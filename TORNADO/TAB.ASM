;****************************************************************************
;*
;* TAB.ASM
;*
;* Navigator TAB displays.
;*
;* 19.03.1992 - KJB
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<
PUBLIC DamagedDisp		
PUBLIC TIALDDisp_Ori		
PUBLIC TIALDDisp_Ori2
PUBLIC StealMouse		
PUBLIC UpdateTAB
PUBLIC RefDisp
PUBLIC MapDisp
PUBLIC RoutePlanDisp		
PUBLIC TIALDDisp
PUBLIC FLIRDisp_Ori
PUBLIC FLIRDisp_Ori2
PUBLIC FLIRDisp_Ori3
PUBLIC FLIRDisp_Ori4
		PUBLIC	UpdateTAB1
		PUBLIC	UpdateTAB2
		PUBLIC	ValidateTIALD
		PUBLIC	TAB1
		PUBLIC	TAB2

		PUBLIC	REF_VIEW

		PUBLIC	TIALDActive
		PUBLIC	LaserActive
		PUBLIC	RadarTest
EXTRN	CrewMode:WORD		
EXTRN SSF_HUD:BYTE		
EXTRN UpdateHUD:NEAR	
EXTRN UpdateHUD2:NEAR		
EXTRN QuieterCockpit:BYTE	
EXTRN   InCockpit:BYTE		
EXTRN	FromHomeToPgUp:BYTE
EXTRN	KF_NavigViewWithCtrl:BYTE
EXTRN	FullScreen:BYTE		
EXTRN   NVG_set:BYTE
;EXTRN   KF_NVG_MFD:BYTE
;EXTRN   KF_NONVG_MFD:BYTE
;EXTRN   KF_HUDContrast:BYTE
EXTRN	IronWork:BYTE		
;EXTRN  SelectActDisp:NEAR	
EXTRN DrawADIRollBug:NEAR
EXTRN UpdateCtrlSFace:NEAR
EXTRN  UpdateEScope2:NEAR	
EXTRN	UpdateHUD2:NEAR	
EXTRN	UpdateADI2:NEAR	
EXTRN	LoadExtrnPan:NEAR    ;added on 2/11/2017
EXTRN	UpdateExtrn:NEAR     ;added on 6/11/2017
EXTRN	UpdateRWR:NEAR
EXTRN	DrawNavigPanel:FAR
EXTRN VGA_DrwNavigPan:NEAR
EXTRN VGA_DrwNavigPanBrief:NEAR

		EXTRN	RandX:FAR
		EXTRN	HLineDraw:FAR
		EXTRN	VLineDraw:FAR
		EXTRN	BlockFill:FAR
		EXTRN	LineDraw:FAR
		EXTRN	CharSprite:FAR
		EXTRN	CellSprite:FAR
		EXTRN	VSetViewport:FAR
		EXTRN	VQuickLineClip:FAR
		EXTRN	VDotClip:FAR
		EXTRN	CancelTgtWP:FAR
		EXTRN	UpdateTgtWP:FAR
		EXTRN	UpdateMovingMap:FAR
		EXTRN	SetViewMode:FAR
		EXTRN	Visual:FAR
		EXTRN	SetIRPalette:FAR
		EXTRN	FixIRPalette:FAR
		EXTRN	ReadMouseMotion:FAR
		EXTRN	MoveViewpoint:FAR
		EXTRN	CalcGndHeight:FAR
		EXTRN	SetPixel:FAR
		EXTRN	Print$:FAR
		EXTRN	CalcRngBrgVP_VP:FAR
		EXTRN	CalcNMiles:FAR
		EXTRN	CalcAngDiff:FAR
		EXTRN	CalcETA:FAR

		EXTRN	DrawIRImage:NEAR

		EXTRN	CloudBase:DWORD

        ;======== for roll indicator
		EXTRN	Roll:WORD
		EXTRN	DialXY1:BYTE
		EXTRN	DialXY2:BYTE
		;======== for roll indicator
EXTRN	Cannons:WORD ;hacked
		EXTRN	M_VIEW:WORD
		EXTRN	TMP_VIEW:WORD
		EXTRN	WPPtr:WORD
		EXTRN	WayTotal:WORD
		EXTRN	WayList:WORD
		EXTRN	FloatWP:WORD
		EXTRN	FloatWPX:WORD
		EXTRN	FloatWPY:WORD
		EXTRN	ACDatumX:WORD
		EXTRN	ACDatumY:WORD
		EXTRN	CellXMin:WORD
		EXTRN	CellXMax:WORD
		EXTRN	CellYMin:WORD
		EXTRN	CellYMax:WORD
		EXTRN	SecScanCnt1:WORD
		EXTRN	SecScanOff1:WORD
		EXTRN	SecScanCnt2:WORD
		EXTRN	SecScanOff2:WORD
		EXTRN	SinTable:WORD
		EXTRN	CosTable:WORD
		EXTRN	XMickeys:WORD
		EXTRN	YMickeys:WORD
		EXTRN	LastFrame:WORD
		EXTRN	TornadoType:WORD
		EXTRN	M_SinH:WORD
		EXTRN	M_CosH:WORD
		EXTRN	M_CosP:WORD
		EXTRN	M_CosR:WORD
		EXTRN	TrueRadAlt:WORD
		EXTRN	DispHdg:WORD
		EXTRN	WPBrg:WORD
		EXTRN	WPRngNMiles:WORD
		EXTRN	WPETA:WORD
		EXTRN	Hdg:WORD
		EXTRN	Vtas:WORD
		EXTRN	SectorTable:WORD
		EXTRN	CurrentWPX:WORD
		EXTRN	CurrentWPY:WORD

		EXTRN	SSF_TAB1:BYTE
		EXTRN	SSF_TAB2:BYTE
		EXTRN	KF_TAB1Select:BYTE
		EXTRN	KF_TAB1Toggle:BYTE
		EXTRN	KF_TAB2Select:BYTE
		EXTRN	KF_TAB2Toggle:BYTE
		EXTRN	KF_MapZoomIn:BYTE
		EXTRN	KF_MapZoomOut:BYTE
		EXTRN	KF_MapOrigin:BYTE
		EXTRN	CRTRing1:BYTE
		EXTRN	GradEnabled:BYTE
		EXTRN	StarsEnabled:BYTE
		EXTRN	CloudsEnabled:BYTE
		EXTRN	HillTextEnabled:BYTE
		EXTRN	Night:BYTE
		EXTRN	Fog:BYTE
		EXTRN	Overcast:BYTE
		EXTRN	DisableInput:BYTE
		EXTRN	Key:BYTE
		EXTRN	SectorLayer1:BYTE

		EXTRN	MAP_TAB_DISP:ABS
		EXTRN	MAP_ZOOM1:ABS
		EXTRN	MAP_ZOOM6:ABS
		EXTRN	MAP_ORG_CENTRE:ABS
		EXTRN	MAP_ORG_BASE:ABS

		EXTRN	ILSActive:BYTE
		EXTRN	ILSLocalPos:WORD
		EXTRN	ILSGlidePos:WORD
		
		EXTRN	ZFT_COCKPIT:ABS
;============================================================================

		INCLUDE	TAB.INC
		INCLUDE	MFD.INC
		INCLUDE	MAINDATA.INC

		INCLUDE	\VISUAL\VSCREEN.INC
		INCLUDE	\VISUAL\VISDATA.INC
		INCLUDE	\VISUAL\VISEXTRN.INC
		INCLUDE	\VISUAL\VISMACRO.INC
		INCLUDE	\VISUAL\PALETTES.INC
		INCLUDE	\VISUAL\GNDLIST.INC

		INCLUDE	\LIB8086\KEYS.INC
		INCLUDE	\LIB8086\TRIG.INC
		INCLUDE	\LIB8086\PRINT.INC
		INCLUDE	\LIB8086\USEFUL.INC

;============================================================================

		EXTRN	NAVIG_MFD:MFD

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

HUD_X_ORG	EQU	160
HUD_Y_ORG	EQU	96

SetUp$		LABEL	BYTE
		P_OVER1
		P_CHAR2
		PD_ATTR	000h,000h,000h,000h,0aah,000h,COL_HUD,000h
		P_END

Cannon$		LABEL	BYTE
        
		P_DECAT	00010011b
		PD_X	HUD_X_ORG-52
		PD_Y	HUD_Y_ORG+27-90
		DB	"GUNS"
		PD_X	HUD_X_ORG-52
		PD_Y	HUD_Y_ORG+33-90
		DB	"x"
		PV_DECW	Cannons
		P_DECAT	00000000b
		P_END

Cannon2$		LABEL	BYTE
        
		P_DECAT	00010011b
		PD_X	HUD_X_ORG-52
		PD_Y	HUD_Y_ORG+27-40
		DB	"GUNS"
		PD_X	HUD_X_ORG-52
		PD_Y	HUD_Y_ORG+33-40
		DB	"x"
		PV_DECW	Cannons
		P_DECAT	00000000b
		P_END		
		
;------------------------------------
;* HSI localiser and glide slope vars
;------------------------------------

LOCAL_X		EQU	95		;localiser needle origin
LOCAL_Y		EQU	184

LocalXPos	DW	LOCAL_X		;localiser x pos

GLIDE_X		EQU	78		;glide slope needle origin
GLIDE_Y		EQU	186

GlideYPos	DB	GLIDE_Y		;glide slope y pos

		EVEN

;-----------------------------
;* meter dial co-ords (size 3)
;-----------------------------

DialXY3		LABEL	BYTE

		DB	  0, -12	;0
		DB	  1, -12	;1
		DB	  2, -12	;2
		DB	  3, -12	;3
		DB	  4, -12	;4
		DB	  5, -11	;5
		DB	  6, -11	;6
		DB	  7, -11	;7
		DB	  8, -10	;8
		DB	  9, -10	;9
		DB	 10,  -9	;10
		DB	 11,  -8	;11
		DB	 12,  -7	;12
		DB	 13,  -6	;13
		DB	 14,  -5	;14
		DB	 14,  -4	;15
		DB	 15,  -3	;16
		DB	 15,  -2	;17
		DB	 15,  -1	;18
		DB	 15,   0	;19
		DB	 15,   1	;20
		DB	 15,   2	;21
		DB	 15,   3	;22
		DB	 14,   4	;23
		DB	 14,   5	;24
		DB	 13,   6	;25
		DB	 12,   7	;26
		DB	 11,   8	;27
		DB	 10,   9	;28
		DB	  9,  10	;29
		DB	  8,  10	;30
		DB	  7,  11	;31
		DB	  6,  11	;32
		DB	  5,  11	;33
		DB	  4,  12	;34
		DB	  3,  12	;35 
		DB	  2,  12	;36
		DB	  1,  12	;37
		DB	  0,  12	;38
		DB	 -1,  12	;39
		DB	 -2,  12	;40
		DB	 -3,  12	;41 
		DB	 -4,  12	;42
		DB	 -5,  11	;43
		DB	 -6,  11	;44
		DB	 -7,  11	;45
		DB	 -8,  10	;46
		DB	 -9,  10	;47
		DB	-10,   9	;48
		DB	-11,   8	;49
		DB	-12,   7	;50
		DB	-13,   6	;51
		DB	-14,   5	;52
		DB	-14,   4	;53
		DB	-15,   3	;54
		DB	-15,   2	;55
		DB	-15,   1	;56
		DB	-15,   0	;57
		DB	-15,  -1	;58
		DB	-15,  -2	;59
		DB	-15,  -3	;60
		DB	-14,  -4	;61
		DB	-14,  -5	;62
		DB	-13,  -6	;63
		DB	-12,  -7	;64
		DB	-11,  -8	;65
		DB	-10,  -9	;66
		DB	 -9, -10	;67
		DB	 -8, -10	;68
		DB	 -7, -11	;69
		DB	 -6, -11	;70
		DB	 -5, -11	;71
		DB	 -4, -12	;72
		DB	 -3, -12	;73
		DB	 -2, -12	;74
		DB	 -1, -12	;75
		DB	  0, -12	;76 <<<<< first co-ord repeated <<<<<


		
;----------
;* TAB size
;----------

TAB_WIDTH	EQU	96 ;96
TAB_DEPTH	EQU	72 ;72
TAB_WIDTH_TIALD	EQU	320
TAB_DEPTH_TIALD	EQU	192

;TIALD Original - offset compensation
OFFSETTIALD EQU 8

XC		EQU	TAB_WIDTH/2	;centre x
;YC		EQU	TAB_DEPTH/2-1	;centre y
YC		EQU	(TAB_DEPTH/2-1)+OFFSETTIALD	;centre y

XC_TIALD		EQU	TAB_WIDTH_TIALD/2	;centre x
;YC_TIALD		EQU	TAB_DEPTH_TIALD/2-1	;centre y

;centre y  - modified by Frankie on 21/5/2018 to compensate for the code
;mov TIALD_VIEW.VP_PITCH,400 on line 2890
YC_TIALD		EQU	(TAB_DEPTH_TIALD/2-1)+25 




;Value 25 means move the crosshairs 25 pixels down south

;------------
;* TAB origin
;------------

XOrg		DW	0
YOrg		DB	0,0

XOrg_TIALD		DW	0
YOrg_TIALD		DB	0,0

;------------------
;* TAB display data
;------------------

;* note: The TAB displays share the mouse with each other and the Navigator's
;*       MFD display. The "mouse required" flag (TAB_REQ_MOUSE) should be set
;*       wrt the default TAB mode. The "has mouse" flag (TAB_HAS_MOUSE) should
;*       be set taking into account of the default TAB modes and the default
;*       MFD mode. The default TAB modes should be common to all Tornado
;*       variants.

TABPtr		DW	OFFSET TAB1

TAB1	    TAB	<16,26,1,TAB_PLN,OFFSET SSF_TAB1,0,0>
TAB2		TAB	<208,26,1,TAB_REF,OFFSET SSF_TAB2,0,0> ;hacked by Frankie 25/11/2017

;----------------------
;* mouse required flags
;----------------------
TABMouseFlags	DB	0	;TAB_PLN
		DB	0	;TAB_MAP
		DB	1	;TAB_REF
		DB	0	;TAB_FLIR  (original)
		DB	0	;TAB_FLIR  (full-screen)						
		DB	1	;TAB_TIALD (original)
		DB	1	;TAB_TIALD (full-screen)		
		DB	0	;TAB_RADAR		
		EVEN
;-------------------
;* TAB select switch
;-------------------
;* note: At least two displays must always be available (unconditional).
SelectSwitch	DW	SelectModeOk	;TAB_PLN
		DW	SelectMap	  ;TAB_MAP
		DW	SelectModeOk  ;TAB_REF
		DW	SelectModeOk  ;TAB_FLIR  (original)
		DW	SelectModeOk  ;TAB_FLIR  (full-screen)			
		DW	SelectTIALD	  ;TAB_TIALD (original)
		DW	SelectTIALD	  ;TAB_TIALD (full-screen)
		DW	SelectRadar	  ;TAB_RADAR
		DW	SelectLoopBack;TAB_LOOPBACK
				
;-------------------------
;* TAB display mode switch
;-------------------------
DispSwitch	DW	RoutePlanDisp ;TAB_PLN
		DW	MapDisp		  ;TAB_MAP
		DW	RefDisp		  ;TAB_REF
		DW	FLIRDisp_Ori  ;TAB_FLIR  (original)
		DW	FLIRDisp	  ;TAB_FLIR	 (full-screen)			
		DW	TIALDDisp_Ori ;TAB_TIALD (original)
		DW	TIALDDisp	  ;TAB_TIALD (full-screen)	
		DW	RadarDisp	  ;TAB_RADAR

		
;--------------------------
;* general purpose viewport
;--------------------------

VP		VIEWPORT <>

;-----------------
;* moving map data
;-----------------

MapZoom		DW	MAP_ZOOM1

MapOrigin	DW	MAP_ORG_CENTRE

;-----------------
;* route plan data
;-----------------

PLN_SCALE1	EQU	0		;2 pixels / sector
PLN_SCALE2	EQU	2		;4 pixels / sector
PLN_SCALE3	EQU	4		;8 pixels / sector

PLNScale	DW	PLN_SCALE1

;*		DB	scale up count, scale down count

PLNScaleTable	DB	0,7		;PLN_SCALE1
		DB	0,6		;PLN_SCALE2
		DB	0,5		;PLN_SCALE3

PLNXCentre	DW	0
PLNYCentre	DW	0

TmpX		DW	0
TmpY		DW	0

;---------------
;* TIALD display
;---------------

TIALD_VIEW	VIEWPOINT <>

MIN_OP_RAD_ALT	EQU	100		;min operating rad alt (ft)

TDScanSize	DW	0		;1 .. 23170 (32767 / sqrt(2))

TDXOffset	DW	0		;-scan size .. scan size
TDYOffset	DW	0		;-scan size .. scan size

TDZoom		DW	255		;1 .. 255 (255 = min zoom)

TDZoomKey	DB	0		;1 = zoom key pressed and mouse available

TDDrag		DB	0		;1 = fixed point dragged

TDCross		DB	1		;1 = display cross

TDBlink		DB	0		;blink toggle

TIALDActive	DB	0		;1 = TIALD updated

LaserActive	DB	0		;1 = laser active

		EVEN

TD_BLINK_RATE	EQU	10		;secs * 100

TDBlinkTimer	DW	TD_BLINK_RATE	;secs * 100

;* TIALD mode

TIALD_INIT	EQU	0		;initialize
TIALD_SEARCH	EQU	2		;search within viewing window
TIALD_ZOOM	EQU	4		;adjust zoom
TIALD_ADJ_LOCK	EQU	6		;adjust lock
TIALD_TGT_LOCK	EQU	8		;target lock (designate)

TDMode		DW	TIALD_INIT

TDSwitch	DW	TIALDInit	;TIALD_INIT
		DW	TIALDSearch	;TIALD_SEARCH
		DW	TIALDZoom	;TIALD_ZOOM
		DW	TIALDAdjustLock	;TIALD_ADJ_LOCK
		DW	TIALDTargetLock	;TIALD_TGT_LOCK

TDSwitch_Ori	DW	TIALDInit_Ori	;TIALD_INIT
		DW	TIALDSearch_Ori	;TIALD_SEARCH
		DW	TIALDZoom_Ori	;TIALD_ZOOM
		DW	TIALDAdjustLock_Ori	;TIALD_ADJ_LOCK
		DW	TIALDTargetLock_Ori	;TIALD_TGT_LOCK		

TDSwitch_Ori2	DW	TIALDInit_Ori2	;TIALD_INIT
		DW	TIALDSearch_Ori2	;TIALD_SEARCH
		DW	TIALDZoom_Ori2	;TIALD_ZOOM
		DW	TIALDAdjustLock_Ori2	;TIALD_ADJ_LOCK
		DW	TIALDTargetLock_Ori2	;TIALD_TGT_LOCK		
		
;* symbology switch

TDSymbolSwitch	DW	TDSymOk		;TIALD_INIT
		DW	TDSymOk		;TIALD_SEARCH
		DW	TDSymZoom	;TIALD_ZOOM
		DW	TDSymAdjustLock	;TIALD_ADJ_LOCK
		DW	TDSymTargetLock	;TIALD_TGT_LOCK

TDSymbolSwitch_Ori	DW	TDSymOk		;TIALD_INIT
		DW	TDSymOk_Ori		;TIALD_SEARCH
		DW	TDSymZoom_Ori	;TIALD_ZOOM
		DW	TDSymAdjustLock_Ori	;TIALD_ADJ_LOCK
		DW	TDSymTargetLock_Ori	;TIALD_TGT_LOCK

TDSymbolSwitch_Ori2	DW	TDSymOk		;TIALD_INIT
		DW	TDSymOk_Ori2		;TIALD_SEARCH
		DW	TDSymZoom_Ori2	;TIALD_ZOOM
		DW	TDSymAdjustLock_Ori2	;TIALD_ADJ_LOCK
		DW	TDSymTargetLock_Ori2	;TIALD_TGT_LOCK
		
;---------------
;* reference map
;---------------

REF_VIEW	VIEWPOINT <16,16,0,0,0>

RefDesignated	DB	0,0		;1 = designation made

RefDesX		DW	XC		;designator flexible x position
RefDesY		DW	YC		;designator flexible y position

RefZoom		DW	MAP_ZOOM1

RefRng		DD	0		;range
RefBrg		DW	0		;bearing (pdeg)
RefRngNMiles	DW	0		;range (nautical miles * 10)
RefETA		DW	0		;ETA (seconds) (-1 = invalid)

;--------------------
;* radar test display (debug option)
;--------------------

RadarTest	DB	0		;1 = radar test enabled

		EVEN

;-----------------------------
;* waypoint statistics strings
;-----------------------------

WPSetUp$ 	LABEL	BYTE
		P_OVER1
		P_CHAR2
		PD_VGA	COL_CRT16,COL_CRT16
		PV_XY	XOrg,YOrg
		PD_XYMV	4,1
		P_DECAT	00100011b	;(unsigned, 3 digits, leading zeroes)
		PV_DECW	DispHdg
		P_DECAT	00000000b	;(default)
		P_END

WPRng$		LABEL	BYTE
		PV_XY	XOrg,YOrg
		PD_XYMV	72,66
		PV_RNG	WPRngNMiles
		P_END

WPBrg$		LABEL	BYTE
		PV_XY	XOrg,YOrg
		PD_XYMV	80,1
		PV_PDEG	WPBrg
		P_END

WPETA$		LABEL	BYTE
		PV_XY	XOrg,YOrg
		;PD_XYMV	4,66
		PD_XYMV	4,56
		PV_ETA	WPETA
		P_END

WPRngInvalid$	LABEL	BYTE
		PV_XY	XOrg,YOrg
		PD_XYMV	72,66
		DB	"-----"
		P_END

WPBrgInvalid$	LABEL	BYTE
		PV_XY	XOrg,YOrg
		PD_XYMV	80,1
		DB	"---"
		P_END

WPETAInvalid$	LABEL	BYTE
		PV_XY	XOrg,YOrg
		PD_XYMV	4,66
		DB	"-----"
		P_END

;----------------------------------
;* reference map statistics strings
;----------------------------------
RefMap$ 	LABEL	BYTE
		P_OVER1
		P_CHAR2
		PD_VGA	COL_REF_SYM,COL_REF_SYM
		PV_XY	XOrg,YOrg
		PD_XYMV	4,1
		P_DECAT	00100011b	;(unsigned, 3 digits, leading zeroes)
		PV_DECW	DispHdg
		P_DECAT	00000000b	;(default)
		PV_XY	XOrg,YOrg
		PD_XYMV	72,66
		PV_RNG	RefRngNMiles
		PV_XY	XOrg,YOrg
		PD_XYMV	80,1
		PV_PDEG	RefBrg
		P_END

RefMap_COL_HUD$ LABEL	BYTE
		P_OVER1
		P_CHAR2
		PD_VGA	COL_HUD,COL_HUD
		PV_XY	XOrg,YOrg
		PD_XYMV	4,1
		P_DECAT	00100011b	;(unsigned, 3 digits, leading zeroes)
		PV_DECW	DispHdg
		P_DECAT	00000000b	;(default)
		PV_XY	XOrg,YOrg
		PD_XYMV	72,66
		PV_RNG	RefRngNMiles
		PV_XY	XOrg,YOrg
		PD_XYMV	80,1
		PV_PDEG	RefBrg
		P_END
		
