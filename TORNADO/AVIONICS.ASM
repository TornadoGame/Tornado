;****************************************************************************
;*
;* AVIONICS.ASM
;*
;* Avionics systems / auto-pilot.
;*
;* 16.10.1991 - KJB
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<	
PUBLIC AllowSplitScreenBigMap		
PUBLIC SplitScreenBigMapIsOn
PUBLIC CurrentViewIsCheckSix		
PUBLIC ShiftDwasPressed		
PUBLIC MFD_Counter
PUBLIC CounterThird		
PUBLIC SAM_Launched_While_In_Cockpit   ;added by Frankie Kam on 3rd June 2018
PUBLIC AAA_or_SAM_value
;PUBLIC InitialToggleZRK_ZSU
PUBLIC EScopeToggle
PUBLIC ToggleZRK_ZSU
PUBLIC ToggleFullScreen
PUBLIC ZRKrombCamDist 
PUBLIC YawValue
PUBLIC YawValue2
PUBLIC YawValue3
PUBLIC YawValue_ZRK_AAA
PUBLIC PlayTheme
PUBLIC InWeaponView
PUBLIC HorizonValue
PUBLIC HorizonValue2
PUBLIC HorizonValue_ZRK_AAA
PUBLIC HorizonValue3
PUBLIC HorizonValue4
PUBLIC HorizonValue5
PUBLIC HorizonValue6
PUBLIC CurrentViewIsCheckSix
PUBLIC CheckSixValue
PUBLIC HorizonBombValue

PUBLIC CockpitViews
        PUBLIC	UpdateAvionics
		PUBLIC	AdvanceWP
		PUBLIC	SelectTgtWP
		PUBLIC	CancelTgtWP
		PUBLIC	UpdateTgtWP

		PUBLIC	TrueRadAlt
		PUBLIC	DispRadAlt
		PUBLIC	GndHtDist
		PUBLIC	GndHtData
		PUBLIC	Vfac
		PUBLIC	TFRideIndex
		PUBLIC	TFRideAlt
		PUBLIC	TFSlope
		PUBLIC	TFPitchRate
		PUBLIC	TFDeltaPRate
		PUBLIC	TFGForce
		PUBLIC	TFTrackPoint
		PUBLIC	TFTgtAlt
		PUBLIC	TFAltError
		PUBLIC	TFDistError
		PUBLIC	AutoVias
		PUBLIC	AutoViasFine
		PUBLIC	AutoVtas
		PUBLIC	ATThrust
		PUBLIC	AimThrottle
		PUBLIC	AimReheat
		PUBLIC	AutoHdg
		PUBLIC	AutoHdgFine
		PUBLIC	AHRollRate
		PUBLIC	AHDeltaRRate
		PUBLIC	AutoRFine
		PUBLIC	AimHFine
		PUBLIC	ErrHFine
		PUBLIC	AHMaxRate
		PUBLIC	AHRollVal
		PUBLIC	AutoAlt
		PUBLIC	AutoAltFine
		PUBLIC	AAPitchRate
		PUBLIC	AADeltaPRate
		PUBLIC	AAGForce
		PUBLIC	AimPFine
		PUBLIC	AAAltError
		PUBLIC	AADistError
		PUBLIC	ThetaAB
		PUBLIC	ThetaBC
		PUBLIC	ThetaABC
		PUBLIC	RTurn
		PUBLIC	TDist
		PUBLIC	InhibitDelay
		PUBLIC	ILSRangeLo
		PUBLIC	ILSRangeHi
		PUBLIC	ILSErrorLo
		PUBLIC	ILSErrorHi
		PUBLIC	ILSMaxError
		PUBLIC	ILSLocalError
		PUBLIC	ILSLocalPos
		PUBLIC	ILSGlideError
		PUBLIC	ILSGlidePos
		PUBLIC	ILSAirfieldPtr
		PUBLIC	ILSRng
		PUBLIC	ILSBrg
		PUBLIC	ILSETA
		PUBLIC	AppHFine
		PUBLIC	AppProgTimer
		PUBLIC	AirRadarTracks
		PUBLIC	NumRadarTracks
		PUBLIC	AirRadarRng
		PUBLIC	DispAirTgtRng
		PUBLIC	DispAirTgtAlt
		PUBLIC	DispAirTgtVel
		PUBLIC	DispAirTgtHdg
		PUBLIC	RWRThreats
		PUBLIC	NumRWRThreats
		PUBLIC	ActiveSAMCntr

		PUBLIC	SSF_Gear
		PUBLIC	SSF_WheelBrakes
		PUBLIC	SSF_AirBrakes
		PUBLIC	SSF_Engine1
		PUBLIC	SSF_Engine2
		PUBLIC	SSF_Sweep
		PUBLIC	SSF_Flaps
		PUBLIC	SSF_ThrustRvrs
		PUBLIC	SSF_SPILS
		PUBLIC	SSF_HUD
		PUBLIC	SSF_PilotMFD
		PUBLIC	SSF_NavigMFD
		PUBLIC	SSF_TAB1
		PUBLIC	SSF_TAB2
		PUBLIC	SSF_CommsRx
		PUBLIC	SSF_Oxygen
		PUBLIC	SSF_Radar
		PUBLIC	SSF_ECM
		PUBLIC	SSF_RWR
		PUBLIC	SSF_ADC
		PUBLIC	TFAuto
		PUBLIC	TFError
		PUBLIC	TFBRisk
		PUBLIC	TFPullUp
		PUBLIC	AutoThrot
		PUBLIC	ATError
		PUBLIC	AHFlag
		PUBLIC	AHError
		PUBLIC	AAFlag
		PUBLIC	AAError
		PUBLIC	TrackLocked
		PUBLIC	ILSActive
		PUBLIC	ILSApproach
		PUBLIC	AppFlag
		PUBLIC	AppError
		PUBLIC	AppProgFlag
		PUBLIC	AppProgSeq
		PUBLIC	RWRThreatFlags

		PUBLIC	MAX_TF_INDEX
		PUBLIC	MAX_AUTO_VIAS
		PUBLIC	MAX_AUTO_HDG
		PUBLIC	MIN_AUTO_ALT
		PUBLIC	MAX_AUTO_ALT
EXTRN SAM_VIEW:WORD
		EXTRN	CalcGndHeight:FAR
		EXTRN	QCalcGndHeight:FAR
		EXTRN	CalcDeltaXY:FAR
		EXTRN	Tangent:FAR
		EXTRN	ArcTan:FAR
		EXTRN	ArcTan2:FAR
		EXTRN	CalcRngBrgVP_VP:FAR
		EXTRN	CalcRngBrgVP_WP:FAR
		EXTRN	CalcRngBrgWP_WP:FAR
		EXTRN	CalcRngBrgVP_AF:FAR
		EXTRN	CalcAngDiff:FAR
		EXTRN	CalcNMiles:FAR
		EXTRN	CalcETA:FAR
		EXTRN	SelectRadarMFD:FAR
		EXTRN	SelectAutoMFD:FAR
		EXTRN	ValidateTIALD:FAR
		EXTRN	MoveViewpoint:FAR
		EXTRN	LocateMobiles:FAR
		EXTRN	CalcGndHeight:FAR
		EXTRN	FastArcTan:FAR
		EXTRN	SetViewMode:FAR
		EXTRN	CalcTransMatrix:FAR
		EXTRN	CalcEyeCoords:FAR
		EXTRN	CalcTgtRelCo:FAR
		EXTRN	XCalcUnclipCRT:FAR
		EXTRN	MorseDotSound:FAR
		EXTRN	MorseDashSound:FAR
		EXTRN	CalcSlantRange:FAR
		EXTRN	CalcVias:FAR
		EXTRN	CalcVkts:FAR
		EXTRN	RWRAlertSound:FAR
		EXTRN	GetDroneIllum:FAR
		EXTRN	GetDroneAlive:FAR
		EXTRN	GetDroneSpeed:FAR

		EXTRN	CheckFailures:NEAR

		EXTRN	WPRng:DWORD
		EXTRN	FrameElapTime:DWORD
		EXTRN	FlatDx:DWORD
		EXTRN	FlatDy:DWORD
		EXTRN	AirTgtRange:DWORD

		EXTRN	AutoMode:WORD
		EXTRN	AltMode:WORD
		EXTRN	HdgMode:WORD
		EXTRN	M_VIEW:WORD
		EXTRN	TMP_VIEW:WORD
		EXTRN	XSec:WORD
		EXTRN	YSec:WORD
		EXTRN	Xft:WORD
		EXTRN	Yft:WORD
		EXTRN	ZftHi:WORD
		EXTRN	ZftLo:WORD
		EXTRN	HFine:WORD
		EXTRN	PFine:WORD
		EXTRN	RFine:WORD
		EXTRN	M_CosP:WORD
		EXTRN	M_CosR:WORD
		EXTRN	M_SinP:WORD
		EXTRN	Vtas:WORD
		EXTRN	Vias:WORD
		EXTRN	Vkts:WORD
		EXTRN	Vtrim:WORD
		EXTRN	GCoord:WORD
		EXTRN	DeltaTime:WORD
		EXTRN	Accel:WORD
		EXTRN	Weight2:WORD
		EXTRN	DragHi:WORD
		EXTRN	DragLo:WORD
		EXTRN	FuelWt:WORD
		EXTRN	ThrustTable:WORD
		EXTRN	Throttle:WORD
		EXTRN	Reheat:WORD
		EXTRN	LastFrame:WORD
		EXTRN	SqrtRho:WORD
		EXTRN	WPPtr:WORD
		EXTRN	EndWPPtr:WORD
		EXTRN	WPBrg:WORD
		EXTRN	WPBrgFine:WORD
		EXTRN	WPRngNMiles:WORD
		EXTRN	WPETA:WORD
		EXTRN	WPTimeEarlyLate:WORD
		EXTRN	WayTotal:WORD
		EXTRN	WayList:WORD
		EXTRN	Hdg:WORD
		EXTRN	AirfieldList:WORD
		EXTRN	Weight:WORD
		EXTRN	RadarMode:WORD
		EXTRN	TornadoType:WORD
		EXTRN	FloatWP:WORD
		EXTRN	RedWarnings2:WORD
		EXTRN	SinTable:WORD
		EXTRN	CosTable:WORD
		EXTRN	AirTgtPtr:WORD
		EXTRN	ViewMode:WORD
		EXTRN	ClipWndwXOrg:WORD
		EXTRN	EWRTable:WORD
		EXTRN	ModelMapIndex:WORD
		EXTRN	RadarLists:WORD
		EXTRN	WeaponList:WORD
		EXTRN	EAircraft7:WORD
		EXTRN	EAircraft8:WORD
		EXTRN	EAircraft9:WORD
		EXTRN	EAircraft10:WORD
		EXTRN	EAircraft11:WORD
		EXTRN	EAircraft12:WORD
		EXTRN	XWindVeff:WORD

		EXTRN	Airborne1:BYTE
		EXTRN	StallFlag1:BYTE
		EXTRN	SpinFlag:BYTE
		EXTRN	AutoTrim:BYTE
		EXTRN	KF_AutoCancel:BYTE
		EXTRN	KF_Approach:BYTE
		EXTRN	KF_Track:BYTE
		EXTRN	KF_Hold:BYTE
		EXTRN	KF_TFollow:BYTE
		EXTRN	KF_Throttle:BYTE
		EXTRN	KF_AutoTrim:BYTE
		EXTRN	CrntWingPos:BYTE
		EXTRN	CrntFlapPos:BYTE
		EXTRN	Clock24:BYTE
		EXTRN	KF_GndRadar:BYTE
		EXTRN	KF_AirRadar:BYTE
		EXTRN	KF_RadarOff:BYTE
		EXTRN	KF_BoreSight:BYTE
		EXTRN	KF_CycleAirTgt:BYTE
		EXTRN	KF_CancelAirTgt:BYTE
		EXTRN	ClipWndwYOrg:BYTE
		EXTRN	AutoTrack:BYTE
		
		EXTRN	KF_SkipWaypoint:BYTE
		EXTRN	KF_SelectTgtWP:BYTE
		EXTRN	KF_CancelTgtWP:BYTE
		EXTRN	SectorDataStart:BYTE
		EXTRN	MSctrDataStart:BYTE
		EXTRN	SctrGameLayer1:BYTE
		EXTRN	EWRFloorLayer1:BYTE
		EXTRN	MobRadarLayer1:BYTE
		EXTRN	ArmLock:BYTE

		EXTRN	SWEEP_D_25:ABS

;============================================================================

		INCLUDE	MAINDATA.INC
		INCLUDE	MISCMAC.INC

		INCLUDE	\VISUAL\VISEXTRN.INC
		INCLUDE	\VISUAL\VISDATA.INC
		INCLUDE	\VISUAL\VISMACRO.INC
		INCLUDE	\VISUAL\RWY_TAXI.INC

		INCLUDE	\LIB8086\KEYS.INC
		INCLUDE	\LIB8086\TRIG.INC
		INCLUDE	\LIB8086\USEFUL.INC

;============================================================================

		EXTRN	M_MOBILE:MOBILE
		EXTRN	OPP_MOBILE:MOBILE

		EXTRN	RadarTable:RADARS

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

;----------------------
;* systems status flags (0 = ok, 1 = damaged)
;----------------------

SysStatusFlags	LABEL	BYTE
AllowSplitScreenBigMap DB 0
SplitScreenBigMapIsOn DB 0
CurrentViewIsCheckSix DB 0
SAM_Launched_While_In_Cockpit DB 0 ;SAM Launched against player's Tornado? 0 = no; 1 = yes;
                                   ;Added by Frankie Kam on 3rd June 2018
SSF_Gear	DB	0		;undercarriage
SSF_WheelBrakes	DB	0		;wheelbrakes
SSF_AirBrakes	DB	0		;airbrakes
SSF_Engine1	DB	0		;engine 1 (lh engine)
SSF_Engine2	DB	0		;engine 2 (rh engine)
SSF_Sweep	DB	0		;wing sweep
SSF_Flaps	DB	0		;flaps
SSF_ThrustRvrs	DB	0		;thrust reversers
SSF_SPILS	DB	0		;Spin Prevention Incidence Limiting System
SSF_HUD		DB	0		;HUD
SSF_PilotMFD	DB	0		;pilot's MFD
SSF_NavigMFD	DB	0		;navigator's MFD
SSF_TAB1	DB	0		;lhs TAB display
SSF_TAB2	DB	0		;rhs TAB display
SSF_CommsRx	DB	0		;comms reciever
SSF_Oxygen	DB	0		;oxygen system
SSF_Radar	DB	0		;ground / air radar
SSF_ECM		DB	0		;ECM damaged
SSF_RWR		DB	0		;RWR damaged
SSF_ADC		DB	0		;ADC damaged
		EVEN

;-----------------
;* velocity factor
;-----------------

Vfac		DW	0		;velocity factor wrt Vtas

CounterThird DW 0       ;Counter to go back to Navigation Panel on the third Shift+D
MFD_Counter       DW 0
ShiftDwasPressed DB 0
;----------------
;* radar altitude
;----------------

RAD_ALT_CEILING	EQU	10000		;(keep < 32767 for terrain following)

TrueRadAlt	DW	0		;0 .. RAD_ALT_CEILING
DispRadAlt	DW	0		;damped value for display purposes only
ZRKrombCamDist DW  80
YawValue DW 0
YawValue2 DW 0
YawValue3 DW 0
YawValue_ZRK_AAA DW 0
HorizonValue DW 22;-10
HorizonValue2 DW 10;-10
HorizonValue_ZRK_AAA DW 18;40 ;-10
HorizonValue3 DW 10
HorizonValue4 DW -120
HorizonValue5 DW -10
HorizonValue6 DW 30
CheckSixValue DW -130
HorizonBombValue DW -40
InWeaponView DB 0
CockpitViews DB 1
;--------------------
;* ground height data
;--------------------

NUM_HT_SAMPLES	EQU	32		;do not change (affects E-Scope)

GndHtData	DW	NUM_HT_SAMPLES DUP(0)

GndHtDist	DW	0		;sample distance

;* sample distance table (wrt Vfac) (exponential range law)

RangeLaw	LABEL	WORD

		DW	21		;0
		DW	25		;1
		DW	31		;2
		DW	37		;3
		DW	44		;4
		DW	52		;5
		DW	62		;6
		DW	72		;7
		DW	85		;8
		DW	99		;9
		DW	117		;10
		DW	138		;11
		DW	165		;12
		DW	199		;13
		DW	245		;14
		DW	309		;15
		DW	401		;16

;-------------------
;* terrain following
;-------------------

TF_B_RISK_SPEED	EQU	8160		;600kts (600 * 1.7 * 8)

TF_B_RISK_SLOPE	EQU	1274		;7 degs

TF_B_RISK_ALT	EQU	160		;'B' risk altitude

TF_PULL_UP_ALT	EQU	100		;emergency pull up altitude

TF_CEILING	EQU	7500		;max operating ceiling (always <= RAD_ALT_CEILING)

TF_MAX_PITCH_UP	EQU	5461		;30 degs

TF_MAX_PITCH_DN	EQU	2731		;15 degs

;* ride altitudes

MAX_TF_INDEX	EQU	20

TFRideIndex	DW	0		;0 .. MAX_TF_INDEX step 2

TFRideTable	DW	90    ;0 hack
		    DW	100   ;2 hack
		    DW	150   ;4 hack
		    DW  200   ;6 hack
		    DW  300   ;8 hack
		    DW	400   ;10 hack
		    DW	500   ;12 hack
		    DW	600   ;14 hack
		    DW	700   ;16 hack
		    DW	800   ;18 hack
		    DW	1000  ;20 hack

TFRideAlt	DW	100		;100 .. 1000ft

;* TF system flags

TFAuto		DB	0		;1 = auto-terrain following engaged
TFLast		DB	0		;previous TFAuto value
TFError		DB	0		;1 = terrain following error
TFBRisk		DB	0		;1 = 'B' risk warning
TFPullUp	DB	0		;1 = emergency pull up

		EVEN

UPSLOPE		EQU	+1
LEVEL		EQU	0
DOWNSLOPE	EQU	-1

LEVEL_DIST 	EQU	(NUM_HT_SAMPLES/2)*2

END_DIST	EQU	(NUM_HT_SAMPLES-1)*2

Count1		DB	0		;current step count
Count2		DB	0
Count3		DB	0
LookAhead	DB	0		;1 = look ahead

		EVEN

;* TF output values

TFSlope		DW	0		;slope

TFPitchRate	DW	0		;pitch rate demand (fine pdegs / sec)

TFDeltaPRate	DW	0		;pitch rate demand (fine pdegs / frame)

TFGForce	DW	0		;g force (*16 scaling)

;* debugging vars

TFTrackPoint	DW	0		;index track point

TFTgtAlt	DW	0		;target altitude

TFAltError	DW	0		;altitude error

TFDistError	DW	0		;distance error

;---------------
;* auto-throttle
;---------------

MAX_THRUST	EQU	34000
MAX_DRY		EQU	18000

MAX_AUTO_VIAS	EQU	800

AutoVias	DW	0		;0 .. MAX_AUTO_VIAS
AutoViasFine	DW	0

AutoVtas	DW	0

ATThrust	DW	0

AimThrottle	DW	0

AimReheat	DW	0

AutoThrot 	DB	0		;1 = auto-throttle engaged
ATError		DB	0		;1 = auto_throttle error

PlayTheme   DB  0         
EScopeToggle DB 0
ToggleZRK_ZSU DB 0      ;Toggle between the ZRK-Romba nd ZSU-23-4 in Tracking-like view (see VIEWS.ASM)
;InitialToggleZRK_ZSU DW -1
ToggleFullScreen DB 0
AAA_or_SAM_value VIEWPOINT <0,0,0,0,8>
		EVEN

;--------------
;* auto-heading
;--------------

MAX_AUTO_HDG	EQU	359

AH_MAX_ROLL	EQU	85*128		;60 degs

AH_ROLL_RATE	EQU	64*128		;45 degs / sec

AutoHdg		DW	0		;0 .. MAX_AUTO_HDG
AutoHdgFine	DW	0

AHRollRate	DW	0		;roll rate demand (fine pdegs / sec)

AHDeltaRRate	DW	0		;roll rate demand (fine pdegs / frame)

AHFlag		DB	0		;1 = auto-heading engaged
AHError		DB	0		;1 = auto-heading error

		EVEN

;* debugging vars

AutoRFine	DW	0		;roll (fine) required

AimHFine	DW	0

ErrHFine	DW	0

AHMaxRate	DW	0

AHRollVal	DW	0

;---------------
;* auto-altitude
;---------------

MIN_AUTO_ALT	EQU	20		;200ft
MAX_AUTO_ALT	EQU	7000		;70,000ft

AutoAlt		DW	0		;MIN_AUTO_ALT .. MAX_AUTO_ALT
AutoAltFine	DW	0

AAPitchRate	DW	0		;pitch rate demand (fine pdegs / sec)

AADeltaPRate	DW	0		;pitch rate demand (fine pdegs / frame)

AAGForce	DW	0		;g force (*16 scaling)

