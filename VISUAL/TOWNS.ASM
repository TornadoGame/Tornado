;****************************************************************************
;*
;* TOWNS.ASM
;*
;* Draw town (or installation) road layouts.
;*
;* Towns are included in the "specials" map layer.
;*
;* 15.07.1991 - KJB
;* 14.04.1992 - KJB - Reorganised to remove need for seperate subroutine
;*                    for each town.
;*
;* Format of data:-
;*
;* TestObj1	DB	end type, x1, y1 	;vertex list
;*		DB	end type, x2, y2
;*		DB	end type, x3, y3
;*		DB	end type, x4, y4
;*		DB	end type, x5, y5
;*		..        ..    ..   ..
;*		DB	end type, xn, yn
;*		DB	-1			;list terminator
;*
;*		DW	OFFSET TestObj1_1
;*
;*		EVEN	  			;even data is faster!!!
;*
;* TestObj1_1	DW	count = length of following face data
;*
;*		DB	colour, v1, v2, v3, .. vn, -1
;*		DB	colour, v1, v2, v3, .. vn, -1
;*              ..        ..    ..  ..  ..  .. ..  ..
;*		DB	colour, v1, v2, v3, .. vn, -1
;*		DB	-1			;list terminator
;*
;*		EVEN
;*
;* Notes:-
;*
;* "end type" indicates which road end co-ords to use. The value is an index
;* into a table pre-scaled by 8 (0 .. 7 * 8).
;*
;* The vertex x and y co-ords represent sector grid offsets (0 .. 64).
;*
;* The actual values of x and y co-ords are indices into the sector
;* grid arrays (ie. XSX[], XSY[] etc.).
;*
;*    ie. x = 64, y = 64 = bottom left hand corner of sector
;*        x = 192, y = 192 = top right hand corner of sector
;*
;* The vertex values are indices into the eye co-ord arrays (ie. Xe[],
;* Ye[] and Ze[]).
;*
;* IMPORTANT: A maximum of 64 vertices may be used as two points (lh and rh)
;*            are generated for each vertex.
;*
;* Towns should be keep near to the sector centre (say within +/-4k ft)
;* because the roads are only drawn as polygons in the current sector.
;*
;* The data format used for town roads is ideally suited for drawing the
;* roads as lines. However, the "end type" byte has been added to enable
;* the roads to be drawn as polygons. Selecting an end type can be quite
;* tricky, but basically the end type should indicate the direction of the
;* road. At some connection points the end type will not be suitable for
;* all of the connecting roads, therefore, the point may have to be defined
;* more than once with different end types.
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	DrawTown

		PUBLIC	TownTable

		EXTRN	PolyFill:FAR
		EXTRN	PolyLine:FAR

		EXTRN	CalcOutCodes:NEAR
		EXTRN	PolyClip:NEAR
		EXTRN	PolyLineClip:NEAR

		EXTRN	TOWN_1:ABS
		EXTRN	TOWN_N:ABS

;============================================================================

		INCLUDE	VISEXTRN.INC
		INCLUDE	VISDATA.INC
		INCLUDE	PALETTES.INC
		INCLUDE	\LIB8086\USEFUL.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

;* town table (index = (special number) - TOWN_1 * 2)

TownTable	LABEL	WORD

		DW	OFFSET Town1	;1 (TOWN_1)
		DW	OFFSET Town2	;2
		DW	OFFSET Town3	;3
		DW	OFFSET Town4	;4
		DW	OFFSET Town5	;5
		DW	OFFSET Town6	;6
		DW	OFFSET Town7	;7
		DW	OFFSET Town8	;8
		DW	OFFSET Town9	;9
		DW	OFFSET Town10	;10
		DW	OFFSET Town11	;11
		DW	OFFSET Town12	;12
		DW	OFFSET Town13	;13 (TOWN_N)

;* approximation threshold wrt ZFT (max value = 8192)

Z_APPROX_THRES	EQU	2048

ScanVertexList	DW	ScanVertex1	;SEC_SCALE1
		DW	ScanVertex2	;SEC_SCALE2
		DW	ScanVertex8	;SEC_SCALE8

;* road polygon

RoadPoly	DB	0,0,0,0,-1

		EVEN

;* lh and rh x, y offsets for road end types (1/16 scaling)

