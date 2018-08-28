;****************************************************************************
;*
;* POLYFILL.ASM
;*
;* Polygon fill routines.
;*
;* 10.12.1990 - KJB - PolyFill routines extracted from COM_DRVR.ASM.
;* 21.12.1990 - KJB - New octant routines added (faster and more accurate).
;* 12.03.1991 - KJB - PolyLine added.
;* 29.07.1991 - KJB - SmokeFill / RvrsSmokeFill added.
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	PolyFill
		PUBLIC	RvrsPolyFill
		PUBLIC	MeshFill
		PUBLIC	RvrsMeshFill
		PUBLIC	SmokeFill
		PUBLIC	RvrsSmokeFill
		PUBLIC	PolyLine

		PUBLIC	FillVector

		PUBLIC	MinY
		PUBLIC	MaxY
		PUBLIC	LhsX
		PUBLIC	RhsX

		EXTRN	LineDraw:FAR

		EXTRN	PolyCount:WORD
		EXTRN	_PolyFill:WORD
		EXTRN	_MeshFill:WORD
		EXTRN	_SmokeFill:WORD

		EXTRN	Palette:BYTE
		EXTRN	FillCol:BYTE

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

MinY		DW	0
MaxY		DW	0

LhsPtr		DW	0
RhsPtr		DW	0

LhsX		DW	200 DUP(0)
RhsX		DW	200 DUP(0)

BUF_SIZE	EQU	SIZE LhsX

OldX		DW	0
OldY		DW	0
NewX		DW	0
NewY		DW	0

FillVector	DW	0		;PolyFill / MeshFill vector routine

OctantBase	DW	0		;octant table base address

Octant  	DW	Octant2		;Dx > 0, Dy > 0, Dy > Dx
		DW	Octant1		;Dx > 0, Dy > 0, Dx > Dy
		DW	Octant3		;Dx > 0, Dy < 0, Dy > Dx
		DW	Octant4		;Dx > 0, Dy < 0, Dx > Dy
		DW	Octant7		;Dx < 0, Dy > 0, Dy > Dx
		DW	Octant8		;Dx < 0, Dy > 0, Dx > Dy
		DW	Octant6		;Dx < 0, Dy < 0, Dy > Dx
		DW	Octant5		;Dx < 0, Dy < 0, Dx > Dy

RvrsOctant 	DW	RvrsOctant2 	;Dx > 0, Dy > 0, Dy > Dx
		DW	RvrsOctant1 	;Dx > 0, Dy > 0, Dx > Dy
		DW	RvrsOctant3 	;Dx > 0, Dy < 0, Dy > Dx
		DW	RvrsOctant4 	;Dx > 0, Dy < 0, Dx > Dy
		DW	RvrsOctant7 	;Dx < 0, Dy > 0, Dy > Dx
		DW	RvrsOctant8 	;Dx < 0, Dy > 0, Dx > Dy
		DW	RvrsOctant6 	;Dx < 0, Dy < 0, Dy > Dx
		DW	RvrsOctant5 	;Dx < 0, Dy < 0, Dx > Dy

TempCol		DB	0,0

DATA		ENDS

;============================================================================

GCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:GCODE
		ASSUME DS:DATA

;* PolyFill - fill polygon (clockwise)
;* MeshFill - fill "transparent" polygon (clockwise)
;* SmokeFill - fill "smoke" polygon (clockwise)
;* RvrsPolyFill - fill polygon (anti-clockwise)
;* RvrsMeshFill - fill "transparent" polygon (anti-clockwise)
;* RvrsSmokeFill - fill "smoke" polygon (anti-clockwise)
;*
;* pass: al = logical colour
;*       si -> co-ord list: x1, y1
;*                          x2, y2
;*                          x3, y3
;*                          ..  ..
;*                          xn, yn
;*                          x1, y1 (first point repeated)
;*                          -1     (terminator) 
;* ret : si -> next polygon data
;* kill: assume all
;*
;* note: Some drivers use FillCol as a word.

PolyDone	LABEL	NEAR

		inc	PolyCount

		mov	bp,FillVector
		jmp	bp

