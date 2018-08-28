;****************************************************************************
;*
;* SAM.ASM
;*
;* SAM gameplay control.
;*	        
;* 26.02.1993 - KJB
;*
;* SAM vs Tornado
;* 컴컴컴컴컴컴컴
;*    SAM data is gathered by the RWR avionics routine. This data is always
;*    valid even though the RWR may be damaged. The RWR data may lag by a
;*    frame as the avionics update appears near the end of the control loop,
;*    but this should have no detrimental effects.
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	UpdateSAM
		PUBLIC SAM_VIEW
EXTRN	InCockpit:BYTE
EXTRN	LaunchSound:FAR
EXTRN	ExploSound3:FAR
		EXTRN	RandX:FAR
		EXTRN	CalcSlantRange:FAR
		EXTRN	CalcIntercept:FAR
		EXTRN	CalcRngBrgVP_VP:FAR
		EXTRN	MakeSmokeEffect:FAR

		EXTRN	LaunchMissile:NEAR

		EXTRN	CloudBase:DWORD

		EXTRN	LastFrame:WORD
		EXTRN	NumRWRThreats:WORD
		EXTRN	ActiveSAMCntr:WORD
		EXTRN	Vtas:WORD
		EXTRN	TornadoOppPtr:WORD

		EXTRN	NoFire:BYTE
		EXTRN	RWRThreatFlags:BYTE
		EXTRN	MSctrDataStart:BYTE
		EXTRN	Overcast:BYTE
		EXTRN	Fog:BYTE
		EXTRN	ECMActive:BYTE

		EXTRN	SAM_MIN_SPEED:ABS
		EXTRN	SAM_MAX_SPEED:ABS

;============================================================================

		INCLUDE	MAINDATA.INC

		INCLUDE	\VISUAL\VISDATA.INC

		INCLUDE	\LIB8086\USEFUL.INC

;============================================================================

		EXTRN	M_MOBILE:MOBILE

		EXTRN	M_VIEW:VIEWPOINT

		EXTRN	RWRThreats:RADARS

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

SAM_FLOOR	EQU	100		;(ft)
SAM_CEILING	EQU	16000		;(ft)

SAMTimer	DW	15*100		;(arbitrary start value) (secs * 100)

SAM_VIEW	VIEWPOINT <0,0,0,0,8> 	;SAM source (zft preset to 8ft)

AIM_VIEW	VIEWPOINT <>

DATA		ENDS

;============================================================================

WEAPONCODE	SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:WEAPONCODE
		ASSUME DS:DATA

;* UpdateSAM
;*
;* pass: nothing
;* ret : nothing
;* kill: assume

UpdateSAM	PROC	FAR

;------------------------------
;* check SAM illuminated on RWR
;------------------------------

		test	RWRThreatFlags,RWR_SAM
		_JZ	SAMExit

;--------------------------------
;* check for hostile fire inhibit
;--------------------------------

		test	NoFire,1
		_JNZ	SAMExit

;---------------
;* check for fog (IR guidance not suitable)
;---------------

		cmp	Fog,0
		_JNE	SAMExit

;---------------------------------------------
;* if overcast, check Tornado below cloud base
;---------------------------------------------

		test	Overcast,1
		jz	@F

	   	mov	ax,WORD PTR M_VIEW.VP_ZFT_LO
		mov	dx,WORD PTR M_VIEW.VP_ZFT_HI

		sub	ax,WORD PTR CloudBase
		sbb	dx,WORD PTR CloudBase+2

		_JAE	SAMExit

;----------------------------------
;* check if Tornado in range of SAM
;----------------------------------

;* check Tornado below SAM ceiling

@@:		cmp	WORD PTR M_VIEW.VP_ZFT_HI,0
		_JA	SAMExit
		cmp	WORD PTR M_VIEW.VP_ZFT_LO,SAM_CEILING
		_JA	SAMExit

;* check Tornado above SAM floor

		cmp	WORD PTR M_VIEW.VP_ZFT_LO,SAM_FLOOR
		_JB	SAMExit

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

		jmp	SAMExit

@@:

