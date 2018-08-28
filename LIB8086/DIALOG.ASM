;****************************************************************************
;*
;* DIALOG.ASM
;*
;* Dialog box handler.
;*
;* 20.01.1990 - KJB
;*
;* 19.06.1991 - KJB - OPTION changed to OPTYPE for MASM v6.00 compatibilty.
;* 30.08.1991 - KJB - New dialog box format implemented.
;*
;* Data structure for dialog box:-
;*
;*	DIALOG	<x org, y org, width, depth, text ptr [, default][, status]>
;*
;*	OPTYPE	<action ptr [, param 1 [, param 2 [, param 3 [, param 4]]]]> )
;*	BUTTON	<x offset, y offset>   ) may specify from 1 to	             ) may specify
;*	BUTTON	<x offset, y offset>   ) 16 buttons per option	             ) from 1 to 
;*        ..			       ) but must not exceed	             ) 10 options
;*	BUTTON	<x offset, y offset>   ) 16 buttons per dialog	             ) per dialog
;*	ENDOPT						       	             )
;*
;*	ENDBOX
;*
;* Refer to DIALOG.INC for data structures.
;*
;* Square brackets [] show optional parameters.
;*
;* DIALOG:-
;*
;*    x org     : x origin of top left hand corner of dialog box (fixed to 8
;*                8 pixel boundary)
;*    y org     : y origin of top left hand corner of dialog box
;*    width     : width of dialog box (fixed to multiple of 8 pixels)
;*    depth	: depth of dialog box
;*    text ptr  : pointer to dialog box text string
;*    default   : default option (mapped to space bar)
;*    status    : status of button bits, may optionally specify initial status
;*
;* OPTYPE:-
;*
;*   action     : pointer to subroutine on which to act when option is selected
;*   param 1	: ) option parameters which may be required for the specified
;*   param 2    : ) action routine (ie. a number entry action may require a
;*   param 3    : ) string pointer, an entry field pointer, a lower limit and
;*   param 4	: ) an upper limit)
;*
;* BUTTON:-
;*
;*   x offset   : x offset of button centre from x org
;*   y offset   : y offset of button centre from y org
;*
;* ENDOPT and ENDBOX are list terminators (test for equality with END_LIST).
;*
;* Most "action" routines will be universal, but any specific routines can be
;* added as long as the subroutine is in the LIBCODE segment.
;*
;* Keyboard input:-
;*
;* The first option is mapped to function key F1, the next to F2 and so on
;* up to F10 (which is why there are a maximum of 10 options allowed).
;*
;* The SPACE BAR is mapped to the default option (if any).
;*
;* The ESC key closes the dialog.
;*
;* Note:-
;*
;* It is assumed that the mouse pointer has been initialized and is visible.
;*
;* It is assumed that the "download" mode is set to MENU_MODE.
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	DialogBox

		PUBLIC	TOGGLE
		PUBLIC	SELECT
		PUBLIC	CLOSE
		PUBLIC	ENTER_STR
		PUBLIC	ENTER_NUM

		PUBLIC	BoxXOrigin
		PUBLIC	BoxYOrigin

		EXTRN	BlockFill:FAR
		EXTRN	DrawRectangle:FAR
		EXTRN	SSprite:FAR
		EXTRN	QSprite:FAR
		EXTRN	DownLoad:FAR
		EXTRN	ShowMouse:FAR
		EXTRN	HideMouse:FAR
		EXTRN	UpdateMouse:FAR
		EXTRN	ScanMouse:FAR
		EXTRN	SaveScreen:FAR
		EXTRN	LoadScreen:FAR
		EXTRN	Print$:FAR
		EXTRN	Input$:FAR
		EXTRN	UpdateMenuKeys:FAR
		EXTRN	ScanMenuKeys:FAR
		EXTRN	TestInsideBox:FAR
		EXTRN	ConvNum$:FAR

		EXTRN	Sprite:WORD
		EXTRN	SpriteX:WORD
		EXTRN	SpriteY:WORD
		EXTRN	SpritePtr:WORD

		EXTRN	CloseSymbol:WORD
		EXTRN	Button0:WORD
		EXTRN	Button1:WORD
		
		EXTRN	Key:BYTE
		EXTRN	InputMode:BYTE
	
