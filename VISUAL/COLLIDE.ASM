;****************************************************************************
;*
;* COLLIDE.ASM
;*
;* Surface check and collision detection routines.
;*
;* 11.10.1992 - KJB
;* 08.03.1993 - KJB - collision detection routines added.
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	SurfaceCheck
		PUBLIC	CloudCheck1
		PUBLIC	CloudCheck2
		PUBLIC	GroundCollision
		PUBLIC	StaticCollision
		PUBLIC	MobileCollision
		PUBLIC	TreeCollision
		PUBLIC	CraterCollision

		EXTRN	LocateMobiles:FAR

		EXTRN	RiverTable:WORD
		EXTRN	FeatureTable:WORD
		EXTRN	CloudTable:WORD
		EXTRN	AirfieldTable:WORD
		EXTRN	GroundTable:WORD
		EXTRN	MobileTable:WORD
		EXTRN	SectorTable:WORD
		EXTRN	MobSectorTable:WORD
		EXTRN	TreeLayouts:WORD

		EXTRN	RiverLayer1:BYTE
		EXTRN	FeatureLayer1:BYTE
		EXTRN	FeatureLayer2:BYTE
		EXTRN	RoadLayer1:BYTE
		EXTRN	RoadLayer2:BYTE
		EXTRN	RoadLayer3:BYTE
		EXTRN	RoadLayer4:BYTE
		EXTRN	RailLayer1:BYTE
		EXTRN	CloudLayer1:BYTE
		EXTRN	CloudLayer2:BYTE
		EXTRN	SpecialLayer1:BYTE
		EXTRN	SectorLayer1:BYTE
		EXTRN	MobileLayer1:BYTE
		EXTRN	TreeLayer1:BYTE
		EXTRN	TreeLayer2:BYTE
		EXTRN	TreeLayer3:BYTE
		EXTRN	TreeLayer4:BYTE
		EXTRN	TreesEnabled:BYTE
		EXTRN	CraterNum:BYTE

		EXTRN	LAKE_FEATURE:ABS
		EXTRN	HARD_FEATURE1:ABS
		EXTRN	HARD_FEATURE8:ABS
		EXTRN	AIRFIELD_1:ABS
		EXTRN	AIRFIELD_N:ABS

;============================================================================

		INCLUDE	VISEXTRN.INC
		INCLUDE	VISDATA.INC
		INCLUDE	VISMACRO.INC
		INCLUDE	RWY_TAXI.INC
		INCLUDE	GNDLIST.INC

		INCLUDE	\LIB8086\USEFUL.INC

;============================================================================

		EXTRN	CraterBuffer:CRATER

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

;------------------
;* current position
;------------------

Xft		DW	0		;-8192 .. 8191
Yft		DW	0		;-8192 .. 8191

;------------------------------------
;* number of logical colours per face
;------------------------------------

NumFaceCols 	DW	1		;standard = 1, clouds = 2

;--------------------------------
;* road layer wrt sector quadrant
;--------------------------------

RoadQuad	DW	OFFSET RoadLayer2	;+x, +y (00)
		DW	OFFSET RoadLayer4	;+x, -y (01)
		DW	OFFSET RoadLayer1	;-x, +y (10)
		DW	OFFSET RoadLayer3	;-x, -y (11)

;-------------------
;* road length table
;-------------------

RoadLength	DW	    0		;x -  N road
		DW	 4096		;y
		DW	 4096 		;x - NE road
		DW	 4096		;y
		DW	 4096 		;x -  E road
		DW	    0		;y
		DW	 4096	 	;x - SE road
		DW	-4096		;y
		DW	    0		;x -  S road
		DW	-4096		;y
		DW	-4096 		;x - SW road
		DW	-4096		;y
		DW	-4096 		;x -  W road
		DW	    0		;y
		DW	-4096 		;x - NW road
		DW	 4096		;y

;----------------------
;* railway length table
;----------------------

RailLength	DW	    0		;x -  N rail
		DW	 8192		;y
		DW	 8192 		;x - NE rail
		DW	 8192		;y
		DW	 8192 		;x -  E rail
		DW	    0		;y
		DW	 8192	 	;x - SE rail
		DW	-8192		;y
		DW	    0		;x -  S rail
		DW	-8192		;y
		DW	-8192 		;x - SW rail
		DW	-8192		;y
		DW	-8192 		;x -  W rail
		DW	    0		;y
		DW	-8192 		;x - NW rail
		DW	 8192		;y

;----------------------------
;* road / railway width table
;----------------------------

RoadWidth	LABEL	BYTE

RailWidth	LABEL	BYTE

		DB	-32		;x1 -  N road
		DB	-32		;y1
		DB	-32		;x2
		DB	 32		;y2
		DB	 32		;x3
		DB	 32		;y3
		DB	 32		;x4
		DB	-32		;y4
		
		DB	-32		;x1 - NE road
		DB	 32		;y1
		DB	  0		;x2
		DB	 64		;y2
		DB	 64		;x3
		DB	  0		;y3
		DB	 32		;x4
		DB	-32		;y4

		DB	-32		;x1 -  E road
		DB	 32		;y1
		DB	 32		;x2
		DB	 32		;y2
		DB	 32		;x3
		DB	-32		;y3
		DB	-32		;x4
		DB	-32		;y4

		DB	 32		;x1 - SE road
		DB	 32		;y1
		DB	 64		;x2
		DB	  0		;y2
		DB	  0		;x3
		DB	-64		;y3
		DB	-32		;x4
		DB	-32		;y4

		DB	 32		;x1 -  S road
		DB	 32		;y1
		DB	 32		;x2
		DB	-32		;y2
		DB	-32		;x3
		DB	-32		;y3
		DB	-32		;x4
		DB	 32		;y4

		DB	 32		;x1 - SW road
		DB	-32		;y1
		DB	  0		;x2
		DB	-64		;y2
		DB	-64		;x3
		DB	  0		;y3
		DB	-32		;x4
		DB	 32		;y4

		DB	 32		;x1 -  W road
		DB	-32		;y1
		DB	-32		;x2
		DB	-32		;y2
		DB	-32		;x3
		DB	 32		;y3
		DB	 32		;x4
		DB	 32		;y4

		DB	-32		;x1 - NW road
		DB	-32		;y1
		DB	-64		;x2
		DB	  0		;y2
		DB	  0		;x3
		DB	 64		;y3
		DB	 32		;x4
		DB	 32		;y4

;---------------------------------------
;* select end type data wrt runway width
;---------------------------------------

RunwayWidth	DW	OFFSET EndType256	;RWY_WIDTH256
		DW	OFFSET EndType192	;RWY_WIDTH192
		DW	OFFSET EndType128	;RWY_WIDTH128

;---------------------------------------------------------
;* lh and rh x, y offsets for 256ft width runway end types
;---------------------------------------------------------

EndType256	DW	-128		;xl - end type 0 (180 - 360)
		DW	   0		;yl
		DW	 128		;xr
		DW	   0		;yr

		DW	-128		;xl - end type 1 (135 - 315)
		DW	-128		;yl
		DW	 128		;xr
		DW	 128		;yr

		DW	   0		;xl - end type 2 (090 - 270)
		DW	-128		;yl
		DW	   0		;xr
		DW	 128		;yr

		DW	 128		;xl - end type 3 (045 - 225)
		DW	-128		;yl
		DW	-128		;xr
		DW	 128		;yr

