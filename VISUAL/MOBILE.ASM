;****************************************************************************
;*
;* MOBILE.ASM
;*
;* Draw mobile objects.
;*
;* 22.03.1991 - KJB
;*
;* Format of mobile object data:-
;*
;* TestObj1	OBJECTHEADER <scale mode, max range, ptr, flags, colour, x size, y size, z size>
;*
;* 		DB	x1, y1, z1	;vertex list
;*		DB	x2, y2, z2
;*		DB	x3, y3, z3
;*		DB	x4, y4, z4
;*		DB	x5, y5, z5
;*		..      ..  ..  ..
;*		DB	xn, yn, zn
;*		DB	-1		;list terminator
;*
;*		DW	OFFSET FaceList	;face list always starts at even address
;*
;*		EVEN			;even data is faster!!!
;*
;* FastList	DB	face list   	;refer to SCANFACE.ASM
;*
;* Notes:-
;*
;* "scale mode" - indicates the scale of the object (*1, *2, *4, etc.).
;*
;*    ie. OBJ_SCALE1
;*
;* "max range"  - defines the maximum range at which the object is visible.
;*                This values should not exceed the maximum range wrt scale
;*                mode.
;*
;*    ie. OBJ_SCALE16 range < MAX_RANGE16
;*
;* "ptr"        -  points to the object definition of the next approximation
;*                 of the object. (-1 terminates the list).
;*
;* "flags"      - miscellaneous flags (see VISDATA.INC).
;*
;* "colour"	- colour of pixel approximation.
;*
;* "x size"     - ) mobile objects may not need to create the entire rotated
;* "y size"	- ) object grid - these values indicate the size of each grid
;* "z size"	- ) (0 .. 32). (ie. 10 = create 10 points either side of 0).
;*
;* The vertex x, y and z co-ords represent object grid offsets (-32 .. +32).
;*
;* The actual values of x, y and z co-rds are indices into the object grid
;* arrays (ie. XGX[], XGY[], XGZ[] etc.).
;* 
;*    ie. x =   0 )
;*        y =   0 ) bottom front left hand corner of object grid
;*        z =   0 )
;*
;*        x = 128 )
;*        y = 128 ) top rear right hand corner of object grid
;*        z = 128 )
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	DrawMobObject1
		PUBLIC	DrawMobObject2
		PUBLIC	DrawMobObject3
		PUBLIC	CalcMobMaxDim

		EXTRN	SetPixel:FAR

		EXTRN	DotClip:NEAR
		EXTRN	CalcBFactors:NEAR
		EXTRN	CalcCFactors:NEAR
		EXTRN	CalcDFactors:NEAR
		EXTRN	CalcRotateGrid1:NEAR
		EXTRN	CalcRotateGrid2:NEAR
		EXTRN	CalcRotateGrid3:NEAR
		EXTRN	CalcOutCodes:NEAR
		EXTRN	ScanFace:NEAR

		EXTRN	MobileTable:WORD
		EXTRN	DrawRecover:WORD
		
;============================================================================

		INCLUDE	VISEXTRN.INC
		INCLUDE	VISDATA.INC
		INCLUDE	\LIB8086\USEFUL.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

;* calc object position wrt scale mode

CalcObjectPos	DW      0		;OBJ_SCALE1
		DW	1		;OBJ_SCALE2
		DW	2		;OBJ_SCALE4
		DW	3		;OBJ_SCALE8
		DW	4		;OBJ_SCALE16

;* orientation of rotated object grid

RGridHdg	DW	0
RGridPitch	DW	0
RGridRoll	DW	0

DATA		ENDS

;============================================================================

MOBOBJ1		SEGMENT PARA PUBLIC 'DATA'

MOBOBJ1		ENDS

;============================================================================

VISCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:VISCODE
		ASSUME DS:DATA

