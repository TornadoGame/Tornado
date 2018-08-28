;****************************************************************************
;*
;* MODEL.ASM
;*
;* Flight model.
;*
;* 03.09.1991 - KJB
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	InitModel
		PUBLIC	Model
		PUBLIC	GameIntr20
		PUBLIC	GameIntr100
		PUBLIC	DestroyTornado

		PUBLIC	M_MOBILE
		PUBLIC	M_VIEW
		PUBLIC	HFine
		PUBLIC	PFine
		PUBLIC	RFine
		PUBLIC	Hdg
		PUBLIC	Pitch
		PUBLIC	Roll
		PUBLIC	M_SinH
		PUBLIC	M_CosH
		PUBLIC	M_SinP
		PUBLIC	M_CosP
		PUBLIC	M_SinR
		PUBLIC	M_CosR
		PUBLIC	ElePosn
		PUBLIC	AilPosn
		PUBLIC	RudPosn
		PUBLIC	PitchFlip
		PUBLIC	Weight
		PUBLIC	Weight2
		PUBLIC	FixedWeight
		PUBLIC	StoresWt
		PUBLIC	XSec
		PUBLIC	YSec
		PUBLIC	Xft
		PUBLIC	Yft
		PUBLIC	ZftHi
		PUBLIC	ZftLo
		PUBLIC	ModelMapIndex
		PUBLIC	Accel
		PUBLIC	Vtas
		PUBLIC	VtasFine
		PUBLIC	Vias
		PUBLIC	Vav
		PUBLIC	Vtrim
		PUBLIC	Vkts
		PUBLIC	GForce
		PUBLIC	GCoord
		PUBLIC	Mach1
		PUBLIC	MachNum
		PUBLIC	Rho
		PUBLIC	SqrtRho
		PUBLIC	RhoTable
		PUBLIC	SqrtRhoTable
		PUBLIC	DispGForce
		PUBLIC	DispAlpha
		PUBLIC	DispZdot
		PUBLIC	DispVSI
		PUBLIC	DispBarAlt
		PUBLIC	DispHdg
		PUBLIC	DispMachNum
		PUBLIC	FuelWt
		PUBLIC	FuelWtFine
		PUBLIC	Rpm1
		PUBLIC	Rpm2
		PUBLIC	FuelFlow1
		PUBLIC	FuelFlow2
		PUBLIC	Temp1
		PUBLIC	Temp2
		PUBLIC	CrntWingVal
		PUBLIC	CrntFlapVal
		PUBLIC	EleKbdWash
		PUBLIC	AilKbdWash
		PUBLIC	RudKbdWash
		PUBLIC	Throttle
		PUBLIC	ThrottleFine
		PUBLIC	Reheat
		PUBLIC	ReheatFine
		PUBLIC	ThrustTable
		PUBLIC	JoyVals
		PUBLIC	Thrust1
		PUBLIC	Thrust2
		PUBLIC	Thrust
		PUBLIC	Thrust4
		PUBLIC	DragHi
		PUBLIC	DragLo
		PUBLIC	Drag4
		PUBLIC	DragCoeff
		PUBLIC	CD0
		PUBLIC	CL1
		PUBLIC	Ksweep
		PUBLIC	KsweepCL2
		PUBLIC	Zdot
		PUBLIC	XWindVeff

		PUBLIC	Gear
		PUBLIC	GearTimer
		PUBLIC	WheelBrakes
		PUBLIC	AirBrakes
		PUBLIC	ThrustRvrs
		PUBLIC	CrntWingPos
		PUBLIC	CrntFlapPos
		PUBLIC	Airborne1
		PUBLIC	StallFlag1
		PUBLIC	SpinFlag
		PUBLIC	AutoTrim
		PUBLIC	DisableInput
		PUBLIC	Paused
		PUBLIC	DebugWeight
		PUBLIC	EngFire1
		PUBLIC	EngFire2

		PUBLIC	KF_HUDContrast
		PUBLIC	KF_HUDSwitch
		PUBLIC	KF_HUDOption
		PUBLIC	KF_ResetTrkCam
		PUBLIC	KF_ResetSatCam
		PUBLIC	KF_ResetWpnCam
		PUBLIC	KF_ZoomIn
		PUBLIC	KF_ZoomOut
		PUBLIC	KF_FastZoomIn
		PUBLIC	KF_FastZoomOut
		PUBLIC	KF_TrackClk
		PUBLIC	KF_TrackAClk
		PUBLIC	KF_FastTrkClk
		PUBLIC	KF_FastTrkAClk
		PUBLIC	KF_DispSelect
		PUBLIC	KF_TAB1Select
		PUBLIC	KF_TAB1Toggle
		PUBLIC	KF_TAB2Select
		PUBLIC	KF_TAB2Toggle
		PUBLIC	KF_PilotView
		PUBLIC	KF_NavigView
		PUBLIC	KF_LViewFix
		PUBLIC	KF_RViewFix
		PUBLIC	KF_LViewGlance
		PUBLIC	KF_RViewGlance
		PUBLIC	KF_TrackingCam
		PUBLIC	KF_SatelliteCam
		PUBLIC	KF_RemoteView
		PUBLIC	KF_MapView
		PUBLIC	KF_DroneView
		PUBLIC	KF_DronePrev
		PUBLIC	KF_DroneSide
		PUBLIC	KF_DroneType
		PUBLIC	KF_Spectator
		PUBLIC	KF_RestoreSpec
		PUBLIC	KF_LookDown
		PUBLIC	KF_ViewWeapon
		PUBLIC	KF_Range
		PUBLIC	KF_GndText
		PUBLIC	KF_HillText
		PUBLIC	KF_Clouds
		PUBLIC	KF_Horizon
		PUBLIC	KF_IronWork
		PUBLIC	KF_Control
		PUBLIC	KF_Sound
		PUBLIC	KF_Minimise
		PUBLIC	KF_MFDSelect
		PUBLIC	KF_MFDToggle
		PUBLIC	KF_MapZoomIn
		PUBLIC	KF_MapZoomOut
		PUBLIC	KF_MapOrigin
		PUBLIC	KF_GndRadar
		PUBLIC	KF_AirRadar
		PUBLIC	KF_RadarOff
		PUBLIC	KF_BoreSight
		PUBLIC	KF_CycleAirTgt
		PUBLIC	KF_CancelAirTgt
		PUBLIC	KF_ArmGnd
		PUBLIC	KF_ArmAir
		PUBLIC	KF_ArmOff
		PUBLIC	KF_Package
		PUBLIC	KF_WpnMode
		PUBLIC	KF_AirWeapon
		PUBLIC	KF_WpnFire
		PUBLIC	KF_WpnCommit
		PUBLIC	KF_ECM
		PUBLIC	KF_Chaff
		PUBLIC	KF_Flare
		PUBLIC	KF_AutoCancel
		PUBLIC	KF_Approach
		PUBLIC	KF_Track
		PUBLIC	KF_Hold
		PUBLIC	KF_TFollow
		PUBLIC	KF_Throttle
		PUBLIC	KF_AutoTrim
		PUBLIC	KF_SkipWaypoint
		PUBLIC	KF_SelectTgtWP
		PUBLIC	KF_CancelTgtWP
		PUBLIC	KF_Eject
		PUBLIC	KF_CancelAttn
		PUBLIC	KF_Recal
		PUBLIC	KF_JoySensNorm
		PUBLIC	KF_JoySensHigh
		PUBLIC	KF_Quit
		PUBLIC	KF_Pause

		PUBLIC	SWEEP_D_25
		PUBLIC	SWEEP_D_45
		PUBLIC	SWEEP_D_67
		PUBLIC	MAX_IDS_FUEL
		PUBLIC	MAX_ADV_FUEL
		PUBLIC	XWIND_VMIN
		PUBLIC	XWIND_VMAX

		EXTRN	InitCtrlDevice:FAR
		EXTRN	LimitPFine:FAR
		EXTRN	CalcDeltaTime:FAR
		EXTRN	ReadJoysticks:FAR
		EXTRN	Print$:FAR
		EXTRN	RandX:FAR
		EXTRN	CreateMobile:FAR
		EXTRN	DeleteMobile:FAR
		EXTRN	CalcSineFine:FAR
		EXTRN	ScreenShaker:FAR
		EXTRN	CalcStoresWt:FAR
		EXTRN	CalcGndHeight:FAR
		EXTRN	SurfaceCheck:FAR
		EXTRN	SetGameViewMode:FAR
		EXTRN	MakeSmokeEffect:FAR
		EXTRN	RefreshSound:FAR
		EXTRN	RefreshMusic:FAR
		EXTRN	ScreechSound:FAR
		EXTRN	GearSound:FAR
		EXTRN	GroundCollision:FAR
		EXTRN	StaticCollision:FAR
		EXTRN	MobileCollision:FAR
		EXTRN	TreeCollision:FAR
		EXTRN	CraterCollision:FAR
		EXTRN	MoveViewpoint:FAR
		EXTRN	MinDamage:FAR
		EXTRN	CalcVias:FAR

		EXTRN	JetExtTanks:NEAR
		EXTRN	JetExtStores:NEAR
		EXTRN	JetAll:NEAR

		EXTRN	ControlDevice:WORD
		EXTRN	LastFrame:WORD
		EXTRN	DeltaTime:WORD
		EXTRN	SinTable:WORD
		EXTRN	CosTable:WORD
		EXTRN	JoyA_XVal:WORD
		EXTRN	JoyA_YVal:WORD
		EXTRN	JoyB_XVal:WORD
		EXTRN	JoyB_YVal:WORD
		EXTRN	TFPitchRate:WORD
		EXTRN	TFDeltaPRate:WORD
		EXTRN	TFGForce:WORD
		EXTRN	CrewMode:WORD
		EXTRN	AutoMode:WORD
		EXTRN	AltMode:WORD
		EXTRN	HdgMode:WORD
		EXTRN	AutoVias:WORD
		EXTRN	AutoViasFine:WORD
		EXTRN	TFRideIndex:WORD
		EXTRN	AutoHdg:WORD
		EXTRN	AutoHdgFine:WORD
		EXTRN	AHRollRate:WORD
		EXTRN	AHDeltaRRate:WORD
		EXTRN	AutoAlt:WORD
		EXTRN	AutoAltFine:WORD
		EXTRN	AAPitchRate:WORD
		EXTRN	AADeltaPRate:WORD
		EXTRN	AAGForce:WORD
		EXTRN	ShakeTimer:WORD
		EXTRN	RedWarnings2:WORD
		EXTRN	AmbWarnings2:WORD
		EXTRN	StartAirspeed:WORD
		EXTRN	XWindVmax:WORD
		EXTRN	XWindDir:WORD

		EXTRN	Key:BYTE
		EXTRN	DieFlag:BYTE
		EXTRN	SSF_Gear:BYTE
		EXTRN	SSF_WheelBrakes:BYTE
		EXTRN	SSF_AirBrakes:BYTE
		EXTRN	SSF_Engine1:BYTE
		EXTRN	SSF_Engine2:BYTE
		EXTRN	SSF_Sweep:BYTE
		EXTRN	SSF_Flaps:BYTE
		EXTRN	SSF_ThrustRvrs:BYTE
		EXTRN	SSF_SPILS:BYTE
		EXTRN	TFAuto:BYTE
		EXTRN	AutoThrot:BYTE
		EXTRN	AHFlag:BYTE
		EXTRN	AAFlag:BYTE
		EXTRN	JoyA_Flag:BYTE
		EXTRN	JoyB_Flag:BYTE
		EXTRN	JoyA_Fire1:BYTE
		EXTRN	JoyA_Fire2:BYTE
		EXTRN	JoyA_JustFired1:BYTE
		EXTRN	JoyA_JustFired2:BYTE
		EXTRN	JoyB_Fire1:BYTE
		EXTRN	JoyB_Fire2:BYTE
		EXTRN	JoyB_JustFired1:BYTE
		EXTRN	JoyB_JustFired2:BYTE
		EXTRN	Jettison:BYTE
		EXTRN	JoySensitivity:BYTE
		EXTRN	InCockpit:BYTE
		EXTRN	ShakePriority:BYTE
		EXTRN	HShake:BYTE
		EXTRN	VShake:BYTE
		EXTRN	NoCollisions:BYTE
		EXTRN	Destroyed:BYTE
		EXTRN	Ejected:BYTE
		EXTRN	TmpDieFlag:BYTE
		EXTRN	Landing:BYTE
		EXTRN	StartAirborne:BYTE
		EXTRN	InfiniteFuel:BYTE
		EXTRN	ECMFitted:BYTE
		EXTRN	ECMActive:BYTE
		EXTRN	SSF_ECM:BYTE
		EXTRN	DamagedLEng:BYTE
		EXTRN	DamagedREng:BYTE
		EXTRN	FixMinWeight:BYTE
		EXTRN	HitObjectNum:BYTE
		EXTRN	TwoPlayer:BYTE
		EXTRN	SctrGameLayer1:BYTE

		EXTRN	MAX_TF_INDEX:ABS
		EXTRN	MAX_AUTO_VIAS:ABS
		EXTRN	MAX_AUTO_HDG:ABS
		EXTRN	MIN_AUTO_ALT:ABS
		EXTRN	MAX_AUTO_ALT:ABS
		EXTRN	HSHAKE_OFF:ABS
		EXTRN	HSHAKE_LO:ABS
		EXTRN	HSHAKE_HI:ABS
		EXTRN	VSHAKE_OFF:ABS
		EXTRN	VSHAKE_LO:ABS
		EXTRN	VSHAKE_HI:ABS

;============================================================================

		INCLUDE	MAINDATA.INC
		INCLUDE	MISCMAC.INC
		INCLUDE	CONFIG.INC

		INCLUDE	\VISUAL\VISDATA.INC
		INCLUDE	\VISUAL\VISMACRO.INC
		INCLUDE	\VISUAL\MOBLIST.INC

		INCLUDE	\LIB8086\KEYS.INC
		INCLUDE	\LIB8086\TRIG.INC
		INCLUDE	\LIB8086\USEFUL.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

;----------------------------------------------
;* Tornado mobile and viewpoint data structures (order is important)
;----------------------------------------------

M_MOBILE	MOBILE    <MOB_TORNADO1,OTYPE_MOBILE3,0>
M_VIEW		VIEWPOINT <16,16,3584,1,0,384>

;* previous viewpoint required for collision detection

M_TEST		VIEWPOINT <>

;-----------------
;* positional vars
;-----------------

XSec		DW	0
YSec		DW	0

Xft		DW	0
XFine		DW	0

Yft		DW	0
YFine		DW	0

ZftHi		DW	0
ZftLo		DW	0
ZFine		DW	0

ModelMapIndex	DW	-1		;ysec * 32 + xsec (-1 = off map)

;---------------
;* attitude vars
;---------------		

Hdg		DW	0		;0 .. 511 pdeg (HFine / 128)
HFine		DW	0

Pitch		DW	0		;384 .. 0 .. 511 pdeg (PFine / 128)
PFine		DW	0

Roll		DW	0		;0 .. 511 pdeg (RFine / 128)
RFine		DW	0

M_SinH		DW	0
M_CosH		DW	0
M_SinP		DW	0
M_CosP		DW	0
M_SinR		DW	0
M_CosR		DW	0

;---------------------------
;* control surface positions
;---------------------------

;* elevator position (-32768 (stick forward) .. +32767 (stick back))

ElePosn		DW	0

;* aileron position (-32768 (stick left) .. +32767 (stick right))

AilPosn		DW	0

;* rudder position   (-32768 (stick left)    .. +32767 (stick right))

RudPosn		DW	0

;---------------
;* control rates
;---------------

HdgRate		DW	0		;fine pdegs / sec
PitchRate	DW	0		;fine pdegs / sec
RollRate     	DW	0		;fine pdegs / sec

DeltaHRate	DW	0		;fine pdegs / frame
DeltaPRate	DW	0		;fine pdegs / frame
DeltaRRate     	DW	0		;fine pdegs / frame

EleRate		DW	0		;fine pdegs / sec
RudRate		DW	0		;fine pdegs / sec

EleRollRate	DW	0		;fine pdegs / sec
AilRollRate	DW	0		;fine pdegs / sec
RudRollRate	DW	0		;fine pdegs / sec

GRate		DW	0		;fine pdegs / sec

PitchFlip	DW	0		;00000h or 0ffffh wrt pitch flip

;-------------
;* stall rates
;-------------

MIN_STALL_PRATE	EQU	1*128		;fine pdegs / sec
MAX_STALL_PRATE	EQU	46*128		;fine pdegs / sec

MAX_STALL_PDN1	EQU	-28*128		;pitch down to -20 degs (fine pdegs) (regular stall)
MAX_STALL_PDN2	EQU	-64*128		;pitch down to -45 degs (fine pdegs) (stall after spin recovery)

MIN_STALL_RRATE	EQU	1*128		;fine pdegs / sec
MAX_STALL_RRATE	EQU	32*128		;fine pdegs / sec

StallPitch	DW	0		;pitch angle at stall (fine pdegs)

MaxPitchDown	DW	MAX_STALL_PDN1	;max stall pitch down angle

StallRollDir	DW	0		;0 = clk-wise, -1 = aclk-wise

;-----------
;* spin vars
;-----------

Recovery	DW	0		;spin recovery time (1/100ths sec)

;------------------------------
;* wash roll threshold and rate
;------------------------------

RWASH_THRESH	EQU	7		;pdegs

RWASH_RATE	EQU	40		;fine pdegs / 100th sec

;-----------------
;* damping factors
;-----------------

DAMP2		EQU	1		;/2 damping
DAMP4		EQU	2		;/4 damping
DAMP8		EQU	3		;/8 damping
DAMP16		EQU	4		;/16 damping
DAMP32		EQU	5		;/32 damping
DAMP64		EQU	6		;/64 damping

;---------------
;* weights (lbs)
;---------------

MIN_WEIGHT	EQU	31065+200+200	;aircraft + pilot + navigator + equipment

NOM_WEIGHT	EQU	45000		;nominal weight

Weight		DW	NOM_WEIGHT	;weight = 0 .. 65,535lbs

Weight2		DW	NOM_WEIGHT/2 	;weight / 2

FixedWeight	DW	NOM_WEIGHT 	;fixed weight for debugging

DebugWeight	DB	0,0		;1 = used fixed weight for debugging

MAX_IDS_FUEL	EQU	10720+970	;IDS / ECR internal tanks + fin tank
MAX_ADV_FUEL	EQU	11790+970	;ADV internal tanks + fin tank
MAX_EXT_FUEL	EQU	3960*2		;drop tanks

	IF	OPT_FLY_DEMO EQ 0

FuelWt		DW	MAX_IDS_FUEL+MAX_EXT_FUEL
FuelWtFine	DW	0

	ELSE

FuelWt		DW	10000
FuelWtFine	DW	0

	ENDIF

StoresWt 	DW	0

;------------------------------------
;* throttle, reheat, rpm, thrust etc.
;------------------------------------

Throttle	DW	0		;0 .. 256

ThrottleFine	DW	0

Reheat		DW	0		;0 .. 128

ReheatFine	DW	0

IDLE_RPM	EQU	63*256

Rpm1		DW	IDLE_RPM	;0 .. 100% * 256 (lh engine)
Rpm2		DW	IDLE_RPM	;0 .. 100% * 256 (rh engine)

RPM_DELTA_MAX	EQU	1894		;7.4% / sec * 256

Thrust1		DW	0		;engine 1 thrust (unaffected by altitude)
Thrust2		DW	0		;engine 2 thrust (unaffected by altitude)

Thrust		DW	0		;thrust = 0 .. 34,000lbf

Thrust4		DW	0		;thrust / 4 (-ve if reversers applied)

EngFire1	DB	0		;1 = engine fire
EngFire2	DB	0		;1 = engine fire

ENG_FIRE_TIME	EQU	30*100		;secs * 100

EngFireTimer	DW	ENG_FIRE_TIME	;secs * 100

;* fuel flow (lbs / sec) * 1024 (for display purposes only)

FuelFlow1	DW	0
FuelFlow2	DW	0

;* temp vars

MIN_ENG_TEMP	EQU	0*16		;min temp (out of fuel, damaged)
MAX_ENG_TEMP	EQU	1000*16		;max temp (on fire)

MAX_TEMP_INC	EQU	100*16		;max temp increase / sec
MAX_TEMP_DEC	EQU	-25*16		;max temp decrease / sec

Temp1		DW	400*16		;400 .. 700 degs / c (*16 scaling)
Temp2		DW	400*16		;400 .. 700 degs / c (*16 scaling)

;--------------
;* display vars
;--------------

DispGForce	DW	16		;damped GForce (*16 scaling)

DispAlpha	DW	0		;damped Alpha (*16 scaling)

DispZdot	DW	0		;damped Zdot (*8 scaling)

DispVSI		DW	0		;VSI ft / min (/10 scaling)

DispBarAlt     	DW	0		;zft (/10 scaling)

DispHdg		DW	0		;hdg (1 .. 360)

DispMachNum	DW	0		;mach num (*10 scaling)

;------------------------------------------------------------
;* thrust wrt engine rpm table (values / 2 for single engine)
;------------------------------------------------------------

ThrustTable	DW	0		;63
		DW	500/2		;64
		DW	880/2		;65
		DW	1260/2		;66
		DW	1640/2		;67
		DW	2020/2		;68
		DW	2400/2		;69
		DW	2800/2		;70
		DW	3120/2		;71
		DW	3440/2		;72
		DW	3760/2		;73
		DW	4080/2		;74
		DW	4400/2		;75
		DW	4840/2		;76
		DW	5280/2		;77
		DW	5720/2		;78
		DW	6160/2		;79
		DW	6600/2		;80
		DW	7140/2		;81
		DW	7680/2		;82
		DW	8220/2		;83
		DW	8760/2		;84
		DW	9300/2		;85
		DW	9680/2		;86
		DW	10060/2		;87
		DW	10440/2		;88
		DW	10820/2		;89
		DW	11200/2		;90
		DW	11800/2		;91
		DW	12400/2		;92
		DW	13000/2		;93
		DW	13600/2		;94
		DW	14200/2		;95
		DW	14960/2		;96
		DW	15720/2		;97
		DW	16480/2		;98
		DW	17240/2		;99
		DW	18000/2		;100

;------
;* gear
;------

Gear		DB	1		;1 = lowered

		EVEN

GEAR_TIME	EQU	300		;gear motion time (secs * 100)

GearTimer	DW	0		;gear in motion timer (secs * 100)

;---------------------
;* miscellaneous flags
;---------------------

WheelBrakes	DB	1		;1 = applied

AirBrakes	DB	0		;1 = applied

ThrustRvrs	DB	0		;1 = applied

SPILS		DB	1		;1 = SPILS on

AirborneFlags	LABEL	WORD

Airborne1	DB	0		;new airborne flag, 1 = airborne
Airborne2	DB	0		;old airborne flag, 1 = airborne

TouchDown	DB	0		;1 = touchdown this frame

StallFlags	LABEL	WORD

StallFlag1	DB	1		;new stall flag, 1 = stalled
StallFlag2	DB	1		;old stall flag, 1 = stalled

StartStall	DB	0		;1 = stalled this frame

SpinFlag	DB	0		;1 = spinning

AutoTrim	DB	0		;1 = auto-trim engaged

NewSector	DB	1		;1 = entered new sector this frame

DisableInput	DB	0		;see MAINDATA.INC

Paused		DB	0		;1 = paused

HitHill		DB	0		;1 = hit hill

Timer50		DB	0		;50Hz toggle

		EVEN

;--------------------------
;* wing sweep position vars
;--------------------------

;* digital wing positions

SWEEP_D_25	EQU	0
SWEEP_D_45	EQU	1
SWEEP_D_67	EQU	2

;* analogue wing positions (time in 1/100ths sec)

SWEEP_A_25	EQU	0
SWEEP_A_45	EQU	333
SWEEP_A_67	EQU	700

SweepActive	DB	0,0		;1 = active (FlapsActive = 0)

CrntWingPos	DB	SWEEP_D_25	;digital position
DestWingPos	DB	SWEEP_D_25

CrntWingVal	DW	SWEEP_A_25	;analogue position
DestWingVal	DW	SWEEP_A_25

WingSetting	DW	SWEEP_A_25
		DW	SWEEP_A_45
		DW	SWEEP_A_67

;-------------------
;* buffet thresholds (wrt Mach)
;-------------------

;* 25 degs sweep up to Mach 0.73
;* 45 degs sweep up to Mach 0.88
;* 67 degs sweep up to Mach 2.20

;* allow 20% excess for lo buffet shake
;* allow 40% excess for hi buffet shake
;* above 40% excess destroys aircraft

BuffetThresh	LABEL	WORD

;*		DW	no, lo, hi

		DW	12, 14, 16	;25 sweep
		DW	14, 17, 20	;45 sweep
		DW	35, 42, 49	;67 sweep

;--------------------
;* flap position vars
;--------------------

;* digital flap positions

FLAPS_D_ZERO 	EQU	0
FLAPS_D_MNVR	EQU	1
FLAPS_D_MID	EQU	2
FLAPS_D_FULL	EQU	3

;* analogue flap positions (time in 1/100ths sec)

FLAPS_A_ZERO 	EQU	0
FLAPS_A_MNVR	EQU	150
FLAPS_A_MID	EQU	300
FLAPS_A_FULL	EQU	600

FlapsActive	DB	0,0		;1 = active (SweepActive = 0)

CrntFlapPos	DB	FLAPS_D_MID	;digital position
DestFlapPos	DB	FLAPS_D_MID

CrntFlapVal	DW	FLAPS_A_MID	;analogue position
DestFlapVal	DW	FLAPS_A_MID

FlapSetting	DW	FLAPS_A_ZERO
		DW	FLAPS_A_MNVR
		DW	FLAPS_A_MID
		DW	FLAPS_A_FULL

;--------------------------------
;* flap damage warning thresholds (wrt IAS)
;--------------------------------

;* MNVR flaps up to 450kts
;* MID  flaps up to 280kts
;* FULL flaps up to 225kts

;* damage flap mechanism if exceed threshold by 20%

FlapThresh	LABEL	WORD

;*		DW	warning threshold, damage threshold (ft/sec * 8)

		DW	32767,32767	;ZERO (does not apply)
		DW	765*8,918*8	;MNVR
		DW	476*8,571*8	;MID
		DW	383*8,459*8	;FULL

;--------------------------------------------
;* wing sweep and flap position inhibit table
;--------------------------------------------

;* index = wing sweep pos * 4 + flap pos

PosInhibit	DB	1,1,1,1		;25 deg (1 = ok, 0 = inhibited)
		DB	1,1,1,0		;45 deg
		DB	1,0,0,0		;67 deg

;----------------------------
;* g force vars (*16 scaling)
;----------------------------

G_MAX		EQU	120		;7.5 * 16 scaling
G_MIN		EQU	-48		;-3 * 16 scaling

GForce		DW	0		;g force

GMax		DW	0		;g maximum

TrueGMax	DW	0		;g maximum unlimited

GCoord		DW	0		;g required for co-ordinated turn

Kfs		DW	26214		;flap / wing sweep constant

;-----------------------------
;* angle of attack (incidence)
;-----------------------------

ALPHA_MAX	EQU	21*16		;21 degs
ALPHA_MIN	EQU	-8*16		;-8 degs

Alpha		DW	0		;degs (*16 scaling)

;------------
;* Kfs tables
;------------

;* wing sweep and flaps inactive (-1 = value not valid)
;*
;* index = wing sweep pos * 8 + flap pos * 2

KfsFixed	DW	19661, 22938, 26214, 32767	;25 deg
		DW	15270, 18285, 21299,    -1	;45 deg
		DW	11338,    -1,    -1,    -1	;67 deg

;* wing sweep active
;*
;* index = flap pos * 4
;*
;*		DW	scale, value
;*
;* Kfs = value - (sweep value * scale) / 256

KfsSweep	DW	 3044, 19661	;zero
		DW	 3577, 22938	;mnvr
		DW	 3778, 26214	;mid
		DW	    0, 32767	;full

;* flaps active
;*
;* index = wing sweep pos * 4
;*
;*		DW	scale, value
;*
;* Kfs = value + (flaps value * scale) / 256

KfsFlaps	DW	 5592, 19661	;25 deg
		DW	 5145, 15270	;45 deg
		DW	    0, 11338	;67 deg

;-----------
;* drag vars
;-----------

DragHi		DW	0		;lbf
DragLo		DW	0

Drag4		DW	0		;drag / 4

DragCoeff	DW	0

;* drag coeff intermediate values

CD0		DW	0		;profile drag
CL1		DW	0		;induced drag (CL)
Ksweep		DW	0		;wing sweep drag constant
KsweepCL2 	DW	0		;KsweepCL^2

;* drag constants

Kgear		EQU	1475		;CD = 0.045
Kairbrakes	EQU	3677		;CD = 0.1122
Kground		EQU	2336		;CD = 0.0713

;* Kstatic - If the aircraft is stationary and wheelbrakes are applied then
;*	     restrain the aircraft with full reheat. This value was previously
;*	     set to restrain the aircraft with max dry thrust only.

Kstatic		EQU	34000	;lbf (changed from 18000)

;* Krolling - Aircraft is rolling with wheelbrakes applied. This value has
;*	      been increased significantly to reduce the landing run.

Krolling	EQU	12000	;lbf (changed from 4625)

;* Kfreewheel - Aircraft is rolling with no wheelbrakes applied. This value
;*		has been introduced because the ground drag Kground is not
;*	        enough to stop the aircraft. However, this value should only
;*		be applied if the aircraft is decelerating.

Kfreewheel	EQU	4000	;lbf

;* Kwheelsup - Aircraft is rolling after wheels up landing. This value is set
;*	       to give a shorter landing run than Krolling.

Kwheelsup	EQU	34000	;lbf

;* profile drag wrt wing sweep and flaps (-1 = value not valid)
;*
;* index = wing sweep pos * 8 + flap pos * 2

CD0Table	DW	2163, 2474, 2785, 3401	;25 deg
		DW	2022, 2305, 2589,   -1	;45 deg
		DW	1786,   -1,   -1,   -1	;67 deg

;-----------------------------------------
;* acceleration, velocity, airspeed (etc.)
;-----------------------------------------

Accel		DW	0		;acceleration (*8 scaling)

Vtas		DW	0		;true air speed (*8 scaling)

VtasFine	DW	0

Vias		DW	0		;indicated air speed (*8 scaling)

Vdiv		DW	1360		;Vias used in division (min 100kts = 1360)

Vav		DW	0		;velocity average (*8 scaling)

Vtrim		DW	0		;velocity trim (*8 scaling)

Zdot		DW	0		;climb / sink rate (*8 scaling)

Vkts		DW	0		;knots (always >= 0)

Mach1		DW	0		;mach 1

MachNum		DW	0		;mach number (*16 scaling)

;* Vtrim wrt wing sweep and flaps (@ 33,000lbwt) (-1 = value not valid)
;*
;* index = wing sweep pos * 8 + flap pos * 2

VtrimTable	DW	477*8, 439*8, 401*8, 358*8	;25 deg
		DW	575*8, 529*8, 483*8,  -1	;45 deg
		DW	652*8,  -1,    -1,    -1	;67 deg

;------------------
;* air density vars
;------------------

Rho		DW	0		;air density

SqrtRho		DW	0		;square root (air density)

;------------------------------------------------
;* air density table (rho), sea level .. 70,000ft
;------------------------------------------------

