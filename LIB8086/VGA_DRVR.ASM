;****************************************************************************
;*
;* VGA_DRVR.ASM
;*
;* Screen dependant routines for Video Graphics Adapter.
;*
;* 10.12.1989 - KJB
;* 29.08.1991 - KJB - VGA_PrtC3 added.
;*                    VGA_SaveScreen / VGA_LoadScreen added.
;*                    VGA_SaveMouse / VGA_LoadMouse added.
;* 18.01.1992 - KJB - VGA_DLoad tidied up to prevent palette switch glitch.
;* 18.03.1992 - KJB - Palette fade added.
;* 17.09.1992 - KJB - Second palette fade added.
;* 20.09.1992 - KJB - FadeOut added.
;* 23.09.1992 - KJB - FadeDown / FadeUp added.
;* 27.09.1992 - KJB - FadeIn added.
;* 02.10.1992 - KJB - UnpackDeltaPic added.
;* 05.10.1992 - KJB - InstantFadeIn / InstantFadeOut added.
;* 25.10.1992 - KJB - ScreenShaker added.
;* 29.11.1992 - KJB - Smoke hatch modified.
;* 18.12.1992 - KJB - Smoke hatch modified.
;* 19.01.1993 - KJB - QFadeOut / QFadeIn added.
;*
;* Video Memory Linear Addressing
;* ------------------------------
;*
;* This VGA graphics driver changes the addressing of video memory to linear
;* (not odd/even, chain or chain 4), to allow access to all 256k of display
;* memory.
;*
;* The major advantage of this addressing mode is that we can write a byte
;* of data to 4 adjacent pixels at once. This is very useful when filling
;* polygons etc., but may be a hindrance for sprites etc. where additional 
;* masking may be required.
;*
;* As this driver will mainly be used for polygon based applications, it is
;* advantageous to put the emphasis on filling polygons quickly.
;*
;* The major disadvantage of this addressing mode is that it is not compat-
;* ible with the MCGA graphics card.
;*
;* Palette Fades
;* -------------
;*
;* Three palette fades are supported. Each fade may be applied to a seperate
;* colour range or the fades may be combined. Combining fades is necessary
;* for effects such as "blacking out" in fog.
;*
;* Fade 3 is applied after fade 2 which is applied after fade 1.
;*
;* Fade 3 is not availble to applications. It is provided for internal
;* effects only (ie. FadeOut).
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<
PUBLIC FadePalette
		PUBLIC	VGA_VMode
		PUBLIC	VGA_DLoad
		PUBLIC	VGA_SetPx
		PUBLIC	VGA_Line
		PUBLIC	VGA_VLine
		PUBLIC	VGA_HLine
		PUBLIC	VGA_PFill
		PUBLIC	VGA_MFill
		PUBLIC	VGA_SFill
		PUBLIC	VGA_PrtC1
		PUBLIC	VGA_PrtC2
		PUBLIC	VGA_PrtC3
		PUBLIC	VGA_SSprite
		PUBLIC	VGA_MSprite
		PUBLIC	VGA_BSprite
		PUBLIC	VGA_QSprite
		PUBLIC	VGA_InitSS
		PUBLIC	VGA_InitMS
		PUBLIC	VGA_InitQS
		PUBLIC	VGA_BFill
		PUBLIC	VGA_SaveMouse
		PUBLIC	VGA_LoadMouse
		PUBLIC	VGA_SaveScreen
		PUBLIC	VGA_LoadScreen
		PUBLIC	VGA_HFill

		PUBLIC	VGA_CalcAddr

		PUBLIC	SetDACBlock
		PUBLIC	ReadDACBlock
		PUBLIC	FadeOut
		PUBLIC	QFadeOut
		PUBLIC	FadeIn 
		PUBLIC	QFadeIn
		PUBLIC	InstantFadeOut
		PUBLIC	InstantFadeIn
		PUBLIC	FadeDown
		PUBLIC	FadeUp
		PUBLIC	UnpackDeltaPic
		PUBLIC	ScreenShaker

		PUBLIC	VGA_LINEADD

		PUBLIC	FadeLevel1
		PUBLIC	FadeRCol1
		PUBLIC	FadeGCol1
		PUBLIC	FadeBCol1
		PUBLIC	FadeStart1
		PUBLIC	FadeCount1

		PUBLIC	FadeLevel2
		PUBLIC	FadeRCol2
		PUBLIC	FadeGCol2
		PUBLIC	FadeBCol2
		PUBLIC	FadeStart2
		PUBLIC	FadeCount2

		PUBLIC	FadeLevel3
		PUBLIC	FadeRCol3
		PUBLIC	FadeGCol3
		PUBLIC	FadeBCol3
		PUBLIC	FadeStart3
		PUBLIC	FadeCount3

		PUBLIC	ShakeTimer
		PUBLIC	HSHAKE_OFF
		PUBLIC	HSHAKE_LO
		PUBLIC	HSHAKE_VERY_LO		
		PUBLIC	HSHAKE_HI
		PUBLIC	HShake
		PUBLIC	VSHAKE_OFF
		PUBLIC	VSHAKE_LO
		PUBLIC	VSHAKE_VERY_LO		
		PUBLIC	VSHAKE_HI
		PUBLIC	VShake
		EXTRN	ResetMouse:FAR
		EXTRN	FastRandX:FAR

		EXTRN	WorkScrPtr:WORD
		EXTRN	RealScrPtr:WORD
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
		EXTRN	Frames:WORD
		EXTRN	CountDown:WORD

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
		EXTRN	VGA_RGB_Data:BYTE
		EXTRN	VGA_RGB_Fade:BYTE

;============================================================================

		INCLUDE	VGA_DRVR.INC
		INCLUDE	USEFUL.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

VGA_LINEADD	EQU	80		;80 bytes / line

VGAScrStart	DW	0,04000h	;page 0, page 1 offsets from 0

DLoadMode	DW	DLoadFlip
		DW	DLoadCopy

ColMask		DB     	00010001b
		DB	00100010b
		DB	01000100b
		DB	10001000b

OctTable	DW	Oct2		;Dx > 0, Dy > Dx
		DW	Oct1		;Dx > 0, Dx > Dy
		DW	Oct7		;Dx < 0, Dy > Dx
		DW	Oct8		;Dx < 0, Dx > Dy

LMask		LABEL	BYTE
		DB	00001111b
		DB	00001110b
		DB	00001100b
		DB	00001000b

RMask		LABEL	BYTE
		DB	00000001b
		DB	00000011b
		DB	00000111b
		DB	00001111b

EVEN_HATCH	EQU	1010b
ODD_HATCH	EQU	0101b
		
EHatchLMask 	LABEL	BYTE
		DB	00001111b AND EVEN_HATCH
		DB	00001110b AND EVEN_HATCH
		DB	00001100b AND EVEN_HATCH
		DB	00001000b AND EVEN_HATCH

EHatchRMask  	LABEL	BYTE
		DB	00000001b AND EVEN_HATCH
		DB	00000011b AND EVEN_HATCH
		DB	00000111b AND EVEN_HATCH
		DB	00001111b AND EVEN_HATCH

OHatchLMask 	LABEL	BYTE
		DB	00001111b AND ODD_HATCH
		DB	00001110b AND ODD_HATCH
		DB	00001100b AND ODD_HATCH
		DB	00001000b AND ODD_HATCH

OHatchRMask  	LABEL	BYTE
		DB	00000001b AND ODD_HATCH
		DB	00000011b AND ODD_HATCH
		DB	00000111b AND ODD_HATCH
		DB	00001111b AND ODD_HATCH

;-----------------------------------
;* >>>>> SMOKE HATCH PATTERN 1 <<<<<
;-----------------------------------

EVEN_SMOKE1	EQU	0001b
ODD_SMOKE1	EQU	0100b
		
ESmokeLMask1 	LABEL	BYTE
		DB	00001111b AND EVEN_SMOKE1
		DB	00001110b AND EVEN_SMOKE1
		DB	00001100b AND EVEN_SMOKE1
		DB	00001000b AND EVEN_SMOKE1

ESmokeRMask1  	LABEL	BYTE
		DB	00000001b AND EVEN_SMOKE1
		DB	00000011b AND EVEN_SMOKE1
		DB	00000111b AND EVEN_SMOKE1
		DB	00001111b AND EVEN_SMOKE1

OSmokeLMask1 	LABEL	BYTE
		DB	00001111b AND ODD_SMOKE1
		DB	00001110b AND ODD_SMOKE1
		DB	00001100b AND ODD_SMOKE1
		DB	00001000b AND ODD_SMOKE1

OSmokeRMask1  	LABEL	BYTE
		DB	00000001b AND ODD_SMOKE1
		DB	00000011b AND ODD_SMOKE1
		DB	00000111b AND ODD_SMOKE1
		DB	00001111b AND ODD_SMOKE1

;-----------------------------------
;* >>>>> SMOKE HATCH PATTERN 2 <<<<<
;-----------------------------------

EVEN_SMOKE2	EQU	1000b
ODD_SMOKE2	EQU	0010b
		
ESmokeLMask2 	LABEL	BYTE
		DB	00001111b AND EVEN_SMOKE2
		DB	00001110b AND EVEN_SMOKE2
		DB	00001100b AND EVEN_SMOKE2
		DB	00001000b AND EVEN_SMOKE2

ESmokeRMask2  	LABEL	BYTE
		DB	00000001b AND EVEN_SMOKE2
		DB	00000011b AND EVEN_SMOKE2
		DB	00000111b AND EVEN_SMOKE2
		DB	00001111b AND EVEN_SMOKE2

OSmokeLMask2 	LABEL	BYTE
		DB	00001111b AND ODD_SMOKE2
		DB	00001110b AND ODD_SMOKE2
		DB	00001100b AND ODD_SMOKE2
		DB	00001000b AND ODD_SMOKE2

OSmokeRMask2  	LABEL	BYTE
		DB	00000001b AND ODD_SMOKE2
		DB	00000011b AND ODD_SMOKE2
		DB	00000111b AND ODD_SMOKE2
		DB	00001111b AND ODD_SMOKE2

;--------------------
;* smoke start switch
;--------------------

SmokeStart	DW	NextESmokeLine	;pattern 1, even y
		DW	NextESmkLine	;pattern 2, even y
		DW	NextOSmokeLine	;pattern 1, odd y
		DW	NextOSmkLine	;pattern 2, odd y

;* reverse nibble bits table (reverse character data)
 
FlipNibble	DB	0000b		;0000b
		DB	1000b		;0001b
		DB	0100b		;0010b
		DB	1100b		;0011b
		DB	0010b		;0100b
		DB	1010b		;0101b
		DB	0110b		;0110b
		DB	1110b		;0111b
		DB	0001b		;1000b
		DB	1001b		;1001b
		DB	0101b		;1010b
		DB	1101b		;1011b
		DB	0011b		;1100b
		DB	1011b		;1101b
		DB	0111b		;1110b
		DB	1111b		;1111b

;* horizon fill masks

HrznMask 	DB	1111b
		DB	1110b
		DB	1100b
		DB	1000b

;-------------------
;* palette fade vars
;-------------------

FadeFlag	DB	0,0		;1 = fade enabled

;-------------
;* fade 1 vars
;-------------

FadeParams1	LABEL	WORD		;current fade params

FadeLevel1	DB	0		;0 .. 127
FadeRCol1	DB	0		;0 .. 63
FadeGCol1	DB	0		;0 .. 63
FadeBCol1	DB	0		;0 .. 63

_FadeParams1	LABEL	WORD		;previous fade params

_FadeLevel1	DB	0
_FadeRCol1	DB	0
_FadeGCol1	DB	0
_FadeBCol1	DB	0

FadeStart1	DW	0		;start col 0 .. 255

FadeCount1	DW	256		;count 1 .. 256

;-------------
;* fade 2 vars
;-------------

FadeParams2	LABEL	WORD		;current fade params

FadeLevel2	DB	0		;0 .. 127
FadeRCol2	DB	0		;0 .. 63
FadeGCol2	DB	0		;0 .. 63
FadeBCol2	DB	0		;0 .. 63

_FadeParams2	LABEL	WORD		;previous fade params

_FadeLevel2	DB	0
_FadeRCol2	DB	0
_FadeGCol2	DB	0
_FadeBCol2	DB	0

FadeStart2	DW	0		;start col 0 .. 255

FadeCount2	DW	256		;count 1 .. 256

;-------------
;* fade 3 vars
;-------------

FadeParams3	LABEL	WORD		;fade params

