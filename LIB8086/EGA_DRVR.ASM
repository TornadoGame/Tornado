;****************************************************************************
;*
;* EGA_DRVR.ASM
;*
;* Screen dependant routines for Enhanced Graphics Adapter.
;*
;* The V16 graphics mode has been incorporated into this driver.
;*
;* 05.06.1989 - KJB
;* 29.08.1991 - KJB - EGA_PrtC3 added.
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	EGA_VMode
		PUBLIC	EGA_DLoad
		PUBLIC	EGA_SetPx
		PUBLIC	EGA_Line
		PUBLIC	EGA_VLine
		PUBLIC	EGA_HLine
		PUBLIC	EGA_PFill
		PUBLIC	EGA_MFill
		PUBLIC	EGA_SFill
		PUBLIC	EGA_PrtC1
		PUBLIC	EGA_PrtC2
		PUBLIC	EGA_PrtC3
		PUBLIC	EGA_SSprite
		PUBLIC	EGA_MSprite
		PUBLIC	EGA_BSprite
		PUBLIC	EGA_QSprite
		PUBLIC	EGA_InitSS
		PUBLIC	EGA_InitMS
		PUBLIC	EGA_InitQS
		PUBLIC	EGA_BFill
		PUBLIC	EGA_SaveMouse
		PUBLIC	EGA_LoadMouse
		PUBLIC	EGA_SaveScreen
		PUBLIC	EGA_LoadScreen
		PUBLIC	EGA_UncompPic
		PUBLIC	EGA_HFill

		PUBLIC	EGA_CalcAddr
		PUBLIC	AllocateSpace
		PUBLIC	CreateEGAData
		PUBLIC	MoveEGAData

		PUBLIC	EGAFreeSpace

		PUBLIC	EGA_LINEADD	

		EXTRN	SetUpEGATable:FAR
		EXTRN	ConvTANToEGA:FAR
		EXTRN	RunLenDecode:FAR
		EXTRN	ResetMouse:FAR

		EXTRN	SeperateData:NEAR

		EXTRN	WorkScrPtr:WORD
		EXTRN	RealScrPtr:WORD
		EXTRN	ScreenMode:WORD
		EXTRN	ScreenPage:WORD
		EXTRN	FlipMode:WORD
		EXTRN	MinY:WORD
		EXTRN	MaxY:WORD
		EXTRN	LhsX:WORD
		EXTRN	RhsX:WORD
		EXTRN	PrtLn:WORD
		EXTRN	PrtCl:WORD
		EXTRN	CharSetPtr1:WORD
		EXTRN	CharSetPtr2:WORD
		EXTRN	CharSetPtr3:WORD
		EXTRN	ClipXMin:WORD
		EXTRN	ClipXMax:WORD
		EXTRN	ClipYMin:WORD
		EXTRN	ClipYMax:WORD
		EXTRN	SSpriteList:WORD
		EXTRN	MSpriteList:WORD
		EXTRN	QSpriteList:WORD
		EXTRN	HrznXMin:WORD
		EXTRN	HrznXMax:WORD

		EXTRN	PixelCol:BYTE
		EXTRN	LineCol:BYTE
		EXTRN	FillCol:BYTE
		EXTRN	HrznLhsCol:BYTE
		EXTRN	HrznRhsCol:BYTE
		EXTRN	ForeCol:BYTE
		EXTRN	BackCol:BYTE
		EXTRN	PrintOver:BYTE
		EXTRN	SSpriteID:BYTE
		EXTRN	MSpriteID:BYTE
		EXTRN	QSpriteID:BYTE
		EXTRN	WorkScreen:BYTE
		EXTRN	CopyScreen:BYTE
		EXTRN	MouseHouse:BYTE
		EXTRN	SetPaletteFlag:BYTE
		EXTRN	V16_RGB_Data:BYTE

		EXTRN	V16:ABS

;============================================================================

		INCLUDE	EGA_DRVR.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

EGA_LINEADD	EQU	40		;40 bytes / line

EGAScrStart	DW	0,02000h	;page 0, page 1 offsets from 0

DLoadMode	DW	DLoadFlip
		DW	DLoadCopy

PaletteRegs	DB	000h,001h,002h,003h,004h,005h,006h,007h
		DB	008h,009h,00ah,00bh,00ch,00dh,00eh,00fh
		DB	000h

		EVEN

ColMask		DB     	10000000b
		DB	01000000b
		DB	00100000b
		DB	00010000b
		DB     	00001000b
		DB	00000100b
		DB	00000010b
		DB	00000001b

OctTable	DW	Oct2		;Dx > 0, Dy > Dx
		DW	Oct1		;Dx > 0, Dx > Dy
		DW	Oct7		;Dx < 0, Dy > Dx
		DW	Oct8		;Dx < 0, Dx > Dy

LMask		LABEL	BYTE
		DB	11111111b
		DB	01111111b
		DB	00111111b
		DB	00011111b
		DB	00001111b
		DB	00000111b
		DB	00000011b
		DB	00000001b

RMask		LABEL	BYTE
		DB	10000000b
		DB	11000000b
		DB	11100000b
		DB	11110000b
		DB	11111000b
		DB	11111100b
		DB	11111110b
		DB	11111111b

PrtC2Mask	DB	0f0h		;displacement 0 - 3
		DB	00fh		;displacement 4 - 7

;* hatched polyfill data

EGA_COL_BASE	EQU	EGA_LINEADD*200	

HatchCol	DB	0,0
HatchPtr	DW	0

EVEN_HATCH	EQU	01010101b
ODD_HATCH	EQU	10101010b

EHatchLMask	LABEL	BYTE
		DB	11111111b AND EVEN_HATCH
		DB	01111111b AND EVEN_HATCH
		DB	00111111b AND EVEN_HATCH
		DB	00011111b AND EVEN_HATCH
		DB	00001111b AND EVEN_HATCH
		DB	00000111b AND EVEN_HATCH
		DB	00000011b AND EVEN_HATCH
		DB	00000001b AND EVEN_HATCH

EHatchRMask  	LABEL	BYTE
		DB	10000000b AND EVEN_HATCH
		DB	11000000b AND EVEN_HATCH
		DB	11100000b AND EVEN_HATCH
		DB	11110000b AND EVEN_HATCH
		DB	11111000b AND EVEN_HATCH
		DB	11111100b AND EVEN_HATCH
		DB	11111110b AND EVEN_HATCH
		DB	11111111b AND EVEN_HATCH

OHatchLMask	LABEL	BYTE		
		DB	11111111b AND ODD_HATCH
		DB	01111111b AND ODD_HATCH
		DB	00111111b AND ODD_HATCH
		DB	00011111b AND ODD_HATCH
		DB	00001111b AND ODD_HATCH
		DB	00000111b AND ODD_HATCH
		DB	00000011b AND ODD_HATCH
		DB	00000001b AND ODD_HATCH

OHatchRMask  	LABEL	BYTE
		DB	10000000b AND ODD_HATCH
		DB	11000000b AND ODD_HATCH
		DB	11100000b AND ODD_HATCH
		DB	11110000b AND ODD_HATCH
		DB	11111000b AND ODD_HATCH
		DB	11111100b AND ODD_HATCH
		DB	11111110b AND ODD_HATCH
		DB	11111111b AND ODD_HATCH

EVEN_SMOKE	EQU	10001000b
ODD_SMOKE	EQU	00100010b

ESmokeLMask	LABEL	BYTE
		DB	11111111b AND EVEN_SMOKE
		DB	01111111b AND EVEN_SMOKE
		DB	00111111b AND EVEN_SMOKE
		DB	00011111b AND EVEN_SMOKE
		DB	00001111b AND EVEN_SMOKE
		DB	00000111b AND EVEN_SMOKE
		DB	00000011b AND EVEN_SMOKE
		DB	00000001b AND EVEN_SMOKE

ESmokeRMask  	LABEL	BYTE
		DB	10000000b AND EVEN_SMOKE
		DB	11000000b AND EVEN_SMOKE
		DB	11100000b AND EVEN_SMOKE
		DB	11110000b AND EVEN_SMOKE
		DB	11111000b AND EVEN_SMOKE
		DB	11111100b AND EVEN_SMOKE
		DB	11111110b AND EVEN_SMOKE
		DB	11111111b AND EVEN_SMOKE

OSmokeLMask	LABEL	BYTE		
		DB	11111111b AND ODD_SMOKE
		DB	01111111b AND ODD_SMOKE
		DB	00111111b AND ODD_SMOKE
		DB	00011111b AND ODD_SMOKE
		DB	00001111b AND ODD_SMOKE
		DB	00000111b AND ODD_SMOKE
		DB	00000011b AND ODD_SMOKE
		DB	00000001b AND ODD_SMOKE

OSmokeRMask  	LABEL	BYTE
		DB	10000000b AND ODD_SMOKE
		DB	11000000b AND ODD_SMOKE
		DB	11100000b AND ODD_SMOKE
		DB	11110000b AND ODD_SMOKE
		DB	11111000b AND ODD_SMOKE
		DB	11111100b AND ODD_SMOKE
		DB	11111110b AND ODD_SMOKE
		DB	11111111b AND ODD_SMOKE

;* horizon fill masks

HrznMask	DB	11111111b
		DB	01111111b
		DB	00111111b
		DB	00011111b
		DB	00001111b
		DB	00000111b
		DB	00000011b
		DB	00000001b

;* AllocateSpace data tables

MAX_SPACE	EQU	02000h

EGAFreeSpace	DW	0		;page 0
		DW	0		;page 1
		DW	MAX_SPACE	;page 2
		DW	MAX_SPACE	;page 3
		DW	MAX_SPACE	;page 4
		DW	MAX_SPACE	;page 5
		DW	MAX_SPACE	;page 6
		DW	MAX_SPACE	;page 7

BasePage	DW	EGA_PAGE_0	
		DW	EGA_PAGE_1	
		DW	EGA_PAGE_2	
		DW	EGA_PAGE_3	
		DW	EGA_PAGE_4	
		DW	EGA_PAGE_5	
		DW	EGA_PAGE_6	
		DW	EGA_PAGE_7	

DATA		ENDS

;============================================================================

WSDATA		SEGMENT PARA PUBLIC 'DATA'

WSDATA		ENDS

;============================================================================

GCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:GCODE
		ASSUME DS:DATA

;* EGA_VMode - set video mode
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all
;*       EGA_CTRL_BITMSK
;*       EGA_CTRL_SETRES
;*
;* note: Reset mouse immediately after setting video mode (see MOUSE.ASM).

EGA_VMode	PROC	FAR

		mov	ah,0 		;service 0, set video mode
		mov	al,00dh		;320 * 200, 16 colour
		int	010h		;BIOS

		call	ResetMouse

		mov	ax,EGA_PAGE_1
		mov	WorkScrPtr,ax
		mov	ax,EGA_PAGE_0
		mov	RealScrPtr,ax

		mov	ScreenPage,2

		mov	SetPaletteFlag,1

		SETREGV	EGA_SEQ,EGA_SEQ_MAPMSK,00fh

		SETREGV	EGA_CTRL,EGA_CTRL_ENABLE,00fh

;* set up TAN to EGA convert table

		call	SetUpEGATable	

;* set up hatched polyfill colours in non-visible screen memory

		push	es
		
		SETREGV	EGA_CTRL,EGA_CTRL_BITMSK,0ffh

		SLCTREG	EGA_CTRL,EGA_CTRL_SETRES

		mov	ax,RealScrPtr
		mov	es,ax

		xor	al,al
		mov	cx,16
		mov	di,EGA_COL_BASE
		
SetHatchLp1:	out	dx,al
		stosb
		inc	al
		loop	SetHatchLp1
		
		mov	ax,WorkScrPtr
		mov	es,ax

		xor	al,al
		mov	cx,16
		mov	di,EGA_COL_BASE
		
SetHatchLp2:	out	dx,al
		stosb
		inc	al
		loop	SetHatchLp2

		pop	es

		ret

EGA_VMode	ENDP

;----------------------------------------------------------------------------

;* EGA_DLoad - download work screen to real screen
;*
;* pass: WorkScrPtr
;*       RealScrPtr
;*       FlipMode
;* ret : nothing
;* kill: assume all
;* note: FlipMode = 0 then flip work / real screens (game mode)
;*       FlipMode = 2 then copy work screen to real screen (menu mode)

EGA_DLoad	PROC	FAR

;* load VGA palette registers if requested (for V16 mode only)

		mov	ax,ScreenMode
		cmp	ax,V16		;16 colour VGA?
		jne	SkipPalette	;no ->

		mov	al,SetPaletteFlag
		test	al,al		;load VGA palette registers?
		jz	SkipPalette	;no ->

		mov	ah,010h		;set palette reg
		mov	al,002h		;update palette regs
		mov	dx,OFFSET PaletteRegs

		int	010h		;video BIOS function

		push	es

		mov	ah,010h		;set palette regs
		mov	al,012h		;update block of colour regs
		mov	bx,0		;start col 0
		mov	cx,16		;update 16 cols

		mov	dx,SEG V16_RGB_Data
		mov	es,dx
		mov	dx,OFFSET V16_RGB_Data

		int	010h		;video BIOS function

		pop	es

		mov	SetPaletteFlag,0

