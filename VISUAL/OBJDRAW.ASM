;****************************************************************************
;*
;* OBJDRAW.ASM
;*
;* Draw distance sorted objects (also includes distance sort routines).
;*
;* 15.03.1991 - KJB
;* 07.07.1992 - KJB - ObjectDistSort4 routine added for OTYPE_MOBILE4 objects.
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	DrawObjects1
		PUBLIC	DrawObjects2
		PUBLIC	DrawObjects3
		PUBLIC	DrawFarObjects
		PUBLIC	ObjectDistSort1
		PUBLIC	ObjectDistSort2
		PUBLIC	ObjectDistSort3
		PUBLIC	ObjectDistSort4
		PUBLIC	NearHillSort
		PUBLIC	FarHillSort

		EXTRN	DrawGndObject:NEAR
		EXTRN	DrawMobObject1:NEAR
		EXTRN	DrawMobObject2:NEAR
		EXTRN	DrawMobObject3:NEAR
		EXTRN	DrawHillFace:NEAR
		EXTRN	DrawSmokeObject:NEAR

;============================================================================

		INCLUDE	VISEXTRN.INC
		INCLUDE	VISDATA.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

ObjectType	DW	DrawGndObject	;OTYPE_GROUND
		DW	DrawMobObject1	;OTYPE_MOBILE1
		DW	DrawMobObject2	;OTYPE_MOBILE2
		DW	DrawMobObject3	;OTYPE_MOBILE3
		DW	DrawMobObject2	;OTYPE_MOBILE4
		DW	DrawHillFace	;OTYPE_HILLFACE
		DW	DrawSmokeObject	;OTYPE_SMOKE

DATA		ENDS

;============================================================================

VISCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:VISCODE
		ASSUME DS:DATA

;* DrawObjects1 - draw objects from object buffer (below clouds)
;*
;* pass: ObjectDist1[]
;* ret : nothing
;* kill: assume all

DrawObjects1	PROC	NEAR

;* draw all objects (starting with furthest)

		mov	cx,NUM_BINS
		mov	si,OFFSET ObjectDist1+NUM_BINS*2-2

BinSearchLoop:	mov	ax,[si]		;fetch object ptr from bin
		cmp	ax,-1		;valid object ptr?
		je	SearchNextBin	;no ->

		push	cx		;store counter
		push	si		;store bin index

DrawObjectLoop:	mov	si,ax		;si -> object data

		mov	bl,OBJ_TYPE[si]	;fetch object type
		xor	bh,bh

		push	si
		call	ObjectType[bx]	;draw object
		pop	si

		mov	ax,OBJ_PTR[si]	;fetch ptr to next object
		cmp	ax,-1		;any more objects in bin?
		jne	DrawObjectLoop	;yes ->

		pop	si		;restore bin index
		pop	cx		;restore counter

SearchNextBin:	sub	si,2

		loop	BinSearchLoop

		ret

DrawObjects1	ENDP

;----------------------------------------------------------------------------

;* DrawObjects2 - draw objects from object buffer (in clouds)
;*
;* pass: ObjectDist2[]
;* ret : nothing
;* kill: assume all

DrawObjects2	PROC	NEAR

;* draw in front objects

		mov	ax,ObjectDist2[IN_FRONT_BIN]
		cmp	ax,-1		;valid object ptr?
		je	SkipBin2_1	;no ->

DrawObjLoop2_1:	mov	si,ax		;si -> object data

		mov	bl,OBJ_TYPE[si]	;fetch object type
		xor	bh,bh

		push	si
		call	ObjectType[bx]	;draw object
		pop	si

		mov	ax,OBJ_PTR[si]	;fetch ptr to next object
		cmp	ax,-1		;any more objects in bin?
		jne	DrawObjLoop2_1	;yes ->

;* draw behind objects

SkipBin2_1:	mov	ax,ObjectDist2[BEHIND_BIN]
		cmp	ax,-1		;valid object ptr?
		je	SkipBin2_2	;no ->

DrawObjLoop2_2:	mov	si,ax		;si -> object data

		mov	bl,OBJ_TYPE[si]	;fetch object type
		xor	bh,bh

		push	si
		call	ObjectType[bx]	;draw object
		pop	si

		mov	ax,OBJ_PTR[si]	;fetch ptr to next object
		cmp	ax,-1		;any more objects in bin?
		jne	DrawObjLoop2_2	;yes ->

