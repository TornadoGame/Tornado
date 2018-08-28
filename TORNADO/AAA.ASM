;****************************************************************************
;*
;* AAA.ASM
;*
;* AAA gameplay control.
;*	        
;* 25.02.1993 - KJB
;*
;* Notes
;* ÄÄÄÄÄ
;*    AAA is focused on the Tornado. Firing AAA at all aircraft would consume
;*    too much of the limited weapon resources.
;*
;*    It would be unusual to encounter more than two AAA sources per sector,
;*    and AAA range is limited to one sector. Therefore only two active AAA
;*    sources are supported.
;*
;*    AAA data is gathered by the RWR avionics routine. This data is always
;*    valid even though the RWR may be damaged. The RWR data may lag by a
;*    frame as the avionics update appears near the end of the control loop,
;*    but this should have no detrimental effects.
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	UpdateAAA

		EXTRN	RandX:FAR
		EXTRN	CalcSlantRange:FAR
		EXTRN	CalcIntercept:FAR
		EXTRN	CalcRngBrgVP_VP:FAR
		EXTRN	FastArcTan:FAR
		EXTRN	MakeSmokeEffect:FAR

		EXTRN	FireCannon:NEAR

		EXTRN	LastFrame:WORD
		EXTRN	NumRWRThreats:WORD
		EXTRN	ModelMapIndex:WORD
		EXTRN	Vtas:WORD
		EXTRN	TornadoOppPtr:WORD

		EXTRN	NoFire:BYTE
		EXTRN	RWRThreatFlags:BYTE
		EXTRN	SctrGameLayer1:BYTE
		EXTRN	MSctrDataStart:BYTE
		EXTRN	ECMActive:BYTE

		EXTRN	MUZZLE_VELOCITY:ABS

;============================================================================

		INCLUDE	MAINDATA.INC

		INCLUDE	\VISUAL\VISDATA.INC

		INCLUDE	\LIB8086\USEFUL.INC

;============================================================================

		EXTRN	M_VIEW:VIEWPOINT

		EXTRN	RWRThreats:RADARS

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

AAA_BURST_LEN	EQU	2*100	 	;AAA burst length (secs * 100)

AAA_FLOOR	EQU	100		;(ft)
AAA_CEILING	EQU	12000		;(ft)

AAAMode1	DB	0		;0 = passive, 1 = active
AAAMode2	DB	0		;0 = passive, 1 = active

AAATimer1	DW	1*100		;(arbitrary start value) (secs * 100)
AAATimer2	DW	2*100		;(arbitrary start value) (secs * 100)

AAAPtr1		DW	-1		;ptr -> STAT_MOB <>
AAAPtr2		DW	-1		;ptr -> STAT_MOB <>

SourcePtr	DW	-1
MobilePtr	DW	-1

AAA_VIEW1	VIEWPOINT <0,0,0,0,8>	;AAA source 1 (zft preset to 8ft)
AAA_VIEW2	VIEWPOINT <0,0,0,0,8>	;AAA source 2 (zft preset to 8ft)

AIM_VIEW	VIEWPOINT <>

DATA		ENDS

;============================================================================

WEAPONCODE	SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:WEAPONCODE
		ASSUME DS:DATA

;* CALC_RND_PERIOD - calc random passive period
;*
;* pass: nothing
;* ret : ax = period (secs * 100)
;* kill: flags

CALC_RND_PERIOD	MACRO
		LOCAL	skip

		call	RandX		;0.00 .. 2.55 secs
		add	ax,2*100	;2.00 .. 4.55 secs

;* reduce AAA activity if Tornado emitting ECM

		test	ECMActive,1
		jz	skip

		add	ax,2*100	;4.00 .. 6.55 secs

skip:

		ENDM

;----------------------------------------------------------------------------

;* UpdateAAA
;*
;* pass: nothing
;* ret : nothing
;* kill: assume

UpdateAAA	PROC	FAR

;--------------------------------
;* check for hostile fire inhibit
;--------------------------------

		test	NoFire,1
		_JNZ	AAAExit

