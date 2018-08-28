;****************************************************************************
;*
;* CLKTEST.ASM
;*
;* Print "time if day" BIOS clock value (LS word).
;*
;* Use this value for rand number seed.
;*
;* 30.04.1990 - KJB
;*
;****************************************************************************

;============================================================================

STACK		SEGMENT PARA STACK 'STACK'
		ASSUME SS:STACK

		DB	0200h DUP(0)

STACK		ENDS

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

CR		EQU	13
LF		EQU	10

SSTemp		DW	0
SPTemp		DW	0

HexChars	DB	"0123456789ABCDEF"

Title$		DB	CR,LF
		DB	"Clock LS value ... "
		DB	'$'

		EVEN

DATA		ENDS

;============================================================================

CODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:CODE
		ASSUME DS:DATA

Main:		mov	ax,DATA
		mov	ds,ax
		mov	es,ax

		mov	ax,ss
		mov	SSTemp,ax
		mov	ax,sp
		mov	SPTemp,ax

		cld	    		;auto-increment

		mov	ah,9
		mov	dx,OFFSET Title$
		int	021h

		mov	ah,0
		int	01ah

		mov	ax,dx

		call	PrintWord
		call	NewLine
		
		mov	al,0		;return code
		mov	ah,04ch		;terminate process
		int	021h
		retf

;----------------------------------------------------------------------------

;* PrintWord - print hex word using DOS
;*
;* pass: ax = word to print
;* ret : nothing
;* kill: flags

PrintWord	PROC	NEAR

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
		mov	dl,'h'
		mov	ah,2
		int	021h
		pop	ax

		pop	dx
		pop	bx
		ret

PrintWord	ENDP

;----------------------------------------------------------------------------

;* NewLine - print CR / LF
;*
;* pass: nothing
;* ret : nothing
;* kill: flags

NewLine		PROC	NEAR

		push	ax
		push	dx
		mov	dl,CR
		mov	ah,2
		int	021h
		mov	dl,LF
		mov	ah,2
		int	021h
		pop	ax
		pop	dx
		ret

NewLine		ENDP

CODE		ENDS

;============================================================================

		END	Main

