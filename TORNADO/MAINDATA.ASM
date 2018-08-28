;****************************************************************************
;*
;* MAINDATA.ASM
;*
;* Miscellaneous Tornado data and gameplay data.
;*
;* 10.12.1991 - KJB
;*
;* Waypoint Route Notes
;* 컴컴컴컴컴컴컴컴컴컴
;*
;* There are two basic forms of waypoint routes (applicable to all aircraft
;* and helicopters):-
;*
;* 1) Co-ordinated Route
;*    컴컴컴컴컴컴컴컴컴
;*
;*    a) takeoff / start airborne
;*    b) fly from waypoint to waypoint aiming to reach waypoint at specified
;*       time executing waypoint "actions"
;*    c) land
;*    d) taxi off runway
;*
;*    Typical missions include interdictor strike, supply drops / delivery.
;* 
;* 2) Continuous Route
;*    컴컴컴컴컴컴컴컴
;*
;*    a) takeoff / start airborne
;*    b) fly continuous waypoint route (linked back), flying at given speed
;*    c) break out of route when fatigued
;*    d) land
;*    e) refuel / rearm
;*    f) takeoff
;*
;*    Typical missions include air defence (CAP), air superiority, close air
;*    support.
;*
;* Waypoint Components
;* 컴컴컴컴컴컴컴컴컴?
;*
;*    WP_ID	: waypoint identifier (ASCII character)
;*
;*		  Use "A", "B", "C" etc. for navigation waypoints.
;*		  Use "X", "Y", "Z" etc. for target waypoints.
;*
;*    WP_ATTR	: waypoint attributes (see below)
;*
;*    WP_XSEC	: waypoint x sector (must be on map (0 .. 31))
;*
;*    WP_YSEC	: waypoint y sector (must be on map (0 .. 31))
;*
;*    WP_XFT	: waypoint xft (-8,192ft .. +8,191ft)
;*
;*    WP_YFT	: waypoint yft (-8,192ft .. +8,191ft)
;*
;*    WP_ZFT	: waypoint altitude (0 .. 65,535ft)
;*
;*                If WP_TF = 1 then WP_ZFT gives the terrain following alt.
;*		  The TF alt can be set to any reasonable value but values
;*                set for Tornados should comply with the standard ride
;*		  altitudes (200, 300, 400, 500, 750, 1000 and 1500ft).
;*
;*    WP_TIME	: waypoint arrival time (secs since start)
;*
;*		  If the route is co-ordinated (WP_COORD = 1) then set speed
;*                to arrive at given time.
;*
;*    WP_SPEED	: waypoint speed (ft/sec * 8)
;*
;*		  If the route is not co-ordinated (WP_COORD = 0) then set
;*                speed to this value.
;*
;*		  If start airborne, then WP_SPEED is the initial speed and
;*                WP_COORD = 0.
;*
;*    WP_ACTION	: waypoint action (actions specific to mobile type)
;*
;*    WP_PACKAGE: weapons package to deliver at waypoint
;*
;* Waypoint Attributes
;* 컴컴컴컴컴컴컴컴컴?
;*		
;*    WP_TYPE	: 1 = target (fly over waypoint)
;*		  0 = turning point (turn early)
;*
;*    WP_LINK	: 1 = link back to waypoint (where WP_HERE = 1)
;*                0 = no link
;*
;*		  Only one "link back" may be set for each waypoint route.
;*                The waypoint to link back to must be before this waypoint
;*		  in the route.
;*
;*		  All waypoints in the linked part of the route must be target
;*		  waypoints (WP_TYPE = 1). This is required for CAP stations
;*		  so that the aircraft covers the whole extent of the route.
;*		  Also problems can occur with the Tornado's skip waypoint
;*		  control. If turn early waypoints are used, it is possible
;*		  that the current waypoint marker will not advance out of the
;*		  loop.
;*
;*    WP_HERE	: 1 = link back to here label
;*		  0 = no label
;*
;*		  Only one "link back" may be set for each waypoint route.
;*                The waypoint to link from must be after this waypoint in
;*                the route.
;*		
;*    WP_TF	: 1 = terrain follow to waypoint (ride alt = WP_ZFT)
;*		  0 = acquire waypoint altitude
;*
;*		  WP_TF = 1 and WP_ILS = 1 is not allowed (WP_TF overrides).
;*
;*		  Terrain following is not available to the ADV Tornado and
;*	          must not be used in the route plan.
;*
;*		  For drone aircraft only, any waypoint set below 4,096ft
;*                should use terrain following.
;*
;*    WP_ILS	: 1 = fly ILS glide slope to waypoint (WP_TYPE = 1)
;*		  0 = acquire waypoint altitude
;*
;*                This must be a target waypoint (WP_TYPE = 1). Speed and
;*                altitude are ignored (WP_ZFT = 0, WP_SPEED = 0).
;*
;*		  WP_TF = 1 and WP_ILS = 1 is not allowed (WP_TF overrides).
;*
;*		  Always turn onto an ILS leg using a navigation waypoint
;*                (turn early), so that the aircraft is lined up with the
;*                runway.
;*
;*		  The waypoint at which the approach starts should be placed
;*		  at the furthest extent of the ILS beam. This is to allow
;*		  aircraft enough time to slow down.
;*
;*		  WP_ILS also indicates a touchdown point for helicopters.
;*                WP_ZFT and WP_SPEED are ignored (WP_ZFT = 0, WP_SPEED = 0).
;*		  The touchdown point must be placed far enough from the
;*		  previous waypoint to allow the helicopter to slow down.
;*
;*    WP_COORD	: 1 = calc speed to arrive at specified time
;*		  0 = set fixed speed
;*
;*		  See route descriptions above. See also WP_TIME and WP_SPEED.
;*
;*		  Routes can comprise co-ordinated and unco-ordinated waypoints.
;*                In a co-ordinated route, the waypoints used to set up the
;* 		  approach and landing points must use fixed speeds. Problems
;*		  could occur if an aircraft was landing late and therefore
;*		  at high speed.
;*
;*    WP_BREAK	: 1 = break to here to land label (WP_TYPE = 1)
;*		  0 = no label
;*
;*		  This label indicates the start of the approach and landing
;*		  waypoints. Only one of these labels may be set per route.
;*
;*		  The break waypoint cannot be the landing waypoint. There
;*		  must be at least one approach waypoint. With helicopters
;*		  use the approach waypoint to line up a clear approach to
;*		  the touchdown point (avoiding ground objects).
;*
;*		  This waypoint should be a target waypoint so that the
;*                aircraft gets to the right side of the approach and touch
;*		  down waypoints (which should follow this waypoint). Also,
;*		  this waypoint and all following waypoints must have fixed
;*		  speeds (WP_COORD = 0).
;*
;*		  It is advisable to terrain follow to this waypoint, as the
;*		  approach direction cannot be predicted.
;*
;*    WP_VALID	: 1 = waypoint valid
;*		  0 = waypoint not in use
;*
;*		  All valid waypoints must be continuous. No gaps are allowed
;*                in the waypoint route.
;*
;* Waypoint Distance
;* 컴컴컴컴컴컴컴컴?
;*
;*    Waypoints should not be placed too close together. The aircraft or
;*    helicoter may have difficulty turning onto the waypoint (especially
;*    at high speed). Heading adjustments are inhibited near to waypoints
;*    (in order to prevent jitter).
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

;----------------
;* debug switches
;----------------

DRONE_AC_ON	EQU	1		;1 = drone aircraft enabled
DRONE_HC_ON	EQU	1		;1 = drone helicopters enabled

;--------------------
;* miscellaneous data
;--------------------
;PUBLIC NightVisionState 
        PUBLIC  ShakeUp
        PUBLIC  FullScreen		
		PUBLIC	TMP_VIEW
PUBLIC TornadoType		
PUBLIC	TMP2_VIEW		
		PUBLIC	GameViewMode
		PUBLIC	PanelMode
		PUBLIC	CrewMode
		PUBLIC	AutoMode
		PUBLIC	AltMode
		PUBLIC	HdgMode
		PUBLIC	RadarMode
		PUBLIC	WayTotal
		PUBLIC	ArmMode
		PUBLIC	WPPtr
		PUBLIC	EndWPPtr
		PUBLIC	FloatWP
		PUBLIC	WPRng
		PUBLIC	WPBrg
		PUBLIC	WPBrgFine
		PUBLIC	WPRngNMiles
		PUBLIC	WPETA
		PUBLIC	WPTimeEarlyLate
		PUBLIC	RedWarnings1
		PUBLIC	RedWarnings2
		PUBLIC	AmbWarnings1
		PUBLIC	AmbWarnings2
		PUBLIC	ShakePriority
		PUBLIC	TmpDieFlag
		PUBLIC	Jettison
		PUBLIC	DronePtrs
		PUBLIC	AAirDronePtrs
		PUBLIC	AAirDroneLast
		PUBLIC	EAirDronePtrs
		PUBLIC	EAirDroneLast
		PUBLIC	AGndDronePtrs
		PUBLIC	AGndDroneLast
		PUBLIC	EGndDronePtrs
		PUBLIC	EGndDroneLast

;---------------
;* gameplay data
;---------------

		PUBLIC	GameDataSize
		PUBLIC	GamePlayData
		PUBLIC	TornadoType
		PUBLIC	ControlDevice
		PUBLIC	SoundCard
		PUBLIC	MusicCard
		PUBLIC	RedWarnings
		PUBLIC	AmbWarnings
		PUBLIC	StartAirspeed
		PUBLIC	TimeLimit
		PUBLIC	APilotSkill
		PUBLIC	EPilotSkill
		PUBLIC	XWindVmax
		PUBLIC	XWindDir	
		PUBLIC	ExploreMode
		PUBLIC	PreviewMode
		PUBLIC	DemoMode
		PUBLIC	NoCollisions
		PUBLIC	DieFlag
		PUBLIC	Landing
		PUBLIC	InfiniteWeapons
		PUBLIC	InfiniteFuel
		PUBLIC	InfiniteGForce
		PUBLIC	IronWork
		PUBLIC	TwoPlayer
		PUBLIC	CommsDevice
		PUBLIC	BaudRate
		PUBLIC	SoundOption
		PUBLIC	Destroyed
		PUBLIC	Ejected
		PUBLIC	StartAirborne
		PUBLIC	AutoTrack
		PUBLIC	DamagedLEng
		PUBLIC	DamagedREng
		PUBLIC	FixMinWeight
		PUBLIC	NoFire
		PUBLIC	GlobalTimeout
		PUBLIC	HitObjectNum
		PUBLIC	Clock24
		PUBLIC	ExtStores
		PUBLIC	Packages
		PUBLIC	StartWaypoint
		PUBLIC	WayList
		PUBLIC	AirfieldList
		PUBLIC	AGndKills
		PUBLIC	EGndKills
		PUBLIC	AMobKills
		PUBLIC	EMobKills
		PUBLIC	EWRTable
		PUBLIC	AAircraft1
		PUBLIC	AAircraft2
		PUBLIC	AAircraft3
		PUBLIC	AAircraft4
		PUBLIC	AAircraft5
		PUBLIC	AAircraft6
		PUBLIC	AAircraft7
		PUBLIC	AAircraft8
		PUBLIC	AAircraft9
		PUBLIC	AAircraft10
		PUBLIC	AAircraft11
		PUBLIC	AAircraft12
		PUBLIC	AAircraft13
		PUBLIC	AAircraft14
		PUBLIC	AAircraft15
		PUBLIC	AAircraft16
		PUBLIC	AAircraft17
		PUBLIC	AHelicopter1
		PUBLIC	AHelicopter2
		PUBLIC	AHelicopter3
		PUBLIC	AHelicopter4
		PUBLIC	EAircraft1
		PUBLIC	EAircraft2
		PUBLIC	EAircraft3
		PUBLIC	EAircraft4
		PUBLIC	EAircraft5
		PUBLIC	EAircraft6
		PUBLIC	EAircraft7
		PUBLIC	EAircraft8
		PUBLIC	EAircraft9
		PUBLIC	EAircraft10
		PUBLIC	EAircraft11
		PUBLIC	EAircraft12
		PUBLIC	EAircraft13
		PUBLIC	EAircraft14
		PUBLIC	EAircraft15
		PUBLIC	EAircraft16
		PUBLIC	EAircraft17
		PUBLIC	EHelicopter1
		PUBLIC	EHelicopter2
		PUBLIC	EHelicopter3
		PUBLIC	EHelicopter4
		PUBLIC	ATruckConvoy1
		PUBLIC	ATruck1_1
		PUBLIC	ATruck1_4
		PUBLIC	ATruckConvoy2
		PUBLIC	ATruck2_1
		PUBLIC	ATruck2_4
		PUBLIC	ETruckConvoy1
		PUBLIC	ETruck1_1
		PUBLIC	ETruck1_4
		PUBLIC	ETruckConvoy2
		PUBLIC	ETruck2_1
		PUBLIC	ETruck2_4
		PUBLIC	ATrain1
		PUBLIC	ATrain1_1
		PUBLIC	ATrain1_8
		PUBLIC	ATrain2
		PUBLIC	ATrain2_1
		PUBLIC	ATrain2_8
		PUBLIC	ETrain1
		PUBLIC	ETrain1_1
		PUBLIC	ETrain1_8
		PUBLIC	ETrain2
		PUBLIC	ETrain2_1
		PUBLIC	ETrain2_8
		PUBLIC	ATruck1Route
		PUBLIC	ATruck2Route
		PUBLIC	ETruck1Route
		PUBLIC	ETruck2Route
		PUBLIC	ATrain1Route
		PUBLIC	ATrain2Route
		PUBLIC	ETrain1Route
		PUBLIC	ETrain2Route
		PUBLIC	_M_VIEW
		PUBLIC	_FuelWt
		PUBLIC	_EXP_VIEW
		PUBLIC	_ExpMapZoom
		PUBLIC	_SecScanCnt1
		PUBLIC	_SecScanOff1
		PUBLIC	_SecScanCnt2
		PUBLIC	_SecScanOff2
		PUBLIC	_CloudBase
		PUBLIC	_CloudDepth
		PUBLIC	_GndTextEnabled
		PUBLIC	_TreesEnabled
		PUBLIC	_HillTxtEnabled
		PUBLIC	_CloudsEnabled
		PUBLIC	_StarsEnabled
		PUBLIC	_GradEnabled
		PUBLIC	_Overcast
		PUBLIC  _Fog
		PUBLIC	_Night
		PUBLIC	_PanelLight
		PUBLIC	_CHStick
		PUBLIC	_ThrustMaster
		PUBLIC	_TM_MinX
		PUBLIC	_TM_MinY
		PUBLIC	_TM_MidX
		PUBLIC	_TM_MidY
		PUBLIC	_TM_MaxX
		PUBLIC	_TM_MaxY
		PUBLIC	_TM_CoolieCn
		PUBLIC	_TM_CoolieLt
		PUBLIC	_TM_CoolieDn
		PUBLIC	_TM_CoolieRt
		PUBLIC	_TM_CoolieUp
		PUBLIC	RunwayDamage
		PUBLIC	GamePlayEnd

		EXTRN	COM2:ABS
		EXTRN	BAUD9600:ABS