SkipPalette:	mov	bx,FlipMode
		jmp	DLoadMode[bx]
	
DLoadFlip:	cli

		mov	ax,RealScrPtr
		xchg	ax,WorkScrPtr
		mov	RealScrPtr,ax

		mov	bx,ScreenPage
		mov	ax,EGAScrStart[bx]
		xchg	ax,bx
		xor	ax,10b		;0 <-> 2
		mov	ScreenPage,ax

		mov	dx,EGA_CRTC

		mov	al,EGA_CRTC_HI
		mov	ah,bh
		out	dx,ax
		jmp 	$+2		;wait a few cycles
		
	   	mov	al,EGA_CRTC_LO
		mov	ah,bl
		out	dx,ax
		jmp	$+2		;wait a few cycles

		sti

;* start address is loaded at the start of v trace, so wait for v trace

VLoop1:	    	mov	dx,EGA_CRT_STAT ;make sure v trace is not occuring
	    	in	al,dx
	    	test	al,EGA_VSYNC
	    	jnz	VLoop1
	
VLoop2:		mov	dx,EGA_CRT_STAT	;wait for vertical retrace to occur
		in	al,dx  	
		test 	al,EGA_VSYNC
	     	jz 	VLoop2

		ret

DLoadCopy:	push	ds
		push	es

		SETREGV	EGA_CTRL,EGA_CTRL_MODE,0001b

		mov	ax,RealScrPtr
		mov	es,ax
		mov	ax,WorkScrPtr
		mov	ds,ax

		xor	si,si
		xor	di,di
		
		mov	cx,EGA_LINEADD*200

		rep	movsb
		
		SETREGV	EGA_CTRL,EGA_CTRL_MODE,0000b

		pop	es
		pop	ds
		ret

EGA_DLoad	ENDP

;----------------------------------------------------------------------------

;* EGA_SetPx - set pixel
;*
;* pass: bl = y (0 - 199)
;*       cx = x (0 - 319)
;*       PixelCol
;* ret : nothing
;* kill: ax, dx, si, di, flags
;*       EGA_CTRL_SETRES
;*       EGA_CTRL_BITMSK

EGA_SetPx	PROC	FAR
		
		push	es
		mov	ax,WorkScrPtr
		mov	es,ax

		SETREGV	EGA_CTRL,EGA_CTRL_SETRES,PixelCol

		SLCTREG	EGA_CTRL,EGA_CTRL_BITMSK
	
		call	EGA_CalcAddr	;es:di -> screen
		mov 	si,cx 
		and 	si,7

		mov 	al,ColMask[si]
		out	dx,al		;set bit mask
		or	es:[di],al	;set pixel via r/w

		pop	es
		ret		 

EGA_SetPx	ENDP

;----------------------------------------------------------------------------

;* EGA_Line - draw line between two points
;*
;* pass: cx, bl = x1, y1
;*       dx, bh = x2, y2
;*       LineCol
;* ret : nothing
;* kill: assume all
;*       EGA_CTRL_SETRES
;*       EGA_CTRL_BITMSK
;*
;* mods: Oct1 and Oct8 routines optimized (03.01.1991 - KJB).

EGA_Line	PROC	FAR

		push	es
		mov	ax,WorkScrPtr
		mov	es,ax

;* test for vertical and horizontal lines (use faster routines)

		cmp	cx,dx		;x1 = x2?
		je	VLineLink	;yes, draw vertical line ->
		cmp	bl,bh		;y1 = y2?
		je	HLineLink	;yes, draw horizontal line ->

		jb	NoSwap		;y1 < y2 ->
		xchg	bl,bh
		xchg	cx,dx
NoSwap:		sub	bh,bl		;bh = abs(Dy)
		mov	di,bx
		and	di,000ffh	;di = y1
		xchg	bl,bh
		xor	bh,bh		;bx = abs(Dy)
		xor	si,si		;jmp offset 0
		sub	dx,cx		;dx = Dx
		rcl	si,1		;jmp offset = 1 if Dx < 0
		mov	ax,dx
		cwd
		xor	ax,dx
		sub	ax,dx
		mov	dx,ax		;dx = abs(Dx)
		cmp	bx,dx		;abs(Dx) > abs(Dy)?
		rcl	si,1		;jmp offset * 2 + 1 if abs(Dx) > abs(Dy)
		shl	si,1		;jmp offset = 0, 2, 4, or 6	

;* bx = Dy
;* cx = x1
;* dx = Dx
;* di = y1
;* si = octant jump table offset

		shl	di,1		;*2
		shl	di,1		;*4
		shl	di,1		;*8
		mov	ax,di
		shl	di,1		;*16
		shl	di,1		;*32
		add	di,ax		;y * 40

		mov	bp,bx
		mov	bx,cx
		and	bx,7
		mov	ah,ColMask[bx]
		mov	bx,bp

		shr	cx,1		;/2
		shr	cx,1		;/4
		shr	cx,1		;/8
		add	di,cx

		mov	bp,dx

		SETREGV	EGA_CTRL,EGA_CTRL_SETRES,LineCol

		SLCTREG	EGA_CTRL,EGA_CTRL_BITMSK
	
		mov	al,ah

		jmp	OctTable[si]	;jump to octant routine

VLineLink:	jmp	IntoVLine	;jump into VLine routine ->
HLineLink:	jmp	IntoHLine	;jump into HLine routine ->

;* al = mask
;* bx = Dy
;* dx = addresses EGA_CTRL_BITMSK 
;* di = screen ptr
;* bp = Dx

;* octant 1: Dx > 0, Dx > Dy

Oct1:		mov	cx,bp
		inc	cx		;count = Dx + 1

		mov	si,bp
		shr	si,1		;error = Dx / 2
		adc	si,0		;1/2 bit round up

		xor	ah,ah		;clear x mask

Oct1Lp:		or	ah,al		;set x

		dec	cx		;count = count - 1
		jz	Oct1End		;count = 0 ->

		ror	al,1		;x = x + 1
		jc	Oct1Ov		;overflow into next byte ->

Oct1Ok:		sub	si,bx		;error = error - Dy
		ja	Oct1Lp		;if error > 0 then no y change ->

		xchg	al,ah		;write accumulated x mask to screen
		out	dx,al
		or	es:[di],al
		xor	al,al
		xchg	al,ah

		add	si,bp		;error = error + Dx
		add	di,EGA_LINEADD	;y = y + 1
		jmp	Oct1Lp

Oct1End:	mov	al,ah		;write accumulated x mask to screen
		out	dx,al
		or	es:[di],al

		pop	es
		ret

Oct1Ov:		xchg	al,ah		;write accumulated x mask to screen
		out	dx,al
		or	es:[di],al
		xor	al,al
		xchg	al,ah
		inc	di
		jmp	Oct1Ok

;* octant 2: Dx > 0, Dy > Dx

Oct2:		mov	cx,bx
		inc	cx		;count = Dy + 1	

		mov	si,bx
		shr	si,1		;error = Dy / 2
		adc	si,0		;1/2 bit round up

Oct2Lp:		out	dx,al		;plot x, y
		or	es:[di],al
		
		dec	cx		;count = count - 1
		jz	Oct2End		;exit if count = 0

		add	di,EGA_LINEADD	;y = y + 1
		sub	si,bp		;error = error - Dx
		ja	Oct2Lp		;if error > 0 then no x change ->
		
		add	si,bx		;error = error + Dy
		ror	al,1		;x = x + 1
		adc	di,0		;inc di if mask wrap around
		jmp	Oct2Lp

Oct2End:        pop	es
		ret

;* octant 7: Dx < 0, Dy > Dx

Oct7:		mov	cx,bx
		inc	cx		;count = Dy + 1	

		mov	si,bx
		shr	si,1		;error = Dy / 2
		adc	si,0		;1/2 bit round up

Oct7Lp:		out	dx,al		;plot x, y
		or	es:[di],al
		
		dec	cx		;count = count - 1
		jz	Oct7End		;exit if count = 0

		add	di,EGA_LINEADD	;y = y + 1
		sub	si,bp		;error = error - Dx
		ja	Oct7Lp		;if error > 0 then no x change ->
		
		add	si,bx		;error = error + Dy
		rol	al,1		;x = x - 1
		sbb	di,0		;dec di if mask wrap around
		jmp	Oct7Lp

Oct7End:	pop	es
		ret

;* octant 8: Dx < 0, Dx > Dy
 
Oct8:		mov	cx,bp
		inc	cx		;count = Dx + 1

		mov	si,bp
		shr	si,1		;error = Dx / 2
		adc	si,0		;1/2 bit round up

		xor	ah,ah		;clear x mask

Oct8Lp:		or	ah,al		;set x

		dec	cx		;count = count - 1
		jz	Oct8End		;count = 0 ->

		rol	al,1		;x = x - 1
		jc	Oct8Ov		;overflow into next byte ->

Oct8Ok:		sub	si,bx		;error = error - Dy
		ja	Oct8Lp		;if error > 0 then no y change ->

		xchg	al,ah		;write accumulated x mask to screen
		out	dx,al
		or	es:[di],al
		xor	al,al
		xchg	al,ah

		add	si,bp		;error = error + Dx
		add	di,EGA_LINEADD	;y = y + 1
		jmp	Oct8Lp

Oct8End:	mov	al,ah		;write accumulated x mask to screen
		out	dx,al
		or	es:[di],al

		pop	es
		ret

Oct8Ov:		xchg	al,ah		;write accumulated x mask to screen
		out	dx,al
		or	es:[di],al
		xor	al,al
		xchg	al,ah
		dec	di
		jmp	Oct8Ok

EGA_Line	ENDP

;----------------------------------------------------------------------------

;* EGA_VLine - draw vertical line between two points
;*
;* pass: bl = y1
;*       bh = y2
;*       cx = x1
;*       LineCol
;* ret : nothing
;* kill: assume all
;*       EGA_CTRL_SETRES
;*       EGA_CTRL_BITMSK

EGA_VLine	PROC	FAR

		push	es
		mov	ax,WorkScrPtr
		mov	es,ax

IntoVLine:	cmp	bl,bh		;y1 <= y2?
		jbe	VLineYOk	;yes, co-ords ok ->
		xchg	bl,bh
VLineYOk:	mov	di,bx
		and	di,000ffh	;di = y1
		
		sub	bh,bl		;bh = y2 - y1
		mov	bl,bh
		xor	bh,bh
		inc	bx		;count = (y2 - y1) + 1
		mov	bp,bx

		SETREGV	EGA_CTRL,EGA_CTRL_SETRES,LineCol

		mov	bx,cx
		and	bx,7

		SETREGV	EGA_CTRL,EGA_CTRL_BITMSK,ColMask[bx]

		shl	di,1		;*2
		shl	di,1		;*4
		shl	di,1		;*8
		mov	ax,di
		shl	di,1		;*16
		shl	di,1		;*32
		add	di,ax		;y * 40

		shr	cx,1		;/2
		shr	cx,1		;/4
		shr	cx,1		;/8
		add	di,cx		;y * 40 + x / 8

		mov	cx,bp
		mov	bp,EGA_LINEADD

VLineLoop:	or	es:[di],al
		add	di,bp
		loop	VLineLoop

		pop	es
		ret

EGA_VLine	ENDP

;----------------------------------------------------------------------------

;* EGA_HLine - draw horizontal line between two points
;*
;* pass: bl = y1
;*       cx = x1
;*       dx = x2
;*       LineCol
;* ret : nothing
;* kill: assume all
;*       EGA_CTRL_SETRES
;*       EGA_CTRL_BITMSK

EGA_HLine	PROC	FAR

		push	es
		mov	ax,WorkScrPtr
		mov	es,ax

IntoHLine:	cmp	cx,dx		;x1 <= x2?
		jbe	HLineXOk	;yes, co-ords ok ->
		xchg	cx,dx
HLineXOk:   	mov	bp,dx

		SETREGV	EGA_CTRL,EGA_CTRL_SETRES,LineCol

		SLCTREG	EGA_CTRL,EGA_CTRL_BITMSK
		
		mov	di,bx
		and	di,000ffh
		shl	di,1		;*2
		shl	di,1		;*4
		shl	di,1		;*8
		mov	ax,di
		shl	di,1		;*16
		shl	di,1		;*32
		add	di,ax		;y * 40

		mov	ax,cx
		shr	ax,1		;/2
		shr	ax,1		;/4
		shr	ax,1		;/8
		add	di,ax		;y * 40 + x / 8

		mov	bx,cx
		and	bx,7		;lhs byte disp

		mov	si,bp
		and	si,7		;rhs byte disp

		sub	cx,bp
		neg	cx
		add	cx,bx		;trim off lh side
		sub	cx,8
		sub	cx,si		;trim off rh side

		sar	cx,1		;8 pixels / byte
		sar	cx,1
		sar	cx,1		;cx = number of whole bytes to fill

		js	ShortHLine	;cx < 0 = short line ->

		mov	al,LMask[bx]	;mask in lh line end
		out	dx,al
		or	es:[di],al
		inc	di

		mov	al,0ffh		;fill line middle
		out	dx,al
		rep	stosb

		mov	al,RMask[si]	;mask in rh line end
		out	dx,al
		or	es:[di],al

