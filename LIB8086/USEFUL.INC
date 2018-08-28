;****************************************************************************
;*
;* USEFUL.INC
;*
;* Miscellaneous useful macros.
;*
;* 20.06.1989 - KJB
;* 10.03.1992 - KJB - ROUNDUP added.
;*
;****************************************************************************

;* ABSV - absolute value
;*
;* pass: al = signed value
;* ret : al = ABS(al)
;*       ah = SIGN(al) (0 or -1)
;* kill: flags
;*
;* pass: ax = signed value
;* ret : ax = ABS(ax)
;*       dx = SIGN(ax) (0 or -1)
;* kill: flags

ABSV		MACRO	reg

		IFIDNI	<reg>,<al>
		cbw
		xor	al,ah		;1s comp
		sub	al,ah		;2s comp
		ENDIF

		IFIDNI	<reg>,<ax>
		cwd
		xor	ax,dx		;1s comp
		sub	ax,dx		;2s comp
		ENDIF

		ENDM

;----------------------------------------------------------------------------

;* SGNV - sign value
;*
;* pass: al = signed value
;* ret : ah = SGN(al) (-1, 0 or 1)
;* kill: flags
;*
;* pass: ax = signed value
;* ret : dx = SGN(ax) (-1, 0 or 1)
;* kill: flags

SGNV		MACRO	reg

		IFIDNI	<reg>,<al>
		cbw	    		;ah = -1 or 0
		cmp	al,1		;cf = 1 if al = 0
		cmc			;cf = 1 if al <> 0
		rcl	ah,1		;ah = -1, 0 or 1
		ENDIF

		IFIDNI	<reg>,<ax>
		cwd	    		;dx = -1 or 0
		cmp	ax,1		;cf = 1 if ax = 0
		cmc			;cf = 1 if ax <> 0
		rcl	dx,1		;ax = -1, 0 or 1
		ENDIF

		ENDM

;----------------------------------------------------------------------------

;* MAXM - limit to maximum value
;*
;* pass: al = sum (value just added to al)
;*       cf = valid (do not use inc)
;* ret : pass cf = 0, al = al
;*       pass cf = 1, al = 255
;* kill: ah, flags
;*
;* pass: ax = sum (value just added to ax)
;*       cf = valid (do not use inc)
;* ret : pass cf = 0, ax = ax
;*       pass cf = 1, ax = 65535
;* kill: dx, flags

MAXM		MACRO	reg

		IFIDNI	<reg>,<al>
		rcr	al,1
		cbw			;if passed cf = 1 then ah = 0ffh
		rcl	al,1
		or	al,ah
		ENDIF

		IFIDNI	<reg>,<ax>
		rcr	ax,1
		cwd			;if passed cf = 1 then dx = 0ffffh
		rcl	ax,1
		or	ax,dx
		ENDIF

		ENDM

;----------------------------------------------------------------------------

;* MINM - limit to minimum value
;*
;* pass: al = difference (value just subtracted from al)
;*       cf = valid (do not use dec)
;* ret : pass cf = 0, al = al
;*       pass cf = 1, al = 0
;*       zf is valid
;* kill: ah, flags
;*
;* pass: ax = difference (value just subtracted from ax)
;*       cf = valid (do not use dec)
;* ret : pass cf = 0, ax = ax
;*       pass cf = 1, ax = 0
;*       zf is valid
;* kill: dx, flags

MINM		MACRO	reg

		IFIDNI	<reg>,<al>
		cmc
		rcr	al,1
		cbw			;if passed cf = 1 then ah = 0
		rcl	al,1
		and	al,ah
		ENDIF

		IFIDNI	<reg>,<ax>
		cmc
		rcr	ax,1
		cwd			;if passed cf = 1 then dx = 0
		rcl	ax,1
		and	ax,dx
		ENDIF

		ENDM

;----------------------------------------------------------------------------

;* FAST_MOVE
;*
;* pass: ds:si -> source
;*       es:di -> dest
;*       cx = number of bytes to move
;* ret : source copied to dest
;* kill: cx, si, di, flags

FAST_MOVE	MACRO

		shr	cx,1		;calc number of words to move
		rep	movsw
		rcl	cx,1		;remaining byte (if any)
		rep	movsb

		ENDM

