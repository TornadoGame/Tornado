;****************************************************************************
;*
;* MAINDATA.INC
;*
;* 10.12.1991 - KJB
;*
;****************************************************************************

;---------------
;* Tornado types
;---------------

IDS_TORNADO	EQU	0		;interdictor strike
ADV_TORNADO	EQU	2		;air defence variant
ECR_TORNADO	EQU	4		;electronic combat and reconnaissance

;-----------------
;* control devices
;-----------------

CTRL_DEV_KBD1	EQU	0		;keyboard (self centring)
CTRL_DEV_KBD2	EQU	2		;keyboard
CTRL_DEV_JOY1	EQU	4		;single joystick
CTRL_DEV_JOY2	EQU	6		;dual joysticks

;-------------
;* sound cards
;-------------

SND_NULL	EQU	0		;no sound card
SND_SPEAKER	EQU	2		;internal speaker
SND_SBLASTER	EQU	4		;SoundBlaster
SND_ADLIB	EQU	6		;AdLib
SND_ROLAND	EQU	8		;Roland LAPC1

;-------------------
;* shake effect flag
;-------------------

SHAKE_OPT_OFF	EQU	0		;shake effects off
SHAKE_OPT_ON	EQU	1		;shake effects on


;-------------
;* sound flags
;-------------

SOUND_OPT_OFF	EQU	0		;sound off
SOUND_OPT_ON	EQU	1		;sound on (less engine sound)
SOUND_OPT_ENG	EQU	2		;sound on (with engine sound)

;------------
;* view modes
;------------

VIEW_PILOT	EQU	0 		;pilot's panel view
VIEW_LPILOT	EQU	2		;pilot's left view
VIEW_RPILOT	EQU	4		;pilot's right view
VIEW_NAVIG	EQU	6		;navigator's panel view
VIEW_LNAVIG	EQU	8		;navigator's left view
VIEW_RNAVIG	EQU	10		;navigator's right view
VIEW_TRACKING	EQU	12		;tracking camera
VIEW_SATELLITE	EQU	14		;satellite camera
VIEW_MAP	EQU	16		;map view
VIEW_DRONE	EQU	18		;drone view
VIEW_SPECTATOR	EQU	20		;spectator view
VIEW_REMOTE	EQU	22		;remote view
VIEW_LOOKDOWN	EQU	24		;pilot's look down
VIEW_LOOKUP	EQU	26		;pilot's look up
VIEW_DEMO	EQU	28		;demo view
VIEW_DESTROYED	EQU	30		;Tornado destroyed view
VIEW_WEAPON	EQU	32		;weapon view
VIEW_ZRK EQU 34         ;ZRK ROMB (SA-8) to Tornado view
VIEW_ZSU1 EQU 36         ;ZSU-23-4 Shilka to Tornado view1
VIEW_ZSU2 EQU 38         ;ZSU-23-4 Shilka to Tornado view2
VIEW_ZRK_AAA EQU 40         ;ZSU-23-4 Shilka to Tornado view2

;-------------
;* panel modes
;-------------

PILOTPAN	EQU	0   	;pilot's front panel
PSIDEPAN	EQU	2		;pilot's left and right side panel
NAVIGPAN	EQU	4		;navigator's front panel
NSIDEPAN	EQU	6		;navigator's left and right side panel
EXTRNPAN	EQU	8		;external panel
LOOKDOWN	EQU	10		;look down panel
LOOKUP		EQU	12		;look up panel
MAPPAN		EQU	14		;map panel

;-----------
;* crew mode
;-----------

CREW_PILOT	EQU	0		;pilot in control
CREW_NAVIG	EQU	2		;navigator in control

;------------------
;* auto-pilot modes
;------------------

AUTO_OFF	EQU	0		;off (manual)
AUTO_APPROACH	EQU	2		;approach (autoland)
AUTO_TRACK	EQU	4		;track acquire (fly to next waypoint)
AUTO_HOLD	EQU	6		;altitude and heading hold
AUTO_TF		EQU	8		;terrain follow

;--------------------------
;* altitude authority modes
;--------------------------

ALT_MANUAL	EQU	0
ALT_APPROACH	EQU	2
ALT_ACQUIRE	EQU	4
ALT_TF		EQU	6

;-------------------------
;* heading authority modes
;-------------------------

HDG_MANUAL	EQU	0
HDG_APPROACH	EQU	2
HDG_ACQUIRE	EQU	4
HDG_TRACK	EQU	6

;-----------------
;* jettison levels
;-----------------

JET_NULL	EQU	0		;nothing
JET_EXT_TANKS	EQU	1		;ext fuel tanks
JET_EXT_STORES	EQU	2		;ext fuel tanks + ext stores
JET_ALL		EQU	3		;ext fuel tanks + ext stores + int fuel

;------------------------
;* end of game conditions (DieFlag = 0 .. 127)
;------------------------

DIE_QUIT	EQU	1		;quit game
DIE_HYPOXIA	EQU	2		;lack of oxygen		
DIE_BREAK_UP	EQU	3		;break up due to buffeting
DIE_CRASH_HILL	EQU	4		;crashed into hill
DIE_CRASH_GND	EQU	5		;crashed into ground
DIE_DITCHED	EQU	6		;ditched
DIE_GND_SPD_HI	EQU	7		;crashed - ground speed too high
DIE_SINK_HI	EQU	8		;crashed - sink rate too high
DIE_ROLL_HI	EQU	9		;crashed - roll too high on landing
DIE_NOSE_WHEEL	EQU	10		;crashed - nose wheel collapsed
DIE_TAIL_SCRAPE	EQU	11		;crashed - tail scrape on landing
DIE_COLLAPSE	EQU	12		;crashed - gear collapsed
DIE_FIRE	EQU	13		;destroyed by fire
DIE_EJECT	EQU	14		;ejected
DIE_MISSILE	EQU	15		;shot down by air-to-air missile
DIE_CANNON	EQU	16		;shot down by cannon fire
DIE_SAM		EQU	17		;shot down by surface-to-air missile
DIE_AAA		EQU	18		;shot down by anti-aircraft artillery
DIE_GND_EXPLO	EQU	19		;destroyed by ground explosion
DIE_AIR_EXPLO	EQU	20		;destroyed by air explosion
DIE_HIT_GND_OBJ	EQU	21		;crashed into ground object
DIE_HIT_MOB_OBJ	EQU	22		;crashed into mobile object
DIE_2_PLYR_WIN	EQU	23		;two player win
DIE_2_PLYR_DRAW	EQU	24		;two player draw
DIE_2_PLYR_LOSE	EQU	25		;two player lose

;---------------
;* system errors (DieFlag = 128 .. 255)
;---------------

