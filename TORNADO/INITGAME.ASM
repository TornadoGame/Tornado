;****************************************************************************
;*
;* INITGAME.ASM
;*
;* Initialize data passed from mission planning and gameplay data.
;*
;* 02.04.1992 - KJB
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	InitGame

		EXTRN	CreateMobile:FAR
		EXTRN	InitPlanes:FAR
		EXTRN	InitHelicops:FAR
		EXTRN	InitConvoys:FAR
		EXTRN	InitWeapons:FAR

		EXTRN	WPPtr:WORD
		EXTRN	EndWPPtr:WORD
		EXTRN	WayTotal:WORD
		EXTRN	StartWaypoint:WORD
		EXTRN	WayList:WORD
		EXTRN	AirfieldList:WORD
		EXTRN	ILSData:WORD
		EXTRN	DronePtrs:WORD
		EXTRN	TornadoType:WORD

		EXTRN	SpecialLayer1:BYTE
		EXTRN	TwoPlayer:BYTE

		EXTRN	AIRFIELD_1:ABS

;============================================================================

		INCLUDE	MAINDATA.INC

		INCLUDE	\VISUAL\VISDATA.INC
		INCLUDE	\VISUAL\VISMACRO.INC
		INCLUDE	\VISUAL\RWY_TAXI.INC
		INCLUDE	\VISUAL\MOBLIST.INC

;============================================================================

		EXTRN	M_VIEW:VIEWPOINT
		EXTRN	REF_VIEW:VIEWPOINT

		EXTRN	M_MOBILE:MOBILE
		EXTRN	OPP_MOBILE:MOBILE

		EXTRN	Clock24:CLOCK

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

DATA		ENDS

;============================================================================

CODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:CODE
		ASSUME DS:DATA

;* InitGame - initialize game
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

InitGame	PROC	NEAR

;--------------
;* init weapons
;--------------

		call	InitWeapons

;--------------------
;* init waypoint data
;--------------------

;* count number of valid waypoints

		mov	si,OFFSET WayList

		xor	ax,ax		;counter = 0

@@:		test	WP_ATTR[si],WP_VALID	;waypoint in use?
		jz	SetWayTotal		;no ->

		inc	ax		;counter += 1

		add	si,WAY_REC_SIZE

		jmp	@B

SetWayTotal:	mov	WayTotal,ax

;* if StartWaypoint < WayTotal then
;*    WPPtr = OFFSET WayList + StartWaypoint * WAY_REC_SIZE
;* else
;*    WPPtr = OFFSET WayList
;* endif

		mov	si,OFFSET WayList

		mov	ax,StartWaypoint
		cmp	ax,WayTotal
		jnb	@F

		mov	dx,WAY_REC_SIZE
		mul	dx
		add	si,ax

@@:		mov	WPPtr,si

;* EndWPPtr = OFFSET WayList + max(WayTotal - 1, 0) * WAY_REC_SIZE

		mov	ax,WayTotal
		test	ax,ax
		jz	@F
		dec	ax
		mov	dx,WAY_REC_SIZE
		mul	dx
@@:		add	ax,OFFSET WayList
		mov	EndWPPtr,ax

;--------------------
;* init airfield data
;--------------------

		mov	cx,NUM_AIRFIELDS

		mov	si,OFFSET AirfieldList

InitAFLoop:	mov	bp,AF_XSEC[si]
		cmp	bp,-1		;record in use?
		je	InitNextAF	;no ->

;* fetch special sector number (AIRFIELD_1 .. AIRFIELD_N)

		mov	ax,AF_YSEC[si]

		REPT	5		;ysec * 32
		shl	ax,1
		ENDM

		add	bp,ax		;map index = xsec + ysec * 32

		mov	al,SpecialLayer1[bp]	;special number

;* ILS ptr = OFFSET ILSData + (special number - AIRFIELD_1) * ILS_REC_SIZE

		sub	al,AIRFIELD_1
		mov	ah,ILS_REC_SIZE
		mul	ah

		add	ax,OFFSET ILSData

		mov	AF_ILS_PTR[si],ax

;* clear vars

		xor	ax,ax
		mov	AF_RNG[si],ax
		mov	AF_BRG[si],ax
		mov	AF_ETA[si],ax
		mov	AF_RNG_LO[si],ax
		mov	AF_RNG_HI[si],ax

InitNextAF:	add	si,AF_REC_SIZE

		loop	InitAFLoop

;------------
;* init clock (read real-time clock if clock not set by mission planning)
;------------

		cmp	Clock24.CLK_HRS,-1	;clock set?
		jne	SkipClock		;yes ->

		xor	al,al		;assume real-time clock defective

		mov	Clock24.CLK_HRS,al
		mov	Clock24.CLK_MINS,al
		mov	Clock24.CLK_SECS,al
		mov	Clock24.CLK_100THS,al
		
		mov	ah,002h		;get real-time clock time
		int	01ah		;time of day service
		jc	SkipClock	;defective ->

;* ch = hours   (00 .. 23 BCD)
;* cl = minutes (00 .. 59 BCD)
;* dh = seconds (00 .. 59 BCD)

		mov	al,ch
		mov	ah,ch
		and	al,00fh
		REPT	4
		shr	ah,1
		ENDM
		aad
		mov	Clock24.CLK_HRS,al

		mov	al,cl
		mov	ah,cl
		and	al,00fh
		REPT	4
		shr	ah,1
		ENDM
		aad
		mov	Clock24.CLK_MINS,al

		mov	al,dh
		mov	ah,dh
		and	al,00fh
		REPT	4
		shr	ah,1
		ENDM
		aad
		mov	Clock24.CLK_SECS,al

;--------------------
;* init reference map
;--------------------

SkipClock:	COPY_VP	REF_VIEW,M_VIEW

;--------------
;* sort variant
;--------------

		mov	al,MOB_TORNADO1		;assume IDS / ECR variants

		cmp	TornadoType,ADV_TORNADO	;ADV variant?
		jne	@F			;no ->

		mov	al,MOB_TORNADV1

@@:		mov	M_MOBILE.MOB_NUM,al

;-----------------------
;* create Tornado mobile
;-----------------------

		mov	si,OFFSET M_MOBILE
		call	CreateMobile

;---------------------------
;* check for two player mode
;---------------------------

		test	TwoPlayer,1
		jz	@F

;* create opponent

		mov	si,OFFSET OPP_MOBILE
		call	CreateMobile

		jmp	InitGameExit

;----------------------
;* create drone mobiles
;----------------------

@@:		xor	bx,bx
		mov	cx,NUM_DRONES

CreateDroneLp:	mov	si,DronePtrs[bx]
		
		cmp	_DRONE_SIDE[si],DEAD	;active?
		je	@F			;no ->

		push	bx
		push	cx
		call	CreateMobile
		pop	cx
		pop	bx

@@:		add	bx,2

		loop	CreateDroneLp

;-----------------------------
;* init aircraft / helicopters
;-----------------------------

		call	InitPlanes

		call	InitHelicops

;----------------------------
;* init truck / train convoys
;----------------------------

		call	InitConvoys

InitGameExit:	ret

InitGame	ENDP

CODE		ENDS

;============================================================================

		END

