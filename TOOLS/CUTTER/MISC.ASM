;****************************************************************************
;*
;* MISC.ASM
;*
;* 06.07.1989 - KJB
;*
;****************************************************************************

		PUBLIC	ScanKeys
		PUBLIC	GetReadFile
		PUBLIC	GetWriteFile
		PUBLIC	VideoMode
		PUBLIC	DownLoad
		PUBLIC	DeltaDownLoad
		PUBLIC	SelectColour
		PUBLIC	XorBox
		PUBLIC	UpdateBox
		PUBLIC	ResetBox
		PUBLIC	FrameWait
		PUBLIC	CalcAddr
		PUBLIC	Beep

		PUBLIC	MaskColour
		PUBLIC	BoxX
		PUBLIC	BoxY
		PUBLIC	BoxWidth
		PUBLIC	BoxDepth
		PUBLIC	BoxMinWidth
		PUBLIC	BoxMaxWidth
		PUBLIC	BoxMinDepth
		PUBLIC	BoxMaxDepth
		PUBLIC	BoxXStep
		PUBLIC	BoxYStep
		PUBLIC	BoxXBoundary

		EXTRN	InstallKbd:FAR
		EXTRN	RestoreKbd:FAR
		EXTRN	UpdateMouse:FAR
		EXTRN	SetMousePos:FAR
		EXTRN	ResetMouse:FAR

		EXTRN	CGA_VMode:NEAR
		EXTRN	CGA_DLoad:NEAR
		EXTRN	TEM_VMode:NEAR
		EXTRN	TEM_DLoad:NEAR

		EXTRN	WorkScrPtr:WORD
		EXTRN	ScreenType:WORD
		EXTRN	MouseX:WORD
		EXTRN	MouseY:WORD
		EXTRN	Frames:WORD

		EXTRN	RdFile:BYTE
		EXTRN	WtFile:BYTE
		EXTRN	Key:BYTE
		EXTRN	DeltaTable:BYTE
		EXTRN	LhsButton:BYTE
		EXTRN	RhsButton:BYTE
      		EXTRN	OldLhsButton:BYTE
		EXTRN	OldRhsButton:BYTE

;============================================================================

		INCLUDE	KEYS.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

BEL		EQU	7
CR		EQU	13
LF		EQU	10

KList		DB	K_A,K_B,K_C,K_D,K_E,K_F,K_G,K_H,K_I,K_J,K_K,K_L,K_M
		DB	K_N,K_O,K_P,K_Q,K_R,K_S,K_T,K_U,K_V,K_W,K_X,K_Y,K_Z

_VideoMode	DW	CGA_VMode
		DW	TEM_VMode

_DownLoad	DW	CGA_DLoad
		DW	TEM_DLoad

MaskColour	DB	0,0

;* Note: widths are in bytes - 2 pixels / byte

BoxX		DW	0
BoxY		DW	0
BoxWidth	DW	16 		;>= BoxXStep
BoxDepth	DW	16		;>= BoxYStep
BoxMinWidth	DW	1		;>= BoxXStep
BoxMaxWidth	DW	160
BoxMinDepth	DW	1		;>= BoxYStep
BoxMaxDepth	DW	200
BoxXStep	DW	1
BoxYStep	DW	1

;* BoxXBoundary is used to restrict box x movement to certain boundaries.
;* Its default value is 0fffeh so if you change this value then make sure
;* that you restore the default value at some point.

BoxXBoundary	DW	0fffeh

RdFile$		DB	CR,LF,CR,LF
		DB	"Read data from? (drive:\path\filename.ext)"
		DB	CR,LF
		DB	">>>"
		DB	'$'

		EVEN

WtFile$		DB	CR,LF,CR,LF
		DB	"Write data to? (drive:\path\filename.ext)"
		DB	CR,LF
		DB	">>>"
		DB	'$'

		EVEN

