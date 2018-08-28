;****************************************************************************
;*
;* GROUND.ASM
;*
;* Draw ground objects (including flat ground objects).
;*
;* 04.03.1991 - KJB
;*
;* Format of ground object data:-
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
;* Flat ground objects use the same data format as above, except that the
;* z value is not required in the vertex list. All polygons are clockwise
;* therefore no cyclic checking is required. Flat objects should always
;* use secondary polygons (cyclic is set to clockwise).
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

       		PUBLIC	DrawGndObject
		PUBLIC	DrawFlatObject

		EXTRN	SetPixel:FAR

		EXTRN	DotClip:NEAR
		EXTRN	CalcOutCodes:NEAR
		EXTRN	ScanFace:NEAR

		EXTRN	GroundTable:WORD
		EXTRN	FlatTable:WORD
		EXTRN	DrawRecover:WORD
		
;============================================================================

		INCLUDE	VISEXTRN.INC
		INCLUDE	VISDATA.INC
		INCLUDE	\LIB8086\USEFUL.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

;* calc object position wrt scale mode

CalcObjectPos	DW	CalcObjectPos1	;OBJ_SCALE1
		DW	CalcObjectPos2	;OBJ_SCALE2
		DW	CalcObjectPos4	;OBJ_SCALE4
		DW	CalcObjectPos8	;OBJ_SCALE8
		DW	CalcObjectPos16	;OBJ_SCALE16

DATA		ENDS

;============================================================================

GRNDOBJ1	SEGMENT PARA PUBLIC 'DATA'

GRNDOBJ1	ENDS

;============================================================================

FLATOBJ1	SEGMENT PARA PUBLIC 'DATA'

FLATOBJ1	ENDS

;============================================================================

VISCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:VISCODE
		ASSUME DS:DATA

;* DrawGndObject - draw ground object
;*
;* pass: si -> OBJECTDATA record
;* ret : cf = 0 = ok
;*       cf = 1 = error
;* kill: assume all

DrawGndObject	PROC	NEAR

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
		jae	SkipSort1	;yes ->
		mov	ax,bx

SkipSort1:	cmp	ax,cx		;max(abs(x), abs(y)) >= abs(z)?
		jae	SkipSort2	;yes ->
		mov	ax,cx

SkipSort2:	mov	dx,ax		;dx = max(abs(x), abs(y), abs(z))

;-------------------------------------
;* fetch pointer to ground object data
;-------------------------------------

		mov	bl,OBJ_NUM[si]
		xor	bh,bh
		shl	bx,1		;*2 index

		mov	ax,GroundTable[bx]

;-------------------------------------------------------------------------
;* test if object is in range, if not, move to next approximation (if any)
;-------------------------------------------------------------------------

		mov	bp,GRNDOBJ1
		mov	ds,bp

ApproxLoop:	mov	bx,ax		;bx -> object data

		cmp	dx,OBJ_HDR_RANGE[bx]
		jb	SortPosition	;in range ->

		mov	ax,OBJ_HDR_PTR[bx]
		cmp	ax,-1		;any more approximations?
		jne	ApproxLoop	;yes ->

;------------------------------------------
;* approximate object to pixel (if enabled)
;------------------------------------------

		mov	ah,OBJ_HDR_FLAGS[bx]
		mov	al,OBJ_HDR_COL[bx]
		
		mov	bp,DATA
		mov	ds,bp

		test	ah,OBJ_FLG_PIXEL
		jz	ExitGndObject	;pixel approximation disabled ->

		push	ax		;store colour

		mov	ax,OBJ_XPOS[si]	;fetch object position
		mov	Xe[0],ax
		mov	ax,OBJ_YPOS[si]
		mov	Ye[0],ax
		mov	ax,OBJ_ZPOS[si]
		mov	Ze[0],ax

		call	DotClip
		pop	ax		;restore colour
		jc	ExitGndObject	;non-visible ->
		
		call	SetPixel

		jmp	ExitGndObject

;-------------------------------------	
;* sort object position wrt scale mode
;-------------------------------------
		
SortPosition:	mov	di,OBJ_HDR_SCALE[bx]

		mov	ax,DATA
		mov	ds,ax

		mov	bp,bx		;store object ptr

		call	CalcObjectPos[di]

