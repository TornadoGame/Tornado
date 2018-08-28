;****************************************************************************
;*
;* MFD.ASM
;*
;* Multi-function display.
;*
;* 12.02.1992 - KJB
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<
PUBLIC DamagedDispMFD
PUBLIC UpdateMFD
PUBLIC RadarDisp
PUBLIC ModePtr
PUBLIC AutoPilotDisp
PUBLIC ILSDisp
PUBLIC GndMappingRadar

		PUBLIC	UpdatePilotMFD
		PUBLIC	UpdateNavigMFD
		PUBLIC	SelectRadarMFD
		PUBLIC	SelectAutoMFD
		
;PUBLIC Cannon$
		PUBLIC	DrawIRImage

		PUBLIC	PILOT_MFD
		PUBLIC	NAVIG_MFD
;EXTRN	NightVisionState:BYTE		
EXTRN QuieterCockpit:BYTE
EXTRN	FullScreen:BYTE		
EXTRN   ShiftDwasPressed:BYTE
;EXTRN   KF_NVG_MFD:BYTE
;EXTRN   KF_NONVG_MFD:BYTE
EXTRN	NavigPanel:BYTE
EXTRN	IronWork:BYTE		
EXTRN	UpdateRWR:NEAR
EXTRN	LoadExtrnPan:NEAR    ;added on 26/11/2017 hacked
EXTRN	UpdateExtrn:NEAR     ;added on 26/11/2017 hacked
EXTRN	UpdateHUD2:NEAR	     ;added on 30/11/2017 hacked frankie
EXTRN	UpdateHUD:NEAR	
EXTRN  UpdateEScope2:NEAR

		EXTRN	DeltaTime:WORD
		EXTRN	KF_TrackClk:BYTE
		EXTRN	KF_TrackAClk:BYTE
		EXTRN	KF_FastTrkClk:BYTE
		EXTRN	KF_FastTrkAClk:BYTE

		EXTRN	RandX:FAR
		EXTRN	LineDraw:FAR
		EXTRN	HLineDraw:FAR
		EXTRN	VLineDraw:FAR
		EXTRN	BlockFill:FAR
		EXTRN	Print$:FAR
		EXTRN	DecWord$:FAR
		EXTRN	UpdateMovingMap:FAR
		EXTRN	SetPixel:FAR
		EXTRN	SetViewMode:FAR
		EXTRN	Visual:FAR
		EXTRN	SetIRPalette:FAR
		EXTRN	FixIRPalette:FAR
		EXTRN	SetGMRPalette:FAR
		EXTRN	FixGMRPalette:FAR
		EXTRN	PolyFill:FAR
		EXTRN	ReadMouseMotion:FAR
		EXTRN	MoveViewpoint:FAR
		EXTRN	LocateMobiles:FAR
		EXTRN	CancelTgtWP:FAR
		EXTRN	UpdateTgtWP:FAR
		EXTRN	CharSprite:FAR
		EXTRN	PrintChar:FAR

		EXTRN	DrawRadarNoise:NEAR
;EXTRN	Cannons:WORD ;hacked
		EXTRN	M_VIEW:WORD
		EXTRN	TMP_VIEW:WORD
		EXTRN	RadarMode:WORD
		EXTRN	AutoMode:WORD
		EXTRN	AltMode:WORD
		EXTRN	HdgMode:WORD
		EXTRN	AutoVias:WORD
		EXTRN	TFRideAlt:WORD
		EXTRN	AutoHdg:WORD
		EXTRN	AutoHdgFine:WORD
		EXTRN	AutoAlt:WORD
		EXTRN	ILSLocalPos:WORD
		EXTRN	ILSGlidePos:WORD
		EXTRN	ILSBrg:WORD
		EXTRN	ILSRng:WORD
		EXTRN	DispHdg:WORD
		EXTRN	ILSETA:WORD
		EXTRN	SecScanCnt1:WORD
		EXTRN	SecScanOff1:WORD
		EXTRN	SecScanCnt2:WORD
		EXTRN	SecScanOff2:WORD
		EXTRN	M_CosP:WORD
		EXTRN	M_SinH:WORD
		EXTRN	M_CosH:WORD
		EXTRN	CrewMode:WORD
		EXTRN	XMickeys:WORD
		EXTRN	YMickeys:WORD
		EXTRN	FloatWP:WORD
		EXTRN	FloatWPX:WORD
		EXTRN	FloatWPY:WORD
		EXTRN	LastFrame:WORD
		EXTRN	MobSectorTable:WORD
		EXTRN	M_MOBILE:WORD
		EXTRN	CurrentWPX:WORD
		EXTRN	CurrentWPY:WORD
		EXTRN	WPPtr:WORD
		EXTRN	WPETA:WORD
		EXTRN	WPTimeEarlyLate:WORD
		EXTRN	CellXMin:WORD
		EXTRN	CellXMax:WORD
		EXTRN	CellYMin:WORD
		EXTRN	CellYMax:WORD
		EXTRN	PrtLn:WORD
		EXTRN	PrtCl:WORD
		EXTRN	NumRadarTracks:WORD
		EXTRN	AirRadarRng:WORD
		EXTRN	TornadoType:WORD
		EXTRN	AirTgtPtr:WORD
EXTRN	KF_Full_MFD:BYTE
		EXTRN	KF_MFDSelect:BYTE
		EXTRN	KF_MFDToggle:BYTE
		EXTRN	KF_MapZoomIn:BYTE
		EXTRN	KF_MapZoomOut:BYTE
		EXTRN	KF_MapOrigin:BYTE
		EXTRN	AutoThrot:BYTE
		EXTRN	SSF_PilotMFD:BYTE
		EXTRN	SSF_NavigMFD:BYTE
		EXTRN	ILSActive:BYTE
		EXTRN	GradEnabled:BYTE
		EXTRN	StarsEnabled:BYTE
		EXTRN	CloudsEnabled:BYTE
		EXTRN	HillTextEnabled:BYTE
		EXTRN	MobileLayer1:BYTE
		EXTRN	DisableInput:BYTE
		EXTRN	Key:BYTE
		EXTRN	Night:BYTE
		EXTRN	Fog:BYTE

		EXTRN	MAP_MFD_DISP:ABS
		EXTRN	MAP_ZOOM1:ABS
		EXTRN	MAP_ZOOM6:ABS
		EXTRN	MAP_ORG_CENTRE:ABS
		EXTRN	MAP_ORG_BASE:ABS

;============================================================================

		INCLUDE	MFD.INC
		INCLUDE	TAB.INC
		INCLUDE	MAINDATA.INC

		INCLUDE	\VISUAL\VISDATA.INC
		INCLUDE	\VISUAL\VISEXTRN.INC
		INCLUDE	\VISUAL\VISMACRO.INC
		INCLUDE	\VISUAL\PALETTES.INC

		INCLUDE	\LIB8086\KEYS.INC
		INCLUDE	\LIB8086\PRINT.INC
		INCLUDE	\LIB8086\USEFUL.INC

	
;============================================================================
		EXTRN	TAB1:TAB
		EXTRN	TAB2:TAB

		EXTRN	AirRadarTracks:ARAD_TRACK

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'
	
HUD_X_ORG	EQU	160
HUD_Y_ORG	EQU	96

;--------------- experimental-----------------------
;VP		VIEWPORT <>


TAB_WIDTH	EQU	96
TAB_DEPTH	EQU	72
TAB_WIDTH_TIALD	EQU	320
TAB_DEPTH_TIALD	EQU	192

XC_TIALD		EQU	TAB_WIDTH_TIALD/2	;centre x
YC_TIALD		EQU	TAB_DEPTH_TIALD/2-1	;centre y

;------------
;* TAB origin
;------------

;XOrg		DW	0
;YOrg		DB	0,0

XOrg_TIALD		DW	0
YOrg_TIALD		DB	0,0


;----------
;* MFD size
;----------

MFD_WIDTH	EQU	64  ;Ori = 64, trying 96
MFD_DEPTH	EQU	48  ;Ori = 48, trying 72

XC		EQU	MFD_WIDTH/2	;centre x
YC		EQU	MFD_DEPTH/2-1	;centre y

;------------
;* MFD origin
;------------

XOrg		DW	0
YOrg		DB	0,0		;sometimes accessed as word

;------------------
;* pilot's MFD data
;------------------

;* note: Pilot MFD always has mouse (MFD_HAS_MOUSE = 1). However, the "mouse
;*       required" flag (MFD_REQ_MOUSE) should be initialized wrt the default
;*       MFD mode. The default MFD mode should be common to all Tornado
;*       variants.

PILOT_MFD	MFD	<128,144,1,MFD_MAP,MAP_ZOOM1,MAP_ORG_CENTRE,OFFSET SSF_PilotMFD,0,1>


;----------------------
;* navigator's MFD data
;----------------------

;* note: Navigator MFD shares the mouse with the two TAB displays. The "mouse
;*       required" flag (MFD_REQ_MOUSE) should be initialized wrt the default
;*	 MFD mode. The "has mouse" flag (MFD_HAS_MOUSE) should be set taking
;*	 into account of the default TAB modes. The default MFD mode should
;*       be common to all Tornado variants.

;NAVIG_MFD	MFD	<128,57,1,MFD_FLIR,MAP_ZOOM1,MAP_ORG_CENTRE,OFFSET SSF_NavigMFD,0,1>
NAVIG_MFD	MFD	<128,57,1,MFD_AUTO_PILOT,MAP_ZOOM1,MAP_ORG_CENTRE,OFFSET SSF_NavigMFD,0,1>

;----------------------
;* mouse required flags
;----------------------

MFDMouseFlags	DB	1		;MFD_MAP
		DB	1		;MFD_RADAR
		DB	0		;MFD_AUTO_PILOT
		DB	0		;MFD_ILS
		DB	0		;MFD_FLIR_ORI
		DB	0		;MFD_FLIR		

		EVEN

;-------------------
;* MFD select switch
;-------------------

;* note: At least one display must always be available (unconditional).

SelectSwitch	DW	SelectMap	;MFD_MAP
		DW	SelectRadar	;MFD_RADAR
		DW	SelectAFDS	;MFD_AUTO_PILOT
		DW	SelectModeOk	;MFD_ILS
		DW	SelectFLIR	;MFD_FLIR
		DW	SelectFLIR	;MFD_FLIR		
		DW	SelectLoopBack	;MFD_LOOPBACK

;-------------------------
;* MFD display mode switch
;-------------------------

DispSwitch	DW	MapDisp		;MFD_MAP
		DW	RadarDisp	;MFD_RADAR
		DW	AutoPilotDisp	;MFD_AUTO_PILOT
		DW	ILSDisp		;MFD_ILS
		DW	FLIRDisp_ori	;MFD_FLIR_ORI
		DW	FLIRDisp	;MFD_FLIR

;----------------------
;* ground mapping radar 
;----------------------

GMRRange	DW	MAP_ZOOM1	;ground mapping radar range

GMROk		DB	0		;1 = within operating conditions

		EVEN

;* flashing target marker

GMR_FLASH_DELAY	EQU	20		;secs * 100

GMRFlashTimer	DW	0		;secs * 100

GMR_FLASH_HI	EQU	COL_CRT16
GMR_FLASH_LO	EQU	COL_CRT6

GMRFlashCol	DB	GMR_FLASH_HI

		EVEN

;* "snap to object" search area wrt range

SnapSearchArea	DW	16384/8		;MAP_ZOOM1
		DW	16384/16	;MAP_ZOOM2
		DW	16384/32	;MAP_ZOOM3
		DW	16384/64	;MAP_ZOOM4
		DW	16384/128	;MAP_ZOOM5
		DW	16384/256	;MAP_ZOOM6


