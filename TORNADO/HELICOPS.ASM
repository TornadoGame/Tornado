;****************************************************************************
;*
;* HELICOPS.ASM
;*
;* Drone helicopter control.
;*
;* 11.09.1992 - KJB
;* 
;* Allied Helicopters 	vs	Enemy Helicopters	Role
;* 컴컴컴컴컴컴컴컴컴 		컴컴컴컴컴컴컴컴�	컴컴
;* AH-64 Apache		vs	Mi-24 Hind		gunship
;* CH-47 Chinook   	vs	Mi-26 Halo		heavy lift helicopter
;*
;* Notes
;* 컴컴�
;*
;*    Data Format
;*    컴컴컴컴컴�
;*       Compound data structure for each drone:-
;*
;*	    MOBILE <>    	<- drone object data (VISDATA.INC)
;*          VIEWPOINT <>	<- drone position and attitude data (VISDATA.INC)
;*          HELICOPTER <>  	<- drone control data (MAINDATA.INC)
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
;*       HC_WP_TAKEOFF	: Helicopters may have an initial delay period or wait
;*			  for an event. The initial delay is not valid if the
;*			  helicopter is triggered by an event.
;*
;*       HC_WP_AIRBORNE	: The helicopter starts airborne. The initial speed is
;*                        set by WP_SPEED (therefore WP_COORD = 0).
;*
;*	 HC_WP_STOP	: Only use on final waypoint. The helicopter lands and
;*			  remains inactive.
;*
;*       HC_WP_RESTART	: Only use on final waypoint. The helicopter lands and
;*			  waits whilst it is resupplied and then takes off again.
;*			  The helicopter flies to the second waypoint after
;*			  takeoff. This mechanism is only useful for continuous routes.
;*
;*    Altitude
;*    컴컴컴컴
;*	 In general keep helicopter altitudes low (200 .. 300ft). Variation
;* 	 of max speed with altitude is not considered. Always use terrain
;*	 following.
;*
;*    Event Counter
;*    컴컴컴컴컴컴�
;*       The event counter is not implemented.
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	InitHelicops
		PUBLIC	UpdateHelicops

		EXTRN	UpdateMobile:FAR
		EXTRN	ArcTan:FAR
		EXTRN	ArcTan2:FAR
		EXTRN	Tangent:FAR
		EXTRN	CalcSineFine:FAR
		EXTRN	CalcRngBrgVP_WP:FAR
		EXTRN	CalcRngBrgWP_WP:FAR
		EXTRN	CalcAngDiff:FAR
		EXTRN	CalcGndHeight:FAR
		EXTRN	CalcDeltaXY:FAR
		EXTRN	RandX:FAR

		EXTRN	ReleaseDecoy:NEAR

		EXTRN	FrameElapTime:DWORD

		EXTRN	AHelicopter1:WORD
		EXTRN	AHelicopter2:WORD
		EXTRN	AHelicopter3:WORD
		EXTRN	AHelicopter4:WORD
		EXTRN	EHelicopter1:WORD
		EXTRN	EHelicopter2:WORD
		EXTRN	EHelicopter3:WORD
		EXTRN	EHelicopter4:WORD
		EXTRN	DeltaTime:WORD
		EXTRN	SinTable:WORD
		EXTRN	CosTable:WORD
		EXTRN	LastFrame:WORD
		EXTRN	TMP_VIEW:WORD
		EXTRN	DronePtrs:WORD

;============================================================================

		INCLUDE	MAINDATA.INC

		INCLUDE	\VISUAL\VISDATA.INC
		INCLUDE	\VISUAL\VISMACRO.INC

		INCLUDE	\LIB8086\TRIG.INC
		INCLUDE	\LIB8086\USEFUL.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

;****************************************************************************
;* The HC_ suffix on some variables is necessary to differentiate them from *
;* similar global vars (in case they need to be made public for debugging). *
;****************************************************************************

HelicopterPtr	DW	-1		;helicopter data / waypoint ptr

PerfDataPtr	DW	-1		;helicopter performance data ptr

;---------------------------------------------------------
;* working copy of current helicopter's data and waypoints
;---------------------------------------------------------

HC_DATA_SIZE	EQU	MOB_REC_SIZE+VIEW_REC_SIZE+HC_REC_SIZE

HC_Workspace	LABEL	BYTE

HC_Mobile	MOBILE <>
HC_View		VIEWPOINT <>
HC_Data		HELICOPTER <>

		EVEN

;-----------
;* AutoRoute
;-----------

HC_AutoHFine	DW	0		;heading to acquire (fine pdegs)
HC_AutoAlt	DW	0		;altitude to acquire (ft)
HC_AutoVtas	DW	0		;speed to acquire (ft/sec * 8)

HC_WPRng	DD	0		;waypoint range
HC_WPBrg 	DW	0		;waypoint bearing (pdeg)
HC_WPBrgFine	DW	0		;waypoint bearing (fine pdeg)

;--------------
;* AutoThrottle
;--------------

FIXED_DECEL	EQU	10*8		;fixed decel rate (ft/sec/sec * 8)

ACC_PITCH_RATE	EQU	32*128		;pitch rate wrt accel (fine pdegs)

;--------------
;* CalcTurnDist
;--------------

HC_ThetaAB 	DW	0		;angle vp(A) -> wp(B)

HC_ThetaBC 	DW	0		;angle wp(B) -> wp(C)

HC_ThetaABC	DW	0		;angle vp(A) -> wp(B) -> wp(C)

HC_RTurn   	DW	0		;turning radius (0 .. 32,767ft)

;--------------------------
;* helicopter control modes
;--------------------------