PolyFill	PROC	FAR

		mov	bx,OFFSET Palette
		xlat
		mov	ah,al
		mov	WORD PTR FillCol,ax

		mov	ax,_PolyFill
		mov	FillVector,ax

		mov	ax,OFFSET Octant

IntoPolyFill:	mov	OctantBase,ax	;store octant table base address

	 	lodsw		  	;fetch first point - x1, y1
		mov 	OldX,ax
		lodsw
		mov 	OldY,ax
		mov	MinY,ax
		mov	MaxY,ax
		mov	bx,ax
		shl 	bx,1 		;word access

		mov 	ax,OFFSET RhsX  ;init RhsPtr wrt y1
		add	ax,bx
		mov	RhsPtr,ax

		mov 	di,ax  		;store first point 
		mov 	ax,OldX
		stosw

		mov 	ax,OFFSET LhsX	;init LhsPtr wrt y1
		add 	ax,bx
		mov 	LhsPtr,ax

	      	mov 	di,ax		;store first point
		mov 	ax,OldX
		stosw

PolyLoop:	lodsw			;fetch x
		test	ax,ax		;end of list?
		js	PolyDone	;yes ->
		mov	dx,ax
		mov	NewX,ax
		lodsw			;fetch y
		mov	bp,ax
		mov	NewY,ax

		cmp	bp,MinY		;y < MinY?
		jae	NotMin		;no ->
		mov	MinY,bp

;* new y min - store new x in LhsX[new y] and RhsX[new y]

		mov	bx,bp
		shl	bx,1
		mov	LhsX[bx],dx
		mov	RhsX[bx],dx

NotMin:		cmp	bp,MaxY		;y > MaxY?
		jbe	NotMax		;no ->
     		mov	MaxY,bp

;* new y max - store new x in LhsX[new y] and RhsX[new y]

		mov	bx,bp
		shl	bx,1
		mov	LhsX[bx],dx
		mov	RhsX[bx],dx

NotMax:		sub	bp,OldY 	;bp = Dy = NewY - OldY
		jz	Horizontal	;Dy = 0 ->
		sub	dx,OldX		;dx = Dx = NewX - OldX
		shl	dx,1
		rcl	di,1	     	;get sign Dx
		shl	bp,1
		rcl	di,1		;get sign Dy
		sar	dx,1
		sar	bp,1

		xchg	dx,bp
		mov	ax,dx
		cwd
		xor	ax,dx
		sub	ax,dx		;ax = abs(Dy)
		xchg	ax,bp
		cwd
		xor	ax,dx
		sub	ax,dx		;ax = abs(Dx)
		mov	dx,ax
 		cmp	bp,dx		;cf = 1 if Dx > Dy
		rcl	di,1

		and	di,7		;b2=sign Dx, b1=sign Dy, b0=Dx > Dy
		shl	di,1

		mov	ax,OctantBase	
		add	di,ax		;di -> Octant or RvrsOctant table
		mov	ax,[di]	     	;fetch octant routine address
		mov	di,ax

		mov	ax,OldX

		call	di		;call the octant

PolyCont: 	mov	ax,NewX
		mov	OldX,ax
		mov	ax,NewY
		mov	OldY,ax
		jmp	PolyLoop

;* if new x = old x then we have a duplicate point so ignore it

Horizontal:	cmp	dx,OldX		;determine line direction
		je	PolyCont	;duplicate point, ignore it ->
		ja	RhsHoz		;new x > old x, left to right ->

;* right to left horizontal line, store left hand point	

;* do not allow new x point to bisect current horizontal line

LhsHoz:     	mov	di,LhsPtr	;fetch lh ptr
		mov	ax,dx		;ax = new x

		cmp	ax,[di]		;new x < lh x?
		jb	SetLHPoint	;yes ->
		cmp	ax,BUF_SIZE[di]	;new x > rh x?
		jbe	PolyCont	;no ->

SetLHPoint:	stosw
		jmp	PolyCont

;* left to right horizontal line, store right hand point

;* do not allow new x point to bisect current horizontal line

