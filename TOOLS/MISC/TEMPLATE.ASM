;****************************************************************************
;*
;* 8086 template program.
;*
;****************************************************************************
		
;----------------------------------------------------------------------------

stack		segment para stack 'stack'
		assume ss:stack

		db	0200h dup(0)

stack		ends

;----------------------------------------------------------------------------

data		segment para public 'data'
		assume ds:data

dv0vctr		equ	000h		;div 0 interrupt vector
tmrvctr		equ	020h		;timer interrupt vector
kbdvctr		equ 	024h   		;keyboard interrupt vector

fiftyhz		equ	23864 		;timer value for 50Hz

CR		equ	13
LF		equ	10
ENT		equ	10
DEL		equ	127

vctrtbl		db	64 dup(0)  	;copy of intr vector table

sstemp		dw	0 		;stack segment temp
sptemp		dw	0   		;stack pointer temp

ticker		dw 	0		;counter incremented each interrupt

;* Key holds state of keys 0 -> 127, where 0 = key open, 1 = key closed

Key		db	128 dup(0)

asctble		db	  0,  0,'1','2','3','4','5','6'	;  0 -> 7
		db	'7','8','9','0',  0,  0,DEL,  0	;  8 -> 15
		db	'Q','W','E','R','T','Y','U','I'	; 16 -> 23
		db	'O','P',  0,  0, 10,  0,'A','S'	; 24 -> 31
		db	'D','F','G','H','J','K','L',  0	; 32 ->	39
		db	  0,  0,  0,  0,'Z','X','C','V'	; 40 ->	47
		db	'B','N','M',  0,  0,  0,  0,  0	; 48 ->	55
		db	  0,' ',  0,  0,  0,  0,  0,  0	; 56 ->	63
		db	  0,  0,  0,  0,  0,  0,  0,  0	; 64 ->	71
		db	'^',  0,  0,'<',  0,'>',  0,  0	; 72 ->	79
		db	'V',  0,  0,DEL,  0,  0,  0,  0	; 80 ->	87
		db	  0,  0,  0,  0,  0,  0,  0,  0	; 88 ->	95
		db	  0,  0,  0,  0,  0,  0,  0,  0	; 96 ->	103
		db	  0,  0,  0,  0,  0,  0,  0,  0	;104 -> 111
		db	  0,  0,  0,  0,  0,  0,  0,  0	;112 ->	119
		db	  0,  0,  0,  0,  0,  0,  0,  0	;120 ->	127

;* command line vars

EOS		equ	'$'		;END-OF-STRING marker

PSP		dw	0

CommandLine	db	130 dup(0)	;128 bytes + 2 for overflow

Argc		dw	0
Argv		dw	16 dup(0)

MaxArgs		equ	LENGTH Argv

data		ends

;----------------------------------------------------------------------------

code		segment byte public 'code'
		assume cs:code

main:		cli  

		push	ds   		;save program segment prefix seg addr
		mov	ax,0			
		push	ax  		;save return address offset (PSP + 0)

		cld   			;si, di auto-increment

		mov	ax,ds
		mov	bx,ax

		mov	ax,data
		mov	ds,ax

		mov	PSP,bx

		mov	ax,ss 		;save stack seg and pointer
		mov	sstemp,ax
		mov	ax,sp
		mov	sptemp,ax
	
		mov	ax,0  		;ds -> intr vector table
		mov	ds,ax
		mov	ax,data	 	;es -> my data segment
		mov	es,ax
		mov	si,000h	 	 
		mov	di,offset vctrtbl
		mov	cx,32	   	;only copy intr's 00h -> 0fh
		rep	movsw	   	;copy vector table
		mov	ax,data
		mov	ds,ax	   	;ds -> my data segment
		mov	es,ax		;es -> my data segment
		sti	

		call	InitIntrs

		call	ParseCmndLine

;----------------------------------------------------------------------------

;* PUT YOUR CODE HERE

;* to see how command line handling works, change to IF 1

IF	0
		mov	cx,Argc
		jcxz	NoArgs

		mov	si,offset Argv
ArgPrintLoop:	lodsw
		mov	dx,ax
		mov	ah,9		;print string

		push	cx
		push	si		
		int	021h		;call DOS 

;* print CR/LF

		mov	ah,2		;print char
		mov	dl,CR
		int	021h
		mov	ah,2		;print char
		mov	dl,LF
		int	021h

		pop	si
		pop	cx

		loop	ArgPrintLoop

NoArgs:

ENDIF

;* to see how GetChar works, change to IF 1

IF	0
Cont:		call	GetChar		
		cmp	al,ENT		;enter key?
		je	Finish		;yes ->

		mov	dl,al		;print char using DOS
		mov	ah,02h
		int	021h
		jmp	Cont

finish:

ENDIF

;* to see how divide by 0 works, change to IF 1

IF	0
		mov	bx,0
		div	bx
ENDIF

;----------------------------------------------------------------------------

		cli

