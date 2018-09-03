;****************************************************************************
;*
;* MOVEMAP.ASM
;* 
;* Moving map for MFD or TAB displays.
;*
;* 05.02.1992 - KJB
;* 25.02.1992 - KJB - Code moved from VISCODE to PANCODE.
;* 01.04.1992 - KJB - MAP_HALF_DISP mode added.
;* 05.04.1992 - KJB - DrawMapBorder added.
;* 14.04.1992 - KJB - Specials reorganized.
;* 11.05.1992 - KJB - Draw lake features only.
;* 01.10.1992 - KJB - Map origin display options added for MAP_MFD_DISP.
;* 05.10.1992 - KJB - "radar" features added.
;* 12.10.1992 - KJB - Floating waypoint position added.
;* 20.10.1992 - KJB - Map origin display options added for MAP_TAB_DISP.
;* 21.10.1992 - KJB - Aircraft position added.
;* 22.10.1992 - KJB - Trees no longer drawn.
;* 02.11.1992 - KJB - Current waypoint position added.
;* 24.11.1992 - KJB - Active runway colour added.
;* 25.11.1992 - KJB - Aircraft position allowed off active map.
;* 02.03.1993 - KJB - Different allied and enemy object colours added.
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	UpdateMovingMap
		PUBLIC	DrawMapBorder

		PUBLIC	CurrentWPX
		PUBLIC	CurrentWPY
		PUBLIC	FloatWPX
		PUBLIC	FloatWPY
		PUBLIC	ACDatumX
		PUBLIC	ACDatumY

		PUBLIC	MAP_MFD_DISP
		PUBLIC	MAP_TAB_DISP
		PUBLIC	MAP_HALF_DISP
		PUBLIC	MAP_FULL_DISP
		PUBLIC	MAP_ZOOM1
		PUBLIC	MAP_ZOOM2
		PUBLIC	MAP_ZOOM3
		PUBLIC	MAP_ZOOM4
		PUBLIC	MAP_ZOOM5
		PUBLIC	MAP_ZOOM6
		PUBLIC	MAP_ORG_CENTRE
		PUBLIC	MAP_ORG_BASE
PUBLIC DispType ;Original was blank
EXTRN SplitScreenBigMapIsOn:BYTE
EXTRN EScopeToggle:BYTE ;Original was blank
		EXTRN	BlockFill:FAR
		EXTRN	PolyFill:FAR
		EXTRN	PolyLine:FAR
		EXTRN	LineDraw:FAR
		EXTRN	SetPixel:FAR
		EXTRN	VSetViewport:FAR
		EXTRN	VSetRotation:FAR
		EXTRN	VCalcOutCodes:FAR
		EXTRN	VQuickOutCodes:FAR
		EXTRN	VPolyClip:FAR
		EXTRN	VPolyLineClip:FAR
		EXTRN	VQuickLineClip:FAR
		EXTRN	VDotClip:FAR
		EXTRN	MoveViewpoint:FAR
		EXTRN	LocateMobiles:FAR
		EXTRN	CalcGndHeight:FAR

		EXTRN	FeatureTable:WORD
		EXTRN	RiverTable:WORD
		EXTRN	SectorTable:WORD
		EXTRN	AirfieldTable:WORD
		EXTRN	TownTable:WORD
		EXTRN	SinTable:WORD
		EXTRN	CosTable:WORD
		EXTRN	MobSectorTable:WORD
		EXTRN	M_MOBILE:WORD
		EXTRN	M_VIEW:WORD
		EXTRN	TMP_VIEW:WORD
		EXTRN	FloatWP:WORD
		EXTRN	WayTotal:WORD
		EXTRN	WPPtr:WORD

		EXTRN	RoadLayer1:BYTE
		EXTRN	RoadLayer2:BYTE
		EXTRN	RoadLayer3:BYTE
		EXTRN	RoadLayer4:BYTE
		EXTRN	RailLayer1:BYTE
		EXTRN	FeatureLayer1:BYTE
		EXTRN	RiverLayer1:BYTE
		EXTRN	HillLayer1:BYTE
		EXTRN	HillLayer2:BYTE
		EXTRN	HillLayer3:BYTE
		EXTRN	HillLayer4:BYTE
		EXTRN	HillLayer5:BYTE
		EXTRN	HillLayer6:BYTE
		EXTRN	HillLayer7:BYTE
		EXTRN	HillLayer8:BYTE
		EXTRN	HillLayer9:BYTE
		EXTRN	HillFaceList0:BYTE
		EXTRN	HillFaceList1:BYTE
		EXTRN	HillFaceList2:BYTE
		EXTRN	HillFaceList3:BYTE
		EXTRN	HillFaceList4:BYTE
		EXTRN	HillFaceList5:BYTE
		EXTRN	HillFaceList6:BYTE
		EXTRN	HillFaceList7:BYTE
		EXTRN	SectorLayer1:BYTE
		EXTRN	SpecialLayer1:BYTE
		EXTRN	MobileLayer1:BYTE
		EXTRN	SctrGameLayer1:BYTE

		EXTRN	AIRFIELD_1:ABS
		EXTRN	AIRFIELD_N:ABS
		EXTRN	TOWN_1:ABS
		EXTRN	TOWN_N:ABS
		EXTRN	LAKE_FEATURE:ABS

;============================================================================

		INCLUDE	MAINDATA.INC

		INCLUDE	\VISUAL\VISEXTRN.INC
		INCLUDE	\VISUAL\VISMACRO.INC
		INCLUDE	\VISUAL\VISDATA.INC
		INCLUDE	\VISUAL\VSCREEN.INC
		INCLUDE	\VISUAL\PALETTES.INC
		INCLUDE	\VISUAL\RWY_TAXI.INC
		INCLUDE	\VISUAL\GNDLIST.INC

		INCLUDE	\LIB8086\USEFUL.INC
		INCLUDE	\LIB8086\TRIG.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

;-----------
;* map datum
;-----------

MAP_VIEW	VIEWPOINT <>

;--------------
;* map viewport
;--------------

VP		VIEWPORT <>

VP_FULL		VIEWPORT <>

;-------------------
;* map display types
;-------------------

MAP_MFD_DISP	EQU	0		;MFD display
MAP_TAB_DISP	EQU	2		;TAB display
MAP_HALF_DISP	EQU	4		;half screen display
MAP_FULL_DISP	EQU	4		;full screen display

DispType	DW	MAP_MFD_DISP	;display type

;-----------------
;* map zoom levels
;-----------------

MAP_ZOOM1	EQU	0		;8 pixels / sector
MAP_ZOOM2	EQU	2		;16 pixels / sector
MAP_ZOOM3	EQU	4		;32 pixels / sector
MAP_ZOOM4	EQU	6		;64 pixels / sector
MAP_ZOOM5	EQU	8		;128 pixels / sector
MAP_ZOOM6	EQU	10		;256 pixels / sector

Zoom		DW	MAP_ZOOM1	;zoom level

;----------------------------
;* map origin display options
;----------------------------

;* note: The MAP_ORG_BASE option is only implemented on MAP_MFD_DISP and
;*	 MAP_TAB_DISP. MAP_HALF_DISP defaults to MAP_ORG_CENTRE.

MAP_ORG_CENTRE	EQU	0		;map origin at display centre
MAP_ORG_BASE	EQU	2		;map origin at display base

Origin		DW	MAP_ORG_CENTRE

;* MFD base origin offset wrt zoom

;* offset = ((MFD depth / 2) / pixels per sector) * sector size
;*
;*        = (24 / pixels per sector) * 16384

MFDBaseOrgTable	LABEL	WORD

;*		DW	offset, result scale up

		DW	24576, 1	;ZOOM1 (result << 1)
		DW	24576, 0	;ZOOM2
		DW	12288, 0	;ZOOM3
		DW	 6144, 0	;ZOOM4
		DW	 3072, 0	;ZOOM5
		DW	 1536, 0	;ZOOM6

;* TAB base origin offset wrt zoom

;* offset = ((TAB depth / 2) / pixels per sector) * sector size
;*
;*        = (36 / pixels per sector) * 16384

TABBaseOrgTable	LABEL	WORD

;*		DW	offset, result scale up

		DW	18432, 2	;ZOOM1 (result << 2)
		DW	18432, 1	;ZOOM2 (result << 1)
		DW	18432, 0	;ZOOM3
		DW	 9216, 0	;ZOOM4
		DW	 4608, 0	;ZOOM5
		DW	 2304, 0	;ZOOM6

;--------------
;* ground radar
;--------------

RadarRange	DW	0		;range in sectors

GndRadar	DB	0		;1 = ground radar display

;* b0: quad +x, +y (00b)
;* b1: quad +x, -y (01b)
;* b2: quad -x, +y (10b)
;* b3: quad -x, -y (11b)

QuadTested	DB	0		;b0 .. b3 = 1 = quadrant tested
QuadResult	DB	0		;b0 .. b3 = 0 = quadrant visible

QuadMask	DB	0

		EVEN

;---------------------------
;* current waypoint position (relative to origin)
;---------------------------

CurrentWPX	DW	-1		;-1, -1 = invalid / non-visible
CurrentWPY	DW	-1

;----------------------------
;* floating waypoint position (relative to origin)
;----------------------------

FloatWPX	DW	-1		;-1, -1 = invalid / non-visible
FloatWPY	DW	-1