RhsHoz:     	mov	di,RhsPtr	;fetch rh ptr
		mov	ax,dx		;ax = new x

		cmp	ax,[di]		;new x > rh x?
		ja	SetRHPoint	;yes ->
		cmp	ax,-BUF_SIZE[di];new x < lh x?
		jae	PolyCont	;no ->

SetRHPoint:	stosw
		jmp	PolyCont

PolyFill	ENDP

;--------------------------
MeshFill	LABEL	FAR
;--------------------------

		mov	bx,OFFSET Palette
		xlat
		mov	ah,al
		mov	WORD PTR FillCol,ax

		mov	ax,_MeshFill
		mov	FillVector,ax

		mov	ax,OFFSET Octant

		jmp	IntoPolyFill

;--------------------------
SmokeFill	LABEL	FAR
;--------------------------

		mov	bx,OFFSET Palette
		xlat
		mov	ah,al
		mov	WORD PTR FillCol,ax

		mov	ax,_SmokeFill
		mov	FillVector,ax

		mov	ax,OFFSET Octant

		jmp	IntoPolyFill

;--------------------------
RvrsPolyFill	LABEL	FAR
;--------------------------

		mov	bx,OFFSET Palette
		xlat
		mov	ah,al
		mov	WORD PTR FillCol,ax

		mov	ax,_PolyFill
		mov	FillVector,ax

		mov	ax,OFFSET RvrsOctant

		jmp	IntoPolyFill

;--------------------------
RvrsMeshFill	LABEL	FAR
;--------------------------

		mov	bx,OFFSET Palette
		xlat
		mov	ah,al
		mov	WORD PTR FillCol,ax

		mov	ax,_MeshFill
		mov	FillVector,ax

		mov	ax,OFFSET RvrsOctant

		jmp	IntoPolyFill

;--------------------------
RvrsSmokeFill	LABEL	FAR
;--------------------------

		mov	bx,OFFSET Palette
		xlat
		mov	ah,al
		mov	WORD PTR FillCol,ax

		mov	ax,_SmokeFill
		mov	FillVector,ax

		mov	ax,OFFSET RvrsOctant

		jmp	IntoPolyFill

;----------------------------------------------------------------------------

;* PolyFill octant routines
;*
;* pass: ax = x
;*       dx = abs(Dx)
;*       bp = abs(Dy)
;* ret : LhsX[]
;*       RhsX[]
;*       LhsPtr = RhsPtr = updated y ptr
;* kill: assume all (except si) 
;*
;* note: The octant routines assume the following:-
;*
;*       Dy is always > 0 (when Dy = 0, horizontal routine is used).
;*
;*       In octants where Dx > Dy, Dx must be > 0 as Dy is always > 0.

;----------------------------------
;* Octant1: Dx > 0, Dy > 0, Dx > Dy
;----------------------------------

Octant1		PROC	NEAR

		mov	di,RhsPtr	;fetch rhs ptr

		mov	cx,bp		;count = Dy

		mov	bx,dx
		shr	bx,1		;error = Dx / 2
		adc	bx,0		;1/2 bit round up

		jmp	IntoOct1

Oct1Lp:		inc	ax		;x = x + 1
IntoOct1:	sub	bx,bp		;error = error - Dy
		ja	Oct1Lp		;if error > 0 then no y change ->

		add	bx,dx		;error = error + Dx
		stosw			;store x, y = y + 1
		loop	Oct1Lp		;count = count - 1, count > 0 ->

		mov	ax,NewX		;fetch last point
		mov	[di],ax		;store last point

		mov	ax,di
		mov	RhsPtr,ax	;store new rhs ptr
		sub	ax,BUF_SIZE	;adjust for lhs
		mov	LhsPtr,ax	;store new lhs ptr

		ret
		
Octant1		ENDP

;----------------------------------
;* Octant2: Dx > 0, Dy > 0, Dy > Dx
;----------------------------------

