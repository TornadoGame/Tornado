;****************************************************************************
;*
;* RWY_TAXI.ASM
;*
;* Draw runways / taxiways for airfields.
;*
;* 05.08.1991 - KJB
;* 14.07.1992 - KJB - Runway lights added (for fog / night modes etc.).
;* 20.07.1992 - KJB - Approach lights added.
;*
;* Runway Notes
;* ------------
;*
;* Runways may be north-south, east-west or run diagonally (45 degrees).
;*
;* Refer to RWY_TAXI.INC for RUNWAY data structure.
;*
;* Taxiway Notes
;* -------------
;*
;* Taxiways use the same data structure as used for town road layouts (refer
;* to TOWNS.ASM). Taxiways are always 64ft wide. Taxiways are not restricted
;* to being drawn near the sector centre (as towns are).
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	DrawRunways
		PUBLIC	DrawTaxiways
EXTRN	ModelMapIndex:WORD		
EXTRN	SctrGameLayer1:BYTE
EXTRN   ILSRangeHi:WORD
		EXTRN	PolyFill:FAR
		EXTRN	LineDraw:FAR
		EXTRN	PolyLine:FAR
		EXTRN	SetPixel:FAR
		EXTRN	CalcOutCodes:NEAR
		EXTRN	PolyClip:NEAR
		EXTRN	QuickLineClip:NEAR
		EXTRN	PolyLineClip:NEAR
		EXTRN	PolyDotClip:NEAR
		EXTRN	DotClip:NEAR

		EXTRN	Night:BYTE
		EXTRN	Fog:BYTE

;============================================================================

		INCLUDE	VISEXTRN.INC
		INCLUDE	VISDATA.INC
		INCLUDE	PALETTES.INC
		INCLUDE	RWY_TAXI.INC
		INCLUDE	\LIB8086\USEFUL.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

;-------------
;* runway data
;-------------

;* sort runway switch (wrt sector scale mode)

SortRunway	DW	SortRunway1	;SEC_SCALE1
		DW	SortRunway2	;SEC_SCALE2
		DW	SortRunway8	;SEC_SCALE8
		DW	SortRunway16	;SEC_SCALE16

;* select end type data wrt runway width

RunwayWidth	DW	OFFSET EndType256	;RWY_WIDTH256
		DW	OFFSET EndType192	;RWY_WIDTH192
		DW	OFFSET EndType128	;RWY_WIDTH128

;* lh and rh x, y offsets for 256ft width runway end types (1/1 scaling)

EndType256	DW	@MID-@128	;xl - end type 0 (180 - 360)
		DW	@MID+@0		;yl
		DW	@MID+@128	;xr
		DW	@MID+@0		;yr

		DW	@MID-@128	;xl - end type 1 (135 - 315)
		DW	@MID-@128	;yl
		DW	@MID+@128	;xr
		DW	@MID+@128	;yr

		DW	@MID+@0		;xl - end type 2 (090 - 270)
		DW	@MID-@128	;yl
		DW	@MID+@0		;xr
		DW	@MID+@128	;yr

		DW	@MID+@128	;xl - end type 3 (045 - 225)
		DW	@MID-@128	;yl
		DW	@MID-@128	;xr
		DW	@MID+@128	;yr

;* lh and rh x, y offsets for 192ft width runway end types (1/1 scaling)

EndType192	DW	@MID-@96	;xl - end type 0 (180 - 360)
		DW	@MID+@0		;yl
		DW	@MID+@96	;xr
		DW	@MID+@0		;yr

		DW	@MID-@96	;xl - end type 1 (135 - 315)
		DW	@MID-@96	;yl
		DW	@MID+@96	;xr
		DW	@MID+@96	;yr

		DW	@MID+@0		;xl - end type 2 (090 - 270)
		DW	@MID-@96	;yl
		DW	@MID+@0		;xr
		DW	@MID+@96	;yr

		DW	@MID+@96	;xl - end type 3 (045 - 225)
		DW	@MID-@96	;yl
		DW	@MID-@96	;xr
		DW	@MID+@96	;yr

;* lh and rh x, y offsets for 128ft width runway end types (1/1 scaling)

EndType128	DW	@MID-@64	;xl - end type 0 (180 - 360)
		DW	@MID+@0		;yl
		DW	@MID+@64	;xr
		DW	@MID+@0		;yr

		DW	@MID-@64	;xl - end type 1 (135 - 315)
		DW	@MID-@64	;yl
		DW	@MID+@64	;xr
		DW	@MID+@64	;yr

		DW	@MID+@0		;xl - end type 2 (090 - 270)
		DW	@MID-@64	;yl
		DW	@MID+@0		;xr
		DW	@MID+@64	;yr

		DW	@MID+@64	;xl - end type 3 (045 - 225)
		DW	@MID-@64	;yl
		DW	@MID-@64	;xr
		DW	@MID+@64	;yr

;--------------
;* taxiway data
;--------------

;* approximation threshold wrt ZFT (max value = 8192)

Z_APPROX_THRES	EQU	8192

;* scan vertex list switch (wrt sector scale mode)

ScanVertexList	DW	ScanVertex1	;SEC_SCALE1
		DW	ScanVertex2	;SEC_SCALE2
		DW	ScanVertex8	;SEC_SCALE8

;* make vertex switch (wrt sector scale mode)

MakeVertex	DW	MakeVertex1	;SEC_SCALE1
		DW	MakeVertex2	;SEC_SCALE2

;* taxiway polygon

TaxiPoly	DB	0,0,0,0,-1

		EVEN

;* lh and rh x, y offsets for 64ft width taxiway end types (1/1 scaling)

EndType64	DW	@MID-@32	;xl - end type 0 (N)
		DW	@MID+@0		;yl
		DW	@MID+@32	;xr
		DW	@MID+@0		;yr

		DW	@MID-@32	;xl - end type 1 (NE)
		DW	@MID+@32	;yl
		DW	@MID+@32	;xr
		DW	@MID-@32	;yr

		DW	@MID+@0		;xl - end type 2 (E)
		DW	@MID+@32	;yl
		DW	@MID+@0		;xr
		DW	@MID-@32	;yr

		DW	@MID+@32	;xl - end type 3 (SE)
		DW	@MID+@32	;yl
		DW	@MID-@32	;xr
		DW	@MID-@32	;yr

		DW	@MID+@32	;xl - end type 4 (S)
		DW	@MID+@0		;yl
		DW	@MID-@32	;xr
		DW	@MID+@0		;yr

		DW	@MID+@32	;xl - end type 5 (SW)
		DW	@MID-@32	;yl
		DW	@MID-@32	;xr
		DW	@MID+@32	;yr

		DW	@MID+@0		;xl - end type 6 (W)
		DW	@MID-@32	;yl
		DW	@MID+@0		;xr
		DW	@MID+@32	;yr

		DW	@MID-@32	;xl - end type 7 (NW)
		DW	@MID-@32	;yl
		DW	@MID+@32	;xr
		DW	@MID+@32	;yr

;-----------------------------------------
;* runway / taxiway / approach lights data
;-----------------------------------------

VertexIndex	DW	0

RwyLightsOn	DB	0		;1 = active runway and (night or fog)

RwyLightCol	DB	0

		EVEN

;* sector sub-division offsets to generate approach light datum points
;*
;*		DW	x offset, y offset	;256ft to left of runway centre
;*		DW	x offset, y offset	;4,096ft from runway end

ApprLightPoints	DW	-1*2,   0*2	;RWY_1836
		DW	 0*2, -16*2
		DW	-1*2,  -1*2	;RWY_1331
		DW	16*2, -16*2
		DW	 0*2,  -1*2	;RWY_0927
		DW	16*2,   0*2
		DW	 1*2,  -1*2	;RWY_0422
		DW	16*2,  16*2

DATA		ENDS

;============================================================================

FEATOBJ1	SEGMENT PARA PUBLIC 'DATA'

FEATOBJ1	ENDS

;============================================================================

VISCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:VISCODE
		ASSUME DS:DATA

;* DrawRunways
;*
;* pass: si -> RUNWAY list (-1 terminated)
;*       SctrScaleMode
;* ret : nothing
;* kill: assume all

DrawRunways	PROC	NEAR

NextRunway:	cmp	RWY_DIR[si],-1	;end of list?
		je	ExitRunways	;yes ->

		mov	RwyLightsOn,0	;assume no lights

;* if last runway in list then assume active runway

		cmp	RWY_REC_SIZE+RWY_DIR[si],-1	;last runway in list?
		jne	LightsOk			;no ->

;* runway lights on if active runway and (night or fog)

		mov	al,Night
		or	al,Fog		;night or fog?
		jz	LightsOk	;no ->

;* runway lights always visible at near range (as are taxiway lights)

		cmp	SctrScaleMode,SEC_SCALE16	;near range?
		jne	LightsOn			;yes ->

;* runway lights less visible if looking at runway "side on"

		cmp	[si].RWY_DIR,RWY_1836	;n-s runway?
		je	CheckNS			;yes ->

		cmp	[si].RWY_DIR,RWY_0927	;e-w runway?
		jne	LightsOk		;no ->

;* e-w runway, check abs(YSecScan - V_VIEW.VP_YSEC) <= 3

CheckEW:	mov	ax,YSecScan
		sub	ax,V_VIEW.VP_YSEC
		ABSV	ax
		cmp	ax,3
		ja	LightsOk

		jmp	LightsOn

;* n-s runway, check abs(XSecScan - V_VIEW.VP_XSEC) <= 3

CheckNS:	mov	ax,XSecScan
		sub	ax,V_VIEW.VP_XSEC
		ABSV	ax
		cmp	ax,3
		ja	LightsOk

;LightsOn:	mov	RwyLightsOn,1	;lights on
LightsOn:	
		mov	bp,ModelMapIndex
		test	SctrGameLayer1[bp],10000000b  ;SECT_ENEMY. Over enemy sector?
        jz @F; --> No! 
		mov	RwyLightsOn,0 ;lights off!
		jmp SkipRwyLightsOn
@@: 
        mov	RwyLightsOn,1	;lights on = 1, The airfield is a friendly. 
		                    ;Show all lights. Assume that at the last minute, they were switched on for me to land!
SkipRwyLightsOn:

LightsOk:	push	si

		mov	bx,SctrScaleMode
		call	SortRunway[bx]

		pop	si

		add	si,RWY_REC_SIZE

		jmp	NextRunway

ExitRunways:	ret

DrawRunways	ENDP

;----------------------------------------------------------------------------

;* SortRunway1 - draw runway (SEC_SCALE1)
;*
;* pass: si -> RUNWAY data block
;* ret : nothing
;* kill: assume all

SortRunway1	PROC	NEAR

		push	si		;store RUNWAY ptr
	
;------------
;* sort end 1
;------------

		mov	bx,RWY_X1[si]	;fetch end 1 x co-ord (0 .. 64)
		shl	bx,1		;0 .. 128
		add	bx,64		;64 .. 192

		mov	di,RWY_Y1[si]	;fetch end 1 y co-ord (0 .. 64)
		shl	di,1		;0 .. 128
		add	di,64		;64 .. 192

		mov	cx,XSX[bx]	
		add	cx,XSY[di]	;XSX + XSY

		mov	dx,YSX[bx]
		add	dx,YSY[di]	;YSX + YSY

		mov	bp,ZSX[bx]
		add	bp,ZSY[di]	;ZSX + ZSY

;* sort pointer to end data wrt runway width and direction

		mov	bx,RWY_WIDTH[si]
		mov	bx,RunwayWidth[bx]
		add	bx,RWY_DIR[si]

		push	bx		;store end data pointer
		
		mov	di,[bx+2]     	;yl
		mov	bx,[bx+0]     	;xl

		mov	ax,cx
		add	ax,XGX[bx]
		add	ax,XGY[di]
		add	ax,XPos1
		mov	Xe[0],ax  	;XPos1 + XSX + XSY + XGX + XGY
		
		mov	ax,dx
		add	ax,YGX[bx]
		add	ax,YGY[di]
		add	ax,YPos1
		mov	Ye[0],ax      	;YPos1 + YSX + YSY + YGX + YGY

		mov	ax,bp
		add	ax,ZGX[bx]
		add	ax,ZGY[di]
		add	ax,ZPos1
		mov	Ze[0],ax 	;ZPos1 + ZSX + ZSY + ZGX + ZGY
		mov	Ze[8],ax	;(preserve for runway lights)

		pop	bx		;restore end data pointer

		mov	di,[bx+6]	;yr
		mov	bx,[bx+4]	;xr

		mov	ax,cx
		add	ax,XGX[bx]
		add	ax,XGY[di]
		add	ax,XPos1
		mov	Xe[6],ax	;XPos1 + XSX + XSY + XGX + XGY
		
		mov	ax,dx
		add	ax,YGX[bx]
		add	ax,YGY[di]
		add	ax,YPos1
		mov	Ye[6],ax       	;YPos1 + YSX + YSY + YGX + YGY

		mov	ax,bp
		add	ax,ZGX[bx]
		add	ax,ZGY[di]
		add	ax,ZPos1
		mov	Ze[6],ax	;ZPos1 + ZSX + ZSY + ZGX + ZGY
		mov	Ze[14],ax	;(preserve for runway lights)

