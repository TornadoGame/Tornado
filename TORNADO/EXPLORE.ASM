;****************************************************************************
;*
;* EXPLORE.ASM
;*
;* Map explore mode control routine.
;*
;* 15.01.1992 - KJB - Simple explore mode used for demonstration purposes.
;* 01.04.1992 - KJB - New explore mode.
;* 09.12.1992 - KJB - MAP_VIEW renamed EXP_VIEW.
;*	              MapZoom renamed ExpMapZoom.
;* 22.04.1993 - KJB - Theme music added.
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	MapExplore

		PUBLIC	EXP_VIEW
		PUBLIC	ExpMapZoom
		PUBLIC	X_CtrlDevice
		PUBLIC	X_XFine
		PUBLIC	X_YFine
		PUBLIC	X_ZFine
		PUBLIC	X_HFine
		PUBLIC	X_PFine
		PUBLIC	X_RFine
		PUBLIC	X_SinH
		PUBLIC	X_CosH
		PUBLIC	X_SinP
		PUBLIC	X_CosP
		PUBLIC	X_SinR
		PUBLIC	X_CosR
		PUBLIC	X_Vtas
		PUBLIC	X_Zdot
		PUBLIC	X_ElePosn
		PUBLIC	X_AilPosn
		PUBLIC	X_ThrotPosn

		EXTRN	InstallUser100:FAR
		EXTRN	CalcDeltaTime:FAR
		EXTRN	UpdateMovingMap:FAR
		EXTRN	DrawMapBorder:FAR
		EXTRN	SetMouseLimits:FAR
		EXTRN	SetMousePos:FAR
		EXTRN	ReadMouse:FAR
		EXTRN	DownLoad:FAR
		EXTRN	HLineDraw:FAR
		EXTRN	VLineDraw:FAR
		EXTRN	MoveViewpoint:FAR
		EXTRN	SetViewMode:FAR
		EXTRN	Visual:FAR
		EXTRN	BlockFill:FAR
		EXTRN	Print$:FAR
		EXTRN	RecalJoysticks:FAR
		EXTRN	ReadJoysticks:FAR
		EXTRN	CalcGndHeight:FAR
		EXTRN	UserVisOptions:FAR
		EXTRN	MapCompass:FAR
		EXTRN	VGAPhotoDflt:FAR
		EXTRN	VisualInfo:FAR
		EXTRN	RefreshMusic:FAR

		EXTRN	MouseXMin:WORD
		EXTRN	MouseXMax:WORD
		EXTRN	MouseYMin:WORD
		EXTRN	MouseYMax:WORD
		EXTRN	MouseX:WORD
		EXTRN	MouseY:WORD
		EXTRN	JoyVals:WORD
		EXTRN	JoyA_XVal:WORD
		EXTRN	JoyA_YVal:WORD
		EXTRN	JoyB_XVal:WORD
		EXTRN	JoyB_YVal:WORD
		EXTRN	WorkScrPtr:WORD
		EXTRN	DeltaTime:WORD
		EXTRN	SinTable:WORD
		EXTRN	CosTable:WORD
		EXTRN	SecScanCnt1:WORD

		EXTRN	Key:BYTE
		EXTRN	JoyA_Flag:BYTE
		EXTRN	JoyB_Flag:BYTE
		EXTRN	JoyA_Fire1:BYTE
		EXTRN	JoyA_Fire2:BYTE
		EXTRN	JoyB_Fire1:BYTE
		EXTRN	JoyB_Fire2:BYTE
		EXTRN	MouseFlag:BYTE
		EXTRN	LhsButton:BYTE
		EXTRN	RhsButton:BYTE
		EXTRN	_LhsButton:BYTE
		EXTRN	_RhsButton:BYTE
		EXTRN	KF_Range:BYTE
		EXTRN	KF_GndText:BYTE
		EXTRN	KF_HillText:BYTE
		EXTRN	KF_Clouds:BYTE
		EXTRN	KF_Horizon:BYTE
		EXTRN	KF_Minimise:BYTE
		EXTRN	KF_Recal:BYTE
		EXTRN	KF_JoySensNorm:BYTE
		EXTRN	KF_JoySensHigh:BYTE
		EXTRN	KF_Quit:BYTE
		EXTRN	JoySensitivity:BYTE
		EXTRN	DieFlag:BYTE

		EXTRN	MAP_BIG_DISP:ABS
		EXTRN	MAP_ZOOM1:ABS
		EXTRN	MAP_ZOOM6:ABS
		EXTRN	MAP_ORG_CENTRE:ABS

;============================================================================

		INCLUDE	MAINDATA.INC
		INCLUDE	CONFIG.INC

		INCLUDE	\VISUAL\VISDATA.INC
		INCLUDE	\VISUAL\VISMACRO.INC
		INCLUDE	\VISUAL\PALETTES.INC

		INCLUDE	\LIB8086\KEYS.INC
		INCLUDE	\LIB8086\PRINT.INC
		INCLUDE	\LIB8086\USEFUL.INC
		INCLUDE	\LIB8086\VGA_DRVR.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

;----------------------
;* large scale map data
;----------------------

EXP_VIEW	VIEWPOINT <16,16,0,0,Z_MIN>	;map viewpoint

ExpMapZoom 	DW	MAP_ZOOM1	;map zoom level

ReDrawMap	DB	0,0		;1 = redraw map

SCROLL_SPEED	EQU	2048		;scroll speed (ft / sec) for MAP_ZOOM6

;------------
;* mouse data
;------------

MOUSE_X_MIN	EQU	0
MOUSE_X_MAX	EQU	639
MOUSE_Y_MIN	EQU	0
MOUSE_Y_MAX	EQU	399

MOUSE_X_CENTRE	EQU	320
MOUSE_Y_CENTRE	EQU	200

MOUSE_X_DBAND	EQU	MOUSE_X_CENTRE/8	;x dead band
MOUSE_Y_DBAND	EQU	MOUSE_Y_CENTRE/8	;y dead band

MOUSE_X_SCALE	EQU	32768/(MOUSE_X_CENTRE-MOUSE_X_DBAND)
MOUSE_Y_SCALE	EQU	32768/(MOUSE_Y_CENTRE-MOUSE_Y_DBAND)

;--------------
;* locator data
;--------------

LOC_X_MIN	EQU	0
LOC_X_MAX	EQU	319
LOC_Y_MIN	EQU	0
LOC_Y_MAX	EQU	199

LocatorX	DW	160
LocatorY	DW	100

;-----------
;* key flags (also use key flags from model)
;-----------

KF_ToggleMode	GAMEKEY	<>	;toggle map / fly modes
KF_Keyboard	GAMEKEY	<>	;keyboard control
KF_Joystick	GAMEKEY	<>	;joystick control
KF_Mouse	GAMEKEY	<>	;mouse control