;-----------------------------------
;* update timer and check for launch
;-----------------------------------

		mov	ax,SAMTimer
		sub	ax,LastFrame
		MINM	ax
		mov	SAMTimer,ax

		_JNZ	SAMExit

;----------------------------
;* launch SAM against Tornado
;----------------------------

;* select random site from those available
;*
;* site num = 0 .. n = ActiveSAMCntr * rnd / 256 (do not round up)
;*
;* (assume that ActiveSAMCntr > 0 and ActiveSAMCntr < 256)

		call	RandX
		mov	dx,ActiveSAMCntr
		mul	dx
		mov	al,ah		;/256
		xor	ah,ah

;* search for site

		mov	cx,NumRWRThreats
		_JCXZ	SAMExit		;launch fail ->

		xor	bp,bp

SAMScanLoop:	cmp	RWRThreats[bp].RWR_THREAT,THREAT_SAM
		jne	@F

		test	ax,ax		;found site?
		jz	SAMLocated	;yes ->

		dec	ax

@@:		add	bp,RWR_REC_SIZE

		loop	SAMScanLoop

		jmp	SAMExit	    	;launch fail ->

;-----------------------------------------------------
;* SAM located, set source position and launch missile
;-----------------------------------------------------

SAMLocated:	mov	ax,RWRThreats[bp].RWR_XSEC
		mov	SAM_VIEW.VP_XSEC,ax

		mov	ax,RWRThreats[bp].RWR_YSEC
		mov	SAM_VIEW.VP_YSEC,ax

		mov	ax,RWRThreats[bp].RWR_XFT
		mov	SAM_VIEW.VP_XFT,ax

		mov	ax,RWRThreats[bp].RWR_YFT
		mov	SAM_VIEW.VP_YFT,ax

		push	RWRThreats[bp].RWR_PTR	;store STAT_MOB <> ptr

;* calc slant range (source -> Tornado)

		mov	si,OFFSET SAM_VIEW
		mov	di,OFFSET M_VIEW
		call	CalcSlantRange

;* calc intercept point

		mov	bx,SAM_MAX_SPEED
		mov	cx,Vtas
		mov	si,OFFSET M_VIEW
		mov	di,OFFSET AIM_VIEW
		call	CalcIntercept

;* calc flat range and bearing (source -> intercept point)

		mov	si,OFFSET SAM_VIEW
		mov	di,OFFSET AIM_VIEW
		call	CalcRngBrgVP_VP

;* set launch hdg and pitch

		mov	SAM_VIEW.VP_HDG,bx

;* note: The missile launch pitch angle is always set to 45?(as opposed to
;*       calculating the launch angle). This improves the visual effect and
;*       deliberately degrades the missile performance (especially at close
;*       range).

		mov	SAM_VIEW.VP_PITCH,64

;* rotate object

		pop	si		;restore STAT_MOB <> ptr

		mov	ax,SEG MSctrDataStart
		mov	ds,ax
		mov	[si].STAT_HDG,bx
		mov	ax,DATA
		mov	ds,ax

;* launch missile

		mov	ax,SAM_MIN_SPEED
		mov	bx,GECKO
		xor	dl,dl		;drone launch

		mov	si,OFFSET SAM_VIEW
		mov	di,OFFSET M_MOBILE

		call	LaunchMissile
		test InCockpit,1
		jnz @F
		call    LaunchSound		
@@:			
		jc	SAMExit	    	;launch fail ->

;* create some smoke

		mov	bx,SMOKE_CRATER2
		mov	si,OFFSET SAM_VIEW
		call	MakeSmokeEffect

;* reset timer

		call	RandX		; 0.00 ..  2.55
		shl	ax,1		; 0.00 ..  5.12
		shl	ax,1		; 0.00 .. 10.24
		add	ax,5*100	; 5.00 .. 15.24

;* reduce SAM activity if Tornado emitting ECM

		test	ECMActive,1
		jz	@F

		add	ax,5*100	;10.00 .. 20.24

@@:		mov	SAMTimer,ax

SAMExit: 	ret

UpdateSAM	ENDP

WEAPONCODE 	ENDS

;============================================================================

		END

