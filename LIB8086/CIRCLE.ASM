;****************************************************************************
;*
;* CIRCLE.ASM
;*
;* Circle fill routines.
;*
;* 29.09.1990 - KJB
;* 29.07.1991 - KJB - CircleSmoke added.
;*
;*
;*
;* Circle Draw Algorithm
;* ---------------------
;*
;* These routines use Bresenham's incremental circle drawing algorithm:-
;*
;*    x = 0
;*    y = radius
;*    sum = 0
;*
;*    while(x <= y)
;*       plot(xorg + y, yorg - x)	;octant 2
;*       plot(xorg + y, yorg + x)	;octant 3
;*       plot(xorg - y, yorg - x)	;octant 7
;*       plot(xorg - y, yorg + x)	;octant 6
;*       sum = sum + x
;*       if sum > 0 then
;*          plot(xorg + x, yorg - y)	;octant 1
;*          plot(xorg + x, yorg + y)	;octant 4
;*          plot(xorg - x, yorg - y)	;octant 8
;*          plot(xorg - x, yorg + y)	;octant 5
;*          sum = sum - y
;*          y = y - 1
;*       end if
;*       x = x + 1
;*    end while
;*
;*
;*          
;* Aspect Ratio
;* ------------
;*
;* Circles are drawn with an aspect ratio of 1.25:1 (x:y). This aspect ratio
;* is not perfect but it is not bad. The aspect ratio will probably vary wrt
;* the type of graphics adaptor.
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	CircleFill
		PUBLIC	CircleMesh
		PUBLIC	CircleSmoke

		PUBLIC	CircleXMin
		PUBLIC	CircleXMax
		PUBLIC	CircleYMin
		PUBLIC	CircleYMax
		PUBLIC	CircleFlag

		EXTRN	LhsX:WORD
		EXTRN	RhsX:WORD
		EXTRN	MinY:WORD
		EXTRN	MaxY:WORD
		EXTRN	FillVector:WORD
		EXTRN	PolyCount:WORD
		EXTRN	_PolyFill:WORD
		EXTRN	_MeshFill:WORD
		EXTRN	_SmokeFill:WORD

		EXTRN	FillCol:BYTE
		EXTRN	Palette:BYTE

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

CircleXMin	DW	0		; >=   0 <= CircleXMax
CircleXMax	DW	319		; <= 319 >= CircleXMin
CircleYMin	DW	0		; >=   0 <= CircleYMax
CircleYMax	DW	199		; <= 199 >= CircleYMin

CircleFlag	DB	0,0		;1 = circle visible

;* select outside clip routine wrt circle origin out code (000ABRL0)

CircleVectors	DW	CircleExit	;00000
		DW	ClipLeft 	;00010
		DW	ClipRight	;00100
		DW	CircleExit	;00110
		DW	ClipBelow	;01000
		DW	ClipBelowLeft	;01010
		DW	ClipBelowRight	;01100
		DW	CircleExit	;01110
		DW	ClipAbove	;10000
		DW	ClipAboveLeft	;10010
		DW	ClipAboveRight	;10100
		DW	CircleExit	;10110
		DW	CircleExit	;11000
		DW	CircleExit	;11010
		DW	CircleExit	;11100
		DW	CircleExit	;11110

DUMMY_MIN	EQU	-32768
DUMMY_MAX	EQU	+32767

DATA		ENDS

;============================================================================

GCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:GCODE
		ASSUME DS:DATA

;* ASPECT - modify value wrt aspect ratio
;*
;* pass: source
;* ret : dest
;* kill: flags

ASPECT		MACRO	dest,source

		mov	dest,source
		shr	dest,1		;*0.5
		shr	dest,1		;*0.25
		adc	dest,source	;*1.25

		ENDM

;----------------------------------------------------------------------------

;* CircleFill - clip and fill circle
;* CircleMesh - clip and fill "transparent" circle
;* CircleSmoke - clip and fill "smoke" circle
;*
;* pass: al = logical colour
;*       bx = y origin
;*       cx = x origin
;*       dx = radius
;*       CircleXMin
;*       CircleXMax
;*       CircleYMin
;*       CircleYMax
;* ret : CircleFlag
;* kill: assume all
;*
;* note: This routine constructs a circle in the PolyFill LhsX[] and RhsX[]
;*       buffers, then uses the PolyFill graphics primitives to draw the
;*       circle.
;*
;*	 Whilst this routine can draw very large circles, I cannot guarantee
;*       what will happen if the circle "wraps around". The maximum radius of
;*       the circle is limited by the fact that (radius * aspect ratio) must
;*       be <= 32767.
;*
;*	 The clipping window may be adjusted to any size so long as:-
;*
;*	 a) CircleXMin <= CircleXMax
;*       b) CircleYMin <= CircleYMax
;*
;*	 Three cases of circles are handled:-
;*
;*	 a) unclipped circle (no clipping required, very fast)
;*       b) clipped circle, circle origin inside clipping window
;*       c) clipped circle, circle origin outside clipping window

;--------------------------
CircleSmoke	LABEL	FAR
;--------------------------

		test	dx,dx		;radius > 0?
		jle	CircleExit	;no ->
		
		mov	si,bx		;si = y org
		mov	bp,cx		;bp = x org

		mov	bx,OFFSET Palette
		xlat
		mov	ah,al
		mov	WORD PTR FillCol,ax

		mov	ax,_SmokeFill
		mov	FillVector,ax

		jmp	IntoCircleFill

;--------------------------
CircleMesh	LABEL	FAR
;--------------------------

		test	dx,dx		;radius > 0?
		jle	CircleExit	;no ->
		
		mov	si,bx		;si = y org
		mov	bp,cx		;bp = x org

		mov	bx,OFFSET Palette
		xlat
		mov	ah,al
		mov	WORD PTR FillCol,ax

		mov	ax,_MeshFill
		mov	FillVector,ax

		jmp	IntoCircleFill

;---------------------------
CircleExit	LABEL	NEAR		;exit point for non-visible circles
;---------------------------

		xor	al,al		;circle not visible
		mov	CircleFlag,al
		retf			;<<<<< MUST BE FAR <<<<<

;--------------------------
CircleFill	PROC	FAR
;--------------------------

		test	dx,dx		;radius > 0?
		jle	CircleExit	;no ->
		
		mov	si,bx		;si = y org
		mov	bp,cx		;bp = x org

		mov	bx,OFFSET Palette
		xlat
		mov	ah,al
		mov	WORD PTR FillCol,ax

		mov	ax,_PolyFill
		mov	FillVector,ax