Octant2		PROC	NEAR

		push	si		;store co-ord ptr

		mov	di,RhsPtr	;fetch rhs ptr

		mov	cx,dx		;count = Dx

		mov	bx,bp
		shr	bx,1		;error = Dy / 2
		adc	bx,0		;1/2 bit round up

		mov	si,bp
		inc	si		;y count = Dy + 1

		jcxz	Oct2LpB		;vertical line ->

Oct2LpA:	stosw			;store x, y = y + 1
		dec	si		;y count = y count - 1
		sub	bx,dx		;error = error - Dx
		ja	Oct2LpA		;if error > 0 then no x change ->

		add	bx,bp		;error = error + Dy
		inc	ax		;x = x + 1
		loop	Oct2LpA		;count = count - 1, count > 0 ->

Oct2LpB:	mov	cx,si		;loop count for remaining y
		rep 	stosw

		sub	di,2		;move y up one line

		mov	ax,di
		mov	RhsPtr,ax	;store new rhs ptr
		sub	ax,BUF_SIZE	;adjust for lhs
		mov	LhsPtr,ax	;store new lhs ptr

		pop	si		;restore co-ord ptr
		ret

Octant2		ENDP

;----------------------------------
;* Octant3: Dx > 0, Dy < 0, Dy > Dx
;----------------------------------

Octant3		PROC	NEAR

		push	si		;store co-ord ptr
		std			;auto-decrement
		
		mov	di,LhsPtr	;fetch lhs ptr

		mov	cx,dx		;count = Dx

		mov	bx,bp
		shr	bx,1		;error = Dy / 2
		adc	bx,0		;1/2 bit round up

		mov	si,bp
		inc	si		;y count = Dy + 1

		jcxz	Oct3LpB		;vertical line ->

Oct3LpA:	stosw			;store x, y = y - 1
		dec	si		;y count = y count - 1
		sub	bx,dx		;error = error - Dx
		ja	Oct3LpA		;if error > 0 then no x change ->

		add	bx,bp		;error = error + Dy
		inc	ax		;x = x + 1
		loop	Oct3LpA		;count = count - 1, count > 0 ->

Oct3LpB:	mov	cx,si		;loop count for remaining y
		rep	stosw

		add	di,2		;move y down one line

		mov	ax,di
		mov	LhsPtr,ax	;store new lhs ptr
		add	ax,BUF_SIZE	;adjust for rhs
		mov	RhsPtr,ax	;store new rhs ptr

		cld			;auto-increment
		pop	si		;restore co-ord ptr
		ret

Octant3		ENDP

;----------------------------------
;* Octant4: Dx > 0, Dy < 0, Dx > Dy
;----------------------------------

Octant4		PROC	NEAR

		std			;auto-decrement

		mov	di,LhsPtr	;fetch lhs ptr

		mov	cx,bp		;count = Dy

		mov	bx,dx
		shr	bx,1		;error = Dx / 2
		adc	bx,0		;1/2 bit round up

		stosw			;store first x, y = y - 1

Oct4Lp:		inc	ax		;x = x + 1
		sub	bx,bp		;error = error - Dy
		ja	Oct4Lp		;if error > 0 then no y change ->

		add	bx,dx		;error = error + Dx
		stosw			;store x, y = y - 1
		loop	Oct4Lp		;count = count - 1, count > 0 ->

		add	di,2		;move y down one line

		mov	ax,di
		mov	LhsPtr,ax	;store new lhs ptr
		add	ax,BUF_SIZE	;adjust for rhs
		mov	RhsPtr,ax	;store new rhs ptr

		cld			;auto-increment
		ret
		
Octant4		ENDP

;----------------------------------
;* Octant5: Dx < 0, Dy < 0, Dx > Dy
;----------------------------------

Octant5		PROC	NEAR

		std			;auto-decrement

		mov	di,LhsPtr	;fetch lhs ptr

		mov	cx,bp		;count = Dy

		mov	bx,dx
		shr	bx,1		;error = Dx / 2
		adc	bx,0		;1/2 bit round up

		jmp	IntoOct5