RhoTable	DW	07FFFh	;@ 0ft = 1.000
		DW	07C49h	;@ 1000ft = 0.971
		DW	078B3h	;@ 2000ft = 0.943
		DW	0751Eh	;@ 3000ft = 0.915
		DW	071A9h	;@ 4000ft = 0.888
		DW	06E55h	;@ 5000ft = 0.862
		DW	06B01h	;@ 6000ft = 0.836
		DW	067CEh	;@ 7000ft = 0.811
		DW	0649Bh	;@ 8000ft = 0.786
		DW	06188h	;@ 9000ft = 0.762
		DW	05E97h	;@ 10000ft = 0.739
		DW	05BA5h	;@ 11000ft = 0.716
		DW	058B4h	;@ 12000ft = 0.693
		DW	055E3h	;@ 13000ft = 0.671
		DW	05333h	;@ 14000ft = 0.650
		DW	05082h	;@ 15000ft = 0.629
		DW	04DF3h	;@ 16000ft = 0.609
		DW	04B64h	;@ 17000ft = 0.589
		DW	048F5h	;@ 18000ft = 0.570
		DW	04687h	;@ 19000ft = 0.551
		DW	04439h	;@ 20000ft = 0.533
		DW	041EBh	;@ 21000ft = 0.515
		DW	03FBEh	;@ 22000ft = 0.498
		DW	03D91h	;@ 23000ft = 0.481
		DW	03B64h	;@ 24000ft = 0.464
		DW	03958h	;@ 25000ft = 0.448
		DW	0376Ch	;@ 26000ft = 0.433
		DW	03560h	;@ 27000ft = 0.417
		DW	03395h	;@ 28000ft = 0.403
		DW	031AAh	;@ 29000ft = 0.388
		DW	02FDFh	;@ 30000ft = 0.374
		DW	02E35h	;@ 31000ft = 0.361
		DW	02C6Ah	;@ 32000ft = 0.347
		DW	02AE1h	;@ 33000ft = 0.335
		DW	02937h	;@ 34000ft = 0.322
		DW	027AEh	;@ 35000ft = 0.310
		DW	02625h	;@ 36000ft = 0.298
		DW	0247Bh	;@ 37000ft = 0.285
		DW	022B0h	;@ 38000ft = 0.271
		DW	02106h	;@ 39000ft = 0.258
		DW	01F7Dh	;@ 40000ft = 0.246
		DW	01E14h	;@ 41000ft = 0.235
		DW	01CACh	;@ 42000ft = 0.224
		DW	01B43h	;@ 43000ft = 0.213
		DW	019FCh	;@ 44000ft = 0.203
		DW	018D5h	;@ 45000ft = 0.194
		DW	017AEh	;@ 46000ft = 0.185
		DW	01687h	;@ 47000ft = 0.176
		DW	01581h	;@ 48000ft = 0.168
		DW	0147Bh	;@ 49000ft = 0.160
		DW	01375h	;@ 50000ft = 0.152
		DW	0128Fh	;@ 51000ft = 0.145
		DW	011AAh	;@ 52000ft = 0.138
		DW	010C4h	;@ 53000ft = 0.131
		DW	01000h	;@ 54000ft = 0.125
		DW	0F5Ch	;@ 55000ft = 0.120
		DW	0E97h	;@ 56000ft = 0.114
		DW	0DF4h	;@ 57000ft = 0.109
		DW	0D50h	;@ 58000ft = 0.104
		DW	0CACh	;@ 59000ft = 0.099
		DW	0C08h	;@ 60000ft = 0.094
		DW	0B64h	;@ 61000ft = 0.089
		DW	0AE1h	;@ 62000ft = 0.085
		DW	0A5Eh	;@ 63000ft = 0.081
		DW	09DBh	;@ 64000ft = 0.077
		DW	0979h	;@ 65000ft = 0.074
		DW	08F6h	;@ 66000ft = 0.070
		DW	0893h	;@ 67000ft = 0.067
		DW	0831h	;@ 68000ft = 0.064
		DW	07CFh	;@ 69000ft = 0.061
		DW	076Ch	;@ 70000ft = 0.058

;---------------------------------------------------------------------
;* square root of air density table (sqrt(rho)), sea level .. 70,000ft
;---------------------------------------------------------------------

SqrtRhoTable	DW	07FFFh	;@ 0ft = 1.000
		DW	07E13h	;@ 1000ft = 0.985
		DW	07C49h	;@ 2000ft = 0.971
		DW	07A7Eh	;@ 3000ft = 0.957
		DW	07893h	;@ 4000ft = 0.942
		DW	076C8h	;@ 5000ft = 0.928
		DW	074FDh	;@ 6000ft = 0.914
		DW	07332h	;@ 7000ft = 0.900
		DW	07188h	;@ 8000ft = 0.887
		DW	06FBEh	;@ 9000ft = 0.873
		DW	06DF3h	;@ 10000ft = 0.859
		DW	06C49h	;@ 11000ft = 0.846
		DW	06A9Fh	;@ 12000ft = 0.833
		DW	068D4h	;@ 13000ft = 0.819
		DW	0672Ah	;@ 14000ft = 0.806
		DW	06580h	;@ 15000ft = 0.793
		DW	063D6h	;@ 16000ft = 0.780
		DW	0624Dh	;@ 17000ft = 0.768
		DW	060A3h	;@ 18000ft = 0.755
		DW	05EF9h	;@ 19000ft = 0.742
		DW	05D70h	;@ 20000ft = 0.730
		DW	05BE7h	;@ 21000ft = 0.718
		DW	05A3Dh	;@ 22000ft = 0.705
		DW	058B4h	;@ 23000ft = 0.693
		DW	0572Ah	;@ 24000ft = 0.681
		DW	055A1h	;@ 25000ft = 0.669
		DW	05395h	;@ 26000ft = 0.653
		DW	052AFh	;@ 27000ft = 0.646
		DW	05147h	;@ 28000ft = 0.635
		DW	04FBEh	;@ 29000ft = 0.623
		DW	04E55h	;@ 30000ft = 0.612
		DW	04CEDh	;@ 31000ft = 0.601
		DW	04B64h	;@ 32000ft = 0.589
		DW	049FBh	;@ 33000ft = 0.578
		DW	048B4h	;@ 34000ft = 0.568
		DW	0474Bh	;@ 35000ft = 0.557
		DW	045E3h	;@ 36000ft = 0.546
		DW	04439h	;@ 37000ft = 0.533
		DW	042B0h	;@ 38000ft = 0.521
		DW	04106h	;@ 39000ft = 0.508
		DW	03F7Ch	;@ 40000ft = 0.496
		DW	03E14h	;@ 41000ft = 0.485
		DW	03C8Bh	;@ 42000ft = 0.473
		DW	03B22h	;@ 43000ft = 0.462
		DW	039BAh	;@ 44000ft = 0.451
		DW	03851h	;@ 45000ft = 0.440
		DW	0370Ah	;@ 46000ft = 0.430
		DW	035A1h	;@ 47000ft = 0.419
		DW	0345Ah	;@ 48000ft = 0.409
		DW	03333h	;@ 49000ft = 0.400
		DW	031EBh	;@ 50000ft = 0.390
		DW	030C4h	;@ 51000ft = 0.381
		DW	02F9Dh	;@ 52000ft = 0.372
		DW	02E76h	;@ 53000ft = 0.363
		DW	02D50h	;@ 54000ft = 0.354
		DW	02C49h	;@ 55000ft = 0.346
		DW	02B22h	;@ 56000ft = 0.337
		DW	02A1Ch	;@ 57000ft = 0.329
		DW	02937h	;@ 58000ft = 0.322
		DW	02831h	;@ 59000ft = 0.314
		DW	0274Bh	;@ 60000ft = 0.307
		DW	02645h	;@ 61000ft = 0.299
		DW	02560h	;@ 62000ft = 0.292
		DW	0247Bh	;@ 63000ft = 0.285
		DW	02395h	;@ 64000ft = 0.278
		DW	022D1h	;@ 65000ft = 0.272
		DW	021EBh	;@ 66000ft = 0.265
		DW	02127h	;@ 67000ft = 0.259
		DW	02041h	;@ 68000ft = 0.252
		DW	01F7Dh	;@ 69000ft = 0.246
		DW	01ED9h	;@ 70000ft = 0.241

;------------
;* crosswinds
;------------

XWIND_VMIN	EQU	68		;(approx 5kts)
XWIND_VMAX	EQU	1023		;(approx 75kts)

XWindVtas	DW	0		;current windspeed (ft/sec * 8)
XWindVaim	DW	0		;aiming windspeed (ft/sec * 8)

XWindVfix	DW	0		;faded windspeed (ft/sec * 8)
XWindVeff	DW	0		;effective windspeed (ft/sec * 8)

XWindGust	DW	0		;gust accel (ft/sec/sec * 8)

XWindFade	DW	0		;fade level (0 .. 32767)

XWindDXft	DW	0		;delta xft
XWindDXFine	DW	0		;delta xfine

XWindDYft	DW	0		;delta yft
XWindDYFine	DW	0		;delta yfine

XWIND_DIR_INT	EQU	15*100		;change wind direction interval

XWindDirTimer	DW	XWIND_DIR_INT 	;(secs * 100)

;------------------
;* keyboard control
;------------------

;* keyboard control mode switch wrt ControlDevice

KbdCtrlSwitch	DW	KbdElevators	;CTRL_DEV_KBD1
		DW	KbdElevators	;CTRL_DEV_KBD2
		DW	KbdRudder	;CTRL_DEV_JOY1
		DW	KbdStatus	;CTRL_DEV_JOY2

;* elevator switch wrt AltMode

KbdEleSwitch	DW	KbdEleManual	;ALT_MANUAL
		DW	KbdEleApproach	;ALT_APPROACH
		DW	KbdEleAcquire	;ALT_ACQUIRE
		DW	KbdEleTF	;ALT_TF

;* aileron switch wrt AltMode

KbdAilSwitch	DW	KbdAilManual	;HDG_MANUAL
		DW	KbdAilApproach	;HDG_APPROACH
		DW	KbdAilAcquire	;HDG_ACQUIRE
		DW	KbdAilTrack	;HDG_TRACK

;* keyboard sensitivity (50 (least sensitive) .. 500 (most sensitive))

EleKbdRate	DW	200		;elevator rate
AilKbdRate	DW	200		;aileron rate
RudKbdRate	DW	100		;rudder rate

;* keyboard washout thresholds (see MODELLIB.ASM InitCtrlDevice for defaults)

EleKbdWash	DW	0		;elevator washout threshold
AilKbdWash	DW	0		;aileron washout threshold
RudKbdWash	DW	0		;rudder washout threshold

;* old key values (status of keys last interrupt)

OldCrsrUp	DB	0
OldCrsrDn	DB	0
OldCrsrLf	DB	0
OldCrsrRt	DB	0
OldPlus		DB	0
OldMinus	DB	0

		EVEN

;------------------
;* joystick control
;------------------

;* elevator switch wrt AltMode

JoyEleSwitch	DW	JoyEleManual	;ALT_MANUAL
		DW	JoyEleApproach	;ALT_APPROACH
		DW	JoyEleAcquire	;ALT_ACQUIRE
		DW	JoyEleTF	;ALT_TF

;* aileron switch wrt AltMode

JoyAilSwitch	DW	JoyAilManual	;HDG_MANUAL
		DW	JoyAilApproach	;HDG_APPROACH
		DW	JoyAilAcquire	;HDG_ACQUIRE
		DW	JoyAilTrack	;HDG_TRACK

;-------------------------------------
;* auto-pilot keyboard / joystick vars
;-------------------------------------

KBD_AUTO_RPT	EQU	50		;auto-repeat delay (1/100ths sec)

JOY_AUTO_RPT	EQU	50		;auto-repeat delay (1/100ths sec)

AutoThrotDelay	DW	0

TFRideDelay	DW	0

AutoHdgDelay	DW	0

AutoAltDelay	DW	0

;-----------------
;* joystick values
;-----------------

JoyA_X		DW	0
JoyA_Y		DW	0
JoyB_X		DW	0
JoyB_Y		DW	0

OldJoyA_X    	DW	0		;)
OldJoyA_Y    	DW	0		;) previous
OldJoyB_X    	DW	0		;)  values
OldJoyB_Y    	DW	0		;)

;----------------------------
;* joystick conversion values
;----------------------------

JoyVals		LABEL	WORD

		DW	-32766		;0  ) do not use -32768 as values
		DW	-32766		;1  ) may need to be negated
		DW	-21869		;2
		DW	-14596		;3
		DW	-9742 		;4
		DW	-6502 		;5
		DW	-4339 		;6
		DW	-2896 		;7
		DW	-1933  		;8
		DW	-1290  		;9
		DW	-861  		;10
		DW	-575  		;11
		DW	-384		;12
		DW	-256		;13
		DW	0		;14 )
		DW	0		;15 )
		DW	0		;16 ) dead band
		DW	0		;17 )
		DW	0 		;18 )
		DW	256 		;19
		DW	384 		;20
		DW	575 		;21
		DW	861 		;22
		DW	1290		;23
		DW	1933 		;24
		DW	2896		;25
		DW	4339		;26
		DW	6502		;27
		DW	9742		;28
		DW	14596		;29
		DW	21869		;30
		DW	32766		;31
		DW	32766		;32

;--------------------------------
;* pilot / navigator key switches
;--------------------------------

KF_UpdateSwitch	DW	KF_UpdatePilot	;CREW_PILOT
		DW	KF_UpdateNavig	;CREW_NAVIG

KF_ScanSwitch	DW	KF_ScanPilot	;CREW_PILOT
		DW	KF_ScanNavig	;CREW_NAVIG

;----------------------
;* pilot only key flags
;----------------------

;* pilot's control keys

KF_HUDContrast	GAMEKEY	<>	;HUD contrast
KF_HUDSwitch	GAMEKEY	<>	;HUD switch on / off
KF_HUDOption	GAMEKEY <>	;HUD airspeed kts or mach num option

;* camera control keys (for outside views)

KF_ResetTrkCam	GAMEKEY	<>	;reset tracking camera position
KF_ResetSatCam	GAMEKEY	<>	;reset satellite camera position
KF_ResetWpnCam	GAMEKEY <>	;reset weapon view camera position
KF_ZoomIn	GAMEKEY	<>	;camera zoom in
KF_ZoomOut	GAMEKEY	<>	;camera zoom out
KF_FastZoomIn	GAMEKEY	<>	;camera fast zoom in
KF_FastZoomOut	GAMEKEY	<>	;camera fast zoom out
KF_TrackClk    	GAMEKEY	<>	;camera track clockwise
KF_TrackAClk	GAMEKEY	<>	;camera track anti-clockwise
KF_FastTrkClk  	GAMEKEY	<>	;camera fast track clockwise
KF_FastTrkAClk	GAMEKEY	<>	;camera fast track anti-clockwise

;--------------------------
;* navigator only key flags
;--------------------------

;* navigator's control keys

KF_DispSelect	GAMEKEY <>	;select "active" display (has mouse input)
KF_TAB1Select	GAMEKEY	<>	;select lhs TAB mode
KF_TAB1Toggle	GAMEKEY	<>	;lhs TAB on / off
KF_TAB2Select	GAMEKEY	<>	;select rhs TAB mode
KF_TAB2Toggle	GAMEKEY	<>	;rhs TAB on / off

;--------------------------------------
;* common (pilot / navigator) key flags
;--------------------------------------

;* view keys

KF_PilotView	GAMEKEY	<>	;pilot view
KF_NavigView	GAMEKEY	<>	;navigator view
KF_LViewFix	GAMEKEY	<>	;left view (fixed)
KF_RViewFix	GAMEKEY	<>	;right view (fixed)
KF_LViewGlance	GAMEKEY	<>	;left view (glance)
KF_RViewGlance	GAMEKEY	<>	;right view (glance)
KF_TrackingCam	GAMEKEY	<>	;tracking camera
KF_SatelliteCam	GAMEKEY	<>	;satellite camera
KF_RemoteView	GAMEKEY	<>	;remote view
KF_MapView	GAMEKEY	<>	;map view
KF_DroneView	GAMEKEY	<>	;drone view (next)
KF_DronePrev	GAMEKEY	<>	;drone view (previous)
KF_DroneSide	GAMEKEY <>	;drone allied / enemy toggle
KF_DroneType	GAMEKEY <>	;drone air / ground toggle
KF_Spectator	GAMEKEY	<>	;spectator view
KF_RestoreSpec	GAMEKEY	<>	;restore spectator view
KF_LookDown	GAMEKEY	<>	;look down
KF_ViewWeapon	GAMEKEY	<>	;weapon view

;* option keys

KF_Range	GAMEKEY <>	;visual range select
KF_GndText	GAMEKEY	<>	;ground texture select
KF_HillText	GAMEKEY	<>	;hill face texture select
KF_Clouds	GAMEKEY	<>	;clouds select
KF_Horizon	GAMEKEY	<>	;horizon select
KF_IronWork	GAMEKEY	<>	;ironwork select
KF_Control	GAMEKEY	<>	;control select
KF_Sound	GAMEKEY	<>	;sound select
KF_Minimise	GAMEKEY	<>	;minimise / restore select

;* secondary flight controls

KF_Gear		GAMEKEY	<>	;raise / lower undercarriage
KF_WheelBrakes	GAMEKEY	<>	;wheelbrakes
KF_AirBrakes	GAMEKEY	<>	;airbrakes / thrust reversers
KF_WingSwpFwd	GAMEKEY	<>	;wing sweep forwards
KF_WingSwpBack	GAMEKEY	<>	;wing sweep backwards
KF_FlapsUp	GAMEKEY	<>	;flaps up
KF_FlapsDn	GAMEKEY	<>	;flaps down
KF_SPILS	GAMEKEY	<>	;SPILS on / off

;* MFD control keys

KF_MFDSelect	GAMEKEY <>	;select MFD mode
KF_MFDToggle	GAMEKEY <>	;MFD on / off
KF_MapZoomIn	GAMEKEY <>	;moving map zoom in
KF_MapZoomOut	GAMEKEY <>	;moving map zoom out
KF_MapOrigin	GAMEKEY <>	;MFD moving map origin

;* ground / air radar select keys

KF_GndRadar	GAMEKEY	<>	;select ground radar
KF_AirRadar	GAMEKEY	<>	;select air radar
KF_RadarOff	GAMEKEY	<>	;switch radar off

KF_BoreSight	GAMEKEY <>	;air radar bore sight designate
KF_CycleAirTgt	GAMEKEY <>	;cycle air radar targets
KF_CancelAirTgt	GAMEKEY <>	;cancel air radar designation

;* weapon management keys

KF_ArmGnd	GAMEKEY <>	;select ground attack mode
KF_ArmAir	GAMEKEY <>	;select air attack mode
KF_ArmOff	GAMEKEY	<>	;cancel attack mode

KF_Package	GAMEKEY	<>	;select weapons package
KF_WpnMode	GAMEKEY	<>	;select weapon delivery mode
KF_AirWeapon	GAMEKEY <>	;cycle air-to-air weapons

KF_WpnFire	GAMEKEY <>	;weapon fire
KF_WpnCommit	GAMEKEY <>	;weapon commit

;* ECM, chaff and flares keys

KF_ECM		GAMEKEY <>	;ECM on / off toggle
KF_Chaff	GAMEKEY <>	;release chaff
KF_Flare	GAMEKEY <>	;release flare

;* auto-pilot keys

KF_AutoCancel	GAMEKEY <>	;cancel all auto-pilot modes
KF_Approach	GAMEKEY <>	;approach mode
KF_Track	GAMEKEY <>	;track acquire mode (fly to next waypoint)
KF_Hold		GAMEKEY <>	;alt and hdg hold mode
KF_TFollow	GAMEKEY <>	;terrain follow mode
KF_Throttle	GAMEKEY <>	;auto-throttle mode
KF_AutoTrim	GAMEKEY	<>	;auto-trim engage

;* waypoint selection keys

KF_SkipWaypoint	GAMEKEY	<>	;select next waypoint
KF_SelectTgtWP	GAMEKEY	<>	;select target of opportunity waypoint
KF_CancelTgtWP	GAMEKEY	<>	;cancel target of opportunity waypoint

;* jettison keys

KF_JetExtTanks	GAMEKEY	<>	;jettison external fuel tanks
KF_JetExtStores	GAMEKEY	<>	;jettison external stores
KF_JetAll	GAMEKEY	<>	;jettison all

;* miscellaneous keys

KF_Eject	GAMEKEY <>	;eject
KF_CancelAttn	GAMEKEY <>	;cancel attention getters
KF_Recal	GAMEKEY	<>	;recal joystick(s)
KF_JoySensNorm	GAMEKEY	<>	;normal joystick sensitivity
KF_JoySensHigh	GAMEKEY	<>	;high joystick sensitivity

KF_Quit		GAMEKEY	<>	;quit game
KF_Pause	GAMEKEY	<>	;pause / resume

		EVEN

DATA		ENDS

;============================================================================

MODCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:MODCODE
		ASSUME DS:DATA

;* InitModel - initialize model
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

InitModel	PROC	FAR

;-----------------------------
;* init model vars from M_VIEW
;-----------------------------

		mov	ax,M_VIEW.VP_XSEC
		mov	XSec,ax

		mov	ax,M_VIEW.VP_YSEC
		mov	YSec,ax

		mov	ax,M_VIEW.VP_XFT
		mov	Xft,ax

		mov	ax,M_VIEW.VP_YFT
		mov	Yft,ax

		mov	ax,WORD PTR M_VIEW.VP_ZFT_LO
		mov	ZftLo,ax

		mov	ax,WORD PTR M_VIEW.VP_ZFT_HI
		mov	ZftHi,ax

		mov	cl,7		;*128

		mov	ax,M_VIEW.VP_HDG
		shl	ax,cl
		mov	HFine,ax

		mov	ax,M_VIEW.VP_PITCH
		shl	ax,cl
		mov	PFine,ax

		mov	ax,M_VIEW.VP_ROLL
		shl	ax,cl
		mov	RFine,ax

		call	CalcAngles

;---------------------
;* sort start airborne
;---------------------

		test	StartAirborne,1	;start airborne?
		_JZ	SkipAirborne	;no ->

		mov	Throttle,256	;max dry
		mov	Rpm1,100*256
		mov	Rpm2,100*256

		mov	Gear,0		;gear up

		mov	WheelBrakes,0	;wheelbrakes off

		mov	Airborne1,1	;airborne
		mov	Airborne2,1

		mov	StallFlag1,0	;not stalled
		mov	StallFlag1,0

		mov	CrntFlapPos,FLAPS_D_ZERO	;flaps up
		mov	DestFlapPos,FLAPS_D_ZERO

		mov	CrntFlapVal,FLAPS_A_ZERO
		mov	DestFlapVal,FLAPS_A_ZERO

;* calc vtas

		call	CalcAirDensity

;* limit = 17144 = 2.2 * 573 * 1.7 * 8
;*
;* v = StartAirspeed * 1.7 * 8 * 32768 = StartAirspeed * 8 * 55706
;*
;* Vtas = min(v / SqrtRho, limit)

		mov	ax,StartAirspeed
		REPT	3   		;*8
		shl	ax,1
		ENDM
		mov	dx,55706
		mul	dx

		mov	bx,SqrtRho
		div	bx

		cmp	ax,17144
		jbe	@F
		mov	ax,17144

@@:		mov	Vtas,ax
		mov	Vav,ax

;* calc mach number

;* if zft < 36,096ft then
;*    Mach1 = 1123 - 0.0165 * zft / 4 = 1123 - 541 / 32768 * zft / 4
;* else
;*    Mach1 = 974
;* end

		mov	bx,974		;assume zft >= 36,096ft

		cmp	ZftHi,0		;zft > 65,535?
		jne	@F		;yes ->

		mov	ax,ZftLo
		cmp	ax,36096	;zft >= 36,096?
		jae	@F		;yes ->

		REPT	2		;zft / 4
		shr	ax,1
		ENDM

		mov	dx,541
		imul	dx
		FRACADJ	dx		;541 / 32768 * zft / 4

		mov	bx,1123
		sub	bx,dx		;1123 - 541 / 32768 * zft / 4

@@:		mov	Mach1,bx

;* MachNum [*16] = Vtas [*8] * 2 / Mach1
	   
		mov	ax,Vtas

;* ensure Vtas >= 0

		test	ax,ax		;Vtas >= 0?
		jns	@F		;yes ->
		xor	ax,ax

@@:		cwd
		shl	ax,1		;Vtas * 2
		rcl	dx,1	

		idiv	bx		;Vtas * 2 / Mach1

		mov	MachNum,ax

		mov	bl,SWEEP_D_25	;assume 25 deg sweep
		mov	dx,SWEEP_A_25

		cmp	ax,10		;25 deg sweep?
		jbe	@F		;yes ->

		mov	bl,SWEEP_D_45	;assume 45 deg sweep
		mov	dx,SWEEP_A_45

		cmp	ax,12		;45 deg sweep?
		jbe	@F		;yes ->

		mov	bl,SWEEP_D_67
		mov	dx,SWEEP_A_67

@@:		mov	CrntWingPos,bl
		mov	DestWingPos,bl

		mov	CrntWingVal,dx
		mov	DestWingVal,dx

;* engage auto-throttle

		mov	ax,StartAirspeed

		cli			;(in case conflict with kbd adjust)
		mov	AutoVias,ax
		mov	AutoViasFine,0
		mov	AutoThrot,1
		sti

;---------------------
;* init control device
;---------------------

SkipAirborne:	call	InitCtrlDevice

;------------------------------
;* start with damaged engine(s)
;------------------------------

		test	DamagedLEng,1
		jz	@F

		mov	SSF_Engine1,1		;damage engine
		or	RedWarnings2,RED_L_ENG	;report damage

@@:		test	DamagedREng,1
		jz	@F

		mov	SSF_Engine2,1		;damage engine
		or	RedWarnings2,RED_R_ENG	;report damage

;------------------------------
;* sort fixed min weight option
;------------------------------

@@:		test	FixMinWeight,1
		jz	@F

		mov	DebugWeight,1
		mov	FixedWeight,33000

;-----------------
;* init new sector
;-----------------

@@:		call	InitNewSector

		ret

InitModel	ENDP

;----------------------------------------------------------------------------

;* Model - Tornado aircraft model
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

Model		PROC	FAR

		call	CalcDeltaTime

	IF	OPT_TURBO EQ 1

		test	Key[K_BACKSLASH],1
		jz	@F
		mov	LastFrame,100
		mov	DeltaTime,32767
@@:

	ENDIF

		call	UpdateGameKeys

		call	PreAmble

		call	CrossWinds

		call	SortJoysticks

		call	UpdateSweep

		call	UpdateFlaps
		
		call	CalcAirDensity

		call	CalcAirSpeed

		call	CalcGForce

		call	CalcRates

		call	CalcAngles

		call	CalcThrust

		call	CalcFuelFlow

		call	CalcDrag

		call	CalcPosition

		call	CalcAltitude

		call	PostAmble

		ret

Model		ENDP

;----------------------------------------------------------------------------

;* UpdateGameKeys
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

UpdateGameKeys	PROC	NEAR

		test	Paused,1	;paused?
		_JNZ	UpdatePaused	;yes ->

		cmp	DisableInput,0	;input disabled?
		_JNE	UpdateDisabled	;yes ->

		mov	bx,CrewMode
		jmp	KF_UpdateSwitch[bx]

;---------------------------
KF_UpdatePilot	LABEL	NEAR
;---------------------------

	IF	OPT_DEMO EQ 0

		KBOUNCE	KF_HUDContrast
		KBOUNCE	KF_HUDSwitch
		KBOUNCE	KF_HUDOption
		
		KBOUNCE	KF_ResetTrkCam
		KBOUNCE	KF_ResetSatCam
		KBOUNCE	KF_ResetWpnCam
		KFOLLOW	KF_ZoomIn
		KFOLLOW	KF_ZoomOut
		KFOLLOW	KF_FastZoomIn
		KFOLLOW	KF_FastZoomOut
		KFOLLOW	KF_TrackClk
		KFOLLOW	KF_TrackAClk
		KFOLLOW	KF_FastTrkClk
		KFOLLOW	KF_FastTrkAClk

	ENDIF

		jmp	KF_UpdateCommon

;---------------------------
KF_UpdateNavig	LABEL	NEAR
;---------------------------

	IF	OPT_DEMO EQ 0

		KBOUNCE	KF_DispSelect
		KBOUNCE	KF_TAB1Select
		KBOUNCE	KF_TAB1Toggle
		KBOUNCE	KF_TAB2Select
		KBOUNCE	KF_TAB2Toggle

	ENDIF

;---------------------------
KF_UpdateCommon	LABEL	NEAR
;---------------------------

	IF	OPT_DEMO EQ 0

		KBOUNCE	KF_PilotView
		KBOUNCE	KF_NavigView
		KBOUNCE	KF_LViewFix
		KBOUNCE	KF_RViewFix
		KFOLLOW	KF_LViewGlance
		KFOLLOW	KF_RViewGlance
		KBOUNCE	KF_TrackingCam
		KBOUNCE	KF_SatelliteCam
		KBOUNCE	KF_RemoteView
		KBOUNCE	KF_MapView
		KBOUNCE	KF_DroneView
		KBOUNCE	KF_DronePrev
		KBOUNCE	KF_DroneSide
		KBOUNCE	KF_DroneType
		KBOUNCE	KF_Spectator
		KBOUNCE	KF_RestoreSpec
		KBOUNCE	KF_LookDown
		KBOUNCE	KF_ViewWeapon

		KBOUNCE	KF_IronWork
		KBOUNCE	KF_Control
		KBOUNCE	KF_Sound

		KBOUNCE	KF_Gear
		KBOUNCE	KF_WheelBrakes
		KFOLLOW	KF_AirBrakes
		KBOUNCE	KF_WingSwpFwd
		KBOUNCE	KF_WingSwpBack
		KBOUNCE	KF_FlapsUp
		KBOUNCE	KF_FlapsDn
		KBOUNCE	KF_SPILS

		KBOUNCE	KF_MFDSelect
		KBOUNCE	KF_MFDToggle
		KBOUNCE	KF_MapZoomIn
		KBOUNCE	KF_MapZoomOut
		KBOUNCE	KF_MapOrigin

		KBOUNCE	KF_GndRadar
		KBOUNCE	KF_AirRadar
		KBOUNCE	KF_RadarOff
		KBOUNCE	KF_BoreSight
		KBOUNCE	KF_CycleAirTgt
		KBOUNCE	KF_CancelAirTgt

		KBOUNCE	KF_ArmGnd
		KBOUNCE	KF_ArmAir
		KBOUNCE	KF_ArmOff

		KBOUNCE	KF_Package
		KBOUNCE	KF_WpnMode
		KBOUNCE	KF_AirWeapon

		KBOUNCE	KF_WpnFire
		KFOLLOW	KF_WpnCommit

		KBOUNCE	KF_ECM		
		KBOUNCE	KF_Chaff	
		KBOUNCE	KF_Flare

		KBOUNCE	KF_AutoCancel
		KBOUNCE	KF_Approach
		KBOUNCE	KF_Track
		KBOUNCE	KF_Hold
		KBOUNCE	KF_TFollow
		KBOUNCE	KF_Throttle
		KBOUNCE	KF_AutoTrim

		KBOUNCE	KF_SkipWaypoint
		KBOUNCE	KF_SelectTgtWP
		KBOUNCE	KF_CancelTgtWP

		KBOUNCE	KF_JetExtTanks
		KBOUNCE	KF_JetExtStores
		KBOUNCE	KF_JetAll

		KBOUNCE	KF_Eject
		KBOUNCE	KF_CancelAttn
		KBOUNCE	KF_Recal
		KBOUNCE	KF_JoySensNorm
		KBOUNCE	KF_JoySensHigh

	ENDIF

		jmp	ContGameKeys