;* calc min / max x and y values to determine if circle is visible
;*
;* min x val = x org - radius * aspect ratio
;* max x val = x org + radius * aspect ratio
;* min y val = y org - radius
;* max y val = y org + radius

;* dx = radius
;* si = y org
;* bp = x org

IntoCircleFill:	ASPECT	cx,dx		;cx = radius * aspect ratio (AR)

		mov	ax,bp
		sub	ax,cx		;x min val = x org - radius * AR
		cmp	ax,CircleXMax	;x min val > clip x max?
		jg	CircleExit	;yes, not visible ->
		mov	di,ax	

		mov	ax,bp
		add	ax,cx		;x max val = x org + radius * AR
		cmp	ax,CircleXMin	;x max val < clip x min?
		jl	CircleExit	;yes, not visible ->
		mov	cx,ax

		mov	ax,si		
		sub	ax,dx		;y min val = y org - radius
		cmp	ax,CircleYMax	;y min val > clip y max?
		jg	CircleExit	;yes, not visible ->
		mov	bx,ax

		mov	ax,si
		add	ax,dx		;y max val = y org + radius
		cmp	ax,CircleYMin	;y max val < clip y min?
		jl	CircleExit	;yes, not visible ->

;* ax = y max val
;* bx = y min val
;* cx = x max val
;* di = x min val
;*
;* dx = radius
;* si = y org
;* bp = x org

;* determine if circle requires clipping

		cmp	ax,CircleYMax	;y max val requires clipping?
		jg	ClipCircleLink	;yes ->
		cmp	bx,CircleYMin	;y min val requires clipping?
		jl	ClipCircleLink	;yes ->
		cmp	cx,CircleXMax	;x max val requires clipping?
		jg	ClipCircleLink	;yes ->
		cmp	di,CircleXMin	;x min val requires clipping?
		jge	UnclippedCircle	;no ->

ClipCircleLink:	jmp	ClippedCircle

;==================
;* unclipped circle
;==================

;* ax = y max val
;* bx = y min val
;*
;* dx = radius
;* si = y org
;* bp = x org

;* min y = y min val
;* max y = y max val

UnclippedCircle:mov	MinY,bx
		mov	MaxY,ax

;* x = 0
;* y = radius
;* sum = 0

		xor	cx,cx
		mov	bx,dx
		xor	di,di
	
		shl	si,1		;y org * 2 (word access)

;* while(x <= y)

CircleLoop1:	cmp	cx,bx
		jg	CircleDone

;*    swap x, y

		xchg	bx,cx
		shl	bx,1		;y * 2 (word access)
	
;*    x aspect = x * aspect ratio

		ASPECT	dx,cx

;*    rhsx(y org - y) = xorg + x aspect
;*    rhsx(y org + y) = xorg + x aspect

		mov	ax,bp
		add	ax,dx
		neg	bx		;(-y)
		mov	RhsX[si+bx],ax
		neg	bx		;(+y)
		mov	RhsX[si+bx],ax

;*    lhsx(y org - y) = xorg - x aspect
;*    lhsx(y org + y) = xorg - x aspect

		mov	ax,bp
		sub	ax,dx
		neg	bx		;(-y)
		mov	LhsX[si+bx],ax
		neg	bx		;(+y)
		mov	LhsX[si+bx],ax

;*    swap x, y

		shr	bx,1		;y / 2 (restore)
		xchg	bx,cx

;*    sum = sum + x
;*    if sum > 0 then

		add	di,cx
		jle	SkipXYOcts1

		shl	bx,1		;y * 2 (word access)
	
;*       x aspect = x * aspect ratio

		ASPECT	dx,cx

;*       rhsx(y org - y) = xorg + x aspect
;*       rhsx(y org + y) = xorg + x aspect

		mov	ax,bp
		add	ax,dx
		neg	bx		;(-y)
		mov	RhsX[si+bx],ax
		neg	bx		;(+y)
		mov	RhsX[si+bx],ax

;*       lhsx(y org - y) = xorg - x aspect
;*       lhsx(y org + y) = xorg - x aspect

		mov	ax,bp
		sub	ax,dx
		neg	bx		;(-y)
		mov	LhsX[si+bx],ax
		neg	bx		;(+y)
		mov	LhsX[si+bx],ax

		shr	bx,1		;y / 2 (restore)

;*       sum = sum - y
;*       y = y - 1

       		sub	di,bx
		dec	bx

;*    end if
;*    x = x + 1

SkipXYOcts1:	inc	cx

;* while end

		jmp	CircleLoop1

;* jump to appropriate graphics primitive to draw circle

CircleDone:	mov	al,1		;circle visible
		mov	CircleFlag,al

		inc	PolyCount

		mov	ax,FillVector
		jmp	ax

;================
;* clipped circle
;================

;* ax = y max val
;* bx = y min val
;*
;* dx = radius
;* si = y org
;* bp = x org

;* check if circle origin is inside or outside clip region

ClippedCircle:	cmp	bp,CircleXMin	;x org < clip x min?
		jl	OutsideLink	;yes, outside ->
		cmp	bp,CircleXMax	;x org > clip x max?
		jg	OutsideLink	;yes, outside ->
		cmp	si,CircleYMin	;y org < clip y min?
		jl	OutsideLink	;yes, outside ->
		cmp	si,CircleYMax	;y org > clip y max?
		jle	InsideClip	;no, inside ->

OutsideLink:	jmp	OutsideClip

;===========================================
;* clipped circle, origin inside clip region
;===========================================

;* ax = y max val
;* bx = y min val
;*
;* dx = radius
;* si = y org
;* bp = x org

;* max y = min(y max val, clip y max)

InsideClip:	cmp	ax,CircleYMax
		jle	Ok2_1
		mov	ax,CircleYMax
Ok2_1:		mov	MaxY,ax
	
;* min y = max(y min val, clip y min)

	       	mov	ax,bx
		cmp	ax,CircleYMin
		jge	Ok2_2
		mov	ax,CircleYMin
Ok2_2:		mov	MinY,ax

;* x = 0
;* y = radius
;* sum = 0

		xor	cx,cx
		mov	bx,dx
		xor	di,di
	
		shl	si,1		;y org * 2 (word access)

;* while(x <= y)

CircleLoop2:	cmp	cx,bx
		jg	CircleDone

;*    swap x, y

		xchg	bx,cx
		shl	bx,1		;y * 2 (word access)
	
;*    x aspect = x * aspect ratio

		ASPECT	dx,cx

;*    if (y org - y) >= clip y min then

       		mov	ax,si
		sub	ax,bx
		js	Skip2_1		;not valid if -ve ->
		shr	ax,1
		cmp	ax,CircleYMin
		jl	Skip2_1
	
		neg	bx		;(-y)