;------------
;* sort end 2
;------------

		mov	bx,RWY_X2[si]	;fetch end 2 x co-ord (0 .. 64)
		shl	bx,1		;0 .. 128
		add	bx,64		;64 .. 192

		mov	di,RWY_Y2[si]	;fetch end 2 y co-ord (0 .. 64)
		shl	di,1		;0 .. 128
		add	di,64		;64 .. 192

		mov	cx,XSX[bx]	
		add	cx,XSY[di]	;XSX + XSY

		mov	dx,YSX[bx]
		add	dx,YSY[di]	;YSX + YSY

		mov	bp,ZSX[bx]
		add	bp,ZSY[di]	;ZSX + ZSY

;* sort pointer to end data wrt runway width and direction

		mov	bx,RWY_WIDTH[si]
		mov	bx,RunwayWidth[bx]
		add	bx,RWY_DIR[si]

		push	bx		;store end data pointer
		
		mov	di,[bx+2]     	;yl
		mov	bx,[bx+0]     	;xl

		mov	ax,cx
		add	ax,XGX[bx]
		add	ax,XGY[di]
		add	ax,XPos1
		mov	Xe[2],ax  	;XPos1 + XSX + XSY + XGX + XGY
		
		mov	ax,dx
		add	ax,YGX[bx]
		add	ax,YGY[di]
		add	ax,YPos1
		mov	Ye[2],ax      	;YPos1 + YSX + YSY + YGX + YGY

		mov	ax,bp
		add	ax,ZGX[bx]
		add	ax,ZGY[di]
		add	ax,ZPos1
		mov	Ze[2],ax 	;ZPos1 + ZSX + ZSY + ZGX + ZGY
		mov	Ze[10],ax	;(preserve for runway lights)

		pop	bx		;restore end data pointer

		mov	di,[bx+6]	;yr
		mov	bx,[bx+4]	;xr

		mov	ax,cx
		add	ax,XGX[bx]
		add	ax,XGY[di]
		add	ax,XPos1
		mov	Xe[4],ax	;XPos1 + XSX + XSY + XGX + XGY
		
		mov	ax,dx
		add	ax,YGX[bx]
		add	ax,YGY[di]
		add	ax,YPos1
		mov	Ye[4],ax       	;YPos1 + YSX + YSY + YGX + YGY

		mov	ax,bp
		add	ax,ZGX[bx]
		add	ax,ZGY[di]
		add	ax,ZPos1
		mov	Ze[4],ax	;ZPos1 + ZSX + ZSY + ZGX + ZGY
		mov	Ze[12],ax	;(preserve for runway lights)

;--------------------------
;* draw runway (if visible)
;--------------------------

		mov	si,6
		call	CalcOutCodes
		jc	ContRunway1	;runway non-visible ->

		mov	si,OFFSET StndPoly4
		mov	di,OFFSET CrtBuffer
		call	PolyClip
		jc	ContRunway1	;runway non-visible ->

		mov	al,COL_RWY1
		mov	si,OFFSET CrtBuffer
		call	PolyFill

		call	DrawRwyLights1

;----------------------
;* draw approach lights
;----------------------

ContRunway1:	pop	si		;restore RUNWAY ptr

		test	RwyLightsOn,1	;runway lights on?
		_JZ	ExitRunway1	;no ->

;----------------------------
;* sort approach lights end 1
;----------------------------

		push	si		;store RUNWAY ptr

		mov	bx,RWY_DIR[si]

		mov	di,RWY_Y1[si]	;fetch end 1 y co-ord (0 .. 64)
		shl	di,1		;0 .. 128
		add	di,64		;64 .. 192

		mov	si,RWY_X1[si]	;fetch end 1 x co-ord (0 .. 64)
		shl	si,1		;0 .. 128
		add	si,64		;64 .. 192

		mov	cx,si
		mov	dx,di

		mov	ax,XSX[si]	
		add	ax,XSY[di]
		add	ax,XPos1     	;XPos1 + XSX + XSY
		mov	Xe[252],ax

		mov	ax,YSX[si]
		add	ax,YSY[di]
		add	ax,YPos1	;YPos1 + YSX + YSY
		mov	Ye[252],ax

		mov	ax,ZSX[si]
		add	ax,ZSY[di]
		add	ax,ZPos1	;ZPos1 + ZSX + ZSY
		mov	Ze[252],ax

		add	si,ApprLightPoints[bx+0]
		add	di,ApprLightPoints[bx+2]

		mov	ax,XSX[si]	
		add	ax,XSY[di]
		add	ax,XPos1     	;XPos1 + XSX + XSY
		mov	Xe[248],ax

		mov	ax,YSX[si]
		add	ax,YSY[di]
		add	ax,YPos1	;YPos1 + YSX + YSY
		mov	Ye[248],ax

		mov	ax,ZSX[si]
		add	ax,ZSY[di]
		add	ax,ZPos1	;ZPos1 + ZSX + ZSY
		mov	Ze[248],ax

		mov	si,cx
		mov	di,dx

		mov	ax,ApprLightPoints[bx+0]
		neg	ax
		add	si,ax
		mov	ax,ApprLightPoints[bx+2]
		neg	ax
		add	di,ax

		mov	ax,XSX[si]	
		add	ax,XSY[di]
		add	ax,XPos1     	;XPos1 + XSX + XSY
		mov	Xe[250],ax

		mov	ax,YSX[si]
		add	ax,YSY[di]
		add	ax,YPos1	;YPos1 + YSX + YSY
		mov	Ye[250],ax

		mov	ax,ZSX[si]
		add	ax,ZSY[di]
		add	ax,ZPos1	;ZPos1 + ZSX + ZSY
		mov	Ze[250],ax

		mov	si,cx
		mov	di,dx

		add	si,ApprLightPoints[bx+4]
		add	di,ApprLightPoints[bx+6]

		mov	ax,XSX[si]	
		add	ax,XSY[di]
		add	ax,XPos1     	;XPos1 + XSX + XSY
		mov	Xe[254],ax

		mov	ax,YSX[si]
		add	ax,YSY[di]
		add	ax,YPos1	;YPos1 + YSX + YSY
		mov	Ye[254],ax

		mov	ax,ZSX[si]
		add	ax,ZSY[di]
		add	ax,ZPos1	;ZPos1 + ZSX + ZSY
		mov	Ze[254],ax

		call	DrawApprLights1

;----------------------------
;* sort approach lights end 2
;----------------------------

		pop	si		;restore RUNWAY ptr

		mov	bx,RWY_DIR[si]

		mov	di,RWY_Y2[si]	;fetch end 1 y co-ord (0 .. 64)
		shl	di,1		;0 .. 128
		add	di,64		;64 .. 192

		mov	si,RWY_X2[si]	;fetch end 1 x co-ord (0 .. 64)
		shl	si,1		;0 .. 128
		add	si,64		;64 .. 192

		mov	cx,si
		mov	dx,di

		mov	ax,XSX[si]	
		add	ax,XSY[di]
		add	ax,XPos1     	;XPos1 + XSX + XSY
		mov	Xe[252],ax

		mov	ax,YSX[si]
		add	ax,YSY[di]
		add	ax,YPos1	;YPos1 + YSX + YSY
		mov	Ye[252],ax

		mov	ax,ZSX[si]
		add	ax,ZSY[di]
		add	ax,ZPos1	;ZPos1 + ZSX + ZSY
		mov	Ze[252],ax

		mov	ax,ApprLightPoints[bx+0]
		neg	ax
		add	si,ax
		mov	ax,ApprLightPoints[bx+2]
		neg	ax
		add	di,ax

		mov	ax,XSX[si]	
		add	ax,XSY[di]
		add	ax,XPos1     	;XPos1 + XSX + XSY
		mov	Xe[248],ax

		mov	ax,YSX[si]
		add	ax,YSY[di]
		add	ax,YPos1	;YPos1 + YSX + YSY
		mov	Ye[248],ax

		mov	ax,ZSX[si]
		add	ax,ZSY[di]
		add	ax,ZPos1	;ZPos1 + ZSX + ZSY
		mov	Ze[248],ax

		mov	si,cx
		mov	di,dx

		add	si,ApprLightPoints[bx+0]
		add	di,ApprLightPoints[bx+2]

		mov	ax,XSX[si]	
		add	ax,XSY[di]
		add	ax,XPos1     	;XPos1 + XSX + XSY
		mov	Xe[250],ax

		mov	ax,YSX[si]
		add	ax,YSY[di]
		add	ax,YPos1	;YPos1 + YSX + YSY
		mov	Ye[250],ax

		mov	ax,ZSX[si]
		add	ax,ZSY[di]
		add	ax,ZPos1	;ZPos1 + ZSX + ZSY
		mov	Ze[250],ax

		mov	si,cx
		mov	di,dx

		mov	ax,ApprLightPoints[bx+4]
		neg	ax
		add	si,ax
		mov	ax,ApprLightPoints[bx+6]
		neg	ax
		add	di,ax

		mov	ax,XSX[si]	
		add	ax,XSY[di]
		add	ax,XPos1     	;XPos1 + XSX + XSY
		mov	Xe[254],ax

		mov	ax,YSX[si]
		add	ax,YSY[di]
		add	ax,YPos1	;YPos1 + YSX + YSY
		mov	Ye[254],ax

		mov	ax,ZSX[si]
		add	ax,ZSY[di]
		add	ax,ZPos1	;ZPos1 + ZSX + ZSY
		mov	Ze[254],ax

		call	DrawApprLights1

ExitRunway1:	ret

SortRunway1	ENDP

;----------------------------------------------------------------------------

;* SortRunway2 - draw runway (SEC_SCALE2)
;*
;* pass: si -> RUNWAY data block
;* ret : nothing
;* kill: assume all

SortRunway2	PROC	NEAR

		push	si		;store RUNWAY ptr
	
;------------
;* sort end 1
;------------

		mov	bx,RWY_X1[si]	;fetch end 1 x co-ord (0 .. 64)
		shl	bx,1		;0 .. 128
		add	bx,64		;64 .. 192

		mov	di,RWY_Y1[si]	;fetch end 1 y co-ord (0 .. 64)
		shl	di,1		;0 .. 128
		add	di,64		;64 .. 192

		mov	cx,XSX[bx]	
		add	cx,XSY[di]	;XSX + XSY

		mov	dx,YSX[bx]
		add	dx,YSY[di]	;YSX + YSY

		mov	bp,ZSX[bx]
		add	bp,ZSY[di]	;ZSX + ZSY

;* sort pointer to end data wrt runway width and direction

		mov	bx,RWY_WIDTH[si]
		mov	bx,RunwayWidth[bx]
		add	bx,RWY_DIR[si]

		push	bx		;store end data pointer
		
		mov	di,[bx+2]     	;yl
		mov	bx,[bx+0]     	;xl

		mov	ax,cx
		add	ax,XGX[bx]
		add	ax,XGY[di]
		sar	ax,1		;/2 scaling
		add	ax,XPos2
		mov	Xe[0],ax  	;XPos2 + XSX + XSY + XGX + XGY
		
		mov	ax,dx
		add	ax,YGX[bx]
		add	ax,YGY[di]
		sar	ax,1		;/2 scaling
		add	ax,YPos2
		mov	Ye[0],ax      	;YPos2 + YSX + YSY + YGX + YGY

		mov	ax,bp
		add	ax,ZGX[bx]
		add	ax,ZGY[di]
		sar	ax,1		;/2 scaling
		add	ax,ZPos2
		mov	Ze[0],ax 	;ZPos2 + ZSX + ZSY + ZGX + ZGY
		mov	Ze[8],ax	;(preserve for runway lights)

		pop	bx		;restore end data pointer

		mov	di,[bx+6]	;yr
		mov	bx,[bx+4]	;xr

		mov	ax,cx
		add	ax,XGX[bx]
		add	ax,XGY[di]
		sar	ax,1		;/2 scaling
		add	ax,XPos2
		mov	Xe[6],ax	;XPos2 + XSX + XSY + XGX + XGY
		
		mov	ax,dx
		add	ax,YGX[bx]
		add	ax,YGY[di]
		sar	ax,1		;/2 scaling
		add	ax,YPos2
		mov	Ye[6],ax       	;YPos2 + YSX + YSY + YGX + YGY

		mov	ax,bp
		add	ax,ZGX[bx]
		add	ax,ZGY[di]
		sar	ax,1		;/2 scaling
		add	ax,ZPos2
		mov	Ze[6],ax	;ZPos2 + ZSX + ZSY + ZGX + ZGY
		mov	Ze[14],ax	;(preserve for runway lights)

