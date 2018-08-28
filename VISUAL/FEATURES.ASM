;****************************************************************************
;*
;* FEATURES.ASM
;*
;* Draw flat ground features (including rivers).
;*
;* 20.02.1991 - KJB
;* 11.05.1992 - KJB - Lake features reserved.
;*
;* Format of feature data:-
;*
;* TestObj1	DW	max visual range (SEC_SCALE1, SEC_SCALE2, SEC_SCALE8, SEC_SCALE16)
;*
;*		DB	vflags1, x1, y1		;vertex list
;*		DB	vflags2, x2, y2
;*		DB	vflags3, x3, y3
;*		DB	vflags4, x4, y4
;*		DB	vflags5, x5, y5
;*		..        ..     ..  ..
;*		DB	vflagsn, xn, yn
;*		DB	-1			;list terminator
;*
;*		DW	OFFSET TestObj1_1	;SEC_SCALE1 face data ptr
;*		DW	OFFSET TestObj1_2	;SEC_SCALE2 face data ptr
;*		DW	OFFSET TestObj1_8	;SEC_SCALE8 face data ptr
;*		DW	OFFSET TestObj1_16	;SEC_SCALE16 face data ptr
;*
;*		EVEN				;even data is faster!!!
;*
;* TestObj1_1	DW	count = length of following face data
;*
;*		DB	attrib, colour, v1, v2, v3, .. vn, -1
;*		DB	attrib, colour, v1, v2, v3, .. vn, -1
;*              ..        ..      ..    ..  ..  ..  .. ..  ..
;*		DB	attrib, colour, v1, v2, v3, .. vn, -1
;*		DB	-1			;list terminator
;*
;*		EVEN				;even data is faster!!!
;*
;* TestObj1_2	DW	count = length of following face data
;*
;*		DB	attrib, colour, v1, v2, v3, .. vn, -1
;*		DB	attrib, colour, v1, v2, v3, .. vn, -1
;*              ..        ..      ..    ..  ..  ..  .. ..  ..
;*		DB	attrib, colour, v1, v2, v3, .. vn, -1
;*		DB	-1			;list terminator
;*
;*		EVEN				;even data is faster!!!
;*
;* TestObj1_8	DW	count = length of following face data
;*
;*		DB	attrib, colour, v1, v2, v3, .. vn, -1
;*		DB	attrib, colour, v1, v2, v3, .. vn, -1
;*              ..        ..      ..    ..  ..  ..  .. ..  ..
;*		DB	attrib, colour, v1, v2, v3, .. vn, -1
;*		DB	-1			;list terminator
;*
;*		EVEN				;even data is faster!!!
;*
;* TestObj1_16	DW	count = length of following face data
;*
;*		DB	attrib, colour, v1, v2, v3, .. vn, -1
;*		DB	attrib, colour, v1, v2, v3, .. vn, -1
;*              ..        ..      ..    ..  ..  ..  .. ..  ..
;*		DB	attrib, colour, v1, v2, v3, .. vn, -1
;*		DB	-1			;list terminator
;*
;*		EVEN
;*
;* Notes:-
;*
;* "max visual range" indicates the furthest visual in which the object is
;* visible (ie. SEC_SCALE8 means that the object is visible in all visuals
;* up to and including SEC_SCALE8).
;*
;* The vertex flags "vflags" indicate which visual the vertex is required
;* for. Some approximated objects may not require all of the vertices.
;*
;*    ie. 0001b = required for SEC_SCALE1 visual
;*        0010b = required for SEC_SCALE2 visual
;*        0100b = required for SEC_SCALE8 visual
;*        1000b = required for SEC_SCALE16 visual
;*
;* The vertex x and y co-ords represent sector grid offsets (0 .. 64).
;*
;* The actual values of x and y co-ords are indices into the sector
;* grid arrays (ie. XSX[], XSY[] etc.).
;*
;*    ie. x = 64, y = 64 = bottom left hand corner of sector
;*        x = 192, y = 192 = top right hand corner of sector
;*
;* The "face data pointers" are provided for object approximation. It is
;* not mandatory to provide different face data for each visual. If face
;* data does not exist for some visuals (ie. for SEC_SCALE16 when max
;* visual range is SEC_SCALE8) then set the corresponding pointer to the
;* nearest approximation (in this case SEC_SCALE8 face data).
;*
;* The face attribute byte is a subset of the standard face attribute:-
;*
;*    - FACE_STRUCTURE is used by features
;*    - FACE_FILL_TYPE is used by clouds
;*
;* The vertex values are indices into the eye co-ord arrays (ie. Xe[],
;* Ye[] and Ze[]).
;*
;* Note that cloud data requires two colour bytes:-
;*
;*		DB	attrib, col1, col2, v1, v2, v3, .. vn, -1
;*
;* "col1" is the topside colour.
;*
;* "col2" is the underside colour.
;*
;* Clouds may only comprise polygons (including meshes). Do not use lines.
;*
;* All polygon points must be in a clockwise order.
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<
	
		PUBLIC	DrawRivers
		PUBLIC	DrawFeatures1
		PUBLIC	DrawFeatures2

		PUBLIC	GndTextEnabled

		PUBLIC	LAKE_FEATURE
		PUBLIC	HARD_FEATURE1
		PUBLIC	HARD_FEATURE8

		EXTRN	PolyFill:FAR
		EXTRN	PolyLine:FAR

		EXTRN	CalcOutCodes:NEAR
		EXTRN	PolyClip:NEAR
		EXTRN	PolyLineClip:NEAR

		EXTRN	FeatureTable:WORD
		EXTRN	RiverTable:WORD

		EXTRN	FeatureLayer1:BYTE
		EXTRN	FeatureLayer2:BYTE
		EXTRN	RiverLayer1:BYTE