EndType		DW	@MID-@128	;xl - end type 0 (N)
		DW	@MID+@0		;yl
		DW	@MID+@128	;xr
		DW	@MID+@0		;yr

		DW	@MID-@128	;xl - end type 1 (NE)
		DW	@MID+@128	;yl
		DW	@MID+@128	;xr
		DW	@MID-@128	;yr

		DW	@MID+@0		;xl - end type 2 (E)
		DW	@MID+@128	;yl
		DW	@MID+@0		;xr
		DW	@MID-@128	;yr

		DW	@MID+@128	;xl - end type 3 (SE)
		DW	@MID+@128	;yl
		DW	@MID-@128	;xr
		DW	@MID-@128	;yr

		DW	@MID+@128	;xl - end type 4 (S)
		DW	@MID+@0		;yl
		DW	@MID-@128	;xr
		DW	@MID+@0		;yr

		DW	@MID+@128	;xl - end type 5 (SW)
		DW	@MID-@128	;yl
		DW	@MID-@128	;xr
		DW	@MID+@128	;yr

		DW	@MID+@0		;xl - end type 6 (W)
		DW	@MID-@128	;yl
		DW	@MID+@0		;xr
		DW	@MID+@128	;yr

		DW	@MID-@128	;xl - end type 7 (NW)
		DW	@MID-@128	;yl
		DW	@MID+@128	;xr
		DW	@MID+@128	;yr

DATA		ENDS

;============================================================================

FEATOBJ1	SEGMENT PARA PUBLIC 'DATA'

		INCLUDE	OBJECTS\FEATURES\TOWNTILE.INC

FEATOBJ1	ENDS

;============================================================================

VISCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:VISCODE
		ASSUME DS:DATA

;* DrawTown - draw town layout
;*
;* pass: al = specials number (TOWN_1 .. TOWN_N)
;*       SctrScaleMode
;* ret : nothing
;* kill: assume all

DrawTown	PROC	NEAR

;* sort ptr to town data

		mov	bl,al

		sub	bl,TOWN_1
		xor	bh,bh
		shl	bx,1		;*2

		mov	si,TownTable[bx]

;* do not draw towns in SEC_SCALE16 visual

		mov	ax,SctrScaleMode
		cmp	ax,SEC_SCALE16
		je	ExitTowns

		mov	bx,ax

;* draw as lines or polygons (polygons if SEC_SCALE1 and zft < Z_APPROX_THRES)?

		cmp	ax,SEC_SCALE1
		jne	ContLines

		mov	ax,WORD PTR V_VIEW.VP_ZFT_HI
		test	ax,ax
		jnz	ContLines

		mov	ax,WORD PTR V_VIEW.VP_ZFT_LO
		cmp	ax,Z_APPROX_THRES
		jb	ContPolys	

;---------------------
;* draw towns as lines
;---------------------

ContLines:	mov	ax,FEATOBJ1
		mov	es,ax

;* scan vertex list and calculate eye co-ord data wrt sector scale mode

		call	ScanVertexList[bx]

		mov	ax,DATA
		mov	es,ax

;* test if town is visible

		push	si
		mov	si,di
		call	CalcOutCodes
		pop	si
		jc	ExitTowns	;town non-visible ->

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
		je	ExitTowns	;yes ->

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

ExitTowns:	ret

;------------------------
;* draw towns as polygons
;------------------------

ContPolys:	mov	ax,FEATOBJ1
		mov	es,ax

;* scan vertex list and calculate eye co-ord data

		call	MakeVertex1

		mov	ax,DATA
		mov	es,ax

;* test if town is visible

		push	si
		mov	si,di
		call	CalcOutCodes
		pop	si
		jc	ExitTowns	;town non-visible ->

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
		je	ExitTowns	;yes ->

		mov	Col1,al

		lodsb			;fetch first vertex index
		cmp	al,-1		;end of list?
		je	NextPolyFace	;yes ->

		shl	al,1	  	;index * 2 for lh end point
		mov	RoadPoly[0],al
		add	al,2		;index + 2 for rh end point
		mov	RoadPoly[3],al

NextPoly:	lodsb			;fetch next vertex index
		cmp	al,-1		;end of list?
		je	NextPolyFace	;yes ->

		shl	al,1	  	;index * 2 for lh end point
		mov	RoadPoly[1],al
		add	al,2		;index + 2 for rh end point
		mov	RoadPoly[2],al
		
		push	si   		;store face list ptr

		mov	si,OFFSET RoadPoly

		mov	di,OFFSET CrtBuffer
		call	PolyClip
		jc	SkipPoly	;poly non-visible ->

		mov	al,Col1
		mov	si,OFFSET CrtBuffer
		call	PolyFill

