;****************************************************************************
;*
;* HILLS.ASM
;*
;* Hill scan / draw.
;*
;* 13.06.1991 - KJB
;* 28.09.1991 - KJB - hill face texture added.
;* 13.10.1991 - KJB - CalcGndHeight routine added.
;* 13.02.1992 - KJB - HillFaceLists made public.
;* 06.10.1992 - KJB - QCalcGndHeight routine added.
;*
;* General Information
;* -------------------
;*
;* The major problem with drawing hills is the presence of concave faces
;* within the hill structure. The method used to process hills can cope with
;* most cases but the occurance of face "breakthrough" is to be expected.
;* In certain cases it may be possible to disguise breakthrough by carefully
;* selecting the face colours.
;*
;* Each hill face is passed through the 3D process as an independant object.
;* However, special sorting routines are used to distance sort the hill faces.
;* These routines use minimum and maximum y eye values to sort the faces
;*
;* Hill Data Format
;* ----------------
;*
;* The hill data resides in the sector layer map:-
;*
;*    HillLayer1[] = quad 1 crease / spot height data
;*    HillLayer2[] = quad 2 crease / spot height data
;*    HillLayer3[] = quad 3 crease / spot height data
;*    HillLayer4[] = quad 4 crease / spot height data
;*    HillLayer5[] = quad 1 face colours
;*    HillLayer6[] = quad 2 face colours
;*    HillLayer7[] = quad 3 face colours
;*    HillLayer8[] = quad 4 face colours
;*    HillLayer9[] = attributes
;*
;* Each sector is sub-divided into quadrants (quad 1 .. quad 4). 
;*
;* The top left hand corner of each quadrant is given a spot height in the
;* range 0 .. 15 (0 .. 15 * 256ft = 3,840ft):-
;*
;* 		  	+Z1------+Z2------+
;* 		  	I        I        I
;* 		  	I quad 1 I quad 2 I
;* 		  	I        I        I
;* 		  	+Z3------+Z4------+
;* 		  	I        I        I
;* 		  	I quad 3 I quad 4 I
;* 		  	I        I        I
;* 		  	+--------+--------+
;*
;* Each quadrant can be divided into two triangular faces (giving a maximum of
;* 8 faces per sector) in one of two ways:-
;*
;* 		  	+-------+-------+
;* 		  	I \     I     / I
;* 		  	I   \   I   /   I <--- "Z" crease
;* 		  	I     \ I /     I
;* 		  	+-------+-------+  or
;* 		  	I     / I \     I
;* 		  	I   /   I   \   I <--- reverse "Z" crease
;* 		  	I /     I     \ I
;* 		  	+-------+-------+
;*
;* Z crease face numbering:-
;*
;* 		  	+-------+-------+
;* 		  	I F0  / I F2  / I
;* 		  	I   /   I   /   I
;* 		  	I /  F1 I /  F3 I
;* 		  	+-------+-------+
;* 		  	I F4  / I F6  / I
;* 		  	I   /   I   /   I
;* 		  	I /  F5 I /  F7 I
;* 		  	+-------+-------+
;*
;* reverse Z crease face numbering:-
;*
;* 		  	+-------+-------+
;* 		  	I \  F1 I \  F3 I
;* 		  	I   \   I   \   I
;* 		  	I F0  \ I F2  \ I
;* 		  	+-------+-------+
;* 		  	I \  F5 I \  F7 I
;* 		  	I   \   I   \   I
;* 		  	I F4  \ I F6  \ I
;* 		  	+-------+-------+
;*
;* Nine spot heights are required for each sector (ZA .. ZI), therefore, data
;* must be taken from adjacent sectors:-
;*
;* 		  	+ZA------+ZB------+ZC-----
;* 		  	I        I        I
;* 		  	I quad 1 I quad 2 I quad 1
;* 		  	I        I        I
;* 		  	+ZD------+ZE------+ZF----- (MapIndex + 1)
;* 		  	I        I        I
;* 		  	I quad 3 I quad 4 I quad 3
;* 		  	I        I        I
;* 		  	+ZG------+ZH------+ZI-----
;*			I        I     	  I
;*			I quad 1 I quad 2 I quad 1
;*			I        I	  I
;*
;*			  (MapIndex + 32)          (MapIndex + 33)
;*
;* Note that hills cannot be placed in sectors where x sec or y sec = 31 as
;* the adjacent sectors do not exist (wrap around not used).
;*
;* Crease / Spot Height Data
;* -------------------------
;*
;*    HillLayer1[] = b7: 0 = Z crease, 1 = reverse Z crease
;*                   b6:
;*                   b5:
;*                   b4:
;*                   b3: )
;*                   b2: ) Z1 spot height
;*                   b1: ) 
;*                   b0: )
;*
;*    HillLayer2[] = b7: 0 = Z crease, 1 = reverse Z crease
;*                   b6:
;*                   b5:
;*                   b4:
;*                   b3: )
;*                   b2: ) Z2 spot height
;*                   b1: ) 
;*                   b0: )
;*
;*    HillLayer3[] = b7: 0 = Z crease, 1 = reverse Z crease
;*                   b6:
;*                   b5:
;*                   b4:
;*                   b3: )
;*                   b2: ) Z3 spot height
;*                   b1: ) 
;*                   b0: )
;*
;*    HillLayer4[] = b7: 0 = Z crease, 1 = reverse Z crease
;*                   b6:
;*                   b5:
;*                   b4:
;*                   b3: )
;*                   b2: ) Z4 spot height
;*                   b1: ) 
;*                   b0: )
;*
;* Face Colour Data
;* ----------------
;*						 
;* Colour range 0 .. 15 where col 0 = unused face.
;*
;*    HillLayer5[] = b7  b6  b5  b4  b3  b2  b1  b0
;*                   --------------  --------------
;*                     face 1 col      face 0 col
;*
;*    HillLayer6[] = b7  b6  b5  b4  b3  b2  b1  b0
;*                   --------------  --------------
;*                     face 3 col      face 2 col
;*
;*    HillLayer7[] = b7  b6  b5  b4  b3  b2  b1  b0
;*                   --------------  --------------
;*                     face 5 col      face 4 col
;*
;*    HillLayer8[] = b7  b6  b5  b4  b3  b2  b1  b0
;*                   --------------  --------------
;*                     face 7 col      face 6 col
;*
;* Attribute Data
;* --------------
;*
;*    HillLayer9[] = b7: 0 = no hills in sector, 1 = hills in sector
;*                   b6:
;*                   b5:
;*                   b4:
;*                   b3:
;*                   b2:
;*                   b1:
;*                   b0:
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	ScanHills
		PUBLIC	DrawHillFace
		PUBLIC	CalcGndHeight
		PUBLIC	QCalcGndHeight

		PUBLIC	HillFaceLists
		PUBLIC	HillFaceList0
		PUBLIC	HillFaceList1
		PUBLIC	HillFaceList2
		PUBLIC	HillFaceList3
		PUBLIC	HillFaceList4
		PUBLIC	HillFaceList5
		PUBLIC	HillFaceList6
		PUBLIC	HillFaceList7
		PUBLIC	HillTextEnabled

		EXTRN	PolyFill:FAR

		EXTRN	NearHillSort:NEAR
		EXTRN	FarHillSort:NEAR
		EXTRN	CalcOutCodes:NEAR
		EXTRN	PolyClip:NEAR
		EXTRN	CyclicCheck:NEAR

		EXTRN	HillLayer1:BYTE
		EXTRN	HillLayer2:BYTE
		EXTRN	HillLayer3:BYTE
		EXTRN	HillLayer4:BYTE
		EXTRN	HillLayer5:BYTE
		EXTRN	HillLayer6:BYTE
		EXTRN	HillLayer7:BYTE
		EXTRN	HillLayer8:BYTE
		EXTRN	HillLayer9:BYTE

