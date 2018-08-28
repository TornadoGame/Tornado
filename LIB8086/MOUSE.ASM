;****************************************************************************
;*
;* MOUSE.ASM
;*
;* 30.06.1989 - KJB
;* 31.03.1992 - KJB - TestInsideBoxes, ShowMouse and HideMouse routines
;*                    moved from MISCLIB.ASM into this module.
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	InstallMouse
		PUBLIC	RestoreMouse
		PUBLIC	ResetMouse
		PUBLIC	UpdateMouse
		PUBLIC	GameMouse
		PUBLIC	SetMousePos
		PUBLIC	SetMousePtr
		PUBLIC	ScanMouse
		PUBLIC	TestInsideBoxes
		PUBLIC	TestInsideBox
		PUBLIC	ShowMouse
		PUBLIC	HideMouse

		PUBLIC	MouseFlag
		PUBLIC	MouseSprite
		PUBLIC	MouseX
		PUBLIC	MouseY
		PUBLIC	MousePtr
		PUBLIC	MouseHotX
		PUBLIC	MouseHotY
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
		PUBLIC	StandardPtr
		PUBLIC	MouseLeft	
		PUBLIC	MouseRight	
		PUBLIC	MouseUp		
		PUBLIC	MouseDown	
		PUBLIC	MouseFire	

		EXTRN	SSprite:FAR
		EXTRN	LoadMouseBGnd:FAR
		EXTRN	SaveMouseBGnd:FAR

		EXTRN	StndPtr:WORD
			
		EXTRN	Key:BYTE

;============================================================================

		INCLUDE	KEYS.INC
		INCLUDE	DIALOG.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

MouseFlag	DB	0,0		;1 = mouse driver fitted

MouseSprite	LABEL	WORD
MouseX		DW	160
MouseY		DW	100
MousePtr	DW	0
MouseHotX	DW	0
MouseHotY	DW	0

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

;* digital mouse flags

MouseLeft	DB	0
MouseRight	DB	0
MouseUp		DB	0
MouseDown	DB	0
MouseFire	DB	0

		EVEN

SLOW_MOUSE	EQU	2
FAST_MOUSE	EQU	8
TOP_SPEED	EQU	15

MOUSE_RESET	EQU	0
HIDE_CURSOR	EQU	2
GET_POSITION	EQU	3
SET_POSITION	EQU	4
SET_HORIZ	EQU	7
SET_VERT	EQU	8

;* mouse pointer data block format:-
;*
;* 		DW	sprite ptr
;*		DW	hot spot x offset (from top lh corner)
;*		DW	hot spot y offset (from top lh corner)

;* standard mouse pointer

StandardPtr	DW	OFFSET StndPtr
		DW	0
		DW	0

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
		jz	InitMousePtr

;* test for first instruction being IRET

		cmp	BYTE PTR es:[bx],0cfh 
		je	InitMousePtr

		mov	ax,MOUSE_RESET
		DO_MOUSE

		cmp	bx,2		;MicroSoft mouse?
		je	MouseOk		;yes ->
		cmp	bx,3		;Mouse Systems mouse?
		jne	InitMousePtr	;no, no mouse fitted ->

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

InitMousePtr:	mov	si,OFFSET StandardPtr
		call	FAR PTR SetMousePtr

		pop	es
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
;* note: The mouse MUST be reset after changing video mode. The graphics
;*	 driver routines reset the mouse after changing video mode so there
;*       should not be any reason to call this routine again. If you do then
;*       be careful because the mouse driver routines may upset any hardware
;*       conditions that you have set up. An example of this is in EGA mode.
;*       The mouse driver actually changes the value of the ENABLE SET/RESET
;* 	 register.

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
;*       OldLhsButton, OldRhsButton, OldMidButton
;* kill: assume all (BIOS routines used)
;* note: If mouse driver installed but user is touching cursor keys then
;*       use KbdCtrl. The AMSTRAD PC1640 ECD model gave us problems with
;*       mouse control when the cursor keys were used.

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