;============================================================================

		INCLUDE	VISEXTRN.INC
		INCLUDE	VISDATA.INC
		INCLUDE	\LIB8086\USEFUL.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

GndTextEnabled	DB	1,0		;1 = ground texture enabled

LAKE_FEATURE	EQU	32		;features 1 .. 32 reserved for lakes

HARD_FEATURE1	EQU	77		;features 77 .. 84 reserved
HARD_FEATURE8	EQU	84		;for airfield hardstandings

ScanVertexList	DW	ScanVertex1	;SEC_SCALE1
		DW	ScanVertex2	;SEC_SCALE2
		DW	ScanVertex8	;SEC_SCALE8
		DW	ScanVertex16	;SEC_SCALE16

DATA		ENDS

;============================================================================

FEATOBJ1	SEGMENT PARA PUBLIC 'DATA'

FEATOBJ1	ENDS

;============================================================================

VISCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:VISCODE
		ASSUME DS:DATA

;* DrawRivers - draw rivers
;*
;* pass: MapIndex
;*       RiverLayer1[]
;* ret : nothing
;* kill: assume all

DrawRivers	PROC	NEAR

		mov	bp,MapIndex
		mov	al,RiverLayer1[bp]
		test	al,al		;null river?
		jz	ExitRivers	;yes ->

;* fetch pointer to river data

		xor	ah,ah
		mov	bx,ax
		shl	bx,1		;*2 index

		mov	si,RiverTable[bx]

		jmp	IntoFeatures

ExitRivers:	ret

DrawRivers	ENDP

;* DrawFeatures1 - essential features
;* DrawFeatures2 - all other features
;*
;* pass: MapIndex
;*       FeatureLayer1[]
;*       FeatureLayer2[]
;* ret : nothing
;* kill: assume all

DrawFeatures1	PROC	NEAR

		mov	bp,MapIndex
		mov	al,FeatureLayer1[bp]
		test	al,al		;null feature?
		jnz	ContFeatures	;no ->
		ret

DrawFeatures2	LABEL	NEAR

		test	GndTextEnabled,1	;ground texture enabled?
		jz	@F			;no ->

		mov	bp,MapIndex
		mov	al,FeatureLayer2[bp]
		test	al,al		;null feature?
		jnz	ContFeatures	;no ->
@@:		ret

;* fetch pointer to feature data

ContFeatures:	xor	ah,ah
		mov	bx,ax
		shl	bx,1		;*2 index

		mov	si,FeatureTable[bx]

;* test if feature is within visual range

IntoFeatures:	mov	ax,FEATOBJ1
		mov	es,ax

		ES_LODSW		;fetch max visual range

		cmp	ax,SctrScaleMode;within visual range?
		jae	InRange		;yes ->

		mov	ax,DATA
		mov	es,ax
		jmp	ExitFeatures

;* scan vertex list and calculate eye co-ord data wrt sector scale mode