;-------------------
;* aircraft position (relative to origin)
;-------------------

ACDatumX	DW	-1		;-1, -1 = non-visible
ACDatumY	DW	-1

;------------------
;* sector scan size
;------------------

ScanSize	DW	9		;(example: 9 = 9 * 9 sector scan)

ScanOffset	DW	-(9/2)		;-(scan size / 2)

;--------------
;* sector scale
;--------------

;* SctrScale = 0 (*1) for 64 pixels / sector or less
;*           = 1 (*2) for 128 pixels / sector
;*           = 2 (*4) for 256 pixels / sector
;* 
;* WARNING: If SctrScale needs to be > 2 then redo XGrid and YGrid calculations.

SctrScale	DB	0,0

;---------------------
;* width / depth table (wrt DispType)
;---------------------

;* 		DW	width, depth

DispSizeTableHalf	DW	 64,  48	;MAP_MFD_DISP
		DW	 96,  72	;MAP_TAB_DISP
		DW	320, 105	;MAP_HALF_DISP - original was 200

DispSizeTableFull	DW	 64,  48	;MAP_MFD_DISP
		DW	 96,  72	;MAP_TAB_DISP
		DW	320, 200	;MAP_HALF_DISP - original was 200		
		
;--------------------------
;* scan size / scale tables (wrt DispType and Zoom)
;--------------------------

DispDataTable	DW	OFFSET MFDTable	;MAP_MFD_DISP
		DW	OFFSET TABTable	;MAP_TAB_DISP
		DW	OFFSET HalfTable	;MAP_HALF_DISP
		DW  OFFSET FullTable

;DispDataTableFull	DW	OFFSET MFDTable	;MAP_MFD_DISP
;		DW	OFFSET TABTable	;MAP_TAB_DISP
;		DW	OFFSET FullTable	;MAP_HALF_DISP		
		
;* 		DB	scan size, sector scale, scale up count, scale down count

MFDTable	LABEL	BYTE		;MAP_MFD_DISP

		DB	 9, 0, 5, 8	;ZOOM1
		DB	 5, 0, 6, 8	;ZOOM2
		DB	 3, 0, 7, 8	;ZOOM3
		DB	 3, 0, 7, 7	;ZOOM4
		DB	 3, 1, 6, 6	;ZOOM5
		DB	 3, 2, 5, 5	;ZOOM6

;* 		DB	scan size, sector scale, scale up count, scale down count

TABTable	LABEL	BYTE		;MAP_TAB_DISP

		DB	13, 0, 5, 8	;ZOOM1
		DB	 7, 0, 6, 8	;ZOOM2
		DB	 5, 0, 6, 7	;ZOOM3
		DB	 3, 0, 7, 7	;ZOOM4
		DB	 3, 1, 6, 6	;ZOOM5
		DB	 3, 2, 5, 5	;ZOOM6

;* 		DB	scan size, sector scale, scale up count, scale down count

HalfTable	LABEL	BYTE		;MAP_HALF_DISP

		DB	45, 0, 3, 6	;ZOOM1
		DB	23, 0, 4, 6	;ZOOM2
		DB	13, 0, 5, 6	;ZOOM3
		DB	 7, 0, 6, 6	;ZOOM4
		DB	 3, 1, 6, 6	;ZOOM5
		DB	 3, 2, 5, 5	;ZOOM6

;* 		DB	scan size, sector scale, scale up count, scale down count

FullTable	LABEL	BYTE		;MAP_HALF_DISP

		DB	45, 0, 3, 6	;ZOOM1
		DB	23, 0, 4, 6	;ZOOM2
		DB	13, 0, 5, 6	;ZOOM3
		DB	 7, 0, 6, 6	;ZOOM4
		DB	 3, 1, 6, 6	;ZOOM5
		DB	 3, 2, 5, 5	;ZOOM6
		
		
;--------------------------------
;* viewpoint sector grid position
;--------------------------------

XGrid		DW	0		;vp sector x grid
YGrid		DW	0		;vp sector y grid

;---------------------------
;* sector reference position (lower left hand corner of sector)
;---------------------------

XSecRef		DW	0		;xsec reference
YSecRef		DW	0		;ysec reference

;----------------
;* current sector
;----------------

XSec		DW	0
YSec		DW	0

;-----------------------
;* road end offset table
;-----------------------

;*		DW	x offset, y offset

RoadEndTable	DW	  0,  16	;N
		DW	 16,  16 	;NE
		DW	 16,   0	;E
		DW	 16, -16	;SE
		DW	  0, -16	;S
		DW	-16, -16	;SW
		DW	-16,   0	;W
		DW	-16,  16	;NW

;--------------------------
;* railway end offset table
;--------------------------

;*		DW	x offset, y offset

RailEndTable	DW	  0,  32	;N
		DW	 32,  32 	;NE
		DW	 32,   0	;E
		DW	 32, -32	;SE
		DW	  0, -32	;S
		DW	-32, -32	;SW
		DW	-32,   0	;W
		DW	-32,  32	;NW

;----------------------------
;* road / railway node centre
;----------------------------

NodeX		DW	0
NodeY		DW	0

;-----------
;* hill data
;-----------

;* spot height EQUates

$ZA		EQU	0
$ZB		EQU	2
$ZC		EQU	4
$ZD		EQU	6
$ZE		EQU	8
$ZF		EQU	10
$ZG		EQU	12
$ZH		EQU	14
$ZI		EQU	16

;----------------------
;* ground object colour (wrt side)
;----------------------

GndObjectCol	DB	0

		EVEN

DATA		ENDS

;============================================================================

FEATOBJ1	SEGMENT PARA PUBLIC 'DATA'

FEATOBJ1	ENDS

;============================================================================

SECDATA1	SEGMENT PARA PUBLIC 'DATA'

SECDATA1	ENDS

;============================================================================

MSECDATA1	SEGMENT PARA PUBLIC 'DATA'

MSECDATA1	ENDS

;============================================================================

PANCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:PANCODE
		ASSUME DS:DATA

;* UpdateMovingMap
;*
;* pass: ax = display type
;*       cx = x origin
;*       bl = y origin
;*	 bh = ground radar flag (1 = ground radar (MAP_MFD_DISP only))
;*       dx = zoom level
;*       si -> VIEWPOINT data block
;*       bp = origin
;* ret : nothing
;* kill: assume all

UpdateMovingMap	PROC	FAR

		call	InitMovingMap

		call	DrawGround

;------------------------------------------
;* for y sector = -ScanOffset to ScanOffset
;------------------------------------------

		mov	cx,ScanSize
		mov	di,ScanOffset

ScanYLoop:	push	cx
		push	di

;------------------------------------------
;* for x sector = -ScanOffset to ScanOffset
;------------------------------------------

		mov	cx,ScanSize
		mov	si,ScanOffset

ScanXLoop:	push	cx
		push	si
		push	di

;-------------------------
;* calc sector map co-ords
;-------------------------

		mov	ax,MAP_VIEW.VP_XSEC
		add	ax,si		;x sec = vp x sec + x sec offset
		mov	dx,ax
		mov	ax,MAP_VIEW.VP_YSEC
		add	ax,di		;y sec = vp y sec + y sec offset

		mov	XSec,dx
		mov	YSec,ax

;-------------------------------------------------------
;* is the sector inside the map area or in no mans land?
;-------------------------------------------------------

		mov	bl,1		;assume outside map

		cmp	dx,32		;x sec inside map?
		jae	@F		;no ->
		cmp	ax,32		;y sec inside map?
		jae	@F		;no ->

		xor	bl,bl

@@:		mov	NoMansLand,bl
	
;-------------------------------------
;* sector wrap around for no mans land
;-------------------------------------

		and	dx,MAP_X_WRAP
		and	ax,MAP_Y_WRAP
		
;-------------------------------------
;* calc map index = x sec + y sec * 32
;-------------------------------------

		REPT	5
		shl	ax,1
		ENDM
		add	ax,dx

		mov	MapIndex,ax

;--------------------------------
;* calc sector reference position (lower left hand corner of sector)
;--------------------------------

		mov	cl,6		;prime for *64

		add	cl,SctrScale	;prime for * 64 * sector scale

;* XSecRef = x sec offset * 64 * sector scale - XGrid

		sal	si,cl
		sub	si,XGrid
		mov	XSecRef,si

;* YSecRef = -(y sec offset) * 64 * sector scale - YGrid

		neg	di		;flip y

		sal	di,cl
		sub	di,YGrid
		mov	YSecRef,di

;------------------------
;* test if sector visible
;------------------------

		call	SectorReject
		jc	SkipSector	;sector non-visible ->

;-------------
;* draw sector
;-------------

		call	DrawFeatures
		call	DrawHills
		call	DrawRivers
		call	DrawRoads
		call	DrawRailways

		call	SortACDatum

		test	NoMansLand,1	;no man's land?
		jnz	SkipSector	;yes ->

		call	DrawSpecials
		call	DrawGndObjects

		call	SortCurrentWP
		call	SortFloatWP

;* Only draw mobiles if in ground radar mode. Draw mobiles last so that they
;* have highest priority. Only show mobiles on active map (they should never
;* stray outside and if they do then they are of no interest).

		test	GndRadar,1	;ground radar mode?
		jz	SkipSector	;no ->