;-----------------------------------
;* check Tornado not in close combat
;-----------------------------------

;* check valid opponent

		cmp	TornadoOppPtr,-1
		je	@F

;* check same sector

		mov	si,TornadoOppPtr

		mov	ax,M_VIEW.VP_XSEC
		cmp	ax,_VP_XSEC[si]
		jne	@F

		mov	ax,M_VIEW.VP_YSEC
		cmp	ax,_VP_YSEC[si]
		jne	@F

		jmp	AAAExit

@@:

;---------------------------
AAASource1	LABEL	NEAR		;update AAA source 1
;---------------------------

;* check if AAA source active

		test	AAAMode1,1
		jz	AAAPassive1

;---------------------------
AAAActive1	LABEL	NEAR		;update active AAA source
;---------------------------

		mov	si,OFFSET AAA_VIEW1
		mov	di,AAAPtr1
		call	AAAFire

		mov	ax,AAATimer1
		sub	ax,LastFrame
		MINM	ax
		jnz	@F		;burst in progress ->

;* switch to passive mode (set random passive period)

		mov	AAAMode1,0	;passive mode

		CALC_RND_PERIOD

@@:		mov	AAATimer1,ax

		jmp	AAASource2

;---------------------------
AAAPassive1	LABEL	NEAR		;update passive AAA source
;---------------------------

;* check AAA illuminated on RWR

		test	RWRThreatFlags,RWR_AAA
		_JZ	AAASource2

;* check Tornado below AAA ceiling

		cmp	WORD PTR M_VIEW.VP_ZFT_HI,0
		_JA	AAASource2
		cmp	WORD PTR M_VIEW.VP_ZFT_LO,AAA_CEILING
		_JA	AAASource2

;* check Tornado above AAA floor

		cmp	WORD PTR M_VIEW.VP_ZFT_LO,AAA_FLOOR
		_JB	AAASource2

;* update timer

		mov	ax,AAATimer1
		sub	ax,LastFrame
		MINM	ax
		mov	AAATimer1,ax

		_JNZ	AAASource2	;still passive ->

;* check Tornado on active map

		cmp	ModelMapIndex,-1
		je	AAASkip1

;* check enemy AAA in sector

		mov	bp,ModelMapIndex

		test	SctrGameLayer1[bp],SECT_ENEMY
		jz	AAASkip1

		test	SctrGameLayer1[bp],SECT_AAA
		jz	AAASkip1

;* scan RWR for AAA

		mov	cx,NumRWRThreats
		jcxz	AAASkip1

		mov	ax,M_VIEW.VP_XSEC
		mov	dx,M_VIEW.VP_YSEC

		xor	bp,bp

AAAScanLoop1:	cmp	RWRThreats[bp].RWR_THREAT,THREAT_AAA
		jne	AAANext1

;* check same sector as Tornado

		cmp	ax,RWRThreats[bp].RWR_XSEC
		jne	AAANext1

		cmp	dx,RWRThreats[bp].RWR_YSEC
		jne	AAANext1

;* fetch xft, yft

		mov	si,RWRThreats[bp].RWR_XFT
		mov	di,RWRThreats[bp].RWR_YFT

;* if AAA source 2 is active then check not same source

		test	AAAMode2,1
		jz	AAALocated1

		cmp	ax,AAA_VIEW2.VP_XSEC
		jne	AAALocated1

		cmp	dx,AAA_VIEW2.VP_YSEC
		jne	AAALocated1

		cmp	si,AAA_VIEW2.VP_XFT
		jne	AAALocated1

		cmp	di,AAA_VIEW2.VP_YFT
		jne	AAALocated1

;* next threat

AAANext1:	add	bp,RWR_REC_SIZE

		loop	AAAScanLoop1

;* AAA not located, remain passive

AAASkip1:	CALC_RND_PERIOD

		mov	AAATimer1,ax

		jmp	AAASource2

;* AAA located, set source position and switch to active

