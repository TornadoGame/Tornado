;****************************************************************************
;*
;* LOOKDOWN.ASM
;*
;* Look down panel driver.
;*
;* 18.01.1992 - KJB
;* 21.03.1992 - KJB - Kneepad text reorganized.
;*                    Sound option added.
;* 10.04.1992 - KJB - UserOptions seperated into UserOptions and UserVisOptions.
;* 01.08.1992 - KJB - StarsEnabled linked to "sky: plain / textured" option.
;*		      Minimise / restore option added.
;* 06.08.1993 - KJB - Sound options modified.
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	UpdateLookDown
		PUBLIC	UserOptions
		PUBLIC	UserVisOptions

		EXTRN	BlockFill:FAR
		EXTRN	VLineDraw:FAR
		EXTRN	HLineDraw:FAR
		EXTRN	Print$:FAR
		EXTRN	InitCtrlDevice:FAR
		EXTRN	SuspendSound:FAR
		EXTRN	ResumeSound:FAR

		EXTRN	SecScanCnt1:WORD
		EXTRN	SecScanOff1:WORD
		EXTRN	SecScanCnt2:WORD
		EXTRN	SecScanOff2:WORD
		EXTRN	ControlDevice:WORD

		EXTRN	GndTextEnabled:BYTE
		EXTRN	TreesEnabled:BYTE
		EXTRN	HillTextEnabled:BYTE
		EXTRN	CloudsEnabled:BYTE
		EXTRN	StarsEnabled:BYTE
		EXTRN	GradEnabled:BYTE
		EXTRN	IronWork:BYTE
		EXTRN	SoundOption:BYTE
		EXTRN	KF_Range:BYTE
		EXTRN	KF_GndText:BYTE
		EXTRN	KF_HillText:BYTE
		EXTRN	KF_Clouds:BYTE
		EXTRN	KF_Horizon:BYTE
		EXTRN	KF_IronWork:BYTE
		EXTRN	KF_Control:BYTE
		EXTRN	KF_Sound:BYTE
		EXTRN	KF_Minimise:BYTE
		EXTRN	JoyA_Flag:BYTE
		EXTRN	JoyB_Flag:BYTE
		
;============================================================================

		INCLUDE	MAINDATA.INC

		INCLUDE	\VISUAL\PALETTES.INC

		INCLUDE	\LIB8086\KEYS.INC
		INCLUDE	\LIB8086\PRINT.INC
		INCLUDE	\LIB8086\USEFUL.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

;-------------------
;* restore variables
;-------------------

Minimise	DB	0,0		;0 = minimise next, 1 = restore next

_SecScanCnt1	DW	0
_SecScanOff1	DW	0
_SecScanCnt2	DW	0
_SecScanOff2	DW	0

_GndTextEnabled	DB	0
_TreesEnabled	DB	0
_HillTxtEnabled	DB	0
_CloudsEnabled	DB	0
_StarsEnabled	DB	0
_GradEnabled	DB	0

		EVEN

;----------------
;* item ring data
;----------------

RING		STRUCT

RING_X		DW	0		;x co-ord
RING_Y		DB	0		;y co-ord
RING_W		DB	0		;width

RING		ENDS

Item1Rings	LABEL	WORD		;visibility
		RING	<14,57,6>	; 6 miles
		RING	<22,57,6>	; 9 miles
		RING	<30,57,10>	;12 miles
		RING	<42,57,10>	;16 miles
		RING	<54,57,10>	;19 miles
		RING	<66,57,10>	;22 miles
		RING	<78,57,10>	;25 miles

Item2Rings	LABEL	WORD		;ground
		RING	<30,76,22>	;plain
		RING	<54,76,34>	;textured

Item3Rings	LABEL	WORD		;hills
		RING	<30,95,22>	;plain
		RING	<54,95,34>	;textured

Item4Rings	LABEL	WORD		;sky
		RING	<30,114,22>	;plain
		RING	<54,114,34>	;textured
		
Item5Rings	LABEL	WORD		;horizon
		RING	<42,133,22>	;plain
		RING	<66,133,22>	;faded

Item6Rings	LABEL	WORD		;ironwork
		RING	<262,57,26>	;hidden
		RING	<290,57,22>	;shown

Item7Rings	LABEL	WORD		;controls
		RING	<246,76,42>	;keyboard 1
		RING	<246,84,42>	;keyboard 2
		RING	<246,92,42>	;joystick 1
		RING	<246,100,42>	;joystick 2

Item8Rings	LABEL	WORD		;sound
		RING	<242,119,14>	;off
		RING	<258,119,26>	;on-eng
		RING	<286,119,26>	;on+eng

		EVEN

;--------------
;* text strings
;--------------