;============================================================================

		INCLUDE	MAINDATA.INC
		INCLUDE	CONFIG.INC

		INCLUDE	\VISUAL\VISDATA.INC
		INCLUDE	\VISUAL\MOBLIST.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

;--------------------
;* miscellaneous data
;--------------------

TMP_VIEW	VIEWPOINT <>		;see VISDATA.INC
TMP2_VIEW	VIEWPOINT <>		;see VISDATA.INC
		EVEN

GameViewMode	DW	VIEW_PILOT	;see MAINDATA.INC

PanelMode	DW	PILOTPAN	;see MAINDATA.INC

CrewMode	DW	CREW_PILOT	;see MAINDATA.INC

AutoMode	DW	AUTO_OFF	;see MAINDATA.INC

AltMode		DW	ALT_MANUAL	;see MAINDATA.INC

HdgMode		DW	HDG_MANUAL	;see MAINDATA.INC

RadarMode	DW	NUL_RADAR	;see MAINDATA.INC

WayTotal  	DW	0		;num valid waypoints (always > 0)

ArmMode		DW	ARM_OFF		;see MAINDATA.INC

ShakeUp    DB 0  ;SHAKE Effects

FullScreen DB 1
;-------------------
;* waypoint pointers
;-------------------

WPPtr		DW	OFFSET WayList	;current waypoint ptr

EndWPPtr	DW	OFFSET WayList	;ptr to last valid waypoint

;-------------------
;* floating waypoint (target of opportunity, navigation aid etc.)
;-------------------

;* note: Always keep WP_TYPE = 1, WP_TF = 1 and WP_COORD = 0.

FloatWP		WAYPOINT <"T",00001001b,0,0,0,0,1000>

;------------------------------------
;* current waypoint range and bearing
;------------------------------------

WPRng		DD	0		;waypoint range
WPBrg		DW	0		;waypoint bearing (pdeg)
WPBrgFine	DW	0		;waypoint bearing (fine pdeg)
WPRngNMiles	DW	0		;waypoint range (nautical miles * 10)
WPETA		DW	0		;waypoint ETA (seconds) (-1 = invalid)
WPTimeEarlyLate	DW	-32768		;waypoint time early / late (secs * 100)
					; -32768 = invalid
					;    < 0 = late
					;    = 0 = on time
					;    > 0 = early

;--------------
;* red warnings (see MAINDATA.INC)
;--------------

RedWarnings1	DW	0		;on lamps (acknowledged failures)
RedWarnings2	DW	0		;flashing lamps (new failures)

;----------------
;* amber warnings (see MAINDATA.INC)
;----------------

AmbWarnings1	DW	0		;on lamps (acknowledged failures)
AmbWarnings2	DW	0		;flashing lamps (new failures)

;---------------------
;* miscellaneous flags
;---------------------

ShakePriority	DB	0		;screen shake priority (see MAINDATA.INC)

TmpDieFlag	DB	0

Jettison	DB	JET_NULL	;see MAINDATA.INC

		EVEN

;----------------
;* drone pointers (keep NUM_DRONES up to date - see MAINDATA.INC)
;----------------

DronePtrs	LABEL	WORD

		DW	OFFSET ATruck1_1	;0
		DW	OFFSET ATruck1_2	;1
		DW	OFFSET ATruck1_3	;2
		DW	OFFSET ATruck1_4	;3

		DW	OFFSET ATruck2_1	;4
		DW	OFFSET ATruck2_2	;5
		DW	OFFSET ATruck2_3	;6
		DW	OFFSET ATruck2_4	;7

		DW	OFFSET ETruck1_1	;8
		DW	OFFSET ETruck1_2	;9
		DW	OFFSET ETruck1_3	;10
		DW	OFFSET ETruck1_4	;11

		DW	OFFSET ETruck2_1	;12
		DW	OFFSET ETruck2_2	;13
		DW	OFFSET ETruck2_3	;14
		DW	OFFSET ETruck2_4	;15

		DW	OFFSET ATrain1_1	;16
		DW	OFFSET ATrain1_2	;17
		DW	OFFSET ATrain1_3	;18
		DW	OFFSET ATrain1_4	;19
		DW	OFFSET ATrain1_5	;20
		DW	OFFSET ATrain1_6	;21
		DW	OFFSET ATrain1_7	;22
		DW	OFFSET ATrain1_8	;23

		DW	OFFSET ATrain2_1	;24
		DW	OFFSET ATrain2_2	;25
		DW	OFFSET ATrain2_3	;26
		DW	OFFSET ATrain2_4	;27
		DW	OFFSET ATrain2_5	;28
		DW	OFFSET ATrain2_6	;29
		DW	OFFSET ATrain2_7	;30
		DW	OFFSET ATrain2_8	;31

		DW	OFFSET ETrain1_1	;32
		DW	OFFSET ETrain1_2	;33
		DW	OFFSET ETrain1_3	;34
		DW	OFFSET ETrain1_4	;35
		DW	OFFSET ETrain1_5	;36
		DW	OFFSET ETrain1_6	;37
		DW	OFFSET ETrain1_7	;38
		DW	OFFSET ETrain1_8	;39

		DW	OFFSET ETrain2_1	;40
		DW	OFFSET ETrain2_2	;41
		DW	OFFSET ETrain2_3	;42
		DW	OFFSET ETrain2_4	;43
		DW	OFFSET ETrain2_5	;44
		DW	OFFSET ETrain2_6	;45
		DW	OFFSET ETrain2_7	;46
		DW	OFFSET ETrain2_8	;47

		DW	OFFSET AAircraft1	;48
		DW	OFFSET AAircraft2	;49
		DW	OFFSET AAircraft3	;50
		DW	OFFSET AAircraft4	;51
		DW	OFFSET AAircraft5	;52
		DW	OFFSET AAircraft6	;53
		DW	OFFSET AAircraft7	;54
		DW	OFFSET AAircraft8	;55
		DW	OFFSET AAircraft9	;56
		DW	OFFSET AAircraft10	;57
		DW	OFFSET AAircraft11	;58
		DW	OFFSET AAircraft12	;59
		DW	OFFSET AAircraft13	;60
		DW	OFFSET AAircraft14	;61
		DW	OFFSET AAircraft15	;62
		DW	OFFSET AAircraft16	;63
		DW	OFFSET AAircraft17	;64

		DW	OFFSET AHelicopter1 	;65
		DW	OFFSET AHelicopter2 	;66
		DW	OFFSET AHelicopter3 	;67
		DW	OFFSET AHelicopter4 	;68
						   
		DW	OFFSET EAircraft1	;69
		DW	OFFSET EAircraft2	;70
		DW	OFFSET EAircraft3	;71 
		DW	OFFSET EAircraft4	;72
		DW	OFFSET EAircraft5	;73
		DW	OFFSET EAircraft6	;74
		DW	OFFSET EAircraft7	;75
		DW	OFFSET EAircraft8	;76
		DW	OFFSET EAircraft9	;77
		DW	OFFSET EAircraft10	;78
		DW	OFFSET EAircraft11	;79
		DW	OFFSET EAircraft12	;80
		DW	OFFSET EAircraft13	;81
		DW	OFFSET EAircraft14	;82
		DW	OFFSET EAircraft15	;83
		DW	OFFSET EAircraft16	;84
		DW	OFFSET EAircraft17	;85

		DW	OFFSET EHelicopter1 	;86
		DW	OFFSET EHelicopter2 	;87
		DW	OFFSET EHelicopter3 	;88
		DW	OFFSET EHelicopter4 	;89

;----------------------------------------------
;* drone ptr lists required for drone view mode
;----------------------------------------------

AAirDronePtrs	LABEL	WORD		;allied aircraft

		DW	OFFSET AAircraft1
		DW	OFFSET AAircraft2
		DW	OFFSET AAircraft3
		DW	OFFSET AAircraft4
		DW	OFFSET AAircraft5
		DW	OFFSET AAircraft6
		DW	OFFSET AAircraft7
		DW	OFFSET AAircraft8
		DW	OFFSET AAircraft9
		DW	OFFSET AAircraft10
		DW	OFFSET AAircraft11
		DW	OFFSET AAircraft12
		DW	OFFSET AAircraft13
		DW	OFFSET AAircraft14
		DW	OFFSET AAircraft15
		DW	OFFSET AAircraft16
		DW	OFFSET AAircraft17
		DW	OFFSET AHelicopter1
		DW	OFFSET AHelicopter2
		DW	OFFSET AHelicopter3
AAirDroneLast	DW	OFFSET AHelicopter4

EAirDronePtrs	LABEL	WORD		;enemy aircraft

		DW	OFFSET EAircraft1
		DW	OFFSET EAircraft2
		DW	OFFSET EAircraft3
		DW	OFFSET EAircraft4
		DW	OFFSET EAircraft5
		DW	OFFSET EAircraft6
		DW	OFFSET EAircraft7
		DW	OFFSET EAircraft8
		DW	OFFSET EAircraft9
		DW	OFFSET EAircraft10
		DW	OFFSET EAircraft11
		DW	OFFSET EAircraft12
		DW	OFFSET EAircraft13
		DW	OFFSET EAircraft14
		DW	OFFSET EAircraft15
		DW	OFFSET EAircraft16
		DW	OFFSET EAircraft17
		DW	OFFSET EHelicopter1
		DW	OFFSET EHelicopter2
		DW	OFFSET EHelicopter3
