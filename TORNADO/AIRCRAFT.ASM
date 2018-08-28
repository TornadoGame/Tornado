;****************************************************************************
;*
;* AIRCRAFT.ASM
;*
;* Drone aircraft control.
;*
;* 14.07.1992 - KJB
;* 02.03.1993 - KJB - Drone bombing added.
;* 18.03.1993 - KJB - Drone combat added.
;* 
;* Allied Aircraft 	vs	Enemy Aircraft		Role
;* 컴컴컴컴컴컴컴?		컴컴컴컴컴컴컴		컴컴
;* GR4 Tornado		vs	Mig-27 Flogger		interdiction / strike
;* F3 Tornado		vs	Mig-31 Foxhound		air defence
;* F-15 Eagle		vs	Su-27 Flanker		interceptor / air superiority
;* F-16 Falcon		vs	Mig-29 Fulcrum		interceptor / air superiority
;* A-10 Thunderbolt	vs	Su-25 Frogfoot		close air support / attack
;* C-130 Hercules  	vs	Il-76 Candid		heavy lift transport
;* E-3D Sentry		vs	Il-76 Mainstay		airborne early warning (AEW)
;*
;* Notes
;* 컴컴?
;*
;*    Data Format
;*    컴컴컴컴컴?
;*       Compound data structure for each drone:-
;*
;*	    MOBILE <>    	<- drone object data (VISDATA.INC)
;*          VIEWPOINT <>	<- drone position and attitude data (VISDATA.INC)
;*          AIRCRAFT <>  	<- drone control data (MAINDATA.INC)
;*
;*	    WAYPOINT <>		)
;*	    WAYPOINT <>		)
;*	    WAYPOINT <>		) waypoint list length may vary
;*             ..    ..		)
;*	    WAYPOINT <>		)
;*
;*	    ENDROUTE <>		end of route marker
;*
;*	    EVEN
;*
;*    Waypoint Actions
;*    컴컴컴컴컴컴컴컴
;*       AC_WP_TAKEOFF	: The aircraft is assumed to be lined up on the runway
;*                   	  ready for takeoff. The runway is assumed to be clear.
;*                        If any aircraft are taking off in front of this one,
;*                        then take care to avoid a fast accelerating aircraft
;*			  running into slower aircraft ahead.
;*
;*			  Aircraft may have an initial delay period or wait for
;*			  an event. The initial delay is not valid if the aircraft
;*			  is triggered by an event.
;*
;*       AC_WP_AIRBORNE	: The aircraft starts airborne. The initial speed is
;*                        set by WP_SPEED (therefore WP_COORD = 0).
;*
;*       AC_WP_TAXI	: Only use on final waypoint. The aircraft will taxi
;*		          off the runway and stop. When multiple aircraft are
;*			  landing together at the same airfield, they should
;*			  be spaced at least 10 seconds apart to avoid collision
;*		          on the ground.
;*
;*       AC_WP_RESTART	: Only use on final waypoint. The aircraft decelerates
;*			  to a stand still and waits whilst it is resupplied
;*			  and then takes off again. The aircraft flies to the
;*			  second waypoint after takeoff. This mechanism is only
;*			  useful for continuous routes.
;*
;*    Event Counter
;*    컴컴컴컴컴컴?
;*       The event counter is not implemented.
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	InitPlanes
		PUBLIC	UpdatePlanes

		PUBLIC	TornadoOppPtr
		PUBLIC	ResponseTimer
		PUBLIC	EWRExposeTimer

EXTRN	WPRngNMiles:WORD

		EXTRN	UpdateMobile:FAR
		EXTRN	ArcTan:FAR
		EXTRN	ArcTan2:FAR
		EXTRN	Tangent:FAR
		EXTRN	CalcSineFine:FAR
		EXTRN	CalcRngBrgVP_VP:FAR
		EXTRN	CalcRngBrgVP_WP:FAR
		EXTRN	CalcRngBrgWP_WP:FAR
		EXTRN	CalcAngDiff:FAR
		EXTRN	CalcGndHeight:FAR
		EXTRN	CalcDeltaXY:FAR
		EXTRN	RandX:FAR
		EXTRN	CalcVias:FAR
		EXTRN	CalcSlantRange:FAR
		EXTRN	GetDroneSpeed:FAR
		EXTRN	GetDroneAlive:FAR
		EXTRN	CalcIntercept:FAR
		EXTRN	CalcTransMatrix:FAR
		EXTRN	CalcRngRelCo:FAR
		EXTRN	CalcEyeCoords:FAR
		EXTRN	FastArcSin:FAR
		EXTRN	FastArcCos:FAR
		EXTRN	LimitPFine:FAR
		EXTRN	AerialExplosion:FAR
		EXTRN	MakeSmokeEffect:FAR
		EXTRN	DeleteMobile:FAR

		EXTRN	CalcThrow:NEAR
		EXTRN	ReleasePackage:NEAR
		EXTRN	LaunchAlarm:NEAR
		EXTRN	FireCannon:NEAR
		EXTRN	LaunchMissile:NEAR
		EXTRN	ReleaseDecoy:NEAR
		EXTRN	CheckIRLock:NEAR

		EXTRN	FrameElapTime:DWORD
		EXTRN	BombThrow:DWORD
		EXTRN	SlantRng:DWORD

		EXTRN	AAircraft1:WORD
		EXTRN	AAircraft2:WORD
		EXTRN	AAircraft3:WORD
		EXTRN	AAircraft4:WORD
		EXTRN	AAircraft5:WORD
		EXTRN	AAircraft6:WORD
		EXTRN	AAircraft7:WORD
		EXTRN	AAircraft8:WORD
		EXTRN	AAircraft9:WORD
		EXTRN	AAircraft10:WORD
		EXTRN	AAircraft11:WORD
		EXTRN	AAircraft12:WORD
		EXTRN	AAircraft13:WORD
		EXTRN	AAircraft14:WORD
		EXTRN	AAircraft15:WORD
		EXTRN	AAircraft16:WORD
		EXTRN	AAircraft17:WORD
		EXTRN	EAircraft1:WORD
		EXTRN	EAircraft2:WORD
		EXTRN	EAircraft3:WORD
		EXTRN	EAircraft4:WORD
		EXTRN	EAircraft5:WORD
		EXTRN	EAircraft6:WORD
		EXTRN	EAircraft7:WORD
		EXTRN	EAircraft8:WORD
		EXTRN	EAircraft9:WORD
		EXTRN	EAircraft10:WORD
		EXTRN	EAircraft11:WORD
		EXTRN	EAircraft12:WORD
		EXTRN	EAircraft13:WORD
		EXTRN	EAircraft14:WORD
		EXTRN	EAircraft15:WORD
		EXTRN	EAircraft16:WORD
		EXTRN	EAircraft17:WORD
		EXTRN	DeltaTime:WORD
		EXTRN	SinTable:WORD
		EXTRN	CosTable:WORD
		EXTRN	LastFrame:WORD
		EXTRN	TMP_VIEW:WORD
		EXTRN	DronePtrs:WORD
		EXTRN	TaxiRoutePtrs:WORD
		EXTRN	APilotSkill:WORD
		EXTRN	EPilotSkill:WORD
		EXTRN	MissileTgtPtr:WORD
		EXTRN	AirTgtPtr:WORD
		EXTRN	RadarMode:WORD
		EXTRN	TrueRadAlt:WORD
		EXTRN	Vias:WORD
		EXTRN	TornadoType:WORD
		EXTRN	ModelMapIndex:WORD

		EXTRN	SpecialLayer1:BYTE
		EXTRN	SctrGameLayer1:BYTE
		EXTRN	NoFire:BYTE
		EXTRN	RWRThreatFlags:BYTE
		EXTRN	ECMActive:BYTE
		EXTRN	Airborne1:BYTE
		EXTRN	DemoMode:BYTE

		EXTRN	AIRFIELD_1:ABS
		EXTRN	JP233_BOMBLETS:ABS
		EXTRN	JP233_PERIOD:ABS
		EXTRN	MUZZLE_VELOCITY:ABS

;============================================================================

		INCLUDE	MAINDATA.INC

		INCLUDE	\VISUAL\VISDATA.INC
		INCLUDE	\VISUAL\VISMACRO.INC
		INCLUDE	\VISUAL\RWY_TAXI.INC

		INCLUDE	\LIB8086\TRIG.INC
		INCLUDE	\LIB8086\USEFUL.INC

;============================================================================

		EXTRN	M_MOBILE:MOBILE
		EXTRN	M_VIEW:VIEWPOINT

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

;****************************************************************************
;* The AC_ suffix on some variables is necessary to differentiate them from *
;* similar global vars (in case they need to be made public for debugging). *
;****************************************************************************

AircraftPtr	DW	-1		;aircraft data / waypoint ptr

PerfDataPtr	DW	-1		;aircraft performance data ptr

;-------------------------------------------------------
;* working copy of current aircraft's data and waypoints
;-------------------------------------------------------

AC_DATA_SIZE	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+AC_REC_SIZE

AC_Workspace	LABEL	BYTE

AC_Mobile	MOBILE <>
AC_View		VIEWPOINT <>
AC_Data		AIRCRAFT <>

		EVEN

;-----------
;* AutoRoute
;-----------

AC_AutoHFine	DW	0		;heading to acquire (fine pdegs)
AC_AutoAlt	DW	0		;altitude to acquire (ft)
AC_AutoVtas	DW	0		;speed to acquire (ft/sec * 8)

AC_WPRng	DD	0		;waypoint range
AC_WPBrg 	DW	0		;waypoint bearing (pdeg)
AC_WPBrgFine	DW	0		;waypoint bearing (fine pdeg)

;--------------
;* AutoThrottle
;--------------

AC_Vmin		DW	0		;min speed (ft/sec * 8)
AC_Vmax		DW	0		;max speed (ft/sec * 8)

AC_Vtrim	DW	0		;min speed for level flight (ft/sec * 8)

FIXED_DECEL	EQU	10*8		;fixed decel rate (ft/sec/sec * 8)

;--------------
;* CalcTurnDist
;--------------

AC_ThetaAB 	DW	0		;angle vp(A) -> wp(B)

AC_ThetaBC 	DW	0		;angle wp(B) -> wp(C)

AC_ThetaABC	DW	0		;angle vp(A) -> wp(B) -> wp(C)

AC_RTurn   	DW	0		;turning radius (0 .. 32,767ft)

;------------------------
;* aircraft control modes
;------------------------

CTRL_NULL	EQU	0		;do nothing
CTRL_TAKEOFF	EQU	2		;takeoff
CTRL_TRACK	EQU	4		;fly from waypoint to waypoint
CTRL_APPROACH	EQU	6		;final approach
CTRL_TOUCHDOWN	EQU	8		;pitch flare and touchdown
CTRL_LANDING	EQU	10		;landing run
CTRL_TAXI	EQU	12		;taxi off runway
CTRL_COMBAT	EQU	14		;combat

ControlMode	DW	CtrlNull	;CTRL_NULL
		DW	CtrlTakeoff	;CTRL_TAKEOFF
		DW	CtrlTrack	;CTRL_TRACK
		DW	CtrlApproach	;CTRL_APPROACH
		DW	CtrlTouchDown	;CTRL_TOUCHDOWN
		DW	CtrlLanding	;CTRL_LANDING
		DW	CtrlTaxi	;CTRL_TAXI
		DW	CtrlCombat	;CTRL_COMBAT

;------------------------------------
;* air-to-ground weapon arming switch
;------------------------------------

ArmSwitch	DW	ArmNull		;WPACK_NULL
		DW	ArmGPB1000	;WPACK_GPB1000
		DW	ArmRET1000	;WPACK_RET1000
		DW	ArmLGB1000	;WPACK_LGB1000
		DW	ArmBL755	;WPACK_BL755
		DW	ArmJP233	;WPACK_JP233
		DW	ArmAlarm	;WPACK_ALARM
		DW	ArmAGM		;WPACK_AGM

;-------------
;* weapon data
;-------------

WeaponType	DW	0
WeaponNum	DW	0

;* note: DEBUG_WEAPONS is not available for LGBs as the "Tornado release"
;*       flag checks that the weapon has guidance from the Tornado TIALD.

DEBUG_WEAPONS	EQU	0		;1 = view drone weapons (debugging)

WPN_CLR_DELAY	EQU	1*100		;weapon clearance delay (secs * 100)

LGB_DELAY	EQU	2*100		;delay between LGB release (secs * 100)

ALARM_DELAY	EQU	1*100		;delay between ALARM launch (secs * 100)

AGM_DELAY	EQU	1*100		;delay between AGM launch (secs * 100)

;------------------------------------
;* aircraft performance data pointers
;------------------------------------

PerfDataPtrs	DW	OFFSET GR4Tornado	;GR4_TORNADO
		DW	OFFSET Mig27Flogger	;MIG27_FLOGGER
		DW	OFFSET F3Tornado	;F3_TORNADO
		DW	OFFSET Mig31Foxhound	;MIG31_FOXHOUND
		DW	OFFSET F15Eagle		;F15_EAGLE
		DW	OFFSET Su27Flanker	;SU27_FLANKER
		DW	OFFSET F16Falcon	;F16_FALCON
		DW	OFFSET Mig29Fulcrum	;MIG29_FULCRUM
		DW	OFFSET A10Thunderbolt	;A10_THUNDERBOLT
		DW	OFFSET Su25Frogfoot	;SU25_FROGFOOT
		DW	OFFSET E3DSentry	;E3D_SENTRY
		DW	OFFSET Il76Mainstay	;IL76_MAINSTAY
		DW	OFFSET C130Hercules	;C130_HERCULES
		DW	OFFSET Il76Candid	;IL76_CANDID

;---------------------------
;* aircraft performance data
;---------------------------

PERF_DATA	STRUCT

PERF_TAKEOFF	DW	-1		;takeoff data ptr
PERF_CRUISE	DW	-1		;cruise data ptr
PERF_LANDING	DW	-1		;landing data ptr
PERF_COMBAT	DW	-1		;combat data ptr (-1 = no combat)

PERF_DATA	ENDS

GR4Tornado	PERF_DATA <					\
			     OFFSET Takeoff2,			\
			     OFFSET Cruise1,			\
			     OFFSET Landing1			\
			  >			   	

Mig27Flogger	PERF_DATA <					\
			     OFFSET Takeoff2,			\
			     OFFSET Cruise1,			\
			     OFFSET Landing3			\
			  >			   	

F3Tornado	PERF_DATA <					\
			     OFFSET Takeoff2,			\
			     OFFSET Cruise1,			\
			     OFFSET Landing1,			\
			     OFFSET Combat1			\
			  >

Mig31Foxhound	PERF_DATA <					\
			     OFFSET Takeoff3,			\
			     OFFSET Cruise1,			\
			     OFFSET Landing3,			\
			     OFFSET Combat2			\
			  >			   	

F15Eagle	PERF_DATA <					\
			     OFFSET Takeoff1,			\
			     OFFSET Cruise2,			\
			     OFFSET Landing3,			\
			     OFFSET Combat3			\
			  >			   	

Su27Flanker	PERF_DATA <					\
			     OFFSET Takeoff1,			\
			     OFFSET Cruise2,			\
			     OFFSET Landing2,			\
			     OFFSET Combat4			\
			  >			   	

F16Falcon	PERF_DATA <					\
			     OFFSET Takeoff2,			\
			     OFFSET Cruise2,			\
			     OFFSET Landing2,			\
			     OFFSET Combat5			\
			  >		    
	   	
Mig29Fulcrum	PERF_DATA <					\
			     OFFSET Takeoff1,			\
			     OFFSET Cruise2,			\
			     OFFSET Landing2,			\
			     OFFSET Combat6			\
			  >			   	

A10Thunderbolt	PERF_DATA <					\
			     OFFSET Takeoff2,			\
			     OFFSET Cruise3,			\
			     OFFSET Landing2			\
			  >			   	

Su25Frogfoot	PERF_DATA <					\
			     OFFSET Takeoff2,			\
			     OFFSET Cruise3,			\
			     OFFSET Landing2			\
			  >			   	

E3DSentry	PERF_DATA <					\
			     OFFSET Takeoff3,			\
			     OFFSET Cruise4,			\
			     OFFSET Landing3			\
			  >			   	

Il76Mainstay	PERF_DATA <					\
			     OFFSET Takeoff3,			\
			     OFFSET Cruise4,			\
			     OFFSET Landing2			\
			  >			   	

C130Hercules	PERF_DATA <					\
			     OFFSET Takeoff3,			\
			     OFFSET Cruise4,			\
			     OFFSET Landing2			\
			  >			   	

Il76Candid	PERF_DATA <					\
			     OFFSET Takeoff3,			\
			     OFFSET Cruise4,			\
			     OFFSET Landing2			\
			  >			   	

;--------------------
;* takeoff parameters
;--------------------

;* calc takeoff parameters given:-
;*
;* ThetaR = pitch angle (rotation) at takeoff (assume 12 degs all aircraft)
;* Vto = takeoff speed (ft/sec)
;* Dto = takeoff run (ft)
;*
;* acceleration (Accel) = (Vto * Vto) / (2 * Dto)
;*
;* rotation rate = ThetaR / tr 
;*
;*    where tr = Vto / (8 * Accel) (rotation speed = Vto * 7 / 8)
;*
;* lift vector rate = Theta / tl
;*
;*    where tl = (Vtrim - Vto) / Accel
;*
;*    where manoeuvre speed (Vtrim) = 4 * Vto * tan(ThetaR) + Vto

TAKEOFF		STRUCT

TO_V_ROTATE	DW	0		;rotation speed (ft/sec * 8)
TO_ACCEL	DW	0		;acceleration (ft/sec * 8)
TO_R_RATE	DW	0		;rotation rate (fine pdegs / sec)
TO_L_RATE	DW	0		;lift vector rate (fine pdegs / sec)

TAKEOFF		ENDS

ROTATION_ANGLE	EQU	2185		;12degs (fine pdegs)

DLY_AFTER_EVENT	EQU	30*100		;delay after event (1/100ths sec)

;------------------------
;* takeoff run = 1,000ft
;* takeoff speed = 125kts
;------------------------
	
Takeoff1	TAKEOFF <1488,181,1857,273>

;------------------------
;* takeoff run = 2,000ft
;* takeoff speed = 150kts
;------------------------
	
Takeoff2	TAKEOFF <1785,130,1114,164>

;------------------------
;* takeoff run = 3,000ft
;* takeoff speed = 130kts
;------------------------
	
Takeoff3	TAKEOFF <1547,65,644,95>

;-------------------
;* cruise parameters
;-------------------

;* note: Mach 1 at sea level = 1123ft/sec (660kts)
;*       Mach 1 at 36,000ft = 974ft/sec (573kts)
;*
;*       CRS_MXSPEED_SL < CRS_MXSPEED_36

CRUISE		STRUCT	2

CRS_CEILING	DW	0		;ceiling (ft)
CRS_MXSPEED_SL	DW	0		;max speed at sea level (ft/sec * 8)
CRS_MXSPEED_36	DW	0		;max speed at 36,000ft (ft/sec * 8)
CRS_ACCEL	DW	0		;acceleration (ft/sec/sec * 8)
CRS_HEAVY	DB	0		;0 = light aircraft
					;1 = heavy aircraft

CRUISE		ENDS

;----------------------------------
;* ceiling = 50,000ft
;* max speed at sea level = 800kts
;* max speed at 36,000ft = Mach 2.2
;* acceleration = 10ft/sec/sec
;* light aircraft
;----------------------------------

Cruise1		CRUISE <50000,10880,17142,80,0>

;----------------------------------
;* ceiling = 60,000ft
;* max speed at sea level = 700kts
;* max speed at 36,000ft = Mach 2.2
;* acceleration = 20ft/sec/sec
;* light aircraft
;----------------------------------

Cruise2		CRUISE <60000,9520,17142,160,0>

;----------------------------------
;* ceiling = 22,000ft
;* max speed at sea level = 350kts
;* max speed at 36,000ft = 680kts (approx. 450kts at 22,000ft)
;* acceleration = 10ft/sec/sec
;* light aircraft
;----------------------------------

Cruise3		CRUISE <22000,4760,9248,80,0>

;----------------------------------
;* ceiling = 40,000ft
;* max speed at sea level = 250kts
;* max speed at 36,000ft = 450kts
;* acceleration = 5ft/sec/sec
;* heavy aircraft
;----------------------------------

Cruise4		CRUISE <40000,3400,6120,40,1>

;------------------------------------------
;* minimum true airspeed table wrt altitude (ft/sec * 8)
;------------------------------------------

MinSpeed	LABEL	WORD

		DW	 1768	;0ft
		DW	 1796	;1,024ft
		DW	 1822	;2,048ft
		DW	 1850	;3,072ft
		DW	 1880	;4,096ft
		DW	 1909	;5,120ft
		DW	 1939	;6,144ft
		DW	 1969	;7,168ft
		DW	 1999	;8,192ft
		DW	 2032	;9,216ft
		DW	 2066	;10,240ft
		DW	 2098	;11,264ft
		DW	 2133	;12,288ft
		DW	 2169	;13,312ft
		DW	 2206	;14,336ft
		DW	 2243	;15,360ft
		DW	 2280	;16,384ft
		DW	 2318	;17,408ft
		DW	 2359	;18,432ft
		DW	 2400	;19,456ft
		DW	 2441	;20,480ft
		DW	 2485	;21,504ft
		DW	 2531	;22,528ft
		DW	 2576	;23,552ft
		DW	 2623	;24,576ft
		DW	 2681	;25,600ft
		DW	 2726	;26,624ft
		DW	 2767	;27,648ft
		DW	 2820	;28,672ft
		DW	 2873	;29,696ft
		DW	 2927	;30,720ft
		DW	 2986	;31,744ft
		DW	 3045	;32,768ft
		DW	 3101	;33,792ft
		DW	 3163	;34,816ft
		DW	 3228	;35,840ft
		DW	 3306	;36,864ft
		DW	 3385	;37,888ft
		DW	 3472	;38,912ft
		DW	 3559	;39,936ft
		DW	 3642	;40,960ft
		DW	 3736	;41,984ft
		DW	 3828	;43,008ft
		DW	 3923	;44,032ft
		DW	 4023	;45,056ft
		DW	 4120	;46,080ft
		DW	 4230	;47,104ft
		DW	 4335	;48,128ft
		DW	 4437	;49,152ft
		DW	 4552	;50,176ft
		DW	 4662	;51,200ft
		DW	 4779	;52,224ft
		DW	 4901	;53,248ft
		DW	 5025	;54,272ft
		DW	 5149	;55,296ft
		DW	 5286	;56,320ft
		DW	 5413	;57,344ft
		DW	 5541	;58,368ft
		DW	 5680	;59,392ft
		DW	 5822	;60,416ft
		DW	 5975	;61,440ft
		DW	 6123	;62,464ft
		DW	 6279	;63,488ft
		DW	 6431	;64,512ft
		DW	 6591	;65,536ft

;--------------------
;* landing parameters
;--------------------

;* Assume all aircraft land at 130kts, therefore:-
;*
;*    decel = (130 * 1.7)^2 / 2 * landing run * 8 scaling

LANDING		STRUCT

LND_DECEL	DW	0		;deceleration (ft/sec/sec * 8)

LANDING		ENDS

LAND_PITCH_DN	EQU	8*128		;landing pitch down rate (fine pdegs / sec)

RESUPPLY_DELAY	EQU	15*100		;time to resupply aircraft (1/100ths sec)

;-----------------------
;* landing run = 1,500ft
;-----------------------

Landing1	LANDING	<130>

;-----------------------
;* landing run = 2,000ft
;-----------------------

Landing2	LANDING	<98>

;-----------------------
;* landing run = 3,000ft
;-----------------------

Landing3	LANDING	<65>

;-------------------
;* combat parameters
;-------------------

MIN_GMAX	EQU	6*16		;keep g max >= 6g

COMBAT		STRUCT