;----------------------
;* sort animation flags
;----------------------

		mov	al,OBJ_ANIM_FLAGS[si]
		mov	ObjAnimFlags,al
	
		mov	si,bp		;restore object ptr

		add	si,OBJ_HDR_SIZE	;skip header data

;------------------------------------------------
;* scan vertex list and calculate eye co-ord data
;------------------------------------------------

		mov	ax,GRNDOBJ1
		mov	es,ax

		call	ScanVertexList

		mov	ax,DATA
		mov	es,ax

;---------------------------
;* test if object is visible
;---------------------------

		push	si
		mov	si,di
		call	CalcOutCodes
		pop	si
		jc	ExitGndObject	;object non-visible ->

;------------------------------------------------------
;* copy face data from GRNDOBJ1 segment to DATA segment
;------------------------------------------------------

		mov	ax,GRNDOBJ1
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

ExitGndObject:	clc			;cf = 0 = ok
		ret    	

DrawGndObject	ENDP

;----------------------------------------------------------------------------

;* DrawFlatObject - draw flat ground object
;*
;* pass: FlatObject data record
;* ret : cf = 0 = ok
;*       cf = 1 = error
;* kill: assume all

DrawFlatObject	PROC	NEAR

		mov	DrawRecover,sp	;recover stack to here if error

		mov	Cyclic,+1	;clockwise cyclic (always)

		mov	si,OFFSET FlatObject

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
		jae	SkipSortA	;yes ->
		mov	ax,bx

SkipSortA:	cmp	ax,cx		;max(abs(x), abs(y)) >= abs(z)?
		jae	SkipSortB	;yes ->
		mov	ax,cx

SkipSortB:	mov	dx,ax		;dx = max(abs(x), abs(y), abs(z))

;------------------------------------------
;* fetch pointer to flat ground object data
;------------------------------------------

		mov	bl,OBJ_NUM[si]
		xor	bh,bh
		shl	bx,1		;*2 index

		mov	ax,FlatTable[bx]

;-------------------------------------------------------------------------
;* test if object is in range, if not, move to next approximation (if any)
;-------------------------------------------------------------------------

		mov	bp,FLATOBJ1
		mov	ds,bp

FlatApproxLoop:	mov	bx,ax		;bx -> object data

		cmp	dx,OBJ_HDR_RANGE[bx]
		jb	SortFlatPos	;in range ->

		mov	ax,OBJ_HDR_PTR[bx]
		cmp	ax,-1		;any more approximations?
		jne	FlatApproxLoop	;yes ->

;------------------------------------------
;* approximate object to pixel (if enabled)
;------------------------------------------

		mov	ah,OBJ_HDR_FLAGS[bx]
		mov	al,OBJ_HDR_COL[bx]
		
		mov	bp,DATA
		mov	ds,bp

		test	ah,OBJ_FLG_PIXEL
		jz	ExitFlatObject	;pixel approximation disabled ->

		push	ax		;store colour

		mov	ax,OBJ_XPOS[si]	;fetch object position
		mov	Xe[0],ax
		mov	ax,OBJ_YPOS[si]
		mov	Ye[0],ax
		mov	ax,OBJ_ZPOS[si]
		mov	Ze[0],ax

		call	DotClip
		pop	ax		;restore colour
		jc	ExitFlatObject	;non-visible ->
		
		call	SetPixel

		jmp	ExitFlatObject

;------------------------------------------	
;* sort flat object position wrt scale mode
;------------------------------------------
		
SortFlatPos:	mov	di,OBJ_HDR_SCALE[bx]

		mov	ax,DATA
		mov	ds,ax

		mov	bp,bx		;store object ptr

		call	CalcObjectPos[di]

;----------------------
;* sort animation flags
;----------------------

		mov	al,OBJ_ANIM_FLAGS[si]
		mov	ObjAnimFlags,al
	
		mov	si,bp		;restore object ptr

		add	si,OBJ_HDR_SIZE	;skip header data

;------------------------------------------------
;* scan vertex list and calculate eye co-ord data
;------------------------------------------------

		mov	ax,FLATOBJ1
		mov	es,ax

		call	ScanFlatVrtxLst

		mov	ax,DATA
		mov	es,ax

;---------------------------
;* test if object is visible
;---------------------------

		push	si
		mov	si,di
		call	CalcOutCodes
		pop	si
		jc	ExitFlatObject	;object non-visible ->

;------------------------------------------------------
;* copy face data from FLATOBJ1 segment to DATA segment
;------------------------------------------------------

		mov	ax,FLATOBJ1
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

