;****************************************************************************
;*
;* RNGBRG.ASM
;*
;* Calculate range and bearing.
;*
;* 17.03.1992 - KJB
;* 25.06.1992 - KJB - //BUG FIX// 
;*                    Equations of the form
;*                       y = -(ysec * 16384) + yft + 8192
;*                    changed to
;*                       y = -(ysec * 16384) + yft - 8192
;* 11.12.1992 - KJB - CalcSlantRange added.
;* 18.12.1992 - KJB - CalcRngBrg now returns FlatDx and FlatDy.
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	CalcRngBrgVP_VP
		PUBLIC	CalcRngBrgVP_WP
		PUBLIC	CalcRngBrgWP_WP
		PUBLIC	CalcRngBrgVP_AF
		PUBLIC	CalcRngBrg
		PUBLIC	CalcAngDiff
		PUBLIC	CalcNMiles
		PUBLIC	CalcETA
		PUBLIC	CalcSlantRange

		PUBLIC	FlatDx
		PUBLIC	FlatDy
		PUBLIC	SlantRng
		PUBLIC	SlantDx
		PUBLIC	SlantDy
		PUBLIC	SlantDz

		EXTRN	ArcTan:FAR
		EXTRN	Sqrt32:FAR

		EXTRN	CosTable:WORD

;============================================================================

		INCLUDE	MAINDATA.INC

		INCLUDE	\VISUAL\VISDATA.INC
		INCLUDE	\VISUAL\RWY_TAXI.INC

		INCLUDE	\LIB8086\TRIG.INC
		INCLUDE	\LIB8086\USEFUL.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

;* OctTable index:-
;*
;*    b0: 0
;*    b1: 0
;*    b2: 1 = abs(Dx) > abs(Dy)
;*    b3: 1 = -Dy
;*    b4: 1 = -Dx

;*		DW	offset, sign

OctTable	DW	  0*128,  0	;  0 + theta
		DW	128*128, -1	; 90 - theta
		DW	256*128, -1	;180 - theta
		DW	128*128,  0	; 90 + theta
		DW	  0*128, -1	;360 - theta
		DW	384*128,  0	;270 + theta
		DW	256*128,  0	;180 + theta
		DW	384*128, -1	;270 - theta

MAX_TIME	EQU	(60*60)-1	;59 mins : 59 secs

;------------
;* flat range
;------------

FlatDx		DD	0
FlatDy		DD	0

;-------------
;* slant range
;-------------

SlantRng	DD	0
SlantDx		DD	0
SlantDy		DD	0
SlantDz		DD	0

DATA		ENDS

;============================================================================

GENCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:GENCODE
		ASSUME DS:DATA

;* CalcRngBrgVP_VP - calc range and bearing of viewpoint from viewpoint
;*
;* pass: si -> VIEWPOINT data block (object)
;*       di -> VIEWPOINT data block (target)
;* ret : see CalcRngBrg
;* kill: see CalcRngBrg
;*
;* note: Returns via CalcRngBrg.

CalcRngBrgVP_VP	PROC	FAR

;* x1 = xsec * 16384 + xft + 8192

		mov	cx,VP_XSEC[si]	;xsec * 65536
		xor	bx,bx
		REPT	2		;/4
		sar	cx,1
		rcr	bx,1
		ENDM
		mov	bp,VP_XFT[si]
		add	bp,8192
		add	bx,bp
		adc	cx,0

;* x2 = xsec * 16384 + xft + 8192

		mov	dx,VP_XSEC[di]	;xsec * 65536
		xor	ax,ax
		REPT	2		;/4
		sar	dx,1
		rcr	ax,1
		ENDM
		mov	bp,VP_XFT[di]
		add	bp,8192
		add	ax,bp
		adc	dx,0

;* Dx = x2 - x1

		sub	ax,bx
		sbb	dx,cx

		push	ax		;store Dx
		push	dx

;* y1 = -(ysec * 16384) + yft - 8192

		mov	dx,VP_YSEC[si]	;ysec * 65536
		xor	ax,ax
		REPT	2		;/4
		sar	dx,1
		rcr	ax,1
		ENDM
		NEG32	dx,ax
		mov	bp,VP_YFT[si]
		sub	bp,8192		;//BUG FIX//
		add	ax,bp
		adc	dx,0

;* y2 = -(ysec * 16384) + yft - 8192

		mov	cx,VP_YSEC[di]	;ysec * 65536
		xor	bx,bx
		REPT	2		;/4
		sar	cx,1
		rcr	bx,1
		ENDM
		NEG32	cx,bx
		mov	bp,VP_YFT[di]
		sub	bp,8192		;//BUG FIX//
		add	bx,bp
		adc	cx,0

