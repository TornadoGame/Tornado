;****************************************************************************
;*
;* MANIMENU.ASM
;*
;* 06.07.1989 - KJB
;*
;****************************************************************************

		PUBLIC	MainMenu

		EXTRN	ScanKeys:NEAR
		
;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

BEL		EQU	7
CR		EQU	13
LF		EQU	10

Msg1$		DB	"PC CUTTER Utility v1.0 - KJB - 05.07.1989",CR,LF
		DB	"-----------------------------------------",CR,LF
		DB	CR,LF
		DB	"Useful functions for manipulating Deluxe Paint *.LBM files.",CR,LF
		DB	CR,LF
		DB	"Main Menu",CR,LF
		DB	"---------",CR,LF
		DB	CR,LF
		DB	"Select option:-",CR,LF
		DB	CR,LF
		DB	"A ... ESCAPE",CR,LF
		DB	" B ... Cut sprites",CR,LF
		DB	"  C ... Cut character set",CR,LF
		DB	"   D ... Compress picture file",CR,LF
		DB	"    E ... View compressed picture file",CR,LF
		DB	CR,LF
		DB	"Hit key A - E ... "
		DB	'$'

		EVEN

DATA		ENDS

;============================================================================

CODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:CODE
		ASSUME DS:DATA

;* MainMenu - select main option
;*
;* pass: nothing
;* ret : bx = option number (0 = A, 1 = B etc.)
;* kill: assume all (DOS routines used)

MainMenu	PROC	NEAR

		mov	ah,9
		mov	dx,OFFSET Msg1$
		int	021h

		mov	dx,'E'-'A'
		call	ScanKeys
		
		ret

MainMenu	ENDP

CODE		ENDS

;============================================================================

		END

