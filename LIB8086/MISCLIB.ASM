;****************************************************************************
;*
;* MISCLIB.ASM
;*
;* Miscellaneous library routines.
;*
;* 15.08.1989 - KJB
;* 30.08.1991 - KJB - DrawRectangle added.
;* 31.03.1992 - KJB - TestInsideBoxes, ShowMouse and HideMouse routines
;*                    to MOUSE.ASM from this module.
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	PrintEGASpace
		PUBLIC	SelectMode
		PUBLIC	Cls
		PUBLIC	ConvPDeg$
		PUBLIC	DecWord$
		PUBLIC	ZDecWord$
		PUBLIC	HexWord$
		PUBLIC	HexByte$
		PUBLIC	ConvNum$
		PUBLIC	QuickSetUp
		PUBLIC	RunLenDecode
		PUBLIC	CalcBitFieldVal
		PUBLIC	TestBitStatus
		PUBLIC	DrawRectangle

		PUBLIC	HexChars

		EXTRN	Print$:FAR
		EXTRN	DownLoad:FAR
		EXTRN	GetChar:FAR
		EXTRN	KeyPress:FAR
		EXTRN	BlockFill:FAR
		EXTRN	LineDraw:FAR
		EXTRN	SetVideoMode:FAR
		EXTRN	SetSSpriteClip:FAR
		EXTRN	InitSSprites:FAR
		EXTRN	InitMSprites:FAR
		EXTRN	InitQSprites:FAR
		EXTRN	ReSeed:FAR

		EXTRN	ScreenMode:WORD
		EXTRN	FlipMode:WORD
		EXTRN	EGAFreeSpace:WORD

		EXTRN	EGA:ABS 
		EXTRN	GAME_MODE:ABS

;============================================================================

		INCLUDE	PRINT.INC
		INCLUDE	USEFUL.INC
		INCLUDE	PALETTES.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

HexChars	DB	"0123456789abcdef"

;====================
;* PrintEGASpace data
;====================

Free$		LABEL	BYTE
		P_CHAR2
		P_OVER0
		P_DEFCL
		PD_XY	0*4,0
		DB	"EGA SPRITE USAGE:- "
		PV_HEXW	EGAFreeSpace+4
		PD_XYMV	-6*4,6
		PV_HEXW	EGAFreeSpace+6
		PD_XYMV	-6*4,6
		PV_HEXW	EGAFreeSpace+8
		PD_XYMV	-6*4,6
		PV_HEXW	EGAFreeSpace+10
		PD_XYMV	-6*4,6
		PV_HEXW	EGAFreeSpace+12
		PD_XYMV	-6*4,6
		PV_HEXW	EGAFreeSpace+14
		PD_XY	0*4,36
		DB	"HIT ANY KEY ... "
		P_END

		EVEN

;=================
;* SelectMode data
;=================

TAB		EQU	9
CR		EQU	13
LF		EQU	10

Prompt$		DB	CR,LF,"Select screen type: ",'$'

HGC$		DB	"[H] Hercules",CR,LF,TAB,TAB,"    ",'$'
HEM$		DB	"[S] Hercules Emulation",CR,LF,TAB,TAB,"    ",'$'
CGA$		DB	"[C] CGA or TANDY 4 Colour",CR,LF,TAB,TAB,"    ",'$'
EGA$		DB	"[E] EGA",CR,LF,TAB,TAB,"    ",'$'
TAN$		DB	"[T] TANDY 16 Colour",CR,LF,TAB,TAB,"    ",'$'
TEM$		DB	"[Y] TANDY 16 Colour Emulation",CR,LF,TAB,TAB,"    ",'$'
V16$		DB	"[X] VGA 16 Colour",CR,LF,TAB,TAB,"    ",'$'
VGA$		DB	"[V] VGA 256 Colour",CR,LF,TAB,TAB,"    ",'$'

Tail$		DB	CR,LF,'$'

		EVEN

Mode$Ptrs	DW	OFFSET HGC$
		DW	OFFSET HEM$
		DW	OFFSET CGA$
		DW	OFFSET EGA$
		DW	OFFSET TAN$
		DW	OFFSET TEM$
		DW	OFFSET V16$
		DW	OFFSET VGA$

ModeKeys	DB	'H'
		DB	'S'
		DB	'C'
		DB	'E'
		DB	'T'
		DB	'Y'
		DB	'X'
		DB	'V'

		EVEN

DATA		ENDS

;============================================================================

LIBCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:LIBCODE
		ASSUME DS:DATA

;* PrintEGASpace - print free space for EGA sprites
;*
;* pass: EGAFreeSpace[]
;* ret : nothing
;* kill: assume all

PrintEGASpace	PROC	FAR

		mov	ax,ScreenMode
		cmp	ax,EGA
		jne	SkipFreeSpace

		mov	si,OFFSET Free$
		call	Print$

		call	DownLoad

		call	KeyPress