FadeLevel3	DB	0		;0 .. 127
FadeRCol3	DB	0		;0 .. 63
FadeGCol3	DB	0		;0 .. 63
FadeBCol3	DB	0		;0 .. 63

FadeStart3	DW	0		;start col 0 .. 255

FadeCount3	DW	256		;count 1 .. 256

;--------------
;* screen shake
;--------------

ShakeTimer	DW	0		;secs * 100

HSHAKE_OFF	EQU	0000b
HSHAKE_LO	EQU	0010b
HSHAKE_HI	EQU	0110b

HShake		DB	HSHAKE_OFF
			 
VSHAKE_OFF	EQU	0000b
VSHAKE_LO	EQU	0001b
VSHAKE_HI	EQU	0011b

HSHAKE_VERY_LO	EQU	0001b
VSHAKE_VERY_LO	EQU	0001b


VShake		DB	VSHAKE_OFF

VShakeTable	DB	0		;screen start address
		DB	80
		DB	160
		DB	240

		EVEN
			 
DATA		ENDS

;============================================================================

WSDATA		SEGMENT PARA PUBLIC 'DATA'

WSDATA		ENDS

;============================================================================

GCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:GCODE
		ASSUME DS:DATA

;* VGA_VMode - set video mode
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all
;*	 VGA_SEQ_MAPMSK
;*
;* note: Reset mouse immediately after setting video mode (see MOUSE.ASM).

VGA_VMode	PROC	FAR

		mov	ah,0 		;service 0, set video mode
		mov	al,013h		;320 * 200, 256 colour
		int	010h		;BIOS

		call	ResetMouse

		mov	ax,VGA_PAGE_1
		mov	WorkScrPtr,ax
		mov	ax,VGA_PAGE_0
		mov	RealScrPtr,ax

		mov	ScreenPage,2

		mov	SetPaletteFlag,1

;* change addressing mode of video memory to linear

		SLCTREG	VGA_SEQ,VGA_SEQ_MEMMOD
		in	al,dx
		and	al,NOT 008h	;disable chain 4
		or	al,004h		;disable odd/even
		out	dx,al

		SLCTREG	VGA_CTRL,VGA_CTRL_MODE
		in	al,dx
		and	al,NOT 010h	;disable odd/even
		out	dx,al

		SLCTREG	VGA_CTRL,VGA_CTRL_MISC
		in	al,dx
		and	al,NOT 002h	;disable chain
		out	dx,al

;* now clear all of video memory so that the switch to linear is not messy

		SETREGV	VGA_SEQ,VGA_SEQ_MAPMSK,1111b

		push	es
		mov	ax,VGA_PAGE_0
		mov	es,ax
		xor	ax,ax
		mov	cx,08000h
		xor	di,di
		rep	stosw
		pop	es

;* change CRTC scanning from doubleword to byte mode

		SLCTREG	VGA_CRTC,VGA_CRTC_ULINE
		in	al,dx
		and	al,NOT 040h	;disable doubleword
		out	dx,al

		SLCTREG	VGA_CRTC,VGA_CRTC_MODE
		in	al,dx
		or	al,040h		;enable byte mode
		out	dx,al

;* reset fade 3 (internal fade) in case FadeOut used before setting video mode

		xor	ax,ax

		mov	FadeLevel3,al

		mov	FadeRCol3,al
		mov	FadeGCol3,al
		mov	FadeBCol3,al

		mov	FadeStart3,ax
		mov	FadeCount3,256

		ret

VGA_VMode	ENDP

;----------------------------------------------------------------------------

;* VGA_DLoad - download work screen to real screen
;*
;* pass: WorkScrPtr
;*       RealScrPtr
;*       FlipMode
;* ret : nothing
;* kill: assume all
;*       VGA_SEQ_MAPMSK
;* note: FlipMode = 0 then flip work / real screens (game mode)
;*       FlipMode = 2 then copy work screen to real screen (menu mode)

VGA_DLoad	PROC	FAR

;* if fade params changed or (SetPaletteFlag = 1 and (FadeLevel1 <> 0 or FadeLevel2 <> 0)) then
;*    fade palette
;* end

		mov	ax,FadeParams1
		mov	dx,FadeParams1+2

		xchg	ax,_FadeParams1
		xchg	dx,_FadeParams1+2

		cmp	ax,_FadeParams1
		jne	ContFade
		cmp	dx,_FadeParams1+2
		jne	ContFade

		mov	ax,FadeParams2
		mov	dx,FadeParams2+2

		xchg	ax,_FadeParams2
		xchg	dx,_FadeParams2+2

		cmp	ax,_FadeParams2
		jne	ContFade
		cmp	dx,_FadeParams2+2
		jne	ContFade

		test	SetPaletteFlag,1
		jz	SkipFade

		cmp	FadeLevel1,0
		jne	ContFade

		cmp	FadeLevel2,0
		je	SkipFade

ContFade: 	call	FadePalette

SkipFade:	mov	bx,FlipMode
		jmp	DLoadMode[bx]
	
;---------------------------
DLoadCopy	LABEL	NEAR
;---------------------------

		push	ds
		push	es

		SETREGV	VGA_SEQ,VGA_SEQ_MAPMSK,1111b

		SLCTREG	VGA_CTRL,VGA_CTRL_MODE
		in	al,dx
		or	al,01b		;write mode 1
		out	dx,al

		mov	ax,RealScrPtr
		mov	es,ax
		mov	ax,WorkScrPtr
		mov	ds,ax

		xor	si,si
		xor	di,di
		
		mov	cx,VGA_LINEADD*200

		rep	movsb
		
		in	al,dx
		and	al,NOT 11b	;write mode 0
		out	dx,al

		pop	es
		pop	ds

		jmp	SortPalette

;---------------------------
DLoadFlip	LABEL	NEAR
;---------------------------

		cli

		mov	ax,RealScrPtr
		xchg	ax,WorkScrPtr
		mov	RealScrPtr,ax

		mov	bx,ScreenPage
		mov	ax,VGAScrStart[bx]
		xchg	ax,bx
		xor	ax,10b		;0 <-> 2
		mov	ScreenPage,ax

		mov	dx,VGA_CRTC

		mov	al,VGA_CRTC_HI
		mov	ah,bh
		out	dx,ax
		jmp 	$+2		;wait a few cycles
		
	   	mov	al,VGA_CRTC_LO
		mov	ah,bl
		out	dx,ax
		jmp	$+2		;wait a few cycles

;----------------------------
;* reset horizontal pixel pan (ensure screen normalized at end of shake)
;----------------------------

;* clear flip-flop to allow attribute register index to be selected

		mov	dx,VGA_INPUT_1	
		in	al,dx

;* select index for horizontal pixel panning register

		mov	dx,VGA_ATTR
		mov	al,VGA_ATTR_HPAN
		out	dx,al

		xor	al,al
		out	dx,al

		sti

;* start address is loaded at the start of v trace, so wait for v trace

VLoop1:	    	mov	dx,VGA_CRT_STAT ;make sure v trace is not occuring
	    	in	al,dx
	    	test	al,VGA_VSYNC
	    	jnz	VLoop1
	
VLoop2:		mov	dx,VGA_CRT_STAT	;wait for vertical retrace to occur
		in	al,dx  	
		test 	al,VGA_VSYNC
	     	jz 	VLoop2

;-----------------------------------------
;* load VGA palette registers if requested
;-----------------------------------------

SortPalette:	mov	si,OFFSET VGA_RGB_Fade	;assume fade palette

		test	FadeFlag,1		;fade palette?
		jnz	@F			;yes ->

		test	SetPaletteFlag,1	;load VGA palette registers?
		jz	SkipLoad      		;no ->

		mov	si,OFFSET VGA_RGB_Data

@@:		push	ds

		mov	ax,SEG VGA_RGB_Data
		mov	ds,ax

		xor	al,al
		mov	cx,256

		call	SetDACBlock

		pop	ds

		mov	SetPaletteFlag,0

		mov	FadeFlag,0

SkipLoad: 	ret

VGA_DLoad	ENDP

;----------------------------------------------------------------------------

;* VGA_SetPx - set pixel
;*
;* pass: bl = y (0 - 199)
;*       cx = x (0 - 319)
;*       PixelCol
;* ret : nothing
;* kill: ax, dx, si, di, flags
;*       VGA_SEQ_MAPMSK

VGA_SetPx	PROC	FAR
		
		push	es
		mov	ax,WorkScrPtr
		mov	es,ax

		SLCTREG	VGA_SEQ,VGA_SEQ_MAPMSK
	
		call	VGA_CalcAddr	;es:di -> screen
		mov 	si,cx 
		and 	si,3

		mov 	al,ColMask[si]
		out	dx,al		;set bit mask
		mov	al,PixelCol
		stosb

		pop	es
		ret		 

VGA_SetPx	ENDP

;----------------------------------------------------------------------------

;* VGA_Line - draw line between two points
;*
;* pass: cx, bl = x1, y1
;*       dx, bh = x2, y2
;*       LineCol
;* ret : nothing
;* kill: assume all
;*       VGA_SEQ_MAPMSK

VGA_Line	PROC	FAR

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
		shl	di,1		;*16
		mov	ax,di
		shl	di,1		;*32
		shl	di,1		;*64
		add	di,ax		;y * 80

		mov	bp,bx
		mov	bx,cx
		and	bx,3
		mov	ah,ColMask[bx]
		mov	bx,bp

		shr	cx,1		;/2
		shr	cx,1		;/4
		add	di,cx

		mov	bp,dx

		SLCTREG	VGA_SEQ,VGA_SEQ_MAPMSK
	
		mov	al,ah

		jmp	OctTable[si]	;jump to octant routine

VLineLink:	jmp	IntoVLine	;jump into VLine routine ->
HLineLink:	jmp	IntoHLine	;jump into HLine routine ->

;* al = mask
;* bx = Dy
;* dx = addresses VGA_SEQ_MAPMSK
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

		rol	al,1		;x = x + 1
		jc	Oct1Ov		;overflow into next byte ->

Oct1Ok:		sub	si,bx		;error = error - Dy
		ja	Oct1Lp		;if error > 0 then no y change ->

		xchg	al,ah		;write accumulated x mask to screen
		out	dx,al
		mov	al,LineCol
		mov	es:[di],al
		xor	al,al
		xchg	al,ah

		add	si,bp		;error = error + Dx
		add	di,VGA_LINEADD	;y = y + 1
		jmp	Oct1Lp

Oct1End:	mov	al,ah		;write accumulated x mask to screen
		out	dx,al
		mov	al,LineCol
		mov	es:[di],al

		pop	es
		ret

Oct1Ov:	 	xchg	al,ah		;write accumulated x mask to screen
		out	dx,al
		mov	al,LineCol
		mov	es:[di],al
		xor	al,al
		xchg	al,ah
		inc	di
		jmp	Oct1Ok

;* octant 2: Dx > 0, Dy > Dx

Oct2:		mov	ah,LineCol

		mov	cx,bx
		inc	cx		;count = Dy + 1	

		mov	si,bx
		shr	si,1		;error = Dy / 2
		adc	si,0		;1/2 bit round up

Oct2Lp:		out	dx,al		;plot x, y
		mov	es:[di],ah
		
		dec	cx		;count = count - 1
		jz	Oct2End		;exit if count = 0

		add	di,VGA_LINEADD	;y = y + 1
		sub	si,bp		;error = error - Dx
		ja	Oct2Lp		;if error > 0 then no x change ->
		
		add	si,bx		;error = error + Dy
		rol	al,1		;x = x + 1
		adc	di,0		;inc di if mask wrap around
		jmp	Oct2Lp

Oct2End:        pop	es
		ret

;* octant 7: Dx < 0, Dy > Dx

Oct7:		mov	ah,LineCol

		mov	cx,bx
		inc	cx		;count = Dy + 1	

		mov	si,bx
		shr	si,1		;error = Dy / 2
		adc	si,0		;1/2 bit round up

Oct7Lp:		out	dx,al		;plot x, y
		mov	es:[di],ah
		
		dec	cx		;count = count - 1
		jz	Oct7End		;exit if count = 0

		add	di,VGA_LINEADD	;y = y + 1
		sub	si,bp		;error = error - Dx
		ja	Oct7Lp		;if error > 0 then no x change ->
		
		add	si,bx		;error = error + Dy
		ror	al,1		;x = x - 1
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

		ror	al,1		;x = x - 1
		jc	Oct8Ov		;overflow into next byte ->

