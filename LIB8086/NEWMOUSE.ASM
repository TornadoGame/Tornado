;****************************************************************************
;*
;* NEWMOUSE.ASM
;*
;* 30.03.1992 - KJB
;*
;* 30.06.1989 - KJB - MOUSE.ASM
;* 30.03.1992 - KJB - New mouse routines.
;* 14.04.1992 - KJB - Amstrad mouse "keys" removed.
;* 22.09.1992 - KJB - ReadMouseMotion added.
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	InstallMouse
		PUBLIC	RestoreMouse
		PUBLIC	ResetMouse
		PUBLIC	SetMouseLimits
		PUBLIC	SetMousePos
		PUBLIC	ReadMouse
		PUBLIC	ReadMouseMotion

		PUBLIC	MouseFlag
		PUBLIC	MouseXMin
		PUBLIC	MouseXMax
		PUBLIC	MouseYMin
		PUBLIC	MouseYMax
		PUBLIC	MouseX
		PUBLIC	MouseY
		PUBLIC	_MouseX
		PUBLIC	_MouseY
		PUBLIC	LhsButton
		PUBLIC	RhsButton
		PUBLIC	_LhsButton
		PUBLIC	_RhsButton
		PUBLIC	XMickeys
		PUBLIC	YMickeys

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

MouseFlag	DB	0,0		;1 = mouse driver installed

;-------------------
;* mouse x, y limits
;-------------------

MouseXMin	DW	0
MouseXMax	DW	639
MouseYMin	DW	0
MouseYMax	DW	399

;----------------
;* mouse position
;----------------

MouseX		DW	320
MouseY		DW	200

;-------------------------
;* previous mouse position
;-------------------------

_MouseX		DW	320
_MouseY		DW	200

;-----------------------
;* current button status
;-----------------------

LhsButton	DB	0		;1 = button pressed 
RhsButton	DB	0		;1 = button pressed 

;------------------------
;* previous button status
;------------------------

_LhsButton	DB	0		;1 = button pressed 
_RhsButton	DB	0		;1 = button pressed 

;-----------------------
;* mouse motion counters
;-----------------------

XMickeys	DW	0		;(-32768 .. 32767)
					;> 0 = rightward motion
					;< 0 = leftward motion

YMickeys	DW	0		;(-32768 .. 32767)
					;> 0 = downward motion
					;< 0 = upward motion

;------------------------
;* mouse function equates
;------------------------

MOUSE_RESET	EQU	0
HIDE_CURSOR	EQU	2
GET_POSITION	EQU	3
SET_POSITION	EQU	4
GET_BUTTONS	EQU	5
SET_HORIZ	EQU	7
SET_VERT	EQU	8
GET_MOTION	EQU	11

DATA		ENDS

;============================================================================

LIBCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:LIBCODE
		ASSUME DS:DATA

CALL_MOUSE	MACRO
		int	033h
		ENDM

;----------------------------------------------------------------------------

;* InstallMouse - check if mouse driver installed and if so initialize mouse
;*
;* pass: MouseXMin
;*       MouseXMax
;*       MouseYMin
;*       MouseYMax
;* ret : MouseFlag
;*       if MouseFlag = 1:
;*          MouseX (centred)
;*          MouseY (centred)
;* kill: assume all (BIOS routines used)

InstallMouse	PROC	FAR

		push	es

		mov	ah,035h		;DOS Get Interrupt Vector function
		mov	al,033h		;mouse interrupt
		int	021h  		;DOS

;* test for null pointer (es:bx -> mouse interrupt routine)

		mov	ax,es	  
		or	ax,bx
		jz	InstallExit	;null ptr ->

;* test for first instruction being IRET

		cmp	BYTE PTR ES:[bx],0cfh 
		je	InstallExit	;IRET ->

		mov	ax,MOUSE_RESET
		CALL_MOUSE

		cmp	ax,-1		;installed?
		jne	InstallExit	;no ->

		cmp	bx,2		;2 button mode?
		je	@F		;yes ->
		cmp	bx,3		;3 button mode?
		jne	InstallExit	;no (mouse not recognized) ->