AAALocated1:	mov	AAA_VIEW1.VP_XSEC,ax
		mov	AAA_VIEW1.VP_YSEC,dx
		mov	AAA_VIEW1.VP_XFT,si
		mov	AAA_VIEW1.VP_YFT,di

		mov	ax,RWRThreats[bp].RWR_PTR
		mov	AAAPtr1,ax

		mov	AAAMode1,1

		mov	AAATimer1,AAA_BURST_LEN

;* create some smoke

		mov	bx,SMOKE_CRATER2
		mov	si,OFFSET AAA_VIEW1
		call	MakeSmokeEffect

;---------------------------
AAASource2	LABEL	NEAR		;update AAA source 2
;---------------------------

;* check if AAA source active

		test	AAAMode2,1
		jz	AAAPassive2

;---------------------------
AAAActive2	LABEL	NEAR		;update active AAA source
;---------------------------

		mov	si,OFFSET AAA_VIEW2
		mov	di,AAAPtr2
		call	AAAFire

		mov	ax,AAATimer2
		sub	ax,LastFrame
		MINM	ax
		jnz	@F		;burst in progress ->

;* switch to passive mode (set random passive period)

		mov	AAAMode2,0	;passive mode

		CALC_RND_PERIOD

@@:		mov	AAATimer2,ax

		jmp	AAAExit

;---------------------------
AAAPassive2	LABEL	NEAR		;update passive AAA source
;---------------------------

;* check AAA illuminated on RWR

		test	RWRThreatFlags,RWR_AAA
		_JZ	AAAExit

;* check Tornado below AAA ceiling

		cmp	WORD PTR M_VIEW.VP_ZFT_HI,0
		_JA	AAAExit
		cmp	WORD PTR M_VIEW.VP_ZFT_LO,AAA_CEILING
		_JA	AAAExit

;* check Tornado above AAA floor

		cmp	WORD PTR M_VIEW.VP_ZFT_LO,AAA_FLOOR
		_JB	AAAExit

;* update timer

		mov	ax,AAATimer2
		sub	ax,LastFrame
		MINM	ax
		mov	AAATimer2,ax

		_JNZ	AAAExit		;still passive ->

;* check Tornado on active map

		cmp	ModelMapIndex,-1
		je	AAASkip2

;* check enemy AAA in sector

		mov	bp,ModelMapIndex

		test	SctrGameLayer1[bp],SECT_ENEMY
		jz	AAASkip2

		test	SctrGameLayer1[bp],SECT_AAA
		jz	AAASkip2

;* scan RWR for AAA

		mov	cx,NumRWRThreats
		jcxz	AAASkip2

		mov	ax,M_VIEW.VP_XSEC
		mov	dx,M_VIEW.VP_YSEC

		xor	bp,bp

AAAScanLoop2:	cmp	RWRThreats[bp].RWR_THREAT,THREAT_AAA
		jne	AAANext2

;* check same sector as Tornado

		cmp	ax,RWRThreats[bp].RWR_XSEC
		jne	AAANext2

		cmp	dx,RWRThreats[bp].RWR_YSEC
		jne	AAANext2

;* fetch xft, yft

		mov	si,RWRThreats[bp].RWR_XFT
		mov	di,RWRThreats[bp].RWR_YFT

;* if AAA source 1 is active then check not same source

		test	AAAMode1,1
		jz	AAALocated2

		cmp	ax,AAA_VIEW1.VP_XSEC
		jne	AAALocated2

		cmp	dx,AAA_VIEW1.VP_YSEC
		jne	AAALocated2

		cmp	si,AAA_VIEW1.VP_XFT
		jne	AAALocated2

		cmp	di,AAA_VIEW1.VP_YFT
		jne	AAALocated2

;* next threat

AAANext2:	add	bp,RWR_REC_SIZE

		loop	AAAScanLoop2

;* AAA not located, remain passive

AAASkip2:	CALC_RND_PERIOD

		mov	AAATimer2,ax

		jmp	AAAExit

;* AAA located, set source position and switch to active