COM_SHELLS	DB	0		;number of cannon shells
COM_MISSILES	DB	0		;number of missiles
COM_ROLL_RATE	DW	0		;max roll rate (fine pdegs/sec)
COM_GMAX	DW	0		;g limit (g * 16)
COM_ACCEL	DW	0		;acceleration (ft/sec/sec * 8)

COMBAT		ENDS

;------------------------
;* F3 Tornado combat data
;------------------------

Combat1		COMBAT <50,8,32767,120,32*8>

;-----------------------------
;* Mig-31 Foxhound combat data
;-----------------------------

Combat2		COMBAT <50,8,16384,96,32*8>

;------------------------
;* F-15 Eagle combat data
;------------------------

Combat3		COMBAT <100,8,21845,117,32*8>

;---------------------------
;* Su-27 Flanker combat data
;---------------------------

Combat4		COMBAT <100,8,27307,160,32*8>

;-------------------------
;* F-16 Falcon combat data
;-------------------------

Combat5		COMBAT <75,6,32767,144,32*8>

;----------------------------
;* Mig-29 Fulcrum combat data
;----------------------------

Combat6		COMBAT <75,6,32767,144,32*8>

;------------------
;* track parameters
;------------------

AH_MAX_ROLL	EQU	85*128		;60 degs

AH_ROLL_RATE	EQU	64*128		;45 degs / sec

;-----------
;* taxi data
;-----------

TaxiWP		WAYPOINT <>		;temporary waypoint for taxiing

TAXI_SPEED_FAST	EQU	680		;50kts
TAXI_SPEED_SLOW	EQU	204		;15kts

;-------------
;* combat data
;-------------

COMBAT_FLOOR	EQU	200
COMBAT_CEILING	EQU	50000

GND_CHECK_ALT	EQU	10000

BREAK_ALT	EQU	5000

AC_Vias		DW	0

AC_DivVias     	DW	1360		;vias used in division (100kts min)
AC_DivVtas     	DW	1360		;vtas used in division (100kts min)

ICPOINT		VIEWPOINT <>		;intercept point

ScaledRange	DW	0

Xt		DW	0		; )
Yt		DW	0		; ) transformed co-ords
Zt		DW	0		; )

HdgError	DW	0
PitchError	DW	0
BrgError	DW	0
CosBrgError	DW	0

MaxRRate	DW	0		;max roll rate (fine pdegs/sec)
MaxPRate	DW	0		;max pitch rate (fine pdegs/sec)
MaxGForce	DW	0		;max g-force [*16]

RollDemand	DW	0		;roll demand (fine pdegs)
DampedRoll	DW	0		;damped roll demand (fine pdegs)

PitchRate	DW	0		;pitch rate (fine pdegs/sec)

OppVtas		DW	0		;opponent speed (ft/sec * 8)

TornadoOppPtr	DW	-1		;-1 = no opponent

TmpSrcPtr	DW	-1
TmpICPtr	DW	-1
TmpICRng	DD	-1

ResponseTimer	DW	0		;interceptor response time (secs * 100)

EWRExposeTimer	DW	0		;EWR exposure timer (secs * 100)

BreakTimer	DW	0		;forced break timer (secs * 100)

VERY_LOW	EQU	600		;(chosen so not too near TF alt)
VERY_FAST	DW	0		;(used to be an EQUate)

ErrorScale	DB	0

OppBehind	DB	0

BreakFlag	DB	0		;enforced break flag

		EVEN

DATA		ENDS

;============================================================================

DRONECODE	SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:DRONECODE
		ASSUME DS:DATA

;* InitPlanes - initialize drone aircraft
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

InitPlanes	PROC	FAR

		mov	si,OFFSET AAircraft1
		call	InitOnePlane

		mov	si,OFFSET AAircraft2
		call	InitOnePlane

		mov	si,OFFSET AAircraft3
		call	InitOnePlane

		mov	si,OFFSET AAircraft4
		call	InitOnePlane

		mov	si,OFFSET AAircraft5
		call	InitOnePlane

		mov	si,OFFSET AAircraft6
		call	InitOnePlane

		mov	si,OFFSET AAircraft7
		call	InitOnePlane

		mov	si,OFFSET AAircraft8
		call	InitOnePlane

		mov	si,OFFSET AAircraft9
		call	InitOnePlane

		mov	si,OFFSET AAircraft10
		call	InitOnePlane

		mov	si,OFFSET AAircraft11
		call	InitOnePlane

		mov	si,OFFSET AAircraft12
		call	InitOnePlane

		mov	si,OFFSET AAircraft13
		call	InitOnePlane

		mov	si,OFFSET AAircraft14
		call	InitOnePlane

		mov	si,OFFSET AAircraft15
		call	InitOnePlane

		mov	si,OFFSET AAircraft16
		call	InitOnePlane

		mov	si,OFFSET AAircraft17
		call	InitOnePlane

		mov	si,OFFSET EAircraft1
		call	InitOnePlane

		mov	si,OFFSET EAircraft2
		call	InitOnePlane

		mov	si,OFFSET EAircraft3
		call	InitOnePlane

		mov	si,OFFSET EAircraft4
		call	InitOnePlane

		mov	si,OFFSET EAircraft5
		call	InitOnePlane

		mov	si,OFFSET EAircraft6
		call	InitOnePlane

		mov	si,OFFSET EAircraft7
		call	InitOnePlane

		mov	si,OFFSET EAircraft8
		call	InitOnePlane

		mov	si,OFFSET EAircraft9
		call	InitOnePlane

		mov	si,OFFSET EAircraft10
		call	InitOnePlane

		mov	si,OFFSET EAircraft11
		call	InitOnePlane

		mov	si,OFFSET EAircraft12
		call	InitOnePlane

		mov	si,OFFSET EAircraft13
		call	InitOnePlane

		mov	si,OFFSET EAircraft14
		call	InitOnePlane

		mov	si,OFFSET EAircraft15
		call	InitOnePlane

		mov	si,OFFSET EAircraft16
		call	InitOnePlane

		mov	si,OFFSET EAircraft17
		call	InitOnePlane

;-------------
;* init values
;-------------

		call	SetEWRTimer

		call	SetBreakTimer

		call	SetVeryFast

		ret

InitPlanes	ENDP

;----------------------------------------------------------------------------

;* InitOnePlane - initialize single drone aircraft
;*
;* pass: si -> MOBILE + VIEWPOINT + AIRCRAFT compound data block
;* ret : nothing
;* kill: assume all

InitOnePlane	PROC	NEAR

;----------------------------
;* test if aircraft is active
;----------------------------

		cmp	_AC_SIDE[si],DEAD	;aircraft active?
		_JE	InitOneExit  		;no ->

;---------------------------
;* init miscellaneous values
;---------------------------

		xor	ax,ax

		mov	_VP_PITCH[si],ax
		mov	_VP_ROLL[si],ax

		mov	_AC_EVENT[si],al
		mov	_AC_XFINE[si],ax
		mov	_AC_YFINE[si],ax
		mov	_AC_ZFINE[si],ax
		mov	_AC_PFINE[si],ax
		mov	_AC_RFINE[si],ax
		mov	_AC_VTAS[si],ax
		mov	_AC_VTAS_FINE[si],ax
		mov	_AC_LIFT_VCTR[si],ax
		mov	_AC_AB_DELAY[si],al
		mov	_AC_SWEEP_DELAY[si],al

;--------------------------------------
;* init waypoint ptr to second waypoint
;--------------------------------------

		mov	di,si
		add	di,AC_WAYPOINTS+WAY_REC_SIZE	;di -> second waypoint
		
		mov	_AC_WP_PTR[si],di

		sub	di,WAY_REC_SIZE		;di -> first waypoint

;--------------------------------------
;* sort control mode wrt first waypoint
;--------------------------------------

		xchg	si,di			;si -> first waypoint
		call	SortControlMode
		xchg	si,di			;si -> compound data block

		cmp	dx,CTRL_TAKEOFF		;takeoff?
		je	SetCtrlMode		;yes ->

;----------------
;* start airborne
;----------------

;* speed = waypoint speed

		mov	di,si
		add	di,AC_WAYPOINTS		;di -> first waypoint

		mov	ax,WP_SPEED[di]
		mov	_AC_VTAS[si],ax

SetCtrlMode:	mov	_AC_CTRL_MODE[si],dx

;-------------------
;* init heading fine
;-------------------

		mov	cl,7		;*128

		mov	ax,_VP_HDG[si]
		shl	ax,cl
		mov	_AC_HFINE[si],ax

;----------------
;* init animation
;----------------

		xor	al,al

;* if IL-76 Mainstay then show radome

		cmp	_AC_TYPE[si],IL76_MAINSTAY	;IL76 Mainstay?
		jne	@F	     			;no ->

		or	al,AC_SPECIALS

@@:		mov	MOB_ANIM[si],al

;------------------
;* init decoy timer
;------------------

		call	RandX		;0.00 .. 2.55
		shr	ax,1		;0.00 .. 1.27
		add	ax,150		;1.50 .. 2.77

		mov	_AC_DECOY_TIMER[si],ax

;------------------------
;* init AA activity timer
;------------------------

		call	SetAATimer

;--------------
;* init weapons
;--------------

		mov	bx,_AC_TYPE[si]
		mov	bx,PerfDataPtrs[bx]

		mov	bx,[bx].PERF_COMBAT

		cmp	bx,-1		;combat valid?
		je	InitOneExit	;no ->

		mov	al,[bx].COM_SHELLS
		mov	_AC_SHELLS[si],al
		mov	al,[bx].COM_MISSILES
		mov	_AC_MISSILES[si],al
		
InitOneExit:	ret

InitOnePlane	ENDP

;----------------------------------------------------------------------------

;* UpdatePlanes - update drone aircraft
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

UpdatePlanes	PROC	FAR

		call	TornadoAction

		call	DroneAction

		mov	si,OFFSET AAircraft1
		call	UpdateOnePlane

		mov	si,OFFSET AAircraft2
		call	UpdateOnePlane

		mov	si,OFFSET AAircraft3
		call	UpdateOnePlane

		mov	si,OFFSET AAircraft4
		call	UpdateOnePlane

		mov	si,OFFSET AAircraft5
		call	UpdateOnePlane

		mov	si,OFFSET AAircraft6
		call	UpdateOnePlane

		mov	si,OFFSET AAircraft7
		call	UpdateOnePlane

		mov	si,OFFSET AAircraft8
		call	UpdateOnePlane

		mov	si,OFFSET AAircraft9
		call	UpdateOnePlane

		mov	si,OFFSET AAircraft10
		call	UpdateOnePlane

		mov	si,OFFSET AAircraft11
		call	UpdateOnePlane

		mov	si,OFFSET AAircraft12
		call	UpdateOnePlane

		mov	si,OFFSET AAircraft13
		call	UpdateOnePlane

		mov	si,OFFSET AAircraft14
		call	UpdateOnePlane

		mov	si,OFFSET AAircraft15
		call	UpdateOnePlane

		mov	si,OFFSET AAircraft16
		call	UpdateOnePlane

		mov	si,OFFSET AAircraft17
		call	UpdateOnePlane

		mov	si,OFFSET EAircraft1
		call	UpdateOnePlane

		mov	si,OFFSET EAircraft2
		call	UpdateOnePlane

		mov	si,OFFSET EAircraft3
		call	UpdateOnePlane

		mov	si,OFFSET EAircraft4
		call	UpdateOnePlane

		mov	si,OFFSET EAircraft5
		call	UpdateOnePlane

		mov	si,OFFSET EAircraft6
		call	UpdateOnePlane

		mov	si,OFFSET EAircraft7
		call	UpdateOnePlane

		mov	si,OFFSET EAircraft8
		call	UpdateOnePlane

		mov	si,OFFSET EAircraft9
		call	UpdateOnePlane

		mov	si,OFFSET EAircraft10
		call	UpdateOnePlane

		mov	si,OFFSET EAircraft11
		call	UpdateOnePlane

		mov	si,OFFSET EAircraft12
		call	UpdateOnePlane

		mov	si,OFFSET EAircraft13
		call	UpdateOnePlane

		mov	si,OFFSET EAircraft14
		call	UpdateOnePlane

		mov	si,OFFSET EAircraft15
		call	UpdateOnePlane

		mov	si,OFFSET EAircraft16
		call	UpdateOnePlane

		mov	si,OFFSET EAircraft17
		call	UpdateOnePlane

		ret

UpdatePlanes	ENDP

;----------------------------------------------------------------------------

;* UpdateOnePlane - update single drone aircraft
;*
;* pass: si -> MOBILE + VIEWPOINT + AIRCRAFT compound data block
;* ret : nothing
;* kill: assume all

UpdateOnePlane	PROC	NEAR

;----------------------------
;* test if aircraft is active
;----------------------------

		cmp	_AC_SIDE[si],DEAD	;aircraft active?
		je	UpdateOneExit		;no ->

		mov	AircraftPtr,si		;store original data ptr

;-----------------------------------
;* copy aircraft data into workspace
;-----------------------------------

		mov	cx,AC_DATA_SIZE
		mov	di,OFFSET AC_Workspace
		FAST_MOVE

;---------------------------
;* sort performance data ptr
;---------------------------

		mov	bx,AC_Data.AC_TYPE
		mov	ax,PerfDataPtrs[bx]
		mov	PerfDataPtr,ax

;---------------------
;* select control mode
;---------------------

		mov	bx,AC_Data.AC_CTRL_MODE
		call	ControlMode[bx]

;--------------------------
;* update aircraft position
;--------------------------

		call	CalcAngles

		call	CalcDeltaXYZ

;-----------------------------------
;* copy aircraft data from workspace 
;-----------------------------------

;* IMPORTANT: Copy aircraft data from workspace back to its original position
;*            before calling UpdateMobile. If the aircraft changes sector the
;*            delete / create mobile routines require the original address of
;*            the data as a reference.

		mov	bp,cx		;store delta zft

		mov	cx,AC_DATA_SIZE
		mov	si,OFFSET AC_Workspace
		mov	di,AircraftPtr
		FAST_MOVE

		mov	cx,bp		;restore delta zft

;----------------------
;* update mobile object
;----------------------

		mov	si,AircraftPtr
		call	UpdateMobile

		call	GroundCheck

;------------------------
;* weapon evasion tactics
;------------------------

		call	EvasionTactics

;--------------------
;* update AA activity
;--------------------

		call	AAActivity
	
UpdateOneExit:	ret

UpdateOnePlane	ENDP

;----------------------------------------------------------------------------

;* CtrlNull - do nothing
;*
;* pass: nothing
;* ret : nothing
;* kill: nothing

CtrlNull	PROC	NEAR

		ret

CtrlNull	ENDP

;----------------------------------------------------------------------------

;* CtrlTakeoff - takeoff control
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

CtrlTakeoff	PROC	NEAR

;-------------------------------
;* wait for event before takeoff
;-------------------------------

		cmp	AC_Data.AC_EVENT_NUM,-1	;wait for event?
		je	SortDelay		;no ->

		mov	bl,AC_Data.AC_DRONE_NUM	;fetch drone number
		xor	bh,bh
		shl	bx,1			;*2 word index

		mov	di,DronePtrs[bx]	;di -> drone data

		mov	al,_DRONE_EVENT[di]

		cmp	al,AC_Data.AC_EVENT_NUM	;event satisfied?
		_JB	SortTakeoffAnim		;no ->

		mov	AC_Data.AC_DRONE_NUM,0	;clear event
		mov	AC_Data.AC_EVENT_NUM,-1

		mov	AC_Data.AC_DELAY,DLY_AFTER_EVENT

;----------------------
;* delay before takeoff
;----------------------

SortDelay:	mov	ax,AC_Data.AC_DELAY
		test	ax,ax			;delay?
		jz	@F			;no ->

		sub	ax,LastFrame

		MINM	ax

		mov	AC_Data.AC_DELAY,ax

		jmp	SortTakeoffAnim

;----------------------------
;* pick up takeoff parameters
;----------------------------

@@:		mov	di,PerfDataPtr
		mov	di,PERF_TAKEOFF[di]

;------------
;* accelerate
;------------

;* accel = TO_ACCEL * DeltaTime

		mov	ax,TO_ACCEL[di]
		mov	dx,DeltaTime
		imul	dx

		shl	ax,1		;align for dx = accel, ax = accel fine
		rcl	dx,1

		add	AC_Data.AC_VTAS_FINE,ax
		adc	AC_Data.AC_VTAS,dx

;---------------------------------------------------
;* rotate aircraft and lift vector to ROTATION_ANGLE 
;---------------------------------------------------

;* if aircraft fully rotated then rotate lift vector

		cmp	AC_Data.AC_PFINE,ROTATION_ANGLE	;fully rotated?
		je	SortLiftVector			;yes ->

;* if speed > rotation speed then rotate

		mov	ax,AC_Data.AC_VTAS

		cmp	ax,TO_V_ROTATE[di]	;speed > rotation speed?
		jle	SortTakeoffAnim		;no ->

;* rotate aircraft

		mov	ax,TO_R_RATE[di]
		mov	dx,DeltaTime
		imul	dx
		FRACADJ	ax		;rotation rate * DeltaTime

		add	ax,AC_Data.AC_PFINE

		cmp	ax,ROTATION_ANGLE	;angle > ROTATION_ANGLE?
		jle	@F			;no ->

		mov	ax,ROTATION_ANGLE	;limit

@@:		mov	AC_data.AC_PFINE,ax

		jmp	SortTakeoffAnim

;* rotate lift vector

SortLiftVector:	mov	ax,TO_L_RATE[di]
		mov	dx,DeltaTime
		imul	dx
		FRACADJ	ax		;lift rate * DeltaTime

		add	ax,AC_Data.AC_LIFT_VCTR

		cmp	ax,ROTATION_ANGLE	;angle > ROTATION_ANGLE?
		jle	@F			;no ->

;* takeoff satisfied

		mov	si,AC_Data.AC_WP_PTR

		call	SortControlMode

		mov	AC_Data.AC_CTRL_MODE,dx

		mov	ax,ROTATION_ANGLE	;limit

@@:		mov	AC_Data.AC_LIFT_VCTR,ax

;------------------------
;* sort takeoff animation
;------------------------

SortTakeoffAnim:mov	al,AC_Mobile.MOB_ANIM

		and	al,NOT (GEAR_DOWN+REHEAT_ALL)	;gear up, reheat off

;* reheat on if moving

		cmp	AC_Data.AC_VTAS,0	;moving?
		je	@F		 	;no ->

		or	al,REHEAT_ALL

;* raise gear when zft > 10ft

@@:		cmp	WORD PTR AC_View.VP_ZFT_LO,10	;gear up?
		ja	@F				;yes ->

		or	al,GEAR_DOWN

@@:		mov	AC_Mobile.MOB_ANIM,al

		ret

CtrlTakeoff	ENDP

;----------------------------------------------------------------------------

;* CtrlTrack - track control (fly from waypoint to waypoint)
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

CtrlTrack	PROC	NEAR

		call	AutoRoute

		mov	ax,AC_AutoHFine
		call	AutoHeading

		mov	ax,AC_AutoAlt
		call	AutoAltitude

		mov	ax,AC_AutoVtas
		call	AutoThrottle

		call	AutoBomb

		ret

CtrlTrack	ENDP

;----------------------------------------------------------------------------

;* CtrlApproach - final approach
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

CtrlApproach	PROC	NEAR

;------------------
;* fly approach leg
;------------------

		call	AutoRoute

		mov	ax,AC_AutoHFine
		call	AutoHeading

		mov	ax,AC_AutoAlt
		call	AutoAltitude

		xor	ax,ax		;fly at min speed
		call	AutoThrottle

;-------------------------------------
;* switch to touchdown when zft < 50ft
;-------------------------------------

		cmp	WORD PTR AC_View.VP_ZFT_HI,0	;zft > 65,535ft?
		ja	@F				;yes ->

		cmp	WORD PTR AC_View.VP_ZFT_LO,50	;touchdown?
		jae	@F				;no ->

		mov	AC_Data.AC_CTRL_MODE,CTRL_TOUCHDOWN

;---------------------
;* sort gear animation
;---------------------

@@:		or	AC_Mobile.MOB_ANIM,GEAR_DOWN

		ret

CtrlApproach	ENDP

;----------------------------------------------------------------------------

;* CtrlLanding - pitch flare and touchdown
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all
;*
;* note: Assume speed and lift vector are stable.

CtrlTouchDown	PROC	NEAR

;-----------------------------
;* pitch flare when zft < 16ft
;-----------------------------

;* if zft < 16ft then
;*    pitch flare = (16 - zft) * 64 fine pdegs (approx. 5 deg flare)
;* endif

		cmp	WORD PTR AC_View.VP_ZFT_HI,0	;zft > 65,535ft?
		ja	@F				;yes ->

		cmp	WORD PTR AC_View.VP_ZFT_LO,16	;pitch flare?
		jae	@F				;no ->

		mov	ax,16

		sub	ax,WORD PTR AC_View.VP_ZFT_LO

		xchg	al,ah		;*256
		REPT	2		;*64
		shr	ax,1
		ENDM

		add	ax,1400		;steady state pitch + flare

		mov	AC_Data.AC_PFINE,ax

;------------------------------------
;* switch to landing run when zft = 0
;------------------------------------

@@:		mov	ax,WORD PTR AC_View.VP_ZFT_HI
		or	ax,WORD PTR AC_View.VP_ZFT_LO
		or	ax,AC_Data.AC_ZFINE
		jnz	@F			;still airborne ->

		mov	AC_Data.AC_CTRL_MODE,CTRL_LANDING

		mov	AC_Data.AC_LIFT_VCTR,0

@@:		ret

CtrlTouchDown	ENDP

;----------------------------------------------------------------------------

;* CtrlLanding - landing run
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

CtrlLanding	PROC	NEAR

;----------------------------
;* pick up landing parameters
;----------------------------

		mov	di,PerfDataPtr
		mov	di,PERF_LANDING[di]

;------------
;* decelerate
;------------

;* decel = LND_DECEL * DeltaTime

		mov	ax,LND_DECEL[di]
		mov	dx,DeltaTime
		imul	dx

		shl	ax,1		;align for dx = decel, ax = decel fine
		rcl	dx,1

		sub	AC_Data.AC_VTAS_FINE,ax
		sbb	AC_Data.AC_VTAS,dx

		jns	SkipRestart	;vtas >= 0 ->

		xor	ax,ax
		mov	AC_Data.AC_VTAS_FINE,ax
		mov	AC_Data.AC_VTAS,ax

;-----------------------------------------------
;* aircraft stopped resupply and restart mission
;-----------------------------------------------

		mov	AC_Data.AC_EVENT,al
		mov	AC_Data.AC_DELAY,RESUPPLY_DELAY
		mov	AC_Data.AC_DRONE_NUM,al
		mov	AC_Data.AC_EVENT_NUM,-1
		mov	AC_Data.AC_AB_DELAY,al
		mov	AC_Data.AC_SWEEP_DELAY,al
		mov	AC_Data.AC_PFINE,ax
		mov	AC_Data.AC_RFINE,ax

		mov	si,AircraftPtr
		add	si,AC_WAYPOINTS+WAY_REC_SIZE	;ptr -> second waypoint
		mov	AC_Data.AC_WP_PTR,si

		mov	si,PerfDataPtr
		mov	si,[si].PERF_COMBAT

		cmp	si,-1		;combat valid?
		je	@F		;no ->

		mov	al,[si].COM_SHELLS
		mov	AC_Data.AC_SHELLS,al

		mov	al,[si].COM_MISSILES
		mov	AC_Data.AC_MISSILES,al

@@:		and	AC_Data.AC_FLAGS,NOT AFLG_BREAK

		mov	AC_Data.AC_CTRL_MODE,CTRL_TAKEOFF

		jmp	ExitLanding

;------------
;* pitch down
;------------