;============================================================================

		INCLUDE	VISEXTRN.INC
		INCLUDE	VISDATA.INC
		INCLUDE	PALETTES.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

;* sort face distance switch wrt sector scale mode

SortFaceDist	DW	SortFaceDist1	;SEC_SCALE1
		DW	SortFaceDist2	;SEC_SCALE2
		DW	SortFaceDist8	;SEC_SCALE8
		DW	SortFaceDist16	;SEC_SCALE16

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

;* calc spot height position switch

CalcSpotHeight	DW	CalcZAPos
		DW	CalcZBPos
		DW	CalcZCPos
		DW	CalcZDPos
		DW	CalcZEPos
		DW	CalcZFPos
		DW	CalcZGPos
		DW	CalcZHPos
		DW	CalcZIPos

;* face lists (clockwise order, 90 degree angle is first angle to help cyclic check)

HillFaceLists	LABEL	BYTE

HillFaceList0	DB	$ZD,$ZA,$ZB,-1	;Z crease
		DB	$ZE,$ZD,$ZA,-1	;reverse Z crease
		
HillFaceList1	DB	$ZB,$ZE,$ZD,-1	;Z crease
		DB	$ZA,$ZB,$ZE,-1	;reverse Z crease

HillFaceList2	DB	$ZE,$ZB,$ZC,-1	;Z crease
		DB	$ZF,$ZE,$ZB,-1	;reverse Z crease

HillFaceList3	DB	$ZC,$ZF,$ZE,-1	;Z crease
		DB	$ZB,$ZC,$ZF,-1	;reverse Z crease

HillFaceList4	DB	$ZG,$ZD,$ZE,-1	;Z crease
		DB	$ZH,$ZG,$ZD,-1	;reverse Z crease

HillFaceList5	DB	$ZE,$ZH,$ZG,-1	;Z crease
		DB	$ZD,$ZE,$ZH,-1	;reverse Z crease

HillFaceList6	DB	$ZH,$ZE,$ZF,-1	;Z crease
		DB	$ZI,$ZH,$ZE,-1	;reverse Z crease

HillFaceList7	DB	$ZF,$ZI,$ZH,-1	;Z crease
		DB	$ZE,$ZF,$ZI,-1	;reverse Z crease

FaceCol		DB	0,0		;face colour

;-------------------------------
;* hill face texture vars / data
;-------------------------------

HillTextEnabled	DB	1,0		;1 = hill face texture enabled

;* texture face lists

;*		DB	v1, v2, v3, -1, colour modifier

TextFaces	DB	14,  2, 16, -1,  0	;sub-face 0
		DB	 6, 14, 26, -1,  0	;sub-face 1
		DB	16, 26, 14, -1, -1	;sub-face 2
		DB	26, 16,  8, -1,  0	;sub-face 3
		DB	12,  6, 24, -1,  0	;sub-face 4
		DB	26, 24,  6, -1, -1	;sub-face 5
		DB	24, 26, 28, -1,  0	;sub-face 6
		DB	 8, 28, 26, -1, -1	;sub-face 7
		DB	28,  8, 18, -1,  0	;sub-face 8
		DB	 0, 12, 22, -1,  0	;sub-face 9
		DB	24, 22, 12, -1, -1	;sub-face 10
		DB	22, 24, 10, -1,  0	;sub-face 11
		DB	28, 10, 24, -1, -1	;sub-face 12
		DB	10, 28, 20, -1,  0	;sub-face 13
		DB	18, 20, 28, -1, -1	;sub-face 14
		DB	20, 18,  4, -1,  0	;sub-face 15

		EVEN

;-------------------------
;* calc ground height data
;-------------------------

;* sort quadrant switch

SortQuad	DW	SortQuad2	;+x, +y
		DW	SortQuad1	;-x, +y
		DW	SortQuad4	;+x, -y
		DW	SortQuad3	;-x, -y

;----------------------------
;* nearest spot height switch
;----------------------------

SortQSpotHt	DW	QSpotHtG  	;xxyy0 = 00000
		DW	QSpotHtD  	;xxyy0 = 00010
		DW	QSpotHtD  	;xxyy0 = 00100
		DW	QSpotHtA  	;xxyy0 = 00110
		DW	QSpotHtH  	;xxyy0 = 01000
		DW	QSpotHtE  	;xxyy0 = 01010
		DW	QSpotHtE  	;xxyy0 = 01100
		DW	QSpotHtB  	;xxyy0 = 01110
		DW	QSpotHtH  	;xxyy0 = 10000
		DW	QSpotHtE  	;xxyy0 = 10010
		DW	QSpotHtE  	;xxyy0 = 10100
		DW	QSpotHtB  	;xxyy0 = 10110
		DW	QSpotHtI  	;xxyy0 = 11000
		DW	QSpotHtF  	;xxyy0 = 11010
		DW	QSpotHtF  	;xxyy0 = 11100
		DW	QSpotHtC  	;xxyy0 = 11110

DATA		ENDS

;============================================================================

VISCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:VISCODE
		ASSUME DS:DATA

;* ScanHills - scan sector for hills
;*
;* pass: MapIndex
;*       HillLayer1[] .. HillLayer9[]
;* ret : nothing
;* kill: assume all

ScanHillsExit	LABEL	NEAR

		ret

ScanHills	PROC	NEAR

;--------------------------
;* test for hills in sector
;--------------------------

		mov	bp,MapIndex
		mov	al,HillLayer9[bp]
		test	al,al		;null hills?
		jns	ScanHillsExit	;yes ->

;---------------------------------
;* calc y eye co-ords for ZA .. ZI
;---------------------------------

;* look up scaling factor wrt sector scale mode

		mov	bx,SctrScaleMode

		mov	cx,SctrScaleFactor[bx]

;* look up y pos sector centre wrt sector scale mode

		mov	bx,SctrScaleYPos[bx]
		mov	dx,[bx]

