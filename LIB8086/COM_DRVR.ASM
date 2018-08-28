;****************************************************************************
;*
;* COM_DRVR.ASM
;*
;* Common routines for all screen drivers.
;*
;* 28.04.1989 - KJB
;* 29.08.1991 - KJB - PrintChar3 added.
;*                    VGA_SaveScreen / VGA_LoadScreen added.
;*                    VGA_SaveMouse / VGA_LoadMouse added.
;*                    MouseHouse[] size increased.
;*
;* Graphics Driver Conventions
;* ---------------------------
;*
;* 1) Always keep ds and es pointing to DATA segment. Any graphics routine
;*    should push es, point es at work screen and pop es before returning.
;*
;* 2) Always return EGA and VGA registers to default settings.
;*
;* 3) Direction flag set for auto-increment.
;*
;* 4) Colours - most of the routines require colours to be specified as
;*    follows:-
;*
;*    HGC - See CGA.
;*
;*    CGA - the colour pattern should be repeated every 2 bits. Some routines
;*          may use a word instead of a byte. Some routines can use 'hatched'
;*          patterns.
;*
;*          example: 10101010b = magenta
;*
;*    EGA - See TAN.
;*
;*    TAN - the colour pattern is repeated in both nibbles.
;*
;*          example: 0aah = light green
;*
;*    VGA - the colour pattern uses the whole byte.
;*
;* 5) Do not use bp as a pass parameter. This register is used to jump to 
;*    correct driver.
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	SetVideoMode
		PUBLIC	DownLoad
		PUBLIC	SetPixel
		PUBLIC	LineDraw
		PUBLIC	VLineDraw
		PUBLIC	HLineDraw
		PUBLIC	PrintChar1
		PUBLIC	PrintChar2
		PUBLIC	PrintChar3
		PUBLIC	SSprite
		PUBLIC	MSprite
		PUBLIC	BSprite
		PUBLIC	QSprite
		PUBLIC	InitSSprites
		PUBLIC	InitMSprites
		PUBLIC	InitQSprites
		PUBLIC	BlockFill
		PUBLIC	SaveMouseBGnd
		PUBLIC	LoadMouseBGnd
		PUBLIC	SaveScreen
		PUBLIC	LoadScreen
		PUBLIC	UncompressPic
		PUBLIC	HorizonFill

		PUBLIC	SetAttributes
		PUBLIC	SetPalette
		PUBLIC	SetSSpriteClip

		PUBLIC	VideoBufSize
		PUBLIC	ScreenMode
		PUBLIC	ScreenPage
		PUBLIC	WorkScrPtr
		PUBLIC	RealScrPtr
		PUBLIC	FlipMode
		PUBLIC	SetPaletteFlag
		PUBLIC	PolyCount
		PUBLIC	MaxFrameRate
		PUBLIC	ScreenType
		PUBLIC	HrznXMin
		PUBLIC	HrznXMax

		PUBLIC	_PolyFill
		PUBLIC	_MeshFill
		PUBLIC	_SmokeFill

		PUBLIC	WorkScreen
		PUBLIC	CopyScreen
		PUBLIC	MouseHouse

		PUBLIC	LineCol
		PUBLIC	PixelCol
		PUBLIC	FillCol
		PUBLIC	HrznLhsCol
		PUBLIC	HrznRhsCol

		PUBLIC	Palette

		PUBLIC	PrtLn
		PUBLIC	PrtCl
		PUBLIC	ForeCol
		PUBLIC	BackCol
		PUBLIC	PrintOver

		PUBLIC	CharSetPtr1 
		PUBLIC	CharSetPtr2
		PUBLIC	CharSetPtr3

		PUBLIC	Sprite
		PUBLIC	SpriteX
		PUBLIC	SpriteY
		PUBLIC	SpritePtr

		PUBLIC	ClipXMin
		PUBLIC	ClipXMax
		PUBLIC	ClipYMin
		PUBLIC	ClipYMax

		PUBLIC	HGC
		PUBLIC	HEM
		PUBLIC	CGA
		PUBLIC	EGA 
		PUBLIC	TAN 
		PUBLIC	TEM
		PUBLIC	V16
		PUBLIC	VGA 

		PUBLIC	GAME_MODE
		PUBLIC	MENU_MODE

		PUBLIC	FREE_FRAME_RATE
		PUBLIC	FAST_FRAME_RATE
		PUBLIC	MEDM_FRAME_RATE
		PUBLIC	SLOW_FRAME_RATE

		EXTRN	HGC_VMode:NEAR
		EXTRN	HEM_VMode:NEAR		
		EXTRN	CGA_VMode:NEAR
		EXTRN	EGA_VMode:NEAR
		EXTRN	TAN_VMode:NEAR
		EXTRN	TEM_VMode:NEAR
		EXTRN	VGA_VMode:NEAR

		EXTRN	HGC_DLoad:NEAR
		EXTRN	CGA_DLoad:NEAR
		EXTRN	EGA_DLoad:NEAR
		EXTRN	TAN_DLoad:NEAR
		EXTRN	TEM_DLoad:NEAR
		EXTRN	VGA_DLoad:NEAR

		EXTRN	CGA_SetPx:NEAR
		EXTRN	EGA_SetPx:NEAR
		EXTRN	TAN_SetPx:NEAR
		EXTRN	VGA_SetPx:NEAR

		EXTRN	CGA_Line:NEAR
		EXTRN	EGA_Line:NEAR
		EXTRN	TAN_Line:NEAR
		EXTRN	VGA_Line:NEAR

		EXTRN	CGA_VLine:NEAR
		EXTRN	EGA_VLine:NEAR
		EXTRN	TAN_VLine:NEAR
		EXTRN	VGA_VLine:NEAR

		EXTRN	CGA_HLine:NEAR
		EXTRN	EGA_HLine:NEAR
		EXTRN	TAN_HLine:NEAR
		EXTRN	VGA_HLine:NEAR

		EXTRN	CGA_PFill:NEAR
		EXTRN	EGA_PFill:NEAR
		EXTRN	TAN_PFill:NEAR
		EXTRN	VGA_PFill:NEAR

		EXTRN	CGA_MFill:NEAR
		EXTRN	EGA_MFill:NEAR
		EXTRN	TAN_MFill:NEAR
		EXTRN	VGA_MFill:NEAR

		EXTRN	CGA_SFill:NEAR
		EXTRN	EGA_SFill:NEAR
		EXTRN	TAN_SFill:NEAR
		EXTRN	VGA_SFill:NEAR

		EXTRN	CGA_PrtC1:NEAR
		EXTRN	EGA_PrtC1:NEAR
		EXTRN	TAN_PrtC1:NEAR
		EXTRN	VGA_PrtC1:NEAR

		EXTRN	CGA_PrtC2:NEAR
		EXTRN	EGA_PrtC2:NEAR
		EXTRN	TAN_PrtC2:NEAR
		EXTRN	VGA_PrtC2:NEAR

		EXTRN	CGA_PrtC3:NEAR
		EXTRN	EGA_PrtC3:NEAR
		EXTRN	TAN_PrtC3:NEAR
		EXTRN	VGA_PrtC3:NEAR

		EXTRN	CGA_SSprite:NEAR
		EXTRN	EGA_SSprite:NEAR
		EXTRN	TAN_SSprite:NEAR
		EXTRN	VGA_SSprite:NEAR

		EXTRN	CGA_MSprite:NEAR
		EXTRN	EGA_MSprite:NEAR
		EXTRN	TAN_MSprite:NEAR
		EXTRN	VGA_MSprite:NEAR

		EXTRN	CGA_BSprite:NEAR
		EXTRN	EGA_BSprite:NEAR
		EXTRN	TAN_BSprite:NEAR
		EXTRN	VGA_BSprite:NEAR

		EXTRN	CGA_QSprite:NEAR
		EXTRN	EGA_QSprite:NEAR
		EXTRN	TAN_QSprite:NEAR
		EXTRN	VGA_QSprite:NEAR

		EXTRN	CGA_InitSS:NEAR
		EXTRN	EGA_InitSS:NEAR
		EXTRN	TAN_InitSS:NEAR
		EXTRN	VGA_InitSS:NEAR

		EXTRN	CGA_InitMS:NEAR
		EXTRN	EGA_InitMS:NEAR
		EXTRN	TAN_InitMS:NEAR
		EXTRN	VGA_InitMS:NEAR
	
		EXTRN	EGA_InitQS:NEAR
		EXTRN	VGA_InitQS:NEAR

		EXTRN	CGA_BFill:NEAR
		EXTRN	EGA_BFill:NEAR
		EXTRN	TAN_BFill:NEAR
		EXTRN	VGA_BFill:NEAR

		EXTRN	CGA_SaveMouse:NEAR
		EXTRN	EGA_SaveMouse:NEAR
		EXTRN	TAN_SaveMouse:NEAR
		EXTRN	VGA_SaveMouse:NEAR

		EXTRN	CGA_LoadMouse:NEAR
		EXTRN	EGA_LoadMouse:NEAR
		EXTRN	TAN_LoadMouse:NEAR
		EXTRN	VGA_LoadMouse:NEAR

		EXTRN	CGA_SaveScreen:NEAR
		EXTRN	EGA_SaveScreen:NEAR
		EXTRN	TAN_SaveScreen:NEAR
		EXTRN	VGA_SaveScreen:NEAR

		EXTRN	CGA_LoadScreen:NEAR
		EXTRN	EGA_LoadScreen:NEAR
		EXTRN	TAN_LoadScreen:NEAR
		EXTRN	VGA_LoadScreen:NEAR

		EXTRN	CGA_UncompPic:NEAR
		EXTRN	EGA_UncompPic:NEAR
		EXTRN	TAN_UncompPic:NEAR

		EXTRN	CGA_HFill:NEAR
		EXTRN	EGA_HFill:NEAR
		EXTRN	TAN_HFill:NEAR
		EXTRN	VGA_HFill:NEAR

		EXTRN	ElapsedTime:DWORD
		EXTRN	FrameElapTime:DWORD

		EXTRN	Frames:WORD
		EXTRN	LastFrame:WORD
		EXTRN	MouseX:WORD
		EXTRN	MouseY:WORD

		EXTRN	HGC_Palette1:BYTE
		EXTRN	CGA_Palette1:BYTE
		EXTRN	TAN_Palette1:BYTE
		EXTRN	VGA_Palette1:BYTE

		EXTRN	Standard_7by9:BYTE
		EXTRN	Standard_3by5:BYTE
		EXTRN	Standard_5by9:BYTE
		