;* DrawMobObject1 - draw mobile object (with skew only)
;*
;* pass: si -> OBJECTDATA record
;* ret : cf = 0 = ok
;*       cf = 1 = error
;* kill: assume all

DrawMobObject1	PROC	NEAR

		mov	DrawRecover,sp	;recover stack to here if error

;----------------------------------
;* calc max(abs(x), abs(y), abs(z))
;----------------------------------

		mov	ax,OBJ_ZPOS[si]
		ABSV	ax
		mov	cx,ax		;cx = abs(z)
	
		mov	ax,OBJ_YPOS[si]
		ABSV	ax
		mov	bx,ax		;bx = abs(y)

		mov	ax,OBJ_XPOS[si]
		ABSV	ax		;ax = abs(x)

		cmp	ax,bx		;abs(x) >= abs(y)?
		jae	SkipSort1_1	;yes ->
		mov	ax,bx

SkipSort1_1:	cmp	ax,cx		;max(abs(x), abs(y)) >= abs(z)?
		jae	SkipSort2_1	;yes ->
		mov	ax,cx

SkipSort2_1:	mov	dx,ax		;dx = max(abs(x), abs(y), abs(z))

;-------------------------------------
;* fetch pointer to mobile object data
;-------------------------------------

		mov	bl,OBJ_NUM[si]
		xor	bh,bh
		shl	bx,1		;*2 index

		mov	ax,MobileTable[bx]

;-------------------------------------------------------------------------
;* test if object is in range, if not, move to next approximation (if any)
;-------------------------------------------------------------------------

		mov	bp,MOBOBJ1
		mov	ds,bp

ApproxLoop1:	mov	bx,ax		;bx -> object data

		cmp	dx,OBJ_HDR_RANGE[bx]
		jb	SortPosition1	;in range ->

		mov	ax,OBJ_HDR_PTR[bx]
		cmp	ax,-1		;any more approximations?
		jne	ApproxLoop1	;yes ->

;------------------------------------------
;* approximate object to pixel (if enabled)
;------------------------------------------

		mov	ah,OBJ_HDR_FLAGS[bx]
		mov	al,OBJ_HDR_COL[bx]
		
		mov	bp,DATA
		mov	ds,bp

		test	ah,OBJ_FLG_PIXEL
		jz	ExitLink1	;pixel approximation disabled ->

		push	ax		;store colour

		mov	ax,OBJ_XPOS[si]	;fetch object position
		mov	Xe[0],ax
		mov	ax,OBJ_YPOS[si]
		mov	Ye[0],ax
		mov	ax,OBJ_ZPOS[si]
		mov	Ze[0],ax

		call	DotClip
		pop	ax		;restore colour
		jc	ExitLink1	;non-visible ->
		
		call	SetPixel

ExitLink1:	jmp	ExitMobObject1

;-------------------------------------	
;* sort object position wrt scale mode
;-------------------------------------
		
SortPosition1:	mov	di,OBJ_HDR_SCALE[bx]

		mov	cx,OBJ_HDR_XGRID[bx]
		mov	dx,OBJ_HDR_YGRID[bx]

		mov	ax,DATA
		mov	ds,ax

		mov	di,CalcObjectPos[di]
		xchg	cx,di

		mov	ax,OBJ_XPOS[si]
		shl	ax,cl
		mov	XPos,ax

		mov	ax,OBJ_YPOS[si]
		shl	ax,cl
		mov	YPos,ax

		mov	ax,OBJ_ZPOS[si]
		shl	ax,cl
		mov	ZPos,ax

;----------------------
;* sort animation flags
;----------------------

		mov	al,OBJ_ANIM_FLAGS[si]
		mov	ObjAnimFlags,al
		
;-----------------------------------
;* rotate object grid (if necessary)
;-----------------------------------

		push	bx		;store object data ptr