;* temp snap co-ords

SnapX		DW	0
SnapY		DW	0

;-----------
;* air radar
;-----------

;* range scale tick y start (offset from YOrg)

AirRadYStart	DW	8		;ARAD_MIN_RANGE
		DW	8		;ARAD_MED_RANGE
		DW	4		;ARAD_MAX_RANGE

;* range scale tick count

AirRadYCount	DW	3		;ARAD_MIN_RANGE
		DW	5		;ARAD_MED_RANGE
		DW	11		;ARAD_MAX_RANGE

;* range scale tick spacing

AirRadYStep	DW	16		;ARAD_MIN_RANGE
		DW	8		;ARAD_MED_RANGE
		DW	4		;ARAD_MAX_RANGE

;* flashing target marker

TGT_FLASH_DELAY	EQU	20		;secs * 100

TgtFlashTimer	DW	0		;secs * 100

TGT_FLASH_HI	EQU	COL_CRT16
TGT_FLASH_LO	EQU	COL_CRT1

TgtCol		DB	TGT_FLASH_HI

TgtFlashCol	DB	TGT_FLASH_HI

		EVEN

;------------
;* radar mask
;------------

RadarMaskPoly	LABEL	WORD		;3 sided polygon list

PolyX1		DW	0   
PolyY1		DW	0
PolyX2		DW	0
PolyY2		DW	0
PolyX3		DW	0
PolyY3		DW	0
PolyX4		DW	0
PolyY4		DW	0
		DW	-1

;-------------------------
;* radar designator cursor
;-------------------------

;* radar cursor virtual co-ords (256 scaled)

CRSR_XV_MAX	EQU	MFD_WIDTH*256
CRSR_YV_MAX 	EQU	MFD_DEPTH*256

CrsrXv		DW	CRSR_XV_MAX/2	;0 .. CRSR_XV_MAX - 1
CrsrYv		DW	CRSR_YV_MAX/2	;0 .. CRSR_YV_MAX - 1

;* top y and bottom y cursor limits

CRSR_YMIN	EQU	1
CRSR_YMAX	EQU	46

;* left x and right x limits

CrsrXLimits	LABEL	BYTE

;*		DB	xl, xr		;line

		DB	-1, -1		;0 (out of bounds)
		DB	20, 43		;1
		DB	18, 45		;2
		DB	16, 47		;3
		DB	14, 49		;4
		DB	13, 50		;5
		DB	12, 51		;6
		DB	11, 52		;7
		DB	10, 53		;8
		DB	 9, 54		;9
		DB	 8, 55		;10
		DB	 7, 56		;11
		DB	 6, 57		;12
		DB	 5, 58		;13
		DB	 5, 58		;14
		DB	 4, 59		;15
		DB	 4, 59		;16
		DB	 4, 59		;17
		DB	 3, 60		;18
		DB	 3, 60		;19
		DB	 3, 60		;20
		DB	 3, 60		;21
		DB	 2, 61		;22
		DB	 2, 61		;23
		DB	 2, 61		;24
		DB	 2, 61		;25
		DB	 2, 61		;26
		DB	 2, 61		;27
		DB	 2, 61		;28
		DB	 3, 60		;29
		DB	 4, 59		;30
		DB	 5, 58		;31
		DB	 6, 57		;32
		DB	 7, 56		;33
		DB	 8, 55		;34
		DB	 9, 54		;35
		DB	10, 53		;36
		DB	11, 52		;37 
		DB	12, 51		;38
		DB	13, 50		;39
		DB	14, 49		;40
		DB	15, 48		;41
		DB	16, 47		;42
		DB	17, 46		;43
		DB	18, 45		;44
		DB	19, 44		;45
		DB	20, 43		;46
		DB	-1, -1		;47 (out of bounds)

;--------------------------------
;* auto-pilot display mode titles
;--------------------------------

AutoTitle$	DW	OFFSET Off$		;AUTO_OFF
		DW	OFFSET Approach$	;AUTO_APPROACH
		DW	OFFSET TrackAcquire$	;AUTO_TRACK
		DW	OFFSET AltHdgHold$	;AUTO_HOLD
		DW	OFFSET TerrainFollow$	;AUTO_TF

;-----------------------------------
;* altitude authority display switch
;-----------------------------------

AltSwitch	DW	AltManual	;ALT_MANUAL
		DW	AltApproach	;ALT_APPROACH
		DW	AltAcquire	;ALT_ACQUIRE
		DW	AltTF		;ALT_TF

;----------------------------------
;* heading authority display switch
;----------------------------------

HdgSwitch	DW	HdgManual	;HDG_MANUAL
		DW	HdgApproach	;HDG_APPROACH
		DW	HdgAcquire	;HDG_ACQUIRE
		DW	HdgTrack	;HDG_TRACK

;-----------------
;* string pointers
;-----------------

ModePtr		DW	OFFSET Off$
AltPtr		DW	OFFSET Manual$
HdgPtr		DW	OFFSET Manual$
IASPtr		DW	OFFSET Manual$

;-------------------------------
;* time early late display value
;-------------------------------

WPTEL		DW	0		;secs

;-------------
;* string data
;-------------

;* >>>>> auto-pilot MFD <<<<<

;MFDAttr1	DB	0ffh,000h,0aah,000h,0aah,000h,COL_CRT6,000h	;dull green
MFDAttr1	DB	0ffh,000h,0aah,000h,0aah,000h,COL_CRT8,000h	;dull green

MFDAttr2	DB	0ffh,000h,0aah,000h,0aah,000h,COL_CRT16,000h	;bright green

AFDS$		LABEL	BYTE
		P_OVER1
		P_CHAR2
		PV_XY	XOrg,YOrg
		PV_ATTR	MFDAttr1
		PD_XYMV	4,4
		DB	"AFDS "
		PP_STR	ModePtr
		PV_XY	XOrg,YOrg
		PD_XYMV	4,13
		DB	"ALT "
Alt$		DB	"----- "
		PP_STR	AltPtr
		PV_XY	XOrg,YOrg
		PD_XYMV	4,20
		DB	"HDG "
Hdg$		DB	"  --- "
		PP_STR	HdgPtr
		PV_XY	XOrg,YOrg
		PD_XYMV	4,27
		DB	"IAS "
IAS$		DB	"  --- "
		PP_STR	IASPtr
		P_END

TTG$		LABEL	BYTE
		PV_XY	XOrg,YOrg
		PD_XYMV	4,34
		DB	"TTG "
		P_END

TTGApproach$	LABEL	BYTE
		PV_ETA	ILSETA
		P_END

TTGTrack$	LABEL	BYTE
		PV_ETA	WPETA
		P_END

TTGInvalid$	LABEL	BYTE
		DB	"-----"
		P_END

TEL$		LABEL	BYTE
		PV_XY	XOrg,YOrg
		PD_XYMV	4,41
		DB	"TEL "
		P_END

TELValid$	LABEL	BYTE
		PV_ETA	WPTEL
		P_END

TELInvalid$	LABEL	BYTE
		DB	"-----"
		P_END

Early$ 		LABEL	BYTE
		PV_XY	XOrg,YOrg
		PD_XYMV	44,41
		DB	"ERLY"
		P_END

Late$ 		LABEL	BYTE
		PV_XY	XOrg,YOrg
		PD_XYMV	44,41
		DB	"LATE"
		P_END

Off$		DB	"OFF",0

Approach$	DB	"APRCH",0

TrackAcquire$	DB	"TRACK ( )",0

AltHdgHold$	DB	"ALT/HDG",0

TerrainFollow$	DB	"TF",0

AutoThrottle$	DB	"THROT",0

Auto$		DB	"AUTO",0

Acquire$	DB	"ACQR",0

Manual$		DB	"MAN",0

Ride$		DB	"RIDE",0

;* >>>>> ILS MFD <<<<<

ILSSetUp$ 	LABEL	BYTE
		P_OVER1
		P_CHAR2
		PV_XY	XOrg,YOrg
		PD_VGA	COL_CRT10,COL_CRT1
		PD_XYMV	4,1
		P_DECAT	00100011b	;(unsigned, 3 digits, leading zeroes)
		PV_DECW	DispHdg
		P_DECAT	00000000b	;(default)
		P_END

ILSActive$	LABEL	BYTE
		PD_XYMV	32,0
		PV_PDEG	ILSBrg
		PD_XYMV	-56,41
		PV_ETA	ILSETA
		PD_XYMV	16,0
		PV_RNG	ILSRng
		P_END

ILSInActive$	LABEL	BYTE
		PD_XYMV	32,0
		DB	"---"
		PD_XYMV	-56,41
		DB	"-----"
		PD_XYMV	16,0
		DB	"-----"
		P_END

		EVEN

DATA		ENDS

;============================================================================

MSECDATA1	SEGMENT PARA PUBLIC 'DATA'

MSECDATA1	ENDS

;============================================================================

PANCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:PANCODE
		ASSUME DS:DATA

;* UpdateMFD
;* UpdatePilotMFD
;* UpdateNavigMFD
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

UpdateNavigMFD	LABEL	NEAR

		mov	si,OFFSET NAVIG_MFD

		jmp	UpdateMFD

UpdatePilotMFD	LABEL	NEAR

		mov	si,OFFSET PILOT_MFD

UpdateMFD	PROC	NEAR

;-----------------
;* set origin vars
;-----------------

		mov	ax,MFD_X_ORG[si]
		mov	XOrg,ax
		mov	al,MFD_Y_ORG[si]
		mov	YOrg,al

;---------------------------------
;* set char sprite clipping window
;---------------------------------

		mov	ax,XOrg
		mov	CellXMin,ax
		add	ax,MFD_WIDTH
		dec	ax
		mov	CellXMax,ax

		mov	ax,WORD PTR YOrg
		mov	CellYMin,ax
		add	ax,MFD_DEPTH
		dec	ax
		mov	CellYMax,ax

;-----------------------
;* test for MFD on / off
;-----------------------

		KTEST	KF_MFDToggle  		;toggle MFD on / off?	
		jz	@F	      		;no ->

		xor	MFD_STATUS[si],1	;toggle

		KCLEAR	KF_MFDSelect		;cancel select request

@@:		test	MFD_STATUS[si],1	;MFD on?
		_JZ	SwitchedOff  		;no ->

;----------------------
;* test for damaged MFD
;----------------------

		mov	bx,MFD_SSF_PTR[si]
		test	BYTE PTR [bx],1		;damaged?
		_JNZ	Damaged			;yes ->

;--------------------------
;* test for select MFD mode
;--------------------------

		mov	bx,MFD_MODE[si]

;* If moving map selected on Nav's MFD, check for confliction with both TAB
;* displays. Do this test here as the MFD may just have been switched on and
;* a conflict may have occurred.

		cmp	si,OFFSET NAVIG_MFD	;Nav's MFD?
		jne	@F			;no ->

		cmp	bx,MFD_MAP     	;moving map?
		jne	@F	       	;no ->

		call	CheckTABMap	;moving map selected on any TAB display?
		jc	SelectNext	;yes ->

;@@:		
	    ;mov	al,Key[K_SHIFT]
		;and	al,Key[K_D]
@@:				
		KTEST	KF_Full_MFD ;Added on 10th April 2018
		jz Check_MFDSelect
		KCLEAR KF_Full_MFD
		cmp bx, MFD_FLIR
		je  Check_MFDSelect
		mov bx,MFD_FLIR
		jmp	SelectSwitch[bx]

Check_MFDSelect:		
        KTEST	KF_MFDSelect
		jz	SortMode
		cmp ShiftDwasPressed,1
        je	SortMode	
