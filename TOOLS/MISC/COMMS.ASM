;****************************************************************************
;*
;* COMMS.ASM
;*
;* 04.05.1989 - KJB
;*
;* General purpose RS232 comms routines.
;*
;* IMPORTANT
;* ---------
;*
;* These routines are interrupt driven. In order for them to work you MUST
;* enable the Serial Interface interrupts (see below). Before you exit your
;* program you MUST stop these interrupts. Calling StopComms will do this
;* but you may prefer to disable them using the interrupt controller.
;*
;*		mov	al,0
;* 		out	021h,al		;enable intr's IRQ0 - IRQ7
;*
;****************************************************************************

;* public symbols

		PUBLIC	InitComms
		PUBLIC	StopComms
		PUBLIC	SendChar
		PUBLIC	SendMessage
		PUBLIC	ReadChar
		PUBLIC	SetBaudRate

		PUBLIC	CommsDevice
		PUBLIC 	CommsError

		PUBLIC	Com1
		PUBLIC	Com2

		PUBLIC	Baud50		
		PUBLIC	Baud300		
		PUBLIC	Baud600		
		PUBLIC	Baud1200	
		PUBLIC	Baud2400	
		PUBLIC	Baud4800	
		PUBLIC	Baud9600	
		PUBLIC	Baud19200	

;============================================================================

data	segment para public 'data'
	assume ds:data

CommsDevice	dw	Com1		;3 = com1:, 2 = com2:

;* UART register LS addresses (CommsDevice forms MS address)

TxHold		equ	0f8h		;tx holding reg
RxData		equ	0f8h		;rx data reg
LSBaud		equ	0f8h		;Baud-rate divisor LSB
MSBaud		equ	0f9h		;Baud-rate divisor MSB
IntrEnable	equ	0f9h		;interrupt enable reg
IntrIdent	equ	0fah		;interrupt identification reg
LineCtrl	equ	0fbh		;line-control reg
ModemCtrl	equ	0fch		;modem-control reg
LineStat	equ	0fdh		;line-status reg
ModemStat	equ	0feh		;modem-status reg

;* interrupt vector table locations

Com1Vector	equ	4*12		;com1: interrupt
Com2Vector	equ	4*11		;com2: interrupt

;* comms device reg ms addresses

Com1		equ	3
Com2		equ	2

TxQHead		db	255 dup(0)	;transmit queue
TxQTail		db	0
TxQWtPtr	dw	offset TxQHead	;tx queue write pointer
TxQRdPtr	dw	offset TxQHead	;tx queue read pointer

RxQHead		db	255 dup(0)	;receive queue
RxQTail		db	0
RxQWtPtr	dw	offset RxQHead	;rx queue write pointer
RxQRdPtr	dw	offset RxQHead	;rx queue read pointer

;* comms error flags
;*
;*    b15: tx queue overflow
;*    b14: rx queue overflow
;*    b13: checksum error
;*    b12: sync timeout
;*    b11: data timeout
;*    b10: no cable
;*    b9 : 0
;*    b8 : 0
;*    b7 : 0
;*    b6 : 0
;*    b5 : 0
;*    b4 : break detect
;*    b3 : framing error
;*    b2 : parity error
;*    b1 : overrun error
;*    b0 : 0
 
CommsError	dw	0		;error flags

;* Set up conditions - refer to 8088 Assembler Langauge Programming by
;*                     Willen and Krantz for serial comms register data
;*
;* Default conditions:- 9600 Baud
;*                      8 data bits
;*                      1 stop bit
;*                      no parity

SetUpCond	db	00ch		;Baud-rate divisor LSB
		db	000h		;Baud-rate divisor MSB
		db	00000011b	;line-control reg
		db	00001011b	;modem-control reg
		db	00000111b	;interrupt-enable reg

		even

Baud50		equ	0
Baud300		equ	1
Baud600		equ	2
Baud1200	equ	3
Baud2400	equ	4
Baud4800	equ	5
Baud9600	equ	6
Baud19200	equ	7

BaudList	dw	00900h		;50
		dw	00180h		;300
		dw	000c0h		;600
		dw	00060h		;1200
		dw	00030h		;2400
		dw	00018h		;4800
		dw	0000ch		;9600
		dw	00006h		;19200

data		ends

;============================================================================

