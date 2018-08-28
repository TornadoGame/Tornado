;****************************************************************************
;*
;* TREES.ASM
;*
;* Draw trees in sector.
;*
;* 03.03.1992 - KJB
;*
;* Format of tree layer data:-
;*
;*    TreeLayer1 - b0: 1 = draw tree type 1 at position 0
;*                 b1: 1 = draw tree type 1 at position 1
;*                 ..       ..   ..   ..    ..    ..
;*                 b7: 1 = draw tree type 1 at position 7
;*
;*    TreeLayer2 - b0: 1 = draw tree type 2 at position 8
;*                 b1: 1 = draw tree type 2 at position 9 
;*                 ..       ..   ..   ..    ..    ..
;*                 b7: 1 = draw tree type 2 at position 15
;*
;*    TreeLayer3 - b0: 1 = draw tree type 3 at position 16
;*                 b1: 1 = draw tree type 3 at position 17
;*                 ..       ..   ..   ..    ..    ..
;*                 b7: 1 = draw tree type 3 at position 23
;*
;*    TreeLayer4 - b0: 1 = draw tree type 4 at position 24
;*                 b1: 1 = draw tree type 4 at position 25
;*                 ..       ..   ..   ..    ..    ..
;*                 b7: 1 = draw tree type 4 at position 31
;*
;*    It is possible to draw up to 32 tree objects, of 4 different types,
;*    per sector.
;*
;*    Tree object positions should be chosen to avoid conflict with roads,
;*    railways and rivers.
;*
;*    Four tree layouts are provided for variety.
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	ScanTrees

		PUBLIC	TreeLayouts

		PUBLIC	TreesEnabled

		EXTRN	ObjectDistSort1:NEAR

		EXTRN	TreeLayer1:BYTE
		EXTRN	TreeLayer2:BYTE
		EXTRN	TreeLayer3:BYTE
		EXTRN	TreeLayer4:BYTE

;============================================================================

		INCLUDE	VISEXTRN.INC
		INCLUDE	VISDATA.INC
		INCLUDE	GNDLIST.INC
		INCLUDE	\LIB8086\USEFUL.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

TreesEnabled	DB	1,0		;1 = trees enabled

XTemp		DW	0
YTemp		DW	0

;--------------------
;* tree layout tables
;--------------------

TreeLayouts	DW	OFFSET TreeLayout1
	   	DW	OFFSET TreeLayout2
	   	DW	OFFSET TreeLayout3
	   	DW	OFFSET TreeLayout4
	      
TreeLayout1	LABEL	BYTE
	
		DB	 8,  9		; 0
		DB	13,  4		; 1
		DB	46,  6		; 2
		DB	17, 60		; 3
		DB	61, 28		; 4
		DB	 4, 47		; 5
		DB	63, 11		; 6
		DB	33, 57		; 7
		DB	42, 63		; 8
		DB	51, 14		; 9
		DB	56, 38		;10
		DB	14, 36		;11
		DB	18, 53		;12
		DB	31, 30		;13
		DB	60, 35		;14
		DB	10, 52		;15
		DB	 1, 22		;16
		DB	15, 58		;17
		DB	50, 20		;18
		DB	 2, 31		;19
		DB	20, 21		;20
		DB	47, 18		;21
		DB	52, 59		;22
		DB	30,  5		;23
		DB	58, 55		;24
		DB	29,  2		;25
		DB	43, 10		;26
		DB	35, 37		;27
		DB	45, 46		;28
		DB	19, 39		;29
		DB	44, 17		;30
		DB	27, 41		;31

TreeLayout2	LABEL	BYTE

		DB	36, 58		; 0
		DB	60, 41		; 1
		DB	 2, 63		; 2
		DB	51,  9		; 3
		DB	49, 45		; 4
		DB	58, 50		; 5
		DB	17, 18		; 6
		DB	46,  3		; 7
		DB	45, 14		; 8
		DB	56, 54		; 9
		DB	34, 59		;10
		DB	 3,  8		;11
		DB	 5, 49		;12
		DB	 1, 36		;13
		DB	11, 35		;14
		DB	 4, 13		;15
		DB	 7, 20		;16
		DB	18,  4		;17
		DB	 6, 27		;18
		DB	55, 31		;19
		DB	50,  5		;20
		DB	19, 15		;21
		DB	29, 57		;22
		DB	31, 60		;23
		DB	53, 17		;24
		DB	24, 38		;25
		DB	40, 37		;26
		DB	25, 40		;27
		DB	38, 34		;28
		DB	20, 22		;29
		DB	33, 30		;30
		DB	47, 19		;31