TextCol1	DB	000h,000h,0aah,000h,00ch,000h,COL_KNEE_INK1,000h	;normal
TextCol2	DB	000h,000h,0aah,000h,00ch,000h,COL_KNEE_INK2,000h	;greyed out (not available)

Joy1Col		DW	OFFSET TextCol1
Joy2Col		DW	OFFSET TextCol1

Num$	 	LABEL	BYTE
		P_OVER1
		P_CHAR2
		PD_ATTR	000h,000h,0aah,000h,00ch,000h,COL_KNEE_NUM,000h
		PD_XY	8,51
		DB	'1'
		PD_XY	8,70
		DB	'2'
		PD_XY	8,89
		DB	'3'
		PD_XY	8,108
		DB	'4'
		PD_XY	8,127
		DB	'5'
		PD_XY	232,51
		DB	'6'
		PD_XY	232,70
		DB	'7'
		PD_XY	232,113
		DB	'8'
		PD_XY	232,132
		DB	'0'
		P_END

Text$	 	LABEL	BYTE
		P_OVER1
		P_CHAR2
		PV_ATTR	TextCol1
		PD_XY	16,51
		DB	"VISIBILITY(MILES):"
		PD_XY	16,59
		DB	"6 9 12 16 19 22 25"
		PD_XY	16,70
		DB	"GROUND:"
		PD_XY	32,78
		DB	"PLAIN TEXTURED"
		PD_XY	16,89
		DB	"HILLS:"
		PD_XY	32,97
		DB	"PLAIN TEXTURED"
		PD_XY	16,108
		DB	"SKY:"
		PD_XY	32,116
		DB	"PLAIN TEXTURED"
		PD_XY	16,127
		DB	"HORIZON:"
		PD_XY	44,135
		DB	"PLAIN FADED"
		PD_XY	240,51
		DB	"IRONWORK:"
		PD_XY	264,59
		DB	"HIDDEN SHOWN"
		PD_XY	240,70
		DB	"CONTROL DEVICE:"
		PD_XY	248,78
		DB	"KEYBOARD 1"
		PD_XY	248,86
		DB	"KEYBOARD 2"
		PD_XY	248,94
		PP_ATTR	Joy1Col
		DB	"JOYSTICK 1"
		PD_XY	248,102
		PP_ATTR	Joy2Col
		DB	"JOYSTICK 2"
		PV_ATTR	TextCol1
		PD_XY	240,113
		DB	"SOUND EFFECTS:"
		PD_XY	244,121
		DB	"OFF ON-ENG ON+ENG"
		PD_XY	240,132
		DB	"MINIMISE / RESTORE"
		P_END

		EVEN

DATA		ENDS

;============================================================================

PANCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:PANCODE
		ASSUME DS:DATA

;* BRACKET - draw bracket around number
;*
;* pass: x = x co-ord of number
;*       y = y co-ord of number
;* ret : nothing
;* kill: assume all

BRACKET		MACRO	x,y

		mov	al,COL_KNEE_NUM
		mov	cx,x+4
		mov	bl,y
		mov	bh,y+5
		call	VLineDraw

		mov	al,COL_KNEE_NUM
		mov	cx,x-1
		mov	bl,y+6
		mov	dx,x+3
		call	HLineDraw

		ENDM

;----------------------------------------------------------------------------

;* HLINE - draw horizontal line
;*
;* pass: x1, x2, y1
;* ret : nothing
;* kill: assume all

HLINE		MACRO	x1,x2,y1
		
		mov	cx,x1
		mov	dx,x2
		mov	bl,y1
		mov	al,COL_KNEE_INK1
		call	HLineDraw

		ENDM

;----------------------------------------------------------------------------

;* UpdateLookDown - update look down panel
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

UpdateLookDown	PROC	NEAR

;--------------
;* clear lh pad
;--------------

		mov	al,COL_KNEE_PAD
		mov	cx,8
		mov	bl,49
		mov	dx,87
		mov	bh,141
		call	BlockFill

		mov	al,COL_KNEE_PAD
		mov	cx,7
		mov	bl,49
		mov	bh,141
		call	VLineDraw

		mov	al,COL_KNEE_PAD
		mov	cx,88
		mov	bl,49
		mov	bh,141
		call	VLineDraw

;--------------
;* clear rh pad
;--------------

		mov	al,COL_KNEE_PAD
		mov	cx,232
		mov	bl,49
		mov	dx,311
		mov	bh,141
		call	BlockFill

		mov	al,COL_KNEE_PAD
		mov	cx,231
		mov	bl,49
		mov	bh,141
		call	VLineDraw

		mov	al,COL_KNEE_PAD
		mov	cx,312
		mov	bl,49
		mov	bh,141
		call	VLineDraw

