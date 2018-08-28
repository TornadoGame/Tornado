;****************************************************************************
;*
;* TV3_CLIP.ASM
;*
;* Clip routines for TV3 view mode.
;*
;* 04.12.1990 - KJB
;* 29.11.1992 - KJB - TV3_CircleCRT added.
;*
;* Clipping Window Size
;* --------------------
;*
;* 96 * 72 (x = 0 .. 95, y = 0 .. 71), origin at ClipWndwXOrg, ClipWndwYOrg
;*
;* Clipping Pyramid
;* ----------------
;*
;* Pixel aspect ratio = 4:3 (x:y).
;*
;* A clipping window 320 pixels wide requires 320 * 3/4 = 240 pixels high
;* for a +/-45 degree viewing pyramid with a square aspect ratio.
;*
;* For a 96 * 72 clipping window no scaling is required in order to maintain
;* the aspect ratio.
;*
;*    right:  x = y
;*    left : -x = y
;*    above:  z = y
;*    below: -z = y
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	TV3_ScaleVP
		PUBLIC	TV3_CalcCRT
		PUBLIC	TV3_CircleCRT

		PUBLIC	TV3_WIDTH
		PUBLIC	TV3_DEPTH

		EXTRN	Ze:WORD
		EXTRN	ClipWndwXOrg:WORD

		EXTRN	ClipWndwYOrg:BYTE

;============================================================================

		INCLUDE	\LIB8086\USEFUL.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

TV3_WIDTH	EQU	96
TV3_DEPTH	EQU	72

DATA		ENDS

;============================================================================

VISCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:VISCODE
		ASSUME DS:DATA

;* TV3_ScaleVP - scale viewing pyramid
;*
;* pass: )
;* ret : ) Refer to COM_CLIP.ASM
;* kill: )

TV3_ScaleVP	PROC	NEAR

		ret

TV3_ScaleVP	ENDP

;----------------------------------------------------------------------------

;* TV3_CalcCRT - calculate x and y crt values
;*
;* pass: )
;* ret : ) Refer to COM_CLIP.ASM
;* kill: )
;*
;* note: x crt = 48 + (x eye / y eye) * 48
;*       y crt = -(((z eye / y eye) * 36) - 36)

YCrtZero	LABEL	NEAR

		mov	bx,-1
		mov	cx,-1
		stc			;cf = 1 = error
		ret

TV3_CalcCRT	PROC	NEAR

		test	bx,bx		;y eye <= 0?
		jle	YCrtZero	;yes ->

		push	si

;------------
;* calc x crt
;------------

		cwd

		shl	ax,1		;*2
		rcl	dx,1
		shl	ax,1		;*4
		rcl	dx,1
		shl	ax,1		;*8
		rcl	dx,1
		shl	ax,1		;*16
		rcl	dx,1
		shl	ax,1		;*32
		rcl	dx,1

		mov	si,ax
		mov	bp,dx

		shl	ax,1		;*64
		rcl	dx,1

		add	ax,si		;x eye * 96
		adc	dx,bp

;* check for overflow

		js	CheckOvXNeg	;x eye < 0 ->

		cmp	dx,bx		;overflow?
		jb	XYCalc		;no ->

XOverflow:	pop	si
		mov	bx,-1
		mov	cx,-1
		stc			;cf = 1 = error
		ret

CheckOvXNeg:	NEG32	dx,ax

		cmp	dx,bx		;overflow?
		jae	XOverflow	;yes ->

		NEG32	dx,ax

XYCalc: 	sar	dx,1		;x eye * 48
		rcr	ax,1

		idiv	bx		;(x eye / y eye) * 48
		
		add	ax,48		;48 + (x eye / y eye) * 48

		jns	XCrtOk1		;x crt >= 0 ->
		xor	ax,ax
XCrtOk1:	cmp	ax,95
		jbe	XCrtOk2		;x crt <= 95 ->
		mov	ax,95
XCrtOk2:	add	ax,ClipWndwXOrg	;add x origin
		xchg	ax,cx		;cx = x crt value

;------------
;* calc y crt
;------------

		cwd

		shl	ax,1		;*2
		rcl	dx,1
		shl	ax,1		;*4
		rcl	dx,1
		shl	ax,1		;*8
		rcl	dx,1

		mov	si,ax
		mov	bp,dx

		shl	ax,1		;*16
		rcl	dx,1
		shl	ax,1		;*32
		rcl	dx,1
		shl	ax,1		;*64
		rcl	dx,1

		add	ax,si		;z eye * 72
		adc	dx,bp

