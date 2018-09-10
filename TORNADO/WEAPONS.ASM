;Very useful regex	
;(?i)(?:\b(WPN_VIEW)\b)[^\w\r\n]+(?:\w+[^\w\r\n]+){0,5}?\b(VIEWPOINT)\b.*
;****************************************************************************
;*
;* WEAPONS.ASM
;*
;* Weapons control.
;*
;* 23.10.1992 - KJB
;*
;* Weapon vs Delivery
;* 컴컴컴컴컴컴컴컴컴
;*
;* GPB1000 .... MANUAL / LAYDOWN / LOFT
;* RET1000 ....	MANUAL / LAYDOWN
;* LGB1000 ....	MANUAL / LAYDOWN / LOFT / LGB
;* BL755 ......	MANUAL / LAYDOWN
;* JP233 ......	JP233
;* ALARM ......	DIRECT / INDIRECT ATTACK MODES
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	InitWeapons
		PUBLIC	CalcStoresWt
		PUBLIC	UpdateWeapons
		PUBLIC	WeaponsControl
		PUBLIC	AerialExplosion

		PUBLIC	CalcThrow
		PUBLIC	ReleasePackage
		PUBLIC	LaunchAlarm
		PUBLIC	FireCannon
		PUBLIC	LaunchMissile
		PUBLIC	ReleaseDecoy
		PUBLIC	CheckIRLock

		PUBLIC	DrawWeapons

		PUBLIC	WPN_Mobile
		PUBLIC	WPN_View
		PUBLIC	WPN_Weapon
		PUBLIC	TGT_VIEW
		PUBLIC	CCIP_VIEW

		PUBLIC	BombThrow
		PUBLIC	AirTgtRange
		PUBLIC	GndTgtRange

		PUBLIC	PackagePtr
		PUBLIC	ExtWeights
		PUBLIC	Cannons
		PUBLIC	ChaffCntr
		PUBLIC	FlareCntr
		PUBLIC	SafetyHeights
		PUBLIC	JP233Timer
		PUBLIC	LoftClock
		PUBLIC	LoftRatio
		PUBLIC	AirTgtPtr
		PUBLIC	MissileTgtPtr
		PUBLIC	AirArmMode

		PUBLIC	RWRTgtValid
		PUBLIC	LateArmAnim
		PUBLIC	ArmLock
		PUBLIC	ECMFitted
		PUBLIC	ECMActive
		PUBLIC	CannonFired
		PUBLIC	IRLockFlag
		PUBLIC	TornadoWpnDie
		PUBLIC	RelChaff
		PUBLIC	RelFlare

		PUBLIC	WeaponList
		PUBLIC	ImpactList

		PUBLIC	MUZZLE_VELOCITY
		PUBLIC	SAM_MIN_SPEED
		PUBLIC	SAM_MAX_SPEED
		PUBLIC	JP233_BOMBLETS
		PUBLIC	JP233_PERIOD
EXTRN	FuelWt:WORD		
EXTRN	GameViewMode:WORD		
EXTRN	MusicCard:WORD		
EXTRN	CrewMode:WORD		
EXTRN InstallMusic:FAR
EXTRN	MorseDashSound:FAR
EXTRN   CockpitViews:BYTE
		EXTRN	MakeCrater:FAR
		EXTRN	MakeSmokeEffect:FAR
		EXTRN	ExploSound1:FAR
		EXTRN	ExploSound2:FAR
		EXTRN	ExploSound3:FAR
		EXTRN	CannonSound:FAR
		EXTRN	LaunchSound:FAR
		EXTRN	DecoySound:FAR
		EXTRN	SurfaceCheck:FAR
		EXTRN	CalcGndHeight:FAR
		EXTRN	Sqrt32:FAR
		EXTRN	MoveViewpoint:FAR
		EXTRN	RandX:FAR
		EXTRN	FastArcTan:FAR
		EXTRN	CalcRngBrgVP_WP:FAR
		EXTRN	CalcRngBrgVP_VP:FAR
		EXTRN	CalcAngDiff:FAR
		EXTRN	CalcETA:FAR
		EXTRN	CalcSlantRange:FAR
		EXTRN	CalcIntercept:FAR
		EXTRN	CalcTransMatrix:FAR
		EXTRN	Calc3DOffset:FAR
		EXTRN	GetDroneSpeed:FAR
		EXTRN	GetDroneChaff:FAR
		EXTRN	GetDroneFlare:FAR
		EXTRN	GetDroneAlive:FAR
		EXTRN	WpnKillDrone:FAR
		EXTRN	SetDroneWpnLock:FAR
		EXTRN	DestroyTornado:FAR
		EXTRN	LocateMobiles:FAR
		EXTRN	MaxDamage:FAR

		EXTRN	DrawMobile:NEAR

		EXTRN	WPRng:DWORD
		EXTRN	CloudBase:DWORD
		EXTRN	CloudTop:DWORD

		EXTRN	SinTable:WORD
		EXTRN	CosTable:WORD
		EXTRN	DeltaTime:WORD
		EXTRN	ExtStores:WORD
		EXTRN	TornadoType:WORD
		EXTRN	StoresWt:WORD
		EXTRN	Vtas:WORD
		EXTRN	WPPtr:WORD
		EXTRN	ArmMode:WORD
		EXTRN	M_CosP:WORD
		EXTRN	M_CosR:WORD
		EXTRN	WayTotal:WORD
		EXTRN	WPBrg:WORD
		EXTRN	ViewWeaponPtr:WORD
		EXTRN	LastFrame:WORD
		EXTRN	ShakeTimer:WORD
		EXTRN	RadarMode:WORD
		EXTRN	SectorTable:WORD
		EXTRN	CloudDepth:WORD
		EXTRN	NumRWRThreats:WORD
		EXTRN	RWRThreats:WORD
		EXTRN	RadarLists:WORD
		EXTRN	EWRTable:WORD
 		EXTRN	WpnCamBrg:WORD
		EXTRN	WpnCamBrgFine:WORD
		EXTRN	MobSectorTable:WORD
		EXTRN	TreeLayouts:WORD

		EXTRN	Airborne1:BYTE
		EXTRN	InfiniteWeapons:BYTE
		EXTRN	JoyA_Fire1:BYTE
		EXTRN	JoyA_JustFired1:BYTE
		EXTRN	JoyA_JustFired2:BYTE
		EXTRN	LaserActive:BYTE
		EXTRN	Overcast:BYTE
		EXTRN	InCockpit:BYTE
		EXTRN	ShakePriority:BYTE
		EXTRN	HShake:BYTE
		EXTRN	VShake:BYTE
		EXTRN	SectorLayer1:BYTE
		EXTRN	MobileLayer1:BYTE
		EXTRN	CrntWingPos:BYTE
		EXTRN	Overcast:BYTE
		EXTRN	Fog:BYTE
		EXTRN	NoCollisions:BYTE
		EXTRN	SSF_RWR:BYTE
		EXTRN	SctrGameLayer1:BYTE
		EXTRN	MobRadarLayer1:BYTE
		EXTRN	SectorDataStart:BYTE
		EXTRN	MSctrDataStart:BYTE
		EXTRN	GndDamageFlags:BYTE
		EXTRN	MobDamageFlags:BYTE
		EXTRN	AGndKills:BYTE
		EXTRN	EGndKills:BYTE
		EXTRN	AMobKills:BYTE
		EXTRN	EMobKills:BYTE
		EXTRN	TreeLayer1:BYTE
		EXTRN	TreeLayer2:BYTE
		EXTRN	TreeLayer3:BYTE
		EXTRN	TreeLayer4:BYTE
		EXTRN	TreesEnabled:BYTE
		EXTRN	TwoPlayer:BYTE

		EXTRN	ZFT_COCKPIT:ABS
		EXTRN	HSHAKE_OFF:ABS
		EXTRN	HSHAKE_LO:ABS
		EXTRN	HSHAKE_HI:ABS
		EXTRN	VSHAKE_OFF:ABS
		EXTRN	VSHAKE_LO:ABS
		EXTRN	VSHAKE_HI:ABS
		EXTRN	SWEEP_D_25:ABS
		EXTRN	SWEEP_D_45:ABS
		EXTRN	SWEEP_D_67:ABS

;============================================================================

		INCLUDE	MAINDATA.INC
		INCLUDE	MISCMAC.INC
		INCLUDE	CONFIG.INC

		INCLUDE	\VISUAL\VISDATA.INC
		INCLUDE	\VISUAL\VISMACRO.INC
		INCLUDE	\VISUAL\GNDLIST.INC
		INCLUDE	\VISUAL\MOBLIST.INC

		INCLUDE	\LIB8086\KEYS.INC
		INCLUDE	\LIB8086\TRIG.INC
		INCLUDE	\LIB8086\USEFUL.INC

;============================================================================

		EXTRN	M_MOBILE:MOBILE

		EXTRN	M_VIEW:VIEWPOINT
		EXTRN	V_VIEW:VIEWPOINT
		EXTRN	TMP_VIEW:VIEWPOINT
	
		EXTRN	FloatWP:WAYPOINT

		EXTRN	Packages:PACKAGE

		EXTRN	RadarTable:RADARS

		EXTRN	KF_Package:GAMEKEY
		EXTRN	KF_WpnMode:GAMEKEY
		EXTRN	KF_WpnFire:GAMEKEY
		EXTRN	KF_WpnCommit:GAMEKEY
		EXTRN	KF_ArmGnd:GAMEKEY
		EXTRN	KF_ArmAir:GAMEKEY
		EXTRN	KF_ArmOff:GAMEKEY
		EXTRN	KF_AirWeapon:GAMEKEY
		EXTRN	KF_Chaff:GAMEKEY
		EXTRN	KF_Flare:GAMEKEY

		EXTRN	Tx:COMMS

		EXTRN	RunwayDamage:RUNWAY_DAMAGE

;============================================================================


DATA		SEGMENT PARA PUBLIC 'DATA'


;------------------------
;* air-to-gnd weapon vars (Tornado only)
;------------------------

PackagePtr	DW	-1		;-1 = no packages

LoftClock	DW	-1		;loft bomb clock value
					;(-1 = invalid, flying away from target)

LoftRatio	DW	-1		;loft bomb throw / range ratio
					;(-1 invalid, approaching pull up point)

RWRTgtValid	DB	0		;1 = RWR target valid

		EVEN

;------------------------
;* air-to-air weapon vars (Tornado only)
;------------------------

AirTgtPtr	DW	-1		;-1 = no target

MissileTgtPtr	DW	-1		;-1 = no target

AirArmMode	DW	ARM_CANNON	;cannons always available at start
					;(ARM_OFF = no air weapons)

AirTgtRange	DD	0		;air target slant range (if valid target)

GndTgtRange	DD	0		;gnd target slant range (if valid target)

LaunchSide	DW	0		;Sidewinder launch side (0 = rhs, -1 = lhs)

IRLockFlag	DB	0		;1 = IR lock, 0 = no lock

		EVEN

;-------------
;* impact data (Tornado only)
;-------------

ImpactPtr	DW	OFFSET ImpactList

;---------------
;* miscellaneous (Tornado only)
;---------------

LateArmAnim	DB	0		;0 (off) .. 3 (on)

ArmLock		DB	0		;1 = release in progress

		EVEN

;-----------
;* temp vars
;-----------

BombThrow	DD	0		;bomb throw (ft)

WeaponPtr	DW	-1		

TargetPtr	DW	-1

WeaponNum   	DW	0

WeaponVel	DW	0

ImpactSurface	DW	0		;surface type at weapon impact point

TmpRange	DD	0

RadarRange	DD	0

RadarFlag	DB	0		;1 = radar found

		EVEN

;---------------------------------------
;* working copy of current missiles data
;---------------------------------------

WPN_Workspace	LABEL	BYTE

WPN_Mobile	MOBILE <>
WPN_View	VIEWPOINT <>
WPN_Weapon	WEAPON <16,16,0,0,5000,0,0,0>

;------------------------------------------
;* look up external stores index wrt weapon (-1 = not external)
;------------------------------------------

ExtStoresIndex	DW	EXT_GPB1000	;GPB1000
		DW	EXT_RET1000    	;RET1000
		DW	EXT_LGB1000    	;LGB1000
		DW	EXT_BL755      	;BL755
		DW	EXT_JP233      	;JP233
		DW	EXT_ALARM      	;ALARM
		DW	-1	       	;CANNON
		DW	EXT_SIDEWINDER 	;SIDEWINDER
		DW	EXT_SKYFLASH   	;SKYFLASH

;-------------------------
;* external stores weights (lbs)
;-------------------------

ExtWeights	DW	1000		;EXT_GPB1000
		DW	1000		;EXT_RET1000
		DW	1000		;EXT_LGB1000
		DW	611		;EXT_BL755
		DW	5148*2		;EXT_JP233
		DW	661		;EXT_ALARM
		DW	188		;EXT_SIDEWINDER
		DW	459		;EXT_SKYFLASH
		DW	225		;EXT_BOZ100
		DW	225		;EXT_SKYSHADOW
		DW	3960		;EXT_DROPTANK

;-------
;* BL755
;-------

BL755_BOMBLETS	EQU	6		;number of bomblets from BL755

;-------
;* JP233
;-------

;* 60 JP233 sub-munitions, released over 4 seconds

JP233_BOMBLETS	EQU	15		;number of bomblets from JP233 per second

JP233_PERIOD	EQU	4*100		;release period (secs * 100)

JP233Timer	DW	0		;Tornado JP233 disperse timer (secs * 100)

;---------
;* cannons
;---------

CANNON_RATE	EQU	16		;rounds / second (approx 1000 / min)

MUZZLE_VELOCITY	EQU	3363*8		;(ft/sec * 8)

SHELL_LIFETIME	EQU	3*100		;(secs * 100)

	IF	OPT_FLY_DEMO EQ 0

Cannons		DW	MAX_CANNON	;number of cannon rounds

	ELSE

Cannons		DW	0

	ENDIF

CannonFine	DW	0

ShellKillZone	DW	0		;lethality zone wrt frame rate

CannonFired	DB	0		;1 = cannon fired this frame

		EVEN

;-----------------
;* Sidewinder data
;-----------------

SIDE_MAX_SPEED	EQU	3000*8		;(ft/sec * 8)

SIDE_BURNTIME	EQU	2*100		;(secs * 100)

;* accel = max speed / burntime

SIDE_ACCEL	EQU	1500*8		;accel (ft/sec/sec * 8)

SideDecelTime	LABEL	WORD		;decel time wrt alt (secs * 100)

		DW	1188		;0
		DW	1225		;1000
		DW	1263		;2000
		DW	1300		;3000
		DW	1338		;4000
		DW	1375		;5000
		DW	1425		;6000
		DW	1475		;7000
		DW	1513		;8000
		DW	1563		;9000
		DW	1613		;10000
		DW	1663		;11000
		DW	1713		;12000
		DW	1775		;13000
		DW	1825		;14000
		DW	1888		;15000
		DW	1950		;16000
		DW	2013		;17000
		DW	2088		;18000
		DW	2138		;19000
		DW	2213		;20000
		DW	2275		;21000
		DW	2363		;22000
		DW	2438		;23000
		DW	2538		;24000
		DW	2625		;25000
		DW	2713		;26000
		DW	2813		;27000
		DW	2900		;28000
		DW	3000		;29000
		DW	3088		;30000
		DW	3188		;31000
		DW	3288		;32000
		DW	3400		;33000
		DW	3538		;34000
		DW	3688		;35000
		DW	3825		;36000

;----------------
;* Sky Flash data
;----------------

SKY_MAX_SPEED	EQU	4000*8		;(ft/sec * 8)

SKY_BURNTIME	EQU	7*100		;(secs * 100)

;* accel = max speed / burntime

SKY_ACCEL	EQU	571*8		;accel (ft/sec/sec * 8)

SkyDecelTime	LABEL	WORD		;decel time wrt alt (secs * 100)

		DW	3225 		;0
		DW	3325 		;1000
		DW	3413 		;2000
		DW	3500 		;3000
		DW	3600 		;4000
		DW	3700 		;5000
		DW	3800 		;6000
		DW	3900 		;7000
		DW	4000 		;8000
		DW	4100 		;9000
		DW	4238 		;10000
		DW	4375 		;11000
		DW	4525 		;12000
		DW	4663 		;13000
		DW	4813 		;14000
		DW	4963 		;15000
		DW	5113 		;16000
		DW	5275 		;17000
		DW	5425 		;18000
		DW	5588 		;19000
		DW	5750 		;20000
		DW	5913 		;21000
		DW	6088 		;22000
		DW	6263 		;23000
		DW	6438 		;24000
		DW	6625 		;25000
		DW	6800 		;26000
		DW	6988 		;27000
		DW	7175 		;28000
		DW	7375 		;29000
		DW	7625 		;30000
		DW	7925 		;31000
		DW	8263 		;32000
		DW	8563 		;33000
		DW	8913 		;34000
		DW	9238 		;35000
		DW	9600 		;36000

;------------
;* ALARM data
;------------

ALARM_MAX_SPEED	EQU	2000*8		;max speed (ft/sec * 8)

ALARM_MIN_SPEED	EQU	40*8		;min speed (chute open) (ft/sec * 8)

ALARM_STL_SPEED	EQU	200*8		;stall speed (ft/sec * 8)

ALARM_BURNTIME	EQU	10*100		;(secs * 100)

;* accel = max speed / burntime

ALARM_ACCEL	EQU	200*8		;accel (ft/sec/sec * 8)

TARGET_ALT	EQU	0
CLEARANCE_ALT	EQU	200
RELEASE_ALT	EQU	1000
CRUISE_ALT	EQU	5000
LOITER_ALT	EQU	10000

KILL_RANGE	EQU	4000
ZOOM_RANGE	EQU	6000

AlarmDecelTime	LABEL	WORD		;decel time wrt alt (secs * 100)

		DW	2788		;0
		DW	2874		;1000
		DW	2960		;2000
		DW	3045		;3000
		DW	3131		;4000
		DW	3217		;5000
		DW	3303		;6000
		DW	3388		;7000
		DW	3474		;8000
		DW	3560		;9000
		DW	3646		;10000
		DW	3731		;11000
		DW	3817		;12000
		DW	3903		;13000
		DW	3989		;14000
		DW	4074		;15000
		DW	4160		;16000
		DW	4246		;17000
		DW	4332		;18000
		DW	4417		;19000
		DW	4503		;20000
		DW	4589		;21000
		DW	4675		;22000
		DW	4760		;23000
		DW	4846		;24000
		DW	4932		;25000
		DW	5018		;26000
		DW	5103		;27000
		DW	5189		;28000
		DW	5275		;29000
		DW	5361		;30000
		DW	5446		;31000
		DW	5532		;32000
		DW	5618		;33000
		DW	5704		;34000
		DW	5789		;35000
		DW	5875		;36000

;* ALARM mode switch

AlarmMode	DW	AlarmDirect	;ALARM_DIRECT
		DW	AlarmKill	;ALARM_KILL
		DW	AlarmGuide	;ALARM_GUIDE
		DW	AlarmZoom	;ALARM_ZOOM
		DW	AlarmFreeFall	;ALARM_FREEFALL
		DW	AlarmLoiter	;ALARM_LOITER
		DW	AlarmDive	;ALARM_DIVE

;----------------------------
;* Patriot / Gecko (SAM) data
;----------------------------

;* note: The surface-to-air missile initial velocity is zero as the launching
;*       vehicle is static. However, this causes a problem with the intercept
;*       algorithm in that the slow speed of the missile causes the intercept
;*       point to appear behind the missile in head on cases. Therefore the
;*       missile always loses lock. This problem is not so apparent with
;*       air-to-air missiles as the missile inherits its initial velocity
;*       from the launching aircraft. Therefore, SAM missiles sholud be given
;*       a fixed initial velocity to get around this problem. Unfortunately,
;*       the visual effect of the launch is slightly spoiled.

SAM_MIN_SPEED	EQU	1000*8		;launch velocity (ft/sec * 8)

SAM_MAX_SPEED	EQU	2500*8		;(ft/sec * 8)

SAM_BURNTIME	EQU	3*100		;(secs * 100)

;* accel = (max speed - min speed) / burntime

SAM_ACCEL	EQU	500*8		;accel (ft/sec/sec * 8)

SAMDecelTime	LABEL	WORD		;decel time wrt alt (secs * 100)

		DW	1188		;0
		DW	1225		;1000
		DW	1263		;2000
		DW	1300		;3000
		DW	1338		;4000
		DW	1375		;5000
		DW	1425		;6000
		DW	1475		;7000
		DW	1513		;8000
		DW	1563		;9000
		DW	1613		;10000
		DW	1663		;11000
		DW	1713		;12000
		DW	1775		;13000
		DW	1825		;14000
		DW	1888		;15000
		DW	1950		;16000
		DW	2013		;17000
		DW	2088		;18000
		DW	2138		;19000
		DW	2213		;20000
		DW	2275		;21000
		DW	2363		;22000
		DW	2438		;23000
		DW	2538		;24000
		DW	2625		;25000
		DW	2713		;26000
		DW	2813		;27000
		DW	2900		;28000
		DW	3000		;29000
		DW	3088		;30000
		DW	3188		;31000
		DW	3288		;32000
		DW	3400		;33000
		DW	3538		;34000
		DW	3688		;35000
		DW	3825		;36000

;----------------------
;* ECM / chaff / flares
;----------------------

ECMFitted	DB	0		;1 = ECM fitted
ECMActive	DB	0		;1 = ECM active (must be fitted)

		EVEN

ChaffCntr	DW	0
FlareCntr	DW	0

RelChaff	DB	0		;1 = used chaff this frame
RelFlare	DB	0		;1 = used flare this frame

		EVEN

CHAFF_LIFE	EQU	5*100		;chaff lifetime (secs * 100)
FLARE_LIFE	EQU	5*100		;flare lifetime (secs * 100)

CHAFF_RETARD	EQU	16384		;0.5
FLARE_RETARD	EQU	24576		;0.75

;----------------
;* weapon objects
;----------------

ObjectNum	DB	MOB_BOMB	;GPB1000
		DB	MOB_BOMB	;RET1000
		DB	MOB_LGB		;LGB1000
		DB	MOB_BOMB	;BL755
		DB	MOB_SG357	;JP233
		DB	MOB_ALARM	;ALARM
		DB	MOB_TRACER	;CANNON
		DB	MOB_AIM9L	;SIDEWINDER
		DB	MOB_SKYFLASH	;SKYFLASH
		DB	MOB_ALARM	;PATRIOT
		DB	MOB_ALARM	;GECKO
		DB	MOB_CHAFF	;CHAFF
		DB	MOB_FLARE	;FLARE
		DB	MOB_TRACERB	;CANNON (RED)
		EVEN

;----------------------
;* update weapon switch
;----------------------

UpdateOneWeapon	DW	UpdateGPB	;GPB1000
		DW	UpdateRET	;RET1000
		DW	UpdateLGB	;LGB1000
		DW	UpdateBL755	;BL755
		DW	UpdateJP233	;JP233
		DW	UpdateAlarm	;ALARM
		DW	UpdateCannon	;CANNON
		DW	UpdateMissile	;SIDEWINDER
		DW	UpdateMissile	;SKYFLASH
		DW	UpdateMissile	;PATRIOT
		DW	UpdateMissile	;GECKO
		DW	UpdateDecoy	;CHAFF
		DW	UpdateDecoy	;FLARE

;--------------------
;* arming mode switch
;--------------------

ArmSwitch	DW	ArmOk		;ARM_OFF
		DW	ArmManual	;ARM_MANUAL
		DW	ArmLaydown	;ARM_LAYDOWN
		DW	ArmLoft		;ARM_LOFT
		DW	ArmLaserGuided	;ARM_LGB
		DW	ArmJP233	;ARM_JP233
		DW	ArmAlarmDir	;ARM_ALARM_DIR
		DW	ArmAlarmInd	;ARM_ALARM_IND
		DW	ArmCannon	;ARM_CANNON
		DW	ArmSidewinder	;ARM_SIDEWINDER
		DW	ArmSkyFlash	;ARM_SKYFLASH

;-----------------------
;* weapon release switch
;-----------------------

ReleaseWeapon	DW	ReleaseBomb	;GPB1000
		DW	ReleaseBomb	;RET1000
		DW	ReleaseBomb	;LGB1000
		DW	ReleaseBomb	;BL755
		DW	ReleaseBomb	;JP233

;-----------------------------
;* bomb release safety heights (ft)
;-----------------------------

SafetyHeights	DW	1000		;GPB1000
		DW	100		;RET1000
		DW	1000		;LGB1000
		DW	200		;BL755
		DW	200		;JP233

;---------------------
;* bomb retard factors (binary fractions)
;---------------------

RetardFactors	DW	31130		;GPB1000 (0.95)
		DW	24576		;RET1000 (0.75)
		DW	31130		;LGB1000 (0.95)
		DW	29491		;BL755 (0.90)
		DW	24576		;JP233 (0.75)

;-------------
;* crater size
;-------------

CraterSize	DB	CRATER_SIZE2	;GPB1000
		DB	CRATER_SIZE2	;RET1000
		DB	CRATER_SIZE2	;LGB1000
		DB	CRATER_SIZE1	;BL755
		DB	CRATER_SIZE1	;JP233
		DB	CRATER_SIZE2	;ALARM
		DB	CRATER_SHELL	;CANNON
		DB	CRATER_SIZE1	;SIDEWINDER
		DB	CRATER_SIZE1	;SKYFLASH
		DB	CRATER_SIZE1	;PATRIOT
		DB	CRATER_SIZE1	;GECKO
		DB	CRATER_SIZE1	;CHAFF
		DB	CRATER_SIZE1	;FLARE

		EVEN

;---------------------
;* crater smoke effect
;---------------------

CraterSmoke	DW	SMOKE_CRATER3	;GPB1000
		DW	SMOKE_CRATER3	;RET1000
		DW	SMOKE_CRATER3	;LGB1000
		DW	SMOKE_CRATER2	;BL755
		DW	SMOKE_CRATER1	;JP233
		DW	SMOKE_CRATER3	;ALARM
		DW	SMOKE_CRATER2	;CANNON
		DW	SMOKE_CRATER2	;SIDEWINDER
		DW	SMOKE_CRATER2	;SKYFLASH
		DW	SMOKE_CRATER2	;PATRIOT
		DW	SMOKE_CRATER2	;GECKO
		DW	SMOKE_CRATER1	;CHAFF
		DW	SMOKE_CRATER1	;FLARE

;-------------------
;* Tornado die flags
;-------------------

TornadoWpnDie	DB	DIE_GND_EXPLO	;GPB1000
		DB	DIE_GND_EXPLO	;RET1000
		DB	DIE_GND_EXPLO	;LGB1000
		DB	DIE_GND_EXPLO	;BL755
		DB	DIE_GND_EXPLO	;JP233
		DB	DIE_GND_EXPLO	;ALARM
		DB	DIE_CANNON	;CANNON
		DB	DIE_MISSILE	;SIDEWINDER
		DB	DIE_MISSILE	;SKYFLASH
		DB	DIE_SAM		;PATRIOT
		DB	DIE_SAM		;GECKO
		DB	DIE_MISSILE	;CHAFF
		DB	DIE_MISSILE	;FLARE

		EVEN

;----------------------
;* weapon effectiveness
;----------------------

WeaponEffect	DB	WPN_EFFECT4	;GPB1000
		DB	WPN_EFFECT4	;RET1000
		DB	WPN_EFFECT4	;LGB1000
		DB	WPN_EFFECT3	;BL755
		DB	WPN_EFFECT3	;JP233
		DB	WPN_EFFECT3	;ALARM
		DB	WPN_EFFECT1	;CANNON
		DB	WPN_EFFECT1	;SIDEWINDER
		DB	WPN_EFFECT1	;SKYFLASH
		DB	WPN_EFFECT3	;PATRIOT
		DB	WPN_EFFECT3	;GECKO  used to be WPN_EFFECT3 --> now changed to WPN_EFFECT2
		DB	WPN_EFFECT1	;CHAFF
		DB	WPN_EFFECT1	;FLARE

		EVEN

;----------------------
;* weapon damage radius (ground objects)
;----------------------

WeaponRadius	DW	300		;GPB1000
		DW	300		;RET1000
		DW	300		;LGB1000
		DW	50		;BL755
		DW	50		;JP233
		DW	50		;ALARM
		DW	20		;CANNON
		DW	20		;SIDEWINDER
		DW	20		;SKYFLASH
		DW	20		;PATRIOT
		DW	20		;GECKO
		;DW	10		;GECKO
		DW	0		;CHAFF
		DW	0		;FLARE

;--------------------------
;* weapon damage hemishpere (airborne objects)
;--------------------------

;* halve these values for lethal hemisphere

WeaponHemi	DW	750		;GPB1000
		DW	750		;RET1000
		DW	750		;LGB1000
		DW	200		;BL755
		DW	200		;JP233
		DW	200		;ALARM
		DW	0		;CANNON
		DW	0		;SIDEWINDER
		DW	0		;SKYFLASH
		DW	0		;PATRIOT
		DW	0		;GECKO
		DW	0		;CHAFF
		DW	0		;FLARE

;----------------
;* debris objects
;----------------

DebrisType	DB	GND_CRATER1	;DAM_DEBRIS1
		DB	GND_CRATER2	;DAM_DEBRIS2
		DB	GND_CRATER3	;DAM_DEBRIS3
		DB	GND_RBNSD	;DAM_DEBRIS4
		DB	GND_RBEWD	;DAM_DEBRIS5
		DB	GND_RLBNSD	;DAM_DEBRIS6
		DB	GND_RLBEWD	;DAM_DEBRIS7
		DB	GND_EMBCRATER	;DAM_DEBRIS8

		EVEN

;------------
;* viewpoints
;------------

TGT_VIEW	VIEWPOINT <>		;target position
CCIP_VIEW	VIEWPOINT <>		;CCIP position

DATA		ENDS

;============================================================================

WPNDATA		SEGMENT PARA PUBLIC 'DATA'

WeaponList	LABEL	WORD

		REPT	NUM_WEAPONS

		MOBILE <>
		VIEWPOINT <>
		WEAPON <>

		ENDM

ImpactList	LABEL	IMPACT

		IMPACT	NUM_IMPACTS DUP(<>)

ImpactListEnd	LABEL	IMPACT

WPNDATA		ENDS

;============================================================================

SECDATA1	SEGMENT PARA PUBLIC 'DATA'

SECDATA1	ENDS

;============================================================================

MSECDATA1	SEGMENT PARA PUBLIC 'DATA'

MSECDATA1	ENDS

;============================================================================

WEAPONCODE	SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:WEAPONCODE
		ASSUME DS:DATA

;* InitWeapons
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

InitWeapons	PROC	FAR

;---------------------
;* init chaff / flares (wrt variant)
;---------------------

		cmp	TornadoType,ADV_TORNADO	;ADV?
		je	@F			;yes (internal) ->

		cmp	ExtStores[EXT_BOZ100],0	;chaff / flare dispenser fitted?
		je	SkipBOZ			;no ->

@@:		mov	ChaffCntr,MAX_CHAFF
		mov	FlareCntr,MAX_FLARES

;----------
;* init ECM (wrt variant)
;----------

SkipBOZ:	cmp	TornadoType,ADV_TORNADO	;ADV?
		je	@F			;yes (internal) ->

		cmp	ExtStores[EXT_SKYSHADOW],0	;ECM fitted?
		je	SkipSkyShadow			;no ->

