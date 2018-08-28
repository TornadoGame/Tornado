;****************************************************************************
;*
;* MOUSE.ASM
;*
;* 30.06.1989 - KJB
;*
;****************************************************************************

		PUBLIC	InstallMouse
		PUBLIC	RestoreMouse
		PUBLIC	ResetMouse
		PUBLIC	UpdateMouse
		PUBLIC	SetMousePos
		PUBLIC	GetMouseMotion

		PUBLIC	MouseFlag
		PUBLIC	MouseX
		PUBLIC	MouseY
		PUBLIC	OldMouseX
		PUBLIC	OldMouseY
		PUBLIC	MouseXMin
		PUBLIC	MouseXMax
		PUBLIC	MouseYMin
		PUBLIC	MouseYMax
		PUBLIC	LhsButton
		PUBLIC	RhsButton
		PUBLIC	MidButton
		PUBLIC	OldLhsButton
		PUBLIC	OldRhsButton
		PUBLIC	OldMidButton
			
		EXTRN	Key:BYTE

;============================================================================

		INCLUDE	KEYS.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

MouseFlag	DB	0,0		;1 = mouse driver fitted

MouseX		DW	160
MouseY		DW	100

OldMouseX	DW	160
OldMouseY	DW	100

LhsButton	DB	0,0		;1 = button pressed 
RhsButton	DB	0,0		;1 = button pressed 
MidButton	DB	0,0		;1 = button pressed 

OldLhsButton	DB	0,0		;1 = button pressed 
OldRhsButton	DB	0,0		;1 = button pressed 
OldMidButton	DB	0,0		;1 = button pressed 

MouseXMin	DW	0
MouseXMax	DW	319
MouseYMin	DW	0
MouseYMax	DW	199

MouseAccel	DW	0

SLOW_MOUSE	EQU	2
FAST_MOUSE	EQU	8
TOP_SPEED	EQU	15

DEAD_BAND	EQU	3

MOUSE_RESET	EQU	0
HIDE_CURSOR	EQU	2
GET_POSITION	EQU	3
SET_POSITION	EQU	4
SET_HORIZ	EQU	7
SET_VERT	EQU	8
REL_MOTION	EQU	11
SET_SENSITIVITY	EQU	15

DATA		ENDS

;============================================================================

LIBCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:LIBCODE
		ASSUME DS:DATA

DO_MOUSE	MACRO
		int	033h
		ENDM

;* InstallMouse - check if mouse fitted and if so initialize it
;*
;* pass: nothing
;* ret : MouseFlag
;* kill: assume all (BIOS routines used)

InstallMouse	PROC	FAR

		push	es

		mov	ah,035h		;DOS Get Interrupt Vector function
		mov	al,033h		;mouse interrupt
		int	021h  		;DOS

;* es:bx -> mouse interrupt routine

;* test for null pointer

		mov	ax,es	  
		or	ax,bx
		jz	InstallExit

;* test for first instruction being IRET

		cmp	BYTE PTR es:[bx],0cfh 
		je	InstallExit

		mov	ax,MOUSE_RESET
		DO_MOUSE

		cmp	bx,2		;MicroSoft mouse?
		je	MouseOk		;yes ->
		cmp	bx,3		;Mouse Systems mouse?
		jne	InstallExit	;no, no mouse fitted ->

MouseOk:	mov	MouseFlag,1

		mov	ax,HIDE_CURSOR
		DO_MOUSE		

		mov	ax,SET_HORIZ
		mov	cx,MouseXMin
		mov	dx,MouseXMax
		DO_MOUSE

		mov	ax,SET_VERT
		mov	cx,MouseYMin
		mov	dx,MouseYMax
		DO_MOUSE

		mov	ax,SET_POSITION
		mov	cx,MouseX
		mov	dx,MouseY
		DO_MOUSE

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

		mov	al,MouseFlag
		test	al,al
		jz	RestoreExit

		mov	ax,MOUSE_RESET
		DO_MOUSE

RestoreExit:	ret

RestoreMouse	ENDP

;----------------------------------------------------------------------------

;* ResetMouse
;*
;* pass: MouseFlag
;* ret : nothing
;* kill: assume all (BIOS routines used)
;*
;* note: It is highly recommened that you reset the mouse driver after
;*       changing video modes.