;*       x temp = min(x org + x aspect, clip x max)
;*       rhsx(y org - y) = x temp

		mov	ax,bp
		add	ax,dx
		cmp	ax,CircleXMax
		jle	Ok2_3
		mov	ax,CircleXMax
Ok2_3:		mov	RhsX[si+bx],ax

;*       x temp = max(x org - x aspect, clip x min)
;*       lhsx(y org - y) = x temp

		mov	ax,bp
		sub	ax,dx
		cmp	ax,CircleXMin
		jge	Ok2_4
		mov	ax,CircleXMin
Ok2_4:		mov	LhsX[si+bx],ax

		neg	bx		;(+y)

;*    end if
;*    if (y org + y) <= clip y max then

Skip2_1:	mov	ax,si
		add	ax,bx
		js	Skip2_2		;not valid if -ve ->
		shr	ax,1
		cmp	ax,CircleYMax
		jg	Skip2_2
	
;*       x temp = min(x org + x aspect, clip x max)
;*       rhsx(y org + y) = x temp

		mov	ax,bp
		add	ax,dx
		cmp	ax,CircleXMax
		jle	Ok2_5
		mov	ax,CircleXMax
Ok2_5:		mov	RhsX[si+bx],ax

;*       x temp = max(x org - x aspect, clip x min)
;*       lhsx(y org + y) = x temp

		mov	ax,bp
		sub	ax,dx
		cmp	ax,CircleXMin
		jge	Ok2_6
		mov	ax,CircleXMin
Ok2_6:		mov	LhsX[si+bx],ax

;*    end if
;*    swap x, y

Skip2_2: 	shr	bx,1		;y / 2 (restore)
		xchg	bx,cx

;*    sum = sum + x
;*    if sum > 0 then

		add	di,cx
		jle	SkipXYOcts2

	    	shl	bx,1		;y * 2 (word access)

;*       x aspect = x * aspect ratio

		ASPECT	dx,cx

;*       if (y org - y) >= clip y min then

		mov	ax,si
		sub	ax,bx
		js	Skip2_3		;not valid if -ve ->
		shr	ax,1
		cmp	ax,CircleYMin
		jl	Skip2_3
		
		neg	bx		;(-y)

;*          x temp = min(x org + x aspect, clip x max)
;*          rhsx(y org - y) = x temp

		mov	ax,bp
		add	ax,dx
		cmp	ax,CircleXMax
		jle	Ok2_7
		mov	ax,CircleXMax
Ok2_7:		mov	RhsX[si+bx],ax

;*          x temp = max(x org - x aspect, clip x min)
;*          lhsx(y org - y) = x temp

		mov	ax,bp
		sub	ax,dx
		cmp	ax,CircleXMin
		jge	Ok2_8
		mov	ax,CircleXMin
Ok2_8:		mov	LhsX[si+bx],ax

		neg	bx		;(+y)

;*       end if
;*       if (y org + y) <= clip y max then

Skip2_3:	mov	ax,si
		add	ax,bx
		js	Skip2_4		;not valid if -ve ->
		shr	ax,1
		cmp	ax,CircleYMax
		jg	Skip2_4
	
;*          x temp = min(x org + x aspect, clip x max)
;*          rhsx(y org + y) = x temp

		mov	ax,bp
		add	ax,dx
		cmp	ax,CircleXMax
		jle	Ok2_9
		mov	ax,CircleXMax
Ok2_9:		mov	RhsX[si+bx],ax

;*          x temp = max(x org - x aspect, clip x min)
;*          lhsx(y org + y) = x temp

		mov	ax,bp
		sub	ax,dx
		cmp	ax,CircleXMin
		jge	Ok2_10
		mov	ax,CircleXMin
Ok2_10:		mov	LhsX[si+bx],ax

;*       end if

Skip2_4: 	shr	bx,1		;y / 2 (restore)

;*       sum = sum - y
;*       y = y - 1

		sub	di,bx
		dec	bx

;*    end if
;*    x = x + 1

SkipXYOcts2:	inc	cx

;* while end

		jmp	CircleLoop2

;============================================
;* clipped circle, origin outside clip region
;============================================

;* dx = radius
;* si = y org
;* bp = x org

;* calc out code for circle origin (bx = out code = 000ABRL0)

OutsideClip:	xor	bx,bx
		cmp	bp,CircleXMin	;left of clip region?
		jge	OutCode1	;no ->
		or	bx,00010b
OutCode1: 	cmp	bp,CircleXMax	;right of clip region?
		jle	OutCode2  	;no ->
		or	bx,00100b 
OutCode2:	cmp	si,CircleYMax	;below clip region?
		jle	OutCode3	;no ->
		or	bx,01000b
OutCode3:	cmp	si,CircleYMin	;above clip region?
		jge	OutCode4	;no ->
		or	bx,10000b

;* jump to appropriate outside clip routine

OutCode4:	mov	ax,CircleVectors[bx]
		jmp	ax

;=================================
;* circle origin above clip region
;=================================

AboveDone: 	jmp	CircleDone

;* dx = radius
;* si = y org
;* bp = x org

;* min y = clip y min
;* max y = clip y min

ClipAbove:	mov	ax,CircleYMin
		mov	MinY,ax
		mov	MaxY,ax

;* x = 0
;* y = radius
;* sum = 0

  		xor	cx,cx
		mov	bx,dx
		xor	di,di
	
		shl	si,1		;y org * 2 (word access)

;* while(x <= y)

CircleLoop3:	cmp	cx,bx
		jg	AboveDone

;*    swap x, y

		xchg	bx,cx
		shl	bx,1		;y * 2 (word access)
	
;*    if (y org + y) >= clip y min and (y org + y) <= clip y max then

		mov	ax,si
		add	ax,bx
		js	Skip3_1		;not valid if -ve ->
		shr	ax,1
		cmp	ax,CircleYMin
		jl	Skip3_1
		cmp	ax,CircleYMax
		jg	Skip3_1

;*       max y = max(max y, y org + y)

		cmp	ax,MaxY
		jle	Ok3_1
		mov	MaxY,ax

;*       x aspect = x * aspect ratio

Ok3_1:		ASPECT	dx,cx

;*       x temp = min(x org + x aspect, clip x max)
;*       rhsx(y org + y) = x temp

		mov	ax,bp
		add	ax,dx
		cmp	ax,CircleXMax
		jle	Ok3_2
		mov	ax,CircleXMax
Ok3_2:		mov	RhsX[si+bx],ax