;------------
;* sort end 2
;------------

		mov	bx,RWY_X2[si]	;fetch end 2 x co-ord (0 .. 64)
		shl	bx,1		;0 .. 128
		add	bx,64		;64 .. 192

		mov	di,RWY_Y2[si]	;fetch end 2 y co-ord (0 .. 64)
		shl	di,1		;0 .. 128
		add	di,64		;64 .. 192

		mov	cx,XSX[bx]	
		add	cx,XSY[di]	;XSX + XSY

		mov	dx,YSX[bx]
		add	dx,YSY[di]	;YSX + YSY

		mov	bp,ZSX[bx]
		add	bp,ZSY[di]	;ZSX + ZSY

;* sort pointer to end data wrt runway width and direction

		mov	bx,RWY_WIDTH[si]
		mov	bx,RunwayWidth[bx]
		add	bx,RWY_DIR[si]

		push	bx		;store end data pointer
		
		mov	di,[bx+2]     	;yl
		mov	bx,[bx+0]     	;xl

		mov	ax,cx
		add	ax,XGX[bx]
		add	ax,XGY[di]
		sar	ax,1		;/2 scaling
		add	ax,XPos2
		mov	Xe[2],ax  	;XPos2 + XSX + XSY + XGX + XGY
		
		mov	ax,dx
		add	ax,YGX[bx]
		add	ax,YGY[di]
		sar	ax,1		;/2 scaling
		add	ax,YPos2
		mov	Ye[2],ax      	;YPos2 + YSX + YSY + YGX + YGY

		mov	ax,bp
		add	ax,ZGX[bx]
		add	ax,ZGY[di]
		sar	ax,1		;/2 scaling
		add	ax,ZPos2
		mov	Ze[2],ax 	;ZPos2 + ZSX + ZSY + ZGX + ZGY
		mov	Ze[10],ax	;(preserve for runway lights)

		pop	bx		;restore end data pointer

		mov	di,[bx+6]	;yr
		mov	bx,[bx+4]	;xr

		mov	ax,cx
		add	ax,XGX[bx]
		add	ax,XGY[di]
		sar	ax,1		;/2 scaling
		add	ax,XPos2
		mov	Xe[4],ax	;XPos2 + XSX + XSY + XGX + XGY
		
		mov	ax,dx
		add	ax,YGX[bx]
		add	ax,YGY[di]
		sar	ax,1		;/2 scaling
		add	ax,YPos2
		mov	Ye[4],ax       	;YPos2 + YSX + YSY + YGX + YGY

		mov	ax,bp
		add	ax,ZGX[bx]
		add	ax,ZGY[di]
		sar	ax,1		;/2 scaling
		add	ax,ZPos2
		mov	Ze[4],ax	;ZPos2 + ZSX + ZSY + ZGX + ZGY
		mov	Ze[12],ax	;(preserve for runway lights)

;--------------------------
;* draw runway (if visible)
;--------------------------

		mov	si,6
		call	CalcOutCodes
		jc	ContRunway2	;runway non-visible ->

		mov	si,OFFSET StndPoly4
		mov	di,OFFSET CrtBuffer
		call	PolyClip
		jc	ContRunway2	;runway non-visible ->

		mov	al,COL_RWY1
		mov	si,OFFSET CrtBuffer
		call	PolyFill

		call	DrawRwyLights2

;----------------------
;* draw approach lights
;----------------------

ContRunway2:	pop	si		;restore RUNWAY ptr

		test	RwyLightsOn,1	;runway lights on?
		_JZ	ExitRunway2	;no ->

;----------------------------
;* sort approach lights end 1
;----------------------------

		push	si		;store RUNWAY ptr

		mov	bx,RWY_DIR[si]

		mov	di,RWY_Y1[si]	;fetch end 1 y co-ord (0 .. 64)
		shl	di,1		;0 .. 128
		add	di,64		;64 .. 192

		mov	si,RWY_X1[si]	;fetch end 1 x co-ord (0 .. 64)
		shl	si,1		;0 .. 128
		add	si,64		;64 .. 192

		mov	cx,si
		mov	dx,di

		mov	ax,XSX[si]	
		add	ax,XSY[di]
		sar	ax,1		;/2 scaling
		add	ax,XPos2     	;XPos2 + XSX + XSY
		mov	Xe[252],ax

		mov	ax,YSX[si]
		add	ax,YSY[di]
		sar	ax,1		;/2 scaling
		add	ax,YPos2	;YPos2 + YSX + YSY
		mov	Ye[252],ax

		mov	ax,ZSX[si]
		add	ax,ZSY[di]
		sar	ax,1		;/2 scaling
		add	ax,ZPos2	;ZPos2 + ZSX + ZSY
		mov	Ze[252],ax

		add	si,ApprLightPoints[bx+0]
		add	di,ApprLightPoints[bx+2]

		mov	ax,XSX[si]	
		add	ax,XSY[di]
		sar	ax,1		;/2 scaling
		add	ax,XPos2     	;XPos2 + XSX + XSY
		mov	Xe[248],ax

		mov	ax,YSX[si]
		add	ax,YSY[di]
		sar	ax,1		;/2 scaling
		add	ax,YPos2	;YPos2 + YSX + YSY
		mov	Ye[248],ax

		mov	ax,ZSX[si]
		add	ax,ZSY[di]
		sar	ax,1		;/2 scaling
		add	ax,ZPos2	;ZPos2 + ZSX + ZSY
		mov	Ze[248],ax

		mov	si,cx
		mov	di,dx

		mov	ax,ApprLightPoints[bx+0]
		neg	ax
		add	si,ax
		mov	ax,ApprLightPoints[bx+2]
		neg	ax
		add	di,ax

		mov	ax,XSX[si]	
		add	ax,XSY[di]
		sar	ax,1		;/2 scaling
		add	ax,XPos2     	;XPos2 + XSX + XSY
		mov	Xe[250],ax

		mov	ax,YSX[si]
		add	ax,YSY[di]
		sar	ax,1		;/2 scaling
		add	ax,YPos2	;YPos2 + YSX + YSY
		mov	Ye[250],ax

		mov	ax,ZSX[si]
		add	ax,ZSY[di]
		sar	ax,1		;/2 scaling
		add	ax,ZPos2	;ZPos2 + ZSX + ZSY
		mov	Ze[250],ax

		mov	si,cx
		mov	di,dx

		add	si,ApprLightPoints[bx+4]
		add	di,ApprLightPoints[bx+6]

		mov	ax,XSX[si]	
		add	ax,XSY[di]
		sar	ax,1		;/2 scaling
		add	ax,XPos2     	;XPos2 + XSX + XSY
		mov	Xe[254],ax

		mov	ax,YSX[si]
		add	ax,YSY[di]
		sar	ax,1		;/2 scaling
		add	ax,YPos2	;YPos2 + YSX + YSY
		mov	Ye[254],ax

		mov	ax,ZSX[si]
		add	ax,ZSY[di]
		sar	ax,1		;/2 scaling
		add	ax,ZPos2	;ZPos2 + ZSX + ZSY
		mov	Ze[254],ax

		call	DrawApprLights2

;----------------------------
;* sort approach lights end 2
;----------------------------

		pop	si		;restore RUNWAY ptr

		mov	bx,RWY_DIR[si]

		mov	di,RWY_Y2[si]	;fetch end 1 y co-ord (0 .. 64)
		shl	di,1		;0 .. 128
		add	di,64		;64 .. 192

		mov	si,RWY_X2[si]	;fetch end 1 x co-ord (0 .. 64)
		shl	si,1		;0 .. 128
		add	si,64		;64 .. 192

		mov	cx,si
		mov	dx,di

		mov	ax,XSX[si]	
		add	ax,XSY[di]
		sar	ax,1		;/2 scaling
		add	ax,XPos2     	;XPos2 + XSX + XSY
		mov	Xe[252],ax

		mov	ax,YSX[si]
		add	ax,YSY[di]
		sar	ax,1		;/2 scaling
		add	ax,YPos2	;YPos2 + YSX + YSY
		mov	Ye[252],ax

		mov	ax,ZSX[si]
		add	ax,ZSY[di]
		sar	ax,1		;/2 scaling
		add	ax,ZPos2	;ZPos2 + ZSX + ZSY
		mov	Ze[252],ax

		mov	ax,ApprLightPoints[bx+0]
		neg	ax
		add	si,ax
		mov	ax,ApprLightPoints[bx+2]
		neg	ax
		add	di,ax

		mov	ax,XSX[si]	
		add	ax,XSY[di]
		sar	ax,1		;/2 scaling
		add	ax,XPos2     	;XPos2 + XSX + XSY
		mov	Xe[248],ax

		mov	ax,YSX[si]
		add	ax,YSY[di]
		sar	ax,1		;/2 scaling
		add	ax,YPos2	;YPos2 + YSX + YSY
		mov	Ye[248],ax

		mov	ax,ZSX[si]
		add	ax,ZSY[di]
		sar	ax,1		;/2 scaling
		add	ax,ZPos2	;ZPos2 + ZSX + ZSY
		mov	Ze[248],ax

		mov	si,cx
		mov	di,dx

		add	si,ApprLightPoints[bx+0]
		add	di,ApprLightPoints[bx+2]

		mov	ax,XSX[si]	
		add	ax,XSY[di]
		sar	ax,1		;/2 scaling
		add	ax,XPos2     	;XPos2 + XSX + XSY
		mov	Xe[250],ax

		mov	ax,YSX[si]
		add	ax,YSY[di]
		sar	ax,1		;/2 scaling
		add	ax,YPos2	;YPos2 + YSX + YSY
		mov	Ye[250],ax

		mov	ax,ZSX[si]
		add	ax,ZSY[di]
		sar	ax,1		;/2 scaling
		add	ax,ZPos2	;ZPos2 + ZSX + ZSY
		mov	Ze[250],ax

		mov	si,cx
		mov	di,dx

		mov	ax,ApprLightPoints[bx+4]
		neg	ax
		add	si,ax
		mov	ax,ApprLightPoints[bx+6]
		neg	ax
		add	di,ax

		mov	ax,XSX[si]	
		add	ax,XSY[di]
		sar	ax,1		;/2 scaling
		add	ax,XPos2     	;XPos2 + XSX + XSY
		mov	Xe[254],ax

		mov	ax,YSX[si]
		add	ax,YSY[di]
		sar	ax,1		;/2 scaling
		add	ax,YPos2	;YPos2 + YSX + YSY
		mov	Ye[254],ax

		mov	ax,ZSX[si]
		add	ax,ZSY[di]
		sar	ax,1		;/2 scaling
		add	ax,ZPos2	;ZPos2 + ZSX + ZSY
		mov	Ze[254],ax

		call	DrawApprLights2

ExitRunway2:	ret

SortRunway2	ENDP

;----------------------------------------------------------------------------

;* SortRunway8 - draw runway (SEC_SCALE8)
;*
;* pass: si -> RUNWAY data block
;* ret : nothing
;* kill: assume all

SortRunway8	PROC	NEAR

		push	si		;store RUNWAY ptr
	
;------------
;* sort end 1
;------------

		mov	bx,RWY_X1[si]	;fetch end 1 x co-ord (0 .. 64)
		shl	bx,1		;0 .. 128
		add	bx,64		;64 .. 192

		mov	di,RWY_Y1[si]	;fetch end 1 y co-ord (0 .. 64)
		shl	di,1		;0 .. 128
		add	di,64		;64 .. 192

		mov	cx,XSX[bx]	
		add	cx,XSY[di]	;XSX + XSY

		mov	dx,YSX[bx]
		add	dx,YSY[di]	;YSX + YSY

		mov	bp,ZSX[bx]
		add	bp,ZSY[di]	;ZSX + ZSY