;---------------------------------------------------------
;* lh and rh x, y offsets for 192ft width runway end types
;---------------------------------------------------------

EndType192	DW	-96		;xl - end type 0 (180 - 360)
		DW	  0		;yl
		DW	 96		;xr
		DW	  0		;yr

		DW	-96		;xl - end type 1 (135 - 315)
		DW	-96		;yl
		DW	 96		;xr
		DW	 96		;yr

		DW	  0		;xl - end type 2 (090 - 270)
		DW	-96		;yl
		DW	  0		;xr
		DW	 96		;yr

		DW	 96		;xl - end type 3 (045 - 225)
		DW	-96		;yl
		DW	-96		;xr
		DW	 96		;yr

;---------------------------------------------------------
;* lh and rh x, y offsets for 128ft width runway end types
;---------------------------------------------------------

EndType128	DW	-64		;xl - end type 0 (180 - 360)
		DW	  0		;yl
		DW	 64		;xr
		DW	  0		;yr

		DW	-64		;xl - end type 1 (135 - 315)
		DW	-64		;yl
		DW	 64		;xr
		DW	 64		;yr

		DW	  0		;xl - end type 2 (090 - 270)
		DW	-64		;yl
		DW	  0		;xr
		DW	 64		;yr

		DW	 64		;xl - end type 3 (045 - 225)
		DW	-64		;yl
		DW	-64		;xr
		DW	 64		;yr

;---------------------------------------------------------
;* lh and rh x, y offsets for 64ft width taxiway end types
;---------------------------------------------------------

EndType64	DW	-32		;xl - end type 0 (N)
		DW	  0		;yl
		DW	 32		;xr
		DW	  0		;yr

		DW	-32		;xl - end type 1 (NE)
		DW	 32		;yl
		DW	 32		;xr
		DW	-32		;yr

		DW	  0		;xl - end type 2 (E)
		DW	 32		;yl
		DW	  0		;xr
		DW	-32		;yr

		DW	 32		;xl - end type 3 (SE)
		DW	 32		;yl
		DW	-32		;xr
		DW	-32		;yr

		DW	 32		;xl - end type 4 (S)
		DW	  0		;yl
		DW	-32		;xr
		DW	  0		;yr

		DW	 32		;xl - end type 5 (SW)
		DW	-32		;yl
		DW	-32		;xr
		DW	 32		;yr

		DW	  0		;xl - end type 6 (W)
		DW	-32		;yl
		DW	  0		;xr
		DW	 32		;yr

		DW	-32		;xl - end type 7 (NW)
		DW	-32		;yl
		DW	 32		;xr
		DW	 32		;yr

;---------------------------
;* collision check temp vars
;---------------------------

SourcePtr	DW	-1

TmpXErr		DW	0
TmpYErr		DW	0
TmpZErr		DW	0

DATA		ENDS

;============================================================================

FEATOBJ1	SEGMENT PARA PUBLIC 'DATA'

FEATOBJ1	ENDS

;============================================================================

GRNDOBJ1	SEGMENT PARA PUBLIC 'DATA'

GRNDOBJ1	ENDS

;============================================================================

MOBOBJ1		SEGMENT PARA PUBLIC 'DATA'

MOBOBJ1		ENDS

;============================================================================

SECDATA1	SEGMENT PARA PUBLIC 'DATA'

SECDATA1	ENDS

;============================================================================

MSECDATA1	SEGMENT PARA PUBLIC 'DATA'

MSECDATA1	ENDS

;============================================================================

VISCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:VISCODE
		ASSUME DS:DATA

;* SurfaceCheck - determine ground surface
;*
;* pass: si -> VIEWPOINT <>
;* ret : ax = surface type (see VISDATA.INC)
;* kill: assume all (except ax)

SurfaceCheck	PROC	FAR

;---------------------
;* initialize position
;---------------------

		mov	ax,[si].VP_XFT
		mov	Xft,ax

		mov	ax,[si].VP_YFT
		mov	Yft,ax

		mov	dx,[si].VP_XSEC
		mov	ax,[si].VP_YSEC

;* is the sector inside active map?

		mov	bl,1		;assume outside map

		cmp	dx,32		;x sec inside map?
		jae	@F		;no ->
		cmp	ax,32		;y sec inside map?
		jae	@F		;no ->

		xor	bl,bl

@@:		mov	NoMansLand,bl
	
;* sector wrap around for no mans land

		and	dx,MAP_X_WRAP
		and	ax,MAP_Y_WRAP
		
;* calc map index = x sec + y sec * 32

		REPT	5
		shl	ax,1
		ENDM
		add	ax,dx

		mov	MapIndex,ax

;----------------
;* check surfaces (in priority order)
;----------------

		call	CheckRivers
		jc	@F

		call	CheckLakes
		jc	@F

		call	CheckRunways
		jc	@F

		call	CheckTaxiways
		jc	@F

		call	CheckHard
		jc	@F

		call	CheckRoads
		jc	@F

		call	CheckRailways

@@:		ret

SurfaceCheck	ENDP

;----------------------------------------------------------------------------

;* CloudCheck1 - check if directly above or below cloud polygon (CloudLayer1)
;* CloudCheck2 - check if directly above or below cloud polygon (CloudLayer2)
;*
;* pass: si -> VIEWPOINT <>
;* ret : cf = 0: not directly above or below cloud polygon
;*       cf = 1: directly above or below cloud polygon
;* kill: assume all (except cf)
;*
;* note: Only call if not overcast and clouds enabled.

CloudCheck1	LABEL	FAR

		mov	di,OFFSET CloudLayer1

		jmp	CloudCheck

CloudCheck2	LABEL	FAR

		mov	di,OFFSET CloudLayer2

CloudCheck	PROC	FAR

;---------------------
;* initialize position
;---------------------

		mov	ax,[si].VP_XFT
		mov	Xft,ax

		mov	ax,[si].VP_YFT
		mov	Yft,ax

		mov	ax,[si].VP_XSEC
		mov	bp,[si].VP_YSEC

;* sector wrap around for no mans land

		and	ax,MAP_X_WRAP
		and	bp,MAP_Y_WRAP
		
;* calc map index = x sec + y sec * 32

		REPT	5
		shl	bp,1
		ENDM

		add	bp,ax

;* check for null feature

		mov	bl,[bp+di]
		test	bl,bl	 	;null feature?
		jz	ExitClouds	;yes (cf = 0) ->

		xor	bh,bh
		shl	bx,1		;*2 word index

		mov	si,CloudTable[bx]

		mov	NumFaceCols,2	

		call	CheckFeature

		mov	NumFaceCols,1

ExitClouds:	ret

CloudCheck	ENDP

;----------------------------------------------------------------------------

;* CheckRivers
;*
;* pass: Xft
;*       Yft
;*       MapIndex
;* ret : cf = 0: not in river
;*          ax = SURFACE_UNKNOWN
;*       cf = 1: in river
;*          ax = SURFACE_RIVER
;* kill: assume all (except ax, cf)

