;****************************************************************************
;*
;* DRONELIB.ASM
;*
;* Drone routines.
;*
;* 07.02.1993 - KJB
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	GetDroneSpeed
		PUBLIC	GetDroneChaff
		PUBLIC	GetDroneFlare
		PUBLIC	GetDroneAlive
		PUBLIC	WpnKillDrone
		PUBLIC	SetDroneWpnLock
		PUBLIC	GetDroneIllum

		EXTRN	DestroyTornado:FAR
		EXTRN	DeleteMobile:FAR
		EXTRN	RandX:FAR
		EXTRN	MedDamage:FAR
		EXTRN	MaxDamage:FAR
		EXTRN	CalcRngBrgVP_VP:FAR
		EXTRN	CalcAngDiff:FAR

		EXTRN	Vtas:WORD
		EXTRN	OppVtas:WORD
		EXTRN	ShakeTimer:WORD
		EXTRN	ATruckConvoy1:WORD
		EXTRN	ATruck1_1:WORD
		EXTRN	ATruck1_4:WORD
		EXTRN	ATruckConvoy2:WORD
		EXTRN	ATruck2_1:WORD
		EXTRN	ATruck2_4:WORD
		EXTRN	ETruckConvoy1:WORD
		EXTRN	ETruck1_1:WORD
		EXTRN	ETruck1_4:WORD
		EXTRN	ETruckConvoy2:WORD
		EXTRN	ETruck2_1:WORD
		EXTRN	ETruck2_4:WORD
		EXTRN	ATrain1:WORD
		EXTRN	ATrain1_1:WORD
		EXTRN	ATrain1_8:WORD
		EXTRN	ATrain2:WORD
		EXTRN	ATrain2_1:WORD
		EXTRN	ATrain2_8:WORD
		EXTRN	ETrain1:WORD
		EXTRN	ETrain1_1:WORD
		EXTRN	ETrain1_8:WORD
		EXTRN	ETrain2:WORD
		EXTRN	ETrain2_1:WORD
		EXTRN	ETrain2_8:WORD

		EXTRN	AMobKills:BYTE
		EXTRN	EMobKills:BYTE
		EXTRN	TornadoWpnDie:BYTE
		EXTRN	NoCollisions:BYTE
		EXTRN	RelChaff:BYTE
		EXTRN	RelFlare:BYTE
		EXTRN	Destroyed:BYTE
		EXTRN	ShakePriority:BYTE
		EXTRN	HShake:BYTE
		EXTRN	VShake:BYTE
		EXTRN	OppFlags1:BYTE
		EXTRN	TwoPlayer:BYTE

		EXTRN	HSHAKE_OFF:ABS
		EXTRN	HSHAKE_LO:ABS
		EXTRN	HSHAKE_HI:ABS
		EXTRN	VSHAKE_OFF:ABS
		EXTRN	VSHAKE_LO:ABS
		EXTRN	VSHAKE_HI:ABS

;============================================================================

		INCLUDE	MAINDATA.INC
		INCLUDE	MISCMAC.INC

		INCLUDE	\VISUAL\VISDATA.INC

		INCLUDE	\LIB8086\USEFUL.INC

;============================================================================

		EXTRN	M_MOBILE:MOBILE
		EXTRN	M_VIEW:VIEWPOINT

		EXTRN	OPP_MOBILE:MOBILE

		EXTRN	WPN_Mobile:MOBILE
		EXTRN	WPN_View:VIEWPOINT
		EXTRN	WPN_Weapon:WEAPON

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

DATA		ENDS

;============================================================================

DRONECODE	SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:DRONECODE
		ASSUME DS:DATA

;* GetDroneSpeed
;*
;* pass: si -> MOBILE + VIEWPOINT + control data
;* ret : ax = speed (ft/sec * 8)
;* kill: flags

GetDroneSpeed	PROC	FAR

;--------------
;* sort Tornado
;--------------

		cmp	si,OFFSET M_MOBILE
		jne	@F

		mov	ax,Vtas

		jmp	ExitDroneSpeed

;--------------------------
;* sort two player opponent
;--------------------------

@@:		cmp	si,OFFSET OPP_MOBILE
		jne	@F

		mov	ax,OppVtas

		jmp	ExitDroneSpeed

;------------------
;* fetch drone type
;------------------

@@:		mov	ax,_DRONE_TYPE[si]

;---------------
;* sort aircraft
;---------------

		cmp	ax,DRONE_AIRCRAFT
		jne	@F

		mov	ax,_AC_VTAS[si]

		jmp	ExitDroneSpeed