;----------------------------------------------------------------------------

;* CALC_RDEG
;*
;* pass: ax = pseudo degress (0 .. 511)
;* ret : dx = real degrees (0 .. 359)
;* kill: ax, flags

CALC_RDEG	MACRO

		mov	dx,46080
		mul	dx		;pdeg * (360 / 512)
		shl	ax,1		;1/2 bit round up
		adc	dx,0

		ENDM

;----------------------------------------------------------------------------

;* FRACADJ - adjust result of signed fractional multiply
;*
;* pass: dx, ax = signed 32-bit number
;* ret : dest
;*       flags (zf, sf may be useful)
;* kill: ax, dx (unless specified as dest)

FRACADJ		MACRO	dest

		shl	ax,1		;*2
		rcl	dx,1
		shl	ax,1		;1/2 bit round up
		adc	dx,0
		IFDIFI	<dest>,<dx>
		mov	dest,dx
		ENDIF

		ENDM

;----------------------------------------------------------------------------

;* SSDRAW - "shifted" sprite draw
;*
;* pass: x = x co-ord
;*       y = y co-ord
;*       ptr = sprite pointer
;* ret : nothing
;* kill: assume all

SSDRAW		MACRO	x,y,ptr

		mov	SpriteX,x
		mov	SpriteY,y
		mov	SpritePtr,OFFSET ptr
		
		mov	si,OFFSET Sprite
		call	SSprite

		ENDM

;----------------------------------------------------------------------------

;* MSDRAW - "masked" sprite draw
;*
;* pass: x = x co-ord
;*       y = y co-ord
;*       ptr = sprite pointer
;* ret : nothing
;* kill: assume all

MSDRAW		MACRO	x,y,ptr

		mov	SpriteX,x
		mov	SpriteY,y
		mov	SpritePtr,OFFSET ptr
		
		mov	si,OFFSET Sprite
		call	MSprite

		ENDM

;----------------------------------------------------------------------------

;* BSDRAW - "block" sprite draw
;*
;* pass: x = x co-ord
;*       y = y co-ord
;*       ptr = sprite pointer
;* ret : nothing
;* kill: assume all

BSDRAW		MACRO	x,y,ptr

		mov	SpriteX,x
		mov	SpriteY,y
		mov	SpritePtr,OFFSET ptr
		
		mov	si,OFFSET Sprite
		call	BSprite

		ENDM

;----------------------------------------------------------------------------

;* QSDRAW - "quick" sprite draw
;*
;* pass: x = x co-ord
;*       y = y co-ord
;*       ptr = sprite pointer
;* ret : nothing
;* kill: assume all

QSDRAW		MACRO	x,y,ptr

		mov	SpriteX,x
		mov	SpriteY,y
		mov	SpritePtr,OFFSET ptr
		
		mov	si,OFFSET Sprite
		call	QSprite

		ENDM

;----------------------------------------------------------------------------

;* ES_LODSB - lodsb instruction with extra segment override
;*
;* pass: es:si -> data
;* ret : al = data
;*       es:si -> data + 1
;* kill: nothing

ES_LODSB	MACRO

		DB	026h		;extra-segment override
		lodsb

		ENDM

;----------------------------------------------------------------------------

;* ES_LODSW - lodsw instruction with extra segment override
;*
;* pass: es:si -> data
;* ret : ax = data
;*       es:si -> data + 2
;* kill: nothing

ES_LODSW	MACRO

		DB	026h		;extra-segment override
		lodsw

		ENDM

;----------------------------------------------------------------------------

;* NEG32 - 32-bit negate
;*
;* pass: reg_hi, reg_lo
;* ret : reg_hi, reg_lo = NEG(reg_hi, reg_lo)
;*	 flags (sf is valid)
;* kill: flags (except sf)

NEG32		MACRO	reg_hi,reg_lo
	
		not	reg_lo
		not	reg_hi
		add	reg_lo,1
		adc	reg_hi,0

		ENDM

;----------------------------------------------------------------------------

;* SBOUND - check signed number is within lower and upper limits
;*
;* pass: n, lo, hi
;* ret : n
;* kill: flags

