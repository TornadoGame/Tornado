;****************************************************************************
;*
;* SECDRAW.ASM
;*
;* Sector drawing routines.
;*
;* 15.03.1991 - KJB
;*
;* Format of sector object list:-
;*
;*		DB	object number, condition flags, x grid, y grid
;*		DB	object number, condition flags, x grid, y grid
;*		..	  ..     ..       ..      ..  	  ..	  ..
;*		DB	object number, condition flags, x grid, y grid
;*		DB	-1		;list terminator
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	DrawSector

		EXTRN	DrawFlatObject:NEAR
		EXTRN	ObjectDistSort1:NEAR

		EXTRN	SectorTable:WORD

		EXTRN	SectorLayer1:BYTE

;============================================================================

		INCLUDE	VISEXTRN.INC
		INCLUDE	VISDATA.INC
		INCLUDE	VISMACRO.INC
		INCLUDE	\LIB8086\USEFUL.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'
		
DATA		ENDS

;============================================================================

SECDATA1	SEGMENT PARA PUBLIC 'DATA'

SECDATA1	ENDS

;============================================================================

VISCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:VISCODE
		ASSUME DS:DATA

;* DrawSector - scan sector for ground objects and place in object buffer
;*
;* pass: si = x sector offset (-1, 0, +1)
;*       di = y sector offset (-1, 0, +1)
;*       MapIndex
;*       SectorLayer1
;*	 ObjectBufPtr
;* ret : ObjectBufPtr
;* kill: assume all

ExitSector	LABEL	NEAR

		ret

DrawSector	PROC	NEAR

		mov	bp,MapIndex
		mov	al,SectorLayer1[bp]

		test	al,al		;null sector?
		jz	ExitSector	;yes ->
	
		neg	di		;-(y sec offset)

		mov	cx,si
		mov	bp,di

;* calc pointer to sector data record

		CALC_SEC_PTR

;* calc sector grid offsets

		REPT	6
		shl	cx,1		;x sector offset * 64
		shl	bp,1		;y sector offset * 64
		ENDM

;* calc sector grid offset wrt viewpoint

		sub	cx,XGrid1
		add	cx,64		;place around sector grid centre
		sub	bp,YGrid1
		add	bp,64		;place around sector grid centre

;--------------------------
;* draw flat ground objects
;--------------------------

		push	bx		;store sector data pointer

		mov	si,SEC_FLAT_PTR[bx]

		mov	ax,SECDATA1
		mov	es,ax

;* flat ground object scan loop

FlatObjectLoop:	mov	di,OFFSET FlatObject

		ES_LODSB		;fetch object number
		cmp	al,-1		;end of list?
		jne	ContFlatLoop	;no ->
		jmp	ExitFlatLoop

ContFlatLoop:	mov	OBJ_NUM[di],al

		ES_LODSB		;fetch object animation flags
		mov	OBJ_ANIM_FLAGS[di],al

		ES_LODSB		;fetch x grid position
		xor	ah,ah	      	
		add	ax,cx		;add viewpoint x offset
		mov	bx,ax

		ES_LODSB		;fetch y grid position
		xor	ah,ah
		add	ax,bp		;add viewpoint y offset
	
;* calc object centre position (abort if object out of range)

		cmp	bx,128		;in range?
		ja	FlatObjectLoop	;no ->
		cmp	ax,128		;in range?
		ja	FlatObjectLoop	;no ->

		push	si		;store list ptr

		mov	si,ax
		shl	bx,1		;make x index
		shl	si,1		;make y index

;* store object x grid index and y grid index

		mov	OBJ_XGRID[di],bx
		mov	OBJ_YGRID[di],si

;* calc y pos (calc y pos first to reject objects behind)

		mov	ax,YE01
		add	ax,YSX[bx]
		add	ax,YSY[si]
		jo	AbortFlatObject	;overflow ->
		cmp	ax,-1024	;in range (approx 512 * sqrt(2))?
		jl	AbortFlatObject	;no ->
		cmp	ax,+16383	;in range?
		jg	AbortFlatObject	;no ->
		mov	OBJ_YPOS[di],ax