CheckRivers	PROC	NEAR

		mov	bp,MapIndex
		mov	bl,RiverLayer1[bp]
		test	bl,bl	 	;null feature?
		jz	FailRivers	;yes ->

		xor	bh,bh
		shl	bx,1		;*2 word index

		mov	si,RiverTable[bx]

		call	CheckFeature
		jnc	FailRivers

		mov	ax,SURFACE_RIVER
		ret

FailRivers:	mov	ax,SURFACE_UNKNOWN
		clc
		ret

CheckRivers	ENDP

;----------------------------------------------------------------------------

;* CheckLakes
;*
;* pass: Xft
;*       Yft
;*       MapIndex
;* ret : cf = 0: not in lake
;*          ax = SURFACE_UNKNOWN
;*       cf = 1: in lake
;*          ax = SURFACE_LAKE
;* kill: assume all (except ax, cf)

CheckLakes	PROC	NEAR

		mov	bp,MapIndex
		mov	bl,FeatureLayer1[bp]
		test	bl,bl	 	;null feature?
		jz	FailLakes	;yes ->

		cmp	bl,LAKE_FEATURE	;lake?
		ja	FailLakes	;no ->

		xor	bh,bh
		shl	bx,1		;*2 word index

		mov	si,FeatureTable[bx]

		call	CheckFeature
		jnc	FailLakes

		mov	ax,SURFACE_LAKE
		ret

FailLakes:	mov	ax,SURFACE_UNKNOWN
		clc
		ret

CheckLakes	ENDP

;----------------------------------------------------------------------------

;* CheckHard
;*
;* pass: Xft
;*       Yft
;*       MapIndex
;* ret : cf = 0: not on hardstanding
;*          ax = SURFACE_UNKNOWN
;*       cf = 1: on hardstanding
;*          ax = SURFACE_HARD
;* kill: assume all (except ax, cf)

CheckHard	PROC	NEAR

		test	NoMansLand,1	;on active map?
		jnz	FailHard	;no ->

		mov	bp,MapIndex
		mov	bl,FeatureLayer2[bp]

		cmp	bl,HARD_FEATURE1	;hardstanding?
		jb	FailHard		;no ->
		cmp	bl,HARD_FEATURE8	;hardstanding?
		ja	FailHard		;no ->

		xor	bh,bh
		shl	bx,1		;*2 word index

		mov	si,FeatureTable[bx]

		call	CheckFeature
		jnc	FailHard

		mov	ax,SURFACE_HARD
		ret

FailHard:	mov	ax,SURFACE_UNKNOWN
		clc
		ret

CheckHard	ENDP

;----------------------------------------------------------------------------

;* CheckFeature - check any feature
;*
;* pass: si -> feature data
;*	 NumFaceCols
;* ret : cf = 0: not in feature
;*       cf = 1: in feature
;* kill: assume all (except cf)
;*
;* note: Refer to FEATURES.ASM for feature data format.

CheckFeature	PROC	NEAR

		add	si,2		;skip visual range data

;------------------
;* scan vertex list (use SEC_SCALE1 vertices)
;------------------

		mov	ax,FEATOBJ1
		mov	es,ax

		mov	dl,0001b	;SEC_SCALE1 test mask

		xor	di,di		;reset index

		jmp	VertexLoop1
		
SkipVertex1:	add	si,2

VertexLoop1:	ES_LODSB		;fetch vertex flags
		cmp	al,-1		;end of vertex list?
		je	ContFeatures	;yes ->
		test	al,dl		;vertex required?
		jz	SkipVertex1	;no ->

;* x val = (v / 2 - 64) * 256

		ES_LODSB		;fetch x index
		shr	al,1
		sub	al,64
		xor	ah,ah
		xchg	al,ah
		mov	Xe[di],ax

;* y val = (v / 2 - 64) * 256

		ES_LODSB		;fetch y index
		shr	al,1
		sub	al,64
		xor	ah,ah
		xchg	al,ah
		mov	Ye[di],ax

		add	di,2		;next index

		jmp	VertexLoop1

ContFeatures:	mov	ax,DATA
		mov	es,ax

;------------------------------------------------------
;* copy face data from FEATOBJ1 segment to DATA segment
;------------------------------------------------------

		mov	ax,FEATOBJ1
		mov	ds,ax

		mov	si,[si]		;point to face data (SEC_SCALE1)

		lodsw			;fetch counter
		mov	cx,ax

		mov	di,OFFSET CopyBuffer

		FAST_MOVE

		mov	ax,DATA
		mov	ds,ax

;--------------------------
;* generate and check faces
;--------------------------

		mov	si,OFFSET CopyBuffer

NextFace:	lodsb			;fetch attribute
		cmp	al,-1		;end of face list?
		je	FailFeature	;yes ->

;* line or polygon structure?

		test	al,FACE_STRUCTURE 
		jnz	SortLine
		
;* sort polygon structure

		add	si,NumFaceCols	;ignore logical colour(s)

		xor	bh,bh		;clear index high byte

		xor	cx,cx		;count = 0

		xor	di,di		;index = 0

MakePolyLoop:	lodsb
		cmp	al,-1		;end of list?
		je	@F		;yes ->

		mov	bl,al

		mov	ax,Xe[bx]
		mov	XCrt[di],ax

		mov	ax,Ye[bx]
		mov	WORD PTR YCrt[di],ax

		inc	cx

		add	di,2

		jmp	MakePolyLoop

@@:		cmp	cx,3		;enough vertices for polygon?
		jb	NextFace	;no ->

		mov	ax,XCrt[0]	;repeat first co-ord at end
		mov	XCrt[di],ax

		mov	ax,WORD PTR YCrt[0]
		mov	WORD PTR YCrt[di],ax

		push	si
		call	TestInsideArea
		pop	si
		jnc	NextFace	;not in features ->

		ret			;cf = 1 (in feature)

;* sort line structure (ignore)

SortLine:   	inc	si		;ignore logical colour

@@:		lodsb			;wind ptr past line data
		cmp	al,-1
		jne	@B

		jmp	NextFace

FailFeature:	clc			;cf = 0 (not in feature)

		ret

CheckFeature	ENDP

;----------------------------------------------------------------------------

;* CheckRoads
;*
;* pass: Xft
;*       Yft
;*       MapIndex
;* ret : cf = 0: not on road
;*          ax = SURFACE_UNKNOWN
;*       cf = 1: on road
;*          ax = SURFACE_ROAD
;* kill: assume all (except ax, cf)
;*
;* note: Refer to ROADS.ASM for data format etc.

CheckRoads	PROC	NEAR

;-------------------------------------
;* sort road layer wrt sector quadrant
;-------------------------------------

		mov	ax,Xft
		cwd
		mov	cx,dx		;store sign(x)

		mov	ax,Yft
		cwd
		mov	bx,dx		;store sign(y)

		xor	si,si

		rol	cx,1		;expose sign(x)
		rcl	si,1		;pick up sign(x)
		rol	bx,1		;expose sign(y)
		rcl	si,1		;pick up sign(x)

		shl	si,1		;*2 word index

		mov	bp,RoadQuad[si]	;si -> road layer wrt sector quadrant

		mov	si,MapIndex

		mov	al,[bp+si]	;fetch road node

		test	al,al		;null node?
		_JZ	FailRoad	;yes ->