;---------------------------
UpdateDisabled	LABEL	NEAR	;update when input disabled
;---------------------------

		KCLEAR	KF_HUDContrast
		KCLEAR	KF_HUDSwitch
		KCLEAR	KF_HUDOption
		
		KCLEAR	KF_ResetTrkCam
		KCLEAR	KF_ResetSatCam
		KCLEAR	KF_ResetWpnCam
		KCLEAR	KF_ZoomIn
		KCLEAR	KF_ZoomOut
		KCLEAR	KF_FastZoomIn
		KCLEAR	KF_FastZoomOut
		KCLEAR	KF_TrackClk
		KCLEAR	KF_TrackAClk
		KCLEAR	KF_FastTrkClk
		KCLEAR	KF_FastTrkAClk

		KCLEAR	KF_DispSelect
		KCLEAR	KF_TAB1Select
		KCLEAR	KF_TAB1Toggle
		KCLEAR	KF_TAB2Select
		KCLEAR	KF_TAB2Toggle

		KCLEAR	KF_PilotView
		KCLEAR	KF_NavigView
		KCLEAR	KF_LViewFix
		KCLEAR	KF_RViewFix
		KCLEAR	KF_LViewGlance
		KCLEAR	KF_RViewGlance
		KCLEAR	KF_TrackingCam
		KCLEAR	KF_SatelliteCam
		KCLEAR	KF_RemoteView
		KCLEAR	KF_MapView
		KCLEAR	KF_DroneView
		KCLEAR	KF_DronePrev
		KCLEAR	KF_DroneSide
		KCLEAR	KF_DroneType
		KCLEAR	KF_Spectator
		KCLEAR	KF_RestoreSpec
		KCLEAR	KF_LookDown
		KCLEAR	KF_ViewWeapon

		KCLEAR	KF_IronWork
		KCLEAR	KF_Control
		KCLEAR	KF_Sound

		KCLEAR	KF_Gear
		KCLEAR	KF_WheelBrakes
		KCLEAR	KF_AirBrakes
		KCLEAR	KF_WingSwpFwd
		KCLEAR	KF_WingSwpBack
		KCLEAR	KF_FlapsUp
		KCLEAR	KF_FlapsDn
		KCLEAR	KF_SPILS

		KCLEAR	KF_MFDSelect
		KCLEAR	KF_MFDToggle
		KCLEAR	KF_MapZoomIn
		KCLEAR	KF_MapZoomOut
		KCLEAR	KF_MapOrigin

		KCLEAR	KF_GndRadar
		KCLEAR	KF_AirRadar
		KCLEAR	KF_RadarOff
		KCLEAR	KF_BoreSight
		KCLEAR	KF_CycleAirTgt
		KCLEAR	KF_CancelAirTgt

		KCLEAR	KF_ArmGnd
		KCLEAR	KF_ArmAir
		KCLEAR	KF_ArmOff

		KCLEAR	KF_Package
		KCLEAR	KF_WpnMode
		KCLEAR	KF_AirWeapon

		KCLEAR	KF_WpnFire
		KCLEAR	KF_WpnCommit

		KCLEAR	KF_ECM		
		KCLEAR	KF_Chaff	
		KCLEAR	KF_Flare

		KCLEAR	KF_AutoCancel
		KCLEAR	KF_Approach
		KCLEAR	KF_Track
		KCLEAR	KF_Hold
		KCLEAR	KF_TFollow
		KCLEAR	KF_Throttle
		KCLEAR	KF_AutoTrim

		KCLEAR	KF_SkipWaypoint
		KCLEAR	KF_SelectTgtWP
		KCLEAR	KF_CancelTgtWP

		KCLEAR	KF_JetExtTanks
		KCLEAR	KF_JetExtStores
		KCLEAR	KF_JetAll

		KCLEAR	KF_Eject
		KCLEAR	KF_CancelAttn
		KCLEAR	KF_Recal
		KCLEAR	KF_JoySensNorm
		KCLEAR	KF_JoySensHigh

ContGameKeys:	KBOUNCE	KF_Range
		KBOUNCE	KF_GndText
		KBOUNCE	KF_HillText
		KBOUNCE	KF_Clouds
		KBOUNCE	KF_Horizon
		KBOUNCE	KF_Minimise

;---------------------------
UpdatePaused	LABEL	NEAR	;update when input disabled or paused
;---------------------------

		KBOUNCE	KF_Quit
		KBOUNCE	KF_Pause

		ret

UpdateGameKeys	ENDP

;----------------------------------------------------------------------------

;* PreAmble - model preamble
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

PreAmble	PROC	NEAR

;--------------------------
;* store previous viewpoint (for collision testing)
;--------------------------

		COPY_VP	M_TEST,M_VIEW

;---------------
;* sort jettison
;---------------

;* jettison interlock - must be airborne and erect

		test	Airborne1,1	;airborne?
		jz	JettisonOk	;no ->

		test	M_CosR,0ffffh	;erect?
		js	JettisonOk	;no ->

		KTEST	KF_JetAll	;jettison all?
		jz	@F		;no ->

		call	JetAll

		jmp	JettisonOk

@@:		KTEST	KF_JetExtStores	;jettison ext stores?
		jz	@F		;no ->

		call	JetExtStores

		jmp	JettisonOk

@@:		KTEST	KF_JetExtTanks	;jettison ext fuel tanks?
		jz	JettisonOk	;no ->

		call	JetExtTanks

;----------------------
;* calc aircraft weight
;----------------------

JettisonOk:	test	DebugWeight,1	;debug weight?
		jz	@F		;no ->

		mov	ax,FixedWeight

		jmp	SetWeight

;* Weight = MIN_WEIGHT + StoresWt + FuelWt

@@: 		call	CalcStoresWt

		mov	ax,MIN_WEIGHT
		add	ax,StoresWt
		MAXM	ax
		add	ax,FuelWt
		MAXM	ax

SetWeight:	mov	Weight,ax

;* Weight2 = Weight / 2

		shr	ax,1		;/2
		mov	Weight2,ax

;--------------------
;* sort undercarriage (toggle up / down, unchanged if damaged)
;--------------------

;* gear stuck if damaged

		mov	al,SSF_Gear
		test	al,al		;damaged?
		jnz	SkipGear	;yes ->

;* update gear timer

		mov	ax,GearTimer
		sub	ax,LastFrame
		MINM	ax
		mov	GearTimer,ax

		KTEST	KF_Gear		;raise / lower undercarriage?
		jz	SkipGear	;no ->

		mov	al,Airborne1
		test	al,al		;airborne?
		jz	SkipGear	;no ->

		test	HitHill,1	;hit hill?
		jnz	SkipGear	;yes ->

		xor	Gear,1		;toggle up / down

		mov	ax,GEAR_TIME
		sub	ax,GearTimer
		mov	GearTimer,ax

		call	GearSound

;------------------
;* sort wheelbrakes (toggle on / off, off if damaged)
;------------------

SkipGear:	mov	al,SSF_WheelBrakes
		test	al,al		;damaged?
		mov	al,0		;assume so
		jnz	@F		;yes ->

		KTEST	KF_WheelBrakes	;wheelbrakes on / off?
		jz	SkipWBrakes	;no ->

		mov	al,WheelBrakes
		xor	al,1		;toggle on / off

@@:		mov	WheelBrakes,al

;-------------------------------------
;* sort airbrakes and thrust reversers (on whilst key held, off if damaged)
;-------------------------------------

SkipWBrakes:	mov	AirBrakes,0
		mov	ThrustRvrs,0

		KFETCH	KF_AirBrakes

		or	al,JoyB_Fire1

		test	AirBorne1,1	;airbrakes or thrust reversers?
		jz	@F		;thrust reversers ->
		
		test	SSF_AirBrakes,1	;damaged?
		jnz	SkipAirBrakes	;yes ->

		mov	AirBrakes,al

		jmp	SkipAirBrakes

@@:		test	SSF_ThrustRvrs,1	;damaged?
		jnz	SkipAirBrakes		;yes ->

		mov	ThrustRvrs,al

;* if thrust reversers on and thrust > max dry then start engine fire

		test	al,al		;thrust reversers on?
		jz	SkipAirBrakes	;no ->

		cmp	Thrust1,9000	;thrust > max dry?
		jbe	@F		;no ->

		mov	EngFire1,1		;start engine fire
		or	RedWarnings2,RED_L_FIRE	;report damage

@@:		cmp	Thrust2,9000	;thrust > max dry?
		jbe	@F		;no ->

		mov	EngFire2,1		;start engine fire
		or	RedWarnings2,RED_R_FIRE	;report damage

;* if thrust reversers on and vtas < 25kts then damage engines

@@:		cmp	Vtas,43*8	;vtas < 25kts?
		jae	SkipAirBrakes	;no ->

		cmp	Thrust1,0	;engine 1 developing thrust?
		je	@F		;no ->

		mov	SSF_Engine1,1		;damage engine
		or	RedWarnings2,RED_L_ENG	;report damage

@@:		cmp	Thrust2,0	;engine 2 developing thrust?
		je	SkipAirBrakes	;no ->

		mov	SSF_Engine2,1		;damage engine
		or	RedWarnings2,RED_R_ENG	;report damage

;------------
;* sort SPILS (toggle on / off, off if damaged)
;------------

SkipAirBrakes:	mov	al,SSF_SPILS
		test	al,al		;damaged?
		mov	al,0		;assume so
		jnz	@F		;yes ->

		KTEST	KF_SPILS	;SPILS on / off?
		jz	SkipSPILS	;no ->

		mov	al,SPILS
		xor	al,1		;toggle on / off

@@:		mov	SPILS,al

;----------------
;* sort auto-trim
;----------------

SkipSPILS:	KTEST	KF_AutoTrim	;centre controls and engage auto-trim?
		jz	SkipAutoTrim	;no ->

;* check auto-pilot is off

		cmp	AutoMode,AUTO_OFF	;off?
		jne	SkipAutoTrim		;no ->

		xor	ax,ax		;centre controls
		mov	ElePosn,ax
		mov	AilPosn,ax
		mov	RudPosn,ax

;* engage auto-trim only if GCoord +ve

		cmp	GCoord,0	;+ve?
		jl	SkipAutoTrim	;no ->

		mov	AutoTrim,1

;-------------------------
;* recalibrate joystick(s)
;-------------------------

SkipAutoTrim:	KTEST	KF_JoySensNorm
		jz	@F

		mov	JoySensitivity,0

@@:		KTEST	KF_JoySensHigh
		jz	@F

		mov	JoySensitivity,1

@@:		KTEST	KF_Recal
		jz	SkipRecal

		call	InitCtrlDevice

;------------
;* sort eject (check before ECM as share same key)
;------------

SkipRecal:	KTEST	KF_Eject	;eject?
		jz	SkipEject	;no ->

		call	StartEjectSeq

		jmp	SkipECM

;-----------------
;* sort ECM toggle
;-----------------

SkipEject:	KTEST	KF_ECM		;toggle ECM?
		jz	SkipECM		;no ->

		test	SSF_ECM,1	;damaged?
		jnz	SkipECM		;yes ->

		mov	al,ECMFitted
		xor	ECMActive,al

;------------------------------
;* sort quit game / end mission
;------------------------------

SkipECM:	KTEST	KF_Quit		;quit?
		jz	SkipQuit	;no ->

;* if TmpDieFlag <> 0 then
;*    DieFlag = TmpDieFlag
;* else
;*    DieFlag = DIE_QUIT
;* endif

		mov	al,TmpDieFlag

		test	al,al
		jnz	@F

		mov	al,DIE_QUIT

@@:		mov	DieFlag,al

;* check landing flags

		test	Airborne1,1	;airborne?
		jnz	SkipQuit	;yes ->

;* check if enemy territory

		cmp	ModelMapIndex,-1
		je	@F

		mov	bp,ModelMapIndex

		test	SctrGameLayer1[bp],SECT_ENEMY
		jz	@F

		or	Landing,LAND_ENEMY

;* check if stationary

@@:		cmp	Vtas,0		;stationary?
		ja	SkipQuit	;no ->

		or	Landing,LAND_STATIONARY

SkipQuit:	ret

PreAmble	ENDP

;----------------------------------------------------------------------------

;* CrossWinds - update crosswinds
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

CrossWinds	PROC	NEAR

		cmp	XWindVmax,0	;crosswinds enabled?
		_JE	ExitWinds	;no ->

;------------------------------------
;* attenuate wind with aircraft speed (cancels wind effect for auto-pilot)
;------------------------------------

;* start fade at 150kts (tas), fully faded by 225kts (tas)

		mov	ax,Vtas
		UBOUND	ax,2048,3071
		sub	ax,2048
		mov	dx,1023
		sub	dx,ax
		mov	cl,5
		shl	dx,cl
		mov	XWindFade,dx
		jnz	@F

;* fully faded, clear variables

		xor	ax,ax

		mov	XWindVeff,ax
		mov	XWindDXft,ax
		mov	XWindDXFine,ax
		mov	XWindDYft,ax
		mov	XWindDYFine,ax

		jmp	ExitWinds

;-----------------------
;* change wind direction
;-----------------------

@@:		mov	ax,XWindDirTimer
		sub	ax,LastFrame
		jnc	@F

;* calc random number -2 .. 2

		call	RandX
		shl	ax,1		;ah =  0 .. 1
		shl	ax,1		;ah =  0 .. 3
		shl	al,1
		adc	ah,0		;ah =  0 .. 4
		sub	ah,2		;ah = -2 .. 2
		mov	al,ah
		cbw

		add	XWindDir,ax
		and	XWindDir,511

		mov	ax,XWIND_DIR_INT

@@:		mov	XWindDirTimer,ax

;------------------
;* change windspeed
;------------------

;* check if reached aiming windspeed

		mov	ax,XWindVtas
		cmp	ax,XWindVaim
		jne	ContWindspeed

;* calc new aiming windspeed
;*
;* XWindVaim = max(XWindVmax * random(0 .. 1), XWindVmax / 16)

		call	RandX
		xchg	al,ah
		shr	ax,1		;0 .. 32767
		mov	bp,XWindVmax
		imul	bp
		FRACADJ	ax

		REPT	4
		shr	bp,1
		ENDM

		cmp	ax,bp
		jae	@F
		mov	ax,bp

@@:		mov	XWindVaim,ax

;* calc new gust acceleration
;*
;* XWindVaim = max(XWindVmax / 4 * random(0 .. 1), XWindVmax / 16)

		call	RandX
		xchg	al,ah
		shr	ax,1		;0 .. 32767
		mov	bp,XWindVmax
		REPT	2		;/4
		shr	bp,1
		ENDM
		imul	bp
		FRACADJ	ax

		REPT	2		;/4
		shr	bp,1
		ENDM

		cmp	ax,bp
		jae	@F
		mov	ax,bp

@@:		mov	XWindGust,ax

;* calc new windspeed

ContWindspeed: 	mov	ax,XWindGust
		mov	dx,DeltaTime
		imul	dx
		FRACADJ	bp
		jnz	@F
		inc	bp

@@:		mov	ax,XWindVaim
		sub	ax,XWindVtas
		ABSV	ax

		cmp	ax,bp		;error < change?
		jae	@F		;no ->
		mov	bp,ax		;change = error

@@:		xor	bp,dx
		sub	bp,dx

		add	XWindVtas,bp

;* fade windspeed

		mov	ax,XWindVtas
		mov	dx,XWindFade
		imul	dx
		FRACADJ	dx
		mov	XWindVfix,dx

;* calc effective vtas
;*
;* XWindVeff = max(cos((hdg - XWindDir) and 511), 0) * cos(pitch) * XWindVfix

		mov	bx,Hdg
		sub	bx,XWindDir
		and	bx,511
		COSINE	ax,bx

		test	ax,ax
		jns	@F
		xor	ax,ax

@@:		mov	dx,M_CosP
		imul	dx
		FRACADJ	dx

		mov	ax,XWindVfix
		imul	dx
		FRACADJ	dx

		mov	XWindVeff,dx

;------------------------------
;* calc delta xft and delta yft (wrt windspeed and direction)
;------------------------------

;* calc sin(wind dir + 180), cos(wind dir + 180)

		mov	bx,XWindDir
		add	bx,256
		and	bx,511

		SINCOS	si,di,bx

;* scale vtas by 32 to retain resolution (vtas = 1023 max (approx 75kts)))

		mov	bp,XWindVfix
		mov	cl,5
		shl	bp,cl

;----------------
;* calc delta xft = sin(wind dir + 180) * XWindVfix * DeltaTime
;----------------

		mov	ax,bp
		imul	si
		FRACADJ	dx
		mov	ax,DeltaTime
		imul	dx
		REPT	7
		sar	dx,1
		rcr	ax,1
		ENDM

		mov	XWindDXft,dx
		mov	XWindDXFine,ax

;----------------
;* calc delta yft = cos(wind dir + 180) * XWindVfix * DeltaTime
;----------------

		mov	ax,bp
		imul	di
		FRACADJ	dx
		mov	ax,DeltaTime
		imul	dx
		REPT	7
		sar	dx,1
		rcr	ax,1
		ENDM

		mov	XWindDYft,dx
		mov	XWindDYFine,ax

ExitWinds:	ret

CrossWinds	ENDP

;----------------------------------------------------------------------------

;* SortJoysticks - process joystick input (if selected)
;*
;* pass: ControlDevice
;* ret : nothing
;* kill: assume all
;*
;* Manual controls:-
;*
;*    JoyA_X -> AilPosn
;*    JoyA_Y -> ElePosn
;*    JoyB_X -> RudPosn
;*    JoyB_Y -> Throttle / Reheat
;*
;* Auto-pilot controls:-
;*
;*    JoyA_X -> heading acquire
;*    JoyA_Y -> altitude / ride altitude acquire
;*    JoyB_Y -> airspeed acquire

SortJoysticks	PROC	NEAR

;---------------------
;* sort control device
;---------------------

		cmp	ControlDevice,CTRL_DEV_JOY1
		je	TestJoy1
		cmp	ControlDevice,CTRL_DEV_JOY2
		je	TestJoy2

		jmp	ExitJoysticks

TestJoy1:	test	JoyA_Flag,1	;single joystick fitted?
		jnz	@F	   	;yes ->

		call	InitCtrlDevice

		jmp	ExitJoysticks	;assume default to keyboard

TestJoy2:	mov	al,JoyA_Flag
		test	al,JoyB_Flag 	;both joysticks fitted?
		jnz	@F	     	;yes ->

		call	InitCtrlDevice

		jmp	ExitJoysticks	;assume default to keyboard

;-------------------------
;* check if input disabled
;-------------------------

@@:		cmp	DisableInput,0	;input disabled?
		je	@F		;no ->

		xor	ax,ax		;reset all controls

		mov	ElePosn,ax
		mov	AilPosn,ax
		mov	RudPosn,ax

		mov	JoyA_X,ax
		mov	JoyA_Y,ax
		mov	JoyB_X,ax
		mov	JoyB_Y,ax

		mov	OldJoyA_X,ax
		mov	OldJoyA_Y,ax
		mov	OldJoyB_X,ax
		mov	OldJoyB_Y,ax

		mov	JoyA_Fire1,al
		mov	JoyA_Fire2,al
		mov	JoyA_JustFired1,al
		mov	JoyA_JustFired2,al

		mov	JoyB_Fire1,al
		mov	JoyB_Fire2,al
		mov	JoyB_JustFired1,al
		mov	JoyB_JustFired2,al

		jmp	ExitJoysticks

;----------------
;* read joysticks
;----------------

@@:		call	ReadJoysticks

;* sort joystick A values

		mov	ax,JoyA_X
		mov	OldJoyA_X,ax
		mov	ax,JoyA_Y
		mov	OldJoyA_Y,ax

		mov	bx,JoyA_XVal
		shl	bx,1
		mov	ax,JoyVals[bx]
		mov	JoyA_X,ax

		mov	bx,JoyA_YVal
		shl	bx,1
		mov	ax,JoyVals[bx]
		mov	JoyA_Y,ax

		cmp	ControlDevice,CTRL_DEV_JOY1
		_JE	JoyElevators
		
;* sort joystick B values

		mov	ax,JoyB_X
		mov	OldJoyB_X,ax
		mov	ax,JoyB_Y
		mov	OldJoyB_Y,ax

		mov	bx,JoyB_XVal
		shl	bx,1
		mov	ax,JoyVals[bx]
		mov	JoyB_X,ax

		mov	bx,JoyB_YVal
		shl	bx,1
		mov	ax,JoyVals[bx]
		mov	JoyB_Y,ax

;===========================
JoyRudder	LABEL	NEAR
;===========================

;* no rudder input if auto-pilot selected

		xor	ax,ax		;assume no input

		cmp	AutoMode,AUTO_OFF	;auto-pilot?
		jne	@F			;yes ->

		mov	ax,JoyB_X

@@:		mov	RudPosn,ax

;===========================
JoyThrottle	LABEL	NEAR
;===========================

		test	AutoThrot,1	;auto-throttle?
		_JNZ	JoyAutoThrot	;yes ->

;-----------------
;* manual throttle
;-----------------

		mov	ax,JoyB_Y

		neg	ax		;flip joystick sense

		_JZ	JoyElevators	;no deflection ->

;* throttle change = (joy val * (100 * 256 / 32768) * DeltaTime * 2) / 128

		mov	dx,100*256
		imul	dx
		FRACADJ	dx

		mov	ax,DeltaTime
		imul	dx

		REPT	6		;* 2 / 128
		sar	dx,1
		rcr	ax,1
		ENDM
			      
		test	dx,dx		;open or close?

		js	JoyCloseThrot	;close ->

;---------------
;* open throttle
;---------------

		mov	bx,Reheat
		or	bx,ReheatFine	;adjust reheat?
		jnz	JoyIncReheat	;yes ->

		cmp	Throttle,256	;max throttle?
		je	JoyReheatOn	;yes, test for engage reheat ->

		add	ThrottleFine,ax
		adc	Throttle,dx

		cmp	Throttle,256	;exceed max throttle?
		jb	@F		;no ->

		mov	Throttle,256
		mov	ThrottleFine,0

@@:		jmp	JoyElevators

JoyIncReheat:	add	ReheatFine,ax
		adc	Reheat,dx

		cmp	Reheat,128	;exceed max reheat?
		jb	@F		;no ->

		mov	Reheat,128
		mov	ReheatFine,0

@@:		jmp	JoyElevators

;* release joystick and push again to engage reheat

JoyReheatOn:	cmp	OldJoyB_Y,0	;joystick released last frame?
		jne	@F		;no ->

		mov	Reheat,0
		mov	ReheatFine,1
		 
@@:		jmp	JoyElevators

;----------------
;* close throttle
;----------------

JoyCloseThrot:	mov	bx,Reheat
		or	bx,ReheatFine	;adjust reheat?
		jnz	JoyDecReheat	;yes ->

		cmp	Throttle,256	;max throttle?
		je	JoyReheatOff	;yes, test for disengage reheat ->

		add	ThrottleFine,ax
		adc	Throttle,dx

		jns	@F

		mov	Throttle,0
		mov	ThrottleFine,0

@@:		jmp	JoyElevators

JoyDecReheat: 	add	ReheatFine,ax
		adc	Reheat,dx

		jns	@F

		mov	Reheat,0
		mov	ReheatFine,0

@@:		jmp	JoyElevators

;* release joystick and pull again to disengage reheat

JoyReheatOff:	cmp	OldJoyB_Y,0	;joystick released last frame?
		jne	@F		;no ->

		mov	Throttle,255
		mov	ThrottleFine,65535
		
@@:		jmp	JoyElevators

;------------------------------
;* increase / decrease AutoVias
;------------------------------

;* do not adjust AutoVias if approach mode

JoyAutoThrot:	cmp	AutoMode,AUTO_APPROACH	;approach mode?
		je	JoyElevators		;yes ->

		mov	ax,JoyB_Y

		neg	ax		;flip joystick sense

;* delta = LastFrame * 2 * joy val

		mov	dx,LastFrame
		shl	dx,1
		imul	dx

		add	AutoViasFine,ax
		adc	AutoVias,dx

		jns	@F		;>= 0 ->

		mov	AutoVias,0
		mov	AutoViasFine,0

		jmp	JoyElevators

@@:		cmp	AutoVias,MAX_AUTO_VIAS
		jb	JoyElevators

		mov	AutoVias,MAX_AUTO_VIAS
		mov	AutoViasFine,0

;===========================
JoyElevators	LABEL	NEAR
;===========================

		mov	bx,AltMode
		jmp	JoyEleSwitch[bx]

;---------------------------
JoyEleManual	LABEL	NEAR
;---------------------------

     		mov	ax,JoyA_Y

		mov	ElePosn,ax

;* if elevator demand then cancel auto-trim

		test	ax,ax		;elevator demand?
		jz	@F		;no ->

		mov	AutoTrim,0	;cancel auto-trim

@@:		jmp	JoyAilerons

;---------------------------
JoyEleApproach	LABEL	NEAR
;---------------------------

		mov	ElePosn,0

		jmp	JoyAilerons

;---------------------------
JoyEleAcquire	LABEL	NEAR
;---------------------------

		mov	ElePosn,0

;* sort n wrt joystick deflection

		mov	ax,JoyA_Y

		ABSV	ax

		mov	cl,1		;2^1
		cmp	ax,1024
		jb	@F

		mov	cl,2		;2^2
		cmp	ax,4096
		jb	@F

		mov	cl,3		;2^3
		cmp	ax,8192
		jb	@F

		mov	cl,4		;2^4

@@:		mov	ax,JoyA_Y

;* delta = LastFrame * 2^n * joy val

		mov	dx,LastFrame
		shl	dx,cl
		imul	dx

		add	AutoAltFine,ax
		adc	AutoAlt,dx

		jns	@F		;>= 0 ->

		mov	AutoAlt,MIN_AUTO_ALT
		mov	AutoAltFine,0

		jmp	JoyAilerons

@@:		cmp	AutoAlt,MIN_AUTO_ALT
		jae	@F

		mov	AutoAlt,MIN_AUTO_ALT
		mov	AutoAltFine,0

		jmp	JoyAilerons

@@:		cmp	AutoAlt,MAX_AUTO_ALT
		jb	JoyAilerons

		mov	AutoAlt,MAX_AUTO_ALT
		mov	AutoAltFine,0

		jmp	JoyAilerons

;---------------------------
JoyEleTF	LABEL	NEAR
;---------------------------

		mov	ElePosn,0

		cmp	JoyA_Y,0	;joystick held?
		je	JoyAilerons	;no ->

		cmp	OldJoyA_Y,0	;joystick released last frame?
		jne	@F		;no ->

		mov	TFRideDelay,JOY_AUTO_RPT

		jmp	ContJoyRide

@@:		mov	ax,TFRideDelay
		test	ax,ax		;end of auto-rpt delay?
		jz	ContJoyRide	;yes ->
		sub	ax,LastFrame
		MINM	ax
		mov	TFRideDelay,ax
		jmp	JoyAilerons

ContJoyRide:	cmp	JoyA_Y,0	;inc or dec ride alt?
		jl	@F		;dec ->

		cmp	TFRideIndex,MAX_TF_INDEX	;max limit?
		je	JoyAilerons			;yes ->

		add	TFRideIndex,2	;inc ride alt index

		mov	TFRideDelay,JOY_AUTO_RPT

		jmp	JoyAilerons

@@:		cmp	TFRideIndex,0	;min limit?
		je	JoyAilerons	;yes ->

		sub	TFRideIndex,2	;dec ride alt index

		mov	TFRideDelay,JOY_AUTO_RPT

;===========================
JoyAilerons	LABEL	NEAR
;===========================

		mov	bx,HdgMode
		jmp	JoyAilSwitch[bx]

;---------------------------
JoyAilManual	LABEL	NEAR
;---------------------------

;* //MOD// 03.12.1992 - Roll inertia added.

;* max rate = delta time * 2

		mov	bp,DeltaTime

		shl	bp,1

;* rate = new rate - old rate
;*
;* new rate = min(abs(rate), max rate) * sign(rate) + old rate
;*
;* use 32 bit maths

		mov	ax,AilPosn	;old rate
		cwd			
		mov	bx,ax
		mov	cx,dx

		mov	ax,JoyA_X   	;new rate
		cwd

		sub	ax,bx 		;new rate - old rate
		sbb	dx,cx

		mov	si,dx		;store sign(rate)

		jns	@F

		NEG32	dx,ax

@@:		test	dx,dx		;abs(rate) > 65535?
		jnz	@F		;yes ->

		cmp	ax,bp		;abs(rate) <= max rate?
		jbe	RRateOk		;yes ->

@@:		mov	ax,bp		;limit

RRateOk:	test	si,si		;negate?
		jns	@F		;no ->

		neg	ax

@@:		add	AilPosn,ax

		jmp	ExitJoysticks

;---------------------------
JoyAilApproach	LABEL	NEAR
;---------------------------

		mov	AilPosn,0

		jmp	ExitJoysticks

;---------------------------
JoyAilAcquire	LABEL	NEAR
;---------------------------

		mov	AilPosn,0

		mov	ax,JoyA_X

;* delta = LastFrame * 2 * joy val

		mov	dx,LastFrame
		shl	dx,1
		imul	dx

		add	AutoHdgFine,ax
		adc	AutoHdg,dx

		jns	@F		;>= 0 ->

		mov	AutoHdg,MAX_AUTO_HDG	;wrap around

		jmp	ExitJoysticks

@@:		cmp	AutoHdg,MAX_AUTO_HDG
		jbe	ExitJoysticks

		mov	AutoHdg,0		;wrap around

		jmp	ExitJoysticks

;---------------------------
JoyAilTrack	LABEL	NEAR
;---------------------------

		mov	AilPosn,0

ExitJoysticks:	ret

SortJoysticks	ENDP

;----------------------------------------------------------------------------

;* UpdateSweep
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

UpdateSweep	PROC	NEAR

;---------------------------------------------------------------
;* wing sweep disabled whilst flaps active or wing sweep damaged
;---------------------------------------------------------------

		mov	al,FlapsActive
		or	al,SSF_Sweep	;flaps active or wing sweep damaged?
		jz	@F		;no ->

		jmp	SweepExit

;------------------------------
;* test for wing sweep forwards
;------------------------------

@@:		KTEST	KF_WingSwpFwd	;sweep forwards?
		jz	SkipSweepFwd	;no ->

		mov	al,DestWingPos
		cmp	al,SWEEP_D_25	;can wings go forward?
		je	SkipSweepFwd	;no ->
		dec	al		;new destination position

;----------------------------------------------
;* test if new wing sweep position is inhibited
;----------------------------------------------

		xor	bh,bh

		mov	bl,al
		shl	bl,1		;*2
		shl	bl,1		;*4
		add	bl,CrntFlapPos			
		test	PosInhibit[bx],1;inhibited?
		jz	SkipSweepFwd	;yes ->

		mov	DestWingPos,al

;* look up destination wing setting

		mov	bl,al
		xor	bh,bh
		shl	bx,1		;*2 word index
		mov	ax,WingSetting[bx]
		mov	DestWingVal,ax

;-------------------------------
;* test for wing sweep backwards
;-------------------------------

SkipSweepFwd:	KTEST	KF_WingSwpBack	;sweep backwards?
		jz	SkipSweepBack	;no ->

		mov	al,DestWingPos
		cmp	al,SWEEP_D_67	;can wings go backward?
		je	SkipSweepBack	;no ->
		inc	al		;new destination position
	