;------------
;* model data "X_" prefix used to avoid conflict with model vars
;------------

;* control device

CTRL_DEV_KBD	EQU	0		;keyboard
CTRL_DEV_JS1	EQU	2		;single joystick
CTRL_DEV_JS2	EQU	4		;dual joysticks
CTRL_DEV_MOUSE	EQU	6		;mouse

X_CtrlDevice	DW	CTRL_DEV_MOUSE

;* positional data

Z_MIN		EQU	16
Z_MAX		EQU	10000

X_XFine		DW	0
X_YFine		DW	0
X_ZFine		DW	0

;* attitude data

PITCH_MAX	EQU	35*128		;25 degs (keep horizon visible)
ROLL_MAX	EQU	0*128		;0 degs

X_HFine		DW	0
X_PFine		DW	0
X_RFine		DW	0

X_SinH		DW	0
X_CosH		DW	0
X_SinP		DW	0
X_CosP		DW	0
X_SinR		DW	0
X_CosR		DW	0

;* velocity data

V_MAX		EQU	10880		;(800kts * 1.7 = 1360ft/sec) * 8 scaling

X_Vtas		DW	0		;-V_MAX .. +V_MAX

X_Zdot		DW	0		;ft / sec (*8 scaling)

;* control positions

X_ElePosn	DW	0
X_AilPosn	DW	0
X_ThrotPosn	DW	0

;* rates

V_RATE		EQU	2*1360		;200kts / sec

HDG_RATE	EQU	64*128		;45 degs / sec

PITCH_RATE	EQU	43*128		;30 degs / sec
PITCH_WASH_RATE	EQU	25		;fine pdegs / sec (*100)

ROLL_RATE	EQU	64*128		;45 degs / sec
ROLL_WASH_RATE	EQU	50		;fine pdegs / sec (*100)

KBD_V_RATE	EQU	16
KBD_ELE_RATE	EQU	200
KBD_AIL_RATE	EQU	200

;----------------------
;* sort controls switch (wrt X_CtrlDevice)
;----------------------

SortCtrlSwitch	DW	SortCtrlKbd	;CTRL_DEV_KBD
		DW	SortCtrlJoy1	;CTRL_DEV_JS1
		DW	SortCtrlJoy2	;CTRL_DEV_JS2
		DW	SortCtrlMouse	;CTRL_DEV_MOUSE

;----------------------
;* init controls switch (wrt X_CtrlDevice)
;----------------------

InitCtrlSwitch	DW	InitKbd		;CTRL_DEV_KBD
		DW	InitJoy1	;CTRL_DEV_JS1
		DW	InitJoy2	;CTRL_DEV_JS2
		DW	InitMouse	;CTRL_DEV_MOUSE

;---------------
;* info bar data
;---------------

DispVkts	DW	0
DispHdg		DW	0
DispAlt		DW	0

;* visual ranges (index = (SecScanCnt1 - 3) / 2 = 0 .. 6)

DispRange	DW	0

VisRange	DB	6, 9, 12, 16, 19, 22, 25

		EVEN

;* control device strings (ptr = OFFSET CtrlDev$ + X_CtrlDevice * 6)

CtrlDevPtr	DW	OFFSET CtrlDev$

CtrlDev$	LABEL	BYTE

		DB	"KEYBOARD   ",0
		DB	"1 JOYSTICK ",0
		DB	"2 JOYSTICKS",0
		DB	"MOUSE      ",0

		EVEN

SpeedCol	DW	OFFSET TextCol2

TextCol1	DB	0ffh,000h,0ffh,000h,00bh,000h,COL_TEXT_NORM1,COL_BLACK
TextCol2	DB	0ffh,000h,055h,000h,00eh,000h,COL_TEXT_NORM2,COL_BLACK
AlertCol	DB	0ffh,000h,0aah,000h,00ch,000h,COL_TEXT_ALERT,COL_BLACK

Title$		LABEL	BYTE
		P_OVER0
		P_CHAR2
		PV_ATTR	TextCol1
		PD_XY	0*4,193
		DB	"SPEED=xxxxKTS "
		DB	"HDG=xxx~ "
		DB	"ALT=xxxxxFT "
		DB	"RANGE=xxMLS "
		DB	"CONTROL=xxxxxxxxxxx "
		DB	"VIEW="
		PV_ATTR	TextCol2
		DB	"EXPLORE"
		P_END

Info$		LABEL	BYTE
		P_OVER0
		P_CHAR2
		PP_ATTR	SpeedCol
		P_DECAT	00100100b	;(unsigned, 4 digits, leading zeroes)
		PD_XY	6*4,193
		PV_DECW	DispVkts
		PV_ATTR	TextCol2
		P_DECAT	00100011b	;(unsigned, 3 digits, leading zeroes)
		PD_X	18*4
		PV_DECW	DispHdg
		P_DECAT	00100101b	;(unsigned, 5 digits, leading zeroes)
		PD_X	27*4
		PV_DECW	DispAlt
		P_DECAT	00100010b	;(unsigned, 2 digits, leading zeroes)
		PD_X	41*4
		PV_DECW	DispRange
		PD_X	55*4
		PP_STR	CtrlDevPtr
		P_DECAT	00000000b	;(default)
		P_END

		EVEN

;-------------
;* 50Hz toggle
;-------------

Timer50		DB	0		;50Hz toggle

		EVEN

DATA		ENDS

;============================================================================

EXPCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:EXPCODE
		ASSUME DS:DATA

;* MapExplore - map explore mode
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

MapExplore	PROC	FAR

		call	InitMapExplore

ExploreLoop:	call	MapView
		KTEST	KF_Quit		;quit explore mode?
		jnz	ExploreExit	;yes ->

		call	FlyView
		KTEST	KF_Quit		;quit explore mode?
		jnz	ExploreExit	;yes ->

		jmp	ExploreLoop

ExploreExit:	call	BorderCheck	;ensure on map (for mission planner)

		mov	DieFlag,DIE_QUIT

		ret

MapExplore	ENDP

;----------------------------------------------------------------------------

;* InitMapExplore - initialize map explore mode
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

InitMapExplore	PROC	NEAR

;* install user timer interrupt

		mov	ax,OFFSET ExploreIntr100
		mov	dx,SEG ExploreIntr100
		call	InstallUser100

;* initialize mouse

		mov	MouseXMin,MOUSE_X_MIN
		mov	MouseXMax,MOUSE_X_MAX
		mov	MouseYMin,MOUSE_Y_MIN
		mov	MouseYMax,MOUSE_Y_MAX

		call	SetMouseLimits

		ret

InitMapExplore	ENDP

