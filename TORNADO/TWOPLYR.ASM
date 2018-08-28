;****************************************************************************
;*
;* TWOPLYR.ASM
;*
;* Two player routines.
;*
;* 06.03.1993 - KJB
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	InitTwoPlayer
		PUBLIC	TxTornadoData
		PUBLIC	RxOpponentData

		PUBLIC	OPP_MOBILE
		PUBLIC	OPP_VIEW
		PUBLIC	OPP_DRONE

		PUBLIC	Tx
		PUBLIC	Rx

		PUBLIC	OppVtas		

		PUBLIC	OppFlags1	
		PUBLIC	OppFlags2	
		PUBLIC	OppFlags3	
		PUBLIC	RxFlag
		PUBLIC	TxGameEnd
		PUBLIC	RxGameEnd

		EXTRN	SendPacket:FAR
		EXTRN	ReadData:FAR
		EXTRN	DeleteMobile:FAR
		EXTRN	CreateMobile:FAR
		EXTRN	DestroyTornado:FAR
		EXTRN	MorseDotSound:FAR

		EXTRN	FireCannon:NEAR
		EXTRN	LaunchMissile:NEAR
		EXTRN	ReleaseDecoy:NEAR

		EXTRN	CountDown:WORD
		EXTRN	Vtas:WORD
		EXTRN	RadarMode:WORD
		EXTRN	NumRadarTracks:WORD
		EXTRN	AirArmMode:WORD
		EXTRN	ExtStores:WORD

		EXTRN	ECMActive:BYTE
		EXTRN	DieFlag:BYTE
		EXTRN	Ejected:BYTE
		EXTRN	Destroyed:BYTE
		EXTRN	InfiniteWeapons:BYTE

;============================================================================

		INCLUDE	MAINDATA.INC
		INCLUDE	MISCMAC.INC

		INCLUDE	\VISUAL\VISDATA.INC
		INCLUDE	\VISUAL\MOBLIST.INC

		INCLUDE	\LIB8086\USEFUL.INC

;============================================================================

		EXTRN	M_MOBILE:MOBILE
		EXTRN	M_VIEW:VIEWPOINT

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

;-----------
;* debugging
;-----------

CHECKSUM_BEEP	EQU	0		;1 = checksum error beep enabled (debugging)

;---------------------
;* two player opponent
;---------------------

;* initialise opponent position somewhere off the map

OPP_MOBILE	MOBILE <MOB_TORNADV1,OTYPE_MOBILE3,0>
OPP_VIEW 	VIEWPOINT <100,100,0,0,5000>
OPP_DRONE	DRONE_DATA <DRONE_UNKNOWN,ENEMY>

OppVtas		DW	0

OppFlags1	DB	0
OppFlags2	DB	0
OppFlags3	DB	0

		EVEN

;--------------
;* Tx / Rx data
;--------------

Tx		COMMS <>		;transmit buffer
Rx		COMMS <>		;receive buffer

;---------------
;* miscellaneous
;---------------

RxFlag		DB	0		;1 = rx opponent data in UserVisual

TxGameEnd	DB	0		;1 = tx game end flag
RxGameEnd	DB	0		;1 = rx game end flag

		EVEN

DATA		ENDS

;============================================================================

TWOCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:TWOCODE
		ASSUME DS:DATA

;* InitTwoPlayer - initialise two player
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

InitTwoPlayer	PROC	FAR

		test	InfiniteWeapons,1
		jz	@F

		mov	ExtStores[EXT_SIDEWINDER],10
		mov	ExtStores[EXT_SKYFLASH],10

@@:		ret

InitTwoPlayer	ENDP

;----------------------------------------------------------------------------

;* TxTornadoData - transmit Tornado data
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

TxTornadoData	PROC	FAR

;----------------------------------
;* prepare Tornado data to transmit
;----------------------------------

;---------------------
;* miscellaneous flags (some set previously in program loop)
;---------------------

;* emitting radar?

		cmp	RadarMode,NUL_RADAR
		je	@F

		or	Tx.COMMS_FLAGS1,I_EMIT_RADAR

;* emitting ECM?

@@:		test	ECMActive,1
		jz	@F

		or	Tx.COMMS_FLAGS1,I_EMIT_ECM

;* opponent radar visible?

@@:		cmp	NumRadarTracks,0
		je	@F

		or	Tx.COMMS_FLAGS1,I_ILLUM_YOU

;* any weapons remaining?

@@:		cmp	AirArmMode,ARM_OFF
		jne	@F

		or	Tx.COMMS_FLAGS3,I_NO_WEAPONS

;* killed? 

@@:		cmp	DieFlag,0
		je	@F

		or	Tx.COMMS_FLAGS3,I_KILLED

@@:		cmp	Destroyed,0
		je	@F

		or	Tx.COMMS_FLAGS3,I_KILLED

;* opponent killed?

@@:		cmp	OPP_DRONE.DRONE_SIDE,DEAD
		jne	@F

		or	Tx.COMMS_FLAGS3,I_KILLED_YOU

		mov	DieFlag,DIE_2_PLYR_WIN

