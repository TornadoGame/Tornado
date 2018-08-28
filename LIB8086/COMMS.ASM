;****************************************************************************
;*
;* COMMS.ASM
;*
;* Interrupt driven serial comms routines.
;*
;* 01.08.1991 - KJB
;* 06.03.1993 - KJB - Higher Baud rates added.
;* 07.03.1993 - KJB - User abort added to SyncComms.
;* 14.03.1993 - KJB - Controlled sync byte rate added to SyncComms.
;* 03.06.1993 - KJB - Store / restore DOS comms interrupt vector added.
;*
;* Refer to 8088 Assembler Langauge Programming by Willen and Krantz for
;* serial comms information.
;*
;* ISBN: 0-672-22400-3
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	InitComms
		PUBLIC	StopComms
		PUBLIC	SendData
		PUBLIC	SendPacket
		PUBLIC	ReadData
		PUBLIC	SyncComms
		PUBLIC	ClearComms

		PUBLIC	TxQHead
		PUBLIC	RxQHead
		PUBLIC	RxQWtPtr
		PUBLIC	RxQRdPtr
		PUBLIC	TxQWtPtr
		PUBLIC	TxQRdPtr

		PUBLIC	CommsError

		PUBLIC	COM1
		PUBLIC	COM2

		PUBLIC	BAUD50
		PUBLIC	BAUD300
		PUBLIC	BAUD600
		PUBLIC	BAUD1200
		PUBLIC	BAUD2400
		PUBLIC	BAUD4800
		PUBLIC	BAUD9600
		PUBLIC	BAUD14400
		PUBLIC	BAUD19200
		PUBLIC	BAUD38400
		PUBLIC	BAUD57600
		PUBLIC	BAUD115200

		PUBLIC	ERR_TX_OVRFLW
		PUBLIC	ERR_RX_OVRFLW
		PUBLIC	ERR_CHECKSUM 
		PUBLIC	ERR_SYNC_TMOUT
		PUBLIC	ERR_SYNC_ABORT
		PUBLIC	ERR_DATA_TMOUT
		PUBLIC	ERR_NO_CABLE
		PUBLIC	ERR_BREAK
		PUBLIC	ERR_FRAME
		PUBLIC	ERR_PARITY
		PUBLIC	ERR_OVERRUN

		EXTRN	CountDown:WORD
		EXTRN	Ticker:WORD

		EXTRN	Key:BYTE

;============================================================================

		INCLUDE	KEYS.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

;* comms device (COM1: or COM2:) forms UART register ms address

COM1		EQU	3
COM2		EQU	2

CommsDevice	DB	COM1,0

;* DOS comms interrupt vector

DOSVctrSeg	DW	0		;DOS comms intr segment
DOSVctrOff	DW	0		;DOS comms intr offset

;* 8250 UART registers (ls addresses)

TX_HOLD		EQU	0f8h		;tx holding reg
RX_DATA		EQU	0f8h		;rx data reg
LS_BAUD		EQU	0f8h		;Baud rate divisor LSB
MS_BAUD		EQU	0f9h		;Baud rate divisor MSB
INTR_ENABLE	EQU	0f9h		;interrupt enable reg
INTR_IDENT	EQU	0fah		;interrupt identification reg
LINE_CTRL	EQU	0fbh		;line control reg
MODEM_CTRL	EQU	0fch		;modem control reg
LINE_STAT	EQU	0fdh		;line status reg
MODEM_STAT	EQU	0feh		;modem status reg

;* 8259 registers

INTR_CMND	EQU	00020h		;interrupt command reg
INTR_MASK	EQU	00021h		;interrupt mask reg

EOI		EQU	020h		;end-of-interrupt command

;* interrupt vector table locations

COM1_VECTOR	EQU	12		;COM1: interrupt vector address
COM2_VECTOR	EQU	11		;COM2: interrupt vector address

CommsVector	DB	0,0		;comms interrupt wrt device

;* transmit queue (cyclic)

TxQHead		DB	255 dup(0)	;transmit queue
TxQTail		DB	0
TxQWtPtr	DW	OFFSET TxQHead	;tx queue write pointer
TxQRdPtr	DW	OFFSET TxQHead	;tx queue read pointer

;* receive queue (cyclic)

RxQHead		DB	255 dup(0)	;receive queue
RxQTail		DB	0
RxQWtPtr	DW	OFFSET RxQHead	;rx queue write pointer
RxQRdPtr	DW	OFFSET RxQHead	;rx queue read pointer

;* comms error flags
 
CommsError	DW	0