SYS_ERR_MOUSE	EQU	255		;mouse driver not present
SYS_ERR_PANELS	EQU	254		;error occurred loading panel data
SYS_ERR_RGB	EQU	253		;error occurred loading palette RGB data
SYS_ERR_LD_GAME	EQU	252		;error occurred loading GAMEPLAY.IN
SYS_ERR_SV_GAME	EQU	251		;error occurred saving GAMEPLAY.OUT
SYS_ERR_LD_LYR	EQU	250		;error occurred loading LAYER.IN
SYS_ERR_LD_OBJ	EQU	249		;error occurred loading OBSECDEF.IN
SYS_ERR_SV_OBJ	EQU	248		;error occurred saving OBSECDEF.OUT
SYS_ERR_LD_MOB	EQU	247		;error occurred loading MSECDEF.IN
SYS_ERR_SV_MOB	EQU	246		;error occurred saving MSECDEF.OUT
SYS_ERR_MAP_OK	EQU	245		;completed map test ok
SYS_ERR_RESIZE	EQU	244		;error occurred resizing memory
SYS_ERR_SMEM	EQU	243		;error occurred allocating memory for sound driver
SYS_ERR_SDRVR	EQU	242		;error occurred loading sound driver
SYS_ERR_SCARD	EQU	241		;sound card not present
SYS_ERR_LD_PIC	EQU	240		;error occurred loading digitized picture file
SYS_ERR_LD_PREV	EQU	239		;error occurred loading PREVIEW.BT2
SYS_ERR_SV_IMP	EQU	238		;error occurred saving IMPACT.OUT
SYS_ERR_LD_MISC	EQU	237		;error occurred loading MISCDATA.IN 
SYS_ERR_TIMEOUT	EQU	236		;global timeout (end of demo)
SYS_ERR_SYNC_TO	EQU	235		;comms sync timeout / user abort
SYS_ERR_MMEM	EQU	234		;error occurred allocating memory for music driver
SYS_ERR_MDRVR	EQU	233		;error occurred loading music driver
SYS_ERR_MCARD	EQU	232		;music card not present

;---------------------
;* disable input flags
;---------------------

DIP_GLOC	EQU	00000001b	;blackout / redout
DIP_HYPOXIA	EQU	00000010b	;lack of oxygen
DIP_EJECT	EQU	00000100b	;eject
DIP_DESTROYED	EQU	00001000b	;aircraft destroyed
DIP_DEMO	EQU	10000000b	;demo mode

;---------------------
;* waypoint data block (see MAINDATA.ASM for more documentation)
;---------------------

WAYPOINT	STRUCT	2

WP_ID		DB	"?"		;identifier "A", "B", "X", "Y" etc.
WP_ATTR		DB	0		;attributes (see below)
WP_XSEC		DW	0		;0 .. 31 (on map)
WP_YSEC		DW	0		;0 .. 31 (on map)
WP_XFT		DW	0
WP_YFT		DW	0
WP_ZFT		DW	0		;WP_TF = 0: waypoint altitude
					;WP_TF = 1: terrain following altitude
WP_TIME		DW	0		;WP_COORD = 0: route leg speed (ft/sec * 8)
					;WP_COORD = 1: planned arrival time (secs since start)
WP_ACTION	DB	0		;action to perform at waypoint
WP_PACKAGE	DB	0		;weapons package to deliver at waypoint
					;   b3 .. b0: weapon / delivery mode
					;   b7 .. b4: num weapons in package

WAYPOINT	ENDS

WAY_REC_SIZE	EQU	TYPE WAYPOINT

WP_SPEED	EQU	WP_TIME		;time / speed share same location

;* attributes

WP_TYPE		EQU	00000001b	;1 = target (fly over waypoint)
					;0 = turning point (turn early)
WP_LINK		EQU	00000010b	;1 = link back to waypoint (where WP_HERE = 1)
					;0 = continue to next waypoint
WP_HERE		EQU	00000100b	;1 = link back to here label
					;0 = no label
WP_TF		EQU	00001000b	;1 = terrain follow to waypoint
					;0 = acquire waypoint altitude
WP_ILS		EQU	00010000b	;1 = fly ILS glide slope to waypoint (WP_TYPE = 1)
					;0 = acquire waypoint altitude
WP_COORD	EQU	00100000b	;1 = calc speed to arrive at specified time
					;0 = set fixed speed
WP_BREAK	EQU	01000000b	;1 = break to here to land label (WP_TYPE = 1)
					;0 = no label
WP_VALID	EQU	10000000b	;1 = waypoint valid
					;0 = waypoint not in use

NUM_WP_LONG	EQU	16		;number of waypoints for long route

NUM_WP_SHORT	EQU	9		;number of waypoints for short route

;* waypoint route end marker

ENDROUTE	STRUCT	2

		DB	"?"		;identifier
		DB	0		;attributes

ENDROUTE	ENDS

;-----------------------------
;* weapons packages for drones
;-----------------------------

WPACK_MODE_MASK	EQU	00001111b
WPACK_NUM_MASK	EQU	11110000b

WPACK_NULL	EQU	0		;no package
WPACK_GPB1000	EQU	2		;GPB1000 (laydown)
WPACK_RET1000	EQU	4		;RET1000 (laydown)
WPACK_LGB1000	EQU	6		;LGB1000 (laser guided)
WPACK_BL755	EQU	8		;BL755 (laydown)
WPACK_JP233	EQU	10		;JP233 (laydown)
WPACK_ALARM	EQU	12		;ALARM (indirect)
WPACK_AGM	EQU	14		;AGM (ALARM direct)

;-------------
;* radar modes
;-------------

NUL_RADAR	EQU	0
GND_RADAR	EQU	2
AIR_RADAR	EQU	4

;---------------------
;* airfield data block
;---------------------

AIRFIELD	STRUCT	2

;* data to be passed from mission planning

AF_XSEC		DW	-1		;xsec (-1 = record not in use)
AF_YSEC		DW	-1		;ysec (-1 = record not in use)
AF_STATUS	DB	0		;0 = green, 1 = amber, 2 = red
AF_ILS_STATUS	DB	0		;ILS status flags (see RWY_TAXI.INC)

;* data to be initialized at run time

AF_RNG		DW	0		;range (nautical miles * 10)
AF_BRG		DW	0		;bearing (pdegs)
AF_ETA		DW	0		;time (seconds)
AF_RNG_LO	DW	0		;range (ft)
AF_RNG_HI	DW	0		;range (ft)
AF_ILS_PTR	DW	-1		;ptr to ILS data block

AIRFIELD	ENDS

AF_REC_SIZE	EQU	TYPE AIRFIELD

NUM_AIRFIELDS	EQU	4

;-----------------------
;* dead / allied / enemy
;-----------------------

DEAD		EQU	0
ALLIED		EQU	1
ENEMY		EQU	2

;-------------
;* drone types
;-------------

DRONE_UNKNOWN	EQU	0	
DRONE_AIRCRAFT	EQU	2
DRONE_HELICOPT	EQU	4
DRONE_TRUCK	EQU	6
DRONE_TRAIN	EQU	8

;---------------------------
;* standard drone data block
;---------------------------

DRONE_DATA	STRUCT	2

DRONE_TYPE	DW	DRONE_UNKNOWN	;type
DRONE_SIDE	DB	DEAD		;side
DRONE_EVENT	DB	0		;event counter