;----------------------------------------------
;* test if new wing sweep position is inhibited
;----------------------------------------------

		xor	bh,bh

		mov	bl,al
		shl	bl,1		;*2
		shl	bl,1		;*4
		add	bl,CrntFlapPos			
		test	PosInhibit[bx],1;inhibited?
		jz	SkipSweepBack	;yes ->

		mov	DestWingPos,al

;* look up destination wing setting

		mov	bl,al
		xor	bh,bh
		shl	bx,1		;*2 word index
		mov	ax,WingSetting[bx]
		mov	DestWingVal,ax

;----------------------------------------
;* update wing sweep if changing position
;----------------------------------------

SkipSweepBack:	mov	SweepActive,0	;assume inactive

		mov	ax,CrntWingVal
		cmp	ax,DestWingVal
		je	SweepExit

		mov	SweepActive,1

		jl	MoveWingsBack

;* move wings forward (current > dest)

		mov	dx,ax		;dx = previous value
		sub	ax,LastFrame	;ax = new value

		cmp	ax,DestWingVal	;crossed destination position?
		jle	SetWingDest	;yes ->

		cmp	dx,SWEEP_A_45	;crossed 45 deg sweep position?
		jl 	SetWingVal	;no ->
		cmp	ax,SWEEP_A_45	;crossed 45 deg sweep position?
		jg	SetWingVal	;no ->

		mov	CrntWingPos,SWEEP_D_45
		jmp	SetWingVal

;* move wings backward (current < dest)

MoveWingsBack:	mov	dx,ax		;dx = previous value
		add	ax,LastFrame	;ax = new value

		cmp	ax,DestWingVal	;crossed destination position?
		jge	SetWingDest	;yes ->

		cmp	dx,SWEEP_A_45	;crossed 45 deg sweep position?
		jg 	SetWingVal	;no ->
		cmp	ax,SWEEP_A_45	;crossed 45 deg sweep position?
		jl	SetWingVal	;no ->

		mov	CrntWingPos,SWEEP_D_45
		jmp	SetWingVal

SetWingDest:	mov	al,DestWingPos
		mov	CrntWingPos,al
		mov	ax,DestWingVal
SetWingVal:	mov	CrntWingVal,ax

SweepExit:	ret

UpdateSweep	ENDP

;----------------------------------------------------------------------------

;* UpdateFlaps
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

UpdateFlaps	PROC	NEAR

;----------------------------------------------------------
;* flaps disabled whilst wing sweep active or flaps damaged
;----------------------------------------------------------

		mov	al,SweepActive
		or	al,SSF_Flaps	;sweep active or flaps damaged?
		jz	@F		;no ->

		jmp	FlapsExit

;-------------------
;* test for flaps up
;-------------------

;* sort manoeuvre flaps in on joystick B button 2

@@:		test	JoyB_JustFired2,1
		jz	@F

		cmp	CrntFlapVal,FLAPS_A_MNVR
		je	IntoFlapsUp

@@:		KTEST	KF_FlapsUp	;flaps up?
		jz	SkipFlapsUp	;no ->

IntoFlapsUp:	mov	al,DestFlapPos
		cmp	al,FLAPS_D_ZERO	;can flaps go up?
		je	SkipFlapsUp	;no ->
		dec	al		;new destination position

;-----------------------------------------
;* test if new flaps position is inhibited
;-----------------------------------------

		xor	bh,bh

		mov	bl,CrntWingPos
		shl	bl,1		;*2
		shl	bl,1		;*4
		add	bl,al
		test	PosInhibit[bx],1;inhibited?
		jz	SkipFlapsUp	;yes ->

		mov	DestFlapPos,al

;* look up destination flap setting

		mov	bl,al
		xor	bh,bh
		shl	bx,1		;*2 word index
		mov	ax,FlapSetting[bx]
		mov	DestFlapVal,ax

;---------------------
;* test for flaps down
;---------------------

;* sort manoeuvre flaps out on joystick B button 2

SkipFlapsUp:	test	JoyB_JustFired2,1
		jz	@F

		cmp	CrntFlapVal,FLAPS_A_ZERO
		je	IntoFlapsDn

@@:		KTEST	KF_FlapsDn	;flaps down?
		jz	SkipFlapsDn	;no ->

IntoFlapsDn:	mov	al,DestFlapPos
		cmp	al,FLAPS_D_FULL	;can flaps go down?
		je	SkipFlapsDn	;no ->
		inc	al		;new destination position
	
;-----------------------------------------
;* test if new flaps position is inhibited
;-----------------------------------------

		xor	bh,bh

		mov	bl,CrntWingPos
		shl	bl,1		;*2
		shl	bl,1		;*4
		add	bl,al
		test	PosInhibit[bx],1;inhibited?
		jz	SkipFlapsDn	;yes ->

		mov	DestFlapPos,al

;* look up destination flap setting

		mov	bl,al
		xor	bh,bh
		shl	bx,1		;*2 word index
		mov	ax,FlapSetting[bx]
		mov	DestFlapVal,ax

;-----------------------------------
;* update flaps if changing position
;-----------------------------------

SkipFlapsDn:	mov	FlapsActive,0	;assume inactive

		mov	ax,CrntFlapVal
		cmp	ax,DestFlapVal
		je	FlapsExit

		mov	FlapsActive,1

		jl	MoveFlapsDown

;* move flaps up (current > dest)

		mov	dx,ax		;dx = previous value
		sub	ax,LastFrame	;ax = new value

		cmp	ax,DestFlapVal	;crossed destination position?
		jle	SetFlapDest	;yes ->

		cmp	dx,FLAPS_A_MNVR	;crossed manoeuvre flaps position?
		jl 	@F		;no ->
		cmp	ax,FLAPS_A_MNVR	;crossed manoeuvre flaps position?
		jg	@F		;no ->

		mov	CrntFlapPos,FLAPS_D_MNVR
		jmp	SetFlapVal

@@:		cmp	dx,FLAPS_A_MID	;crossed mid flaps position?
		jl 	SetFlapVal	;no ->
		cmp	ax,FLAPS_A_MID	;crossed mid flaps position?
		jg	SetFlapVal	;no ->

		mov	CrntFlapPos,FLAPS_D_MID
		jmp	SetFlapVal

;* move flaps down (current < dest)

MoveFlapsDown:	mov	dx,ax		;dx = previous value
		add	ax,LastFrame	;ax = new value

		cmp	ax,DestFlapVal	;crossed destination position?
		jge	SetFlapDest	;yes ->

		cmp	dx,FLAPS_A_MID	;crossed mid flaps position?
		jg 	@F		;no ->
		cmp	ax,FLAPS_A_MID	;crossed mid flaps position?
		jl	@F		;no ->

		mov	CrntFlapPos,FLAPS_D_MID
		jmp	SetFlapVal

@@:		cmp	dx,FLAPS_A_MNVR	;crossed manoeuvre flaps position?
		jg 	SetFlapVal	;no ->
		cmp	ax,FLAPS_A_MNVR	;crossed manoeuvre flaps position?
		jl	SetFlapVal	;no ->

		mov	CrntFlapPos,FLAPS_D_MNVR
		jmp	SetFlapVal

SetFlapDest:	mov	al,DestFlapPos
		mov	CrntFlapPos,al
		mov	ax,DestFlapVal
SetFlapVal:	mov	CrntFlapVal,ax

FlapsExit:	ret

UpdateFlaps	ENDP

;----------------------------------------------------------------------------

;* CalcAirDensity - calc air density and square root of air density
;*
;* pass: nothing
;* ret : Rho
;*       SqrtRho
;* kill: assume all

CalcAirDensity	PROC	NEAR

;------------------------
;* calc air density (Rho)
;------------------------

;* if zft >= 70,000ft then limit Rho, SqrtRho

		mov	dx,ZftHi
		mov	ax,ZftLo

		test	dx,dx		;zft > 65,535ft?
		jz	@F		;no ->
		cmp	ax,4464		;zft < 70,000ft?
		jb	@F		;yes ->

		mov	ax,RhoTable[70*2]
		mov	Rho,ax
		mov	ax,SqrtRhoTable[70*2]
		mov	SqrtRho,ax

		jmp	CalcAirDensExit

;* tabulated from 0 .. 70,000ft step 1,000ft

@@:		mov	bp,1000
		idiv	bp		;ax = quotient, dx = remainder

		mov	bx,ax		;0 .. 69
		shl	bx,1		;*2 index

		mov	si,dx		;si = remainder

;* interpolate between 1,000ft intervals

		mov	ax,RhoTable[bx]		;z1
		mov	di,ax
		sub	ax,RhoTable[bx+2]	;z1 - z2 = diff Rho

		imul	si		;diff Rho * remainder
		idiv	bp		;diff z = diff Rho * remainder / 1000

		sub	di,ax		;z1 - diff z

		mov	Rho,di

;-------------------------------------------
;* calc square root of air density (SqrtRho)
;-------------------------------------------

;* tabulated from 0 .. 70,000ft step 1,000ft
;*
;* interpolate between 1,000ft intervals

		mov	ax,SqrtRhoTable[bx]  	;z1
		mov	di,ax
		sub	ax,SqrtRhoTable[bx+2]	;z1 - z2 = diff SqrtRho

		imul	si		;diff SqrtRho * remainder
		idiv	bp		;diff z = diff SqrtRho * remainder / 1000

		sub	di,ax		;z1 - diff z

		mov	SqrtRho,di

CalcAirDensExit:ret

CalcAirDensity	ENDP

;----------------------------------------------------------------------------

;* CalcAirSpeed - calc true air speed and indicated air speed
;*
;* pass: nothing
;* ret : Vias
;*       Vkts
;* kill: assume all

CalcAirSpeed	PROC	NEAR

;-----------
;* calc Vias
;-----------

;* Vias = SqrtRho * Vtas

		mov	ax,Vtas

		add	ax,XWindVeff	;add crosswinds

;* ensure Vtas >= 0

		test	ax,ax		;Vtas >= 0?
		jns	@F		;yes ->
		xor	ax,ax

@@:		mov	dx,SqrtRho
		imul	dx
		FRACADJ	ax		;SqrtRho * Vtas
		mov	Vias,ax

;-----------
;* calc Vdiv
;-----------

		ABSV	ax
		cmp	ax,1360		;Vias < 100kts (100 * 1.7 * 8)?
		jae	@F		;yes ->
		mov	ax,1360		;limit to prevent divide overflows
@@:		xor	ax,dx		;restore sign
		sub	ax,dx
		mov	Vdiv,ax
	     
;-----------
;* calc Vkts
;-----------

;* Vkts = Vias * 2409 / 32768

		mov	ax,Vias
		mov	dx,2409
		imul	dx
		FRACADJ	dx
		mov	Vkts,dx

		ret

CalcAirSpeed	ENDP

;----------------------------------------------------------------------------

;* CalcGForce - calc g force, g max etc.
;*
;* pass: nothing
;* ret : GMax
;*       TrueGMax
;*       GForce
;*       GCoord
;*       Alpha
;*       StallFlag1
;*       StallFlag2
;*       StartStall
;* kill: assume all

CalcGForce	PROC	NEAR

;---------------------------------------
;* calc Kfs - flap / wing sweep constant
;---------------------------------------

;* if sweep active then
;*    use KfsSweep table
;* else
;*    if flaps active then 
;*       use KfsFlaps table
;*    else
;*       use KfsFixed table
;*    end
;* end
		
;-------------------------------------------------------
;* if sweep active then derive Kfs from KfsSweep[] table
;-------------------------------------------------------

		mov	al,SweepActive
		test	al,al		;sweep active?
		jz	@F		;no ->

;* Kfs = value - (sweep value * scale) / 256

		mov	bl,CrntFlapPos
		xor	bh,bh
		shl	bx,1		;*2
		shl	bx,1		;*4 index
		mov	dx,KfsSweep[bx+0]

		mov	ax,CrntWingVal

		mul	dx		;dx, ax = sweep value * scale

		mov	dh,dl		;/256
		mov	dl,ah
		shl	al,1		;1/2 bit round up
		adc	dx,0		;dx = sweep value * scale / 256

		mov	ax,KfsSweep[bx+2]

		sub	ax,dx		;ax = value - (sweep value * scale) / 256

		jmp	KfsOk

;-------------------------------------------------------
;* if flaps active then derive Kfs from KfsFlaps[] table
;-------------------------------------------------------

@@:		mov	al,FlapsActive
		test	al,al		;flaps active?
		jz	@F    		;no ->

;* Kfs = value + (flaps value * scale) / 256

		mov	bl,CrntWingPos
		xor	bh,bh
		shl	bx,1		;*2
		shl	bx,1		;*4 index
		mov	dx,KfsFlaps[bx+0]

		mov	ax,CrntFlapVal

		mul	dx		;dx, ax = flaps value * scale

		mov	dh,dl		;/256
		mov	dl,ah
		shl	al,1		;1/2 bit round up
		adc	dx,0		;dx = flaps value * scale / 256

		mov	ax,KfsFlaps[bx+2]

		add	ax,dx		;ax = value + (flaps value * scale) / 256

		jmp	KfsOk

;-----------------------------------
;* look up Kfs from KfsFixed[] table
;-----------------------------------

@@:		mov	bl,CrntWingPos
		xor	bh,bh
		shl	bx,1		;*2
		shl	bx,1		;*4
		shl	bx,1		;*8 index

		mov	al,CrntFlapPos
		xor	ah,ah
		shl	ax,1		;*2 index

		add	bx,ax

		mov	ax,KfsFixed[bx]

KfsOk:		mov	Kfs,ax		

;-----------
;* calc GMax
;-----------

;* GMax = ((Vias * (Vias * Kfs)) / (Weight2 - (Thrust * sin(21) / 2))) / 8
;*
;* if pushing then GMax = -GMax
;*
;* note: GMax is *16 scaled
;*       Vias is *8 scaled
;*       Weight2 is /2 scaled
;*       Kfs has no scaling
;*
;*       GMax [*16] = result [*128] / 8

;* old stall flag = new stall flag

		mov	dl,StallFlag1
		mov	StallFlag2,dl

		mov	ax,Thrust
		mov	dx,23486/2	;sin(21) / 2 (*65536)
		mul	dx	  	;Thrust * sin(21) / 2
		mov	bx,Weight2
		sub	bx,dx		;Weight2 - Thrust * sin(21) / 2

		mov	ax,Kfs
		mov	bp,Vias
		imul	bp
		FRACADJ	ax		;ax = Vias * Kfs
		imul	bp		;dx, ax = Vias * Vias * Kfs
		
		idiv	bx		;ax = Vias * Vias * Kfs / Weight2

;* if GMax < 1g then stall (hold GMax at just < 1g)

		cmp	ax,16*8		;GMax < 1g?
		jae	@F		;no ->

		mov	StallFlag1,1	;stalled

		mov	ax,15*8		;hold GMax at just < 1g

		jmp	SortGMax	;ignore elevator ->

@@:		mov	StallFlag1,0	;not stalled

;* test if pushing or pulling

		test	AutoTrim,1	;auto-trim?
		mov	dx,ElePosn	;assume not
		jz	@F		;no ->
		mov	dx,GCoord

@@:		test	dx,dx		;pushing?
		js	SortGMin	;yes ->

SortGMax:	shr	ax,1
		shr	ax,1
		shr	ax,1		;ax = Vias * Vias * Kfs / Weight2 / 8

		adc	ax,0		;1/2 bit round up

		mov	TrueGMax,ax	;unlimited GMax

;* limit to G_MAX

		cmp	ax,G_MAX
		jle	SetGMax
		mov	ax,G_MAX

		jmp	SetGMax

SortGMin:	shr	ax,1
		shr	ax,1
		shr	ax,1		;ax = Vias * Vias * Kfs / Weight2 / 8

		adc	ax,0		;1/2 bit round up

		neg	ax		;-GMax

		mov	TrueGMax,ax	;unlimited GMax

;* limit to G_MIN

		cmp	ax,G_MIN
		jge	SetGMax
		mov	ax,G_MIN

SetGMax: 	mov	GMax,ax		

;-----------------
;* calc StartStall
;-----------------

;* StartStall = not(StallFlag2) and StallFlag1 (0 -> 1 transition)

		mov	ax,StallFlags	;al = StallFlag1, ah = StallFlag2
		not	ah
		and	al,ah
		mov	StartStall,al

		jz	ContGForce	;not just stalled ->
		
;* sort stall roll direction (wing drop):-
;*
;* RFine = 00000h .. 03fffh: +ve hdg rate, +ve roll rate )
;* RFine = 04000h .. 07fffh: -ve hdg rate, -ve roll rate ) b14 = 0 = +ve roll rate
;* RFine = 08000h .. 0bfffh: +ve hdg rate, +ve roll rate ) b14 = 1 = -ve roll rate
;* RFine = 0c000h .. 0ffffh: -ve hdg rate, -ve roll rate )

		mov	ax,RFine

		cmp	ax,0*128	;wings level (erect)?
		je	@F		;yes ->
		cmp	ax,256*128	;wings level (inverted)?
		je	@F		;yes ->

		shl	ax,1		;b14 = sign roll direction (wrt quadrant)

		jmp	ContStallRoll

@@:		call	RandX		;select random stall roll direction

		cbw			;(use sign bit)

ContStallRoll:	cwd			;0 = clk-wise, -1 = aclk-wise

		mov	StallRollDir,dx

;* store pitch angle at point of stall

		mov	ax,PFine

		mov	StallPitch,ax

;* set max stall pitch down angle

		mov	MaxPitchDown,MAX_STALL_PDN1

;-------------
;* calc GForce
;-------------

;* if not stalled then
;*    if terrain following then
;*       GForce = TFGForce
;*    else
;*       if auto-altitude then
;*          GForce = AAGForce
;*       else
;*          if not auto-trim then
;*             GForce = ElePosn * abs(GMax) + M_CosR * M_CosP * 16
;*          else
;*             GForce = GCoord
;*          end
;*       end
;*    end
;* else
;*    GForce = M_CosR * M_CosP * 16
;* end
;*
;* if abs(GForce) > abs(GMax) then
;*    GForce = GMax
;* end
;*
;* if not airborne and stalled then
;*    GForce = 1g
;* end

ContGForce:	mov	ax,GMax
		ABSV	ax   		;abs(GMax)
		mov	bx,ax

		xor	bp,bp		;assume stalled

		test	StallFlag1,1	;stalled?
		jnz	@F		;yes ->

;* terrain following authority?

		test	TFAuto,1	;auto-terrain follow?
		mov	ax,TFGForce	;assume so
		jnz	CheckGForce	;yes ->

;* auto-altitude authority?

		test	AAFlag,1	;auto-altitude?
		mov	ax,AAGForce	;assume so
		jnz	CheckGForce	;yes ->

;* auto-trim authority? (GForce lags GCoord by one frame)

		test	AutoTrim,1	;auto-trim?
		mov	ax,GCoord	;assume so
		jnz	CheckGForce	;yes ->

		mov	ax,ElePosn
		imul	bx
		FRACADJ	bp		;ElePosn * abs(GMax)

@@:	 	mov	ax,M_CosR
		mov	dx,M_CosP
		imul	dx
		FRACADJ	ax		;M_CosR * M_CosP
		cwd
		REPT	4		;*16
		shl	ax,1	
		rcl	dx,1
		ENDM
		FRACADJ	ax		;M_CosR * M_CosP * 16

		add	ax,bp		;ElePosn * abs(GMax) + M_CosR * M_CosP * 16

CheckGForce:	ABSV	ax
		
		cmp	ax,bx		;abs(GForce) <= abs(GMax)?
		jbe	@F		;yes ->
		mov	ax,bx		;abs(GForce) = abs(GMax)

@@:		xor	ax,dx		;restore sign
		sub	ax,dx

		mov	dl,Airborne1
		not	dl
		and	dl,StallFlag1	;not airborne and stalled?
		jz	@F
		mov	ax,16		;GForce = 1g

@@:		mov	GForce,ax

;-------------
;* calc GCoord
;-------------

;* GCoord = (M_CosP * 256 / M_CosR) / 16
;*
;* note: Roll limited to 83 degs (to prevent overflow).
;*
;*       cos(83) = 0.122 = 3993 / 32768

		mov	ax,M_CosR
		ABSV	ax
		cmp	ax,3993		;roll <= 83 degs?
		jae	@F		;yes ->
		mov	ax,3993		;limit to 83 degs

@@:		xor	ax,dx		;restore sign
		sub	ax,dx

		mov	bp,ax

		mov	ax,M_CosP
		cwd
		mov	dl,ah		;M_CosP * 256
		mov	ah,al
		xor	al,al

		idiv	bp		;M_CosP * 256 / M_CosR

		ABSV	ax

		REPT	4		;(M_CosP * 256 / M_CosR) / 16
		shr	ax,1
		ENDM
		
		adc	ax,0		;1/2 bit round up

		xor	ax,dx		;restore sign
		sub	ax,dx

;* cancel auto-trim if GCoord is -ve

		jns	SetGCoord	;GCoord +ve ->

		mov	AutoTrim,0	;cancel auto-trim

SetGCoord:	mov	GCoord,ax

;------------------------------
;* calc Alpha (angle of attack)
;------------------------------

;* if spinning and not recovered then
;*    Alpha [*16] = ALPHA_MAX
;* else
;*    if airborne then 
;*       Alpha [*16] = GForce * ALPHA_MAX / max(abs(TrueGMax), 1g)
;*    else
;*       Alpha [*16] = PFine * (23040 / 32768) / 8
;*    end
;* end

		mov	al,SpinFlag
		test	al,al		;spinning?
		jz	@F		;no ->

		mov	ax,Recovery
		test	ax,ax		;recovered?
		jz	@F		;yes ->

		mov	ax,ALPHA_MAX	;assume so

		jmp	SetAlpha

@@:		mov	al,Airborne1
		test	al,al		;airborne?
		jnz	@F		;yes ->

		mov	ax,PFine
		mov	dx,23040
		imul	dx
		FRACADJ	ax		;PFine * 23040 / 32768

		REPT	3		;PFine * (23040 / 32768) / 8
		sar	ax,1
		ENDM

		jmp	SetAlpha

@@:		mov	bx,16		;assume abs(GMax) < 1g

		mov	ax,TrueGMax
		ABSV	ax   		;ax = abs(TrueGMax), dx = sign(TrueGMax)
		cmp	ax,bx		;abs(TrueGMax) < 1g?
		jb	@F		;yes, limit to 1g ->
		mov	bx,ax

@@:		mov	ax,GForce
		mov	dx,ALPHA_MAX
		imul	dx		;GForce * ALPHA_MAX

		idiv	bx		;GForce * ALPHA_MAX / max(abs(TrueGMax), 1g)

		test	ax,ax		;Alpha >= 0?
		jns	SetAlpha	;yes ->

		cmp	ax,ALPHA_MIN	;limit -ve Alpha to ALPHA_MIN
		jge	SetAlpha
		mov	ax,ALPHA_MIN

SetAlpha:	mov	Alpha,ax

		ret

CalcGForce	ENDP

;----------------------------------------------------------------------------

;* CalcRates - calc control rates
;*
;* pass: nothing
;* ret : HdgRate
;*       PitchRate
;*       RollRate
;* kill: assume all

CalcRates	PROC	NEAR

		mov	al,SpinFlag
		test	al,al		;spinning?
		jz	@F		;no

		jmp	SpinRates

;------------
;* calc GRate
;------------

;* GRate = (GForce - GCoord) * 656 * 256 / Vdiv

@@:		mov	ax,GForce
		sub	ax,GCoord	;GForce - GCoord
		mov	dx,656
		imul	dx		;(GForce - GCoord) * 656

		mov	dh,dl		;(GForce - GCoord) * 656 * 256
		mov	dl,ah
		mov	ah,al
		xor	al,al

		mov	bx,Vdiv
		idiv	bx		;(GForce - GCoord) * 656 * 256 / Vdiv

		mov	GRate,ax
       
;--------------
;* calc EleRate
;--------------

;* if not stalled then
;*    EleRate = ((41 * 65536) / Vdiv) * ElePosn
;* else
;*    EleRate = 0
;* end

		xor	dx,dx		;assume stalled

		mov	al,StallFlag1
		test	al,al		;stalled?
		jnz	@F		;yes ->

		mov	dx,41
		xor	ax,ax
		mov	bx,Vdiv
		idiv	bx		;(41 * 65536) / Vdiv

		mov	dx,ElePosn
		imul	dx
		FRACADJ	dx		;((41 * 65536) / Vdiv) * ElePosn

@@:		mov	EleRate,dx

;------------------
;* calc EleRollRate
;------------------

;* EleRollRate = EleRate * 8 * M_SinR * M_SinP

;* //MOD// 28.04.1993 - Use (EleRate * 8) to boost induced roll with elevator
;*			(to improve off axis loop).

		REPT	3
		sal	dx,1
		ENDM

		mov	ax,M_SinR
		imul	dx
		FRACADJ	dx		;EleRate * 8 * M_SinR
		mov	ax,M_SinP
		imul	dx
		FRACADJ	dx		;EleRate * 8 * M_SinR * M_SinP

		mov	EleRollRate,dx

;--------------
;* calc RudRate
;--------------

;* RudRate = ((41 * 65536) / Vdiv) * RudPosn

		mov	dx,41
		xor	ax,ax
		mov	bx,Vdiv
		idiv	bx		;(41 * 65536) / Vdiv

		mov	dx,RudPosn
		imul	dx
		FRACADJ	dx		;((41 * 65536) / Vdiv) * RudPosn

;* if stalled then
;*    RudRate = RudRate / 4
;* end

		mov	al,StallFlag1
		test	al,al		;stalled?
		jz	@F		;no ->

;* RudRate / 4 (ignore -1 truncation error)

		sar	dx,1		;/2
		sar	dx,1		;/4

@@:		mov	RudRate,dx

;------------------
;* calc RudRollRate
;------------------

;* RudRollRate = RudRate * M_CosR * M_SinP

		mov	ax,M_CosR
		imul	dx
		FRACADJ	dx		;RudRate * M_CosR
		mov	ax,M_SinP
		imul	dx
		FRACADJ	dx		;RudRate * M_CosR * M_SinP

		mov	RudRollRate,dx

;------------------
;* calc AilRollRate
;------------------

;* if abs(Vias) < 4096 (300kts) then
;*    rate = abs(Vias) * 8
;* else
;*    rate = 32767 (max roll rate)
;* end
;*
;* AilRollRate = AilPosn * rate * sign(Vias) 

		mov	ax,Vias
		ABSV	ax		;ax = abs(Vias), dx = sign(Vias)

		cmp	ax,4096		;abs(Vias) >= 300kts?
		mov	bp,32767	;assume so (max roll rate)
		jae	@F		;yes ->

		shl	ax,1		;*2
		shl	ax,1		;*4
		shl	ax,1		;rate = abs(Vias) * 8

		mov	bp,ax

@@:		xor	bp,dx		;rate * sign(Vias)
		sub	bp,dx

		mov	ax,AilPosn
		imul	bp
		FRACADJ	dx		;AilPosn * rate * sign(Vias)

;* if stalled then
;*    AilRolRate = AilRollRate / 4
;* end

		mov	al,StallFlag1
		test	al,al		;stalled?
		jz	@F		;no ->

;* AilRollRate / 4 (ignore -1 truncation error)

		sar	dx,1		;/2
		sar	dx,1		;/4

@@:		mov	AilRollRate,dx

;--------------
;* calc HdgRate
;--------------

;* if airborne then
;*    HdgRate = ((GForce * 1.125 * 656 * 256 / Vtas) * M_SinR + RudRate * M_CosR)
;* else
;*    HdgRate = ground steering (see below)
;* end

		mov	al,Airborne1
		test	al,al		;airborne?
		jz	GndSteering	;no ->

;* //MOD// 28.04.1993 - Sort roll / hdg singularity at +/-90degs.

		cmp	Pitch,128
		je	Fix90
		cmp	Pitch,384
		je	Fix90

		mov	ax,RudRate
		mov	dx,M_CosR
		imul	dx
		FRACADJ	bp		;RudRate * M_CosR

;* //MOD// 28.04.1993 - Use (GForce * 1.125) to increase hdg rate (required
;*                      to improve off axis loop).

		mov	ax,GForce
		mov	dx,738		;738 = 1.125 * 656 
		imul	dx    		;GForce * 738

		mov	dh,dl		;GForce * 738 * 256
		mov	dl,ah
		mov	ah,al
		xor	al,al

;* //MOD// 22.07.1992 - Vdiv replaced with Vtas. This prevents high heading
;*                      rates at altitude.

		mov	bx,Vtas
		cmp	bx,1360		;Vtas < 100kts?
		jge	@F		;no ->
		mov	bx,1360		;limit to 100kts (prevent overflow)
@@:		idiv	bx		;GForce * 738 * 256 / Vtas

		mov	dx,M_SinR
		imul	dx
		FRACADJ	dx		;(GForce * 738 * 256 / Vtas) * M_SinR

		add	dx,bp		;(GForce * 738 * 256 / Vtas) * M_SinR + RudRate * M_CosR

		jmp	SetHdgRate

Fix90:		mov	dx,AilRollRate	;hdg rate = aileron roll rate

		mov	AilRollRate,0	;aileron roll rate = 0
		
		jmp	SetHdgRate

;* ground steering:-
;*
;* if Vtas > 0 and gear down then
;*    if sign(AilPosn) = sign(RudPosn) then
;*       if abs(AilPosn) > abs(RudPosn) then
;*          steer posn = AilPosn
;*       else
;*          steer posn = RudPosn
;*       end
;*    else
;*       steer posn = AilPosn + RudPosn
;*    end
;*    HdgRate = (max(21 * 128 - Vtas * 2, 0) + 1) * steer posn
;* else
;*    HdgRate = 0
;* end

GndSteering:	xor	dx,dx		;assume Vtas <= 0 or gear up

		test	Gear,1		;gear down?
		jz	SetHdgRate	;no ->

		mov	ax,Vtas
		cmp	ax,0		;Vtas > 0?
		jle	SetHdgRate	;no ->

		shl	ax,1		;Vtas * 2

		mov	dx,21*128
		xchg	ax,dx
		sub	ax,dx
		MINM	ax		;max(21 * 128 - Vtas * 2, 0)
		add	ax,128		;max(21 * 128 - Vtas * 2, 0) + 128

		mov	bp,ax

		mov	ax,AilPosn
		xor	ax,RudPosn	;sign(AilPosn) = sign(RudPosn)?
		js	SumControls	;no ->

		mov	ax,AilPosn
		ABSV	ax
		mov	bx,ax
		mov	cx,dx

		mov	ax,RudPosn
		ABSV	ax

		cmp	ax,bx		;ailerons or rudder dominant?
		jae	@F		;rudder dominant (or same) ->
		mov	ax,bx
		mov	dx,cx
@@:		xor	ax,dx		;restore sign
		sub	ax,dx

		jmp	@F

SumControls:	mov	ax,AilPosn
		add	ax,RudPosn

@@:		imul	bp
		FRACADJ	dx		;max(21 * 128 - Vtas * 2, 0) + 128 * steer posn

SetHdgRate:    	mov	HdgRate,dx

		mov	ax,DeltaTime
		imul	dx
		FRACADJ	dx		;DeltaHRate = HdgRate * DeltaTime

		mov	DeltaHRate,dx

;----------------
;* calc PitchRate
;----------------