RefETA$		LABEL	BYTE
		PV_XY	XOrg,YOrg
		PD_XYMV	4,66
		PV_ETA	RefETA
		P_END

RefETAInvalid$	LABEL	BYTE
		PV_XY	XOrg,YOrg
		PD_XYMV	4,66
		DB	"-----"
		P_END

		EVEN

DATA		ENDS

;============================================================================

SECDATA1	SEGMENT PARA PUBLIC 'DATA'

SECDATA1	ENDS

;============================================================================

PANCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:PANCODE
		ASSUME DS:DATA

mov	si,OFFSET SetUp$
call	Print$

		
;* UpdateTAB
;* UpdateTAB1 - update lhs TAB display
;* UpdateTAB2 - update rhs TAB display
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

UpdateTAB1	LABEL	NEAR
		mov	si,OFFSET TAB1	;this TAB display
		mov	di,OFFSET TAB2	;other TAB display
;* update key flags

		mov	al,KF_TAB1Select
		mov	TAB_SELECT[si],al
		mov	al,KF_TAB1Toggle
		mov	TAB_TOGGLE[si],al
;DontDoAnything:
		jmp	UpdateTAB

UpdateTAB2	LABEL	NEAR

		mov	si,OFFSET TAB2	;this TAB display
		mov	di,OFFSET TAB1	;other TAB display

;* update key flags

		mov	al,KF_TAB2Select
		mov	TAB_SELECT[si],al
		mov	al,KF_TAB2Toggle
		mov	TAB_TOGGLE[si],al
		jmp	UpdateTAB
;@@:
UpdateTAB	PROC	NEAR

;-----------------
;* set origin vars
;-----------------

		mov	ax,TAB_X_ORG[si]
		mov	XOrg,ax
		mov	al,TAB_Y_ORG[si]
		mov	YOrg,al

;---------------------------------
;* set char sprite clipping window
;---------------------------------

		mov	ax,XOrg
		mov	CellXMin,ax
		add	ax,TAB_WIDTH
		dec	ax
		mov	CellXMax,ax

		mov	ax,WORD PTR YOrg
		mov	CellYMin,ax
		add	ax,TAB_DEPTH
		dec	ax
		mov	CellYMax,ax

;-----------------------
;* test for TAB on / off
;-----------------------

		test	TAB_TOGGLE[si],1	;toggle TAB on / off
		jz	@F			;no ->

		xor	TAB_STATUS[si],1	;toggle

		mov	TAB_SELECT[si],0	;cancel select request

@@:		test	TAB_STATUS[si],1	;TAB on?
		_JZ	SwitchedOff		;no ->

;----------------------
;* test for damaged TAB
;----------------------

		mov	bx,TAB_SSF_PTR[si]
		test	BYTE PTR [bx],1
		_JNZ	Damaged

;---------------------------------------------------------------------------
;* test for mode confliction with other TAB display (ie. when just turned on)
;---------------------------------------------------------------------------

		mov	bp,-1			;assume off or damaged

		test	TAB_STATUS[di],1	;other TAB display on?
		jz	@F			;no, mode not valid ->

		mov	bx,TAB_SSF_PTR[di]
		test	BYTE PTR [bx],1		;other TAB display damaged?
		jnz	@F			;yes, mode not valid ->

		mov	bp,TAB_MODE[di]
		cmp	bp,TAB_MODE[si]		;same mode?
		jne	@F			;no ->

		mov	TAB_SELECT[si],1	;set select request

		jmp	ContSelect

;* check for confliction with MFD display (moving map is mutually exclusive)

@@:		cmp	[si].TAB_MODE,TAB_MAP	;moving map selected?
		jne	ContSelect		;no ->

		cmp	NAVIG_MFD.MFD_MODE,MFD_MAP	;moving map selected?
		jne	ContSelect			;no ->

		test	NAVIG_MFD.MFD_STATUS,1	;Nav's MFD on?
		jz	ContSelect		;no ->

		mov	bx,NAVIG_MFD.MFD_SSF_PTR
		test	BYTE PTR [bx],1		;Nav's display damaged?
		jnz	ContSelect		;yes ->

		mov	[si].TAB_SELECT,1	;set select request

;--------------------------
;* test for select TAB mode
;--------------------------

ContSelect:	mov	bx,TAB_MODE[si]

		test	TAB_SELECT[si],1	;select mode?
		jz	SortMode		;no ->

SelectNext:	
        add	bx,2
		
		cmp	bx,bp		;same mode as other TAB display?
		je	SelectNext	;yes, skip same mode ->

;-------------------------------------------------------------------------------------------------------
; This section was written by Frankie Kam on 17 December 2017
; This switch-case like construct is to avoid the Tab1 and Tab2 from showing up in these combinations:		
; TAB1               TAB2
; ====               ====
; FLIR               FLIR full-screen
; FLIR full-screen   FLIR 
; TIALD              TIALD full-screen
; TIALD full-screen  TIALD 		
;
; Refer to Line 353 (reproduced below)
;
; SelectSwitch	DW	SelectModeOk	;TAB_PLN
;		DW	SelectMap	  ;TAB_MAP
;		DW	SelectModeOk  ;TAB_REF
;		DW	SelectModeOk  ;TAB_FLIR  (original)
;		DW	SelectTIALD	  ;TAB_TIALD (original)
;		DW	SelectModeOk  ;TAB_FLIR  (full-screen)	
;		DW	SelectTIALD	  ;TAB_TIALD (full-screen)
;		DW	SelectRadar	  ;TAB_RADAR
;		DW	SelectLoopBack;TAB_LOOPBACK
;---------------------------------------------------------------------------------------------------------

		cmp bx,TAB_FLIR_ORI ;10
        jne NextCondition3
		cmp bp,TAB_FLIR ;6
		je	SelectNext
NextCondition3:
		cmp bx,TAB_FLIR ;6
        jne NextCondition4
		cmp bp,TAB_FLIR_ORI ;10
		je	SelectNext
NextCondition4:
		cmp bx,TAB_TIALD ;8
        jne NextCondition5
		cmp bp,TAB_TIALD_ORI;12
		je	SelectNext
NextCondition5:
		cmp bx,TAB_TIALD_ORI ;12
        jne GoAheadSelect
		cmp bp,TAB_TIALD ;8
		je	SelectNext
GoAheadSelect:	
        ;Show full-screen FLIR and TIALDS only if the /fs flag is used. For example, C:\>TORNADO /fs
        cmp FullScreen,1
		_JE GetOutHere
        cmp bx,TAB_FLIR_ORI ;6
		jne CheckTab
		add bx, 4
		jmp GetOutHere
CheckTab:	
        cmp bx,TAB_TIALD_ORI ;6
        jne CheckTab2
		add bx, 2
		jmp GetOutHere		
CheckTab2:			
        cmp bp,TAB_FLIR_ORI ;6
	    jne CheckTab3
		add bp, 4	
CheckTab3:					
        cmp bp,TAB_TIALD_ORI ;6
	    jne GetOutHere
		add bp, 2
GetOutHere:
		jmp	SelectSwitch[bx] 

;* only select TAB_MAP if moving map not displayed on Nav's MFD

SelectMap:	cmp	NAVIG_MFD.MFD_MODE,MFD_MAP	;moving map selected?
		jne	@F				;no ->

		test	NAVIG_MFD.MFD_STATUS,1	;Nav's MFD on?
		jz	@F			;no ->

		push	bx
		mov	bx,NAVIG_MFD.MFD_SSF_PTR
		test	BYTE PTR [bx],1		;Nav's display damaged?
		pop	bx
		jz	SelectNext		;no ->

@@:		jmp	SelectModeOk

;* do not select TAB_TIALD if ADV (IDS / ECR only)

SelectTIALD:	
        cmp	TornadoType,ADV_TORNADO
		je	SelectNext

		jmp	SelectModeOk

;* only select TAB_RADAR if radar test enabled

SelectRadar:	test	RadarTest,1
		jz	SelectNext

		jmp	SelectModeOk

;* loop back to first TAB mode

SelectLoopBack:	mov	bx,-2

		jmp	SelectNext

SelectModeOk:	mov	TAB_MODE[si],bx

;-------------------
;* sort display mode
;-------------------

;* sort mouse required flag (do this every frame in case TAB auto-switches)

SortMode:	shr	bx,1		;/2 byte index

		mov	al,TABMouseFlags[bx]
		mov	TAB_REQ_MOUSE[si],al

		shl	bx,1		;*2 word index

		test	al,al		;mouse required?
		jz	@F		;no ->

		call	StealMouse

@@:		mov	TABPtr,si

		call	DispSwitch[bx]

		ret

;------------------
;* TAB switched off
;------------------

SwitchedOff:	call	ClearDisp

		ret

;-------------
;* damaged TAB
;-------------

Damaged:	call	DamagedDisp

		ret

UpdateTAB	ENDP

;----------------------------------------------------------------------------

;* StealMouse - steal mouse from other displays (if available)
;*
;* pass: si -> this TAB display
;*	 di -> other TAB display
;* ret : nothing
;* kill: ax, flags
;*
;* note: Registers bx, si and di must be preserved.

StealMouse	PROC	NEAR

		push	bx

		test	TAB_HAS_MOUSE.[si],1	;does TAB already have mouse?
		jnz	ExitSteal		;yes ->

;-----------------------------------------
;* attempt to steal from other TAB display
;-----------------------------------------

		test	TAB_HAS_MOUSE.[di],1	;does other TAB have mouse?
		jz	@F			;no ->

;* mouse available if not required by other TAB, or other TAB is switched off or damaged

		mov	al,TAB_STATUS.[di]
		and	al,TAB_REQ_MOUSE.[di]	;required and on?

		mov	bx,TAB_SSF_PTR.[di]
		mov	ah,[bx]
		not	ah	    	;0ffh = ok, 0feh = damaged

		and	al,ah		;required and on and not damaged?

		jz	ContSteal	;no, steal mouse ->

		jmp	ExitSteal

;-----------------------------------------------
;* attempt to steal from Navigator's MFD display
;-----------------------------------------------

@@:		test	NAVIG_MFD.MFD_HAS_MOUSE,1	;does Nav's MFD have mouse?
		jz	ContSteal  			;no (error, steal anyway) ->

;* mouse available if not required by Nav's MFD, or Nav's MFD is switched off or damaged

		mov	al,NAVIG_MFD.MFD_STATUS
		and	al,NAVIG_MFD.MFD_REQ_MOUSE	;required and on?

		mov	bx,NAVIG_MFD.MFD_SSF_PTR
		mov	ah,[bx]
		not	ah	    	;0ffh = ok, 0feh = damaged

		and	al,ah		;required and on and not damaged?

		jz	ContSteal	;no, steal mouse ->

		jmp	ExitSteal

;-------------
;* steal mouse
;-------------

ContSteal:   	mov	TAB_HAS_MOUSE.[si],1
		mov	TAB_HAS_MOUSE.[di],0
		mov	NAVIG_MFD.MFD_HAS_MOUSE,0

ExitSteal:	pop	bx

		ret

StealMouse	ENDP

;----------------------------------------------------------------------------

;* PLOTSYM - clip and plot pixel relative to symbol centre
;*
;* pass: xrel = offset from symbol centre
;*       yrel = offset from symbol centre
;*	 col = logical colour
;*	 cx = x co-ord symbol centre (wrt XOrg)
;*       bl = y co-ord symbol centre (wrt YOrg)
;* ret : nothing
;* kill: assume all (except cx, bl)

PLOTSYM		MACRO	xrel,yrel,col
		LOCAL	SkipPixel

		push	bx
		push	cx

		add	cx,xrel
		cmp	cx,TAB_WIDTH-1	;visible?
		ja	SkipPixel	;no ->

		add	bl,yrel
		cmp	bl,TAB_DEPTH-1	;visible?
		ja	SkipPixel	;no ->

		add	cx,XOrg
		add	bl,YOrg

		mov	al,col

		call	SetPixel

SkipPixel:	pop	cx
		pop	bx

		ENDM

;----------------------------------------------------------------------------

;* RoutePlanDisp - routine navigation display
;*
;* pass: si -> TAB data block
;* ret : nothing
;* kill: assume all

RoutePlanDisp	PROC	NEAR

;		test	QuieterCockpit,1	;in cockpit?
;		jnz @F ;->yes
;		jmp GoOverHereMann2
;@@:	
		call	ClearDisp

;-----------------
;* sort plan scale
;-----------------

;* assume Tornado off map or < 2 waypoints (set limits to display entire map)

		mov	al,0		;x min
		mov	ah,31		;x max
		mov	dl,0		;y min
		mov	dh,31		;y max

		mov	cx,WayTotal
		cmp	cx,2
		jb	ContPLNScale	;< 2 waypoints ->

;* if Tornado on active map then
;*    select scale considering Tornado position and floating waypoint
;* else
;*    select scale to display entire map
;* endif

		cmp	M_VIEW.VP_XSEC,31	;xsec on map?
		ja	ContPLNScale	   	;no ->
		cmp	M_VIEW.VP_YSEC,31	;ysec on map?
		ja	ContPLNScale	   	;no ->

		mov	al,BYTE PTR M_VIEW.VP_XSEC
		mov	ah,al
		mov	dl,BYTE PTR M_VIEW.VP_YSEC
		mov	dh,dl

		test	FloatWP.WP_ATTR,WP_VALID	;floating waypoint valid?
		jz	StartScan			;no ->

		cmp	FloatWP.WP_XSEC,31	;xsec on map?
		ja	StartScan	   	;no ->
		cmp	FloatWP.WP_YSEC,31	;ysec on map?
		ja	StartScan	   	;no ->

;* x min = min(x min, xsec)

		cmp	al,BYTE PTR FloatWP.WP_XSEC
		jbe	@F
		mov	al,BYTE PTR FloatWP.WP_XSEC

;* x max = max(x max, xsec)

@@:		cmp	ah,BYTE PTR FloatWP.WP_XSEC
		jae	@F
		mov	ah,BYTE PTR FloatWP.WP_XSEC

;* y min = min(y min, ysec)

@@:		cmp	dl,BYTE PTR FloatWP.WP_YSEC
		jbe	@F
		mov	dl,BYTE PTR FloatWP.WP_YSEC

;* y max = max(y max, ysec)

@@:		cmp	dh,BYTE PTR FloatWP.WP_YSEC
		jae	StartScan
		mov	dh,BYTE PTR FloatWP.WP_YSEC

StartScan:	mov	si,OFFSET WayList

;* x min = min(x min, xsec)

ScanWPLoop:	cmp	al,BYTE PTR WP_XSEC[si]
		jbe	@F
		mov	al,BYTE PTR WP_XSEC[si]

;* x max = max(x max, xsec)

@@:		cmp	ah,BYTE PTR WP_XSEC[si]
		jae	@F
		mov	ah,BYTE PTR WP_XSEC[si]

;* y min = min(y min, ysec)

@@:		cmp	dl,BYTE PTR WP_YSEC[si]
		jbe	@F
		mov	dl,BYTE PTR WP_YSEC[si]

;* y max = max(y max, ysec)

@@:		cmp	dh,BYTE PTR WP_YSEC[si]
		jae	@F
		mov	dh,BYTE PTR WP_YSEC[si]

@@:		add	si,WAY_REC_SIZE	;next waypoint
		loop	ScanWPLoop

;* calc Dx, Dy

ContPLNScale:	sub	ah,al		;Dx = x max - x min
		sub	dh,dl		;Dy = y max - y min

;* calc max(Dx, Dy)

		mov	cl,ah		;assume Dx >= Dy
		cmp	ah,dh		;Dx >= Dy?
		jae	@F		;yes ->
		mov	cl,dh

@@:		mov	bx,PLN_SCALE3	;assume PLN_SCALE3
		cmp	cl,9		;inside 9 * 9 sectors?
		jb	@F		;yes ->

		mov	bx,PLN_SCALE2	;assume PLN_SCALE2
		cmp	cl,17		;inside 17 * 17 sectors?
		jb	@F		;yes ->
		
		mov	bx,PLN_SCALE1	;default PLN_SCALE1

@@:		mov	PLNScale,bx

;---------------------
;* calc centre offsets (place 0,0 of middle sector at viewport centre)
;---------------------

;* x centre = (x min + Dx / 2) * 256 + 128

		shr	ah,1		;Dx / 2
		adc	ah,al		;(x min + Dx / 2) * 256 (+ 1/2 bit)
		mov	al,128		;(x min + Dx / 2) * 256 + 128
		mov	PLNXCentre,ax

;* y centre = (31 - (y min + Dy / 2)) * 256 + 128

		shr	dh,1		;Dy / 2
		adc	dl,dh		;Dy / 2 + y min (+ 1/2 bit)
		mov	dh,31
		sub	dh,dl		;(31 - (y min + Dy / 2)) * 256
		mov	dl,128		;(31 - (y min + Dy / 2)) * 256 + 128
		mov	PLNYCentre,dx

;---------------
;* init viewport
;---------------

		mov	ax,XOrg
		mov	VP.V_X_ORG,ax

		mov	al,YOrg
		mov	BYTE PTR VP.V_Y_ORG,al

		mov	VP.V_WIDTH,TAB_WIDTH

		mov	VP.V_DEPTH,TAB_DEPTH

		mov	bx,PLNScale

		mov	al,PLNScaleTable[bx+0]
		mov	VP.V_SCALE_UP,al

		mov	al,PLNScaleTable[bx+1]
		mov	VP.V_SCALE_DN,al

		xor	ax,ax
		mov	si,OFFSET VP
		call	VSetViewport

;-----------
;* draw grid
;-----------

;* draw vertical lines every 4 sectors (through sector centre)
;*
;* offset = -(PLNXCentre and 00300h)
;*
;* x = -(5k + offset)
;*
;* for vline = 1 to 11
;*    Xe[0] = x
;*    Ye[0] = +8k
;*    Xe[2] = x
;*    Ye[2] = -8k
;*    clip and draw line
;*    x += 1k
;* next vline

;		test	QuieterCockpit,1	;in cockpit?
;		jnz @F ;->yes
;		jmp GoOverHereMann3
;@@:	

		mov	ax,PLNXCentre
		and	ax,00300h
		add	ax,5120
		neg	ax

		mov	cx,11

XGridLoop:	push	ax
		push	cx

		mov	Xe[0],ax
		mov	Ye[0],+8192
		mov	Xe[2],ax
		mov	Ye[2],-8192

		call	VQuickLineClip
		jc	@F		;non-visible ->

		mov	al,COL_CRT2
		mov	cx,XCrt[0]
		mov	bl,YCrt[0]
		mov	dx,XCrt[2]
		mov	bh,YCrt[2]
		call	LineDraw

@@:		pop	cx
		pop	ax

		add	ax,1024

		loop	XGridLoop

;* draw horizontal lines every 4 sectors (through sector centre)
;*
;* offset = -(PLNYCentre and 00300h)
;*
;* y = -(5k + offset)
;*
;* for hline = 1 to 11
;*    Xe[0] = -8k
;*    Ye[0] = y
;*    Xe[2] = +8k
;*    Ye[2] = y
;*    clip and draw line
;* next x

		mov	ax,PLNYCentre
		and	ax,00300h
		add	ax,5120
		neg	ax

		mov	cx,11

YGridLoop:	push	ax
		push	cx

		mov	Xe[0],-8192
		mov	Ye[0],ax
		mov	Xe[2],+8192
		mov	Ye[2],ax

		call	VQuickLineClip
		jc	@F		;non-visible ->

		mov	al,COL_CRT2
		mov	cx,XCrt[0]
		mov	bl,YCrt[0]
		mov	dx,XCrt[2]
		mov	bh,YCrt[2]
		call	LineDraw

@@:		pop	cx
		pop	ax

		add	ax,1024

		loop	YGridLoop

;GoOverHereMann3:
;-----------------
;* draw route legs (if visible)
;-----------------

		mov	cx,WayTotal

		_JCXZ	DrawFloatWP	;no waypoints ->

		dec	cx		;num legs
		jz	DrawWPMarkers	;single waypoint ->

		mov	si,OFFSET WayList
		mov	di,OFFSET WayList+WAY_REC_SIZE

@@:		push	cx
		push	si
		push	di
		call	DrawLeg
		pop	di
		pop	si
		pop	cx

		add	si,WAY_REC_SIZE
		add	di,WAY_REC_SIZE
		loop	@B

;* check for "linked" route leg and draw if exists

		mov	cx,WayTotal	;WayTotal >= 2

		mov	si,-1		;null ptr
		mov	di,-1		;null ptr

		mov	bx,OFFSET WayList

LinkLoop:	test	WP_ATTR[bx],WP_LINK	;link back?
		jz	@F			;no ->

		mov	si,bx

@@:		test	WP_ATTR[bx],WP_HERE	;link back to here?
		jz	@F			;no ->

		mov	di,bx

@@:		add	bx,WAY_REC_SIZE	;next waypoint

		loop	LinkLoop

		cmp	si,-1		;link ptr valid?
		je	DrawWPMarkers	;no ->

		cmp	di,-1		;here ptr valid?
		je	DrawWPMarkers	;no ->

		call	DrawLeg

;-----------------------
;* draw waypoint markers (if visible)
;-----------------------

DrawWPMarkers:	mov	cx,WayTotal

		mov	si,OFFSET WayList

		mov	di,-1		;assume no current marker

WPMarkerLoop:	push	cx
		push	si
		push	di

		mov	cl,6		;/64

		mov	ax,WP_XFT[si]
		add	ax,8192		;0 .. 16383
		shr	ax,cl		;0 .. 255
		mov	ah,BYTE PTR WP_XSEC[si]
		sub	ax,PLNXCentre
		mov	Xe[0],ax

		mov	ax,WP_YFT[si]
		add	ax,8192		;0 .. 16383
		shr	ax,cl		;0 .. 255
		mov	ah,31		
		sub	ah,BYTE PTR WP_YSEC[si]
		sub	ax,PLNYCentre
		mov	Ye[0],ax

		push	si
		call	VDotClip
		pop	si
		jc	SkipWPMarker	;non-visible ->

		cmp	si,WPPtr	;current waypoint?
		jne	@F		;no ->

;* store current waypoint marker data, and draw last (to prevent overwriting)

		pop	di
		mov	di,si
		push	di

		mov	TmpX,cx
		mov	TmpY,bx

		jmp	SkipWPMarker

@@:		mov	al,COL_CRT10
		mov	dl,WP_ID[si]
		call	CharSprite

SkipWPMarker:	pop	di
		pop	si
		pop	cx

		add	si,WAY_REC_SIZE	;next waypoint
		loop	WPMarkerLoop

;* draw current waypoint marker (if any)

		cmp	di,-1		;any current waypoint marker?
		je	DrawFloatWP	;no ->

		mov	cx,TmpX
		mov	bx,TmpY

		mov	al,COL_CRT16
		mov	dl,WP_ID[di]
		call	CharSprite

;------------------------
;* mark floating waypoint (if valid)
;------------------------