SkipRestart:	mov	ax,LAND_PITCH_DN
		mov	dx,DeltaTime
		imul	dx
		FRACADJ	dx		;pitch down rate * DeltaTime

		sub	AC_Data.AC_PFINE,dx

		jns	ExitLanding	;pitch >= 0 ->

		mov	AC_Data.AC_PFINE,0	;fully pitched down

;---------------------------------------------
;* check if restart mission or taxi off runway
;---------------------------------------------

		cmp	AC_Data.AC_VTAS,TAXI_SPEED_FAST	;speed <= taxi speed?
		ja	ExitLanding			;no ->

		mov	si,AC_Data.AC_WP_PTR

		cmp	WP_ACTION[si],AC_WP_RESTART	;restart mission?
		je	ExitLanding			;yes ->

		call	InitTaxi

ExitLanding:	ret

CtrlLanding	ENDP

;----------------------------------------------------------------------------

;* InitTaxi - initialize taxi
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

InitTaxi	PROC	NEAR

;---------------------------------
;* sort pointer to taxi route data
;---------------------------------

;* calc map index assuming xsec, ysec is on map (index = xsec + ysec * 32)

		mov	bp,AC_View.VP_YSEC

		mov	cl,5		;*32
		shl	bp,cl

		add	bp,AC_View.VP_XSEC

;* index = (special number - 1) * 2

		mov	bl,SpecialLayer1[bp]	;special number

		sub	bl,AIRFIELD_1
		xor	bh,bh

		shl	bx,1

		mov	si,TaxiRoutePtrs[bx]	;si -> taxi route ptrs

;* select route wrt heading:-
;*
;* hdg N (448 ..  63 pdegs), offset = 0
;* hdg E ( 64 .. 191 pdegs), offset = 2
;* hdg S (192 .. 319 pdegs), offset = 4
;* hdg W (320 .. 447 pdegs), offset = 6
;*
;* offset = ((hdg + 64) and 00180h) / 64

		mov	bx,AC_View.VP_HDG
		add	bx,64
		and	bx,00180h
		mov	cl,6		;/64
		shr	bx,cl

		mov	si,[si+bx]	;si -> TAXI data

		cmp	si,-1		;taxi route available?
		je	@F		;no (error) ->

		mov	AC_Data.AC_TAXI_PTR,si

		add	si,TAXI_REC_SIZE	;si -> first taxi route point

		mov	AC_Data.AC_WP_PTR,si

		call	SortTaxiXY

		mov	AC_Data.AC_CTRL_MODE,CTRL_TAXI

		jmp	ExitInitTaxi

;* no taxi route (error condition), stop aircraft

@@:		xor	ax,ax
		mov	AC_Data.AC_VTAS_FINE,ax
		mov	AC_Data.AC_VTAS,ax
		
		mov	AC_Data.AC_CTRL_MODE,CTRL_NULL

ExitInitTaxi:	ret

InitTaxi	ENDP

;----------------------------------------------------------------------------

;* CtrlTaxi - taxi off runway
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

CtrlTaxi	PROC	NEAR

;----------------------------------------
;* calc taxi route node range and bearing
;----------------------------------------

		call	CalcTaxiRngBrg

;--------------------
;* sort taxiing speed
;--------------------

;* if first waypoint then
;*    if range > 1,000ft then
;*       aiming speed = TAXI_SPEED_FAST
;*    else
;*       aiming speed = TAXI_SPEED_SLOW
;*    endif
;* else
;*    if last waypoint then
;*       if range > 100ft then
;*          aiming speed = TAXI_SPEED_SLOW
;*       else
;*          aiming speed = 0
;*       endif
;*    else
;*       aiming speed = TAXI_SPEED_SLOW
;*    endif
;* endif

		mov	si,AC_Data.AC_TAXI_PTR
		mov	di,si
		add	di,TAXI_REC_SIZE	;di -> first point

		cmp	di,AC_Data.AC_WP_PTR	;taxiing to first point?
		jne	@F			;no ->

		mov	bp,TAXI_SPEED_FAST	;assume > 1,000ft

		cmp	WORD PTR AC_WPRng,1000	;range > 1,000ft?
		ja	SortSpeed		;yes ->

		mov	bp,TAXI_SPEED_SLOW

		jmp	SortSpeed

@@:		mov	di,TAXI_END_PTR[si]	;di -> last point

		mov	bp,TAXI_SPEED_SLOW	;assume not last point

		cmp	di,AC_Data.AC_WP_PTR	;taxiing to last point?
		jne	SortSpeed		;no ->

		cmp	WORD PTR AC_WPRng,100	;range > 100ft?
		ja	SortSpeed		;yes ->

		xor	bp,bp

;* if vtas > aiming speed then
;*    decelerate to aiming speed
;* else
;*    speed = aiming speed (not expecting to have to accelerate)
;* endif

SortSpeed:	cmp	AC_Data.AC_VTAS,bp	;accel or decel?
		ja	TaxiDecel		;decel ->
		jb	TaxiAccel		;accel ->

		cmp	AC_Data.AC_VTAS_FINE,0
		ja	TaxiDecel		;decel ->

TaxiAccel:	mov	AC_Data.AC_VTAS,bp
		mov	AC_Data.AC_VTAS_FINE,0

		jmp	TaxiSpeedOk

TaxiDecel: 	mov	ax,5*8		;5ft/sec/sec decel
		mov	dx,DeltaTime
		imul	dx

		shl	ax,1		;align for dx = decel, ax = decel fine
		rcl	dx,1

		sub	AC_Data.AC_VTAS_FINE,ax
		sbb	AC_Data.AC_VTAS,dx

		jns	@F		;vtas >= 0 ->

		xor	ax,ax
		mov	AC_Data.AC_VTAS_FINE,ax
		mov	AC_Data.AC_VTAS,ax

		mov	AC_Data.AC_CTRL_MODE,CTRL_NULL

		jmp	ExitTaxi

@@:		cmp	AC_Data.AC_VTAS,bp	;vtas < aiming speed?
		jae	TaxiSpeedOk		;no ->

		mov	AC_Data.AC_VTAS,bp
		mov	AC_Data.AC_VTAS_FINE,0

;----------------------------
;* satisfied taxi route node?
;----------------------------

TaxiSpeedOk:	cmp	WORD PTR AC_WPRng,40	;within 40ft of waypoint?
		jae	SortTaxiHdg		;no ->

;---------------------------
;* taxi route node satisfied (advance to next)
;---------------------------

		mov	si,AC_Data.AC_TAXI_PTR
		mov	di,AC_Data.AC_WP_PTR

		cmp	di,TAXI_END_PTR[si]	;end of taxi route?
		je	SortTaxiHdg		;yes, do not advance ->
		
		add	AC_Data.AC_WP_PTR,TNODE_REC_SIZE	;advance

		call	SortTaxiXY

		call	CalcTaxiRngBrg

;--------------------------
;* sort heading to waypoint
;--------------------------

;* do not adjust hdg if too close (avoid jitter)

SortTaxiHdg:	cmp	WORD PTR AC_WPRng,128	;within 128ft?
		jbe	ExitTaxi	   	;yes ->

;* calc hdg rate (wrt time)

		mov	ax,64*128	;45degs/sec
		mov	dx,DeltaTime
		imul	dx
		FRACADJ	bp		;bp = hdg rate

;* calc hdg error and sign

		mov	ax,AC_WPBrgFine
		sub	ax,AC_Data.AC_HFINE
		ABSV	ax		;ax = hdg error, dx = sign error

;* delta hdg = min(hdg error, hdg rate)

		cmp	ax,bp		;error <= rate?
		jbe	@F		;yes ->

		mov	ax,bp		;set error to rate

@@:		xor	ax,dx		;restore sign
		sub	ax,dx
		
		add	AC_Data.AC_HFINE,ax

ExitTaxi:	ret

CtrlTaxi	ENDP

;----------------------------------------------------------------------------

;* SortTaxiXY - sort taxi point xft, yft
;*
;* pass: AC_WP_PTR
;*       AC_TAXI_PTR
;* ret : AC_TAXI_XFT
;*       AC_TAXI_YFT
;* kill: ax, si, di, flags

SortTaxiXY	PROC	NEAR

		mov	si,AC_Data.AC_TAXI_PTR
		mov	di,AC_Data.AC_WP_PTR

		mov	ax,TNODE_XFT[di]
		mov	AC_Data.AC_TAXI_XFT,ax
		mov	ax,TNODE_YFT[di]
		mov	AC_Data.AC_TAXI_YFT,ax

;* if last taxi point then modify co-ords for next aircraft

		cmp	di,TAXI_END_PTR[si]	;last point?
		jne	@F			;no ->

		mov	ax,TAXI_X_MOD[si]
		add	TNODE_XFT[di],ax
		mov	ax,TAXI_Y_MOD[si]
		add	TNODE_YFT[di],ax

@@:		ret

SortTaxiXY	ENDP

;----------------------------------------------------------------------------

;* CalcTaxiRngBrg - calc taxi route node range and bearing
;*
;* pass: nothing
;* ret : AC_WPRng = dx, ax = range
;*       AC_WPBrg = bx = si = bearing (pdegs)
;*       AC_WPBrgFine = bp = di = bearing (fine pdegs)
;* kill: cx, flags
;*
;* note: Assume range < 65,536ft as the viewpoint and waypoint are in the same
;*       sector.

CalcTaxiRngBrg	PROC	NEAR

;------------------------------------------
;* create temp waypoint for taxi route node (to calc range and bearing)
;------------------------------------------

		mov	ax,AC_View.VP_XSEC
		mov	TaxiWP.WP_XSEC,ax
		mov	ax,AC_View.VP_YSEC
		mov	TaxiWP.WP_YSEC,ax

		mov	ax,AC_Data.AC_TAXI_XFT
		mov	TaxiWP.WP_XFT,ax
		mov	ax,AC_Data.AC_TAXI_YFT
		mov	TaxiWP.WP_YFT,ax

;-------------------------------------------
;* calc range and bearing of taxi route node
;-------------------------------------------

		mov	si,OFFSET AC_View
		mov	di,OFFSET TaxiWP

		call	CalcRngBrgVP_WP

		mov	WORD PTR AC_WPRng+2,dx
		mov	WORD PTR AC_WPRng,ax
		mov	AC_WPBrg,bx
		mov	AC_WPBrgFine,bp

		ret

CalcTaxiRngBrg	ENDP

;----------------------------------------------------------------------------

;* AutoRoute - fly from waypoint to waypoint
;*
;* pass: nothing
;* ret : AC_AutoHFine
;*       AC_AutoAlt
;*       AC_AutoVtas
;*       AC_WPRng	
;*       AC_WPBrg 	
;*       AC_WPBrgFine
;* kill: assume all
;*
;* note: This routine sets up parameters for AutoHeading and AutoAltitude
;*       so call AutoRoute before calling these routines.

AutoRoute	PROC	NEAR

;---------------------------------
;* assume heading change inhibited (restore previous value)
;---------------------------------

		mov	ax,AC_Data.AC_HFINE

		mov	AC_AutoHFine,ax

;----------------------------------
;* assume altitude change inhibited (restore previous value)
;----------------------------------

		mov	ax,WORD PTR AC_View.VP_ZFT_LO

		mov	AC_AutoAlt,ax

;-------------------------------
;* assume speed change inhibited (restore previous value)
;------------------------------

		mov	ax,AC_Data.AC_VTAS

		mov	AC_AutoVtas,ax

;--------------------------------------------
;* calc range and bearing of current waypoint
;--------------------------------------------

		mov	si,OFFSET AC_View	;si -> viewpoint
		mov	di,AC_Data.AC_WP_PTR	;di -> current waypoint
		call	CalcRngBrgVP_WP

		mov	WORD PTR AC_WPRng+2,dx
		mov	WORD PTR AC_WPRng,ax
		mov	AC_WPBrg,bx
		mov	AC_WPBrgFine,bp

;------------------------------
;* inhibit change if "arm lock"
;------------------------------

		cmp	AC_Data.AC_ARM_LOCK,0
		je	SkipArmLock

;* check if package delivered
		
		mov	si,AC_Data.AC_WP_PTR

		cmp	[si].WP_PACKAGE,WPACK_NULL
		_JNE	ExitRoute

;* update weapon clearance delay

		mov	ax,AC_Data.AC_ARM_LOCK
		sub	ax,LastFrame
		MINM	ax
		mov	AC_Data.AC_ARM_LOCK,ax

		jz	SatisfiedWP

		jmp	ExitRoute

;---------------------
;* satisfied waypoint?
;---------------------

SkipArmLock:	mov	si,AC_Data.AC_WP_PTR

		test	WP_ATTR[si],WP_TYPE	;turning or target waypoint?
		jnz	TargetWP		;target ->

;------------------
;* turning waypoint (turn early to next waypoint to keep on track)
;------------------

		call	CalcTurnDist

		cmp	WORD PTR AC_WPRng+2,0	;range > turn dist?
		ja	WPOk			;yes ->
		cmp	WORD PTR AC_WPRng,ax	;range > turn dist?
		jae	WPOk			;yes ->

		jmp	SatisfiedWP

;-----------------
;* target waypoint (fly over waypoint)
;-----------------

TargetWP	LABEL	NEAR

;* within 1/2NM of waypoint?

		cmp	WORD PTR AC_WPRng+2,0
		ja	WPOk			;no ->
		cmp	WORD PTR AC_WPRng,6076/2
		jae	WPOk			;no ->

		mov	ax,AC_View.VP_HDG
		mov	dx,AC_WPBrg
		call	CalcAngDiff

		cmp	ax,128		;error > 90 degs?
		jbe	WPOk		;no ->

;--------------------
;* waypoint satisfied
;--------------------

;* if approach mode then switch to touchdown mode (do not advance to next waypoint)

SatisfiedWP:	cmp	AC_Data.AC_CTRL_MODE,CTRL_APPROACH	;approach mode?
		jne	@F					;no ->

		mov	AC_Data.AC_CTRL_MODE,CTRL_TOUCHDOWN

		jmp	ExitRoute

@@:		call	SelectNextWP

;* sort waypoint action

		mov	si,AC_Data.AC_WP_PTR

		call	SortControlMode

		mov	AC_Data.AC_CTRL_MODE,dx

;--------------------------
;* set heading for waypoint (unless too close - reduce jitter)
;--------------------------

;* within 1/4NM of waypoint?

WPOk:		cmp	WORD PTR AC_WPRng+2,0
		ja	@F			;no ->
		cmp	WORD PTR AC_WPRng,6076/4
		jb	SortWPAlt		;yes ->

@@:		mov	ax,AC_WPBrgFine
		mov	AC_AutoHFine,ax

;------------------------
;* sort waypoint altitude
;------------------------

;* alt = min(waypoint alt, ceiling)

SortWPAlt:	mov	si,AC_Data.AC_WP_PTR
		mov	ax,WP_ZFT[si]

		mov	di,PerfDataPtr
		mov	di,PERF_CRUISE[di]

		cmp	ax,CRS_CEILING[di]	;alt < ceiling?
		jbe	SetAutoAlt		;yes ->

		mov	ax,CRS_CEILING[di]	;limit to ceiling

SetAutoAlt:	mov	AC_AutoAlt,ax

;---------------------
;* sort aircraft speed
;---------------------

		mov	si,AC_Data.AC_WP_PTR

		test	WP_ATTR[si],WP_COORD	;co-ordinate or set speed?
		jnz	@F			;co-ordonate ->

		mov	ax,WP_SPEED[si]

		jmp	SetSpeed

;* calc speed required to reach waypoint on time

@@:		mov	ax,WP_TIME[si]
		mov	dx,100
		mul	dx

;* time to go = waypoint time - elapsed time

		sub	ax,WORD PTR FrameElapTime
		sbb	dx,WORD PTR FrameElapTime+2

;* if already late then set max speed

		js	SetMaxSpeed	;late ->

;* if within 5 secs then inhibit speed change

		cmp	ax,5*100	;inhibit?
		jbe	ExitRoute	;yes ->

		mov	bx,ax
		mov	cx,dx

;* if within 1,000ft then inhibit speed change

		mov	dx,WORD PTR AC_WPRng+2
		mov	ax,WORD PTR AC_WPRng

		cmp	dx,0		;inhibit?
		ja	@F		;no ->
		cmp	ax,1000		;inhibit?
		jbe	ExitRoute 	;yes ->

;* aiming speed = dist * 800 / time (ft/sec * 8)

@@:		REPT	5		;*32
		shl	ax,1
		rcl	dx,1
		ENDM

		mov	si,ax
		mov	di,dx

		REPT	3		;*8 (*256)
		shl	si,1
		rcl	di,1
		ENDM

		add	ax,si		;*32 + *256 = *288
		adc	dx,di

		REPT	1		;*2 (*512)
		shl	si,1
		rcl	di,1
		ENDM

		add	ax,si		;*32 + *256 +*512 = *800
		adc	dx,di

@@:		jcxz	TimeOK

		shr	dx,1
		rcr	ax,1

		shr	cx,1
		rcr	bx,1

		jmp	@B

TimeOk:		cmp	bx,dx		;div ok?
		jbe	SetMaxSpeed	;no ->

		div	bx

SetSpeed:	mov	AC_AutoVtas,ax

ExitRoute:	ret

SetMaxSpeed:	mov	ax,32767

		jmp	SetSpeed

AutoRoute	ENDP

;----------------------------------------------------------------------------

;* SelectNextWP - select next waypoint
;*
;* pass: AC_Data.AC_WP_PTR
;* ret : AC_Data.AC_WP_PTR -> next waypoint
;* kill: assume all

SelectNextWP	PROC	NEAR

		mov	si,AC_Data.AC_WP_PTR
		call	CalcNextWP	  	;di -> next waypoint
		mov	AC_Data.AC_WP_PTR,di

;* update waypoint range and bearing

		mov	si,OFFSET AC_View	;si -> viewpoint
		call	CalcRngBrgVP_WP

		mov	WORD PTR AC_WPRng,ax
		mov	WORD PTR AC_WPRng+2,dx
		mov	AC_WPBrg,bx
		mov	AC_WPBrgFine,bp

		ret

SelectNextWP	ENDP

;----------------------------------------------------------------------------

;* CalcNextWP - calc ptr to next waypoint
;*
;* pass: si -> current waypoint
;* ret : di -> next waypoint
;* kill: flags

CalcNextWP	PROC	NEAR

		test	WP_ATTR[si],WP_LINK	;link back to waypoint?
		jnz	SortLink		;yes ->

		mov	di,si		;di -> current waypoint

		test	WAY_REC_SIZE+WP_ATTR[di],WP_VALID	;next waypoint vaild?
		jz	ExitNextWP				;no, do not advance ->

		add	di,WAY_REC_SIZE	;di -> next waypoint

		jmp	ExitNextWP

;* link back to tagged waypoint

SortLink:	mov	di,AircraftPtr

		add	di,AC_WAYPOINTS	;di -> first waypoint

@@:		cmp	di,si		;di -> current waypoint?
		je	ExitNextWP	;yes, do not advance ->

		test	WP_ATTR[di],WP_HERE	;link back to here?
		jnz	ExitNextWP		;yes ->

		add	di,WAY_REC_SIZE	;advance

		jmp	@B

ExitNextWP:	ret

CalcNextWP	ENDP

;----------------------------------------------------------------------------

;* CalcTurnDist - calc dist at which to start turning to next waypoint
;*		  (in order to keep on track)
;*
;* pass: nothing
;* ret : ax = turning dist (ft)
;* kill: assume all (except ax)

CalcTurnDist	PROC	NEAR

;---------------
;* calc ThetaABC = inside angle of vp(A) -> first wp(B) -> second wp(C)
;---------------

;* ThetaAB = bearing of wp(B) from vp(A)

		mov	si,OFFSET AC_View	;si -> viewpoint
		mov	di,AC_Data.AC_WP_PTR	;di -> current waypoint
		call	CalcRngBrgVP_WP

		mov	AC_ThetaAB,bx

;* ThetaBC = bearing of wp(C) from wp(B)

		mov	si,AC_Data.AC_WP_PTR
		call	CalcNextWP
		call	CalcRngBrgWP_WP

		mov	AC_ThetaBC,bx

;* ThetaABC = abs(256 - abs(ThetaAB - ThetaBC)) (0 .. 511 pdegs)

		mov	ax,AC_ThetaAB
		sub	ax,bx		;ThetaAB - ThetaBC
		ABSV	ax		;abs(ThetaAB - ThetaBC)

		mov	dx,ax
		mov	ax,256
		sub	ax,dx		;256 - abs(ThetaAB - ThetaBC)

		ABSV	ax		;abs(256 - abs(ThetaAB - ThetaBC))

		mov	AC_ThetaABC,ax

;-----------------------------
;* calc RTurn = turning radius
;-----------------------------

;* RTurn = min((vtas^2 / 64) * 588 / 32768, 32767)

		mov	ax,AC_Data.AC_VTAS

		SBOUND	ax,1360,10880

		mul	ax

		mov	bx,ax		;bx, cx = vtas^2 * 64
		mov	cx,dx

		REPT	3		;*8 (*512)
		shl	ax,1
		rcl	dx,1
		ENDM

		add	ax,bx		;dx, ax = vtas^2 * 576
		adc	dx,cx

		REPT	3		;/8 (*8)
		shr	cx,1
		rcr	bx,1
		ENDM

		add	ax,bx		;dx, ax = vtas^2 * 584
		adc	dx,cx

		REPT	1		;/2 (*4)
		shr	cx,1
		rcr	bx,1
		ENDM

		add	ax,bx		;dx, ax = vtas^2 * 588
		adc	dx,cx

		shl	ax,1		;*2/65536 = /32768
		rcl	dx,1
		shl	ax,1
		ROUNDUP	dx

		cmp	dx,32767
		jbe	@F
		mov	dx,32767

@@:		mov	AC_RTurn,dx

;-------------------------------
;* calc TDist = turning distance
;-------------------------------

;* if ThetaABC >= 128 pdegs (90 degs) then
;*    theta = (256 - ThetaABC) / 2  		;***** obtuse angle *****
;*    TDist = RTurn * tan(theta / 2)
;* else
;*    theta = ThetaABC / 2			;***** acute angle *****
;*    TDist = RTurn * 32768 / tan(theta / 2)
;* endif

		cmp	AC_ThetaABC,128	;< 90 degs?
		jb	@F		;yes ->

;------------------------------
;* ThetaABC >= 90 degs (obtuse)
;------------------------------

		mov	ax,256
		sub	ax,AC_ThetaABC
		shr	ax,1
		call	Tangent		;dx = tan(ax) / 2 (refer to TRIG.ASM)
		shl	dx,1

		mov	ax,AC_RTurn
		mul	dx
		FRACADJ	ax

		jmp	ExitTurnDist

;----------------------------
;* ThetaABC < 90 degs (acute)
;----------------------------

@@:		mov	ax,AC_ThetaABC
		shr	ax,1
		call	Tangent		;dx = tan(ax) / 2 (refer to TRIG.ASM)
		shl	dx,1
		mov	bx,dx

		mov	dx,AC_RTurn
		xor	ax,ax

		shr	dx,1		;/2 for frac divide
		rcr	ax,1

		cmp	bx,dx		;div ok?
		jbe	TDistOv		;no ->

		div	bx

ExitTurnDist:	ret

;-----------------------------------
;* if overflow then TDist = 65,535ft
;-----------------------------------

TDistOv:	mov	ax,65535

		ret

CalcTurnDist	ENDP

;----------------------------------------------------------------------------

;* AutoHeading - turn to given heading
;*
;* pass: ax = aiming heading (fine pdegs)
;* ret : AC_Data.AC_HFINE
;*       AC_Data.AC_RFINE
;* kill: assume all
;*
;* note: Based on the Tornado auto-pilot "auto-heading" algorithm. Roll and
;*       heading rates are the same (CRS_HEAVY = 0) so that aircraft can fly
;*       in formation.

AutoHeading	PROC	NEAR

;---------------------------
;* pick up cruise parameters
;---------------------------

		mov	di,PerfDataPtr
		mov	di,PERF_CRUISE[di]