SelectNext:	add	bx,2
        cmp FullScreen,1
		je JumpOutToHere
        cmp	bx,MFD_FLIR
		jne JumpOutToHere
		add	bx,2
JumpOutToHere:		
		jmp	SelectSwitch[bx]

;* only select moving map if not selected on TAB displays (Nav only)

SelectMap:	cmp	si,OFFSET NAVIG_MFD	;Nav's MFD?
		jne	@F			;no ->

		call	CheckTABMap	;moving map selected on any TAB display?
		jc	SelectNext	;yes ->

@@:		jmp	SelectModeOk

;* only select radar mode if radar is on

SelectRadar:	cmp	RadarMode,NUL_RADAR	;radar on?
		je	SelectNext		;no ->

		jmp	SelectModeOk

;* only select AFDS if auto-pilot engaged

SelectAFDS:	cmp	AutoMode,AUTO_OFF	;auto-pilot engaged?
		jne	@F			;yes ->

   		test	AutoThrot,1	;auto-throttle engaged?
		jz	SelectNext 	;no ->

@@:		jmp	SelectModeOk

;* if Pilot then only select FLIR if night or foggy

SelectFLIR:	
;       cmp	si,OFFSET PILOT_MFD	;Pilot's MFD?
;		jne	@F			;no ->
;
;		
;		cmp	Night,0		;night?
;		jne	@F		;yes ->
;
;		cmp	Fog,0		;foggy?
;		je	SelectNext	;no ->
;
;@@:		
        cmp	CrewMode,CREW_PILOT	;pilot?
		je skippyhere
		cmp	NAVIG_MFD.MFD_MODE,MFD_FLIR_ORI	;kbs
		je	SelectNext
		cmp	TAB1.TAB_MODE,TAB_FLIR	
		je	SelectNext
skippyhere:		
        jmp	SelectModeOk  ;hack frankie
		
		call LoadExtrnPan  ;hacked on 5/11/2017 - calls the info bar (8 pixels) to cover remaining space at bottom
		call UpdateExtrn
		
;* loop back to first MFD mode


SelectLoopBack:	mov	bx,-2

		jmp	SelectNext

SelectModeOk:	mov	MFD_MODE[si],bx

;-------------------
;* sort display mode
;-------------------

;* note: If auto-pilot display selected and auto-pilot is disengaged then
;*	 leave display selected (ie. do not revert to moving map). This is
;*       so cancellation or error can be confirmed. The auto-pilot display
;*	 will be removed from cycle next time around.
;*
;*       If radar mode and radar off (or damaged) then revert back to moving
;*       map (if possible). The Nav's MFD has to check for confliction with
;*	 the TAB displays. If there is a confliction then revert to the FLIR 
;*	 display. The FLIR display is always available on the Nav's MFD.

SortMode:	cmp	bx,MFD_RADAR	;radar mode?
		jne	SkipRadarCheck	;no ->

		cmp	RadarMode,NUL_RADAR	;radar on?
		jne	SkipRadarCheck		;yes ->

		mov	bx,MFD_MAP	;revert to map

;* if Nav's MFD then check for confliction with TAB moving map

		cmp	si,OFFSET NAVIG_MFD	;Nav's MFD?
		jne	@F			;no ->

		call	CheckTABMap	;moving map selected on any TAB display?
		jnc	@F		;no ->

		mov	bx,MFD_FLIR	;confliction - revert to FLIR

@@:		mov	MFD_MODE[si],bx

;* sort mouse required flag (do this every frame in case MFD auto-switches)

SkipRadarCheck:	shr	bx,1		;/2 byte index

		mov	al,MFDMouseFlags[bx]
		mov	MFD_REQ_MOUSE[si],al

		shl	bx,1		;*2 word index

		cmp	si,OFFSET NAVIG_MFD	;Nav's MFD?
		jne	@F			;no ->

		test	al,al		;mouse required?
		jz	@F		;no ->

		call	StealMouse

@@:		call	DispSwitch[bx]

		ret

;------------------
;* MFD switched off
;------------------

SwitchedOff:	call	ClearDisp

		ret

;-------------
;* damaged MFD
;-------------

Damaged:	call	DamagedDisp

		ret

UpdateMFD	ENDP

;----------------------------------------------------------------------------

;* CheckTABMap - check if moving map is selected on any TAB display
;*
;* pass: TAB1
;*       TAB2
;* ret : cf = 0: moving map not selected
;*       cf = 1: moving map selected
;* kill: ax, flags (except cf)

CheckTABMap	PROC	NEAR

		push	bx

		cmp	TAB1.TAB_MODE,TAB_MAP	;map selected?
		jne	@F			;no ->

		test	TAB1.TAB_STATUS,1	;display on?
		jz	@F			;no ->

		mov	bx,TAB1.TAB_SSF_PTR
		test	BYTE PTR [bx],1		;display damaged?
		jz	PassTABMap		;no ->

@@:		cmp	TAB2.TAB_MODE,TAB_MAP	;map selected?
		jne	FailTABMap		;no ->

		test	TAB2.TAB_STATUS,1	;display on?
		jz	FailTABMap		;no ->

		mov	bx,TAB2.TAB_SSF_PTR
		test	BYTE PTR [bx],1		;display damaged?
		jnz	FailTABMap		;yes ->

PassTABMap:	pop	bx
		stc			;moving map selected
		ret

FailTABMap:	pop	bx
		clc			;moving map not selected
		ret

CheckTABMap	ENDP

;----------------------------------------------------------------------------

;* StealMouse - steal mouse from other displays (if available)
;*
;* pass: si -> MFD data block
;* ret : nothing
;* kill: ax, flags
;*
;* note: This routine only applies to the Nav's MFD.
;* 
;*       Registers bx and si must be preserved.

StealMouse	PROC	NEAR

		push	bx

		test	NAVIG_MFD.MFD_HAS_MOUSE,1 ;does MFD already have mouse?
		jnz	ExitSteal		  ;yes ->

;-----------------------------------------
;* attempt to steal from TAB1 (lh) display
;-----------------------------------------

		test	TAB1.TAB_HAS_MOUSE,1	;does TAB1 have mouse?
		jz	@F			;no ->

;* mouse available if not required by TAB1, or TAB1 is switched off or damaged

		mov	al,TAB1.TAB_STATUS
		and	al,TAB1.TAB_REQ_MOUSE	;required and on?

		mov	bx,TAB1.TAB_SSF_PTR
		mov	ah,[bx]
		not	ah	    	;0ffh = ok, 0feh = damaged

		and	al,ah		;required and on and not damaged?

		jz	ContSteal	;no, steal mouse ->

		jmp	ExitSteal

;-----------------------------------------
;* attempt to steal from TAB2 (rh) display
;-----------------------------------------

@@:		test	TAB2.TAB_HAS_MOUSE,1	;does TAB2 have mouse?
		jz	ContSteal		;no ->

;* mouse available if not required by TAB2, or TAB2 is switched off or damaged

		mov	al,TAB2.TAB_STATUS
		and	al,TAB2.TAB_REQ_MOUSE	;required and on?

		mov	bx,TAB2.TAB_SSF_PTR
		mov	ah,[bx]
		not	ah	    	;0ffh = ok, 0feh = damaged

		and	al,ah		;required and on and not damaged?

		jz	ContSteal	;no, steal mouse ->

		jmp	ExitSteal

;-------------
;* steal mouse
;-------------

ContSteal:   	mov	NAVIG_MFD.MFD_HAS_MOUSE,1
		mov	TAB1.TAB_HAS_MOUSE,0
		mov	TAB2.TAB_HAS_MOUSE,0

ExitSteal:	pop	bx

		ret

StealMouse	ENDP

;----------------------------------------------------------------------------

;* SelectRadarMFD - set MFD to radar mode (wrt crew)
;*
;* pass: CrewMode
;* ret : nothing
;* kill: assume all

SelectRadarMFD	PROC	FAR

		mov	si,OFFSET PILOT_MFD	;assume pilot

		cmp	TAB2.TAB_MODE,TAB_FLIR
		je @F
		jmp Ouches
@@:		
		mov	si,OFFSET NAVIG_MFD
        mov	NAVIG_MFD.MFD_X_ORG,0
        mov	NAVIG_MFD.MFD_Y_ORG,0       
		mov	[si].MFD_MODE,MFD_RADAR
		ret
Ouches:
		cmp	CrewMode,CREW_PILOT	;pilot?
		je	@f

		mov	si,OFFSET NAVIG_MFD
mov	NAVIG_MFD.MFD_X_ORG,0
mov	NAVIG_MFD.MFD_Y_ORG,0
        
@@:		mov	[si].MFD_MODE,MFD_RADAR

		ret

SelectRadarMFD	ENDP

;----------------------------------------------------------------------------

;* SelectAutoMFD - set MFD to auto-pilot mode (wrt crew)
;*
;* pass: CrewMode
;* ret : nothing
;* kill: assume all

SelectAutoMFD	PROC	FAR

		mov	si,OFFSET PILOT_MFD	;assume pilot

		cmp	CrewMode,CREW_PILOT	;pilot?
		je	@f

		mov	si,OFFSET NAVIG_MFD

@@:		mov	[si].MFD_MODE,MFD_AUTO_PILOT

		ret

SelectAutoMFD	ENDP

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
		cmp	cx,MFD_WIDTH-1	;visible?
		ja	SkipPixel	;no ->

		add	bl,yrel
		cmp	bl,MFD_DEPTH-1	;visible?
		ja	SkipPixel	;no ->

		add	cx,XOrg
		add	bl,BYTE PTR YOrg

		mov	al,col

		call	SetPixel

SkipPixel:	pop	cx
		pop	bx

		ENDM

;----------------------------------------------------------------------------

;* MapDisp - moving map display
;*
;* pass: si -> MFD data block
;* ret : nothing
;* kill: assume all

MapDisp		PROC	NEAR

;-----------------
;* update map zoom
;-----------------

		call	UpdateMapZoom

;-------------------
;* update map origin
;-------------------

		KTEST	KF_MapOrigin	;map origin toggle?
		jz	@F		;no ->

		xor	[si].MFD_MAP_ORG,MAP_ORG_BASE

;----------
;* draw map
;----------

@@:		mov	ax,MAP_MFD_DISP
		mov	cx,[si].MFD_X_ORG
		mov	bl,[si].MFD_Y_ORG
		xor	bh,bh
		mov	dx,[si].MFD_MAP_ZOOM
		mov	bp,[si].MFD_MAP_ORG

		push	si
		mov	si,OFFSET M_VIEW
		call	UpdateMovingMap
		pop	si

;--------------------------
;* display current waypoint
;--------------------------

		mov	cx,CurrentWPX
		mov	bx,CurrentWPY

		cmp	cx,-1		;valid?
		je	@F		;no ->
		cmp	bx,-1		;valid?
		je	@F		;no ->

		push	si

		add	cx,XOrg
		add	bx,WORD PTR YOrg

		mov	si,WPPtr
		mov	dl,[si].WP_ID

		mov	al,COL_MAP_SYM

		call	CharSprite

		pop	si

;----------------
;* draw hdg datum (wrt origin)
;----------------

@@:		mov	cx,[si].MFD_X_ORG
		add	cx,XC
		mov	bl,[si].MFD_Y_ORG

		mov	dx,MFD_DEPTH/2	;assume MAP_ORG_BASE

		cmp	[si].MFD_MAP_ORG,MAP_ORG_BASE	;base origin?
		je	@F				;yes ->

		mov	dx,MFD_DEPTH/4

@@:		push	bx
		push	cx
		push	dx
		mov	al,COL_MAP_SYM
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
		mov	al,COL_MAP_SYM
		call	SetPixel
		pop	cx
		pop	bx
	
		add	cx,2

		mov	al,COL_MAP_SYM
		call	SetPixel

		ret