DrawFloatWP:	test	FloatWP.WP_ATTR,WP_VALID	;floating waypoint valid?
		jz	DrawPosMarker			;no ->

		cmp	FloatWP.WP_XSEC,31	;xsec on map?
		ja	DrawPosMarker	   	;no ->
		cmp	FloatWP.WP_YSEC,31	;ysec on map?
		ja	DrawPosMarker	   	;no ->

		mov	cl,6		;/64

		mov	ax,FloatWP.WP_XFT
		add	ax,8192		;0 .. 16383
		shr	ax,cl		;0 .. 255
		mov	ah,BYTE PTR FloatWP.WP_XSEC
		sub	ax,PLNXCentre
		mov	Xe[0],ax

		mov	ax,FloatWP.WP_YFT
		add	ax,8192		;0 .. 16383
		shr	ax,cl		;0 .. 255
		mov	ah,31		
		sub	ah,BYTE PTR FloatWP.WP_YSEC
		sub	ax,PLNYCentre
		mov	Ye[0],ax

		call	VDotClip
		jc	DrawPosMarker	;non-visible ->

		mov	al,COL_CRT10	;assume not selected

		cmp	WPPtr,OFFSET FloatWP	;selected?
		jne	@F			;no ->

		mov	al,COL_CRT16

@@:		mov	dl,FloatWP.WP_ID
		call	CharSprite

;----------------------
;* mark current postion
;----------------------

;* check if on map or nearly on map (cannot display if too far off map)

DrawPosMarker:	cmp	M_VIEW.VP_XSEC,32+4
		jg	@F
		cmp	M_VIEW.VP_XSEC,-4
		jl	@F

		cmp	M_VIEW.VP_YSEC,32+4
		jg	@F
		cmp	M_VIEW.VP_YSEC,-4
		jl	@F

		mov	cl,6		;/64

		mov	ax,M_VIEW.VP_XFT
		add	ax,8192		;0 .. 16383
		shr	ax,cl		;0 .. 255
		mov	ah,BYTE PTR M_VIEW.VP_XSEC
		sub	ax,PLNXCentre
		mov	Xe[0],ax

		mov	ax,M_VIEW.VP_YFT
		add	ax,8192		;0 .. 16383
		shr	ax,cl		;0 .. 255
		mov	ah,31		
		sub	ah,BYTE PTR M_VIEW.VP_YSEC
		sub	ax,PLNYCentre
		mov	Ye[0],ax

		call	VDotClip
		jc	@F		;non-visible ->

		mov	al,COL_CRT16
		mov	si,OFFSET CRTRing1
		call	CellSprite

;-----------------------------
;* display waypoint statistics
;-----------------------------

@@:		mov	si,OFFSET WPSetUp$
		call	Print$

		cmp	WayTotal,0	;any waypoints?
		ja	@F		;yes ->

		cmp	WPPtr,OFFSET FloatWP	;floating waypoint selected?
		jne	WPInvalid1		;no ->

@@:		mov	si,OFFSET WPRng$
		call	Print$

		mov	si,OFFSET WPBrg$
		call	Print$

		cmp	WPETA,-1	;ETA valid?
		je	WPInvalid2	;no ->

		mov	si,OFFSET WPETA$
		call	Print$

		jmp	RoutePlanExit

WPInvalid1:	mov	si,OFFSET WPRngInvalid$
		call	Print$

		mov	si,OFFSET WPBrgInvalid$
		call	Print$

WPInvalid2: 	mov	si,OFFSET WPETAInvalid$
		call	Print$

RoutePlanExit:	ret

RoutePlanDisp	ENDP

;----------------------------------------------------------------------------

;* DrawLeg - draw route leg (from waypoint 1 to waypoint 2)
;*
;* pass: si -> waypoint 1
;*       di -> waypoint 2
;* ret : nothing
;* kill: assume all

DrawLeg		PROC	NEAR

		mov	cl,6		;/64

		mov	ax,WP_XFT[si]
		add	ax,8192		;0 .. 16383
		shr	ax,cl		;0 .. 255
		mov	ah,BYTE PTR WP_XSEC[si]
		sub	ax,PLNXCentre
		mov	Xe[0],ax

		mov	ax,WP_YFT[si]
		add	ax,8192		;0 .. 16383
		shr	ax,cl		;0 .. 255
		mov	ah,31		
		sub	ah,BYTE PTR WP_YSEC[si]
		sub	ax,PLNYCentre
		mov	Ye[0],ax

		mov	ax,WP_XFT[di]
		add	ax,8192		;0 .. 16383
		shr	ax,cl		;0 .. 255
		mov	ah,BYTE PTR WP_XSEC[di]
		sub	ax,PLNXCentre
		mov	Xe[2],ax

		mov	ax,WP_YFT[di]
		add	ax,8192		;0 .. 16383
		shr	ax,cl		;0 .. 255
		mov	ah,31
		sub	ah,BYTE PTR WP_YSEC[di]
		sub	ax,PLNYCentre
		mov	Ye[2],ax

		call	VQuickLineClip
		jc	@F		;non-visible ->

		mov	al,COL_CRT5
		mov	cx,XCrt[0]
		mov	bl,YCrt[0]
		mov	dx,XCrt[2]
		mov	bh,YCrt[2]
		call	LineDraw

@@:		ret

DrawLeg		ENDP

;----------------------------------------------------------------------------

;* MapDisp - moving map display
;*
;* pass: si -> TAB data block
;* ret : nothing
;* kill: assume all

MapDisp		PROC	NEAR

;-----------------
;* update map zoom
;-----------------

		KTEST	KF_MapZoomIn
		jz	SkipZoomIn

		cmp	MapZoom,MAP_ZOOM6	;fully zoomed in?
		je	SkipZoomIn		;yes ->

		add	MapZoom,2

		jmp	SkipZoomOut

SkipZoomIn:	KTEST	KF_MapZoomOut
		jz	SkipZoomOut

		cmp	MapZoom,MAP_ZOOM1	;fully zoomed out?
		je	SkipZoomOut		;yes ->

		sub	MapZoom,2

;-------------------
;* update map origin
;-------------------

SkipZoomOut:	KTEST	KF_MapOrigin
		jz	@F

		xor	MapOrigin,MAP_ORG_BASE

;----------
;* draw map
;----------

@@:		mov	ax,MAP_TAB_DISP

        cmp	CrewMode,CREW_NAVIG
        jne @F		
		mov	cx,XOrg
		mov	bl,YOrg
		jmp Conthere
@@:		
        mov	cx,0
		mov	bl,0
Conthere:
		xor	bh,bh
		mov	dx,MapZoom
		mov	bp,MapOrigin

		mov	si,OFFSET M_VIEW
		call	UpdateMovingMap

;--------------------------
;* display current waypoint
;--------------------------

		mov	cx,CurrentWPX
		mov	bx,CurrentWPY

		cmp	cx,-1		;valid?
		je	@F		;no ->
		cmp	bx,-1		;valid?
		je	@F		;no ->

		add	cx,XOrg
		add	bx,WORD PTR YOrg

		mov	si,WPPtr
		mov	dl,[si].WP_ID

		;mov	al,COL_MAP_SYM
		cmp NVG_set,1
		je setcolourhudd1
		mov	al,COL_MAP_SYM
		jmp zxs1
setcolourhudd1:		
		mov	al,COL_HUD
zxs1:			

		call	CharSprite

;----------------
;* draw hdg datum (wrt origin)
;----------------

@@:		
        cmp	CrewMode,CREW_NAVIG
        jne @F		
        mov	cx,XOrg
		add	cx,XC
		mov	bl,YOrg
		jmp Conthere2
@@:		
        mov	cx,0
		add	cx,XC
		mov	bl,0
Conthere2:

		mov	dx,TAB_DEPTH/2	;assume MAP_ORG_BASE

		cmp	MapOrigin,MAP_ORG_BASE	;base origin?
		je	@F			;yes ->

		mov	dx,TAB_DEPTH/4

@@:		push	bx
		push	cx
		push	dx
		
		;mov	al,COL_MAP_SYM
		cmp NVG_set,1
		je setcolourhudd2
		mov	al,COL_MAP_SYM
		jmp zxs2
setcolourhudd2:		
		mov	al,COL_HUD
zxs2:					
		
		call	SetPixel
		pop	dx
		pop	cx
		pop	bx
		add	bl,2
		dec	dx
		jnz	@B

		dec	cx
		sub	bl,2

		push	bx
		push	cx
		
		;mov	al,COL_MAP_SYM
		cmp NVG_set,1
		je setcolourhudd3
		mov	al,COL_MAP_SYM
		jmp zxs3
setcolourhudd3:		
		mov	al,COL_HUD
zxs3:					
		call	SetPixel
		pop	cx
		pop	bx
	
		add	cx,2

		;mov	al,COL_MAP_SYM
		cmp NVG_set,1
		je setcolourhudd4
		mov	al,COL_MAP_SYM
		jmp zxs4
setcolourhudd4:		
		mov	al,COL_HUD
zxs4:					
		call	SetPixel

		ret

MapDisp		ENDP

;----------------------------------------------------------------------------

;* RefDisp - reference map display
;*
;* pass: si -> TAB data block
;* ret : nothing
;* kill: assume all
;*
;* note: How to use reference map (mouse control only):-
;*
;*	 The reference map allows the Nav to view any area of the map at
;*	 any of the available zoom levels. The Nav can also designate a
;*	 target on this map.
;*
;*       Use mouse x, y motion to slew map.
;*
;*	 Click lh mouse button to designate a target.
;*	 Click rh mouse button to cancel designation.
;*
;*	 It is not possible to designate outside of the active map area.
;*
;*       Use ALT key to locate aircraft or target:-
;*
;*	    ALT key and click lh button to locate aircraft (if on active map).
;*	    ALT key and click rh button to locate target (if valid).
;*
;*	 Use CTRL key to zoom (step zoom):-
;*
;*	    CTRL key and click lh button to zoom in.
;*	    CTRL key and click rh button to zoom out.

RefDisp		PROC	NEAR

		mov	RefDesignated,0	;assume no designation made

;------------------
;* read mouse input
;------------------

		cmp	DisableInput,0	;input disabled?
		_JNE	DrawRefMap	;yes ->

		test	QuieterCockpit,1	;in cockpit?
		jnz @F ;->yes
		jmp GoOverHereMann		
@@:		
		test	[si].TAB_HAS_MOUSE,1	;mouse available?
		_JZ	DrawRefMap		;no ->
GoOverHereMann:
		call	ReadMouseMotion

;* note: al = 1 = lhs button pressed
;*       ah = 1 = rhs button pressed
;*       cx = XMickeys (-32768 .. 32767)
;*       bx = YMickeys (-32768 .. 32767)
;*       dl = 1 = lhs button just pressed
;*       dh = 1 = rhs button just pressed

;----------------------
;* sort locate aircraft
;----------------------

		test	Key[K_ALT],dl	;locate aircraft?
		jz	@F		;no ->

;* locate aircraft

		COPY_VP	REF_VIEW,M_VIEW

;* reset mouse buttons

		xor	ax,ax
		xor	dx,dx

		jmp	ContRefSlew

;--------------------
;* sort locate target
;--------------------

@@:		test	Key[K_ALT],dh	;locate target?
		jz	@F		;no ->

;* locate target (if valid)

		test	FloatWP.WP_ATTR,WP_VALID	;valid?
		jz	@F				;no ->

		mov	ax,FloatWP.WP_XSEC
		mov	REF_VIEW.VP_XSEC,ax

		mov	ax,FloatWP.WP_YSEC
		mov	REF_VIEW.VP_YSEC,ax
		
		mov	ax,FloatWP.WP_XFT
		mov	REF_VIEW.VP_XFT,ax

		mov	ax,FloatWP.WP_YFT
		mov	REF_VIEW.VP_YFT,ax

;* reset mouse buttons

		xor	ax,ax
		xor	dx,dx

		jmp	ContRefSlew

;-----------
;* sort zoom
;-----------

@@:		test	Key[K_CTRL],1	;update zoom?
		jz	ContRefSlew	;no ->

		test	dl,dl		;zoom in?
		jnz	RefZoomIn	;yes ->

		test	dh,dh		;zoom out?
		jnz	RefZoomOut	;yes ->

		jmp	RefZoomOk

;* zoom in

RefZoomIn:	cmp	RefZoom,MAP_ZOOM6	;fully zoomed in?
		je	RefZoomOk		;yes ->

		add	RefZoom,2

		jmp	RefZoomOk

;* zoom out

RefZoomOut:   	cmp	RefZoom,MAP_ZOOM1	;fully zoomed out?
		je	RefZoomOk 	 	;yes ->

		sub	RefZoom,2

;* reset mouse buttons

RefZoomOk:	xor	ax,ax
		xor	dx,dx

;----------
;* slew map
;----------

;* @ MAP_ZOOM1 move 512ft / mickey
;* @ MAP_ZOOM2 move 256ft / mickey
;* @ MAP_ZOOM3 move 128ft / mickey
;* @ MAP_ZOOM4 move  64ft / mickey
;* @ MAP_ZOOM5 move  32ft / mickey
;* @ MAP_ZOOM6 move  16ft / mickey

ContRefSlew:	push	dx		;store button status

		mov	si,XMickeys
		SBOUND	si,-255,255

		mov	di,YMickeys
		SBOUND	di,-255,255
		neg	di

;* yr = -YMickeys * cos(hdg) - XMickeys * sin(hdg)
		
		mov	ax,M_CosH
		imul	di
		shl	ax,1		;adjust after fractional multiply
		rcl	dx,1
		mov	bx,ax
		mov	cx,dx

		mov	ax,M_SinH
		imul	si
		shl	ax,1		;adjust after fractional multiply
		rcl	dx,1

		sub	bx,ax
		sbb	cx,dx

		shl	bx,1		;1/2 bit round up
		adc	cx,0

		mov	ax,cx
		cwd
		mov	bx,ax
		mov	cx,dx

;* xr = XMickeys * cos(hdg) + YMickeys * sin(hdg)

		mov	ax,M_CosH
		imul	si
		shl	ax,1		;adjust after fractional multiply
		rcl	dx,1
		mov	bp,ax
		mov	si,dx

		mov	ax,M_SinH
		imul	di
		shl	ax,1		;adjust after fractional multiply
		rcl	dx,1
		
		add	ax,bp
		adc	dx,si

		shl	ax,1		;1/2 bit round up
		adc	dx,0

		mov	ax,dx
		cwd

;* scale up (wrt zoom)

		mov	bp,18
		sub	bp,RefZoom		;18 .. 8 step 2
		shr	bp,1			; 9 .. 4

@@:		shl	ax,1
		rcl	dx,1

		shl	bx,1
		rcl	cx,1

		dec	bp
		jnz	@B

		mov	si,OFFSET REF_VIEW
		call	MoveViewpoint

;* keep viewpoint on active map

		cmp	REF_VIEW.VP_XSEC,0
		jge	@F
		mov	REF_VIEW.VP_XSEC,0
		mov	REF_VIEW.VP_XFT,-8192

@@:		cmp	REF_VIEW.VP_XSEC,31
		jle	@F
		mov	REF_VIEW.VP_XSEC,31
		mov	REF_VIEW.VP_XFT,8191

@@:		cmp	REF_VIEW.VP_YSEC,0
		jge	@F
		mov	REF_VIEW.VP_YSEC,0
		mov	REF_VIEW.VP_YFT,8191

@@:		cmp	REF_VIEW.VP_YSEC,31
		jle	@F
		mov	REF_VIEW.VP_YSEC,31
		mov	REF_VIEW.VP_YFT,-8192

@@:		pop	dx		;restore button status

;---------------------------
;* test for cancel designate
;---------------------------

		test	dh,dh		;rh mouse button just pressed?
		jz	@F		;no ->

		call	CancelTgtWP

		jmp	DrawRefMap

;---------------------------
;* test for target designate
;---------------------------

@@:		test	dl,dl		;lh mouse button just pressed?
		jz	DrawRefMap	;no ->

		mov	RefDesignated,1

		call	SnapGndObject

;* update floating waypoint

		mov	ax,REF_VIEW.VP_XSEC
		mov	FloatWP.WP_XSEC,ax

		mov	ax,REF_VIEW.VP_YSEC
		mov	FloatWP.WP_YSEC,ax
		
		mov	ax,REF_VIEW.VP_XFT
		mov	FloatWP.WP_XFT,ax

		mov	ax,REF_VIEW.VP_YFT
		mov	FloatWP.WP_YFT,ax

		or	FloatWP.WP_ATTR,WP_VALID

		call	UpdateTgtWP		;tell AutoRoute

;----------
;* draw map
;----------

DrawRefMap:	mov	ax,M_VIEW.VP_HDG	;update hdg
		mov	REF_VIEW.VP_HDG,ax

		mov	ax,MAP_TAB_DISP
		mov	cx,XOrg
		mov	bl,YOrg
		xor	bh,bh
		mov	dx,RefZoom
		mov	bp,MAP_ORG_CENTRE

		mov	si,OFFSET REF_VIEW
		call	UpdateMovingMap

;-------------------------------
;* draw floating waypoint symbol (if valid and visible)
;-------------------------------

		mov	cx,FloatWPX
		mov	bx,FloatWPY

		cmp	cx,-1		;x valid?
		_JE	SkipWPSymbol	;no ->
		cmp	bx,-1		;y valid?
		_JE	SkipWPSymbol	;no ->
		
		cmp NVG_set,1
		je putcolorhud1
		PLOTSYM	 0, -4, COL_REF_SYM
		PLOTSYM	 0, -3, COL_REF_SYM
		PLOTSYM	 0, -2, COL_REF_SYM
		PLOTSYM	 0,  2, COL_REF_SYM
		PLOTSYM	 0,  3, COL_REF_SYM
		PLOTSYM	 0,  4, COL_REF_SYM
		PLOTSYM	-4,  0, COL_REF_SYM
		PLOTSYM	-3,  0, COL_REF_SYM
		PLOTSYM	-2,  0, COL_REF_SYM
		PLOTSYM	 2,  0, COL_REF_SYM
		PLOTSYM	 3,  0, COL_REF_SYM
		PLOTSYM	 4,  0, COL_REF_SYM		
		jmp getout1
putcolorhud1:		
		PLOTSYM	 0, -4, COL_HUD
		PLOTSYM	 0, -3, COL_HUD
		PLOTSYM	 0, -2, COL_HUD
		PLOTSYM	 0,  2, COL_HUD
		PLOTSYM	 0,  3, COL_HUD
		PLOTSYM	 0,  4, COL_HUD
		PLOTSYM	-4,  0, COL_HUD
		PLOTSYM	-3,  0, COL_HUD
		PLOTSYM	-2,  0, COL_HUD
		PLOTSYM	 2,  0, COL_HUD
		PLOTSYM	 3,  0, COL_HUD
		PLOTSYM	 4,  0, COL_HUD		
getout1:			
;----------------------------
;* draw aircraft datum symbol (if visible)
;----------------------------

SkipWPSymbol:	mov	cx,ACDatumX
		mov	bx,ACDatumY

		cmp	cx,-1		;x valid?
		_JE	SkipACSymbol	;no ->
		cmp	bx,-1		;y valid?
		_JE	SkipACSymbol	;no ->
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		cmp NVG_set,1
		je putcolorhud2
		PLOTSYM	 0, -3, COL_REF_SYM
		PLOTSYM	 0, -2, COL_REF_SYM
		PLOTSYM	 0, -1, COL_REF_SYM
		PLOTSYM	 0,  0, COL_REF_SYM
		PLOTSYM	 0,  1, COL_REF_SYM
		PLOTSYM	 0,  2, COL_REF_SYM
		PLOTSYM	 0,  3, COL_REF_SYM

		PLOTSYM	-3, -1, COL_REF_SYM
		PLOTSYM	-2, -1, COL_REF_SYM
		PLOTSYM	-1, -1, COL_REF_SYM
		PLOTSYM	 1, -1, COL_REF_SYM
		PLOTSYM	 2, -1, COL_REF_SYM
		PLOTSYM	 3, -1, COL_REF_SYM

		PLOTSYM	-1,  2, COL_REF_SYM
		PLOTSYM	 1,  2, COL_REF_SYM

		jmp getout2
putcolorhud2:		
		PLOTSYM	 0, -3, COL_HUD
		PLOTSYM	 0, -2, COL_HUD
		PLOTSYM	 0, -1, COL_HUD
		PLOTSYM	 0,  0, COL_HUD
		PLOTSYM	 0,  1, COL_HUD
		PLOTSYM	 0,  2, COL_HUD
		PLOTSYM	 0,  3, COL_HUD

		PLOTSYM	-3, -1, COL_HUD
		PLOTSYM	-2, -1, COL_HUD
		PLOTSYM	-1, -1, COL_HUD
		PLOTSYM	 1, -1, COL_HUD
		PLOTSYM	 2, -1, COL_HUD
		PLOTSYM	 3, -1, COL_HUD

		PLOTSYM	-1,  2, COL_HUD
		PLOTSYM	 1,  2, COL_HUD	
getout2:			
		
		;;;;;;;;;;;;;;;;;;;;
;------------------------
;* draw designator symbol
;------------------------

;* if just designated, adjust designator pos to match target waypoint pos

SkipACSymbol:	test	RefDesignated,1	;just designated?
		jz	@F		;no ->

		mov	cx,FloatWPX
		mov	bx,FloatWPY

		mov	RefDesX,cx
		mov	RefDesY,bx

@@:		mov	cx,RefDesX
		mov	bx,RefDesY
		
		cmp NVG_set,1
		je putcolorhud3
		PLOTSYM	 0, -2, COL_REF_SYM
		PLOTSYM	 0, -1, COL_REF_SYM
		PLOTSYM	 0,  1, COL_REF_SYM
		PLOTSYM	 0,  2, COL_REF_SYM
		PLOTSYM	-2,  0,COL_REF_SYM
		PLOTSYM	-1,  0,COL_REF_SYM
		PLOTSYM	 1,  0,COL_REF_SYM
		PLOTSYM	 2,  0,COL_REF_SYM
		jmp getout3
putcolorhud3:
		PLOTSYM	 0, -2, COL_HUD
		PLOTSYM	 0, -1, COL_HUD
		PLOTSYM	 0,  1, COL_HUD
		PLOTSYM	 0,  2, COL_HUD
		PLOTSYM	-2,  0,COL_HUD
		PLOTSYM	-1,  0,COL_HUD
		PLOTSYM	 1,  0,COL_HUD
		PLOTSYM	 2,  0,COL_HUD		
getout3:
;------------------------------------------------------
;* display map datum range, bearing etc. (from Tornado)
;------------------------------------------------------

;* calc range and bearing

		mov	si,OFFSET M_VIEW
		mov	di,OFFSET REF_VIEW
		call	CalcRngBrgVP_VP

		mov	WORD PTR RefRng,ax
		mov	WORD PTR RefRng+2,dx
		mov	RefBrg,bx

;* calc range (nautical miles)

		call	CalcNMiles

		mov	RefRngNMiles,ax

;* calc ETA (only valid if vtas > 0 and abs(ang diff) <= 45 degs)

		mov	RefETA,-1	;assume invalid

		cmp	Vtas,0		;vtas > 0?
		je	@F		;no ->

		mov	ax,Hdg
		mov	dx,RefBrg
		call	CalcAngDiff

		cmp	ax,64		;abs(ang diff) <= 45 degs?
		ja	@F		;no ->

		mov	ax,WORD PTR RefRng
		mov	dx,WORD PTR RefRng+2

		mov	bx,Vtas

		call	CalcETA

		mov	RefETA,ax

@@:		
		cmp NVG_set,1
		je putcolorhud4        
		mov	si,OFFSET RefMap$
putcolorhud4:		
        mov	si,OFFSET RefMap_COL_HUD$
		jmp getout4
getout4:		
		call	Print$

		mov	si,OFFSET RefETA$	;assume ETA valid

		cmp	RefETA,-1		;valid?
		jne	@F			;yes ->

		mov	si,OFFSEt RefETAInvalid$

@@:		call	Print$

		ret

