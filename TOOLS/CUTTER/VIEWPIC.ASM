;****************************************************************************
;*
;* VIEWPIC.ASM
;*
;* 06.07.1989 - KJB
;*
;****************************************************************************

		PUBLIC	ViewPic

		EXTRN	ScanKeys:NEAR
       		EXTRN	LoadPicFile:NEAR
		EXTRN	VideoMode:NEAR
		EXTRN	DownLoad:NEAR
		EXTRN	UnCompress:NEAR
		EXTRN	GetReadFile:NEAR

       		EXTRN	ScreenType:WORD

		EXTRN	Key:BYTE

;============================================================================

		INCLUDE	KEYS.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

BEL		EQU	7
CR		EQU	13
LF		EQU	10

Msg1$		DB	CR,LF,CR,LF
		DB	"View Compressed Picture File",CR,LF
		DB	"----------------------------",CR,LF
		DB	CR,LF
		DB	"Select input data format:-",CR,LF
		DB	CR,LF
		DB	"A ... CGA",CR,LF
		DB	" B ... TAN",CR,LF
		DB	CR,LF
		DB	"Hit key A - B ... "
		DB	'$'

		EVEN

DATA		ENDS

;============================================================================

CODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:CODE
		ASSUME DS:DATA

;* ViewPic - view compressed picture files
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

ViewPic		PROC	NEAR

		mov	ah,9
		mov	dx,OFFSET Msg1$
		int	021h

		mov	dx,'B'-'A'
		call	ScanKeys

		shl	bx,1
		mov	ScreenType,bx
		
		call	GetReadFile

		call	VideoMode

		call	LoadPicFile

		call	UnCompress

		call	DownLoad

ViewWait:	mov	al,Key[K_ESC]	
		test	al,al
		jz	ViewWait

		ret

ViewPic		ENDP

CODE		ENDS

;============================================================================

		END