HLineExit:	pop	es
		ret

;* short horizontal line draw (exception)

ShortHLine:	mov	al,LMask[bx]
		and	al,RMask[si]
		out	dx,al
		or	es:[di],al
		jmp	HLineExit

EGA_HLine	ENDP

;----------------------------------------------------------------------------

;* EGA_PFill - fill polygon from table
;*
;* pass: MinY, MaxY
;*       LhsX, RhsX
;*       FillCol
;* ret : nothing
;* kill: ax, bx, cx, dx, di, bp, flags
;*       EGA_CTRL_SETRES
;*       EGA_CTRL_BITMSK

EGA_PFill	PROC	FAR

		push	si
		push	es
		mov	ax,WorkScrPtr
		mov	es,ax

;* test if normal fill or hatched fill is required

		mov	al,FillCol
		mov	ah,al
		shr	al,1
		shr	al,1
		shr	al,1
		shr	al,1		;al = hi nibble colour
		and	ah,00fh		;ah = lo nibble colour
		cmp	al,ah		;are colours the same?
		je	ContPolyFill	;yes, normal fill ->

		jmp	HatchFill

ContPolyFill:	SETREGV	EGA_CTRL,EGA_CTRL_SETRES,FillCol

		SLCTREG	EGA_CTRL,EGA_CTRL_BITMSK
	
		mov	bx,MinY
		mov	cx,MaxY
		sub	cx,bx
		inc	cx		;cx = number of lines
		shl	bx,1		;bx = x table index
		mov	di,bx
		shl	di,1		;*4
		shl	di,1		;*8
		mov	ax,di
		shl	di,1		;*16
		shl	di,1		;*32
		add	di,ax		;*40

;* bx = x table index
;* cx = number of lines
;* dx = addresses EGA_CTRL_BITMSK 
;* di -> screen (x = 0)

NextFillLine:	push	bx
		push	cx

		mov	ax,RhsX[bx]
		mov	bp,ax
		mov	ax,LhsX[bx]
		mov	cx,ax

		mov	bx,cx
		and	bx,7		;lhs byte disp

		mov	si,bp
		and	si,7		;rhs byte disp

		sub	cx,bp
		ja	FixPoints	;error lh x > rh x ->
PointsFixed:	neg	cx
		add	cx,bx		;trim off lh side
		sub	cx,8
		sub	cx,si		;trim off rh side

		mov	bp,di		;save screen address

		shr	ax,1		;/2
		shr	ax,1		;/4
		shr	ax,1		;/8
		add	di,ax		;y + x / 8

		sar	cx,1		;8 pixels / byte
		sar	cx,1
		sar	cx,1		;cx = number of whole bytes to fill

		js	ShortLine	;cx < 0 = short line ->

		mov	al,LMask[bx]	;mask in lh line end
		out	dx,al
		or	es:[di],al
		inc	di

		mov	al,0ffh		;fill line middle
		out	dx,al
		rep	stosb

		mov	al,RMask[si]	;mask in rh line end
		out	dx,al
		or	es:[di],al

FillEndLoop:	mov	di,bp		;restore screen address
		pop	cx
		pop	bx
		add	bx,2		;next table index
		add	di,EGA_LINEADD	;y = y + 1
		loop	NextFillLine
		
		pop	es
		pop	si
		ret

;* lh x > rh x error condition (exception)

FixPoints:	mov	cx,ax		;cx = lh x
		xchg	cx,bp		;swap lh x, rh x
		mov	ax,cx		;ax = lh x
		xchg	bx,si		;swap lh disp, rh disp
		sub	cx,bp
		jmp	PointsFixed

;* short line draw (exception)

ShortLine:	mov	al,LMask[bx]
		and	al,RMask[si]
		out	dx,al
		or	es:[di],al
		jmp	FillEndLoop

;* cross-hatched polyfill

HatchFill:	mov	HatchCol,al
		xor	ah,ah
		add	ax,EGA_COL_BASE
		mov	HatchPtr,ax

		SETREGV	EGA_CTRL,EGA_CTRL_MODE,0010b

		SLCTREG	EGA_CTRL,EGA_CTRL_BITMSK

		mov	bx,MinY
		mov	cx,MaxY
		sub	cx,bx
		inc	cx		;cx = number of lines
		shl	bx,1		;bx = x table index
		mov	di,bx
		shl	di,1		;*4
		shl	di,1		;*8
		mov	ax,di
		shl	di,1		;*16
		shl	di,1		;*32
		add	di,ax		;*40

		test	bx,0010b	;start on even or odd hatch?
		jz	NextEHatchLine	;even hatch ->
		jmp	NextOHatchLine	;odd hatch ->

;* bx = x table index
;* cx = number of lines
;* dx = addresses EGA_CTRL_BITMSK 
;* di -> screen (x = 0)

NextEHatchLine:	push	bx
		push	cx

		mov	ax,RhsX[bx]
		mov	bp,ax
		mov	ax,LhsX[bx]
		mov	cx,ax

		mov	bx,cx
		and	bx,7		;lhs byte disp

		mov	si,bp
		and	si,7		;rhs byte disp

		sub	cx,bp
		ja	FixEHatchPts	;error lh x > rh x ->
EHatchPtsFixed:	neg	cx
		add	cx,bx		;trim off lh side
		sub	cx,8
		sub	cx,si		;trim off rh side

		mov	bp,di		;preserve di

		shr	ax,1		;/2
		shr	ax,1		;/4
		shr	ax,1		;/8
		add	di,ax		;y + x / 8

		sar	cx,1		;8 pixels / byte
		sar	cx,1
		sar	cx,1		;cx = number of whole bytes to fill

		js	ShortEHatchLine	;cx < 0 = short line ->

		mov	al,EHatchLMask[bx]
		out	dx,al
		mov	al,es:[di]
		mov	al,FillCol
		mov	es:[di],al
		
		mov	al,OHatchLMask[bx]
		out	dx,al
		mov	al,es:[di]
		mov	al,HatchCol
		mov	es:[di],al
		
		inc	di

		mov	ax,HatchPtr
		mov	bx,ax
		mov	al,es:[bx]

		mov	al,EVEN_HATCH
		out	dx,al
		mov	al,FillCol
		rep	stosb

		mov	al,EHatchRMask[si]
		out	dx,al
		mov	al,es:[di]
		mov	al,FillCol
		mov	es:[di],al
		
		mov	al,OHatchRMask[si]
		out	dx,al
		mov	al,es:[di]
		mov	al,HatchCol
		mov	es:[di],al
	
EHatchEndLoop:	mov	di,bp
		pop	cx
		pop	bx
		add	bx,2		;next table index
		add	di,EGA_LINEADD	;y = y + 1

		dec	cx
		jnz	NextOHatchLine
		jmp	HatchFillExit

;* lh x > rh x error condition (exception)

FixEHatchPts:	mov	cx,ax		;cx = lh x
		xchg	cx,bp		;swap lh x, rh x
		mov	ax,cx		;ax = lh x
		xchg	bx,si		;swap lh disp, rh disp
		sub	cx,bp
		jmp	EHatchPtsFixed

;* short line draw (exception)

ShortEHatchLine:mov	al,EHatchLMask[bx]
		and	al,EHatchRMask[si]
		out	dx,al
		mov	al,es:[di]
		mov	al,FillCol
		mov	es:[di],al

		mov	al,OHatchLMask[bx]
		and	al,OHatchRMask[si]
		out	dx,al
		mov	al,es:[di]
		mov	al,HatchCol
		mov	es:[di],al

		jmp	EHatchEndLoop

;* bx = x table index
;* cx = number of lines
;* dx = addresses EGA_CTRL_BITMSK 
;* di -> screen (x = 0)

NextOHatchLine:	push	bx
		push	cx

		mov	ax,RhsX[bx]
		mov	bp,ax
		mov	ax,LhsX[bx]
		mov	cx,ax

		mov	bx,cx
		and	bx,7		;lhs byte disp

		mov	si,bp
		and	si,7		;rhs byte disp

		sub	cx,bp
		ja	FixOHatchPts	;error lh x > rh x ->
OHatchPtsFixed:	neg	cx
		add	cx,bx		;trim off lh side
		sub	cx,8
		sub	cx,si		;trim off rh side

		mov	bp,di		;preserve di

		shr	ax,1		;/2
		shr	ax,1		;/4
		shr	ax,1		;/8
		add	di,ax		;y + x / 8

		sar	cx,1		;8 pixels / byte
		sar	cx,1
		sar	cx,1		;cx = number of whole bytes to fill

		js	ShortOHatchLine	;cx < 0 = short line ->

		mov	al,OHatchLMask[bx]
		out	dx,al
		mov	al,es:[di]
		mov	al,FillCol
		mov	es:[di],al
		
		mov	al,EHatchLMask[bx]
		out	dx,al
		mov	al,es:[di]
		mov	al,HatchCol
		mov	es:[di],al
		
		inc	di

		mov	ax,HatchPtr
		mov	bx,ax
		mov	al,es:[bx]

		mov	al,ODD_HATCH
		out	dx,al
		mov	al,FillCol
		rep	stosb

		mov	al,OHatchRMask[si]
		out	dx,al
		mov	al,es:[di]
		mov	al,FillCol
		mov	es:[di],al
		
		mov	al,EHatchRMask[si]
		out	dx,al
		mov	al,es:[di]
		mov	al,HatchCol
		mov	es:[di],al
	
OHatchEndLoop:	mov	di,bp
		pop	cx
		pop	bx
		add	bx,2		;next table index
		add	di,EGA_LINEADD	;y = y + 1

		dec	cx
		jz	HatchFillExit
		jmp	NextEHatchLine

;* lh x > rh x error condition (exception)

FixOHatchPts:	mov	cx,ax		;cx = lh x
		xchg	cx,bp		;swap lh x, rh x
		mov	ax,cx		;ax = lh x
		xchg	bx,si		;swap lh disp, rh disp
		sub	cx,bp
		jmp	OHatchPtsFixed

;* short line draw (exception)

ShortOHatchLine:mov	al,OHatchLMask[bx]
		and	al,OHatchRMask[si]
		out	dx,al
		mov	al,es:[di]
		mov	al,FillCol
		mov	es:[di],al

		mov	al,EHatchLMask[bx]
		and	al,EHatchRMask[si]
		out	dx,al
		mov	al,es:[di]
		mov	al,HatchCol
		mov	es:[di],al

		jmp	OHatchEndLoop

HatchFillExit:	SETREGV	EGA_CTRL,EGA_CTRL_MODE,0000b
		
		pop	es
		pop	si
		ret

EGA_PFill	ENDP

;----------------------------------------------------------------------------

;* EGA_MFill - fill "transparent" polygon from table
;*
;* pass: MinY, MaxY
;*       LhsX, RhsX
;*       FillCol
;* ret : nothing
;* kill: ax, bx, cx, dx, di, bp, flags
;*       EGA_CTRL_SETRES
;*       EGA_CTRL_BITMSK

EGA_MFill	PROC	FAR

		push	si
		push	es
		mov	ax,WorkScrPtr
		mov	es,ax

		SETREGV	EGA_CTRL,EGA_CTRL_SETRES,FillCol

		SLCTREG	EGA_CTRL,EGA_CTRL_BITMSK

		mov	bx,MinY
		mov	cx,MaxY
		sub	cx,bx
		inc	cx		;cx = number of lines
		shl	bx,1		;bx = x table index
		mov	di,bx
		shl	di,1		;*4
		shl	di,1		;*8
		mov	ax,di
		shl	di,1		;*16
		shl	di,1		;*32
		add	di,ax		;*40

		test	bx,0010b	;start on even or odd hatch?
		jz	NextEMeshLine	;even hatch ->
		jmp	NextOMeshLine	;odd hatch ->

;* bx = x table index
;* cx = number of lines
;* dx = addresses EGA_CTRL_BITMSK 
;* di -> screen (x = 0)

NextEMeshLine:	push	bx
		push	cx
		push	di

		mov	ax,RhsX[bx]
		mov	bp,ax
		mov	ax,LhsX[bx]
		mov	cx,ax

		mov	bx,cx
		and	bx,7		;lhs byte disp

		mov	si,bp
		and	si,7		;rhs byte disp

		sub	cx,bp
		ja	FixEMeshPts	;error lh x > rh x ->
