;****************************************************************************
;*
;* MAKEDB.ASM - KJB - 27.02.1989
;*
;* Read in file and make DB file.
;*
;* Command line format:-
;*
;*   makedb [drive:][\path\]inputfile [drive:][\path\]outputfile
;*
;****************************************************************************

		public	MakeDB

;----------------------------------------------------------------------------

stack		segment para stack 'stack'
		assume ss:stack

		db	0200h dup(0)

stack		ends							

;----------------------------------------------------------------------------

data		segment para public 'data'
		assume ds:data

Buffer		db	32768 dup(0)

BELL		equ	7
TAB		equ	9
LF		equ	10
CR		equ	13

Handle		dw	0

ReadFile	db	128 dup(0)

WriteFile	db	128 dup(0)

BytesRead	dw	0

;* strings

CmndErrMes	db	BELL,CR,LF
		db	'Command line error ... ',CR,LF,CR,LF
		db	'Command line format:-',CR,LF,CR,LF
		db	'makedb [drive:][\path\]inputfile '
		db	'[drive:][\path\]outputfile',CR,LF
		db	'$'
		even

DiskErrMes	db	'DISK ERROR !!!',CR,LF,'$'
		even	

EOS		equ	'$'		;END-OF-STRING marker

PSP		dw	0

CommandLine	db	130 dup(0)	;128 bytes + 2 for overflow

Argc		dw	0
Argv		dw	16 dup(0)

MaxArgs		equ	LENGTH Argv

txtptr		dw	offset txtbuf
txtbuf		db	256 dup (0)

HexChars	db	'0123456789ABCDEF'

ByteCount	db	0,0

ASCIIeqv	db	'........'

data		ends

;----------------------------------------------------------------------------

code		segment byte public 'code'
		assume cs:code

MakeDB:	

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

		mov	PSP,bx

		cld	      		;si, di auto-increment

;=======================
;* SORT OUT COMMAND LINE
;=======================

		call	ParseCmndLine
		mov	ax,Argc
		cmp	ax,2
		jne	CmndLineError

;* inputfile

		mov	si,Argv[0]
		mov	di,offset ReadFile
CLLoop:		lodsb
		cmp	al,EOS
		je	EndFound
		stosb
		jmp	CLLoop

EndFound:	xor	al,al		;ASCIIZ terminator
		stosb

;* outputfile

		mov	si,Argv[2]
		mov	di,offset WriteFile
CLLoop2:  	lodsb
		cmp	al,EOS
		je	EndFound2
		stosb
		jmp	CLLoop2

EndFound2:	xor	al,al		;ASCIIZ terminator
		stosb

		jmp	IntoProg

;====================
;* Command line error
;====================

CmndLineError:  mov	ah,9
		mov	dx,offset CmndErrMes
		int	021h
		jmp	Exit

;==================================================
;* READ inputfile AND PROCESS IT TO MAKE outputfile
;==================================================

IntoProg:      

;* open inputfile

		mov	al,00000000b
		mov	ah,03dh
		mov	dx,offset ReadFile
		int	021h
		jnc	OpenOK
		jmp	DiskError
OpenOK:

;* read inputfile - can only handle file LENGTH Buffer bytes or less

		mov	Handle,ax
		mov	bx,ax
		mov	cx,LENGTH Buffer
		mov	dx,offset Buffer

		mov	ah,03fh
		int	021h
		jnc	ReadOK
		jmp	DiskError
ReadOK:		mov	BytesRead,ax

;* close inputfile

		mov	ah,03eh
		mov	bx,Handle
		int	021h
		jnc	CloseOK
		jmp	DiskError
CloseOK:

;* create outputfile

		mov	ah,03ch
		mov	cx,0
		mov	dx,offset WriteFile
		int	021h
		jnc	CreateOk
		jmp	DiskError
CreateOk:	mov	Handle,ax

;* write data to outputfile

		mov	cx,BytesRead

		test	cx,7		;exact multiple of 8?
		jz	Mult8		;yes ->
		and	cx,0fff8h
		add	cx,8	 	;round up to next multiple

Mult8:		mov	si,offset Buffer
WriteLoop:	lodsb
		push	cx
		push	si
		call	WriteHexByte
		pop	si
		pop	cx
		loop	WriteLoop

;* close outputfile

		mov	ah,03eh
		mov	bx,Handle
		int	021h
		jc	DiskError

;===========
;* POSTAMBLE
;===========

Exit:		retf			;return to DOS

;============
;* DISK ERROR
;============

DiskError:	mov	ah,9
		mov	dx,offset DiskErrMes
		int	021h
		
		retf

;----------------------------------------------------------------------------

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

;----------------------------------------------------------------------------

;* WriteHexByte
;* 
;* pass: al = byte
;* ret : nothing
;* kill: nothing
;*
;* NO ERROR TRAPPING!!!

WriteHexByte:	push	ax
		push	bx
		push	cx
		push	dx
		push	si
		push	di
		push	bp
		push	ds
		push	es

		mov	si,txtptr
	
		cmp	ByteCount,0
		jne	NotFirstByte

		mov	[si+0],byte ptr TAB
		mov	[si+1],byte ptr TAB
		mov	[si+2],byte ptr 'd'
		mov	[si+3],byte ptr 'b'
		mov	[si+4],byte ptr TAB
		add	si,5
		jmp	SortByte

NotFirstByte:	mov	[si+0],byte ptr ','
		inc	si

SortByte:	call	PutHexByte

		inc	ByteCount
		cmp	ByteCount,8
		jb	ByteWidthOk

		mov	ByteCount,0

		mov	[si+0],byte ptr TAB
		mov	[si+1],byte ptr ';'
		add	si,2
		mov	di,si
		mov	si,offset ASCIIeqv
		mov	cx,8
		rep	movsb
		
		mov	si,di
		mov	[si+0],byte ptr CR
		mov	[si+1],byte ptr LF
		mov	[si+2],byte ptr '$'

		mov	si,offset txtbuf
		push	si
		call	fwrite
		pop	si

ByteWidthOk:	mov	txtptr,si

		pop	es
		pop	ds
		pop	bp
		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		ret

;* PutHexByte - put byte into string

PutHexByte:	mov	bl,ByteCount
		xor	bh,bh
		cmp	al,' '
		jb	Dot
		cmp	al,127
		ja	Dot
		mov	ASCIIeqv[bx],al
		jmp	Cont

Dot:		mov	ASCIIeqv[bx],byte ptr '.'     
	
Cont:		mov	[si+0],byte ptr '0'
		mov	bx,offset HexChars
		mov	ah,al
		shr	al,1
		shr	al,1
		shr	al,1
		shr	al,1
		and	al,00fh
		xlat
		mov	[si+1],al
		mov	al,ah
		and	al,00fh
		xlat
		mov	[si+2],al
		mov	[si+3],byte ptr 'H'
		add	si,4
		ret

;* fwrite - write string to disk
;*
;* pass: ds:si -> string ('$' terminator)
;*       handle
;* ret : cf = 0 = no error
;*       cf = 1 = error
;* kill: assume all
 
fwrite:	mov	dx,si

;* count number of chars in string

	xor	cx,cx			;cntr = 0
	cld
search:	lodsb				;get text byte
	cmp	al,'$'
	je	found
	inc	cx
	jmp	short search
found:	mov	bx,handle
	mov	ah,040h			;write to file
	int	021h
	ret

;----------------------------------------------------------------------------

code		ends					      	

		end 	MakeDB