;* check sector is in radar range

		mov	ax,M_VIEW.VP_XSEC
		sub	ax,XSec
		ABSV	ax
		cmp	ax,RadarRange	;in range?
		ja	SkipSector	;no ->

		mov	ax,M_VIEW.VP_YSEC
		sub	ax,YSec
		ABSV	ax
		cmp	ax,RadarRange	;in range?
		ja	SkipSector	;no ->

		mov	QuadTested,0000b	;clear quad tested flags
		mov	QuadResult,1111b	;clear quad result flags

		call	DrawStatMobiles
		call	DrawMobiles

;---------------
;* next x sector
;---------------

SkipSector:	pop	di
		pop	si
		pop	cx
		inc	si		;x = x + 1
		_LOOP	ScanXLoop

;---------------
;* next y sector
;---------------

		pop	di
		pop	cx
		inc	di		;y = y + 1
		_LOOP	ScanYLoop

		ret

UpdateMovingMap	ENDP

;----------------------------------------------------------------------------

;* InitMovingMap - initialize moving map
;*
;* pass: ax = display type
;*       cx = x origin
;*       bl = y origin
;*	 bh = ground radar flag (1 = ground radar (MAP_MFD_DISP only))
;*       dx = zoom level
;*       si -> VIEWPOINT data block
;*       bp = origin
;* ret : nothing
;* kill: assume all

InitMovingMap	PROC	NEAR

		mov	DispType,ax
	
	;Original was blank
	cmp SplitScreenBigMapIsOn,1
	jne frankie_1
	        cmp	DispType,MAP_HALF_DISP	
			je @F		                
			jmp hopstepleap2		
	@@:				
	        cmp EScopeToggle,10		
			jbe check2		
			ret		
	check2:  		
	        cmp EScopeToggle,0		
			jg assign096		
			ret		
	assign096: 				
	        mov cx, 0		
			mov bl,96		
	hopstepleap2:		
	;Original was blank
	frankie_1:
		mov	GndRadar,bh

		mov	Zoom,dx

		mov	Origin,bp

		cmp SplitScreenBigMapIsOn,1
		jne @F
		mov	VP.V_X_ORG,cx
		mov	BYTE PTR VP.V_Y_ORG,bl
		jmp frankie_6
@@:		
		mov	VP_FULL.V_X_ORG,cx
		mov	BYTE PTR VP_FULL.V_Y_ORG,bl

frankie_6:
		COPY_VP	MAP_VIEW,si

;-------------
;* sort origin
;-------------

		;cmp	DispType,MAP_HALF_DISP	;BIG display?
		cmp	DispType,MAP_FULL_DISP	;BIG display?
		je	SortDisp		;yes ->

		cmp	Origin,MAP_ORG_CENTRE	;map origin at display centre?
		je	SortDisp		;yes ->

;* lookup offset wrt zoom

		mov	si,OFFSET MFDBaseOrgTable	;assume MFD

		cmp	DispType,MAP_MFD_DISP	;MFD?
		je	@F			;yes ->

		mov	si,OFFSET TABBaseOrgTable

@@:		mov	bx,Zoom
		shl	bx,1
		mov	bp,[si+bx+0]

		push	[si+bx+2]	;store result scale up

;* rotate offset wrt hdg (note: y = offset, x = 0)

		mov	ax,MAP_VIEW.VP_HDG

		SINCOS	si,di,ax	;si = sin(hdg), di = cos(hdg)

;* yr = y.cos(hdg)

		mov	ax,bp
		imul	di
		shl	ax,1		;adjust after fractional multiply
		rcl	dx,1
		shl	ax,1		;1/2 bit round up
		adc	dx,0

		mov	ax,dx
		cwd
		mov	bx,ax
		mov	cx,dx

;* xr = y.sin(hdg)

		mov	ax,bp
		imul	si
		shl	ax,1		;adjust after fractional multiply
		rcl	dx,1
		shl	ax,1		;1/2 bit round up
		adc	dx,0

		mov	ax,dx
		cwd

;* offset viewpoint

		pop	bp		;restore result scale up

		test	bp,bp		;scale result?
		jz	SkipScaleUp	;no ->

@@:		shl	ax,1		;*2
		rcl	dx,1

		shl	bx,1		;*2
		rcl	cx,1

		dec	bp
		jnz	@B

SkipScaleUp:	mov	si,OFFSET MAP_VIEW
		call	MoveViewpoint

;-------------------
;* sort display size
;-------------------

SortDisp:	mov	bx,DispType

		mov	si,DispDataTable[bx]	;ptr disp data table

		shl	bx,1			;(*4 index)

		cmp SplitScreenBigMapIsOn,1
		jne @F
		
		mov	ax,DispSizeTableHalf[bx+0]	;width
		mov	VP.V_WIDTH,ax

		mov	ax,DispSizeTableHalf[bx+2]	;depth
		mov	VP.V_DEPTH,ax
		jmp frankie_4
@@:
		mov	ax,DispSizeTableFull[bx+0]	;width
		mov	VP_FULL.V_WIDTH,ax

		mov	ax,DispSizeTableFull[bx+2]	;depth
		mov	VP_FULL.V_DEPTH,ax
frankie_4:
;-----------------
;* sort zoom level
;-----------------

		mov	bx,Zoom
		shl	bx,1			;(*4 index)

		mov	al,[si+bx+0]  	;scan size
		xor	ah,ah
		mov	ScanSize,ax
		shr	ax,1
		neg	ax
		mov	ScanOffset,ax

		mov	al,[si+bx+1]	;sector scale
		mov	SctrScale,al

		mov	al,[si+bx+2]	;scale up
		
		cmp SplitScreenBigMapIsOn,1
		jne @F		
		mov	VP.V_SCALE_UP,al

		mov	al,[si+bx+3]	;scale down
		mov	VP.V_SCALE_DN,al
		jmp frankie_7
@@:
		mov	VP_FULL.V_SCALE_UP,al

		mov	al,[si+bx+3]	;scale down
		mov	VP_FULL.V_SCALE_DN,al
frankie_7:
;------------------
;* calc radar range
;------------------

;* radar range = (zft / 1024) + 2

		mov	dx,WORD PTR M_VIEW.VP_ZFT_HI
		mov	ax,WORD PTR M_VIEW.VP_ZFT_LO

		mov	al,ah		;/256
		mov	ah,dl
		REPT	2
		shr	ax,1		;/1024
		ENDM

		add	ax,2

		mov	RadarRange,ax

;* assume current waypoint invalid / non-visible

		mov	CurrentWPX,-1
		mov	CurrentWPY,-1

;* assume floating waypoint invalid / non-visible

		mov	FloatWPX,-1
		mov	FloatWPY,-1

;* assume aircraft non-visible

		mov	ACDatumX,-1
		mov	ACDatumY,-1

;---------------------
;* initialize viewport
;---------------------

		mov	ax,MAP_VIEW.VP_HDG
		neg	ax   		;negate hdg
		and 	ax,001ffh

		cmp SplitScreenBigMapIsOn,1
		jne @F
		mov	si,OFFSET VP
		jmp frankie_5
@@:		
		mov	si,OFFSET VP_FULL
frankie_5:		
		call	VSetViewport

;---------------------
;* sort grid positions
;---------------------

;* XGrid = (xft + 8192) * sector scale / 256 + 1/2 bit

		mov	cl,SctrScale

		mov	ax,MAP_VIEW.VP_XFT
		add	ax,8192
		shl	ax,cl
		mov	al,ah		;/256
		shl	ah,1
		mov	ah,0
		adc	ax,0

		mov	XGrid,ax

;* YGrid = (yft + 8192) * sector scale / 256 + 1/2 bit

		mov	ax,MAP_VIEW.VP_YFT
		add	ax,8192
		shl	ax,cl
		mov	al,ah		;/256
		shl	ah,1
		mov	ah,0
		adc	ax,0

		mov	YGrid,ax

		ret

InitMovingMap	ENDP

;----------------------------------------------------------------------------

;* DrawGround - clear display
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

DrawGround	PROC	NEAR

		cmp SplitScreenBigMapIsOn,1
		jne @F
		
		mov	cx,VP.V_X_ORG
		mov	bl,BYTE PTR VP.V_Y_ORG
		mov	dx,cx
		add	dx,VP.V_WIDTH
		dec	dx
		mov	bh,bl
		add	bh,BYTE PTR VP.V_DEPTH
		jmp frankie_8
@@:
		mov	cx,VP_FULL.V_X_ORG
		mov	bl,BYTE PTR VP_FULL.V_Y_ORG
		mov	dx,cx
		add	dx,VP_FULL.V_WIDTH
		dec	dx
		mov	bh,bl
		add	bh,BYTE PTR VP_FULL.V_DEPTH
frankie_8:		
		
		dec	bh

		mov	al,COL_MAP_GND1
		call	BlockFill

		ret

DrawGround	ENDP

;----------------------------------------------------------------------------

;* SectorReject - sector reject test
;*
;* pass: nothing
;* ret : cf = 0: sector visible
;*       cf = 1: sector non-visible
;* kill: assume all (except cf)

SectorReject	PROC	NEAR

		mov	cl,SctrScale

		mov	dx,64
		sal	dx,cl

		mov	ax,XSecRef
		mov	Xe[0],ax
		mov	Xe[2],ax
		add	ax,dx
		mov	Xe[4],ax
		mov	Xe[6],ax

		mov	ax,YSecRef
		mov	Ye[0],ax
		mov	Ye[6],ax
		add	ax,dx
		mov	Ye[2],ax
		mov	Ye[4],ax

		mov	si,6
		call	VQuickOutCodes

		ret