SkipFreeSpace:	ret

PrintEGASpace	ENDP

;----------------------------------------------------------------------------

;* SelectMode - select screen mode
;*
;* pass: al = modes available:-
;*               b0: HGC
;*               b1: HEM
;*               b2: CGA
;*               b3: EGA
;*               b4: TAN
;*               b5: TEM
;*               b6: V16
;*		 b7: VGA
;* ret : ax = ScreenMode
;* kill: assume all

SelectMode	PROC	FAR

		push	ax
		mov	ah,9
		mov	dx,OFFSET Prompt$
		int	021h
		pop	ax

		mov	ah,al
		xor	bx,bx
		mov	cx,8
ModePrintLoop:	ror	al,1
		jnc	SkipPrint
		push	ax
		push	bx
		push	cx
		mov	ah,9
		mov	dx,Mode$Ptrs[bx]
		int	021h
		pop	cx
		pop	bx
		pop	ax
SkipPrint:	add	bx,2
		loop	ModePrintLoop

		push	ax
		mov	ah,9
		mov	dx,OFFSET Tail$
		int	021h
		pop	ax

		mov	dh,ah
		
SelectLoop:	call	GetChar

		mov	dl,dh
		xor	bx,bx
		mov	cx,8
KeyTestLoop:	ror	dl,1
		jnc	SkipKeyTest
		cmp	al,ModeKeys[bx]
		je	FoundMode
SkipKeyTest:	inc	bx
		loop	KeyTestLoop

		jmp	SelectLoop

FoundMode:	mov	ax,bx
		shl	ax,1
		mov	ScreenMode,ax

		ret
			
SelectMode	ENDP

;----------------------------------------------------------------------------

;* Cls - clear screen
;*
;* pass: al = logical colour
;* ret : nothing
;* kill: assume all

Cls		PROC	FAR

		mov	bl,0
		mov	bh,199
		mov	cx,0
		mov	dx,319
		call	BlockFill
		ret

Cls		ENDP

;----------------------------------------------------------------------------

;* ConvPDeg$ - convert pseudo degrees to ASCIIZ string
;*
;* pass: ax = pseudo degrees (0 .. 511)
;*       di -> string buffer (space for 3 chars, assumed to have 0 terminator)
;* ret : ax = real degrees (0 .. 359)
;* kill: ax, bx, dx, bp, flags

ConvPDeg$	PROC	FAR

		CALC_RDEG

		mov	bp,dx		;store real degrees

		test	dx,dx
		jnz	SkipPDeg360	;not 360 degrees ->

		mov	dx,360

SkipPDeg360:	mov	al,' '
		mov	[di+0],al
		mov	[di+1],al
		mov	[di+2],al

		mov	ax,dx

		mov	bx,10

		xor	dx,dx
		div	bx
		add	dl,'0'
		xchg	al,dl
		mov	[di+2],al
		xchg	al,dl
		test	ax,ax
		jz	DonePDeg

		xor	dx,dx
		div	bx
		add	dl,'0'
		xchg	al,dl
		mov	[di+1],al
		xchg	al,dl
		test	ax,ax
		jz	DonePDeg

		xor	dx,dx
		div	bx
		add	dl,'0'
		mov	al,dl
		mov	[di+0],al

DonePDeg:	mov	ax,bp		;restore real degrees
		ret

ConvPDeg$	ENDP

;----------------------------------------------------------------------------

;* DecWord$ - convert unsigned word to ASCIIZ string (leading spaces)
;* ZDecWord$ - convert unsigned word to ASCIIZ string (leading zeroes)
;*
;* pass: ax = unsigned word
;*       di -> string buffer (space for 5 chars, assumed to have 0 terminator)
;* ret : nothing
;* kill: ax, bx, dx, flags

ZDecWord$	LABEL	FAR

		mov	dx,ax
		mov	al,'0'
		jmp	ClearBuffer

DecWord$	PROC	FAR

		mov	dx,ax
		mov	al,' '
ClearBuffer:	mov	[di+0],al
		mov	[di+1],al
		mov	[di+2],al
		mov	[di+3],al
		mov	[di+4],al
		mov	ax,dx

		test	ax,ax
		jz	ZeroWord	;0 ->

		mov	bx,10

		xor	dx,dx
		div	bx
		add	dl,'0'
		xchg	al,dl
		mov	[di+4],al
		xchg	al,dl
		test	ax,ax
		jz	DoneWord

		xor	dx,dx
		div	bx
		add	dl,'0'
		xchg	al,dl
		mov	[di+3],al
		xchg	al,dl
		test	ax,ax
		jz	DoneWord

		xor	dx,dx
		div	bx
		add	dl,'0'
		xchg	al,dl
		mov	[di+2],al
		xchg	al,dl
		test	ax,ax
		jz	DoneWord

		xor	dx,dx
		div	bx
		add	dl,'0'
		xchg	al,dl
		mov	[di+1],al
		xchg	al,dl
		test	ax,ax
		jz	DoneWord

		xor	dx,dx
		div	bx
		add	dl,'0'
		mov	al,dl
		mov	[di+0],al

