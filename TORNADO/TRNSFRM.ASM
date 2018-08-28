;****************************************************************************
;*
;* TRNSFRM.ASM
;*
;* 3D transform routines.
;*
;* 11.12.1992 - KJB
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	CalcTransMatrix
		PUBLIC	CalcEyeCoords
		PUBLIC	CalcTgtRelCo
		PUBLIC	Calc3DOffset
		PUBLIC	CalcRngRelCo

		EXTRN	CalcSlantRange:FAR
		EXTRN	Sqrt32:FAR

		EXTRN	SlantDx:DWORD
		EXTRN	SlantDy:DWORD
		EXTRN	SlantDz:DWORD

		EXTRN	SinTable:WORD
		EXTRN	CosTable:WORD

;============================================================================

		INCLUDE	\VISUAL\VISDATA.INC

		INCLUDE	\LIB8086\USEFUL.INC
		INCLUDE	\LIB8086\TRIG.INC

;============================================================================

		EXTRN	M_VIEW:VIEWPOINT

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

;-------------------------------------
;* heading, pitch and roll trig values
;-------------------------------------

V_SinH		DW	0
V_CosH		DW	0
V_SinP		DW	0
V_CosP		DW	0
V_SinR		DW	0
V_CosR		DW	0

;-----------------------------
;* rotation matrix "A" factors
;-----------------------------

A1		DW	0
A2		DW	0
A3		DW	0
A4		DW	0
A5		DW	0
A6		DW	0
A7		DW	0
A8		DW	0
A9		DW	0

;-----------
;* temp vars
;-----------

TmpRng		DD	0

DATA		ENDS

;============================================================================

GENCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:GENCODE
		ASSUME DS:DATA

;* CalcTransMatrix - calc transformation matrix ('A' factors)
;*
;* pass: si -> VIEWPOINT
;* ret : 'A' factors
;* kill: assume all

CalcTransMatrix	PROC	FAR

;------------------
;* calc trig angles
;------------------

;* heading

		mov	ax,[si].VP_HDG
		and	ax,001ffh
		mov	bx,ax
		shl	bx,1
		mov	ax,SinTable[bx]
		mov	V_SinH,ax
		mov	ax,CosTable[bx]
		mov	V_CosH,ax

;* pitch

		mov	ax,[si].VP_PITCH
		and	ax,001ffh
		mov	bx,ax
		shl	bx,1
		mov	ax,SinTable[bx]
		mov	V_SinP,ax
		mov	ax,CosTable[bx]
		mov	V_CosP,ax

;* roll

		mov	ax,[si].VP_ROLL
		and	ax,001ffh
		mov	bx,ax
		shl	bx,1
		mov	ax,SinTable[bx]
		mov	V_SinR,ax
		mov	ax,CosTable[bx]
		mov	V_CosR,ax

;------------------
;* calc 'A' factors
;------------------

		mov	ax,V_CosR
		mov	bp,ax

		mov	ax,V_CosH
		mov	si,ax
		imul	bp
		FRACADJ	bx		;bx = cosH.cosR

		mov	ax,V_SinH
		mov	di,ax
		imul	bp
		FRACADJ	cx		;cx = sinH.cosR

		mov	ax,V_SinR
		mov	bp,ax

		imul	si
		FRACADJ	si		;si = cosH.sinR

		mov	ax,bp
		imul	di
		FRACADJ	di		;di = sinH.sinR

		mov	ax,V_SinP
		mov	bp,ax

		mov	ax,di
		imul	bp
		FRACADJ	ax		;ax = sinP.sinH.sinR
		add	ax,bx		;ax = sinP.sinH.sinR + cosH.cosR
		mov	A1,ax

		mov	ax,si	
		imul	bp
		FRACADJ	ax		;ax = sinP.cosH.sinR
		sub	ax,cx		;ax = sinP.cosH.sinR - sinH.cosR
		mov	A2,ax

		mov	ax,cx
		imul	bp
		FRACADJ	dx		;dx = sinP.sinH.cosR
		mov	ax,si
		sub	ax,dx		;ax = cosH.sinR - sinP.sinH.cosR
		mov	A7,ax

		mov	ax,bx
		imul	bp
		FRACADJ	dx		;dx = sinP.cosH.cosR
		mov	ax,di
		neg	ax		;ax = -sinH.sinR
		sub	ax,dx		;ax = -sinH.sinR - sinP.cosH.cosR
		mov	A8,ax

		mov	ax,V_CosP
		mov	bp,ax
		
		mov	ax,V_SinR
		neg	ax		;ax = -sinR
		imul	bp
		FRACADJ	ax		;ax = -sinR.cosP
		mov	A3,ax

		mov	ax,V_SinH
		imul	bp
		FRACADJ	ax	 	;ax = sinH.cosP
		mov	A4,ax

		mov	ax,V_CosH
		imul	bp
		FRACADJ	ax		;ax = cosH.cosP
		mov	A5,ax

		mov	ax,V_CosR
		imul	bp
		FRACADJ	ax		;ax = cosR.cosP
		mov	A9,ax

		mov	ax,V_SinP	;ax = sinP
		mov	A6,ax

		ret