ERR_TX_OVRFLW	EQU	1000000000000000b	;tx queue overflow
ERR_RX_OVRFLW	EQU	0100000000000000b	;rx queue overflow
ERR_CHECKSUM	EQU	0010000000000000b	;checksum error
ERR_SYNC_TMOUT	EQU	0001000000000000b	;sync timeout
ERR_SYNC_ABORT	EQU	0000100000000000b	;sync user abort
ERR_DATA_TMOUT	EQU	0000010000000000b	;data timeout
ERR_NO_CABLE	EQU	0000001000000000b	;no cable

ERR_BREAK	EQU	0000000000010000b	;break detect
ERR_FRAME	EQU	0000000000001000b	;framing error
ERR_PARITY	EQU	0000000000000100b	;parity error
ERR_OVERRUN	EQU	0000000000000010b	;overrun error

;* Baud rates

BAUD50		EQU	0
BAUD300		EQU	2
BAUD600		EQU	4
BAUD1200	EQU	6
BAUD2400	EQU	8
BAUD4800	EQU	10
BAUD9600	EQU	12
BAUD14400	EQU	14
BAUD19200	EQU	16
BAUD38400	EQU	18
BAUD57600	EQU	20
BAUD115200	EQU	22

BaudRate	DW	BAUD9600	;default Baud rate

BaudTable	DW	00900h		;BAUD50
		DW	00180h		;BAUD300
		DW	000c0h		;BAUD600
		DW	00060h		;BAUD1200
		DW	00030h		;BAUD2400
		DW	00018h		;BAUD4800
		DW	0000ch		;BAUD9600
		DW	00008h		;BAUD14400
		DW	00006h		;BAUD19200
		DW	00003h		;BAUD38400
		DW	00002h		;BAUD57600
		DW	00001h		;BAUD115200

SyncByte	DB	0

UserAbort	DB	0		;1 = user abort enabled

		EVEN

DATA		ENDS

;============================================================================

LIBCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:LIBCODE
		ASSUME DS:DATA

;* InitComms - initialize serial comms port
;*
;* pass: al = comms device (COM1 or COM2)
;*       ah = Baud rate
;* ret : nothing
;* kill: assume all

InitComms	PROC	FAR

		mov	CommsDevice,al
		mov	BYTE PTR BaudRate,ah

;* sort interrupt vector wrt comms device

		mov	CommsVector,COM1_VECTOR

		cmp	al,COM1
		je	@F

		mov	CommsVector,COM2_VECTOR

;* disable UART interrupts

@@:		mov	dh,CommsDevice
		mov	dl,INTR_ENABLE
		mov	al,00000000b
		out	dx,al

;-----------------------------------------
;* store interrupt vector wrt comms device
;-----------------------------------------

		push	es

		mov	ah,035h		;DOS Get Interrupt Vector function
		mov	al,CommsVector	;comms interrupt wrt device
		int	021h  		;DOS
		mov	DOSVctrSeg,es
		mov	DOSVctrOff,bx

		pop	es

;---------------------------------------
;* set interrupt vector wrt comms device
;---------------------------------------

		mov	bl,CommsVector

		push	ds

		mov	dx,OFFSET CommsIntr
		mov	ax,SEG CommsIntr
		mov	ds,ax
		mov	ah,025h		;DOS Set Interrupt Vector function
		mov	al,bl		;comms interrupt wrt device
		int	021h		;DOS

		pop	ds

;-----------------
;* initialize UART
;-----------------

		cli

		mov	dh,CommsDevice

;* enable access to Baud rate divisor reg's

		mov	dl,LINE_CTRL
		mov	al,10000000b
		out	dx,al

;* set Baud rate divisor reg's

		mov	bx,BaudRate

		mov	dl,LS_BAUD
		mov	al,BYTE PTR BaudTable[bx+0]    	;Baud rate LSB data
		out	dx,al
		mov	dl,MS_BAUD
		mov	al,BYTE PTR BaudTable[bx+1]	;Baud rate MSB data
		out	dx,al

;* set line control reg

		mov	dl,LINE_CTRL
		mov	al,00000011b	;8 data bits, 1 stop bit, no parity
		out	dx,al

;* set modem control reg

		mov	dl,MODEM_CTRL
		mov	al,00001011b
		out	dx,al

;* set interrupt enable reg

		mov	dl,INTR_ENABLE
		mov	al,00000111b
		out	dx,al

;---------------------------------
;* initialize interrupt controller
;---------------------------------

		mov	al,00000000b	;enable IRQ0 .. IRQ7
		out	INTR_MASK,al

		sti

;* any 'left over' pending intr's will occur NOW, so reset queues afterwards

		call	ClearTxQueue
		call	ClearRxQueue
		call	ClearError

		ret	

InitComms	ENDP

;----------------------------------------------------------------------------

;* StopComms - disable comms interrupts
;*
;* pass: CommsDevice
;* ret : nothing
;* kill: al, dx, flags
;*
;* note: Comms MUST be disabled before exiting program.

StopComms	PROC	FAR