EAirDroneLast	DW	OFFSET EHelicopter4

AGndDronePtrs	LABEL	WORD		;allied ground vehicles

		DW	OFFSET ATruck1_1
		DW	OFFSET ATruck2_1
		DW	OFFSET ATrain1_1
AGndDroneLast	DW	OFFSET ATrain2_1

EGndDronePtrs	LABEL	WORD		;enemy ground vehicles

		DW	OFFSET ETruck1_1
		DW	OFFSET ETruck2_1
		DW	OFFSET ETrain1_1
EGndDroneLast	DW	OFFSET ETrain2_1

;----------------------------------------------------------------------------

;---------------------
;* game play data size
;---------------------

GameDataSize	DW	OFFSET GamePlayEnd-OFFSET GamePlayData

;---------------------------
GamePlayData	LABEL	BYTE
;---------------------------

		DW	OFFSET GamePlayData	;data start datum

;--------------------
;* miscellaneous data
;--------------------

TornadoType	DW	IDS_TORNADO	;see MAINDATA.INC

ControlDevice	DW	CTRL_DEV_JOY1	;see MAINDATA.INC

SoundCard	DW	SND_NULL	;see MAINDATA.INC

MusicCard	DW	SND_NULL	;see MAINDATA.INC

RedWarnings	DW	0		;see MAINDATA.INC

AmbWarnings	DW	0		;see MAINDATA.INC

StartAirspeed	DW	200		;start airborne airspeed (ias) 200 .. 800

TimeLimit	DD	0		;time limit for "global timeout" (secs * 100)

APilotSkill	DW	32767		;allied pilot skill (0 .. 32767)
EPilotSkill	DW	32767		;enemy pilot skill (0 .. 32767)

XWindVmax	DW	0		;max crosswind velocity (ft/sec * 8)
					;0 = no crosswinds
					;range = XWIND_VMIN .. XWIND_VMAX

XWindDir	DW	0		;crosswind direction (0 .. 511 pdegs)

;---------------------
;* miscellaneous flags
;---------------------

ExploreMode	DB	0		;1 = map explore mode enabled

	IF	OPT_PREVIEW EQ 0

PreviewMode	DB	0		;0 = no preview
					;1 = object preview
					;2 = auto-run object preview

	ELSE

PreviewMode	DB	1

	ENDIF

DemoMode	DB	OPT_DEMO	;0 = no demo
					;1 = drone cycling demo
					;2 = flying demo

NoCollisions	DB	0		;1 = collision detection off

DieFlag		DB	0		;see MAINDATA.INC (init to 0)

Landing		DB	0		;see MAINDATA.INC (init to 0)

InfiniteWeapons	DB	0		;1 = infinite weapons

InfiniteFuel	DB	0		;1 = infinite fuel

InfiniteGForce	DB	0		;1 = no blackouts or redouts

IronWork	DB	1		;1 = shown, 0 = hidden

;NightVisionState DB 0 ;1 = NVG is on, 0 = off

TwoPlayer	DB	0		;1 = two player mode enabled

CommsDevice	DB	COM2		;see COMMS.ASM

BaudRate	DB	BAUD9600	;see COMMS.ASM

SoundOption	DB	SOUND_OPT_ENG	;see MAINDATA.INC

Destroyed	DB	0		;see MAINDATA.INC

Ejected		DB	0		;1 = ejected

StartAirborne	DB	0		;1 = start airborne

AutoTrack	DB	0		;1 = start in track mode

DamagedLEng	DB	0		;1 = start with damaged lh engine

DamagedREng	DB	0		;1 = start with damaged rh engine

FixMinWeight	DB	0		;1 = set fixed weight to minimum

NoFire		DB	0		;1 = no hostile fire (allied or enemy)

GlobalTimeout	DB	0		;1 = global timeout enabled

HitObjectNum	DB	0		;number of object crashed into (ground / mobile)

		EVEN

;---------------
;* 24 hour clock
;---------------

;* Note: -1 hours indicates that the time has not been passed from mission
;*       planning so read actual time from real-time clock (see InitGame).

Clock24		CLOCK <-1,0,0,0>	;see MAINDATA.INC

		EVEN

;-------------------------
;* Tornado external stores
;-------------------------

	IF	OPT_FLY_DEMO EQ 0

ExtStores	DW	0		;EXT_GPB1000
		DW	0		;EXT_RET1000
		DW	1		;EXT_LGB1000
		DW	0		;EXT_BL755
		DW	1		;EXT_JP233
		DW	4		;EXT_ALARM
		DW	2		;EXT_SIDEWINDER
		DW	0		;EXT_SKYFLASH (ADV only)
		DW	1		;EXT_BOZ100 (IDS / ECR only)
		DW	1		;EXT_SKYSHADOW (IDS / ECR only)
		DW	2		;EXT_DROPTANK

	ELSE

ExtStores	DW	0		;EXT_GPB1000
		DW	0		;EXT_RET1000
		DW	0		;EXT_LGB1000
		DW	0		;EXT_BL755
		DW	0		;EXT_JP233
		DW	0		;EXT_ALARM
		DW	0		;EXT_SIDEWINDER
		DW	0		;EXT_SKYFLASH (ADV only)
		DW	0		;EXT_BOZ100 (IDS / ECR only)
		DW	0		;EXT_SKYSHADOW (IDS / ECR only)
		DW	0		;EXT_DROPTANK

	ENDIF

;------------------
;* weapons packages
;------------------

	IF	OPT_FLY_DEMO EQ 0

Packages	LABEL	PACKAGE

		;Available ordnance:
		;GPB1000  RET1000 LGB1000 BL755 JP233  ALARM BOZ100 SKYSHADOW

		;Available arming modes:
        ;ARM_OFF		= off
        ;ARM_MANUAL	= manual bombing
        ;ARM_LAYDOWN	= laydown bombing
        ;ARM_LOFT	= loft bombing
        ;ARM_LGB		= laser guided bomb
        ;ARM_JP233	= JP233
        ;ARM_ALARM_DIR = ;ALARM (direct attack mode)
        ;ARM_ALARM_IND = ALARM (indirect attack mode)
        ;ARM_CANNON = cannon
        ;ARM_SIDEWINDER = Sidewinder
        ;ARM_SKYFLASH = Skyflas

		;Previously the default IDS package was:
		;PACKAGE	<'-',   ALARM, 4, ARM_ALARM_DIR>
		;PACKAGE	<'-', LGB1000, 1, ARM_LGB>
		;PACKAGE	<'-', GPB1000, 4, ARM_MANUAL>
		;PACKAGE	<'-',   JP233, 1, ARM_JP233>
		
		;Now the default IDS package is:
		PACKAGE	<'-', LGB1000, 4, ARM_LGB>
		PACKAGE	<'-', RET1000, 2, ARM_MANUAL>
		PACKAGE	<'-',   BL755, 2, ARM_MANUAL>

		EVEN

	ELSE

Packages	LABEL	PACKAGE

		PACKAGE	<>
		PACKAGE	<>
		PACKAGE	<>

		EVEN

	ENDIF

;-------------------
;* Tornado waypoints
;-------------------

StartWaypoint	DW	1		;0 = 'A', 1 = 'B' etc.

;* note: This route has been set up for the flying demo. DO NOT CHANGE.

WayList		LABEL	WAYPOINT

		WAYPOINT <'A', 10001001b, 16, 16,     0,     0, 1000, 7072>
		WAYPOINT <'B', 10001101b, 18, 17, -7168, -2048,  200, 7072>
		WAYPOINT <'C', 10001001b, 20, 19,  4608,  7680,  200, 7072>
		WAYPOINT <'D', 10001001b, 22, 17, -4672, -4288,  200, 7072>
		WAYPOINT <'E', 10001001b, 23, 14,  3072, -8192,  200, 7072>
		WAYPOINT <'F', 10000001b, 25, 16,   512,     0,   10, 7072>
		WAYPOINT <'G', 10000001b, 25, 17, -1792,  3840,  200, 7072>
		WAYPOINT <'H', 10001001b, 27, 17, -3232,  6784,  200, 7072>
		WAYPOINT <'I', 10001001b, 28, 14,  6912,  7424,  200, 7072>
		WAYPOINT <'J', 10001001b, 26, 10,  2688,  1856,  200, 7072>
		WAYPOINT <'K', 10001001b, 27,  8, -1024, -7168,  200, 7072>
		WAYPOINT <'L', 10001001b, 23, 10, -2304,  3072,  200, 7072>
		WAYPOINT <'M', 10001001b, 15, 13,   224,   416,  200, 7072>
		WAYPOINT <'N', 10001001b, 14, 12, -3584, -5120,  750, 7072>
		WAYPOINT <'O', 10001011b, 15, 15,  7168,     0, 1500, 7072>

		REPT	NUM_WP_LONG-15
		WAYPOINT <>
		ENDM

		ENDROUTE <>

		EVEN

;-----------
;* airfields
;-----------

AirfieldList	LABEL	WORD

		AIRFIELD <16,16,0,0011b>	;1
		AIRFIELD < 5,16,0,1100b>	;2
		AIRFIELD < 4,26,0,0011b>	;3
		AIRFIELD <23,25,0,0011b>	;4

		EVEN

;--------------
;* kills tables (index using object number)
;--------------

AGndKills	DB	128 DUP(0)
EGndKills	DB	128 DUP(0)

AMobKills	DB	64 DUP(0)
EMobKills	DB	64 DUP(0)

;-------------------------
;* allied / enemy EWR data
;-------------------------

EWRTable	EWR	NUM_EWR*2 DUP(<>)	;(allied and enemy)

;-----------------------------------------
;* drone aircraft / helicopter data macros
;-----------------------------------------

DEF_AIRCRAFT	MACRO	num_waypoints

		MOBILE <>
		VIEWPOINT <>
		AIRCRAFT <>

		REPT	num_waypoints
		WAYPOINT <>
		ENDM

		ENDROUTE <>

		EVEN

		ENDM

DEF_HELICOPTER	MACRO	num_waypoints

		MOBILE <>
		VIEWPOINT <>
		HELICOPTER <>

		REPT	num_waypoints
		WAYPOINT <>
		ENDM

		ENDROUTE <>

		EVEN

		ENDM

;-----------------------------------
;* ///// allied drone aircraft /////
;-----------------------------------

;---------------------------
AAircraft1	LABEL	BYTE		;interdiction / strike aircraft
;---------------------------

	IF	DRONE_AC_ON EQ 0

		DEF_AIRCRAFT	NUM_WP_LONG

	ELSE

		MOBILE <MOB_TORNADO1,OTYPE_MOBILE3>
		VIEWPOINT <16,16,0,0,0,384>
		AIRCRAFT <DRONE_AIRCRAFT,ALLIED,,GR4_TORNADO,0*100,0,-1>

		WAYPOINT <"A",10000001b,16,16,   0,0,   0,  0,AC_WP_TAKEOFF>
		WAYPOINT <"B",10101001b,14,16,   0,0,1000, 65>
		WAYPOINT <"C",10101001b,13,15,   0,0,1000, 65+39>
		WAYPOINT <"D",10101001b,14,14,   0,0,1000, 65+39+39>
		WAYPOINT <"E",10101001b,18,14,   0,0,1000, 65+39+39+90>
		WAYPOINT <"F",10101001b,19,15,   0,0,1000, 65+39+39+90+39>
		WAYPOINT <"G",10101000b,18,16,   0,0,1000, 65+39+39+90+39+50>
		WAYPOINT <"H",10010001b,16,16,3840,0,   0,  0,AC_WP_TAXI>

		REPT	NUM_WP_LONG-8
		WAYPOINT <>
		ENDM

		ENDROUTE <>

		EVEN

	ENDIF