;*       x temp = max(x org - x aspect, clip x min)
;*       lhsx(y org + y) = x temp

		mov	ax,bp
		sub	ax,dx
		cmp	ax,CircleXMin
		jge	Ok3_3
		mov	ax,CircleXMin
Ok3_3:		mov	LhsX[si+bx],ax

;*    end if
;*    swap x, y

Skip3_1:	shr	bx,1		;y / 2 (restore)
		xchg	bx,cx

;*    sum = sum + x
;*    if sum > 0 then

		add	di,cx
		jle	SkipXYOcts3

		shl	bx,1		;y * 2 (word access)
	
;*       if (y org + y) >= clip y min and (y org + y) <= clip y max then

		mov	ax,si
		add	ax,bx
		js	Skip3_2		;not valid if -ve ->
		shr	ax,1
		cmp	ax,CircleYMin
		jl	Skip3_2
		cmp	ax,CircleYMax
		jg	Skip3_2

;*          max y = max(max y, y org + y)

		cmp	ax,MaxY
		jle	Ok3_4
		mov	MaxY,ax

;*          x aspect = x * aspect ratio

Ok3_4:		ASPECT	dx,cx

;*          x temp = min(x org + x aspect, clip x max)
;*          rhsx(y org + y) = x temp

		mov	ax,bp
		add	ax,dx
		cmp	ax,CircleXMax
		jle	Ok3_5
		mov	ax,CircleXMax
Ok3_5:		mov	RhsX[si+bx],ax

;*          x temp = max(x org - x aspect, clip x min)
;*          lhsx(y org + y) = x temp

		mov	ax,bp
		sub	ax,dx
		cmp	ax,CircleXMin
		jge	Ok3_6
		mov	ax,CircleXMin
Ok3_6:		mov	LhsX[si+bx],ax

;*       end if

Skip3_2:	shr	bx,1		;y / 2 (restore)

;*       sum = sum - y
;*       y = y - 1

		sub	di,bx
		dec	bx

;*    end if
;*    x = x + 1

SkipXYOcts3:	inc	cx

;* while end
	
		jmp	CircleLoop3

;============================================
;* circle origin above / right of clip region
;============================================

;* test if circle is visible before drawing

AboveRightDone:	mov	ax,MaxY
		cmp	ax,DUMMY_MIN	;visible?
		je	AboveRightSkip	;no ->
		jmp	CircleDone
AboveRightSkip:	jmp	CircleExit

;* dx = radius
;* si = y org
;* bp = x org

;* min y = clip y min
;* max y = DUMMY_MIN

ClipAboveRight:	mov	ax,CircleYMin
		mov	MinY,ax
		mov	ax,DUMMY_MIN
		mov	MaxY,ax

;* x = 0
;* y = radius
;* sum = 0

  		xor	cx,cx
		mov	bx,dx
		xor	di,di
	
		shl	si,1		;y org * 2 (word access)

;* while(x <= y)

CircleLoop4: 	cmp	cx,bx
		jg	AboveRightDone

;*    swap x, y

		xchg	bx,cx
		shl	bx,1		;y * 2 (word access)
	
;*    x aspect = x * aspect ratio

		ASPECT	dx,cx

;*    if (x org - x aspect) <= clip x max then

		mov	ax,bp
		sub	ax,dx
		cmp	ax,CircleXMax
		jg	Skip4_1

;*       if (y org + y) >= clip y min and (y org + y) <= clip y max then

		mov	ax,si
		add	ax,bx
		js	Skip4_1		;not valid if -ve ->
		shr	ax,1
		cmp	ax,CircleYMin
		jl	Skip4_1
		cmp	ax,CircleYMax
		jg	Skip4_1

;*          max y = max(max y, y org + y)

		cmp	ax,MaxY
		jle	Ok4_1
		mov	MaxY,ax

;*          x temp = clip x max
;*          rhsx(y org + y) = x temp

Ok4_1:		mov	ax,CircleXMax
		mov	RhsX[si+bx],ax

;*          x temp = max(x org - x aspect, clip x min)
;*          lhsx(y org + y) = x temp

		mov	ax,bp
		sub	ax,dx
		cmp	ax,CircleXMin
		jge	Ok4_2
		mov	ax,CircleXMin
Ok4_2:		mov	LhsX[si+bx],ax

;*       end if
;*    end if
;*    swap x, y

Skip4_1:	shr	bx,1		;y / 2 (restore)
		xchg	bx,cx

;*    sum = sum + x
;*    if sum > 0 then

		add	di,cx
		jle	SkipXYOcts4

		shl	bx,1		;y * 2 (word access)
	
;*       x aspect = x * aspect ratio

		ASPECT	dx,cx

;*       if (x org - x aspect) <= clip x max then

		mov	ax,bp
		sub	ax,dx
		cmp	ax,CircleXMax
		jg	Skip4_2

;*          if (y org + y) >= clip y min and (y org + y) <= clip y max then

		mov	ax,si
		add	ax,bx
		js	Skip4_2		;not valid if -ve ->
		shr	ax,1
		cmp	ax,CircleYMin
		jl	Skip4_2
		cmp	ax,CircleYMax
		jg	Skip4_2

;*             max y = max(max y, y org + y)

		cmp	ax,MaxY
		jle	Ok4_3
		mov	MaxY,ax

;*             x temp = clip x max
;*             rhsx(y org + y) = x temp

Ok4_3:		mov	ax,CircleXMax
		mov	RhsX[si+bx],ax

;*             x temp = max(x org - x aspect, clip x min)
;*             lhsx(y org + y) = x temp

		mov	ax,bp
		sub	ax,dx
		cmp	ax,CircleXMin
		jge	Ok4_4
		mov	ax,CircleXMin
Ok4_4:		mov	LhsX[si+bx],ax

;*          end if
;*       end if

Skip4_2:	shr	bx,1		;y / 2 (restore)

;*       sum = sum - y
;*       y = y - 1

		sub	di,bx
		dec	bx

;*    end if
;*    x = x + 1

SkipXYOcts4:	inc	cx

;* while end
	
		jmp	CircleLoop4

;===========================================
;* circle origin above / left of clip region
;===========================================

;* test if circle is visible before drawing

AboveLeftDone: 	mov	ax,MaxY
		cmp	ax,DUMMY_MIN	;visible?
		je	AboveLeftSkip	;no ->
		jmp	CircleDone
AboveLeftSkip:	jmp	CircleExit

;* dx = radius
;* si = y org
;* bp = x org

;* min y = clip y min
;* max y = DUMMY_MIN