Oct8Ok:		sub	si,bx		;error = error - Dy
		ja	Oct8Lp		;if error > 0 then no y change ->

		xchg	al,ah		;write accumulated x mask to screen
		out	dx,al
		mov	al,LineCol
		mov	es:[di],al
		xor	al,al
		xchg	al,ah

		add	si,bp		;error = error + Dx
		add	di,VGA_LINEADD	;y = y + 1
		jmp	Oct8Lp

Oct8End:	mov	al,ah		;write accumulated x mask to screen
		out	dx,al
		mov	al,LineCol
		mov	es:[di],al

		pop	es
		ret

Oct8Ov:	 	xchg	al,ah		;write accumulated x mask to screen
		out	dx,al
		mov	al,LineCol
		mov	es:[di],al
		xor	al,al
		xchg	al,ah
		dec	di
		jmp	Oct8Ok

VGA_Line	ENDP

;----------------------------------------------------------------------------

;* VGA_VLine - draw vertical line between two points
;*
;* pass: bl = y1
;*       bh = y2
;*       cx = x1
;*       LineCol
;* ret : nothing
;* kill: assume all
;*       VGA_SEQ_MAPMSK

VGA_VLine	PROC	FAR

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

		mov	bx,cx
		and	bx,3

		SETREGV	VGA_SEQ,VGA_SEQ_MAPMSK,ColMask[bx]

		shl	di,1		;*2
		shl	di,1		;*4
		shl	di,1		;*8
		shl	di,1		;*16
		mov	ax,di
		shl	di,1		;*32
		shl	di,1		;*64
		add	di,ax		;y * 80

		shr	cx,1		;/2
		shr	cx,1		;/4
		add	di,cx		;y * 80 + x / 4

		mov	cx,bp
		mov	bp,VGA_LINEADD-1

		mov	al,LineCol

VLineLoop:	stosb
		add	di,bp
		loop	VLineLoop

		pop	es
		ret

VGA_VLine	ENDP

;----------------------------------------------------------------------------

;* VGA_HLine - draw horizontal line between two points
;*
;* pass: bl = y1
;*       cx = x1
;*       dx = x2
;*       LineCol
;* ret : nothing
;* kill: assume all
;*       VGA_SEQ_MAPMSK

VGA_HLine	PROC	FAR

		push	es
		mov	ax,WorkScrPtr
		mov	es,ax

IntoHLine:	cmp	cx,dx		;x1 <= x2?
		jbe	HLineXOk	;yes, co-ords ok ->
		xchg	cx,dx
HLineXOk:   	mov	bp,dx

		SLCTREG	VGA_SEQ,VGA_SEQ_MAPMSK
		
		mov	di,bx
		and	di,000ffh
		shl	di,1		;*2
		shl	di,1		;*4
		shl	di,1		;*8
		shl	di,1		;*16
		mov	ax,di
		shl	di,1		;*32
		shl	di,1		;*64
		add	di,ax		;y * 80

		mov	ax,cx
		shr	ax,1		;/2
		shr	ax,1		;/4
		add	di,ax		;y * 80 + x / 4

		mov	bx,cx
		and	bx,3		;lhs byte disp

		mov	si,bp
		and	si,3		;rhs byte disp

		sub	cx,bp
		neg	cx
		add	cx,bx		;trim off lh side
		sub	cx,4
		sub	cx,si		;trim off rh side

		sar	cx,1		;4 pixels / byte
		sar	cx,1		;cx = number of whole bytes to fill

		mov	ah,LineCol

		js	ShortHLine	;cx < 0 = short line ->

		mov	al,LMask[bx]	;mask in lh line end
		out	dx,al
		mov	al,ah
		stosb

		mov	al,1111b	;fill line middle
		out	dx,al
		mov	al,ah
		rep	stosb

		mov	al,RMask[si]	;mask in rh line end
		out	dx,al
		mov	al,ah
		stosb

HLineExit:	pop	es
		ret

;* short horizontal line draw (exception)

ShortHLine:	mov	al,LMask[bx]
		and	al,RMask[si]
		out	dx,al
		mov	al,ah
		stosb
		jmp	HLineExit

VGA_HLine	ENDP

;----------------------------------------------------------------------------

;* VGA_PFill - fill polygon from table
;*
;* pass: MinY, MaxY
;*       LhsX, RhsX
;*       FillCol
;* ret : nothing
;* kill: ax, bx, cx, dx, di, bp, flags
;*       VGA_SEQ_MAPMSK

VGA_PFill	PROC	FAR

		push	si
		push	es
		mov	ax,WorkScrPtr
		mov	es,ax

		SLCTREG	VGA_SEQ,VGA_SEQ_MAPMSK

		mov	bx,MinY
		mov	cx,MaxY
		sub	cx,bx
		inc	cx		;cx = number of lines
		shl	bx,1		;bx = x table index
		mov	di,bx
		shl	di,1		;*4
		shl	di,1		;*8
		shl	di,1		;*16
		mov	ax,di
		shl	di,1		;*32
		shl	di,1		;*64
		add	di,ax		;*80

;* bx = x table index
;* cx = number of lines
;* dx = addresses VGA_SEQ_MAPMSK
;* di -> screen (x = 0)

NextFillLine:	push	bx
		push	cx

		mov	ax,RhsX[bx]
		mov	bp,ax
		mov	ax,LhsX[bx]
		mov	cx,ax

		mov	bx,cx
		and	bx,3		;lhs byte disp

		mov	si,bp
		and	si,3		;rhs byte disp

		sub	cx,bp
		ja	FixPoints	;error lh x > rh x ->
PointsFixed:	neg	cx
		add	cx,bx		;trim off lh side
		sub	cx,4
		sub	cx,si		;trim off rh side

		mov	bp,di		;save screen address

		shr	ax,1		;/2
		shr	ax,1		;/4
		add	di,ax		;y + x / 4

		sar	cx,1		;4 pixels / byte
		sar	cx,1		;cx = number of whole bytes to fill

		mov	ah,FillCol

		js	ShortLine	;cx < 0 = short line ->

		mov	al,LMask[bx]	;mask in lh line end
		out	dx,al
		mov	al,ah
		stosb

		mov	al,1111b	;fill line middle
		out	dx,al
		mov	al,ah
		rep	stosb

		mov	al,RMask[si]	;mask in rh line end
		out	dx,al
		mov	al,ah
		stosb

FillEndLoop:	mov	di,bp		;restore screen address
		pop	cx
		pop	bx
		add	bx,2		;next table index
		add	di,VGA_LINEADD	;y = y + 1
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
		mov	al,ah
		stosb
		jmp	FillEndLoop

VGA_PFill	ENDP

;----------------------------------------------------------------------------

;* VGA_MFill - fill "transparent" polygon from table
;*
;* pass: MinY, MaxY
;*       LhsX, RhsX
;*       FillCol
;* ret : nothing
;* kill: ax, bx, cx, dx, di, bp, flags
;*       VGA_SEQ_MAPMSK

VGA_MFill	PROC	FAR

		push	si
		push	es
		mov	ax,WorkScrPtr
		mov	es,ax

		SLCTREG	VGA_SEQ,VGA_SEQ_MAPMSK

		mov	bx,MinY
		mov	cx,MaxY
		sub	cx,bx
		inc	cx		;cx = number of lines
		shl	bx,1		;bx = x table index
		mov	di,bx
		shl	di,1		;*4
		shl	di,1		;*8
		shl	di,1		;*16
		mov	ax,di
		shl	di,1		;*32
		shl	di,1		;*64
		add	di,ax		;*80

		test	bx,0010b	;start on even or odd hatch?
		jz	NextEMeshLine	;even hatch ->
		jmp	NextOMeshLine	;odd hatch ->

;* bx = x table index
;* cx = number of lines
;* dx = addresses VGA_SEQ_MAPMSK
;* di -> screen (x = 0)

NextEMeshLine:	push	bx
		push	cx

		mov	ax,RhsX[bx]
		mov	bp,ax
		mov	ax,LhsX[bx]
		mov	cx,ax

		mov	bx,cx
		and	bx,3		;lhs byte disp

		mov	si,bp
		and	si,3		;rhs byte disp

		sub	cx,bp
		ja	FixEMeshPoints	;error lh x > rh x ->
EMeshPtsFixed:	neg	cx
		add	cx,bx		;trim off lh side
		sub	cx,4
		sub	cx,si		;trim off rh side

		mov	bp,di		;save screen address

		shr	ax,1		;/2
		shr	ax,1		;/4
		add	di,ax		;y + x / 4

		sar	cx,1		;4 pixels / byte
		sar	cx,1		;cx = number of whole bytes to fill

		mov	ah,FillCol

		js	ShortEMeshLine	;cx < 0 = short line ->

		mov	al,EHatchLMask[bx]
		out	dx,al
		mov	al,ah
		stosb

		mov	al,EVEN_HATCH
		out	dx,al
		mov	al,ah
		rep	stosb

		mov	al,EHatchRMask[si]
		out	dx,al
		mov	al,ah
		stosb

EMeshEndLoop:	mov	di,bp		;restore screen address
		pop	cx
		pop	bx
		add	bx,2		;next table index
		add	di,VGA_LINEADD	;y = y + 1

		dec	cx
		jnz	NextOMeshLine
		jmp	MeshFillExit

;* lh x > rh x error condition (exception)

FixEMeshPoints:	mov	cx,ax		;cx = lh x
		xchg	cx,bp		;swap lh x, rh x
		mov	ax,cx		;ax = lh x
		xchg	bx,si		;swap lh disp, rh disp
		sub	cx,bp
		jmp	EMeshPtsFixed

;* short line draw (exception)

ShortEMeshLine:	mov	al,EHatchLMask[bx]
		and	al,EHatchRMask[si]
		out	dx,al
		mov	al,ah
		stosb
		jmp	EMeshEndLoop

;* bx = x table index
;* cx = number of lines
;* dx = addresses VGA_SEQ_MAPMSK
;* di -> screen (x = 0)

NextOMeshLine:	push	bx
		push	cx

		mov	ax,RhsX[bx]
		mov	bp,ax
		mov	ax,LhsX[bx]
		mov	cx,ax

		mov	bx,cx
		and	bx,3		;lhs byte disp

		mov	si,bp
		and	si,3		;rhs byte disp

		sub	cx,bp
		ja	FixOMeshPoints	;error lh x > rh x ->
OMeshPtsFixed:	neg	cx
		add	cx,bx		;trim off lh side
		sub	cx,4
		sub	cx,si		;trim off rh side

		mov	bp,di		;save screen address

		shr	ax,1		;/2
		shr	ax,1		;/4
		add	di,ax		;y + x / 4

		sar	cx,1		;4 pixels / byte
		sar	cx,1		;cx = number of whole bytes to fill

		mov	ah,FillCol

		js	ShortOMeshLine	;cx < 0 = short line ->

		mov	al,OHatchLMask[bx]
		out	dx,al
		mov	al,ah
		stosb

		mov	al,ODD_HATCH
		out	dx,al
		mov	al,ah
		rep	stosb

		mov	al,OHatchRMask[si]
		out	dx,al
		mov	al,ah
		stosb

OMeshEndLoop:	mov	di,bp		;restore screen address
		pop	cx
		pop	bx
		add	bx,2		;next table index
		add	di,VGA_LINEADD	;y = y + 1
		
		dec	cx
		jz	MeshFillExit
		jmp	NextEMeshLine

;* lh x > rh x error condition (exception)

FixOMeshPoints:	mov	cx,ax		;cx = lh x
		xchg	cx,bp		;swap lh x, rh x
		mov	ax,cx		;ax = lh x
		xchg	bx,si		;swap lh disp, rh disp
		sub	cx,bp
		jmp	OMeshPtsFixed

;* short line draw (exception)

ShortOMeshLine:	mov	al,OHatchLMask[bx]
		and	al,OHatchRMask[si]
		out	dx,al
		mov	al,ah
		stosb
		jmp	OMeshEndLoop

MeshFillExit:	pop	es
		pop	si
		ret

VGA_MFill	ENDP

;----------------------------------------------------------------------------

;* VGA_SFill - fill "smoke" polygon from table
;*
;* pass: MinY, MaxY
;*       LhsX, RhsX
;*       FillCol
;* ret : nothing
;* kill: ax, bx, cx, dx, di, bp, flags
;*       VGA_SEQ_MAPMSK

VGA_SFill	PROC	FAR

		push	si
		push	es
		mov	ax,WorkScrPtr
		mov	es,ax

		SLCTREG	VGA_SEQ,VGA_SEQ_MAPMSK

		mov	bx,MinY
		mov	cx,MaxY
		sub	cx,bx
		inc	cx		;cx = number of lines
		shl	bx,1		;bx = x table index
		mov	di,bx
		shl	di,1		;*4
		shl	di,1		;*8
		shl	di,1		;*16
		mov	ax,di
		shl	di,1		;*32
		shl	di,1		;*64
		add	di,ax		;*80

