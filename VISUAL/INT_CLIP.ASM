;****************************************************************************
;*
;* INT_CLIP.ASM
;*
;* Clip routines for internal view mode.
;*
;* 21.11.1990 - KJB
;* 29.11.1992 - KJB - INT_CircleCRT added.
;*
;* Clipping Window Size
;* --------------------
;*
;* 320 * 96 (x = 0 .. 319, y = 0 .. 95), origin at 0, 0
;*
;* Clipping Pyramid
;* ----------------
;*
;* Pixel aspect ratio = 4:3 (x:y).
;*
;* A clipping window 320 pixels wide requires 320 * 3/4 = 240 pixels high
;* for a +/-45 degree viewing pyramid with a square aspect ratio.
;*
;* For a 320 * 96 clipping window, scale z eye by 240/96 = 5/2 in order
;* to maintain the aspect ratio.
;*
;*    right:      x = y
;*    left :     -x = y
;*    above:  z*5/2 = y
;*    below: -z*5/2 = y
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	INT_ScaleVP
		PUBLIC	INT_CalcCRT
		PUBLIC	INT_CircleCRT

		PUBLIC	INT_WIDTH
		PUBLIC	INT_DEPTH

		EXTRN	Ze:WORD

;============================================================================

		INCLUDE	\LIB8086\USEFUL.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

INT_WIDTH	EQU	320
INT_DEPTH	EQU	96

DATA		ENDS

;============================================================================

VISCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:VISCODE
		ASSUME DS:DATA

;* INT_ScaleVP - scale viewing pyramid
;*
;* pass: )
;* ret : ) Refer to COM_CLIP.ASM
;* kill: )

INT_ScaleVP	PROC	NEAR

;* check z eye in range

		cmp	cx,13107	;z eye > max input value?  32,767 x 2/5
		jg	SetZMax		;yes ->
		cmp	cx,-13107	;z eye < min input value?
		jl	SetZMin		;yes ->

;* scale z eye

		mov	bp,cx		;bp = z eye
		sar	bp,1		;bp = z eye / 2
		shl	cx,1		;cx = z eye * 2
		add	cx,bp		;cx = z eye * 5 / 2
		mov	Ze[si],cx
		ret

SetZMax:	mov	cx,32767
		mov	Ze[si],cx
		ret

SetZMin:	mov	cx,-32768
		mov	Ze[si],cx
		ret

INT_ScaleVP	ENDP

;----------------------------------------------------------------------------

;* INT_CalcCRT - calculate x and y crt values
;*
;* pass: )
;* ret : ) Refer to COM_CLIP.ASM
;* kill: )
;*
;* note: x crt = 160 + (x eye / y eye) * 160
;*       y crt = -(((z eye / y eye) * 48) - 48)

YCrtZero	LABEL	NEAR

		mov	bx,-1
		mov	cx,-1
		stc			;cf = 1 = error
		ret

INT_CalcCRT	PROC	NEAR

		test	bx,bx		;y eye <= 0?
		jle	YCrtZero	;yes ->

		push	si

;------------
;* calc x crt
;------------

		cwd

		mov	dh,dl		;*256
		mov	dl,ah
		mov	ah,al
		xor	al,al

		mov	si,ax
		mov	bp,dx

		sar	bp,1		;*128
		rcr	si,1
		sar	bp,1		;*64
		rcr	si,1

		add	ax,si		;x eye * 320
		adc	dx,bp

;* check for overflow

		js	CheckOvXNeg	;x eye < 0 ->

		cmp	dx,bx		;overflow?
		jb	XYCalc     	;no ->

XOverflow:	pop	si
		mov	bx,-1
		mov	cx,-1
		stc			;cf = 1 = error
		ret

CheckOvXNeg: 	NEG32	dx,ax

		cmp	dx,bx		;overflow?
		jae	XOverflow	;yes ->

		NEG32	dx,ax

XYCalc: 	sar	dx,1		;x eye * 160
		rcr	ax,1

		idiv	bx		;(x eye / y eye) * 160
		
		add	ax,160		;160 + (x eye / y eye) * 160

		jns	XCrtOk1		;x crt >= 0 ->
		xor	ax,ax
