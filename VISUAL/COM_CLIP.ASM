;****************************************************************************
;*
;* COM_CLIP.ASM
;*
;* Common clip driver routines.
;*
;* 21.11.1990 - KJB
;* 14.07.1992 - KJB - PolyDotClip added.
;* 09.11.1992 - KJB - XDotClip added.
;* 26.11.1992 - KJB - Circle clip parameters initialized wrt view mode.
;* 29.11.1992 - KJB - CalcCircleCRT added.
;* 03.01.1993 - KJB - XCalcUnclipCRT added.
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	SetViewMode
		PUBLIC	XDotClip
		PUBLIC	XCalcUnclipCRT

		PUBLIC	CalcOutCodes
		PUBLIC	QuickOutCodes
		PUBLIC	ScaleVPyramid
		PUBLIC	CalcCrt
		PUBLIC	PolyClip
		PUBLIC	PolyLineClip
		PUBLIC	PolyDotClip
		PUBLIC	QuickLineClip
		PUBLIC	HorizonClip
		PUBLIC	DotClip
		PUBLIC	CyclicCheck
		PUBLIC	CalcCircleCRT

		PUBLIC	ClipWndwXOrg
		PUBLIC	ClipWndwYOrg
		PUBLIC	ClipWndwXMax
		PUBLIC	ClipWndwYMax
		PUBLIC	ClipWndwWidth
		PUBLIC	ClipWndwDepth
		PUBLIC	ClipWndwSize
		PUBLIC	ClipBuffer
		PUBLIC	ClipRecover

		EXTRN	INT_ScaleVP:NEAR
		EXTRN	ALT_ScaleVP:NEAR
		EXTRN	EXT_ScaleVP:NEAR
		EXTRN	TV1_ScaleVP:NEAR
		EXTRN	TV2_ScaleVP:NEAR
		EXTRN	TV3_ScaleVP:NEAR
		EXTRN	TV4_ScaleVP:NEAR
		EXTRN	TV5_ScaleVP:NEAR
		EXTRN	INT_CalcCRT:NEAR
		EXTRN	ALT_CalcCRT:NEAR
		EXTRN	EXT_CalcCRT:NEAR
		EXTRN	TV1_CalcCRT:NEAR
		EXTRN	TV2_CalcCRT:NEAR
		EXTRN	TV3_CalcCRT:NEAR
		EXTRN	TV4_CalcCRT:NEAR
		EXTRN	TV5_CalcCRT:NEAR
		EXTRN	INT_CircleCRT:NEAR
		EXTRN	ALT_CircleCRT:NEAR
		EXTRN	EXT_CircleCRT:NEAR
		EXTRN	TV1_CircleCRT:NEAR
		EXTRN	TV2_CircleCRT:NEAR
		EXTRN	TV3_CircleCRT:NEAR
		EXTRN	TV4_CircleCRT:NEAR
		EXTRN	TV5_CircleCRT:NEAR

		EXTRN	ViewMode:WORD
		EXTRN	CircleXMin:WORD
		EXTRN	CircleXMax:WORD
		EXTRN	CircleYMin:WORD
		EXTRN	CircleYMax:WORD

		EXTRN	INT_WIDTH:ABS
		EXTRN	INT_DEPTH:ABS
		EXTRN	ALT_WIDTH:ABS
		EXTRN	ALT_DEPTH:ABS
		EXTRN	EXT_WIDTH:ABS
		EXTRN	EXT_DEPTH:ABS
		EXTRN	TV1_WIDTH:ABS
		EXTRN	TV1_DEPTH:ABS
		EXTRN	TV2_WIDTH:ABS
		EXTRN	TV2_DEPTH:ABS
		EXTRN	TV3_WIDTH:ABS
		EXTRN	TV3_DEPTH:ABS
		EXTRN	TV4_WIDTH:ABS
		EXTRN	TV4_DEPTH:ABS
		EXTRN	TV5_WIDTH:ABS
		EXTRN	TV5_DEPTH:ABS

;============================================================================

		INCLUDE	VISEXTRN.INC
		INCLUDE	\LIB8086\USEFUL.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

;-----------------
;* clipping window
;-----------------

;* clip window origin (default (0, 0), but TV?_VIEWMODEs require variable origin)

ClipWndwXOrg	DW	0		;x origin of clip window
ClipWndwYOrg	DB	0,0		;y origin of clip window

;* clip window x max, y max

ClipWndwXMax	DW	0	    	;x max = x org + width - 1
ClipWndwYMax	DB	0,0		;y max = y org + depth - 1

;* clipping window width, depth (wrt view mode)

ClipWndwWidth	DW	0
ClipWndwDepth	DW	0

;* clipping window width, depth table

ClipWndwSize	DW	INT_WIDTH, INT_DEPTH	;INT_VIEWMODE
		DW	ALT_WIDTH, ALT_DEPTH	;ALT_VIEWMODE
		DW	EXT_WIDTH, EXT_DEPTH	;EXT_VIEWMODE
		DW	TV1_WIDTH, TV1_DEPTH	;TV1_VIEWMODE
		DW	TV2_WIDTH, TV2_DEPTH	;TV2_VIEWMODE
		DW	TV3_WIDTH, TV3_DEPTH	;TV3_VIEWMODE
		DW	TV4_WIDTH, TV4_DEPTH	;TV4_VIEWMODE
		DW	TV5_WIDTH, TV5_DEPTH	;TV5_VIEWMODE

;* variable clipping window origin flag (wrt view mode), 1 = variable origin

VarClipOrg	DB	0		;INT_VIEWMODE
		DB	0		;ALT_VIEWMODE
		DB	0		;EXT_VIEWMODE
		DB	1		;TV1_VIEWMODE
		DB	1		;TV2_VIEWMODE
		DB	1		;TV3_VIEWMODE
		DB	1		;TV4_VIEWMODE
		DB	1		;TV5_VIEWMODE

		EVEN

;* indirection pointers for clip routines

_ScaleVPyramid	DW	0

		DW	INT_ScaleVP	;INT_VIEWMODE
		DW	ALT_ScaleVP	;ALT_VIEWMODE
		DW	EXT_ScaleVP	;EXT_VIEWMODE
		DW	TV1_ScaleVP	;TV1_VIEWMODE
		DW	TV2_ScaleVP	;TV2_VIEWMODE
		DW	TV3_ScaleVP	;TV3_VIEWMODE
		DW	TV4_ScaleVP	;TV4_VIEWMODE
		DW	TV5_ScaleVP	;TV5_VIEWMODE

_CalcCRT	DW	0

		DW	INT_CalcCRT	;INT_VIEWMODE
		DW	ALT_CalcCRT	;ALT_VIEWMODE
		DW	EXT_CalcCRT	;EXT_VIEWMODE
		DW	TV1_CalcCRT	;TV1_VIEWMODE
		DW	TV2_CalcCRT	;TV2_VIEWMODE
		DW	TV3_CalcCRT	;TV3_VIEWMODE
		DW	TV4_CalcCRT	;TV4_VIEWMODE
		DW	TV5_CalcCRT	;TV5_VIEWMODE

_CircleCRT	DW	0

		DW	INT_CircleCRT	;INT_VIEWMODE
		DW	ALT_CircleCRT	;ALT_VIEWMODE
		DW	EXT_CircleCRT	;EXT_VIEWMODE
		DW	TV1_CircleCRT	;TV1_VIEWMODE
		DW	TV2_CircleCRT	;TV2_VIEWMODE
		DW	TV3_CircleCRT	;TV3_VIEWMODE
		DW	TV4_CircleCRT	;TV4_VIEWMODE
		DW	TV5_CircleCRT	;TV5_VIEWMODE

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

PDotClipMode	DW	DrawPolyDots	;DRAW_OBJECT
		DW	ClipPolyDots	;CLIP_OBJECT
		DW	NullPolyDots	;SKIP_OBJECT

CyclicMode	DW	FastCyclic	;DRAW_OBJECT
		DW	SlowCyclic	;CLIP_OBJECT
		DW	NullCyclic	;SKIP_OBJECT

;-----------
;* poly clip
;-----------

ClipBuffer	DW	512 DUP(0)

LastPtr		DW	0

LookAhead	DB	0,0

IntoPolyClip	DW	IntoBehindClip
		DW	IntoLeftClip
		DW	IntoRightClip
		DW	IntoBelowClip
		DW	IntoAboveClip
		DW	SortPolyCrt

XA		EQU	0
YA		EQU	2
ZA		EQU	4

XB		EQU	-8
YB		EQU	-6
ZB		EQU	-4

XC		EQU	0
YC		EQU	2
ZC		EQU	4

;-----------
;* line clip
;-----------

XEndA		DW	0
YEndA		DW	0
ZEndA		DW	0

OCodeEndA	DB	0,0

XEndB		DW	0
YEndB		DW	0
ZEndB		DW	0

XEndC		DW	0
YEndC		DW	0
ZEndC		DW	0

;---------------
;* miscellaneous
;---------------

ClipRecover	DW	0

TempPtr1 	DW	0
TempPtr2 	DW	0
TempPtr3 	DW	0

DATA		ENDS

;============================================================================

VISCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:VISCODE
		ASSUME DS:DATA

;* SCALE_V_PYRAMID - a faster way to call ScaleVPyramid (use in COM_CLIP only)
;*
;* pass: )
;* ret : ) Refer to ScaleVPyramid.
;* kill: )

SCALE_V_PYRAMID	MACRO
		mov	bp,_ScaleVPyramid
		call	bp
		ENDM

;----------------------------------------------------------------------------

;* CALC_CRT - a faster way to call CalcCRT (use in COM_CLIP only)
;*
;* pass: )
;* ret : ) Refer to CalcCRT.
;* kill: )

CALC_CRT	MACRO
		mov	bp,_CalcCRT
		call	bp
		ENDM

;----------------------------------------------------------------------------

;* CIRCLE_CRT - a faster way to call CircleCRT (use in COM_CLIP only)
;*
;* pass: )
;* ret : ) Refer to CircleCRT.
;* kill: )

CIRCLE_CRT	MACRO
		mov	bp,_CircleCRT
		call	bp
		ENDM

;----------------------------------------------------------------------------

;* SetViewMode - initialize view mode
;*
;* pass: ax = view mode
;*       bl = y pos (if TV?_VIEWMODE requested)
;*       cx = x pos (if TV?_VIEWMODE requested)
;* ret : nothing
;* kill: assume all
;*
;* note: SetViewMode MUST be called at the start of your program in order to
;*       initialize the clip variables - there is no default condition.

SetViewMode	PROC	FAR

		mov	ViewMode,ax

		mov	si,ax
		shr	si,1		;/2 byte index
		test	VarClipOrg[si],1;variable origin?
		jnz	@F		;yes ->

		xor	cx,cx		;set default origin
		xor	bl,bl