;-----------------------
;* calc road node centre
;-----------------------

		mov	dx,4096		;4096 * sign(x)
		xchg	cx,dx
		xor	cx,dx
		sub	cx,dx

		mov	dx,4096		;4096 * sign(y)
		xchg	bx,dx
		xor	bx,dx
		sub	bx,dx

;----------------
;* scan road node
;----------------

		xor	si,si		;length index
		xor	di,di		;width index

ScanNextRoad:	shr	al,1		;road to scan?
		jnc	SkipRoad	;no ->

		push	ax
		push	bx
		push	cx
		push	si
		push	di

;* x1, y1

		mov	al,RoadWidth[di+0]	;x1
		cbw
		add	ax,cx
		mov	XCrt[0],ax
		mov	XCrt[8],ax		;repeat at end

		mov	al,RoadWidth[di+1]	;y1
		cbw
		add	ax,bx
		mov	WORD PTR YCrt[0],ax
		mov	WORD PTR YCrt[8],ax  	;repeat at end

;* x2, y2

		mov	al,RoadWidth[di+2]	;x2
		cbw
		add	ax,RoadLength[si+0]
		add	ax,cx
		mov	XCrt[2],ax

		mov	al,RoadWidth[di+3]	;y3
		cbw
		add	ax,RoadLength[si+2]
		add	ax,bx
		mov	WORD PTR YCrt[2],ax

;* x3, y3

		mov	al,RoadWidth[di+4]	;x3
		cbw
		add	ax,RoadLength[si+0]
		add	ax,cx
		mov	XCrt[4],ax

		mov	al,RoadWidth[di+5]	;y3
		cbw
		add	ax,RoadLength[si+2]
		add	ax,bx
		mov	WORD PTR YCrt[4],ax

;* x4, y4

		mov	al,RoadWidth[di+6]	;x4
		cbw
		add	ax,cx
		mov	XCrt[6],ax

		mov	al,RoadWidth[di+7]	;y4
		cbw
		add	ax,bx
		mov	WORD PTR YCrt[6],ax

		mov	cx,4

		call	TestInsideArea

		pop	di
		pop	si
		pop	cx
		pop	bx
		pop	ax

		jc	PassRoad

SkipRoad:	add	si,4		;next road
		add	di,8

		test	al,al		;any more roads?
		_JNZ	ScanNextRoad	;yes ->

FailRoad:	mov	ax,SURFACE_UNKNOWN
		clc
		ret

PassRoad:	mov	ax,SURFACE_ROAD
		ret

CheckRoads	ENDP

;----------------------------------------------------------------------------

;* CheckRailways
;*
;* pass: Xft
;*       Yft
;*       MapIndex
;* ret : cf = 0: not on railway
;*          ax = SURFACE_UNKNOWN
;*       cf = 1: on railway
;*          ax = SURFACE_RAILWAY
;* kill: assume all (except ax, cf)
;*
;* note: Refer to RAILWAYS.ASM for data format etc.

CheckRailways	PROC	NEAR

		mov	bp,MapIndex
		mov	al,RailLayer1[bp]
		test	al,al		;null node?
		jz	FailRail	;yes ->

;----------------
;* scan rail node
;----------------

		xor	si,si		;length index
		xor	di,di		;width index

ScanNextRail:	shr	al,1		;rail to scan?
		jnc	SkipRail	;no ->

		push	ax
		push	si
		push	di

;* x1, y1

		mov	al,RailWidth[di+0]	;x1
		cbw
		mov	XCrt[0],ax
		mov	XCrt[8],ax		;repeat at end

		mov	al,RailWidth[di+1]	;y1
		cbw
		mov	WORD PTR YCrt[0],ax
		mov	WORD PTR YCrt[8],ax  	;repeat at end

;* x2, y2

		mov	al,RailWidth[di+2]	;x2
		cbw
		add	ax,RailLength[si+0]
		mov	XCrt[2],ax

		mov	al,RailWidth[di+3]	;y3
		cbw
		add	ax,RailLength[si+2]
		mov	WORD PTR YCrt[2],ax

;* x3, y3

		mov	al,RailWidth[di+4]	;x3
		cbw
		add	ax,RailLength[si+0]
		mov	XCrt[4],ax

		mov	al,RailWidth[di+5]	;y3
		cbw
		add	ax,RailLength[si+2]
		mov	WORD PTR YCrt[4],ax

;* x4, y4

		mov	al,RailWidth[di+6]	;x4
		cbw
		mov	XCrt[6],ax

		mov	al,RailWidth[di+7]	;y4
		cbw
		mov	WORD PTR YCrt[6],ax

		mov	cx,4

		call	TestInsideArea

		pop	di
		pop	si
		pop	ax

		jc	PassRail

SkipRail:	add	si,4		;next rail
		add	di,8

		test	al,al		;any more rails?
		jnz	ScanNextRail	;yes ->

FailRail:	mov	ax,SURFACE_UNKNOWN
		clc
		ret

PassRail:	mov	ax,SURFACE_RAILWAY
		ret

CheckRailways	ENDP

;----------------------------------------------------------------------------

;* CheckRunways - check runways
;*
;* pass: Xft
;*       Yft
;*       MapIndex
;* ret : cf = 0: not on runway
;*          ax = SURFACE_UNKNOWN
;*       cf = 1: on runway
;*          ax = SURFACE_RUNWAY
;* kill: assume all (except ax, cf)
;*
;* note: Refer to AIRFIELD.ASM, RWY_TAXI.ASM and TOWNS.ASM for data format etc.

CheckRunways	PROC	NEAR

		test	NoMansLand,1	;on active map?
		_JNZ	FailRunway	;no ->

		mov	bp,MapIndex
		mov	bl,SpecialLayer1[bp]

		cmp	bl,AIRFIELD_1	;airfield?
		_JB	FailRunway	;no ->
		cmp	bl,AIRFIELD_N	;airfield?
		_JA	FailRunway	;no ->

		sub	bl,AIRFIELD_1
		xor	bh,bh
		REPT	2
		shl	bx,1
		ENDM

		mov	si,AirfieldTable[bx]	;si -> runway list

RunwayLoop:	cmp	[si].RWY_DIR,-1		;end of list?
		_JE	FailRunway		;yes ->

		mov	di,[si].RWY_WIDTH
		mov	di,RunwayWidth[di]
		add	di,[si].RWY_DIR

;* end 1

		mov	cx,[si].RWY_X1		;    0 .. 64
		sub	cx,32			;  -32 .. 32
		mov	ch,cl			;-8192 .. 8192
		xor	cl,cl

		mov	bx,[si].RWY_Y1		;    0 .. 64
		sub	bx,32			;  -32 .. 32
		mov	bh,bl			;-8192 .. 8192
		xor	bl,bl

		mov	ax,cx
		add	ax,[di+0]		;x = x1 + xl
		mov	XCrt[0],ax
		mov	XCrt[8],ax		;repeat at end

		mov	ax,bx
		add	ax,[di+2]		;y = y1 + yl
		mov	WORD PTR YCrt[0],ax
		mov	WORD PTR YCrt[8],ax	;repeat at end

		mov	ax,cx
		add	ax,[di+4]		;x = x1 + xr
		mov	XCrt[6],ax

		mov	ax,bx
		add	ax,[di+6]		;y = y1 + yr
		mov	WORD PTR YCrt[6],ax