SectorReject	ENDP

;----------------------------------------------------------------------------

;* DrawRoads
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all
;*
;* note: Refer to ROADS.ASM for road data format.

DrawRoads	PROC	NEAR

		mov	bp,MapIndex
		mov	al,RoadLayer1[bp]
		test	al,al
		jz	@F
		mov	si,16		;x node
		mov	di,48		;y node
		call	DrawRoadNode

		mov	bp,MapIndex
@@:		mov	al,RoadLayer2[bp]
		test	al,al
		jz	@F
		mov	si,48		;x node
		mov	di,48		;y node
		call	DrawRoadNode

		mov	bp,MapIndex
@@:		mov	al,RoadLayer3[bp]
		test	al,al
		jz	@F
		mov	si,16		;x node
		mov	di,16		;y node
		call	DrawRoadNode

		mov	bp,MapIndex
@@:		mov	al,RoadLayer4[bp]
		test	al,al
		jz	@F
		mov	si,48		;x node
		mov	di,16		;y node
		call	DrawRoadNode

@@:		ret

DrawRoads	ENDP

;----------------------------------------------------------------------------

;* DrawRoadNode
;*
;* pass: al = node code
;*       si = x offset (node centre)
;*       di = y offset (node centre)
;* ret : nothing
;* kill: assume all

DrawRoadNode	PROC	NEAR

		mov	cl,SctrScale

		sal	si,cl
		add	si,XSecRef

		sal	di,cl
		add	di,YSecRef

		mov	NodeX,si
		mov	NodeY,di

		xor	bx,bx		;index

DrawNextRoad:	shr	al,1		;road to draw?
		jnc	SkipRoad	;no ->

		push	ax
		push	bx

		mov	cl,SctrScale

		mov	ax,NodeX
		mov	Xe[0],ax
		mov	dx,RoadEndTable[bx+0]	;x
		sal	dx,cl
		add	ax,dx
		mov	Xe[2],ax

		mov	ax,NodeY
		mov	Ye[0],ax
		mov	dx,RoadEndTable[bx+2]	;y
		sal	dx,cl
		add	ax,dx
		mov	Ye[2],ax

		call	VQuickLineClip
		jc	@F		;non-visible ->

		mov	al,COL_MAP_ROAD1
		mov	cx,XCrt[0]
		mov	bl,YCrt[0]
		mov	dx,XCrt[2]
		mov	bh,YCrt[2]
		call	LineDraw

@@:		pop	bx
		pop	ax

SkipRoad: 	add	bx,4		;next road

		test	al,al		;any more roads?
		jnz	DrawNextRoad	;yes ->

		ret

DrawRoadNode	ENDP

;----------------------------------------------------------------------------

;* DrawRailways
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all
;*
;* note: Refer to RAILWAYS.ASM for road data format.

DrawRailways	PROC	NEAR

		mov	bp,MapIndex
		mov	al,RailLayer1[bp]
		test	al,al
		jz	ExitRailways

		mov	si,32		;node x
		mov	di,32		;node y

		mov	cl,SctrScale

		sal	si,cl
		add	si,XSecRef

		sal	di,cl
		add	di,YSecRef

		mov	NodeX,si
		mov	NodeY,di

		xor	bx,bx		;index

DrawNextRail:	shr	al,1		;rail to draw?
		jnc	SkipRail	;no ->

		push	ax
		push	bx

		mov	cl,SctrScale

		mov	ax,NodeX
		mov	Xe[0],ax
		mov	dx,RailEndTable[bx+0]	;x
		sal	dx,cl
		add	ax,dx
		mov	Xe[2],ax

		mov	ax,NodeY
		mov	Ye[0],ax
		mov	dx,RailEndTable[bx+2]	;y
		sal	dx,cl
		add	ax,dx
		mov	Ye[2],ax

		call	VQuickLineClip
		jc	@F		;non-visible ->

		mov	al,COL_MAP_RAIL1
		mov	cx,XCrt[0]
		mov	bl,YCrt[0]
		mov	dx,XCrt[2]
		mov	bh,YCrt[2]
		call	LineDraw

@@:		pop	bx
		pop	ax

SkipRail: 	add	bx,4		;next rail

		test	al,al		;any more rails?
		jnz	DrawNextRail	;yes ->

ExitRailways:	ret

DrawRailways	ENDP

;----------------------------------------------------------------------------

;* DrawRivers
;* 
;* pass: nothing
;* ret : nothing
;* kill: assume all
;*
;* note: Refer to FEATURES.ASM for feature data format.

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

;----------------------------------------------------------------------------

;* DrawFeatures
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all
;*
;* note: Refer to FEATURES.ASM for feature data format.
;*
;*       Draw lakes only on moving map (lakes must be in FeatureLayer1[]).

ExitFeatures1	LABEL	NEAR

		ret

DrawFeatures	PROC	NEAR

		mov	bp,MapIndex
		mov	al,FeatureLayer1[bp]
		test	al,al		;null feature?
		jz	ExitFeatures1	;yes ->

		cmp	al,LAKE_FEATURE	;lake?
		ja	ExitFeatures1	;no ->

;* fetch pointer to feature data

		xor	ah,ah
		mov	bx,ax
		shl	bx,1		;*2 index

		mov	si,FeatureTable[bx]

IntoFeatures:	mov	Col1,COL_MAP_RIVER1	;draw rivers / lakes only

;* skip visual range data

		add	si,2

;------------------
;* scan vertex list (use SEC_SCALE1 or SEC_SCALE16 vertices wrt zoom)
;------------------

		mov	ax,FEATOBJ1
		mov	es,ax

		mov	cl,SctrScale

		mov	ch,0001b	;SEC_SCALE1 test mask

		cmp	Zoom,MAP_ZOOM2	;use lower approximation?
		ja	@F		;no ->

		mov	ch,1000b	;SEC_SCALE16 test mask

@@:		xor	di,di		;reset index

		jmp	VertexLoop1
		
SkipVertex1:	add	si,2

VertexLoop1:	ES_LODSB		;fetch vertex flags
		cmp	al,-1		;end of vertex list?
		je	ContFeatures	;yes ->
		test	al,ch		;vertex required?
		jz	SkipVertex1	;no ->

;* x grid = (v - 64) / 2

		ES_LODSB		;fetch x vertex
		xor	ah,ah
		sub	ax,64
		shr	ax,1
		sal	ax,cl		;scale
		add	ax,XSecRef
		mov	Xe[di],ax

;* y grid = (v - 64) / 2

		ES_LODSB		;fetch y vertex
		xor	ah,ah
		sub	ax,64
		shr	ax,1
		sal	ax,cl		;scale
		add	ax,YSecRef
		mov	Ye[di],ax

		add	di,2		;next index

		jmp	VertexLoop1

ContFeatures:	sub	di,2		;di indexes last vertex

		mov	ax,DATA
		mov	es,ax

;----------------------------
;* test if feature is visible
;----------------------------

		push	si
		mov	si,di
		call	VCalcOutCodes
		pop	si
		jc	ExitFeatures2	;non-visible ->

;------------------------------------------------------
;* copy face data from FEATOBJ1 segment to DATA segment
;------------------------------------------------------

		xor	bx,bx		;assume SEC_SCALE1

		cmp	Zoom,MAP_ZOOM2	;use lower approximation?
		ja	@F		;no ->

		mov	bx,6		;SEC_SCALE16

@@:		mov	ax,FEATOBJ1
		mov	ds,ax

		mov	si,[si+bx]	;point to face data

		lodsw			;fetch counter
		mov	cx,ax

		mov	di,OFFSET CopyBuffer

		FAST_MOVE

		mov	ax,DATA
		mov	ds,ax

;----------------
;* generate faces
;----------------

		mov	si,OFFSET CopyBuffer

NextFace:	lodsb			;fetch attribute
		cmp	al,-1		;end of face list?
		je	ExitFeatures2	;yes ->

;* line or polygon structure?

		test	al,FACE_STRUCTURE 
		jnz	SortLine
		
;* sort polygon structure

		lodsb			;fetch and ignore logical colour

		mov	di,OFFSET CrtBuffer
		call	VPolyClip
		jc	NextFace	;polygon non-visible ->

		push	si
		mov	al,Col1
		mov	si,OFFSET CrtBuffer
		call	PolyFill
		pop	si
		jmp	NextFace

;* sort line structure

SortLine:   	lodsb			;fetch and ignore logical colour

		mov	di,OFFSET CrtBuffer
		call	VPolyLineClip
		jc	NextFace	;lines non-visible ->

		push	si
		mov	al,Col1
		mov	si,OFFSET CrtBuffer
		call	PolyLine
		pop	si
		jmp	NextFace

ExitFeatures2:	ret

DrawFeatures	ENDP

;----------------------------------------------------------------------------

;* DrawHills
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all
;*
;* note: Refer to HILLS.ASM for feature data format.

ExitHills	LABEL	NEAR

		ret

DrawHills	PROC	NEAR

;--------------------------
;* test for hills in sector
;--------------------------

		mov	bp,MapIndex
		mov	al,HillLayer9[bp]
		test	al,al		;null hills?
		jns	ExitHills	;yes ->

