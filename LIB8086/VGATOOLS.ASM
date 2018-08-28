;****************************************************************************
;*
;* VGATOOLS.ASM
;*
;* 22.02.1991 - KJB
;* 01.04.1992 - KJB - Modified to work with NEWMOUSE.ASM.
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	VGAPaletteTool

		EXTRN	BlockFill:FAR
		EXTRN	Print$:FAR
		EXTRN	SetMouseLimits:FAR
		EXTRN	SetMousePos:FAR
		EXTRN	ReadMouse:FAR
		EXTRN	CreateFile:FAR
		EXTRN	FWrite$:FAR
		EXTRN	CloseFile:FAR
		EXTRN	DecWord$:FAR
		EXTRN	HexByte$:FAR

		EXTRN	VGA_CalcAddr:NEAR

		EXTRN	WorkScrPtr:WORD
		EXTRN	RealScrPtr:WORD
		EXTRN	MouseXMin:WORD
		EXTRN	MouseXMax:WORD
		EXTRN	MouseYMin:WORD
		EXTRN	MouseYMax:WORD
		EXTRN	MouseX:WORD
		EXTRN	MouseY:WORD
		EXTRN	_MouseX:WORD
		EXTRN	_MouseY:WORD
		EXTRN	Frames:WORD

		EXTRN	Key:BYTE

;============================================================================

		INCLUDE	KEYS.INC
		INCLUDE	PRINT.INC
		INCLUDE	USEFUL.INC
		INCLUDE	PALETTES.INC
		INCLUDE	VGA_DRVR.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

ColNum		DB	0
Red		DB	0
Green		DB	0
Blue		DB	0

ColMask		DB     	0001b
		DB	0010b
		DB	0100b
		DB	1000b

TAB		EQU	9
CR		EQU	13
LF		EQU	10

Data$		DB	TAB,TAB,"DB",TAB,"0rrh, 0ggh, 0bbh",TAB,";   ",CR,LF,'$'

Dec$		DB	"nnnnn",0

File$		DB	"RGB.DAT",0

Select$		LABEL	BYTE
		P_CHAR2
		P_OVER0
		PD_ATTR	0ffh,000h,0ffh,000h,0cch,0eeh,00ch,00eh
		PD_XY	0,1
		DB	"SELECT PALETTE COLOUR - MOVE MOUSE TO SELECT COLOUR "
		DB	"THEN CLICK BUTTON (F=FIND)"
		P_END

Adjust$		LABEL	BYTE
		P_CHAR2
		P_OVER0
		PD_ATTR	0ffh,000h,0ffh,000h,0cch,0eeh,00ch,00eh
		PD_XY	0,1
		P_DECAT	002h
		DB	"R:"
		PV_DECB	Red
		DB	" G:"
		PV_DECB	Green
		DB	" B:"
		PV_DECB	Blue
		DB	" - R/G/B AND +/- TO ADJUST COLOUR THEN (C)ONT, (S)AVE OR (Q)UIT "
		P_DECAT	000h
		P_END

		EVEN
		
DATA		ENDS

;============================================================================

GCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:GCODE
		ASSUME DS:DATA

;* VGAPaletteTool - allow user to adjust VGA palette and store RGB data to disk
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

VGAPaletteTool	PROC	FAR

;* test if tool is required (ALP-P)

		mov	al,Key[K_ALT]
		and	al,Key[K_P]
		_JZ	ExitTool

;* write to real screen (swap work screen <-> real screen)

		mov	ax,WorkScrPtr
		xchg	ax,RealScrPtr
		mov	WorkScrPtr,ax

;* store mouse limits

		push	MouseXMin
		push	MouseXMax
		push	MouseYMin
		push	MouseYMax

		mov	MouseXMin,0
		mov	MouseXMax,639
		mov	MouseYMin,0
		mov	MouseYMax,399

		call	SetMouseLimits

;* clear info bar and print select message