DoneWord:	ret

ZeroWord:    	mov	al,'0'
		mov	[di+4],al
		ret		
		
DecWord$	ENDP

;----------------------------------------------------------------------------

;* HexWord$ - calc hex word and put into string
;*
;* pass: ax = word
;*       es:di -> string
;* ret : hex word in string
;* kill: ax, bx, cx, dx, di, flags

HexWord$	PROC	FAR

		mov	bx,OFFSET HexChars
		mov	cx,4
		mov	dx,ax

HexWord$Loop:	mov	al,dh
		shr	al,1
		shr	al,1
		shr	al,1
		shr	al,1
		xlat
		stosb
		shl	dx,1
		shl	dx,1
		shl	dx,1
		shl	dx,1
		loop	HexWord$Loop

		ret

HexWord$	ENDP

;----------------------------------------------------------------------------

;* HexByte$ - calc hex byte and put into string
;*
;* pass: al = byte
;*       es:di -> string
;* ret : hex byte in string
;* kill: ax, bx, di, flags

HexByte$	PROC	FAR

		mov	ah,al
		mov	bx,OFFSET HexChars

		mov	al,ah
		shr	al,1
		shr	al,1
		shr	al,1
		shr	al,1
		xlat
		stosb
		mov	al,ah
		and	al,00fh
		xlat
		stosb

		ret

HexByte$	ENDP

;----------------------------------------------------------------------------

;* ConvNum$ - convert ASCIIZ digit string to unsigned 32-bit number
;*
;* pass: si -> ASCIIZ string
;* ret : dx, ax = unsigned 32-bit number
;* kill: bx, cx, di, bp, flags
;* 
;* note: The digit string is terminated by any non '0' .. '9' character.
;*       A maximum of 5 digits are allowed (0 .. 99999).

ConvNum$	PROC	FAR

		xor	bx,bx		;reset string index
	 	mov	cx,5		;max of 5 digits

;* search for end of string (locate least significant digit)

CheckNextDigit:	mov	al,[si+bx]
		cmp	al,'0'		;valid digit?
		jb	ConvNumber	;no ->
		cmp	al,'9'		;valid digit?
		ja	ConvNumber	;no ->
		inc	bx		;next digit
		loop	CheckNextDigit	

ConvNumber:	xor	cx,cx		;clear temp result
		xor	di,di

		mov	bp,1		;multiplier

ConvNumLoop:	dec	bx
		js	ConvNumExit	;done all digits ->

		mov	al,[si+bx]
		sub	al,'0'
		xor	ah,ah

		mul	bp

		add	cx,ax
		adc	di,dx

		shl	bp,1		;*2
		mov	ax,bp
		shl	bp,1		;*4
		shl	bp,1		;*8
		add	bp,ax		;multiplier * 10		

		jmp	ConvNumLoop

ConvNumExit:	mov	dx,di
		mov	ax,cx
		ret

ConvNum$	ENDP

;----------------------------------------------------------------------------

;* QuickSetUp - general purpose library initialization
;*
;* pass: ax = screen mode
;* ret : nothing
;* kill: assume all

QuickSetUp	PROC	FAR 

;* set video mode

		mov	ScreenMode,ax
		mov	FlipMode,GAME_MODE

		call	SetVideoMode

;* clear real screen and work screen

		mov	al,COL_BLACK
		call	Cls
		call	DownLoad

		mov	al,COL_BLACK
		call	Cls
		call	DownLoad

;* init sprite window wrt screen mode (max screen size)

		mov	bl,0
		mov	bh,199
		mov	cx,0
		mov	dx,319
		call	SetSSpriteClip

;* init sprites

		call	InitSSprites
		call	InitMSprites
		call	InitQSprites

;* clear work screen again (may have been used as buffer for sprite init)

		mov	al,COL_BLACK
		call	Cls
		call	DownLoad

;* miscellaneous

		call	ReSeed

		ret

QuickSetUp	ENDP

;----------------------------------------------------------------------------

;* RunLenDecode - run length decode
;*
;* pass: ds:si -> encoded data buffer
;* ret : es:di -> decoded data buffer
;* kill: ax, cx, si, di, bp, flags
;*
;* Run Length Encoding format:-
;*
;* The first two bytes give the length of the following data.
;*
;*  0 ... +127: copy the next n + 1 bytes literally
;* -1 ... -127: copy the next byte -n + 1 times
;*        -128: no operation (see below)
;*
;* I have modified this format so that -128 indicates that the following
;* counter is a 16-bit value. This should improve the compression.