;* check if heading, pitch and roll match previously rotated grid

		mov	ax,OBJ_HDG[si]
		cmp	ax,RGridHdg
		jne	ContRotate1

		mov	ax,OBJ_PITCH[si]
		cmp	ax,RGridPitch
		jne	ContRotate1

		mov	ax,OBJ_ROLL[si]
		cmp	ax,RGridRoll
		jne	ContRotate1

;* check if previously rotated grid is large enough to use

		cmp	di,XGridSize	;x grid size ok?
		ja	ContRotate1	;no ->

		cmp	dx,YGridSize	;y grid size ok?
		jbe	SkipRotate1	;yes ->

ContRotate1:	mov	XGridSize,di
		mov	YGridSize,dx

		mov	ax,OBJ_ROLL[si]
		mov	RGridRoll,ax

		mov	ax,OBJ_PITCH[si]
		mov	RGridPitch,ax

		mov	ax,OBJ_HDG[si]
		mov	RGridHdg,ax

		call	CalcBFactors	;skew

		call	CalcRotateGrid1	

SkipRotate1:	pop	si		;restore object data ptr

		add	si,OBJ_HDR_SIZE	;skip header data

;------------------------------------------------
;* scan vertex list and calculate eye co-ord data
;------------------------------------------------

		mov	ax,MOBOBJ1
		mov	es,ax

		call	ScanVertexList1

		mov	ax,DATA
		mov	es,ax

;---------------------------
;* test if object is visible
;---------------------------

		push	si
		mov	si,di
		call	CalcOutCodes
		pop	si
		jc	ExitMobObject1	;object non-visible ->

;-----------------------------------------------------
;* copy face data from MOBOBJ1 segment to DATA segment
;-----------------------------------------------------

		mov	ax,MOBOBJ1
		mov	ds,ax

		mov	si,[si]		;point to face data

		lodsw			;fetch counter
		mov	cx,ax
		
		mov	di,OFFSET CopyBuffer

		FAST_MOVE

		mov	ax,DATA
		mov	ds,ax

;---------------------
;* scan and draw faces
;---------------------

;* reset crt buffer ptr

		mov	ax,OFFSET CrtBuffer
		mov	CrtBufPtr,ax

		mov	si,OFFSET CopyBuffer

		call	ScanFace

ExitMobObject1:	clc			;cf = 0 = ok
		ret    	

DrawMobObject1	ENDP

;----------------------------------------------------------------------------

;* DrawMobObject2 - draw mobile object (with skew and pitch)
;*
;* pass: si -> OBJECTDATA record
;* ret : cf = 0 = ok
;*       cf = 1 = error
;* kill: assume all

DrawMobObject2	PROC	NEAR

		mov	DrawRecover,sp	;recover stack to here if error

;----------------------------------
;* calc max(abs(x), abs(y), abs(z))
;----------------------------------

		mov	ax,OBJ_ZPOS[si]
		ABSV	ax
		mov	cx,ax		;cx = abs(z)
	
		mov	ax,OBJ_YPOS[si]
		ABSV	ax
		mov	bx,ax		;bx = abs(y)

		mov	ax,OBJ_XPOS[si]
		ABSV	ax		;ax = abs(x)

		cmp	ax,bx		;abs(x) >= abs(y)?
		jae	SkipSort1_2	;yes ->
		mov	ax,bx

SkipSort1_2:	cmp	ax,cx		;max(abs(x), abs(y)) >= abs(z)?
		jae	SkipSort2_2	;yes ->
		mov	ax,cx

SkipSort2_2:	mov	dx,ax		;dx = max(abs(x), abs(y), abs(z))

;-------------------------------------
;* fetch pointer to mobile object data
;-------------------------------------

		mov	bl,OBJ_NUM[si]
		xor	bh,bh
		shl	bx,1		;*2 index

		mov	ax,MobileTable[bx]

;-------------------------------------------------------------------------
;* test if object is in range, if not, move to next approximation (if any)
;-------------------------------------------------------------------------

		mov	bp,MOBOBJ1
		mov	ds,bp