;---------------------------
AAircraft2	LABEL	BYTE		;interdiction / strike aircraft
;---------------------------

	IF	DRONE_AC_ON EQ 0

		DEF_AIRCRAFT	NUM_WP_LONG

	ELSE

		MOBILE <MOB_TORNADO1,OTYPE_MOBILE3>
		VIEWPOINT <16,16,1000,0,0,384>
		AIRCRAFT <DRONE_AIRCRAFT,ALLIED,,GR4_TORNADO,0*100,0,-1>

		WAYPOINT <"A",10000001b,16,16,1000,   0,   0,  0,AC_WP_TAKEOFF>
		WAYPOINT <"B",10101001b,14,16, 200, 100,1000, 65>
		WAYPOINT <"C",10101001b,13,15, 223,   0,1000, 65+39>
		WAYPOINT <"D",10101001b,14,14,   0,-233,1000, 65+39+39>
		WAYPOINT <"E",10101001b,18,14,-200,-100,1000, 65+39+39+90>
		WAYPOINT <"F",10101001b,19,15,   0,   0,1000, 65+39+39+90+39+10>
		WAYPOINT <"G",10101000b,18,16,   0,   0,1000, 65+39+39+90+39+50+20>
		WAYPOINT <"H",10010001b,16,16,3840,   0,   0,  0,AC_WP_TAXI>

		REPT	NUM_WP_LONG-8
		WAYPOINT <>
		ENDM

		ENDROUTE <>

		EVEN

	ENDIF

;---------------------------
AAircraft3	LABEL	BYTE		;interdiction / strike aircraft
;---------------------------

	IF	DRONE_AC_ON EQ 0

		DEF_AIRCRAFT	NUM_WP_LONG

	ELSE

		MOBILE <MOB_TORNADO1,OTYPE_MOBILE3>
		VIEWPOINT <5,16,0,-256,0,0>
		AIRCRAFT <DRONE_AIRCRAFT,ALLIED,,GR4_TORNADO,2*100,0,-1>

		WAYPOINT <"A",10000000b, 5,16,0, -256,   0,   0,AC_WP_TAKEOFF>
		WAYPOINT <"B",10001101b, 0, 9,0,    0, 500,6000>
		WAYPOINT <"C",10001001b,11, 5,0,    0, 200,6000>
		WAYPOINT <"D",10001001b, 2,20,0,    0, 200,6000>
 		WAYPOINT <"E",10001011b,17,20,0,    0, 200,6000>

		REPT	NUM_WP_LONG-5
		WAYPOINT <>
		ENDM

		ENDROUTE <>

		EVEN

	ENDIF

;---------------------------
AAircraft4	LABEL	BYTE		;interdiction / strike aircraft
;---------------------------

	IF	DRONE_AC_ON EQ 0

		DEF_AIRCRAFT	NUM_WP_LONG

	ELSE

		MOBILE <MOB_TORNADO1,OTYPE_MOBILE3>
		VIEWPOINT <5,16,0,-384,0,0>
		AIRCRAFT <DRONE_AIRCRAFT,ALLIED,,GR4_TORNADO,3*100,0,-1>

		WAYPOINT <"A",10000000b, 5,16,0, -384,   0,   0,AC_WP_TAKEOFF>
		WAYPOINT <"B",10001101b, 0, 9,0,    0, 500,6000>
		WAYPOINT <"C",10001001b,11, 5,0,    0, 200,6000>
		WAYPOINT <"D",10001001b, 2,20,0,    0, 200,6000>
 		WAYPOINT <"E",10001011b,17,20,0,    0, 200,6000>

		REPT	NUM_WP_LONG-5
		WAYPOINT <>
		ENDM

		ENDROUTE <>

		EVEN

	ENDIF

;---------------------------
AAircraft5	LABEL	BYTE		;interdiction / strike aircraft
;---------------------------

	IF	DRONE_AC_ON EQ 0

		DEF_AIRCRAFT	NUM_WP_LONG

	ELSE

		MOBILE <MOB_TORNADO1,OTYPE_MOBILE3>
		VIEWPOINT <23,25,0,1536,0,384>
		AIRCRAFT <DRONE_AIRCRAFT,ALLIED,,GR4_TORNADO,0*100,0,-1>

		WAYPOINT <"A",10000000b,23,25,  0, 1536,   0,   0,AC_WP_TAKEOFF>
		WAYPOINT <"B",10000101b,23,23,  0,    0,5500,6000>
		WAYPOINT <"C",10000001b,22,20,  0,    0,5000,6000>
		WAYPOINT <"D",10000001b,24,20,  0,    0,5000,6000>
 		WAYPOINT <"E",10000011b,25,24,  0,    0,5000,6000>

		REPT	NUM_WP_LONG-5
		WAYPOINT <>
		ENDM

		ENDROUTE <>

		EVEN

	ENDIF

;---------------------------
AAircraft6	LABEL	BYTE		;interdiction / strike aircraft
;---------------------------

	IF	DRONE_AC_ON EQ 0

		DEF_AIRCRAFT	NUM_WP_LONG

	ELSE

		MOBILE <MOB_TORNADO1,OTYPE_MOBILE3>
		VIEWPOINT <23,25,128,1536,0,384>
		AIRCRAFT <DRONE_AIRCRAFT,ALLIED,,GR4_TORNADO,1*100,0,-1>

		WAYPOINT <"A",10000000b,23,25,128, 1536,   0,   0,AC_WP_TAKEOFF>
		WAYPOINT <"B",10000101b,23,23,  0,    0,5500,6000>
		WAYPOINT <"C",10000001b,22,20,  0,    0,5000,6000>
		WAYPOINT <"D",10000001b,24,20,  0,    0,5000,6000>
 		WAYPOINT <"E",10000011b,25,24,  0,    0,5000,6000>

		REPT	NUM_WP_LONG-5
		WAYPOINT <>
		ENDM

		ENDROUTE <>

		EVEN

	ENDIF

;---------------------------
AAircraft7	LABEL	BYTE		;air defence aircraft
;---------------------------

	IF	DRONE_AC_ON EQ 0

		DEF_AIRCRAFT	NUM_WP_LONG

	ELSE

		MOBILE <MOB_TORNADV1,OTYPE_MOBILE3>
		VIEWPOINT <23,25,256,1536,0,384>
		AIRCRAFT <DRONE_AIRCRAFT,ALLIED,,F3_TORNADO,2*100,0,-1>

		WAYPOINT <"A",10000000b,23,25,  256, 1536,   0,   0,AC_WP_TAKEOFF>
		WAYPOINT <"B",10000101b,23,23,    0,    0,5500,6000>
		WAYPOINT <"C",10000001b,22,20,    0,    0,5000,6000>
		WAYPOINT <"D",10000001b,24,20,    0,    0,5000,6000>
 		WAYPOINT <"E",10000011b,25,24,    0,    0,5000,6000>
 		WAYPOINT <"F",11001001b,19,16,    0,    0,1000,5000>
 		WAYPOINT <"G",10001001b,18,16,    0,    0,1000,4000>
 		WAYPOINT <"H",10001000b,17,16,    0,    0,1000,3000>
 		WAYPOINT <"I",10010001b,16,16, 3840,    0,   0,   0,AC_WP_RESTART>

		REPT	NUM_WP_LONG-9
		WAYPOINT <>
		ENDM

		ENDROUTE <>

		EVEN

	ENDIF

;---------------------------
AAircraft8	LABEL	BYTE		;air defence aircraft
;---------------------------

	IF	DRONE_AC_ON EQ 0

		DEF_AIRCRAFT	NUM_WP_LONG

	ELSE

		MOBILE <MOB_TORNADV1,OTYPE_MOBILE3>
		VIEWPOINT <23,25,384,1536,0,384>
		AIRCRAFT <DRONE_AIRCRAFT,ALLIED,,F3_TORNADO,3*100,0,-1>

		WAYPOINT <"A",10000000b,23,25,  384, 1536,   0,   0,AC_WP_TAKEOFF>
		WAYPOINT <"B",10000101b,23,23,    0,    0,5500,6000>
		WAYPOINT <"C",10000001b,22,20,    0,    0,5000,6000>
		WAYPOINT <"D",10000001b,24,20,    0,    0,5000,6000>
 		WAYPOINT <"E",10000011b,25,24,    0,    0,5000,6000>
 		WAYPOINT <"F",11001001b,19,16,    0,    0,1000,5000>
 		WAYPOINT <"G",10001001b,18,16,    0,    0,1000,4000>
 		WAYPOINT <"H",10001000b,17,16,    0,    0,1000,3000>
 		WAYPOINT <"I",10010001b,16,16, 3840,    0,   0,   0,AC_WP_RESTART>

		REPT	NUM_WP_LONG-9
		WAYPOINT <>
		ENDM

		ENDROUTE <>

		EVEN

	ENDIF

;---------------------------
AAircraft9	LABEL	BYTE		;interceptor / air superiority aircraft
;---------------------------

	IF	DRONE_AC_ON EQ 0

		DEF_AIRCRAFT	NUM_WP_SHORT

	ELSE

		MOBILE <MOB_F15,OTYPE_MOBILE3>
		VIEWPOINT <4,26,0,-768,0,384>
		AIRCRAFT <DRONE_AIRCRAFT,ALLIED,,F15_EAGLE,0*100,0,-1>

		WAYPOINT <"A",10000000b, 4,26,    0, -768,   0,   0,AC_WP_TAKEOFF>
		WAYPOINT <"B",10001101b, 2,25,    0,    0,1100,6000>
		WAYPOINT <"C",10001001b, 3,20,    0,    0,1000,6000>
		WAYPOINT <"D",10001001b,18,19,    0,    0,1000,6000>
 		WAYPOINT <"E",10001011b,11,25,    0,    0,1000,6000>
 		WAYPOINT <"F",11001001b,19,16,    0,    0,1000,5000>
 		WAYPOINT <"G",10001001b,18,16,    0,    0,1000,4000>
 		WAYPOINT <"H",10001000b,17,16,    0,    0,1000,3000>
 		WAYPOINT <"I",10010001b,16,16, 3840,    0,   0,   0,AC_WP_RESTART>

		REPT	NUM_WP_SHORT-9
		WAYPOINT <>
		ENDM

		ENDROUTE <>

		EVEN

	ENDIF

;---------------------------
AAircraft10	LABEL	BYTE		;interceptor / air superiority aircraft
;---------------------------

	IF	DRONE_AC_ON EQ 0

		DEF_AIRCRAFT	NUM_WP_SHORT

	ELSE

		MOBILE <MOB_F15,OTYPE_MOBILE3>
		VIEWPOINT <4,26,128,-768,0,384>
		AIRCRAFT <DRONE_AIRCRAFT,ALLIED,,F15_EAGLE,1*100,0,-1>

		WAYPOINT <"A",10000000b, 4,26,  128, -768,   0,   0,AC_WP_TAKEOFF>
		WAYPOINT <"B",10001101b, 2,25,    0,    0,1100,6000>
		WAYPOINT <"C",10001001b, 3,20,    0,    0,1000,6000>
		WAYPOINT <"D",10001001b,18,19,    0,    0,1000,6000>
 		WAYPOINT <"E",10001011b,11,25,    0,    0,1000,6000>
 		WAYPOINT <"F",11001001b,19,16,    0,    0,1000,5000>
 		WAYPOINT <"G",10001001b,18,16,    0,    0,1000,4000>
 		WAYPOINT <"H",10001000b,17,16,    0,    0,1000,3000>
 		WAYPOINT <"I",10010001b,16,16, 3840,    0,   0,   0,AC_WP_RESTART>

		REPT	NUM_WP_SHORT-9
		WAYPOINT <>
		ENDM

		ENDROUTE <>

		EVEN

	ENDIF

;---------------------------
AAircraft11	LABEL	BYTE		;interceptor / air superiority aircraft
;---------------------------

	IF	DRONE_AC_ON EQ 0

		DEF_AIRCRAFT	NUM_WP_SHORT

	ELSE

		MOBILE <MOB_F16,OTYPE_MOBILE3>
		VIEWPOINT <4,26,256,-768,0,384>
		AIRCRAFT <DRONE_AIRCRAFT,ALLIED,,F16_FALCON,2*100,0,-1>

		WAYPOINT <"A",10000000b, 4,26,  256, -768,   0,   0,AC_WP_TAKEOFF>
		WAYPOINT <"B",10001101b, 2,25,    0,    0,1600,6000>
		WAYPOINT <"C",10001001b, 3,20,    0,    0,1500,6000>
		WAYPOINT <"D",10001001b,18,19,    0,    0,1500,6000>
 		WAYPOINT <"E",10001011b,11,25,    0,    0,1500,6000>
 		WAYPOINT <"F",11001001b,19,16,    0,    0,1000,5000>
 		WAYPOINT <"G",10001001b,18,16,    0,    0,1000,4000>
 		WAYPOINT <"H",10001000b,17,16,    0,    0,1000,3000>
 		WAYPOINT <"I",10010001b,16,16, 3840,    0,   0,   0,AC_WP_RESTART>

		REPT	NUM_WP_SHORT-9
		WAYPOINT <>
		ENDM

		ENDROUTE <>

		EVEN

	ENDIF