;* if not stalled then
;*    if terrain following then
;*       PitchRate = terrain following pitch rate
;*    else
;*       if auto-altitude then
;*          PitchRate = auto-altitude pitch rate
;*       else
;*          PitchRate = (GRate * M_CosR - RudRate * M_SinR)
;*       end
;*    end
;* else
;*    PitchRate = pitch down wrt stall (see below)
;* end

		mov	al,StallFlag1
		test	al,al		;stalled?
		jnz	StallPitchDown	;yes ->

;* terrain following authority?

		test	TFAuto,1	;auto-terrain following on?
		jz	@F		;no ->

		mov	ax,TFPitchRate
		mov	PitchRate,ax

		mov	dx,TFDeltaPRate

		jmp	ContPitchRate

;* auto-altitude authority?

@@:		test	AAFlag,1	;auto-altitude engaged?
		jz	@F		;no ->

		mov	ax,AAPitchRate
		mov	PitchRate,ax

		mov	dx,AADeltaPRate

		jmp	ContPitchRate

@@:		mov	ax,RudRate
		mov	dx,M_SinR
		imul	dx
		FRACADJ	bp  		;RudRate * M_SinR

;* //MOD// 28.04.1993 - Keep abs(M_CosR) >= cos(83) else nose does not drop
;*		        when rolled 90 degs.

		mov	ax,M_CosR
		ABSV	ax
		cmp	ax,3993		;cos(83)
		jae	@F

		mov	ax,3993		;cos(83)

@@:		xor	ax,dx		;restore sign
		sub	ax,dx

		mov	dx,GRate
		imul	dx
		FRACADJ	dx		;GRate * M_CosR

		sub	dx,bp		;GRate * M_CosR - RudRate * M_SinR

		jmp	SetPitchRate

;-------------------------
;* pitch down due to stall
;-------------------------

;* if airborne then
;*    PitchRate = DampRate(-(M_CosP * MAX_STALL_PRATE + MIN_STALL_PRATE))
;* else
;*    if accelerating then
;*       PitchRate = 0
;*    else
;*       PitchRate = -10degs/sec
;*    endif
;* endif

;* //MOD// 05.11.1992 - Pitch down on ground if decelerating.

StallPitchDown:	test	Airborne1,1	;airborne?
		jnz	@F		;yes ->

		xor	dx,dx		;assume accelerating

		cmp	Accel,0		;accelerating?
		jg	SetPitchRate	;yes ->

		mov	dx,-1820	;-10degs/sec pitch down

		jmp	SetPitchRate

;* new pitch rate = -(M_CosP * MAX_STALL_PRATE + MIN_STALL_PRATE))

@@:		mov	ax,M_CosP
		mov	dx,MAX_STALL_PRATE
		imul	dx
		FRACADJ	dx 		
		add	dx,MIN_STALL_PRATE

		neg	dx     		;dx = new pitch rate

		mov	ax,PitchRate	;ax = old pitch rate

		mov	cx,DAMP2

		call	DampRate

SetPitchRate:	mov	PitchRate,dx

		mov	ax,DeltaTime
		imul	dx
		FRACADJ	dx		;DeltaPRate = PitchRate * DeltaTime

;* if on ground then
;*    PFine = max(PFine, 0)		;limit pitch down to 0 degrees
;* end

ContPitchRate:	mov	al,Airborne1
		test	al,al		;airborne?
		jnz	SkipGndPDown	;yes ->

		mov	ax,PFine
		add	ax,dx		;PFine + DeltaPRate
		_JNS	SetDeltaPRate	;PFine + DeltaPRate >= 0 ->

		test	Gear,1		;gear down?
		jz	@F    		;no ->

		cmp	PFine,0		;nose wheel just touched down?
		je	@F		;no ->

		SHAKE	SHAKE_NOSE_DOWN,HSHAKE_OFF,VSHAKE_LO,10

@@:		mov	dx,PFine
		neg	dx		;DeltaPRate = -PFine

		jmp	SetDeltaPRate

;* if stalled then
;*    if nose just gone through horizon then
;*       if HdgRate <> 0 then
;*          if SPILS off then
;*             start spin
;*          end
;*       end
;*    end
;*    if not spinning then
;*       PFine = max(PFine, MaxPitchDown)
;*    end
;* end

SkipGndPDown:	mov	al,StallFlag1
		test	al,al		;stalled?
		jz	SetDeltaPRate	;no ->

;----------------------
;* check for start spin
;----------------------

		mov	ax,PFine
		test	ax,ax		;nose was above horizon?
		js	SkipStartSpin	;no ->

		add	ax,dx		;nose now below horizon?
		jns	SkipStartSpin	;no ->

		mov	ax,StallPitch
		cmp	ax,16*128	;gentle stall (pitch < 11 degs)?
		jle	SkipStartSpin	;yes ->

		mov	al,SPILS
		test	al,al		;SPILS on?
		jnz	SkipStartSpin	;yes ->

;------------
;* start spin
;------------

		mov	SpinFlag,1

;* set max stall pitch down angle

		mov	MaxPitchDown,MAX_STALL_PDN2

;* spin recovery time = 3 * 100 + RandX * 2
;*
;*                    = 300 + (0 .. 510)
;*
;*                    = 3.00 .. 8.10 secs

		call	RandX
		shl	ax,1		;*2
		add	ax,3*100

		mov	Recovery,ax

		jmp	SetDeltaPRate

;--------------------------
;* check for max pitch down
;--------------------------

SkipStartSpin:	mov	ax,PFine
		add	ax,dx		;PFine + DeltaPRate

		cmp	ax,MaxPitchDown	;pitch < MaxPitchDown?
		jge	SetDeltaPRate	;no ->

		mov	dx,MaxPitchDown
		sub	dx,PFine	;DeltaPRate = MaxPitchDown - PFine

SetDeltaPRate:	mov	DeltaPRate,dx

;---------------
;* calc RollRate
;---------------

;* if airborne then
;*    if stalled and pitched up then
;*       RollRate = DampRate((M_CosP * MAX_STALL_RRATE + MIN_STALL_RRATE) * StallRollDir)
;*    else
;*       RollRate = (EleRollRate + AilRollRate + RudRollRate)
;*    end
;* else
;*    RollRate = 0
;* end

		xor	dx,dx		;assume not airborne

		mov	al,Airborne1
		test	al,al		;airborne?
		jz	SetRollRate	;no ->

;* KJB - 10.03.1992 - auto-heading modification

		test	AHFlag,1	;auto-hdg active?
		jz	@F		;no ->

		mov	ax,AHRollRate
		mov	RollRate,ax

		mov	dx,AHDeltaRRate

		jmp	SetDeltaRRate

@@:		mov	al,StallFlag1
		test	al,al		;stalled?
		jz	@F		;no ->

		mov	ax,PFine
		test	ax,ax		;pitched up?
		jns	StallWingDrop	;yes ->

;* scale by /2 to prevent overflow

@@:		mov	ax,EleRollRate
		sar	ax,1		;/2
		add	dx,ax
		mov	ax,AilRollRate
		sar	ax,1		;/2
		add	dx,ax
		mov	ax,RudRollRate
		sar	ax,1		;/2
		add	dx,ax

		cmp	dx,-16384	;limit roll left rate?
		jge	@F		;no ->
		mov	dx,-16384

@@:		cmp	dx,+16363	;limit roll right rate?
		jle	@F		;no ->
		mov	dx,+16383

@@:		sal	dx,1		;*2 (restore scale)

		jmp	SetRollRate

;-------------------------------------
;* stalled and pitched up so drop wing
;-------------------------------------

StallWingDrop:	mov	ax,M_CosP
		mov	dx,MAX_STALL_RRATE
		imul	dx
		FRACADJ	dx			;M_CosP * MAX_STALL_RRATE
		add	dx,MIN_STALL_RRATE	;M_CosP * MAX_STALL_RRATE + MIN_STALL_RRATE

		mov	ax,StallRollDir	;(M_CosP * MAX_STALL_RRATE + MIN_STALL_RRATE) * StallRollDir
		xor	dx,ax
		sub	dx,ax		;dx = new roll rate

		mov	ax,RollRate	;ax = old roll rate

		mov	cx,DAMP2

		call	DampRate

SetRollRate:	mov	RollRate,dx

		mov	ax,DeltaTime
		imul	dx
		FRACADJ	dx		;DeltaRRate = RollRate * DeltaTime

SetDeltaRRate:	mov	DeltaRRate,dx

		jmp	CalcRatesExit

;-----------------
;* calc spin rates
;-----------------

SpinRates	LABEL	NEAR

;--------------------
;* sort spin recovery
;--------------------

		mov	ax,Recovery
		test	ax,ax		;recovered?
		jnz	@F		;no ->

		jmp	RecoveryRates

;* if stick back then
;*    if "in spin" aileron then
;*       Recovery = max(Recovery - LastFrame, 0)
;*    end
;* end

;* note: Do not check for max control positions (ie. +32767 and -32768) as
;*       some joysticks may not be able to reach these limits. Instead use
;*       +16384 and -16384 limits.

@@:		mov	ax,ElePosn
		cmp	ax,+16384	;stick back?
		jl	@F		;no ->

;* check for "in spin" aileron

		mov	ax,AilPosn
		ABSV	ax		;ax = abs(AilPosn), dx = sign(AilPosn)
		cmp	ax,+16384	;enough aileron?
		jb	@F		;no ->

		xor	dx,HdgRate	;"in spin" aileron?
		js	@F		;no ->

		mov	ax,Recovery
		sub	ax,LastFrame
		MINM	ax
		mov	Recovery,ax

;-------------------
;* sort heading rate
;-------------------

;* continuous heading rate:-
;*
;* HdgRate = ((SWEEP_A_67 - CrntWingVal) * 32 + 10367) * sign(old PitchRate)
;*
;* @ 25 deg wing sweep, rate =   (700 - 0) * 32 + 10367 = 180 degs / sec
;* @ 45 deg wing sweep, rate = (700 - 333) * 32 + 10367 = 121 degs / sec
;* @ 67 deg wing sweep, rate = (700 - 700) * 32 + 10367 =  57 degs / sec

@@:	 	mov	ax,HdgRate
		cwd			;dx = heading direction

		mov	ax,SWEEP_A_67
		sub	ax,CrntWingVal	;SWEEP_A_67 - CrntWingVal
		REPT	5		;(SWEEP_A_67 - CrntWingVal) * 32
		shl	ax,1
		ENDM
		add	ax,10367	;(SWEEP_A_67 - CrntWingVal) * 32 + 10367
		xor	ax,dx		;set heading direction
		sub	ax,dx
		mov	dx,ax		;dx = new heading rate

		mov	ax,HdgRate	;ax = old heading rate

		mov	cx,DAMP64

		call	DampRate

		mov	HdgRate,dx

		mov	ax,DeltaTime
		imul	dx
		FRACADJ	dx		;DeltaHRate = HdgRate * DeltaTime

		mov	DeltaHRate,dx

;-----------------
;* sort pitch rate
;-----------------

;* if CrntWingVal <= SWEEP_A_45 then
;*    pitch to steady state position wrt wing sweep
;* else
;*    continuous pitch (set pitch rate wrt wing sweep)
;* end

		mov	ax,CrntWingVal
		cmp	ax,SWEEP_A_45	;wing sweep <= 45 degs?
		ja	ContSpinPitch	;no ->

;* steady state pitch:-

		mov	ax,-8192	;steady state pitch = -45 degs

;* pitch rate = steady state pitch - current pitch

		sub	ax,PFine

		jmp	DampSpinPitch

;* continuous pitch rate:-
;*
;* pitch rate = (3407 + (CrntWingVal - SWEEP_A_45) * 80) * sign(PitchRate)
;*
;*           = 3407 .. 32767 (fine pdegs / sec)
;*
;*           = 19 .. 180 degs / sec

ContSpinPitch:	sub	ax,SWEEP_A_45
		
		REPT	4		;*16
		shl	ax,1
		ENDM
		mov	dx,ax
		REPT	2		;*64
		shl	ax,1
		ENDM
		add	ax,dx		;(CrntWingVal - SWEEP_A_45) * 80

		add	ax,3407		;3407 + (CrntWingVal - SWEEP_A_45) * 80

		mov	dx,PitchRate
		test	dx,dx		;pitch up or down?
		jns	DampSpinPitch	;up ->

		neg	ax

DampSpinPitch:	mov	dx,ax		;dx = new pitch rate

		mov	ax,PitchRate	;ax = old pitch rate

		mov	cx,DAMP2

		call	DampRate

		mov	PitchRate,dx

		mov	ax,DeltaTime
		imul	dx
		FRACADJ	dx		;DeltaPRate = PitchRate * DeltaTime

		mov	DeltaPRate,dx

;* flip pitch direction if pitch over top / bottom
		
		add	dx,PFine

		cmp	dx,128*128	;pitch <= 90 degs?
		jbe	@F		;yes ->
		cmp	dx,384*128	;pitch >= -90 degs
		jae	@F		;yes ->

		neg	PitchRate

;----------------
;* sort roll rate
;----------------

;* if CrntWingVal <= SWEEP_A_45 then
;*    roll to steady state position wrt wing sweep
;* else
;*    continuous roll (set roll rate wrt wing sweep)
;* end

@@:		mov	ax,CrntWingVal
		cmp	ax,SWEEP_A_45	;wing sweep <= 45 degs?
		ja	ContSpinRoll	;no ->

;* steady state roll:-

;* calc roll angle wrt wing sweep
;*
;* roll angle = 200 + CrntWingVal * 24
;*
;*            = 200 .. 8192 fine pdegs
;*
;*            = 1 .. 45 degs

		REPT	3   		;*8
		shl	ax,1
		ENDM
		mov	dx,ax
		shl	ax,1		;*16
		add	ax,dx		;CrntWingVal * 24

		add	ax,200		;200 + CrntWingVal * 24

;* roll angle * sign(HdgRate)

		mov	dx,HdgRate
		test	dx,dx	  	;clk-wise or aclk-wise roll?
		jns	@F		;clk-wise ->

		neg	ax

;* if erect then
;*    steady state roll = 0 * 128 + roll angle * sign(HdgRate)
;* else
;*    steady state roll = 256 * 128 + roll angle * sign(HdgRate)
;* end

@@:		mov	dx,M_CosR
		test	dx,dx		;erect or inverted?
		jns	@F		;erect ->
		add	ax,256*128

;* roll rate = steady state roll - current roll

@@:		sub	ax,RFine

		jmp	DampSpinRoll

;* continuous roll rate:-
;*
;* roll rate = (3407 + (CrntWingVal - SWEEP_A_45) * 80) * sign(HdgRate)
;*
;*           = 3407 .. 32767 (fine pdegs / sec)
;*
;*           = 19 .. 180 degs / sec

ContSpinRoll:	sub	ax,SWEEP_A_45
		
		REPT	4		;*16
		shl	ax,1
		ENDM
		mov	dx,ax
		REPT	2		;*64
		shl	ax,1
		ENDM
		add	ax,dx		;(CrntWingVal - SWEEP_A_45) * 80

		add	ax,3407		;3407 + (CrntWingVal - SWEEP_A_45) * 80

		mov	dx,HdgRate
		test	dx,dx		;clk-wise or aclk-wise roll?
		jns	DampSpinRoll	;clk-wise ->

		neg	ax

DampSpinRoll:	mov	dx,ax		;dx = new roll rate
		
		mov	ax,RollRate	;ax = old roll rate

		mov	cx,DAMP2

		call	DampRate

		mov	RollRate,dx

		mov	ax,DeltaTime
		imul	dx
		FRACADJ	dx		;DeltaRRate = RollRate * DeltaTime

		mov	DeltaRRate,dx

		jmp	CalcRatesExit

;---------------------
;* spin recovery rates
;---------------------

RecoveryRates	LABEL	NEAR

;-------------------------------------
;* check for unexpected stall recovery
;-------------------------------------

		mov	al,StallFlag1
		test	al,al		;recovered from stall?
		jnz	@F		;no ->

		mov	SpinFlag,0	;stop spin

		xor	ax,ax		;set rates to 0

		mov	HdgRate,ax
		mov	DeltaHRate,ax
		mov	PitchRate,ax
		mov	DeltaPRate,ax
		mov	RollRate,ax
		mov	DeltaRRate,ax

		jmp	CalcRatesExit

;----------------------------
;* sort recovery heading rate - reduce heading rate to 0 degs / sec
;----------------------------

@@:		mov	ax,40*128	;approx 30 degs / sec decrease
		mov	dx,DeltaTime
		imul	dx
		FRACADJ	bp

		mov	ax,HdgRate
		ABSV	ax
		sub	ax,bp		;reduce heading rate to 0 degs / sec
		ja	@F		;not reached zero ->
		xor	ax,ax

		mov	SpinFlag,0	;stop spin

@@:		xor	ax,dx		;restore sign
		sub	ax,dx

		mov	HdgRate,ax

		mov	dx,DeltaTime
		imul	dx
		FRACADJ	dx		;DeltaHRate = HdgRate * DeltaTime

		mov	DeltaHRate,dx

;--------------------------
;* sort recovery pitch rate - aim for MaxPitchDown
;--------------------------

		mov	dx,MaxPitchDown

		sub	dx,PFine	;dx = new pitch rate

		mov	ax,PitchRate	;ax = old pitch rate

		mov	cx,DAMP2

		call	DampRate

		mov	PitchRate,dx

		mov	ax,DeltaTime
		imul	dx
		FRACADJ	dx		;DeltaPRate = PitchRate * DeltaTime

		mov	DeltaPRate,dx

;* flip pitch direction if pitch over top / bottom
		
		add	dx,PFine

		cmp	dx,128*128	;pitch <= 90 degs?
		jbe	@F		;yes ->
		cmp	dx,384*128	;pitch >= -90 degs
		jae	@F		;yes ->

		neg	PitchRate

;-------------------------
;* sort recovery roll rate - wash out wrt erect / inverted
;-------------------------

@@:  		mov	ax,M_CosR
		test	ax,ax		;erect or inverted?
		mov	ax,0		;assume erect
		jns	@F   		;erect ->

		mov	ax,RFine
		cwd			;dx = sign(roll)

		mov	ax,32767	;ax = 32767 * sign(roll)
		xor	ax,dx
		sub	ax,dx

@@:	      	sub	ax,RFine

		mov	dx,ax		;new roll rate

		mov	ax,RollRate	;old roll rate

		mov	cx,DAMP2

		call	DampRate

		mov	RollRate,dx

		mov	ax,DeltaTime
		imul	dx
		FRACADJ	dx		;DeltaRRate = RollRate * DeltaTime

		mov	DeltaRRate,dx

CalcRatesExit:	ret

CalcRates	ENDP

;----------------------------------------------------------------------------

;* CalcAngles - update angles and calc trig angles
;*
;* pass: nothing
;* ret : Hdg, HFine
;*       Pitch, PFine
;*       Roll, RFine
;*       M_SinH, M_CosH
;*       M_SinP, M_CosP
;*       M_SinR, M_CosR
;* kill: assume all

CalcAngles	PROC	NEAR

;-------------------------------
;* update HFine, PFine and RFine
;-------------------------------

		mov	ax,HFine
		add	ax,DeltaHRate	;HFine + DeltaHRate

		mov	bx,PFine
		add	bx,DeltaPRate	;PFine + DeltaPRate

		mov	cx,RFine
		add	cx,DeltaRRate	;RFine + DeltaRRate

		mov	dx,PitchFlip

		call	LimitPFine

		mov	HFine,ax
		mov	PFine,bx
		mov	RFine,cx

		mov	PitchFlip,dx

;--------------------------
;* calc Hdg, Pitch and Roll
;--------------------------

;* Hdg = HFine / 128

		mov	dx,cx

		mov	cl,7		;/128

		shr	ax,cl
		ROUNDUP	ax
		and	ax,001ffh
		mov	Hdg,ax

;* Pitch = PFine / 128

		shr	bx,cl
		ROUNDUP	bx
		and	bx,001ffh
		mov	Pitch,bx

;* Roll = RFine / 128

		shr	dx,cl
		ROUNDUP	dx
		and	dx,001ffh
		mov	Roll,dx

;------------------
;* calc trig angles
;------------------

;* heading

		mov	bx,Hdg
		shl	bx,1		;*2 word index
		mov	ax,SinTable[bx]
		mov	M_SinH,ax
		mov	ax,CosTable[bx]
		mov	M_CosH,ax

;* pitch

		mov	bx,Pitch
		shl	bx,1		;*2 word index
		mov	ax,SinTable[bx]
		mov	M_SinP,ax
		mov	ax,CosTable[bx]
		mov	M_CosP,ax

;* roll

		mov	bx,Roll
		shl	bx,1		;*2 word index
		mov	ax,SinTable[bx]
		mov	M_SinR,ax
		mov	ax,CosTable[bx]
		mov	M_CosR,ax

		ret

CalcAngles	ENDP

;----------------------------------------------------------------------------

;* CalcThrust - calc thrust and rpm
;*
;* pass: nothing
;* ret : Rpm1
;*       Rpm2
;*       Thrust1
;*       Thrust2
;*       Temp1
;*       Temp2
;*       Thrust
;*       Thrust4
;* kill: assume all

CalcThrust	PROC	NEAR

;--------------------
;* calc Rpm1 and Rpm2
;--------------------

;* calc rpm delta max wrt frame rate

		mov	ax,DeltaTime
		mov	dx,RPM_DELTA_MAX
		imul	dx
		FRACADJ	si

;* calc aiming rpm = IDLE_RPM + Throttle * 37

		mov	ax,Throttle
		mov	dx,37
		mul	dx		

		add	ax,IDLE_RPM	;IDLE_RPM + Throttle * 37

		mov	di,ax

;* calc rpm engine 1

CalcRpm1:	mov	al,SSF_Engine1	
		test	al,al		;engine ok?
		jnz	SpoolDown1	;no ->

		mov	ax,FuelWt
		test	ax,ax		;out of fuel?
		jz	SpoolDown1	;yes ->

		mov	ax,di
		sub	ax,Rpm1		;rpm delta required = aiming rpm - rpm

		ABSV	ax		;ax = abs(rpm delta req), dx = sign

		cmp	ax,si		;abs(rpm delta req) > rpm delta max?
		jbe	@F		;no ->
		mov	ax,si

@@:		xor	ax,dx		;restore sign
		sub	ax,dx

		add	Rpm1,ax		;update rpm

		jmp	CalcRpm2

;* out of fuel or engine failure, spool down to 0% rpm (at faster rate)

SpoolDown1:	mov	ax,Rpm1		;rpm delta required

		mov	dx,si
		shl	dx,1		;*2
		shl	dx,1		;rpm delta max * 4

		cmp	ax,dx		;rpm delta req > rpm delta max?
		jbe	@F		;no ->
		mov	ax,dx

@@:		sub	Rpm1,ax		;update rpm

;* calc rpm engine 2

CalcRpm2:	mov	al,SSF_Engine2	
		test	al,al		;engine ok?
		jnz	SpoolDown2	;no ->

		mov	ax,FuelWt
		test	ax,ax		;out of fuel?
		jz	SpoolDown2	;yes ->

		mov	ax,di
		sub	ax,Rpm2		;rpm delta required = aiming rpm - rpm

		ABSV	ax		;ax = abs(rpm delta req), dx = sign

		cmp	ax,si		;abs(rpm delta req) > rpm delta max?
		jbe	@F		;no ->
		mov	ax,si

@@:		xor	ax,dx		;restore sign
		sub	ax,dx

		add	Rpm2,ax		;update rpm

		jmp	RpmOk

;* out of fuel or engine failure, spool down to 0% rpm (at faster rate)

SpoolDown2:	mov	ax,Rpm2		;rpm delta required

		mov	dx,si
		shl	dx,1		;*2
		shl	dx,1		;rpm delta max * 4

		cmp	ax,dx		;rpm delta req > rpm delta max?
		jbe	@F		;no ->
		mov	ax,dx

@@:		sub	Rpm2,ax		;update rpm

;-------------
;* calc Thrust
;-------------

;* thrust wrt rpm tabulated from 63% to 100%
;*
;* @  63% rpm, thrust = 0lbf
;* @ 100% rpm, thrust = 18,000lbf (max dry)
;*
;* reheat = 128 stages of 125lbf each
;*
;* @ 100% rpm with full reheat, thrust = 34,000lbf
;*
;* these thrust values should be halved for each engine

;* engine 1 thrust

RpmOk:		xor	bp,bp		;assume engine 1 is idling

		mov	ax,Rpm1
		cmp	ax,IDLE_RPM	;rpm < idle?
		jb	SetThrust1	;yes ->

;* calc thrust developed from engine 1 wrt rpm (look up and interpolate)

		sub	ax,IDLE_RPM
		xor	bx,bx
		xchg	bl,ah
		shl	bx,1		;*2 word index
		mov	bp,ThrustTable[bx]
		cmp	bx,37*2			;100% ?
		je	@F			;yes ->
		mov	dx,ThrustTable[bx+2]
		sub	dx,bp
		mul	dx
		shl	al,1		;store 1/2 bit
		mov	al,ah		;/256
		mov	ah,dl
   		adc	bp,ax		;restore 1/2 bit

;* calc thrust developed from engine 1 wrt reheat

@@:		mov	al,SSF_Engine1	
		test	al,al		;engine ok?
		jnz	SetThrust1	;no, no reheat thrust ->

		mov	ax,FuelWt
		test	ax,ax		;out of fuel?
		jz	SetThrust1	;yes, no reheat thrust ->

		mov	ax,Reheat	;0 .. 128
		mov	ah,125
		mul	ah
		shr	ax,1		;/2 for one engine
		adc	bp,ax		;(1/2 bit round up)

;* set thrust and calc eng temp

SetThrust1:	mov	Thrust1,bp

		mov	dx,bp
		mov	al,SSF_Engine1
		mov	ah,EngFire1
		mov	bp,Temp1
		call	CalcEngTemp
		mov	Temp1,ax

;* engine 2 thrust

		xor	bp,bp		;assume engine 2 is idling

		mov	ax,Rpm2
		cmp	ax,IDLE_RPM	;rpm < idle?
		jb	SetThrust2	;yes ->

;* calc thrust developed from engine 2 wrt rpm (look up and interpolate)

		sub	ax,IDLE_RPM
		xor	bx,bx
		xchg	bl,ah
		shl	bx,1		;*2 word index
		mov	bp,ThrustTable[bx]
		cmp	bx,37*2			;100% ?
		je	@F			;yes ->
		mov	dx,ThrustTable[bx+2]
		sub	dx,bp
		mul	dx
		shl	al,1		;store 1/2 bit
		mov	al,ah		;/256
		mov	ah,dl
   		adc	bp,ax		;restore 1/2 bit

;* calc thrust developed from engine 2 wrt reheat

@@:		mov	al,SSF_Engine2	
		test	al,al		;engine ok?
		jnz	SetThrust2	;no, no reheat thrust ->

		mov	ax,FuelWt
		test	ax,ax		;out of fuel?
		jz	SetThrust2	;yes, no reheat thrust ->

		mov	ax,Reheat	;0 .. 128
		mov	ah,125
		mul	ah
		shr	ax,1		;/2 for one engine
		adc	bp,ax		;(1/2 bit round up)

;* set thrust and calc eng temp

SetThrust2:	mov	Thrust2,bp

		mov	dx,bp
		mov	al,SSF_Engine2
		mov	ah,EngFire2
		mov	bp,Temp2
		call	CalcEngTemp
		mov	Temp2,ax

;* if spinning and not recovered then
;*    Thrust = 0
;* end

		test	SpinFlag,1	;spinning?
		jz	CalcThrustVar	;no ->

		cmp	Recovery,0	;recovered?
		je	CalcThrustVar	;yes ->

		xor	ax,ax		;Thrust = 0

		jmp	SetThrust

;* //MOD// 08.05.1992 - Variation of thrust with altitude has been modified
;*                      to prevent the aircraft flying at speeds in excess of
;*                      mach 1 at 36,000ft with max dry thrust only.

;* variation of thrust with altitude
;*
;* if zft < 36,000ft then
;*    thrust = thrust - zft * 0.325
;* else
;*    thrust = thrust - 11700 - (zft - 36000) * 0.656
;* endif

CalcThrustVar:	mov	ax,ZftLo
		mov	dx,ZftHi

		cmp	dx,0
		ja	@F
		cmp	ax,36000
		ja	@F

		mov	dx,21299	;0.325 = 21299 / 65536
		mul	dx
		shl	ax,1
		ROUNDUP	dx

		jmp	SortThrust

@@:		sub	ax,36000
		sbb	dx,0

		jnz	@F		;zft > (65535 + 36000) ->

		mov	dx,42984	;0.656 = 42984 / 65536
		mul	dx
		shl	ax,1
		adc	dx,11700

SortThrust:	mov	ax,Thrust1
		add	ax,Thrust2

		sub	ax,dx

		jnc	SetThrust

@@:		xor	ax,ax

SetThrust:	mov	Thrust,ax

		shr	ax,1		;/2
		shr	ax,1		;Thrust4 = Thrust / 4
	
		test	ThrustRvrs,1	;thrust reversers on?
		jz	@F		;no ->

		neg	ax		;Thrust4 = -Thrust4

@@:	  	mov	Thrust4,ax

		ret

CalcThrust	ENDP		

;----------------------------------------------------------------------------

;* CalcFuelFlow - calc fuel consumption
;*
;* pass: nothing
;* ret : FuelWt
;*       FuelWtFine
;*	 FuelFlow1
;*	 FuelFlow2
;* kill: assume all

CalcFuelFlow	PROC	NEAR

;--------------------------------------
;* calc fuel consumption wrt engine rpm
;--------------------------------------

;* fuel flow rate wrt rpm:-
;*
;* val = max((rpm - IDLE_RPM) / 256, 0)
;*
;* fuel flow rate = ((val * 763 + 1802) * Rho * DeltaTime) * 4 (32 bit)

;* check if out of fuel

		mov	ax,FuelWt
		or	ax,FuelWtFine	;out of fuel?
		jnz	@F		;no ->

   		xor	si,si		;eng 1 fuel flow = 0
   		xor	di,di		;eng 2 fuel flow = 0

		jmp	DampFuelFlow

;* keep Rho constant above 36,000ft so that fuel economy does not improve with altitude

@@:		mov	bp,Rho
		cmp	bp,RhoTable[36*2]
		jae	@F
		mov	bp,RhoTable[36*2]

;* engine 1 fuel flow rate wrt rpm

@@:		mov	ax,Rpm1
		sub	ax,IDLE_RPM 	;rpm - IDLE_RPM
		MINM	ax		;max((rpm - IDLE_RPM), 0)
		mov	al,ah
		xor	ah,ah		;val = max((rpm - IDLE_RPM) / 256, 0)

		mov	dx,763
		mul	dx		;val * 763
		add	ax,1802		;val * 763 + 1802
		
		imul	bp		;(val * 763 + 1802) * Rho
		FRACADJ	dx

;* calc fuel flow lbs / sec * 1024

		mov	si,dx
		REPT	4		;/16
		shr	si,1
		ENDM

		mov	ax,DeltaTime
		imul	dx		;(val * 763 + 1802) * Rho * DeltaTime
		FRACADJ	ax

		xor	dx,dx
		REPT	2   		;*4
		shl	ax,1
		rcl	dx,1
		ENDM

		mov	bx,ax		;update fuel flow rate total
		mov	cx,dx

;* engine 2 fuel flow rate wrt rpm

		mov	ax,Rpm2
		sub	ax,IDLE_RPM 	;rpm - IDLE_RPM
		MINM	ax		;max((rpm - IDLE_RPM), 0)
		mov	al,ah
		xor	ah,ah		;val = max((rpm - IDLE_RPM) / 256, 0)

		mov	dx,763
		mul	dx		;val * 763
		add	ax,1802		;val * 763 + 1802
		
		imul	bp		;(val * 763 + 1802) * Rho
		FRACADJ	dx