DRONE_DATA	ENDS

NUM_DRONES	EQU	90

;-------------------------------------------------------------
;* offsets to reach DRONE in compound mobile object data block
;-------------------------------------------------------------

_DRONE_TYPE	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+DRONE_TYPE
_DRONE_SIDE	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+DRONE_SIDE
_DRONE_EVENT	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+DRONE_EVENT

;--------------------
;* vehicle data block
;--------------------

VEHICLE		STRUCT	2

;* standard drone data (matches DRONE_DATA)

VEH_DRONE	DW	DRONE_UNKNOWN	;drone type
VEH_SIDE	DB	DEAD		;side
VEH_EVENT	DB	0		;event counter

;* custom data

VEH_NODE_PTR	DW	-1		;route node ptr
VEH_DIST	DW	0		;distance to next node
VEH_DIST_FINE	DW	0
VEH_XFINE	DW	0		;xft fine
VEH_YFINE	DW	0		;yft fine
VEH_ZFINE	DW	0		;zft fine

VEHICLE		ENDS

VEH_REC_SIZE	EQU	TYPE VEHICLE

NEXT_VEHICLE	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+VEH_REC_SIZE

;---------------------------------------------------------------
;* offsets to reach VEHICLE in compound mobile object data block
;---------------------------------------------------------------

_VEH_DRONE	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+VEH_DRONE
_VEH_SIDE	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+VEH_SIDE
_VEH_EVENT	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+VEH_EVENT
_VEH_NODE_PTR	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+VEH_NODE_PTR
_VEH_DIST	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+VEH_DIST
_VEH_DIST_FINE	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+VEH_DIST_FINE
_VEH_XFINE	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+VEH_XFINE
_VEH_YFINE	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+VEH_YFINE
_VEH_ZFINE	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+VEH_ZFINE

;---------------------------------
;* truck / train convoy data block
;---------------------------------

CONVOY		STRUCT	2

;* data to be passed from mission planning

CNVY_ACTIVE	DB	0		;1 = convoy active, 0 = inactive
CNVY_DELAY	DW	0		;initial delay (1/100ths sec)

;* data to be initialized at run time

CNVY_SPEED	DW	0		;current speed (ft/sec)
CNVY_AIM_SPEED	DW	0		;aiming speed (ft/sec)
CNVY_DRONE	DB	0		;drone to trigger event
CNVY_EVENT	DB	-1		;event number (-1 = no event)

CONVOY		ENDS

CNVY_REC_SIZE	EQU	TYPE CONVOY

TRUCK		EQU	0
TRAIN		EQU	2

NUM_TRUCKS	EQU	4
NUM_TRAINS	EQU	8

;-----------------------------------
;* road / rail route node data block
;-----------------------------------

ROUTE_NODE	STRUCT	2

ROUTE_XSEC	DB	0		;xsec (0 .. 31)
ROUTE_YSEC	DB	0		;ysec (0 .. 31)
ROUTE_XFT	DW	0		;xft
ROUTE_YFT	DW	0		;yft
ROUTE_DIST	DW	0		;distance to next node (ft)
ROUTE_DIR	DW	0		;direction of next node (pdegs)
ROUTE_ATTR	DB	0		;node attributes
ROUTE_SPEED	DB	0		;speed (ft/sec) (127 max = 87mph)
ROUTE_DRONE	DB	0		;drone to trigger event
ROUTE_EVENT	DB	-1		;event number (-1 = no event)

ROUTE_NODE	ENDS

ROUTE_REC_SIZE	EQU	TYPE ROUTE_NODE

NUM_ROUTE_NODES	EQU	32		;num route nodes per route

;------------
;* attributes
;------------

RN_END		EQU	00000001b	;end of route (terminate here)

RN_LINK		EQU	00000010b	;link back to first node
					;(continuous loop)

RN_EVENT	EQU	00000100b	;stop here and wait for event

RN_DELAY	EQU	00001000b	;stop here and wait for delay period
					;(do not set for initial delay)

RN_UPSLOPE	EQU	00010000b	;start bridge ramp ascent here

RN_DNSLOPE	EQU	00100000b	;start bridge ramp descent here

;--------------------------
;* 24 hour clock data block
;--------------------------

CLOCK		STRUCT

CLK_HRS		DB	0		;hours (0 .. 23)
CLK_MINS	DB	0		;mins (0 .. 59)
CLK_SECS 	DB	0		;secs (0 .. 59)
CLK_100THS	DB	0		;1/100ths sec (0 .. 99)

CLOCK		ENDS

;----------------------
;* red / amber warnings
;----------------------

RED_OXY		EQU	0000000000000001b	;oxygen system pressure low
RED_L_FIRE	EQU	0000000000000010b	;left engine fire
RED_R_FIRE	EQU	0000000000000100b	;right engine fire
RED_AUT		EQU	0000000000001000b	;auto-pilot disengage
RED_REV		EQU	0000000000010000b	;thrust reversers failure
RED_SPILS	EQU	0000000000100000b	;SPILS failure
RED_UC		EQU	0000000001000000b	;gear damaged (IAS > 350kts)
RED_FUEL	EQU	0000000010000000b	;fuel low
RED_L_ENG	EQU	0000000100000000b	;left engine failure
RED_R_ENG	EQU	0000001000000000b	;right engine failure

;* red warnings which are not permanent

RED_CANCEL	EQU	NOT(RED_AUT)

AMB_CNFG	EQU	0000000000000001b	;config error
AMB_ADC		EQU	0000000000000010b	;air data computer failure
AMB_ECM		EQU	0000000000000100b	;ECM failure
AMB_UC		EQU	0000000000001000b	;gear warning (IAS > 250kts)
AMB_WB		EQU	0000000000010000b	;wheelbrakes failure
AMB_AB		EQU	0000000000100000b	;airbrakes failure
AMB_FLPS	EQU	0000000001000000b	;flaps failure
AMB_SWP		EQU	0000000010000000b	;sweep failure
AMB_HUD		EQU	0000000100000000b	;HUD failure
AMB_MFD1	EQU	0000001000000000b	;pilot's MFD failure
AMB_MFD2	EQU	0000010000000000b	;navig's MFD failure
AMB_L_TAB	EQU	0000100000000000b	;lh TAB failure
AMB_R_TAB	EQU	0001000000000000b	;rh TAB failure
AMB_RAD		EQU	0010000000000000b	;radar failure
AMB_RWR		EQU	0100000000000000b	;RWR failure

;* amber warnings which are not permanent

AMB_CANCEL	EQU	NOT(AMB_CNFG+AMB_UC)

;---------------------
;* aircraft data block
;---------------------

AIRCRAFT	STRUCT	2

;* standard drone data (matches DRONE_DATA)

AC_DRONE	DW	DRONE_UNKNOWN	;drone type
AC_SIDE     	DB	DEAD		;side
AC_EVENT	DB	0		;event counter

;* custom data