ApproxLoop2:	mov	bx,ax		;bx -> object data

		cmp	dx,OBJ_HDR_RANGE[bx]
		jb	SortPosition2	;in range ->

		mov	ax,OBJ_HDR_PTR[bx]
		cmp	ax,-1		;any more approximations?
		jne	ApproxLoop2	;yes ->

;------------------------------------------
;* approximate object to pixel (if enabled)
;------------------------------------------

		mov	ah,OBJ_HDR_FLAGS[bx]
		mov	al,OBJ_HDR_COL[bx]
		
		mov	bp,DATA
		mov	ds,bp

		test	ah,OBJ_FLG_PIXEL
		jz	ExitLink2	;pixel approximation disabled ->

		push	ax		;store colour

		mov	ax,OBJ_XPOS[si]	;fetch object position
		mov	Xe[0],ax
		mov	ax,OBJ_YPOS[si]
		mov	Ye[0],ax
		mov	ax,OBJ_ZPOS[si]
		mov	Ze[0],ax

		call	DotClip
		pop	ax		;restore colour
		jc	ExitLink2	;non-visible ->
		
		call	SetPixel

ExitLink2:	jmp	ExitMobObject2

;-------------------------------------	
;* sort object position wrt scale mode
;-------------------------------------
		
SortPosition2:	mov	di,OBJ_HDR_SCALE[bx]

		mov	cx,OBJ_HDR_XGRID[bx]
		mov	dx,OBJ_HDR_YGRID[bx]
		mov	bp,OBJ_HDR_ZGRID[bx]

		mov	ax,DATA
		mov	ds,ax

		mov	di,CalcObjectPos[di]
		xchg	cx,di

		mov	ax,OBJ_XPOS[si]
		shl	ax,cl
		mov	XPos,ax

		mov	ax,OBJ_YPOS[si]
		shl	ax,cl
		mov	YPos,ax

		mov	ax,OBJ_ZPOS[si]
		shl	ax,cl
		mov	ZPos,ax

;----------------------
;* sort animation flags
;----------------------

		mov	al,OBJ_ANIM_FLAGS[si]
		mov	ObjAnimFlags,al
	
;-----------------------------------
;* rotate object grid (if necessary)
;-----------------------------------

		push	bx		;store object data ptr

;* check if heading, pitch and roll match previously rotated grid

		mov	ax,OBJ_HDG[si]
		cmp	ax,RGridHdg
		jne	ContRotate2

		mov	ax,OBJ_PITCH[si]
		cmp	ax,RGridPitch
		jne	ContRotate2

		mov	ax,OBJ_ROLL[si]
		cmp	ax,RGridRoll
		jne	ContRotate2

;* check if previously rotated grid is large enough to use

		cmp	di,XGridSize	;x grid size ok?
		ja	ContRotate2	;no ->

		cmp	dx,YGridSize	;y grid size ok?
		ja	ContRotate2	;no ->

		cmp	bp,ZGridSize	;z grid size ok?
		jbe	SkipRotate2	;yes ->

ContRotate2:	mov	XGridSize,di
		mov	YGridSize,dx
		mov	ZGridSize,bp

		mov	ax,OBJ_ROLL[si]
		mov	RGridRoll,ax

		mov	ax,OBJ_PITCH[si]
		mov	RGridPitch,ax

		mov	ax,OBJ_HDG[si]
		mov	RGridHdg,ax

		push	si
		call	CalcBFactors	;skew
		pop	si

		mov	ax,OBJ_PITCH[si]

		call	CalcCFactors	;pitch

		call	CalcRotateGrid2	

SkipRotate2:	pop	si		;restore object data ptr

		add	si,OBJ_HDR_SIZE	;skip header data