CalcTransMatrix	ENDP

;----------------------------------------------------------------------------

;* CalcEyeCoords - calc eye co-ords from rel co-ords
;*
;* pass: ax = x rel
;*       bx = y rel
;*       cx = z rel
;*       'A' factors
;* ret : ax = x eye
;*       bx = y eye
;*       cx = z eye
;* kill: dx, si, di, bp, flags

CalcEyeCoords	PROC	FAR

		mov	si,ax
		mov	di,bx
		push	cx

		mov	ax,A1
		imul	si
		FRACADJ	bp		;bp = A1.x rel

		mov	ax,A4
		imul	si
		FRACADJ	bx		;bx = A4.x rel

		mov 	ax,A7
		imul 	si
		FRACADJ	cx		;cx = A7.x rel

		mov	ax,A2
		imul 	di
		FRACADJ	dx
		add 	bp,dx		;bp = A1.x rel + A2.y rel

		mov	ax,A5
		imul	di
		FRACADJ	dx
		add	bx,dx		;bx = A4.x rel + A5.y rel

		mov	ax,A8
		imul	di
		FRACADJ	dx
		add	cx,dx		;cx = A7.x rel + A8.y rel

		pop	si

		mov	ax,A6
		imul 	si
		FRACADJ	dx
		add	bx,dx		;bx = A4.x rel + A5.y rel + A6.z rel

		mov	ax,A9
		imul	si
		FRACADJ	dx
		add	cx,dx		;cx = A7.x rel + A8.y rel + A9.z rel

		mov	ax,A3
		imul	si
		FRACADJ	ax
		add	ax,bp		;ax = A1.x rel + A2.y rel + A3.z rel

		ret

CalcEyeCoords	ENDP

;----------------------------------------------------------------------------

;* SCALE_REL_VALS - scale relative values
;*
;* pass: dx, ax = abs(x rel)
;*	 cx, bx = abs(y rel)
;*	     bp = abs(z rel)
;* ret : dx, ax = abs(x rel) / 2
;*	 cx, bx = abs(y rel) / 2
;* 	     bp = abs(z rel) / 2
;* kill: flags

SCALE_REL_VALS	MACRO

		shr	dx,1		;;abs(x rel) / 2
		rcr	ax,1

		shr	cx,1		;;abs(y rel) / 2
		rcr	bx,1

		shr	bp,1		;;abs(z rel) / 2

		ENDM

;----------------------------------------------------------------------------

;* CalcTgtRelCo - calc target relative co-ords
;*
;* pass: M_VIEW
;*	 si -> VIEWPOINT target
;* ret : cf = 0 = ok
;*	    ax = x rel
;*	    bx = y rel
;*	    cx = z rel
;*       cf = 1 = error
;* kill: dx, bp, flags (except cf)

CalcTgtRelCo	PROC	FAR

;------------
;* calc x rel (target xft - aircraft xft)
;------------

;* x1 = xsec * 16384 + xft + 8192

		mov	cx,M_VIEW.VP_XSEC	;xsec * 65536
		xor	bx,bx
		REPT	2      		;/4
		sar	cx,1
		rcr	bx,1
		ENDM
		mov	bp,M_VIEW.VP_XFT
		add	bp,8192
		add	bx,bp
		adc	cx,0

;* x2 = xsec * 16384 + xft + 8192

		mov	dx,[si].VP_XSEC	;xsec * 65536
		xor	ax,ax
		REPT	2		;/4
		sar	dx,1
		rcr	ax,1
		ENDM
		mov	bp,[si].VP_XFT
		add	bp,8192
		add	ax,bp
		adc	dx,0