;* calc fuel flow lbs / sec * 1024

		mov	di,dx
		REPT	4		;/16
		shr	di,1
		ENDM

		mov	ax,DeltaTime
		imul	dx		;(val * 763 + 1802) * Rho * DeltaTime
		FRACADJ	ax

		xor	dx,dx
		REPT	2   		;*4
		shl	ax,1
		rcl	dx,1
		ENDM

		add	bx,ax		;update fuel flow rate total
		adc	cx,dx

;* fuel flow rate wrt reheat:-
;*
;* fuel flow rate = (reheat * 235 * Rho * DeltaTime) * 32 (32 bit)

;* fuel flow rate wrt reheat (any engine)

		mov	ax,Reheat
		mov	dx,235
		mul	dx		;reheat * 235

		imul	bp		;reheat * 235 * Rho
		FRACADJ	dx

;* calc fuel flow lbs / sec * 1024

		mov	bp,dx
		shr	bp,1		;/2 (for single engine)
		
		mov	ax,DeltaTime
		imul	dx		;reheat * 235 * Rho * DeltaTime
		FRACADJ	ax

		xor	dx,dx
		REPT	5   		;*32
		shl	ax,1
		rcl	dx,1
		ENDM

		test	SSF_Engine1,1	;engine 1 ok?
		jnz	@F		;no ->

		add	bx,ax		;update fuel flow rate total
		adc	cx,dx

		add	si,bp

@@:  		test	SSF_Engine2,1	;engine 2 ok?
		jnz	@F		;no ->

		add	bx,ax		;update fuel flow rate total
		adc	cx,dx

		add	di,bp

;* update fuel weight

@@:		test	InfiniteFuel,1	;infinite fuel?
		jnz	DampFuelFlow	;yes ->

		sub	FuelWtFine,bx
		sbb	FuelWt,cx
		jnc	DampFuelFlow 	;not out of fuel ->

		xor	ax,ax
		mov	FuelWtFine,ax
		mov	FuelWt,ax

;* damp fuel flow 1 (frame rate dependant)

DampFuelFlow: 	mov	ax,si
		sub	ax,FuelFlow1	;delta = new - old
		ABSV	ax		;ax = abs(delta), dx = sign(delta)
		REPT	2		;/4
		shr	ax,1
		ENDM
		adc	ax,0		;1/2 bit round up
		xor	ax,dx		;restore sign
		sub	ax,dx
		add	FuelFlow1,ax	;(new - old) / 4 + old

;* damp fuel flow 2 (frame rate dependant)

		mov	ax,di
		sub	ax,FuelFlow2	;delta = new - old
		ABSV	ax		;ax = abs(delta), dx = sign(delta)
		REPT	2		;/4
		shr	ax,1
		ENDM
		adc	ax,0		;1/2 bit round up
		xor	ax,dx		;restore sign
		sub	ax,dx
		add	FuelFlow2,ax	;(new - old) / 4 + old

;------------------------
;* check for fuel warning
;------------------------

		cmp	FuelWt,1000
		ja	@F

		or	RedWarnings2,RED_FUEL

@@:		ret

CalcFuelFlow	ENDP

;----------------------------------------------------------------------------

;* CalcDrag - calc drag
;*
;* pass: nothing
;* ret : Drag
;*       Drag4
;* kill: assume all

CalcDrag	PROC	NEAR

;----------------
;* calc DragCoeff
;----------------

;* DragCoeff (CD) = CD0 + KsweepCL^2 + Kgear + Kairbrakes + Kground

;* calc CD0 (profile drag)

		mov	si,OFFSET CD0Table
		call	CalcSFValue
		mov	CD0,ax

		mov	bp,ax		;set drag coeff

;* calc CL1 (induced drag)
;*
;* if on ground then
;*    CL1[*128] = Kfs * Alpha * 8 * 0.14
;* else
;*    CL1[*128] = (GForce * Weight2 / 0.085 * Vdiv) * 256 / Vdiv
;* end

		mov	al,Airborne1
		test	al,al		;on ground?
		jnz	@F		;no ->

;* calc CL on ground

frac1		=	4588		;0.14 = 4588 / 32768

		mov	ax,Kfs
		mov	dx,Alpha
		sal	dx,1		;*2
		sal	dx,1		;*4
		sal	dx,1		;Alpha * 8
		imul	dx
		FRACADJ	dx    		;Kfs * Alpha * 8
		mov	ax,frac1
		imul	dx
		FRACADJ	ax		;Kfs * Alpha * 8 * frac1

		jmp	SetInducedDrag

;* calc CL airborne

frac1		=	2785		;0.085 = 2785 / 32768

@@:		mov	ax,Vdiv
		mov	cx,ax
		mov	dx,frac1
		imul	dx
		FRACADJ	bx		;frac1 * Vdiv

		mov	ax,GForce
		mov	dx,Weight2
		imul	dx		;GForce * Weight2

		idiv	bx		;GForce * Weight2 / frac1 * Vdiv

		cwd			;(GForce * Weight2 / frac1 * Vdiv) * 256
		mov	dl,ah
		mov	ah,al
		xor	al,al
		
		idiv	cx		;(GForce * Weight2 / frac1 * Vdiv) * 256 / Vdiv
   
;* limit CL to +/-2.9

SetInducedDrag:	ABSV	ax		;ax = abs(CL), dx = sign(CL)
		cmp	ax,371		;CL < 2.9?
		jbe	@F		;yes ->
		mov	ax,371		;limit to 2.9
@@:		xor	ax,dx		;restore sign
		sub	ax,dx

		mov	CL1,ax

		mov	si,ax		;>>>>> store in si <<<<<

;* calc Ksweep
;*
;* if CrntWingVal < SWEEP_A_45 then
;*    Ksweep = 0.0848 - (0.0848 - 0.041) * CrntWingVal / SWEEP_A_45
;* else
;*    Ksweep = 0.041 + (0.105 - 0.041) * (CrntWingVal - SWEEP_A_45) / (SWEEP_A_67 - SWEEP_A_45)
;* end

frac1		=	2779		;0.0848 = 2779 / 32768
frac2		=	1343		;0.041 = 1343 / 32768
frac3		=	3441		;0.105 = 3441 / 32768

		mov	ax,CrntWingVal
		cmp	ax,SWEEP_A_45	;wing sweep <= 45 degs?
		ja	@F		;no ->

		mov	dx,frac1-frac2
		mul	dx		;(frac1 - frac2) * CrntWingVal

		mov	bx,SWEEP_A_45
		div	bx		;(frac1 - frac2) * CrntWingVal / SWEEP_A_45

		neg	ax		;-((frac1 - frac2) * CrntWingVal / SWEEP_A_45)

		add	ax,frac1	;frac 1 - (frac1 - frac2) * CrntWingVal / SWEEP_A_45

		jmp	SetKsweep

@@:		sub	ax,SWEEP_A_45	;CrntWingVal - SWEEP_A_45
		mov	dx,frac3-frac2
		mul	dx		;(frac3 - frac2) * (CrntWingVal - SWEEP_A_45)

		mov	bx,SWEEP_A_67-SWEEP_A_45
		div	bx		;(frac3 - frac2) * (CrntWingVal - SWEEP_A_45) / (SWEEP_A_67 - SWEEP_A_45)

		add	ax,frac2	;frac2 + (frac3 - frac2) * (CrntWingVal - SWEEP_A_45) / (SWEEP_A_67 - SWEEP_A_45)

SetKSweep:	mov	Ksweep,ax

		mov	di,ax		;>>>>> store in di <<<<<

;* calc KsweepCL^2
;*
;* if abs(CL) <= 181 then
;*    KsweepCL^2 = Ksweep * (CL * CL)	;maintain accuracy when CL is low
;* else
;*    KsweepCL^2 = (Ksweep * CL) * CL	;prevent overflow when CL is high
;* end

		mov	ax,si
		ABSV	ax		;abs(CL)
		cmp	ax,181		;CL low?
		ja	@F		;no ->
		
;* CL low

		imul	ax		;CL * CL

		imul	di
		FRACADJ	ax		;Ksweep * (CL * CL) [*16384]
	     
		jmp	SetKsweepCL2

;* CL high
	
@@:		mov	ax,di

		imul	si
		FRACADJ	ax		;Ksweep * CL

		imul	si		;(Ksweep * CL) * CL [*16384]

SetKsweepCL2:	sal	ax,1		;*2 gives binary fraction

		mov	KsweepCL2,ax
		
		add	bp,ax		;add to drag coeff

;* Kgear - undercarriage drag

		mov	al,Gear
		test	al,al		;gear down?
		jz	@F		;no ->
		add	bp,Kgear	;add to drag coeff

;* Kairbrakes - airbrake drag

@@:		mov	al,AirBrakes
		test	al,al		;airbrakes applied?
		jz	@F		;no ->
		add	bp,Kairbrakes 	;add to drag coeff

;* Kground - ground drag

@@:		mov	al,Airborne1
		test	al,al		;on ground?
		jnz	@F		;no ->
		add	bp,Kground    	;add to drag coeff
		
@@:		mov	DragCoeff,bp

;-----------
;* Calc Drag
;-----------

;* Drag = 0.34 * DragCoeff * Vias^2 / 64 + Kwheelbrakes

		mov	ax,Vias
		xchg	ax,bp
		imul	bp
		FRACADJ	bx		;(Vias * DragCoeff)

		mov	ax,11141	;0.34 = 11141 / 32768
		imul	bp
		FRACADJ	ax		;(Vias * 0.34)

		imul	bx		;0.34 * DragCoeff * Vias^2

		REPT	6   		;/64
		sar	dx,1
		rcr	ax,1
		ENDM

		mov	cx,dx
		mov	bx,ax

;* //MOD// 05.11.1992 - Modified for wheels up landing etc.

;* if not airborne and not hit hill then
;*    if gear down then
;*	 if wheelbrakes applied then
;*          if vtas = 0 then
;*             Kwheelbrakes = Kstatic
;* 	    else
;*	       Kwheelbrakes = Krolling
;*	    endif
;*	 else
;*	    if accel < 0 then
;*             Kwheelbrakes = Kfreewheel
;*	    endif
;*       endif
;*    else
;*       Kwheelbrakes = Kwheelsup
;*    endif
;* else
;*    Kwheelbrakes = 0
;* endif

		test	HitHill,1	;hit hill?
		jnz	@F		;yes, ignore airborne flag ->

		test	Airborne1,1	;airborne?
		jnz	SetDrag		;yes, ignore brake drag ->

@@:		mov	ax,Kwheelsup	;assume wheels up landing

		test	Gear,1		;gear down?
		jz	AddWBrakeDrag	;no ->

		test	WheelBrakes,1	;wheelbrakes applied?
		jz	@F		;no ->

		mov	ax,Kstatic	;assume static

		cmp	Vtas,0		;static?
		je	AddWBrakeDrag

		mov	ax,Krolling

		jmp	AddWBrakeDrag

@@:		cmp	Accel,0		;decelerating?
		jg	SetDrag		;no ->

		mov	ax,Kfreewheel

AddWBrakeDrag:	add	bx,ax
		adc	cx,0

;* limit drag to 131,071 (01ffffh)

SetDrag:	cmp	cx,1		;drag > 131,071?
		jbe	@F		;no ->

		mov	cx,00001h
		mov	bx,0ffffh

@@:		mov	DragHi,cx
		mov	DragLo,bx

		REPT	2   		;/4
		shr	cx,1
		rcr	bx,1
		ENDM
				
		mov	Drag4,bx

		ret

CalcDrag	ENDP

;----------------------------------------------------------------------------

;* CalcPosition - calc acceleration, velocity and position
;*
;* pass: nothing
;* ret : Vtas
;*       MachNum
;*       XSec, Xft, XFine
;*       YSec, Yft, YFine
;*       NewSector
;* kill: assume all

CalcPosition	PROC	NEAR

;-----------------------------------
;* calc Accel and Vtas when spinning
;-----------------------------------

;* if spinning and not recovered then
;*    Accel = 0
;*    Vtas = max(-(Weight2 * 128 * 8 * M_SinP), 0) + 50 * 8
;* end

		mov	al,SpinFlag
		test	al,al		;spinning?
		jz	CalcAccel	;no ->

		mov	ax,Recovery
		test	ax,ax		;recovered?
		jz	CalcAccel	;yes ->

;* cx, bx = old Vtas for CalcVav calculation

		mov	ax,Vtas		;//BUG FIX//
		cwd			;//BUG FIX//
		mov	bx,ax		;//BUG FIX//
		mov	cx,dx		;//BUG FIX//

		mov	Accel,0

;* Vtas = max(-(Weight2 / 32 * M_SinP), 0) + 400

		mov	ax,Weight2
		REPT	5		;/32
		sar	ax,1
		ENDM

		mov	dx,M_SinP
		imul	dx
		FRACADJ	ax		;Weight2 / 32 * M_SinP

		neg	ax		;-(Weight2 / 32 * M_SinP)

		cwd			;dx = 00000h (+ve), dx = 0ffffh (-ve)

		not	dx		;dx = 0ffffh (+ve), dx = 00000h (-ve)

		and	ax,dx		;max(-(Weight2 / 32 * M_SinP), 0)

		add	ax,400		;approx 30kts (@ sea level)

		mov	Vtas,ax		;max(-(Weight2 / 32 * M_SinP), 0) + 400

		mov	VtasFine,0

		jmp	CalcVav

;------------
;* calc Accel
;------------

;* Accel = (Thrust4 - Drag4 - Weight2 / 2 * M_SinP) * 256 / Weight2

CalcAccel:	mov	ax,M_SinP
		mov	bp,Weight2
		shr	bp,1		;Weight2 / 2
		imul	bp
		FRACADJ	ax		;Weight2 / 2 * M_SinP
		
;* use 32-bits to avoid possible overflow

		cwd
		mov	cx,dx		;cx, bx = Weight2 / 2 * M_SinP
		mov	bx,ax

		mov	ax,Thrust4
		sub	ax,Drag4	;Thrust4 - Drag4
		cwd

		sub	ax,bx		;Thrust4 - Drag4 - Weight2 / 2 * M_SinP
		sbb	dx,cx

		mov	dl,ah		;(Thrust4 - Drag4 - Weight2 / 2 * M_SinP) * 256
		mov	ah,al
		xor	al,al

		idiv	bp  		;(Thrust4 - Drag4 - Weight2 / 2 * M_SinP) * 256 / Weight2 / 2

		mov	Accel,ax

;-----------
;* calc Vtas
;-----------

;* //MOD// 12.05.1992 - VtasFine added (Vtas not changing when Accel is small
;*                      due to truncation when Accel multiplied by DeltaTime).

;* cx, bx = old Vtas for CalcVav calculation

		mov	ax,Vtas
		cwd
		mov	bx,ax
		mov	cx,dx

;* Vtas = Vtas + Accel * DeltaTime

		mov	ax,Accel
		mov	dx,DeltaTime
		imul	dx
		shl	ax,1
		rcl	dx,1

;* //MOD// 13.11.1992 - Vtas never allowed < 0 now

		add	VtasFine,ax
		adc	Vtas,dx

		mov	ax,Vtas

		jns	CalcVav

		xor	ax,ax

		mov	Vtas,ax
		mov	VtasFine,ax

		test	Airborne1,1	;airborne?
		jnz	CalcVav		;yes ->

		mov	Accel,ax

;----------
;* calc Vav
;----------

;* Vav = (new Vtas + old Vtas) / 2

;* ax = new Vtas
;* cx, bx = sign extended old Vtas

CalcVav:	cwd	     		;dx, ax = sign extend new Vtas

		add	ax,bx
		adc	dx,cx

		sar	dx,1		;(new Vtas + old Vtas) / 2
		rcr	ax,1
		
		mov	Vav,ax

;------------
;* calc Mach1
;------------

;* if zft < 36,096ft then
;*    Mach1 = 1123 - 0.0165 * zft / 4 = 1123 - 541 / 32768 * zft / 4
;* else
;*    Mach1 = 974
;* end

		mov	bx,974		;assume zft >= 36,096ft

		cmp	ZftHi,0		;zft > 65,535?
		jne	@F		;yes ->

		mov	ax,ZftLo
		cmp	ax,36096	;zft >= 36,096?
		jae	@F		;yes ->

		REPT	2		;zft / 4
		shr	ax,1
		ENDM

		mov	dx,541
		imul	dx
		FRACADJ	dx		;541 / 32768 * zft / 4

		mov	bx,1123
		sub	bx,dx		;1123 - 541 / 32768 * zft / 4

@@:		mov	Mach1,bx

;--------------
;* calc MachNum
;--------------

;* MachNum [*16] = Vtas [*8] * 2 / Mach1
	   
		mov	ax,Vtas

;* ensure Vtas >= 0

		test	ax,ax		;Vtas >= 0?
		jns	@F		;yes ->
		xor	ax,ax

@@:		cwd
		shl	ax,1		;Vtas * 2
		rcl	dx,1	

		idiv	bx		;Vtas * 2 / Mach1

		mov	MachNum,ax

;-----------------------
;* calc XSec, Xft, XFine
;-----------------------

;* VavX = Vav * M_CosP * M_SinH
;*
;* Xft, XFine = Xft, XFine + VavX * DeltaTime * 8192

		mov	ax,Vav
		mov	dx,M_CosP
		imul	dx
		FRACADJ	bp		;Vav * M_CosP >>>>> store in bp <<<<<
		mov	ax,M_SinH
		imul	bp
		FRACADJ	dx		;Vav * M_CosP * M_SinH

		mov	ax,DeltaTime
		imul	dx
		FRACADJ	ax		;VavX * DeltaTime

		cwd	  		;VavX * DeltaTime * 256
		mov	dl,ah
		mov	ah,al
		xor	al,al

		REPT	5		;VavX * DeltaTime * 256 * 32 (*8192)
		shl	ax,1
		rcl	dx,1
		ENDM

		add	XFine,ax
		adc	Xft,dx

;* if airborne then take account of crosswinds

		test	Airborne1,1
		jz	@F
		
		mov	ax,XWindDXFine
		mov	dx,XWindDXft

		add	XFine,ax
		adc	Xft,dx

@@:

;* update XSec (keep Xft in range)

		mov	dx,XSec

		mov	ax,Xft

		cmp	ax,8192		;xft < 8192?
		jl	@F		;yes ->
		sub	ax,16384
		inc	XSec

@@:		cmp	ax,-8192	;xft >= -8192?
		jge	@F		;yes ->
		add	ax,16384
		dec	XSec

@@:		mov	Xft,ax

;* check for new sector

		xor	al,al		;assume not changed sector

		cmp	dx,XSec		;changed sector?
		je	@F		;no ->
		mov	al,1
@@:		mov	NewSector,al

;-----------------------
;* calc YSec, Yft, YFine
;-----------------------

;* VavY = Vav * M_CosP * M_CosH
;*
;* Yft, YFine = Yft, YFine + VavY * DeltaTime * 8192

		mov	ax,M_CosH
		imul	bp
		FRACADJ	dx		;Vav * M_CosP * M_CosH

		mov	ax,DeltaTime
		imul	dx
		FRACADJ	ax		;VavY * DeltaTime

		cwd	  		;VavY * DeltaTime * 256
		mov	dl,ah
		mov	ah,al
		xor	al,al

		REPT	5		;VavY * DeltaTime * 256 * 32 (*8192)
		shl	ax,1
		rcl	dx,1
		ENDM
		
		add	YFine,ax
		adc	Yft,dx

;* if airborne then take account of crosswinds

		test	Airborne1,1
		jz	@F
		
		mov	ax,XWindDYFine
		mov	dx,XWindDYft

		add	YFine,ax
		adc	Yft,dx

@@:

;* update YSec (keep Yft in range)

		mov	dx,YSec

		mov	ax,Yft

		cmp	ax,8192		;yft < 8192?
		jl	@F		;yes ->
		sub	ax,16384
		dec	YSec

@@:		cmp	ax,-8192	;yft >= -8192?
		jge	@F		;yes ->
		add	ax,16384
		inc	YSec

@@:		mov	Yft,ax

;* check for new sector

		cmp	dx,YSec		;changed sector?
		je	@F		;no ->
		mov	NewSector,1

@@:		ret

CalcPosition	ENDP

;----------------------------------------------------------------------------

;* CalcAltitude - calc climb rate and altitude
;*
;* pass: nothing
;* ret : Airborne1
;*       Airborne2
;*       TouchDown
;*       Zdot
;*       ZftHi, ZftLo, ZFine
;* kill: assume all

CalcAltitude	PROC	NEAR

;------------
;* calc Vtrim
;------------

;* //MOD// 08.05.1992 - Vtrim(delta) modified to correct alpha at take off.

;* Vtrim = Vtrim(33,000lbwt) + Vtrim(delta) + Vtrim(inverted)
;*
;* Vtrim(33,000lbwt) tabulated
;*
;* Vtrim(delta) = Weight / 32 - 128 * 8
;*
;* Vtrim(inverted) = 32 * 8

		mov	si,OFFSET VtrimTable
		call	CalcSFValue

		mov	bp,ax		;Vtrim(33,000lbwt)

		mov	ax,Weight
		mov	cl,5		;/32
		shr	ax,cl
		sub	ax,128*8

		add	bp,ax		;Vtrim(33,000lbwt) + Vtrim(delta)

		mov	ax,M_CosR
		test	ax,ax		;inverted flight?
		jns	@F		;no ->
		add	bp,32*8		;Vtrim(33,000lbwt) + Vtrim(delta) + Vtrim(inverted)

@@:		mov	Vtrim,bp

;-----------
;* calc Zdot
;-----------

;* if spinning and not recovered then
;*    Zdot = -(Weight2 / 32768 * (250 + CrntWingVal / 2)) * 8
;* else
;*    Zdot = sink rate + climb rate
;* end

		test	SpinFlag,1	;spinning?
		jz	@F		;no ->

		cmp	Recovery,0	;recovered?
		je	@F		;yes ->

		mov	ax,CrntWingVal
		shr	ax,1		;/2
		add	ax,250		;250 + CrntWingVal / 2

		REPT	3   		;(250 + CrntWingVal / 2) * 8
		shl	ax,1
		ENDM

		neg	ax		;-(250 + CrntWingVal / 2) * 8

		mov	dx,Weight2
		imul	dx
		FRACADJ	dx		;-(Weight2 / 32768 * (250 + CrntWingVal / 2)) * 8

		jmp	SetZdot

;* //MOD// 08.05.1992 - Sink rate modified to use Vtas in place of Vias.
;*                      This is so the aircraft can fly straight and level
;*                      at altitude (36,000ft) with max dry thrust.

;* Zdot = sink rate + climb rate
;*
;* sink rate = min(Vtas - Vtrim, 0) * M_CosP / 4 (only applies when Vtas < Vtrim)
;*
;* climb rate = Vtas * sin(PFine)

@@:		xor	bp,bp		;assume sink rate = 0

		mov	ax,Vtas
		sub	ax,Vtrim	;Vtas < Vtrim
		jns	@F		;no ->

		mov	dx,M_CosP
		imul	dx
		FRACADJ	bp		;min(Vtas - Vtrim, 0) * M_CosP

		sar	bp,1		;/2
		sar	bp,1		;min(Vtas - Vtrim, 0) * M_CosP / 4

;* note: sin(PFine) required for precise control when auto-terrain following

@@:		push	bp
		mov	ax,PFine
		call	CalcSineFine
		mov	dx,Vtas
		imul	dx
		FRACADJ	dx		;Vtas * sin(PFine)
		pop	bp

		add	dx,bp		;sink rate + climb rate

SetZdot:	mov	Zdot,dx

;--------------------------
;* calc ZftHi, ZftLo, ZFine
;--------------------------

;* if airborne or Zdot > 0 then
;*    ZftHi, ZftLo, ZFine = ZftHi, ZftLo, ZFine + (Zdot * DeltaTime * 8192)
;* end
   
		mov	al,Airborne1
		test	al,al		;airborne?
		jnz	@F		;yes ->

		test	dx,dx		;sinking?
		js	SortAirborne	;yes ->

;* sort computation order wrt accuracy and overflow

@@:		cmp	dx,127
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

		add	ZFine,ax
		adc	ZftLo,dx
		mov	ax,dx
		cwd
		adc	ZftHi,dx
		jns	SortAirborne

		xor	ax,ax
		mov	ZftHi,ax
		mov	ZftLo,ax
		mov	ZFine,ax

;-----------------------------
;* test if airborne (zft <> 0)
;-----------------------------

SortAirborne:	mov	ax,ZftLo
		or	ax,ZftHi
		jz	@F		;on ground ->
		mov	al,1		;airborne

@@:		mov	ah,al
		xchg	ah,Airborne1
		mov	Airborne2,ah

;* TouchDown = Airborne2 and not(Airborne1) (1 -> 0 transition)

		not	al
		and	al,ah
		mov	TouchDown,al
		_JZ	SkipTouchDown

;--------------
;* touched down
;--------------

		xor	ax,ax

;* clear previous landing flags

		mov	Landing,al

;* set aircraft level

		mov	Roll,ax
		mov	RFine,ax

		test	SpinFlag,1	;spinning?
		jz	@F		;no ->

		mov	Pitch,ax
		mov	PFine,ax

;* stop spinning (in case no collisions)

		mov	SpinFlag,al
		mov	Recovery,ax

;* check if landed on road

@@:		mov	si,OFFSET M_VIEW
		call	SurfaceCheck

		cmp	ax,SURFACE_ROAD	;landed on a road?
		jne	@F		;no ->

		or	Landing,LAND_ROAD

;* no collisions?

@@:		test	NoCollisions,1	;no collisions?
		_JNZ	ContLanding	;yes ->

;* check approx attitude for landing

		cmp	M_CosR,23170	;abs(roll) > 45 degs?
		jl	@F		;yes ->

		cmp	PFine,-1820	;pitch < -10degs?
		jl	@F		;yes ->

		cmp	PFine,5461	;pitch > 30degs?
		jle	AttOk		;no ->

@@:		DESTROY	DIE_CRASH_GND,TOTAL_DAMAGE
		
		jmp	SkipTouchDown

;* check sink rate:-
;*
;* gear down: crash if sink rate < -40ft/sec
;* gear up  : crash if sink rate < -10ft/sec

AttOk:		mov	ax,-40*8	;assume gear down

		test	Gear,1		;gear down?
		jnz	@F		;yes ->

		mov	ax,-10*8

@@:		cmp	ax,Zdot		;sink rate too high?
		jle	SinkOk		;no ->

		DESTROY	DIE_SINK_HI,TOTAL_DAMAGE

		jmp	SkipTouchDown

;* check roll (wrt wing sweep):-
;*
;* @ 25degs: abs(roll) <= 17degs
;* @ 45degs: abs(roll) <= 18degs
;* @ 67degs: abs(roll) <= 19degs

SinkOk:		mov	ax,31336	;cos(17) (assume 25degs)
		cmp	CrntWingPos,SWEEP_D_25
		je	@F

		mov	ax,31164	;cos(18) (assume 45degs)
		cmp	CrntWingPos,SWEEP_D_45
		je	@F

		mov	ax,30983	;cos(19)

@@:		cmp	ax,M_CosR	;roll too high?
		jle	RollOk		;no ->

		DESTROY	DIE_ROLL_HI,MAJOR_DAMAGE

		jmp	SkipTouchDown

;* check for nose wheel collapsed

RollOk:		cmp	PFine,0		;pitched down?
		jge	NoseOk		;no ->

		test	Gear,1		;gear down?
		jz	@F		;no ->

		mov	Gear,0			;collapse gear
		mov	SSF_Gear,1		;damage gear
		or	RedWarnings2,RED_UC	;report damage

		DESTROY	DIE_NOSE_WHEEL,MAJOR_DAMAGE

		jmp	SkipTouchDown

@@:		DESTROY	DIE_CRASH_GND,TOTAL_DAMAGE

		jmp	SkipTouchDown

;* check pitch (wrt wing sweep):-
;*
;* @ 25degs: pitch <= 19degs
;* @ 45degs: pitch <= 18degs
;* @ 67degs: pitch <= 17degs

NoseOk:		mov	ax,3459		;19degs (assume 25degs)
		cmp	CrntWingPos,SWEEP_D_25
		je	@F

		mov	ax,3277		;18degs (assume 45degs)
		cmp	CrntWingPos,SWEEP_D_45
		je	@F

		mov	ax,3095		;17degs

@@:		cmp	ax,PFine	;pitch too high?
		jge	ContLanding	;no ->

		DESTROY	DIE_TAIL_SCRAPE,MAJOR_DAMAGE

		jmp	SkipTouchDown

;* calc gear collapse threshold (wrt weight):-
;*
;* @32768lbs, threshold = -20ft/sec (*8 scaled)
;* @65535lbs, threshold =  -4ft/sec (*8 scaled)
;*
;* wt = max(weight,32768) - 32768 = 0 .. 32767
;*
;* threshold = -(20 * 8 - wt / 256) = -160 .. -40

ContLanding:	mov	ax,Weight
		sub	ax,32768
		MINM	ax		;0 .. 32767
		xchg	al,ah		;/256
		shl	ah,1		;expose 1/2 bit
		adc	al,0		;round up
		xor	ah,ah		;0 .. 128

		mov	bp,20*8
		sub	bp,ax

		neg	bp

		test	NoCollisions,1	;no collisions?
		jnz	SortLanding	;yes ->

;* check for gear collapse (sink rate < threshold)

		test	Gear,1		;gear down?
		_JZ	SortWheelsUp	;no ->

		cmp	Zdot,bp		;gear collapsed?
		jge	SortLanding	;no ->

		mov	Gear,0			;collapse gear
		mov	SSF_Gear,1		;damage gear
		or	RedWarnings2,RED_UC	;report damage

		DESTROY	DIE_COLLAPSE,MAJOR_DAMAGE

		jmp	SkipTouchDown

;* sort landing - heavy / wheels up / dead stick etc.

SortLanding:	test	Gear,1		;gear down?
		_JZ	SortWheelsUp	;no ->

;* if no collisions then check approx aircraft attitude (else wheelsbrakes
;* get damaged and wheel screech sounds etc. when aircraft lands inverted)

		test	NoCollisions,1	;no collisions?
		jz	@F		;no ->

		cmp	M_CosR,31164	;abs(roll) > 18 degs?
		jl	LandHeavy	;yes ->

		cmp	PFine,0		;pitch < 0degs?
		jl	LandHeavy	;yes ->

		cmp	PFine,3277	;pitch > 18degs?
		jg	LandHeavy	;no ->

;* wheelbrakes on then damage wheelbrakes

@@:		test	WheelBrakes,1	;wheelbrakes applied?
		jz	@F		;no ->

		mov	SSF_WheelBrakes,1	;damage wheelbrakes
		or	AmbWarnings2,AMB_WB	;report damage

@@:		push	bp
		call	ScreechSound	;make wheel screech sound
		pop	bp

		sar	bp,1		;heavy thresh = gear collapse thresh / 2

		cmp	ZDot,bp		;heavy landing?
		jge	@F		;no ->

LandHeavy:	or	Landing,LAND_HEAVY

		SHAKE	SHAKE_LAND_HVY,HSHAKE_OFF,VSHAKE_HI,20
		
		jmp	SortDeadStick

@@:  		or	Landing,LAND_GOOD

		SHAKE	SHAKE_LAND_GOOD,HSHAKE_OFF,VSHAKE_LO,10

		jmp	SortDeadStick