;--------------------------------------
	IF	0	;use old method
;--------------------------------------

;* Select start on even or odd hatch wrt y and colour. If two polygons with
;* adjacent colour values are overlapping, then both hatches are visible.
;* This is desirable for smoke circles. Select as follows:-
;* 
;*    even y, even colour (00) -> (0) start on even hatch
;*    even y,  odd colour (01) -> (1) start on  odd hatch
;*     odd y, even colour (10) -> (1) start on  odd hatch
;*     odd y,  odd colour (11) -> (0) start on even hatch
		
		mov	al,FillCol	
		and	al,0001b	;colour (odd / even)
		mov	ah,bl		;y * 2
		and	ah,0010b	;extract lsb
		shr	ah,1		;y (odd / even)
		xor	al,ah		;start on even or odd hatch?
		jz	NextESmokeLine	;even hatch ->
		jmp	NextOSmokeLine	;odd hatch ->

;--------------------------------------
	ELSE	  	;use new method
;--------------------------------------

;* select pattern 1 or pattern 2 wrt odd or even colour

		mov	al,FillCol
		and	ax,0001b

;* select odd or even hatch wrt start y

		mov	si,bx
		and	si,0010b

;* combine

		add	si,ax
		shl	si,1

		jmp	SmokeStart[si]

	ENDIF

;-----------------------------------
;* >>>>> SMOKE HATCH PATTERN 1 <<<<<
;-----------------------------------

;* bx = x table index
;* cx = number of lines
;* dx = addresses VGA_SEQ_MAPMSK
;* di -> screen (x = 0)

NextESmokeLine:	push	bx
		push	cx

		mov	ax,RhsX[bx]
		mov	bp,ax
		mov	ax,LhsX[bx]
		mov	cx,ax

		mov	bx,cx
		and	bx,3		;lhs byte disp

		mov	si,bp
		and	si,3		;rhs byte disp

		sub	cx,bp
		ja	FixESmokePoints	;error lh x > rh x ->
ESmokePtsFixed:	neg	cx
		add	cx,bx		;trim off lh side
		sub	cx,4
		sub	cx,si		;trim off rh side

		mov	bp,di		;save screen address

		shr	ax,1		;/2
		shr	ax,1		;/4
		add	di,ax		;y + x / 4

		sar	cx,1		;4 pixels / byte
		sar	cx,1		;cx = number of whole bytes to fill

		mov	ah,FillCol

		js	ShortESmokeLine	;cx < 0 = short line ->

		mov	al,ESmokeLMask1[bx]
		out	dx,al
		mov	al,ah
		stosb

		mov	al,EVEN_SMOKE1
		out	dx,al
		mov	al,ah
		rep	stosb

		mov	al,ESmokeRMask1[si]
		out	dx,al
		mov	al,ah
		stosb

ESmokeEndLoop:	mov	di,bp		;restore screen address
		pop	cx
		pop	bx
		add	bx,2		;next table index
		add	di,VGA_LINEADD	;y = y + 1

		dec	cx
		jnz	NextOSmokeLine
		jmp	SmokeFillExit

;* lh x > rh x error condition (exception)

FixESmokePoints:mov	cx,ax		;cx = lh x
		xchg	cx,bp		;swap lh x, rh x
		mov	ax,cx		;ax = lh x
		xchg	bx,si		;swap lh disp, rh disp
		sub	cx,bp
		jmp	ESmokePtsFixed

;* short line draw (exception)

ShortESmokeLine:mov	al,ESmokeLMask1[bx]
		and	al,ESmokeRMask1[si]
		out	dx,al
		mov	al,ah
		stosb
		jmp	ESmokeEndLoop

;* bx = x table index
;* cx = number of lines
;* dx = addresses VGA_SEQ_MAPMSK
;* di -> screen (x = 0)

NextOSmokeLine:	push	bx
		push	cx

		mov	ax,RhsX[bx]
		mov	bp,ax
		mov	ax,LhsX[bx]
		mov	cx,ax

		mov	bx,cx
		and	bx,3		;lhs byte disp

		mov	si,bp
		and	si,3		;rhs byte disp

		sub	cx,bp
		ja	FixOSmokePoints	;error lh x > rh x ->
OSmokePtsFixed:	neg	cx
		add	cx,bx		;trim off lh side
		sub	cx,4
		sub	cx,si		;trim off rh side

		mov	bp,di		;save screen address

		shr	ax,1		;/2
		shr	ax,1		;/4
		add	di,ax		;y + x / 4

		sar	cx,1		;4 pixels / byte
		sar	cx,1		;cx = number of whole bytes to fill

		mov	ah,FillCol

		js	ShortOSmokeLine	;cx < 0 = short line ->

		mov	al,OSmokeLMask1[bx]
		out	dx,al
		mov	al,ah
		stosb

		mov	al,ODD_SMOKE1
		out	dx,al
		mov	al,ah
		rep	stosb

		mov	al,OSmokeRMask1[si]
		out	dx,al
		mov	al,ah
		stosb

OSmokeEndLoop:	mov	di,bp		;restore screen address
		pop	cx
		pop	bx
		add	bx,2		;next table index
		add	di,VGA_LINEADD	;y = y + 1
		
		dec	cx
		jz	SmokeFillExit
		jmp	NextESmokeLine

;* lh x > rh x error condition (exception)

FixOSmokePoints:mov	cx,ax		;cx = lh x
		xchg	cx,bp		;swap lh x, rh x
		mov	ax,cx		;ax = lh x
		xchg	bx,si		;swap lh disp, rh disp
		sub	cx,bp
		jmp	OSmokePtsFixed

;* short line draw (exception)

ShortOSmokeLine:mov	al,OSmokeLMask1[bx]
		and	al,OSmokeRMask1[si]
		out	dx,al
		mov	al,ah
		stosb
		jmp	OSmokeEndLoop

SmokeFillExit:	pop	es
		pop	si
		ret

;-----------------------------------
;* >>>>> SMOKE HATCH PATTERN 2 <<<<<
;-----------------------------------

;* bx = x table index
;* cx = number of lines
;* dx = addresses VGA_SEQ_MAPMSK
;* di -> screen (x = 0)

NextESmkLine:	push	bx
		push	cx

		mov	ax,RhsX[bx]
		mov	bp,ax
		mov	ax,LhsX[bx]
		mov	cx,ax

		mov	bx,cx
		and	bx,3		;lhs byte disp

		mov	si,bp
		and	si,3		;rhs byte disp

		sub	cx,bp
		ja	FixESmkPoints	;error lh x > rh x ->
ESmkPtsFixed:	neg	cx
		add	cx,bx		;trim off lh side
		sub	cx,4
		sub	cx,si		;trim off rh side

		mov	bp,di		;save screen address

		shr	ax,1		;/2
		shr	ax,1		;/4
		add	di,ax		;y + x / 4

		sar	cx,1		;4 pixels / byte
		sar	cx,1		;cx = number of whole bytes to fill

		mov	ah,FillCol

		js	ShortESmkLine	;cx < 0 = short line ->

		mov	al,ESmokeLMask2[bx]
		out	dx,al
		mov	al,ah
		stosb

		mov	al,EVEN_SMOKE2
		out	dx,al
		mov	al,ah
		rep	stosb

		mov	al,ESmokeRMask2[si]
		out	dx,al
		mov	al,ah
		stosb

ESmkEndLoop:	mov	di,bp		;restore screen address
		pop	cx
		pop	bx
		add	bx,2		;next table index
		add	di,VGA_LINEADD	;y = y + 1

		dec	cx
		jnz	NextOSmkLine
		jmp	SmkFillExit

;* lh x > rh x error condition (exception)

FixESmkPoints:	mov	cx,ax		;cx = lh x
		xchg	cx,bp		;swap lh x, rh x
		mov	ax,cx		;ax = lh x
		xchg	bx,si		;swap lh disp, rh disp
		sub	cx,bp
		jmp	ESmkPtsFixed

;* short line draw (exception)

ShortESmkLine:	mov	al,ESmokeLMask2[bx]
		and	al,ESmokeRMask2[si]
		out	dx,al
		mov	al,ah
		stosb
		jmp	ESmkEndLoop

;* bx = x table index
;* cx = number of lines
;* dx = addresses VGA_SEQ_MAPMSK
;* di -> screen (x = 0)

NextOSmkLine:	push	bx
		push	cx

		mov	ax,RhsX[bx]
		mov	bp,ax
		mov	ax,LhsX[bx]
		mov	cx,ax

		mov	bx,cx
		and	bx,3		;lhs byte disp

		mov	si,bp
		and	si,3		;rhs byte disp

		sub	cx,bp
		ja	FixOSmkPoints	;error lh x > rh x ->
OSmkPtsFixed:	neg	cx
		add	cx,bx		;trim off lh side
		sub	cx,4
		sub	cx,si		;trim off rh side

		mov	bp,di		;save screen address

		shr	ax,1		;/2
		shr	ax,1		;/4
		add	di,ax		;y + x / 4

		sar	cx,1		;4 pixels / byte
		sar	cx,1		;cx = number of whole bytes to fill

		mov	ah,FillCol

		js	ShortOSmkLine	;cx < 0 = short line ->

		mov	al,OSmokeLMask2[bx]
		out	dx,al
		mov	al,ah
		stosb

		mov	al,ODD_SMOKE2
		out	dx,al
		mov	al,ah
		rep	stosb

		mov	al,OSmokeRMask2[si]
		out	dx,al
		mov	al,ah
		stosb

OSmkEndLoop:	mov	di,bp		;restore screen address
		pop	cx
		pop	bx
		add	bx,2		;next table index
		add	di,VGA_LINEADD	;y = y + 1
		
		dec	cx
		jz	SmkFillExit
		jmp	NextESmkLine

;* lh x > rh x error condition (exception)

FixOSmkPoints:	mov	cx,ax		;cx = lh x
		xchg	cx,bp		;swap lh x, rh x
		mov	ax,cx		;ax = lh x
		xchg	bx,si		;swap lh disp, rh disp
		sub	cx,bp
		jmp	OSmkPtsFixed

;* short line draw (exception)

ShortOSmkLine:	mov	al,OSmokeLMask2[bx]
		and	al,OSmokeRMask2[si]
		out	dx,al
		mov	al,ah
		stosb
		jmp	OSmkEndLoop

SmkFillExit:	pop	es
		pop	si
		ret

VGA_SFill	ENDP

;----------------------------------------------------------------------------

;* VGA_CalcAddr - calculate screen address
;*
;* pass: bl = y (0 - 199)
;*       cx = x (0 - 319)
;* ret : di = screen address = y * 80 + x / 4
;* kill: ax, flags

VGA_CalcAddr	PROC	NEAR

		mov	al,bl
		xor	ah,ah
		shl	ax,1		;*2
		shl	ax,1		;*4
		shl	ax,1		;*8
		shl	ax,1   	     	;*16
		mov	di,ax
		shl	ax,1		;*32
		shl	ax,1		;*64
		add	di,ax		;*80
		mov	ax,cx
		shr	ax,1		;/2
		shr	ax,1		;/4
		add	di,ax
		ret

VGA_CalcAddr	ENDP

;----------------------------------------------------------------------------

;* VGA_PrtC1 - print character type 1 (7 by 9)
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
;*       VGA_SEQ_MAPMSK
;* note: PrtCl is rounded down to 4 pixel steps (effectively 80 columns).
;*       No checks are made for PrtLn and PrtCl being off screen.

VGA_PrtC1	PROC	FAR

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
		call	VGA_CalcAddr 	;di -> screen

		mov	ax,WorkScrPtr
		mov	es,ax		

		mov	bx,OFFSET FlipNibble
		mov	cx,9
		mov	bp,WORD PTR PrintOver

		SLCTREG	VGA_SEQ,VGA_SEQ_MAPMSK

PrtC1Loop:	test	bp,bp		;print "over" mode?
		jnz	PrtC1Over	;yes ->

		mov	al,00fh		;set all pixels to background colour
		out	dx,al
		mov	al,BackCol
		stosb
		stosb

		sub	di,2		;restore screen address