bailout:	mov	al,036h	 	;set timer channel 0 to 18.2Hz
		out	043h,al 
		mov	bx,0
		mov	al,bl
		out	040h,al
		mov	al,bh
		out	040h,al

		mov	ax,data		;ds -> my data segment 
		mov	ds,ax
		mov	ax,0 		;es -> intr vector table
		mov	es,ax
		mov	si,offset vctrtbl
		mov	di,000h		 
		mov	cx,32  		;only copy intr's 00h -> 0fh
		rep	movsw  		;copy vector table
		sti

		retf			;far ret back to DOS

;===================
;* Initialize Intr's
;===================

InitIntrs:	cli
		push	es

		mov	ax,0  		;es -> interrupt vector table
		mov	es,ax

		mov	di,dv0vctr	;re-direct divide by 0 interrupt
		mov	ax,offset div0
		stosw
		mov	ax,cs
		stosw

		mov	di,tmrvctr   	;re-direct timer interrupt
		mov	ax,offset Intr50
		stosw
		mov	ax,cs
		stosw

		mov	di,kbdvctr	;re-direct keyboard interrupt
		mov	ax,offset kbdintr
		stosw
		mov	ax,cs
		stosw

		mov	al,036h	 	;set timer channel 0 to 50hz
		out	043h,al 
		mov	bx,fiftyhz
		mov	al,bl
		out	040h,al
		mov	al,bh
		out	040h,al

		mov	al,0		;enable IRQ0 -> IRQ7
		out	021h,al
		mov	al,0   		;enable IRQ8 -> IRQF
		out	0a1h,al

		pop	es
		sti
		ret

;========================
;* DIVIDE by ZERO handler
;========================

div0:		push 	ax
		mov 	ax,data
		mov 	ds,ax
		mov 	ax,3
		int 	010h
		pop 	ax
		push 	bx
		call 	prword	 	;print ax 	
		pop 	ax
		call 	prword   	;print bx
		mov 	ax,cx
		call 	prword	 	;print cx
		mov 	ax,dx
		call 	prword	  	;print dx
		mov 	ax,bp
		call 	prword	  	;print bp
		mov 	ax,si
		call 	prword	        ;print si
		mov 	ax,di
		call 	prword		;print di
		mov 	ax,cs
		call 	prword		;print cs
		mov 	ax,ds
		call 	prword		;print ds
		mov 	ax,es
		call 	prword		;print es
		mov 	ax,ss
		call 	prword		;print ss
		mov 	ax,sp
		call 	prword		;print sp
		pop 	ax
		call 	prword  	;print top of stack
		pop 	ax
		call 	prword  	;print top of stack - 2
		pop 	ax
		call 	prword  	;print top of stack - 4 
       
		mov	ax,sstemp 	;Hi Ho, Hi Ho, it's back to DOS we go!
		mov 	ss,ax	   
		mov 	ax,sptemp
		mov 	sp,ax
		mov	al,020h
		out	020h,al
		jmp	bailout

prword:		push 	ax		;print word in hex
		mov 	al,ah
		call 	prbyte
		pop 	ax
		call 	prbyte
		mov 	al,32
		int 	010h
		ret

prbyte:		push	ax	  	;print byte in hex
		shr 	al,1
		shr 	al,1 
		shr 	al,1
		shr 	al,1
		call 	byte2
		pop 	ax
byte2:		and 	al,15
		cmp 	al,10
		jb 	byte3
		add 	al,7
byte3:		add 	al,"0"
		mov 	ah,14
		mov 	bl,3
		int 	010h
		ret

;=================
;* 50 Hz interrupt
;=================

Intr50:		push	ax
		push	bx
		push	cx
		push	dx
		push	si
		push	di
		push	bp
		push	ds
		push	es

		mov	ax,data 	;ensure correct data segment!
		mov	ds,ax
		mov	es,ax

		cld			

		inc	ticker	  	;increment timer counter

;----------------------------------------------------------------------------

;* PUT YOUR INTERUPT CODE HERE

;----------------------------------------------------------------------------

		mov 	al,020h	 	;inform the interrupt controller that
      		out 	020h,al	 	;the interrupt has been serviced

		pop	es
		pop	ds
		pop	bp
		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		iret

;============================
;* Keyboard Interrupt handler
;============================

;* kbdintr - keyboard interrupt
;*
;* pass: nothing (entered by key interrupt at 024h)
;* ret : nothing
;* kill: nothing
;*
;* A keyboard interrupt occurs whenever a key is pressed or released. 
;* When the interrupt occurs, the keyboard scan code can be read from PPI
;* port A (port number 0060h). If bit 7 is 0 then the key was pressed. If bit
;* 7 was 1 then the key was released.
;*
;* After reading the scan code the keyboard is cleared and enabled by
;* toggling bit 7 of PPI port B.
;*
;* Note that at the end of the interrupt routine it is necessary to inform
;* the interrupt controller (8259A) that the interrupt has been serviced.