;============================================================================

		INCLUDE	KEYS.INC
		INCLUDE	PRINT.INC
		INCLUDE	DIALOG.INC
		INCLUDE	PALETTES.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

;* button size

BUT_WIDTH	EQU	12
BUT_DEPTH	EQU	12

;* close symbol size

CLOSE_WIDTH	EQU	15
CLOSE_DEPTH	EQU	12

;* parsed box data

DialogPtr	DW	0		;dialog data ptr

BoxXOrigin  	DW	0		;must be on 8 pixel boundary
BoxYOrigin  	DW	0		

BoxWidth	DW	0		;multiple of 8 pixels
BoxDepth	DW	0

BoxXCorner	DW	0		;x origin + box width - 1
BoxYCorner	DW	0		;y origin + box depth - 1

TextPtr		DW	0		;text string pointer

DefaultPtr	DW	0		;default option pointer

Status		DW	0		;button status

Param1		DW	0		;)
Param2		DW	0		;) temp parameter store
Param3		DW	0		;)
Param4		DW	0		;)

;* options table

OptTable	ACTION	NUM_OPTIONS DUP(<>)

;* target buttons table

TgtTable	TARGET	NUM_BUTTONS DUP(<>)	

;* miscellaneous

CloseFlag	DB	0,0		;1 = close dialog box

ButtonList	DW	OFFSET Button0	;button off
		DW	OFFSET Button1	;button on

ButtonMask	DW	0		;mask for selected button

DATA		ENDS

;============================================================================

LIBCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:LIBCODE
		ASSUME DS:DATA

;* DialogBox - handle dialog box
;*
;* pass: si -> dialog box data
;* ret : ax = button status
;* kill: bx, cx, dx, si, di, bp, flags

DialogBox	PROC	FAR

		call	ParseDialog
		call	OpenDialog

DialogLoop:	call	HideMouse
		call	UpdateMouse
		call	UpdateMenuKeys

		call	DialogControl

		call	ShowMouse
		call	DownLoad
		
		mov	al,CloseFlag
		test	al,al		;close dialog box?
		jz	DialogLoop 	;no ->

		call	CloseDialog

		ret

DialogBox	ENDP

;----------------------------------------------------------------------------

;* ParseDialog - check dialog data is ok and initialize variables
;*
;* pass: si -> dialog box data
;* ret : DialogPtr
;* kill: assume all

ParseDialog	PROC	NEAR

		mov	DialogPtr,si	

		mov	ax,BOX_X_ORG[si]
		and	ax,0fff8h	;fix x origin to 8 pixel boundary
		mov	BoxXOrigin,ax

		mov	ax,BOX_Y_ORG[si]
		mov	BoxYOrigin,ax

		mov	ax,BOX_WIDTH[si]
		shr	ax,1		;/2
		shr	ax,1		;/4
		shr	ax,1		;/8
		adc	ax,0		;1/2 bit round up
		shl	ax,1		;*2
		shl	ax,1		;*4
		shl	ax,1		;*8
		mov	BoxWidth,ax	;multiple of 8 pixels

		mov	ax,BOX_DEPTH[si]
		mov	BoxDepth,ax

;* calc bottom rh corner co-ords

		mov	ax,BoxXOrigin
		add	ax,BoxWidth
		dec	ax
		mov	BoxXCorner,ax

		mov	ax,BoxYOrigin
		add	ax,BoxDepth
		dec	ax
		mov	BYTE PTR BoxYCorner,al

;* miscellaneous data

		mov	ax,BOX_TEXT[si]
		mov	TextPtr,ax

		mov	ax,BOX_OPTION[si]
		mov	DefaultPtr,ax

		mov	ax,BOX_STATUS[si]
		mov	Status,ax

		mov	CloseFlag,0	