@@:		mov	ECMFitted,1

;------------------
;* init package ptr
;------------------

SkipSkyShadow:	mov	si,OFFSET Packages

		mov	cx,NUM_PACKAGES

@@:		cmp	[si].PACK_WEAP_TYPE,NULL_WEAPON	;null package?
		jne	PackageOk

		add	si,PACK_REC_SIZE

		loop	@B

		mov	si,-1		;no packages

PackageOk:	mov	PackagePtr,si

		ret

InitWeapons	ENDP

;----------------------------------------------------------------------------

;* CalcStoresWt (excluding external fuel)
;*
;* pass: nothing
;* ret : StoresWt
;* kill: assume all

CalcStoresWt	PROC	FAR

		mov	StoresWt,0

		mov	ax,ExtStores[EXT_GPB1000]
		mov	dx,ExtWeights[EXT_GPB1000]
		mul	dx
		add	StoresWt,ax

		mov	ax,ExtStores[EXT_RET1000]
		mov	dx,ExtWeights[EXT_RET1000]
		mul	dx
		add	StoresWt,ax

		mov	ax,ExtStores[EXT_LGB1000]
		mov	dx,ExtWeights[EXT_LGB1000]
		mul	dx
		add	StoresWt,ax

		mov	ax,ExtStores[EXT_BL755]
		mov	dx,ExtWeights[EXT_BL755]
		mul	dx
		add	StoresWt,ax

		mov	ax,ExtStores[EXT_JP233]
		mov	dx,ExtWeights[EXT_JP233]
		mul	dx
		add	StoresWt,ax

		mov	ax,ExtStores[EXT_ALARM]
		mov	dx,ExtWeights[EXT_ALARM]
		mul	dx
		add	StoresWt,ax

		mov	ax,ExtStores[EXT_SIDEWINDER]
		mov	dx,ExtWeights[EXT_SIDEWINDER]
		mul	dx
		add	StoresWt,ax

		mov	ax,ExtStores[EXT_SKYFLASH]
		mov	dx,ExtWeights[EXT_SKYFLASH]
		mul	dx
		add	StoresWt,ax

		mov	ax,ExtStores[EXT_BOZ100]
		mov	dx,ExtWeights[EXT_BOZ100]
		mul	dx
		add	StoresWt,ax

		mov	ax,ExtStores[EXT_SKYSHADOW]
		mov	dx,ExtWeights[EXT_SKYSHADOW]
		mul	dx
		add	StoresWt,ax

;* cannons weigh 1/2 pound each (9.17oz)

		mov	ax,Cannons

		cmp	TornadoType,ADV_TORNADO
		jne	@F

		shr	ax,1		;ADV has single gun

@@:		add	StoresWt,ax

		ret

CalcStoresWt	ENDP

;----------------------------------------------------------------------------

;* UpdateWeapons - update active weapons
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

UpdateWeapons	PROC	FAR

;---------------------------
;* calc shell lethality zone (wrt frame rate)
;---------------------------

;* At 16 frames/sec, a shell kill zone of 32ft seems ok.
;*
;* Increase kill zone wrt frame rate to make the target easier to hit.
;*
;* @ 16 frames/sec DeltaTime = 32768 / 16 = 2048
;*
;* shell kill zone = 32 + max(DeltaTime - 2048, 0) / 128

		mov	ax,DeltaTime
		sub	ax,2048
		MINM	ax
		mov	cl,7
		shr	ax,cl
		adc	ax,32

		mov	ShellKillZone,ax

;-------------------------
;* init weapon update loop
;-------------------------

		mov	ax,WPNDATA
		mov	ds,ax

		mov	cx,NUM_WEAPONS

		mov	si,OFFSET WeaponList

;--------------------
;* update weapon loop
;--------------------

UpdateLoop:	cmp	_WPN_TYPE[si],NULL_WEAPON	;in use?
		je	UpdateNext     			;no ->

		mov	ES:WeaponPtr,si

		push	cx
		push	si

;---------------------------------
;* copy weapon data into workspace
;---------------------------------

		mov	di,OFFSET WPN_Workspace
		mov	cx,WPN_DATA_SIZE
		FAST_MOVE

		mov	ax,DATA
		mov	ds,ax

;* intercept splash / airburst effects

		mov	ax,WPN_Weapon.WPN_FLAGS

		test	ax,WFLG_SPLASH		;splash?
		jnz	ContSplash		;yes ->

		test	ax,WFLG_AIRBURST	;airburst?
		jnz	ContAirburst		;yes ->

		mov	bx,WPN_Weapon.WPN_TYPE
		call	UpdateOneWeapon[bx]

		jmp	ContUpdate

ContSplash:	call	UpdateSplash

		jmp	ContUpdate

ContAirburst:	call	UpdateAirburst

;---------------------------------
;* copy weapon data from workspace
;---------------------------------

ContUpdate:	mov	ax,WPNDATA
		mov	es,ax

		mov	si,OFFSET WPN_Workspace
		mov	di,WeaponPtr
		mov	cx,WPN_DATA_SIZE
		FAST_MOVE

		mov	ax,DATA
		mov	es,ax

		mov	ax,WPNDATA
		mov	ds,ax

		pop	si
		pop	cx

UpdateNext:	add	si,WPN_DATA_SIZE

		loop	UpdateLoop

		mov	ax,DATA
		mov	ds,ax

		ret

UpdateWeapons	ENDP

;----------------------------------------------------------------------------

;* UpdateGPB
;*
;* pass: WPN_Workspace
;* ret : nothing
;* kill: assume all

UpdateGPB	PROC	NEAR

		call	BombBallistics
		jnc	ExitGPB		;still falling ->

		call	GroundDamage

ExitGPB:	ret

UpdateGPB	ENDP

;----------------------------------------------------------------------------

;* UpdateRET
;*
;* pass: WPN_Workspace
;* ret : nothing
;* kill: assume all

UpdateRET	PROC	NEAR

		call	BombBallistics
		jnc	ExitRET		;still falling ->

		call	GroundDamage

ExitRET:	ret

UpdateRET	ENDP

;----------------------------------------------------------------------------

;* UpdateLGB
;*
;* pass: WPN_Workspace
;* ret : nothing
;* kill: assume all

UpdateLGB	PROC	NEAR

		test	WPN_Weapon.WPN_FLAGS,WFLG_UNGUIDED	;guided?
		jnz	UnguidedLGB				;no ->

		call	LGBGuidance
		jnc	ExitLGB		;still guiding ->

		call	GroundDamage

		jmp	ExitLGB

;----------------------------
;* LGB used as GPB (unguided)
;----------------------------

UnguidedLGB:	call	BombBallistics
		jnc	ExitLGB		;still falling ->

		call	GroundDamage

ExitLGB:	ret

UpdateLGB	ENDP

;----------------------------------------------------------------------------

;* UpdateBL755
;*
;* pass: WPN_Workspace
;* ret : nothing
;* kill: assume all

UpdateBL755	PROC	NEAR

;* sort BL755 or bomblet

		test	WPN_Weapon.WPN_FLAGS,WFLG_BOMBLET	;already bomblet?
		jnz	SkipFragment				;yes ->

;* if just blown off casing then fragment

		test	WPN_Mobile.MOB_ANIM,CASING_OFF 	;casing off?
		jnz	ContFragment		       	;yes ->

;* if alt < threshold then start fragmention

		cmp	WORD PTR WPN_View.VP_ZFT_HI,0  	;alt > 65535?
		ja	SkipFragment		       	;yes ->
		cmp	WORD PTR WPN_View.VP_ZFT_LO,150	;alt > 150?
		ja	SkipFragment		       	;yes ->

;* one frame of casing off animation before fragmenting

		or	WPN_Mobile.MOB_ANIM,CASING_OFF		

		jmp	SkipFragment

;* fragment BL755 into bomblets

ContFragment:	mov	cx,BL755_BOMBLETS-1

@@:		push	cx
		call	CreateBomblet
		pop	cx
		loop	@B

;* convert BL755 into bomblet

		mov	WPN_Mobile.MOB_NUM,MOB_BOMBLET

		mov	WPN_Mobile.MOB_ANIM,0

		or	WPN_Weapon.WPN_FLAGS,WFLG_BOMBLET

SkipFragment:	call	BombBallistics
		jnc	ExitBL755	;still falling ->

		call	GroundDamage

ExitBL755:	ret

UpdateBL755	ENDP

;----------------------------------------------------------------------------

;* UpdateJP233
;*
;* pass: WPN_Workspace
;* ret : nothing
;* kill: assume all

UpdateJP233	PROC	NEAR

		call	BombBallistics
		jnc	ExitJP233	;still falling ->

		call	GroundDamage

ExitJP233:	ret

UpdateJP233	ENDP

;----------------------------------------------------------------------------

;* UpdateAlarm
;*
;* pass: WPN_Workspace
;* ret : nothing
;* kill: assume all

UpdateAlarm	PROC	NEAR

		mov	bx,WPN_Weapon.WPN_FLAGS
		and	bx,WFLG_ALARM_MODE
		shl	bx,1

		jmp	AlarmMode[bx]

;---------------------------
AlarmDirect	LABEL	NEAR
;---------------------------

;* if end of lifetime then switch to zoom

		call	CheckAlarmTimer
		_JC	SwitchToZoom

;* if overshoot target then switch to zoom

		mov	ax,CLEARANCE_ALT
		xor	dx,dx
		call	AlarmGuidance
		_JC	SwitchToZoom

;* if within kill range then switch to kill

		cmp	WORD PTR TmpRange+2,0
		ja	@F
		cmp	WORD PTR TmpRange,KILL_RANGE
		_JB	SwitchToKill

;* if hit ground then explode

@@:		call	AlarmMovement
		_JC	AlarmDamage

		jmp	ExitAlarm

;---------------------------
AlarmKill	LABEL	NEAR
;---------------------------

;* if end of lifetime then switch to zoom

		call	CheckAlarmTimer
		_JC	SwitchToZoom

;* if overshoot target then switch to zoom

		mov	ax,TARGET_ALT
		xor	dx,dx
		call	AlarmGuidance
		_JC	SwitchToZoom

;* if hit ground then explode

IntoKill:	call	AlarmMovement
		_JC	AlarmDamage

		jmp	ExitAlarm

;---------------------------
AlarmGuide	LABEL	NEAR
;---------------------------

;* if end of lifetime then switch to zoom

		call	CheckAlarmTimer
		_JC	SwitchToZoom

;* if overshoot target then switch to zoom

		mov	ax,CRUISE_ALT
		xor	dx,dx

;* force missile to reach cruise altitude more quickly (avoid hills)

		cmp	WORD PTR WPN_View.VP_ZFT_HI,0
		ja	@F
		cmp	WORD PTR WPN_View.VP_ZFT_LO,CRUISE_ALT-1000
		ja	@F

		REPT	2
		shl	ax,1
		rcl	dx,1
		ENDM

@@:		call	AlarmGuidance
		_JC	SwitchToZoom

;* if within zoom range then switch to zoom

		cmp	WORD PTR TmpRange+2,0
		ja	@F
		cmp	WORD PTR TmpRange,ZOOM_RANGE
		_JB	SwitchToZoom

;* if hit ground then explode

@@:		call	AlarmMovement
		_JC	AlarmDamage

		jmp	ExitAlarm

;---------------------------
AlarmZoom     	LABEL	NEAR
;---------------------------

;* check if zoomed above loiter altitude

		cmp	WORD PTR WPN_View.VP_ZFT_HI,0
		_JA	SwitchToLoiter
		cmp	WORD PTR WPN_View.VP_ZFT_LO,LOITER_ALT
		_JA	SwitchToLoiter

;* check if stalled

		cmp	WPN_Weapon.WPN_ALM_VEL,ALARM_STL_SPEED
		_JB	SwitchToLoiter

;* zoom climb

		call	AlarmGuideAbove

;* if hit ground then explode

IntoZoom:	call	AlarmMovement
		_JC	AlarmDamage

		jmp	ExitAlarm

;---------------------------
AlarmFreeFall 	LABEL	NEAR
;---------------------------

;* if (alt > release alt) and (alt < loiter alt) then switch to loiter

		cmp	WORD PTR WPN_View.VP_ZFT_HI,0
		ja	@F

		mov	ax,WORD PTR WPN_View.VP_ZFT_LO

		cmp	ax,RELEASE_ALT
		jb	@F

		cmp	ax,LOITER_ALT
		_JB	SwitchToLoiter

;* free fall

@@:		call	AlarmGuideBelow

;* if hit ground then explode

IntoFreeFall:	call	AlarmMovement
		_JC	AlarmDamage

		jmp	ExitAlarm

;---------------------------
AlarmLoiter	LABEL	NEAR
;---------------------------

;* ensure pitched down to -90 degs

		cmp	WPN_Weapon.WPN_PFINE,-128*128
		jne	ContLoiter

;* if alt < release alt then switch to free fall

		cmp	WORD PTR WPN_View.VP_ZFT_HI,0
		ja	@F
		cmp	WORD PTR WPN_View.VP_ZFT_LO,RELEASE_ALT
		_JB	SwitchToFree

;* stabilise (prevent dive immediately after pitch = -90 for visual effect)

@@:		mov	ax,WPN_Weapon.WPN_ALM_TIMER
		sub	ax,LastFrame
		MINM	ax
		mov	WPN_Weapon.WPN_ALM_TIMER,ax

		jnz	ContLoiter

;* if radar detected then switch to dive mode

		call	AlarmRadarScan
		_JC	SwitchToDive

;* spinning parachute effect

ContLoiter:	mov	ax,14		;10 degs/sec

;* increase spin rate during pitch over (for stabilising effect)

		cmp	WPN_Weapon.WPN_PFINE,-128*128
		je	@F

		REPT	2
		shl	ax,1
		ENDM

@@:		mov	dx,DeltaTime
		imul	dx
		FRACADJ	dx

		jnz	@F

		inc	dx		;ensure spinning

@@:		add	dx,WPN_View.VP_ROLL
		and	dx,001ffh
		mov	WPN_View.VP_ROLL,dx

;* loiter

		call	AlarmGuideBelow

;* if hit ground then explode

IntoLoiter:	call	AlarmMovement
		jc	AlarmDamage

		jmp	ExitAlarm

;---------------------------
AlarmDive     	LABEL	NEAR
;---------------------------

;* dive towards target

		mov	ax,TARGET_ALT
		xor	dx,dx
		call	AlarmGuidance
		jc	SwitchToFree

;* if hit ground then explode

IntoDive:	call	AlarmMovement
		jc	AlarmDamage

		jmp	ExitAlarm

;---------------------------
AlarmDamage	LABEL	NEAR
;---------------------------

		call	GroundDamage

ExitAlarm:	ret

;---------------------------
SwitchToKill	LABEL	NEAR
;---------------------------

;* set kill mode

		and	WPN_Weapon.WPN_FLAGS,NOT WFLG_ALARM_MODE
		or	WPN_Weapon.WPN_FLAGS,ALARM_KILL

		jmp	IntoKill

;---------------------------
SwitchToZoom	LABEL	NEAR
;---------------------------

;* if above loiter altitude then switch to free fall

		cmp	WORD PTR WPN_View.VP_ZFT_HI,0
		ja	SwitchToFree
		cmp	WORD PTR WPN_View.VP_ZFT_LO,LOITER_ALT
		ja	SwitchToFree

;* if stalled then switch to loiter

		cmp	WPN_Weapon.WPN_ALM_VEL,ALARM_STL_SPEED
		jb	SwitchToLoiter

;* motor off

		or	WPN_Weapon.WPN_FLAGS,WFLG_BURNOUT
		and	WPN_Mobile.MOB_ANIM,NOT FLAME

;* fixed deceleration (-187.5ft/sec/sec)

		mov	WPN_Weapon.WPN_ALM_ACCEL,-1500

;* set zoom mode

		and	WPN_Weapon.WPN_FLAGS,NOT WFLG_ALARM_MODE
		or	WPN_Weapon.WPN_FLAGS,ALARM_ZOOM

		jmp	IntoZoom

;---------------------------
SwitchToFree	LABEL	NEAR
;---------------------------

;* motor off

		or	WPN_Weapon.WPN_FLAGS,WFLG_BURNOUT
		and	WPN_Mobile.MOB_ANIM,NOT FLAME

;* chute closed

		and	WPN_Mobile.MOB_ANIM,NOT CHUTE

;* fixed acceleration (32ft/sec/sec)

		mov	WPN_Weapon.WPN_ALM_ACCEL,32*8

;* reset roll (for better visual effect after loiter)

		mov	WPN_View.VP_ROLL,0

;* set free fall mode

		and	WPN_Weapon.WPN_FLAGS,NOT WFLG_ALARM_MODE
		or	WPN_Weapon.WPN_FLAGS,ALARM_FREEFALL

		jmp	IntoFreeFall

;---------------------------
SwitchToLoiter	LABEL	NEAR
;---------------------------

;* motor off

		or	WPN_Weapon.WPN_FLAGS,WFLG_BURNOUT
		and	WPN_Mobile.MOB_ANIM,NOT FLAME

;* chute open

		or	WPN_Mobile.MOB_ANIM,CHUTE

;* fixed deceleration (-375ft/sec/sec)

		mov	WPN_Weapon.WPN_ALM_ACCEL,-3000

;* set stabilisation delay

		mov	WPN_Weapon.WPN_ALM_TIMER,3*100

;* set loiter mode

		and	WPN_Weapon.WPN_FLAGS,NOT WFLG_ALARM_MODE
		or	WPN_Weapon.WPN_FLAGS,ALARM_LOITER

		jmp	IntoLoiter

;---------------------------
SwitchToDive	LABEL	NEAR
;---------------------------

;* motor off

		or	WPN_Weapon.WPN_FLAGS,WFLG_BURNOUT
		and	WPN_Mobile.MOB_ANIM,NOT FLAME

;* chute closed

		and	WPN_Mobile.MOB_ANIM,NOT CHUTE

;* fixed acceleration (32ft/sec/sec)

		mov	WPN_Weapon.WPN_ALM_ACCEL,32*8

;* reset roll (for better visual effect after loiter)

		mov	WPN_View.VP_ROLL,0
		;Added this in so that the ALARM fires towards its target with
		;a full plume of fire at its back nozzle!
		mov	WPN_Mobile.MOB_ANIM,FLAME

;* if viewing weapon then reset camera bearing (to prevent visual glitch)

		mov	ax,WeaponPtr
		cmp	ax,ViewWeaponPtr
		jne	@F

 		mov	WpnCamBrg,256
		mov	WpnCamBrgFine,0

;* set dive mode

@@:		and	WPN_Weapon.WPN_FLAGS,NOT WFLG_ALARM_MODE
		or	WPN_Weapon.WPN_FLAGS,ALARM_DIVE

		jmp	IntoDive

UpdateAlarm	ENDP

;----------------------------------------------------------------------------

;* UpdateCannon
;*
;* pass: WPN_Workspace
;* ret : nothing
;* kill: assume all

UpdateCannon	PROC	NEAR

;---------------------------
;* check for end of lifetime
;---------------------------

		mov	ax,WPN_Weapon.WPN_CAN_TIMER

		sub	ax,LastFrame	;time up?
		jnc	@F    		;no ->

		mov	WPN_Weapon.WPN_TYPE,NULL_WEAPON

		jmp	ExitCannon

@@:		mov	WPN_Weapon.WPN_CAN_TIMER,ax

;-------------
;* move weapon
;-------------

		call	ShellBallistics
		jnc	ExitCannon	;ok ->

		call	GroundDamage

ExitCannon:	ret

UpdateCannon	ENDP

;----------------------------------------------------------------------------

;* UpdateMissile
;*
;* pass: WPN_Workspace
;* ret : nothing
;* kill: assume all

UpdateMissile	PROC	NEAR

;---------------------------
;* check for end of lifetime
;---------------------------

		mov	ax,WPN_Weapon.WPN_MISS_TIMER

		sub	ax,LastFrame	;time up?
		_JNC	MissTimerOk	;no ->

;* motor burnout or end of lifetime?

		test	WPN_Weapon.WPN_FLAGS,WFLG_BURNOUT
		jz	@F

;* end of lifetime (self destruct)

		mov	si,-1
		mov	di,OFFSET WPN_View

		call	WpnHitTarget

;* lose lock (else explosion shows up on Tornado RWR)

		mov	WPN_Weapon.WPN_MISS_TGT,-1

		and	WPN_Weapon.WPN_FLAGS,NOT WFLG_TLOCK

		jmp	ExitMissile

;* motor burnout

@@:		or	WPN_Weapon.WPN_FLAGS,WFLG_BURNOUT

		and	WPN_Mobile.MOB_ANIM,NOT FLAME

		mov	ax,WORD PTR WPN_View.VP_ZFT_LO
		mov	dx,WORD PTR WPN_View.VP_ZFT_HI
		mov	bx,1000

		div 	bx

		cmp	ax,36		;valid up to 36000ft
		jbe	@F
		mov	ax,36

@@:		mov	bx,ax

		shl	bx,1		;bx = decel time index

;* sort Sidewinder

		cmp	WPN_Weapon.WPN_TYPE,SIDEWINDER
		jne	@F

		mov	bx,SideDecelTime[bx]

		jmp	ContBurnout

;* sort Sky Flash

@@:		cmp	WPN_Weapon.WPN_TYPE,SKYFLASH
		jne	@F

		mov	bx,SkyDecelTime[bx]

		jmp	ContBurnout

;* sort Patriot

@@:		cmp	WPN_Weapon.WPN_TYPE,PATRIOT
		jne	@F

		mov	bx,SAMDecelTime[bx]

		jmp	ContBurnout

;* sort Gecko

@@:		mov	bx,SAMDecelTime[bx]

;* accel[*8] = (1000*8 - vel[*8]) * 100 / decel time[*100]

ContBurnout:	mov	ax,1000*8

		mov	dx,WPN_Weapon.WPN_MISS_VEL

;* ensure accel <= 0

		cmp	dx,1000*8
		jae	@F
		mov	dx,1000*8

@@:		sub	ax,dx
		mov	dx,100
		imul	dx
		idiv	bx

		mov	WPN_Weapon.WPN_MISS_ACCEL,ax

		mov	ax,bx

;* set lifetime counter

MissTimerOk:	mov	WPN_Weapon.WPN_MISS_TIMER,ax

;-------------
;* move weapon
;-------------

		call	MissileGuidance
		jnc	ExitMissile	;ok ->

		call	GroundDamage

ExitMissile:	ret

UpdateMissile	ENDP

;----------------------------------------------------------------------------

;* UpdateDecoy
;*
;* pass: WPN_Workspace
;* ret : nothing
;* kill: assume all

UpdateDecoy	PROC	NEAR

;* check for end of lifetime

		mov	ax,LastFrame
		sub	WPN_Weapon.WPN_DECOY_LIFE,ax
		jc	@F

;* move decoy (check for hit ground)

		call	BombBallistics
		jnc	ExitDecoy

;* weapon no longer in use

@@:		mov	WPN_Weapon.WPN_TYPE,NULL_WEAPON

ExitDecoy:	ret

UpdateDecoy	ENDP

;----------------------------------------------------------------------------

;* BombBallistics - bomb movement routine (common to all free fall bombs)
;*
;* pass: WPN_Workspace
;* ret : cf = 0 = still falling
;*	 cf = 1 = hit ground / hit hill (zft > 0)
;* kill: assume all (except cf)

BombBallistics	PROC	NEAR

;--------------
;* calc delta z
;--------------

;* delta z = v vel * delta time - 16 * delta time * delta time
;*
;* (s = u * t + 1/2 * a * t * t)

;* v vel * delta time (result as 16 bit whole, 16 bit fraction)

		mov	ax,WPN_Weapon.WPN_BOMB_VVEL
		mov	dx,DeltaTime
		imul	dx
		REPT	2		;/4
		sar	dx,1
		rcr	ax,1
		ENDM

		mov	bx,ax
		mov	cx,dx

;* 16 * delta time * delta time (result as 16 bit whole, 16 bit fraction)

		mov	ax,DeltaTime
		imul	ax
		mov	al,ah		;/256
		mov	ah,dl
		mov	dl,dh
		xor	dh,dh
		REPT	2		;/4 (/1024)
		shr	dx,1
		rcr	ax,1
		ENDM

		sub	bx,ax
		sbb	cx,dx

		mov	ax,cx
		cwd			;dxcx.bx = delta z

		add	WPN_Weapon.WPN_ZFINE,bx
		adc	WORD PTR WPN_View.VP_ZFT_LO,cx
		adc	WORD PTR WPN_View.VP_ZFT_HI,dx

		_JS	BombHitGnd	;hit ground ->

;------------------------
;* calc vertical velocity
;------------------------

;* v vel = v vel - 32 * delta time (v = u + a * t)

		mov	ax,DeltaTime
		xor	dx,dx
		mov	dl,ah		;*256
		mov	ah,al
		xor	al,al
		FRACADJ	dx

		sub	WPN_Weapon.WPN_BOMB_VVEL,dx

;--------------------------------
;* calc delta horizontal velocity (dist moved this frame)
;--------------------------------

;* delta h vel = h vel * delta time

		mov	ax,WPN_Weapon.WPN_BOMB_HVEL
		mov	dx,DeltaTime
		imul	dx
		FRACADJ	bp

;-------------
;* move weapon
;-------------

;* calc sin(hdg) and cos(hdg)

ContBombBall:	mov	bx,WPN_View.VP_HDG

		SINCOS	si,di,bx

;* x = x + delta h vel * sin(hdg)

		mov	ax,bp
		imul	si
		REPT	2		;/4
		sar	dx,1
		rcr	ax,1
		ENDM
		add	WPN_Weapon.WPN_XFINE,ax
		adc	dx,0

		mov	cx,dx

;* y = y + delta h vel * cos(hdg)

		mov	ax,bp
		imul	di
		REPT	2		;/4
		sar	dx,1
		rcr	ax,1
		ENDM
		add	WPN_Weapon.WPN_YFINE,ax
		adc	dx,0

		MOVEXY	WPN_View,cx,dx

;-----------------------
;* calc bomb pitch angle
;-----------------------

;* note: h vel >= 0

;* select abs(v vel)
;* case = h vel
;*    pitch = 45
;* case < h vel
;*    pitch = arctan(v vel / h vel)
;* case > h vel
;*    pitch = 90 - arctan(h vel / v vel)
;* endselect

		mov	ax,WPN_Weapon.WPN_BOMB_VVEL

		ABSV	ax		;ax = abs(v vel), dx = sign(v vel)

		mov	bp,dx		;bp = sign(v vel)

		mov	bx,WPN_Weapon.WPN_BOMB_HVEL

		cmp	ax,bx		;abs(v vel) = h vel
		jne	@F

		mov	ax,64		;45 degs

		jmp	SetBombPitch

@@:		ja	@F		;abs(v vel) > h vel ->

;* pitch = arctan(abs(v vel) / h vel)

		mov	dx,ax
		xor	ax,ax

		shr	dx,1		;/2 for bin frac result
		rcr	ax,1

		div	bx

		call	FastArcTan

		mov	cl,7		;convert fine degs to pdegs
		shr	ax,cl
		ROUNDUP	ax

		jmp	SetBombPitch

;* pitch = 128 - arctan(h vel / abs(v vel))

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

		mov	cl,7		;convert fine degs to pdegs
		shr	ax,cl
		ROUNDUP	ax

SetBombPitch:	xor	ax,bp		;restore sign
		sub	ax,bp

		and	ax,511		;0 .. 511 pdegs

		mov	WPN_View.VP_PITCH,ax

;----------------------
;* check for hit ground
;----------------------

		mov	ax,WPN_Weapon.WPN_ZFINE
		or	ax,WORD PTR WPN_View.VP_ZFT_LO
		or	ax,WORD PTR WPN_View.VP_ZFT_HI
		jz	BombImpact

;--------------------
;* check for hit hill
;--------------------

		cmp	WORD PTR WPN_View.VP_ZFT_HI,0		;zft > 65535ft?
		ja	@F					;yes ->
		cmp	WORD PTR WPN_View.VP_ZFT_LO,4095	;zft > 4095ft?
		ja	@F					;yes ->

		mov	si,OFFSET WPN_View
		call	CalcGndHeight

		cmp	WORD PTR WPN_View.VP_ZFT_LO,ax	;hit hill?
		jbe	BombImpact			;yes ->

@@:		clc			;cf = 0 (still falling)
		ret

BombImpact:	stc			;cf = 1 (hit ground / hit hill)
		ret

;-----------------
;* bomb hit ground (calc impact point)
;-----------------

;* restore zft

BombHitGnd:    	sub	WPN_Weapon.WPN_ZFINE,bx
		sbb	WORD PTR WPN_View.VP_ZFT_LO,cx
		sbb	WORD PTR WPN_View.VP_ZFT_HI,dx

;* frac = zft / abs(delta z)
;*
;* assume delta z < 0
;* assume zft < 65536

		mov	dx,WORD PTR WPN_View.VP_ZFT_LO
		mov	ax,WPN_Weapon.WPN_ZFINE

		shr	dx,1		;/2 for bin frac
		rcr	ax,1

		neg	cx

		div	cx

;* delta h vel = h vel * frac * delta time

		mov	dx,WPN_Weapon.WPN_BOMB_HVEL
		imul	dx
		FRACADJ	dx

		mov	ax,DeltaTime
		imul	dx
		FRACADJ	bp

;* zft = 0

		xor	ax,ax

		mov	WPN_Weapon.WPN_ZFINE,ax
		mov	WORD PTR WPN_View.VP_ZFT_LO,ax
		mov	WORD PTR WPN_View.VP_ZFT_HI,ax

;* v vel = 0

		mov	WPN_Weapon.WPN_BOMB_VVEL,ax

		jmp	ContBombBall

BombBallistics	ENDP

;----------------------------------------------------------------------------

;* LGBGuidance - laser guided bomb guidance
;*
;* pass: WPN_Workspace
;* ret : cf = 0 = still guiding
;*	 cf = 1 = hit ground / hit hill (zft > 0)
;* kill: assume all (except cf)

LGBGuidance	PROC	NEAR

;--------------
;* calc delta z
;--------------

;* delta z = (vel * sin(pitch) * delta time) + (16 * delta time * delta time)

		mov	bx,WPN_View.VP_PITCH

		SINCOS	si,di,bx	;si = sin(pitch), di = cos(pitch)

		mov	ax,WPN_Weapon.WPN_LGB_VEL
		imul	si
		FRACADJ	dx

		mov	ax,DeltaTime
		imul	dx

		REPT	2		;/4
		sar	dx,1
		rcr	ax,1
		ENDM

		mov	bx,ax
		mov	cx,dx

;* 16 * delta time * delta time (result as 16 bit whole, 16 bit fraction)

		mov	ax,DeltaTime
		imul	ax
		mov	al,ah		;/256
		mov	ah,dl
		mov	dl,dh
		xor	dh,dh
		REPT	2		;/4 (/1024)
		shr	dx,1
		rcr	ax,1
		ENDM

		add	bx,ax
		adc	cx,dx

		mov	ax,cx
		cwd			;dxcx.bx = delta z

		add	WPN_Weapon.WPN_ZFINE,bx
		adc	WORD PTR WPN_View.VP_ZFT_LO,cx
		adc	WORD PTR WPN_View.VP_ZFT_HI,dx

		jns	CalcLGBVel	;not hit ground ->

;----------------
;* LGB hit ground (calc impact point)
;----------------

