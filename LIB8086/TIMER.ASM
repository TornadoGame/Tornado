;****************************************************************************
;*
;* TIMER.ASM
;*
;* Routines for 8253 timer.
;*
;* 29.06.1989 - KJB
;* 01.08.1991 - KJB - CountDown timer added.
;* 08.08.1991 - KJB - TimerStatus removed (no longer required for DISK.ASM).
;* 04.08.1992 - KJB - ElapsedTime added.
;* 23.09.1992 - KJB - DOS interrupt now called at 18.2Hz not 20Hz.
;* 05.10.1992 - KJB - PS/2 mod made to TimerIntr.
;* 29.10.1992 - KJB - SetTimeDate added.
;* 04.11.1992 - KJB - FrameElapTime added.
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	InstallTimer
		PUBLIC	RestoreTimer
		PUBLIC	InstallUser20
		PUBLIC	RestoreUser20
		PUBLIC	InstallUser100
		PUBLIC	RestoreUser100
		PUBLIC	SetTimeDate

		PUBLIC	ElapsedTime
		PUBLIC	FrameElapTime

		PUBLIC	Ticker
		PUBLIC	Frames
		PUBLIC	LastFrame
		PUBLIC	CountDown

;============================================================================

		INCLUDE	USEFUL.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

Ticker		DW	0 
Frames		DW	0 
LastFrame	DW	0
CountDown	DW	0

ElapsedTime	DD	0		;(1/100ths sec)

FrameElapTime	DD	0		;elapsed time at start of frame

Count100	DW	100
	
IntrCntr	DB	0,0		;interrupt counter

DOSTimer	DW	0

DOSVctrSeg	DW	0		;DOS timer intr segment
DOSVctrOff	DW	0		;DOS timer intr offset

;* count = 1.19318MHz / freq

T_18Hz		EQU	65535		;18.2Hz for DOS
T_100Hz		EQU	11932		;100Hz

;* user timer routines

UserVctr20Flag	DB	0,0		;1 = 20Hz user routine installed

UserVctr20	DD	0		;20Hz user routine address

UserVctr100Flag	DB	0,0		;1 = 100Hz user routine installed

UserVctr100	DD	0		;100Hz user routine address

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

InstallTimer	PROC	FAR

		push	ds
		push	es

		mov	ah,035h		;DOS Get Interrupt Vector function
		mov	al,008h		;timer interrupt
		int	021h  		;DOS
		mov	DOSVctrSeg,es
		mov	DOSVctrOff,bx

		mov	CS:DOSTimerSeg,es
		mov	CS:DOSTimerOff,bx

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

		pop	es
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

RestoreTimer	PROC	FAR

		push	ds
		push	es

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

		pop	es
		pop	ds
		ret

RestoreTimer	ENDP

;----------------------------------------------------------------------------

;* TimerIntr - timer interrupt
;*
;* pass: nothing
;* ret : nothing
;* kill: nothing

TimerIntr 	PROC	FAR

		push 	ax		;(see pop lists below)
      		push 	ds     

	      	mov 	ax,DATA
      		mov 	ds,ax

;---------------------
; mod for PS/2 systems
;---------------------

		in	al,061h		;read PPI port B
		or	al,080h
		out	061h,al		;IRQ 0 reset

;--------------------------
;* update timers / counters
;--------------------------

		inc	Ticker
	 	inc	Frames

		mov	ax,CountDown	;count down to zero
		cmp	ax,1
		cmc			;cf = 1 only if ax > 0
		sbb	ax,0
		mov	CountDown,ax

		add	WORD PTR ElapsedTime,1
		adc	WORD PTR ElapsedTime+2,0

;------------------------------------------------------
;* test for user 100Hz routine, if present then call it
;------------------------------------------------------

		test	UserVctr100Flag,1
		jz	NoUser100

		push	ax
		push	bx
		push	cx
		push	dx
		push	si
		push	di
		push	bp
		push	ds
		push	es
		call	UserVctr100
		pop	es
		pop	ds
		pop	bp
		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax

;-----------------------------------------------------
;* test for user 20Hz routine, if present then call it
;-----------------------------------------------------

NoUser100:	inc	IntrCntr

		cmp	IntrCntr,5 	;5th interrupt (20Hz)?
		jb	NoUser20	;no ->

		mov	IntrCntr,0

		test	UserVctr20Flag,1
		jz	NoUser20

		push	ax
		push	bx
		push	cx
		push	dx
		push	si
		push	di
		push	bp
		push	ds
		push	es
		call	UserVctr20
		pop	es
		pop	ds
		pop	bp
		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax

;----------------------------------
;* test for return via DOS (18.2Hz)
;----------------------------------