;-----------------
;* sort helicopter
;-----------------

@@:		cmp	ax,DRONE_HELICOPT
		jne	@F

		mov	ax,_HC_VTAS[si]

		jmp	ExitDroneSpeed

;--------------
;* sort default
;--------------

@@:		xor	ax,ax

ExitDroneSpeed:	ret

GetDroneSpeed	ENDP

;----------------------------------------------------------------------------

;* GetDroneChaff - check if drone has release chaff this frame
;*
;* pass: si -> MOBILE + VIEWPOINT + control data
;* ret : cf = 0 = no chaff
;*       cf = 1 = chaff released
;* kill: ax, flags (except cf)

GetDroneChaff	PROC	FAR

;--------------
;* sort Tornado
;--------------

		cmp	si,OFFSET M_MOBILE
		jne	@F

		test	RelChaff,1
		jnz	SetDroneChaff

		jmp	ClrDroneChaff

;--------------------------
;* sort two player opponent
;--------------------------

@@:		cmp	si,OFFSET OPP_MOBILE
		jne	@F

		test	OppFlags1,I_REL_CHAFF
		jnz	SetDroneChaff

		jmp	ClrDroneChaff

;------------------
;* fetch drone type
;------------------

@@:		mov	ax,_DRONE_TYPE[si]

;---------------
;* sort aircraft
;---------------

		cmp	ax,DRONE_AIRCRAFT
		jne	@F

		test	_AC_FLAGS[si],AFLG_REL_CHAFF
		jnz	SetDroneChaff

		jmp	ClrDroneChaff

;-----------------
;* sort helicopter
;-----------------

@@:		cmp	ax,DRONE_HELICOPT
		jne	ClrDroneChaff

		test	_HC_FLAGS[si],HFLG_REL_CHAFF
		jnz	SetDroneChaff

ClrDroneChaff:	clc			;cf = 0 (no chaff)
		ret

SetDroneChaff:	stc			;cf = 1 (chaff released)
		ret

GetDroneChaff	ENDP

;----------------------------------------------------------------------------

;* GetDroneFlare - check if drone has release flare this frame
;*
;* pass: si -> MOBILE + VIEWPOINT + control data
;* ret : cf = 0 = no flare
;*       cf = 1 = flare released
;* kill: ax, flags (except cf)

GetDroneFlare	PROC	FAR

;--------------
;* sort Tornado
;--------------

		cmp	si,OFFSET M_MOBILE
		jne	@F

		test	RelFlare,1
		jnz	SetDroneFlare

		jmp	ClrDroneFlare

;--------------------------
;* sort two player opponent
;--------------------------

@@:		cmp	si,OFFSET OPP_MOBILE
		jne	@F

		test	OppFlags1,I_REL_FLARE
		jnz	SetDroneFlare

		jmp	ClrDroneFlare

;------------------
;* fetch drone type
;------------------

@@:		mov	ax,_DRONE_TYPE[si]

;---------------
;* sort aircraft
;---------------

		cmp	ax,DRONE_AIRCRAFT
		jne	@F

		test	_AC_FLAGS[si],AFLG_REL_FLARE
		jnz	SetDroneFlare

		jmp	ClrDroneFlare

;-----------------
;* sort helicopter
;-----------------

@@:		cmp	ax,DRONE_HELICOPT
		jne	ClrDroneFlare

		test	_HC_FLAGS[si],HFLG_REL_FLARE
		jnz	SetDroneFlare

ClrDroneFlare:	clc			;cf = 0 (no flare)
		ret

SetDroneFlare:	stc			;cf = 1 (flare released)
		ret

GetDroneFlare	ENDP

;----------------------------------------------------------------------------

;* GetDroneAlive - check if drone is still in play
;*
;* pass: si -> MOBILE + VIEWPOINT + control data
;* ret : cf = 0 = not in play (dead)
;*       cf = 1 = in play (alive)
;* kill: flags (except cf)

GetDroneAlive	PROC	FAR

;--------------
;* sort Tornado
;--------------

		cmp	si,OFFSET M_MOBILE
		jne	@F

		cmp	Destroyed,0
		je	SetDroneAlive

		jmp	ClrDroneAlive

;-----------------------------------------
;* sort all drones and two player opponent
;-----------------------------------------

@@:		cmp	_DRONE_SIDE[si],DEAD
		jne	SetDroneAlive

