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

		PUBLIC	SetGameViewMode
		PUBLIC	UpdateGameView

		PUBLIC	ViewPtr
		PUBLIC	DroneMode
		PUBLIC	DroneCrntPtrs
		PUBLIC	ViewWeaponPtr
		PUBLIC	TrkCamBrg
		PUBLIC	WpnCamBrg
		PUBLIC	WpnCamBrgFine

		PUBLIC	InCockpit
		PUBLIC	EarShot

		PUBLIC	ZFT_COCKPIT

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
	
		EXTRN	KF_PilotView:BYTE
		EXTRN	KF_NavigView:BYTE
		EXTRN	KF_LViewFix:BYTE
		EXTRN	KF_RViewFix:BYTE
		EXTRN	KF_LViewGlance:BYTE
		EXTRN	KF_RViewGlance:BYTE
		EXTRN	KF_TrackingCam:BYTE
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

		EXTRN	COOLIE_UP:ABS
		EXTRN	COOLIE_DN:ABS
		EXTRN	COOLIE_LT:ABS
		EXTRN	COOLIE_RT:ABS

;============================================================================

		INCLUDE	MAINDATA.INC

		INCLUDE	\VISUAL\VISDATA.INC
		INCLUDE	\VISUAL\VISMACRO.INC
		INCLUDE	\VISUAL\VISEXTRN.INC

		INCLUDE	\LIB8086\KEYS.INC
		INCLUDE	\LIB8086\TRIG.INC
		INCLUDE	\LIB8086\USEFUL.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

;----------------
;* view point ptr
;----------------

ViewPtr		DW	OFFSET M_VIEW	;(-1 = visual disabled)

;---------------
;* set view mode (wrt GameViewMode)
;---------------

ViewSwitch	DW	INT_VIEWMODE	;VIEW_PILOT
		DW	ALT_VIEWMODE	;VIEW_LPILOT
		DW	ALT_VIEWMODE	;VIEW_RPILOT
		DW	NUL_VIEWMODE	;VIEW_NAVIG
		DW	ALT_VIEWMODE	;VIEW_LNAVIG
		DW	ALT_VIEWMODE	;VIEW_RNAVIG
		DW	EXT_VIEWMODE	;VIEW_TRACKING
		DW	EXT_VIEWMODE	;VIEW_SATELLITE
		DW	NUL_VIEWMODE	;VIEW_MAP
		DW	EXT_VIEWMODE	;VIEW_DRONE
		DW	EXT_VIEWMODE	;VIEW_SPECTATOR
		DW	EXT_VIEWMODE	;VIEW_REMOTE
		DW	NUL_VIEWMODE	;VIEW_LOOKDOWN
		DW	EXT_VIEWMODE	;VIEW_LOOKUP
		DW	EXT_VIEWMODE	;VIEW_DEMO
		DW	EXT_VIEWMODE	;VIEW_DESTROYED
		DW	EXT_VIEWMODE	;VIEW_WEAPON

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
		DW	ROTATE_NULL	;VIEW_SATELLITE
		DW	ROTATE_NULL	;VIEW_MAP
		DW	ROTATE_NULL	;VIEW_DRONE
		DW	ROTATE_NULL	;VIEW_SPECTATOR
		DW	ROTATE_NULL	;VIEW_REMOTE
		DW	ROTATE_NULL	;VIEW_LOOKDOWN
		DW	ROTATE_VIEW_UP	;VIEW_LOOKUP
		DW	ROTATE_NULL	;VIEW_DEMO
		DW	ROTATE_NULL	;VIEW_DESTROYED
		DW	ROTATE_NULL	;VIEW_WEAPON

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

;------------
;* in cockpit (wrt GameViewMode)
;------------

ZFT_COCKPIT	EQU	8		;in cockpit zft displacement

InCockpit	DB	1		;1 = in cockpit