;-----------------------------
;* disable all UART interrupts
;-----------------------------

		mov	dh,CommsDevice
		mov	dl,INTR_ENABLE
		mov	al,00000000b
		out	dx,al

;--------------------------
;* restore interrupt vector
;--------------------------

		mov	bl,CommsVector

		push	ds

		mov	dx,DOSVctrOff
		mov	ax,DOSVctrSeg
		mov	ds,ax
		mov	ah,025h		;DOS Set Interrupt Vector function
		mov	al,bl		;comms interrupt wrt device
		int	021h		;DOS

		pop	ds

		ret

StopComms	ENDP

;----------------------------------------------------------------------------

;* CommsIntr - serial comms interrupt handler
;*
;* pass: nothing
;* ret : nothing
;* kill: nothing
;*
;* note: This routine only handles the following interrupts:-
;*          - error condition interrupt
;*          - data ready interrupt
;*          - transmitter ready interrupt
;*
;*       The modem status changed interrupt should not be enabled.

CommsIntr	PROC	FAR

		push	ax
		push	dx
		push	si
		push	ds

		mov	ax,DATA
		mov	ds,ax

		mov	dh,CommsDevice

;* identify the cause of the interrupt

		mov	dl,INTR_IDENT
		in	al,dx
NextIntr:	and	al,0110b     	;mask out unwanted bits
		cmp	al,0110b	;error condition interrupt?
		je	ErrorIntr	;yes ->
		cmp	al,0100b	;received data ready interrupt?
		je	RxIntr		;yes ->

;* transmitter ready interrupt
		
TxIntr:		mov	si,TxQRdPtr
		cmp	si,TxQWtPtr	;is queue empty?
		je	IntrPending	;yes ->
		mov	al,[si]	
		mov	dl,TX_HOLD
		out	dx,al
		inc	si
		cmp	si,OFFSET TxQTail
		jbe	@F
		mov	si,OFFSET TxQHead
@@:		mov	TxQRdPtr,si
		jmp	IntrPending

;* received data ready interrupt

RxIntr:	 	mov	dl,RX_DATA
		in	al,dx
		mov	si,RxQWtPtr
		mov	[si],al
		inc	si
		cmp	si,OFFSET RxQTail
		jbe	@F
		mov	si,OFFSET RxQHead
@@:		mov	RxQWtPtr,si
		cmp	si,RxQRdPtr    	;queue full?
		jne	IntrPending	;no ->
		or	CommsError,ERR_RX_OVRFLW
		jmp	IntrPending

;* error condition interrupt

ErrorIntr:	mov	dl,LINE_STAT
		in	al,dx
		and	ax,0001eh	;clear unwanted bits
		or	CommsError,ax

;* test to see if any interrupts are pending

IntrPending: 	mov	dl,INTR_IDENT
	     	in	al,dx
	     	test	al,0001b
	     	jz	NextIntr 	;intr pending ->

;* inform the interrupt controller that the interrupt has been serviced

		mov 	al,EOI
		out	INTR_CMND,al

		pop	ds
		pop	si
		pop	dx
		pop	ax

		iret

CommsIntr	ENDP

;----------------------------------------------------------------------------

;* SendData - send data byte
;*
;* pass: al = character
;* ret : nothing
;* kill: ax, dx, si, flags

SendData	PROC	FAR

		cli			;<<<<< IMPORTANT <<<<<

		mov	ah,al

;* if transmit queue empty and transmit holding reg empty then
;*    send char immediately
;* else
;*    put char in transmit queue
;* end

		mov	si,TxQWtPtr
		cmp	si,TxQRdPtr   	;is tx queue empty?
		jne	AddToQueue	;no ->
		mov	dh,CommsDevice
		mov	dl,LINE_STAT
		in	al,dx
		test	al,00100000b	;is tx hold reg empty?
		jz	AddToQueue	;no ->

;* transmit character

		mov	dl,TX_HOLD
		mov	al,ah
		out	dx,al
		jmp	CharSent

;* put char in transmit queue

AddToQueue:	mov	[si],ah
		inc	si

;* check for and handle queue wrap around

		cmp	si,OFFSET TxQTail
		jbe	@F
		mov	si,OFFSET TxQHead

@@:		mov	TxQWtPtr,si

;* check for buffer full

		cmp	si,TxQRdPtr
		jne	CharSent
		or	CommsError,ERR_TX_OVRFLW
		
CharSent:	sti

		ret

SendData	ENDP

;----------------------------------------------------------------------------

;* SendPacket - send packet of data
;*
;* pass: cx = count
;*       ds:si -> data
;* ret : nothing
;* kill: ax, cx, dx, si, flags

SendPacket	PROC	FAR

SendLoop:	lodsb
		push	si
		call	SendData
		pop	si
		loop	SendLoop

		ret

