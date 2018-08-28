;****************************************************************************
;*
;* STACK.ASM
;*
;* Program stack.
;*
;* 11.02.1991 - KJB
;*
;* Notes:-
;*
;* This file MUST be the last file in the link list. This allows data to be
;* stored in the stack segment, but keeps the actual program stack at the
;* end of the segment. DOS initializes SP to the end of the stack segment.
;*
;* >>>>> IMPORTANT <<<<<
;*
;* If any other modules store data in the stack segment then the combine type
;* used for that segment should be set to PUBLIC and not STACK. The program
;* will not link properly if the combine type STACK is used.
;*
;* This technique works with:-
;*
;*  - Microsoft Overlay Linker V3.60
;*  - Microsoft Segmented-Executable Linker V5.13
;*
;* but it does not work with:-
;*
;*  - Borland Turbo Linker TLink V3.0.
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	ProgStack

		PUBLIC	PROG_END

;============================================================================

STACK		SEGMENT PARA STACK 'STACK'
		ASSUME SS:STACK

ProgStack	DW	256 DUP(0)

PROG_END	LABEL	BYTE

STACK		ENDS

;============================================================================

		END