CockpitFlags	DB	1		;VIEW_PILOT
		DB	1		;VIEW_LPILOT
		DB	1		;VIEW_RPILOT
		DB	1		;VIEW_NAVIG
		DB	1		;VIEW_LNAVIG
		DB	1		;VIEW_RNAVIG
		DB	0		;VIEW_TRACKING
		DB	0		;VIEW_SATELLITE
		DB	1		;VIEW_MAP
		DB	0		;VIEW_DRONE
		DB	0		;VIEW_SPECTATOR
		DB	0		;VIEW_REMOTE
		DB	1		;VIEW_LOOKDOWN
		DB	1		;VIEW_LOOKUP
		DB	0		;VIEW_DEMO
		DB	0		;VIEW_DESTROYED
		DB	0		;VIEW_WEAPON

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
		DB	0		;VIEW_DRONE
		DB	0		;VIEW_SPECTATOR
		DB	0		;VIEW_REMOTE
		DB	1		;VIEW_LOOKDOWN
		DB	1		;VIEW_LOOKUP
		DB	0		;VIEW_DEMO
		DB	1		;VIEW_DESTROYED
		DB	0		;VIEW_WEAPON

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
MAX_ZOOM	EQU	1023		;1023 maximum

;----------------------
;* tracking camera vars
;----------------------

TrkCamDist	DW	64
TrkCamDistFine	DW	0

TrkCamBrg	DW	256
TrkCamBrgFine	DW	0

TrkCamAlt	DW	16

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

DrnCamBrg	DW	0		;A_AIR_MODE
		DW	0		;E_AIR_MODE
		DW	0		;A_GND_MODE
		DW	0		;E_GND_MODE

DrnCamBrgFine	DW	0		;A_AIR_MODE
		DW	0		;E_AIR_MODE
		DW	0		;A_GND_MODE
		DW	0		;E_GND_MODE

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

;-----------
;* demo view
;-----------

;* set default viewpoint (in case no drones active)

DEMO_VIEW	VIEWPOINT <16,16,0,0,5000,0,0,0>

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

@@:		mov	ax,VIEW_NAVIG
		call	ChgGameViewMode

		jmp	UpdateView

;-------------------------------------------
;* left view (fixed), sort pilot / navigator
;-------------------------------------------

SkipNavig:	cmp	TM_CoolieVal,COOLIE_LT
		je	@F

		KTEST	KF_LViewFix
		jz	SkipLFix

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

@@:		mov	ax,VIEW_RPILOT		;assume pilot
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

SkipRGlance:	KTEST	KF_TrackingCam
		jz	SkipTracking

IntoTracking:	mov	ax,VIEW_TRACKING
		call	ChgGameViewMode
		jnc	@F		;change successful ->

;* must have been VIEW_TRACKING already so adjust TrkCamAlt

		neg	TrkCamAlt	;toggle above / below

@@:		jmp	UpdateView

;-----------------------
;* satellite camera view
;-----------------------

SkipTracking:	KTEST	KF_SatelliteCam
		jz	SkipSatellite

		mov	ax,VIEW_SATELLITE
		call	ChgGameViewMode
		jnc	@F		;change successful ->

;* must have been VIEW_SATELLITE already so toggle topside / underside

		xor	SatCamSide,0ffffh

@@:		jmp	UpdateView

;---------------
;* map view mode
;---------------

SkipSatellite:	KTEST	KF_MapView
		jz	SkipMapView

		mov	ax,VIEW_MAP
		call	ChgGameViewMode

		jmp	UpdateView

;-----------------
;* drone view mode
;-----------------

SkipMapView:	KTEST	KF_DroneSide	;allied / enemy toggle?
		jz	SkipDroneSide	;no ->

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

SkipDroneType:	KTEST	KF_DroneView	;drone view / next drone?
		jz	SkipDroneView	;no ->

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

		mov	bx,DroneMode

		call	SelectNextDrone
		jc	FailDroneView  	;no drone available ->

		mov	DroneCrntPtrs[bx],si
		
		mov	DroneMode,bx

		jmp	UpdateView

@@:		mov	bx,DroneMode

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