;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

;* CGA_MODEL is suitable for HGC, HEM, CGA modes
;* EGA_MODEL is suitable for HGC, HEM, CGA, EGA, TAN, TEM, V16, VGA modes

CGA_MODEL	EQU	16000		;4 colour buffer size
EGA_MODEL	EQU	32000		;16 colour buffer size

VIDEO_BUF_SIZE	EQU	EGA_MODEL

VideoBufSize	DW	VIDEO_BUF_SIZE

;* enable / disable sprite routines

SPRITES_ON	EQU	1		;1 = sprite routines enabled

VGA		EQU	0		;Video Graphics Adapter
HEM		EQU	2	     ;Hercules emulated on CGA
CGA		EQU	4		;Colour Graphics Adapter
EGA		EQU	6		;Enhanced Graphics Adapter
TAN		EQU	8		;Tandy
TEM		EQU	10		;Tandy emulated on EGA
V16		EQU	12		;16 colour VGA
HGC		EQU	14		;Hercules Graphics Card

WorkScrPtr	DW	0		;ptr to work screen segment
RealScrPtr	DW	0		;ptr to real screen segment

ScreenMode	DW	EGA

ScreenPage	DW	0		;0 = page 0, 2 = page 1 (EGA, VGA)

GAME_MODE	EQU	0		;EGA / VGA flip work / real screen
MENU_MODE	EQU	2	 	;EGA / VGA copy work to real screen