PrtC1Over:	lodsb			;fetch char pattern data
		mov	ah,al

		shr	al,1		;require data in high nibble
		shr	al,1
		shr	al,1
		shr	al,1
		xlat			;reverse bits
		out	dx,al
		mov	al,ForeCol
		stosb

		xchg	al,ah
		and	al,00fh		;require data in low nibble
		xlat			;reverse bits
		out	dx,al
		mov	al,ah
		stosb

		add	di,VGA_LINEADD-2;next line
		loop	PrtC1Loop

PrtC1Exit:	add	PrtCl,8		;next column

		pop	es
		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax

		ret

VGA_PrtC1	ENDP

;----------------------------------------------------------------------------

;* VGA_PrtC2 - print character type 2 (3 by 5)
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
;*       VGA_SEQ_MAPMSK
;* note: PrtCl is rounded down to 4 pixel steps (effectively 80 columns).
;*       No checks are made for PrtLn and PrtCl being off screen.
;*       Optimized for speed (inline code).

VGA_PrtC2	PROC	FAR

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
		call	VGA_CalcAddr 	;di -> screen

		mov	ax,WorkScrPtr
		mov	es,ax		

		mov	bx,OFFSET FlipNibble

		mov	cl,ForeCol
		mov	ch,BackCol

		mov	bp,VGA_LINEADD-1

		SLCTREG	VGA_SEQ,VGA_SEQ_MAPMSK

		mov	al,PrintOver
		test	al,al	     	;print over?
		jz	VGA_PrtC2Norm	;no ->

;* inline print

		REPT	5

		lodsb			;al = char pattern data
		and	al,00fh		;clear unwanted bits
		xlat			;reverse bits
		out	dx,al		;set foreground pixels to update
		mov	al,cl		;fetch foreground colour
		stosb			;set foreground pixels

		add	di,bp		;next line

		ENDM

		jmp	VGA_PrtC2Com

;* inline print

VGA_PrtC2Norm:	REPT	5

		mov	al,00fh		;set all pixels to background colour
		out	dx,al
		mov	al,ch		;fetch background colour
		stosb			;set background pixels

		dec	di		;restore screen address

		lodsb			;al = char pattern data
		and	al,00fh		;clear unwanted bits
		xlat			;reverse bits
		out	dx,al		;set foreground pixels to update
		mov	al,cl		;fetch foreground colour
		stosb			;set foreground pixels

		add	di,bp		;next line

		ENDM

VGA_PrtC2Com:	add	PrtCl,4		;next column

		pop	es
		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax

		ret

VGA_PrtC2	ENDP

;----------------------------------------------------------------------------

;* VGA_PrtC3 - print character type 3 (5 by 9)
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
;*       VGA_SEQ_MAPMSK
;* note: PrtCl is rounded down to 2 pixel steps.
;*       No checks are made for PrtLn and PrtCl being off screen.

VGA_PrtC3	PROC	FAR

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
		call	VGA_CalcAddr 	;di -> screen

		mov	ax,WorkScrPtr
		mov	es,ax		

		mov	bx,OFFSET FlipNibble
		mov	cx,9

;* bp flags: b0 = 1 = print over
;*           b1 = 1 = 2 pixel offset

		mov	bp,PrtCl
		and	bp,0010b
		or	bp,WORD PTR PrintOver

		SLCTREG	VGA_SEQ,VGA_SEQ_MAPMSK

PrtC3Loop:	test	bp,0001b	;print "over" mode?
		jnz	PrtC3Over	;yes ->

		test	bp,0010b	;2 pixel offset?
		jz	@F		;no ->

		mov	al,00ch		;set all pixels to background colour
		out	dx,al
		mov	al,BackCol
		stosb
		mov	al,00fh
		out	dx,al
		mov	al,BackCol
		stosb
		
		sub	di,2		;restore screen address
		
		jmp	PrtC3Over

@@:  		mov	al,00fh		;set all pixels to background colour
		out	dx,al
		mov	al,BackCol
		stosb
		mov	al,003h
		out	dx,al
		mov	al,BackCol
		stosb
		
		sub	di,2		;restore screen address

PrtC3Over:	lodsb			;fetch char pattern data
		test	bp,0010b	;2 pixel offset?
		jz	@F		;no ->
		shr	al,1
		shr	al,1
@@:		mov	ah,al

		shr	al,1		;require data in high nibble
		shr	al,1
		shr	al,1
		shr	al,1
		xlat			;reverse bits
		out	dx,al
		mov	al,ForeCol
		stosb

		xchg	al,ah
		and	al,00fh		;require data in low nibble
		xlat			;reverse bits
		out	dx,al
		mov	al,ah
		stosb

		add	di,VGA_LINEADD-2;next line
		loop	PrtC3Loop

PrtC3Exit:	add	PrtCl,6		;next column

		pop	es
		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax

		ret

VGA_PrtC3	ENDP

;----------------------------------------------------------------------------

;* VGA_SSprite - shifted sprite
;*
;* pass: si -> logical sprite data (x, y, ptr)
;* ret : cf = 0 = sprite not visible
;*       cf = 1 = sprite visible
;* kill: assume all (except cf)
;*       VGA_SEQ_MAPMSK
;* note: x co-ord is rounded to even pixel.

SSpriteOut:	pop	ds		
		pop	ax
		pop	ax
		clc			;exception - sprite not visible
		jmp	SSpriteExit

VGA_SSprite	PROC	FAR

		push	ds
		push	es

		SLCTREG	VGA_SEQ,VGA_SEQ_MAPMSK

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

		mov	si,[si]

;* fetch physical data

		lodsw
		mov	cx,ax		;width in bytes (/4)
		lodsw
		mov	dx,ax		;depth
		lodsw
		mov	bx,ax		;size
		push	ax
		lodsw	
		add	bp,ax		;x offset
		lodsw
		add	di,ax		;y offset
		lodsw
		push	ax		;mask colour

;* if 2 pixel offset then use shifted sprite

		test	bp,0010b	;2 pixel offset
		jz	OffsetOk	;no, use unshifted sprite ->

		inc	cx		;width + 1

		shl	bx,1		;*2
		shl	bx,1		;size * 4
		add	si,bx		;si -> shifted data
		
		pop	bx
		pop	ax
		add	ax,dx	    	;modify size on stack
		push	ax
		push	bx

OffsetOk:	sar	bp,1
		sar	bp,1		;x byte offset

;* cx = width (bytes)
;* dx = depth
;* bp = x byte offset
;* di = y
;*
;* ds:si -> sprite mask / pattern data
;*
;* stack: ds
;*        es
;*        size
;* (top): mask col

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
;* ds:si -> sprite mask / pattern data
;*
;* stack: ds
;*        es
;*        size
;* (top): mask col

ContMSprite:	shl	di,1		;*2
		shl	di,1		;*4
		shl	di,1		;*8
		shl	di,1		;*16
		mov	ax,di
		shl	di,1		;*32
		shl	di,1		;*64
		add	di,ax		;y * 80
		add	di,bp		;y * 80 + x byte offset

		mov	bp,VGA_LINEADD
		sub	bp,cx		;screen add on

;* calc computed jump for width

		mov	ax,VGA_LINEADD
		sub	ax,cx
		mov	cx,ax
		shl	ax,1		;*2
		shl	ax,1		;*4
		shl	ax,1		;*8
		add	ax,cx		;*9
		lea	cx,WSpriteBytes
		add	cx,ax		;cx = computed jump wrt width
		
		pop	ax   		;mask colour
		mov	dh,al

;* bx = sprite data add on
;* cx = width (computed jump)
;* dl = depth
;* dh = mask colour	
;* bp = screen address add on
;*
;* ds:si -> sprite mask / pattern data
;* es:di -> screen
;*
;* stack: ds
;*        es
;* (top)  size

;* map 0

		push	dx
		mov	dx,VGA_SEQ+1
		mov	al,0001b
		out	dx,al
		pop	dx

		call	WriteSprite

		pop	ax		;size
		add	si,ax
		push	ax
		
;* map 1

		push	dx
		mov	dx,VGA_SEQ+1
		mov	al,0010b
		out	dx,al
		pop	dx

		call	WriteSprite

		pop	ax		;size
		add	si,ax
		push	ax
	
;* map 2

		push	dx
		mov	dx,VGA_SEQ+1
		mov	al,0100b
		out	dx,al
		pop	dx

		call	WriteSprite

		pop	ax		;size
		add	si,ax
	
;* map 3

		push	dx
		mov	dx,VGA_SEQ+1
		mov	al,1000b
		out	dx,al
		pop	dx

		call	WriteSprite

SSpriteDone:	stc			;sprite visible

		ASSUME	DS:DATA

SSpriteExit:   	pop	es
		pop	ds
		ret

VGA_SSprite	ENDP

;----------------------------------------------------------------------------

;* VGA_MSprite - masked sprite
;*
;* pass: si -> logical sprite data (x, y, ptr)
;* ret : nothing
;* kill: assume all

VGA_MSprite	PROC	FAR

		push	ds
		push	es

		SLCTREG	VGA_SEQ,VGA_SEQ_MAPMSK

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

		mov	si,[si]

;* fetch physical data

		lodsw
		mov	cx,ax		;width in bytes (/4)
		lodsw
		mov	dx,ax		;depth
		lodsw
		push	ax		;size

		add	si,4		;skip over x, y offsets

		lodsw
		push	ax		;mask col

		sar	bp,1
		sar	bp,1		;x byte offset

		xor	bx,bx		;add on = 0

		jmp	ContMSprite

		ASSUME	DS:DATA

VGA_MSprite	ENDP

;----------------------------------------------------------------------------

;* VGA_BSprite - use MSprite data as SSprite
;*
;* pass: si -> logical sprite data (x, y, ptr)
;* ret : cf = 0 = sprite not visible
;*       cf = 1 = sprite visible
;* kill: assume all (except cf)
;*
;* note: x co-ord is rounded to byte boundary

VGA_BSprite	PROC	FAR

		push	ds
		push	es

		SLCTREG	VGA_SEQ,VGA_SEQ_MAPMSK

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

		mov	si,[si]

;* fetch physical data

		lodsw
		mov	cx,ax		;width in bytes (/4)
		lodsw
		mov	dx,ax		;depth
		lodsw
		mov	bx,ax		;size
		push	ax
		lodsw	
		add	bp,ax		;x offset
		lodsw
		add	di,ax		;y offset
		lodsw
		push	ax		;mask colour

		sar	bp,1
		sar	bp,1		;x byte offset

		jmp	ContBSprite

		ASSUME	DS:DATA

VGA_BSprite	ENDP
	
;----------------------------------------------------------------------------

;* WriteSprite - write sprite data to screen
;*
;* pass: bx = sprite data add on
;*       cx = width (computed jump)
;*       dl = depth
;*       dh = mask colour
;*       bp = screen address add on
;*       ds:si -> sprite mask / pattern data
;*       es:di -> screen
;*       VGA_SEQ_MAPMSK = selected bit plane
;* ret : nothing
;* kill: flags

WriteSprite	PROC	NEAR

		push	dx
		push	si
		push	di

		mov	ah,dh
		xor	dh,dh

WSpriteLoop:	jmp	cx		;jump wrt width
		
;* this macro generates 9 bytes of code each iteration

WSpriteBytes:	REPT	80

		lodsb			;fetch mask / pattern data
		cmp	al,ah		;mask or pattern data?
		je	@F		;mask ->
		mov	es:[di],al	;write pattern
@@:		inc	di		;next screen address

		ENDM

		add	si,bx		;next mask / pattern data
		add	di,bp		;next screen line
		dec	dx		;any more lines?
		jz	WSpriteDone	;no ->
		jmp	WSpriteLoop

WSpriteDone:	pop	di
		pop	si
		pop	dx
		ret
	
WriteSprite	ENDP

;----------------------------------------------------------------------------

;* VGA_QSprite - quick sprite
;*
;* pass: si -> logical sprite data (x, y, ptr)
;* ret : nothing
;* kill: assume all

VGA_QSprite	PROC	FAR

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
		mov	ax,SEG QSpriteID
		mov	ds,ax

		ASSUME	DS:SEG QSpriteID

;* fetch ptr to physical data from list

		mov	si,[si]

;* fetch physical data

		lodsw
		mov	bx,ax		;width in bytes (/4)
		lodsw
		mov	dx,ax		;depth

		add	si,2		;skip size

		sar	bp,1
		sar	bp,1		;x byte offset

		shl	di,1		;*2
		shl	di,1		;*4
		shl	di,1		;*8
		shl	di,1		;*16
		mov	ax,di
		shl	di,1		;*32
		shl	di,1		;*64
		add	di,ax		;y * 80
		add	di,bp		;y * 80 + x byte offset

		mov	bp,VGA_LINEADD
		sub	bp,bx		;screen add on

		shr	bx,1		;/2 for word width

		mov	ah,dl		;depth

		SLCTREG	VGA_SEQ,VGA_SEQ_MAPMSK