;* initialize OptTable[] and TgtTable[]

		mov	ax,NULL

		mov	cx,(NUM_OPTIONS*ACT_REC_SIZE)/2
		mov	di,OFFSET OptTable
		rep	stosw

		mov	cx,(NUM_BUTTONS*TGT_REC_SIZE)/2
		mov	di,OFFSET TgtTable
		rep	stosw

;* calc option pointers, masks and button co-ords etc.

		add	si,BOX_REC_SIZE	;si -> option data

		mov	bx,OFFSET OptTable
		mov	di,OFFSET TgtTable

		mov	cx,NUM_OPTIONS

		mov	bp,00001h	;button mask

InitOptionLoop:	mov	ax,OPT_ACTION[si]
		cmp	ax,END_LIST  	;end of option list?
		je	InitOptionDone	;yes ->

		mov	ACT_PTR[bx],si	;store action pointer

		xor	dx,dx		;clear mask

		add	si,OPT_REC_SIZE	;si -> button data

InitButtonLoop:	mov	ax,BUT_X_OFF[si]
		cmp	ax,END_LIST	;end of button list?
		je	InitButtonDone	;yes ->

		mov	TGT_ACT[di],bx	;store ptr to corresponding action data

		add	ax,BoxXOrigin
		mov	TGT_X[di],ax	;store x co-ord
		mov	ax,BUT_Y_OFF[si]
		add	ax,BoxYOrigin
		mov	TGT_Y[di],ax	;store y co-ord

		or	dx,bp		;set mask

		add	si,BUT_REC_SIZE	;si -> next button data
		add	di,TGT_REC_SIZE	;next target button record

		shl	bp,1		;next mask (cf = 1 = mask full)
		jnc	InitButtonLoop	;mask not full, next button ->

InitButtonDone:	mov	ax,dx
		not	ax
		mov	ACT_OUT[bx],ax	;set "out" mask

		mov	ax,Status
		and	ax,dx		;in mask already set?
		jnz	TestInMask	;yes ->
		mov	ax,dx

;* make sure that only one bit is set

TestInMask:	mov	dx,00001h
BitTestLoop:	test	ax,dx		;found bit?
		jnz	MaskBit		;yes ->
		shl	dx,1		;next bit (cf = 1 = error, dx = 0)
		jnc	BitTestLoop	;no error ->
MaskBit:	mov	ax,dx

		mov	ACT_IN[bx],ax	;set "in" mask

;* if "select" type then make sure at least one bit is set in status

		or	ax,ACT_OUT[bx]
		cmp	ax,0ffffh	;"select" type?
		je	TestMaskFull	;no ->

		mov	ax,Status
		and	ax,ACT_OUT[bx]
		or	ax,ACT_IN[bx]
		mov	Status,ax

TestMaskFull:	test	bp,bp		;is mask full?
		jz	InitOptionDone	;yes ->

		add	si,END_REC_SIZE	;si -> next option data
		add	bx,ACT_REC_SIZE	;next option record
		loop	InitOptionLoop	;next option ->

InitOptionDone:	ret

ParseDialog	ENDP

;----------------------------------------------------------------------------

;* OpenDialog - open dialog box
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

OpenDialog	PROC	NEAR

;* save original screen

		call	HideMouse
		call	SaveScreen

;* draw dialog box

		mov	al,COL_LT_GREY
		mov	cx,BoxXOrigin
		mov	bl,BYTE PTR BoxYOrigin
		mov	dx,BoxXCorner
		mov	bh,BYTE PTR BoxYCorner
		call	BlockFill

;* draw title bar

		mov	al,COL_BLACK
		mov	cx,BoxXOrigin
		mov	bl,BYTE PTR BoxYOrigin
		inc	bl
		mov	dx,BoxXCorner
		mov	bh,bl
		add	bh,10
		call	BlockFill
		
;* draw outer border

		mov	al,COL_WHITE
		mov	cx,BoxXOrigin
		mov	bl,BYTE PTR BoxYOrigin
		mov	dx,BoxXCorner
		mov	bh,BYTE PTR BoxYCorner

		call	DrawRectangle