RefDisp		ENDP

;----------------------------------------------------------------------------

;* SnapGndObject - snap to ground object (if available)
;*
;* pass: REF_VIEW <> (must be on active map)
;* ret : cf = 0: no snap
;*       cf = 1: snapped (REF_VIEW <> modified)
;* kill: assume all (except cf)

SnapGndObject	PROC	NEAR

;-------------------------------------
;* calc map index = x sec + y sec * 32
;-------------------------------------

		mov	bp,REF_VIEW.VP_YSEC

		REPT	5
		shl	bp,1
		ENDM

		add	bp,REF_VIEW.VP_XSEC

;--------------------------
;* test for occupied sector
;--------------------------

		mov	al,SectorLayer1[bp]

		test	al,al		;occupied sector?
		_JZ	FailSnapGnd	;no ->

;------------------------------------
;* calc pointer to sector data record
;------------------------------------

		CALC_SEC_PTR

		mov	si,[bx].SEC_OBJ_PTR	;si -> ground object list

;----------------------
;* calc nearest sub-div
;----------------------

		mov	ax,REF_VIEW.VP_XFT
		add	ax,8192
		shl	al,1
		ROUNDUP	ah
		mov	dl,ah		;x grid (0 .. 64)

		mov	ax,REF_VIEW.VP_YFT
		add	ax,8192
		shl	al,1
		ROUNDUP	ah
		mov	dh,ah		;y grid (0 .. 64)

;------------------
;* scan object list (search for ground object at sub-div)
;------------------

;* note: The object status (alive / dead) is not checked as this information
;*       is not available to the map database.

ScanObjLoop:	mov	ax,SECDATA1
		mov	es,ax

		ES_LODSB		;fetch object number
		mov	bl,al

		inc	si		;skip animation flags

		ES_LODSB		;fetch x grid
		mov	cl,al

		ES_LODSB		;fetch y grid
		mov	ch,al

		mov	ax,DATA
		mov	es,ax

		cmp	bl,-1		;end of list?
		je	FailSnapGnd	;yes ->

		cmp	cx,dx		;grid match?
		jne	ScanObjLoop	;no ->

;* exclude trees (assume GND_COPSEA .. GND_COPSED are contiguous)

		cmp	bl,GND_COPSEA	;tree?
		jb	@F		;no ->
		cmp	bl,GND_COPSED	;tree?
		jbe	FailSnapGnd	;yes ->

;* convert x grid, y grid to xft, yft

@@:		xor	al,al

		mov	ah,dl
		sub	ah,32

		SBOUND	ax,-8192,8191	;(in case sub-div = 64)

		mov	REF_VIEW.VP_XFT,ax

		mov	ah,dh
		sub	ah,32

		SBOUND	ax,-8192,8191	;(in case sub-div = 64)

		mov	REF_VIEW.VP_YFT,ax

		stc			;cf = 1
		ret

FailSnapGnd:	clc			;cf = 0
		ret

SnapGndObject	ENDP

;----------------------------------------------------------------------------
;* FLIRDisp - forward looking infra-red  (FULL-SCREEN)
;*
;* pass: si -> TAB data block
;* ret : nothing
;* kill: assume all

FLIRDisp 	PROC	NEAR
        mov InCockpit,1
        ;Mod 43 by Frankie Kam on 18/3/2018
		KTEST	KF_NavigViewWithCtrl
		jz	@F	
		KCLEAR	KF_NavigViewWithCtrl
        sub bx, 2 ;Pointer skips to previous TAB display, i.e., TIALD normal-sized view
        jmp	SelectSwitch[bx]	
		ret
@@:
		mov	TAB1.TAB_X_ORG,0  ;Awesome! Frankie hack on 27/11/17
		mov	TAB1.TAB_Y_ORG,0  
		mov	TAB2.TAB_X_ORG,220
		mov	TAB2.TAB_Y_ORG,0  
		mov	NAVIG_MFD.MFD_X_ORG,0
		mov	NAVIG_MFD.MFD_Y_ORG,0  
				
		mov	ax,EXT_VIEWMODE
		;mov	ax,TV3_VIEWMODE
		
		mov	IronWork,0 ;hacked by Frankie 30/11/2017
		mov	cx,XOrg
		mov	bl,YOrg
		call	SetViewMode
		COPY_VP	TMP_VIEW,M_VIEW
		add	WORD PTR TMP_VIEW.VP_ZFT_LO,8	;add zft displacement
		adc	WORD PTR TMP_VIEW.VP_ZFT_HI,0
		call	DrawIRImage
		mov	ax,NUL_VIEWMODE	;set viewmode for navig view
		call	SetViewMode	
        call LoadExtrnPan  ;added on 6/11/2017
		call UpdateExtrn   ;added on 6/11/2017
	
		cmp	TAB2.TAB_MODE,TAB_FLIR	;TAB2's FLIR selected?
        je BypassEScope2 ;yes ->  		
        call UpdateEScope2
		call UpdateRWR		
		call UpdateADI2		
BypassEScope2:
        call UpdateHUD2
		call UpdateCtrlSFace		
        mov	IronWork,1
		ret

FLIRDisp	ENDP

;----------------------------------------------------------------------------

;* ValidateTIALD - check TIALD range when TIALD display not active
;*
;* pass: TIALDActive
;* ret : TIALDActive
;*	 LaserActive
;* kill: assume all
;*
;* The TIALD function is slaved to the TAB display. This is unavoidable as
;* the display and the mouse are mandatory to use this device. However, if
;* the TIALD is not being updated then it is still necessary to check the
;* validity of the TIALD lock.
;*
;* TIALD operating conditions (roll, pitch and altitude) are not checked as
;* the effect of losing laser guidance due to any of these may be too subtle.

ValidateTIALD	PROC	FAR

		test	TIALDActive,1		;TIALD updated?
		jnz	ValidateExit		;yes ->

		cmp	TDMode,TIALD_ADJ_LOCK	;adjust lock?
		je	CancelTIALD		;yes ->

		cmp	TDMode,TIALD_TGT_LOCK	;target lock?
		jne	InitTIALD		;no ->

		call	TargetMoved		;target ok?
		jc	InitTIALD		;no ->

		call	CalcScanSize

		call	RecalcXYOffsets

		test	TDDrag,1		;within scan limits?
		jz	ValidateExit		;yes ->

CancelTIALD:	call	CancelTgtWP

InitTIALD:	mov	TDMode,TIALD_INIT

		mov	LaserActive,0

ValidateExit:	mov	TIALDActive,0

		ret

ValidateTIALD	ENDP

;----------------------------------------------------------------------------
;* TIALDDisp - thermal image and laser designation display (FULL-SCREEN)
;*
;* pass: si -> TAB data block
;* ret : nothing
;* kill: assume all
;*
;* note: How to use TIALD (mouse control only):-
;*
;*       Use mouse x, y motion to steer TIALD.
;*
;*	 Click lh mouse button to designate a target (hold and drag to adjust).
;*	 Click rh mouse button to cancel designation.
;*
;*	 Use CTRL key to zoom (continuous zoom):-
;*
;*	    CTRL key and move mouse forward to zoom in.
;*	    CTRL key and move mouse backward to zoom out.
;*
;* 	 Zoom still functions after designation.
;*
;* 	 Scan area is related to altitude. The cursor blinks when it is being
;*	 dragged along the scan edge.
;*
;*	 It is not possible to designate outside of the active map area.



TIALDDisp	PROC	NEAR
        ;Mod 43 by Frankie Kam on 18/3/2018
		mov InCockpit,1
		KTEST	KF_NavigViewWithCtrl
		jz	@F	
		KCLEAR	KF_NavigViewWithCtrl
        sub bx, 2 ;Pointer skips to previous TAB display, i.e., TIALD normal-sized view0
		jmp	SelectSwitch[bx]
		ret		
@@:
;----------------------------
;* check operating conditions
;----------------------------
        ;Bingo
		;cmp	TAB2.TAB_MODE,TAB_FLIR_ORI
	    ;je @F
		cmp	M_CosP,16384	;pitch in limits (+/-60degs)?
		jl	@F		;no ->

		cmp	M_CosR,16384	;roll in limits (+/-60degs)?
		jl	@F		;no ->

		cmp	TrueRadAlt,MIN_OP_RAD_ALT	;rad alt ok?
		jae	TIALDOk				;no ->
        
@@:		mov	TDMode,TIALD_INIT

		call InvalidDisp
		cmp	TAB1.TAB_MODE,TAB_FLIR_ORI
		je @F
		call VGA_DrwNavigPanBrief
@@:		
		cmp	TAB1.TAB_MODE,TAB_FLIR_ORI
		je @F
		cmp	TAB1.TAB_MODE,TAB_TIALD_ORI
		je @F		
		cmp	TAB2.TAB_MODE,TAB_FLIR_ORI
		je @F
		cmp	TAB2.TAB_MODE,TAB_TIALD_ORI
		je @F				
		call DrawADIRollBug	
@@:		
		jmp	TIALDExit

;---------------
;* init viewmode
;---------------

TIALDOk:	
		call LoadExtrnPan   ;added on 17/11/17
		call UpdateExtrn    ;added on 17/11/17
		mov	TAB1.TAB_X_ORG,0  ;Awesome! Frankie hack on 27/11/17
		mov	TAB1.TAB_Y_ORG,0  
		mov	TAB2.TAB_X_ORG,220
		mov	TAB2.TAB_Y_ORG,0  
		mov	NAVIG_MFD.MFD_X_ORG,0
		mov	NAVIG_MFD.MFD_Y_ORG,0  
		mov	ax,EXT_VIEWMODE
		;mov	ax,TV3_VIEWMODE
		mov	cx,XOrg
		mov	bl,YOrg
		call	SetViewMode

;----------------------------
;* store visual configuration
;----------------------------

		push	WORD PTR GradEnabled
		push	WORD PTR StarsEnabled
		push	WORD PTR CloudsEnabled
		push	WORD PTR HillTextEnabled

		push	SecScanCnt1
		push	SecScanOff1
		push	SecScanCnt2
		push	SecScanOff2

;-----------------------------
;* modify visual configuration
;-----------------------------

;* if night or foggy use IR visual colours

		cmp	Night,1		;Dusk (still light enough to see)?
		je	SkipIRCols	;no ->
		
		cmp	Night,0		;night?
		jne	@F		;yes ->

		cmp	Fog,0		;foggy?
		je	SkipIRCols	;no ->

@@:		;call CheckForNVG
        ;call	SetIRPalette

		;mov	StarsEnabled,0

SkipIRCols:	mov	GradEnabled,0
		mov	CloudsEnabled,0
		mov	HillTextEnabled,0

		mov	SecScanCnt1,5		;minimize range
		mov	SecScanOff1,-2
		mov	SecScanCnt2,5
		mov	SecScanOff2,-2

;----------------------
;* calc TIALD scan size
;----------------------

		call	CalcScanSize

;-----------------
;* clear drag flag
;-----------------

		mov	TDDrag,0

;------------------
;* read mouse input
;------------------

		cmp	DisableInput,0	;input disabled?
		jne	@F		;yes ->

		mov	si,TABPtr
		test	[si].TAB_HAS_MOUSE,1	;mouse available?
		jnz	ReadTIALDMouse		;yes ->

;* null input from mouse

@@:		xor	ax,ax
		xor	bx,bx
		xor	cx,cx
		xor	dx,dx

		mov	XMickeys,cx
		mov	YMickeys,bx

		mov	TDZoomKey,0

		jmp	SortTDMode

ReadTIALDMouse:	mov	al,Key[K_CTRL]	;update zoom override flag
		mov	TDZoomKey,al

		call	ReadMouseMotion

;* note: al = 1 = lhs button pressed
;*       ah = 1 = rhs button pressed
;*       cx = XMickeys (-32768 .. 32767)
;*       bx = YMickeys (-32768 .. 32767)
;*       dl = 1 = lhs button just pressed
;*       dh = 1 = rhs button just pressed

;-------------
;* select mode
;-------------

SortTDMode:	mov	bx,TDMode
		jmp	TDSwitch[bx]

;---------------------------
TIALDInit	LABEL	NEAR
;---------------------------

;* init mode ensures start up into search mode regardless of mouse input

		call	SetDatum

		mov	TDMode,TIALD_SEARCH

		jmp	IntoSearch

;---------------------------
TIALDSearch	LABEL	NEAR
;---------------------------

;* cancel lock?

		test	dh,dh		;rh button just pressed?
		jz	@F		;no ->

		push	dx
		call	CancelTgtWP
		pop	dx

;* switch to adjust lock mode?

@@:		test	dl,dl		;lh button just pressed?
		jz	@F		;no ->

		call	SetTarget
		jc	@F		;target invalid ->

		mov	TDMode,TIALD_ADJ_LOCK

		jmp	IntoAdjustLock

;* switch to zoom mode?

@@:		test	TDZoomKey,1	;CTRL key pressed?
		jz	IntoSearch	;no ->

		mov	TDMode,TIALD_ZOOM

		jmp	IntoZoom

;* search within viewing window

IntoSearch:	call	SetDatum

		call	AdjustXYOffsets

		call	RotateXYOffsets

		jmp	ContVisual

;---------------------------
TIALDZoom	LABEL	NEAR
;---------------------------

;* cancel lock?

		test	dh,dh		;rh button just pressed?
		jz	@F		;no ->

		push	dx
		call	CancelTgtWP
		pop	dx

;* switch to adjust lock mode?

@@:		test	dl,dl		;lh button just pressed?
		jz	@F		;no ->

		call	SetTarget
		jc	@F		;target invalid ->

		mov	TDMode,TIALD_ADJ_LOCK

		jmp	IntoAdjustLock

;* switch to search mode?

@@:		test	TDZoomKey,1	;CTRL key released?
		jnz	IntoZoom	;no ->

		call	RecalcXYOffsets

		call	SetDatum

		mov	TDMode,TIALD_SEARCH

		jmp	IntoSearch

;* adjust zoom

IntoZoom:	call	AdjustZoom

		call	RecalcXYOffsets

		test	TDDrag,1	;drag point?
		jz	@F		;no ->

		call	SetDatum

		call	RotateXYOffsets

@@:		jmp	ContVisual

;---------------------------
TIALDAdjustLock	LABEL	NEAR
;---------------------------

;* cancel lock?

		test	dh,dh		;rh button just pressed?
		jz	@F		;no ->

		call	CancelTgtWP

		call	RecalcXYOffsets

		call	SetDatum

		mov	TDMode,TIALD_SEARCH

		jmp	IntoSearch

;* switch to target lock mode?

@@:		test	al,al		;lh button released?
		jnz	IntoAdjustLock	;no ->

		mov	TDMode,TIALD_TGT_LOCK

		jmp	IntoTargetLock

IntoAdjustLock:	call	AdjustLock

		call	RecalcXYOffsets

		test	TDDrag,1	;drag point?
		jz	@F		;no ->

		call	SetDatum

		call	RotateXYOffsets

@@:		call	SetTarget
		jnc	ContVisual	;target valid ->

		call	RecalcXYOffsets

		call	SetDatum

		mov	TDMode,TIALD_SEARCH

		jmp	IntoSearch

;---------------------------
TIALDTargetLock	LABEL	NEAR
;---------------------------

;* has target moved (or cancelled) externally?

		call	TargetMoved	;moved (or cancelled)?
		jc	CancelLock	;yes ->

;* cancel target designation (switch to search mode)?

		test	dh,dh		;rh button just pressed?
		jz	@F		;no ->

		call	CancelTgtWP

CancelLock:	call	RecalcXYOffsets

		call	SetDatum

		mov	TDMode,TIALD_SEARCH

		jmp	IntoSearch

;* return to adjust lock mode?

@@:		test	dl,dl		;lh button just pressed?
		jz	@F		;no ->

		mov	TDMode,TIALD_ADJ_LOCK

		jmp	IntoAdjustLock

;* adjust zoom?

@@:	 	test	TDZoomKey,1	;CTRL key pressed?
		jz	IntoTargetLock	;no ->

		call	AdjustZoom

IntoTargetLock:	call	RecalcXYOffsets

		test	TDDrag,1	;within scan limits?
		jz	ContVisual	;yes ->

		call	SetDatum

		mov	TDMode,TIALD_SEARCH

		jmp	IntoSearch

;---------------------------
ContVisual	LABEL	NEAR
;---------------------------

;* vp alt = max(TDScanSize * TDZoom / 256, gnd ht + MIN_OP_RAD_ALT)

		mov	ax,TDScanSize
		mov	dx,TDZoom
		mul	dx

		mov	dh,al		;store 1/2 bit
		mov	al,ah		;/256
		mov	ah,dl
		shl	dh,1		;expose 1/2 bit
		ROUNDUP	ax

		push	ax

		mov	si,OFFSET TIALD_VIEW
		call	CalcGndHeight

		add	ax,MIN_OP_RAD_ALT

		pop	bx

		cmp	bx,ax		;vp alt >= gnd ht + MIN_OP_RAD_ALT?
		jae	@F		;yes ->

		mov	bx,ax

@@:		xor	cx,cx

;* if overcast then
;*    if ac alt >= cloudbase then
;*       if vp alt < cloudbase then
;*          vp alt = cloudbase
;*       endif
;*    endif
;* endif

		test	Overcast,1	;overcast?
		jz	SetVPAlt	;no ->

		mov	ax,WORD PTR M_VIEW.VP_ZFT_LO
		mov	dx,WORD PTR M_VIEW.VP_ZFT_HI
		sub	ax,WORD PTR CloudBase
		sbb	dx,WORD PTR CloudBase+2
		jb	SetVPAlt	;ac alt < cloudbase ->

		mov	ax,bx
		mov	dx,cx
		sub	ax,WORD PTR CloudBase
		sbb	dx,WORD PTR CloudBase+2
		jae	SetVPAlt	;vp alt > cloudbase ->

		mov	bx,WORD PTR CloudBase
		mov	cx,WORD PTR CloudBase+2

SetVPAlt:	mov	WORD PTR TIALD_VIEW.VP_ZFT_HI,cx
		mov	WORD PTR TIALD_VIEW.VP_ZFT_LO,bx

;-------------------
;* draw TIALD visual
;-------------------

;* keep TIALD hdg in line with aircraft hdg (even if zoom or lock)

		mov	ax,M_VIEW.VP_HDG
		mov	TIALD_VIEW.VP_HDG,ax

;* pitched down, no roll

		;mov	TIALD_VIEW.VP_PITCH,384
		mov	TIALD_VIEW.VP_PITCH,400 ;390    ;hacked to 394 by Frankie on 24/11/2017; 388 seems best
		;mov	TIALD_VIEW.VP_ROLL,0   ;hacked by Frankie on 24/11/2017
		
		mov	si,OFFSET TIALD_VIEW
		call	Visual

;----------------
;* draw symbology
;----------------

;* update blink timer

		mov	ax,TDBlinkTimer
		sub	ax,LastFrame
		mov	TDBlinkTimer,ax
		jnc	@F

		mov	TDBlinkTimer,TD_BLINK_RATE

		xor	TDBlink,1	;toggle blink flag

;* if "dragging" then switch cross off for blink period

		mov	TDCross,1	;assume cross on

		jnz	@F		;0 .. 1 (leading edge) ->

		test	TDDrag,1	;dragging?
		jz	@F		;no ->

		mov	TDCross,0	;cross off

;* draw symbology wrt mode

@@:		mov	bx,TDMode
		jmp	TDSymbolSwitch[bx]

;---------------------------
TDSymZoom	LABEL	NEAR
;---------------------------

		call	DrawLaserSymbol

		jmp	TDSymOk

;---------------------------
TDSymAdjustLock	LABEL	NEAR
;---------------------------

		call	DrawLaserSymbol

;* blink track symbol

		test	TDBLink,1
		jz	@F

		call	DrawTrackSymbol

@@:		jmp	TDSymOk

;---------------------------
TDSymTargetLock	LABEL	NEAR
;---------------------------

;* blink laser symbol

		test	TDBLink,1
		jz	@F

		call	DrawLaserSymbol

@@:		call	DrawTrackSymbol

;---------------------------
TDSymOk		LABEL	NEAR
;---------------------------

		call	DrawCrossSymbol

;------------------------------
;* restore visual configuration
;------------------------------

		pop	SecScanOff2
		pop	SecScanCnt2
		pop	SecScanOff1
		pop	SecScanCnt1

		pop	WORD PTR HillTextEnabled
		pop	WORD PTR CloudsEnabled
		pop	WORD PTR StarsEnabled
		pop	WORD PTR GradEnabled

;* if night or foggy restore visual colours

		cmp	Night,0		;night?
		jne	@F		;yes ->

		cmp	Fog,0		;foggy?
		je	SkipFixCols	;no ->

@@:		;call CheckForNVG
        ;call	FixIRPalette

;------------------
;* restore viewmode
;------------------

SkipFixCols:	mov	ax,NUL_VIEWMODE
		call	SetViewMode	

;--------------------
;* update TIALD flags
;--------------------

TIALDExit:	
        cmp	TrueRadAlt,MIN_OP_RAD_ALT	;rad alt ok?
		jl BypassEScope_and_ADI
        mov	al,1		;assume active

		cmp	TDMode,TIALD_ADJ_LOCK
		je	@F		
		cmp	TDMode,TIALD_TGT_LOCK
		je	@F		

		xor	al,al		;inactive

@@:		mov	LaserActive,al

		mov	TIALDActive,1
		cmp	TAB2.TAB_MODE,TAB_TIALD	;TAB2's TIALD display selected?
        je BypassEScope ;yes ->  
		
		;cmp	TAB2.TAB_MODE,TAB_FLIR_ORI
	    ;je @F
		;Don't show the EScope and ADI gauges if TIALD is broken because past the pitch threshold of +/-60degs!
        cmp	M_CosP,16384	;pitch in limits (+/-60degs)?
		jl	BypassEScope_and_ADI		;no ->
		cmp	M_CosR,16384	;roll in limits (+/-60degs)?
		jl	BypassEScope_and_ADI		
		call UpdateEScope2
BypassEScope:		
;ExitTIALDOk:
		call UpdateADI2  ;display attitude direction indicator	
BypassEScope_and_ADI:		
        call UpdateCtrlSFace		
		ret

TIALDDisp	ENDP

;----------------------------------------------------------------------------

;* CalcScanSize
;*
;* pass: M_VIEW
;* ret : TDScanSize
;* kill: ax, flags

CalcScanSize	PROC	NEAR

;* scan size = ubound(alt, 1, 23170)

		mov	ax,23170	;assume alt > 65,535ft

		cmp	WORD PTR M_VIEW.VP_ZFT_HI,0
		ja	@F

		mov	ax,WORD PTR M_VIEW.VP_ZFT_LO

		UBOUND	ax,1,23170

@@:		mov	TDScanSize,ax

		ret

CalcScanSize	ENDP

;----------------------------------------------------------------------------

;* DrawCrossSymbol
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

DrawCrossSymbol	PROC	NEAR