;* ah = depth
;* bx = width in words
;* dx = addresses VGA_SEQ_MAPMSK
;* bp = screen address add on
;*
;* ds:si -> sprite data
;* es:di -> screen

		mov	al,0001b	;map 0
		out	dx,al
		mov	al,ah		;al = depth
		push	di		;store start screen addr
QSLoop1:	mov	cx,bx		;cx = width
		rep	movsw		;copy sprite data
		add	di,bp		;next line
		dec	al		;any more lines?
		jnz	QSLoop1		;yes ->
		pop	di		;restore start screen addr

		mov	al,0010b	;map 1
		out	dx,al
		mov	al,ah		;al = depth
		push	di		;store start screen addr
QSLoop2:  	mov	cx,bx		;cx = width
		rep	movsw		;copy sprite data
		add	di,bp		;next line
		dec	al		;any more lines?
		jnz	QSLoop2		;yes ->
		pop	di		;restore start screen addr

		mov	al,0100b	;map 2
		out	dx,al
		mov	al,ah		;al = depth
		push	di		;store start screen addr
QSLoop3:	mov	cx,bx		;cx = width
		rep	movsw		;copy sprite data
		add	di,bp		;next line
		dec	al		;any more lines?
		jnz	QSLoop3		;yes ->
		pop	di		;restore start screen addr

		mov	al,1000b	;map 3
		out	dx,al
		mov	al,ah		;al = depth
QSLoop4:	mov	cx,bx		;cx = width
		rep	movsw		;copy sprite data
		add	di,bp		;next line
		dec	al		;any more lines?
		jnz	QSLoop4		;yes ->

		ASSUME	DS:DATA
		
		pop	es
		pop	ds
		ret

VGA_QSprite	ENDP

;----------------------------------------------------------------------------

;* VGA_InitSS - initialize shifted sprites
;*
;* pass: SSpriteList
;* ret : nothing
;* kill: assume all
;*
;* note: The WorkScreen is used as a buffer.
;*       Refer to SS_VGA_1.ASM for SSprite data formats.

SS_WIDTH	EQU	0
SS_DEPTH	EQU	2
SS_SIZE		EQU	4
SS_XOFF		EQU	6
SS_YOFF		EQU	8
SS_MASK		EQU	10
SS_DATA		EQU	12

VGA_InitSS	PROC	FAR

		push	ds
		push	es

	     	mov	ax,SEG SSpriteList
		mov	ds,ax
		mov	es,ax

		ASSUME	DS:SEG SSpriteList

		xor	bx,bx

InitSSLoop:  	mov	si,SSpriteList[bx]	
		cmp	si,-1		;end of list?
		je	InitSSExit	;yes ->

		push	bx		;store list index

;* copy unshifted sprite data to shifted sprite buffer with 2 pixel offset

		push	si		;store sprite ptr

		mov	bx,[si+SS_WIDTH]
		mov	cx,[si+SS_SIZE]
		mov	dx,[si+SS_DEPTH]
		add	si,SS_DATA
		shl	cx,1		;*2
		shl	cx,1		;size * 4
		mov	di,si
		add	di,cx		;di -> shifted sprite buffer

		shl	bx,1		;width * 2 = num words width

		add	di,2		;add 2 pixel offset

;* bx = width (words)
;* dx = depth
;* si -> unshifted sprite data
;* di -> shifted sprite buffer + 2 pixel offset

CopySSLoop:	mov	cx,bx
		rep	movsw		;copy one line
		add	di,4		;next line + 2 pixel offset
		dec	dx		;any more lines?
		jnz	CopySSLoop	;yes ->
		
		pop	si		;restore sprite ptr

;* interleave unshifted sprite data

		push	si		;store sprite ptr

		mov	cx,[si+SS_SIZE]
		add	si,SS_DATA
		call	ConvertVGAData

		pop	si		;restore sprite ptr

;* interleave shifted sprite data

		mov	cx,[si+SS_SIZE]
		mov	dx,[si+SS_DEPTH]

		add	si,SS_DATA
		mov	ax,cx
		shl	ax,1		;*2
		shl	ax,1		;size * 4
		add	si,ax		;si -> shifted sprite data

		add	cx,dx		;modify size

		call	ConvertVGAData

		pop	bx		;restore list index

		add	bx,2  		;next sprite
		jmp	InitSSLoop

		ASSUME	DS:DATA

InitSSExit:	pop	es
		pop	ds

		ret

VGA_InitSS	ENDP

;----------------------------------------------------------------------------

;* VGA_InitMS - initialize masked sprites
;*
;* pass: MSpriteList
;* ret : nothing
;* kill: assume all
;*
;* note: The WorkScreen is used as a buffer.
;*       Refer to MS_VGA_1.ASM for MSprite data formats.

MS_WIDTH	EQU	0
MS_DEPTH	EQU	2
MS_SIZE		EQU	4
MS_XOFF		EQU	6
MS_YOFF		EQU	8
MS_MASK		EQU	10
MS_DATA		EQU	12

VGA_InitMS	PROC	FAR

		push	ds

		mov	ax,SEG MSpriteList
		mov	ds,ax

		ASSUME	DS:SEG MSpriteList

	     	xor	bx,bx

InitMSLoop:	mov	si,MSpriteList[bx]	
		cmp	si,-1		;end of list?
		je	InitMSExit	;yes ->

		push	bx
		mov	cx,[si+MS_SIZE]
		add	si,MS_DATA
		call	ConvertVGAData
		pop	bx

		add	bx,2  		;next sprite
		jmp	InitMSLoop

		ASSUME	DS:DATA

InitMSExit:	pop	ds

		ret

VGA_InitMS	ENDP

;----------------------------------------------------------------------------

;* VGA_InitQS - initialize quick sprites
;*
;* pass: QSpriteList
;* ret : nothing
;* kill: assume all
;* note: The WorkScreen is used as a buffer.
;*       Refer to QS_VGA_1.ASM for QSprite data formats.

QS_WIDTH	EQU	0
QS_DEPTH	EQU	2
QS_SIZE		EQU	4
QS_DATA		EQU	6

VGA_InitQS	PROC	FAR

		push	ds

	     	mov	ax,SEG QSpriteList
		mov	ds,ax

		ASSUME	DS:SEG QSpriteList

		xor	bx,bx

InitQSLoop:	mov	si,QSpriteList[bx]	
		cmp	si,-1		;end of list?
		je	InitQSExit	;yes ->

		push	bx
		mov	cx,[si+QS_SIZE]
		add	si,QS_DATA
		call	ConvertVGAData
		pop	bx

		add	bx,2  		;next sprite
		jmp	InitQSLoop

		ASSUME	DS:DATA

InitQSExit:	pop	ds

		ret

VGA_InitQS	ENDP

;----------------------------------------------------------------------------

;* ConvertVGAData - convert linear data to interleaved data
;*
;* pass: cx = size (of one bit plane)
;*       ds:si -> sprite pattern
;* ret : nothing
;* kill: assume all

ConvertVGAData	PROC	NEAR

		push	ds
		push	es

		push	ds

		mov	ax,SEG WorkScreen
		mov	es,ax
		xor	di,di		;es:di -> start of WorkScreen

;-----------------
;* sort map 0 data
;-----------------

		mov	bx,0		;map 0

		push	cx		;store size
ConvLoop0:	mov	al,[si+bx]	;fetch map data
		stosb			;store map data
		add	bx,4		;next map data
		loop	ConvLoop0
		pop	cx		;restore size

;-----------------
;* sort map 1 data
;-----------------

		mov	bx,1		;map 1

		push	cx		;store size
ConvLoop1:	mov	al,[si+bx]	;fetch map data
		stosb			;store map data
		add	bx,4		;next map data
		loop	ConvLoop1
		pop	cx		;restore size

;-----------------
;* sort map 2 data
;-----------------

		mov	bx,2		;map 2

		push	cx		;store size
ConvLoop2:	mov	al,[si+bx]	;fetch map data
		stosb			;store map data
		add	bx,4		;next map data
		loop	ConvLoop2
		pop	cx		;restore size

;-----------------
;* sort map 3 data
;-----------------

		mov	bx,3		;map 3

		push	cx		;store size
ConvLoop3:	mov	al,[si+bx]	;fetch map data
		stosb			;store map data
		add	bx,4		;next map data
		loop	ConvLoop3
		pop	cx		;restore size
	
		pop	es

		mov	di,si		;es:di -> sprite pattern

		mov	ax,SEG WorkScreen
		mov	ds,ax
		xor	si,si		;ds:si -> start of WorkScreen

		shl	cx,1	 	;size * 2 = num words
		
		rep	movsw		;copy interleaved data to sprite data

		pop	es
		pop	ds

		ret

ConvertVGAData	ENDP

;----------------------------------------------------------------------------

;* VGA_BFill - fast block fill
;*
;* pass: bx = width (1 - 40)
;*       cx = x start (0 - 312 step 8)
;*       dx = depth
;*       di = y start
;*	 FillCol = physical colour
;* ret : nothing
;* kill: assume all
;*       VGA_SEQ_MAPMSK

VGA_BFill	PROC	FAR

		push	es
		mov	ax,WorkScrPtr
		mov	es,ax

		mov	bp,dx

		SETREGV	VGA_SEQ,VGA_SEQ_MAPMSK,1111b

		shl	di,1		;*2
		shl	di,1		;*4
		shl	di,1		;*8
		shl	di,1		;*16
		mov	ax,di
		shl	di,1		;*32
		shl	di,1		;*64
		add	di,ax		;y * 80

		shr	cx,1
		shr	cx,1		;(4 pixels / byte)
		add	di,cx		;y * 80 + x / 4

		shl	bx,1		;line width (bytes)

		mov	si,VGA_LINEADD
		sub	si,bx		;si = line add on

		mov	ax,WORD PTR FillCol

		shr	bx,1		;num words

VGA_BFillLoop:	mov	cx,bx		;width (words)
		rep	stosw		;fill line
		add	di,si		;next line
		dec	bp
		jnz	VGA_BFillLoop

		pop	es	
		ret

VGA_BFill	ENDP
	
;----------------------------------------------------------------------------

;* VGA_SaveMouse - save mouse background into MouseHouse[]
;*
;* pass: cx = x co-ord of top lh corner of mouse
;*       bx = y co-ord of top lh corner of mouse
;* ret : MouseHouse[]
;* kill: assume all
;*       VGA_CTRL_RDMAP

VGA_SaveMouse	PROC	FAR

		push	ds
		push	es

		mov	ax,SEG MouseHouse
		mov	es,ax
		mov	ax,WorkScrPtr
		mov	ds,ax

		call	VGA_CalcAddr
		mov	si,di		;ds:si -> mouse background

		mov	di,OFFSET MouseHouse

		mov	ah,0	  	;read map

		SLCTREG VGA_CTRL,VGA_CTRL_RDMAP

VGA_SvMseMapLp:	mov	al,ah
		out	dx,al

		mov	bx,si

		mov	bp,16		;16 lines
VGA_SvMseLoop1:	mov	cx,5		;5 bytes wide (16 pixels + shift byte)
VGA_SvMseLoop2:	cmp	si,VGA_LINEADD*200
		jae	VGA_SvMseExit	;screen ptr outside screen limits ->
		movsb			;copy byte
		loop	VGA_SvMseLoop2	;next byte
		add	si,VGA_LINEADD-5
		dec	bp		;next line
		jnz	VGA_SvMseLoop1

VGA_SvMseExit:	mov	si,bx

		inc	ah		;next plane
		cmp	ah,4		;done all planes yet?
		jne	VGA_SvMseMapLp	;no ->

		pop	es
		pop	ds
		ret

VGA_SaveMouse	ENDP

;----------------------------------------------------------------------------

;* VGA_LoadMouse - load mouse background from MouseHouse[]
;*
;* pass: cx = x co-ord of top lh corner of mouse
;*       bx = y co-ord of top lh corner of mouse
;* 	 MouseHouse[]
;* ret : nothing
;* kill: assume all
;*       VGA_SEQ_MAPMSK

VGA_LoadMouse	PROC	FAR

		push	ds
		push	es

		mov	ax,WorkScrPtr
		mov	es,ax
		mov	ax,SEG MouseHouse
		mov	ds,ax

		call	VGA_CalcAddr	;es:di -> mouse background

		mov	si,OFFSET MouseHouse

		mov	ah,0001b	;write map

		SLCTREG	VGA_SEQ,VGA_SEQ_MAPMSK