CTRL_NULL	EQU	0		;do nothing
CTRL_TAKEOFF	EQU	2		;takeoff
CTRL_TRACK	EQU	4		;fly from waypoint to waypoint
CTRL_APPROACH	EQU	6		;final approach to hover
CTRL_TOUCHDOWN	EQU	8		;descend and touchdown

ControlMode	DW	CtrlNull	;CTRL_NULL
		DW	CtrlTakeoff	;CTRL_TAKEOFF
		DW	CtrlTrack	;CTRL_TRACK
		DW	CtrlApproach	;CTRL_APPROACH
		DW	CtrlTouchDown	;CTRL_TOUCHDOWN

;--------------------------------------
;* helicopter performance data pointers
;--------------------------------------

PerfDataPtrs	DW	OFFSET AH64Apache	;AH64_APACHE
		DW	OFFSET Mi24Hind		;MI24_HIND
		DW	OFFSET Ch47Chinook	;CH47_CHINOOK
		DW	OFFSET Mi26Halo		;MI26_HALO

;-----------------------------
;* helicopter performance data
;-----------------------------

PERF_DATA	STRUCT

PERF_TAKEOFF	DW	-1		;takeoff data ptr
PERF_CRUISE	DW	-1		;cruise data ptr

PERF_DATA	ENDS

AH64Apache	PERF_DATA <					\
			     OFFSET Takeoff1,			\
			     OFFSET Cruise1			\
			  >

Mi24Hind	PERF_DATA <					\
			     OFFSET Takeoff1,			\
			     OFFSET Cruise1			\
			  >

Ch47Chinook	PERF_DATA <					\
			     OFFSET Takeoff2,			\
			     OFFSET Cruise2			\
			  >

Mi26Halo	PERF_DATA <					\
			     OFFSET Takeoff2,			\
			     OFFSET Cruise2			\
			  >

;--------------------
;* takeoff parameters
;--------------------

TAKEOFF		STRUCT

TO_ZDOT		DW	0		;climb rate (ft/sec * 8)

TAKEOFF		ENDS

DLY_AFTER_EVENT	EQU	30*100		;delay after event (1/100ths sec)

;----------------------------------
;* takeoff climb rate = 2,500ft/min
;----------------------------------
	
Takeoff1	TAKEOFF <333>

;----------------------------------
;* takeoff climb rate = 1,500ft/min
;----------------------------------
	
Takeoff2	TAKEOFF <200>

;-------------------
;* cruise parameters
;-------------------

CRUISE		STRUCT	2

CRS_CEILING	DW	0		;ceiling (ft)
CRS_MXSPEED_SL	DW	0		;max speed at sea level (ft/sec * 8)
CRS_ACCEL	DW	0		;acceleration (ft/sec/sec * 8)
CRS_HEAVY	DB	0		;0 = light helicopter
					;1 = heavy helicopter

CRUISE		ENDS

;----------------------------------
;* ceiling = 15,000ft
;* max speed at sea level = 160kts
;* acceleration = 12ft/sec/sec
;* light helicopter
;----------------------------------

Cruise1		CRUISE <15000,2176,96,0>

;----------------------------------
;* ceiling = 15,000ft
;* max speed at sea level = 135kts
;* acceleration = 8ft/sec/sec
;* heavy helicopter
;----------------------------------

Cruise2		CRUISE <15000,1836,64,1>

;--------------------
;* landing parameters
;--------------------

LAND_ZDOT	EQU	10*8		;descend rate (ft/sec * 8)

RESUPPLY_DELAY	EQU	15*100		;time to resupply aircraft (1/100ths sec)

;------------------
;* track parameters
;------------------

AH_MAX_ROLL	EQU	85*128		;60 degs

AH_ROLL_RATE	EQU	64*128		;45 degs / sec

DATA		ENDS

;============================================================================

DRONECODE	SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:DRONECODE
		ASSUME DS:DATA

;* InitHelicops - initialize drone helicopters
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

InitHelicops	PROC	FAR

		mov	si,OFFSET AHelicopter1
		call	InitOneHeli

		mov	si,OFFSET AHelicopter2
		call	InitOneHeli

		mov	si,OFFSET AHelicopter3
		call	InitOneHeli

		mov	si,OFFSET AHelicopter4
		call	InitOneHeli

		mov	si,OFFSET EHelicopter1
		call	InitOneHeli

		mov	si,OFFSET EHelicopter2
		call	InitOneHeli

		mov	si,OFFSET EHelicopter3
		call	InitOneHeli

		mov	si,OFFSET EHelicopter4
		call	InitOneHeli

		ret

InitHelicops	ENDP

;----------------------------------------------------------------------------

;* InitOneHeli - initialize single drone helicopter
;*
;* pass: si -> MOBILE + VIEWPOINT + HELICOPTER compound data block
;* ret : nothing
;* kill: assume all

InitOneHeli	PROC	NEAR

;------------------------------
;* test if helicopter is active
;------------------------------

		cmp	_HC_SIDE[si],DEAD	;helicopter active?
		_JE	InitOneExit  		;no ->

;---------------------------
;* init miscellaneous values
;---------------------------

		xor	ax,ax

		mov	MOB_ANIM[si],al
		
		mov	_VP_PITCH[si],ax
		mov	_VP_ROLL[si],ax

		mov	_HC_EVENT[si],al
		mov	_HC_XFINE[si],ax
		mov	_HC_YFINE[si],ax
		mov	_HC_ZFINE[si],ax
		mov	_HC_PFINE[si],ax
		mov	_HC_RFINE[si],ax
		mov	_HC_VTAS[si],ax
		mov	_HC_VTAS_FINE[si],ax
		mov	_HC_LIFT_VCTR[si],ax
		mov	_HC_ACCEL_PFINE[si],ax