;* blink cross if "dragging"

		test	TDCross,1
		_JZ	SkipCross

		;* HLineDraw - draw horizontal line between two points
        ;*
        ;* pass: al = logical colour
        ;*       bl = y1
        ;*       cx = x1
        ;*       dx = x2
        ;* ret : nothing
		
		;Top left horizontal
		mov	bl,YOrg_TIALD
		add	bl,YC_TIALD-40
		mov	cx,XOrg_TIALD
		mov	dx,cx
		add	cx,XC_TIALD-53 ;-60
		add	dx,XC_TIALD-49
		mov	al,COL_HUD ;darker grey than COL_GREY1
		call	HLineDraw

		;Top right horizontal
		mov	bl,YOrg_TIALD
		add	bl,YC_TIALD-40
		mov	cx,XOrg_TIALD
		mov	dx,cx
		add	cx,XC_TIALD+53
		add	dx,XC_TIALD+49
		mov	al,COL_HUD
		call	HLineDraw		
		
		
		;* VLineDraw - draw vertical line between two points
		;*
		;* pass: al = logical colour
		;*       bl = y1
		;*       bh = y2
		;*       cx = x1	
		
		;Top left vertical
		mov	bl,YOrg_TIALD
		mov	bh,bl
		add	bl,YC_TIALD-39
		add	bh,YC_TIALD-35
		mov	cx,XOrg_TIALD
		add	cx,XC_TIALD-53
		mov	al,COL_HUD
		call	VLineDraw

		;Top right vertical
		mov	bl,YOrg_TIALD
		mov	bh,bl
		add	bl,YC_TIALD-39
		add	bh,YC_TIALD-35
		mov	cx,XOrg_TIALD
		add	cx,XC_TIALD+53
		mov	al,COL_HUD
		call	VLineDraw		


		;* HLineDraw - draw horizontal line between two points
        ;*
        ;* pass: al = logical colour
        ;*       bl = y1
        ;*       cx = x1
        ;*       dx = x2
        ;* ret : nothing
		
        ;Bottom left horizontal		
		mov	bl,YOrg_TIALD
		add	bl,YC_TIALD+40
		mov	cx,XOrg_TIALD
		mov	dx,cx
		add	cx,XC_TIALD-53
		add	dx,XC_TIALD-49
		mov	al,COL_HUD
		call	HLineDraw
		
		;Bottom right horizontal	
		mov	bl,YOrg_TIALD
		add	bl,YC_TIALD+40
		mov	cx,XOrg_TIALD
		mov	dx,cx
		add	cx,XC_TIALD+53
		add	dx,XC_TIALD+49
		mov	al,COL_HUD
		call	HLineDraw
		
		;* VLineDraw - draw vertical line between two points
		;*
		;* pass: al = logical colour
		;*       bl = y1
		;*       bh = y2
		;*       cx = x1	
		
		;Bottom left vertical
		mov	bl,YOrg_TIALD
		mov	bh,bl
		add	bl,YC_TIALD+35
		add	bh,YC_TIALD+39
		mov	cx,XOrg_TIALD
		add	cx,XC_TIALD-53
		mov	al,COL_HUD
		call	VLineDraw
		
		;Bottom right vertical
		mov	bl,YOrg_TIALD
		mov	bh,bl
		add	bl,YC_TIALD+35
		add	bh,YC_TIALD+39
		mov	cx,XOrg_TIALD
		add	cx,XC_TIALD+53
		mov	al,COL_HUD
		call	VLineDraw
		
		;------------------------------
		
		mov	bl,YOrg_TIALD
		add	bl,YC_TIALD
		mov	cx,XOrg_TIALD
		mov	dx,cx
		add	cx,XC_TIALD-4
		add	dx,XC_TIALD-2
		mov	al,COL_HUD
		call	HLineDraw
	
		mov	bl,YOrg_TIALD
		add	bl,YC_TIALD
		mov	cx,XOrg_TIALD
		mov	dx,cx
		add	cx,XC_TIALD+2
		add	dx,XC_TIALD+4
		mov	al,COL_HUD
		call	HLineDraw
		
		;* VLineDraw - draw vertical line between two points
		;*
		;* pass: al = logical colour
		;*       bl = y1
		;*       bh = y2
		;*       cx = x1	
		mov	bl,YOrg_TIALD
		mov	bh,bl
		add	bl,YC_TIALD-4
		add	bh,YC_TIALD-2
		mov	cx,XOrg_TIALD
		add	cx,XC_TIALD
		mov	al,COL_HUD
		call	VLineDraw
	
		mov	bl,YOrg_TIALD
		mov	bh,bl
		add	bl,YC_TIALD+2
		add	bh,YC_TIALD+4
		mov	cx,XOrg_TIALD
		add	cx,XC_TIALD
		mov	al,COL_HUD
		call	VLineDraw

		cmp	TDYOffset,0	;laser ahead of aircraft?
		_JL	SkipCross	;no ->

		mov	bl,YOrg_TIALD
		add	bl,YC_TIALD-3
		mov	cx,XOrg_TIALD
		add	cx,XC_TIALD-5 ;-4
		mov	al,COL_HUD
		call	SetPixel

		mov	bl,YOrg_TIALD
		add	bl,YC_TIALD-4
		mov	cx,XOrg_TIALD
		add	cx,XC_TIALD-5 ;-4
		mov	al,COL_HUD
		call	SetPixel

		mov	bl,YOrg_TIALD
		add	bl,YC_TIALD-4
		mov	cx,XOrg_TIALD
		add	cx,XC_TIALD-4  ;-3
		mov	al,COL_HUD
		call	SetPixel
	
		mov	bl,YOrg_TIALD
		add	bl,YC_TIALD-4
		mov	cx,XOrg_TIALD
		add	cx,XC_TIALD+4 ;+3
		mov	al,COL_HUD
		call	SetPixel

		mov	bl,YOrg_TIALD
		add	bl,YC_TIALD-4
		mov	cx,XOrg_TIALD
		add	cx,XC_TIALD+5 ;+4
		mov	al,COL_HUD
		call	SetPixel

		mov	bl,YOrg_TIALD
		add	bl,YC_TIALD-3
		mov	cx,XOrg_TIALD
		add	cx,XC_TIALD+5 ;+4
		mov	al,COL_HUD
		call	SetPixel

		mov	bl,YOrg_TIALD
		add	bl,YC_TIALD+3
		mov	cx,XOrg_TIALD
		add	cx,XC_TIALD+5 ;+4
		mov	al,COL_HUD
		call	SetPixel

		mov	bl,YOrg_TIALD
		add	bl,YC_TIALD+4
		mov	cx,XOrg_TIALD
		add	cx,XC_TIALD+5 ;+4
		mov	al,COL_HUD
		call	SetPixel

		mov	bl,YOrg_TIALD
		add	bl,YC_TIALD+4
		mov	cx,XOrg_TIALD
		add	cx,XC_TIALD+4 ;+3
		mov	al,COL_HUD
		call	SetPixel

		mov	bl,YOrg_TIALD
		add	bl,YC_TIALD+4
		mov	cx,XOrg_TIALD
		add	cx,XC_TIALD-4 ;-3
		mov	al,COL_HUD
		call	SetPixel

		mov	bl,YOrg_TIALD
		add	bl,YC_TIALD+4
		mov	cx,XOrg_TIALD
		add	cx,XC_TIALD-5 ;-4
		mov	al,COL_HUD
		call	SetPixel

		mov	bl,YOrg_TIALD
		add	bl,YC_TIALD+3
		mov	cx,XOrg_TIALD
		add	cx,XC_TIALD-5 ;-4
		mov	al,COL_HUD
		call	SetPixel

SkipCross:	ret

DrawCrossSymbol	ENDP

;----------------------------------------------------------------------------

;* DrawLaserSymbol
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

DrawLaserSymbol	PROC	NEAR

		mov	bl,YOrg_TIALD
		mov	bh,bl
		add	bl,YC_TIALD-2
		add	bh,YC_TIALD+1
		mov	cx,XOrg_TIALD
		add	cx,XC_TIALD+6
		mov	al,COL_HUD
		call	VLineDraw

		mov	bl,YOrg_TIALD
		add	bl,YC_TIALD+2
		mov	cx,XOrg_TIALD
		mov	dx,cx
		add	cx,XC_TIALD+6
		add	dx,XC_TIALD+8
		mov	al,COL_HUD
		call	HLineDraw
	
		ret

DrawLaserSymbol	ENDP

;----------------------------------------------------------------------------

;* DrawTrackSymbol
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

DrawTrackSymbol	PROC	NEAR

		mov	bl,YOrg_TIALD
		mov	bh,bl
		add	bl,YC_TIALD-1
		add	bh,YC_TIALD+2
		mov	cx,XOrg_TIALD
		add	cx,XC_TIALD-7
		mov	al,COL_HUD
		call	VLineDraw

		mov	bl,YOrg_TIALD
		add	bl,YC_TIALD-2
		mov	cx,XOrg_TIALD
		mov	dx,cx
		add	cx,XC_TIALD-8
		add	dx,XC_TIALD-6
		mov	al,COL_HUD
		call	HLineDraw
	
		ret

DrawTrackSymbol	ENDP

;----------------------------------------------------------------------------

;* SetDatum
;*
;* pass: M_VIEW
;* ret : TIALD_VIEW
;* kill: assume all

SetDatum	PROC	NEAR

		COPY_VP	TIALD_VIEW,M_VIEW
		
		ret

SetDatum	ENDP

;----------------------------------------------------------------------------

;* SetTarget - set floating waypoint (if on active map)
;*
;* pass: TIALD_VIEW
;* ret : cf = 0: target valid
;*          FloatWP
;*	 cf = 1: target invalid
;* kill: ax, flags (except cf)

SetTarget	PROC	NEAR

		cmp	TIALD_VIEW.VP_XSEC,31	;on active map?
		ja	@F			;no, ignore ->
		cmp	TIALD_VIEW.VP_YSEC,31	;on active map?
		ja	@F			;no, ignore ->

		mov	ax,TIALD_VIEW.VP_XSEC
		mov	FloatWP.WP_XSEC,ax

		mov	ax,TIALD_VIEW.VP_YSEC
		mov	FloatWP.WP_YSEC,ax
		
		mov	ax,TIALD_VIEW.VP_XFT
		mov	FloatWP.WP_XFT,ax

		mov	ax,TIALD_VIEW.VP_YFT
		mov	FloatWP.WP_YFT,ax

		or	FloatWP.WP_ATTR,WP_VALID

		call	UpdateTgtWP    	;tell AutoRoute

		clc			;cf = 0 (target valid)
		ret
		
@@:		stc			;cf = 1 (target invalid)
		ret

SetTarget	ENDP

;----------------------------------------------------------------------------

;* TargetMoved - test if floating waypoint has moved (by another device)
;*
;* pass: TIALD_VIEW
;*       FloatWP
;* ret : cf = 0: ok
;*       cf = 1: moved
;* kill: ax, flags

TargetMoved	PROC	NEAR

		test	FloatWP.WP_ATTR,WP_VALID	;waypoint valid?
		jz	@F				;no ->

		mov	ax,FloatWP.WP_XSEC
		cmp	ax,TIALD_VIEW.VP_XSEC
		jne	@F			;moved ->

		mov	ax,FloatWP.WP_YSEC
		cmp	ax,TIALD_VIEW.VP_YSEC
		jne	@F			;moved ->
		
		mov	ax,FloatWP.WP_XFT
		cmp	ax,TIALD_VIEW.VP_XFT
		jne	@F			;moved ->

		mov	ax,FloatWP.WP_YFT
		cmp	ax,TIALD_VIEW.VP_YFT
		jne	@F			;moved ->

		clc
		ret
		
@@:		stc			;cf = 1 (target moved)
		ret

TargetMoved	ENDP

;----------------------------------------------------------------------------

;* AdjustXYOffsets - adjust x and y offsets (using mouse input)
;*
;* pass: nothing
;* ret : TDXOffset
;*       TDYOffset
;* kill: assume all

AdjustXYOffsets	PROC	NEAR

	     	mov	bp,TDScanSize

;* x motion = sbound(XMickeys, -255, 255) * TDZoom / 2
;*
;* x offset = TDXOffset + TDScanSize * x motion / 32768
;*
;* TDXOffset = sbound(x offset, -TDScanSize, TDScanSize)

;* calc x motion

		mov	ax,XMickeys
		SBOUND	ax,-255,255
		mov	dx,TDZoom
		imul	dx
		sar	dx,1
		rcr	ax,1
		adc	ax,0

;* calc x offset (use 32-bit maths)

		imul	bp
		FRACADJ	ax
		cwd
		mov	bx,ax
		mov	cx,dx
		
		mov	ax,TDXOffset
		cwd

		add	bx,ax
		adc	cx,dx

		mov	ax,cx
		cwd

		xor	bx,dx		;abs(offset)
		xor	cx,dx
		sub	bx,dx
		sbb	cx,dx

		cmp	cx,0		;offset > 65,535?
		ja	@F		;yes ->
		cmp	bx,bp		;offset > scan size?
		jbe	XOk		;no ->

@@:		mov	bx,bp		;limit

XOk:		xor	bx,dx		;restore sign
		sub	bx,dx

		mov	TDXOffset,bx

;* y motion = sbound(-YMickeys, -255, 255) * TDZoom / 2
;*
;* y offset = TDYOffset + TDScanSize * y motion / 32768
;*
;* TDYOffset = sbound(y offset, -TDScanSize, TDScanSize)

;* calc y motion

		mov	ax,YMickeys
		neg	ax		;reverse sense
		SBOUND	ax,-255,255
		mov	dx,TDZoom
		imul	dx
		sar	dx,1
		rcr	ax,1
		adc	ax,0

;* calc y offset (use 32-bit maths)

		imul	bp
		FRACADJ	ax
		cwd
		mov	bx,ax
		mov	cx,dx
		
		mov	ax,TDYOffset
		cwd

		add	bx,ax
		adc	cx,dx

		mov	ax,cx
		cwd

		xor	bx,dx		;abs(offset)
		xor	cx,dx
		sub	bx,dx
		sbb	cx,dx

		cmp	cx,0		;offset > 65,535?
		ja	@F		;yes ->
		cmp	bx,bp		;offset > scan size?
		jbe	YOk		;no ->

@@:		mov	bx,bp		;limit

YOk:		xor	bx,dx		;restore sign
		sub	bx,dx

		mov	TDYOffset,bx

		ret

AdjustXYOffsets	ENDP

;----------------------------------------------------------------------------

;* RotateXYOffsets - rotate x and y offsets wrt hdg
;*
;* pass: TDXOffset
;*	 TDYOffset
;*	 M_VIEW.VP_HDG
;* ret : TIALD_VIEW
;* kill: assume all

RotateXYOffsets	PROC	NEAR

;--------------------------------
;* rotate x and y offsets wrt hdg
;--------------------------------

		mov	ax,M_VIEW.VP_HDG

		SINCOS	si,di,ax	;si = sin(hdg), di = cos(hdg)

;* yr = y * cos(hdg) - x * sin(hdg)

		mov	ax,TDYOffset
		imul	di
		shl	ax,1		;adjust after fractional multiply
		rcl	dx,1
		mov	bx,ax
		mov	cx,dx

		mov	ax,TDXOffset
		imul	si
		shl	ax,1		;adjust after fractional multiply
		rcl	dx,1
		
		sub	bx,ax
		sbb	cx,dx

		shl	bx,1		;1/2 bit round up
		adc	cx,0

		mov	ax,cx
		cwd
		mov	bx,ax
		mov	cx,dx

;* xr = x * cos(hdg) + y * sin(hdg)

		mov	ax,TDXOffset
		imul	di
		shl	ax,1		;adjust after fractional multiply
		rcl	dx,1
		mov	bp,ax
		mov	di,dx

		mov	ax,TDYOffset
		imul	si
		shl	ax,1		;adjust after fractional multiply
		rcl	dx,1
		
		add	ax,bp
		adc	dx,di

		shl	ax,1		;1/2 bit round up
		adc	dx,0

		mov	ax,dx
		cwd

		mov	si,OFFSET TIALD_VIEW
		call	MoveViewpoint

		ret

RotateXYOffsets	ENDP

;----------------------------------------------------------------------------

;* RecalcXYOffsets - recalculate x and y offsets (from fixed point)
;*
;* pass: M_VIEW = current position
;*       TIALD_VIEW = fixed position
;* ret : TDXOffset
;*	 TDYOffset
;*	 TDDrag
;* kill: assume all

RecalcXYOffsets	PROC	NEAR

		mov	TDDrag,0	;assume point within scan limits

;* x1 = xsec * 16384 + xft + 8192

		mov	cx,M_VIEW.VP_XSEC	;xsec * 65536
		xor	bx,bx
		REPT	2		;/4
		sar	cx,1
		rcr	bx,1
		ENDM
		mov	bp,M_VIEW.VP_XFT
		add	bp,8192
		add	bx,bp
		adc	cx,0

;* x2 = xsec * 16384 + xft + 8192

		mov	dx,TIALD_VIEW.VP_XSEC	;xsec * 65536
		xor	ax,ax
		REPT	2		;/4
		sar	dx,1
		rcr	ax,1
		ENDM
		mov	bp,TIALD_VIEW.VP_XFT
		add	bp,8192
		add	ax,bp
		adc	dx,0

;* Dx = x2 - x1

		sub	ax,bx
		sbb	dx,cx

		push	ax		;store Dx
		push	dx

;* y1 = -(ysec * 16384) + yft - 8192

		mov	dx,M_VIEW.VP_YSEC	;ysec * 65536
		xor	ax,ax
		REPT	2		;/4
		sar	dx,1
		rcr	ax,1
		ENDM
		NEG32	dx,ax
		mov	bp,M_VIEW.VP_YFT
		sub	bp,8192
		add	ax,bp
		adc	dx,0

;* y2 = -(ysec * 16384) + yft - 8192

		mov	cx,TIALD_VIEW.VP_YSEC	;ysec * 65536
		xor	bx,bx
		REPT	2		;/4
		sar	cx,1
		rcr	bx,1
		ENDM
		NEG32	cx,bx
		mov	bp,TIALD_VIEW.VP_YFT
		sub	bp,8192
		add	bx,bp
		adc	cx,0

;* Dy = y2 - y1

		sub	bx,ax
		sbb	cx,dx

		pop	dx		;restore Dx
		pop	ax

;-----------------------
;* keep offsets in range
;-----------------------

;* Dx = sbound(Dx,-32767,32767)
;* Dy = sbound(Dy,-32767,32767)

		mov	si,dx		;store sign(Dx)
		mov	di,cx		;store sign(Dy)

		test	dx,dx
		jns	@F

		NEG32	dx,ax

@@:		cmp	dx,0		;Dx > 65535?
		ja	LimitDx		;yes ->
		cmp	ax,32767	;Dx > 32767?
		jbe	@F		;no ->

LimitDx:	mov	ax,32767

		mov	TDDrag,1

@@:		test	si,si
		jns	@F

		neg	ax		;restore sign

@@:		test	cx,cx
		jns	@F

		NEG32	cx,bx

@@:		cmp	cx,0		;Dy > 65535?
		ja	LimitDy		;yes ->
		cmp	bx,32767	;Dy > 32767?
		jbe	@F		;no ->

LimitDy:	mov	bx,32767

		mov	TDDrag,1

@@:		test	di,di
		jns	@F

		neg	bx		;restore sign

@@:		mov	TmpX,ax
		mov	TmpY,bx

;-----------------------------------------
;* rotate north orientated offsets wrt hdg
;-----------------------------------------

;* if hdg <= 256pdegs then
;*    hdg = (-hdg and 511) (counter clockwise)
;* else
;*    hdg = 512 - hdg (clockwise)
;* endif

		mov	ax,M_VIEW.VP_HDG

		cmp	ax,256
		ja	@F

		neg	ax
		and	ax,511

		jmp	HdgOk

@@:		mov	ax,512
		sub	ax,M_VIEW.VP_HDG

HdgOk:		SINCOS	si,di,ax	;si = sin(hdg), di = cos(hdg)

;* xr = x * cos(hdg) + y * sin(hdg)

		mov	ax,TmpX
		imul	di
		FRACADJ	bx

		mov	ax,TmpY
		imul	si
		FRACADJ	ax

		cwd
		xchg	bx,ax
		mov	cx,dx
		cwd

		add	ax,bx
		adc	dx,cx

		mov	bp,0		;assume +ve
		jns	@F   		;+ve
		mov	bp,-1
		NEG32	dx,ax

@@:		cmp	dx,0		;xr > 65535?
		ja	LimitXr		;yes ->
		cmp	ax,TDScanSize	;within scan limits?
		jbe	@F		;yes ->

LimitXr:	mov	ax,TDScanSize

		mov	TDDrag,1

@@: 		xor	ax,bp		;restore sign
		sub	ax,bp

		mov	TDXOffset,ax

;* yr = y * cos(hdg) - x * sin(hdg)

		mov	ax,TmpY
		imul	di
		FRACADJ	bx

		mov	ax,TmpX
		imul	si
		FRACADJ	ax

		cwd
		xchg	bx,ax
		mov	cx,dx
		cwd

		sub	ax,bx
		sbb	dx,cx

		mov	bp,0		;assume +ve
		jns	@F   		;+ve
		mov	bp,-1
		NEG32	dx,ax

@@:		cmp	dx,0		;yr > 65535?
		ja	LimitYr		;yes ->
		cmp	ax,TDScanSize	;within scan limits?
		jbe	@F		;yes ->

LimitYr:	mov	ax,TDScanSize

		mov	TDDrag,1

@@: 		xor	ax,bp		;restore sign
		sub	ax,bp

		mov	TDYOffset,ax

		ret

RecalcXYOffsets	ENDP

;----------------------------------------------------------------------------

;* AdjustZoom - adjust zoom (using mouse input)
;*
;* pass: nothing
;* ret : TDZoom
;* kill: assume all

AdjustZoom	PROC	NEAR

;* y motion = sbound(YMickeys, -255, 255)
;*
;* TDZoom = sbound(TDZoom + y motion, 1, 255)

		mov	dx,YMickeys
		SBOUND	dx,-255,255

		mov	ax,TDZoom
		add	ax,dx
		SBOUND	ax,1,255

		mov	TDZoom,ax

		ret

AdjustZoom	ENDP

;----------------------------------------------------------------------------

;* AdjustLock - adjust lock position (using mouse input)
;*
;* pass: TIALD_VIEW
;* ret : TIALD_VIEW
;* kill: assume all
;*
;* note: This routine borrows TDXOffset and TDYOffset variables in order to
;*       use RotateXYOffsets.

AdjustLock	PROC	NEAR

	     	mov	bp,TDScanSize

;* x motion = sbound(XMickeys, -255, 255) * TDZoom / 2
;*
;* x offset = TDScanSize * x motion / 32768

;* calc x motion

		mov	ax,XMickeys
		SBOUND	ax,-255,255
		mov	dx,TDZoom
		imul	dx
		sar	dx,1
		rcr	ax,1
		adc	ax,0

;* calc x offset

		imul	bp
		FRACADJ	dx

		mov	TDXOffset,dx

;* y motion = sbound(-YMickeys, -255, 255) * TDZoom / 2
;*
;* y offset = TDScanSize * y motion / 32768

;* calc y motion

		mov	ax,YMickeys
		neg	ax		;reverse sense
		SBOUND	ax,-255,255
		mov	dx,TDZoom
		imul	dx
		sar	dx,1
		rcr	ax,1
		adc	ax,0

;* calc y offset

		imul	bp
		FRACADJ	dx

		mov	TDYOffset,dx

;* move lock

		call	RotateXYOffsets

		ret

AdjustLock	ENDP

;----------------------------------------------------------------------------

;* RadarDisp - debug option to test ground mapping radar designation
;*
;* pass: si -> TAB data block
;* ret : nothing
;* kill: assume all

RadarDisp 	PROC	NEAR

		test	FloatWP.WP_ATTR,WP_VALID	;waypoint valid?
		jz	@F				;no ->