SBOUND		MACRO	n,lo,hi
		LOCAL	TestHi,TestOk

		cmp	n,lo
		jge	TestHi
		mov	n,lo
		jmp	TestOk
TestHi:		cmp	n,hi
		jle	TestOk
		mov	n,hi
TestOk:
		ENDM

;----------------------------------------------------------------------------

;* UBOUND - check unsigned number is within lower and upper limits
;*
;* pass: n, lo, hi
;* ret : n
;* kill: flags

UBOUND		MACRO	n,lo,hi
		LOCAL	TestHi,TestOk

		cmp	n,lo
		jae	TestHi
		mov	n,lo
		jmp	TestOk
TestHi:		cmp	n,hi
		jbe	TestOk
		mov	n,hi
TestOk:
		ENDM

;----------------------------------------------------------------------------

;* ROUNDUP - 1/2 bit round up
;*
;* pass: n (cf valid)
;* ret : n
;* kill: flags (zf valid)

ROUNDUP		MACRO	n

		adc	n,0

		ENDM

;----------------------------------------------------------------------------

;----------------------------------------
;* MACROs for "near" conditional branches
;----------------------------------------

;----------------------------
_JC		MACRO	label
		LOCAL	skip
		jnc	skip
		jmp	label
skip:
		ENDM
;----------------------------
_JNC		MACRO	label
		LOCAL	skip
		jc	skip
		jmp	label
skip:
		ENDM
;----------------------------
_JZ		MACRO	label
		LOCAL	skip
		jnz	skip
		jmp	label
skip:
		ENDM
;----------------------------
_JNZ		MACRO	label
		LOCAL	skip
		jz	skip
		jmp	label
skip:
		ENDM
;----------------------------
_JE		MACRO	label
		LOCAL	skip
		jne	skip
		jmp	label
skip:
		ENDM
;----------------------------
_JNE		MACRO	label
		LOCAL	skip
		je	skip
		jmp	label
skip:
		ENDM
;----------------------------
_JS		MACRO	label
		LOCAL	skip
		jns	skip
		jmp	label
skip:
		ENDM
;----------------------------
_JNS		MACRO	label
		LOCAL	skip
		js	skip
		jmp	label
skip:
		ENDM
;----------------------------
_JO		MACRO	label
		LOCAL	skip
		jno	skip
		jmp	label
skip:
		ENDM
;----------------------------
_JNO		MACRO	label
		LOCAL	skip
		jo	skip
		jmp	label
skip:
		ENDM
;----------------------------
_JP		MACRO	label
		LOCAL	skip
		jnp	skip
		jmp	label
skip:
		ENDM
;----------------------------
_JNP		MACRO	label
		LOCAL	skip
		jp	skip
		jmp	label
skip:
		ENDM
;----------------------------
_JA		MACRO	label
		LOCAL	skip
		jbe	skip
		jmp	label
skip:
		ENDM
;----------------------------
_JAE		MACRO	label
		LOCAL	skip
		jb	skip
		jmp	label
skip:
		ENDM
;----------------------------
_JB		MACRO	label
		LOCAL	skip
		jae	skip
		jmp	label
skip:
		ENDM
;----------------------------
_JBE		MACRO	label
		LOCAL	skip
		ja	skip
		jmp	label
skip:
		ENDM
;----------------------------
_JG		MACRO	label
		LOCAL	skip
		jle	skip
		jmp	label
skip:
		ENDM
;----------------------------
_JGE		MACRO	label
		LOCAL	skip
		jl	skip
		jmp	label
skip:
		ENDM
;----------------------------
_JL		MACRO	label
		LOCAL	skip
		jge	skip
		jmp	label
skip:
		ENDM
;----------------------------
_JLE		MACRO	label
		LOCAL	skip
		jg	skip
		jmp	label
skip:
		ENDM
;----------------------------
_LOOP		MACRO	label
		LOCAL	skip
		dec	cx
		jz	skip
		jmp	label
skip:
		ENDM
;----------------------------
_JCXZ		MACRO	label
		LOCAL	skip
		test	cx,cx
		jnz	skip
		jmp	label
skip:
		ENDM
;----------------------------