ClrDroneAlive:	clc		;cf = 0 (not in play)	
		ret

SetDroneAlive:	stc		;cf = 1 (in play)	
		ret

GetDroneAlive	ENDP

;----------------------------------------------------------------------------

;* WpnKillDrone - weapon destroys drone
;*
;* pass: si -> target drone MOBILE + VIEWPOINT + control data
;*	 WPN_Workspace (only call from WEAPONS.ASM)
;* ret : nothing
;* kill: assume all

WpnKillDrone	PROC	FAR

;--------------
;* sort Tornado
;--------------

		cmp	si,OFFSET M_MOBILE
		jne	SkipPlayerKill

		SHAKE	SHAKE_DAMAGE,HSHAKE_HI,VSHAKE_HI,50

;* check no collisions enabled

		test	NoCollisions,1
		_JNZ	ExitKill

;* if cannon shell then random chance of kill else sustain damage

		cmp	WPN_Weapon.WPN_TYPE,CANNON
		jne	ContPlayerKill

		test	TwoPlayer,1
		jnz	@F

;* single player

		call	RandX
		cmp	al,(2*256)/100
		jbe	ContPlayerKill

		call	MedDamage

		jmp	ExitKill

;* two player

@@:		call	RandX
		cmp	al,(10*256)/100
		jbe	ContPlayerKill

		call	MaxDamage

		jmp	ExitKill

;* look up die flag wrt weapon type

ContPlayerKill:	mov	bx,WPN_Weapon.WPN_TYPE
		shr	bx,1
		mov	al,TornadoWpnDie[bx]

		DESTROY	al,TOTAL_DAMAGE

		jmp	ExitKill

;--------------------------
;* sort two player opponent
;--------------------------

SkipPlayerKill:	cmp	si,OFFSET OPP_MOBILE
		jne	ContDroneKill

;* cannon shells do not kill opponent

		cmp	WPN_Weapon.WPN_TYPE,CANNON
		_JE	ExitKill

;-----------------
;* sort all drones
;-----------------

;* if cannon shell then random chance of kill

ContDroneKill: 	cmp	WPN_Weapon.WPN_TYPE,CANNON
		jne	@F

		call	RandX
		cmp	al,(75*256)/100
		_JBE	ExitKill

;* inc kills if Tornado weapon and enemy target

@@:		test	WPN_Weapon.WPN_FLAGS,WFLG_TORNADO
		jz	SkipKillMob

		mov	bl,[si].MOB_NUM
		xor	bh,bh

		cmp	_DRONE_SIDE[si],ENEMY
		jne	@F

		inc	EMobKills[bx]

		jmp	SkipKillMob

@@:		inc	AMobKills[bx]

SkipKillMob:

;-------------------------------
;* stop truck convoys and trains
;-------------------------------

		cmp	WORD PTR _DRONE_TYPE[si],DRONE_TRUCK
		jne	SkipKillTruck

		mov	di,OFFSET ATruckConvoy1

		cmp	si,OFFSET ATruck1_1
		jb	@F
		cmp	si,OFFSET ATruck1_4
		jbe	StopConvoy

@@:		mov	di,OFFSET ATruckConvoy2

		cmp	si,OFFSET ATruck2_1
		jb	@F
		cmp	si,OFFSET ATruck2_4
		jbe	StopConvoy

@@:		mov	di,OFFSET ETruckConvoy1

		cmp	si,OFFSET ETruck1_1
		jb	@F
		cmp	si,OFFSET ETruck1_4
		jbe	StopConvoy

@@:		mov	di,OFFSET ETruckConvoy2

		cmp	si,OFFSET ETruck2_1
		jb	@F
		cmp	si,OFFSET ETruck2_4
		jbe	StopConvoy

@@:		jmp	SkipKillTrain

SkipKillTruck:

		cmp	WORD PTR _DRONE_TYPE[si],DRONE_TRAIN
		jne	SkipKillTrain

		mov	di,OFFSET ATrain1

		cmp	si,OFFSET ATrain1_1
		jb	@F
		cmp	si,OFFSET ATrain1_8
		jbe	StopConvoy

@@:		mov	di,OFFSET ATrain2

		cmp	si,OFFSET ATrain2_1
		jb	@F
		cmp	si,OFFSET ATrain2_8
		jbe	StopConvoy

@@:		mov	di,OFFSET ETrain1

		cmp	si,OFFSET ETrain1_1
		jb	@F
		cmp	si,OFFSET ETrain1_8
		jbe	StopConvoy

