;****************************************************************************
;****************************************************************************
;*
;* VIEWS.ASM
;*
;* In cockpit / out of cockpit view modes.
;*
;* 14.08.1991 - KJB
;* 18.01.1992 - KJB - VIEW_LOOKDOWN and VIEW_LOOKUP view modes added.
;* 02.04.1992 - KJB - VIEW_MAP added.
;* 24.06.1992 - KJB - AdjustTrack subroutine added.
;*                    VIEW_DRONE added.
;* 26.06.1992 - KJB - VIEW_SPECTATOR added.
;* 08.07.1992 - KJB - VIEW_REMOTE added.
;* 06.08.1992 - KJB - Drone side / type switching added to VIEW_DRONE.
;* 26.09.1992 - KJB - VIEW_DEMO added.
;* 14.11.1992 - KJB - VIEW_DESTROYED added.
;* 14.11.1992 - KJB - Keep viewpoint above hills mod added.
;* 14.11.1992 - KJB - Keep viewpoint outside drone mod added.
;* 21.11.1992 - KJB - VIEW_WEAPON added.
;* 06.01.1993 - KJB - EarShot flag added (sound suspend / resume).
;* 10.01.1993 - KJB - VIEW_WEAPON zoom added.
;* 03.04.1993 - KJB - View rotate added.
;* 07.04.1993 - KJB - Coolie hat view switching added.
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<
PUBLIC TrkCamAlt		
PUBLIC TrkCamDist
		PUBLIC	SetGameViewMode
		PUBLIC	UpdateGameView
PUBLIC ChgGameViewMode
		PUBLIC	ViewPtr
		PUBLIC	DroneMode
		PUBLIC	DroneCrntPtrs
		PUBLIC	ViewWeaponPtr
		PUBLIC	TrkCamBrg
		PUBLIC	WpnCamBrg
		PUBLIC	WpnCamBrgFine

		PUBLIC	InCockpit
PUBLIC	QuieterCockpit
;PUBLIC	MutedCockpit
		PUBLIC	EarShot

		PUBLIC	ZFT_COCKPIT
EXTRN AllowSplitScreenBigMap:BYTE		
EXTRN SplitScreenBigMapIsOn:BYTE
EXTRN CurrentViewIsCheckSix:BYTE		
EXTRN EScopeToggle:BYTE
EXTRN ZRKrombCamDist:WORD		
EXTRN YawValue:WORD		
EXTRN YawValue2:WORD	
EXTRN YawValue_ZRK_AAA:WORD		
EXTRN SAM_VIEW:WORD		
EXTRN AAA_VIEW1:WORD		
EXTRN AAA_VIEW2:WORD	
EXTRN EScopeToggle:BYTE
EXTRN   InWeaponView:BYTE	
EXTRN   CockpitViews:BYTE	
EXTRN   HorizonValue:WORD		
EXTRN   HorizonValue2:WORD	
EXTRN   HorizonValue_ZRK_AAA:WORD
EXTRN   HorizonValue3:WORD	
EXTRN   HorizonValue5:WORD	
EXTRN   HorizonValue6:WORD	
EXTRN   CheckSixValue:WORD
EXTRN   HorizonBombValue:WORD			
EXTRN	Key:BYTE		
EXTRN   ToggleZRK_ZSU:BYTE
EXTRN	TornadoType:WORD		

EXTRN	SetHUDLevel:FAR
EXTRN	HUDLevel:BYTE		
EXTRN	LoadExtrnPan:NEAR    ;hacked on 6/11/2017
EXTRN	UpdateExtrn:NEAR     ;hacked on 6/11/2017		
EXTRN	UpdateADI2:NEAR     ;hacked on 6/11/2017	

		EXTRN	SetIRPalette:FAR
		EXTRN	FixIRPalette:FAR		
		
		EXTRN	SetViewMode:FAR
		EXTRN	CalcDeltaXY:FAR
		EXTRN	LimitPitch:FAR
		EXTRN	SetPanelMode:FAR
		EXTRN	MapView:FAR
		EXTRN	CalcRngBrgVP_VP:FAR
		EXTRN	CalcAngDiff:FAR
		EXTRN	ArcTan:FAR
		EXTRN	RandX:FAR
		EXTRN	CalcMobMaxDim:FAR
		EXTRN	CalcGndHeight:FAR
		EXTRN	SuspendSound:FAR
		EXTRN	ResumeSound:FAR

		EXTRN	GameViewMode:WORD
		EXTRN	M_VIEW:WORD
		EXTRN	TMP_VIEW:WORD
EXTRN	TMP2_VIEW:WORD		
		EXTRN	DeltaTime:WORD
		EXTRN	OctTrigTable:WORD
		EXTRN	OctSignTable:WORD
		EXTRN	PitchFlip:WORD
		EXTRN	CrewMode:WORD
		EXTRN	DronePtrs:WORD
		EXTRN	AAirDronePtrs:WORD
		EXTRN	AAirDroneLast:WORD
		EXTRN	EAirDronePtrs:WORD
		EXTRN	EAirDroneLast:WORD
		EXTRN	AGndDronePtrs:WORD
		EXTRN	AGndDroneLast:WORD
		EXTRN	EGndDronePtrs:WORD
		EXTRN	EGndDroneLast:WORD
		EXTRN	LastFrame:WORD
		EXTRN	SinTable:WORD
		EXTRN	CosTable:WORD
		
EXTRN	ShakeUp:BYTE		
		
EXTRN   SSF_RWR:BYTE	
EXTRN	SSF_HUD:BYTE	
EXTRN	SSF_PilotMFD:BYTE	
EXTRN	SSF_NavigMFD:BYTE	
EXTRN	SSF_TAB1:BYTE	
EXTRN	SSF_TAB2:BYTE	
EXTRN	SSF_CommsRx:BYTE	
EXTRN	SSF_Oxygen:BYTE	
EXTRN	SSF_Radar:BYTE	
EXTRN	SSF_ECM:BYTE	
EXTRN	SSF_RWR:BYTE	
EXTRN	SSF_ADC:BYTE	

EXTRN KF_HillText:BYTE
EXTRN KF_Yaw:BYTE		
EXTRN KF_ZoomIn:BYTE
EXTRN KF_ZoomOut:BYTE
EXTRN KF_GndText:BYTE
EXTRN KF_Minimise:BYTE
EXTRN KF_Range:BYTE
EXTRN KF_SAMLauncherToTornado:BYTE
EXTRN KF_AAAToTornadoView1:BYTE
EXTRN KF_AAAToTornadoView2:BYTE
EXTRN KF_ChangeArmor:BYTE
EXTRN KF_ArmorCtrlShift:BYTE
EXTRN KF_ArmorCtrlAlt:BYTE
EXTRN KF_ArmorDown:BYTE
EXTRN KF_Horizon:BYTE
		EXTRN	KF_PilotView:BYTE
		EXTRN	KF_NavigView:BYTE
		EXTRN	KF_LViewFix:BYTE
		EXTRN	KF_RViewFix:BYTE
		EXTRN	KF_LViewGlance:BYTE
		EXTRN	KF_RViewGlance:BYTE
		EXTRN	KF_TrackingCam:BYTE
		EXTRN	KF_TrackingCamUp:BYTE
		EXTRN	KF_SatelliteCam:BYTE
		EXTRN	KF_MapView:BYTE
		EXTRN	KF_DroneView:BYTE
		EXTRN	KF_DronePrev:BYTE
		EXTRN	KF_DroneSide:BYTE
		EXTRN	KF_DroneType:BYTE
		EXTRN	KF_Spectator:BYTE
		EXTRN	KF_RestoreSpec:BYTE
		EXTRN	KF_RemoteView:BYTE
		EXTRN	KF_LookDown:BYTE
		EXTRN	KF_TogglePitchCam:BYTE
		EXTRN	KF_Pause:BYTE
		EXTRN	KF_ResetTrkCam:BYTE
		EXTRN	KF_ResetSatCam:BYTE
		EXTRN	KF_ResetWpnCam:BYTE
		EXTRN	KF_ZoomIn:BYTE
		EXTRN	KF_ZoomOut:BYTE
		EXTRN	KF_FastZoomIn:BYTE
		EXTRN	KF_FastZoomOut:BYTE
		EXTRN	KF_TrackClk:BYTE
		EXTRN	KF_TrackAClk:BYTE
		EXTRN	KF_FastTrkClk:BYTE
		EXTRN	KF_FastTrkAClk:BYTE
		EXTRN	KF_ViewWeapon:BYTE
		EXTRN	SpinFlag:BYTE
		EXTRN	DieFlag:BYTE
		EXTRN	TmpDieFlag:BYTE
		EXTRN	TwoPlayer:BYTE
		EXTRN	TM_CoolieVal:BYTE

EXTRN	SSF_Gear:BYTE
EXTRN	SSF_WheelBrakes:BYTE
EXTRN	SSF_AirBrakes:BYTE
EXTRN	SSF_Engine1:BYTE
EXTRN	SSF_Engine2:BYTE
EXTRN	SSF_Sweep:BYTE
EXTRN	SSF_Flaps:BYTE
EXTRN	SSF_ThrustRvrs:BYTE
EXTRN	SSF_SPILS:BYTE
			
		EXTRN	COOLIE_UP:ABS
		EXTRN	COOLIE_DN:ABS
		EXTRN	COOLIE_LT:ABS
		EXTRN	COOLIE_RT:ABS

EXTRN	ShakePriority:BYTE
EXTRN	HShake:BYTE	
EXTRN	VShake:BYTE
EXTRN	ShakeTimer:WORD
EXTRN	HSHAKE_HI:ABS
EXTRN	VSHAKE_HI:ABS
EXTRN	HSHAKE_LO:ABS
EXTRN	HSHAKE_VERY_LO:ABS
EXTRN	VSHAKE_VERY_LO:ABS
EXTRN	VSHAKE_LO:ABS
EXTRN	VSHAKE_OFF:ABS
EXTRN	HSHAKE_OFF:ABS


;============================================================================
INCLUDE	MISCMAC.INC
		
;============================================================================

		INCLUDE	MAINDATA.INC

		INCLUDE	\VISUAL\VISDATA.INC
		INCLUDE	\VISUAL\VISMACRO.INC
		INCLUDE	\VISUAL\VISEXTRN.INC

		INCLUDE	\LIB8086\KEYS.INC
		INCLUDE	\LIB8086\TRIG.INC
		INCLUDE	\LIB8086\USEFUL.INC

;============================================================================
EXTRN AAA_or_SAM_value:VIEWPOINT

DATA		SEGMENT PARA PUBLIC 'DATA'

;----------------
;* view point ptr
;----------------
PitchToggle DB 0 ;1 = pitch horizon when Tornado turns
PitchToggleWeapon DB 0 ;1 = pitch horizon for launched Weapon when Tornado turns
ViewPtr		DW	OFFSET M_VIEW	;(-1 = visual disabled)
;SAM_GOPHER EQU 8
;SAM_BUFFER EQU 20
SAM_GOPHER EQU 0
SAM_BUFFER EQU 0
;---------------
;* set view mode (wrt GameViewMode)
;---------------

ViewSwitch	DW	NUL_VIEWMODE	;VIEW_PILOT
		DW	ALT_VIEWMODE	;VIEW_LPILOT
		DW	ALT_VIEWMODE	;VIEW_RPILOT
		DW	NUL_VIEWMODE	;VIEW_NAVIG
		DW	ALT_VIEWMODE	;VIEW_LNAVIG
		DW	ALT_VIEWMODE	;VIEW_RNAVIG
		DW	EXT_VIEWMODE	;VIEW_TRACKING
		DW	EXT_VIEWMODE	;VIEW_SATELLITE
		DW	NUL_VIEWMODE	;VIEW_MAP ;NUL_VIEWMODE
		DW	EXT_VIEWMODE	;VIEW_DRONE
		DW	EXT_VIEWMODE	;VIEW_SPECTATOR
		DW	EXT_VIEWMODE	;VIEW_REMOTE
		DW	NUL_VIEWMODE	;VIEW_LOOKDOWN
		DW	EXT_VIEWMODE	;VIEW_LOOKUP
		DW	EXT_VIEWMODE	;VIEW_DEMO
		DW	EXT_VIEWMODE	;VIEW_DESTROYED
		DW	EXT_VIEWMODE	;VIEW_WEAPON
		DW	EXT_VIEWMODE	;VIEW_ZRK (Added by Frankie, 27/5/18)
		DW	EXT_VIEWMODE	;VIEW_ZSU1 (Added by Frankie, 27/5/18)
		DW	EXT_VIEWMODE	;VIEW_ZSU2 (Added by Frankie, 27/5/18)
		DW	EXT_VIEWMODE	;VIEW_ZRK_AAA (Added by Frankie, 29/5/18)
		
;------------------
;* view rotate mode (wrt GameViewMode)
;------------------

RotateSwitch	DW	ROTATE_NULL	;VIEW_PILOT
		DW	ROTATE_VIEW_LT	;VIEW_LPILOT
		DW	ROTATE_VIEW_RT	;VIEW_RPILOT
		DW	ROTATE_NULL	;VIEW_NAVIG
		DW	ROTATE_VIEW_LT	;VIEW_LNAVIG
		DW	ROTATE_VIEW_RT	;VIEW_RNAVIG
		DW	ROTATE_NULL	;VIEW_TRACKING
		DW	ROTATE_VIEW_BK	;BACK VIEW replaces the VIEW_SATELLITE
		DW	ROTATE_NULL	;VIEW_MAP
		DW	ROTATE_NULL	;VIEW_DRONE
		DW	ROTATE_NULL	;VIEW_SPECTATOR
		DW	ROTATE_NULL	;VIEW_REMOTE
		DW	ROTATE_NULL	;VIEW_LOOKDOWN
		DW	ROTATE_VIEW_UP	;VIEW_LOOKUP
		DW	ROTATE_NULL	;VIEW_DEMO
		DW	ROTATE_NULL	;VIEW_DESTROYED
		DW	ROTATE_NULL	;VIEW_WEAPON
		DW	ROTATE_NULL	;VIEW_ZRK
		DW	ROTATE_NULL	;VIEW_ZSU1
		DW	ROTATE_NULL	;VIEW_ZSU2	
        DW	ROTATE_NULL ;VIEW_ZRK_AAA		

;----------------
;* set panel mode (wrt GameViewMode)
;----------------

PanelSwitch	DW	PILOTPAN	;VIEW_PILOT
		DW	PSIDEPAN	;VIEW_LPILOT
		DW	PSIDEPAN	;VIEW_RPILOT
		DW	NAVIGPAN	;VIEW_NAVIG
		DW	NSIDEPAN	;VIEW_LNAVIG
		DW	NSIDEPAN	;VIEW_RNAVIG
		DW	EXTRNPAN	;VIEW_TRACKING
		DW	EXTRNPAN	;VIEW_SATELLITE
		DW	MAPPAN		;VIEW_MAP
		DW	EXTRNPAN	;VIEW_DRONE
		DW	EXTRNPAN	;VIEW_SPECTATOR
		DW	EXTRNPAN	;VIEW_REMOTE
		DW	LOOKDOWN	;VIEW_LOOKDOWN
		DW	LOOKUP		;VIEW_LOOKUP
		DW	EXTRNPAN	;VIEW_DEMO
		DW	EXTRNPAN	;VIEW_DESTROYED
		DW	EXTRNPAN	;VIEW_WEAPON
		DW	EXTRNPAN	;VIEW_ZRK
		DW	EXTRNPAN	;VIEW_ZSU1
		DW	EXTRNPAN	;VIEW_ZSU2
		DW	EXTRNPAN	;VIEW_ZRK_AAA
		
;-------------
;* crew switch (wrt GameViewMode)
;-------------

CrewSwitch	DW	CREW_PILOT	;VIEW_PILOT
		DW	CREW_PILOT	;VIEW_LPILOT
		DW	CREW_PILOT	;VIEW_RPILOT
		DW	CREW_NAVIG	;VIEW_NAVIG
		DW	CREW_NAVIG	;VIEW_LNAVIG
		DW	CREW_NAVIG	;VIEW_RNAVIG
		DW	CREW_PILOT	;VIEW_TRACKING
		DW	CREW_PILOT	;VIEW_SATELLITE
		DW	CREW_PILOT	;VIEW_MAP
		DW	CREW_PILOT	;VIEW_DRONE
		DW	CREW_PILOT	;VIEW_SPECTATOR
		DW	CREW_PILOT	;VIEW_REMOTE
		DW	CREW_PILOT	;VIEW_LOOKDOWN
		DW	CREW_PILOT	;VIEW_LOOKUP
		DW	CREW_PILOT	;VIEW_DEMO
		DW	CREW_PILOT	;VIEW_DESTROYED
		DW	CREW_PILOT	;VIEW_WEAPON
		DW	CREW_PILOT	;VIEW_ZRK
		DW	CREW_PILOT	;VIEW_ZSU1
		DW	CREW_PILOT	;VIEW_ZSU2
		DW  CREW_PILOT  ;VIEW_ZRK_AAA
		
;------------
;* in cockpit (wrt GameViewMode)
;------------