;--------------------------------------
;* init waypoint ptr to second waypoint
;--------------------------------------

		mov	di,si
		add	di,HC_WAYPOINTS+WAY_REC_SIZE	;di -> second waypoint
		
		mov	_HC_WP_PTR[si],di

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
		add	di,HC_WAYPOINTS		;di -> first waypoint

		mov	ax,WP_SPEED[di]
		mov	_HC_VTAS[si],ax

SetCtrlMode:	mov	_HC_CTRL_MODE[si],dx

;-------------------
;* init heading fine
;-------------------

		mov	cl,7		;*128

		mov	ax,_VP_HDG[si]
		shl	ax,cl
		mov	_HC_HFINE[si],ax

;------------------
;* init decoy timer
;------------------

		call	RandX		;0.00 .. 2.55
		shr	ax,1		;0.00 .. 1.27
		add	ax,50		;0.50 .. 1.77

		mov	_HC_DECOY_TIMER[si],ax
		
InitOneExit:	ret

InitOneHeli	ENDP

;----------------------------------------------------------------------------

;* UpdateHelicops - update drone helicopters
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

UpdateHelicops	PROC	FAR

		mov	si,OFFSET AHelicopter1
		call	UpdateOneHeli

		mov	si,OFFSET AHelicopter2
		call	UpdateOneHeli

		mov	si,OFFSET AHelicopter3
		call	UpdateOneHeli

		mov	si,OFFSET AHelicopter4
		call	UpdateOneHeli

		mov	si,OFFSET EHelicopter1
		call	UpdateOneHeli

		mov	si,OFFSET EHelicopter2
		call	UpdateOneHeli

		mov	si,OFFSET EHelicopter3
		call	UpdateOneHeli

		mov	si,OFFSET EHelicopter4
		call	UpdateOneHeli

		ret

UpdateHelicops	ENDP

;----------------------------------------------------------------------------

;* UpdateOneHeli - update single drone helicopter
;*
;* pass: si -> MOBILE + VIEWPOINT + HELICOPTER compound data block
;* ret : nothing
;* kill: assume all

UpdateOneHeli	PROC	NEAR

;----------------------------
;* test if helicopter is active
;----------------------------

		cmp	_HC_SIDE[si],DEAD	;helicopter active?
		je	UpdateOneExit		;no ->

		mov	HelicopterPtr,si	;store original data ptr

;-------------------------------------
;* copy helicopter data into workspace
;-------------------------------------

		mov	cx,HC_DATA_SIZE
		mov	di,OFFSET HC_Workspace
		FAST_MOVE

;---------------------------
;* sort performance data ptr
;---------------------------

		mov	bx,HC_Data.HC_TYPE
		mov	ax,PerfDataPtrs[bx]
		mov	PerfDataPtr,ax

;--------------------------
;* rotate helicopter blades
;--------------------------

		mov	al,HC_Mobile.MOB_ANIM
		and	al,ROTOR_ALL			;current rotor pos
		add	al,ROTOR_POS2			;rotate one position
		cmp	al,ROTOR_POS3			;end of rotation?
		jbe	@F				;no ->
		mov	al,ROTOR_POS1			;start of rotation
@@:		and	HC_Mobile.MOB_ANIM,NOT ROTOR_ALL;clear old rotation
		or	HC_Mobile.MOB_ANIM,al		;set new rotation

;---------------------
;* select control mode
;---------------------

		mov	bx,HC_Data.HC_CTRL_MODE
		call	ControlMode[bx]

;----------------------------
;* update helicopter position
;----------------------------

		call	CalcAngles

		call	CalcDeltaXYZ

;-------------------------------------
;* copy helicopter data from workspace 
;-------------------------------------

;* IMPORTANT: Copy helicopter data from workspace back to its original position
;*            before calling UpdateMobile. If the helicopter changes sector the
;*            delete / create mobile routines require the original address of
;*            the data as a reference.

		mov	bp,cx		;store delta zft

		mov	cx,HC_DATA_SIZE
		mov	si,OFFSET HC_Workspace
		mov	di,HelicopterPtr
		FAST_MOVE

		mov	cx,bp		;restore delta zft

;----------------------
;* update mobile object
;----------------------

		mov	si,HelicopterPtr
		call	UpdateMobile

		call	GroundCheck

;------------------------
;* weapon evasion tactics
;------------------------

		call	EvasionTactics
	
UpdateOneExit:	ret

UpdateOneHeli	ENDP

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

		cmp	HC_Data.HC_EVENT_NUM,-1	;wait for event?
		je	SortDelay		;no ->

		mov	bl,HC_Data.HC_DRONE_NUM	;fetch drone number
		xor	bh,bh
		shl	bx,1			;*2 word index

		mov	di,DronePtrs[bx]	;di -> drone data

		mov	al,_DRONE_EVENT[di]

		cmp	al,HC_Data.HC_EVENT_NUM	;event satisfied?
		_JB	ExitTakeoff		;no ->

		mov	HC_Data.HC_DRONE_NUM,0	;clear event
		mov	HC_Data.HC_EVENT_NUM,-1

		mov	HC_Data.HC_DELAY,DLY_AFTER_EVENT

;----------------------
;* delay before takeoff
;----------------------

SortDelay:	mov	ax,HC_Data.HC_DELAY
		test	ax,ax			;delay?
		jz	@F			;no ->

		sub	ax,LastFrame

		MINM	ax

		mov	HC_Data.HC_DELAY,ax

		jmp	ExitTakeoff