@@:		mov	ClipWndwXOrg,cx	;only valid if TV?_VIEWMODE
		mov	ClipWndwYOrg,bl	;only valid if TV?_VIEWMODE

		mov	CircleXMin,cx
		mov	BYTE PTR CircleYMin,bl

		mov	si,ax
		shl	si,1		;*2 index

		mov	ax,ClipWndwSize[si]

		mov	ClipWndwWidth,ax

		add	cx,ax
		dec	cx
		mov	ClipWndwXMax,cx
		mov	CircleXMax,cx

		mov	al,BYTE PTR ClipWndwSize[si+2]

		mov	BYTE PTR ClipWndwDepth,al

		add	bl,al
		dec	bl
		mov	ClipWndwYMax,bl
		mov	BYTE PTR CircleYMax,bl

		shr	si,1		;/2 index

;* set up indirection pointers for clip routines

		mov	ax,_ScaleVPyramid[si+2]
		mov	_ScaleVPyramid,ax

		mov	ax,_CalcCRT[si+2]
		mov	_CalcCRT,ax

		mov	ax,_CircleCRT[si+2]
		mov	_CircleCRT,ax

		ret

SetViewMode	ENDP

;----------------------------------------------------------------------------

;* CalcOutCodes - calculate outcodes
;*
;* pass: si indexes last vertex in Xe[], Ye[] and Ze[] arrays
;* ret : ax = ObjectDrawMode
;*       cf = 0: object visible
;*       cf = 1: object non-visible
;*       XCrt[] = x crt co-ords if DRAW_OBJECT mode
;*       YCrt[] = y crt co-ords if DRAW_OBJECT mode
;* kill: assume all (except cf)
;*
;* note: If crt co-ords are generated (DRAW_OBJECT mode) then any crt error
;*       values (x = -1, y = -1) are stored in the crt arrays. The object
;*       drawing routines MUST check for these error values and handle them
;*       as necessary.

CalcOutCodes	PROC	NEAR

		mov	di,si 		;store last vertex index

;* dl = object non-visible test mask, dh = object totally visible test mask

		mov	dx,000ffh

OCodeLoop:	mov	ax,Xe[si]	;fetch eye co-ords
		mov	bx,Ye[si]
		mov	cx,Ze[si]

		SCALE_V_PYRAMID		;scale viewing pyramid wrt view mode

		call	CalcOCode	;calculate outcode

		mov	OutCode[si],al	;store outcode

		and	dl,al		;update non-visible test mask
		or	dh,al		;update totally visible test mask

		sub	si,2		;next eye co-ord
		jnc	OCodeLoop

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

DrawObject:	xor	si,si		;index = 0

GenXYCrtLoop:	mov	ax,Xe[si]
		mov	bx,Ye[si]
		mov	cx,Ze[si]

		CALC_CRT

;* store crt co-ords, even if error (x = -1, y = -1)

		mov	XCrt[si],cx
		mov	WORD PTR YCrt[si],bx

		add	si,2		;next vertex index
		cmp	si,di		;all vertices done?
		jbe	GenXYCrtLoop	;no ->
		
		mov	ax,DRAW_OBJECT
		mov	ObjectDrawMode,ax
		clc			;cf = 0 (object visible)
		ret

CalcOutCodes	ENDP

;----------------------------------------------------------------------------

;* QuickOutCodes - calculate outcodes (for sector culling etc.)
;*
;* pass: si indexes last vertex in Xe[], Ye[] and Ze[] arrays
;* ret : cf = 0: object visible
;*       cf = 1: object non-visible
;* kill: assume all (except cf)

QuickOutCodes	PROC	NEAR

;* dl = object non-visible test mask

		mov	dl,0ffh

QuickOCodeLoop:	mov	ax,Xe[si]	;fetch eye co-ords
		mov	bx,Ye[si]
		mov	cx,Ze[si]

		SCALE_V_PYRAMID		;scale viewing pyramid wrt view mode

		call	CalcOCode	;calculate outcode

		and	dl,al		;update non-visible test mask

		sub	si,2		;next eye co-ord
		jnc	QuickOCodeLoop

		xor	al,al
		sub	al,dl		;cf = 0 = visible, cf = 1 = non-visible

		ret

QuickOutCodes	ENDP

;----------------------------------------------------------------------------

;* CalcOCode - calculate outcode
;*
;* pass: ax = x eye
;*       bx = y eye
;*       cx = z eye (pre-scaled wrt view mode)
;* ret : al = outcode - FRONT : al = 0000ABRL - active high
;*                    - BEHIND: al = 1000BALR - active low
;*       zf = 1 (z)  = visible
;*       zf = 0 (nz) = non-visible
;* kill: ah, bx, cx, bp, flags

CalcOCode	PROC	NEAR

		mov	bp,ax

		cmp	bx,1		;behind?
		jl	YNeg1		;yes ->

;* calculate outcode for point in front

		xor	al,al		;init in front outcode

		test	bp,bp		;x left or right?	
		js	XNeg1		;left ->

		cmp	bp,bx		;x <= y?
		jbe	CheckZY1	;yes ->
		or	al,002h		;set clip right flag
		jmp	CheckZY1

XNeg1:		neg	bp		;abs(x)
		cmp	bp,bx		;x <= y?
		jbe	CheckZY1	;yes ->
		or	al,001h		;set clip left flag 

CheckZY1:	test	cx,cx		;z above or below?
		js	ZNeg1		;below ->		
		
		cmp	cx,bx		;z <= y?
		jbe	CalcOCodeExit	;yes ->
		or	al,008h		;set clip above flag
		jmp	CalcOCodeExit

ZNeg1:		neg	cx		;abs(z)
		cmp	cx,bx		;z <= y?
		jbe	CalcOCodeExit	;yes ->
		or	al,004h		;set clip below flag
		jmp	CalcOCodeExit

;* calculate outcode for point behind

YNeg1:		neg	bx		;abs(y)
		mov	al,08fh		;init behind outcode
		
		test	bp,bp		;x left or right?	
		js	XNeg2		;left ->

		cmp	bp,bx		;x <= y?
		jbe	CheckZY2	;yes ->
		and	al,08eh		;set clip right flag
		jmp	CheckZY2

XNeg2:		neg	bp		;abs(x)
		cmp	bp,bx		;x <= y?
		jbe	CheckZY2	;yes ->
		and	al,08dh		;set clip left flag 

CheckZY2:	test	cx,cx		;z above or below?
		js	ZNeg2		;below ->		
		
		cmp	cx,bx		;z <= y?
		jbe	CalcOCodeExit	;yes ->
		and	al,08bh		;set clip above flag
		jmp	CalcOCodeExit

ZNeg2:		neg	cx		;abs(z)
		cmp	cx,bx		;z <= y?
		jbe	CalcOCodeExit	;yes ->
		and	al,087h		;set clip below flag

CalcOCodeExit:	test	al,al		;zf = 1 = visible
		ret

CalcOCode	ENDP

;----------------------------------------------------------------------------

;* ScaleVPyramid - scale viewing pyramid (wrt ViewMode)
;*
;* pass: cx = z eye
;*       si = Ze[] vertex index
;* ret : cx = Ze[si] = scaled z eye
;* kill: bp, flags

ScaleVPyramid	PROC	NEAR

		mov	bp,_ScaleVPyramid
		jmp	bp

ScaleVPyramid	ENDP

;----------------------------------------------------------------------------

;* CalcCRT - calculate x and y crt values (wrt ViewMode)
;*
;* pass: ax = x eye
;*       bx = y eye
;*       cx = z eye
;* ret : cf = 0 = ok   : bx = y crt
;*                       cx = x crt
;*       cf = 1 = error: bx = -1
;*                       cx = -1
;* kill: ax, dx, bp, flags

CalcCRT		PROC	NEAR

		mov	bp,_CalcCRT
		jmp	bp

CalcCRT		ENDP

;----------------------------------------------------------------------------

;* CirleCRT - calculate x and y crt values (wrt ViewMode)
;*
;* pass: ax = x eye
;*       bx = y eye
;*       cx = z eye
;* ret : cf = 0 = ok   : bx = y crt
;*                       cx = x crt
;*       cf = 1 = error: bx = -1
;*                       cx = -1
;* kill: ax, dx, bp, flags

CircleCRT	PROC	NEAR

		mov	bp,_CircleCRT
		jmp	bp

CircleCRT  	ENDP

;----------------------------------------------------------------------------

;* PolyClip - generate clipped polygon (wrt ObjectDrawMode)
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

PolyClip	PROC	NEAR

		mov	bx,ObjectDrawMode
		jmp	PolyClipMode[bx]

PolyClip	ENDP

;----------------------------------------------------------------------------

;* DrawPoly - draw polygon (no clipping required)
;*
;* pass: )
;* ret : ) Refer to PolyClip
;* kill: )
;*
;* note: All x crt and y crt values have been pre-calculated in CalcOutCodes
;*       and stored in the crt arrays XCrt[] and YCrt[].

DrawPoly	PROC	NEAR

		mov	bp,di		;store crt buffer ptr

		xor	bx,bx

DrawPolyLoop:	lodsb			;fetch vertex index
		cmp	al,-1		;end of list?
		je	SortPolyTerm	;yes ->

		mov	bl,al

		mov	ax,XCrt[bx]
		cmp	ax,-1		;error?
		je	DrawPolyLoop	;yes, skip point ->
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
		ret

DrawPolyFail:	stc			;cf = 1 = non-visible or error
		ret

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

		mov	di,OFFSET ClipBuffer+8

NextPolyCoord:	lodsb			;fetch vertex index
		cmp	al,-1		;end of list?
		je	SortPolyVis	;yes, sort polygon visibility ->

		mov	bl,al
		mov	ax,Xe[bx]
		stosw
		mov	ax,Ye[bx]
		stosw
		mov	ax,Ze[bx]
		stosw
		mov	al,OutCode[bx]
		stosw			;store word for padding

		and	dl,al		;update non-visible test mask
		or	dh,al		;update totally visible test mask

		jmp	NextPolyCoord

;* sort polygon visibility (totally visible, partially visible, non-visible)

SortPolyVis:	push	si		;store ptr to next polygon data

		mov	ClipRecover,sp	;recover stack to here if clip error

		mov	si,OFFSET ClipBuffer+8
		
		test	dl,dl		;polygon non-visible?
		jnz	ClipPolyFailLnk	;yes ->

;* if partially visible then jump to first clip required

		xor	bx,bx		;reset index
		
		rol	dh,1		;outcodes xxxABRLB

		rcr	dh,1		;cf = 1 = behind clip required
		jc	ClipSwitch
		add	bx,2

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