MapDisp		ENDP

;----------------------------------------------------------------------------

;* RadarDisp - ground / air radar displays
;*
;* pass: si -> MFD data block
;* ret : nothing
;* kill: assume all

RadarDisp	PROC	NEAR

		cmp	RadarMode,GND_RADAR	;ground mapping radar?
		jne	@F			;no, must be air radar ->

		call	GndMappingRadar

		ret

@@:		call	AirRadar

		ret

RadarDisp 	ENDP

;----------------------------------------------------------------------------

;* GndMappingRadar - ground mapping radar display
;*
;* pass: si -> MFD data block
;* ret : nothing
;* kill: assume all
;*
;* note: To use ground mapping radar:-
;*
;*       Use mouse x, y motion to move target designator cursor.
;*
;*	 Click lh mouse button to designate a target.
;*	 Click rh mouse button to cancel designation.
;*
;*	 Use CTRL key to zoom (step zoom):-
;*
;*	    CTRL key and click lh button to zoom in (decrease range).
;*	    CTRL key and click rh button to zoom out (increase range).
;*
;*	 It is not possible to designate outside of the active map area.

GndMappingRadar	PROC	NEAR

;-------------------------------------
;* test if within operating conditions
;-------------------------------------

		mov	al,1		;assume within operating conditions

		cmp	M_CosP,16384	;pitch in limits (+/-60degs)?
		jl	@F		;no ->

		cmp	WORD PTR M_VIEW.VP_ZFT_HI,0	;alt > 65535ft?
		ja	RadarOk			  	;yes ->

		cmp	WORD PTR M_VIEW.VP_ZFT_LO,50	;alt > 50ft?
		ja	RadarOk			  	;yes ->

@@:		xor	al,al

RadarOk:	mov	GMROk,al

;------------------
;* read mouse input
;------------------

		cmp	DisableInput,0	;input disabled?
		_JNE	ContGMRMap	;yes ->

		test QuieterCockpit,1 ;in cockpit
		jnz @F ;->yes
		jmp JumpOverHereMann
@@:		
		test	[si].MFD_HAS_MOUSE,1	;mouse available?
		_JZ	ContGMRMap		;no ->
JumpOverHereMann:
		call	ReadMouseMotion

;* note: al = 1 = lhs button pressed
;*       ah = 1 = rhs button pressed
;*       cx = XMickeys (-32768 .. 32767)
;*       bx = YMickeys (-32768 .. 32767)
;*       dl = 1 = lhs button just pressed
;*       dh = 1 = rhs button just pressed

;--------------------
;* update radar range
;--------------------

		test	Key[K_CTRL],1	;update range?
		jz	ContGMRDes	;no ->

		test	dl,dl		;zoom in (decrease range)?
		jnz	GMRDecRange	;yes ->

		test	dh,dh		;zoom out (increase range)?
		jnz	GMRIncRange	;yes ->

		jmp	GMRRangeOk

;* zoom in (decrease range)

GMRDecRange:	cmp	GMRRange,MAP_ZOOM6	;fully zoomed in? Hacked by Frankie
		je	GMRRangeOk		;yes ->

		add	GMRRange,2	;decrease range

		jmp	GMRRangeOk

;* zoom out (increase range)

GMRIncRange:   	cmp	GMRRange,MAP_ZOOM1	;fully zoomed out?
		je	GMRRangeOk 	 	;yes ->

		sub	GMRRange,2	;increase range

;* reset mouse buttons

GMRRangeOk:	xor	ax,ax
		xor	dx,dx

;------------------------------------------
;* update target designator cursor position
;------------------------------------------

ContGMRDes:	test	GMROk,1		;radar ok?
		_JZ	ContGMRMap	;no, skip designation ->

		push	dx		;store button status

		SBOUND	cx,-127,127  	;limit motion
		SBOUND	bx,-127,127

		REPT	6		;scale motion
		sal	cx,1
		sal	bx,1
		ENDM

		add	cx,CrsrXv
		SBOUND	cx,0,CRSR_XV_MAX-1

		add	bx,CrsrYv
		SBOUND	bx,0,CRSR_YV_MAX-1

;* keep cursor from straying under mask

		cmp	bx,CRSR_YMIN*256	;y >= min y?
		jae	@F			;yes ->
		mov	bx,CRSR_YMIN*256

@@:		cmp	bx,(CRSR_YMAX*256)+255	;y <= max y?
		jbe	@F  			;yes ->
		mov	bx,(CRSR_YMAX*256)+255

@@:		mov	al,bh		;calc x limits index
		xor	ah,ah
		shl	ax,1
		mov	si,ax

		mov	ah,CrsrXLimits[si+0]	;x left limit
		xor	al,al

		cmp	cx,ax		;x >= min x?
		jae	@F		;yes ->
		mov	cx,ax

@@: 		mov	ah,CrsrXLimits[si+1]	;x right limit
		mov	al,255

		cmp	cx,ax
		jbe	@F
		mov	cx,ax

@@:		mov	CrsrXv,cx
		mov	CrsrYv,bx

		pop	dx		;restore button status

;---------------------------
;* test for cancel designate
;---------------------------

		test	dh,dh		;rh mouse button just pressed?
		jz	@F		;no ->

		call	CancelTgtWP

		jmp	ContGMRMap

;---------------------------
;* test for target designate
;---------------------------

@@:		test	dl,dl		;lh mouse button just pressed?
		_JZ	ContGMRMap	;no ->

;* make working copy of aircraft viewpoint

		COPY_VP	TMP_VIEW,M_VIEW

;* x radar = ((CrsrXv AND 0ff00h) - CRSR_XV_MAX / 2) * 0.8 (aspect ratio correction)

		mov	ax,CrsrXv
		and	ax,0ff00h	;round to pixel
		sub	ax,(CRSR_XV_MAX/2)

		mov	dx,26214	;aspect ratio correction (x * 0.8)
		imul	dx
		FRACADJ	si		;x radar

;* y radar = CRSR_YV_MAX - 1 - (CrsrYv and 0ff00h) - 256 (y adjust)
;*
;* Note: "y adjust" value is required to compensate for display y centre
;*        differences between co-ordinate systems.

		mov	di,(CRSR_YV_MAX-1)
		mov	ax,CrsrYv
		and	ax,0ff00h	;round to pixel
		sub	di,ax	
		sub	di,256		;y radar

;* delta yft = (y radar * cos(hdg) - x radar * sin(hdg)) * scale wrt zoom

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

;* delta xft = (x radar * cos(hdg) + y radar * sin(hdg)) * scale wrt zoom

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

;* sort scaling wrt range

		mov	bp,GMRRange	;0 .. 10
		shr	bp,1		;0 .. 5

		add	bp,13		;13 .. 18

@@:		sar	dx,1
		rcr	ax,1

		sar	cx,1
		rcr	bx,1

		dec	bp
		jnz	@B

		mov	si,OFFSET TMP_VIEW
		call	MoveViewpoint

;* "snap to object" (if on active map and any available)

		cmp	TMP_VIEW.VP_XSEC,31	;on active map?
		ja	ContGMRMap		;no, ignore ->
		cmp	TMP_VIEW.VP_YSEC,31	;on active map?
		ja	ContGMRMap		;no, ignore ->

		call	SnapStatic
		jc	@F		;snapped ->

		call	SnapMobile

;* set floating waypoint 

@@:		mov	ax,TMP_VIEW.VP_XSEC
		mov	FloatWP.WP_XSEC,ax

		mov	ax,TMP_VIEW.VP_YSEC
		mov	FloatWP.WP_YSEC,ax
		
		mov	ax,TMP_VIEW.VP_XFT
		mov	FloatWP.WP_XFT,ax

		mov	ax,TMP_VIEW.VP_YFT
		mov	FloatWP.WP_YFT,ax

		or	FloatWP.WP_ATTR,WP_VALID

		call	UpdateTgtWP		;tell AutoRoute
		
;-----------------
;* draw moving map (base origin, modified colours)
;-----------------				  

;* modify map colours

ContGMRMap:	call	SetGMRPalette

;* draw map and radar image

		mov	ax,MAP_MFD_DISP
		mov	cx,XOrg
		mov	bl,YOrg
		mov	bh,GMROk
		mov	dx,GMRRange
		mov	bp,MAP_ORG_BASE

		mov	si,OFFSET M_VIEW
		call	UpdateMovingMap

;* restore map colours

		call	FixGMRPalette

;----------------------------------------
;* draw flashing floating waypoint cursor (if valid)
;----------------------------------------

		mov	cx,FloatWPX
		mov	bx,FloatWPY

		cmp	cx,-1		;x valid?
		_JE	SkipWPCursor	;no ->
		cmp	bx,-1		;y valid?
		_JE	SkipWPCursor	;no ->

;* update flash timer

		mov	ax,GMRFlashTimer
		sub	ax,LastFrame	;time up?
		jnc	FlashOk		;no ->

;* toggle colour

		mov	al,GMR_FLASH_HI

		cmp	GMRFlashCol,al
		jne	@F

		mov	al,GMR_FLASH_LO

@@:		mov	GMRFlashCol,al

		mov	ax,GMR_FLASH_DELAY

FlashOk:  	mov	GMRFlashTimer,ax

		PLOTSYM	 0, -3, GMRFlashCol
		PLOTSYM	 0, -2, GMRFlashCol
		PLOTSYM	 0,  2, GMRFlashCol
		PLOTSYM	 0,  3, GMRFlashCol
		PLOTSYM	-3,  0, GMRFlashCol
		PLOTSYM	-2,  0, GMRFlashCol
		PLOTSYM	 2,  0, GMRFlashCol
		PLOTSYM	 3,  0, GMRFlashCol

;------------------------
;* draw designator cursor
;------------------------

SkipWPCursor:	test	GMROk,1		;radar ok?
		_JZ	SkipTgtCursor	;no ->

		mov	cx,CrsrXv
		mov	bx,CrsrYv

		mov	cl,ch
		xor	ch,ch
		mov	bl,bh

		PLOTSYM	 0, -2, COL_CRT16
		PLOTSYM	 0, -1, COL_CRT16
		PLOTSYM	 0,  1, COL_CRT16
		PLOTSYM	 0,  2, COL_CRT16
		PLOTSYM	-2,  0, COL_CRT16
		PLOTSYM	-1,  0, COL_CRT16
		PLOTSYM	 1,  0, COL_CRT16
		PLOTSYM	 2,  0, COL_CRT16

;----------------------
;* draw radar scan mask
;----------------------

SkipTgtCursor:	call	DrawRadarMask

		ret

GndMappingRadar	ENDP

;----------------------------------------------------------------------------

;* SnapStatic - snap to static mobile (if available)
;*
;* pass: TMP_VIEW <> (must be on active map)
;* ret : cf = 0: no snap
;*       cf = 1: snapped (TMP_VIEW <> modified)
;* kill: assume all (except cf)

SnapStatic	PROC	NEAR

;-------------------------------------
;* calc map index = x sec + y sec * 32
;-------------------------------------

		mov	bp,TMP_VIEW.VP_YSEC

		REPT	5
		shl	bp,1
		ENDM

		add	bp,TMP_VIEW.VP_XSEC

;--------------------------
;* test for occupied sector
;--------------------------

		mov	bl,MobileLayer1[bp]

		test	bl,bl		;occupied sector?
		jz	FailSnapStatic	;no ->

;------------------------------------
;* calc pointer to sector data record
;------------------------------------

		xor	bh,bh
		shl	bx,1		;*2 word index

		mov	si,MobSectorTable[bx]