Continue:	mov	al,COL_YELLOW
		mov	bl,0
		mov	bh,6
		mov	cx,0
		mov	dx,319
		call	BlockFill

		mov	si,OFFSET Select$
		call	Print$

		call	SelectColour  	;select colour to adjust
		jc	Quit		;escape requested ->

;* adjust colour loop
		
AdjustLoop:	mov	ax,10
		call	FrameWait

		mov	si,OFFSET Adjust$
		call	Print$

		call	AdjustColour

		mov	al,Key[K_C]
		test	al,al		;continue?
		jnz	Continue	;yes ->

		mov	al,Key[K_ESC]
		or	al,Key[K_Q]	;quit?
		jnz	Quit		;yes ->
		
		mov	al,Key[K_S]
		test	al,al		;save?
		jz	AdjustLoop	;no ->

		call	SaveRGBData	;save RGB data to disk

;* restore real screen and work screen pointers

Quit:		mov	ax,WorkScrPtr
		xchg	ax,RealScrPtr
		mov	WorkScrPtr,ax

;* restore mouse limits

		pop	MouseYMax
		pop	MouseYMin
		pop	MouseXMax
		pop	MouseXMin

		call	SetMouseLimits

ExitTool:	ret

VGAPaletteTool	ENDP

;----------------------------------------------------------------------------

;* SelectColour - allow user to move xored pixel around screen to select colour
;*
;* pass: nothing
;* ret : ColNum = colour register number
;*       Red    = red DAC value
;*       Green  = green DAC value
;*       Blue   = blue DAC value
;*       cf     = 0: ok
;*       cf     = 1: escape requested
;* kill: assume all

SelectColour	PROC	NEAR

		mov	cx,MouseX  	;xor initial pixel
		mov	bx,MouseY
		mov	_MouseX,cx
		mov	_MouseY,bx
		call	XorPixel
		mov	ColNum,al

SelectLoop:	mov	ax,5
		call	FrameWait
		
		mov	al,Key[K_ESC]
		test	al,al		;escape requested?
		jnz	Escape		;yes ->

		mov	al,Key[K_F]
		test	al,al		;find cursor?
		jz	SkipCentre	;no ->

	 	mov	cx,MouseX	;restore current pixel
		mov	bx,MouseY
		call	XorPixel

		mov	cx,160*2	;move cursor to screen centre
		mov	bx,100*2
		call	SetMousePos

		jmp	SkipUpdate

SkipCentre:	call	ReadMouse

		or	al,ah		;mouse button pressed?
		jnz	ExitSelectCol	;yes ->

		mov	ax,MouseX	
		cmp	ax,_MouseX	;has mouse x pos changed?
		jne	MovePixel	;yes ->
		mov	ax,MouseY
		cmp	ax,_MouseY	;has mouse y pos changed?
		je	SelectLoop	;no ->

MovePixel:  	mov	cx,_MouseX	;restore old pixel
		mov	bx,_MouseY
		call	XorPixel

SkipUpdate:	mov	cx,MouseX	;xor new pixel
		mov	bx,MouseY
		call	XorPixel
		mov	ColNum,al

		jmp	SelectLoop

ExitSelectCol:	mov	cx,_MouseX	;restore old pixel
		mov	bx,_MouseY
		call	XorPixel

;* use BIOS to read specified DAC colour register

		mov	al,015h
		mov	ah,010h
		mov	bl,ColNum
		xor	bh,bh
		int	010h

		mov	Red,dh
		mov	Green,ch
		mov	Blue,cl
		
		clc			;cf = 0 = ok
		ret

Escape:		stc			;cf = 1 = escape requested
		ret

SelectColour	ENDP

;----------------------------------------------------------------------------

;* XorPixel - xor screen pixel
;*
;* pass: cx = x
;*       bx = y
;* ret : al = original colour number
;* kill: assume all (except al)
;*       VGA_SEQ_MAPMSK
;*	 VGA_CTRL_RDMAP

XorPixel	PROC	NEAR

		push	es
		mov	ax,WorkScrPtr
		mov	es,ax