ClipAboveLeft:	mov	ax,CircleYMin
		mov	MinY,ax
		mov	ax,DUMMY_MIN
		mov	MaxY,ax

;* x = 0
;* y = radius
;* sum = 0

  		xor	cx,cx
		mov	bx,dx
		xor	di,di
	
		shl	si,1		;y org * 2 (word access)

;* while(x <= y)

CircleLoop5:	cmp	cx,bx
		jg	AboveLeftDone

;*    swap x, y

		xchg	bx,cx
		shl	bx,1		;y * 2 (word access)
	
;*    x aspect = x * aspect ratio

		ASPECT	dx,cx

;*    if (x org + x aspect) >= clip x min then

		mov	ax,bp
		add	ax,dx
		cmp	ax,CircleXMin
		jl	Skip5_1

;*       if (y org + y) >= clip y min and (y org + y) <= clip y max then

		mov	ax,si
		add	ax,bx
		js	Skip5_1		;not valid if -ve ->
		shr	ax,1
		cmp	ax,CircleYMin
		jl	Skip5_1
		cmp	ax,CircleYMax
		jg	Skip5_1

;*          max y = max(max y, y org + y)

		cmp	ax,MaxY
		jle	Ok5_1
		mov	MaxY,ax

;*          x temp = min(x org + x aspect, clip x max)
;*          rhsx(y org + y) = x temp

Ok5_1:		mov	ax,bp
		add	ax,dx
		cmp	ax,CircleXMax
		jle	Ok5_2
		mov	ax,CircleXMax
Ok5_2:		mov	RhsX[si+bx],ax

;*          x temp = clip x min
;*          lhsx(y org + y) = x temp

		mov	ax,CircleXMin
		mov	LhsX[si+bx],ax

;*       end if
;*    end if
;*    swap x, y

Skip5_1:	shr	bx,1		;y / 2 (restore)
		xchg	bx,cx

;*    sum = sum + x
;*    if sum > 0 then

		add	di,cx
		jle	SkipXYOcts5

		shl	bx,1		;y * 2 (word access)

;*       x aspect = x * aspect ratio

		ASPECT	dx,cx

;*       if (x org + x aspect) >= clip x min then

		mov	ax,bp
		add	ax,dx
		cmp	ax,CircleXMin
		jl	Skip5_2

;*          if (y org + y) >= clip y min and (y org + y) <= clip y max then

		mov	ax,si
		add	ax,bx
		js	Skip5_2		;not valid if -ve ->
		shr	ax,1
		cmp	ax,CircleYMin
		jl	Skip5_2
		cmp	ax,CircleYMax
		jg	Skip5_2

;*             max y = max(max y, y org + y)

		cmp	ax,MaxY
		jle	Ok5_3
		mov	MaxY,ax

;*             x temp = min(x org + x aspect, clip x max)
;*             rhsx(y org + y) = x temp

Ok5_3:		mov	ax,bp
		add	ax,dx
		cmp	ax,CircleXMax
		jle	Ok5_4
		mov	ax,CircleXMax
Ok5_4:		mov	RhsX[si+bx],ax

;*             x temp = clip x min
;*             lhsx(y org + y) = x temp

		mov	ax,CircleXMin
		mov	LhsX[si+bx],ax

;*          end if
;*       end if

Skip5_2:	shr	bx,1		;y / 2 (restore)

;*       sum = sum - y
;*       y = y - 1

		sub	di,bx
		dec	bx

;*    end if
;*    x = x + 1

SkipXYOcts5:	inc	cx

;* while end

		jmp	CircleLoop5

;=================================
;* circle origin below clip region
;=================================

BelowDone:	jmp	CircleDone

;* dx = radius
;* si = y org
;* bp = x org

;* min y = clip y max
;* max y = clip y max

ClipBelow:	mov	ax,CircleYMax
		mov	MinY,ax
		mov	MaxY,ax

;* x = 0
;* y = radius
;* sum = 0

  		xor	cx,cx
		mov	bx,dx
		xor	di,di
	
		shl	si,1		;y org * 2 (word access)

;* while(x <= y)

CircleLoop6:	cmp	cx,bx
		jg	BelowDone

;*    swap x, y

		xchg	bx,cx
		shl	bx,1		;y * 2 (word access)
	
;*    if (y org - y) >= clip y min and (y org - y) <= clip y max then

		mov	ax,si
		sub	ax,bx
		js	Skip6_1		;not valid if -ve ->
		shr	ax,1
		cmp	ax,CircleYMin
		jl	Skip6_1
		cmp	ax,CircleYMax
		jg	Skip6_1

;*       min y = min(min y, y org - y)

		cmp	ax,MinY
		jge	Ok6_1
		mov	MinY,ax

;*       x aspect = x * aspect ratio

Ok6_1:		ASPECT	dx,cx

;*       x temp = min(x org + x aspect, clip x max)
;*       rhsx(y org - y) = x temp

		neg	bx		;(-y)
	
		mov	ax,bp
		add	ax,dx
		cmp	ax,CircleXMax
		jle	Ok6_2
		mov	ax,CircleXMax
Ok6_2:		mov	RhsX[si+bx],ax

;*       x temp = max(x org - x aspect, clip x min)
;*       lhsx(y org - y) = x temp

		mov	ax,bp
		sub	ax,dx
		cmp	ax,CircleXMin
		jge	Ok6_3
		mov	ax,CircleXMin
Ok6_3:		mov	LhsX[si+bx],ax

		neg	bx		;(+y)

;*    end if
;*    swap x, y

Skip6_1:	shr	bx,1		;y / 2 (restore)
		xchg	bx,cx

;*    sum = sum + x
;*    if sum > 0 then

		add	di,cx
		jle	SkipXYOcts6

		shl	bx,1		;y * 2 (word access)

;*       if (y org - y) >= clip y min and (y org - y) <= clip y max then

		mov	ax,si
		sub	ax,bx
		js	Skip6_2		;not valid if -ve ->
		shr	ax,1
		cmp	ax,CircleYMin
		jl	Skip6_2
		cmp	ax,CircleYMax
		jg	Skip6_2

;*          min y = min(min y, y org - y)

		cmp	ax,MinY
		jge	Ok6_4
		mov	MinY,ax

;*          x aspect = x * aspect ratio

Ok6_4:		ASPECT	dx,cx

;*          x temp = min(x org + x aspect, clip x max)
;*          rhsx(y org - y) = x temp

		neg 	bx		;(-y)

		mov	ax,bp
		add	ax,dx
		cmp	ax,CircleXMax
		jle	Ok6_5
		mov	ax,CircleXMax
Ok6_5:		mov	RhsX[si+bx],ax