code	segment byte public 'code'
	assume cs:code

;* InitComms - initialize serial comms port
;*
;* pass: CommsDevice
;* ret : nothing
;* kill: ax, dx, si, di, flags

InitComms:	cli  			;disable intr's - a really good idea!

;* disable UART intr's then set intr vector address

		mov	dh,byte ptr CommsDevice
		mov	dl,IntrEnable
		mov	al,0
		out	dx,al

		push	es
		mov	ax,0
		mov	es,ax
		mov	di,Com1Vector	;assume com1:
		cmp	dh,Com1		;is it com1:?
		je	GotCommsVctr	;yes ->
		mov	di,Com2Vector
GotCommsVctr:	mov	ax,offset CommsIntr
		stosw
		mov	ax,cs
		stosw
		pop	es

;* set up UART wrt SetUpCond data

		mov	si,offset SetUpCond

;* enable access to Baud-rate divisor reg's

		mov	dl,LineCtrl
		mov	al,10000000b
		out	dx,al

;* set Baud-rate divisor reg's

		mov	dl,LSBaud
		mov	al,[si+0]    	;Baud-rate LSB data
		out	dx,al
		mov	dl,MSBaud
		mov	al,[si+1]	;Baud-rate MSB data
		out	dx,al

;* set line-control reg

		mov	dl,LineCtrl
		mov	al,[si+2]	;line-control data
		out	dx,al

;* set modem-control reg

		mov	dl,ModemCtrl
		mov	al,[si+3]      	;modem-control data
		out	dx,al

;* set interrupt-enable reg

		mov	dl,IntrEnable
		mov	al,[si+4]	;interrupt-enable data
		out	dx,al

		sti

;* any 'left over' pending intr's will occur NOW, so reset queues afterwards

		call	ClearTxQueue
		call	ClearRxQueue
		call	ClearError

		ret	

;----------------------------------------------------------------------------

;* StopComms - disable comms interrupts
;*
;* pass: CommsDevice
;* ret : nothing
;* kill: al, dx, flags

;* disable all UARTS intr's

StopComms:	mov	dh,byte ptr CommsDevice
		mov	dl,IntrEnable
		mov	al,0
		out	dx,al
		ret

;----------------------------------------------------------------------------

;* CommsIntr - serial comms interrupt handler
;*
;* Note: This routine only caters for error condition interrupt, received
;*       data is ready interrupt and transmitter ready interrupt. The modem
;*       status changed interrupt should not be enabled.

CommsIntr:	push	ax
		push	dx
		push	si
		push	ds

		mov	ax,data
		mov	ds,ax

		mov	dh,byte ptr CommsDevice

;* identify the cause of the interrupt

		mov	dl,IntrIdent
		in	al,dx
Again:		and	al,0110b     	;mask out unwanted bits
		cmp	al,0110b	;error condition interrupt?
		je	ErrorIntr	;yes ->
		cmp	al,0100b	;received data ready interrupt?
		je	RxIntr		;yes ->
       
;* transmitter ready interrupt
		
TxIntr:		mov	si,TxQRdPtr
		cmp	si,TxQWtPtr	;is queue empty?
		je	IntrPending	;yes ->
		mov	al,[si]	
		mov	dl,TxHold
		out	dx,al
		inc	si
		cmp	si,offset TxQTail
		jbe	NoTxWrap
		mov	si,offset TxQHead
NoTxWrap:	mov	TxQRdPtr,si
		jmp	short IntrPending

;* received data ready interrupt

RxIntr:		mov	dl,RxData
		in	al,dx
		mov	si,RxQWtPtr
		mov	[si],al
		inc	si
		cmp	si,offset RxQTail
		jbe	NoRxWrap
		mov	si,offset RxQHead
NoRxWrap:	mov	RxQWtPtr,si
		cmp	si,RxQRdPtr    	;queue full?
		jne	IntrPending	;no ->
		or	CommsError,04000h
		jmp	short IntrPending

;* error condition interrupt

ErrorIntr:	mov	dl,LineStat
		in	al,dx
		and	al,01eh		;clear unwanted bits
		mov	byte ptr CommsError,al		

;* test to see if any interrupts are pending

IntrPending: 	mov	dl,IntrIdent
	     	in	al,dx
	     	test	al,0001b
	     	jz	Again		;intr pending ->