AC_TYPE     	DW	0		;aircraft type
AC_DELAY	DW	0    		;initial delay (1/100ths sec)
AC_DRONE_NUM	DB	0		;drone to trigger event
AC_EVENT_NUM	DB	-1		;event number (-1 = no event)
AC_CTRL_MODE	DW	0		;control mode (see AIRCRAFT.ASM)
AC_WP_PTR	DW	-1		;waypoint ptr
AC_XFINE	DW	0		;xft fine
AC_YFINE	DW	0		;yft fine
AC_ZFINE	DW	0		;zft fine
AC_HFINE	DW	0		;heading fine (fine pdegs)
AC_PFINE	DW	0		;pitch fine (fine pdegs)
AC_RFINE	DW	0		;roll fine (fine pdegs)
AC_VTAS     	DW	0		;true airspeed ( * 8)
AC_VTAS_FINE	DW	0		;true airspeed fine
AC_LIFT_VCTR	DW	0		;lift vector (fine pdegs)
AC_AB_DELAY	DB	0		;reheat animation inhibit delay (1/100ths sec)
AC_SWEEP_DELAY	DB	0		;wing sweep animation inhibit delay (1/100ths sec)
AC_TAXI_PTR	DW	-1		;taxi route ptr
AC_TAXI_XFT	DW	0		;taxi point xft
AC_TAXI_YFT	DW	0		;taxi point yft
AC_ARM_LOCK	DW	0		;arm lock timer (secs * 100)
AC_FLAGS	DW	0		;misc flags
AC_DECOY_TIMER	DW	0		;chaff / flare release timer (secs * 100)
AC_AA_TIMER	DW	0		;AAA and SAM activity timer (secs * 100)

;* combat data

AC_OPP_PTR	DW	-1		;opponent ptr (-1 = no opponent)
AC_PREV_PERR	DW	0		;previous pitch error (fine pdegs)
AC_PREV_PRATE	DW	0		;previous pitch rate (fine pdegs/sec)
AC_SHELLS	DB	0		;num cannon shells
AC_MISSILES	DB	0		;num missiles
AC_WPN_INT	DW	0		;weapon interval timer (secs * 100)
AC_EVADE_TIMER	DW	0		;evade missile timer (secs * 100)
AC_GMAX_TIMER	DW	0		;g max timer (secs * 100)

AIRCRAFT	ENDS

AC_REC_SIZE	EQU	TYPE AIRCRAFT

AC_WAYPOINTS	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+AC_REC_SIZE

;----------------------------------------------------------------
;* offsets to reach AIRCRAFT in compound mobile object data block
;----------------------------------------------------------------

_AC_DRONE	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+AC_DRONE
_AC_SIDE	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+AC_SIDE
_AC_EVENT	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+AC_EVENT
_AC_TYPE	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+AC_TYPE
_AC_DELAY	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+AC_DELAY
_AC_DRONE_NUM	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+AC_DRONE_NUM
_AC_EVENT_NUM	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+AC_EVENT_NUM
_AC_CTRL_MODE	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+AC_CTRL_MODE
_AC_WP_PTR	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+AC_WP_PTR
_AC_XFINE	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+AC_XFINE
_AC_YFINE	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+AC_YFINE
_AC_ZFINE	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+AC_ZFINE
_AC_HFINE	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+AC_HFINE
_AC_PFINE	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+AC_PFINE
_AC_RFINE	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+AC_RFINE
_AC_VTAS	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+AC_VTAS
_AC_VTAS_FINE	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+AC_VTAS_FINE
_AC_LIFT_VCTR	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+AC_LIFT_VCTR
_AC_AB_DELAY	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+AC_AB_DELAY
_AC_SWEEP_DELAY	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+AC_SWEEP_DELAY
_AC_TAXI_PTR	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+AC_TAXI_PTR
_AC_TAXI_XFT	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+AC_TAXI_XFT
_AC_TAXI_YFT	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+AC_TAXI_YFT
_AC_ARM_LOCK	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+AC_ARM_LOCK	
_AC_FLAGS	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+AC_FLAGS
_AC_DECOY_TIMER	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+AC_DECOY_TIMER
_AC_AA_TIMER	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+AC_AA_TIMER
_AC_OPP_PTR	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+AC_OPP_PTR
_AC_PREV_PERR	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+AC_PREV_PERR
_AC_PREV_PRATE	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+AC_PREV_PRATE
_AC_SHELLS	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+AC_SHELLS
_AC_MISSILES	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+AC_MISSILES
_AC_WPN_INT	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+AC_WPN_INT
_AC_EVADE_TIMER	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+AC_EVADE_TIMER
_AC_GMAX_TIMER	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+AC_GMAX_TIMER

;-------------------------------------
;* waypoint actions for drone aircraft
;-------------------------------------

AC_WP_NULL	EQU	0		;no action
AC_WP_TAKEOFF	EQU	2		;takeoff
AC_WP_AIRBORNE	EQU	4		;start airborne
AC_WP_TAXI	EQU	6		;taxi off runway
AC_WP_RESTART	EQU	8		;resupply then restart

;----------------
;* aircraft types
;----------------

GR4_TORNADO	EQU	0
MIG27_FLOGGER	EQU	2
F3_TORNADO	EQU	4
MIG31_FOXHOUND	EQU	6
F15_EAGLE	EQU	8
SU27_FLANKER	EQU	10
F16_FALCON	EQU	12
MIG29_FULCRUM	EQU	14
A10_THUNDERBOLT	EQU	16
SU25_FROGFOOT	EQU	18
E3D_SENTRY	EQU	20
IL76_MAINSTAY	EQU	22
C130_HERCULES	EQU	24
IL76_CANDID	EQU	26

;---------------------
;* misc aircraft flags
;---------------------

AFLG_IR_LOCK	EQU	0000000000000001b	;IR guided missile has lock
AFLG_RAD_LOCK	EQU	0000000000000010b	;radar guided missile has lock
AFLG_REL_CHAFF	EQU	0000000000000100b	;released chaff
AFLG_REL_FLARE	EQU	0000000000001000b	;released flare
AFLG_EVADE_HI	EQU	0000000000010000b	;evade missile (pull up)
AFLG_EVADE_LO	EQU	0000000000100000b	;evade missile (roll and pull)
AFLG_GMAX	EQU	0000000001000000b	;hard manoeuvring
AFLG_UPRIGHT	EQU	0000000010000000b	;fly upright to break
AFLG_BREAK	EQU	0000000100000000b	;break to land

;-----------------------
;* helicopter data block
;-----------------------

HELICOPTER	STRUCT	2

;* standard drone data (matches DRONE_DATA)

HC_DRONE	DW	DRONE_UNKNOWN	;drone type
HC_SIDE     	DB	DEAD		;side
HC_EVENT	DB	0		;event counter

;* custom data