;* draw inner border

		mov	al,COL_BLACK
		mov	cx,BoxXOrigin
		mov	bl,BYTE PTR BoxYOrigin
		mov	dx,BoxXCorner
		mov	bh,BYTE PTR BoxYCorner

		inc	cx
		inc	bl
		dec	dx
		dec	bh
		
		call	DrawRectangle

;* draw "close box"

		mov	ax,BoxXOrigin
		mov	SpriteX,ax
		mov	ax,BoxYOrigin
		mov	SpriteY,ax
		mov	ax,OFFSET CloseSymbol
		mov	SpritePtr,ax

		mov	si,OFFSET Sprite
		call	QSprite

		call	PrintText	;print dialog text
		call	ShowButtons	;draw buttons
		call	ShowMouse	;switch mouse back on
		call	DownLoad	;display dialog

		ret

OpenDialog	ENDP

;----------------------------------------------------------------------------

;* CloseDialog - close dialog box
;*
;* pass: nothing
;* ret : ax = status (with close bit intact)
;* kill: assume all

CloseDialog	PROC	NEAR

		call	HideMouse
		call	LoadScreen
		call	ShowMouse
		call	DownLoad

;* reset close button (if any)

		mov	dx,Status

		mov	ax,ButtonMask
		not	ax
		and	ax,dx

;* set new dialog box button status

		mov	si,DialogPtr
		mov	BOX_STATUS[si],ax

;* return status with "close" bit intact (so we know why dialog was closed)

		mov	ax,dx

		ret

CloseDialog	ENDP

;----------------------------------------------------------------------------

;* DialogControl - handle user input
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

DialogControl	PROC	NEAR

		mov	ButtonMask,0	;clear button mask

;* sort mouse input

SortMouse:	call	ScanMouse	;any mouse button just pressed?
		jnc	SortKbd		;no ->

		call	ScanButtons	;inside any button?
		jc	ExecAction	;yes ->

		call	TestForClose	;inside close symbol?
		jc	ControlExit	;yes ->

;* sort keyboard input

SortKbd:	call	ScanKeyboard	;any valid key pressed?
		jnc	ControlExit	;no ->

;* execute button action routine

ExecAction:	mov	bx,OPT_ACTION[di]

		call	bx

		call	ShowButtons	;update buttons

ControlExit:	ret

DialogControl	ENDP

;----------------------------------------------------------------------------

;* PrintText - print dialog box text
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

PrintText	PROC	NEAR

		mov	si,TextPtr
		cmp	si,NULL
		je	PrintTextExit
		call	Print$
PrintTextExit:	ret

PrintText	ENDP

;----------------------------------------------------------------------------

;* ShowButtons - draw buttons
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

ShowButtons	PROC	NEAR

		mov	cx,NUM_BUTTONS
		mov	dx,Status
		mov	si,OFFSET TgtTable
	
ShowButtonLoop:	mov	ax,TGT_ACT[si]
		cmp	ax,NULL		;button valid?
		je	ExitButtons	;no ->

		mov	ax,TGT_X[si]
		mov	SpriteX,ax
		mov	ax,TGT_Y[si]
		mov	SpriteY,ax

		mov	bx,dx
		and	bx,00001h
		shl	bx,1		;*2 (word index)
		mov	ax,ButtonList[bx]
		mov	SpritePtr,ax
		
		push	cx
		push	dx
		push	si
		mov	si,OFFSET Sprite
		call	SSprite
		pop	si
		pop	dx
		pop	cx

		shr	dx,1		;next button status
		add	si,TGT_REC_SIZE	;si -> next button data
		loop	ShowButtonLoop	;next button ->
		
ExitButtons:	ret

ShowButtons	ENDP

;----------------------------------------------------------------------------

;* ScanButtons - scan buttons to see if pointer is "inside" one
;*
;* pass: nothing
;* ret : cf = 1 = inside button: si -> ACTION record
;*                               di -> OPTYPE record
;*                               ButtonMask
;* kill: ax, bx, cx, dx, flags

ScanButtons	PROC	NEAR

		mov	si,OFFSET TgtTable

		mov	bp,00001h	;button mask
		