;----------------------------------------------------------------------------

;* MapView
;*
;* pass: EXP_VIEW
;* ret : EXP_VIEW
;* kill: assume all

MapView		PROC	NEAR

		call	InitMapView

MapLoop:	call	UpdateKeys

		call	CalcDeltaTime

		call	ReadMouse

		test	dl,dl		;lh button pressed?
		jz	@F		;no ->
		call	MapZoomIn
		jmp	ContMap

@@:		test	dh,dh		;rh button pressed?
		jz	@F		;no ->
		call	MapZoomOut
		jmp	ContMap

@@:		call	ScrollMap

ContMap:	call	DrawMap

		call	DrawLocator

		call	DownLoad

		KTEST	KF_ToggleMode	;toggle mode?
		jnz	ExitMapView	;yes ->
		KTEST	KF_Quit		;quit explore mode?
		jnz	ExitMapView	;yes ->

		jmp	MapLoop

ExitMapView:	ret

MapView		ENDP

;----------------------------------------------------------------------------

;* InitMapView
;*
;* pass: EXP_VIEW
;* ret : EXP_VIEW
;* kill: assume all

InitMapView	PROC	NEAR

		mov	EXP_VIEW.VP_HDG,0

;* draw map

		mov	ReDrawMap,1

		call	DrawMap

;* move locator to screen centre

		mov	cx,MOUSE_X_CENTRE
		mov	bx,MOUSE_Y_CENTRE
		call	SetMousePos

		call	DrawLocator

		call	DownLoad

		ret

InitMapView	ENDP

;----------------------------------------------------------------------------

;* DrawMap
;*
;* pass: EXP_VIEW
;*       ReDrawMap
;* ret : nothing
;* kill: assume all

DrawMap		PROC	NEAR

		test	ReDrawMap,1	;redraw map?
		jz	@F		;no ->

		call	BorderCheck

;* redraw map and save to buffer

		mov	ax,MAP_BIG_DISP
		xor	cx,cx
		xor	bl,bl
		xor	bh,bh
		mov	dx,ExpMapZoom
		mov	bp,MAP_ORG_CENTRE
		mov	si,OFFSET EXP_VIEW

		call	UpdateMovingMap

		call	DrawMapBorder

		xor	ax,ax
		mov	dx,ExpMapZoom
		call	MapCompass

		call	SaveMap

		mov	ReDrawMap,0

		jmp	ExitDrawMap

;* draw map from buffer

@@:		call	LoadMap

ExitDrawMap:	ret

DrawMap		ENDP

;----------------------------------------------------------------------------

;* SaveMap - copy map from work screen to buffer
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all
;*
;* note: VGA ONLY

SaveMap		PROC	NEAR

		push	ds
		push	es

		SETREGV	VGA_SEQ,VGA_SEQ_MAPMSK,1111b

		SLCTREG	VGA_CTRL,VGA_CTRL_MODE
		in	al,dx
		or	al,01b		;write mode 1
		out	dx,al

		mov	ax,VGA_PAGE_2
		mov	es,ax
		mov	ax,WorkScrPtr
		mov	ds,ax

		xor	si,si
		xor	di,di
		
		mov	cx,80*200

		rep	movsb
		
		in	al,dx
		and	al,NOT 11b	;write mode 0
		out	dx,al

		pop	es
		pop	ds

		ret

SaveMap		ENDP

;----------------------------------------------------------------------------

;* LoadMap - copy map from buffer to work screen
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all
;*
;* note: VGA ONLY

LoadMap		PROC	NEAR

		push	ds
		push	es

		SETREGV	VGA_SEQ,VGA_SEQ_MAPMSK,1111b

		SLCTREG	VGA_CTRL,VGA_CTRL_MODE
		in	al,dx
		or	al,01b		;write mode 1
		out	dx,al

		mov	ax,WorkScrPtr
		mov	es,ax
		mov	ax,VGA_PAGE_2
		mov	ds,ax

		xor	si,si
		xor	di,di
		
		mov	cx,80*200

		rep	movsb
		
		in	al,dx
		and	al,NOT 11b	;write mode 0
		out	dx,al

		pop	es
		pop	ds

		ret

LoadMap		ENDP

;----------------------------------------------------------------------------

;* MapZoomIn
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

MapZoomIn	PROC	NEAR

		call	CalcNewPos

		cmp	ExpMapZoom,MAP_ZOOM6	;fully zoomed in?
		je	@F			;yes ->

		add	ExpMapZoom,2

@@:		mov	ReDrawMap,1

		ret

MapZoomIn	ENDP

;----------------------------------------------------------------------------

;* MapZoomOut
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

MapZoomOut	PROC	NEAR

		call	CalcNewPos

		cmp	ExpMapZoom,MAP_ZOOM1	;fully zoomed out?
		je	@F			;yes ->

		sub	ExpMapZoom,2

@@:		mov	ReDrawMap,1

		ret

MapZoomOut	ENDP

;----------------------------------------------------------------------------

;* ScrollMap
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

ScrollMap	PROC	NEAR

;-------------------------------------
;* check mouse position for map scroll
;-------------------------------------

		xor	cx,cx		;assume no x scroll
		xor	bx,bx		;assume no y scroll

		cmp	LocatorX,LOC_X_MIN	;scroll map right?
		jne	@F			;no ->
		mov	cx,-SCROLL_SPEED

@@:		cmp	LocatorX,LOC_X_MAX	;scroll map left?
		jne	@F		     	;no ->
		mov	cx,SCROLL_SPEED

@@:		cmp	LocatorY,LOC_Y_MIN	;scroll map down?
		jne	@F			;no ->
		mov	bx,SCROLL_SPEED

@@:		cmp	LocatorY,LOC_Y_MAX	;scroll map up?
		jne	@F			;no ->
		mov	bx,-SCROLL_SPEED

@@:		mov	ax,cx
		or	ax,bx		;scroll?
		jz	ExitScroll	;no ->

;-----------------------------------
;* scroll dist = scroll speed * time
;-----------------------------------

		mov	bp,DeltaTime

		mov	ax,cx
		imul	bp
		FRACADJ	cx

		mov	ax,bx
		imul	bp
		FRACADJ	bx

		mov	ax,bx
		cwd
		xchg	cx,ax
		mov	bx,dx
		xchg	bx,cx		;cx, bx = y dist

		cwd			;dx, ax = x dist

;----------------------------
;* adjust dist wrt zoom level
;----------------------------

;* shift count = 10 - ExpMapZoom (10 .. 0 step 2)

		mov	bp,10
		sub	bp,ExpMapZoom
		jz	SkipDistScale

@@:		shl	ax,1
		rcl	dx,1
		shl	bx,1
		rcl	cx,1
		sub	bp,2
		jnz	@B

