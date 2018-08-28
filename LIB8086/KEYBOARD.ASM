;****************************************************************************
;*
;* KEYBOARD.ASM
;*
;* Keyboard routines.
;*
;* 15.06.1989 - KJB
;* 13.08.1991 - KJB - KbdIntr modified (shift keys mapped together).
;* 27.08.1991 - KJB - KbdIntr modified ("+" keys mapped together).
;*                  - KbdIntr modified ("-" keys mapped together).
;* 25.02.1991 - KJB - KbdIntr modified to exchange ss:sp with SPTemp and
;*                    SSTemp at RetToDOS (useful for debugging).
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	InstallKbd
		PUBLIC	RestoreKbd
		PUBLIC	ClearKeyBuffer

		PUBLIC	Key

		EXTRN	AbortToDOS:FAR

		EXTRN	SSTemp:WORD
		EXTRN	SPTemp:WORD

;============================================================================

		INCLUDE	KEYS.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

SYSREQ_ENABLED	EQU	0		;1 = enabled, 0 = disabled

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
;* 7 is 1 then the key was released.
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

;* map shift keys together

		cmp	bx,K_SHIFT1	;shift key 1 pressed?
		je	FixShiftKey2	;yes ->		
		cmp	bx,K_SHIFT2	;shift key 2 pressed?
		je	FixShiftKey1	;yes ->		

;* map "+" keys together

		cmp	bx,K_PLUS	;QWERTY "+" key pressed?
		je	FixPlusKey2	;yes ->
		cmp	bx,K_PAD_PLUS	;numeric key pad "+" key pressed?
		je	FixPlusKey1	;yes ->

;* map "-" keys together

		cmp	bx,K_MINUS	;QWERTY "-" key pressed?
		je	FixMinusKey2	;yes ->
		cmp	bx,K_PAD_MINUS	;numeric key pad "-" key pressed?
		je	FixMinusKey1	;yes ->

KeysFixed:	mov 	al,020h	    	;send EOI to 8259 command register
      		out 	020h,al

		IF	SYSREQ_ENABLED

		cmp	bx,K_SYSREQ
		je	RetToDOS

		ENDIF
      	
		pop 	ds
      		pop 	bx 
      		pop 	ax
		iret

FixShiftKey2:	mov	Key[K_SHIFT2],al
		jmp	KeysFixed

FixShiftKey1:	mov	Key[K_SHIFT1],al
		jmp	KeysFixed

FixPlusKey2:	mov	Key[K_PAD_PLUS],al
		jmp	KeysFixed

FixPlusKey1:	mov	Key[K_PLUS],al
		jmp	KeysFixed

FixMinusKey2:	mov	Key[K_PAD_MINUS],al
		jmp	KeysFixed

FixMinusKey1:	mov	Key[K_MINUS],al
		jmp	KeysFixed

RetToDOS:	mov	ax,sp
		xchg	ax,SPTemp
		mov	sp,ax
		mov	ax,ss
		xchg	ax,SSTemp
		mov	ss,ax

		sti
		jmp	FAR PTR AbortToDOS

KbdIntr		ENDP

;----------------------------------------------------------------------------

;* ClearKeyBuffer - clear Key[] array
;*
;* pass: nothing
;* ret : Key[] = 0
;* kill: al, cx, di, flags

ClearKeyBuffer	PROC	FAR

		xor	al,al
		mov	cx,SIZE Key
		mov	di,OFFSET Key
		rep	stosb
		ret

ClearKeyBuffer	ENDP

LIBCODE		ENDS

;============================================================================

		END