;* calc ZA y eye co-ord

		mov	bl,HillLayer1[bp]
		and	bx,0000fh	;spot height 0 .. 15
		shl	bx,1		;*2 word index

		mov	ax,YSX[$MID-$8192]
		add	ax,YSY[$MID+$8192]
		add	ax,YSZ[bx]
		sar	ax,cl
		add	ax,dx
		mov	Ye[$ZA],ax
	
;* calc ZB y eye co-ord

		mov	bl,HillLayer2[bp]
		and	bx,0000fh	;spot height 0 .. 15
		shl	bx,1		;*2 word index

		mov	ax,YSY[$MID+$8192]
		add	ax,YSZ[bx]
		sar	ax,cl
		add	ax,dx
		mov	Ye[$ZB],ax
	
;* calc ZC y eye co-ord

		mov	bl,HillLayer1[bp+1]
		and	bx,0000fh	;spot height 0 .. 15
		shl	bx,1		;*2 word index

		mov	ax,YSX[$MID+$8192]
		add	ax,YSY[$MID+$8192]
		add	ax,YSZ[bx]
		sar	ax,cl
		add	ax,dx
		mov	Ye[$ZC],ax
	
;* calc ZD y eye co-ord

		mov	bl,HillLayer3[bp]
		and	bx,0000fh	;spot height 0 .. 15
		shl	bx,1		;*2 word index

		mov	ax,YSX[$MID-$8192]
		add	ax,YSZ[bx]
		sar	ax,cl
		add	ax,dx
		mov	Ye[$ZD],ax
	
;* calc ZE y eye co-ord

		mov	bl,HillLayer4[bp]
		and	bx,0000fh	;spot height 0 .. 15
		shl	bx,1		;*2 word index

		mov	ax,YSZ[bx]
		sar	ax,cl
		add	ax,dx
		mov	Ye[$ZE],ax
	
;* calc ZF y eye co-ord

		mov	bl,HillLayer3[bp+1]
		and	bx,0000fh	;spot height 0 .. 15
		shl	bx,1		;*2 word index

		mov	ax,YSX[$MID+$8192]
		add	ax,YSZ[bx]
		sar	ax,cl
		add	ax,dx
		mov	Ye[$ZF],ax
	
;* calc ZG y eye co-ord

		mov	bl,HillLayer1[bp+32]
		and	bx,0000fh	;spot height 0 .. 15
		shl	bx,1		;*2 word index

		mov	ax,YSX[$MID-$8192]
		add	ax,YSY[$MID-$8192]
		add	ax,YSZ[bx]
		sar	ax,cl
		add	ax,dx
		mov	Ye[$ZG],ax
	
;* calc ZH y eye co-ord

		mov	bl,HillLayer2[bp+32]
		and	bx,0000fh	;spot height 0 .. 15
		shl	bx,1		;*2 word index

		mov	ax,YSY[$MID-$8192]
		add	ax,YSZ[bx]
		sar	ax,cl
		add	ax,dx
		mov	Ye[$ZH],ax
	
;* calc ZI y eye co-ord

		mov	bl,HillLayer1[bp+33]
		and	bx,0000fh	;spot height 0 .. 15
		shl	bx,1		;*2 word index
		
		mov	ax,YSX[$MID+$8192]
		add	ax,YSY[$MID-$8192]
		add	ax,YSZ[bx]
		sar	ax,cl
		add	ax,dx
		mov	Ye[$ZI],ax

;-------------------------------------
;* sort quad 1 faces (face 0 / face 1)
;-------------------------------------

;* face 0

		mov	dl,HillLayer5[bp]	;quad 1 colour data
		mov	dh,HillLayer1[bp]	;quad 1 crease flag

		test	dl,00001111b	;face 0 required?
		jz	ContFace1	;no ->

		push	dx

		mov	si,OFFSET HillFaceList0

		mov	al,0*2		;face num

		test	dh,080h 	;Z crease?
		jz	CreaseOk0	;yes ->
		add	si,4		;reverse Z crease
		inc	al		;face num + 1

CreaseOk0:	shl	dl,1		;shift colour into high nibble
		shl	dl,1
		shl	dl,1
		shl	dl,1

		or	al,dl		;face flags = face col and face num

		call	SortHillFace

		pop	dx

;* face 1
		
ContFace1: 	and 	dl,11110000b	;face 1 required (clear low nibble)?
		jz	ContFace2 	;no ->

		mov	si,OFFSET HillFaceList1

		mov	al,1*2		;face num

		test	dh,080h 	;Z crease?
		jz	CreaseOk1	;yes ->
		add	si,4		;reverse Z crease
		inc	al		;face num + 1

CreaseOk1:	or	al,dl		;face flags = face col and face num

		call	SortHillFace
		
;-------------------------------------
;* sort quad 2 faces (face 2 / face 3)
;-------------------------------------

;* face 2

ContFace2:	mov	dl,HillLayer6[bp]	;quad 2 colour data
		mov	dh,HillLayer2[bp]	;quad 2 crease flag

		test	dl,00001111b	;face 2 required?
		jz	ContFace3	;no ->

		push	dx

		mov	si,OFFSET HillFaceList2

		mov	al,2*2		;face num

		test	dh,080h 	;Z crease?
		jz	CreaseOk2	;yes ->
		add	si,4		;reverse Z crease
		inc	al		;face num + 1

CreaseOk2:	shl	dl,1		;shift colour into high nibble
		shl	dl,1
		shl	dl,1
		shl	dl,1

		or	al,dl		;face flags = face col and face num

		call	SortHillFace

		pop	dx

;* face 3
		
ContFace3: 	and 	dl,11110000b	;face 3 required (clear low nibble)?
		jz	ContFace4	;no ->

		mov	si,OFFSET HillFaceList3

		mov	al,3*2		;face num

		test	dh,080h 	;Z crease?
		jz	CreaseOk3	;yes ->
		add	si,4		;reverse Z crease
		inc	al		;face num + 1

CreaseOk3:	or	al,dl		;face flags = face col and face num

		call	SortHillFace
		
;-------------------------------------
;* sort quad 3 faces (face 4 / face 5)
;-------------------------------------

;* face 4

ContFace4:	mov	dl,HillLayer7[bp]	;quad 3 colour data
		mov	dh,HillLayer3[bp]	;quad 3 crease flag

		test	dl,00001111b	;face 4 required?
		jz	ContFace5	;no ->

		push	dx

		mov	si,OFFSET HillFaceList4

		mov	al,4*2		;face num

		test	dh,080h 	;Z crease?
		jz	CreaseOk4	;yes ->
		add	si,4		;reverse Z crease
		inc	al		;face num + 1

CreaseOk4:	shl	dl,1		;shift colour into high nibble
		shl	dl,1
		shl	dl,1
		shl	dl,1

		or	al,dl		;face flags = face col and face num

		call	SortHillFace

		pop	dx