;------------------
;* sort search area
;------------------

		mov	bx,GMRRange

		mov	bp,SnapSearchArea[bx]

;------------------
;* scan object list (search for nearest static within search area)
;------------------

		mov	di,65535  	;set previous best to worst case

ScanStatLoop:	mov	ax,MSECDATA1
		mov	es,ax

		mov	dl,ES:STAT_NUM[si]
		mov	dh,ES:STAT_ANIM[si]
		mov	cx,ES:STAT_XFT[si]
		mov	bx,ES:STAT_YFT[si]

		mov	ax,DATA
		mov	es,ax

		cmp	dl,-1		;end of list?
		je	ScanStatDone	;yes ->

		test	dh,OBJECT_DEAD	;dead?
		jnz	SkipStatic	;yes ->

		mov	ax,TMP_VIEW.VP_XFT
		sub	ax,cx
		ABSV	ax		;abs(delta xft)

		mov	dx,TMP_VIEW.VP_YFT
		sub	dx,bx
		jns	@F
		neg	dx		;abs(delta yft)

@@:		cmp	ax,dx		;max(delta xft, delta yft)
		jae	@F
 		mov	ax,dx

@@:		cmp	ax,bp		;within search area?
		ja	SkipStatic	;no ->

		cmp	ax,di		;nearer than previous object?
		jae	SkipStatic	;no ->

		mov	SnapX,cx
		mov	SnapY,bx

		mov	di,ax		;new best

SkipStatic:	add	si,STAT_REC_SIZE

		jmp	ScanStatLoop

ScanStatDone:	cmp	di,65535	;snapped ok?
		je	FailSnapStatic	;no ->

PassSnapStatic:	mov	cx,SnapX
		mov	bx,SnapY

		mov	TMP_VIEW.VP_XFT,cx
		mov	TMP_VIEW.VP_YFT,bx

		stc			;cf = 1

		ret

FailSnapStatic:	clc			;cf = 0
		
		ret

SnapStatic	ENDP

;----------------------------------------------------------------------------

;* SnapMobile - snap to mobile (if available)
;*
;* pass: TMP_VIEW <>
;* ret : cf = 0: no snap
;*       cf = 1: snapped (TMP_VIEW <> modified)
;* kill: assume all (except cf)

SnapMobile	PROC	NEAR

;--------------------------
;* test for occupied sector
;--------------------------

		mov	ax,TMP_VIEW.VP_XSEC
		mov	dx,TMP_VIEW.VP_YSEC

		call	LocateMobiles	;mobiles in sector?
		jc	FailSnapMobile	;no ->

;------------------
;* sort search area
;------------------

		mov	bx,GMRRange

		mov	bp,SnapSearchArea[bx]

;------------------
;* scan object list (search for nearest mobile within search area)
;------------------

		mov	di,65535 	;set previous best to worst case

ScanMobLoop:	cmp	si,-1		;end of list?
		je	ScanMobDone	;yes ->

		cmp	si,OFFSET M_MOBILE	;Tornado?
		je	SkipMobile		;yes ->

;* only allow mobiles whose zft <= 50ft (still see vehicles on bridges)

		cmp	WORD PTR _VP_ZFT_HI[si],0	;alt > 65535ft?
		ja	SkipMobile     			;yes ->

		cmp	WORD PTR _VP_ZFT_LO[si],50	;alt <= 50ft?
		ja	SkipMobile 	    		;no ->

		mov	cx,_VP_XFT[si]
		mov	bx,_VP_YFT[si]

		mov	ax,TMP_VIEW.VP_XFT
		sub	ax,cx
		ABSV	ax		;abs(delta xft)

		mov	dx,TMP_VIEW.VP_YFT
		sub	dx,bx
		jns	@F
		neg	dx		;abs(delta yft)

@@:		cmp	ax,dx		;max(delta xft, delta yft)
		jae	@F
 		mov	ax,dx

@@:		cmp	ax,bp		;within search area?
		ja	SkipMobile	;no ->

		cmp	ax,di		;nearer than previous object?
		jae	SkipMobile	;no ->

		mov	SnapX,cx
		mov	SnapY,bx

		mov	di,ax		;new best

SkipMobile: 	mov	si,MOB_LINK_PTR[si]

		jmp	ScanMobLoop

ScanMobDone:	cmp	di,65535	;snapped ok?
		je	FailSnapMobile	;no ->

PassSnapMobile:	mov	cx,SnapX
		mov	bx,SnapY

		mov	TMP_VIEW.VP_XFT,cx
		mov	TMP_VIEW.VP_YFT,bx

		stc			;cf = 1

		ret

FailSnapMobile:	clc			;cf = 0
		
		ret

SnapMobile	ENDP

;----------------------------------------------------------------------------

;* DrawRadarMask
;*
;* pass: XOrg
;*	 YOrg
;* ret : nothing
;* kill: assume all

DrawRadarMask	PROC	NEAR

;* top lh corner mask

		mov	ax,XOrg
		mov	dx,ax
		add	dx,17
		mov	PolyX1,ax
		mov	PolyX2,dx
		mov	PolyX3,ax
		mov	PolyX4,ax

		mov	ax,WORD PTR YOrg
		mov	dx,ax
		add	dx,17
		mov	PolyY1,ax
		mov	PolyY2,ax
		mov	PolyY3,dx
		mov	PolyY4,ax

		mov	al,COL_RADAR_MASK
		mov	si,OFFSET RadarMaskPoly
		call	PolyFill

;* top rh corner mask

		mov	ax,XOrg
		mov	dx,ax
		add	ax,46
		add	dx,63
		mov	PolyX1,ax
		mov	PolyX2,dx
		mov	PolyX3,dx
		mov	PolyX4,ax

		mov	ax,WORD PTR YOrg
		mov	dx,ax
		add	dx,17
		mov	PolyY1,ax
		mov	PolyY2,ax
		mov	PolyY3,dx
		mov	PolyY4,ax

		mov	al,COL_RADAR_MASK
		mov	si,OFFSET RadarMaskPoly
		call	PolyFill

;* bottom rh corner mask

		mov	ax,XOrg
		mov	dx,ax
		add	ax,63
		add	dx,43
		mov	PolyX1,ax
		mov	PolyX2,ax
		mov	PolyX3,dx
		mov	PolyX4,ax

		mov	ax,WORD PTR YOrg
		mov	dx,ax
		add	ax,27
		add	dx,47
		mov	PolyY1,ax
		mov	PolyY2,dx
		mov	PolyY3,dx
		mov	PolyY4,ax

		mov	al,COL_RADAR_MASK
		mov	si,OFFSET RadarMaskPoly
		call	PolyFill

;* bottom lh corner mask

		mov	ax,XOrg
		mov	dx,ax
		add	dx,20
		mov	PolyX1,ax
		mov	PolyX2,dx
		mov	PolyX3,ax
		mov	PolyX4,ax

		mov	ax,WORD PTR YOrg
		mov	dx,ax
		add	ax,27
		add	dx,47
		mov	PolyY1,ax
		mov	PolyY2,dx
		mov	PolyY3,dx
		mov	PolyY4,ax

		mov	al,COL_RADAR_MASK
		mov	si,OFFSET RadarMaskPoly
		call	PolyFill

;* top line

		mov	cx,XOrg
		mov	dx,cx
		add	cx,18
		add	dx,45
		mov	bl,YOrg

		mov	al,COL_RADAR_MASK
		call	HLineDraw

;* bottom line

		mov	cx,XOrg
		mov	dx,cx
		add	cx,21
		add	dx,42
		mov	bl,YOrg
		add	bl,47

		mov	al,COL_RADAR_MASK
		call	HLineDraw

;* top lh fillet

		mov	cx,XOrg
		mov	dx,cx
		add	cx,17
		add	dx,19
		mov	bl,YOrg
		add	bl,1

		mov	al,COL_RADAR_MASK
		call	HLineDraw

		mov	cx,XOrg
		add	cx,16
		mov	bl,YOrg
		add	bl,2

		mov	al,COL_RADAR_MASK
		call	SetPixel

		mov	cx,XOrg
		add	cx,17
		mov	bl,YOrg
		add	bl,2

		mov	al,COL_RADAR_MASK
		call	SetPixel

		mov	cx,XOrg
		add	cx,15
		mov	bl,YOrg
		add	bl,3

		mov	al,COL_RADAR_MASK
		call	SetPixel

;* top rh fillet

		mov	cx,XOrg
		mov	dx,cx
		add	cx,44
		add	dx,46
		mov	bl,YOrg
		add	bl,1

		mov	al,COL_RADAR_MASK
		call	HLineDraw

		mov	cx,XOrg
		add	cx,46
		mov	bl,YOrg
		add	bl,2

		mov	al,COL_RADAR_MASK
		call	SetPixel

		mov	cx,XOrg
		add	cx,47
		mov	bl,YOrg
		add	bl,2

		mov	al,COL_RADAR_MASK
		call	SetPixel

		mov	cx,XOrg
		add	cx,48
		mov	bl,YOrg
		add	bl,3

		mov	al,COL_RADAR_MASK
		call	SetPixel

;* lh fillet

		mov	bl,YOrg
		mov	bh,bl
		add	bl,18
		add	bh,26
		mov	cx,XOrg

		mov	al,COL_RADAR_MASK
		call	VLineDraw

		mov	bl,YOrg
		mov	bh,bl
		add	bl,17
		add	bh,27
		mov	cx,XOrg
		add	cx,1

		mov	al,COL_RADAR_MASK
		call	VLineDraw

		mov	bl,YOrg
		mov	bh,bl
		add	bl,16
		add	bh,21
		mov	cx,XOrg
		add	cx,2

		mov	al,COL_RADAR_MASK
		call	VLineDraw

		mov	bl,YOrg
		mov	bh,bl
		add	bl,15
		add	bh,17
		mov	cx,XOrg
		add	cx,3

		mov	al,COL_RADAR_MASK
		call	VLineDraw

		mov	bl,YOrg
		add	bl,14
		mov	cx,XOrg
		add	cx,4

		mov	al,COL_RADAR_MASK
		call	SetPixel

;* rh fillet

		mov	bl,YOrg
		mov	bh,bl
		add	bl,18
		add	bh,26
		mov	cx,XOrg
		add	cx,63

		mov	al,COL_RADAR_MASK
		call	VLineDraw

		mov	bl,YOrg
		mov	bh,bl
		add	bl,17
		add	bh,27
		mov	cx,XOrg
		add	cx,62

		mov	al,COL_RADAR_MASK
		call	VLineDraw

		mov	bl,YOrg
		mov	bh,bl
		add	bl,16
		add	bh,21
		mov	cx,XOrg
		add	cx,61

		mov	al,COL_RADAR_MASK
		call	VLineDraw

		mov	bl,YOrg
		mov	bh,bl
		add	bl,15
		add	bh,17
		mov	cx,XOrg
		add	cx,60

		mov	al,COL_RADAR_MASK
		call	VLineDraw

		mov	bl,YOrg
		add	bl,14
		mov	cx,XOrg
		add	cx,59

		mov	al,COL_RADAR_MASK
		call	SetPixel

		ret

DrawRadarMask	ENDP

;----------------------------------------------------------------------------

;* AirRadar
;*
;* pass: si -> MFD data block
;* ret : nothing
;* kill: assume all
;*
;* note: To use air radar:-
;*
;*       Use mouse x, y motion to move target designator cursor.
;*
;*	 Click lh mouse button to designate a target.
;*	 Click rh mouse button to cancel designation.
;*
;*	 Use CTRL key to zoom (step zoom):-
;*
;*	    CTRL key and click lh button to decrease radar range.
;*	    CTRL key and click rh button to increase radar range.
;*
;*	 Use CAPS LOCK key for "bore sight" designation.

