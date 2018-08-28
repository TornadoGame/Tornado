;****************************************************************************
;*
;* SCANFACE.ASM
;*
;* Object face processing routines.
;*
;* 04.03.1991 - KJB
;* 18.02.1992 - KJB - GOSUB function added.
;*                    IF .. THEN structure modified (end if ptr added).
;*                    IF .. THEN .. ELSE structure modified (end if ptr added).
;*
;* Format of face list (standard functions shown only):-
;*
;* 		DW	count = length of following face data
;*
;*		DB	attrib [,count] [,col1] [,col2] [,v1[,v2 ...]] [,-1]
;*		DB	attrib [,count] [,col1] [,col2] [,v1[,v2 ...]] [,-1]
;*		..        ..      ..       .. 	   ..     ..  ..         ..
;*		DB	attrib [,count] [,col1] [,col2] [,v1[,v2 ...]] [,-1]
;*		DB	-1		;list terminator
;*
;*		EVEN
;*
;* Notes:-
;*
;* "attrib" = face attribute:-
;*
;*    b7 = 0: always zero (prevents attribute = -1 = list terminator)
;*    b6 = X: 1 = extended functions, 0 = standard functions
;*    b5 = D: 1 = decision plane, 0 = standard face
;*    b4 = E: 1 = exclude 2nd path of decision, 0 = include 2nd path of decision
;*    b3 = P: 1 = primary face, 0 = secondary face
;*    b2 = V: 1 = outside / inside visible, 0 = outside visible only
;*    b1 = S: 1 = line structure, 0 = polygon structure
;*    b0 = F: 1 = mesh fill, 0 = solid fill
;*
;* "count" = number of following bytes in face data.
;*
;* "col1" = logical colour of outside face. 
;* 
;* "col2" = logical colour of inside face. 
;*
;* "v1" .. "vn" = vertex values (indices into eye co-ord arrays (ie. Xe[])).
;*
;* "-1" = list terminator.
;*
;* --------------------
;* "standard" functions
;* --------------------
;*
;*    DEPVS = 00000 = secondary face, outside visible only, polygon structure
;*
;*	DB	attrib, count, col1, v1, v2, ... , vn, -1
;*
;*    DEPVS = 00001 = secondary face, outside visible only, line structure
;*
;*	DB	attrib, count, col1, v1, v2, ... , vn, -1
;*
;*    DEPVS = 00010 = secondary face, both sides visible, polygon structure
;*
;*	DB	attrib, count, col1, col2, v1, v2, ... , vn, -1
;*
;*    DEPVS = 00011 = secondary face, both sides visible, line structure
;*
;*	DB	attrib, count, col1, col2, v1, v2, ... , vn, -1
;*
;*    DEPVS = 00100 = primary face, outside visible only, polygon structure
;*
;*	DB	attrib, col1, v1, v2, ... , vn, -1
;*
;*    DEPVS = 00101 = primary face, outside visible only, line structure
;*
;*	DB	attrib, col1, v1, v2, ... , vn, -1
;*
;*    DEPVS = 00110 = primary face, both sides visible, polygon structure
;*
;*	DB	attrib, col1, col2, v1, v2, ... , vn, -1
;*
;*    DEPVS = 00111 = primary face, both sides visible, line structure
;*
;*	DB	attrib, col1, col2, v1, v2, ... , vn, -1
;*
;*    DEPVS = 10000 = secondary decision plane, include 2nd choice
;*
;*	DB	attrib
;*	DW	clockwise ptr add on
;*	DW	anti-clockwise ptr add on
;*
;*	DB	-1 (usually terminate after decision)
;*
;*    DEPVS = 10100 = primary decision plane, include 2nd choice
;*
;*	DB	attrib, v1, v2, ... , vn, -1
;*	DW	clockwise ptr add on
;*	DW	anti-clockwise ptr add on
;*
;*	DB	-1 (usually terminate after decision)
;*
;*    DEPVS = 11000 = secondary decision plane, exclude 2nd choice
;*
;*	DB	attrib
;*	DW	clockwise ptr add on
;*	DW	anti-clockwise ptr add on
;*
;*	DB	-1 (usually terminate after decision)
;*
;*    DEPVS = 11100 = primary decision plane, exclude 2nd choice
;*
;*	DB	attrib, v1, v2, ... , vn, -1
;*	DW	clockwise ptr add on
;*	DW	anti-clockwise ptr add on
;*
;*	DB	-1 (usually terminate after decision)
;*
;* --------------------
;* "extended" functions
;* --------------------
;*
;*    040h = IF .. THEN .. END IF control structure
;*
;*	DB	attrib, mask
;*	DW	ptr add on (end if)
;*	DW	ptr add on (if condition true)
;*
;*    042h = IF .. THEN .. ELSE .. END IF control structure
;*
;*	DB	attrib, mask
;*	DW	ptr add on (end if)
;*	DW	ptr add on (if condition true)
;*	DW	ptr add on (if condition false)
;*
;*    044h = SELECT CASE control structure
;*
;*	DB	attrib, mask, shift count
;*	DW	ptr add on (case end)
;*	DW	ptr add on (case 0)
;*	DW	ptr add on (case 1)
;*	..	..  ..  ..    ..
;*	DW	ptr add on (case n)
;*
;*    046h = GOSUB
;*
;*	DB	attrib
;*	DW	ptr add on (subroutine)
;*
;* Note: "ptr add on" = relative address of branch destination
;*
;****************************************************************************
		
		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	ScanFace

		PUBLIC	DrawRecover

		EXTRN	PolyFill:FAR
		EXTRN	RvrsPolyFill:FAR
		EXTRN	MeshFill:FAR
		EXTRN	RvrsMeshFill:FAR
		EXTRN	PolyLine:FAR

		EXTRN	PolyClip:NEAR
		EXTRN	PolyLineClip:NEAR
		EXTRN	CyclicCheck:NEAR