;---------------------------
AAircraft12	LABEL	BYTE		;interceptor / air superiority aircraft
;---------------------------

	IF	DRONE_AC_ON EQ 0

		DEF_AIRCRAFT	NUM_WP_SHORT

	ELSE

		MOBILE <MOB_F16,OTYPE_MOBILE3>
		VIEWPOINT <4,26,384,-768,0,384>
		AIRCRAFT <DRONE_AIRCRAFT,ALLIED,,F16_FALCON,3*100,0,-1>

		WAYPOINT <"A",10000000b, 4,26,  384, -768,   0,   0,AC_WP_TAKEOFF>
		WAYPOINT <"B",10001101b, 2,25,    0,    0,1600,6000>
		WAYPOINT <"C",10001001b, 3,20,    0,    0,1500,6000>
		WAYPOINT <"D",10001001b,18,19,    0,    0,1500,6000>
 		WAYPOINT <"E",10001011b,11,25,    0,    0,1500,6000>
 		WAYPOINT <"F",11001001b,19,16,    0,    0,1000,5000>
 		WAYPOINT <"G",10001001b,18,16,    0,    0,1000,4000>
 		WAYPOINT <"H",10001000b,17,16,    0,    0,1000,3000>
 		WAYPOINT <"I",10010001b,16,16, 3840,    0,   0,   0,AC_WP_RESTART>

		REPT	NUM_WP_SHORT-9
		WAYPOINT <>
		ENDM

		ENDROUTE <>

		EVEN

	ENDIF

;---------------------------
AAircraft13	LABEL	BYTE		;close air support / attack aircraft
;---------------------------

	IF	DRONE_AC_ON EQ 0

		DEF_AIRCRAFT	NUM_WP_SHORT

	ELSE

		MOBILE <MOB_A10,OTYPE_MOBILE3>
		VIEWPOINT <15,15,0,0,500,256>
		AIRCRAFT <DRONE_AIRCRAFT,ALLIED,,A10_THUNDERBOLT,0*100,0,-1>

		WAYPOINT <"A",10001100b,15,15,0,0,500,4760,AC_WP_AIRBORNE>
		WAYPOINT <"B",10001000b,15,17,0,0,500,4760>
		WAYPOINT <"C",10001000b,17,17,0,0,500,4760>
		WAYPOINT <"D",10001010b,17,15,0,0,500,4760>

		REPT	NUM_WP_SHORT-4
		WAYPOINT <>
		ENDM

		ENDROUTE <>

		EVEN

	ENDIF

;---------------------------
AAircraft14	LABEL	BYTE		;close air support / attack aircraft
;---------------------------

	IF	DRONE_AC_ON EQ 0

		DEF_AIRCRAFT	NUM_WP_SHORT

	ELSE

		MOBILE <MOB_A10,OTYPE_MOBILE3>
		VIEWPOINT <17,17,0,0,500,0>
		AIRCRAFT <DRONE_AIRCRAFT,ALLIED,,A10_THUNDERBOLT,0*100,0,-1>

		WAYPOINT <"A",10001100b,17,17,0,0,500,4760,AC_WP_AIRBORNE>
		WAYPOINT <"B",10001000b,17,15,0,0,500,4760>
		WAYPOINT <"C",10001000b,15,15,0,0,500,4760>
		WAYPOINT <"D",10001010b,15,17,0,0,500,4760>

		REPT	NUM_WP_SHORT-4
		WAYPOINT <>
		ENDM

		ENDROUTE <>

		EVEN

	ENDIF

;---------------------------
AAircraft15	LABEL	BYTE		;heavy lift transport aircraft
;---------------------------

	IF	DRONE_AC_ON EQ 0

		DEF_AIRCRAFT	NUM_WP_SHORT

	ELSE

		MOBILE <MOB_C130,OTYPE_MOBILE3>
		VIEWPOINT <0,20,0,0,10000,256>
		AIRCRAFT <DRONE_AIRCRAFT,ALLIED,,C130_HERCULES,0*100,0,-1>

		WAYPOINT <"A",10000100b, 0,20,0,0,10000,4760,AC_WP_AIRBORNE>
		WAYPOINT <"B",10000000b, 0,28,0,0,10000,4760>
		WAYPOINT <"C",10000000b,31,28,0,0,10000,4760>
		WAYPOINT <"D",10000010b,31,20,0,0,10000,4760>

		REPT	NUM_WP_SHORT-4
		WAYPOINT <>
		ENDM

		ENDROUTE <>

		EVEN

	ENDIF

;---------------------------
AAircraft16	LABEL	BYTE		;heavy lift transport aircraft
;---------------------------

	IF	DRONE_AC_ON EQ 0

		DEF_AIRCRAFT	NUM_WP_SHORT

	ELSE

		MOBILE <MOB_C130,OTYPE_MOBILE3>
		VIEWPOINT <31,28,0,0,10000,0>
		AIRCRAFT <DRONE_AIRCRAFT,ALLIED,,C130_HERCULES,0*100,0,-1>

		WAYPOINT <"A",10000100b,31,28,0,0,10000,4760,AC_WP_AIRBORNE>
		WAYPOINT <"B",10000000b,31,20,0,0,10000,4760>
		WAYPOINT <"C",10000000b, 0,20,0,0,10000,4760>
		WAYPOINT <"D",10000010b, 0,28,0,0,10000,4760>

		REPT	NUM_WP_SHORT-4
		WAYPOINT <>
		ENDM

		ENDROUTE <>

		EVEN

	ENDIF

;---------------------------
AAircraft17	LABEL	BYTE		;airborne early warning aircraft
;---------------------------

	IF	DRONE_AC_ON EQ 0

		DEF_AIRCRAFT	NUM_WP_SHORT

	ELSE

		MOBILE <MOB_E3D,OTYPE_MOBILE3>
		VIEWPOINT <8,0,0,0,11000,256>
		AIRCRAFT <DRONE_AIRCRAFT,ALLIED,,E3D_SENTRY,0*100,0,-1>

		WAYPOINT <"A",10000100b, 8, 0,0,0,11000,4760,AC_WP_AIRBORNE>
		WAYPOINT <"B",10000000b, 8,15,0,0,11000,4760>
		WAYPOINT <"C",10000000b,24,15,0,0,11000,4760>
		WAYPOINT <"D",10000010b,24, 0,0,0,11000,4760>

		REPT	NUM_WP_SHORT-4
		WAYPOINT <>
		ENDM

		ENDROUTE <>

		EVEN

	ENDIF

;---------------------------
AHelicopter1	LABEL	BYTE		;gunship helicopter
;---------------------------

	IF	DRONE_HC_ON EQ 0

		DEF_HELICOPTER	NUM_WP_SHORT

	ELSE

		MOBILE <MOB_AH64,OTYPE_MOBILE3>
		VIEWPOINT <16,16,2304,-768,0,0>
		HELICOPTER <DRONE_HELICOPT,ALLIED,,AH64_APACHE,8*100,0,-1>

		WAYPOINT <"A",10000001b,16,16, 2304, -768,   0,   0,HC_WP_TAKEOFF>
		WAYPOINT <"B",10001101b,16,16,    0, 4000, 200,1360>
		WAYPOINT <"C",10001011b,16,16,-2816, 2048, 100,1600>
		WAYPOINT <"D",11001001b,16,16,-1500, 1000, 100,1360>
		WAYPOINT <"E",10010001b,16,16,-2816, 2048, 100,   0,HC_WP_RESTART>

		REPT	NUM_WP_SHORT-5
		WAYPOINT <>
		ENDM

		ENDROUTE <>

		EVEN

	ENDIF

;---------------------------
AHelicopter2	LABEL	BYTE		;gunship helicopter
;---------------------------

	IF	DRONE_HC_ON EQ 0

		DEF_HELICOPTER	NUM_WP_SHORT

	ELSE

		MOBILE <MOB_AH64,OTYPE_MOBILE3>
		VIEWPOINT <13,20,6800,5800,100,384>
		HELICOPTER <DRONE_HELICOPT,ALLIED,,AH64_APACHE,0,0,-1>

		WAYPOINT <"A",10000001b,13,20, 6800, 5800, 100,1360,HC_WP_AIRBORNE>
		WAYPOINT <"B",10001101b,13,20, 3800, 7000, 100,1360>
		WAYPOINT <"C",10001001b,13,20, 4000, 2900, 200,1600>
		WAYPOINT <"D",11001011b,14,20,-6900, 3900,  75,1360>

		REPT	NUM_WP_SHORT-4
		WAYPOINT <>
		ENDM

		ENDROUTE <>

		EVEN

	ENDIF

;---------------------------
AHelicopter3	LABEL	BYTE		;heavy lift helicopter
;---------------------------

	IF	DRONE_HC_ON EQ 0

		DEF_HELICOPTER	NUM_WP_SHORT

	ELSE

		MOBILE <MOB_CHINOOK,OTYPE_MOBILE3>
		VIEWPOINT <16,16,-3328,1792,0,0>
		HELICOPTER <DRONE_HELICOPT,ALLIED,,CH47_CHINOOK,3*100,0,-1>

		WAYPOINT <"A",10000001b,16,16,-3328, 1792,   0,   0,HC_WP_TAKEOFF>
		WAYPOINT <"B",10001001b,23,25, 6000, 4000, 150,2000>
		WAYPOINT <"C",10010001b,23,25, -256, 3072, 100,   0,HC_WP_STOP>

		REPT	NUM_WP_SHORT-3
		WAYPOINT <>
		ENDM

		ENDROUTE <>

		EVEN

	ENDIF

;---------------------------
AHelicopter4	LABEL	BYTE		;heavy lift helicopters
;---------------------------

	IF	DRONE_HC_ON EQ 0

		DEF_HELICOPTER	NUM_WP_SHORT

	ELSE

		MOBILE <MOB_CHINOOK,OTYPE_MOBILE3>
		VIEWPOINT <16,16,3400,0,50,384>
		HELICOPTER <DRONE_HELICOPT,ALLIED,,CH47_CHINOOK,0,0,-1>

		WAYPOINT <"A",10000001b,16,16, 3400,    0,  50,1360,HC_WP_AIRBORNE>
		WAYPOINT <"B",10001001b,16,16, 2000,    0, 100,1360>
		WAYPOINT <"C",10010001b,16,16,-2816, 2048, 100,   0,HC_WP_STOP>

		REPT	NUM_WP_SHORT-3
		WAYPOINT <>
		ENDM

		ENDROUTE <>

		EVEN

	ENDIF

;----------------------------------
;* ///// enemy drone aircraft /////
;----------------------------------

;---------------------------
EAircraft1	LABEL	BYTE		;interdiction / strike aircraft
;---------------------------

	IF	DRONE_AC_ON EQ 0

		DEF_AIRCRAFT	NUM_WP_LONG

	ELSE

		MOBILE <MOB_MIG27_1,OTYPE_MOBILE3>
		VIEWPOINT <26,4,-2304,0,0,0>
		AIRCRAFT <DRONE_AIRCRAFT,ENEMY,,MIG27_FLOGGER,0*100,0,-1>

		WAYPOINT <"A",10000000b,26, 4,-2304,    0,   0,   0,AC_WP_TAKEOFF>
		WAYPOINT <"B",10001101b,24, 4,    0,    0,1000,6000>
		WAYPOINT <"C",10001001b,17, 0,    0,    0,1500,6000>
		WAYPOINT <"D",10001001b,16, 2,    0,    0,1000,6000>
 		WAYPOINT <"E",10001011b,21, 5,    0,    0, 500,6000>

		REPT	NUM_WP_LONG-5
		WAYPOINT <>
		ENDM

		ENDROUTE <>

		EVEN

	ENDIF

