;****************************************************************************
;*
;* DELUXE.ASM
;*
;* 06.07.1989 - KJB
;*
;****************************************************************************

		PUBLIC	LoadPicFile
		PUBLIC	DiskError
		PUBLIC	UnCompress
		PUBLIC	SortRaw

		EXTRN	LoadFile:FAR
		EXTRN	AbortToDOS:FAR

		EXTRN	SSTemp:WORD
		EXTRN	SPTemp:WORD
		EXTRN	ScreenType:WORD

		EXTRN	Key:BYTE
		EXTRN	RdFileName:BYTE
		EXTRN	DiskBuffer:BYTE
		EXTRN	WorkScreen:BYTE
		EXTRN	DataMarker:BYTE

		EXTRN	BUF_SIZE:ABS

;============================================================================

		INCLUDE	KEYS.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

BEL		EQU	7
CR		EQU	13
LF		EQU	10

DiskErr$	DB	BEL,"DISK ERROR!!! - HIT ESC",CR,LF
		DB	'$'

		EVEN

CGABitTable	DB	00000000b
		DB	00000011b
		DB	00001100b
		DB	00001111b
		DB	00110000b
		DB	00110011b
		DB	00111100b
		DB	00111111b
		DB	11000000b
		DB	11000011b
		DB	11001100b
		DB	11001111b
		DB	11110000b
		DB	11110011b
		DB	11111100b
		DB	11111111b

EGABitTable0	DB	00000000b
		DB	00000001b
		DB	00010000b
		DB	00010001b

EGABitTable1	DB	00000000b
		DB	00000010b
		DB	00100000b
		DB	00100010b

EGABitTable2	DB	00000000b
		DB	00000100b
		DB	01000000b
		DB	01000100b

EGABitTable3	DB	00000000b
		DB	00001000b
		DB	10000000b
		DB	10001000b

_SortRaw	DW	SortRawCGA
		DW	SortRawEGA

DATA		ENDS

;============================================================================

CODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:CODE
		ASSUME DS:DATA

;* LoadPicFile - load picture file
;*
;* pass: RdFileName
;* ret : DiskBuffer[] stores file data
;* kill: assume all

LoadPicFile	PROC	NEAR

		push	es

		mov	cx,BUF_SIZE
		mov	dx,OFFSET RdFileName
		mov	ax,SEG DiskBuffer
		mov	es,ax
		mov	di,OFFSET DiskBuffer

		call	LoadFile

		pop	es

		jc	LoadPicError
		ret

LoadPicError:	jmp	DiskError

LoadPicFile	ENDP

;----------------------------------------------------------------------------

;* DiskError - piss poor disk error handling!!!
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

DiskError	PROC	NEAR

		mov	ax,DATA
		mov	ds,ax
		mov	es,ax

		mov	ah,0		;80*25 Alpha mode
		mov	al,3
		int	010h

		mov	ah,9
		mov	dx,OFFSET DiskErr$
		int	021h

ErrorWait:	mov	al,Key[K_ESC]
		test	al,al
		jz	ErrorWait

		cli
		mov	ax,SPTemp
		mov	sp,ax
		mov	ax,SSTemp
		mov	ss,ax
		sti

		jmp	AbortToDOS

DiskError	ENDP

;----------------------------------------------------------------------------

;* UnCompress - uncompress RLE data
;*
;* pass: DiskBuffer[] = compressed data
;* ret : WorkScreen[] = uncompressed data
;* kill: assume all
;*
;* Run Length Encoding format:-
;*
;*  0 ... +127: copy the next n + 1 bytes literally
;* -1 ... -127: copy the next byte -n + 1 times
;*        -128: no operation
;*
;* I have modified this format so that now -128 signals the following counter
;* as being a 16-bit value. Hopefully this should improve the compression.

UnCompress	PROC	NEAR

		push	ds
		push	es

		mov	ax,SEG DiskBuffer
		mov	ds,ax
		mov	si,offset DiskBuffer

		mov	ax,SEG WorkScreen
		mov	es,ax
		mov	di,OFFSET WorkScreen

		lodsw			;length of data
		mov	bp,ax
		add	bp,si		;ds:bp -> end of data + 1

NextChar:	lodsb	      		;fetch counter
		cbw	
		cmp	ax,-128		;16-bit counter following?
		jne	TestCntrType	;no ->
		lodsw			;fetch 16-bit counter	

TestCntrType:	test	ax,ax
		js	BlockFill

		mov	cx,ax
		inc	cx
		rep	movsb
		jmp	Skip