;* restore zft

		sub	WPN_Weapon.WPN_ZFINE,bx
		sbb	WORD PTR WPN_View.VP_ZFT_LO,cx
		sbb	WORD PTR WPN_View.VP_ZFT_HI,dx

;* frac = zft / abs(delta z)
;*
;* assume delta z < 0
;* assume zft < 65536

		mov	dx,WORD PTR WPN_View.VP_ZFT_LO
		mov	ax,WPN_Weapon.WPN_ZFINE

		shr	dx,1		;/2 for bin frac
		rcr	ax,1

		neg	cx

		div	cx

;* delta time * frac

		mov	dx,DeltaTime
		imul	dx
		FRACADJ	ax

;* zft = 0

		xor	dx,dx

		mov	WPN_Weapon.WPN_ZFINE,dx
		mov	WORD PTR WPN_View.VP_ZFT_LO,dx
		mov	WORD PTR WPN_View.VP_ZFT_HI,dx

		jmp	IntoLGBVel

;---------------
;* calc velocity
;---------------

;* vel = max(vel + 32 * -sin(pitch) * delta time, 0)

CalcLGBVel:	mov	ax,DeltaTime

IntoLGBVel:	imul	si

		REPT	6		;/64
		sar	dx,1
		rcr	ax,1
		ENDM

		mov	ax,dx

		neg	ax

		add	ax,WPN_Weapon.WPN_LGB_VEL
		jns	@F

		xor	ax,ax

@@:		mov	WPN_Weapon.WPN_LGB_VEL,ax

;-------------
;* move weapon
;-------------

;* delta h vel = vel * cos(pitch) * delta time

		imul	di
		FRACADJ	dx

		mov	ax,DeltaTime
		imul	dx
		FRACADJ	bp		;bp = delta h vel

;* calc sin(hdg) and cos(hdg)

		mov	bx,WPN_View.VP_HDG

		SINCOS	si,di,bx	;si = sin(hdg), di = cos(hdg)

;* x = x + delta h vel * sin(hdg)

		mov	ax,bp
		imul	si
		REPT	2		;/4
		sar	dx,1
		rcr	ax,1
		ENDM
		add	WPN_Weapon.WPN_XFINE,ax
		adc	dx,0

		mov	cx,dx

;* y = y + delta h vel * cos(hdg)

		mov	ax,bp
		imul	di
		REPT	2		;/4
		sar	dx,1
		rcr	ax,1
		ENDM
		add	WPN_Weapon.WPN_YFINE,ax
		adc	dx,0

		MOVEXY	WPN_View,cx,dx

;----------------------
;* check for hit ground
;----------------------

		mov	ax,WPN_Weapon.WPN_ZFINE
		or	ax,WORD PTR WPN_View.VP_ZFT_LO
		or	ax,WORD PTR WPN_View.VP_ZFT_HI
		_JZ	LGBImpact

;--------------------
;* check for hit hill
;--------------------

		cmp	WORD PTR WPN_View.VP_ZFT_HI,0		;zft > 65535ft?
		ja	@F					;yes ->
		cmp	WORD PTR WPN_View.VP_ZFT_LO,4095	;zft > 4095ft?
		ja	@F					;yes ->

		mov	si,OFFSET WPN_View
		call	CalcGndHeight

		cmp	WORD PTR WPN_View.VP_ZFT_LO,ax	;hit hill?
		_JBE	LGBImpact			;yes ->

;----------------------------------
;* check Tornado target illuminated
;----------------------------------

@@:		test	WPN_Weapon.WPN_FLAGS,WFLG_TORNADO	;Tornado weapon?
		jz	@F					;no ->

		test	LaserActive,1	;target illuminated?
		_JZ	NoLaser		;no ->

		cmp	Fog,0		;foggy?
		_JNE	NoLaser		;yes ->

		test	Overcast,1     	;overcast?
		jz	@F		;no ->

		mov	dx,WORD PTR M_VIEW.VP_ZFT_HI
		mov	ax,WORD PTR M_VIEW.VP_ZFT_LO

		cmp	dx,WORD PTR CloudBase+2	;zft >= cloud base?
		_JA	NoLaser			;yes ->
		cmp	ax,WORD PTR CloudBase
		_JAE	NoLaser			;yes ->

;------------------
;* calc ideal pitch
;------------------

@@:		mov	si,OFFSET WPN_View
		mov	di,WPN_Weapon.WPN_LGB_TGT
		call	CalcRngBrgVP_WP

;* if range > 65535ft then no guidance (too far)

		cmp	dx,0		;range > 65535?
		ja	NoLaser		;yes ->

;* if zft > 65535ft then no guidance (too high)

		cmp	WORD PTR WPN_View.VP_ZFT_HI,0	;zft > 65535?
		ja	NoLaser				;yes ->
		
		mov	bx,ax		;bx = range

;* select zft
;* case = range
;*    pitch = -45 degs
;* case < range
;*    pitch = -arctan(zft / range)
;* case > range
;*    pitch = -(90 degs - arctan(range / zft))
;* endselect

		mov	ax,WORD PTR WPN_View.VP_ZFT_LO

		cmp	ax,bx		;select zft

		jb	CalcLGBPitch1	;case < range ->
		ja	CalcLGBPitch2	;case > range ->

		mov	ax,-64*128	;ideal pitch = -45 degs

		jmp	LGBHdgError	

;* pitch = -arctan(zft / range)

CalcLGBPitch1:	mov	dx,ax
		xor	ax,ax

		shr	dx,1		;/2 for bin frac result
		rcr	ax,1

		div	bx

		call	FastArcTan

		neg	ax

		jmp	LGBHdgError

;* pitch = -(90 degs - arctan(range / zft))

CalcLGBPitch2:	mov	dx,bx
		mov	bx,ax
		xor	ax,ax

		shr	dx,1		;/2 for bin frac result
		rcr	ax,1

		div	bx

		call	FastArcTan

		mov	dx,128*128
		xchg	ax,dx

		sub	ax,dx

		neg	ax

;* hdg error = angular difference

LGBHdgError: 	mov	bx,ax		;store ideal pitch

		mov	ax,bp		;brg fine

		sub	ax,WPN_Weapon.WPN_HFINE

		ABSV	ax

		xchg	bx,ax		;ax = ideal pitch, bx = abs(hdg error)
		mov	cx,dx		;cx = sign(hdg error)

		jmp	CalcLGBRate

;-------------
;* no guidance (pitch down)
;-------------

NoLaser:	mov	ax,-128*128	;ideal pitch = -90 degs

		xor	bx,bx		;abs(hdg error) = 0
		xor	cx,cx		;sign(hdg error) = +ve

;-------------------
;* calc angular rate (frame limit)
;-------------------

;* ang rate = delta time * 16 (result required * 128 scaled)

CalcLGBRate:	mov	bp,DeltaTime

		REPT	4
		shr	bp,1
		ENDM

		ROUNDUP	bp

;--------------------
;* check for flipover
;--------------------

;* ax = ideal pitch (fine pdegs)
;* bx = abs(hdg error) (fine pdegs)
;* cx = sign(hdg error)
;* bp = ang rate (fine pdegs)

		cmp	bx,128*128	;hdg error > 90 degs?
		jbe	NoLGBFlip	;no ->

;----------
;* flipover
;----------

;* delta pitch = -180 - pitch - ideal pitch

		mov	dx,-256*128
		sub	dx,WPN_Weapon.WPN_PFINE
		sub	dx,ax

		mov	ax,dx

		ABSV	ax		;ax = abs(delta pitch), dx = sign(delta pitch)

;* delta pitch = max(abs(delta pitch), ang rate) * sign(delta pitch)

		cmp	ax,bp		;abs(delta pitch) > ang rate?
		jbe	@F		;no ->
		mov	ax,bp

@@:	  	xor	ax,dx		;restore sign
		sub	ax,dx

;* pitch = pitch + delta pitch

		add	ax,WPN_Weapon.WPN_PFINE

		cmp	ax,-128*128	;pitch < -90 degs?
		jge	@F		;no ->

;* limit pitch and flip hdg

		sub	ax,256*128 	;flip pitch 180 degs
		neg	ax	   	;invert sign

		mov	WPN_Weapon.WPN_PFINE,ax

		sub	WPN_Weapon.WPN_HFINE,256*128	;flip heading 180 degs

		jmp	SortLGBAngles

@@:		mov	WPN_Weapon.WPN_PFINE,ax

;* hdg error = hdg error + 180

		xor	bx,cx		;restore sign
		sub	bx,cx

		add	bx,256*128

		mov	ax,bx

		ABSV	ax

		mov	bx,ax		;bx = abs(hdg error)
		mov	cx,dx		;cx = sign(hdg error)

		jmp	SortLGBHdg

;-------------
;* no flipover
;-------------

;* delta pitch = ideal pitch - pitch
;*
;* delta pitch = max(abs(delta pitch), ang rate) * sign(delta pitch)
;*
;* pitch = max(pitch + delta pitch, -90 degs)

NoLGBFlip:	push	bx		;store abs(hdg error)
		push	cx		;store sign(hdg error)

		mov	bx,WPN_Weapon.WPN_PFINE

		sub	ax,bx		;ideal pitch - pitch

		ABSV	ax		;abs(delta pitch)

		cmp	ax,bp		;abs(delta pitch) > ang rate?
		jbe	@F		;no ->
		mov	ax,bp

@@:	  	xor	ax,dx		;restore sign
		sub	ax,dx

		xchg	ax,bx		;ax = pitch, bx = delta pitch

		add	ax,bx		;pitch + delta pitch

		cmp	ax,-128*128	;< -90 degs?
		jge	@F		;no ->

		mov	ax,-128*128

@@:		mov	WPN_Weapon.WPN_PFINE,ax

		pop	dx		;store sign(hdg error)
		pop	ax		;store abs(hdg error)

;* delta hdg = hdg error
;*
;* delta hdg = max(abs(delta hdg), ang rate) * sign(delta hdg)
;*
;* hdg = hdg + delta hdg

SortLGBHdg:	cmp	ax,bp		;abs(delta hdg) > ang rate?
		jbe	@F		;no ->
		mov	ax,bp

@@:		xor	ax,dx		;restore sign
		sub	ax,dx

		add	WPN_Weapon.WPN_HFINE,ax

;-----------------------------
;* convert fine pdegs to pdegs
;-----------------------------

SortLGBAngles:	mov	cl,7		;/128

;* hdg = hfine / 128

		mov	ax,WPN_Weapon.WPN_HFINE

		shr	ax,cl
		ROUNDUP	ax
		and	ax,001ffh
		mov	WPN_View.VP_HDG,ax

;* pitch = pfine / 128

		mov	ax,WPN_Weapon.WPN_PFINE

		shr	ax,cl
		ROUNDUP	ax
		and	ax,001ffh
		mov	WPN_View.VP_PITCH,ax

		clc			;cf = 0 (still guiding)
		ret

LGBImpact:	stc			;cf = 1 (hit ground / hit hill)
		ret

LGBGuidance	ENDP

;----------------------------------------------------------------------------

;* ShellBallistics - cannon shell movement routine
;*
;* pass: WPN_Workspace
;* ret : cf = 0 = ok
;*	 cf = 1 = hit ground / hit hill (zft > 0)
;* kill: assume all (except cf)

ShellBallistics	PROC	NEAR

;--------------
;* calc delta z
;--------------

;* delta z = v vel * delta time (result as 16 bit whole, 16 bit fraction)

		mov	ax,WPN_Weapon.WPN_CAN_VVEL
		mov	dx,DeltaTime
		imul	dx
		REPT	2		;/4
		sar	dx,1
		rcr	ax,1
		ENDM

		mov	bx,ax
		mov	cx,dx

		mov	ax,cx
		cwd			;dxcx.bx = delta z

		add	WPN_Weapon.WPN_ZFINE,bx
		adc	WORD PTR WPN_View.VP_ZFT_LO,cx
		adc	WORD PTR WPN_View.VP_ZFT_HI,dx

		_JS	ShellHitGnd	;hit ground ->

;--------------------------------
;* calc delta horizontal velocity (dist moved this frame)
;--------------------------------

;* delta h vel = h vel * delta time

		mov	ax,WPN_Weapon.WPN_CAN_HVEL
		mov	dx,DeltaTime
		imul	dx
		FRACADJ	bp		;bp = delta h vel

;-------------
;* move weapon
;-------------

;* calc sin(hdg) and cos(hdg)

ContShellBall:	mov	bx,WPN_View.VP_HDG

		SINCOS	si,di,bx

;* x = x + delta h vel * sin(hdg)

		mov	ax,bp
		imul	si
		REPT	2		;/4
		sar	dx,1
		rcr	ax,1
		ENDM
		add	WPN_Weapon.WPN_XFINE,ax
		adc	dx,0

		mov	cx,dx

;* y = y + delta h vel * cos(hdg)

		mov	ax,bp
		imul	di
		REPT	2		;/4
		sar	dx,1
		rcr	ax,1
		ENDM
		add	WPN_Weapon.WPN_YFINE,ax
		adc	dx,0

		MOVEXY	WPN_View,cx,dx

;----------------------
;* check for hit ground
;----------------------

		mov	ax,WPN_Weapon.WPN_ZFINE
		or	ax,WORD PTR WPN_View.VP_ZFT_LO
		or	ax,WORD PTR WPN_View.VP_ZFT_HI
		_JZ	ShellImpact

;--------------------
;* check for hit hill
;--------------------

		cmp	WORD PTR WPN_View.VP_ZFT_HI,0		;zft > 65535ft?
		ja	@F					;yes ->
		cmp	WORD PTR WPN_View.VP_ZFT_LO,4095	;zft > 4095ft?
		ja	@F					;yes ->

		mov	si,OFFSET WPN_View
		call	CalcGndHeight

		cmp	WORD PTR WPN_View.VP_ZFT_LO,ax	;hit hill?
		jbe	ShellImpact			;yes ->

;----------------------
;* check for hit mobile
;----------------------

;* check for mobiles in sector

@@:		mov	ax,WPN_View.VP_XSEC
		mov	dx,WPN_View.VP_YSEC

		call	LocateMobiles
		jc	ShellOk		;no mobiles in sector ->

;* scan mobiles and collision test

		mov	bp,ShellKillZone

;* check for end of list

ScanMobLoop:	cmp	si,-1
		je	ShellOk

;* check for source of shell (avoid self destruction)

		cmp	si,WPN_Weapon.WPN_CAN_SRC
		je	SkipMob

;* check abs(delta xft) in collision cube

		mov	ax,_VP_XFT[si]
		sub	ax,WPN_View.VP_XFT
		ABSV	ax
		cmp	ax,bp
		ja	SkipMob

;* check abs(delta yft) in collision cube

		mov	ax,_VP_YFT[si]
		sub	ax,WPN_View.VP_YFT
		ABSV	ax
		cmp	ax,bp
		ja	SkipMob

;* check abs(delta zft) in collision cube

		mov	ax,WORD PTR _VP_ZFT_LO[si]
		mov	dx,WORD PTR _VP_ZFT_HI[si]
		sub	ax,WORD PTR WPN_View.VP_ZFT_LO
		sbb	dx,WORD PTR WPN_View.VP_ZFT_HI
		jns	@F
		NEG32	dx,ax
@@:		test	dx,dx
		jnz	SkipMob
		cmp	ax,bp
		ja	SkipMob

;* hit mobile

		mov	di,OFFSET WPN_View

		call	WpnHitTarget

		jmp	ShellOk

;* next mobile

SkipMob: 	mov	si,[si].MOB_LINK_PTR

		jmp	ScanMobLoop

ShellOk:	clc			;cf = 0 (ok)
		ret

ShellImpact:	stc			;cf = 1 (hit ground / hit hill)
		ret

;-----------------
;* shell hit ground (calc impact point)
;-----------------

;* restore zft

ShellHitGnd:   	sub	WPN_Weapon.WPN_ZFINE,bx
		sbb	WORD PTR WPN_View.VP_ZFT_LO,cx
		sbb	WORD PTR WPN_View.VP_ZFT_HI,dx

;* frac = zft / abs(delta z)
;*
;* assume delta z < 0
;* assume zft < 65536

		mov	dx,WORD PTR WPN_View.VP_ZFT_LO
		mov	ax,WPN_Weapon.WPN_ZFINE

		shr	dx,1		;/2 for bin frac
		rcr	ax,1

		neg	cx

		div	cx

;* delta h vel = h vel * frac * delta time

		mov	dx,WPN_Weapon.WPN_CAN_HVEL
		imul	dx
		FRACADJ	dx

		mov	ax,DeltaTime
		imul	dx
		FRACADJ	bp

;* zft = 0

		xor	ax,ax

		mov	WPN_Weapon.WPN_ZFINE,ax
		mov	WORD PTR WPN_View.VP_ZFT_LO,ax
		mov	WORD PTR WPN_View.VP_ZFT_HI,ax

		jmp	ContShellBall

ShellBallistics	ENDP

;----------------------------------------------------------------------------

;* CheckAlarmTimer
;*
;* pass: WPN_Workspace
;* ret : cf = 0 = ok
;*	 cf = 1 = end of lifetime
;* kill: assume all (except cf)

CheckAlarmTimer	PROC	NEAR

;--------------
;* update timer
;--------------

		mov	ax,WPN_Weapon.WPN_ALM_TIMER

		sub	ax,LastFrame	;time up?
		jnc	AlarmTimerOk	;no ->

;* motor burnout or end of lifetime?

		test	WPN_Weapon.WPN_FLAGS,WFLG_BURNOUT
		jnz	AlarmEndLife

;---------------
;* motor burnout
;---------------

		or	WPN_Weapon.WPN_FLAGS,WFLG_BURNOUT

		and	WPN_Mobile.MOB_ANIM,NOT FLAME

		mov	ax,WORD PTR WPN_View.VP_ZFT_LO
		mov	dx,WORD PTR WPN_View.VP_ZFT_HI
		mov	bx,1000

		div 	bx

		cmp	ax,36		;valid up to 36000ft
		jbe	@F
		mov	ax,36

@@:		mov	bx,ax

		shl	bx,1		;bx = decel time index

		mov	bx,AlarmDecelTime[bx]

;* accel[*8] = (1000*8 - vel[*8]) * 100 / decel time[*100]

		mov	ax,1000*8

		mov	dx,WPN_Weapon.WPN_ALM_VEL

;* ensure accel <= 0

		cmp	dx,1000*8
		jae	@F
		mov	dx,1000*8

@@:		sub	ax,dx
		mov	dx,100
		imul	dx
		idiv	bx

		mov	WPN_Weapon.WPN_ALM_ACCEL,ax

		mov	ax,bx

;----------------------
;* set lifetime counter
;----------------------

AlarmTimerOk:	mov	WPN_Weapon.WPN_ALM_TIMER,ax

		clc			;cf = 0 (ok)
		ret

AlarmEndLife:	mov	WPN_Weapon.WPN_ALM_TIMER,0

		stc			;cf = 1 (end of lifetime)
		ret

CheckAlarmTimer	ENDP

;----------------------------------------------------------------------------

;* AlarmGuidance - guide ALARM missile to target
;*
;* pass: WPN_Workspace
;*	 dx, ax = aiming altitude
;* ret : cf = 0 = ok
;*	 cf = 1 = overshot target
;*	 TmpRange = flat range to target
;* kill: assume all (except cf)

AlarmGuidance	PROC	NEAR

;---------------------
;* set aiming altitude
;---------------------

		mov	WORD PTR TMP_VIEW.VP_ZFT_LO,ax
		mov	WORD PTR TMP_VIEW.VP_ZFT_HI,dx

;-----------------
;* update velocity
;-----------------

;* vel = vel + accel * DeltaTime

		mov	ax,WPN_Weapon.WPN_ALM_ACCEL
		mov	dx,DeltaTime
		imul	dx
		FRACADJ	ax

		cwd

		add	ax,WPN_Weapon.WPN_ALM_VEL
		adc	dx,0		;(assuming velocity always >= 0)
		jns	@F		;vel >= 0 ->

;* ensure velocity >= 0

		mov	ax,ALARM_MIN_SPEED

		jmp	SetAlarmVel

;* ensure velocity within limits

@@:		UBOUND	ax,ALARM_MIN_SPEED,32767

SetAlarmVel:	mov	WPN_Weapon.WPN_ALM_VEL,ax

;-----------------------
;* make target viewpoint
;-----------------------

		mov	ax,WPN_Weapon.WPN_ALM_XSEC
		mov	TMP_VIEW.VP_XSEC,ax

		mov	ax,WPN_Weapon.WPN_ALM_YSEC
		mov	TMP_VIEW.VP_YSEC,ax

		mov	ax,WPN_Weapon.WPN_ALM_XFT
		mov	TMP_VIEW.VP_XFT,ax
		
		mov	ax,WPN_Weapon.WPN_ALM_YFT
		mov	TMP_VIEW.VP_YFT,ax
		
;-----------------------------------------
;* calc range (flat) and bearing of target (always calc range)
;-----------------------------------------

		mov	si,OFFSET WPN_View
		mov	di,OFFSET TMP_VIEW

		call	CalcRngBrgVP_VP

		mov	WORD PTR TmpRange,ax
		mov	WORD PTR TmpRange+2,dx

;------------------------------------------
;* inhibit guidance until clear of aircraft
;------------------------------------------

		test	WPN_Weapon.WPN_FLAGS,WFLG_BURNOUT
		jnz	@F

		cmp	WPN_Weapon.WPN_ALM_TIMER,ALARM_BURNTIME-150
		_JA	AlarmGuideOk

;----------------
;* calc hdg error
;----------------

;* if zero range then
;*    hdg error = zero (cases where aiming point is directly above or below)
;* endif

@@:		or	ax,dx		;zero range?
		jz	@F		;yes ->

		mov	ax,bp

		sub	ax,WPN_Weapon.WPN_HFINE

		ABSV	ax

;* if hdg error > 90 degs then overshot target

		cmp	ax,128*128
		_JA	AlarmGuideOver

@@:		push	ax		;abs(hdg error)
		push	dx		;sign(hdg error)

;------------------
;* calc ideal pitch
;------------------

		mov	ax,WORD PTR TmpRange
		mov	dx,WORD PTR TmpRange+2

;* calc delta z (z tgt - z obj)

		mov	bx,WORD PTR TMP_VIEW.VP_ZFT_LO
		mov	cx,WORD PTR TMP_VIEW.VP_ZFT_HI

		sub	bx,WORD PTR WPN_View.VP_ZFT_LO
		sbb	cx,WORD PTR WPN_View.VP_ZFT_HI

		push	cx		;store sign(delta z)

;* calc abs(delta z)

		jns	@F

		NEG32	cx,bx

;* scale range and abs(delta z)

@@:		test	dx,dx
		jz	@F
		shr	dx,1		;range / 2
		rcr	ax,1
		shr	cx,1		;abs(delta z) / 2
		rcr	bx,1
		jmp	@B

@@:		test	cx,cx
		jz	@F
		shr	ax,1		;range / 2
		shr	cx,1		;abs(delta z) / 2
		rcr	bx,1
		jmp	@B

;* select abs(delta z)
;* case = range
;*    pitch = 45
;* case < range
;*    pitch = arctan(abs(delta z) / range)
;* case > range
;*    pitch = 90 - arctan(range / abs(delta z))
;* endselect

@@:		cmp	bx,ax		;select abs(delta z)

		jb	AlarmAimPitch1	;case < range ->
		ja	AlarmAimPitch2	;case > range ->

		mov	bp,64*128	;case 45 degs

		jmp	ContAlarmPitch

;* pitch = arctan(abs(delta z) / range)

AlarmAimPitch1:	xchg	ax,bx

		mov	dx,ax
		xor	ax,ax

		shr	dx,1		;/2 for bin frac result
		rcr	ax,1

		div	bx

		call	FastArcTan

		mov	bp,ax

		jmp	ContAlarmPitch

;* pitch = 90 - arctan(range / abs(delta z))

AlarmAimPitch2:	mov	dx,ax
		xor	ax,ax

		shr	dx,1		;/2 for bin frac result
		rcr	ax,1

		div	bx

		call	FastArcTan

		mov	bp,128*128

		sub	bp,ax

ContAlarmPitch:	pop	ax		;restore sign(delta z)

		cwd

		mov	ax,bp

		xor	ax,dx		;restore sign ideal pitch
		sub	ax,dx

		sub	ax,WPN_Weapon.WPN_PFINE

		ABSV	ax

		push	ax		;store abs(pitch error)
		push	dx		;store sign(pitch error)

;---------------
;* calc max rate
;---------------

;* @ 20g, max rate = (1845 * 20 * 8 * 65536 / 360) / vtas [*8]
;*
;*	  max rate = 3340000h / vtas [*8]

		mov	dx,00334h
		xor	ax,ax

;* if motor not burning then halve max rate

		test	WPN_Weapon.WPN_FLAGS,WFLG_BURNOUT
		jz	@F

		shr	dx,1
		rcr	ax,1

;* vtas = max(vel, 1000 * 8) (prevent overflow)

@@:		mov	bx,WPN_Weapon.WPN_ALM_VEL

		cmp	bx,1000*8
		jae	@F

		mov	bx,1000*8

;* halve max rate again

		shr	dx,1
		rcr	ax,1

@@:		div 	bx

;* calc max rate wrt time

		mov	dx,DeltaTime
		imul	dx
		FRACADJ	bp		;bp = max rate wrt time

;-----------------
;* sort pitch rate
;-----------------

		pop	dx		;restore sign(pitch error)
		pop	ax		;restore abs(pitch error)

;* rate = min(abs(pitch error), max rate wrt time)

		cmp	ax,bp
		jbe	@F

		mov	ax,bp

@@:		xor	ax,dx		;restore sign
		sub	ax,dx

		add	WPN_Weapon.WPN_PFINE,ax

;---------------
;* sort hdg rate
;---------------

		pop	dx		;restore sign(hdg error)
		pop	ax		;restore abs(hdg error)

;* rate = min(abs(hdg error), max rate wrt time)

		cmp	ax,bp
		jbe	@F

		mov	ax,bp

@@:		xor	ax,dx		;restore sign
		sub	ax,dx

		add	WPN_Weapon.WPN_HFINE,ax

;-----------------------------
;* convert fine pdegs to pdegs
;-----------------------------

		mov	cl,7		;/128

;* hdg = hfine / 128

		mov	ax,WPN_Weapon.WPN_HFINE

		shr	ax,cl
		ROUNDUP	ax
		and	ax,001ffh
		mov	WPN_View.VP_HDG,ax

;* pitch = pfine / 128

		mov	ax,WPN_Weapon.WPN_PFINE

		shr	ax,cl
		ROUNDUP	ax
		and	ax,001ffh
		mov	WPN_View.VP_PITCH,ax

AlarmGuideOk:	clc			;cf = 0 (ok)
		ret

AlarmGuideOver:	stc			;cf = 1 (overshot target)
		ret

AlarmGuidance	ENDP

;----------------------------------------------------------------------------

;* AlarmGuideAbove - guide to point above missile (60 degs pitch up)
;*
;* pass: WPN_Workspace
;* ret : cf = 0 = ok
;*	 cf = 1 = overshot target
;*	 TmpRange = flat range to target
;* kill: assume all (except cf)

AlarmGuideAbove	PROC	NEAR

;-------------------------------------------
;* project aiming point for 60 degs pitch up
;-------------------------------------------

;* make working viewpoint

		COPY_VP	TMP_VIEW,WPN_View

;* calc sin(hdg), cos(hdg)

		mov	bx,TMP_VIEW.VP_HDG

		SINCOS	si,di,bx

		mov	cl,7		;/128

;* delta y = 256 * cos(hdg)

		mov	ax,di
		ABSV	ax
		shr	ax,cl
		adc	ax,0
		xor	ax,dx
		sub	ax,dx
		mov	bx,ax

;* delta x = 256 * sin(hdg)

		mov	ax,si
		ABSV	ax
		shr	ax,cl
		adc	ax,0
		xor	ax,dx
		sub	ax,dx
		mov	cx,ax

;* move viewpoint

		MOVEXY	TMP_VIEW,cx,bx

;* set aiming point

		mov	ax,TMP_VIEW.VP_XSEC
		mov	WPN_Weapon.WPN_ALM_XSEC,ax

		mov	ax,TMP_VIEW.VP_YSEC
		mov	WPN_Weapon.WPN_ALM_YSEC,ax

		mov	ax,TMP_VIEW.VP_XFT
		mov	WPN_Weapon.WPN_ALM_XFT,ax

		mov	ax,TMP_VIEW.VP_YFT
		mov	WPN_Weapon.WPN_ALM_YFT,ax

		mov	ax,WORD PTR TMP_VIEW.VP_ZFT_LO
		mov	dx,WORD PTR TMP_VIEW.VP_ZFT_HI

		add	ax,443		;256 * tan(60)
		adc	dx,0

		call	AlarmGuidance

		ret

AlarmGuideAbove	ENDP

;----------------------------------------------------------------------------

;* AlarmGuideBelow - guide to point immediately below missile (pitch up)
;*
;* pass: WPN_Workspace
;* ret : cf = 0 = ok
;*	 cf = 1 = overshot target
;*	 TmpRange = flat range to target
;* kill: assume all (except cf)

AlarmGuideBelow	PROC	NEAR

		mov	ax,WPN_View.VP_XSEC
		mov	WPN_Weapon.WPN_ALM_XSEC,ax

		mov	ax,WPN_View.VP_YSEC
		mov	WPN_Weapon.WPN_ALM_YSEC,ax

		mov	ax,WPN_View.VP_XFT
		mov	WPN_Weapon.WPN_ALM_XFT,ax

		mov	ax,WPN_View.VP_YFT
		mov	WPN_Weapon.WPN_ALM_YFT,ax

		xor	ax,ax
		xor	dx,dx

		call	AlarmGuidance

		ret

AlarmGuideBelow	ENDP

;----------------------------------------------------------------------------

;* AlarmMovement - move ALARM missile
;*
;* pass: WPN_Workspace
;* ret : cf = 0 = ok
;*	 cf = 1 = hit ground / hit hill (zft > 0)
;* kill: assume all (except cf)

AlarmMovement	PROC	NEAR

;----------------------
;* calc h vel and v vel
;----------------------

;* calc sin(pitch) and cos(pitch)

		SINCOS	si,di,WPN_View.VP_PITCH

;* horizontal velocity = vtas * cos(pitch)

		mov	ax,WPN_Weapon.WPN_ALM_VEL
		imul	di
		FRACADJ	di		;di = h vel

;* vertical velocity = vtas * sin(pitch)

		mov	ax,WPN_Weapon.WPN_ALM_VEL
		imul	si
		FRACADJ	si		;si = v vel

;--------------
;* calc delta z
;--------------

;* delta z = v vel * delta time (result as 16 bit whole, 16 bit fraction)

		mov	ax,DeltaTime
		imul	si
		REPT	2		;/4
		sar	dx,1
		rcr	ax,1
		ENDM

		mov	bx,ax
		mov	cx,dx

		mov	ax,cx
		cwd			;dxcx.bx = delta z

		add	WPN_Weapon.WPN_ZFINE,bx
		adc	WORD PTR WPN_View.VP_ZFT_LO,cx
		adc	WORD PTR WPN_View.VP_ZFT_HI,dx

		_JS	AlarmHitGnd	;hit ground ->

;--------------------------------
;* calc delta horizontal velocity (dist moved this frame)
;--------------------------------

;* delta h vel = h vel * delta time

		mov	ax,DeltaTime
		imul	di
		FRACADJ	bp		;bp = delta h vel