ExitFlatObject:	clc			;cf = 0 = ok
		ret    	

DrawFlatObject	ENDP

;----------------------------------------------------------------------------

;* CalcObjectPos1 - calc position of OBJ_SCALE1 object
;*
;* pass: si -> OBJECTDATA record
;* ret : XPos, YPos, ZPos
;* kill: ax

CalcObjectPos1	PROC	NEAR

		mov	ax,OBJ_XPOS[si]
		mov	XPos,ax
		mov	ax,OBJ_YPOS[si]
		mov	YPos,ax
		mov	ax,OBJ_ZPOS[si]
		mov	ZPos,ax

		ret
		   
CalcObjectPos1	ENDP	

;----------------------------------------------------------------------------

;* CalcObjectPos2 - calc position of OBJ_SCALE2 object
;*
;* pass: si -> OBJECTDATA record
;* ret : XPos, YPos, ZPos
;* kill: ax, bx, di, flags

CalcObjectPos2	PROC	NEAR

		mov	al,Valid1_2
		test	al,al		;2 * overscaled vars valid?
		jz	FixObjectPos2	;no ->

		mov	ax,OBJ_XGRID[si]
		sub	ax,64*2		;centre index around zero
		shl	ax,1		;*2 index (signed)
		add	ax,64*2		;place around sector grid centre
		cmp	ax,128*2	;index in range?
		ja	FixObjectPos2	;no ->
		mov	bx,ax

		mov	ax,OBJ_YGRID[si]
		sub	ax,64*2		;centre index around zero
		shl	ax,1		;*2 index (signed)
		add	ax,64*2		;place around sector grid centre
		cmp	ax,128*2	;index in range?
		ja	FixObjectPos2	;no ->
		mov	di,ax

		mov	ax,XE01_2
		add	ax,XSX[bx]
		add	ax,XSY[di]
		mov	XPos,ax
		
		mov	ax,YE01_2
		add	ax,YSX[bx]
		add	ax,YSY[di]
		mov	YPos,ax
	
		mov	ax,ZE01_2
		add	ax,ZSX[bx]
		add	ax,ZSY[di]
		mov	ZPos,ax
	
		ret
		   
;* index out of range, calc coarse position values

FixObjectPos2:	mov	ax,OBJ_XPOS[si]
		shl	ax,1		;*2
		mov	XPos,ax

		mov	ax,OBJ_YPOS[si]
		shl	ax,1		;*2
		mov	YPos,ax

		mov	ax,OBJ_ZPOS[si]
		shl	ax,1		;*2
		mov	ZPos,ax

		ret
	
CalcObjectPos2	ENDP	

;----------------------------------------------------------------------------

;* CalcObjectPos4 - calc position of OBJ_SCALE4 object
;*
;* pass: si -> OBJECTDATA record
;* ret : XPos, YPos, ZPos
;* kill: ax, bx, di, flags

CalcObjectPos4	PROC	NEAR

		mov	al,Valid1_4
		test	al,al		;4 * overscaled vars valid?
		jz	FixObjectPos4	;no ->

		mov	ax,OBJ_XGRID[si]
		sub	ax,64*2		;centre index around zero
		shl	ax,1		;*2
		shl	ax,1		;*4 index (signed)
		add	ax,64*2		;place around sector grid centre
		cmp	ax,128*2	;index in range?
		ja	FixObjectPos4	;no ->
		mov	bx,ax

		mov	ax,OBJ_YGRID[si]
		sub	ax,64*2		;centre index around zero
		shl	ax,1		;*2
		shl	ax,1		;*4 index (signed)
		add	ax,64*2		;place around sector grid centre
		cmp	ax,128*2	;index in range?
		ja	FixObjectPos4	;no ->
		mov	di,ax

		mov	ax,XE01_4
		add	ax,XSX[bx]
		add	ax,XSY[di]
		mov	XPos,ax
		
		mov	ax,YE01_4
		add	ax,YSX[bx]
		add	ax,YSY[di]
		mov	YPos,ax
	
		mov	ax,ZE01_4
		add	ax,ZSX[bx]
		add	ax,ZSY[di]
		mov	ZPos,ax
	
		ret
		   
;* index out of range, calc coarse position values