AirRadar	PROC	NEAR

;------------------
;* read mouse input
;------------------

		cmp	DisableInput,0	;input disabled?
		_JNE	ContAirRadar	;yes ->

		test QuieterCockpit,1 ;in cockpit
		jnz @F ;->yes
		jmp LompatOverHereMan
@@:		
		test	[si].MFD_HAS_MOUSE,1	;mouse available?
		_JZ	ContAirRadar		;no ->
LompatOverHereMan:
		call	ReadMouseMotion

;* note: al = 1 = lhs button pressed
;*       ah = 1 = rhs button pressed
;*       cx = XMickeys (-32768 .. 32767)
;*       bx = YMickeys (-32768 .. 32767)
;*       dl = 1 = lhs button just pressed
;*       dh = 1 = rhs button just pressed

;--------------------
;* update radar range
;--------------------

;* range allowed wrt variant:-
;*
;* IDS = ARAD_MIN_RANGE .. ARAD_MED_RANGE
;* ECR = ARAD_MIN_RANGE .. ARAD_MED_RANGE
;* ADV = ARAD_MIN_RANGE .. ARAD_MAX_RANGE

		test	Key[K_CTRL],1	;update range?
		jz	SkipRadRange	;no ->

		test	dl,dl		;decrease range?
		jnz	DecRadRange	;yes ->

		test	dh,dh		;increase range?
		jnz	IncRadRange	;yes ->

		jmp	RadRangeOk

;* decrease range

DecRadRange:	cmp	AirRadarRng,ARAD_MIN_RANGE	;min range?
		je	RadRangeOk			;yes ->

		sub	AirRadarRng,2  	;decrease range

		jmp	RadRangeOk

;* increase range

IncRadRange:   	mov	bp,ARAD_MAX_RANGE	;assume ADV

		cmp	TornadoType,ADV_TORNADO	;ADV?
		je	@F			;yes ->

		mov	bp,ARAD_MED_RANGE

@@:		cmp	AirRadarRng,bp	;max range (wrt variant)?
		je	RadRangeOk	;yes ->

		add	AirRadarRng,2	;increase range

;* reset mouse buttons

RadRangeOk:	xor	ax,ax
		xor	dx,dx

;------------------------------------------
;* update target designator cursor position
;------------------------------------------

SkipRadRange:	push	dx		;store button status

		SBOUND	cx,-127,127  	;limit motion
		SBOUND	bx,-127,127

		REPT	6		;scale motion
		sal	cx,1
		sal	bx,1
		ENDM

		add	cx,CrsrXv
		SBOUND	cx,0,CRSR_XV_MAX-1

		add	bx,CrsrYv
		SBOUND	bx,0,CRSR_YV_MAX-1

;* keep cursor from straying under mask

		cmp	bx,CRSR_YMIN*256	;y >= min y?
		jae	@F			;yes ->
		mov	bx,CRSR_YMIN*256

@@:		cmp	bx,(CRSR_YMAX*256)+255	;y <= max y?
		jbe	@F  			;yes ->
		mov	bx,(CRSR_YMAX*256)+255

@@:		mov	al,bh		;calc x limits index
		xor	ah,ah
		shl	ax,1
		mov	si,ax

		mov	ah,CrsrXLimits[si+0]	;x left limit
		xor	al,al

		cmp	cx,ax		;x >= min x?
		jae	@F		;yes ->
		mov	cx,ax

@@: 		mov	ah,CrsrXLimits[si+1]	;x right limit
		mov	al,255

		cmp	cx,ax
		jbe	@F
		mov	cx,ax

@@:		mov	CrsrXv,cx
		mov	CrsrYv,bx

		pop	dx		;restore button status

;---------------------------
;* test for cancel designate
;---------------------------

		test	dh,dh		;rh mouse button just pressed?
		jz	@F		;no ->

		mov	AirTgtPtr,-1	;cancel designation

		jmp	ContAirRadar

;---------------------------
;* test for target designate
;---------------------------

@@:		test	dl,dl		;lh mouse button just pressed?
		jz	ContAirRadar	;no ->

;* search for exact x, y crt match

		mov	cx,NumRadarTracks

		jcxz	ContAirRadar	;no tracks ->

		mov	si,OFFSET AirRadarTracks

		mov	bx,CrsrXv
		mov	bl,bh
		xor	bh,bh
		mov	dx,CrsrYv
		mov	dl,dh
		xor	dh,dh

AirTgtLoop1:	mov	di,[si].ARAD_PTR
		cmp	_DRONE_SIDE[di],ENEMY	;enemy target?
		jne	@F			;no ->

		cmp	bx,[si].ARAD_XCRT	;x crt match?
		jne	@F			;no ->
		cmp	dx,[si].ARAD_YCRT	;y crt match?
		je	SetAirTgt		;yes ->

@@:		add	si,ARAD_REC_SIZE

		loop	AirTgtLoop1

;* extend search (allow ñ1 pixel error)

		mov	cx,NumRadarTracks

		mov	si,OFFSET AirRadarTracks

AirTgtLoop2:	mov	di,[si].ARAD_PTR
		cmp	_DRONE_SIDE[di],ENEMY	;enemy target?
		jne	@F			;no ->
		
		mov	ax,[si].ARAD_XCRT
		sub	ax,bx
		cmp	ax,1 		;> 1 pixel error?
		jg	@F   		;yes ->
		cmp	ax,-1		;> 1 pixel error?
		jl	@F		;yes ->

		mov	ax,[si].ARAD_YCRT
		sub	ax,dx
		cmp	ax,1 		;> 1 pixel error?
		jg	@F   		;yes ->
		cmp	ax,-1		;> 1 pixel error?
		jge	SetAirTgt	;no ->

@@:		add	si,ARAD_REC_SIZE

		loop	AirTgtLoop2

		jmp	ContAirRadar

SetAirTgt:	mov	AirTgtPtr,di

;-----------------------
;* draw radar background
;-----------------------

ContAirRadar:	call	DrawRadarNoise

;------------------
;* draw range scale
;------------------

		mov	si,AirRadarRng

		mov	bx,AirRadYStart[si]
		mov	bp,AirRadYCount[si]
		mov	di,AirRadYStep[si]

		add	bx,WORD PTR YOrg

		mov	cx,XOrg
		add	cx,(MFD_WIDTH/2)-1
		mov	dx,cx
		inc	dx

@@:		push	bx
		push	cx
		push	dx
		push	di
		push	bp

		mov	al,COL_CRT14
		call	HLineDraw

		pop	bp
		pop	di
		pop	dx
		pop	cx
		pop	bx

		add	bx,di

		dec	bp
		jnz	@B

;-----------------------
;* plot mobiles on radar
;-----------------------

		mov	cx,NumRadarTracks

		jcxz	NoTracks	;no tracks ->

		mov	si,OFFSET AirRadarTracks

		mov	di,-1		;assume no target designated

		mov	TgtCol,COL_CRT16

PlotMobLoop:	mov	ax,[si].ARAD_PTR
		cmp	ax,AirTgtPtr	;designated target?
		jne	@F		;no ->

		mov	di,si

		jmp	PlotNextMob

@@:		push	cx
		push	si
		push	di

		mov	cx,[si].ARAD_XCRT
		mov	bx,[si].ARAD_YCRT
		mov	si,[si].ARAD_PTR

		call	DrawMobSymbol

		pop	di
		pop	si
		pop	cx

PlotNextMob:	add	si,ARAD_REC_SIZE

		loop	PlotMobLoop

;* flash designated target (draw last so that it is always visible)

		cmp	di,-1		;target designated?
		je	NoTracks	;no ->

		mov	ax,TgtFlashTimer
		sub	ax,LastFrame	;time up?
		jnc	TgtFlashOk 	;no ->

		mov	al,TGT_FLASH_HI

		cmp	TgtFlashCol,al
		jne	@F

		mov	al,TGT_FLASH_LO

@@:		mov	TgtFlashCol,al

		mov	ax,TGT_FLASH_DELAY

TgtFlashOk:  	mov	TgtFlashTimer,ax

		mov	al,TgtFlashCol

		mov	TgtCol,al

		mov	cx,[di].ARAD_XCRT
		mov	bx,[di].ARAD_YCRT
		mov	si,[di].ARAD_PTR

		call	DrawMobSymbol

;------------------------
;* draw designator cursor
;------------------------

NoTracks:	mov	cx,CrsrXv
		mov	bx,CrsrYv

		mov	cl,ch
		xor	ch,ch
		mov	bl,bh

		PLOTSYM	 0, -2, COL_CRT16
		PLOTSYM	 0, -1, COL_CRT16
		PLOTSYM	 0,  1, COL_CRT16
		PLOTSYM	 0,  2, COL_CRT16
		PLOTSYM	-2,  0, COL_CRT16
		PLOTSYM	-1,  0, COL_CRT16
		PLOTSYM	 1,  0, COL_CRT16
		PLOTSYM	 2,  0, COL_CRT16

;----------------------
;* draw radar scan mask
;----------------------

		call	DrawRadarMask

		ret

AirRadar	ENDP

;----------------------------------------------------------------------------

;* DrawMobSymbol
;*
;* pass: cx = symbol centre x
;*       bl = symbol centre y
;*       si -> MOBILE + VIEWPOINT + control data
;*	 TgtCol
;* ret : nothing
;* kill: assume all

DrawMobSymbol	PROC	NEAR

		cmp	_DRONE_SIDE[si],ENEMY	;enemy?
		_JE	DrawMobEnemy		;yes ->

;---------------------------
DrawMobAllied	LABEL	NEAR
;---------------------------

		PLOTSYM	-1, -1, TgtCol
		PLOTSYM	 1, -1, TgtCol
		PLOTSYM	 1,  1, TgtCol
		PLOTSYM	-1,  1, TgtCol
		PLOTSYM	 0,  0, TgtCol

		jmp	ExitMobSymbol

;---------------------------
DrawMobEnemy	LABEL	NEAR
;---------------------------

		PLOTSYM	-1, -1, TgtCol
		PLOTSYM	 0, -1, TgtCol
		PLOTSYM	 1, -1, TgtCol
		PLOTSYM	-1,  0, TgtCol
		PLOTSYM	 1,  0, TgtCol
		PLOTSYM	-1,  1, TgtCol
		PLOTSYM	 0,  1, TgtCol
		PLOTSYM	 1,  1, TgtCol

ExitMobSymbol:	ret

DrawMobSymbol	ENDP

;----------------------------------------------------------------------------

;* AutoPilotDisp - auto-pilot display
;*
;* pass: si -> MFD data block
;* ret : nothing
;* kill: assume all

AutoPilotDisp	PROC	NEAR

;------------
;* initialize
;------------

		mov	al,'-'
		mov	ah,' '

		mov	Alt$[0],al
		mov	Alt$[1],al
		mov	Alt$[2],al
		mov	Alt$[3],al
		mov	Alt$[4],al

		mov	Hdg$[0],ah
		mov	Hdg$[1],ah
		mov	Hdg$[2],al
		mov	Hdg$[3],al
		mov	Hdg$[4],al

		mov	IAS$[0],ah
		mov	IAS$[1],ah
		mov	IAS$[2],al
		mov	IAS$[3],al
		mov	IAS$[4],al

;--------------------
;* sort auto-throttle
;--------------------

		cmp	AutoMode,AUTO_OFF	;off?
		jne	@F			;no ->

		test	AutoThrot,1		;manual or auto throttle?
		jz	@F			;manual ->

		mov	ModePtr,OFFSET AutoThrottle$

		mov	AltPtr,OFFSET Manual$
		mov	HdgPtr,OFFSET Manual$
		mov	IASPtr,OFFSET Acquire$

		mov	ax,AutoVias
		mov	di,OFFSET IAS$
		call	DecWord$

		jmp	ContAutoDisp