Oct5Lp:		dec	ax		;x = x - 1
IntoOct5:	sub	bx,bp		;error = error - Dy
		ja	Oct5Lp		;if error > 0 then no y change ->

		add	bx,dx		;error = error + Dx
		stosw			;store x, y = y - 1
		loop	Oct5Lp		;count = count - 1, count > 0 ->

		mov	ax,NewX		;fetch last point
		mov	[di],ax		;store last point

		mov	ax,di
		mov	LhsPtr,ax	;store new lhs ptr
		add	ax,BUF_SIZE	;adjust for rhs
		mov	RhsPtr,ax	;store new rhs ptr

		cld			;auto-increment
		ret

Octant5		ENDP

;----------------------------------
;* Octant6: Dx < 0, Dy < 0, Dy > Dx
;----------------------------------

Octant6		PROC	NEAR

		push	si		;store co-ord ptr
		std			;auto-decrement

		mov	di,LhsPtr	;fetch lhs ptr

		mov	cx,dx		;count = Dx

		mov	bx,bp
		shr	bx,1		;error = Dy / 2
		adc	bx,0		;1/2 bit round up

		mov	si,bp
		inc	si		;y count = Dy + 1

		jcxz	Oct6LpB		;vertical line ->

Oct6LpA:	stosw			;store x, y = y - 1
		dec	si		;y count = y count - 1
		sub	bx,dx		;error = error - Dx
		ja	Oct6LpA		;if error > 0 then no x change ->

		add	bx,bp		;error = error + Dy
		dec	ax		;x = x - 1
		loop	Oct6LpA		;count = count - 1, count > 0 ->

Oct6LpB:	mov	cx,si		;loop count for remaining y
		rep	stosw

		add	di,2		;move y down one line

		mov	ax,di
		mov	LhsPtr,ax	;store new lhs ptr
		add	ax,BUF_SIZE	;adjust for rhs
		mov	RhsPtr,ax	;store new rhs ptr

		cld			;auto-increment
		pop	si		;restore co-ord ptr
		ret

Octant6		ENDP

;----------------------------------
;* Octant7: Dx < 0, Dy > 0, Dy > Dx
;----------------------------------

Octant7		PROC	NEAR

		push	si		;store co-ord ptr

		mov	di,RhsPtr	;fetch rhs ptr

		mov	cx,dx		;count = Dx

		mov	bx,bp
		shr	bx,1		;error = Dy / 2
		adc	bx,0		;1/2 bit round up

		mov	si,bp
		inc	si		;y count = Dy + 1

		jcxz	Oct7LpB		;vertical line ->

Oct7LpA:	stosw			;store x, y = y + 1
		dec	si		;y count = y count - 1
		sub	bx,dx		;error = error - Dx
		ja	Oct7LpA		;if error > 0 then no x change ->

		add	bx,bp		;error = error - Dy
		dec	ax		;x = x - 1
		loop	Oct7LpA		;count = count - 1, count > 0 ->

Oct7LpB:	mov	cx,si		;loop count for remaining y
		rep	stosw

		sub	di,2		;move y up one line

		mov	ax,di
		mov	RhsPtr,ax	;store new rhs ptr
		sub	ax,BUF_SIZE	;adjust for lhs
		mov	LhsPtr,ax	;store new lhs ptr

		pop	si		;restore co-ord ptr
		ret

Octant7		ENDP

;----------------------------------
;* Octant8: Dx < 0, Dy > 0, Dx > Dy
;----------------------------------

Octant8		PROC	NEAR

		mov	di,RhsPtr	;fetch rhs ptr

		mov	cx,bp		;count = Dy

		mov	bx,dx
		shr	bx,1		;error = Dx / 2
		adc	bx,0		;1/2 bit round up

		stosw			;store first x, y = y + 1

Oct8Lp:		dec	ax		;x = x - 1
		sub	bx,bp		;error = error - Dy
		ja	Oct8Lp		;if error > 0 then no y change ->

		add	bx,dx		;error = error + Dx
		stosw			;store x, y = y + 1
		loop	Oct8Lp		;count = count - 1, count > 0 ->

		sub	di,2		;move y up one line

		mov	ax,di
		mov	RhsPtr,ax	;store new rhs ptr
		sub	ax,BUF_SIZE	;adjust for lhs
		mov	LhsPtr,ax	;store new lhs ptr

		ret