;============================================================================

		INCLUDE	VISEXTRN.INC
		INCLUDE	\LIB8086\USEFUL.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

;* select face sorting routine wrt attribute

FaceSort	LABEL	WORD

;* "standard" functions

		DW	SortSecPoly1	;0  - 0 0 0 0 0 (D E P V S)
		DW	SortSecLine1	;1  - 0 0 0 0 1
		DW	SortSecPoly2	;2  - 0 0 0 1 0
		DW	SortSecLine2	;3  - 0 0 0 1 1
		DW	SortPrmPoly1	;4  - 0 0 1 0 0
		DW	SortPrmLine1	;5  - 0 0 1 0 1
		DW	SortPrmPoly2	;6  - 0 0 1 1 0
		DW	SortPrmLine2	;7  - 0 0 1 1 1
		DW	Illegal		;8
		DW	Illegal		;9
		DW	Illegal		;10
		DW	Illegal		;11
		DW	Illegal		;12
		DW	Illegal		;13
		DW	Illegal		;14
		DW	Illegal		;15
		DW	SortSecDecInc	;16 - 1 0 0 0 0
		DW	Illegal		;17
		DW	Illegal		;18
		DW	Illegal		;19
		DW	SortPrmDecInc	;20 - 1 0 1 0 0
		DW	Illegal		;21
		DW	Illegal		;22
		DW	Illegal		;23
		DW	SortSecDecExc	;24 - 1 1 0 0 0
		DW	Illegal		;25
		DW	Illegal		;26
		DW	Illegal		;27
		DW	SortPrmDecExc	;28 - 1 1 1 0 0
		DW	Illegal		;29
		DW	Illegal		;30
		DW	Illegal		;31

;* "extended" functions

		DW	IfThen		;32
		DW	IfThenElse	;33
		DW	SelectCase	;34
		DW	Gosub		;35
		DW	Illegal		;36
		DW	Illegal		;37
		DW	Illegal		;38
		DW	Illegal		;39
		DW	Illegal		;40
		DW	Illegal		;41
		DW	Illegal		;42
		DW	Illegal		;43
		DW	Illegal		;44
		DW	Illegal		;45
		DW	Illegal		;46
		DW	Illegal		;47
		DW	Illegal		;48
		DW	Illegal		;49
		DW	Illegal		;50
		DW	Illegal		;51
		DW	Illegal		;52
		DW	Illegal		;53
		DW	Illegal		;54
		DW	Illegal		;55
		DW	Illegal		;56
		DW	Illegal		;57
		DW	Illegal		;58
		DW	Illegal		;59
		DW	Illegal		;60
		DW	Illegal		;61
		DW	Illegal		;62
		DW	Illegal		;63

