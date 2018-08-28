;****************************************************************************
;*
;* TIMER.ASM
;*
;* Routines for 8253 timer.
;*
;* 29.06.1989 - KJB
;*
;****************************************************************************

		PUBLIC	InstallTimer
		PUBLIC	RestoreTimer

		PUBLIC	TimerStatus
		PUBLIC	Ticker
		PUBLIC	Frames

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

TimerStatus	DB	0,0		;0 = DOS Timer currently installed
					;1 = TimerIntr currently installed

Ticker		DW	0		;clock
Frames		DW	0		;frame timer

IntrCntr	DB	0,0		;interrupt counter

DOSVctrSeg	DW	0		;DOS keyboard intr segment
DOSVctrOff	DW	0		;DOS keyboard intr offset

;* count = 1.19318MHz / freq

T_18Hz		EQU	65535		;18.2 Hz for DOS
T_100Hz		EQU	11932		;100 Hz

DATA		ENDS

;============================================================================

LIBCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:LIBCODE
		ASSUME DS:DATA

;* InstallTimer - set timer interrupt vector
;*
;* pass: nothing
;* ret : DOSVctrSeg = DOS timer intr segment
;*       DOSVctrOff = DOS timer intr offset
;* kill: assume all (DOS routine used)
;* note: If TimerStatus = 1 then do not install.

InstallTimer	PROC	FAR

		push	ds
		push	es

		mov	al,1
		cmp	al,TimerStatus
		je	DoNotInstall
	
		mov	TimerStatus,al

		mov	ah,035h		;DOS Get Interrupt Vector function
		mov	al,008h		;timer interrupt
		int	021h  		;DOS
		mov	DOSVctrSeg,es
		mov	DOSVctrOff,bx

		mov	cs:DOSTimerSeg,es
		mov	cs:DOSTimerOff,bx

		mov	dx,OFFSET TimerIntr
		mov	ax,SEG TimerIntr
		mov	ds,ax
		mov	ah,025h		;DOS Set Interrupt Vector function
		mov	al,008h		;timer interrupt
		int	021h		;DOS

;* set frequency AFTER redirecting intr vector

		cli
		mov	al,036h		;tell 8253 command reg we want to set
		out	043h,al		;channel 0 frequency
		mov	al,LOW T_100Hz
		out	040h,al
		mov	al,HIGH T_100Hz
		out	040h,al
		sti

DoNotInstall:	pop	es
		pop	ds
		ret

InstallTimer	ENDP

;----------------------------------------------------------------------------

;* RestoreTimer - restore DOS timer interrupt vector
;*
;* pass: DOSVctrSeg = DOS timer intr segment
;*       DOSVctrOff = DOS timer intr offset
;* ret : nothing
;* kill: assume all (DOS routine used)
;* note: If TimerStatus = 0 then do not restore.

RestoreTimer	PROC	FAR

		push	ds
		push	es

		mov	al,0
		cmp	al,TimerStatus
		je	DoNotRestore
	
		mov	TimerStatus,al

;* set frequency BEFORE redirecting intr vector

		cli
		mov	al,036h		;tell 8253 command reg we want to set
		out	043h,al		;channel 0 frequency
		mov	al,LOW T_18Hz
		out	040h,al
		mov	al,HIGH T_18Hz
		out	040h,al
		sti

		mov	dx,DOSVctrOff
		mov	ax,DOSVctrSeg
		mov	ds,ax
		mov	ah,025h		;DOS Set Interrupt Vector function
		mov	al,008h		;timer interrupt
		int	021h		;DOS

DoNotRestore:	pop	es
		pop	ds
		ret

RestoreTimer	ENDP

;----------------------------------------------------------------------------

;* TimerIntr - timer interrupt
;*
;* pass: Ticker
;*       Frames
;*       IntrCntr
;* ret : Ticker = Ticker + 1
;*       Frames = Frames + 1
;*       IntrCntr = IntrCntr + 1 (reset to 0 when reach 5)
;* kill: nothing
;* note: Every 5 interrupts this routine jumps to the DOS timer routine.
;*       Therefore DOS routine is called at 20Hz instead of 18.2 Hz.
;*       Should still be ok though. This is necessary to update mouse
;*       and switch disk motor off.

TimerIntr 	PROC	FAR

		push 	ax
      		push 	ds     

	      	mov 	ax,SEG Ticker
      		mov 	ds,ax

		inc	Ticker
	 	inc	Frames

		mov	al,IntrCntr
		inc	al
		cmp	al,5
		je	RetViaDOSIntr
		mov	IntrCntr,al

		mov 	al,020h	    	;send EOI to 8259 command register
      		out 	020h,al
      	
		pop 	ds
      		pop 	ax
		iret

;* NOTE: POP list should match list above

RetViaDOSIntr:	xor	al,al
		mov	IntrCntr,al
		pop	ds
		pop	ax

;* WARNING - SELF MODIFYING CODE!!!

		DB	0eah		;jmp FAR PTR
DOSTimerOff	DW	0
DOSTimerSeg	DW	0

TimerIntr  	ENDP

LIBCODE		ENDS

;============================================================================

		END

