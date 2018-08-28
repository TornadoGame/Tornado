;****************************************************************************
;*
;* VSCREEN.ASM
;* 
;* 2D virtual screen driver.
;*
;* 05.02.1992 - KJB
;* 25.03.1992 - KJB - PUBLIC routines made FAR.
;*
;* The purpose of the 2D virtual screen driver is to provide an enviroment,
;* similar to the 3D engine, which can be used to manipulate 2D graphics.
;*
;* The basic principle being to scale up, rotate and clip 2D graphics using a
;* virtual screen and then scale down calculating CRT co-ords for the desired
;* viewport.
;*
;* Scaling up values has the advantage of improving resolution for rotation
;* and clipping.
;*
;* Typical applications might be a zoomable moving map, HUD pitch bars,
;* zoomable navigation / waypoint display etc.
;*
;* The virtual co-ords should not really exceed +/-16k when scaled. Bear in
;* mind that x co-ords are adjusted by 1.25 to compensate for the aspect
;* ratio. In some cases it may be safer to limit the scaled co-ords to +/-8k
;* if connected points can be on opposite sides of the viewport.
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	VSetViewport
		PUBLIC	VSetRotation
		PUBLIC	VCalcOutCodes
		PUBLIC	VQuickOutCodes
		PUBLIC	VPolyClip
		PUBLIC	VPolyLineClip
		PUBLIC	VQuickLineClip
		PUBLIC	VDotClip

		EXTRN	ClipBuffer:WORD
		EXTRN	SinTable:WORD
		EXTRN	CosTable:WORD
		EXTRN	ClipRecover:WORD

;============================================================================

		INCLUDE	VISEXTRN.INC
		INCLUDE	VSCREEN.INC
		INCLUDE	\LIB8086\TRIG.INC
		INCLUDE	\LIB8086\USEFUL.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

;-----------------------------
;* current viewport data block
;-----------------------------

VP		VIEWPORT <>

;------------------------
;* clipping window limits
;------------------------

CLIPL		DW	0
CLIPR		DW	0
CLIPB		DW	0
CLIPA		DW	0

;-------------------------------
;* clipping window adjust origin (move to bottom lh corner)
;-------------------------------

XADJUST		DW	0
YADJUST		DW	0

;-----------------
;* viewport origin (bottom lh corner)
;-----------------

X_ORG		DW	0
Y_ORG		DW	0

;-----------------
;* viewport limits
;-----------------

XCRTMAX		DW	0
YCRTMAX		DW	0

;--------------------------
;* sin / cos rotation angle
;--------------------------

VSinR		DW	0
VCosR		DW	0

;---------------
;* outcode flags
;---------------

OCODEL		EQU	0001b
OCODER		EQU	0010b
OCODEB		EQU	0100b
OCODEA		EQU	1000b

;------------------
;* object draw mode
;------------------

DRAW_OBJECT	EQU	0		;no clipping required
CLIP_OBJECT	EQU	2		;clipping required
SKIP_OBJECT	EQU	4		;object not visible

ObjectDrawMode	DW	0

PolyClipMode	DW	DrawPoly	;DRAW_OBJECT
		DW	ClipPoly	;CLIP_OBJECT
		DW	NullPoly	;SKIP_OBJECT

PLineClipMode	DW	DrawPolyLine	;DRAW_OBJECT
		DW	ClipPolyLine	;CLIP_OBJECT
		DW	NullPolyLine	;SKIP_OBJECT

;----------------
;* poly clip data
;----------------

LastPtr		DW	0

LookAhead	DB	0,0

IntoPolyClip	DW	IntoLeftClip
		DW	IntoRightClip
		DW	IntoBelowClip
		DW	IntoAboveClip
		DW	SortPolyCrt

XA		EQU	0
YA		EQU	2

XB		EQU	-6
YB		EQU	-4

XC		EQU	0
YC		EQU	2
OC		EQU	4

;---------------
;* miscellaneous
;---------------

TempPtr1 	DW	0
TempPtr2 	DW	0
TempPtr3 	DW	0

DATA		ENDS

;============================================================================

VISCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:VISCODE
		ASSUME DS:DATA

;* OCODE - calculate outcode
;*
;* pass: xv = x virtual co-ord
;*       yv = y virtual co-ord
;* ret : al = outcode 0000ABRL - active high
;*       zf = 1 (z)  = visible
;*       zf = 0 (nz) = non-visible
;* kill: flags

OCODE		MACRO	xv,yv
		LOCAL	OCode1,OCode2,Ocode3,OCode4

		xor	al,al		;clear outcode (assume visible)

		cmp	xv,CLIPR	;right clip?
		jle	OCode1		;no ->

		or	al,OCODER

		jmp	OCode2

OCode1:		cmp	xv,CLIPL	;left clip?
		jge	OCode2		;no ->

		or	al,OCODEL

OCode2:		cmp	yv,CLIPA	;above clip?
		jle	OCode3		;no ->

		or	al,OCODEA

		jmp	OCode4

OCode3:		cmp	yv,CLIPB	;below clip?
		jge	OCode4		;no ->

		or	al,OCODEB

OCode4:		test	al,al

		ENDM

;----------------------------------------------------------------------------

;* CRTXY - calculate CRT co-ord
;*
;* pass: x = x virtual co-ord
;*       y = y virtual co-ord
;*       cl = scale down shift count
;* ret : x = x crt co-ord
;*       y = y crt co-ord

CRTXY		MACRO	x,y
		LOCAL	XCrtOk,YCrtOk

		add	x,XADJUST	;0 .. clip limit * 2 - 1
		shr	x,cl		;scale down
		adc	x,0		;1/2 bit round up
		cmp	x,XCRTMAX	;in limits?
		jbe	XCrtOk		;yes ->
		mov	x,XCRTMAX

XCrtOk:		add	x,X_ORG

		add	y,YADJUST	;0 .. clip limit * 2 - 1
		shr	y,cl		;scale down
		adc	y,0		;1/2 bit round up
		cmp	y,YCRTMAX	;in limits?
		jbe	YCrtOk		;yes ->
		mov	y,YCRTMAX

YCrtOk:		neg	y

		add	y,Y_ORG

		ENDM

;----------------------------------------------------------------------------

;* VSetViewport - initialize viewport
;*
;* pass: ax = rotation angle (0 .. 511 pdegs)
;*       si -> VIEWPORT data block
;* ret : VP
;*       VSinR
;*       VCosR
;* kill: assume all

VSetViewport	PROC	FAR

;----------------------
;* reset rotation angle
;----------------------

		call	FAR PTR VSetRotation

;--------------------------
;* copy VIEWPORT data block
;--------------------------

		mov	di,OFFSET VP
		mov	cx,VP_REC_SIZE

		FAST_MOVE

;-----------------------------
;* calc clipping window limits
;-----------------------------

		mov	cl,VP.V_SCALE_DN

;* limit = (VP.V_WIDTH / 2) << VP.V_SCALE_DN
;*
;* CLIPR = limit - 1
;* CLIPL = -limit

		mov	ax,VP.V_WIDTH
		shr	ax,1		;assume even width (no resolution lost)
		shl	ax,cl

		mov	XADJUST,ax

		neg	ax		;-limit
		mov	CLIPL,ax

		neg	ax
		dec	ax		;limit - 1
		mov	CLIPR,ax

;* limit = (VP.V_DEPTH / 2) << VP.V_SCALE_DN
;*
;* CLIPA = limit - 1
;* CLIPB = -limit

		mov	ax,VP.V_DEPTH
		shr	ax,1		;assume even depth (no resolution lost)
		shl	ax,cl

		mov	YADJUST,ax

		neg	ax		;-limit
		mov	CLIPB,ax

		neg	ax
		dec	ax		;limit - 1
		mov	CLIPA,ax

;----------------------
;* calc viewport origin (bottom lh corner)
;----------------------

		mov	ax,VP.V_X_ORG
		mov	X_ORG,ax

		mov	ax,VP.V_Y_ORG
		add	ax,VP.V_DEPTH
		dec	ax
		mov	Y_ORG,ax

;----------------------
;* calc viewport limits
;----------------------