;-------------
;* move weapon
;-------------

;* calc sin(hdg) and cos(hdg)

ContAlarmMove:	mov	bx,WPN_View.VP_HDG

		SINCOS	si,di,bx

;* x = x + delta h vel * sin(hdg)

		mov	ax,bp
		imul	si
		REPT	2		;/4
		sar	dx,1
		rcr	ax,1
		ENDM
		add	WPN_Weapon.WPN_XFINE,ax
		adc	dx,0

		mov	cx,dx

;* y = y + delta h vel * cos(hdg)

		mov	ax,bp
		imul	di
		REPT	2		;/4
		sar	dx,1
		rcr	ax,1
		ENDM
		add	WPN_Weapon.WPN_YFINE,ax
		adc	dx,0

		MOVEXY	WPN_View,cx,dx

;----------------------
;* check for hit ground
;----------------------

		mov	ax,WPN_Weapon.WPN_ZFINE
		or	ax,WORD PTR WPN_View.VP_ZFT_LO
		or	ax,WORD PTR WPN_View.VP_ZFT_HI
		jz	AlarmImpact

;--------------------
;* check for hit hill
;--------------------

		cmp	WORD PTR WPN_View.VP_ZFT_HI,0		;zft > 65535ft?
		ja	@F					;yes ->
		cmp	WORD PTR WPN_View.VP_ZFT_LO,4095	;zft > 4095ft?
		ja	@F					;yes ->

		mov	si,OFFSET WPN_View
		call	CalcGndHeight

		cmp	WORD PTR WPN_View.VP_ZFT_LO,ax	;hit hill?
		jbe	AlarmImpact			;yes ->

@@:		clc			;cf = 0 (ok)
		ret

;---------------------------
AlarmImpact	LABEL	NEAR
;---------------------------

		stc			;cf = 1 (hit ground / hit hill)
		ret

;------------------
;* ALARM hit ground (calc impact point)
;------------------

;* restore zft

AlarmHitGnd: 	
        ;SHAKE	SHAKE_DAMAGE,HSHAKE_HI,VSHAKE_HI,50  ;Frankie 6th May 2018	
		
        sub	WPN_Weapon.WPN_ZFINE,bx
		sbb	WORD PTR WPN_View.VP_ZFT_LO,cx
		sbb	WORD PTR WPN_View.VP_ZFT_HI,dx

;* frac = zft / abs(delta z)
;*
;* assume delta z < 0
;* assume zft < 65536

		mov	dx,WORD PTR WPN_View.VP_ZFT_LO
		mov	ax,WPN_Weapon.WPN_ZFINE

		shr	dx,1		;/2 for bin frac
		rcr	ax,1

		neg	cx

		div	cx

;* delta h vel = h vel * frac * delta time

		imul	di
		FRACADJ	dx

		mov	ax,DeltaTime
		imul	dx
		FRACADJ	bp

;* zft = 0

		xor	ax,ax

		mov	WPN_Weapon.WPN_ZFINE,ax
		mov	WORD PTR WPN_View.VP_ZFT_LO,ax
		mov	WORD PTR WPN_View.VP_ZFT_HI,ax

		jmp	ContAlarmMove

AlarmMovement	ENDP

;----------------------------------------------------------------------------

;* AlarmRadarScan - scan for active radar
;*
;* pass: WPN_Workspace
;* ret : cf = 0 = no radar detected
;*	 cf = 1 = radar detected
;* 	    WPN_View.VP_HDG
;*	    WPN_Weapon.WPN_HFINE
;*          WPN_Weapon.WPN_ALM_XSEC	)
;*          WPN_Weapon.WPN_ALM_YSEC	)  target
;*          WPN_Weapon.WPN_ALM_XFT	) position
;*          WPN_Weapon.WPN_ALM_YFT	)
;* kill: assume all (except cf)

AlarmRadarScan	PROC	NEAR

;----------------------------------------
;* check if "no radar" already determined
;----------------------------------------

		test	WPN_Weapon.WPN_FLAGS,WFLG_NO_RADAR
		_JNZ	AlarmRadarFail

;-----------------------------------
;* check if missile is on active map
;-----------------------------------

		cmp	WPN_View.VP_XSEC,31
		_JA	NoRadarTargets
		cmp	WPN_View.VP_YSEC,31
		_JA	NoRadarTargets

;--------------------------------------
;* scan 3*3 sectors for aerial activity
;--------------------------------------

;* y sector scan

		mov	cx,3		;scan count
		mov	di,-1		;scan offset

ScanYLoop1:	push	cx
		push	di

;* x sector scan

		mov	cx,3		;scan count
		mov	si,-1		;scan offset

ScanXLoop1:	push	cx
		push	si
		push	di

;* scan sector (if on active map)

		mov	ax,WPN_View.VP_XSEC
		mov	dx,WPN_View.VP_YSEC

		add	ax,si
		add	dx,di

		cmp	ax,31
		ja	ScanNextSctr1
		cmp	dx,31
		ja	ScanNextSctr1

		call	LocateMobiles	;any mobiles in sector?
		jc	ScanNextSctr1	;no ->

ScanMobiles:	cmp	si,-1		;end of list?
		je	ScanNextSctr1	;yes ->

;* check if mobile alt > 100ft (ignore trucks, trains and parked aircraft)

		cmp	WORD PTR _VP_ZFT_HI[si],0
		ja	AerialActivity
		cmp	WORD PTR _VP_ZFT_LO[si],100
		ja	AerialActivity

		mov	si,[si].MOB_LINK_PTR

		jmp	ScanMobiles

ScanNextSctr1:	pop	di
		pop	si
		pop	cx
		inc	si		;x = x + 1
		loop	ScanXLoop1

		pop	di
		pop	cx
		inc	di		;y = y + 1
		loop	ScanYLoop1

		jmp	AlarmRadarFail

;---------------------------
AerialActivity	LABEL	NEAR
;---------------------------

;* restore stack

		REPT	5
		pop	ax
		ENDM

;----------------------------
;* scan 3*3 sectors for radar
;----------------------------

;* clear radar found flag

		mov	RadarFlag,0

;* set max range to zft (therefore ?5?scan pyramid)

		mov	ax,WORD PTR WPN_View.VP_ZFT_LO
		mov	dx,WORD PTR WPN_View.VP_ZFT_HI

		mov	WORD PTR RadarRange,ax
		mov	WORD PTR RadarRange+2,dx

;* y sector scan

		mov	cx,3		;scan count
		mov	di,-1		;scan offset

ScanYLoop2:	push	cx
		push	di

;* x sector scan

		mov	cx,3		;scan count
		mov	si,-1		;scan offset

ScanXLoop2:	push	cx
		push	si
		push	di

;* scan sector (if on active map)

		mov	ax,WPN_View.VP_XSEC
		mov	bp,WPN_View.VP_YSEC

		add	ax,si
		add	bp,di

		cmp	ax,31
		_JA	ScanNextSctr2
		cmp	bp,31
		_JA	ScanNextSctr2

;* set xsec, ysec

		mov	TMP_VIEW.VP_XSEC,ax
		mov	TMP_VIEW.VP_YSEC,bp

;* map index = ysec * 32 + xsec

		REPT	5
		shl	bp,1
		ENDM

		add	bp,ax

;--------------------------------------
;* check for SAM or AAA radar in sector
;--------------------------------------

		test	SctrGameLayer1[bp],SECT_SAM+SECT_AAA
		_JZ	ContEWRScan

		mov	al,MobRadarLayer1[bp]

		push	bp		;store map index

		CALC_RAD_INDEX

;-----------------
;* check SAM radar
;-----------------

		cmp	RadarTable[bp].RAD_SAM_OFFSET,-1
		je	SkipSAMScan

		push	bp		;store table index

		mov	bp,RadarTable[bp].RAD_SAM_OFFSET

ScanSAMLoop:	cmp	RadarLists[bp],-1 	;end of list?
		je	ExitSAMLoop		;yes ->

		mov	dx,SEG MSctrDataStart
		mov	ds,dx

		mov	si,RadarLists[bp]

		mov	al,[si].STAT_ANIM
		mov	cx,[si].STAT_XFT
		mov	bx,[si].STAT_YFT

		mov	dx,DATA
		mov	ds,dx

		test	al,OBJECT_DEAD	;in play?
		jnz	@F		;no ->

		mov	TMP_VIEW.VP_XFT,cx
		mov	TMP_VIEW.VP_YFT,bx

		push	bp
		call	CheckRadarTgt
		pop	bp

@@:		add	bp,2

		jmp	ScanSAMLoop

ExitSAMLoop: 	pop	bp		;restore table index

;-----------------
;* check AAA radar
;-----------------

SkipSAMScan:	cmp	RadarTable[bp].RAD_AAA_OFFSET,-1
		je	SkipAAAScan

		mov	bp,RadarTable[bp].RAD_AAA_OFFSET

ScanAAALoop:	cmp	RadarLists[bp],-1 	;end of list?
		je	SkipAAAScan		;yes ->

		mov	dx,SEG MSctrDataStart
		mov	ds,dx

		mov	si,RadarLists[bp]

		mov	al,[si].STAT_ANIM
		mov	cx,[si].STAT_XFT
		mov	bx,[si].STAT_YFT

		mov	dx,DATA
		mov	ds,dx

		test	al,OBJECT_DEAD	;in play?
		jnz	@F		;no ->

		mov	TMP_VIEW.VP_XFT,cx
		mov	TMP_VIEW.VP_YFT,bx

		push	bp
		call	CheckRadarTgt
		pop	bp

@@:		add	bp,2

		jmp	ScanAAALoop

SkipAAAScan:	pop	bp		;restore map index

;-------------------------------
;* check for EWR radar in sector (only one EWR in sector)
;-------------------------------

ContEWRScan: 	test	SctrGameLayer1[bp],SECT_EWR
		jz	ScanNextSctr2

		mov	ax,TMP_VIEW.VP_XSEC
		mov	dx,TMP_VIEW.VP_YSEC

		xor	bx,bx
		mov	cx,NUM_EWR*2

ScanEWRLoop:	cmp	EWRTable[bx].EWR_TYPE,-1	;in use?
		je	@F				;no ->

		cmp	al,EWRTable[bx].EWR_XSEC	;xsec match?
		jne	@F				;no ->

		cmp	dl,EWRTable[bx].EWR_YSEC	;ysec match?
		je	EWRFound			;yes ->

@@:		add	bx,EWR_REC_SIZE

		loop	ScanEWRLoop

		jmp	ScanNextSctr2

;----------------------------
;* located EWR, sort wrt type
;----------------------------

EWRFound:	mov	si,EWRTable[bx].EWR_PTR

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

		jmp	ScanNextSctr2

;---------------------------
EWROk		LABEL	NEAR
;---------------------------

		mov	ax,DATA
		mov	ds,ax

		mov	TMP_VIEW.VP_XFT,cx
		mov	TMP_VIEW.VP_YFT,dx

		call	CheckRadarTgt

;-------------
;* next sector
;-------------

ScanNextSctr2:	pop	di
		pop	si
		pop	cx
		inc	si		;x = x + 1
		_LOOP	ScanXLoop2

		pop	di
		pop	cx
		inc	di		;y = y + 1
		_LOOP	ScanYLoop2

		test	RadarFlag,1	;target found?
		jnz	AlarmRadarPass	;yes ->

;---------------------------
NoRadarTargets	LABEL	NEAR
;---------------------------

		or	WPN_Weapon.WPN_FLAGS,WFLG_NO_RADAR

;---------------------------
AlarmRadarFail	LABEL	NEAR
;---------------------------

		clc			;cf = 0 (no radar detected)
		ret

;---------------------------
AlarmRadarPass	LABEL	NEAR
;---------------------------

		stc			;cf = 1 (radar detected)
		ret

AlarmRadarScan	ENDP

;----------------------------------------------------------------------------

;* CheckRadarTgt - check if radar is suitable target, if so, set target etc.
;*
;* pass: TMP_VIEW = target position
;*       WPN_Workspace
;*       RadarRange
;* ret : if suitable target then
;*	    RadarRange
;*	    RadarFlag
;* 	    WPN_View.VP_HDG
;*	    WPN_Weapon.WPN_HFINE
;*          WPN_Weapon.WPN_ALM_XSEC	)
;*          WPN_Weapon.WPN_ALM_YSEC	)  target
;*          WPN_Weapon.WPN_ALM_XFT	) position
;*          WPN_Weapon.WPN_ALM_YFT	)
;* kill: assume all
;*
;* note: Radar shadowing is not considered.

CheckRadarTgt	PROC	NEAR

;* calc range and bearing of radar from missile

		mov	si,OFFSET WPN_View
		mov	di,OFFSET TMP_VIEW

		call	CalcRngBrgVP_VP

;* check if radar is nearer than previous best target

		cmp	dx,WORD PTR RadarRange+2
		ja	ExitRadarTgt
		jb	@F
		cmp	ax,WORD PTR RadarRange
		jae	ExitRadarTgt

;* make new target

@@:		mov	WORD PTR RadarRange,ax
		mov	WORD PTR RadarRange+2,dx

		mov	WPN_View.VP_HDG,bx
		mov	WPN_Weapon.WPN_HFINE,bp

		mov	ax,TMP_VIEW.VP_XSEC
		mov	WPN_Weapon.WPN_ALM_XSEC,ax

		mov	ax,TMP_VIEW.VP_YSEC
		mov	WPN_Weapon.WPN_ALM_YSEC,ax

		mov	ax,TMP_VIEW.VP_XFT
		mov	WPN_Weapon.WPN_ALM_XFT,ax

		mov	ax,TMP_VIEW.VP_YFT
		mov	WPN_Weapon.WPN_ALM_YFT,ax

;* set radar found flag

		mov	RadarFlag,1

ExitRadarTgt:	ret

CheckRadarTgt	ENDP

;----------------------------------------------------------------------------

;* MissileGuidance - guide missile to target
;*
;* pass: WPN_Workspace
;* ret : cf = 0 = ok
;*	 cf = 1 = hit ground / hit hill (zft > 0)
;* kill: assume all (except cf)

MissileGuidance	PROC	NEAR

;-----------------
;* update velocity
;-----------------

;* vel = vel + accel * DeltaTime

		mov	ax,WPN_Weapon.WPN_MISS_ACCEL
		mov	dx,DeltaTime
		imul	dx
		FRACADJ	dx

		add	dx,WPN_Weapon.WPN_MISS_VEL

;* ensure within limits

		cmp	dx,32767
		jbe	@F
		mov	dx,32767

@@:		mov	WPN_Weapon.WPN_MISS_VEL,dx

;-------------------
;* check target lock
;-------------------

		cmp	WPN_Weapon.WPN_MISS_TGT,-1	;target lock?
		_JE	MoveMissile			;no ->

;--------------------------
;* check target still valid
;--------------------------

		mov	si,WPN_Weapon.WPN_MISS_TGT
		call	GetDroneAlive
		_JNC	MissLoseLock

;------------------
;* missile guidance
;------------------

;---------------------------------
;* sort lock wrt IR / radar guided
;---------------------------------

		test	WPN_Weapon.WPN_FLAGS,WFLG_IR_SEEK
		jz	SortRadarLock

;* check IR lock still valid

		mov	si,OFFSET WPN_View

		mov	di,WPN_Weapon.WPN_MISS_TGT
		add	di,MOB_REC_SIZE

		call	CheckIRLock
		_JNC	MissLoseLock

;* IR guided - check for flare release

		mov	si,WPN_Weapon.WPN_MISS_TGT
		call	GetDroneFlare
		jnc	SkipDecoy

;* set random missile distract time

		mov	ax,100		;fixed distract time if two player

		test	TwoPlayer,1
		jnz	@F

		call	RandX		;0.00 .. 2.55 secs
		shr	ax,1		;0.00 .. 1.27 secs
		add	ax,50		;0.50 .. 1.77 secs

@@:		mov	WPN_Weapon.WPN_MISS_DECOY,ax

		jmp	SkipDecoy

;* radar guided - check for chaff release

SortRadarLock:	mov	si,WPN_Weapon.WPN_MISS_TGT
		call	GetDroneChaff
		jnc	SkipDecoy

;* set random missile distract time (less than flare as more chaff available)

		mov	ax,75		;fixed distract time if two player

		test	TwoPlayer,1
		jnz	@F

		call	RandX		;0.00 .. 2.55 secs
		shr	ax,1		;0.00 .. 1.27 secs
		shr	ax,1		;0.00 .. 0.63 secs
		add	ax,50		;0.50 .. 1.13 secs

@@:		mov	WPN_Weapon.WPN_MISS_DECOY,ax

;-------------------
;* check decoy timer
;-------------------

SkipDecoy:	cmp	WPN_Weapon.WPN_MISS_DECOY,0
		je	MissLockOk

		mov	ax,WPN_Weapon.WPN_MISS_DECOY
		sub	ax,LastFrame
		MINM	ax
		mov	WPN_Weapon.WPN_MISS_DECOY,ax

		_JNZ	MoveMissile

;----------------------
;* calc intercept point
;----------------------

MissLockOk:	mov	si,OFFSET WPN_View	;si -> object viewpoint

		mov	di,WPN_Weapon.WPN_MISS_TGT

		add	di,MOB_REC_SIZE		;di -> target viewpoint

		call	CalcSlantRange		;dx, ax = target range

		mov	si,WPN_Weapon.WPN_MISS_TGT

		mov	cx,ax
		call	GetDroneSpeed
		xchg	cx,ax			;cx = target speed

		add	si,MOB_REC_SIZE		;si -> target viewpoint

		mov	bx,WPN_Weapon.WPN_MISS_VEL	;bx = object speed

		mov	di,OFFSET TGT_VIEW	;di -> result viewpoint

		push	bx
		push	cx
		push	si
		push	di

		call	CalcIntercept

		mov	si,OFFSET WPN_View
		mov	di,OFFSET TGT_VIEW

		call	CalcSlantRange

		pop	di
		pop	si
		pop	cx
		pop	bx

		push	bx
		push	cx
		push	si
		push	di

		call	CalcIntercept

		mov	si,OFFSET WPN_View
		mov	di,OFFSET TGT_VIEW

		call	CalcSlantRange

		pop	di
		pop	si
		pop	cx
		pop	bx

		call	CalcIntercept

;--------------------------------------------------
;* calc range (flat) and bearing of intercept point
;--------------------------------------------------

		mov	si,OFFSET WPN_View	;si -> object viewpoint

		mov	di,OFFSET TGT_VIEW	;di -> intercept viewpoint

		call	CalcRngBrgVP_VP

		mov	WORD PTR TmpRange,ax
		mov	WORD PTR TmpRange+2,dx

;----------------
;* calc hdg error
;----------------

		mov	ax,bp

		sub	ax,WPN_Weapon.WPN_HFINE

		ABSV	ax

;* if hdg error > 90 degs then lose lock

		cmp	ax,128*128
		_JA	MissLoseLock

		push	ax		;abs(hdg error)
		push	dx		;sign(hdg error)

;------------------
;* calc ideal pitch
;------------------

		mov	ax,WORD PTR TmpRange
		mov	dx,WORD PTR TmpRange+2

;* calc delta z (z tgt - z obj)

		mov	si,WPN_Weapon.WPN_MISS_TGT

		mov	bx,WORD PTR _VP_ZFT_LO[si]
		mov	cx,WORD PTR _VP_ZFT_HI[si]

		sub	bx,WORD PTR WPN_View.VP_ZFT_LO
		sbb	cx,WORD PTR WPN_View.VP_ZFT_HI

		push	cx		;store sign(delta z)

;* calc abs(delta z)

		jns	@F

		NEG32	cx,bx

;* scale range and abs(delta z)

@@:		test	dx,dx
		jz	@F
		shr	dx,1		;range / 2
		rcr	ax,1
		shr	cx,1		;abs(delta z) / 2
		rcr	bx,1
		jmp	@B

@@:		test	cx,cx
		jz	@F
		shr	ax,1		;range / 2
		shr	cx,1		;abs(delta z) / 2
		rcr	bx,1
		jmp	@B

;* select abs(delta z)
;* case = range
;*    pitch = 45
;* case < range
;*    pitch = arctan(abs(delta z) / range)
;* case > range
;*    pitch = 90 - arctan(range / abs(delta z))
;* endselect

@@:		cmp	bx,ax		;select abs(delta z)

		jb	MissAimPitch1	;case < range ->
		ja	MissAimPitch2	;case > range ->

		mov	bp,64*128	;case 45 degs

		jmp	ContMissPitch

;* pitch = arctan(abs(delta z) / range)

MissAimPitch1:	xchg	ax,bx

		mov	dx,ax
		xor	ax,ax

		shr	dx,1		;/2 for bin frac result
		rcr	ax,1

		div	bx

		call	FastArcTan

		mov	bp,ax

		jmp	ContMissPitch

;* pitch = 90 - arctan(range / abs(delta z))

MissAimPitch2:	mov	dx,ax
		xor	ax,ax

		shr	dx,1		;/2 for bin frac result
		rcr	ax,1

		div	bx

		call	FastArcTan

		mov	bp,128*128

		sub	bp,ax

ContMissPitch:	pop	ax		;restore sign(delta z)

		cwd

		mov	ax,bp

		xor	ax,dx		;restore sign ideal pitch
		sub	ax,dx

		sub	ax,WPN_Weapon.WPN_PFINE

		ABSV	ax

		push	ax		;store abs(pitch error)
		push	dx		;store sign(pitch error)

;---------------
;* calc max rate
;---------------

;* @ 20g, max rate = (1845 * 20 * 8 * 65536 / 360) / vtas [*8]
;*
;*	  max rate = 3340000h / vtas [*8]

		mov	dx,00334h
		xor	ax,ax

;* if motor not burning then halve max rate

		test	WPN_Weapon.WPN_FLAGS,WFLG_BURNOUT
		jnz	@F

		shr	dx,1
		rcr	ax,1

;* vtas = max(vel, 1000 * 8) (prevent overflow)

@@:		mov	bx,WPN_Weapon.WPN_MISS_VEL

		cmp	bx,1000*8
		jae	@F

		mov	bx,1000*8

@@:		div 	bx

;* calc max rate wrt time

		mov	dx,DeltaTime
		imul	dx
		FRACADJ	bp		;bp = max rate wrt time

;-----------------
;* sort pitch rate
;-----------------

		pop	dx		;restore sign(pitch error)
		pop	ax		;restore abs(pitch error)

;* rate = min(abs(pitch error), max rate wrt time)

		cmp	ax,bp
		jbe	@F

		mov	ax,bp

@@:		xor	ax,dx		;restore sign
		sub	ax,dx

		add	WPN_Weapon.WPN_PFINE,ax

;---------------
;* sort hdg rate
;---------------

		pop	dx		;restore sign(hdg error)
		pop	ax		;restore abs(hdg error)

;* rate = min(abs(hdg error), max rate wrt time)

		cmp	ax,bp
		jbe	@F

		mov	ax,bp

@@:		xor	ax,dx		;restore sign
		sub	ax,dx

		add	WPN_Weapon.WPN_HFINE,ax

;-----------------------------
;* convert fine pdegs to pdegs
;-----------------------------

		mov	cl,7		;/128

;* hdg = hfine / 128

		mov	ax,WPN_Weapon.WPN_HFINE

		shr	ax,cl
		ROUNDUP	ax
		and	ax,001ffh
		mov	WPN_View.VP_HDG,ax

;* pitch = pfine / 128

		mov	ax,WPN_Weapon.WPN_PFINE

		shr	ax,cl
		ROUNDUP	ax
		and	ax,001ffh
		mov	WPN_View.VP_PITCH,ax

		jmp	MoveMissile

;---------------------------
MissLoseLock	LABEL	NEAR
;---------------------------

		mov	WPN_Weapon.WPN_MISS_TGT,-1

		and	WPN_Weapon.WPN_FLAGS,NOT WFLG_TLOCK

;---------------------------
MoveMissile	LABEL	NEAR
;---------------------------

;----------------------
;* calc h vel and v vel
;----------------------

;* calc sin(pitch) and cos(pitch)

		SINCOS	si,di,WPN_View.VP_PITCH

;* horizontal velocity = vtas * cos(pitch)

		mov	ax,WPN_Weapon.WPN_MISS_VEL
		imul	di
		FRACADJ	di		;di = h vel

;* vertical velocity = vtas * sin(pitch)

		mov	ax,WPN_Weapon.WPN_MISS_VEL
		imul	si
		FRACADJ	si		;si = v vel

;--------------
;* calc delta z
;--------------

;* delta z = v vel * delta time (result as 16 bit whole, 16 bit fraction)

		mov	ax,DeltaTime
		imul	si
		REPT	2		;/4
		sar	dx,1
		rcr	ax,1
		ENDM

		mov	bx,ax
		mov	cx,dx

		mov	ax,cx
		cwd			;dxcx.bx = delta z

		add	WPN_Weapon.WPN_ZFINE,bx
		adc	WORD PTR WPN_View.VP_ZFT_LO,cx
		adc	WORD PTR WPN_View.VP_ZFT_HI,dx

		_JS	MissileHitGnd	;hit ground ->

;--------------------------------
;* calc delta horizontal velocity (dist moved this frame)
;--------------------------------

;* delta h vel = h vel * delta time

		mov	ax,DeltaTime
		imul	di
		FRACADJ	bp		;bp = delta h vel

;-------------
;* move weapon
;-------------

;* calc sin(hdg) and cos(hdg)

ContMissMove:	mov	bx,WPN_View.VP_HDG

		SINCOS	si,di,bx

;* x = x + delta h vel * sin(hdg)

		mov	ax,bp
		imul	si
		REPT	2		;/4
		sar	dx,1
		rcr	ax,1
		ENDM
		add	WPN_Weapon.WPN_XFINE,ax
		adc	dx,0

		mov	cx,dx

;* y = y + delta h vel * cos(hdg)

		mov	ax,bp
		imul	di
		REPT	2		;/4
		sar	dx,1
		rcr	ax,1
		ENDM
		add	WPN_Weapon.WPN_YFINE,ax
		adc	dx,0

		MOVEXY	WPN_View,cx,dx

;----------------------
;* check for hit ground
;----------------------

		mov	ax,WPN_Weapon.WPN_ZFINE
		or	ax,WORD PTR WPN_View.VP_ZFT_LO
		or	ax,WORD PTR WPN_View.VP_ZFT_HI
		_JZ	MissileImpact

;--------------------
;* check for hit hill
;--------------------

		cmp	WORD PTR WPN_View.VP_ZFT_HI,0		;zft > 65535ft?
		ja	@F					;yes ->
		cmp	WORD PTR WPN_View.VP_ZFT_LO,4095	;zft > 4095ft?
		ja	@F					;yes ->

		mov	si,OFFSET WPN_View
		call	CalcGndHeight

		cmp	WORD PTR WPN_View.VP_ZFT_LO,ax	;hit hill?
		_JBE	MissileImpact			;yes ->

;---------------------
;* check if hit target
;---------------------

;* if target lock valid and weapon not distracted then
;*    if flat range to intercept point < missile vel then (< 4 secs to impact)
;*       if abs(intercept zft - missile zft) < missile vel then (< 4 secs to impact)
;*          calc range and bearing of intercept point
;*          if heading error > 90 degs then (gone through intercept point)
;*             calc slant range of target from intercept point
;*             if range within lethal range then
;*                hit target
;*             endif
;*          endif
;*       endif
;*    endif
;* endif

;* check target lock valid

@@:		cmp	WPN_Weapon.WPN_MISS_TGT,-1
		_JE	MissileOk

;* check weapon not distracted (else TmpRange not valid)

		cmp	WPN_Weapon.WPN_MISS_DECOY,0
		_JA	MissileOk

;* check intercept point range < 65536ft

		cmp	WORD PTR TmpRange+2,0
		ja	MissileOk

;* calc dist travelled in 4 seconds
	
		mov	bp,WPN_Weapon.WPN_MISS_VEL

		shr	bp,1

;* check range <= 4 seconds to impact point

		cmp	WORD PTR TmpRange,bp
		ja	MissileOk

;* calc abs(zdiff) = abs(intercept zft - missile zft)

		mov	ax,WORD PTR TGT_VIEW.VP_ZFT_LO
		mov	dx,WORD PTR TGT_VIEW.VP_ZFT_HI

		sub	ax,WORD PTR WPN_View.VP_ZFT_LO
		sbb	dx,WORD PTR WPN_View.VP_ZFT_HI
		jns	@F

		NEG32	dx,ax

;* check abs(zdiff) <= 4 seconds to impact point

@@:		test	dx,dx
		jnz	MissileOk
		cmp	ax,bp
		ja	MissileOk

;* inform target that missile is locked and close

		call	MorseDashSound 
		call	SetDroneWpnLock 
        
		
;* calc range (flat) and bearing of intercept point

		mov	si,OFFSET WPN_View
		mov	di,OFFSET TGT_VIEW
		call	CalcRngBrgVP_VP

;* calc abs(hdg error)

		mov	ax,bp

		sub	ax,WPN_Weapon.WPN_HFINE

		ABSV	ax

;* if abs(hdg error) > 90 degs then gone through intercept point

		cmp	ax,128*128
		jbe	MissileOk

;* calc slant range of target from intercept point

		mov	si,OFFSET TGT_VIEW
		mov	di,WPN_Weapon.WPN_MISS_TGT
		add	di,MOB_REC_SIZE
		call	CalcSlantRange

;* check if within lethal range

		test	dx,dx
		jnz	MissileOk
		cmp	ax,100
		ja	MissileOk

;------------
;* hit target
;------------

		mov	si,WPN_Weapon.WPN_MISS_TGT
		mov	di,OFFSET TGT_VIEW	;explosion at intercept point

		call	WpnHitTarget

;* lose lock (else explosion shows up on Tornado RWR)

		mov	WPN_Weapon.WPN_MISS_TGT,-1

		and	WPN_Weapon.WPN_FLAGS,NOT WFLG_TLOCK

;---------------------------
MissileOk	LABEL	NEAR
;---------------------------

		clc			;cf = 0 (ok)
		ret

;---------------------------
MissileImpact	LABEL	NEAR
;---------------------------

		stc			;cf = 1 (hit ground / hit hill)
		ret

;--------------------
;* missile hit ground (calc impact point)
;--------------------

;* restore zft

MissileHitGnd: 	sub	WPN_Weapon.WPN_ZFINE,bx
		sbb	WORD PTR WPN_View.VP_ZFT_LO,cx
		sbb	WORD PTR WPN_View.VP_ZFT_HI,dx

;* frac = zft / abs(delta z)
;*
;* assume delta z < 0
;* assume zft < 65536

		mov	dx,WORD PTR WPN_View.VP_ZFT_LO
		mov	ax,WPN_Weapon.WPN_ZFINE

		shr	dx,1		;/2 for bin frac
		rcr	ax,1

		neg	cx

		div	cx

;* delta h vel = h vel * frac * delta time

		imul	di
		FRACADJ	dx

		mov	ax,DeltaTime
		imul	dx
		FRACADJ	bp

;* zft = 0

		xor	ax,ax

		mov	WPN_Weapon.WPN_ZFINE,ax
		mov	WORD PTR WPN_View.VP_ZFT_LO,ax
		mov	WORD PTR WPN_View.VP_ZFT_HI,ax

		jmp	ContMissMove

MissileGuidance	ENDP

;----------------------------------------------------------------------------

