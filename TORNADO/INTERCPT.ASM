;****************************************************************************
;*
;* INTERCPT.ASM
;*
;* Calc intercept point routine.
;*
;* 11.12.1992 - KJB
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	CalcIntercept

		EXTRN	MoveViewpoint:FAR

		EXTRN	SinTable:WORD
		EXTRN	CosTable:WORD

;============================================================================

		INCLUDE	\VISUAL\VISDATA.INC
		INCLUDE	\VISUAL\VISMACRO.INC

		INCLUDE	\LIB8086\USEFUL.INC
		INCLUDE	\LIB8086\TRIG.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

;* unit vector of target motion

UnitVctrTgtX	DW	0
UnitVctrTgtY	DW	0
UnitVctrTgtZ	DW	0

DATA		ENDS

;============================================================================

GENCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:GENCODE
		ASSUME DS:DATA

;* CalcIntercept - calc intercept point
;*
;* pass: bx = object speed (ft/sec * 8) (assume >= 0)
;*       cx = target speed (ft/sec * 8) (assume >= 0)
;*       dx, ax = target slant range
;*       si -> target viewpoint
;*       di -> result viewpoint
;* ret : result viewpoint
;* kill: assume all

CalcIntercept	PROC	FAR

;-------------------------------------------
;* copy target viewpoint to result viewpoint
;-------------------------------------------

		push	cx
		push	di

		COPY_VP	di,si

		pop	si		;si -> result viewpoint
		pop	cx

;-----------------------------------------------
;* calc target move distance (tmod) (wrt object)
;-----------------------------------------------

;* tmod = range * (target speed / object speed)

;* scale range <= 32767

		xor	bp,bp

@@:		test	dx,dx
		jz	@F
		shr	dx,1
		rcr	ax,1
		inc	bp
		jmp	@B

@@:		cmp	ax,32767
		jbe	@F
		shr	ax,1
		inc	bp

@@:		imul	cx

;* guard against overflow

		shl	ax,1
		rcl	dx,1

		cmp	bx,dx		;overflow?
		_JBE	ExitIntercept	;yes (result vp = target vp) ->

		shr	dx,1
		rcr	ax,1

		idiv	bx

		mov	di,ax		;di = tmod

;-----------------------------------
;* calc unit vector of target motion
;-----------------------------------

;* unit vector target x = cos(target pitch) * sin(target hdg)
;*
;* unit vector target y = cos(target pitch) * cos(target hdg)
;*
;* unit vector target z = sin(target pitch)

		SINCOS	bx,cx,[si].VP_PITCH	;bx = sin(pitch), cx = cos(pitch)

		mov	UnitVctrTgtZ,bx

		SINCOS	ax,bx,[si].VP_HDG	;ax = sin(hdg), bx = cos(hdg)

		imul	cx
		FRACADJ	dx
		mov	UnitVctrTgtX,dx

		mov	ax,bx
		imul	cx
		FRACADJ	dx
		mov	UnitVctrTgtY,dx

;-----------------------------------------------------
;* project target motion vector to the intercept point
;-----------------------------------------------------

;* target z = target z + UnitVctrTgtZ * tmod

		mov	ax,UnitVctrTgtZ
		imul	di
		FRACADJ	ax
		cwd

		mov	cx,bp

		jcxz	SkipZScale

@@:		shl	ax,1
		rcl	dx,1
		loop	@B

SkipZScale:	add	WORD PTR [si].VP_ZFT_LO,ax
		adc	WORD PTR [si].VP_ZFT_HI,dx

		jns	@F		;above ground ->

		mov	WORD PTR [si].VP_ZFT_LO,0
		mov	WORD PTR [si].VP_ZFT_HI,0

;* target x = target x + UnitVctrTgtX * tmod
;* target y = target y + UnitVctrTgtY * tmod

@@:		mov	ax,UnitVctrTgtY
		imul	di
		FRACADJ	ax
		cwd
		mov	bx,ax
		mov	cx,dx

		mov	ax,UnitVctrTgtX
		imul	di
		FRACADJ	ax
		cwd

		test	bp,bp
		jz	SkipXYScale

@@:		shl	ax,1
		rcl	dx,1
		shl	bx,1
		rcl	cx,1
		dec	bp
		jnz	@B

SkipXYScale:	call	MoveViewpoint

ExitIntercept:	ret

CalcIntercept	ENDP

GENCODE		ENDS

;============================================================================

		END