FlipMode	DW	GAME_MODE

SetPaletteFlag	DB	0,0		;1 = load palette registers

PolyCount	DW	0		;polygons / frame

;* frame rates

FREE_FRAME_RATE	EQU	1		;100 frames / sec (max) (free run)
FAST_FRAME_RATE	EQU	5 		; 20 frames / sec (max)
MEDM_FRAME_RATE	EQU	10		; 10 frames / sec (max)
SLOW_FRAME_RATE	EQU	20		;  5 frames / sec (max)

MaxFrameRate	DW	FREE_FRAME_RATE	;limit frame rate (1/100ths sec)

;* screen types

SCR_TYPE_0	EQU	0		;4 colour screens
SCR_TYPE_1	EQU	1		;16 colour screens
SCR_TYPE_2	EQU	2		;256 colour screens

ScreenTypeTable	DW	SCR_TYPE_2	;VGA

ScreenType	DW	SCR_TYPE_1

;* pen colours

PixelCol	DB	0,0		;SetPixel pen colour
LineCol		DB	0,0		;LineDraw pen colour
FillCol		DB	0,0		;PolyFill paint colour
HrznLhsCol	DB	0,0		;HorizonFill lhs colour
HrznRhsCol	DB	0,0		;HorizonFill rhs colour

;* logical to physical colour convert table