;----------------
;* calc hdg error
;----------------

;* hdg error = aiming hdg - current hdg

		sub	ax,AC_Data.AC_HFINE

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
;* limit vtas (100 .. 800kts)
;----------------------------

		mov	bp,AC_Data.AC_VTAS

		SBOUND	bp,1360,10880

;-------------------
;* calc hdg rate max (wrt vtas)
;-------------------

;* max rate = 47039bh / vtas

		mov	dx,00047h
		mov	ax,0039bh
		div	bp

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

;* roll angle = arctan(hdg err * vtas * 400 / 65536)

		push	di

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

		push	bp
		call	ArcTan2
		pop	bp

		pop	di

		jmp	ContHeading

;* set roll angle to max

MaxRollAngle:	mov	ax,AH_MAX_ROLL

		xor	ax,cx		;restore sign
		sub	ax,cx

ContHeading:	test	CRS_HEAVY[di],1	;heavy aircraft?
		jz	@F		;no ->

		sar	ax,1		;aiming roll / 2

@@:		sub	ax,AC_Data.AC_RFINE	;roll error

		ABSV	ax		;ax = abs(roll error), dx = sign(roll error)

;* roll rate = min(abs(error), AH_ROLL_RATE * DeltaTime / 32768) * sign(error)

		mov	bx,ax		;abs(error)
		mov	cx,dx		;sign(error)

		mov	dx,AH_ROLL_RATE

		test	CRS_HEAVY[di],1	;heavy aircraft?
		jz	@F		;no ->

		shr	dx,1		;roll rate / 2

@@:		mov	ax,DeltaTime
		imul	dx
		FRACADJ	dx

		cmp	dx,bx		;rate > error?
		jbe	@F		;no ->
		mov	dx,bx

@@:		xor	dx,cx		;restore sign
		sub	dx,cx

		add	AC_Data.AC_RFINE,dx

;-------------------
;* calc heading rate
;-------------------

;* hdg rate = 520000h / vtas * sin(roll) * DeltaTime

		mov	dx,00052h
		xor	ax,ax
		div	bp		;520000h / vtas

		mov	bx,AC_View.VP_ROLL

		test	CRS_HEAVY[di],1	;heavy aircraft?
		jz	@F		;no ->

		mov	cl,7		;double roll for desired hdg rate
		shl	bx,cl
		sal	bx,1
		shr	bx,cl

@@:		SINE	dx,bx

		imul	dx
		FRACADJ	dx		;520000h / vtas * sin(roll)

		mov	ax,DeltaTime
		imul	dx
		FRACADJ	dx		;520000h / vtas * sin(roll) * DeltaTime

		add	AC_Data.AC_HFINE,dx

		ret

AutoHeading	ENDP

;----------------------------------------------------------------------------

;* AutoAltitude - fly to given altitude / terrain follow / fly glide slope
;*
;* pass: ax = aiming altitude (ft)
;* ret : AC_Data.AC_PFINE
;*       AC_Data.AC_LIFT_VCTR
;* kill: assume all
;*
;* note: Based on the Tornado auto-pilot "auto-altitude" algorithm. Pitch
;*       rates are the same (CRS_HEAVY = 0) so that aircraft can fly in
;*       formation.
;*
;*	 AutoAltitude requires current heading for terrain following algorithm
;*       so call AutoAltitude after AutoHeading.

AutoAltitude	PROC	NEAR

;-------------------------------------
;* test for terrain following override
;-------------------------------------

		mov	si,AC_Data.AC_WP_PTR

		test	WP_ATTR[si],WP_TF	;terrain follow?
		_JZ	SkipTF			;no ->

;* copy viewpoint data to temporary data

		COPY_VP	TMP_VIEW,AC_View

;* calc ground height below aircraft

		mov	si,OFFSET TMP_VIEW
		call	CalcGndHeight

		push	ax		;store ground height below aircraft

;* calc delta xft and delta yft per second (wrt heading)

		mov	dx,AC_Data.AC_Vtas	;(*8 scaled)

		mov	cl,7		;/128

		mov	ax,AC_Data.AC_HFINE
		shr	ax,cl
		ROUNDUP	ax
		and	ax,001ffh

		call	CalcDeltaXY

		mov	ax,cx
		ABSV	ax		;ax = abs(x), dx = sign(x)
		REPT	3		;/8 scaling
		shr	ax,1
		ENDM
		adc	ax,0		;1/2 bit round up
		xor	ax,dx		;restore sign
		sub	ax,dx
		mov	cx,ax

		mov	ax,bx		;ax = abs(y), dx = sign(y)
		ABSV	ax
		REPT	3		;/8 scaling
		shr	ax,1
		ENDM
		adc	ax,0		;1/2 bit round up
		xor	ax,dx		;restore sign
		sub	ax,dx
		mov	bx,ax

;* calc ground height 1 second ahead

		push	bx
		push	cx

		MOVEXY	TMP_VIEW,cx,bx

		mov	si,OFFSET TMP_VIEW
		call	CalcGndHeight

		pop	cx
		pop	bx

		push	ax		;store ground height 1 second ahead

;* calc ground height 2 seconds ahead

		MOVEXY	TMP_VIEW,cx,bx

		mov	si,OFFSET TMP_VIEW
		call	CalcGndHeight

;* select highest point

		pop	dx		;restore ground height 1 second ahead

		cmp	ax,dx
		jae	@F

		mov	ax,dx

@@:		pop	dx		;restore ground height below aircraft

		cmp	ax,dx
		jae	@F

		mov	ax,dx

@@:		mov	si,AC_Data.AC_WP_PTR

		add	ax,WP_ZFT[si]	;ground height + TF height

		jmp	ContAutoAlt

;-------------------------------
;* test for glide slope override
;-------------------------------

SkipTF:		test	WP_ATTR[si],WP_ILS	;fly glide slope?
		jz	ContAutoAlt		;no ->

;* alt = min((waypoint range / 16) - 32, 4096)

		mov	ax,65535	;assume range > 65,535ft

		cmp	WORD PTR AC_WPRng+2,0
		ja	@F

		mov	ax,WORD PTR AC_WPRng

@@:		REPT	4		;/16
		shr	ax,1
		ENDM

		sub	ax,20		;compensate (for auto alt reaction delay)

		MINM	ax
   
ContAutoAlt:	mov	cx,ax		;cx = aiming altitude

;---------------------------
;* pick up cruise parameters
;---------------------------

		mov	di,PerfDataPtr
		mov	di,PERF_CRUISE[di]

;-----------------
;* calc pitch rate (wrt vtas)
;-----------------

;* if not terrain following then
;*    @200kts, pitch rate = 20 pdeg / sec (=2g) (vfac lo = 340 * 8)
;*    @800kts, pitch rate =  4 pdeg / sec (=2g) (vfac hi = 1360 * 8)
;* else
;*    @200kts, pitch rate = 20 pdeg / sec (=2g) (vfac lo = 340 * 8)
;*    @800kts, pitch rate = 10 pdeg / sec (>2g) (vfac hi = 980 * 8)
;* endif
;*
;* pitch rate = 20 * 128 - (bound(vtas, vfac lo, vfac hi) - vfac lo) / 4

		mov	dx,1360*8	;assume not terrain following

		mov	si,AC_Data.AC_WP_PTR

		test	WP_ATTR[si],WP_TF	;terrain follow?
		jz	@F			;no ->

		mov	dx,980*8	;terrain following

@@:		mov	ax,AC_Data.AC_VTAS

		SBOUND	ax,340*8,dx

		mov	si,ax		;si = bound(vtas, vfac lo, vfac hi)

		sub	ax,340*8

		REPT	2		;/4
		shr	ax,1
		ENDM

		mov	bp,20*128

		sbb	bp,ax		;(1/2 bit round up)

		mov	bx,bp		;bx = pitch rate

;------------------
;* calc pitch limit (wrt vtas)
;------------------

;* if not CRS_HEAVY then
;*    pitch limit = pitch rate * 2
;* else
;*    pitch limit = pitch rate
;*    pitch rate = pitch rate / 2
;* endif

		test	CRS_HEAVY[di],1	;heavy aircraft?
		jnz	@F		;yes ->

		shl	bp,1		;pitch limit = pitch rate * 2

		jmp	PRateOk

@@:		shr	bx,1		;pitch rate / 2

		ROUNDUP	bx

;-----------------
;* calc dist error (wrt vtas)
;-----------------

;* dist error = bound(vtas, 340 * 8, 1360 * 8) / 8

PRateOk:	REPT	3		;/8
		shr	si,1
		ENDM

		ROUNDUP	si		;si = dist error

;--------------
;* calc z error
;--------------

;* z error = aiming z - current z

		mov	ax,cx
		xor	dx,dx

		sub	ax,WORD PTR AC_View.VP_ZFT_LO
		sbb	dx,WORD PTR AC_View.VP_ZFT_HI

		mov	cx,dx		;cx = sign(z error)

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

		cmp	ax,si		;z error < dist error?
		jae	SetPitchLimit	;no ->

		mov	dx,ax		;z error * 32768
		xor	ax,ax
		shr	dx,1
		rcr	ax,1

		div	si

		push	bx		;pitch rate
		push	cx		;sign(z error)
		push	di		;param ptr
		push	bp		;pitch limit
		call	ArcTan
		pop	bp		;pitch limit
		pop	di		;param ptr
		pop	cx		;sign(z error)
		pop	bx		;pitch rate

		cmp	ax,bp		;aiming pitch <= pitch limit
		jbe	@F		;yes ->

SetPitchLimit:	mov	ax,bp

@@:		xchg	ax,cx		;aiming pitch * sign(z error)
		cwd			
		mov	ax,cx
		xor	ax,dx
		sub	ax,dx

;-----------------
;* sort pitch rate
;-----------------

		sub	ax,AC_Data.AC_LIFT_VCTR	;pitch error = aiming pitch - lift vector

		ABSV	ax		;ax = abs(error), dx = sign(error)

		mov	bp,ax		;bp = abs(error)
		mov	cx,dx		;cx = sign(error)

		mov	ax,DeltaTime
		imul	bx
		FRACADJ	ax		;delta pitch rate

		cmp	ax,bp		;delta pitch rate > error?
		jbe	@F		;no ->
   
		mov	ax,bp		;delta pitch rate = error

@@:		xor	ax,cx		;restore sign
		sub	ax,cx

		add	ax,AC_Data.AC_LIFT_VCTR

		mov	AC_Data.AC_LIFT_VCTR,ax

		mov	AC_Data.AC_PFINE,ax

		ret

AutoAltitude	ENDP

;----------------------------------------------------------------------------

;* AutoThrottle - accelerate to given speed
;*
;* pass: ax = aiming speed (ft/sec * 8)
;* ret : AC_Data.AC_VTAS
;*       AC_Data.AC_VTAS_FINE
;* kill: assume all
;*
;* note: AutoThrottle modifies pitch value so call after AutoAltitude.

AutoThrottle	PROC	NEAR

		mov	bp,ax		;bp = aiming speed

;---------------------------
;* pick up cruise parameters
;---------------------------

		mov	di,PerfDataPtr
		mov	di,PERF_CRUISE[di]

;-------------------
;* look up min speed (wrt altitude)
;-------------------

		mov	bx,WORD PTR AC_View.VP_ZFT_LO

		cmp	WORD PTR AC_View.VP_ZFT_HI,0	;zft > 65,535ft?
		je	@F				;no ->

		mov	bx,65535	;limit

@@:		mov	cl,10		;/1024

		shr	bx,cl
		ROUNDUP	bx		;0 .. 64
		shl	bx,1		;*2 word index

		mov	ax,MinSpeed[bx]

		mov	AC_Vmin,ax

;--------------------------
;* check speed >= min speed
;--------------------------

		cmp	bp,ax		;speed >= min speed?
		jae	@F		;yes ->

		mov	bp,ax

;--------------------------
;* check speed <= max speed (wrt altitude)
;--------------------------

@@:		mov	dx,WORD PTR AC_View.VP_ZFT_HI
		mov	ax,WORD PTR AC_View.VP_ZFT_LO

;* limit zft to 32,767ft (approx. 36,000ft)

		cmp	dx,0		;zft > 65,535ft?
		ja	@F		;yes ->
		cmp	ax,32767	;zft <= 32,767ft
		jbe	ZftOk		;yes ->

@@:		mov	ax,32767

;* interpolate max speed (wrt altitude)
;*
;* max speed = (vmax(36,000ft) - vmax(sea level)) * zft / 32768 + vmax(sea level)

ZftOk:		mov	dx,CRS_MXSPEED_36[di]
		sub	dx,CRS_MXSPEED_SL[di]

		imul	dx
		FRACADJ	dx

		add	dx,CRS_MXSPEED_SL[di]

		cmp	bp,dx		;speed <= max speed?
		jbe	@F		;yes ->

		mov	bp,dx

@@:		mov	AC_Vmax,dx

;----------------------------
;* accelerate to aiming speed
;----------------------------

;* calc speed error

		mov	cx,bp		;cx = aiming speed
		xor	bx,bx

		sub	bx,AC_Data.AC_VTAS_FINE	;error = aiming speed - current speed
		sbb	cx,AC_Data.AC_VTAS
		js	@F		;decelerate ->

;* accelerating - calc delta max accel (keep result as 32-bit value)

		xor	si,si		;accel

		mov	ax,CRS_ACCEL[di]
		mov	dx,DeltaTime
		imul	dx

		shl	ax,1		;adjust after fractional multiply
		rcl	dx,1

		jmp	ContAccel

;* decelerating - calc delta fixed decel (keep result as 32-bit value)

@@:		mov	si,-1		;decel

		mov	ax,FIXED_DECEL
		mov	dx,DeltaTime
		imul	dx

		shl	ax,1		;adjust after fractional multiply
		rcl	dx,1

		NEG32	cx,bx

		cmp	cx,100*8	;error > 100ft/sec?
		jbe	ContAccel	;no ->

		REPT	2		;use airbrake (decel * 4)
		shl	ax,1
		rcl	dx,1
		ENDM

;* if accel > error then
;*    accel = error
;* endif

ContAccel:	cmp	dx,cx
		jb	AccelOk
		ja	@F
		cmp	ax,bx
		jbe	AccelOk

@@:		mov	dx,cx
		mov	ax,bx

AccelOk:	xor	ax,si		;restore sign
		xor	dx,si
		sub	ax,si
		sbb	dx,si

		xor	bx,si		;restore sign
		xor	cx,si
		sub	bx,si
		sbb	cx,si

		add	AC_Data.AC_VTAS_FINE,ax
		adc	AC_Data.AC_VTAS,dx

;-------------------------
;* sort pitch up wrt vtrim
;-------------------------

;* vtrim = vmin * 2
;*
;* if vtas < vtrim then
;*    pitch = (16 * 128) - max(vtas - vmin, 0) * 128 / (vmin / 16) (fine pdegs)
;* else
;*    pitch = 0
;* endif

		push	cx		;store error

		xor	bp,bp		;assume vtas >= vtrim

		mov	bx,AC_Vmin

		mov	cx,bx
		shl	cx,1		;vtrim = vmin * 2

		mov	ax,AC_Data.AC_VTAS
		cmp	ax,cx		;vtas >= vtrim?
		jae	@F		;yes ->

		sub	ax,bx		;vtas - vmin

		MINM	ax		;max(vtas - vmin, 0)

		xor	dh,dh		;max(vtas - vmin, 0) * 256
		mov	dl,ah
		mov	ah,al
		xor	al,al

		shr	dx,1		;max(vtas - vmin, 0) * 128
		rcr	ax,1

		REPT	4		;vmin / 16
		shr	bx,1
		ENDM

		ROUNDUP	bx

		mov	bp,16*128	;set max pitch up

		cmp	bx,dx		;div ok?
		jbe	@F		;no ->

		div	bx

		sub	bp,ax
		jnc	@F
		xor	bp,bp

@@:		add	AC_Data.AC_PFINE,bp

		pop	cx		;restore error

;--------------------------------------
;* sort wing sweep and reheat animation (wrt speed vs max speed)
;--------------------------------------

;* update inhibit delays (prevent animations from oscillating)

		mov	al,AC_Data.AC_AB_DELAY
		sub	al,BYTE PTR LastFrame
		MINM	al
		mov	AC_Data.AC_AB_DELAY,al

		mov	al,AC_Data.AC_SWEEP_DELAY
		sub	al,BYTE PTR LastFrame
		MINM	al
		mov	AC_Data.AC_SWEEP_DELAY,al

;* if speed <= (max speed / 2) then
;*    wing sweep forward
;* else
;*    if speed <= (max speed * 3 / 4) then
;*       wing sweep mid
;*    else
;*       wing sweep back
;*       if error >= -25ft/sec then    	;allow -ve to avoid reheat flickering
;*          reheat on
;*       endif
;*    endif
;* endif
;*
;* if error >= 50ft/sec then
;*    reheat on
;* endif

		mov	dx,AC_Vmax

		xor	bh,bh		;assume reheat off

		mov	ax,AC_Data.AC_VTAS

		shr	dx,1		;max speed / 2

		mov	bl,WING_SWEEP_FWD

		cmp	ax,dx		;sweep <= (max speed / 2)?
		jbe	@F		;yes ->

		sub	ax,dx
		shr	dx,1		;max speed / 4

		mov	bl,WING_SWEEP_MID

		cmp	ax,dx		;sweep <= (max speed * 3 / 4)?
		jbe	@F		;yes ->

		mov	bl,WING_SWEEP_BCK

		cmp	cx,-25*8	;error >= -25ft/sec?
		jl	@F		;no ->

		mov	bh,REHEAT_ALL

@@:		cmp	cx,50*8		;error >= 50ft/sec
		jl	@F		

		mov	bh,REHEAT_ALL

;* if reheat animation not inhibited then
;*    if reheat animation changed then
;*       sort reheat animation
;*       set inhibit delay
;*    endif
;* endif

@@:		cmp	AC_Data.AC_AB_DELAY,0	;inhibited?
		jne	@F			;yes ->

		mov	al,AC_Mobile.MOB_ANIM
		and	al,REHEAT_ALL
		cmp	al,bh			;changed?
		je	@F			;no ->

		and	AC_Mobile.MOB_ANIM,NOT REHEAT_ALL	;clear old
		or	AC_Mobile.MOB_ANIM,bh			;set new

		mov	AC_Data.AC_AB_DELAY,255	;set 2.55 secs delay

;* if wing sweep animation not inhibited then
;*    if wing sweep animation changed then
;*       sort wing sweep animation
;*       set inhibit delay
;*    endif
;* endif

@@:		cmp	AC_Data.AC_SWEEP_DELAY,0	;inhibited?
		jne	@F				;yes ->

		mov	al,AC_Mobile.MOB_ANIM
		and	al,WING_SWEEP_ALL
		cmp	al,bl			;changed?
		je	@F			;no ->

		and	AC_Mobile.MOB_ANIM,NOT WING_SWEEP_ALL	;clear old
		or	AC_Mobile.MOB_ANIM,bl			;set new

		mov	AC_Data.AC_SWEEP_DELAY,255	;set 2.55 secs delay

@@:		ret

AutoThrottle	ENDP

;----------------------------------------------------------------------------

;* CalcAngles - convert fine pdegs to pdegs
;*
;* pass: AC_Data.AC_HFINE
;*       AC_Data.AC_PFINE
;*       AC_Data.AC_RFINE
;* ret : AC_View.VP_HDG
;*       AC_View.VP_PITCH
;*       AC_View.VP_ROLL
;* kill: assume all

CalcAngles	PROC	NEAR

		mov	cl,7		;/128

;---------
;* heading
;---------

		mov	ax,AC_Data.AC_HFINE
		shr	ax,cl
		ROUNDUP	ax
		and	ax,001ffh
		mov	AC_View.VP_HDG,ax

;-------
;* pitch
;-------

		mov	ax,AC_Data.AC_PFINE
		shr	ax,cl
		ROUNDUP	ax
		and	ax,001ffh
		mov	AC_View.VP_PITCH,ax

;------
;* roll
;------

		mov	ax,AC_Data.AC_RFINE
		shr	ax,cl
		ROUNDUP	ax
		and	ax,001ffh
		mov	AC_View.VP_ROLL,ax

		ret

CalcAngles	ENDP

;----------------------------------------------------------------------------

;* CalcDeltaXYZ - calc delta xft, yft, zft
;*
;* pass: nothing
;* ret : ax = delta xft, AC_Data.AC_XFINE
;*       bx = delta yft, AC_Data.AC_YFINE
;*       cx = delta zft, AC_Data.AC_ZFINE
;* kill: assume all

CalcDeltaXYZ	PROC	NEAR

		mov	di,DeltaTime

;* calc speed * cos(lift)

		mov	bx,AC_Data.AC_LIFT_VCTR
		mov	cl,7
		shr	bx,cl		;/128 (convert fine pdegs to pdegs)
		ROUNDUP	bx
		and	bx,001ffh

		COSINE	dx,bx		;dx = cos(lift)

		mov	ax,AC_Data.AC_VTAS
		imul	dx
		FRACADJ	bp		;bp = speed * cos(lift)

;------------------------------------------------------
;* delta xft = speed * cos(lift) * sin(hdg) * DeltaTime
;------------------------------------------------------

		mov	bx,AC_View.VP_HDG
		
		SINCOS	ax,bx,bx	;ax = sin(hdg), bx = cos(hdg)

		imul	bp
		FRACADJ	ax		;speed * cos(lift) * sin(hdg)

		imul	di		;speed * cos(lift) * sin(hdg) * DeltaTime

;* /4 to align dx = delta xft and ax = delta xft fine

		test	dx,dx		;delta xft < 0?
		jns	@F		;no ->

		NEG32	dx,ax		;avoid -1 truncation error

		REPT	2		;/4
		shr	dx,1
		rcr	ax,1
		ENDM

		NEG32	dx,ax

		jmp	DxOk

@@:		REPT	2		;/4
		shr	dx,1
		rcr	ax,1
		ENDM

DxOk:		add	AC_Data.AC_XFINE,ax
		adc	dx,0

		mov	ax,bp		;ax = speed * cos(lift)

		mov	bp,dx		;bp = delta xft

;------------------------------------------------------
;* delta yft = speed * cos(lift) * cos(hdg) * DeltaTime
;------------------------------------------------------

		imul	bx		
		FRACADJ	ax		;speed * cos(lift) * cos(hdg)

		imul	di		;speed * cos(lift) * cos(hdg) * DeltaTime

;* /4 to align dx = delta yft and ax = delta yft fine

		test	dx,dx		;delta yft < 0?
		jns	@F		;no ->

		NEG32	dx,ax		;avoid -1 truncation error

		REPT	2		;/4
		shr	dx,1
		rcr	ax,1
		ENDM

		NEG32	dx,ax

		jmp	DyOk

@@:		REPT	2		;/4
		shr	dx,1
		rcr	ax,1
		ENDM

DyOk:		add	AC_Data.AC_YFINE,ax
		adc	dx,0

		mov	bx,dx		;bx = delta yft

;------------------------------------------------
;* delta zft = speed * sin(lift fine) * DeltaTime
;------------------------------------------------

		mov	ax,AC_Data.AC_LIFT_VCTR

		push	bx		;delta yft
		push	di		;delta time
		push	bp		;delta xft
		call	CalcSineFine
		pop	bp		;delta xft
		pop	di		;delta time
		pop	bx		;delta yft

		mov	dx,AC_Data.AC_VTAS
		imul	dx
		FRACADJ	ax		;speed * sin(lift)

		imul	di		;speed * sin(lift) * DeltaTime

;* /4 to align dx = delta zft and ax = delta zft fine

		test	dx,dx		;delta zft < 0?
		jns	@F		;no ->

		NEG32	dx,ax		;avoid -1 truncation error

		REPT	2		;/4
		shr	dx,1
		rcr	ax,1
		ENDM

		NEG32	dx,ax

		jmp	DzOk

