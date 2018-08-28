;****************************************************************************
;*
;* VISDATA.ASM
;*
;* 3D visual data.
;*
;* 19.11.1990 - KJB
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	V_VIEW

		PUBLIC	ViewMode

		PUBLIC	ViewRotateMode

		PUBLIC	ZScaled

		PUBLIC	V_SinH,V_CosH
		PUBLIC	V_SinP,V_CosP
		PUBLIC	V_SinR,V_CosR

		PUBLIC	A1,A2,A3,A4,A5,A6,A7,A8,A9

		PUBLIC	B1,B2,B3,B4,B5,B6,B7,B8,B9

		PUBLIC	C1,C2,C3,C4,C5,C6,C7,C8,C9

		PUBLIC	D1,D2,D3,D4,D5,D6,D7,D8,D9

		PUBLIC	XSX,XSY,XSZ
		PUBLIC	YSX,YSY,YSZ
		PUBLIC	ZSX,ZSY,ZSZ

		PUBLIC	XGX,XGY,XGZ
		PUBLIC	YGX,YGY,YGZ
		PUBLIC	ZGX,ZGY,ZGZ

		PUBLIC	R_XGX,R_XGY,R_XGZ
		PUBLIC	R_YGX,R_YGY,R_YGZ
		PUBLIC	R_ZGX,R_ZGY,R_ZGZ

		PUBLIC	XGridSize
		PUBLIC	YGridSize
		PUBLIC	ZGridSize

		PUBLIC	ObjScaleConvert

		PUBLIC	XGrid1,YGrid1
		PUBLIC	XRel1,YRel1,ZRel1
		PUBLIC	XE01,YE01,ZE01
		PUBLIC	XE01_2,YE01_2,ZE01_2
		PUBLIC	XE01_4,YE01_4,ZE01_4
		PUBLIC	XE01_8,YE01_8,ZE01_8
		PUBLIC	XE01_16,YE01_16,ZE01_16
		PUBLIC	XPos1,YPos1,ZPos1
		PUBLIC	Valid1_2,Valid1_4,Valid1_8,Valid1_16

		PUBLIC	XGrid2,YGrid2
		PUBLIC	XRel2,YRel2,ZRel2
		PUBLIC	XE02,YE02,ZE02
		PUBLIC	XPos2,YPos2,ZPos2

		PUBLIC	XGrid8,YGrid8
		PUBLIC	XRel8,YRel8,ZRel8
		PUBLIC	XE08,YE08,ZE08
		PUBLIC	XPos8,YPos8,ZPos8

		PUBLIC	XGrid16,YGrid16
		PUBLIC	XRel16,YRel16,ZRel16
		PUBLIC	XE016,YE016,ZE016
		PUBLIC	XPos16,YPos16,ZPos16

		PUBLIC	XPos,YPos,ZPos

		PUBLIC	Xe,Ye,Ze

		PUBLIC	XCrt
		PUBLIC	YCrt
		PUBLIC	OutCode
		PUBLIC	CrtBuffer
		PUBLIC	CrtBufPtr

		PUBLIC	Colours
		PUBLIC	Col1
		PUBLIC	Col2

		PUBLIC	StndPoly4
		PUBLIC	StndPoly3

		PUBLIC	ObjectBuffer
		PUBLIC	ObjectBufEnd
		PUBLIC	ObjectBufPtr
		PUBLIC	ObjectDist1
		PUBLIC	ObjectDist2
		PUBLIC	ObjectDist3
		PUBLIC	FarObjectDist

		PUBLIC	SctrScaleMode
		PUBLIC	MapIndex
		PUBLIC	XSecScan
		PUBLIC	YSecScan
		PUBLIC	NoMansLand
		PUBLIC	NumVisSctrs
		PUBLIC	SctrScaleFactor
		PUBLIC	SctrScaleYPos
		PUBLIC	SecScanCnt1
		PUBLIC	SecScanOff1
		PUBLIC	SecScanCnt2
		PUBLIC	SecScanOff2

		PUBLIC	CopyBuffer
		PUBLIC	Cyclic
		PUBLIC	ObjAnimFlags
		PUBLIC	FlatObject

		PUBLIC	MobSortPtr
		PUBLIC	MobSortBins
		PUBLIC	NumMobiles

;============================================================================

		INCLUDE	VISDATA.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

;----------------------
;* viewpoint data block
;----------------------

V_VIEW		VIEWPOINT <>		;see VISDATA.INC

;-----------
;* view mode
;-----------

ViewMode	DW	NUL_VIEWMODE	;see VISDATA.INC

;------------------
;* view rotate mode
;------------------

ViewRotateMode	DW	ROTATE_NULL	;see VISDATA.INC

;----------------
;* compressed zft
;----------------

ZScaled		DW	0

;-------------------------------------
;* heading, pitch and roll trig values
;-------------------------------------

V_SinH		DW	0
V_CosH		DW	0
V_SinP		DW	0
V_CosP		DW	0
V_SinR		DW	0
V_CosR		DW	0

;-----------------------------
;* rotation matrix "A" factors
;-----------------------------