;* end 2

		mov	cx,[si].RWY_X2		;    0 .. 64
		sub	cx,32			;  -32 .. 32
		mov	ch,cl			;-8192 .. 8192
		xor	cl,cl

		mov	bx,[si].RWY_Y2		;    0 .. 64
		sub	bx,32			;  -32 .. 32
		mov	bh,bl			;-8192 .. 8192
		xor	bl,bl

		mov	ax,cx
		add	ax,[di+0]		;x = x2 + xl
		mov	XCrt[2],ax

		mov	ax,bx
		add	ax,[di+2]		;y = y2 + yl
		mov	WORD PTR YCrt[2],ax

		mov	ax,cx
		add	ax,[di+4]		;x = x2 + xr
		mov	XCrt[4],ax

		mov	ax,bx
		add	ax,[di+6]		;y = y2 + yr
		mov	WORD PTR YCrt[4],ax

		mov	cx,4
		push	si
		call	TestInsideArea
		pop	si
		jc	PassRunway

		add	si,RWY_REC_SIZE		;next runway

		jmp	RunwayLoop

FailRunway:	mov	ax,SURFACE_UNKNOWN
		clc
		ret

PassRunway:	mov	ax,SURFACE_RUNWAY
		ret

CheckRunways	ENDP

;----------------------------------------------------------------------------

;* CheckTaxiways - check taxiways
;*
;* pass: Xft
;*       Yft
;*       MapIndex
;* ret : cf = 0: not on taxiway
;*          ax = SURFACE_UNKNOWN
;*       cf = 1: on taxiway
;*          ax = SURFACE_TAXIWAY
;* kill: assume all (except ax, cf)
;*
;* note: Refer to AIRFIELD.ASM, RWY_TAXI.ASM and TOWNS.ASM for data format etc.

CheckTaxiways	PROC	NEAR

		test	NoMansLand,1	;on active map?
		_JNZ	FailTaxiway	;no ->

		mov	bp,MapIndex
		mov	bl,SpecialLayer1[bp]

		cmp	bl,AIRFIELD_1	;airfield?
		_JB	FailTaxiway	;no ->
		cmp	bl,AIRFIELD_N	;airfield?
		_JA	FailTaxiway	;no ->

		sub	bl,AIRFIELD_1
		xor	bh,bh
		REPT	2
		shl	bx,1
		ENDM

		mov	si,AirfieldTable[bx+2]	;si -> taxiway data

;------------------------------------
;* scan vertex list and make vertices
;------------------------------------

		mov	ax,FEATOBJ1
		mov	es,ax

		xor	di,di		;reset co-ord store index

		xor	bx,bx		;reset index (high byte always 0)

MakeVertexLoop:	ES_LODSB		;fetch end type
		cmp	al,-1		;end of vertex list?
		je	ContTaxi	;yes ->

		mov	bl,al

;* x val = (v / 2 - 64) * 256

		ES_LODSB		;fetch x index
		shr	al,1
		sub	al,64
		xor	ah,ah
		xchg	al,ah
		mov	cx,ax

;* y val = (v / 2 - 64) * 256

		ES_LODSB		;fetch y index
		shr	al,1
		sub	al,64
		xor	ah,ah
		xchg	al,ah
		mov	dx,ax

;* sort lh co-ord

		mov	ax,cx
		add	ax,EndType64[bx+0]	;x + xl
		mov	Xe[di],ax

		mov	ax,dx
		add	ax,EndType64[bx+2]	;y + yl
		mov	Ye[di],ax

		add	di,2

;* sort rh co-ord

		mov	ax,cx
		add	ax,EndType64[bx+4]	;x + xr
		mov	Xe[di],ax

		mov	ax,dx
		add	ax,EndType64[bx+6]	;y + yr
		mov	Ye[di],ax

		add	di,2

		jmp	MakeVertexLoop

;------------------------------------------------------
;* copy face data from FEATOBJ1 segment to DATA segment
;------------------------------------------------------

ContTaxi:	mov	ax,DATA
		mov	es,ax

		mov	ax,FEATOBJ1
		mov	ds,ax

		mov	si,[si]		;point to even face data

		lodsw			;fetch counter
		mov	cx,ax

		mov	di,OFFSET CopyBuffer

		FAST_MOVE

		mov	ax,DATA
		mov	ds,ax

;-------------
;* check faces
;-------------

		mov	si,OFFSET CopyBuffer

NextTaxiList:	lodsb			;fetch logical colour
		cmp	al,-1		;end of face list?
		je	FailTaxiway	;yes ->

		lodsb			;fetch first vertex index
		cmp	al,-1		;end of list?
		je	NextTaxiList	;yes ->

		mov	bl,al
		xor	bh,bh
		shl	bx,1

;* lh point

		mov	ax,Xe[bx]
		mov	XCrt[0],ax
		mov	XCrt[8],ax	;repeat first point at end

		mov	ax,Ye[bx]
		mov	WORD PTR YCrt[0],ax
		mov	WORD PTR YCrt[8],ax	;repeat first point at end

;* rh point

		mov	ax,Xe[bx+2]
		mov	XCrt[6],ax

		mov	ax,Ye[bx+2]
		mov	WORD PTR YCrt[6],ax

NextTaxiFace:	lodsb			;fetch next vertex index
		cmp	al,-1		;end of list?
		je	NextTaxiList	;yes ->

		mov	bl,al
		xor	bh,bh
		shl	bx,1

;* lh point

		mov	ax,Xe[bx]
		mov	XCrt[2],ax

		mov	ax,Ye[bx]
		mov	WORD PTR YCrt[2],ax

;* rh point

		mov	ax,Xe[bx+2]
		mov	XCrt[4],ax

		mov	ax,Ye[bx+2]
		mov	WORD PTR YCrt[4],ax

;* check taxiway face

		mov	cx,4
		push	si
		call	TestInsideArea
		pop	si
		jc	PassTaxiway

;* next taxiway face shares previous points

;* lh point

		mov	ax,XCrt[2]
		mov	XCrt[0],ax
		mov	XCrt[8],ax

		mov	ax,WORD PTR YCrt[2]
		mov	WORD PTR YCrt[0],ax
		mov	WORD PTR YCrt[8],ax

;* rh point

		mov	ax,XCrt[4]
		mov	XCrt[6],ax

		mov	ax,WORD PTR YCrt[4]
		mov	WORD PTR YCrt[6],ax

		jmp	NextTaxiFace

FailTaxiway:	mov	ax,SURFACE_UNKNOWN
		clc
		ret

PassTaxiway:	mov	ax,SURFACE_TAXIWAY
		ret

CheckTaxiways	ENDP

;----------------------------------------------------------------------------