;* XCRTMAX = VP.V_WIDTH - 1

		mov	ax,VP.V_WIDTH
		dec	ax
		mov	XCRTMAX,ax

;* YCRTMAX = VP.V_DEPTH - 1

		mov	ax,VP.V_DEPTH
		dec	ax
		mov	YCRTMAX,ax

		ret

VSetViewport	ENDP

;----------------------------------------------------------------------------

;* VSetRotation - set virtual screen rotation angle
;*
;* pass: ax = rotation angle (0 .. 511 pdegs)
;* ret : VSinR
;*       VCosR
;* kill: ax, bx, dx, flags

VSetRotation	PROC	FAR

		SINCOS	ax,dx,ax
		
		mov	VSinR,ax
		mov	VCosR,dx

		ret

VSetRotation	ENDP

;----------------------------------------------------------------------------

;* VCalcOutCodes - scale, rotate and calculate outcodes
;*
;* pass: si indexes last vertex in Xe[] and Ye[] arrays
;* ret : ax = ObjectDrawMode
;*       cf = 0: object visible
;*       cf = 1: object non-visible
;*       XCrt[] = x crt co-ords if DRAW_OBJECT mode
;*       YCrt[] = y crt co-ords if DRAW_OBJECT mode
;* kill: assume all (except cf)

VCalcOutCodes	PROC	FAR

		push	si 		;store last vertex index

		mov	cl,VP.V_SCALE_UP

;* dl = object non-visible test mask, dh = object totally visible test mask

		mov	dx,000ffh

OCodeLoop:	push	dx
		call	VTransform	;scale and rotate
		pop	dx

		OCODE	di,bp

		mov	OutCode[si],al	;store outcode

		and	dl,al		;update non-visible test mask
		or	dh,al		;update totally visible test mask

		sub	si,2		;next co-ord
		jnc	OCodeLoop

		pop	si		;restore last vertex index

		test	dl,dl		;object visible?
		jnz	SkipObject	;no ->

		test	dh,dh		;object totally visible?
		jz	DrawObject	;yes ->

;* clip object - object partially visible

ClipObject:	mov	ax,CLIP_OBJECT
		mov	ObjectDrawMode,ax
		clc			;cf = 0 (object visible)
		ret

;* skip object - object totally non-visible

SkipObject:	mov	ax,SKIP_OBJECT
		mov	ObjectDrawMode,ax
		stc			;cf = 1 (object non-visible)
		ret

;* draw object - object totally visible, generate all crt co-ords now

DrawObject:	mov	cl,VP.V_SCALE_DN

GenXYCrtLoop:	mov	ax,Xe[si]
		mov	dx,Ye[si]

		CRTXY	ax,dx

		mov	XCrt[si],ax
		mov	WORD PTR YCrt[si],dx

		sub	si,2		;next vertex index
		jnc	GenXYCrtLoop
		
		mov	ax,DRAW_OBJECT
		mov	ObjectDrawMode,ax
		clc			;cf = 0 (object visible)
		ret

VCalcOutCodes	ENDP

;----------------------------------------------------------------------------

;* VQuickOutCodes - calculate outcodes (for sector culling etc.)
;*
;* pass: si indexes last vertex in Xe[] and Ye[] arrays
;* ret : cf = 0: object visible
;*       cf = 1: object non-visible
;* kill: assume all (except cf)

VQuickOutCodes	PROC	FAR

;* dl = object non-visible test mask

		mov	dl,0ffh

		mov	cl,VP.V_SCALE_UP

QuickOCodeLoop:	push	dx
		call	VTransform	;scale and rotate
		pop	dx

		OCODE	di,bp

		and	dl,al		;update non-visible test mask

		sub	si,2		;next eye co-ord
		jnc	QuickOCodeLoop

		xor	al,al
		sub	al,dl		;cf = 0 = visible, cf = 1 = non-visible

		ret

VQuickOutCodes	ENDP

;----------------------------------------------------------------------------

;* VTransform - scale, rotate and adjust aspect ratio
;*
;* pass: cl = scale up shift count
;*       si indexes Xe[] and Ye[]
;* ret : di = Xe[si] = xt (transformed virtual x co-ord)
;*       bp = Ye[si] = yt (transformed virtual y co-ord)
;* kill: ax, bx, dx, flags

VTransform	PROC	NEAR

;----------
;* scale up
;----------

		mov	di,Xe[si]
		sal	di,cl		;xs = x << cl
		mov	bp,Ye[si]
		sal	bp,cl		;ys = y << cl

;-----------------------------------
;* rotate xs and adjust aspect ratio
;-----------------------------------

;* xt = (xs * VCosR + ys * VSinR) * 1.25

		mov	ax,VCosR
		imul	di
		FRACADJ	bx		;xs * VCosR

		mov	ax,VSinR
		imul	bp
		FRACADJ	dx		;ys * VSinR

		add	dx,bx 		;xs * VCosR + ys * VSinR

		mov	bx,dx

		sar	bx,1		;/2 (0.5)
		sar	bx,1		;/4 (0.25)

		add	dx,bx		;(xs * VCosR + ys * VSinR) * 1.25

		mov	Xe[si],dx

;----------
;* rotate y
;----------

;* yt = ys * VCosR - xs * VSinR

		xchg	dx,di		;dx = xs, di = xt

		mov	ax,VSinR
		imul	dx
		FRACADJ	bx		;xs * VSinR

		mov	ax,VCosR
		imul	bp
		FRACADJ	bp		;ys * VCosR

		sub	bp,bx  		;ys * VCosR - xs * VSinR

		mov	Ye[si],bp

		ret

VTransform	ENDP

;----------------------------------------------------------------------------

;* VPolyClip - generate clipped polygon (wrt ObjectDrawMode)
;*
;* pass: si -> polygon data
;*       ie. [si+0] = vertex index
;*             ..   =   ..    ..
;*           [si+n] =   ..    ..
;*           [si+m] = -1 (list terminator)
;*       di -> crt buffer position
;* ret : si -> next face data
;*       di -> next crt buffer position
;*	 cf = 0 = visible
;*       cf = 1 = non-visible or error (do not draw polygon)
;* kill: ax, bx, cx, dx, bp, flags

VPolyClip	PROC	FAR

		mov	bx,ObjectDrawMode
		jmp	PolyClipMode[bx]

VPolyClip	ENDP

;----------------------------------------------------------------------------

;* DrawPoly - draw polygon (no clipping required)
;*
;* pass: )
;* ret : ) Refer to PolyClip
;* kill: )
;*
;* note: All x crt and y crt values have been pre-calculated in VCalcOutCodes
;*       and stored in the crt arrays XCrt[] and YCrt[].

DrawPoly	PROC	NEAR

		mov	bp,di		;store crt buffer ptr

		xor	bx,bx

DrawPolyLoop:	lodsb			;fetch vertex index
		cmp	al,-1		;end of list?
		je	SortPolyTerm	;yes ->

		mov	bl,al

		mov	ax,XCrt[bx]
		stosw
		mov	ax,WORD PTR YCrt[bx]
		stosw

		jmp	DrawPolyLoop

SortPolyTerm:	cmp	di,bp		;any points?
		je	DrawPolyFail	;no ->

		xchg	bp,si		;store ptr to next polygon data

		movsw			;copy 1st x crt to end
		movsw			;copy 1st y crt to end
		mov	ax,-1
		stosw			;store terminator

		mov	si,bp		;restore ptr to next polygon data

		clc			;cf = 0 = visible
		retf			;<<<<< MUST BE FAR <<<<<

DrawPolyFail:	stc			;cf = 1 = non-visible or error
		retf			;<<<<< MUST BE FAR <<<<<

DrawPoly	ENDP

;----------------------------------------------------------------------------

;* ClipPoly - draw clipped polygon
;*
;* pass: )
;* ret : ) Refer to PolyClip
;* kill: )
;*
;* note: Uses Sutherland - Hodgman polygon clipping algorithm.

ClipPoly	PROC	NEAR

		mov	TempPtr1,di

		xor	bx,bx