@@:		REPT	2		;/4
		shr	dx,1
		rcr	ax,1
		ENDM

DzOk:		add	AC_Data.AC_ZFINE,ax
		adc	dx,0

		mov	cx,dx		;cx = delta zft

		mov	ax,bp		;ax = delta xft

		ret

CalcDeltaXYZ	ENDP

;----------------------------------------------------------------------------

;* GroundCheck - keep drone above ground
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

GroundCheck	PROC	NEAR

		mov	si,AircraftPtr

		cmp	WORD PTR _VP_ZFT_HI[si],0	;below ground?
		jge	@F				;no ->

		xor	ax,ax

		mov	WORD PTR _VP_ZFT_HI[si],ax
		mov	WORD PTR _VP_ZFT_LO[si],ax
		mov	_AC_ZFINE[si],ax

;* if combat mode and alt <= (15 * 256) then keep above hills

@@:		cmp	_AC_CTRL_MODE[si],CTRL_COMBAT
		jne	@F

		cmp	WORD PTR _VP_ZFT_HI[si],0
		ja	@F
		cmp	WORD PTR _VP_ZFT_LO[si],15*256
		ja	@F

		add	si,MOB_REC_SIZE
		call	CalcGndHeight

		mov	si,AircraftPtr

		cmp	WORD PTR _VP_ZFT_LO[si],ax
		ja	@F

		mov	WORD PTR _VP_ZFT_LO[si],ax

@@:		ret

GroundCheck	ENDP

;---------------------------------------------------------------------------

;* SortControlMode
;*
;* pass: si -> waypoint
;* ret : dx = control mode
;* kill: flags

SortControlMode	PROC	NEAR

		mov	dx,CTRL_APPROACH		;assume approach
		test	WP_ATTR[si],WP_ILS		;approach?
		jnz	@F				;yes ->

		mov	dx,CTRL_TAKEOFF			;assume takeoff
		cmp	WP_ACTION[si],AC_WP_TAKEOFF	;takeoff?
		je	@F				;yes ->

		mov	dx,CTRL_TRACK			;assume airborne
		cmp	WP_ACTION[si],AC_WP_AIRBORNE	;airborne?
		je	@F				;yes ->

		mov	dx,CTRL_TRACK			;default to track

@@:		ret

SortControlMode	ENDP

;----------------------------------------------------------------------------

;* CtrlCombat
;*
;* pass: AC_Workspace
;* ret : nothing
;* kill: assume all
;*
;* note: This routine is designed to manoeuvre drone aircraft against
;*       opponents. Valid opponents are the Tornado and other drone aircraft.
;*       However, it may be possible to expand the routine to other opponents
;*       such as helicopters. All queries regarding opponent should be
;*       handled via "DRONELIB".

CtrlCombat	PROC	NEAR

;----------------------------------------------------------------------------
;*                        ///// check for break /////
;----------------------------------------------------------------------------

;* note: Interceptor activity maybe sparse if interceptors spend most of their
;*       time returning to base in order to resupply. If this is the case then
;*       modify the following code so that on destroying an opponent, the
;*       interceptor is rewarded a new full weapons load and returns to CAP.

;* check if already breaking

		test	AC_Data.AC_FLAGS,AFLG_UPRIGHT
		jnz	SkipBreak

		mov	si,AC_Data.AC_OPP_PTR

;* break if opponent destroyed

		call	GetDroneAlive
		jnc	SortBreak

;* get opponent speed (speed not required when breaking)

		call	GetDroneSpeed

		mov	OppVtas,ax

;* break if opponent speed < 25kts (must have landed)

;* note: This check is made to prevent the interceptors from attacking the
;*       Tornado after landing. It is better to check the speed as opposed
;*       to altitude or the Tornado "airborne" flag because interceptors
;*       will break every time the opponent hits the ground. This could be
;*       an easy way to get rid of interceptors when "no collisions" are 
;*       enabled!

		cmp	ax,340
		jb	SortBreak

;* break if out of shells

		cmp	AC_Data.AC_SHELLS,0
		je	IntoBreak

;* check if Tornado opponent

		cmp	AC_Data.AC_OPP_PTR,OFFSET M_MOBILE
		jne	SkipBreak

;* break if "break" flag set

		test	BreakFlag,1
		jnz	IntoBreak

;* break if flying very low, very fast

		cmp	TrueRadAlt,VERY_LOW
		ja	@F

		mov	ax,Vias
		cmp	ax,VERY_FAST
		ja	SortBreak

@@:		

		jmp	SkipBreak

;* return to base or CAP depending on weapon status

SortBreak:	cmp	AC_Data.AC_SHELLS,25
		jb	IntoBreak

		cmp	AC_Data.AC_MISSILES,1
		ja	ContBreak

IntoBreak:	call	SelectBreakWP
		jc	ContBreak

		or	AC_Data.AC_FLAGS,AFLG_BREAK

ContBreak:	or	AC_Data.AC_FLAGS,AFLG_UPRIGHT

		and	AC_Data.AC_FLAGS,NOT (AFLG_EVADE_HI+AFLG_EVADE_LO)

;* note: When breaking the opponent ptr is set to -1. This should not cause
;*       any problems in the following code as most places where AC_OPP_PTR
;*       is used are skipped over when breaking. In other cases, such as the
;*       g max calculation, it is of no consequence.

		mov	AC_Data.AC_OPP_PTR,-1

SkipBreak:

;----------------------------------------------------------------------------
;*		             ///// initialise /////
;----------------------------------------------------------------------------

;-----------
;* calc vias
;-----------
		
		mov	ax,WORD PTR AC_View.VP_ZFT_LO
		mov	dx,WORD PTR AC_View.VP_ZFT_HI
		mov	bp,AC_Data.AC_VTAS
		call	CalcVias
		mov	AC_Vias,ax

;-------------------------------------
;* calc min vias and vtas for division
;-------------------------------------

;* keep vias > 100kts

		cmp	ax,1360
		jge	@F
		mov	ax,1360
@@:		mov	AC_DivVias,ax

;* keep vtas > 100kts

		mov	ax,AC_Data.AC_VTAS
		cmp	ax,1360
		jge	@F
		mov	ax,1360
@@:		mov	AC_DivVtas,ax

;--------------------
;* update g max timer
;--------------------

		mov	ax,AC_Data.AC_GMAX_TIMER
		sub	ax,LastFrame
		jnc	@F

;* toggle status and reset timer

		xor	AC_Data.AC_FLAGS,AFLG_GMAX

		call	RandX		; 0.00 ..  2.55
		shl	ax,1		; 0.00 ..  5.10
		shl	ax,1		; 0.00 .. 10.20
		add	ax,20*100	;20.00 .. 30.20

@@:		mov	AC_Data.AC_GMAX_TIMER,ax

;-----------------------------
;* apply artificial pitch down (tends to keep aircraft erect)
;-----------------------------

;* delta pitch (degs) = cos(pitch) * 1845 / vtas * delta time
;*
;* delta pitch (fine pdegs) = cos(pitch) * 82 / vtas * delta time

		COSINE	ax,AC_View.VP_PITCH

		mov	dx,82
		imul	dx

		mov	bx,AC_DivVtas
		idiv	bx

		mov	dx,DeltaTime
		imul	dx
		FRACADJ	dx

		mov	ax,AC_Data.AC_PFINE
		sub	ax,dx
		cmp	ax,-128*128
		jge	@F
		mov	ax,-128*128
@@:		mov	AC_Data.AC_PFINE,ax

		mov	cl,7		;convert fine pdegs -> pdegs
		shr	ax,cl
		adc	ax,0
		and	ax,511

		mov	AC_View.VP_PITCH,ax

;----------------------------------------------------------------------------
;*  			  ///// calc aiming point /////
;----------------------------------------------------------------------------

;-------------------------
;* check for "fly upright"
;-------------------------

		test	AC_Data.AC_FLAGS,AFLG_UPRIGHT
		_JZ	SkipUpright

;* calc aiming point ahead of aircraft

		COPY_VP	ICPOINT,AC_View

		mov	ax,ICPOINT.VP_HDG
		mov	dx,4000
		call	CalcDeltaXY

		MOVEXY	ICPOINT,cx,bx

;* if alt > BREAK_ALT then descend (ensure safe hand over to tracking mode)

		cmp	WORD PTR ICPOINT.VP_ZFT_HI,0
		ja	@F
		cmp	WORD PTR ICPOINT.VP_ZFT_LO,BREAK_ALT
		ja	@F

		jmp	SkipEvade

@@:		mov	WORD PTR ICPOINT.VP_ZFT_HI,0
		mov	WORD PTR ICPOINT.VP_ZFT_LO,BREAK_ALT

		jmp	SkipEvade

SkipUpright:

;------------------
;* calc slant range (aircraft -> opponent)
;------------------

		mov	si,OFFSET AC_View
		mov	di,AC_Data.AC_OPP_PTR
		add	di,MOB_REC_SIZE
		call	CalcSlantRange

;----------------------
;* calc intercept point (based on aircraft speed + cannon muzzle velocity)
;----------------------

		mov	bx,AC_Data.AC_VTAS
		add	bx,MUZZLE_VELOCITY
		cmp	bx,32767
		jbe	@F
		mov	bx,32767

@@:		mov	cx,OppVtas

		mov	si,AC_Data.AC_OPP_PTR
		add	si,MOB_REC_SIZE
		mov	di,OFFSET ICPOINT
		call	CalcIntercept

;-----------------
;* missile evasion
;-----------------

;* check if already evading missile

		cmp	AC_Data.AC_EVADE_TIMER,0
		ja	ContEvade

;* give Tornado and ADV drones a fighting chance!

		mov	bp,255-(20*256)/100

		cmp	AC_Data.AC_OPP_PTR,OFFSET M_MOBILE
		je	@F
		cmp	AC_Data.AC_OPP_PTR,OFFSET AAircraft7
		je	@F
		cmp	AC_Data.AC_OPP_PTR,OFFSET AAircraft8
		je	@F

		mov	bp,255-(50*256)/100

;* test if released chaff / flare last frame

@@:		test	AC_Data.AC_FLAGS,AFLG_REL_CHAFF+AFLG_REL_FLARE
		jz	SkipEvade

;* random chance of evading missile

		call	RandX
		cmp	ax,bp
		jb	SkipEvade

;* set evade timer

		call	RandX		;0.00 ..  2.55
		shl	ax,1		;0.00 ..  5.10
		add	ax,5*100	;5.00 .. 10.10

		mov	AC_Data.AC_EVADE_TIMER,ax

;* sort pull up or roll and pull (wrt altitude)

SWITCH_ALT	=	(COMBAT_CEILING-GND_CHECK_ALT)/2+GND_CHECK_ALT

		mov	ax,AFLG_EVADE_LO

		cmp	WORD PTR AC_View.VP_ZFT_HI,0
		ja	@F
		cmp	WORD PTR AC_View.VP_ZFT_LO,SWITCH_ALT
		ja	@F

		mov	ax,AFLG_EVADE_HI

@@:		or	AC_Data.AC_FLAGS,ax

		jmp	IntoEvade

;* update evade timer and set intercept altitude

ContEvade:	mov	ax,AC_Data.AC_EVADE_TIMER
		sub	ax,LastFrame
		MINM	ax
		mov	AC_Data.AC_EVADE_TIMER,ax

		jz	StopEvade

IntoEvade:	mov	WORD PTR ICPOINT.VP_ZFT_HI,0

		mov	ax,COMBAT_CEILING

		test	AC_Data.AC_FLAGS,AFLG_EVADE_HI
		jnz	@F

		mov	ax,GND_CHECK_ALT

@@:		mov	WORD PTR ICPOINT.VP_ZFT_LO,ax

		jmp	SkipEvade

;* disable evasion

StopEvade:	and	AC_Data.AC_FLAGS,NOT (AFLG_EVADE_HI+AFLG_EVADE_LO)

SkipEvade:

;--------------------------
;* prevent ground collision
;--------------------------

;* check intercept point below combat ceiling

		cmp	WORD PTR ICPOINT.VP_ZFT_HI,0
		_JA	SetCeiling
		cmp	WORD PTR ICPOINT.VP_ZFT_LO,COMBAT_CEILING
		_JA	SetCeiling

;* check aircraft below ground check threshold

		cmp	WORD PTR AC_View.VP_ZFT_HI,0
		_JA	GndCheckOk
		cmp	WORD PTR AC_View.VP_ZFT_LO,GND_CHECK_ALT
		_JA	GndCheckOk

;* calc range to intercept point

		mov	si,OFFSET AC_View
		mov	di,OFFSET ICPOINT
		call	CalcRngBrgVP_VP

;* check if opponent behind (abs(ang diff) > 90 degs)

		mov	OppBehind,0

		push	ax
		push	dx

		mov	ax,AC_Data.AC_HFINE
		xchg	ax,bp
		sub	ax,bp
		ABSV	ax

		cmp	ax,128*128
		jbe	@F

		mov	OppBehind,1

@@:		pop	dx
		pop	ax

;* calc error scaling wrt range

		mov	cl,8		;(error << 8)

		cmp	dx,0
		ja	@F

		dec	cl		;(error << 7)
		cmp	ax,32767
		ja	@F

		dec	cl		;(error << 6)

@@:		mov	ErrorScale,cl

;* if range > 16384 then keep aircraft above hills

		mov	bp,15*256

		cmp	dx,0
		ja	@F
		cmp	ax,16384
		ja	@F

;* calc ground height below aircraft

		mov	si,OFFSET AC_View
		call	CalcGndHeight

		mov	bp,ax

;* calc aircraft rad alt

@@:		mov	bx,WORD PTR AC_View.VP_ZFT_LO

		sub	bx,bp
		jnc	@F

		xor	bx,bx

;* check for emergency pull up

@@:		cmp	bx,COMBAT_FLOOR
		jae	@F

;* emergency pull up

		mov	ax,COMBAT_FLOOR
		sub	ax,bx

		mov	cl,ErrorScale

		shl	ax,cl

		add	bp,ax

		jmp	SortICAlt

;* check for pitched down (pitch up to prevent ground collision)

@@:		cmp	AC_Data.AC_PFINE,0
		jge	SortICAlt

		mov	ax,AC_Data.AC_PFINE

		push	bx
		push	bp
		call	CalcSineFine
		pop	bp
		pop	bx

		mov	dx,10000

		test	OppBehind,1
		jnz	@F

		mov	dx,bx

@@:		imul	dx
		FRACADJ	dx

		sub	bp,dx

;* sort intercept point alt

SortICAlt:	add	bp,COMBAT_FLOOR

		cmp	WORD PTR ICPOINT.VP_ZFT_LO,bp
		jae	GndCheckOk
	
		mov	WORD PTR ICPOINT.VP_ZFT_LO,bp

		jmp	GndCheckOk

SetCeiling:	mov	WORD PTR ICPOINT.VP_ZFT_LO,COMBAT_CEILING
		mov	WORD PTR ICPOINT.VP_ZFT_HI,0

GndCheckOk:

;----------------------------------------------------------------------------
;*      ///// transform intercept point in terms of aircraft axis /////
;----------------------------------------------------------------------------

		mov	si,OFFSET AC_View
		call	CalcTransMatrix

		mov	si,OFFSET AC_View
		mov	di,OFFSET ICPOINT
		call	CalcRngRelCo

		mov	ScaledRange,dx

		call	CalcEyeCoords

		mov	Xt,ax
		mov	Yt,bx
		mov	Zt,cx

;----------------------------------------------------------------------------
;*			    ///// calc errors /////
;----------------------------------------------------------------------------

;--------------------
;* calc bearing error
;--------------------

;* guard against overflow

		mov	ax,Yt
		ABSV	ax
		cmp	ax,ScaledRange
		jb	@F

;* overflow, CosBrgError = 32767 * sign(Yt)

		mov	ax,32767
		xor	ax,dx
		sub	ax,dx

		jmp	SetCosBrgError

;* BrgError = (Yt / ScaledRange)

@@:		mov	dx,Yt
		xor	ax,ax

		sar	dx,1
		rcr	ax,1

		mov	bx,ScaledRange

		idiv	bx

SetCosBrgError:	mov	CosBrgError,ax

		call	FastArcCos

		mov	BrgError,ax

;-----------------------
;* apply dead band to Zt
;-----------------------

;* if cos(brg error) >= cos(15) (0.966) then
;*    if Zt < 0 then
;*       threshold = -(scaled range / 64)
;*       if Zt > threshold then
;*          Zt = 0
;*       else
;*          Zt = Zt - threshold
;*       endif
;*    endif
;* endif

		cmp	CosBrgError,31651	;31651 = cos(15) * 32768
		jl	SkipDeadBand

		cmp	Zt,0
		jge	SkipDeadBand

		mov	bp,ScaledRange

		mov	cl,6
		shr	bp,cl
		adc	bp,0
		neg	bp

		cmp	Zt,bp
		jle	@F

		mov	Zt,0

		jmp	SkipDeadBand

@@:		sub	Zt,bp

SkipDeadBand:

;----------------
;* calc hdg error
;----------------

;* guard against overflow

		mov	ax,Xt
		ABSV	ax
		cmp	ax,ScaledRange
		jb	@F

;* overflow, HdgError = 90 * sign(Xt)

		mov	ax,128*128
		xor	ax,dx
		sub	ax,dx

		jmp	SetHdgError

;* HdgError = arcsin(Xt / ScaledRange)

@@:		mov	dx,Xt
		xor	ax,ax

		sar	dx,1
		rcr	ax,1

		mov	bx,ScaledRange

		idiv	bx

		call	FastArcSin

SetHdgError:	mov	HdgError,ax

;------------------
;* calc pitch error
;------------------

;* guard against overflow

		mov	ax,Zt
		ABSV	ax
		cmp	ax,ScaledRange
		jb	@F

;* overflow, PitchError = 90 * sign(Zt)

		mov	ax,128*128
		xor	ax,dx
		sub	ax,dx

		jmp	SetPitchError

;* PitchError = arcsin(Zt / ScaledRange)

@@:		mov	dx,Zt
		xor	ax,ax

		sar	dx,1
		rcr	ax,1

		mov	bx,ScaledRange

		idiv	bx

		call	FastArcSin

SetPitchError:	mov	PitchError,ax

;----------------------------------------------------------------------------
;* 			  ///// firing decision /////
;----------------------------------------------------------------------------

;-------------------------
;* do not fire if breaking
;-------------------------

		test	AC_Data.AC_FLAGS,AFLG_UPRIGHT
		_JNZ	SkipFiring
		
;----------------------------
;* check hostile fire enabled
;----------------------------

		test	NoFire,1
		_JNZ	SkipFiring

;------------------------
;* update weapon interval
;------------------------

		mov	ax,AC_Data.AC_WPN_INT
		sub	ax,LastFrame
		MINM	ax
		mov	AC_Data.AC_WPN_INT,ax

		jnz	SkipFiring

;---------------------------
;* check opponent alt > 50ft
;---------------------------

		mov	si,AC_Data.AC_OPP_PTR
		add	si,MOB_REC_SIZE

		cmp	WORD PTR [si].VP_ZFT_HI,0
		ja	@F
		cmp	WORD PTR [si].VP_ZFT_LO,50
		jbe	SkipFiring

;-----------------------
;* check firing solution (bearing error <= 1 deg)
;-----------------------

@@:		cmp	CosBrgError,32763
		jl	SkipFiring

;-------------------
;* check fire cannon
;-------------------

		cmp	WORD PTR SlantRng+2,0
		ja	SkipCannon
		cmp	WORD PTR SlantRng,4000
		ja	SkipCannon

		cmp	AC_Data.AC_SHELLS,0
		je	SkipFiring

		call	AutoCannon
		jc	SkipFiring

		dec	AC_Data.AC_SHELLS

;* random chance of setting inhibit interval

		call	RandX
		cmp	ax,(10*256)/100	;10% chance of inhibit
		ja	SkipFiring

		call	RandX		; 0.00 ..  2.55
		shl	ax,1		; 0.00 ..  5.10
		shl	ax,1		; 0.00 .. 10.20
		add	ax,10*100	;10.00 .. 20.20

		mov	AC_Data.AC_WPN_INT,ax

		jmp	SkipFiring

;----------------------
;* check launch missile
;----------------------

SkipCannon:	cmp	AC_Data.AC_MISSILES,0
		je	SkipFiring

		cmp	WORD PTR SlantRng+2,1
		ja	SkipFiring

		call	AutoMissile
		jc	SkipFiring

		dec	AC_Data.AC_MISSILES

		call	RandX		; 0.00 ..  2.55
		shl	ax,1		; 0.00 ..  5.10
		shl	ax,1		; 0.00 .. 10.20
		add	ax,10*100	;10.00 .. 20.20

		mov	AC_Data.AC_WPN_INT,ax

SkipFiring:

;----------------------------------------------------------------------------
;* 			  ///// calc max rates /////
;----------------------------------------------------------------------------

		mov	si,PerfDataPtr
		mov	si,[si].PERF_COMBAT

;---------------
;* max roll rate
;---------------

;* MaxRRate = COM_ROLL_RATE * DeltaTime

		mov	ax,[si].COM_ROLL_RATE

		mov	dx,DeltaTime
		imul	dx
		FRACADJ	dx

		mov	MaxRRate,dx

;------------
;* calc g max
;------------

		mov	bp,MIN_GMAX

;* if Tornado opponent then check for hi-g or lo-g manoeuvring
;*
;* (note: When breaking AC_OPP_PTR = -1, therefore, always uses hi-g)

		cmp	AC_Data.AC_OPP_PTR,OFFSET M_MOBILE
		jne	@F

		test	AC_Data.AC_FLAGS,AFLG_GMAX
		jz	GMaxOk

;* adjust g max wrt pilot skill

@@:		mov	ax,[si].COM_GMAX

		sub	ax,MIN_GMAX
		jbe	GMaxOk

		mov	dx,APilotSkill

		cmp	AC_Data.AC_SIDE,ALLIED
		je	@F

		mov	dx,EPilotSkill

@@:		imul	dx
		FRACADJ	dx

		add	bp,dx

;* MaxGForce = min(g max, AC_Vias * AC_Vias >> 17)

GMaxOk:		mov	ax,AC_Vias
		imul	ax

		shr	dx,1
		adc	dx,0

		cmp	dx,bp
		jbe	@F

		mov	dx,bp

@@:		mov	MaxGForce,dx

;----------------
;* max pitch rate
;----------------

;* MaxPRate = (MaxGForce * 256) * 656 / AC_DivVias * DeltaTime

		mov	ax,656

		xchg	dl,dh		;*256 (gmax < 256)

		mul	dx

		mov	bx,AC_DivVias

		idiv	bx

		mov	dx,DeltaTime
		imul	dx
		FRACADJ	dx

		mov	MaxPRate,dx

;----------------------------------------------------------------------------
;* 		    ///// calc pitch and roll demands /////
;----------------------------------------------------------------------------

;------------------
;* calc roll demand
;------------------

;* select pitch error
;* case < 0 (turn push into roll and pull)
;*    roll demand = 180 * sign(hdg error)
;* case = 0 (pitch ok)
;*    select hdg error
;*    case < 0
;*       roll demand = -90
;*    case = 0
;*       roll demand = 0
;*    case > 0
;*       roll demand = 90
;*    endselect
;* case > 0 (pull)
;*    roll demand = arctan(hdg error / pitch error)
;* endselect

		cmp	PitchError,0
		jg	CasePull
		je	CasePitchOk

;---------------------------
CasePush	LABEL	NEAR		;(pitch error < 0)
;---------------------------

		mov	ax,HdgError

		cwd

		mov	ax,32767
		xor	ax,dx
		sub	ax,dx

		jmp	SetRollDemand

;---------------------------
CasePitchOk	LABEL	NEAR		;(pitch error = 0)
;---------------------------

		cmp	HdgError,0

		mov	ax,-128*128	;-90 degs
		jl	SetRollDemand

		mov	ax,128*128	;90 degs
		jg	SetRollDemand

		xor	ax,ax		;0 degs

		jmp	SetRollDemand