;* TestInsideArea
;*
;* pass: cx = number of vertices (n)
;*       Xft, Yft = current position
;*       XCrt[], YCrt[] = xft, yft of vertices (-8192 .. 8191)
;*
;*	    x1, y1	;first point
;*	    x2, y2
;*	    .., ..
;*	    xn, yn	;num vertices
;*	    x1, y1	;first point repeated
;*
;* ret : cf = 0: outside area
;*       cf = 1: inside area
;* kill: assume all (except cf)
;*
;* note: This routine cyclic checks each edge of the given area with the 
;*	 current position. 
;*
;* 	 The co-ordinate system is arranged as follows:-
;*
;* 				       +y
;*  					³
;* 	 		         -x ÄÄÄÄÅÄÄÄÄ +x
;*  					³
;*		 		       -y
;*
;*	 If the current position is inside the area then all of the cyclic
;*       checks will return a +ve result. Any -ve result causes an "early
;*       out" condition.
;*
;*       The cyclic check is determined using cross products of vectors.
;*
;*       Dx1 = x1 - x2, Dy1 = y1 - y2
;*       Dx2 = x2 - x3, Dy2 = y2 - y3
;*
;*       result = (Dx2 * Dy1) - (Dx1 * Dy2)

TestInsideArea	PROC	NEAR

		xor	si,si

CyclicLoop:	mov	ax,XCrt[si]		;x1
		mov	bx,WORD PTR YCrt[si]	;y1

		add	si,2			;next vertex

		mov	bp,XCrt[si]		;x2
		mov	dx,WORD PTR YCrt[si]	;y2

		sub	ax,bp		;Dx1 = x1 - x2
		sub	bx,dx		;Dy1 = y1 - y2

		sub	bp,Xft		;Dx2 = x2 - x3
		sub	dx,Yft		;Dy2 = y2 - y3

		imul	dx		;Dx1 * Dy2

		xchg	ax,bp
		xchg	dx,bx

		imul	dx		;Dx2 * Dy1

		sub	ax,bp		;result = (Dx2 * Dy1) - (Dx1 * Dy2)
		sbb	dx,bx

		js	InsideFail	;not inside (early out) ->

		loop	CyclicLoop

InsidePass:	stc			;cf = 1 = inside	

		ret

InsideFail:	clc			;cf = 0 = outside

		ret

TestInsideArea	ENDP

;----------------------------------------------------------------------------

;* GroundCollision - ground object collision test
;*
;* pass: si -> VIEWPOINT <>
;* ret : cf = 0: no collision
;*          al = 0
;*       cf = 1: collision
;*          al = object number
;* kill: assume all (except al, cf)

GroundCollision	PROC	FAR

;--------------------------------------
;* check zft <= ground object threshold
;--------------------------------------

		cmp	WORD PTR [si].VP_ZFT_HI,0
		_JA	GndOk
		cmp	WORD PTR [si].VP_ZFT_LO,512
		_JA	GndOk

;---------------------
;* check on active map
;---------------------

		cmp	[si].VP_XSEC,31
		_JA	GndOk
		cmp	[si].VP_YSEC,31
		_JA	GndOk

;----------------
;* calc map index (xsec + ysec * 32)
;----------------

		mov	bp,[si].VP_YSEC
		
		REPT	5
		shl	bp,1
		ENDM

		add	bp,[si].VP_XSEC

;---------------------------
;* check for occupied sector
;---------------------------

		mov	al,SectorLayer1[bp]

		test	al,al
		_JZ	GndOk

;-----------------------------
;* sort sector object list ptr
;-----------------------------

		CALC_SEC_PTR

		mov	di,[bx].SEC_OBJ_PTR

;-------------------------
;* scan ground object list
;-------------------------

		mov	ax,SECDATA1
		mov	es,ax

;* check for end of list

GndLoop:	cmp	ES:[di].GND_NUM,-1
		je	DoneGnd

;* check abs(delta x) <= 256

		mov	ah,ES:[di].GND_XGRID
		xor	al,al
		sub	ax,8192
		sub	ax,[si].VP_XFT
		ABSV	ax

		cmp	ax,256
		ja	NextGnd

		mov	TmpXErr,ax

;* check abs(delta y) <= 256

		mov	ah,ES:[di].GND_YGRID
		xor	al,al
		sub	ax,8192
		sub	ax,[si].VP_YFT
		ABSV	ax

		cmp	ax,256
		ja	NextGnd

		mov	TmpYErr,ax

;-----------------------------
;* get object x, y and z sizes
;-----------------------------

		mov	bl,ES:[di].GND_NUM
		xor	bh,bh
		shl	bx,1		;*2 word index

		mov	bx,GroundTable[bx]

		mov	cx,GRNDOBJ1
		mov	ds,cx

		mov	ax,[bx].OBJ_HDR_XGRID
		mov	dx,[bx].OBJ_HDR_YGRID
		mov	bp,[bx].OBJ_HDR_ZGRID

		mov	bx,[bx].OBJ_HDR_SCALE

		mov	cx,DATA
		mov	ds,cx

		shr	bx,1		;/2 byte index

		mov	cl,ObjScaleConvert[bx]

		shl	ax,cl
		shl	dx,cl
		shl	bp,cl

;---------------------
;* check for collision
;---------------------

		cmp	WORD PTR [si].VP_ZFT_LO,bp
		ja	NextGnd

		cmp	TmpXErr,ax
		ja	NextGnd

		cmp	TmpYErr,dx
		jbe	GndHit

;---------------------------
NextGnd		LABEL	NEAR
;---------------------------

		add	di,GND_REC_SIZE

		jmp	GndLoop
	
;---------------------------
DoneGnd		LABEL	NEAR
;---------------------------

		mov	ax,DATA
		mov	es,ax

;---------------------------
GndOk		LABEL	NEAR
;---------------------------

		xor	al,al		;no collision (cf = 0)
		ret

;---------------------------
GndHit		LABEL	NEAR
;---------------------------

		mov	al,ES:[di].GND_NUM

		mov	dx,DATA
		mov	es,dx

		stc			;collision (cf = 1)
		ret

GroundCollision	ENDP

;----------------------------------------------------------------------------

;* StaticCollision - "static" mobile object collision test
;*
;* pass: si -> VIEWPOINT <>
;* ret : cf = 0: no collision
;*          al = 0
;*       cf = 1: collision
;*          al = object number
;* kill: assume all (except al, cf)

StaticCollision	PROC	FAR

;--------------------------------------
;* check zft <= static mobile threshold
;--------------------------------------

		cmp	WORD PTR [si].VP_ZFT_HI,0
		_JA	StatOk
		cmp	WORD PTR [si].VP_ZFT_LO,128
		_JA	StatOk

;---------------------
;* check on active map
;---------------------

		cmp	[si].VP_XSEC,31
		_JA	StatOk
		cmp	[si].VP_YSEC,31
		_JA	StatOk

;----------------
;* calc map index (xsec + ysec * 32)
;----------------

		mov	bp,[si].VP_YSEC
		
		REPT	5
		shl	bp,1
		ENDM

		add	bp,[si].VP_XSEC

;---------------------------
;* check for occupied sector
;---------------------------

		mov	bl,MobileLayer1[bp]

		test	bl,bl
		_JZ	StatOk

;-----------------------------
;* sort sector object list ptr
;-----------------------------

		xor	bh,bh
		shl	bx,1		;*2 word index

		mov	di,MobSectorTable[bx]