SkipDistScale:	mov	si,OFFSET EXP_VIEW
		call	MoveViewpoint
  
		mov	ReDrawMap,1

ExitScroll:	ret

ScrollMap	ENDP

;----------------------------------------------------------------------------

;* BorderCheck - check viewpoint is in active map area
;*
;* pass: EXP_VIEW
;* ret : EXP_VIEW
;* kill: flags

BorderCheck	PROC	NEAR

		cmp	EXP_VIEW.VP_XSEC,0
		jge	@F
		mov	EXP_VIEW.VP_XSEC,0
		mov	EXP_VIEW.VP_XFT,-8192

@@:		cmp	EXP_VIEW.VP_XSEC,31
		jle	@F
		mov	EXP_VIEW.VP_XSEC,31
		mov	EXP_VIEW.VP_XFT,8191

@@:		cmp	EXP_VIEW.VP_YSEC,0
		jge	@F
		mov	EXP_VIEW.VP_YSEC,0
		mov	EXP_VIEW.VP_YFT,8191

@@:		cmp	EXP_VIEW.VP_YSEC,31
		jle	@F
		mov	EXP_VIEW.VP_YSEC,31
		mov	EXP_VIEW.VP_YFT,-8192

@@:		ret

BorderCheck	ENDP

;----------------------------------------------------------------------------

;* DrawLocator
;*
;* pass: MouseX
;*       MouseY
;* ret : LocatorX
;*       LocatorY
;* kill: assume all

DrawLocator	PROC	NEAR

;------------------------------
;* calc locator centre position
;------------------------------

		mov	cx,MouseX
		shr	cx,1
		adc	cx,0
		cmp	cx,LOC_X_MAX
		jbe	@F
		mov	cx,LOC_X_MAX
@@:		mov	LocatorX,cx

		mov	bx,MouseY
		shr	bx,1
		adc	bx,0
		cmp	bx,LOC_Y_MAX
		jbe	@F
		mov	bx,LOC_Y_MAX
@@:		mov	LocatorY,bx

;------------------------
;* draw locator (clipped)
;------------------------

;* locator shape:-
;*
;*              ³ (a)
;*              ³
;*      (c) ÄÄÄÄ ÄÄÄÄ (d)
;*              ³
;*              ³ (b)

;* draw stroke (a)

		push	bx
		push	cx

		sub	bl,2
		jc	SkipA

		mov	bh,bl
		sub	bh,4
		jnc	@F
		xor	bh,bh

@@:		mov	al,COL_LOCATOR
		call	VLineDraw

SkipA:		pop	cx
		pop	bx

;* draw stroke (b)

		push	bx
		push	cx

		add	bl,2
		cmp	bl,LOC_Y_MAX
		ja	SkipB

		mov	bh,bl
		add	bh,4
		cmp	bh,LOC_Y_MAX
		jbe	@F
		mov	bh,LOC_Y_MAX

@@:		mov	al,COL_LOCATOR
		call	VLineDraw

SkipB:		pop	cx
		pop	bx

;* draw stroke (c)

		push	bx
		push	cx

		sub	cx,2
		jc	SkipC

		mov	dx,cx
		sub	dx,5
		jnc	@F
		xor	dx,dx

@@:		mov	al,COL_LOCATOR
		call	HLineDraw

SkipC:		pop	cx
		pop	bx

;* draw stroke (d)

		add	cx,2
		cmp	cx,LOC_X_MAX
		ja	SkipD

		mov	dx,cx
		add	dx,5
		cmp	dx,LOC_X_MAX
		jbe	@F
		mov	dx,LOC_X_MAX

@@:		mov	al,COL_LOCATOR
		call	HLineDraw

SkipD:		ret

DrawLocator	ENDP

;----------------------------------------------------------------------------

;* CalcNewPos
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

CalcNewPos	PROC	NEAR

;* calc position scale wrt zoom:-
;*
;* MAP_ZOOM1 =   8 pixels / sector = 1024ft / mouse pos (<< 10)
;* MAP_ZOOM2 =  16 pixels / sector =  512ft / mouse pos (<< 9)
;* MAP_ZOOM3 =  32 pixels / sector =  256ft / mouse pos (<< 8)
;* MAP_ZOOM4 =  64 pixels / sector =  128ft / mouse pos (<< 7)
;* MAP_ZOOM5 = 128 pixels / sector =   64ft / mouse pos (<< 6)
;* MAP_ZOOM6 = 256 pixels / sector =   32ft / mouse pos (<< 5)
;*
;* scale = 10 - (zoom / 2)

		mov	bp,10
		mov	ax,ExpMapZoom
		shr	ax,1
		sub	bp,ax

;* y offset = -(MouseY - MOUSE_Y_CENTRE) << scale

		mov	ax,MouseY
		sub	ax,MOUSE_Y_CENTRE
		neg	ax
		cwd

		mov	cx,dx
		mov	bx,ax

;* x offset = ((MouseX - MOUSE_X_CENTRE) * 26214 / 32768) << scale

		mov	ax,MouseX
		sub	ax,MOUSE_X_CENTRE
		mov	dx,26214	;aspect ratio correction
		imul	dx
		FRACADJ	ax
		cwd

		xchg	cx,bp

@@:		shl	ax,1		;scale up wrt zoom
		rcl	dx,1
		shl	bx,1
		rcl	bp,1
		loop	@B

		mov	cx,bp

		mov	si,OFFSET EXP_VIEW
		call	MoveViewpoint

;* move locator to screen centre

		mov	cx,MOUSE_X_CENTRE
		mov	bx,MOUSE_Y_CENTRE
		call	SetMousePos

		ret

CalcNewPos	ENDP

;----------------------------------------------------------------------------

;* FlyView - fly around map
;*
;* pass: EXP_VIEW
;* ret : EXP_VIEW
;* kill: assume all

FlyView		PROC	NEAR

		call	InitFlyView

FlyLoop:	call	UpdateKeys

		call	UserOptions

		call	CalcDeltaTime

		call	ExploreModel

		mov	si,OFFSET EXP_VIEW
		call	Visual

		call	DispInfoBar

	IF	OPT_DEBUG EQ 1

		test	Key[K_F11],1
		jz	@F
		call	VisualInfo
@@:	
	
	ENDIF

		call	DownLoad

	IF	OPT_PHOTO EQ 1

		test	Key[K_F12],1
		jz	@F
		call	VGAPhotoDflt
@@:	
	
	ENDIF

		KTEST	KF_ToggleMode	;toggle mode?
		jnz	ExitFlyView	;yes ->
		KTEST	KF_Quit		;quit explore mode?
		jnz	ExitFlyView	;yes ->

		jmp	FlyLoop