Octant8		ENDP

;----------------------------------------------------------------------------

;* RvrsPolyFill octant routines
;*
;* pass: ax = x
;*       dx = abs(Dx)
;*       bp = abs(Dy)
;* ret : LhsX[]
;*       RhsX[]
;*       LhsPtr = RhsPtr = updated y ptr
;* kill: assume all (except si) 
;*
;* note: The octant routines assume the following:-
;*
;*       Dy is always > 0 (when Dy = 0, horizontal routine is used).
;*
;*       In octants where Dx > Dy, Dx must be > 0 as Dy is always > 0.

;--------------------------------------
;* RvrsOctant1: Dx > 0, Dy > 0, Dx > Dy
;--------------------------------------

RvrsOctant1	PROC	NEAR

		mov	di,LhsPtr	;fetch lhs ptr

		mov	cx,bp		;count = Dy

		mov	bx,dx
		shr	bx,1		;error = Dx / 2
		adc	bx,0		;1/2 bit round up

		stosw			;store first x, y = y + 1

RvrsOct1Lp:	inc	ax		;x = x + 1
		sub	bx,bp		;error = error - Dy
		ja	RvrsOct1Lp	;if error > 0 then no y change ->

		add	bx,dx		;error = error + Dx
		stosw			;store x, y = y + 1
		loop	RvrsOct1Lp	;count = count - 1, count > 0 ->

		sub	di,2		;move y up one line

		mov	ax,di
		mov	LhsPtr,ax	;store new lhs ptr
		add	ax,BUF_SIZE	;adjust for rhs
		mov	RhsPtr,ax	;store new rhs ptr

		ret

RvrsOctant1	ENDP

;--------------------------------------
;* RvrsOctant2: Dx > 0, Dy > 0, Dy > Dx
;--------------------------------------

RvrsOctant2	PROC	NEAR

		push	si		;store co-ord ptr

		mov	di,LhsPtr	;fetch lhs ptr

		mov	cx,dx		;count = Dx

		mov	bx,bp
		shr	bx,1		;error = Dy / 2
		adc	bx,0		;1/2 bit round up

		mov	si,bp
		inc	si		;y count = Dy + 1

		jcxz	RvrsOct2LpB 	;vertical line ->

RvrsOct2LpA:	stosw			;store x, y = y + 1
		dec	si		;y count = y count - 1
		sub	bx,dx		;error = error - Dx
		ja	RvrsOct2LpA 	;if error > 0 then no x change ->

		add	bx,bp		;error = error + Dy
		inc	ax		;x = x + 1
		loop	RvrsOct2LpA 	;count = count - 1, count > 0 ->

RvrsOct2LpB:	mov	cx,si		;loop count for remaining y
		rep 	stosw

		sub	di,2		;move y up one line

		mov	ax,di
		mov	LhsPtr,ax	;store new lhs ptr
		add	ax,BUF_SIZE	;adjust for rhs
		mov	RhsPtr,ax	;store new rhs ptr

		pop	si		;restore co-ord ptr
		ret

RvrsOctant2	ENDP

;--------------------------------------
;* RvrsOctant3: Dx > 0, Dy < 0, Dy > Dx
;--------------------------------------

RvrsOctant3	PROC	NEAR

		push	si		;store co-ord ptr
		std			;auto-decrement
		
		mov	di,RhsPtr	;fetch rhs ptr

		mov	cx,dx		;count = Dx

		mov	bx,bp
		shr	bx,1		;error = Dy / 2
		adc	bx,0		;1/2 bit round up

		mov	si,bp
		inc	si		;y count = Dy + 1

		jcxz	RvrsOct3LpB  	;vertical line ->

RvrsOct3LpA:	stosw			;store x, y = y - 1
		dec	si		;y count = y count - 1
		sub	bx,dx		;error = error - Dx
		ja	RvrsOct3LpA   	;if error > 0 then no x change ->

		add	bx,bp		;error = error + Dy
		inc	ax		;x = x + 1
		loop	RvrsOct3LpA 	;count = count - 1, count > 0 ->