SendPacket	ENDP

;----------------------------------------------------------------------------

;* ReadData - read data byte from the receive queue
;*
;* pass: nothing
;* ret : cf = 0: al = character
;*       cf = 1: al = 0 (receive queue empty)
;* kill: si, flags

ReadData	PROC	FAR

		cli			;<<<<< IMPORTANT <<<<<

;* test if receive queue is empty

		mov	si,RxQRdPtr
		cmp	si,RxQWtPtr
		jne	@F

;* receive queue empty

		xor	al,al
		stc			;cf = 1
		jmp	ReadDataExit

;* read character from receive queue and update pointer

@@:		mov	al,[si]
		inc	si
		cmp	si,OFFSET RxQTail
		jbe	@F
		mov	si,OFFSET RxQHead
@@:		mov	RxQRdPtr,si
		clc		   	;cf = 0
		
ReadDataExit:	sti

		ret		

ReadData	ENDP

;----------------------------------------------------------------------------

;* SyncComms - wait for sync data
;*
;* pass: al = sync data
;*       ah = 0 = user abort disabled
;*	      1 = user abort enabled (Ctrl Q)
;* 	 cx = timeout limit (1/100th sec)
;* ret : cf = 0: sync received
;*       cf = 1: timeout / user abort
;* kill: assume all
;*
;* note: Do NOT use -1 as sync data (-1 received if no cable fitted)

SyncComms	PROC	FAR

		mov	SyncByte,al

		mov	UserAbort,ah

		mov	CountDown,cx

;* wait for transmit queue to empty before sending sync bytes

EmptyLoop:	mov	ax,CountDown
		test	ax,ax		;timeout?
		jz	SyncTimeout	;yes ->

		mov	al,UserAbort	;user abort?
		and	al,Key[K_CTRL]
		and	al,Key[K_Q]
		jnz	SyncUserAbort	;yes ->

		mov	ax,TxQWtPtr
		cmp	ax,TxQRdPtr
		jne	EmptyLoop

		jmp	IntoSync

;* send sync bytes at controlled rate

SyncLoop:	mov	Ticker,0

@@:		cmp	Ticker,2	;50 sync bytes / sec
		jbe	@B

IntoSync:	mov	ax,CountDown
		test	ax,ax		;timeout?
		jz	SyncTimeout	;yes ->

		mov	al,UserAbort	;user abort?
		and	al,Key[K_CTRL]
		and	al,Key[K_Q]
		jnz	SyncUserAbort	;yes ->

		mov	al,SyncByte
		call	SendData
		call	ReadData   
		jc	SyncLoop

		cmp	al,SyncByte	;received sync?
		jne	SyncLoop	;no ->

;* send sync again in case other machine missed the sync

		call	SendData

		clc			;cf = 0 = sync received
		ret

;---------------------------
SyncTimeout	LABEL	NEAR
;---------------------------

		or	CommsError,ERR_SYNC_TMOUT

		stc			;cf = 1	= sync timeout / user abort
		ret

;---------------------------
SyncUserAbort	LABEL	NEAR
;---------------------------

	 	or	CommsError,ERR_SYNC_ABORT

		stc			;cf = 1	= sync timeout / user abort
		ret

SyncComms	ENDP

;----------------------------------------------------------------------------

;* ClearComms
;*
;* pass: nothing
;* ret : nothing
;* kill: nothing

ClearComms	PROC	FAR

		call	ClearTxQueue
		call	ClearRxQueue
		call	ClearError

		ret

ClearComms	ENDP

;----------------------------------------------------------------------------

;* ClearTxQueue - reset transmit queue pointers
;*
;* pass: nothing
;* ret : TxQWtPtr = TxQRdPtr = OFFSET TxQHead
;* kill: nothing

ClearTxQueue	PROC	NEAR

		pushf
		cli
		mov	TxQWtPtr,OFFSET TxQHead
		mov	TxQRdPtr,OFFSET TxQHead
		popf

		ret

ClearTxQueue	ENDP

;----------------------------------------------------------------------------

;* ClearRxQueue - reset receive queue pointers
;*
;* pass: nothing
;* ret : RxQWtPtr = RxQRdPtr = OFFSET RxQHead
;* kill: nothing

ClearRxQueue	PROC	NEAR

		pushf
		cli
		mov	RxQWtPtr,OFFSET RxQHead
		mov	RxQRdPtr,OFFSET RxQHead
		popf

		ret

ClearRxQueue	ENDP

;----------------------------------------------------------------------------

;* ClearError - clear error flags
;*
;* pass: nothing
;* ret : CommsError = 0
;* kill: nothing

ClearError	PROC	NEAR

		pushf
		cli
		mov	CommsError,0
		popf

		ret

ClearError	ENDP

LIBCODE		ENDS

;============================================================================

		END

