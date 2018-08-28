;****************************************************************************
;*
;* TEM_DRVR.ASM
;*
;* Screen dependant routines for emulating Tandy graphics on EGA.
;*
;* 06.06.1989 - KJB
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	TEM_VMode
		PUBLIC	TEM_DLoad

		PUBLIC	SetUpEGATable
		PUBLIC	ConvTANToEGA

		EXTRN	ResetMouse:FAR

		EXTRN	WorkScrPtr:WORD
		EXTRN	RealScrPtr:WORD

;============================================================================

		INCLUDE	EGA_DRVR.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

TEM_REAL_SCR	EQU	0a000h		;TEM segment ptr

TEM_LINEADD	EQU	40		;40 bytes / line

DATA		ENDS

;============================================================================

WSDATA		SEGMENT PARA PUBLIC 'DATA'

PixTable 	DB 	00h,80h,20h,0a0h
		DB	08h,88h,28h,0a8h
		DB	02h,82h,22h,0a2h
		DB	0ah,8ah,2ah,0aah

EGATable 	DB	00100h DUP(0)

WSDATA		ENDS

;============================================================================

GCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:GCODE
		ASSUME DS:DATA

;* TEM_VMode - set video mode
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all
;*
;* note: Reset mouse immediately after setting video mode (see MOUSE.ASM).

TEM_VMode	PROC	FAR

		mov	ah,0 		;service 0, set video mode
		mov	al,00dh		;320 * 200, 16 colour
		int	010h		;BIOS

		call	ResetMouse

		mov	ax,WSDATA    	;system memory work screen
		mov	WorkScrPtr,ax
		mov	ax,TEM_REAL_SCR
		mov	RealScrPtr,ax

		call	FAR PTR SetUpEGATable

		ret

TEM_VMode	ENDP

;----------------------------------------------------------------------------

;* TEM_DLoad - download work screen to real screen
;*
;* pass: WorkScrPtr
;*       RealScrPtr
;* ret : nothing
;* kill: ax, bx, cx, dx, si, di, bp, flags
 
TEM_DLoad	PROC	FAR
		
		push	ds
		push	es

		mov	ax,RealScrPtr	
		mov	es,ax
		mov	ax,WorkScrPtr
		mov	ds,ax

		xor	si,si
		xor	di,di

		call	FAR PTR ConvTANToEGA

		pop	es
		pop	ds
		ret

TEM_DLoad	ENDP

;----------------------------------------------------------------------------

;* SetUpEGATable
;*
;* pass: nothing
;* ret : EGATable[]
;* kill: ax, bx, cx, dx, flags

SetUpEGATable	PROC	FAR

		push	ds

		mov	ax,WSDATA
		mov	ds,ax

		ASSUME DS:WSDATA

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

		pop	ds

		ASSUME DS:DATA

		ret

SetUpEGATable	ENDP

;----------------------------------------------------------------------------

;* ConvTANToEGA - convert TAN format screen into EGA format
;*
;* pass: ds:si -> TAN screen (must be in WSDATA segment)
;*       es:di -> EGA screen
;* ret : nothing
;* kill: assume all

ConvTANToEGA	PROC	FAR

		SETREGV	EGA_CTRL,EGA_CTRL_ENABLE,000h

		SETREGV	EGA_CTRL,EGA_CTRL_BITMSK,0ffh

		SLCTREG	EGA_SEQ,EGA_SEQ_MAPMSK

		mov	bx,OFFSET EGATable
		mov	bp,200

CopyLoop:    	push	bp

		mov	bp,TEM_LINEADD

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

		pop	bp
		dec	bp
		jnz	CopyLoop
	
		SETREGV	EGA_SEQ,EGA_SEQ_MAPMSK,00fh

		SETREGV	EGA_CTRL,EGA_CTRL_ENABLE,00fh

		ret

ConvTANToEGA	ENDP

GCODE		ENDS

;============================================================================

		END