;---------------------------
EAircraft2 	LABEL	BYTE		;interdiction / strike aircraft
;---------------------------

	IF	DRONE_AC_ON EQ 0

		DEF_AIRCRAFT	NUM_WP_LONG

	ELSE

		MOBILE <MOB_MIG27_1,OTYPE_MOBILE3>
		VIEWPOINT <26,4,-2304,-128,0,0>
		AIRCRAFT <DRONE_AIRCRAFT,ENEMY,,MIG27_FLOGGER,1*100,0,-1>

		WAYPOINT <"A",10000000b,26, 4,-2304, -128,   0,   0,AC_WP_TAKEOFF>
		WAYPOINT <"B",10001101b,24, 4,    0,    0,1000,6000>
		WAYPOINT <"C",10001001b,17, 0,    0,    0,1500,6000>
		WAYPOINT <"D",10001001b,16, 2,    0,    0,1000,6000>
 		WAYPOINT <"E",10001011b,21, 5,    0,    0, 500,6000>

		REPT	NUM_WP_LONG-5
		WAYPOINT <>
		ENDM

		ENDROUTE <>

		EVEN

	ENDIF

;---------------------------
EAircraft3	LABEL	BYTE		;interdiction / strike aircraft
;---------------------------

	IF	DRONE_AC_ON EQ 0

		DEF_AIRCRAFT	NUM_WP_LONG

	ELSE

		MOBILE <MOB_MIG27_1,OTYPE_MOBILE3>
		VIEWPOINT <26,4,-2304,-256,0,0>
		AIRCRAFT <DRONE_AIRCRAFT,ENEMY,,MIG27_FLOGGER,2*100,0,-1>

		WAYPOINT <"A",10000000b,26, 4,-2304, -256,   0,   0,AC_WP_TAKEOFF>
		WAYPOINT <"B",10001101b,24, 4,    0,    0,1000,6000>
		WAYPOINT <"C",10001001b,17, 0,    0,    0,1500,6000>
		WAYPOINT <"D",10001001b,16, 2,    0,    0,1000,6000>
 		WAYPOINT <"E",10001011b,21, 5,    0,    0, 500,6000>

		REPT	NUM_WP_LONG-5
		WAYPOINT <>
		ENDM

		ENDROUTE <>

		EVEN

	ENDIF

;---------------------------
EAircraft4	LABEL	BYTE		;interdiction / strike aircraft
;---------------------------

	IF	DRONE_AC_ON EQ 0

		DEF_AIRCRAFT	NUM_WP_LONG

	ELSE

		MOBILE <MOB_MIG27_1,OTYPE_MOBILE3>
		VIEWPOINT <26,4,-2304,-384,0,0>
		AIRCRAFT <DRONE_AIRCRAFT,ENEMY,,MIG27_FLOGGER,3*100,0,-1>

		WAYPOINT <"A",10000000b,26, 4,-2304, -384,   0,   0,AC_WP_TAKEOFF>
		WAYPOINT <"B",10001101b,24, 4,    0,    0,1000,6000>
		WAYPOINT <"C",10001001b,17, 0,    0,    0,1500,6000>
		WAYPOINT <"D",10001001b,16, 2,    0,    0,1000,6000>
 		WAYPOINT <"E",10001011b,21, 5,    0,    0, 500,6000>

		REPT	NUM_WP_LONG-5
		WAYPOINT <>
		ENDM

		ENDROUTE <>

		EVEN

	ENDIF

;---------------------------
EAircraft5	LABEL	BYTE		;interdiction / strike aircraft
;---------------------------

	IF	DRONE_AC_ON EQ 0

		DEF_AIRCRAFT	NUM_WP_LONG

	ELSE

		MOBILE <MOB_MIG27_1,OTYPE_MOBILE3>
		VIEWPOINT <11,2,0,1792,0,384>
		AIRCRAFT <DRONE_AIRCRAFT,ENEMY,,MIG27_FLOGGER,0*100,0,-1>

		WAYPOINT <"A",10000000b,11, 2,  0, 1792,   0,   0,AC_WP_TAKEOFF>
		WAYPOINT <"B",10000101b,15, 0,  0,    0,5500,6000>
		WAYPOINT <"C",10000001b,24, 4,  0,    0,5000,6000>
		WAYPOINT <"D",10000001b,22, 7,  0,    0,5000,6000>
 		WAYPOINT <"E",10000011b,16, 6,  0,    0,5000,6000>

		REPT	NUM_WP_LONG-5
		WAYPOINT <>
		ENDM

		ENDROUTE <>

		EVEN

	ENDIF

;---------------------------
EAircraft6	LABEL	BYTE		;interdiction / strike aircraft
;---------------------------

	IF	DRONE_AC_ON EQ 0

		DEF_AIRCRAFT	NUM_WP_LONG

	ELSE

		MOBILE <MOB_MIG27_1,OTYPE_MOBILE3>
		VIEWPOINT <11,2,128,1792,0,384>
		AIRCRAFT <DRONE_AIRCRAFT,ENEMY,,MIG27_FLOGGER,1*100,0,-1>

		WAYPOINT <"A",10000000b,11, 2,128, 1792,   0,   0,AC_WP_TAKEOFF>
		WAYPOINT <"B",10000101b,15, 0,  0,    0,5500,6000>
		WAYPOINT <"C",10000001b,24, 4,  0,    0,5000,6000>
		WAYPOINT <"D",10000001b,22, 7,  0,    0,5000,6000>
 		WAYPOINT <"E",10000011b,16, 6,  0,    0,5000,6000>

		REPT	NUM_WP_LONG-5
		WAYPOINT <>
		ENDM

		ENDROUTE <>

		EVEN

	ENDIF

;---------------------------
EAircraft7	LABEL	BYTE		;air defence aircraft
;---------------------------

	IF	DRONE_AC_ON EQ 0

		DEF_AIRCRAFT	NUM_WP_LONG

	ELSE

		MOBILE <MOB_MIG31,OTYPE_MOBILE3>
		VIEWPOINT <11,2,256,1792,0,384>
		AIRCRAFT <DRONE_AIRCRAFT,ENEMY,,MIG31_FOXHOUND,2*100,0,-1>

		WAYPOINT <"A",10000000b,11, 2,  256, 1792,   0,   0,AC_WP_TAKEOFF>
		WAYPOINT <"B",10000101b,15, 0,    0,    0,5500,6000>
		WAYPOINT <"C",10000001b,24, 4,    0,    0,5000,6000>
		WAYPOINT <"D",10000001b,22, 7,    0,    0,5000,6000>
 		WAYPOINT <"E",10000011b,16, 6,    0,    0,5000,6000>
 		WAYPOINT <"F",11001001b,26,10,    0, 4096,1000,5000>
 		WAYPOINT <"G",10001001b,25,10,    0, 4096,1000,4000>
 		WAYPOINT <"H",10001000b,24,10,    0, 4096, 800,3000>
 		WAYPOINT <"I",10010001b,23,10, 3840, 4096,   0,   0,AC_WP_RESTART>

		REPT	NUM_WP_LONG-9
		WAYPOINT <>
		ENDM

		ENDROUTE <>

		EVEN

	ENDIF

;---------------------------
EAircraft8	LABEL	BYTE		;air defence aircraft
;---------------------------

	IF	DRONE_AC_ON EQ 0

		DEF_AIRCRAFT	NUM_WP_LONG

	ELSE

		MOBILE <MOB_MIG31,OTYPE_MOBILE3>
		VIEWPOINT <11,2,384,1792,0,384>
		AIRCRAFT <DRONE_AIRCRAFT,ENEMY,,MIG31_FOXHOUND,3*100,0,-1>

		WAYPOINT <"A",10000000b,11, 2,  384, 1792,   0,   0,AC_WP_TAKEOFF>
		WAYPOINT <"B",10000101b,15, 0,    0,    0,5500,6000>
		WAYPOINT <"C",10000001b,24, 4,    0,    0,5000,6000>
		WAYPOINT <"D",10000001b,22, 7,    0,    0,5000,6000>
 		WAYPOINT <"E",10000011b,16, 6,    0,    0,5000,6000>
 		WAYPOINT <"F",11001001b,26,10,    0, 4096,1000,5000>
 		WAYPOINT <"G",10001001b,25,10,    0, 4096,1000,4000>
 		WAYPOINT <"H",10001000b,24,10,    0, 4096, 800,3000>
 		WAYPOINT <"I",10010001b,23,10, 3840, 4096,   0,   0,AC_WP_RESTART>

		REPT	NUM_WP_LONG-9
		WAYPOINT <>
		ENDM

		ENDROUTE <>

		EVEN

	ENDIF

;---------------------------
EAircraft9	LABEL	BYTE		;interceptor / air superiority aircraft
;---------------------------

	IF	DRONE_AC_ON EQ 0

		DEF_AIRCRAFT	NUM_WP_SHORT

	ELSE

		MOBILE <MOB_SU27_1,OTYPE_MOBILE3>
		VIEWPOINT <23,10,0,4096,0,384>
		AIRCRAFT <DRONE_AIRCRAFT,ENEMY,,SU27_FLANKER,0*100,0,-1>

		WAYPOINT <"A",10000000b,23,10,    0, 4096,   0,   0,AC_WP_TAKEOFF>
		WAYPOINT <"B",10001101b,20, 6,    0,    0,1500,6000>
		WAYPOINT <"C",10001001b,15, 3,    0,    0,1000,6000>
		WAYPOINT <"D",10001001b,19, 1,    0,    0,1000,6000>
 		WAYPOINT <"E",10001011b,24, 6,    0,    0,1000,6000>
 		WAYPOINT <"F",11001001b,26,10,    0, 4096,1000,5000>
 		WAYPOINT <"G",10001001b,25,10,    0, 4096,1000,4000>
 		WAYPOINT <"H",10001000b,24,10,    0, 4096, 800,3000>
 		WAYPOINT <"I",10010001b,23,10, 3840, 4096,   0,   0,AC_WP_RESTART>

		REPT	NUM_WP_SHORT-9
		WAYPOINT <>
		ENDM

		ENDROUTE <>

		EVEN

	ENDIF

;---------------------------
EAircraft10	LABEL	BYTE		;interceptor / air superiority aircraft
;---------------------------

	IF	DRONE_AC_ON EQ 0

		DEF_AIRCRAFT	NUM_WP_SHORT

	ELSE

		MOBILE <MOB_SU27_1,OTYPE_MOBILE3>
		VIEWPOINT <23,10,128,4096,0,384>
		AIRCRAFT <DRONE_AIRCRAFT,ENEMY,,SU27_FLANKER,1*100,0,-1>

		WAYPOINT <"A",10000000b,23,10,  128, 4096,   0,   0,AC_WP_TAKEOFF>
		WAYPOINT <"B",10001101b,20, 6,    0,    0,1500,6000>
		WAYPOINT <"C",10001001b,15, 3,    0,    0,1000,6000>
		WAYPOINT <"D",10001001b,19, 1,    0,    0,1000,6000>
 		WAYPOINT <"E",10001011b,24, 6,    0,    0,1000,6000>
 		WAYPOINT <"F",11001001b,26,10,    0, 4096,1000,5000>
 		WAYPOINT <"G",10001001b,25,10,    0, 4096,1000,4000>
 		WAYPOINT <"H",10001000b,24,10,    0, 4096, 800,3000>
 		WAYPOINT <"I",10010001b,23,10, 3840, 4096,   0,   0,AC_WP_RESTART>

		REPT	NUM_WP_SHORT-9
		WAYPOINT <>
		ENDM

		ENDROUTE <>

		EVEN

	ENDIF

;---------------------------
EAircraft11	LABEL	BYTE		;interceptor / air superiority aircraft
;---------------------------

	IF	DRONE_AC_ON EQ 0

		DEF_AIRCRAFT	NUM_WP_SHORT

	ELSE

		MOBILE <MOB_MIG29,OTYPE_MOBILE3>
		VIEWPOINT <23,10,256,4096,0,384>
		AIRCRAFT <DRONE_AIRCRAFT,ENEMY,,MIG29_FULCRUM,2*100,0,-1>

		WAYPOINT <"A",10000000b,23,10,  256, 4096,   0,   0,AC_WP_TAKEOFF>
		WAYPOINT <"B",10001101b,20, 6,    0,    0,1500,6000>
		WAYPOINT <"C",10001001b,15, 3,    0,    0,1000,6000>
		WAYPOINT <"D",10001001b,19, 1,    0,    0,1000,6000>
 		WAYPOINT <"E",10001011b,24, 6,    0,    0,1000,6000>
 		WAYPOINT <"F",11001001b,26,10,    0, 4096,1000,5000>
 		WAYPOINT <"G",10001001b,25,10,    0, 4096,1000,4000>
 		WAYPOINT <"H",10001000b,24,10,    0, 4096, 800,3000>
 		WAYPOINT <"I",10010001b,23,10, 3840, 4096,   0,   0,AC_WP_RESTART>

		REPT	NUM_WP_SHORT-9
		WAYPOINT <>
		ENDM

		ENDROUTE <>

		EVEN

	ENDIF