;* Dy = y2 - y1

		sub	bx,ax
		sbb	cx,dx

		pop	dx		;restore Dx
		pop	ax

		jmp	NEAR PTR CalcRngBrg
		
CalcRngBrgVP_VP	ENDP

;----------------------------------------------------------------------------

;* CalcRngBrgVP_WP - calc range and bearing of waypoint from viewpoint
;*
;* pass: si -> VIEWPOINT data block
;*       di -> WAYPOINT data block
;* ret : see CalcRngBrg
;* kill: see CalcRngBrg
;*
;* note: Returns via CalcRngBrg.

CalcRngBrgVP_WP	PROC	FAR

;* x1 = xsec * 16384 + xft + 8192

		mov	cx,VP_XSEC[si]	;xsec * 65536
		xor	bx,bx
		REPT	2		;/4
		sar	cx,1
		rcr	bx,1
		ENDM
		mov	bp,VP_XFT[si]
		add	bp,8192
		add	bx,bp
		adc	cx,0

;* x2 = xsec * 16384 + xft + 8192

		mov	dx,WP_XSEC[di]	;xsec * 65536
		xor	ax,ax
		REPT	2		;/4
		sar	dx,1
		rcr	ax,1
		ENDM
		mov	bp,WP_XFT[di]
		add	bp,8192
		add	ax,bp
		adc	dx,0

;* Dx = x2 - x1

		sub	ax,bx
		sbb	dx,cx

		push	ax		;store Dx
		push	dx

;* y1 = -(ysec * 16384) + yft - 8192

		mov	dx,VP_YSEC[si]	;ysec * 65536
		xor	ax,ax
		REPT	2		;/4
		sar	dx,1
		rcr	ax,1
		ENDM
		NEG32	dx,ax
		mov	bp,VP_YFT[si]
		sub	bp,8192		;//BUG FIX//
		add	ax,bp
		adc	dx,0

;* y2 = -(ysec * 16384) + yft - 8192

		mov	cx,WP_YSEC[di]	;ysec * 65536
		xor	bx,bx
		REPT	2		;/4
		sar	cx,1
		rcr	bx,1
		ENDM
		NEG32	cx,bx
		mov	bp,WP_YFT[di]
		sub	bp,8192		;//BUG FIX//
		add	bx,bp
		adc	cx,0

;* Dy = y2 - y1

		sub	bx,ax
		sbb	cx,dx

		pop	dx		;restore Dx
		pop	ax

		jmp	NEAR PTR CalcRngBrg
		
CalcRngBrgVP_WP	ENDP

;----------------------------------------------------------------------------

;* CalcRngBrgWP_WP - calc range and bearing of waypoint from waypoint
;*
;* pass: si -> WAYPOINT data block (first waypoint)
;*       di -> WAYPOINT data block (second waypoint)
;* ret : see CalcRngBrg
;* kill: see CalcRngBrg
;*
;* note: Returns via CalcRngBrg.

CalcRngBrgWP_WP	PROC	FAR

;* x1 = xsec * 16384 + xft + 8192

		mov	cx,WP_XSEC[si]	;xsec * 65536
		xor	bx,bx
		REPT	2		;/4
		sar	cx,1
		rcr	bx,1
		ENDM
		mov	bp,WP_XFT[si]
		add	bp,8192
		add	bx,bp
		adc	cx,0

;* x2 = xsec * 16384 + xft + 8192

		mov	dx,WP_XSEC[di]	;xsec * 65536
		xor	ax,ax
		REPT	2		;/4
		sar	dx,1
		rcr	ax,1
		ENDM
		mov	bp,WP_XFT[di]
		add	bp,8192
		add	ax,bp
		adc	dx,0

;* Dx = x2 - x1

		sub	ax,bx
		sbb	dx,cx

		push	ax		;store Dx
		push	dx

;* y1 = -(ysec * 16384) + yft - 8192

		mov	dx,WP_YSEC[si]	;ysec * 65536
		xor	ax,ax
		REPT	2		;/4
		sar	dx,1
		rcr	ax,1
		ENDM
		NEG32	dx,ax
		mov	bp,WP_YFT[si]
		sub	bp,8192		;//BUG FIX//
		add	ax,bp
		adc	dx,0