;* face 5
		
ContFace5: 	and 	dl,11110000b	;face 5 required (clear low nibble)?
		jz	ContFace6	;no ->

		mov	si,OFFSET HillFaceList5

		mov	al,5*2		;face num

		test	dh,080h 	;Z crease?
		jz	CreaseOk5	;yes ->
		add	si,4		;reverse Z crease
		inc	al		;face num + 1

CreaseOk5:	or	al,dl		;face flags = face col and face num

		call	SortHillFace
		
;-------------------------------------
;* sort quad 4 faces (face 6 / face 7)
;-------------------------------------

;* face 6

ContFace6:	mov	dl,HillLayer8[bp]	;quad 4 colour data
		mov	dh,HillLayer4[bp]	;quad 4 crease flag

		test	dl,00001111b	;face 6 required?
		jz	ContFace7	;no ->

		push	dx

		mov	si,OFFSET HillFaceList6

		mov	al,6*2		;face num

		test	dh,080h 	;Z crease?
		jz	CreaseOk6	;yes ->
		add	si,4		;reverse Z crease
		inc	al		;face num + 1

CreaseOk6:	shl	dl,1		;shift colour into high nibble
		shl	dl,1
		shl	dl,1
		shl	dl,1

		or	al,dl		;face flags = face col and face num

		call	SortHillFace

		pop	dx

;* face 7
		
ContFace7: 	and 	dl,11110000b	;face 7 required (clear low nibble)?
		jz	ContFace8	;no ->

		mov	si,OFFSET HillFaceList7

		mov	al,7*2		;face num

		test	dh,080h 	;Z crease?
		jz	CreaseOk7	;yes ->
		add	si,4		;reverse Z crease
		inc	al		;face num + 1

CreaseOk7:	or	al,dl		;face flags = face col and face num

		call	SortHillFace
		
ContFace8:	ret

ScanHills	ENDP

;----------------------------------------------------------------------------

;* SortHillFace - generate object record and distance sort face
;*
;* pass: al = face flags
;*       si -> face list
;*       ie. [si+0] = vertex index 1
;*           [si+1] = vertex index 2
;*           [si+2] = vertex index 3
;*           [si+3] = -1 (list terminator)
;*       bp = map index
;*       ObjectBufPtr
;* ret : cf = 0: face visible
;*       cf = 1: face non-visible or error
;*       ObjectBufPtr
;* kill: assume all (except bp, cf)
;*
;* note: Face flags = b7: )
;*		      b6: ) face colour 0 .. 15
;*		      b5: )
;*		      b4: )
;*
;*		      b3: )
;*		      b2: ) face number 0 .. 7 * 2 + 1 if reverse Z crease
;*		      b1: )
;*		      b0: )

SortFaceFail1	LABEL	NEAR

		pop	bp		;restore map index

SortFaceFail2:	stc			;cf = 1 = non-visible or error
		ret

SortHillFace	PROC	NEAR

		mov	di,ObjectBufPtr
		cmp	di,OFFSET ObjectBufEnd
		je	SortFaceFail2	;no space left in object buffer ->

		mov	OBJ_FACE_FLAGS[di],al

		mov	OBJ_MAPINDEX[di],bp

		push	bp		;store map index

;----------------------------------------------------------------
;* look up y eye for each face vertex and sort furthest	/ nearest
;----------------------------------------------------------------

		xor	bx,bx

		mov	bl,[si+0]	;vertex index 1
		mov	dx,Ye[bx] 	;y1

		mov	bl,[si+1]	;vertex index 2
		mov	ax,Ye[bx]	;y2

		mov	bl,[si+2]	;vertex index 3
		mov	bp,Ye[bx]	;y3

;* ensure y1 >= y2

		cmp	dx,ax		;y1 >= y2?
		jge	YOk1		;yes ->
		xchg	dx,ax

;* ensure y1 >= y3

YOk1:		cmp	dx,bp		;y1 >= y3?
		jge	YOk2		;yes ->
		xchg	dx,bp

;* ensure y2 >= y3 (therefore y1 >= y2 >= y3)

YOk2:		cmp	ax,bp		;y2 >= y3?
		jge	YOk3		;yes ->
		xchg	ax,bp

;* if furthest y eye is negative (behind) then ignore face (non-visible)

YOk3:		test	dx,dx
		js	SortFaceFail1	;non-visible ->

		mov	al,OTYPE_HILLFACE
		mov	OBJ_TYPE[di],al

		mov	bx,SctrScaleMode
		mov	OBJ_SECSCALE[di],bl

		jmp	SortFaceDist[bx]

;-----------------
;* SEC_SCALE1 face
;-----------------

SortFaceDist1:	mov	ax,XPos1
		mov	OBJ_XSECPOS[di],ax
		mov	ax,YPos1
		mov	OBJ_YSECPOS[di],ax
		mov	ax,ZPos1
		mov	OBJ_ZSECPOS[di],ax

		cmp	dx,16384	;near or far?
		jge	SortFarFace1	;far ->

		mov	OBJ_YPOS[di],dx

		mov	OBJ_YMIN[di],bp

		call	NearHillSort

		jmp	FaceOk

SortFarFace1:	sar	dx,1		;/2
		sar	dx,1		;/4
		sar	dx,1		;/8
		sar	dx,1		;/16 scaling for far sort

		mov	OBJ_YPOS[di],dx

		sar	bp,1		;/2
		sar	bp,1		;/4
		sar	bp,1		;/8
		sar	bp,1		;/16 scaling for far sort

		mov	OBJ_YMIN[di],bp

		call	FarHillSort

		jmp	FaceOk

;-----------------
;* SEC_SCALE2 face
;-----------------

SortFaceDist2:	mov	ax,XPos2
		mov	OBJ_XSECPOS[di],ax
		mov	ax,YPos2
		mov	OBJ_YSECPOS[di],ax
		mov	ax,ZPos2
		mov	OBJ_ZSECPOS[di],ax

		cmp	dx,16384/2	;near or far?
		jge	SortFarFace2	;far ->

		sal	dx,1		;*2 scaling for near sort

		mov	OBJ_YPOS[di],dx

		sal	bp,1		;*2 scaling for near sort

		mov	OBJ_YMIN[di],bp

		call	NearHillSort

		jmp	FaceOk

SortFarFace2:	sar	dx,1		;/2
		sar	dx,1		;/4
		sar	dx,1		;/8 scaling for far sort

		mov	OBJ_YPOS[di],dx

		sar	bp,1		;/2
		sar	bp,1		;/4
		sar	bp,1		;/8 scaling for far sort

		mov	OBJ_YMIN[di],bp

		call	FarHillSort

		jmp	FaceOk
	
;-----------------
;* SEC_SCALE8 face
;-----------------