TreeLayout3	LABEL	BYTE

		DB	60, 34		; 0
		DB	57, 54		; 1
		DB	26, 41		; 2
		DB	 4, 49		; 3
		DB	25, 40		; 4
		DB	31, 13		; 5
		DB	17,  9		; 6
		DB	 8, 53		; 7
		DB	50,  2		; 8
		DB	12,  3		; 9
		DB	19, 63		;10
		DB	47, 62		;11
		DB	58,  8		;12
		DB	 1, 38		;13
		DB	 5,  6		;14
		DB	20, 21		;15
		DB	35, 17		;16
		DB	62, 59		;17
		DB	 9, 36		;18
		DB	61, 27		;19
		DB	30, 60		;20
		DB	 3, 30		;21
		DB	56, 31		;22
		DB	33, 50		;23
		DB	45, 47		;24
		DB	 2, 24		;25
		DB	46, 45		;26
		DB	40,  1		;27
		DB	42, 15		;28
		DB	54, 44		;29
		DB	41, 28		;30
		DB	18, 20		;31

TreeLayout4	LABEL	BYTE

		DB	 7, 35		; 0
		DB	 2, 33		; 1
		DB	61,  1		; 2
		DB	46, 63		; 3
		DB	56, 57		; 4
		DB	13, 17		; 5
		DB	25, 59		; 6
		DB	40,  2		; 7
		DB	34, 58		; 8
		DB	 8, 51		; 9
		DB	35,  6		;10
		DB	24, 20		;11
		DB	 6, 14		;12
		DB	53, 10		;13
		DB	10, 12		;14
		DB	15, 54		;15
		DB	55, 38		;16
		DB	58, 60		;17
		DB	12, 30		;18
		DB	28,  7		;19
		DB	47, 44		;20
		DB	19, 62		;21
		DB	26,  4		;22
		DB	57, 34		;23
		DB	27, 41		;24
		DB	50, 21		;25
		DB	54, 19		;26
		DB	38, 39		;27
		DB	30, 31		;28
		DB	17, 46		;29
		DB	45, 18		;30
		DB	36, 29		;31

DATA		ENDS

;============================================================================

VISCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:VISCODE
		ASSUME DS:DATA

;* ScanTrees - scan sector for trees and place in object buffer
;*
;* pass: si = x sector offset (-1, 0, +1)
;*       di = y sector offset (-1, 0, +1)
;*       MapIndex
;*       TreeLayer1
;*       TreeLayer2
;*       TreeLayer3
;*       TreeLayer4
;*	 ObjectBufPtr
;* ret : ObjectBufPtr
;* kill: assume all

ExitTrees	LABEL	NEAR

		ret

ScanTrees	PROC	NEAR

		test	TreesEnabled,1	;enabled?
		jz	ExitTrees	;no ->

		neg	di		;-(y sec offset)

;* calc sector grid offsets

		mov	cl,6

		shl	si,cl		;x sector offset * 64
		shl	di,cl		;y sector offset * 64

;* calc sector grid offset wrt viewpoint

		sub	si,XGrid1
		add	si,64		;place around sector grid centre
		sub	di,YGrid1
		add	di,64		;place around sector grid centre

		mov	XTemp,si
		mov	YTemp,di

;* select layout wrt xsec and ysec (via MapIndex so values are wrapped)

		mov	ax,MapIndex
		mov	bx,ax
		REPT	4
		shr	bx,1
		ENDM
		and	ax,01b		;x
		and	bx,10b		;y
		or	bx,ax
		shl	bx,1		;*2 word index

		mov	bx,TreeLayouts[bx]

;* draw type 1 tree objects

		mov	bp,MapIndex
		mov	al,TreeLayer1[bp]
		test	al,al		;any trees?
		jz	@F		;no ->
		mov	ah,GND_COPSEA
		push	bx
		call	DrawTrees
		pop	bx