;--------------------------
;* calc spot height co-ords (ZA .. ZI)
;--------------------------

		mov	cl,SctrScale

		mov	dx,32
		sal	dx,cl

		mov	ax,XSecRef
		mov	Xe[$ZA],ax
		mov	Xe[$ZD],ax
		mov	Xe[$ZG],ax

		add	ax,dx
		mov	Xe[$ZB],ax
		mov	Xe[$ZE],ax
		mov	Xe[$ZH],ax

		add	ax,dx
		mov	Xe[$ZC],ax
		mov	Xe[$ZF],ax
		mov	Xe[$ZI],ax

		mov	ax,YSecRef
		mov	Ye[$ZG],ax
		mov	Ye[$ZH],ax
		mov	Ye[$ZI],ax

		add	ax,dx
		mov	Ye[$ZD],ax
		mov	Ye[$ZE],ax
		mov	Ye[$ZF],ax

		add	ax,dx
		mov	Ye[$ZA],ax
		mov	Ye[$ZB],ax
		mov	Ye[$ZC],ax

;--------------------------
;* generate virtual co-ords
;--------------------------

		mov	si,$ZI
		call	VCalcOutCodes
		jc	ExitHills	;non-visible ->

;------------
;* draw faces
;------------

;* draw face 0

		mov	bp,MapIndex

		mov	al,HillLayer5[bp]
		and	al,00fh		;extract colour data
		jz	SkipFace0	;no face ->

		mov	si,OFFSET HillFaceList0

		test	HillLayer1[bp],080h	;z crease?
		jz	@F			;yes ->

		add	si,4

@@:		push	ax
		mov	di,OFFSET CrtBuffer
		call	VPolyClip
		pop	ax
		jc	SkipFace0	;non-visible ->

		add	al,COL_MAP_HILL1
		mov	si,OFFSET CrtBuffer
		call	PolyFill

;* draw face 1

SkipFace0:	mov	bp,MapIndex

		mov	al,HillLayer5[bp]
		REPT	4   		;extract colour data
		shr	al,1
		ENDM
		jz	SkipFace1	;no face ->

		mov	si,OFFSET HillFaceList1

		test	HillLayer1[bp],080h	;z crease?
		jz	@F			;yes ->

		add	si,4

@@:		push	ax
		mov	di,OFFSET CrtBuffer
		call	VPolyClip
		pop	ax
		jc	SkipFace1	;non-visible ->

		add	al,COL_MAP_HILL1
		mov	si,OFFSET CrtBuffer
		call	PolyFill

;* draw face 2

SkipFace1:	mov	bp,MapIndex

		mov	al,HillLayer6[bp]
		and	al,00fh		;extract colour data
		jz	SkipFace2	;no face ->

		mov	si,OFFSET HillFaceList2

		test	HillLayer2[bp],080h	;z crease?
		jz	@F			;yes ->

		add	si,4

@@:		push	ax
		mov	di,OFFSET CrtBuffer
		call	VPolyClip
		pop	ax
		jc	SkipFace2	;non-visible ->

		add	al,COL_MAP_HILL1
		mov	si,OFFSET CrtBuffer
		call	PolyFill

;* draw face 3

SkipFace2:	mov	bp,MapIndex

		mov	al,HillLayer6[bp]
		REPT	4   		;extract colour data
		shr	al,1
		ENDM
		jz	SkipFace3	;no face ->

		mov	si,OFFSET HillFaceList3

		test	HillLayer2[bp],080h	;z crease?
		jz	@F			;yes ->

		add	si,4

@@:		push	ax
		mov	di,OFFSET CrtBuffer
		call	VPolyClip
		pop	ax
		jc	SkipFace3	;non-visible ->

		add	al,COL_MAP_HILL1
		mov	si,OFFSET CrtBuffer
		call	PolyFill

;* draw face 4

SkipFace3:	mov	bp,MapIndex

		mov	al,HillLayer7[bp]
		and	al,00fh		;extract colour data
		jz	SkipFace4	;no face ->

		mov	si,OFFSET HillFaceList4

		test	HillLayer3[bp],080h	;z crease?
		jz	@F			;yes ->

		add	si,4

@@:		push	ax
		mov	di,OFFSET CrtBuffer
		call	VPolyClip
		pop	ax
		jc	SkipFace4	;non-visible ->

		add	al,COL_MAP_HILL1
		mov	si,OFFSET CrtBuffer
		call	PolyFill

;* draw face 5

SkipFace4:	mov	bp,MapIndex

		mov	al,HillLayer7[bp]
		REPT	4   		;extract colour data
		shr	al,1
		ENDM
		jz	SkipFace5	;no face ->

		mov	si,OFFSET HillFaceList5

		test	HillLayer3[bp],080h	;z crease?
		jz	@F			;yes ->

		add	si,4

@@:		push	ax
		mov	di,OFFSET CrtBuffer
		call	VPolyClip
		pop	ax
		jc	SkipFace5	;non-visible ->

		add	al,COL_MAP_HILL1
		mov	si,OFFSET CrtBuffer
		call	PolyFill

;* draw face 6

SkipFace5:	mov	bp,MapIndex

		mov	al,HillLayer8[bp]
		and	al,00fh		;extract colour data
		jz	SkipFace6	;no face ->

		mov	si,OFFSET HillFaceList6

		test	HillLayer4[bp],080h	;z crease?
		jz	@F			;yes ->

		add	si,4

@@:		push	ax
		mov	di,OFFSET CrtBuffer
		call	VPolyClip
		pop	ax
		jc	SkipFace6	;non-visible ->

		add	al,COL_MAP_HILL1
		mov	si,OFFSET CrtBuffer
		call	PolyFill

;* draw face 6

SkipFace6:	mov	bp,MapIndex

		mov	al,HillLayer8[bp]
		REPT	4   		;extract colour data
		shr	al,1
		ENDM
		jz	SkipFace7	;no face ->

		mov	si,OFFSET HillFaceList7

		test	HillLayer4[bp],080h	;z crease?
		jz	@F			;yes ->

		add	si,4

@@:		push	ax
		mov	di,OFFSET CrtBuffer
		call	VPolyClip
		pop	ax
		jc	SkipFace7	;non-visible ->

		add	al,COL_MAP_HILL1
		mov	si,OFFSET CrtBuffer
		call	PolyFill

SkipFace7:	ret

DrawHills	ENDP

;----------------------------------------------------------------------------

;* DrawGndObjects
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

DrawGndObjects	PROC	NEAR

;* only display objects at high zoom levels

		cmp	Zoom,MAP_ZOOM4	;high zoom level?
		jb	ExitGndObjects	;no ->

;* test for occupied sector

		mov	bp,MapIndex
		mov	al,SectorLayer1[bp]
		test	al,al		;occupied sector?
		jz	ExitGndObjects	;no ->

;* sort allied / enemy object colour

		mov	ah,COL_MAP_ALLIED

		test	SctrGameLayer1[bp],SECT_ENEMY
		jz	@F

		mov	ah,COL_MAP_ENEMY

@@:		mov	GndObjectCol,ah

;* calc pointer to sector data record

		CALC_SEC_PTR

;* scan object list

		mov	si,SEC_OBJ_PTR[bx]

ScanGndObjects:	mov	ax,SECDATA1
		mov	es,ax

		ES_LODSB		;fetch object number
		mov	cl,al

		inc	si		;skip object flag

		ES_LODSB		;fetch x grid position
		mov	dl,al

		ES_LODSB		;fetch y grid position
		mov	bl,al

		mov	ax,DATA
		mov	es,ax

		cmp	cl,-1		;end of list?
		je	ExitGndObjects	;yes ->

;* do not draw trees (assume GND_COPSEA .. GND_COPSED are contiguous)

		cmp	cl,GND_COPSEA	;tree?
		jb	@F		;no ->
		cmp	cl,GND_COPSED	;tree?
		jbe	ScanGndObjects	;yes ->

@@:		mov	cl,SctrScale

		xor	dh,dh
		sal	dx,cl
		add	dx,XSecRef
		mov	Xe[0],dx

		xor	bh,bh
		sal	bx,cl
		add	bx,YSecRef
		mov	Ye[0],bx

		push	si

		call	VDotClip
		jc	@F		;non-visible ->

		mov	al,GndObjectCol
		call	SetPixel

@@:		pop	si

		jmp	ScanGndObjects

ExitGndObjects:	ret

DrawGndObjects	ENDP

;----------------------------------------------------------------------------

;* SortCurrentWP - calc co-ords for current waypoint
;*
;* pass: XSec
;*       YSec
;* ret : CurrentWPX ) if current waypoint is in sector 
;*       CurrentWPY )
;* kill: assume all

SortCurrentWP	PROC	NEAR

		cmp	WayTotal,0	;any waypoints?
		je	ExitCurrentWP	;no ->

;* is current waypoint in sector?

		mov	si,WPPtr

		mov	ax,[si].WP_XSEC
		cmp	ax,XSec		;x sector match?
		jne	ExitCurrentWP  	;no ->

		mov	ax,[si].WP_YSEC
		cmp	ax,YSec		;y sector match?
		jne	ExitCurrentWP	;no ->

;* calc current waypoint position relative to display origin

		mov	ax,[si].WP_XFT
		mov	bx,[si].WP_YFT

		add	ax,8192
		mov	cl,8
		sub	cl,SctrScale
		shr	ax,cl
		add	ax,XSecRef
		mov	Xe[0],ax

		add	bx,8192
		mov	cl,8
		sub	cl,SctrScale
		shr	bx,cl
		add	bx,YSecRef
		mov	Ye[0],bx

		call	VDotClip
		jc	ExitCurrentWP	;non-visible ->

