		public 	Counter
		public	DEBUG1
		public	DEBUG2
			
;----------------------------------------------------------------------------

stack		segment para stack 'stack'
		assume ss:stack

		db	0200h dup(0)

stack		ends							

;----------------------------------------------------------------------------

data		segment para public 'data'

tmrvctr	equ	020h			;timer interrupt vector

fiftyhz	equ	23864			;timer value for 50Hz

vctrtbl	db	64 dup(0)		;copy of intr vector table

Counter		dw	0

StringAll	db	13,10,'0'

String		db	'1234h','$'

		even

Hex		db	'0123456789ABCDEF'

data		ends

;----------------------------------------------------------------------------

code		segment byte public 'code'
		assume cs:code
		assume ds:data

Test:		cli  

		push	ds   
		mov	ax,0			
		push	ax   

		cld	     

		mov	ax,0	    
		mov	ds,ax
		mov	ax,data	    
		mov	es,ax
		mov	si,000h		     
		mov	di,offset vctrtbl    
		mov	cx,32		     
		rep	movsw		     
		mov	ax,data
		mov	ds,ax		     
		mov	es,ax		     

		push	es

		mov	ax,0  	     
		mov	es,ax

		mov	di,tmrvctr	 
		mov	ax,offset Int50
		stosw
		mov	ax,cs
		stosw

		mov	al,036h			;set timer channel 0 to 50hz
		out	043h,al 
		mov	bx,fiftyhz
		mov	al,bl
		out	040h,al
		mov	al,bh
		out	040h,al

		mov	al,0			;enable IRQ0 -> IRQ7
		out	021h,al
		mov	al,0   			;enable IRQ8 -> IRQF
		out	0a1h,al

		pop	es
		sti

;----------------------------------------------------------------------------

DEBUG1:		mov	bp,-1
		mov	cl,2

loop1:

		REPT	100
		rol	al,cl
		ENDM

		dec	bp
		jz	DEBUG2
		jmp	loop1

DEBUG2:		mov	bx,offset Hex
		mov	cx,4
		mov	dx,Counter
		mov	di,offset String
	
here:		xor	ax,ax
		shl	dx,1
		rcl	ax,1
		shl	dx,1
		rcl	ax,1
		shl	dx,1
		rcl	ax,1
		shl	dx,1
		rcl	ax,1
		xlat	
		stosb
		loop	here
		
		mov	ah,9		
    		mov	dx,offset StringAll
		int	33
		
;----------------------------------------------------------------------------
		
		cli

		mov	al,036h	 	;set timer channel 0 to 18.2Hz
		out	043h,al 
		mov	bx,0
		mov	al,bl
		out	040h,al
		mov	al,bh
		out	040h,al

		mov	ax,data		    
		mov	ds,ax
		mov	ax,0 		    
		mov	es,ax
		mov	si,offset vctrtbl   
		mov	di,000h		    
		mov     cx,32		    
		rep	movsw		    
		sti

TestEnd:	retf

Int50:		push	ax
		push	ds

		mov	ax,data 
		mov	ds,ax
	       	inc	Counter
	 	mov 	al,020h	 
      		out 	020h,al	 

		pop	ds
		pop	ax
		iret

code		ends					      	

;----------------------------------------------------------------------------

		end 	Test