SkipBin2_2:	ret

DrawObjects2	ENDP

;----------------------------------------------------------------------------

;* DrawObjects3 - draw objects from object buffer (above clouds)
;*
;* pass: ObjectDist3[]
;* ret : nothing
;* kill: assume all

DrawObjects3	PROC	NEAR

;* draw in front objects

		mov	ax,ObjectDist3[IN_FRONT_BIN]
		cmp	ax,-1		;valid object ptr?
		je	SkipBin3_1	;no ->

DrawObjLoop3_1:	mov	si,ax		;si -> object data

		mov	bl,OBJ_TYPE[si]	;fetch object type
		xor	bh,bh

		push	si
		call	ObjectType[bx]	;draw object
		pop	si

		mov	ax,OBJ_PTR[si]	;fetch ptr to next object
		cmp	ax,-1		;any more objects in bin?
		jne	DrawObjLoop3_1	;yes ->

;* draw behind objects

SkipBin3_1:	mov	ax,ObjectDist3[BEHIND_BIN]
		cmp	ax,-1		;valid object ptr?
		je	SkipBin3_2	;no ->

DrawObjLoop3_2:	mov	si,ax		;si -> object data

		mov	bl,OBJ_TYPE[si]	;fetch object type
		xor	bh,bh

		push	si
		call	ObjectType[bx]	;draw object
		pop	si

		mov	ax,OBJ_PTR[si]	;fetch ptr to next object
		cmp	ax,-1		;any more objects in bin?
		jne	DrawObjLoop3_2	;yes ->

SkipBin3_2:	ret

DrawObjects3	ENDP

;----------------------------------------------------------------------------

;* DrawFarObjects - draw far objects from far object buffer (below clouds)
;*
;* pass: FarObjectDist[]
;* ret : nothing
;* kill: assume all

DrawFarObjects	PROC	NEAR

;* draw all objects (starting with furthest)

		mov	cx,NUM_FAR_BINS
		mov	si,OFFSET FarObjectDist+NUM_FAR_BINS*2-2

FarBinLoop:	mov	ax,[si]		;fetch object ptr from bin
		cmp	ax,-1		;valid object ptr?
		je	NextFarBin	;no ->

		push	cx		;store counter
		push	si		;store bin index

DrawFarObjLoop:	mov	si,ax		;si -> object data

		mov	bl,OBJ_TYPE[si]	;fetch object type
		xor	bh,bh

		push	si
		call	ObjectType[bx]	;draw object
		pop	si

		mov	ax,OBJ_PTR[si]	;fetch ptr to next object
		cmp	ax,-1		;any more objects in bin?
		jne	DrawFarObjLoop	;yes ->

		pop	si		;restore bin index
		pop	cx		;restore counter

NextFarBin:	sub	si,2

		loop	FarBinLoop

		ret

DrawFarObjects	ENDP

;----------------------------------------------------------------------------

;* ObjectDistSort1 - object distance sort (below clouds)
;*
;* pass: dx = y eye (+/-16k max)
;*       di -> OBJECTDATA record
;*       ObjectDist1[]
;* ret : OBJ_PTR[di]
;*       ObjectDist1[]
;* kill: ax, bx, si, flags

ObjectDistSort1	PROC	NEAR

		test	dx,dx		;object behind?
		js	BehindSort1  	;yes ->

;* bin sort object distance to resolution of 256ft

		mov	al,dh		;/256 for bin sort
		xor	ah,ah		
		shl	ax,1		;*2 word index
		add	ax,IN_FRONT_BIN	;skip behind bin
		mov	si,ax

;* insertion sort object distance within bin (descending order of distance)

		mov	ax,ObjectDist1[si]
		cmp	ax,-1		;empty bin?
		je	EmptyBin1	;yes ->

		mov	bx,ax
		cmp	dx,OBJ_YPOS[bx]	;insert before first object in bin?
		jge	InsertFirst1	;yes ->

SearchBin1:	mov	si,bx		;si -> previous record
		mov	bx,OBJ_PTR[si]	;bx -> next record
		cmp	bx,-1		;last record encountered?
		je	InsertObject1	;yes ->
		cmp	dx,OBJ_YPOS[bx]	;insert here?
		jl	SearchBin1	;no ->