;*          x temp = max(x org - x aspect, clip x min)
;*          lhsx(y org - y) = x temp

		mov	ax,bp
		sub	ax,dx
		cmp	ax,CircleXMin
		jge	Ok6_6
		mov	ax,CircleXMin
Ok6_6:		mov	LhsX[si+bx],ax

		neg	bx		;(+y)

;*       end if

Skip6_2:	shr	bx,1		;y / 2 (restore)

;*       sum = sum - y
;*       y = y - 1

		sub	di,bx
		dec	bx

;*    end if
;*    x = x + 1

SkipXYOcts6:	inc	cx

;* while end
	
		jmp	CircleLoop6

;============================================
;* circle origin below / right of clip region
;============================================

;* test if circle is visible before drawing

BelowRightDone: mov	ax,MinY
		cmp	ax,DUMMY_MAX	;visible?
		je	BelowRightSkip	;no ->
		jmp	CircleDone
BelowRightSkip:	jmp	CircleExit

;* dx = radius
;* si = y org
;* bp = x org

;* min y = DUMMY_MAX
;* max y = clip y max

ClipBelowRight:	mov	ax,DUMMY_MAX
		mov	MinY,ax
		mov	ax,CircleYMax
		mov	MaxY,ax

;* x = 0
;* y = radius
;* sum = 0

  		xor	cx,cx
		mov	bx,dx
		xor	di,di
	
		shl	si,1		;y org * 2 (word access)

;* while(x <= y)

CircleLoop7: 	cmp	cx,bx
		jg	BelowRightDone

;*    swap x, y

		xchg	bx,cx
		shl	bx,1		;y * 2 (word access)
	
;*    x aspect = x * aspect ratio

		ASPECT	dx,cx

;*    if (x org - x aspect) <= clip x max then

		mov	ax,bp
		sub	ax,dx
		cmp	ax,CircleXMax
		jg	Skip7_1

;*       if (y org - y) >= clip y min and (y org - y) <= clip y max then

		mov	ax,si
		sub	ax,bx
		js	Skip7_1		;not valid if -ve ->
		shr	ax,1
		cmp	ax,CircleYMin
		jl	Skip7_1
		cmp	ax,CircleYMax
		jg	Skip7_1

;*          min y = min(min y, y org - y)

		cmp	ax,MinY
		jge	Ok7_1
		mov	MinY,ax

;*          x temp = clip x max
;*          rhsx(y org - y) = x temp

Ok7_1:		neg	bx		;(-y)

		mov	ax,CircleXMax
		mov	RhsX[si+bx],ax

;*          x temp = max(x org - x aspect, clip x min)
;*          lhsx(y org - y) = x temp
	
		mov	ax,bp
		sub	ax,dx
		cmp	ax,CircleXMin
		jge	Ok7_2
		mov	ax,CircleXMin
Ok7_2:		mov	LhsX[si+bx],ax

		neg	bx		;(+y)

;*       end if
;*    end if
;*    swap x, y

Skip7_1:	shr	bx,1		;y / 2 (restore)
		xchg	bx,cx

;*    sum = sum + x
;*    if sum > 0 then

		add	di,cx
		jle	SkipXYOcts7

		shl	bx,1		;y * 2 (word access)
	
;*       x aspect = x * aspect ratio

		ASPECT	dx,cx

;*       if (x org - x aspect) <= clip x max then

     		mov	ax,bp
		sub	ax,dx
		cmp	ax,CircleXMax
		jg	Skip7_2

;*          if (y org - y) >= clip y min and (y org - y) <= clip y max then

		mov	ax,si
		sub	ax,bx
		js	Skip7_2		;not valid if -ve ->
		shr	ax,1
		cmp	ax,CircleYMin
		jl	Skip7_2
		cmp	ax,CircleYMax
		jg	Skip7_2

;*             min y = min(min y, y org - y)

		cmp	ax,MinY
		jge	Ok7_3
		mov	MinY,ax

;*             x temp = clip x max
;*             rhsx(y org - y) = x temp

Ok7_3:		neg	bx		;(-y)

		mov	ax,CircleXMax
		mov	RhsX[si+bx],ax

;*             x temp = max(x org - x aspect, clip x min)
;*             lhsx(y org - y) = x temp

		mov	ax,bp
		sub	ax,dx
		cmp	ax,CircleXMin
		jge	Ok7_4
		mov	ax,CircleXMin
Ok7_4:		mov	LhsX[si+bx],ax

		neg	bx		;(+y)

;*          end if
;*       end if

Skip7_2:	shr	bx,1		;y / 2 (restore)

;*       sum = sum - y
;*       y = y - 1

		sub	di,bx
		dec	bx

;*    end if
;*    x = x + 1

SkipXYOcts7:	inc	cx

;* while end

		jmp	CircleLoop7

;===========================================
;* circle origin below / left of clip region
;===========================================

;* test if circle is visible before drawing

BelowLeftDone: 	mov	ax,MinY
		cmp	ax,DUMMY_MAX	;visible?
		je	BelowLeftSkip	;no ->
		jmp	CircleDone
BelowLeftSkip:	jmp	CircleExit

;* dx = radius
;* si = y org
;* bp = x org

;* min y = DUMMY_MAX
;* max y = clip y max

ClipBelowLeft:	mov	ax,DUMMY_MAX
		mov	MinY,ax
		mov	ax,CircleYMax
		mov	MaxY,ax

;* x = 0
;* y = radius
;* sum = 0

  		xor	cx,cx
		mov	bx,dx
		xor	di,di
	
		shl	si,1		;y org * 2 (word access)

;* while(x <= y)

CircleLoop8:	cmp	cx,bx
		jg	BelowLeftDone

;*    swap x, y

		xchg	bx,cx
		shl	bx,1		;y * 2 (word access)
	
;*    x aspect = x * aspect ratio

		ASPECT	dx,cx

;*    if (x org + x aspect) >= clip x min then

		mov	ax,bp
		add	ax,dx
		cmp	ax,CircleXMin
		jl	Skip8_1

;*       if (y org - y) >= clip y min and (y org - y) <= clip y max then

		mov	ax,si
		sub	ax,bx
		js	Skip8_1		;not valid if -ve ->
		shr	ax,1
		cmp	ax,CircleYMin
		jl	Skip8_1
		cmp	ax,CircleYMax
		jg	Skip8_1

;*          min y = min(min y, y org - y)

		cmp	ax,MinY
		jge	Ok8_1
		mov	MinY,ax

;*          x temp = min(x org + x aspect, clip x max)
;*          rhsx(y org - y) = x temp