;* select face drawing routine wrt attribute

FaceDraw	DD	PolyFill	;0 - 0 0 (S F)
		DD	MeshFill	;1 - 0 1
		DD	PolyLine	;2 - 1 0
		DD	PolyLine	;3 - 1 1

RvrsFaceDraw	DD	RvrsPolyFill	;0 - 0 0 (S F)
		DD	RvrsMeshFill	;1 - 0 1

DrawRecover	DW	0

DATA		ENDS

;============================================================================

VISCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:VISCODE
		ASSUME DS:DATA

;* ScanFace - process face data
;*
;* pass: si -> face data
;* ret : si -> next face data
;* kill: assume all (except si)
;*
;* note: This routine is recursive.

ScanFace	PROC	NEAR

NextFace:	lodsb		    	;fetch attribute
		cmp	al,-1		;end of face list?
		je	FlushBuffer	;yes ->

		mov	bl,al
		and	bx,0007eh	;*2 index
		call	FaceSort[bx]

		jmp	NextFace

;* flush all faces in crt buffer (if any)

FlushBuffer:	push	si		;store face data ptr

		mov	si,OFFSET CrtBuffer

FaceLoop:	cmp	si,CrtBufPtr	;any more faces?
		je	ScanFaceExit	;no ->

		lodsw			;fetch attribute / colour
		
		mov	bl,al
		mov	al,ah
		and	bx,0011b
		shl	bx,1	     	;*2
		shl	bx,1		;*4 index

		call	FaceDraw[bx]
		
		jmp	FaceLoop

;* reset crt buffer ptr

ScanFaceExit:	mov	ax,OFFSET CrtBuffer
		mov	CrtBufPtr,ax

		pop	si		;restore face data ptr
		ret

ScanFace	ENDP

;----------------------------------------------------------------------------

;* SortPrmPoly1 - primary face, outside visible only, polygon structure
;*
;* pass: al = face attribute
;*       si -> face data
;*       CrtBufPtr
;* ret : si -> next face data
;*       CrtBufPtr
;*       Cyclic
;* kill: assume all (except si)

SortPrmPoly1	PROC	NEAR

		mov	di,CrtBufPtr

		stosb			;store face attribute

		movsb			;fetch and store outside colour
		
		call	PolyClip
		jc	PrmPolyFail1	;non-visible ->

		push	si
		push	di
		mov	si,CrtBufPtr
		add	si,2		;ignore attribute / colour
		call	CyclicCheck
		pop	di
		pop	si
		js	PrmPolyRvrs1

;* clockwise cyclic, store face, set cyclic

		mov	CrtBufPtr,di

		mov	al,+1		;clockwise cyclic
		mov	Cyclic,al
		ret

;* anti-clockwise cyclic, ignore face, set cyclic

PrmPolyRvrs1:	mov	al,-1		;anti-clockwise cyclic
		mov	Cyclic,al
		ret

;* face non-visible, set invalid cyclic

PrmPolyFail1:  	xor	al,al	 	;invalid cyclic
		mov	Cyclic,al
		ret

SortPrmPoly1	ENDP

;----------------------------------------------------------------------------

;* SortPrmPoly2 - primary face, both sides visible, polygon structure
;*
;* pass: al = face attribute
;*       si -> face data
;*       CrtBufPtr
;* ret : si -> next face data
;*       CrtBufPtr
;*       Cyclic
;* kill: assume all (except si)