;* sort pointer to end data wrt runway width and direction

		mov	bx,RWY_WIDTH[si]
		mov	bx,RunwayWidth[bx]
		add	bx,RWY_DIR[si]

		push	bx		;store end data pointer
		
		mov	di,[bx+2]     	;yl
		mov	bx,[bx+0]     	;xl

		mov	ax,cx
		add	ax,XGX[bx]
		add	ax,XGY[di]
		sar	ax,1
		sar	ax,1
		sar	ax,1		;/8 scaling
		add	ax,XPos8
		mov	Xe[0],ax  	;XPos8 + XSX + XSY + XGX + XGY
		
		mov	ax,dx
		add	ax,YGX[bx]
		add	ax,YGY[di]
		sar	ax,1
		sar	ax,1
		sar	ax,1		;/8 scaling
		add	ax,YPos8
		mov	Ye[0],ax      	;YPos8 + YSX + YSY + YGX + YGY

		mov	ax,bp
		add	ax,ZGX[bx]
		add	ax,ZGY[di]
		sar	ax,1
		sar	ax,1
		sar	ax,1		;/8 scaling
		add	ax,ZPos8
		mov	Ze[0],ax 	;ZPos8 + ZSX + ZSY + ZGX + ZGY
		mov	Ze[8],ax	;(preserve for runway lights)

		pop	bx		;restore end data pointer

		mov	di,[bx+6]	;yr
		mov	bx,[bx+4]	;xr

		mov	ax,cx
		add	ax,XGX[bx]
		add	ax,XGY[di]
		sar	ax,1
		sar	ax,1
		sar	ax,1		;/8 scaling
		add	ax,XPos8
		mov	Xe[6],ax	;XPos8 + XSX + XSY + XGX + XGY
		
		mov	ax,dx
		add	ax,YGX[bx]
		add	ax,YGY[di]
		sar	ax,1
		sar	ax,1
		sar	ax,1		;/8 scaling
		add	ax,YPos8
		mov	Ye[6],ax       	;YPos8 + YSX + YSY + YGX + YGY

		mov	ax,bp
		add	ax,ZGX[bx]
		add	ax,ZGY[di]
		sar	ax,1
		sar	ax,1
		sar	ax,1		;/8 scaling
		add	ax,ZPos8
		mov	Ze[6],ax	;ZPos8 + ZSX + ZSY + ZGX + ZGY
		mov	Ze[14],ax	;(preserve for runway lights)

;------------
;* sort end 2
;------------

		mov	bx,RWY_X2[si]	;fetch end 2 x co-ord (0 .. 64)
		shl	bx,1		;0 .. 128
		add	bx,64		;64 .. 192

		mov	di,RWY_Y2[si]	;fetch end 2 y co-ord (0 .. 64)
		shl	di,1		;0 .. 128
		add	di,64		;64 .. 192

		mov	cx,XSX[bx]	
		add	cx,XSY[di]	;XSX + XSY

		mov	dx,YSX[bx]
		add	dx,YSY[di]	;YSX + YSY

		mov	bp,ZSX[bx]
		add	bp,ZSY[di]	;ZSX + ZSY

;* sort pointer to end data wrt runway width and direction

		mov	bx,RWY_WIDTH[si]
		mov	bx,RunwayWidth[bx]
		add	bx,RWY_DIR[si]

		push	bx		;store end data pointer
		
		mov	di,[bx+2]     	;yl
		mov	bx,[bx+0]     	;xl

		mov	ax,cx
		add	ax,XGX[bx]
		add	ax,XGY[di]
		sar	ax,1
		sar	ax,1
		sar	ax,1		;/8 scaling
		add	ax,XPos8
		mov	Xe[2],ax  	;XPos8 + XSX + XSY + XGX + XGY
		
		mov	ax,dx
		add	ax,YGX[bx]
		add	ax,YGY[di]
		sar	ax,1
		sar	ax,1
		sar	ax,1		;/8 scaling
		add	ax,YPos8
		mov	Ye[2],ax      	;YPos8 + YSX + YSY + YGX + YGY

		mov	ax,bp
		add	ax,ZGX[bx]
		add	ax,ZGY[di]
		sar	ax,1
		sar	ax,1
		sar	ax,1		;/8 scaling
		add	ax,ZPos8
		mov	Ze[2],ax 	;ZPos8 + ZSX + ZSY + ZGX + ZGY
		mov	Ze[10],ax	;(preserve for runway lights)

		pop	bx		;restore end data pointer

		mov	di,[bx+6]	;yr
		mov	bx,[bx+4]	;xr

		mov	ax,cx
		add	ax,XGX[bx]
		add	ax,XGY[di]
		sar	ax,1
		sar	ax,1
		sar	ax,1		;/8 scaling
		add	ax,XPos8
		mov	Xe[4],ax	;XPos8 + XSX + XSY + XGX + XGY
		
		mov	ax,dx
		add	ax,YGX[bx]
		add	ax,YGY[di]
		sar	ax,1
		sar	ax,1
		sar	ax,1		;/8 scaling
		add	ax,YPos8
		mov	Ye[4],ax       	;YPos8 + YSX + YSY + YGX + YGY

		mov	ax,bp
		add	ax,ZGX[bx]
		add	ax,ZGY[di]
		sar	ax,1
		sar	ax,1
		sar	ax,1		;/8 scaling
		add	ax,ZPos8
		mov	Ze[4],ax	;ZPos8 + ZSX + ZSY + ZGX + ZGY
		mov	Ze[12],ax	;(preserve for runway lights)

;--------------------------
;* draw runway (if visible)
;--------------------------

		mov	si,6
		call	CalcOutCodes
		jc	ContRunway8	;runway non-visible ->

		mov	si,OFFSET StndPoly4
		mov	di,OFFSET CrtBuffer
		call	PolyClip
		jc	ContRunway8	;runway non-visible ->

		mov	al,COL_RWY1
		mov	si,OFFSET CrtBuffer
		call	PolyFill

		call	DrawRwyLights8

;----------------------
;* draw approach lights
;----------------------

ContRunway8:	pop	si		;restore RUNWAY ptr

		test	RwyLightsOn,1	;runway lights on?
		_JZ	ExitRunway8	;no ->

;----------------------------
;* sort approach lights end 1
;----------------------------

		push	si		;store RUNWAY ptr

		mov	bx,RWY_DIR[si]

		mov	di,RWY_Y1[si]	;fetch end 1 y co-ord (0 .. 64)
		shl	di,1		;0 .. 128
		add	di,64		;64 .. 192

		mov	si,RWY_X1[si]	;fetch end 1 x co-ord (0 .. 64)
		shl	si,1		;0 .. 128
		add	si,64		;64 .. 192

		mov	cx,si
		mov	dx,di

		mov	ax,XSX[si]	
		add	ax,XSY[di]
		sar	ax,1
		sar	ax,1
		sar	ax,1		;/8 scaling
		add	ax,XPos8     	;XPos8 + XSX + XSY
		mov	Xe[252],ax

		mov	ax,YSX[si]
		add	ax,YSY[di]
		sar	ax,1
		sar	ax,1
		sar	ax,1		;/8 scaling
		add	ax,YPos8	;YPos8 + YSX + YSY
		mov	Ye[252],ax

		mov	ax,ZSX[si]
		add	ax,ZSY[di]
		sar	ax,1
		sar	ax,1
		sar	ax,1		;/8 scaling
		add	ax,ZPos8	;ZPos8 + ZSX + ZSY
		mov	Ze[252],ax

		add	si,ApprLightPoints[bx+0]
		add	di,ApprLightPoints[bx+2]

		mov	ax,XSX[si]	
		add	ax,XSY[di]
		sar	ax,1
		sar	ax,1
		sar	ax,1		;/8 scaling
		add	ax,XPos8     	;XPos8 + XSX + XSY
		mov	Xe[248],ax

		mov	ax,YSX[si]
		add	ax,YSY[di]
		sar	ax,1
		sar	ax,1
		sar	ax,1		;/8 scaling
		add	ax,YPos8	;YPos8 + YSX + YSY
		mov	Ye[248],ax

		mov	ax,ZSX[si]
		add	ax,ZSY[di]
		sar	ax,1
		sar	ax,1
		sar	ax,1		;/8 scaling
		add	ax,ZPos8	;ZPos8 + ZSX + ZSY
		mov	Ze[248],ax

		mov	si,cx
		mov	di,dx

		mov	ax,ApprLightPoints[bx+0]
		neg	ax
		add	si,ax
		mov	ax,ApprLightPoints[bx+2]
		neg	ax
		add	di,ax

		mov	ax,XSX[si]	
		add	ax,XSY[di]
		sar	ax,1
		sar	ax,1
		sar	ax,1		;/8 scaling
		add	ax,XPos8     	;XPos8 + XSX + XSY
		mov	Xe[250],ax

		mov	ax,YSX[si]
		add	ax,YSY[di]
		sar	ax,1
		sar	ax,1
		sar	ax,1		;/8 scaling
		add	ax,YPos8	;YPos8 + YSX + YSY
		mov	Ye[250],ax

		mov	ax,ZSX[si]
		add	ax,ZSY[di]
		sar	ax,1
		sar	ax,1
		sar	ax,1		;/8 scaling
		add	ax,ZPos8	;ZPos8 + ZSX + ZSY
		mov	Ze[250],ax

		mov	si,cx
		mov	di,dx

		add	si,ApprLightPoints[bx+4]
		add	di,ApprLightPoints[bx+6]

		mov	ax,XSX[si]	
		add	ax,XSY[di]
		sar	ax,1
		sar	ax,1
		sar	ax,1		;/8 scaling
		add	ax,XPos8     	;XPos8 + XSX + XSY
		mov	Xe[254],ax

		mov	ax,YSX[si]
		add	ax,YSY[di]
		sar	ax,1
		sar	ax,1
		sar	ax,1		;/8 scaling
		add	ax,YPos8	;YPos8 + YSX + YSY
		mov	Ye[254],ax

		mov	ax,ZSX[si]
		add	ax,ZSY[di]
		sar	ax,1
		sar	ax,1
		sar	ax,1		;/8 scaling
		add	ax,ZPos8	;ZPos8 + ZSX + ZSY
		mov	Ze[254],ax

		call	DrawApprLights8

;----------------------------
;* sort approach lights end 2
;----------------------------

		pop	si		;restore RUNWAY ptr

		mov	bx,RWY_DIR[si]

		mov	di,RWY_Y2[si]	;fetch end 1 y co-ord (0 .. 64)
		shl	di,1		;0 .. 128
		add	di,64		;64 .. 192

		mov	si,RWY_X2[si]	;fetch end 1 x co-ord (0 .. 64)
		shl	si,1		;0 .. 128
		add	si,64		;64 .. 192

		mov	cx,si
		mov	dx,di

		mov	ax,XSX[si]	
		add	ax,XSY[di]
		sar	ax,1
		sar	ax,1
		sar	ax,1		;/8 scaling
		add	ax,XPos8     	;XPos8 + XSX + XSY
		mov	Xe[252],ax

		mov	ax,YSX[si]
		add	ax,YSY[di]
		sar	ax,1
		sar	ax,1
		sar	ax,1		;/8 scaling
		add	ax,YPos8	;YPos8 + YSX + YSY
		mov	Ye[252],ax

		mov	ax,ZSX[si]
		add	ax,ZSY[di]
		sar	ax,1
		sar	ax,1
		sar	ax,1		;/8 scaling
		add	ax,ZPos8	;ZPos8 + ZSX + ZSY
		mov	Ze[252],ax

		mov	ax,ApprLightPoints[bx+0]
		neg	ax
		add	si,ax
		mov	ax,ApprLightPoints[bx+2]
		neg	ax
		add	di,ax

		mov	ax,XSX[si]	
		add	ax,XSY[di]
		sar	ax,1
		sar	ax,1
		sar	ax,1		;/8 scaling
		add	ax,XPos8     	;XPos8 + XSX + XSY
		mov	Xe[248],ax

		mov	ax,YSX[si]
		add	ax,YSY[di]
		sar	ax,1
		sar	ax,1
		sar	ax,1		;/8 scaling
		add	ax,YPos8	;YPos8 + YSX + YSY
		mov	Ye[248],ax

		mov	ax,ZSX[si]
		add	ax,ZSY[di]
		sar	ax,1
		sar	ax,1
		sar	ax,1		;/8 scaling
		add	ax,ZPos8	;ZPos8 + ZSX + ZSY
		mov	Ze[248],ax

		mov	si,cx
		mov	di,dx

		add	si,ApprLightPoints[bx+0]
		add	di,ApprLightPoints[bx+2]

		mov	ax,XSX[si]	
		add	ax,XSY[di]
		sar	ax,1
		sar	ax,1
		sar	ax,1		;/8 scaling
		add	ax,XPos8     	;XPos8 + XSX + XSY
		mov	Xe[250],ax

		mov	ax,YSX[si]
		add	ax,YSY[di]
		sar	ax,1
		sar	ax,1
		sar	ax,1		;/8 scaling
		add	ax,YPos8	;YPos8 + YSX + YSY
		mov	Ye[250],ax

		mov	ax,ZSX[si]
		add	ax,ZSY[di]
		sar	ax,1
		sar	ax,1
		sar	ax,1		;/8 scaling
		add	ax,ZPos8	;ZPos8 + ZSX + ZSY
		mov	Ze[250],ax

		mov	si,cx
		mov	di,dx

		mov	ax,ApprLightPoints[bx+4]
		neg	ax
		add	si,ax
		mov	ax,ApprLightPoints[bx+6]
		neg	ax
		add	di,ax

		mov	ax,XSX[si]	
		add	ax,XSY[di]
		sar	ax,1
		sar	ax,1
		sar	ax,1		;/8 scaling
		add	ax,XPos8     	;XPos8 + XSX + XSY
		mov	Xe[254],ax

		mov	ax,YSX[si]
		add	ax,YSY[di]
		sar	ax,1
		sar	ax,1
		sar	ax,1		;/8 scaling
		add	ax,YPos8	;YPos8 + YSX + YSY
		mov	Ye[254],ax

		mov	ax,ZSX[si]
		add	ax,ZSY[di]
		sar	ax,1
		sar	ax,1
		sar	ax,1		;/8 scaling
		add	ax,ZPos8	;ZPos8 + ZSX + ZSY
		mov	Ze[254],ax

		call	DrawApprLights8