Ok8_1:		neg	bx		;(-y)

		mov	ax,bp
		add	ax,dx
		cmp	ax,CircleXMax
		jle	Ok8_2
		mov	ax,CircleXMax
Ok8_2:		mov	RhsX[si+bx],ax

;*          x temp = clip x min
;*          lhsx(y org - y) = x temp

		mov	ax,CircleXMin
		mov	LhsX[si+bx],ax

		neg	bx		;(+y)

;*       end if
;*    end if
;*    swap x, y

Skip8_1:	shr	bx,1		;y / 2 (restore)
		xchg	bx,cx

;*    sum = sum + x
;*    if sum > 0 then

		add	di,cx
		jle	SkipXYOcts8

		shl	bx,1		;y * 2 (word access)
	
;*       x aspect = x * aspect ratio

		ASPECT	dx,cx

;*       if (x org + x aspect) >= clip x min then

		mov	ax,bp
		add	ax,dx
		cmp	ax,CircleXMin
		jl	Skip8_2

;*          if (y org - y) >= clip y min and (y org - y) <= clip y max then

		mov	ax,si
		sub	ax,bx
		js	Skip8_2		;not valid if -ve ->
		shr	ax,1
		cmp	ax,CircleYMin
		jl	Skip8_2
		cmp	ax,CircleYMax
		jg	Skip8_2

;*             min y = min(min y, y org - y)

		cmp	ax,MinY
		jge	Ok8_3
		mov	MinY,ax

;*             x temp = min(x org + x aspect, clip x max)
;*             rhsx(y org - y) = x temp

Ok8_3:		neg	bx		;(-y)

		mov	ax,bp
		add	ax,dx
		cmp	ax,CircleXMax
		jle	Ok8_4
		mov	ax,CircleXMax
Ok8_4:		mov	RhsX[si+bx],ax

;*             x temp = clip x min
;*             lhsx(y org - y) = x temp

		mov	ax,CircleXMin
		mov	LhsX[si+bx],ax

		neg	bx		;(+y)

;*          end if
;*       end if

Skip8_2:	shr	bx,1		;y / 2 (restore)

;*       sum = sum - y
;*       y = y - 1

		sub	di,bx
		dec	bx

;*    end if
;*    x = x + 1

SkipXYOcts8:	inc	cx

;* while end

		jmp	CircleLoop8

;====================================
;* circle origin right of clip region
;====================================

RightDone: 	jmp	CircleDone

;* dx = radius
;* si = y org
;* bp = x org

;* min y = clip y max
;* max y = clip y min

ClipRight:	mov	ax,CircleYMax
		mov	MinY,ax
		mov	ax,CircleYMin
		mov	MaxY,ax

;* x = 0
;* y = radius
;* sum = 0

  		xor	cx,cx
		mov	bx,dx
		xor	di,di
	
		shl	si,1		;y org * 2 (word access)

;* while(x <= y)

CircleLoop9: 	cmp	cx,bx
		jg	RightDone

;*    swap x, y
	
		xchg	bx,cx
		shl	bx,1		;y * 2 (word access)
	
;*    x aspect = x * aspect ratio

		ASPECT	dx,cx

;*    if (x org - x aspect) <= clip x max then

		mov	ax,bp
		sub	ax,dx
		cmp	ax,CircleXMax
		jg      Skip9_2

;*       if (y org - y) >= clip y min then

		mov	ax,si
		sub	ax,bx
		js	Skip9_1		;not valid if -ve ->
		shr	ax,1
		cmp	ax,CircleYMin
		jl	Skip9_1

;*          min y = min(min y, y org - y) 

		cmp	ax,MinY
		jge	Ok9_1
		mov	MinY,ax

;*          x temp = clip x max
;*          rhsx(y org - y) = x temp

Ok9_1:		neg	bx		;(-y)

		mov	ax,CircleXMax
		mov	RhsX[si+bx],ax

;*          x temp = max(x org - x aspect, clip x min)
;*          lhsx(y org - y) = x temp

		mov	ax,bp
		sub	ax,dx
		cmp	ax,CircleXMin
		jge	Ok9_2
		mov	ax,CircleXMin
Ok9_2:		mov	LhsX[si+bx],ax

		neg	bx		;(+y)

;*       end if
;*       if (y org + y) <= clip y max then

Skip9_1:	mov	ax,si
		add	ax,bx
		js	Skip9_2 	;not valid if -ve ->
		shr	ax,1
		cmp	ax,CircleYMax
		jg	Skip9_2

;*          max y = max(max y, y org + y) 

		cmp	ax,MaxY
		jle	Ok9_3
		mov	MaxY,ax

;*          x temp = clip x max
;*          rhsx(y org + y) = x temp

Ok9_3:		mov	ax,CircleXMax
		mov	RhsX[si+bx],ax

;*          x temp = max(x org - x aspect, clip x min)
;*          lhsx(y org + y) = x temp

		mov	ax,bp
		sub	ax,dx
		cmp	ax,CircleXMin
		jge	Ok9_4
		mov	ax,CircleXMin
Ok9_4:		mov	LhsX[si+bx],ax

;*       end if
;*    end if
;*    swap x, y

Skip9_2:	shr	bx,1		;y / 2 (restore)
		xchg	bx,cx

;*    sum = sum + x
;*    if sum > 0 then

		add	di,cx
		jle	SkipXYOcts9

		shl	bx,1		;y * 2 (word access)
	
;*       x aspect = x * aspect ratio

		ASPECT	dx,cx

;*       if (x org - x aspect) <= clip x max then

		mov	ax,bp
		sub	ax,dx
		cmp	ax,CircleXMax
		jg	Skip9_4

;*          if (y org - y) >= clip y min then

		mov	ax,si
		sub	ax,bx
		js	Skip9_3		;not valid if -ve ->
		shr	ax,1
		cmp	ax,CircleYMin
		jl	Skip9_3

;*             min y = min(min y, y org - y) 

		cmp	ax,MinY
		jge	Ok9_5
		mov	MinY,ax

;*             x temp = clip x max
;*             rhsx(y org - y) = x temp

Ok9_5:		neg	bx		;(-y)

		mov	ax,CircleXMax
		mov	RhsX[si+bx],ax

;*             x temp = max(x org - x aspect, clip x min)
;*             lhsx(y org - y) = x temp

		mov	ax,bp
		sub	ax,dx
		cmp	ax,CircleXMin
		jge	Ok9_6
		mov	ax,CircleXMin
Ok9_6:		mov	LhsX[si+bx],ax

		neg	bx		;(+y)

;*          end if
;*          if (y org + y) <= clip y max then