SkipDroneView:	KTEST	KF_Spectator
		jz	SkipSpectator

;* set spectator view, if already spectating then catch up with Tornado

		mov	ax,VIEW_SPECTATOR
		call	ChgGameViewMode
		jc	CatchTornado

;* if restore spectator view then check SPEC_VIEW is valid

		KTEST	KF_RestoreSpec
		jz	@F

		test	SpecValid,1
		jz	@F

		jmp	UpdateView

;* if ViewPtr <> -1 (viewpoint valid) then
;*    SPEC_VIEW = V_VIEW
;* else
;*    SPEC_VIEW = M_VIEW
;* endif

@@:		mov	si,OFFSET V_VIEW	;assume viewpoint valid

		cmp	ViewPtr,-1		;viewpoint valid?
		jne	@F			;yes ->

CatchTornado:	mov	si,OFFSET M_VIEW

@@:		COPY_VP	SPEC_VIEW,si

		mov	SPEC_VIEW.VP_ROLL,0	;keep horizon level

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

		mov	ax,VIEW_REMOTE
		call	ChgGameViewMode

;* drop viewpoint anchor

		mov	si,OFFSET M_VIEW

		COPY_VP	REM_VIEW,si

		mov	REM_VIEW.VP_ROLL,0	;keep horizon level

;* ensure zft never zero

		mov	ax,WORD PTR REM_VIEW.VP_ZFT_LO
		or	ax,WORD PTR REM_VIEW.VP_ZFT_HI
		jnz	@F

		mov	WORD PTR REM_VIEW.VP_ZFT_LO,1

@@:		jmp	UpdateView

;----------------
;* look down view
;----------------

SkipRemote:	KTEST	KF_LookDown
		jz	SkipLookDown

		mov	ax,VIEW_LOOKDOWN
		call	ChgGameViewMode

		jmp	UpdateView

;-------------
;* weapon view
;-------------

SkipLookDown:	KTEST	KF_ViewWeapon
		jz	UpdateView

		cmp	ViewWeaponPtr,-1	;weapon available?
		je	UpdateView		;no ->

		mov	ax,VIEW_WEAPON
		call	ChgGameViewMode
		jc	UpdateView		;already weapon view ->

;* ensure correct view if current weapon expired

		mov	si,ViewWeaponPtr

		mov	ax,WPNDATA
		mov	ds,ax

		mov	bx,_WPN_TYPE[si]

		add	si,MOB_REC_SIZE		;si -> viewpoint data

		COPY_VP	WPN_VIEW,si

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

;---------------------------
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

		mov	TrkCamDist,64
		mov	TrkCamDistFine,0
		mov	TrkCamBrg,256
		mov	TrkCamBrgFine,0
		mov	TrkCamAlt,16
		mov	PitchFlip,0

;* adjust zoom

@@:		mov	cx,TrkCamDist
		mov	bx,TrkCamDistFine
		call	AdjustZoom
		mov	TrkCamDist,cx
		mov	TrkCamDistFine,bx

;* adjust track

		mov	cx,TrkCamBrg
		mov	bx,TrkCamBrgFine
		call	AdjustTrack
		mov	TrkCamBrg,cx
		mov	TrkCamBrgFine,bx

;* adjust zft

	  	mov	ax,TrkCamAlt

		cwd

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

		mov	TMP_VIEW.VP_PITCH,0
		mov	TMP_VIEW.VP_ROLL,0

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
UpdateSatellite	LABEL	NEAR
;---------------------------

		KTEST	KF_ResetSatCam	;reset view position?
		jz	@F		;no ->

		mov	SatCamDist,64
		mov	SatCamDistFine,0
		mov	PitchFlip,0
		mov	SatCamSide,0

;* adjust heading, pitch and roll