;----------------------------
;* pick up takeoff parameters
;----------------------------

@@:		mov	di,PerfDataPtr
		mov	di,PERF_TAKEOFF[di]

;-------------------------------------------
;* climb until takeoff altitude is satisfied
;-------------------------------------------

;* if zft < 100ft then
;*    accel zdot to steady state value
;* else
;*    decel zdot to zero
;* endif

;* (note: vtas is effectively zdot)

		cmp	WORD PTR HC_View.VP_ZFT_HI,0	;zft > 65,535ft?
		ja	DecelZDot			;yes ->

		mov	ax,WORD PTR HC_View.VP_ZFT_LO
		cmp	ax,100
		jae	DecelZDot

;---------------------------
AccelZDot	LABEL	NEAR
;---------------------------

		mov	bp,TO_ZDOT[di]

		cmp	bp,HC_Data.HC_VTAS	;reached steady state zdot?
		je	ZDotOk			;yes ->

		mov	ax,bp
		REPT	2		;accel = steady state zdot / 4
		shr	ax,1
		ENDM
		mov	dx,DeltaTime
		imul	dx

		shl	ax,1		;adjust after fractional multiply
		rcl	dx,1

		add	HC_Data.HC_VTAS_FINE,ax
		adc	HC_Data.HC_VTAS,dx

		cmp	HC_Data.HC_VTAS,bp	;reached steady state zdot?
		jb	ZDotOk			;no ->

		mov	HC_Data.HC_VTAS,bp
		mov	HC_Data.HC_VTAS_FINE,0

		jmp	ZDotOk

;---------------------------
DecelZDot	LABEL	NEAR
;---------------------------

		mov	ax,TO_ZDOT[di]

		REPT	1		;decel = steady state zdot / 2
		shr	ax,1
		ENDM
		mov	dx,DeltaTime
		imul	dx

		shl	ax,1		;adjust after fractional multiply
		rcl	dx,1

		sub	HC_Data.HC_VTAS_FINE,ax
		sbb	HC_Data.HC_VTAS,dx

		jns	ZDotOk		;zdot >= 0 ->

		xor	ax,ax
		mov	HC_Data.HC_VTAS,ax
		mov	HC_Data.HC_VTAS_FINE,ax

;-------------------
;* takeoff satisfied
;-------------------

		mov	si,HC_Data.HC_WP_PTR

		call	SortControlMode

		mov	HC_Data.HC_CTRL_MODE,dx

		mov	HC_Data.HC_LIFT_VCTR,0*128	;0degs

		jmp	ExitTakeoff
		
ZDotOk:		mov	HC_Data.HC_LIFT_VCTR,128*128	;90degs

ExitTakeoff:	ret

CtrlTakeoff	ENDP

;----------------------------------------------------------------------------

;* CtrlTrack - track control (fly from waypoint to waypoint)
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

CtrlTrack	PROC	NEAR

		call	AutoRoute

		mov	ax,HC_AutoHFine
		call	AutoHeading

		mov	ax,HC_AutoAlt
		call	AutoAltitude

		mov	ax,HC_AutoVtas
		call	AutoThrottle

		ret

CtrlTrack	ENDP

;----------------------------------------------------------------------------

;* CtrlApproach - final approach
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

CtrlApproach	PROC	NEAR

		call	AutoRoute

		mov	ax,HC_AutoHFine
		call	AutoHeading

		mov	ax,100
		call	AutoAltitude

;* if within stopping dist then
;*    aiming vtas = 0kts
;* else
;*    aiming vtas = 50kts
;* endif

		mov	ax,680		;assume 50kts
	
		cmp	WORD PTR HC_WPRng+2,0	;range > 65,535ft?
		ja	@F			;yes ->
		cmp	WORD PTR HC_WPRng,361	;within stopping dist?
		ja	@F			;no ->

		xor	ax,ax			;decelerate to hover

@@:		call	AutoThrottle
		
;* if hovering then switch to touchdown mode

		mov	ax,HC_Data.HC_VTAS
		or	ax,HC_Data.HC_VTAS_FINE
		jnz	@F

		mov	HC_Data.HC_CTRL_MODE,CTRL_TOUCHDOWN

@@:		ret

CtrlApproach	ENDP

;----------------------------------------------------------------------------

;* CtrlTouchDown - descend and touchdown
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

CtrlTouchDown	PROC	NEAR

;* if zft = 0 then touched down

		mov	ax,HC_Data.HC_ZFINE
		or	ax,WORD PTR HC_View.VP_ZFT_LO
		jnz	ContTouchDown

;* check for restart mission or stop

		mov	si,HC_Data.HC_WP_PTR

		mov	ax,CTRL_NULL	;assume stopping
		
		cmp	WP_ACTION[si],HC_WP_RESTART	;restart?
		jne	@F				;no ->

;------------------------------------------------
;* helicopter landed resupply and restart mission
;------------------------------------------------

		xor	ax,ax

		mov	HC_Data.HC_EVENT,al
		mov	HC_Data.HC_DELAY,RESUPPLY_DELAY
		mov	HC_Data.HC_DRONE_NUM,al
		mov	HC_Data.HC_EVENT_NUM,-1
		mov	HC_Data.HC_PFINE,ax
		mov	HC_Data.HC_RFINE,ax
		mov	HC_Data.HC_VTAS,ax
		mov	HC_Data.HC_VTAS_FINE,ax
		mov	HC_Data.HC_LIFT_VCTR,ax
		mov	HC_Data.HC_ACCEL_PFINE,ax

		mov	si,HelicopterPtr
		add	si,HC_WAYPOINTS+WAY_REC_SIZE	;ptr -> second waypoint
		mov	HC_Data.HC_WP_PTR,si

		mov	ax,CTRL_TAKEOFF

