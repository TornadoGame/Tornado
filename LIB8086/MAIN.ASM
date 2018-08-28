;****************************************************************************
;*
;* MAIN.ASM
;*
;* Handle safe entry from and exit to DOS.
;*
;* 28.04.1989 - KJB
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	AbortToDOS
		PUBLIC	ReturnCode
		
		EXTRN	ParseCmndLine:FAR
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
		EXTRN	SetTimeDate:FAR

		EXTRN	PSP:WORD
		EXTRN	SSTemp:WORD
		EXTRN	SPTemp:WORD

		EXTRN	OverflowFlag:BYTE

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

ReturnCode	DB	0,0

DATA		ENDS

;============================================================================

CODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:CODE
		ASSUME DS:DATA

Main:		mov	ax,ds
		mov	dx,ax		

		mov	ax,DATA
		mov	ds,ax
		mov	es,ax

		mov	PSP,dx		;store program segment prefix

		mov	ax,ss
		mov	SSTemp,ax
		mov	ax,sp
		mov	SPTemp,ax

		cld	    		;auto-increment

		call	ParseCmndLine

		call	InstallKbd
		call	InstallTimer
		call	InstallCritErr
		call	InstallOverflow
		call	InstallMouse
	
;---------------------
;* YOUR CODE GOES HERE
;---------------------
 
AbortToDOS:	call	RestoreMouse
		call	RestoreOverflow
		call	RestoreCritErr
		call	RestoreTimer
		call	RestoreKbd

		call	SetTimeDate

		mov	al,OverflowFlag
		test	al,al
		jnz	ReturnToDOS
		mov	ah,0		;80*25 Alpha mode
		mov	al,3
		int	010h

ReturnToDOS:	mov	al,ReturnCode
		mov	ah,04ch		;terminate process
		int	021h
		retf

CODE		ENDS

;============================================================================

		END	Main