ExitFlyView:	ret

FlyView		ENDP

;----------------------------------------------------------------------------

;* InitFlyView
;*
;* pass: EXP_VIEW
;* ret : EXP_VIEW
;* kill: assume all

InitFlyView	PROC	NEAR

;* initialize explore model

		call	InitExpModel

;* set full screen visual

		mov	ax,EXT_VIEWMODE
		call	SetViewMode

;* generate visual and clear info bar on both screens

		mov	si,OFFSET EXP_VIEW
		call	Visual

		call	ClearInfoBar

		call	DownLoad

		call	ClearInfoBar

		ret

InitFlyView	ENDP

;----------------------------------------------------------------------------

;* InitExpModel - initialize explore model
;*
;* pass: EXP_VIEW
;* ret : EXP_VIEW
;* kill: assume all

InitExpModel	PROC	NEAR

;* init model vars

		xor	ax,ax

		mov	X_XFine,ax
		mov	X_YFine,ax
		mov	X_ZFine,ax

		mov	X_PFine,ax
		mov	X_RFine,ax

		mov	X_Vtas,ax
		mov	X_Zdot,ax

		mov	X_ElePosn,ax
		mov	X_AilPosn,ax

;* init viewpoint

		mov	si,OFFSET EXP_VIEW
		call	CalcGndHeight

		add	ax,Z_MIN

		cmp	ax,WORD PTR EXP_VIEW.VP_ZFT_LO	;z min < z?
		jbe	@F				;yes ->

		mov	WORD PTR EXP_VIEW.VP_ZFT_LO,ax

@@:		mov	WORD PTR EXP_VIEW.VP_ZFT_HI,0

		call	CalcAngles

;* init control device

		call	InitCtrlDevice

		ret

InitExpModel	ENDP

;----------------------------------------------------------------------------

;* ExploreModel - explore model
;*
;* pass: EXP_VIEW
;* ret : EXP_VIEW
;* kill: assume all

ExploreModel	PROC	NEAR

;-----------------
;* update controls
;-----------------

		call	SortControls

;--------------
;* update speed
;--------------

;* v rate = X_ThrotPosn * V_RATE

		mov	ax,X_ThrotPosn
		mov	dx,V_RATE
		imul	dx
		FRACADJ	dx

;* delta v rate = v rate * DeltaTime

		mov	ax,DeltaTime
		imul	dx
		FRACADJ	dx

;* X_Vtas = SBOUND(X_Vtas - delta v rate, -V_MAX, V_MAX)

		mov	ax,X_Vtas
		sub	ax,dx

		SBOUND	ax,-V_MAX,V_MAX

		mov	X_Vtas,ax

;----------------
;* update heading
;----------------

;* hdg rate = X_AilPosn * HDG_RATE

		mov	ax,X_AilPosn
		mov	dx,HDG_RATE
		imul	dx
		FRACADJ	dx

;* delta hdg rate = hdg rate * DeltaTime

		mov	ax,DeltaTime
		imul	dx
		FRACADJ	dx

;* X_HFine = X_HFine + delta hdg rate

		add	X_HFine,dx

;--------------
;* update pitch
;--------------

;* pitch rate = X_ElePosn * PITCH_RATE

		mov	ax,X_ElePosn
		mov	dx,PITCH_RATE
		imul	dx
		FRACADJ	dx

;* delta pitch rate = pitch rate * DeltaTime

		mov	ax,DeltaTime
		imul	dx
		FRACADJ	dx

;* X_PFine = SBOUND(X_PFine + delta pitch rate, -PITCH_MAX, PITCH_MAX)

		mov	ax,X_PFine
		add	ax,dx

		SBOUND	ax,-PITCH_MAX,PITCH_MAX

		mov	X_PFine,ax

;-------------
;* update roll
;-------------

;* roll rate = X_AilPosn * ROLL_RATE

		mov	ax,X_AilPosn
		mov	dx,ROLL_RATE
		imul	dx
		FRACADJ	dx

;* delta roll rate = roll rate * DeltaTime

		mov	ax,DeltaTime
		imul	dx
		FRACADJ	dx

;* X_RFine = SBOUND(X_RFine + delta roll rate, -ROLL_MAX, ROLL_MAX)

		mov	ax,X_RFine
		add	ax,dx

		SBOUND	ax,-ROLL_MAX,ROLL_MAX

		mov	X_RFine,ax

;-------------
;* calc angles
;-------------

		call	CalcAngles

;----------
;* position
;----------

;* delta x = X_Vtas * X_CosP * X_SinH * DeltaTime * 8192

		mov	ax,X_Vtas
		mov	dx,X_CosP
		imul	dx
		FRACADJ	dx
		mov	ax,X_SinH
		imul	dx
		FRACADJ	dx
		mov	ax,DeltaTime
		imul	dx
		FRACADJ	ax

		cwd	  		;*256
		mov	dl,ah
		mov	ah,al
		xor	al,al

		REPT	5		;*32 (*8192)
		shl	ax,1
		rcl	dx,1
		ENDM

;* update x position (with sector change test)
		
		add	X_XFine,ax
		adc	dx,EXP_VIEW.VP_XFT

		cmp	dx,8192		;xft < 8192?
		jl	@F		;yes ->
		sub	dx,16384
		inc	EXP_VIEW.VP_XSEC

@@:		cmp	dx,-8192	;xft >= -8192?
		jge	@F		;yes ->
		add	dx,16384
		dec	EXP_VIEW.VP_XSEC

@@:		mov	EXP_VIEW.VP_XFT,dx

;* delta y = X_Vtas * X_CosP * X_CosH * DeltaTime * 8192

		mov	ax,X_Vtas
		mov	dx,X_CosP
		imul	dx
		FRACADJ	dx
		mov	ax,X_CosH
		imul	dx
		FRACADJ	dx
		mov	ax,DeltaTime
		imul	dx
		FRACADJ	ax

		cwd	  		;*256
		mov	dl,ah
		mov	ah,al
		xor	al,al

		REPT	5		;*32 (*8192)
		shl	ax,1
		rcl	dx,1
		ENDM
		
;* update y position (with sector change test)
		
		add	X_YFine,ax
		adc	dx,EXP_VIEW.VP_YFT

		cmp	dx,8192		;yft < 8192?
		jl	@F		;yes ->
		sub	dx,16384
		dec	EXP_VIEW.VP_YSEC

@@:		cmp	dx,-8192	;yft >= -8192?
		jge	@F		;yes ->
		add	dx,16384
		inc	EXP_VIEW.VP_YSEC

@@:		mov	EXP_VIEW.VP_YFT,dx

;----------
;* altitude
;----------