;* ejected?

@@:		test	Ejected,1
		jz	@F

		or	Tx.COMMS_FLAGS3,I_EJECTED

;* quit?

@@:		cmp	DieFlag,DIE_QUIT
		jne	@F

		or	Tx.COMMS_FLAGS3,I_QUIT

;* sent game end flag?

@@:		cmp	Tx.COMMS_FLAGS3,0
		je	@F

		mov	TxGameEnd,1

;----------------------
;* mobile object number
;----------------------

@@:		mov	al,M_MOBILE.MOB_NUM
		mov	Tx.COMMS_MOB_NUM,al

;-------------------------
;* mobile object animation
;-------------------------

		mov	al,M_MOBILE.MOB_ANIM
		mov	Tx.COMMS_MOB_ANIM,al

;------------------
;* mobile viewpoint
;------------------

		mov	ax,M_VIEW.VP_XSEC
		mov	Tx.COMMS_XSEC,ax

		mov	ax,M_VIEW.VP_YSEC
		mov	Tx.COMMS_YSEC,ax

		mov	ax,M_VIEW.VP_XFT
		mov	Tx.COMMS_XFT,ax

		mov	ax,M_VIEW.VP_YFT
		mov	Tx.COMMS_YFT,ax

		mov	ax,WORD PTR M_VIEW.VP_ZFT_LO
		mov	WORD PTR Tx.COMMS_ZFT_LO,ax

		mov	ax,WORD PTR M_VIEW.VP_ZFT_HI
		mov	WORD PTR Tx.COMMS_ZFT_HI,ax

		mov	ax,M_VIEW.VP_HDG
		mov	Tx.COMMS_HDG,ax

		mov	ax,M_VIEW.VP_PITCH
		mov	Tx.COMMS_PITCH,ax

		mov	ax,M_VIEW.VP_ROLL
		mov	Tx.COMMS_ROLL,ax

;------
;* vtas
;------

		mov	ax,Vtas
		mov	Tx.COMMS_VTAS,ax

;---------------------
;* calc 7-bit checksum
;---------------------

		mov	cx,COMMS_REC_SIZE-1
		mov	si,OFFSET Tx+1

		xor	ah,ah

@@:		lodsb
		add	ah,al
		loop	@B

		and	ah,07fh

		mov	Tx.COMMS_CHECKSUM,ah

;-----------------------
;* transmit Tornado data
;-----------------------

		mov	cx,COMMS_REC_SIZE
		mov	si,OFFSET Tx
		call	SendPacket

;-------------
;* clear flags
;-------------

		mov	Tx.COMMS_FLAGS1,0
		mov	Tx.COMMS_FLAGS2,0
		mov	Tx.COMMS_FLAGS3,0

		ret

TxTornadoData	ENDP

;----------------------------------------------------------------------------

;* RxOpponentData - receive opponent data
;*
;* pass: nothing
;* ret : OPP_MOBILE <>
;*       OPP_VIEW <>
;* kill: assume all

RxOpponentData	PROC	FAR

;-----------------------
;* receive opponent data
;-----------------------

		mov	cx,COMMS_REC_SIZE-1
		mov	di,OFFSET Rx

		mov	CountDown,2*100

;* wait for first +ve data byte (start of data packet)

RxLoop1:	cmp	CountDown,0
		_JE	RxTimeout

		call	ReadData
		jc	RxLoop1
		test	al,al
		js	RxLoop1

		stosb

;* read rest of packet

RxLoop2:	mov	CountDown,25

@@:		cmp	CountDown,0
		_JE	RxTimeout

		call	ReadData
		jc	@B

		stosb

		loop	RxLoop2

;-----------------------
;* process opponent data
;-----------------------

;------------------
;* check data valid
;------------------

		mov	cx,COMMS_REC_SIZE-1
		mov	si,OFFSET Rx+1

		xor	ah,ah

@@:		lodsb
		add	ah,al
		loop	@B

		and	ah,07fh

		cmp	ah,Rx.COMMS_CHECKSUM
		_JNE	RxInvalid

;-----------------
;* delete opponent
;-----------------

		mov	si,OFFSET OPP_MOBILE
		call	DeleteMobile

;---------------------
;* miscellaneous flags
;---------------------

		mov	al,Rx.COMMS_FLAGS1
		mov	OppFlags1,al

		mov	al,Rx.COMMS_FLAGS2
		mov	OppFlags2,al

		mov	al,Rx.COMMS_FLAGS3
		mov	OppFlags3,al

;----------------------
;* mobile object number
;----------------------

		mov	al,Rx.COMMS_MOB_NUM
		mov	OPP_MOBILE.MOB_NUM,al

;-------------------------
;* mobile object animation
;-------------------------

		mov	al,Rx.COMMS_MOB_ANIM
		mov	OPP_MOBILE.MOB_ANIM,al