;------------------------
;* clip all points behind
;------------------------

IntoBehindClip:	xor	al,al		;reset look ahead outcode mask
		mov	LookAhead,al

		mov	LastPtr,di

		mov	ax,[di-8]	;move last point in front of first
		mov	[si-8],ax
		mov	ax,[di-6]
		mov	[si-6],ax
		mov	ax,[di-4]
		mov	[si-4],ax
		mov	ax,[di-2]
		mov	[si-2],ax
		mov	dl,al
		and	dl,080h	 	;dl = end b outcode

BehindClipLoop:	mov	dh,[si+6]
		and	dh,080h		;dh = end a outcode	
		mov	al,dh
		xor	al,dl	    	;ends a and b on same side of pyramid?
		jz 	SkipBehindClip	;yes ->
		
		push	dx
		call	PolyClipBehind
		or	LookAhead,al	;update look ahead outcode mask
		stosw			;store outcode of clipped point
		pop 	dx

SkipBehindClip:	test	dh,dh		;end a visible?
		jnz	SkipBehindPoint	;no ->

		mov	cx,3		;store new point if visible
		rep	movsw
		lodsw
		or	LookAhead,al	;update look ahead outcode mask
		stosw
		jmp	NextBehindClip

SkipBehindPoint:add	si,8		;skip point
	
NextBehindClip:	mov	dl,dh
		cmp	si,LastPtr	;all points done?
		jb	BehindClipLoop	;no ->

		cmp	si,di		;any points remaining?
		jne	LeftClipStart	;yes, move on to next clip ->
BehindFail:	jmp	ClipPolyFail

;----------------------
;* clip all points left
;----------------------

LeftClipStart:	mov	al,LookAhead
		test	al,080h		;any rogue points?
		jnz	BehindFail	;yes, clip failed ->
		test	al,001h		;any left clipping required?
		jz	RightClipStart	;no ->

IntoLeftClip:	xor	al,al		;reset look ahead outcode mask
		mov	LookAhead,al

		mov	LastPtr,di

		mov	ax,[di-8]	;move last point in front of first
		mov	[si-8],ax
		mov	ax,[di-6]
		mov	[si-6],ax
		mov	ax,[di-4]
		mov	[si-4],ax
		mov	ax,[di-2]
		mov	[si-2],ax
		mov	dl,al
		and	dl,001h	 	;dl = end b outcode

LeftClipLoop:	mov	dh,[si+6]
		and	dh,001h		;dh = end a outcode	
		mov	al,dh
		xor	al,dl	    	;ends a and b on same side of pyramid?
		jz 	SkipLeftClip	;yes ->
		
		push	dx
		call	PolyClipLeft
		or	LookAhead,al	;update look ahead outcode mask
		stosw			;store outcode of clipped point
		pop 	dx

SkipLeftClip:	test	dh,dh		;end a visible?
		jnz	SkipLeftPoint	;no ->

		mov	cx,3		;store new point if visible
		rep	movsw
		lodsw
		or	LookAhead,al	;update look ahead outcode mask
		stosw
		jmp	NextLeftClip

SkipLeftPoint:	add	si,8		;skip point
	
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
		test	al,081h		;any rogue points?
		jnz	LeftFail	;yes, clip failed ->
		test	al,002h		;any right clipping required?
		jz	BelowClipStart	;no ->

IntoRightClip:	xor	al,al		;reset look ahead outcode mask
		mov	LookAhead,al

		mov	LastPtr,di

		mov	ax,[di-8]	;move last point in front of first
		mov	[si-8],ax
		mov	ax,[di-6]
		mov	[si-6],ax
		mov	ax,[di-4]
		mov	[si-4],ax
		mov	ax,[di-2]
		mov	[si-2],ax
		mov	dl,al
		and	dl,002h	 	;dl = end b outcode

RightClipLoop:	mov	dh,[si+6]
		and	dh,002h		;dh = end a outcode	
		mov	al,dh
		xor	al,dl	    	;ends a and b on same side of pyramid?
		jz 	SkipRightClip	;yes ->
		
		push	dx
		call	PolyClipRight
		or	LookAhead,al	;update look ahead outcode mask
		stosw			;store outcode of clipped point
		pop 	dx

SkipRightClip:	test	dh,dh		;end a visible?
		jnz	SkipRightPoint	;no ->

		mov	cx,3		;store new point if visible
		rep	movsw
		lodsw
		or	LookAhead,al	;update look ahead outcode mask
		stosw
		jmp	NextRightClip

SkipRightPoint:	add	si,8		;skip point
	
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
		test	al,083h		;any rogue points?
		jnz	RightFail	;yes, clip failed ->
		test	al,004h		;any below clipping required?
		jz	AboveClipStart	;no ->

IntoBelowClip:	xor	al,al		;reset look ahead outcode mask
		mov	LookAhead,al

		mov	LastPtr,di

		mov	ax,[di-8]	;move last point in front of first
		mov	[si-8],ax
		mov	ax,[di-6]
		mov	[si-6],ax
		mov	ax,[di-4]
		mov	[si-4],ax
		mov	ax,[di-2]
		mov	[si-2],ax
		mov	dl,al
		and	dl,004h	 	;dl = end b outcode

BelowClipLoop:	mov	dh,[si+6]
		and	dh,004h		;dh = end a outcode	
		mov	al,dh
		xor	al,dl	    	;ends a and b on same side of pyramid?
		jz 	SkipBelowClip	;yes ->
		
		push	dx
		call	PolyClipBelow
		or	LookAhead,al	;update look ahead outcode mask
		stosw			;store outcode of clipped point
		pop 	dx

SkipBelowClip:	test	dh,dh		;end a visible?
		jnz	SkipBelowPoint	;no ->

		mov	cx,3		;store new point if visible
		rep	movsw	
		lodsw
		or	LookAhead,al	;update look ahead outcode mask
		stosw
		jmp	NextBelowClip

SkipBelowPoint:	add	si,8		;skip point
	
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
		test	al,087h		;any rogue points?
		jnz	BelowFail	;yes, clip failed ->
		test	al,008h		;any above clipping required?
		jz	SortPolyCrt	;no ->

IntoAboveClip:	xor	al,al		;reset look ahead outcode mask
		mov	LookAhead,al

		mov	LastPtr,di

		mov	ax,[di-8]	;move last point in front of first
		mov	[si-8],ax
		mov	ax,[di-6]
		mov	[si-6],ax
		mov	ax,[di-4]
		mov	[si-4],ax
		mov	ax,[di-2]
		mov	[si-2],ax
		mov	dl,al
		and	dl,008h	 	;dl = end b outcode

AboveClipLoop:	mov	dh,[si+6]
		and	dh,008h		;dh = end a outcode	
		mov	al,dh
		xor	al,dl	    	;ends a and b on same side of pyramid?
		jz 	SkipAboveClip	;yes ->
		
		push	dx
		call	PolyClipAbove
		or	LookAhead,al	;update look ahead outcode mask
		stosw			;store outcode of clipped point
		pop 	dx

SkipAboveClip:	test	dh,dh		;end a visible?
		jnz	SkipAbovePoint	;no ->

		mov	cx,3		;store new point if visible
		rep	movsw	
		lodsw
		or	LookAhead,al	;update look ahead outcode mask
		stosw
		jmp	NextAboveClip

SkipAbovePoint:	add	si,8		;skip point
	
NextAboveClip:	mov	dl,dh
		cmp	si,LastPtr	;all points done?
		jb	AboveClipLoop	;no ->

		mov	al,LookAhead
		test	al,08fh		;any rogue points?
		jnz	ClipPolyFail	;yes, clip failed ->

;-----------------------------
;* create crt list for polygon
;-----------------------------

SortPolyCrt:	cmp	si,di		;any points remaining?
		je	ClipPolyFail	;no ->

		mov	LastPtr,di

		mov	di,TempPtr1

PolyCrtLoop:	lodsw			;fetch x eye
		mov	bp,ax
		lodsw			;fetch y eye
		mov	bx,ax
		lodsw			;fetch z eye
		mov	cx,ax
		mov	ax,bp
		
		CALC_CRT
		jc	SkipPolyPoint	;crt calc error, skip point ->

		mov	ax,cx
		stosw			;store x crt
		mov	ax,bx
		stosw			;store y crt

SkipPolyPoint:	add	si,2		;skip outcode data

		cmp	si,LastPtr 	;done all points?
		jb	PolyCrtLoop	;no ->

		mov	si,TempPtr1
		movsw			;copy 1st x crt to end
		movsw			;copy 1st y crt to end
		mov	ax,-1
		stosw			;store terminator

		pop	si		;restore ptr to next polygon data
		clc			;cf = 0 = visible
		ret

ClipPolyFail:	pop	si		;restore ptr to next polygon data
		stc			;cf = 1 = non-visible or error
		ret

ClipPoly	ENDP

;----------------------------------------------------------------------------

;* PolyClipCheck - polygon clip divide check
;*
;* pass: dx = numerator
;*       bp = denominator
;* ret : abs(dx)
;*       abs(bp)
;*       zf = 0: t < 1
;*       zf = 1: t = 1
;* kill: ax, flags
;*
;* note: If an error occurs (sign(dx) <> sign(bp) or abs(bp) < abs(dx))
;*       then the program recovers the stack and drops out of ClipPoly.

PolyClipCheck	PROC	NEAR

		mov	ax,dx
		xor	ax,bp		;sign(dx) = sign(bp)?
		js	ClipDivError	;no, error ->

		test	bp,bp		;+ve?
		jns	ClipDivTest	;yes ->

		neg	dx
		neg	bp

ClipDivTest:	cmp	bp,dx		;abs(bp) < abs(dx)?
		jb	ClipDivError	;yes ->

		ret

ClipDivError:	mov	sp,ClipRecover	;recover the stack

		jmp	ClipPolyFail

PolyClipCheck	ENDP

;----------------------------------------------------------------------------

;* PolyClipBehind - behind polygon clip
;*
;* pass: si -> end a and end b data
;*       di -> clipped point store
;* ret : di -> next clipped point store
;* kill: ax, bx, cx, dx, bp, flags
;*
;* note: Returns via CalcOCode.
;*
;* Clip equations:-
;*
;* T = (YA - 1) / (YA - YB)
;* 
;* when T <> 1: XC = T * (XB - XA) + XA
;*              YC = 1
;*              ZC = T * (ZB - ZA) + ZA
;*
;* when T = 1 : XC = XB
;*              YC = 1
;*              ZC = ZB