;* y2 = -(ysec * 16384) + yft - 8192

		mov	cx,WP_YSEC[di]	;ysec * 65536
		xor	bx,bx
		REPT	2		;/4
		sar	cx,1
		rcr	bx,1
		ENDM
		NEG32	cx,bx
		mov	bp,WP_YFT[di]
		sub	bp,8192		;//BUG FIX//
		add	bx,bp
		adc	cx,0

;* Dy = y2 - y1

		sub	bx,ax
		sbb	cx,dx

		pop	dx		;restore Dx
		pop	ax

		jmp	NEAR PTR CalcRngBrg
		
CalcRngBrgWP_WP	ENDP

;----------------------------------------------------------------------------

;* CalcRngBrgVP_AF - calc range and bearing of airfield from viewpoint
;*
;* pass: si -> VIEWPOINT data block
;*       di -> AIRFIELD data block
;* ret : see CalcRngBrg
;* kill: see CalcRngBrg
;*
;* note: Returns via CalcRngBrg.

CalcRngBrgVP_AF	PROC	FAR

;* x1 = xsec * 16384 + xft + 8192

		mov	cx,VP_XSEC[si]	;xsec * 65536
		xor	bx,bx
		REPT	2		;/4
		sar	cx,1
		rcr	bx,1
		ENDM
		mov	bp,VP_XFT[si]
		add	bp,8192
		add	bx,bp
		adc	cx,0

;* x2 = xsec * 16384 + xft + 8192

		mov	dx,AF_XSEC[di]	;xsec * 65536
		xor	ax,ax
		REPT	2		;/4
		sar	dx,1
		rcr	ax,1
		ENDM
		mov	bp,AF_ILS_PTR[di]
		mov	bp,DS:ILS_X_DATUM[bp]
		add	bp,8192
		add	ax,bp
		adc	dx,0

;* Dx = x2 - x1

		sub	ax,bx
		sbb	dx,cx

		push	ax		;store Dx
		push	dx

;* y1 = -(ysec * 16384) + yft - 8192

		mov	dx,VP_YSEC[si]	;ysec * 65536
		xor	ax,ax
		REPT	2		;/4
		sar	dx,1
		rcr	ax,1
		ENDM
		NEG32	dx,ax
		mov	bp,VP_YFT[si]
		sub	bp,8192		;//BUG FIX//
		add	ax,bp
		adc	dx,0

;* y2 = -(ysec * 16384) + yft - 8192

		mov	cx,AF_YSEC[di]	;ysec * 65536
		xor	bx,bx
		REPT	2		;/4
		sar	cx,1
		rcr	bx,1
		ENDM
		NEG32	cx,bx
		mov	si,AF_ILS_PTR[di]
		mov	bp,ILS_Y_DATUM[si]
		sub	bp,8192		;//BUG FIX//
		add	bx,bp
		adc	cx,0

;* Dy = y2 - y1

		sub	bx,ax
		sbb	cx,dx

		pop	dx		;restore Dx
		pop	ax

		jmp	NEAR PTR CalcRngBrg
		
CalcRngBrgVP_AF	ENDP

;----------------------------------------------------------------------------

;* CalcRngBrg - calc range and bearing
;*
;* pass: dx, ax = Dx
;*       cx, bx = Dy
;* ret : dx, ax = range
;*       bx = si = bearing (pdegs)
;*       bp = di = bearing (fine pdegs)
;*	 FlatDx = Dx
;*	 FlatDy = Dy
;* kill: cx, flags
;*
;* note: This routine will not cope with extremely large values of Dx and Dy.
;*       However, the limit is 2^31 / 5, so there should be need for concern!
;*
;*       The long range calculation used has an average error of 3% and a
;*       worst case error of 12%.
;*
;*       The short range calculation accuracy could be improved if cos(theta)
;*       were calculated using fine pdegs.

CalcRngBrg	PROC	FAR

		mov	WORD PTR FlatDx,ax
		mov	WORD PTR FlatDx+2,dx

		mov	WORD PTR FlatDy,bx
		mov	WORD PTR FlatDy+2,cx

;--------------
;* calc bearing
;--------------

		xor	si,si		;reset table index

		test	dx,dx		;abs(Dx)
		jns	@F
		NEG32	dx,ax
		or	si,10000b	;-Dx flag

@@:		test	cx,cx		;abs(Dy)
		jns	@F
		NEG32	cx,bx
		or	si,01000b	;-Dy flag