RvrsOct3LpB:	mov	cx,si		;loop count for remaining y
		rep	stosw

		add	di,2		;move y down one line

		mov	ax,di
		mov	RhsPtr,ax	;store new rhs ptr
		sub	ax,BUF_SIZE	;adjust for lhs
		mov	LhsPtr,ax	;store new lhs ptr

		cld			;auto-increment
		pop	si		;restore co-ord ptr
		ret

RvrsOctant3	ENDP

;--------------------------------------
;* RvrsOctant4: Dx > 0, Dy < 0, Dx > Dy
;--------------------------------------

RvrsOctant4	PROC	NEAR

		std			;auto-decrement

		mov	di,RhsPtr	;fetch rhs ptr

		mov	cx,bp		;count = Dy

		mov	bx,dx
		shr	bx,1		;error = Dx / 2
		adc	bx,0		;1/2 bit round up

		jmp	IntoRvrsOct4

RvrsOct4Lp:	inc	ax		;x = x + 1
IntoRvrsOct4:	sub	bx,bp		;error = error - Dy
		ja	RvrsOct4Lp 	;if error > 0 then no y change ->

		add	bx,dx		;error = error + Dx
		stosw			;store x, y = y - 1
		loop	RvrsOct4Lp 	;count = count - 1, count > 0 ->

		mov	ax,NewX		;fetch last point
		mov	[di],ax		;store last point

		mov	ax,di
		mov	RhsPtr,ax	;store new rhs ptr
		sub	ax,BUF_SIZE	;adjust for lhs
		mov	LhsPtr,ax	;store new lhs ptr

		cld			;auto-increment
		ret
	
RvrsOctant4	ENDP

;--------------------------------------
;* RvrsOctant5: Dx < 0, Dy < 0, Dx > Dy
;--------------------------------------

RvrsOctant5	PROC	NEAR

		std			;auto-decrement

		mov	di,RhsPtr	;fetch rhs ptr

		mov	cx,bp		;count = Dy

		mov	bx,dx
		shr	bx,1		;error = Dx / 2
		adc	bx,0		;1/2 bit round up

		stosw			;store first x, y = y - 1

RvrsOct5Lp:	dec	ax		;x = x - 1
		sub	bx,bp		;error = error - Dy
		ja	RvrsOct5Lp 	;if error > 0 then no y change ->

		add	bx,dx		;error = error + Dx
		stosw			;store x, y = y - 1
		loop	RvrsOct5Lp 	;count = count - 1, count > 0 ->

		add	di,2		;move y down one line

		mov	ax,di
		mov	RhsPtr,ax	;store new rhs ptr
		sub	ax,BUF_SIZE	;adjust for lhs
		mov	LhsPtr,ax	;store new lhs ptr

		cld			;auto-increment
		ret

RvrsOctant5	ENDP

;--------------------------------------
;* RvrsOctant6: Dx < 0, Dy < 0, Dy > Dx
;--------------------------------------

RvrsOctant6	PROC	NEAR

		push	si		;store co-ord ptr
		std			;auto-decrement

		mov	di,RhsPtr	;fetch rhs ptr

		mov	cx,dx		;count = Dx

		mov	bx,bp
		shr	bx,1		;error = Dy / 2
		adc	bx,0		;1/2 bit round up

		mov	si,bp
		inc	si		;y count = Dy + 1

		jcxz	RvrsOct6LpB 	;vertical line ->

RvrsOct6LpA:	stosw			;store x, y = y - 1
		dec	si		;y count = y count - 1
		sub	bx,dx		;error = error - Dx
		ja	RvrsOct6LpA 	;if error > 0 then no x change ->

		add	bx,bp		;error = error + Dy
		dec	ax		;x = x - 1
		loop	RvrsOct6LpA  	;count = count - 1, count > 0 ->