;* GameMouse - mouse control during game
;*
;* pass: MouseX, MouseY, Key[]
;* ret : MouseX, MouseY
;*       LhsButton, RhsButton, MidButton
;* kill: assume all (BIOS routines used)
;*       It is assume that: MouseXMin = 0, MouseXMax = 319
;*                          MouseYMin = 0, MouseYMax = 199

GameMouse	PROC	FAR

		xor	al,al
		mov	MouseLeft,al
		mov	MouseRight,al
		mov	MouseUp,al
		mov	MouseDown,al
		mov	MouseFire,al
		
		mov	al,MouseFlag 	;mouse installed?
		test	al,al
		jz	GameMouseExit	;no ->

		xor	al,al	
		mov	LhsButton,al
		mov	MidButton,al
		mov	RhsButton,al

;* check for keyboard override

		mov	al,Key[K_CRSRLF]			
		or	al,Key[K_CRSRRT]
		or	al,Key[K_CRSRUP]
		or	al,Key[K_CRSRDN]
		jnz	GameMouseExit	;override ->
	
		call	MouseCtrl

;* test for left

		mov	ax,MouseX
		cmp	ax,319*1/3	;cf = 1 = left
		mov	al,0
		rcl	al,1
		mov	MouseLeft,al

;* test for right

		mov	ax,MouseX
		cmp	ax,319*2/3	;cf = 0 = right
		cmc
		mov	al,0
		rcl	al,1
		mov	MouseRight,al

;* test for up
		
		mov	ax,MouseY
		cmp	ax,199*1/3	;cf = 1 = up
		mov	al,0
		rcl	al,1
		mov	MouseUp,al

;* test for down
		
		mov	ax,MouseY
		cmp	ax,199*2/3	;cf = 0 = down
		cmc
		mov	al,0
		rcl	al,1
		mov	MouseDown,al

;* test for fire

		mov	al,LhsButton
		or	al,RhsButton
		or	al,MidButton
		mov	MouseFire,al

GameMouseExit:	ret

GameMouse	ENDP

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
		or	al,Key[K_AMS_JOYF1]
		or	LhsButton,al

;* test for rhs button

		mov	al,Key[K_MOUSERT]
		or	al,Key[K_AMS_JOYF2]
		or	RhsButton,al

;* update mouse position

		mov	cx,MouseX		   
		mov	dx,MouseY

		mov	bx,SLOW_MOUSE

		mov	ax,MouseAccel
		cmp	ax,TOP_SPEED
		jae	RapidMouse

		mov	al,Key[K_SHIFT]
		test	al,al
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

		mov	ax,MouseX
		mov	OldMouseX,ax
		mov	ax,MouseY
		mov	OldMouseY,ax
			
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

;* SetMousePtr - set mouse pointer
;*
;* pass: si -> mouse pointer data block
;* ret : MousePtr
;*       MouseHotX
;*       MouseHotY
;* kill: ax

SetMousePtr	PROC	FAR

		mov	ax,[si+0]
		mov	MousePtr,ax
		mov	ax,[si+2]
		mov	MouseHotX,ax
		mov	ax,[si+4]
		mov	MouseHotY,ax
		ret

SetMousePtr	ENDP

;----------------------------------------------------------------------------

;* ScanMouse - scan mouse buttons to see if any have just been pressed
;*
;* pass: LhsButton
;*	 RhsButton
;*	 MidButton
;*	 OldLhsButton
;*	 OldRhsButton
;*	 OldMidButton
;* ret : cf = 1 = button pressed, al = button number (see note)
;*       cf = 0 = no button pressed, al = 0
;* kill: ah, flags
;* note: lhs button = 1
;*       rhs button = 2
;*       mid button = 3