PolyClipBehind	PROC	NEAR

		mov	cx,XA[si]
		mov	dx,YA[si]

		mov	bx,XB[si]
		mov	ax,YB[si]

		sub	bx,cx		;bx = XB - XA
		mov	bp,dx		;bp = YA
		sub	bp,ax		;bp = YA - YB
		dec	dx  		;dx = YA - 1

		call	PolyClipCheck
		je	PClipBehind1	;T = 1 ->

		xor	ax,ax
		sar	dx,1
		rcr	ax,1
		idiv	bp		;ax = T = (YA - 1) / (YA - YB)

		mov	bp,ax		;bp = T

		imul	bx 		;dx, ax = T * (XB - XA)
		FRACADJ	dx		;dx = T * (XB - XA)
		add 	dx,cx		;dx = T * (XB - XA) + XA
		mov 	XC[di],dx	;XC = T * (XB - XA) + XA

		mov	ax,1
		mov	YC[di],ax	;YC = 1

		mov	cx,ZA[si]
		mov	bx,ZB[si] 		
		
		sub	bx,cx		;bx = ZB - ZA

		mov	ax,bp		;ax = T

		imul	bx		;dx, ax = T * (ZB - ZA)
		FRACADJ	dx		;dx = T * (ZB - ZA)
		add	dx,cx		;dx = T * (ZB - ZA) + ZA
		mov	ZC[di],dx	;ZC = T * (ZB - ZA) + ZA

BehindPClipDone:mov	ax,XC[di]
		mov	bx,YC[di]
		mov	cx,ZC[di]
		add	di,6

		jmp	CalcOCode	;return via CalcOCode

;* T = 1

PClipBehind1:	mov	ax,XB[si]
		mov	XC[di],ax	;XC = XB
		mov	ax,1
		mov	YC[di],ax	;YC = 1
		mov	ax,ZB[si]
		mov	ZC[di],ax	;ZC = ZB

		jmp	BehindPClipDone

PolyClipBehind	ENDP

;----------------------------------------------------------------------------

;* PolyClipAbove - above polygon clip
;*
;* pass: si -> end a and end b data
;*       di -> clipped point store
;* ret : di -> next clipped point store
;* kill: ax, bx, cx, dx, bp, flags
;*
;* note: Returns via CalcOCode.
;* 
;* Clip equations:-
;*
;* T = (YA - ZA) / ((ZB - ZA) - (YB - YA))
;* 
;* when T <> 1: XC = T * (XB - XA) + XA
;*              YC = T * (YB - YA) + YA
;*              ZC = YC
;*
;* when T = 1 : XC = XB
;*              YC = YB
;*              ZC = YC

PolyClipAbove	PROC	NEAR

		mov	dx,YA[si]
		mov	bx,ZA[si]

		mov	ax,YB[si]
		mov	cx,ZB[si]

		sub	dx,bx		;dx = YA - ZA
		mov 	bp,dx		;bp = YA - ZA
		add	bp,cx		;bp = YA - ZA + ZB
		sub	bp,ax		;bp = YA - ZA + ZB - YB = ((ZB - ZA) - (YB - YA))

		call	PolyClipCheck
		je	PClipAbove1	;T = 1 ->

		xor	ax,ax
		sar	dx,1
		rcr	ax,1
		idiv 	bp		;ax = T = (YA - ZA) / ((ZB - ZA) - (YB - YA))
   
		mov	bp,ax		;bp = T

		mov	bx,YA[si]
		mov	cx,YB[si]

		sub	cx,bx		;cx = YB - YA
		imul	cx		;dx, ax = T * (YB - YA)
		FRACADJ	dx		;dx = T * (YB - YA)
		add	dx,bx		;dx = T * (YB - YA) + YA
		mov	YC[di],dx	;YC = T * (YB - YA) + YA
		mov	ZC[di],dx	;ZC = YC

		mov	bx,XA[si]		
		mov	cx,XB[si]

		sub	cx,bx		;cx = XB - XA

		mov	ax,bp		;ax = T

		imul	cx		;dx, ax = T * (XB - XA)
		FRACADJ	dx		;dx = T * (XB - XA)
		add	dx,bx 		;dx = T * (XB - XA) + XA
		mov 	XC[di],dx 	;XC = T * (XB - XA) + XA

AbovePClipDone:	mov	ax,XC[di]
		mov	bx,YC[di]
		mov	cx,ZC[di]
		add	di,6

		jmp	CalcOCode	;return via CalcOCode

;* T = 1

PClipAbove1:	mov 	ax,XB[si]
		mov 	XC[di],ax	;XC = XB
		mov	ax,YB[si]
		mov	YC[di],ax	;YC = YB
		mov	ZC[di],ax	;ZC = YC

		jmp	AbovePClipDone

PolyClipAbove	ENDP

;----------------------------------------------------------------------------

;* PolyClipBelow - below polygon clip
;*
;* pass: si -> end a and end b data
;*       di -> clipped point store
;* ret : di -> next clipped point store
;* kill: ax, bx, cx, dx, bp, flags
;*
;* note: Returns via CalcOCode.
;* 
;* Clip equations:-
;*
;* T = (YA + ZA) / ((ZA - ZB) - (YB - YA))
;* 
;* when T <> 1: XC = T * (XB - XA) + XA
;*              YC = T * (YB - YA) + YA
;*              ZC = -YC
;*
;* when T = 1 : XC = XB
;*              YC = YB
;*              ZC = -YC

PolyClipBelow	PROC	NEAR

		mov	dx,YA[si]
		mov	bx,ZA[si]

		mov	ax,YB[si]
		mov	cx,ZB[si]
		
		add	dx,bx		;dx = YA + ZA
		mov	bp,dx		;bp = YA + ZA
		sub	bp,cx		;bp = YA + ZA - ZB
		sub	bp,ax		;bp = YA + ZA - ZB - YB = ((ZA - ZB) - (YB - YA))

		call	PolyClipCheck
		je	PClipBelow1	;T = 1 ->

		xor	ax,ax
		sar	dx,1
		rcr	ax,1
		idiv	bp    		;ax = T = (YA + ZA) / ((ZA - ZB) - (YB - YA))

		mov	bp,ax		;bp = T

		mov	bx,YA[si]		
		mov	cx,YB[si]

		sub	cx,bx		;cx = YB - YA
		imul	cx		;dx, ax = T * (YB - YA)
		FRACADJ	dx		;dx = T * (YB - YA)
		add	dx,bx		;dx = T * (YB - YA) + YA
		mov	YC[di],dx	;YC = T * (YB - YA) + YA

		neg	dx
		mov 	ZC[di],dx	;ZC = -YC

		mov	bx,XA[si]		
		mov	cx,XB[si]

		sub	cx,bx		;cx = XB - XA

		mov	ax,bp		;ax = T

		imul	cx		;dx, ax = T * (XB - XA)
		FRACADJ	dx		;dx = T * (XB - XA)
		add	dx,bx		;dx = T * (XB - XA) + XA
		mov	XC[di],dx	;XC = T * (XB - XA) + XA

BelowPClipDone:	mov	ax,XC[di]
		mov	bx,YC[di]
		mov	cx,ZC[di]
		add	di,6

		jmp	CalcOCode	;return via CalcOCode

;* T = 1

PClipBelow1:	mov	ax,XB[si]
		mov	XC[di],ax	;XC = XB
		mov	ax,YB[si]
		mov	YC[di],ax	;YC = YB
		neg	ax		
		mov	ZC[di],ax	;ZC = -YB

		jmp	BelowPClipDone

PolyClipBelow	ENDP

;----------------------------------------------------------------------------

;* PolyClipRight - right polygon clip
;*
;* pass: si -> end a and end b data
;*       di -> clipped point store
;* ret : di -> next clipped point store
;* kill: ax, bx, cx, dx, bp, flags
;*
;* note: Returns via CalcOCode.
;* 
;* Clip equations:-
;*
;* T = (YA - XA) / ((XB - XA) - (YB - YA))
;* 
;* when T <> 1: XC = YC
;*              YC = T * (YB - YA) + YA
;*              ZC = T * (ZB - ZA) + ZA
;*
;* when T = 1 : XC = YC
;*              YC = YB
;*              ZC = ZB

PolyClipRight	PROC	NEAR

		mov	ax,XA[si]
		mov	cx,YA[si]

		mov	bp,XB[si]
		mov	bx,YB[si]

		sub	bx,cx		;bx = YB - YA
		mov	dx,cx		;dx = YA
		sub	dx,ax		;dx = YA - XA
		sub	bp,ax		;bp = XB - XA
		sub	bp,bx		;bp = ((XB - XA) - (YB - YA))
		
		call	PolyClipCheck
		je	PClipRight1	;T = 1 ->

		xor	ax,ax
		sar	dx,1
		rcr	ax,1
		idiv 	bp		;ax = T = (YA - XA) / ((XB - XA) - (YB - YA))
    
		mov	bp,ax		;bp = T
		
		imul	bx	 	;dx, ax = T * (YB - YA)
		FRACADJ	dx		;dx = T * (YB - YA)
		add	dx,cx		;dx = T * (YB - YA) + YA
		mov	YC[di],dx 	;YC = T * (YB - YA) + YA
		mov	XC[di],dx 	;XC = YC

		mov	cx,ZA[si]
		mov	bx,ZB[si]
		
		sub 	bx,cx		;bx = ZB - ZA

		mov	ax,bp		;ax = T

		imul	bx		;dx, ax = T * (ZB - ZA)
		FRACADJ	dx		;dx = T * (ZB - ZA)
		add	dx,cx		;dx = T * (ZB - ZA) + ZA
		mov	ZC[di],dx	;ZC = T * (ZB - ZA) + ZA

RightPClipDone:	mov	ax,XC[di]
		mov	bx,YC[di]
		mov	cx,ZC[di]
		add	di,6

		jmp	CalcOCode	;return via CalcOCode

;* T = 1

PClipRight1: 	mov	ax,YB[si]
		mov	YC[di],ax	;YC = YB
		mov	XC[di],ax 	;XC = YC
		mov	ax,ZB[si]
		mov	ZC[di],ax	;ZC = ZB

		jmp	RightPClipDone

PolyClipRight	ENDP

;----------------------------------------------------------------------------

;* PolyClipLeft - left polygon clip
;*
;* pass: si -> end a and end b data
;*       di -> clipped point store
;* ret : di -> next clipped point store
;* kill: ax, bx, cx, dx, bp, flags
;*
;* note: Returns via CalcOCode.
;* 
;* Clip equations:-
;*
;* T = (YA + XA) / ((XA - XB) - (YB - YA))
;* 
;* when T <> 1: XC = -YC
;*              YC = T * (YB - YA) + YA
;*              ZC = T * (ZB - ZA) + ZA
;*
;* when T = 1 : XC = -YC
;*              YC = YB
;*              ZC = ZB