FixObjectPos4:	mov	ax,OBJ_XPOS[si]
		shl	ax,1		;*2
		shl	ax,1		;*4
		mov	XPos,ax

		mov	ax,OBJ_YPOS[si]
		shl	ax,1		;*2
		shl	ax,1		;*4
		mov	YPos,ax

		mov	ax,OBJ_ZPOS[si]
		shl	ax,1		;*2
		shl	ax,1		;*4
		mov	ZPos,ax

		ret
	
CalcObjectPos4	ENDP	

;----------------------------------------------------------------------------

;* CalcObjectPos8 - calc position of OBJ_SCALE8 object
;*
;* pass: si -> OBJECTDATA record
;* ret : XPos, YPos, ZPos
;* kill: ax, bx, di, flags

CalcObjectPos8	PROC	NEAR

		mov	al,Valid1_8
		test	al,al		;8 * overscaled vars valid?
		jz	FixObjectPos8	;no ->

		mov	ax,OBJ_XGRID[si]
		sub	ax,64*2		;centre index around zero
		shl	ax,1		;*2
		shl	ax,1		;*4
		shl	ax,1		;*8 index (signed)
		add	ax,64*2		;place around sector grid centre
		cmp	ax,128*2	;index in range?
		ja	FixObjectPos8	;no ->
		mov	bx,ax

		mov	ax,OBJ_YGRID[si]
		sub	ax,64*2		;centre index around zero
		shl	ax,1		;*2
		shl	ax,1		;*4
		shl	ax,1		;*8 index (signed)
		add	ax,64*2		;place around sector grid centre
		cmp	ax,128*2	;index in range?
		ja	FixObjectPos8	;no ->
		mov	di,ax

		mov	ax,XE01_8
		add	ax,XSX[bx]
		add	ax,XSY[di]
		mov	XPos,ax
		
		mov	ax,YE01_8
		add	ax,YSX[bx]
		add	ax,YSY[di]
		mov	YPos,ax
	
		mov	ax,ZE01_8
		add	ax,ZSX[bx]
		add	ax,ZSY[di]
		mov	ZPos,ax
	
		ret
		   
;* index out of range, calc coarse position values

FixObjectPos8:	mov	ax,OBJ_XPOS[si]
		shl	ax,1		;*2
		shl	ax,1		;*4
		shl	ax,1		;*8
		mov	XPos,ax

		mov	ax,OBJ_YPOS[si]
		shl	ax,1		;*2
		shl	ax,1		;*4
		shl	ax,1		;*8
		mov	YPos,ax

		mov	ax,OBJ_ZPOS[si]
		shl	ax,1		;*2
		shl	ax,1		;*4
		shl	ax,1		;*8
		mov	ZPos,ax

		ret
	
CalcObjectPos8	ENDP	

;----------------------------------------------------------------------------

;* CalcObjectPos16 - calc position of OBJ_SCALE16 object
;*
;* pass: si -> OBJECTDATA record
;* ret : XPos, YPos, ZPos
;* kill: ax, bx, di, flags

CalcObjectPos16	PROC	NEAR

		mov	al,Valid1_16
		test	al,al		;16 * overscaled vars valid?
		jz	FixObjectPos16	;no ->

		mov	ax,OBJ_XGRID[si]
		sub	ax,64*2		;centre index around zero
		shl	ax,1		;*2
		shl	ax,1		;*4
		shl	ax,1		;*8
		shl	ax,1		;*16 index (signed)
		add	ax,64*2		;place around sector grid centre
		cmp	ax,128*2	;index in range?
		ja	FixObjectPos16	;no ->
		mov	bx,ax

		mov	ax,OBJ_YGRID[si]
		sub	ax,64*2		;centre index around zero
		shl	ax,1		;*2
		shl	ax,1		;*4
		shl	ax,1		;*8
		shl	ax,1		;*16 index (signed)
		add	ax,64*2		;place around sector grid centre
		cmp	ax,128*2	;index in range?
		ja	FixObjectPos16	;no ->
		mov	di,ax

		mov	ax,XE01_16
		add	ax,XSX[bx]
		add	ax,XSY[di]
		mov	XPos,ax
		
		mov	ax,YE01_16
		add	ax,YSX[bx]
		add	ax,YSY[di]
		mov	YPos,ax
	
		mov	ax,ZE01_16
		add	ax,ZSX[bx]
		add	ax,ZSY[di]
		mov	ZPos,ax
	
		ret