SkipPoly:	pop	si		;restore face list ptr

		mov	al,RoadPoly[1]	;next road shares previous points
		mov	RoadPoly[0],al
  
		mov	al,RoadPoly[2]
		mov	RoadPoly[3],al

		jmp	NextPoly

DrawTown	ENDP

;----------------------------------------------------------------------------

;* ScanVertex1 - scan vertex list and calc eye co-ords (SEC_SCALE1)
;*
;* pass: es:si -> vertex list
;* ret : es:si -> end of vertex list + 1
;*       di = indexes last vertex value in eye co-ord arrays
;*       Xe[], Ye[], Ze[]
;* kill: ax, bx, cx, dx, bp, flags

ScanVertex1	PROC	NEAR

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

		mov	bx,dx

;* calc max(abs(x), abs(y), abs(z))

		push	si
		push	di

		mov	ax,bp
		ABSV	ax
		mov	di,ax		;di = abs(z)
	
		mov	ax,bx
		ABSV	ax
		mov	si,ax		;si = abs(y)

		mov	ax,cx
		ABSV	ax		;ax = abs(x)

		cmp	ax,si		;abs(x) >= abs(y)?
		jae	@F		;yes ->
		mov	ax,si

@@:		cmp	ax,di		;max(abs(x), abs(y)) >= abs(z)?
		jae	@F		;yes ->
		mov	ax,di

@@:		pop	di
		pop	si

		mov	dx,cx

;* calc scaling mode wrt distance (see RAILWAYS.ASM for 3D Euclidian distance notes)

		mov	cx,00004h	;cl = position scale, ch = offset scale

		cmp	ax,387		;*16 scaling ok?
		jb	ScaleOk		;yes ->
		dec	cl
		inc	ch

		cmp	ax,774		;*8 scaling ok?
		jb	ScaleOk		;yes ->
		dec	cl
		inc	ch

		cmp	ax,1548		;*4 scaling ok?
		jb	ScaleOk		;yes ->
		dec	cl
		inc	ch

		cmp	ax,3096		;*2 scaling ok?
		jb	ScaleOk		;yes ->
		dec	cl
		inc	ch

ScaleOk:	sal	dx,cl		;scale x pos
		sal	bx,cl  		;scale y pos
		sal	bp,cl		;scale z pos

		mov	XPos,dx
		mov	YPos,bx
		mov	ZPos,bp
		
;* calc lh and rh points wrt end type (two co-ords generated for each vertex)

		mov	cl,ch		;cl = offset scale

		pop	bx		;restore end type index

		push	si 		;store vertex list ptr

		push	bx   		;store end type index

		mov	si,EndType[bx]		;xl
		mov	bx,EndType[bx+2]	;yl

		mov	ax,XGX[si]
		add	ax,XGY[bx]
		sar	ax,cl		;scale x offset
		add	ax,XPos
		mov	Xe[di],ax

		mov	ax,YGX[si]
		add	ax,YGY[bx]
		sar	ax,cl		;scale y offset
		add	ax,YPos
		mov	Ye[di],ax

		mov	ax,ZGX[si]
		add	ax,ZGY[bx]
		sar	ax,cl		;scale z offset
		add	ax,ZPos
		mov	Ze[di],ax

		pop	bx	 	;restore end type index
		
		add	di,2   		;rh point index

		mov	si,EndType[bx+4]	;xr
		mov	bx,EndType[bx+6]	;yr

		mov	ax,XGX[si]
		add	ax,XGY[bx]
		sar	ax,cl		;scale x offset
		add	ax,XPos
		mov	Xe[di],ax

		mov	ax,YGX[si]
		add	ax,YGY[bx]
		sar	ax,cl		;scale y offset
		add	ax,YPos
		mov	Ye[di],ax

		mov	ax,ZGX[si]
		add	ax,ZGY[bx]
		sar	ax,cl		;scale z offset
		add	ax,ZPos
		mov	Ze[di],ax

		pop	si		;restore vertex list ptr

		add	di,2		;next index

		jmp	MakeVertLoop1

MakeVertex1	ENDP

VISCODE		ENDS

;============================================================================

		END