@@:		mov	IASPtr,OFFSET Auto$	;assume approach

		cmp	AutoMode,AUTO_APPROACH	;approach?
		je	SortAutoMode	     	;yes ->

		mov	IASPtr,OFFSET Manual$	;assume manual

		test	AutoThrot,1		;manual or auto throttle?
		jz	SortAutoMode		;manual ->

		mov	IASPtr,OFFSET Acquire$

		mov	ax,AutoVias
		mov	di,OFFSET IAS$
		call	DecWord$

;----------------------
;* sort auto-pilot mode
;----------------------

SortAutoMode:	mov	bx,AutoMode
		mov	ax,AutoTitle$[bx]
		mov	ModePtr,ax

		call	SortAlt$
		call	SortHdg$

;--------------------
;* print AFDS display
;--------------------

ContAutoDisp:	call	ClearDisp

;* underline and overline title

		mov	bl,MFD_Y_ORG[si]
		add	bl,2
		mov	cx,MFD_X_ORG[si]
		mov	dx,cx
		add	dx,MFD_WIDTH-1
		add	cx,4
		sub	dx,4
		mov	al,COL_CRT6

		push	bx
		push	cx
		push	dx
		call	HLineDraw
		pop	dx
		pop	cx
		pop	bx

		mov	al,COL_CRT6
		add	bl,8
		call	HLineDraw

;* print text

		mov	si,OFFSET AFDS$
		call	Print$

;* sort approach "time to go"

		cmp	AutoMode,AUTO_APPROACH	;approach?
		jne	SkipApprTTG		;no ->

		mov	si,OFFSET TTG$
		call	Print$

		mov	si,OFFSET TTGInvalid$	;assume invalid

		test	ILSActive,1		;ILS active?
		jz	@F			;no ->

		mov	si,OFFSET TTGApproach$

@@:		call	Print$

		jmp	ExitAutoDisp

;* sort waypoint ID for track mode (cannot select track mode if no waypoints)

SkipApprTTG: 	cmp	AutoMode,AUTO_TRACK	;track mode?
		_JNE	ExitAutoDisp		;no ->

		mov	ax,XOrg
		add	ax,13*4
		mov	PrtCl,ax

		mov	ax,WORD PTR YOrg
		add	ax,4
		mov	PrtLn,ax

		mov	si,WPPtr
		mov	al,[si].WP_ID
		call	PrintChar

;* sort track "time to go"

		mov	si,OFFSET TTG$
		call	Print$

		mov	si,OFFSET TTGInvalid$	;assume invalid

		cmp	WPETA,-1		;TTG valid?
		je	@F			;no ->

		mov	si,OFFSET TTGTrack$

@@:	    	call	Print$

;* sort track "time early / late"

		mov	si,OFFSET TEL$
		call	Print$

		mov	ax,WPTimeEarlyLate

		cmp	ax,-32768 	;TEL valid?
		jne	@F		;yes ->

		mov	si,OFFSET TELInvalid$
		call	Print$

		jmp	ExitAutoDisp

@@:		ABSV	ax		;calc display value
		xor	dx,dx
		mov	bx,100
		div	bx
		mov	WPTEL,ax

		mov	si,OFFSET TELValid$
		call	Print$

		cmp	WPTEL,0		;on time (according to display value)?
		je	ExitAutoDisp	;yes ->

		mov	si,OFFSET Early$	;assume early

		cmp	WPTimeEarlyLate,0	;early?
		jge	@F			;yes ->

		mov	si,OFFSET Late$

@@:		call	Print$

ExitAutoDisp:	ret

AutoPilotDisp 	ENDP

;----------------------------------------------------------------------------

;* SortAlt$ - sort altitude authority text
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

SortAlt$	PROC	NEAR

		mov	bx,AltMode
		jmp	AltSwitch[bx]

;---------------------------
AltManual	LABEL	NEAR
;---------------------------
		
		mov	AltPtr,OFFSET Manual$

		jmp	ExitAlt$

;---------------------------
AltApproach	LABEL	NEAR
;---------------------------

		mov	AltPtr,OFFSET Auto$
		
		jmp	ExitAlt$

;---------------------------
AltAcquire	LABEL	NEAR
;---------------------------
		
		mov	AltPtr,OFFSET Acquire$

		mov	ax,AutoAlt

		mov	di,OFFSET Alt$	;assume zero

		test	ax,ax		;zero?
		jz	@F		;yes (avoid printing "00") ->

		mov	BYTE PTR Alt$[4],'0'

		dec	di

@@:		call	DecWord$

		jmp	ExitAlt$

;---------------------------
AltTF		LABEL	NEAR
;---------------------------
		
		mov	AltPtr,OFFSET Ride$

		mov	ax,TFRideAlt
		mov	di,OFFSET Alt$
		call	DecWord$

ExitAlt$:	ret

SortAlt$	ENDP

;----------------------------------------------------------------------------

;* SortHdg$ - sort heading authority text
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

SortHdg$	PROC	NEAR

		mov	bx,HdgMode
		jmp	HdgSwitch[bx]

;---------------------------
HdgManual	LABEL	NEAR
;---------------------------

		mov	HdgPtr,OFFSET Manual$

		jmp	ExitHdg$

;---------------------------
HdgApproach	LABEL	NEAR
;---------------------------

		mov	HdgPtr,OFFSET Auto$

		jmp	ExitHdg$

;---------------------------
HdgAcquire	LABEL	NEAR
;---------------------------

		mov	HdgPtr,OFFSET Acquire$

		mov	ax,AutoHdg
		mov	dx,AutoHdgFine
		shl	dx,1
		ROUNDUP	ax
		jnz	@F

		mov	ax,360		;display 0 as 360

@@:		mov	di,OFFSET Hdg$
		call	DecWord$

		jmp	ExitHdg$

;---------------------------
HdgTrack	LABEL	NEAR
;---------------------------

		mov	HdgPtr,OFFSET Auto$

ExitHdg$:	ret

SortHdg$	ENDP

;----------------------------------------------------------------------------

;* ILSDisp - ILS display
;*
;* pass: si -> MFD data block
;* ret : nothing
;* kill: assume all
;*
;* note: Do not use XC and YC co-ords for ILS display.

ILSDisp		PROC	NEAR

		call	ClearDisp

;* draw datum dots (localiser)

		mov	cx,XOrg
		add	cx,MFD_WIDTH/2-24
		mov	bl,YOrg
		add	bl,MFD_DEPTH/2
		mov	al,COL_CRT8
		call	SetPixel

		mov	cx,XOrg
		add	cx,MFD_WIDTH/2-12
		mov	bl,YOrg
		add	bl,MFD_DEPTH/2
		mov	al,COL_CRT8
		call	SetPixel

		mov	cx,XOrg
		add	cx,MFD_WIDTH/2
		mov	bl,YOrg
		add	bl,MFD_DEPTH/2
		mov	al,COL_CRT8
		call	SetPixel

		mov	cx,XOrg
		add	cx,MFD_WIDTH/2+12
		mov	bl,YOrg
		add	bl,MFD_DEPTH/2
		mov	al,COL_CRT8
		call	SetPixel

		mov	cx,XOrg
		add	cx,MFD_WIDTH/2+24
		mov	bl,YOrg
		add	bl,MFD_DEPTH/2
		mov	al,COL_CRT8
		call	SetPixel

;* draw datum dots (glide slope)

		mov	cx,XOrg
		add	cx,MFD_WIDTH/2
		mov	bl,YOrg
		add	bl,MFD_DEPTH/2-20
		mov	al,COL_CRT8
		call	SetPixel

		mov	cx,XOrg
		add	cx,MFD_WIDTH/2
		mov	bl,YOrg
		add	bl,MFD_DEPTH/2-10
		mov	al,COL_CRT8
		call	SetPixel

		mov	cx,XOrg
		add	cx,MFD_WIDTH/2
		mov	bl,YOrg
		add	bl,MFD_DEPTH/2+10
		mov	al,COL_CRT8
		call	SetPixel

		mov	cx,XOrg
		add	cx,MFD_WIDTH/2
		mov	bl,YOrg
		add	bl,MFD_DEPTH/2+20
		mov	al,COL_CRT8
		call	SetPixel

;* print data

		mov	si,OFFSET ILSSetUp$
		call	Print$

		mov	si,OFFSET ILSInActive$

		test	ILSActive,1	;ILS active?
		jz	@F		;no ->

		mov	si,OFFSET ILSActive$

@@:		call	Print$

;* test if in ILS beam

		test	ILSActive,1	;in ILS beam?
		jz	ILSExit		;no ->

;* draw localiser needle

		mov	ax,ILSLocalPos
		mov	dx,-MFD_WIDTH/2
		imul	dx
		FRACADJ	cx

		add	cx,MFD_WIDTH/2
		cmp	cx,MFD_WIDTH	;off screen?
		jb	@F		;no ->
		mov	cx,MFD_WIDTH-1
@@:		add	cx,XOrg
		
		mov	bl,YOrg
		mov	bh,bl
		add	bh,MFD_DEPTH-1

		mov	al,COL_CRT16
		call	VLineDraw

;* draw glide slope needle

		mov	ax,ILSGlidePos
		mov	dx,MFD_DEPTH/2
		imul	dx
		FRACADJ	bx

		add	bl,MFD_DEPTH/2
		cmp	bl,MFD_DEPTH	;off screen?
		jb	@F		;no ->
		mov	bl,MFD_DEPTH-1
@@:		add	bl,YOrg
		
		mov	cx,XOrg
		mov	dx,cx
		add	dx,MFD_WIDTH-1

		mov	al,COL_CRT16
		call	HLineDraw

ILSExit:	ret

ILSDisp		ENDP

;----------------------------------------------------------------------------

;* FLIRDisp - forward looking infra-red display
;*
;* pass: si -> MFD data block
;* ret : nothing
;* kill: assume all

FLIRDisp	PROC	NEAR
        cmp	si,OFFSET PILOT_MFD	;Pilot's MFD?
		jne	GoNavMFD			;no ->
		
		mov	ax,EXT_VIEWMODE	;set viewmode for MFD
		cmp IronWork, 1
		jne SkipMovIronWork0
		mov	IronWork,0 ;hacked by Frankie 30/11/2017
		mov	cx,XOrg
		mov	bl,YOrg
		call	SetViewMode
		COPY_VP	TMP_VIEW,M_VIEW
		;mov TMP_VIEW.VP_PITCH,0  ;hack frankie
		add	WORD PTR TMP_VIEW.VP_ZFT_LO,8	;add zft displacement
		adc	WORD PTR TMP_VIEW.VP_ZFT_HI,0
		call	DrawIRImage
		mov	ax,INT_VIEWMODE		;assume pilot view
		cmp	CrewMode,CREW_PILOT	;pilot?
		je	@F			;yes ->
		mov	ax,NUL_VIEWMODE		;nav view
@@:		call	SetViewMode	        
		
		cmp	PILOT_MFD.MFD_MODE,MFD_FLIR	;TAB2's FLIR selected?
        jne BypassEScope2 ;yes ->  		
		
        ;call UpdateEScope2

BypassEScope2:
        call LoadExtrnPan  
        call UpdateExtrn
		call RotateHdg		
        call UpdateHUD2 
		call UpdateRWR		
        mov	IronWork,1
		ret
		