;* check for overflow

		js	CheckOvZNeg	;z eye < 0 ->

		cmp	dx,bx		;overflow?
		jb	ZYCalc		;no ->

YOverflow:	pop	si
		mov	bx,-1
		mov	cx,-1
		stc			;cf = 1 = error
		ret

CheckOvZNeg:  	NEG32	dx,ax

		cmp	dx,bx		;overflow?
		jae	YOverflow	;yes ->

		NEG32	dx,ax

ZYCalc: 	sar	dx,1		;z eye * 36
		rcr	ax,1

		idiv	bx		;z eye / y eye * 36
		
		sub	ax,36		;((z eye / y eye) * 36) - 36
		neg	ax		;-(((z eye / y eye) * 36) - 36)

		jns	YCrtOk1		;y crt >= 0 ->
		xor	ax,ax
YCrtOk1:	cmp	ax,71
		jbe	YCrtOk2 	;y crt <= 71 ->
		mov	ax,71
YCrtOk2:	add	al,ClipWndwYOrg	;add y origin
		mov	bx,ax		;bx = y crt value

		pop	si
		clc			;cf = 0 = ok
		ret
	
TV3_CalcCRT	ENDP

;----------------------------------------------------------------------------

;* TV3_CircleCRT - calculate x and y crt values for circles
;*
;* pass: )
;* ret : ) Refer to COM_CLIP.ASM
;* kill: )
;*
;* note: x crt = 48 + (x eye / y eye) * 48
;*       y crt = -(((z eye / y eye) * 36) - 36)

_YCrtZero	LABEL	NEAR

		mov	bx,-1
		mov	cx,-1
		stc			;cf = 1 = error
		ret

TV3_CircleCRT	PROC	NEAR

		test	bx,bx		;y eye <= 0?
		jle	_YCrtZero	;yes ->

		push	si

;------------
;* calc x crt
;------------

		cwd

		shl	ax,1		;*2
		rcl	dx,1
		shl	ax,1		;*4
		rcl	dx,1
		shl	ax,1		;*8
		rcl	dx,1
		shl	ax,1		;*16
		rcl	dx,1
		shl	ax,1		;*32
		rcl	dx,1

		mov	si,ax
		mov	bp,dx

		shl	ax,1		;*64
		rcl	dx,1

		add	ax,si		;x eye * 96
		adc	dx,bp

;* check for overflow

		js	_CheckOvXNeg	;x eye < 0 ->

		cmp	dx,bx		;overflow?
		jb	_XYCalc		;no ->

_XOverflow:	pop	si
		mov	bx,-1
		mov	cx,-1
		stc			;cf = 1 = error
		ret

_CheckOvXNeg:	NEG32	dx,ax

		cmp	dx,bx		;overflow?
		jae	_XOverflow	;yes ->

		NEG32	dx,ax

_XYCalc: 	sar	dx,1		;x eye * 48
		rcr	ax,1

		idiv	bx		;(x eye / y eye) * 48
		
		add	ax,48		;48 + (x eye / y eye) * 48

		add	ax,ClipWndwXOrg	;add x origin

		xchg	ax,cx		;cx = x crt value

;------------
;* calc y crt
;------------

		cwd

		shl	ax,1		;*2
		rcl	dx,1
		shl	ax,1		;*4
		rcl	dx,1
		shl	ax,1		;*8
		rcl	dx,1

		mov	si,ax
		mov	bp,dx

		shl	ax,1		;*16
		rcl	dx,1
		shl	ax,1		;*32
		rcl	dx,1
		shl	ax,1		;*64
		rcl	dx,1

		add	ax,si		;z eye * 72
		adc	dx,bp

;* check for overflow

		js	_CheckOvZNeg	;z eye < 0 ->

		cmp	dx,bx		;overflow?
		jb	_ZYCalc		;no ->

_YOverflow:	pop	si
		mov	bx,-1
		mov	cx,-1
		stc			;cf = 1 = error
		ret

_CheckOvZNeg:  	NEG32	dx,ax

		cmp	dx,bx		;overflow?
		jae	_YOverflow	;yes ->

		NEG32	dx,ax

_ZYCalc: 	sar	dx,1		;z eye * 36
		rcr	ax,1

		idiv	bx		;z eye / y eye * 36
		
		sub	ax,36		;((z eye / y eye) * 36) - 36
		neg	ax		;-(((z eye / y eye) * 36) - 36)

		add	ax,WORD PTR ClipWndwYOrg	;add y origin

		mov	bx,ax		;bx = y crt value

		pop	si
		clc			;cf = 0 = ok
		ret
	
TV3_CircleCRT	ENDP

VISCODE		ENDS

;============================================================================

		END