;------------------------------------------------
;* scan vertex list and calculate eye co-ord data
;------------------------------------------------

		mov	ax,MOBOBJ1
		mov	es,ax

		call	ScanVertexList2

		mov	ax,DATA
		mov	es,ax

;---------------------------
;* test if object is visible
;---------------------------

		push	si
		mov	si,di
		call	CalcOutCodes
		pop	si
		jc	ExitMobObject2	;object non-visible ->

;-----------------------------------------------------
;* copy face data from MOBOBJ1 segment to DATA segment
;-----------------------------------------------------

		mov	ax,MOBOBJ1
		mov	ds,ax

		mov	si,[si]		;point to face data

		lodsw			;fetch counter
		mov	cx,ax
		
		mov	di,OFFSET CopyBuffer

		FAST_MOVE

		mov	ax,DATA
		mov	ds,ax

;---------------------
;* scan and draw faces
;---------------------

;* reset crt buffer ptr

		mov	ax,OFFSET CrtBuffer
		mov	CrtBufPtr,ax

		mov	si,OFFSET CopyBuffer

		call	ScanFace

ExitMobObject2:	clc			;cf = 0 = ok
		ret    	

DrawMobObject2	ENDP

;----------------------------------------------------------------------------

;* DrawMobObject3 - draw mobile object (with skew, pitch and roll)
;*
;* pass: si -> OBJECTDATA record
;* ret : cf = 0 = ok
;*       cf = 1 = error
;* kill: assume all

DrawMobObject3	PROC	NEAR

		mov	DrawRecover,sp	;recover stack to here if error

;----------------------------------
;* calc max(abs(x), abs(y), abs(z))
;----------------------------------

		mov	ax,OBJ_ZPOS[si]
		ABSV	ax
		mov	cx,ax		;cx = abs(z)
	
		mov	ax,OBJ_YPOS[si]
		ABSV	ax
		mov	bx,ax		;bx = abs(y)

		mov	ax,OBJ_XPOS[si]
		ABSV	ax		;ax = abs(x)

		cmp	ax,bx		;abs(x) >= abs(y)?
		jae	SkipSort1_3	;yes ->
		mov	ax,bx

SkipSort1_3:	cmp	ax,cx		;max(abs(x), abs(y)) >= abs(z)?
		jae	SkipSort2_3	;yes ->
		mov	ax,cx

SkipSort2_3:	mov	dx,ax		;dx = max(abs(x), abs(y), abs(z))

;-------------------------------------
;* fetch pointer to mobile object data
;-------------------------------------

		mov	bl,OBJ_NUM[si]
		xor	bh,bh
		shl	bx,1		;*2 index

		mov	ax,MobileTable[bx]

;-------------------------------------------------------------------------
;* test if object is in range, if not, move to next approximation (if any)
;-------------------------------------------------------------------------

		mov	bp,MOBOBJ1
		mov	ds,bp

ApproxLoop3:	mov	bx,ax		;bx -> object data

		cmp	dx,OBJ_HDR_RANGE[bx]
		jb	SortPosition3	;in range ->

		mov	ax,OBJ_HDR_PTR[bx]
		cmp	ax,-1		;any more approximations?
		jne	ApproxLoop3	;yes ->

;------------------------------------------
;* approximate object to pixel (if enabled)
;------------------------------------------

		mov	ah,OBJ_HDR_FLAGS[bx]
		mov	al,OBJ_HDR_COL[bx]
		
		mov	bp,DATA
		mov	ds,bp

		test	ah,OBJ_FLG_PIXEL
		jz	ExitLink3	;pixel approximation disabled ->

		push	ax		;store colour

		mov	ax,OBJ_XPOS[si]	;fetch object position
		mov	Xe[0],ax
		mov	ax,OBJ_YPOS[si]
		mov	Ye[0],ax
		mov	ax,OBJ_ZPOS[si]
		mov	Ze[0],ax

		call	DotClip
		pop	ax		;restore colour
		jc	ExitLink3	;non-visible ->
		
		call	SetPixel

