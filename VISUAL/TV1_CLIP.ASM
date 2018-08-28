;****************************************************************************
;*
;* TV1_CLIP.ASM
;*
;* Clip routines for TV1 view mode.
;*
;* 04.12.1990 - KJB
;* 29.11.1992 - KJB - TV1_CircleCRT added.
;*
;* Clipping Window Size
;* --------------------
;*
;* 64 * 48 (x = 0 .. 63, y = 0 .. 47), origin at ClipWndwXOrg, ClipWndwYOrg
;*
;* Clipping Pyramid
;* ----------------
;*
;* Pixel aspect ratio = 4:3 (x:y).
;*
;* A clipping window 320 pixels wide requires 320 * 3/4 = 240 pixels high
;* for a +/-45 degree viewing pyramid with a square aspect ratio.
;*
;* For a 64 * 48 clipping window no scaling is required in order to maintain
;* the aspect ratio.
;*
;*    right:  x = y
;*    left : -x = y
;*    above:  z = y
;*    below: -z = y
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	TV1_ScaleVP
		PUBLIC	TV1_CalcCRT
		PUBLIC	TV1_CircleCRT

		PUBLIC	TV1_WIDTH
		PUBLIC	TV1_DEPTH

		EXTRN	Ze:WORD
		EXTRN	ClipWndwXOrg:WORD

		EXTRN	ClipWndwYOrg:BYTE

;============================================================================

		INCLUDE	\LIB8086\USEFUL.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

TV1_WIDTH	EQU	64
TV1_DEPTH	EQU	48

DATA		ENDS

;============================================================================

VISCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:VISCODE
		ASSUME DS:DATA

;* TV1_ScaleVP - scale viewing pyramid
;*
;* pass: )
;* ret : ) Refer to COM_CLIP.ASM
;* kill: )

TV1_ScaleVP	PROC	NEAR

		ret

TV1_ScaleVP	ENDP

;----------------------------------------------------------------------------

;* TV1_CalcCRT - calculate x and y crt values
;*
;* pass: )
;* ret : ) Refer to COM_CLIP.ASM
;* kill: )
;*
;* note: x crt = 32 + (x eye / y eye) * 32
;*       y crt = -(((z eye / y eye) * 24) - 24)

YCrtZero	LABEL	NEAR

		mov	bx,-1
		mov	cx,-1
		stc			;cf = 1 = error
		ret

TV1_CalcCRT	PROC	NEAR

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
		shl	ax,1		;x eye * 64
		rcl	dx,1

;* check for overflow

		test	dx,dx
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

XYCalc: 	sar	dx,1		;x eye * 32
		rcr	ax,1

		idiv	bx		;(x eye / y eye) * 32
		
		add	ax,32		;32 + (x eye / y eye) * 32

		jns	XCrtOk1		;x crt >= 0 ->
		xor	ax,ax
XCrtOk1:	cmp	ax,63
		jbe	XCrtOk2		;x crt <= 63 ->
		mov	ax,63
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
		shl	ax,1		;*16
		rcl	dx,1

		mov	si,ax
		mov	bp,dx

		shl	ax,1		;*32
		rcl	dx,1

		add	ax,si		;z eye * 48
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

ZYCalc: 	sar	dx,1		;z eye * 24
		rcr	ax,1

		idiv	bx		;z eye / y eye * 24
		
		sub	ax,24		;((z eye / y eye) * 24) - 24
		neg	ax		;-(((z eye / y eye) * 24) - 24)

		jns	YCrtOk1		;y crt >= 0 ->
		xor	ax,ax
YCrtOk1:	cmp	ax,47
		jbe	YCrtOk2 	;y crt <= 47 ->
		mov	ax,47
YCrtOk2:	add	al,ClipWndwYOrg	;add y origin
		mov	bx,ax		;bx = y crt value

		pop	si
		clc			;cf = 0 = ok
		ret
	
TV1_CalcCRT	ENDP

;----------------------------------------------------------------------------

;* TV1_CircleCRT - calculate x and y crt values for circles
;*
;* pass: )
;* ret : ) Refer to COM_CLIP.ASM
;* kill: )
;*
;* note: x crt = 32 + (x eye / y eye) * 32
;*       y crt = -(((z eye / y eye) * 24) - 24)

_YCrtZero	LABEL	NEAR

		mov	bx,-1
		mov	cx,-1
		stc			;cf = 1 = error
		ret

TV1_CircleCRT	PROC	NEAR

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
		shl	ax,1		;x eye * 64
		rcl	dx,1

;* check for overflow

		test	dx,dx
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

_XYCalc: 	sar	dx,1		;x eye * 32
		rcr	ax,1

		idiv	bx		;(x eye / y eye) * 32
		
		add	ax,32		;32 + (x eye / y eye) * 32

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
		shl	ax,1		;*16
		rcl	dx,1

		mov	si,ax
		mov	bp,dx

		shl	ax,1		;*32
		rcl	dx,1

		add	ax,si		;z eye * 48
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

_ZYCalc: 	sar	dx,1		;z eye * 24
		rcr	ax,1

		idiv	bx		;z eye / y eye * 24
		
		sub	ax,24		;((z eye / y eye) * 24) - 24
		neg	ax		;-(((z eye / y eye) * 24) - 24)

		add	ax,WORD PTR ClipWndwYOrg	;add y origin

		mov	bx,ax		;bx = y crt value

		pop	si
		clc			;cf = 0 = ok
		ret
	
TV1_CircleCRT	ENDP

VISCODE		ENDS

;============================================================================

		END