SortPrmPoly2	PROC	NEAR

		mov	di,CrtBufPtr

		stosb			;store face attribute

		movsb			;fetch and store outside colour
			
		lodsb			;fetch inside colour
		mov	Col2,al		;store inside colour

		call	PolyClip
		jc	PrmPolyFail2	;non-visible ->

		push	si
		push	di
		mov	si,CrtBufPtr
		add	si,2		;ignore attribute / colour
		call	CyclicCheck
		pop	di

		js	PrmPolyRvrs2

		pop	si

;* clockwise cyclic, store face, set cyclic

		mov	CrtBufPtr,di

		mov	al,+1		;clockwise cyclic
		mov	Cyclic,al
		ret

;* anti-clockwise cyclic, draw face, set cyclic

PrmPolyRvrs2:	mov	si,CrtBufPtr
		
		lodsw			;fetch attribute / colour

		mov	bl,al
		and	bx,0001b
		shl	bx,1		;*2
		shl	bx,1		;*4 index

		mov	al,Col2
		call	RvrsFaceDraw[bx]

		mov	al,-1		;anti-clockwise cyclic
		mov	Cyclic,al

		pop	si
		ret

;* face non-visible, set invalid cyclic

PrmPolyFail2:  	xor	al,al	 	;invalid cyclic
		mov	Cyclic,al
		ret

SortPrmPoly2	ENDP

;----------------------------------------------------------------------------

;* SortSecPoly1 - secondary face, outside visible only, polygon structure
;*
;* pass: al = face attribute
;*       si -> face data
;*       CrtBufPtr
;*       Cyclic
;* ret : si -> next face data
;*       CrtBufPtr
;* kill: assume all (except si)
 
SortSecPoly1	PROC	NEAR

		mov	ah,Cyclic
		test	ah,ah		;cyclic valid and clockwise?
		jle	SecPolyFail1_1	;no ->

		mov	di,CrtBufPtr

		stosb			;store face attribute

		inc	si		;ignore count

		movsb			;fetch and store outside colour
	
		call	PolyClip
		jc	SecPolyFail1_2	;non-visible ->

;* clockwise cyclic, store face

		mov	CrtBufPtr,di
		ret

;* move ptr past face data

SecPolyFail1_1:	lodsb			;fetch count
		xor	ah,ah
		add	si,ax

SecPolyFail1_2:	ret

SortSecPoly1	ENDP

;----------------------------------------------------------------------------

;* SortSecPoly2 - secondary face, both sides visible, polygon structure
;*
;* pass: al = face attribute
;*       si -> face data
;*       CrtBufPtr
;*       Cyclic
;* ret : si -> next face data
;*       CrtBufPtr
;* kill: assume all (except si)

SortSecPoly2	PROC	NEAR

		mov	ah,Cyclic
		test	ah,ah		;cyclic valid?
		jz	SecPolyFail2_1	;no ->

		mov	di,CrtBufPtr

		stosb			;store face attribute

		inc	si		;ignore count

		movsb			;fetch and store outside colour
			
		lodsb			;fetch inside colour
		mov	Col2,al		;store inside colour

		call	PolyClip
		jc	SecPolyFail2_2	;non-visible ->

		mov	al,Cyclic
		test	al,al		;clockwise?
		js	SecPolyRvrs2	;no ->

;* clockwise cyclic, store face

		mov	CrtBufPtr,di
		ret

;* anti-clockwise cyclic, draw face

SecPolyRvrs2:  	push	si

		mov	si,CrtBufPtr

		lodsw			;fetch attribute / colour

		mov	bl,al
		and	bx,0001b
		shl	bx,1		;*2
		shl	bx,1		;*4 index

		mov	al,Col2
		call	RvrsFaceDraw[bx]

		pop	si
		ret

;* move ptr past face data

SecPolyFail2_1: lodsb			;fetch count
		xor	ah,ah
		add	si,ax

SecPolyFail2_2: ret

SortSecPoly2	ENDP

;----------------------------------------------------------------------------

;* SortPrmLine1 - primary face, outside visible only, line structure
;*
;* pass: al = face attribute
;*       si -> face data
;*       CrtBufPtr
;* ret : si -> next face data
;* kill: assume all (except si)

