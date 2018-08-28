;****************************************************************************
;*
;* COMPRESS.ASM
;*
;* 06.07.1989 - KJB
;*
;****************************************************************************

		PUBLIC	CompressPic

		EXTRN	SaveFile:FAR

		EXTRN	ScanKeys:NEAR
		EXTRN	LoadPicFile:NEAR
		EXTRN	GetReadFile:NEAR
		EXTRN	GetWriteFile:NEAR
		EXTRN	VideoMode:NEAR
		EXTRN	DownLoad:NEAR
		EXTRN	SortRaw:NEAR

		EXTRN	ScreenType:WORD

		EXTRN	DiskBuffer:BYTE
		EXTRN	WorkScreen:BYTE
		EXTRN	WtFileName:BYTE

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

BEL		EQU	7
CR		EQU	13
LF		EQU	10

Msg1$		DB	CR,LF,CR,LF
		DB	"Compress Picture File",CR,LF
		DB	"---------------------",CR,LF
		DB	CR,LF
		DB	"Select input data format:-",CR,LF
		DB	CR,LF
		DB	"A ... CGA",CR,LF
		DB	" B ... EGA",CR,LF
		DB	CR,LF
		DB	"Hit key A - B ... "
		DB	'$'

		EVEN

ScreenSize	DW	OFFSET WorkScreen + 200*80	;CGA
		DW	OFFSET WorkScreen + 200*160  	;TANDY

DATA		ENDS

;============================================================================

CODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:CODE
		ASSUME DS:DATA

;* CompressPic - compress picture data
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

CompressPic	PROC	NEAR

		mov	ah,9
		mov	dx,OFFSET Msg1$
		int	021h

		mov	dx,'B'-'A'
		call	ScanKeys

		shl	bx,1
		mov	ScreenType,bx

		call	GetReadFile

		call	GetWriteFile

		call	VideoMode

		call	LoadPicFile

		call	SortRaw
		
		call	DownLoad

		call	Compress

		ret

CompressPic	ENDP

;----------------------------------------------------------------------------

;* Compress - compress picture file
;*
;* pass: WorkScreen[] = uncompressed picture
;*       ScreenType
;* ret : nothing
;* kill: assume all
;* note: Store 2 byte for file length, then the RLE screen data.

Compress	PROC	NEAR

		push	es

		mov	si,OFFSET WorkScreen

		mov	ax,SEG DiskBuffer
		mov	es,ax
		mov	di,OFFSET DiskBuffer

		xor	ax,ax		;clear file length
		stosw

		mov	bx,ScreenType
		mov	bp,ScreenSize[bx]

CompressLoop:	call	CountNonConsec
		pushf
		cmp	bx,0
		je	NoNonConsec
		cmp	bx,128		;use 16-bit counter?
		ja	NonConsec16	;yes ->

		mov	al,bl
		dec	al
		stosb
		mov	cx,bx
		rep	movsb
		jmp	NoNonConsec

NonConsec16:	mov	al,-128		;16-bit counter signal
		stosb
		mov	ax,bx
		dec	ax
		stosw
		mov	cx,bx
		rep	movsb

NoNonConsec:	popf
		jc	HitEOF

		call	CountConsec
		pushf
		cmp	bx,0
		je	NoConsec
		cmp	bx,128 		;use 16-bit counter?
		ja 	Consec16   	;yes ->

		mov	al,bl
		dec	al
		neg	al
		stosb
		mov	al,[si]
		stosb
		add	si,bx
		jmp	NoConsec

Consec16:	mov	al,-128		;16-bit counter signal
		stosb
		mov	ax,bx
		dec	ax
		neg	ax
		stosw
		mov	al,[si]
		stosb
		add	si,bx

NoConsec:	popf
		jc	HitEOF

		jmp	CompressLoop

HitEOF:		

;* calc length of RLE data and store at start of file

		sub	di,OFFSET DiskBuffer
		mov	cx,di
		sub	di,2
		mov	ax,di
		mov	di,OFFSET DiskBuffer
		mov	es:[di],ax
		mov	dx,OFFSET WtFileName
		call	SaveFile

		pop	es
		ret

Compress	ENDP

;----------------------------------------------------------------------------

;* CountNonConsec - count number of non-consecutive bytes
;*
;* pass: ds:si -> work screen
;*       bp = screen size
;* ret : bx = number of non-consecutive bytes
;*       cf = 1 = EOF encountered
;* kill: ax, flags

CountNonConsec	PROC	NEAR

		xor	bx,bx		;counter = 0
	       
CountLoop:	mov	ax,si		;test for EOF
		add	ax,bx
		cmp	ax,bp
		je	FoundEOF

		mov	al,[si+bx]  	;stop if 3 consec bytes found
		cmp	al,[si+bx+1]
		jne	NotConsecByte
		cmp	al,[si+bx+2]
		je	EndCount

NotConsecByte:	inc	bx
		jmp	CountLoop

EndCount:	clc
		ret

FoundEOF:	stc
		ret

CountNonConsec	ENDP

;----------------------------------------------------------------------------

;* CountConsec - count number of consecutive bytes
;*
;* pass: ds:si -> work screen
;*       bp = screen size
;* ret : bx = number of consecutive bytes
;*       cf = 1 = EOF encountered
;* kill: ax, flags

CountConsec:	xor	bx,bx		;counter = 0

		mov	al,[si+bx]  	
	       
_CountLoop:	mov	dx,si		;test for EOF
		add	dx,bx
		cmp	dx,bp
		je	_FoundEOF

		cmp	al,[si+bx]
		jne	_EndCount

		inc	bx
		jmp	_CountLoop

_EndCount:	clc
		ret

_FoundEOF:	stc
		ret

CODE		ENDS

;============================================================================

		END