@@: 		cmp	dx,cx
		jb	ScaleVals	;abs(Dx) < abs(Dy) ->
		ja	SwapVals	;abs(Dx) > abs(Dy) ->

		cmp	ax,bx
		jb	ScaleVals	;abs(Dx) < abs(Dy) ->
		ja	SwapVals	;abs(Dx) > abs(Dy) ->

;* if abs(Dx) = abs(Dy) = 0 then
;*    theta = 0 degs
;* else
;*    theta = 45 degs
;* end

		push	dx		;store min(abs(Dx), abs(Dy))
		push	ax
		push	cx		;store max(abs(Dx), abs(Dy))
		push	bx

		mov	ax,64*128	;assume 45 degs

		or	bx,cx		;abs(Dx) = abs(Dy) <> 0?
		jnz	ContBrg		;yes ->

		xor	ax,ax		;0 degs

		jmp	ContBrg

SwapVals:	xchg	dx,cx
		xchg	ax,bx

		or	si,00100b	;abs(Dx) > abs(Dy) flag

ScaleVals: 	push	dx		;store min(abs(Dx), abs(Dy))
		push	ax
		push	cx		;store max(abs(Dx), abs(Dy))
		push	bx

;* numerator * 32768 for binary fraction

		mov	bp,dx
		mov	dx,ax
		xor	ax,ax

		shr	bp,1
		rcr	dx,1
		rcr	ax,1

;* scale values for 16 bit denominator (val <= 65536)

ScaleLoop:	jcxz	@F

		shr	bp,1		;numerator / 2
		rcr	dx,1
		rcr	ax,1

		shr	cx,1		;denominator / 2
		rcr	bx,1

		jmp	ScaleLoop

@@:		div	bx

		push	si
		call	ArcTan		;(0 .. 45 degs)
		pop	si

ContBrg:	mov	di,ax		;theta (fine pdegs)

		mov	cl,7		;/128
		shr	ax,cl
		ROUNDUP	ax

		mov	bx,ax		;theta (pdegs)

;* bearing = oct offset + theta * oct sign

		mov	ax,OctTable[si+0]	;oct offset

		mov	dx,OctTable[si+2]	;oct sign

		xor	di,dx
		sub	di,dx

		add	di,ax		;di = bearing (fine pdegs)

		mov	si,di

		mov	cl,7		;/128
		shr	si,cl
		ROUNDUP	si
		and	si,001ffh	;si = bearing (pdegs)

;------------
;* calc range
;------------

		pop	ax		;restore max(abs(Dx), abs(Dy))
		pop	dx
		pop	bp		;restore min(abs(Dx), abs(Dy))
		pop	cx

;* if max(abs(Dx), abs(Dy)) < 32768 then
;*    calc range (short)
;* else
;*    calc range (long)
;* end

;* short range = max(abs(Dx), abs(Dy)) * 32768 / cos(theta)

		test	dx,dx
		jnz	@F		;long ->
		cmp	ax,32768
		jae	@F		;long ->

		mov	dx,ax		;*32768
		xor	ax,ax
		shr	dx,1
		rcr	ax,1

		COSINE	bx,bx

		div	bx

		xor	dx,dx		;dx, ax = range

		jmp	ExitRngBrg

;* long range = [min(abs(Dx), abs(Dy)) + 4 * max(abs(Dx), abs(Dy))] / 4

@@:		REPT	2		;*4
		shl	ax,1
		rcl	dx,1
		ENDM

		add	ax,bp
		adc	dx,cx

		REPT	2    		;/4
		shr	dx,1
		rcr	ax,1
		ENDM

ExitRngBrg:	mov	bx,si		;bx = bearing (pdegs)
		mov	bp,di		;bp = bearing (fine pdegs)

		ret

CalcRngBrg	ENDP

;----------------------------------------------------------------------------

;* CalcAngDiff - calculate angular difference
;*
;* pass: ax = heading (0 .. 511 pdeg)
;*       dx = bearing (0 .. 511 pdeg)
;* ret : ax = abs(ang diff) (0 .. 256 pdeg)
;*       dx = sign(ang diff)
;* kill: cl, flags

CalcAngDiff	PROC	FAR

		mov	cl,7		;scale by 128

		and	ax,001ffh	;ensure 0 .. 511 pdeg
		and	dx,001ffh	;ensure 0 .. 511 pdeg

		shl	ax,cl		;*128
		shl	dx,cl		;*128

		xchg	ax,dx

		sub	ax,dx		;ang diff * 128

		ABSV	ax		;ax = abs(ang diff), dx = sign(ang diff)

		shr	ax,cl		;/128

		ret

CalcAngDiff	ENDP

