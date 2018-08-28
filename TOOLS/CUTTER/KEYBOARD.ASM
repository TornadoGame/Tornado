;****************************************************************************
;*
;* KEYBOARD.ASM
;*
;* Keyboard routines.
;*
;* 15.06.1989 - KJB
;*
;****************************************************************************

		PUBLIC	InstallKbd
		PUBLIC	RestoreKbd

		PUBLIC	Key

		EXTRN	AbortToDOS:FAR

		EXTRN	SSTemp:WORD
		EXTRN	SPTemp:WORD

;============================================================================

		INCLUDE	KEYS.INC

;============================================================================

SYSREQ_ENABLED	EQU	1

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

Key		DB	128 DUP(0)	;0 = key open, 1 = key closed

DOSVctrSeg	DW	0		;DOS keyboard intr segment
DOSVctrOff	DW	0		;DOS keyboard intr offset

DATA		ENDS

;============================================================================

LIBCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:LIBCODE
		ASSUME DS:DATA

;* InstallKbd - set keyboard interrupt vector
;*
;* pass: nothing
;* ret : DOSVctrSeg = DOS keyboard intr segment
;*       DOSVctrOff = DOS keyboard intr offset
;* kill: assume all (DOS routine used)

InstallKbd	PROC	FAR

		push	ds
		push	es

		mov	ah,035h		;DOS Get Interrupt Vector function
		mov	al,009h		;keyboard interrupt
		int	021h  		;DOS
		mov	DOSVctrSeg,es
		mov	DOSVctrOff,bx

		mov	dx,OFFSET KbdIntr
		mov	ax,SEG KbdIntr
		mov	ds,ax
		mov	ah,025h		;DOS Set Interrupt Vector function
		mov	al,009h		;keyboard interrupt
		int	021h		;DOS

		pop	es
		pop	ds
		ret

InstallKbd	ENDP

;----------------------------------------------------------------------------

;* RestoreKbd - restore DOS keyboard interrupt vector
;*
;* pass: DOSVctrSeg = DOS keyboard intr segment
;*       DOSVctrOff = DOS keyboard intr offset
;* ret : nothing
;* kill: assume all (DOS routine used)

RestoreKbd	PROC	FAR

		push	ds
		push	es

		mov	dx,DOSVctrOff
		mov	ax,DOSVctrSeg
		mov	ds,ax
		mov	ah,025h		;DOS Set Interrupt Vector function
		mov	al,009h		;keyboard interrupt
		int	021h		;DOS

		pop	es
		pop	ds
		ret

RestoreKbd	ENDP

;----------------------------------------------------------------------------

;* KbdIntr - keyboard interrupt
;*
;* pass: nothing
;* ret : Key[?] = 0 if key released, = 1 if key pressed
;* kill: nothing
;*
;* A keyboard interrupt occurs whenever a key is pressed or released. 
;* When the interrupt occurs, the keyboard scan code can be read from PPI
;* port A (port number 0060h). If bit 7 is 0 then the key was pressed. If bit
;* 7 was 1 then the key was released.
;*
;* After reading the scan code the keyboard is cleared and enabled by
;* toggling bit 7 of PPI port B.
;*
;* Note that at the end of the interrupt routine it is necessary to inform
;* the interrupt controller (8259A) that the interrupt has been serviced.

KbdIntr		PROC	FAR

		push 	ax
      		push 	bx
      		push 	ds     

	      	mov 	ax,SEG Key
      		mov 	ds,ax

	      	in	al,060h		;al = kbd scan code from PPI port A
  	    	mov	bl,al
    	  	in 	al,061h		;al = current state of PPI port B 
      		or 	al,080h		;set keyboard acknowledge signal		
      		out 	061h,al		;send keyboard acknowledge signal
		and	al,07fh		;reset keyboard acknowledge signal		
      		out 	061h,al		;restore original PPI port B state
   
		xor	al,al		
   		xor 	bh,bh
		shl	bl,1		;cf = 0 = key pressed
		cmc			;cf = 1 = key pressed
		rcl	al,1		;al = 1 = key pressed
		shr	bl,1		;restore bl (bit 7 = 0)
		mov 	Key[bx],al

		mov 	al,020h	    	;send EOI to 8259 command register
      		out 	020h,al

		IF	SYSREQ_ENABLED

		cmp	bx,K_SYSREQ
		je	RetToDOS

		ENDIF
      	
		pop 	ds
      		pop 	bx 
      		pop 	ax
		iret

RetToDOS:	mov	ax,SPTemp
		mov	sp,ax
		mov	ax,SSTemp
		mov	ss,ax

		sti
		jmp	FAR PTR AbortToDOS

KbdIntr		ENDP

LIBCODE		ENDS

;============================================================================

		END