HC_TYPE     	DW	0		;helicopter type
HC_DELAY	DW	0    		;initial delay (1/100ths sec)
HC_DRONE_NUM	DB	0		;drone to trigger event
HC_EVENT_NUM	DB	-1		;event number (-1 = no event)
HC_CTRL_MODE	DW	0		;control mode (see HELICOPS.ASM)
HC_WP_PTR	DW	-1		;waypoint ptr
HC_XFINE	DW	0		;xft fine
HC_YFINE	DW	0		;yft fine
HC_ZFINE	DW	0		;zft fine
HC_HFINE	DW	0		;heading fine (fine pdegs)
HC_PFINE	DW	0		;pitch fine (fine pdegs)
HC_RFINE	DW	0		;roll fine (fine pdegs)
HC_VTAS     	DW	0		;true airspeed ( *8)
HC_VTAS_FINE	DW	0		;true airspeed fine
HC_LIFT_VCTR	DW	0		;lift vector (fine pdegs)
HC_ACCEL_PFINE	DW	0		;pitch wrt accel (fine pdegs)
HC_FLAGS	DW	0		;misc flags
HC_DECOY_TIMER	DW	0		;chaff / flare release timer

HELICOPTER	ENDS

HC_REC_SIZE	EQU	TYPE HELICOPTER

HC_WAYPOINTS	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+HC_REC_SIZE

;------------------------------------------------------------------
;* offsets to reach HELICOPTER in compound mobile object data block
;------------------------------------------------------------------

_HC_DRONE	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+HC_DRONE
_HC_SIDE	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+HC_SIDE
_HC_EVENT	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+HC_EVENT
_HC_TYPE       	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+HC_TYPE
_HC_DELAY	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+HC_DELAY
_HC_DRONE_NUM	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+HC_DRONE_NUM
_HC_EVENT_NUM	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+HC_EVENT_NUM
_HC_CTRL_MODE	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+HC_CTRL_MODE
_HC_WP_PTR	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+HC_WP_PTR
_HC_XFINE	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+HC_XFINE
_HC_YFINE	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+HC_YFINE
_HC_ZFINE	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+HC_ZFINE
_HC_HFINE	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+HC_HFINE
_HC_PFINE	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+HC_PFINE
_HC_RFINE	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+HC_RFINE
_HC_VTAS       	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+HC_VTAS
_HC_VTAS_FINE  	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+HC_VTAS_FINE
_HC_LIFT_VCTR	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+HC_LIFT_VCTR
_HC_ACCEL_PFINE	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+HC_ACCEL_PFINE
_HC_FLAGS	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+HC_FLAGS
_HC_DECOY_TIMER	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+HC_DECOY_TIMER

;----------------------------------------
;* waypoint actions for drone helicopters
;----------------------------------------

HC_WP_NULL	EQU	0		;no action
HC_WP_TAKEOFF	EQU	2		;takeoff
HC_WP_AIRBORNE	EQU	4		;start airborne
HC_WP_STOP	EQU	6		;stop
HC_WP_RESTART	EQU	8		;resupply then restart

;------------------
;* helicopter types
;------------------

AH64_APACHE	EQU	0
MI24_HIND	EQU	2
CH47_CHINOOK	EQU	4
MI26_HALO	EQU	6

;-----------------------
;* misc helicopter flags
;-----------------------

HFLG_IR_LOCK	EQU	0000000000000001b	;IR guided missile has lock
HFLG_RAD_LOCK	EQU	0000000000000010b	;radar guided missile has lock
HFLG_REL_CHAFF	EQU	0000000000000100b	;released chaff
HFLG_REL_FLARE	EQU	0000000000001000b	;released flare

;-------------------------------------------
;* ground object / static mobile status flag (encoded in animation byte)
;-------------------------------------------

;OBJECT_LIGHTS	EQU	00000001b	;1 = night lighting on
OBJECT_LIGHTS	EQU	00000000b	;0 = night lighting off

OBJECT_ENEMY	EQU	01000000b	;1 = enemy
OBJECT_DEAD	EQU	10000000b	;1 = dead

OBJECT_CLEAR	EQU	11000000b	;clear animation with mask

;-----------------------------
;* aircraft animation switches
;-----------------------------

;* bit 7 has a reserved use - do not allocate!!!
;* bit 6 has a reserved use - do not allocate!!!

WING_SWEEP_FWD	EQU	00000000b
WING_SWEEP_MID	EQU	00000001b
WING_SWEEP_BCK	EQU	00000010b
WING_SWEEP_ALL	EQU	00000011b

GEAR_DOWN	EQU	00000100b

REHEAT_L_ENG	EQU	00001000b
REHEAT_R_ENG	EQU	00010000b
REHEAT_ALL	EQU	00011000b

AC_SPECIALS	EQU	00100000b

;-------------------------------
;* helicopter animation switches
;-------------------------------

;* bit 7 has a reserved use - do not allocate!!!
;* bit 6 has a reserved use - do not allocate!!!

ROTOR_POS1	EQU	00000000b
ROTOR_POS2	EQU	00000001b
ROTOR_POS3	EQU	00000010b

ROTOR_ALL	EQU	00000011b

;-----------------------------------
;* ground vehicle animation switches
;-----------------------------------

;* bit 7 has a reserved use - do not allocate!!!
;* bit 6 has a reserved use - do not allocate!!!

HEADLAMPS	EQU	00000001b

;--------------
;* weapon types
;--------------

NULL_WEAPON	EQU	-1

;* air-to-ground weapons

GPB1000		EQU	0		;1000lb slick bomb
RET1000		EQU	2		;1000lb retarded bomb
LGB1000		EQU	4		;1000lb laser guided bomb (Paveway II)
BL755		EQU	6		;cluster bomb
JP233		EQU	8		;JP233
ALARM		EQU	10		;ALARM

;* air-to-air weapons

CANNON		EQU	12		;cannon
SIDEWINDER	EQU	14		;Sidewinder (AIM-9L)
SKYFLASH	EQU	16		;active Sky Flash (ADV only)

;* surface-to-air weapons

PATRIOT		EQU	18		;radar guided SAM
GECKO		EQU	20		;IR guided SAM

;* chaff / flare

CHAFF		EQU	22
FLARE		EQU	24

;-----------------
;* external stores
;-----------------

EXT_GPB1000   	EQU	0		;1000lb slick bomb
EXT_RET1000   	EQU	2		;1000lb retarded bomb
EXT_LGB1000   	EQU	4		;1000lb laser guided bomb (Paveway II)
EXT_BL755     	EQU	6		;cluster bomb
EXT_JP233     	EQU	8		;JP233
EXT_ALARM     	EQU	10		;ALARM
EXT_SIDEWINDER	EQU	12		;Sidewinder (AIM-9L)
EXT_SKYFLASH	EQU	14		;active Sky Flash (ADV only)
EXT_BOZ100    	EQU	16		;chaff / flare dispenser (IDS / ECR only)
EXT_SKYSHADOW	EQU	18		;ECM jamming pod (IDS / ECR only)
EXT_DROPTANK	EQU	20		;external fuel tank

;------------------------------
;* max cannon, chaff and flares
;------------------------------

MAX_CANNON	EQU	180
MAX_CHAFF	EQU	120
MAX_FLARES	EQU	28