;* convert mouse position to screen position

		shr	cx,1		;/2
		adc	cx,0
		cmp	cx,319
		jbe	@F
		mov	cx,319

@@:		shr	bx,1		;/2
		adc	bx,0
		cmp	bx,199
		jbe	@F
		mov	bx,199

@@:		call	VGA_CalcAddr	;es:di -> screen
		and	cx,3
		mov 	si,cx 
		mov 	ah,ColMask[si]

		SETREGV	VGA_CTRL,VGA_CTRL_RDMAP,cl

		SETREGV	VGA_SEQ,VGA_SEQ_MAPMSK,ah
	
		mov	al,es:[di]
		xor	es:[di],BYTE PTR 0ffh

		pop	es
       		ret

XorPixel	ENDP

;----------------------------------------------------------------------------

;* AdjustColour - adjust selected colour
;*
;* pass: ColNum
;*       Key[]
;* ret : Red
;*       Green
;*       Blue
;* kill: assume all

AdjustColour	PROC	NEAR

		xor	ah,ah
		mov	al,Key[K_PLUS]
		or	al,Key[K_PAD_PLUS]
		add	ah,al
		mov	al,Key[K_MINUS]
		or	al,Key[K_PAD_MINUS]
		sub	ah,al
		
		mov	al,Key[K_R]
		test	al,al		;modify red?
		jz	SkipRed		;no ->
		add	Red,ah
		and	Red,03fh	;keep in range 0 .. 63

SkipRed:	mov	al,Key[K_G]
		test	al,al		;modify green?
		jz	SkipGreen	;no ->
		add	Green,ah
		and	Green,03fh	;keep in range 0 .. 63

SkipGreen:	mov	al,Key[K_B]
		test	al,al		;modify blue?
		jz	SkipBlue	;no ->
		add	Blue,ah
		and	Blue,03fh	;keep in range 0 .. 63

;* use BIOS to update specified DAC colour register

SkipBlue:	mov	al,010h
		mov	ah,010h
		mov	bl,ColNum
		xor	bh,bh
		mov	dh,Red
		mov	ch,Green
		mov	cl,Blue
		int	010h

AdjustExit:	ret

AdjustColour	ENDP

;----------------------------------------------------------------------------

;* SaveRGBData - save RGB data to disk
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

SaveRGBData	PROC	NEAR

		mov	dx,OFFSET File$
		call	CreateFile
		jc	ExitSave	;disk error ->

		mov	ax,0		;start with colour 0
		mov	cx,256		;save all 256 colours

SaveLoop:	push	ax
		push	cx

;* convert colour number to decimal and put into Data$

		push	ax		;store colour number

		mov	di,OFFSET Dec$
		call	DecWord$

		mov	cx,3
		mov	si,OFFSET Dec$+2
		mov	di,OFFSET Data$+23
		rep	movsb

		pop	bx		;restore colour number

;* use BIOS to read specified DAC colour register

		mov	al,015h
		mov	ah,010h
		int	010h

;* put DAC values into Data$

		mov	al,dh		;red
		mov	di,OFFSET Data$+6
		call	HexByte$
				
		mov	al,ch		;green
		mov	di,OFFSET Data$+12
		call	HexByte$

		mov	al,cl		;blue
		mov	di,OFFSET Data$+18
		call	HexByte$
	
		mov	di,OFFSET Data$
		call	FWrite$
		jc	ExitSave	;disk error ->

		pop	cx		;next colour
		pop	ax
		inc	ax
		loop	SaveLoop

		call	CloseFile

ExitSave:	ret

SaveRGBData	ENDP

;----------------------------------------------------------------------------

;* FrameWait - delay
;*
;* pass: ax = delay (1/100th sec)
;*	 Frames
;* ret : Frames = 0
;* kill: ax, flags

FrameWait	PROC	NEAR

		cmp	Frames,ax
		jb	FrameWait
		xor	ax,ax
		mov	Frames,ax
		ret

FrameWait	ENDP
	
GCODE		ENDS

;============================================================================

		END