;---------------
;* print numbers
;---------------

		mov	si,OFFSET Num$
		call	Print$

		BRACKET	8,51
		BRACKET	8,70
		BRACKET	8,89
		BRACKET	8,108
		BRACKET	8,127
		BRACKET	232,51
		BRACKET	232,70
		BRACKET	232,113
		BRACKET	232,132

;--------------------
;* print kneepad text
;--------------------

;* sort joystick text colour

		mov	si,OFFSET TextCol2	;assume joystick 1 unavailable
		mov	di,OFFSET TextCol2	;assume joystick 2 unavailable

		test	JoyA_Flag,1	;joystick 1 available?
		jz	@F		;no ->

		mov	si,OFFSET TextCol1

		test	JoyB_Flag,1	;joystick 2 available?
		jz	@F		;no ->

		mov	di,OFFSET TextCol1

@@:		mov	Joy1Col,si
		mov	Joy2Col,di

		mov	si,OFFSET Text$
		call	Print$

;-----------------------
;* draw seperating lines
;-----------------------

;* lhs

		HLINE	6,91,67
		HLINE	6,91,86
		HLINE	6,91,105
		HLINE	6,91,124

;* rhs

		HLINE	228,313,67
		HLINE	228,313,110
		HLINE	228,313,129

;----------------------------------
;* draw rings around selected items
;----------------------------------

;* visibility

		mov	ax,SecScanCnt1		;3 .. 15
		sub	ax,3			;0 .. 12
		shl	ax,1			;0 .. 24
		mov	si,OFFSET Item1Rings
		add	si,ax
		call	DrawRing

;* ground

		mov	al,GndTextEnabled	;0 .. 1
		xor	ah,ah
		shl	ax,1			;0 .. 2
		shl	ax,1			;0 .. 4
		mov	si,OFFSET Item2Rings
		add	si,ax
		call	DrawRing

;* hills

		mov	al,HillTextEnabled	;0 .. 1
		xor	ah,ah
		shl	ax,1			;0 .. 2
		shl	ax,1			;0 .. 4
		mov	si,OFFSET Item3Rings
		add	si,ax
		call	DrawRing

;* sky

		mov	al,CloudsEnabled	;0 .. 1
		xor	ah,ah
		shl	ax,1			;0 .. 2
		shl	ax,1			;0 .. 4
		mov	si,OFFSET Item4Rings
		add	si,ax
		call	DrawRing

;* horizon

		mov	al,GradEnabled		;0 .. 1
		xor	ah,ah
		shl	ax,1			;0 .. 2
		shl	ax,1			;0 .. 4
		mov	si,OFFSET Item5Rings
		add	si,ax
		call	DrawRing

;* ironwork

		mov	al,IronWork		;0 .. 1
		xor	ah,ah
		shl	ax,1			;0 .. 2
		shl	ax,1			;0 .. 4
		mov	si,OFFSET Item6Rings
		add	si,ax
		call	DrawRing

;* control device

		mov	ax,ControlDevice	;0 .. 10
		shl	ax,1			;0 .. 20
		mov	si,OFFSET Item7Rings
		add	si,ax
		call	DrawRing

;* sound effects

		mov	al,SoundOption		;0 .. 2
		xor	ah,ah
		shl	ax,1			;0 .. 4
		shl	ax,1			;0 .. 8
		mov	si,OFFSET Item8Rings
		add	si,ax
		call	DrawRing

		ret

UpdateLookDown	ENDP

;----------------------------------------------------------------------------

;* DrawRing - draw ring around text
;*
;* pass: si -> ring data block
;* ret : nothing
;* kill: assume all

DrawRing	PROC	NEAR

		mov	cx,RING_X[si]
		mov	dx,cx
		add	dl,RING_W[si]
		adc	dh,0
		inc	cx
		dec	dx
		mov	bl,RING_Y[si]

		mov	al,COL_KNEE_PEN
		push	si
		call	HLineDraw
		pop	si

		mov	cx,RING_X[si]
		mov	dx,cx
		add	dl,RING_W[si]
		adc	dh,0
		inc	cx
		dec	dx
		mov	bl,RING_Y[si]
		add	bl,8

		mov	al,COL_KNEE_PEN
		
		push	si
		call	HLineDraw
		pop	si

		mov	cx,RING_X[si]
		mov	bl,RING_Y[si]
		inc	bl
		mov	bh,bl
		add	bh,6

		mov	al,COL_KNEE_PEN
		push	si
		call	VLineDraw
		pop	si

		mov	cx,RING_X[si]
		add	cl,RING_W[si]
		adc	ch,0
		mov	bl,RING_Y[si]
		inc	bl
		mov	bh,bl
		add	bh,6

		mov	al,COL_KNEE_PEN
		call	VLineDraw

		ret

DrawRing	ENDP