SortWheelsUp: 	or	Landing,LAND_WHEELS_UP+LAND_HEAVY

SortDeadStick:	mov	al,SSF_Engine1	;both engines failed?
		and	al,SSF_Engine2	
		jnz	@F		;yes ->

		cmp	FuelWt,0	;out of fuel?
		ja	SkipTouchDown	;no ->

@@:		or	Landing,LAND_DEAD_STICK

SkipTouchDown:	ret

CalcAltitude	ENDP

;----------------------------------------------------------------------------

;* PostAmble - model postamble
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

PostAmble	PROC	NEAR

;-----------------------------
;* copy model vars into M_VIEW
;-----------------------------

;* //MOD// 22.06.1992 - Delete mobile if changed sector.

		test	NewSector,1	;changed sector?
		jz	@F		;no ->

		mov	si,OFFSET M_MOBILE
		call	DeleteMobile

@@:		mov	ax,XSec
		mov	M_VIEW.VP_XSEC,ax
		mov	ax,YSec
		mov	M_VIEW.VP_YSEC,ax

		mov	ax,Xft
		mov	M_VIEW.VP_XFT,ax
		mov	ax,Yft
		mov	M_VIEW.VP_YFT,ax
		mov	ax,ZftHi
		mov	WORD PTR M_VIEW.VP_ZFT_HI,ax
		mov	ax,ZftLo
		mov	WORD PTR M_VIEW.VP_ZFT_LO,ax

		mov	ax,Hdg
		mov	M_VIEW.VP_HDG,ax
		mov	ax,Pitch
		mov	M_VIEW.VP_PITCH,ax
		mov	ax,Roll
		mov	M_VIEW.VP_ROLL,ax

;* //MOD// 22.06.1992 - Create mobile if changed sector.

		test	NewSector,1	;changed sector?
		jz	@F		;no ->

		mov	si,OFFSET M_MOBILE
		call	CreateMobile

;----------------------
;* sort animation flags
;----------------------

;* //MOD// 27.07.1992 - Animation reorganized.

;* wing sweep

@@:		mov	al,CrntWingPos

;* undercarriage

		test	Gear,1		;gear down?
		jz	@F		;no ->
		or	al,GEAR_DOWN

;* reheat

@@:		cmp	Reheat,0	;reheat on?
		je	SetAnim		;no ->

		cmp	FuelWt,0	;any fuel?
		je	SetAnim		;no ->

		test	SSF_Engine1,1	;lh engine ok?
		jnz	@F		;no ->
		or	al,REHEAT_L_ENG

@@:		test	SSF_Engine2,1	;rh engine ok?
		jnz	SetAnim		;no ->
		or	al,REHEAT_R_ENG

SetAnim:	mov	M_MOBILE.MOB_ANIM,al

;-------------------
;* calc display vars
;-------------------

;* calc DispGForce (frame rate dependant)

;* DispGForce = (GForce - DispGForce) / 4 + DispGForce

		mov	ax,GForce
		sub	ax,DispGForce

;* use abs(GForce - DispGForce) to avoid -1 truncation error

		ABSV	ax
		REPT	2		;/4
		shr	ax,1
		ENDM
		adc	ax,0		;1/2 bit round up
		xor	ax,dx		;restore sign
		sub	ax,dx

		add	DispGForce,ax

;* calc DispAlpha (frame rate dependant)

;* DispAlpha = (Alpha - DispAlpha) / 4 + DispAlpha

		mov	ax,Alpha
		sub	ax,DispAlpha

;* use abs(Alpha - DispAlpha) to avoid -1 truncation error

		ABSV	ax
		REPT	2		;/4
		shr	ax,1
		ENDM
		adc	ax,0		;1/2 bit round up
		xor	ax,dx		;restore sign
		sub	ax,dx

		add	DispAlpha,ax

;* calc DispZdot (frame rate dependant)

;* if on ground then
;*    Zdot = 0
;* end
;*
;* DispZdot = (Zdot - DispZdot) / 2 + DispZdot

		xor	ax,ax		;assume Zdot = 0

		test	Airborne1,1	;on ground?
		jz	@F		;yes ->
		mov	ax,Zdot

@@:   		sub	ax,DispZdot

;* use abs(Zdot - DispZdot) to avoid -1 truncation error

		ABSV	ax
		REPT	1		;/2
		shr	ax,1
		ENDM
		adc	ax,0		;1/2 bit round up
		xor	ax,dx		;restore sign
		sub	ax,dx

		add	DispZdot,ax

;* calc DispVSI (ft / min) = DispZdot * 3 / 4

		mov	ax,DispZdot

		ABSV	ax		;ax = abs, dx = sign

		mov	bp,ax

		xor	bx,bx		;bx, ax = 32 bit value

		REPT	2		;*3
		add	ax,bp
		adc	bx,0
		ENDM

		REPT	2		;/4
		shr	bx,1
		rcr	ax,1
		ENDM

		adc	ax,0		;1/2 bit round up

		xor	ax,dx		;restore sign
		sub	ax,dx

		mov	DispVSI,ax

;* calc DispHdg (1 .. 360)

		mov	ax,HFine
		mov	dx,360
		mul	dx
		shl	ax,1		
		ROUNDUP	dx
		jnz	@F

		mov	dx,360		;display 0 as 360

@@:		mov	DispHdg,dx

;* calc DispBarAlt (zft / 10)

		mov	dx,ZftHi
		mov	ax,ZftLo
		mov	bx,10
		div	bx

		mov	DispBarAlt,ax

;* calc DispMachNum (convert MachNum[*16] to *10 scaled (MachNum * 5 / 8))

		mov	ax,MachNum
		mov	dx,ax
		REPT	2		;*4
		shl	ax,1
		ENDM
		add	ax,dx		;*5
		REPT	3		;/8
		shr	ax,1
		ENDM
		ROUNDUP	ax

		mov	DispMachNum,ax

;------------------
;* check for buffet (excess speed wrt wing sweep)
;------------------

		mov	al,CrntWingPos
		xor	ah,ah

		shl	ax,1		;*2
		mov	bx,ax
		shl	ax,1		;*4
		add	bx,ax		;*6

		mov	ax,MachNum

		cmp	ax,BuffetThresh[bx]	;< buffet threshold?
		jb	NoBuffet		;yes ->

		cmp	ax,BuffetThresh[bx+2]	;< lo buffet threshold?
		jb	LoBuffet		;yes ->

		cmp	ax,BuffetThresh[bx+4]	;< hi buffet threshold?
		jb	HiBuffet		;yes ->

		DESTROY	DIE_BREAK_UP,TOTAL_DAMAGE

		jmp	BuffetOk

LoBuffet:	SHAKE	SHAKE_BUFFET,HSHAKE_OFF,VSHAKE_LO,65535

		jmp	BuffetOk

HiBuffet:	SHAKE	SHAKE_BUFFET,HSHAKE_OFF,VSHAKE_HI,65535

		call	MinDamage

		jmp	BuffetOk

NoBuffet:	UNSHAKE SHAKE_BUFFET

;-----------------------
;* check for flap damage
;-----------------------

;* if flaps are damaged then do not issue config warning as it is irritating!

BuffetOk:	test	SSF_Flaps,1	;flaps already damaged?
		jnz	FlapsOk		;yes ->

		mov	bl,CrntFlapPos
		xor	bh,bh
		shl	bx,1		;*2
		shl	bx,1		;*4

		mov	ax,Vias

		cmp	ax,FlapThresh[bx]	;< warning threshold?
		jl	FlapsOk			;yes ->

		or	AmbWarnings2,AMB_CNFG	;issue warning

		cmp	ax,FlapThresh[bx+2]	;< damage threshold?
		jl	FlapsOk			;yes ->

		mov	SSF_Flaps,1		;damage flaps mechanism
		
		or	AmbWarnings2,AMB_FLPS	;report damage

;------------------------------
;* check for crashed into hills
;------------------------------

FlapsOk:	mov	HitHill,0

		cmp	ZftHi,0		;zft > 65535ft?
		_JA	SkipHillTest	;yes ->
		cmp	ZftLo,4095	;zft > 4095ft?
		_JA	SkipHillTest	;yes ->

		mov	si,OFFSET M_VIEW
		call	CalcGndHeight

		test	ax,ax		;hill here?
		_JZ	SkipHillTest	;no ->

		cmp	ax,ZftLo	;crashed into hill?
		_JB	SkipHillTest	;no ->

;* crashed into hill

		mov	HitHill,1

		mov	ZFine,0
		mov	ZftLo,ax
		mov	ZftHi,0

		mov	WORD PTR M_VIEW.VP_ZFT_LO,ax
		mov	WORD PTR M_VIEW.VP_ZFT_HI,0

		xor	ax,ax

		mov	Roll,ax
		mov	RFine,ax

;* enable aircraft to take from hillside (in case no collisions)

		cmp	PFine,0		;pitched down?
		jge	@F		;no ->

		mov	Pitch,ax
		mov	PFine,ax

;* stop spinning (in case no collisions)

@@:		mov	SpinFlag,al
		mov	Recovery,ax

;* shake aircraft (unless moving) in case no collsions enabled

		UNSHAKE	SHAKE_OFF_HARD	;assume not moving

		cmp	Vtas,0		;moving?
		je	@F		;no ->

		SHAKE	SHAKE_OFF_HARD,HSHAKE_HI,VSHAKE_HI,65535

@@:		test	NoCollisions,1	;no collisions?
		jnz	SkipHillTest	;yes ->

		DESTROY	DIE_CRASH_HILL,TOTAL_DAMAGE

;---------------
;* surface check
;---------------

SkipHillTest:	test	Airborne1,1	;airborne?
		jz	@F		;no ->

		test	HitHill,1	;hit hill (do not unshake)?
		jnz	@F		;yes ->

		UNSHAKE	SHAKE_OFF_HARD
		UNSHAKE	SHAKE_WHEELS_UP

		jmp	SkipSurfaceChk

@@:		UNSHAKE	SHAKE_WHEELS_UP	;assume gear down

		test	Gear,1		;gear down?
		jnz	@F		;yes ->

		cmp	Vtas,0		;moving?
		je	@F		;no ->

		SHAKE	SHAKE_WHEELS_UP,HSHAKE_HI,VSHAKE_HI,65535

		mov	bx,SMOKE_KICK_UP
		mov	si,OFFSET M_VIEW
		call	MakeSmokeEffect

@@:		mov	si,OFFSET M_VIEW
		call	SurfaceCheck

		mov	dx,Vtas

		cmp	ax,SURFACE_RUNWAY
		je	HardSurface
		cmp	ax,SURFACE_TAXIWAY
		je	HardSurface
		cmp	ax,SURFACE_HARD
		je	HardSurface
		cmp	ax,SURFACE_ROAD
		je	HardSurface

		cmp	ax,SURFACE_RAILWAY
		_JE	RailSurface

		cmp	ax,SURFACE_RIVER
		_JE	Ditched
		cmp	ax,SURFACE_LAKE
		_JE	Ditched

;* unknown surface
;*
;* up to  5kts ok (no shake)
;* up to 30kts ok (lo shake)
;* up to 50kts ok (hi shake)
;* above 50kts then crash

		cmp	dx,8*8		;vtas < 5kts?
		jb	NoOffHard	;yes ->

		cmp	dx,51*8		;vtas < 30kts?
		jb	LoOffHard	;no ->

		cmp	dx,85*8		;vtas < 50kts?
		jb	HiOffHard	;no ->

		jmp	GndSpeedHigh

;* hard surface
;*
;* up to 180kts ok (no shake)
;* up to 200kts ok (lo shake)
;* up to 225kts ok (hi shake)
;* above 225kts then crash

HardSurface:	cmp	dx,306*8 	;vtas < 180kts?
		jb	NoOffHard	;yes ->

		cmp	dx,340*8 	;vtas < 200kts?
		jb	LoOffHard	;no ->

		cmp	dx,383*8  	;vtas < 225kts?
		jb	HiOffHard	;no ->

		jmp	GndSpeedHigh

LoOffHard:	SHAKE	SHAKE_OFF_HARD,HSHAKE_OFF,VSHAKE_LO,65535

		jmp	SkipSurfaceChk

HiOffHard:	SHAKE	SHAKE_OFF_HARD,HSHAKE_OFF,VSHAKE_HI,65535

		jmp	SkipSurfaceChk

NoOffHard:	UNSHAKE	SHAKE_OFF_HARD

		jmp	SkipSurfaceChk

;* rail surface
;*
;* if no collisions and not moving then
;*    no shake
;* else
;*    ground speed too high
;* endif

RailSurface: 	test	NoCollisions,1	;no collisions?
		jz	GndSpeedHigh	;no ->

		test	dx,dx		;moving?
		jnz	GndSpeedHigh	;yes ->

		UNSHAKE	SHAKE_OFF_HARD

		jmp	SkipSurfaceChk

;* ground speed too high - shake in case no collisions

GndSpeedHigh: 	SHAKE	SHAKE_OFF_HARD,HSHAKE_OFF,VSHAKE_HI,65535

		test	NoCollisions,1	;no collisions?
		jnz	SkipSurfaceChk	;yes ->

		DESTROY	DIE_GND_SPD_HI,MINOR_DAMAGE

		jmp	SkipSurfaceChk

;* ditched - shake in case no collisions

Ditched: 	SHAKE	SHAKE_OFF_HARD,HSHAKE_OFF,VSHAKE_HI,65535

		test	dx,dx		;moving?
		jnz	@F		;yes ->

		UNSHAKE	SHAKE_OFF_HARD

@@:		test	NoCollisions,1	;no collisions?
		jnz	SkipSurfaceChk	;yes ->

		DESTROY	DIE_DITCHED,TOTAL_DAMAGE

;-------------------
;* check engine fire
;-------------------

SkipSurfaceChk:	mov	al,EngFire1
		or	al,EngFire2	;any engine on fire?
		jz	SkipEngFire	;no ->

		mov	ax,EngFireTimer
		sub	ax,LastFrame
		MINM	ax
		mov	EngFireTimer,ax

		jnz	@F		;not destroyed by fire ->

		DESTROY	DIE_FIRE,TOTAL_DAMAGE

		jmp	SkipEngFire

@@:		cmp	ax,ENG_FIRE_TIME/2	;time to damage engine(s)?
		ja	SkipEngFire

		test	EngFire1,1	;engine 1 on fire?
		jz	@F		;no ->

		mov	SSF_Engine1,1		;damage engine
		or	RedWarnings2,RED_L_ENG	;report damage

@@:		test	EngFire2,1	;engine 2 on fire?
		jz	SkipEngFire	;no ->

		mov	SSF_Engine2,1		;damage engine
		or	RedWarnings2,RED_R_ENG	;report damage

;------------------------------------
;* check for not moving and reheat on (shake aircraft)
;------------------------------------

SkipEngFire:	UNSHAKE	SHAKE_BRAKE	;assume moving

		cmp	Vtas,0		;moving?
		jg	SkipBrakeShake	;yes ->

		test	Airborne1,1	;airborne?
		jz	@F		;no ->

		test	HitHill,1	;hit hill?
		jz	SkipBrakeShake	;no ->

@@:		cmp	Thrust1,9000	;engine 1 thrust > max dry?
		ja	@F		;yes ->

		cmp	Thrust2,9000	;engine 2 thrust > max dry?
		jbe	SkipBrakeShake	;no ->

@@:		SHAKE	SHAKE_BRAKE,HSHAKE_OFF,VSHAKE_LO,65535

SkipBrakeShake:

;-------------------
;* check gear damage
;-------------------

;* only damage gear if lowered

		test	Gear,1
		jz	@F

;* ignore if already damaged

		test	SSF_Gear,1
		jnz	@F

;* issue warning if IAS > 250kts

		cmp	Vkts,250
		jbe	@F

		or	AmbWarnings2,AMB_UC	;issue warning

;* damage gear if IAS > 350kts

		cmp	Vkts,350
		jbe	@F

		mov	SSF_Gear,1		;damage gear
		or	RedWarnings2,RED_UC	;report damage

@@:

;------------------
;* sort smoke trail
;------------------

;* if destroyed or engine fire then
;*    if airborne and not hit hill then
;*       make smoke trail
;*    else
;*       kick up smoke
;*    endif
;* endif

		mov	al,Destroyed
		or	al,EngFire1
		or	al,EngFire2
		jz	SkipSmokeTrail

		mov	bx,SMOKE_AIR_TRAIL

		mov	al,HitHill
		not	al
		and	al,Airborne1
		jnz	@F

		mov	bx,SMOKE_KICK_UP

@@:		mov	si,OFFSET M_VIEW
		call	MakeSmokeEffect

SkipSmokeTrail:

;-----------------
;* init new sector
;-----------------

		test	NewSector,1	;changed sector?
		jz	@F		;no ->

		call	InitNewSector

@@:

;---------------------
;* collision detection
;---------------------

;-----------------------------------
;* calc delta x, delta y and delta z
;-----------------------------------

;-------------
;* calc Dx / 4
;-------------

;* x1 = xsec * 16384 + xft + 8192

		mov	cx,M_TEST.VP_XSEC
		xor	bx,bx
		REPT	2
		sar	cx,1
		rcr	bx,1
		ENDM
		mov	bp,M_TEST.VP_XFT
		add	bp,8192
		add	bx,bp
		adc	cx,0

;* x2 = xsec * 16384 + xft + 8192

		mov	dx,M_VIEW.VP_XSEC
		xor	ax,ax
		REPT	2
		sar	dx,1
		rcr	ax,1
		ENDM
		mov	bp,M_VIEW.VP_XFT
		add	bp,8192
		add	ax,bp
		adc	dx,0

;* Dx = x2 - x1

		sub	ax,bx
		sbb	dx,cx

		jns	@F

		NEG32	dx,ax

		REPT	2
		shr	dx,1
		rcr	ax,1
		ENDM

		adc	ax,0
		adc	dx,0

		NEG32	dx,ax

		jmp	DxOk

@@:		REPT	2
		shr	dx,1
		rcr	ax,1
		ENDM

		adc	ax,0
		adc	dx,0

DxOk:		push	ax		;store Dx
		push	dx

;-------------
;* calc Dy / 4
;-------------

;* y1 = -(ysec * 16384) + yft - 8192

		mov	dx,M_TEST.VP_YSEC
		xor	ax,ax
		REPT	2
		sar	dx,1
		rcr	ax,1
		ENDM
		NEG32	dx,ax
		mov	bp,M_TEST.VP_YFT
		sub	bp,8192
		add	ax,bp
		adc	dx,0

;* y2 = -(ysec * 16384) + yft - 8192

		mov	cx,M_VIEW.VP_YSEC
		xor	bx,bx
		REPT	2
		sar	cx,1
		rcr	bx,1
		ENDM
		NEG32	cx,bx
		mov	bp,M_VIEW.VP_YFT
		sub	bp,8192
		add	bx,bp
		adc	cx,0

;* Dy = y2 - y1

		sub	bx,ax
		sbb	cx,dx

		jns	@F

		NEG32	cx,bx

		REPT	2
		shr	cx,1
		rcr	bx,1
		ENDM

		adc	bx,0
		adc	cx,0

		NEG32	cx,bx

		jmp	DyOk

@@:		REPT	2
		shr	cx,1
		rcr	bx,1
		ENDM

		adc	bx,0
		adc	cx,0

;-------------
;* calc Dz / 4
;-------------

;* z1

DyOk:		mov	ax,WORD PTR M_TEST.VP_ZFT_LO
		mov	dx,WORD PTR M_TEST.VP_ZFT_HI

;* z2

		mov	si,WORD PTR M_VIEW.VP_ZFT_LO
		mov	di,WORD PTR M_VIEW.VP_ZFT_HI

;* Dz = abs(z2 - z1)

		sub	si,ax
		sbb	di,dx

		jns	@F

		NEG32	di,si

		REPT	2
		shr	di,1
		rcr	si,1
		ENDM

		adc	si,0
		adc	di,0

		NEG32	di,si

		jmp	DzOk

@@:		REPT	2
		shr	di,1
		rcr	si,1
		ENDM

		adc	si,0
		adc	di,0

DzOk:		pop	dx		;restore Dx
		pop	ax

;-------------
;* sample loop
;-------------

;* Dx = dx, ax
;* Dy = cx, bx
;* Dz = di, si

		mov	bp,4

CollisionLoop:	push	ax
		push	bx
		push	cx
		push	dx
		push	si
		push	di
		push	bp

		add	WORD PTR M_TEST.VP_ZFT_LO,si
		adc	WORD PTR M_TEST.VP_ZFT_HI,di

		jns	@F

		mov	WORD PTR M_TEST.VP_ZFT_LO,0
		mov	WORD PTR M_TEST.VP_ZFT_HI,0

@@:		mov	si,OFFSET M_TEST
		call	MoveViewpoint

;* ground object collision

		mov	si,OFFSET M_TEST
		call	GroundCollision
		jc	HitGndObject

;* static mobile collision

		mov	si,OFFSET M_TEST
		call	StaticCollision
		jc	HitMobObject

;* mobile object collision

		mov	si,OFFSET M_TEST
		mov	di,OFFSET M_MOBILE
		call	MobileCollision
		jc	HitMobObject

;* tree collision

		mov	si,OFFSET M_TEST
		call	TreeCollision
		jc	HitGndObject

;* crater collision

		mov	si,OFFSET M_TEST
		call	CraterCollision
		jc	HitMobObject

		pop	bp
		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax

		dec	bp
		jnz	CollisionLoop

		jmp	SkipCollisions

;---------------------------
HitGndObject	LABEL	NEAR
;---------------------------

		mov	HitObjectNum,al

;* clean up stack

		pop	bp
		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax

;* destroy Tornado

		test	NoCollisions,1
		jnz	@F

		DESTROY	DIE_HIT_GND_OBJ,TOTAL_DAMAGE

		jmp	SkipCollisions

@@:		SHAKE	SHAKE_COLLIDE,HSHAKE_HI,VSHAKE_HI,50

		jmp	SkipCollisions

;---------------------------
HitMobObject	LABEL	NEAR
;---------------------------

		mov	HitObjectNum,al

;* clean up stack

		pop	bp
		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax

;* destroy Tornado

		test	NoCollisions,1
		jnz	@F

		DESTROY	DIE_HIT_MOB_OBJ,TOTAL_DAMAGE

		jmp	SkipCollisions

@@:		SHAKE	SHAKE_COLLIDE,HSHAKE_HI,VSHAKE_HI,50

SkipCollisions:	ret

PostAmble	ENDP

;----------------------------------------------------------------------------

;* GameIntr20 - 20Hz game interrupt
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

GameIntr20	PROC	FAR

;----------------
;* scan game keys
;----------------

		test	Paused,1	;paused?
		_JNZ	ScanPaused	;yes ->

		cmp	DisableInput,0	;input disabled?
		_JNE	ScanDisabled	;yes ->

		mov	bx,CrewMode
		jmp	KF_ScanSwitch[bx]

;---------------------------
KF_ScanPilot	LABEL	NEAR
;---------------------------

	IF	OPT_DEMO EQ 0

		KUPDATE	KF_HUDContrast,K_H
		KUPDATE	KF_HUDSwitch,K_CTRL,_AND_,K_H
		KUPDATE	KF_HUDOption,K_ALT,_AND_,K_H

		KUPDATE	KF_ResetTrkCam,K_CTRL,_AND_,K_F1
		KUPDATE	KF_ResetSatCam,K_CTRL,_AND_,K_F2
		KUPDATE	KF_ResetWpnCam,K_CTRL,_AND_,K_V
		KUPDATE	KF_ZoomIn,K_LESSTHAN
		KUPDATE	KF_ZoomOut,K_GRTRTHAN
		KUPDATE	KF_FastZoomIn,K_SHIFT,_AND_,K_LESSTHAN
		KUPDATE	KF_FastZoomOut,K_SHIFT,_AND_,K_GRTRTHAN
	    	KUPDATE	KF_TrackClk,K_X
		KUPDATE	KF_TrackAClk,K_Z
		KUPDATE	KF_FastTrkClk,K_SHIFT,_AND_,K_X
		KUPDATE	KF_FastTrkAClk,K_SHIFT,_AND_,K_Z

	ENDIF

		jmp	KF_ScanCommon

;---------------------------
KF_ScanNavig	LABEL	NEAR
;---------------------------

	IF	OPT_DEMO EQ 0

		KUPDATE	KF_DispSelect,K_TAB
		KUPDATE	KF_TAB1Select,K_OPN_SQ_BRKT
		KUPDATE	KF_TAB1Toggle,K_CTRL,_AND_,K_OPN_SQ_BRKT
		KUPDATE	KF_TAB2Select,K_CLS_SQ_BRKT
		KUPDATE	KF_TAB2Toggle,K_CTRL,_AND_,K_CLS_SQ_BRKT

	ENDIF

;---------------------------
KF_ScanCommon	LABEL	NEAR
;---------------------------

	IF	OPT_DEMO EQ 0

		KUPDATE	KF_PilotView,K_HOME
		KUPDATE	KF_NavigView,K_PGUP
		KUPDATE	KF_LViewFix,K_SHIFT,_AND_,K_END
		KUPDATE	KF_RViewFix,K_SHIFT,_AND_,K_PGDN
		KUPDATE	KF_LViewGlance,K_END
		KUPDATE	KF_RViewGlance,K_PGDN
		KUPDATE	KF_TrackingCam,K_F1
		KUPDATE	KF_SatelliteCam,K_F2
		KUPDATE	KF_RemoteView,K_F3
		KUPDATE	KF_Spectator,K_F4
		KUPDATE	KF_RestoreSpec,K_CTRL,_AND_,K_F4
		KUPDATE	KF_DroneView,K_F5
		KUPDATE	KF_DronePrev,K_SHIFT,_AND_,K_F5
		KUPDATE	KF_DroneSide,K_ALT,_AND_,K_F5
		KUPDATE	KF_DroneType,K_CTRL,_AND_,K_F5
		KUPDATE	KF_MapView,K_M
		KUPDATE	KF_LookDown,K_NUMLOCK
		KUPDATE	KF_ViewWeapon,K_V

		KUPDATE	KF_IronWork,K_6
		KUPDATE	KF_Control,K_7
		KUPDATE	KF_Sound,K_8

		KUPDATE	KF_Gear,K_U,_OR_,K_G
		KUPDATE	KF_WheelBrakes,K_B
		KUPDATE	KF_AirBrakes,K_BACKSPACE
		KUPDATE	KF_WingSwpFwd,K_W
		KUPDATE	KF_WingSwpBack,K_S
		KUPDATE	KF_FlapsUp,K_Q
		KUPDATE	KF_FlapsDn,K_A
		KUPDATE	KF_SPILS,K_CTRL,_AND_,K_I

		KUPDATE	KF_MFDSelect,K_D
		KUPDATE	KF_MFDToggle,K_CTRL,_AND_,K_D
		KUPDATE	KF_MapZoomIn,K_LESSTHAN
		KUPDATE	KF_MapZoomOut,K_GRTRTHAN
		KUPDATE	KF_MapOrigin,K_O

		KUPDATE	KF_GndRadar,K_R
		KUPDATE	KF_AirRadar,K_ALT,_AND_,K_R
		KUPDATE	KF_RadarOff,K_CTRL,_AND_,K_R
		KUPDATE	KF_BoreSight,K_CAPSLOCK
		KUPDATE	KF_CycleAirTgt,K_ALT,_AND_,K_CAPSLOCK
		KUPDATE	KF_CancelAirTgt,K_CTRL,_AND_,K_CAPSLOCK

		KUPDATE	KF_ArmGnd,K_ENTER
		KUPDATE	KF_ArmAir,K_ALT,_AND_,K_ENTER
		KUPDATE	KF_ArmOff,K_CTRL,_AND_,K_ENTER

		KUPDATE	KF_Package,K_K
		KUPDATE	KF_WpnMode,K_L
		KUPDATE	KF_AirWeapon,K_SEMICOLON

		KUPDATE	KF_WpnFire,K_SPACE
		KUPDATE	KF_WpnCommit,K_SPACE

		KUPDATE	KF_ECM,K_E
		KUPDATE	KF_Chaff,K_C
	        KUPDATE	KF_Flare,K_F

		KUPDATE	KF_AutoCancel,K_ESC
		KUPDATE	KF_Approach,K_F6
		KUPDATE	KF_Track,K_F7
		KUPDATE	KF_Hold,K_F8
		KUPDATE	KF_TFollow,K_F9
		KUPDATE	KF_Throttle,K_F10
		KUPDATE	KF_AutoTrim,K_CENTRE

		KUPDATE	KF_SkipWaypoint,K_N
		KUPDATE	KF_SelectTgtWP,K_T
		KUPDATE	KF_CancelTgtWP,K_CTRL,_AND_,K_T

		KUPDATE	KF_JetExtTanks,K_ALT,_AND_,K_J
		KUPDATE	KF_JetExtStores,K_CTRL,_AND_,K_J
		KUPDATE	KF_JetAll,K_SHIFT,_AND_,K_J

		KUPDATE	KF_Eject,K_CTRL,_AND_,K_E
		KUPDATE	KF_CancelAttn,K_PAD_STAR,_OR_,K_APOSTROPHE
		KUPDATE	KF_Recal,K_Y
		KUPDATE	KF_JoySensNorm,K_CTRL,_AND_,K_Y
		KUPDATE	KF_JoySensHigh,K_SHIFT,_AND_,K_Y

	ENDIF

;---------------------------
ScanDisabled	LABEL	NEAR	;scan when input disabled
;---------------------------

		KUPDATE	KF_Range,K_1
		KUPDATE	KF_GndText,K_2
		KUPDATE	KF_HillText,K_3
		KUPDATE	KF_Clouds,K_4
		KUPDATE	KF_Horizon,K_5
		KUPDATE	KF_Minimise,K_0

;---------------------------
ScanPaused	LABEL	NEAR	;scan when input disabled or paused
;---------------------------

		KUPDATE	KF_Quit,K_CTRL,_AND_,K_Q
		KUPDATE	KF_Pause,K_P

;-----------
;* wash roll
;-----------

;* wash roll if input disabled but not if paused
 
 		test	Paused,1	;paused?
		jnz	ExitIntr20	;yes ->

;* do not wash roll of auto-heading active

		test	AHFlag,1	;auto-heading active?
		jnz	ExitIntr20	;yes ->

;* do not wash roll if ailerons active or rolling

		mov	ax,AilPosn
		or	ax,RollRate	;ailerons active or rolling?
		jnz	ExitIntr20	;yes ->

		mov	ax,RFine	

		cmp	ax,RWASH_THRESH*128
		jbe	WashRoll1	;wash roll left to 360 degs ->

		cmp	ax,(256-RWASH_THRESH)*128
		jb	ExitIntr20	;ignore wash ->

		cmp	ax,256*128
		jbe	WashRoll2	;wash roll right to 180 degs ->

		cmp	ax,(256+RWASH_THRESH)*128
		jbe	WashRoll3	;wash roll left to 180 degs ->

		cmp	ax,(512-RWASH_THRESH)*128
		jb	ExitIntr20	;ignore wash ->

;* wash roll right to 360 degs

WashRoll4:	xor	dx,dx
		sub	dx,ax		;delta roll = (360 degs - roll)
		cmp	dx,RWASH_RATE	;delta roll <= wash rate?
		jbe	@F		;yes ->
		mov	dx,RWASH_RATE	;limit to wash rate
@@:		add	ax,dx
		jmp	WashRollOk

;* wash roll left to 180 degs