;* CreateBomblet - create bomblet for BL755
;*
;* pass: WPN_Workspace
;* ret : cf = 0: bomblet created
;*       cf = 1: bomblet not created (no weapon available)
;* kill: assume all (except cf)
;*
;* note: Some bomblets may be created ahead of the BL775 in the weapon buffer
;*       and will therefore be updated later this frame, and some will be
;*       created behind the BL755 and will not be updated until next frame.
;*	 But this does not matter because of the random scattering of the
;*       bomblets.

CreateBomblet	PROC	NEAR

		call	FindAvailWeapon
		jc	ExitBomblet	;no weapon available ->

;--------------------------------------
;* copy datum BL755 data from workspace
;--------------------------------------

		mov	ax,WPNDATA
		mov	es,ax

		push	si

		mov	di,si
		mov	si,OFFSET WPN_Workspace
		mov	cx,WPN_DATA_SIZE
		FAST_MOVE

		pop	si

;-------------------
;* modify parameters
;-------------------

;* note: It is safe to call RandX with ES pointing away from DATA segment.

		mov	ES:MOB_NUM[si],MOB_BOMBLET

		mov	ES:MOB_ANIM[si],0

		or	ES:_WPN_FLAGS[si],WFLG_BOMBLET

;* modify hdg (-3 .. +3 pdegs)

		call	RandX
		cbw
		and	al,003h
		xor	al,ah
		sub	al,ah
		cbw

		add	ES:_VP_HDG[si],ax
		and	ES:_VP_HDG[si],511

;* modify vertical velocity (-16 .. +16 ft/sec)

		call	RandX
		cbw
		and	al,07fh
		xor	al,ah
		sub	al,ah
		cbw

		add	ES:_WPN_BOMB_VVEL[si],ax	

;* modify horizontal velocity (0 .. +128 ft/sec)

		call	RandX
		REPT	2
		shl	ax,1
		ENDM

		add	ES:_WPN_BOMB_HVEL[si],ax	

		mov	ax,WPNDATA
		mov	es,ax

		clc			;cf = 0 (weapon created)
		
ExitBomblet:	ret

CreateBomblet	ENDP

;----------------------------------------------------------------------------

;* GroundDamage - ground damage (common to all weapons)
;*
;* pass: WPN_Workspace
;* ret : nothing
;* kill: assume all

GroundDamage	PROC	NEAR

;----------------------
;* make explosion sound (if in audible range)
;----------------------

;* calc slant range from Tornado to explosion
;*
;* if cannon then
;*    if range <= 5280 then
;*       make explosion sound 3
;*    endif
;* else
;*    inner range = 16383 (approx 3 miles)
;*    outer range = 32767 (approx 6 miles)
;*    select range
;*    case <= inner range
;*       if in cockpit then
;*          make explosion sound 2
;*       else
;*          make explosion sound 1
;*       endif
;*    case <= outer range
;*       if not in cockpit then
;*          make explosion sound 2
;*       endif
;*    endselect
;* endif

		mov	si,OFFSET M_VIEW
		mov	di,OFFSET WPN_View
		call	CalcSlantRange

		test	dx,dx		;range > 65535?
		jnz	ExploSoundOk	;yes ->

		cmp	WPN_Weapon.WPN_TYPE,CANNON
		jne	@F

		cmp	ax,5280		;within range?
		ja	ExploSoundOk	;no ->

		call	ExploSound3

		jmp	ExploSoundOk

@@:		mov	bx,16383	;inner range
		mov	cx,32767	;outer range
	
		cmp	ax,cx		;within outer range?
		ja	ExploSoundOk	;no ->

		cmp	ax,bx		;within inner range?
		jb	@F		;yes ->

		test	InCockpit,1	;in cockpit?
		jnz	ExploSoundOk	;yes ->

		call	ExploSound2

		jmp	ExploSoundOk

@@:		test	InCockpit,1	;in cockpit?
		jz	@F		;no ->

		call	ExploSound2

		jmp	ExploSoundOk

@@:		call	ExploSound1

ExploSoundOk:

;---------------------
;* hit ground or hill?
;---------------------

;* if hit hill (zft > 0) then make crater only

		mov	ax,WORD PTR WPN_View.VP_ZFT_LO	
		or	ax,WORD PTR WPN_View.VP_ZFT_HI
		jnz	ContCrater

;-------------------
;* weapon hit ground
;-------------------

		mov	si,OFFSET WPN_View
		call	SurfaceCheck

		mov	ImpactSurface,ax

;* if Tornado weapon then store impact point

		test	WPN_Weapon.WPN_FLAGS,WFLG_TORNADO
		jz	@F

		call	StoreImpact

@@:		call	ProximityKill

;-------------------------
;* splash if land in water
;-------------------------

		mov	dx,ImpactSurface

		cmp	dx,SURFACE_RIVER
		je	WeaponSplash
		cmp	dx,SURFACE_LAKE
		je	WeaponSplash

;---------------
;* make a crater (wrt weapon)
;---------------

;* make heave if JP233 lands on hard surface

		cmp	WPN_Weapon.WPN_TYPE,JP233
		jne	ContCrater

		mov	al,CRATER_HEAVE

		cmp	dx,SURFACE_RUNWAY
		je	ContHeave
		cmp	dx,SURFACE_TAXIWAY
		je	ContHeave
		cmp	dx,SURFACE_HARD
		je	ContHeave
		cmp	dx,SURFACE_ROAD
		je	ContHeave

ContCrater:	mov	bx,WPN_Weapon.WPN_TYPE
		shr	bx,1
		mov	al,CraterSize[bx]
ContHeave:	mov	si,OFFSET WPN_View
		call	MakeCrater

		mov	bx,WPN_Weapon.WPN_TYPE
		mov	bx,CraterSmoke[bx]
		mov	si,OFFSET WPN_View
		call	MakeSmokeEffect

;--------------------
;* sort runway damage
;--------------------

		cmp	ImpactSurface,SURFACE_RUNWAY
		jne	@F

		call	RecordRwyDamage

;-------------------------
;* weapon no longer in use
;-------------------------

@@:		mov	WPN_Weapon.WPN_TYPE,NULL_WEAPON

		ret

;---------------------------
WeaponSplash	LABEL	NEAR
;---------------------------

		or	WPN_Weapon.WPN_FLAGS,WFLG_SPLASH

		mov	WPN_Mobile.MOB_NUM,MOB_SPLASH
		mov	WPN_Mobile.MOB_TYPE,OTYPE_MOBILE1
		mov	WPN_Mobile.MOB_ANIM,SPLASH1

		ret

GroundDamage	ENDP

;----------------------------------------------------------------------------

;* RecordRwyDamage - record runway damage
;*
;* pass: WPN_WorkSpace
;* ret : nothing
;* kill: assume all

RecordRwyDamage	PROC	NEAR

		mov	ax,WPN_View.VP_XSEC
		mov	dx,WPN_View.VP_YSEC

		mov	bx,OFFSET RunwayDamage
		mov	cx,NUM_RUNWAYS

RwyLoop:	cmp	[bx].RDAM_XSEC,-1	;record in use?
		je	NewRwy			;no ->

		cmp	[bx].RDAM_XSEC,ax	;xsec match?
		jne	NextRwy			;no ->
	       	cmp	[bx].RDAM_YSEC,dx	;ysec match?
		jne	NextRwy			;no ->

		jmp	SameRwy

NewRwy:		mov	[bx].RDAM_XSEC,ax
		mov	[bx].RDAM_YSEC,dx

SameRwy:	inc	[bx].RDAM_HITS

		jmp	ExitRwyDamage

NextRwy:	add	bx,RDAM_REC_SIZE

		loop	RwyLoop

ExitRwyDamage:	ret

RecordRwyDamage	ENDP

;----------------------------------------------------------------------------

;* WpnHitTarget - weapon hit target (kill target, check Tornado, explode etc.)
;*
;* pass: si -> target drone MOBILE + VIEWPOINT + control data
;*	       (-1 = self destruct)
;*       di -> explosion VIEWPOINT
;*             (possibly different to target (ie. intercept point, self destruct))
;*       WPN_WorkSpace
;* ret : nothing
;* kill: assume all
;*
;* note: This routine is intended for use with missiles and cannon shells.

WpnHitTarget	PROC	NEAR

;-------------------------
;* check for self destruct (no target to kill)
;-------------------------

		cmp	si,-1
		je	@F
		
;-------------
;* kill target
;-------------

		push	si
		push	di
		call	WpnKillDrone
		pop	di
		pop	si

;-----------------------------------------------------
;* if Tornado is target then just make explosion sound
;-----------------------------------------------------

		cmp	si,OFFSET M_MOBILE
		je	WpnHitSound

;---------------------------------
;* calc Tornado range to explosion (sound effect, destroyed, damaged)
;---------------------------------

@@:		mov	si,OFFSET M_VIEW            ;save this line! Try to change M_VIEW to REM_VIEW and to SPEC_VIEW

		push	di
		call	CalcSlantRange
		pop	di

		test	dx,dx		;range < 65536ft?
		jnz	WpnHitSmoke	;no ->

		cmp	ax,250		;within damage radius?
		ja	@F		;no ->

		SHAKE	SHAKE_DAMAGE,HSHAKE_HI,VSHAKE_HI,50 ;ori

		test	NoCollisions,1	;no collisions enabled?
		jnz	@F		;yes ->

		push	ax
		push	di
		call	MaxDamage
		pop	di
		pop	ax

		cmp	ax,100		;within lethal radius?
		ja	@F		;no ->

		push	ax
		push	di
		DESTROY	DIE_AIR_EXPLO,TOTAL_DAMAGE ;perhaps this code is key
		pop	di
		pop	ax

@@:		cmp	ax,32767	;within audible range (approx 6 miles)?
		ja	WpnHitSmoke	;no ->

;-------------------
;* make sound effect
;-------------------
 
WpnHitSound:	push	di
		SHAKE	SHAKE_DAMAGE,HSHAKE_HI,VSHAKE_HI,50 ;added in for extra measure - frankie kam hack (31/12/17)
		pop	di

;-------------------
;* make smoke effect
;-------------------

WpnHitSmoke:	mov	bx,SMOKE_AIR_EXPLO

		mov	si,di

		push	di
		call	MakeSmokeEffect
		pop	di

;--------------------------------------
;* convert weapon to airburst animation (at explosion point)
;--------------------------------------

;* if explosion point different to weapon then move weapon to explosion

		cmp	di,OFFSET WPN_View
		je	@F

		mov	ax,[di].VP_XSEC
		mov	WPN_View.VP_XSEC,ax

		mov	ax,[di].VP_YSEC
		mov	WPN_View.VP_YSEC,ax

		mov	ax,[di].VP_XFT
		mov	WPN_View.VP_XFT,ax

		mov	ax,[di].VP_YFT
		mov	WPN_View.VP_YFT,ax

		mov	ax,WORD PTR [di].VP_ZFT_LO
		mov	WORD PTR WPN_View.VP_ZFT_LO,ax

		mov	ax,WORD PTR [di].VP_ZFT_HI
		mov	WORD PTR WPN_View.VP_ZFT_HI,ax

@@:		call	CreateAirburst

		ret

WpnHitTarget	ENDP

;----------------------------------------------------------------------------

;* UpdateSplash - two stage splash animation
;*
;* pass: WPN_Workspace
;* ret : nothing
;* kill: assume all

UpdateSplash	PROC	NEAR

 		test	WPN_Mobile.MOB_ANIM,SPLASH1	;done stage 2?
		jz	@F				;yes ->

		and	WPN_Mobile.MOB_ANIM,NOT SPLASH1

		jmp	ExitSplash

@@:		mov	WPN_Weapon.WPN_TYPE,NULL_WEAPON

ExitSplash:	ret

UpdateSplash	ENDP

;----------------------------------------------------------------------------

;* CreateAirburst - start airburst animation
;*
;* pass: WPN_Workspace
;* ret : nothing
;* kill: assume all

CreateAirburst	PROC	NEAR

;* init MOBILE <>

		mov	WPN_Mobile.MOB_NUM,MOB_AIRBURST
		mov	WPN_Mobile.MOB_TYPE,OTYPE_MOBILE3
		mov	WPN_Mobile.MOB_ANIM,AIRBURST1

;* init WEAPON <>

		or	WPN_Weapon.WPN_FLAGS,WFLG_AIRBURST

		ret

CreateAirburst	ENDP

;----------------------------------------------------------------------------

;* UpdateAirburst - airburst animation
;*
;* pass: WPN_Workspace
;* ret : nothing
;* kill: assume all

UpdateAirburst	PROC	NEAR

;* next animation stage

		sub	WPN_Mobile.MOB_ANIM,1
		jnc	@F

;* end of animation

		mov	WPN_Weapon.WPN_TYPE,NULL_WEAPON

@@:		ret

UpdateAirburst	ENDP

;----------------------------------------------------------------------------

;* WeaponsControl - Tornado weapons control
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all
;*
;* note: This routine must be called after all of the drones have been
;*	 updated.

WeaponsControl	PROC	FAR

;------------
;* initialize
;------------

;* assume cannon not fired

		mov	CannonFired,0

		UNSHAKE SHAKE_CANNON ;ori

;* assume no IR lock

		mov	IRLockFlag,0

;* assume RWR target not valid

		mov	RWRTgtValid,0

;* assume no chaff or flare released this frame

		mov	RelChaff,0
		mov	RelFlare,0

;* assume no missile launched this frame

		mov	MissileTgtPtr,-1

;--------------------
;* select arming mode
;--------------------

		test	ArmLock,1	;release in progress?
		_JNZ	LateArmSwitch	;yes ->

;------------
;* arm cancel
;------------

		KTEST	KF_ArmOff
		jz	SkipArmOff

		mov	ArmMode,ARM_OFF

		jmp	SkipArmGnd

;------------------------
;* arm air-to-air weapons
;------------------------

SkipArmOff:	KTEST	KF_ArmAir
		jz	SkipArmAir

		mov	ax,AirArmMode

		mov	ArmMode,ax

		jmp	SkipArmGnd

;---------------------------
;* arm air-to-ground weapons
;---------------------------

SkipArmAir:	KTEST	KF_ArmGnd
		jz	SkipArmGnd

		mov	si,PackagePtr

		cmp	si,-1		;any packages?
		je	SkipArmGnd	;no ->

		mov	ax,[si].PACK_WEAP_MODE

		mov	ArmMode,ax

;------------------------
;* select next air weapon
;------------------------
			   
SkipArmGnd:	KFETCH	KF_AirWeapon
		or	al,JoyA_JustFired2
		jz	@F

		call	SelectAirWpn

;---------------------
;* select next package
;---------------------

@@:	 	KTEST	KF_Package
		jz	SkipPackage

		mov	si,PackagePtr

		cmp	si,-1		;any packages?
		je	SkipPackage	;no ->

		mov	ax,[si].PACK_WEAP_MODE
		cmp	ax,ArmMode	;package armed?
		je	SkipPackage	;yes ->

		call	SelectNextPack

;-----------------------------
;* select weapon delivery mode
;-----------------------------

SkipPackage: 	KTEST	KF_WpnMode
		_JZ	LateArmSwitch

		mov	si,PackagePtr
		
		cmp	si,-1		;any packages?
		_JE	LateArmSwitch	;no ->

		mov	ax,[si].PACK_WEAP_MODE
		cmp	ax,ArmMode	;package armed?
		_JE	LateArmSwitch	;yes ->

;* GPB1000 modes (manual / laydown / loft)

		cmp	[si].PACK_WEAP_TYPE,GPB1000	;GPB1000?
		jne	@F				;no ->

		mov	ax,ARM_LAYDOWN
		cmp	[si].PACK_WEAP_MODE,ARM_MANUAL
		je	SetWpnMode

		mov	ax,ARM_LOFT
		cmp	[si].PACK_WEAP_MODE,ARM_LAYDOWN
		je	SetWpnMode

		mov	ax,ARM_MANUAL

		jmp	SetWpnMode

;* RET1000 modes (manual / laydown)

@@: 		cmp	[si].PACK_WEAP_TYPE,RET1000	;RET1000?
		jne	@F				;no ->

		mov	ax,ARM_LAYDOWN
		cmp	[si].PACK_WEAP_MODE,ARM_MANUAL
		je	SetWpnMode

		mov	ax,ARM_MANUAL

		jmp	SetWpnMode

;* LGB1000 modes (manual / laydown / loft / laser guided)

@@:		cmp	[si].PACK_WEAP_TYPE,LGB1000	;LGB1000?
		jne	@F				;no ->

		mov	ax,ARM_LAYDOWN
		cmp	[si].PACK_WEAP_MODE,ARM_MANUAL
		je	SetWpnMode

		mov	ax,ARM_LOFT
		cmp	[si].PACK_WEAP_MODE,ARM_LAYDOWN
		je	SetWpnMode

		mov	ax,ARM_LGB
		cmp	[si].PACK_WEAP_MODE,ARM_LOFT
		je	SetWpnMode

		mov	ax,ARM_MANUAL

		jmp	SetWpnMode

;* BL755 modes (manual / laydown)

@@:		cmp	[si].PACK_WEAP_TYPE,BL755	;BL755?
		jne	@F				;no ->

		mov	ax,ARM_LAYDOWN
		cmp	[si].PACK_WEAP_MODE,ARM_MANUAL
		je	SetWpnMode

		mov	ax,ARM_MANUAL

		jmp	SetWpnMode

;* ALARM modes (direct / indirect)

@@:		cmp	[si].PACK_WEAP_TYPE,ALARM	;ALARM?
		jne	LateArmSwitch			;no ->

		mov	ax,ARM_ALARM_DIR
		cmp	[si].PACK_WEAP_MODE,ARM_ALARM_IND
		je	SetWpnMode

		mov	ax,ARM_ALARM_IND

SetWpnMode:	mov	[si].PACK_WEAP_MODE,ax

;---------------------------
LateArmSwitch	LABEL	NEAR		;update late arming switch animation
;---------------------------

;* if ArmMode = ARM_OFF then
;*    LateArmAnim = max(LateArmAnim - 1, 0)
;* else
;*    LateArmAnim = min(LateArmAnim + 1, 3)
;* endif

		mov	al,LateArmAnim

		cmp	ArmMode,ARM_OFF	;off?
		jne	@F		;no ->

		test	al,al		;already min?
		jz	SkipLateArm	;yes ->

		dec	al

		jmp	SetLateArm

@@:		cmp	al,3		;already max?
		je	SkipLateArm	;yes ->

		inc	al

SetLateArm:	mov	LateArmAnim,al

;-----------------------------
;* sort weapon wrt arming mode
;-----------------------------

SkipLateArm:	mov	bx,ArmMode
		
		jmp	ArmSwitch[bx]

;---------------------------
ArmManual     	LABEL	NEAR
;---------------------------

;* calc throw

		mov	si,PackagePtr

		mov	ax,Vtas
		mov	bx,[si].PACK_WEAP_TYPE
		mov	si,OFFSET M_VIEW
		call	CalcThrow

;* calc impact point

		mov	si,OFFSET M_VIEW
		call	CalcBombCCIP

;* test for weapon release

		KFETCH	KF_WpnFire
		or	al,JoyA_JustFired1	;release package?
		jz	SkipManual		;no ->

;* release interlock

		cmp	M_CosR,0	;aircraft erect?
		jl	SkipManual	;no ->
		test	Airborne1,1	;aircraft airborne?
		jz	SkipManual	;no ->

;* release package

		mov	si,PackagePtr

		mov	ax,Vtas
		mov	bx,[si].PACK_WEAP_TYPE
		mov	cx,[si].PACK_WEAP_NUM
		mov	dl,1		;Tornado release
		mov	si,OFFSET M_VIEW
		mov	di,-1		;target waypoint not applicable
		call	ReleasePackage
		jc	SkipManual	;package not released ->

;* disarm (clear package, update weight, select next package etc.)

		mov	ArmMode,ARM_OFF

		test	InfiniteWeapons,1	;infinite weapons?
		jnz	SkipManual		;yes ->

		mov	si,PackagePtr

		mov	bx,[si].PACK_WEAP_TYPE
		mov	bx,ExtStoresIndex[bx]
		mov	ax,ExtStores[bx]
		sub	ax,[si].PACK_WEAP_NUM
		MINM	ax
		mov	ExtStores[bx],ax

		mov	[si].PACK_WEAP_TYPE,NULL_WEAPON
		mov	[si].PACK_WEAP_NUM,0

		call	SelectNextPack

SkipManual: 	jmp	ArmOk

;---------------------------
ArmLaydown     	LABEL	NEAR
;---------------------------

;* check target valid

		cmp	WayTotal,0	;any waypoints?
		ja	@F		;yes ->

		cmp	WPPtr,OFFSET FloatWP	;floating waypoint selected?
		je	@F			;yes ->

		mov	ArmMode,ARM_OFF

		jmp	SkipLaydown

;* make target viewpoint (every frame in case target changes)

@@:		mov	si,WPPtr

		mov	ax,[si].WP_XSEC
		mov	TGT_VIEW.VP_XSEC,ax

		mov	ax,[si].WP_YSEC
		mov	TGT_VIEW.VP_YSEC,ax

		mov	ax,[si].WP_XFT
		mov	TGT_VIEW.VP_XFT,ax

		mov	ax,[si].WP_YFT
		mov	TGT_VIEW.VP_YFT,ax

		xor	ax,ax

		mov	WORD PTR TGT_VIEW.VP_ZFT_LO,ax
		mov	WORD PTR TGT_VIEW.VP_ZFT_HI,ax

;* calc throw

		mov	si,PackagePtr

		mov	ax,Vtas
		mov	bx,[si].PACK_WEAP_TYPE
		mov	si,OFFSET M_VIEW
		call	CalcThrow

;* calc impact point

		mov	si,OFFSET M_VIEW
		call	CalcBombCCIP

;* test for weapon commit

		KFETCH	KF_WpnCommit
		or	al,JoyA_Fire1	;commit package?
		_JZ	SkipLaydown	;no ->

;* release interlock

		cmp	M_CosR,0	;aircraft erect?
		_JL	SkipLaydown	;no ->
		test	Airborne1,1	;aircraft airborne?
		_JZ	SkipLaydown	;no ->

;* check heading in approx direction (avoid spurious release)

		mov	ax,M_VIEW.VP_HDG
		mov	dx,WPBrg
		call	CalcAngDiff

		cmp	ax,64		;diff > 45 degs?
		_JA	SkipLaydown	;yes ->

;* release if (range - throw) <= (vtas * cos(pitch) * delta time) / 16

		mov	ax,WORD PTR WPRng
		mov	dx,WORD PTR WPRng+2

		sub	ax,WORD PTR BombThrow
		sbb	dx,WORD PTR BombThrow+2

		js	@F		;< 0, always release ->

		_JNZ	SkipLaydown	;too far ->

		mov	bp,ax

		mov	ax,Vtas
		mov	dx,M_CosP
		imul	dx
		FRACADJ	dx
		mov	ax,DeltaTime
		imul	dx
		FRACADJ	dx

		REPT	4		;/16
		shr	dx,1
		ENDM

		ROUNDUP	dx

		cmp	bp,dx		;solution?
		ja	SkipLaydown	;no ->

;* release package

@@:		mov	si,PackagePtr

		mov	ax,Vtas
		mov	bx,[si].PACK_WEAP_TYPE
		mov	cx,[si].PACK_WEAP_NUM
		mov	dl,1		;Tornado release
		mov	si,OFFSET M_VIEW
		mov	di,-1		;target waypoint not applicable
		call	ReleasePackage
		jc	SkipLaydown	;package not released ->

;* disarm (clear package, update weight, select next package etc.)

		mov	ArmMode,ARM_OFF

		test	InfiniteWeapons,1	;infinite weapons?
		jnz	SkipLaydown		;yes ->

		mov	si,PackagePtr

		mov	bx,[si].PACK_WEAP_TYPE
		mov	bx,ExtStoresIndex[bx]
		mov	ax,ExtStores[bx]
		sub	ax,[si].PACK_WEAP_NUM
		MINM	ax
		mov	ExtStores[bx],ax

		mov	[si].PACK_WEAP_TYPE,NULL_WEAPON
		mov	[si].PACK_WEAP_NUM,0

		call	SelectNextPack

SkipLaydown:	jmp	ArmOk

;---------------------------
ArmLoft     	LABEL	NEAR
;---------------------------

;* check target valid

		cmp	WayTotal,0	;any waypoints?
		ja	@F		;yes ->

		cmp	WPPtr,OFFSET FloatWP	;floating waypoint selected?
		je	@F			;yes ->

		mov	ArmMode,ARM_OFF

		jmp	SkipLoft

;* make target viewpoint (every frame in case target changes)

@@:		mov	si,WPPtr

		mov	ax,[si].WP_XSEC
		mov	TGT_VIEW.VP_XSEC,ax

		mov	ax,[si].WP_YSEC
		mov	TGT_VIEW.VP_YSEC,ax

		mov	ax,[si].WP_XFT
		mov	TGT_VIEW.VP_XFT,ax

		mov	ax,[si].WP_YFT
		mov	TGT_VIEW.VP_YFT,ax

		xor	ax,ax

		mov	WORD PTR TGT_VIEW.VP_ZFT_LO,ax
		mov	WORD PTR TGT_VIEW.VP_ZFT_HI,ax

;* calc throw

		mov	si,PackagePtr

		mov	ax,Vtas
		mov	bx,[si].PACK_WEAP_TYPE
		mov	si,OFFSET M_VIEW
		call	CalcThrow

;* if abs(ang diff) > 90 degs then (flying away from target)
;*    clock = -1
;*    ratio = -1
;* endif

		mov	ax,M_VIEW.VP_HDG
		mov	dx,WPBrg
		call	CalcAngDiff

		cmp	ax,128		;diff > 90 degs?
		jbe	@F		;yes ->

		mov	LoftClock,-1
		mov	LoftRatio,-1

		jmp	SkipLoft

;* calc pull up range (pull up range = throw @ 45 degs pitch up)

@@:		mov	si,PackagePtr

		mov	ax,Vtas
		mov	bx,[si].PACK_WEAP_TYPE
		mov	si,OFFSET M_VIEW

		push	M_VIEW.VP_PITCH
		push	WORD PTR BombThrow
		push	WORD PTR BombThrow+2

		mov	M_VIEW.VP_PITCH,64	;45 degs

		call	CalcThrow

		pop	WORD PTR BombThrow+2
		pop	WORD PTR BombThrow
		pop	M_VIEW.VP_PITCH

;* if target range >= pull up range then
;*    time to go = (target range - pull up range) / vtas
;*    clock = time to go
;*    ratio = -1
;* else
;*    if range < 65536 then
;*       if throw < range then
;*          ratio = throw * 32768 / range
;*          clock = 32767 - ratio
;*       else
;*          ratio = 32767
;*          clock = 32767
;*	 endif
;*    else
;*       ratio = 32767
;*       clock = 32767
;*    endif
;* endif

		mov	bx,WORD PTR WPRng
		mov	cx,WORD PTR WPRng+2

		cmp	cx,dx
		ja	@F	     	;target rng > pull up rng ->
		jb	ContPullUp	;target rng < pull up rng ->

		cmp	bx,ax	
		jb	ContPullUp     	;target rng < pull up rng ->

@@:		xchg	ax,bx
		xchg	dx,cx

		sub	ax,bx		;target range - pull up range
		sbb	dx,cx

		mov	bx,Vtas

		call	CalcETA

		cmp	ax,60		;clock limit 60 secs
		jbe	@F
		mov	ax,60

@@:		mov	dx,546		;adjust for clock (0 .. 32767)

		imul	dx

		mov	LoftClock,ax

		mov	LoftRatio,-1

		jmp	LoftCommit

ContPullUp:	mov	LoftRatio,32767	;assume div error
		mov	LoftClock,32767

		test	cx,cx		;range < 65536?
		jnz	LoftCommit	;no ->

		mov	ax,WORD PTR BombThrow
		mov	dx,WORD PTR BombThrow+2

		test	dx,dx		;throw < 65536?
		jnz	LoftCommit	;no ->

		cmp	ax,bx		;throw < range?
		jae	LoftCommit	;no ->

		mov	dx,ax		;*32768 for bin frac result
		xor	ax,ax
		shr	dx,1
		rcr	ax,1

		div	bx

		mov	LoftRatio,ax

		mov	dx,32767	;clock = 32767 - ratio
		sub	dx,ax

		mov	LoftClock,dx

;* test for weapon commit

LoftCommit:	KFETCH	KF_WpnCommit
		or	al,JoyA_Fire1	;commit package?
		_JZ	SkipLoft	;no ->

;* release interlock

		cmp	M_CosR,0	;aircraft erect?
		_JL	SkipLoft	;no ->
		test	Airborne1,1	;aircraft airborne?
		_JZ	SkipLoft	;no ->

;* check heading in approx direction (avoid spurious release)

		mov	ax,M_VIEW.VP_HDG
		mov	dx,WPBrg
		call	CalcAngDiff

		cmp	ax,64		;diff > 45 degs?
		_JA	SkipLoft	;yes ->

;* release if (range - throw) <= (vtas * cos(pitch) * delta time) / 16

		mov	ax,WORD PTR WPRng
		mov	dx,WORD PTR WPRng+2

		sub	ax,WORD PTR BombThrow
		sbb	dx,WORD PTR BombThrow+2

		js	@F		;< 0, always release ->

		_JNZ	SkipLoft	;too far ->

		mov	bp,ax

		mov	ax,Vtas
		mov	dx,M_CosP
		imul	dx
		FRACADJ	dx
		mov	ax,DeltaTime
		imul	dx
		FRACADJ	dx

		REPT	4		;/16
		shr	dx,1
		ENDM

		ROUNDUP	dx

		cmp	bp,dx		;solution?
		ja	SkipLoft	;no ->

;* release package

@@:		mov	si,PackagePtr

		mov	ax,Vtas
		mov	bx,[si].PACK_WEAP_TYPE
		mov	cx,[si].PACK_WEAP_NUM
		mov	dl,1		;Tornado release
		mov	si,OFFSET M_VIEW
		mov	di,-1		;target waypoint not applicable
		call	ReleasePackage
		jc	SkipLoft	;package not released ->

;* disarm (clear package, update weight, select next package etc.)

		mov	ArmMode,ARM_OFF

		test	InfiniteWeapons,1	;infinite weapons?
		jnz	SkipLoft		;yes ->

		mov	si,PackagePtr

		mov	bx,[si].PACK_WEAP_TYPE
		mov	bx,ExtStoresIndex[bx]
		mov	ax,ExtStores[bx]
		sub	ax,[si].PACK_WEAP_NUM
		MINM	ax
		mov	ExtStores[bx],ax

		mov	[si].PACK_WEAP_TYPE,NULL_WEAPON
		mov	[si].PACK_WEAP_NUM,0

		call	SelectNextPack

SkipLoft:	jmp	ArmOk

;---------------------------
ArmLaserGuided	LABEL	NEAR
;---------------------------

;* test for weapon release

		KFETCH	KF_WpnFire
		or	al,JoyA_JustFired1	;release package?
		jz	SkipLaserGuided		;no ->

;* release interlock

		cmp	M_CosR,0	;aircraft erect?
		jl	SkipLaserGuided	;no ->
		test	Airborne1,1	;aircraft airborne?
		jz	SkipLaserGuided	;no ->

;* release package

		mov	si,PackagePtr

		mov	ax,Vtas
		mov	bx,[si].PACK_WEAP_TYPE
		mov	cx,1		;release single weapon from package
		mov	dl,1		;Tornado release
		mov	si,OFFSET M_VIEW
		mov	di,OFFSET FloatWP
		call	ReleasePackage
		jc	SkipLaserGuided	;package not released ->