A1		DW	0
A2		DW	0
A3		DW	0
A4		DW	0
A5		DW	0
A6		DW	0
A7		DW	0
A8		DW	0
A9		DW	0

;-----------------------------
;* rotation matrix "B" factors
;-----------------------------

B1		DW	0
B2		DW	0
B3		DW	0
B4		DW	0
B5		DW	0
B6		DW	0
B7		DW	0
B8		DW	0
B9		DW	0

;-----------------------------
;* rotation matrix "C" factors
;-----------------------------

C1		DW	0
C2		DW	0
C3		DW	0
C4		DW	0
C5		DW	0
C6		DW	0
C7		DW	0
C8		DW	0
C9		DW	0

;-----------------------------
;* rotation matrix "D" factors
;-----------------------------

D1		DW	0
D2		DW	0
D3		DW	0
D4		DW	0
D5		DW	0
D6		DW	0
D7		DW	0
D8		DW	0
D9		DW	0

;--------------
;* sector grids
;--------------

XSX		DW	129 DUP(0)
XSY		DW	129 DUP(0)
XSZ		DW	 17 DUP(0)
YSX		DW	129 DUP(0)
YSY		DW	129 DUP(0)
YSZ		DW	 17 DUP(0)
ZSX		DW	129 DUP(0)
ZSY		DW	129 DUP(0)
ZSZ		DW	 17 DUP(0)

;--------------
;* object grids
;--------------

XGX		DW	65 DUP(0)
XGY		DW	65 DUP(0)
XGZ		DW	65 DUP(0)
YGX		DW	65 DUP(0)
YGY		DW	65 DUP(0)
YGZ		DW	65 DUP(0)
ZGX		DW	65 DUP(0)
ZGY		DW	65 DUP(0)
ZGZ		DW      65 DUP(0)

;----------------------
;* rotated object grids
;----------------------

R_XGX		DW	65 DUP(0)
R_XGY		DW	65 DUP(0)
R_XGZ		DW	65 DUP(0)
R_YGX		DW	65 DUP(0)
R_YGY		DW	65 DUP(0)
R_YGZ		DW	65 DUP(0)
R_ZGX		DW	65 DUP(0)
R_ZGY		DW	65 DUP(0)
R_ZGZ		DW      65 DUP(0)

;---------------------
;* variable grid sizes
;---------------------

XGridSize	DW	0
YGridSize	DW	0
ZGridSize	DW	0

;----------------------------------
;* object scale convert to ft table
;----------------------------------

ObjScaleConvert	DB	4	;OBJ_SCALE1  (*16)
		DB	3	;OBJ_SCALE2  (*8)
		DB	2	;OBJ_SCALE4  (*4)
		DB	1	;OBJ_SCALE8  (*2)
		DB	0	;OBJ_SCALE16 (*1)

		EVEN

;----------------------------------------------
;* current sector visual variables (SEC_SCALE1)
;----------------------------------------------

XGrid1		DW	0		;sector sub-division grid co-ords
YGrid1		DW	0

XRel1		DW	0		;sector sub-div offset rel co-ords
YRel1		DW	0
ZRel1		DW	0

XE01		DW	0		;sector sub-div offset eye co-ords
YE01		DW	0
ZE01		DW	0

;* modified values for XE01, YE01 and ZE01 for overscaled objects

XE01_2		DW	0		;2 * overscaled objects
YE01_2		DW	0
ZE01_2		DW	0

XE01_4		DW	0		;4 * overscaled objects
YE01_4		DW	0
ZE01_4		DW	0

XE01_8		DW	0		;8 * overscaled objects
YE01_8		DW	0
ZE01_8		DW	0

XE01_16		DW	0		;16 * overscaled objects
YE01_16		DW	0
ZE01_16		DW	0

XPos1		DW	0		;sector centre position
YPos1		DW	0
ZPos1		DW	0

Valid1_2	DB	0		;1 = 2 * overscaled vars are valid
Valid1_4	DB	0		;1 = 4 * overscaled vars are valid
Valid1_8	DB	0		;1 = 8 * overscaled vars are valid
Valid1_16	DB	0		;1 = 16 * overscaled vars are valid

;---------------------------------------------
;* 3 by 3 sector visual variables (SEC_SCALE2)
;---------------------------------------------

XGrid2		DW	0		;sector sub-division grid co-ords
YGrid2		DW	0

XRel2		DW	0		;sector sub-div offset rel co-ords
YRel2		DW	0
ZRel2		DW	0

XE02		DW	0		;sector sub-div offset eye co-ords
YE02		DW	0
ZE02		DW	0

XPos2		DW	0		;sector centre position
YPos2		DW	0
ZPos2		DW	0

;---------------------------------------------
;* 7 by 7 sector visual variables (SEC_SCALE8)
;---------------------------------------------

XGrid8		DW	0		;sector sub-division grid co-ords
YGrid8		DW	0

XRel8		DW	0		;sector sub-div offset rel co-ords
YRel8		DW	0
ZRel8		DW	0