;----------------------------------------------------------------------------

;* UserOptions - update user selectable options
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

UserOptions	PROC	FAR

;--------
;* visual 
;--------

		call	UserVisOptions

;----------
;* ironwork
;----------

		KFETCH	KF_IronWork
		xor	IronWork,al

;----------
;* controls
;----------

		KTEST	KF_Control	;change control device?
		jz	SkipControl	;no ->

		mov	ax,ControlDevice
		add	ax,2
		cmp	ax,CTRL_DEV_JOY2	;wrap around?
		jbe	@F			;no ->
		xor	ax,ax
@@:		mov	ControlDevice,ax

		call	InitCtrlDevice

;---------------
;* sound effects
;---------------

SkipControl:	KTEST	KF_Sound	;change sound?
		jz	SkipSound	;no ->

		mov	al,SoundOption
		inc	al
		cmp	al,3		;wrap around?
		jb	@F		;no ->
		xor	al,al
@@:		mov	SoundOption,al

		cmp	al,SOUND_OPT_OFF	;switch off?
		jne	@F			;no ->

		call	SuspendSound

		jmp	SkipSound

@@:		call	ResumeSound

SkipSound:	ret

UserOptions	ENDP

;----------------------------------------------------------------------------

;* UserVisOptions - update user selectable visual options
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

UserVisOptions	PROC	FAR

;------------
;* visibility
;------------

		KTEST	KF_Range	;adjust visibility?
		jz	SkipRange	;no ->

		mov	ax,SecScanCnt1
		add	ax,2
		cmp	ax,15		;wrap around?
		jbe	@F		;no ->
		mov	ax,3

@@:		mov	SecScanCnt1,ax
		mov	SecScanCnt2,ax

		shr	ax,1		;count / 2
		neg	ax		;offset = -(count / 2)

   		mov	SecScanOff1,ax
		mov	SecScanOff2,ax

;--------
;* ground
;--------

SkipRange:	KFETCH	KF_GndText
		xor	GndTextEnabled,al
		xor	TreesEnabled,al

;-------
;* hills
;-------

		KFETCH	KF_HillText
		xor	HillTextEnabled,al

;-----
;* sky
;-----

	 	KFETCH	KF_Clouds
		xor	CloudsEnabled,al
		xor	StarsEnabled,al

;---------
;* horizon
;---------

		KFETCH	KF_Horizon
		xor	GradEnabled,al

;--------------------
;* minimise / restore
;--------------------

		KTEST	KF_Minimise	;minimise / restore?
		_JZ	MinimiseOk	;no ->

		xor	Minimise,1	;minimise or restore?
		jz	@F		;restore ->

;* minimise

		mov	ax,SecScanCnt1
		mov	_SecScanCnt1,ax
		mov	ax,SecScanOff1
		mov	_SecScanOff1,ax
		mov	ax,SecScanCnt2
		mov	_SecScanCnt2,ax
		mov	ax,SecScanOff2
		mov	_SecScanOff2,ax

		mov	al,GndTextEnabled
		mov	_GndTextEnabled,al
		mov	al,TreesEnabled
		mov	_TreesEnabled,al
		mov	al,HillTextEnabled
		mov	_HillTxtEnabled,al
		mov	al,CloudsEnabled
		mov	_CloudsEnabled,al
		mov	al,StarsEnabled
		mov	_StarsEnabled,al
		mov	al,GradEnabled
		mov	_GradEnabled,al

		mov	SecScanCnt1,3
		mov	SecScanOff1,-1
		mov	SecScanCnt2,3
		mov	SecScanOff2,-1

		xor	al,al

		mov	GndTextEnabled,al
		mov	TreesEnabled,al
		mov	HillTextEnabled,al
		mov	CloudsEnabled,al
		mov	StarsEnabled,al
		mov	GradEnabled,al

		jmp	MinimiseOk

;* restore

@@:		mov	ax,_SecScanCnt1
		mov	SecScanCnt1,ax
		mov	ax,_SecScanOff1
		mov	SecScanOff1,ax
		mov	ax,_SecScanCnt2
		mov	SecScanCnt2,ax
		mov	ax,_SecScanOff2
		mov	SecScanOff2,ax

		mov	al,_GndTextEnabled
		mov	GndTextEnabled,al
		mov	al,_TreesEnabled
		mov	TreesEnabled,al
		mov	al,_HillTxtEnabled
		mov	HillTextEnabled,al
		mov	al,_CloudsEnabled
		mov	CloudsEnabled,al
		mov	al,_StarsEnabled
		mov	StarsEnabled,al
		mov	al,_GradEnabled
		mov	GradEnabled,al

MinimiseOk:	ret

UserVisOptions	ENDP

PANCODE		ENDS

;============================================================================

		END