ScanButLoop:	mov	ax,TGT_ACT[si]
		cmp	ax,NULL		;button valid?
		je	ScanButFail	;no ->

		mov	ax,TGT_X[si]
		sub	ax,BUT_WIDTH/2
		mov	cx,ax		;x top lh corner

		mov	ax,TGT_Y[si]
		sub	ax,BUT_DEPTH/2
		mov	bl,al		;y top lh corner

		mov	dx,BUT_WIDTH
		mov	bh,BUT_DEPTH

		call	TestInsideBox	;inside this button?
		jc	ScanButPass	;yes ->

		add	si,TGT_REC_SIZE	;next button data
		shl	bp,1		;next button mask (cf = 1 = all checked)
		jnc	ScanButLoop	;next button (if any left to check) ->

ScanButFail:	clc			;cf = 0
		ret

ScanButPass:	mov	ButtonMask,bp	;set button mask
		mov	si,TGT_ACT[si]	;ACTION pointer
		mov	di,ACT_PTR[si]	;OPTYPE Pointer
		stc			;cf = 1
		ret

ScanButtons	ENDP

;----------------------------------------------------------------------------

;* ScanKeyboard - scan keyboard and test for action required
;*
;* pass: nothing
;* ret : cf = 1 = action required: si -> ACTION record
;*                                 di -> OPTYPE record
;*                                 ButtonMask
;* kill: assume all (except si, di)

ScanKeyboard	PROC	NEAR

		call	ScanMenuKeys	;any activity?
		jnc	ScanKbdFail	;no ->

		cmp	al,K_ESC	;ESCape key (close dialog)?
		jne	TestDefault	;no ->

		call	CloseBox	;signal close

		jmp	ScanKbdFail	;no further action required ->

TestDefault:	cmp	al,K_SPACE	;SPACE BAR (default option)?
		jne	TestFunction	;no ->

		mov	si,DefaultPtr
		cmp	si,NULL		;default valid?
		je	ScanKbdFail	;no ->

		jmp	SortFunction	;sort out function ->

TestFunction:	cmp	al,K_F1		;in function key range?
		jb	ScanKbdFail	;no ->

		cmp	al,K_F10	;in function key range?
		ja	ScanKbdFail	;no ->

		sub	al,K_F1		;0 .. 9
		xor	ah,ah
		mov	dx,ACT_REC_SIZE
		mul	dx
		mov	si,ax		;si -> ACTION record wrt function key

SortFunction:	add	si,OFFSET OptTable
		
		mov	di,ACT_PTR[si]	;OPTYPE Pointer
		cmp	di,NULL		;valid option?
		jne	ScanKbdPass	;yes ->

ScanKbdFail:	clc			;cf = 0
		ret

;* sort out ButtonMask

ScanKbdPass:	mov	ax,ACT_IN[si] 	;"in" mask
		mov	dx,ACT_OUT[si]	;"out" mask

;* if "in" mask ORed with "out" mask = 0ffffh then only one selection

		mov	bp,ax
		or	bp,dx
		cmp	bp,0ffffh	;only one selection?
		je	SetButtonMask	;yes, button mask = "in" mask

;* must be > 1 select so rotate "in" mask

		not	dx

TryNextBit:	rol	ax,1		;next bit position 
		test	ax,dx		;bit position valid?
		jz	TryNextBit	;no, keep rotating until valid ->

SetButtonMask:	mov	ButtonMask,ax
		
		stc			;cf = 1
		ret

ScanKeyboard	ENDP

;----------------------------------------------------------------------------

;* TestForClose - test if pointer is "inside" close symbol
;*
;* pass: BoxXOrigin
;*       BoxYOrigin
;* ret : cf = 1 = inside close symbol
;* kill: ax, bx, cx, dx, flags

TestForClose	PROC	NEAR

		mov	cx,BoxXOrigin
		mov	bl,BYTE PTR BoxYOrigin
		
		mov	dx,CLOSE_WIDTH
		mov	bh,CLOSE_DEPTH

		call	TestInsideBox  	;inside close symbol?
		jnc	TestCloseExit	;no ->
   
		call	CloseBox	;signal close
	
		stc			;cf = 1
			