@@:		mov	HC_Data.HC_CTRL_MODE,ax

		jmp	ExitTouchDown

;* if zft > 10ft then
;*    accel zdot to LAND_ZDOT
;* else
;*    zdot = LAND_ZDOT / 2
;* endif

;* (note: vtas is effectively zdot)

ContTouchDown:	cmp	WORD PTR HC_View.VP_ZFT_HI,0	;zft > 65,535ft?
		ja	@F				;yes ->
	       	cmp	WORD PTR HC_View.VP_ZFT_LO,10	;zft > 10ft?
	       	jbe	DecelTouchDown			;yes ->

@@:		cmp	HC_Data.HC_VTAS,LAND_ZDOT	;reached steady state zdot?
		je	LandZDotOk	  		;yes ->

		mov	ax,LAND_ZDOT/4	;accel = steady state zdot / 4
		mov	dx,DeltaTime
		imul	dx

		shl	ax,1		;adjust after fractional multiply
		rcl	dx,1

		add	HC_Data.HC_VTAS_FINE,ax
		adc	HC_Data.HC_VTAS,dx

		cmp	HC_Data.HC_VTAS,LAND_ZDOT	;reached steady state zdot?
		jb	LandZDotOk			;no ->

		mov	HC_Data.HC_VTAS,LAND_ZDOT
		mov	HC_Data.HC_VTAS_FINE,0

		jmp	LandZDotOk

;* decelerate just prior to touchdown

DecelTouchDown:	mov	HC_Data.HC_VTAS,LAND_ZDOT/2
		mov	HC_Data.HC_VTAS_FINE,0

LandZDotOk:  	mov	HC_Data.HC_LIFT_VCTR,-128*128	;-90degs

ExitTouchDown:	ret

CtrlTouchDown	ENDP

;----------------------------------------------------------------------------

;* AutoRoute - fly from waypoint to waypoint
;*
;* pass: nothing
;* ret : HC_AutoHFine
;*       HC_AutoAlt
;*       HC_AutoVtas
;* kill: assume all
;*
;* note: This routine sets up parameters for AutoHeading and AutoAltitude
;*       so call AutoRoute before calling these routines.

AutoRoute	PROC	NEAR

;---------------------------------
;* assume heading change inhibited (restore previous value)
;---------------------------------

		mov	ax,HC_Data.HC_HFINE

		mov	HC_AutoHFine,ax

;-------------------------------
;* assume speed change inhibited (restore previous value)
;------------------------------

		mov	ax,HC_Data.HC_VTAS

		mov	HC_AutoVtas,ax

;--------------------------------------------
;* calc range and bearing of current waypoint
;--------------------------------------------

		mov	si,OFFSET HC_View	;si -> viewpoint
		mov	di,HC_Data.HC_WP_PTR	;di -> current waypoint
		call	CalcRngBrgVP_WP

		mov	WORD PTR HC_WPRng+2,dx
		mov	WORD PTR HC_WPRng,ax
		mov	HC_WPBrg,bx
		mov	HC_WPBrgFine,bp

;---------------------
;* satisfied waypoint?
;---------------------

		mov	si,HC_Data.HC_WP_PTR

		test	WP_ATTR[si],WP_TYPE	;turning or target waypoint?
		jnz	TargetWP		;target ->

;------------------
;* turning waypoint (turn early to next waypoint to keep on track)
;------------------

		call	CalcTurnDist

		cmp	WORD PTR HC_WPRng+2,0	;range > turn dist?
		ja	WPOk			;yes ->
		cmp	WORD PTR HC_WPRng,ax	;range > turn dist?
		jae	WPOk			;yes ->

		jmp	SatisfiedWP

;-----------------
;* target waypoint (fly over waypoint)
;-----------------

TargetWP	LABEL	NEAR

;* within 1/4NM of waypoint?

;* note: This distance is less than the distance used with aircraft autoroute
;*       as helicopters fly at lower speeds.

		cmp	WORD PTR HC_WPRng+2,0
		ja	WPOk			;no ->
		cmp	WORD PTR HC_WPRng,6076/4
		jae	WPOk			;no ->

		mov	ax,HC_View.VP_HDG
		mov	dx,HC_WPBrg
		call	CalcAngDiff

		cmp	ax,128		;error > 90 degs?
		jbe	WPOk		;no ->

;--------------------
;* waypoint satisfied
;--------------------

;* if approach mode then do not advance to next waypoint

SatisfiedWP:	cmp	HC_Data.HC_CTRL_MODE,CTRL_APPROACH	;approach mode?
		je	WPOk					;yes ->

		call	SelectNextWP

;* sort waypoint action

		mov	si,HC_Data.HC_WP_PTR

		call	SortControlMode

		mov	HC_Data.HC_CTRL_MODE,dx

;--------------------------
;* set heading for waypoint (unless too close - reduce jitter)
;--------------------------

;* within 1/8NM of waypoint?

;* note: This distance is less than the distance used with aircraft autoroute
;*       as helicopters fly at lower speeds.

WPOk:		cmp	WORD PTR HC_WPRng+2,0
		ja	@F			;no ->
		cmp	WORD PTR HC_WPRng,6076/8
		jb	SortWPAlt		;yes ->

@@:		mov	ax,HC_WPBrgFine
		mov	HC_AutoHFine,ax

;------------------------
;* sort waypoint altitude
;------------------------

;* alt = min(waypoint alt, ceiling)