SortPrmLine1	PROC	NEAR

		mov	di,CrtBufPtr

		stosb			;store face attribute

		movsb			;fetch and store outside colour
		
		call	PolyLineClip
		jc	PrmLineFail1	;non-visible ->

		push	si

		mov	si,CrtBufPtr

		lodsw			;fetch attribute / colour

		mov	al,ah
		call	PolyLine

		pop	si

PrmLineFail1:	ret

SortPrmLine1	ENDP

;----------------------------------------------------------------------------

;* SortPrmLine2 - primary face, both sides visible, line structure
;*
;* pass: al = face attribute
;*       si -> face data
;*       CrtBufPtr
;* ret : si -> next face data
;* kill: assume all (except si)

SortPrmLine2	PROC	NEAR

		mov	di,CrtBufPtr

		stosb			;store face attribute

		movsb			;fetch and store outside colour
		
		inc	si		;ignore inside colour
	
		call	PolyLineClip
		jc	PrmLineFail2	;non-visible ->

		push	si

		mov	si,CrtBufPtr

		lodsw			;fetch attribute / colour

		mov	al,ah
		call	PolyLine

		pop	si

PrmLineFail2:	ret

SortPrmLine2	ENDP

;----------------------------------------------------------------------------

;* SortSecLine1 - secondary face, outside visible only, line structure
;*
;* pass: al = face attribute
;*       si -> face data
;*       CrtBufPtr
;*       Cyclic
;* ret : si -> next face data
;*       CrtBufPtr
;* kill: assume all (except si)

SortSecLine1	PROC	NEAR

		mov	ah,Cyclic
		test	ah,ah		;cyclic valid and clockwise?
		jle	SecLineFail1_1	;no ->

		mov	di,CrtBufPtr

		stosb			;store face attribute

		inc	si		;ignore count

		movsb			;fetch and store outside colour
		    
		call	PolyLineClip
		jc	SecLineFail1_2	;non-visible ->

;* clockwise cyclic, store face

		mov	CrtBufPtr,di
		ret

;* move ptr past face data

SecLineFail1_1:	lodsb			;fetch count
		xor	ah,ah
		add	si,ax

SecLineFail1_2:	ret

SortSecLine1	ENDP

;----------------------------------------------------------------------------

;* SortSecLine2 - secondary face, both sides visible, line structure
;*
;* pass: al = face attribute
;*       si -> face data
;*       CrtBufPtr
;*       Cyclic
;* ret : si -> next face data
;*       CrtBufPtr
;* kill: assume all (except si)

SortSecLine2	PROC	NEAR

		mov	ah,Cyclic
		test	ah,ah		;cyclic valid?
		jz	SecLineFail2_1	;no ->

		mov	di,CrtBufPtr

		stosb			;store face attribute

		inc	si		;ignore count

		movsb			;fetch and store outside colour
			
		lodsb			;fetch inside colour
		mov	Col2,al		;store inside colour

		call	PolyLineClip
		jc	SecLineFail2_2	;non-visible ->

		mov	al,Cyclic
		test	al,al		;clockwise?
		js	SecLineRvrs2	;no ->

;* clockwise cyclic, store face

		mov	CrtBufPtr,di
		ret

;* anti-clockwise cyclic, draw face

SecLineRvrs2:	push	si

		mov	si,CrtBufPtr
		add	si,2		;ignore attribute / colour

		mov	al,Col2
		call	PolyLine

		pop	si
		ret

;* move ptr past face data

SecLineFail2_1:	lodsb			;fetch count
		xor	ah,ah
		add	si,ax

SecLineFail2_2:	ret

SortSecLine2	ENDP

;----------------------------------------------------------------------------

;* SortPrmDecInc - primary decision plane, include 2nd choice
;*
;* pass: al = face attribute
;*       si -> face data
;*       CrtBufPtr
;* ret : si -> next face data
;* kill: assume all (except si)

SortPrmDecInc	PROC	NEAR

	  	mov	di,CrtBufPtr

		call	PolyClip
		jc	SortClkWise1 	;non-visible, assume clockwise ->

		push	si
		mov	si,CrtBufPtr
		call	CyclicCheck
		pop	si

		js	SortAClkWise1	;anti-clockwise decision plane ->

