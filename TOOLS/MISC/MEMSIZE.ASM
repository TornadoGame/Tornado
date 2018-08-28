;****************************************************************************
;*
;* MEMSIZE.ASM - KJB - 24.05.1990
;*
;*
;* How big is my memory?
;*
;****************************************************************************

		public	Memsize

;----------------------------------------------------------------------------

stack		segment para stack 'stack'
		assume ss:stack

		db	0200h dup(0)

stack		ends							

;----------------------------------------------------------------------------

data		segment para public 'data'
		assume ds:data

HexChars	DB	"0123456789ABCDEF"

data		ends

;----------------------------------------------------------------------------

code		segment byte public 'code'
		assume cs:code

Memsize:	

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

		mov	ah,048h		;alloc mem
		mov	bx,00010h	;can handle this
		int	021h
		cmp	ax,7
		je	ohno
		cmp	ax,8
		je	ohno

		mov	es,ax

		mov	ah,04ah		;alloc mem
		mov	bx,0ffffh	;can't handle this!!!
		int	021h

		mov	ax,bx

		push	bx
		push	dx

		mov	bx,OFFSET HexChars

		push	ax
		mov	al,ah
		shr	al,1
		shr	al,1
		shr	al,1
		shr	al,1
		xlat
		mov	dl,al
		mov	ah,2
		int	021h
		pop	ax

		push	ax
		mov	al,ah
		and	al,00fh
		xlat
		mov	dl,al
		mov	ah,2
		int	021h
		pop	ax

		push	ax
		shr	al,1
		shr	al,1
		shr	al,1
		shr	al,1
		xlat
		mov	dl,al
		mov	ah,2
		int	021h
		pop	ax

		push	ax
		and	al,00fh
		xlat
		mov	dl,al
		mov	ah,2
		int	021h
		mov	dl,' '
		mov	ah,2
		int	021h
		pop	ax

		pop	dx
		pop	bx

ohno:		retf			;return to DOS

code		ends					      	

		end 	Memsize