;-------------------------
;* scan ground object list
;-------------------------

		mov	ax,MSECDATA1
		mov	es,ax

;* check for end of list

StatLoop:	cmp	ES:[di].STAT_NUM,-1
		je	DoneStat

;* check abs(delta x) <= 128

		mov	ax,ES:[di].STAT_XFT
		sub	ax,[si].VP_XFT
		ABSV	ax

		cmp	ax,128
		ja	NextStat

		mov	TmpXErr,ax

;* check abs(delta y) <= 128

		mov	ax,ES:[di].STAT_YFT
		sub	ax,[si].VP_YFT
		ABSV	ax

		cmp	ax,128
		ja	NextStat

		mov	TmpYErr,ax

;-----------------------------
;* get object x, y and z sizes
;-----------------------------

		mov	bl,ES:[di].STAT_NUM
		xor	bh,bh
		shl	bx,1		;*2 word index

		mov	bx,MobileTable[bx]

		mov	cx,MOBOBJ1
		mov	ds,cx

		mov	ax,[bx].OBJ_HDR_XGRID
		mov	dx,[bx].OBJ_HDR_YGRID
		mov	bp,[bx].OBJ_HDR_ZGRID

		mov	bx,[bx].OBJ_HDR_SCALE

		mov	cx,DATA
		mov	ds,cx

		shr	bx,1		;/2 byte index

		mov	cl,ObjScaleConvert[bx]

		shl	ax,cl
		shl	dx,cl
		shl	bp,cl

;---------------------
;* check for collision
;---------------------

		cmp	WORD PTR [si].VP_ZFT_LO,bp
		ja	NextStat

		cmp	TmpXErr,ax
		ja	NextStat

		cmp	TmpYErr,dx
		jbe	StatHit

;---------------------------
NextStat	LABEL	NEAR
;---------------------------

		add	di,STAT_REC_SIZE

		jmp	StatLoop
	
;---------------------------
DoneStat	LABEL	NEAR
;---------------------------

		mov	ax,DATA
		mov	es,ax

;---------------------------
StatOk		LABEL	NEAR
;---------------------------

		xor	al,al		;no collision (cf = 0)
		ret

;---------------------------
StatHit		LABEL	NEAR
;---------------------------

		mov	al,ES:[di].STAT_NUM

		mov	dx,DATA
		mov	es,dx

		stc			;collision (cf = 1)
		ret

StaticCollision	ENDP

;----------------------------------------------------------------------------

;* MobileCollision - mobile object collision test
;*
;* pass: si -> VIEWPOINT <>
;*       di -> MOBILE <> + VIEWPOINT <> of source (-1 = no source)
;*             (required to prevent collision with source object)
;* ret : cf = 0: no collision
;*          al = 0
;*       cf = 1: collision
;*          al = object number
;* kill: assume all (except al, cf)

MobileCollision	PROC	FAR

		mov	SourcePtr,di

;--------------------------
;* locate mobiles in sector
;--------------------------

		mov	ax,[si].VP_XSEC
		mov	dx,[si].VP_YSEC

		mov	di,si

		call	LocateMobiles
		_JC	MobOk

		xchg	si,di		;si -> viewpoint, di -> mobiles

;--------------
;* scan mobiles
;--------------

;* check for end of list

MobLoop:	cmp	di,-1
		_JE	MobOk

;* check for self

		cmp	di,SourcePtr
		_JE	NextMob

;* check abs(delta x) <= 128

		mov	ax,_VP_XFT[di]
		sub	ax,[si].VP_XFT
		ABSV	ax

		cmp	ax,128
		ja	NextMob

		mov	TmpXErr,ax

;* check abs(delta y) <= 128

		mov	ax,_VP_YFT[di]
		sub	ax,[si].VP_YFT
		ABSV	ax

		cmp	ax,128
		ja	NextMob

		mov	TmpYErr,ax

;* check abs(delta z) <= 128

		mov	ax,WORD PTR _VP_ZFT_LO[di]
		mov	dx,WORD PTR _VP_ZFT_HI[di]
		sub	ax,WORD PTR [si].VP_ZFT_LO
		sbb	dx,WORD PTR [si].VP_ZFT_HI

		jns	@F
		NEG32	dx,ax

@@:		cmp	dx,0
		ja	NextMob
		cmp	ax,128
		ja	NextMob

		mov	TmpZErr,ax

;-----------------------------
;* get object x, y and z sizes
;-----------------------------

		mov	bl,[di].MOB_NUM
		xor	bh,bh
		shl	bx,1		;*2 word index

		mov	bx,MobileTable[bx]

		mov	cx,MOBOBJ1
		mov	ds,cx

		mov	ax,[bx].OBJ_HDR_XGRID
		mov	dx,[bx].OBJ_HDR_YGRID
		mov	bp,[bx].OBJ_HDR_ZGRID

		mov	bx,[bx].OBJ_HDR_SCALE

		mov	cx,DATA
		mov	ds,cx

		shr	bx,1		;/2 byte index

		mov	cl,ObjScaleConvert[bx]

		shl	ax,cl
		shl	dx,cl
		shl	bp,cl

;---------------------
;* check for collision
;---------------------

		cmp	TmpXErr,ax
		ja	NextMob

		cmp	TmpYErr,dx
		ja	NextMob

		cmp	TmpZErr,bp
		jbe	MobHit

;---------------------------
NextMob		LABEL	NEAR
;---------------------------

		mov	di,[di].MOB_LINK_PTR

		jmp	MobLoop

;---------------------------
MobOk		LABEL	NEAR
;---------------------------

		xor	al,al		;no collision (cf = 0)
		ret

;---------------------------
MobHit		LABEL	NEAR
;---------------------------

		mov	al,[di].MOB_NUM

		stc			;collision (cf = 1)
		ret

MobileCollision	ENDP

;----------------------------------------------------------------------------

;* TreeCollision - tree object collision test
;*
;* pass: si -> VIEWPOINT <>
;* ret : cf = 0: no collision
;*          al = 0
;*       cf = 1: collision
;*          al = object number
;* kill: assume all (except al, cf)

TreeCollision	PROC	FAR

;---------------------
;* check trees enabled
;---------------------

		test	TreesEnabled,1
		jz	TreesOk

;------------------------------
;* check zft <= trees threshold
;------------------------------

		cmp	WORD PTR [si].VP_ZFT_HI,0
		ja	TreesOk
		cmp	WORD PTR [si].VP_ZFT_LO,128
		ja	TreesOk

;---------------------------------
;* calc map index with wrap around (xsec + ysec * 32)
;---------------------------------

		mov	ax,[si].VP_XSEC
		mov	bp,[si].VP_YSEC

		and	ax,MAP_X_WRAP
		and	bp,MAP_Y_WRAP
		
		REPT	5
		shl	bp,1
		ENDM

		add	bp,ax

;---------------------------------
;* select layout wrt xsec and ysec (via MapIndex so values are wrapped)
;---------------------------------

		mov	ax,bp
		mov	bx,bp
		REPT	4
		shr	bx,1
		ENDM
		and	ax,01b		;x
		and	bx,10b		;y
		or	bx,ax
		shl	bx,1		;*2 word index

		mov	bx,TreeLayouts[bx]