;* x rel = x2 - x1

		sub	ax,bx
		sbb	dx,cx

		push	ax		;store x rel
		push	dx

;------------
;* calc y rel (target yft - aircraft yft)
;------------

;* y1 = -(ysec * 16384) + yft - 8192

		mov	dx,M_VIEW.VP_YSEC	;ysec * 65536
		xor	ax,ax
		REPT	2		;/4
		sar	dx,1
		rcr	ax,1
		ENDM
		NEG32	dx,ax
		mov	bp,M_VIEW.VP_YFT
		sub	bp,8192
		add	ax,bp
		adc	dx,0

;* y2 = -(ysec * 16384) + yft - 8192

		mov	cx,[si].VP_YSEC	;ysec * 65536
		xor	bx,bx
		REPT	2		;/4
		sar	cx,1
		rcr	bx,1
		ENDM
		NEG32	cx,bx
		mov	bp,[si].VP_YFT
		sub	bp,8192
		add	bx,bp
		adc	cx,0

;* y rel = y2 - y1

		sub	bx,ax
		sbb	cx,dx

;------------
;* calc z rel (target zft - aircraft zft)
;------------

		mov	bp,WORD PTR [si].VP_ZFT_LO
		mov	ax,WORD PTR [si].VP_ZFT_HI

		sub	bp,WORD PTR M_VIEW.VP_ZFT_LO
		sbb	ax,WORD PTR M_VIEW.VP_ZFT_HI

		cwd			;dx = sign(z rel)

		jns	@F

		NEG32	ax,bp

;* compress z rel (assume abs(z rel) <= 100,000)
;*
;* if abs(z rel) > 10000 then 
;*    abs(z rel) = abs(z rel) / 4 + 7500
;* endif

@@:		test	ax,ax		;abs(z rel) > 65535?
		jnz	@F		;yes ->

		cmp	bp,10000	;abs(z rel) > 10000?
		jbe	ZRelOk		;no ->

@@:		REPT	2		;abs(z rel) / 4
		shr	ax,1
		rcr	bp,1
		ENDM

		add	bp,7500		;abs(z rel) / 4 + 7500

ZRelOk: 	xor	bp,dx		;restore sign
		sub	bp,dx

		pop	dx		;restore x rel
		pop	ax

;-----------------------------------------
;* calc abs(x rel), abs(y rel), abs(z rel)
;-----------------------------------------

		push	dx		;sign(x rel)
		push	cx		;sign(y rel)
		push	bp		;sign(z rel)

;* abs(x rel)

		test	dx,dx
		jns	@F
		NEG32	dx,ax

;* abs(y rel)

@@:		test	cx,cx
		jns	@F
		NEG32	cx,bx

;* abs(z rel)

@@:		test	bp,bp
		jns	@F
		neg	bp

;------------------------------------------
;* check abs(x rel) and abs(y rel) in range
;------------------------------------------

;* max range = 03ffffh (approx. 50 miles)

@@:		cmp	dx,3		;abs(x rel) in range?
		_JA	RelCoError	;no ->

		cmp	cx,3		;abs(y rel) in range?
		_JA	RelCoError	;no ->

;--------------
;* scale values (all rel values must be < 16384)
;--------------

;* scale wrt abs(x rel)

		test	dx,dx		;abs(x rel) > 65535?
		jz	@F		;no ->
		SCALE_REL_VALS		;(max = 131071)

		test	dx,dx		;abs(x rel) > 65535?
		jz	@F		;no ->
		SCALE_REL_VALS		;(max = 65535)

@@:		cmp	ax,16384	;abs(x rel) < 16384?
		jb	@F		;yes ->
		SCALE_REL_VALS		;(max = 32767)

		cmp	ax,16384	;abs(x rel) < 16384?
		jb	@F		;yes ->
		SCALE_REL_VALS		;(max = 16383)

;* scale wrt abs(y rel)

@@:		test	cx,cx		;abs(y rel) > 65535?
		jz	@F		;no ->
		SCALE_REL_VALS		;(max = 131071)
		
		test	cx,cx		;abs(y rel) > 65535?
		jz	@F		;no ->
		SCALE_REL_VALS		;(max = 65535)