;* clockwise cyclic, process clockwise data then anti-clockwise data

SortClkWise1:	mov	al,+1		;clockwise cyclic
		mov	Cyclic,al

		lodsw			;fetch clockwise ptr add on
		push	si
		add	si,ax
		call	ScanFace	;process clockwise data
		pop	si

		lodsw			;fetch anti-clockwise ptr add on
		push	si
		add	si,ax
		call	ScanFace	;process anti-clockwise data
		pop	si

		ret
		
;* anti-clockwise cyclic, process anti-clockwise data then clockwise data

SortAClkWise1:	mov	al,-1		;anti-clockwise cyclic
		mov	Cyclic,al

		lodsw			;fetch clockwise ptr add on
		mov	di,si
		add	di,ax

		lodsw	     		;fetch anti-clockwise ptr add on
		push	si
		push	di

		add	si,ax
		call	ScanFace	;process anti-clockwise data
	
		pop	si
		call	ScanFace	;process clockwise data
		pop	si

		ret

SortPrmDecInc	ENDP

;----------------------------------------------------------------------------

;* SortPrmDecExc - primary decision plane, exclude 2nd choice
;*
;* pass: al = face attribute
;*       si -> face data
;*       CrtBufPtr
;* ret : si -> next face data
;* kill: assume all (except si)

SortPrmDecExc	PROC	NEAR

	  	mov	di,CrtBufPtr

		call	PolyClip
		jc	SortClkWise2 	;non-visible, assume clockwise ->

		push	si
		mov	si,CrtBufPtr
		call	CyclicCheck
		pop	si

		js	SortAClkWise2	;anti-clockwise decision plane ->

;* clockwise cyclic, process clockwise data only

SortClkWise2:	mov	al,+1		;clockwise cyclic
		mov	Cyclic,al

		lodsw			;fetch clockwise ptr add on
		push	si
		add	si,ax
		call	ScanFace	;process clockwise data
		pop	si

		add	si,2		;ignore anti-clockwise ptr add on

		ret
		
;* anti-clockwise cyclic, process anti-clockwise data only

SortAClkWise2:	mov	al,-1		;anti-clockwise cyclic
		mov	Cyclic,al

		add	si,2		;ignore clockwise ptr add on

		lodsw	     		;fetch anti-clockwise ptr add on
		push	si
		add	si,ax
		call	ScanFace	;process anti-clockwise data
		pop	si

		ret

SortPrmDecExc	ENDP

;----------------------------------------------------------------------------

;* SortSecDecInc - secondary decision plane, include 2nd choice
;*
;* pass: al = face attribute
;*       si -> face data
;*       CrtBufPtr
;*       Cyclic
;* ret : si -> next face data
;* kill: assume all (except si)

SortSecDecInc	PROC	NEAR

	  	mov	di,CrtBufPtr

		mov	al,Cyclic
		test	al,al		;cyclic clockwise or invalid?
		js	SortAClkWise3	;no ->

;* clockwise cyclic, process clockwise data then anti-clockwise data

SortClkWise3:	lodsw			;fetch clockwise ptr add on
		push	si
		add	si,ax
		call	ScanFace	;process clockwise data
		pop	si

		lodsw			;fetch anti-clockwise ptr add on
		push	si
		add	si,ax
		call	ScanFace	;process anti-clockwise data
		pop	si

		ret
		
;* anti-clockwise cyclic, process anti-clockwise data then clockwise data

SortAClkWise3:	lodsw			;fetch clockwise ptr add on
		mov	di,si
		add	di,ax

		lodsw	     		;fetch anti-clockwise ptr add on
		push	si
		push	di

		add	si,ax
		call	ScanFace	;process anti-clockwise data
	
		pop	si
		call	ScanFace	;process clockwise data
		pop	si

		ret

SortSecDecInc	ENDP

;----------------------------------------------------------------------------

;* SortSecDecExc - secondary decision plane, exclude 2nd choice
;*
;* pass: al = face attribute
;*       si -> face data
;*       CrtBufPtr
;*       Cyclic
;* ret : si -> next face data
;* kill: assume all (except si)