@@:		mov	dx,SatCamSide
		and	dx,256			;0 or 180 degs (wrt side)

		mov	ax,PitchFlip
		and	ax,256			;0 or 180 degs (wrt pitch flip)
		add	ax,dx			;adjust wrt side
		add	ax,TMP_VIEW.VP_HDG	;+ aircraft heading
		and	ax,511			;0 .. 511 pdegs
		mov	TMP_VIEW.VP_HDG,ax

		mov	ax,384	     		;assume topside
		sub	ax,dx	     		;adjust wrt side
		mov	TMP_VIEW.VP_PITCH,ax

		mov	TMP_VIEW.VP_ROLL,0

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

		add	WORD PTR TMP_VIEW.VP_ZFT_LO,ax
		adc	WORD PTR TMP_VIEW.VP_ZFT_HI,dx

		js	@F		;zft < 0 ->

		mov	ax,WORD PTR TMP_VIEW.VP_ZFT_LO
		or	ax,WORD PTR TMP_VIEW.VP_ZFT_HI

		jnz	SatCamZftOk	;zft > 0 ->

@@:		mov	WORD PTR TMP_VIEW.VP_ZFT_LO,1
		mov	WORD PTR TMP_VIEW.VP_ZFT_HI,0

SatCamZftOk:	mov	ViewPtr,OFFSET TMP_VIEW

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
		cmp	ax,64		;min dist >= 64ft?
		jae	@F		;yes ->
		mov	ax,64
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
		call	AdjustTrack
		mov	DrnCamBrg[si],cx
		mov	DrnCamBrgFine[si],bx

;* adjust zft (zft = max(zft + 16, 32))

		mov	ax,WORD PTR TMP_VIEW.VP_ZFT_LO
		mov	dx,WORD PTR TMP_VIEW.VP_ZFT_HI

		add	ax,16
		adc	dx,0

		jnz	@F		;zft > 65,535ft ->

		cmp	ax,32
		jae	@F   		;zft >= 32ft ->

		mov	ax,32

@@:		mov	WORD PTR TMP_VIEW.VP_ZFT_LO,ax
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

		mov	TMP_VIEW.VP_PITCH,0
		mov	TMP_VIEW.VP_ROLL,0

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

		mov	REM_VIEW.VP_PITCH,ax

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
		adc	WORD PTR TMP_VIEW.VP_ZFT_HI,0

		mov	ViewPtr,OFFSET TMP_VIEW

		jmp	UpdateViewExit

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

		REPT	2		;*4
		shl	ax,1
		rcl	dx,1
		ENDM

@@:		sub	bx,ax
		sbb	cx,dx
		and	cx,511

		jmp	SkipTrackAClk
		
;* sort anti-clockwise track

SkipTrackClk:	KTEST	KF_TrackAClk	;track anti-clockwise?
		jz	SkipTrackAClk	;no ->

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

@@:		mov	ax,DRONE_AIR_TIME	;assume aircraft

		test	DroneMode,AIR_GND_TOGGLE	;aircraft?
		jz	@F				;yes ->

		mov	ax,DRONE_GND_TIME

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

		mov	DEMO_VIEW.VP_PITCH,0
		mov	DEMO_VIEW.VP_ROLL,0

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

		mov	TMP_VIEW.VP_PITCH,0
		mov	TMP_VIEW.VP_ROLL,0

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

		mov	WpnCamDist,WPN_DIST_MIN	
		mov	WpnCamBrg,256
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

		mov	WPN_VIEW.VP_ROLL,0

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

SWITCH_THRESH	EQU	500

OVERHEAD_ALT	EQU	500		;OVERHEAD_ALT >= SWITCH_THRESH

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

		mov	si,OFFSET WPN_VIEW
		call	CalcGndHeight

		add	ax,OVERHEAD_ALT

		mov	WORD PTR WPN_VIEW.VP_ZFT_LO,ax
		mov	WORD PTR WPN_VIEW.VP_ZFT_HI,0

		mov	WPN_VIEW.VP_PITCH,384	;pitch down -90

		jmp	ExitWeapon

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

		mov	WPN_VIEW.VP_PITCH,0

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
		call	AdjustTrack
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

