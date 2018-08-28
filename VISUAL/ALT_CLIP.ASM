;****************************************************************************
;*
;* ALT_CLIP.ASM
;*
;* Clip routines for alternate internal view mode.
;*
;* 04.12.1990 - KJB
;* 29.11.1992 - KJB - ALT_CircleCRT added.
;*
;* Clipping Window Size
;* --------------------
;*
;* 320 * 160 (x = 0 .. 319, y = 0 .. 159), origin at 0, 0
;*
;* Clipping Pyramid
;* ----------------
;*
;* Pixel aspect ratio = 4:3 (x:y).
;*
;* A clipping window 320 pixels wide requires 320 * 3/4 = 240 pixels high
;* for a +/-45 degree viewing pyramid with a square aspect ratio.
;*
;* For a 320 * 160 clipping window, scale z eye by 240/160 = 3/2 in order
;* to maintain the aspect ratio.
;*
;*    right:      x = y
;*    left :     -x = y
;*    above:  z*3/2 = y
;*    below: -z*3/2 = y
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	ALT_ScaleVP
		PUBLIC	ALT_CalcCRT
		PUBLIC	ALT_CircleCRT

		PUBLIC	ALT_WIDTH
		PUBLIC	ALT_DEPTH

		EXTRN	Ze:WORD

;============================================================================

		INCLUDE	\LIB8086\USEFUL.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

ALT_WIDTH	EQU	320
ALT_DEPTH	EQU	160

DATA		ENDS

;============================================================================

VISCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:VISCODE
		ASSUME DS:DATA

;* ALT_ScaleVP - scale viewing pyramid
;*
;* pass: )
;* ret : ) Refer to COM_CLIP.ASM
;* kill: )

ALT_ScaleVP	PROC	NEAR

;* check z eye in range

		cmp	cx,21845	;z eye > max input value?
		jg	SetZMax		;yes ->
		cmp	cx,-21845	;z eye < min input value?
		jl	SetZMin		;yes ->

;* scale z eye

		mov	bp,cx
		sar	bp,1		;bp = z eye / 2
		add	cx,bp		;cx = z eye * 3 / 2
		mov	Ze[si],cx
		ret

SetZMax:	mov	cx,32767
		mov	Ze[si],cx
		ret

SetZMin:	mov	cx,-32768
		mov	Ze[si],cx
		ret

ALT_ScaleVP	ENDP

;----------------------------------------------------------------------------

;* ALT_CalcCRT - calculate x and y crt values
;*
;* pass: )
;* ret : ) Refer to COM_CLIP.ASM
;* kill: )
;*
;* note: x crt = 160 + (x eye / y eye) * 160
;*       y crt = -(((z eye / y eye) * 80) - 80)

YCrtZero	LABEL	NEAR

		mov	bx,-1
		mov	cx,-1
		stc			;cf = 1 = error
		ret

ALT_CalcCRT	PROC	NEAR

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

XYCalc:		sar	dx,1		;x eye * 160
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

		mov	si,ax
		mov	bp,dx

		shl	ax,1		;*32
		rcl	dx,1
		shl	ax,1		;*64
		rcl	dx,1

		add	ax,si		;*80
		adc	dx,bp

		shl	ax,1		;z eye * 160
		rcl	dx,1

;* check for overflow

		test	dx,dx
		js	CheckOvZNeg	;z eye < 0 ->

		cmp	dx,bx		;overflow?
		jb	ZYCalc		;no ->

YOverflow:	pop	si
		mov	bx,-1
		mov	cx,-1
		stc			;cf = 1 = error
		ret
	
CheckOvZNeg:	NEG32	dx,ax

		cmp	dx,bx		;overflow?
		jae	YOverflow	;yes ->

		NEG32	dx,ax

ZYCalc:  	sar	dx,1		;z eye * 80
		rcr	ax,1

		idiv	bx		;z eye / y eye * 80
		
		sub	ax,80		;((z eye / y eye) * 80) - 80
		neg	ax		;-(((z eye / y eye) * 80) - 80)

		jns	YCrtOk1		;y crt >= 0 ->
		xor	ax,ax
YCrtOk1:	cmp	ax,159
		jbe	YCrtOk2 	;y crt <= 159 ->
		mov	ax,159
YCrtOk2:	mov	bx,ax		;bx = y crt value

		pop	si
		clc			;cf = 0 = ok
		ret
	
ALT_CalcCRT	ENDP

;----------------------------------------------------------------------------

;* ALT_CircleCRT - calculate x and y crt values for circles
;*
;* pass: )
;* ret : ) Refer to COM_CLIP.ASM
;* kill: )
;*
;* note: x crt = 160 + (x eye / y eye) * 160
;*       y crt = -(((z eye / y eye) * 80) - 80)

_YCrtZero	LABEL	NEAR

		mov	bx,-1
		mov	cx,-1
		stc			;cf = 1 = error
		ret

ALT_CircleCRT	PROC	NEAR

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

_XYCalc:	sar	dx,1		;x eye * 160
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

		mov	si,ax
		mov	bp,dx

		shl	ax,1		;*32
		rcl	dx,1
		shl	ax,1		;*64
		rcl	dx,1

		add	ax,si		;*80
		adc	dx,bp

		shl	ax,1		;z eye * 160
		rcl	dx,1

;* check for overflow

		test	dx,dx
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

_ZYCalc:  	sar	dx,1		;z eye * 80
		rcr	ax,1

		idiv	bx		;z eye / y eye * 80
		
		sub	ax,80		;((z eye / y eye) * 80) - 80
		neg	ax		;-(((z eye / y eye) * 80) - 80)

		mov	bx,ax		;bx = y crt value

		pop	si
		clc			;cf = 0 = ok
		ret
	
ALT_CircleCRT	ENDP

VISCODE		ENDS

;============================================================================

		END