;* calc x, y position relative to display origin
		
		cmp SplitScreenBigMapIsOn,1
		jne @F
		
		sub	cx,VP.V_X_ORG
		mov	CurrentWPX,cx

		sub	bx,VP.V_Y_ORG
		mov	CurrentWPY,bx
		jmp frankie_9
@@:
		sub	cx,VP_FULL.V_X_ORG
		mov	CurrentWPX,cx

		sub	bx,VP_FULL.V_Y_ORG
		mov	CurrentWPY,bx
frankie_9:

ExitCurrentWP:	ret

SortCurrentWP	ENDP

;----------------------------------------------------------------------------

;* SortFloatWP - calc co-ords for floating waypoint
;*
;* pass: XSec
;*       YSec
;* ret : FloatWPX ) if floating waypoint is valid and in sector
;*       FloatWPY ) 
;* kill: assume all

SortFloatWP	PROC	NEAR

;* is floating waypoint valid?

		test	FloatWP.WP_ATTR,WP_VALID	;valid?
		jz	ExitFloatWP			;no ->

;* is floating waypoint in sector?

		mov	ax,FloatWP.WP_XSEC
		cmp	ax,XSec		;x sector match?
		jne	ExitFloatWP	;no ->

		mov	ax,FloatWP.WP_YSEC
		cmp	ax,YSec		;y sector match?
		jne	ExitFloatWP	;no ->

;* calc floating waypoint position relative to display origin

		mov	ax,FloatWP.WP_XFT
		mov	bx,FloatWP.WP_YFT

		add	ax,8192
		mov	cl,8
		sub	cl,SctrScale
		shr	ax,cl
		add	ax,XSecRef
		mov	Xe[0],ax

		add	bx,8192
		mov	cl,8
		sub	cl,SctrScale
		shr	bx,cl
		add	bx,YSecRef
		mov	Ye[0],bx

		call	VDotClip
		jc	ExitFloatWP	;non-visible ->

;* calc x, y position relative to display origin
		
		cmp SplitScreenBigMapIsOn,1
		jne @F
	
		sub	cx,VP.V_X_ORG
		mov	FloatWPX,cx

		sub	bx,VP.V_Y_ORG
		mov	FloatWPY,bx
		jmp frankie_10
@@:		
		sub	cx,VP_FULL.V_X_ORG
		mov	FloatWPX,cx

		sub	bx,VP_FULL.V_Y_ORG
		mov	FloatWPY,bx
frankie_10:
		
ExitFloatWP:	ret

SortFloatWP	ENDP

;----------------------------------------------------------------------------

;* SortACDatum - calc co-ords for aircraft position
;*
;* pass: XSec
;*       YSec
;* ret : ACDatumX ) if aircraft is in sector
;*       ACDatumY ) 
;* kill: assume all

SortACDatum	PROC	NEAR

;* is aircraft in sector?

		mov	ax,M_VIEW.VP_XSEC
		cmp	ax,XSec		;x sector match?
		jne	ExitACDatum	;no ->

		mov	ax,M_VIEW.VP_YSEC
		cmp	ax,YSec		;y sector match?
		jne	ExitACDatum	;no ->

;* calc aircraft position relative to display origin

		mov	ax,M_VIEW.VP_XFT
		mov	bx,M_VIEW.VP_YFT

		add	ax,8192
		mov	cl,8
		sub	cl,SctrScale
		shr	ax,cl
		add	ax,XSecRef
		mov	Xe[0],ax

		add	bx,8192
		mov	cl,8
		sub	cl,SctrScale
		shr	bx,cl
		add	bx,YSecRef
		mov	Ye[0],bx

		call	VDotClip
		jc	ExitACDatum	;non-visible ->

;* calc x, y position relative to display origin

		cmp SplitScreenBigMapIsOn,1
		jne @F
		
		sub	cx,VP.V_X_ORG
		mov	ACDatumX,cx

		sub	bx,VP.V_Y_ORG
		mov	ACDatumY,bx
		jmp frankie_11
@@:
		sub	cx,VP_FULL.V_X_ORG
		mov	ACDatumX,cx

		sub	bx,VP_FULL.V_Y_ORG
		mov	ACDatumY,bx
frankie_11:		

ExitACDatum:	ret

SortACDatum	ENDP

;----------------------------------------------------------------------------

;* DrawStatMobiles
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all
;*
;* note: Only call if ground radar mode.

DrawStatMobiles	PROC	NEAR

;* test for occupied sector

		mov	bp,MapIndex
		mov	bl,MobileLayer1[bp]

		test	bl,bl		;occupied sector?
		jz	ExitStatMobs	;no ->

;* calc pointer to sector data record

		xor	bh,bh
		shl	bx,1		;*2 word index

		mov	si,MobSectorTable[bx]

;* scan object list

ScanStatMobs:	mov	ax,MSECDATA1
		mov	es,ax

		mov	dl,ES:STAT_NUM[si]
		mov	dh,ES:STAT_ANIM[si]
		mov	cx,ES:STAT_XFT[si]
		mov	bx,ES:STAT_YFT[si]

		mov	ax,DATA
		mov	es,ax

		cmp	dl,-1		;end of list?
		je	ExitStatMobs	;yes ->

		test	dh,OBJECT_DEAD	;dead?
		jnz	SkipStatic2	;yes ->

;* radar shadow test

		push	si

		push	bx
		push	cx
		call	ShadowCheck
		pop	ax
		pop	bx

		jc	SkipStatic1	;in radar shadow (non-visible) ->
		
;* plot static mobile on radar

		add	ax,8192
		mov	cl,8
		sub	cl,SctrScale
		shr	ax,cl
		add	ax,XSecRef
		mov	Xe[0],ax

		add	bx,8192
		mov	cl,8
		sub	cl,SctrScale
		shr	bx,cl
		add	bx,YSecRef
		mov	Ye[0],bx

		call	VDotClip
		jc	SkipStatic1	;non-visible ->

		mov	al,COL_CRT16
		call	SetPixel

SkipStatic1:	pop	si

SkipStatic2:	add	si,STAT_REC_SIZE

		jmp	ScanStatMobs

ExitStatMobs:	ret

DrawStatMobiles	ENDP

;----------------------------------------------------------------------------

;* DrawMobiles
;*
;* pass: XSec
;*       YSec
;* ret : nothing
;* kill: assume all
;*
;* note: Only call if ground radar mode.

DrawMobiles	PROC	NEAR

;* test for occupied sector

		mov	ax,XSec
		mov	dx,YSec

		call	LocateMobiles	;mobiles in sector?
		jc	ExitMobiles	;no ->

;* scan mobiles

ScanMobiles:  	cmp	si,-1		;end of list?
		je	ExitMobiles	;yes ->

		push	si

		cmp	si,OFFSET M_MOBILE	;Tornado?
		je	SkipMobile		;yes ->

;* only allow mobiles whose zft <= 50ft (still see vehicles on bridges)

		cmp	WORD PTR _VP_ZFT_HI[si],0	;alt > 65535ft?
		ja	SkipMobile			;yes ->

		cmp	WORD PTR _VP_ZFT_LO[si],50	;alt <= 50ft?
		ja	SkipMobile			;no ->

		mov	cx,_VP_XFT[si]
		mov	bx,_VP_YFT[si]

		push	bx
		push	cx
		call	ShadowCheck
		pop	ax
		pop	bx

		jc	SkipMobile	;in radar shadow (non-visible) ->

		add	ax,8192
		mov	cl,8
		sub	cl,SctrScale
		shr	ax,cl
		add	ax,XSecRef
		mov	Xe[0],ax

		add	bx,8192
		mov	cl,8
		sub	cl,SctrScale
		shr	bx,cl
		add	bx,YSecRef
		mov	Ye[0],bx

		call	VDotClip
		jc	SkipMobile	;non-visible ->

		mov	al,COL_CRT16
		call	SetPixel

SkipMobile:	pop	si

		mov	si,MOB_LINK_PTR[si]

		jmp	ScanMobiles

ExitMobiles:	ret

DrawMobiles	ENDP

;----------------------------------------------------------------------------

;* ShadowCheck - check if object is in radar shadow
;*
;* pass: M_VIEW 
;*	 XSec
;*	 YSec
;*       cx = xft
;*       bx = yft
;* ret : cf = 0 = visible
;*	 cf = 1 = non-visible (in radar shadow)
;* kill: assume all (except cf)

ShadowCheck	PROC	NEAR

;--------------------------------------
;* always visible if altitude > 65535ft
;--------------------------------------

		cmp	WORD PTR M_VIEW.VP_ZFT_HI,0	;alt > 65535ft?
		je	@F				;no ->

		clc			;cf = 0 = visible

		ret

;-----------------------------------
;* has quadrant been tested already?
;-----------------------------------

;* calc quad x centre

@@:		mov	ax,cx
		cwd
		mov	si,4096
		xor	si,dx
		sub	si,dx

		rol	dx,1		;cf = sign(xft)
		rcl	cl,1