;* inform the interrupt controller that the interrupt has been serviced.

		mov 	al,020h
		out	020h,al

		pop	ds
		pop	si
		pop	dx
		pop	ax
		iret

;----------------------------------------------------------------------------

;* SendChar - send character
;*
;* pass: al = character
;* ret : TxQWtPtr may be modified if char is put in transmit queue
;*       CommsError may be modified if transmit queue becomes full
;* kill: ax, dx, si, flags

SendChar:	cli			;disable intr's - important
		mov	ah,al

;* if the transmit queue is empty and the transmit holding reg is empty then
;* send the char immediately else put the char in the transmit queue

		mov	si,TxQWtPtr
		cmp	si,TxQRdPtr   	;is tx queue empty?
		jne	AddToQueue	;no ->
		mov	dh,byte ptr CommsDevice
		mov	dl,LineStat
		in	al,dx
		test	al,00100000b	;is tx hold reg empty?
		jz	AddToQueue	;no ->

;* transmit character

		mov	dl,TxHold
		mov	al,ah
		out	dx,al
		jmp	short CharSent

;* put char in transmit queue

AddToQueue:	mov	[si],ah
		inc	si

;* check for and handle queue wrap around

		cmp	si,offset TxQTail
		jbe	NoWtWrap
		mov	si,offset TxQHead

NoWtWrap:	mov	TxQWtPtr,si

;* check for buffer full

		cmp	si,TxQRdPtr
		jne	CharSent
		or	CommsError,08000h
		
CharSent:	sti
		ret

;----------------------------------------------------------------------------

;* ClearTxQueue - reset transmit queue pointers
;*
;* pass: nothing
;* ret : TxQWtPtr = TxQRdPtr = offset TxQHead
;* kill: nothing

ClearTxQueue:	pushf
		cli
		mov	TxQWtPtr,offset TxQHead
		mov	TxQRdPtr,offset TxQHead
		popf
		ret

;----------------------------------------------------------------------------

;* ClearRxQueue - reset receive queue pointers
;*
;* pass: nothing
;* ret : RxQWtPtr = RxQRdPtr = offset RxQHead
;* kill: nothing

ClearRxQueue:	pushf
		cli
		mov	RxQWtPtr,offset RxQHead
		mov	RxQRdPtr,offset RxQHead
		popf
		ret

;----------------------------------------------------------------------------

;* ClearError - clear error flags
;*
;* pass: nothing
;* ret : CommsError = 0
;* kill: nothing

ClearError:	pushf
		cli
		mov	CommsError,0
		popf
		ret

;----------------------------------------------------------------------------

;* SendMessage - send n characters
;*
;* pass: cx = n characters
;*       si -> data to be sent
;* ret : nothing
;* kill: ax, cx, dx, si, flags

SendMessage:	lodsb
		push	si
		call	SendChar
		pop	si
		loop	SendMessage
		ret

;----------------------------------------------------------------------------

;* ReadChar - read a character from the receive queue
;*
;* pass: nothing
;* ret : cf = 0: al = character
;*       cf = 1: al = 0 (receive queue empty)
;* kill: si, flags

ReadChar:	cli

;* test if receive queue is empty

		mov	si,RxQRdPtr
		cmp	si,RxQWtPtr
		je	NoData

;* read character from receive queue and update pointer

		mov	al,[si]
		inc	si
		cmp	si,offset RxQTail
		jbe	NoRdWrap
		mov	si,offset RxQHead
NoRdWrap:	mov	RxQRdPtr,si
		clc		   	;cf = 0
		jmp	short ReadCharOut

;* receive queue empty

NoData:		xor	al,al
		stc			;cf = 1
		
ReadCharOut:	sti
		ret		

;---------------------------------------------------------------------------- 

;* SetBaudRate - set Baud rate
;*
;* pass: ax = 0 = 50
;*            1 = 300
;*            2 = 600
;*            3 = 1200
;*            4 = 2400
;*            5 = 4800
;*            6 = 9600
;* ret : nothing
;* kill: ax, bx, flags

SetBaudRate:	shl	ax,1
		mov	bx,ax
		mov	ax,BaudList[bx]
		mov	word ptr SetUpCond,ax
		ret

code		ends

;============================================================================

		end
	