;* dl = object non-visible test mask, dh = object totally visible test mask

		mov	dx,000ffh

		mov	di,OFFSET ClipBuffer+6

NextPolyCoord:	lodsb			;fetch vertex index
		cmp	al,-1		;end of list?
		je	SortPolyVis	;yes, sort polygon visibility ->

		mov	bl,al
		mov	ax,Xe[bx]
		stosw
		mov	ax,Ye[bx]
		stosw
		mov	al,OutCode[bx]
		stosw			;store word for padding

		and	dl,al		;update non-visible test mask
		or	dh,al		;update totally visible test mask

		jmp	NextPolyCoord

;* sort polygon visibility (totally visible, partially visible, non-visible)

SortPolyVis:	push	si		;store ptr to next polygon data

		mov	ClipRecover,sp	;recover stack to here if clip error

		mov	si,OFFSET ClipBuffer+6
		
		test	dl,dl		;polygon non-visible?
		jnz	ClipPolyFailLnk	;yes ->

;* if partially visible then jump to first clip required

		xor	bx,bx		;reset index
		
		rcr	dh,1		;cf = 1 = left clip required
		jc	ClipSwitch
		add	bx,2

		rcr	dh,1		;cf = 1 = right clip required
		jc	ClipSwitch
		add	bx,2

		rcr	dh,1		;cf = 1 = below clip required
		jc	ClipSwitch
		add	bx,2

		rcr	dh,1		;cf = 1 = above clip required
		jc	ClipSwitch
		add	bx,2

ClipSwitch:	jmp	IntoPolyClip[bx]

ClipPolyFailLnk:jmp	ClipPolyFail

;----------------------
;* clip all points left
;----------------------

IntoLeftClip:	xor	al,al		;reset look ahead outcode mask
		mov	LookAhead,al

		mov	LastPtr,di

		mov	ax,[di-6]	;move last point in front of first
		mov	[si-6],ax
		mov	ax,[di-4]
		mov	[si-4],ax
		mov	ax,[di-2]
		mov	[si-2],ax
		mov	dl,al
		and	dl,OCODEL 	;dl = end b outcode

LeftClipLoop:	mov	dh,[si+4]
		and	dh,OCODEL	;dh = end a outcode	
		mov	al,dh
		xor	al,dl	    	;ends a and b on same side of viewport?
		jz 	SkipLeftClip	;yes ->
		
		push	dx
		call	PolyClipLeft
		or	LookAhead,al	;update look ahead outcode mask
		pop 	dx

SkipLeftClip:	test	dh,dh		;end a visible?
		jnz	SkipLeftPoint	;no ->

		movsw			;store new point if visible
		movsw
		lodsw
		or	LookAhead,al	;update look ahead outcode mask
		stosw
		jmp	NextLeftClip

SkipLeftPoint:	add	si,6		;skip point
	
NextLeftClip:	mov	dl,dh
		cmp	si,LastPtr	;all points done?
		jb	LeftClipLoop	;no ->

		cmp	si,di		;any points remaining?
		jne	RightClipStart	;yes, move on to next clip ->
LeftFail:	jmp	ClipPolyFail
		
;-----------------------
;* clip all points right
;-----------------------

RightClipStart:	mov	al,LookAhead
		test	al,0001b	;any rogue points?
		jnz	LeftFail	;yes, clip failed ->
		test	al,OCODER	;any right clipping required?
		jz	BelowClipStart	;no ->

IntoRightClip:	xor	al,al		;reset look ahead outcode mask
		mov	LookAhead,al

		mov	LastPtr,di

		mov	ax,[di-6]	;move last point in front of first
		mov	[si-6],ax
		mov	ax,[di-4]
		mov	[si-4],ax
		mov	ax,[di-2]
		mov	[si-2],ax
		mov	dl,al
		and	dl,OCODER 	;dl = end b outcode

RightClipLoop:	mov	dh,[si+4]
		and	dh,OCODER	;dh = end a outcode	
		mov	al,dh
		xor	al,dl	    	;ends a and b on same side of viewport?
		jz 	SkipRightClip	;yes ->
		
		push	dx
		call	PolyClipRight
		or	LookAhead,al	;update look ahead outcode mask
		pop 	dx

SkipRightClip:	test	dh,dh		;end a visible?
		jnz	SkipRightPoint	;no ->

		movsw			;store new point if visible
		movsw
		lodsw
		or	LookAhead,al	;update look ahead outcode mask
		stosw
		jmp	NextRightClip

SkipRightPoint:	add	si,6		;skip point
	
NextRightClip:	mov	dl,dh
		cmp	si,LastPtr	;all points done?
		jb	RightClipLoop	;no ->

		cmp	si,di		;any points remaining?
		jne	BelowClipStart	;yes, move on to next clip ->
RightFail:	jmp	ClipPolyFail
	
;-----------------------
;* clip all points below
;-----------------------

BelowClipStart:	mov	al,LookAhead
		test	al,0011b	;any rogue points?
		jnz	RightFail	;yes, clip failed ->
		test	al,OCODEB	;any below clipping required?
		jz	AboveClipStart	;no ->

IntoBelowClip:	xor	al,al		;reset look ahead outcode mask
		mov	LookAhead,al

		mov	LastPtr,di

		mov	ax,[di-6]	;move last point in front of first
		mov	[si-6],ax
		mov	ax,[di-4]
		mov	[si-4],ax
		mov	ax,[di-2]
		mov	[si-2],ax
		mov	dl,al
		and	dl,OCODEB 	;dl = end b outcode

BelowClipLoop:	mov	dh,[si+4]
		and	dh,OCODEB	;dh = end a outcode	
		mov	al,dh
		xor	al,dl	    	;ends a and b on same side of viewport?
		jz 	SkipBelowClip	;yes ->
		
		push	dx
		call	PolyClipBelow
		or	LookAhead,al	;update look ahead outcode mask
		pop 	dx

SkipBelowClip:	test	dh,dh		;end a visible?
		jnz	SkipBelowPoint	;no ->

		movsw			;store new point if visible
		movsw	
		lodsw
		or	LookAhead,al	;update look ahead outcode mask
		stosw
		jmp	NextBelowClip

SkipBelowPoint:	add	si,6		;skip point
	
NextBelowClip:	mov	dl,dh
		cmp	si,LastPtr	;all points done?
		jb	BelowClipLoop	;no ->

		cmp	si,di		;any points remaining?
		jne	AboveClipStart	;yes, move on to next clip ->
BelowFail:	jmp	ClipPolyFail
	
;-----------------------
;* clip all points above
;-----------------------

AboveClipStart:	mov	al,LookAhead
		test	al,0111b	;any rogue points?
		jnz	BelowFail	;yes, clip failed ->
		test	al,OCODEA	;any above clipping required?
		jz	SortPolyCrt	;no ->

IntoAboveClip:	xor	al,al		;reset look ahead outcode mask
		mov	LookAhead,al

		mov	LastPtr,di

		mov	ax,[di-6]	;move last point in front of first
		mov	[si-6],ax
		mov	ax,[di-4]
		mov	[si-4],ax
		mov	ax,[di-2]
		mov	[si-2],ax
		mov	dl,al
		and	dl,OCODEA 	;dl = end b outcode

AboveClipLoop:	mov	dh,[si+4]
		and	dh,OCODEA	;dh = end a outcode	
		mov	al,dh
		xor	al,dl	    	;ends a and b on same side of viewport?
		jz 	SkipAboveClip	;yes ->
		
		push	dx
		call	PolyClipAbove
		or	LookAhead,al	;update look ahead outcode mask
		pop 	dx

SkipAboveClip:	test	dh,dh		;end a visible?
		jnz	SkipAbovePoint	;no ->

		movsw			;store new point if visible
		movsw	
		lodsw
		or	LookAhead,al	;update look ahead outcode mask
		stosw
		jmp	NextAboveClip

SkipAbovePoint:	add	si,6		;skip point
	
NextAboveClip:	mov	dl,dh
		cmp	si,LastPtr	;all points done?
		jb	AboveClipLoop	;no ->

		mov	al,LookAhead
		test	al,1111b	;any rogue points?
		jnz	ClipPolyFail	;yes, clip failed ->