ResetMouse	PROC	FAR

		mov	al,MouseFlag
		test	al,al
		jz	ResetMouseExit

		mov	ax,MOUSE_RESET
		DO_MOUSE

		mov	ax,HIDE_CURSOR
		DO_MOUSE		

		mov	ax,SET_HORIZ
		mov	cx,MouseXMin
		mov	dx,MouseXMax
		DO_MOUSE

		mov	ax,SET_VERT
		mov	cx,MouseYMin
		mov	dx,MouseYMax
		DO_MOUSE

		mov	ax,SET_POSITION
		mov	cx,MouseX
		mov	dx,MouseY
		DO_MOUSE

ResetMouseExit:	ret

ResetMouse	ENDP

;----------------------------------------------------------------------------

;* UpdateMouse - update mouse position
;*
;* pass: MouseX, MouseY, Key[]
;* ret : MouseX, MouseY
;*       OldMouseX, OldMouseY
;*       LhsButton, RhsButton, MidButton
;* kill: assume all (BIOS routines used)
;* note: If mouse driver installed but user is touching cursor keys then
;*       use KbdCtrl. The AMSTRAD PC1640 ECD model gave us problems with
;*       mouse control when keyboard was touched.

UpdateMouse	PROC	FAR

		mov	ax,MouseX
		mov	OldMouseX,ax
		mov	ax,MouseY
		mov	OldMouseY,ax

		mov	al,LhsButton
		mov	OldLhsButton,al
		mov	al,RhsButton
		mov	OldRhsButton,al
		mov	al,MidButton
		mov	OldMidButton,al

		xor	al,al	
		mov	LhsButton,al
		mov	MidButton,al
		mov	RhsButton,al

		mov	al,MouseFlag 	;mouse installed?
		test	al,al
		jz	SkipMouse	;no ->

;* check for keyboard override

		mov	al,Key[K_CRSRLF]			
		or	al,Key[K_CRSRRT]
		or	al,Key[K_CRSRUP]
		or	al,Key[K_CRSRDN]
		jnz	SkipMouse	;override ->
	
		call	MouseCtrl

SkipMouse:	call	KbdCtrl

UpdateExit:	ret

UpdateMouse	ENDP

;----------------------------------------------------------------------------

;* MouseCtrl - use mouse to update pointer
;*
;* pass: Key[]
;* ret : cx = MouseX, dx = MouseY
;*       LhsButton, RhsButton, MidButton
;* kill: assume all (BIOS routines used)
;* note: AMSTRAD machines return button status via Keyboard!

MouseCtrl	PROC	NEAR

		mov	ax,GET_POSITION
		DO_MOUSE
		mov	MouseX,cx
		mov	MouseY,dx

;* test for lhs button

		mov	al,bl
		and	al,001b
		or	al,Key[K_AMS_MOUSELF]
		or	LhsButton,al

;* test for rhs button

		mov	al,bl
		and	al,010b
		shr	al,1
		or	al,Key[K_AMS_MOUSERT]
		or	RhsButton,al
			
;* test for mid button

		mov	al,bl
		and	al,100b
		shr	al,1
		shr	al,1
		or	MidButton,al

		ret

MouseCtrl	ENDP

;----------------------------------------------------------------------------

;* KbdCtrl - use keyboard to update pointer
;*
;* pass: Key[]
;*       MouseXMin, MouseXMax
;*       MouseYMin, MouseYMax
;*	 MouseAccel
;* ret : MouseX, MouseY
;*       LhsButton, RhsButton
;*       MouseAccel
;* kill: assume all (BIOS routines used)
;* note: Mouse movement accelerates from SLOW_MOUSE to FAST_MOUSE after
;*       TOP_SPEED frames. Pressing a shift key accelerates mouse 
;*       immediately.
;*       AMSTRAD 8-way joystick is read via keyboard!

KbdCtrl		PROC	NEAR

;* test for lhs button

		mov	al,Key[K_MOUSELF]
		or	al,Key[K_ENTER]
		or	al,Key[K_AMS_JOYLF]
		or	LhsButton,al

;* test for rhs button

		mov	al,Key[K_MOUSERT]
		or	al,Key[K_AMS_JOYRT]
		or	RhsButton,al

;* update mouse position

		mov	cx,MouseX		   
		mov	dx,MouseY

		mov	bx,SLOW_MOUSE

		mov	ax,MouseAccel
		cmp	ax,TOP_SPEED
		jae	RapidMouse

		mov	al,Key[K_SHIFT1]
		or	al,Key[K_SHIFT2]
		jz	MoveLeft

RapidMouse:	mov	bx,FAST_MOUSE
		mov	MouseAccel,TOP_SPEED