;---------------------------
CasePull	LABEL	NEAR		;(pitch error > 0)
;---------------------------

		mov	ax,PitchError
		ABSV	ax
		mov	bx,ax
		mov	bp,dx

		mov	ax,HdgError
		ABSV	ax
		xor	bp,dx		;bp = sign result

		cmp	ax,bx
		jne	@F

;* abs(hdg error) = abs(pitch error)
;*
;* roll demand = 45 * sign(result)

		mov	ax,64*128	;45 degs

		xor	ax,bp
		sub	ax,bp

		jmp	SetRollDemand

@@:		ja	@F

;* abs(hdg error) < abs(pitch error)
;*
;* roll demand = arctan(abs(hdg error) / abs(pitch error)) * sign(result)

		mov	dx,ax
		xor	ax,ax

		shr	dx,1
		rcr	ax,1

		div	bx

		push	bp
		call	ArcTan
		pop	bp

		xor	ax,bp
		sub	ax,bp

		jmp	SetRollDemand

;* abs(hdg error) > abs(pitch error)
;*
;* roll demand = 90 - arctan(abs(pitch error) / abs(hdg error)) * sign(result)

@@:		mov	dx,bx
		mov	bx,ax
		xor	ax,ax

		shr	dx,1
		rcr	ax,1

		div	bx

		push	bp
		call	ArcTan
		pop	bp

		mov	dx,128*128
		xchg	ax,dx

		sub	ax,dx

		xor	ax,bp
		sub	ax,bp

SetRollDemand:	mov	RollDemand,ax

;------------------
;* damp roll demand
;------------------

;* roll demand = roll demand * damp factor
;*
;* damp factor = max(sin(abs(roll demand >> 9)), sin(abs(pitch error >> 8)))

		ABSV	ax
		mov	cl,9
		shr	ax,cl
		adc	ax,0
		and	ax,511

		SINE	bp,ax

		mov	ax,PitchError
		ABSV	ax
		mov	cl,8
		shr	ax,cl
		adc	ax,0
		and	ax,511

		SINE	dx,ax

		cmp	dx,bp
		jae	@F
		mov	dx,bp

@@:		mov	ax,RollDemand

		imul	dx
		FRACADJ	dx

;* if cos(brg error) > 32767-128 (0.996) then
;*    roll demand = roll demand * (1 - cos(brg error)) * 256
;* endif

		cmp	CosBrgError,32767-128
		jle	@F

		mov	ax,32767
		sub	ax,CosBrgError
		mov	cl,8
		shl	ax,cl

		imul	dx
		FRACADJ	dx

@@:		mov	DampedRoll,dx

;-------------------
;* calc pitch demand
;-------------------

;* delta pitch error = pitch error - prev pitch error
;*
;* select delta pitch error
;* case < 0 (error reduced)
;*    if abs(delta pitch error) >= pitch error then
;*       (closing in - reduce pull to avoid overshoot)
;*       pitch rate = prev pitch rate + delta pitch error + pitch error
;*    else
;*       pitch rate = prev pitch rate
;*    endif
;* case = 0 (error same)
;*    if abs(pitch error) <= 1 deg then
;*       pitch rate = prev pitch rate
;*    else
;*       pitch rate = prev pitch rate + pitch error / 2
;*    endif
;* case > 0 (error increased)
;*    pitch rate = delta pitch error + prev pitch rate
;* endselect

;* calc delta pitch error

		mov	bp,PitchError
		sub	bp,AC_Data.AC_PREV_PERR

		cmp	bp,0

		jl	DecError	;decreased error ->
		jg	IncError	;increased error ->

;---------------------------
SameError	LABEL	NEAR		;(pitch error same)
;---------------------------

		mov	ax,PitchError
		ABSV	ax
		cmp	ax,182		;182 = 1 deg

		ja	@F

;* abs(pitch error) <= 1 deg

		mov	ax,AC_Data.AC_PREV_PRATE

		jmp	ContPitchRate

;* abs(pitch error) > 1 deg

@@:		shr	ax,1
		adc	ax,0
		xor	ax,dx
		sub	ax,dx

		add	ax,AC_Data.AC_PREV_PRATE

		jmp	ContPitchRate

;---------------------------
DecError	LABEL	NEAR		;(pitch error reduced)
;---------------------------

		mov	ax,bp
		ABSV	ax

;* potential bug if abs(delta pitch error) = 32768 (pitch error compare is signed)

		cmp	ax,32768
		jb	@F
		mov	ax,32767

@@:		cmp	ax,PitchError
		jl	@F

;* abs(delta pitch error) >= pitch error

		mov	ax,AC_Data.AC_PREV_PRATE
		add	ax,bp
		add	ax,PitchError

		jmp	ContPitchRate

;* abs(delta pitch error) < pitch error

@@:		mov	ax,AC_Data.AC_PREV_PRATE

		jmp	ContPitchRate

;---------------------------
IncError	LABEL	NEAR		;(pitch error increased)
;---------------------------

		mov	ax,AC_Data.AC_PREV_PRATE
		add	ax,bp

;------------------------------------
;* reduce pitch rate with roll demand
;------------------------------------

;* pitch rate = pitch rate * cos(roll demand / 2)

ContPitchRate:	mov	bp,ax

		mov	ax,RollDemand
		sar	ax,1

		mov	cl,7		;convert fine pdegs -> pdegs
		shr	ax,cl
		adc	ax,0
		and	ax,511

		COSINE	ax,ax

		imul	bp
		FRACADJ	ax

;-------------------------------
;* keep pitch rate within limits
;-------------------------------

		SBOUND	ax,-3*16,MaxPRate

		mov	PitchRate,ax

;* if pitch rate = min pitch rate then 
;*    damped roll demand = 180 * sign(damped roll demand)
;*    (convert push to pull via roll)
;* endif

		cmp	ax,-3*16
		jne	@F

		mov	ax,DampedRoll
		cwd
		mov	ax,32767
		xor	ax,dx
		sub	ax,dx
		mov	DampedRoll,ax

;--------------------------------
;* keep roll demand within limits
;--------------------------------

@@:		mov	ax,DampedRoll
		ABSV	ax
		cmp	ax,MaxRRate
		jbe	@F
		mov	ax,MaxRRate
		xor	ax,dx
		sub	ax,dx
		mov	DampedRoll,ax

;----------------------------------------------------------------------------
;* 		   ///// adjust heading, pitch and roll /////
;----------------------------------------------------------------------------

;* roll = roll + roll demand

@@:		mov	ax,DampedRoll
		add	ax,AC_Data.AC_RFINE
		mov	AC_Data.AC_RFINE,ax

;* calc sin(new roll), cos(new roll)

		mov	cl,7		;convert fine pdegs -> pdegs
		shr	ax,cl
		adc	ax,0
		and	ax,511

		SINCOS	si,di,ax		

;* if abs(pitch) <> 90 degs then
;*    delta hdg = pitch rate * sin(new roll)
;* else
;*    delta hdg = roll demand
;* endif

		cmp	AC_View.VP_PITCH,128	;90 degs?
		je	@F			;yes ->
		cmp	AC_View.VP_PITCH,384	;-90 degs?
		je	@F			;yes ->

		mov	ax,PitchRate
		imul	si
		FRACADJ	dx

		jmp	SortHdg

@@:		mov	dx,DampedRoll

SortHdg:	add	AC_Data.AC_HFINE,dx

;* delta pitch = pitch rate * cos(new roll)

		mov	ax,PitchRate
		imul	di
		FRACADJ	dx

;* pitch = pitch + delta pitch

		add	AC_Data.AC_PFINE,dx

;----------------------
;* check for pitch flip
;----------------------

		mov	ax,AC_Data.AC_HFINE
		mov	bx,AC_Data.AC_PFINE
		mov	cx,AC_Data.AC_RFINE

		xor	dx,dx

		call	LimitPFine

		mov	AC_Data.AC_HFINE,ax
		mov	AC_Data.AC_PFINE,bx
		mov	AC_Data.AC_RFINE,cx

;----------------------
;* miscellaneous params
;----------------------

		mov	AC_Data.AC_LIFT_VCTR,bx

		mov	ax,PitchError
		mov	AC_Data.AC_PREV_PERR,ax

		mov	ax,PitchRate
		mov	AC_Data.AC_PREV_PRATE,ax

;----------------------------------------------------------------------------
;* 			  ///// combat throttle /////
;----------------------------------------------------------------------------

;-------------------
;* look up min speed (wrt altitude)
;-------------------

		mov	bx,WORD PTR AC_View.VP_ZFT_LO

		cmp	WORD PTR AC_View.VP_ZFT_HI,0	;zft > 65,535ft?
		je	@F				;no ->

		mov	bx,65535	;limit

@@:		mov	cl,10		;/1024

		shr	bx,cl
		ROUNDUP	bx		;0 .. 64
		shl	bx,1		;*2 word index

		mov	ax,MinSpeed[bx]

		mov	AC_Vmin,ax

		shl	ax,1		;vtrim = min speed * 2

		mov	AC_Vtrim,ax

;----------------
;* calc max speed (wrt altitude)
;---------------- 

		mov	di,PerfDataPtr
		mov	di,PERF_CRUISE[di]

		mov	dx,WORD PTR AC_View.VP_ZFT_HI
		mov	ax,WORD PTR AC_View.VP_ZFT_LO

;* limit zft to 32,767ft (approx. 36,000ft)

		cmp	dx,0		;zft > 65,535ft?
		ja	@F		;yes ->
		cmp	ax,32767	;zft <= 32,767ft
		jbe	AltOk		;yes ->

@@:		mov	ax,32767

;* interpolate max speed (wrt altitude)
;*
;* max speed = (vmax(36,000ft) - vmax(sea level)) * zft / 32768 + vmax(sea level)

AltOk:		mov	dx,CRS_MXSPEED_36[di]
		sub	dx,CRS_MXSPEED_SL[di]

		imul	dx
		FRACADJ	dx

		add	dx,CRS_MXSPEED_SL[di]

		mov	AC_Vmax,dx

;-------------------
;* check if breaking
;-------------------

		test	AC_Data.AC_FLAGS,AFLG_UPRIGHT
		jnz	SetCombatSpeed

;-----------------------
;* check behind opponent
;-----------------------

		cmp	CosBrgError,0
		jl	SetCombatSpeed

;-------------------
;* calc aiming speed (behind opponent)
;-------------------

		mov	ax,WORD PTR SlantRng
		mov	dx,WORD PTR SlantRng+2

		mov	bp,1000		;assume Tornado

		cmp	AC_Data.AC_OPP_PTR,OFFSET M_MOBILE
		je	@F

		mov	bp,6076
		
@@:		cmp	dx,0
		ja	@F
		cmp	ax,bp
		jbe	SetCombatSpeed

;* aiming speed = sbound(target speed + range / 4, vmin, vmax)

@@:		REPT	2
		shr	dx,1
		rcr	ax,1
		ENDM

		add	ax,OppVtas
		adc	dx,0

;* keep in range

		cmp	dx,0
		ja	@F
		cmp	ax,32767
		ja	@F

		SBOUND	ax,AC_Vtrim,AC_Vmax

		jmp	CalcAccel

@@:		mov	ax,AC_Vmax

		jmp	CalcAccel

;-------------------
;* calc aiming speed (ahead of or close to opponent)
;-------------------

;* aiming speed = vmin + vtrim

SetCombatSpeed:	mov	ax,AC_Vmin
		add	ax,AC_Vtrim

;---------------------------
CalcAccel	LABEL	NEAR
;---------------------------

		mov	di,PerfDataPtr
		mov	di,PERF_COMBAT[di]

;* calc speed error

		mov	cx,ax		;cx = aiming speed
		xor	bx,bx

		sub	bx,AC_Data.AC_VTAS_FINE
		sbb	cx,AC_Data.AC_VTAS
		js	@F		;decelerate ->

;* accelerating - calc delta max accel (keep result as 32-bit value)

		xor	si,si		;accel

		mov	ax,COM_ACCEL[di]
		mov	dx,DeltaTime
		imul	dx

		shl	ax,1		;adjust after fractional multiply
		rcl	dx,1

		jmp	SortAccel

;* decelerating - calc delta fixed decel (keep result as 32-bit value)

@@:		mov	si,-1		;decel

		mov	ax,COM_ACCEL[di]
		mov	dx,DeltaTime
		imul	dx

;* (do not adjust after fractional multiply as decel = accel / 2)

		NEG32	cx,bx

		cmp	cx,100*8	;error > 100ft/sec?
		jbe	SortAccel	;no ->

		REPT	2		;use airbrake (decel * 4)
		shl	ax,1
		rcl	dx,1
		ENDM

;* if accel > error then
;*    accel = error
;* endif

SortAccel:	cmp	dx,cx
		jb	AccOk
		ja	@F
		cmp	ax,bx
		jbe	AccOk

@@:		mov	dx,cx
		mov	ax,bx

AccOk:		xor	ax,si		;restore sign
		xor	dx,si
		sub	ax,si
		sbb	dx,si

		xor	bx,si		;restore sign
		xor	cx,si
		sub	bx,si
		sbb	cx,si

		add	AC_Data.AC_VTAS_FINE,ax
		adc	AC_Data.AC_VTAS,dx

;--------------------------------------
;* sort wing sweep and reheat animation (wrt speed vs max speed)
;--------------------------------------

;* update inhibit delays (prevent animations from oscillating)

		mov	al,AC_Data.AC_AB_DELAY
		sub	al,BYTE PTR LastFrame
		MINM	al
		mov	AC_Data.AC_AB_DELAY,al

		mov	al,AC_Data.AC_SWEEP_DELAY
		sub	al,BYTE PTR LastFrame
		MINM	al
		mov	AC_Data.AC_SWEEP_DELAY,al

;* if speed <= (max speed / 2) then
;*    wing sweep forward
;* else
;*    if speed <= (max speed * 3 / 4) then
;*       wing sweep mid
;*    else
;*       wing sweep back
;*       if error >= -25ft/sec then    	;allow -ve to avoid reheat flickering
;*          reheat on
;*       endif
;*    endif
;* endif
;*
;* if error >= 50ft/sec then
;*    reheat on
;* endif

		mov	dx,AC_Vmax

		xor	bh,bh		;assume reheat off

		mov	ax,AC_Data.AC_VTAS

		shr	dx,1		;max speed / 2

		mov	bl,WING_SWEEP_FWD

		cmp	ax,dx		;sweep <= (max speed / 2)?
		jbe	@F		;yes ->

		sub	ax,dx
		shr	dx,1		;max speed / 4

		mov	bl,WING_SWEEP_MID

		cmp	ax,dx		;sweep <= (max speed * 3 / 4)?
		jbe	@F		;yes ->

		mov	bl,WING_SWEEP_BCK

		cmp	cx,-25*8	;error >= -25ft/sec?
		jl	@F		;no ->

		mov	bh,REHEAT_ALL

@@:		cmp	cx,50*8		;error >= 50ft/sec
		jl	@F		

		mov	bh,REHEAT_ALL

;* if reheat animation not inhibited then
;*    if reheat animation changed then
;*       sort reheat animation
;*       set inhibit delay
;*    endif
;* endif

@@:		cmp	AC_Data.AC_AB_DELAY,0	;inhibited?
		jne	@F			;yes ->

		mov	al,AC_Mobile.MOB_ANIM
		and	al,REHEAT_ALL
		cmp	al,bh			;changed?
		je	@F			;no ->

		and	AC_Mobile.MOB_ANIM,NOT REHEAT_ALL	;clear old
		or	AC_Mobile.MOB_ANIM,bh			;set new

		mov	AC_Data.AC_AB_DELAY,255	;set 2.55 secs delay

;* if wing sweep animation not inhibited then
;*    if wing sweep animation changed then
;*       sort wing sweep animation
;*       set inhibit delay
;*    endif
;* endif

@@:		cmp	AC_Data.AC_SWEEP_DELAY,0	;inhibited?
		jne	@F				;yes ->

		mov	al,AC_Mobile.MOB_ANIM
		and	al,WING_SWEEP_ALL
		cmp	al,bl			;changed?
		je	@F			;no ->

		and	AC_Mobile.MOB_ANIM,NOT WING_SWEEP_ALL	;clear old
		or	AC_Mobile.MOB_ANIM,bl			;set new

		mov	AC_Data.AC_SWEEP_DELAY,255	;set 2.55 secs delay

@@:

;----------------------------------------------------------------------------
;*       ///// assert break if aircraft pitch and roll in limits /////
;----------------------------------------------------------------------------

;* fly upright?

		test	AC_Data.AC_FLAGS,AFLG_UPRIGHT
		jz	ExitCombat

		cmp	WORD PTR AC_View.VP_ZFT_HI,0
		ja	ExitCombat
		cmp	WORD PTR AC_View.VP_ZFT_LO,BREAK_ALT+200
		ja	ExitCombat

;* abs(roll) < 90 degs?

		mov	ax,AC_Data.AC_RFINE
		ABSV	ax
		cmp	ax,128*128
		jae	ExitCombat

;* abs(pitch) < 30 degs

		mov	ax,AC_Data.AC_PFINE
		ABSV	ax
		cmp	ax,43*128
		jae	ExitCombat

		mov	AC_Data.AC_CTRL_MODE,CTRL_TRACK

ExitCombat:	ret

CtrlCombat	ENDP

;----------------------------------------------------------------------------

;* SelectBreakWP
;*
;* pass: AircraftPtr
;* ret : cf = 0: break ok
;*       cf = 1: break error
;* kill: si, flags (except cf)

SelectBreakWP	PROC	NEAR

		mov	si,AircraftPtr

		add	si,AC_WAYPOINTS		;si -> first waypoint

@@:		test	WP_ATTR[si],WP_VALID	;waypoint in use?
		jz	BreakFail		;no, break failed ->

		test	WP_ATTR[si],WP_BREAK	;break to here?
		jnz	BreakPass		;yes ->

		add	si,WAY_REC_SIZE		;next waypoint

		jmp	@B

BreakFail:	stc				;break error
		ret

BreakPass:	mov	AC_Data.AC_WP_PTR,si	;update waypoint ptr

		clc				;break ok
		ret

SelectBreakWP	ENDP

;----------------------------------------------------------------------------

;* TornadoAction - Tornado interaction with enemy aircraft
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

TornadoAction	PROC	NEAR

;------------------------------
;* no interaction in demo modes
;------------------------------

		cmp	DemoMode,0
		_JNE	ActionExit

;---------------------------------------
;* check if Tornado has a valid opponent
;---------------------------------------

		cmp	TornadoOppPtr,-1
		je	ContAction

		mov	si,TornadoOppPtr

;* opponent alive?

		cmp	_AC_SIDE[si],ENEMY
		jne	@F

;* opponent in combat mode?

		cmp	_AC_CTRL_MODE[si],CTRL_COMBAT
		jne	@F

;* opponent vs Tornado?

		cmp	_AC_OPP_PTR[si],OFFSET M_MOBILE
		jne	@F

		jmp	CheckEscort

@@:		mov	TornadoOppPtr,-1

;----------------
;* check airborne
;----------------

ContAction:	test	Airborne1,1
		_JZ	ActionExit

;--------------------------------------------
;* no hostility if flying very low, very fast
;--------------------------------------------

		cmp	TrueRadAlt,VERY_LOW
		ja	@F

		mov	ax,Vias
		cmp	ax,VERY_FAST
		_JA	ActionExit

;----------------------------------------------------
;* check for counter attack against Tornado hostility
;----------------------------------------------------

;* missile fired?

@@:		mov	si,MissileTgtPtr

		cmp	si,-1
		jne	@F

;* radar lock?

		mov	si,AirTgtPtr

		cmp	si,-1
		_JE	SkipCntrAttack

;* check enemy target

@@:		cmp	_DRONE_SIDE[si],ENEMY
		jne	SkipCntrAttack

;* hostile to interceptor?

		cmp	si,OFFSET EAircraft7
		je	ICResponse
		cmp	si,OFFSET EAircraft8
		je	ICResponse
		cmp	si,OFFSET EAircraft9
		je	ICResponse
		cmp	si,OFFSET EAircraft10
		je	ICResponse
		cmp	si,OFFSET EAircraft11
		je	ICResponse
		cmp	si,OFFSET EAircraft12
		je	ICResponse

;* hostile to AWACS?

		cmp	si,OFFSET EAircraft17
		je	AWACSResponse

		jmp	MiscResponse

;---------------------------
ICResponse	LABEL	NEAR
;---------------------------

;* immediate retaliation from enemy interceptor

		call	CheckICAvail
		jc	MiscResponse

		mov	TornadoOppPtr,si

		mov	di,OFFSET M_MOBILE
		call	SetCombatMode

		jmp	CheckEscort

;---------------------------
AWACSResponse	LABEL	NEAR
;---------------------------

;* immediate retaliation from nearest enemy interceptor

		mov	si,OFFSET M_MOBILE

		call	FindEnemyIC
		_JC	ActionExit

		mov	TornadoOppPtr,si

		mov	di,OFFSET M_MOBILE
		call	SetCombatMode

		jmp	CheckEscort

;---------------------------
MiscResponse	LABEL	NEAR
;---------------------------

;* set response timer (if not already set)

		cmp	ResponseTimer,0
		ja	SkipCntrAttack

		call	RandX		; 0.00 ..  2.55
		shl	ax,1		; 0.00 ..  5.10
		shl	ax,1		; 0.00 .. 10.20
		shl	ax,1		; 0.00 .. 20.40
		shl	ax,1		; 0.00 .. 40.80
		add	ax,40*100	;40.00 .. 80.80

;* increase response time if enemy AWACS destroyed

		cmp	BYTE PTR EAircraft17+_AC_SIDE,ENEMY
		je	@F

		add	ax,60*100

@@:		mov	ResponseTimer,ax

SkipCntrAttack:

;---------------------------
;* update EWR exposure timer
;---------------------------

;* note: The EWRExposeTimer is not updated when the Tornado has an opponent. 
;*       There would be no point as another interceptor cannot be dispatched
;*       until the current one is finished.

;* exposed to enemy EWR?

		test	RWRThreatFlags,RWR_EWR
		jz	SkipEWR

;* update EWR timer

		mov	ax,EWRExposeTimer
		sub	ax,LastFrame
		MINM	ax
		mov	EWRExposeTimer,ax

		jnz	SkipEWR

;* time up, dispatch interceptor

		mov	si,OFFSET M_MOBILE

		call	FindEnemyIC
		_JC	ActionExit

		mov	TornadoOppPtr,si

		mov	di,OFFSET M_MOBILE
		call	SetCombatMode

		call	SetEWRTimer

		jmp	CheckEscort

SkipEWR:

;-----------------------
;* update response timer
;-----------------------

;* note: The ResponseTimer is not updated when the Tornado has an opponent. 
;*       There would be no point as another interceptor cannot be dispatched
;*       until the current one is finished.

		cmp	ResponseTimer,0
		je	SkipResponse

		mov	ax,ResponseTimer
		sub	ax,LastFrame
		MINM	ax
		mov	ResponseTimer,ax

		jnz	SkipResponse

;* time up, dispatch interceptor

		mov	si,OFFSET M_MOBILE

		call	FindEnemyIC
		_JC	ActionExit

		mov	TornadoOppPtr,si

		mov	di,OFFSET M_MOBILE
		call	SetCombatMode

		jmp	CheckEscort

SkipResponse:

;------------------------------------------
;* check if enemy interceptors in proximity
;------------------------------------------

		mov	cx,M_VIEW.VP_XSEC
		mov	bx,M_VIEW.VP_YSEC

		mov	bp,2		;assume emissions

		cmp	RadarMode,NUL_RADAR
		jne	@F

		test	ECMActive,1
		jnz	@F

		mov	bp,1		;no emmisions

@@:		call	ProxEnemyIC
		jc	SkipICProx

		mov	TornadoOppPtr,si

		mov	di,OFFSET M_MOBILE
		call	SetCombatMode

		jmp	CheckEscort