;* calc x pos

		mov	ax,XE01
		add	ax,XSX[bx]
		add	ax,XSY[si]
		jo	AbortFlatObject	;overflow ->
		cmp	ax,-16384	;in range?
		jl	AbortFlatObject ;no ->
		cmp	ax,+16383	;in range?
		jg	AbortFlatObject	;no ->
		mov	OBJ_XPOS[di],ax

;* calc z pos

		mov	ax,ZE01
		add	ax,ZSX[bx]
		add	ax,ZSY[si]
		jo	AbortFlatObject	;overflow ->
		cmp	ax,-16384	;in range?
		jl	AbortFlatObject	;no ->
		cmp	ax,+16383	;in range?
		jg	AbortFlatObject	;no ->
		mov	OBJ_ZPOS[di],ax

;* draw flat ground object (no depth buffering required)

		mov	ax,DATA
		mov	es,ax

		push	cx
		push	bp
		call	DrawFlatObject
		pop	bp
		pop	cx

		mov	ax,SECDATA1
		mov	es,ax

AbortFlatObject:pop	si   		;restore list ptr

		jmp	FlatObjectLoop

ExitFlatLoop:	pop	bx		;restore sector data pointer

;---------------------
;* draw ground objects
;---------------------

		mov	si,SEC_OBJ_PTR[bx]

		mov	di,ObjectBufPtr

;* ground object scan loop

GndObjectLoop:	cmp	di,OFFSET ObjectBufEnd
		jne	ContGndLoop1
		jmp	ExitGndLoop	;no space left in object buffer ->

ContGndLoop1:	ES_LODSB		;fetch object number
		cmp	al,-1		;end of list?
		jne	ContGndLoop2	;no ->
		jmp	ExitGndLoop

ContGndLoop2:	mov	OBJ_NUM[di],al

		ES_LODSB		;fetch object animation flags
		mov	OBJ_ANIM_FLAGS[di],al

		ES_LODSB		;fetch x grid position
		xor	ah,ah	      	
		add	ax,cx		;add viewpoint x offset
		mov	bx,ax

		ES_LODSB		;fetch y grid position
		xor	ah,ah
		add	ax,bp		;add viewpoint y offset
	
;* calc object centre position (abort if object out of range)

		cmp	bx,128		;in range?
		ja	GndObjectLoop	;no ->
		cmp	ax,128		;in range?
		ja	GndObjectLoop	;no ->

		push	si		;store list ptr

		mov	si,ax
		shl	bx,1		;make x index
		shl	si,1		;make y index

;* store object x grid index and y grid index

		mov	OBJ_XGRID[di],bx
		mov	OBJ_YGRID[di],si

;* calc y pos (calc y pos first to reject objects behind)

		mov	ax,YE01
		add	ax,YSX[bx]
		add	ax,YSY[si]
		jo	AbortGndObject	;overflow ->
		cmp	ax,-1024	;in range (approx 512 * sqrt(2))?
		jl	AbortGndObject	;no ->
		cmp	ax,+16383	;in range?
		jg	AbortGndObject	;no ->
		mov	OBJ_YPOS[di],ax

		mov	dx,ax

;* calc x pos

		mov	ax,XE01
		add	ax,XSX[bx]
		add	ax,XSY[si]
		jo	AbortGndObject	;overflow ->
		cmp	ax,-16384	;in range?
		jl	AbortGndObject 	;no ->
		cmp	ax,+16383	;in range?
		jg	AbortGndObject	;no ->
		mov	OBJ_XPOS[di],ax

;* calc z pos

		mov	ax,ZE01
		add	ax,ZSX[bx]
		add	ax,ZSY[si]
		jo	AbortGndObject 	;overflow ->
		cmp	ax,-16384	;in range?
		jl	AbortGndObject	;no ->
		cmp	ax,+16383	;in range?
		jg	AbortGndObject	;no ->
		mov	OBJ_ZPOS[di],ax

;* sort object distance

		call	ObjectDistSort1

		mov	al,OTYPE_GROUND
		mov	OBJ_TYPE[di],al

		add	di,OBJ_REC_SIZE

AbortGndObject:	pop	si   		;restore list ptr

		jmp	GndObjectLoop

ExitGndLoop:	mov	ax,DATA
		mov	es,ax

		mov	ObjectBufPtr,di	;update object buffer pointer

		ret

DrawSector	ENDP

VISCODE		ENDS

;============================================================================

		END

