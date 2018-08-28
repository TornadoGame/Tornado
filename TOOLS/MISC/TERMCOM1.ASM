;****************************************************************************
;*
;* TERMCOM1.ASM
;*
;* 04.05.1989 - KJB
;*
;****************************************************************************

		EXTRN	InitComms:NEAR
		EXTRN	StopComms:NEAR
		EXTRN	SendChar:NEAR
		EXTRN	SendMessage:NEAR
		EXTRN	ReadChar:NEAR
		EXTRN	SetBaudRate:NEAR

		EXTRN	CommsDevice:WORD

		EXTRN	Baud9600:ABS
		EXTRN	Com1:ABS
		EXTRN	Com2:ABS
	
;============================================================================

STACK		SEGMENT PARA STACK 'STACK'
		ASSUME SS:STACK

		db	0200h dup(0)

STACK		ENDS

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

Flag		db	0,0		;b0 = ignore LF if next char

LF		equ	10
CR		equ	13

Msg		db	"BAUD 9600",CR,LF
		db	"8 data bits",CR,LF
		db	"1 start bit",CR,LF
		db	"1 stop bit",CR,LF
		db	"No parity",CR,LF,CR,LF
		db	"Hit ESC to QUIT ...",CR,LF,CR,LF,'$'

DATA		ENDS

;============================================================================

CODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:CODE
		ASSUME DS:DATA

Test:		push	ds   		;save PSP 
		mov	ax,0			
		push	ax    

		cld	    		;auto-increment

		mov	ax,DATA
		mov	ds,ax
		mov	es,ax

		mov	al,0
		out	021h,al

		mov	ax,Baud9600
		call	SetBaudRate

		mov	ax,Com1
		mov	CommsDevice,ax

		call	InitComms

		mov	ah,9
		mov	dx,offset Msg
		int	021h

TalkBack:	mov	ah,1		;has keyboard been touched?
		int	016h
		jz	IncomingData	;no ->		
		mov	ah,0		;get ASCII and scan code
		int	016h
		cmp	ah,1		;ESCape?
		je	Exit		;yes ->
		call	SendChar
IncomingData:	call	ReadChar
		jc	TalkBack

		mov	ah,0		;ignore LF flag set?
		xchg	Flag,ah
		test	ah,1
		jz	NotLF	       	;no ->
		
		cmp	al,LF	
		je	TalkBack	;ignore LF ->
			
NotLF:		cmp	al,CR
		jne	NotCR
		mov	dl,al
		mov	ah,002h
		int	021h		
		mov	al,LF
		or	Flag,001h

NotCR:		mov	dl,al
		mov	ah,002h
		int	021h		
		jmp	short TalkBack

Exit:		call	StopComms

		retf
		
CODE		ENDS

;============================================================================

		END	Test