;------------------
;* weapon animation
;------------------

RETARDED_BOMB	EQU	00000001b	;0 = slick bomb, 1 = retarded bomb
CASING_OFF	EQU	00000010b	;0 = casing on, 1 = casing off

SPLASH1		EQU	00000001b	;0 = stage 2, 1 = stage 1

AIRBURST1	EQU	5		;first stage of airburst animation

FLAME		EQU	00000001b	;0 = no flame, 1 = flame
CHUTE		EQU	00000010b	;0 = no chute, 1 = chute

;* if Tornado cannon viewed from cockpit shift animation << 2

RHS_CANNON	EQU	00000001b	;rhs cannon
LHS_CANNON	EQU	00000010b	;lhs cannon

;-------------------
;* weapon data block
;-------------------

WEAPON		STRUCT	2

WPN_TYPE	DW	NULL_WEAPON	;weapon type
WPN_FLAGS	DW	0		;weapon flags
WPN_HFINE	DW	0		;hdg fine
WPN_PFINE	DW	0		;pitch fine
WPN_XFINE	DW	0		;x fine
WPN_YFINE	DW	0		;y fine
WPN_ZFINE	DW	0		;z fine
WPN_USERW1	DW	0		;user defined (see below)
WPN_USERW2	DW	0		;user defined (see below)
WPN_USERW3	DW	0		;user defined (see below)
WPN_USERW4	DW	0		;user defined (see below)
WPN_USERW5	DW	0		;user defined (see below)
WPN_USERW6	DW	0		;user defined (see below)
WPN_USERW7	DW	0		;user defined (see below)

WEAPON		ENDS

WPN_REC_SIZE	EQU	TYPE WEAPON

NUM_WEAPONS	EQU	128

WPN_DATA_SIZE	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+WPN_REC_SIZE

;--------------------------
;* user defined weapon data
;--------------------------

;* free fall bombs

WPN_BOMB_HVEL	EQU	WPN_USERW1	;horizontal velocity (ft/sec * 8)
WPN_BOMB_VVEL	EQU	WPN_USERW2	;vertical velocity (ft/sec * 8)

;* laser guided bombs

WPN_LGB_TGT	EQU	WPN_USERW1	;target waypoint ptr
WPN_LGB_VEL	EQU	WPN_USERW2	;velocity (ft/sec * 8)

;* cannons

WPN_CAN_HVEL	EQU	WPN_USERW1	;horizontal velocity (ft/sec * 8)
WPN_CAN_VVEL	EQU	WPN_USERW2	;vertical velocity (ft/sec * 8)
WPN_CAN_TIMER	EQU	WPN_USERW3	;lifetime (secs * 100)
WPN_CAN_SRC	EQU	WPN_USERW4	;source ptr (source of cannon fire)
					;(use -1 if not drone (ie. AAA)) 

;* missiles

WPN_MISS_TGT	EQU	WPN_USERW1	;target ptr (-1 = target lost)
WPN_MISS_VEL	EQU	WPN_USERW2	;velocity (ft/sec * 8)
WPN_MISS_ACCEL	EQU	WPN_USERW3	;acceleration (ft/sec/sec * 8)
WPN_MISS_TIMER	EQU	WPN_USERW4	;burntime / lifetime (secs * 100)
WPN_MISS_DECOY	EQU	WPN_USERW5	;decoy distraction timer (secs * 100)

;* ALARM missile

WPN_ALM_VEL	EQU	WPN_USERW1	;velocity (ft/sec * 8)
WPN_ALM_ACCEL	EQU	WPN_USERW2	;acceleration (ft/sec/sec * 8)
WPN_ALM_TIMER	EQU	WPN_USERW3	;burntime / lifetime (secs * 100)
WPN_ALM_XSEC	EQU	WPN_USERW4	;xsec )
WPN_ALM_YSEC	EQU	WPN_USERW5	;ysec )  target
WPN_ALM_XFT	EQU	WPN_USERW6	;xft  ) position
WPN_ALM_YFT	EQU	WPN_USERW7	;yft  )

;* chaff / flare (decoys use bomb ballistics)

WPN_DECOY_HVEL	EQU	WPN_BOMB_HVEL	;horizontal velocity (ft/sec * 8)
WPN_DECOY_VVEL	EQU	WPN_BOMB_VVEL	;vertical velocity (ft/sec * 8)
WPN_DECOY_LIFE	EQU	WPN_USERW3	;lifetime (secs * 100)

;--------------
;* weapon flags
;--------------

WFLG_ALARM_MODE	EQU	0000000000000111b	;ALARM control mode (DO NOT CHANGE)
WFLG_TORNADO	EQU	0000000000001000b	;Tornado weapon release
WFLG_SPLASH	EQU	0000000000010000b	;draw weapon as splash
WFLG_UNGUIDED	EQU	0000000000100000b	;LGB assumes GPB behaviour
WFLG_BOMBLET	EQU	0000000001000000b	;BL755 bomblet
WFLG_BURNOUT	EQU	0000000010000000b	;missile motor burnt out
WFLG_IR_SEEK	EQU	0000000100000000b	;IR missile (else assume radar)
WFLG_AIRBURST	EQU	0000001000000000b	;draw weapon as airburst
WFLG_NO_RADAR	EQU	0000010000000000b	;no radar targets for ALARM
WFLG_TLOCK	EQU	0000100000000000b	;weapon locked onto Tornado

;* ALARM control modes

ALARM_DIRECT	EQU	0		;direct
ALARM_KILL	EQU	1		;kill
ALARM_GUIDE	EQU	2		;guide
ALARM_ZOOM	EQU	3		;zoom climb
ALARM_FREEFALL	EQU	4		;freefall
ALARM_LOITER	EQU	5		;loiter
ALARM_DIVE	EQU	6		;dive

;--------------------------------------------------------------
;* offsets to reach WEAPON in compound mobile object data block
;--------------------------------------------------------------

_WPN_TYPE	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+WPN_TYPE
_WPN_FLAGS	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+WPN_FLAGS
_WPN_HFINE	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+WPN_HFINE
_WPN_PFINE	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+WPN_PFINE
_WPN_XFINE	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+WPN_XFINE
_WPN_YFINE	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+WPN_YFINE
_WPN_ZFINE	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+WPN_ZFINE
_WPN_USERW1	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+WPN_USERW1
_WPN_USERW2	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+WPN_USERW2
_WPN_USERW3	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+WPN_USERW3
_WPN_USERW4	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+WPN_USERW4

_WPN_BOMB_HVEL	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+WPN_BOMB_HVEL
_WPN_BOMB_VVEL	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+WPN_BOMB_VVEL

_WPN_LGB_TGT	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+WPN_LGB_TGT
_WPN_LGB_VEL	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+WPN_LGB_VEL

_WPN_CAN_HVEL	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+WPN_CAN_HVEL
_WPN_CAN_VVEL	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+WPN_CAN_VVEL
_WPN_CAN_TIMER	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+WPN_CAN_TIMER