;-----------------------------
;* create crt list for polygon
;-----------------------------

SortPolyCrt:	cmp	si,di		;any points remaining?
		je	ClipPolyFail	;no ->

		mov	bp,di

		mov	di,TempPtr1

		mov	cl,VP.V_SCALE_DN

PolyCrtLoop:	lodsw			;fetch x
		mov	dx,ax
		lodsw			;fetch y
		
		xchg	ax,dx

		CRTXY	ax,dx

		stosw			;store x crt
		mov	ax,dx
		stosw			;store y crt

		add	si,2		;skip outcode data

		cmp	si,bp	 	;done all points?
		jb	PolyCrtLoop	;no ->

		mov	si,TempPtr1
		movsw			;copy 1st x crt to end
		movsw			;copy 1st y crt to end
		mov	ax,-1
		stosw			;store terminator

		pop	si		;restore ptr to next polygon data
		clc			;cf = 0 = visible
		retf			;<<<<< MUST BE FAR <<<<<

ClipPolyFail:	pop	si		;restore ptr to next polygon data
		stc			;cf = 1 = non-visible or error
		retf			;<<<<< MUST BE FAR <<<<<

ClipPoly	ENDP

;----------------------------------------------------------------------------

;* PolyClipCheck - polygon clip divide check
;*
;* pass: dx = numerator
;*       bp = denominator
;* ret : nothing
;* kill: flags

PolyClipCheck	PROC	NEAR

		push	dx
		push	bp

		test	bp,bp
		jz	ClipDivError	;divide by zero ->
		jns	@F
		neg	bp

@@:		test	dx,dx
		jns	@F
		neg	dx

@@:		cmp	bp,dx		;abs(bp) > abs(dx)?
		jbe	ClipDivError	;no ->

		pop	bp
		pop	dx

		ret

ClipDivError:	mov	sp,ClipRecover	;recover the stack

		jmp	ClipPolyFail

PolyClipCheck	ENDP

;----------------------------------------------------------------------------

;* PolyClipAbove - above polygon clip
;*
;* pass: si -> end a and end b data
;*       di -> clipped point store
;* ret : di -> next clipped point store
;* kill: ax, bx, cx, dx, bp, flags
;*
;* Clip equations:-
;*
;*    YC = CLIPA
;*
;*    DX = XB - XA
;*    DY = YB - YA
;*
;*    SELECT abs(DX)
;*    CASE < abs(DY)
;*       XC = XA + DX * (CLIPA - YA) / DY
;*    CASE > abs(DY)
;*       XC = XA + (CLIPA - YA) / (DY / DX)
;*    CASE = abs(DY)
;*       XC = XA + (CLIPA - YA) * sign(slope)
;*    END SELECT

PClipAboveFail	LABEL	NEAR		;<<<<< ERROR HANDLE <<<<<

		mov	sp,ClipRecover	;recover the stack

		jmp	ClipPolyFail

PolyClipAbove	PROC	NEAR

		mov	cx,XB[si]	;DX
		sub	cx,XA[si]
		jo	PClipAboveFail	;>>>>> ERROR >>>>>

		mov	bx,YB[si]	;DY
		sub	bx,YA[si]
		jo	PClipAboveFail	;>>>>> ERROR >>>>>

		mov	ax,bx
		ABSV	ax   		;abs(DY)
		mov	bp,ax

		mov	ax,cx
		ABSV	ax		;abs(DX)

		cmp	ax,bp		;select abs(DX)
		je	PClipA_EQ	;case = abs(DY) ->
		ja	PClipA_GT	;case > abs(DY) ->

;* case abs(DX) < abs(DY)

PClipA_LT:	mov	ax,CLIPA
		sub	ax,YA[si]	;CLIPA - YA
		jo	PClipAboveFail	;>>>>> ERROR >>>>>

		imul	cx		;DX * (CLIPA - YA)

		idiv	bx		;DX * (CLIPA - YA) / DY

		jmp	PClipACont

;* case abs(DX) > abs(DY)

PClipA_GT:	mov	dx,bx

		xor	ax,ax
		sar	dx,1
		rcr	ax,1

		idiv	cx		;DY / DX

		mov	bp,ax

		mov	dx,CLIPA
		sub	dx,YA[si]	;CLIPA - YA
		jo	PClipAboveFail	;>>>>> ERROR >>>>>

		call	PolyClipCheck

		xor	ax,ax
		sar	dx,1
		rcr	ax,1

		idiv	bp		;(CLIPA - YA) / (DY / DX)

		jmp	PClipACont

;* case abs(DX) = abs(DY)

PClipA_EQ:	mov	ax,cx
		xor	ax,bx
		cwd			;dx = sign(slope)

		mov	ax,CLIPA
		sub	ax,YA[si]	;CLIPA - YA
		jo	PClipAboveFail	;>>>>> ERROR >>>>>

		xor	ax,dx
		sub	ax,dx

PClipACont:	add	ax,XA[si]
		mov	XC[di],ax
		mov	cx,ax

		mov	bx,CLIPA
		mov	YC[di],bx

		OCODE	cx,bx

		mov	OC[di],al

		add	di,6

		ret

PolyClipAbove	ENDP

;----------------------------------------------------------------------------

;* PolyClipBelow - below polygon clip
;*
;* pass: si -> end a and end b data
;*       di -> clipped point store
;* ret : di -> next clipped point store
;* kill: ax, bx, cx, dx, bp, flags
;*
;* Clip equations:-
;*
;*    YC = CLIPB
;*
;*    DX = XB - XA
;*    DY = YB - YA
;*
;*    SELECT abs(DX)
;*    CASE < abs(DY)
;*       XC = XA + DX * (CLIPB - YA) / DY
;*    CASE > abs(DY)
;*       XC = XA + (CLIPB - YA) / (DY / DX)
;*    CASE = abs(DY)
;*       XC = XA + (CLIPB - YA) * sign(slope)
;*    END SELECT

PClipBelowFail	LABEL	NEAR		;<<<<< ERROR HANDLE <<<<<

		mov	sp,ClipRecover	;recover the stack

		jmp	ClipPolyFail

PolyClipBelow	PROC	NEAR

		mov	cx,XB[si]	;DX
		sub	cx,XA[si]
		jo	PClipBelowFail	;>>>>> ERROR >>>>>

		mov	bx,YB[si]	;DY
		sub	bx,YA[si]
		jo	PClipBelowFail	;>>>>> ERROR >>>>>

		mov	ax,bx
		ABSV	ax   		;abs(DY)
		mov	bp,ax

		mov	ax,cx
		ABSV	ax		;abs(DX)

		cmp	ax,bp		;select abs(DX)
		je	PClipB_EQ	;case = abs(DY) ->
		ja	PClipB_GT	;case > abs(DY) ->

;* case abs(DX) < abs(DY)

PClipB_LT:	mov	ax,CLIPB
		sub	ax,YA[si]	;CLIPB - YA
		jo	PClipBelowFail	;>>>>> ERROR >>>>>

		imul	cx		;DX * (CLIPB - YA)

		idiv	bx		;DX * (CLIPB - YA) / DY

		jmp	PClipBCont

;* case abs(DX) > abs(DY)

PClipB_GT:	mov	dx,bx

		xor	ax,ax
		sar	dx,1
		rcr	ax,1

		idiv	cx		;DY / DX

		mov	bp,ax

		mov	dx,CLIPB
		sub	dx,YA[si]	;CLIPB - YA
		jo	PClipBelowFail	;>>>>> ERROR >>>>>

		call	PolyClipCheck

		xor	ax,ax
		sar	dx,1
		rcr	ax,1

		idiv	bp		;(CLIPB - YA) / (DY / DX)

		jmp	PClipBCont

;* case abs(DX) = abs(DY)

PClipB_EQ:	mov	ax,cx
		xor	ax,bx
		cwd			;dx = sign(slope)

		mov	ax,CLIPB
		sub	ax,YA[si]	;CLIPB - YA
		jo	PClipBelowFail	;>>>>> ERROR >>>>>

		xor	ax,dx
		sub	ax,dx