;----------------------------------------------------------------------------

;* CalcNMiles - calc range in nautical miles
;*
;* pass: dx, ax = range (ft)
;* ret : ax = range (nautical miles * 10)
;* kill: bx, cx, dx, flags
;*
;* note: 1NM = 6076ft

CalcNMiles	PROC	FAR

		shl	ax,1		;*2
		rcl	dx,1

		mov	bx,ax
		mov	cx,dx

		REPT	2		;*4 (*8)
		shl	ax,1
		rcl	dx,1
		ENDM

		add	ax,bx		;*10
		adc	dx,cx

		mov	bx,6076

		cmp	bx,dx		;div ok
		jbe	SetMaxRange	;no ->

		div	bx

		cmp	dx,6076/2	;round up?
		jb	@F		;no ->

		inc	ax

@@:		ret

SetMaxRange:	mov	ax,9999		;999.9NM

		ret

CalcNMiles	ENDP

;----------------------------------------------------------------------------

;* CalcETA
;*
;* pass: dx, ax = dist (ft)
;*       bx = speed (ft / sec * 8)
;* ret : ax = time (seconds)
;* kill: bx, dx, flags

CalcETA		PROC	FAR

		cmp	bx,0		;speed > 0?
		jle	SetMaxTime	;no ->

		REPT	3		;/8
		shr	bx,1
		ENDM

		cmp	bx,dx		;div ok?
		jbe	SetMaxTime	;no ->

		div	bx

		cmp	ax,MAX_TIME 	;> max time?
		ja	SetMaxTime	;yes ->

		ret

SetMaxTime:	mov	ax,MAX_TIME

		ret

CalcETA		ENDP

;----------------------------------------------------------------------------

;* CalcSlantRange (Euclidian distance)
;*
;* pass: si -> object VIEWPOINT
;*       di -> target VIEWPOINT
;* ret : SlantRng = dx, ax = slant range (ft)
;*	 SlantDx
;*	 SlantDy
;*	 SlantDz
;* kill: assume all (except ax, dx)
;*
;* note: Two calculation methods are used:-
;*
;*	 a) short range (accurate)
;*
;*          slant range = sqrt(Dx * Dx + Dy * Dy + Dz * Dz)
;*	 
;*	    Use short range method if all abs(deltas) are < 32768.
;*
;*	 b) long range (approximated)
;*
;*          Dx = abs(x2 - x1)
;*          Dy = abs(y2 - y1)
;*	    Dz = abs(z2 - z1)
;*
;*          slant range = max(Dx,Dy,Dz) + med(Dx,Dy,Dz)/4 + min(Dx,Dy,Dz)/4
;*
;*	    Best case error when only one non-zero value (0%).
;*
;*	    Worst case error when Dx = Dy = Dz (13.4%).
;*
;*	    Long range method makes no checks for overflow.

CalcSlantRange	PROC	FAR

;------------------------
;* calc Dx = abs(x2 - x1)
;------------------------

;* x1 = xsec * 16384 + xft + 8192

		mov	cx,[si].VP_XSEC	;xsec * 65536
		xor	bx,bx
		REPT	2		;/4
		sar	cx,1
		rcr	bx,1
		ENDM
		mov	bp,[si].VP_XFT
		add	bp,8192
		add	bx,bp
		adc	cx,0

;* x2 = xsec * 16384 + xft + 8192

		mov	dx,[di].VP_XSEC	;xsec * 65536
		xor	ax,ax
		REPT	2		;/4
		sar	dx,1
		rcr	ax,1
		ENDM
		mov	bp,[di].VP_XFT
		add	bp,8192
		add	ax,bp
		adc	dx,0

;* Dx = abs(x2 - x1)

		sub	ax,bx
		sbb	dx,cx

		mov	WORD PTR SlantDx,ax
		mov	WORD PTR SlantDx+2,dx

		jns	@F

		NEG32	dx,ax

@@:		push	ax		;store Dx
		push	dx

;------------------------
;* calc Dy = abs(y2 - y1)
;------------------------

;* y1 = -(ysec * 16384) + yft - 8192

		mov	dx,[si].VP_YSEC	;ysec * 65536
		xor	ax,ax
		REPT	2		;/4
		sar	dx,1
		rcr	ax,1
		ENDM
		NEG32	dx,ax
		mov	bp,[si].VP_YFT
		sub	bp,8192
		add	ax,bp
		adc	dx,0