;---------------------------
EAircraft12	LABEL	BYTE		;interceptor / air superiority aircraft
;---------------------------

	IF	DRONE_AC_ON EQ 0

		DEF_AIRCRAFT	NUM_WP_SHORT

	ELSE

		MOBILE <MOB_MIG29,OTYPE_MOBILE3>
		VIEWPOINT <23,10,384,4096,0,384>
		AIRCRAFT <DRONE_AIRCRAFT,ENEMY,,MIG29_FULCRUM,3*100,0,-1>

		WAYPOINT <"A",10000000b,23,10,  384, 4096,   0,   0,AC_WP_TAKEOFF>
		WAYPOINT <"B",10001101b,20, 6,    0,    0,1500,6000>
		WAYPOINT <"C",10001001b,15, 3,    0,    0,1000,6000>
		WAYPOINT <"D",10001001b,19, 1,    0,    0,1000,6000>
 		WAYPOINT <"E",10001011b,24, 6,    0,    0,1000,6000>
 		WAYPOINT <"F",11001001b,26,10,    0, 4096,1000,5000>
 		WAYPOINT <"G",10001001b,25,10,    0, 4096,1000,4000>
 		WAYPOINT <"H",10001000b,24,10,    0, 4096, 800,3000>
 		WAYPOINT <"I",10010001b,23,10, 3840, 4096,   0,   0,AC_WP_RESTART>

		REPT	NUM_WP_SHORT-9
		WAYPOINT <>
		ENDM

		ENDROUTE <>

		EVEN

	ENDIF

;---------------------------
EAircraft13	LABEL	BYTE		;close air support / attack aircraft
;---------------------------

	IF	DRONE_AC_ON EQ 0

		DEF_AIRCRAFT	NUM_WP_SHORT

	ELSE

		MOBILE <MOB_SU25,OTYPE_MOBILE3>
		VIEWPOINT <22,9,0,0,500,256>
		AIRCRAFT <DRONE_AIRCRAFT,ENEMY,,SU25_FROGFOOT,0*100,0,-1>

		WAYPOINT <"A",10001100b,22, 9,0,0,500,4760,AC_WP_AIRBORNE>
		WAYPOINT <"B",10001000b,22,11,0,0,500,4760>
		WAYPOINT <"C",10001000b,24,11,0,0,500,4760>
		WAYPOINT <"D",10001010b,24, 9,0,0,500,4760>

		REPT	NUM_WP_SHORT-4
		WAYPOINT <>
		ENDM

		ENDROUTE <>

		EVEN

	ENDIF

;---------------------------
EAircraft14	LABEL	BYTE		;close air support / attack aircraft
;---------------------------

	IF	DRONE_AC_ON EQ 0

		DEF_AIRCRAFT	NUM_WP_SHORT

	ELSE

		MOBILE <MOB_SU25,OTYPE_MOBILE3>
		VIEWPOINT <24,11,0,0,500,0>
		AIRCRAFT <DRONE_AIRCRAFT,ENEMY,,SU25_FROGFOOT,0*100,0,-1>

		WAYPOINT <"A",10001100b,24,11,0,0,500,4760,AC_WP_AIRBORNE>
		WAYPOINT <"B",10001000b,24, 9,0,0,500,4760>
		WAYPOINT <"C",10001000b,22, 9,0,0,500,4760>
		WAYPOINT <"D",10001010b,22,11,0,0,500,4760>

		REPT	NUM_WP_SHORT-4
		WAYPOINT <>
		ENDM

		ENDROUTE <>

		EVEN

	ENDIF

;---------------------------
EAircraft15	LABEL	BYTE		;heavy lift transport aircraft
;---------------------------

	IF	DRONE_AC_ON EQ 0

		DEF_AIRCRAFT	NUM_WP_SHORT

	ELSE

		MOBILE <MOB_IL76,OTYPE_MOBILE3>
		VIEWPOINT <0,4,0,0,10000,256>
		AIRCRAFT <DRONE_AIRCRAFT,ENEMY,,IL76_CANDID,0*100,0,-1>

		WAYPOINT <"A",10000100b, 0, 4,0,0,10000,4760,AC_WP_AIRBORNE>
		WAYPOINT <"B",10000000b, 0,12,0,0,10000,4760>
		WAYPOINT <"C",10000000b,31,12,0,0,10000,4760>
		WAYPOINT <"D",10000010b,31, 4,0,0,10000,4760>

		REPT	NUM_WP_SHORT-4
		WAYPOINT <>
		ENDM

		ENDROUTE <>

		EVEN

	ENDIF

;---------------------------
EAircraft16	LABEL	BYTE		;heavy lift transport aircraft
;---------------------------

	IF	DRONE_AC_ON EQ 0

		DEF_AIRCRAFT	NUM_WP_SHORT

	ELSE

		MOBILE <MOB_IL76,OTYPE_MOBILE3>
		VIEWPOINT <31,12,0,0,10000,0>
		AIRCRAFT <DRONE_AIRCRAFT,ENEMY,,IL76_CANDID,0*100,0,-1>

		WAYPOINT <"A",10000100b,31,12,0,0,10000,4760,AC_WP_AIRBORNE>
		WAYPOINT <"B",10000000b,31, 4,0,0,10000,4760>
		WAYPOINT <"C",10000000b, 0, 4,0,0,10000,4760>
		WAYPOINT <"D",10000010b, 0,12,0,0,10000,4760>

		REPT	NUM_WP_SHORT-4
		WAYPOINT <>
		ENDM

		ENDROUTE <>

		EVEN

	ENDIF

;---------------------------
EAircraft17	LABEL	BYTE		;airborne early warning aircraft
;---------------------------

	IF	DRONE_AC_ON EQ 0

		DEF_AIRCRAFT	NUM_WP_SHORT

	ELSE

		MOBILE <MOB_IL76,OTYPE_MOBILE3>
		VIEWPOINT <8,17,0,0,11000,256>
		AIRCRAFT <DRONE_AIRCRAFT,ENEMY,,IL76_MAINSTAY,0*100,0,-1>

		WAYPOINT <"A",10000100b, 8,17,0,0,11000,4760,AC_WP_AIRBORNE>
		WAYPOINT <"B",10000000b, 8,31,0,0,11000,4760>
		WAYPOINT <"C",10000000b,24,31,0,0,11000,4760>
		WAYPOINT <"D",10000010b,24,17,0,0,11000,4760>

		REPT	NUM_WP_SHORT-4
		WAYPOINT <>
		ENDM

		ENDROUTE <>

		EVEN

	ENDIF

;---------------------------
EHelicopter1	LABEL	BYTE		;gunship helicopter
;---------------------------

	IF	DRONE_HC_ON EQ 0

		DEF_HELICOPTER	NUM_WP_SHORT

	ELSE

		MOBILE <MOB_HIND1,OTYPE_MOBILE3>
		VIEWPOINT <23,10,200,700,75,64>
		HELICOPTER <DRONE_HELICOPT,ENEMY,,MI24_HIND,0,0,-1>

		WAYPOINT <"A",10001101b,23,10,  200,  700,  75,1360,HC_WP_AIRBORNE>
		WAYPOINT <"B",10001001b,23,10, 4000, 4000,  75,1360>
		WAYPOINT <"C",10001011b,23,10,-2400, 2800,  75,1360>

		REPT	NUM_WP_SHORT-3
		WAYPOINT <>
		ENDM

		ENDROUTE <>

		EVEN

	ENDIF

;---------------------------
EHelicopter2	LABEL	BYTE		;gunship helicopter
;---------------------------

	IF	DRONE_HC_ON EQ 0

		DEF_HELICOPTER	NUM_WP_SHORT

	ELSE

		MOBILE <MOB_HIND1,OTYPE_MOBILE3>
		VIEWPOINT <23,10,200,700,175,448>
		HELICOPTER <DRONE_HELICOPT,ENEMY,,MI24_HIND,0,0,-1>

		WAYPOINT <"A",10001101b,23,10,  200,  700, 175,1360,HC_WP_AIRBORNE>
		WAYPOINT <"B",10001001b,23,10,-2400, 2800, 175,1360>
		WAYPOINT <"C",10001011b,23,10, 4000, 4000, 175,1360>

		REPT	NUM_WP_SHORT-3
		WAYPOINT <>
		ENDM

		ENDROUTE <>

		EVEN

	ENDIF

;---------------------------
EHelicopter3	LABEL	BYTE		;heavy lift helicopter
;---------------------------

	IF	DRONE_HC_ON EQ 0

		DEF_HELICOPTER	NUM_WP_SHORT

	ELSE

		MOBILE <MOB_MI26,OTYPE_MOBILE3>
		VIEWPOINT <13,4,600,-3600,200,448>
		HELICOPTER <DRONE_HELICOPT,ENEMY,,MI26_HALO,0,0,-1>

		WAYPOINT <"A",10000001b,13, 4,  600,-3600, 200,1360,HC_WP_AIRBORNE>
		WAYPOINT <"B",10101001b,11, 2,    0,-2000, 150,256>
		WAYPOINT <"C",10010001b,11, 2,    0,  800, 100,   0,HC_WP_STOP>

		REPT	NUM_WP_SHORT-3
		WAYPOINT <>
		ENDM

		ENDROUTE <>

		EVEN

	ENDIF

;---------------------------
EHelicopter4	LABEL	BYTE		;heavy lift helicopter
;---------------------------

	IF	DRONE_HC_ON EQ 0

		DEF_HELICOPTER	NUM_WP_SHORT

	ELSE

		MOBILE <MOB_MI26,OTYPE_MOBILE3>
		VIEWPOINT <8,3,3100,2600,0,320>
		HELICOPTER <DRONE_HELICOPT,ENEMY,,MI26_HALO,0,0,-1>

		WAYPOINT <"A",10000001b,8, 3, 3100, 2600,   0,   0,HC_WP_TAKEOFF>
		WAYPOINT <"B",10001001b,5, 4, 4000, 1150, 150, 1360>
		WAYPOINT <"C",10010001b,5, 4, 1750, 1150,   0,   0,HC_WP_STOP>

		REPT	NUM_WP_SHORT-3
		WAYPOINT <>
		ENDM

		ENDROUTE <>

		EVEN

	ENDIF

;-----------------------------------
;* truck / train vehicles and routes (see VEHICLES.ASM)
;-----------------------------------

;-----------------------
;* allied truck convoy 1
;-----------------------

ATruckConvoy1	CONVOY <1,0>

ATruck1_1	MOBILE <MOB_RDTNKR1,OTYPE_MOBILE2>
		VIEWPOINT <12,12,3000+(64*3),64,0,128>
		VEHICLE <DRONE_TRUCK,ALLIED,,,500-(64*3)>

ATruck1_2	MOBILE <MOB_RDTNKR1,OTYPE_MOBILE2>
		VIEWPOINT <12,12,3000+(64*2),64,0,128>
		VEHICLE <DRONE_TRUCK,ALLIED,,,500-(64*2)>

ATruck1_3	MOBILE <MOB_RDTNKR1,OTYPE_MOBILE2>
		VIEWPOINT <12,12,3000+(64*1),64,0,128>
		VEHICLE <DRONE_TRUCK,ALLIED,,,500-(64*1)>

ATruck1_4     	MOBILE <MOB_RDTNKR1,OTYPE_MOBILE2>
		VIEWPOINT <12,12,3000+(64*0),64,0,128>
		VEHICLE <DRONE_TRUCK,ALLIED,,,500-(64*0)>

		EVEN

;-----------------------
;* allied truck convoy 2
;-----------------------

ATruckConvoy2	CONVOY <>

ATruck2_1	MOBILE <>
		VIEWPOINT <>
		VEHICLE <>

ATruck2_2	MOBILE <>
		VIEWPOINT <>
		VEHICLE <>