ExitLink3:	jmp	ExitMobObject3

;-------------------------------------	
;* sort object position wrt scale mode
;-------------------------------------
		
SortPosition3:	mov	di,OBJ_HDR_SCALE[bx]

		mov	cx,OBJ_HDR_XGRID[bx]
		mov	dx,OBJ_HDR_YGRID[bx]
		mov	bp,OBJ_HDR_ZGRID[bx]

		mov	ax,DATA
		mov	ds,ax

		mov	di,CalcObjectPos[di]
		xchg	cx,di

		mov	ax,OBJ_XPOS[si]
		shl	ax,cl
		mov	XPos,ax

		mov	ax,OBJ_YPOS[si]
		shl	ax,cl
		mov	YPos,ax

		mov	ax,OBJ_ZPOS[si]
		shl	ax,cl
		mov	ZPos,ax

;----------------------
;* sort animation flags
;----------------------

		mov	al,OBJ_ANIM_FLAGS[si]
		mov	ObjAnimFlags,al
	
;-----------------------------------
;* rotate object grid (if necessary)
;-----------------------------------

		push	bx		;store object data ptr

;* check if heading, pitch and roll match previously rotated grid

		mov	ax,OBJ_HDG[si]
		cmp	ax,RGridHdg
		jne	ContRotate3

		mov	ax,OBJ_PITCH[si]
		cmp	ax,RGridPitch
		jne	ContRotate3

		mov	ax,OBJ_ROLL[si]
		cmp	ax,RGridRoll
		jne	ContRotate3

;* check if previously rotated grid is large enough to use

		cmp	di,XGridSize	;x grid size ok?
		ja	ContRotate3	;no ->

		cmp	dx,YGridSize	;y grid size ok?
		ja	ContRotate3	;no ->

		cmp	bp,ZGridSize	;z grid size ok?
		jbe	SkipRotate3	;yes ->

ContRotate3:	mov	XGridSize,di
		mov	YGridSize,dx
		mov	ZGridSize,bp

		mov	ax,OBJ_ROLL[si]
		mov	RGridRoll,ax

		mov	ax,OBJ_PITCH[si]
		mov	RGridPitch,ax

		mov	ax,OBJ_HDG[si]
		mov	RGridHdg,ax

		push	si
		call	CalcBFactors	;skew
		pop	si

		mov	ax,OBJ_PITCH[si]

		push	si
		call	CalcCFactors	;pitch
		pop	si

		mov	ax,OBJ_ROLL[si]

		call	CalcDFactors	;roll

		call	CalcRotateGrid3	

SkipRotate3:	pop	si		;restore object data ptr

		add	si,OBJ_HDR_SIZE	;skip header data

;------------------------------------------------
;* scan vertex list and calculate eye co-ord data
;------------------------------------------------

		mov	ax,MOBOBJ1
		mov	es,ax

		call	ScanVertexList3

		mov	ax,DATA
		mov	es,ax

;---------------------------
;* test if object is visible
;---------------------------

		push	si
		mov	si,di
		call	CalcOutCodes
		pop	si
		jc	ExitMobObject3	;object non-visible ->

;-----------------------------------------------------
;* copy face data from MOBOBJ1 segment to DATA segment
;-----------------------------------------------------

		mov	ax,MOBOBJ1
		mov	ds,ax

		mov	si,[si]		;point to face data

		lodsw			;fetch counter
		mov	cx,ax
		
		mov	di,OFFSET CopyBuffer

		FAST_MOVE

		mov	ax,DATA
		mov	ds,ax

;---------------------
;* scan and draw faces
;---------------------

;* reset crt buffer ptr

		mov	ax,OFFSET CrtBuffer
		mov	CrtBufPtr,ax

		mov	si,OFFSET CopyBuffer

		call	ScanFace

ExitMobObject3:	clc			;cf = 0 = ok
		ret    	