kbdintr:	push 	ax
      		push 	bx
      		push 	ds	   	;in case ds changed when int occurs
      		mov 	ax,data
      		mov 	ds,ax
      		in	al,060h	   	;al = kbd scan code from PPI port A
      		push 	ax	  
      		in 	al,061h	   	;al = current state of PPI port B 
      		mov 	ah,al	  		
      		or 	al,080h			
      		out 	061h,al	   	;clear keyboard
      		xchg 	ah,al
      		out 	061h,al	   	;enable keyboard
      		pop 	bx
      		xor 	bh,bh
      		test	bl,bl	   	;has key been pressed (bit 7 = 0)?
      		jns	keymade	   	;yes ->
		and	bl,07fh    	;key has been released
		mov	al,0	   
		jmp	short skip
keymade:	mov	al,1
skip:		mov 	Key[bx],al
		mov 	al,020h	       	;inform the interrupt controller that
      		out 	020h,al	       	;the interrupt has been serviced
      		pop 	ds
      		pop 	bx 
      		pop 	ax
      		iret

;===============================
;* Some useful keyboard routines
;===============================

;* testkey - test if key is being pressed
;*
;* pass: al = code of key to be tested
;* ret : zf = 0 = key not pressed
;*	      1 = key pressed
;* kill: flags

testkey:	push	bx
		mov	bl,al
		xor	bh,bh
		cmp	Key[bx],1
		pop	bx
		ret

;* getchar - get character from keyboard (wait for keypress)
;*
;* pass: nothing
;* ret : al = ASCII code of key pressed
;*       ah = scan code of key pressed
;* kill: flags
;*
;* Note that when the key is read, the Key code is reset to 0. This will
;* allow the key to auto-repeat at the normal rate.

getchar:	push	bx
		push	cx
getch10:	xor	bx,bx		;index start of Key
		mov	cx,128		;max of 128 keys to test
getch20:	cmp	Key[bx],1	;is key pressed?
		je	getch30	     	;yes ->
		inc	bx
		loop	getch20
		jmp	short getch10	;wait for keypress ->
getch30:	mov	Key[bx],0	;stamp on 'pressed' for auto-repeat
		mov	al,asctble[bx]	;get ASCII code
		mov	ah,bl	      	;ah = scan code
		pop	cx
		pop	bx
		ret	

;* getc - as getchar but no auto-repeat
;*
;* pass: nothing
;* ret : al = ASCII code of key pressed
;*       ah = scan code of key pressed
;* kill: flags

getc:		push	bx
		push	cx
getc10:		xor	bx,bx	      	;index start of Key
		mov	cx,128	      	;max of 128 keys to test
getc20:		cmp	Key[bx],1 	;is key pressed?
		je	getc30	      	;yes ->
		inc	bx
		loop	getc20
		jmp	short getc10  	;wait for keypress ->
getc30:		mov	al,asctble[bx]	;get ASCII code
		mov	ah,bl	      	;ah = scan code
		pop	cx
		pop	bx
		ret	

;======================
;* Command Line handler
;======================

;* ParseCmndLine - parse command line and initialize Argc and Argv[]
;*
;* pass: PSP = program segment pointer
;* ret : Argc, Argv, CommandLine
;* kill: ax, bx, cx, si, di, flags

ParseCmndLine:	push	ds
		push	es
		mov	ax,PSP
		mov	ds,ax
		mov	ax,data
		mov	es,ax

;* copy PSP command line into data segment

		mov	cx,128
		mov	si,128
		mov	di,offset CommandLine
		rep	movsb

		mov	ax,data
		mov	ds,ax

		mov	si,offset CommandLIne
		lodsb			
		mov	cl,al		
		xor	ch,ch		;cx = command line length

		mov	bx,offset Argv

		mov	Argc,0

		jcxz	EndScan

;* search for first non-seperator character

FirstSearch:	mov	al,[si]
		call	IsSeperator
		jnc	FoundFirst
		inc	si
		loop	FirstSearch
		jmp	EndScan

;* update Argc and Argv[]

FoundFirst:	cmp	Argc,MaxArgs
		je	EndScan
		inc	Argc
		mov	[bx],si
		add	bx,2
		inc	si
		loop	SepSearch
		jmp	EndScan

;* search for next seperator

SepSearch:	mov	al,[si]
		call	IsSeperator
		jc	FoundSep
		inc	si
		loop	SepSearch
		jmp	EndScan

;* replace seperator with END-OF-STRING marker

FoundSep:	mov	[si],byte ptr EOS
		inc	si
		loop	FirstSearch

EndScan:	mov	[si],byte ptr EOS

		pop	es
		pop	ds
		ret

;* IsSeperator - check if char in al is a seperator character
;*
;* pass: al = character
;* ret : cf = 1 = seperator
;* kill: flags

IsSeperator:	cmp	al,' '		;test all chars space and below
		jbe	FoundSeperator
		cmp	al,','		;comma
		je	FoundSeperator
		cmp	al,'/'		;slash
		je	FoundSeperator
		clc	
		ret
FoundSeperator:	stc
		ret

code		ends

;----------------------------------------------------------------------------

		end 	main

