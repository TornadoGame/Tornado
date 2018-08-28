;****************************************************************************
;*
;* PARAMS - KJB - 22.02.1989
;*
;****************************************************************************

		public	Params
		public	IsSeperator
		public	ParseCmndLine

		public	PSP
		public	CommandLine
		public	Argc
		public	Argv
		public	EOS
		
;----------------------------------------------------------------------------

stack		segment para stack 'stack'
		assume ss:stack

		db	0200h dup(0)

stack		ends							

;----------------------------------------------------------------------------

data		segment para public 'data'

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
		assume ds:data

Params:		push	ds    		;save program segment prefix seg addr
		mov	ax,0			
		push	ax    		;save return address offset (PSP + 0)

		cld	      		;si, di auto-increment

		mov	ax,ds
		mov	bx,ax

		mov	ax,data
		mov	ds,ax
		mov	es,ax
		
		mov	PSP,bx

		call	ParseCmndLine

		mov	cx,Argc
		jcxz	NoArgs
    		mov	bx,offset Argv
		
PrintLoop:   	push	bx
		push	cx

	     	mov	dx,[bx]
		mov	ah,9
		int	021h

		mov	dl,13		;CR/LF
		mov	ah,2
		int	021h
		mov	dl,10
		mov	ah,2
		int	021h

		pop	cx
		pop	bx
		add	bx,2
		loop	PrintLoop

NoArgs:		retf

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
		cmp	al,'\'		;back slash
		je	FoundSeperator
		clc	
		ret
FoundSeperator:	stc
		ret

code		ends					      	

;----------------------------------------------------------------------------

		end 	Params