XE08		DW	0		;sector sub-div offset eye co-ords
YE08		DW	0
ZE08		DW	0

XPos8		DW	0		;sector centre position
YPos8		DW	0
ZPos8		DW	0

;------------------------------------------------
;* 15 by 15 sector visual variables (SEC_SCALE16)
;------------------------------------------------

XGrid16		DW	0		;sector sub-division grid co-ords
YGrid16		DW	0

XRel16		DW	0		;sector sub-div offset rel co-ords
YRel16		DW	0
ZRel16		DW	0

XE016		DW	0		;sector sub-div offset eye co-ords
YE016		DW	0
ZE016		DW	0

XPos16		DW	0		;sector centre position
YPos16		DW	0
ZPos16		DW	0

;------------------------
;* object centre position
;------------------------

XPos		DW	0
YPos		DW	0
ZPos		DW	0

;-------------------
;* eye co-ord arrays
;-------------------

NUM_POINTS	EQU	128		;max number of points per object

Xe		DW	NUM_POINTS DUP(0)
Ye		DW	NUM_POINTS DUP(0)
Ze		DW	NUM_POINTS DUP(0)

;------------------------
;* crt and outcode arrays
;------------------------

XCrt		DW	NUM_POINTS DUP(0)
YCrt		DB	0
OutCode		DB	0
		DW	NUM_POINTS-1 DUP(0)

CrtBuffer	DW	1024 DUP(0)

CrtBufPtr	DW	0

;----------------------
;* logical colour store
;----------------------

Colours		LABEL	WORD

Col1		DB	0
Col2		DB	0

;-------------------------------
;* standard polygon vertex lists
;-------------------------------

StndPoly4	DB	0,2,4,6,-1	;4 points

StndPoly3	DB	0,2,4,-1	;3 points

		EVEN

;----------------
;* object buffers (required for depth buffering)
;----------------

ObjectBuffer	OBJECTDATA NUM_OBJECTS+NUM_FAR_OBJECTS DUP(<>)

ObjectBufEnd	LABEL	WORD

ObjectBufPtr	DW	0

;* ObjectDist1[] - objects below clouds (all ground objects + mobile objects)
;*
;* ObjectDist1[BEHIND_BIN]     : no sort
;* ObjectDist1[IN_FRONT_BIN+n] : bin sort (n = y eye / 256 * 2) + insertion sort

ObjectDist1	DW	NUM_BINS DUP(-1)	

;* ObjectDist2[] - objects in clouds (mobile objects only)
;*
;* ObjectDist2[BEHIND_BIN]   : no sort
;* ObjectDist2[IN_FRONT_BIN] : insertion sort

ObjectDist2	DW	-1,-1

;* ObjectDist3[] - objects above clouds (mobile objects only)
;*
;* ObjectDist3[BEHIND_BIN]   : no sort
;* ObjectDist3[IN_FRONT_BIN] : insertion sort

ObjectDist3	DW	-1,-1

FarObjectDist	DW	NUM_FAR_BINS DUP(-1)

;--------------------------
;* sector drawing variables
;--------------------------

SctrScaleMode	DW	0

MapIndex	DW	0

XSecScan	DW	0		;xsec of sector being drawn
YSecScan	DW	0		;ysec of sector being drawn

NoMansLand	DB	0,0		;1 = no mans land

NumVisSctrs	DW	0

;* scaling factors wrt sector scale mode

SctrScaleFactor	DW	0		;SEC_SCALE1  (/1)
		DW	1		;SEC_SCALE2  (/2)
		DW	3		;SEC_SCALE8  (/8)
		DW	4		;SEC_SCALE16 (/16)

;* look up y pos wrt sector scale mode

SctrScaleYPos	DW	OFFSET YPos1	;SEC_SCALE1
		DW	OFFSET YPos2	;SEC_SCALE2
		DW	OFFSET YPos8 	;SEC_SCALE8
		DW	OFFSET YPos16	;SEC_SCALE16

;* flat ground feature sector scan vars

SecScanCnt1	DW	MAX_SEC_SCAN	;MIN_SEC_SCAN .. MAX_SEC_SCAN step 2

SecScanOff1	DW	-(MAX_SEC_SCAN/2)

;* cloud sector scan vars

SecScanCnt2	DW	MAX_SEC_SCAN 	;MIN_SEC_SCAN .. MAX_SEC_SCAN step 2

SecScanOff2	DW	-(MAX_SEC_SCAN/2)

;------------------------------------
;* object drawing variables / buffers
;------------------------------------

CopyBuffer	DB	1500 DUP(0)

Cyclic		DB	0,0		;+1 = clk, 0 = invalid, -1 = anti-clk

ObjAnimFlags	DB	0,0

FlatObject	OBJECTDATA <>		;flat object data record

;--------------------------------
;* mobile object sector sort bins
;--------------------------------

MobSortPtr	DW	OFFSET MobSortBins

MobSortBins	MOBSORT	NUM_MOBILES DUP(<>)

NumMobiles	DW	0		;number of active mobiles

DATA		ENDS

;============================================================================

		END