ExitRunway8:	ret

SortRunway8	ENDP

;----------------------------------------------------------------------------

;* SortRunway16 - draw runway (SEC_SCALE16)
;*
;* pass: si -> RUNWAY data block
;* ret : nothing
;* kill: assume all

SortRunway16	PROC	NEAR

;------------
;* sort end 1
;------------

		mov	bx,RWY_X1[si]	;fetch end 1 x co-ord (0 .. 64)
		shl	bx,1		;0 .. 128
		add	bx,64		;64 .. 192

		mov	di,RWY_Y1[si]	;fetch end 1 y co-ord (0 .. 64)
		shl	di,1		;0 .. 128
		add	di,64		;64 .. 192

		mov	ax,XSX[bx]	
		add	ax,XSY[di]
		sar	ax,1
		sar	ax,1
		sar	ax,1
		sar	ax,1		;/16 scaling
		add	ax,XPos16
		mov	Xe[0],ax 	;XPos16 + XSX + XSY
		mov	Xe[4],ax 	;(preserve for runway lights)

		mov	ax,YSX[bx]	
		add	ax,YSY[di]
		sar	ax,1
		sar	ax,1
		sar	ax,1
		sar	ax,1		;/16 scaling
		add	ax,YPos16
		mov	Ye[0],ax 	;YPos16 + YSX + YSY
		mov	Ye[4],ax 	;(preserve for runway lights)

		mov	ax,ZSX[bx]	
		add	ax,ZSY[di]
		sar	ax,1
		sar	ax,1
		sar	ax,1
		sar	ax,1		;/16 scaling
		add	ax,ZPos16
		mov	Ze[0],ax 	;ZPos16 + ZSX + ZSY
		mov	Ze[4],ax 	;(preserve for runway lights)

;------------
;* sort end 2
;------------

		mov	bx,RWY_X2[si]	;fetch end 1 x co-ord (0 .. 64)
		shl	bx,1		;0 .. 128
		add	bx,64		;64 .. 192

		mov	di,RWY_Y2[si]	;fetch end 1 y co-ord (0 .. 64)
		shl	di,1		;0 .. 128
		add	di,64		;64 .. 192

		mov	ax,XSX[bx]	
		add	ax,XSY[di]
		sar	ax,1
		sar	ax,1
		sar	ax,1
		sar	ax,1		;/16 scaling
		add	ax,XPos16
		mov	Xe[2],ax 	;XPos16 + XSX + XSY
		mov	Xe[6],ax 	;(preserve for runway lights)

		mov	ax,YSX[bx]	
		add	ax,YSY[di]
		sar	ax,1
		sar	ax,1
		sar	ax,1
		sar	ax,1		;/16 scaling
		add	ax,YPos16
		mov	Ye[2],ax 	;YPos16 + YSX + YSY
		mov	Ye[6],ax 	;(preserve for runway lights)

		mov	ax,ZSX[bx]	
		add	ax,ZSY[di]
		sar	ax,1
		sar	ax,1
		sar	ax,1
		sar	ax,1		;/16 scaling
		add	ax,ZPos16
		mov	Ze[2],ax 	;ZPos16 + ZSX + ZSY
		mov	Ze[6],ax 	;(preserve for runway lights)

		call	QuickLineClip
		jc	ExitRunway16	;runway non-visible ->

		test	RwyLightsOn,1	;runway lights on?
		jnz	@F		;yes ->

		mov	al,COL_RWY1
		mov	cx,XCrt[0]
		mov	bl,YCrt[0]
		mov	dx,XCrt[2]
		mov	bh,YCrt[2]
		call	LineDraw

		jmp	ExitRunway16

@@:		call	DrawRwyLights16

ExitRunway16:	ret

SortRunway16	ENDP

;----------------------------------------------------------------------------

;* DrawTaxiways
;*
;* pass: si -> taxiway data
;*       SctrScaleMode
;* ret : nothing
;* kill: assume all

ExitTaxiways1	LABEL	NEAR

		ret

DrawTaxiways	PROC	NEAR

;* do not draw taxiways in SEC_SCALE16 visual

		mov	ax,SctrScaleMode
		cmp	ax,SEC_SCALE16
		je	ExitTaxiways1

		mov	bx,ax

;* if SctrScaleMode < SEC_SCALE8 and ZFT < Z_APPROX_THRESH then
;*    draw polygon taxiways
;* else
;*    draw line taxiways
;* end

		cmp	ax,SEC_SCALE8
		je	ContLines

		mov	ax,WORD PTR V_VIEW.VP_ZFT_HI
		test	ax,ax		;zft > 65,535ft?
		jnz	ContLines	;yes ->

		mov	ax,WORD PTR V_VIEW.VP_ZFT_LO
		cmp	ax,Z_APPROX_THRES
		_JB	ContPolys

;------------------------
;* draw taxiways as lines
;------------------------

ContLines:	mov	ax,FEATOBJ1
		mov	es,ax

;* scan vertex list and calculate eye co-ord data wrt sector scale mode

		call	ScanVertexList[bx]

		mov	ax,DATA
		mov	es,ax

		mov	VertexIndex,di

;* test if taxiways are visible

		push	si
		mov	si,di
		call	CalcOutCodes
		pop	si
		jc	ExitTaxiways2	;taxiways non-visible ->

;* copy face data from FEATOBJ1 segment to DATA segment

		mov	ax,FEATOBJ1
		mov	ds,ax

		mov	si,[si]		;point to even face data

		lodsw			;fetch counter
		mov	cx,ax
		
		mov	di,OFFSET CopyBuffer

		FAST_MOVE

		mov	ax,DATA
		mov	ds,ax

;* generate faces

		mov	si,OFFSET CopyBuffer

NextLineFace:	lodsb		    	;fetch logical colour
		cmp	al,-1		;end of face list?
		je	TaxiLights1	;yes ->

		mov	Col1,al

		mov	di,OFFSET CrtBuffer
		call	PolyLineClip
		jc	NextLineFace	;lines non-visible ->

		push	si
		mov	al,Col1
		mov	si,OFFSET CrtBuffer
		call	PolyLine
		pop	si
		jmp	NextLineFace

;---------------------
;* draw taxiway lights
;---------------------

TaxiLights1:	mov	al,Night	
		or	al,Fog		;night or fog?
		jz	ExitTaxiways2	;no ->

		mov	si,VertexIndex

		call	PolyDotClip

		mov	si,VertexIndex

TaxiLightsLp1:	mov	cx,XCrt[si]
		cmp	cx,-1		;visible?
		je	@F		;no ->
		mov	bl,YCrt[si]

		mov	al,RwyLightCol
		push	si
		call	SetPixel
		pop	si

@@:		sub	si,2
		jnc	TaxiLightsLp1

ExitTaxiways2:	ret

;---------------------------
;* draw taxiways as polygons
;---------------------------

ContPolys:	mov	ax,FEATOBJ1
		mov	es,ax

;* scan vertex list and calculate eye co-ord data wrt sector scale mode

		call	MakeVertex[bx]

		mov	ax,DATA
		mov	es,ax

		mov	VertexIndex,di

;* test if taxiway is visible

		push	si
		mov	si,di
		call	CalcOutCodes
		pop	si
		jc	ExitTaxiways2	;taxiways non-visible ->

;* copy face data from FEATOBJ1 segment to DATA segment

		mov	ax,FEATOBJ1
		mov	ds,ax

		mov	si,[si]		;point to even face data

		lodsw			;fetch counter
		mov	cx,ax
		
		mov	di,OFFSET CopyBuffer

		FAST_MOVE

		mov	ax,DATA
		mov	ds,ax

;* generate faces

		mov	si,OFFSET CopyBuffer

NextPolyFace:	lodsb		    	;fetch logical colour
		cmp	al,-1		;end of face list?
		je	TaxiLights2	;yes ->

		mov	Col1,al

		lodsb			;fetch first vertex index
		cmp	al,-1		;end of list?
		je	NextPolyFace	;yes ->

		shl	al,1	  	;index * 2 for lh end point
		mov	TaxiPoly[0],al
		add	al,2		;index + 2 for rh end point
		mov	TaxiPoly[3],al

NextPoly:	lodsb			;fetch next vertex index
		cmp	al,-1		;end of list?
		je	NextPolyFace	;yes ->

		shl	al,1	  	;index * 2 for lh end point
		mov	TaxiPoly[1],al
		add	al,2		;index + 2 for rh end point
		mov	TaxiPoly[2],al
		
		push	si   		;store face list ptr

		mov	si,OFFSET TaxiPoly

		mov	di,OFFSET CrtBuffer
		call	PolyClip
		jc	SkipPoly	;poly non-visible ->

		mov	al,Col1
		mov	si,OFFSET CrtBuffer
		call	PolyFill

SkipPoly:	pop	si		;restore face list ptr

		mov	al,TaxiPoly[1]	;next road shares previous points
		mov	TaxiPoly[0],al
  
		mov	al,TaxiPoly[2]
		mov	TaxiPoly[3],al

		jmp	NextPoly

;---------------------
;* draw taxiway lights
;---------------------

TaxiLights2:	mov	al,Night	
		or	al,Fog		;night or fog?
		jz	ExitTaxiways3	;no ->

		mov	si,VertexIndex

		call	PolyDotClip

		mov	si,VertexIndex

TaxiLightsLp2:	mov	cx,XCrt[si]
		cmp	cx,-1		;visible?
		je	@F		;no ->
		mov	bl,YCrt[si]

		mov	al,RwyLightCol
		push	si
		call	SetPixel
		pop	si

@@:		sub	si,2
		jnc	TaxiLightsLp2

ExitTaxiways3:	ret

DrawTaxiways	ENDP
 
;----------------------------------------------------------------------------

;* ScanVertex1 - scan vertex list and calc eye co-ords (SEC_SCALE1)
;*
;* pass: es:si -> vertex list
;* ret : es:si -> end of vertex list + 1
;*       di = indexes last vertex value in eye co-ord arrays
;*       Xe[], Ye[], Ze[]
;* kill: ax, bx, cx, dx, bp, flags

ScanVertex1	PROC	NEAR

	    ;mov	RwyLightCol,COL_NT_BLUE1
		
		mov	bp,ModelMapIndex
		test	SctrGameLayer1[bp],10000000b  ;SECT_ENEMY. Over enemy sector?
        jz @F; --> No! 
		mov	RwyLightCol,COL_GREY1      	;The airfield is enemy-held. Dim the lights!
		jmp SkipAirfieldFriendly1
@@: 
        mov	RwyLightCol,COL_NT_BLUE1
SkipAirfieldFriendly1:
		
		
		xor	di,di		;reset eye co-ord index

		xor	bx,bx		;reset index (high byte always 0)

VertexLoop1:	ES_LODSB		;fetch end type
		cmp	al,-1		;end of vertex list?
		je	ExitVertex1	;yes ->
		
		ES_LODSB		;fetch x index
		mov	bl,al
		mov	cx,XSX[bx]	;XSX
		mov	dx,YSX[bx]	;YSX
		mov	bp,ZSX[bx]	;ZSX

		ES_LODSB		;fetch y index
		mov	bl,al
		add	cx,XSY[bx]	;XSX + XSY
		add	dx,YSY[bx]	;YSX + YSY
		add	bp,ZSY[bx]	;ZSX + ZSY

		add	cx,XPos1	;XPos1 + XSX + XSY
		mov	Xe[di],cx

		add	dx,YPos1	;YPos1 + YSX + YSY
		mov	Ye[di],dx

		add	bp,ZPos1	;ZPos1 + ZSX + ZSY
		mov	Ze[di],bp

		add	di,2		;next index

		jmp	VertexLoop1

ExitVertex1:	sub	di,2		;di indexes last vertex
		ret

ScanVertex1	ENDP

;----------------------------------------------------------------------------