Palette		DB	256 DUP(0ffh)	;colour palette

;* pointers to default palettes for screen modes

PaletteTable	DW	OFFSET VGA_Palette1	;VGA
		

;* offsets in attribute data block for screen modes

AttrTable	DW	6		;VGA
		DW	2		;CGA

;* print character variables

PrtLn		DW	0		;print line 0 - 199
PrtCl		DW	0		;print column 0 - 319
ForeCol  	DB	0ffh,0ffh	;default white  
BackCol  	DB	000h,000h	;default black
PrintOver	DB	0,0  		;1 = use print 'over'

;* character set font pointers

CharSetPtr1	DW	OFFSET Standard_7by9
CharSetPtr2	DW	OFFSET Standard_3by5
CharSetPtr3	DW	OFFSET Standard_5by9

;* general purpose logical sprite data block

Sprite		LABEL	WORD

SpriteX		DW	0		;x
SpriteY		DW	0		;y
SpritePtr	DW	0		;ptr

;* SSprite clip divide x table

ClipXTable	DB	2,0		;VGA (x/4)
;		DB	2,0		;CGA (x/4)

;* clip data initialized to maximum screen size

ClipXMin	DW	0 		;byte resolution
ClipXMax	DW	79		;byte resolution
ClipYMin	DW	0		;pixel resolution
ClipYMax	DW	199		;pixel resolution

;* horizon fill variables

HrznXMin	DW	0
HrznXMax	DW	0

;-------------
;* Jump Tables
;-------------

JumpInitList	DW	_SetVideoMode
		DW	_DownLoad
		DW	_SetPixel
		DW	_LineDraw
		DW	_VLineDraw
		DW	_HLineDraw
		DW	_PolyFill
		DW	_MeshFill
		DW	_SmokeFill
		DW	_PrintChar1
		DW	_PrintChar2
		DW	_PrintChar3
		DW	_SSprite
		DW	_MSprite
		DW	_BSprite
		DW	_QSprite
		DW	_InitSSprites
		DW	_InitMSprites
		DW	_InitQSprites
		DW	_BlockFill
		DW	_SaveMouseBGnd
		DW	_LoadMouseBGnd
		DW	_SaveScreen
		DW	_LoadScreen
		DW	_UncompressPic
		DW	_HorizonFill
		DW	-1		;list terminator

_SetVideoMode	DW	Null

		DW	VGA_VMode	;VGA

_DownLoad	DW	Null

		DW	VGA_DLoad	;VGA

_SetPixel	DW	Null

		DW	VGA_SetPx	;VGA

_LineDraw	DW	Null

		DW	VGA_Line	;VGA

_VLineDraw	DW	Null

		DW	VGA_VLine	;VGA

_HLineDraw	DW	Null

		DW	VGA_HLine	;VGA

_PolyFill	DW	Null

	 	DW	VGA_PFill	;VGA

_MeshFill	DW	Null

	 	DW	VGA_MFill	;VGA

_SmokeFill	DW	Null

	 	DW	VGA_SFill	;VGA

_PrintChar1	DW	Null

	 	DW	VGA_PrtC1	;VGA

_PrintChar2	DW	Null

	 	DW	VGA_PrtC2	;VGA

_PrintChar3	DW	Null

	 	DW	VGA_PrtC3	;VGA

_SSprite	DW	Null

		IF	SPRITES_ON

	 	DW	VGA_SSprite	;VGA

		ELSE

	 	DW	Null	 	;VGA

		ENDIF

_MSprite	DW	Null

		IF	SPRITES_ON

	 	DW	VGA_MSprite	;VGA

		ELSE

	 	DW	Null	 	;VGA

		ENDIF

_BSprite	DW	Null

		IF	SPRITES_ON

	 	DW	VGA_BSprite	;VGA

		ELSE

	 	DW	Null	 	;VGA

		ENDIF

_QSprite	DW	Null

		IF	SPRITES_ON

	 	DW	VGA_QSprite	;VGA

		ELSE

	 	DW	Null	 	;VGA

		ENDIF

_InitSSprites	DW	Null

		IF	SPRITES_ON

	 	DW	VGA_InitSS	;VGA

		ELSE

	 	DW	Null	 	;VGA

		ENDIF

