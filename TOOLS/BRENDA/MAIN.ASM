;****************************************************************************
;*
;* MAIN.ASM
;*
;* xx.xx.xxxx - KJB
;*
;****************************************************************************

		PUBLIC	AbortToDOS

		EXTRN	InstallKbd:FAR
		EXTRN	RestoreKbd:FAR
		EXTRN	InstallTimer:FAR
		EXTRN	RestoreTimer:FAR
		EXTRN	InstallCritErr:FAR
		EXTRN	RestoreCritErr:FAR
		EXTRN	InstallOverflow:FAR
		EXTRN	RestoreOverflow:FAR
		EXTRN	InstallMouse:FAR
		EXTRN	RestoreMouse:FAR

		EXTRN	Brenda:NEAR

		EXTRN	SSTemp:WORD
		EXTRN	SPTemp:WORD
		EXTRN	MouseXMin:WORD
		EXTRN	MouseXMax:WORD
		EXTRN	MouseYMin:WORD
		EXTRN	MouseYMax:WORD

		EXTRN	OverflowFlag:BYTE

;============================================================================

STACK		SEGMENT PARA STACK 'STACK'
		ASSUME SS:STACK

		DB	0200h DUP(0)

STACK		ENDS

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

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

		mov	MouseXMin,0
		mov	MouseXMax,311
		mov	MouseYMin,0
		mov	MouseYMax,189

		call	InstallKbd
		call	InstallTimer
		call	InstallCritErr
		call	InstallOverflow
		call	InstallMouse
	
;---------------------
;* YOUR CODE GOES HERE
;---------------------

		call	Brenda
 
AbortToDOS:	call	RestoreMouse
		call	RestoreOverflow
		call	RestoreCritErr
		call	RestoreTimer
		call	RestoreKbd

		mov	al,OverflowFlag
		test	al,al
		jnz	ReturnToDOS
		mov	ah,0		;80*25 Alpha mode
		mov	al,3
		int	010h

ReturnToDOS:	mov	al,0		;return code
		mov	ah,04ch		;terminate process
		int	021h
		retf

CODE		ENDS

;============================================================================

		END	Main