;* init viewmode (for TAB display)

		mov	ax,TV3_VIEWMODE
		mov	cx,XOrg
		mov	bl,YOrg
		call	SetViewMode

;* init viewpoint (from waypoint)

		mov	ax,FloatWP.WP_XSEC
		mov	TMP_VIEW.VP_XSEC,ax
		mov	ax,FloatWP.WP_YSEC
		mov	TMP_VIEW.VP_YSEC,ax

		mov	ax,FloatWP.WP_XFT
		mov	TMP_VIEW.VP_XFT,ax
		mov	ax,FloatWP.WP_YFT
		mov	TMP_VIEW.VP_YFT,ax

		mov	si,OFFSET TMP_VIEW
		call	CalcGndHeight

		add	ax,50

		mov	WORD PTR TMP_VIEW.VP_ZFT_LO,ax
		mov	WORD PTR TMP_VIEW.VP_ZFT_HI,0

		mov	TMP_VIEW.VP_HDG,0
		mov	TMP_VIEW.VP_PITCH,384
		mov	TMP_VIEW.VP_ROLL,0

;* draw visual (plan view of target)

		call	DrawIRImage

;* restore viewmode (for navig view)

		mov	ax,NUL_VIEWMODE
		call	SetViewMode	

		ret

;* floating waypoint invalid

@@:		call	InvalidDisp

		ret

RadarDisp	ENDP

;----------------------------------------------------------------------------

;* ClearDisp - clear TAB display
;*
;* pass: si -> TAB data block
;* ret : nothing
;* kill: assume all (except si)

ClearDisp	PROC	NEAR

		push	si

		mov	al,COL_CRT1
		mov	cx,TAB_X_ORG[si]
		mov	bl,TAB_Y_ORG[si]
		mov	dx,cx
		add	dx,TAB_WIDTH-1
		mov	bh,bl
		add	bh,TAB_DEPTH-1
		call	BlockFill

		pop	si

		ret

ClearDisp	ENDP

;----------------------------------------------------------------------------

;* DamagedDisp
;*
;* pass: si -> TAB data block
;* ret : nothing
;* kill: assume all

DamagedDisp	PROC	NEAR

		call	ClearDisp

		mov	cx,36
DamagedLoop:	push	cx
		push	si

		call	RandX
		and	al,07fh
		cmp	al,TAB_DEPTH
		jae	NextDamage

		add	al,TAB_Y_ORG[si]
		mov	bl,al
		mov	cx,TAB_X_ORG[si]
		mov	dx,cx
		add	dx,TAB_WIDTH-1
		mov	al,COL_CRT6
		call	HLineDraw

NextDamage:	pop	si
		pop	cx
		loop	DamagedLoop
		
		ret

DamagedDisp	ENDP

;----------------------------------------------------------------------------

;* InvalidDisp - draw large 'X' in centre of TAB display
;*
;* pass: si -> TAB data block
;* ret : nothing
;* kill: assume all (except si)

InvalidDisp	PROC	NEAR

		call	ClearDisp

		mov	bl,TAB_Y_ORG[si]
		mov	bh,bl
		add	bl,YC-25
		add	bh,YC+25
		mov	cx,TAB_X_ORG[si]
		mov	dx,cx
		add	cx,XC-25
		add	dx,XC+25
		mov	al,COL_CRT8

		push	si
		call	LineDraw
		pop	si

		mov	bl,TAB_Y_ORG[si]
		mov	bh,bl
		add	bl,YC-25
		add	bh,YC+25
		mov	cx,TAB_X_ORG[si]
		mov	dx,cx
		add	cx,XC+25
		add	dx,XC-25
		mov	al,COL_CRT8

		push	si
		call	LineDraw
		pop	si

		ret

InvalidDisp	ENDP


;DrawStandby	PROC	NEAR
;		
		;mov	si,OFFSET SetUp$
		;call	Print$
		
;		mov	si,OFFSET SetUp$
;		call	Print$
		
;* centre dot

;		mov	cx,HUD_X_ORG
;		mov	bl,HUD_Y_ORG
;		mov	al,COL_SIGHT
;		call	SetPixel

;* up stroke

;		mov	cx,HUD_X_ORG
;		mov	bl,HUD_Y_ORG-17
;		mov	bh,HUD_Y_ORG-6
;		mov	al,COL_SIGHT
;		call	VLineDraw

;		mov	cx,HUD_X_ORG-2
;		mov	dx,HUD_X_ORG+2
;		mov	bl,HUD_Y_ORG-18
;		mov	al,COL_SIGHT
;		call	HLineDraw

;		mov	cx,HUD_X_ORG-2
;		mov	dx,HUD_X_ORG+2
;		mov	bl,HUD_Y_ORG-14
;		mov	al,COL_SIGHT
;		call	HLineDraw

;		mov	cx,HUD_X_ORG-3
;		mov	dx,HUD_X_ORG+3
;		mov	bl,HUD_Y_ORG-10
;		mov	al,COL_SIGHT
;		call	HLineDraw

;		mov	cx,HUD_X_ORG-6
;		mov	dx,HUD_X_ORG-4
;		mov	bl,HUD_Y_ORG-9
;		mov	al,COL_SIGHT
;		call	HLineDraw

;		mov	cx,HUD_X_ORG+4
;		mov	dx,HUD_X_ORG+6
;		mov	bl,HUD_Y_ORG-9
;		mov	al,COL_SIGHT
;		call	HLineDraw

;		mov	cx,HUD_X_ORG-7
;		mov	bl,HUD_Y_ORG-8
;		mov	al,COL_SIGHT
;		call	SetPixel

;		mov	cx,HUD_X_ORG+7
;		mov	bl,HUD_Y_ORG-8
;		mov	al,COL_SIGHT
;		call	SetPixel

;		mov	cx,HUD_X_ORG-2
;		mov	dx,HUD_X_ORG+2
;		mov	bl,HUD_Y_ORG-5
;		mov	al,COL_SIGHT
;		call	HLineDraw

;		mov	cx,HUD_X_ORG-3
;		mov	bl,HUD_Y_ORG-4
;		mov	al,COL_SIGHT
;		call	SetPixel

;		mov	cx,HUD_X_ORG+3
;		mov	bl,HUD_Y_ORG-4
;		mov	al,COL_SIGHT
;		call	SetPixel

;* down stroke

;		mov	cx,HUD_X_ORG
;		mov	bl,HUD_Y_ORG+17
;		mov	bh,HUD_Y_ORG+6
;		mov	al,COL_SIGHT
;		call	VLineDraw

;		mov	cx,HUD_X_ORG-2
;		mov	dx,HUD_X_ORG+2
;		mov	bl,HUD_Y_ORG+18
;		mov	al,COL_SIGHT
;		call	HLineDraw

;		mov	cx,HUD_X_ORG-2
;		mov	dx,HUD_X_ORG+2
;		mov	bl,HUD_Y_ORG+14
;		mov	al,COL_SIGHT
;		call	HLineDraw

;		mov	cx,HUD_X_ORG-3
;		mov	dx,HUD_X_ORG+3
;		mov	bl,HUD_Y_ORG+10
;		mov	al,COL_SIGHT
;		call	HLineDraw

;		mov	cx,HUD_X_ORG-6
;		mov	dx,HUD_X_ORG-4
;		mov	bl,HUD_Y_ORG+9
;		mov	al,COL_SIGHT
;		call	HLineDraw

;		mov	cx,HUD_X_ORG+4
;		mov	dx,HUD_X_ORG+6
;		mov	bl,HUD_Y_ORG+9
;		mov	al,COL_SIGHT
;		call	HLineDraw

;		mov	cx,HUD_X_ORG-7
;		mov	bl,HUD_Y_ORG+8
;		mov	al,COL_SIGHT
;		call	SetPixel

;		mov	cx,HUD_X_ORG+7
;		mov	bl,HUD_Y_ORG+8
;		mov	al,COL_SIGHT
;		call	SetPixel

;		mov	cx,HUD_X_ORG-2
;		mov	dx,HUD_X_ORG+2
;		mov	bl,HUD_Y_ORG+5
;		mov	al,COL_SIGHT
;		call	HLineDraw

;		mov	cx,HUD_X_ORG-3
;		mov	bl,HUD_Y_ORG+4
;		mov	al,COL_SIGHT
;		call	SetPixel

;		mov	cx,HUD_X_ORG+3
;		mov	bl,HUD_Y_ORG+4
;		mov	al,COL_SIGHT
;		call	SetPixel

;* left stroke

;		mov	cx,HUD_X_ORG-21
;		mov	dx,HUD_X_ORG-7
;		mov	bl,HUD_Y_ORG
;		mov	al,COL_SIGHT
;		call	HLineDraw

;		mov	cx,HUD_X_ORG-22
;		mov	bl,HUD_Y_ORG-2
;		mov	bh,HUD_Y_ORG+2
;		mov	al,COL_SIGHT
;		call	VLineDraw

;		mov	cx,HUD_X_ORG-17
;		mov	bl,HUD_Y_ORG-2
;		mov	bh,HUD_Y_ORG+2
;		mov	al,COL_SIGHT
;		call	VLineDraw

;		mov	cx,HUD_X_ORG-12
;		mov	bl,HUD_Y_ORG-2
;		mov	bh,HUD_Y_ORG+2
;		mov	al,COL_SIGHT
;		call	VLineDraw

;		mov	cx,HUD_X_ORG-11
;		mov	bl,HUD_Y_ORG-4
;		mov	bh,HUD_Y_ORG-3
;		mov	al,COL_SIGHT
;		call	VLineDraw

;		mov	cx,HUD_X_ORG-11
;		mov	bl,HUD_Y_ORG+3
;		mov	bh,HUD_Y_ORG+4
;		mov	al,COL_SIGHT
;		call	VLineDraw

;		mov	cx,HUD_X_ORG-10
;		mov	bl,HUD_Y_ORG-5
;		mov	al,COL_SIGHT
;		call	SetPixel

;		mov	cx,HUD_X_ORG-10
;		mov	bl,HUD_Y_ORG+5
;		mov	al,COL_SIGHT
;		call	SetPixel

;		mov	cx,HUD_X_ORG-6
;		mov	bl,HUD_Y_ORG-1
;		mov	bh,HUD_Y_ORG+1
;		mov	al,COL_SIGHT
;		call	VLineDraw

;		mov	cx,HUD_X_ORG-5
;		mov	bl,HUD_Y_ORG-2
;		mov	al,COL_SIGHT
;		call	SetPixel

;		mov	cx,HUD_X_ORG-5
;		mov	bl,HUD_Y_ORG+2
;		mov	al,COL_SIGHT
;		call	SetPixel

;* right stroke

;		mov	cx,HUD_X_ORG+21
;		mov	dx,HUD_X_ORG+7
;		mov	bl,HUD_Y_ORG
;		mov	al,COL_SIGHT
;		call	HLineDraw

;		mov	cx,HUD_X_ORG+22
;		mov	bl,HUD_Y_ORG-2
;		mov	bh,HUD_Y_ORG+2
;		mov	al,COL_SIGHT
;		call	VLineDraw

;		mov	cx,HUD_X_ORG+17
;		mov	bl,HUD_Y_ORG-2
;		mov	bh,HUD_Y_ORG+2
;		mov	al,COL_SIGHT
;		call	VLineDraw

;		mov	cx,HUD_X_ORG+12
;		mov	bl,HUD_Y_ORG-2
;		mov	bh,HUD_Y_ORG+2
;		mov	al,COL_SIGHT
;		call	VLineDraw

;		mov	cx,HUD_X_ORG+11
;		mov	bl,HUD_Y_ORG-4
;		mov	bh,HUD_Y_ORG-3
;		mov	al,COL_SIGHT
;		call	VLineDraw

;		mov	cx,HUD_X_ORG+11
;		mov	bl,HUD_Y_ORG+3
;		mov	bh,HUD_Y_ORG+4
;		mov	al,COL_SIGHT
;		call	VLineDraw

;		mov	cx,HUD_X_ORG+10
;		mov	bl,HUD_Y_ORG-5
;		mov	al,COL_SIGHT
;		call	SetPixel

;		mov	cx,HUD_X_ORG+10
;		mov	bl,HUD_Y_ORG+5
;		mov	al,COL_SIGHT
;		call	SetPixel

;		mov	cx,HUD_X_ORG+6
;		mov	bl,HUD_Y_ORG-1
;		mov	bh,HUD_Y_ORG+1
;		mov	al,COL_SIGHT
;		call	VLineDraw

;		mov	cx,HUD_X_ORG+5
;		mov	bl,HUD_Y_ORG-2
;		mov	al,COL_SIGHT
;		call	SetPixel

;		mov	cx,HUD_X_ORG+5
;		mov	bl,HUD_Y_ORG+2
;		mov	al,COL_SIGHT
;		call	SetPixel

;		ret

;DrawStandby	ENDP




;----------------------------------------------------------------------------

;* FLIRDisp_Ori - forward looking infra-red display
;*
;* pass: si -> TAB data block
;* ret : nothing
;* kill: assume all

FLIRDisp_Ori 	PROC	NEAR
        mov InCockpit,1
		KTEST	KF_NavigViewWithCtrl
		jz	@F	
		KCLEAR	KF_NavigViewWithCtrl
		cmp TAB2.TAB_MODE,TAB_TIALD
		je @F
        add bx, 2 ;Pointer skips to previous TAB display, i.e., TIALD normal-sized view
		jmp	SelectSwitch[bx]
		ret
@@:
		mov	ax,TV3_VIEWMODE	;set viewmode for TAB
		mov	cx,XOrg
		mov	bl,YOrg
		call	SetViewMode

		COPY_VP	TMP_VIEW,M_VIEW

		add	WORD PTR TMP_VIEW.VP_ZFT_LO,8	;add zft displacement
		adc	WORD PTR TMP_VIEW.VP_ZFT_HI,0

		call	DrawIRImage

		mov	ax,NUL_VIEWMODE	;set viewmode for navig view
		call	SetViewMode	
		
		ret

FLIRDisp_Ori	ENDP


;----------------------------------------------------------------------------
;* FLIRDisp_Ori2 - forward looking infra-red display
;*
;* pass: si -> TAB data block
;* ret : nothing
;* kill: assume all

FLIRDisp_Ori2 	PROC	NEAR
        mov InCockpit,1
		KTEST	KF_NavigViewWithCtrl
		jz	@F	
		KCLEAR	KF_NavigViewWithCtrl
		cmp TAB2.TAB_MODE,TAB_TIALD
		je @F
        add bx, 2 ;Pointer skips to previous TAB display, i.e., TIALD normal-sized view
		jmp	SelectSwitch[bx]
		ret
@@:
		mov	ax,TV3_VIEWMODE	;set viewmode for TAB
		mov	cx,XOrg
		mov	bl,YOrg
		call	SetViewMode

		COPY_VP	TMP_VIEW,M_VIEW
        ;mov	TMP_VIEW.VP_ROLL,0 ;Added by Frankie Kam on 30/7/2018 to inhibit roll
		add	WORD PTR TMP_VIEW.VP_ZFT_LO,32	;add zft displacement ; 8
		adc	WORD PTR TMP_VIEW.VP_ZFT_HI,0
		
		call	DrawIRImage

		mov	ax,EXT_VIEWMODE	;set viewmode for navig view
		call	SetViewMode	
		
		ret

FLIRDisp_Ori2	ENDP


;----------------------------------------------------------------------------
;* FLIRDisp_Ori3 - forward looking infra-red display
;*
;* pass: si -> TAB data block
;* ret : nothing
;* kill: assume all

FLIRDisp_Ori3 	PROC	NEAR
        mov InCockpit,1
		KTEST	KF_NavigViewWithCtrl
		jz	@F	
		KCLEAR	KF_NavigViewWithCtrl
		cmp TAB2.TAB_MODE,TAB_TIALD
		je @F
        add bx, 2 ;Pointer skips to previous TAB display, i.e., TIALD normal-sized view
		jmp	SelectSwitch[bx]
		ret
@@:
		mov	ax,INT_VIEWMODE	;set viewmode for TAB
		mov	cx,XOrg
		mov	bl,YOrg
		call	SetViewMode

		COPY_VP	TMP_VIEW,M_VIEW
        ;mov	TMP_VIEW.VP_ROLL,0 ;Added by Frankie Kam on 30/7/2018 to inhibit roll
		add	WORD PTR TMP_VIEW.VP_ZFT_LO,40	;add zft displacement ; 8 ;190
		adc	WORD PTR TMP_VIEW.VP_ZFT_HI,0
		
	    call	DrawIRImage

		mov	ax,NUL_VIEWMODE	;set viewmode for navig view EXT_VIEWMODE
		call	SetViewMode	
		
		;HUD Damaged?
        cmp SSF_HUD,1	
		je	@F
		call UpdateHUD
@@:	
		
		ret
        
FLIRDisp_Ori3	ENDP


;----------------------------------------------------------------------------
;* FLIRDisp_Ori4 - forward looking infra-red display
;*
;* pass: si -> TAB data block
;* ret : nothing
;* kill: assume all

FLIRDisp_Ori4 	PROC	NEAR
        mov InCockpit,1
		KTEST	KF_NavigViewWithCtrl
		jz	@F	
		KCLEAR	KF_NavigViewWithCtrl
		cmp TAB2.TAB_MODE,TAB_TIALD
		je @F
        add bx, 2 ;Pointer skips to previous TAB display, i.e., TIALD normal-sized view
		jmp	SelectSwitch[bx]
		ret
@@:
		mov	ax,EXT_VIEWMODE	;set viewmode for TAB
		mov	cx,XOrg
		mov	bl,YOrg
		call	SetViewMode
		
		COPY_VP	TMP_VIEW,M_VIEW
        ;mov	TMP_VIEW.VP_ROLL,0 ;Added by Frankie Kam on 30/7/2018 to inhibit roll
		add	WORD PTR TMP_VIEW.VP_ZFT_LO,8	;add zft displacement ; 8
		adc	WORD PTR TMP_VIEW.VP_ZFT_HI,0
		
		call	DrawIRImage

		mov	ax,EXT_VIEWMODE	;set viewmode for navig view
		call	SetViewMode	

		;HUD Damaged?
        cmp SSF_HUD,1	
		je	@F
		call UpdateHUD2
@@:	
		;call DrawStandby2
		;mov	si,OFFSET Cannon2$
		;call	Print$		
		
		ret

FLIRDisp_Ori4	ENDP


;----------------------------------------------------------------------------

;* TIALDDisp_Ori - thermal image and laser designation display
;*
;* pass: si -> TAB data block
;* ret : nothing
;* kill: assume all
;*
;* note: How to use TIALD (mouse control only):-
;*
;*       Use mouse x, y motion to steer TIALD.
;*
;*	 Click lh mouse button to designate a target (hold and drag to adjust).
;*	 Click rh mouse button to cancel designation.
;*
;*	 Use CTRL key to zoom (continuous zoom):-
;*
;*	    CTRL key and move mouse forward to zoom in.
;*	    CTRL key and move mouse backward to zoom out.
;*
;* 	 Zoom still functions after designation.
;*
;* 	 Scan area is related to altitude. The cursor blinks when it is being
;*	 dragged along the scan edge.
;*
;*	 It is not possible to designate outside of the active map area.

TIALDDisp_Ori	PROC	NEAR
        mov InCockpit,1
		KTEST	KF_NavigViewWithCtrl
		jz	@F
		KCLEAR	KF_NavigViewWithCtrl
		cmp TAB2.TAB_MODE,TAB_FLIR
		je @F
        add bx, 2 ;Pointer skips to next TAB display, i.e., TIALD full-sized view
		jmp	SelectSwitch[bx]
		ret
@@:				
;----------------------------
;* check operating conditions
;----------------------------
		;cmp	TAB2.TAB_MODE,TAB_FLIR_ORI
	    ;je @F
		cmp	M_CosP,16384	;pitch in limits (+/-60degs)?
		jl	@F		;no ->

		cmp	M_CosR,16384	;roll in limits (+/-60degs)?
		jl	@F		;no ->
		cmp	TrueRadAlt,MIN_OP_RAD_ALT	;rad alt ok?
		jae	TIALDOk_Ori				;no ->

@@:		mov	TDMode,TIALD_INIT

		call	InvalidDisp_Ori
		jmp	TIALDExit_Ori

;---------------
;* init viewmode
;---------------

TIALDOk_Ori:	mov	ax,TV3_VIEWMODE
		mov	cx,XOrg
		mov	bl,YOrg
		call	SetViewMode

;----------------------------
;* store visual configuration
;----------------------------

		push	WORD PTR GradEnabled
		push	WORD PTR StarsEnabled
		push	WORD PTR CloudsEnabled
		push	WORD PTR HillTextEnabled

		push	SecScanCnt1
		push	SecScanOff1
		push	SecScanCnt2
		push	SecScanOff2

;-----------------------------
;* modify visual configuration
;-----------------------------

;* if night or foggy use IR visual colours

		cmp	Night,1		;Dusk (still light enough to see)?
		je	SkipIRCols_Ori	;no ->

		cmp	Night,0		;night?
		jne	@F		;yes ->

		cmp	Fog,0		;foggy?
		je	SkipIRCols_Ori	;no ->

@@:		;call CheckForNVG
        ;call	SetIRPalette
		;mov	StarsEnabled,0

SkipIRCols_Ori:	mov	GradEnabled,0
		mov	CloudsEnabled,0
		mov	HillTextEnabled,0

		mov	SecScanCnt1,5		;minimize range
		mov	SecScanOff1,-2
		mov	SecScanCnt2,5
		mov	SecScanOff2,-2

;----------------------
;* calc TIALD scan size
;----------------------

		call	CalcScanSize

;-----------------
;* clear drag flag
;-----------------

		mov	TDDrag,0

;------------------
;* read mouse input
;------------------

		cmp	DisableInput,0	;input disabled?
		jne	@F		;yes ->

		mov	si,TABPtr
		test	[si].TAB_HAS_MOUSE,1	;mouse available?
		jnz	ReadTIALDMouse_Ori		;yes ->

;* null input from mouse

@@:		xor	ax,ax
		xor	bx,bx
		xor	cx,cx
		xor	dx,dx

		mov	XMickeys,cx
		mov	YMickeys,bx

		mov	TDZoomKey,0

		jmp	SortTDMode_Ori

ReadTIALDMouse_Ori:	mov	al,Key[K_CTRL]	;update zoom override flag
		mov	TDZoomKey,al

		call	ReadMouseMotion

;* note: al = 1 = lhs button pressed
;*       ah = 1 = rhs button pressed
;*       cx = XMickeys (-32768 .. 32767)
;*       bx = YMickeys (-32768 .. 32767)
;*       dl = 1 = lhs button just pressed
;*       dh = 1 = rhs button just pressed

;-------------
;* select mode
;-------------

SortTDMode_Ori:	mov	bx,TDMode
		jmp	TDSwitch_Ori[bx]

;---------------------------
TIALDInit_Ori	LABEL	NEAR
;---------------------------

;* init mode ensures start up into search mode regardless of mouse input

		call	SetDatum

		mov	TDMode,TIALD_SEARCH

		jmp	IntoSearch_Ori

;---------------------------
TIALDSearch_Ori	LABEL	NEAR
;---------------------------

;* cancel lock?

		test	dh,dh		;rh button just pressed?
		jz	@F		;no ->

		push	dx
		call	CancelTgtWP
		pop	dx