PClipBCont:	add	ax,XA[si]
		mov	XC[di],ax
		mov	cx,ax

		mov	bx,CLIPB
		mov	YC[di],bx

		OCODE	cx,bx

		mov	OC[di],al

		add	di,6

		ret

PolyClipBelow	ENDP

;----------------------------------------------------------------------------

;* PolyClipRight - right polygon clip
;*
;* pass: si -> end a and end b data
;*       di -> clipped point store
;* ret : di -> next clipped point store
;* kill: ax, bx, cx, dx, bp, flags
;*
;* Clip equations:-
;*
;*    XC = CLIPR
;*
;*    DX = XB - XA
;*    DY = YB - YA
;*
;*    SELECT abs(DY)
;*    CASE < abs(DX)
;*       YC = YA + DY * (CLIPR - XA) / DX
;*    CASE > abs(DX)
;*       YC = YA + (CLIPR - XA) / (DX / DY)
;*    CASE = abs(DX)
;*       YC = YA + (CLIPR - XA) * sign(slope)
;*    END SELECT

PClipRightFail	LABEL	NEAR		;<<<<< ERROR HANDLE <<<<<

		mov	sp,ClipRecover	;recover the stack

		jmp	ClipPolyFail

PolyClipRight	PROC	NEAR

		mov	cx,XB[si]	;DX
		sub	cx,XA[si]
		jo	PClipRightFail	;>>>>> ERROR >>>>>

		mov	bx,YB[si]	;DY
		sub	bx,YA[si]
		jo	PClipRightFail	;>>>>> ERROR >>>>>

		mov	ax,cx
		ABSV	ax		;abs(DX)
		mov	bp,ax

		mov	ax,bx
		ABSV	ax   		;abs(DY)

		cmp	ax,bp		;select abs(DY)
		je	PClipR_EQ	;case = abs(DX) ->
		ja	PClipR_GT	;case > abs(DX) ->

;* case abs(DY) < abs(DX)

PClipR_LT:	mov	ax,CLIPR
		sub	ax,XA[si]	;CLIPR - XA
		jo	PClipRightFail	;>>>>> ERROR >>>>>

		imul	bx		;DY * (CLIPR - XA)

		idiv	cx		;DY * (CLIPR - XA) / DX

		jmp	PClipRCont

;* case abs(DY) > abs(DX)

PClipR_GT:	mov	dx,cx

		xor	ax,ax
		sar	dx,1
		rcr	ax,1

		idiv	bx		;DX / DY

		mov	bp,ax

		mov	dx,CLIPR
		sub	dx,XA[si]	;CLIPR - XA
		jo	PClipRightFail	;>>>>> ERROR >>>>>

		call	PolyClipCheck

		xor	ax,ax
		sar	dx,1
		rcr	ax,1

		idiv	bp		;(CLIPR - XA) / (DX / DY)

		jmp	PClipRCont

;* case abs(DY) = abs(DX)

PClipR_EQ:	mov	ax,cx
		xor	ax,bx
		cwd			;dx = sign(slope)

		mov	ax,CLIPR
		sub	ax,XA[si]	;CLIPR - XA
		jo	PClipRightFail	;>>>>> ERROR >>>>>

		xor	ax,dx
		sub	ax,dx

PClipRCont:	add	ax,YA[si]
		mov	YC[di],ax
		mov	bx,ax

		mov	cx,CLIPR
		mov	XC[di],cx

		OCODE	cx,bx

		mov	OC[di],al

		add	di,6

		ret

PolyClipRight	ENDP

;----------------------------------------------------------------------------

;* PolyClipLeft - left polygon clip
;*
;* pass: si -> end a and end b data
;*       di -> clipped point store
;* ret : di -> next clipped point store
;* kill: ax, bx, cx, dx, bp, flags
;*
;* Clip equations:-
;*
;*    XC = CLIPL
;*
;*    DX = XB - XA
;*    DY = YB - YA
;*
;*    SELECT abs(DY)
;*    CASE < abs(DX)
;*       YC = YA + DY * (CLIPL - XA) / DX
;*    CASE > abs(DX)
;*       YC = YA + (CLIPL - XA) / (DX / DY)
;*    CASE = abs(DX)
;*       YC = YA + (CLIPL - XA) * sign(slope)
;*    END SELECT

PClipLeftFail	LABEL	NEAR		;<<<<< ERROR HANDLE <<<<<

		mov	sp,ClipRecover	;recover the stack

		jmp	ClipPolyFail

PolyClipLeft	PROC	NEAR

		mov	cx,XB[si]	;DX
		sub	cx,XA[si]
		jo	PClipLeftFail	;>>>>> ERROR >>>>>

		mov	bx,YB[si]	;DY
		sub	bx,YA[si]
		jo	PClipLeftFail	;>>>>> ERROR >>>>>

		mov	ax,cx
		ABSV	ax		;abs(DX)
		mov	bp,ax

		mov	ax,bx
		ABSV	ax   		;abs(DY)

		cmp	ax,bp		;select abs(DY)
		je	PClipL_EQ	;case = abs(DX) ->
		ja	PClipL_GT	;case > abs(DX) ->

;* case abs(DY) < abs(DX)

PClipL_LT:	mov	ax,CLIPL
		sub	ax,XA[si]	;CLIPL - XA
		jo	PClipLeftFail	;>>>>> ERROR >>>>>

		imul	bx		;DY * (CLIPL - XA)

		idiv	cx		;DY * (CLIPL - XA) / DX

		jmp	PClipLCont

;* case abs(DY) > abs(DX)

PClipL_GT:	mov	dx,cx

		xor	ax,ax
		sar	dx,1
		rcr	ax,1

		idiv	bx		;DX / DY

		mov	bp,ax

		mov	dx,CLIPL
		sub	dx,XA[si]	;CLIPL - XA
		jo	PClipLeftFail	;>>>>> ERROR >>>>>

		call	PolyClipCheck

		xor	ax,ax
		sar	dx,1
		rcr	ax,1

		idiv	bp		;(CLIPL - XA) / (DX / DY)

		jmp	PClipLCont

;* case abs(DY) = abs(DX)

PClipL_EQ:	mov	ax,cx
		xor	ax,bx
		cwd			;dx = sign(slope)

		mov	ax,CLIPL
		sub	ax,XA[si]	;CLIPL - XA
		jo	PClipLeftFail	;>>>>> ERROR >>>>>

		xor	ax,dx
		sub	ax,dx

PClipLCont:	add	ax,YA[si]
		mov	YC[di],ax
		mov	bx,ax

		mov	cx,CLIPL
		mov	XC[di],cx

		OCODE	cx,bx

		mov	OC[di],al

		add	di,6

		ret

PolyClipLeft	ENDP

;----------------------------------------------------------------------------

;* NullPoly - null polygon clip routine
;*
;* pass: )
;* ret : ) Refer to PolyClip
;* kill: )

NullPoly	PROC	NEAR

NullPolyLoop:	lodsb			;move pointer past polygon data
		cmp	al,-1
		jne	NullPolyLoop

		stc			;cf = 1 = error
		retf			;<<<<< MUST BE FAR <<<<<

NullPoly	ENDP

;----------------------------------------------------------------------------

;* ClipLineEnd - clip one end of line
;*
;* pass: si = end a index
;*       di = end b index
;* ret : bp = x clipped
;*       dx = y clipped
;*       cf = 0 = visible
;*       cf = 1 = non-visible or error (do not draw line)
;* kill: ax, bx, cx, flags

ClipLineEnd	PROC	NEAR

		mov	ClipRecover,sp	;recover stack to here if clip error

		mov	al,OutCode[si]
		test	al,OCODEL	;left?
		jz	SkipLineLeft	;no ->
		call	LineClipLeft
		jz	ClipEndExit

		mov	al,OutCode[si]
SkipLineLeft:	test	al,OCODER	;right?
		jz	SkipLineRight	;no ->
		call	LineClipRight
		jz	ClipEndExit

		mov	al,OutCode[si]
SkipLineRight:	test	al,OCODEB	;below?
		jz	SkipLineBelow	;no ->
		call	LineClipBelow
		jz	ClipEndExit

		mov	al,OutCode[si]
