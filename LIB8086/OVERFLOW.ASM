;****************************************************************************
;*
;* OVERFLOW.ASM
;*
;* Overflow interrupt handler.
;*
;* 30.06.1989 - KJB
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	InstallOverflow
		PUBLIC	RestoreOverflow

		PUBLIC	SSTemp
		PUBLIC	SPTemp

		PUBLIC	OverflowFlag

		EXTRN	AbortToDOS:FAR

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

SSTemp		DW	0
SPTemp		DW	0

OverflowFlag	DB	0,0

DOSVctrSeg	DW	0		;DOS overflow intr segment
DOSVctrOff	DW	0		;DOS overflow intr offset

HexChars	DB	"0123456789ABCDEF"

CR		EQU	13
LF		EQU	10

DATA		ENDS

;============================================================================

LIBCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:LIBCODE
		ASSUME DS:DATA

;* InstallOverflow - set overflow interrupt vector
;*
;* pass: nothing
;* ret : DOSVctrSeg = DOS overflow intr segment
;*       DOSVctrOff = DOS overflow intr offset
;* kill: assume all (DOS routine used)

InstallOverflow	PROC	FAR

		push	ds
		push	es

		mov	ah,035h		;DOS Get Interrupt Vector function
		mov	al,000h		;overflow interrupt
		int	021h  		;DOS
		mov	DOSVctrSeg,es
		mov	DOSVctrOff,bx

		mov	dx,OFFSET OverflowIntr
		mov	ax,SEG OverflowIntr
		mov	ds,ax
		mov	ah,025h		;DOS Set Interrupt Vector function
		mov	al,000h		;overflow interrupt
		int	021h		;DOS

		pop	es
		pop	ds
		ret

InstallOverflow	ENDP

;----------------------------------------------------------------------------

;* RestoreOverflow - restore overflow interrupt vector
;*
;* pass: DOSVctrSeg = overflow intr segment
;*       DOSVctrOff = overflow intr offset
;* ret : nothing
;* kill: assume all (DOS routine used)

RestoreOverflow	PROC	FAR

		push	ds
		push	es

		mov	dx,DOSVctrOff
		mov	ax,DOSVctrSeg
		mov	ds,ax
		mov	ah,025h		;DOS Set Interrupt Vector function
		mov	al,000h		;overflow interrupt
		int	021h		;DOS

		pop	es
		pop	ds
		ret

RestoreOverflow	ENDP

;----------------------------------------------------------------------------

;* OverflowIntr - overflow interrupt
;*
;* pass: SSTemp, SPTemp (restore stack for return to DOS)
;* ret : nothing
;* kill: nothing

OverflowIntr 	PROC	FAR

		push 	ax

	      	mov 	ax,DATA
      		mov 	ds,ax

		mov	al,3		;80 * 25 Alpha mode
		mov	ah,0
		int	010h

		mov	OverflowFlag,1	;Oh my God! How could it happen?

;* print ax, bx, cx, dx, si, di, bp

		pop	ax
		call	PrintWord
		mov	ax,bx
		call	PrintWord
		mov	ax,cx
		call	PrintWord
		mov	ax,dx
		call	PrintWord
		mov	ax,si
		call	PrintWord
		mov	ax,di
		call	PrintWord
		mov	ax,bp
		call	PrintWord
		call	NewLine

;* print cs, ds, es, ss, sp

		mov	ax,cs
		call	PrintWord
		mov	ax,ds
		call	PrintWord
		mov	ax,es
		call	PrintWord
		mov	ax,ss
		call	PrintWord
		mov	ax,sp
		call	PrintWord
		call	NewLine

;* print return address ip, cs, flags

		pop	ax
		call	PrintWord
		pop	ax
		call	PrintWord
		pop	ax
		call	PrintWord
		call	NewLine

		mov	ax,SPTemp
		mov	sp,ax
		mov	ax,SSTemp
		mov	ss,ax

		sti
		jmp	FAR PTR AbortToDOS

OverflowIntr  	ENDP

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
		mov	dl,' '
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

LIBCODE		ENDS

;============================================================================

		END