MoveLeft:	mov	al,Key[K_CRSRLF]
		test	al,al
		jz	MoveRight
		sub	cx,bx
		cmp	cx,MouseXMin
		jge	MoveRight
		mov	cx,MouseXMin

MoveRight:	mov	al,Key[K_CRSRRT]
		test	al,al
		jz	MoveUp
		add	cx,bx
		cmp	cx,MouseXMax
		jle	MoveUp
		mov	cx,MouseXMax

MoveUp:		shr	bx,1		;/2 for vertical movement
		mov	al,Key[K_CRSRUP]
		test	al,al
		jz	MoveDown
		sub	dx,bx
		cmp	dx,MouseYMin
		jge	MoveDown
		mov	dx,MouseYMin

MoveDown:    	mov	al,Key[K_CRSRDN]
		test	al,al
		jz	TestMove
		add	dx,bx
		cmp	dx,MouseYMax
		jle	TestMove
		mov	dx,MouseYMax

TestMove:	mov	MouseX,cx
		mov	MouseY,dx
	
		cmp	cx,OldMouseX
		jne	MouseMoved
		cmp	dx,OldMouseY
		jne	MouseMoved

		mov	MouseAccel,0
		jmp	KbdCtrlExit

MouseMoved:	inc	MouseAccel

;* if mouse fitted then set new position

		mov	al,MouseFlag
		test	al,al
		jz	KbdCtrlExit

		mov	ax,SET_POSITION
		DO_MOUSE

KbdCtrlExit:	ret		   	

KbdCtrl		ENDP

;----------------------------------------------------------------------------

;* SetMousePos - set mouse position
;*
;* pass: cx = x pos
;*       dx = y pos
;* ret : MouseX, MouseY
;* kill: assume all (BIOS routines used)

SetMousePos	PROC	FAR

		mov	MouseX,cx
		mov	MouseY,dx

		mov	al,MouseFlag	;mouse installed?
		test	al,al
		jz	SetMouseExit	;no ->

		mov	ax,SET_POSITION
		DO_MOUSE

SetMouseExit:	ret

SetMousePos	ENDP

;----------------------------------------------------------------------------

;* GetMouseMotion - get mouse relative movement
;*
;* pass: DEAD_BAND
;* ret : cx = -1 = move left
;*          =  0 = no movement
;*          = +1 = move right
;*       dx = -1 = move up
;*          =  0 = no movement
;*          = +1 = move down
;* kill: assume all (BIOS routines used)

GetMouseMotion	PROC	FAR

		mov	al,MouseFlag 	;mouse installed?
		test	al,al
		jz	KbdMotion	;no ->

;* check for keyboard override

		mov	al,Key[K_CRSRLF]			
		or	al,Key[K_CRSRRT]
		or	al,Key[K_CRSRUP]
		or	al,Key[K_CRSRDN]
		jnz	KbdMotion	;override ->

;* get mouse motion from mouse
	
		mov	ax,REL_MOTION
		DO_MOUSE

		neg	dx

		mov	ax,dx		;ax = y motion
		cwd			;dx = sign y motion
		xor	ax,dx
		sub	ax,dx		;ax = mod y motion
		cmp	ax,DEAD_BAND
		cmc			;cf = 1 = y motion > DEAD_BAND
		mov	ax,0
		rcl	ax,1		;ax = 1 = y motion > DEAD_BAND
		xor	ax,dx
		sub	ax,dx		;restore sign
		xchg	ax,cx		;ax = x motion
		cwd			;dx = sign x motion
		xor	ax,dx
		sub	ax,dx		;ax = mod x motion
		cmp	ax,DEAD_BAND
		cmc			;cf = 1 = x motion > DEAD_BAND
		mov	ax,0
		rcl	ax,1		;ax = 1 = x motion > DEAD_BAND
		xor	ax,dx
		sub	ax,dx		;restore sign
		mov	dx,ax	   	
		xchg	cx,dx

		jmp	GetMotionExit

;* get mouse motion from keyboard

KbdMotion:	xor  	ax,ax		;al = 0
		sub	al,Key[K_CRSRLF];al = -1 or 0 
		add	al,Key[K_CRSRRT];al = -1 or 0 or +1
		cbw
		mov	cx,ax
		xor  	ax,ax		;al = 0
		sub	al,Key[K_CRSRUP];al = -1 or 0 
		add	al,Key[K_CRSRDN];al = -1 or 0 or +1
		cbw
		mov	dx,ax

GetMotionExit:	ret

GetMouseMotion	ENDP
		
LIBCODE		ENDS

;============================================================================

		END