;* switch to adjust lock mode?

@@:		test	dl,dl		;lh button just pressed?
		jz	@F		;no ->

		call	SetTarget
		jc	@F		;target invalid ->

		mov	TDMode,TIALD_ADJ_LOCK

		jmp	IntoAdjustLock_Ori

;* switch to zoom mode?

@@:		test	TDZoomKey,1	;CTRL key pressed?
		jz	IntoSearch_Ori	;no ->

		mov	TDMode,TIALD_ZOOM

		jmp	IntoZoom_Ori

;* search within viewing window

IntoSearch_Ori:	call	SetDatum

		call	AdjustXYOffsets

		call	RotateXYOffsets

		jmp	ContVisual_Ori

;---------------------------
TIALDZoom_Ori	LABEL	NEAR
;---------------------------

;* cancel lock?

		test	dh,dh		;rh button just pressed?
		jz	@F		;no ->

		push	dx
		call	CancelTgtWP
		pop	dx

;* switch to adjust lock mode?

@@:		test	dl,dl		;lh button just pressed?
		jz	@F		;no ->

		call	SetTarget
		jc	@F		;target invalid ->

		mov	TDMode,TIALD_ADJ_LOCK

		jmp	IntoAdjustLock_Ori

;* switch to search mode?

@@:		test	TDZoomKey,1	;CTRL key released?
		jnz	IntoZoom_Ori	;no ->

		call	RecalcXYOffsets

		call	SetDatum

		mov	TDMode,TIALD_SEARCH

		jmp	IntoSearch_Ori

;* adjust zoom

IntoZoom_Ori:	call	AdjustZoom

		call	RecalcXYOffsets

		test	TDDrag,1	;drag point?
		jz	@F		;no ->

		call	SetDatum

		call	RotateXYOffsets

@@:		jmp	ContVisual_Ori

;---------------------------
TIALDAdjustLock_Ori	LABEL	NEAR
;---------------------------

;* cancel lock?

		test	dh,dh		;rh button just pressed?
		jz	@F		;no ->

		call	CancelTgtWP

		call	RecalcXYOffsets

		call	SetDatum

		mov	TDMode,TIALD_SEARCH

		jmp	IntoSearch_Ori

;* switch to target lock mode?

@@:		test	al,al		;lh button released?
		jnz	IntoAdjustLock_Ori	;no ->

		mov	TDMode,TIALD_TGT_LOCK

		jmp	IntoTargetLock_Ori

IntoAdjustLock_Ori:	call	AdjustLock

		call	RecalcXYOffsets

		test	TDDrag,1	;drag point?
		jz	@F		;no ->

		call	SetDatum

		call	RotateXYOffsets

@@:		call	SetTarget
		jnc	ContVisual_Ori	;target valid ->

		call	RecalcXYOffsets

		call	SetDatum

		mov	TDMode,TIALD_SEARCH

		jmp	IntoSearch_Ori

;---------------------------
TIALDTargetLock_Ori	LABEL	NEAR
;---------------------------

;* has target moved (or cancelled) externally?

		call	TargetMoved	;moved (or cancelled)?
		jc	CancelLock_Ori	;yes ->

;* cancel target designation (switch to search mode)?

		test	dh,dh		;rh button just pressed?
		jz	@F		;no ->

		call	CancelTgtWP

CancelLock_Ori:	call	RecalcXYOffsets

		call	SetDatum

		mov	TDMode,TIALD_SEARCH

		jmp	IntoSearch_Ori

;* return to adjust lock mode?

@@:		test	dl,dl		;lh button just pressed?
		jz	@F		;no ->

		mov	TDMode,TIALD_ADJ_LOCK

		jmp	IntoAdjustLock_Ori

;* adjust zoom?

@@:	 	test	TDZoomKey,1	;CTRL key pressed?
		jz	IntoTargetLock_Ori	;no ->

		call	AdjustZoom

IntoTargetLock_Ori:	call	RecalcXYOffsets

		test	TDDrag,1	;within scan limits?
		jz	ContVisual_Ori	;yes ->

		call	SetDatum

		mov	TDMode,TIALD_SEARCH

		jmp	IntoSearch_Ori

;---------------------------
ContVisual_Ori	LABEL	NEAR
;---------------------------

;* vp alt = max(TDScanSize * TDZoom / 256, gnd ht + MIN_OP_RAD_ALT)

		mov	ax,TDScanSize
		mov	dx,TDZoom
		mul	dx

		mov	dh,al		;store 1/2 bit
		mov	al,ah		;/256
		mov	ah,dl
		shl	dh,1		;expose 1/2 bit
		ROUNDUP	ax

		push	ax

		mov	si,OFFSET TIALD_VIEW
		call	CalcGndHeight

		add	ax,MIN_OP_RAD_ALT

		pop	bx

		cmp	bx,ax		;vp alt >= gnd ht + MIN_OP_RAD_ALT?
		jae	@F		;yes ->

		mov	bx,ax

@@:		xor	cx,cx

;* if overcast then
;*    if ac alt >= cloudbase then
;*       if vp alt < cloudbase then
;*          vp alt = cloudbase
;*       endif
;*    endif
;* endif

		test	Overcast,1	;overcast?
		jz	SetVPAlt_Ori	;no ->

		mov	ax,WORD PTR M_VIEW.VP_ZFT_LO
		mov	dx,WORD PTR M_VIEW.VP_ZFT_HI
		sub	ax,WORD PTR CloudBase
		sbb	dx,WORD PTR CloudBase+2
		jb	SetVPAlt_Ori	;ac alt < cloudbase ->

		mov	ax,bx
		mov	dx,cx
		sub	ax,WORD PTR CloudBase
		sbb	dx,WORD PTR CloudBase+2
		jae	SetVPAlt_Ori	;vp alt > cloudbase ->

		mov	bx,WORD PTR CloudBase
		mov	cx,WORD PTR CloudBase+2

SetVPAlt_Ori:	mov	WORD PTR TIALD_VIEW.VP_ZFT_HI,cx
		mov	WORD PTR TIALD_VIEW.VP_ZFT_LO,bx

;-------------------
;* draw TIALD visual
;-------------------

;* keep TIALD hdg in line with aircraft hdg (even if zoom or lock)

		mov	ax,M_VIEW.VP_HDG
		mov	TIALD_VIEW.VP_HDG,ax

;* pitched down, no roll

		mov	TIALD_VIEW.VP_PITCH,400 ;384           ;hacked by Frankie on 8th July 2018
		;mov	TIALD_VIEW.VP_ROLL,0               ;hacked by Frankie on 8th July 2018
		
		mov	si,OFFSET TIALD_VIEW
		call	Visual

;----------------
;* draw symbology
;----------------

;* update blink timer

		mov	ax,TDBlinkTimer
		sub	ax,LastFrame
		mov	TDBlinkTimer,ax
		jnc	@F

		mov	TDBlinkTimer,TD_BLINK_RATE

		xor	TDBlink,1	;toggle blink flag

;* if "dragging" then switch cross off for blink period

		mov	TDCross,1	;assume cross on

		jnz	@F		;0 .. 1 (leading edge) ->

		test	TDDrag,1	;dragging?
		jz	@F		;no ->

		mov	TDCross,0	;cross off

;* draw symbology wrt mode

@@:		mov	bx,TDMode
		jmp	TDSymbolSwitch_Ori[bx]

;---------------------------
TDSymZoom_Ori	LABEL	NEAR
;---------------------------

		call	DrawLaserSymbol_Ori

		jmp	TDSymOk_Ori

;---------------------------
TDSymAdjustLock_Ori	LABEL	NEAR
;---------------------------

		call	DrawLaserSymbol_Ori

;* blink track symbol

		test	TDBLink,1
		jz	@F

		call	DrawTrackSymbol_Ori

@@:		jmp	TDSymOk_Ori

;---------------------------
TDSymTargetLock_Ori	LABEL	NEAR
;---------------------------

;* blink laser symbol

		test	TDBLink,1
		jz	@F

		call	DrawLaserSymbol_Ori

@@:		call	DrawTrackSymbol_Ori

;---------------------------
TDSymOk_Ori		LABEL	NEAR
;---------------------------

		call	DrawCrossSymbol_Ori

;------------------------------
;* restore visual configuration
;------------------------------

		pop	SecScanOff2
		pop	SecScanCnt2
		pop	SecScanOff1
		pop	SecScanCnt1

		pop	WORD PTR HillTextEnabled
		pop	WORD PTR CloudsEnabled
		pop	WORD PTR StarsEnabled
		pop	WORD PTR GradEnabled

;* if night or foggy restore visual colours

		cmp	Night,0		;night?
		jne	@F		;yes ->

		cmp	Fog,0		;foggy?
		je	SkipFixCols_Ori	;no ->

@@:		;call CheckForNVG
        ;call	FixIRPalette

;------------------
;* restore viewmode
;------------------

SkipFixCols_Ori:	mov	ax,NUL_VIEWMODE
		call	SetViewMode	

;--------------------
;* update TIALD flags
;--------------------

TIALDExit_Ori:	mov	al,1		;assume active

		cmp	TDMode,TIALD_ADJ_LOCK
		je	@F		
		cmp	TDMode,TIALD_TGT_LOCK
		je	@F		

		xor	al,al		;inactive

@@:		mov	LaserActive,al

		mov	TIALDActive,1
		
		ret

TIALDDisp_Ori	ENDP



TIALDDisp_Ori2	PROC	NEAR
        mov InCockpit,1
		KTEST	KF_NavigViewWithCtrl
		jz	@F
		KCLEAR	KF_NavigViewWithCtrl
		cmp TAB2.TAB_MODE,TAB_FLIR
		je @F
        add bx, 2 ;Pointer skips to next TAB display, i.e., TIALD full-sized view
		jmp	SelectSwitch[bx]
		ret
@@:				
;----------------------------
;* check operating conditions
;----------------------------
		;cmp	TAB2.TAB_MODE,TAB_FLIR_ORI
	    ;je @F
		cmp	M_CosP,16384	;pitch in limits (+/-60degs)?
		jl	@F		;no ->

		cmp	M_CosR,16384	;roll in limits (+/-60degs)?
		jl	@F		;no ->
		cmp	TrueRadAlt,MIN_OP_RAD_ALT	;rad alt ok?
		jae	TIALDOk_Ori2				;no ->

@@:		mov	TDMode,TIALD_INIT

		call	InvalidDisp_Ori
		jmp	TIALDExit_Ori2

;---------------
;* init viewmode
;---------------

TIALDOk_Ori2:	mov	ax,TV3_VIEWMODE
		mov	cx,XOrg
		mov	bl,YOrg
		call	SetViewMode

;----------------------------
;* store visual configuration
;----------------------------

		push	WORD PTR GradEnabled
		push	WORD PTR StarsEnabled
		push	WORD PTR CloudsEnabled
		push	WORD PTR HillTextEnabled

		push	SecScanCnt1
		push	SecScanOff1
		push	SecScanCnt2
		push	SecScanOff2

;-----------------------------
;* modify visual configuration
;-----------------------------

;* if night or foggy use IR visual colours

		cmp	Night,1		;Dusk (still light enough to see)?
		je	SkipIRCols_Ori2	;no ->

		cmp	Night,0		;night?
		jne	@F		;yes ->

		cmp	Fog,0		;foggy?
		je	SkipIRCols_Ori2	;no ->

@@:		;call CheckForNVG
        ;call	SetIRPalette
		;mov	StarsEnabled,0

SkipIRCols_Ori2:	mov	GradEnabled,0
		mov	CloudsEnabled,0
		mov	HillTextEnabled,0

		mov	SecScanCnt1,5		;minimize range
		mov	SecScanOff1,-2
		mov	SecScanCnt2,5
		mov	SecScanOff2,-2

;----------------------
;* calc TIALD scan size
;----------------------

		call	CalcScanSize

;-----------------
;* clear drag flag
;-----------------

		mov	TDDrag,0

;------------------
;* read mouse input
;------------------
	
		cmp	DisableInput,0	;input disabled?
		jne	@F		;yes ->

		mov	si,TABPtr
		;test	[si].TAB_HAS_MOUSE,1	;mouse available?
		;jnz	ReadTIALDMouse_Ori2		;yes ->
        jmp ReadTIALDMouse_Ori2		;yes ->
;* null input from mouse

@@:		xor	ax,ax
		xor	bx,bx
		xor	cx,cx
		xor	dx,dx

		mov	XMickeys,cx
		mov	YMickeys,bx

		mov	TDZoomKey,0

		jmp	SortTDMode_Ori2

ReadTIALDMouse_Ori2:	mov	al,Key[K_CTRL]	;update zoom override flag
		mov	TDZoomKey,al

		call	ReadMouseMotion

;* note: al = 1 = lhs button pressed
;*       ah = 1 = rhs button pressed
;*       cx = XMickeys (-32768 .. 32767)
;*       bx = YMickeys (-32768 .. 32767)
;*       dl = 1 = lhs button just pressed
;*       dh = 1 = rhs button just pressed

;-------------
;* select mode
;-------------

SortTDMode_Ori2:	mov	bx,TDMode
		jmp	TDSwitch_Ori2[bx]

;---------------------------
TIALDInit_Ori2	LABEL	NEAR
;---------------------------

;* init mode ensures start up into search mode regardless of mouse input

		call	SetDatum

		mov	TDMode,TIALD_SEARCH

		jmp	IntoSearch_Ori2

;---------------------------
TIALDSearch_Ori2	LABEL	NEAR
;---------------------------

;* cancel lock?

		test	dh,dh		;rh button just pressed?
		jz	@F		;no ->

		push	dx
		call	CancelTgtWP
		pop	dx

;* switch to adjust lock mode?

@@:		test	dl,dl		;lh button just pressed?
		jz	@F		;no ->

		call	SetTarget
		jc	@F		;target invalid ->

		mov	TDMode,TIALD_ADJ_LOCK

		jmp	IntoAdjustLock_Ori2

;* switch to zoom mode?

@@:		test	TDZoomKey,1	;CTRL key pressed?
		jz	IntoSearch_Ori2	;no ->

		mov	TDMode,TIALD_ZOOM

		jmp	IntoZoom_Ori2

;* search within viewing window

IntoSearch_Ori2:	call	SetDatum

		call	AdjustXYOffsets

		call	RotateXYOffsets

		jmp	ContVisual_Ori2

;---------------------------
TIALDZoom_Ori2	LABEL	NEAR
;---------------------------

;* cancel lock?

		test	dh,dh		;rh button just pressed?
		jz	@F		;no ->

		push	dx
		call	CancelTgtWP
		pop	dx

;* switch to adjust lock mode?

@@:		test	dl,dl		;lh button just pressed?
		jz	@F		;no ->

		call	SetTarget
		jc	@F		;target invalid ->

		mov	TDMode,TIALD_ADJ_LOCK

		jmp	IntoAdjustLock_Ori2

;* switch to search mode?

@@:		test	TDZoomKey,1	;CTRL key released?
		jnz	IntoZoom_Ori2	;no ->

		call	RecalcXYOffsets

		call	SetDatum

		mov	TDMode,TIALD_SEARCH

		jmp	IntoSearch_Ori2

;* adjust zoom

IntoZoom_Ori2:	call	AdjustZoom

		call	RecalcXYOffsets

		test	TDDrag,1	;drag point?
		jz	@F		;no ->

		call	SetDatum

		call	RotateXYOffsets

@@:		jmp	ContVisual_Ori2

;---------------------------
TIALDAdjustLock_Ori2	LABEL	NEAR
;---------------------------

;* cancel lock?

		test	dh,dh		;rh button just pressed?
		jz	@F		;no ->

		call	CancelTgtWP

		call	RecalcXYOffsets

		call	SetDatum

		mov	TDMode,TIALD_SEARCH

		jmp	IntoSearch_Ori2

;* switch to target lock mode?

@@:		test	al,al		;lh button released?
		jnz	IntoAdjustLock_Ori2	;no ->

		mov	TDMode,TIALD_TGT_LOCK

		jmp	IntoTargetLock_Ori2

IntoAdjustLock_Ori2:	call	AdjustLock

		call	RecalcXYOffsets

		test	TDDrag,1	;drag point?
		jz	@F		;no ->

		call	SetDatum

		call	RotateXYOffsets

@@:		call	SetTarget
		jnc	ContVisual_Ori2	;target valid ->

		call	RecalcXYOffsets

		call	SetDatum

		mov	TDMode,TIALD_SEARCH

		jmp	IntoSearch_Ori2

;---------------------------
TIALDTargetLock_Ori2	LABEL	NEAR
;---------------------------

;* has target moved (or cancelled) externally?

		call	TargetMoved	;moved (or cancelled)?
		jc	CancelLock_Ori2	;yes ->

;* cancel target designation (switch to search mode)?

		test	dh,dh		;rh button just pressed?
		jz	@F		;no ->

		call	CancelTgtWP

CancelLock_Ori2:	call	RecalcXYOffsets

		call	SetDatum

		mov	TDMode,TIALD_SEARCH

		jmp	IntoSearch_Ori2

;* return to adjust lock mode?

@@:		test	dl,dl		;lh button just pressed?
		jz	@F		;no ->

		mov	TDMode,TIALD_ADJ_LOCK

		jmp	IntoAdjustLock_Ori2

;* adjust zoom?

@@:	 	test	TDZoomKey,1	;CTRL key pressed?
		jz	IntoTargetLock_Ori2	;no ->

		call	AdjustZoom

IntoTargetLock_Ori2:	call	RecalcXYOffsets

		test	TDDrag,1	;within scan limits?
		jz	ContVisual_Ori2	;yes ->

		call	SetDatum

		mov	TDMode,TIALD_SEARCH

		jmp	IntoSearch_Ori2

;---------------------------
ContVisual_Ori2	LABEL	NEAR
;---------------------------

;* vp alt = max(TDScanSize * TDZoom / 256, gnd ht + MIN_OP_RAD_ALT)

		mov	ax,TDScanSize
		mov	dx,TDZoom
		mul	dx

		mov	dh,al		;store 1/2 bit
		mov	al,ah		;/256
		mov	ah,dl
		shl	dh,1		;expose 1/2 bit
		ROUNDUP	ax

		push	ax

		mov	si,OFFSET TIALD_VIEW
		call	CalcGndHeight

		add	ax,MIN_OP_RAD_ALT

		pop	bx

		cmp	bx,ax		;vp alt >= gnd ht + MIN_OP_RAD_ALT?
		jae	@F		;yes ->

		mov	bx,ax

@@:		xor	cx,cx

;* if overcast then
;*    if ac alt >= cloudbase then
;*       if vp alt < cloudbase then
;*          vp alt = cloudbase
;*       endif
;*    endif
;* endif

		test	Overcast,1	;overcast?
		jz	SetVPAlt_Ori2	;no ->

		mov	ax,WORD PTR M_VIEW.VP_ZFT_LO
		mov	dx,WORD PTR M_VIEW.VP_ZFT_HI
		sub	ax,WORD PTR CloudBase
		sbb	dx,WORD PTR CloudBase+2
		jb	SetVPAlt_Ori2	;ac alt < cloudbase ->

		mov	ax,bx
		mov	dx,cx
		sub	ax,WORD PTR CloudBase
		sbb	dx,WORD PTR CloudBase+2
		jae	SetVPAlt_Ori2	;vp alt > cloudbase ->

		mov	bx,WORD PTR CloudBase
		mov	cx,WORD PTR CloudBase+2

SetVPAlt_Ori2:	mov	WORD PTR TIALD_VIEW.VP_ZFT_HI,cx
		mov	WORD PTR TIALD_VIEW.VP_ZFT_LO,bx

;-------------------
;* draw TIALD visual
;-------------------

;* keep TIALD hdg in line with aircraft hdg (even if zoom or lock)

		mov	ax,M_VIEW.VP_HDG
		mov	TIALD_VIEW.VP_HDG,ax

;* pitched down, no roll

		mov	TIALD_VIEW.VP_PITCH,400 ;384           ;hacked by Frankie on 8th July 2018
		;mov	TIALD_VIEW.VP_ROLL,0               ;hacked by Frankie on 8th July 2018
		
		mov	si,OFFSET TIALD_VIEW
		call	Visual

;----------------
;* draw symbology
;----------------

;* update blink timer

		mov	ax,TDBlinkTimer
		sub	ax,LastFrame
		mov	TDBlinkTimer,ax
		jnc	@F

		mov	TDBlinkTimer,TD_BLINK_RATE

		xor	TDBlink,1	;toggle blink flag

;* if "dragging" then switch cross off for blink period

		mov	TDCross,1	;assume cross on

		jnz	@F		;0 .. 1 (leading edge) ->

		test	TDDrag,1	;dragging?
		jz	@F		;no ->

		mov	TDCross,0	;cross off

;* draw symbology wrt mode

@@:		mov	bx,TDMode
		jmp	TDSymbolSwitch_Ori2[bx]

;---------------------------
TDSymZoom_Ori2	LABEL	NEAR
;---------------------------

		call	DrawLaserSymbol_Ori

		jmp	TDSymOk_Ori2

;---------------------------
TDSymAdjustLock_Ori2	LABEL	NEAR
;---------------------------

		call	DrawLaserSymbol_Ori

;* blink track symbol

		test	TDBLink,1
		jz	@F

		call	DrawTrackSymbol_Ori

@@:		jmp	TDSymOk_Ori2

;---------------------------
TDSymTargetLock_Ori2	LABEL	NEAR
;---------------------------

;* blink laser symbol

		test	TDBLink,1
		jz	@F

		call	DrawLaserSymbol_Ori

@@:		call	DrawTrackSymbol_Ori

;---------------------------
TDSymOk_Ori2		LABEL	NEAR
;---------------------------

		call	DrawCrossSymbol_Ori

;------------------------------
;* restore visual configuration
;------------------------------

		pop	SecScanOff2
		pop	SecScanCnt2
		pop	SecScanOff1
		pop	SecScanCnt1

		pop	WORD PTR HillTextEnabled
		pop	WORD PTR CloudsEnabled
		pop	WORD PTR StarsEnabled
		pop	WORD PTR GradEnabled

;* if night or foggy restore visual colours

		cmp	Night,0		;night?
		jne	@F		;yes ->

		cmp	Fog,0		;foggy?
		je	SkipFixCols_Ori2	;no ->

@@:		;call CheckForNVG
        ;call	FixIRPalette

;------------------
;* restore viewmode
;------------------

SkipFixCols_Ori2:	;mov	ax,NUL_VIEWMODE
       mov	ax,EXT_VIEWMODE
		call	SetViewMode	

;--------------------
;* update TIALD flags
;--------------------

TIALDExit_Ori2:	mov	al,1		;assume active

		cmp	TDMode,TIALD_ADJ_LOCK
		je	@F		
		cmp	TDMode,TIALD_TGT_LOCK
		je	@F		

		xor	al,al		;inactive

@@:		mov	LaserActive,al

		mov	TIALDActive,1
		
		ret

TIALDDisp_Ori2	ENDP

;----------------------------------------------------------------------------

;* DrawCrossSymbol_Ori
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

DrawCrossSymbol_Ori	PROC	NEAR