@@:		mov	MouseFlag,1

		mov	ax,HIDE_CURSOR
		CALL_MOUSE		

		call	FAR PTR SetMouseLimits

InstallExit:	pop	es
		ret

InstallMouse	ENDP

;----------------------------------------------------------------------------

;* RestoreMouse - reset mouse if fitted
;*
;* pass: MouseFlag
;* ret : nothing
;* kill: assume all (BIOS routines used)

RestoreMouse	PROC	FAR

		test	MouseFlag,1	;mouse installed?
		jz	@F		;no ->

		mov	ax,MOUSE_RESET
		CALL_MOUSE

@@:		ret

RestoreMouse	ENDP

;----------------------------------------------------------------------------

;* ResetMouse
;*
;* pass: MouseFlag
;*       MouseXMin
;*       MouseXMax
;*       MouseYMin
;*       MouseYMax
;* ret : if MouseFlag = 1:
;*          MouseX (centred)
;*          MouseY (centred)
;* kill: assume all (BIOS routines used)
;*
;* note: The mouse MUST be reset after changing video mode. The graphics
;*	 driver routines reset the mouse after changing video mode so there
;*       should not be any reason to call this routine again. If you do then
;*       be careful because the mouse driver routines may upset any hardware
;*       conditions that you have set up. An example of this is in EGA mode.
;*       The mouse driver actually changes the value of the ENABLE SET/RESET
;* 	 register.

ResetMouse	PROC	FAR

		test	MouseFlag,1	;mouse installed?
		jz	@F		;no ->

		mov	ax,MOUSE_RESET
		CALL_MOUSE

		mov	ax,HIDE_CURSOR
		CALL_MOUSE		

		call	FAR PTR SetMouseLimits

@@:		ret

ResetMouse	ENDP

;----------------------------------------------------------------------------

;* SetMouseLimits - set mouse x, y limits
;*
;* pass: MouseFlag
;*       MouseXMin
;*       MouseXMax
;*       MouseYMin
;*       MouseYMax
;* ret : if MouseFlag = 1:
;*          MouseX = (MouseXMax - MouseXMin) / 2 + MouseXMin (centred)
;*	    MouseY = (MouseYMax - MouseYMin) / 2 + MouseYMin (centred)
;* kill: assume all (BIOS routines used)
;*
;* note: Some mouse drivers tend to only return even values for x position.
;*       Therefore use twice the resolution that you require and divide by
;*       2 (with 1/2 bit round up and upper limit test).

SetMouseLimits	PROC	FAR

		test	MouseFlag,1	;mouse installed?
		jz	@F		;no ->

		mov	ax,SET_HORIZ
		mov	cx,MouseXMin
		mov	dx,MouseXMax
		CALL_MOUSE

		mov	ax,SET_VERT
		mov	cx,MouseYMin
		mov	dx,MouseYMax
		CALL_MOUSE

		mov	cx,MouseXMax
		sub	cx,MouseXMin
		shr	cx,1
		add	cx,MouseXMin

		mov	bx,MouseYMax
		sub	bx,MouseYMin
		shr	bx,1
		add	bx,MouseYMin

		call	FAR PTR SetMousePos

@@:		ret

SetMouseLimits	ENDP

;----------------------------------------------------------------------------

;* SetMousePos - set mouse position
;*
;* pass: cx = x pos (MouseXMin .. MouseXMax)
;*       bx = y pos (MouseYMin .. MouseYMax)
;*       MouseFlag
;* ret : if MouseFlag = 1:
;*          MouseX
;*          MouseY
;*          _MouseX
;*          _MouseY
;* kill: assume all (BIOS routines used)

SetMousePos	PROC	FAR

		test	MouseFlag,1	;mouse installed?
		jz	@F		;no ->

		mov	dx,bx

		mov	MouseX,cx
		mov	MouseY,dx

		mov	_MouseX,cx
		mov	_MouseY,dx

		mov	ax,SET_POSITION
		CALL_MOUSE