SortSecDecExc	PROC	NEAR

	  	mov	di,CrtBufPtr

		mov	al,Cyclic
		test	al,al		;cyclic clockwise or invalid?
		js	SortAClkWise4	;no ->

;* clockwise cyclic, process clockwise data only

SortClkWise4:	lodsw			;fetch clockwise ptr add on
		push	si
		add	si,ax
		call	ScanFace	;process clockwise data
		pop	si

		add	si,2		;ignore anti-clockwise ptr add on

		ret
		
;* anti-clockwise cyclic, process anti-clockwise data only

SortAClkWise4:	add	si,2		;ignore clockwise ptr add on

		lodsw	     		;fetch anti-clockwise ptr add on
		push	si
		add	si,ax
		call	ScanFace	;process anti-clockwise data
		pop	si

		ret

SortSecDecExc	ENDP

;----------------------------------------------------------------------------

;* IfThen - IF .. THEN .. END IF control structure
;*
;* pass: si -> face data
;* ret : si -> next face data
;* kill: assume all (except si)

IfThen		PROC	NEAR

		lodsb			;fetch mask
		mov	dl,al

		lodsw			;fetch end if ptr add on
		mov	di,si
		add	di,ax
		
		test	dl,ObjAnimFlags	;condition true?
		jz	CondFalse1	;no ->

		lodsw			;fetch condition true ptr add on
		add	si,ax

		push	di
		call	ScanFace	;process condition true data
		pop	si

		ret

CondFalse1:	mov	si,di

		ret

IfThen		ENDP

;----------------------------------------------------------------------------

;* IfThenElse - IF .. THEN .. ELSE .. END IF control structure
;*
;* pass: si -> face data
;* ret : si -> next face data
;* kill: assume all (except si)

IfThenElse	PROC	NEAR

		lodsb			;fetch mask
		mov	dl,al

		lodsw			;fetch end if ptr add on
		mov	di,si
		add	di,ax

		test	dl,ObjAnimFlags	;condition true?
		jz	CondFalse2	;no ->

		lodsw			;fetch condition true ptr add on
		add	si,ax

		push	di
		call	ScanFace	;process condition true data
		pop	si

		ret

CondFalse2:	add	si,2		;ignore condition true ptr add on

		lodsw			;fetch condition false ptr add on
		add	si,ax

		push	di
		call	ScanFace	;process condition false data
		pop	si

		ret

IfThenElse	ENDP

;----------------------------------------------------------------------------

;* SelectCase - SELECT CASE control structure
;*
;* pass: si -> face data
;* ret : si -> next face data
;* kill: assume all (except si)

SelectCase	PROC	NEAR

		lodsw			;fetch mask, fetch shift count
		mov	dl,al		;mask
		mov	cl,ah		;shift count

		lodsw			;fetch case end ptr add on
		mov	di,si
		add	di,ax

		mov	al,ObjAnimFlags
		shr	al,cl		;shift bit field into low order bits
		and	al,dl		;extract case
		xor	ah,ah
		shl	ax,1		;*2 word index
		add	si,ax
		
		lodsw			;fetch case ptr add on
		add	si,ax
	
		push	di
		call	ScanFace	;process case data
		pop	si

		ret

SelectCase	ENDP

;----------------------------------------------------------------------------

;* Gosub - process block
;*
;* pass: si -> face data
;* ret : si -> next face data
;* kill: assume all (except si)

Gosub		PROC	NEAR

		lodsw			;fetch block ptr

		push	si
		add	si,ax
		call	ScanFace	;process block
		pop	si

		ret

Gosub		ENDP

;----------------------------------------------------------------------------

;* Illegal - handle illegal face attribute (abort object draw)
;*
;* pass: nothing
;* ret : cf = 1 = error
;* kill: nothing

Illegal		PROC	NEAR

		mov	sp,DrawRecover	;recover stack to abort object draw
		stc			;cf = 1 = error
		ret

Illegal		ENDP

VISCODE		ENDS

;============================================================================

		END