@@:		cmp	bx,16384	;abs(y rel) < 16384?
		jb	@F		;yes ->
		SCALE_REL_VALS		;(max = 32767)

		cmp	bx,16384	;abs(y rel) < 16384?
		jb	@F		;yes ->
		SCALE_REL_VALS		;(max = 16383)

;* scale wrt abs(z rel)

@@:		cmp	bp,16384	;abs(z rel) < 16384?
		jb	@F		;yes ->
		SCALE_REL_VALS		;(max = 16383)

;---------------
;* restore signs
;---------------

;* ax = abs(x rel)
;* bx = abs(y rel)
;* bp = abs(z rel)

@@:		mov	si,ax

		pop	ax		;sign(z rel)
		cwd
		mov	cx,bp
		xor	cx,dx
		sub	cx,dx

		pop	ax		;sign(y rel)
		cwd
		xor	bx,dx
		sub	bx,dx

		pop	ax		;sign(x rel)
		cwd
		mov	ax,si
		xor	ax,dx
		sub	ax,dx

		clc			;cf = 0 = ok

		ret

;---------------------------
RelCoError	LABEL	NEAR
;---------------------------

;* clean up stack

		pop	ax		;sign(z rel)
		pop	ax		;sign(y rel)
		pop	ax		;sign(x rel)

		stc			;cf = 1 = error

		ret	

CalcTgtRelCo	ENDP

;----------------------------------------------------------------------------

;* Calc3DOffset
;*
;* pass: ax = x offset )
;*       bx = y offset ) orthogonal offset wrt object centre
;*       cx = z offset )
;*       'A' factors
;* ret : ax = x offset )
;*       bx = y offset ) transformed 3D offset wrt object centre
;*       cx = z offset )
;* kill: dx, si, di, bp, flags

Calc3DOffset	PROC	FAR

		mov	bp,ax

		mov	ax,A1
		imul	bp
		mov	si,ax		;x.a1
		mov	di,dx

		mov	ax,A4
		imul	bx
		add	si,ax		;x.a1 + y.a4
		adc	di,dx

		mov	ax,A7
		imul	cx
		add	si,ax		;x.a1 + y.a4 + z.a7
		adc	di,dx

		shl	si,1		;*2
		rcl	di,1
		shl	si,1		;1/2 bit round up
		adc	di,0

		push	di		;store x offset

		mov	ax,A2
		imul	bp
		mov	si,ax		;x.a2
		mov	di,dx

		mov	ax,A5
		imul	bx
		add	si,ax		;x.a2 + y.a5
		adc	di,dx

		mov	ax,A8
		imul	cx
		add	si,ax		;x.a2 + y.a5 + z.a8
		adc	di,dx

		shl	si,1		;*2
		rcl	di,1
		shl	si,1		;1/2 bit round up
		adc	di,0

		push	di		;store y offset

		mov	ax,A3
		imul	bp
		mov	si,ax		;x.a3
		mov	di,dx

		mov	ax,A6
		imul	bx
		add	si,ax		;x.a3 + y.a6
		adc	di,dx

		mov	ax,A9
		imul	cx
		add	si,ax		;x.a3 + y.a6 + z.a9
		adc	di,dx

		shl	si,1		;*2
		rcl	di,1
		shl	si,1		;1/2 bit round up
		adc	di,0

		mov	cx,di		;z offset
		pop	bx   		;y offset
		pop	ax		;x offset

		ret

Calc3DOffset	ENDP

;----------------------------------------------------------------------------

;* SCALE_ALL_VALS - scale x, y and z relative values and slant range
;*
;* pass: dx, ax = abs(x rel)
;*	 cx, bx = abs(y rel)
;*	 di, si = abs(z rel)
;*	 TmpRng = slant range
;* ret : dx, ax = abs(x rel) / 2
;*	 cx, bx = abs(y rel) / 2
;*	 di, si = abs(z rel) / 2
;*	 TmpRng = slant range / 2 
;* kill: flags

SCALE_ALL_VALS	MACRO

		shr	dx,1		;;abs(x rel) / 2
		rcr	ax,1

		shr	cx,1		;;abs(y rel) / 2
		rcr	bx,1

		shr	di,1		;;abs(z rel) / 2
		rcr	si,1

		shr	WORD PTR TmpRng+2,1
		rcr	WORD PTR TmpRng,1

		ENDM