EMeshPtsFixed:	neg	cx
		add	cx,bx		;trim off lh side
		sub	cx,8
		sub	cx,si		;trim off rh side

		shr	ax,1		;/2
		shr	ax,1		;/4
		shr	ax,1		;/8
		add	di,ax		;y + x / 8

		sar	cx,1		;8 pixels / byte
		sar	cx,1
		sar	cx,1		;cx = number of whole bytes to fill

		js	ShortEMeshLine	;cx < 0 = short line ->

		mov	al,EHatchLMask[bx]
		out	dx,al
		or	es:[di],al
		
		inc	di

		mov	al,EVEN_HATCH
		out	dx,al
		
		mov	ax,es
		mov	ds,ax

		mov	bp,si
		mov	si,di
		rep	movsb
		mov	si,bp

		mov	ax,DATA
		mov	ds,ax

		mov	al,EHatchRMask[si]
		out	dx,al
		or	es:[di],al
		
EMeshEndLoop:	pop	di
		pop	cx
		pop	bx
		add	bx,2		;next table index
		add	di,EGA_LINEADD	;y = y + 1

		dec	cx
		jnz	NextOMeshLine
		jmp	MeshFillExit

;* lh x > rh x error condition (exception)

FixEMeshPts:	mov	cx,ax		;cx = lh x
		xchg	cx,bp		;swap lh x, rh x
		mov	ax,cx		;ax = lh x
		xchg	bx,si		;swap lh disp, rh disp
		sub	cx,bp
		jmp	EMeshPtsFixed

;* short line draw (exception)

ShortEMeshLine:	mov	al,EHatchLMask[bx]
		and	al,EHatchRMask[si]
		out	dx,al
		or	es:[di],al

		jmp	EMeshEndLoop

;* bx = x table index
;* cx = number of lines
;* dx = addresses EGA_CTRL_BITMSK 
;* di -> screen (x = 0)

NextOMeshLine:	push	bx
		push	cx
		push	di

		mov	ax,RhsX[bx]
		mov	bp,ax
		mov	ax,LhsX[bx]
		mov	cx,ax

		mov	bx,cx
		and	bx,7		;lhs byte disp

		mov	si,bp
		and	si,7		;rhs byte disp

		sub	cx,bp
		ja	FixOMeshPts	;error lh x > rh x ->
OMeshPtsFixed:	neg	cx
		add	cx,bx		;trim off lh side
		sub	cx,8
		sub	cx,si		;trim off rh side

		shr	ax,1		;/2
		shr	ax,1		;/4
		shr	ax,1		;/8
		add	di,ax		;y + x / 8

		sar	cx,1		;8 pixels / byte
		sar	cx,1
		sar	cx,1		;cx = number of whole bytes to fill

		js	ShortOMeshLine	;cx < 0 = short line ->

		mov	al,OHatchLMask[bx]
		out	dx,al
		or	es:[di],al
		
		inc	di

		mov	al,ODD_HATCH
		out	dx,al
		
		mov	ax,es
		mov	ds,ax

		mov	bp,si
		mov	si,di
		rep	movsb
		mov	si,bp

		mov	ax,DATA
		mov	ds,ax

		mov	al,OHatchRMask[si]
		out	dx,al
		or	es:[di],al
		
OMeshEndLoop:	pop	di
		pop	cx
		pop	bx
		add	bx,2		;next table index
		add	di,EGA_LINEADD	;y = y + 1

		dec	cx
		jz	MeshFillExit
		jmp	NextEMeshLine

;* lh x > rh x error condition (exception)

FixOMeshPts:	mov	cx,ax		;cx = lh x
		xchg	cx,bp		;swap lh x, rh x
		mov	ax,cx		;ax = lh x
		xchg	bx,si		;swap lh disp, rh disp
		sub	cx,bp
		jmp	OMeshPtsFixed

;* short line draw (exception)

ShortOMeshLine:	mov	al,OHatchLMask[bx]
		and	al,OHatchRMask[si]
		out	dx,al
		or	es:[di],al

		jmp	OMeshEndLoop

MeshFillExit:	pop	es
		pop	si
		ret

EGA_MFill	ENDP

;----------------------------------------------------------------------------

;* EGA_SFill - fill "smoke" polygon from table
;*
;* pass: MinY, MaxY
;*       LhsX, RhsX
;*       FillCol
;* ret : nothing
;* kill: ax, bx, cx, dx, di, bp, flags
;*       EGA_CTRL_SETRES
;*       EGA_CTRL_BITMSK

EGA_SFill	PROC	FAR

		push	si
		push	es
		mov	ax,WorkScrPtr
		mov	es,ax

		SETREGV	EGA_CTRL,EGA_CTRL_SETRES,FillCol

		SLCTREG	EGA_CTRL,EGA_CTRL_BITMSK

		mov	bx,MinY
		mov	cx,MaxY
		sub	cx,bx
		inc	cx		;cx = number of lines
		shl	bx,1		;bx = x table index
		mov	di,bx
		shl	di,1		;*4
		shl	di,1		;*8
		mov	ax,di
		shl	di,1		;*16
		shl	di,1		;*32
		add	di,ax		;*40

		test	bx,0010b	;start on even or odd hatch?
		jz	NextESmokeLine	;even hatch ->
		jmp	NextOSmokeLine	;odd hatch ->

;* bx = x table index
;* cx = number of lines
;* dx = addresses EGA_CTRL_BITMSK 
;* di -> screen (x = 0)

NextESmokeLine:	push	bx
		push	cx
		push	di

		mov	ax,RhsX[bx]
		mov	bp,ax
		mov	ax,LhsX[bx]
		mov	cx,ax

		mov	bx,cx
		and	bx,7		;lhs byte disp

		mov	si,bp
		and	si,7		;rhs byte disp

		sub	cx,bp
		ja	FixESmokePts	;error lh x > rh x ->
ESmokePtsFixed:	neg	cx
		add	cx,bx		;trim off lh side
		sub	cx,8
		sub	cx,si		;trim off rh side

		shr	ax,1		;/2
		shr	ax,1		;/4
		shr	ax,1		;/8
		add	di,ax		;y + x / 8

		sar	cx,1		;8 pixels / byte
		sar	cx,1
		sar	cx,1		;cx = number of whole bytes to fill

		js	ShortESmokeLine	;cx < 0 = short line ->

		mov	al,ESmokeLMask[bx]
		out	dx,al
		or	es:[di],al
		
		inc	di

		mov	al,EVEN_SMOKE
		out	dx,al
		
		mov	ax,es
		mov	ds,ax

		mov	bp,si
		mov	si,di
		rep	movsb
		mov	si,bp

		mov	ax,DATA
		mov	ds,ax

		mov	al,ESmokeRMask[si]
		out	dx,al
		or	es:[di],al
		
ESmokeEndLoop:	pop	di
		pop	cx
		pop	bx
		add	bx,2		;next table index
		add	di,EGA_LINEADD	;y = y + 1

		dec	cx
		jnz	NextOSmokeLine
		jmp	SmokeFillExit

;* lh x > rh x error condition (exception)

FixESmokePts:	mov	cx,ax		;cx = lh x
		xchg	cx,bp		;swap lh x, rh x
		mov	ax,cx		;ax = lh x
		xchg	bx,si		;swap lh disp, rh disp
		sub	cx,bp
		jmp	ESmokePtsFixed

;* short line draw (exception)

ShortESmokeLine:mov	al,ESmokeLMask[bx]
		and	al,ESmokeRMask[si]
		out	dx,al
		or	es:[di],al

		jmp	ESmokeEndLoop

;* bx = x table index
;* cx = number of lines
;* dx = addresses EGA_CTRL_BITMSK 
;* di -> screen (x = 0)

NextOSmokeLine:	push	bx
		push	cx
		push	di

		mov	ax,RhsX[bx]
		mov	bp,ax
		mov	ax,LhsX[bx]
		mov	cx,ax

		mov	bx,cx
		and	bx,7		;lhs byte disp

		mov	si,bp
		and	si,7		;rhs byte disp

		sub	cx,bp
		ja	FixOSmokePts	;error lh x > rh x ->
OSmokePtsFixed:	neg	cx
		add	cx,bx		;trim off lh side
		sub	cx,8
		sub	cx,si		;trim off rh side

		shr	ax,1		;/2
		shr	ax,1		;/4
		shr	ax,1		;/8
		add	di,ax		;y + x / 8

		sar	cx,1		;8 pixels / byte
		sar	cx,1
		sar	cx,1		;cx = number of whole bytes to fill

		js	ShortOSmokeLine	;cx < 0 = short line ->

		mov	al,OSmokeLMask[bx]
		out	dx,al
		or	es:[di],al
		
		inc	di

		mov	al,ODD_SMOKE
		out	dx,al
		
		mov	ax,es
		mov	ds,ax

		mov	bp,si
		mov	si,di
		rep	movsb
		mov	si,bp

		mov	ax,DATA
		mov	ds,ax

		mov	al,OSmokeRMask[si]
		out	dx,al
		or	es:[di],al
		
OSmokeEndLoop:	pop	di
		pop	cx
		pop	bx
		add	bx,2		;next table index
		add	di,EGA_LINEADD	;y = y + 1

		dec	cx
		jz	SmokeFillExit
		jmp	NextESmokeLine

;* lh x > rh x error condition (exception)

FixOSmokePts:	mov	cx,ax		;cx = lh x
		xchg	cx,bp		;swap lh x, rh x
		mov	ax,cx		;ax = lh x
		xchg	bx,si		;swap lh disp, rh disp
		sub	cx,bp
		jmp	OSmokePtsFixed

;* short line draw (exception)

ShortOSmokeLine:mov	al,OSmokeLMask[bx]
		and	al,OSmokeRMask[si]
		out	dx,al
		or	es:[di],al

		jmp	OSmokeEndLoop

SmokeFillExit:	pop	es
		pop	si
		ret

EGA_SFill	ENDP

;----------------------------------------------------------------------------

;* EGA_CalcAddr - calculate screen address
;*
;* pass: bl = y (0 - 199)
;*       cx = x (0 - 319)
;* ret : di = screen address = y * 40 + x / 8
;* kill: ax, flags

EGA_CalcAddr	PROC	NEAR

		mov	al,bl
		xor	ah,ah
		shl	ax,1		;*2
		shl	ax,1		;*4
		shl	ax,1		;*8
		mov	di,ax
		shl	ax,1   		;*16
		shl	ax,1		;*32
		add	di,ax		;*40
		mov	ax,cx
		shr	ax,1		;/2
		shr	ax,1		;/4
		shr	ax,1		;/8
		add	di,ax
		ret

EGA_CalcAddr	ENDP

;----------------------------------------------------------------------------

;* EGA_PrtC1 - print character type 1 (7 by 9)
;*
;* pass: al = ASCII code
;*       PrtLn
;*       PrtCl
;*       ForeCol
;*       BackCol
;*       PrintOver
;*       CharSetPtr1
;* ret : PrtCl modified
;* kill: bp, flags
;*       EGA_CTRL_SETRES
;*       EGA_CTRL_BITMSK
;* note: PrtCl is rounded down to 4 pixel steps (effectively 80 columns).
;*       No checks are made for PrtLn and PrtCl being off screen.

EGA_PrtC1	PROC	FAR

		push	ax
		push	bx
		push	cx
		push	dx
		push	si
		push	di
		push	es

		sub	al,' '		;character set starts with space
		xor	ah,ah
		mov	si,ax
		shl	ax,1
		shl	ax,1
		shl	ax,1
		add	si,ax		;si = char * 9
		add	si,CharSetPtr1	;si -> char pattern data

		mov	bl,BYTE PTR PrtLn
		mov	cx,PrtCl
		call	EGA_CalcAddr 	;di -> screen

		mov	ax,WorkScrPtr
		mov	es,ax		

		mov	ah,PrintOver
		mov	cx,9
		mov	bp,EGA_LINEADD

		test	PrtCl,0100b	;does character need to be shifted?
		jnz	S_PrtC1Loop	;yes ->

;* main print loop (unshifted)

PrtC1Loop:	SETREGV	EGA_CTRL,EGA_CTRL_SETRES,ForeCol

		SLCTREG	EGA_CTRL,EGA_CTRL_BITMSK

		lodsb			;al = char pattern data
		out	dx,al		;set foreground pixels to update
		or	es:[di],al	;read to / write from latches

		test	ah,ah		;print over?
		jnz	PrtC1Over	;yes ->

		not	al		;get background pixels		
		out	dx,al		;set background pixels to update
		
		SETREGV	EGA_CTRL,EGA_CTRL_SETRES,BackCol

		or	es:[di],al	;read to / write from latches

PrtC1Over:	add	di,bp		;next line
		loop	PrtC1Loop

		jmp	PrtC1Exit

;* main print loop (shifted)