SortFaceDist8:	mov	ax,XPos8
		mov	OBJ_XSECPOS[di],ax
		mov	ax,YPos8
		mov	OBJ_YSECPOS[di],ax
		mov	ax,ZPos8
		mov	OBJ_ZSECPOS[di],ax

		cmp	dx,16384/8	;near or far?
		jge	SortFarFace8	;far ->

		sal	dx,1		;*2
		sal	dx,1		;*4
		sal	dx,1		;*8 scaling for near sort

		mov	OBJ_YPOS[di],dx

		sal	bp,1		;*2
		sal	bp,1		;*4
		sal	bp,1		;*8 scaling for near sort

		mov	OBJ_YMIN[di],bp

		call	NearHillSort

		jmp	FaceOk

SortFarFace8:  	sar	dx,1		;/2 scaling for far sort

		mov	OBJ_YPOS[di],dx

		sar	bp,1		;/2 scaling for far sort

		mov	OBJ_YMIN[di],bp

		call	FarHillSort

		jmp	FaceOk
	
;------------------
;* SEC_SCALE16 face
;------------------

SortFaceDist16:	mov	ax,XPos16
		mov	OBJ_XSECPOS[di],ax
		mov	ax,YPos16
		mov	OBJ_YSECPOS[di],ax
		mov	ax,ZPos16
		mov	OBJ_ZSECPOS[di],ax

;* SEC_SCALE16 faces must be "far", but test if in range to prevent dist sort overflow

		cmp	dx,8192		;in range (dist < (2048*64)/16)?
		jl	SortFarFace16	;yes ->

		jmp	SortFaceFail1

SortFarFace16:	mov	OBJ_YPOS[di],dx

		mov	OBJ_YMIN[di],bp

		call	FarHillSort

;------------------------------
;* update object buffer pointer
;------------------------------

FaceOk:		add	di,OBJ_REC_SIZE
		mov	ObjectBufPtr,di

		pop	bp		;restore map index

		clc			;cf = 0 = visible
		ret

SortHillFace	ENDP

;----------------------------------------------------------------------------

;* SUBDIV - sub-divide two eye co-ords
;*
;* pass: dest = dest eye co-ord index
;*       s1   = source eye co-ord 1 index
;*       s2   = source eye co-ord 2 index
;* ret : Xe[dest], Ye[dest], Ze[dest]
;* kill: ax, dx, flags

SUBDIV		MACRO	dest,s1,s2

		mov	ax,Xe[s2]
		mov	dx,Xe[s1]
		sub	ax,dx		;s2 - s1
		sar	ax,1		;(s2 - s1) / 2
		add	ax,dx		;(s2 - s1) / 2 + s1
		mov	Xe[dest],ax

		mov	ax,Ye[s2]
		mov	dx,Ye[s1]
		sub	ax,dx		;s2 - s1
		sar	ax,1		;(s2 - s1) / 2
		add	ax,dx		;(s2 - s1) / 2 + s1
		mov	Ye[dest],ax

		mov	ax,Ze[s2]
		mov	dx,Ze[s1]
		sub	ax,dx		;s2 - s1
		sar	ax,1		;(s2 - s1) / 2
		add	ax,dx		;(s2 - s1) / 2 + s1
		mov	Ze[dest],ax

		ENDM

;----------------------------------------------------------------------------

;* DrawHillFace - draw hill face
;*
;* pass: si -> OBJECTDATA record
;* ret : cf = 0 = ok
;*       cf = 1 = error
;* kill: assume all

DrawHillFace	PROC	NEAR

;* sort sector scaling factor wrt sector scale mode

		mov	bl,OBJ_SECSCALE[si]
		xor	bh,bh
		mov	cx,SctrScaleFactor[bx]

		mov	bp,OBJ_MAPINDEX[si]

;* extract face colour and sort logical colour

		mov	al,OBJ_FACE_FLAGS[si]

		mov	ah,al

		shr	al,1
		shr	al,1
		shr	al,1
		shr	al,1
		add	al,COL_HILL1
		mov	FaceCol,al

		mov	al,ah

;* calc face list pointer

		and	ax,00fh
		shl	ax,1		;*2
		shl	ax,1		;*4 index
		add	ax,OFFSET HillFaceLists

		mov	dx,ax

;---------------
;* sort vertex 1
;---------------

		xor	di,di

		mov	bx,dx

		mov	bl,[bx+0]
		xor	bh,bh
		call	CalcSpotHeight[bx]

;---------------
;* sort vertex 2
;---------------

		mov	di,2

		mov	bx,dx

		mov	bl,[bx+1]
		xor	bh,bh
		call	CalcSpotHeight[bx]

;---------------
;* sort vertex 3
;---------------

		mov	di,4

		mov	bx,dx

		mov	bl,[bx+2]
		xor	bh,bh
		call	CalcSpotHeight[bx]

;-------------------
;* sort face texture
;-------------------

		test	HillTextEnabled,1	;hill face texture enabled?
		jz	Plain			;no ->

		mov	al,OBJ_SECSCALE[si]

		cmp	al,SEC_SCALE2	;current or adjacent sector?
		jbe	Textured	;yes ->

;-------------------------------
;* draw plain face  (no texture)
;-------------------------------

Plain:		mov	si,4
		call	CalcOutCodes
		jc	DrawFaceExit1	;non-visible ->

		mov	si,OFFSET StndPoly3
		mov	di,OFFSET CrtBuffer
		call	PolyClip
		jc	DrawFaceExit1	;non-visible ->

		mov	si,OFFSET CrtBuffer
		call	CyclicCheck
		js	DrawFaceExit1	;facing away ->

		mov	al,FaceCol
		mov	si,OFFSET CrtBuffer
		call	PolyFill
 
DrawFaceExit1:	clc			;cf = 0 = ok
		ret

;-----------------------------------
;* draw textured face (16 sub-faces)
;-----------------------------------

;* preserve z eye values

Textured:	mov	si,OFFSET Ze[0]
		mov	di,OFFSET Ze[6]
		mov	cx,3
		rep	movsw

;* test if complete face is visible

	       	mov	si,4
		call	CalcOutCodes
		jc	DrawFaceExit1	;non-visible ->

		mov	si,OFFSET StndPoly3
		mov	di,OFFSET CrtBuffer
		call	PolyClip
		jc	DrawFaceExit1	;non-visible ->

		mov	si,OFFSET CrtBuffer
		call	CyclicCheck
		js	DrawFaceExit1	;facing away ->

;* restore z eye values

		mov	si,OFFSET Ze[6]
		mov	di,OFFSET Ze[0]
		mov	cx,3
		rep	movsw
	