@@:		mov	di,OFFSET ETrain2

		cmp	si,OFFSET ETrain2_1
		jb	@F
		cmp	si,OFFSET ETrain2_8
		jbe	StopConvoy

@@:		jmp	SkipKillTrain

StopConvoy:    	mov	[di].CNVY_ACTIVE,0
		mov	[di].CNVY_SPEED,0
		mov	[di].CNVY_AIM_SPEED,0		

SkipKillTrain:

;------------
;* kill drone
;------------

	 	mov	_DRONE_SIDE[si],DEAD

		call	DeleteMobile

ExitKill:	ret

WpnKillDrone	ENDP

;----------------------------------------------------------------------------

;* SetDroneWpnLock - set weapon locked onto drone
;*
;* pass: WPN_Workspace (only call from WEAPONS.ASM (MissileGuidance))
;* ret : nothing
;* kill: assume all

SetDroneWpnLock	PROC	FAR

		mov	si,WPN_Weapon.WPN_MISS_TGT

;--------------
;* sort Tornado (not applicable)
;--------------

		cmp	si,OFFSET M_MOBILE
		je	ExitWpnLock

;--------------------------
;* sort two player opponent (not applicable)
;--------------------------

		cmp	si,OFFSET OPP_MOBILE
		je	ExitWpnLock

;------------------
;* fetch drone type
;------------------

		mov	ax,_DRONE_TYPE[si]

;---------------
;* sort aircraft
;---------------

		cmp	ax,DRONE_AIRCRAFT
		jne	SkipACLock

		test	WPN_Weapon.WPN_FLAGS,WFLG_IR_SEEK
		jz	@F

		or	_AC_FLAGS[si],AFLG_IR_LOCK

		jmp	ExitWpnLock

@@:		or	_AC_FLAGS[si],AFLG_RAD_LOCK

		jmp	ExitWpnLock

;-----------------
;* sort helicopter
;-----------------

SkipACLock: 	cmp	ax,DRONE_HELICOPT
		jne	ExitWpnLock

		test	WPN_Weapon.WPN_FLAGS,WFLG_IR_SEEK
		jz	@F

		or	_HC_FLAGS[si],HFLG_IR_LOCK

		jmp	ExitWpnLock

@@:		or	_HC_FLAGS[si],HFLG_RAD_LOCK

ExitWpnLock:	ret
		
SetDroneWpnLock	ENDP

;----------------------------------------------------------------------------

;* GetDroneIllum - check if drone aircraft radar is illuminating Tornado
;*
;* pass: si -> MOBILE + VIEWPOINT + control data
;* ret : cf = 0 = not illuminated
;*       cf = 1 = illuminated
;* kill: assume all (except si, cf)

GetDroneIllum	PROC	FAR

;--------------
;* sort Tornado
;--------------

		cmp	si,OFFSET M_MOBILE
		je	ClrDroneIllum

;--------------------------
;* sort two player opponent
;--------------------------

		cmp	si,OFFSET OPP_MOBILE
		jne	@F

		test	OppFlags1,I_ILLUM_YOU
		jnz	SetDroneIllum

		jmp	ClrDroneIllum

;------------------
;* fetch drone type
;------------------

@@:		mov	ax,_DRONE_TYPE[si]

;---------------
;* sort aircraft
;---------------

		cmp	ax,DRONE_AIRCRAFT
		jne	ClrDroneIllum

;* check Tornado is opponent

		cmp	_AC_OPP_PTR[si],OFFSET M_MOBILE
		jne	ClrDroneIllum

;* calc range and brg of Tornado from drone aircraft

		push	si

		add	si,MOB_REC_SIZE
		mov	di,OFFSET M_VIEW
		call	CalcRngBrgVP_VP

		pop	si

;* check range < 30 miles (ensure radar illum before firing Sky Flash)

		cmp	dx,2
		ja	ClrDroneIllum
		jb	@F
		cmp	ax,06ac0h
		ja	ClrDroneIllum

;* check abs(ang diff) <= 45 degs

@@:		mov	ax,_VP_HDG[si]
		mov	dx,bx
		call	CalcAngDiff
		cmp	ax,64
		jbe	SetDroneIllum

ClrDroneIllum:	clc		;cf = 0 (not illuminated)	
		ret

SetDroneIllum:	stc		;cf = 1 (illuminated)	
		ret

GetDroneIllum	ENDP

DRONECODE	ENDS

;============================================================================

		END