PolyClipLeft	PROC	NEAR

		mov	bp,XA[si]
		mov	cx,YA[si]

		mov	ax,XB[si]
		mov	bx,YB[si]

		sub	bx,cx		;bx = YB - YA
		mov	dx,cx		;dx = YA
		add	dx,bp  		;dx = YA + XA
		sub	bp,ax		;bp = XA - XB
		sub	bp,bx		;bp = (XA - XB) - (YB - YA)

		call	PolyClipCheck
		je	PClipLeft1 	;T = 1 ->

		xor	ax,ax
		sar	dx,1
		rcr	ax,1
		idiv	bp		;ax = T = (YA + XA) / ((XA - XB) - (YB - YA))

		mov	bp,ax		;bp = T

		imul	bx	 	;dx, ax =  T * (YB - YA)
		FRACADJ	dx		;dx = T * (YB - YA)
		add	dx,cx		;dx = T * (YB - YA) + YA
		mov	YC[di],dx 	;YC = T * (YB - YA) + YA
		neg	dx		
		mov	XC[di],dx	;XC = -YC

		mov	cx,ZA[si]
		mov	bx,ZB[si]
		
		sub	bx,cx		;bx = ZB - ZA
		
		mov	ax,bp		;ax = T

		imul	bx		;dx, ax = T * (ZB - ZA)
		FRACADJ	dx		;dx = T * (ZB - ZA)
		add	dx,cx		;dx = T * (ZB - ZA) + ZA
		mov	ZC[di],dx	;ZC = T * (ZB - ZA) + ZA

LeftPClipDone:	mov	ax,XC[di]
		mov	bx,YC[di]
		mov	cx,ZC[di]
		add	di,6

		jmp	CalcOCode	;return via CalcOCode

;* T = 1

PClipLeft1:	mov	ax,YB[si]
		mov	YC[di],ax	;YC = YB
		neg	ax
		mov	XC[di],ax 	;XC = -YC
		mov	ax,ZB[si]
		mov	ZC[di],ax	;ZC = ZB

		jmp	LeftPClipDone

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
		ret

NullPoly	ENDP

;----------------------------------------------------------------------------

;* ClipLineEnd - clip one end of line
;*
;* pass: si = end a index
;*       di = end b index
;* ret : XEndC, YEndC, ZEndC
;*       cf = 0 = visible
;*       cf = 1 = non-visible or error (do not draw line)
;* kill: ax, bx, cx, dx, bp, flags

ClipLineEnd	PROC	NEAR

		mov	ClipRecover,sp	;recover stack to here if clip error

		mov	ax,Xe[si]
		mov	XEndA,ax
		mov	ax,Ye[si]
		mov	YEndA,ax
		mov	ax,Ze[si]
		mov	ZEndA,ax

		mov	ax,Xe[di]
		mov	XEndB,ax
		mov	ax,Ye[di]
		mov	YEndB,ax
		mov	ax,Ze[di]
		mov	ZEndB,ax

		mov	al,OutCode[si]
		mov	OCodeEndA,al

		test	al,080h		;behind?
		jz	SkipLineBehind	;no ->
		call	LineClipBehind
		test	al,OutCode[di]	;totally non-vis after behind clip?
		jnz	ClipEndFail	;yes ->

		mov	OCodeEndA,al	;overwrite end a with clipped end
		mov	ax,XEndC
		mov	XEndA,ax
		mov	ax,YEndC
		mov	YEndA,ax
		mov	ax,ZEndC
		mov	ZEndA,ax

		mov	al,OCodeEndA
SkipLineBehind:	test	al,001h		;left?
		jz	SkipLineLeft	;no ->
		call	LineClipLeft
		jz	ClipEndExit

		mov	al,OCodeEndA
SkipLineLeft:	test	al,002h		;right?
		jz	SkipLineRight	;no ->
		call	LineClipRight
		jz	ClipEndExit

		mov	al,OCodeEndA
SkipLineRight:	test	al,004h		;below?
		jz	SkipLineBelow	;no ->
		call	LineClipBelow
		jz	ClipEndExit

		mov	al,OCodeEndA
SkipLineBelow:	test	al,008h		;above?
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
;* ret : abs(dx)
;*       abs(bp)
;*       zf = 0: t < 1
;*       zf = 1: t = 1
;* kill: ax, flags
;*
;* note: If an error occurs (sign(dx) <> sign(bp) or abs(bp) < abs(dx))
;*       then the program recovers the stack and drops out of ClipLineEnd.

LineClipCheck	PROC	NEAR

		mov	ax,dx
		xor	ax,bp		;sign(dx) = sign(bp)?
		js	LClipDivError	;no, error ->

		test	bp,bp		;+ve?
		jns	LClipDivTest	;yes ->

		neg	dx
		neg	bp

LClipDivTest:	cmp	bp,dx		;abs(bp) < abs(dx)?
		jb	LClipDivError	;yes ->

		ret

LClipDivError:	mov	sp,ClipRecover	;recover the stack

		jmp	ClipEndFail

LineClipCheck	ENDP

;----------------------------------------------------------------------------

;* LineClipBehind - behind line clip
;*
;* pass: XEndA, YEndA, ZEndA
;*       XEndB, YEndB, ZEndB
;* ret : XEndC, YEndC, ZEndC
;* kill: ax, bx, cx, dx, bp, flags
;*
;* note: Returns via CalcOCode.
;*
;* Clip equations:-
;*
;* T = (YA - 1) / (YA - YB)
;* 
;* when T <> 1: XC = T * (XB - XA) + XA
;*              YC = 1
;*              ZC = T * (ZB - ZA) + ZA
;*
;* when T = 1 : XC = XB
;*              YC = 1
;*              ZC = ZB

LineClipBehind	PROC	NEAR

		mov	cx,XEndA
		mov	dx,YEndA

		mov	bx,XEndB
		mov	ax,YEndB

		sub	bx,cx		;bx = XB - XA
		mov	bp,dx		;bp = YA
		sub	bp,ax		;bp = YA - YB
		dec	dx  		;dx = YA - 1

		call	LineClipCheck
		je	LClipBehind1	;T = 1 ->

		xor	ax,ax
		sar	dx,1
		rcr	ax,1
		idiv	bp		;ax = T = (YA - 1) / (YA - YB)

		mov	bp,ax		;bp = T

		imul	bx 		;dx, ax = T * (XB - XA)
		FRACADJ	ax		;ax = T * (XB - XA)
		add 	ax,cx		;ax = T * (XB - XA) + XA
		mov 	XEndC,ax	;XC = T * (XB - XA) + XA

		mov	ax,1
		mov	YEndC,ax	;YC = 1

		mov	cx,ZEndA
		mov	bx,ZEndB 		
		
		sub	bx,cx		;bx = ZB - ZA

		mov	ax,bp		;ax = T

		imul	bx		;dx, ax = T * (ZB - ZA)
		FRACADJ	ax		;ax = T * (ZB - ZA)
		add	ax,cx		;ax = T * (ZB - ZA) + ZA
		mov	ZEndC,ax	;ZC = T * (ZB - ZA) + ZA

BehindLClipDone:mov	ax,XEndC
		mov	bx,YEndC
		mov	cx,ZEndC

		jmp	CalcOCode	;return via CalcOCode

;* T = 1

LClipBehind1:	mov	ax,XEndB
		mov	XEndC,ax	;XC = XB
		mov	ax,1
		mov	YEndC,ax	;YC = 1
		mov	ax,ZEndB
		mov	ZEndC,ax	;ZC = ZB

		jmp	BehindLClipDone

LineClipBehind	ENDP

;----------------------------------------------------------------------------

;* LineClipAbove - above line clip
;*
;* pass: XEndA, YEndA, ZEndA
;*       XEndB, YEndB, ZEndB
;* ret : XEndC, YEndC, ZEndC
;* kill: ax, bx, cx, dx, bp, flags
;*
;* note: Returns via CalcOCode.
;* 
;* Clip equations:-
;*
;* T = (YA - ZA) / ((ZB - ZA) - (YB - YA))
;* 
;* when T <> 1: XC = T * (XB - XA) + XA
;*              YC = T * (YB - YA) + YA
;*              ZC = YC
;*
;* when T = 1 : XC = XB
;*              YC = YB
;*              ZC = YC

LineClipAbove	PROC	NEAR

		mov	dx,YEndA
		mov	bx,ZEndA

		mov	ax,YEndB
		mov	cx,ZEndB

		sub	dx,bx		;dx = YA - ZA
		mov 	bp,dx		;bp = YA - ZA
		add	bp,cx		;bp = YA - ZA + ZB
		sub	bp,ax		;bp = YA - ZA + ZB - YB = ((ZB - ZA) - (YB - YA))

		call	LineClipCheck
		je	LClipAbove1	;T = 1 ->

		xor	ax,ax
		sar	dx,1
		rcr	ax,1
		idiv 	bp		;ax = T = (YA - ZA) / ((ZB - ZA) - (YB - YA))
   
		mov	bp,ax		;bp = T

		mov	bx,YEndA
		mov	cx,YEndB

		sub	cx,bx		;cx = YB - YA
		imul	cx		;dx, ax = T * (YB - YA)
		FRACADJ	ax		;ax = T * (YB - YA)
		add	ax,bx		;ax = T * (YB - YA) + YA
		mov	YEndC,ax	;YC = T * (YB - YA) + YA
		mov	ZEndC,ax	;ZC = YC

		mov	bx,XEndA		
		mov	cx,XEndB

		sub	cx,bx		;cx = XB - XA

		mov	ax,bp		;ax = T

		imul	cx		;dx, ax = T * (XB - XA)
		FRACADJ	ax		;ax = T * (XB - XA)
		add	ax,bx 		;ax = T * (XB - XA) + XA
		mov 	XEndC,ax 	;XC = T * (XB - XA) + XA

AboveLClipDone:	mov	ax,XEndC
		mov	bx,YEndC
		mov	cx,ZEndC

		jmp	CalcOCode	;return via CalcOCode

;* T = 1

LClipAbove1:	mov 	ax,XEndB
		mov 	XEndC,ax	;XC = XB
		mov	ax,YEndB
		mov	YEndC,ax	;YC = YB
		mov	ZEndC,ax	;ZC = YC

		jmp	AboveLClipDone

LineClipAbove	ENDP

;----------------------------------------------------------------------------

;* LineClipBelow - below line clip
;*
;* pass: XEndA, YEndA, ZEndA
;*       XEndB, YEndB, ZEndB
;* ret : XEndC, YEndC, ZEndC
;* kill: ax, bx, cx, dx, bp, flags
;*
;* note: Returns via CalcOCode.
;* 
;* Clip equations:-
;*
;* T = (YA + ZA) / ((ZA - ZB) - (YB - YA))
;* 
;* when T <> 1: XC = T * (XB - XA) + XA
;*              YC = T * (YB - YA) + YA
;*              ZC = -YC
;*
;* when T = 1 : XC = XB
;*              YC = YB
;*              ZC = -YC