;* min alt = ground height + Z_MIN

		mov	si,OFFSET EXP_VIEW
		call	CalcGndHeight

		add	ax,Z_MIN

		mov	bp,ax

		mov	ax,X_Vtas
		ABSV	ax
		add	ax,1360		;k = 100kts
		mov	dx,X_SinP
		imul	dx
		FRACADJ	dx

		mov	X_Zdot,dx

;* VP_ZFT_LO, X_ZFine = VP_ZFT_LO, X_ZFine + (Zdot * DeltaTime * 8192)

;* sort computation order wrt accuracy and overflow

		cmp	dx,127
		jg	@F		;method 2 ->
		cmp	dx,-128
		jl	@F		;method 2 ->

;* method 1: calc Zdot * 256 * DeltaTime (for max accuracy)

		mov	dh,dl
		xor	dl,dl		;Zdot * 256

		mov	ax,DeltaTime
		imul	dx
		FRACADJ	ax		;Zdot * 256 * DeltaTime

		cwd

		jmp	ContCalcAlt

;* method 2: calc Zdot * DeltaTime * 256 (to prevent overflow)

@@:		mov	ax,DeltaTime
		imul	dx
		FRACADJ	ax		;Zdot * DeltaTime

		cwd	  		;Zdot * DeltaTime * 256
		mov	dl,ah
		mov	ah,al
		xor	al,al

ContCalcAlt:	REPT	5		;Zdot * DeltaTime * 256 * 32 (*8192)
		shl	ax,1
		rcl	dx,1
		ENDM

		add	ax,X_ZFine
		adc	dx,WORD PTR EXP_VIEW.VP_ZFT_LO

		cmp	dx,bp		;zft < min alt?
		jge	@F		;no ->
		mov	dx,bp
		xor	ax,ax

@@:		cmp	dx,Z_MAX	;zft > max alt?
		jle	@F		;no ->
		mov	dx,Z_MAX
		xor	ax,ax

@@:		mov	X_ZFine,ax
		mov	WORD PTR EXP_VIEW.VP_ZFT_LO,dx

		ret

ExploreModel	ENDP

;----------------------------------------------------------------------------

;* CalcAngles
;*
;* pass: HFine
;*       PFine
;*       RFine
;* ret : EXP_VIEW
;*       X_SinH, X_CosH
;*       X_SinP, X_CosP
;*       X_SinR, X_CosR
;* kill: assume all

CalcAngles	PROC	NEAR

		mov	cl,7		;/128

;* VP_HDG = X_HFine / 128

		mov	bx,X_HFine
		shr	bx,cl
		ROUNDUP	bx
		and	bx,001ffh
		mov	EXP_VIEW.VP_HDG,bx

		shl	bx,1		;*2 word index
		mov	ax,SinTable[bx]
		mov	X_SinH,ax
		mov	ax,CosTable[bx]
		mov	X_CosH,ax

;* VP_PITCH = X_PFine / 128

		mov	bx,X_PFine
		shr	bx,cl
		ROUNDUP	bx
		and	bx,001ffh
		mov	EXP_VIEW.VP_PITCH,bx

		shl	bx,1		;*2 word index
		mov	ax,SinTable[bx]
		mov	X_SinP,ax
		mov	ax,CosTable[bx]
		mov	X_CosP,ax

;* VP_ROLL = X_RFine / 128

		mov	bx,X_RFine
		shr	bx,cl
		ROUNDUP	bx
		and	bx,001ffh
		mov	EXP_VIEW.VP_ROLL,bx

		shl	bx,1		;*2 word index
		mov	ax,SinTable[bx]
		mov	X_SinR,ax
		mov	ax,CosTable[bx]
		mov	X_CosR,ax

		ret

CalcAngles	ENDP

;----------------------------------------------------------------------------

;* SortControls - sort controls (joystick(s) / mouse)
;*
;* pass: X_CtrlDevice
;* ret : X_ElePosn
;*       X_AilPosn
;*       X_Vtas

SortControls	PROC	NEAR

		mov	bx,X_CtrlDevice
		jmp	SortCtrlSwitch[bx]

;---------------------------
SortCtrlKbd	LABEL	NEAR
;---------------------------

		ret

;---------------------------
SortCtrlJoy1	LABEL	NEAR
;---------------------------

;* pitch up (climb) ..... joystick backwards
;* pitch down (dive) .... joystick forwards
;* roll right ........... joystick right
;* roll left ............ joystick left
;*
;* inc speed ............ joystick forwards + fire button 1
;* dec speed ............ joystick backwards + fire button 1
;*
;* stop dead ............ fire button 2

		call	ReadJoysticks

		test	JoyA_Flag,1	;single joystick fitted?
		jnz	@F	   	;yes ->

		call	InitCtrlDevice

		jmp	SortCtrlKbd	;assume default to keyboard

@@:		mov	bx,JoyA_XVal
		shl	bx,1
		mov	ax,JoyVals[bx]
		mov	X_AilPosn,ax

		mov	bx,JoyA_YVal
		shl	bx,1
		mov	ax,JoyVals[bx]

		xor	dx,dx

		test	JoyA_Fire1,1	;adjust pitch or throttle?
		jz	@F		;pitch ->

		xchg	ax,dx

@@:		mov	X_ElePosn,ax
		mov	X_ThrotPosn,dx

		test	JoyA_Fire2,1	;stop dead?
		jz	@F		;no ->

		mov	X_Vtas,0
		mov	X_ThrotPosn,0

@@:		ret

;---------------------------
SortCtrlJoy2	LABEL	NEAR
;---------------------------

;* pitch up (climb) ..... joystick A backwards
;* pitch down (dive) .... joystick A forwards
;* roll right ........... joystick A right
;* roll left ............ joystick A left
;*
;* inc speed ............ joystick B forwards
;* dec speed ............ joystick B backwards
;*
;* stop dead ............ any fire button

		call	ReadJoysticks

		mov	al,JoyA_Flag
		test	al,JoyB_Flag 	;both joysticks fitted?
		jnz	@F	     	;yes ->

		call	InitCtrlDevice

		jmp	SortCtrlKbd	;assume default to keyboard

@@:		mov	bx,JoyA_XVal
		shl	bx,1
		mov	ax,JoyVals[bx]
		mov	X_AilPosn,ax

		mov	bx,JoyA_YVal
		shl	bx,1
		mov	ax,JoyVals[bx]
		mov	X_ElePosn,ax

		mov	bx,JoyB_YVal
		shl	bx,1
		mov	ax,JoyVals[bx]
		mov	X_ThrotPosn,ax

;* stop dead if any fire button pressed

		mov	al,JoyA_Fire1
		or	al,JoyA_Fire2
		or	al,JoyB_Fire1
		or	al,JoyB_Fire2
		jz	@F		;no ->

		mov	X_Vtas,0
		mov	X_ThrotPosn,0