VGA_LdMseMapLp:	mov	al,ah
		out	dx,al

		mov	bx,di

		mov	bp,16		;16 lines
VGA_LdMseLoop1:	mov	cx,5		;5 bytes wide (16 pixels + shift byte)
VGA_LdMseLoop2:	cmp	di,VGA_LINEADD*200
		jae	VGA_LdMseExit	;screen ptr outside screen limits ->
		movsb			;copy byte
		loop	VGA_LdMseLoop2	;next byte
		add	di,VGA_LINEADD-5
		dec	bp		;next line
		jnz	VGA_LdMseLoop1

VGA_LdMseExit:	mov	di,bx

		shl	ah,1		;next plane
		test	ah,10000b	;done all planes yet?
		jz	VGA_LdMseMapLp	;no ->

		pop	es
		pop	ds
		ret

VGA_LoadMouse	ENDP

;----------------------------------------------------------------------------

;* VGA_SaveScreen - copy work screen to (WorkScreen[] + CopyScreen[]) combined
;*
;* pass: WorkScrPtr
;* ret : (WorkScreen[] + CopyScreen[])
;* kill: assume all
;*       VGA_CTRL_RDMAP

VGA_SaveScreen	PROC	FAR

		push	ds
		push	es

		mov	ax,SEG WorkScreen
		mov	es,ax
		mov	ax,WorkScrPtr
		mov	ds,ax

		SLCTREG VGA_CTRL,VGA_CTRL_RDMAP

		mov	di,OFFSET WorkScreen

		mov	al,0		;map 0
		out	dx,al
		mov	cx,200*VGA_LINEADD/2
		xor	si,si
		rep	movsw

		mov	al,1		;map 1
		out	dx,al
		mov	cx,200*VGA_LINEADD/2
		xor	si,si
		rep	movsw

		mov	al,2		;map 2
		out	dx,al
		mov	cx,200*VGA_LINEADD/2
		xor	si,si
		rep	movsw

		mov	al,3		;map 3
		out	dx,al
		mov	cx,200*VGA_LINEADD/2
		xor	si,si
		rep	movsw

		pop	es
		pop	ds
		ret

VGA_SaveScreen	ENDP
				
;----------------------------------------------------------------------------

;* VGA_LoadScreen - copy (WorkScreen[] + CopyScreen[]) combined to work screen
;*
;* pass: (WorkScreen[] + CopyScreen[])
;*       WorkScrPtr
;* ret : work screen
;* kill: assume all
;*       VGA_SEQ_MAPMSK

VGA_LoadScreen	PROC	FAR

		push	ds
		push	es

		mov	ax,WorkScrPtr
		mov	es,ax
		mov	ax,SEG WorkScreen
		mov	ds,ax

		SLCTREG	VGA_SEQ,VGA_SEQ_MAPMSK

		mov	si,OFFSET WorkScreen

		mov	al,0001b    	;map 0
		out	dx,al
		mov	cx,200*VGA_LINEADD/2
		xor	di,di
		rep	movsw

		mov	al,0010b    	;map 1
		out	dx,al
		mov	cx,200*VGA_LINEADD/2
		xor	di,di
		rep	movsw

		mov	al,0100b    	;map 2
		out	dx,al
		mov	cx,200*VGA_LINEADD/2
		xor	di,di
		rep	movsw

		mov	al,1000b    	;map 3
		out	dx,al
		mov	cx,200*VGA_LINEADD/2
		xor	di,di
		rep	movsw

		pop	es
		pop	ds
		ret
	
VGA_LoadScreen	ENDP

;----------------------------------------------------------------------------

;* VGA_HFill - fill 'Z' section of horizon
;*
;* pass: cx = num lines
;*       si = y min
;*       HrznXMin
;*       HrznXMax
;*       HrznLhsCol
;*       HrznRhsCol
;* ret : nothing
;* kill: assume all
;*       VGA_SEQ_MAPMSK

VGA_HFill	PROC	FAR

		push	es
		mov	ax,WorkScrPtr
		mov	es,ax

		SLCTREG	VGA_SEQ,VGA_SEQ_MAPMSK

		shl	si,1		;*2 LhsX[] index
		
		mov	di,si
		shl	di,1		;*4
		shl	di,1		;*8
		shl	di,1		;*16
		mov	ax,di
		shl	di,1		;*32
		shl	di,1		;*64
		add	di,ax		;y * 80

		mov	ax,HrznXMin
		shr	ax,1		;/2
		shr	ax,1		;/4
		add	di,ax		;y * 80 + x min / 4

		add	si,OFFSET LhsX	;si -> LhsX[y min]

		mov	bx,OFFSET HrznMask

;* bx -> HrznMask
;* cx = num lines
;* dx = addresses VGA_SEQ_MAPMSK
;* si -> LhsX[y min]
;* di -> screen
 
		mov	al,1111b
		out	dx,al		;set mask for solid fill

VGA_HFillLp:	push	cx
		push	di

		lodsw			;fetch x value
		mov	bp,ax		;store x value

		sub	ax,HrznXMin	;x - x min
		shr	ax,1		;/2
		shr	ax,1		;(x - x min) / 4
		inc	ax		;(x - x min) / 4 + 1
		mov	cx,ax		;cx = num whole bytes to fill

		mov	al,HrznLhsCol
		rep	stosb	  	;fill solid lhs

		dec	di		;move back to screen byte to be masked

		mov	ax,bp
		and	ax,3		;x offset within screen byte
		xlat			;fetch mask wrt x offset
		out	dx,al		;set mask

		mov	al,HrznRhsCol
		stosb			;mask rhs colour into middle byte

		mov	al,1111b
		out	dx,al		;set mask for solid fill

		mov	ax,HrznXMax
		sub	ax,bp		;x max - x
		shr	ax,1		;/2
		shr	ax,1		;(x max - x) / 4
		mov	cx,ax		;cx = num whole bytes to fill

		mov	al,HrznRhsCol
		rep	stosb	  	;fill solid rhs

		pop	di
		pop	cx
		add	di,VGA_LINEADD
		loop	VGA_HFillLp

		pop	es	
		ret

VGA_HFill	ENDP

;----------------------------------------------------------------------------

;* SetDACBlock - update a block of DAC colour registers
;*
;* pass: al = first colour to update
;*       cx = number of colours to update
;*       ds:si -> red-green-blue values (gun values = 0 .. 63)
;* ret : nothing
;* kill: al, cx, dx, si, flags

SetDACBlock	PROC	FAR

;* set start colour

		mov	dx,VGA_PEL_WRITE
		out	dx,al

;* update n colours

		mov	dx,VGA_PEL_DATA

@@:		lodsb			;red
		out	dx,al
		lodsb			;green
		out	dx,al
		lodsb			;blue
		out	dx,al
		
		loop	@B

		ret

SetDACBlock	ENDP

;----------------------------------------------------------------------------

;* ReadDACBlock - read a block of DAC colour registers
;*
;* pass: al = first colour to read
;*       cx = number of colours to read
;*       es:di -> red-green-blue data buffer
;* ret : nothing
;* kill: al, cx, dx, di, flags

ReadDACBlock	PROC	FAR

;* set start colour

		mov	dx,VGA_PEL_READ
		out	dx,al

;* read n colours

		mov	dx,VGA_PEL_DATA

@@:    		in	al,dx		;red
		stosb
		in	al,dx		;green
		stosb
		in	al,dx		;blue
		stosb

		loop	@B

		ret

ReadDACBlock	ENDP

;----------------------------------------------------------------------------

;* FadePalette - fade RGB values
;*
;* pass: VGA_RGB_Data[]
;* ret : VGA_RGB_Fade[]
;*       FadeFlag
;* kill: assume all

FadePalette	PROC	FAR  ;formerly NEAR

		push	ds
		push	es

		push	FadeParams3
		push	FadeParams3+2
		push	FadeStart3
		push	FadeCount3

		push	FadeParams2
		push	FadeParams2+2
		push	FadeStart2
		push	FadeCount2

		mov	bl,FadeLevel1
		mov	bh,FadeRCol1
		mov	dl,FadeGCol1
		mov	dh,FadeBCol1

		mov	ax,FadeStart1
		mov	bp,FadeCount1

		mov	cx,SEG VGA_RGB_Data
		mov	ds,cx
		mov	es,cx

;* copy current palette data

		mov	si,OFFSET VGA_RGB_Data
		mov	di,OFFSET VGA_RGB_Fade

		mov	cx,256*3/2
		rep	movsw

;----------------
;* palette fade 1
;----------------

;* skip fade if fade level = 0

		test	bl,bl		;fade level = 0?
		jz	FadeDone1	;yes ->

;* calc ptr to start of fade range

		mov	si,OFFSET VGA_RGB_Fade
		REPT	3
		add	si,ax
		ENDM

;* fade range of colours

FadeLoop1:	mov	al,bh		;new R
		sub	al,[si]		;new R - old R
		ABSV	al		;al = abs(delta), ah = sign(delta)
		mov	cl,ah
		mul	bl		;(new R - old R) * fade
		shl	ax,1		;frac adjust
		shl	al,1		;expose 1/2 bit
		ROUNDUP	ah
		xor	ah,cl		;restore sign
		sub	ah,cl
		add	[si],ah		;(new R - old R) * fade + old R
		inc	si		;next col

		mov	al,dl		;new G
		sub	al,[si]		;new G - old G
		ABSV	al		;al = abs(delta), ah = sign(delta)
		mov	cl,ah
		mul	bl		;(new G - old G) * fade
		shl	ax,1		;frac adjust
		shl	al,1		;expose 1/2 bit
		ROUNDUP	ah
		xor	ah,cl		;restore sign
		sub	ah,cl
		add	[si],ah		;(new G - old G) * fade + old G
		inc	si		;next col

		mov	al,dh		;new B
		sub	al,[si]		;new B - old B
		ABSV	al		;al = abs(delta), ah = sign(delta)
		mov	cl,ah
		mul	bl		;(new B - old B) * fade
		shl	ax,1		;frac adjust
		shl	al,1		;expose 1/2 bit
		ROUNDUP	ah
		xor	ah,cl		;restore sign
		sub	ah,cl
		add	[si],ah		;(new B - old B) * fade + old B
		inc	si		;next col

		dec	bp
		jnz	FadeLoop1

FadeDone1:	pop	bp
		pop	ax
		pop	dx
		pop	bx

;----------------
;* palette fade 2
;----------------

;* skip fade if fade level = 0

		test	bl,bl		;fade level = 0?
		jz	FadeDone2	;yes ->

;* calc ptr to start of fade range

		mov	si,OFFSET VGA_RGB_Fade
		REPT	3
		add	si,ax
		ENDM

;* fade range of colours

FadeLoop2:	mov	al,bh		;new R
		sub	al,[si]		;new R - old R
		ABSV	al		;al = abs(delta), ah = sign(delta)
		mov	cl,ah
		mul	bl		;(new R - old R) * fade
		shl	ax,1		;frac adjust
		shl	al,1		;expose 1/2 bit
		ROUNDUP	ah
		xor	ah,cl		;restore sign
		sub	ah,cl
		add	[si],ah		;(new R - old R) * fade + old R
		inc	si		;next col

		mov	al,dl		;new G
		sub	al,[si]		;new G - old G
		ABSV	al		;al = abs(delta), ah = sign(delta)
		mov	cl,ah
		mul	bl		;(new G - old G) * fade
		shl	ax,1		;frac adjust
		shl	al,1		;expose 1/2 bit
		ROUNDUP	ah
		xor	ah,cl		;restore sign
		sub	ah,cl
		add	[si],ah		;(new G - old G) * fade + old G
		inc	si		;next col

		mov	al,dh		;new B
		sub	al,[si]		;new B - old B
		ABSV	al		;al = abs(delta), ah = sign(delta)
		mov	cl,ah
		mul	bl		;(new B - old B) * fade
		shl	ax,1		;frac adjust
		shl	al,1		;expose 1/2 bit
		ROUNDUP	ah
		xor	ah,cl		;restore sign
		sub	ah,cl
		add	[si],ah		;(new B - old B) * fade + old B
		inc	si		;next col

		dec	bp
		jnz	FadeLoop2

FadeDone2:	pop	bp
		pop	ax
		pop	dx
		pop	bx

;----------------
;* palette fade 3
;----------------

;* skip fade if fade level = 0

		test	bl,bl		;fade level = 0?
		jz	FadeDone3	;yes ->

;* calc ptr to start of fade range

		mov	si,OFFSET VGA_RGB_Fade
		REPT	3
		add	si,ax
		ENDM