;* sub-divide to calc intermediate eye co-ords

		SUBDIV	 6,  0,  2
		SUBDIV	 8,  2,  4
		SUBDIV	10,  4,  0
		SUBDIV	12,  0,  6
		SUBDIV	14,  6,  2
		SUBDIV	16,  2,  8
		SUBDIV	18,  8,  4
		SUBDIV	20,  4, 10
		SUBDIV	22, 10,  0
		SUBDIV	24, 10,  6
		SUBDIV	26,  6,  8
		SUBDIV	28,  8, 10

	       	mov	si,28
		call	CalcOutCodes
		jc	DrawFaceExit2	;non-visible ->

;* draw texture faces

		mov	cx,16		;16 sub-faces

		mov	si,OFFSET TextFaces

TextLoop:	push	cx		;store cntr
		mov	di,OFFSET CrtBuffer
		call	PolyClip
		lodsb			;fetch colour modifier
		jc	@F		;non-visible ->
		add	al,FaceCol	;modify colour
		push	si		;store ptr
		mov	si,OFFSET CrtBuffer
		call	PolyFill
		pop	si		;restore ptr
@@:		pop	cx		;restore cntr
		loop	TextLoop	;next sub-face ->

DrawFaceExit2:	clc			;cf = 0 = ok
		ret

DrawHillFace	ENDP

;----------------------------------------------------------------------------

;* CalcZAPos - calculate eye co-ords of spot height ZA
;*
;* pass: cx = scaling factor
;*       si -> OBJECTDATA record
;*       di = eye co-ord index
;*       bp = map index
;* ret : Xe[di], Ye[di], Ze[di]
;* kill: ax, bx, flags

CalcZAPos	PROC	NEAR

		mov	bl,HillLayer1[bp]
		and	bx,0000fh	;spot height 0 .. 15
		shl	bx,1		;*2 word index

		mov	ax,XSX[$MID-$8192]
		add	ax,XSY[$MID+$8192]
		add	ax,XSZ[bx]
		sar	ax,cl
		add	ax,OBJ_XSECPOS[si]
		mov	Xe[di],ax
		
		mov	ax,YSX[$MID-$8192]
		add	ax,YSY[$MID+$8192]
		add	ax,YSZ[bx]
		sar	ax,cl
		add	ax,OBJ_YSECPOS[si]
		mov	Ye[di],ax
	
		mov	ax,ZSX[$MID-$8192]
		add	ax,ZSY[$MID+$8192]
		add	ax,ZSZ[bx]
		sar	ax,cl
		add	ax,OBJ_ZSECPOS[si]
		mov	Ze[di],ax

		ret

CalcZAPos	ENDP
	
;----------------------------------------------------------------------------

;* CalcZBPos - calculate eye co-ords of spot height ZB
;*
;* pass: cx = scaling factor
;*       si -> OBJECTDATA record
;*       di = eye co-ord index
;*       bp = map index
;* ret : Xe[di], Ye[di], Ze[di]
;* kill: ax, bx, flags

CalcZBPos	PROC	NEAR

		mov	bl,HillLayer2[bp]
		and	bx,0000fh	;spot height 0 .. 15
		shl	bx,1		;*2 word index

		mov	ax,XSY[$MID+$8192]
		add	ax,XSZ[bx]
		sar	ax,cl
		add	ax,OBJ_XSECPOS[si]
		mov	Xe[di],ax
		
		mov	ax,YSY[$MID+$8192]
		add	ax,YSZ[bx]
		sar	ax,cl
		add	ax,OBJ_YSECPOS[si]
		mov	Ye[di],ax
	
		mov	ax,ZSY[$MID+$8192]
		add	ax,ZSZ[bx]
		sar	ax,cl
		add	ax,OBJ_ZSECPOS[si]
		mov	Ze[di],ax
	
		ret

CalcZBPos	ENDP
	
;----------------------------------------------------------------------------

;* CalcZCPos - calculate eye co-ords of spot height ZC
;*
;* pass: cx = scaling factor
;*       si -> OBJECTDATA record
;*       di = eye co-ord index
;*       bp = map index
;* ret : Xe[di], Ye[di], Ze[di]
;* kill: ax, bx, flags

CalcZCPos	PROC	NEAR

		mov	bl,HillLayer1[bp+1]
		and	bx,0000fh	;spot height 0 .. 15
		shl	bx,1		;*2 word index

		mov	ax,XSX[$MID+$8192]
		add	ax,XSY[$MID+$8192]
		add	ax,XSZ[bx]
		sar	ax,cl
		add	ax,OBJ_XSECPOS[si]
		mov	Xe[di],ax
		
		mov	ax,YSX[$MID+$8192]
		add	ax,YSY[$MID+$8192]
		add	ax,YSZ[bx]
		sar	ax,cl
		add	ax,OBJ_YSECPOS[si]
		mov	Ye[di],ax
	
		mov	ax,ZSX[$MID+$8192]
		add	ax,ZSY[$MID+$8192]
		add	ax,ZSZ[bx]
		sar	ax,cl
		add	ax,OBJ_ZSECPOS[si]
		mov	Ze[di],ax
	
		ret

CalcZCPos	ENDP

;----------------------------------------------------------------------------

;* CalcZDPos - calculate eye co-ords of spot height ZD
;*
;* pass: cx = scaling factor
;*       si -> OBJECTDATA record
;*       di = eye co-ord index
;*       bp = map index
;* ret : Xe[di], Ye[di], Ze[di]
;* kill: ax, bx, flags

CalcZDPos	PROC	NEAR

		mov	bl,HillLayer3[bp]
		and	bx,0000fh	;spot height 0 .. 15
		shl	bx,1		;*2 word index

		mov	ax,XSX[$MID-$8192]
		add	ax,XSZ[bx]
		sar	ax,cl
		add	ax,OBJ_XSECPOS[si]
		mov	Xe[di],ax
		
		mov	ax,YSX[$MID-$8192]
		add	ax,YSZ[bx]
		sar	ax,cl
		add	ax,OBJ_YSECPOS[si]
		mov	Ye[di],ax
	
		mov	ax,ZSX[$MID-$8192]
		add	ax,ZSZ[bx]
		sar	ax,cl
		add	ax,OBJ_ZSECPOS[si]
		mov	Ze[di],ax
	
		ret

CalcZDPos	ENDP

;----------------------------------------------------------------------------

;* CalcZEPos - calculate eye co-ords of spot height ZE
;*
;* pass: cx = scaling factor
;*       si -> OBJECTDATA record
;*       di = eye co-ord index
;*       bp = map index
;* ret : Xe[di], Ye[di], Ze[di]
;* kill: ax, bx, flags

CalcZEPos	PROC	NEAR

		mov	bl,HillLayer4[bp]
		and	bx,0000fh	;spot height 0 .. 15
		shl	bx,1		;*2 word index

		mov	ax,XSZ[bx]
		sar	ax,cl
		add	ax,OBJ_XSECPOS[si]
		mov	Xe[di],ax
		
		mov	ax,YSZ[bx]
		sar	ax,cl
		add	ax,OBJ_YSECPOS[si]
		mov	Ye[di],ax
	
		mov	ax,ZSZ[bx]
		sar	ax,cl
		add	ax,OBJ_ZSECPOS[si]
		mov	Ze[di],ax
	
		ret