@@:		ret

;---------------------------
SortCtrlMouse	LABEL	NEAR
;---------------------------

;* pitch up (climb) ..... mouse forwards
;* pitch down (dive) .... mouse backwards
;* roll right ........... mouse right
;* roll left ............ mouse left
;*
;* inc speed ............ mouse forwards + lh button
;* dec speed ............ mouse backwards + lh button
;*
;* stop dead ............ lh button + rh button
;*
;* centre mouse ......... rh button

		call	ReadMouse

;* if lh button just released then centre y to prevent unwanted pitch change

		mov	al,LhsButton
		sub	al,_LhsButton	;cf = 1 = 1 -> 0 transtion
		jnc	@F

		mov	cx,MouseX
		mov	bx,MOUSE_Y_CENTRE
		call	SetMousePos

@@:		mov	ax,MouseX
		sub	ax,MOUSE_X_CENTRE
		ABSV	ax
		mov	bp,dx
		sub	ax,MOUSE_X_DBAND
		jnc	@F
		xor	ax,ax
@@:		mov	dx,MOUSE_X_SCALE
		mul	dx
		xor	ax,bp
		sub	ax,bp
		mov	X_AilPosn,ax

		mov	ax,MouseY
		sub	ax,MOUSE_Y_CENTRE
		ABSV	ax
		mov	bp,dx
		sub	ax,MOUSE_Y_DBAND
		jnc	@F
		xor	ax,ax
@@:		mov	dx,MOUSE_Y_SCALE
		mul	dx
		xor	ax,bp
		sub	ax,bp

		xor	dx,dx

		test	LhsButton,1	;adjust pitch or throttle?
		jz	@F		;pitch ->

		xchg	ax,dx

@@:		mov	X_ElePosn,ax
		mov	X_ThrotPosn,dx

		mov	al,LhsButton
		and	al,RhsButton	;stop dead?
		jz	@F		;no ->

		mov	X_Vtas,0
		mov	X_ThrotPosn,0

@@:		test	RhsButton,1	;centre mouse ->
		jz	@F		;no ->

		mov	cx,MOUSE_X_CENTRE
		mov	bx,MOUSE_Y_CENTRE
		call	SetMousePos

@@:		ret

SortControls	ENDP

;----------------------------------------------------------------------------

;* InitCtrlDevice - initialize control device
;*
;* pass: X_CtrlDevice
;* ret : nothing
;* kill: assume all

InitCtrlDevice	PROC	NEAR

		xor	ax,ax
		mov	X_ElePosn,ax
		mov	X_AilPosn,ax
		mov	X_ThrotPosn,ax

		call	RecalJoysticks

		mov	bx,X_CtrlDevice
		jmp	InitCtrlSwitch[bx]

;---------------------------
InitKbd		LABEL	NEAR
;---------------------------

		mov	X_CtrlDevice,CTRL_DEV_KBD

		ret

;---------------------------
InitJoy1	LABEL	NEAR
;---------------------------

;* if single joystick not fitted then default to keyboard

		test	JoyA_Flag,1	;joystick fitted?
		jz	InitKbd		;no ->

		ret

;---------------------------
InitJoy2	LABEL	NEAR
;---------------------------

;* if both joysticks not fitted then default to keyboard

		mov	al,JoyA_Flag
		test	al,JoyB_Flag	;joysticks fitted?
		jz	InitKbd		;no ->

		ret

;---------------------------
InitMouse	LABEL	NEAR
;---------------------------

;* if mouse not fitted then default to keyboard

		test	MouseFlag,1	;mouse fitted?
		jz	InitKbd		;no ->

		mov	cx,MOUSE_X_CENTRE
		mov	bx,MOUSE_Y_CENTRE
		call	SetMousePos

		ret

InitCtrlDevice	ENDP

;----------------------------------------------------------------------------

;* ClearInfoBar - clear info bar and print data
;* DispInfoBar - print info bar data
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

ClearInfoBar	LABEL	NEAR

		mov	al,COL_BLACK
		mov	cx,0
		mov	bl,192
		mov	dx,319
		mov	bh,199
		call	BlockFill

		mov	si,OFFSET Title$
		call	Print$

DispInfoBar	PROC	NEAR

;-------
;* speed
;-------

;* DispVkts = X_Vtas * 2409 / 32768

		mov	SpeedCol,OFFSET TextCol2	;assume forwards

		mov	ax,X_Vtas
		test	ax,ax		;flying forwards?
		jns	@F		;yes ->

		mov	SpeedCol,OFFSET AlertCol

		neg	ax

@@:		mov	dx,2409
		imul	dx
		FRACADJ	dx
		mov	DispVkts,dx

;---------
;* heading
;---------

		mov	ax,X_HFine
		mov	dx,360
		mul	dx
		shl	ax,1		
		ROUNDUP	dx
		jnz	@F

		mov	dx,360		;display 0 as 360

@@:		mov	DispHdg,dx

;----------
;* altitude
;----------

		mov	ax,WORD PTR EXP_VIEW.VP_ZFT_LO
		mov	DispAlt,ax

;--------------
;* visual range
;--------------

		mov	bx,SecScanCnt1		;3 .. 15
		sub	bx,3			;0 .. 12
		shr	bx,1			;0 .. 6

		mov	al,VisRange[bx]

		mov	BYTE PTR DispRange,al

;----------------
;* control device
;----------------

		mov	ax,X_CtrlDevice
		shl	ax,1		;*2
		add	ax,X_CtrlDevice	;*3
		shl	ax,1		;*6
		add	ax,OFFSET CtrlDev$
		mov	CtrlDevPtr,ax

		mov	si,OFFSET Info$
		call	Print$

		ret

DispInfoBar	ENDP

;----------------------------------------------------------------------------

;* ExploreIntr100 - 100Hz interrupt routine
;*
;* pass: nothing
;* ret : nothing
;* kill: nothing

ExploreIntr100	PROC	FAR

;--------------------
;* update theme music
;--------------------

		xor	Timer50,1	;toggle 50Hz
		jz	@F		;skip ->

		call	RefreshMusic

;-----------
;* scan keys
;-----------

@@:		KUPDATE	KF_ToggleMode,K_SPACE,_OR_,K_ENTER
		KUPDATE	KF_Quit,K_CTRL,_AND_,K_Q
		KUPDATE	KF_Range,K_1
		KUPDATE	KF_GndText,K_2
		KUPDATE	KF_HillText,K_3
		KUPDATE	KF_Clouds,K_4
		KUPDATE	KF_Horizon,K_5
		KUPDATE	KF_Minimise,K_0
		KUPDATE	KF_Keyboard,K_K
		KUPDATE	KF_Joystick,K_J
		KUPDATE	KF_Mouse,K_M
		KUPDATE	KF_Recal,K_Y
		KUPDATE	KF_JoySensNorm,K_CTRL,_AND_,K_Y
		KUPDATE	KF_JoySensHigh,K_SHIFT,_AND_,K_Y