AAFlag		DB	0		;1 = auto-altitude engaged
AAError		DB	0		;1 = auto-altitude error

		EVEN

;* debugging vars

AimPFine	DW	0		;aiming pitch (fine pdegs)

AAAltError	DW	0		;altitude error

AADistError	DW	0		;distance error

;------------
;* auto-route
;------------

ThetaAB		DW	0		;angle vp(A) -> wp(B)

ThetaBC		DW	0		;angle wp(B) -> wp(C)

ThetaABC	DW	0		;angle vp(A) -> wp(B) -> wp(C)

RTurn		DW	0		;turning radius (0 .. 32,767ft)

TDist		DW	0		;turning distance (0 .. 65,535ft)

INHIBIT_DIST	EQU	6076		;1NM
INHIBIT_PERIOD	EQU	3*100		;1/100ths sec

InhibitDelay	DW	0

ARFlag		DB	0		;1 = auto-route engaged

ARLast		DB	0		;previous ARFlag value

TrackLocked	DB	0		;1 = (hdg = brg)

		EVEN

OldWPPtr	DW	OFFSET Waylist	;store WPPtr whilst target WP selected

;-----
;* ILS
;-----

ILSActive	DB	0 		;1 = in ILS beam
ILSApproach	DB	0		;approach direction (ILS flag)

ILSRangeLo	DW	0		;distance to touchdown point
ILSRangeHi	DW	0

ILSErrorLo	DW	0		;deviation from centre line
ILSErrorHi	DW	0

ILSMaxError	DW	0

LOCAL_OFFSET	EQU	1024/16		;localiser offset

ILSLocalError	DW	0		;ft
ILSLocalPos	DW	0		;localiser position (bin frac)
					;   < 0 = a/c left of centre (turn right)
					;   > 0 = a/c right of centre (turn left)

ILSGlideError	DW	0		;ft
ILSGlidePos	DW	0		;glide slope position (bin frac)
					;   < 0 = a/c below glide slope (climb)
					;   > 0 = a/c above glide slope (dive)

ILSAirfieldPtr	DW	-1		;ptr to airfield data block

ILSRng		DW	0		;range (nautical miles * 10)
ILSBrg		DW	0		;bearing (pdegs)
ILSETA		DW	0		;time (seconds)

;---------------
;* auto-approach
;---------------

AppHFine	DW	0		;approach heading (fine pdegs)

AppFlag		DB	0		;1 = auto-approach engaged
AppLast		DB	0		;previous AppFlag value
AppError	DB	0		;1 = auto-approach error

		EVEN

;* approach speed (in knots, weight = 33,000lbs) wrt configuration (-1 = value not valid)
;*
;* index = wing sweep pos * 8 + flap pos * 2

ApproachSpeed	DW	180, 172, 153, 135
		DW	199, 187, 180,  -1
	  	DW	208,  -1,  -1,  -1

;-----------------------------
;* approach progress indicator
;-----------------------------

MORSE_DASH	EQU	40		;1/100ths / sec
MORSE_DOT	EQU	10		;1/100ths / sec

AppProgFlag	DB	0		;1 = enabled

AppProgSeq	DB	0		;00b = dash	)
					;01b = pause	) bit 0 indicates
					;10b = dot	) lamp on / off
					;11b = pause	)

AppProgTimer	DW	0

;----------------
;* air radar data
;----------------

AirRadarTracks	LABEL	ARAD_TRACK

		ARAD_TRACK NUM_TRACKS DUP(<>)

AirRadarPtr	DW	OFFSET AirRadarTracks	;ptr to next available track data

NumRadarTracks	DW	0		;num of aircraft currently being tracked

AirRadarRng	DW	ARAD_MED_RANGE	;(see MAINDATA.INC)

;* aircraft position offset to scan centre (wrt range) /4 scaled
;*
;* @ min range, offset =  ((3 - 1) * 16384) / (4 * 2) = 4096
;* @ med range, offset =  ((5 - 1) * 16384) / (4 * 2) = 8192
;* @ max range, offset = ((11 - 1) * 16384) / (4 * 2) = 20480

AirRadarOffset	DW	4096		;ARAD_MIN_RANGE
		DW	8192		;ARAD_MED_RANGE
		DW	20480		;ARAD_MAX_RANGE

;* sectors scan size (wrt range)

AirRadarScan	DW	3		;ARAD_MIN_RANGE
		DW	5		;ARAD_MED_RANGE
		DW	11		;ARAD_MAX_RANGE

;* scan size and offset

ScanSize	DW	5

ScanOffset	DW	-(5/2)

;* air radar viewpoint

ARAD_VIEW	VIEWPOINT <>

;* x divide values wrt radar range (1.333 aspect ratio correction)
;*
;* @ min range, x value =  ((3 - 1) * 16384) / (48 * 1.333) = 512
;* @ med range, x value =  ((5 - 1) * 16384) / (48 * 1.333) = 1024
;* @ max range, x value = ((11 - 1) * 16384) / (48 * 1.333) = 2560

XDivVals	DW	512	;ARAD_MIN_RANGE
		DW	1024	;ARAD_MED_RANGE
		DW	2560	;ARAD_MAX_RANGE

;* y divide values wrt radar range
;*
;* @ min range, y value =  ((3 - 1) * 16384) / 48 = 683
;* @ med range, y value =  ((5 - 1) * 16384) / 48 = 1365
;* @ max range, y value = ((11 - 1) * 16384) / 48 = 3413

YDivVals	DW	683	;ARAD_MIN_RANGE
		DW	1365	;ARAD_MED_RANGE
		DW	3413	;ARAD_MAX_RANGE

SampleCntr	DW	0

BoreSightError	DD	0

;* temp vars

TmpAngDiff	DW	0

TmpScaledRng	DW	0

TmpScaledCnt	DW	0

TmpZErr		DD	0

TmpDz		DD	0

;---------------------------
;* air target display values
;---------------------------

DispAirTgtRng	DW	0
DispAirTgtAlt	DW	0
DispAirTgtVel	DW	0
DispAirTgtHdg	DW	0

;------------------------------
;* radar warning receiver (RWR)
;------------------------------

RWR_VIEW	VIEWPOINT <>

NumRWRThreats	DW	0

OldRWRThreats	DW	0

ActiveSAMCntr	DW	0

RWRThreatIndex	DW	0

RWRThreatFlags	DB	0		;(see MAINDATA.INC)

		EVEN

TmpFlags	DW	0

DATA		ENDS

;============================================================================

STACK		SEGMENT PARA PUBLIC 'STACK'
		ASSUME SS:STACK