_InitMSprites	DW	Null

		IF	SPRITES_ON

	 	DW	VGA_InitMS	;VGA

		ELSE

	 	DW	Null	 	;VGA

		ENDIF

_InitQSprites	DW	Null

		IF	SPRITES_ON

	 	DW	VGA_InitQS	;VGA

		ELSE

	 	DW	Null	 	;VGA

		ENDIF

_BlockFill   	DW	Null

	 	DW	VGA_BFill	;VGA

_SaveMouseBGnd 	DW	Null

	 	DW	VGA_SaveMouse	;VGA

_LoadMouseBGnd 	DW	Null

	 	DW	VGA_LoadMouse	;VGA

_SaveScreen 	DW	Null

	 	DW	VGA_SaveScreen	;VGA

_LoadScreen 	DW	Null

	 	DW	VGA_LoadScreen	;VGA

_UncompressPic 	DW	Null

	 	DW	Null		;VGA

_HorizonFill 	DW	Null

	 	DW	VGA_HFill	;VGA

DATA		ENDS

;============================================================================

;---------------------------------------------------------
;* System memory work screen - all work screens are linear
;---------------------------------------------------------

WSDATA		SEGMENT PARA PUBLIC 'DATA'

;* DO NOT PUT ANY DATA IN FRONT OF WorkScreen!!!

;* VGA mode uses WorkScreen and CopyScreen as a combined buffer.

WorkScreen	DB	VIDEO_BUF_SIZE DUP(0)
CopyScreen	DB	VIDEO_BUF_SIZE DUP(0)

;* MouseHouse[] - store mouse background
;*
;* largest size required for VGA:- 
;*
;*    (4 bytes + 1 shift byte) * 4 planes * 16 lines = 320 bytes

MouseHouse	DB	320 DUP(0)

WSDATA		ENDS

;============================================================================

GCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:GCODE
		ASSUME DS:DATA

;* SetVideoMode - set video mode
;*
;* pass: ScreenMode (HGC, HEM, CGA, EGA, TAN, TEM, V16, VGA)
;* ret : WorkScrPtr
;*       RealScrPtr
;* kill: assume all (BIOS routines used)

SetVideoMode	PROC	FAR

;* initialize jumps wrt ScreenMode

		mov	bx,ScreenMode
		mov	di,OFFSET JumpInitList

SetVideoLoop:	mov	si,[di]
		cmp	si,-1		;end of list?
		je	InitPalette	;yes ->
		mov	ax,[si+bx+2]
		mov	[si],ax
		add	di,2
		jmp	SetVideoLoop

;* initialize palette wrt ScreenMode
		
InitPalette:	mov	bx,ScreenMode
		mov	si,PaletteTable[bx]
		push	ds
		mov	ax,SEG TAN_Palette1
		mov	ds,ax
		call	FAR PTR SetPalette
		pop	ds

;* set screen type

		mov	bx,ScreenMode
		mov	ax,ScreenTypeTable[bx]
		mov	ScreenType,ax

;* set video mode

		mov	bp,_SetVideoMode
		jmp	bp

SetVideoMode	ENDP

;----------------------------------------------------------------------------

;* DownLoad - download work screen to real screen
;*
;* pass: WorkScrPtr
;*       RealScrPtr
;*       Frames
;*       MaxFrameRate
;* ret : WorkScrPtr   ) swapped over if EGA / VGA mode
;*       RealScrPtr   )
;*       LastFrame = Frames
;*	 FrameElapTime = ElapsedTime
;*       Frames = 0
;* kill: assume all

DownLoad	PROC	FAR

;* fix max frame rate (stop program running away)

FrameWait:	mov	ax,Frames
		cmp	ax,MaxFrameRate
		jb	FrameWait

		mov	LastFrame,ax	;store frame time
		xor	ax,ax
		mov	Frames,ax

		mov	PolyCount,0

		cli
		mov	ax,WORD PTR ElapsedTime
		mov	dx,WORD PTR ElapsedTime+2
		mov	WORD PTR FrameElapTime,ax
		mov	WORD PTR FrameElapTime+2,dx
		sti

		mov	bp,_DownLoad
		jmp	bp

DownLoad	ENDP

;----------------------------------------------------------------------------

;* SetPixel - set pixel
;*
;* pass: al = logical colour
;*       bl = y (0 - 199)
;*       cx = x (0 - 319)
;* ret : nothing
;* kill: assume all