;* calc quad y centre

		mov	ax,bx
		cwd
		mov	di,4096
		xor	di,dx
		sub	di,dx

		rol	dx,1		;cf = sign(yft)
		rcl	cl,1

		and	cl,0011b

		mov	al,0001b
		shl	al,cl

		test	QuadTested,al	;quadrant already tested?
		jz	@F		;no ->

		mov	al,QuadResult
		inc	cl
		shr	al,cl		;cf = result wrt quad

		ret

@@:		or	QuadTested,al	

		mov	QuadMask,al

;-------------------------
;* copy M_VIEW to TMP_VIEW
;-------------------------

		mov	ax,si
		mov	dx,di

		COPY_VP	TMP_VIEW,M_VIEW

		mov	si,ax
		mov	di,dx

;----------------
;* calc Dx and Dy
;----------------

;* x1 = xsec * 16384 + xft + 8192

		mov	cx,M_VIEW.VP_XSEC	;xsec * 65536
		xor	bx,bx
		REPT	2			;/4
		sar	cx,1
		rcr	bx,1
		ENDM
		mov	bp,M_VIEW.VP_XFT
		add	bp,8192
		add	bx,bp
		adc	cx,0

;* x2 = xsec * 16384 + xft + 8192

		mov	dx,XSec		;xsec * 65536
		xor	ax,ax
		REPT	2		;/4
		sar	dx,1
		rcr	ax,1
		ENDM
		mov	bp,si
		add	bp,8192
		add	ax,bp
		adc	dx,0

;* Dx = x2 - x1

		sub	ax,bx
		sbb	dx,cx

		push	ax		;store Dx
		push	dx

;* y1 = -(ysec * 16384) + yft - 8192

		mov	dx,M_VIEW.VP_YSEC	;ysec * 65536
		xor	ax,ax
		REPT	2			;/4
		sar	dx,1
		rcr	ax,1
		ENDM
		NEG32	dx,ax
		mov	bp,M_VIEW.VP_YFT
		sub	bp,8192
		add	ax,bp
		adc	dx,0

;* y2 = -(ysec * 16384) + yft - 8192

		mov	cx,YSec		;ysec * 65536
		xor	bx,bx
		REPT	2		;/4
		sar	cx,1
		rcr	bx,1
		ENDM
		NEG32	cx,bx
		mov	bp,di
		sub	bp,8192
		add	bx,bp
		adc	cx,0

;* Dy = y2 - y1

		sub	bx,ax
		sbb	cx,dx

		pop	dx		;restore Dx
		pop	ax

;-----------------------------------
;* calc sample dist (Dx / 8, Dy / 8)
;-----------------------------------

		REPT	3
		sar	dx,1
		rcr	ax,1
		sar	cx,1
		rcr	bx,1
		ENDM

;-------------------
;* calc Dz = zft / 8
;-------------------

		mov	di,WORD PTR M_VIEW.VP_ZFT_LO

		REPT	3
		shr	di,1
		ENDM

;------------------
;* shadow test loop
;------------------

		mov	bp,7		;loop count

ShadowLoop:	push	ax
		push	bx
		push	cx
		push	dx
		push	di
		push	bp

		push	di

		mov	si,OFFSET TMP_VIEW
		call	MoveViewpoint

		pop	di

		mov	ax,WORD PTR TMP_VIEW.VP_ZFT_LO
		sub	ax,di
		MINM	ax
		mov	WORD PTR TMP_VIEW.VP_ZFT_LO,ax

		cmp	ax,256*15	;alt > max gnd ht?
		ja	@F	 	;yes ->

		call	CalcGndHeight

		cmp	WORD PTR TMP_VIEW.VP_ZFT_LO,ax	;alt > gnd ht?

@@:		pop	bp
		pop	di
		pop	dx
		pop	cx
		pop	bx
		pop	ax

		jbe	RadarNonVis    	;alt <= gnd ht ->

		dec	bp	    	;next test

		jnz	ShadowLoop

;* set result to visible

RadarVis:	mov	al,QuadMask
		not	al
		and	QuadResult,al

		clc			;cf = 0 = visible

		ret

RadarNonVis:	stc			;cf = 1 = non-visible

		ret

ShadowCheck	ENDP

;----------------------------------------------------------------------------

;* DrawSpecials
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

DrawSpecials	PROC	NEAR

		mov	bp,MapIndex
		mov	al,SpecialLayer1[bp]
		test	al,al		;null?
		jz	ExitSpecials	;yes ->

;----------------
;* draw airfields
;----------------

		cmp	al,AIRFIELD_N	;airfield?
		ja	@F		;no ->

		call	DrawAirfield

		jmp	ExitSpecials

;------------
;* draw towns
;------------

@@:		cmp	al,TOWN_N	;town?
		ja	ExitSpecials	;no ->

		call	DrawTown

ExitSpecials:	ret

DrawSpecials	ENDP

;----------------------------------------------------------------------------

;* DrawAirfield - draw runways / taxiways
;*
;* pass: al = specials number (AIRFIELD_1 .. AIRFIELD_N)
;* ret : nothing
;* kill: assume all

DrawAirfield	PROC	NEAR

		mov	bl,al

		sub	bl,AIRFIELD_1
		xor	bh,bh
		shl	bx,1	;*2
		shl	bx,1	;*4

		mov	si,AirfieldTable[bx+2]
		push	bx
		call	DrawTaxiways
		pop	bx

		mov	si,AirfieldTable[bx]
		call	DrawRunways

		ret

DrawAirfield	ENDP

;----------------------------------------------------------------------------

;* DrawRunways
;*
;* pass: si -> RUNWAY record list (-1 terminated)
;* ret : nothing
;* kill: assume all
;*
;* note: Assume last runway in list is the active runway.

DrawRunways	PROC	NEAR

NextRunway:	mov	ax,RWY_DIR[si]
		cmp	ax,-1		;end of list?
		je	ExitRunways	;yes ->

		mov	cl,SctrScale

		mov	ax,RWY_X1[si]
		sal	ax,cl
		add	ax,XSecRef
		mov	Xe[0],ax

		mov	ax,RWY_Y1[si]
		sal	ax,cl
		add	ax,YSecRef
		mov	Ye[0],ax

		mov	ax,RWY_X2[si]
		sal	ax,cl
		add	ax,XSecRef
		mov	Xe[2],ax

		mov	ax,RWY_Y2[si]
		sal	ax,cl
		add	ax,YSecRef
		mov	Ye[2],ax

		push	si
		call	VQuickLineClip
		pop	si
		jc	SkipRunway	;non-visible ->

;* sort active / inactive runway colours

		mov	al,COL_MAP_RWY2			;assume active runway

		cmp	RWY_REC_SIZE+RWY_DIR[si],-1	;last runway in list?
		je	@F				;yes ->

		mov	al,COL_MAP_RWY1			;inactive runway

@@:		mov	cx,XCrt[0]
		mov	bl,YCrt[0]
		mov	dx,XCrt[2]
		mov	bh,YCrt[2]
		push	si		
		call	LineDraw
		pop	si

SkipRunway: 	add	si,RWY_REC_SIZE

		jmp	NextRunway

ExitRunways:	ret

DrawRunways	ENDP

;----------------------------------------------------------------------------

;* DrawTown - draw town layout
;*
;* pass: al = specials number (TOWN_1 .. TOWN_N)
;* ret : nothing
;* kill: assume all

DrawTown	PROC	NEAR

		mov	bl,al

		sub	bl,TOWN_1
		xor	bh,bh
		shl	bx,1		;*2

		mov	si,TownTable[bx]

		call	DrawTownRoads

		ret

DrawTown	ENDP

;----------------------------------------------------------------------------

;* DrawNetwork - draw town / taxiway networks
;*
;* pass: si -> town / taxiway data
;* ret : nothing
;* kill: assume all

SkipNetwork	LABEL	NEAR

		ret

DrawTaxiways	LABEL	NEAR

		mov	Col1,COL_MAP_RWY1

		jmp	DrawNetwork

DrawTownRoads	LABEL	NEAR

		mov	Col1,COL_MAP_ROAD1

DrawNetwork	PROC	NEAR

		cmp	Zoom,MAP_ZOOM2	;zoomed out too far?
		jbe	SkipNetwork	;no ->

;------------------
;* scan vertex list
;------------------

		mov	cl,SctrScale

		mov	ax,FEATOBJ1
		mov	es,ax

		mov	cl,SctrScale

		xor	di,di		;reset index

VertexLoop2:	ES_LODSB		;fetch end type
		cmp	al,-1		;end of vertex list?
		je	ContNetwork	;yes ->

;* x grid = (v - 64) / 2

		ES_LODSB		;fetch x vertex
		xor	ah,ah
		sub	ax,64
		shr	ax,1
		sal	ax,cl		;scale
		add	ax,XSecRef
		mov	Xe[di],ax

;* y grid = (v - 64) / 2

		ES_LODSB		;fetch y vertex
		xor	ah,ah
		sub	ax,64
		shr	ax,1
		sal	ax,cl		;scale
		add	ax,YSecRef
		mov	Ye[di],ax

		add	di,2		;next index

		jmp	VertexLoop2

ContNetwork:	sub	di,2		;di indexes last vertex

		mov	ax,DATA
		mov	es,ax

;----------------------------
;* test if network is visible
;----------------------------

		push	si
		mov	si,di
		call	VCalcOutCodes
		pop	si
		jc	ExitNetwork	;non-visible ->