;-----------------------------------------------------------------------
;* NOTE: Data is stored in the stack segment due to lack of space in the
;*       main DATA segment. Using SS: override does not appear to add
;*       any additional cycles to i286 and i386 timings. i486 has one
;*       extra cycle if the instruction is in cache. Therefore, use SS:
;*       override (don't worry about always using [bp]).
;-----------------------------------------------------------------------

RWRThreats	RWR	NUM_RWR_THREATS DUP(<>)

STACK		ENDS

;============================================================================

MODCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:MODCODE
		ASSUME DS:DATA

;* UpdateAvionics
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

UpdateAvionics	PROC	FAR

		call	CalcVFactor

		call	ScanGndHeight

		call	CalcRadAlt

		call	UpdateNavSystem

		call	UpdateClock

		call	ScanAirfields

		call	UpdateILS

		call	AutoPilot

		call	UpdateRadar

		call	UpdateAppProg

		call	UpdateAirRadar

		call	UpdateRWR

		call	ValidateTIALD

		call	CheckFailures

		ret

UpdateAvionics	ENDP

;----------------------------------------------------------------------------

;* CalcVFactor - calc velocity factor
;*
;* pass: Vtas
;* ret : Vfac
;* kill: assume all

CalcVFactor	PROC	NEAR

;----------------------
;* calc Vfac (wrt Vtas)
;----------------------

;* Vtas range relevant to terrain following and altitude acquire is
;* 200 .. 800kts, where:-
;* 
;*    @ 200kts, Vfac = 0
;*    @ 800kts, Vfac = 16
;*
;* 200kts = 340ft/sec
;* 800kts = 1360ft/sec (approx. 340 + 1024 = 1364)
;*
;* Vfac = (bound(Vtas, 340*8, 1364*8) - 340*8) / 512 + 1/2 bit round up = 0 .. 16

		mov	ax,Vtas

		SBOUND	ax,340*8,1364*8

		sub	ax,340*8
		mov	al,ah		;/256
		xor	ah,ah
		shr	ax,1		;/512
		ROUNDUP	ax

		mov	Vfac,ax

		ret

CalcVFactor	ENDP

;----------------------------------------------------------------------------

;* ScanGndHeight - scan ground height ahead of aircraft
;*
;* pass: Vfac
;* ret : GndHtData[]
;* kill: assume all

ScanGndHeight	PROC	NEAR

;* look up sample distance (wrt Vfac)

		mov	bx,Vfac

		shl	bx,1		;*2 word index

		mov	bx,RangeLaw[bx]

		mov	GndHtDist,bx

;* copy aircraft position to temp buffer

		COPY_VP	TMP_VIEW,M_VIEW

;* calc ground height immediately below aircraft

		mov	si,OFFSET TMP_VIEW
		call	CalcGndHeight

		mov	GndHtData[0],ax	

;* calc x and y offsets for distance between samples

		mov	ax,TMP_VIEW.VP_HDG

		mov	dx,GndHtDist

;* use *64 scaling for accuracy

		mov	cl,6		;*64
		shl	dx,cl		;dist * 64

		call	CalcDeltaXY

		mov	si,cx		;x offset
		mov	di,bx		;y offset

		mov	ax,si
		ABSV	ax		;ax = abs(x offset), dx = sign(x offset)
		mov	cl,6		;/64
		shr	ax,cl		;x offset / 64
		adc	ax,0		;1/2 bit round up
		xor	ax,dx		;restore sign
		sub	ax,dx
		mov	si,ax
		
		mov	ax,di
		ABSV	ax		;ax = abs(y offset), dx = sign(y offset)
		mov	cl,6		;/64
		shr	ax,cl		;y offset / 64
		adc	ax,0		;1/2 bit round up
		xor	ax,dx		;restore sign
		sub	ax,dx
		mov	di,ax

		mov	ax,si		;x add
		mov	dx,di		;y add

		mov	bx,2			;index
		mov	cx,NUM_HT_SAMPLES-1	;count

		mov	si,OFFSET TMP_VIEW

;* scan ground height loop

ScanGndHtLoop: 	push	ax
		push	bx
		push	cx
		push	dx
		push	si

		MOVEXY	[si],ax,dx
		
		call	CalcGndHeight

		pop	si
		pop	dx
		pop	cx
		pop	bx

		mov	GndHtData[bx],ax

		pop	ax

		add	bx,2		;next index
		
		loop	ScanGndHtLoop

		ret

ScanGndHeight	ENDP

;----------------------------------------------------------------------------

;* CalcRadAlt - calc radar altitude
;*
;* pass: ZftHi, ZftLo
;* ret : TrueRadAlt (valid up to RAD_ALT_CEILING)
;*       DispRadAlt
;* kill: assume all

CalcRadAlt	PROC	NEAR

;---------------------
;* calc radar altitude
;---------------------

		mov	ax,RAD_ALT_CEILING	;assume alt > 65,535ft

		cmp	ZftHi,0		;alt > 65,535ft
		ja	@F		;yes ->

		mov	ax,ZftLo

		sub	ax,GndHtData[0]	;radar alt = alt - ground height

		MINM	ax		;limit to 0

		cmp	ax,RAD_ALT_CEILING	;limit to RAD_ALT_CEILING
		jbe	@F
		mov	ax,RAD_ALT_CEILING

@@:		mov	TrueRadAlt,ax

;----------------
;* damp radar alt (frame rate dependant)
;----------------

		sub	ax,DispRadAlt

;* use abs(TrueRadAlt - DispRadAlt) to avoid -1 truncation error

		ABSV	ax
		REPT	1		;/2
		shr	ax,1
		ENDM
		adc	ax,0		;1/2 bit round up
		xor	ax,dx		;restore sign
		sub	ax,dx

		add	DispRadAlt,ax

		ret

CalcRadAlt	ENDP

;----------------------------------------------------------------------------

;* UpdateNavSystem - update navigation system
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

UpdateNavSystem	PROC	NEAR

;----------------------
;* update waypoint data
;----------------------

		call	UpdateWPData

;------------------------------
;* sort waypoint selection keys
;------------------------------

;* skip to next waypoint

		KTEST	KF_SkipWaypoint
		jz	@F

   		call	AdvanceWP

;* cancel target waypoint (check before "select target" as share same key)

@@:		KTEST	KF_CancelTgtWP
		jz	@F

		call	CancelTgtWP

		jmp	TgtWPOk

;* select target waypoint

@@:		KTEST	KF_SelectTgtWP
		jz	TgtWPOk

		call	SelectTgtWP

TgtWPOk:	ret

UpdateNavSystem	ENDP

;----------------------------------------------------------------------------

;* UpdateClock - update 24 hour clock
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all
;*
;* note: LastFrame <= 100 (CalcDeltaTime called from Model).

UpdateClock	PROC	NEAR

;----------------------
;* update 24 hour clock
;----------------------

		mov	al,Clock24.CLK_100THS
		add	al,BYTE PTR LastFrame

		cmp	al,100		;> 1sec?
		jae	@F		;yes ->

		mov	Clock24.CLK_100THS,al

		jmp	ClockOk

@@:		sub	al,100
		mov	Clock24.CLK_100THS,al

		mov	al,Clock24.CLK_SECS
		inc	al

		cmp	al,60		;> 1min?
		jae	@F		;yes ->

		mov	Clock24.CLK_SECS,al

		jmp	ClockOk

@@:		mov	Clock24.CLK_SECS,0

		mov	al,Clock24.CLK_MINS
		inc	al

		cmp	al,60		;> 1hr?
		jae	@F		;yes ->

		mov	Clock24.CLK_MINS,al

		jmp	ClockOk

@@:		mov	Clock24.CLK_MINS,0

		mov	al,Clock24.CLK_HRS
		inc	al

		cmp	al,24		;> 1day?
		jae	@F		;yes ->

		mov	Clock24.CLK_HRS,al

		jmp	ClockOk

@@:		mov	Clock24.CLK_HRS,0

ClockOk:	ret

UpdateClock	ENDP

;----------------------------------------------------------------------------

;* AutoPilot
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

AutoPilot	PROC	NEAR

;-----------------------------------
;* ADC damaged - disengage autopilot (if on)
;-----------------------------------

		test	SSF_ADC,1
		jz	ADCOk

		cmp	AutoMode,AUTO_OFF
		je	@F

		call	AutoCancel

		or	RedWarnings2,RED_AUT

@@:		test	AutoThrot,1
		jz	@F

		mov	AutoThrot,0

		or	RedWarnings2,RED_AUT

@@:		jmp	ExitAutoPilot

;----------------------------
;* cancel auto-pilot request?
;----------------------------

ADCOk:		KTEST	KF_AutoCancel
		jz	SkipCancel

		call	AutoCancel

		jmp	ContAutoPilot

;------------------------
;* approach mode request?
;------------------------

SkipCancel:	

        KTEST	KF_Approach
		jz	SkipApproach

		call	AutoCancel

		cli			;<<<<< IMPORTANT <<<<<

		mov	AutoMode,AUTO_APPROACH

		mov	AppFlag,1

		mov	AltMode,ALT_APPROACH

		mov	AAFlag,1

		mov	HdgMode,HDG_APPROACH

		mov	AHFlag,1

		mov	AutoThrot,1

		call	SelectAutoMFD

		sti			;<<<<< IMPORTANT <<<<<

		jmp	ContAutoPilot

;---------------------
;* track mode request?
;---------------------

SkipApproach:	KFETCH	KF_Track	
		or	al,AutoTrack	;track request or auto-start?
		jz	SkipTrack	;no ->

		mov	AutoTrack,0

;* note: Preserve vars for SortWPAlt. If track mode cannot be selected
;*       then call AutoCancel again to ensure vars are reset to manual.

		push	AltMode

		mov	al,TFAuto
		mov	ah,AAFlag

		push	ax

		call	AutoCancel

		pop	ax

		mov	AAFlag,ah
		mov	TFAuto,al

		pop	AltMode

;* cannot select track mode if weapon release in progress

		test	ArmLock,1
		jnz	@F

;* cannot select track mode if no waypoints (even if floating waypoint valid)

		cmp	WayTotal,0
		ja	ContTrack

@@:		call	AutoCancel

		jmp	SkipTrack

ContTrack:	cli			;<<<<< IMPORTANT <<<<<

		mov	AutoMode,AUTO_TRACK

		mov	ARFlag,1

		call	SortWPAlt

;* set heading for waypoint

		mov	HdgMode,HDG_TRACK

		mov	AHFlag,1

		mov	ax,WPBrgFine
		mov	dx,360
		mul	dx

		mov	AutoHdg,dx
		mov	AutoHdgFine,ax

		call	SelectAutoMFD

		sti			;<<<<< IMPORTANT <<<<<

		jmp	ContAutoPilot

;--------------------
;* hold mode request?
;--------------------

SkipTrack:	KTEST	KF_Hold
		jz	SkipHold

		call	AutoCancel

		cli			;<<<<< IMPORTANT <<<<<

		mov	AutoMode,AUTO_HOLD

;* hold current altitude

		mov	AltMode,ALT_ACQUIRE

		mov	AAFlag,1

		mov	dx,ZftHi
		mov	ax,ZftLo
		mov	bx,10
		div	bx

		UBOUND	ax,MIN_AUTO_ALT,MAX_AUTO_ALT

		mov	AutoAlt,ax
		mov	AutoAltFine,0

;* hold current heading

		mov	HdgMode,HDG_ACQUIRE

		mov	AHFlag,1

		mov	ax,HFine
		mov	dx,360
		mul	dx

		mov	AutoHdg,dx
		mov	AutoHdgFine,ax

		call	SelectAutoMFD

		sti			;<<<<< IMPORTANT <<<<<

		jmp	ContAutoPilot

;-------------------------
;* terrain follow request?
;-------------------------

SkipHold:	KTEST	KF_TFollow
		_JZ	SkipTFollow

;* terrain following not available in ADV

		cmp	TornadoType,ADV_TORNADO
		_JE	SkipTFollow

;* toggle alt mode whilst in track mode?
	
		cmp	AutoMode,AUTO_TRACK	;track mode?
		je	ToggleAltMode		;yes ->

		call	AutoCancel

		cli			;<<<<< IMPORTANT <<<<<

		mov	AutoMode,AUTO_TF

;* sort TF ride alt wrt current rad alt

		mov	AltMode,ALT_TF

		mov	TFAuto,1

		mov	ax,TrueRadAlt

		call	CalcTFRideIndex

;* hold current heading

		mov	HdgMode,HDG_ACQUIRE

		mov	AHFlag,1

		mov	ax,HFine
		mov	dx,360
		mul	dx

		mov	AutoHdg,dx
		mov	AutoHdgFine,ax

		call	SelectAutoMFD

		sti			;<<<<< IMPORTANT <<<<<

		jmp	ContAutoPilot

;-----------------------------
;* toggle ALT_ACQUIRE / ALT_TF
;-----------------------------

ToggleAltMode:	cmp	AltMode,ALT_TF	;terrain following?
		jne	@F		;no ->

;* set ALT_ACQUIRE mode

		cli			;<<<<< IMPORTANT <<<<<

		mov	TFAuto,0

		mov	AltMode,ALT_ACQUIRE

		mov	AAFlag,1

		mov	dx,ZftHi
		mov	ax,ZftLo
		mov	bx,10
		div	bx

		UBOUND	ax,MIN_AUTO_ALT,MAX_AUTO_ALT

		mov	AutoAlt,ax
		mov	AutoAltFine,0

		sti			;<<<<< IMPORTANT <<<<<

		jmp	ContAutoPilot

;* set ALT_TF mode

@@:		cli			;<<<<< IMPORTANT <<<<<

		mov	AAFlag,0

		mov	AltMode,ALT_TF

		mov	TFAuto,1

		mov	ax,TrueRadAlt

		call	CalcTFRideIndex

		sti			;<<<<< IMPORTANT <<<<<

		jmp	ContAutoPilot

;------------------------
;* auto-throttle request?
;------------------------

SkipTFollow: 	KTEST	KF_Throttle
		jz	ContAutoPilot

;* cannot engage / disengage auto-throttle if approach mode selected

		cmp	AutoMode,AUTO_APPROACH
		je	ContAutoPilot

		cli			;<<<<< IMPORTANT <<<<<

		xor	AutoThrot,1	;toggle on / off
		jz	AutoThrotOk	;off ->

;* hold current airspeed

		mov	ax,Vkts
		cmp	ax,MAX_AUTO_VIAS	;<= max value?
		jbe	@F			;yes ->
		mov	ax,MAX_AUTO_VIAS

@@:		mov	AutoVias,ax
		mov	AutoViasFine,0

		call	SelectAutoMFD

AutoThrotOk:	sti			;<<<<< IMPORTANT <<<<<

;---------------------------
;* update auto-pilot systems
;---------------------------

;* WARNING: Order of subroutines is important - DO NOT CHANGE!
;*
;*          (Refer to AutoRoute and AutoApproach documentation).

ContAutoPilot: 	call	AutoRoute

		call	AutoApproach

		call	TerrainFollow

		call	AutoAltitude

		call	AutoHeading

		call	AutoThrottle

;---------------------------------
;* test for auto-pilot malfunction
;---------------------------------

		mov	al,TFError
		or	al,ATError
		or	al,AHError
		or	al,AAError
		or	al,AppError

		jz	ExitAutoPilot	;no malfunction ->

;* cancel auto-pilot

		call	AutoCancel

;* clear errors

		xor	al,al
		mov	TFError,al
		mov	ATError,al
		mov	AHError,al
		mov	AAError,al
		mov	AppError,al

;* warning

		or	RedWarnings2,RED_AUT

ExitAutoPilot:	ret

AutoPilot	ENDP

;----------------------------------------------------------------------------

;* AutoCancel - cancel auto-pilot mode
;*
;* pass: nothing
;* ret : nothing
;* kill: al, flags

AutoCancel	PROC	NEAR

		cli			;<<<<< IMPORTANT <<<<<

		xor	al,al

;* only cancel auto-throttle if approach mode

		cmp	AutoMode,AUTO_APPROACH	;approach mode?
		jne	@F			;no ->

		mov	AutoThrot,al

@@:		mov	AutoMode,AUTO_OFF
		mov	AltMode,ALT_MANUAL
		mov	HdgMode,HDG_MANUAL

		mov	TFAuto,al
		mov	AHFlag,al
		mov	AAFlag,al
		mov	ARFlag,al
		mov	AppFlag,al
		mov	AutoTrim,al

		sti			;<<<<< IMPORTANT <<<<<

		ret

AutoCancel	ENDP

;----------------------------------------------------------------------------

;* TerrainFollow
;*
;* pass: GndHtData[]
;* ret : TFPitchRate
;*       TFDeltaPRate
;*       TFGForce
;* kill: assume all

;---------------------------
TFExit2		LABEL	NEAR		;<<<<< exit here if TF error <<<<<
;---------------------------

		mov	TFAuto,0	;disengage auto-terrain following

		mov	TFError,1	;set TF error

;---------------------------
TFExit1		LABEL	NEAR		;<<<<< exit here if TF disabled <<<<<
;---------------------------

		mov	TFBRisk,0	;clear 'B' risk warning

		mov	TFPitchRate,0

		mov	TFDeltaPRate,0

		mov	TFGForce,16	;1g

		ret

;---------------------------
TerrainFollow	PROC	NEAR
;---------------------------

		mov	al,TFAuto
		test	al,al		;TF enabled?
		xchg	al,TFLast	;new <-> old

		jz	TFExit1		;no ->

		xor	al,TFAuto	;just enabled?
		jz	@F		;no ->

   		mov	TFPullUp,0	;clear pull up flag

@@:		mov	TFBRisk,0	;clear 'B' risk warning

		mov	TFError,0	;clear TF error

;---------------------------------
;* test if within operating limits
;---------------------------------

;* ensure pitch is within limits (+/-60 degs)

		cmp	M_CosP,16384	;pitch in limits?
		jl	TFExit2 	;no ->

;* ensure roll is within limits (+/-60 degs)

		cmp	M_CosR,16384	;roll in limits (+/-60 degs)?
		jl	TFExit2 	;no ->

;* ensure airborne

		test	Airborne1,1	;airborne?
		jz	TFExit2		;no ->

;* ensure not stalled

		test	StallFlag1,1	;stalled?
		jnz	TFExit2		;yes ->

;* ensure not spinning

		test	SpinFlag,1	;spinning?
		jnz	TFExit2		;yes ->

;* ensure Vtas > 0

		cmp	Vtas,0		;Vtas <= 0?
		jle	TFExit2		;yes ->

;-------------------
;* set ride altitude
;-------------------

		mov	bx,TFRideIndex
		mov	ax,TFRideTable[bx]
		mov	TFRideAlt,ax

;-------------------------
;* reset g force to GCoord
;-------------------------

		mov	ax,GCoord
		mov	TFGForce,ax

;----------------------------
;* calc pitch rate (wrt Vtas)
;----------------------------

;* @200kts, pitch rate = 20 pdeg / sec (2g)
;* @800kts, pitch rate =  4 pdeg / sec (2g)
;*
;* pitch rate = (20 - Vfac) * 128 (fine pdegs)

		mov	ax,Vfac

		mov	ah,20
		sub	ah,al		;(20 - Vfac) * 256
		xor	al,al
		shr	ax,1		;(20 - Vfac) * 128

		mov	TFPitchRate,ax

;----------------------------
;* test for emergency pull up
;----------------------------

		test	TFPullUp,1	;already pulling up?
		jnz	@F		;yes ->

		cmp	TrueRadAlt,TF_PULL_UP_ALT	;below pull up alt?
		jae	SkipPullUp			;no ->

@@: 		mov	ax,TF_MAX_PITCH_UP

		shl	TFPitchRate,1	;pitch rate * 2 (4g)

		mov	TFPullUp,1	;emergency pull up

		mov	TFBRisk,1	;set 'B' risk warning

		jmp	SortPitchRate

;--------------------------------------------------------
;* if above TF_CEILING then push down to -TF_MAX_PITCH_DN
;--------------------------------------------------------

SkipPullUp:	cmp	ZftHi,0			;> 65,535ft?
		jne	@F	   		;yes ->
		cmp	ZftLo,TF_CEILING	;> TF_CEILING?
		jbe	SkipPushDown   		;no ->

@@:		mov	ax,-TF_MAX_PITCH_DN

		jmp	SortPitchRate

;-------------------------
;* initialize terrain scan
;-------------------------

SkipPushDown:	mov	cl,6		;prime for /64

		xor	bx,bx		;index

		mov	di,LEVEL   	;slope

		mov	si,LEVEL_DIST	;assume level

		mov	LookAhead,0

;-----------------------------
;* calc rel gnd dist below a/c
;-----------------------------

		mov	ax,ZftLo
		sub	ax,GndHtData[bx]
		ABSV	ax
		shr	ax,cl
		adc	ax,0		;1/2 bit round up
		xor	ax,dx		;restore sign
		sub	ax,dx

		mov	bp,ax		;ht1

;-----------------
;* find first step
;-----------------

		mov	Count1,0	;count = 0

FindFirstLoop: 	add	bx,2		;next sample

		cmp	bx,END_DIST	;end of scan?
		jbe	@F
		jmp	EndScan		;yes ->

@@:		mov	ax,ZftLo
		sub	ax,GndHtData[bx]
		ABSV	ax
		shr	ax,cl
		adc	ax,0		;1/2 bit round up
		xor	ax,dx		;restore sign
		sub	ax,dx		;ht2

		cmp	ax,bp		;found step?
		jne	InitSlope	;yes ->

		inc	Count1		;count = count + 1

		jmp	FindFirstLoop

;------------------
;* initialize slope
;------------------

InitSlope:	mov	bp,ax		;ht1 = ht2

		jg	InitDownSlope

;* initialize upslope

		mov	di,UPSLOPE

		mov	si,bx		;target dist = start of current step

		mov	Count3,127	;first step length invalid (default to "long")
		mov	Count2,127
		mov	Count1,0

		jmp	FindNextLoop

InitDownSlope:	mov	di,DOWNSLOPE

		mov	si,bx		;target dist = end of previous step
		sub	si,2

		mov	al,Count1

		mov	Count3,al
		mov	Count2,al
		mov	Count1,0

;--------------------
;* find next step ...
;--------------------

FindNextLoop:	add	bx,2		;next sample

 		cmp	bx,END_DIST	;end of scan?
		jbe	@F
		jmp	CheckLastStep	;yes ->

@@:		mov	ax,ZftLo
		sub	ax,GndHtData[bx]
		ABSV	ax
		shr	ax,cl
		adc	ax,0		;1/2 bit round up
		xor	ax,dx		;restore sign
		sub	ax,dx		;ht2

		cmp	ax,bp		;found step?
		jne	SortSlope	;yes ->

		inc	Count1		;count = count + 1
	
		jmp	FindNextLoop

;------------
;* sort slope
;------------

SortSlope:	mov	bp,ax		;ht1 = ht2

		jg	SortDownSlope

;* sort upslope

		cmp	di,DOWNSLOPE	;previous slope = downslope (trough)?
		jne	@F		;no ->

		mov	di,UPSLOPE

		mov	si,bx		;target dist = start of current step

		mov	Count3,127	;reset counters for upslope
		mov	Count2,127
		mov	Count1,0

		mov	LookAhead,0

		jmp	FindNextLoop

@@:		test	LookAhead,1	;look ahead requested?
		jz	@F		;no ->

		mov	al,Count1
		cmp	al,Count3	;short step -> long step?
		ja	EndScan		;yes ->

		mov	LookAhead,0

@@:		mov	al,Count2
		sub	al,Count1	;short step -> long step?
		jns	@F		;no ->

		cmp	al,-1		;step length change by 1?
		jne	EndScan		;no ->

		mov	LookAhead,1

		jmp	ContSortSlope

@@:		mov	si,bx  		;target dist = start of current step

		jmp	ContSortSlope

;* sort downslope

SortDownSlope:	test	LookAhead,1	;look ahead requested?
		jz	@F		;no ->

		mov	al,Count1
		cmp	al,Count3	;long step -> short step?
		jb	EndScan		;yes ->

		mov	LookAhead,0

@@:		cmp	di,UPSLOPE	;previous slope = upslope (peak)?
		je	EndScan		;yes ->

		mov	al,Count1
		sub	al,Count2	;long step -> short step?
		jns	@F		;no ->

		cmp	al,-1		;step length change by 1?
		jne	EndScan		;no ->

		mov	LookAhead,1

		jmp	ContSortSlope

@@:		mov	si,bx		;target dist = end of previous step
		sub	si,2

ContSortSlope:	mov	al,Count2
		mov	Count3,al
		mov	al,Count1
		mov	Count2,al
		mov	Count1,0

		jmp	FindNextLoop

;--------------------------------------
;* if downslope then last step is valid
;--------------------------------------

CheckLastStep:	cmp	di,DOWNSLOPE	;downslope?
		jne	EndScan		;no ->

		mov	al,Count1
		cmp	al,Count2	;current step >= previous step?
		jb	EndScan		;no ->

		mov	si,END_DIST	;tgt dist = end of scan

EndScan:	mov	TFTrackPoint,si	;store debug value

;--------------------------
;* calc dist to track point
;--------------------------

		mov	ax,si
		shr	ax,1		;index / 2
		mov	dx,GndHtDist
		mul	dx

		mov	TFDistError,ax	;store debug value

		mov	bp,ax

;------------------------------------
;* aiming altitude = peak + TFRideAlt
;------------------------------------

		mov	dx,GndHtData[si]
		add	dx,TFRideAlt

		mov	TFTgtAlt,dx	;store debug value

;-------------------------------
;* aircraft below or above peak?
;-------------------------------

		sub	dx,ZftLo	;dx = alt error
		js	TFAbove    	;above ->

;---------------------
;* aircraft below peak
;---------------------

;* slope = arctan(alt error / peak dist)

		mov	TFAltError,dx	;store debug value

		mov	ax,32767	;assume slope >= 1

		cmp	dx,bp		;slope >= 1
		jae	@F		;yes ->

		xor	ax,ax

		div	bp

		shr	ax,1

@@:		call	ArcTan

;* limit pitch up

		cmp	ax,TF_MAX_PITCH_UP
		jbe	TFCont
		mov	ax,TF_MAX_PITCH_UP

		jmp	TFCont

;---------------------
;* aircraft above peak
;---------------------

TFAbove:   	neg	dx

		mov	TFAltError,dx	;store debug value

		mov	ax,32767	;assume slope >= 1

		cmp	dx,bp		;slope >= 1
		jae	@F		;yes ->

		xor	ax,ax

		div	bp

		shr	ax,1

@@:		call	ArcTan

;* limit pitch down

		cmp	ax,TF_MAX_PITCH_DN
		jbe	@F
		mov	ax,TF_MAX_PITCH_DN

@@:	   	neg	ax

;-----------------------
;* sort 'B' risk warning
;-----------------------

;* set 'B' risk if rad alt < TF_B_RISK_ALT

TFCont:	  	cmp	TrueRadAlt,TF_B_RISK_ALT;< 'B' risk altitude?
		jb	@F			;yes ->

;* set 'B' risk if speed > TF_B_RISK_SPEED and slope > TF_B_RISK_SLOPE

		cmp	Vtas,TF_B_RISK_SPEED	;> 'B' risk speed?
		jle	SortVtrim		;no ->
		cmp	ax,TF_B_RISK_SLOPE	;> 'B' risk slope?
		jle	SortVtrim 		;no ->

@@:		mov	TFBRisk,1	;set 'B' risk warning

;-------------------------
;* sort pitch up wrt Vtrim
;-------------------------

;* if Vtas < Vtrim then
;*    pitch up = arctan(-((Vtas - Vtrim) / 4) / Vtas) (fine pdegs)
;* end

SortVtrim:     	mov	dx,Vtas
		sub	dx,Vtrim	;Vtas < Vtrim?
		jns	SortPitchRate	;no ->
			    	
		push	ax		;store slope
	
		neg	dx		;make +ve

		mov	ax,32767	;assume slope >= 1

		xor	cx,cx

		REPT	2		;/4
		shr	dx,1
		rcr	cx,1
		ENDM

		mov	bx,Vtas

		cmp	dx,bx		;slope ok? (note Vtas > 0)
		jae	@F		;no ->

		mov	ax,cx

		shr	dx,1		;/2 for signed binary fraction
		rcr	ax,1

		div	bx

@@:		call	ArcTan		;ax = arctan(frac)

		pop	dx		;restore slope

		add	ax,dx		;slope = slope + pitch up

;* check pitch up limit

		cmp	ax,TF_MAX_PITCH_UP
		jle	SortPitchRate
		mov	ax,TF_MAX_PITCH_UP
		
;-----------------
;* sort pitch rate
;-----------------

SortPitchRate:	mov	TFSlope,ax

		sub	ax,PFine	;pitch error = slope - pitch
		jz	TFExit4		;zero pitch error ->

		ABSV	ax		;ax = abs(error), dx = sign(error)

		mov	bx,ax		;bx = abs(error)
		mov	cx,dx		;cx = sign(error)

		mov	ax,DeltaTime
		mov	bp,TFPitchRate
		imul	bp
		FRACADJ	dx		;dx = delta pitch rate

		cmp	dx,bx		;delta pitch rate > error?
		jbe	@F		;no ->
   
		mov	dx,bx		;delta pitch rate = error

@@:		xor	dx,cx		;restore sign
		sub	dx,cx
		mov	TFDeltaPRate,dx

		mov	ax,bp
		xor	ax,cx		;restore sign
		sub	ax,cx
		mov	TFPitchRate,ax

;--------------
;* sort g force
;--------------

		test	ax,ax		;pulling or pushing?
		jz	TFExit3		;no (g force = GCoord) ->

		cwd			;dx = sign(g force)

		mov	ax,2*16		;2g
		test	TFPullUp,1	;emergency pull up?
		jz	@F		;no ->
		mov	ax,4*16		;4g

@@:		xor	ax,dx		;sort sign(g force)
		sub	ax,dx

;* scale wrt error
	
		cmp	bx,bp		;error >= rate?
		jae	@F		;yes ->

		mov	cx,ax

		mov	dx,bx		;frac = error / rate
		xor	ax,ax
		div	bp

		shr	ax,1		;/2 for binary fraction

		imul	cx		;g * frac
		FRACADJ	ax

@@:		add	TFGForce,ax

TFExit3:	ret

;---------------------------
TFExit4		LABEL	NEAR		;<<<<< exit here if zero pitch error <<<<<
;---------------------------

		mov	TFPitchRate,0

		mov	TFDeltaPRate,0

		test	TFPullUp,1	;was this an emergency pull up?
		jz	@F		;no ->

		mov	TFAuto,0	;disengage auto-terrain following

		mov	TFBRisk,0	;clear 'B' risk warning

		mov	TFPullUp,0	;clear pull up flag

		mov	TFError,1	;set TF error

@@:		ret

TerrainFollow	ENDP

;----------------------------------------------------------------------------

;* CalcTFRideIndex
;*
;* pass: ax = desired ride alt
;* ret : TFRideIndex
;* kill: bx, flags

CalcTFRideIndex	PROC	NEAR

		mov	bx,MAX_TF_INDEX

TFRideLoop:	cmp	ax,TFRideTable[bx]	;alt >= ride alt?
		jae	@F			;yes ->

		sub	bx,2		;next ride alt

		jnz	TFRideLoop	;(stop if last value)

@@:	       	mov	TFRideIndex,bx

		ret

CalcTFRideIndex	ENDP

;----------------------------------------------------------------------------

;* AutoThrottle
;*
;* pass: AutoVias
;* ret : Throttle
;*       Reheat
;* kill: assume all

ATExit2		LABEL	NEAR		;<<<<< exit here if AT error <<<<<

		mov	AutoThrot,0	;disengage auto-throttle

		mov	ATError,1	;signal error

ATExit1		LABEL	NEAR		;<<<<< exit here if AT disabled <<<<<

		ret

AutoThrottle	PROC	NEAR

		test	AutoThrot,1	;auto-throttle engaged?
		jz	ATExit1		;no ->

		mov	ATError,0	;clear error

;------------------------------------------
;* check auto-throttle operating conditions
;------------------------------------------

		cmp	FuelWt,0	;out of fuel?
		je	ATExit2		;yes ->

		mov	al,SSF_Engine1
		test	al,SSF_Engine2	;both engines damaged?
		jnz	ATExit2		;yes ->

		test	SpinFlag,1	;spinning?
		jnz	ATExit2		;yes ->

;-----------------------------
;* calc AutoVtas from AutoVias
;-----------------------------

;* limit = 17144 = 2.2 * 573 * 1.7 * 8
;*
;* v = AutoVias * 1.7 * 8 * 32768 = AutoVias * 8 * 55706
;*
;* AutoVtas = min(v / SqrtRho, limit)

		mov	ax,AutoVias
		REPT	3   		;*8
		shl	ax,1
		ENDM
		mov	dx,55706
		mul	dx

		mov	bx,SqrtRho
		div	bx

;* //MOD// 01.04.1993 - Adjust for crosswinds.

		sub	ax,XWindVeff
		MINM	ax

		cmp	ax,17144
		jbe	@F
		mov	ax,17144

@@:		mov	AutoVtas,ax

;--------------------
;* calc aiming thrust
;--------------------

;* if aiming speed = 0 then
;*    set min throttle (prevent bogus throttle up when static)
;* end

		test	ax,ax		;aiming speed = 0?
		_JZ	MinThrottle	;yes ->

;* v = u + at
;*
;* a = (v - u) / t
;*
;* when t = 1
;*
;* accel = AutoVtas - Vtas

		sub	ax,Vtas

;* accel = (thrust - drag - weight * sin(pitch)) * 32 / weight
;*
;* thrust = accel * weight / 32 + drag + weight * sin(pitch)

;* if accel >= 32 ft/sec/sec then assume max throttle

		cmp	ax,32*8
		_JGE	MaxThrottle

;* if accel <= -32 ft/s/s then assume min throttle

		cmp	ax,-32*8
		_JLE	MinThrottle

;* accel * weight / 32 = accel [*8] * weight [/2] / 128

		mov	dx,Weight2
		imul	dx

		REPT	7		;/128
		sar	dx,1
		rcr	ax,1
		ENDM

;* accel * weight / 32 + drag

		add	ax,DragLo
		adc	dx,DragHi

		mov	bx,ax
		mov	cx,dx

;* weight * sin(pitch) = weight [/2] * sin(pitch) * 2

		mov	ax,M_SinP
		mov	dx,Weight2
		imul	dx		;weight [/2] * sin(pitch)
		shl	ax,1		;adjust for signed binary fraction
		rcl	dx,1

;* weight [/2] * sin(pitch) * 2 (maintaining lsb resolution) (32 bit result)

		mov	bp,ax
		mov	ax,dx
		cwd

		shl	bp,1		;restore lsb
		rcl	ax,1
		rcl	dx,1

;* thrust = accel * weight / 32 + drag + weight * sin(pitch)

		add	ax,bx
		adc	dx,cx

		_JS	MinThrottle	;thrust < 0 ->

		test	dx,dx		;thrust > 65535?
		_JNZ	MaxThrottle	;yes ->

		cmp	ax,MAX_THRUST	;thrust > MAX_THRUST?
		_JA	MaxThrottle	;yes ->

;--------------------
;* calc aiming thrust (wrt altitude)
;--------------------

;* //MOD// 14.05.1992 - variation of thrust wrt altitude equations modified
;*                      (see MODEL.ASM)

;* if zft < 36,000ft then
;*    thrust = thrust + zft * 0.325
;* else
;*    thrust = thrust + 11700 + (zft - 36000) * 0.656
;* endif

		mov	bp,ax

		mov	ax,ZftLo
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

		_JNZ	MaxThrottle	;zft > (65535 + 36000) ->

		mov	dx,42984	;0.656 = 42984 / 65536
		mul	dx
		shl	ax,1
		adc	dx,11700

SortThrust:	add	bp,dx
		_JC	MaxThrottle	;thrust > 65535 ->

		cmp	bp,MAX_THRUST	;thrust > MAX_THRUST?
		_JA	MaxThrottle	;yes ->

		mov	ATThrust,bp

;* if one engine is damaged then the other engine must do the work of two

		mov	al,SSF_Engine1
		or	al,SSF_Engine2
		jz	@F		;both engines ok ->

		cmp	bp,MAX_THRUST/2	;thrust > MAX_THRUST single engine?
		_JA	MaxThrottle	;yes ->

		shl	bp,1		;*2

;----------------------------------------
;* calc aiming throttle / reheat settings
;----------------------------------------

;* if thrust > MAX_DRY then
;*    throttle = 256
;*    reheat = (thrust - MAX_DRY) / 125
;* else
;*    throttle = (RPM - 63) * 1771 / 256
;*    reheat = 0
;* end

@@:		cmp	bp,MAX_DRY	;thrust > MAX_DRY?
		jbe	@F		;no ->

		mov	ax,bp
		sub	ax,MAX_DRY
		xor	dx,dx
		mov	bx,125
		div	bx

		cmp	dx,125/2	;cf = 1/2 bit
		cmc
		adc	ax,0		;1/2 bit round up

		mov	AimThrottle,256
		mov	AimReheat,ax

		jmp	ContThrottle

;* scan thrust table for rpm value

@@:		shr	bp,1		;thrust for one engine

		mov	bx,-2

@@:		add	bx,2
		cmp	bp,ThrustTable[bx]
		ja	@B

		shr	bx,1		;(RPM - 63) = index / 2

		mov	ax,1771
		mul	bx

		xchg	al,ah		;/256
		shl	ah,1
		mov	ah,0
		adc	ax,0		;1/2 bit round up

;* linear search for more precise throttle setting

		mov	si,ax		;throttle

		mov	di,32768	;init old error

;* look up and interpolate thrust value

ThrottleLoop:	mov	ax,37		;calc rpm value
		mul	si

		xor	bx,bx
		xchg	bl,ah
		shl	bx,1		;*2 word index
		mov	cx,ThrustTable[bx]
		cmp	bx,37*2			;100% ?
		je	@F			;yes ->
		mov	dx,ThrustTable[bx+2]
		sub	dx,cx
		mul	dx
		shl	al,1		;store 1/2 bit
		mov	al,ah		;/256
		mov	ah,dl
   		adc	cx,ax		;1/2 bit round up

@@:		mov	ax,cx
		sub	ax,bp
		ABSV	ax		;ax = new error = abs(thrust - aiming thrust)

		cmp	ax,di		;new error >= new error?
		jae	@F		;yes ->

		mov	di,ax		;old error = new error

		sub	si,1

		jnc	ThrottleLoop

@@:		add	si,1		;restore throttle

		mov	AimThrottle,si
		mov	AimReheat,0

		jmp	ContThrottle

;--------------
;* max throttle
;--------------

MaxThrottle:	mov	ATThrust,MAX_THRUST
		mov	AimThrottle,256
		mov	AimReheat,128

		jmp	ContThrottle

;--------------
;* min throttle
;--------------

MinThrottle:	xor	ax,ax
		mov	ATThrust,ax
		mov	AimThrottle,ax
		mov	AimReheat,ax

;--------------------------
;* adjust throttle / reheat (wrt time)
;--------------------------

;* throttle change rate = 256 / (100 * 2) = 1.28 secs fsd
;*
;* reheat change rate = 128 / (100 * 2) = 0.64 secs fsd

ContThrottle:	mov	bp,LastFrame

		shl	bp,1		;max throttle change rate

		cmp	Throttle,256	;can we change reheat?
		jne	SkipReheat	;no ->

		mov	ax,AimReheat
		sub	ax,Reheat	;change reheat?
		jz	SkipReheat	;no ->

		ABSV	ax		;ax = abs(diff), dx = sign(diff)

		cmp	ax,bp		;diff < max rate?
		jb	@F		;yes ->
		mov	ax,bp

@@:		xor	ax,dx		;restore sign
		sub	ax,dx

		add	Reheat,ax

		jmp	ExitThrottle

SkipReheat:	cmp	Reheat,0	;can we change throttle?
		jne	ExitThrottle	;no ->

		mov	ax,AimThrottle
		sub	ax,Throttle	;change throttle?
		jz	ExitThrottle	;no ->

		ABSV	ax		;ax = abs(diff), dx = sign(diff)

		cmp	ax,bp		;diff < max rate?
		jb	@F		;yes ->
		mov	ax,bp

@@:		xor	ax,dx		;restore sign
		sub	ax,dx

		add	Throttle,ax

ExitThrottle:	ret

AutoThrottle	ENDP

;----------------------------------------------------------------------------

;* AutoHeading
;*
;* pass: AutoHdg
;* ret : AHRollRate
;*       AHDeltaRRate
;* kill: assume all

;---------------------------
AHExit2		LABEL	NEAR		;<<<<< exit here if AH error <<<<<
;---------------------------

		mov	AHFlag,0	;disengage auto-hdg

		mov	AHError,1	;set auto-hdg error

;---------------------------
AHExit1		LABEL	NEAR		;<<<<< exit here if AH disabled <<<<<
;---------------------------

		mov	AHRollRate,0

		mov	AHDeltaRRate,0

		ret

;---------------------------
AutoHeading	PROC	NEAR
;---------------------------

		test	AHFlag,1	;auto-hdg enabled?
		jz	AHExit1		;no ->

		mov	AHError,0	;clear AH error

;---------------------------------
;* test if within operating limits
;---------------------------------

;* ensure pitch is within limits (+/-60 degs)

		cmp	M_CosP,16384	;pitch in limits?
		jl	AHExit2 	;no ->

;* ensure roll is within limits (+/-60 degs)

		cmp	M_CosR,16384	;roll in limits (+/-60 degs)?
		jl	AHExit2 	;no ->

;* ensure airborne

		test	Airborne1,1	;airborne?
		jz	AHExit2		;no ->

;* ensure not stalled

		test	StallFlag1,1	;stalled?
		jnz	AHExit2		;yes ->

;* ensure not spinning

		test	SpinFlag,1	;spinning?
		jnz	AHExit2		;yes ->

;* ensure Vtas > 0

		cmp	Vtas,0		;Vtas <= 0?
		jle	AHExit2		;yes ->

;--------------------------------------------
;* if emergency pull up then roll wings level
;--------------------------------------------

		xor	ax,ax		;assume emergency pull up

		test	TFPullUp,1	;emergency?
		_JNZ	ContHeading	;yes ->

;---------------------------
;* calc new hdg (fine pdegs)
;---------------------------

;* if auto-approach enabled then
;*    new hdg (fine) = AppHFine - (ILSLocalError * 4)
;* else
;*    new hdg (fine) = AutoHdg, AutoHdgFine / 360
;* endif

		test	AppFlag,1	;auto-approach
		jnz	@F		;yes ->

		mov	dx,AutoHdg
		mov	ax,AutoHdgFine
		mov	bx,360
		div	bx

		jmp	SetAimHFine

@@:		mov	dx,ILSLocalError
		REPT	2		;*4
		shl	dx,1
		ENDM
	  	mov	ax,AppHFine
	  	sub	ax,dx

SetAimHFine:	mov	AimHFine,ax	;store debug value

;----------------
;* calc hdg error
;----------------

		sub	ax,HFine

		mov	ErrHFine,ax 	;store debug value

;* critical damping for heading error (prevent oscillation on slow machines
;* but have little effect on faster machines)
;*
;* hdg error = hdg error * max(32767 - DeltaTime, 16384) / 32768

		mov	dx,32767
		sub	dx,DeltaTime
		cmp	dx,16384
		jae	@F
		mov	dx,16384
@@:		imul	dx
		FRACADJ	ax

		ABSV	ax

		mov	bx,ax		;bx = abs(hdg error)
		mov	cx,dx		;cx = sign(hdg error)

;----------------------------
;* limit Vtas (100 .. 800kts)
;----------------------------

		mov	bp,Vtas

		SBOUND	bp,1360,10880

;------------------------------
;* calc hdg rate max (wrt Vtas)
;------------------------------

;* max rate = 47039bh / Vtas

		mov	dx,00047h
		mov	ax,0039bh
		div	bp

		mov	AHMaxRate,ax	;store debug value

;-----------------
;* sort roll angle
;-----------------

;* if hdg err <= max rate then
;*    calc roll angle
;* else
;*    roll angle = AH_MAX_ROLL * sign(hdg error)
;* end

		cmp	bx,ax		;hdg err <= max rate?
		ja	MaxRollAngle	;no ->

;* roll angle = arctan(hdg err * Vtas * 400 / 65536)

		mov	ax,bx

		xor	ax,cx		;restore sign
		sub	ax,cx

		imul	bp

		REPT	4		;*16
		shl	ax,1
		rcl	dx,1
		ENDM

		mov	di,dx		;*16
		mov	si,ax

		REPT	3		;*8 (*128)
		shl	si,1
		rcl	di,1
		ENDM

		add	ax,si		;*144
		adc	dx,di

		REPT	1		;*2 (*256)
		shl	si,1
		rcl	di,1
		ENDM

		add	ax,si		;*400
		adc	dx,di

		mov	ax,dx

		mov	AHRollVal,ax	;store debug value

		call	ArcTan2

		jmp	ContHeading

;* set roll angle to max

MaxRollAngle:	mov	ax,AH_MAX_ROLL

		xor	ax,cx		;restore sign
		sub	ax,cx

ContHeading:	mov	AutoRFine,ax	;store debug value

		sub	ax,RFine	;roll error

		ABSV	ax		;ax = abs(roll error), dx = sign(roll error)

;* AHRollRate = AH_ROLL_RATE * sign(error)
;*
;* AHDeltaRRate = min(abs(error), AH_ROLL_RATE * DeltaTime / 32768) * sign(error)

		mov	bx,ax		;abs(error)
		mov	cx,dx		;sign(error)

		mov	bp,AH_ROLL_RATE

		mov	ax,DeltaTime
		imul	bp
		FRACADJ	dx

		cmp	dx,bx		;rate > error?
		jbe	@F		;no ->
		mov	dx,bx

@@:		xor	dx,cx		;restore sign
		sub	dx,cx

		mov	AHDeltaRRate,dx

		xor	bp,cx		;restore sign
		sub	bp,cx

		mov	AHRollRate,bp

		ret

AutoHeading	ENDP

;----------------------------------------------------------------------------

;* AutoAltitude
;*
;* pass: AutoAlt
;* ret : AAPitchRate
;*       AADeltaPRate
;*       AAGForce
;* kill: assume all

;---------------------------
AAExit2		LABEL	NEAR		;<<<<< exit here if AA error <<<<<
;---------------------------

		mov	AAFlag,0	;disengage auto-alt

		mov	AAError,1	;set auto-alt error

;---------------------------
AAExit1		LABEL	NEAR		;<<<<< exit here if AA disabled <<<<<
;---------------------------

		mov	AAPitchRate,0

		mov	AADeltaPRate,0

		mov	AAGForce,16	;1g

		ret

;---------------------------
AutoAltitude	PROC	NEAR
;---------------------------

		test	AAFlag,1	;auto-alt enabled?
		jz	AAExit1		;no ->

		mov	AAError,0	;clear AA error

;---------------------------------
;* test if within operating limits
;---------------------------------

;* ensure pitch is within limits (+/-60 degs)

		cmp	M_CosP,16384	;pitch in limits?
		jl	AAExit2 	;no ->

;* ensure roll is within limits (+/-60 degs)

		cmp	M_CosR,16384	;roll in limits (+/-60 degs)?
		jl	AAExit2 	;no ->

;* ensure airborne

		test	Airborne1,1	;airborne?
		jz	AAExit2		;no ->

;* ensure not stalled

		test	StallFlag1,1	;stalled?
		jnz	AAExit2		;yes ->

;* ensure not spinning

		test	SpinFlag,1	;spinning?
		jnz	AAExit2		;yes ->

;* ensure Vtas > 0

		cmp	Vtas,0		;Vtas <= 0?
		jle	AAExit2		;yes ->

;----------------------------
;* calc pitch rate (wrt Vtas)
;----------------------------

;* @200kts, pitch rate = 20 pdeg / sec (2g)
;* @800kts, pitch rate =  4 pdeg / sec (2g)
;*
;* pitch rate = 20 * 128 - (bound(Vtas, 340 * 8, 1360 * 8) - 340 * 8) / 4

		mov	ax,Vtas

		SBOUND	ax,340*8,1360*8

		mov	di,ax

		sub	ax,340*8

		REPT	2		;/4
		shr	ax,1
		ENDM

		mov	bp,20*128

		sbb	bp,ax		;(1/2 bit round up)

		mov	AAPitchRate,bp

;-----------------------------
;* calc pitch limit (wrt Vtas)
;-----------------------------

;* pitch limit = pitch rate * 2

		shl	bp,1

;----------------------------
;* calc dist error (wrt Vtas)
;----------------------------

;* dist error = bound(Vtas, 340 * 8, 1360 * 8) / 8

		REPT	3		;/8
		shr	di,1
		ENDM

		ROUNDUP	di

		mov	AADistError,di	;store debug value

;--------------
;* calc z error
;--------------

;* if auto-approach enabled then
;*    aiming z = ILSMaxError - 20 (auto alt reaction delay compensation)
;* else
;*    aiming z = AutoAlt * 10
;* endif

		test	AppFlag,1	;auto-approach?
		jnz	@F		;yes ->

		mov	ax,AutoAlt
		mov	dx,10
		mul	dx

		jmp	CalcZError

@@:		mov	ax,ILSMaxError
		sub	ax,20
		MINM	ax
		xor	dx,dx

;* z error = aiming z - current z

CalcZError: 	sub	ax,ZftLo
		sbb	dx,ZftHi

		mov	si,dx		;store sign(z error)

		test	dx,dx		;< 0?
		jns	@F		;no ->
		NEG32	dx,ax

;-------------------
;* calc aiming pitch
;-------------------

;* if z error < dist error then
;*    aiming pitch = arctan(z error * 32768 / dist error)
;*    aiming pitch = min(aiming pitch, pitch limit)
;* else
;*    aiming pitch = pitch limit
;* end
;*
;* aiming pitch = aiming pitch * sign(z error)

@@:		test	dx,dx		;z error > 65,535ft?
		jnz	SetPitchLimit	;yes ->

		mov	AAAltError,ax	;store debug value

		cmp	ax,di		;z error < dist error?
		jae	SetPitchLimit	;no ->

		mov	dx,ax		;z error * 32768
		xor	ax,ax
		shr	dx,1
		rcr	ax,1

		div	di

		push	si
		push	bp
		call	ArcTan
		pop	bp
		pop	si

		cmp	ax,bp		;aiming pitch <= pitch limit
		jbe	@F		;yes ->

SetPitchLimit:	mov	ax,bp

@@:		xchg	ax,si		;aiming pitch * sign(z error)
		cwd			
		xor	si,dx
		sub	si,dx

;-------------------------
;* sort pitch up wrt Vtrim
;-------------------------

;* if Vtas < Vtrim then
;*    pitch = pitch + arctan(-((Vtas - Vtrim) / 4) / Vtas) (fine pdegs)
;* end

		mov	ax,si

		mov	dx,Vtas
		sub	dx,Vtrim	;Vtas < Vtrim?
		jns	SortAAPRate	;no ->
			    	
		push	ax		;store pitch
	
		neg	dx		;make +ve

		mov	ax,32767	;assume slope >= 1

		xor	cx,cx

		REPT	2		;/4
		shr	dx,1
		rcr	cx,1
		ENDM

		mov	bx,Vtas

		cmp	dx,bx		;slope ok? (note Vtas > 0)
		jae	@F		;no ->

		mov	ax,cx

		shr	dx,1		;/2 for signed binary fraction
		rcr	ax,1

		div	bx

@@:		call	ArcTan		;ax = arctan(frac)

		pop	dx		;restore pitch

		add	ax,dx		;slope = pitch + pitch up

;-----------------
;* sort pitch rate
;-----------------

SortAAPRate:	mov	AimPFine,ax	;store debug value

		sub	ax,PFine	;pitch error = aiming pitch - pitch

		ABSV	ax		;ax = abs(error), dx = sign(error)

		mov	bx,ax		;bx = abs(error)
		mov	cx,dx		;cx = sign(error)

		mov	ax,DeltaTime
		mov	bp,AAPitchRate
		imul	bp
		FRACADJ	dx		;dx = delta pitch rate

		cmp	dx,bx		;delta pitch rate > error?
		jbe	@F		;no ->
   
		mov	dx,bx		;delta pitch rate = error

@@:		xor	dx,cx		;restore sign
		sub	dx,cx
		mov	AADeltaPRate,dx

		mov	ax,bp
		xor	ax,cx		;restore sign
		sub	ax,cx
		mov	AAPitchRate,ax

;--------------
;* sort g force
;--------------

		mov	dx,GCoord
		mov	AAGForce,dx

		test	ax,ax		;pushing or pulling?
		jz	AAExit3		;no (g force = GCoord) ->

		cwd			;dx = sign(g force)

		mov	ax,2*16		;2g

		xor	ax,dx		;sort sign(g force)
		sub	ax,dx

		cmp	bx,bp		;error > rate?
		jae	@F		;yes ->

		mov	cx,ax

		mov	dx,bx		;frac = error / rate
		xor	ax,ax
		div	bp

		shr	ax,1		;/2 for binary fraction

		imul	cx		;g * frac
		FRACADJ	ax

@@:		add	AAGForce,ax

AAExit3:	ret

AutoAltitude	ENDP

;----------------------------------------------------------------------------

;* AutoRoute - fly from waypoint to waypoint
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all
;*
;* note: This routine sets up parameters for AutoAltitude and AutoHeading
;*       so call AutoRoute before calling these routines.
;*
;*       Track mode cannot be selected if there are no waypoints.

AutoRoute	PROC	NEAR

		mov	al,ARFlag
		test	al,al		;auto-route enabled?
		xchg	al,ARLast	;new <-> old

		_JZ	ExitAutoRoute	;no ->

		xor	al,ARFlag	;just enabled?
		jz	@F		;no ->

;-----------------
;* init auto-route
;-----------------

		mov	TrackLocked,0

;-------------------------------------
;* check if weapon release in progress
;-------------------------------------

@@:		test	ArmLock,1	;weapon release in progress?
		_JNZ	ExitAutoRoute	;yes ->

;---------------------
;* satisfied waypoint?
;---------------------

		mov	si,WPPtr

		test	WP_ATTR[si],WP_TYPE	;turning or target waypoint?
		jnz	TargetWP		;target ->

;------------------
;* turning waypoint (turn early to next waypoint to keep on track)
;------------------

		call	CalcTurnDist

		cmp	WORD PTR WPRng+2,0	;range > turn dist?
		_JA	WPOk			;yes ->
		cmp	WORD PTR WPRng,ax	;range > turn dist?
		_JAE	WPOk			;yes ->

		jmp	SatisfiedWP

;-----------------
;* target waypoint (fly over waypoint)
;-----------------

TargetWP:	test	TrackLocked,1	;track locked?
		jnz	@F		;yes, flying towards waypoint ->

;* within 1/2NM of waypoint?

		cmp	WORD PTR WPRng+2,0
		_JA	WPOk			;no ->
		cmp	WORD PTR WPRng,6076/2
		jae	WPOk			;no ->

@@:		mov	ax,Hdg
		mov	dx,WPBrg
		call	CalcAngDiff

		cmp	ax,128		;error > 90 degs?
		jbe	WPOk		;no ->

;--------------------
;* waypoint satisfied
;--------------------

;* if last waypoint and not linked back then
;*    if AltMode = ALT_TF then
;*       AutoMode = AUTO_TF
;*    else
;*       AutoMode = AUTO_HOLD
;*    endif
;*    ARFlag = 0
;*    HdgMode = HDG_ACQUIRE
;*    if in ILS beam then
;*       engage approach mode
;*    endif
;* else
;*    select next waypoint
;* endif

SatisfiedWP:	mov	si,WPPtr
		cmp	si,EndWPPtr	;satisfied last waypoint?
		jne	ContRoute	;no ->

		test	WP_ATTR[si],WP_LINK	;linked back?
		jnz	ContRoute		;yes ->

		mov	ax,AUTO_TF	;assume terrain following

		cmp	AltMode,ALT_TF	;terrain following?
		je	@F		;yes ->

		mov	ax,AUTO_HOLD

@@:		cli			;<<<<< IMPORTANT <<<<<

		mov	AutoMode,ax

		mov	ARFlag,0	;disengage auto-route

		mov	HdgMode,HDG_ACQUIRE

		sti			;<<<<< IMPORTANT <<<<<

;* engage approach mode if in ILS beam

		test	ILSActive,1
		_JZ	ExitAutoRoute

		call	AutoCancel

		cli			;<<<<< IMPORTANT <<<<<

		mov	AutoMode,AUTO_APPROACH

		mov	AppFlag,1

		mov	AltMode,ALT_APPROACH

		mov	AAFlag,1

		mov	HdgMode,HDG_APPROACH

		mov	AHFlag,1

		mov	AutoThrot,1

		sti			;<<<<< IMPORTANT <<<<<

		jmp	ExitAutoRoute

ContRoute:	call	SelectNextWP

		cli			;<<<<< IMPORTANT <<<<<
		call	SortWPAlt
		sti			;<<<<< IMPORTANT <<<<<

;-----------------------
;* test for track locked (hdg = brg)
;-----------------------

WPOk:		test	TrackLocked,1	;track already locked?
		jnz	ContInhibit	;yes, continue inhibit test ->

		mov	ax,Hdg
		cmp	ax,WPBrg	;hdg = brg?
		jne	AdjustHdg	;no ->

		mov	TrackLocked,1

		mov	InhibitDelay,INHIBIT_PERIOD

;--------------------------
;* set heading for waypoint (unless inhibited - inhibit reduces jitter)
;--------------------------
  
;* if track locked then
;*    update inhibit delay
;*    if waypoint dist > INHIBIT_DIST then
;*       if inhibit delay = 0 then
;*          inhibit delay = INHIBIT_PERIOD
;*          adjust heading
;*       endif
;*    endif
;*    adjust heading
;* endif
							     
;* update inhibit delay

ContInhibit:	mov	ax,InhibitDelay
		sub	ax,LastFrame
		MINM	ax
		mov	InhibitDelay,ax

		mov	bp,ax

;* waypoint dist > INHIBIT_DIST?
		
		cmp	WORD PTR WPRng+2,0
		jnz	@F				;yes ->
		cmp	WORD PTR WPRng,INHIBIT_DIST
		jbe	ExitAutoRoute			;no ->

@@:		test	bp,bp		;inhibit delay = 0?
		jnz	ExitAutoRoute	;no ->

		mov	InhibitDelay,INHIBIT_PERIOD

AdjustHdg:	mov	ax,WPBrgFine
		mov	dx,360
		mul	dx

		mov	AutoHdg,dx
		mov	AutoHdgFine,ax

ExitAutoRoute:	ret

AutoRoute	ENDP

;----------------------------------------------------------------------------

;* SelectNextWP - select next waypoint
;*
;* pass: WPPtr
;* ret : WPPtr -> next waypoint
;* kill: assume all

SelectNextWP	PROC	NEAR

		mov	si,WPPtr
		call	CalcNextWP
		mov	WPPtr,di

;* update waypoint range and bearing etc.

		call	UpdateWPData

;* reset auto-route vars

		mov	TrackLocked,0

		ret

SelectNextWP	ENDP

;----------------------------------------------------------------------------

;* CalcNextWP - calc ptr to next waypoint
;*
;* pass: si -> current waypoint
;* ret : di -> next waypoint
;* kill: flags

CalcNextWP	PROC	NEAR

;* if current waypoint is floating waypoint then restore previous waypoint

		cmp	si,OFFSET FloatWP	;floating waypoint selected?
		jne	@F			;no ->

		mov	di,OldWPPtr

		jmp	ExitNextWP

;* link back or advance to next waypont?

@@:		test	WP_ATTR[si],WP_LINK	;link back to waypoint?
		jnz	SortLink		;yes ->

;* advance to next waypoint (if possible)

		mov	di,si		;di -> current waypoint

		test	WAY_REC_SIZE+WP_ATTR[di],WP_VALID	;next waypoint vaild?
		jz	ExitNextWP				;no, do not advance ->

		add	di,WAY_REC_SIZE	;di -> next waypoint

		jmp	ExitNextWP

;* link back to tagged waypoint

SortLink:	mov	di,OFFSET WayList	;di -> first waypoint

@@:		cmp	di,si			;di -> current waypoint?
		je	ExitNextWP		;yes, do not advance ->

		test	WP_ATTR[di],WP_HERE	;link back to here?
		jnz	ExitNextWP		;yes ->

		add	di,WAY_REC_SIZE		;advance

		jmp	@B

ExitNextWP:	ret

CalcNextWP	ENDP

;----------------------------------------------------------------------------

;* AdvanceWP - advance to next waypoint
;*
;* pass: WPPtr
;* ret : WPPtr -> next waypoint
;* kill: assume all

AdvanceWP	PROC	FAR

		mov	si,WPPtr

;* if current waypoint is floating waypoint then restore previous waypoint

		cmp	si,OFFSET FloatWP	;floating waypoint selected?
		jne	@F			;no ->

		mov	si,OldWPPtr

		jmp	AdvanceOk

@@:		add	si,WAY_REC_SIZE		;di -> next waypoint

		cmp	si,EndWPPtr		;wrap around?
		jbe	AdvanceOk		;no ->

		mov	si,OFFSET WayList	;di -> first waypoint

AdvanceOk: 	mov	WPPtr,si

;* update waypoint range and bearing etc.

		call	UpdateWPData

;* reset auto-route vars

		mov	TrackLocked,0

		ret

AdvanceWP	ENDP

;----------------------------------------------------------------------------

;* SelectTgtWP - select target of opportunity waypoint (floating waypoint)
;*
;* pass: FloatWP
;* ret : WPPtr
;*       OldWPPtr
;* kill: assume all

SelectTgtWP	PROC	FAR

		test	FloatWP.WP_ATTR,WP_VALID	;valid?
		jz	ExitSelectWP			;no ->

		cmp	WPPtr,OFFSET FloatWP	;already selected?
		je	ExitSelectWP		;yes ->

		mov	ax,WPPtr
		mov	OldWPPtr,ax

		mov	WPPtr,OFFSET FloatWP

;* update waypoint range and bearing etc.

		call	UpdateWPData

;* reset auto-route vars

		mov	TrackLocked,0

ExitSelectWP:	ret

SelectTgtWP	ENDP

;----------------------------------------------------------------------------

;* CancelTgtWP - cancel target of opportunity waypoint (floating waypoint)
;*
;* pass: FloatWP
;*       OldWPPtr
;* ret : WPPtr
;* kill: assume all
;*
;* note: This is the only routine which may cancel the floating waypoint.

CancelTgtWP	PROC	FAR

;* always make waypoint invalid

		and	FloatWP.WP_ATTR,NOT WP_VALID	;(see note above)

;* only update if floating waypoint selected

		cmp	WPPtr,OFFSET FloatWP	;target waypoint selected?
		jne	ExitCancelWP		;no ->

;* restore previous waypoint

		mov	ax,OldWPPtr
		mov	WPPtr,ax

;* update waypoint range and bearing etc.

		call	UpdateWPData

;* reset auto-route vars

		mov	TrackLocked,0

ExitCancelWP:	ret

CancelTgtWP	ENDP

;----------------------------------------------------------------------------

;* UpdateTgtWP - tell AutoRoute that target waypoint has been modified
;*
;* pass: WPPtr
;* ret : nothing
;* kill: assume all

UpdateTgtWP	PROC	FAR

		cmp	WPPtr,OFFSET FloatWP	;target waypoint selected?
		jne	ExitUpdateWP		;no ->

;* update waypoint range and bearing etc.

		call	UpdateWPData

;* reset auto-route vars

		mov	TrackLocked,0

ExitUpdateWP:	ret

UpdateTgtWP	ENDP

;----------------------------------------------------------------------------

;* UpdateWPData - update waypoint range, bearing etc.
;*
;* pass: WPPtr
;* ret : WPRng
;*       WPBrg
;*       WPBrgFine
;*       WPRngNMiles
;*	 WPETA
;*	 WPTimeEarlyLate
;* kill: assume all

UpdateWPData	PROC	NEAR

		mov	WPETA,-1		;assume ETA invalid

		mov	WPTimeEarlyLate,-32768	;assume TEL invalid

		cmp	WayTotal,0	;any waypoints?
		ja	@F		;yes ->

		cmp	WPPtr,OFFSET FloatWP	;floating waypoint selected?
		_JNE	UpdateWPExit		;no ->

;------------------------
;* calc range and bearing
;------------------------

@@:		mov	si,OFFSET M_VIEW
		mov	di,WPPtr
		call	CalcRngBrgVP_WP

		mov	WORD PTR WPRng,ax
		mov	WORD PTR WPRng+2,dx
		mov	WPBrg,bx
		mov	WPBrgFine,bp

;------------
;* calc range (nautical miles)
;------------

		call	CalcNMiles

		mov	WPRngNMiles,ax

;----------
;* calc ETA (only valid if vtas > 0 and abs(ang diff) <= 45 degs)
;----------

		cmp	Vtas,0		;vtas > 0?
		_JE	UpdateWPExit	;no ->

		mov	ax,Hdg
		mov	dx,WPBrg
		call	CalcAngDiff

		cmp	ax,64		;abs(ang diff) <= 45 degs?
		ja	UpdateWPExit	;no ->

		mov	ax,WORD PTR WPRng
		mov	dx,WORD PTR WPRng+2

		mov	bx,Vtas

		call	CalcETA

		mov	WPETA,ax

;------------------------
;* calc time early / late
;------------------------

		mov	si,WPPtr

		test	[si].WP_ATTR,WP_COORD	;co-ordinated waypoint?
		jz	UpdateWPExit		;no ->

;* time early / late = waypoint time - (current time + ETA)

		mov	ax,WPETA
		mov	dx,100		;ETA * 100 secs
		mul	dx

		add	ax,WORD PTR FrameElapTime
		adc	dx,WORD PTR FrameElapTime+2

		mov	bx,ax
		mov	cx,dx

		mov	ax,[si].WP_TIME
		mov	dx,100		;waypoint time * 100 secs
		mul	dx

		sub	ax,bx
		sbb	dx,cx
		js	@F		;late ->

;* early (limit to +32767)

		mov	bp,32767	;assume limit

		cmp	dx,0		;> 65535?
		ja	SetTEL		;yes ->
		cmp	ax,32767	;> 32767?
		ja	SetTEL		;no ->

		mov	bp,ax

		jmp	SetTEL

;* late (limit to -32767)

@@:		mov	bp,-32767

		NEG32	dx,ax

		cmp	dx,0		;> 65535?
		ja	SetTEL		;yes ->
		cmp	ax,32767	;> 32767?
		ja	SetTEL		;yes ->

		neg	ax

		mov	bp,ax

SetTEL:		mov	WPTimeEarlyLate,bp

UpdateWPExit:	ret

UpdateWPData	ENDP

;----------------------------------------------------------------------------

;* CalcTurnDist - calc dist at which to start turning to next waypoint
;*		  (in order to keep on track)
;*
;* pass: nothing
;* ret : ax = TDist = turning dist
;* kill: assume all (except ax)

CalcTurnDist	PROC	NEAR

;---------------
;* calc ThetaABC = inside angle of vp(A) -> first wp(B) -> second wp(C)
;---------------

;* ThetaAB = bearing of wp(B) from vp(A)

		mov	si,OFFSET M_VIEW
		mov	di,WPPtr
		call	CalcRngBrgVP_WP

		mov	ThetaAB,bx

;* ThetaBC = bearing of wp(C) from wp(B)

		mov	si,WPPtr
		call	CalcNextWP
		call	CalcRngBrgWP_WP

		mov	ThetaBC,bx

;* ThetaABC = abs(256 - abs(ThetaAB - ThetaBC)) (0 .. 511 pdegs)

		mov	ax,ThetaAB
		sub	ax,bx		;ThetaAB - ThetaBC
		ABSV	ax		;abs(ThetaAB - ThetaBC)

		mov	dx,ax
		mov	ax,256
		sub	ax,dx		;256 - abs(ThetaAB - ThetaBC)

		ABSV	ax		;abs(256 - abs(ThetaAB - ThetaBC))

		mov	ThetaABC,ax

;-----------------------------
;* calc RTurn = turning radius
;-----------------------------

;* RTurn = min((Vtas^2 / 64) * 588 / 32768, 32767)

		mov	ax,Vtas

		SBOUND	ax,1360,10880

		mul	ax

		mov	bx,ax		;bx, cx = Vtas^2 * 64
		mov	cx,dx

		REPT	3		;*8 (*512)
		shl	ax,1
		rcl	dx,1
		ENDM

		add	ax,bx		;dx, ax = Vtas^2 * 576
		adc	dx,cx

		REPT	3		;/8 (*8)
		shr	cx,1
		rcr	bx,1
		ENDM

		add	ax,bx		;dx, ax = Vtas^2 * 584
		adc	dx,cx

		REPT	1		;/2 (*4)
		shr	cx,1
		rcr	bx,1
		ENDM

		add	ax,bx		;dx, ax = Vtas^2 * 588
		adc	dx,cx

		shl	ax,1		;*2/65536 = /32768
		rcl	dx,1
		shl	ax,1
		ROUNDUP	dx

		cmp	dx,32767
		jbe	@F
		mov	dx,32767

@@:		mov	RTurn,dx

;-------------------------------
;* calc TDist = turning distance
;-------------------------------

;* if ThetaABC >= 128 pdegs (90 degs) then
;*    theta = (256 - ThetaABC) / 2     		;***** obtuse angle *****
;*    TDist = RTurn * tan(theta / 2)
;* else
;*    theta = ThetaABC / 2			;***** acute angle *****
;*    TDist = RTurn * 32768 / tan(theta / 2)
;* endif

		cmp	ThetaABC,128	;< 90 degs?
		jb	@F		;yes ->

;------------------------------
;* ThetaABC >= 90 degs (obtuse)
;------------------------------

		mov	ax,256
		sub	ax,ThetaABC
		shr	ax,1
		call	Tangent		;dx = tan(ax) / 2 (refer to TRIG.ASM)
		shl	dx,1

		mov	ax,RTurn
		mul	dx
		FRACADJ	ax

		jmp	SetTDist

;----------------------------
;* ThetaABC < 90 degs (acute)
;----------------------------

@@:		mov	ax,ThetaABC
		shr	ax,1
		call	Tangent		;dx = tan(ax) / 2 (refer to TRIG.ASM)
		shl	dx,1
		mov	bx,dx

		mov	dx,RTurn
		xor	ax,ax

		shr	dx,1		;/2 for frac divide
		rcr	ax,1

		cmp	bx,dx		;div ok?
		jbe	TDistOv		;no ->

		div	bx

SetTDist:	mov	TDist,ax

		ret

;--------------------------------
;* if overflow then TDist = 65535
;--------------------------------

TDistOv:	mov	ax,65535

		jmp	SetTDist

CalcTurnDist	ENDP

;----------------------------------------------------------------------------

;* SortWPAlt - sort waypoint altitude authority
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all
;*
;* note: Call this routine with interrupts disabled.

SortWPAlt	PROC	NEAR

		mov	si,WPPtr

;-----------------------------------------
;* treat floating waypoint as special case
;-----------------------------------------

		cmp	si,OFFSET FloatWP	;floating waypoint?
		jne	@F			;no ->

		cmp	AltMode,ALT_TF		;already terrain following?
		_JE	ExitWPAlt		;yes, do not change ->

		cmp	AltMode,ALT_ACQUIRE	;already held?
		_JE	ExitWPAlt		;yes, do not change ->

;* acquire current altitude

		mov	TFAuto,0

		mov	AltMode,ALT_ACQUIRE

		mov	AAFlag,1

		mov	dx,ZftHi
		mov	ax,ZftLo
		mov	bx,10
		div	bx

		UBOUND	ax,MIN_AUTO_ALT,MAX_AUTO_ALT

		mov	AutoAlt,ax
		mov	AutoAltFine,0

		jmp	ExitWPAlt

;----------------------------------------------
;* acquire waypoint altitude or terrain follow?
;----------------------------------------------

@@:		test	WP_ATTR[si],WP_TF	;terrain follow?
		jnz	@F			;yes ->

;---------------------------
;* acquire waypoint altitude
;---------------------------

		mov	TFAuto,0

		mov	AltMode,ALT_ACQUIRE

		mov	AAFlag,1

		mov	dx,0
		mov	ax,WP_ZFT[si]
		mov	bx,10
		div	bx

		UBOUND	ax,MIN_AUTO_ALT,MAX_AUTO_ALT

		mov	AutoAlt,ax
		mov	AutoAltFine,0

		jmp	ExitWPAlt

;----------------------------
;* terrain follow to waypoint
;----------------------------

@@:		mov	AAFlag,0

		mov	AltMode,ALT_TF

		mov	TFAuto,1

		mov	ax,WP_ZFT[si]

		call	CalcTFRideIndex

ExitWPAlt:	ret

SortWPAlt	ENDP

;----------------------------------------------------------------------------

;* ScanAirfields - calc range and bearing of all airfields
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

ScanAirfields	PROC	NEAR

		mov	di,OFFSET AirfieldList

		mov	cx,NUM_AIRFIELDS

ScanAFLoop:	cmp	AF_XSEC[di],-1	;record in use?
		je	@F		;no ->
			  
		push	cx

;* calc range and bearing of airfield datum

		mov	si,OFFSET M_VIEW

		push	di
		call	CalcRngBrgVP_AF
		pop	di

		mov	AF_RNG_LO[di],ax
		mov	AF_RNG_HI[di],dx

		mov	AF_BRG[di],bx

;* calc range (nautical miles)

		call	CalcNMiles

		mov	AF_RNG[di],ax

;* calc ETA

		mov	ax,AF_RNG_LO[di]
		mov	dx,AF_RNG_HI[di]

		mov	bx,Vtas

		call	CalcETA

		mov	AF_ETA[di],ax

		pop	cx

@@:		add	di,AF_REC_SIZE

		loop	ScanAFLoop

		ret

ScanAirfields	ENDP

;----------------------------------------------------------------------------

;* UpdateILS - update ILS system
;*
;* pass: nothing
;* ret : ILS vars
;* kill: assume all

UpdateILS	PROC	NEAR

		mov	ILSActive,0	;assume ILS not active

;* altitude check (zft <= 8,191ft)

		cmp	ZftHi,0
		ja	ExitILS

		cmp	ZftLo,8191
		ja	ExitILS

		mov	si,OFFSET AirfieldList

		mov	cx,NUM_AIRFIELDS

AFLoop:		push	cx

		cmp	AF_XSEC[si],-1	;record in use?
		je	NextAF		;no ->

;* coarse range check

		cmp	AF_RNG[si],150	;within 15nm?
		jae	NextAF	      	;no ->

;* a/c pointing at airfield?

		mov	ax,Hdg
		mov	dx,AF_BRG[si]
		call	CalcAngDiff
		cmp	ax,128	     	;within +/-90 degs?
		jae	NextAF		;no ->

		mov	di,AF_ILS_PTR[si]

		mov	al,ILS_N
		call	CheckILS
		jc	InILSBeam

		mov	al,ILS_S
		call	CheckILS
		jc	InILSBeam

		mov	al,ILS_E
		call	CheckILS
		jc	InILSBeam

		mov	al,ILS_W
		call	CheckILS
		jc	InILSBeam

NextAF:		pop	cx

		add	si,AF_REC_SIZE

		loop	AFLoop

ExitILS:	ret

;* in ILS beam, break out of loop, tidy up stack, return

InILSBeam:    	pop	cx

		ret

UpdateILS	ENDP

;----------------------------------------------------------------------------
;* CheckILS - check if aircraft is in ILS beam
;*
;* pass: al = ILS flag
;*       si -> AIRFIELD data block
;*       di -> ILS data block
;* ret : cf = 1 = in ILS beam
;*       cf = 0 = not in ILS beam
;* kill: assume all (except si, di)
;*
;* note: Xac, Yac = aircraft position
;*       Xtd, Ytd = touchdown position

CheckILS	PROC	NEAR

		mov	ILSApproach,al

		mov	ILSAirfieldPtr,si

;* test if ILS is available and working

		and	al,ILS_AVAILABLE[di]	;available?
		and	al,AF_ILS_STATUS[si]	;working?
		_JZ	ILSFail			;no ->

;* select approach direction

		test	al,ILS_N
		jnz	SortNApproach

		test	al,ILS_S
		_JNZ	SortSApproach

		test	al,ILS_E
		_JNZ	SortEApproach

		test	al,ILS_W
		_JNZ	SortWApproach

		jmp	ILSFail

;---------------------------
SortNApproach	LABEL	NEAR
;---------------------------

;* range = Ytd - Yac
;* error = Xac - Xtd

;* calc range

		mov	cx,YSec		;-(ysec * 16384) + yft
		xor	bx,bx
		REPT	2
		sar	cx,1
		rcr	bx,1
		ENDM
		NEG32	cx,bx
		mov	bp,Yft
		add	bp,8192
		add	bx,bp
		adc	cx,0

		mov	dx,AF_YSEC[si]	;-(ysec * 16384) + yft
		xor	ax,ax
		REPT	2
		sar	dx,1
		rcr	ax,1
		ENDM
		NEG32	dx,ax
		mov	bp,ILS_N_TDOWN_Y[di]
		add	bp,8192
		add	ax,bp
		adc	dx,0

		sub	ax,bx
		sbb	dx,cx

		push	ax		;store range
		push	dx

;* calc localiser error

		mov	dx,AF_XSEC[si]	;xsec * 16384 + xft
		xor	ax,ax
		REPT	2
		sar	dx,1
		rcr	ax,1
		ENDM
		mov	bp,ILS_N_TDOWN_X[di]
		add	bp,8192
		add	ax,bp
		adc	dx,0

		mov	cx,XSec		;xsec * 16384 + xft
		xor	bx,bx
		REPT	2
		sar	cx,1
		rcr	bx,1
		ENDM
		mov	bp,Xft
		add	bp,8192
		add	bx,bp
		adc	cx,0

		sub	bx,ax
		sbb	cx,dx

		pop	dx		;restore range
		pop	ax

		jmp	ILSOk

;---------------------------
SortSApproach	LABEL	NEAR
;---------------------------

;* range = Yac - Ytd
;* error = Xtd - Xac

;* calc range

		mov	cx,AF_YSEC[si]	;-(ysec * 16384) + yft
		xor	bx,bx
		REPT	2
		sar	cx,1
		rcr	bx,1
		ENDM
		NEG32	cx,bx
		mov	bp,ILS_S_TDOWN_Y[di]
		add	bp,8192
		add	bx,bp
		adc	cx,0

		mov	dx,YSec		;-(ysec * 16384) + yft
		xor	ax,ax
		REPT	2
		sar	dx,1
		rcr	ax,1
		ENDM
		NEG32	dx,ax
		mov	bp,Yft
		add	bp,8192
		add	ax,bp
		adc	dx,0

		sub	ax,bx
		sbb	dx,cx

		push	ax		;store range
		push	dx

;* calc localiser error

		mov	dx,XSec		;xsec * 16384 + xft
		xor	ax,ax
		REPT	2
		sar	dx,1
		rcr	ax,1
		ENDM
		mov	bp,Xft
		add	bp,8192
		add	ax,bp
		adc	dx,0

		mov	cx,AF_XSEC[si]	;xsec * 16384 + xft
		xor	bx,bx
		REPT	2
		sar	cx,1
		rcr	bx,1
		ENDM
		mov	bp,ILS_S_TDOWN_X[di]
		add	bp,8192
		add	bx,bp
		adc	cx,0

		sub	bx,ax
		sbb	cx,dx

		pop	dx		;restore range
		pop	ax

		jmp	ILSOk

;---------------------------
SortEApproach	LABEL	NEAR
;---------------------------

;* range = Xtd - Xac
;* error = Ytd - Yac

;* calc range

		mov	cx,XSec		;xsec * 16384 + xft
		xor	bx,bx
		REPT	2
		sar	cx,1
		rcr	bx,1
		ENDM
		mov	bp,Xft
		add	bp,8192
		add	bx,bp
		adc	cx,0

		mov	dx,AF_XSEC[si]	;xsec * 16384 + xft
		xor	ax,ax
		REPT	2
		sar	dx,1
		rcr	ax,1
		ENDM
		mov	bp,ILS_E_TDOWN_X[di]
		add	bp,8192
		add	ax,bp
		adc	dx,0

		sub	ax,bx
		sbb	dx,cx

		push	ax		;store range
		push	dx

;* calc localiser error

		mov	dx,YSec		;-(ysec * 16384) + yft
		xor	ax,ax
		REPT	2
		sar	dx,1
		rcr	ax,1
		ENDM
		NEG32	dx,ax
		mov	bp,Yft
		add	bp,8192
		add	ax,bp
		adc	dx,0

		mov	cx,AF_YSEC[si]	;-(ysec * 16384) + yft
		xor	bx,bx
		REPT	2
		sar	cx,1
		rcr	bx,1
		ENDM
		NEG32	cx,bx
		mov	bp,ILS_E_TDOWN_Y[di]
		add	bp,8192
		add	bx,bp
		adc	cx,0

		sub	bx,ax
		sbb	cx,dx

		pop	dx		;restore range
		pop	ax

		jmp	ILSOk

;---------------------------
SortWApproach	LABEL	NEAR
;---------------------------

;* range = Xac - Xtd
;* error = Yac - Ytd

;* calc range

		mov	cx,AF_XSEC[si]	;xsec * 16384 + xft
		xor	bx,bx
		REPT	2
		sar	cx,1
		rcr	bx,1
		ENDM
		mov	bp,ILS_W_TDOWN_X[di]
		add	bp,8192
		add	bx,bp
		adc	cx,0

		mov	dx,XSec		;xsec * 16384 + xft
		xor	ax,ax
		REPT	2
		sar	dx,1
		rcr	ax,1
		ENDM
		mov	bp,Xft
		add	bp,8192
		add	ax,bp
		adc	dx,0

		sub	ax,bx
		sbb	dx,cx

		push	ax		;store range
		push	dx

;* calc localiser error

		mov	dx,AF_YSEC[si]	;-(ysec * 16384) + yft
		xor	ax,ax
		REPT	2
		sar	dx,1
		rcr	ax,1
		ENDM
		NEG32	dx,ax
		mov	bp,ILS_W_TDOWN_Y[di]
		add	bp,8192
		add	ax,bp
		adc	dx,0

		mov	cx,YSec		;-(ysec * 16384) + yft
		xor	bx,bx
		REPT	2
		sar	cx,1
		rcr	bx,1
		ENDM
		NEG32	cx,bx
		mov	bp,Yft
		add	bp,8192
		add	bx,bp
		adc	cx,0

		sub	bx,ax
		sbb	cx,dx

		pop	dx		;restore range
		pop	ax

;---------------------------
ILSOk		LABEL	NEAR
;---------------------------

;* dx, ax = range
;* cx, bx = localiser error

		mov	ILSRangeLo,ax
		mov	ILSRangeHi,dx

		mov	ILSErrorLo,bx
		mov	ILSErrorHi,cx

;* test for correct approach direction (range > 0ft) and (range < 65,536ft)

		test	dx,dx		;direction and range ok?
		jnz	ILSFail		;no ->

;* max error = range / 16

		REPT	4		;/16
		shr	ax,1
		ENDM

		ROUNDUP	ax

		mov	ILSMaxError,ax

		mov	bp,ax

;* check if localiser error < max error

		add	bp,LOCAL_OFFSET	;increase resolution towards touchdown point

		mov	ax,cx		;store error sign

		test	cx,cx
		jns	@F
		NEG32	cx,bx

@@:		test	cx,cx		;error > 65,535ft?
		jnz	ILSFail		;yes ->

		cmp	bx,bp		;error < max error?
		jae	ILSFail		;no ->

		cwd			;restore error sign
		xor	bx,dx
		sub	bx,dx

		mov	ILSLocalError,bx

;* calc localiser position = error * 32768 / max error

		mov	dx,bx
		xor	ax,ax
		sar	dx,1
		rcr	ax,1

		idiv	bp

		mov	ILSLocalPos,ax

		sub	bp,LOCAL_OFFSET	;restore max error

;* calc glide slope error (error = zft - max error)

		mov	ax,ZftLo
		sub	ax,bp

;* check if glide slope error < max error

		ABSV	ax

		cmp	ax,bp		;error < max error?
		jae	ILSFail		;no ->

		xor	ax,dx		;restore error sign
		sub	ax,dx

		mov	ILSGlideError,ax

;* calc glide slope position = error * 32768 / max error

		mov	dx,ax
		xor	ax,ax
		sar	dx,1
		rcr	ax,1

		idiv	bp

		mov	ILSGlidePos,ax

;* sort ILS display values (range, bearing and ETA)

		mov	ax,AF_RNG[si]
		mov	ILSRng,ax

		mov	ax,AF_BRG[si]
		mov	ILSBrg,ax

		mov	ax,AF_ETA[si]
		mov	ILSETA,ax

		mov	ILSActive,1

		stc		;cf = 1
		ret

ILSFail:	clc		;cf = 0
		ret

CheckILS	ENDP

;----------------------------------------------------------------------------

;* AutoApproach
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all
;*
;* note: This routine sets up parameters for AutoAltitude, AutoHeading and
;*       AutoThrottle so call AutoApproach before calling these routines.

;---------------------------
AppExit2	LABEL	NEAR		;<<<<< exit here if error <<<<<
;---------------------------

		mov	AppFlag,0	;disengage auto-approach

		mov	AppError,1	;set error

;---------------------------
AppExit1	LABEL	NEAR		;<<<<< exit here if disabled <<<<<
;---------------------------

		ret

AutoApproach	PROC	NEAR

		mov	al,AppFlag
		test	al,al		;auto-approach enabled
		xchg	al,AppLast	;new <-> old

		jz	AppExit1	;no ->

		xor	al,AppFlag	;just enabled?
		jz	SkipAppInit	;no ->

;* calc approach heading (fine pdegs)

		mov	al,ILSApproach

		mov	dx,0*128
		test	al,ILS_N	;north approach?
		jnz	@F		;yes ->

		mov	dx,256*128
		test	al,ILS_S	;south approach?
		jnz	@F		;yes ->

		mov	dx,128*128
		test	al,ILS_E	;east approach?
		jnz	@F		;yes ->

		mov	dx,384*128	;west approach

@@:		mov	AppHFine,dx

SkipAppInit:	mov	AppError,0	;clear error

;--------------------
;* ensure in ILS beam
;--------------------

		test	ILSActive,1	;in ILS?
		jz	AppExit2	;no ->

;---------------------
;* calc approach speed
;---------------------

;* look up speed wrt configuration (weight = 33,000lbs)

		mov	bl,CrntWingPos
		xor	bh,bh
		shl	bx,1		;*2
		shl	bx,1		;*4
		shl	bx,1		;*8 index

		mov	al,CrntFlapPos
		xor	ah,ah
		shl	ax,1		;*2 index

		add	bx,ax

		mov	bx,ApproachSpeed[bx]

;* if 25 degs sweep then
;*    add 5kts for every 2,048lbs above 33,000lbs
;* else
;*    add 7kts for every 2,048lbs above 33,000lbs
;* endif

		mov	ax,Weight
		sub	ax,33000
		MINM	ax

		mov	cl,11		;/2048
		shr	ax,cl

		ROUNDUP	ax

		mov	dx,ax

		shl	ax,1		;*2

		cmp	CrntWingPos,SWEEP_D_25	;25 degs sweep?
		je	@F			;yes ->

		add	ax,dx		;*3

@@:		shl	ax,1		;*4 or *6
		add	ax,dx		;*5 or *7

		add	ax,bx

		cli			;<<<<< IMPORTANT <<<<<

		mov	AutoVias,ax
		mov	AutoViasFine,0

		sti			;<<<<< IMPORTANT <<<<<

		ret

AutoApproach	ENDP

;----------------------------------------------------------------------------

;* UpdateRadar - update ground / air radar
;*
;* pass: RadarMode
;* ret : RadarMode
;* kill: assume all

UpdateRadar	PROC	NEAR

;* radar switching logic:-
;*
;* if radar ok then
;*    if select radar off then
;*       radar mode = off
;*    else
;*       if select air radar then
;*          radar mode = air
;*       else
;*          if variant not ADV then
;*             if select ground radar then
;*                radar mode = ground
;*             endif
;*          endif
;*       endif
;*    endif
;* else
;*    radar mode = off
;* endif

		test	SSF_Radar,1	;radar damaged?
		jz	@F		;no ->

		mov	RadarMode,NUL_RADAR

		jmp	RadarOk

@@:		KTEST	KF_RadarOff	;switch radar off?
		jz	@F		;no ->

		mov	RadarMode,NUL_RADAR

		jmp	RadarOk

@@:		KTEST	KF_AirRadar	;select air radar?
		jz	@F		;no ->

;* set up air to air combat configuration

		mov	RadarMode,AIR_RADAR

		call	SelectRadarMFD

		jmp	RadarOk

@@:		cmp	TornadoType,ADV_TORNADO	;ADV variant?
		je	RadarOk			;yes ->

		KTEST	KF_GndRadar	;select ground radar?
		jz	RadarOk		;no ->

;* set up ground attack configuration

		mov	RadarMode,GND_RADAR

		call	SelectRadarMFD

RadarOk: 	ret

UpdateRadar	ENDP

;----------------------------------------------------------------------------

;* UpdateAppProg - update approach progress indicator
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all
;*
;* note: The approach progress indicator only includes the middle marker. The
;*       middle marker is placed 3,500ft from touchdown. This generates a
;*       medium tone Morse signal of dash-dot-dash per second and an amber
;*       lamp flashes in sequence. 

UpdateAppProg	PROC	NEAR

;* check if in ILS beam and ILS range 3,000 .. 4,000ft

		xor	al,al		;assume not in fan marker beam

		test	ILSActive,1	;in ILS	beam?
		jz	@F		;no ->

		cmp	ILSRangeHi,0	;range > 65,535ft?
		ja	@F		;yes ->

		cmp	ILSRangeLo,4000	;within upper limit?
		ja	@F		;no ->

		cmp	ILSRangeLo,3000	;within lower limit?
		jb	@F		;no ->

		mov	al,1		;in fan marker beam

@@:		test	al,al		;in fan marker?

		xchg	al,AppProgFlag	;new <-> old

		jz	ExitAppProg	;no ->

		test	al,al		;just enabled?
		jnz	@F		;no ->

		mov	AppProgSeq,0

		mov	AppProgTimer,MORSE_DASH

		call	MorseDashSound

		jmp	ExitAppProg

;* update timer and sequence

@@:		mov	ax,AppProgTimer
		sub	ax,LastFrame
		jnc	SetAPTimer	;still timing ->

		mov	al,AppProgSeq
		inc	al
		and	al,11b
		mov	AppProgSeq,al

		cmp	al,00b		;dash?
		jne	@F		;no ->

		call	MorseDashSound

		mov	ax,MORSE_DASH

		jmp	SetAPTimer

@@:		cmp	al,10b		;dot?
		jne	@F		;no ->

		call	MorseDotSound

@@:		mov	ax,MORSE_DOT	;dot or pause

SetAPTimer:	mov	AppProgTimer,ax

ExitAppProg:	ret

UpdateAppProg	ENDP

;----------------------------------------------------------------------------

;* UpdateAirRadar
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

UpdateAirRadar	PROC	NEAR

		mov	NumRadarTracks,0	;assume radar off

		mov	AirRadarPtr,OFFSET AirRadarTracks

		cmp	RadarMode,AIR_RADAR	;air radar on?
		je	ContAirRadar		;yes ->

		mov	AirTgtPtr,-1

		jmp	ExitAirRadar		;no ->

;----------------------------
;* calc air radar scan centre
;----------------------------

;* copy aircraft datum

ContAirRadar: 	COPY_VP	ARAD_VIEW,M_VIEW

;* lookup offset wrt radar range

		mov	bx,AirRadarRng

		mov	bp,AirRadarOffset[bx]

;* rotate offset wrt hdg (note: y = offset, x = 0)

		mov	bx,ARAD_VIEW.VP_HDG

		SINCOS	si,di,bx	;si = sin(hdg), di = cos(hdg)

;* yr = y.cos(hdg)

		mov	ax,bp
		imul	di
		shl	ax,1		;adjust after fractional multiply
		rcl	dx,1
		shl	ax,1		;1/2 bit round up
		adc	dx,0

		mov	ax,dx
		cwd
		mov	bx,ax
		mov	cx,dx

;* xr = y.sin(hdg)

		mov	ax,bp
		imul	si
		shl	ax,1		;adjust after fractional multiply
		rcl	dx,1
		shl	ax,1		;1/2 bit round up
		adc	dx,0

		mov	ax,dx
		cwd

;* scale up xr and yr (original offset is /4 scaled)

		REPT	2		;*4
		shl	ax,1
		rcl	dx,1
		shl	bx,1
		rcl	cx,1
		ENDM

;* offset viewpoint

		mov	si,OFFSET ARAD_VIEW
		call	MoveViewpoint

;---------------------------
;* calc scan size and offset
;---------------------------

		mov	bx,AirRadarRng
		mov	ax,AirRadarScan[bx]
		mov	ScanSize,ax

		shr	ax,1
		neg	ax
		mov	ScanOffset,ax

;----------------
;* air radar scan
;----------------

;* for y sector = -ScanOffset to ScanOffset

		mov	cx,ScanSize
		mov	di,ScanOffset

ScanYLoop:	push	cx
		push	di

;* for x sector = -ScanOffset to ScanOffset

		mov	cx,ScanSize
		mov	si,ScanOffset

ScanXLoop:	push	cx
		push	si
		push	di

;* check for occupied sector

		mov	ax,ARAD_VIEW.VP_XSEC
		add	ax,si		;x sec = vp x sec + x sec offset

		mov	dx,ARAD_VIEW.VP_YSEC
		add	dx,di		;y sec = vp y sec + y sec offset

		call	LocateMobiles
		jc	SkipSector	;no mobiles in sector ->

;* scan mobiles in sector

ScanMobiles:	cmp	si,-1		;end of list?
		je	SkipSector	;yes ->

		cmp	si,OFFSET M_MOBILE	;Tornado?
		je	SkipMobile		;yes ->

		push	si
		call	TrackMobile
		pop	si

SkipMobile:	mov	si,[si].MOB_LINK_PTR	;next mobile

		jmp	ScanMobiles

;* next x sector

SkipSector:	pop	di
		pop	si
		pop	cx
		inc	si		;x = x + 1
		loop	ScanXLoop

;* next y sector

		pop	di
		pop	cx
		inc	di		;y = y + 1
		loop	ScanYLoop

;---------------------------------------------
;* check designated target still radar visible
;---------------------------------------------

		cmp	AirTgtPtr,-1	;any target designated?
		je	TrackOk		;no ->

		mov	cx,NumRadarTracks

		jcxz	LostTrack	;no tracks ->

		mov	si,OFFSET AirRadarTracks

		mov	ax,AirTgtPtr

@@:		cmp	ax,[si].ARAD_PTR	;found target?
		je	TrackOk			;yes ->

		add	si,ARAD_REC_SIZE

		loop	@B

LostTrack:	mov	AirTgtPtr,-1

;------------------------
;* check num radar tracks
;------------------------

TrackOk:  	cmp	NumRadarTracks,0	;any tracks?
		_JE	ExitAirRadar		;no ->

;--------------------------
;* check cancel designation
;--------------------------

		KTEST	KF_CancelAirTgt
		jz	@F

		mov	AirTgtPtr,-1

		jmp	ExitAirRadar

;-------------------------
;* check cycle air targets
;-------------------------

@@:		KTEST	KF_CycleAirTgt	;cycle air targets?
		jz	@F		;no ->

		cmp	AirTgtPtr,-1	;designated target?
		je	@F		;no (default to boresight) ->

		call	CycleTargets

		jmp	AirTgtData

;------------------------------
;* check bore sight designation
;------------------------------

@@:		KTEST	KF_BoreSight	;bore sight designate?
		jz	AirTgtData	;no ->

		call	BoreSight

;-------------------------
;* calc target slant range (if valid target)
;-------------------------

AirTgtData:	cmp	AirTgtPtr,-1	;valid target?
		je	ExitAirRadar	;no ->

		mov	si,OFFSET M_VIEW

		mov	di,AirTgtPtr
		add	di,MOB_REC_SIZE	;di -> target VIEWPOINT data

		call	CalcSlantRange

		mov	WORD PTR AirTgtRange,ax
		mov	WORD PTR AirTgtRange+2,dx

;--------------------------------
;* calc air target display values
;--------------------------------

		mov	si,AirTgtPtr

;* calc range (nm)

		mov	bx,6076
		div	bx

		cmp	dx,6076/2	;1/2 bit round up
		cmc
		adc	ax,0

		mov	DispAirTgtRng,ax

;* calc alt (1000's ft)

		mov	ax,WORD PTR _VP_ZFT_LO[si]
		mov	dx,WORD PTR _VP_ZFT_HI[si]
		mov	bx,1000
		div	bx

		cmp	dx,1000/2	;1/2 bit round up
		cmc
		adc	ax,0

		mov	DispAirTgtAlt,ax

;* calc IAS (kts)

		push	si
		call	GetDroneSpeed
		pop	si

		mov	bp,ax

		mov	ax,WORD PTR _VP_ZFT_LO[si]
		mov	dx,WORD PTR _VP_ZFT_HI[si]

		call	CalcVias
		call	CalcVkts

		cmp	ax,999		;limit max display value
		jbe	@F
		mov	ax,999

@@:		mov	DispAirTgtVel,ax

;* calc hdg

		mov	ax,_VP_HDG[si]

		mov	DispAirTgtHdg,ax

ExitAirRadar:	ret

UpdateAirRadar	ENDP

;----------------------------------------------------------------------------

;* TrackMobile - check if mobile is radar visible
;*
;* pass: si -> mobile + viewpoint data
;* ret : nothing
;* kill: assume all

TrackMobile	PROC	NEAR

		cmp	NumRadarTracks,NUM_TRACKS	;any records available?
		_JE	ExitTrack			;no ->

		mov	di,AirRadarPtr

		mov	[di].ARAD_PTR,si	;store ptr

		add	si,MOB_REC_SIZE		;si -> viewpoint

;--------------------------------------
;* check if mobile is in ground clutter	(therefore ignore trucks / trains)
;--------------------------------------

		cmp	WORD PTR [si].VP_ZFT_HI,0	;alt > 65535ft?
		ja	@F				;yes ->

		cmp	WORD PTR [si].VP_ZFT_LO,100	;alt <= 100ft?
		_JBE	ExitTrack			;yes ->

;----------------------------------
;* calc range and bearing of mobile
;----------------------------------

@@:		push	si
		push	di

		mov	di,OFFSET M_VIEW

		xchg	si,di

		call	CalcRngBrgVP_VP

		pop	di
		pop	si

		mov	WORD PTR [di].ARAD_RNG_LO,ax
		mov	WORD PTR [di].ARAD_RNG_HI,dx

		mov	[di].ARAD_BRG,bx

;---------------------------------------
;* check mobile in air radar cone (plan)
;---------------------------------------

;* calc ang diff(hdg, brg)

		mov	ax,M_VIEW.VP_HDG
		mov	dx,bx

		call	CalcAngDiff

;* expand pointed end of cone (else close range mobiles always disappear)
;*
;* note: Use a minimum cone angle of 60degs else mobiles disappear before
;*       they reach air radar display edge.
;*
;* if range <= 4000ft then
;*    check abs(ang diff) <= 90degs
;* else
;*    check abs(ang diff) <= 60degs
;* endif

		mov	bp,85		;60degs (assume not close range)

		cmp	WORD PTR [di].ARAD_RNG_HI,0	;range > 65535?
		ja	@F				;yes ->
		cmp	WORD PTR [di].ARAD_RNG_LO,4000	;range <= 4000?
		ja	@F		  	    	;no ->

		mov	bp,128		;90degs (close range)

@@:		cmp	ax,bp		;abs(ang diff) <= cone angle?
		_JA	ExitTrack	;no ->

		xor	ax,dx
		sub	ax,dx
		and	ax,511

		mov	TmpAngDiff,ax

;--------------------------------------------
;* check mobile in air radar cone (elevation)
;--------------------------------------------

;* calc abs(z err)

		mov	ax,WORD PTR [si].VP_ZFT_LO
		mov	dx,WORD PTR [si].VP_ZFT_HI

		sub	ax,WORD PTR M_VIEW.VP_ZFT_LO
		sbb	dx,WORD PTR M_VIEW.VP_ZFT_HI

		mov	WORD PTR TmpZErr,ax
		mov	WORD PTR TmpZErr+2,dx

		jns	@F

		NEG32	dx,ax

@@:		push	ax		;store abs(z err)
		push	dx

;* scale down range and abs(z err) < 32768

		mov	bx,WORD PTR [di].ARAD_RNG_LO
		mov	cx,WORD PTR [di].ARAD_RNG_HI

		xor	bp,bp		;scale count = 0

@@:		test	cx,cx		;range > 65535?
		jz	@F		;no ->
		shr	cx,1		;range / 2
		rcr	bx,1
		shr	dx,1		;abs(z err) / 2
		rcr	ax,1
		inc	bp		;inc scale count
		jmp	@B

@@:		cmp	bx,32768	;range < 32768?
		jb	@F		;yes ->
		shr	bx,1		;range / 2
		shr	dx,1		;abs(z err) / 2
		rcr	ax,1
		inc	bp		;inc scale count

@@:		test	dx,dx		;abs(z err) > 65535?
		jz	@F		;no ->
		shr	bx,1		;range / 2
		shr	dx,1		;abs(z err) / 2
		rcr	ax,1
		inc	bp		;inc scale count
		jmp	@B

@@:		cmp	ax,32768	;abs(z err) < 32768?
		jb	@F		;yes ->
		shr	bx,1		;range / 2
		shr	ax,1		;abs(z err) / 2
		inc	bp		;inc scale count

;* ax = scaled abs(z err)
;* bx = scaled range

@@:		mov	TmpScaledRng,bx
		mov	TmpScaledCnt,bp

;* expand pointed end of cone (else close range mobiles always disappear)

		pop	dx		;restore abs(z err) (unscaled)
		pop	cx

		test	dx,dx		;abs(z err) > 65535ft?
		jnz	@F		;yes ->
		cmp	cx,1000		;abs(z err) <= 1000ft?
		jbe	SkipConeElev	;yes ->
		
;* select abs(z err)
;* case = range
;*    pitch = 45
;* case < range
;*    pitch = arctan(abs(z err) / range)
;* case > range
;*    pitch = 90 - arctan(range / abs(z err))
;* endselect


@@:		cmp	ax,bx		;abs(z err) = range?
		jne	@F		;no ->

		mov	ax,64*128	;45 degs

		jmp	ContConeElev

@@:		ja	@F		;abs(z err) > range ->

;* pitch = arctan(abs(z err) / range)

		mov	dx,ax
		xor	ax,ax

		shr	dx,1		;/2 for bin frac result
		rcr	ax,1

		div	bx

		call	FastArcTan

		jmp	ContConeElev

;* pitch = 128 - arctan(range / abs(z err))

@@:		mov	dx,bx
		mov	bx,ax
		xor	ax,ax

		shr	dx,1		;/2 for bin frac result
		rcr	ax,1

		div	bx

		call	FastArcTan

		mov	dx,128*128
		xchg	ax,dx
		sub	ax,dx

ContConeElev:	cmp	WORD PTR TmpZErr+2,0	;neg pitch?
		jge	@F			;no ->

		neg	ax

;* check in cone

@@:		mov	dx,PFine
		add	dx,64*128	;pitch + 45degs

		cmp	ax,dx		;in cone?
		_JG	ExitTrack	;no ->

		sub	dx,128*128	;pitch - 45degs

		cmp	ax,dx		;in cone?
		_JL	ExitTrack	;no ->

;--------------------
;* radar shadow check
;--------------------

SkipConeElev:	push	si
		push	di
		call	ShadowCheck
		pop	di
		pop	si
		_JC	ExitTrack	;non-visible (in radar shadow) ->

;------------------
;* calc crt co-ords
;------------------

;* x = range * sin(ang diff)
;* y = range * cos(ang diff)

		push	si
		push	di

		mov	bx,TmpAngDiff

		SINCOS	si,di,bx

		mov	ax,TmpScaledRng
		imul	di
		FRACADJ	ax		;y = range * cos(ang diff)
		cwd
		mov	bx,ax
		mov	cx,dx

		mov	ax,TmpScaledRng
		imul	si
		FRACADJ	ax		;x = range * sin(ang diff)
		cwd

;* scale up x and y

		mov	bp,TmpScaledCnt

		test	bp,bp		;scale up?
		jz	XYScaleOk	;no ->

@@:		shl	ax,1
		rcl	dx,1

		shl	bx,1
		rcl	cx,1

		dec	bp
		jnz	@B

;* convert x and y to crt co-ords

XYScaleOK:	pop	di

		mov	si,AirRadarRng

		mov	bp,XDivVals[si]
		idiv	bp
		mov	bp,YDivVals[si]

		pop	si

		cmp	ax,-32		;x in range?
		jl	ExitTrack	;no ->
		cmp	ax,31		;x in range?
		jg	ExitTrack	;no ->

		add	ax,32

		mov	[di].ARAD_XCRT,ax

		mov	dx,cx
		mov	ax,bx

		idiv	bp

		cmp	ax,47		;y in range?
		jg	ExitTrack	;no ->

		mov	dx,47		;flip orientation
		sub	dx,ax

		mov	[di].ARAD_YCRT,dx

;-----------------
;* next track data
;-----------------

		add	AirRadarPtr,ARAD_REC_SIZE

		inc	NumRadarTracks

ExitTrack:	ret

TrackMobile	ENDP

;----------------------------------------------------------------------------

;* ShadowCheck - check if mobile is in radar shadow
;*
;* pass: M_VIEW 
;*	 si -> mobile VIEWPOINT
;*       di -> target ARAD_TRACK
;*	 FlatDx (from CalcRngBrgVP_VP)
;*	 FlatDy (from CalcRngBrgVP_VP)
;*	 TmpZErr
;* ret : cf = 0 = visible
;*	 cf = 1 = non-visible (in radar shadow)
;* kill: assume all (except cf)

ShadowCheck	PROC	NEAR

;-------------------------------
;* quick radar visibility checks
;-------------------------------

;* target always visible if Tornado altitude > 65535ft

		cmp	WORD PTR M_VIEW.VP_ZFT_HI,0	;alt > 65535ft?
		_JA	RadarVis			;yes ->

;* target always visible if target altitude > 65535ft

		cmp	WORD PTR [si].VP_ZFT_HI,0	;alt > 65535ft?
		_JA	RadarVis			;yes ->

;-------------------------
;* copy M_VIEW to TMP_VIEW
;-------------------------

		push	si
		push	di
		COPY_VP	TMP_VIEW,M_VIEW
		pop	di
		pop	si

;------------------------------
;* select shadow test wrt range
;------------------------------

		cmp	WORD PTR [di].ARAD_RNG_HI,0	;range > 65535ft?
		_JA	LongRangeCheck			;yes ->

		cmp	WORD PTR [di].ARAD_RNG_LO,8191	;range > 8191ft?
		ja	MedRangeCheck			;yes ->

;---------------------------
ShortRangeCheck	LABEL	NEAR		;short range shadow check
;---------------------------

;* calc Dz = z error / 8

		mov	ax,WORD PTR TmpZErr
		mov	dx,WORD PTR TmpZErr+2

		REPT	3
		sar	dx,1
		rcr	ax,1
		ENDM

		mov	WORD PTR TmpDz,ax
		mov	WORD PTR TmpDz+2,dx

;* calc sample dist (Dx / 8, Dy / 8)

		mov	ax,WORD PTR FlatDx
		mov	dx,WORD PTR FlatDx+2

		mov	bx,WORD PTR FlatDy
		mov	cx,WORD PTR FlatDy+2

		REPT	3
		sar	dx,1
		rcr	ax,1
		sar	cx,1
		rcr	bx,1
		ENDM

		mov	bp,7		;loop count

		jmp	ContShadow

;---------------------------
MedRangeCheck	LABEL	NEAR		;medium range shadow check
;---------------------------

;* calc Dz = z error / 16

		mov	ax,WORD PTR TmpZErr
		mov	dx,WORD PTR TmpZErr+2

		REPT	4
		sar	dx,1
		rcr	ax,1
		ENDM

		mov	WORD PTR TmpDz,ax
		mov	WORD PTR TmpDz+2,dx

;* calc sample dist (Dx / 16, Dy / 16)

		mov	ax,WORD PTR FlatDx
		mov	dx,WORD PTR FlatDx+2

		mov	bx,WORD PTR FlatDy
		mov	cx,WORD PTR FlatDy+2

		REPT	4
		sar	dx,1
		rcr	ax,1
		sar	cx,1
		rcr	bx,1
		ENDM

		mov	bp,15		;loop count

		jmp	ContShadow

;---------------------------
LongRangeCheck	LABEL	NEAR		;long range shadow check
;---------------------------

;* calc Dz = z error / 32

		mov	ax,WORD PTR TmpZErr
		mov	dx,WORD PTR TmpZErr+2

		REPT	5
		sar	dx,1
		rcr	ax,1
		ENDM

		mov	WORD PTR TmpDz,ax
		mov	WORD PTR TmpDz+2,dx

;* calc sample dist (Dx / 32, Dy / 32)

		mov	ax,WORD PTR FlatDx
		mov	dx,WORD PTR FlatDx+2

		mov	bx,WORD PTR FlatDy
		mov	cx,WORD PTR FlatDy+2

		REPT	5
		sar	dx,1
		rcr	ax,1
		sar	cx,1
		rcr	bx,1
		ENDM

		mov	bp,31		;loop count

;-------------------
;* shadow check loop
;-------------------

ContShadow:	mov	SampleCntr,0

ShadowLoop:	push	ax
		push	bx
		push	cx
		push	dx
		push	bp

		mov	si,OFFSET TMP_VIEW
		call	MoveViewpoint

		mov	ax,WORD PTR TMP_VIEW.VP_ZFT_LO
		mov	dx,WORD PTR TMP_VIEW.VP_ZFT_HI

		add	ax,WORD PTR TmpDz
		adc	dx,WORD PTR TmpDz+2

		jns	@F		;above ground ->

		xor	ax,ax

@@:		mov	WORD PTR TMP_VIEW.VP_ZFT_LO,ax

;* (not expecting zft to exceed 65535, therefore ignore high word)

		cmp	ax,256*15	;alt > max gnd ht?
		ja	AltOk	 	;yes ->

;* use fine check on nearer samples (0 .. 15 use fine check)

		cmp	SampleCntr,16 	;fine or coarse check?
		jae	@F		;coarse ->

		call	CalcGndHeight	;(fine check)

		jmp	CheckAlt

@@:		call	QCalcGndHeight	;(coarse check)

CheckAlt:	cmp	WORD PTR TMP_VIEW.VP_ZFT_LO,ax	;alt > gnd ht?

AltOk:		pop	bp
		pop	dx
		pop	cx
		pop	bx
		pop	ax

		jbe	RadarNonVis    	;alt <= gnd ht ->

		inc	SampleCntr	;next test
		cmp	SampleCntr,bp 	;loop end?
		jb	ShadowLoop	;no ->

;---------------------------
RadarVis	LABEL	NEAR
;---------------------------

		clc			;cf = 0 = visible
		ret

;---------------------------
RadarNonVis	LABEL	NEAR
;---------------------------

		stc			;cf = 1 = non-visible
		ret

ShadowCheck	ENDP

;----------------------------------------------------------------------------

;* BoreSight - bore sight designate
;*
;* pass: nothing
;* ret : AirTgtPtr
;* kill: assume all

BoreSight	PROC	NEAR

;----------------
;* store viewmode
;----------------

		mov	ax,ViewMode
		mov	bl,ClipWndwYOrg
		mov	cx,ClipWndwXOrg

		push	ax
		push	bx
		push	cx

;--------------
;* set viewmode 
;--------------

		mov	ax,EXT_VIEWMODE
		call	SetViewMode

;----------------------------
;* calc transformation matrix
;----------------------------

		mov	si,OFFSET M_VIEW
		call	CalcTransMatrix

;--------------
;* scan targets
;--------------

;* init bore sight error to worst case

		mov	WORD PTR BoreSightError,0ffffh
		mov	WORD PTR BoreSightError+2,0ffffh

;* init loop vars

		mov	cx,NumRadarTracks

		mov	si,OFFSET AirRadarTracks

TargetLoop:	push	cx
		push	si

		mov	si,[si].ARAD_PTR	;si -> MOBILE + VIEWPOINT

;* designate enemy targets only

		cmp	_DRONE_SIDE[si],ENEMY
		jne	NextTarget

;* calc unclipped CRT co-ords of target

		add	si,MOB_REC_SIZE		;si -> VIEWPOINT

		call	CalcTgtRelCo
		jc	NextTarget	;error ->

		call	CalcEyeCoords

		mov	Xe[0],ax
		mov	Ye[0],bx
		mov	Ze[0],cx

		call	XCalcUnclipCRT
		jc	NextTarget	;error ->

;* offset wrt screen centre

		sub	cx,320/2
		sub	bx,192/2

;* calc error = sum of squares (x crt * x crt + y crt * y crt)

		mov	ax,cx

		imul	ax		;x crt * x crt

		mov	cx,dx
		xchg	bx,ax

		imul	ax		;y crt * y crt

		add	ax,bx		;sum of squares
		adc	dx,cx

;* if error < previous error then designate target

		cmp	dx,WORD PTR BoreSightError+2
		ja	NextTarget
		jb	@F

		cmp	ax,WORD PTR BoreSightError
		jae	NextTarget

@@:		mov	WORD PTR BoreSightError,ax
		mov	WORD PTR BoreSightError+2,dx

		pop	si

		mov	ax,[si].ARAD_PTR
		mov	AirTgtPtr,ax

		push	si

NextTarget:	pop	si
		pop	cx

		add	si,ARAD_REC_SIZE

		loop	TargetLoop

;------------------
;* restore viewmode
;------------------

		pop	cx
		pop	bx
		pop	ax

		call	SetViewMode

		ret

BoreSight	ENDP

;----------------------------------------------------------------------------

;* CycleTargets
;*
;* pass: AirTgtPtr
;* ret : AirTgtPtr
;* kill: assume all
;*
;* note: Only call if AirTgtPtr <> -1 (ie. target designated).

CycleTargets	PROC	NEAR

;* check > 1 target

		cmp	NumRadarTracks,1
		jbe	ExitCycle

;* calc list end ptr

		mov	ax,NumRadarTracks
		mov	dx,ARAD_REC_SIZE
		mul	dx
		mov	bp,OFFSET AirRadarTracks
		add	bp,ax

;* init loop vars

		mov	ax,AirTgtPtr
		mov	cx,NumRadarTracks
		mov	si,OFFSET AirRadarTracks

;* search for current designation

@@:		cmp	ax,[si].ARAD_PTR
		je	@F

		add	si,ARAD_REC_SIZE

		loop	@B

		jmp	ExitCycle	;(should never happen)

;* found current designation, cycle to next enemy target (with wrap around)

@@:		add	si,ARAD_REC_SIZE

		cmp	si,bp		;end of list?
		jb	@F		;no ->

		mov	si,OFFSET AirRadarTracks

@@:		mov	cx,NumRadarTracks
		dec	cx

CycleLoop:	mov	di,[si].ARAD_PTR

		cmp	_DRONE_SIDE[di],ENEMY
		je	CycleOk

		add	si,ARAD_REC_SIZE

		cmp	si,bp
		jb	@F

		mov	si,OFFSET AirRadarTracks

@@:		loop	CycleLoop

		jmp	ExitCycle

CycleOk:	mov	AirTgtPtr,di

ExitCycle:	ret

CycleTargets	ENDP

;----------------------------------------------------------------------------

;* UpdateRWR - update radar warning receiver
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all
;*
;* note: RWR should always be active (even if damaged) as the data gathered
;*	 is useful for other gameplay elements (ie. tripping SAMs and AAA).
;*	 If the RWR is damaged then do not update display, make alert sound
;*       or pass data to ALARM missiles etc.

UpdateRWR	PROC	NEAR

;------------
;* initialize
;------------

		mov	ax,NumRWRThreats
		mov	OldRWRThreats,ax

		xor	ax,ax

		mov	NumRWRThreats,ax
		mov	ActiveSAMCntr,ax
		mov	RWRThreatIndex,ax
		mov	RWRThreatFlags,al

;-----------------------------------
;* scan for EWR, SAM and AAA threats
;-----------------------------------

		call	ScanEWR
		call	ScanSAM
		call	ScanAAA

;----------------------
;* check if RWR damaged
;----------------------

		test	SSF_RWR,1
		jnz	ExitRWR

;-----------------------------
;* scan for AC and MSL threats
;-----------------------------

		call	ScanAC
	   	call	ScanMSL

;-----------------------------
;* sound alert if more threats
;-----------------------------

		mov	ax,OldRWRThreats
		cmp	ax,NumRWRThreats
		jae	ExitRWR

		call	RWRAlertSound

ExitRWR:	ret

UpdateRWR	ENDP

;----------------------------------------------------------------------------

;* ScanEWR - scan for EWR threats
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all
;*
;* note: This routine will only locate one EWR threat.

ScanEWR		PROC	NEAR

;--------------------------------------------
;* check space available in RWR threat buffer
;--------------------------------------------

		cmp	NumRWRThreats,NUM_RWR_THREATS
		_JE	ExitEWR

;------------------------
;* check if on active map
;------------------------

		cmp	ModelMapIndex,-1
		_JE	ExitEWR

		mov	bp,ModelMapIndex

;------------------------------------
;* check if enemy EWR cover in sector (enemy EWR floor > 0)
;------------------------------------

		mov	al,EWRFloorLayer1[bp]
		and	ax,E_EWR_FLOOR
		_JZ	ExitEWR

;--------------------------
;* check if above EWR floor
;--------------------------

		xchg	al,ah		;floor * 256ft

		cmp	ZftHi,0
		ja	@F
		cmp	ZftLo,ax
		ja	@F

		jmp	ExitEWR

;--------------------------
;* sort ground / mobile EWR
;--------------------------

@@:		mov	al,SctrGameLayer1[bp]

		and	al,SECT_EWR_NUM

		CALC_EWR_INDEX

		mov	si,EWRTable[bx].EWR_PTR

		cmp	EWRTable[bx].EWR_TYPE,EWR_GROUND
		jne	SortMobileEWR

;---------------------------
SortGroundEWR	LABEL	NEAR
;---------------------------

		mov	ax,SEG SectorDataStart
		mov	ds,ax

;* check EWR in play

		test	[si].GND_ANIM,OBJECT_DEAD
		jnz	EWRDead

;* sort EWR viewpoint xft, yft

		mov	ch,[si].GND_XGRID
		xor	cl,cl
		sub	cx,8192

		mov	dh,[si].GND_YGRID
		xor	dl,dl
		sub	dx,8192

		jmp	EWROk

;---------------------------
SortMobileEWR	LABEL	NEAR
;---------------------------

		mov	ax,SEG MSctrDataStart
		mov	ds,ax

;* check EWR in play

		test	[si].STAT_ANIM,OBJECT_DEAD
		jnz	EWRDead

;* sort EWR viewpoint xft, yft

		mov	cx,[si].STAT_XFT
		mov	dx,[si].STAT_YFT

		jmp	EWROk

;---------------------------
EWRDead		LABEL	NEAR
;---------------------------

		mov	ax,DATA
		mov	ds,ax

		jmp	ExitEWR

;---------------------------
EWROk		LABEL	NEAR
;---------------------------

		mov	ax,DATA
		mov	ds,ax

		mov	RWR_VIEW.VP_XFT,cx
		mov	RWR_VIEW.VP_YFT,dx

;---------------------
;* sort EWR xsec, ysec
;---------------------

		xor	ah,ah

		mov	al,EWRTable[bx].EWR_XSEC
		mov	RWR_VIEW.VP_XSEC,ax

		mov	al,EWRTable[bx].EWR_YSEC
		mov	RWR_VIEW.VP_YSEC,ax

;----------------------------
;* calc EWR range and bearing
;----------------------------

		mov	si,OFFSET M_VIEW
		mov	di,OFFSET RWR_VIEW
		call	CalcRngBrgVP_VP

;----------------------------------
;* enter EWR into RWR threat buffer
;----------------------------------

		mov	bp,RWRThreatIndex

		mov	RWRThreats[bp].RWR_THREAT,THREAT_EWR

		mov	WORD PTR RWRThreats[bp].RWR_RNG_LO,ax
		mov	WORD PTR RWRThreats[bp].RWR_RNG_HI,dx

;* calc angular difference

		mov	ax,Hdg
		mov	dx,bx
		call	CalcAngDiff
		xor	ax,dx
		sub	ax,dx
		and	ax,511

		mov	RWRThreats[bp].RWR_DIR,ax

		mov	ax,RWR_VIEW.VP_XSEC
		mov	RWRThreats[bp].RWR_XSEC,ax

		mov	ax,RWR_VIEW.VP_YSEC
		mov	RWRThreats[bp].RWR_YSEC,ax

		mov	ax,RWR_VIEW.VP_XFT
		mov	RWRThreats[bp].RWR_XFT,ax

		mov	ax,RWR_VIEW.VP_YFT
		mov	RWRThreats[bp].RWR_YFT,ax

		mov	RWRThreats[bp].RWR_PTR,-1

		inc	NumRWRThreats

		add	RWRThreatIndex,RWR_REC_SIZE

		or	RWRThreatFlags,RWR_EWR

ExitEWR:	ret

ScanEWR		ENDP

;----------------------------------------------------------------------------

;* ScanSAM - scan for SAM threats
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

ScanSAM		PROC	NEAR

;---------------
;* y sector scan
;---------------

		mov	cx,3
		mov	di,-1

SAMYLoop:	push	cx
		push	di

;---------------
;* x sector scan
;---------------

		mov	cx,3
		mov	si,-1

SAMXLoop:	push	cx
		push	si
		push	di

;-------------
;* scan sector (if on active map)
;-------------

		mov	ax,XSec
		mov	bp,YSec

		add	ax,si
		add	bp,di

		cmp	ax,31
		_JA	SAMNextSctr
		cmp	bp,31
		_JA	SAMNextSctr

;----------------
;* set xsec, ysec (valid for all radars in sector)
;----------------

		mov	RWR_VIEW.VP_XSEC,ax
		mov	RWR_VIEW.VP_YSEC,bp

;------------------------------
;* map index = ysec * 32 + xsec
;------------------------------

		REPT	5
		shl	bp,1
		ENDM

		add	bp,ax

;-------------------------------
;* check for enemy SAM in sector
;-------------------------------

		test	SctrGameLayer1[bp],SECT_ENEMY
		_JZ	SAMNextSctr

		test	SctrGameLayer1[bp],SECT_SAM
		_JZ	SAMNextSctr

		mov	al,MobRadarLayer1[bp]

		CALC_RAD_INDEX

;---------------
;* scan SAM list
;---------------

		cmp	RadarTable[bp].RAD_SAM_OFFSET,-1
		_JE	SAMNextSctr

		mov	bp,RadarTable[bp].RAD_SAM_OFFSET

ScanSAMLoop:	cmp	RadarLists[bp],-1 	;end of list?
		_JE	SAMNextSctr		;yes ->

		mov	dx,SEG MSctrDataStart
		mov	ds,dx

		mov	si,RadarLists[bp]

		mov	al,[si].STAT_ANIM
		mov	cx,[si].STAT_XFT
		mov	bx,[si].STAT_YFT

		mov	dx,DATA
		mov	ds,dx

		test	al,OBJECT_DEAD	;in play?
		jnz	SkipSAM		;no ->

;-------------------
;* enemy SAM located
;-------------------

		mov	RWR_VIEW.VP_XFT,cx
		mov	RWR_VIEW.VP_YFT,bx

		push	si
		push	bp
		call	RadShadCheck
		pop	bp
		pop	si
		
		jc	SkipSAM		;non-visible (in shadow) ->

;----------------------------------
;* enter SAM into RWR threat buffer (if space available)
;----------------------------------

		cmp	NumRWRThreats,NUM_RWR_THREATS
		je	SkipSAM

		push	bp

		mov	bp,RWRThreatIndex

		mov	RWRThreats[bp].RWR_THREAT,THREAT_SAM

		mov	WORD PTR RWRThreats[bp].RWR_RNG_LO,ax
		mov	WORD PTR RWRThreats[bp].RWR_RNG_HI,dx

;* calc angular difference

		mov	ax,Hdg
		mov	dx,bx
		call	CalcAngDiff
		xor	ax,dx
		sub	ax,dx
		and	ax,511

		mov	RWRThreats[bp].RWR_DIR,ax

		mov	ax,RWR_VIEW.VP_XSEC
		mov	RWRThreats[bp].RWR_XSEC,ax

		mov	ax,RWR_VIEW.VP_YSEC
		mov	RWRThreats[bp].RWR_YSEC,ax

		mov	ax,RWR_VIEW.VP_XFT
		mov	RWRThreats[bp].RWR_XFT,ax

		mov	ax,RWR_VIEW.VP_YFT
		mov	RWRThreats[bp].RWR_YFT,ax

		mov	RWRThreats[bp].RWR_PTR,si

		inc	NumRWRThreats

		inc	ActiveSAMCntr

		add	RWRThreatIndex,RWR_REC_SIZE

		or	RWRThreatFlags,RWR_SAM

		pop	bp
		
SkipSAM:	add	bp,2

		jmp	ScanSAMLoop

;-------------
;* next sector
;-------------

SAMNextSctr:	pop	di
		pop	si
		pop	cx
		inc	si		;x = x + 1
		_LOOP	SAMXLoop

		pop	di
		pop	cx
		inc	di		;y = y + 1
		_LOOP	SAMYLoop

		ret

ScanSAM		ENDP

;----------------------------------------------------------------------------

;* ScanAAA - scan for AAA threats
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

ScanAAA		PROC	NEAR

;---------------
;* y sector scan
;---------------

		mov	cx,3
		mov	di,-1

AAAYLoop:	push	cx
		push	di

;---------------
;* x sector scan
;---------------

		mov	cx,3
		mov	si,-1

AAAXLoop:	push	cx
		push	si
		push	di

;-------------
;* scan sector (if on active map)
;-------------

		mov	ax,XSec
		mov	bp,YSec

		add	ax,si
		add	bp,di

		cmp	ax,31
		_JA	AAANextSctr
		cmp	bp,31
		_JA	AAANextSctr

;----------------
;* set xsec, ysec (valid for all radars in sector)
;----------------

		mov	RWR_VIEW.VP_XSEC,ax
		mov	RWR_VIEW.VP_YSEC,bp

;------------------------------
;* map index = ysec * 32 + xsec
;------------------------------

		REPT	5
		shl	bp,1
		ENDM

		add	bp,ax

;-------------------------------
;* check for enemy AAA in sector
;-------------------------------

		test	SctrGameLayer1[bp],SECT_ENEMY
		_JZ	AAANextSctr

		test	SctrGameLayer1[bp],SECT_AAA
		_JZ	AAANextSctr

		mov	al,MobRadarLayer1[bp]

		CALC_RAD_INDEX

;---------------
;* scan AAA list
;---------------

		cmp	RadarTable[bp].RAD_AAA_OFFSET,-1
		_JE	AAANextSctr

		mov	bp,RadarTable[bp].RAD_AAA_OFFSET

ScanAAALoop:	cmp	RadarLists[bp],-1 	;end of list?
		_JE	AAANextSctr		;yes ->

		mov	dx,SEG MSctrDataStart
		mov	ds,dx

		mov	si,RadarLists[bp]

		mov	al,[si].STAT_ANIM
		mov	cx,[si].STAT_XFT
		mov	bx,[si].STAT_YFT

		mov	dx,DATA
		mov	ds,dx

		test	al,OBJECT_DEAD	;in play?
		jnz	SkipAAA		;no ->

;-------------------
;* enemy AAA located
;-------------------

		mov	RWR_VIEW.VP_XFT,cx
		mov	RWR_VIEW.VP_YFT,bx

		push	si
		push	bp
		call	RadShadCheck
		pop	bp
		pop	si
		
		jc	SkipAAA		;non-visible (in shadow) ->

;----------------------------------
;* enter AAA into RWR threat buffer (if space available)
;----------------------------------

		cmp	NumRWRThreats,NUM_RWR_THREATS
		je	SkipAAA

		push	bp

		mov	bp,RWRThreatIndex

		mov	RWRThreats[bp].RWR_THREAT,THREAT_AAA

		mov	WORD PTR RWRThreats[bp].RWR_RNG_LO,ax
		mov	WORD PTR RWRThreats[bp].RWR_RNG_HI,dx

;* calc angular difference

		mov	ax,Hdg
		mov	dx,bx
		call	CalcAngDiff
		xor	ax,dx
		sub	ax,dx
		and	ax,511

		mov	RWRThreats[bp].RWR_DIR,ax

		mov	ax,RWR_VIEW.VP_XSEC
		mov	RWRThreats[bp].RWR_XSEC,ax

		mov	ax,RWR_VIEW.VP_YSEC
		mov	RWRThreats[bp].RWR_YSEC,ax

		mov	ax,RWR_VIEW.VP_XFT
		mov	RWRThreats[bp].RWR_XFT,ax

		mov	ax,RWR_VIEW.VP_YFT
		mov	RWRThreats[bp].RWR_YFT,ax

		mov	RWRThreats[bp].RWR_PTR,si

		inc	NumRWRThreats

		add	RWRThreatIndex,RWR_REC_SIZE

		or	RWRThreatFlags,RWR_AAA

		pop	bp
		
SkipAAA:	add	bp,2

		jmp	ScanAAALoop

;-------------
;* next sector
;-------------

AAANextSctr:	pop	di
		pop	si
		pop	cx
		inc	si		;x = x + 1
		_LOOP	AAAXLoop

		pop	di
		pop	cx
		inc	di		;y = y + 1
		_LOOP	AAAYLoop

		ret

ScanAAA		ENDP

;----------------------------------------------------------------------------

;* ScanAC - scan for AC threats
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

ScanAC		PROC	NEAR

;--------------------------
;* sort two player opponent
;--------------------------

		mov	si,OFFSET OPP_MOBILE
		call	GetDroneAlive
		jnc	@F
		call	GetDroneIllum
		jnc	@F
		call	AircraftRadar

;---------------------
;* scan enemy aircraft
;---------------------

@@:		mov	si,OFFSET EAircraft7
		call	GetDroneAlive
		jnc	@F
		call	GetDroneIllum
		jnc	@F
		call	AircraftRadar

@@:		mov	si,OFFSET EAircraft8
		call	GetDroneAlive
		jnc	@F
		call	GetDroneIllum
		jnc	@F
		call	AircraftRadar

@@:		mov	si,OFFSET EAircraft9
		call	GetDroneAlive
		jnc	@F
		call	GetDroneIllum
		jnc	@F
		call	AircraftRadar

@@:		mov	si,OFFSET EAircraft10
		call	GetDroneAlive
		jnc	@F
		call	GetDroneIllum
		jnc	@F
		call	AircraftRadar

@@:		mov	si,OFFSET EAircraft11
		call	GetDroneAlive
		jnc	@F
		call	GetDroneIllum
		jnc	@F
		call	AircraftRadar

@@:		mov	si,OFFSET EAircraft12
		call	GetDroneAlive
		jnc	@F
		call	GetDroneIllum
		jnc	@F
		call	AircraftRadar

@@:		ret

ScanAC		ENDP

;----------------------------------------------------------------------------

;* AircraftRadar
;*
;* pass: si -> MOBILE <> + VIEWPOINT <>
;* ret : nothing
;* kill: assume all

AircraftRadar	PROC	NEAR

;-----------------------
;* check space available
;-----------------------

		cmp	NumRWRThreats,NUM_RWR_THREATS
		je	ExitACRadar

;------------------------
;* calc range and bearing
;------------------------

		push	si

		mov	di,si

		mov	si,OFFSET M_VIEW
		add	di,MOB_REC_SIZE
		call	CalcRngBrgVP_VP

		pop	si

;---------------------------------------
;* enter aircraft into RWR threat buffer
;---------------------------------------

		mov	bp,RWRThreatIndex

		mov	RWRThreats[bp].RWR_THREAT,THREAT_AC

		mov	WORD PTR RWRThreats[bp].RWR_RNG_LO,ax
		mov	WORD PTR RWRThreats[bp].RWR_RNG_HI,dx

;* calc angular difference

		mov	ax,Hdg
		mov	dx,bx
		call	CalcAngDiff
		xor	ax,dx
		sub	ax,dx
		and	ax,511

		mov	RWRThreats[bp].RWR_DIR,ax

		mov	ax,[si].VP_XSEC
		mov	RWRThreats[bp].RWR_XSEC,ax

		mov	ax,[si].VP_YSEC
		mov	RWRThreats[bp].RWR_YSEC,ax

		mov	ax,[si].VP_XFT
		mov	RWRThreats[bp].RWR_XFT,ax

		mov	ax,[si].VP_YFT
		mov	RWRThreats[bp].RWR_YFT,ax

		mov	RWRThreats[bp].RWR_PTR,-1

		inc	NumRWRThreats

		add	RWRThreatIndex,RWR_REC_SIZE

		or	RWRThreatFlags,RWR_AC

ExitACRadar:	ret

AircraftRadar	ENDP

;----------------------------------------------------------------------------

;* ScanMSL - scan for MSL threats
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

ScanMSL		PROC	NEAR

;------------------------
;* init missile scan loop
;------------------------

		mov	cx,NUM_WEAPONS

		mov	ax,SEG WeaponList
		mov	ds,ax

		mov	si,OFFSET WeaponList

;-------------------
;* missile scan loop (loop optimized to reduce segment switching)
;-------------------

;* search for non-null weapon which has Tornado lock

MissileScan:	cmp	_WPN_TYPE[si],NULL_WEAPON
		je	NextWeapon

		test	_WPN_FLAGS[si],WFLG_TLOCK
		jnz	MissileLocated

NextWeapon:	add	si,WPN_DATA_SIZE

		loop	MissileScan

		mov	ax,DATA
		mov	ds,ax

		ret

;---------------------------
MissileLocated	LABEL	NEAR
;---------------------------

		push	cx
		push	si

		mov	bp,_WPN_FLAGS[si]

;* copy missile viewpoint into workspace

		add	si,MOB_REC_SIZE

		COPY_VP	RWR_VIEW,si

		mov	ax,DATA
		mov	ds,ax

		mov	TmpFlags,bp

;--------------------------------------------
;* check space available in RWR threat buffer
;--------------------------------------------

		cmp	NumRWRThreats,NUM_RWR_THREATS
		je	SkipMissile

;------------------------
;* calc range and bearing
;------------------------

		mov	si,OFFSET M_VIEW
		mov	di,OFFSET RWR_VIEW
		call	CalcRngBrgVP_VP

;--------------------------------------
;* enter missile into RWR threat buffer
;--------------------------------------

		mov	bp,RWRThreatIndex

		mov	WORD PTR RWRThreats[bp].RWR_RNG_LO,ax
		mov	WORD PTR RWRThreats[bp].RWR_RNG_HI,dx

;* calc angular difference

		mov	ax,Hdg
		mov	dx,bx
		call	CalcAngDiff
		xor	ax,dx
		sub	ax,dx
		and	ax,511

		mov	RWRThreats[bp].RWR_DIR,ax

		mov	ax,RWR_VIEW.VP_XSEC
		mov	RWRThreats[bp].RWR_XSEC,ax

		mov	ax,RWR_VIEW.VP_YSEC
		mov	RWRThreats[bp].RWR_YSEC,ax

		mov	ax,RWR_VIEW.VP_XFT
		mov	RWRThreats[bp].RWR_XFT,ax

		mov	ax,RWR_VIEW.VP_YFT
		mov	RWRThreats[bp].RWR_YFT,ax
		
		mov	RWRThreats[bp].RWR_PTR,-1

;* sort threat type (radar or IR seeker)

		mov	ax,THREAT_RAD_MSL

		test	TmpFlags,WFLG_IR_SEEK
		jz	@F

		mov	ax,THREAT_IR_MSL

@@:		mov	RWRThreats[bp].RWR_THREAT,ax

		inc	NumRWRThreats

		add	RWRThreatIndex,RWR_REC_SIZE

		or	RWRThreatFlags,RWR_MSL

SkipMissile:	mov	ax,SEG WeaponList
		mov	ds,ax

		pop	si
		pop	cx

		jmp	NextWeapon

ScanMSL		ENDP

;----------------------------------------------------------------------------

;* RadShadCheck - check line of sight to radar
;*
;* pass: M_VIEW = Tornado viewpoint
;*       RWR_VIEW = radar viewpoint
;* ret : cf = 0 = visible
;*          dx, ax = range
;*          bx = bearing
;*	 cf = 1 = non-visible (in radar shadow)
;* kill: cx, si, di, flags (except cf)

RadShadCheck	PROC	NEAR

;---------------------------------
;* calc range and bearing of radar
;---------------------------------

		mov	si,OFFSET M_VIEW
		mov	di,OFFSET RWR_VIEW

		call	CalcRngBrgVP_VP

		push	ax		;store range
		push	dx

		push	bx		;store bearing

;--------------------------------------
;* always visible if altitude > 65535ft
;--------------------------------------

		cmp	WORD PTR M_VIEW.VP_ZFT_HI,0
		ja	RadVis

;-------------------------
;* copy M_VIEW to TMP_VIEW
;-------------------------

		COPY_VP	TMP_VIEW,M_VIEW

;-----------------------------------
;* calc sample dist (Dx / 8, Dy / 8)
;-----------------------------------

		mov	ax,WORD PTR FlatDx
		mov	dx,WORD PTR FlatDx+2

		mov	bx,WORD PTR FlatDy
		mov	cx,WORD PTR FlatDy+2

		REPT	3
		sar	dx,1
		rcr	ax,1
		sar	cx,1
		rcr	bx,1
		ENDM

;-------------------
;* calc Dz = zft / 8
;-------------------

		mov	di,WORD PTR M_VIEW.VP_ZFT_LO

		REPT	3
		shr	di,1
		ENDM

;------------------
;* shadow test loop
;------------------

		mov	bp,7		;loop count

RadShadLoop:	push	ax
		push	bx
		push	cx
		push	dx
		push	di
		push	bp

		push	di

		mov	si,OFFSET TMP_VIEW
		call	MoveViewpoint

		pop	di

		mov	ax,WORD PTR TMP_VIEW.VP_ZFT_LO
		sub	ax,di
		MINM	ax
		mov	WORD PTR TMP_VIEW.VP_ZFT_LO,ax

		cmp	ax,256*15	;alt > max gnd ht?
		ja	@F	 	;yes ->

		call	CalcGndHeight

		cmp	WORD PTR TMP_VIEW.VP_ZFT_LO,ax	;alt > gnd ht?

@@:		pop	bp
		pop	di
		pop	dx
		pop	cx
		pop	bx
		pop	ax

		jbe	RadNonVis    	;alt <= gnd ht ->

		dec	bp	    	;next test

		jnz	RadShadLoop

;---------------------------
RadVis		LABEL	NEAR
;---------------------------

		pop	bx		;restore bearing

		pop	dx		;store range
		pop	ax

		clc			;cf = 0 (visible)
		ret

;---------------------------
RadNonVis	LABEL	NEAR
;---------------------------

		pop	bx		;restore bearing

		pop	dx		;store range
		pop	ax

		stc			;cf = 1 (non-visible)
		ret

RadShadCheck	ENDP

MODCODE		ENDS

;============================================================================

		END