S_PrtC1Loop:	SETREGV	EGA_CTRL,EGA_CTRL_SETRES,ForeCol

		SLCTREG	EGA_CTRL,EGA_CTRL_BITMSK

		lodsb			;al = char pattern data
		mov	bh,al
		xor	bl,bl
		ror	bx,1
		ror	bx,1
		ror	bx,1
		ror	bx,1 		;bx = shifted char pattern

		mov	al,bh
		out	dx,al		;set foreground pixels to update
		or	es:[di],al	;read to / write from latches
		mov	al,bl
		out	dx,al		;set foreground pixels to update
		or	es:[di+1],al	;read to / write from latches

		test	ah,ah		;print over?
		jnz	S_PrtC1Over	;yes ->

		SETREGV	EGA_CTRL,EGA_CTRL_SETRES,BackCol

		SLCTREG	EGA_CTRL,EGA_CTRL_BITMSK

		not	bx		;get background pixels
		and	bx,00ff0h	;clear unwanted pixels
		
		mov	al,bh
		out	dx,al		;set background pixels to update
		or	es:[di],al	;read to / write from latches
		mov	al,bl
		out	dx,al		;set background pixels to update
		or	es:[di+1],al	;read to / write from latches

S_PrtC1Over:	add	di,bp		;next line
		loop	S_PrtC1Loop

PrtC1Exit:	add	PrtCl,8		;next column

		pop	es
		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax

		ret

EGA_PrtC1	ENDP

;----------------------------------------------------------------------------

;* EGA_PrtC2 - print character type 2 (3 by 5)
;*
;* pass: al = ASCII code
;*       PrtLn
;*       PrtCl
;*       ForeCol
;*       BackCol
;*	 PrintOver
;*       CharSetPtr2
;* ret : PrtCl modified
;* kill: bp, flags
;*       EGA_CTRL_SETRES
;*       EGA_CTRL_BITMSK
;* note: PrtCl is rounded down to 4 pixel steps (effectively 80 columns).
;*       No checks are made for PrtLn and PrtCl being off screen.
;*       Optimized for speed (inline code).

EGA_PrtC2	PROC	FAR

		push	ax
		push	bx
		push	cx
		push	dx
		push	si
		push	di
		push	es

		sub	al,' '		;character set starts with space
		xor	ah,ah
		mov	si,ax
		shl	ax,1
		shl	ax,1
		add	si,ax		;si = char * 5
		add	si,CharSetPtr2	;si -> char pattern data

		mov	bl,BYTE PTR PrtLn
		mov	cx,PrtCl
		call	EGA_CalcAddr 	;di -> screen

		mov	ax,WorkScrPtr
		mov	es,ax		

		mov	bx,cx		;column
		and	bx,0100b	;select mask wrt displacement
		shr	bx,1
		shr	bx,1
		mov	ah,PrtC2Mask[bx];ah = mask

		mov	bp,EGA_LINEADD

		mov	al,PrintOver
		test	al,al	     	;print over?
		jz	EGA_PrtC2Norm	;no ->

;* inline print

		SETREGV	EGA_CTRL,EGA_CTRL_SETRES,ForeCol

		SLCTREG	EGA_CTRL,EGA_CTRL_BITMSK

		REPT	5

		lodsb			;al = char pattern data
		and	al,ah
		out	dx,al		;set foreground pixels to update
		or	es:[di],al	;read to / write from latches

		add	di,bp		;next line

		ENDM

		jmp	EGA_PrtC2Com

;* inline print

EGA_PrtC2Norm:	REPT	5

		SETREGV	EGA_CTRL,EGA_CTRL_SETRES,ForeCol

		SLCTREG	EGA_CTRL,EGA_CTRL_BITMSK

		lodsb			;al = char pattern data
		and	al,ah
		out	dx,al		;set foreground pixels to update
		or	es:[di],al	;read to / write from latches

		not	al   		;get background pixels
		and	al,ah		;clear unwanted pixels
		out	dx,al		;set background pixels to update

		SETREGV	EGA_CTRL,EGA_CTRL_SETRES,BackCol

		or	es:[di],al	;read to / write from latches

		add	di,bp		;next line

		ENDM

EGA_PrtC2Com:	add	PrtCl,4		;next column

		pop	es
		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax

		ret

EGA_PrtC2	ENDP

;----------------------------------------------------------------------------

;* EGA_PrtC3 - print character type 3 (5 by 9)
;*
;* pass: al = ASCII code
;*       PrtLn
;*       PrtCl
;*       ForeCol
;*       BackCol
;*       PrintOver
;*       CharSetPtr3
;* ret : PrtCl modified
;* kill: bp, flags
;*       EGA_CTRL_SETRES
;*       EGA_CTRL_BITMSK
;* note: PrtCl is rounded down to 2 pixel steps.
;*       No checks are made for PrtLn and PrtCl being off screen.

EGA_PrtC3	PROC	FAR

		push	ax
		push	bx
		push	cx
		push	dx
		push	si
		push	di
		push	es

		sub	al,' '		;character set starts with space
		xor	ah,ah
		mov	si,ax
		shl	ax,1
		shl	ax,1
		shl	ax,1
		add	si,ax		;si = char * 9
		add	si,CharSetPtr3	;si -> char pattern data

		mov	bl,BYTE PTR PrtLn
		mov	cx,PrtCl
		call	EGA_CalcAddr 	;di -> screen

		mov	ax,WorkScrPtr
		mov	es,ax		

		mov	cx,9
		mov	bp,EGA_LINEADD

;* ah flags: b0 = 1 = print over
;*           b1 = 1 = 2 pixel offset

		mov	ah,BYTE PTR PrtCl
		and	ah,0010b
		or	ah,PrintOver

		test	PrtCl,0100b	;does character need to be shifted?
		jnz	S_PrtC3Loop	;yes ->

;* main print loop (unshifted)

PrtC3Loop:	SETREGV	EGA_CTRL,EGA_CTRL_SETRES,ForeCol

		SLCTREG	EGA_CTRL,EGA_CTRL_BITMSK

		lodsb			;al = char pattern data

		test	ah,0010b	;2 pixel offset?
		jz	@F		;no ->
		shr	al,1
		shr	al,1
		
@@:		out	dx,al		;set foreground pixels to update
		or	es:[di],al	;read to / write from latches

		test	ah,0001b	;print over?
		jnz	PrtC3Over	;yes ->

		not	al		;get background pixels		

;* set background mask wrt 0 or 2 pixel offset

		test	ah,0010b	;2 pixel offset?
		jz	@F		;no ->
		and	al,00111111b
		jmp	PrtC3MaskOk
@@:		and	al,11111100b

PrtC3MaskOk:	out	dx,al		;set background pixels to update
		
		SETREGV	EGA_CTRL,EGA_CTRL_SETRES,BackCol

		or	es:[di],al	;read to / write from latches

PrtC3Over:	add	di,bp		;next line
		loop	PrtC3Loop

		jmp	PrtC3Exit

;* main print loop (shifted)

S_PrtC3Loop:	SETREGV	EGA_CTRL,EGA_CTRL_SETRES,ForeCol

		SLCTREG	EGA_CTRL,EGA_CTRL_BITMSK

		lodsb			;al = char pattern data

		test	ah,0010b	;2 pixel offset?
		jz	@F		;no ->
		shr	al,1
		shr	al,1
		
@@:		mov	bh,al
		xor	bl,bl
		ror	bx,1
		ror	bx,1
		ror	bx,1
		ror	bx,1 		;bx = shifted char pattern

		mov	al,bh
		out	dx,al		;set foreground pixels to update
		or	es:[di],al	;read to / write from latches
		mov	al,bl
		out	dx,al		;set foreground pixels to update
		or	es:[di+1],al	;read to / write from latches

		test	ah,0001b	;print over?
		jnz	S_PrtC3Over	;yes ->

		SETREGV	EGA_CTRL,EGA_CTRL_SETRES,BackCol

		SLCTREG	EGA_CTRL,EGA_CTRL_BITMSK

		not	bx		;get background pixels

;* set background mask wrt 0 or 2 pixel offset

		test	ah,0010b	;2 pixel offset?
		jz	@F		;no ->
		and	bx,003f0h	;clear unwanted pixels
		jmp	S_PrtC3MaskOk
@@:		and	bx,00fc0h	;clear unwanted pixels
		
S_PrtC3MaskOk:	mov	al,bh
		out	dx,al		;set background pixels to update
		or	es:[di],al	;read to / write from latches
		mov	al,bl
		out	dx,al		;set background pixels to update
		or	es:[di+1],al	;read to / write from latches

S_PrtC3Over:	add	di,bp		;next line
		loop	S_PrtC3Loop

PrtC3Exit:	add	PrtCl,6		;next column

		pop	es
		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax

		ret

EGA_PrtC3	ENDP

;----------------------------------------------------------------------------

;* EGA_SSprite - shifted sprite
;*
;* pass: si -> logical sprite data (x, y, ptr)
;* ret : cf = 0 = sprite not visible
;*       cf = 1 = sprite visible
;* kill: ax, bx, cx, dx, si, di, bp, flags
;*       EGA_CTRL_SETRES
;*       EGA_CTRL_RDMAP
;*       EGA_CTRL_BITMSK
;* note: x co-ord is rounded to even pixel

SSpriteOut:	pop	ds
		pop	ax
		pop	ax
		pop	ax
		clc			;exception - sprite not visible
		jmp	SSpriteExit

EGA_SSprite	PROC	FAR

		push	ds
		push	es

;* fetch logical data

		lodsw	
		mov	bp,ax		;x
		lodsw
		mov	di,ax		;y
		lodsw
		mov	si,ax		;ptr

		mov	ax,WorkScrPtr
		mov	es,ax
		mov	ax,SEG SSpriteID
		mov	ds,ax

		ASSUME	DS:SEG SSpriteID

;* fetch ptr to physical data from list

		mov	ax,[si]
		mov	si,ax

;* fetch physical data

		lodsw
		mov	cx,ax		;width (bytes)
		lodsw
		mov	dx,ax		;depth
   		lodsw
		mov	bx,ax		;size
		lodsw	
		add	bp,ax		;x offset
		lodsw
		add	di,ax		;y offset

		add	si,2		;skip mask

		lodsw			;store base page
		push	ax
		lodsw			;store page offset
		push	ax

		push	si		;store mask data start

;* calc x byte offset and point si at shift data wrt x offset

		sar	bp,1
		sar	bp,1
		jnc	NoAdd1
		add	si,bx
NoAdd1:		shl	bx,1
		sar	bp,1
		jnc	NoAdd2
		add	si,bx
NoAdd2:

;* cx = width (bytes)
;* dx = depth
;* bp = x byte offset
;* di = y
;*
;* ds:si -> sprite mask
;*
;* stack: ds
;*        es
;*        page
;*        offset
;* (top): mask data start

;* test if sprite is visible

ContBSprite:	push	ds
		mov	ax,SEG ClipXMin
		mov	ds,ax

		ASSUME	DS:SEG ClipXMin

		mov	ax,di		;y
		cmp	ax,ClipYMax	;y <= y max?
		jg	SSpriteOut	;no ->

		add	ax,dx		;y + depth
		dec	ax		;y + depth - 1
		cmp	ax,ClipYMin	;(y + depth - 1) >= y min?
		jl	SSpriteOut	;no ->

		mov	ax,bp		;x
		cmp	ax,ClipXMax	;x <= x max?
		jg	SSpriteOut	;no ->

		add	ax,cx		;x + width
		dec	ax		;x + width - 1
		cmp	ax,ClipXMin	;(x + width - 1) >= x min?
		jl	SSpriteOut	;no ->

;* if above - reduce depth and modify ptr

AboveClip:	mov	ax,ClipYMin	
		cmp	di,ax		;y < y min?
		jge	BelowClip	;no ->
		mov	bx,ax		;y min
		xchg	ax,di		;di = y = y min, ax = original y
		sub	bx,ax		;y min - y
		sub	dx,bx		;depth = depth - (y min - y)
		mov	ax,cx		;width
		xchg	bx,dx		;preserve depth
		mul	dx		;(y min - y) * width
		xchg	bx,dx		;restore depth
		add	si,ax		;ptr = ptr + (y min - y) * width 

;* if below - reduce depth

BelowClip:	mov	ax,di		;y
		add	ax,dx		;y + depth
		dec 	ax		;y + depth - 1
		cmp	ax,ClipYMax	;(y + depth - 1) > y max
		jle	LeftClip	;no ->
		sub	ax,ClipYMax	;y + depth - 1 - y max
		sub	dx,ax		;depth = depth - (y+depth-1-y max)

;* if left - reduce width, modify ptr and calc add on

LeftClip:	xor	bx,bx		;add on = 0
		mov	ax,ClipXMin	
		cmp	bp,ax		;x < x min?
		jge	RightClip	;no ->
		mov	bx,ax		;x min
		xchg	ax,bp		;bp = x = x min, ax = original x
		sub	bx,ax		;x min - x
		sub	cx,bx		;width = width - (x min - x)
		add	si,bx		;ptr = ptr + (x min - x)

;* if right - reduce width, modfiy add on

RightClip:	mov	ax,bp		;x
		add	ax,cx		;x + width
		dec	ax		;x + width - 1
		cmp	ax,ClipXMax	;(x + width - 1) > x max?
		jle	ClipDone	;no ->
		sub	ax,ClipXMax	;x + width - 1 - x max
		sub	cx,ax		;width = width - (x+width-1-x max)
		add	bx,ax		;modify add on