;* ScanVertex2 - scan vertex list and calc eye co-ords (SEC_SCALE2)
;*
;* pass: es:si -> vertex list
;* ret : es:si -> end of vertex list + 1
;*       di = indexes last vertex value in eye co-ord arrays
;*       Xe[], Ye[], Ze[]
;* kill: ax, bx, cx, dx, bp, flags

ScanVertex2	PROC	NEAR

		;mov	RwyLightCol,COL_NT_BLUE1

		mov	bp,ModelMapIndex
		test	SctrGameLayer1[bp],10000000b  ;SECT_ENEMY. Over enemy sector?
        jz @F; --> No! 
		mov	RwyLightCol,COL_GREY1      	;The airfield is enemy-held. Dim the lights!
		jmp SkipAirfieldFriendly2
@@: 
        mov	RwyLightCol,COL_NT_BLUE1	;The airfield is a friendly. Show all lights. 
		
SkipAirfieldFriendly2:		

		xor	di,di		;reset eye co-ord index

		xor	bx,bx		;reset index (high byte always 0)

VertexLoop2:	ES_LODSB		;fetch end type
		cmp	al,-1		;end of vertex list?
		je	ExitVertex2	;yes ->
		
		ES_LODSB		;fetch x index
		mov	bl,al
		mov	cx,XSX[bx]	;XSX
		mov	dx,YSX[bx]	;YSX
		mov	bp,ZSX[bx]	;ZSX

		ES_LODSB		;fetch y index
		mov	bl,al
		add	cx,XSY[bx]	;XSX + XSY
		add	dx,YSY[bx]	;YSX + YSY
		add	bp,ZSY[bx]	;ZSX + ZSY

		sar	cx,1		;/2 scaling
		add	cx,XPos2	;XPos2 + XSX + XSY
		mov	Xe[di],cx

		sar	dx,1		;/2 scaling
		add	dx,YPos2	;YPos2 + YSX + YSY
		mov	Ye[di],dx

		sar	bp,1		;/2 scaling
		add	bp,ZPos2	;ZPos2 + ZSX + ZSY
		mov	Ze[di],bp

		add	di,2		;next index

		jmp	VertexLoop2

ExitVertex2:	sub	di,2		;di indexes last vertex
		ret

ScanVertex2	ENDP

;----------------------------------------------------------------------------

;* ScanVertex8 - scan vertex list and calc eye co-ords (SEC_SCALE8)
;*
;* pass: es:si -> vertex list
;* ret : es:si -> end of vertex list + 1
;*       di = indexes last vertex value in eye co-ord arrays
;*       Xe[], Ye[], Ze[]
;* kill: ax, bx, cx, dx, bp, flags

ScanVertex8	PROC	NEAR

		;mov	RwyLightCol,COL_NT_BLUE2

		mov	bp,ModelMapIndex
		test	SctrGameLayer1[bp],10000000b  ;SECT_ENEMY. Over enemy sector?
        jz @F; --> No! 
		mov	RwyLightCol,COL_GREY1      	;The airfield is enemy-held. Dim the lights!
		jmp SkipAirfieldFriendly3
@@: 
        mov	RwyLightCol,COL_NT_BLUE2
		
SkipAirfieldFriendly3:		

		xor	di,di		;reset eye co-ord index

		xor	bx,bx		;reset index (high byte always 0)

VertexLoop8:	ES_LODSB		;fetch end type
		cmp	al,-1		;end of vertex list?
		je	ExitVertex8	;yes ->
		
		ES_LODSB		;fetch x index
		mov	bl,al
		mov	cx,XSX[bx]	;XSX
		mov	dx,YSX[bx]	;YSX
		mov	bp,ZSX[bx]	;ZSX

		ES_LODSB		;fetch y index
		mov	bl,al
		add	cx,XSY[bx]	;XSX + XSY
		add	dx,YSY[bx]	;YSX + YSY
		add	bp,ZSY[bx]	;ZSX + ZSY

		sar	cx,1
		sar	cx,1
		sar	cx,1		;/8 scaling
		add	cx,XPos8	;XPos8 + XSX + XSY
		mov	Xe[di],cx

		sar	dx,1
		sar	dx,1
		sar	dx,1		;/8 scaling
		add	dx,YPos8	;YPos8 + YSX + YSY
		mov	Ye[di],dx

		sar	bp,1
		sar	bp,1
		sar	bp,1		;/8 scaling
		add	bp,ZPos8	;ZPos8 + ZSX + ZSY
		mov	Ze[di],bp

		add	di,2		;next index

		jmp	VertexLoop8

ExitVertex8:	sub	di,2		;di indexes last vertex
		ret

ScanVertex8	ENDP

;----------------------------------------------------------------------------

;* MakeVertex1 - scan vertex list and calc eye co-ords wrt end type (SEC_SCALE1)
;*
;* pass: es:si -> vertex list
;* ret : es:si -> end of vertex list + 1
;*       di = indexes last vertex value in eye co-ord arrays
;*       Xe[], Ye[], Ze[]
;* kill: ax, bx, cx, dx, bp, flags

ExitMakeVert1	LABEL	NEAR

		sub	di,2		;di indexes last vertex
		ret

MakeVertex1	PROC	NEAR

		;mov	RwyLightCol,COL_NT_BLUE1

		mov	bp,ModelMapIndex
		test	SctrGameLayer1[bp],10000000b  ;SECT_ENEMY. Over enemy sector?
        jz @F; --> No! 
		mov	RwyLightCol,COL_GREY1      	;The airfield is enemy-held. Dim the lights!
		jmp SkipAirfieldFriendly4
@@: 
        mov	RwyLightCol,COL_NT_BLUE1

SkipAirfieldFriendly4:			

		xor	di,di		;reset eye co-ord index

		xor	bx,bx		;reset index (high byte always 0)

MakeVertLoop1:	ES_LODSB		;fetch end type
		cmp	al,-1		;end of vertex list?
		je	ExitMakeVert1	;yes ->

		mov	bl,al
		push	bx		;store end type index
		
		ES_LODSB		;fetch x index
		mov	bl,al
		mov	cx,XSX[bx]	;XSX
		mov	dx,YSX[bx]	;YSX
		mov	bp,ZSX[bx]	;ZSX

		ES_LODSB		;fetch y index
		mov	bl,al
		add	cx,XSY[bx]	;XSX + XSY
		add	dx,YSY[bx]	;YSX + YSY
		add	bp,ZSY[bx]	;ZSX + ZSY

		add	cx,XPos1	;XPos1 + XSX + XSY
		add	dx,YPos1	;YPos1 + YSX + YSY
		add	bp,ZPos1	;ZPos1 + ZSX + ZSY

		mov	XPos,cx
		mov	YPos,dx
		mov	ZPos,bp
		
;* calc lh and rh points wrt end type (two co-ords generated for each vertex)

		pop	bx		;restore end type index

		push	si 		;store vertex list ptr

		push	bx   		;store end type index

		mov	si,EndType64[bx]   	;xl
		mov	bx,EndType64[bx+2]	;yl

		mov	ax,XGX[si]
		add	ax,XGY[bx]
		add	ax,XPos
		mov	Xe[di],ax

		mov	ax,YGX[si]
		add	ax,YGY[bx]
		add	ax,YPos
		mov	Ye[di],ax

		mov	ax,ZGX[si]
		add	ax,ZGY[bx]
		add	ax,ZPos
		mov	Ze[di],ax

		pop	bx	 	;restore end type index
		
		add	di,2   		;rh point index

		mov	si,EndType64[bx+4]	;xr
		mov	bx,EndType64[bx+6]	;yr

		mov	ax,XGX[si]
		add	ax,XGY[bx]
		add	ax,XPos
		mov	Xe[di],ax

		mov	ax,YGX[si]
		add	ax,YGY[bx]
		add	ax,YPos
		mov	Ye[di],ax

		mov	ax,ZGX[si]
		add	ax,ZGY[bx]
		add	ax,ZPos
		mov	Ze[di],ax

		pop	si		;restore vertex list ptr

		add	di,2		;next index

		jmp	MakeVertLoop1

MakeVertex1	ENDP

;----------------------------------------------------------------------------

;* MakeVertex2 - scan vertex list and calc eye co-ords wrt end type (SEC_SCALE2)
;*
;* pass: es:si -> vertex list
;* ret : es:si -> end of vertex list + 1
;*       di = indexes last vertex value in eye co-ord arrays
;*       Xe[], Ye[], Ze[]
;* kill: ax, bx, cx, dx, bp, flags

ExitMakeVert2	LABEL	NEAR

		sub	di,2		;di indexes last vertex
		ret

MakeVertex2	PROC	NEAR

		;mov	RwyLightCol,COL_NT_BLUE1

		mov	bp,ModelMapIndex
		test	SctrGameLayer1[bp],10000000b  ;SECT_ENEMY. Over enemy sector?
        jz @F; --> No! 
		mov	RwyLightCol,COL_GREY1      	;The airfield is enemy-held. Dim the lights!
		jmp SkipAirfieldFriendly5
@@: 
        mov	RwyLightCol,COL_NT_BLUE1     ;Friendly-held airfield. Show the lights.

SkipAirfieldFriendly5:					

		xor	di,di		;reset eye co-ord index

		xor	bx,bx		;reset index (high byte always 0)

MakeVertLoop2:	ES_LODSB		;fetch end type
		cmp	al,-1		;end of vertex list?
		je	ExitMakeVert2	;yes ->

		mov	bl,al
		push	bx		;store end type index
		
		ES_LODSB		;fetch x index
		mov	bl,al
		mov	cx,XSX[bx]	;XSX
		mov	dx,YSX[bx]	;YSX
		mov	bp,ZSX[bx]	;ZSX

		ES_LODSB		;fetch y index
		mov	bl,al
		add	cx,XSY[bx]	;XSX + XSY
		add	dx,YSY[bx]	;YSX + YSY
		add	bp,ZSY[bx]	;ZSX + ZSY

		sar	cx,1		;/2 scaling
		sar	dx,1		;/2 scaling
		sar	bp,1		;/2 scaling

		add	cx,XPos2	;XPos2 + XSX + XSY
		add	dx,YPos2	;YPos2 + YSX + YSY
		add	bp,ZPos2	;ZPos2 + ZSX + ZSY

		mov	XPos,cx
		mov	YPos,dx
		mov	ZPos,bp
		
;* calc lh and rh points wrt end type (two co-ords generated for each vertex)

		pop	bx		;restore end type index

		push	si 		;store vertex list ptr

		push	bx   		;store end type index

		mov	si,EndType64[bx]	;xl
		mov	bx,EndType64[bx+2]	;yl

		mov	ax,XGX[si]
		add	ax,XGY[bx]
		sar	ax,1		;/2 scaling
		add	ax,XPos
		mov	Xe[di],ax

		mov	ax,YGX[si]
		add	ax,YGY[bx]
		sar	ax,1		;/2 scaling
		add	ax,YPos
		mov	Ye[di],ax

		mov	ax,ZGX[si]
		add	ax,ZGY[bx]
		sar	ax,1		;/2 scaling
		add	ax,ZPos
		mov	Ze[di],ax

		pop	bx	 	;restore end type index
		
		add	di,2   		;rh point index

		mov	si,EndType64[bx+4]	;xr
		mov	bx,EndType64[bx+6]	;yr

		mov	ax,XGX[si]
		add	ax,XGY[bx]
		sar	ax,1		;/2 scaling
		add	ax,XPos
		mov	Xe[di],ax

		mov	ax,YGX[si]
		add	ax,YGY[bx]
		sar	ax,1		;/2 scaling
		add	ax,YPos
		mov	Ye[di],ax

		mov	ax,ZGX[si]
		add	ax,ZGY[bx]
		sar	ax,1		;/2 scaling
		add	ax,ZPos
		mov	Ze[di],ax

		pop	si		;restore vertex list ptr

		add	di,2		;next index

		jmp	MakeVertLoop2

MakeVertex2	ENDP

;----------------------------------------------------------------------------

;* DrawRwyLights1 - draw runway lights (SEC_SCALE1)
;*
;* pass: Xe[0], Ye[0],  Ze[8] = lh vertex end 1 ) Ze[] values must be preserved
;*       Xe[2], Ye[2], Ze[10] = lh vertex end 2	) at different locations as the
;*       Xe[4], Ye[4], Ze[12] = rh vertex end 2	) original values are destroyed
;*       Xe[6], Ye[6], Ze[14] = rh vertex end 1	) by viewing pyramid scaling
;* ret : nothing
;* kill: assume all

DrawRwyLights1	PROC	NEAR

		mov	RwyLightCol,COL_NT_WHITE1

IntoRwyLights1	LABEL	NEAR

		test	RwyLightsOn,1	;runway lights on?
		_JZ	ExitRwyLights1	;no ->

