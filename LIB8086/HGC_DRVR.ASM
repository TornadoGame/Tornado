;****************************************************************************
;*
;* HGC_DRVR.ASM
;*
;* Screen dependant routines for Hercules Graphics Card.
;*
;* 28.04.1989 - KJB
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	HGC_VMode
		PUBLIC	HGC_DLoad

		EXTRN	ResetMouse:FAR

		EXTRN	WorkScrPtr:WORD
		EXTRN	RealScrPtr:WORD

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

HGC_REAL_SCR	EQU	0b000h		;HGC segment ptr

HGC_CRTC   	EQU	003b4h		;CRT controller reg
HGC_MODE 	EQU	003b8h		;Hercules mode control reg
HGC_CONFIG  	EQU	003bfh		;Hercules configuration switch reg

;* HGC default CRTC register values
;*
;* There is no BIOS video mode initialize for the Hecules card so we have 
;* to set the CRTC defaults ourselves. These default values were taken
;* from F-16 Combat Pilot. I do not know where they originally came from.

HGC_InitVal	DB	035h		;horizontal total
		DB	02dh		;horizontal displayed
		DB	02eh		;horizontal sync position
		DB	007h		;horizontal sync pulse width
		DB	05bh		;vertical total
		DB	002h		;vertical total adjust
		DB	057h		;vertical displayed
		DB	057h		;vertical sync position
		DB	002h		;interlace mode
		DB	003h		;maximum scan line
		DB	000h		;cursor start
		DB	000h		;cursor end

DATA		ENDS

;============================================================================

WSDATA		SEGMENT PARA PUBLIC 'DATA'

WSDATA		ENDS

;============================================================================

GCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:GCODE
		ASSUME DS:DATA

;* HGC_VMode - set video mode
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all
;*
;* note: Reset mouse immediately after setting video mode (see MOUSE.ASM).

HGC_VMode	PROC	FAR

		mov	dx,HGC_CONFIG
		mov	al,00000001b	;enable graphics mode
		out	dx,al

		mov	dx,HGC_MODE
		mov	al,00000010b	;720 * 350 graphics mode
		out	dx,al

		mov	si,OFFSET HGC_InitVal
		xor	ah,ah
		mov	cx,12
		mov	dx,HGC_CRTC

VidInitLp:	mov	al,ah	 	;select CRTC register
		out	dx,al

		lodsb
		inc	dx
		out	dx,al		;set CRTC register value

		inc	ah
		dec	dx
		loop	VidInitLp	

;* clear screen

		push	es
		mov	ax,HGC_REAL_SCR
		mov	es,ax
		xor	ax,ax
		mov	di,00000h
		mov	cx,3915
		rep	stosw
		mov	di,02000h
		mov	cx,3915
		rep	stosw
	 	mov	di,04000h
		mov	cx,3915
		rep	stosw
	 	mov	di,06000h
		mov	cx,3915
		rep	stosw
		pop	es
 
		mov	dx,HGC_MODE
		mov	al,00011010b	;video enabled
		out	dx,al

		call	ResetMouse
		
		mov	ax,WSDATA    	;system memory work screen
		mov	WorkScrPtr,ax
		mov	ax,HGC_REAL_SCR
		mov	RealScrPtr,ax

		ret

HGC_VMode	ENDP

;----------------------------------------------------------------------------

;* HGC_DLoad - download work screen to real screen
;*
;* pass: WorkScrPtr
;*       RealScrPtr
;* ret : nothing
;* kill: ax, bx, cx, dx, si, di, bp, flags

;* This routine downloads the 200 * 320 linear CGA dummy screen into the
;* 720 * 350 Hercules screen. The simplest way to increase the number of
;* lines is to load each even CGA line into two Hercules lines and load
;* each odd CGA line into a Hercules line. This give 300 lines in total.
;*
;* The CGA screen has 2 bits / pixel giving 640 bits / line. This almost
;* corresponds with the Hercules 720 pixels / line. We need only offset
;* the start of each Hercules line to centralize the screen.

HGC_DLoad	PROC	FAR

		push	ds	
		push	es

		mov	ax,RealScrPtr
		mov 	es,ax
		mov 	ax,WorkScrPtr
		mov 	ds,ax

		mov	ax,40	   
		mov	bx,80
		mov	dx,200/8
		mov	bp,02000h-80

		xor 	si,si
		mov 	di,5

CopyLoop:	mov 	cx,ax		;copy line 0 to line 0
		rep 	movsw

		sub 	si,bx		;copy line 0 to line 1
		add 	di,bp
     		mov 	cx,ax
		rep 	movsw	 

		add 	di,bp		;copy line 1 to line 2
     		mov 	cx,ax
		rep 	movsw	

		add 	di,bp		;copy line 2 to line 3
		mov 	cx,ax
		rep 	movsw 

		sub	si,bx		;copy line 2 to line 4
		sub	di,05ff6h
     		mov 	cx,ax
		rep 	movsw
	
		add	di,bp		;copy line 3 to line 5
     		mov 	cx,ax
		rep 	movsw	

		add	di,bp		;copy line 4 to line 6
		mov	cx,ax
		rep 	movsw 

		sub	si,bx		;copy line 4 to line 7
		add	di,bp
     		mov	cx,ax
		rep	movsw	

		sub	di,05ff6h	;copy line 5 to line 8
     		mov 	cx,ax
		rep	movsw	

		add	di,bp		;copy line 6 to line 9
		mov 	cx,ax
		rep	movsw 

		sub	si,bx 		;copy line 6 to line 10
		add	di,bp
     		mov	cx,ax
		rep 	movsw	

		add 	di,bp		;copy line 7 to line 11
     		mov 	cx,ax
		rep	movsw	

		sub	di,05ff6h

		dec 	dx
		jnz	CopyLoop

		pop	es
		pop	ds
		ret

HGC_DLoad	ENDP

GCODE		ENDS

;============================================================================

		END



