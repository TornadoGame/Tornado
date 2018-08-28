;****************************************************************************
;*
;* MEMSIZE.ASM - KJB - 24.05.1990
;*
;*
;* How big is my memory?
;*
;****************************************************************************

		public	VGA
		public	BREAK	
		public	DUMP
		public	DUMP2

;----------------------------------------------------------------------------

stack		segment para stack 'stack'
		assume ss:stack

		db	0200h dup(0)

stack		ends							

;----------------------------------------------------------------------------

data		segment para public 'data'
		assume ds:data

dump		db	3*256 dup("-")
		db	"HELLO KEV"

dump2		db	17 dup("-")
		db	"HELLO KEV"

data		ends

;----------------------------------------------------------------------------

code		segment byte public 'code'
		assume cs:code

VGA:	

;==========
;* PREAMBLE
;==========

		push	ds    		;save program segment prefix seg addr
		mov	ax,0			
		push	ax    		;save return address offset (PSP + 0)

		mov	ax,ds
		mov	bx,ax

		mov	ax,data		
		mov	ds,ax
		mov	es,ax

		cld	      		;si, di auto-increment

		mov	ah,0 		;service 0, set video mode
		mov	al,00dh		;320 * 200, 16 colour
		int	010h		;BIOS

BREAK:	       ;	mov	ah,010h
	       ;	mov	al,017h
	       ;	mov	bx,0
	       ;	mov	cx,256
	       ;	mov	dx,offset dump
	       ;	int	010h

		mov	ah,010h
		mov	al,009h
		mov	dx,offset dump2
		int	010h

		mov	ah,0 		;service 0, set video mode
		mov	al,003h		;320 * 200, 16 colour
		int	010h		;BIOS

		retf			;return to DOS

code		ends					      	

		end 	VGA