SkipLineBelow:	test	al,OCODEA	;above?
		jz	ClipEndFail	;no ->
		call	LineClipAbove
		jnz	ClipEndFail	;error ->

ClipEndExit:	clc			;cf = 0 = visible
		ret

ClipEndFail:	stc			;cf = 1 = non-visible or error
		ret

ClipLineEnd	ENDP

;----------------------------------------------------------------------------

;* LineClipCheck - line clip divide check
;*
;* pass: dx = numerator
;*       bp = denominator
;* ret : nothing
;* kill: flags

LineClipCheck	PROC	NEAR

		push	dx
		push	bp

		test	bp,bp
		jz	LClipDivError	;divide by zero ->
		jns	@F
		neg	bp

@@:		test	dx,dx
		jns	@F
		neg	dx

@@:		cmp	bp,dx		;abs(bp) > abs(dx)?
		jbe	LClipDivError	;no ->

		pop	bp
		pop	dx

		ret

LClipDivError:	mov	sp,ClipRecover	;recover the stack

		jmp	ClipEndFail

LineClipCheck	ENDP

;----------------------------------------------------------------------------

;* LineClipAbove - above line clip
;*
;* pass: si = end a index
;*       di = end b index
;* ret : al = outcode 0000ABRL - active high
;*       bp = x clipped
;*       dx = y clipped
;*       zf = 1 (z)  = visible
;*       zf = 0 (nz) = non-visible
;* kill: ax, bx, cx, flags (except zf)
;*
;* Clip equations:-
;*
;*    YC = CLIPA
;*
;*    DX = XB - XA
;*    DY = YB - YA
;*
;*    SELECT abs(DX)
;*    CASE < abs(DY)
;*       XC = XA + DX * (CLIPA - YA) / DY
;*    CASE > abs(DY)
;*       XC = XA + (CLIPA - YA) / (DY / DX)
;*    CASE = abs(DY)
;*       XC = XA + (CLIPA - YA) * sign(slope)
;*    END SELECT

LClipAboveFail	LABEL	NEAR		;<<<<< ERROR HANDLE <<<<<

		mov	sp,ClipRecover	;recover the stack

		jmp	ClipEndFail

LineClipAbove	PROC	NEAR

		mov	cx,Xe[di]	;DX
		sub	cx,Xe[si]
		jo	LClipAboveFail	;>>>>> ERROR >>>>>

		mov	bx,Ye[di]	;DY
		sub	bx,Ye[si]
		jo	LClipAboveFail	;>>>>> ERROR >>>>>

		mov	ax,bx
		ABSV	ax   		;abs(DY)
		mov	bp,ax

		mov	ax,cx
		ABSV	ax		;abs(DX)

		cmp	ax,bp		;select abs(DX)
		je	LClipA_EQ	;case = abs(DY) ->
		ja	LClipA_GT	;case > abs(DY) ->

;* case abs(DX) < abs(DY)

LClipA_LT:	mov	ax,CLIPA
		sub	ax,Ye[si]	;CLIPA - YA
		jo	LClipAboveFail	;>>>>> ERROR >>>>>

		imul	cx		;DX * (CLIPA - YA)

		idiv	bx		;DX * (CLIPA - YA) / DY

		jmp	LClipACont

;* case abs(DX) > abs(DY)

LClipA_GT:	mov	dx,bx

		xor	ax,ax
		sar	dx,1
		rcr	ax,1

		idiv	cx		;DY / DX

		mov	bp,ax

		mov	dx,CLIPA
		sub	dx,Ye[si]	;CLIPA - YA
		jo	LClipAboveFail	;>>>>> ERROR >>>>>

		call	LineClipCheck
		
		xor	ax,ax
		sar	dx,1
		rcr	ax,1

		idiv	bp		;(CLIPA - YA) / (DY / DX)

		jmp	LClipACont

;* case abs(DX) = abs(DY)

LClipA_EQ:	mov	ax,cx
		xor	ax,bx
		cwd			;dx = sign(slope)

		mov	ax,CLIPA
		sub	ax,Ye[si]	;CLIPA - YA
		jo	LClipAboveFail	;>>>>> ERROR >>>>>

		xor	ax,dx
		sub	ax,dx

LClipACont:	add	ax,Xe[si]
		mov	bp,ax

		mov	dx,CLIPA

		OCODE	bp,dx

		ret

LineClipAbove	ENDP

;----------------------------------------------------------------------------

;* LineClipBelow - below line clip
;*
;* pass: si = end a index
;*       di = end b index
;* ret : al = outcode 0000ABRL - active high
;*       bp = x clipped
;*       dx = y clipped
;*       zf = 1 (z)  = visible
;*       zf = 0 (nz) = non-visible
;* kill: ax, bx, cx, flags (except zf)
;*
;* Clip equations:-
;*
;*    YC = CLIPB
;*
;*    DX = XB - XA
;*    DY = YB - YA
;*
;*    SELECT abs(DX)
;*    CASE < abs(DY)
;*       XC = XA + DX * (CLIPB - YA) / DY
;*    CASE > abs(DY)
;*       XC = XA + (CLIPB - YA) / (DY / DX)
;*    CASE = abs(DY)
;*       XC = XA + (CLIPB - YA) * sign(slope)
;*    END SELECT

LClipBelowFail	LABEL	NEAR		;<<<<< ERROR HANDLE <<<<<

		mov	sp,ClipRecover	;recover the stack

		jmp	ClipEndFail

LineClipBelow	PROC	NEAR

		mov	cx,Xe[di]	;DX
		sub	cx,Xe[si]
		jo	LClipBelowFail	;>>>>> ERROR >>>>>

		mov	bx,Ye[di]	;DY
		sub	bx,Ye[si]
		jo	LClipBelowFail	;>>>>> ERROR >>>>>

		mov	ax,bx
		ABSV	ax   		;abs(DY)
		mov	bp,ax

		mov	ax,cx
		ABSV	ax		;abs(DX)

		cmp	ax,bp		;select abs(DX)
		je	LClipB_EQ	;case = abs(DY) ->
		ja	LClipB_GT	;case > abs(DY) ->

;* case abs(DX) < abs(DY)

LClipB_LT:	mov	ax,CLIPB
		sub	ax,Ye[si]	;CLIPB - YA
		jo	LClipBelowFail	;>>>>> ERROR >>>>>

		imul	cx		;DX * (CLIPB - YA)

		idiv	bx		;DX * (CLIPB - YA) / DY

		jmp	LClipBCont

;* case abs(DX) > abs(DY)

LClipB_GT:	mov	dx,bx

		xor	ax,ax
		sar	dx,1
		rcr	ax,1

		idiv	cx		;DY / DX

		mov	bp,ax

		mov	dx,CLIPB
		sub	dx,Ye[si]	;CLIPB - YA
		jo	LClipBelowFail	;>>>>> ERROR >>>>>

		call	LineClipCheck
		
		xor	ax,ax
		sar	dx,1
		rcr	ax,1

		idiv	bp		;(CLIPB - YA) / (DY / DX)

		jmp	LClipBCont

;* case abs(DX) = abs(DY)

LClipB_EQ:	mov	ax,cx
		xor	ax,bx
		cwd			;dx = sign(slope)

		mov	ax,CLIPB
		sub	ax,Ye[si]	;CLIPB - YA
		jo	LClipBelowFail	;>>>>> ERROR >>>>>

		xor	ax,dx
		sub	ax,dx

LClipBCont:	add	ax,Xe[si]
		mov	bp,ax

		mov	dx,CLIPB

		OCODE	bp,dx

		ret

LineClipBelow	ENDP

;----------------------------------------------------------------------------