;* blink cross if "dragging"

		test	TDCross,1
		_JZ	SkipCross

		mov	bl,YOrg
		add	bl,YC
		mov	cx,XOrg
		mov	dx,cx
		add	cx,XC-4
		add	dx,XC-2
		mov	al,COL_HUD
		call	HLineDraw
	
		mov	bl,YOrg
		add	bl,YC
		mov	cx,XOrg
		mov	dx,cx
		add	cx,XC+2
		add	dx,XC+4
		mov	al,COL_HUD
		call	HLineDraw
	
		mov	bl,YOrg
		mov	bh,bl
		add	bl,YC-4
		add	bh,YC-2
		mov	cx,XOrg
		add	cx,XC
		mov	al,COL_HUD
		call	VLineDraw
	
		mov	bl,YOrg
		mov	bh,bl
		add	bl,YC+2
		add	bh,YC+4
		mov	cx,XOrg
		add	cx,XC
		mov	al,COL_HUD
		call	VLineDraw

		cmp	TDYOffset,0	;laser ahead of aircraft?
		_JL	SkipCross	;no ->

		mov	bl,YOrg
		add	bl,YC-3
		mov	cx,XOrg
		add	cx,XC-4
		mov	al,COL_HUD
		call	SetPixel

		mov	bl,YOrg
		add	bl,YC-4
		mov	cx,XOrg
		add	cx,XC-4
		mov	al,COL_HUD
		call	SetPixel

		mov	bl,YOrg
		add	bl,YC-4
		mov	cx,XOrg
		add	cx,XC-3
		mov	al,COL_HUD
		call	SetPixel
	
		mov	bl,YOrg
		add	bl,YC-4
		mov	cx,XOrg
		add	cx,XC+3
		mov	al,COL_HUD
		call	SetPixel

		mov	bl,YOrg
		add	bl,YC-4
		mov	cx,XOrg
		add	cx,XC+4
		mov	al,COL_HUD
		call	SetPixel

		mov	bl,YOrg
		add	bl,YC-3
		mov	cx,XOrg
		add	cx,XC+4
		mov	al,COL_HUD
		call	SetPixel

		mov	bl,YOrg
		add	bl,YC+3
		mov	cx,XOrg
		add	cx,XC+4
		mov	al,COL_HUD
		call	SetPixel

		mov	bl,YOrg
		add	bl,YC+4
		mov	cx,XOrg
		add	cx,XC+4
		mov	al,COL_HUD
		call	SetPixel

		mov	bl,YOrg
		add	bl,YC+4
		mov	cx,XOrg
		add	cx,XC+3
		mov	al,COL_HUD
		call	SetPixel

		mov	bl,YOrg
		add	bl,YC+4
		mov	cx,XOrg
		add	cx,XC-3
		mov	al,COL_HUD
		call	SetPixel

		mov	bl,YOrg
		add	bl,YC+4
		mov	cx,XOrg
		add	cx,XC-4
		mov	al,COL_HUD
		call	SetPixel

		mov	bl,YOrg
		add	bl,YC+3
		mov	cx,XOrg
		add	cx,XC-4
		mov	al,COL_HUD
		call	SetPixel

SkipCross_Ori:	ret

DrawCrossSymbol_Ori	ENDP

;----------------------------------------------------------------------------

;* DrawLaserSymbol_Ori
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

DrawLaserSymbol_Ori	PROC	NEAR

		mov	bl,YOrg
		mov	bh,bl
		add	bl,YC-2  ;Add 4 to YC by Frankie on 8th July 2018
		add	bh,YC+1  ;Add 4 to YC by Frankie on 8th July 2018
		mov	cx,XOrg
		add	cx,XC+6    ;Add 4 to YC by Frankie on 8th July 2018
		mov	al,COL_HUD
		call	VLineDraw

		mov	bl,YOrg
		add	bl,YC+2
		mov	cx,XOrg
		mov	dx,cx
		add	cx,XC+6
		add	dx,XC+8
		mov	al,COL_HUD
		call	HLineDraw
	
		ret

DrawLaserSymbol_Ori	ENDP

;----------------------------------------------------------------------------

;* DrawTrackSymbol
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

DrawTrackSymbol_Ori	PROC	NEAR

		mov	bl,YOrg
		mov	bh,bl
		add	bl,YC-1  ;Add 4 to YC by Frankie on 8th July 2018
		add	bh,YC+2  ;Add 4 to YC by Frankie on 8th July 2018
		mov	cx,XOrg
		add	cx,XC-7
		mov	al,COL_HUD
		call	VLineDraw

		mov	bl,YOrg
		add	bl,YC-2  ;Add 4 to YC by Frankie on 8th July 2018
		mov	cx,XOrg
		mov	dx,cx
		add	cx,XC-8
		add	dx,XC-6
		mov	al,COL_HUD
		call	HLineDraw
	
		ret

DrawTrackSymbol_Ori	ENDP

;----------------------------------------------------------------------------

;* InvalidDisp_Ori - draw large 'X' in centre of TAB display
;*
;* pass: si -> TAB data block
;* ret : nothing
;* kill: assume all (except si)

InvalidDisp_Ori	PROC	NEAR

		call	ClearDisp

		mov	bl,TAB_Y_ORG[si]
		mov	bh,bl 
		add	bl,YC-25  ;Add 4 to YC by Frankie on 8th July 2018
		add	bh,YC+25  ;Add 4 to YC by Frankie on 8th July 2018
		mov	cx,TAB_X_ORG[si]
		mov	dx,cx
		add	cx,XC-25
		add	dx,XC+25
		mov	al,COL_CRT8

		push	si
		call	LineDraw
		pop	si

		mov	bl,TAB_Y_ORG[si]
		mov	bh,bl
		add	bl,YC-25   ;Add 4 to YC by Frankie on 8th July 2018
		add	bh,YC+25   ;Add 4 to YC by Frankie on 8th July 2018
		mov	cx,TAB_X_ORG[si]
		mov	dx,cx
		add	cx,XC+25
		add	dx,XC-25
		mov	al,COL_CRT8

		push	si
		call	LineDraw
		pop	si

		ret

InvalidDisp_Ori	ENDP

DrawStandby	PROC	NEAR
		
		;mov	si,OFFSET SetUp$
		;call	Print$
		
		mov	si,OFFSET SetUp$
		call	Print$
		
;* centre dot

		mov	cx,HUD_X_ORG
		mov	bl,HUD_Y_ORG-48
		mov	al,COL_SIGHT
		call	SetPixel

;* up stroke

		mov	cx,HUD_X_ORG
		mov	bl,HUD_Y_ORG-48-17
		mov	bh,HUD_Y_ORG-48-6
		mov	al,COL_SIGHT
		call	VLineDraw

		mov	cx,HUD_X_ORG-2
		mov	dx,HUD_X_ORG+2
		mov	bl,HUD_Y_ORG-48-18
		mov	al,COL_SIGHT
		call	HLineDraw

		mov	cx,HUD_X_ORG-2
		mov	dx,HUD_X_ORG+2
		mov	bl,HUD_Y_ORG-48-14
		mov	al,COL_SIGHT
		call	HLineDraw

		mov	cx,HUD_X_ORG-3
		mov	dx,HUD_X_ORG+3
		mov	bl,HUD_Y_ORG-48-10
		mov	al,COL_SIGHT
		call	HLineDraw

		mov	cx,HUD_X_ORG-6
		mov	dx,HUD_X_ORG-4
		mov	bl,HUD_Y_ORG-48-9
		mov	al,COL_SIGHT
		call	HLineDraw

		mov	cx,HUD_X_ORG+4
		mov	dx,HUD_X_ORG+6
		mov	bl,HUD_Y_ORG-48-9
		mov	al,COL_SIGHT
		call	HLineDraw

		mov	cx,HUD_X_ORG-7
		mov	bl,HUD_Y_ORG-48-8
		mov	al,COL_SIGHT
		call	SetPixel

		mov	cx,HUD_X_ORG+7
		mov	bl,HUD_Y_ORG-48-8
		mov	al,COL_SIGHT
		call	SetPixel

		mov	cx,HUD_X_ORG-2
		mov	dx,HUD_X_ORG+2
		mov	bl,HUD_Y_ORG-48-5
		mov	al,COL_SIGHT
		call	HLineDraw

		mov	cx,HUD_X_ORG-3
		mov	bl,HUD_Y_ORG-48-4
		mov	al,COL_SIGHT
		call	SetPixel

		mov	cx,HUD_X_ORG+3
		mov	bl,HUD_Y_ORG-48-4
		mov	al,COL_SIGHT
		call	SetPixel

;* down stroke

		mov	cx,HUD_X_ORG
		mov	bl,HUD_Y_ORG-48+17
		mov	bh,HUD_Y_ORG-48+6
		mov	al,COL_SIGHT
		call	VLineDraw

		mov	cx,HUD_X_ORG-2
		mov	dx,HUD_X_ORG+2
		mov	bl,HUD_Y_ORG-48+18
		mov	al,COL_SIGHT
		call	HLineDraw

		mov	cx,HUD_X_ORG-2
		mov	dx,HUD_X_ORG+2
		mov	bl,HUD_Y_ORG-48+14
		mov	al,COL_SIGHT
		call	HLineDraw

		mov	cx,HUD_X_ORG-3
		mov	dx,HUD_X_ORG+3
		mov	bl,HUD_Y_ORG-48+10
		mov	al,COL_SIGHT
		call	HLineDraw

		mov	cx,HUD_X_ORG-6
		mov	dx,HUD_X_ORG-4
		mov	bl,HUD_Y_ORG-48+9
		mov	al,COL_SIGHT
		call	HLineDraw

		mov	cx,HUD_X_ORG+4
		mov	dx,HUD_X_ORG+6
		mov	bl,HUD_Y_ORG-48+9
		mov	al,COL_SIGHT
		call	HLineDraw

		mov	cx,HUD_X_ORG-7
		mov	bl,HUD_Y_ORG-48+8
		mov	al,COL_SIGHT
		call	SetPixel

		mov	cx,HUD_X_ORG+7
		mov	bl,HUD_Y_ORG-48+8
		mov	al,COL_SIGHT
		call	SetPixel

		mov	cx,HUD_X_ORG-2
		mov	dx,HUD_X_ORG+2
		mov	bl,HUD_Y_ORG-48+5
		mov	al,COL_SIGHT
		call	HLineDraw

		mov	cx,HUD_X_ORG-3
		mov	bl,HUD_Y_ORG-48+4
		mov	al,COL_SIGHT
		call	SetPixel

		mov	cx,HUD_X_ORG+3
		mov	bl,HUD_Y_ORG-48+4
		mov	al,COL_SIGHT
		call	SetPixel

;* left stroke

		mov	cx,HUD_X_ORG-21
		mov	dx,HUD_X_ORG-7
		mov	bl,HUD_Y_ORG-48
		mov	al,COL_SIGHT
		call	HLineDraw

		mov	cx,HUD_X_ORG-22
		mov	bl,HUD_Y_ORG-48-2
		mov	bh,HUD_Y_ORG-48+2
		mov	al,COL_SIGHT
		call	VLineDraw

		mov	cx,HUD_X_ORG-17
		mov	bl,HUD_Y_ORG-48-2
		mov	bh,HUD_Y_ORG-48+2
		mov	al,COL_SIGHT
		call	VLineDraw

		mov	cx,HUD_X_ORG-12
		mov	bl,HUD_Y_ORG-48-2
		mov	bh,HUD_Y_ORG-48+2
		mov	al,COL_SIGHT
		call	VLineDraw

		mov	cx,HUD_X_ORG-11
		mov	bl,HUD_Y_ORG-48-4
		mov	bh,HUD_Y_ORG-48-3
		mov	al,COL_SIGHT
		call	VLineDraw

		mov	cx,HUD_X_ORG-11
		mov	bl,HUD_Y_ORG-48+3
		mov	bh,HUD_Y_ORG-48+4
		mov	al,COL_SIGHT
		call	VLineDraw

		mov	cx,HUD_X_ORG-10
		mov	bl,HUD_Y_ORG-48-5
		mov	al,COL_SIGHT
		call	SetPixel

		mov	cx,HUD_X_ORG-10
		mov	bl,HUD_Y_ORG-48+5
		mov	al,COL_SIGHT
		call	SetPixel

		mov	cx,HUD_X_ORG-6
		mov	bl,HUD_Y_ORG-48-1
		mov	bh,HUD_Y_ORG-48+1
		mov	al,COL_SIGHT
		call	VLineDraw

		mov	cx,HUD_X_ORG-5
		mov	bl,HUD_Y_ORG-48-2
		mov	al,COL_SIGHT
		call	SetPixel

		mov	cx,HUD_X_ORG-5
		mov	bl,HUD_Y_ORG-48+2
		mov	al,COL_SIGHT
		call	SetPixel

;* right stroke

		mov	cx,HUD_X_ORG+21
		mov	dx,HUD_X_ORG+7
		mov	bl,HUD_Y_ORG-48
		mov	al,COL_SIGHT
		call	HLineDraw

		mov	cx,HUD_X_ORG+22
		mov	bl,HUD_Y_ORG-48-2
		mov	bh,HUD_Y_ORG-48+2
		mov	al,COL_SIGHT
		call	VLineDraw

		mov	cx,HUD_X_ORG+17
		mov	bl,HUD_Y_ORG-48-2
		mov	bh,HUD_Y_ORG-48+2
		mov	al,COL_SIGHT
		call	VLineDraw

		mov	cx,HUD_X_ORG+12
		mov	bl,HUD_Y_ORG-48-2
		mov	bh,HUD_Y_ORG-48+2
		mov	al,COL_SIGHT
		call	VLineDraw

		mov	cx,HUD_X_ORG+11
		mov	bl,HUD_Y_ORG-48-4
		mov	bh,HUD_Y_ORG-48-3
		mov	al,COL_SIGHT
		call	VLineDraw

		mov	cx,HUD_X_ORG+11
		mov	bl,HUD_Y_ORG-48+3
		mov	bh,HUD_Y_ORG-48+4
		mov	al,COL_SIGHT
		call	VLineDraw

		mov	cx,HUD_X_ORG+10
		mov	bl,HUD_Y_ORG-48-5
		mov	al,COL_SIGHT
		call	SetPixel

		mov	cx,HUD_X_ORG+10
		mov	bl,HUD_Y_ORG-48+5
		mov	al,COL_SIGHT
		call	SetPixel

		mov	cx,HUD_X_ORG+6
		mov	bl,HUD_Y_ORG-48-1
		mov	bh,HUD_Y_ORG-48+1
		mov	al,COL_SIGHT
		call	VLineDraw

		mov	cx,HUD_X_ORG+5
		mov	bl,HUD_Y_ORG-48-2
		mov	al,COL_SIGHT
		call	SetPixel

		mov	cx,HUD_X_ORG+5
		mov	bl,HUD_Y_ORG-48+2
		mov	al,COL_SIGHT
		call	SetPixel

		ret

DrawStandby	ENDP

DrawStandby2	PROC	NEAR
		
		;mov	si,OFFSET SetUp$
		;call	Print$
		
		mov	si,OFFSET SetUp$
		call	Print$
		
;* centre dot

		mov	cx,HUD_X_ORG
		mov	bl,HUD_Y_ORG-0
		mov	al,COL_SIGHT
		call	SetPixel

;* up stroke

		mov	cx,HUD_X_ORG
		mov	bl,HUD_Y_ORG-0-17
		mov	bh,HUD_Y_ORG-0-6
		mov	al,COL_SIGHT
		call	VLineDraw

		mov	cx,HUD_X_ORG-2
		mov	dx,HUD_X_ORG+2
		mov	bl,HUD_Y_ORG-0-18
		mov	al,COL_SIGHT
		call	HLineDraw

		mov	cx,HUD_X_ORG-2
		mov	dx,HUD_X_ORG+2
		mov	bl,HUD_Y_ORG-0-14
		mov	al,COL_SIGHT
		call	HLineDraw

		mov	cx,HUD_X_ORG-3
		mov	dx,HUD_X_ORG+3
		mov	bl,HUD_Y_ORG-0-10
		mov	al,COL_SIGHT
		call	HLineDraw

		mov	cx,HUD_X_ORG-6
		mov	dx,HUD_X_ORG-4
		mov	bl,HUD_Y_ORG-0-9
		mov	al,COL_SIGHT
		call	HLineDraw

		mov	cx,HUD_X_ORG+4
		mov	dx,HUD_X_ORG+6
		mov	bl,HUD_Y_ORG-0-9
		mov	al,COL_SIGHT
		call	HLineDraw

		mov	cx,HUD_X_ORG-7
		mov	bl,HUD_Y_ORG-0-8
		mov	al,COL_SIGHT
		call	SetPixel

		mov	cx,HUD_X_ORG+7
		mov	bl,HUD_Y_ORG-0-8
		mov	al,COL_SIGHT
		call	SetPixel

		mov	cx,HUD_X_ORG-2
		mov	dx,HUD_X_ORG+2
		mov	bl,HUD_Y_ORG-0-5
		mov	al,COL_SIGHT
		call	HLineDraw

		mov	cx,HUD_X_ORG-3
		mov	bl,HUD_Y_ORG-0-4
		mov	al,COL_SIGHT
		call	SetPixel

		mov	cx,HUD_X_ORG+3
		mov	bl,HUD_Y_ORG-0-4
		mov	al,COL_SIGHT
		call	SetPixel

;* down stroke

		mov	cx,HUD_X_ORG
		mov	bl,HUD_Y_ORG-0+17
		mov	bh,HUD_Y_ORG-0+6
		mov	al,COL_SIGHT
		call	VLineDraw

		mov	cx,HUD_X_ORG-2
		mov	dx,HUD_X_ORG+2
		mov	bl,HUD_Y_ORG-0+18
		mov	al,COL_SIGHT
		call	HLineDraw

		mov	cx,HUD_X_ORG-2
		mov	dx,HUD_X_ORG+2
		mov	bl,HUD_Y_ORG-0+14
		mov	al,COL_SIGHT
		call	HLineDraw

		mov	cx,HUD_X_ORG-3
		mov	dx,HUD_X_ORG+3
		mov	bl,HUD_Y_ORG-0+10
		mov	al,COL_SIGHT
		call	HLineDraw

		mov	cx,HUD_X_ORG-6
		mov	dx,HUD_X_ORG-4
		mov	bl,HUD_Y_ORG-0+9
		mov	al,COL_SIGHT
		call	HLineDraw

		mov	cx,HUD_X_ORG+4
		mov	dx,HUD_X_ORG+6
		mov	bl,HUD_Y_ORG-0+9
		mov	al,COL_SIGHT
		call	HLineDraw

		mov	cx,HUD_X_ORG-7
		mov	bl,HUD_Y_ORG-0+8
		mov	al,COL_SIGHT
		call	SetPixel

		mov	cx,HUD_X_ORG+7
		mov	bl,HUD_Y_ORG-0+8
		mov	al,COL_SIGHT
		call	SetPixel

		mov	cx,HUD_X_ORG-2
		mov	dx,HUD_X_ORG+2
		mov	bl,HUD_Y_ORG-0+5
		mov	al,COL_SIGHT
		call	HLineDraw

		mov	cx,HUD_X_ORG-3
		mov	bl,HUD_Y_ORG-0+4
		mov	al,COL_SIGHT
		call	SetPixel

		mov	cx,HUD_X_ORG+3
		mov	bl,HUD_Y_ORG-0+4
		mov	al,COL_SIGHT
		call	SetPixel

;* left stroke

		mov	cx,HUD_X_ORG-21
		mov	dx,HUD_X_ORG-7
		mov	bl,HUD_Y_ORG-0
		mov	al,COL_SIGHT
		call	HLineDraw

		mov	cx,HUD_X_ORG-22
		mov	bl,HUD_Y_ORG-0-2
		mov	bh,HUD_Y_ORG-0+2
		mov	al,COL_SIGHT
		call	VLineDraw

		mov	cx,HUD_X_ORG-17
		mov	bl,HUD_Y_ORG-0-2
		mov	bh,HUD_Y_ORG-0+2
		mov	al,COL_SIGHT
		call	VLineDraw

		mov	cx,HUD_X_ORG-12
		mov	bl,HUD_Y_ORG-0-2
		mov	bh,HUD_Y_ORG-0+2
		mov	al,COL_SIGHT
		call	VLineDraw

		mov	cx,HUD_X_ORG-11
		mov	bl,HUD_Y_ORG-0-4
		mov	bh,HUD_Y_ORG-0-3
		mov	al,COL_SIGHT
		call	VLineDraw

		mov	cx,HUD_X_ORG-11
		mov	bl,HUD_Y_ORG-0+3
		mov	bh,HUD_Y_ORG-0+4
		mov	al,COL_SIGHT
		call	VLineDraw

		mov	cx,HUD_X_ORG-10
		mov	bl,HUD_Y_ORG-0-5
		mov	al,COL_SIGHT
		call	SetPixel

		mov	cx,HUD_X_ORG-10
		mov	bl,HUD_Y_ORG-0+5
		mov	al,COL_SIGHT
		call	SetPixel

		mov	cx,HUD_X_ORG-6
		mov	bl,HUD_Y_ORG-0-1
		mov	bh,HUD_Y_ORG-0+1
		mov	al,COL_SIGHT
		call	VLineDraw

		mov	cx,HUD_X_ORG-5
		mov	bl,HUD_Y_ORG-0-2
		mov	al,COL_SIGHT
		call	SetPixel

		mov	cx,HUD_X_ORG-5
		mov	bl,HUD_Y_ORG-0+2
		mov	al,COL_SIGHT
		call	SetPixel

;* right stroke

		mov	cx,HUD_X_ORG+21
		mov	dx,HUD_X_ORG+7
		mov	bl,HUD_Y_ORG-0
		mov	al,COL_SIGHT
		call	HLineDraw

		mov	cx,HUD_X_ORG+22
		mov	bl,HUD_Y_ORG-0-2
		mov	bh,HUD_Y_ORG-0+2
		mov	al,COL_SIGHT
		call	VLineDraw

		mov	cx,HUD_X_ORG+17
		mov	bl,HUD_Y_ORG-0-2
		mov	bh,HUD_Y_ORG-0+2
		mov	al,COL_SIGHT
		call	VLineDraw

		mov	cx,HUD_X_ORG+12
		mov	bl,HUD_Y_ORG-0-2
		mov	bh,HUD_Y_ORG-0+2
		mov	al,COL_SIGHT
		call	VLineDraw

		mov	cx,HUD_X_ORG+11
		mov	bl,HUD_Y_ORG-0-4
		mov	bh,HUD_Y_ORG-0-3
		mov	al,COL_SIGHT
		call	VLineDraw

		mov	cx,HUD_X_ORG+11
		mov	bl,HUD_Y_ORG-0+3
		mov	bh,HUD_Y_ORG-0+4
		mov	al,COL_SIGHT
		call	VLineDraw

		mov	cx,HUD_X_ORG+10
		mov	bl,HUD_Y_ORG-0-5
		mov	al,COL_SIGHT
		call	SetPixel

		mov	cx,HUD_X_ORG+10
		mov	bl,HUD_Y_ORG-0+5
		mov	al,COL_SIGHT
		call	SetPixel

		mov	cx,HUD_X_ORG+6
		mov	bl,HUD_Y_ORG-0-1
		mov	bh,HUD_Y_ORG-0+1
		mov	al,COL_SIGHT
		call	VLineDraw

		mov	cx,HUD_X_ORG+5
		mov	bl,HUD_Y_ORG-0-2
		mov	al,COL_SIGHT
		call	SetPixel

		mov	cx,HUD_X_ORG+5
		mov	bl,HUD_Y_ORG-0+2
		mov	al,COL_SIGHT
		call	SetPixel

		ret

DrawStandby2	ENDP

PANCODE		ENDS

;============================================================================

		END