@@:		ret

SetMousePos	ENDP

;----------------------------------------------------------------------------

;* ReadMouse - read mouse position / button status
;*
;* pass: MouseFlag
;* ret : al = 1 = lhs button pressed
;*       ah = 1 = rhs button pressed
;*       cx = MouseX
;*       bx = MouseY
;*       dl = 1 = lhs button just pressed
;*       dh = 1 = rhs button just pressed
;* kill: assume all (BIOS routines used)

ReadMouse	PROC	FAR

;* assume mouse not installed

		xor	ax,ax
		xor	dx,dx
		mov	cx,MouseX
		mov	bx,MouseY

		test	MouseFlag,1 	;mouse installed?
		jz	UpdateExit	;no ->

;* store previous mouse position

		mov	ax,MouseX
		mov	_MouseX,ax
		mov	ax,MouseY
		mov	_MouseY,ax

;* store previous button values

		mov	al,LhsButton
		mov	_LhsButton,al
		mov	al,RhsButton
		mov	_RhsButton,al

;* read mouse position / button status

		mov	ax,GET_POSITION
		CALL_MOUSE
		mov	MouseX,cx
		mov	MouseY,dx

		mov	bp,dx		;store y pos

;* test for lhs button

		mov	al,bl
		and	al,001b
		mov	LhsButton,al
		mov	dl,al
		jz	@F		;not pressed ->

		xor	dl,_LhsButton	;1 = just pressed (0 -> 1)

;* test for rhs button

@@:		mov	ah,bl
		and	ah,010b
		shr	ah,1
		mov	RhsButton,ah
		mov	dh,ah
		jz	@F		;not pressed ->

		xor	dh,_RhsButton	;1 = just pressed (0 -> 1)

@@:		mov	bx,bp		;restore y pos
			
UpdateExit:	ret

ReadMouse	ENDP

;----------------------------------------------------------------------------

;* ReadMouseMotion - read mouse motion / button status
;*
;* pass: MouseFlag
;* ret : al = 1 = lhs button pressed
;*       ah = 1 = rhs button pressed
;*       cx = XMickeys (-32768 .. 32767)
;*       bx = YMickeys (-32768 .. 32767)
;*       dl = 1 = lhs button just pressed
;*       dh = 1 = rhs button just pressed
;* kill: assume all (BIOS routines used)

ReadMouseMotion	PROC	FAR

;* assume mouse not installed

		xor	ax,ax
		xor	bx,bx
		xor	cx,cx
		xor	dx,dx

		mov	XMickeys,cx
		mov	YMickeys,dx

		test	MouseFlag,1 	;mouse installed?
		jz	ReadMotionExit	;no ->

;* store previous button values

		mov	al,LhsButton
		mov	_LhsButton,al
		mov	al,RhsButton
		mov	_RhsButton,al

;* read mouse motion

		mov	ax,GET_MOTION
		CALL_MOUSE
		mov	XMickeys,cx
		mov	YMickeys,dx

;* read mouse button status

		mov	ax,GET_BUTTONS
		xor	bx,bx
		CALL_MOUSE

		mov	ah,al		;store rhs button status

;* test for lhs button

		and	al,001b
		mov	LhsButton,al
		mov	dl,al
		jz	@F		;not pressed ->

		xor	dl,_LhsButton	;1 = just pressed (0 -> 1)

;* test for rhs button

@@:		and	ah,010b
		shr	ah,1
		mov	RhsButton,ah
		mov	dh,ah
		jz	@F		;not pressed ->

		xor	dh,_RhsButton	;1 = just pressed (0 -> 1)

;* return motion counters

@@:		mov	cx,XMickeys
		mov	bx,YMickeys

ReadMotionExit:	ret

ReadMouseMotion	ENDP

LIBCODE		ENDS

;============================================================================

		END

