;****************************************************************************
;*
;* CGA_SCR.ASM
;*
;* 06.07.1989 - KJB
;*
;****************************************************************************

		PUBLIC	CGA_VMode
		PUBLIC	CGA_DLoad

		EXTRN	WorkScrPtr:WORD
		EXTRN	RealScrPtr:WORD

		EXTRN	WorkScreen:BYTE

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

CGA_REAL_SCR	EQU	0b800h		;CGA segment ptr
CGA_LINEADD	EQU	80		;80 bytes / line

DATA		ENDS

;============================================================================

CODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:CODE
		ASSUME DS:DATA

;* CGA_VMode set CGA video mode
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

CGA_VMode	PROC	NEAR

		mov	ah,0 		;service 0, set video mode
		mov	al,004h		;320 * 200, 4 colour
		int	010h		;BIOS
		mov	ax,SEG WorkScreen

		mov	WorkScrPtr,ax
		mov	ax,CGA_REAL_SCR
		mov	RealScrPtr,ax

		ret

CGA_VMode	ENDP

;----------------------------------------------------------------------------

;* CGA_DLoad - CGA down load
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

CGA_DLoad	PROC	NEAR

		push	ds
		push	es

		mov	ax,RealScrPtr	
		mov	es,ax
		mov	ax,WorkScrPtr
		mov	ds,ax

		xor	si,si
		xor	di,di

		mov	ax,100
		mov	bx,02000h-CGA_LINEADD
		mov	dx,02000h
		mov	bp,CGA_LINEADD

CGACopyLoop:	mov	cx,bp		;copy even line
		rep	movsb
		add	di,bx
		mov	cx,bp		;copy odd line
		rep	movsb		
		sub	di,dx
		dec	ax
		jnz	CGACopyLoop

		pop	es
		pop	ds
		ret

CGA_DLoad	ENDP

CODE		ENDS

;============================================================================

		END