SetPixel	PROC	FAR

		inc	PolyCount

		xor	ah,ah
		mov	si,ax
		mov	al,Palette[si]
		mov	PixelCol,al
	
		mov	bp,_SetPixel
		jmp	bp

SetPixel	ENDP

;----------------------------------------------------------------------------

;* LineDraw - draw line between two points
;*
;* pass: al = logical colour
;*       cx, bl = x1, y1
;*       dx, bh = x2, y2
;* ret : nothing
;* kill: assume all

LineDraw	PROC	FAR

		inc	PolyCount

		xor	ah,ah
		mov	si,ax
		mov	al,Palette[si]
		mov	LineCol,al

		mov	bp,_LineDraw
		jmp	bp

LineDraw	ENDP

;----------------------------------------------------------------------------

;* VLineDraw - draw vertical line between two points
;*
;* pass: al = logical colour
;*       bl = y1
;*       bh = y2
;*       cx = x1
;* ret : nothing
;* kill: assume all

VLineDraw	PROC	FAR

		inc	PolyCount

		xor	ah,ah
		mov	si,ax
		mov	al,Palette[si]
		mov	LineCol,al

		mov	bp,_VLineDraw
		jmp	bp

VLineDraw	ENDP

;----------------------------------------------------------------------------

;* HLineDraw - draw horizontal line between two points
;*
;* pass: al = logical colour
;*       bl = y1
;*       cx = x1
;*       dx = x2
;* ret : nothing
;* kill: assume all

HLineDraw	PROC	FAR

		inc	PolyCount

		xor	ah,ah
		mov	si,ax
		mov	al,Palette[si]
		mov	LineCol,al

		mov	bp,_HLineDraw
		jmp	bp

HLineDraw	ENDP

;----------------------------------------------------------------------------

;* PrintChar1 - print character type 1 (7 by 9)
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
;*
;* note: PrtCl is rounded down to 4 pixel steps (effectively 80 columns).
;*       No checks are made for PrtLn and PrtCl being off screen.

PrintChar1	PROC	FAR

		mov	bp,_PrintChar1
		jmp	bp

PrintChar1	ENDP

;----------------------------------------------------------------------------

;* PrintChar2 - print character type 2 (3 by 5)
;*
;* pass: al = ASCII code
;*       PrtLn
;*       PrtCl
;*       ForeCol
;*       BackCol
;*       CharSetPtr2
;* ret : PrtCl modified
;* kill: bp, flags
;*
;* note: PrtCl is rounded down to 4 pixel steps (effectively 80 columns).
;*       No checks are made for PrtLn and PrtCl being off screen.

PrintChar2	PROC	FAR

		mov	bp,_PrintChar2
		jmp	bp

PrintChar2	ENDP

;----------------------------------------------------------------------------

;* PrintChar3 - print character type 3 (5 by 9)
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
;*
;* note: PrtCl is rounded down to 2 pixel steps.
;*       No checks are made for PrtLn and PrtCl being off screen.

PrintChar3	PROC	FAR

		mov	bp,_PrintChar3
		jmp	bp

PrintChar3	ENDP

;----------------------------------------------------------------------------

;* SSprite - shifted sprite (pre-shifted, clipped and masked)
;*
;* pass: si -> logical sprite data
;*          [si+0] = x co-ord
;*          [si+2] = y co-ord
;*          [si+4] = sprite pointer
;* ret : cf = 0 = sprite not visible
;*       cf = 1 = sprite visible
;* kill: assume all

SSprite		PROC	FAR

		mov	bp,_SSprite
		jmp	bp

SSprite		ENDP

;----------------------------------------------------------------------------

;* MSprite - masked sprite (not shifted, not clipped, masked only)
;*
;* pass: si -> logical sprite data
;*          [si+0] = x co-ord
;*          [si+2] = y co-ord
;*          [si+4] = sprite pointer
;* ret : nothing
;* kill: assume all

MSprite		PROC	FAR

		mov	bp,_MSprite
		jmp	bp

MSprite		ENDP

;----------------------------------------------------------------------------

;* BSprite - block sprite (use MSprite data with SSprite)
;*
;* pass: si -> logical sprite data
;*          [si+0] = x co-ord
;*          [si+2] = y co-ord
;*          [si+4] = sprite pointer
;* ret : cf = 0 = sprite not visible
;*       cf = 1 = sprite visible
;* kill: assume all

BSprite		PROC	FAR

		mov	bp,_BSprite
		jmp	bp

BSprite		ENDP