_WPN_MISS_TGT	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+WPN_MISS_TGT
_WPN_MISS_VEL	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+WPN_MISS_VEL
_WPN_MISS_ACCEL	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+WPN_MISS_ACCEL
_WPN_MISS_TIMER	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+WPN_MISS_TIMER
_WPN_MISS_DECOY	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+WPN_MISS_DECOY

_WPN_ALM_VEL	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+WPN_ALM_VEL
_WPN_ALM_ACCEL	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+WPN_ALM_ACCEL
_WPN_ALM_TIMER	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+WPN_ALM_TIMER
_WPN_ALM_XSEC	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+WPN_ALM_XSEC
_WPN_ALM_YSEC	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+WPN_ALM_YSEC
_WPN_ALM_XFT	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+WPN_ALM_XFT
_WPN_ALM_YFT	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+WPN_ALM_YFT

_WPN_DECOY_HVEL	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+WPN_DECOY_HVEL
_WPN_DECOY_VVEL	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+WPN_DECOY_VVEL
_WPN_DECOY_LIFE	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+WPN_DECOY_LIFE

;----------------------
;* weapon effectiveness
;----------------------

WPN_EFFECT1	EQU	0
WPN_EFFECT2	EQU	1
WPN_EFFECT3	EQU	2
WPN_EFFECT4	EQU	3

;---------------------------
;* weapon package data block
;---------------------------

PACKAGE		STRUCT	2

PACK_WP_ID	DB	'-'		;waypoint identifier 'X', 'Y', 'Z' or '-' (unassigned)
PACK_WEAP_TYPE	DW	NULL_WEAPON	;weapon type
PACK_WEAP_NUM	DW	0		;number of weapons
PACK_WEAP_MODE	DW	ARM_OFF		;weapon arming mode (see below)

PACKAGE		ENDS

PACK_REC_SIZE	EQU	TYPE PACKAGE

NUM_PACKAGES	EQU	3

;--------------
;* arming modes
;--------------

ARM_OFF		EQU	0		;off
ARM_MANUAL	EQU	2		;manual bombing
ARM_LAYDOWN	EQU	4		;laydown bombing
ARM_LOFT	EQU	6		;loft bombing
ARM_LGB		EQU	8		;laser guided bomb
ARM_JP233	EQU	10		;JP233
ARM_ALARM_DIR	EQU	12		;ALARM (direct attack mode)
ARM_ALARM_IND	EQU	14		;ALARM (indirect attack mode)
ARM_CANNON	EQU	16		;cannon
ARM_SIDEWINDER	EQU	18		;Sidewinder
ARM_SKYFLASH	EQU	20		;Sky Flash

;-----------------------
;* screen shake priority (1 = lowest, 255 = highest)
;-----------------------

;* note: Every shake should be given a unique priority level. This is so that
;*	 shakes can be identified (see CANCEL_SHAKE (MISCMAC.INC)).

SHAKE_NOSE_DOWN	EQU	5		;nose wheel touchdown
SHAKE_LAND_GOOD	EQU	10		;good landing
SHAKE_LAND_HVY	EQU	15		;heavy landing

SHAKE_CANNON	EQU	45		;cannon fire
SHAKE_JP233	EQU	50		;JP233 release

SHAKE_DAMAGE	EQU	75		;hit by cannon fire / explosion damage 

SHAKE_COLLIDE	EQU	100		;collide with object

;* long duration shakes (higher priority)

SHAKE_BRAKE	EQU	240		;not moving, brakes on and reheat on
SHAKE_BUFFET	EQU	245		;buffet due to excess speed wrt wing sweep
SHAKE_OFF_HARD	EQU	250		;off hard surface (runway, taxiway etc.)
SHAKE_WHEELS_UP	EQU	255		;wheels up landing

;---------------
;* landing types
;---------------

LAND_GOOD	EQU	00000001b	;1 = good landing
LAND_HEAVY	EQU	00000010b	;1 = heavy landing
LAND_WHEELS_UP	EQU	00000100b	;1 = wheels up landing
LAND_DEAD_STICK	EQU	00001000b	;1 = dead stick landing
LAND_ROAD	EQU	00010000b	;1 = landed on road
LAND_ENEMY	EQU	00100000b	;1 = landed in enemy territory
LAND_STATIONARY	EQU	01000000b	;1 = stationary (when quit)

;----------------------------
;* tornado destruction levels
;----------------------------

MINOR_DAMAGE	EQU	1
MAJOR_DAMAGE	EQU	2
TOTAL_DAMAGE	EQU	3

;----------------------------
;* air radar track data block
;----------------------------

ARAD_TRACK	STRUCT	2

ARAD_PTR	DW	-1		;ptr to mobile + viewpoint data
ARAD_RNG	DD	0		;range (ft)
ARAD_BRG	DW	0		;brg (pdegs)
ARAD_XCRT	DW	0		;0 .. 63 (from top lh corner)
ARAD_YCRT	DW	0		;0 .. 47 (from top lh corner)

ARAD_TRACK	ENDS

ARAD_RNG_LO	EQU	ARAD_RNG
ARAD_RNG_HI	EQU	ARAD_RNG+2

ARAD_REC_SIZE	EQU	TYPE ARAD_TRACK

NUM_TRACKS	EQU	40		;max number of aircraft radar can track

;-----------------
;* air radar range
;-----------------

ARAD_MIN_RANGE	EQU	0		;short range (guns)
ARAD_MED_RANGE	EQU	2		;medium range (Sidewinder)
ARAD_MAX_RANGE	EQU	4		;long range (SkyFlash)

;------------------------------
;* bomb impact point data block
;------------------------------

IMPACT		STRUCT	2

IMP_XSEC	DB	0		;x sec = 0 .. 31 (on active map)
IMP_YSEC	DB	0		;y sec = 0 .. 31 (on active map)
IMP_XFT		DW	0		;xft
IMP_YFT		DW	0		;yft
IMP_WEAP_TYPE	DB	NULL_WEAPON	;weapon type
IMP_SURF_TYPE	DB	0		;surface type

IMPACT		ENDS

IMP_REC_SIZE	EQU	TYPE IMPACT

NUM_IMPACTS	EQU	128

;-----------------------
;* sector gameplay flags
;-----------------------

SECT_ENEMY	EQU	10000000b	;1 = enemy occupied sector

SECT_SAM	EQU	01000000b	;1 = SAM in sector
SECT_AAA	EQU	00100000b	;1 = AAA in sector
SECT_EWR	EQU	00010000b	;1 = EWR in sector

SECT_EWR_NUM	EQU	00001111b	;enemy EWR number (0 .. 15)
					;(where E_EWR_FLOOR is > 0)

;------------------------
;* sector EWR floor masks
;------------------------

;* EWR floor = 1 .. 15 * 256ft, 0 = no cover

E_EWR_FLOOR	EQU	00001111b	;enemy EWR floor
A_EWR_FLOOR	EQU	11110000b	;allied EWR floor

;-----------------------------------
;* maximum number of radars per side
;-----------------------------------