XCrtOk1:	cmp	ax,319
		jbe	XCrtOk2		;x crt <= 319 ->
		mov	ax,319
XCrtOk2:	xchg	ax,cx		;cx = x crt value

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
		shl	ax,1		;*16
		rcl	dx,1
		shl	ax,1		;*32
		rcl	dx,1

		mov	si,ax
		mov	bp,dx

		shl	ax,1		;*64
		rcl	dx,1

		add	ax,si		;z eye * 96
		adc	dx,bp

;* check for overflow

		js	CheckOvZNeg	;z eye < 0 ->

		cmp	dx,bx		;overflow?
		jb	ZYCalc	;no ->

YOverflow:	pop	si
		mov	bx,-1
		mov	cx,-1
		stc			;cf = 1 = error
		ret
	
CheckOvZNeg:	NEG32	dx,ax

		cmp	dx,bx		;overflow?
		jae	YOverflow	;yes ->

		NEG32	dx,ax

ZYCalc:  	sar	dx,1		;z eye * 48
		rcr	ax,1

		idiv	bx		;z eye / y eye * 48
		
		sub	ax,48		;((z eye / y eye) * 48) - 48
		neg	ax		;-(((z eye / y eye) * 48) - 48)

		jns	YCrtOk1		;y crt >= 0 ->
		xor	ax,ax
YCrtOk1:	cmp	ax,95	
		jbe	YCrtOk2 	;y crt <= 95 ->
		mov	ax,95
YCrtOk2:	mov	bx,ax		;bx = y crt value

		pop	si
		clc			;cf = 0 = ok
		ret
	
INT_CalcCRT	ENDP

;----------------------------------------------------------------------------

;* INT_CircleCRT - calculate x and y crt values for circles
;*
;* pass: )
;* ret : ) Refer to COM_CLIP.ASM
;* kill: )
;*
;* note: x crt = 160 + (x eye / y eye) * 160
;*       y crt = -(((z eye / y eye) * 48) - 48)

_YCrtZero	LABEL	NEAR

		mov	bx,-1
		mov	cx,-1
		stc			;cf = 1 = error
		ret

INT_CircleCRT	PROC	NEAR

		test	bx,bx		;y eye <= 0?
		jle	_YCrtZero	;yes ->

		push	si

;------------
;* calc x crt
;------------

		cwd

		mov	dh,dl		;*256
		mov	dl,ah
		mov	ah,al
		xor	al,al

		mov	si,ax
		mov	bp,dx

		sar	bp,1		;*128
		rcr	si,1
		sar	bp,1		;*64
		rcr	si,1

		add	ax,si		;x eye * 320
		adc	dx,bp

;* check for overflow

		js	_CheckOvXNeg	;x eye < 0 ->

		cmp	dx,bx		;overflow?
		jb	_XYCalc     	;no ->

_XOverflow:	pop	si
		mov	bx,-1
		mov	cx,-1
		stc			;cf = 1 = error
		ret

_CheckOvXNeg: 	NEG32	dx,ax

		cmp	dx,bx		;overflow?
		jae	_XOverflow	;yes ->

		NEG32	dx,ax

_XYCalc: 	sar	dx,1		;x eye * 160
		rcr	ax,1

		idiv	bx		;(x eye / y eye) * 160
		
		add	ax,160		;160 + (x eye / y eye) * 160

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
		shl	ax,1		;*16
		rcl	dx,1
		shl	ax,1		;*32
		rcl	dx,1

		mov	si,ax
		mov	bp,dx

		shl	ax,1		;*64
		rcl	dx,1

		add	ax,si		;z eye * 96
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
	
_CheckOvZNeg:	NEG32	dx,ax

		cmp	dx,bx		;overflow?
		jae	_YOverflow	;yes ->

		NEG32	dx,ax

_ZYCalc:  	sar	dx,1		;z eye * 48
		rcr	ax,1

		idiv	bx		;z eye / y eye * 48
		
		sub	ax,48		;((z eye / y eye) * 48) - 48
		neg	ax		;-(((z eye / y eye) * 48) - 48)

		mov	bx,ax		;bx = y crt value

		pop	si
		clc			;cf = 0 = ok
		ret
	
INT_CircleCRT	ENDP

VISCODE		ENDS

;============================================================================

		END