;---------------------
;* restore Ze[] values
;---------------------

		mov	si,OFFSET Ze[8]
		mov	di,OFFSET Ze[0]
		mov	cx,4
		rep	movsw

;-----------------------------------------
;* sub-divide lhs creating 31 extra points
;-----------------------------------------

;* sub-divide Xe[0] and Xe[2] creating Xe[8] .. Xe[68]

		mov	ax,Xe[2]
		sub	ax,Xe[0]

		ABSV	ax

		xor	bx,bx

		REPT	5		;ax, bx = (Xe[2] - Xe[0]) / 32
		shr	ax,1
		rcr	bx,1
		ENDM

		xor	bx,dx		;restore sign
		xor	ax,dx
		sub	bx,dx
		sbb	ax,dx

		mov	cx,Xe[0]	;cx, dx = starting point
		xor	dx,dx

		xchg	ax,cx		;ax, bx = starting point
		xchg	bx,dx		;cx, dx = sub-division

		mov	di,OFFSET Xe[8]

		REPT	31
		add	bx,dx
		adc	ax,cx
		stosw
		ENDM

;* sub-divide Ye[0] and Ye[2] creating Ye[8] .. Ye[68]

		mov	ax,Ye[2]
		sub	ax,Ye[0]

		ABSV	ax

		xor	bx,bx

		REPT	5		;ax, bx = (Ye[2] - Ye[0]) / 32
		shr	ax,1
		rcr	bx,1
		ENDM

		xor	bx,dx		;restore sign
		xor	ax,dx
		sub	bx,dx
		sbb	ax,dx

		mov	cx,Ye[0]	;cx, dx = starting point
		xor	dx,dx

		xchg	ax,cx		;ax, bx = starting point
		xchg	bx,dx		;cx, dx = sub-division

		mov	di,OFFSET Ye[8]

		REPT	31
		add	bx,dx
		adc	ax,cx
		stosw
		ENDM

;* sub-divide Ze[0] and Ze[2] creating Ze[8] .. Ze[68]

		mov	ax,Ze[2]
		sub	ax,Ze[0]

		ABSV	ax

		xor	bx,bx

		REPT	5		;ax, bx = (Ze[2] - Ze[0]) / 32
		shr	ax,1
		rcr	bx,1
		ENDM

		xor	bx,dx		;restore sign
		xor	ax,dx
		sub	bx,dx
		sbb	ax,dx

		mov	cx,Ze[0]	;cx, dx = starting point
		xor	dx,dx

		xchg	ax,cx		;ax, bx = starting point
		xchg	bx,dx		;cx, dx = sub-division

		mov	di,OFFSET Ze[8]

		REPT	31
		add	bx,dx
		adc	ax,cx
		stosw
		ENDM

;-----------------------------------------
;* sub-divide rhs creating 31 extra points
;-----------------------------------------

;* sub-divide Xe[6] and Xe[4] creating Xe[70] .. Xe[130]

		mov	ax,Xe[4]
		sub	ax,Xe[6]

		ABSV	ax

		xor	bx,bx

		REPT	5		;ax, bx = (Xe[4] - Xe[6]) / 32
		shr	ax,1
		rcr	bx,1
		ENDM

		xor	bx,dx		;restore sign
		xor	ax,dx
		sub	bx,dx
		sbb	ax,dx

		mov	cx,Xe[6]	;cx, dx = starting point
		xor	dx,dx

		xchg	ax,cx		;ax, bx = starting point
		xchg	bx,dx		;cx, dx = sub-division

		mov	di,OFFSET Xe[70]

		REPT	31
		add	bx,dx
		adc	ax,cx
		stosw
		ENDM

;* sub-divide Ye[6] and Ye[4] creating Ye[70] .. Ye[130]

		mov	ax,Ye[4]
		sub	ax,Ye[6]

		ABSV	ax

		xor	bx,bx

		REPT	5		;ax, bx = (Ye[4] - Ye[6]) / 32
		shr	ax,1
		rcr	bx,1
		ENDM

		xor	bx,dx		;restore sign
		xor	ax,dx
		sub	bx,dx
		sbb	ax,dx

		mov	cx,Ye[6]	;cx, dx = starting point
		xor	dx,dx

		xchg	ax,cx		;ax, bx = starting point
		xchg	bx,dx		;cx, dx = sub-division

		mov	di,OFFSET Ye[70]

		REPT	31
		add	bx,dx
		adc	ax,cx
		stosw
		ENDM

;* sub-divide Ze[6] and Ze[4] creating Ze[70] .. Ze[130]

		mov	ax,Ze[4]
		sub	ax,Ze[6]

		ABSV	ax

		xor	bx,bx

		REPT	5		;ax, bx = (Ze[4] - Ze[6]) / 32
		shr	ax,1
		rcr	bx,1
		ENDM

		xor	bx,dx		;restore sign
		xor	ax,dx
		sub	bx,dx
		sbb	ax,dx

		mov	cx,Ze[6]	;cx, dx = starting point
		xor	dx,dx

		xchg	ax,cx		;ax, bx = starting point
		xchg	bx,dx		;cx, dx = sub-division

		mov	di,OFFSET Ze[70]

		REPT	31
		add	bx,dx
		adc	ax,cx
		stosw
		ENDM

;---------------------------------------------------------------------------
;* sub-divide lhs and rhs points (diagonally) creating 30 centre line points
;---------------------------------------------------------------------------

;* Unfortunately the runway stripes obstruct the centre line lights causing
;* them to flicker. The visual effect is unsatisfactory. This code has been
;* commented out pending future inspiration!

		IF	0

		mov	cx,30

		mov	si,8

CentreLoop1:	mov	ax,Xe[si+64]	;rhs point
		sub	ax,Xe[si]	;lhs point
		ABSV	ax
		shr	ax,1		;/2
		ROUNDUP	ax
		xor	ax,dx		;restore sign
		sub	ax,dx
		add	ax,Xe[si]
		mov	Xe[si+124],ax

		mov	ax,Ye[si+64]	;rhs point
		sub	ax,Ye[si]	;lhs point
		ABSV	ax
		shr	ax,1		;/2
		ROUNDUP	ax
		xor	ax,dx		;restore sign
		sub	ax,dx
		add	ax,Ye[si]
		mov	Ye[si+124],ax

		mov	ax,Ze[si+64]	;rhs point
		sub	ax,Ze[si]	;lhs point
		ABSV	ax
		shr	ax,1		;/2
		ROUNDUP	ax
		xor	ax,dx		;restore sign
		sub	ax,dx
		add	ax,Ze[si]
		mov	Ze[si+124],ax

		add	si,2		;next point

		loop	CentreLoop1

		ENDIF

;--------------------
;* draw runway lights
;--------------------

NUM_LIGHTS	=	(4+31+31-1)*2

		mov	si,NUM_LIGHTS
		call	CalcOutCodes
		jc	ExitRwyLights1	;runway lights non-visible ->

		mov	si,NUM_LIGHTS
		call	PolyDotClip

		mov	si,NUM_LIGHTS

RwyLightsLp1:	mov	cx,XCrt[si]
		cmp	cx,-1		;visible?
		je	@F		;no ->
		mov	bl,YCrt[si]

		mov	al,RwyLightCol
		push	si
		call	SetPixel
		pop	si

@@:		sub	si,2
		jnc	RwyLightsLp1

ExitRwyLights1:	ret

DrawRwyLights1	ENDP

;----------------------------------------------------------------------------

;* DrawRwyLights2 - draw runway lights (SEC_SCALE2)
;*
;* pass: Xe[0], Ye[0],  Ze[8] = lh vertex end 1 ) Ze[] values must be preserved
;*       Xe[2], Ye[2], Ze[10] = lh vertex end 2	) at different locations as the
;*       Xe[4], Ye[4], Ze[12] = rh vertex end 2	) original values are destroyed
;*       Xe[6], Ye[6], Ze[14] = rh vertex end 1	) by viewing pyramid scaling
;* ret : nothing
;* kill: assume all
;*
;* note: Returns via DrawRwyLights1.

DrawRwyLights2	PROC	NEAR

		mov	RwyLightCol,COL_NT_WHITE1

		jmp	IntoRwyLights1

DrawRwyLights2	ENDP

;----------------------------------------------------------------------------

;* DrawRwyLights8 - draw runway lights (SEC_SCALE8)
;*
;* pass: Xe[0], Ye[0],  Ze[8] = lh vertex end 1 ) Ze[] values must be preserved
;*       Xe[2], Ye[2], Ze[10] = lh vertex end 2	) at different locations as the
;*       Xe[4], Ye[4], Ze[12] = rh vertex end 2	) original values are destroyed
;*       Xe[6], Ye[6], Ze[14] = rh vertex end 1	) by viewing pyramid scaling
;* ret : nothing
;* kill: assume all
;*
;* note: Returns via DrawRwyLights1.

DrawRwyLights8	PROC	NEAR

		mov	RwyLightCol,COL_NT_GREY2

		jmp	IntoRwyLights1

DrawRwyLights8	ENDP

;----------------------------------------------------------------------------

;* DrawRwyLights16 - draw runway lights (SEC_SCALE16)
;*
;* pass: XCrt[0], YCrt[0] = runway end 1
;*       XCrt[2], YCrt[2] = runway end 2
;*       Xe[4], Ye[4], Ze[4] = runway end 1
;*       Xe[6], Ye[6], Ze[6] = runway end 2
;* ret : nothing
;* kill: assume all

DrawRwyLights16	PROC	NEAR

;* draw runway lights

		mov	al,COL_NT_GREY4
		mov	cx,XCrt[0]
		mov	bl,YCrt[0]
		mov	dx,XCrt[2]
		mov	bh,YCrt[2]
		call	LineDraw

		mov	ax,Xe[4]
		mov	Xe[0],ax
		mov	ax,Ye[4]
		mov	Ye[0],ax
		mov	ax,Ze[4]
		mov	Ze[0],ax

		call	DotClip
		jc	@F		;non-visible ->
		mov	al,COL_NT_RED3
		call	SetPixel

@@:		mov	ax,Xe[6]
		mov	Xe[0],ax
		mov	ax,Ye[6]
		mov	Ye[0],ax
		mov	ax,Ze[6]
		mov	Ze[0],ax

		call	DotClip
		jc	@F		;non-visible ->
		mov	al,COL_NT_RED3
		call	SetPixel

@@:		ret

DrawRwyLights16	ENDP

;----------------------------------------------------------------------------

;* DrawApprLights1 - draw approach lights (single pixels) (SEC_SCALE1)
;*
;* pass: p1 = Xe[248], Ye[248], Ze[248]
;*       p2 = Xe[250], Ye[250], Ze[250]
;*       p3 = Xe[252], Ye[252], Ze[252]
;*       p4 = Xe[254], Ye[254], Ze[254]
;* ret : nothing
;* kill: assume all
;*
;* note:		p3
;*		 p1 ÄÄÄÄÂÄÄÄÄ p2
;*			³
;*			³
;*			³
;*			³
;*			³
;*			p4

DrawApprLights1	PROC	NEAR

		mov	RwyLightCol,COL_NT_RED1

;-------------------
;* calc x eye values
;-------------------

;* calc 8ft offset between lights

		mov	ax,Xe[250]
		sub	ax,Xe[248]

		ABSV	ax

		xor	bx,bx

		REPT	6		;ax, bx = (Xe[p2] - Xe[p1]) / 64
		shr	ax,1
		rcr	bx,1
		ENDM

		xor	bx,dx		;restore sign
		xor	ax,dx
		sub	bx,dx
		sbb	ax,dx

		mov	bp,bx		;store 8ft offset
		mov	si,ax

;* create 12 light datum positions at 256ft intervals from runway end

		mov	ax,Xe[254]
		sub	ax,Xe[252]

		ABSV	ax

		xor	bx,bx

		REPT	4		;ax, bx = (Xe[p4] - Xe[p3]) / 16
		shr	ax,1
		rcr	bx,1
		ENDM

		xor	bx,dx		;restore sign
		xor	ax,dx
		sub	bx,dx
		sbb	ax,dx

		mov	cx,Xe[252]	;cx, dx = starting point
		xor	dx,dx

		xchg	ax,cx		;ax, bx = starting point
		xchg	bx,dx		;cx, dx = sub-division

		mov	di,OFFSET Xe[0]

		call	CreateLights1

;-------------------
;* calc y eye values
;-------------------

;* calc 8ft offset between lights

		mov	ax,Ye[250]
		sub	ax,Ye[248]

		ABSV	ax

		xor	bx,bx

		REPT	6		;ax, bx = (Xe[p2] - Xe[p1]) / 64
		shr	ax,1
		rcr	bx,1
		ENDM

		xor	bx,dx		;restore sign
		xor	ax,dx
		sub	bx,dx
		sbb	ax,dx

		mov	bp,bx
		mov	si,ax