ClipDone:	pop	ds

;* bx = sprite data add on
;* cx = width (bytes)
;* dx = depth
;* bp = x byte offset
;* di = y
;*
;* ds:si -> sprite mask
;*
;* stack: ds
;*        es
;*        page
;*        offset
;* (top): mask data start

ContMSprite:	shl	di,1		;*2
		shl	di,1		;*4
		shl	di,1		;*8
		mov	ax,di
		shl	di,1		;*16
		shl	di,1		;*32
		add	di,ax		;y * 40
		add	di,bp		;y * 40 + x byte offset

		mov	bp,EGA_LINEADD
		sub	bp,cx		;screen add on

;* calc computed jump for width

		mov	ax,EGA_LINEADD
		sub	ax,cx
		mov	cx,ax
		shl	ax,1		;*2
		shl	ax,1		;*4
		add	ax,cx		;*5
		push	ax		;store width * 5
		add    	ax,cx		;*6
		lea	cx,SSMaskBytes
		add	cx,ax		;cx = computed jump wrt width
		
;* bx = sprite data add on
;* cx = width (computed jump)
;* dx = depth
;* bp = screen address add on
;*
;* ds:si -> sprite mask
;* es:di -> screen
;*
;* stack: ds
;*        es
;*        page
;*        offset
;*        mask data start
;* (top): width * 5

		push	dx
		push	si
		push	di
		mov	ah,dl		;ah = depth

		SETREGV	EGA_CTRL,EGA_CTRL_SETRES,000h
		
		SLCTREG EGA_CTRL,EGA_CTRL_BITMSK

SSMaskLoop:	jmp	cx		;jump wrt width
		
;* this macro generates 6 bytes of code each iteration

SSMaskBytes:	REPT	40

		lodsb
		out	dx,al
		or	es:[di],al
		inc	di
		
		ENDM

		add	si,bx
		add	di,bp
		dec	ah
		jz	SSMaskDone
		jmp	SSMaskLoop
	
SSMaskDone:    	SETREGV	EGA_CTRL,EGA_CTRL_ENABLE,000h

		SETREGV EGA_CTRL,EGA_CTRL_BITMSK,0ffh

		pop	di   		;retrieve data from stack
		pop	si
		pop	dx
		pop	cx		;width * 5
		lea	ax,SSDataBytes
		add	cx,ax
		pop	ax		;mask data start
		xchg	ax,si
		sub	ax,si		;ax = offset into sprite data
		pop	si
		add	si,ax
		pop	ds

		mov	al,0001b
		mov	ah,0000b
		
SSDataLoop1:	push	dx

		push	ax
		xchg	al,ah
		SETREGV	EGA_SEQ,EGA_SEQ_MAPMSK,ah
		pop	ax

		push	ax
		SETREGV EGA_CTRL,EGA_CTRL_RDMAP,ah
		pop	ax

		pop	dx

		push	ax
		push	dx		 
		push	si
		push	di

SSDataLoop2:	jmp	cx		;jump wrt width
		
;* this macro generates 5 bytes of code each iteration

SSDataBytes:	REPT	40

		lodsb
		or	al,es:[di]
		stosb
		
		ENDM

		add	si,bx
		add	di,bp
		dec	dx
		jz	SSDataDone1
		jmp	SSDataLoop2
	
SSDataDone1:	pop	di
		pop	si
		pop	dx
		pop	ax
		shl	al,1
		inc	ah
		test	al,10000b
		jnz	SSDataDone2
		jmp	SSDataLoop1

SSDataDone2:	SETREGV	EGA_CTRL,EGA_CTRL_ENABLE,00fh

		SETREGV	EGA_SEQ,EGA_SEQ_MAPMSK,00fh
		
		stc			;sprite visible

		ASSUME	DS:DATA

SSpriteExit:   	pop	es
		pop	ds
		ret

EGA_SSprite	ENDP

;----------------------------------------------------------------------------

;* EGA_MSprite - masked sprite
;*
;* pass: si -> logical sprite data (x, y, ptr)
;* ret : nothing
;* kill: ax, bx, cx, dx, si, di, bp, flags

EGA_MSprite	PROC	FAR

		push	ds
		push	es

;* fetch logical data

		lodsw	
		mov	bp,ax		;x
		lodsw
		mov	di,ax		;y
		lodsw
		mov	si,ax		;ptr

		mov	ax,WorkScrPtr
		mov	es,ax
		mov	ax,SEG MSpriteID
		mov	ds,ax

		ASSUME	DS:SEG MSpriteID

;* fetch ptr to physical data from list

		mov	ax,[si]
		mov	si,ax

;* fetch physical data

		lodsw
		mov	cx,ax		;width (bytes)
		lodsw
		mov	dx,ax		;depth

		add	si,8		;skip over data not required

		lodsw			;store base page
		push	ax
		lodsw			;store page offset
		push	ax

		push	si		;store mask data start

		sar	bp,1
		sar	bp,1
		sar	bp,1		;x byte offset

		xor	bx,bx		;add on = 0

		jmp	ContMSprite

		ASSUME	DS:DATA

		ret

EGA_MSprite	ENDP

;----------------------------------------------------------------------------

;* EGA_BSprite -  use MSprite data as SSprite
;*
;* pass: si -> logical sprite data (x, y, ptr)
;* ret : cf = 0 = sprite not visible
;*       cf = 1 = sprite visible
;* kill: ax, bx, cx, dx, si, di, bp, flags
;* note: x co-ord is rounded to byte boundary

EGA_BSprite	PROC	FAR

		push	ds
		push	es

;* fetch logical data

		lodsw	
		mov	bp,ax		;x
		lodsw
		mov	di,ax		;y
		lodsw
		mov	si,ax		;ptr

		mov	ax,WorkScrPtr
		mov	es,ax
		mov	ax,SEG MSpriteID
		mov	ds,ax

;* fetch ptr to physical data from list

		mov	ax,[si]
		mov	si,ax

;* fetch physical data

		lodsw
		mov	cx,ax		;width (bytes)
		lodsw
		mov	dx,ax		;depth

		add	si,2		;skip size
      
		lodsw	
		add	bp,ax		;x offset
		lodsw
		add	di,ax		;y offset

		add	si,2		;skip mask

		lodsw			;store base page
		push	ax
		lodsw			;store page offset
		push	ax

		push	si		;store mask data start

;* calc x byte offset

		sar	bp,1
		sar	bp,1
		sar	bp,1

		jmp	ContBSprite

EGA_BSprite	ENDP

;----------------------------------------------------------------------------

;* EGA_QSprite - quick sprite
;*
;* pass: si -> logical sprite data (x, y, ptr)
;* ret : nothing
;* kill: ax, bx, cx, dx, si, di, bp, flags
;* note: Uses EGA write mode 1 for video memory to video memory transfer.

EGA_QSprite	PROC	FAR

		push	ds
		push	es

		SETREGV	EGA_CTRL,EGA_CTRL_MODE,0001b

;* fetch logical data

		lodsw	
		mov	bp,ax		;x
		lodsw
		mov	di,ax		;y
		lodsw
		mov	si,ax		;ptr

		mov	ax,WorkScrPtr
		mov	es,ax
		mov	ax,SEG QSpriteID
		mov	ds,ax

		ASSUME	DS:SEG QSpriteID

;* fetch ptr to physical data from list

		mov	ax,[si]
		mov	si,ax

;* fetch physical data

		lodsw
		mov	bx,ax		;width (bytes)
		lodsw
		mov	dx,ax		;depth
		lodsw
		mov	cx,ax		;EGA page 
		lodsw	
		mov	si,ax		;EGA page offset
	
		mov	ds,cx		;ds:si -> pattern data in EGA card

		sar	bp,1
		sar	bp,1
		sar	bp,1		;x byte offset

		shl	di,1		;*2
		shl	di,1		;*4
		shl	di,1		;*8
		mov	ax,di
		shl	di,1		;*16
		shl	di,1		;*32
		add	di,ax		;y * 40
		add	di,bp		;y * 40 + x byte offset

		mov	bp,EGA_LINEADD
		sub	bp,bx		;screen add on

;* bx = width
;* dx = depth
;* bp = screen address add on
;*
;* ds:si -> sprite data
;* es:di -> screen

QSpriteLoop:	mov	cx,bx
		rep	movsb
		add	di,bp
		dec	dx
		jnz	QSpriteLoop

		ASSUME	DS:DATA
		
		SETREGV	EGA_CTRL,EGA_CTRL_MODE,0000b

		pop	es
		pop	ds
		ret

EGA_QSprite	ENDP

;----------------------------------------------------------------------------

;* EGA_InitSS - initialize shifted sprites
;*
;* pass: SSpriteList
;* ret : nothing
;* kill: ax, bx, cx, dx, si, di, bp, flags
;* note: The WorkScreen is used as a buffer.
;*       Refer to SS_TAN_1.ASM for SSprite data formats.

SS_WIDTH	EQU	0
SS_DEPTH	EQU	2
SS_SIZE		EQU	4
SS_XOFF		EQU	6
SS_YOFF		EQU	8
SS_MASK		EQU	10
SS_BASE		EQU	12
SS_OFFSET	EQU	14
SS_DATA		EQU	16

EGA_InitSS 	PROC	FAR

		push	ds
		push	es

	     	xor	bx,bx
InitSSLoop:	mov	ax,SEG SSpriteList
		mov	ds,ax
		mov	es,ax

		ASSUME	DS:SEG SSpriteList

		mov	si,SSpriteList[bx]	
		cmp	si,-1		;end of list?
		jne	InitSSCont	;no ->
		jmp	InitSSExit

InitSSCont:	push	bx

;* seperate mask / pattern data

		push	si
		mov	al,[si+SS_MASK]	;mask
		mov	cx,[si+SS_SIZE]	;number of bytes
		add	si,SS_DATA	;si -> combined mask / pattern data
		mov	di,si
		add	di,cx		;di -> pattern buffer
		call	SeperateData
		pop	si

;* create EGA data in WorkScreen

		push	si
		mov	al,0
		mov	bx,[si+SS_WIDTH]
		mov	cx,[si+SS_SIZE]
		mov	dx,[si+SS_DEPTH]
		add	si,SS_DATA
		add	si,cx
		call	CreateEGAData
		pop	si

;* allocate space for sprite in EGA card, set base and offset

		push	ax
		call	AllocateSpace
		pop	cx
		jc	InitSSFail	;no space available ->
		mov	[si+SS_BASE],bp
		mov	[si+SS_OFFSET],di

;* copy EGA data in WorkScreen to EGA card

		shr	cx,1
		shr	cx,1		;/4 for size of one shift

		push	cx
		push	si
		push	ds
		push	es
		mov	es,bp
		mov	ax,SEG WorkScreen
		mov	ds,ax
		xor	si,si
		call	MoveEGAData	;shift 0
		call	MoveEGAData	;shift 2
		call	MoveEGAData	;shift 4
		call	MoveEGAData	;shift 6
		pop	es
		pop	ds
		pop	si
		pop	cx

;* calc new EGA width and size

		mov	ax,[si+SS_WIDTH]
		mov	bx,ax		;store TAN width
		mov	dx,ax
		shr	ax,1
		shr	ax,1 		;/4
		and	dx,0011b	;round up if any remainder
		cmp	dx,1		;0 = cf = 1; 1, 2 or 3 = cf = 0
		cmc			;0 = cf = 0; 1, 2 or 3 = cf = 1
		adc	ax,0		;add 1 if remainder
		inc	ax		;add 1 for shift byte
		mov	[si+SS_WIDTH],ax

		mov	[si+SS_SIZE],cx

;* create EGA mask data in WorkScreen

		mov	al,0
		mov	dx,[si+SS_DEPTH]
		add	si,SS_DATA
		push	si
		call	CreateEGAMask
		pop	si

;* copy EGA mask in WorkScreen over TAN mask

		mov	cx,ax
		push	ds
		mov	ax,SEG WorkScreen
		mov	ds,ax
		mov	di,si
		xor	si,si
		rep	movsb
		pop	ds
		
InitSSFail:	pop	bx
		add	bx,2  		;next sprite
		jmp	InitSSLoop

		ASSUME	DS:DATA
		ASSUME	ES:DATA

InitSSExit:	pop	es
		pop	ds

		ret

EGA_InitSS	ENDP

;----------------------------------------------------------------------------

;* EGA_InitMS - initialize masked sprites
;*
;* pass: MSpriteList
;* ret : nothing
;* kill: ax, bx, cx, dx, si, di, bp, flags
;* note: The WorkScreen is used as a buffer.
;*       Refer to MS_TAN_1.ASM for MSprite data formats.

MS_WIDTH	EQU	0
MS_DEPTH	EQU	2
MS_SIZE		EQU	4
MS_XOFF		EQU	6
MS_YOFF		EQU	8
MS_MASK		EQU	10
MS_BASE		EQU	12
MS_OFFSET	EQU	14
MS_DATA		EQU	16

EGA_InitMS	PROC	FAR

		push	ds
		push	es

	     	xor	bx,bx