TestCloseExit:	ret

TestForClose	ENDP
	
;----------------------------------------------------------------------------

;* CloseBox - signal close box
;*
;* pass: nothing
;* ret : CloseFlag = 1
;* kill: nothing

CloseBox	PROC	NEAR

		mov	CloseFlag,1
		ret

CloseBox	ENDP

;============================================================================
;*
;* Option routines:-
;*
;* For ALL option routines assume the following:-
;*
;* pass: si -> ACTION record (masks)
;*       di -> OPTYPE record (parameters)  
;*       ButtonMask
;* ret : Status
;* kill: assume all
;*
;============================================================================

;* TOGGLE - toggle button
;*
;* param 1: n/a
;* param 2: n/a
;* param 3: n/a
;* param 4: n/a

TOGGLE		PROC	NEAR

		mov	ax,ButtonMask
		xor	Status,ax    	;toggle bit
		ret

TOGGLE		ENDP

;----------------------------------------------------------------------------

;* SELECT - select one of many
;*
;* param 1: n/a
;* param 2: n/a
;* param 3: n/a
;* param 4: n/a

SELECT		PROC	NEAR

		mov	ax,ACT_OUT[si]
		and 	Status,ax  	;clear select bits
		mov	ax,ButtonMask
		or	Status,ax	;set selected bit
		mov	ACT_IN[si],ax	;update "in" mask
		ret

SELECT		ENDP

;----------------------------------------------------------------------------

;* CLOSE - close dialog
;*
;* param 1: n/a
;* param 2: n/a
;* param 3: n/a
;* param 4: n/a

CLOSE		PROC	NEAR

		mov	ax,ButtonMask
		or	Status,ax	;set bit
		call	CloseBox
		ret

CLOSE		ENDP

;----------------------------------------------------------------------------

;* ENTER_STR - enter string
;*
;* param 1: pointer to start of string (positional data etc.)
;* param 2: pointer to string input field
;* param 3: n/a
;* param 4: n/a

ENTER_STR	PROC	NEAR

		mov	ax,OPT_PARAM1[di]
		mov	Param1,ax
		mov	ax,OPT_PARAM2[di]
		mov	Param2,ax
			
		mov	ax,ButtonMask
		or	Status,ax	;set bit

		call	ShowButtons	;show lit button

ReDoString:	mov	si,Param1
		mov	di,Param2

		call	Input$
		test	cx,cx		;any chars entered?
		jz	ReDoString	;no ->

		mov	ax,ButtonMask
		not	ax
		and	Status,ax	;reset bit

		ret

ENTER_STR	ENDP

;----------------------------------------------------------------------------

;* ENTER_NUM - enter unsigned number
;*
;* param 1: pointer to start of string (positional data etc.)
;* param 2: pointer to string input field
;* param 3: lower limit
;* param 4: upper limit

ENTER_NUM	PROC	NEAR

		mov	InputMode,INPUT_NUM

		mov	ax,OPT_PARAM1[di]
		mov	Param1,ax
		mov	ax,OPT_PARAM2[di]
		mov	Param2,ax
		mov	ax,OPT_PARAM3[di]
		mov	Param3,ax
		mov	ax,OPT_PARAM4[di]
		mov	Param4,ax
				
		mov	ax,ButtonMask
		or	Status,ax	;set bit

		call	ShowButtons	;show lit button

ReDoNumber:	mov	si,Param1
		mov	di,Param2

		call	Input$
		test	cx,cx		;any chars entered?
		jz	ReDoNumber	;no ->

		mov	si,Param2
		call	ConvNum$

		test	dx,dx		;too big?
		jnz	ReDoNumber	;yes ->

		cmp	ax,Param3	;< lower limit?
		jb	ReDoNumber	;yes ->
		cmp	ax,Param4	;> upper limit?
		ja	ReDoNumber	;yes ->

		mov	ax,ButtonMask
		not	ax
		and	Status,ax	;reset bit

		ret

ENTER_NUM	ENDP

LIBCODE		ENDS

;============================================================================

		END