;* y2 = -(ysec * 16384) + yft - 8192

		mov	cx,[di].VP_YSEC	;ysec * 65536
		xor	bx,bx
		REPT	2		;/4
		sar	cx,1
		rcr	bx,1
		ENDM
		NEG32	cx,bx
		mov	bp,[di].VP_YFT
		sub	bp,8192
		add	bx,bp
		adc	cx,0

;* Dy = abs(y2 - y1)

		sub	bx,ax
		sbb	cx,dx

		mov	WORD PTR SlantDy,bx
		mov	WORD PTR SlantDy+2,cx

		jns	@F

		NEG32	cx,bx

;------------------------
;* calc Dz = abs(z2 - z1)
;------------------------

;* z1

@@:		mov	ax,WORD PTR [si].VP_ZFT_LO
		mov	dx,WORD PTR [si].VP_ZFT_HI

;* z2

		mov	si,WORD PTR [di].VP_ZFT_LO
		mov	di,WORD PTR [di].VP_ZFT_HI

;* Dz = abs(z2 - z1)

		sub	si,ax
		sbb	di,dx

		mov	WORD PTR SlantDz,si
		mov	WORD PTR SlantDz+2,di

		jns	@F

		NEG32	di,si

@@:		pop	dx		;restore Dx
		pop	ax

;-----------------------------------------
;* select short range or long range method
;-----------------------------------------

;* dx, ax = Dx
;* cx, bx = Dy
;* di, si = Dz

		mov	bp,32768	;set limit

		test	dx,dx		;Dx < 65536?
		jnz	LongRange	;no ->
		cmp	ax,bp		;Dx < limit?
		ja	LongRange	;no ->

		test	cx,cx		;Dy < 65536?
		jnz	LongRange	;no ->
		cmp	bx,bp		;Dy < limit?
		ja	LongRange	;no ->

		test	di,di		;Dz < 65536?
		jnz	LongRange	;no ->
		cmp	si,bp		;Dz < limit?
		ja	LongRange	;no ->

;---------------------------
ShortRange	LABEL	NEAR
;---------------------------

;* ax = Dx
;* bx = Dy
;* si = Dz

;* slant range = sqrt(Dx * Dx + Dy * Dy + Dz * Dz)

		mul	ax		;Dx * Dx

		xchg	ax,bx
		mov	cx,dx

		mul	ax		;Dy * Dy

		add	bx,ax		;Dx * Dx + Dy * Dy
		adc	cx,dx

		mov	ax,si

		mul	ax		;Dz * Dz

		add	ax,bx		;Dx * Dx + Dy * Dy + Dz * Dz
		adc	dx,cx

		call	Sqrt32

		xor	dx,dx

		mov	WORD PTR SlantRng,ax
		mov	WORD PTR SlantRng+2,dx

		ret

;---------------------------
LongRange	LABEL	NEAR
;---------------------------

;* dx, ax = Dx
;* cx, bx = Dy
;* di, si = Dz

;* sort max(Dx, Dy, Dz)

		cmp	dx,cx		;Dx > Dy?
		ja	SortOk1		;yes ->
		jb	@F		;no ->

		cmp	ax,bx		;Dx >= Dy?
		jae	SortOk1		;yes ->

@@:		xchg	ax,bx
		xchg	dx,cx

;* dx, ax = max(Dx, Dy)

SortOk1:	cmp	dx,di		;max(Dx, Dy) > Dz?
		ja	SortOk2		;yes ->
		jb	@F		;no ->

		cmp	ax,si		;max(Dx, Dy) >= Dz?
		jae	SortOk2		;yes ->

@@:		xchg	ax,si
		xchg	dx,di

;* dx, ax = max(Dx, Dy, Dz)
;* cx, bx = either med(Dx, Dy, Dz) or min(Dx, Dy, Dz)
;* di, si = either med(Dx, Dy, Dz) or min(Dx, Dy, Dz)

;* calc med(Dx, Dy, Dz) / 4
;* calc min(Dx, Dy, Dz) / 4

SortOk2:	REPT	2		
		shr	cx,1
		rcr	bx,1
		shr	di,1
		rcr	si,1
		ENDM

;* slant range = max(Dx, Dy, Dz) + med(Dx, Dy, Dz) / 4 + min(Dx, Dy, Dz) / 4

		add	ax,bx
		adc	dx,cx

		add	ax,si
		adc	dx,di

		mov	WORD PTR SlantRng,ax
		mov	WORD PTR SlantRng+2,dx

		ret

CalcSlantRange	ENDP

GENCODE		ENDS

;============================================================================

		END

