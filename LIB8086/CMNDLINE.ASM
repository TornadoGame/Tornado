;****************************************************************************
;*
;* CMNDLINE.ASM
;*
;* Parse command line.
;*
;* 02.08.1990 - KJB
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	ParseCmndLine

		PUBLIC	PSP
		PUBLIC	ARGC
		PUBLIC	ARGV

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

PSP		DW	0		;program segment prefix

DEBUG		EQU	0		;1 = use debug command line

CommandLine	LABEL	BYTE

		IF	DEBUG
		DB	""		;<<<<< debug command line <<<<<
		ELSE
		DB	130 DUP(0)	;copy of DOS command line + overflow
		ENDIF

		EVEN

MAX_ARGS	EQU	32

ARGC		DW	0		;argument count (0 .. MAX_ARGS)
ARGV		DW	MAX_ARGS DUP(0)	;argument pointers

ASCIIZ		EQU	0

DATA		ENDS

;============================================================================

LIBCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:LIBCODE
		ASSUME DS:DATA

;* ParseCmndLine - copy DOS command line and set up ARGC and ARGV[]
;*
;* pass: PSP (program segment prefix)
;* ret : ARGC, ARGV[]
;* kill: assume all
;*
;* note: Refer to Programmer's Guide to the IBM PC by Peter Norton for
;*       a description of the program segment prefix (PSP) structure.

ParseCmndLine	PROC	FAR

;* copy DOS command line before it is destroyed

		IFE	DEBUG

		push	ds
		mov	ax,PSP
		mov	ds,ax

		mov	cx,128
		mov	si,128		;DOS command line is at PSP+128
		mov	di,OFFSET CommandLine
		rep	movsb

		pop	ds

		ENDIF

;* initialize variables

		mov	ARGC,0

		xor	bx,bx

		mov	si,OFFSET CommandLine

;* determine command line length

		lodsb			
		mov	cl,al		
		and	cx,0007fh	;cx = command line length = 0 .. 127

		jcxz	CmndLineExit	;null command line ->

;* scan command line for an argument

ArgSearch:	mov	al,[si]
		call	CheckSeperator	;non-seperator character?
		jnc	FoundArg	;yes, found start of argument ->
		inc	si
		loop	ArgSearch
		jmp	CmndLineExit	;end of command line encountered ->

;* update ARGC and ARGV[]

FoundArg:	cmp	ARGC,MAX_ARGS	;room for another argument?
		je	CmndLineExit	;no ->
		inc	ARGC		;update ARGC
		mov	ARGV[bx],si	;store arg pointer in ARGV[]
		add	bx,2
		inc	si
		loop	SepSearch
		jmp	TruncateArg	;end of command line, truncate arg ->

;* scan command line for a seperator

SepSearch:	mov	al,[si]
		call	CheckSeperator	;seperator character?
		jc	FoundSep	;yes ->
		inc	si
		loop	SepSearch
		jmp	TruncateArg	;end of command line, truncate arg ->

;* replace seperator with ASCIIZ

FoundSep:	mov	[si],BYTE PTR ASCIIZ
		inc	si
		loop	ArgSearch
		jmp	CmndLineExit	;end of command line encountered ->

;* end of command line encountered whilst scanning arg, therefore truncate arg

TruncateArg:	mov	[si],BYTE PTR ASCIIZ

CmndLineExit:	ret

ParseCmndLine	ENDP

;----------------------------------------------------------------------------

;* CheckSeperator - check if character is a seperator
;*
;* pass: al = character
;* ret : cf = 1 = seperator
;* kill: flags

CheckSeperator	PROC	NEAR

		cmp	al,' '		;space?
		je	Seperator
		cmp	al,','		;comma?
		je	Seperator
		cmp	al,'/'		;slash?
		je	Seperator
		cmp	al,'-'		;minus?
		je	Seperator

NonSeperator:	clc			;cf = 0	
		ret

Seperator:	stc			;cf = 1
		ret

CheckSeperator	ENDP

LIBCODE		ENDS

;============================================================================

		END