BlockFill:	neg	ax
		mov	cx,ax
		inc	cx
		lodsb
		rep	stosb

Skip:	       	cmp	si,bp
		jb	NextChar

		pop	es
		pop	ds

		ret

UnCompress	ENDP

;----------------------------------------------------------------------------

;* SortRaw - uncompress raw screen data
;*
;* pass: ScreenType
;* ret : uncompressed data in WorkScreen[]
;* kill: assume all

SortRaw		PROC	NEAR
		
		mov	bx,ScreenType
		call	_SortRaw[bx]
		ret

SortRaw		ENDP

;----------------------------------------------------------------------------

;* SortRawCGA - uncompress raw CGA data from Deluxe Paint LBM format
;*
;* pass: raw CGA data in DiskBuffer[]
;* ret : CGA data in WorkScreen[]
;* kill: assume all
;*
;* Format of LBM data:-
;*
;*    Data stored line by line using RLE format. However, the data is split
;*    into two planes.

SortRawCGA	PROC	NEAR

		push	ds
		push	es

;* search for data marker

		mov	bx,WORD PTR [DataMarker]
		mov	cx,WORD PTR [DataMarker+2]

		mov	ax,SEG DiskBuffer
		mov	ds,ax
		mov	si,offset DiskBuffer

CGASearchOn:	mov	al,[si+0]
		cmp	al,bl
		jne	CGANextData
		mov	al,[si+1]	
		cmp	al,bh
		jne	CGANextData
		mov	al,[si+2]
		cmp	al,cl
		jne	CGANextData
		mov	al,[si+3]	
		cmp	al,ch
		je	CGAFoundMarker
CGANextData:	inc	si
		cmp	si,BUF_SIZE
		jb	CGASearchOn
	 	jmp	DiskError

CGAFoundMarker:	add	si,8		;ds:si -> start of data

;* clear WorkScreen

		mov	ax,SEG WorkScreen
		mov	es,ax
		mov	di,OFFSET WorkScreen

		xor	ax,ax
		mov	cx,200*80/2
		rep	stosw

		mov	di,OFFSET WorkScreen

;* now uncompress the data

		xor	bx,bx

CGANextLine:	mov	bp,di 		;store line ptr

		mov	dh,01010101b

CGANextPlane:	xor	dl,dl		;counter
		mov	di,bp

CGANextChar:	lodsb
		test	al,al
		js	CGABlockFill

		mov	cl,al
		xor	ch,ch
		inc	cx
		add	dl,cl

CGACopyLoop:	lodsb
		mov	ah,al
		and	al,00fh
		mov	bl,al
		mov	al,es:CGABitTable[bx]
		and	al,dh
		xchg	al,ah
		shr	al,1
		shr	al,1
		shr	al,1
		shr	al,1
		mov	bl,al
		mov	al,es:CGABitTable[bx]
		and	al,dh
		or	es:[di],ax
		add	di,2
		loop	CGACopyLoop
		jmp	CGASkip

CGABlockFill:	cmp	al,-128
		je	CGASkip

		neg	al
		mov	cl,al
		xor	ch,ch
		inc	cx
		add	dl,cl

		lodsb
		mov	ah,al
		and	al,00fh
		mov	bl,al
		mov	al,es:CGABitTable[bx]
		and	al,dh
		xchg	al,ah
		shr	al,1
		shr	al,1
		shr	al,1
		shr	al,1
		mov	bl,al
		mov	al,es:CGABitTable[bx]
		and	al,dh
		
CGABlockLoop:	or	es:[di],ax
		add	di,2
		loop	CGABlockLoop

CGASkip:       	cmp	dl,40
		jb	CGANextChar

		rol	dh,1
		cmp	dh,01010101b
		jne	CGANextPlane	
	
		mov	di,bp
		add	di,80
		cmp	di,200*80
		jae	CGADone
		jmp	CGANextLine

CGADone:	pop	es
		pop	ds

		ret

SortRawCGA	ENDP

;----------------------------------------------------------------------------

;* SortRawEGA - uncompress raw EGA data from Deluxe Paint LBM format
;*
;* pass: raw EGA data in DiskBuffer[]
;* ret : TAN data in WorkScreen[]
;* kill: assume all
;*
;* Format of LBM data:-
;*
;*    Data stored line by line using RLE format. However, the data is split
;*    into four planes.

SortRawEGA	PROC	NEAR

		push	ds
		push	es