Mask$		DB	CR,LF,CR,LF
		DB	"      IRGB",CR,LF
		DB	"A ... 0000 = Black",CR,LF
		DB	" B ... 0001 = Blue",CR,LF
		DB	"  C ... 0010 = Green",CR,LF
		DB	"   D ... 0011 = Cyan",CR,LF
		DB	"    E ... 0100 = Red",CR,LF
		DB	"     F ... 0101 = Magenta",CR,LF
		DB	"      G ... 0110 = Brown",CR,LF
		DB	"       H ... 0111 = Light Grey",CR,LF
		DB	"        I ... 1000 = Dark Grey",CR,LF
		DB	"         J ... 1001 = Light Blue",CR,LF
		DB	"          K ... 1010 = Light Green",CR,LF
		DB	"           L ... 1011 = Light Cyan",CR,LF
		DB	"            M ... 1100 = Light Red",CR,LF
		DB	"             N ... 1101 = Light Magenta",CR,LF
		DB	"              O ... 1110 = Yellow",CR,LF
		DB	"               P ... 1111 = White",CR,LF
		DB	CR,LF
		DB	"Hit key A - P ... "
		db	'$'

		EVEN

DATA		ENDS

;============================================================================

CODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:CODE
		ASSUME DS:DATA

;* ScanKeys - scan keys A - Z
;*
;* pass: dx = max option allowed (0 = A, 1 = B etc.)
;* ret : cf = 0 = bx = option number (0 = A, 1 = B etc.)
;*       cf = 1 = ESC key pressed (bx = 0)
;* kill: al, si, flags

ScanKeys	PROC	NEAR

		xor	bx,bx

		mov	al,Key[K_ESC]
		test	al,al
		jnz	ScanESC

ScanLoop:	mov	al,KList[bx]
		xor	ah,ah
		mov	si,ax
		mov	al,Key[si]
		test	al,al
		jnz	ScanExit
		inc	bx
		cmp	bx,dx
		jbe	ScanLoop		
		jmp	ScanKeys

ScanExit:	push	bx
		push	si
		mov	ah,2
		mov	dl,bl
		add	dl,'A'
		int	021h
		pop	si
		pop	bx
KeyReleaseLoop:	mov	al,Key[si]	;wait for key release
		test	al,al
		jnz	KeyReleaseLoop
		clc
		ret		

ScanESC:	stc
		ret

ScanKeys	ENDP

;----------------------------------------------------------------------------

;* GetReadFile - get filename of data to read
;*
;* pass: nothing
;* ret : RdFile
;* kill: assume all

GetReadFile	PROC	NEAR

		call	RestoreKbd

GetReadAgain:	mov	ah,9
		mov	dx,OFFSET RdFile$
		int	021h

		mov	ah,10
		mov	dx,OFFSET RdFile
		int	021h

		mov	al,RdFile[1]	;any chars entered?
		cmp	al,0
		je	GetReadAgain	;no ->

		mov	bl,al		;change CR to ASCIIZ terminator
		xor	bh,bh
		add	bx,2
		mov	RdFile[bx],0

		call	InstallKbd

		ret

GetReadFile	ENDP

;----------------------------------------------------------------------------

;* GetWriteFile - get filename of data to write
;*
;* pass: nothing
;* ret : WtFile
;* kill: assume all

GetWriteFile	PROC	NEAR

		call	RestoreKbd

GetWriteAgain:	mov	ah,9
		mov	dx,OFFSET WtFile$
		int	021h

		mov	ah,10
		mov	dx,OFFSET WtFile
		int	021h

		mov	al,WtFile[1]	;any chars entered?
		cmp	al,0
		je	GetWriteAgain	;no ->

		mov	bl,al		;change CR to ASCIIZ terminator
		xor	bh,bh
		add	bx,2
		mov	WtFile[bx],0

		call	InstallKbd

		ret

GetWriteFile	ENDP

;----------------------------------------------------------------------------

;* VideoMode - set video mode
;*
;* pass: ScreenType
;* ret : WorkScrPtr
;*       RealScrPtr
;* kill: assume all

VideoMode	PROC	NEAR

		mov	bx,ScreenType
		call	_VideoMode[bx]

		call	ResetMouse

		ret

VideoMode	ENDP

;----------------------------------------------------------------------------

;* DownLoad - download work screen to real screen
;*
;* pass: ScreenType
;*       WorkScrPtr
;*       RealScrPtr
;* ret : nothing
;* kill: assume all