LineClipBelow	PROC	NEAR

		mov	dx,YEndA
		mov	bx,ZEndA

		mov	ax,YEndB
		mov	cx,ZEndB
		
		add	dx,bx		;dx = YA + ZA
		mov	bp,dx		;bp = YA + ZA
		sub	bp,cx		;bp = YA + ZA - ZB
		sub	bp,ax		;bp = YA + ZA - ZB - YB = ((ZA - ZB) - (YB - YA))

		call	LineClipCheck
		je	LClipBelow1 	;T = 1 ->

		xor	ax,ax
		sar	dx,1
		rcr	ax,1
		idiv	bp    		;ax = T = (YA + ZA) / ((ZA - ZB) - (YB - YA))

		mov	bp,ax		;bp = T

		mov	bx,YEndA		
		mov	cx,YEndB

		sub	cx,bx		;cx = YB - YA
		imul	cx		;dx, ax = T * (YB - YA)
		FRACADJ	ax		;ax = T * (YB - YA)
		add	ax,bx		;ax = T * (YB - YA) + YA
		mov	YEndC,ax	;YC = T * (YB - YA) + YA
		neg	ax
		mov 	ZEndC,ax	;ZC = -YC

		mov	bx,XEndA		
		mov	cx,XEndB

		sub	cx,bx		;cx = XB - XA

		mov	ax,bp		;ax = T

		imul	cx		;dx, ax = T * (XB - XA)
		FRACADJ	ax		;ax = T * (XB - XA)
		add	ax,bx		;ax = T * (XB - XA) + XA
		mov	XEndC,ax	;XC = T * (XB - XA) + XA

BelowLClipDone:	mov	ax,XEndC
		mov	bx,YEndC
		mov	cx,ZEndC

		jmp	CalcOCode	;return via CalcOCode

;* T = 1

LClipBelow1:	mov	ax,XEndB
		mov	XEndC,ax	;XC = XB
		mov	ax,YEndB
		mov	YEndC,ax	;YC = YB
		neg	ax		
		mov	ZEndC,ax	;ZC = -YB

		jmp	BelowLClipDone

LineClipBelow	ENDP

;----------------------------------------------------------------------------

;* LineClipRight - right line clip
;*
;* pass: XEndA, YEndA, ZEndA
;*       XEndB, YEndB, ZEndB
;* ret : XEndC, YEndC, ZEndC
;* kill: ax, bx, cx, dx, bp, flags
;*
;* note: Returns via CalcOCode.
;* 
;* Clip equations:-
;*
;* T = (YA - XA) / ((XB - XA) - (YB - YA))
;* 
;* when T <> 1: XC = YC
;*              YC = T * (YB - YA) + YA
;*              ZC = T * (ZB - ZA) + ZA
;*
;* when T = 1 : XC = YC
;*              YC = YB
;*              ZC = ZB

LineClipRight	PROC	NEAR

		mov	ax,XEndA
		mov	cx,YEndA

		mov	bp,XEndB
		mov	bx,YEndB

		sub	bx,cx		;bx = YB - YA
		mov	dx,cx		;dx = YA
		sub	dx,ax		;dx = YA - XA
		sub	bp,ax		;bp = XB - XA
		sub	bp,bx		;bp = ((XB - XA) - (YB - YA))
		
		call	LineClipCheck
		je	LClipRight1 	;T = 1 ->

		xor	ax,ax
		sar	dx,1
		rcr	ax,1
		idiv 	bp		;ax = T = (YA - XA) / ((XB - XA) - (YB - YA))
    
		mov	bp,ax		;bp = T
		
		imul	bx	 	;dx, ax = T * (YB - YA)
		FRACADJ	ax		;ax = T * (YB - YA)
		add	ax,cx		;ax = T * (YB - YA) + YA
		mov	YEndC,ax 	;YC = T * (YB - YA) + YA
		mov	XEndC,ax 	;XC = YC

		mov	cx,ZEndA
		mov	bx,ZEndB
		
		sub 	bx,cx		;bx = ZB - ZA

		mov	ax,bp		;ax = T

		imul	bx		;dx, ax = T * (ZB - ZA)
		FRACADJ	ax		;ax = T * (ZB - ZA)
		add	ax,cx		;ax = T * (ZB - ZA) + ZA
		mov	ZEndC,ax	;ZC = T * (ZB - ZA) + ZA

RightLClipDone:	mov	ax,XEndC
		mov	bx,YEndC
		mov	cx,ZEndC

		jmp	CalcOCode	;return via CalcOCode

;* T = 1

LClipRight1:	mov	ax,YEndB
		mov	YEndC,ax	;YC = YB
		mov	XEndC,ax 	;XC = YC
		mov	ax,ZEndB
		mov	ZEndC,ax	;ZC = ZB

		jmp	RightLClipDone

LineClipRight	ENDP

;----------------------------------------------------------------------------

;* LineClipLeft - left line clip
;*
;* pass: XEndA, YEndA, ZEndA
;*       XEndB, YEndB, ZEndB
;* ret : XEndC, YEndC, ZEndC
;* kill: ax, bx, cx, dx, bp, flags
;*
;* note: Returns via CalcOCode.
;* 
;* Clip equations:-
;*
;* T = (YA + XA) / ((XA - XB) - (YB - YA))
;* 
;* when T <> 1: XC = -YC
;*              YC = T * (YB - YA) + YA
;*              ZC = T * (ZB - ZA) + ZA
;*
;* when T = 1 : XC = -YC
;*              YC = YB
;*              ZC = ZB

LineClipLeft	PROC	NEAR

		mov	bp,XEndA
		mov	cx,YEndA

		mov	ax,XEndB
		mov	bx,YEndB

		sub	bx,cx		;bx = YB - YA
		mov	dx,cx		;dx = YA
		add	dx,bp  		;dx = YA + XA
		sub	bp,ax		;bp = XA - XB
		sub	bp,bx		;bp = (XA - XB) - (YB - YA)

		call	LineClipCheck
		je	LClipLeft1	;T = 1 ->

		xor	ax,ax
		sar	dx,1
		rcr	ax,1
		idiv	bp		;ax = T = (YA + XA) / ((XA - XB) - (YB - YA))

		mov	bp,ax		;bp = T

		imul	bx	 	;dx, ax =  T * (YB - YA)
		FRACADJ	ax		;ax = T * (YB - YA)
		add	ax,cx		;ax = T * (YB - YA) + YA
		mov	YEndC,ax 	;YC = T * (YB - YA) + YA
		neg	ax		
		mov	XEndC,ax	;XC = -YC

		mov	cx,ZEndA
		mov	bx,ZEndB
		
		sub	bx,cx		;bx = ZB - ZA
		
		mov	ax,bp		;ax = T

		imul	bx		;dx, ax = T * (ZB - ZA)
		FRACADJ	ax		;ax = T * (ZB - ZA)
		add	ax,cx		;ax = T * (ZB - ZA) + ZA
		mov	ZEndC,ax	;ZC = T * (ZB - ZA) + ZA

LeftLClipDone:	mov	ax,XEndC
		mov	bx,YEndC
		mov	cx,ZEndC

		jmp	CalcOCode	;return via CalcOCode

;* T = 1

LClipLeft1: 	mov	ax,YEndB
		mov	YEndC,ax	;YC = YB
		neg	ax
		mov	XEndC,ax 	;XC = -YC
		mov	ax,ZEndB
		mov	ZEndC,ax	;ZC = ZB

		jmp	LeftLClipDone

LineClipLeft	ENDP

;----------------------------------------------------------------------------

;* PolyLineClip - draw clipped lines (wrt ObjectDrawMode)
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

PolyLineClip	PROC	NEAR

		mov	bx,ObjectDrawMode
		jmp	PLineClipMode[bx]

PolyLineClip	ENDP

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

ReDoDrawPLine:	lodsb			;fetch first vertex index
		cmp	al,-1		;end of list?
		je	DrawPLineExit	;yes ->

		mov	bl,al

		mov	cx,XCrt[bx]	;cx = x1
		cmp	cx,-1	      	;error?
		je	ReDoDrawPLine	;yes ->
		mov	dl,YCrt[bx]	;dl = y1

DrawPLineLoop:	lodsb			;fetch next vertex index
		cmp	al,-1		;end of list?
		je	DrawPLineExit	;yes ->

		mov	bl,al

		mov	ax,XCrt[bx]	;ax = x2
		cmp	ax,-1		;error?
		je	ReDoDrawPLine	;yes ->
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
		ret

DrawPLineFail:	stc			;cf = 1 = non-visible or error
		ret

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
		ret

ClipPLineFail:	stc			;cf = 1 = non-visible or error
		ret

ClipPolyLine	PROC	NEAR

		mov	ax,di
		mov	TempPtr1,ax
		mov	TempPtr2,ax

ReDoClipPLine:	lodsb			;fetch first vertex index
		cmp	al,-1		;end of list?
		je	ClipPLineExit	;yes ->

		xor	ah,ah
		mov	bx,ax		;bx = end a index
		mov	al,OutCode[bx]	;fetch end a outcode
		test	al,al		;end a visible?
		jnz	ClipPLineLoop	;no ->

		mov	di,bx
		mov	ax,Xe[di]
		mov	bx,Ye[di]
		mov	cx,Ze[di]
		CALC_CRT		;calc end a crt co-ords
		jc	ReDoClipPLine	;error ->
		mov	XCrt[di],cx
		mov	YCrt[di],bl
		mov	bx,di

ClipPLineLoop:	lodsb			;fetch next vertex index
		cmp	al,-1		;end of list?
		je	ClipPLineExit	;yes ->

		xor	ah,ah
		mov	di,ax		;di = end b index
		mov	al,OutCode[di]	;fetch end b outcode
		test	al,al		;end b visible?
		jnz	PLineVisTest	;no ->

		push	bx
		mov	ax,Xe[di]
		mov	bx,Ye[di]
		mov	cx,Ze[di]
		CALC_CRT		;calc end b crt co-ords
		mov	XCrt[di],cx
		mov	YCrt[di],bl
		pop	bx
		jc	ReDoClipPLine	;error ->

PLineVisTest:	mov	TempPtr3,si

		mov	si,bx		;si = end a index

		mov	dl,OutCode[si]	;dl = end a outcode
		mov	dh,OutCode[di]	;dh = end b outcode

		test	dl,dh		;line totally non-visible?
		jnz	PLineNonVis	;yes ->

		mov	al,dl
		or	al,dh	    	;line totally visible?
		jz	ClipPLineDraw	;yes ->

		test	dl,dl		;end a requires clipping?
		jz	ClipPLineEndB	;no, must be end b ->

		call	ClipLineEnd	;clip end a
		jc	PLineNonVis	;end a non-visible ->
		mov	ax,XEndC
		mov	bx,YEndC
		mov	cx,ZEndC
		CALC_CRT		;calc end a crt co-ords
		jc	PLineNonVis	;error ->
		mov	XCrt[si],cx
		mov	YCrt[si],bl

		mov	al,OutCode[di]
		test	al,al		;end b requires cliping?
		jz	ClipPLineDraw	;no ->