CalcZEPos	ENDP

;----------------------------------------------------------------------------

;* CalcZFPos - calculate eye co-ords of spot height ZF
;*
;* pass: cx = scaling factor
;*       si -> OBJECTDATA record
;*       di = eye co-ord index
;*       bp = map index
;* ret : Xe[di], Ye[di], Ze[di]
;* kill: ax, bx, flags

CalcZFPos	PROC	NEAR

		mov	bl,HillLayer3[bp+1]
		and	bx,0000fh	;spot height 0 .. 15
		shl	bx,1		;*2 word index

		mov	ax,XSX[$MID+$8192]
		add	ax,XSZ[bx]
		sar	ax,cl
		add	ax,OBJ_XSECPOS[si]
		mov	Xe[di],ax
		
		mov	ax,YSX[$MID+$8192]
		add	ax,YSZ[bx]
		sar	ax,cl
		add	ax,OBJ_YSECPOS[si]
		mov	Ye[di],ax
	
		mov	ax,ZSX[$MID+$8192]
		add	ax,ZSZ[bx]
		sar	ax,cl
		add	ax,OBJ_ZSECPOS[si]
		mov	Ze[di],ax
	
		ret

CalcZFPos	ENDP

;----------------------------------------------------------------------------

;* CalcZGPos - calculate eye co-ords of spot height ZG
;*
;* pass: cx = scaling factor
;*       si -> OBJECTDATA record
;*       di = eye co-ord index
;*       bp = map index
;* ret : Xe[di], Ye[di], Ze[di]
;* kill: ax, bx, flags

CalcZGPos	PROC	NEAR

		mov	bl,HillLayer1[bp+32]
		and	bx,0000fh	;spot height 0 .. 15
		shl	bx,1		;*2 word index

		mov	ax,XSX[$MID-$8192]
		add	ax,XSY[$MID-$8192]
		add	ax,XSZ[bx]
		sar	ax,cl
		add	ax,OBJ_XSECPOS[si]
		mov	Xe[di],ax
		
		mov	ax,YSX[$MID-$8192]
		add	ax,YSY[$MID-$8192]
		add	ax,YSZ[bx]
		sar	ax,cl
		add	ax,OBJ_YSECPOS[si]
		mov	Ye[di],ax
	
		mov	ax,ZSX[$MID-$8192]
		add	ax,ZSY[$MID-$8192]
		add	ax,ZSZ[bx]
		sar	ax,cl
		add	ax,OBJ_ZSECPOS[si]
		mov	Ze[di],ax
	
		ret

CalcZGPos	ENDP

;----------------------------------------------------------------------------

;* CalcZHPos - calculate eye co-ords of spot height ZH
;*
;* pass: cx = scaling factor
;*       si -> OBJECTDATA record
;*       di = eye co-ord index
;*       bp = map index
;* ret : Xe[di], Ye[di], Ze[di]
;* kill: ax, bx, flags

CalcZHPos	PROC	NEAR

		mov	bl,HillLayer2[bp+32]
		and	bx,0000fh	;spot height 0 .. 15
		shl	bx,1		;*2 word index

		mov	ax,XSY[$MID-$8192]
		add	ax,XSZ[bx]
		sar	ax,cl
		add	ax,OBJ_XSECPOS[si]
		mov	Xe[di],ax
		
		mov	ax,YSY[$MID-$8192]
		add	ax,YSZ[bx]
		sar	ax,cl
		add	ax,OBJ_YSECPOS[si]
		mov	Ye[di],ax
	
		mov	ax,ZSY[$MID-$8192]
		add	ax,ZSZ[bx]
		sar	ax,cl
		add	ax,OBJ_ZSECPOS[si]
		mov	Ze[di],ax
	
		ret

CalcZHPos	ENDP

;----------------------------------------------------------------------------

;* CalcZIPos - calculate eye co-ords of spot height ZI
;*
;* pass: cx = scaling factor
;*       si -> OBJECTDATA record
;*       di = eye co-ord index
;*       bp = map index
;* ret : Xe[di], Ye[di], Ze[di]
;* kill: ax, bx, flags

CalcZIPos	PROC	NEAR

		mov	bl,HillLayer1[bp+33]
		and	bx,0000fh	;spot height 0 .. 15
		shl	bx,1		;*2 word index

		mov	ax,XSX[$MID+$8192]
		add	ax,XSY[$MID-$8192]
		add	ax,XSZ[bx]
		sar	ax,cl
		add	ax,OBJ_XSECPOS[si]
		mov	Xe[di],ax
		
		mov	ax,YSX[$MID+$8192]
		add	ax,YSY[$MID-$8192]
		add	ax,YSZ[bx]
		sar	ax,cl
		add	ax,OBJ_YSECPOS[si]
		mov	Ye[di],ax
	
		mov	ax,ZSX[$MID+$8192]
		add	ax,ZSY[$MID-$8192]
		add	ax,ZSZ[bx]
		sar	ax,cl
		add	ax,OBJ_ZSECPOS[si]
		mov	Ze[di],ax
	
		ret

CalcZIPos	ENDP

;----------------------------------------------------------------------------

;* CalcGndHeight - calc ground height
;*
;* pass: si -> VIEWPOINT data block
;* ret : ax = ground height
;* kill: assume all (except ax)

ExitGndHt1	LABEL	NEAR

		xor	ax,ax		;sea level
		retf			;<<<<< MUST BE FAR <<<<<

CalcGndHeight	PROC	FAR

;* calc map index (map index = x sec + y sec * 32)

		mov	bp,VP_XSEC[si]
		mov	dx,VP_YSEC[si]

		and	bp,MAP_X_WRAP
		and	dx,MAP_Y_WRAP

		REPT	5		;y sec * 32
		shl	dx,1
		ENDM

		add	bp,dx		;map index = x sec + y sec * 32

;* test for hills in sector

		mov	al,HillLayer9[bp]
		test	al,al		;hills in sector?
		jns	ExitGndHt1	;no, therefore sea level ->

;* sort quadrant index (quad index = sign(y) * 2 + sign(x))

		mov	ax,VP_YFT[si]
		mov	di,ax
		shl	ax,1		;extract sign(y)
		rcl	bx,1

		mov	ax,VP_XFT[si]
		mov	si,ax
		shl	ax,1		;extract sign(x)
		rcl	bx,1

		and	bx,0011b

		shl	bx,1		;*2 word index

		jmp	SortQuad[bx]

;* sort quad 1

SortQuad1:	mov	bl,HillLayer1[bp]	;Z1 = ZA (also quad crease flag)
		mov	bh,HillLayer2[bp]	;Z2 = ZB
		mov	cl,HillLayer3[bp]	;Z3 = ZD
		mov	ch,HillLayer4[bp]	;Z4 = ZE

		mov	ah,HillLayer5[bp]	;face colour data

		add	si,8192		;x = x + 8192
	
		jmp	QuadOk