DownLoad	PROC	NEAR

		mov	al,1
		mov	cx,200
		mov	di,OFFSET DeltaTable
		rep	stosb

		mov	bx,ScreenType
		call	_DownLoad[bx]
		ret

DownLoad	ENDP

;----------------------------------------------------------------------------

;* DeltaDownLoad - download part of screen which has changed
;*
;* pass: ScreenType
;*       WorkScrPtr
;*       RealScrPtr
;* ret : nothing
;* kill: assume all

DeltaDownLoad	PROC	NEAR

		mov	bx,ScreenType
		call	_DownLoad[bx]
		ret

DeltaDownLoad	ENDP

;----------------------------------------------------------------------------

;* SelectColour - select colour
;*
;* pass: nothing
;* ret : bx = MaskColour = colour 0 - 15
;* kill: assume all

SelectColour	PROC	NEAR

		mov	ah,9
		mov	dx,OFFSET Mask$
		int	021h

		mov	dx,'P'-'A'
		call	ScanKeys
		mov	MaskColour,bl
		ret

SelectColour	ENDP

;----------------------------------------------------------------------------

;* XorBox - draw box using XOR
;*
;* pass: MouseX, MouseY, BoxWidth, BoxDepth
;* ret : nothing
;* kill: assume all

XorBox		PROC	NEAR

		mov	al,1
		mov	cx,BoxDepth
		mov	di,BoxY
		add	di,OFFSET DeltaTable
		rep	stosb
		
		push	es
		mov	es,WorkScrPtr

		mov	bl,BYTE PTR BoxY
		mov	cx,BoxX
		call	CalcAddr

		mov	al,0ffh
		mov	bx,BoxWidth
		mov	dx,BoxDepth
BoxLoop1:	mov	bp,di
		mov	cx,bx
BoxLoop2:	xor	es:[di],al
		inc	di
		loop	BoxLoop2
		mov	di,bp
		add	di,160
		dec	dx
		jnz	BoxLoop1

		pop	es
		ret

XorBox		ENDP

;----------------------------------------------------------------------------

;* CalcAddr - calculate screen address
;*
;* pass: bl = y (0 - 199)
;*       cx = x (0 - 319)
;* ret : di = screen address = y * 160 + x / 2
;* kill: ax, flags

CalcAddr	PROC	NEAR

		mov	al,bl
		xor	ah,ah
		shl	ax,1
		shl	ax,1
		shl	ax,1
		shl	ax,1
		shl	ax,1		;*32
		mov	di,ax
		shl	ax,1   
		shl	ax,1		;*128
		add	di,ax		;*160
		mov	ax,cx
		shr	ax,1		;/2
		add	di,ax
		ret

CalcAddr	ENDP

;----------------------------------------------------------------------------

;* UpdateBox - update xor box
;*
;* pass: all Box vars
;* ret : BoxX, BoxY
;* kill: assume all

UpdateBox	PROC	NEAR

		call	UpdateMouse

;* has lh button status changed?

		mov	al,LhsButton
		xor	al,OldLhsButton
		jz	TestStatus

		mov	al,LhsButton
		test	al,al		;button pressed?
		jz	ButtonReleased	;no ->

;* button just pressed, move mouse to bottom rh corner of box

		mov	cx,BoxWidth
		shl	cx,1
		add	cx,BoxX
		dec	cx
		mov	dx,BoxDepth
		add	dx,BoxY
		dec	dx
	        call	SetMousePos
		jmp	TestStatus

;* button just released, move mouse to top lh corner of box

ButtonReleased:	mov	cx,BoxX
		mov	dx,BoxY
		call	SetMousePos	

;* moving box or changing box size?

TestStatus:	mov	al,LhsButton
		test	al,al
		jnz	ChangeBoxSize 
   
;* has mouse moved?

		mov	ax,MouseX
		cmp	ax,BoxX
		jne	BoxMoved
		mov	ax,MouseY
		cmp	ax,BoxY
	   	je	ExitLink

;* can box be moved?

BoxMoved:	mov	cx,MouseX
		mov	dx,MouseY