;* create 12 light datum positions at 256ft intervals from runway end

		mov	ax,Ye[254]
		sub	ax,Ye[252]

		ABSV	ax

		xor	bx,bx

		REPT	4		;ax, bx = (Ye[p4] - Ye[p3]) / 16
		shr	ax,1
		rcr	bx,1
		ENDM

		xor	bx,dx		;restore sign
		xor	ax,dx
		sub	bx,dx
		sbb	ax,dx

		mov	cx,Ye[252]	;cx, dx = starting point
		xor	dx,dx

		xchg	ax,cx		;ax, bx = starting point
		xchg	bx,dx		;cx, dx = sub-division

		mov	di,OFFSET Ye[0]

		call	CreateLights1

;-------------------
;* calc z eye values
;-------------------

;* calc 8ft offset between lights

		mov	ax,Ze[250]
		sub	ax,Ze[248]

		ABSV	ax

		xor	bx,bx

		REPT	6		;ax, bx = (Xe[p2] - Xe[p1]) / 64
		shr	ax,1
		rcr	bx,1
		ENDM

		xor	bx,dx		;restore sign
		xor	ax,dx
		sub	bx,dx
		sbb	ax,dx

		mov	bp,bx
		mov	si,ax

;* create 12 light datum positions at 256ft intervals from runway end

		mov	ax,Ze[254]
		sub	ax,Ze[252]

		ABSV	ax

		xor	bx,bx

		REPT	4		;ax, bx = (Ze[p4] - Ze[p3]) / 16
		shr	ax,1
		rcr	bx,1
		ENDM

		xor	bx,dx		;restore sign
		xor	ax,dx
		sub	bx,dx
		sbb	ax,dx

		mov	cx,Ze[252]	;cx, dx = starting point
		xor	dx,dx

		xchg	ax,cx		;ax, bx = starting point
		xchg	bx,dx		;cx, dx = sub-division

		mov	di,OFFSET Ze[0]

		call	CreateLights1

;----------------------
;* draw approach lights
;----------------------

NUM_LIGHTS	=	((12*5)+(5*2)+(9*2)-1)*2	;see CreateLights1

		mov	si,NUM_LIGHTS
		call	CalcOutCodes
		jc	ExitApprLights1	;runway non-visible ->

		mov	si,NUM_LIGHTS
		call	PolyDotClip

		mov	si,NUM_LIGHTS

ApprLightsLp1:	mov	cx,XCrt[si]
		cmp	cx,-1		;error?
		je	@F		;yes ->
		mov	bl,YCrt[si]

		mov	al,RwyLightCol
		push	si
		call	SetPixel
		pop	si

@@:		sub	si,2
		jnc	ApprLightsLp1

ExitApprLights1:ret

DrawApprLights1	ENDP

;----------------------------------------------------------------------------

;* LIGHTS - create approach lights wrt datum point
;*
;* pass: count1 = number of lhs lights
;*       count2 = number of centre lights
;*       count3 = number of rhs lights 
;*       ax, bx = starting point
;*       cx, dx = 256ft sub-division
;*       si, bp = 8ft sub-division
;*       di -> eye co-ords result buffer
;* ret : di -> next eye co-ord result
;* kill: flags

LIGHTS		MACRO	count1,count2,count3

		add	bx,dx		;displace 256ft from runway
		adc	ax,cx
		stosw

		push	ax		;store centre postion
		push	bx

		REPT	count2/2	;create count2/2 lights to the right
		add	bx,bp
		adc	ax,si
		stosw
		ENDM

		IF	count3 NE 0
		add	bx,bp		;create gap
		adc	ax,si
		REPT	count3		;create count3 lights to the right
		add	bx,bp
		adc	ax,si
		stosw
		ENDM
		ENDIF

		pop	bx		;restore centre position
		pop	ax

		push	ax		;store centre postion
		push	bx

		REPT	count2/2	;create count2/2 lights to the left
		sub	bx,bp
		sbb	ax,si
		stosw
		ENDM

		IF	count1 NE 0
		sub	bx,bp		;create gap
		sbb	ax,si
		REPT	count1		;create count1 lights to the left
		sub	bx,bp
		sbb	ax,si
		stosw
		ENDM
		ENDIF

		pop	bx		;restore centre position
		pop	ax

		ENDM

;----------------------------------------------------------------------------

;* CreateLights1 - create approach lights wrt datum point
;*
;* pass: ax, bx = starting point
;*       cx, dx = 256ft sub-division (bar distance)
;*       si, bp = 8ft sub-division (lamp distance)
;*       di -> eye co-ords result buffer
;* ret : nothing
;* kill: assume all

CreateLights1	PROC	NEAR

		LIGHTS	0,5,0
		LIGHTS	0,5,0
		LIGHTS	0,5,0
		LIGHTS	5,5,5
		LIGHTS	0,5,0
		LIGHTS	0,5,0
		LIGHTS	0,5,0
		LIGHTS	9,5,9
		LIGHTS	0,5,0
		LIGHTS	0,5,0
		LIGHTS	0,5,0
		LIGHTS	0,5,0

		ret

CreateLights1	ENDP

;----------------------------------------------------------------------------

;* DrawApprLights2 - draw approach lights (grouped as lines) (SEC_SCALE2)
;*
;* pass: p1 = Xe[248], Ye[248], Ze[248]
;*       p2 = Xe[250], Ye[250], Ze[250]
;*       p3 = Xe[252], Ye[252], Ze[252]
;*       p4 = Xe[254], Ye[254], Ze[254]
;* ret : nothing
;* kill: assume all
;*
;* note:		p3
;*		 p1 ÄÄÄÄÂÄÄÄÄ p2
;*			³
;*			³
;*			³
;*			³
;*			³
;*			p4

DrawApprLights2	PROC	NEAR

		mov	RwyLightCol,COL_NT_RED1

IntoApprLights2	LABEL	NEAR

;-------------------
;* calc x eye values
;-------------------

;* calc 16ft offset

		mov	ax,Xe[250]
		sub	ax,Xe[248]

		ABSV	ax

		xor	bx,bx

		REPT	5		;ax, bx = (Xe[p2] - Xe[p1]) / 32
		shr	ax,1
		rcr	bx,1
		ENDM

		xor	bx,dx		;restore sign
		xor	ax,dx
		sub	bx,dx
		sbb	ax,dx

		mov	bp,bx		;store 16ft offset
		mov	si,ax

;* create 12 light datum positions at 256ft intervals from runway end

		mov	ax,Xe[254]
		sub	ax,Xe[252]

		ABSV	ax

		xor	bx,bx

		REPT	4		;ax, bx = (Xe[p4] - Xe[p3]) / 16
		shr	ax,1
		rcr	bx,1
		ENDM

		xor	bx,dx		;restore sign
		xor	ax,dx
		sub	bx,dx
		sbb	ax,dx

		mov	cx,Xe[252]	;cx, dx = starting point
		xor	dx,dx

		xchg	ax,cx		;ax, bx = starting point
		xchg	bx,dx		;cx, dx = sub-division

		mov	di,OFFSET Xe[0]

		call	CreateLights2

;-------------------
;* calc y eye values
;-------------------

;* calc 16ft offset

		mov	ax,Ye[250]
		sub	ax,Ye[248]

		ABSV	ax

		xor	bx,bx

		REPT	5		;ax, bx = (Ye[p2] - Ye[p1]) / 32
		shr	ax,1
		rcr	bx,1
		ENDM

		xor	bx,dx		;restore sign
		xor	ax,dx
		sub	bx,dx
		sbb	ax,dx

		mov	bp,bx		;store 16ft offset
		mov	si,ax

;* create 12 light datum positions at 256ft intervals from runway end

		mov	ax,Ye[254]
		sub	ax,Ye[252]

		ABSV	ax

		xor	bx,bx

		REPT	4		;ax, bx = (Ye[p4] - Ye[p3]) / 16
		shr	ax,1
		rcr	bx,1
		ENDM

		xor	bx,dx		;restore sign
		xor	ax,dx
		sub	bx,dx
		sbb	ax,dx

		mov	cx,Ye[252]	;cx, dx = starting point
		xor	dx,dx

		xchg	ax,cx		;ax, bx = starting point
		xchg	bx,dx		;cx, dx = sub-division

		mov	di,OFFSET Ye[0]

		call	CreateLights2

;-------------------
;* calc z eye values
;-------------------

;* calc 16ft offset

		mov	ax,Ze[250]
		sub	ax,Ze[248]

		ABSV	ax

		xor	bx,bx

		REPT	5		;ax, bx = (Ze[p2] - Ze[p1]) / 32
		shr	ax,1
		rcr	bx,1
		ENDM

		xor	bx,dx		;restore sign
		xor	ax,dx
		sub	bx,dx
		sbb	ax,dx

		mov	bp,bx		;store 16ft offset
		mov	si,ax

;* create 12 light datum positions at 256ft intervals from runway end

		mov	ax,Ze[254]
		sub	ax,Ze[252]

		ABSV	ax

		xor	bx,bx

		REPT	4		;ax, bx = (Ze[p4] - Ze[p3]) / 16
		shr	ax,1
		rcr	bx,1
		ENDM

		xor	bx,dx		;restore sign
		xor	ax,dx
		sub	bx,dx
		sbb	ax,dx

		mov	cx,Ze[252]	;cx, dx = starting point
		xor	dx,dx

		xchg	ax,cx		;ax, bx = starting point
		xchg	bx,dx		;cx, dx = sub-division

		mov	di,OFFSET Ze[0]

		call	CreateLights2

;----------------------
;* draw approach lights
;----------------------

NUM_LIGHTS	=	12		;see CreateLights2

		mov	cx,NUM_LIGHTS

		xor	si,si

ApprLightsLp2:	push	cx
		push	si

		call	QuickLineClip	;lights visible?
		jc	@F		;no ->

		mov	al,RwyLightCol
		mov	cx,XCrt[0]
		mov	bl,YCrt[0]
		mov	dx,XCrt[2]
		mov	bh,YCrt[2]
		call	LineDraw

@@:		pop	si
		pop	cx

;* move next line ends to Xe[0], Ye[0], Ze[0] and Xe[2], Ye[2], Ze[2]

		add	si,4

		mov	ax,Xe[si]
		mov	Xe[0],ax
		mov	ax,Ye[si]
		mov	Ye[0],ax
		mov	ax,Ze[si]
		mov	Ze[0],ax

		mov	ax,Xe[si+2]
		mov	Xe[2],ax
		mov	ax,Ye[si+2]
		mov	Ye[2],ax
		mov	ax,Ze[si+2]
		mov	Ze[2],ax

		loop	ApprLightsLp2

		ret

DrawApprLights2	ENDP

;----------------------------------------------------------------------------

;* DrawApprLights8 - draw approach lights (grouped as lines) (SEC_SCALE8)
;*
;* pass: p1 = Xe[248], Ye[248], Ze[248]
;*       p2 = Xe[250], Ye[250], Ze[250]
;*       p3 = Xe[252], Ye[252], Ze[252]
;*       p4 = Xe[254], Ye[254], Ze[254]
;* ret : nothing
;* kill: assume all
;*
;* note: Returns via DrawAppLights2.

DrawApprLights8	PROC	NEAR

		mov	RwyLightCol,COL_NT_RED2

		jmp	IntoApprLights2

DrawApprLights8	ENDP

;----------------------------------------------------------------------------

;* CreateLights2 - create approach lights wrt datum point
;*
;* pass: ax, bx = starting point
;*       cx, dx = 256ft sub-division (bar distance)
;*       si, bp = 16ft sub-division (lamp strip width)
;* ret : nothing
;* kill: assume all

CreateLights2	PROC	NEAR

LOOP_COUNT	=	1

		REPT	12

WIDTH_COUNT	=	1		;32ft wide lamp strip
		IF	LOOP_COUNT EQ 4
WIDTH_COUNT	=	4		;128ft wide lamp strip
		ELSEIF	LOOP_COUNT EQ 8
WIDTH_COUNT	=	6		;192ft wide lamp strip
		ENDIF

		add	bx,dx		;displace 256ft from runway
		adc	ax,cx

		push	ax
		push	bx
		REPT	WIDTH_COUNT
		add	bx,bp
		adc	ax,si
		ENDM
		stosw
		pop	bx
		pop	ax

		push	ax
		push	bx
		REPT	WIDTH_COUNT
		sub	bx,bp
		sbb	ax,si
		ENDM
		stosw
		pop	bx
		pop	ax

LOOP_COUNT	=	LOOP_COUNT+1

		ENDM

		ret

CreateLights2	ENDP


VISCODE		ENDS

;============================================================================

		END