Skip9_3:	mov	ax,si
		add	ax,bx
		js	Skip9_4 	;not valid if -ve ->
		shr	ax,1
		cmp	ax,CircleYMax
		jg	Skip9_4

;*             max y = max(max y, y org + y) 

		cmp	ax,MaxY
		jle	Ok9_7
		mov	MaxY,ax

;*             x temp = clip x max
;*             rhsx(y org + y) = x temp

Ok9_7:		mov	ax,CircleXMax
		mov	RhsX[si+bx],ax

;*             x temp = max(x org - x aspect, clip x min)
;*             lhsx(y org + y) = x temp

		mov	ax,bp
		sub	ax,dx
		cmp	ax,CircleXMin
		jge	Ok9_8
		mov	ax,CircleXMin
Ok9_8:		mov	LhsX[si+bx],ax

;*          end if
;*       end if

Skip9_4:       shr	bx,1		;y / 2 (restore)

;*       sum = sum - y
;*       y = y - 1

		sub	di,bx
		dec	bx

;*    end if
;*    x = x + 1

SkipXYOcts9:	inc	cx 

;* while end

		jmp	CircleLoop9

;===================================
;* circle origin left of clip region
;===================================

LeftDone: 	jmp	CircleDone

;* dx = radius
;* si = y org
;* bp = x org

;* min y = clip y max
;* max y = clip y min

ClipLeft:	mov	ax,CircleYMax
		mov	MinY,ax
		mov	ax,CircleYMin
		mov	MaxY,ax

;* x = 0
;* y = radius
;* sum = 0

  		xor	cx,cx
		mov	bx,dx
		xor	di,di
	
		shl	si,1		;y org * 2 (word access)

;* while(x <= y)

CircleLoop10: 	cmp	cx,bx
		jg	LeftDone

;*    swap x, y

		xchg	bx,cx
		shl	bx,1		;y * 2 (word access)
	
;*    x aspect = x * aspect ratio

		ASPECT	dx,cx

;*    if (x org + x aspect) >= clip x min then

		mov	ax,bp
		add	ax,dx
		cmp	ax,CircleXMin
		jl	Skip10_2

;*       if (y org - y) >= clip y min then

		mov	ax,si
		sub	ax,bx
		js	Skip10_1	;not valid if -ve ->
		shr	ax,1
		cmp	ax,CircleYMin
		jl	Skip10_1

;*          min y = min(min y, y org - y) 

		cmp	ax,MinY
		jge     Ok10_1
		mov	MinY,ax

;*          x temp = min(x org + x aspect, clip x max)
;*          rhsx(y org - y) = x temp

Ok10_1:		neg	bx		;(-y)

		mov	ax,bp
		add	ax,dx
		cmp	ax,CircleXMax
		jle	Ok10_2
		mov	ax,CircleXMax
Ok10_2:		mov	RhsX[si+bx],ax

;*          x temp = clip x min
;*          lhsx(y org - y) = x temp

		mov	ax,CircleXMin
		mov	LhsX[si+bx],ax

		neg	bx		;(+y)

;*       end if
;*       if (y org + y) <= clip y max then

Skip10_1:	mov	ax,si
		add	ax,bx
		js	Skip10_2	;not valid if -ve ->
		shr	ax,1
		cmp	ax,CircleYMax
		jg	Skip10_2

;*          max y = max(max y, y org + y) 

		cmp	ax,MaxY
		jle	Ok10_3
		mov	MaxY,ax

;*          x temp = min(x org + x aspect, clip x max)
;*          rhsx(y org + y) = x temp

Ok10_3:		mov	ax,bp
		add	ax,dx
		cmp	ax,CircleXMax
		jle	Ok10_4
		mov	ax,CircleXMax
Ok10_4:		mov	RhsX[si+bx],ax

;*          x temp = clip x min
;*          lhsx(y org + y) = x temp

		mov	ax,CircleXMin
		mov	LhsX[si+bx],ax

;*       end if
;*    end if
;*    swap x, y

Skip10_2:	shr	bx,1		;y / 2 (restore)
		xchg	bx,cx

;*    sum = sum + x
;*    if sum > 0 then

		add	di,cx
		jle	SkipXYOcts10

		shl	bx,1		;y * 2 (word access)

;*       x aspect = x * aspect ratio

		ASPECT	dx,cx

;*       if (x org + x aspect) >= clip x min then

		mov	ax,bp
		add	ax,dx
		cmp	ax,CircleXMin
		jl	Skip10_4

;*          if (y org - y) >= clip y min then

		mov	ax,si
		sub	ax,bx
		js	Skip10_3	;not valid if -ve ->
		shr	ax,1
		cmp	ax,CircleYMin
		jl	Skip10_3

;*             min y = min(min y, y org - y) 

		cmp	ax,MinY
		jge	Ok10_5
		mov	MinY,ax

;*             x temp = min(x org + x aspect, clip x max)
;*             rhsx(y org - y) = x temp

Ok10_5:		neg	bx		;(-y)

		mov	ax,bp
		add	ax,dx
		cmp	ax,CircleXMax
		jle	Ok10_6
		mov	ax,CircleXMax
Ok10_6:		mov	RhsX[si+bx],ax

;*             x temp = clip x min
;*             lhsx(y org - y) = x temp

		mov	ax,CircleXMin
		mov	LhsX[si+bx],ax

		neg	bx		;(+y)

;*          end if
;*          if (y org + y) <= clip y max then


Skip10_3:	mov	ax,si
		add	ax,bx
		js	Skip10_4	;not valid if -ve ->
		shr	ax,1
		cmp	ax,CircleYMax
		jg	Skip10_4

;*             max y = max(max y, y org + y) 

		cmp	ax,MaxY
		jle	Ok10_7
		mov	MaxY,ax

;*             x temp = min(x org + x aspect, clip x max)
;*             rhsx(y org + y) = x temp

Ok10_7:		mov	ax,bp
		add	ax,dx
		cmp	ax,CircleXMax
		jle	Ok10_8
		mov	ax,CircleXMax
Ok10_8:		mov	RhsX[si+bx],ax

;*             x temp = clip x min
;*             lhsx(y org + y) = x temp

		mov	ax,CircleXMin
		mov	LhsX[si+bx],ax

;*          end if
;*       end if

Skip10_4:       shr bx,1		;y / 2 (restore)

;*       sum = sum - y
;*       y = y - 1

		sub	di,bx
		dec	bx

;*    end if
;*    x = x + 1

SkipXYOcts10:	inc	cx

;* while end

		jmp	CircleLoop10

CircleFill	ENDP

GCODE		ENDS	   	

;============================================================================

		END