AAALocated2:	mov	AAA_VIEW2.VP_XSEC,ax
		mov	AAA_VIEW2.VP_YSEC,dx
		mov	AAA_VIEW2.VP_XFT,si
		mov	AAA_VIEW2.VP_YFT,di

		mov	ax,RWRThreats[bp].RWR_PTR
		mov	AAAPtr2,ax

		mov	AAAMode2,1

		mov	AAATimer2,AAA_BURST_LEN

;* create some smoke

		mov	bx,SMOKE_CRATER2
		mov	si,OFFSET AAA_VIEW2
		call	MakeSmokeEffect

AAAExit: 	ret

UpdateAAA	ENDP

;----------------------------------------------------------------------------

;* AAAFire - fire cannon shell at Tornado
;*
;* pass: si -> AAA source
;*       di -> STAT_MOB <>
;* ret : nothing
;* kill: assume all

AAAFire		PROC	NEAR

		mov	SourcePtr,si
		mov	MobilePtr,di

;------------------
;* calc slant range (source -> Tornado)
;------------------

		mov	di,OFFSET M_VIEW
		call	CalcSlantRange

;----------------------
;* calc intercept point
;----------------------

		mov	bx,MUZZLE_VELOCITY
		mov	cx,Vtas
		mov	si,OFFSET M_VIEW
		mov	di,OFFSET AIM_VIEW
		call	CalcIntercept

;-----------------------------
;* calc flat range and bearing (source -> intercept point)
;-----------------------------

		mov	si,SourcePtr
		mov	di,OFFSET AIM_VIEW
		call	CalcRngBrgVP_VP

;-------------------------------------------
;* calc hdg and pitch angles to aiming point
;-------------------------------------------

		mov	si,SourcePtr

;* hdg = brg

		mov	[si].VP_HDG,bx

;* rotate object

		mov	di,MobilePtr

		mov	bp,SEG MSctrDataStart
		mov	ds,bp
		mov	[di].STAT_HDG,bx
		mov	bp,DATA
		mov	ds,bp

;* calc pitch
;*
;* select zft
;* case = range
;*    pitch = 45ø
;* case < range
;*    pitch = arctan(zft / range)
;* case > range
;*    pitch = 90ø - arctan(range / zft)
;* endselect

;* if range > 65535ft then no fire (too far)

		cmp	dx,0
		ja	AAAFireExit

;* if zft > 65535ft then no fire (too high)

		cmp	WORD PTR AIM_VIEW.VP_ZFT_HI,0
		ja	AAAFireExit
		
		mov	bx,ax		;bx = range

		mov	ax,WORD PTR AIM_VIEW.VP_ZFT_LO

		cmp	ax,bx		;select zft

		jb	CalcAAAPitch1	;case < range ->
		ja	CalcAAAPitch2	;case > range ->

		mov	ax,64		;ideal pitch = 45ø

		jmp	SetAAAPitch

;* pitch = arctan(zft / range)

CalcAAAPitch1:	mov	dx,ax
		xor	ax,ax

		shr	dx,1		;/2 for bin frac result
		rcr	ax,1

		div	bx

		call	FastArcTan

;* convert fine degs to pdegs

		mov	cl,7
		shr	ax,cl
		ROUNDUP	ax
		and	ax,001ffh

		jmp	SetAAAPitch

;* pitch = 90ø - arctan(range / zft)

CalcAAAPitch2:	mov	dx,bx
		mov	bx,ax
		xor	ax,ax

		shr	dx,1		;/2 for bin frac result
		rcr	ax,1

		div	bx

		call	FastArcTan

		mov	dx,128*128
		xchg	ax,dx

		sub	ax,dx

;* convert fine degs to pdegs

		mov	cl,7
		shr	ax,cl
		ROUNDUP	ax
		and	ax,001ffh

SetAAAPitch:	mov	[si].VP_PITCH,ax

;-------------
;* fire cannon
;-------------

		xor	ax,ax		;static

		xor	dl,dl		;drone fire

		mov	dh,LHS_CANNON+RHS_CANNON

		mov	di,-1		;not mobile

		call	FireCannon

AAAFireExit:	ret

AAAFire		ENDP

WEAPONCODE 	ENDS

;============================================================================

		END