;* LineClipRight - right line clip
;*
;* pass: si = end a index
;*       di = end b index
;* ret : al = outcode 0000ABRL - active high
;*       bp = x clipped
;*       dx = y clipped
;*       zf = 1 (z)  = visible
;*       zf = 0 (nz) = non-visible
;* kill: ax, bx, cx, flags (except zf)
;*
;* Clip equations:-
;*
;*    XC = CLIPR
;*
;*    DX = XB - XA
;*    DY = YB - YA
;*
;*    SELECT abs(DY)
;*    CASE < abs(DX)
;*       YC = YA + DY * (CLIPR - XA) / DX
;*    CASE > abs(DX)
;*       YC = YA + (CLIPR - XA) / (DX / DY)
;*    CASE = abs(DX)
;*       YC = YA + (CLIPR - XA) * sign(slope)
;*    END SELECT

LClipRightFail	LABEL	NEAR		;<<<<< ERROR HANDLE <<<<<

		mov	sp,ClipRecover	;recover the stack

		jmp	ClipEndFail

LineClipRight	PROC	NEAR

		mov	cx,Xe[di]	;DX
		sub	cx,Xe[si]
		jo	LClipRightFail	;>>>>> ERROR >>>>>

		mov	bx,Ye[di]	;DY
		sub	bx,Ye[si]
		jo	LClipRightFail	;>>>>> ERROR >>>>>

		mov	ax,cx
		ABSV	ax		;abs(DX)
		mov	bp,ax

		mov	ax,bx
		ABSV	ax   		;abs(DY)

		cmp	ax,bp		;select abs(DY)
		je	LClipR_EQ	;case = abs(DX) ->
		ja	LClipR_GT	;case > abs(DX) ->

;* case abs(DY) < abs(DX)

LClipR_LT:	mov	ax,CLIPR
		sub	ax,Xe[si]	;CLIPR - XA
		jo	LClipRightFail	;>>>>> ERROR >>>>>

		imul	bx		;DY * (CLIPR - XA)

		idiv	cx		;DY * (CLIPR - XA) / DX

		jmp	LClipRCont

;* case abs(DY) > abs(DX)

LClipR_GT:	mov	dx,cx

		xor	ax,ax
		sar	dx,1
		rcr	ax,1

		idiv	bx		;DX / DY

		mov	bp,ax

		mov	dx,CLIPR
		sub	dx,Xe[si]	;CLIPR - XA
		jo	LClipRightFail	;>>>>> ERROR >>>>>

		call	LineClipCheck
		
		xor	ax,ax
		sar	dx,1
		rcr	ax,1

		idiv	bp		;(CLIPR - XA) / (DX / DY)

		jmp	LClipRCont

;* case abs(DY) = abs(DX)

LClipR_EQ:	mov	ax,cx
		xor	ax,bx
		cwd			;dx = sign(slope)

		mov	ax,CLIPR
		sub	ax,Xe[si]	;CLIPR - XA
		jo	LClipRightFail	;>>>>> ERROR >>>>>

		xor	ax,dx
		sub	ax,dx

LClipRCont:	add	ax,Ye[si]
		mov	dx,ax

		mov	bp,CLIPR

		OCODE	bp,dx

		ret

LineClipRight	ENDP

;----------------------------------------------------------------------------

;* LineClipLeft - left polygon clip
;*
;* pass: si = end a index
;*       di = end b index
;* ret : al = outcode 0000ABRL - active high
;*       bp = x clipped
;*       dx = y clipped
;*       zf = 1 (z)  = visible
;*       zf = 0 (nz) = non-visible
;* kill: ax, bx, cx, flags (except zf)
;*
;* Clip equations:-
;*
;*    XC = CLIPL
;*
;*    DX = XB - XA
;*    DY = YB - YA
;*
;*    SELECT abs(DY)
;*    CASE < abs(DX)
;*       YC = YA + DY * (CLIPL - XA) / DX
;*    CASE > abs(DX)
;*       YC = YA + (CLIPL - XA) / (DX / DY)
;*    CASE = abs(DX)
;*       YC = YA + (CLIPL - XA) * sign(slope)
;*    END SELECT

LClipLeftFail	LABEL	NEAR		;<<<<< ERROR HANDLE <<<<<

		mov	sp,ClipRecover	;recover the stack

		jmp	ClipEndFail

LineClipLeft	PROC	NEAR

		mov	cx,Xe[di]	;DX
		sub	cx,Xe[si]
		jo	LClipLeftFail	;>>>>> ERROR >>>>>

		mov	bx,Ye[di]	;DY
		sub	bx,Ye[si]
		jo	LClipLeftFail	;>>>>> ERROR >>>>>

		mov	ax,cx
		ABSV	ax		;abs(DX)
		mov	bp,ax

		mov	ax,bx
		ABSV	ax   		;abs(DY)

		cmp	ax,bp		;select abs(DY)
		je	LClipL_EQ	;case = abs(DX) ->
		ja	LClipL_GT	;case > abs(DX) ->

;* case abs(DY) < abs(DX)

LClipL_LT:	mov	ax,CLIPL
		sub	ax,Xe[si]	;CLIPL - XA
		jo	LClipLeftFail	;>>>>> ERROR >>>>>

		imul	bx		;DY * (CLIPL - XA)

		idiv	cx		;DY * (CLIPL - XA) / DX

		jmp	LClipLCont

;* case abs(DY) > abs(DX)

LClipL_GT:	mov	dx,cx

		xor	ax,ax
		sar	dx,1
		rcr	ax,1

		idiv	bx		;DX / DY

		mov	bp,ax

		mov	dx,CLIPL
		sub	dx,Xe[si]	;CLIPL - XA
		jo	LClipLeftFail	;>>>>> ERROR >>>>>

		call	LineClipCheck
		
		xor	ax,ax
		sar	dx,1
		rcr	ax,1

		idiv	bp		;(CLIPL - XA) / (DX / DY)

		jmp	LClipLCont

;* case abs(DY) = abs(DX)

LClipL_EQ:	mov	ax,cx
		xor	ax,bx
		cwd			;dx = sign(slope)

		mov	ax,CLIPL
		sub	ax,Xe[si]	;CLIPL - XA
		jo	LClipLeftFail	;>>>>> ERROR >>>>>

		xor	ax,dx
		sub	ax,dx

LClipLCont:	add	ax,Ye[si]
		mov	dx,ax

		mov	bp,CLIPL

		OCODE	bp,dx

		ret

LineClipLeft	ENDP

;----------------------------------------------------------------------------

;* VPolyLineClip - draw clipped lines (wrt ObjectDrawMode)
;*
;* pass: si -> line data
;*       ie. [si+0] = vertex index
;*             ..   =   ..    ..
;*           [si+n] =   ..    ..
;*           [si+m] = -1 (list terminator)
;*       di -> crt buffer position
;* ret : si -> next face data
;*       di -> next crt buffer position
;*	 cf = 0 = visible
;*       cf = 1 = non-visible or error (do not draw line)
;* kill: ax, bx, cx, dx, bp, flags

VPolyLineClip	PROC	FAR

		mov	bx,ObjectDrawMode
		jmp	PLineClipMode[bx]

VPolyLineClip	ENDP

;----------------------------------------------------------------------------

;* DrawPolyLine - draw lines (no clipping required)
;*
;* pass: )
;* ret : ) Refer to PolyLineClip
;* kill: )
;*
;* note: All x crt and y crt values have been pre-calculated in CalcOutCodes
;*       and stored in the crt arrays XCrt[] and YCrt[].

DrawPolyLine	PROC	NEAR

		mov	bp,di		;store crt buffer ptr

		xor	bx,bx

		lodsb			;fetch first vertex index
		cmp	al,-1		;end of list?
		je	DrawPLineExit	;yes ->

		mov	bl,al

		mov	cx,XCrt[bx]	;cx = x1
		mov	dl,YCrt[bx]	;dl = y1

DrawPLineLoop:	lodsb			;fetch next vertex index
		cmp	al,-1		;end of list?
		je	DrawPLineExit	;yes ->

		mov	bl,al

		mov	ax,XCrt[bx]	;ax = x2
		mov	dh,YCrt[bx]	;dh = y2

		xchg	ax,cx		;x1 = x2
		stosw			;store x1
		mov	ax,cx
		stosw			;store x2
		mov	ax,dx
		stosw			;store y1, y2
		xchg	dl,dh		;y1 = y2
		
		jmp	DrawPLineLoop