;----------------------------------------------------------------------------

;* QSprite - quick sprite (copy block onto screen)
;*
;* pass: si -> logical sprite data
;*          [si+0] = x co-ord
;*          [si+2] = y co-ord
;*          [si+4] = sprite pointer
;* ret : nothing
;* kill: assume all

QSprite		PROC	FAR

		mov	bp,_QSprite
		jmp	bp

QSprite		ENDP

;----------------------------------------------------------------------------

;* InitSSprites - initialize shifted sprites
;*
;* pass: SSpriteList
;* ret : nothing
;* kill: assume all

InitSSprites	PROC	FAR

		mov	bp,_InitSSprites
		jmp	bp

InitSSprites 	ENDP

;----------------------------------------------------------------------------

;* InitMSprites - initialize masked sprites
;*
;* pass: MSpriteList
;* ret : nothing
;* kill: assume all

InitMSprites	PROC	FAR

		mov	bp,_InitMSprites
		jmp	bp

InitMSprites 	ENDP

;----------------------------------------------------------------------------

;* InitQSprites - initialize quick sprites
;*
;* pass: QSpriteList
;* ret : nothing
;* kill: assume all

InitQSprites	PROC	FAR

		mov	bp,_InitQSprites
		jmp	bp

InitQSprites 	ENDP

;----------------------------------------------------------------------------

;* BlockFill - fast block fill
;*
;* pass: al = logical colour
;*       bl = y min (y1)
;*       bh = y max (y2)
;*       cx = x min (x1)
;*       dx = x max (x2)
;* ret : nothing
;* kill: assume all
;*
;* note: So that the block filled is the same size for each screen type, each
;*       driver will default to EGA boundaries (ie. x limited to minimum of
;*       8 pixel steps).
;*       Some drivers use FillCol as a word.

BlockFill	PROC	FAR

		inc	PolyCount

		mov	di,bx
		
		mov	bx,OFFSET Palette
		xlat
		mov	ah,al
		mov	WORD PTR FillCol,ax

		mov	bx,di
		and	di,000ffh	;di = y start

		sub	bh,bl		;y2 - y1
		mov	bl,bh
		xor	bh,bh		
		inc	bx		;bx = depth = (y2 - y1) + 1

		mov	ax,cx
		shr	ax,1
		shr	ax,1
		shr	ax,1		;x1 / 8
		shr	dx,1
		shr	dx,1
		shr	dx,1		;x2 / 8
		sub	dx,ax		;(x2 / 8) - (x1 / 8)
		inc	dx		;dx = width = 1 .. 40 (*8 pixels)

		xchg	bx,dx

		and	cx,0fff8h	;cx = x start (8 pixel boundary)

;* bx = width (1 - 40)
;* cx = x start (0 - 312 step 8)
;* dx = depth
;* di = y start
;* FillCol = physical colour
			
		mov	bp,_BlockFill
		jmp	bp

		ret

BlockFill	ENDP

;----------------------------------------------------------------------------

;* SaveMouseBGnd - save mouse background into MouseHouse[]
;*
;* pass: MouseX, MouseY
;* ret : MouseHouse[]
;* kill: assume all
;*
;* note: Assumes mouse sprite is 16 * 16 pixels (maximum).

SaveMouseBGnd	PROC	FAR

		mov	cx,MouseX
		mov	bx,MouseY

		mov	bp,_SaveMouseBGnd
		jmp	bp

SaveMouseBGnd 	ENDP

;----------------------------------------------------------------------------

;* LoadMouseBGnd - load mouse background from MouseHouse[]
;*
;* pass: MouseX, MouseY
;*       MouseHouse[]
;* ret : nothing
;* kill: assume all
;*
;* note: Assumes mouse sprite is 16 * 16 pixels (maximum).

LoadMouseBGnd	PROC	FAR

		mov	cx,MouseX
		mov	bx,MouseY

		mov	bp,_LoadMouseBGnd
		jmp	bp

LoadMouseBGnd 	ENDP

;----------------------------------------------------------------------------

;* SaveScreen - copy WorkScreen[] to CopyScreen[]
;*
;* pass: WorkScreen[]
;* ret : CopyScreen[]
;* kill: assume all

SaveScreen	PROC	FAR

		mov	bp,_SaveScreen
		jmp	bp

SaveScreen 	ENDP

;----------------------------------------------------------------------------