;* sort quad 2

SortQuad2:	mov	bl,HillLayer2[bp]	;Z1 = ZB (also quad crease flag)
		mov	bh,HillLayer1[bp+1]	;Z2 = ZC
		mov	cl,HillLayer4[bp]	;Z3 = ZE
		mov	ch,HillLayer3[bp+1]	;Z4 = ZF

		mov	ah,HillLayer6[bp]	;face colour data

		jmp	QuadOk

;* sort quad 3

SortQuad3:	mov	bl,HillLayer3[bp]	;Z1 = ZD (also quad crease flag)
		mov	bh,HillLayer4[bp]	;Z2 = ZE
		mov	cl,HillLayer1[bp+32]	;Z3 = ZG
		mov	ch,HillLayer2[bp+32]	;Z4 = ZH

		mov	ah,HillLayer7[bp]	;face colour data

		add	si,8192		;x = x + 8192
		add	di,8192		;y = y + 8192
	
		jmp	QuadOk

;* sort quad 4

SortQuad4:	mov	bl,HillLayer4[bp]	;Z1 = ZE (also quad crease flag)
		mov	bh,HillLayer3[bp+1]	;Z2 = ZF
		mov	cl,HillLayer2[bp+32]	;Z3 = ZH
		mov	ch,HillLayer1[bp+33]	;Z4 = ZI

		mov	ah,HillLayer8[bp]	;face colour data

		add	di,8192		;y = y + 8192

;* if reverse Z crease then convert to Z crease	

QuadOk:		test	bl,080h		;Z crease?
		jz	@F		;yes ->

		xchg	bl,bh		;swap Z1, Z2
		xchg	cl,ch		;swap Z3, Z4

		REPT	4		;swap face colours
		rol	ah,1
		ENDM

		mov	bp,8192
		sub	bp,si		;8192 - x
		mov	si,bp		;x = 8192 - x

;* sort which face (x >= y) or (y > x)

@@:		mov	al,0f0h		;assume (x >= y)

		cmp	si,di		;x >= y?
		jae	@F		;yes ->

		xchg	bl,ch		;swap Z1, Z4
		xchg	si,di		;swap x, y

		mov	al,00fh

@@:		test	ah,al		;face exists?
		jz	ExitGndHt2	;no, therefore sea level ->
		
		and	bx,00f0fh	;clear crease flags
		and	cx,00f0fh	;clear crease flags

		test	si,si		;x = 0? (prevent div 0 error)
		jz	ExitGndHt3	;yes ->

;* calc ground height (Zt):-
;*
;*    Zi = (y / x) * (Z2 - Z4) + Z4
;*    Zt = (x / 8192) * (Zi - Z3) + Z3

		mov	ah,bh
		sub	ah,ch		;Z2 - Z4 (*256)
		xor	al,al

		imul	di		;y * (Z2 - Z4)
		idiv	si		;(y / x) * (Z2 - Z4)

		add	ah,ch		;Zi = (y / x) * (Z2 - Z4) + Z4

		sub	ah,cl		;Zi - Z3 (*256)

		imul	si		;x * (Zi - Z3)

		REPT	3		;(x / 8192) * (Zi - Z3) = x * (Zi - Z3) * 8 / 65536
		shl	ax,1
		rcl	dx,1
		ENDM

		add	dh,cl		;Zt = (x / 8192) * (Zi - Z3) + Z3

		mov	ax,dx

		ret

ExitGndHt2:	xor	ax,ax		;sea level
		ret

ExitGndHt3:	mov	ah,cl		;height = Z3 (*256)
		xor	al,al
		ret

CalcGndHeight	ENDP

;----------------------------------------------------------------------------

;* QCalcGndHeight - quick calc ground height (nearest spot height)
;*
;* pass: si -> VIEWPOINT data block
;* ret : ax = ground height
;* kill: assume all (except ax)

QCalcGndHeight	PROC	FAR

;* calc map index (map index = x sec + y sec * 32)

		mov	bp,VP_XSEC[si]
		mov	dx,VP_YSEC[si]

		and	bp,MAP_X_WRAP
		and	dx,MAP_Y_WRAP

		REPT	5		;y sec * 32
		shl	dx,1
		ENDM

		add	bp,dx		;map index = x sec + y sec * 32

;* test for hills in sector

		mov	al,HillLayer9[bp]
		test	al,al		;hills in sector?
		jns	ExitQGndHt1	;no, therefore sea level ->

;* index = ((xft + 8192) and 03000h) >> 9 or ((yft + 8192) and 03000h) >> 11

		mov	ax,VP_XFT[si]
		add	ax,8192
		and	ax,03000h
		xchg	al,ah		;>> 8
		shr	ax,1		;>> 9

		mov	bx,VP_YFT[si]
		add	bx,8192
		and	bx,03000h
		xchg	bl,bh		;>> 8
		REPT	3		;>> 11
		shr	bx,1
		ENDM

		or	bx,ax

		jmp	SortQSpotHt[bx]

;---------------------------
QSpotHtA   	LABEL	NEAR
;---------------------------

		mov	ah,HillLayer1[bp]
		and	ax,00f00h
		ret

;---------------------------
QSpotHtB   	LABEL	NEAR
;---------------------------

		mov	ah,HillLayer2[bp]
		and	ax,00f00h
		ret

;---------------------------
QSpotHtC   	LABEL	NEAR
;---------------------------

		mov	ah,HillLayer1[bp+1]
		and	ax,00f00h
		ret

;---------------------------
QSpotHtD   	LABEL	NEAR
;---------------------------

		mov	ah,HillLayer3[bp]
		and	ax,00f00h
		ret

;---------------------------
QSpotHtE   	LABEL	NEAR
;---------------------------

		mov	ah,HillLayer4[bp]
		and	ax,00f00h
		ret

;---------------------------
QSpotHtF   	LABEL	NEAR
;---------------------------

		mov	ah,HillLayer3[bp+1]
		and	ax,00f00h
		ret

;---------------------------
QSpotHtG   	LABEL	NEAR
;---------------------------

		mov	ah,HillLayer1[bp+32]
		and	ax,00f00h
		ret

;---------------------------
QSpotHtH   	LABEL	NEAR
;---------------------------

		mov	ah,HillLayer2[bp+32]
		and	ax,00f00h
		ret

;---------------------------
QSpotHtI   	LABEL	NEAR
;---------------------------

		mov	ah,HillLayer1[bp+33]
		and	ax,00f00h
		ret

;---------------------------
ExitQGndHt1	LABEL	NEAR
;---------------------------

		xor	ax,ax		;sea level
		ret

QCalcGndHeight	ENDP

VISCODE		ENDS

;============================================================================

		END