DrawMobObject3	ENDP

;----------------------------------------------------------------------------

;* ScanVertexList1 - scan vertex list and calc eye co-ords
;*                   (skew only objects)
;*
;* pass: es:si -> vertex list
;*       XPos, YPos, ZPos
;* ret : es:si -> end of vertex list + 1
;*       di = indexes last vertex value in eye co-ord arrays
;*       Xe[], Ye[], Ze[]
;* kill: ax, bx, cx, dx, bp, flags

ScanVertexList1	PROC	NEAR

		xor	di,di		;reset eye co-ord index

		xor	bx,bx		;reset index (high byte always 0)

ScanVertexLoop1:ES_LODSB		;fetch x index
		cmp	al,-1		;end of vertex list?
		je	ExitScanVertex1	;yes ->
		
		mov	bl,al
		mov	cx,R_XGX[bx]	;R_XGX
		mov	dx,R_YGX[bx]	;R_YGX
		mov	bp,R_ZGX[bx]	;R_ZGX

		ES_LODSB		;fetch y index
		mov	bl,al
		add	cx,R_XGY[bx]	;R_XGX + R_XGY
		add	dx,R_YGY[bx]	;R_YGX + R_YGY
		add	bp,R_ZGY[bx]	;R_ZGX + R_ZGY

		ES_LODSB		;fetch z index
		mov	bl,al
		add	cx,XGZ[bx]	;R_XGX + R_XGY + XGZ
		add	dx,YGZ[bx]	;R_YGX + R_YGY + YGZ
		add	bp,ZGZ[bx]	;R_ZGX + R_ZGY + ZGZ

		add	cx,XPos		;XPos + R_XGX + R_XGY + XGZ
		mov	Xe[di],cx

		add	dx,YPos		;YPos + R_YGX + R_YGY + YGZ
		mov	Ye[di],dx

		add	bp,ZPos		;ZPos + R_ZGX + R_ZGY + ZGZ
		mov	Ze[di],bp

		add	di,2		;next index

		jmp	ScanVertexLoop1

ExitScanVertex1:sub	di,2		;di indexes last vertex
		ret

ScanVertexList1	ENDP

;----------------------------------------------------------------------------

;* ScanVertexList2 - scan vertex list and calc eye co-ords
;*                   (skew and pitch objects)
;*
;* pass: es:si -> vertex list
;*       XPos, YPos, ZPos
;* ret : es:si -> end of vertex list + 1
;*       di = indexes last vertex value in eye co-ord arrays
;*       Xe[], Ye[], Ze[]
;* kill: ax, bx, cx, dx, bp, flags

ScanVertexList2	PROC	NEAR

		xor	di,di		;reset eye co-ord index

		xor	bx,bx		;reset index (high byte always 0)

ScanVertexLoop2:ES_LODSB		;fetch x index
		cmp	al,-1		;end of vertex list?
		je	ExitScanVertex2	;yes ->
		
		mov	bl,al
		mov	cx,R_XGX[bx]	;R_XGX
		mov	dx,R_YGX[bx]	;R_YGX
		mov	bp,R_ZGX[bx]	;R_ZGX

		ES_LODSB		;fetch y index
		mov	bl,al
		add	cx,R_XGY[bx]	;R_XGX + R_XGY
		add	dx,R_YGY[bx]	;R_YGX + R_YGY
		add	bp,R_ZGY[bx]	;R_ZGX + R_ZGY

		ES_LODSB		;fetch z index
		mov	bl,al
		add	cx,R_XGZ[bx]	;R_XGX + R_XGY + R_XGZ
		add	dx,R_YGZ[bx]	;R_YGX + R_YGY + R_YGZ
		add	bp,R_ZGZ[bx]	;R_ZGX + R_ZGY + R_ZGZ

		add	cx,XPos		;XPos + R_XGX + R_XGY + R_XGZ
		mov	Xe[di],cx

		add	dx,YPos		;YPos + R_YGX + R_YGY + R_YGZ
		mov	Ye[di],dx

		add	bp,ZPos		;ZPos + R_ZGX + R_ZGY + R_ZGZ
		mov	Ze[di],bp

		add	di,2		;next index

		jmp	ScanVertexLoop2