InsertObject1:	mov	OBJ_PTR[si],di
		mov	OBJ_PTR[di],bx
		ret

;* object behind - insertion sort not required, insert at start of behind bin

BehindSort1:	mov	ax,ObjectDist1[BEHIND_BIN]
		mov	ObjectDist1[BEHIND_BIN],di
		mov	OBJ_PTR[di],ax
		ret

;* only object in bin

EmptyBin1:	mov	ObjectDist1[si],di
		mov	OBJ_PTR[di],ax
		ret

;* first object in bin

InsertFirst1:	mov	ObjectDist1[si],di
		mov	OBJ_PTR[di],bx
		ret

ObjectDistSort1	ENDP

;----------------------------------------------------------------------------

;* ObjectDistSort2 - object distance sort (in clouds)
;*
;* pass: dx = y eye (+/-16k max)
;*       di -> OBJECTDATA record
;*       ObjectDist2[]
;* ret : OBJ_PTR[di]
;*       ObjectDist2[]
;* kill: ax, bx, si, flags

ObjectDistSort2	PROC	NEAR

		test	dx,dx		;object behind?
		js	BehindSort2  	;yes ->

;* insertion sort object distance within bin (descending order of distance)

		mov	ax,ObjectDist2[IN_FRONT_BIN]
		cmp	ax,-1		;empty bin?
		je	EmptyBin2	;yes ->

		mov	bx,ax
		cmp	dx,OBJ_YPOS[bx]	;insert before first object in bin?
		jge	InsertFirst2	;yes ->

SearchBin2:	mov	si,bx		;si -> previous record
		mov	bx,OBJ_PTR[si]	;bx -> next record
		cmp	bx,-1		;last record encountered?
		je	InsertObject2	;yes ->
		cmp	dx,OBJ_YPOS[bx]	;insert here?
		jl	SearchBin2	;no ->

InsertObject2:	mov	OBJ_PTR[si],di
		mov	OBJ_PTR[di],bx
		ret

;* object behind - insertion sort not required, insert at start of behind bin

BehindSort2:	mov	ax,ObjectDist2[BEHIND_BIN]
		mov	ObjectDist2[BEHIND_BIN],di
		mov	OBJ_PTR[di],ax
		ret

;* only object in bin

EmptyBin2:	mov	ObjectDist2[IN_FRONT_BIN],di
		mov	OBJ_PTR[di],ax
		ret

;* first object in bin

InsertFirst2:	mov	ObjectDist2[IN_FRONT_BIN],di
		mov	OBJ_PTR[di],bx
		ret

ObjectDistSort2	ENDP

;----------------------------------------------------------------------------

;* ObjectDistSort3 - object distance sort (above clouds)
;*
;* pass: dx = y eye (+/-16k max)
;*       di -> OBJECTDATA record
;*       ObjectDist3[]
;* ret : OBJ_PTR[di]
;*       ObjectDist3[]
;* kill: ax, bx, si, flags

ObjectDistSort3	PROC	NEAR

		test	dx,dx		;object behind?
		js	BehindSort3  	;yes ->

;* insertion sort object distance within bin (descending order of distance)

		mov	ax,ObjectDist3[IN_FRONT_BIN]
		cmp	ax,-1		;empty bin?
		je	EmptyBin3	;yes ->

		mov	bx,ax
		cmp	dx,OBJ_YPOS[bx]	;insert before first object in bin?
		jge	InsertFirst3	;yes ->

SearchBin3:	mov	si,bx		;si -> previous record
		mov	bx,OBJ_PTR[si]	;bx -> next record
		cmp	bx,-1		;last record encountered?
		je	InsertObject3	;yes ->
		cmp	dx,OBJ_YPOS[bx]	;insert here?
		jl	SearchBin3	;no ->

InsertObject3:	mov	OBJ_PTR[si],di
		mov	OBJ_PTR[di],bx
		ret

;* object behind - insertion sort not required, insert at start of behind bin

BehindSort3:	mov	ax,ObjectDist3[BEHIND_BIN]
		mov	ObjectDist3[BEHIND_BIN],di
		mov	OBJ_PTR[di],ax
		ret

;* only object in bin

EmptyBin3:	mov	ObjectDist3[IN_FRONT_BIN],di
		mov	OBJ_PTR[di],ax
		ret