;------------------
;* keyboard control
;------------------

;* pitch up (climb) ..... cursor down
;* pitch down (dive) .... cursor up
;* roll right ........... cursor right
;* roll left ............ cursor left
;*
;* inc speed ............ '+'
;* dec speed ............ '-'
;*
;* stop dead ............ num keypad '5'

		cmp	X_CtrlDevice,CTRL_DEV_KBD	;kbd?
		jne	WashRoll			;no ->

;* elevators

		mov	bl,Key[K_CRSRDN]	;pitch up
		shl	bl,1
		or	bl,Key[K_CRSRUP]	;pitch down

		mov	ax,X_ElePosn
		mov	dx,KBD_ELE_RATE
		call	UpdatePosn
		mov	X_ElePosn,ax

;* ailerons

		mov	bl,Key[K_CRSRRT]	;roll right
		shl	bl,1
		or	bl,Key[K_CRSRLF]	;roll left

		mov	ax,X_AilPosn
		mov	dx,KBD_AIL_RATE
		call	UpdatePosn
		mov	X_AilPosn,ax

;* speed (change Vtas directly - do not go via X_ThrotPosn)

		xor	ax,ax		;assume stop dead

		test	Key[K_CENTRE],1	;stop dead?
		jnz	SetSpeed	;yes ->

		mov	ax,X_Vtas

		test	Key[K_PLUS],1	;inc speed?
		jz	@F		;no ->

		add	ax,KBD_V_RATE

@@:		test	Key[K_MINUS],1	;dec speed?
		jz	@F		;no ->

		sub	ax,KBD_V_RATE

@@:		SBOUND	ax,-V_MAX,V_MAX

SetSpeed:	mov	X_Vtas,ax

;--------------
;* washout roll
;--------------

WashRoll:	cmp	X_AilPosn,0	;ailerons active?
		jne	WashPitch	;yes ->

		mov	ax,X_RFine
		ABSV	ax
		sub	ax,ROLL_WASH_RATE
		jnc	@F
		xor	ax,ax
@@:		xor	ax,dx		;restore sign
		sub	ax,dx

		mov	X_RFine,ax

;---------------
;* washout pitch
;---------------

WashPitch:	cmp	X_ElePosn,0	;elevators active?
		jne	ExitIntr100	;yes ->

		mov	ax,X_PFine
		ABSV	ax
		sub	ax,PITCH_WASH_RATE
		jnc	@F
		xor	ax,ax
@@:		xor	ax,dx		;restore sign
		sub	ax,dx

		mov	X_PFine,ax

ExitIntr100:	ret

ExploreIntr100	ENDP

;----------------------------------------------------------------------------

;* UpdatePosn - update control position
;*
;* pass: ax = position
;*       bl = key codes (b0 = dec key, b1 = inc key)
;*       dx = rate
;* ret : ax = new position
;* kill: bx, dx, flags
;*
;* note: ONLY call from ExploreIntr100.

UpdatePosn	PROC	NEAR

		cmp	bl,10b		;inc key pressed only?
		je	IncPosn		;yes ->
		cmp	bl,01b		;dec key pressed only?
		je	DecPosn		;yes ->

;* washout position
		
		mov	bx,dx
		ABSV	ax		;ax = abs(posn), dx = sign(posn)
		shl	bx,1		;washout rate = 2 * input rate
		sub	ax,bx		;washout
		jnc	@F		;ok ->
		xor	ax,ax		;washout to 0
@@:		xor	ax,dx		;restore sign
		sub	ax,dx
		ret

;* increment position

IncPosn:	add	ax,dx		;posn = posn + rate
		jno	@F		;ok ->
		mov	ax,+32767	;limit
@@:		ret

;* decrement position

DecPosn:	sub	ax,dx		;posn = posn - rate
		jno	@F		;ok ->
		mov	ax,-32768	;limit
@@:		ret

UpdatePosn	ENDP

;----------------------------------------------------------------------------

;* UpdateKeys
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

UpdateKeys	PROC	NEAR

		KBOUNCE	KF_ToggleMode
		KBOUNCE	KF_Quit
		KBOUNCE	KF_Range
		KBOUNCE	KF_GndText
		KBOUNCE	KF_HillText
		KBOUNCE	KF_Clouds
		KBOUNCE	KF_Horizon
		KBOUNCE	KF_Minimise
		KBOUNCE	KF_Keyboard
		KBOUNCE	KF_Joystick
		KBOUNCE	KF_Mouse
		KBOUNCE	KF_Recal
		KBOUNCE	KF_JoySensNorm
		KBOUNCE	KF_JoySensHigh

		ret

UpdateKeys	ENDP

;----------------------------------------------------------------------------

;* UserOptions - sort visual and control options
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

UserOptions	PROC	NEAR

;------------------
;* keyboard control
;------------------

		KTEST	KF_Keyboard
		jz	SkipKbd

		mov	X_CtrlDevice,CTRL_DEV_KBD

		call	InitCtrlDevice

;------------------
;* joystick control
;------------------

SkipKbd:	KTEST	KF_Joystick
		jz	SkipJoy

		cmp	X_CtrlDevice,CTRL_DEV_JS1	;single joystick control?
		jne	@F				;no ->

		mov	X_CtrlDevice,CTRL_DEV_JS2	;dual joysticks

		call	InitCtrlDevice

		cmp	X_CtrlDevice,CTRL_DEV_JS2	;dual joysticks ok?
		je	SkipJoy				;yes ->

@@:		mov	X_CtrlDevice,CTRL_DEV_JS1	;single joystick

		call	InitCtrlDevice

;---------------
;* mouse control
;---------------

SkipJoy:	KTEST	KF_Mouse
		jz	SkipMouse

		mov	X_CtrlDevice,CTRL_DEV_MOUSE

		call	InitCtrlDevice

;------------------------
;* joystick recalibration
;------------------------

SkipMouse:	KTEST	KF_JoySensNorm
		jz	@F

		mov	JoySensitivity,0

@@:		KTEST	KF_JoySensHigh
		jz	@F

		mov	JoySensitivity,1

@@:		KTEST	KF_Recal
		jz	SkipRecal

		call	InitCtrlDevice

;----------------
;* visual options
;----------------

SkipRecal:	call	UserVisOptions

		ret

UserOptions	ENDP

EXPCODE		ENDS

;============================================================================

		END