;------------------------------------------------------
;* copy face data from FEATOBJ1 segment to DATA segment
;------------------------------------------------------

		mov	ax,FEATOBJ1
		mov	ds,ax

		mov	si,[si]		;point to even face data

		lodsw			;fetch counter
		mov	cx,ax

		mov	di,OFFSET CopyBuffer

		FAST_MOVE

		mov	ax,DATA
		mov	ds,ax

;----------------
;* generate faces
;----------------

		mov	si,OFFSET CopyBuffer

NextLineFace:	lodsb		    	;fetch logical colour (colour ignored)
		cmp	al,-1		;end of face list?
		je	ExitNetwork	;yes ->

		mov	di,OFFSET CrtBuffer
		call	VPolyLineClip
		jc	NextLineFace	;lines non-visible ->

		push	si
		mov	al,Col1
		mov	si,OFFSET CrtBuffer
		call	PolyLine
		pop	si

		jmp	NextLineFace

ExitNetwork:	ret

DrawNetwork	ENDP

;----------------------------------------------------------------------------

;* DrawMapBorder
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all
;*
;* note: Call this routine IMMEDIATELY after calling UpdateMovingMap if you
;*       require a border around the active map area. This routine relies
;*       on moving map and vscreen variables being valid.
;*
;*       This routine will only work if the map is not rotated.

ExitMapBorder	LABEL	NEAR

		retf			;<<<<< MUST BE FAR <<<<<

DrawMapBorder	PROC	FAR

;--------------------------
;* check if too far off map
;--------------------------

		cmp	MAP_VIEW.VP_XSEC,-16
		jl	ExitMapBorder
		cmp	MAP_VIEW.VP_XSEC,47
		jg	ExitMapBorder

		cmp	MAP_VIEW.VP_YSEC,-16
		jl	ExitMapBorder
		cmp	MAP_VIEW.VP_YSEC,47
		jg	ExitMapBorder

;---------------------
;* initialize viewport
;---------------------

		cmp SplitScreenBigMapIsOn,1
		jne @F
		
		mov	VP.V_SCALE_UP,0
		jmp frankie_12
@@:
        mov	VP_FULL.V_SCALE_UP,0
frankie_12:		
		
;* calc scale down wrt zoom:-
;*
;* MAP_ZOOM1 =   8 pixels / sector =   4096 / 8 * 16 = 32 (>> 5)
;* MAP_ZOOM2 =  16 pixels / sector =  4096 / 16 * 16 = 16 (>> 4)
;* MAP_ZOOM3 =  32 pixels / sector =  4096 / 32 * 16 =  8 (>> 3)
;* MAP_ZOOM4 =  64 pixels / sector =  4096 / 64 * 16 =  4 (>> 2)
;* MAP_ZOOM5 = 128 pixels / sector = 4096 / 128 * 16 =  2 (>> 1)
;* MAP_ZOOM6 = 256 pixels / sector = 4096 / 256 * 16 =  1 (>> 0)
;*
;* scale down = 5 - zoom / 2
 
		mov	ax,5
		mov	dx,Zoom
		shr	dx,1
		sub	ax,dx
		cmp SplitScreenBigMapIsOn,1
		jne @F		
		mov	VP.V_SCALE_DN,al
		jmp frankie_13
@@:		
		mov	VP_FULL.V_SCALE_DN,al
frankie_13:		
		xor	ax,ax		;zero hdg

		cmp SplitScreenBigMapIsOn,1
		jne @F		
		mov	si,OFFSET VP
		jmp frankie_14
@@:		
		mov	si,OFFSET VP_FULL
frankie_14:		
		
		call	VSetViewport

;----------------------
;* calc linear position
;----------------------

		mov	cl,6		;/64

;* lin x = (xsec * 256) + (xft + 8192) / 64 + 1/2 bit (-4096 .. 12288)

		mov	dx,MAP_VIEW.VP_XSEC
		mov	dh,dl
		xor	dl,dl

		mov	ax,MAP_VIEW.VP_XFT
		add	ax,8192
		shr	ax,cl
		ROUNDUP	ax

		add	ax,dx

		mov	si,ax

;* lin y = ((31 - ysec) * 256) + (yft + 8192) / 64 + 1/2 bit (-4096 .. 12288)

		mov	dx,31
		sub	dx,MAP_VIEW.VP_YSEC
		mov	dh,dl
		xor	dl,dl

		mov	ax,MAP_VIEW.VP_YFT
		add	ax,8192
		shr	ax,cl
		ROUNDUP	ax

		add	ax,dx

		mov	di,ax

;-------------
;* draw border
;-------------

;* (Xb, Yb) ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿ (Xc, Yc)
;*          ?             ?
;*          ?             ?
;*          ?             ?
;*          ?             ?
;*          ?             ?
;* (Xa, Ya) ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ (Xd, Yd)
;*
;* Xa' = Xa - lin x =    0 - lin x = -(lin x)
;* Ya' = Ya - lin y =    0 - lin y = -(lin y)
;* Xb' = Xb - lin x =    0 - lin x = -(lin x)
;* Yb' = Yb - lin y = 8192 - lin y
;* Xc' = Xc - lin x = 8192 - lin x
;* Yc' = Yc - lin y = 8192 - lin y
;* Xd' = Xd - lin x = 8192 - lin x
;* Yd' = Yd - lin y =    0 - lin y = -(lin y)

;* draw (Xa, Ya) -> (Xb, Yb)

		mov	ax,si
		neg	ax
		mov	Xe[0],ax
		mov	Xe[2],ax

		mov	ax,di
		neg	ax
		mov	Ye[0],ax

		mov	ax,8192
		sub	ax,di
		mov	Ye[2],ax

		push	si
		push	di

		call	VQuickLineClip
		jc	@F		;non-visible ->

		mov	cx,XCrt[0]
		mov	bl,YCrt[0]
		mov	dx,XCrt[2]
		mov	bh,YCrt[2]
		call	VDotLineDraw

@@:		pop	di
		pop	si

;* draw (Xb, Yb) -> (Xc, Yc)

		mov	ax,8192
		sub	ax,di
		mov	Ye[0],ax
		mov	Ye[2],ax

		mov	ax,si
		neg	ax
		mov	Xe[0],ax

		mov	ax,8192
		sub	ax,si
		mov	Xe[2],ax

		push	si
		push	di

		call	VQuickLineClip
		jc	@F		;non-visible ->

		mov	cx,XCrt[0]
		mov	bl,YCrt[0]
		mov	dx,XCrt[2]
		mov	bh,YCrt[2]
		call	HDotLineDraw

@@:		pop	di
		pop	si

;* draw (Xc, Yc) -> (Xd, Yd)

		mov	ax,8192
		sub	ax,si
		mov	Xe[0],ax
		mov	Xe[2],ax

		mov	ax,8192
		sub	ax,di
		mov	Ye[0],ax

		mov	ax,di
		neg	ax
		mov	Ye[2],ax

		push	si
		push	di

		call	VQuickLineClip
		jc	@F		;non-visible ->

		mov	cx,XCrt[0]
		mov	bl,YCrt[0]
		mov	dx,XCrt[2]
		mov	bh,YCrt[2]
		call	VDotLineDraw

@@:		pop	di
		pop	si

;* draw (Xd, Yd) -> (Xa, Ya)

		mov	ax,di
		neg	ax
		mov	Ye[0],ax
		mov	Ye[2],ax

		mov	ax,8192
		sub	ax,si
		mov	Xe[0],ax

		mov	ax,si
		neg	ax
		mov	Xe[2],ax

		call	VQuickLineClip
		jc	@F		;non-visible ->

		mov	cx,XCrt[0]
		mov	bl,YCrt[0]
		mov	dx,XCrt[2]
		mov	bh,YCrt[2]
		call	HDotLineDraw

@@:		ret

DrawMapBorder	ENDP

;----------------------------------------------------------------------------

;* HDotLineDraw - horizontal dotted line draw
;*
;* pass: cx = x1
;*       bl = y1
;*       dx = x2
;*       bh = y2
;* ret : nothing
;* kill: assume all

HDotLineDraw	PROC	NEAR

;* sort x1 < x2 (always draw left to right)

		cmp	cx,dx
		jbe	HDotLoop
		xchg	cx,dx
		xchg	bl,bh

HDotLoop:	cmp	cx,dx		;end of line?
		ja	@F		;yes ->

		push	bx
		push	cx
		push	dx

		mov	al,COL_MAP_BORDER
		call	SetPixel

		pop	dx
		pop	cx
		pop	bx

		add	cx,2

	 	jmp	HDotLoop

@@:		ret

HDotLineDraw	ENDP

;----------------------------------------------------------------------------

;* VDotLineDraw - vertical dotted line draw
;*
;* pass: cx = x1
;*       bl = y1
;*       dx = x2
;*       bh = y2
;* ret : nothing
;* kill: assume all

VDotLineDraw	PROC	NEAR

;* sort y1 <= y2 (always draw top to bottom)

		cmp	bl,bh
		jbe	VDotLoop
		xchg	cx,dx
		xchg	bl,bh

VDotLoop:	cmp	bl,bh		;end of line?
		ja	@F		;yes ->

		push	bx
		push	cx
		push	dx

		mov	al,COL_MAP_BORDER
		call	SetPixel

		pop	dx
		pop	cx
		pop	bx

		add	bl,2

	 	jmp	VDotLoop

@@:		ret

VDotLineDraw	ENDP

PANCODE		ENDS

;============================================================================

		END