;* update package (disarm if empty)

		test	InfiniteWeapons,1	;infinite weapons?
		jnz	SkipLaserGuided		;yes ->

		mov	si,PackagePtr

		mov	bx,[si].PACK_WEAP_TYPE
		mov	bx,ExtStoresIndex[bx]
		mov	ax,ExtStores[bx]
		sub	ax,1
		MINM	ax
		mov	ExtStores[bx],ax

		dec	[si].PACK_WEAP_NUM
		jnz	SkipLaserGuided

		mov	ArmMode,ARM_OFF

		mov	[si].PACK_WEAP_TYPE,NULL_WEAPON

		call	SelectNextPack

SkipLaserGuided:jmp	ArmOk

;---------------------------
ArmJP233     	LABEL	NEAR
;---------------------------

		test	ArmLock,1	;release in progress?
		_JNZ	ContJP233	;yes ->

;* check target valid

		cmp	WayTotal,0	;any waypoints?
		ja	@F		;yes ->

		cmp	WPPtr,OFFSET FloatWP	;floating waypoint selected?
		je	@F			;yes ->

		mov	ArmMode,ARM_OFF

		jmp	SkipJP233

;* make target viewpoint (every frame in case target changes)

@@:		mov	si,WPPtr

		mov	ax,[si].WP_XSEC
		mov	TGT_VIEW.VP_XSEC,ax

		mov	ax,[si].WP_YSEC
		mov	TGT_VIEW.VP_YSEC,ax

		mov	ax,[si].WP_XFT
		mov	TGT_VIEW.VP_XFT,ax

		mov	ax,[si].WP_YFT
		mov	TGT_VIEW.VP_YFT,ax

		xor	ax,ax

		mov	WORD PTR TGT_VIEW.VP_ZFT_LO,ax
		mov	WORD PTR TGT_VIEW.VP_ZFT_HI,ax

;* calc throw

		mov	si,PackagePtr

		mov	ax,Vtas
		mov	bx,[si].PACK_WEAP_TYPE
		mov	si,OFFSET M_VIEW
		call	CalcThrow

;* calc impact point

		mov	si,OFFSET M_VIEW
		call	CalcBombCCIP

;* test for weapon commit

		KFETCH	KF_WpnCommit
		or	al,JoyA_Fire1	;commit package?
		_JZ	SkipJP233	;no ->

;* release interlock

		cmp	M_CosR,0	;aircraft erect?
		_JL	SkipJP233	;no ->
		test	Airborne1,1	;aircraft airborne?
		_JZ	SkipJP233	;no ->

;* check heading in approx direction (avoid spurious release)

		mov	ax,M_VIEW.VP_HDG
		mov	dx,WPBrg
		call	CalcAngDiff

		cmp	ax,64		;diff > 45 degs?
		_JA	SkipJP233	;yes ->

;* release if (range - throw) <= (vtas * cos(pitch) * delta time) / 16

		mov	ax,WORD PTR WPRng
		mov	dx,WORD PTR WPRng+2

		sub	ax,WORD PTR BombThrow
		sbb	dx,WORD PTR BombThrow+2

		js	@F		;< 0, always release ->

		_JNZ	SkipJP233	;too far ->

		mov	bp,ax

		mov	ax,Vtas
		mov	dx,M_CosP
		imul	dx
		FRACADJ	dx
		mov	ax,DeltaTime
		imul	dx
		FRACADJ	dx

		REPT	4		;/16
		shr	dx,1
		ENDM

		ROUNDUP	dx

		cmp	bp,dx		;solution?
		_JA	SkipJP233	;no ->

;* start package release

@@: 		mov	ArmLock,1

		mov	JP233Timer,JP233_PERIOD

		SHAKE	SHAKE_JP233,HSHAKE_LO,VSHAKE_LO,JP233_PERIOD ;ori

		jmp	SkipJP233

;* continue package release

;* num bomblets this frame = min(JP233_BOMBLETS * delta time, 1)

ContJP233:	mov	ax,JP233_BOMBLETS
		mov	dx,DeltaTime
		imul	dx
		FRACADJ	cx

		test	cx,cx		;any bomblets?
		jnz	@F		;yes ->

		inc	cx

@@:		mov	si,PackagePtr

		mov	ax,Vtas
		mov	bx,[si].PACK_WEAP_TYPE
		mov	dl,1		;Tornado release
		mov	si,OFFSET M_VIEW
		mov	di,-1		;target waypoint not applicable
		call	ReleasePackage

;* update timer

		mov	ax,JP233Timer
		sub	ax,LastFrame
		MINM	ax
		mov	JP233Timer,ax

		jnz	SkipJP233 	;release still in progress

;* disarm (clear package, update weight, select next package etc.)

		mov	ArmLock,0

		mov	ArmMode,ARM_OFF

		test	InfiniteWeapons,1	;infinite weapons?
		jnz	SkipJP233		;yes ->

		mov	si,PackagePtr

		mov	bx,[si].PACK_WEAP_TYPE
		mov	bx,ExtStoresIndex[bx]
		mov	ax,ExtStores[bx]
		sub	ax,[si].PACK_WEAP_NUM
		MINM	ax
		mov	ExtStores[bx],ax

		mov	[si].PACK_WEAP_TYPE,NULL_WEAPON
		mov	[si].PACK_WEAP_NUM,0

		call	SelectNextPack

SkipJP233:	jmp	ArmOk

;---------------------------
ArmAlarmDir 	LABEL	NEAR
;---------------------------

;* check target valid (take target from RWR)

		test	SSF_RWR,1	;damaged?
		_JNZ	SkipAlarmDir	;yes ->

		mov	cx,NumRWRThreats
		_JCXZ	SkipAlarmDir	;no threats ->

;* scan RWR threats for threat nearest top dead centre (but within ?5degs)

		xor	bp,bp		;index = 0

		mov	bx,64*128	;worst case 45 degs

		mov	si,-1		;assume no threats

;* ignore aircraft and missile threats

ThreatLoop:	cmp	RWRThreats[bp].RWR_THREAT,THREAT_AC
		je	NextThreat

	   	cmp	RWRThreats[bp].RWR_THREAT,THREAT_RAD_MSL
		je	NextThreat

	   	cmp	RWRThreats[bp].RWR_THREAT,THREAT_IR_MSL
		je	NextThreat

;* fetch direction and calc abs(error)

		mov	ax,RWRThreats[bp].RWR_DIR

		xchg	al,ah		;*256
		ror	ax,1		;*128

		ABSV	ax

;* check if nearer TDC

		cmp	ax,bx
		jae	NextThreat

		mov	bx,ax		;new error
		mov	si,bp		;new index

NextThreat:	add	bp,RWR_REC_SIZE

		loop	ThreatLoop

		cmp	si,-1		;valid target?
		_JE	SkipAlarmDir	;no ->

		mov	RWRTgtValid,1

;* make target viewpoint

		mov	bp,si

		mov	ax,RWRThreats[bp].RWR_XSEC
		mov	TGT_VIEW.VP_XSEC,ax

		mov	ax,RWRThreats[bp].RWR_YSEC
		mov	TGT_VIEW.VP_YSEC,ax

		mov	ax,RWRThreats[bp].RWR_XFT
		mov	TGT_VIEW.VP_XFT,ax

		mov	ax,RWRThreats[bp].RWR_YFT
		mov	TGT_VIEW.VP_YFT,ax

		xor	ax,ax

		mov	WORD PTR TGT_VIEW.VP_ZFT_LO,ax
		mov	WORD PTR TGT_VIEW.VP_ZFT_HI,ax

;* calc slant range to target

		mov	si,OFFSET M_VIEW
		mov	di,OFFSET TGT_VIEW

		call	CalcSlantRange

		mov	WORD PTR GndTgtRange,ax
		mov	WORD PTR GndTgtRange+2,dx

;* test for launch ALARM

		KFETCH	KF_WpnFire
		or	al,JoyA_JustFired1	;launch ALARM?
		jz	SkipAlarmDir		;no ->

;* launch interlock

		test	Airborne1,1	;aircraft airborne?
		jz	SkipAlarmDir	;no ->

;* launch ALARM

		mov	ax,Vtas
		mov	dl,1		;Tornado release
		mov	dh,0		;direct attack mode
		mov	si,OFFSET M_VIEW
		mov	di,OFFSET TGT_VIEW
		call	LaunchAlarm
		jc	SkipAlarmDir	;missile not launched ->

		call	LaunchSound

;* update package (disarm if empty)

		test	InfiniteWeapons,1
		jnz	SkipAlarmDir

		mov	ax,ExtStores[EXT_ALARM]
		sub	ax,1
		MINM	ax
		mov	ExtStores[EXT_ALARM],ax

		mov	si,PackagePtr

		dec	[si].PACK_WEAP_NUM
		jnz	SkipAlarmDir

		mov	ArmMode,ARM_OFF

		mov	[si].PACK_WEAP_TYPE,NULL_WEAPON

		call	SelectNextPack

SkipAlarmDir:	jmp	ArmOk

;---------------------------
ArmAlarmInd	LABEL	NEAR
;---------------------------

;* check target valid

		cmp	WayTotal,0	;any waypoints?
		ja	@F		;yes ->

		cmp	WPPtr,OFFSET FloatWP	;floating waypoint selected?
		je	@F			;yes ->

		mov	ArmMode,ARM_OFF

		jmp	SkipAlarmInd

;* make target viewpoint (every frame in case target changes)

@@:		mov	si,WPPtr

		mov	ax,[si].WP_XSEC
		mov	TGT_VIEW.VP_XSEC,ax

		mov	ax,[si].WP_YSEC
		mov	TGT_VIEW.VP_YSEC,ax

		mov	ax,[si].WP_XFT
		mov	TGT_VIEW.VP_XFT,ax

		mov	ax,[si].WP_YFT
		mov	TGT_VIEW.VP_YFT,ax

		xor	ax,ax

		mov	WORD PTR TGT_VIEW.VP_ZFT_LO,ax
		mov	WORD PTR TGT_VIEW.VP_ZFT_HI,ax

;* calc slant range to target

		mov	si,OFFSET M_VIEW
		mov	di,OFFSET TGT_VIEW

		call	CalcSlantRange

		mov	WORD PTR GndTgtRange,ax
		mov	WORD PTR GndTgtRange+2,dx

;* test for launch ALARM

		KFETCH	KF_WpnFire
		or	al,JoyA_JustFired1	;launch ALARM?
		jz	SkipAlarmInd		;no ->

;* launch interlock

		test	Airborne1,1	;aircraft airborne?
		jz	SkipAlarmInd	;no ->

;* check heading in approx direction (avoid spurious release)

		mov	ax,M_VIEW.VP_HDG
		mov	dx,WPBrg
		call	CalcAngDiff

		cmp	ax,64		;diff > 45 degs?
		ja	SkipAlarmInd	;yes ->

;* launch ALARM

		mov	ax,Vtas
		mov	dl,1		;Tornado release
		mov	dh,1		;indirect attack mode
		mov	si,OFFSET M_VIEW
		mov	di,OFFSET TGT_VIEW
		call	LaunchAlarm
		jc	SkipAlarmInd	;missile not launched ->

		call	LaunchSound

;* update package (disarm if empty)

		test	InfiniteWeapons,1
		jnz	SkipAlarmInd

		mov	ax,ExtStores[EXT_ALARM]
		sub	ax,1
		MINM	ax
		mov	ExtStores[EXT_ALARM],ax

		mov	si,PackagePtr

		dec	[si].PACK_WEAP_NUM
		jnz	SkipAlarmInd

		mov	ArmMode,ARM_OFF

		mov	[si].PACK_WEAP_TYPE,NULL_WEAPON

		call	SelectNextPack

SkipAlarmInd:	jmp	ArmOk

;---------------------------
ArmCannon   	LABEL	NEAR
;---------------------------

		cmp	RadarMode,AIR_RADAR	;air radar on?
		je	ContCannon		;yes ->

;* >>>>> air-to-ground cannon <<<<<

;* check target valid (floating waypoint)

		cmp	WPPtr,OFFSET FloatWP	;floating waypoint selected?
		jne	ContCannon		;no ->

;* make target viewpoint (every frame in case target changes)

		mov	si,WPPtr

		mov	ax,[si].WP_XSEC
		mov	TGT_VIEW.VP_XSEC,ax

		mov	ax,[si].WP_YSEC
		mov	TGT_VIEW.VP_YSEC,ax

		mov	ax,[si].WP_XFT
		mov	TGT_VIEW.VP_XFT,ax

		mov	ax,[si].WP_YFT
		mov	TGT_VIEW.VP_YFT,ax

		xor	ax,ax

		mov	WORD PTR TGT_VIEW.VP_ZFT_LO,ax
		mov	WORD PTR TGT_VIEW.VP_ZFT_HI,ax

;* calc slant range

		mov	si,OFFSET M_VIEW
		mov	di,OFFSET TGT_VIEW

		call	CalcSlantRange

		mov	WORD PTR GndTgtRange,ax
		mov	WORD PTR GndTgtRange+2,dx

;* test for fire cannons

ContCannon:	KFETCH	KF_WpnCommit
		or	al,JoyA_Fire1	;fire cannons?
		jz	SkipCannon	;no ->

;* fire interlock

		test	Airborne1,1	;aircraft airborne?
		jz	SkipCannon	;no ->

;* fire cannons (assume available else get break in shake and sound effects)
		
		mov	CannonFired,1	

		call	CannonSound

		SHAKE	SHAKE_CANNON,HSHAKE_OFF,VSHAKE_LO,1*100 ;ori

		mov	dh,RHS_CANNON

		cmp	TornadoType,ADV_TORNADO
		je	@F

		mov	dh,RHS_CANNON+LHS_CANNON

@@:		mov	ax,Vtas
		mov	dl,1		;Tornado fire
		mov	si,OFFSET M_VIEW
		mov	di,OFFSET M_MOBILE
		call	FireCannon
		jc	SkipCannon	;cannon not fired ->

		or	Tx.COMMS_FLAGS1,I_FIRE_CANNON

		test	InfiniteWeapons,1
		jnz	SkipCannon

;* decrement cannons wrt time

		mov	ax,DeltaTime
		mov	dx,CANNON_RATE*2	;result * 65536
		imul	dx

		sub	CannonFine,ax
		sbb	Cannons,dx
		ja	SkipCannon	;cannons remaining ->

		mov	Cannons,0
		mov	CannonFine,0

		mov	ArmMode,ARM_OFF

		call	SelectAirWpn

SkipCannon:	jmp	ArmOk

;---------------------------
ArmSidewinder  	LABEL	NEAR
;---------------------------

;* check target valid

		cmp	AirTgtPtr,-1
		je	SkipSidewinder

;* check IR lock (IR range approx 8 miles)

		cmp	WORD PTR AirTgtRange+2,0
		ja	SkipSidewinder
		cmp	WORD PTR AirTgtRange,8*5280
		ja	SkipSidewinder

		mov	si,OFFSET M_VIEW

		mov	di,AirTgtPtr
		add	di,MOB_REC_SIZE		;di -> target VIEWPOINT data

		call	CheckIRLock
		jnc	SkipSidewinder		;no lock ->

		mov	IRLockFlag,1

;* test for launch Sidewinder

		KFETCH	KF_WpnFire
		or	al,JoyA_JustFired1	;launch Sidewinder?
		jz	SkipSidewinder		;no ->

;* launch interlock

		test	Airborne1,1	;aircraft airborne?
		jz	SkipSidewinder	;no ->

;* launch Sidewinder

		mov	ax,Vtas
		mov	bx,SIDEWINDER
		mov	dl,1		;Tornado release
		mov	si,OFFSET M_VIEW
		mov	di,AirTgtPtr
		call	LaunchMissile
		jc	SkipSidewinder	;missile not launched ->

		call	LaunchSound

		or	Tx.COMMS_FLAGS1,I_FIRE_AIM9L

		mov	ax,AirTgtPtr
		mov	MissileTgtPtr,ax

		test	TwoPlayer,1
		jnz	@F

		test	InfiniteWeapons,1
		jnz	SkipSidewinder

@@:		dec	ExtStores[EXT_SIDEWINDER]
		jnz	SkipSidewinder	;Sidewinders remaining ->

		mov	ArmMode,ARM_OFF

		call	SelectAirWpn

SkipSidewinder:	jmp	ArmOk

;---------------------------
ArmSkyFlash    	LABEL	NEAR
;---------------------------

;* check target valid

		cmp	AirTgtPtr,-1
		je	SkipSkyFlash

;* test for launch Sky Flash

		KFETCH	KF_WpnFire
		or	al,JoyA_JustFired1	;launch Sky Flash?
		jz	SkipSkyFlash		;no ->

;* launch interlock

		test	Airborne1,1	;aircraft airborne?
		jz	SkipSkyFlash	;no ->

;* launch Sky Flash

		mov	ax,Vtas
		mov	bx,SKYFLASH
		mov	dl,1		;Tornado release
		mov	si,OFFSET M_VIEW
		mov	di,AirTgtPtr
		call	LaunchMissile
		jc	SkipSkyFlash	;missile not launched ->

		call	LaunchSound

		or	Tx.COMMS_FLAGS1,I_FIRE_SKYFLASH

		mov	ax,AirTgtPtr
		mov	MissileTgtPtr,ax

		test	TwoPlayer,1
		jnz	@F

		test	InfiniteWeapons,1
		jnz	SkipSkyFlash

@@:		dec	ExtStores[EXT_SKYFLASH]
		jnz	SkipSkyFlash	;Sky Flash remaining ->

		mov	ArmMode,ARM_OFF

		call	SelectAirWpn

SkipSkyFlash:	jmp	ArmOk

;---------------------------
ArmOk		LABEL	NEAR
;---------------------------

;--------------------
;* sort chaff release
;--------------------

		KTEST	KF_Chaff
		jz	SkipChaff

;* release interlock

		cmp	ChaffCntr,0
		je	SkipChaff

		test	Airborne1,1
		jz	SkipChaff

;* release chaff

		mov	ax,Vtas
		mov	bx,CHAFF
		mov	dl,1		;Tornado release
		mov	si,OFFSET M_VIEW

		call	ReleaseDecoy

;* assume chaff always released (regardless of mobile being created)

		call	DecoySound

		mov	RelChaff,1

		or	Tx.COMMS_FLAGS1,I_REL_CHAFF

		test	TwoPlayer,1
		jnz	@F

		test	InfiniteWeapons,1
		jnz	SkipChaff

@@:		dec	ChaffCntr

;--------------------
;* sort flare release
;--------------------

SkipChaff:	KTEST	KF_Flare
		jz	SkipFlare

;* release interlock

		cmp	FlareCntr,0
		je	SkipFlare

		test	Airborne1,1
		jz	SkipFlare

;* release flare

		mov	ax,Vtas
		mov	bx,FLARE
		mov	dl,1		;Tornado release
		mov	si,OFFSET M_VIEW

		call	ReleaseDecoy

;* assume flare always released (regardless of mobile being created)

		call	DecoySound

		mov	RelFlare,1

		or	Tx.COMMS_FLAGS1,I_REL_FLARE

		test	TwoPlayer,1
		jnz	@F

		test	InfiniteWeapons,1
		jnz	SkipFlare

@@:		dec	FlareCntr

SkipFlare:	ret

WeaponsControl	ENDP

;----------------------------------------------------------------------------

;* SelectNextPack - select next package (if any)
;*
;* pass: PackagePtr
;* ret : PackagePtr
;* kill: assume all

SelectNextPack	PROC	NEAR

		mov	si,PackagePtr
		
		cmp	si,-1		;any packages?
		je	ExitNextPack	;no ->

		mov	di,si		;store starting place

NextPackLoop:	add	si,PACK_REC_SIZE	;next package
		
		cmp	si,OFFSET Packages+(NUM_PACKAGES*PACK_REC_SIZE)	;wrap around?
		jb	@F						;no ->

		mov	si,OFFSET Packages

@@:		cmp	[si].PACK_WEAP_TYPE,NULL_WEAPON	;null package?
		jne	@F				;no ->

;* Note: If back to starting point then the last package must have been
;*       released and there are no more packages left (PackagePtr = -1).

		cmp	si,di		;starting point?
		jne	NextPackLoop	;no ->

		mov	si,-1

@@:		mov	PackagePtr,si

ExitNextPack:	ret

SelectNextPack	ENDP

;----------------------------------------------------------------------------

;* SelectAirWpn - select next air weapon
;*
;* pass: AirArmMode
;* ret : AirArmMode
;*       ArmMode (if any air mode armed)
;* kill: assume all

SelectAirWpn	PROC	NEAR

		mov	ax,AirArmMode

		cmp	ax,ARM_OFF	;off?
		_JE	ExitAirWpn	;yes ->

;* cannon - select Sidewinder then Sky Flash then cannon

		cmp	ax,ARM_CANNON
		jne	@F

		mov	ax,ARM_SIDEWINDER
		cmp	ExtStores[EXT_SIDEWINDER],0
		ja	SetAirWpn

		mov	ax,ARM_SKYFLASH
		cmp	ExtStores[EXT_SKYFLASH],0
		ja	SetAirWpn

		mov	ax,ARM_CANNON
		cmp	Cannons,0
		ja	SetAirWpn

		mov	ax,ARM_OFF

		jmp	SetAirWpn

;* Sidewinder - select Sky Flash then cannon then Sidewinder

@@:		cmp	ax,ARM_SIDEWINDER
		jne	@F

		mov	ax,ARM_SKYFLASH
		cmp	ExtStores[EXT_SKYFLASH],0
		ja	SetAirWpn

		mov	ax,ARM_CANNON
		cmp	Cannons,0
		ja	SetAirWpn

		mov	ax,ARM_SIDEWINDER
		cmp	ExtStores[EXT_SIDEWINDER],0
		ja	SetAirWpn

		mov	ax,ARM_OFF

		jmp	SetAirWpn

;* Sky Flash - select cannon then Sidewinder then Sky Flash 

@@:		cmp	ax,ARM_SKYFLASH
		jne	@F

		mov	ax,ARM_CANNON
		cmp	Cannons,0
		ja	SetAirWpn

		mov	ax,ARM_SIDEWINDER
		cmp	ExtStores[EXT_SIDEWINDER],0
		ja	SetAirWpn

		mov	ax,ARM_SKYFLASH
		cmp	ExtStores[EXT_SKYFLASH],0
		ja	SetAirWpn

@@:		mov	ax,ARM_OFF

SetAirWpn:	mov	AirArmMode,ax

;* if ArmMode = air-to-air mode then update ArmMode

		mov	dx,ArmMode

		cmp	dx,ARM_CANNON
		je	@F
		cmp	dx,ARM_SIDEWINDER
		je	@F
		cmp	dx,ARM_SKYFLASH
		jne	ExitAirWpn

@@:		mov	ArmMode,ax

ExitAirWpn:	ret

SelectAirWpn	ENDP

;----------------------------------------------------------------------------

;* CalcThrow - calc bomb throw
;*
;* pass: ax = aircraft velocity (vtas *8 scaled)
;*       bx = weapon type (GPB1000, RET1000, LGB1000, BL755, JP233)
;*	 si -> aircraft VIEWPOINT
;* ret : dx, ax = BombThrow = throw (ft)
;* kill: assume all (except ax, dx)

CalcThrow	PROC	NEAR

;----------------------
;* retard bomb velocity
;----------------------

		call	RetardBombVel

;------------
;* calc throw
;------------

;* vvel = vel * sin(pitch)
;*
;* if vvel > 0 then
;*    tr = vvel / 32
;*    rh = (vvel * vvel) / 64
;*    zmax = alt + rh
;*    tf = sqrt(zmax / 16)
;*    tt = tr + tf
;* else
;*    impvvel = sqrt(vvel * vvel + 64 * alt)
;*    tt = (impvvel - abs(vvel)) / 32
;* endif
;*
;* hvel = vel * cos(pitch)
;*
;* throw = tt * hvel

		mov	bx,[si].VP_PITCH

		SINCOS	bx,dx,bx	;bx = sin(pitch), dx = cos(pitch)

;* hvel[*8] = vel[*8] * cos(pitch)

		mov	bp,ax

		imul	dx
		FRACADJ	dx

		mov	ax,bp

		push	dx		;store hvel

;* vvel[*8] = vel[*8] * sin(pitch)

		imul	bx
		FRACADJ	ax

		cmp	ax,0		;pitched up?
		jle	CalcPitchDown	;no ->

;-------------------------
;* calc throw - pitched up
;-------------------------

;* tr[*256] = vvel[*8]
		
		mov	bp,ax

;* rh[*4096] = vvel[*8] * vvel[*8]

		imul	ax

;* zmax = alt * 4096 + rh[*4096]

		mov	bx,WORD PTR [si].VP_ZFT_LO
		mov	cx,WORD PTR [si].VP_ZFT_HI

		mov	ch,cl		;*256
		mov	cl,bh
		mov	bh,bl
		xor	bl,bl

		REPT	4		;*16 (*4096)
		shl	bx,1
		rcl	cx,1
		ENDM

		add	ax,bx
		adc	dx,cx

;* tf[*256] = sqrt(zmax)

		call	Sqrt32

;* tt[*256] = tr[*256] + tf[*256]

		add	ax,bp

		MAXM	ax		;limit to 65535

		jmp	ContThrow
		
;-------------------------
;* calc throw - pitched down (or level)
;-------------------------

CalcPitchDown:	neg	ax

		mov	bp,ax		;bp = abs(vvel)

;* impvvel[*8] = sqrt(vvel[*8] * vvel[*8] + 4096 * alt)

		imul	ax

		mov	bx,WORD PTR [si].VP_ZFT_LO
		mov	cx,WORD PTR [si].VP_ZFT_HI

		mov	ch,cl		;*256
		mov	cl,bh
		mov	bh,bl
		xor	bl,bl

		REPT	4		;*16 (*4096)
		shl	bx,1
		rcl	cx,1
		ENDM

		add	ax,bx
		adc	dx,cx

		call	Sqrt32

;* tt[*256] = impvvel[*8] - abs(vvel[*8])

		sub	ax,bp

;* throw = tt[*256] * hvel[*8] / 2048

ContThrow:	pop	dx		;restore hvel

		mul	dx

		mov	al,ah		;/256
		mov	ah,dl
		mov	dl,dh
		xor	dh,dh

		REPT	3		;/8 (/2048)
		shr	dx,1
		rcr	ax,1
		ENDM

;* store bomb throw value

		mov	WORD PTR BombThrow,ax
		mov	WORD PTR BombThrow+2,dx

		ret

CalcThrow	ENDP

;----------------------------------------------------------------------------

;* RetardBombVel - retard bomb velocity wrt bomb type
;*
;* pass: ax = aircraft velocity (vtas *8 scaled)
;*       bx = weapon type (GPB1000, RET1000, LGB1000, BL755, JP233)
;* ret : ax = retarded velocity
;* kill: dx, flags

RetardBombVel	PROC	NEAR

		mov	dx,RetardFactors[bx]

		imul	dx
		FRACADJ	ax

		ret

RetardBombVel	ENDP

;----------------------------------------------------------------------------

;* CalcBombCCIP - calc CCIP for bomb
;*
;* pass: dx, ax = throw (ft)
;*	 si -> aircraft VIEWPOINT
;* ret : CCIP_VIEW
;* kill: assume all

CalcBombCCIP	PROC	NEAR

;------------------
;* copy datum point
;------------------

		COPY_VP	CCIP_VIEW,si

;----------------------
;* place CCIP on ground
;----------------------

		mov	WORD PTR CCIP_VIEW.VP_ZFT_LO,0
		mov	WORD PTR CCIP_VIEW.VP_ZFT_HI,0

;--------------------------
;* scale down throw < 32768
;--------------------------

		xor	bp,bp		;scale count = 0

@@:		test	dx,dx		;throw > 65535?
		jz	@F		;no ->
		shr	dx,1		;throw / 2
		rcr	ax,1
		inc	bp		;inc scale count
		jmp	@B

@@:		cmp	ax,32768	;throw < 32768?
		jb	@F		;yes ->
		shr	ax,1		;throw / 2
		inc	bp		;inc scale count

;------------------------------
;* calc x and y offsets wrt hdg
;------------------------------

@@:		mov	bx,CCIP_VIEW.VP_HDG

		SINCOS	si,di,bx

		mov	bx,ax

;* y offset = throw * cos(hdg)

		imul	di
		FRACADJ	ax
		cwd

		xchg	ax,bx		;cx, bx = y offset
		mov	cx,dx

;* x offset = throw * sin(hdg)

		imul	si
		FRACADJ	ax
		cwd			;dx, ax = x offset

;---------------
;* restore scale
;---------------

		xchg	cx,bp

		jcxz	ScaleOk

@@:		shl	ax,1		;x offset * 2
		rcl	dx,1

		shl	bx,1		;y offset * 2
		rcl	bp,1

		loop	@B

ScaleOk:	xchg	cx,bp

		mov	si,OFFSET CCIP_VIEW

		call	MoveViewpoint

		ret

CalcBombCCIP	ENDP

;----------------------------------------------------------------------------

;* ReleasePackage - release weapon package
;*
;* pass: ax = aircraft velocity (vtas *8 scaled)
;*       bx = weapon type
;*	 cx = number of weapons in package
;*	 dl = 0 = drone release
;*	      1 = Tornado release
;*    	 si -> aircraft VIEWPOINT
;*	 di -> target waypoint (if applicable else -1)
;* ret : cf = 0: package (or part package) released
;*       cf = 1: package not released
;* kill: assume all (except cf)

ReleasePackage	PROC	NEAR

		xor	bp,bp

@@:		push	ax
		push	bx
		push	cx
		push	dx
		push	si
		push	di
		push	bp
		call	ReleaseWeapon[bx]
		pop	bp
		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax

		jc	@F		;failed to create weapon ->

		inc	bp

		loop	@B

@@:		test	bp,bp		;released any weapons?
		jz	@F		;no ->

		clc			;package released
		ret

@@:		stc			;package not released
		ret

ReleasePackage	ENDP

;----------------------------------------------------------------------------

;* ReleaseBomb - drop bomb (if available)
;*
;* pass: ax = aircraft velocity (vtas *8 scaled)
;*       bx = weapon type (GPB1000, RET1000, LGB1000, BL755, JP233)
;*	 cx = weapon number
;*	 dl = 0 = drone release
;*	      1 = Tornado release
;*	 si -> aircraft VIEWPOINT
;*	 di -> target waypoint (if applicable else -1)
;* ret : cf = 0: weapon created
;*       cf = 1: weapon not created (no weapon available)
;* kill: assume all (except cf)

ReleaseBomb	PROC	NEAR

;-------------------------
;* assume weapon available (initialize wrt pass parameters)
;-------------------------

		mov	WPN_Weapon.WPN_TYPE,bx

		mov	WeaponNum,cx

		mov	TargetPtr,di

		mov	WPN_Weapon.WPN_FLAGS,0	;init flags

		test	dl,dl			;Tornado release?
		jz	@F			;no ->

		or	WPN_Weapon.WPN_FLAGS,WFLG_TORNADO

@@:		call	RetardBombVel

		mov	WeaponVel,ax

		COPY_VP	WPN_View,si

;---------------------------
;* check if weapon available
;---------------------------

		call	FindAvailWeapon
		_JC	ExitRelBomb	;cf = 1 (weapon not created) ->

		mov	WeaponPtr,si