;* search for data marker

		mov	bx,WORD PTR [DataMarker]
		mov	cx,WORD PTR [DataMarker+2]

		mov	ax,SEG DiskBuffer
		mov	ds,ax
		mov	es,ax
		mov	si,offset DiskBuffer

EGASearchOn:	mov	al,[si+0]
		cmp	al,bl
		jne	EGANextData
		mov	al,[si+1]	
		cmp	al,bh
		jne	EGANextData
		mov	al,[si+2]
		cmp	al,cl
		jne	EGANextData
		mov	al,[si+3]	
		cmp	al,ch
		je	EGAFoundMarker
EGANextData:	inc	si
		cmp	si,BUF_SIZE
		jb	EGASearchOn
	 	jmp	DiskError

EGAFoundMarker:	add	si,6		;ds:si -> start of data

		mov	ax,[si]		;sort out length of file
		xchg	al,ah
		mov	[si],ax
		mov	cx,ax
		add	cx,2

;* copy data to start of DiskBuffer[]

		mov	di,offset DiskBuffer

		rep	movsb

		call	EGAUnCompress

		mov	ax,SEG WorkScreen
		mov	ds,ax
		mov	si,OFFSET WorkScreen

		mov	ax,SEG DiskBuffer
		mov	es,ax
		mov	di,OFFSET DiskBuffer

		mov	cx,200*160/2
		rep	movsw

		mov	ax,SEG DiskBuffer
		mov	ds,ax
		mov	si,OFFSET DiskBuffer
		
		mov	ax,SEG WorkScreen
		mov	es,ax
		mov	di,OFFSET WorkScreen

;* clear work screen

		xor	ax,ax
		mov	cx,200*160/2
		rep	stosw

		mov	di,OFFSET WorkScreen

		mov	cx,200

EGALoop1:	push	cx

		mov	cx,4
		mov	dx,OFFSET EGABitTable0
EGALoop2:	push	cx
		push	di

		mov	cx,40

EGALoop3:	lodsb
		mov	ah,al
	
		and	al,11000000b
		rol	al,1
		rol	al,1
		mov	bx,dx
		add	bl,al
		adc	bh,0
		mov	al,es:[bx]
		or	es:[di+0],al

		mov	al,ah
		and	al,00110000b
		shr	al,1
		shr	al,1
		shr	al,1
		shr	al,1
		mov	bx,dx
		add	bl,al
		adc	bh,0
		mov	al,es:[bx]
		or	es:[di+1],al

		mov	al,ah
		and	al,00001100b
		shr	al,1
		shr	al,1
		mov	bx,dx
		add	bl,al
		adc	bh,0
		mov	al,es:[bx]
		or	es:[di+2],al

		mov	al,ah
	       	and	al,00000011b
		mov	bx,dx
		add	bl,al
		adc	bh,0
		mov	al,es:[bx]
		or	es:[di+3],al

		add	di,4
		loop	EGALoop3

		pop	di
		pop	cx
		add	dx,4
		loop	EGALoop2
		add	di,160

		pop	cx
		loop	EGALoop1

		pop	es
		pop	ds

		ret

SortRawEGA	ENDP

;----------------------------------------------------------------------------

;* EGAUnCompress - uncompress RLE data
;*
;* pass: DiskBuffer[] = compressed data
;* ret : WorkScreen[] = uncompressed data
;* kill: assume all
;*
;* Run Length Encoding format:-
;*
;*  0 ... +127: copy the next n + 1 bytes literally
;* -1 ... -127: copy the next byte -n + 1 times
;*        -128: no operation

EGAUnCompress	PROC	NEAR

		push	ds
		push	es

		mov	ax,SEG DiskBuffer
		mov	ds,ax
		mov	si,offset DiskBuffer

		mov	ax,SEG WorkScreen
		mov	es,ax
		mov	di,OFFSET WorkScreen

		lodsw			;length of data
		mov	bp,ax
		add	bp,si		;ds:bp -> end of data + 1

EGANextChar:	lodsb
		test	al,al
		js	EGABlockFill

		mov	cl,al
		xor	ch,ch
		inc	cx
		rep	movsb
		jmp	EGASkip

EGABlockFill:	cmp	al,-128
		je	EGASkip

		neg	al
		mov	cl,al
		xor	ch,ch
		inc	cx
		lodsb
		rep	stosb

EGASkip:       	cmp	si,bp
		jb	EGANextChar

		pop	es
		pop	ds

		ret

EGAUnCompress	ENDP

CODE		ENDS

;============================================================================

		END