NUM_SAM_AAA	EQU	128
NUM_EWR		EQU	8

;-------------------------------
;* radar list offsets data block (if modified then update CALC_RAD_INDEX in MISCMAC.INC)
;-------------------------------

RADARS		STRUCT	2

RAD_SAM_OFFSET	DW	-1  		;offset into SAM list for sector (-1 = null list)
RAD_AAA_OFFSET	DW	-1  		;offset into AAA list for sector (-1 = null list)

RADARS		ENDS

RAD_REC_SIZE	EQU	TYPE RADARS

;-----------
;* EWR types
;-----------

EWR_GROUND	EQU	0		;ground object (SECDATA1)
EWR_MOBILE	EQU	2		;mobile object (MSECDATA1)

;----------------
;* EWR data block (if modified then update CALC_EWR_INDEX in MISCMAC.INC)
;----------------

EWR		STRUCT	2

EWR_TYPE	DW	-1		;static / mobile
EWR_XSEC	DB	-1		;x sector (0.. 31)
EWR_YSEC	DB	-1		;y sector (0.. 31)
EWR_PTR		DW	-1		;object ptr

EWR		ENDS

EWR_REC_SIZE	EQU	EWR

;------------------
;* RWR threat types
;------------------

THREAT_SAM	EQU	0
THREAT_AAA	EQU	2
THREAT_EWR	EQU	4
THREAT_AC	EQU	6
THREAT_RAD_MSL	EQU	8
THREAT_IR_MSL	EQU	10

;----------------
;* RWR data block
;----------------

RWR		STRUCT	2

RWR_THREAT	DW	0		;see above
RWR_RNG		DD	0		;range (ft)
RWR_DIR		DW	0		;0 .. 511
RWR_XSEC	DW	0		;xsec
RWR_YSEC	DW	0		;ysec
RWR_XFT		DW	0		;xft
RWR_YFT		DW	0		;yft
RWR_PTR		DW	-1		;source ptr (valid for SAM and AAA only)

RWR		ENDS

RWR_RNG_LO	EQU	RWR_RNG
RWR_RNG_HI	EQU	RWR_RNG+2

RWR_REC_SIZE	EQU	RWR

NUM_RWR_THREATS	EQU	16

;------------------
;* RWR threat flags
;------------------

RWR_SAM		EQU	00010000b
RWR_AAA		EQU	00001000b
RWR_EWR		EQU	00000100b
RWR_AC		EQU	00000010b
RWR_MSL		EQU	00000001b

;--------------------------
;* object damage attributes
;--------------------------

;* object hardness

DAM_HARD_MASK	EQU	00000011b	;(DO NOT CHANGE)

DAM_HARD1	EQU	00000000b	;soft
DAM_HARD2	EQU	00000001b
DAM_HARD3	EQU	00000010b
DAM_HARD4	EQU	00000011b	;hard

;* object debris

DAM_DEBRIS_MASK	EQU	00011100b	;(DO NOT CHANGE)

DAM_DEBRIS1	EQU	00000000b	;crater 1	) MOBILES CAN ONLY
DAM_DEBRIS2	EQU	00000100b	;crater 2	) USE THESE VALUES
DAM_DEBRIS3	EQU	00001000b	;crater 3
DAM_DEBRIS4	EQU	00001100b	;NS road bridge
DAM_DEBRIS5	EQU	00010000b	;EW road bridge
DAM_DEBRIS6	EQU	00010100b	;NS rail bridge
DAM_DEBRIS7	EQU	00011000b	;EW rail bridge
DAM_DEBRIS8	EQU	00011100b	;embankment crater

;* object explosion size

;DAM_EXPLO_MASK	EQU	01100000b	;(DO NOT CHANGE)
DAM_EXPLO_MASK	EQU	11111111b	;(DO NOT CHANGE)

DAM_EXPLO1	EQU	00000000b	;burn only
DAM_EXPLO2	EQU	00100000b	;crater size 1 * 2
DAM_EXPLO3	EQU	01000000b	;crater size 2 * 2
DAM_EXPLO4	EQU	01100000b	;crater size 2 * 4


;* object invalid (not a valid target)

DAM_INVALID	EQU	10000000b	;(DO NOT CHANGE)

;-----------------------------
;* two player comms data block
;-----------------------------

COMMS		STRUCT	2

COMMS_CHECKSUM	DB	0		;7-bit checksum (bit 7 always 0)
COMMS_FLAGS1	DB	0		;misc flags
COMMS_FLAGS2	DB	0		;misc flags
COMMS_FLAGS3	DB	0		;misc flags
COMMS_MOB_NUM	DB	0		;mobile object number
COMMS_MOB_ANIM	DB	0		;mobile animation data
COMMS_XSEC	DW	0		;xsec
COMMS_YSEC	DW	0		;ysec
COMMS_XFT	DW	0		;xft
COMMS_YFT	DW	0		;yft
COMMS_ZFT	DD	0		;zft
COMMS_HDG	DW	0		;hdg
COMMS_PITCH	DW	0		;pitch
COMMS_ROLL	DW	0		;roll
COMMS_VTAS	DW	0		;vtas

COMMS		ENDS

COMMS_REC_SIZE	EQU	TYPE COMMS

COMMS_ZFT_LO	EQU	COMMS_ZFT
COMMS_ZFT_HI	EQU	COMMS_ZFT+2

;-------------
;* comms flags
;-------------

;* flags 1

I_FIRE_CANNON	EQU	00000001b	;I have fired a cannon shell
I_FIRE_AIM9L	EQU	00000010b	;I have launched a Sidewinder
I_FIRE_SKYFLASH	EQU	00000100b	;I have launched a Sky Flash
I_REL_CHAFF	EQU	00001000b	;I have released chaff
I_REL_FLARE	EQU	00010000b	;I have released flare
I_EMIT_RADAR	EQU	00100000b	;I am emitting radar
I_EMIT_ECM	EQU	01000000b	;I am emitting ECM
I_ILLUM_YOU	EQU	10000000b	;I am illuminating you (on radar)

;* flags 2

I_PAUSED	EQU	00000001b	;I have paused
I_RESUMED	EQU	00000010b	;I have resumed

;* flags 3 (end of game conditions)

I_NO_WEAPONS	EQU	00000001b	;I have no weapons
I_KILLED	EQU	00000010b	;I have been destroyed
I_EJECTED	EQU	00000100b	;I have ejected
I_QUIT		EQU	00001000b	;I have quit
I_KILLED_YOU	EQU	00010000b	;I have destroyed you

;--------------------------
;* runway damage data block
;--------------------------

RUNWAY_DAMAGE	STRUCT	2

RDAM_XSEC	DW	-1		;xsec (-1 = unused)
RDAM_YSEC	DW	-1		;ysec (-1 = unused)
RDAM_HITS	DW	0		;hit counter

RUNWAY_DAMAGE	ENDS

RDAM_REC_SIZE	EQU	TYPE RUNWAY_DAMAGE

NUM_RUNWAYS	EQU	8

