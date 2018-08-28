;****************************************************************************
;*
;* CHSPRITE.ASM
;*
;* Character sprites.
;*
;* 25.03.1992 - KJB
;* 14.04.1992 - KJB - CellSprite added.
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	CharSprite
		PUBLIC	CellSprite

		PUBLIC	CellXMin
		PUBLIC	CellXMax
		PUBLIC	CellYMin
		PUBLIC	CellYMax

		EXTRN	SetPixel:FAR

		EXTRN	Standard_3by5:BYTE

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

CellXMin	DW	0
CellXMax	DW	319
CellYMin	DW	0
CellYMax	DW	199

Col		DB	0,0

DATA		ENDS

;============================================================================

LIBCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:LIBCODE
		ASSUME DS:DATA

;* CharSprite - draw 3 * 5 character as clipped sprite
;*
;* pass: al = logical colour
;*       dl = ASCII character
;*       cx = x co-ord (char centre)
;*       bx = y co-ord (char centre)
;* ret : nothing
;* kill: assume all

CharSprite	PROC	FAR

		mov	Col,al

;* offset x, y to top lh corner of char

		sub	cx,1
		sub	bx,2

;* calc ptr to char cell data

		sub	dl,' '		;char set starts with space
		xor	dh,dh

		mov	si,OFFSET Standard_3by5

		add	si,dx		;char * 1
		shl	dx,1		;*2
		shl	dx,1		;*4
		add	si,dx		;char * 5

;* y print loop

		mov	ah,5		;y cntr

		jmp	YLoop

NextY:		inc	bx		;y = y + 1
		dec	ah
		jnz	YLoop

		ret

YLoop:		lodsb			;fetch char cell data

		test	al,al		;blank?
		jz	NextY		;yes ->

		cmp	bx,CellYMin	;above clipping window?
		jl	NextY		;yes ->
		cmp	bx,CellYMax	;below clipping window?
		jg	NextY		;yes ->

		push	cx		;store x co-ord

		REPT	4		;x loop

		shl	al,1		;draw pixel?
		jnc	@F		;no ->

		cmp	cx,CellXMin	;left of clipping window?
		jl	@F		;yes ->
		cmp	cx,CellXMax	;right of clipping window?
      		jg	@F		;yes ->

		push	ax
		push	bx
		push	cx
		push	si

		mov	al,Col
		call	SetPixel

		pop	si
		pop	cx
		pop	bx
		pop	ax

@@:		inc	cx		;x = x + 1

		ENDM

		pop	cx		;restore x co-ord

		jmp	NextY

		ret

CharSprite	ENDP

;----------------------------------------------------------------------------

;* CellSprite - draw 8 * 8 cell sprite
;*
;* pass: al = logical colour
;*       cx = x co-ord (char centre)
;*       bx = y co-ord (char centre)
;*	 si -> cell data
;* ret : nothing
;* kill: assume all
;*
;* note: Data format:-
;*
;*       (bits) 76543210 
;*       	...1.... 0 (bytes)
;*       	...1.... 1
;*       	........ 2
;*       	11.1.11. 3 (cell centre at byte 3, bit 4)
;*       	........ 4
;*       	...1.... 5
;*       	...1.... 6
;*       	........ 7

CellSprite	PROC	FAR

		mov	Col,al

;* offset x, y to top lh corner of cell

		sub	cx,3
		sub	bx,3

;* y print loop

		mov	ah,8		;y cntr

		jmp	CellYLoop

CellNextY:	inc	bx		;y = y + 1
		dec	ah
		jnz	CellYLoop

		ret

CellYLoop:	lodsb			;fetch char cell data

		test	al,al		;blank?
		jz	CellNextY	;yes ->

		cmp	bx,CellYMin	;above clipping window?
		jl	CellNextY	;yes ->
		cmp	bx,CellYMax	;below clipping window?
		jg	CellNextY 	;yes ->

		push	cx		;store x co-ord

		REPT	8		;x loop

		shl	al,1		;draw pixel?
		jnc	@F		;no ->

		cmp	cx,CellXMin	;left of clipping window?
		jl	@F		;yes ->
		cmp	cx,CellXMax	;right of clipping window?
      		jg	@F		;yes ->

		push	ax
		push	bx
		push	cx
		push	si

		mov	al,Col
		call	SetPixel

		pop	si
		pop	cx
		pop	bx
		pop	ax

@@:		inc	cx		;x = x + 1

		ENDM

		pop	cx		;restore x co-ord

		jmp	CellNextY

		ret

CellSprite	ENDP

LIBCODE		ENDS

;============================================================================

		END