;------------------
;* scan tree layers
;------------------

		mov	al,TreeLayer1[bp]
		mov	ah,GND_COPSEA
		call	ScanTrees
		jc	TreesHit

		mov	al,TreeLayer2[bp]
		mov	ah,GND_COPSEB
		call	ScanTrees
		jc	TreesHit

		mov	al,TreeLayer3[bp]
		mov	ah,GND_COPSEC
		call	ScanTrees
		jc	TreesHit

		mov	al,TreeLayer4[bp]
		mov	ah,GND_COPSED
		call	ScanTrees
		jc	TreesHit

;---------------------------
TreesOk		LABEL	NEAR
;---------------------------

		xor	al,al		;no collision (cf = 0)

;---------------------------
TreesHit	LABEL	NEAR
;---------------------------

		ret

TreeCollision	ENDP

;----------------------------------------------------------------------------

;* ScanTrees
;*
;* pass: al = tree layout
;*       ah = copse object
;*       bx = tree position index
;*       si -> VIEWPOINT <>
;* ret : cf = 0: no collision
;*          al = 0
;*          bx = updated tree position index (for next copse)
;*       cf = 1: collision
;*          al = object number
;* kill: ah, cx, dx, di, flags (except cf)

ScanTrees	PROC	NEAR

		push	ax		;store copse object
		push	bx		;store tree index
		push	bp		;store map index

;-----------------------------
;* get object x, y and z sizes
;-----------------------------

		push	bx

		mov	bl,ah
		xor	bh,bh
		shl	bx,1		;*2 word index

		mov	bx,GroundTable[bx]

		mov	cx,GRNDOBJ1
		mov	ds,cx

		mov	di,[bx].OBJ_HDR_XGRID
		mov	bp,[bx].OBJ_HDR_YGRID
		mov	dx,[bx].OBJ_HDR_ZGRID

		mov	bx,[bx].OBJ_HDR_SCALE

		mov	cx,DATA
		mov	ds,cx

		shr	bx,1		;/2 byte index

		mov	cl,ObjScaleConvert[bx]

		shl	di,cl
		shl	bp,cl
		shl	dx,cl

		pop	bx

;* check zft <= tree height

		cmp	WORD PTR [si].VP_ZFT_LO,dx
		ja	MissTrees

		mov	cl,al

;---------------------------
ScanTreeLoop	LABEL	NEAR
;---------------------------

		shr	cl,1
		jnc	NextTree

;* check abs(delta x) <= x size

		mov	ah,[bx+0]	;xgrid
		xor	al,al
		sub	ax,8192
		sub	ax,[si].VP_XFT
		ABSV	ax

		cmp	ax,di
		ja	NextTree

;* check abs(delta y) <= y size

		mov	ah,[bx+1]	;ygrid
		xor	al,al
		sub	ax,8192
		sub	ax,[si].VP_YFT
		ABSV	ax

		cmp	ax,bp
		jbe	HitTrees

;---------------------------
NextTree	LABEL	NEAR
;---------------------------

		add	bx,2		;next index

		test	cl,cl
		jnz	ScanTreeLoop

;---------------------------
MissTrees	LABEL	NEAR
;---------------------------

		pop	bp		;restore map index
		pop	bx		;restore tree index
		pop	ax		;restore copse object

		add	bx,8*2		;update trees index

		xor	al,al		;no collision (cf = 0)
		ret

;---------------------------
HitTrees	LABEL	NEAR
;---------------------------

		pop	bp		;restore map index
		pop	bx		;restore tree index
		pop	ax		;restore copse object

		mov	al,ah

		stc			;collision (cf = 1)
		ret

ScanTrees	ENDP

;----------------------------------------------------------------------------

;* CraterCollision - crater collision test
;*
;* pass: si -> VIEWPOINT <>
;* ret : cf = 0: no collision
;*          al = 0
;*       cf = 1: collision
;*          al = object number
;* kill: assume all (except al, cf)

CraterCollision	PROC	FAR

;---------------
;* check zft = 0
;---------------

		mov	ax,WORD PTR [si].VP_ZFT_LO
		or	ax,WORD PTR [si].VP_ZFT_HI
		_JNZ	CratersOk

;------------------
;* scan crater loop
;------------------

		mov	ax,SEG CraterBuffer
		mov	es,ax

		mov	di,OFFSET CraterBuffer

		mov	cx,NUM_CRATERS

;* check for crater not in use (search no further)

CraterLoop:	mov	al,ES:[di].CRATER_TYPE

		cmp	al,CRATER_NULL
		_JE	DoneCraters

;* ignore "shell" craters (too small)

		cmp	al,CRATER_SHELL
		je	NextCrater

;* check for xsec match

		mov	ax,ES:[di].CRATER_XSEC
		cmp	ax,[si].VP_XSEC
		jne	NextCrater

;* check for ysec match

		mov	ax,ES:[di].CRATER_YSEC
		cmp	ax,[si].VP_YSEC
		jne	NextCrater

;* check abs(delta x) <= 128

		mov	ax,ES:[di].CRATER_XFT
		sub	ax,[si].VP_XFT
		ABSV	ax

		cmp	ax,128
		ja	NextCrater

		mov	TmpXErr,ax

;* check abs(delta y) <= 128

		mov	ax,ES:[di].CRATER_YFT
		sub	ax,[si].VP_YFT
		ABSV	ax

		cmp	ax,128
		ja	NextCrater

		mov	TmpYErr,ax

;-----------------------------
;* get object x, y and z sizes
;-----------------------------

		mov	bp,cx

		mov	bl,ES:[di].CRATER_TYPE
		xor	bh,bh
		mov	bl,CraterNum[bx]

		shl	bx,1		;*2 word index

		mov	bx,MobileTable[bx]

		mov	cx,MOBOBJ1
		mov	ds,cx

		mov	ax,[bx].OBJ_HDR_XGRID
		mov	dx,[bx].OBJ_HDR_YGRID

		mov	bx,[bx].OBJ_HDR_SCALE

		mov	cx,DATA
		mov	ds,cx

		shr	bx,1		;/2 byte index

		mov	cl,ObjScaleConvert[bx]

		shl	ax,cl
		shl	dx,cl

		mov	cx,bp

;---------------------
;* check for collision
;---------------------

		cmp	TmpXErr,ax
		ja	NextCrater

		cmp	TmpYErr,dx
		jbe	CraterHit

;---------------------------
NextCrater	LABEL	NEAR
;---------------------------

		add	di,CRATER_REC_SIZE

		_LOOP	CraterLoop
	
;---------------------------
DoneCraters	LABEL	NEAR
;---------------------------

		mov	ax,DATA
		mov	es,ax

;---------------------------		
CratersOk	LABEL	NEAR
;---------------------------		
	
		xor	al,al		;no collision (cf = 0)
		ret

;---------------------------
CraterHit	LABEL	NEAR
;---------------------------

		mov	al,ES:[di].CRATER_TYPE
		mov	bx,OFFSET CraterNum
		xlat

		mov	dx,DATA
		mov	es,dx

		stc			;collision (cf = 1)
		ret

CraterCollision	ENDP

VISCODE		ENDS

;============================================================================

		END

