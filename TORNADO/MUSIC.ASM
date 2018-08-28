;****************************************************************************
;*
;* MUSIC.ASM
;*
;* Theme music.
;*
;* 22.04.1993 - KJB
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	InstallMusic
		PUBLIC	NormaliseMusic
		PUBLIC	SuspendMusic
		PUBLIC	ResumeMusic
		PUBLIC	RefreshMusic

		EXTRN	LoadFile:FAR

		EXTRN	MusicCard:WORD

		EXTRN	DieFlag:BYTE

;============================================================================

		INCLUDE	MAINDATA.INC

		INCLUDE	\LIB8086\USEFUL.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

;-------
;* flags
;-------

Installed	DB	0		;1 = installed

Normalised	DB	0		;1 = normalised

		EVEN

;-----------------------
;* music driver overlays
;-----------------------

;* file names

SpeakerBin	DB	"THEMEB.BIN",0		;SND_SPEAKER
AdLibBin	DB	"THEMEA.BIN",0		;SND_ADLIB
RolandBin	DB	"THEMER.BIN",0		;SND_ROLAND

		EVEN

;* file sizes

FSIZE_SPEAKER	EQU	3741			;SND_SPEAKER
FSIZE_ADLIB	EQU	10970			;SND_ADLIB
FSIZE_ROLAND	EQU	8300			;SND_ROLAND

;* file paragraph sizes (16 byte units)

PSIZE_SPEAKER	EQU	(FSIZE_SPEAKER/16)+1 	;SND_SPEAKER
PSIZE_ADLIB	EQU	(FSIZE_ADLIB/16)+1   	;SND_ADLIB
PSIZE_ROLAND	EQU	(FSIZE_ROLAND/16)+1  	;SND_ROLAND

;* music driver address

MusicDriver	LABEL	DWORD

MusicDriverOff	DW	0
MusicDriverSeg	DW	0

;------------------------
;* music routine switches (wrt MusicCard)
;------------------------

_InstallMusic	DW	InstallNull	;SND_NULL
		DW	InstallSpkr	;SND_SPEAKER
		DW	InstallBlst	;SND_SBLASTER
		DW	InstallAdLb	;SND_ADLIB
		DW	InstallRlnd	;SND_ROLAND

DATA		ENDS			

;============================================================================

SNDCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:SNDCODE
		ASSUME DS:DATA

;* InstallMusic - load music card driver(s) and initialise
;*
;* pass: MusicCard
;* ret : cf = 0 = ok
;*       cf = 1 = error
;*	    DieFlag
;* kill: assume all (except cf)

InstallMusic	PROC	FAR

		mov	bx,MusicCard
		jmp	_InstallMusic[bx]

;---------------------------
InstallNull	LABEL	NEAR
;---------------------------

		clc			;cf = 0 = ok
		ret

;---------------------------
InstallSpkr	LABEL	NEAR
;---------------------------

;* allocate memory for speaker driver

		mov	bx,PSIZE_SPEAKER
		mov	ah,048h		;DOS allocate memory block
		int	021h
		_JC	InstallMemErr

		mov	MusicDriverSeg,ax

;* load speaker driver

		push	es
		mov	cx,FSIZE_SPEAKER
		mov	dx,OFFSET SpeakerBin
		mov	es,ax
		xor	di,di
		call	LoadFile
		pop	es
		jc	InstallFileErr

		mov	dx,0		;no I/O port address

		jmp	ContInstall

;---------------------------
InstallBlst	LABEL	NEAR
InstallAdLb	LABEL	NEAR
;---------------------------

;* allocate memory for AdLib driver

		mov	bx,PSIZE_ADLIB
		mov	ah,048h		;DOS allocate memory block
		int	021h
		jc	InstallMemErr

		mov	MusicDriverSeg,ax

;* load AdLib driver

		push	es
		mov	cx,FSIZE_ADLIB
		mov	dx,OFFSET AdLibBin
		mov	es,ax
		xor	di,di
		call	LoadFile
		pop	es
		jc	InstallFileErr

		mov	dx,00388h	;I/O port address

		jmp	ContInstall

;---------------------------
InstallRlnd	LABEL	NEAR
;---------------------------

;* allocate memory for Roland driver

		mov	bx,PSIZE_ROLAND
		mov	ah,048h		;DOS allocate memory block
		int	021h
		jc	InstallMemErr

		mov	MusicDriverSeg,ax

;* load Roland driver

		push	es
		mov	cx,FSIZE_ROLAND
		mov	dx,OFFSET RolandBin
		mov	es,ax
		xor	di,di
		call	LoadFile
		pop	es
		jc	InstallFileErr

		mov	dx,00331h	;I/O port address

;---------------------------
ContInstall	LABEL	NEAR
;---------------------------

;* initialise

		mov	ah,0
		mov	cx,0
		call	DWORD PTR MusicDriver

		cmp	al,0
		jne	InstallCardErr

;* set timer rate (for 50Hz)

		mov	ah,2
		mov	cx,23864
		call	DWORD PTR MusicDriver

		cmp	al,0
		jne	InstallCardErr

;* start theme tune

		mov	ah,4
		mov	al,1
		call	DWORD PTR MusicDriver

		cmp	al,0
		jne	InstallCardErr

		mov	Installed,1

		clc			;cf = 0 = ok
		ret

;---------------------------
InstallMemErr	LABEL	NEAR
;---------------------------

		mov	DieFlag,SYS_ERR_MMEM

		stc			;cf = 1 = error
		ret

;---------------------------
InstallFileErr	LABEL	NEAR
;---------------------------

		mov	DieFlag,SYS_ERR_MDRVR

		stc			;cf = 1 = error
		ret

;---------------------------
InstallCardErr	LABEL	NEAR
;---------------------------

		mov	DieFlag,SYS_ERR_MCARD

		stc			;cf = 1 = error
		ret

InstallMusic	ENDP

;----------------------------------------------------------------------------

;* NormaliseMusic - turn off music (restore system)
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

NormaliseMusic	PROC	FAR

;* only normalise if installed and not already normalised

		test	Installed,1	;installed?
		jz	@F		;no ->

		test	Normalised,1	;already normalised?
		jnz	@F		;yes ->

		mov	Normalised,1

;* stop theme music

		mov	ah,7
		call	DWORD PTR MusicDriver

;* refresh (required to assert stop)

		mov	ah,3

		cli
		call	DWORD PTR MusicDriver
		sti

;* remove music driver

		mov	ah,1
		call	DWORD PTR MusicDriver

@@:		ret

NormaliseMusic	ENDP

;----------------------------------------------------------------------------

;* SuspendMusic - suspend music
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

SuspendMusic	PROC	FAR

		test	Installed,1
		jz	@F

		mov	ah,7
		call	DWORD PTR MusicDriver

@@:		ret

SuspendMusic	ENDP

;----------------------------------------------------------------------------

;* ResumeMusic - resume music
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

ResumeMusic	PROC	FAR

		test	Installed,1
		jz	@F

		mov	ah,4
		mov	al,1
		call	DWORD PTR MusicDriver

@@:		ret

ResumeMusic	ENDP

;----------------------------------------------------------------------------

;* RefreshMusic - refresh music (under interrupt)
;*
;* pass: MusicCard
;* ret : nothing
;* kill: assume all
;*
;* note: Call from 50Hz interrupt.

RefreshMusic	PROC	FAR

		test	Installed,1
		jz	@F
				 
		mov	ah,3
		call	DWORD PTR MusicDriver

@@:		ret

RefreshMusic	ENDP

SNDCODE		ENDS

;============================================================================

		END