ATruck2_3	MOBILE <>
		VIEWPOINT <>
		VEHICLE <>

ATruck2_4	MOBILE <>
		VIEWPOINT <>
		VEHICLE <>

		EVEN

;----------------------
;* enemy truck convoy 1
;----------------------

ETruckConvoy1	CONVOY <>

ETruck1_1	MOBILE <>
		VIEWPOINT <>
		VEHICLE <>

ETruck1_2	MOBILE <>
		VIEWPOINT <>
		VEHICLE <>

ETruck1_3 	MOBILE <>
		VIEWPOINT <>
		VEHICLE <>

ETruck1_4 	MOBILE <>
		VIEWPOINT <>
		VEHICLE <>

		EVEN

;----------------------
;* enemy truck convoy 2
;----------------------

ETruckConvoy2	CONVOY <>

ETruck2_1	MOBILE <>
		VIEWPOINT <>
		VEHICLE <>

ETruck2_2	MOBILE <>
		VIEWPOINT <>
		VEHICLE <>

ETruck2_3	MOBILE <>
		VIEWPOINT <>
		VEHICLE <>

ETruck2_4	MOBILE <>
		VIEWPOINT <>
		VEHICLE <>

		EVEN

;----------------
;* allied train 1
;----------------

ATrain1		CONVOY <1,10*100>

;* ATrain1_1 assumed to be locomotive

ATrain1_1	MOBILE <MOB_LOCO1,OTYPE_MOBILE2>
		VIEWPOINT <12,12,4096-(64*7),0,0,384>
		VEHICLE <DRONE_TRAIN,ALLIED,,,4096-(64*7)>

ATrain1_2	MOBILE <MOB_RLTTRANS,OTYPE_MOBILE2>
		VIEWPOINT <12,12,4096-(64*6),0,0,384>
		VEHICLE <DRONE_TRAIN,ALLIED,,,4096-(64*6)>

ATrain1_3	MOBILE <MOB_RLTTRANS,OTYPE_MOBILE2>
		VIEWPOINT <12,12,4096-(64*5),0,0,384>
		VEHICLE <DRONE_TRAIN,ALLIED,,,4096-(64*5)>

ATrain1_4 	MOBILE <MOB_RLWAGONA,OTYPE_MOBILE2>
		VIEWPOINT <12,12,4096-(64*4),0,0,384>
		VEHICLE <DRONE_TRAIN,ALLIED,,,4096-(64*4)>

ATrain1_5	MOBILE <MOB_RLTANK1,OTYPE_MOBILE2>
		VIEWPOINT <12,12,4096-(64*3),0,0,384>
		VEHICLE <DRONE_TRAIN,ALLIED,,,4096-(64*3)>

ATrain1_6 	MOBILE <MOB_RLTANK1,OTYPE_MOBILE2>
		VIEWPOINT <12,12,4096-(64*2),0,0,384>
		VEHICLE <DRONE_TRAIN,ALLIED,,,4096-(64*2)>

ATrain1_7 	MOBILE <MOB_RLWAGONA,OTYPE_MOBILE2>
		VIEWPOINT <12,12,4096-(64*1),0,0,384>
		VEHICLE <DRONE_TRAIN,ALLIED,,,4096-(64*1)>

ATrain1_8 	MOBILE <MOB_RLTTRANS,OTYPE_MOBILE2>
		VIEWPOINT <12,12,4096-(64*0),0,0,384>
		VEHICLE <DRONE_TRAIN,ALLIED,,,4096-(64*0)>

		EVEN

;----------------
;* allied train 2
;----------------

ATrain2		CONVOY <>

;* ATrain2_1 assumed to be locomotive

ATrain2_1	MOBILE <>
		VIEWPOINT <>
		VEHICLE <>

ATrain2_2	MOBILE <>
		VIEWPOINT <>
		VEHICLE <>

ATrain2_3	MOBILE <>
		VIEWPOINT <>
		VEHICLE <>

ATrain2_4	MOBILE <>
		VIEWPOINT <>
		VEHICLE <>

ATrain2_5	MOBILE <>
		VIEWPOINT <>
		VEHICLE <>

ATrain2_6	MOBILE <>
		VIEWPOINT <>
		VEHICLE <>

ATrain2_7	MOBILE <>
		VIEWPOINT <>
		VEHICLE <>

ATrain2_8	MOBILE <>
		VIEWPOINT <>
		VEHICLE <>

		EVEN

;---------------
;* enemy train 1
;---------------

ETrain1		CONVOY <>

;* ETrain1_1 assumed to be locomotive

ETrain1_1 	MOBILE <>
		VIEWPOINT <>
		VEHICLE <>

ETrain1_2 	MOBILE <>
		VIEWPOINT <>
		VEHICLE <>

ETrain1_3	MOBILE <>
		VIEWPOINT <>
		VEHICLE <>

ETrain1_4	MOBILE <>
		VIEWPOINT <>
		VEHICLE <>

ETrain1_5	MOBILE <>
		VIEWPOINT <>
		VEHICLE <>

ETrain1_6 	MOBILE <>
		VIEWPOINT <>
		VEHICLE <>

ETrain1_7	MOBILE <>
		VIEWPOINT <>
		VEHICLE <>

ETrain1_8	MOBILE <>
		VIEWPOINT <>
		VEHICLE <>

		EVEN

;---------------
;* enemy train 2
;---------------

ETrain2		CONVOY <>

;* ETrain2_1 assumed to be locomotive

ETrain2_1	MOBILE <>
		VIEWPOINT <>
		VEHICLE <>

ETrain2_2	MOBILE <>
		VIEWPOINT <>
		VEHICLE <>

ETrain2_3	MOBILE <>
		VIEWPOINT <>
		VEHICLE <>

ETrain2_4	MOBILE <>
		VIEWPOINT <>
		VEHICLE <>

ETrain2_5	MOBILE <>
		VIEWPOINT <>
		VEHICLE <>

ETrain2_6	MOBILE <>
		VIEWPOINT <>
		VEHICLE <>

ETrain2_7	MOBILE <>
		VIEWPOINT <>
		VEHICLE <>

ETrain2_8	MOBILE <>
		VIEWPOINT <>
		VEHICLE <>

		EVEN

;----------------------
;* allied truck route 1
;----------------------

ATruck1Route	LABEL	WORD

		ROUTE_NODE <12,12, 3000,64,  500,128,00000000b, 64,0,-1>	;1
		ROUTE_NODE <12,12, 3500,64,65535,128,00000001b,  0,0,-1>	;2

		REPT	NUM_ROUTE_NODES-2
		ROUTE_NODE <>
		ENDM

		EVEN

;----------------------
;* allied truck route 2
;----------------------

ATruck2Route	LABEL	WORD

		REPT	NUM_ROUTE_NODES
		ROUTE_NODE <>
		ENDM

		EVEN

;---------------------
;* enemy truck route 1
;---------------------

ETruck1Route	LABEL	WORD

		REPT	NUM_ROUTE_NODES
		ROUTE_NODE <>
		ENDM

		EVEN

;---------------------
;* enemy truck route 2
;---------------------

ETruck2Route	LABEL	WORD

		REPT	NUM_ROUTE_NODES
		ROUTE_NODE <>
		ENDM

		EVEN

;----------------------
;* allied train route 1
;----------------------

ATrain1Route	LABEL	WORD

		ROUTE_NODE <12,12, 4096,0, 4096,384,00000100b,127,0, 1>	;1
		ROUTE_NODE <12,12,    0,0,23170,320,00000000b,127,0,-1>	;2
		ROUTE_NODE <11,13,    0,0,15232,384,00000000b,127,0,-1>	;3
		ROUTE_NODE <10,13, 1152,0, 1280,384,00010000b,127,0,-1>	;4
		ROUTE_NODE <10,13, -128,0,16256,384,00100000b,127,0,-1>	;5
		ROUTE_NODE < 9,13,    0,0,23170,192,00000000b,127,0,-1>	;6
		ROUTE_NODE <10,14,    0,0,46341, 64,00000000b,127,0,-1>	;7
		ROUTE_NODE <12,12,    0,0,27520,128,00000000b,127,0,-1>	;8
		ROUTE_NODE <14,12,-5248,0, 9472,128,00010000b,127,0,-1>	;9
		ROUTE_NODE <14,12, 4224,0,12160,128,00100000b,127,0,-1>	;10
		ROUTE_NODE <15,12,    0,0,23170, 64,00000000b,127,0,-1>	;11
		ROUTE_NODE <16,11,    0,0,32768,  0,00000000b,127,0,-1>	;12
		ROUTE_NODE <16, 9,    0,0,49152,  0,00000000b,127,0,-1>	;13
		ROUTE_NODE <16, 6,    0,0,23170,192,00000000b,127,0,-1>	;14
		ROUTE_NODE <17, 7,    0,0,32768,128,00000000b,127,0,-1>	;15
		ROUTE_NODE <19, 7,    0,0,23170,192,00000000b,127,0,-1>	;16
		ROUTE_NODE <20, 8,    0,0,16384,256,00000000b,127,0,-1>	;17
		ROUTE_NODE <20, 9,    0,0,23170,320,00000000b,127,0,-1>	;18
		ROUTE_NODE <19,10,    0,0,16384,384,00000000b,127,0,-1>	;19
		ROUTE_NODE <18,10,    0,0,23170,320,00000000b,127,0,-1>	;20
		ROUTE_NODE <17,11,    0,0,16384,384,00000000b,127,0,-1>	;21
		ROUTE_NODE <16,11,    0,0,23170,320,00000000b,127,0,-1>	;22
		ROUTE_NODE <15,12,    0,0,11136,384,00000000b,127,0,-1>	;23
		ROUTE_NODE <14,12, 5248,0, 9472,384,00010000b,127,0,-1>	;24
		ROUTE_NODE <14,12,-4224,0,24448,384,00100010b,127,0,-1>	;25

		REPT	NUM_ROUTE_NODES-25
		ROUTE_NODE <>
		ENDM

		EVEN

;----------------------
;* allied train route 2
;----------------------

ATrain2Route	LABEL	WORD

		REPT	NUM_ROUTE_NODES
		ROUTE_NODE <>
		ENDM

		EVEN

;---------------------
;* enemy train route 1
;---------------------

ETrain1Route	LABEL	WORD

		REPT	NUM_ROUTE_NODES
		ROUTE_NODE <>
		ENDM

		EVEN

;---------------------
;* enemy train route 2
;---------------------

ETrain2Route	LABEL	WORD

		REPT	NUM_ROUTE_NODES
		ROUTE_NODE <>
		ENDM

		EVEN

;---------------------
;* duplicate variables
;---------------------

;* model (refer to MODEL.ASM)

_M_VIEW		VIEWPOINT <>

_FuelWt		DW	0

;* explore mode (refer to EXPLORE.ASM)

_EXP_VIEW	VIEWPOINT <>

_ExpMapZoom	DW	0

;* visual parameters

_SecScanCnt1	DW	0
_SecScanOff1	DW	0
_SecScanCnt2	DW	0
_SecScanOff2	DW	0
_CloudBase	DD	0
_CloudDepth	DW	0

_GndTextEnabled	DB	0
_TreesEnabled	DB	0
_HillTxtEnabled	DB	0
_CloudsEnabled	DB	0
_StarsEnabled	DB	0
_GradEnabled	DB	0
_Overcast	DB	0
_Fog		DB	0
_Night		DB	0
_PanelLight	DB	0

		EVEN

;* CH FlightStick Pro flag

_CHStick	DB	0

;* ThrustMaster FCS flag

_ThrustMaster	DB	0

		EVEN

;* ThrustMaster calibration values

_TM_MinX	DW	0
_TM_MinY	DW	0
_TM_MidX	DW	0
_TM_MidY	DW	0
_TM_MaxX	DW	0
_TM_MaxY	DW	0
_TM_CoolieCn	DW	0
_TM_CoolieLt	DW	0
_TM_CoolieDn	DW	0
_TM_CoolieRt	DW	0
_TM_CoolieUp	DW	0

;---------------
;* runway damage
;---------------

RunwayDamage	RUNWAY_DAMAGE NUM_RUNWAYS DUP(<>)

;---------------------------
GamePlayEnd	LABEL	BYTE
;---------------------------

DATA		ENDS

;============================================================================

		END