RvrsOct6LpB:	mov	cx,si		;loop count for remaining y
		rep	stosw

		add	di,2		;move y down one line

		mov	ax,di
		mov	RhsPtr,ax	;store new rhs ptr
		sub	ax,BUF_SIZE	;adjust for lhs
		mov	LhsPtr,ax	;store new lhs ptr

		cld			;auto-increment
		pop	si		;restore co-ord ptr
		ret

RvrsOctant6	ENDP

;--------------------------------------
;* RvrsOctant7: Dx < 0, Dy > 0, Dy > Dx
;--------------------------------------

RvrsOctant7	PROC	NEAR

		push	si		;store co-ord ptr

		mov	di,LhsPtr	;fetch lhs ptr

		mov	cx,dx		;count = Dx

		mov	bx,bp
		shr	bx,1		;error = Dy / 2
		adc	bx,0		;1/2 bit round up

		mov	si,bp
		inc	si		;y count = Dy + 1

		jcxz	RvrsOct7LpB 	;vertical line ->

RvrsOct7LpA:	stosw			;store x, y = y + 1
		dec	si		;y count = y count - 1
		sub	bx,dx		;error = error - Dx
		ja	RvrsOct7LpA  	;if error > 0 then no x change ->

		add	bx,bp		;error = error - Dy
		dec	ax		;x = x - 1
		loop	RvrsOct7LpA  	;count = count - 1, count > 0 ->

RvrsOct7LpB:	mov	cx,si		;loop count for remaining y
		rep	stosw

		sub	di,2		;move y up one line

		mov	ax,di
		mov	LhsPtr,ax	;store new lhs ptr
		add	ax,BUF_SIZE	;adjust for rhs
		mov	RhsPtr,ax	;store new rhs ptr

		pop	si		;restore co-ord ptr
		ret

RvrsOctant7	ENDP

;--------------------------------------
;* RvrsOctant8: Dx < 0, Dy > 0, Dx > Dy
;--------------------------------------

RvrsOctant8	PROC	NEAR

		mov	di,LhsPtr	;fetch lhs ptr

		mov	cx,bp		;count = Dy

		mov	bx,dx
		shr	bx,1		;error = Dx / 2
		adc	bx,0		;1/2 bit round up

		jmp	IntoRvrsOct8

RvrsOct8Lp:  	dec	ax		;x = x - 1
IntoRvrsOct8:	sub	bx,bp		;error = error - Dy
		ja	RvrsOct8Lp 	;if error > 0 then no y change ->

		add	bx,dx		;error = error + Dx
		stosw			;store x, y = y + 1
		loop	RvrsOct8Lp 	;count = count - 1, count > 0 ->

		mov	ax,NewX		;fetch last point
		mov	[di],ax		;store last point

		mov	ax,di
		mov	LhsPtr,ax	;store new lhs ptr
		add	ax,BUF_SIZE	;adjust for rhs
		mov	RhsPtr,ax	;store new rhs ptr

		ret

RvrsOctant8	ENDP

;----------------------------------------------------------------------------

;* PolyLine - draw lines from list
;*
;* pass: al = logical colour
;*       si -> line co-ord list
;*       ie. [si+0]  = x1 line 1
;*           [si+2]  = x2  ..
;*           [si+3]  = y1  ..
;*           [si+4]  = y2  .. 
;*           [si+6]  = x1 line 2
;*           [si+8]  = x2  ..
;*           [si+10] = y1  ..
;*           [si+11] = y2  ..
;;*             ..   = ..
;*           [si+n]  = -1 (list terminator)
;* ret : si -> next data
;* kill: assume all (except si)

PolyLine	PROC	FAR

		mov	TempCol,al	;store colour

PolyLineLoop:	lodsw			;fetch x1
		cmp	ax,-1		;end of list?
		je	PolyLineExit	;yes ->

		mov	cx,ax
		lodsw			;fetch x2
		mov	dx,ax
		lodsw			;fetch y1, y2
		mov	bx,ax

		mov	al,TempCol	;fetch colour

		push	si
		call	LineDraw
		pop	si

		jmp	PolyLineLoop

PolyLineExit:	ret		

PolyLine	ENDP

GCODE		ENDS

;============================================================================

		END