InitMSLoop:	mov	ax,SEG MSpriteList
		mov	ds,ax
		mov	es,ax

		ASSUME	DS:SEG MSpriteList

		mov	si,MSpriteList[bx]	
		cmp	si,-1		;end of list?
		jne	InitMSCont	;no ->
		jmp	InitMSExit

InitMSCont:	push	bx

;* seperate mask / pattern data

		push	si
		mov	al,[si+MS_MASK]	;mask
		mov	cx,[si+MS_SIZE]	;number of bytes
		add	si,MS_DATA	;si -> combined mask / pattern data
		mov	di,si
		add	di,cx		;di -> pattern buffer
		call	SeperateData
		pop	si

;* create EGA data in WorkScreen

		push	si
		mov	al,1
		mov	bx,[si+MS_WIDTH]
		mov	cx,[si+MS_SIZE]
		mov	dx,[si+MS_DEPTH]
		add	si,MS_DATA
		add	si,cx
		call	CreateEGAData
		pop	si

;* allocate space for sprite in EGA card, set base and offset

		push	ax
		call	AllocateSpace
		pop	cx
		jc	InitMSFail	;no space available ->
		mov	[si+MS_BASE],bp
		mov	[si+MS_OFFSET],di

;* copy EGA data in WorkScreen to EGA card

		push	cx
		push	si
		push	ds
		push	es
		mov	es,bp
		mov	ax,SEG WorkScreen
		mov	ds,ax
		xor	si,si
		call	MoveEGAData
		pop	es
		pop	ds
		pop	si
		pop	cx

;* calc new EGA width and size

		mov	ax,[si+MS_WIDTH]
		mov	bx,ax		;store TAN width
		mov	dx,ax
		shr	ax,1
		shr	ax,1 		;/4
		and	dx,0011b	;round up if any remainder
		cmp	dx,1		;0 = cf = 1; 1, 2 or 3 = cf = 0
		cmc			;0 = cf = 0; 1, 2 or 3 = cf = 1
		adc	ax,0		;add 1 if remainder
		mov	[si+MS_WIDTH],ax

		mov	[si+MS_SIZE],cx

;* create EGA mask data in WorkScreen

		mov	al,1
		mov	dx,[si+MS_DEPTH]
		add	si,MS_DATA
		push	si
		call	CreateEGAMask
		pop	si

;* copy EGA mask in WorkScreen over TAN mask

		mov	cx,ax
		push	ds
		mov	ax,SEG WorkScreen
		mov	ds,ax
		mov	di,si
		xor	si,si
		rep	movsb
		pop	ds
		
InitMSFail:	pop	bx
		add	bx,2  		;next sprite
		jmp	InitMSLoop

		ASSUME	DS:DATA
		ASSUME	ES:DATA

InitMSExit:	pop	es
		pop	ds

		ret

EGA_InitMS	ENDP

;----------------------------------------------------------------------------

;* EGA_InitQS - initialize quick sprites
;*
;* pass: QSpriteList
;* ret : nothing
;* kill: ax, bx, cx, dx, si, di, bp, flags
;* note: The WorkScreen is used as a buffer.
;*       Refer to QS_TAN_1.ASM for QSprite data formats.

QS_WIDTH	EQU	0
QS_DEPTH	EQU	2
QS_BASE		EQU	4
QS_OFFSET	EQU	6
QS_DATA		EQU	8

EGA_InitQS	PROC	FAR

		push	ds
		push	es

	     	xor	bx,bx
InitQSLoop:	mov	ax,SEG QSpriteList
		mov	ds,ax
		mov	es,ax

		ASSUME	DS:SEG QSpriteList

		mov	si,QSpriteList[bx]	
		cmp	si,-1		;end of list?
		jne	InitQSCont	;no ->
		jmp	InitQSExit

InitQSCont:	push	bx

;* create EGA data in WorkScreen

		push	si
		mov	al,1
		mov	bx,[si+QS_WIDTH]
		mov	dx,[si+QS_DEPTH]
		add	si,QS_DATA
		call	CreateEGAData
		pop	si

;* allocate space for sprite in EGA card, set base and offset

		push	ax
		call	AllocateSpace
		pop	cx
		jc	InitQSFail	;no space available ->
		mov	[si+QS_BASE],bp
		mov	[si+QS_OFFSET],di

;* copy EGA data in WorkScreen to EGA card

		push	si
		push	ds
		push	es
		mov	es,bp
		mov	ax,SEG WorkScreen
		mov	ds,ax
		xor	si,si
		call	MoveEGAData
		pop	es
		pop	ds
		pop	si

;* calc new EGA width

		mov	ax,[si+QS_WIDTH];TAN width always multiple of 8 pixels
		shr	ax,1
		shr	ax,1		;/4 for EGA width
		mov	[si+QS_WIDTH],ax

InitQSFail:	pop	bx
		add	bx,2  		;next sprite
		jmp	InitQSLoop

		ASSUME	DS:DATA
		ASSUME	ES:DATA

InitQSExit:	pop	es
		pop	ds

		ret

EGA_InitQS	ENDP

;----------------------------------------------------------------------------

;* AllocateSpace - allocate EGA page area for sprite data
;*
;* pass: ax = number of bytes required (for 1 plane)
;* ret : cf = 0: bp = segment
;*               di = segment offset
;*       cf = 1: bp = 0 (error, no space available)
;*               di = 0
;* kill: ax, bx, cx, flags

AllocateSpace	PROC	NEAR

		push	ds
		mov	bx,DATA
		mov	ds,bx

		ASSUME	DS:DATA

		xor	bx,bx
		mov	cx,8
AllocateLoop:	cmp	ax,EGAFreeSpace[bx]
		jbe	FoundSpace	
		add	bx,2
		loop	AllocateLoop
		xor	di,di	
		xor	bp,bp
		stc			;cf = 1 = error
		jmp	AllocateExit

FoundSpace:	mov	di,EGAFreeSpace[bx]
		sub	EGAFreeSpace[bx],ax
		mov	ax,MAX_SPACE
		xchg	ax,di
		sub	di,ax		;bp = offset
		mov	bp,BasePage[bx]	;di = segment
		clc			;cf = 0 = ok

AllocateExit:	pop	ds
		ret

AllocateSpace	ENDP

;----------------------------------------------------------------------------

;* CreateEGAData - create EGA data from TAN data
;*
;* pass: al = type: 0 = shifted, 1 = non-shifted
;*       bx = width
;*       dx = depth
;*       ds:si -> pattern data
;* ret : ax = number of bytes created (for 1 plane)
;*       EGA format data in WorkScreen (order B, G, R, I)
;* kill: assume all

CreateEGAData	PROC	NEAR

		push	es

		mov	ch,al		;ch = type
		mov	bp,dx		;bp = depth

		mov	ax,SEG WorkScreen
		mov	es,ax
		xor	di,di		;start of WorkScreen

		mov	dh,00010000b	;hi nibble plane mask (do B first)
		mov	dl,00000001b	;lo nibble plane mask (do B first)

CreateDataLp1:	push	si
		push	bp

CreateDataLp2:	xor	ah,ah		;clear result
		mov	bh,10000000b	;init out mask
		mov	cl,bl		;cl = width
CreateDataLp3:	lodsb			;fetch TAN data
		test	al,dh		;this plane set in hi nibble?
		jz	NotSetHi	;no ->
		or	ah,bh		;set result bit				
NotSetHi:	ror	bh,1		;next result bit
		test	al,dl		;this plane set in lo nibble?
		jz	NotSetLo	;no ->
		or	ah,bh		;set result bit				
NotSetLo:	ror	bh,1		;next result bit
		jnc	NotFull		;byte not finished ->
		mov	al,ah
		stosb			;store result
		xor	ah,ah		;clear result
NotFull:	dec	cl
		jnz	CreateDataLp3	;next byte ->
		cmp	bh,10000000b	;any remainder?
		je	NoRemainder	;no ->
		mov	al,ah
		stosb			;store remainder
NoRemainder:	test	ch,ch		;shifted sprite?
		jnz	NotShifted	;no ->
		xor	al,al
		stosb			;store 'shift into' byte
NotShifted:	dec	bp
		jnz	CreateDataLp2	;next line ->
				
		pop	bp
		pop	si
		shl	dx,1		;next hi and lo planes
		jnc	CreateDataLp1	;next plane ->

;* if shifted data then shift the data

		test	ch,ch		;shifted sprite?
		jnz	SkipDataShift	;no ->

		push	ds
		mov	ax,es
		mov	ds,ax
		xor	si,si

;* ds:si -> start of unshifted data
;* es:di -> buffer for next shift

		mov	dx,di		;number of bytes to shift
		mov	bp,3		;shift 3 times

DataShiftLp1:	mov	cx,dx
		rep	movsb		;copy data

;* shift 2 pixels

		mov	cx,dx
		clc		
DataShiftLp2:	rcr	BYTE PTR [si],1
		inc	si
		loop	DataShiftLp2
		sub	si,dx
		mov	cx,dx
		clc		
DataShiftLp3:	rcr	BYTE PTR [si],1
		inc	si
		loop	DataShiftLp3
		sub	si,dx

		dec	bp	
		jnz	DataShiftLp1	;next shift

		pop	ds	      
	
SkipDataShift:	mov	ax,di		;ax = number of bytes created
		shr	ax,1
		shr	ax,1		;/4 for bytes in 1 plane
		pop	es
		ret

CreateEGAData	ENDP

;----------------------------------------------------------------------------

;* CreateEGAMask - create EGA mask from TAN mask
;*
;* pass: al = type: 0 = shifted, 1 = non-shifted
;*       bx = width
;*       dx = depth
;*       ds:si -> mask data
;* ret : ax = number of bytes created
;*       EGA mask data in WorkScreen
;* kill: assume all

CreateEGAMask	PROC	NEAR

		push	es

		mov	ch,al		;ch = type
		mov	bp,dx		;bp = depth

		mov	ax,SEG WorkScreen
		mov	es,ax
		xor	di,di		;start of WorkScreen

		mov	dh,11110000b	;hi nibble mask compare
		mov	dl,00001111b	;lo nibble mask compare

CreateMaskLp1:	xor	ah,ah		;clear result
		mov	bh,10000000b	;init out mask
		mov	cl,bl		;cl = width
CreateMaskLp2:	lodsb			;fetch TAN mask
		test	al,dh		;mask in hi nibble?
		jnz	NotMaskHi	;yes ->
		or	ah,bh		;set result bit
NotMaskHi:	ror	bh,1		;next result bit
		test	al,dl		;mask in lo nibble?
		jnz	NotMaskLo	;yes ->
		or	ah,bh		;set result bit				
NotMaskLo:	ror	bh,1		;next result bit
		jnc	MaskNotFull  	;byte not finished ->
		mov	al,ah
		stosb			;store result
		xor	ah,ah		;clear result
MaskNotFull:	dec	cl
		jnz	CreateMaskLp2	;next byte ->
		cmp	bh,10000000b	;any remainder?
		je	NoMaskRemainder	;no ->
		mov	al,ah
		stosb			;store remainder
NoMaskRemainder:test	ch,ch		;shifted sprite?
		jnz	MaskNotShifted	;no ->
		xor	al,al
		stosb			;store 'shift into' byte
MaskNotShifted:	dec	bp
		jnz	CreateMaskLp1	;next line ->
	     
;* if shifted data then shift the data

		test	ch,ch		;shifted sprite?
		jnz	SkipMaskShift	;no ->

		push	ds
		mov	ax,es
		mov	ds,ax
		xor	si,si

;* ds:si -> start of unshifted data
;* es:di -> buffer for next shift

		mov	dx,di		;number of bytes to shift
		mov	bp,3		;shift 3 times

MaskShiftLp1:	mov	cx,dx
		rep	movsb		;copy data

;* shift 2 pixels

		mov	cx,dx
		clc		
MaskShiftLp2:	rcr	BYTE PTR [si],1
		inc	si
		loop	MaskShiftLp2
		sub	si,dx
		mov	cx,dx
		clc		
MaskShiftLp3:	rcr	BYTE PTR [si],1
		inc	si
		loop	MaskShiftLp3
		sub	si,dx

		dec	bp	
		jnz	MaskShiftLp1	;next shift

		pop	ds	      
	
SkipMaskShift:	mov	ax,di		;ax = number of bytes created
		pop	es
		ret

CreateEGAMask	ENDP

;----------------------------------------------------------------------------

;* MoveEGAData - move EGA data from system memory to EGA card memory
;*
;* pass: cx = number of bytes to move (1 plane)
;*       ds:si -> source
;*       es:di -> destination
;*       WorkScreen[] = EGA data (B, G, R, I)
;* ret : cx = number of bytes to move (1 plane)
;*       ds:si -> end of source data + 1
;*       es:di -> end of destination data + 1
;* kill: ax, bx, cx, dx, di, flags
;*       EGA_CTRL_BITMSK