;----------------------------------------------------------------------------

;* CalcRngRelCo - calc target relative co-ords and scaled range
;*
;* pass: si -> VIEWPOINT source
;*	 di -> VIEWPOINT target
;* ret :    ax = x rel	      )
;*	    bx = y rel	      ) all values scaled to fit range ñ16383
;*	    cx = z rel	      ) 
;*          dx = scaled range )
;*	    SlantRng
;* kill: si, di, bp, flags

CalcRngRelCo	PROC	FAR

;---------------------------------------
;* calc slant range, x rel, y rel, z rel
;---------------------------------------

		call	CalcSlantRange

		mov	WORD PTR TmpRng,ax
		mov	WORD PTR TmpRng+2,dx

		mov	ax,WORD PTR SlantDx
		mov	dx,WORD PTR SlantDx+2

		mov	bx,WORD PTR SlantDy
		mov	cx,WORD PTR SlantDy+2

		mov	si,WORD PTR SlantDz
		mov	di,WORD PTR SlantDz+2

;-----------------------------------------
;* calc abs(x rel), abs(y rel), abs(z rel)
;-----------------------------------------

;* abs(x rel)

		test	dx,dx
		jns	@F
		NEG32	dx,ax

;* abs(y rel)

@@:		test	cx,cx
		jns	@F
		NEG32	cx,bx

;* abs(z rel)

@@:		test	di,di
		jns	@F
		NEG32	di,si

;--------------
;* scale values (all rel values must be < 16384)
;--------------

;* scale wrt abs(x rel)

@@:		test	dx,dx		;abs(x rel) > 65535?
		jz	@F		;no ->
		SCALE_ALL_VALS
		jmp	@B

@@:		cmp	ax,16384	;abs(x rel) < 16384?
		jb	@F		;yes ->
		SCALE_ALL_VALS
		jmp	@B

;* scale wrt abs(y rel)

@@:		test	cx,cx		;abs(y rel) > 65535?
		jz	@F		;no ->
		SCALE_ALL_VALS
		jmp	@B

@@:		cmp	bx,16384	;abs(y rel) < 16384?
		jb	@F		;yes ->
		SCALE_ALL_VALS
		jmp	@B

;* scale wrt abs(z rel)

@@:		test	di,di		;abs(z rel) > 65535?
		jz	@F		;no ->
		SCALE_ALL_VALS
		jmp	@B

@@:		cmp	si,16384	;abs(z rel) < 16384?
		jb	@F		;yes ->
		SCALE_ALL_VALS
		jmp	@B

;* scale wrt slant range

@@:		cmp	WORD PTR TmpRng+2,0	;slant range > 65535?
		je	@F			;no ->
		SCALE_ALL_VALS
		jmp	@B

@@:		cmp	WORD PTR TmpRng,16384	;abs(z rel) < 16384?
		jb	@F
		SCALE_ALL_VALS
		jmp	@B

;---------------
;* restore signs
;---------------

@@:		mov	bp,ax

		mov	ax,WORD PTR SlantDz+2
		cwd
		mov	cx,si
		xor	cx,dx
		sub	cx,dx

		mov	ax,WORD PTR SlantDy+2
		cwd
		xor	bx,dx
		sub	bx,dx

		mov	ax,WORD PTR SlantDx+2
		cwd
		mov	ax,bp
		xor	ax,dx
		sub	ax,dx

;---------------------
;* recalc scaled range
;---------------------

;* Re-calc scaled range from scaled x rel, y rel and z rel values in order to
;* remove noise from the system (especially where slant range is long and the
;* approximated slant range calculation is used).

;* scaled range = sqrt(x rel * x rel + y rel * y rel + z rel * z rel)

		push	ax		;store x rel
		push	bx		;store y rel
		push	cx		;store z rel

		imul	ax		;x rel * x rel

		mov	si,ax
		mov	di,dx

		mov	ax,bx
		imul	ax		;y rel * y rel

		add	si,ax
		adc	di,dx

		mov	ax,cx
		imul	ax		;z rel * z rel

		add	ax,si
		adc	dx,di

		call	Sqrt32

		mov	dx,ax		;scaled range

		pop	cx		;restore z rel
		pop	bx		;restore y rel
		pop	ax		;restore x rel

		ret

CalcRngRelCo	ENDP

GENCODE		ENDS

;============================================================================

		END