DrawPLineExit:	cmp	di,bp		;any points?
		je	DrawPLineFail	;no ->

		mov	ax,-1
		stosw			;store terminator

		clc			;cf = 0 = visible
		retf			;<<<<< MUST BE FAR <<<<<

DrawPLineFail:	stc			;cf = 1 = non-visible or error
		retf			;<<<<< MUST BE FAR <<<<<

DrawPolyLine	ENDP

;----------------------------------------------------------------------------

;* ClipPolyLine - draw clipped lines
;*
;* pass: )
;* ret : ) Refer to PolyLineClip
;* kill: )

ClipPLineExit	LABEL	NEAR

		mov	ax,TempPtr2
		cmp	ax,TempPtr1	;any points?
		je	ClipPLineFail	;no ->

		mov	di,ax
		mov	ax,-1
		stosw			;store terminator

		clc			;cf = 0 = visible
		retf			;<<<<< MUST BE FAR <<<<<

ClipPLineFail:	stc			;cf = 1 = non-visible or error
		retf			;<<<<< MUST BE FAR <<<<<

ClipPolyLine	PROC	NEAR

		mov	ax,di
		mov	TempPtr1,ax
		mov	TempPtr2,ax

		lodsb			;fetch first vertex index
		cmp	al,-1		;end of list?
		je	ClipPLineExit	;yes ->

		xor	ah,ah
		mov	bx,ax		;bx = end a index
		mov	al,OutCode[bx]	;fetch end a outcode
		test	al,al		;end a visible?
		jnz	ClipPLineLoop	;no ->

		mov	ax,Xe[bx]
		mov	dx,Ye[bx]
		mov	cl,VP.V_SCALE_DN
		CRTXY	ax,dx		;calc end a crt co-ords
		mov	XCrt[bx],ax
		mov	YCrt[bx],dl

ClipPLineLoop:	lodsb			;fetch next vertex index
		cmp	al,-1		;end of list?
		je	ClipPLineExit	;yes ->

		xor	ah,ah
		mov	di,ax		;di = end b index
		mov	al,OutCode[di]	;fetch end b outcode
		test	al,al		;end b visible?
		jnz	PLineVisTest	;no ->

		mov	ax,Xe[di]
		mov	dx,Ye[di]
		mov	cl,VP.V_SCALE_DN
		CRTXY	ax,dx		;calc end b crt co-ords
		mov	XCrt[di],ax
		mov	YCrt[di],dl

PLineVisTest:	mov	TempPtr3,si

		mov	si,bx		;si = end a index

		mov	dl,OutCode[si]	;dl = end a outcode
		mov	dh,OutCode[di]	;dh = end b outcode

		test	dl,dh		;line totally non-visible?
		jz	@F
		jmp	PLineNonVis	;yes ->

@@:		mov	al,dl
		or	al,dh	    	;line totally visible?
		jnz	@F
		jmp	ClipPLineDraw	;yes ->

@@:		test	dl,dl		;end a requires clipping?
		jz	ClipPLineEndB	;no, must be end b ->

		call	ClipLineEnd	;clip end a
		jnc	@F
		jmp	PLineNonVis	;end a non-visible ->
@@:		mov	cl,VP.V_SCALE_DN
		CRTXY	bp,dx		;calc end a crt co-ords
		mov	XCrt[si],bp
		mov	YCrt[si],dl

		mov	al,OutCode[di]
		test	al,al		;end b requires cliping?
		jz	ClipPLineDraw	;no ->

ClipPLineEndB:	xchg	si,di
		call	ClipLineEnd	;clip end b
		xchg	si,di
		jc	PLineNonVis	;end b non-visible ->
		mov	cl,VP.V_SCALE_DN
		CRTXY	bp,dx		;calc end b crt co-ords
		mov	XCrt[di],bp
		mov	YCrt[di],dl

ClipPLineDraw:	mov	bx,di		;bx = new end a index

		mov	di,TempPtr2
		mov	ax,XCrt[si]
		stosw
		mov	ax,XCrt[bx]
		stosw
		mov	al,YCrt[si]
		mov	ah,YCrt[bx]
		stosw
		mov	TempPtr2,di

		mov	si,TempPtr3
		jmp	ClipPLineLoop

PLineNonVis:	mov	bx,di		;bx = new end a index
		mov	si,TempPtr3
		jmp	ClipPLineLoop

ClipPolyLine	ENDP

;----------------------------------------------------------------------------

;* NullPolyLine - null draw lines routine
;*
;* pass: )
;* ret : ) Refer to PolyLineClip
;* kill: )

NullPolyLine	PROC	NEAR

NullPLineLoop:	lodsb			;move pointer past line data
		cmp	al,-1
		jne	NullPLineLoop

		stc			;cf = 1 = error
		retf			;<<<<< MUST BE FAR <<<<<

NullPolyLine	ENDP

;----------------------------------------------------------------------------

;* VQuickLineClip - clip a single line and calc crt co-ords (if visible)
;*
;* pass: Xe[0], Ye[0] = end a co-ords
;*       Xe[2], Ye[2] = end b co-ords
;* ret : cf = 0 = visible: XCrt[0], YCrt[0] = end a crt co-ords
;*                         XCrt[2], YCrt[2] = end b crt co-ords
;*       cf = 1 = non-visible or error
;* kill: assume all

VQuickLineClip	PROC	FAR

		mov	si,0		;end a index

		mov	cl,VP.V_SCALE_UP

		call	VTransform

		OCODE	di,bp	 	;calculate outcode

		mov	OutCode[si],al	;store outcode

		mov	si,2		;end b index

		call	VTransform

		OCODE	di,bp	 	;calculate outcode

		mov	OutCode[si],al	;store outcode

		mov	si,0		;end a index
		mov	di,2		;end b index

;* test line visibility

		mov	ah,OutCode[si]

		test	al,ah		;both ends on same side of viewport?
		jz	@F
		jmp	QLineClipFail	;yes, non-visible ->

;* test end a visibility, clip and calc crt co-ords

@@:		test	ah,ah		;end a visible?
		jnz	ClipEndA	;no ->

		mov	bp,Xe[si]
		mov	dx,Ye[si]
		jmp	CalcEndACrt

ClipEndA:	call	ClipLineEnd
		jnc	CalcEndACrt
		jmp	QLineClipFail	;non-visible ->
		
CalcEndACrt: 	mov	cl,VP.V_SCALE_DN

		CRTXY	bp,dx

		mov	XCrt[si],bp
		mov	WORD PTR YCrt[si],dx

;* test end b visibility, clip and calc crt co-ords

		xchg	si,di

		mov	al,OutCode[si]

		test	al,al		;end b visible?
		jnz	ClipEndB	;no ->

		mov	bp,Xe[si]
		mov	dx,Ye[si]
		jmp	CalcEndBCrt

ClipEndB:	call	ClipLineEnd
		jc	QLineClipFail	;non-visible ->
		
CalcEndBCrt:	mov	cl,VP.V_SCALE_DN

		CRTXY	bp,dx

		mov	XCrt[si],bp
		mov	WORD PTR YCrt[si],dx

		clc			;cf = 0 = visible
		ret

QLineClipFail:	stc			;cf = 1 = non-visible or error
		ret

VQuickLineClip	ENDP

;----------------------------------------------------------------------------

;* VDotClip - clip single point and generate crt co-ords if visible
;*
;* pass: Xe[0], Ye[0] = vertex
;* ret : cf = 0 = visible: cx = x crt
;*                         bx = y crt (bh = 0)
;*       cf = 1 = non-visible or error
;* kill: assume all (except cf)

VDotClip       	PROC	FAR

		xor	si,si		;index = 0

		mov	cl,VP.V_SCALE_UP

		call	VTransform	;scale and rotate

		OCODE	di,bp	 	;calculate outcode
		jnz	DotClipFail	;non-visible ->

		mov	cl,VP.V_SCALE_DN

   		CRTXY	di,bp

		mov	cx,di
		mov	bx,bp

		clc			;cf = 0 = visible
		ret

DotClipFail:	stc			;cf = 1 = non-visible or error
		ret

VDotClip	ENDP

VISCODE		ENDS

;============================================================================

		END