TryXMove:	mov	ax,BoxWidth	
		shl	ax,1		;width in pixels
		mov	bx,ax
		add	ax,cx		;mouse x + pixel width
		cmp	ax,320		;> rh boundary?
		jbe	TryYMove	;no, x position ok ->
		mov	cx,320
		sub	cx,bx		;max x position
TryYMove:	mov	ax,BoxDepth	;depth in pixels
		mov	bx,ax
		add	ax,dx		;mouse y + pixel depth
		cmp	ax,200		;> bottom boundary?
		jbe	TestMove	;no, y position ok ->
		mov	dx,200
		sub	dx,bx		;max y position

TestMove:	call	SetMousePos

		cmp	cx,BoxX
		jne	BoxCanMove
		cmp	dx,BoxY
		je	ExitLink

BoxCanMove:	call	XorBox
		mov	ax,MouseX
		and	ax,BoxXBoundary	;fix to required boundary
		mov	BoxX,ax
		mov	ax,MouseY
		mov	BoxY,ax
		call	XorBox

ExitLink:	jmp	UpdateBoxExit

;* calc new width and depth and check limits

ChangeBoxSize: 	mov	cx,MouseX
		sub	cx,BoxX

;* I changed the order of the following two lines of code in order to fix a
;* bug caused by the mouse driver ...

		sar	cx,1
		add	cx,1

;		add	cx,1
;		sar	cx,1

		cmp	cx,BoxMinWidth
		jge	TestMaxWidth
		mov	cx,BoxMinWidth
		jmp	TestDepth
TestMaxWidth:	cmp	cx,BoxMaxWidth
		jle	TestDepth
		mov	cx,BoxMaxWidth

TestDepth:	mov	dx,MouseY
		sub	dx,BoxY
		add	dx,1
		cmp	dx,BoxMinDepth
		jge	TestMaxDepth
		mov	dx,BoxMinDepth
		jmp	SetStep
TestMaxDepth:	cmp	dx,BoxMaxDepth
		jle	SetStep
		mov	dx,BoxMaxDepth

;* change box size in increments of BoxXStep and BoxYStep

SetStep:	mov	ax,dx
		xor	dx,dx
		mov	bx,BoxYStep
		cmp	bx,0
		je	SkipYDivide
		div	bx
		mul	bx
SkipYDivide:	xchg	ax,cx
	    	xor	dx,dx
		mov	bx,BoxXStep
		cmp	bx,0
		je	SkipXDivide
		div	bx
		mul	bx
SkipXDivide:	mov	dx,ax
		xchg	cx,dx	
		
TestStep:	cmp	cx,BoxWidth
		jne	BoxHasChanged
	      	cmp	dx,BoxDepth
		je	UpdateBoxExit	;MouseInCorner

BoxHasChanged:	push	cx
		push	dx
		call	XorBox
		pop	dx
		pop	cx
		mov	BoxWidth,cx
		mov	BoxDepth,dx
		call	XorBox

UpdateBoxExit:	ret

UpdateBox	ENDP

;----------------------------------------------------------------------------

;* ResetBox - reset box parameters
;*
;* pass: nothing
;* ret : BoxX, BoxY
;*       MouseX, MouseY
;* kill: assume all

ResetBox	PROC	NEAR

		mov	cx,0
		mov	dx,0

		mov	BoxX,cx
		mov	BoxY,dx

		call	SetMousePos

		ret

ResetBox	ENDP

;----------------------------------------------------------------------------

;* FrameWait - wait for n frames (control program speed)
;*
;* pass: Frames
;* ret : Frames = 0
;* kill: ax, flags

FrameWait	PROC	NEAR

WaitLoop:	mov	ax,Frames
		cmp	ax,5
	 	jb	WaitLoop
		mov	Frames,0
		ret

FrameWait	ENDP

;----------------------------------------------------------------------------

;* Beep - make beep noise
;* 
;* pass: nothing
;* ret : nothing
;* kill: assume all

Beep		PROC	NEAR

		mov	ah,2
		mov	dl,BEL
		int	021h
		ret

Beep		ENDP

CODE		ENDS

;============================================================================

		END