SortWPAlt:	mov	si,HC_Data.HC_WP_PTR
		mov	ax,WP_ZFT[si]

		mov	di,PerfDataPtr
		mov	di,PERF_CRUISE[di]

		cmp	ax,CRS_CEILING[di]	;alt < ceiling?
		jbe	SetAutoAlt		;yes ->

		mov	ax,CRS_CEILING[di]	;limit to ceiling

SetAutoAlt:	mov	HC_AutoAlt,ax

;-----------------------
;* sort helicopter speed
;-----------------------

		mov	si,HC_Data.HC_WP_PTR

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

		mov	dx,WORD PTR HC_WPRng+2
		mov	ax,WORD PTR HC_WPRng

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

SetSpeed:	mov	HC_AutoVtas,ax

ExitRoute:	ret

SetMaxSpeed:	mov	ax,32767

		jmp	SetSpeed

AutoRoute	ENDP

;----------------------------------------------------------------------------

;* SelectNextWP - select next waypoint
;*
;* pass: HC_Data.HC_WP_PTR
;* ret : HC_Data.HC_WP_PTR -> next waypoint
;* kill: assume all

SelectNextWP	PROC	NEAR

		mov	si,HC_Data.HC_WP_PTR
		call	CalcNextWP	  	;di -> next waypoint
		mov	HC_Data.HC_WP_PTR,di

;* update waypoint range and bearing

		mov	si,OFFSET HC_View	;si -> viewpoint
		call	CalcRngBrgVP_WP

		mov	WORD PTR HC_WPRng,ax
		mov	WORD PTR HC_WPRng+2,dx
		mov	HC_WPBrg,bx
		mov	HC_WPBrgFine,bp

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

SortLink:	mov	di,HelicopterPtr

		add	di,HC_WAYPOINTS	;di -> first waypoint

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

		mov	si,OFFSET HC_View	;si -> viewpoint
		mov	di,HC_Data.HC_WP_PTR	;di -> current waypoint
		call	CalcRngBrgVP_WP

		mov	HC_ThetaAB,bx

;* ThetaBC = bearing of wp(C) from wp(B)

		mov	si,HC_Data.HC_WP_PTR
		call	CalcNextWP
		call	CalcRngBrgWP_WP

		mov	HC_ThetaBC,bx

;* ThetaABC = abs(256 - abs(ThetaAB - ThetaBC)) (0 .. 511 pdegs)

		mov	ax,HC_ThetaAB
		sub	ax,bx		;ThetaAB - ThetaBC
		ABSV	ax		;abs(ThetaAB - ThetaBC)

		mov	dx,ax
		mov	ax,256
		sub	ax,dx		;256 - abs(ThetaAB - ThetaBC)

		ABSV	ax		;abs(256 - abs(ThetaAB - ThetaBC))

		mov	HC_ThetaABC,ax

;-----------------------------
;* calc RTurn = turning radius
;-----------------------------

;* RTurn = min((vtas^2 / 64) * 588 / 32768, 32767)

		mov	ax,HC_Data.HC_VTAS

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

@@:		mov	HC_RTurn,dx

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

		cmp	HC_ThetaABC,128	;< 90 degs?
		jb	@F		;yes ->

;------------------------------
;* ThetaABC >= 90 degs (obtuse)
;------------------------------

		mov	ax,256
		sub	ax,HC_ThetaABC
		shr	ax,1
		call	Tangent		;dx = tan(ax) / 2 (refer to TRIG.ASM)
		shl	dx,1

		mov	ax,HC_RTurn
		mul	dx
		FRACADJ	ax

		jmp	ExitTurnDist

;----------------------------
;* ThetaABC < 90 degs (acute)
;----------------------------

@@:		mov	ax,HC_ThetaABC
		shr	ax,1
		call	Tangent		;dx = tan(ax) / 2 (refer to TRIG.ASM)
		shl	dx,1
		mov	bx,dx

		mov	dx,HC_RTurn
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
;* ret : HC_Data.HC_HFINE
;*       HC_Data.HC_RFINE
;* kill: assume all
;*
;* note: Based on the Tornado auto-pilot "auto-heading" algorithm.

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

		sub	ax,HC_Data.HC_HFINE

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

		mov	bp,HC_Data.HC_VTAS

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

ContHeading:	test	CRS_HEAVY[di],1	;heavy helicopter?
		jz	@F		;no ->

		sar	ax,1		;aiming roll / 2

@@:		sub	ax,HC_Data.HC_RFINE	;roll error

		ABSV	ax		;ax = abs(roll error), dx = sign(roll error)

;* roll rate = min(abs(error), AH_ROLL_RATE * DeltaTime / 32768) * sign(error)

		mov	bx,ax		;abs(error)
		mov	cx,dx		;sign(error)

		mov	dx,AH_ROLL_RATE

		test	CRS_HEAVY[di],1	;heavy helicopter?
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

		add	HC_Data.HC_RFINE,dx

;-------------------
;* calc heading rate
;-------------------

;* hdg rate = 520000h / vtas * sin(roll) * DeltaTime

		mov	dx,00052h
		xor	ax,ax
		div	bp		;520000h / vtas

		mov	bx,HC_View.VP_ROLL

		test	CRS_HEAVY[di],1	;heavy helicopter?
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

		add	HC_Data.HC_HFINE,dx

		ret

AutoHeading	ENDP

;----------------------------------------------------------------------------

;* AutoAltitude - fly to given altitude / terrain follow / fly glide slope
;*
;* pass: ax = aiming altitude (ft)
;* ret : HC_Data.HC_PFINE
;*       HC_Data.HC_LIFT_VCTR
;* kill: assume all
;*
;* note: Based on the Tornado auto-pilot "auto-altitude" algorithm.
;*
;*	 AutoAltitude requires current heading for terrain following algorithm
;*       so call AutoAltitude after AutoHeading.