ClipPLineEndB:	xchg	si,di
		call	ClipLineEnd	;clip end b
		xchg	si,di
		jc	PLineNonVis	;end b non-visible ->
		mov	ax,XEndC
		mov	bx,YEndC
		mov	cx,ZEndC
		CALC_CRT		;calc end b crt co-ords
		jc	PLineNonVis	;error ->
		mov	XCrt[di],cx
		mov	YCrt[di],bl

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
		ret

NullPolyLine	ENDP

;----------------------------------------------------------------------------

;* PolyDotClip - draw clipped dots (wrt ObjectDrawMode)
;*
;* pass: si indexes last vertex in Xe[], Ye[] and Ze[] arrays
;* ret : XCrt[], YCrt[] = x, y crt co-ords of dots (-1, -1 = dot not visible or error)
;* kill: assume all

PolyDotClip	PROC	NEAR

		mov	bx,ObjectDrawMode
		jmp	PDotClipMode[bx]

PolyDotClip	ENDP

;----------------------------------------------------------------------------

;* DrawPolyDots - draw dots (no clipping required)
;*
;* pass: )
;* ret : ) Refer to PolyDotClip
;* kill: )
;*
;* note: All x crt and y crt values have been pre-calculated in CalcOutCodes
;*       and stored in the crt arrays XCrt[] and YCrt[].

DrawPolyDots	PROC	NEAR

		ret

DrawPolyDots	ENDP

;----------------------------------------------------------------------------

;* ClipPolyDots - draw clipped dots
;*
;* pass: )
;* ret : ) Refer to PolyDotClip
;* kill: )

ClipPolyDots	PROC	NEAR

		mov	al,OutCode[si]
		test	al,al		;point visible?
		jnz	@F		;no ->

;* point visible calc crt co-ord

		mov	ax,Xe[si]
		mov	bx,Ye[si]
		mov	cx,Ze[si]
		CALC_CRT		;calc crt co-ords
		mov	XCrt[si],cx
		mov	YCrt[si],bl

		sub	si,2
		jnc	ClipPolyDots  	;next point ->

		ret

;* point non-visible, XCrt = YCrt = -1 (do not draw)

@@:		mov	ax,-1

		mov	XCrt[si],ax
		mov	YCrt[si],al

		sub	si,2
		jnc	ClipPolyDots  	;next point ->

		ret

ClipPolyDots	ENDP

;----------------------------------------------------------------------------

;* NullPolyDots - null draw dots routine
;*
;* pass: )
;* ret : ) Refer to PolyDotClip
;* kill: )

NullPolyDots	PROC	NEAR

		mov	ax,-1

;* point non-visible, XCrt = YCrt = -1 (do not draw)

@@:		mov	XCrt[si],ax
		mov	YCrt[si],al

		sub	si,2
		jnc	@B		;next point ->

		ret

NullPolyDots	ENDP

;----------------------------------------------------------------------------

;* QuickLineClip - clip a single line and calc crt co-ords (if visible)
;*
;* pass: Xe[0], Ye[0], Ze[0] = end a eye co-ords
;*       Xe[2], Ye[2], Ze[2] = end b eye co-ords
;* ret : cf = 0 = visible: XCrt[0], YCrt[0] = end a crt co-ords
;*                         XCrt[2], YCrt[2] = end b crt co-ords
;*       cf = 1 = non-visible or error
;* kill: assume all

QuickLineClip	PROC	NEAR

		mov	si,0		;end a index
		mov	di,2		;end b index

		mov	ax,Xe[si]	;fetch eye co-ords
		mov	bx,Ye[si]
		mov	cx,Ze[si]

		SCALE_V_PYRAMID		;scale viewing pyramid wrt view mode

		call	CalcOCode	;calculate outcode

		mov	OutCode[si],al	;store outcode

		xchg	si,di

		mov	ax,Xe[si]	;fetch eye co-ords
		mov	bx,Ye[si]
		mov	cx,Ze[si]

		SCALE_V_PYRAMID		;scale viewing pyramid wrt view mode

		call	CalcOCode	;calculate outcode

		mov	OutCode[si],al	;store outcode

		xchg	si,di

;* test line visibility

		mov	ah,OutCode[si]

		test	al,ah		;both ends on same side of pyramid?
		jnz	QLineClipFail	;yes, non-visible ->

;* test end a visibility, clip and calc crt co-ords

		test	ah,ah		;end a visible?
		jnz	ClipEndA	;no ->

		mov	ax,Xe[si]
		mov	bx,Ye[si]
		mov	cx,Ze[si]
		jmp	CalcEndACrt

ClipEndA:	call	ClipLineEnd
		jc	QLineClipFail	;non-visible ->
		
		mov	ax,XEndC
		mov	bx,YEndC
		mov	cx,ZEndC

CalcEndACrt:	CALC_CRT
		jc	QLineClipFail 	;non-visible ->

		mov	XCrt[si],cx
		mov	WORD PTR YCrt[si],bx

;* test end b visibility, clip and calc crt co-ords

		xchg	si,di

		mov	al,OutCode[si]

		test	al,al		;end b visible?
		jnz	ClipEndB	;no ->

		mov	ax,Xe[si]
		mov	bx,Ye[si]
		mov	cx,Ze[si]
		jmp	CalcEndBCrt

ClipEndB:	call	ClipLineEnd
		jc	QLineClipFail	;non-visible ->
		
		mov	ax,XEndC
		mov	bx,YEndC
		mov	cx,ZEndC

CalcEndBCrt:	CALC_CRT
		jc	QLineClipFail 	;non-visible ->

		mov	XCrt[si],cx
		mov	WORD PTR YCrt[si],bx

		clc			;cf = 0 = visible
		ret

QLineClipFail:	stc			;cf = 1 = non-visible or error
		ret

QuickLineClip	ENDP

;----------------------------------------------------------------------------

;* HorizonClip - clip horizon line and calc crt co-ords (if visible)
;*
;* pass: Xe[0], Ye[0], Ze[0] = end a eye co-ords
;*       Xe[2], Ye[2], Ze[2] = end b eye co-ords
;* ret : cf = 0 = visible: XCrt[0], YCrt[0] = end a crt co-ords
;*                         XCrt[2], YCrt[2] = end b crt co-ords
;*       cf = 1 = non-visible or error
;* kill: assume all
;*
;* note: This routine assumes that end a and end b eye co-ords have been
;*       selected so that they always require clipping.

HorizonClip	PROC	NEAR

		mov	si,0		;end a index
		mov	di,2		;end b index

		mov	ax,Xe[si]	;fetch eye co-ords
		mov	bx,Ye[si]
		mov	cx,Ze[si]

		SCALE_V_PYRAMID		;scale viewing pyramid wrt view mode

		call	CalcOCode	;calculate outcode

		mov	OutCode[si],al	;store outcode

		xchg	si,di

		mov	ax,Xe[si]	;fetch eye co-ords
		mov	bx,Ye[si]
		mov	cx,Ze[si]

		SCALE_V_PYRAMID		;scale viewing pyramid wrt view mode

		call	CalcOCode	;calculate outcode

		mov	OutCode[si],al	;store outcode

		xchg	si,di

;* test horizon visibility

		mov	ah,OutCode[si]

		test	al,ah		;both ends on same side of pyramid?
		jnz	HrznClipFail	;yes, non-visible ->

;* clip end a and test for visibility, if visible calc crt co-ords

		call	ClipLineEnd
		jc	HrznClipFail	;non-visible ->
		
		mov	ax,XEndC
		mov	bx,YEndC
		mov	cx,ZEndC
		CALC_CRT
		jc	HrznClipFail	;non-visible ->

		mov	XCrt[si],cx
		mov	WORD PTR YCrt[si],bx

;* clip end b and test for visibility, if visible calc crt co-ords

		xchg	si,di

		call	ClipLineEnd
		jc	HrznClipFail	;non-visible ->
		
		mov	ax,XEndC
		mov	bx,YEndC
		mov	cx,ZEndC
		CALC_CRT
		jc	HrznClipFail	;non-visible ->

		mov	XCrt[si],cx
		mov	WORD PTR YCrt[si],bx

		clc			;cf = 0 = visible
		ret

HrznClipFail:	stc			;cf = 1 = non-visible or error
		ret

HorizonClip	ENDP

;----------------------------------------------------------------------------

;* DotClip - clip single point and generate crt co-ords if visible
;*
;* pass: Xe[0], Ye[0], Ze[0] = point eye co-ords
;* ret : cf = 0 = visible: cx = x crt
;*                         bl = y crt
;*       cf = 1 = non-visible or error
;* kill: assume all (except bl, cx, cf)

DotClip		PROC	NEAR

		xor	si,si		;index = 0
	
		mov	ax,Xe[0]	;fetch eye co-ords
		mov	bx,Ye[0]
		mov	cx,Ze[0]

		SCALE_V_PYRAMID		;scale viewing pyramid wrt view mode

		call	CalcOCode	;calculate outcode
		jnz	DotClipFail	;non-visible ->

		mov	ax,Xe[0]	;fetch eye co-ords
		mov	bx,Ye[0]
		mov	cx,Ze[0]

   		CALC_CRT		;cx = x crt, bl = y crt, cf = error status

		ret

DotClipFail:	stc			;cf = 1 = non-visible or error
		ret

DotClip		ENDP

;----------------------------------------------------------------------------

;* XDotClip - same as DotClip but available externally
;*
;* pass: Xe[0], Ye[0], Ze[0] = point eye co-ords
;* ret : cf = 0 = visible: cx = x crt
;*                         bl = y crt
;*       cf = 1 = non-visible or error
;* kill: assume all (except bl, cx, cf)

XDotClip      	PROC	FAR

		xor	si,si		;index = 0
	
		mov	ax,Xe[0]	;fetch eye co-ords
		mov	bx,Ye[0]
		mov	cx,Ze[0]

		SCALE_V_PYRAMID		;scale viewing pyramid wrt view mode

		call	CalcOCode	;calculate outcode
		jnz	XDotClipFail	;non-visible ->

		mov	ax,Xe[0]	;fetch eye co-ords
		mov	bx,Ye[0]
		mov	cx,Ze[0]

   		CALC_CRT		;cx = x crt, bl = y crt, cf = error status

		ret