SkipMovIronWork0:		
		mov	cx,XOrg
		mov	bl,YOrg
		call	SetViewMode
		COPY_VP	TMP_VIEW,M_VIEW
		;mov TMP_VIEW.VP_PITCH,0  ;hack frankie
		add	WORD PTR TMP_VIEW.VP_ZFT_LO,8	;add zft displacement
		adc	WORD PTR TMP_VIEW.VP_ZFT_HI,0
		call	DrawIRImage
		mov	ax,INT_VIEWMODE		;assume pilot view
		cmp	CrewMode,CREW_PILOT	;pilot?
		je	@F			;yes ->
		mov	ax,NUL_VIEWMODE		;nav view
@@:		call	SetViewMode	        
		
		cmp	PILOT_MFD.MFD_MODE,MFD_FLIR	;TAB2's FLIR selected?
        jne BypassEScope2b ;yes ->  		
        ;call UpdateEScope2

BypassEScope2b:
        call LoadExtrnPan  
        call UpdateExtrn
        call UpdateHUD2 
		call UpdateRWR		
        ;mov	IronWork,1
		ret

GoNavMFD:		
        ;cmp	dx,OFFSET NavigPanel ;kbs
		;je @F  
		cmp	TAB1.TAB_MODE,TAB_FLIR	;TAB1 FLIR selected?
		je	@F			
		cmp	TAB1.TAB_MODE,TAB_TIALD	;TAB1 TIALD selected?
		je	@F					
		mov	ax,TV1_VIEWMODE	;set viewmode for MFD
		jmp Zebra
		
@@:        
		mov	ax,TV1_VIEWMODE	;set viewmode for MFD
Zebra:		
		mov	cx,XOrg
		mov	bl,YOrg
		call	SetViewMode
		COPY_VP	TMP_VIEW,M_VIEW
		;mov TMP_VIEW.VP_PITCH,0  ;hack frankie
		add	WORD PTR TMP_VIEW.VP_ZFT_LO,8	;add zft displacement
		adc	WORD PTR TMP_VIEW.VP_ZFT_HI,0
		call	DrawIRImage
		mov	ax,INT_VIEWMODE		;assume pilot view
		cmp	CrewMode,CREW_PILOT	;pilot?
		je	@F			;yes ->
		mov	ax,NUL_VIEWMODE		;nav view
;@@:		
        call	SetViewMode	      
		ret

FLIRDisp	ENDP


;----------------------------------------------------------------------------

;* DrawIRImage - draw infra-red image
;*
;* pass: TMP_VIEW
;* ret : nothing
;* kill: assume all
;*
;* note: Assume viewmode initialized.

DrawIRImage	PROC	NEAR

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
		;cmp	Night,1		;night level1?
		;je	SkipIRCols	;yes ->

		cmp	Night,0		;night?
		jne	@F		;yes ->

		cmp	Fog,0		;foggy
		je	SkipIRCols	;no ->

@@:		;cmp Night,1
        ;je SkipIRCols   ;The user had earlier switched NVG on, so do not reset!

;call SetIRPalette ;Safe to reset the NVG to normal colors
;call CheckForNVG
		;mov	GradEnabled,0
		;mov	StarsEnabled,0
		;mov	CloudsEnabled,0
;mov	GradEnabled,1   ;hack by Frankie 30/11/17
;mov	StarsEnabled,0  ;hack by Frankie 30/11/17
;mov	CloudsEnabled,0 ;hack by Frankie 30/11/17

		
SkipIRCols:	mov	HillTextEnabled,0

;* sector scan = max(sector scan, 7 * 7)

		cmp	SecScanCnt1,7		;sector scan <= 7 * 7 scan?
		jbe	@F			;yes ->

		mov	SecScanCnt1,7		;reduce range
		mov	SecScanOff1,-3
		mov	SecScanCnt2,7
		mov	SecScanOff2,-3

;----------------
;* draw IR visual
;----------------

@@:		mov	si,OFFSET TMP_VIEW
		call	Visual

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

@@:		;cmp Night,1
        ;je SkipFixCols   ;The user had earlier switched NVG on, so do not reset!
;call FixIRPalette ;Safe to reset the NVG to normal colors
;call CheckForUNNVG
SkipFixCols:	
        mov	ax,NUL_VIEWMODE ;does this have any effect?
		call	SetViewMode	;does this have any effect?
        ret

DrawIRImage	ENDP

;----------------------------------------------------------------------------

;* ClearDisp - clear MFD display
;*
;* pass: si -> MFD data block
;* ret : nothing
;* kill: assume all (except si)

ClearDisp	PROC	NEAR

		push	si

		mov	al,COL_CRT1
		mov	cx,MFD_X_ORG[si]
		mov	bl,MFD_Y_ORG[si]
		mov	dx,cx
		add	dx,MFD_WIDTH-1
		mov	bh,bl
		add	bh,MFD_DEPTH-1
		call	BlockFill

		pop	si

		ret

ClearDisp	ENDP

;----------------------------------------------------------------------------

;* DamagedDisp
;*
;* pass: si -> MFD data block
;* ret : nothing
;* kill: assume all

DamagedDisp	PROC	NEAR

		call	ClearDisp

		mov	cx,24
DamagedLoop:	push	cx
		push	si

		call	RandX
		and	al,03fh
		cmp	al,MFD_DEPTH
		jae	NextDamage

		add	al,MFD_Y_ORG[si]
		mov	bl,al
		mov	cx,MFD_X_ORG[si]
		mov	dx,cx
		add	dx,MFD_WIDTH-1
		mov	al,COL_CRT6
		call	HLineDraw

NextDamage:	pop	si
		pop	cx
		loop	DamagedLoop
		
		ret

DamagedDisp	ENDP


;----------------------------------------------------------------------------

;* DamagedDispMFD
;*
;* pass: si -> MFD data block
;* ret : nothing
;* kill: assume all

DamagedDispMFD	PROC	NEAR

		call	ClearDisp

		mov	cx,24
DamagedLoop2:	push	cx
		push	si

		call	RandX
		and	al,03fh
		cmp	al,MFD_DEPTH
		jae	NextDamage2

		add	al,MFD_Y_ORG[si]
		mov	bl,al
		mov	cx,MFD_X_ORG[si]
		mov	dx,cx
		add	dx,MFD_WIDTH-1
		mov	al,COL_CRT6
		call	HLineDraw

NextDamage2:	pop	si
		pop	cx
		loop	DamagedLoop2
		
		ret

DamagedDispMFD	ENDP
;----------------------------------------------------------------------------

;* InvalidDisp - draw large 'X' in centre of MFD display
;*
;* pass: si -> MFD data block
;* ret : nothing
;* kill: assume all (except si)

InvalidDisp	PROC	NEAR

		call	ClearDisp

		mov	bl,MFD_Y_ORG[si]
		mov	bh,bl
		add	bl,YC-20
		add	bh,YC+20
		mov	cx,MFD_X_ORG[si]
		mov	dx,cx
		add	cx,XC-20
		add	dx,XC+20
		mov	al,COL_CRT8

		push	si
		call	LineDraw
		pop	si

		mov	bl,MFD_Y_ORG[si]
		mov	bh,bl
		add	bl,YC-20
		add	bh,YC+20
		mov	cx,MFD_X_ORG[si]
		mov	dx,cx
		add	cx,XC+20
		add	dx,XC-20
		mov	al,COL_CRT8

		push	si
		call	LineDraw
		pop	si

		ret

InvalidDisp	ENDP

;----------------------------------------------------------------------------

;* UpdateMapZoom - update map zoom level
;*
;* pass: si -> MFD data block
;* ret : nothing
;* kill: assume all (except si)

UpdateMapZoom	PROC	NEAR

		KTEST	KF_MapZoomIn
		jz	SkipZoomIn

		cmp	MFD_MAP_ZOOM[si],MAP_ZOOM6	;fully zoomed in?
		je	SkipZoomIn			;yes ->

		add	MFD_MAP_ZOOM[si],2

		jmp	SkipZoomOut

SkipZoomIn:	KTEST	KF_MapZoomOut
		jz	SkipZoomOut

		cmp	MFD_MAP_ZOOM[si],MAP_ZOOM1	;fully zoomed out?
		je	SkipZoomOut	 	 	;yes ->

		sub	MFD_MAP_ZOOM[si],2

SkipZoomOut:	ret

UpdateMapZoom	ENDP

   
;CheckForNVG	PROC	NEAR
;        KTEST   KF_NVG_MFD
;        _JZ GoHere2
;		cmp	Night,0	;day?
;		je GoHere2 ;yes ->
;		call	SetIRPalette
;		mov	GradEnabled,0
;		mov StarsEnabled,0
;		mov CloudsEnabled,0
;   GoHere2: ret
;CheckForNVG ENDP

;CheckForUNNVG	PROC	NEAR
;        KTEST   KF_NONVG_MFD
;        _JZ GoHere1
;		call	FixIRPalette
;		mov	GradEnabled,1
;		mov StarsEnabled,1
;		mov CloudsEnabled,1
;   GoHere1: ret
;CheckForUNNVG ENDP
  
  
;----------------------------------------------------------------------------

;* FLIRDisp - forward looking infra-red display
;*
;* pass: si -> MFD data block
;* ret : nothing
;* kill: assume all

FLIRDisp_ori	PROC	NEAR

		mov	ax,TV1_VIEWMODE	;set viewmode for MFD
		mov	cx,XOrg
		mov	bl,YOrg
		call	SetViewMode

		COPY_VP	TMP_VIEW,M_VIEW

		add	WORD PTR TMP_VIEW.VP_ZFT_LO,8	;add zft displacement
		adc	WORD PTR TMP_VIEW.VP_ZFT_HI,0

		call	DrawIRImage

		mov	ax,INT_VIEWMODE		;assume pilot view

		cmp	CrewMode,CREW_PILOT	;pilot?
		je	@F			;yes ->

		mov	ax,NUL_VIEWMODE		;nav view

@@:		call	SetViewMode	

		ret

FLIRDisp_ori	ENDP
  
;----------------------------------------------------------------------------

;* RotateHdg - rotate camera heading
;*
;* pass: cx, bx = current heading (*65536 scaling)
;* ret : cx, bx = new heading
;* kill: ax, dx, flags

RotateHdg	PROC	NEAR

;* sort rotate right

		KTEST	KF_TrackAClk
		jz	SkipRotateRt

		mov	ax,32*256	;32 pdeg / sec track (*256 scaling)
		mov	dx,DeltaTime
		imul	dx
		FRACADJ	ax

		xor	dh,dh		;*256 = *65536 scaling
		mov	dl,ah
		mov	ah,al
		xor	al,al

;* fast rotate?

		test	BYTE PTR KF_FastTrkAClk[K_STATUS],1
		jz	@F

		REPT	2		;*4
		shl	ax,1
		rcl	dx,1
		ENDM

@@:		sub	bx,ax
		sbb	cx,dx
		and	cx,511

		jmp	SkipRotateLt
		
;* sort rotate left

SkipRotateRt:	KTEST	KF_TrackClk
		jz	SkipRotateLt

		mov	ax,32*256	;32 pdeg / sec track (*256 scaling)
		mov	dx,DeltaTime
		imul	dx
		FRACADJ	ax

		xor	dh,dh		;*256 = *65536 scaling
		mov	dl,ah
		mov	ah,al
		xor	al,al

;* fast rotate?

		test	BYTE PTR KF_FastTrkClk[K_STATUS],1
		jz	@F

		REPT	2		;*4
		shl	ax,1
		rcl	dx,1
		ENDM

@@:		add	bx,ax
		adc	cx,dx
		and	cx,511

SkipRotateLt:	ret

RotateHdg	ENDP    
  
  
  
PANCODE		ENDS






;============================================================================

		END