;----------------
;* init MOBILE <>
;----------------

		mov	bx,WPN_Weapon.WPN_TYPE
		shr	bx,1			;/2 byte index
		mov	al,ObjectNum[bx]
		mov	WPN_Mobile.MOB_NUM,al

		mov	WPN_Mobile.MOB_TYPE,OTYPE_MOBILE2

		xor	al,al			;init animation

		cmp	WPN_Weapon.WPN_TYPE,RET1000	;retarded bomb?
		jne	@F				;no ->

		or	al,RETARDED_BOMB

@@:		mov	WPN_Mobile.MOB_ANIM,al

;-------------------
;* init VIEWPOINT <>
;-------------------

;* note: Roll is always set to zero, therefore use OTYPE_MOBILE2 mobiles.
;*	 Zero roll is also required for weapon view.

		mov	WPN_View.VP_ROLL,0

;--------------
;* sort release
;--------------

		cmp	WPN_Weapon.WPN_TYPE,LGB1000	;LGB?
		jne	SkipLGBRelease			;no ->

;-----------------
;* LGB1000 release
;-----------------

		test	WPN_Weapon.WPN_FLAGS,WFLG_TORNADO	;Tornado release?
		jz	ContLGBRelease				;no ->

		mov	si,PackagePtr

		cmp	[si].PACK_WEAP_MODE,ARM_LGB	;guided?
		je	ContLGBRelease			;yes ->

		or	WPN_Weapon.WPN_FLAGS,WFLG_UNGUIDED

		jmp	SkipLGBRelease

ContLGBRelease:	mov	ax,TargetPtr
		mov	WPN_Weapon.WPN_LGB_TGT,ax

		mov	ax,WeaponVel
		mov	WPN_Weapon.WPN_LGB_VEL,ax

		jmp	ContRelBomb

;-------------------------------------------
;* GPB1000 / RET1000 / BL755 / JP233 release
;-------------------------------------------

;* random hdg variation to disperse sub-munitions (JP233 only)

SkipLGBRelease:	cmp	WPN_Weapon.WPN_TYPE,JP233	;JP233?
		jne	@F				;no ->

		call	RandX
		cbw
		and	al,003h		;-3 .. +3 pdegs
		xor	al,ah
		sub	al,ah
		cbw

		add	WPN_View.VP_HDG,ax
		and	WPN_View.VP_HDG,511

;* calc sin(pitch) and cos(pitch)

@@:		mov	bx,WPN_View.VP_PITCH

		SINCOS	si,di,bx

;* horizontal velocity = vtas * cos(pitch)

		mov	ax,WeaponVel
		imul	di
		FRACADJ	bx

;* add random adjustment to horizontal velocity (seperate bombs)

		cmp	WPN_Weapon.WPN_TYPE,JP233	;JP233?
		je	@F				;yes, always adjust ->
		
		cmp	WeaponNum,1	;first bomb?
		je	HVelOk		;yes, keep accurate ->

@@:		call	RandX
		cbw
		REPT	2		;/4 gives +/-64 (+/-8ft/sec)
		sar	ax,1
		ENDM

		add	bx,ax

HVelOk:		mov	WPN_Weapon.WPN_BOMB_HVEL,bx

;* vertical velocity = vtas * sin(pitch)

		mov	ax,WeaponVel
		imul	si
		FRACADJ	bx

;* add random adjustment to vertical velocity (seperate bombs)

		cmp	WPN_Weapon.WPN_TYPE,JP233	;JP233?
		je	@F				;yes, always adjust ->
		
		cmp	WeaponNum,1	;first bomb?
		je	VVelOk		;yes, keep accurate ->

@@:		call	RandX
		cbw
		REPT	2		;/4 gives +/-64 (+/-8ft/sec)
		sar	ax,1
		ENDM

		add	bx,ax

VVelOk:		mov	WPN_Weapon.WPN_BOMB_VVEL,bx

;---------------------------
ContRelBomb	LABEL	NEAR
;---------------------------

;* xfine, yfine, zfine

		xor	ax,ax

		mov	WPN_Weapon.WPN_XFINE,ax
		mov	WPN_Weapon.WPN_YFINE,ax
		mov	WPN_Weapon.WPN_ZFINE,ax

;* hfine, pfine

		mov	cl,7		;*128

		mov	ax,WPN_View.VP_HDG
		shl	ax,cl
		mov	WPN_Weapon.WPN_HFINE,ax

		mov	ax,WPN_View.VP_PITCH
		shl	ax,cl
		mov	WPN_Weapon.WPN_PFINE,ax

;* vertical seperation (not JP233)

		cmp	WPN_Weapon.WPN_TYPE,JP233	;JP233?
		je	@F				;yes ->

		mov	ax,WeaponNum

		dec	ax

		REPT	3		;*8 (8ft seperation)
		shl	ax,1
		ENDM

		sub	WORD PTR WPN_View.VP_ZFT_LO,ax
		sbb	WORD PTR WPN_View.VP_ZFT_HI,0
		jns	@F				;above ground ->

		mov	WORD PTR WPN_View.VP_ZFT_LO,0
		mov	WORD PTR WPN_View.VP_ZFT_HI,0

;-----------------------------------------
;* if Tornado weapon then sort weapon view
;-----------------------------------------

@@:		test	WPN_Weapon.WPN_FLAGS,WFLG_TORNADO	;Tornado?
		jz	SkipView	     			;no ->

;* if JP233 release then keep viewpoint with first bomblet

		cmp	WPN_Weapon.WPN_TYPE,JP233	;JP233?
		jne	@F				;no ->

		mov	si,ViewWeaponPtr

		cmp	si,-1		;valid?
		je	@F		;no ->

		mov	ax,WPNDATA
		mov	ds,ax

		mov	bx,_WPN_TYPE[si]

		mov	ax,DATA
		mov	ds,ax

		cmp	bx,JP233	;already viewing JP233 bomblet?
		je	SkipView	;yes ->

@@:		mov	ax,WeaponPtr
		mov	ViewWeaponPtr,ax

;---------------------------------
;* copy weapon data from workspace
;---------------------------------

SkipView: 	mov	ax,WPNDATA
		mov	es,ax

		mov	si,OFFSET WPN_Workspace
		mov	di,WeaponPtr
		mov	cx,WPN_DATA_SIZE
		FAST_MOVE

		mov	ax,DATA
		mov	es,ax

		clc			;cf = 0 (weapon created)

ExitRelBomb:	ret

ReleaseBomb	ENDP

;----------------------------------------------------------------------------

;* LaunchAlarm - launch ALARM missile (if available)
;*
;* pass: ax = aircraft velocity (vtas *8 scaled)
;*	 dl = 0 = drone launch
;*	      1 = Tornado launch
;*	 dh = 0 = direct attack mode
;*	      1 = indirect attack mode
;*	 si -> aircraft VIEWPOINT
;*	 di -> target VIEWPOINT
;* ret : cf = 0: weapon created
;*       cf = 1: weapon not created (no weapon available)
;* kill: assume all (except cf)

LaunchAlarm	PROC	NEAR

;-------------------------
;* assume weapon available (initialize wrt pass parameters)
;-------------------------

		mov	WPN_Weapon.WPN_TYPE,ALARM

		mov	WPN_Weapon.WPN_ALM_VEL,ax

		mov	TargetPtr,di

		mov	WPN_Weapon.WPN_FLAGS,0	;init flags

		test	dl,dl			;Tornado launch?
		jz	@F			;no ->

		or	WPN_Weapon.WPN_FLAGS,WFLG_TORNADO

@@:		mov	ax,ALARM_DIRECT		;assume direct

		test	dh,dh			;direct attack mode?
		jz	@F			;yes ->

		mov	ax,ALARM_GUIDE

		or	WPN_Weapon.WPN_FLAGS,ax

@@:		COPY_VP	WPN_View,si

;---------------------------
;* check if weapon available
;---------------------------

		call	FindAvailWeapon
		_JC	ExitLaunchAlarm	;cf = 1 (weapon not created) ->

		mov	WeaponPtr,si

;----------------
;* init MOBILE <>
;----------------

		mov	WPN_Mobile.MOB_NUM,MOB_ALARM

		mov	WPN_Mobile.MOB_TYPE,OTYPE_MOBILE3	;(roll required)

		mov	WPN_Mobile.MOB_ANIM,FLAME

;-------------------
;* init VIEWPOINT <>
;-------------------

;* if Tornado and in cockpit then adjust viewpoint zft for visual effect

		test	WPN_Weapon.WPN_FLAGS,WFLG_TORNADO
		jz	@F

		test	InCockpit,1
		jz	@F

		add	WORD PTR WPN_View.VP_ZFT_LO,ZFT_COCKPIT
		adc	WORD PTR WPN_View.VP_ZFT_HI,0

@@:		call	CalcPylonPos

;* set roll to zero for initial missile guidance

		mov	WPN_View.VP_ROLL,0

;----------------
;* init WEAPON <>
;----------------

;* xfine, yfine, zfine

		xor	ax,ax

		mov	WPN_Weapon.WPN_XFINE,ax
		mov	WPN_Weapon.WPN_YFINE,ax
		mov	WPN_Weapon.WPN_ZFINE,ax

;* hfine, pfine

		mov	cl,7		;*128

		mov	ax,WPN_View.VP_HDG
		shl	ax,cl
		mov	WPN_Weapon.WPN_HFINE,ax

		mov	ax,WPN_View.VP_PITCH
		shl	ax,cl
		mov	WPN_Weapon.WPN_PFINE,ax

		mov	WPN_Weapon.WPN_ALM_ACCEL,ALARM_ACCEL

		mov	WPN_Weapon.WPN_ALM_TIMER,ALARM_BURNTIME

;* sort target position

		mov	si,TargetPtr

		mov	ax,[si].VP_XSEC
		mov	WPN_Weapon.WPN_ALM_XSEC,ax
		mov	ax,[si].VP_YSEC
		mov	WPN_Weapon.WPN_ALM_YSEC,ax
		mov	ax,[si].VP_XFT
		mov	WPN_Weapon.WPN_ALM_XFT,ax
		mov	ax,[si].VP_YFT
		mov	WPN_Weapon.WPN_ALM_YFT,ax

;-----------------------------------------
;* if Tornado weapon then sort weapon view
;-----------------------------------------

		test	WPN_Weapon.WPN_FLAGS,WFLG_TORNADO	;Tornado?
		jz	@F		     			;no ->

		mov	ax,WeaponPtr
		mov	ViewWeaponPtr,ax

;---------------------------------
;* copy weapon data from workspace
;---------------------------------

@@:		mov	ax,WPNDATA
		mov	es,ax

		mov	si,OFFSET WPN_Workspace
		mov	di,WeaponPtr
		mov	cx,WPN_DATA_SIZE
		FAST_MOVE

		mov	ax,DATA
		mov	es,ax

		clc			;cf = 0 (weapon created)

ExitLaunchAlarm:ret

LaunchAlarm	ENDP

;----------------------------------------------------------------------------

;* FireCannon - fire cannon (if available)
;*
;* pass: ax = source velocity (vtas *8 scaled)
;*            (zero if static (ie. AAA))
;*	 dl = 0 = drone fire
;*	      1 = Tornado fire
;*       dh = cannon animation
;*	 si -> source VIEWPOINT
;*       di -> source MOBILE (required to prevent self destruction)
;*             (-1 if not mobile (ie. AAA))
;* ret : cf = 0: weapon created
;*       cf = 1: weapon not created (no weapon available)
;* kill: assume all (except cf)
;*
;* note: This routine is intended to be used by all sources of shell fire
;*	 (ie. aircraft, helicopters, AAA).

FireCannon	PROC	NEAR

;-------------------------
;* assume weapon available (initialize wrt pass parameters)
;-------------------------

		mov	WPN_Weapon.WPN_CAN_SRC,di

		mov	WPN_Weapon.WPN_FLAGS,0	;init flags

		test	dl,dl			;Tornado release?
		jz	@F			;no ->

		or	WPN_Weapon.WPN_FLAGS,WFLG_TORNADO

@@:		mov	WeaponVel,ax

		mov	WPN_Mobile.MOB_ANIM,dh

		COPY_VP	WPN_View,si

;---------------------------
;* check if weapon available
;---------------------------

		call	FindAvailWeapon
		_JC	ExitFireCannon	;cf = 1 (weapon not created) ->

		mov	WeaponPtr,si

;----------------
;* init MOBILE <>
;----------------

		mov	WPN_Mobile.MOB_NUM,MOB_TRACER

		mov	WPN_Mobile.MOB_TYPE,OTYPE_MOBILE3

;-------------------
;* init VIEWPOINT <>
;-------------------

;* if Tornado and in cockpit then
;*    adjust viewpoint zft and object animation for visual effect
;* endif

		test	WPN_Weapon.WPN_FLAGS,WFLG_TORNADO
		jz	@F

		test	InCockpit,1
		jz	@F

		add	WORD PTR WPN_View.VP_ZFT_LO,ZFT_COCKPIT
		adc	WORD PTR WPN_View.VP_ZFT_HI,0

		mov	al,WPN_Mobile.MOB_ANIM
		REPT	2
		shl	al,1
		ENDM
		mov	WPN_Mobile.MOB_ANIM,al

;----------------
;* init WEAPON <>
;----------------

@@:		mov	WPN_Weapon.WPN_TYPE,CANNON

		xor	ax,ax

		mov	WPN_Weapon.WPN_HFINE,ax
		mov	WPN_Weapon.WPN_PFINE,ax
		mov	WPN_Weapon.WPN_XFINE,ax
		mov	WPN_Weapon.WPN_YFINE,ax
		mov	WPN_Weapon.WPN_ZFINE,ax

		mov	WPN_Weapon.WPN_CAN_TIMER,SHELL_LIFETIME

;* vel = min(vtas + muzzle velocity, 32767)

		mov WeaponVel,0
		mov	bp,WeaponVel
		add	bp,MUZZLE_VELOCITY

		cmp	bp,32767
		jbe	@F
		mov	bp,32767

;* calc sin(pitch) and cos(pitch)

@@:		mov	bx,WPN_View.VP_PITCH

		SINCOS	si,di,bx

;* horizontal velocity = vtas * cos(pitch)

		mov	ax,bp
		imul	di
		FRACADJ	dx

		mov	WPN_Weapon.WPN_CAN_HVEL,dx

;* vertical velocity = vtas * sin(pitch)

		mov	ax,bp
		imul	si
		FRACADJ	dx

		mov	WPN_Weapon.WPN_CAN_VVEL,dx

;-----------------------------------------
;* if Tornado weapon then sort weapon view
;-----------------------------------------

		test	WPN_Weapon.WPN_FLAGS,WFLG_TORNADO	;Tornado?
		jz	@F		     			;no ->

		mov	ax,WeaponPtr
		mov	ViewWeaponPtr,ax

;---------------------------------
;* copy weapon data from workspace
;---------------------------------

@@:		mov	ax,WPNDATA
		mov	es,ax

		mov	si,OFFSET WPN_Workspace
		mov	di,WeaponPtr
		mov	cx,WPN_DATA_SIZE
		FAST_MOVE

		mov	ax,DATA
		mov	es,ax

		clc			;cf = 0 (weapon created)

ExitFireCannon:	ret

FireCannon	ENDP

;----------------------------------------------------------------------------

;* LaunchMissile - launch missile (if available)
;*
;* pass: ax = aircraft velocity (vtas *8 scaled) (zero if SAM launch)
;*       bx = weapon type (SIDEWINDER / SKYFLASH / PATRIOT / GECKO)
;*	 dl = 0 = drone launch
;*	      1 = Tornado launch
;*	 si -> source VIEWPOINT (aircraft / SAM launcher)
;*	 di -> target ptr
;* ret : cf = 0: weapon created
;*       cf = 1: weapon not created (no weapon available)
;* kill: assume all (except cf)

LaunchMissile	PROC	NEAR

;-------------------------
;* assume weapon available (initialize wrt pass parameters)
;-------------------------

		mov	WPN_Weapon.WPN_TYPE,bx

		mov	WPN_Weapon.WPN_MISS_VEL,ax

		mov	WPN_Weapon.WPN_MISS_TGT,di

		mov	WPN_Weapon.WPN_FLAGS,0	;init flags

		test	dl,dl			;Tornado launch?
		jz	@F			;no ->

		or	WPN_Weapon.WPN_FLAGS,WFLG_TORNADO

@@:		cmp	di,OFFSET M_MOBILE	;missile locked onto Tornado?
		jne	@F			;no ->

		or	WPN_Weapon.WPN_FLAGS,WFLG_TLOCK

@@:		COPY_VP	WPN_View,si

;---------------------------
;* check if weapon available
;---------------------------

		call	FindAvailWeapon
		_JC	ExitLaunchMiss	;cf = 1 (weapon not created) ->

		mov	WeaponPtr,si

;----------------
;* init MOBILE <>
;----------------

		mov	bx,WPN_Weapon.WPN_TYPE
		shr	bx,1			;/2 byte index
		mov	al,ObjectNum[bx]
		mov	WPN_Mobile.MOB_NUM,al

		mov	WPN_Mobile.MOB_TYPE,OTYPE_MOBILE2

		mov	WPN_Mobile.MOB_ANIM,FLAME

;-------------------
;* init VIEWPOINT <>
;-------------------

;* if Tornado and in cockpit then adjust viewpoint zft for visual effect

		test	WPN_Weapon.WPN_FLAGS,WFLG_TORNADO
		jz	@F

		test	InCockpit,1
		jz	@F

		add	WORD PTR WPN_View.VP_ZFT_LO,ZFT_COCKPIT
		adc	WORD PTR WPN_View.VP_ZFT_HI,0

@@:		call	CalcPylonPos

;* note: Roll is always set to zero, therefore use OTYPE_MOBILE2 mobiles.
;*	 Zero roll is also required for weapon view.

		mov	WPN_View.VP_ROLL,0

;----------------
;* init WEAPON <>
;----------------

;* xfine, yfine, zfine

		xor	ax,ax

		mov	WPN_Weapon.WPN_XFINE,ax
		mov	WPN_Weapon.WPN_YFINE,ax
		mov	WPN_Weapon.WPN_ZFINE,ax

;* hfine, pfine

		mov	cl,7		;*128

		mov	ax,WPN_View.VP_HDG
		shl	ax,cl
		mov	WPN_Weapon.WPN_HFINE,ax

		mov	ax,WPN_View.VP_PITCH
		shl	ax,cl
		mov	WPN_Weapon.WPN_PFINE,ax

;* sort Sidewinder

		cmp	WPN_Weapon.WPN_TYPE,SIDEWINDER
		jne	@F

		mov	WPN_Weapon.WPN_MISS_ACCEL,SIDE_ACCEL

		mov	WPN_Weapon.WPN_MISS_TIMER,SIDE_BURNTIME

		or	WPN_Weapon.WPN_FLAGS,WFLG_IR_SEEK

		jmp	SortMissOk

;* sort Sky Flash

@@:		cmp	WPN_Weapon.WPN_TYPE,SKYFLASH
		jne	@F

		mov	WPN_Weapon.WPN_MISS_ACCEL,SKY_ACCEL

		mov	WPN_Weapon.WPN_MISS_TIMER,SKY_BURNTIME

		jmp	SortMissOk

;* sort Patriot

@@:		cmp	WPN_Weapon.WPN_TYPE,PATRIOT
		jne	@F

		mov	WPN_Weapon.WPN_MISS_ACCEL,SAM_ACCEL

		mov	WPN_Weapon.WPN_MISS_TIMER,SAM_BURNTIME

		jmp	SortMissOk

;* sort Gecko

@@:		mov	WPN_Weapon.WPN_MISS_ACCEL,SAM_ACCEL

		mov	WPN_Weapon.WPN_MISS_TIMER,SAM_BURNTIME

		or	WPN_Weapon.WPN_FLAGS,WFLG_IR_SEEK

;* reset decoy timer (allow time for clearance before enabling guidance)

SortMissOk:	mov	WPN_Weapon.WPN_MISS_DECOY,50

;-----------------------------------------
;* if Tornado weapon then sort weapon view
;-----------------------------------------

		test	WPN_Weapon.WPN_FLAGS,WFLG_TORNADO	;Tornado?
		jz	@F		     			;no ->

		mov	ax,WeaponPtr
		mov	ViewWeaponPtr,ax

;---------------------------------
;* copy weapon data from workspace
;---------------------------------

@@:		mov	ax,WPNDATA
		mov	es,ax

		mov	si,OFFSET WPN_Workspace
		mov	di,WeaponPtr
		mov	cx,WPN_DATA_SIZE
		FAST_MOVE

		mov	ax,DATA
		mov	es,ax

		clc			;cf = 0 (weapon created)

ExitLaunchMiss:	ret

LaunchMissile	ENDP

;----------------------------------------------------------------------------

;* ReleaseDecoy - release chaff / flare (if available)
;*
;* pass: ax = aircraft velocity (vtas *8 scaled)
;*       bx = decoy type (CHAFF / FLARE)
;*	 dl = 0 = drone release
;*	      1 = Tornado release
;*	 si -> aircraft VIEWPOINT
;* ret : cf = 0: decoy created
;*       cf = 1: decoy not created (no weapon available)
;* kill: assume all (except cf)

ReleaseDecoy	PROC	NEAR

;-------------------------
;* assume weapon available (initialize wrt pass parameters)
;-------------------------

		mov	WPN_Weapon.WPN_TYPE,bx

		mov	WPN_Weapon.WPN_FLAGS,0	;init flags

		test	dl,dl			;Tornado release?
		jz	@F			;no ->

		or	WPN_Weapon.WPN_FLAGS,WFLG_TORNADO

;* sort retard velocity and lifetime

@@:		mov	dx,CHAFF_RETARD
		mov	bp,CHAFF_LIFE
		
		cmp	bx,CHAFF
		je	@F

		mov	dx,FLARE_RETARD
		mov	bp,FLARE_LIFE

@@:		imul	dx
		FRACADJ	dx
		
		mov	WeaponVel,dx

		mov	WPN_Weapon.WPN_DECOY_LIFE,bp

		COPY_VP	WPN_View,si

;---------------------------
;* check if weapon available
;---------------------------

		call	FindAvailWeapon
		_JC	ExitRelDecoy	;cf = 1 (decoy not created) ->

		mov	WeaponPtr,si

;----------------
;* init MOBILE <>
;----------------

		mov	bx,WPN_Weapon.WPN_TYPE
		shr	bx,1			;/2 byte index
		mov	al,ObjectNum[bx]
		mov	WPN_Mobile.MOB_NUM,al

		mov	WPN_Mobile.MOB_TYPE,OTYPE_MOBILE2

		mov	WPN_Mobile.MOB_ANIM,0

;-------------------
;* init VIEWPOINT <>
;-------------------

;* if Tornado and in cockpit then adjust viewpoint zft for visual effect

		test	WPN_Weapon.WPN_FLAGS,WFLG_TORNADO
		jz	@F

		test	InCockpit,1
		jz	@F

		add	WORD PTR WPN_View.VP_ZFT_LO,ZFT_COCKPIT-4
		add	WORD PTR WPN_View.VP_XFT,ZFT_COCKPIT
		add	WORD PTR WPN_View.VP_YFT,ZFT_COCKPIT
		adc	WORD PTR WPN_View.VP_ZFT_HI,0

@@:		call	CalcDecoyPos

;* note: Roll is always set to zero, therefore use OTYPE_MOBILE2 mobiles.

		mov	WPN_View.VP_ROLL,0

;----------------
;* init WEAPON <>
;----------------

;* calc sin(pitch) and cos(pitch)

		mov	bx,WPN_View.VP_PITCH

		SINCOS	si,di,bx

;* horizontal velocity = vtas * cos(pitch)

		mov	ax,WeaponVel
		imul	di
		FRACADJ	dx

		mov	WPN_Weapon.WPN_DECOY_HVEL,dx

;* vertical velocity = vtas * sin(pitch)

		mov	ax,WeaponVel
		imul	si
		FRACADJ	dx

		mov	WPN_Weapon.WPN_DECOY_VVEL,dx

;* xfine, yfine, zfine

		xor	ax,ax

		mov	WPN_Weapon.WPN_XFINE,ax
		mov	WPN_Weapon.WPN_YFINE,ax
		mov	WPN_Weapon.WPN_ZFINE,ax

;* hfine, pfine

		mov	cl,7		;*128

		mov	ax,WPN_View.VP_HDG
		shl	ax,cl
		mov	WPN_Weapon.WPN_HFINE,ax

		mov	ax,WPN_View.VP_PITCH
		shl	ax,cl
		mov	WPN_Weapon.WPN_PFINE,ax

;---------------------------------
;* copy weapon data from workspace
;---------------------------------

		mov	ax,WPNDATA
		mov	es,ax

		mov	si,OFFSET WPN_Workspace
		mov	di,WeaponPtr
		mov	cx,WPN_DATA_SIZE
		FAST_MOVE

		mov	ax,DATA
		mov	es,ax

		clc			;cf = 0 (decoy created)

ExitRelDecoy:	ret

ReleaseDecoy	ENDP

;----------------------------------------------------------------------------

;* FindAvailWeapon - find unused weapon record
;*
;* pass: nothing
;* ret : cf = 0: weapon available
;*          si -> MOBILE + VIEWPOINT + WEAPON
;*       cf = 1: no weapon available
;*	    si = -1
;* kill: ax, cx, flags (except cf)

FindAvailWeapon	PROC	NEAR

		mov	ax,WPNDATA
		mov	es,ax

		mov	cx,NUM_WEAPONS

		mov	si,OFFSET WeaponList

FindWpnLoop:	cmp	si,ViewWeaponPtr	;used by view weapon?
		je	@F			;yes ->

		cmp	ES:_WPN_TYPE[si],NULL_WEAPON	;unused?
		je	WeaponAvail	 		;yes ->

@@:		add	si,WPN_DATA_SIZE

		loop	FindWpnLoop

		stc			;cf = 1 (no weapon available)

		mov	si,-1

		mov	ax,DATA
		mov	es,ax

		ret

WeaponAvail:	clc			;cf = 0 (weapon available)

		mov	ax,DATA
		mov	es,ax

		ret

FindAvailWeapon	ENDP

;----------------------------------------------------------------------------

;* StoreImpact - store Tornado weapon impact point
;*
;* pass: WPN_Workspace
;*	 ImpactPtr
;*       ImpactSurface
;* ret : ImpactPtr
;* kill: assume all
;*
;* note: Only call this routine if Tornado weapon and zft = 0.

StoreImpact	PROC	NEAR

;--------------------------
;* check impact point valid
;--------------------------

;* any room in buffer?

		cmp	ImpactPtr,OFFSET ImpactListEnd
		je	ExitImpact

;* ignore cannon shells (too many and not useful data)

		cmp	WPN_Weapon.WPN_TYPE,CANNON
		je	ExitImpact

;* land on active map?

		cmp	WPN_View.VP_XSEC,31
		ja	ExitImpact
		cmp	WPN_View.VP_YSEC,31
		ja	ExitImpact

;--------------------
;* store impact point
;--------------------

		mov	di,ImpactPtr

		mov	ax,WPNDATA
		mov	es,ax

		mov	ax,WPN_View.VP_XSEC
		mov	ES:[di].IMP_XSEC,al
		mov	ax,WPN_View.VP_YSEC
		mov	ES:[di].IMP_YSEC,al

		mov	ax,WPN_View.VP_XFT
		mov	ES:[di].IMP_XFT,ax
		mov	ax,WPN_View.VP_YFT
		mov	ES:[di].IMP_YFT,ax

		mov	ax,WPN_Weapon.WPN_TYPE
		mov	ES:[di].IMP_WEAP_TYPE,al

		mov	ax,ImpactSurface
		mov	ES:[di].IMP_SURF_TYPE,al

		mov	ax,DATA
		mov	es,ax

;* update ptr

		add	ImpactPtr,IMP_REC_SIZE

ExitImpact:	ret

StoreImpact	ENDP

;----------------------------------------------------------------------------

;* ProximityKill - destroy ground objects in proximity of weapon impact point
;*
;* pass: WPN_Workspace
;* ret : nothing
;* kill: assume all
;*
;* note: This routine only considers impact points which are on the active
;*	 map and will only destroy objects in that sector.

ProximityKill	PROC	NEAR

;----------------------------------
;* check impact point on active map
;----------------------------------

		cmp	WPN_View.VP_XSEC,31
		ja	ExitProxKill
		cmp	WPN_View.VP_YSEC,31
		ja	ExitProxKill

;----------------------------------------------
;* copy impact viewpoint to auxillary viewpoint
;----------------------------------------------

;* aux viewpoint used to place explosions and smoke at object position

		COPY_VP	TMP_VIEW,WPN_View

;* hdg always zero (mobile crater has same orientation as fixed crater)

		mov	TMP_VIEW.VP_HDG,0

;-----------------
;* destroy objects
;-----------------

		call	KillGndObjects
		call	KillStatMobiles
		call	KillMobiles
		call	KillTrees

ExitProxKill:	ret

ProximityKill	ENDP

;----------------------------------------------------------------------------

;* KillGndObjects
;*
;* pass: WPN_Workspace
;*       TMP_VIEW <>
;* ret : nothing
;* kill: assume all
;*       TMP_VIEW.VP_XFT
;*       TMP_VIEW.VP_YFT

KillGndObjects	PROC	NEAR

;----------------------------
;* get ground object list ptr (if occupied sector)
;----------------------------

;* calc map index = x sec + y sec * 32

		mov	bp,WPN_View.VP_YSEC

		REPT	5
		shl	bp,1
		ENDM

		add	bp,WPN_View.VP_XSEC

;* test for occupied sector

		mov	al,SectorLayer1[bp]

		test	al,al
		_JZ	KillGndExit

;* calc ptr to sector data record

		CALC_SEC_PTR

;* get ptr to ground object list

		mov	si,[bx].SEC_OBJ_PTR

;-------------------------
;* scan ground object list
;-------------------------

		mov	ax,SECDATA1
		mov	es,ax

;---------------------------
GndObjLoop	LABEL	NEAR
;---------------------------

;* check for end of list (-1 terminator)

		cmp	ES:[si].GND_NUM,-1
		_JE	ExitGndObj

;* check object in play

		test	ES:[si].GND_ANIM,OBJECT_DEAD
		_JNZ	NextGndObj

;* fetch object damage flags

		mov	bl,ES:[si].GND_NUM
		xor	bh,bh
		mov	ch,GndDamageFlags[bx]

;* check valid target

		test	ch,DAM_INVALID
		_JNZ	NextGndObj

;* fetch weapon damage radius and effectiveness

		mov	bx,WPN_Weapon.WPN_TYPE

		mov	bp,WeaponRadius[bx]

		shr	bx,1		;/2 byte index

		mov	al,WeaponEffect[bx]

;* check weapon effectiveness >= object hardness

		mov	cl,ch

		and	cl,DAM_HARD_MASK

		cmp	al,cl

		_JB	NextGndObj

;* adjust damage radius wrt object hardness

		shr	bp,cl

;-------------------------------------------
;* check abs(delta xft) within damage radius
;-------------------------------------------

;* xft = (x grid * 256) - 8192

		mov	ah,ES:[si].GND_XGRID
		xor	al,al
		sub	ax,8192

;* set aux viewpoint xft at object position

		mov	TMP_VIEW.VP_XFT,ax

;* calc abs(delta xft)

		sub	ax,WPN_View.VP_XFT

		ABSV	ax

;* check abs(delta xft) within damage radius

		cmp	ax,bp
		ja	NextGndObj