AutoAltitude	PROC	NEAR

;-------------------------------------
;* test for terrain following override
;-------------------------------------

		mov	si,HC_Data.HC_WP_PTR

		test	WP_ATTR[si],WP_TF	;terrain follow?
		_JZ	ContAutoAlt		;no ->

;* copy viewpoint data to temporary data

		COPY_VP	TMP_VIEW,HC_View

;* calc ground height below helicopter

		mov	si,OFFSET TMP_VIEW
		call	CalcGndHeight

		push	ax		;store ground height below helicopter

;* calc delta xft and delta yft per second (wrt heading)

		mov	dx,HC_Data.HC_Vtas	;(*8 scaled)

		mov	cl,7		;/128

		mov	ax,HC_Data.HC_HFINE
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

@@:		pop	dx		;restore ground height below helicopter

		cmp	ax,dx
		jae	@F

		mov	ax,dx

@@:		mov	si,HC_Data.HC_WP_PTR

		add	ax,WP_ZFT[si]	;ground height + TF height

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

		mov	si,HC_Data.HC_WP_PTR

		test	WP_ATTR[si],WP_TF	;terrain follow?
		jz	@F			;no ->

		mov	dx,980*8	;terrain following

@@:		mov	ax,HC_Data.HC_VTAS

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

		test	CRS_HEAVY[di],1	;heavy helicopter?
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

		sub	ax,WORD PTR HC_View.VP_ZFT_LO
		sbb	dx,WORD PTR HC_View.VP_ZFT_HI

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

		sub	ax,HC_Data.HC_LIFT_VCTR	;pitch error = aiming pitch - lift vector

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

		add	ax,HC_Data.HC_LIFT_VCTR

		mov	HC_Data.HC_LIFT_VCTR,ax

		mov	HC_Data.HC_PFINE,ax

		ret

AutoAltitude	ENDP

;----------------------------------------------------------------------------

;* AutoThrottle - accelerate to given speed
;*
;* pass: ax = aiming speed (ft/sec * 8)
;* ret : HC_Data.HC_VTAS
;*       HC_Data.HC_VTAS_FINE
;* kill: assume all
;*
;* note: AutoThrottle modifies pitch value so call after AutoAltitude.

AutoThrottle	PROC	NEAR

;---------------------------
;* pick up cruise parameters
;---------------------------

		mov	di,PerfDataPtr
		mov	di,PERF_CRUISE[di]

;---------------------------------
;* limit aiming speed to max speed
;---------------------------------

		cmp	ax,CRS_MXSPEED_SL[di]	;aiming speed <= max speed?
		jbe	@F			;yes ->

		mov	ax,CRS_MXSPEED_SL[di]

;----------------------------
;* accelerate to aiming speed
;----------------------------

;* calc speed error

@@:		mov	cx,ax		;cx = aiming speed
		xor	bx,bx

		sub	bx,HC_Data.HC_VTAS_FINE	;error = aiming speed - current speed
		sbb	cx,HC_Data.HC_VTAS
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

		REPT	2		;flare (decel * 4)
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

		add	HC_Data.HC_VTAS_FINE,ax
		adc	HC_Data.HC_VTAS,dx

;----------------------
;* sort pitch wrt accel 
;----------------------

;* speed error = -speed error (pitch down to accel, pitch up to decel)
;*
;* aiming pitch = min(abs(speed error), 64 * 8) * sign(speed error) * 8 (fine pdegs)
;*
;* aiming pitch = aiming pitch - 4 * 128 (fixed pitch down attitude)
;*
;* @ max accel, pitch = -36pdegs
;* @ max decel, pitch = +28pdegs

		mov	ax,cx

		neg	ax		;accel = pitch down, decel = pitch up

		ABSV	ax		;ax = abs(speed error), dx = sign(speed error)

		cmp	ax,64*8
		jbe	@F
		mov	ax,64*8		;limit

@@:		REPT	3		;*8 (*128)
		shl	ax,1
		ENDM

		xor	ax,dx		;restore sign
		sub	ax,dx

		sub	ax,4*128	;fixed pitch down

;* adjust pitch

		sub	ax,HC_Data.HC_ACCEL_PFINE	;ax = pitch error

		ABSV	ax		;ax = abs(pitch error), dx = sign(pitch error)

		mov	bx,ax		;bx = abs(error)
		mov	cx,dx		;dx = sign(error)

		mov	ax,ACC_PITCH_RATE

		test	CRS_HEAVY[di],1	;heavy helicopter?
		jz	@F		;no ->

		shr	ax,1		;pitch rate / 2

@@:		mov	dx,DeltaTime
		imul	dx
		FRACADJ	dx

		cmp	dx,bx		;rate > error?
		jbe	@F		;no ->
		mov	dx,bx

@@:		xor	dx,cx		;restore sign
		sub	dx,cx

		add	dx,HC_Data.HC_ACCEL_PFINE

		mov	HC_Data.HC_ACCEL_PFINE,dx

		add	HC_Data.HC_PFINE,dx

		ret

AutoThrottle	ENDP

;----------------------------------------------------------------------------

;* CalcAngles - convert fine pdegs to pdegs
;*
;* pass: HC_Data.HC_HFINE
;*       HC_Data.HC_PFINE
;*       HC_Data.HC_RFINE
;* ret : HC_View.VP_HDG
;*       HC_View.VP_PITCH
;*       HC_View.VP_ROLL
;* kill: assume all