InRange:	mov	bx,SctrScaleMode
		call	ScanVertexList[bx]

		mov	ax,DATA
		mov	es,ax

;* test if feature is visible

		push	si
		mov	si,di
		call	CalcOutCodes
		pop	si
		jc	ExitFeatures	;feature non-visible ->

;* copy face data from FEATOBJ1 segment to DATA segment

		mov	bx,SctrScaleMode

		mov	ax,FEATOBJ1
		mov	ds,ax

		mov	si,[si+bx]	;point to face data wrt scale mode

		lodsw			;fetch counter
		mov	cx,ax
		
		mov	di,OFFSET CopyBuffer

		FAST_MOVE

		mov	ax,DATA
		mov	ds,ax

;* generate faces

		mov	si,OFFSET CopyBuffer

NextFace:	lodsb		    	;fetch attribute
		cmp	al,-1		;end of face list?
		je	ExitFeatures	;yes ->

;* line or polygon structure?

		test	al,FACE_STRUCTURE 
		jnz	SortLine
		
;* sort polygon structure

		lodsb			;fetch logical colour
		mov	Col1,al

		mov	di,OFFSET CrtBuffer
		call	PolyClip
		jc	NextFace	;polygon non-visible ->

		push	si
		mov	al,Col1
		mov	si,OFFSET CrtBuffer
		call	PolyFill
		pop	si
		jmp	NextFace

;* sort line structure

SortLine:   	lodsb			;fetch logical colour
		mov	Col1,al

		mov	di,OFFSET CrtBuffer
		call	PolyLineClip
		jc	NextFace	;lines non-visible ->

		push	si
		mov	al,Col1
		mov	si,OFFSET CrtBuffer
		call	PolyLine
		pop	si
		jmp	NextFace

ExitFeatures:	ret

DrawFeatures1	ENDP

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

		jmp	VertexLoop1

SkipVertex1:	add	si,2

VertexLoop1:	ES_LODSB		;fetch vertex flags
		cmp	al,-1		;end of vertex list?
		je	ExitVertex1	;yes ->
		test	al,0001b	;vertex required?
		jz	SkipVertex1	;no ->
		
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

		jmp	VertexLoop2

SkipVertex2:	add	si,2

VertexLoop2:	ES_LODSB		;fetch vertex flags
		cmp	al,-1		;end of vertex list?
		je	ExitVertex2	;yes ->
		test	al,0010b	;vertex required?
		jz	SkipVertex2	;no ->
		
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

		jmp	VertexLoop8

SkipVertex8:	add	si,2

VertexLoop8:	ES_LODSB		;fetch vertex flags
		cmp	al,-1		;end of vertex list?
		je	ExitVertex8	;yes ->
		test	al,0100b	;vertex required?
		jz	SkipVertex8	;no ->
		
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

;* ScanVertex16 - scan vertex list and calc eye co-ords (SEC_SCALE16)
;*
;* pass: es:si -> vertex list
;* ret : es:si -> end of vertex list + 1
;*       di = indexes last vertex value in eye co-ord arrays
;*       Xe[], Ye[], Ze[]
;* kill: ax, bx, cx, dx, bp, flags

ScanVertex16	PROC	NEAR

		xor	di,di		;reset eye co-ord index

		xor	bx,bx		;reset index (high byte always 0)

		jmp	VertexLoop16

SkipVertex16:	add	si,2

VertexLoop16:	ES_LODSB		;fetch vertex flags
		cmp	al,-1		;end of vertex list?
		je	ExitVertex16	;yes ->
		test	al,1000b	;vertex required?
		jz	SkipVertex16	;no ->

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
		sar	cx,1
		sar	cx,1		;/16 scaling
		add	cx,XPos16	;XPos16 + XSX + XSY
		mov	Xe[di],cx

		sar	dx,1
		sar	dx,1
		sar	dx,1
		sar	dx,1		;/16 scaling
		add	dx,YPos16	;YPos16 + YSX + YSY
		mov	Ye[di],dx

		sar	bp,1
		sar	bp,1
		sar	bp,1
		sar	bp,1		;/16 scaling
		add	bp,ZPos16	;ZPos16 + ZSX + ZSY
		mov	Ze[di],bp

		add	di,2		;next index

		jmp	VertexLoop16

ExitVertex16:	sub	di,2		;di indexes last vertex
		ret

ScanVertex16	ENDP

VISCODE		ENDS

;============================================================================

		END