;-------------------------------------------
;* check abs(delta yft) within damage radius
;-------------------------------------------

;* yft = (y grid * 256) - 8192

		mov	ah,ES:[si].GND_YGRID
		xor	al,al
		sub	ax,8192

;* set aux viewpoint yft at object position

		mov	TMP_VIEW.VP_YFT,ax

;* calc abs(delta yft)

		sub	ax,WPN_View.VP_YFT

		ABSV	ax

;* check abs(delta yft) within damage radius

		cmp	ax,bp
		ja	NextGndObj

;----------------
;* destroy object
;----------------

;* kill object

		or	ES:[si].GND_ANIM,OBJECT_DEAD

;* inc kills (if Tornado weapon and enemy target)

		test	WPN_Weapon.WPN_FLAGS,WFLG_TORNADO
		jz	SkipKillGnd

		mov	bl,ES:[si].GND_NUM
		xor	bh,bh

		test	ES:[si].GND_ANIM,OBJECT_ENEMY
		jz	@F

		inc	EGndKills[bx]

		jmp	SkipKillGnd

@@: 		inc	AGndKills[bx]

;* sort object debris

SkipKillGnd:	mov	bl,ch

		and	bl,DAM_DEBRIS_MASK
		REPT	2
		shr	bl,1
		ENDM
		xor	bh,bh

		mov	al,DebrisType[bx]
		
		mov	ES:[si].GND_NUM,al

		and	ES:[si].GND_ANIM,OBJECT_CLEAR

;* make explosion effect

		mov	ax,DATA
		mov	es,ax

		mov	al,ch

		push	si
		call	CreateExplosion
		pop	si

		mov	ax,SECDATA1
		mov	es,ax

NextGndObj:	add	si,GND_REC_SIZE

		jmp	GndObjLoop

ExitGndObj:	mov	ax,DATA
		mov	es,ax

KillGndExit:	ret

KillGndObjects	ENDP

;----------------------------------------------------------------------------

;* KillStatMobiles
;*
;* pass: WPN_Workspace
;*       TMP_VIEW <>
;* ret : nothing
;* kill: assume all
;*       TMP_VIEW.VP_XFT
;*       TMP_VIEW.VP_YFT

KillStatMobiles	PROC	NEAR

;----------------------------
;* get static mobile list ptr (if occupied sector)
;----------------------------

;* calc map index = x sec + y sec * 32

		mov	bp,WPN_View.VP_YSEC

		REPT	5
		shl	bp,1
		ENDM

		add	bp,WPN_View.VP_XSEC

;* test for occupied sector

		mov	bl,MobileLayer1[bp]

		test	bl,bl
		_JZ	KillStatExit

;* get ptr to static mobile list

		xor	bh,bh
		shl	bx,1		;*2 word index

		mov	si,MobSectorTable[bx]

;-------------------------
;* scan static mobile list
;-------------------------

		mov	ax,MSECDATA1
		mov	es,ax

;---------------------------
StatMobLoop	LABEL	NEAR
;---------------------------

;* check for end of list (-1 terminator)

		cmp	ES:[si].STAT_NUM,-1
		_JE	ExitStatMob

;* check object in play

		test	ES:[si].STAT_ANIM,OBJECT_DEAD
		_JNZ	NextStatMob

;* fetch object damage flags

		mov	bl,ES:[si].STAT_NUM
		xor	bh,bh
		mov	ch,MobDamageFlags[bx]

;* check valid target

		test	ch,DAM_INVALID
		_JNZ	NextStatMob

;* fetch weapon damage radius and effectiveness

		mov	bx,WPN_Weapon.WPN_TYPE

		mov	bp,WeaponRadius[bx]

		shr	bx,1		;/2 byte index

		mov	al,WeaponEffect[bx]

;* check weapon effectiveness >= object hardness

		mov	cl,ch

		and	cl,DAM_HARD_MASK

		cmp	al,cl

		_JB	NextStatMob

;* adjust damage radius wrt object hardness

		shr	bp,cl

;-------------------------------------------
;* check abs(delta xft) within damage radius
;-------------------------------------------

;* fetch object xft

		mov	ax,ES:[si].STAT_XFT

;* set aux viewpoint xft at object position

		mov	TMP_VIEW.VP_XFT,ax

;* calc abs(delta xft)

		sub	ax,WPN_View.VP_XFT

		ABSV	ax

;* check abs(delta xft) within damage radius

		cmp	ax,bp
		ja	NextStatMob

;-------------------------------------------
;* check abs(delta yft) within damage radius
;-------------------------------------------

;* fetch object yft

		mov	ax,ES:[si].STAT_YFT

;* set aux viewpoint yft at object position

		mov	TMP_VIEW.VP_YFT,ax

;* calc abs(delta yft)

		sub	ax,WPN_View.VP_YFT

		ABSV	ax

;* check abs(delta yft) within damage radius

		cmp	ax,bp
		ja	NextStatMob

;----------------
;* destroy object
;----------------

;* kill object

		or	ES:[si].STAT_ANIM,OBJECT_DEAD

;* inc kills (if Tornado weapon and enemy target)

		test	WPN_Weapon.WPN_FLAGS,WFLG_TORNADO
		jz	SkipKillMob

		mov	bl,ES:[si].STAT_NUM
		xor	bh,bh

		test	ES:[si].STAT_ANIM,OBJECT_ENEMY
		jz	@F

		inc	EMobKills[bx]

		jmp	SkipKillMob

@@:		inc	AMobKills[bx]

;* sort object debris

SkipKillMob:	mov	ah,ch

		and	ah,DAM_DEBRIS_MASK

		mov	al,MOB_CRATER1M
		cmp	ah,DAM_DEBRIS1
		je	@F

		mov	al,MOB_CRATER2M
		
@@:		mov	ES:[si].STAT_NUM,al

		and	ES:[si].STAT_ANIM,OBJECT_CLEAR

		mov	ES:[si].STAT_HDG,0

;* make explosion effect

		mov	ax,DATA
		mov	es,ax

		mov	al,ch

		push	si
		call	CreateExplosion
		pop	si

		mov	ax,MSECDATA1
		mov	es,ax

NextStatMob:	add	si,STAT_REC_SIZE

		jmp	StatMobLoop

ExitStatMob:	mov	ax,DATA
		mov	es,ax

KillStatExit:	ret

KillStatMobiles	ENDP

;----------------------------------------------------------------------------

;* KillMobiles
;*
;* pass: WPN_Workspace
;*       TMP_VIEW <>
;* ret : nothing
;* kill: assume all
;*       TMP_VIEW.VP_XFT
;*       TMP_VIEW.VP_YFT

KillMobiles	PROC	NEAR

;--------------------------
;* test for occupied sector
;--------------------------

		mov	ax,WPN_View.VP_XSEC
		mov	dx,WPN_View.VP_YSEC

		call	LocateMobiles	;mobiles in sector?
		_JC	KillMobExit	;no ->

;--------------
;* scan mobiles
;--------------

MobileLoop:  	cmp	si,-1		;end of list?
		_JE	KillMobExit  	;yes ->

		push	si

;* fetch object damage flags

		mov	bl,[si].MOB_NUM
		xor	bh,bh
		mov	ch,MobDamageFlags[bx]

;* check valid target

		test	ch,DAM_INVALID
		_JNZ	NextMobile

;* fetch weapon damage radius and effectiveness

		mov	bx,WPN_Weapon.WPN_TYPE

		mov	bp,WeaponRadius[bx]

		shr	bx,1		;/2 byte index

		mov	al,WeaponEffect[bx]

;* check weapon effectiveness >= object hardness

		mov	cl,ch

		and	cl,DAM_HARD_MASK

		cmp	al,cl

		_JB	NextMobile

;* adjust damage radius wrt object hardness

		shr	bp,cl

;* sort on ground / airborne

		cmp	WORD PTR _VP_ZFT_HI[si],0
		_JA	NextMobile

		cmp	WORD PTR _VP_ZFT_LO[si],0
		ja	SortAirborne

;---------------
;* ground mobile
;---------------

;-------------------------------------------
;* check abs(delta xft) within damage radius
;-------------------------------------------

;* fetch object xft

		mov	ax,_VP_XFT[si]

;* set aux viewpoint xft at object position

		mov	TMP_VIEW.VP_XFT,ax

;* calc abs(delta xft)

		sub	ax,WPN_View.VP_XFT

		ABSV	ax

;* check abs(delta xft) within damage radius

		cmp	ax,bp
		_JA	NextMobile

;-------------------------------------------
;* check abs(delta yft) within damage radius
;-------------------------------------------

;* fetch object yft

		mov	ax,_VP_YFT[si]

;* set aux viewpoint yft at object position

		mov	TMP_VIEW.VP_YFT,ax

;* calc abs(delta yft)

		sub	ax,WPN_View.VP_YFT

		ABSV	ax

;* check abs(delta yft) within damage radius

		cmp	ax,bp
		_JA	NextMobile

;----------------
;* destroy object
;----------------

		push	cx
		call	WpnKillDrone	
		pop	ax

		call	CreateExplosion

		jmp	NextMobile

;-----------------
;* airborne mobile
;-----------------

;* check alt not too high (saves doing slant range check)

SortAirborne: 	cmp	WORD PTR _VP_ZFT_LO[si],1000
		_JA	NextMobile

;* calc slant range (mobile -> impact point)

		push	si

		add	si,MOB_REC_SIZE		;si -> mobile viewpoint
		mov	di,OFFSET WPN_View	;di -> impact viewpoint
		call	CalcSlantRange

		pop	si

;* check range not too far

		cmp	dx,0
		_JA	NextMobile
		cmp	ax,1414		;1000 * sqrt(2)
		_JA	NextMobile

;* check if within lethal zone (radius / 2)

		mov	bx,WPN_Weapon.WPN_TYPE
		mov	dx,WeaponHemi[bx]
		shr	dx,1

		cmp	ax,dx
		jae	SkipMobKill

;* destroy mobile (if Tornado - shake in case no collisions)

		cmp	si,OFFSET M_MOBILE
		jne	@F
		
		;SHAKE	SHAKE_DAMAGE,HSHAKE_HI,VSHAKE_HI,50 ;ori
		
@@:		push	si
		call	WpnKillDrone	
		pop	si

		mov	bx,SMOKE_AIR_EXPLO
		add	si,MOB_REC_SIZE
		call	MakeSmokeEffect		

		jmp	NextMobile

;* if Tornado then check if within damage zone

SkipMobKill:	cmp	si,OFFSET M_MOBILE
		jne	SpecialEffectsBeforeNextMobile
		
        ;mov	MusicCard,SND_SBLASTER
        ;call InstallMusic
		
		
;		cmp	ax,WeaponHemi[bx]		
;		jae	NextMobile                    
		
;* damage Tornado

;		SHAKE	SHAKE_DAMAGE,HSHAKE_HI,VSHAKE_HI,50 ;ori

        ; If the logic flow reaches here, then the Tonka is out of the DamageHemisphere 
		; but we still want a little jolt/vibration to with the sound effects of 
		; the bomb detonating!
		mov dx,WeaponHemi[bx]	;Added on 30/6/2018. Now LGBs hit the ground with a jarring shaking effect
		shr dx,1                ;Added on 30/6/2018. Now LGBs hit the ground with a jarring shaking effect
		cmp	ax,dx               ;Added on 30/6/2018. Now LGBs hit the ground with a jarring shaking effect
		jae	@F
;* damage Tornado		
		;SHAKE	SHAKE_DAMAGE,HSHAKE_HI,VSHAKE_HI,50 ;ori
		
		mov	bx,SMOKE_AIR_EXPLO
		mov	si,OFFSET M_VIEW
		call	MakeSmokeEffect		

		test	NoCollisions,1
		jnz	NextMobile

		call	MaxDamage
		
		jmp NextMobile
@@:		
		cmp ax, 1320 ;1,320 feet = 1/4 mile
		jae @F ;--> if the distance of Tornado from the blast is less than a quarter mile then...
        SHAKE	SHAKE_COLLIDE,HSHAKE_LO,VSHAKE_HI,50   ;... add MAJOR shake/vibration (hack),
		jmp NextMobile
@@:		; <-- else jump here!
		cmp ax, 2640 ;2,640 feet = 1/2 mile
		jae @F ;--> if the distance of Tornado from the blast is less than a half mile then...
        SHAKE	SHAKE_COLLIDE,HSHAKE_HI,VSHAKE_LO,50   ;... add MEDIUM shake/vibration (hack),
		jmp NextMobile 
@@:		; <-- else jump here!
		cmp ax, 5280 ;5,280 feet = 1 mile
		jae NextMobile ;--> if the distance of Tornado from the blast is less than a mile then...
		SHAKE	SHAKE_BRAKE,HSHAKE_LO,VSHAKE_LO,65535 ;add SLIGHT shake/vibration (hack)
        jmp NextMobile 
		
SpecialEffectsBeforeNextMobile:
		test	WPN_Weapon.WPN_FLAGS,WFLG_TORNADO
		jz	@F
		test	InCockpit,1
		jz	@F
		jmp NextMobile
@@:		
        test CockpitViews,1
		jnz @F
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        cmp	GameViewMode,VIEW_DRONE
        jne @F
		test	WPN_Weapon.WPN_FLAGS,WFLG_TORNADO
		jnz	@F
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
		call ExploSound2
        SHAKE	SHAKE_DAMAGE,HSHAKE_HI,VSHAKE_HI,50
@@:		
NextMobile:	
        pop	si
		mov	si,[si].MOB_LINK_PTR
		jmp	MobileLoop

KillMobExit:	ret

KillMobiles	ENDP

;----------------------------------------------------------------------------

;* KillTrees
;*
;* pass: WPN_Workspace
;*       TMP_VIEW <>
;* ret : nothing
;* kill: assume all
;*       TMP_VIEW.VP_XFT
;*       TMP_VIEW.VP_YFT
;*
;* note: Assume all copse objects have the damage flags:-
;*
;*	 	DAM_HARD1+DAM_DEBRIS2+DAM_EXPLO1
;*
;*	 Trees which are destroyed on the active map will also disappear from
;*	 no mans land!

KillTrees	PROC	NEAR

;---------------------
;* check trees enabled
;---------------------

		test	TreesEnabled,1
		jz	KillTreesExit

;----------------
;* calc map index
;----------------

;* map index = x sec + y sec * 32

		mov	bp,WPN_View.VP_YSEC

		REPT	5
		shl	bp,1
		ENDM

		add	bp,WPN_View.VP_XSEC

;----------------------------
;* fetch weapon damage radius
;----------------------------

		mov	bx,WPN_Weapon.WPN_TYPE

		mov	di,WeaponRadius[bx]

;--------------------------------------
;* select tree layout wrt xsec and ysec (via map index so values are wrapped)
;--------------------------------------

		mov	ax,bp
		mov	bx,bp
		REPT	4
		shr	bx,1
		ENDM
		and	ax,01b		;x
		and	bx,10b		;y
		or	bx,ax
		shl	bx,1		;*2 word index

		mov	bx,TreeLayouts[bx]

;------------------
;* scan tree layers
;------------------

		mov	al,TreeLayer1[bp]
		call	ScanTrees
		mov	TreeLayer1[bp],al

		mov	al,TreeLayer2[bp]
		call	ScanTrees
		mov	TreeLayer2[bp],al

		mov	al,TreeLayer3[bp]
		call	ScanTrees
		mov	TreeLayer3[bp],al

		mov	al,TreeLayer4[bp]
		call	ScanTrees
		mov	TreeLayer4[bp],al

KillTreesExit:	ret

KillTrees	ENDP

;----------------------------------------------------------------------------

;* ScanTrees
;*
;* pass: al = tree layout
;*       bx = tree position index
;*	 di = damage radius
;* ret : al = updated tree layout
;*       bx = updated tree position index
;* kill: ah, cx, dx, si, di, flags

ScanTrees	PROC	NEAR

		mov	dl,al		;tree layout
		mov	dh,11111110b	;kill mask

		push	bx		;store tree index
		push	bp		;store map index

;---------------------------
ScanTreeLoop	LABEL	NEAR
;---------------------------

		shr	al,1
		jnc	NextTree

		push	ax
		push	bx
		push	dx

;-------------------------------------------
;* check abs(delta xft) within damage radius
;-------------------------------------------

;* xft = (x grid * 256) - 8192

		mov	ah,[bx+0]	;xgrid
		xor	al,al
		sub	ax,8192

;* set aux viewpoint xft at object position

		mov	TMP_VIEW.VP_XFT,ax

;* calc abs(delta xft)

		sub	ax,WPN_View.VP_XFT

		ABSV	ax

;* check abs(delta xft) within damage radius

		cmp	ax,di
		ja	SkipTree

;-------------------------------------------
;* check abs(delta yft) within damage radius
;-------------------------------------------

;* yft = (y grid * 256) - 8192

		mov	ah,[bx+1]	;ygrid
		xor	al,al
		sub	ax,8192

;* set aux viewpoint yft at object position

		mov	TMP_VIEW.VP_YFT,ax

;* calc abs(delta yft)

		sub	ax,WPN_View.VP_YFT

		ABSV	ax

;* check abs(delta yft) within damage radius

		cmp	ax,di
		ja	SkipTree

;---------------
;* destroy copse
;---------------

		pop	dx

		and	dl,dh		;clear tree

		push	dx

		mov	al,DAM_EXPLO1

		push	di
		call	CreateExplosion
		pop	di

SkipTree:	pop	dx
		pop	bx
		pop	ax

NextTree:	add	bx,2		;next index

		rol	dh,1		;rotate kill mask

		test	al,al		;any more trees?
		jnz	ScanTreeLoop	;yes ->

		pop	bp		;restore map index
		pop	bx		;restore tree index

		add	bx,8*2		;update tree index

		mov	al,dl		;updated tree layout

		ret

ScanTrees	ENDP

;----------------------------------------------------------------------------

;* CreateExplosion - create explosion effect
;*
;* pass: al = object damage flags
;* ret : nothing
;* kill: assume all
;*
;* note: DAM_EXPLO1 = burn only
;*	 DAM_EXPLO2 = crater size 1 * 2
;*	 DAM_EXPLO3 = crater size 2 * 2
;*	 DAM_EXPLO4 = crater size 2 * 4
;*
;*       TMP_VIEW <> is not destroyed.

CreateExplosion	PROC	NEAR

;-------------
;* sort effect
;-------------
        ;SHAKE	SHAKE_BRAKE,HSHAKE_HI,VSHAKE_HI,50		
		and	al,DAM_EXPLO_MASK

;* DAM_EXPLO1 = burn only

		cmp	al,DAM_EXPLO1
		_JE	ContBurn

;* DAM_EXPLO2 = crater size 1 * 2

		cmp	al,DAM_EXPLO2
		jne	@F

		mov	dl,1		;crater spread dist / 2
		mov	dh,CRATER_SIZE1	;crater size 1
		mov	cx,2		;2 craters

		jmp	ExploLoop

;* DAM_EXPLO3 = crater size 2 * 2

@@:		cmp	al,DAM_EXPLO3
		jne	@F

		mov	dl,0		;crater spread dist / 1
		mov	dh,CRATER_SIZE2	;crater size 2
		mov	cx,2		;2 craters

		jmp	ExploLoop

;* DAM_EXPLO4 = crater size 2 * 4

@@:		mov	dl,0		;crater spread dist / 1
		mov	dh,CRATER_SIZE2	;crater size 2
		mov	cx,4		;4 craters

;--------------
;* make craters
;--------------

ExploLoop: 	push	cx
		push	dx

		push	TMP_VIEW.VP_XFT
		push	TMP_VIEW.VP_YFT

		mov	cl,dl

		call	RandX
		cbw
		sar	ax,cl
		add	ax,TMP_VIEW.VP_XFT
		cmp	ax,8191
		jle	@F
		mov	ax,8191
@@:		cmp	ax,-8192
		jge	@F
		mov	ax,-8192
@@:		mov	TMP_VIEW.VP_XFT,ax

		call	RandX
		cbw
		sar	ax,cl
		add	ax,TMP_VIEW.VP_YFT
		cmp	ax,8191
		jle	@F
		mov	ax,8191
@@:		cmp	ax,-8192
		jge	@F
		mov	ax,-8192
@@:		mov	TMP_VIEW.VP_YFT,ax

		mov	al,dh
		mov	si,OFFSET TMP_VIEW
		call	MakeCrater

		pop	TMP_VIEW.VP_YFT
		pop	TMP_VIEW.VP_XFT

		pop	dx
		pop	cx

		loop	ExploLoop

;------------------
;* make object burn
;------------------

ContBurn:	mov	bx,SMOKE_BURNING
		mov	si,OFFSET TMP_VIEW
		call	MakeSmokeEffect
;SHAKE	SHAKE_BRAKE,HSHAKE_HI,VSHAKE_HI,50
		ret

CreateExplosion	ENDP

;----------------------------------------------------------------------------

;* CalcPylonPos - calc pylon position for weapon
;*
;* pass: WPN_Workspace (WPN_View <>, WPN_TYPE and WPN_FLAGS required)
;* ret : WPN_View
;* kill: assume all

CalcPylonPos	PROC	NEAR

		mov	si,OFFSET WPN_View
		call	CalcTransMatrix

;-----------------
;* sort wing pylon
;-----------------

		cmp	WPN_Weapon.WPN_TYPE,SIDEWINDER
		jne	SortBellyPylon

;* sort Tornado launch

		test	WPN_Weapon.WPN_FLAGS,WFLG_TORNADO
		jz	DroneWingPylon

		mov	al,CrntWingPos

;* 25 degs sweep

		cmp	al,SWEEP_D_25
		jne	@F

		mov	ax,11		;x offset
		mov	bx,1		;y offset

		jmp	SortLaunchSide

;* 45 degs sweep

@@:		cmp	al,SWEEP_D_45
		jne	@F

		mov	ax,10		;x offset
		mov	bx,-1		;y offset

		jmp	SortLaunchSide

;* 67 degs sweep

@@: 		mov	ax,8		;x offset
		mov	bx,-2		;y offset

SortLaunchSide:	mov	dx,LaunchSide	;fetch launch side

		xor	LaunchSide,0ffffh	;switch launch side

		xor	ax,dx	     	;adjust x offset wrt wing
		sub	ax,dx

;* adjust y offset if ADV

		cmp	TornadoType,ADV_TORNADO
		jne	@F

		sub	bx,2

;* set z offset (assume not in cockpit)

@@:		mov	cx,6		;z offset

		jmp	ContPylonPos

;* sort drone launch

DroneWingPylon:	call	RandX		;select random wing
		cbw
		cwd

		mov	ax,8		;x offset
		mov	bx,-2		;y offset
		mov	cx,6		;z offset

		xor	ax,dx		;adjust x offset wrt wing
		sub	ax,dx

		jmp	ContPylonPos

;---------------------------
SortBellyPylon	LABEL	NEAR
;---------------------------

		mov	ax,0		;x offset
		mov	bx,0		;y offset
		mov	cx,2		;z offset

;---------------------------
ContPylonPos	LABEL	NEAR
;---------------------------

;* if Tornado sort in / out cockpit adjustment

		test	WPN_Weapon.WPN_FLAGS,WFLG_TORNADO
		jz	@F

		test	InCockpit,1
		jz	@F

		sub	cx,ZFT_COCKPIT

;* calc 3D offset of pylon position

@@:		call	Calc3DOffset

		xchg	ax,cx

		cwd

		add	WORD PTR WPN_View.VP_ZFT_LO,ax
		adc	WORD PTR WPN_View.VP_ZFT_HI,dx
		jns	@F
		mov	WORD PTR WPN_View.VP_ZFT_LO,0
		mov	WORD PTR WPN_View.VP_ZFT_HI,0

@@:		MOVEXY	WPN_View,cx,bx

		ret

CalcPylonPos	ENDP

;----------------------------------------------------------------------------

;* CalcDecoyPos - calc decoy release position for IDS / ADV / drone
;*
;* pass: WPN_Workspace (WPN_View <>, WPN_TYPE and WPN_FLAGS required)
;* ret : WPN_View
;* kill: assume all

CalcDecoyPos	PROC	NEAR

		mov	si,OFFSET WPN_View
		call	CalcTransMatrix

;-------------------------
;* sort IDS Tornado launch (rh wing tip)
;-------------------------

		test	WPN_Weapon.WPN_FLAGS,WFLG_TORNADO
		jz	BellyDecoy

		cmp	TornadoType,ADV_TORNADO
		je	BellyDecoy

		mov	al,CrntWingPos

		mov	cx,6		;z offset (assume not in cockpit)

;* 25 degs sweep

		cmp	al,SWEEP_D_25
		jne	@F

		mov	ax,19		;x offset
		mov	bx,-20		;y offset

		jmp	ContDecoyPos

;* 45 degs sweep

@@:		cmp	al,SWEEP_D_45
		jne	@F

		mov	ax,17		;x offset
		mov	bx,-27		;y offset

		jmp	ContDecoyPos

;* 67 degs sweep

@@: 		mov	ax,13		;x offset
		mov	bx,-32		;y offset

		jmp	ContDecoyPos

;---------------------------------
;* sort ADV Tornado / drone launch (belly)
;---------------------------------

BellyDecoy:	mov	ax,0		;x offset
		mov	bx,-32		;y offset
		mov	cx,2		;z offset

;---------------------------
ContDecoyPos	LABEL	NEAR
;---------------------------

;* if Tornado sort in / out cockpit adjustment

		test	WPN_Weapon.WPN_FLAGS,WFLG_TORNADO
		jz	@F

		test	InCockpit,1
		jz	@F

		sub	cx,ZFT_COCKPIT

;* calc 3D offset of decoy position

@@:		call	Calc3DOffset

		xchg	ax,cx

		cwd

		add	WORD PTR WPN_View.VP_ZFT_LO,ax
		adc	WORD PTR WPN_View.VP_ZFT_HI,dx
		jns	@F
		mov	WORD PTR WPN_View.VP_ZFT_LO,0
		mov	WORD PTR WPN_View.VP_ZFT_HI,0

@@:		MOVEXY	WPN_View,cx,bx

		ret

CalcDecoyPos	ENDP

;----------------------------------------------------------------------------

;* CheckIRLock - check infra-red lock
;*
;* pass: si -> object VIEWPOINT
;*       di -> target VIEWPOINT
;* ret : cf = 0 = no lock
;*       cf = 1 = IR lock
;* kill: ax, dx, flags (except cf)

CheckIRLock	PROC	NEAR

;--------------------------------
;* check for zero fuel - gliding?
;--------------------------------

;* no lock if out of fuel
		cmp	FuelWt,0	;out of fuel?
		je	NoLock		;yes ->

;---------------
;* check for fog
;---------------		

		cmp	Fog,0
		je	@F

;* no lock if object below cloud top

		mov	ax,WORD PTR [si].VP_ZFT_LO
		mov	dx,WORD PTR [si].VP_ZFT_HI

		sub	ax,WORD PTR CloudTop
		sbb	dx,WORD PTR CloudTop+2

		jb	NoLock

;* no lock if target below cloud top

		mov	ax,WORD PTR [di].VP_ZFT_LO
		mov	dx,WORD PTR [di].VP_ZFT_HI

		sub	ax,WORD PTR CloudTop
		sbb	dx,WORD PTR CloudTop+2

		jb	NoLock

		jmp	IRLock

;--------------------
;* check for overcast
;--------------------

@@:		test	Overcast,1
		jz	IRLock

;* if object is below cloud base then target must also be below for IR lock

		mov	ax,WORD PTR [si].VP_ZFT_LO
		mov	dx,WORD PTR [si].VP_ZFT_HI

		sub	ax,WORD PTR CloudBase
		sbb	dx,WORD PTR CloudBase+2

		jae	@F

		mov	ax,WORD PTR [di].VP_ZFT_LO
		mov	dx,WORD PTR [di].VP_ZFT_HI

		sub	ax,WORD PTR CloudBase
		sbb	dx,WORD PTR CloudBase+2

		jae	NoLock

		jmp	IRLock

;* no lock if object in clouds

@@:		sub	ax,CloudDepth
		sbb	dx,0

		jb	NoLock

;* if object is above cloud top then target must also be above for IR lock

		mov	ax,WORD PTR [di].VP_ZFT_LO
		mov	dx,WORD PTR [di].VP_ZFT_HI

		sub	ax,WORD PTR CloudTop
		sbb	dx,WORD PTR CloudTop+2

		jb	NoLock

;---------------------------
IRLock		LABEL	NEAR
;---------------------------

		stc			;cf = 1 = IR lock
		ret

;---------------------------
NoLock		LABEL	NEAR
;---------------------------

		clc			;cf = 0 = no lock
		ret

CheckIRLock	ENDP

;----------------------------------------------------------------------------

;* AerialExplosion - use weapon to make aerial explosion
;*
;* pass: si -> VIEWPOINT <>
;* ret : nothing
;* kill: assume all

AerialExplosion	PROC	FAR

;-------------------------
;* assume weapon available (initialize wrt pass parameters)
;-------------------------

		COPY_VP	WPN_View,si

;---------------------------
;* check if weapon available
;---------------------------

		call	FindAvailWeapon
		jc	ExitAerial	;cf = 1 (weapon not created) ->

		mov	WeaponPtr,si

;----------------------
;* initialize explosion
;----------------------

;* init MOBILE <>

		mov	WPN_Mobile.MOB_NUM,MOB_AIRBURST
		mov	WPN_Mobile.MOB_TYPE,OTYPE_MOBILE3
		mov	WPN_Mobile.MOB_ANIM,AIRBURST1

;* init WEAPON <> (use arbitrary weapon - anything but NULL_WEAPON)

		mov	WPN_Weapon.WPN_TYPE,CANNON
		mov	WPN_Weapon.WPN_FLAGS,WFLG_AIRBURST

;---------------------------------
;* copy weapon data from workspace
;---------------------------------

		mov	ax,WPNDATA
		mov	es,ax

		mov	si,OFFSET WPN_Workspace
		mov	di,WeaponPtr
		mov	cx,WPN_DATA_SIZE
		FAST_MOVE

		mov	ax,DATA
		mov	es,ax

		clc			;cf = 0 (weapon created)

ExitAerial:	ret

AerialExplosion	ENDP

WEAPONCODE 	ENDS

;============================================================================

VISCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:VISCODE
		ASSUME DS:DATA

;* DrawWeapons
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

DrawWeapons	PROC	NEAR

		mov	ax,WPNDATA
		mov	ds,ax

		mov	cx,NUM_WEAPONS

		mov	si,OFFSET WeaponList

;------------------
;* draw weapon loop
;------------------

DrawLoop:	cmp	_WPN_TYPE[si],NULL_WEAPON	;in use?
		je	@F	      			;no ->

		push	cx
		push	si

;-----------------------------------------------
;* copy MOBILE and VIEWPOINT data into workspace (WEAPON not required)
;-----------------------------------------------

		mov	di,OFFSET WPN_Workspace
		mov	cx,MOB_REC_SIZE+VIEW_REC_SIZE
		FAST_MOVE

;-------------
;* draw mobile
;-------------

		mov	ax,DATA
		mov	ds,ax

		mov	si,OFFSET WPN_Workspace
		call	DrawMobile

		mov	ax,WPNDATA
		mov	ds,ax

		pop	si
		pop	cx

@@:		add	si,WPN_DATA_SIZE

		loop	DrawLoop

		mov	ax,DATA
		mov	ds,ax

		ret

DrawWeapons	ENDP

VISCODE		ENDS

;============================================================================

		END