ZFT_COCKPIT	EQU	8		;in cockpit zft displacement

InCockpit	 DB	1		;1 = in cockpit
QuieterCockpit DB	1		;1 = in cockpit, the sound of engines is quieter than outside 
;MutedCockpit DB 0           ;1 = mute engines (no engine sounds)

CockpitFlags DB	1		;VIEW_PILOT
		DB	1		;VIEW_LPILOT
		DB	1		;VIEW_RPILOT
		DB	1		;VIEW_NAVIG
		DB	1		;VIEW_LNAVIG
		DB	1		;VIEW_RNAVIG
		DB	1		;VIEW_TRACKING
		DB	1		;VIEW_SATELLITE
		DB	0		;VIEW_MAP
		DB	1		;VIEW_DRONE
		DB	1		;VIEW_SPECTATOR
		DB	1		;VIEW_REMOTE
		DB	1		;VIEW_LOOKDOWN
		DB	1		;VIEW_LOOKUP
		DB	0		;VIEW_DEMO
		DB	0		;VIEW_DESTROYED
		DB	0		;VIEW_WEAPON
		DB	0		;VIEW_ZRK  0
		DB	0		;VIEW_ZSU1 0
		DB	0		;VIEW_ZSU2 0
		DB  0       ;VIEW_ZRK_AAA 0
		
		EVEN

QuieterCockpitFlags	DB	1		;VIEW_PILOT
		DB	1		;VIEW_LPILOT
		DB	1		;VIEW_RPILOT
		DB	1		;VIEW_NAVIG
		DB	1		;VIEW_LNAVIG
		DB	1		;VIEW_RNAVIG
		DB	0		;VIEW_TRACKING
		DB	0		;VIEW_SATELLITE
		DB	0		;VIEW_MAP
		DB	0		;VIEW_DRONE
		DB	0		;VIEW_SPECTATOR
		DB	0		;VIEW_REMOTE
		DB	1		;VIEW_LOOKDOWN
		DB	1		;VIEW_LOOKUP
		DB	0		;VIEW_DEMO
		DB	0		;VIEW_DESTROYED
		DB	0		;VIEW_WEAPON
		DB	0		;VIEW_ZRK      1   
		DB	0		;VIEW_ZSU1     1
		DB	0		;VIEW_ZSU2     1
		DB  0       ;VIEW_ZRK_AAA  1
		
		EVEN
		
;MutedCockpitFlags	DB	0		;VIEW_PILOT
;		DB	0		;VIEW_LPILOT
;		DB	0	    ;VIEW_RPILOT
;		DB	0		;VIEW_NAVIG
;		DB	0		;VIEW_LNAVIG
;		DB	0		;VIEW_RNAVIG
;		DB	0		;VIEW_TRACKING
;		DB	0		;VIEW_SATELLITE
;		DB	0		;VIEW_MAP
;		DB	0		;VIEW_DRONE
;		DB	0		;VIEW_SPECTATOR
;		DB	0		;VIEW_REMOTE
;		DB	0		;VIEW_LOOKDOWN
;		DB	0		;VIEW_LOOKUP
;		DB	0		;VIEW_DEMO
;		DB	0		;VIEW_DESTROYED
;		DB	0		;VIEW_WEAPON
;		DB	1		;VIEW_ZRK
;		DB	1		;VIEW_ZSU1
;		DB	1		;VIEW_ZSU2
;		DB  1       ;VIEW_ZRK_AAA
		
		EVEN

		
;---------------
;* earshot flags (wrt GameViewMode)
;---------------

EarShot		DB	1		;1 = within audible range of Tornado sound effects

EarShotFlags	DB	1		;VIEW_PILOT
		DB	1		;VIEW_LPILOT
		DB	1		;VIEW_RPILOT
		DB	1		;VIEW_NAVIG
		DB	1		;VIEW_LNAVIG
		DB	1		;VIEW_RNAVIG
		DB	1		;VIEW_TRACKING
		DB	1		;VIEW_SATELLITE
		DB	1		;VIEW_MAP
		DB	1		;VIEW_DRONE
		DB	1		;VIEW_SPECTATOR  ;hack from 0 to 1
		DB	1		;VIEW_REMOTE     ;hack from 0 to 1
		DB	1		;VIEW_LOOKDOWN
		DB	1		;VIEW_LOOKUP
		DB	1		;VIEW_DEMO
		DB	1		;VIEW_DESTROYED
		DB	1		;VIEW_WEAPON  ;hack from 0 to 1
		DB	1		;VIEW_ZRK
		DB	1		;VIEW_ZSU1
		DB	1		;VIEW_ZSU2
		DB  1       ;VIEW_ZRK_AAA
		
		EVEN

;--------------------
;* update view switch (wrt GameViewMode)
;--------------------

UpdateSwitch	DW	UpdatePilot	;VIEW_PILOT
		DW	UpdateLPilot	;VIEW_LPILOT
		DW	UpdateRPilot	;VIEW_RPILOT
		DW	UpdateNavig	;VIEW_NAVIG
		DW	UpdateLNavig	;VIEW_LNAVIG
		DW	UpdateRNavig	;VIEW_RNAVIG
		DW	UpdateTracking	;VIEW_TRACKING
		DW	UpdateSatellite	;VIEW_SATELLITE
		DW	UpdateMap	;VIEW_MAP
		DW	UpdateDrone	;VIEW_DRONE
		DW	UpdateSpectator	;VIEW_SPECTATOR
		DW	UpdateRemote	;VIEW_REMOTE
		DW	UpdateLookDown	;VIEW_LOOKDOWN
		DW	UpdateLookUp	;VIEW_LOOKUP
		DW	UpdateDemo	;VIEW_DEMO
		DW	UpdateDestroyed	;VIEW_DESTROYED
		DW	UpdateWeapon	;VIEW_WEAPON
		DW	UpdateRemote	;VIEW_ZRK
		DW	UpdateRemote	;VIEW_ZSU1
		DW	UpdateRemote	;VIEW_ZSU2
		DW	UpdateZRK_AAA	;VIEW_ZRK_AAA
		
;---------------
;* "glance" vars
;---------------

GlanceFlag	DB	0,0		;1 = glancing left or right

PrevViewMode	DW	VIEW_PILOT

GlanceKeyPtr	DW	OFFSET KF_LViewGlance[K_STATUS]

;-----------------
;* zoom parameters
;-----------------

MIN_ZOOM	EQU	40
;MAX_ZOOM	EQU	1023		;1023 maximum
MAX_ZOOM	EQU	2047		;1023 maximum

;----------------------
;* tracking camera vars
;----------------------

;TrkCamDist     DW  98  ;formerly 64
;TrkCamDistFine	DW	0

;TrkCamBrg      DW  300  ;formerly 270
;TrkCamBrgFine	DW	0

;TrkCamAlt      DW  38   ;formerly 16

TrkCamDist	DW	64 ;64
TrkCamDistFine	DW	0

TrkCamBrg	DW	256
TrkCamBrgFine	DW	0

TrkCamAlt	DW	16;16
TrkCamAlt2	DW	16;16

;-----------------------
;* satellite camera vars
;-----------------------

SatCamDist	DW	64
SatCamDistFine	DW	0

SatCamSide	DW	0		;0 = topside view, -1 = underside view

;-------------------
;* drone camera vars
;-------------------

A_AIR_MODE	EQU	000b		;allied aircraft
E_AIR_MODE	EQU	010b		;enemy aircraft
A_GND_MODE	EQU	100b		;allied ground vehicles
E_GND_MODE	EQU	110b		;enemy ground vehicles

A_E_TOGGLE	EQU	010b		;allied / enemy toggle
AIR_GND_TOGGLE	EQU	100b		;air / ground toggle

DroneMode	DW	A_AIR_MODE

DroneCrntPtrs	LABEL	WORD		;current drone pointers

		DW	OFFSET AAirDronePtrs	;A_AIR_MODE
		DW	OFFSET EAirDronePtrs	;E_AIR_MODE
		DW	OFFSET AGndDronePtrs  	;A_GND_MODE
		DW	OFFSET EGndDronePtrs  	;E_GND_MODE

DroneListPtrs	LABEL	WORD		;drone list pointers

		DW	OFFSET AAirDronePtrs	;A_AIR_MODE
		DW	OFFSET EAirDronePtrs	;E_AIR_MODE
		DW	OFFSET AGndDronePtrs  	;A_GND_MODE
		DW	OFFSET EGndDronePtrs  	;E_GND_MODE

DroneListEnds	LABEL	WORD		;drone list end pointers

		DW	OFFSET AAirDroneLast	;A_AIR_MODE
		DW	OFFSET EAirDroneLast	;E_AIR_MODE
		DW	OFFSET AGndDroneLast  	;A_GND_MODE
		DW	OFFSET EGndDroneLast  	;E_GND_MODE

DrnCamDist	DW	64		;A_AIR_MODE
		DW	64		;E_AIR_MODE
		DW	64		;A_GND_MODE
		DW	64		;E_GND_MODE

DrnCamDistFine	DW	0		;A_AIR_MODE
		DW	0		;E_AIR_MODE
		DW	0		;A_GND_MODE
		DW	0		;E_GND_MODE

DrnCamBrg	DW	260		;A_AIR_MODE       ;hack from 0 to 260
		DW	260		;E_AIR_MODE           ;hack from 0 to 260
		DW	260		;A_GND_MODE           ;hack from 0 to 260
		DW	260		;E_GND_MODE           ;hack from 0 to 260

DrnCamBrgFine	DW	260		;A_AIR_MODE   ;hack from 0 to 260
		DW	260		;E_AIR_MODE           ;hack from 0 to 260
		DW	260		;A_GND_MODE           ;hack from 0 to 260
		DW	260		;E_GND_MODE           ;hack from 0 to 260

;---------------------
;* spectator viewpoint
;---------------------

SpecValid	DB	0		;1 = SPEC_VIEW valid

		EVEN

SPEC_VIEW	VIEWPOINT <>

SpecCamHdgFine	DW	0

;------------------
;* remote viewpoint
;------------------

REM_VIEW	VIEWPOINT <>
;REM_VIEW	VIEWPOINT <0,0,0,0,0,0,0,0>
;REM_VIEW   VIEWPOINT  <xsec, ysec, xft, yft,   zft, hd, ptch, roll>
;REM_VIEW	VIEWPOINT  <23,   25,   0,   1536,  0,   384

;VIEWPOINT	STRUCT
;
;VP_XSEC	DW	0		;x sector
;VP_YSEC	DW	0		;y sector
;VP_XFT		DW	0		;x ft
;VP_YFT		DW	0		;y ft
;VP_ZFT		DD	0		;z ft (0 .. 100,000)
;VP_HDG		DW	0		;heading
;VP_PITCH	DW	0		;pitch
;VP_ROLL		DW	0		;roll

;-----------
;* demo view
;-----------

;* set default viewpoint (in case no drones active)

DEMO_VIEW	VIEWPOINT <16,16,10000,10000,5000,0,0,0>

DRONE_AIR_TIME	EQU	10*100		;secs * 100
DRONE_GND_TIME	EQU	5*100		;secs * 100

DroneTimer	DW	0		;secs * 100

;* various camera angles for demo mode

CameraAngle	DW	0

CameraSwitch	DW	CamRotateClk	;0
		DW	CamRotateAClk	;2
		DW	CamRandom	;4
		DW	CamRandom	;6

RndCamBrg	DW	0		;random camera bearing

;----------------
;* destroyed view
;----------------

DestroyTimer	DW	8*100		;destroyed view duration (secs * 100)

;-------------
;* weapon view
;-------------

;* note: The weapon record referenced by ViewWeaponPtr cannot be reused (even
;*	 when NULL_WEAPON). This guarantees that the VIEWPOINT data is valid.

ViewWeaponPtr	DW	-1		;-1 = weapon view not available

WPN_VIEW	VIEWPOINT <>

WPN_DIST_MIN	EQU	32*256
WPN_DIST_MAX	EQU	120*256

WpnCamDist	DW	WPN_DIST_MIN	;ft * 256

WpnCamBrg	DW	256
WpnCamBrgFine	DW	0

;* expired weapon viewpoint position

WpnExpView	DB	0		;0 = normal
					;1 = overhead

		EVEN

WeaponSwitch	DW	BombView	;GPB1000
		DW	BombView	;RET1000
		DW	BombView	;LGB1000
		DW	BombView	;BL755
		DW	BombView	;JP233
		DW	AlarmView	;ALARM
		DW	MissileView	;CANNON
		DW	MissileView	;SIDEWINDER
		DW	MissileView	;SKYFLASH

DATA		ENDS

;============================================================================

WPNDATA		SEGMENT PARA PUBLIC 'DATA'

WPNDATA		ENDS

;============================================================================

PANCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:PANCODE
		ASSUME DS:DATA

;* ChgGameViewMode - set game view mode (if changed)
;* SetGameViewMode - set game view mode (sort panel mode / view mode etc.)
;*
;* pass: ax = view mode
;* ret : GameViewMode
;*       ax = previous view mode     )
;*       cf = 0 = change successful  ) only meaningful for ChgGameViewMode
;*       cf = 1 = change unsuccesful )
;* kill: assume all

ChgGameViewMode	LABEL	FAR

		cmp	ax,GameViewMode	;game view mode already set?
		jne	SetGameViewMode	;no ->

		stc			;change unsuccessful

		retf			;<<<<< MUST BE FAR <<<<<

SetGameViewMode	PROC	FAR

		mov	bx,ax

		xchg	ax,GameViewMode

		push	ax		;store previous view mode

		mov	ax,CrewSwitch[bx]
		mov	CrewMode,ax

		mov	ax,ViewSwitch[bx]
		push	bx
		call	SetViewMode
		pop	bx

		mov	ax,RotateSwitch[bx]
		mov	ViewRotateMode,ax

		mov	ax,PanelSwitch[bx]
		push	bx
		call	SetPanelMode
		pop	bx

		shr	bx,1		;/2 byte index

		mov	al,CockpitFlags[bx]
		mov	InCockpit,al

		mov	al,QuieterCockpitFlags[bx]
		mov	QuieterCockpit,al
		
		;mov	al,MutedCockpitFlags[bx]
		;mov	MutedCockpit,al
		
		
		mov	al,EarShotFlags[bx]
		mov	EarShot,al

		test	al,al		;within earshot?
		jnz	@F		;yes ->

		call	SuspendSound

		jmp	SoundOk

@@:		call	ResumeSound

SoundOk:	pop	ax		;restore previous view mode

		clc			;change successful

		ret

SetGameViewMode	ENDP

;----------------------------------------------------------------------------

;* UpdateGameView - update game view (update cameras etc.)
;*
;* pass: GameViewMode
;* ret : ViewPtr -> VIEWPOINT record (-1 = visual disabled)
;* kill: assume all

UpdateGameView	PROC	FAR

;----------------------------
;* check for fixed view modes
;----------------------------

;* Input is disabled for these modes so it is not possible to switch out of
;* them. However, check for them here in case just switched and key flags
;* are still active from last scan.

		mov	ax,GameViewMode

		cmp	ax,VIEW_DEMO		;demo?
		_JE	UpdateView		;yes ->

		cmp	ax,VIEW_DESTROYED	;destroyed?
		_JE	UpdateView		;yes ->

;---------------------------------------
;* check if still glancing left or right (cannot change view whilst glancing)
;---------------------------------------

		test	GlanceFlag,1	;glancing?
		jz	CheckChange	;no ->


	    mov	si,GlanceKeyPtr
		test	BYTE PTR [si],1	;glance key still held?
		jz	@F		;no ->
		jmp	UpdateView

;* restore previous view mode

@@:		mov	GlanceFlag,0

		mov	ax,PrevViewMode

		call	ChgGameViewMode
	
;----------------------------
;* check if view mode changed
;----------------------------

;--------------------
;* pilot's panel view
;--------------------

CheckChange:	cmp	TM_CoolieVal,COOLIE_UP
		je	@F

		KTEST	KF_PilotView
		jz	SkipPilot
        mov SplitScreenBigMapIsOn,0
			
		;mov InCockpit,1
		mov CockpitViews,1
		mov InWeaponView,0
	    ;mov M_VIEW.VP_PITCH,20	;Frankie hack
		
@@:		mov	ax,VIEW_PILOT
		call	ChgGameViewMode
		jnc	@F		;change successful ->

;* must have been VIEW_PILOT already, switch to VIEW_LOOKUP

		mov	ax,VIEW_LOOKUP
		call	ChgGameViewMode
	
@@:		jmp	UpdateView

;------------------------
;* navigator's panel view
;------------------------

SkipPilot:	cmp	TM_CoolieVal,COOLIE_DN
		je	@F
        
		KTEST	KF_NavigView
		jz	SkipNavig
		
		;mov InCockpit,1
		mov CockpitViews,1
		mov InWeaponView,0

@@:		mov SplitScreenBigMapIsOn,0
        mov	ax,VIEW_NAVIG
		call	ChgGameViewMode

		jmp	UpdateView

;-------------------------------------------
;* left view (fixed), sort pilot / navigator
;-------------------------------------------