RunLenDecode	PROC	FAR

		lodsw			;length of data
		mov	bp,ax
		add	bp,si		;ds:bp -> end of data + 1

NextData:	lodsb	      		;fetch counter
		cbw	
		cmp	ax,-128		;16-bit counter following?
		jne	TestCntrType	;no ->
		lodsw			;fetch 16-bit counter	

TestCntrType:	test	ax,ax
		js	RepeatCopy

;* copy the next n + 1 bytes literally

LiteralCopy:	mov	cx,ax
		inc	cx
		rep	movsb
		jmp	TestForDataEnd

;* copy the next byte -n + 1 times

RepeatCopy:	neg	ax
		mov	cx,ax
		inc	cx
		lodsb
		rep	stosb

TestForDataEnd:	cmp	si,bp
		jb	NextData

		ret

RunLenDecode	ENDP

;----------------------------------------------------------------------------

;* CalcBitFieldVal - calc bit position in bit field
;*
;* pass: ax = bit field mask
;*       dx = status
;* ret : ax = bit position in bit field
;*       ax = 0 if error occured (bad pass parameters)
;* kill: flags
;*
;* note: This routine is intended for use with processing the status word
;*       returned from DialogBox.
;*
;*       If a "select" option uses (say) bits B7, B6, B5, B4; we may need
;*       to convert the selected bit position into a more useful value
;*       (say) 0 .. 3.
;*
;*	 Example:-
;*
;*	 mov	si,OFFSET DialogData
;*       call	DialogBox		;ax = status
;*
;*	 mov	dx,ax
;*
;*       mov	ax,B7+B6+B5+B4		;ax = bit field mask
;*	 call	CalcBitFieldVal		;ax = 0 .. 3

CalcBitFieldVal	PROC	FAR

		push	cx
		push	dx

		and	dx,ax		;clear unwanted bits

;* calc position of status bit (b0 .. b15)

		mov	cx,15
StatusBitLoop:	shl	dx,1  		;(msb into cf)
		jc	FoundStatusBit
		loop	StatusBitLoop

FoundStatusBit:	mov	dx,cx		;0 .. 15 = b0 .. b15

;* calc position of first bit of bit field mask

		mov	cx,15
FirstBitLoop:	shr	ax,1		;(lsb into cf)
		jc	FoundFirstBit
		loop	FirstBitLoop

FoundFirstBit:	mov	ax,15
		sub	ax,cx		;0 .. 15 = b0 .. b15

		xchg	ax,dx
		sub	ax,dx		;status bit pos wrt first bit pos

		MINM	ax		;return ax = 0 if error

		pop	dx
		pop	cx
		ret

CalcBitFieldVal	ENDP

;----------------------------------------------------------------------------

;* TestBitStatus - test bit status
;*
;* pass: ax = bit mask
;*       dx = status
;* ret : ax = 0 or 1
;* kill: flags
;*
;* note: This routine is intended for use with processing the status word
;*       returned from DialogBox.
;*
;*	 Example:-
;*
;*	 mov	si,OFFSET DialogData
;*       call	DialogBox		;ax = status
;*
;*	 mov	dx,ax
;*
;*       mov	ax,B10			;ax = bit to test
;*	 call	TestBitStatus		;ax = 0 or 1

TestBitStatus	PROC	FAR

		test	dx,ax
		mov	ax,0		;assume reset
		jz	TestBitExit	;reset ->
		mov	ax,1
		
TestBitExit:	ret

TestBitStatus	ENDP

;----------------------------------------------------------------------------

;* DrawRectangle - line draw rectangle
;*
;* pass: al = logical colour
;*       bl = y min (y1)
;*       bh = y max (y2)
;*       cx = x min (x1)
;*       dx = x max (x2)
;* ret : nothing
;* kill: assume all

DrawRectangle	PROC	FAR

;* x min, y min ----> x max, y min

		push	ax
		push	bx
		push	cx
		push	dx
		mov	bh,bl
		call	LineDraw
		pop	dx
		pop	cx
		pop	bx
		pop	ax

;* x max, y min ----> x max, y max

		push	ax
		push	bx
		push	cx
		push	dx
		mov	cx,dx
		call	LineDraw
		pop	dx
		pop	cx
		pop	bx
		pop	ax

;* x max, y max ----> x min, y max

		push	ax
		push	bx
		push	cx
		push	dx
		mov	bl,bh
		call	LineDraw
		pop	dx
		pop	cx
		pop	bx
		pop	ax

;* x min, y max ----> x min, y min

		mov	dx,cx
		call	LineDraw

		ret

DrawRectangle	ENDP

LIBCODE		ENDS

;============================================================================

		END