;* first object in bin

InsertFirst3:	mov	ObjectDist3[IN_FRONT_BIN],di
		mov	OBJ_PTR[di],bx
		ret

ObjectDistSort3	ENDP

;----------------------------------------------------------------------------

;* ObjectDistSort4 - object distance sort mobiles on bridge (below clouds)
;*
;* pass: dx = y eye (+/-16k max)
;*       di -> OBJECTDATA record
;*       ObjectDist1[]
;* ret : OBJ_PTR[di]
;*       ObjectDist1[]
;* kill: ax, bx, si, flags
;*
;* note: This routine is a modified version of ObjectDistSort1. The comparison
;*       test has been modified so that mobiles on bridges are drawn after
;*       bridge objects. The test assumes that all ground objects are bridge
;*       objects.

ObjectDistSort4	PROC	NEAR

		test	dx,dx		;object behind?
		js	BehindSort6  	;yes ->

;* bin sort object distance to resolution of 256ft

		mov	al,dh		;/256 for bin sort
		xor	ah,ah		
		shl	ax,1		;*2 word index
		add	ax,IN_FRONT_BIN	;skip behind bin
		mov	si,ax

;* insertion sort object distance within bin (descending order of distance)

		mov	ax,ObjectDist1[si]
		cmp	ax,-1		;empty bin?
		je	EmptyBin6	;yes ->

		mov	bx,ax

		cmp	OBJ_TYPE[bx],OTYPE_GROUND	;ground object?
		je	SearchBin6			;yes, move past it ->

		cmp	dx,OBJ_YPOS[bx]	;insert before first object in bin?
		jge	InsertFirst6	;yes ->

SearchBin6:	mov	si,bx		;si -> previous record
		mov	bx,OBJ_PTR[si]	;bx -> next record
		cmp	bx,-1		;last record encountered?
		je	InsertObject6	;yes ->

		cmp	OBJ_TYPE[bx],OTYPE_GROUND	;ground object?
		je	SearchBin6			;yes, move past it ->
		
		cmp	dx,OBJ_YPOS[bx]	;insert here?
		jl	SearchBin6	;no ->

InsertObject6:	mov	OBJ_PTR[si],di
		mov	OBJ_PTR[di],bx
		ret

;* object behind - insertion sort not required, insert at start of behind bin

BehindSort6:	mov	ax,ObjectDist1[BEHIND_BIN]
		mov	ObjectDist1[BEHIND_BIN],di
		mov	OBJ_PTR[di],ax
		ret

;* only object in bin

EmptyBin6:	mov	ObjectDist1[si],di
		mov	OBJ_PTR[di],ax
		ret

;* first object in bin

InsertFirst6:	mov	ObjectDist1[si],di
		mov	OBJ_PTR[di],bx
		ret

ObjectDistSort4	ENDP

;----------------------------------------------------------------------------

;* NearHillSort - distance sort near hill faces
;*
;* pass: dx = y eye (+/-16k max)
;*       di -> OBJECTDATA record
;*       ObjectDist1[]
;* ret : OBJ_PTR[di]
;*       ObjectDist1[]
;* kill: ax, bx, cx, si, flags
;*
;* note: This routine assumes that the only object type currently in the
;*       object buffer is hill faces. The secondary y eye value OBJ_YMIN
;*       should be valid.
;*
;*       Hills are always below clouds.

NearHillSort	PROC	NEAR

		test	dx,dx		;object behind?
		js	BehindSort4  	;yes ->

;* fetch secondary y eye value

		mov	cx,OBJ_YMIN[di]

;* bin sort object distance to resolution of 256ft

		mov	al,dh		;/256 for bin sort
		xor	ah,ah		
		shl	ax,1		;*2 word index
		add	ax,IN_FRONT_BIN	;skip behind bin
		mov	si,ax

;* insertion sort object distance within bin (descending order of distance)

		mov	ax,ObjectDist1[si]
		cmp	ax,-1		;empty bin?
		je	EmptyBin4	;yes ->

		mov	bx,ax
		cmp	dx,OBJ_YPOS[bx]	;insert before first object in bin?
		jg	InsertFirst4	;yes ->
		jl	SearchBin4	;no ->
		cmp	cx,OBJ_YMIN[bx]	;equal, compare secondary y eye values
		jge	InsertFirst4	;insert before first ->