SkipNavig:	cmp	TM_CoolieVal,COOLIE_LT
		je	@F
		
		KTEST	KF_LViewFix
		jz	SkipLFix
		
		mov SplitScreenBigMapIsOn,0
		
		mov CockpitViews,1
		mov InWeaponView,0

@@:		mov	ax,VIEW_LPILOT		;assume pilot
		cmp	CrewMode,CREW_PILOT	;pilot?
		je	@F			;yes ->
		mov	ax,VIEW_LNAVIG

@@:		call	ChgGameViewMode

		jmp	UpdateView

;--------------------------------------------
;* right view (fixed), sort pilot / navigator
;--------------------------------------------

SkipLFix:	cmp	TM_CoolieVal,COOLIE_RT
		je	@F

		KTEST	KF_RViewFix
		jz	SkipRFix
		
		mov CockpitViews,1
        mov InWeaponView,0
		
@@:		mov SplitScreenBigMapIsOn,0
        mov	ax,VIEW_RPILOT		;assume pilot
		cmp	CrewMode,CREW_PILOT	;pilot?
		je	@F			;yes ->
		mov	ax,VIEW_RNAVIG

@@:		call	ChgGameViewMode

		jmp	UpdateView

;--------------------------------------------
;* left view (glance), sort pilot / navigator
;--------------------------------------------

SkipRFix:	KTEST	KF_LViewGlance
		jz	SkipLGlance
		
		mov SplitScreenBigMapIsOn,1
		
		mov CockpitViews,1
        mov InWeaponView,0
		test	InCockpit,1	;in cockpit?
		jz	SkipLGlance	;no ->

		mov	ax,VIEW_LPILOT		;assume pilot
		cmp	CrewMode,CREW_PILOT	;pilot?
		je	@F			;yes ->
		mov	ax,VIEW_LNAVIG

@@:		call	ChgGameViewMode
		jc	SkipLGlance	;mode already set ->

		mov	PrevViewMode,ax

		mov	GlanceFlag,1

		mov	GlanceKeyPtr,OFFSET KF_LViewGlance[K_STATUS]

		jmp	UpdateView

;---------------------------------------------
;* right view (glance), sort pilot / navigator
;---------------------------------------------

SkipLGlance:	KTEST	KF_RViewGlance
		jz	SkipRGlance
		
        mov SplitScreenBigMapIsOn,1
		
		mov CockpitViews,1
        mov InWeaponView,0
		test	InCockpit,1	;in cockpit?
		jz	SkipRGlance	;no ->

		mov	ax,VIEW_RPILOT		;assume pilot
		cmp	CrewMode,CREW_PILOT	;pilot?
		je	@F			;yes ->
		mov	ax,VIEW_RNAVIG

@@:		call	ChgGameViewMode
		jc	SkipRGlance	;mode already set ->

		mov	PrevViewMode,ax

		mov	GlanceFlag,1

		mov	GlanceKeyPtr,OFFSET KF_RViewGlance[K_STATUS]

		jmp	UpdateView

;----------------------
;* tracking camera view
;----------------------

SkipRGlance:	
                mov ah, Key[K_ALT]
                and ah, Key[K_F1]
        ;KTEST  KF_TrackingCam
		jz	SkipKF_TrackingCamUp
		
        mov SplitScreenBigMapIsOn,0
		
		mov CockpitViews,0
        mov InWeaponView,1
		IntoTracking:	mov	ax,VIEW_TRACKING
		call	ChgGameViewMode
		jnc	@F		;change successful ->
		;neg	TrkCamAlt	;toggle above / below
		add TrkCamAlt,2
                KBOUNCE KF_TrackingCamUp
		
@@:		jmp	UpdateView


SkipKF_TrackingCamUp:

        ;KTEST	KF_TrackingCamUp
		KTEST	KF_TrackingCam
		jz	SkipTrackingZRK_and_ZSU

        mov SplitScreenBigMapIsOn,0
		
		mov CurrentViewIsCheckSix,0
		mov CockpitViews,0
		;mov InCockpit,0
        mov InWeaponView,1
  	    mov	ax,VIEW_TRACKING
		call	ChgGameViewMode
		jnc	@F		;change successful ->
		;neg	TrkCamAlt	;toggle above / below
		sub TrkCamAlt,2
		;KBOUNCE KF_TrackingCamUp
                KBOUNCE KF_TrackingCam
