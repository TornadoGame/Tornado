;****************************************************************************
;*
;* TEM_SCR.ASM
;*
;* 06.07.1989 - KJB
;*
;****************************************************************************

		PUBLIC	TEM_VMode
		PUBLIC	TEM_DLoad
		PUBLIC	DeltaTable

		EXTRN	WorkScrPtr:WORD
		EXTRN	RealScrPtr:WORD

		EXTRN	WorkScreen:BYTE

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

TEM_REAL_SCR	EQU	0a000h		;TEM segment ptr
TEM_LINEADD	EQU	40		;40 bytes / line

EGA_SEQ		EQU	003c4h
EGA_SEQ_MAPMSK	EQU	002h		;xxxxIRGB

PixTable 	DB 	00h,80h,20h,0a0h
		DB	08h,88h,28h,0a8h
		DB	02h,82h,22h,0a2h
		DB	0ah,8ah,2ah,0aah

EGATable 	DB	00100h DUP(0)

DeltaTable	DB	200 DUP(0)

DATA		ENDS

;============================================================================

CODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:CODE
		ASSUME DS:DATA

;* TEM_VMode - set Tandy Emulation video mode
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

TEM_VMode	PROC	NEAR

		mov	ah,0 		;service 0, set video mode
		mov	al,00dh		;320 * 200, 16 colour
		int	010h		;BIOS

		mov	ax,SEG WorkScreen
		mov	WorkScrPtr,ax
		mov	ax,TEM_REAL_SCR
		mov	RealScrPtr,ax

;* initialize EGA table

		mov	cx,0ffh

SetYLoop:	mov	bx,cx
		and	bl,0fh
		mov	dl,PixTable[bx]
		shr	dl,1

		mov	bx,cx
		shr	bl,1
		shr	bl,1
		shr	bl,1
		shr	bl,1
		or	dl,PixTable[bx]
		
		mov	bx,cx
		mov	EGATable[bx],dl
       	
		loop	SetYLoop
		mov	EGATable[0],cl

		ret

TEM_VMode	ENDP

;----------------------------------------------------------------------------

;* TEM_DLoad - download work screen to real screen
;*
;* pass: WorkScrPtr
;*       RealScrPtr
;* ret : nothing
;* kill: assume all
 
TEM_DLoad	PROC	NEAR
		
		push	ds
		push	es

		mov	ax,RealScrPtr	
		mov	es,ax
		mov	ax,WorkScrPtr
		mov	ds,ax

		xor	si,si
		xor	di,di

		mov 	dx,EGA_SEQ
		mov 	al,EGA_SEQ_MAPMSK
		out 	dx,al
		inc	dx		

		mov	bx,OFFSET EGATable
		xor	bp,bp

TEMCopyLoop:    push	bp
	 	mov	al,ds:DeltaTable[bp]
		test	al,al
		jnz	DoLine
		add	si,160
       		add	di,TEM_LINEADD
		jmp	SkipLine

DoLine:		mov	bp,TEM_LINEADD

NextByte:	mov	al,01h		;write map 0
		out	dx,al		;write map 0

		lodsw
		xlat
		xchg	al,ah
		xlat
		mov	cx,ax

		lodsw
		xlat
		xchg	al,ah
		xlat

		rol	ch,1
		rol	ch,1

		rol	cx,1
		rol	cx,1

		rol	cl,1
		rol	cl,1

		xchg	cl,ah

		rol	cx,1
		rol	cx,1
       	
		xchg	ch,ah

		rol	cx,1
		rol	cx,1

		rol	cl,1
		rol	cl,1

		rol	ax,1
		rol	ax,1

		xchg	al,ah
		mov	es:[di],al	;output plane 0
		mov	al,02h		;write map 1
		out	dx,al		;write map 1
		xchg	al,ah	

		xchg	ah,ch

		rol	ax,1
		rol	ax,1

		xchg	al,ah		
		mov	es:[di],al	;output plane 1
		mov	al,04h		;write map 2
		out	dx,al		;write map 2
		xchg	al,ah

		xchg	ah,cl

    		rol	ax,1
    		rol	ax,1

		xchg	al,ah
		mov	es:[di],al	;output plane 2
		mov	al,08h		;write map 3
		out	dx,al		;write map 3
		xchg	al,ah
		
		rol	al,1
		rol	al,1

		stosb			;output plane 3

		dec	bp
		jnz	NextByte

SkipLine:	pop	bp
		inc	bp
		cmp	bp,200
		jne	TEMCopyLoop

		pop	es
		pop	ds

		xor	al,al
		mov	cx,200
		mov	di,OFFSET DeltaTable
		rep	stosb

		ret

TEM_DLoad	ENDP

CODE		ENDS

;============================================================================

		END