SkipICProx:

;-----------------------------------
;* check if enemy AWACS in proximity
;-----------------------------------

		cmp	BYTE PTR EAircraft17+_AC_SIDE,ENEMY
		jne	SkipAWACSProx

		mov	ax,EAircraft17+_VP_XSEC
		sub	ax,M_VIEW.VP_XSEC
		ABSV	ax
		cmp	ax,3
		ja	SkipAWACSProx

		mov	ax,EAircraft17+_VP_YSEC
		sub	ax,M_VIEW.VP_YSEC
		ABSV	ax
		cmp	ax,3
		ja	SkipAWACSProx

		mov	si,OFFSET M_MOBILE

		call	FindEnemyIC
		_JC	ActionExit

		mov	TornadoOppPtr,si

		mov	di,OFFSET M_MOBILE
		call	SetCombatMode

SkipAWACSProx:

;---------------------------------------------
;* redirect enemy interceptor to nearby escort (if any)
;---------------------------------------------

;* (does not apply to ADV (ADV should be escorting!))

CheckEscort:	cmp	TornadoType,ADV_TORNADO
		je	SkipEscort

;* check valid opponent

		cmp	TornadoOppPtr,-1
		je	SkipEscort

;* locate nearby allied interceptor

		mov	cx,M_VIEW.VP_XSEC
		mov	bx,M_VIEW.VP_YSEC
		mov	bp,2

		call	ProxAlliedIC
		jc	SkipEscort

;* set allied interceptor onto enemy interceptor

		mov	di,TornadoOppPtr

		call	SetCombatMode

;* redirect enemy interceptor to allied interceptor

		mov	_AC_OPP_PTR[di],si

;* cancel Tornado opponent

		mov	TornadoOppPtr,-1

SkipEscort:

;--------------------
;* update break timer (force enemy interceptor to break)
;--------------------

		mov	BreakFlag,0	;reset break flag

;* check Tornado has opponent

		cmp	TornadoOppPtr,-1
		je	SkipBreakTimer

;* check if Tornado off map (assume allied)

		cmp	ModelMapIndex,-1
		je	@F

;* check if Tornado in allied terratory

		mov	bp,ModelMapIndex

		test	SctrGameLayer1[bp],SECT_ENEMY
		jnz	SkipBreakTimer

;* update break timer

@@:		mov	ax,BreakTimer
		sub	ax,LastFrame
		MINM	ax
		mov	BreakTimer,ax
		jnz	SkipBreakTimer

		call	SetBreakTimer

		mov	BreakFlag,1

SkipBreakTimer:

ActionExit:	ret

TornadoAction	ENDP

;----------------------------------------------------------------------------

;* DroneAction - interaction between drone aircraft
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

DroneAction	PROC	NEAR

;-----------------------------------------
;* allied aircraft 7 vs enemy interceptors
;-----------------------------------------

		mov	si,OFFSET AAircraft7
		call	CheckICAvail
		jc	@F

		mov	cx,_VP_XSEC[si]
		mov	bx,_VP_YSEC[si]
		mov	bp,1

		call	ProxEnemyIC
		jc	@F

		mov	di,OFFSET AAircraft7

		call	SetCombatMode	;enemy -> allied

		xchg	si,di

		call	SetCombatMode	;allied -> enemy

;-----------------------------------------
;* allied aircraft 8 vs enemy interceptors
;-----------------------------------------

@@:		mov	si,OFFSET AAircraft8
		call	CheckICAvail
		jc	@F

		mov	cx,_VP_XSEC[si]
		mov	bx,_VP_YSEC[si]
		mov	bp,1

		call	ProxEnemyIC
		jc	@F

		mov	di,OFFSET AAircraft8

		call	SetCombatMode	;enemy -> allied

		xchg	si,di

		call	SetCombatMode	;allied -> enemy

;-----------------------------------------
;* allied aircraft 9 vs enemy interceptors
;-----------------------------------------

@@:		mov	si,OFFSET AAircraft9
		call	CheckICAvail
		jc	@F

		mov	cx,_VP_XSEC[si]
		mov	bx,_VP_YSEC[si]
		mov	bp,1

		call	ProxEnemyIC
		jc	@F

		mov	di,OFFSET AAircraft9

		call	SetCombatMode	;enemy -> allied

		xchg	si,di

		call	SetCombatMode	;allied -> enemy

;------------------------------------------
;* allied aircraft 10 vs enemy interceptors
;------------------------------------------

@@:		mov	si,OFFSET AAircraft10
		call	CheckICAvail
		jc	@F

		mov	cx,_VP_XSEC[si]
		mov	bx,_VP_YSEC[si]
		mov	bp,1

		call	ProxEnemyIC
		jc	@F

		mov	di,OFFSET AAircraft10

		call	SetCombatMode	;enemy -> allied

		xchg	si,di

		call	SetCombatMode	;allied -> enemy

;------------------------------------------
;* allied aircraft 11 vs enemy interceptors
;------------------------------------------

@@:		mov	si,OFFSET AAircraft11
		call	CheckICAvail
		jc	@F

		mov	cx,_VP_XSEC[si]
		mov	bx,_VP_YSEC[si]
		mov	bp,1

		call	ProxEnemyIC
		jc	@F

		mov	di,OFFSET AAircraft11

		call	SetCombatMode	;enemy -> allied

		xchg	si,di

		call	SetCombatMode	;allied -> enemy

;------------------------------------------
;* allied aircraft 12 vs enemy interceptors
;------------------------------------------

@@:		mov	si,OFFSET AAircraft12
		call	CheckICAvail
		jc	@F

		mov	cx,_VP_XSEC[si]
		mov	bx,_VP_YSEC[si]
		mov	bp,1

		call	ProxEnemyIC
		jc	@F

		mov	di,OFFSET AAircraft12

		call	SetCombatMode	;enemy -> allied

		xchg	si,di

		call	SetCombatMode	;allied -> enemy

;------------------------------------
;* allied AWACS vs enemy interceptors
;------------------------------------

;* allied AWACS alive?

@@:		cmp	BYTE PTR AAircraft17+_AC_SIDE,ALLIED
		jne	SkipAAWACS

;* allied AWACS under attack?

		cmp	WORD PTR AAircraft17+_AC_OPP_PTR,-1
		je	@F

;* attacker still alive?

		mov	si,AAircraft17+_AC_OPP_PTR
		cmp	_AC_SIDE[si],DEAD
		jne	SkipAAWACS

		mov	WORD PTR AAircraft17+_AC_OPP_PTR,-1

;* scan for enemy interceptors

@@:   		mov	cx,AAircraft17+_VP_XSEC
		mov	bx,AAircraft17+_VP_YSEC
		mov	bp,3

		call	ProxEnemyIC
		jc	SkipAAWACS

		mov	AAircraft17+_AC_OPP_PTR,si

		mov	di,OFFSET AAircraft17

		call	SetCombatMode

SkipAAWACS:

;------------------------------------
;* enemy AWACS vs allied interceptors
;------------------------------------

;* enemy AWACS alive?

		cmp	BYTE PTR EAircraft17+_AC_SIDE,ENEMY
		jne	SkipEAWACS

;* enemy AWACS under attack?

		cmp	WORD PTR EAircraft17+_AC_OPP_PTR,-1
		je	@F

;* attacker still alive?

		mov	si,EAircraft17+_AC_OPP_PTR
		cmp	_AC_SIDE[si],DEAD
		jne	SkipEAWACS

		mov	WORD PTR EAircraft17+_AC_OPP_PTR,-1

;* scan for allied interceptors

@@:   		mov	cx,EAircraft17+_VP_XSEC
		mov	bx,EAircraft17+_VP_YSEC
		mov	bp,3

		call	ProxAlliedIC
		jc	SkipEAWACS

		mov	EAircraft17+_AC_OPP_PTR,si

		mov	di,OFFSET EAircraft17

		call	SetCombatMode

SkipEAWACS:

		ret

DroneAction	ENDP

;----------------------------------------------------------------------------

;* CheckICAvail - check interceptor available for combat
;*
;* pass: si -> MOBILE + VIEWPOINT + AIRCRAFT compound data block
;* ret : cf = 0: interceptor available
;*       cf = 1: interceptor unavailable
;* kill: flags (except cf)

CheckICAvail	PROC	NEAR

;* check alive

		cmp	_AC_SIDE[si],DEAD
		je	ICUnavail

;* check in tracking mode (ie. unavailabe if landing etc.)

		cmp	_AC_CTRL_MODE[si],CTRL_TRACK
		jne	ICUnavail

;* check for "break" (ie. unavailable if returning to base)

		test	_AC_FLAGS[si],AFLG_BREAK
		jnz	ICUnavail

ICAvail:	clc			;interceptor available
		ret

ICUnavail:	stc			;interceptor unavailable
		ret

CheckICAvail	ENDP

;----------------------------------------------------------------------------

;* SetCombatMode
;*
;* pass: si -> source MOBILE + VIEWPOINT + AIRCRAFT compound data block
;*       di -> target (drone / Tornado etc.)
;* ret : nothing
;* kill: ax, flags

SetCombatMode	PROC	NEAR

		mov	_AC_CTRL_MODE[si],CTRL_COMBAT

		mov	_AC_OPP_PTR[si],di

		and	_AC_FLAGS[si],NOT (AFLG_EVADE_HI+AFLG_EVADE_LO+AFLG_UPRIGHT)

		xor	ax,ax

		mov	_AC_PREV_PERR[si],ax
		mov	_AC_PREV_PRATE[si],ax
		mov	_AC_EVADE_TIMER[si],ax

		ret

SetCombatMode	ENDP

;----------------------------------------------------------------------------

;* FindEnemyIC - find nearest enemy interceptor
;*
;* pass: si -> source MOBILE + VIEWPOINT (drone aircraft / Tornado)
;* ret : cf = 0: interceptor available
;*               si -> MOBILE + VIEWPOINT + AIRCRAFT compound data block
;*	         dx, ax = range
;*       cf = 1: interceptor unavailable
;* kill: bx, cx, di, bp, flags

FindEnemyIC	PROC	NEAR

		add	si,MOB_REC_SIZE

		mov	TmpSrcPtr,si

;* set range to worst case

		mov	WORD PTR TmpICRng,-1
		mov	WORD PTR TmpICRng+2,-1

;* set null ptr

		mov	TmpICPtr,-1

;------------------------
;* check enemy aircraft 7
;------------------------

		mov	si,OFFSET EAircraft7
		call	CheckICAvail
		jc	SkipE7

		mov	di,TmpSrcPtr

		call	CalcSlantRange

		cmp	dx,WORD PTR TmpICRng+2
		ja	SkipE7
		jb	@F
		cmp	ax,WORD PTR TmpICRng
		ja	SkipE7

@@:		mov	WORD PTR TmpICRng,ax
		mov	WORD PTR TmpICRng+2,dx

		mov	TmpICPtr,OFFSET EAircraft7

;------------------------
;* check enemy aircraft 8
;------------------------

SkipE7:		mov	si,OFFSET EAircraft8
		call	CheckICAvail
		jc	SkipE8

		mov	di,TmpSrcPtr

		call	CalcSlantRange

		cmp	dx,WORD PTR TmpICRng+2
		ja	SkipE8
		jb	@F
		cmp	ax,WORD PTR TmpICRng
		ja	SkipE8

@@:		mov	WORD PTR TmpICRng,ax
		mov	WORD PTR TmpICRng+2,dx

		mov	TmpICPtr,OFFSET EAircraft8

;------------------------
;* check enemy aircraft 9
;------------------------

SkipE8:		mov	si,OFFSET EAircraft9
		call	CheckICAvail
		jc	SkipE9

		mov	di,TmpSrcPtr

		call	CalcSlantRange

		cmp	dx,WORD PTR TmpICRng+2
		ja	SkipE9
		jb	@F
		cmp	ax,WORD PTR TmpICRng
		ja	SkipE9

@@:		mov	WORD PTR TmpICRng,ax
		mov	WORD PTR TmpICRng+2,dx

		mov	TmpICPtr,OFFSET EAircraft9

;-------------------------
;* check enemy aircraft 10
;-------------------------

SkipE9:		mov	si,OFFSET EAircraft10
		call	CheckICAvail
		jc	SkipE10

		mov	di,TmpSrcPtr

		call	CalcSlantRange

		cmp	dx,WORD PTR TmpICRng+2
		ja	SkipE10
		jb	@F
		cmp	ax,WORD PTR TmpICRng
		ja	SkipE10

@@:		mov	WORD PTR TmpICRng,ax
		mov	WORD PTR TmpICRng+2,dx

		mov	TmpICPtr,OFFSET EAircraft10

;-------------------------
;* check enemy aircraft 11
;-------------------------

SkipE10: 	mov	si,OFFSET EAircraft11
		call	CheckICAvail
		jc	SkipE11

		mov	di,TmpSrcPtr

		call	CalcSlantRange

		cmp	dx,WORD PTR TmpICRng+2
		ja	SkipE11
		jb	@F
		cmp	ax,WORD PTR TmpICRng
		ja	SkipE11

@@:		mov	WORD PTR TmpICRng,ax
		mov	WORD PTR TmpICRng+2,dx

		mov	TmpICPtr,OFFSET EAircraft11

;-------------------------
;* check enemy aircraft 12
;-------------------------

SkipE11: 	mov	si,OFFSET EAircraft12
		call	CheckICAvail
		jc	SkipE12

		mov	di,TmpSrcPtr

		call	CalcSlantRange

		cmp	dx,WORD PTR TmpICRng+2
		ja	SkipE12
		jb	@F
		cmp	ax,WORD PTR TmpICRng
		ja	SkipE12

@@:		mov	WORD PTR TmpICRng,ax
		mov	WORD PTR TmpICRng+2,dx

		mov	TmpICPtr,OFFSET EAircraft12

;--------------------------------
;* check interceptor availability
;--------------------------------

SkipE12:	cmp	TmpICPtr,-1
		je	@F

		mov	si,TmpICPtr

		mov	ax,WORD PTR TmpICRng
		mov	dx,WORD PTR TmpICRng+2

		clc			;interceptor available
		ret	

@@:		stc			;interceptor unavailable
		ret

FindEnemyIC	ENDP

;----------------------------------------------------------------------------

;* ProxEnemyIC - check proximity to enemy interceptors
;*
;* pass: cx = xsec
;*       bx = ysec
;*       bp = range threshold (sectors)
;*            0 = 1 * 1 sectors
;*            1 = 3 * 3 sectors
;*            2 = 5 * 5 sectors
;*	      etc.
;* ret : cf = 0: interceptor located
;*               si -> MOBILE + VIEWPOINT + AIRCRAFT compound data block
;*       cf = 1: interceptor not located
;* kill: ax, dx, flags

ProxEnemyIC	PROC	NEAR

;------------------------
;* check enemy aircraft 7
;------------------------

		mov	si,OFFSET EAircraft7
		call	CheckICAvail
		jc	@F

		mov	ax,_VP_XSEC[si]
		sub	ax,cx
		ABSV	ax
		cmp	ax,bp
		ja	@F

		mov	ax,_VP_YSEC[si]
		sub	ax,bx
		ABSV	ax
		cmp	ax,bp
		ja	@F

		clc			;interceptor located

		jmp	ProxEnemyExit

;------------------------
;* check enemy aircraft 8
;------------------------

@@:		mov	si,OFFSET EAircraft8
		call	CheckICAvail
		jc	@F

		mov	ax,_VP_XSEC[si]
		sub	ax,cx
		ABSV	ax
		cmp	ax,bp
		ja	@F

		mov	ax,_VP_YSEC[si]
		sub	ax,bx
		ABSV	ax
		cmp	ax,bp
		ja	@F

		clc			;interceptor located

		jmp	ProxEnemyExit

;------------------------
;* check enemy aircraft 9
;------------------------

@@:		mov	si,OFFSET EAircraft9
		call	CheckICAvail
		jc	@F

		mov	ax,_VP_XSEC[si]
		sub	ax,cx
		ABSV	ax
		cmp	ax,bp
		ja	@F

		mov	ax,_VP_YSEC[si]
		sub	ax,bx
		ABSV	ax
		cmp	ax,bp
		ja	@F

		clc			;interceptor located

		jmp	ProxEnemyExit

;-------------------------
;* check enemy aircraft 10
;-------------------------

@@:		mov	si,OFFSET EAircraft10
		call	CheckICAvail
		jc	@F

		mov	ax,_VP_XSEC[si]
		sub	ax,cx
		ABSV	ax
		cmp	ax,bp
		ja	@F

		mov	ax,_VP_YSEC[si]
		sub	ax,bx
		ABSV	ax
		cmp	ax,bp
		ja	@F

		clc			;interceptor located

		jmp	ProxEnemyExit

;-------------------------
;* check enemy aircraft 11
;-------------------------

@@:		mov	si,OFFSET EAircraft11
		call	CheckICAvail
		jc	@F

		mov	ax,_VP_XSEC[si]
		sub	ax,cx
		ABSV	ax
		cmp	ax,bp
		ja	@F

		mov	ax,_VP_YSEC[si]
		sub	ax,bx
		ABSV	ax
		cmp	ax,bp
		ja	@F

		clc			;interceptor located

		jmp	ProxEnemyExit

;-------------------------
;* check enemy aircraft 12
;-------------------------

@@:		mov	si,OFFSET EAircraft12
		call	CheckICAvail
		jc	@F

		mov	ax,_VP_XSEC[si]
		sub	ax,cx
		ABSV	ax
		cmp	ax,bp
		ja	@F

		mov	ax,_VP_YSEC[si]
		sub	ax,bx
		ABSV	ax
		cmp	ax,bp
		ja	@F

		clc			;interceptor located

		jmp	ProxEnemyExit

;------------------------------
;* no interceptors in proximity
;------------------------------

@@:		stc			;interceptor not located

ProxEnemyExit:	ret

ProxEnemyIC	ENDP

;----------------------------------------------------------------------------

;* ProxAlliedIC - check proximity to allied interceptors
;*
;* pass: cx = xsec
;*       bx = ysec
;*       bp = range threshold (sectors)
;*            0 = 1 * 1 sectors
;*            1 = 3 * 3 sectors
;*            2 = 5 * 5 sectors
;*	      etc.
;* ret : cf = 0: interceptor located
;*               si -> MOBILE + VIEWPOINT + AIRCRAFT compound data block
;*       cf = 1: interceptor not located
;* kill: ax, dx, flags

ProxAlliedIC	PROC	NEAR

;-------------------------
;* check allied aircraft 7
;-------------------------

		mov	si,OFFSET AAircraft7
		call	CheckICAvail
		jc	@F

		mov	ax,_VP_XSEC[si]
		sub	ax,cx
		ABSV	ax
		cmp	ax,bp
		ja	@F

		mov	ax,_VP_YSEC[si]
		sub	ax,bx
		ABSV	ax
		cmp	ax,bp
		ja	@F

		clc			;interceptor located

		jmp	ProxAlliedExit

;-------------------------
;* check allied aircraft 8
;-------------------------

@@:		mov	si,OFFSET AAircraft8
		call	CheckICAvail
		jc	@F

		mov	ax,_VP_XSEC[si]
		sub	ax,cx
		ABSV	ax
		cmp	ax,bp
		ja	@F

		mov	ax,_VP_YSEC[si]
		sub	ax,bx
		ABSV	ax
		cmp	ax,bp
		ja	@F

		clc			;interceptor located

		jmp	ProxAlliedExit

;-------------------------
;* check allied aircraft 9
;-------------------------

@@:		mov	si,OFFSET AAircraft9
		call	CheckICAvail
		jc	@F

		mov	ax,_VP_XSEC[si]
		sub	ax,cx
		ABSV	ax
		cmp	ax,bp
		ja	@F

		mov	ax,_VP_YSEC[si]
		sub	ax,bx
		ABSV	ax
		cmp	ax,bp
		ja	@F

		clc			;interceptor located

		jmp	ProxAlliedExit

;--------------------------
;* check allied aircraft 10
;--------------------------

@@:		mov	si,OFFSET AAircraft10
		call	CheckICAvail
		jc	@F

		mov	ax,_VP_XSEC[si]
		sub	ax,cx
		ABSV	ax
		cmp	ax,bp
		ja	@F

		mov	ax,_VP_YSEC[si]
		sub	ax,bx
		ABSV	ax
		cmp	ax,bp
		ja	@F

		clc			;interceptor located

		jmp	ProxAlliedExit

;--------------------------
;* check allied aircraft 11
;--------------------------

@@:		mov	si,OFFSET AAircraft11
		call	CheckICAvail
		jc	@F

		mov	ax,_VP_XSEC[si]
		sub	ax,cx
		ABSV	ax
		cmp	ax,bp
		ja	@F

		mov	ax,_VP_YSEC[si]
		sub	ax,bx
		ABSV	ax
		cmp	ax,bp
		ja	@F

		clc			;interceptor located

		jmp	ProxAlliedExit

;--------------------------
;* check allied aircraft 12
;--------------------------

@@:		mov	si,OFFSET AAircraft12
		call	CheckICAvail
		jc	@F

		mov	ax,_VP_XSEC[si]
		sub	ax,cx
		ABSV	ax
		cmp	ax,bp
		ja	@F

		mov	ax,_VP_YSEC[si]
		sub	ax,bx
		ABSV	ax
		cmp	ax,bp
		ja	@F

		clc			;interceptor located

		jmp	ProxAlliedExit

;------------------------------
;* no interceptors in proximity
;------------------------------

@@:		stc			;interceptor not located

ProxAlliedExit:	ret

ProxAlliedIC	ENDP

;----------------------------------------------------------------------------

;* SetEWRTimer
;*
;* pass: nothing
;* ret : EWRExposeTimer
;* kill: ax, flags

SetEWRTimer	PROC	NEAR

		call	RandX		; 0.00 ..   2.55
		shl	ax,1		; 0.00 ..   5.10
		shl	ax,1		; 0.00 ..  10.20
		shl	ax,1		; 0.00 ..  20.40
		shl	ax,1		; 0.00 ..  40.80
		add	ax,60*100	;60.00 .. 100.80

		mov	EWRExposeTimer,ax

		ret

SetEWRTimer	ENDP

;----------------------------------------------------------------------------

;* SetBreakTimer
;*
;* pass: nothing
;* ret : BreakTimer
;* kill: ax, flags

SetBreakTimer	PROC	NEAR

		call	RandX		; 0.00 ..   2.55
		shl	ax,1		; 0.00 ..   5.10
		shl	ax,1		; 0.00 ..  10.20
		shl	ax,1		; 0.00 ..  20.40
		shl	ax,1		; 0.00 ..  40.80
		shl	ax,1		; 0.00 ..  81.60
		add	ax,60*100	;60.00 .. 141.60

		mov	BreakTimer,ax

		ret

SetBreakTimer	ENDP

;----------------------------------------------------------------------------

;* SetVeryFast
;*
;* pass: nothing
;* ret : VERY_FAST
;* kill: ax, flags

SetVeryFast	PROC	NEAR

		call	RandX		;   0 .. 255
		shl	ax,1		;   0 .. 511
		add	ax,8000		;8000 .. 8511 (588 .. 626kts)

		mov	VERY_FAST,ax

		ret

SetVeryFast	ENDP

;----------------------------------------------------------------------------

;* AAActivity - update AA activity
;*
;* pass: AircraftPtr
;* ret : nothing
;* kill: assume all

AAActivity	PROC	NEAR

		test	NoFire,1	;hostile fire inhibited?
		_JNZ	AAExit		;yes ->

		mov	si,AircraftPtr

;---------------------------------------
;* check drone aircraft is on active map
;---------------------------------------

		cmp	WORD PTR _VP_XSEC[si],31
		ja	AAExit
		cmp	WORD PTR _VP_YSEC[si],31
		ja	AAExit

;----------------------------
;* fetch sector gameplay data
;----------------------------

		mov	bp,_VP_YSEC[si]

		REPT	5
		shl	bp,1
		ENDM

		add	bp,_VP_XSEC[si]