;------------------
;* mobile viewpoint
;------------------

		mov	ax,Rx.COMMS_XSEC
		mov	OPP_VIEW.VP_XSEC,ax

		mov	ax,Rx.COMMS_YSEC
		mov	OPP_VIEW.VP_YSEC,ax

		mov	ax,Rx.COMMS_XFT
		mov	OPP_VIEW.VP_XFT,ax

		mov	ax,Rx.COMMS_YFT
		mov	OPP_VIEW.VP_YFT,ax

		mov	ax,WORD PTR Rx.COMMS_ZFT_LO
		mov	WORD PTR OPP_VIEW.VP_ZFT_LO,ax

		mov	ax,WORD PTR Rx.COMMS_ZFT_HI
		mov	WORD PTR OPP_VIEW.VP_ZFT_HI,ax

		mov	ax,Rx.COMMS_HDG
		mov	OPP_VIEW.VP_HDG,ax

		mov	ax,Rx.COMMS_PITCH
		mov	OPP_VIEW.VP_PITCH,ax

		mov	ax,Rx.COMMS_ROLL
		mov	OPP_VIEW.VP_ROLL,ax

;------
;* vtas
;------

		mov	ax,Rx.COMMS_VTAS
		mov	OppVtas,ax

;-----------------
;* create opponent
;-----------------

		mov	si,OFFSET OPP_MOBILE
		call	CreateMobile

;---------------
;* process flags
;---------------

;* fire cannon

		test	OppFlags1,I_FIRE_CANNON
		jz	@F

		call	OppFireCannon

;* fire Sidewinder

@@:		test	OppFlags1,I_FIRE_AIM9L
		jz	@F

		mov	bx,SIDEWINDER
		call	OppFireMissile

;* fire Sky Flash

@@:		test	OppFlags1,I_FIRE_SKYFLASH
		jz	@F

		mov	bx,SKYFLASH
		call	OppFireMissile

;* release chaff

@@:		test	OppFlags1,I_REL_CHAFF
		jz	@F

		mov	bx,CHAFF
		call	OppRelDecoy

;* release flare

@@:		test	OppFlags1,I_REL_FLARE
		jz	@F

		mov	bx,FLARE
		call	OppRelDecoy

;* check for stalemate

@@:		test	OppFlags3,I_NO_WEAPONS
		jz	@F

		cmp	AirArmMode,ARM_OFF
		jne	@F

		mov	DieFlag,DIE_2_PLYR_DRAW

;* check for opponent killed / ejected / quit

@@:		test	OppFlags3,I_KILLED+I_EJECTED+I_QUIT
		jz	@F

		mov	DieFlag,DIE_2_PLYR_WIN

;* check for opponent killed Tornado

@@:		test	OppFlags3,I_KILLED_YOU
		jz	@F

		DESTROY	DIE_2_PLYR_LOSE,TOTAL_DAMAGE

;* received game end flag

@@:		cmp	OppFlags3,0
		je	@F

		mov	RxGameEnd,1

@@:		jmp	RxOppExit

;---------------------------
RxInvalid	LABEL	NEAR
;---------------------------

	IF	CHECKSUM_BEEP EQ 1

		call	MorseDotSound

	ENDIF

;---------------------------
RxTimeout	LABEL	NEAR
;---------------------------

;* keep position data and speed as before, but reset all flags

		mov	OppFlags1,0
		mov	OppFlags2,0
		mov	OppFlags3,0

RxOppExit:	ret

RxOpponentData	ENDP

TWOCODE		ENDS

;============================================================================

WEAPONCODE	SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:WEAPONCODE
		ASSUME DS:DATA

;* OppFireCannon
;*
;* pass: OPP_MOBILE + OPP_VIEW
;*       OppVtas
;* ret : nothing
;* kill: assume all

OppFireCannon	PROC	FAR

;* fire cannon (assume ADV)

		mov	ax,OppVtas
		xor	dl,dl
		mov	dh,RHS_CANNON
		mov	si,OFFSET OPP_VIEW
		mov	di,OFFSET OPP_MOBILE
		call	FireCannon

		ret

OppFireCannon	ENDP

;----------------------------------------------------------------------------

;* OppFireMissile
;*
;* pass: bx = missile (SIDEWINDER / SKYFLASH)
;*	 OPP_MOBILE + OPP_VIEW
;*       OppVtas
;* ret : nothing
;* kill: assume all

OppFireMissile	PROC	FAR

		mov	ax,OppVtas
		xor	dl,dl
		mov	si,OFFSET OPP_VIEW
		mov	di,OFFSET M_MOBILE
		call	LaunchMissile

		ret

OppFireMissile	ENDP

;----------------------------------------------------------------------------

;* OppRelDecoy
;*
;* pass: bx = decoy (CHAFF / FLARE)
;*	 OPP_MOBILE + OPP_VIEW
;*       OppVtas
;* ret : nothing
;* kill: assume all

OppRelDecoy	PROC	FAR

		mov	ax,OppVtas
		xor	dl,dl
		mov	si,OFFSET OPP_VIEW
		call	ReleaseDecoy

		ret

OppRelDecoy	ENDP

WEAPONCODE 	ENDS

;============================================================================

		END