;* draw type 2 tree objects

		mov	bp,MapIndex
@@:		add	bx,8*2
		mov	al,TreeLayer2[bp]
		test	al,al		;any trees?
		jz	@F		;no ->
		mov	ah,GND_COPSEB
		push	bx
		call	DrawTrees
		pop	bx

;* draw type 3 tree objects

		mov	bp,MapIndex
@@:		add	bx,8*2
		mov	al,TreeLayer3[bp]
		test	al,al		;any trees?
		jz	@F		;no ->
		mov	ah,GND_COPSEC
		push	bx
		call	DrawTrees
		pop	bx

;* draw type 4 tree objects

		mov	bp,MapIndex
@@:		add	bx,8*2
		mov	al,TreeLayer4[bp]
		test	al,al		;any trees?
		jz	@F		;no ->
		mov	ah,GND_COPSED
		call	DrawTrees

@@:		ret

ScanTrees	ENDP

;----------------------------------------------------------------------------

;* DrawTrees - draw trees in sector
;*
;* pass: al = tree layout data
;*       ah = tree object type
;*       bx = tree position index
;*       XTemp
;*       YTemp
;*	 ObjectBufPtr
;* ret : ObjectBufPtr
;* kill: assume all

DrawTrees	PROC	NEAR

		mov	di,ObjectBufPtr

TreeLoop:	cmp	di,OFFSET ObjectBufEnd
		_JE	ExitTreeLoop	;no space left in object buffer ->

		shr	al,1		;draw tree?
		_JNC	SkipTree	;no ->

		push	ax		;store tree layout data
		push	bx		;store tree position index

		mov	OBJ_NUM[di],ah	;store tree object

		mov	al,[bx+0] 	;fetch x grid position
		xor	ah,ah	      	
		add	ax,XTemp	;add viewpoint x offset
		mov	si,ax

		mov	al,[bx+1]	;fetch y grid position
		xor	ah,ah
		add	ax,YTemp	;add viewpoint y offset
		mov	bx,ax
	
;* calc object centre position (abort if object out of range)

		cmp	si,128		;in range?
		ja	NextTree	;no ->
		cmp	bx,128		;in range?
		ja	NextTree	;no ->

		shl	si,1		;make x index
		shl	bx,1		;make y index

;* store object x grid index and y grid index

		mov	OBJ_XGRID[di],si
		mov	OBJ_YGRID[di],bx

;* calc y pos (calc y pos first to reject objects behind)

		mov	ax,YE01
		add	ax,YSX[si]
		add	ax,YSY[bx]
		jo	NextTree	;overflow ->
		cmp	ax,-1024	;in range (approx 512 * sqrt(2))?
		jl	NextTree	;no ->
		cmp	ax,+16383	;in range?
		jg	NextTree	;no ->
		mov	OBJ_YPOS[di],ax

		mov	dx,ax

;* calc x pos

		mov	ax,XE01
		add	ax,XSX[si]
		add	ax,XSY[bx]
		jo	NextTree	;overflow ->
		cmp	ax,-16384	;in range?
		jl	NextTree 	;no ->
		cmp	ax,+16383	;in range?
		jg	NextTree	;no ->
		mov	OBJ_XPOS[di],ax

;* calc z pos

		mov	ax,ZE01
		add	ax,ZSX[si]
		add	ax,ZSY[bx]
		jo	NextTree 	;overflow ->
		cmp	ax,-16384	;in range?
		jl	NextTree	;no ->
		cmp	ax,+16383	;in range?
		jg	NextTree	;no ->
		mov	OBJ_ZPOS[di],ax

;* sort object distance

		call	ObjectDistSort1

		mov	OBJ_TYPE[di],OTYPE_GROUND

		mov	OBJ_ANIM_FLAGS[di],0

		add	di,OBJ_REC_SIZE

NextTree:	pop	bx		;restore tree position index
		pop	ax		;restore tree layout data

SkipTree:	add	bx,2		;next index

		test	al,al		;any more trees?
		_JNZ	TreeLoop	;yes ->

ExitTreeLoop:	mov	ObjectBufPtr,di	;update object buffer pointer

		ret

DrawTrees	ENDP

VISCODE		ENDS

;============================================================================

		END