CalcAngles	PROC	NEAR

		mov	cl,7		;/128

;---------
;* heading
;---------

		mov	ax,HC_Data.HC_HFINE
		shr	ax,cl
		ROUNDUP	ax
		and	ax,001ffh
		mov	HC_View.VP_HDG,ax

;-------
;* pitch
;-------

		mov	ax,HC_Data.HC_PFINE
		shr	ax,cl
		ROUNDUP	ax
		and	ax,001ffh
		mov	HC_View.VP_PITCH,ax

;------
;* roll
;------

		mov	ax,HC_Data.HC_RFINE
		shr	ax,cl
		ROUNDUP	ax
		and	ax,001ffh
		mov	HC_View.VP_ROLL,ax

		ret

CalcAngles	ENDP

;----------------------------------------------------------------------------

;* CalcDeltaXYZ - calc delta xft, yft, zft
;*
;* pass: nothing
;* ret : ax = delta xft, HC_Data.HC_XFINE
;*       bx = delta yft, HC_Data.HC_YFINE
;*       cx = delta zft, HC_Data.HC_ZFINE
;* kill: assume all

CalcDeltaXYZ	PROC	NEAR

		mov	di,DeltaTime

;* calc speed * cos(lift)

		mov	bx,HC_Data.HC_LIFT_VCTR
		mov	cl,7
		shr	bx,cl		;/128 (convert fine pdegs to pdegs)
		ROUNDUP	bx
		and	bx,001ffh

		COSINE	dx,bx		;dx = cos(lift)

		mov	ax,HC_Data.HC_VTAS
		imul	dx
		FRACADJ	bp		;bp = speed * cos(lift)

;------------------------------------------------------
;* delta xft = speed * cos(lift) * sin(hdg) * DeltaTime
;------------------------------------------------------

		mov	bx,HC_View.VP_HDG
		
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

DxOk:		add	HC_Data.HC_XFINE,ax
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

DyOk:		add	HC_Data.HC_YFINE,ax
		adc	dx,0

		mov	bx,dx		;bx = delta yft

;------------------------------------------------
;* delta zft = speed * sin(lift fine) * DeltaTime
;------------------------------------------------

		mov	ax,HC_Data.HC_LIFT_VCTR

		push	bx		;delta yft
		push	di		;delta time
		push	bp		;delta xft
		call	CalcSineFine
		pop	bp		;delta xft
		pop	di		;delta time
		pop	bx		;delta yft

		mov	dx,HC_Data.HC_VTAS
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

DzOk:		add	HC_Data.HC_ZFINE,ax
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

		mov	si,HelicopterPtr

		cmp	WORD PTR _VP_ZFT_HI[si],0	;below ground?
		jge	@F		       		;no ->

		xor	ax,ax

		mov	WORD PTR _VP_ZFT_HI[si],ax
		mov	WORD PTR _VP_ZFT_LO[si],ax
		mov	_HC_ZFINE[si],ax

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
		cmp	WP_ACTION[si],HC_WP_TAKEOFF	;takeoff?
		je	@F				;yes ->

		mov	dx,CTRL_TRACK			;assume airborne
		cmp	WP_ACTION[si],HC_WP_AIRBORNE	;airborne?
		je	@F				;yes ->

		mov	dx,CTRL_TRACK			;default to track

@@:		ret

SortControlMode	ENDP

DRONECODE	ENDS

;============================================================================

WEAPONCODE	SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:WEAPONCODE
		ASSUME DS:DATA

;* EvasionTactics - chaff / flare if weapon lock
;*
;* pass: HelicopterPtr
;* ret : nothing
;* kill: assume all

EvasionTactics	PROC	FAR

		mov	si,HelicopterPtr

;---------------------------
;* clear chaff / flare flags
;---------------------------

		and	_HC_FLAGS[si],NOT (HFLG_REL_CHAFF+HFLG_REL_FLARE)

;----------------------
;* test for weapon lock
;----------------------

		test	_HC_FLAGS[si],HFLG_IR_LOCK+HFLG_RAD_LOCK
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

		mov	ax,_HC_DECOY_TIMER[si]
		sub	ax,LastFrame
		jnc	SetDecoyTimer

;---------------
;* release decoy
;---------------

;* release chaff (if required)

		test	_HC_FLAGS[si],HFLG_RAD_LOCK
		jz	@F

		push	si

		mov	ax,_HC_VTAS[si]
		mov	bx,CHAFF
		xor	dl,dl
		add	si,MOB_REC_SIZE		;si -> viewpoint
		call	ReleaseDecoy

		pop	si

		or	_HC_FLAGS[si],HFLG_REL_CHAFF

;* release flare (if required)

@@:		test	_HC_FLAGS[si],HFLG_IR_LOCK
		jz	@F

		push	si

		mov	ax,_HC_VTAS[si]
		mov	bx,FLARE
		xor	dl,dl
		add	si,MOB_REC_SIZE		;si -> viewpoint
		call	ReleaseDecoy

		pop	si

		or	_HC_FLAGS[si],HFLG_REL_FLARE

;* reset decoy release timer

@@:		call	RandX		;0.00 .. 2.55
		shr	ax,1		;0.00 .. 1.27
		add	ax,50		;0.50 .. 1.77

SetDecoyTimer:	mov	_HC_DECOY_TIMER[si],ax

;------------------
;* clear lock flags
;------------------

SkipEvasion:	and	_HC_FLAGS[si],NOT (HFLG_IR_LOCK+HFLG_RAD_LOCK)

		ret

EvasionTactics	ENDP

WEAPONCODE 	ENDS

;============================================================================

		END