;* fade range of colours

FadeLoop3:	mov	al,bh		;new R
		sub	al,[si]		;new R - old R
		ABSV	al		;al = abs(delta), ah = sign(delta)
		mov	cl,ah
		mul	bl		;(new R - old R) * fade
		shl	ax,1		;frac adjust
		shl	al,1		;expose 1/2 bit
		ROUNDUP	ah
		xor	ah,cl		;restore sign
		sub	ah,cl
		add	[si],ah		;(new R - old R) * fade + old R
		inc	si		;next col

		mov	al,dl		;new G
		sub	al,[si]		;new G - old G
		ABSV	al		;al = abs(delta), ah = sign(delta)
		mov	cl,ah
		mul	bl		;(new G - old G) * fade
		shl	ax,1		;frac adjust
		shl	al,1		;expose 1/2 bit
		ROUNDUP	ah
		xor	ah,cl		;restore sign
		sub	ah,cl
		add	[si],ah		;(new G - old G) * fade + old G
		inc	si		;next col

		mov	al,dh		;new B
		sub	al,[si]		;new B - old B
		ABSV	al		;al = abs(delta), ah = sign(delta)
		mov	cl,ah
		mul	bl		;(new B - old B) * fade
		shl	ax,1		;frac adjust
		shl	al,1		;expose 1/2 bit
		ROUNDUP	ah
		xor	ah,cl		;restore sign
		sub	ah,cl
		add	[si],ah		;(new B - old B) * fade + old B
		inc	si		;next col

		dec	bp
		jnz	FadeLoop3

FadeDone3:	pop	es
		pop	ds

		mov	FadeFlag,1

		ret

FadePalette	ENDP

;----------------------------------------------------------------------------

;* FadeOut - fade screen to black
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

FadeOut		PROC	FAR

;-----------------
;* initialize fade
;-----------------

		xor	ax,ax

		mov	FadeLevel3,al

		mov	FadeRCol3,al
		mov	FadeGCol3,al
		mov	FadeBCol3,al

		mov	FadeStart3,ax
		mov	FadeCount3,256

		mov	Frames,ax

;---------------
;* fade out loop
;---------------

FadeOutLoop: 	mov	FadeLevel3,al

		call	UpdateFade

		mov	ax,Frames
		cmp	ax,127
		jbe	@F
		mov	ax,127

;* allow a little longer delay ...

@@:		cmp	Frames,200
		jb	FadeOutLoop

		ret

FadeOut		ENDP

;----------------------------------------------------------------------------

;* QFadeOut - quick fade screen to black
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

QFadeOut	PROC	FAR

;-----------------
;* initialize fade
;-----------------

		xor	ax,ax

		mov	FadeLevel3,al

		mov	FadeRCol3,al
		mov	FadeGCol3,al
		mov	FadeBCol3,al

		mov	FadeStart3,ax
		mov	FadeCount3,256

		mov	Frames,ax

;---------------
;* fade out loop
;---------------

@@:	 	shl	al,1		;*2
		shl	al,1		;*4

		mov	FadeLevel3,al

		call	UpdateFade

		mov	ax,Frames
		cmp	ax,31
		jbe	@B

		mov	FadeLevel3,127

		call	UpdateFade

		ret

QFadeOut 	ENDP

;----------------------------------------------------------------------------

;* FadeIn - fade screen to normal from black
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

FadeIn		PROC	FAR

;-----------------
;* initialize fade
;-----------------

		xor	ax,ax

		mov	FadeLevel3,127

		mov	FadeRCol3,al
		mov	FadeGCol3,al
		mov	FadeBCol3,al

		mov	FadeStart3,ax
		mov	FadeCount3,256

		mov	ax,127

		mov	CountDown,ax

;--------------
;* fade in loop
;--------------

@@:		mov	FadeLevel3,al

		call	UpdateFade

		mov	ax,CountDown
		test	ax,ax
		jnz	@B
        
		mov	FadeLevel3,al

		call	UpdateFade

		ret

FadeIn		ENDP

;----------------------------------------------------------------------------

;* QFadeIn - quick fade screen to normal from black
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

QFadeIn		PROC	FAR

;-----------------
;* initialize fade
;-----------------

		xor	ax,ax

		mov	FadeLevel3,127

		mov	FadeRCol3,al
		mov	FadeGCol3,al
		mov	FadeBCol3,al

		mov	FadeStart3,ax
		mov	FadeCount3,256

		mov	ax,31

		mov	CountDown,ax

;--------------
;* fade in loop
;--------------

@@:		shl	al,1		;*2
		shl	al,1		;*4

		mov	FadeLevel3,al

		call	UpdateFade

		mov	ax,CountDown
		test	ax,ax
		jnz	@B

		mov	FadeLevel3,al

		call	UpdateFade

		ret

QFadeIn		ENDP

;----------------------------------------------------------------------------

;* InstantFadeOut
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all
;*
;* note: Ensure that SetPaletteFlag is reset before calling this routine else
;*       conflicts will arise in DownLoad. It is possibly a good idea to clear
;*       the screen to (say) black first.

InstantFadeOut	PROC	FAR

		xor	ax,ax

		mov	FadeLevel3,127

		mov	FadeRCol3,al
		mov	FadeGCol3,al
		mov	FadeBCol3,al

		mov	FadeStart3,ax
		mov	FadeCount3,256

		call	UpdateFade

		ret

InstantFadeOut	ENDP

;----------------------------------------------------------------------------

;* InstantFadeIn
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all
;*
;* note: Ensure that SetPaletteFlag is reset before calling this routine else
;*       conflicts will arise in DownLoad. It is possibly a good idea to clear
;*       the screen to (say) black first.

InstantFadeIn	PROC	FAR

		xor	ax,ax

		mov	FadeLevel3,al

		mov	FadeRCol3,al
		mov	FadeGCol3,al
		mov	FadeBCol3,al

		mov	FadeStart3,ax
		mov	FadeCount3,256

		call	UpdateFade

		ret

InstantFadeIn	ENDP

;----------------------------------------------------------------------------

;* FadeDown - partially fade screen to black
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

FadeDown	PROC	FAR

;-----------------
;* initialize fade
;-----------------

		xor	ax,ax

		mov	FadeLevel3,al

		mov	FadeRCol3,al
		mov	FadeGCol3,al
		mov	FadeBCol3,al

		mov	FadeStart3,ax
		mov	FadeCount3,256

		mov	Frames,ax

;----------------
;* fade down loop
;----------------

@@:		mov	FadeLevel3,al

		call	UpdateFade

		mov	ax,Frames
		cmp	ax,12
		jb	@B

		mov	FadeLevel3,12

		call	UpdateFade

		ret

FadeDown	ENDP

;----------------------------------------------------------------------------

;* FadeUp - fade screen to normal from partially black
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

FadeUp		PROC	FAR

;-----------------
;* initialize fade
;-----------------

		xor	ax,ax

		mov	FadeLevel3,12

		mov	FadeRCol3,al
		mov	FadeGCol3,al
		mov	FadeBCol3,al

		mov	FadeStart3,ax
		mov	FadeCount3,256

		mov	ax,12

		mov	CountDown,ax

;--------------
;* fade up loop
;--------------

@@:		mov	FadeLevel3,al

		call	UpdateFade

		mov	ax,CountDown
		test	ax,ax
		jnz	@B

		mov	FadeLevel3,al

		call	UpdateFade

		ret

FadeUp		ENDP

;----------------------------------------------------------------------------

;* UpdateFade - set fade level
;*
;* pass: FadeLevel3
;* ret : nothing
;* kill: assume all

UpdateFade	PROC	NEAR

		call	FadePalette

;------------------
;* wait for retrace
;------------------

@@:	    	mov	dx,VGA_CRT_STAT
	    	in	al,dx
	    	test	al,VGA_VSYNC
	    	jnz	@B
	
@@:		mov	dx,VGA_CRT_STAT
		in	al,dx  	
		test 	al,VGA_VSYNC
	     	jz 	@B

;-------------
;* update DACs
;-------------

		mov	si,OFFSET VGA_RGB_Fade

		push	ds

		mov	ax,SEG VGA_RGB_Data
		mov	ds,ax

		xor	al,al
		mov	cx,256

		call	SetDACBlock

		pop	ds

		mov	FadeFlag,0	;prevent repeat fade in DownLoad

		ret

UpdateFade	ENDP

;----------------------------------------------------------------------------

;* UnpackDeltaPic - unpack delta compressed picture
;*
;* pass: WorkScreen[] + CopyScreen[] hold delta compressed data
;*       RealScrPtr
;* ret : nothing
;* kill: assume all
;*       VGA_SEQ_MAPMSK
;*
;* note: The picture data is unpacked to the REAL screen so make sure that
;*       the palette is faded out before unpacking. The picture is unpacked
;*	 into the real screen so that the "fade" routines can be used. The
;*	 fade routines use fade 3 (which is ignored by the download routine).
;*
;*	 This routine does not load the palette data into the DACs.
;*
;*       Data format:-
;*
;*	 bytes   0 .. 767: RGB * 256 (0 .. 63 gun values)
;*	 bytes 768 .. n  : delta compressed data
;*
;*       A 4-bit delta is used in this compression.
;*
;*	 Delta data is stored hi nibble, lo nibble, hi nibble, lo nibble etc.
;*
;*       Delta compression is best suited to digitized pictures where the
;*       palette has been sorted in some order (grey scaled?).

UnpackDeltaPic	PROC	FAR

		push	ds
		push	es

		mov	ax,RealScrPtr
		mov	es,ax
		mov	ax,SEG WorkScreen
		mov	ds,ax

		SLCTREG	VGA_SEQ,VGA_SEQ_MAPMSK

		mov	si,OFFSET WorkScreen+(256*3)	;start of delta data

		xor	di,di		;start of screen

		mov	al,0001b	;map mask = map 0

		mov	ah,0f0h		;nibble mask

		xor	bl,bl		;pixel = 0

		mov	cl,4		;nibble shift count

UnpackLoop	LABEL	NEAR

;* read nibble

		mov	bh,[si]		;fetch nibble

		cmp	ah,0f0h		;hi nibble?
		je	@F		;yes ->

		shl	bh,cl		;lo nibble -> hi nibble

		inc	si		;next byte

@@:		sar	bh,cl		;sign extend into lo nibble

		not	ah		;toggle nibble

		cmp	bh,-8		;delta data or new pixel value?
		jne	SortDelta	;delta data ->

		mov	bl,[si]

		cmp	ah,0f0h		;extract hi then lo?
		jne	@F		;no (extract lo then hi) ->

		rol	bl,cl		;swap nibbles

		inc	si		;next byte

		jmp	PixelOk

@@:		and	bl,ah		;lo nibble

		inc	si		;next byte

		mov	bh,[si]

		and 	bh,0f0h		;hi nibble

		or	bl,bh

		jmp	PixelOk

SortDelta:	add	bl,bh		;pixel + delta

;* write pixel

PixelOk:	out	dx,al		;select map

		mov	es:[di],bl	;store pixel

		shl	al,1		;next map

		test	al,10000b	;all maps done?
		jz	UnpackLoop	;no ->

		mov	al,0001b	;map mask = map 0

		inc	di		;next screen address

		cmp	di,(320*200)/4	;end of screen?
		jb	UnpackLoop	;no ->

		pop	es
		pop	ds

		ret

UnpackDeltaPic	ENDP

;----------------------------------------------------------------------------

;* ScreenShaker - shake screen horizontally and vertically
;*
;* pass: HShake
;*	 VShake
;* ret : nothing
;* kill: ax, bx, dx, flags
;*
;* note: This routine should be called from the user's 100Hz interrupt
;*       routine (only if ShakeTimer <> 0).

ScreenShaker	PROC	FAR

;------------------
;* horizontal shake
;------------------

;* clear flip-flop to allow attribute register index to be selected

		mov	dx,VGA_INPUT_1	
		in	al,dx

;* select index for horizontal pixel panning register

		mov	dx,VGA_ATTR
		mov	al,VGA_ATTR_HPAN
		out	dx,al

;* set random pan value

		call	FastRandX
		and	al,HShake
		out	dx,al

;----------------
;* vertical shake
;----------------

		call	FastRandX
		and	al,VShake

		mov	bx,OFFSET VShakeTable
		xlat

		mov	dx,VGA_CRTC
		mov	ah,al
		mov	al,VGA_CRTC_LO
		out	dx,ax

		ret

ScreenShaker	ENDP

GCODE		ENDS

;============================================================================

		END

