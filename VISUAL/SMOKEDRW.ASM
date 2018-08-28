;****************************************************************************
;*
;* SMOKEDRW.ASM
;*
;* Smoke drawing routines.
;*
;* 26.11.1992 - KJB
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	DrawSmoke
		PUBLIC	DrawSmokeObject

		EXTRN	CircleSmoke:FAR

		EXTRN	CalcEyePosition:NEAR
		EXTRN	ObjectDistSort1:NEAR
		EXTRN	ObjectDistSort2:NEAR
		EXTRN	ObjectDistSort3:NEAR
		EXTRN	ObjectDistSort4:NEAR
		EXTRN	CalcCircleCRT:NEAR

		EXTRN	CloudBase:DWORD
		
		EXTRN	CloudDepth:WORD

;============================================================================

		INCLUDE	VISEXTRN.INC
		INCLUDE	VISDATA.INC
		INCLUDE	\LIB8086\USEFUL.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

		DW	-16384
SectorAdjust	DW	0
		DW	+16384

DATA		ENDS

;============================================================================

VISCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:VISCODE
		ASSUME DS:DATA

;* DrawSmoke - test if smoke is visible, calc pos and place in object buffer
;*
;* pass: si -> SMOKE data block
;*       V_VIEW
;*       ObjectBufPtr
;* ret : cf = 0: smoke visible
;*       cf = 1: smoke non-visible
;*       ObjectBufPtr
;* kill: assume all (except cf)

FailSmoke	LABEL	NEAR

		stc			;cf = 1 = smoke non-visible
		ret

DrawSmoke	PROC	NEAR

;* any room left in object buffer?

		mov	ax,ObjectBufPtr
		cmp	ax,OFFSET ObjectBufEnd
		je	FailSmoke	;no room ->

;* delta x sec = smoke x sec - vp x sec

		mov	ax,[si].SMOKE_XSEC
		sub	ax,V_VIEW.VP_XSEC

		mov	di,ax

;* if abs(delta x sec) > 1 then smoke is non-visible

		ABSV	ax
		cmp	ax,1	  	;smoke in current or adjacent sector?
		ja	FailSmoke	;no ->

;* delta y sec = smoke y sec - vp y sec

		mov	ax,[si].SMOKE_YSEC
		sub	ax,V_VIEW.VP_YSEC

		mov	bx,ax

;* if abs(delta y sec) > 1 then smoke is non-visible

		ABSV	ax
		cmp	ax,1	  	;smoke in current or adjacent sector?
		ja	FailSmoke	;no ->

;* x rel = smoke xft - vp xft + (delta x sec * 16384)

		shl	di,1		;-2, 0, +2

		mov	ax,[si].SMOKE_XFT
		sub	ax,V_VIEW.VP_XFT
		add	ax,SectorAdjust[di]

		cmp	ax,-16384	;in range?
		jl	FailSmoke	;no ->
		cmp	ax,+16383	;in range?
		jg	FailSmoke	;no ->

		mov	bp,ax		;bp = x rel

;* y rel = smoke yft - vp yft + (-(delta y sec) * 16384)

		shl	bx,1		;-2, 0, +2

		mov	ax,[si].SMOKE_YFT
		sub	ax,V_VIEW.VP_YFT
		sub	ax,SectorAdjust[bx]

		cmp	ax,-16384	;in range?
		jl	FailSmoke	;no ->
		cmp	ax,+16383	;in range?
		jg	FailSmoke	;no ->

		mov	bx,ax		;bx = y rel

;* z rel = smoke zft - vp zft (compressed)

		mov	cx,WORD PTR [si].SMOKE_ZFT_LO
		mov	ax,WORD PTR [si].SMOKE_ZFT_HI

		sub	cx,WORD PTR V_VIEW.VP_ZFT_LO
		sbb	ax,WORD PTR V_VIEW.VP_ZFT_HI

		cwd			;dx = sign(z rel)

		jns	@F

		NEG32	ax,cx

;* compress z rel (assume abs(z rel) <= 100,000)

@@:		test	ax,ax		;abs(z rel) > 65535?
		jnz	@F		;yes ->

		cmp	cx,10000	;abs(z rel) > 10000?
		jbe	ZRelOk		;no ->

@@:		REPT	2		;abs(z rel) / 4
		shr	ax,1
		rcr	cx,1
		ENDM

		add	cx,7500		;abs(z rel) / 4 + 7500

		cmp	cx,+16383	;in range?
		ja	FailSmokeLink	;no ->

