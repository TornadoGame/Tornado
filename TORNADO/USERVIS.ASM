;****************************************************************************
;*
;* USERVIS.ASM
;*
;* User visual routine (visual breakout box).
;*
;* Customise the visual in this routine.
;*
;* 28.08.1991 - KJB
;* 22.06.1992 - KJB - New mobile object scan added.
;* 10.12.1992 - KJB - SwitchOnLights added.
;* 06.03.1993 - KJB - Two player added.
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	UserVisual
		PUBLIC	SwitchOnLights

		EXTRN	LocateMobiles:FAR
		EXTRN	RxOpponentData:FAR

		EXTRN	DrawMobile:NEAR
		EXTRN	DrawWeapons:NEAR

		EXTRN	M_MOBILE:WORD
		EXTRN	SectorTable:WORD
		EXTRN	SectorDataStart:WORD

		EXTRN	InCockpit:BYTE
		EXTRN	Night:BYTE
		EXTRN	Fog:BYTE
		EXTRN	RxFlag:BYTE

;============================================================================

		INCLUDE	MAINDATA.INC

		INCLUDE	\VISUAL\VISEXTRN.INC
		INCLUDE	\VISUAL\VISDATA.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

DATA		ENDS

;============================================================================

VISCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:VISCODE
		ASSUME DS:DATA

;* UserVisual - customised visual routine
;*
;* pass: RxFlag (two player)
;* ret : nothing
;* kill: assume all

UserVisual	PROC	NEAR

;------------------------------------------
;* receive opponent data in two player game
;------------------------------------------

;* note: Receive opponent data here (as late as possible in control loop) to
;*       allow as much time as possible between transmitting Tornado data and
;*       receiving opponent data.

		test	RxFlag,1
		jz	@F

		call	RxOpponentData

;---------------------
;* draw mobile objects
;---------------------

;* for y sector offset = -1 to +1

@@:		mov	cx,3		;y count
		mov	di,-1		;y sector offset

ScanYLoop:	push	cx
		push	di

;* for x sector offset = -1 to +1

		mov	cx,3		;x count
		mov	si,-1		;x sector offset

ScanXLoop:	push	cx
		push	si
		push	di

;* calc sector map co-ords

		mov	ax,V_VIEW.VP_XSEC
		add	ax,si		;x sec = vp x sec + x sec offset
		mov	dx,V_VIEW.VP_YSEC
		add	dx,di		;y sec = vp y sec + y sec offset

;* draw mobiles in sector (if any)

		call	LocateMobiles
		jc	SkipSector	;no mobiles located ->

MobLoop:	cmp	si,-1		;list terminator?
		je	SkipSector	;yes ->

		cmp	si,OFFSET M_MOBILE	;Tornado?
		jne	ContMob			;no ->
		
		test	InCockpit,1	;external view?
		jnz	NextMob		;no ->

ContMob:	push	si
		call	DrawMobile
		pop	si

NextMob:	mov	si,MOB_LINK_PTR[si]

		jmp	MobLoop

;* next x sector

SkipSector:	pop	di
		pop	si
		pop	cx
		add	si,1		;x = x + 1
		loop	ScanXLoop

;* next y sector

		pop	di
		pop	cx
		add	di,1		;y = y + 1
		loop	ScanYLoop

;--------------
;* draw weapons
;--------------

		call	DrawWeapons

		ret

UserVisual	ENDP

;----------------------------------------------------------------------------

;* SwitchOnLights - switch on night lighting
;*
;* pass: Night
;*       Fog
;* ret : nothing
;* kill: assume all

SwitchOnLights	PROC	FAR

		mov	al,Night	;night or foggy?
		or	al,Fog
		jz	ExitSwitchOn	;no ->

		mov	cx,256			;illuminate 256 sectors

		mov	si,OFFSET SectorTable

		mov	ax,SEG SectorDataStart
		mov	es,ax

SwitchOnLoop:  	mov	di,[si].SEC_OBJ_PTR

@@:		cmp	BYTE PTR ES:[di],-1	;end of list?
		je	@F			;yes ->

		or	BYTE PTR ES:[di+1],OBJECT_LIGHTS

		add	di,4

		jmp	@B

@@:		add	si,SEC_REC_SIZE

		loop	SwitchOnLoop

		mov	ax,DATA
		mov	es,ax

ExitSwitchOn:	ret

SwitchOnLights	ENDP

VISCODE		ENDS

;============================================================================

		END

