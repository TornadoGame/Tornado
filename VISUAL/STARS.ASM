;****************************************************************************
;*
;* STARS.ASM
;*
;* Draw stars.
;*
;* 28.07.1992 - KJB
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	DrawStars

		PUBLIC	StarsEnabled

		EXTRN	SetPixel:FAR

		EXTRN	DotClip:NEAR

		EXTRN	Night:BYTE

;============================================================================

		INCLUDE	VISEXTRN.INC
		INCLUDE	PALETTES.INC

		INCLUDE	\LIB8086\USEFUL.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

StarsEnabled	DB	1,0		;1 = stars visible

DATA		ENDS

;============================================================================

STARDATA	SEGMENT PARA PUBLIC 'DATA'

StarMap		LABEL	BYTE

;*		DB	xgrid, ygrid, zgrid, colour

		INCLUDE	STARDATA.INC	;<<<<< NUM_STARS defined <<<<<

STARDATA	ENDS

;============================================================================

VISCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:VISCODE
		ASSUME DS:DATA

;* DrawStars
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

DrawStars	PROC	NEAR

		cmp	Night,0		;night?
		je	ExitStars	;no ->

		test	StarsEnabled,1	;stars visible?
		jz	ExitStars	;no ->

		mov	si,OFFSET StarMap

		mov	cx,NUM_STARS

StarLoop:	push	cx
		push	si

		push	es

		mov	ax,STARDATA
		mov	es,ax

		xor	bh,bh

		ES_LODSB		;xgrid
		mov	bl,al
		mov	cx,XGX[bx]	;XGX
		mov	dx,YGX[bx]	;YGX
		mov	bp,ZGX[bx]	;ZGX

		ES_LODSB		;ygrid
		mov	bl,al
		add	cx,XGY[bx]	;XGX + XGY
		add	dx,YGY[bx]	;YGX + YGY
		add	bp,ZGY[bx]	;ZGX + ZGY

		ES_LODSB		;zgrid
		mov	bl,al
		add	cx,XGZ[bx]	;XGX + XGY + XGZ
		add	dx,YGZ[bx]	;YGX + YGY + YGZ
		add	bp,ZGZ[bx]	;ZGX + ZGY + ZGZ

		mov	Xe[0],cx
		mov	Ye[0],dx
		mov	Ze[0],bp

		ES_LODSB		;colour

		pop	es

;* do not draw darkest stars in night mode 1

		cmp	al,COL_NT_GREY4	;dark star?
		jne	@F		;no ->
		cmp	Night,1		;night mode 1?
		je	SkipStar	;yes ->

@@:		push	ax
		call	DotClip
		pop	ax
		jc	SkipStar	;non-visible ->

		call	SetPixel

SkipStar:  	pop	si
		pop	cx

		add	si,4

		loop	StarLoop

ExitStars:	ret

DrawStars	ENDP

VISCODE		ENDS

;============================================================================

		END