MoveEGAData	PROC	NEAR

		SETREGV	EGA_CTRL,EGA_CTRL_ENABLE,000h

		SETREGV	EGA_CTRL,EGA_CTRL_BITMSK,0ffh

		SLCTREG	EGA_SEQ,EGA_SEQ_MAPMSK

		mov	ah,0001b
		mov	bx,cx
		mov	bp,di

MoveEGADataLp:	mov	al,ah
		out	dx,al

		mov	cx,bx
		mov	di,bp
		rep	movsb

		shl	ah,1	 	;next plane
		test	ah,10000b	;done all planes yet?
		jz	MoveEGADataLp	;no ->

		mov	al,00fh		;set EGA_SEQ_MAPMSK to default value
		out	dx,al

		SETREGV	EGA_CTRL,EGA_CTRL_ENABLE,00fh

		mov	cx,bx		;return cx intact

		ret

MoveEGAData	ENDP

;----------------------------------------------------------------------------

;* EGA_BFill - fast block fill
;*
;* pass: bx = width (1 - 40)
;*       cx = x start (0 - 312 step 8)
;*       dx = depth
;*       di = y start
;*	 FillCol = physical colour
;* ret : nothing
;* kill: assume all
;*       EGA_CTRL_SETRES
;*       EGA_CTRL_BITMSK

EGA_BFill	PROC	FAR

		push	es
		mov	ax,WorkScrPtr
		mov	es,ax

		mov	bp,dx

		SETREGV	EGA_CTRL,EGA_CTRL_SETRES,FillCol

		mov	al,FillCol
		shr	al,1
		shr	al,1
		shr	al,1
		shr	al,1
		xor	ah,ah
		add	ax,EGA_COL_BASE
		mov	si,ax
		mov	al,es:[si]

		SLCTREG	EGA_CTRL,EGA_CTRL_BITMSK

		mov	al,EVEN_HATCH
		test	di,1
		jz	BFillHatchOk
		ror	al,1		;rotate hatch if start on odd line

BFillHatchOk:	shl	di,1		;*2
		shl	di,1		;*4
		shl	di,1		;*8
		mov	si,di
		shl	di,1		;*16
		shl	di,1		;*32
		add	di,si		;y * 40

		shr	cx,1
		shr	cx,1
		shr	cx,1		;(8 pixels / byte)
		add	di,cx		;y * 40 + x / 8

		mov	si,EGA_LINEADD
		sub	si,bx		;si = line add on

EGA_BFillLoop:	out	dx,al		;set hatch mask
		mov	cx,bx		;width (bytes)
		rep	stosb		;fill line
		ror	al,1		;rotate hatch
		add	di,si		;next line
		dec	bp
		jnz	EGA_BFillLoop

		pop	es	
		ret

EGA_BFill	ENDP
	
;----------------------------------------------------------------------------

;* EGA_SaveMouse - save mouse background into MouseHouse[]
;*
;* pass: cx = x co-ord of top lh corner of mouse
;*       bx = y co-ord of top lh corner of mouse
;* ret : MouseHouse[]
;* kill: assume all
;*       EGA_CTRL_RDMAP

EGA_SaveMouse	PROC	FAR

		push	ds
		push	es

		mov	ax,SEG MouseHouse
		mov	es,ax
		mov	ax,WorkScrPtr
		mov	ds,ax

		call	EGA_CalcAddr
		mov	si,di		;ds:si -> mouse background

		mov	di,OFFSET MouseHouse

		mov	ah,0	  	;read map

		SLCTREG EGA_CTRL,EGA_CTRL_RDMAP

EGA_SvMseMapLp:	mov	al,ah
		out	dx,al

		mov	bx,si

		mov	bp,16		;16 lines
EGA_SvMseLoop1:	mov	cx,3		;3 bytes wide (16 pixels + shift byte)
EGA_SvMseLoop2:	cmp	si,EGA_LINEADD*200
		jae	EGA_SvMseExit	;screen ptr outside screen limits ->
		movsb			;copy byte
		loop	EGA_SvMseLoop2	;next byte
		add	si,EGA_LINEADD-3
		dec	bp		;next line
		jnz	EGA_SvMseLoop1

EGA_SvMseExit:	mov	si,bx

		inc	ah		;next plane
		cmp	ah,4		;done all planes yet?
		jne	EGA_SvMseMapLp	;no ->

		pop	es
		pop	ds
		ret

EGA_SaveMouse	ENDP

;----------------------------------------------------------------------------

;* EGA_LoadMouse - load mouse background from MouseHouse[]
;*
;* pass: cx = x co-ord of top lh corner of mouse
;*       bx = y co-ord of top lh corner of mouse
;* 	 MouseHouse[]
;* ret : nothing
;* kill: assume all
;*       EGA_CTRL_BITMSK

EGA_LoadMouse	PROC	FAR

		push	ds
		push	es

		mov	ax,WorkScrPtr
		mov	es,ax
		mov	ax,SEG MouseHouse
		mov	ds,ax

		call	EGA_CalcAddr	;es:di -> mouse background

		mov	si,OFFSET MouseHouse

		mov	ah,0001b	;write map

		SETREGV	EGA_CTRL,EGA_CTRL_ENABLE,000h

		SETREGV	EGA_CTRL,EGA_CTRL_BITMSK,0ffh

		SLCTREG	EGA_SEQ,EGA_SEQ_MAPMSK

EGA_LdMseMapLp:	mov	al,ah
		out	dx,al

		mov	bx,di

		mov	bp,16		;16 lines
EGA_LdMseLoop1:	mov	cx,3		;3 bytes wide (16 pixels + shift byte)
EGA_LdMseLoop2:	cmp	di,EGA_LINEADD*200
		jae	EGA_LdMseExit	;screen ptr outside screen limits ->
		movsb			;copy byte
		loop	EGA_LdMseLoop2	;next byte
		add	di,EGA_LINEADD-3
		dec	bp		;next line
		jnz	EGA_LdMseLoop1

EGA_LdMseExit:	mov	di,bx

		shl	ah,1		;next plane
		test	ah,10000b	;done all planes yet?
		jz	EGA_LdMseMapLp	;no ->

		mov	al,00fh		;set EGA_SEQ_MAPMSK to default value
		out	dx,al

		SETREGV	EGA_CTRL,EGA_CTRL_ENABLE,00fh

		pop	es
		pop	ds
		ret

EGA_LoadMouse	ENDP

;----------------------------------------------------------------------------

;* EGA_SaveScreen - copy WorkScreen[] to CopyScreen[]
;*
;* pass: WorkScreen[]
;* ret : CopyScreen[]
;* kill: assume all
;*       EGA_CTRL_RDMAP

EGA_SaveScreen	PROC	FAR

		push	ds
		push	es

		mov	ax,SEG CopyScreen
		mov	es,ax
		mov	ax,WorkScrPtr
		mov	ds,ax

		SLCTREG EGA_CTRL,EGA_CTRL_RDMAP

		mov	di,OFFSET CopyScreen

		mov	al,0		;bit plane 0
		out	dx,al
		mov	cx,200*EGA_LINEADD
		xor	si,si
		rep	movsb

		mov	al,1		;bit plane 1
		out	dx,al
		mov	cx,200*EGA_LINEADD
		xor	si,si
		rep	movsb

		mov	al,2		;bit plane 2
		out	dx,al
		mov	cx,200*EGA_LINEADD
		xor	si,si
		rep	movsb

		mov	al,3		;bit plane 3
		out	dx,al
		mov	cx,200*EGA_LINEADD
		xor	si,si
		rep	movsb

		pop	es
		pop	ds
		ret

EGA_SaveScreen	ENDP
				
;----------------------------------------------------------------------------

;* EGA_LoadScreen - copy CopyScreen[] to WorkScreen[]
;*
;* pass: CopyScreen[]
;* ret : WorkScreen[]
;* kill: assume all
;*       EGA_CTRL_BITMSK

EGA_LoadScreen	PROC	FAR

		push	ds
		push	es

		mov	ax,WorkScrPtr
		mov	es,ax
		mov	ax,SEG CopyScreen
		mov	ds,ax

		SETREGV	EGA_CTRL,EGA_CTRL_ENABLE,000h

		SETREGV	EGA_CTRL,EGA_CTRL_BITMSK,0ffh

		SLCTREG	EGA_SEQ,EGA_SEQ_MAPMSK

		mov	si,OFFSET CopyScreen

		mov	al,0001b    	;bit plane 0
		out	dx,al
		mov	cx,200*EGA_LINEADD
		xor	di,di
		rep	movsb

		mov	al,0010b    	;bit plane 1
		out	dx,al
		mov	cx,200*EGA_LINEADD
		xor	di,di
		rep	movsb

		mov	al,0100b    	;bit plane 2
		out	dx,al
		mov	cx,200*EGA_LINEADD
		xor	di,di
		rep	movsb

		mov	al,1000b    	;bit plane 3
		out	dx,al
		mov	cx,200*EGA_LINEADD
		xor	di,di
		rep	movsb

		mov	al,00fh		;set EGA_SEQ_MAPMSK to default value
		out	dx,al

		SETREGV	EGA_CTRL,EGA_CTRL_ENABLE,00fh

		pop	es
		pop	ds
		ret
	
EGA_LoadScreen	ENDP

;----------------------------------------------------------------------------

;* EGA_UncompPic - uncompress picture data
;*
;* pass: CopyScreen[] = compressed picture data
;* ret : WorkScreen[] = uncompressed picture data
;* kill: assume all

EGA_UncompPic	PROC	FAR

		push	ds
		push	es

		mov	ax,SEG WorkScreen
		mov	es,ax
		mov	ax,SEG CopyScreen
		mov	ds,ax

		mov	si,OFFSET CopyScreen
		mov	di,OFFSET WorkScreen

		call	RunLenDecode

		pop	es
		pop	ds

		push	ds
		push	es

		mov	ax,WorkScrPtr	
		mov	es,ax
		mov	ax,SEG WorkScreen
		mov	ds,ax

		mov	si,OFFSET WorkScreen
		xor	di,di

		call	ConvTANToEGA

		pop	es
		pop	ds
		ret

EGA_UncompPic	ENDP

;----------------------------------------------------------------------------

;* EGA_HFill - fill 'Z' section of horizon
;*
;* pass: cx = num lines
;*       si = y min
;*       HrznXMin
;*       HrznXMax
;*       HrznLhsCol
;*       HrznRhsCol
;* ret : nothing
;* kill: assume all
;*       EGA_CTRL_BITMSK
;*
;* note: Use solid colours only - cross hatch not implemented.

EGA_HFill	PROC	FAR

		push	es
		mov	ax,WorkScrPtr
		mov	es,ax

		SETREGV	EGA_CTRL,EGA_CTRL_MODE,0010b

		SLCTREG	EGA_CTRL,EGA_CTRL_BITMSK

		shl	si,1		;*2 LhsX[] index
		
		mov	di,si
		shl	di,1		;*4
		shl	di,1		;*8
		mov	ax,di
		shl	di,1		;*16
		shl	di,1		;*32
		add	di,ax		;y * 40

		mov	ax,HrznXMin
		shr	ax,1		;/2
		shr	ax,1		;/4
		shr	ax,1		;/8
		add	di,ax		;y * 40 + x min / 8

		add	si,OFFSET LhsX	;si -> LhsX[y min]

		mov	bx,OFFSET HrznMask

;* bx -> HrznMask
;* cx = num lines
;* dx = addresses EGA_CTRL_BITMSK
;* si -> LhsX[y min]
;* di -> screen
 
		mov	al,0ffh
		out	dx,al		;set mask for solid fill

EGA_HFillLp:	push	cx
		push	di

		lodsw			;fetch x value
		mov	bp,ax		;store x value

		sub	ax,HrznXMin	;x - x min
		shr	ax,1		;/2
		shr	ax,1		;/4
		shr	ax,1		;(x - x min) / 8
		inc	ax		;(x - x min) / 8 + 1
		mov	cx,ax		;cx = num whole bytes to fill

		mov	al,HrznLhsCol
		rep	stosb	  	;fill solid lhs

		dec	di		;move back to screen byte to be masked

		mov	ax,bp
		and	ax,7		;x offset within screen byte
		xlat			;fetch mask wrt x offset
		out	dx,al		;set mask

		mov	al,es:[di]	;read lhs colour into latches
		mov	al,HrznRhsCol
		stosb			;mask rhs colour into middle byte

		mov	al,0ffh
		out	dx,al		;set mask for solid fill

		mov	ax,HrznXMax
		sub	ax,bp		;x max - x
		shr	ax,1		;/2
		shr	ax,1		;/4
		shr	ax,1		;(x max - x) / 8
		mov	cx,ax		;cx = num whole bytes to fill

		mov	al,HrznRhsCol
		rep	stosb	  	;fill solid rhs

		pop	di
		pop	cx
		add	di,EGA_LINEADD
		loop	EGA_HFillLp

		SETREGV	EGA_CTRL,EGA_CTRL_MODE,0000b

		pop	es	
		ret

EGA_HFill	ENDP

GCODE		ENDS

;============================================================================

		END