SearchBin4:	mov	si,bx		;si -> previous record
		mov	bx,OBJ_PTR[si]	;bx -> next record
		cmp	bx,-1		;last record encountered?
		je	InsertObject4	;yes ->
		cmp	dx,OBJ_YPOS[bx]	;insert here?
		jl	SearchBin4	;no ->
		jg	InsertObject4	;yes ->
		cmp	cx,OBJ_YMIN[bx]	;equal, compare secondary y eye values
		jl	SearchBin4	;continue search ->

InsertObject4:	mov	OBJ_PTR[si],di
		mov	OBJ_PTR[di],bx
		ret

;* object behind - insertion sort not required, insert at start of behind bin

BehindSort4:	mov	ax,ObjectDist1[BEHIND_BIN]
		mov	ObjectDist1[BEHIND_BIN],di
		mov	OBJ_PTR[di],ax
		ret

;* only object in bin

EmptyBin4:	mov	ObjectDist1[si],di
		mov	OBJ_PTR[di],ax
		ret

;* first object in bin

InsertFirst4:	mov	ObjectDist1[si],di
		mov	OBJ_PTR[di],bx
		ret

NearHillSort	ENDP

;----------------------------------------------------------------------------

;* FarHillSort - distance sort far hill faces
;*
;* pass: dx = y eye (+/-8k max (/16 scaling))
;*       di -> OBJECTDATA record
;*       FarObjectDist[]
;* ret : OBJ_PTR[di]
;*       FarObjectDist[]
;* kill: ax, bx, cx, si, flags
;* note: This routine assumes that the only object type currently in the
;*       object buffer is hill faces. The secondary y eye value OBJ_YMIN
;*       should be valid.
;*
;*       On entry y eye values are /16 scaled, therefore:-
;*
;*       8,191 represents 8,191 * 16 = 131,056
;*
;*       y eye requires further /128 scaling for bin sort resolution of 2,048.
;*
;*       Hills are always below clouds.

FarHillSort	PROC	NEAR

		test	dx,dx		;object behind?
		js	BehindSort5  	;yes ->

;* fetch secondary y eye value

		mov	cx,OBJ_YMIN[di]

;* bin sort object distance to resolution of 2,048ft

		mov	ax,dx

		xchg	al,ah		;/256
		rol	ax,1		;/128
		and	ax,0003fh	;0 .. 63
		shl	ax,1		;*2 word index
		add	ax,IN_FRONT_BIN	;skip behind bin
		mov	si,ax

;* insertion sort object distance within bin (descending order of distance)

		mov	ax,FarObjectDist[si]
		cmp	ax,-1		;empty bin?
		je	EmptyBin5	;yes ->

		mov	bx,ax
		cmp	dx,OBJ_YPOS[bx]	;insert before first object in bin?
		jg	InsertFirst5	;yes ->
		jl	SearchBin5	;no ->
		cmp	cx,OBJ_YMIN[bx]	;equal, compare secondary y eye values
		jge	InsertFirst5	;insert before first ->

SearchBin5:	mov	si,bx		;si -> previous record
		mov	bx,OBJ_PTR[si]	;bx -> next record
		cmp	bx,-1		;last record encountered?
		je	InsertObject5	;yes ->
		cmp	dx,OBJ_YPOS[bx]	;insert here?
		jl	SearchBin5	;no ->
		jg	InsertObject5	;yes ->
		cmp	cx,OBJ_YMIN[bx]	;equal, compare secondary y eye values
		jl	SearchBin5	;continue search ->

InsertObject5:	mov	OBJ_PTR[si],di
		mov	OBJ_PTR[di],bx
		ret

;* object behind - insertion sort not required, insert at start of behind bin

BehindSort5:	mov	ax,FarObjectDist[BEHIND_BIN]
		mov	FarObjectDist[BEHIND_BIN],di
		mov	OBJ_PTR[di],ax
		ret

;* only object in bin

EmptyBin5:	mov	FarObjectDist[si],di
		mov	OBJ_PTR[di],ax
		ret

;* first object in bin

InsertFirst5:	mov	FarObjectDist[si],di
		mov	OBJ_PTR[di],bx
		ret

FarHillSort	ENDP

VISCODE		ENDS

;============================================================================

		END