;* LoadScreen - copy CopyScreen[] to WorkScreen[]
;*
;* pass: CopyScreen[]
;* ret : WorkScreen[]
;* kill: assume all

LoadScreen	PROC	FAR

		mov	bp,_LoadScreen
		jmp	bp

LoadScreen 	ENDP

;----------------------------------------------------------------------------

;* UncompressPic - uncompress picture data
;*
;* pass: CopyScreen[] = compressed picture data
;* ret : WorkScreen[] = uncompressed picture data
;* kill: assume all

UncompressPic	PROC	FAR

		mov	bp,_UncompressPic
		jmp	bp

UncompressPic	ENDP

;----------------------------------------------------------------------------

;* HorizonFill - fill 'Z' section of horizon
;*
;* pass: al = logical colour 1
;*       ah = logical colour 2
;*       bl = y min
;*       bh = y max
;*       cx = x min
;*       dx = x max
;*       LhsX[y min] .. LhsX[y max] = x values for horizon line
;* ret : nothing
;* kill: assume all
;* note: Some drivers use HrznLhsCol and HrznRhsCol as a word.

HorizonFill	PROC	NEAR
		
		inc	PolyCount

		mov	HrznXMin,cx
		mov	HrznXMax,dx

		mov	si,bx

		mov	dl,ah

		mov	bx,OFFSET Palette
		xlat
		mov	ah,al
		mov	WORD PTR HrznLhsCol,ax

		mov	al,dl
		xlat
		mov	ah,al
		mov	WORD PTR HrznRhsCol,ax

		mov	cx,si
		and	si,000ffh	;si = y min

		sub	ch,cl		;y max - y min
		mov	cl,ch
		xor	ch,ch
		inc	cx		;num lines = (y max - y min) + 1

		mov	bp,_HorizonFill
		jmp	bp

HorizonFill	ENDP

;----------------------------------------------------------------------------

;* Null - null routine
;*
;* pass: nothing
;* ret : nothing
;* kill: nothing

Null		PROC	FAR

		ret

Null		ENDP

;----------------------------------------------------------------------------

;* SetAttributes - set print colour attributes
;*
;* pass: si -> data block
;*          [si+0] = HGC / HEM foreground colour
;*          [si+1] = HGC / HEM background colour
;*          [si+2] = CGA foreground colour
;*          [si+3] = CGA background colour
;*          [si+4] = EGA / TAN / TEM / V16 foreground colour
;*          [si+5] = EGA / TAN / TEM / V16 background colour
;*          [si+6] = VGA foreground colour
;*          [si+7] = VGA background colour
;*       ScreenMode
;* ret : ForeCol, BackCol
;* kill: ax, bx
;*
;* note: Some drivers use ForeCol and BackCol as words.

SetAttributes	PROC	FAR

		mov	bx,ScreenMode
		mov	bx,AttrTable[bx];look up data block offset

		mov	al,[si+bx]	;foreground colour
		mov	ah,al
		mov	WORD PTR ForeCol,ax

		mov	al,[si+bx+1]	;background colour
		mov	ah,al
		mov	WORD PTR BackCol,ax

		ret

SetAttributes	ENDP

;----------------------------------------------------------------------------

;* SetPalette - set palette colours
;*
;* pass: ds:si -> palette data
;* ret : nothing
;* kill: ax, cx, si, di

SetPalette	PROC	FAR

		push	es
		mov	ax,DATA
		mov	es,ax

		mov	cx,256
		mov	di,OFFSET Palette
		rep	movsb

		pop	es
		ret

SetPalette	ENDP

;----------------------------------------------------------------------------

;* SetSSpriteClip - set SSprite clip window
;*
;* pass: bl = y min
;*       bh = y max
;*       cx = x min
;*       dx = x max
;*       ScreenMode
;* ret : ClipXMin, ClipXMax
;*       ClipYMin, ClipYMax
;* kill: ax, bx, cx, dx, di, flags
;*
;* note: The x values are rounded down to the nearest byte wrt ScreenMode.

SetSSpriteClip	PROC	FAR

		mov	di,ScreenMode

		xor	ah,ah
		mov	al,bl
		mov	ClipYMin,ax
		mov	al,bh
		mov	ClipYMax,ax

		mov	ax,cx
		mov	cl,ClipXTable[di]

		shr	ax,cl
		shr	dx,cl

		mov	ClipXMin,ax
		mov	ClipXMax,dx

		ret

SetSSpriteClip	ENDP

GCODE		ENDS

;============================================================================

		END