;--------------------------------------
;* check if terratory is enemy to drone
;--------------------------------------

		mov	al,ENEMY	;assume enemy sector

		test	SctrGameLayer1[bp],SECT_ENEMY	;emeny?
		jnz	@F	       			;yes ->

		mov	al,ALLIED      	;allied

@@:		cmp	_AC_SIDE[si],al	;same side?
		je	AAExit	       	;yes ->

;--------------
;* update timer
;--------------

		mov	ax,_AC_AA_TIMER[si]
		sub	ax,LastFrame
		MINM	ax
		mov	_AC_AA_TIMER[si],ax
		jnz	AAExit

;----------------
;* check altitude 
;----------------

		cmp	WORD PTR _VP_ZFT_HI[si],0
		ja	AAOk
		cmp	WORD PTR _VP_ZFT_LO[si],10000
		ja	AAOk

;----------------
;* check for kill
;----------------

		call	RandX

		cmp	ax,(1*256)/100	;kill?
		ja	AAOk 		;no ->

;-----------
;* make kill
;-----------

		mov	si,AircraftPtr
		add	si,MOB_REC_SIZE
		call	AerialExplosion

		mov	bx,SMOKE_AIR_EXPLO
		mov	si,AircraftPtr
		add	si,MOB_REC_SIZE
		call	MakeSmokeEffect

		mov	si,AircraftPtr

	 	mov	_DRONE_SIDE[si],DEAD

		call	DeleteMobile

		jmp	AAExit

;-------------
;* reset timer
;-------------

AAOk:		call	SetAATimer

AAExit:		ret

AAActivity	ENDP

;----------------------------------------------------------------------------

;* SetAATimer - set AA activity timer
;*
;* pass: si -> MOBILE + VIEWPOINT + AIRCRAFT compound data block
;* ret : nothing
;* kill: ax, flags

SetAATimer	PROC	NEAR

		call	RandX		; 0.00 ..   2.55
		shl	ax,1		; 0.00 ..   5.10
		shl	ax,1		; 0.00 ..  10.20
		shl	ax,1		; 0.00 ..  20.40
		shl	ax,1		; 0.00 ..  40.80
		add	ax,60*100	;60.00 .. 100.80

		mov	_AC_AA_TIMER[si],ax

		ret

SetAATimer	ENDP

DRONECODE	ENDS

;============================================================================

WEAPONCODE	SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:WEAPONCODE
		ASSUME DS:DATA

;* AutoBomb - air-to-ground weapons control (only available from "track" mode)
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

AutoBomb	PROC	FAR

;-------------------
;* ensure track mode (aircraft may have just switched to another mode)
;-------------------

		cmp	AC_Data.AC_CTRL_MODE,CTRL_TRACK
		jne	ExitBomb

;----------------------------------
;* check if package to be delivered
;----------------------------------

		mov	si,AC_Data.AC_WP_PTR

		cmp	[si].WP_PACKAGE,WPACK_NULL
		je	ExitBomb

;----------------------
;* extract package data
;----------------------

		mov	al,[si].WP_PACKAGE

;* extract weapon type / delivery mode

		mov	bx,ax
		and	bx,WPACK_MODE_MASK

;* extract number of weapons

		mov	cx,ax
		and	cx,WPACK_NUM_MASK

		REPT	4
		shr	cx,1
		ENDM

;--------------------
;* sort weapon arming
;--------------------

		jmp	ArmSwitch[bx]

;---------------------------
ArmNull 	LABEL	NEAR
;---------------------------

		jmp	ExitBomb

;---------------------------
ArmGPB1000	LABEL	NEAR
;---------------------------

		mov	bx,GPB1000

		call	AutoLaydown

		jmp	ExitBomb

;---------------------------
ArmRET1000	LABEL	NEAR
;---------------------------

		mov	bx,RET1000

		call	AutoLaydown

		jmp	ExitBomb

;---------------------------
ArmLGB1000	LABEL	NEAR
;---------------------------

		call	AutoLGB

		jmp	ExitBomb

;---------------------------
ArmBL755	LABEL	NEAR
;---------------------------

		mov	bx,BL755

		call	AutoLaydown

		jmp	ExitBomb

;---------------------------
ArmJP233	LABEL	NEAR
;---------------------------

		call	AutoJP233

		jmp	ExitBomb

;---------------------------
ArmAlarm	LABEL	NEAR
;---------------------------

		call	AutoAlarm

		jmp	ExitBomb

;---------------------------
ArmAGM		LABEL	NEAR
;---------------------------

		call	AutoAGM

ExitBomb:	ret

AutoBomb	ENDP

;----------------------------------------------------------------------------

;* AutoLaydown
;*
;* pass: bx = weapon type (GPB1000, RET1000, BL755)
;*       cx = number of weapons in package
;* ret : nothing
;* kill: assume all (except cf)

AutoLaydown	PROC	NEAR

;-------------------
;* store pass params
;-------------------

		mov	WeaponType,bx
		mov	WeaponNum,cx

;-------------------
;* release interlock
;-------------------

;* check target ahead (avoid spurious release)

		mov	ax,AC_View.VP_HDG
		mov	dx,AC_WPBrg
		call	CalcAngDiff

		cmp	ax,14		;?0?
		_JA	ExitLaydown

;-------------------
;* calc weapon throw
;-------------------

		mov	ax,AC_Data.AC_VTAS
		mov	bx,WeaponType
		mov	si,OFFSET AC_View
		call	CalcThrow

;-------------------
;* check for release
;-------------------

;* release if (range - throw) <= (vtas * cos(pitch) * delta time) / 16

		mov	ax,WORD PTR AC_WPRng
		mov	dx,WORD PTR AC_WPRng+2

		sub	ax,WORD PTR BombThrow
		sbb	dx,WORD PTR BombThrow+2

		js	@F		;< 0, always release ->

		jnz	ExitLaydown	;too far ->

		mov	bp,ax

		COSINE	dx,AC_View.VP_PITCH

		mov	ax,AC_Data.AC_VTAS
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
		ja	ExitLaydown	;no ->

;-----------------
;* release package
;-----------------

@@:		mov	ax,AC_Data.AC_VTAS
		mov	bx,WeaponType
		mov	cx,WeaponNum
		mov	si,OFFSET AC_View
		mov	di,-1	  	;target waypoint not applicable

	IF	DEBUG_WEAPONS EQ 0

		xor	dl,dl	  	;drone release

	ELSE

		mov	dl,1		;debug release

	ENDIF

		call	ReleasePackage

;* clear package (assume package released)

		mov	si,AC_Data.AC_WP_PTR
		mov	[si].WP_PACKAGE,WPACK_NULL

;* inhibit aircraft route change until weapons are clear

		mov	AC_Data.AC_ARM_LOCK,WPN_CLR_DELAY

ExitLaydown:	ret

AutoLaydown	ENDP

;----------------------------------------------------------------------------

;* AutoLGB
;*
;* pass: cx = number of weapons in package
;* ret : nothing
;* kill: assume all (except cf)

AutoLGB		PROC	NEAR

;-------------------
;* store pass params
;-------------------

		mov	WeaponNum,cx

;-------------------------------
;* check for release in progress
;-------------------------------

		cmp	AC_Data.AC_ARM_LOCK,0
		ja	ContLGB

;-------------------
;* release interlock
;-------------------

;* check target ahead (avoid spurious release)

		mov	ax,AC_View.VP_HDG
		mov	dx,AC_WPBrg
		call	CalcAngDiff

		cmp	ax,14		;?0?
		ja	ExitLGB

;-------------------
;* check for release
;-------------------

;* release if range <= zft / 2

		mov	ax,WORD PTR AC_View.VP_ZFT_LO
		mov	dx,WORD PTR AC_View.VP_ZFT_HI

		shr	dx,1
		rcr	ax,1

		cmp	WORD PTR AC_WPRng+2,dx
		ja	ExitLGB
		jb	LGBOk
		cmp	WORD PTR AC_WPRng,ax
		ja	ExitLGB
		jmp	LGBOk

;--------------------------
;* continue package release
;--------------------------

;* update delivery timer

ContLGB:    	mov	ax,AC_Data.AC_ARM_LOCK
		sub	ax,LastFrame
		MINM	ax
		mov	AC_Data.AC_ARM_LOCK,ax

		jnz	ExitLGB

;* release single weapon

LGBOk:		mov	ax,AC_Data.AC_VTAS
		mov	bx,LGB1000
		mov	cx,1
		xor	dl,dl
		mov	si,OFFSET AC_View
		mov	di,AC_Data.AC_WP_PTR

		call	ReleasePackage

;* update package count (assume weapon released)

		mov	ax,WeaponNum
		dec	ax
		jnz	@F

;* clear package (last weapon released)

		mov	si,AC_Data.AC_WP_PTR
		mov	[si].WP_PACKAGE,WPACK_NULL

;* inhibit aircraft route change until weapons are clear

		mov	AC_Data.AC_ARM_LOCK,WPN_CLR_DELAY

		jmp	ExitLGB

;* update number of weapons remaining in package

@@:		REPT	4
		shl	al,1
		ENDM

		and	al,WPACK_NUM_MASK

		mov	si,AC_Data.AC_WP_PTR

		and	[si].WP_PACKAGE,WPACK_MODE_MASK

		or	[si].WP_PACKAGE,al

;* inhibit aircraft route change during LGB delivery

		mov	AC_Data.AC_ARM_LOCK,LGB_DELAY

ExitLGB:	ret

AutoLGB		ENDP

;----------------------------------------------------------------------------

;* AutoJP233
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all (except cf)

AutoJP233	PROC	NEAR

;-------------------------------
;* check for release in progress
;-------------------------------

		cmp	AC_Data.AC_ARM_LOCK,0
		ja	ContJP233

;-------------------
;* release interlock
;-------------------

;* check target ahead (avoid spurious release)

		mov	ax,AC_View.VP_HDG
		mov	dx,AC_WPBrg
		call	CalcAngDiff

		cmp	ax,14		;?0?
		_JA	ExitJP233

;-------------------
;* calc weapon throw
;-------------------

		mov	ax,AC_Data.AC_VTAS
		mov	bx,JP233
		mov	si,OFFSET AC_View
		call	CalcThrow

;-------------------
;* check for release
;-------------------

;* release if (range - throw) <= (vtas * cos(pitch) * delta time) / 16

		mov	ax,WORD PTR AC_WPRng
		mov	dx,WORD PTR AC_WPRng+2

		sub	ax,WORD PTR BombThrow
		sbb	dx,WORD PTR BombThrow+2

		js	@F		;< 0, always release ->

		_JNZ	ExitJP233	;too far ->

		mov	bp,ax

		COSINE	dx,AC_View.VP_PITCH

		mov	ax,AC_Data.AC_VTAS
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
		ja	ExitJP233	;no ->

;-----------------------
;* start package release
;-----------------------

;* inhibit aircraft route change during JP233 delivery

@@:		mov	AC_Data.AC_ARM_LOCK,JP233_PERIOD

;--------------------------
;* continue package release
;--------------------------

;* update delivery timer

ContJP233:    	mov	ax,AC_Data.AC_ARM_LOCK
		sub	ax,LastFrame
		MINM	ax
		mov	AC_Data.AC_ARM_LOCK,ax

		jnz	@F

;* clear package

		mov	si,AC_Data.AC_WP_PTR
		mov	[si].WP_PACKAGE,WPACK_NULL

;* inhibit aircraft route change until weapons are clear

		mov	AC_Data.AC_ARM_LOCK,WPN_CLR_DELAY

		jmp	ExitJP233

;* num bomblets this frame = min(JP233_BOMBLETS * delta time, 1)

@@:		mov	ax,JP233_BOMBLETS
		mov	dx,DeltaTime
		imul	dx
		FRACADJ	cx

		test	cx,cx		;any bomblets?
		jnz	@F		;yes ->

		inc	cx

@@:		mov	ax,AC_Data.AC_VTAS
		mov	bx,JP233
		mov	si,OFFSET AC_View
		mov	di,-1	  	;target waypoint not applicable

	IF	DEBUG_WEAPONS EQ 0

		xor	dl,dl	  	;drone release

	ELSE

		mov	dl,1		;debug release

	ENDIF

;* release bomblets (assume released ok)

		call	ReleasePackage

ExitJP233:	ret

AutoJP233	ENDP

;----------------------------------------------------------------------------

;* AutoAlarm
;*
;* pass: cx = number of weapons in package
;* ret : nothing
;* kill: assume all (except cf)

AutoAlarm	PROC	NEAR

;-------------------
;* store pass params
;-------------------

		mov	WeaponNum,cx

;-------------------------------
;* check for release in progress
;-------------------------------

		cmp	AC_Data.AC_ARM_LOCK,0
		ja	ContAlarm

;-------------------
;* release interlock
;-------------------

;* check target ahead (avoid spurious release)

		mov	ax,AC_View.VP_HDG
		mov	dx,AC_WPBrg
		call	CalcAngDiff

		cmp	ax,14		;?0?
		_JA	ExitAlarm

;-------------------
;* check for release
;-------------------

;* release if range <= 10nm (60760ft)

		cmp	WORD PTR AC_WPRng+2,0
		_JA	ExitAlarm
		cmp	WORD PTR AC_WPRng,10*6076
		_JA	ExitAlarm

		jmp	AlarmOk

;--------------------------
;* continue package release
;--------------------------

;* update delivery timer

ContAlarm:    	mov	ax,AC_Data.AC_ARM_LOCK
		sub	ax,LastFrame
		MINM	ax
		mov	AC_Data.AC_ARM_LOCK,ax

		_JNZ	ExitAlarm

;* sort target viewpoint

AlarmOk:	mov	si,AC_Data.AC_WP_PTR

		mov	ax,[si].WP_XSEC
		mov	TMP_VIEW.VP_XSEC,ax

		mov	ax,[si].WP_YSEC
		mov	TMP_VIEW.VP_YSEC,ax

		mov	ax,[si].WP_XFT
		mov	TMP_VIEW.VP_XFT,ax

		mov	ax,[si].WP_YFT
		mov	TMP_VIEW.VP_YFT,ax

		xor	ax,ax

		mov	WORD PTR TMP_VIEW.VP_ZFT_LO,ax
		mov	WORD PTR TMP_VIEW.VP_ZFT_HI,ax

;* add random offset to viewpoint (unless last weapon in package)

		cmp	WeaponNum,1
		je	@F

		call	RandX
		xchg	al,ah
		REPT	2
		sar	ax,1		;-8192 .. 8191
		ENDM
		mov	cx,ax		;x offset

		call	RandX
		xchg	al,ah
		REPT	2
		sar	ax,1		;-8192 .. 8191
		ENDM
		mov	bx,ax		;y offset

		MOVEXY	TMP_VIEW,cx,bx

;* launch single weapon

@@:		mov	ax,AC_Data.AC_VTAS

		mov	dh,1		;indirect mode

		mov	si,OFFSET AC_View
		mov	di,OFFSET TMP_VIEW

	IF	DEBUG_WEAPONS EQ 0

		xor	dl,dl	  	;drone release

	ELSE

		mov	dl,1		;debug release

	ENDIF

		call	LaunchAlarm

;* update package count (assume weapon launched)

		mov	ax,WeaponNum
		dec	ax
		jnz	@F

;* clear package (last weapon launched)

		mov	si,AC_Data.AC_WP_PTR
		mov	[si].WP_PACKAGE,WPACK_NULL

;* inhibit aircraft route change until weapons are clear

		mov	AC_Data.AC_ARM_LOCK,WPN_CLR_DELAY

		jmp	ExitAlarm

;* update number of weapons remaining in package

@@:		REPT	4
		shl	al,1
		ENDM

		and	al,WPACK_NUM_MASK

		mov	si,AC_Data.AC_WP_PTR

		and	[si].WP_PACKAGE,WPACK_MODE_MASK

		or	[si].WP_PACKAGE,al

;* inhibit aircraft route change during ALARM delivery

		mov	AC_Data.AC_ARM_LOCK,ALARM_DELAY

ExitAlarm:	ret

AutoAlarm	ENDP

;----------------------------------------------------------------------------

;* AutoAGM (air-to-ground missile)
;*
;* pass: cx = number of weapons in package
;* ret : nothing
;* kill: assume all (except cf)
;*
;* note: Air-to-ground missiles are essentially the ALARM missile used in
;*       direct mode. They are used at a fairly short range so that they
;*       never go into "loiter" mode. These weapons are mainly required as
;*       an ALARM equivalent for enemy drone aircraft but they could be used
;*       against many targets (check weapon effectiveness against target
;*       hardness).

AutoAGM		PROC	NEAR

;-------------------
;* store pass params
;-------------------

		mov	WeaponNum,cx

;-------------------------------
;* check for release in progress
;-------------------------------

		cmp	AC_Data.AC_ARM_LOCK,0
		ja	ContAGM

;-------------------
;* release interlock
;-------------------

;* check target ahead (avoid spurious release)

		mov	ax,AC_View.VP_HDG
		mov	dx,AC_WPBrg
		call	CalcAngDiff

		cmp	ax,14		;?0?
		_JA	ExitAGM

;-------------------
;* check for release
;-------------------

;* release if range <= 8nm (48608ft)

		cmp	WORD PTR AC_WPRng+2,0
		_JA	ExitAGM
		cmp	WORD PTR AC_WPRng,8*6076
		_JA	ExitAGM

		jmp	AGMOk

;--------------------------
;* continue package release
;--------------------------

;* update delivery timer

ContAGM:    	mov	ax,AC_Data.AC_ARM_LOCK
		sub	ax,LastFrame
		MINM	ax
		mov	AC_Data.AC_ARM_LOCK,ax

		_JNZ	ExitAGM

;* sort target viewpoint

AGMOk:		mov	si,AC_Data.AC_WP_PTR

		mov	ax,[si].WP_XSEC
		mov	TMP_VIEW.VP_XSEC,ax

		mov	ax,[si].WP_YSEC
		mov	TMP_VIEW.VP_YSEC,ax

		mov	ax,[si].WP_XFT
		mov	TMP_VIEW.VP_XFT,ax

		mov	ax,[si].WP_YFT
		mov	TMP_VIEW.VP_YFT,ax

		xor	ax,ax

		mov	WORD PTR TMP_VIEW.VP_ZFT_LO,ax
		mov	WORD PTR TMP_VIEW.VP_ZFT_HI,ax

;* add random offset to viewpoint (unless last weapon in package)

		cmp	WeaponNum,1
		je	@F

		call	RandX
		cbw			;-128 .. 127
		mov	cx,ax		;x offset

		call	RandX
		cbw			;-128 .. 127
		mov	bx,ax		;y offset

		MOVEXY	TMP_VIEW,cx,bx

;* launch single weapon

@@:		mov	ax,AC_Data.AC_VTAS

		mov	dh,0		;direct mode

		mov	si,OFFSET AC_View
		mov	di,OFFSET TMP_VIEW

	IF	DEBUG_WEAPONS EQ 0

		xor	dl,dl	  	;drone release

	ELSE

		mov	dl,1		;debug release

	ENDIF

		call	LaunchAlarm

;* update package count (assume weapon launched)

		mov	ax,WeaponNum
		dec	ax
		jnz	@F

;* clear package (last weapon launched)

		mov	si,AC_Data.AC_WP_PTR
		mov	[si].WP_PACKAGE,WPACK_NULL

;* inhibit aircraft route change until weapons are clear

		mov	AC_Data.AC_ARM_LOCK,WPN_CLR_DELAY

		jmp	ExitAGM

;* update number of weapons remaining in package

@@:		REPT	4
		shl	al,1
		ENDM

		and	al,WPACK_NUM_MASK

		mov	si,AC_Data.AC_WP_PTR

		and	[si].WP_PACKAGE,WPACK_MODE_MASK

		or	[si].WP_PACKAGE,al

;* inhibit aircraft route change during AGM delivery

		mov	AC_Data.AC_ARM_LOCK,AGM_DELAY

ExitAGM:	ret

AutoAGM	ENDP

;----------------------------------------------------------------------------

;* AutoCannon - fire cannon
;*
;* pass: nothing
;* ret : cf = 0: weapon created
;*       cf = 1: weapon not created (no weapon available)
;* kill: assume all (except cf)

AutoCannon	PROC	FAR

		mov	ax,AC_Data.AC_VTAS
		xor	dl,dl
		mov	dh,RHS_CANNON
		mov	si,OFFSET AC_View
		mov	di,OFFSET AC_Mobile
		call	FireCannon

		ret

AutoCannon	ENDP

;----------------------------------------------------------------------------

;* AutoMissile
;*
;* pass: nothing
;* ret : cf = 0: weapon created
;*       cf = 1: weapon not created (no weapon available)
;* kill: assume all (except cf)

AutoMissile	PROC	FAR

;* sort Sidewinder / Sky Flash wrt range

		mov	bx,SKYFLASH

		cmp	WORD PTR SlantRng+2,0
		ja	@F
		cmp	WORD PTR SlantRng,20000
		ja	@F

;* check IR lock for Sidewinder

		mov	si,OFFSET AC_View
		mov	di,AC_Data.AC_OPP_PTR
		add	di,MOB_REC_SIZE
		call	CheckIRLock
		jnc	@F

		mov	bx,SIDEWINDER

@@:		mov	ax,AC_Data.AC_VTAS
		xor	dl,dl
		mov	si,OFFSET AC_View
		mov	di,AC_Data.AC_OPP_PTR
		call	LaunchMissile

		ret

AutoMissile	ENDP

;----------------------------------------------------------------------------

;* EvasionTactics - chaff / flare if weapon lock
;*
;* pass: AircraftPtr
;* ret : nothing
;* kill: assume all

EvasionTactics	PROC	FAR

		mov	si,AircraftPtr

;---------------------------
;* clear chaff / flare flags
;---------------------------

		and	_AC_FLAGS[si],NOT (AFLG_REL_CHAFF+AFLG_REL_FLARE)

;----------------------
;* test for weapon lock
;----------------------

		test	_AC_FLAGS[si],AFLG_IR_LOCK+AFLG_RAD_LOCK
		jz	SkipEvasion

;----------------
;* check airborne
;----------------

		mov	ax,WORD PTR _VP_ZFT_LO[si]
		or	ax,WORD PTR _VP_ZFT_HI[si]
		jz	SkipEvasion

;----------------------------
;* update decoy release timer
;----------------------------

		mov	ax,_AC_DECOY_TIMER[si]
		sub	ax,LastFrame
		jnc	SetDecoyTimer

;---------------
;* release decoy
;---------------

;* release chaff (if required)

		test	_AC_FLAGS[si],AFLG_RAD_LOCK
		jz	@F

		push	si

		mov	ax,_AC_VTAS[si]
		mov	bx,CHAFF
		xor	dl,dl
		add	si,MOB_REC_SIZE		;si -> viewpoint
		call	ReleaseDecoy

		pop	si

		or	_AC_FLAGS[si],AFLG_REL_CHAFF

;* release flare (if required)

@@:		test	_AC_FLAGS[si],AFLG_IR_LOCK
		jz	@F

		push	si

		mov	ax,_AC_VTAS[si]
		mov	bx,FLARE
		xor	dl,dl
		add	si,MOB_REC_SIZE		;si -> viewpoint
		call	ReleaseDecoy

		pop	si

		or	_AC_FLAGS[si],AFLG_REL_FLARE

;* reset decoy release timer

@@:		call	RandX		;0.00 .. 2.55
		shr	ax,1		;0.00 .. 1.27
		add	ax,150		;1.50 .. 2.77

SetDecoyTimer:	mov	_AC_DECOY_TIMER[si],ax

;------------------
;* clear lock flags
;------------------

SkipEvasion:	and	_AC_FLAGS[si],NOT (AFLG_IR_LOCK+AFLG_RAD_LOCK)

		ret

EvasionTactics	ENDP

WEAPONCODE 	ENDS

;============================================================================

		END