ScanMouse	PROC	FAR

		mov	ah,1
		mov	al,OldLhsButton
		cmp	al,LhsButton	;cf = 1 if old = 0 and new = 1 (only)
		jc	Pressed		;button just pressed ->

		mov	ah,2
		mov	al,OldRhsButton
		cmp	al,RhsButton	;cf = 1 if old = 0 and new = 1 (only)
		jc	Pressed		;button just pressed ->

		mov	ah,3
		mov	al,OldMidButton
		cmp	al,MidButton	;cf = 1 if old = 0 and new = 1 (only)
		jc	Pressed		;button just pressed ->

		xor	ah,ah		;cf = 0

Pressed:	mov	al,ah		
		ret

ScanMouse	ENDP

;----------------------------------------------------------------------------

;* TestInsideBoxes - test if mouse is "inside" any box from a given list
;*
;* pass: si -> box list
;* ret : cf = 1 = inside box, ax = box number (starting from 0)
;*       cf = 0 = not inside box
;* kill: bx, cx, dx, si, bp, flags
;*
;* note: Refer to DIALOG.INC for RECT data strucure.
;*
;* Format of box list:-
;*
;*		RECT	<x, y, width, depth>	;0
;*		RECT	<x, y, width, depth>	;1
;*		RECT	<x, y, width, depth>	;2
;*               ..              ..
;*		RECT	<x, y, width, depth>	;n
;*		ENDRECT

TestInsideBoxes	PROC	FAR

		xor	bp,bp		;reset counter

TestNextBox:	mov	ax,RECT_X[si]
		cmp	ax,END_LIST	;end of list?
		je	TestBoxFail	;yes ->

		mov	cx,ax
		mov	ax,RECT_Y[si]
		mov	bl,al
		mov	ax,RECT_WIDTH[si]
		mov	dx,ax
		mov	ax,RECT_DEPTH[si]
		mov	bh,al

		call	FAR PTR TestInsideBox	;inside this box?
		jc	TestBoxPass		;yes ->

		inc	bp		;next box
		add	si,RECT_REC_SIZE
		jmp	TestNextBox	

TestBoxPass:	mov	ax,bp
		ret

TestBoxFail:	xor	ax,ax		;cf = 0
		ret
		
TestInsideBoxes	ENDP
 
;----------------------------------------------------------------------------

;* TestInsideBox - test if MouseX, MouseY is "inside" a given box
;*
;* pass: cx = x top lh corner
;*       bl = y top lh corner
;*       dx = width
;*       bh = depth
;*       MouseX
;*       MouseY
;*       MouseHotX
;*       MouseHotY
;* ret : cf = 1 = inside
;* kill: ax, bx, cx, flags

TestInsideBox	PROC	FAR

		mov	ax,MouseX
		add	ax,MouseHotX

		cmp	ax,cx
		jb	NotInside
		add	cx,dx
		cmp	ax,cx
		jae	NotInside
		
		mov	ax,MouseY
		add	ax,MouseHotY

		cmp	al,bl
		jb	NotInside
		add	bl,bh
		cmp	al,bl
		jae	NotInside

		stc			;cf = 1	
		ret

NotInside:	clc			;cf = 0
		ret

TestInsideBox	ENDP

;----------------------------------------------------------------------------

;* ShowMouse - save mouse background and draw mouse
;*
;* pass: MouseX
;*       MouseY
;* ret:  MouseHouse[]
;* kill: assume all

ShowMouse	PROC	FAR

		call	SaveMouseBGnd
		mov	si,OFFSET MouseSprite
		call	SSprite
		ret

ShowMouse	ENDP

;----------------------------------------------------------------------------

;* HideMouse - reload mouse background
;*
;* pass: MouseX
;*       MouseY
;*       MouseHouse[]
;* ret : nothing
;* kill: assume all
;*
;* note: Only call this routine after ShowMouse has been called.

HideMouse	PROC	FAR

		call	LoadMouseBGnd
		ret

HideMouse	ENDP

LIBCODE		ENDS

;============================================================================

		END

