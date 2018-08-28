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

		PUBLIC	VideoMode
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
		EXTRN	NormaliseSound:FAR
		EXTRN	NormaliseMusic:FAR
		EXTRN	StopComms:FAR

		EXTRN	Control:NEAR

		EXTRN	PSP:WORD
		EXTRN	SSTemp:WORD
		EXTRN	SPTemp:WORD

		EXTRN	OverflowFlag:BYTE
		EXTRN	TwoPlayer:BYTE

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

VideoMode	DB	0

ReturnCode	DB	0

		EVEN

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

		mov	ah,00fh		;get current video mode
		int	010h
		mov	VideoMode,al

		call	ParseCmndLine

		call	InstallKbd
		call	InstallTimer
		call	InstallCritErr
		call	InstallOverflow
		call	InstallMouse
	
		call	Control
 
AbortToDOS:	call	RestoreMouse
		call	RestoreOverflow
		call	RestoreCritErr
		call	RestoreTimer
		call	RestoreKbd

;* set time and date from real time clock

		call	SetTimeDate

;* normalise sound (in case exit via SysReq)

		call	NormaliseSound
		call	NormaliseMusic

;* if two player then stop comms (in case exit via SysReq)

		test	TwoPlayer,1
		jz	@F

		call	StopComms

@@:		mov	al,OverflowFlag
		test	al,al
		jnz	ReturnToDOS
		mov	ah,0		;set video mode
		mov	al,VideoMode
		and	al,07fh		;ensure clear screen enabled
		int	010h

ReturnToDOS:	mov	al,ReturnCode
		mov	ah,04ch		;terminate process
		int	021h
		retf

CODE		ENDS

;============================================================================

		END	Main