ExitScanVertex2:sub	di,2		;di indexes last vertex
		ret

ScanVertexList2	ENDP

;----------------------------------------------------------------------------

;* ScanVertexList3 - scan vertex list and calc eye co-ords
;*                   (skew, pitch and roll objects)
;*
;* pass: es:si -> vertex list
;*       XPos, YPos, ZPos
;* ret : es:si -> end of vertex list + 1
;*       di = indexes last vertex value in eye co-ord arrays
;*       Xe[], Ye[], Ze[]
;* kill: ax, bx, cx, dx, bp, flags

ScanVertexList3	PROC	NEAR

		xor	di,di		;reset eye co-ord index

		xor	bx,bx		;reset index (high byte always 0)

ScanVertexLoop3:ES_LODSB		;fetch x index
		cmp	al,-1		;end of vertex list?
		je	ExitScanVertex3	;yes ->
		
		mov	bl,al
		mov	cx,R_XGX[bx]	;R_XGX
		mov	dx,R_YGX[bx]	;R_YGX
		mov	bp,R_ZGX[bx]	;R_ZGX

		ES_LODSB		;fetch y index
		mov	bl,al
		add	cx,R_XGY[bx]	;R_XGX + R_XGY
		add	dx,R_YGY[bx]	;R_YGX + R_YGY
		add	bp,R_ZGY[bx]	;R_ZGX + R_ZGY

		ES_LODSB		;fetch z index
		mov	bl,al
		add	cx,R_XGZ[bx]	;R_XGX + R_XGY + R_XGZ
		add	dx,R_YGZ[bx]	;R_YGX + R_YGY + R_YGZ
		add	bp,R_ZGZ[bx]	;R_ZGX + R_ZGY + R_ZGZ

		add	cx,XPos		;XPos + R_XGX + R_XGY + R_XGZ
		mov	Xe[di],cx

		add	dx,YPos		;YPos + R_YGX + R_YGY + R_YGZ
		mov	Ye[di],dx

		add	bp,ZPos		;ZPos + R_ZGX + R_ZGY + R_ZGZ
		mov	Ze[di],bp

		add	di,2		;next index

		jmp	ScanVertexLoop3

ExitScanVertex3:sub	di,2		;di indexes last vertex
		ret

ScanVertexList3	ENDP

;----------------------------------------------------------------------------

;* CalcMobMaxDim - calc max dimension of mobile
;*
;* pass: al = object number
;* ret : ax = max object dimension (ft)
;* kill: assume all

CalcMobMaxDim	PROC	FAR

;* sort ptr to object header

		mov	bl,al
		xor	bh,bh
		shl	bx,1	;*2 word index

		mov	bx,MobileTable[bx]

		mov	dx,MOBOBJ1
		mov	ds,dx

;* max dimension = max(xgrid, ygrid, zgrid) * scale

		mov	ax,OBJ_HDR_XGRID[bx]
		cmp	ax,OBJ_HDR_YGRID[bx]
		jae	@F
		mov	ax,OBJ_HDR_YGRID[bx]

@@:		cmp	ax,OBJ_HDR_ZGRID[bx]
		jae	@F
		mov	ax,OBJ_HDR_ZGRID[bx]

@@:		mov	bx,OBJ_HDR_SCALE[bx]

		mov	dx,DATA
		mov	ds,dx

		shr	bx,1		;/2 byte index

		mov	cl,ObjScaleConvert[bx]

		shl	ax,cl

		ret

CalcMobMaxDim	ENDP

VISCODE		ENDS

;============================================================================

		END