NoUser20:	add	DOSTimer,T_100Hz
		jc	RetViaDOSIntr

		mov 	al,020h	    	;send EOI to 8259 command register
      		out 	020h,al
      	
		pop 	ds		;(see push list above)
      		pop 	ax
		iret

RetViaDOSIntr:	pop	ds		;(see push list above)
		pop	ax

		jmp	DWORD PTR CS:DOSTimerOff

DOSTimerOff	DW	0
DOSTimerSeg	DW	0

TimerIntr  	ENDP

;----------------------------------------------------------------------------

;* InstallUser20 - install user timer 20Hz routine
;*
;* pass: ax = offset
;*       dx = segment
;* ret : UserVctr20Flag = 1
;*       UserVctr20 = FAR address of user routine
;* kill: nothing

InstallUser20	PROC	FAR

		cli	
		mov	WORD PTR UserVctr20,ax
		mov	WORD PTR UserVctr20+2,dx
		mov	UserVctr20Flag,1
		sti
		ret

InstallUser20	ENDP

;----------------------------------------------------------------------------

;* RestoreUser20 - remove user timer 20Hz routine
;*
;* pass: nothing
;* ret : UserVctr20Flag = 0
;* kill: nothing

RestoreUser20	PROC	FAR

		cli	
		mov	UserVctr20Flag,0
		sti
		ret

RestoreUser20	ENDP

;----------------------------------------------------------------------------

;* InstallUser100 - install user timer 100Hz routine
;*
;* pass: ax = offset
;*       dx = segment
;* ret : UserVctr100Flag = 1
;*       UserVctr100 = FAR address of user routine
;* kill: nothing

InstallUser100	PROC	FAR

		cli	
		mov	WORD PTR UserVctr100,ax
		mov	WORD PTR UserVctr100+2,dx
		mov	UserVctr100Flag,1
		sti
		ret

InstallUser100	ENDP

;----------------------------------------------------------------------------

;* RestoreUser100 - remove user timer 100Hz routine
;*
;* pass: nothing
;* ret : UserVctr100Flag = 0
;* kill: nothing

RestoreUser100	PROC	FAR

		cli	
		mov	UserVctr100Flag,0
		sti
		ret

RestoreUser100	ENDP

;----------------------------------------------------------------------------

;* UnpackBCD
;*
;* pass: reg = 00 .. 99 packed BCD
;* ret : reg =  0 .. 99
;* kill: ax, flags

UnpackBCD	MACRO	reg

		mov	al,reg
		mov	ah,reg
		and	al,00fh
		REPT	4
		shr	ah,1
		ENDM
		aad
		mov	reg,al

		ENDM

;----------------------------------------------------------------------------

;* SetTimeDate - set system time and date from real-time clock
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all
;*
;* note: If the real-time clock passes midnight after reading the date but
;*	 before reading the time, then the clock will lose a day!

SetTimeDate	PROC	FAR

;----------------------------------------------
;* get real-time clock date and set system date
;----------------------------------------------

		mov	ah,004h		;get real-time clock date
		int	01ah		;time of day service
		_JC	ExitTimeDate	;defective ->

;* ch = century (19 .. 20 BCD)
;* cl = year    (00 .. 99 BCD)
;* dh = month   (01 .. 12 BCD)
;* dl = day     (01 .. 31 BCD)

		UnpackBCD ch
		UnpackBCD cl
		UnpackBCD dh
		UnpackBCD dl

		mov	al,100
		mul	ch
		add	al,cl
		adc	ah,0
		mov	cx,ax

;* cx = year (1980 .. 2099)
;* dh = month   (1 .. 12)
;* dl = day     (1 .. 31)

		mov	ah,02bh		;set date
		int	021h		;DOS function

;----------------------------------------------
;* get real-time clock time and set system time
;----------------------------------------------

		mov	ah,002h		;get real-time clock time
		int	01ah		;time of day service
		jc	ExitTimeDate	;defective ->

;* ch = hours   (00 .. 23 BCD)
;* cl = minutes (00 .. 59 BCD)
;* dh = seconds (00 .. 59 BCD)

		UnpackBCD ch
		UnpackBCD cl
		UnpackBCD dh

;* Note: The BIOS routine does not return 1/100ths sec value, which is required
;*	 by the DOS routine to set the time. Set this to 0.5 secs so that the
;*	 maximum error is 0.5 secs.

		mov	dl,50

;* ch = hours    (0 .. 23)
;* cl = minutes  (0 .. 59)
;* dh = seconds  (0 .. 59)
;* dl = 1/100ths (0 .. 99)

		mov	ah,02dh		;set time
		int	021h		;DOS function

ExitTimeDate:	ret

SetTimeDate	ENDP

LIBCODE		ENDS

;============================================================================

		END