WashRoll3:	mov	dx,ax
		sub	dx,256*128	;delta roll = (roll - 180 degs)
		cmp	dx,RWASH_RATE	;delta roll <= wash rate?
		jbe	@F		;yes ->
		mov	dx,RWASH_RATE	;limit to wash rate
@@:		sub	ax,dx
		jmp	WashRollOk

;* wash roll right to 180 degs

WashRoll2:	mov	dx,256*128
		sub	dx,ax		;delta roll = (180 degs - roll)
		cmp	dx,RWASH_RATE	;delta roll <= wash rate?
		jbe	@F		;yes ->
		mov	dx,RWASH_RATE	;limit to wash rate
@@:		add	ax,dx
		jmp	WashRollOk

;* wash roll left to 360 degs

WashRoll1:	mov	dx,ax		;delta roll = roll
		cmp	dx,RWASH_RATE	;delta roll <= wash rate?
		jbe	@F		;yes ->
		mov	dx,RWASH_RATE	;limit to wash rate
@@:		sub	ax,dx

WashRollOk:	mov	RFine,ax

ExitIntr20:	ret

GameIntr20	ENDP

;----------------------------------------------------------------------------

;* GameIntr100 - 100Hz game interrupt
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all
;*
;* Manual controls:-
;*
;*    cursor down ....... pull			(ALT)
;*    cursor up ......... push			(ALT)
;*    cursor right ...... roll right		(ALT)
;*    cursor left ....... roll left		(ALT)
;*    key pad delete .... rudder right		(ALT)
;*    key pad insert .... rudder left		(ALT)
;*
;*    '+' ............... open throttle
;*    '-' ............... close throttle
;*    shift and '+' ..... slam throttle open
;*    shift and '-' ..... slam throttle shut
;*
;*    To engage reheat, increase throttle to maximum, release '+' key and
;*    press again.
;*
;*    To disengage reheat, decrease reheat to minimum, release '-' key and
;*    press again.
;*
;* Auto-pilot controls:-
;*
;*    cursor down ....... increase acquired altitude	(ALT)
;*                        or ride altitude
;*    cursor up ......... decrease acquired altitude	(ALT)
;*                        or ride altitude
;*    cursor right ...... increase acquired heading	(ALT)
;*    cursor left ....... decrease acquired heading	(ALT)
;*    '+' ............... increase acquired airspeed	(ALT)
;*    '-' ............... decrease acquired airspeed	(ALT)
;*
;* Notes:-
;*
;*    (ALT) indicates controls which can be de-sensitised when used with the
;*    ALT key.

GameIntr100	PROC	FAR

;-----------------------------------
;* check if input disabled or paused
;-----------------------------------

		test	Paused,1	;paused?
		_JNZ	GameIntr50	;yes ->

		cmp	DisableInput,0	;input disabled?
		je	@F		;no ->

		xor	ax,ax		;reset all controls
		mov	ElePosn,ax
		mov	AilPosn,ax
		mov	RudPosn,ax

		jmp	KbdStatus

;-----------------------
;* control device switch
;-----------------------

@@:		mov	bx,ControlDevice
		jmp	KbdCtrlSwitch[bx]

;===========================
KbdElevators	LABEL	NEAR
;===========================

		mov	bx,AltMode
		jmp	KbdEleSwitch[bx]

;---------------------------
KbdEleManual	LABEL	NEAR		;ALT_MANUAL
;---------------------------

		mov	bl,Key[K_CRSRDN]	;pull
		shl	bl,1
		or	bl,Key[K_CRSRUP]	;push

		jz	@F	  	;no input ->

		mov	AutoTrim,0  	;elevator demand, cancel auto-trim

@@:		mov	ax,ElePosn
		mov	dx,EleKbdRate
		mov	bp,EleKbdWash
		call	UpdatePosn
		mov	ElePosn,ax

		jmp	KbdAilerons

;---------------------------
KbdEleApproach	LABEL	NEAR		;ALT_APPROACH
;---------------------------

		mov	ElePosn,0

		jmp	KbdAilerons

;---------------------------
KbdEleAcquire	LABEL	NEAR		;ALT_ACQUIRE
;---------------------------

		mov	ElePosn,0

;* inc AutoAlt

		test	Key[K_CRSRDN],1	;inc key pressed?
		jz	SkipIncAlt     	;no ->

		test	OldCrsrDn,1	;key pressed last intr?
		jnz	@F		;yes ->

		mov	AutoAltDelay,KBD_AUTO_RPT

		mov	ax,256*10	;assume ALT key not pressed

		test	Key[K_ALT],1	;alt key pressed?
		jz	ContIncAlt

		mov	ax,256

		jmp	ContIncAlt

@@:		mov	ax,AutoAltDelay
		test	ax,ax		;end of auto-rpt delay?
		jz	@F		;yes ->
		dec	ax
		mov	AutoAltDelay,ax
		jmp	KbdAilerons

@@:		mov	ax,256*10
		mov	cl,Key[K_ALT]
		shl	cl,1		;0 or 2
		shl	cl,1		;0 or 4
		shr	ax,cl		;/1 or /16

ContIncAlt:	xor	dh,dh
		mov	dl,ah
		mov	ah,al
		xor	al,al

		add	ax,AutoAltFine
		adc	dx,AutoAlt

		cmp	dx,MAX_AUTO_ALT
		jb	@F
		mov	dx,MAX_AUTO_ALT
		xor	ax,ax
		
@@:		mov	AutoAlt,dx
		mov	AutoAltFine,ax

		jmp	KbdAilerons

;* dec AutoAlt

SkipIncAlt:	test	Key[K_CRSRUP],1	;dec key pressed?
		jz	SkipDecAlt    	;no ->

		test	OldCrsrUp,1	;key pressed last intr?
		jnz	@F		;yes ->

		mov	AutoAltDelay,KBD_AUTO_RPT

		mov	ax,256*10	;assume ALT key not pressed

		test	Key[K_ALT],1	;alt key pressed?
		jz	ContDecAlt

		mov	ax,256

		jmp	ContDecAlt

@@:		mov	ax,AutoAltDelay
		test	ax,ax		;end of auto-rpt delay?
		jz	@F		;yes ->
		dec	ax
		mov	AutoAltDelay,ax
		jmp	KbdAilerons

@@:		mov	ax,256*10
		mov	cl,Key[K_ALT]
		shl	cl,1		;0 or 2
		shl	cl,1		;0 or 4
		shr	ax,cl		;/1 or /16

ContDecAlt:	xor	dh,dh
		mov	dl,ah
		mov	ah,al
		xor	al,al

		sub	AutoAltFine,ax
		sbb	AutoAlt,dx

		jns	@F

		mov	AutoAlt,MIN_AUTO_ALT
		mov	AutoAltFine,0
		
		jmp	KbdAilerons

@@:		cmp	AutoAlt,MIN_AUTO_ALT
		jae	SkipDecAlt

		mov	AutoAlt,MIN_AUTO_ALT
		mov	AutoAltFine,0

SkipDecAlt:	jmp	KbdAilerons

;---------------------------
KbdEleTF	LABEL	NEAR		;ALT_TF
;---------------------------

		mov	ElePosn,0

;* increase ride altitude

		test	Key[K_CRSRDN],1	;increase ride alt?
		jz	SkipIncRide    	;no ->

		test	OldCrsrDn,1	;key pressed last intr?
		jnz	@F		;yes ->

		mov	TFRideDelay,KBD_AUTO_RPT

		jmp	ContIncRide

@@:		mov	ax,TFRideDelay
		test	ax,ax		;end of auto-rpt delay?
		jz	ContIncRide	;yes ->
		dec	ax
		mov	TFRideDelay,ax
		jmp	KbdAilerons

ContIncRide: 	cmp	TFRideIndex,MAX_TF_INDEX	;max limit?
		je	KbdAilerons			;yes ->

		add	TFRideIndex,2	;inc ride alt index

		mov	TFRideDelay,KBD_AUTO_RPT

		jmp	KbdAilerons

;* decrease ride altitude

SkipIncRide:	test	Key[K_CRSRUP],1	;increase ride alt?
		jz	KbdAilerons 	;no ->

		test	OldCrsrUp,1	;key pressed last intr?
		jnz	@F		;yes ->

		mov	TFRideDelay,KBD_AUTO_RPT

		jmp	ContDecRide

@@:		mov	ax,TFRideDelay
		test	ax,ax		;end of auto-rpt delay?
		jz	ContDecRide	;yes ->
		dec	ax
		mov	TFRideDelay,ax
		jmp	KbdAilerons

ContDecRide: 	cmp	TFRideIndex,0	;min limit?
		je	KbdAilerons  	;yes ->

		sub	TFRideIndex,2	;dec ride alt index

		mov	TFRideDelay,KBD_AUTO_RPT

;===========================
KbdAilerons	LABEL	NEAR
;===========================

		mov	bx,HdgMode
		jmp	KbdAilSwitch[bx]

;---------------------------
KbdAilManual	LABEL	NEAR		;HDG_MANUAL
;---------------------------

		mov	bl,Key[K_CRSRRT]	;roll right
		shl	bl,1
		or	bl,Key[K_CRSRLF]	;roll left

		mov	ax,AilPosn
		mov	dx,AilKbdRate
		mov	bp,AilKbdWash
		call	UpdatePosn
		mov	AilPosn,ax

		jmp	KbdRudder

;---------------------------
KbdAilApproach	LABEL	NEAR		;HDG_APPROACH
;---------------------------

		mov	AilPosn,0

		jmp	KbdRudder

;---------------------------
KbdAilAcquire	LABEL	NEAR		;HDG_ACQUIRE
;---------------------------

		mov	AilPosn,0

;* inc AutoHdg

		test	Key[K_CRSRRT],1	;inc key pressed?
		jz	SkipIncHdg     	;no ->

		test	OldCrsrRt,1	;key pressed last intr?
		jnz	@F		;yes ->

;* note: kbd auto rpt /2 to prevent "kicking" effects with auto hdg

		mov	AutoHdgDelay,KBD_AUTO_RPT/2

		mov	ax,256

		jmp	ContIncHdg

@@:		mov	ax,AutoHdgDelay
		test	ax,ax		;end of auto-rpt delay?
		jz	@F		;yes ->
		dec	ax
		mov	AutoHdgDelay,ax
		jmp	KbdRudder

@@:		mov	ax,256
		mov	cl,Key[K_ALT]
		shl	cl,1		;0 or 2
		shl	cl,1		;0 or 4
		shr	ax,cl		;/1 or /16

ContIncHdg:	xor	dh,dh
		mov	dl,ah
		mov	ah,al
		xor	al,al

		add	ax,AutoHdgFine
		adc	dx,AutoHdg

		cmp	dx,MAX_AUTO_HDG
		jbe	@F
		xor	dx,dx		;wrap around
		
@@:		mov	AutoHdg,dx
		mov	AutoHdgFine,ax

		jmp	KbdRudder

;* dec AutoHdg

SkipIncHdg:	test	Key[K_CRSRLF],1	;dec key pressed?
		jz	SkipDecHdg     	;no ->

		test	OldCrsrLf,1	;key pressed last intr?
		jnz	@F		;yes ->

;* note: kbd auto rpt /2 to prevent "kicking" effects with auto hdg

		mov	AutoHdgDelay,KBD_AUTO_RPT/2

		mov	ax,256

		jmp	ContDecHdg

@@:		mov	ax,AutoHdgDelay
		test	ax,ax		;end of auto-rpt delay?
		jz	@F		;yes ->
		dec	ax
		mov	AutoHdgDelay,ax
		jmp	KbdRudder

@@:		mov	ax,256
		mov	cl,Key[K_ALT]
		shl	cl,1		;0 or 2
		shl	cl,1		;0 or 4
		shr	ax,cl		;/1 or /16

ContDecHdg:	xor	dh,dh
		mov	dl,ah
		mov	ah,al
		xor	al,al

		sub	AutoHdgFine,ax
		sbb	AutoHdg,dx

		jns	KbdRudder

		mov	AutoHdg,MAX_AUTO_HDG	;wrap around
		
SkipDecHdg:	jmp	KbdRudder

;---------------------------
KbdAilTrack	LABEL	NEAR		;HDG_TRACK
;---------------------------

		mov	AilPosn,0

;===========================
KbdRudder	LABEL	NEAR
;===========================

;* no rudder input if auto-pilot selected

		cmp	AutoMode,AUTO_OFF	;manual?
		je	@F			;yes ->

		mov	RudPosn,0

		jmp	KbdThrottle

@@:		mov	bl,Key[K_PAD_DEL]	;right rudder
		shl	bl,1
		or	bl,Key[K_PAD_INS]	;left rudder

		mov	ax,RudPosn
		mov	dx,RudKbdRate
		mov	bp,RudKbdWash
		call	UpdatePosn
		mov	RudPosn,ax

;===========================
KbdThrottle	LABEL	NEAR
;===========================

		test	AutoThrot,1	;auto-throttle?
		_JNZ	KbdAutoThrot	;yes ->

;---------------
;* open throttle
;---------------

		test	Key[K_PLUS],1	;open throttle?
		jz	CloseThrottle	;no ->

		cmp	Reheat,0	;adjust reheat?
		jne	IncReheat	;yes ->

		cmp	Throttle,256 	;max throttle?
		je	ReheatOn	;yes, test for engage reheat ->

		test	Key[K_SHIFT],1	;slam open?
		jnz	SlamThrotOpen	;yes ->

		inc	Throttle

		jmp	KbdStatus

SlamThrotOpen:	mov	Throttle,256

		jmp	KbdStatus

IncReheat:   	test	Key[K_SHIFT],1	;slam open?
		jnz	SlamReheatOpen	;yes ->

		cmp	Reheat,128 	;max reheat?
		je	@F		;yes ->

		inc	Reheat

@@:		jmp	KbdStatus

SlamReheatOpen:	mov	Reheat,128

		jmp	KbdStatus

;* release '+' key and press again to engage reheat

ReheatOn:	test	OldPlus,1	;'+' key pressed last interrupt?
		jnz	@F		;yes ->

		mov	Reheat,1

@@:		jmp	KbdStatus

;----------------
;* close throttle
;----------------

CloseThrottle:	test	Key[K_MINUS],1	;close throttle?
		jz	@B		;no ->

		cmp	Reheat,0	;adjust reheat?
		jne	DecReheat	;yes ->

		cmp	Throttle,256 	;max throttle?
		je	ReheatOff	;yes, test for disengage reheat ->

		test	Key[K_SHIFT],1	;slam shut?
		jnz	SlamThrotShut	;yes ->

		cmp	Throttle,0	;min throttle?
		je	@F		;yes ->

		dec	Throttle

@@:		jmp	KbdStatus

SlamThrotShut:	mov	Throttle,0

		jmp	KbdStatus

DecReheat:   	test	Key[K_SHIFT],1	;slam shut?
		jnz	SlamReheatShut	;yes ->

		cmp	Reheat,0	;min reheat?
		je	@F		;yes ->

		dec	Reheat

@@:		jmp	KbdStatus

SlamReheatShut:	mov	Reheat,0

		jmp	KbdStatus

;* release '-' key and press again to disengage reheat

ReheatOff:	test	OldMinus,1	;'-' key pressed last interrupt?
		jnz	@F		;yes ->

		mov	Throttle,255

@@:		jmp	KbdStatus

;-------------------
;* increase AutoVias
;-------------------

;* do not adjust AutoVias if approach mode

KbdAutoThrot:	cmp	AutoMode,AUTO_APPROACH	;approach mode?
		_JE	KbdStatus		;yes ->

		test	Key[K_PLUS],1	;inc key pressed?
		jz	SkipIncVias	;no ->

		test	OldPlus,1	;key pressed last intr?
		jnz	@F		;yes ->

		mov	AutoThrotDelay,KBD_AUTO_RPT

		mov	ax,256

		jmp	ContIncVias

@@:		mov	ax,AutoThrotDelay
		test	ax,ax		;end of auto-rpt delay?
		jz	@F		;yes ->
		dec	ax
		mov	AutoThrotDelay,ax
		jmp	KbdStatus

@@:		mov	ax,256
		mov	cl,Key[K_ALT]
		shl	cl,1		;0 or 2
		shl	cl,1		;0 or 4
		shr	ax,cl		;/1 or /16

ContIncVias:	xor	dh,dh
		mov	dl,ah
		mov	ah,al
		xor	al,al

		add	ax,AutoViasFine
		adc	dx,AutoVias

		cmp	dx,MAX_AUTO_VIAS
		jb	@F
		mov	dx,MAX_AUTO_VIAS
		xor	ax,ax

@@:		mov	AutoVias,dx
		mov	AutoViasFine,ax

		jmp	KbdStatus

;-------------------
;* decrease AutoVias
;-------------------

SkipIncVias:	test	Key[K_MINUS],1	;dec key pressed?
		jz	KbdStatus	;no ->

		test	OldMinus,1	;key pressed last intr?
		jnz	@F		;yes ->

		mov	AutoThrotDelay,KBD_AUTO_RPT

		mov	ax,256

		jmp	ContDecVias

@@:		mov	ax,AutoThrotDelay
		test	ax,ax		;end of auto-rpt delay?
		jz	@F		;yes ->
		dec	ax
		mov	AutoThrotDelay,ax
		jmp	KbdStatus

@@:		mov	ax,256
		mov	cl,Key[K_ALT]
		shl	cl,1		;0 or 2
		shl	cl,1		;0 or 4
		shr	ax,cl		;/1 or /16

ContDecVias:	xor	dh,dh
		mov	dl,ah
		mov	ah,al
		xor	al,al

		sub	AutoViasFine,ax
		sbb	AutoVias,dx

		jns	KbdStatus

		mov	AutoVias,0
		mov	AutoViasFine,0

;===========================
KbdStatus	LABEL	NEAR
;===========================

		mov	al,Key[K_CRSRUP]
		mov	OldCrsrUp,al

		mov	al,Key[K_CRSRDN]
		mov	OldCrsrDn,al

		mov	al,Key[K_CRSRLF]
		mov	OldCrsrLf,al

		mov	al,Key[K_CRSRRT]
		mov	OldCrsrRt,al

		mov	al,Key[K_PLUS]
		mov	OldPlus,al

		mov	al,Key[K_MINUS]
		mov	OldMinus,al

;----------------------
;* update screen shaker
;----------------------

		mov	ax,ShakeTimer
		test	ax,ax		;shaking?
		jz	GameIntr50	;no ->

		dec	ax		;update timer

		jnz	@F		;continue ->

		mov	ShakePriority,0	;clear priority

@@:		mov	ShakeTimer,ax

		test	InCockpit,1	;in cockpit?
		jz	GameIntr50	;no ->

		call	ScreenShaker

;===========================
GameIntr50	LABEL	NEAR
;===========================

		xor	Timer50,1	;toggle 50Hz
		jz	@F		;skip ->

		call	RefreshSound
		call	RefreshMusic

@@:		ret

GameIntr100	ENDP

;----------------------------------------------------------------------------

;* UpdatePosn - update control position
;*
;* pass: ax = position
;*       bl = key codes (b0 = dec key, b1 = inc key)
;*       dx = rate
;*       bp = washout threshold
;* ret : ax = new position
;* kill: bx, cx, dx, flags
;*
;* note: ONLY call from GameIntr100.

UpdatePosn	PROC	NEAR

		mov	cl,Key[K_ALT]	;fine control if alt key pressed
		shl	cl,1		;0 or 2
		shl	cl,1		;0 or 4

		cmp	bl,10b		;inc key pressed only?
		je	IncPosn		;yes ->
		cmp	bl,01b		;dec key pressed only?
		je	DecPosn		;yes ->

;* washout position
		
		mov	bx,dx
		ABSV	ax		;ax = abs(posn), dx = sign(posn)
		cmp	ax,bp		;within washout limits?
		ja	@F		;no ->
		shl	bx,1		;washout rate = 2 * input rate
		sub	ax,bx		;washout
		jnc	@F		;ok ->
		xor	ax,ax		;washout to 0
@@:		xor	ax,dx		;restore sign
		sub	ax,dx
		ret

;* increment position

IncPosn:	shr	dx,cl		;rate / 1 or rate / 16
		add	ax,dx		;posn = posn + rate
		jno	@F		;ok ->
		mov	ax,+32767	;limit
@@:		ret

;* decrement position

DecPosn:	shr	dx,cl		;rate / 1 or rate / 16
		sub	ax,dx		;posn = posn - rate
		jno	@F		;ok ->
		mov	ax,-32768	;limit
@@:		ret

UpdatePosn	ENDP

;----------------------------------------------------------------------------

;* CalcSFValue - look up / interpolate value from sweep / flaps table
;*
;* pass: si -> table[]
;*       SweepActive
;*       CrntWingPos
;*       CrntWingVal
;*       FlapsActive
;*       CrntFlapPos
;*       CrntFlapVal
;* ret : ax = value
;* kill: assume all (except ax)
;*
;* note: Table format:-
;*
;*       index = wing sweep pos * 8 + flap pos * 2
;*
;*	             zero, mnvr,  mid, full (flaps)
;*
;*		DW	x,    x,    x,    x	;25 degrees sweep
;*		DW	x,    x,    x,   -1	;45 degrees sweep
;*		DW	x,   -1,   -1,   -1	;67 degrees sweep
;*
;*       (-1 = value not valid)

CalcSFValue	PROC	NEAR

;* if sweep active then
;*    interpolate value wrt sweep
;* else
;*    if flaps active then
;*       interpolate value wrt flaps
;*    else
;*       look up value
;*    end
;* end

;----------------------
;* test if sweep active
;----------------------

		mov	al,SweepActive
		test	al,al		;sweep active?
		jz	SweepInActive	;no ->

;--------------
;* sweep active
;--------------

;* column = CrntFlapPos * 2
;*
;* if CrntWingVal < SWEEP_A_45 then
;*    val1 = table[SWEEP_D_25*8][column]
;*    val2 = table[SWEEP_D_45*8][column]
;*    val3 = CrntWingVal
;*    val4 = SWEEP_A_45
;* else
;*    val1 = table[SWEEP_D_45*8][column]
;*    val2 = table[SWEEP_D_67*8][column]
;*    val3 = CrntWingVal - SWEEP_A_45
;*    val4 = SWEEP_A_67 - SWEEP_A_45
;* end
;*
;* value = val1 + ((val2 - val1) * val3 / val4)

		mov	bl,CrntFlapPos
		xor	bh,bh
		shl	bx,1		;column = flap pos * 2

		mov	di,CrntWingVal	;val3
		mov	bp,SWEEP_A_45	;val4

		cmp	di,bp		;<= 45 deg sweep?
		jbe	@F		;yes ->

		add	bx,8	  	;next row

		sub	di,bp				;val3
		mov	bp,SWEEP_A_67-SWEEP_A_45	;val4
	
@@:		mov	cx,[si+bx]	;val1
		add	bx,8	  	;next row
		mov	ax,[si+bx]	;val2
		sub	ax,cx		;val2 - val1
		imul	di	      	;(val2 - val1) * val3
		idiv	bp	      	;(val2 - val1) * val3 / val4
		add	ax,cx	      	;val1 + ((val2 - val1) * val3 / val4)
	
		jmp	CalcSFExit

;----------------------
;* test if flaps active
;----------------------

SweepInActive:	mov	al,FlapsActive
		test	al,al		;flaps active?
		jz	FlapsInActive	;no ->

;--------------
;* flaps active
;--------------

;* row = CrntWingPos * 8
;*
;* if CrntFlapVal < FLAPS_A_MNVR then
;*    val1 = table[row][FLAPS_A_ZERO*2]
;*    val2 = table[row][FLAPS_A_MNVR*2]
;*    val3 = CrntFlapVal
;*    val4 = FLAPS_A_MNVR
;* else
;*    if CrntFlapVal < FLAPS_A_MID then
;*       val1 = table[row][FLAPS_A_MNVR*2]
;*       val2 = table[row][FLAPS_A_MID*2]
;*       val3 = CrntFlapVal - FLAPS_A_MNVR
;*       val4 = FLAPS_A_MID - FLAPS_A_MNVR
;*    else
;*       val1 = table[row][FLAPS_A_MID*2]
;*       val2 = table[row][FLAPS_A_FULL*2]
;*       val3 = CrntFlapVal - FLAPS_A_MID
;*       val4 = FLAPS_A_FULL - FLAPS_A_MID
;*    end
;* end
;*
;* val = val1 + ((val2 - val1) * val3 / val4)

		mov	bl,CrntWingPos
		xor	bh,bh
		shl	bx,1		;*2
		shl	bx,1		;*4
		shl	bx,1		;row = wing pos * 8

		mov	di,CrntFlapVal	;val3
		mov	bp,FLAPS_A_MNVR	;val4

		cmp	di,bp		;<= manoeuvre flaps?
		jbe	@F		;yes ->

		add	bx,2	  	;next colomn

		sub	di,bp				;val3
		mov	bp,FLAPS_A_MID-FLAPS_A_MNVR	;val4

		cmp	di,bp		;<= mid flaps?
		jbe	@F		;yes ->
		
		add	bx,2	  	;next colomn

		sub	di,bp				;val3
		mov	bp,FLAPS_A_FULL-FLAPS_A_MID	;val4
		
@@:	  	mov	cx,[si+bx]	;val1
		add	bx,2	  	;next column
		mov	ax,[si+bx]	;val2
		sub	ax,cx		;val2 - val1
		imul	di	      	;(val2 - val1) * val3
		idiv	bp	      	;(val2 - val1) * val3 / val4
		add	ax,cx	      	;val1 + ((val2 - val1) * val3 / val4)

		jmp	CalcSFExit

;--------------------------
;* sweep and flaps inactive
;--------------------------

FlapsInActive:	mov	bl,CrntWingPos
		xor	bh,bh
		shl	bx,1		;*2
		shl	bx,1		;*4
		shl	bx,1		;wing sweep pos * 8
		mov	al,CrntFlapPos
		xor	ah,ah
		shl	ax,1		;flap pos * 2
		add	bx,ax		;wing sweep pos * 8 + flap pos * 2
		
		mov	ax,[si+bx]

CalcSFExit:	ret

CalcSFValue	ENDP

;----------------------------------------------------------------------------

;* CalcEngTemp - calc engine temperature wrt thrust (damped, frame rate dependant)
;*
;* pass: al = engine damage status
;*       ah = engine fire status
;*       dx = thrust
;*       bp = old temperature
;* ret : ax = new temperature
;* kill: assume all

CalcEngTemp	PROC	NEAR

;* if engine fire then
;*    aim for MAX_ENG_TEMP
;* else
;*    if engine damaged or out of fuel then
;*       aim for MIN_ENG_TEMP
;*    endif
;* endif

		test	ah,ah		;fire?
		jz	@F		;no ->

		mov	dx,MAX_ENG_TEMP

		jmp	SortTemp

@@:		test	al,al		;damaged?
		jnz	@F		;yes ->

		cmp	FuelWt,0	;out of fuel?
		ja	ContTemp	;no ->

@@:		mov	dx,MIN_ENG_TEMP

		jmp	SortTemp

;* @ idle: thrust =     0lbf, eng temp = 400 * 16 deg c
;* @ max : thrust = 17000lbf, eng temp = 700 * 16 deg c

;* new temp = thrust * (9252 / 32768) + 400 * 16

ContTemp: 	mov	ax,9252
		imul	dx
		FRACADJ	dx
		add	dx,400*16	;new temp = thrust * (9252 / 32768) + 400 * 16

SortTemp:	sub	dx,bp		;delta temp = new temp - old temp

		mov	bx,dx		;bx = delta temp

		js	DecTemp		;decrease temp ->

IncTemp:	mov	ax,MAX_TEMP_INC
		mov	dx,DeltaTime
		imul	dx
		FRACADJ	dx		;dx = max temp change this frame

		cmp	bx,dx		;delta temp ok?
		jle	TempOk		;yes ->
		mov	bx,dx		;limit temp change
		jmp	TempOk

DecTemp:	mov	ax,MAX_TEMP_DEC
		mov	dx,DeltaTime
		imul	dx
		FRACADJ	dx		;dx = max temp change this frame

		cmp	bx,dx		;delta temp ok?
		jge	TempOk		;yes ->
		mov	bx,dx		;limit temp change

;* new temp = old temp + delta temp

TempOk:		mov	ax,bp
		add	ax,bx

		ret

CalcEngTemp	ENDP

;----------------------------------------------------------------------------

;* DampRate - damp rate change
;*
;* pass: ax = old rate
;*       cx = damp factor
;*       dx = new rate
;* ret : dx = damped new rate
;* kill: assume all (except dx)
;*
;* note: This algorithm is frame rate dependant.

DampRate	PROC	NEAR

		mov	bp,ax		;store old rate

		mov	ax,dx

		cwd

		mov	bx,ax		;si, bx = new rate
		mov	si,dx

		mov	ax,bp

		cwd			;dx, ax = old rate

;* damped new rate = (new rate - old rate) / damp factor + old rate

		sub	bx,ax
		sbb	si,dx

		js	NegChange	;neg change ->

;* pos change

@@:		shr	si,1		;(new rate - old rate) / damp factor
		rcr	bx,1
		loop	@B

		jmp	DampOk

;* neg change (negate and scale to prevent -1 truncation error)

NegChange: 	NEG32	si,bx

@@:		shr	si,1		;(new rate - old rate) / damp factor
		rcr	bx,1
		loop	@B

		neg	bx		;restore sign

DampOk:		add	bx,bp		;(new rate - old rate) / damp factor + old rate

		mov	dx,bx

		ret

DampRate	ENDP

;----------------------------------------------------------------------------

;* DestroyTornado - start Tornado destruction sequence
;*
;* pass: al = die flag
;*       ah = destruction level
;* ret : nothing
;* kill: assume all

DestroyTornado	PROC	FAR

		test	TwoPlayer,1	;two player mode?
		jnz	SortTwoPlayer	;yes ->

		cmp	Destroyed,0	;already destroyed?
		jne	ExitDestroy	;yes ->

		mov	Destroyed,ah

		cmp	TmpDieFlag,0	;die flag locked?
		jne	@F		;yes ->

		mov	TmpDieFlag,al

@@:		or	DisableInput,DIP_DESTROYED

		test	Ejected,1	;ejected?
		jnz	ExitDestroy	;yes ->

		mov	ax,VIEW_DESTROYED
		call	SetGameViewMode

ExitDestroy:	ret

;---------------------------
SortTwoPlayer	LABEL	NEAR
;---------------------------

		cmp	Destroyed,0	;already destroyed?
		jne	ExitDestroy	;yes ->

		mov	Destroyed,ah

		cmp	DieFlag,0	;die flag locked?
		jne	@F		;yes ->

		mov	DieFlag,al

@@:		or	DisableInput,DIP_DESTROYED

		jmp	ExitDestroy

DestroyTornado	ENDP

;----------------------------------------------------------------------------

;* StartEjectSeq - start eject sequence
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

StartEjectSeq	PROC	NEAR

		mov	Ejected,1

		or	DisableInput,DIP_EJECT

		mov	DieFlag,DIE_EJECT

		ret

StartEjectSeq	ENDP

;----------------------------------------------------------------------------

;* InitNewSector - init misc items when entering a new sector
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

InitNewSector	PROC	NEAR

;----------------
;* make map index (if on active map)
;----------------

		mov	ax,-1		;assume off active map

		cmp	XSec,31
		ja	@F
		cmp	YSec,31
		ja	@F

;* map index = ysec * 32 + xsec

		mov	ax,YSec

		REPT	5
		shl	ax,1
		ENDM

		add	ax,XSec

@@:		mov	ModelMapIndex,ax

		ret

InitNewSector	ENDP

MODCODE		ENDS

;============================================================================

		END