@@:		jmp	UpdateView

		
;-------------------------------------------------------------
;* ZRK and ZSU tracking camera view (Cloned from Tracking View
;-------------------------------------------------------------
SkipTrackingZRK_and_ZSU:	
		;mov ah, Key[K_CTRL]
		;and ah, Key[K_SHIFT]		
        KTEST KF_ArmorCtrlShift		
		jz	SkipKF_TrackingCamUp2

        mov SplitScreenBigMapIsOn,0
		
		;mov InCockpit,0
        mov CurrentViewIsCheckSix,0		
		mov CockpitViews,0
        mov InWeaponView,1
  	    mov	ax,VIEW_ZRK_AAA
		call	ChgGameViewMode
		jnc	@F		;change successful ->
		;neg	TrkCamAlt	;toggle above / below
		add TrkCamAlt2,2 ;originally was sub
		KBOUNCE KF_ArmorCtrlShift		
@@:		jmp	UpdateView

SkipKF_TrackingCamUp2:	
        ;KTEST	KF_TrackingCam
		   ;KTEST KF_ChangeArmor
		;mov ah, Key[K_CTRL]
		;and ah, Key[K_ALT]		   
		KTEST KF_ArmorCtrlAlt
		jz	SkipTracking

        mov SplitScreenBigMapIsOn,0
		
		mov CurrentViewIsCheckSix,0
		mov CockpitViews,0
        mov InWeaponView,1
		;IntoTracking:	mov	ax,VIEW_ZRK_AAA
		mov	ax,VIEW_ZRK_AAA
		call	ChgGameViewMode
		jnc	@F		;change successful ->
		;neg	TrkCamAlt	;toggle above / below
		sub TrkCamAlt2,2  ;originally was add
		KBOUNCE KF_ArmorCtrlAlt		
@@:		jmp	UpdateView


;-----------------------
;* satellite camera view
;-----------------------

SkipTracking:	KTEST	KF_SatelliteCam
		jz	SkipSatellite

        mov SplitScreenBigMapIsOn,0
		
		mov CurrentViewIsCheckSix,1
		;mov InCockpit,0
		mov CockpitViews,0
		mov InWeaponView,1
		
        mov	ax,VIEW_SATELLITE
		call	ChgGameViewMode
		jnc	@F		;change successful ->

;* must have been VIEW_SATELLITE already so toggle topside / underside

		xor	SatCamSide,0ffffh
		
@@:		jmp	UpdateView

;---------------
;* map view mode
;---------------

SkipSatellite:	       
		KTEST	KF_MapView
		jz	SkipMapView	
        ;mov AllowSplitScreenBigMap,1
		;jmp check3
		
	    cmp EScopeToggle,10		
		jbe check1		
		jmp nope
	check1:  		
	    cmp EScopeToggle,0		
		jg check3
		mov SplitScreenBigMapIsOn,0
		jmp nope
	check3: 				
	    mov SplitScreenBigMapIsOn,1
	nope:		
		mov CockpitViews,0
        mov InWeaponView,0
		mov	ax,VIEW_MAP
		call	ChgGameViewMode

		jmp	UpdateView

;-----------------
;* drone view mode
;-----------------

SkipMapView:	
		
        KTEST	KF_DroneSide	;allied / enemy toggle?
		jz	SkipDroneSide	;no ->
		
        mov SplitScreenBigMapIsOn,0		
		
		;mov InCockpit,0
		mov CurrentViewIsCheckSix,0
		mov CockpitViews,0
        mov InWeaponView,0
;* if GameViewMode = VIEW_DRONE then
;*    tmp = DroneMode xor A_E_TOGGLE
;*    if CurrentDroneOk(tmp) then
;*       DroneMode = tmp
;*    else
;*       if SelectNextDrone(tmp) = drone available then
;*          DroneMode = tmp
;*       endif
;*    endif
;* endif

		cmp	GameViewMode,VIEW_DRONE	;drone view mode?
		jne	FailDroneSide		;no ->

		mov	bx,DroneMode
		xor	bx,A_E_TOGGLE

		call	CurrentDroneOk
		jnc	@F		;current drone ok ->

		call	SelectNextDrone
		jc	FailDroneSide	;no drone available ->

@@:		mov	DroneCrntPtrs[bx],si
		
		mov	DroneMode,bx

FailDroneSide:	jmp	UpdateView

SkipDroneSide:	KTEST	KF_DroneType	;air / ground toggle?
		jz	SkipDroneType	;no ->

        mov SplitScreenBigMapIsOn,0		
		
		;mov InCockpit,0
		mov CurrentViewIsCheckSix,0
		mov CockpitViews,0
        mov InWeaponView,0
			
;* if GameViewMode = VIEW_DRONE then
;*    tmp = DroneMode xor AIR_GND_TOGGLE
;*    if CurrentDroneOk(tmp) then
;*       DroneMode = tmp
;*    else
;*       if SelectNextDrone(tmp) = drone available then
;*          DroneMode = tmp
;*       endif
;*    endif
;* endif

		cmp	GameViewMode,VIEW_DRONE	;drone view mode?
		jne	FailDroneType		;no ->

		mov	bx,DroneMode
		xor	bx,AIR_GND_TOGGLE

		call	CurrentDroneOk
		jnc	@F		;current drone ok ->

		call	SelectNextDrone
		jc	FailDroneType	;no drone available ->

@@:		mov	DroneCrntPtrs[bx],si
		
		mov	DroneMode,bx

FailDroneType:	jmp	UpdateView

SkipDroneType:	
        KTEST	KF_DroneView	;drone view / next drone?
		jz	SkipDroneView	;no ->	
        mov SplitScreenBigMapIsOn,0		
		mov CurrentViewIsCheckSix,0
		mov InWeaponView,1
		
;* ignore drone view if two player
		test	TwoPlayer,1
		jnz	SkipDroneView	

;* if GameViewMode = VIEW_DRONE then
;*    tmp = DroneMode
;*    if select next drone then
;*       if SelectNextDrone(tmp) = drone available then
;*          DroneMode = tmp
;*       endif
;*    else
;*       if SelectPrevDrone(tmp) = drone available then
;*          DroneMode = tmp
;*       endif
;*    endif
;* else
;*    if SelectAnyDrone(DroneMode) = drone available then
;*       GameViewMode = VIEW_DRONE
;*    endif
;* endif

		cmp	GameViewMode,VIEW_DRONE	;drone view mode?
		jne	IntoDroneView		;no ->

		KTEST	KF_DronePrev	;next or previous?
		jnz	@F		;previous ->
		mov CurrentViewIsCheckSix,0
		;mov InCockpit,0	
		
		mov CockpitViews,0
		mov InWeaponView,1
		mov	bx,DroneMode

		call	SelectNextDrone
		jc	FailDroneView  	;no drone available ->

		mov	DroneCrntPtrs[bx],si
		
		mov	DroneMode,bx
		
		jmp	UpdateView

@@:     KBOUNCE KF_DronePrev
        mov	bx,DroneMode

		call	SelectPrevDrone
		jc	FailDroneView  	;no drone available ->

		mov	DroneCrntPtrs[bx],si
		
		mov	DroneMode,bx

		jmp	UpdateView

IntoDroneView:	call	SelectAnyDrone
		jc	FailDroneView	;no drone available ->

		mov	DroneCrntPtrs[bx],si

		mov	DroneMode,bx

		mov	ax,VIEW_DRONE
		call	ChgGameViewMode

FailDroneView:	jmp	UpdateView

;----------------
;* spectator view
;----------------

SkipDroneView:	
        KTEST	KF_Spectator
		jz	SkipSpectator

        mov SplitScreenBigMapIsOn,0		
		
		mov CurrentViewIsCheckSix,0
		;mov InCockpit,0
		mov CockpitViews,0
        mov InWeaponView,1
		;KBOUNCE KF_Spectator
		
;* set spectator view, if already spectating then catch up with Tornado

		mov	ax,VIEW_SPECTATOR
		
		call	ChgGameViewMode
		jc	CatchTornado
		;jmp CatchTornado

;* if restore spectator view then check SPEC_VIEW is valid

		KTEST	KF_RestoreSpec
		jz	@F
        mov CockpitViews,0
		test	SpecValid,1
		jz	@F

		jmp	UpdateView

;* if ViewPtr <> -1 (viewpoint valid) then
;*    SPEC_VIEW = V_VIEW
;* else
;*    SPEC_VIEW = M_VIEW
;* endif

@@:		mov	si,OFFSET V_VIEW	;assume viewpoint valid V_VIEW

		cmp	ViewPtr,-1		;viewpoint valid?
		jne	@F			;yes ->

CatchTornado:	mov	si,OFFSET M_VIEW

@@:		COPY_VP	SPEC_VIEW,si

		mov	SPEC_VIEW.VP_ROLL,0	;keep horizon level - hack

;* ensure zft never zero

		mov	ax,WORD PTR SPEC_VIEW.VP_ZFT_LO
		or	ax,WORD PTR SPEC_VIEW.VP_ZFT_HI
		jnz	@F

		mov	WORD PTR SPEC_VIEW.VP_ZFT_LO,1

;* set SPEC_VIEW valid flag

@@:		mov	SpecValid,1

		jmp	UpdateView

;-------------
;* remote view
;-------------

SkipSpectator:	KTEST	KF_RemoteView
		jz	SkipRemote

        mov SplitScreenBigMapIsOn,0		
		
		mov CurrentViewIsCheckSix,0
		;mov InCockpit,0
		mov CockpitViews,0
        mov InWeaponView,1
		mov	ax,VIEW_REMOTE
		call	ChgGameViewMode
			
;* drop viewpoint anchor
        
        mov	si,OFFSET V_VIEW     ;hack change M_VIEW to V_VIEW - flyby view
		
		COPY_VP	REM_VIEW,si    

		;mov	REM_VIEW.VP_ROLL,0	;keep horizon level - comment off
		
;* ensure zft never zero

		mov	ax,WORD PTR REM_VIEW.VP_ZFT_LO
		or	ax,WORD PTR REM_VIEW.VP_ZFT_HI
		jnz	@F

		mov	WORD PTR REM_VIEW.VP_ZFT_LO,1

@@:		jmp	UpdateView



;--------------------------------
;* ZRK ROMB (SAM, SA-8) to Tornado view
;--------------------------------
SkipRemote:	KTEST	KF_SAMLauncherToTornado
		jz	SkipSAMLauncherToTornado1
		
        mov SplitScreenBigMapIsOn,0		
		
		;mov InCockpit,0
		mov CurrentViewIsCheckSix,0
		mov CockpitViews,0
        mov InWeaponView,1
		mov	ax,VIEW_ZRK ;VIEW_ZRK
		call	ChgGameViewMode
			
        mov bx, 32 ; Pitch of 32
		mov	SAM_VIEW.VP_PITCH,bx
		mov	si,OFFSET SAM_VIEW     
		COPY_VP	REM_VIEW,si
		mov	REM_VIEW.VP_PITCH,bx
		;mov	REM_VIEW.VP_ROLL,0	;keep horizon level - comment off
		;call	AdjustZoom
;* ensure zft never zero

		;mov	cx,SatCamDist
		;mov	bx,SatCamDistFine
		;call	AdjustZoom

mov	WORD PTR REM_VIEW.VP_PITCH,bx
mov	WORD PTR REM_VIEW.VP_ZFT_LO,0 ;50

;add	WORD PTR REM_View.VP_ZFT_LO,ZFT_COCKPIT-2
;adc	WORD PTR REM_View.VP_ZFT_HI,0

		;add	WORD PTR REM_View.VP_ZFT_LO,SAM_GOPHER
		;add	WORD PTR REM_View.VP_XFT,SAM_GOPHER
		;add	WORD PTR REM_View.VP_YFT,SAM_BUFFER
		;adc	WORD PTR REM_View.VP_ZFT_HI,0
				
        mov ax,0
		add	WORD PTR REM_View.VP_ZFT_LO,ax
		;add	WORD PTR REM_View.VP_XFT,10;SAM_GOPHER
		;mov ax,25
		;add	WORD PTR REM_View.VP_XFT,ax;SAM_BUFFER
		adc	WORD PTR REM_View.VP_ZFT_HI,0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;; ??? ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
;* adjust position wrt camera bearing and distance

		KTEST KF_ZoomOut
		jz SkipZRK1
		mov CockpitViews,0
		mov InWeaponView,1
		;mov	TMP_VIEW.VP_PITCH,-10 ;hack from -10 
		sub ZRKrombCamDist, 2
		KBOUNCE KF_ZoomOut
		jmp SkipZRK2
SkipZRK1:
		KTEST KF_ZoomIn
		jz SkipZRK2
		mov CockpitViews,0
		mov InWeaponView,1
		;mov	TMP_VIEW.VP_PITCH,-10 ;hack from -10 
		add ZRKrombCamDist, 2
		KBOUNCE KF_ZoomIn
SkipZRK2:
        mov ax, ZRKrombCamDist ;Where 128 is actually TrkCamDist
;;;;;;;;;;;;;;;;;;;;;;;;;;;		
		;mov	ax,80 ;Where 128 is actually TrkCamDist
		xchg	ax,dx
		and	ax,511		;0 .. 511 pdegs

		REPT	5		;*32 scaling
		sal	dx,1
		ENDM

		call	CalcDeltaXY	;cx = delta x, bx = delta y

;* /32 scaling using abs(value) for 1/2 bit round up (for improved accuracy)

		mov	ax,cx
		ABSV	ax		;ax = abs(x), dx = sign(x)
		REPT	5		;/32 scaling
		shr	ax,1
		ENDM
		adc	ax,0		;1/2 bit round up
		xor	ax,dx		;restore sign
		sub	ax,dx
		mov	cx,ax

		mov	ax,bx		;ax = abs(y), dx = sign(y)
		ABSV	ax
		REPT	5		;/32 scaling
		shr	ax,1
		ENDM
		adc	ax,0		;1/2 bit round up
		xor	ax,dx		;restore sign
		sub	ax,dx
		mov	bx,ax

		MOVEXY	REM_VIEW,cx,bx
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		mov	ViewPtr,OFFSET REM_VIEW
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
		
        mov	ax,WORD PTR REM_VIEW.VP_ZFT_LO
		or	ax,WORD PTR REM_VIEW.VP_ZFT_HI
		;mov	ax,WORD PTR REM_VIEW.VP_ZFT_LO
		;or	ax,WORD PTR REM_VIEW.VP_ZFT_HI
		jnz	@F
        ;mov	WORD PTR M_VIEW.VP_ZFT_LO,1
		;mov	WORD PTR REM_VIEW.VP_ZFT_LO,1
	;mov REM_VIEW.VP_PITCH,100	
	;mov M_VIEW.VP_PITCH,100	

@@:	
        mov ax, 32
		mov	REM_VIEW.VP_PITCH, ax 	
		
		jmp	UpdateView


;-----------------------------------------
;* ZSU-23-4 Shilka to Tornado View (First)
;-----------------------------------------
SkipSAMLauncherToTornado1:	
        KTEST	KF_AAAToTornadoView1
		jz	SkipAAAToTornado2
		
        mov SplitScreenBigMapIsOn,0		
		
		;mov InCockpit,0
		mov CurrentViewIsCheckSix,0
		mov CockpitViews,0
        mov InWeaponView,1
		mov	ax,VIEW_ZSU1;VIEW_ZSU1
		call	ChgGameViewMode
			

		mov bx, 50 ;32
		mov	AAA_VIEW1.VP_PITCH,bx ;100
		mov	si,OFFSET AAA_VIEW1
		COPY_VP	REM_VIEW,si
		mov	REM_VIEW.VP_PITCH,bx ;100
		;mov	REM_VIEW.VP_ROLL,0	;keep horizon level - comment off
		;call	AdjustZoom
;* ensure zft never zero

		;mov	cx,SatCamDist
		;mov	bx,SatCamDistFine
		;call	AdjustZoom

mov	WORD PTR REM_VIEW.VP_PITCH,bx;30
mov	WORD PTR REM_VIEW.VP_ZFT_LO,0 ;50

;add	WORD PTR REM_View.VP_ZFT_LO,ZFT_COCKPIT-2
;adc	WORD PTR REM_View.VP_ZFT_HI,0

		;add	WORD PTR REM_View.VP_ZFT_LO,SAM_GOPHER
		;add	WORD PTR REM_View.VP_XFT,SAM_GOPHER
		;add	WORD PTR REM_View.VP_YFT,SAM_BUFFER
		;adc	WORD PTR REM_View.VP_ZFT_HI,0
        mov ax,0
		add	WORD PTR REM_View.VP_ZFT_LO,ax
		;add	WORD PTR REM_View.VP_XFT,10;SAM_GOPHER
		;mov ax,25
		;add	WORD PTR REM_View.VP_XFT,ax;SAM_BUFFER
		adc	WORD PTR REM_View.VP_ZFT_HI,0
		
;;;;;;;;;;;;;;;;;;;;;;;;;; ??? ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
;* adjust position wrt camera bearing and distance

		mov	ax,80 ;Where 128 is actually TrkCamDist
		xchg	ax,dx
		and	ax,511		;0 .. 511 pdegs

		REPT	5		;*32 scaling
		sal	dx,1
		ENDM

		call	CalcDeltaXY	;cx = delta x, bx = delta y

;* /32 scaling using abs(value) for 1/2 bit round up (for improved accuracy)

		mov	ax,cx
		ABSV	ax		;ax = abs(x), dx = sign(x)
		REPT	5		;/32 scaling
		shr	ax,1
		ENDM
		adc	ax,0		;1/2 bit round up
		xor	ax,dx		;restore sign
		sub	ax,dx
		mov	cx,ax

		mov	ax,bx		;ax = abs(y), dx = sign(y)
		ABSV	ax
		REPT	5		;/32 scaling
		shr	ax,1
		ENDM
		adc	ax,0		;1/2 bit round up
		xor	ax,dx		;restore sign
		sub	ax,dx
		mov	bx,ax

		MOVEXY	REM_VIEW,cx,bx

		mov	ViewPtr,OFFSET REM_VIEW
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

		
        mov	ax,WORD PTR REM_VIEW.VP_ZFT_LO
		or	ax,WORD PTR REM_VIEW.VP_ZFT_HI
		;mov	ax,WORD PTR REM_VIEW.VP_ZFT_LO
		;or	ax,WORD PTR REM_VIEW.VP_ZFT_HI
		jnz	@F
        ;mov	WORD PTR M_VIEW.VP_ZFT_LO,1
		;mov	WORD PTR REM_VIEW.VP_ZFT_LO,1
	mov REM_VIEW.VP_PITCH,50	;30
	mov M_VIEW.VP_PITCH,50    ;30
@@:		jmp	UpdateView


;------------------------------------------
;* ZSU-23-4 Shilka to Tornado View (Second)
;------------------------------------------
SkipAAAToTornado2:
        KTEST	KF_AAAToTornadoView2
		jz	SkipToLookDown
		
        mov SplitScreenBigMapIsOn,0		
		
		mov CurrentViewIsCheckSix,0
		;mov InCockpit,0
		mov CockpitViews,0
        mov InWeaponView,1
		mov	ax,VIEW_ZSU2;VIEW_ZSU2
		call	ChgGameViewMode
			

		mov	AAA_VIEW2.VP_PITCH,50 ;30
		mov	si,OFFSET AAA_VIEW2
		COPY_VP	AAA_VIEW2,si
		mov	AAA_VIEW2.VP_PITCH,50 ;30
		;mov	REM_VIEW.VP_ROLL,0	;keep horizon level - comment off
		;call	AdjustZoom
;* ensure zft never zero

		;mov	cx,SatCamDist
		;mov	bx,SatCamDistFine
		;call	AdjustZoom

mov	WORD PTR AAA_VIEW2.VP_PITCH,50 ;30
mov	WORD PTR AAA_VIEW2.VP_ZFT_LO,0 ;50

;add	WORD PTR REM_View.VP_ZFT_LO,ZFT_COCKPIT-2
;adc	WORD PTR REM_View.VP_ZFT_HI,0

		;add	WORD PTR REM_View.VP_ZFT_LO,SAM_GOPHER
		;add	WORD PTR REM_View.VP_XFT,SAM_GOPHER
		;add	WORD PTR REM_View.VP_YFT,SAM_BUFFER
		;adc	WORD PTR REM_View.VP_ZFT_HI,0
        mov ax,0 ;height of ZSU
		add	WORD PTR AAA_VIEW2.VP_ZFT_LO,ax
		;add	WORD PTR REM_View.VP_XFT,10;SAM_GOPHER
		;mov ax,25
		;add	WORD PTR REM_View.VP_XFT,ax;SAM_BUFFER
		adc	WORD PTR AAA_VIEW2.VP_ZFT_HI,0
		
;;;;;;;;;;;;;;;;;;;;;;;;;; ??? ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
;* adjust position wrt camera bearing and distance

		mov	ax,100 ;Where 128 is actually TrkCamDist
		xchg	ax,dx
		and	ax,511		;0 .. 511 pdegs

		REPT	5		;*32 scaling
		sal	dx,1
		ENDM

		call	CalcDeltaXY	;cx = delta x, bx = delta y

;* /32 scaling using abs(value) for 1/2 bit round up (for improved accuracy)

		mov	ax,cx
		ABSV	ax		;ax = abs(x), dx = sign(x)
		REPT	5		;/32 scaling
		shr	ax,1
		ENDM
		adc	ax,0		;1/2 bit round up
		xor	ax,dx		;restore sign
		sub	ax,dx
		mov	cx,ax

		mov	ax,bx		;ax = abs(y), dx = sign(y)
		ABSV	ax
		REPT	5		;/32 scaling
		shr	ax,1
		ENDM
		adc	ax,0		;1/2 bit round up
		xor	ax,dx		;restore sign
		sub	ax,dx
		mov	bx,ax

		MOVEXY	AAA_VIEW2,cx,bx

		mov	ViewPtr,OFFSET AAA_VIEW2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

		
        mov	ax,WORD PTR AAA_VIEW2.VP_ZFT_LO
		or	ax,WORD PTR AAA_VIEW2.VP_ZFT_HI
		;mov	ax,WORD PTR REM_VIEW.VP_ZFT_LO
		;or	ax,WORD PTR REM_VIEW.VP_ZFT_HI
		jnz	@F
        ;mov	WORD PTR M_VIEW.VP_ZFT_LO,1
		;mov	WORD PTR REM_VIEW.VP_ZFT_LO,1
	mov AAA_VIEW2.VP_PITCH,50	;30
	mov M_VIEW.VP_PITCH,50      ;30
@@:		jmp	UpdateView



;----------------
;* look down view
;----------------
SkipToLookDown:	KTEST	KF_LookDown
		jz	SkipLookDown 
		
        mov SplitScreenBigMapIsOn,0		
		
		;mov InCockpit,1
		mov CockpitViews,1
        mov InWeaponView,0
		mov	ax,VIEW_LOOKDOWN
		call	ChgGameViewMode

		jmp	UpdateView

;-------------
;* weapon view
;-------------

SkipLookDown:	KTEST	KF_ViewWeapon
		jz	UpdateView
		
        mov SplitScreenBigMapIsOn,0		
		
		mov CurrentViewIsCheckSix,0
		mov HorizonValue6, 30
		mov CockpitViews,0
		;mov InWeaponView,1  ;This line is compiled gives a bizarre
		                     ;graphic if Tonka is on runaway and you hit the V key!
		;mov InWeaponView,0   ;So let's see what happens if we set 
		                     ;InWeaponView to 0
		mov	WpnCamBrg,300 ;256-->300

		cmp	ViewWeaponPtr,-1	;weapon available?
		je	UpdateView		;no ->
		
		mov	ax,VIEW_WEAPON
		call	ChgGameViewMode
		jc	UpdateView		;already weapon view ->
		
;* ensure correct view if current weapon expired

		mov	si,ViewWeaponPtr   ;SAM_VIEW??

		mov	ax,WPNDATA
		mov	ds,ax

		mov	bx,_WPN_TYPE[si]

		add	si,MOB_REC_SIZE		;si -> viewpoint data

		COPY_VP	WPN_VIEW,si
		;mov	WPN_VIEW.VP_ROLL,0	;keep horizon level - hack
		
		mov	ax,DATA
		mov	ds,ax

		cmp	bx,NULL_WEAPON
		jne	UpdateView

		cmp	WORD PTR WPN_VIEW.VP_ZFT_HI,0
		ja	@F

		mov	si,OFFSET WPN_VIEW
		call	CalcGndHeight

		
		cmp	WORD PTR WPN_VIEW.VP_ZFT_LO,ax
		ja	@F

		mov	al,1		;overhead

		jmp	SetExpView

@@:		xor	al,al		;normal

SetExpView:	mov	WpnExpView,al

;------------------
;* update game view
;------------------
		
UpdateView:	COPY_VP	TMP_VIEW,M_VIEW
		
		cmp	ShakeUp,1
		_JNE  exitdamagestatus
		
		;Damage Ascertain - results in SHAKE of various degrees! kbs
        cmp SSF_HUD,1	
		jne	@F
		SHAKE	SHAKE_NOSE_DOWN,HSHAKE_LO,VSHAKE_OFF,65535;
@@:		
        cmp SSF_PilotMFD,1	
		jne	@F
		SHAKE	SHAKE_NOSE_DOWN,HSHAKE_LO,VSHAKE_OFF,65535;
@@:		
        cmp SSF_NavigMFD,1	
		jne	@F
		SHAKE	SHAKE_NOSE_DOWN,HSHAKE_LO,VSHAKE_OFF,65535;
@@:		
        cmp SSF_TAB1,1	
		jne	@F
		SHAKE	SHAKE_NOSE_DOWN,HSHAKE_LO,VSHAKE_OFF,65535;
@@:		
        cmp SSF_TAB2,1	
		jne	@F
		SHAKE	SHAKE_NOSE_DOWN,HSHAKE_LO,VSHAKE_OFF,65535;
@@:		
        cmp SSF_CommsRx,1	
		jne	@F
		SHAKE	SHAKE_NOSE_DOWN,HSHAKE_LO,VSHAKE_OFF,65535;
@@:		
        cmp SSF_Oxygen,1	
		jne	@F
		SHAKE	SHAKE_NOSE_DOWN,HSHAKE_LO,VSHAKE_OFF,65535;
@@:		
        cmp SSF_Radar,1	
		jne	@F
		SHAKE	SHAKE_NOSE_DOWN,HSHAKE_LO,VSHAKE_OFF,65535;
@@:		
        cmp SSF_ECM,1	
		jne	@F
		SHAKE	SHAKE_NOSE_DOWN,HSHAKE_LO,VSHAKE_OFF,65535;
@@:		
        cmp SSF_RWR,1	
		jne	@F
		SHAKE	SHAKE_NOSE_DOWN,HSHAKE_LO,VSHAKE_OFF,65535;
@@:		
        cmp SSF_ADC,1
		jne	@F
		SHAKE	SHAKE_NOSE_DOWN,HSHAKE_LO,VSHAKE_OFF,65535;
@@:				
		cmp SSF_RWR,1
		jne	@F
		SHAKE	SHAKE_NOSE_DOWN,HSHAKE_LO,VSHAKE_OFF,65535;
@@:		
		cmp SSF_SPILS,1
		jne	@F		
		SHAKE	SHAKE_NOSE_DOWN,HSHAKE_HI,VSHAKE_LO,65535;		
@@:		
		cmp SSF_Gear,1
		jne	@F
		SHAKE	SHAKE_NOSE_DOWN,HSHAKE_LO,VSHAKE_OFF,65535;
@@:		
		cmp SSF_Flaps,1
		jne	@F
		SHAKE	SHAKE_NOSE_DOWN,HSHAKE_LO,VSHAKE_OFF,65535;
@@:		
		cmp SSF_Sweep,1
		jne	@F
		SHAKE	SHAKE_NOSE_DOWN,HSHAKE_LO,VSHAKE_OFF,65535;
@@:		
		cmp SSF_Engine1,1
		jne	@F
		SHAKE	SHAKE_NOSE_DOWN,HSHAKE_LO,VSHAKE_OFF,65535;
@@:
		cmp SSF_Engine2,1
		jne	@F
		SHAKE	SHAKE_NOSE_DOWN,HSHAKE_LO,VSHAKE_OFF,65535;
@@:		
SkipShakeUp:
		mov	al,SSF_Engine1	;both engines failed?
		and	al,SSF_Engine2	
		jnz	bothenginesdead		;yes ->
		;mov	al,SSF_Engine1	;one engine has failed?
		;or	al,SSF_Engine2	
        ;jz	exitdamagestatus		;no ->
		;SHAKE	SHAKE_NOSE_DOWN,HSHAKE_HI,VSHAKE_LO,65535;
        jz	exitdamagestatus
bothenginesdead:
		;SHAKE	SHAKE_NOSE_DOWN,HSHAKE_OFF,VSHAKE_OFF,1;
exitdamagestatus:		
		mov	bx,GameViewMode
		jmp	UpdateSwitch[bx]

;---------------------------
UpdatePilot	LABEL	NEAR
;---------------------------

		mov	ax,ZFT_COCKPIT
		add	WORD PTR TMP_VIEW.VP_ZFT_LO,ax
		adc	WORD PTR TMP_VIEW.VP_ZFT_HI,0

		mov	ViewPtr,OFFSET TMP_VIEW

		jmp	UpdateViewExit

;---------------------------
UpdateLPilot	LABEL	NEAR
UpdateLNavig	LABEL	NEAR
;---------------------------

		mov	ax,ZFT_COCKPIT
		add	WORD PTR TMP_VIEW.VP_ZFT_LO,ax
		adc	WORD PTR TMP_VIEW.VP_ZFT_HI,0

		mov	ViewPtr,OFFSET TMP_VIEW

		jmp	UpdateViewExit

;----------------------4-----
UpdateRPilot	LABEL	NEAR
UpdateRNavig	LABEL	NEAR
;---------------------------

		mov	ax,ZFT_COCKPIT
		add	WORD PTR TMP_VIEW.VP_ZFT_LO,ax
		adc	WORD PTR TMP_VIEW.VP_ZFT_HI,0

		mov	ViewPtr,OFFSET TMP_VIEW

		jmp	UpdateViewExit

;---------------------------
UpdateNavig	LABEL	NEAR
;---------------------------

		mov	ViewPtr,-1

		jmp	UpdateViewExit

;---------------------------
UpdateTracking	LABEL	NEAR
;---------------------------

    	KTEST	KF_ResetTrkCam	;reset view position?
		jz	@F		;no ->
		mov CockpitViews,0
		mov InWeaponView,1
        ;Below are the original settings
		;mov	TrkCamDist,64
		;mov	TrkCamDistFine,0
		;mov	TrkCamBrg,256
		;mov	TrkCamBrgFine,0
		;mov	TrkCamAlt,16
		;mov	PitchFlip,0
		
		;Modified settings, 25th April 2018
		mov TrkCamDist,62  ;formerly 60-->64-->98
        mov TrkCamDistFine,0
        mov TrkCamBrg,270  ;formerly 270-->
		mov	TrkCamBrgFine,0
		mov	TrkCamAlt,38
		mov	PitchFlip,0
		mov	TMP_VIEW.VP_PITCH,-10
	
;* adjust zoom

@@:		mov	cx,TrkCamDist
		mov	bx,TrkCamDistFine
		call	AdjustZoom ;UpdateTracking
		mov	TrkCamDist,cx
		mov	TrkCamDistFine,bx

;* adjust track

		mov	cx,TrkCamBrg
		mov	bx,TrkCamBrgFine
		call	AdjustTrack  ;UpdateTracking
		mov	TrkCamBrg,cx
		mov	TrkCamBrgFine,bx

		
; Adjust yaw ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		KTEST KF_Yaw ;UpdateTracking
		jz SkipAlex7
		mov InWeaponView,1
		;mov	TMP_VIEW.VP_PITCH,-10 ;hack from -10 
		cmp YawValue,-180 ;haha!
		jle FixToMinus180a
		sub YawValue, 4
		jmp @F
FixToMinus180a:
        mov YawValue,-180
		jmp @F
@@:
		KBOUNCE KF_Yaw
		jmp SkipAlex8
SkipAlex7:
		KTEST KF_GndText ;UpdateTracking
		jz SkipAlex8                                               
		mov InWeaponView,1
		;mov	TMP_VIEW.VP_PITCH,-10 ;hack from -10 
		cmp YawValue,180
		jae FixToPositive180a
		add YawValue,4
		jmp @F
FixToPositive180a:
        cmp YawValue,0
		jle AddTwoToYawValue
        mov YawValue,180
		jmp @F
AddTwoToYawValue:		
        add YawValue,4
@@:		
		KBOUNCE KF_GndText
SkipAlex8:
        mov bx, YawValue
		
		
;* adjust zft

	  	mov	ax,TrkCamAlt		
		cwd
add	WORD PTR TMP_VIEW.VP_YFT,bx ;hack 26th May2018
		add	WORD PTR TMP_VIEW.VP_ZFT_LO,ax
		adc	WORD PTR TMP_VIEW.VP_ZFT_HI,dx

		js	@F		;zft < 0 ->

		mov	ax,WORD PTR TMP_VIEW.VP_ZFT_LO
		or	ax,WORD PTR TMP_VIEW.VP_ZFT_HI

		jnz	ZftOk		;zft > 0 ->

@@:		mov	WORD PTR TMP_VIEW.VP_ZFT_LO,1
		mov	WORD PTR TMP_VIEW.VP_ZFT_HI,0

;* adjust heading, pitch and roll

ZftOk:		mov	dx,TrkCamBrg
		mov	ax,TrkCamBrgFine
		shl	ax,1
		ROUNDUP	dx

		mov	ax,PitchFlip
		and	ax,256			;0 or 180 degs (wrt pitch flip)
		add	ax,TMP_VIEW.VP_HDG	;+ aircraft heading
		add	ax,dx			;+ camera bearing
		mov	dx,ax
		add	ax,256			;+ 180 degs
		and	ax,511			;0 .. 511 pdegs
		mov	TMP_VIEW.VP_HDG,ax

		;cmp TornadoType,IDS_TORNADO	;ADV variant?
		;jne @F
		
		;IDS variant
		KTEST KF_Minimise  ;UpdateTracking
		jz SkipAlex1
		mov InWeaponView,1
		;mov	TMP_VIEW.VP_PITCH,-10 ;hack from -10 
		sub HorizonValue, 2
		add TrkCamAlt,2
		KBOUNCE KF_Minimise
		jmp SkipAlex2
SkipAlex1:
		KTEST KF_Range ;UpdateTracking
		jz SkipAlex2
		mov InWeaponView,1
		;mov	TMP_VIEW.VP_PITCH,-10 ;hack from -10 
		add HorizonValue, 2
		sub TrkCamAlt,2
		KBOUNCE KF_Range
SkipAlex2:
        mov bx, HorizonValue
		mov	TMP_VIEW.VP_PITCH, bx ;hack from -10 
        ;Mod by Frankie Kam on 21st April 2018
        ;User pressed Alt+P to toggle on/off horizon pitching 
		;when in F1 Tracking View mode?
		KTEST	KF_TogglePitchCam	
		jz	@F		;no -> do nothing!
		mov InWeaponView,1
		xor PitchToggle,1 ;Toggle this value from 0 to 1
		;Clear the P (Pause) key. If this line is not executed, 
		;the game will pause!
		KCLEAR KF_Pause 
		;Clear this Control+P key!
		KCLEAR KF_TogglePitchCam 
@@:
        ;Check for 0 or 1
        cmp	PitchToggle,1
		jne @F       ;-->Set the TMP_VIEW.VP_ROLL variable to 0
		jmp SkipRoll ;-->Do nothing if PitchToggle equals to 1
@@:
		mov TMP_VIEW.VP_ROLL,0 
SkipRoll: ;do nothing	
		
;* adjust position wrt camera bearing and distance

		mov	ax,TrkCamDist
		xchg	ax,dx
		and	ax,511		;0 .. 511 pdegs

		REPT	5		;*32 scaling
		sal	dx,1
		ENDM

		call	CalcDeltaXY	;cx = delta x, bx = delta y

;* /32 scaling using abs(value) for 1/2 bit round up (for improved accuracy)

		mov	ax,cx
		ABSV	ax		;ax = abs(x), dx = sign(x)
		REPT	5		;/32 scaling
		shr	ax,1
		ENDM
		adc	ax,0		;1/2 bit round up
		xor	ax,dx		;restore sign
		sub	ax,dx
		mov	cx,ax

		mov	ax,bx		;ax = abs(y), dx = sign(y)
		ABSV	ax
		REPT	5		;/32 scaling
		shr	ax,1
		ENDM
		adc	ax,0		;1/2 bit round up
		xor	ax,dx		;restore sign
		sub	ax,dx
		mov	bx,ax

		MOVEXY	TMP_VIEW,cx,bx

		mov	ViewPtr,OFFSET TMP_VIEW

		jmp	UpdateViewExit
		
;---------------------------
UpdateZRK_AAA	LABEL	NEAR
;---------------------------

    	KTEST	KF_ResetTrkCam	;reset view position?
		jz	@F		;no ->
		mov InWeaponView,1
        ;Below are the original settings
		;mov	TrkCamDist,64
		;mov	TrkCamDistFine,0
		;mov	TrkCamBrg,256
		;mov	TrkCamBrgFine,0
		;mov	TrkCamAlt,16
		;mov	PitchFlip,0
		
		;Modified settings, 25th April 2018
		mov TrkCamDist,64  ;formerly 64
        mov TrkCamDistFine,0
        mov TrkCamBrg,300  ;formerly 270
		mov	TrkCamBrgFine,0
		mov	TrkCamAlt2,38
		mov	PitchFlip,0
		mov	TMP2_VIEW.VP_PITCH,-10
	
;* adjust zoom

@@:		mov	cx,TrkCamDist
		mov	bx,TrkCamDistFine
		call	AdjustZoom  ;UpdateZRK_AAA
		mov	TrkCamDist,cx
		mov	TrkCamDistFine,bx

;* adjust track

		mov	cx,TrkCamBrg
		mov	bx,TrkCamBrgFine
		call	AdjustTrack   ;UpdateZRK_AAA
		mov	TrkCamBrg,cx
		mov	TrkCamBrgFine,bx

		
; Adjust yaw ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		KTEST KF_Yaw ;UpdateZRK_AAA
		jz SkipAlex7b
		mov InWeaponView,1
		;mov	TMP_VIEW.VP_PITCH,-10 ;hack from -10 
		cmp YawValue,-180 ;haha!
		jle FixToMinus180ab
		sub YawValue_ZRK_AAA, 4 
		jmp @F
FixToMinus180ab:
        mov YawValue_ZRK_AAA,-180
		jmp @F
@@:
		KBOUNCE KF_Yaw
		jmp SkipAlex8b
SkipAlex7b:
		KTEST KF_GndText ;UpdateZRK_AAA                              
		jz SkipAlex8b                                         
		mov InWeaponView,1
		;mov	TMP_VIEW.VP_PITCH,-10 ;hack from -10 
		cmp YawValue_ZRK_AAA,180
		jae FixToPositive180ab
		add YawValue_ZRK_AAA,4
		jmp @F
FixToPositive180ab:
        cmp YawValue_ZRK_AAA,0
		jle AddTwoToYawValueb
        mov YawValue_ZRK_AAA,180
		jmp @F
AddTwoToYawValueb:		
        add YawValue_ZRK_AAA,4
@@:		
		KBOUNCE KF_GndText
SkipAlex8b:
        mov bx, YawValue_ZRK_AAA
		
		
;* adjust zft
        ;mov	si,OFFSET SAM_VIEW     
		;mov	si,OFFSET AAA_VIEW2
		
		;mov ah, Key[K_ALT]
		;and ah, Key[K_SHIFT]
		KTEST KF_ChangeArmor
		jz @F
		;KBOUNCE KF_ChangeArmor
		mov CurrentViewIsCheckSix,0
		xor	ToggleZRK_ZSU,1	;alternate between ZRK-Romb and ZSU-23-4		
		jz Skipppper1b
		COPY_VP AAA_or_SAM_value, AAA_VIEW1
		jmp @F
Skipppper1b:		
        COPY_VP AAA_or_SAM_value, SAM_VIEW
@@:				
        KCLEAR KF_ChangeArmor
		;KBOUNCE KF_ChangeArmor
        mov	si,OFFSET AAA_or_SAM_value
		COPY_VP	TMP2_VIEW,si
		
	  	mov	ax,TrkCamAlt2		
		cwd
add	WORD PTR TMP2_VIEW.VP_YFT,bx ;hack 26th May2018
		add	WORD PTR TMP2_VIEW.VP_ZFT_LO,ax
		adc	WORD PTR TMP2_VIEW.VP_ZFT_HI,dx

		js	@F		;zft < 0 ->

		mov	ax,WORD PTR TMP2_VIEW.VP_ZFT_LO
		or	ax,WORD PTR TMP2_VIEW.VP_ZFT_HI

		jnz	ZftOkb		;zft > 0 ->

@@:		mov	WORD PTR TMP2_VIEW.VP_ZFT_LO,1
		mov	WORD PTR TMP2_VIEW.VP_ZFT_HI,0

;* adjust heading, pitch and roll

ZftOkb:		mov	dx,TrkCamBrg
		mov	ax,TrkCamBrgFine
		shl	ax,1
		ROUNDUP	dx

		mov	ax,PitchFlip
		and	ax,256			;0 or 180 degs (wrt pitch flip)
		add	ax,TMP2_VIEW.VP_HDG	;+ aircraft heading
		add	ax,dx			;+ camera bearing
		mov	dx,ax
		add	ax,256			;+ 180 degs
		and	ax,511			;0 .. 511 pdegs
		mov	TMP2_VIEW.VP_HDG,ax

		;cmp TornadoType,IDS_TORNADO	;ADV variant?
		;jne @F
		;IDS variant
		KTEST KF_Minimise ;UpdateZRK_AAA
		jz SkipAlex1b
		mov InWeaponView,1
		;mov	TMP_VIEW.VP_PITCH,-10 ;hack from -10 
		sub HorizonValue_ZRK_AAA, 2
		KBOUNCE KF_Minimise
		jmp SkipAlex2b
SkipAlex1b:
		KTEST KF_Range ;UpdateZRK_AAA
		jz SkipAlex2b
		mov InWeaponView,1
		;mov	TMP_VIEW.VP_PITCH,-10 ;hack from -10 
		add HorizonValue_ZRK_AAA, 2
		KBOUNCE KF_Range
SkipAlex2b:
        mov bx, HorizonValue_ZRK_AAA
		mov	TMP2_VIEW.VP_PITCH, bx ;hack from -10 
        ;Mod by Frankie Kam on 21st April 2018
        ;User pressed Control+P to toggle on/off horizon pitching 
		;when in F1 Tracking View mode?
		KTEST	KF_TogglePitchCam	
		jz	@F		;no -> do nothing!
		mov InWeaponView,1
		xor PitchToggle,1 ;Toggle this value from 0 to 1
		;Clear the P (Pause) key. If this line is not executed, 
		;the game will pause!
		KCLEAR KF_Pause 
		;Clear this Control+P key!
		KCLEAR KF_TogglePitchCam 
@@:
        ;Check for 0 or 1
        cmp	PitchToggle,1
		jne @F       ;-->Set the TMP_VIEW.VP_ROLL variable to 0
		jmp SkipRoll2 ;-->Do nothing if PitchToggle equals to 1
@@:
		mov TMP2_VIEW.VP_ROLL,0 
SkipRoll2: ;do nothing	
		
;* adjust position wrt camera bearing and distance

		mov	ax,TrkCamDist
		xchg	ax,dx
		and	ax,511		;0 .. 511 pdegs

		REPT	5		;*32 scaling
		sal	dx,1
		ENDM

		call	CalcDeltaXY	;cx = delta x, bx = delta y

;* /32 scaling using abs(value) for 1/2 bit round up (for improved accuracy)

		mov	ax,cx
		ABSV	ax		;ax = abs(x), dx = sign(x)
		REPT	5		;/32 scaling
		shr	ax,1
		ENDM
		adc	ax,0		;1/2 bit round up
		xor	ax,dx		;restore sign
		sub	ax,dx
		mov	cx,ax

		mov	ax,bx		;ax = abs(y), dx = sign(y)
		ABSV	ax
		REPT	5		;/32 scaling
		shr	ax,1
		ENDM
		adc	ax,0		;1/2 bit round up
		xor	ax,dx		;restore sign
		sub	ax,dx
		mov	bx,ax

		MOVEXY	TMP2_VIEW,cx,bx

		mov	ViewPtr,OFFSET TMP2_VIEW

		jmp	UpdateViewExit

;---------------------------
UpdateSatellite	LABEL	NEAR
;---------------------------
        KTEST	KF_ResetSatCam	;reset view position?
		jz	@F		;no ->
		mov InWeaponView,1
		mov	SatCamDist,32 ;Previously was 64
		mov	SatCamDistFine,0
        mov PitchFlip,0
        mov SatCamSide,270
;* adjust heading, pitch and roll	
@@:     mov dx,SatCamSide
        and dx,0
        mov ax, PitchFlip
        and ax,0
        add ax,dx
        add ax,TMP_VIEW.VP_HDG
        and ax,511
		mov TMP_VIEW.VP_HDG,ax
		mov ax,270
		sub ax,dx
		mov TMP_VIEW.VP_PITCH,90

		KTEST	KF_TogglePitchCam	
		jz	@F		;no -> do nothing!
		mov InWeaponView,1
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
		xor PitchToggle,1 ;Toggle this value from 0 to 1
		;Clear the P (Pause) key. If this line is not executed, the game will pause!
		KCLEAR KF_Pause 
		KCLEAR KF_TogglePitchCam ;Clear this Control+P key!
@@:
        cmp	PitchToggle,1
		jne @F       ;-->Set the TMP_VIEW.VP_ROLL variable to 0
		jmp SkipRoll3 ;-->Do nothing if PitchToggle equals to 1
@@:
		mov TMP_VIEW.VP_ROLL,0  ;Don't roll the horizon!
SkipRoll3: ;do nothing			
		
		
;* adjust position wrt camera distance
		mov	cx,SatCamDist
		mov	bx,SatCamDistFine
		call	AdjustZoom
		mov	SatCamDist,cx
		mov	SatCamDistFine,bx
		mov	ax,cx
		mov	dx,SatCamSide
		xor	ax,dx
		sub	ax,dx
		cwd
		add	WORD PTR TMP_VIEW.VP_ZFT_LO,ax  ;<--- 0 nice!!! Latest  ax	
		adc	WORD PTR TMP_VIEW.VP_ZFT_HI,dx
		js	@F		;zft < 0 ->
		mov	ax,WORD PTR TMP_VIEW.VP_ZFT_LO
		or	ax,WORD PTR TMP_VIEW.VP_ZFT_HI
		jnz	SatCamZftOk	;zft > 0 ->
@@:		mov	WORD PTR TMP_VIEW.VP_ZFT_LO,1
		mov	WORD PTR TMP_VIEW.VP_ZFT_HI,0

SatCamZftOk:	mov	ViewPtr,OFFSET TMP_VIEW

		KTEST KF_Range  ;UpdateTracking
		jz SkipAlexis1
		mov InWeaponView,1
		sub HorizonValue3, 2
		KBOUNCE KF_Range
		jmp SkipAlexis2
SkipAlexis1:
		KTEST  KF_Minimise;UpdateTracking
		jz SkipAlexis2
		mov InWeaponView,1
		add HorizonValue3, 2
		KBOUNCE KF_Minimise
SkipAlexis2:
        mov bx, HorizonValue3
		mov	TMP_VIEW.VP_PITCH, bx ;hack from -10 
		jmp	UpdateViewExit
		
;---------------------------
UpdateMap	LABEL	NEAR
;---------------------------

		mov	si,OFFSET TMP_VIEW

		call	MapView

		mov	ViewPtr,-1

		jmp	UpdateViewExit

;---------------------------
UpdateDrone	LABEL	NEAR
;---------------------------

;* tmp = DroneMode
;*
;* if SelectAnyDrone(tmp) = drone available then
;*    DroneMode = tmp
;* else
;*    default to tracking mode
;* endif

		mov	bx,DroneMode

		call	SelectAnyDrone
		_JC	IntoTracking	;no drones available ->

		mov	DroneCrntPtrs[bx],si
		
		mov	DroneMode,bx

		mov	si,[si]		;si -> compound mobile data block

;* calc min dist wrt object size (min dist = max(object size * 2, 64))

		mov	al,[si].MOB_NUM	

		push	bx
		push	si
		call	CalcMobMaxDim
		pop	si
		pop	bx

		shl	ax,1		;min dist = size * 2
		cmp	ax,98		;min dist >= 64ft?  Previously was 64.
		jae	@F		;yes ->
		mov	ax,98  ;Prev was 64
@@:		mov	bp,ax

		add	si,MOB_REC_SIZE	;si -> VIEWPOINT data

		COPY_VP	TMP_VIEW,si
		mov	si,bx		;si = drone mode

;* adjust zoom

		mov	cx,DrnCamDist[si]
		mov	bx,DrnCamDistFine[si]

		call	AdjustZoom

		cmp	cx,bp		;dist >= min dist?
		jae	@F		;yes ->
		mov	cx,bp
		xor	bx,bx

@@:		mov	DrnCamDist[si],cx
		mov	DrnCamDistFine[si],bx

;* adjust track

		mov	cx,DrnCamBrg[si]
		mov	bx,DrnCamBrgFine[si]
		call	AdjustTrack  ;UpdateDrone
		mov	DrnCamBrg[si],cx
		mov	DrnCamBrgFine[si],bx

; Adjust yaw ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		KTEST KF_Yaw
		jz SkipCandy9
		mov InWeaponView,1
		;mov	TMP_VIEW.VP_PITCH,-10 ;hack from -10 
		cmp YawValue2,-180 ;haha!
		jle FixToMinus180b
		sub YawValue2, 4
		jmp @F
FixToMinus180b:
        mov YawValue2,-180
		jmp @F
@@:
		KBOUNCE KF_Yaw
		jmp SkipCandy8
SkipCandy9:
		KTEST KF_GndText ;K_2                                      
		jz SkipCandy8                                               
		mov InWeaponView,1
		;mov	TMP_VIEW.VP_PITCH,-10 ;hack from -10 
		cmp YawValue2,180
		jae FixToPositive180b
		add YawValue2,4
		jmp @F
FixToPositive180b:
        cmp YawValue2,0
		jle AddTwoToYawValue2
        mov YawValue2,180
		jmp @F
AddTwoToYawValue2:		
        add YawValue2,4
@@:		
		KBOUNCE KF_GndText
SkipCandy8:
        mov ax, YawValue2
		
        add	WORD PTR TMP_VIEW.VP_YFT,ax ;hack 26th May2018		

		
;* adjust zft (zft = max(zft + 16, 32))
        

		mov	ax,WORD PTR TMP_VIEW.VP_ZFT_LO
		mov	dx,WORD PTR TMP_VIEW.VP_ZFT_HI

		add	ax,16
		adc	dx,0

		jnz	@F		;zft > 65,535ft ->

		cmp	ax,32
		jae	@F   		;zft >= 32ft ->

		mov	ax,32
		
		
	
@@:		
        ; Added code by Frankie Kam on 25th May 2018
		; Nice visual cinematic effects with the keys 1 and 0
		;
		add	ax,HorizonValue2  ;amazing at last! sub
        mov	WORD PTR TMP_VIEW.VP_ZFT_LO,ax
		mov	WORD PTR TMP_VIEW.VP_ZFT_HI,dx
	
;* adjust heading, pitch and roll

		mov	dx,DrnCamBrg[si]
		mov	ax,DrnCamBrgFine[si]
		shl	ax,1
		ROUNDUP	dx

		mov	ax,TMP_VIEW.VP_HDG	;drone heading
		add	ax,dx			;+ camera bearing
		mov	dx,ax
		add	ax,256			;+ 180 degs
		and	ax,511			;0 .. 511 pdegs
		mov	TMP_VIEW.VP_HDG,ax

		KTEST KF_Minimise
		jz SkipAlex5
		mov InWeaponView,1
		add HorizonValue2, 2
		KBOUNCE KF_Minimise
		jmp SkipAlex6
SkipAlex5:
		KTEST KF_Range
		jz SkipAlex6
		mov InWeaponView,1
		sub HorizonValue2, 2
		KBOUNCE KF_Range
SkipAlex6:
        mov bx, HorizonValue2		
		
		mov	TMP_VIEW.VP_PITCH,bx ;hack from 0 to -10 to adjustable! This is it! Motherload!
		

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;Mod by Frankie Kam on 21st April 2018
        ;User pressed Control+P to toggle on/off horizon pitching 
		;when in F1 Tracking View mode?
		KTEST	KF_TogglePitchCam	
		jz	@F		;no -> do nothing!
		mov InWeaponView,1
		xor PitchToggle,1 ;Toggle this value from 0 to 1
		;Clear the P (Pause) key. If this line is not executed, 
		;the game will pause!
		KCLEAR KF_Pause 
		;Clear this Control+P key!
		KCLEAR KF_TogglePitchCam 
@@:
        ;Check for 0 or 1
        cmp	PitchToggle,1
		jne @F       ;-->Set the TMP_VIEW.VP_ROLL variable to 0
		jmp SkipRoll4 ;-->Do nothing if PitchToggle equals to 1
@@:
		mov TMP_VIEW.VP_ROLL,0 
SkipRoll4: ;do nothing	



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
		;mov	TMP_VIEW.VP_ROLL,0   ;hack from 0 to neg zero

;* adjust position wrt camera bearing and distance

		mov	ax,DrnCamDist[si]
		xchg	ax,dx
		and	ax,511		;0 .. 511 pdegs

		REPT	5		;*32 scaling
		sal	dx,1
		ENDM

		call	CalcDeltaXY	;cx = delta x, bx = delta y

;* /32 scaling using abs(value) for 1/2 bit round up (for improved accuracy)

		mov	ax,cx
		ABSV	ax		;ax = abs(x), dx = sign(x)
		REPT	5		;/32 scaling
		shr	ax,1
		ENDM
		adc	ax,0		;1/2 bit round up
		xor	ax,dx		;restore sign
		sub	ax,dx
		mov	cx,ax

		mov	ax,bx		;ax = abs(y), dx = sign(y)
		ABSV	ax
		REPT	5		;/32 scaling
		shr	ax,1
		ENDM
		adc	ax,0		;1/2 bit round up
		xor	ax,dx		;restore sign
		sub	ax,dx
		mov	bx,ax

		MOVEXY	TMP_VIEW,cx,bx

		mov	ViewPtr,OFFSET TMP_VIEW

		jmp	UpdateViewExit

;---------------------------
UpdateSpectator	LABEL	NEAR
;---------------------------

		mov	cx,SPEC_VIEW.VP_HDG
		mov	bx,SpecCamHdgFine
		call	RotateHdg
		mov	SPEC_VIEW.VP_HDG,cx
		
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		KTEST KF_Minimise  ;UpdateTracking
		jz SkipGarry1
		mov InWeaponView,1
		sub HorizonValue5, 2
		KBOUNCE KF_Minimise
		jmp SkipGarry2
SkipGarry1:
		KTEST KF_Range ;UpdateTracking
		jz SkipGarry2
		mov InWeaponView,1
		add HorizonValue5, 2
		KBOUNCE KF_Range
SkipGarry2:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
		
		mov bx, horizonValue5
		mov	SPEC_VIEW.VP_PITCH,bx		
		
		
		
		mov	SpecCamHdgFine,bx

		mov	ViewPtr,OFFSET SPEC_VIEW

		jmp	UpdateViewExit

;---------------------------
UpdateRemote	LABEL	NEAR
;---------------------------

;* calc range and bearing of Tornado from viewpoint

		mov	si,OFFSET REM_VIEW
		mov	di,OFFSET M_VIEW

		call	CalcRngBrgVP_VP

;* if range = 0 then do not update heading or pitch

		mov	bp,ax
		or	bp,dx		;range = 0?
		_JZ	RemoteOk	;yes ->

;* calc max heading change wrt time

		push	ax
		push	dx

;* (if spinning reduce rate to prevent heading flip glitch)

		mov	ax,256		;assume not spinning (180 degs / sec)

		test	SpinFlag,1	;spinning?
		jz	@F		;no ->

		mov	ax,64		;(45 degs / sec)

@@:		mov	dx,DeltaTime
		imul	dx
		FRACADJ	bp

		mov	ax,REM_VIEW.VP_HDG
		mov	dx,bx

		call	CalcAngDiff

		cmp	ax,bp		;abs(hdg diff) > max rate?
		jbe	@F		;no ->
		mov	ax,bp

@@:		xor	ax,dx		;restore sign(hdg diff)
		sub	ax,dx

		add	ax,REM_VIEW.VP_HDG

		and	ax,511

		mov	REM_VIEW.VP_HDG,ax

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		KTEST KF_Minimise  ;UpdateTracking
		jz SkipJake1
		mov InWeaponView,1
		;mov	TMP_VIEW.VP_PITCH,-10 ;hack from -10 
		sub HorizonValue, 2
		KBOUNCE KF_Minimise
		jmp SkipJake2
SkipJake1:
		KTEST KF_Range ;UpdateTracking
		jz SkipJake2
		mov InWeaponView,1
		;mov	TMP_VIEW.VP_PITCH,-10 ;hack from -10 
		add HorizonValue, 2
		KBOUNCE KF_Range
SkipJake2:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
		
		mov bx, horizonValue
		mov	REM_VIEW.VP_PITCH,bx		
		
		pop	dx
		pop	ax

;* z diff = Tornado zft - viewpoint zft

		xor	bp,bp		;assume sign(z diff) = 0

		mov	bx,WORD PTR M_VIEW.VP_ZFT_LO
		mov	cx,WORD PTR M_VIEW.VP_ZFT_HI

		sub	bx,WORD PTR REM_VIEW.VP_ZFT_LO
		sbb	cx,WORD PTR REM_VIEW.VP_ZFT_HI

		jns	ScaleRange	;z diff >= 0 ->

		NEG32	cx,bx

		mov	bp,-1		;sign(z diff) = -1

;* ensure both range and z diff < 32,767

;* while (range > 32,767)
;*    range = range / 2
;*    z diff = z diff / 2
;* endwhile

ScaleRange:	test	dx,dx		;range > 65,535?
		jnz	@F		;yes ->
		cmp	ax,32767	;range > 32,767?
		jbe	ScaleZDiff	;no ->

@@:		shr	dx,1		;range = range / 2
		rcr	ax,1
		shr	cx,1		;z diff = z diff / 2
		rcr	bx,1

		jmp	ScaleRange

;* while (z diff > 32,767)
;*    range = range / 2
;*    z diff = z diff / 2
;* endwhile

ScaleZDiff:	test	cx,cx		;z diff > 65,535?
		jnz	@F		;yes ->
		cmp	bx,32767	;z diff > 32,767?
		jbe	ScaleOk		;no ->

@@:		shr	dx,1		;range = range / 2
		rcr	ax,1
		shr	cx,1		;z diff = z diff / 2
		rcr	bx,1

		jmp	ScaleZDiff

;* ax = range
;* bx = z diff

ScaleOk:	cmp	ax,bx		;range = z diff?
		jne	@F		;no ->

		mov	ax,64		;pitch = 45 degs

		jmp	SetRemotePitch

@@:		jb	@F		;range < z diff ->

;* pitch = arctan(z diff * 32768 / range)

		mov	dx,bx
		mov	bx,ax
		xor	ax,ax

		shr	dx,1		;z diff * 32768 (result is fraction)
		rcr	ax,1

		div	bx		;z diff * 32768 / range

		push	bp
		call	ArcTan		;arctan(z diff * 32768 / range)
		pop	bp

		mov	cl,7		;convert fine pdegs to pdegs
		shr	ax,cl
		ROUNDUP	ax		;(works ok as 0 .. 45 degs only)

		jmp	SetRemotePitch

;* pitch = 128 - arctan(range * 32768 / z diff)

@@:		mov	dx,ax
		xor	ax,ax

		shr	dx,1		;range * 32768 (result is fraction)
		rcr	ax,1

		div	bx		;range * 32768 / z diff

		push	bp
		call	ArcTan		;arctan(range * 32768 / z diff)
		pop	bp

		mov	cl,7		;convert fine pdegs to pdegs
		shr	ax,cl
		ROUNDUP	ax		;(works ok as 0 .. 45 degs only)

		mov	dx,128
		xchg	ax,dx

		sub	ax,dx		;128 - arctan(range * 32768 / z diff)

SetRemotePitch:	xor	ax,bp		;restore sign(z diff)
		sub	ax,bp

		and	ax,001ffh	;0 .. 511 pdegs	
		mov bx, HorizonValue
		mov	REM_VIEW.VP_PITCH,bx ;hack from ax
		
		

RemoteOk:	mov	ViewPtr,OFFSET REM_VIEW

		jmp	UpdateViewExit

;---------------------------
UpdateLookDown	LABEL	NEAR
;---------------------------

		mov	ViewPtr,-1

		jmp	UpdateViewExit

;---------------------------
UpdateLookUp	LABEL	NEAR
;---------------------------

		mov	ax,ZFT_COCKPIT
		
		add	WORD PTR TMP_VIEW.VP_ZFT_LO,ax
		adc	WORD PTR TMP_VIEW.VP_ZFT_HI,0  ;from 0 to -30
        ;mov    TMP_VIEW.VP_PITCH, -160  ;-45 front look, too low kbs
		mov    TMP_VIEW.VP_PITCH, -30  ;-45 front look, too low kbs
		mov	ViewPtr,OFFSET TMP_VIEW
        
		call LoadExtrnPan  ;hacked on 6/11/2017 - calls the info bar (8 pixels) to cover remaining space at bottom
		call UpdateExtrn   ;hacked on 6/11/2017 - calls the info bar (8 pixels) to cover remaining space at bottom
;=== zoom =====	
		mov	cx,DrnCamDist[si]
		mov	bx,DrnCamDistFine[si]

		call	AdjustZoom

		cmp	cx,bp		;dist >= min dist?
		jae	@F		;yes ->
		mov	cx,bp
		xor	bx,bx

@@:		mov	DrnCamDist[si],cx
		mov	DrnCamDistFine[si],bx
;=== zoom =====	
	
	
		jmp	UpdateViewExit
		;=====================================================
		;mov	dx,SatCamSide
		;and	dx,256			;0 or 180 degs (wrt side)  
		;mov	ax,PitchFlip
		;and	ax,256			;0 or 180 degs (wrt pitch flip)
		;add	ax,dx			;adjust wrt side
		;add	ax,TMP_VIEW.VP_HDG	;+ aircraft heading
		;and	ax,511			;0 .. 511 pdegs
		;mov	TMP_VIEW.VP_HDG,ax  ;hacked from ax to 123

		;mov	ax,384	     		;assume topside  from 384 to 0 to 180 to 270
		
		;sub	ax,dx	     		;adjust wrt side
		;mov	TMP_VIEW.VP_PITCH,-115  ;-110 is nice
		        ;mov	TMP_VIEW.VP_ROLL,0
		
		;mov	cx,SatCamDist
		;mov	bx,SatCamDistFine
		;call	AdjustZoom
		;mov	SatCamDist,cx
		;mov	SatCamDistFine,bx

		;mov	ax,cx
		;mov	dx,SatCamSide
		;xor	ax,dx
		;sub	ax,dx

		;cwd

		;add	WORD PTR TMP_VIEW.VP_ZFT_LO,ax
		;adc	WORD PTR TMP_VIEW.VP_ZFT_HI,dx

		;js	@F		;zft < 0 ->

		;mov	ax,WORD PTR TMP_VIEW.VP_ZFT_LO
		;or	ax,WORD PTR TMP_VIEW.VP_ZFT_HI

		;jnz	SatCamZftOk2	;zft > 0 ->

;@@:		mov	WORD PTR TMP_VIEW.VP_ZFT_LO,1
		;mov	WORD PTR TMP_VIEW.VP_ZFT_HI,0

	

;SatCamZftOk2:	mov	ViewPtr,OFFSET TMP_VIEW
        ;call LoadExtrnPan  ;hacked on 6/11/2017 - calls the info bar (8 pixels) to cover remaining space at bottom
		;call UpdateExtrn
		;jmp	UpdateViewExit

;---------------------------
UpdateDemo	LABEL	NEAR
;---------------------------

		call	DemoView

		mov	ViewPtr,OFFSET DEMO_VIEW

		jmp	UpdateViewExit

;---------------------------
UpdateDestroyed	LABEL	NEAR
;---------------------------

		call	DestroyView

		mov	ViewPtr,OFFSET TMP_VIEW

		jmp	UpdateViewExit

;---------------------------
UpdateWeapon	LABEL	NEAR
;---------------------------

		call	WeaponView

		KTEST KF_Minimise  
		jz SkipFrankie1
		mov InWeaponView,1
		sub HorizonValue6, 5
		KBOUNCE KF_Minimise
		jmp SkipFrankie2
SkipFrankie1:
		KTEST KF_Range 
		jz SkipFrankie2
		mov InWeaponView,1
		add HorizonValue6, 5
		KBOUNCE KF_Range
SkipFrankie2:

		mov bx, horizonValue6
		mov WPN_VIEW.VP_PITCH,bx
		
		mov	ViewPtr,OFFSET WPN_VIEW

;----------------------------
;* keep viewpoint above hills
;----------------------------

UpdateViewExit:	mov	si,ViewPtr

		cmp	si,-1				;visual enabled?
		je	SkipHillTest			;no ->

		cmp	WORD PTR [si].VP_ZFT_HI,0	;zft > 65535ft?
		ja	SkipHillTest			;yes ->
		cmp	WORD PTR [si].VP_ZFT_LO,4095	;zft > 4095ft
		ja	SkipHillTest			;yes ->

		push	si
		call	CalcGndHeight
		pop	si

		cmp	WORD PTR [si].VP_ZFT_LO,ax	;vp above hills?
		ja	SkipHillTest			;yes ->

		add	ax,4				;hill height + 4

		mov	WORD PTR [si].VP_ZFT_LO,ax
;call AdjustTrack ;hack ;UpdateViewExit - is this really necessary?
SkipHillTest:	ret

UpdateGameView	ENDP

;----------------------------------------------------------------------------

;* AdjustZoom - adjust camera zoom distance
;*
;* pass: cx, bx = current zoom setting (*65536 scaling)
;* ret : cx, bx = new zoom setting
;* kill: ax, dx, flags

AdjustZoom	PROC	NEAR

;--------------
;* sort zoom in
;--------------

		KTEST	KF_ZoomIn	;zoom in?
		jz	SkipZoomIn	;no ->
        mov InWeaponView,1
		mov	ax,64*256	;64 ft / sec zoom (*256 scaling)
		mov	dx,DeltaTime
		imul	dx
		FRACADJ	ax

		xor	dh,dh		;*256 = *65536 scaling
		mov	dl,ah
		mov	ah,al
		xor	al,al

;* fast zoom?

		test	BYTE PTR KF_FastZoomIn[K_STATUS],1
		jz	@F		;slow ->
		REPT	3		;*8
		shl	ax,1
		rcl	dx,1
		ENDM

@@:		sub	bx,ax
		sbb	cx,dx
		js	SetMinZoom	;< 0, set min zoom dist ->

		cmp	cx,MIN_ZOOM 	;< min zoom dist?
		jae	ZoomOk		;no ->
		
SetMinZoom:	mov	cx,MIN_ZOOM
		mov	bx,0
		jmp	ZoomOk

;---------------
;* sort zoom out
;---------------

SkipZoomIn:	KTEST	KF_ZoomOut	;zoom out?
		jz	ZoomOk		;no ->
        mov InWeaponView,1
		mov	ax,64*256	;64 ft / sec zoom (*256 scaling)
		mov	dx,DeltaTime
		imul	dx
		FRACADJ	ax

		xor	dh,dh		;*256 = *65536 scaling
		mov	dl,ah
		mov	ah,al
		xor	al,al

;* fast zoom?

		test	BYTE PTR KF_FastZoomOut[K_STATUS],1
		jz	@F		;slow ->
		REPT	3		;*8
		shl	ax,1
		rcl	dx,1
		ENDM

@@:		add	bx,ax
		adc	cx,dx

		cmp	cx,MAX_ZOOM 	;> max zoom dist?
		jbe	ZoomOk		;no ->
		
		mov	cx,MAX_ZOOM
		mov	bx,0ffffh

ZoomOk:		ret

AdjustZoom	ENDP

;----------------------------------------------------------------------------

;* AdjustTrack - adjust tracking camera bearing
;*
;* pass: cx, bx = current track setting (*65536 scaling)
;* ret : cx, bx = new track setting
;* kill: ax, dx, flags

AdjustTrack	PROC	NEAR

;* sort clockwise track

		KTEST	KF_TrackClk	;track clockwise?
		jz	SkipTrackClk	;no ->
        mov InWeaponView,1
		mov	ax,32*256	;32 pdeg / sec track (*256 scaling)
		mov	dx,DeltaTime
		imul	dx
		FRACADJ	ax

		xor	dh,dh		;*256 = *65536 scaling
		mov	dl,ah
		mov	ah,al
		xor	al,al

;* fast track clockwise?

		test	BYTE PTR KF_FastTrkClk[K_STATUS],1
		jz	@F		;slow ->
        mov InWeaponView,1
		REPT	2		;*4
		shl	ax,1
		rcl	dx,1
		ENDM

@@:		sub	bx,ax
		sbb	cx,dx
		and	cx,511

		jmp	SkipTrackAClk
		
;* sort anti-clockwise track

SkipTrackClk:	KTEST	KF_TrackAClk	;track anti-clockwise?  ;AdjustTrack
		jz	SkipTrackAClk	;no ->
        mov InWeaponView,1
		mov	ax,32*256	;32 pdeg / sec track (*256 scaling)
		mov	dx,DeltaTime
		imul	dx
		FRACADJ	ax

		xor	dh,dh		;*256 = *65536 scaling
		mov	dl,ah
		mov	ah,al
		xor	al,al

;* fast track anti-clockwise?

		test	BYTE PTR KF_FastTrkAClk[K_STATUS],1
		jz	@F		;slow ->
        mov InWeaponView,1
		REPT	2		;*4
		shl	ax,1
		rcl	dx,1
		ENDM

@@:		add	bx,ax
		adc	cx,dx
		and	cx,511

SkipTrackAClk:	ret

AdjustTrack	ENDP

;----------------------------------------------------------------------------

;* RotateHdg - rotate camera heading
;*
;* pass: cx, bx = current heading (*65536 scaling)
;* ret : cx, bx = new heading
;* kill: ax, dx, flags

RotateHdg	PROC	NEAR

;* sort rotate right

		KTEST	KF_TrackAClk  ;RotateHdg
		jz	SkipRotateRt
        mov InWeaponView,1
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
        mov InWeaponView,1
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
        mov InWeaponView,1
		REPT	2		;*4
		shl	ax,1
		rcl	dx,1
		ENDM

@@:		add	bx,ax
		adc	cx,dx
		and	cx,511

SkipRotateLt:	ret

RotateHdg	ENDP

;----------------------------------------------------------------------------

;* SelectNextDrone - search for next valid drone (if any)
;*
;* pass: bx = drone mode
;* ret : cf = 0: drone selected
;*          si = drone list ptr
;*       cf = 1: no drone available
;* kill: di, bp, flags (except cf)

SelectNextDrone	PROC	NEAR

		mov	si,DroneCrntPtrs[bx]

		mov	bp,si			;store starting place

NextDroneLoop:	cmp	si,DroneListEnds[bx]	;end of list?
		je	@F			;yes ->

		add	si,2			;si -> next drone

		jmp	NextPtrOk

@@:		mov	si,DroneListPtrs[bx]	;si -> first drone

NextPtrOk:	mov	di,[si]			;di -> compound mobile data block

		cmp	_DRONE_SIDE[di],DEAD	;drone valid?
		jne	@F			;yes ->

		cmp	si,bp			;back to starting place?
		jne	NextDroneLoop		;no ->

		stc				;cf = 1 = no drone available

		ret

@@:		clc				;cf = 0 = drone selected

		ret

SelectNextDrone	ENDP

;----------------------------------------------------------------------------

;* SelectPrevDrone - search for previous valid drone (if any)
;*
;* pass: bx = drone mode
;* ret : cf = 0: drone selected
;*          si = drone list ptr
;*       cf = 1: no drone available
;* kill: di, bp, flags (except cf)

SelectPrevDrone	PROC	NEAR

		mov	si,DroneCrntPtrs[bx]

		mov	bp,si			;store starting place

PrevDroneLoop:	cmp	si,DroneListPtrs[bx]	;start of list?
		je	@F			;yes ->

		sub	si,2			;si -> prev drone

		jmp	PrevPtrOk

@@:		mov	si,DroneListEnds[bx]	;si -> last drone

PrevPtrOk:	mov	di,[si]			;di -> compound mobile data block

		cmp	_DRONE_SIDE[di],DEAD	;drone valid?
		jne	@F			;yes ->

		cmp	si,bp			;back to starting place?
		jne	PrevDroneLoop		;no ->

		stc				;cf = 1 = no drone available

		ret

@@:		clc				;cf = 0 = drone selected

		ret

SelectPrevDrone	ENDP

;----------------------------------------------------------------------------

;* CurrentDroneOk - check if current drone is valid
;*
;* pass: bx = drone mode
;* ret : cf = 0: drone valid
;*          si = drone list ptr
;*       cf = 1: drone invalid
;* kill: di, flags (except cf)

CurrentDroneOk	PROC	NEAR

		mov	si,DroneCrntPtrs[bx]

		mov	di,[si]		;di -> compound mobile data block

		cmp	_DRONE_SIDE[di],DEAD	;drone valid?
		je	@F			;no ->

		clc			;cf = 0 = drone valid

		ret

@@:		stc			;cf = 1 = drone invalid

		ret

CurrentDroneOk	ENDP

;----------------------------------------------------------------------------

;* SelectAnyDrone - select any drone (starting with current category)
;*
;* pass: DroneMode
;* ret : cf = 0: drone selected
;*          bx = drone mode
;*          si = drone list ptr
;*       cf = 1: no drone available
;* kill: assume all (except bx, si, cf)

SelectAnyDrone	PROC	NEAR

;* tmp = DroneMode
;* cnt = 4
;* found drone = false
;*
;* loop
;*    if CurrentDroneOk(tmp) then
;*       found drone = true
;*    else
;*       if SelectNextDrone(tmp) = drone available then
;*          found drone = true
;*       endif
;*    endif
;* exit if cnt = 1 or found drone
;*    cnt = cnt - 1
;*    tmp = (tmp + 2) and 0110b
;* endloop

		mov	bx,DroneMode
		mov	cx,4

AnyDroneLoop:	call	CurrentDroneOk
		jnc	@F		;current drone ok ->

		call	SelectNextDrone
		jnc	@F		;drone available ->

		add	bx,2		;next mode
		and	bx,0110b	;wrap around

		loop	AnyDroneLoop

		stc		;cf = 1 = no drone available

@@:		ret

SelectAnyDrone	ENDP

;----------------------------------------------------------------------------

;* SelectRndDrone - select random drone
;*
;* pass: DroneMode
;* ret : DroneMode
;*	 DroneCrntPtrs[]
;*	 cf = 0: drone selected
;*       cf = 1: no drone available
;* kill: assume all (except cf)

SelectRndDrone	PROC	NEAR

;* select random category

		call	RandX

		mov	bx,A_AIR_MODE	;40% chance
		cmp	ax,(40*256)/100
		jbe	@F

		mov	bx,E_AIR_MODE	;40% chance
		cmp	ax,(80*256)/100
		jbe	@F

		mov	bx,A_GND_MODE	;10% chance
		cmp	ax,(90*256)/100
		jbe	@F

		mov	bx,E_GND_MODE	;10% chance

;* select random starting place within category

@@:		call	RandX
		mov	cx,ax
		and	cx,63
		inc	cx		;1 .. 64

		mov	si,DroneListPtrs[bx]	;start of list

RndLoop:	cmp	si,DroneListEnds[bx]	;end of list?
		je	@F			;yes ->

		add	si,2

		jmp	ContRndLoop

@@:		mov	si,DroneListPtrs[bx]	;start of list

ContRndLoop:	loop	RndLoop

		mov	DroneCrntPtrs[bx],si

		mov	DroneMode,bx

		call	SelectAnyDrone

		mov	DroneCrntPtrs[bx],si

		mov	DroneMode,bx

		ret

SelectRndDrone	ENDP

;----------------------------------------------------------------------------

;* DemoView
;*
;* pass: nothing
;* ret : DEMO_VIEW
;* kill: assume all

DemoView	PROC	NEAR

;------------------------------------
;* check current drone is still valid
;------------------------------------

		mov	bx,DroneMode

		call	CurrentDroneOk	;current drone still valid?
		jc	@F		;no ->

;--------------
;* update timer
;--------------

		mov	ax,DroneTimer
		sub	ax,LastFrame
		MINM	ax
		mov	DroneTimer,ax

		jnz	ContDemo	;still viewing this drone ->

;-----------------------------
;* select a new drone (if any)
;-----------------------------

@@:		call	SelectRndDrone	;any drone available?
		jnc	@F		;yes ->

;* if no drones left then quit

		mov	DieFlag,DIE_QUIT

		jmp	ExitDemo

;* if aircraft then
;*    DroneTimer = DRONE_AIR_TIME
;* else
;*    DroneTimer = DRONE_GND_TIME
;* endif

@@:		;mov	ax,DRONE_AIR_TIME	;assume aircraft
        mov	ax,DRONE_GND_TIME	;assume aircraft

		test	DroneMode,AIR_GND_TOGGLE	;aircraft?
		jz	@F				;yes ->

		;mov	ax,DRONE_GND_TIME
		mov	ax,DRONE_AIR_TIME

@@:		mov	DroneTimer,ax

;* select random camera angle

		call	RandX
		and	ax,3		;0 .. 3
		shl	ax,1		;0 .. 6 step 2
		mov	CameraAngle,ax

;* select random camera bearing

		call	RandX
		shl	ax,1
		and	ax,001c0h
		mov	RndCamBrg,ax

;-------------------
;* sort camera angle
;-------------------

ContDemo:    	mov	bx,DroneMode

		mov	si,DroneCrntPtrs[bx]

		mov	si,[si]		;si -> compound mobile data block

		add	si,MOB_REC_SIZE	;si -> VIEWPOINT data

		COPY_VP	DEMO_VIEW,si

		mov	si,bx		;si = drone mode

		mov	bx,CameraAngle
		jmp	CameraSwitch[bx]

;---------------------------
CamRotateClk	LABEL	NEAR
;---------------------------

		mov	ax,32*256	;32 pdeg / sec track (*256 scaling)
		mov	dx,DeltaTime
		imul	dx
		FRACADJ	ax

		xor	dh,dh		;*256 = *65536 scaling
		mov	dl,ah
		mov	ah,al
		xor	al,al

		mov	cx,DrnCamBrg[si]
		mov	bx,DrnCamBrgFine[si]

		sub	bx,ax
		sbb	cx,dx
		and	cx,511

		jmp	SetCameraBrg

;---------------------------
CamRotateAClk	LABEL	NEAR
;---------------------------

		mov	ax,32*256	;32 pdeg / sec track (*256 scaling)
		mov	dx,DeltaTime
		imul	dx
		FRACADJ	ax

		xor	dh,dh		;*256 = *65536 scaling
		mov	dl,ah
		mov	ah,al
		xor	al,al

		mov	cx,DrnCamBrg[si]
		mov	bx,DrnCamBrgFine[si]

		add	bx,ax
		adc	cx,dx
		and	cx,511

		jmp	SetCameraBrg

;---------------------------
CamRandom	LABEL	NEAR
;---------------------------

		mov	cx,RndCamBrg
		xor	bx,bx

;---------------------------
SetCameraBrg	LABEL	NEAR
;---------------------------

		mov	DrnCamBrg[si],cx
		mov	DrnCamBrgFine[si],bx

;* set camera dist

		push	si

		mov	bx,DroneMode
		mov	si,DroneCrntPtrs[bx]
		mov	si,[si]		;si -> compound mobile data block

		mov	al,MOB_NUM[si]
		call	CalcMobMaxDim

		pop	si

		shl	ax,1		;*2

		cmp	ax,64		;dist = max(dist, 64)
		jae	@F
		mov	ax,64

@@:		mov	DrnCamDist[si],ax
		mov	DrnCamDistFine[si],0

;* adjust zft (zft = max(zft + 16, 32))

		mov	ax,WORD PTR DEMO_VIEW.VP_ZFT_LO
		mov	dx,WORD PTR DEMO_VIEW.VP_ZFT_HI

		add	ax,16
		adc	dx,0

		jnz	@F		;zft > 65,535ft ->

		cmp	ax,32
		jae	@F   		;zft >= 32ft ->
		mov	ax,32

@@:		mov	WORD PTR DEMO_VIEW.VP_ZFT_LO,ax
		mov	WORD PTR DEMO_VIEW.VP_ZFT_HI,dx

;* adjust heading, pitch and roll

		mov	dx,DrnCamBrg[si]
		mov	ax,DrnCamBrgFine[si]
		shl	ax,1
		ROUNDUP	dx

		mov	ax,DEMO_VIEW.VP_HDG	;drone heading
		add	ax,dx			;+ camera bearing
		mov	dx,ax
		add	ax,256			;+ 180 degs
		and	ax,511			;0 .. 511 pdegs
		mov	DEMO_VIEW.VP_HDG,ax

		mov	DEMO_VIEW.VP_PITCH,-10 ;hack from 0
		;mov	DEMO_VIEW.VP_ROLL,0   ;hack from 0 to neg zero

;* adjust position wrt camera bearing and distance

		mov	ax,DrnCamDist[si]
		xchg	ax,dx
		and	ax,511		;0 .. 511 pdegs

		REPT	5		;*32 scaling
		sal	dx,1
		ENDM

		call	CalcDeltaXY	;cx = delta x, bx = delta y

;* /32 scaling using abs(value) for 1/2 bit round up (for improved accuracy)

		mov	ax,cx
		ABSV	ax		;ax = abs(x), dx = sign(x)
		REPT	5		;/32 scaling
		shr	ax,1
		ENDM
		adc	ax,0		;1/2 bit round up
		xor	ax,dx		;restore sign
		sub	ax,dx
		mov	cx,ax

		mov	ax,bx		;ax = abs(y), dx = sign(y)
		ABSV	ax
		REPT	5		;/32 scaling
		shr	ax,1
		ENDM
		adc	ax,0		;1/2 bit round up
		xor	ax,dx		;restore sign
		sub	ax,dx
		mov	bx,ax

		MOVEXY	DEMO_VIEW,cx,bx

ExitDemo:	ret

DemoView	ENDP

;----------------------------------------------------------------------------

;* DestroyView
;*
;* pass: TMP_VIEW
;* ret : TMP_VIEW
;* kill: assume all

DestroyView	PROC	NEAR

;--------------
;* update timer
;--------------

		mov	ax,DestroyTimer
		sub	ax,LastFrame
		MINM	ax
		mov	DestroyTimer,ax

		jnz	@F		;continue ->

		mov	al,TmpDieFlag	;end of game
		mov	DieFlag,al

;------------------------------
;* rotate camera around Tornado
;------------------------------

@@:		mov	ax,64*256	;64 pdeg / sec track (*256 scaling)
		mov	dx,DeltaTime
		imul	dx
		FRACADJ	ax

		xor	dh,dh		;*256 = *65536 scaling
		mov	dl,ah
		mov	ah,al
		xor	al,al

		mov	cx,TrkCamBrg
		mov	bx,TrkCamBrgFine

		add	bx,ax
		adc	cx,dx
		and	cx,511

		mov	TrkCamBrg,cx
		mov	TrkCamBrgFine,bx

;* set camera dist

		mov	TrkCamDist,64
		mov	TrkCamDistFine,0

;* adjust zft

		add	WORD PTR TMP_VIEW.VP_ZFT_LO,16
		adc	WORD PTR TMP_VIEW.VP_ZFT_HI,0

;* adjust heading, pitch and roll

		mov	dx,TrkCamBrg
		mov	ax,TrkCamBrgFine
		shl	ax,1
		ROUNDUP	dx

		mov	ax,PitchFlip
		and	ax,256			;0 or 180 degs (wrt pitch flip)
		add	ax,TMP_VIEW.VP_HDG	;+ aircraft heading
		add	ax,dx			;+ camera bearing
		mov	dx,ax
		add	ax,256			;+ 180 degs
		and	ax,511			;0 .. 511 pdegs
		mov	TMP_VIEW.VP_HDG,ax

		mov	TMP_VIEW.VP_PITCH,30 ;hack from -10; 0
		;mov	TMP_VIEW.VP_ROLL,0   ;hack from 0 to neg zero

;* adjust position wrt camera bearing and distance

		mov	ax,TrkCamDist
		xchg	ax,dx
		and	ax,511		;0 .. 511 pdegs

		REPT	5		;*32 scaling
		sal	dx,1
		ENDM

		call	CalcDeltaXY	;cx = delta x, bx = delta y

;* /32 scaling using abs(value) for 1/2 bit round up (for improved accuracy)

		mov	ax,cx
		ABSV	ax		;ax = abs(x), dx = sign(x)
		REPT	5		;/32 scaling
		shr	ax,1
		ENDM
		adc	ax,0		;1/2 bit round up
		xor	ax,dx		;restore sign
		sub	ax,dx
		mov	cx,ax

		mov	ax,bx		;ax = abs(y), dx = sign(y)
		ABSV	ax
		REPT	5		;/32 scaling
		shr	ax,1
		ENDM
		adc	ax,0		;1/2 bit round up
		xor	ax,dx		;restore sign
		sub	ax,dx
		mov	bx,ax

		MOVEXY	TMP_VIEW,cx,bx

		ret

DestroyView	ENDP

;----------------------------------------------------------------------------

;* WeaponView
;*
;* pass: ViewWeaponPtr
;* ret : WPN_VIEW
;* kill: assume all

WeaponView	PROC	NEAR

;---------------------
;* reset view position
;---------------------

		KTEST	KF_ResetWpnCam	;reset view position?
		jz	@F		;no ->
        mov InWeaponView,1
		mov	WpnCamDist,WPN_DIST_MIN	
		mov	WpnCamBrg,300;256-->300
		mov	WpnCamBrgFine,0

;-----------------------
;* copy weapon viewpoint (always valid see ViewWeaponPtr note above)
;-----------------------

@@:		mov	si,ViewWeaponPtr

		mov	ax,WPNDATA
		mov	ds,ax

		mov	bx,_WPN_TYPE[si]	;bx = weapon type
		mov	dx,_WPN_FLAGS[si]	;dx = weapon flags

		add	si,MOB_REC_SIZE		;si -> viewpoint data

		COPY_VP	WPN_VIEW,si

		mov	ax,DATA
		mov	ds,ax

;* always reset roll
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;Mod by Frankie Kam on 21st April 2018
        ;User pressed Alt+P to toggle on/off horizon pitching 
		;when in F1 Tracking View mode?
		KTEST	KF_TogglePitchCam	;kkk
		jz	@F		;no -> do nothing!
		mov InWeaponView,1
		xor PitchToggleWeapon,1 ;Toggle this value from 0 to 1
		;Clear the P (Pause) key. If this line is not executed, 
		;the game will pause!
		KCLEAR KF_Pause 
		;Clear this Control+P key!
		KCLEAR KF_TogglePitchCam 
@@:
        ;Check for 0 or 1
        cmp	PitchToggleWeapon,0
		jne @F       ;-->Set the TMP_VIEW.VP_ROLL variable to 0
		jmp SkipRoll5 ;-->Do nothing if PitchToggle equals to 1
@@:
		mov WPN_VIEW.VP_ROLL,0 

SkipRoll5: ;do nothing

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        ;mov	WPN_VIEW.VP_ROLL,1 ;hack

;------------------
;* select view mode (wrt weapon)
;------------------

;* if NULL_WEAPON then sort expired weapon view

		cmp	bx,NULL_WEAPON	;null weapon?
		jne	@F		;no ->

		cmp	WpnExpView,1	;overhead?
		je	OverheadView	;yes ->

		jmp	NormalView

@@:		jmp	WeaponSwitch[bx]

;---------------------------
BombView	LABEL	NEAR
;---------------------------

		mov	WpnExpView,1	;overhead view when weapon expired

;* always show bomb splash as overhead view

		test	dx,WFLG_SPLASH	;splash?
		jnz	OverheadView	;yes ->

;* Calc altitude to switch to overhead view:-
;*
;* Only consider overhead view if bomb is pitched down.
;*
;*    switch alt = -SWITCH_THRESH * sin(pitch)
;*
;* This prevents low level launched weapons (ie. retarded bombs) from
;* switching to the overhead view too early.

SWITCH_THRESH	EQU	1     ;hack - from 500 to 600

OVERHEAD_ALT	EQU	1		;OVERHEAD_ALT >= SWITCH_THRESH  ;hack - from 500 to 600

		mov	bx,WPN_VIEW.VP_PITCH

		cmp	bx,128		;pitched down?
		jbe	NormalView	;no ->

		SINE	ax,bx		;sin(pitch)

		mov	dx,-SWITCH_THRESH
		imul	dx
		FRACADJ	dx		;-SWITCH_THRESH * sin(pitch)

		cmp	WORD PTR WPN_VIEW.VP_ZFT_HI,0
		ja	NormalView

		cmp	WORD PTR WPN_VIEW.VP_ZFT_LO,dx
		ja	NormalView

;---------------------------
OverheadView	LABEL	NEAR
;---------------------------

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                Original
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		mov	si,OFFSET WPN_VIEW
		call	CalcGndHeight

		add	ax,OVERHEAD_ALT

		mov	WORD PTR WPN_VIEW.VP_ZFT_LO,ax
		mov	WORD PTR WPN_VIEW.VP_ZFT_HI,0

		;mov	WPN_VIEW.VP_PITCH,-110	
		mov	WPN_VIEW.VP_PITCH,-110 ;384
		;pitch down -90 ;hack from 384 to -110

		call AdjustWpnZoom  ;hack
		call AdjustWpnTrack ;hack
		
		jmp	ExitWeapon
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
;		mov	si,OFFSET WPN_VIEW
;		call	CalcGndHeight
;
;		;add	ax,OVERHEAD_ALT
;		add	ax,50
;		        
;		mov	WpnCamDist,4096
;		
;		mov	WORD PTR WPN_VIEW.VP_ZFT_LO,ax
;		mov	WORD PTR WPN_VIEW.VP_ZFT_HI,0
;
;		mov	WPN_VIEW.VP_PITCH,384	;pitch down -90
;				
;		KTEST KF_Minimise
;		jz SkipAlex3
;		mov InWeaponView,1
;		sub HorizonBombValue, 5
;		KBOUNCE KF_Minimise
;		jmp SkipAlex4
;SkipAlex3:
;		KTEST KF_Range
;		jz SkipAlex4
;		mov InWeaponView,1
;		add HorizonBombValue, 5
;		KBOUNCE KF_Range
;SkipAlex4:
;        mov bx, HorizonBombValue
;        mov	WPN_VIEW.VP_PITCH,bx
;		call AdjustWpnZoom  ;hack
;		call AdjustWpnTrack ;hack
;		
;		jmp	ExitWeapon
;		

;---------------------------
AlarmView	LABEL	NEAR
;---------------------------

		mov	WpnExpView,1	;overhead view when weapon expired

;* switch to lookdown if freefall or dive

		and	dx,WFLG_ALARM_MODE

		cmp	dx,ALARM_FREEFALL
		je	NormalView
		cmp	dx,ALARM_DIVE
		je	NormalView

		;mov	WPN_VIEW.VP_PITCH,-10 ;hack from 0
		mov	WPN_VIEW.VP_PITCH,0
		mov	WPN_VIEW.VP_ROLL,0

		jmp	NormalView

;---------------------------
MissileView	LABEL	NEAR
;---------------------------

		mov	WpnExpView,0	;normal view when weapon expired

;---------------------------
NormalView	LABEL	NEAR
;---------------------------

		call	AdjustWpnZoom

		call	AdjustWpnTrack

ExitWeapon:	ret

WeaponView	ENDP

;----------------------------------------------------------------------------

;* AdjustWpnZoom
;*
;* pass: WpnCamDist = old dist
;* ret : WpnCamDist = new dist = WPN_DIST_MIN .. WPN_DIST_MAX
;* kill: assume all

AdjustWpnZoom	PROC	NEAR

;--------------
;* sort zoom in
;--------------

		KTEST	KF_ZoomIn	;zoom in?
		jz	SkipWpnZoomIn	;no ->
		mov InWeaponView,1
		mov	ax,32*256	;32ft/sec zoom rate (*256 scaling)
		mov	dx,DeltaTime
		imul	dx
		FRACADJ	dx

		test	BYTE PTR KF_FastZoomIn[K_STATUS],1	;fast zoom?
		jz	@F					;no ->

		REPT	2		;*4
		shl	dx,1
		ENDM

@@:		mov	ax,WpnCamDist
		sub	ax,dx
		jc	@F

		cmp	ax,WPN_DIST_MIN ;zoom < min zoom dist?
		jae	WpnZoomOk 	;no ->
		
@@:		mov	ax,WPN_DIST_MIN

		jmp	WpnZoomOk

;---------------
;* sort zoom out
;---------------

SkipWpnZoomIn:	KTEST	KF_ZoomOut	;zoom out?
		jz	SkipWpnZoomOut 	;no ->
        mov InWeaponView,1
		mov	ax,32*256	;32ft/sec zoom rate (*256 scaling)
		mov	dx,DeltaTime
		imul	dx
		FRACADJ	dx

		test	BYTE PTR KF_FastZoomOut[K_STATUS],1	;fast zoom?
		jz	@F					;no ->

		REPT	2		;*4
		shl	dx,1
		ENDM

@@:		mov	ax,WpnCamDist
		add	ax,dx
		jc	@F

		cmp	ax,WPN_DIST_MAX ;zoom > max zoom dist?
		jbe	WpnZoomOk 	;no ->
		
@@:		mov	ax,WPN_DIST_MAX

WpnZoomOk: 	mov	WpnCamDist,ax

SkipWpnZoomOut:	ret

AdjustWpnZoom	ENDP

;----------------------------------------------------------------------------

;* AdjustWpnTrack
;*
;* pass: WPN_VIEW
;*       WpnCamBrg
;*       WpnCamBrgFine
;* ret : WPN_VIEW
;*       WpnCamBrg
;*       WpnCamBrgFine
;* kill: assume all

AdjustWpnTrack	PROC	NEAR

;* dist = WpnCamDist * cos(pitch)
;*
;* delta x = dist * sin((hdg + brg) and 511)
;* delta y = dist * cos((hdg + brg) and 511)
;* delta z = -WpnCamDist * sin(pitch)

		mov	bx,WPN_VIEW.VP_PITCH

		SINCOS	si,di,bx

		mov	ax,WpnCamDist
		neg	ax
		imul	si
		shl	ax,1		;adjust after fractional multiply
		rcl	dx,1
		shl	dl,1		;/256
		adc	dh,0
		mov	al,dh
		cbw			;ax = delta z
		cwd			;dx, ax = delta z

		add	WORD PTR WPN_VIEW.VP_ZFT_LO,ax
		adc	WORD PTR WPN_VIEW.VP_ZFT_HI,dx

		jns	@F	;above ground ->

		mov	WORD PTR WPN_VIEW.VP_ZFT_LO,1
		mov	WORD PTR WPN_VIEW.VP_ZFT_HI,0

@@:		mov	ax,WpnCamDist
		imul	di
		FRACADJ	bp		;bp = dist

;* adjust weapon camera tracking

		mov	cx,WpnCamBrg
		mov	bx,WpnCamBrgFine
		call	AdjustTrack  ;UpdateViewExit
		mov	WpnCamBrg,cx
		mov	WpnCamBrgFine,bx

		shl	bx,1
		ROUNDUP	cx

		mov	bx,WPN_VIEW.VP_HDG

		add	bx,cx		;hdg + brg

		mov	cx,bx
		add	cx,256		;hdg + brg + 180
		and	cx,511		;(hdg + brg + 180) and 511

		mov	WPN_VIEW.VP_HDG,cx

		and	bx,511		;(hdg + brg) and 511

		SINCOS	si,di,bx

		mov	ax,bp
		imul	si		
		shl	ax,1		;adjust after fractional multiply
		rcl	dx,1
		shl	dl,1		;/256
		adc	dh,0
		mov	al,dh
		cbw			
		mov	cx,ax		;cx = delta x

		mov	ax,bp
		imul	di
		shl	ax,1		;adjust after fractional multiply
		rcl	dx,1
		shl	dl,1		;/256
		adc	dh,0
		mov	al,dh
		cbw
		mov	bx,ax		;bx = delta y

		MOVEXY	WPN_VIEW,cx,bx

		ret

AdjustWpnTrack	ENDP


PANCODE		ENDS

;============================================================================

		END