ZRelOk:		xor	cx,dx		;restore sign
		sub	cx,dx

		mov	ax,bp		;ax = x rel

		jmp	CalcPos

;--------------------------------
FailSmokeLink:	jmp	FailSmoke
;--------------------------------

;* calc eye co-ords

CalcPos:	push	si
		call	CalcEyePosition
		pop	si

;* check y pos in range (prevent dist sort overflow)

		cmp	bx,1		;ahead?
		jl	FailSmokeLink	;no ->
		cmp	bx,+16383	;in range?
		jg	FailSmokeLink	;no ->

;* check x pos in range

		cmp	ax,-16384	;in range?
		jl	FailSmokeLink	;no ->
		cmp	ax,+16383	;in range?
		jg	FailSmokeLink	;no ->

;* check z pos in range

		cmp	cx,-16384	;in range?
		jl	FailSmokeLink	;no ->
		cmp	cx,+16383	;in range?
		jg	FailSmokeLink	;no ->

;* sort smoke data

		mov	di,ObjectBufPtr

		mov	[di].OBJ_XPOS,ax
		mov	[di].OBJ_YPOS,bx
		mov	[di].OBJ_ZPOS,cx

		mov	[di].OBJ_TYPE,OTYPE_SMOKE

		mov	ax,[si].SMOKE_RFT
		mov	[di].OBJ_SMOKE_RFT,ax

		mov	al,[si].SMOKE_COL
		mov	[di].OBJ_SMOKE_COL,al

;* sort smoke distance (select distance sort wrt clouds)

 	     	mov	ax,WORD PTR [si].SMOKE_ZFT_LO
		mov	dx,WORD PTR [si].SMOKE_ZFT_HI

		sub	ax,WORD PTR CloudBase
		sbb	dx,WORD PTR CloudBase+2

		jb	BelowClouds	;below clouds ->

		sub	ax,CloudDepth
		sbb	dx,0

		jb	InClouds	;in clouds ->

AboveClouds:	mov	dx,bx
		call	ObjectDistSort3
		jmp	Sorted

InClouds:	mov	dx,bx
		call	ObjectDistSort2
		jmp	Sorted

BelowClouds:	mov	dx,bx
		call	ObjectDistSort1

Sorted:		add	di,OBJ_REC_SIZE

		mov	ObjectBufPtr,di	;update object buffer pointer
		
		clc			;cf = 0 = smoke visible
		ret

DrawSmoke	ENDP

;----------------------------------------------------------------------------

;* DrawSmokeObject - draw smoke object
;*
;* pass: si -> OBJECTDATA record
;* ret : cf = 0 = ok
;*       cf = 1 = error
;* kill: assume all

DrawSmokeObject	PROC	NEAR

;-----------------------
;* project circle centre
;-----------------------

		mov	ax,[si].OBJ_XPOS
		mov	Xe[0],ax
		mov	ax,[si].OBJ_YPOS
		mov	Ye[0],ax
		mov	ax,[si].OBJ_ZPOS
		mov	Ze[0],ax

		push	si
		call	CalcCircleCRT
		pop	si
		jc	ExitSmokeObject	;error ->

;-----------------------
;* project circle radius
;-----------------------

;* note: Calc radius using y crt as this axis is not distorted due to aspect
;*       ratio correction. The circle fill routine rejects circles with a
;*       radius <= zero so no checks need to be made.

		push	bx		;store centre y crt
		push	cx		;store centre x crt

		mov	ax,[si].OBJ_XPOS
		mov	Xe[0],ax
		mov	ax,[si].OBJ_YPOS
		mov	Ye[0],ax
		mov	ax,[si].OBJ_ZPOS

		sub	ax,[si].OBJ_SMOKE_RFT

		mov	Ze[0],ax

		push	si
		call	CalcCircleCRT
		pop	si

		mov	dx,bx		;y crt radius

		pop	cx		;restore centre x crt
		pop	bx		;restore centre y crt

		jc	ExitSmokeObject	;error ->

		sub	dx,bx		;calc radius

		mov	al,[si].OBJ_SMOKE_COL
		call	CircleSmoke	

		clc			;cf = 0 = ok

ExitSmokeObject:ret    	

DrawSmokeObject	ENDP

VISCODE		ENDS

;============================================================================

		END