;* index out of range, calc coarse position values

FixObjectPos16:	mov	ax,OBJ_XPOS[si]
		shl	ax,1		;*2
		shl	ax,1		;*4
		shl	ax,1		;*8
		shl	ax,1		;*16
		mov	XPos,ax

		mov	ax,OBJ_YPOS[si]
		shl	ax,1		;*2
		shl	ax,1		;*4
		shl	ax,1		;*8
		shl	ax,1		;*16
		mov	YPos,ax

		mov	ax,OBJ_ZPOS[si]
		shl	ax,1		;*2
		shl	ax,1		;*4
		shl	ax,1		;*8
		shl	ax,1		;*16
		mov	ZPos,ax

		ret
	
CalcObjectPos16	ENDP	

;----------------------------------------------------------------------------

;* ScanVertexList - scan vertex list and calc eye co-ords
;*
;* pass: es:si -> vertex list
;*       XPos, YPos, ZPos
;* ret : es:si -> end of vertex list + 1
;*       di = indexes last vertex value in eye co-ord arrays
;*       Xe[], Ye[], Ze[]
;* kill: ax, bx, cx, dx, bp, flags

ScanVertexList	PROC	NEAR

		xor	di,di		;reset eye co-ord index

		xor	bx,bx		;reset index (high byte always 0)

ScanVertexLoop:	ES_LODSB		;fetch x index
		cmp	al,-1		;end of vertex list?
		je	ExitScanVertex	;yes ->
		
		mov	bl,al
		mov	cx,XGX[bx]	;XGX
		mov	dx,YGX[bx]	;YGX
		mov	bp,ZGX[bx]	;ZGX

		ES_LODSB		;fetch y index
		mov	bl,al
		add	cx,XGY[bx]	;XGX + XGY
		add	dx,YGY[bx]	;YGX + YGY
		add	bp,ZGY[bx]	;ZGX + ZGY

		ES_LODSB		;fetch z index
		mov	bl,al
		add	cx,XGZ[bx]	;XGX + XGY + XGZ
		add	dx,YGZ[bx]	;YGX + YGY + YGZ
		add	bp,ZGZ[bx]	;ZGX + ZGY + ZGZ

		add	cx,XPos		;XPos + XGX + XGY + XGZ
		mov	Xe[di],cx

		add	dx,YPos		;YPos + YGX + YGY + YGZ
		mov	Ye[di],dx

		add	bp,ZPos		;ZPos + ZGX + ZGY + ZGZ
		mov	Ze[di],bp

		add	di,2		;next index

		jmp	ScanVertexLoop

ExitScanVertex:	sub	di,2		;di indexes last vertex
		ret

ScanVertexList	ENDP

;----------------------------------------------------------------------------

;* ScanFlatVrtxLst - scan flat object vertex list and calc eye co-ords
;*
;* pass: es:si -> vertex list
;*       XPos, YPos, ZPos
;* ret : es:si -> end of vertex list + 1
;*       di = indexes last vertex value in eye co-ord arrays
;*       Xe[], Ye[], Ze[]
;* kill: ax, bx, cx, dx, bp, flags

ScanFlatVrtxLst	PROC	NEAR

		xor	di,di		;reset eye co-ord index

		xor	bx,bx		;reset index (high byte always 0)

ScanFlatLoop:	ES_LODSB		;fetch x index
		cmp	al,-1		;end of vertex list?
		je	ExitScanFlat	;yes ->
		
		mov	bl,al
		mov	cx,XGX[bx]	;XGX
		mov	dx,YGX[bx]	;YGX
		mov	bp,ZGX[bx]	;ZGX

		ES_LODSB		;fetch y index
		mov	bl,al
		add	cx,XGY[bx]	;XGX + XGY
		add	dx,YGY[bx]	;YGX + YGY
		add	bp,ZGY[bx]	;ZGX + ZGY

		add	cx,XPos		;XPos + XGX + XGY
		mov	Xe[di],cx

		add	dx,YPos		;YPos + YGX + YGY
		mov	Ye[di],dx

		add	bp,ZPos		;ZPos + ZGX + ZGY
		mov	Ze[di],bp

		add	di,2		;next index

		jmp	ScanFlatLoop

ExitScanFlat:	sub	di,2		;di indexes last vertex
		ret

ScanFlatVrtxLst	ENDP

VISCODE		ENDS

;============================================================================

		END

