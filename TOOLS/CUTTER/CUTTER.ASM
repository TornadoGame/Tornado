;****************************************************************************
;*
;* CUTTER.ASM
;*
;* 05.07.1989 - KJB
;*
;****************************************************************************

		PUBLIC	Cutter
		PUBLIC	AbortToDOS
		PUBLIC	BUF_SIZE
		PUBLIC	DiskBuffer
		PUBLIC	WorkScreen
		PUBLIC	WorkScrPtr
		PUBLIC	RealScrPtr
		PUBLIC	DataMarker
		PUBLIC	RdFile
		PUBLIC	RdFileName
		PUBLIC	WtFile
		PUBLIC	WtFileName
		PUBLIC	ScreenType

		EXTRN	InstallKbd:FAR
		EXTRN	RestoreKbd:FAR
		EXTRN	InstallTimer:FAR
		EXTRN	RestoreTimer:FAR
		EXTRN	InstallCritErr:FAR
		EXTRN	RestoreCritErr:FAR
		EXTRN	InstallOverflow:FAR
		EXTRN	RestoreOverflow:FAR
		EXTRN	InstallMouse:FAR
		EXTRN	RestoreMouse:FAR

		EXTRN	MainMenu:NEAR
	 	EXTRN	CutSprites:NEAR
		EXTRN	CutChars:NEAR
		EXTRN	CompressPic:NEAR
		EXTRN	ViewPic:NEAR

		EXTRN	SSTemp:WORD
		EXTRN	SPTemp:WORD

		EXTRN	Key:BYTE
		EXTRN	OverflowFlag:BYTE

;============================================================================

		INCLUDE	KEYS.INC

;============================================================================

STACK		SEGMENT PARA STACK 'STACK'
		ASSUME SS:STACK

		db	0200h dup(0)

STACK		ENDS

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

;* NO VARS ABOVE WorkScreen!!!

WorkScreen	DB	32000 DUP(0)   	;DATA:0000

BEL		EQU	7
CR		EQU	13
LF		EQU	10

WorkScrPtr	DW	0
RealScrPtr	DW	0

ScreenType	DW	0

DataMarker	db	'BODY'

RdFile		DB	128,0
RdFileName	DB	128 DUP(0)

WtFile		DB	128,0
WtFileName	DB	128 DUP(0)

MainOptions 	DW	CutSprites
		DW	CutChars
		DW	CompressPic
		DW	ViewPic

DATA		ENDS

;============================================================================

BUFDATA		SEGMENT PARA PUBLIC 'DATA'

BUF_SIZE	EQU	64000

DiskBuffer	DB	BUF_SIZE DUP(0)

BUFDATA		ENDS

;============================================================================

CODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:CODE
		ASSUME DS:DATA

Cutter:		push	ds   		;save PSP 
		mov	ax,0			
		push	ax    

		cld	    		;auto-increment

		mov	ax,DATA
		mov	ds,ax
		mov	es,ax

		mov	ax,ss
		mov	SSTemp,ax
		mov	ax,sp
		mov	SPTemp,ax

		call	InstallKbd
 		call	InstallTimer
		call	InstallCritErr
		call	InstallOverflow
		call	InstallMouse

NextItem:	mov	ah,0		;80*25 Alpha mode
		mov	al,3
		int	010h	

		call	MainMenu
		cmp	bx,0
		je	AbortToDOS
		dec	bx
		shl	bx,1
		call	MainOptions[bx]

		jmp	NextItem

AbortToDOS:	call	RestoreMouse
		call	RestoreOverflow
		call	RestoreCritErr
		call	RestoreTimer
		call	RestoreKbd

		mov	al,OverflowFlag
		test	al,al
		jnz	ReturnToDOS
		mov	ah,0		;80*25 Alpha mode
		mov	al,3
		int	010h

ReturnToDOS:	retf

CODE		ENDS

;============================================================================

		END	Cutter

