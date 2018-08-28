;****************************************************************************
;*
;* MESSAGES.ASM
;*
;* Message display driver and data.
;*
;* 21.02.1992 - KJB
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	UpdatePilotMsg
		PUBLIC	UpdateNavigMsg
		PUBLIC	DispMessage

		PUBLIC	NullMsg$

		EXTRN	Print$:FAR

		EXTRN	LastFrame:WORD

		EXTRN	SSF_CommsRx:BYTE

;============================================================================

		INCLUDE	\VISUAL\PALETTES.INC

		INCLUDE	\LIB8086\PRINT.INC
		INCLUDE	\LIB8086\USEFUL.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

PILOTX		EQU	124
PILOTY		EQU	114

NAVIGX		EQU	124
NAVIGY		EQU	136

NUM_MSG		EQU	32

MsgQueue	DW	NUM_MSG DUP(OFFSET NullMsg$)

MsgQueueIndex	DW	0

MsgPtr		DW	OFFSET NullMsg$

MsgTimer	DW	0

MsgDelay	DB	0,0		;1 = delay active

CLEAR_DELAY	EQU	25

LONG_DELAY	EQU	5*100

SHORT_DELAY	EQU	2*100

;* message attributes

MSG_SHORT	EQU	00000001b	;0 = long delay
					;1 = short delay
MSG_CLEAR	EQU	00000010b	;0 = leave message displayed after delay
					;1 = clear message after delay
MSG_PRIOR	EQU	00000100b	;0 = low priority (add to tail of queue)
					;1 = high priority (insert at head of queue)
MSG_ALERT	EQU	00001000b	;0 = no sound
					;1 = alert sound
MSG_EXTRN	EQU	00010000b	;0 = message from internal source
					;1 = message from external source

;----------------
;* set up strings
;----------------

COL_LCD		EQU	COL_BLACK

LCDAttr		DB	0ffh,000h,0ffh,000h,077h,000h,COL_LCD,000h

PilotSetUp$	LABEL	BYTE
		P_OVER1
		P_CHAR2
		PD_XY	PILOTX,PILOTY
		PV_ATTR	LCDAttr
		P_END

NavigSetUp$	LABEL	BYTE
		P_OVER1
		P_CHAR2
		PD_XY	NAVIGX,NAVIGY
		PV_ATTR	LCDAttr
		P_END

;-----------------
;* message strings
;-----------------

;* Message Format
;* --------------
;*
;* Attribute byte followed by 2 lines of 19 characters (standard Print$
;* format string). For example:-
;*
;* Msg$		LABEL	BYTE
;*		DB	MSG_CLEAR+MSG_PRIOR+MSG_ALERT
;*		DB	" AUTO-PILOT SYSTEM"
;*		PD_XYMV	-14*4,6
;*		DB	"MALFUNCTION"
;*		P_END

NullMsg$	LABEL	BYTE
		DB	0
		P_END

		EVEN

DATA		ENDS

;============================================================================

PANCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:PANCODE
		ASSUME DS:DATA

;* UpdatePilotMsg
;* UpdateNavigMsg
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

UpdateNavigMsg	LABEL	NEAR

		mov	si,OFFSET NavigSetUp$

		jmp	ContUpdateMsg

UpdatePilotMsg	PROC	NEAR

		mov	si,OFFSET PilotSetUp$

ContUpdateMsg:	call	Print$

;* update message timer

		mov	ax,MsgTimer
		sub	ax,LastFrame
		MINM	ax
		mov	MsgTimer,ax

		jnz	DispMsg		;message still being displayed ->

;* check for empty queue

		cmp	MsgQueueIndex,0	;empty queue?
		jne	NextMsg		;no ->

;* empty queue, clear last message?

		mov	si,MsgPtr

		test	BYTE PTR [si],MSG_CLEAR	;clear message?
		jz	DispMsg			;no ->

		mov	MsgPtr,OFFSET NullMsg$

		jmp	DispMsg

;* clear display for short period (visual effect) or disp next message?

NextMsg:	xor	MsgDelay,1	;clear display?
		jz	@F		;no ->

		mov	MsgPtr,OFFSET NullMsg$

		mov	MsgTimer,CLEAR_DELAY

		jmp	DispMsg

;* fetch next message from queue

@@:		mov	si,MsgQueue[0]

		mov	MsgPtr,si

;* sort display period

		mov	ax,LONG_DELAY	;assume long delay

		test	BYTE PTR [si],MSG_SHORT	;short delay?
		jz	@F			;* no ->

		mov	ax,SHORT_DELAY

@@:		mov	MsgTimer,ax

;* sort alert

		test	BYTE PTR [si],MSG_ALERT	;alert sound?
		jz	@F			;no ->

;* move queue along

@@:		sub	MsgQueueIndex,2

		mov	cx,NUM_MSG-1
		mov	si,OFFSET MsgQueue+2
		mov	di,OFFSET MsgQueue
		rep	movsw

DispMsg:	mov	si,MsgPtr

		inc	si		;ignore attribute byte

		call	Print$

		ret

UpdatePilotMsg	ENDP

;----------------------------------------------------------------------------

;* DispMessage
;*
;* pass: si -> message string
;* ret : cf = 0 = message added to queue
;*       cf = 1 = queue full (message ignored)
;* kill: assume all

DispMessage	PROC	FAR

		mov	bx,MsgQueueIndex

;* if comms reciever damaged then ignore external messages

		test	SSF_CommsRx,1	;damaged?
		jz	@F		;no ->

		test	BYTE PTR [si],MSG_EXTRN	;external message?
		jnz	MsgOk			;yes ->

;* sort message priority

@@:		test	BYTE PTR [si],MSG_PRIOR	;high priority message?
		jz	LowPriority		;no ->

;* high priority message - insert at head of queue (regardless of queue full)

		mov	bp,si

		mov	cx,NUM_MSG-1
		mov	si,OFFSET MsgQueue+(NUM_MSG-2)*2
		mov	di,OFFSET MsgQueue+(NUM_MSG-1)*2
		std
		rep	movsw
		cld

		mov	si,bp

		mov	MsgQueue[0],si

		cmp	bx,NUM_MSG*2	;was queue full?
		je	MsgOk		;yes ->

		add	bx,2

		jmp	MsgOk

;* low priority message - add to tail of queue (if room)

LowPriority:	cmp	bx,NUM_MSG*2	;queue full?
		je	QueueFull	;yes ->

		mov	MsgQueue[bx],si

		add	bx,2

MsgOk:		mov	MsgQueueIndex,bx

		clc			;message added to queue
		ret

QueueFull:	stc			;queue full, message ignored
		ret

DispMessage	ENDP

PANCODE		ENDS

;============================================================================

		END