XDotClipFail:	stc			;cf = 1 = non-visible or error
		ret

XDotClip 	ENDP

;----------------------------------------------------------------------------

;* CyclicCheck - test if polygon co-ords are in a clockwise or anti-clockwise
;*               order
;*
;* pass: si -> clipped polygon co-ords buffer (-1 terminator)
;*             ie. si -> x1, y1
;*                       x2, y2
;*                       .., ..
;*                       xn, yn 
;*                       x1, y1	(first point repeated)
;*                       -1     (terminator)
;* ret : sf = 0 (+ve) = clockwise
;*       sf = 1 (-ve) = anti-clockwise
;*       cf = 0 = cyclic ok
;*       cf = 1	= cyclic error
;* kill: assume all (except sf, cf)
;* 
;* note: The order of the co-ords is determined using cross products of
;*       vectors. The sign of the result tells us if the points are in a 
;*       clockwise (positive) or anti-clockwise (negative) order.
;*
;*       Dx1 = x1 - x2, Dy1 = y1 - y2
;*       Dx2 = x2 - x3, Dy2 = y2 - y3
;*
;*       result = (Dx1 * Dy2) - (Dx2 * Dy1)
;*
;*       Two cyclic check methods are used:-
;*
;*          FastCyclic: Simple cyclic check used for totally visible objects.
;*
;*                      This method only checks the first set of points
;*                      encountered.
;*
;*          SlowCyclic: Rigorous cyclic check used for clipped objects.
;*
;*                      This method checks up to 3 sets of points and uses a
;*                      "majority vote" to determine the cyclic. This is
;*                      necessary as the clipped points can sometimes cause
;*                      errors (especially where clipping produces two adjacent
;*                      pixels on the clipping window edge).
;*
;*	 A minimal polygon will at least have the following number of points:-
;*
;*       x1, y1, x2, y2, x3, y3, x1, y1, -1

CyclicCheck	PROC	NEAR

		mov	bx,ObjectDrawMode
		jmp	CyclicMode[bx]

CyclicCheck	ENDP

;----------------------------------------------------------------------------

;* FastCyclic - simple cyclic check
;*
;* pass: )
;* ret : ) Refer to CyclicCheck
;* kill: )

FastCyclic	PROC	NEAR

		lodsw			;fetch x1
		test	ax,ax	      	;end of list?
		js	FastCyclicFail	;yes ->
		mov	bp,ax
		lodsw			;fetch y1
		mov	di,ax

		lodsw			;fetch x2
		test	ax,ax		;end of list?
		js	FastCyclicFail	;yes ->
		mov	bx,ax
		lodsw			;fetch y2
		mov	cx,ax
	
		lodsw			;fetch x3
		test	ax,ax		;end of list?
		js	FastCyclicFail	;yes ->
		mov	dx,ax
		lodsw			;fetch y3
		
		sub	bp,bx		;Dx1 = x1 - x2
		sub	di,cx		;Dy1 = y1 - y2
		sub	bx,dx		;Dx2 = x2 - x3
		sub	cx,ax		;Dy2 = y2 - y3

		mov	ax,bp		;ax = Dx1
		imul	cx		;dx, ax = Dx1 * Dy2

		xchg	ax,di		;ax = Dy1
		mov	bp,dx		;bp, di = Dx1 * Dy2

		imul	bx		;dx, ax = Dx2 * Dy1

		sub	di,ax
		sbb	bp,dx		;result (Dx1 * Dy2) - (Dx2 * Dy1)

		clc			;cyclic ok
		ret

;* failed cyclic check - cannot determine point order - assume clockwise

FastCyclicFail:	xor	ax,ax		;clockwise
		stc			;cyclic error
		ret

FastCyclic	ENDP

;----------------------------------------------------------------------------

;* SlowCyclic - rigorous cyclic check
;*
;* pass: )
;* ret : ) Refer to CyclicCheck
;* kill: )

;* failed cyclic check - cannot determine point order - assume clockwise

SlowCyclicFail	LABEL	NEAR

		xor	ax,ax		;clockwise
		stc			;cyclic error
		ret

SlowCyclic	PROC	NEAR

		lodsw			;fetch x1
		test	ax,ax	      	;end of list?
		js	SlowCyclicFail	;yes ->
		mov	bp,ax
		lodsw			;fetch y1
		mov	di,ax

X2Y2Loop:	mov	TempPtr1,si	;store ptr to x2, y2

		lodsw			;fetch x2
		test	ax,ax		;end of list?
		js	SlowCyclicFail	;yes ->
		mov	bx,ax
		lodsw			;fetch y2
		mov	cx,ax
	
		cmp	bx,bp		;x2 = x1?
		jne	X3Y3Loop	;no ->
		cmp	cx,di		;y2 = y1?
		je	X2Y2Loop	;yes ->

X3Y3Loop:	lodsw			;fetch x3
		test	ax,ax		;end of list?
		js	SlowCyclicFail	;yes ->
		mov	dx,ax
		lodsw			;fetch y3

		cmp	dx,bx		;x3 = x2?
		jne	CalcResult1	;no ->
		cmp	ax,cx		;y3 = y2?
		je	X3Y3Loop	;yes ->

CalcResult1:	push	dx		;store x3
		push	ax		;store y3

		sub	bp,bx		;Dx1 = x1 - x2
		sub	di,cx		;Dy1 = y1 - y2
		sub	bx,dx		;Dx2 = x2 - x3
		sub	cx,ax		;Dy2 = y2 - y3

		mov	ax,bp		;ax = Dx1
		imul	cx		;dx, ax = Dx1 * Dy2

		xchg	ax,di		;ax = Dy1
		mov	bp,dx		;bp, di = Dx1 * Dy2

		imul	bx		;dx, ax = Dx2 * Dy1

		sub	di,ax
		sbb	bp,dx		;result1 = (Dx1 * Dy2) - (Dx2 * Dy1)

		pop	dx		;restore y3
		pop	di		;restore x3

;* bx = Dx2
;* cx = Dy2
;* dx = y3
;* si = ptr
;* di = x3
;* bp = result1

		push	bp		;store result1

X4Y4Loop:	lodsw			;fetch x4
		test	ax,ax		;end of list?
		js	LoopBack1	;yes, loop back to x2, y2 ->
ContCyclic1:	mov	bp,ax
		lodsw			;fetch y4

		cmp	bp,di		;x4 = x3?
		jne	CalcResult2	;no ->
		cmp	ax,dx		;y4 = y3?
		je	X4Y4Loop	;yes ->		

CalcResult2:	sub	di,bp		;Dx3 = x3 - x4
		sub	dx,ax		;Dy3 = y3 - y4

		push	bp		;store x4
		push	ax		;store y4

		mov	ax,bx		;ax = Dx2
		mov	bx,dx  		;bx = Dy3
		imul	bx		;dx, ax = Dx2 * Dy3

		xchg	ax,cx		;ax = Dy2
		mov	bp,dx		;bp, cx = Dx2 * Dy3

		imul	di		;dx, ax = Dx3 * Dy2

		sub	cx,ax
		sbb	bp,dx		;result2 = (Dx2 * Dy3) - (Dx3 * Dy2)

		pop	dx		;restore y4
		pop	cx		;restore x4
		pop	ax		;restore result1

		xor	ax,bp		;sign(result1) = sign(result2)?
		js	X5Y5Loop	;no ->

		test	bp,bp		;result = sign(result2) = sign(result1), cyclic ok 
		ret

;* bx = Dy3
;* cx = x4
;* dx = y4
;* di = Dx3

X5Y5Loop:	lodsw			;fetch x5
		test	ax,ax		;end of list?
		js	LoopBack2	;yes, loop back to x2, y2 ->
ContCyclic2:	mov	bp,ax
		lodsw			;fetch y5

		cmp	bp,cx		;x5 = x4?
		jne	CalcResult3	;no ->
		cmp	ax,dx		;y5 = y4?
		je	X5Y5Loop	;yes ->		

CalcResult3:	sub	cx,bp		;Dx4 = x4 - x5
		sub	dx,ax		;Dy4 = y4 - y5

		mov	ax,dx		;ax = Dy4
		imul	di		;dx, ax = Dx3 * Dy4

		xchg	ax,bx		;ax = Dy3
		mov	bp,dx		;bp, bx = Dx3 * Dy4

		imul	cx		;dx, ax = Dx4 * Dy3

		sub	bx,ax
		sbb	bp,dx		;result3 = (Dx3 * Dy4) - (Dx4 * Dy3)
		
		clc			;cyclic ok
		ret

;* reached end of point list, loop back to x2, y2

LoopBack1:	mov	si,TempPtr1
		lodsw
		jmp	ContCyclic1

LoopBack2:	mov	si,TempPtr1
		lodsw
		jmp	ContCyclic2

SlowCyclic	ENDP

;----------------------------------------------------------------------------

;* NullCyclic - null cyclic check
;*
;* pass: )
;* ret : ) Refer to CyclicCheck
;* kill: )

NullCyclic	PROC	NEAR

		xor	ax,ax		;clockwise
		stc			;cyclic error
		ret

NullCyclic	ENDP

;----------------------------------------------------------------------------

;* CalcCircleCRT - calc circle CRT point (unclipped)
;*
;* pass: Xe[0], Ye[0], Ze[0] = point eye co-ords
;* ret : cf = 0 = ok: cx = x crt (crt point may be off screen)
;*                    bx = y crt
;*       cf = 1 = error
;* kill: assume all (except bx, cx, cf)

CalcCircleCRT	PROC	NEAR

		xor	si,si		;index = 0
	
		mov	ax,Xe[0]	;fetch eye co-ords
		mov	bx,Ye[0]
		mov	cx,Ze[0]

		SCALE_V_PYRAMID		;scale viewing pyramid wrt view mode

   		CIRCLE_CRT		;cx = x crt, bx = y crt, cf = error status

		ret

CalcCircleCRT	ENDP

;----------------------------------------------------------------------------

;* XCalcUnclipCRT - calc unclipped CRT co-ords (available externally)
;*
;* pass: Xe[0], Ye[0], Ze[0] = point eye co-ords
;* ret : cf = 0 = ok: cx = x crt (crt co-ords may be off screen)
;*                    bx = y crt
;*       cf = 1 = error
;* kill: assume all (except bx, cx, cf)

XCalcUnclipCRT	PROC	FAR

		xor	si,si		;index = 0
	
		mov	ax,Xe[0]	;fetch eye co-ords
		mov	bx,Ye[0]
		mov	cx,Ze[0]

		SCALE_V_PYRAMID		;scale viewing pyramid wrt view mode

   		CIRCLE_CRT		;cx = x crt, bx = y crt, cf = error status

		ret

XCalcUnclipCRT	ENDP

VISCODE		ENDS

;============================================================================

		END

