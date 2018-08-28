;****************************************************************************
;*
;* NAVIGPAN.ASM
;*
;* Navigator's panel driver.
;*
;* 16.10.1991 - KJB
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<
PUBLIC UpdateStores2	
		PUBLIC  DrawADIRollBug
		PUBLIC	UpdateNavig	
		PUBLIC UpdateADI2
EXTRN	RadarMode:WORD		
EXTRN	Key:BYTE		
EXTRN MFD_Counter:WORD		
EXTRN   ShiftDwasPressed:BYTE
EXTRN QuieterCockpit:BYTE
EXTRN CounterThird:WORD		
EXTRN TIALDDisp:FAR
EXTRN ToggleZRK_ZSU:BYTE
EXTRN ToggleFullScreen:BYTE
EXTRN	UpdateHUD2:NEAR			
EXTRN VGA_DrwNavigPan:NEAR		
EXTRN VGA_DrwNavigPanBrief:NEAR
EXTRN LoadNavigPan:NEAR
		EXTRN	ClearNavigPanel:FAR
		EXTRN	DrawNavigPanel:FAR
		EXTRN	SetViewMode:FAR
		EXTRN	UserHorizon:FAR
		EXTRN	BlockFill:FAR
		EXTRN	SetPixel:FAR
		EXTRN	Print$:FAR
		EXTRN	LineDraw:FAR
		EXTRN	PrintChar:FAR
		EXTRN	PrintDecWord:FAR
		EXTRN	HLineDraw:FAR
EXTRN	RandX:FAR
		EXTRN	UpdateNavigMFD:NEAR
		EXTRN	UpdateTAB1:NEAR
		EXTRN	UpdateTAB2:NEAR
EXTRN TrueRadAlt:WORD
		EXTRN	M_VIEW:WORD
		EXTRN	Hdg:WORD
		EXTRN	Roll:WORD
		EXTRN	M_SinR:WORD
		EXTRN	M_CosR:WORD
		EXTRN	M_CosP:WORD
		EXTRN	ZftHi:WORD
		EXTRN	ZftLo:WORD
		EXTRN	ILSLocalPos:WORD
		EXTRN	ILSGlidePos:WORD
		EXTRN	Vkts:WORD
		EXTRN	DispMachNum:WORD
		EXTRN	PrtLn:WORD
		EXTRN	PrtCl:WORD
		EXTRN	ChaffCntr:WORD
		EXTRN	FlareCntr:WORD
		EXTRN	PrtLn:WORD
		EXTRN	PrtCl:WORD
		EXTRN	PackagePtr:WORD
		EXTRN	ArmMode:WORD
		EXTRN	AirArmMode:WORD
		EXTRN	LastFrame:WORD
		EXTRN	TornadoType:WORD
		EXTRN	Cannons:WORD
		EXTRN	ExtStores:WORD
EXTRN KF_Full_MFD:BYTE
		EXTRN	DialXY1:BYTE
		EXTRN	DialXY2:BYTE
		EXTRN	DialXY3:BYTE
		EXTRN	ILSActive:BYTE
		EXTRN	Clock24:BYTE
		EXTRN	Night:BYTE
		EXTRN	DecAttr:BYTE
		EXTRN	CannonFired:BYTE
;============================================================================
EXTRN	ShakeUp:BYTE
EXTRN	ShakePriority:BYTE
EXTRN	HShake:BYTE	
EXTRN	VShake:BYTE
EXTRN	ShakeTimer:WORD
EXTRN	HSHAKE_HI:ABS
EXTRN	VSHAKE_HI:ABS
EXTRN	HSHAKE_LO:ABS
EXTRN	HSHAKE_VERY_LO:ABS
EXTRN	VSHAKE_VERY_LO:ABS
EXTRN	VSHAKE_LO:ABS
EXTRN	VSHAKE_OFF:ABS
EXTRN	HSHAKE_OFF:ABS

;============================================================================
INCLUDE	MISCMAC.INC

;============================================================================

		INCLUDE	MAINDATA.INC
		INCLUDE	MFD.INC
		INCLUDE	TAB.INC
INCLUDE	\LIB8086\VGA_DRVR.INC
		INCLUDE	\VISUAL\VISDATA.INC
		INCLUDE	\VISUAL\PALETTES.INC

		INCLUDE	\LIB8086\KEYS.INC
		INCLUDE	\LIB8086\PRINT.INC
		INCLUDE	\LIB8086\USEFUL.INC

		EXTRN	NAVIG_MFD:MFD

		EXTRN	TAB1:TAB
		EXTRN	TAB2:TAB

		EXTRN	KF_DispSelect:GAMEKEY

		EXTRN	Packages:PACKAGE

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

NAVIGPAN_SIZE	EQU	320*200
NAVIGPAN_OFF	EQU	320*0/4 
NAVIGPAN_SEG	EQU	VGA_PAGE_3

TempVal		DW	0
MIN_OP_RAD_ALT	EQU	100
;----------------
;* stores display
;----------------

SDISP_X_ORG	EQU	128
SDISP_Y_ORG	EQU	148
SDISP_WIDTH	EQU	64
SDISP_DEPTH	EQU	47

ARM_BLINK_TIME	EQU	50		;arm blink time (secs*100)

ArmBlinkTimer	DW	ARM_BLINK_TIME	;arm blink timer (secs*100)

ArmBlink	DB	0		;blink state

		EVEN

;* stores screen layout switch (wrt variant)

LayoutSwitch	DW	IDSLayout	;IDS_TORNADO
		DW	ADVLayout 	;ADV_TORNADO
		DW	ECRLayout	;ECR_TORNADO

LayoutSwitch2	DW	IDSLayout2	;IDS_TORNADO
		DW	ADVLayout2 	;ADV_TORNADO
		DW	ECRLayout2	;ECR_TORNADO

LayoutSwitch3	DW	IDSLayout3	;IDS_TORNADO
		DW	ADVLayout3 	;ADV_TORNADO
		DW	ECRLayout3	;ECR_TORNADO		
;------------------------------------
;* HSI localiser and glide slope vars
;------------------------------------

LOCAL_X		EQU	87		;localiser needle origin
LOCAL_Y		EQU	184

LocalXPos	DW	LOCAL_X		;localiser x pos

GLIDE_X		EQU	70		;glide slope needle origin
GLIDE_Y		EQU	186

GlideYPos	DB	GLIDE_Y		;glide slope y pos

		EVEN

;-----------------
;* clock dial data
;-----------------

ClockDial1	LABEL	BYTE		;minute and second hands

		DB	  0, -10	;0
		DB	  1, -10	;1
		DB	  2, -10	;2
		DB	  3, -10	;3
		DB	  4, -10	;4
		DB	  5,  -9	;5
		DB	  6,  -9	;6
		DB	  7,  -8	;7
		DB	  8,  -8	;8
		DB	  9,  -7	;9
		DB	 10,  -6	;10
		DB	 11,  -5	;11
		DB	 12,  -4	;12
		DB	 12,  -3	;13
		DB	 13,  -2	;14
		DB	 13,  -1	;15
		DB	 13,   0	;16
		DB	 13,   1	;17
		DB	 13,   2	;18
		DB	 12,   3	;19
		DB	 12,   4	;20
		DB	 11,   5	;21
		DB	 10,   6	;22
		DB	  9,   7	;23
		DB	  8,   8	;24
		DB	  7,   8	;25
		DB	  6,   9	;26
		DB	  5,   9	;27
		DB	  4,  10	;28
		DB	  3,  10	;29
		DB	  2,  10	;30
		DB	  1,  10	;31
		DB	  0,  10	;32
		DB	 -1,  10	;33
		DB	 -2,  10	;34
		DB	 -3,  10	;35
		DB	 -4,  10	;36
		DB	 -5,   9	;37
		DB	 -6,   9	;38
		DB	 -7,   8	;39
		DB	 -8,   8	;40
		DB	 -9,   7	;41
		DB	-10,   6	;42
		DB	-11,   5	;43
		DB	-12,   4	;44
		DB	-12,   3	;45
		DB	-13,   2	;46
		DB	-13,   1	;47
		DB	-13,   0	;48
		DB	-13,  -1	;49
		DB	-13,  -2	;50
		DB	-12,  -3	;51
		DB	-12,  -4	;52
		DB	-11,  -5	;53
		DB	-10,  -6	;54
		DB	 -9,  -7	;55
		DB	 -8,  -8	;56
		DB	 -7,  -8	;57
		DB	 -6,  -9	;58
		DB	 -5,  -9	;59
		DB	 -4, -10	;60
		DB	 -3, -10	;61
		DB	 -2, -10	;62
		DB	 -1, -10	;63
		DB	  0, -10	;64 <<<<< first co-ord repeated <<<<<

ClockDial2	LABEL	BYTE		;hour hand

		DB	  0,  -8	;0
		DB	  1,  -8	;1
		DB	  2,  -8	;2
		DB	  3,  -8	;3
		DB	  4,  -7	;4
		DB	  5,  -7	;5
		DB	  6,  -6	;6
		DB	  7,  -6	;7
		DB	  8,  -5	;8
		DB	  9,  -4	;9
		DB	  9,  -3	;10
		DB	 10,  -2	;11
		DB	 10,  -1	;12
		DB	 10,   0	;13
		DB	 10,   1	;14
		DB	 10,   2	;15
		DB	  9,   3	;16
		DB	  9,   4	;17
		DB	  8,   5	;18
		DB	  7,   6	;19
		DB	  6,   6	;20
		DB	  5,   7	;21
		DB	  4,   7	;22
		DB	  3,   8	;23
		DB	  2,   8	;24
		DB	  1,   8	;25
		DB	  0,   8	;26
		DB	 -1,   8	;27
		DB	 -2,   8	;28
		DB	 -3,   8	;29
		DB	 -4,   7	;30
		DB	 -5,   7	;31
		DB	 -6,   6	;32
		DB	 -7,   6	;33
		DB	 -8,   5	;34
		DB	 -9,   4	;35
		DB	 -9,   3	;36
		DB	-10,   2	;37
		DB	-10,   1	;38
		DB	-10,   0	;39
		DB	-10,  -1	;40
		DB	-10,  -2	;41
		DB	 -9,  -3	;42
		DB	 -9,  -4	;43
		DB	 -8,  -5	;44
		DB	 -7,  -6	;45
		DB	 -6,  -6	;46
		DB	 -5,  -7	;47
		DB	 -4,  -7	;48
		DB	 -3,  -8	;49
		DB	 -2,  -8	;50
		DB	 -1,  -8	;51
		DB	  0,  -8	;52 <<<<< first co-ord repeated <<<<<

ClockDial3	LABEL	BYTE		;second hand tail

		DB	  0,   2	;0
		DB	 -1,   2	;1
		DB	 -2,   2	;2
		DB	 -2,   1	;3
		DB	 -2,   0	;4
		DB	 -2,  -1	;5
		DB	 -2,  -2	;6
		DB	 -1,  -2	;7
		DB	  0,  -2	;8
		DB	  1,  -2	;9
		DB	  2,  -2	;10
		DB	  2,  -1	;11
		DB	  2,   0	;12
		DB	  2,   1	;13
		DB	  2,   2	;14
		DB	  1,   2	;15
		DB	  0,   2	;16 <<<<< first co-ord repeated <<<<<

;------------------------
;* instrument string data
;------------------------

SetUp$		LABEL	BYTE
		P_OVER1
		P_CHAR2
		PD_VGA	COL_COUNTER,000h
		P_END

;* print barometric altitude

BarAlt$		LABEL	BYTE
		P_DECAT	00100011b	;(unsigned, 3 digits, leading zeroes)
		PD_XY	132,26
		PV_DECW	TempVal
		P_DECAT	00000000b	;(default)
		P_END

		EVEN

;-------------------------------
;* stores management string data
;-------------------------------	

WpnSetUp1$ 	LABEL	BYTE		;normal
		P_OVER1
		P_CHAR2
		PD_VGA	COL_CRT9,000h
		P_END

WpnSetUp2$ 	LABEL	BYTE		;hi-lite
		P_OVER1
		P_CHAR2
		PD_VGA	COL_CRT16,000h
		P_END

WpnSetUp1_fullscr$ 	LABEL	BYTE		;normal
		P_OVER1
		P_CHAR2
		PD_VGA	COL_CRT10,COL_CRT1
		P_END

WpnSetUp2_fullscr$ 	LABEL	BYTE		;hi-lite
		P_OVER1
		P_CHAR2
		PD_VGA	COL_HUD,000h
		P_END		
		
Weapon$		LABEL	BYTE
		DB	"GPB1000",0
		DB	"RET1000",0
		DB	"LGB1000",0
		DB	"  BL755",0
		DB	"  JP233",0
		DB	"  ALARM",0

ManBomb$	DB	"MAN",0
LayBomb$	DB	"LAY",0
LftBomb$	DB	"LFT",0
LGBBomb$	DB	"LGB",0
DirAlarm$	DB	"DIR",0
IndAlarm$	DB	"IND",0

Cannon$		LABEL	BYTE
		P_DECAT	00010011b	;(unsigned, 3 digits, left justified)
		DB	"CANNONx"
		PV_DECW	Cannons
		P_DECAT	00000000b	;(default)
		P_END

Sidewinder$	LABEL	BYTE
		P_DECAT	00010010b	;(unsigned, 2 digits, left justified)
		DB	"AIM9Lx"
		PV_DECW	ExtStores[EXT_SIDEWINDER]
		P_DECAT	00000000b	;(default)
		P_END

SkyFlash$	LABEL	BYTE
		P_DECAT	00010010b	;(unsigned, 2 digits, left justified)
		DB	"SKYFLASHx"
		PV_DECW	ExtStores[EXT_SKYFLASH]
		P_DECAT	00000000b	;(default)
		P_END

Chaff$		LABEL	BYTE
		P_OVER1
		P_CHAR2
		PD_VGA	COL_CRT9,000h
		;PD_VGA	COL_HUD,000h
		P_DECAT	00010011b	;(unsigned, 3 digits, left justified)
		DB	"CHAFFx"
		PV_DECW	ChaffCntr
		P_DECAT	00000000b	;(default)
		P_END

Flare$		LABEL	BYTE
		P_OVER1
		P_CHAR2
		PD_VGA	COL_CRT9,000h
		;PD_VGA	COL_HUD,000h
		P_DECAT	00010010b	;(unsigned, 2 digits, left justified)
		DB	"FLAREx"
		PV_DECW	FlareCntr
		P_DECAT	00000000b	;(default)
		P_END

		EVEN

DATA		ENDS

;============================================================================

PANCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:PANCODE
		ASSUME DS:DATA

;* UpdateNavig - update navigator's panel
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

UpdateNavig	PROC	NEAR
        mov	NAVIG_MFD.MFD_X_ORG,128  ;Awesome! Frankie hack on 27/11/17
		mov	NAVIG_MFD.MFD_Y_ORG,57
		mov	TAB1.TAB_X_ORG,16  ;Awesome! Frankie hack on 27/11/17
		mov	TAB1.TAB_Y_ORG,26  ;Awesome! Frankie hack on 27/11/17
        mov	TAB2.TAB_X_ORG,208  ;Awesome! Frankie hack on 27/11/17
		mov	TAB2.TAB_Y_ORG,26  ;Awesome! Frankie hack on 27/11/17		
		;Awesome! Frankie hack on 27/11/17
        call	InitPanel			
call    LoadNavigPan		
		call	UpdateADI
		call	UpdateHSI
		call	UpdateAltimeter
		call	UpdateSpeed
		call	UpdateClock
		call	SelectActDisp						
        call	DrawNavigPanel			
        call	DrawADIRollBug			
		call	UpdateTAB1
		call	UpdateTAB2 
        call    VGA_DrwNavigPan;	
call UpdateNavigMFD		
cmp	TAB1.TAB_MODE,TAB_FLIR_ORI
je SkipDrawADIRollBug	
cmp	TAB1.TAB_MODE,TAB_TIALD_ORI
je CheckIfRadAltOk
jmp SkipCheckIfRadAltOk
CheckIfRadAltOk:		
        cmp	TrueRadAlt,MIN_OP_RAD_ALT	;rad alt ok?
        jge SkipDrawADIRollBug
SkipCheckIfRadAltOk:
cmp	TAB2.TAB_MODE,TAB_FLIR_ORI
je @F
cmp	TAB2.TAB_MODE,TAB_TIALD_ORI
je @F
call DrawADIRollBug		
@@:
SkipDrawADIRollBug:
cmp	TAB2.TAB_MODE,TAB_FLIR_ORI
je @F
        ;call	UpdateNavigMFD							
@@:		
cmp	TAB2.TAB_MODE,TAB_TIALD_ORI
je @F
        ;call	UpdateNavigMFD							
@@:		
mov	si,OFFSET TAB2	;this TAB display
mov	di,OFFSET TAB1	;other TAB display		
        test	TAB_STATUS[di],1	;TAB on?
		_JZ	GoSwitchedOff			
		;call	UpdateTAB2	
cmp	TAB2.TAB_MODE,TAB_FLIR_ORI
jne @F
        ;call	UpdateNavigMFD							
@@:				
cmp	TAB2.TAB_MODE,TAB_TIALD_ORI
jne @F
        cmp	TrueRadAlt,MIN_OP_RAD_ALT	;rad alt ok?
		jge SkipDrawDeBug
		call DrawADIRollBug		
SkipDrawDeBug:		
        ;call	UpdateNavigMFD							
@@:
		call	UpdateStores
        jmp Neutral		
GoSwitchedOff:		
		;call	UpdateTAB2			
		call	UpdateStores		
Neutral:		
		cmp	ShakeUp,1
		_JNE NoShakesNavig	
        call	RandX		; 0.00 ..  2.55 secs
		cmp	ax,(2*256)/100	;2% chance of random shake in cockpit
		ja	SkipShakeNav0
		call	RandX	
		cmp	ax,(30*256)/100	
		jb SkipShakeNav1
		SHAKE	SHAKE_LAND_GOOD,HSHAKE_OFF,VSHAKE_OFF,5
		ret
SkipShakeNav1:
		cmp	ax,(50*256)/100	
		jb SkipShakeNav2
        SHAKE	SHAKE_LAND_GOOD,HSHAKE_LO,VSHAKE_LO,5
		ret
SkipShakeNav2:
		cmp	ax,(75*256)/100	
		jb SkipShakeNav3
        SHAKE	SHAKE_LAND_GOOD,HSHAKE_OFF,VSHAKE_LO,5
		ret		
SkipShakeNav3:		
        SHAKE	SHAKE_LAND_GOOD,HSHAKE_LO,VSHAKE_OFF,5
		ret
SkipShakeNav0:
        SHAKE	SHAKE_NOSE_DOWN,HSHAKE_OFF,VSHAKE_OFF,5	
NoShakesNavig:		
		ret

UpdateNavig	ENDP

;----------------------------------------------------------------------------

;* InitPanel - initialize
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

InitPanel	PROC	NEAR

		call	ClearNavigPanel

		mov	si,OFFSET SetUp$
		call	Print$

		ret

InitPanel	ENDP

;----------------------------------------------------------------------------

;* UpdateADI - update attitude direction indicator (artificial horizon)
;*
;* pass: M_VIEW
;*       Roll
;* ret : nothing
;* kill: assume all

UpdateADI	PROC	NEAR

;--------------
;* draw horizon
;--------------

;* set visual view mode for artificial horizon

		mov	ax,TV5_VIEWMODE
		mov	cx,72
		mov	bl,141
		call	SetViewMode

		mov	si,OFFSET M_VIEW

		mov	cx,M_SinR
		mov	dx,M_CosR

		mov	al,COL_ADI_GND
		mov	ah,COL_ADI_SKY

		call	UserHorizon

;* restore view mode

		mov	ax,INT_VIEWMODE
		call	SetViewMode

		ret

UpdateADI	ENDP

;----------------------------------------------------------------------------

;* DrawADIRollBug - draw attitude direction indicator roll bug
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

DrawADIRollBug	PROC	NEAR

XCENTRE		=	84
YCENTRE		=	150

;* index = Roll * (3527 / 32768)

		mov	ax,Roll
		mov	dx,3527
		imul	dx
		FRACADJ	si
		shl	si,1		;*2 index

		mov	cx,XCENTRE
		mov	bl,YCENTRE

		mov	al,DialXY1[si+0]	;x offset
		cbw
		neg	ax			;flip x
		add	cx,ax

		mov	al,DialXY1[si+1]	;y offset
		neg	al			;flip y
		add	bl,al

		mov	al,COL_BUG

		call	SetPixel

		ret

DrawADIRollBug	ENDP

;----------------------------------------------------------------------------

;* UpdateHSI - update horizontal situation indicator
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

UpdateHSI 	PROC	NEAR

;------------------
;* draw heading bug
;------------------

XCENTRE		=	87
YCENTRE		=	184

;* index = Hdg * (4864 / 32768)

		mov	ax,Hdg
		mov	dx,4864
		imul	dx
		FRACADJ	si
		shl	si,1		;*2 index

		mov	cx,XCENTRE
		mov	bl,YCENTRE

		mov	al,DialXY3[si+0]	;x offset
		cbw
		add	cx,ax

		add	bl,DialXY3[si+1]	;y offset

		mov	al,COL_BUG

		call	SetPixel

;-------------------------------------------------
;* calc localiser and glide slope needle positions
;-------------------------------------------------

		test	ILSActive,1	;active?
		jz	@F		;no, use previous values ->

;* localiser

		mov	ax,ILSLocalPos

		cwd

		REPT	2		;*4
		shl	ax,1
		rcl	dx,1
		ENDM

		FRACADJ	dx

		neg	dx

		add	dx,LOCAL_X

		mov	LocalXPos,dx

;* glide slope

		mov	ax,ILSGlidePos

		cwd

		shl	ax,1		;*2
		rcl	dx,1

		mov	bx,ax
		mov	cx,dx

		shl	ax,1		;*4
		rcl	dx,1

		add	ax,bx		;*6
		adc	dx,cx

		FRACADJ	dx

		add	dx,GLIDE_Y

		mov	GlideYPos,dl

;-----------------------
;* draw localiser needle (use different colours wrt day / night)
;-----------------------

@@:	  	cmp	Night,0		;night?
		jne	@F		;yes ->

		mov	al,COL_LOCAL1
		mov	cx,LocalXPos
		mov	bl,LOCAL_Y-4
		call	SetPixel

		mov	al,COL_LOCAL2
		mov	cx,LocalXPos
		mov	bl,LOCAL_Y-3
		call	SetPixel

		mov	al,COL_LOCAL3
		mov	cx,LocalXPos
		mov	bl,LOCAL_Y-2
		call	SetPixel

		mov	al,COL_LOCAL4
		mov	cx,LocalXPos
		mov	bl,LOCAL_Y-1
		call	SetPixel

		mov	al,COL_LOCAL5
		mov	cx,LocalXPos
		mov	bl,LOCAL_Y
		call	SetPixel

		mov	al,COL_LOCAL4
		mov	cx,LocalXPos
		mov	bl,LOCAL_Y+1
		call	SetPixel

		mov	al,COL_LOCAL3
		mov	cx,LocalXPos
		mov	bl,LOCAL_Y+2
		call	SetPixel

		mov	al,COL_LOCAL2
		mov	cx,LocalXPos
		mov	bl,LOCAL_Y+3
		call	SetPixel

		mov	al,COL_LOCAL1
		mov	cx,LocalXPos
		mov	bl,LOCAL_Y+4
		call	SetPixel

		jmp	LocalOk

@@:		mov	al,COL_NT_LOCAL1
		mov	cx,LocalXPos
		mov	bl,LOCAL_Y-4
		call	SetPixel

		mov	al,COL_NT_LOCAL2
		mov	cx,LocalXPos
		mov	bl,LOCAL_Y-3
		call	SetPixel

		mov	al,COL_NT_LOCAL3
		mov	cx,LocalXPos
		mov	bl,LOCAL_Y-2
		call	SetPixel

		mov	al,COL_NT_LOCAL4
		mov	cx,LocalXPos
		mov	bl,LOCAL_Y-1
		call	SetPixel

		mov	al,COL_NT_LOCAL5
		mov	cx,LocalXPos
		mov	bl,LOCAL_Y
		call	SetPixel

		mov	al,COL_NT_LOCAL4
		mov	cx,LocalXPos
		mov	bl,LOCAL_Y+1
		call	SetPixel

		mov	al,COL_NT_LOCAL3
		mov	cx,LocalXPos
		mov	bl,LOCAL_Y+2
		call	SetPixel

		mov	al,COL_NT_LOCAL2
		mov	cx,LocalXPos
		mov	bl,LOCAL_Y+3
		call	SetPixel

		mov	al,COL_NT_LOCAL1
		mov	cx,LocalXPos
		mov	bl,LOCAL_Y+4
		call	SetPixel

;-------------------------
;* draw glide slope needle (use different colours wrt day / night)
;-------------------------

LocalOk:	cmp	Night,0		;night?
		jne	@F		;yes ->

		mov	al,COL_GLIDE1
		mov	cx,GLIDE_X-1
		mov	bl,GlideYPos
		call	SetPixel

		mov	al,COL_GLIDE2
		mov	cx,GLIDE_X
		mov	bl,GlideYPos
		call	SetPixel

		mov	al,COL_GLIDE3
		mov	cx,GLIDE_X+1
		mov	bl,GlideYPos
		call	SetPixel

		jmp	GlideOk

@@:		mov	al,COL_NT_GLIDE1
		mov	cx,GLIDE_X-1
		mov	bl,GlideYPos
		call	SetPixel

		mov	al,COL_NT_GLIDE2
		mov	cx,GLIDE_X
		mov	bl,GlideYPos
		call	SetPixel

		mov	al,COL_NT_GLIDE3
		mov	cx,GLIDE_X+1
		mov	bl,GlideYPos
		call	SetPixel

GlideOk:	ret

UpdateHSI 	ENDP

;----------------------------------------------------------------------------

;* UpdateAltimeter - update servo altimeter
;*
;* pass: ZftLo
;*       ZftHi
;* kill: nothing
;* ret : assume all

UpdateAltimeter	PROC	NEAR

;---------------------------
;* print barometric altitude (to 100ft resolution)
;---------------------------

		mov	dx,ZftHi
		mov	ax,ZftLo
		mov	bx,100
		div	bx

		mov	TempVal,ax
	
		mov	si,OFFSET BarAlt$
		call	Print$

;------------------------
;* draw 1,000ft indicator
;------------------------

XCENTRE		=	141
YCENTRE		=	25

;* index = altitude mod 1000 * (2097 / 32768)

		mov	dx,ZftHi
		mov	ax,ZftLo
		mov	bx,1000
		div	bx

		mov	ax,2097
		imul	dx
		FRACADJ	si
		shl	si,1		;*2 index

		mov	cx,XCENTRE
		mov	bl,YCENTRE

		mov	dx,cx
		mov	al,DialXY2[si+0]	;x offset
		cbw
		add	dx,ax

		mov	bh,bl
		add	bh,DialXY2[si+1]	;y offset

		mov	al,COL_NEEDLE

		call	LineDraw

;-------------------------
;* draw 10,000ft indicator
;-------------------------

XCENTRE		=	141
YCENTRE		=	25

;* index = altitude mod 10000 * (183 / 32768)

		mov	dx,ZftHi
		mov	ax,ZftLo
		mov	bx,10000
		div	bx

		mov	ax,183
		imul	dx
		FRACADJ	si
		shl	si,1		;*2 index

		mov	cx,XCENTRE
		mov	bl,YCENTRE

		mov	dx,cx
		mov	al,DialXY1[si+0]	;x offset
		cbw
		neg	ax			;flip x
		add	dx,ax

		mov	bh,bl
		mov	al,DialXY1[si+1]	;y offset
		neg	al			;flip y
		add	bh,al

		mov	al,COL_NEEDLE

		call	LineDraw

		ret

UpdateAltimeter	ENDP

;----------------------------------------------------------------------------

;* UpdateSpeed - update combined speed indicator
;*
;* pass: DispMachNum
;*       Vkts
;* ret : nothing
;* kill: assume all

UpdateSpeed	PROC	NEAR

XCENTRE		=	177
YCENTRE		=	25

;-------------------
;* print mach number
;-------------------

		mov	ax,DispMachNum

		aam			;ah = integer, al = fraction

;* print "d.d"

		mov	PrtCl,XCENTRE-5
		mov	PrtLn,YCENTRE+1

		add	al,'0'
		add	ah,'0'

		push	ax
		mov	al,ah
		call	PrintChar
		add	PrtCl,4
		pop	ax
		call	PrintChar

;--------------------
;* airspeed indicator
;--------------------

;* index = min(Vkts, 850) * (2330 / 32768)

		mov	ax,Vkts

		cmp	ax,850 		;Vkts <= fsd?
		jbe	@F		;yes ->
		mov	ax,850		;limit to fsd

@@:		mov	dx,2330
		imul	dx
		FRACADJ	si
		shl	si,1		;*2 index

		mov	cx,XCENTRE
		mov	bl,YCENTRE

		mov	dx,cx
		mov	al,DialXY2[si+0]	;x offset
		cbw
		add	dx,ax

		mov	bh,bl
		add	bh,DialXY2[si+1]	;y offset

		mov	al,COL_NEEDLE

		call	LineDraw

		ret

UpdateSpeed	ENDP

;----------------------------------------------------------------------------

;* UpdateClock
;*
;* pass: Clock24
;* ret : nothing
;* kill: assume all

UpdateClock	PROC	NEAR

XCENTRE		=	37
YCENTRE		=	173

;-----------
;* hour hand
;-----------

		mov	al,Clock24.CLK_HRS
		mov	ah,60
		mul	ah
		add	al,Clock24.CLK_MINS
		adc	ah,0

		cmp	ax,12*60	;after midday?
		jb	@F		;no ->
		sub	ax,12*60	;wrap around

@@:		mov	dx,2367		;2367 = (52 / (12 * 60)) * 32768
		imul	dx
		FRACADJ	si
		shl	si,1		;*2 index

		mov	cx,XCENTRE
		mov	bl,YCENTRE

		mov	dx,cx
		mov	al,ClockDial2[si+0]	;x offset
		cbw
		add	dx,ax

		mov	bh,bl
		add	bh,ClockDial2[si+1]	;y offset

		mov	al,COL_NEEDLE

		call	LineDraw

;-------------
;* minute hand
;-------------

		mov	al,Clock24.CLK_MINS
		xor	ah,ah
		mov	dx,34953	;34953 = (64 / 60) * 32768
		mul	dx
		FRACADJ	si
		shl	si,1		;*2 index

		mov	cx,XCENTRE
		mov	bl,YCENTRE

		mov	dx,cx
		mov	al,ClockDial1[si+0]	;x offset
		cbw
		add	dx,ax

		mov	bh,bl
		add	bh,ClockDial1[si+1]	;y offset

		mov	al,COL_NEEDLE

		call	LineDraw

;-------------
;* second hand
;-------------

		mov	al,Clock24.CLK_SECS
		xor	ah,ah
		mov	dx,34953	;34953 = (64 / 60) * 32768
		mul	dx
		FRACADJ	si
		shl	si,1		;*2 index

		mov	cx,XCENTRE
		mov	bl,YCENTRE

		mov	al,ClockDial1[si+0]	;x offset
		cbw
		add	cx,ax

		add	bl,ClockDial1[si+1]	;y offset

;* calc tail end co-ords

		mov	al,Clock24.CLK_SECS
		xor	ah,ah
		mov	dx,8738		;8738 = (16 / 60) * 32768
		imul	dx
		FRACADJ	si
		shl	si,1		;*2 index

		mov	dx,XCENTRE
		mov	bh,YCENTRE

		mov	al,ClockDial3[si+0]	;x offset
		cbw
		add	dx,ax

		add	bh,ClockDial3[si+1]	;y offset

		mov	al,COL_RED_NEEDLE

		call	LineDraw

		ret

UpdateClock	ENDP

;----------------------------------------------------------------------------

;* UpdateStores - update stores display screen
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

UpdateStores	PROC	NEAR
		
		mov	di,OFFSET TAB1	;other TAB display
		mov	si,OFFSET TAB2	;this TAB display
	
	    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		; Handling Damaged Tabs
		; Frankie Kam
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		mov	bx,TAB_SSF_PTR[di]   ;Tab1 damaged?
		test	BYTE PTR [bx],1		
		_JNZ	TVTab1DamagedOrOff ;yes
		
		; Check if Tab1 is switched off!
		mov	di,OFFSET TAB1	;this TAB display
        test	TAB_STATUS[di],1	;TAB switched on?
        _JZ	TVTab1DamagedOrOff		;no, it is OFF! ->
		
		mov	bx,TAB_SSF_PTR[si]  ;;Tab2 damaged?
		test	BYTE PTR [bx],1
		_JNZ	TVTab2DamagedOrOff ;yes
		
		; Check if Tab2 is switched off!
		mov	si,OFFSET TAB2	;this TAB display
        test	TAB_STATUS[si],1	;TAB switched on?
        _JZ	TVTab2DamagedOrOff		;no, it is OFF! ->		
		
		jmp BothTabsUndamagedOrOff
TVTab1DamagedOrOff: 
		        mov	bx,TAB_SSF_PTR[si]  ;;Tab2 damaged?
		        test	BYTE PTR [bx],1
		        _JNZ	BothTabsDamagedOrOff ;yes

				; Check if Tab2 is switched off!
				test	TAB_STATUS[si],1	;TAB switched on?
				_JZ	BothTabsDamagedOrOff		;no, it is OFF! ->						
				
				;Check Tab2 TIALD over the limit?
				cmp	TAB2.TAB_MODE,TAB_TIALD_ORI
				jne SkipCheckM_CosR
		        cmp	M_CosP,16384	;pitch in limits (+/-60degs)?
		        jl	BothTabsDamagedOrOff		;no, so show "X" as invalid display ->							
				cmp	M_CosR,16384	;roll in limits (+/-60degs)?
		        jl	BothTabsDamagedOrOff		;no, so show "X" as invalid display ->
SkipCheckM_CosR:				
				
			   cmp	TAB2.TAB_MODE,TAB_FLIR_ORI
			   je @F
			   cmp	TAB2.TAB_MODE,TAB_TIALD_ORI
			   je @F
			   call VGA_DrwNavigPanBrief			   
			   call	DrawADIRollBug	
			   call UpdateStores2 ;else, show SMD at the bottom centre!
			   ret			   
           @@:   
			   call UpdateNavigMFD		   
               call UpdateStores3 ;Show SMD at the top left
			   ret
TVTab2DamagedOrOff:
		       mov	bx,TAB_SSF_PTR[di]   ;Tab1 damaged?
		       test	BYTE PTR [bx],1		
		        _JNZ	BothTabsDamagedOrOff ;yes

				; Check if Tab1 is switched off!
				test	TAB_STATUS[di],1	;TV-Tab2 switched on?
				_JZ	BothTabsDamagedOrOff    ;no, it is OFF! ->						
				
				;Check Tab1 TIALD over the limit?
				cmp	TAB1.TAB_MODE,TAB_TIALD_ORI
				jne SkipCheckM_CosR2
				
		        cmp	M_CosP,16384	;pitch in limits (+/-60degs)?
		        jl	BothTabsDamagedOrOff		;no, so show "X" as invalid display ->			
				cmp	M_CosR,16384	;roll in limits (+/-60degs)?
		        jl	BothTabsDamagedOrOff		;no, so show "X" as invalid display ->
SkipCheckM_CosR2:				
				
				
			   cmp	TAB1.TAB_MODE,TAB_FLIR_ORI
			   je @F
			   cmp	TAB1.TAB_MODE,TAB_TIALD_ORI
			   je @F
		       call VGA_DrwNavigPanBrief			   			   
			   call	DrawADIRollBug	
			   call UpdateStores2 ;else, show SMD at the bottom centre!
			   ret			   
           @@:   
               call UpdateStores3 ;Show SMD at the top left
			   ret
BothTabsDamagedOrOff:
			   call VGA_DrwNavigPanBrief
			   call	DrawADIRollBug				   
			   call UpdateStores2 ;else, show SMD at the bottom centre!
               ret
BothTabsUndamagedOrOff:

;---------------
;* clear display
;---------------
		mov	cx,SDISP_X_ORG
		mov	bl,SDISP_Y_ORG		
		mov	dx,SDISP_X_ORG+SDISP_WIDTH-1
		mov	bh,SDISP_Y_ORG+SDISP_DEPTH-1		

		mov	al,COL_CRT1
		
        ;If full-Screen TIALD in TV-Tab1 (left) then check if outside TIALD pitch limits
		cmp	TAB1.TAB_MODE,TAB_TIALD_ORI
		jne @F
		cmp	TAB2.TAB_MODE,TAB_FLIR_ORI
	    je @F
		cmp	M_CosP,16384	;pitch in limits (+/-60degs)?
		jl	GotoUpdateStores2		;no ->
		cmp	M_CosR,16384	;roll in limits (+/-60degs)?
		jl	GotoUpdateStores2		;no ->
		jmp MoreChecks
GotoUpdateStores2:
        call DrawADIRollBug
		
		;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		; Check if Tab1 is switched off!
		; Frankie Kam
		mov	si,OFFSET TAB1	;this TAB display
        test	TAB_STATUS[si],1	;TAB switched on?
        _JZ	Tab1IsSwitchedOff		;no, it is OFF! ->
		call UpdateStores2
		ret
Tab1IsSwitchedOff:

		cmp	M_CosP,16384	;pitch in limits (+/-60degs)?
		jl	Breakthrough		;no ->
		cmp	M_CosR,16384	;roll in limits (+/-60degs)?
		jl	Breakthrough


        ;call UpdateNavigMFD
		cmp	TAB2.TAB_MODE,TAB_FLIR_ORI
		je Ozark
		cmp	TAB2.TAB_MODE,TAB_TIALD_ORI
		je Ozark		
Breakthrough:		
		call UpdateStores2
		ret
Ozark:
        mov	di,OFFSET TAB2	;this TAB display
        test	TAB_STATUS[di],1	;TAB switched on?
        _JZ	Tab1IsSwitchedOffz		;no, it is OFF! ->
		
		call UpdateStores3
		ret
Tab1IsSwitchedOffz:
		call UpdateStores2
		ret

		
@@:		;If full-Screen TIALD in TV-Tab2 (right) then check if outside TIALD pitch limits
        cmp	TAB1.TAB_MODE,TAB_FLIR_ORI
		je MoreChecks
        cmp	TAB2.TAB_MODE,TAB_FLIR_ORI
		je MoreChecks		
		cmp	TAB2.TAB_MODE,TAB_TIALD_ORI
		jne SkipGotoUpdateStores2
		cmp	M_CosP,16384	;pitch in limits (+/-60degs)?
		jl	GotoUpdateStores2		;no ->
		cmp	M_CosR,16384	;roll in limits (+/-60degs)?
		jl	GotoUpdateStores2		;no ->
		jmp MoreChecks
MoreChecks: 
;-----------------------
;* test for TAB on / off
;-----------------------
		mov	si,OFFSET TAB1	;TV-TAB1 (left) display
		mov	di,OFFSET TAB2	;TV-TAB2 (right) display	
		
        test TAB_STATUS[si],1
		_JZ GotoUpdateStores2		;yes, still on->			
				
        test TAB_STATUS[di],1
		_JZ CheckIfTVTab1CurrActiveDisp
		jmp SkipCheckIfTVTab1CurrActiveDisp
CheckIfTVTab1CurrActiveDisp:	
        cmp	TAB1.TAB_MODE,TAB_FLIR_ORI
        je	SkipGotoUpdateStores2	
        cmp	TAB1.TAB_MODE,TAB_TIALD_ORI
        je	SkipGotoUpdateStores2		
		jmp GotoUpdateStores2		;yes, still on->			
SkipCheckIfTVTab1CurrActiveDisp:
		
SkipGotoUpdateStores2:
		cmp	TrueRadAlt,MIN_OP_RAD_ALT	;minimum alt for TIALD not ok?
		jl CallBlockFill ; --> not ok
		cmp	TAB1.TAB_MODE,TAB_FLIR_ORI	;full-screen FLIR on TV-TAB1?
		je SkipBlockFill
		cmp	TAB1.TAB_MODE,TAB_TIALD_ORI	;full-screen TIALD on TV-TAB1?
		je SkipBlockFill	
		cmp	TAB2.TAB_MODE,TAB_FLIR_ORI	;full-screen FLIR on TV-TAB2?
		je SkipBlockFill					
		cmp	TAB2.TAB_MODE,TAB_TIALD_ORI	;full-screen TIALD on TV-TAB2?
		je SkipBlockFill							
CallBlockFill:		
		cmp	TAB1.TAB_MODE,TAB_FLIR_ORI	;full-screen FLIR on TV-TAB1?
		je SkipBlockFill
		cmp	TAB2.TAB_MODE,TAB_FLIR_ORI	;full-screen FLIR on TV-TAB2?
		je SkipBlockFill							
		call	BlockFill
SkipBlockFill:
;--------------------
;* update blink timer
;--------------------

		mov	ax,ArmBlinkTimer
		sub	ax,LastFrame
		jnc	@F

		xor	ArmBlink,1	;toggle blink state

		mov	ax,ARM_BLINK_TIME

@@:		mov	ArmBlinkTimer,ax

;-------------------------
;* sort layout wrt variant
;-------------------------

		mov	bx,TornadoType

		jmp	LayoutSwitch[bx]

;---------------------------
IDSLayout	LABEL	NEAR
ECRLayout	LABEL	NEAR
;---------------------------

;----------------------
;* draw separator lines
;----------------------
	    ;mov	si,OFFSET TAB2	;this TAB display
		;mov	di,OFFSET TAB1	;other TAB display
        ;mov	bx,TAB_SSF_PTR[si]
		;test	BYTE PTR [bx],1     ;test for damaged TAB
		;_JNZ	ExitActDisp
		;mov	ax,TAB_SSF_PTR[di]
		;test	BYTE PTR [bx],1		;other TAB display damaged?
		;_JNZ	ExitActDisp
		;and bx, ax
		;jz	ExitActDisp
		cmp	TrueRadAlt,MIN_OP_RAD_ALT	;minimum alt for TIALD not ok?
		jl DontSkipHLineDraw ; --> not ok
		cmp	TAB1.TAB_MODE,TAB_FLIR_ORI	;full-screen FLIR selected on left TV-Tab?		
		je SkipHLineDraw
		cmp	TAB1.TAB_MODE,TAB_TIALD_ORI	;full-screen TIALD selected on left TV-Tab?	
		je SkipHLineDraw
		cmp	TAB2.TAB_MODE,TAB_FLIR_ORI	;full-screen FLIR selected on right TV-Tab?		
		je SkipHLineDraw
		cmp	TAB2.TAB_MODE,TAB_TIALD_ORI	;full-screen TIALD selected on right TV-Tab?	
		je SkipHLineDraw
DontSkipHLineDraw:		
		cmp	TAB1.TAB_MODE,TAB_FLIR_ORI	;full-screen FLIR selected on left TV-Tab?		
		je SkipHLineDraw
		cmp	TAB2.TAB_MODE,TAB_FLIR_ORI	;full-screen FLIR selected on left TV-Tab?		
		je SkipHLineDraw		
		mov	cx,128
		mov	dx,191
		mov	bl,167
		mov	al,COL_CRT3
		call	HLineDraw

		mov	cx,128
		mov	dx,191
		mov	bl,181
		mov	al,COL_CRT3
		call	HLineDraw
SkipHLineDraw:
;------------------
;* display packages
;------------------
		cmp	TrueRadAlt,MIN_OP_RAD_ALT	;minimum alt for TIALD not ok?
		jl DontSkipPrtLn149 ; --> not ok
		cmp	TAB1.TAB_MODE,TAB_FLIR_ORI	;full-screen FLIR selected on left TV-Tab1?			
		je SkipPrtLn149
		cmp	TAB1.TAB_MODE,TAB_TIALD_ORI	;full-screen TIALD selected on left TV-Tab1?	
		je SkipPrtLn149
		cmp	TAB2.TAB_MODE,TAB_FLIR_ORI	;full-screen FLIR selected on right TV-Tab2?			
		je SkipPrtLn149_rightTVTab
		cmp	TAB2.TAB_MODE,TAB_TIALD_ORI	;full-screen TIALD selected on right TV-Tab2?			
		je SkipPrtLn149_rightTVTab
DontSkipPrtLn149:		
		cmp	TAB1.TAB_MODE,TAB_FLIR_ORI	;full-screen FLIR selected on left TV-Tab1?			
		je SkipPrtLn149
		cmp	TAB2.TAB_MODE,TAB_FLIR_ORI	;full-screen FLIR selected on left TV-Tab1?			
		je SkipPrtLn149		
godoit1:	
		mov	PrtLn,149
		jmp SkipSkipPrtLn149
		
SkipPrtLn149:
        mov	PrtLn,50 ;50
		jmp SkipSkipPrtLn149
SkipPrtLn149_rightTVTab:
		;mov PrtLn,5
		mov PrtLn,50
SkipSkipPrtLn149:		
		mov	cx,NUM_PACKAGES

		mov	si,OFFSET Packages

PackageLoop:  	cmp	[si].PACK_WEAP_TYPE,NULL_WEAPON	;null package?
		_JE	SkipPackage	    		;yes ->

	    push	cx
		push	si

;* blink if current package and armed

		cmp	si,PackagePtr	;current package?
		jne	SkipPackBlink	;no ->

		mov	ax,[si].PACK_WEAP_MODE

		cmp	ax,ArmMode	;armed?
		jne	SkipPackBlink	;no ->

		test	ArmBlink,1   	;blink on?
		_JZ	NextPackage  	;no ->

;* hi-lite text if current package

SkipPackBlink:	

        cmp	TrueRadAlt,MIN_OP_RAD_ALT
		jl DontSkipPrtCl128
		cmp	TAB1.TAB_MODE,TAB_FLIR_ORI	;full-screen FLIR selected on left TV-Tab?	
		je SkipPrtCl128
		cmp	TAB1.TAB_MODE,TAB_TIALD_ORI	;full-screen TIALD selected on left TV-Tab?		
		je SkipPrtCl128
		cmp	TAB2.TAB_MODE,TAB_FLIR_ORI	;full-screen FLIR selected on right TV-Tab?	
		je SkipPrtCl128
		cmp	TAB2.TAB_MODE,TAB_TIALD_ORI	;full-screen TIALD selected on right TV-Tab?	
		je SkipPrtCl128
DontSkipPrtCl128:
		cmp	TAB1.TAB_MODE,TAB_FLIR_ORI	;full-screen FLIR selected on left TV-Tab?	
		je SkipPrtCl128
		cmp	TAB2.TAB_MODE,TAB_FLIR_ORI	;full-screen FLIR selected on left TV-Tab?	
		je SkipPrtCl128		

        mov	PrtCl,128
		push	si

		cmp	si,PackagePtr		;current package?

		mov	si,OFFSET WpnSetUp1$	;assume not

		jne	@F			;no ->
		
		mov	si,OFFSET WpnSetUp2$
		
		jmp SkipSkipPrtCl128
SkipPrtCl128:
        mov	PrtCl,1
		push	si

		cmp	si,PackagePtr		;current package?

		mov	si,OFFSET WpnSetUp1_fullscr$	;assume not

		jne	@F			;no ->
		
		mov	si,OFFSET WpnSetUp2_fullscr$

SkipSkipPrtCl128:		
		

@@:		call	Print$

		pop	si

;* print target waypoint identifier

		mov	al,[si].PACK_WP_ID
		cmp	TrueRadAlt,MIN_OP_RAD_ALT
		jl DontSkipPrintChar

		cmp	TAB1.TAB_MODE,TAB_FLIR_ORI	;full-screen FLIR selected on left TV-Tab?		
		je SkipPrintChar
		cmp	TAB1.TAB_MODE,TAB_TIALD_ORI	;full-screen TIALD selected on left TV-Tab?		
		je SkipPrintChar
		cmp	TAB2.TAB_MODE,TAB_FLIR_ORI	;full-screen FLIR selected on right TV-Tab?		
		je SkipPrintChar
		cmp	TAB2.TAB_MODE,TAB_TIALD_ORI	;full-screen TIALD selected on right TV-Tab?		
		je SkipPrintChar	
DontSkipPrintChar:		
		cmp	TAB1.TAB_MODE,TAB_FLIR_ORI	;full-screen FLIR selected on left TV-Tab?		
		je SkipPrintChar
		cmp	TAB2.TAB_MODE,TAB_FLIR_ORI	;full-screen FLIR selected on left TV-Tab?		
		je SkipPrintChar		
		
		call PrintChar		
		
SkipPrintChar:		
        add	PrtCl,4
		push	si

		mov	si,[si].PACK_WEAP_TYPE

		REPT	2		;*4 (string length 8 bytes)
		shl	si,1
		ENDM

		add	si,OFFSET Weapon$

		call	Print$

		mov	al,'x'
		call	PrintChar

		pop	si

;* print number of weapons in package

		mov	DecAttr,00010010b	;(unsigned, 2 digits, left justified)

		mov	ax,[si].PACK_WEAP_NUM
		call	PrintDecWord

		mov	DecAttr,00000000b	;(default)

;* print delivery mode (if applicable)

		mov	ax,[si].PACK_WEAP_MODE

		mov	si,OFFSET ManBomb$
		cmp	ax,ARM_MANUAL
		je	@F

		mov	si,OFFSET LayBomb$
		cmp	ax,ARM_LAYDOWN
		je	@F

		mov	si,OFFSET LftBomb$
		cmp	ax,ARM_LOFT
		je	@F

		mov	si,OFFSET LGBBomb$
		cmp	ax,ARM_LGB
		je	@F

		mov	si,OFFSET DirAlarm$
		cmp	ax,ARM_ALARM_DIR
		je	@F

		mov	si,OFFSET IndAlarm$
		cmp	ax,ARM_ALARM_IND
		je	@F

		jmp	NextPackage

@@:		
		cmp	TrueRadAlt,MIN_OP_RAD_ALT
		jl DontSkipPrtCl180
		
		cmp	TAB1.TAB_MODE,TAB_FLIR_ORI	;map selected?		
		je SkipPrtCl180
		cmp	TAB1.TAB_MODE,TAB_TIALD_ORI	;map selected?		
		je SkipPrtCl180
		cmp	TAB2.TAB_MODE,TAB_FLIR_ORI	;map selected?		
		je SkipPrtCl180
		cmp	TAB2.TAB_MODE,TAB_TIALD_ORI	;map selected?		
		je SkipPrtCl180
DontSkipPrtCl180:		
		cmp	TAB1.TAB_MODE,TAB_FLIR_ORI	;map selected?		
		je SkipPrtCl180
		cmp	TAB2.TAB_MODE,TAB_FLIR_ORI	;map selected?		
		je SkipPrtCl180		

        mov	PrtCl,180
		jmp AfterSkipPrtCl180
SkipPrtCl180:
        mov	PrtCl,51
AfterSkipPrtCl180:		

		call	Print$

NextPackage:  	pop	si
		pop	cx
		
		add	PrtLn,6

SkipPackage:	add	si,PACK_REC_SIZE

		_LOOP	PackageLoop

;----------------------------
;* display air-to-air weapons
;----------------------------

;* cannons
		cmp	TrueRadAlt,MIN_OP_RAD_ALT
		jl DontSkipPrtLn169_PrtCl140

		cmp	TAB1.TAB_MODE,TAB_FLIR_ORI	;map selected?		
		je SkipPrtLn169_PrtCl140
		cmp	TAB1.TAB_MODE,TAB_TIALD_ORI	;map selected?		
		je SkipPrtLn169_PrtCl140
		cmp	TAB2.TAB_MODE,TAB_FLIR_ORI	;map selected?		
		je SkipPrtLn169_PrtCl140_RightTVTab
		cmp	TAB2.TAB_MODE,TAB_TIALD_ORI	;map selected?		
		je SkipPrtLn169_PrtCl140_RightTVTab
DontSkipPrtLn169_PrtCl140:		
		cmp	TAB1.TAB_MODE,TAB_FLIR_ORI	;map selected?		
		je SkipPrtLn169_PrtCl140
		cmp	TAB2.TAB_MODE,TAB_FLIR_ORI	;map selected?		
		je SkipPrtLn169_PrtCl140		

		mov	PrtLn,169
		mov	PrtCl,140
		jmp SkipSkipPrtLn169_PrtCl140

SkipPrtLn169_PrtCl140:
		mov	PrtLn,70
		mov	PrtCl,10
		jmp SkipSkipPrtLn169_PrtCl140
SkipPrtLn169_PrtCl140_RightTVTab:
        mov	PrtCl,10
		;mov	PrtLn,25
		mov	PrtLn,70
SkipSkipPrtLn169_PrtCl140:
		cmp	Cannons,0		;any cannons?
		je	SkipAirWpn1		;no ->

		cmp	TrueRadAlt,MIN_OP_RAD_ALT
		jl DontSkipBlink
		cmp	TAB1.TAB_MODE,TAB_FLIR_ORI	;map selected?		
		je SkipBlink
		cmp	TAB1.TAB_MODE,TAB_TIALD_ORI	;map selected?		
		je SkipBlink
		cmp	TAB2.TAB_MODE,TAB_FLIR_ORI	;map selected?		
		je SkipBlink
		cmp	TAB2.TAB_MODE,TAB_TIALD_ORI	;map selected?		
		je SkipBlink
DontSkipBlink:
		cmp	TAB1.TAB_MODE,TAB_FLIR_ORI	;map selected?		
		je SkipBlink
		cmp	TAB2.TAB_MODE,TAB_FLIR_ORI	;map selected?		
		je SkipBlink		
;* do not blink when counting down

		test	CannonFired,1		;counting down?
		jnz	@F			;yes ->

		cmp	ArmMode,ARM_CANNON	;armed?
		jne	@F			;no ->

		test	ArmBlink,1		;blink on?
		jz	NextAirWpn1		;no ->

@@:		cmp	AirArmMode,ARM_CANNON	;current air-to-air weapon?

		mov	si,OFFSET WpnSetUp1$	;assume not (normal)
		jne	@F			;no ->
		
		mov	si,OFFSET WpnSetUp2$	;assume not (normal)
@@:		call	Print$

		mov	si,OFFSET Cannon$
		call	Print$
		jmp SkipSkipBlink

SkipBlink:
;* do not blink when counting down

		test	CannonFired,1		;counting down?
		jnz	@F			;yes ->

		cmp	ArmMode,ARM_CANNON	;armed?
		jne	@F			;no ->

		test	ArmBlink,1		;blink on?
		jz	NextAirWpn1		;no ->

@@:		cmp	AirArmMode,ARM_CANNON	;current air-to-air weapon?

		mov	si,OFFSET WpnSetUp1_fullscr$	;assume not (normal)
		jne	@F			;no ->
		
		mov	si,OFFSET WpnSetUp2_fullscr$	;assume not (normal)
@@:		call	Print$

		mov	si,OFFSET Cannon$
		call	Print$
		
SkipSkipBlink:
;* Sidewinders

NextAirWpn1:	add	PrtLn,6
SkipAirWpn1:	mov	PrtCl,144

		cmp	TrueRadAlt,MIN_OP_RAD_ALT
		jl DontGoAirArm
		cmp	TAB1.TAB_MODE,TAB_FLIR_ORI	;map selected?		
		je AirArm
		cmp	TAB1.TAB_MODE,TAB_TIALD_ORI	;map selected?		
		je AirArm
		cmp	TAB2.TAB_MODE,TAB_FLIR_ORI	;map selected?		
		je AirArm
		cmp	TAB2.TAB_MODE,TAB_TIALD_ORI	;map selected?		
		je AirArm
DontGoAirArm:
		cmp	TAB1.TAB_MODE,TAB_FLIR_ORI	;map selected?		
		je AirArm
		cmp	TAB2.TAB_MODE,TAB_FLIR_ORI	;map selected?		
		je AirArm		
		cmp	ExtStores[EXT_SIDEWINDER],0	;any Sidewinders?
		je	SkipAirWpn2			;no ->

		cmp	ArmMode,ARM_SIDEWINDER		;armed?
		jne	@F				;no ->

		test	ArmBlink,1			;blink on?
		jz	SkipAirWpn2			;no ->		
		
@@:		cmp	AirArmMode,ARM_SIDEWINDER	;current air-to-air weapon?

		mov	si,OFFSET WpnSetUp1$		;assume not (normal)
		jne	@F

		mov	si,OFFSET WpnSetUp2$		;(hi-lite)
@@:		call	Print$

		mov	si,OFFSET Sidewinder$
		call	Print$
		jmp SkipAirArm

AirArm: mov	PrtCl,15
		cmp	ExtStores[EXT_SIDEWINDER],0	;any Sidewinders?
		je	SkipAirWpn2			;no ->

		cmp	ArmMode,ARM_SIDEWINDER		;armed?
		jne	@F				;no ->

		test	ArmBlink,1			;blink on?
		jz	SkipAirWpn2			;no ->		
		
@@:		cmp	AirArmMode,ARM_SIDEWINDER	;current air-to-air weapon?

		mov	si,OFFSET WpnSetUp1_fullscr$		;assume not (normal)
		jne	@F

		mov	si,OFFSET WpnSetUp2_fullscr$		;(hi-lite)
@@:		call	Print$

		mov	si,OFFSET Sidewinder$
		call	Print$
		
SkipAirArm:
;------------------------
;* display chaff / flares
;------------------------

SkipAirWpn2:	
        ;mov	PrtLn,183
		;mov	PrtCl,144
		cmp	TrueRadAlt,MIN_OP_RAD_ALT
		jl DontSkipChaffAndFlares
		cmp	TAB1.TAB_MODE,TAB_FLIR_ORI	;map selected?		
		je ShowChaffAndFlares
		cmp	TAB1.TAB_MODE,TAB_TIALD_ORI	;map selected?		
		je ShowChaffAndFlares
		cmp	TAB2.TAB_MODE,TAB_FLIR_ORI	;map selected?		
		je ShowChaffAndFlares
		cmp	TAB2.TAB_MODE,TAB_TIALD_ORI	;map selected?		
		je ShowChaffAndFlares
DontSkipChaffAndFlares:		
		cmp	TAB1.TAB_MODE,TAB_FLIR_ORI	;map selected?		
		je ShowChaffAndFlares
		cmp	TAB2.TAB_MODE,TAB_FLIR_ORI	;map selected?		
		je ShowChaffAndFlares		
		cmp	ChaffCntr,0	;any chaff?
		je	@F		;no ->
        mov	PrtLn,183
		mov	PrtCl,144
		mov	si,OFFSET Chaff$
		call	Print$

		add	PrtLn,6
@@:		mov	PrtCl,144

		cmp	FlareCntr,0	;any flares?
		je	@F		;no ->

		mov	si,OFFSET Flare$
		call	Print$
@@:		
		ret
ShowChaffAndFlares:
		cmp	ChaffCntr,0	;any chaff?
		je	@F		;no ->
		add PrtLn,7
		mov	PrtCl,12
		mov	si,OFFSET Chaff$
		call	Print$
@@:		
		add	PrtLn,6
		mov	PrtCl,12

		cmp	FlareCntr,0	;any flares?
		je	@F		;no ->

		mov	si,OFFSET Flare$
		call	Print$
@@:		
		ret
		ret

;---------------------------
ADVLayout	LABEL	NEAR
;---------------------------

;---------------------
;* draw seperator line
;---------------------
		cmp	TAB1.TAB_MODE,TAB_FLIR_ORI	;map selected?		
		je @F
		cmp	TAB2.TAB_MODE,TAB_FLIR_ORI	;map selected?		
		je @F		
		mov	cx,128
		mov	dx,191
		mov	bl,175
		mov	al,COL_CRT3
		call	HLineDraw
@@:
;----------------------------
;* display air-to-air weapons
;----------------------------

;* cannons
		cmp	TAB1.TAB_MODE,TAB_FLIR_ORI	;map selected?		
		je @F
		cmp	TAB2.TAB_MODE,TAB_FLIR_ORI	;map selected?		
		je @F		
		mov	PrtLn,152
		mov	PrtCl,140
		jmp SkipCannonsADV
@@:
		mov	PrtLn,52+2
		mov	PrtCl,10
SkipCannonsADV:		
		

		cmp	Cannons,0		;any cannons?
		je	SkipAirWpn3		;no ->

;* do not blink when counting down

		test	CannonFired,1		;counting down?
		jnz	@F			;yes ->

		cmp	ArmMode,ARM_CANNON	;armed?
		jne	@F			;no ->

		test	ArmBlink,1		;blink on?
		jz	NextAirWpn3		;no ->

@@:		cmp	AirArmMode,ARM_CANNON	;current air-to-air weapon?

		mov	si,OFFSET WpnSetUp1$	;assume not (normal)

		jne	@F			;no ->

		mov	si,OFFSET WpnSetUp2$	;(hi-lite)

@@:		call	Print$

		mov	si,OFFSET Cannon$
		call	Print$

;* Sidewinders

NextAirWpn3:	add	PrtLn,7
SkipAirWpn3:	
		cmp	TAB1.TAB_MODE,TAB_FLIR_ORI	;map selected?		
		je @F
		cmp	TAB2.TAB_MODE,TAB_FLIR_ORI	;map selected?		
		je @F		
		mov	PrtCl,144
		jmp SkipPrtCl_10
@@:		
        mov	PrtCl,10
SkipPrtCl_10:
		cmp	ExtStores[EXT_SIDEWINDER],0	;any Sidewinders?
		je	SkipAirWpn4			;no ->

		cmp	ArmMode,ARM_SIDEWINDER		;armed?
		jne	@F				;no ->

		test	ArmBlink,1			;blink on?
		jz	NextAirWpn4			;no ->

@@:		cmp	AirArmMode,ARM_SIDEWINDER	;current air-to-air weapon?

		mov	si,OFFSET WpnSetUp1$		;assume not (normal)

		jne	@F

		mov	si,OFFSET WpnSetUp2$		;(hi-lite)

@@:		call	Print$

		mov	si,OFFSET Sidewinder$
		call	Print$

;* Sky Flash

NextAirWpn4:	add	PrtLn,7
SkipAirWpn4:	
		cmp	TAB1.TAB_MODE,TAB_FLIR_ORI	;map selected?		
		je @F
		cmp	TAB2.TAB_MODE,TAB_FLIR_ORI	;map selected?		
		je @F		
        mov	PrtCl,140
		jmp SkipToPrtCl10
@@:		
        mov PrtCl,10
SkipToPrtCl10:		
		
		cmp	ExtStores[EXT_SKYFLASH],0	;any Sky Flash?
		je	SkipAirWpn5			;no ->

		cmp	ArmMode,ARM_SKYFLASH		;armed?
		jne	@F				;no ->

		test	ArmBlink,1			;blink on?
		jz	SkipAirWpn5			;no ->

@@:		cmp	AirArmMode,ARM_SKYFLASH		;current air-to-air weapon?

		mov	si,OFFSET WpnSetUp1$		;assume not (normal)

		jne	@F

		mov	si,OFFSET WpnSetUp2$		;(hi-lite)

@@:		call	Print$

		mov	si,OFFSET SkyFlash$
		call	Print$

;------------------------
;* display chaff / flares
;------------------------

SkipAirWpn5:	
		cmp	TAB1.TAB_MODE,TAB_FLIR_ORI	;map selected?		
		je @F
		cmp	TAB2.TAB_MODE,TAB_FLIR_ORI	;map selected?		
		je @F		
		mov	PrtLn,180
		mov	PrtCl,144
        jmp SkipCFLines
@@:		
		add	PrtLn,9
		mov	PrtCl,10
SkipCFLines:		
        
		cmp	ChaffCntr,0  	;any chaff?
		je	@F		;no ->

		mov	si,OFFSET Chaff$
		call	Print$
		
		add	PrtLn,6
@@:		
		cmp	TAB1.TAB_MODE,TAB_FLIR_ORI	;map selected?		
		je @F
		cmp	TAB2.TAB_MODE,TAB_FLIR_ORI	;map selected?		
		je @F
        mov	PrtCl,144
		jmp Skippp
@@:     
        add	PrtLn,1
        mov	PrtCl,10		
Skippp:
		cmp	FlareCntr,0	;any flares?
		je	@F		;no ->

		mov	si,OFFSET Flare$
		call	Print$

@@:		ret

UpdateStores	ENDP



;----------------------------------------------------------------------------

;* SelectActDisp - select active display (display which has mouse input)
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

SelectActDisp	PROC	NEAR
		KTEST KF_Full_MFD
		_JZ PreCheckNext
		jmp ActionStations
PreCheckNext:
        mov ShiftDwasPressed,0
		jmp CheckNext
ActionStations:		
		KCLEAR KF_Full_MFD
		mov ShiftDwasPressed,1	
		
		cmp NAVIG_MFD.MFD_MODE,MFD_MAP
		jne @F
		mov MFD_Counter,MFD_MAP
		jmp comeouttohereMan
@@:
		cmp NAVIG_MFD.MFD_MODE,MFD_RADAR
		jne @F
		mov MFD_Counter,MFD_RADAR
		jmp comeouttohereMan
@@:
		cmp NAVIG_MFD.MFD_MODE,MFD_AUTO_PILOT
		jne @F
		mov MFD_Counter,MFD_AUTO_PILOT
		jmp comeouttohereMan
@@:
		cmp NAVIG_MFD.MFD_MODE,MFD_ILS
		jne @F
		mov MFD_Counter,MFD_ILS
		jmp comeouttohereMan
@@:
		cmp NAVIG_MFD.MFD_MODE,MFD_FLIR_ORI
		jne @F	
@@:		
        mov MFD_Counter,MFD_FLIR_ORI

comeouttohereMan:
		
		add CounterThird,1
		cmp CounterThird,3
		jge BackToNavigPanel
        xor	ToggleFullScreen,1	;alternate between full screen FLIR and TIALD
		jz tab2tialdori
		
		mov	di,OFFSET TAB1	;other TAB display		
        mov	si,OFFSET TAB2	;this TAB display

;----------------------------------
;* test for TAB1 switched on or not
;----------------------------------		
		
		test TAB1.TAB_STATUS,1
		jz	@F   ;no ->

;----------------------
;* test for damaged TAB1
;----------------------

		mov	bx,TAB1.TAB_SSF_PTR
		test	BYTE PTR [bx],1		;display damaged?
		jnz	@F		;yes ->
		mov TAB1.TAB_MODE,TAB_FLIR_ORI
		jmp CheckNext
@@:

;----------------------------------
;* test for TAB2 switched on or not
;----------------------------------		

		test	TAB2.TAB_STATUS,1 ;TAB2 on?
		jz	@F   ;no ->		

;-----------------------
;* test for damaged TAB2
;-----------------------

		mov	bx,TAB2.TAB_SSF_PTR
		test	BYTE PTR [bx],1		;display damaged?
		_JNZ @F   ;yes ->
		mov TAB2.TAB_MODE,TAB_FLIR_ORI
		jmp CheckNext
@@:
		
BackToNavigPanel:
        mov CounterThird,0
		
;----------------------------------
;* test for TAB1 switched on or not
;----------------------------------		
		
		test TAB1.TAB_STATUS,1
		jz	@F   ;no ->

;----------------------
;* test for damaged TAB1
;----------------------

		mov	bx,TAB1.TAB_SSF_PTR
		test	BYTE PTR [bx],1		;display damaged?
		jnz	@F		;yes ->
        cmp TAB2.TAB_MODE,TAB_TIALD  ;Is TV-Tab2 already showing the small TV-Tab-sized TIALD view?
		je @F       ;yes -> Do NOT view full-screen TIALD view in TAB1! We can't have 2 simulataneous TV-TAB views!						
		mov TAB1.TAB_MODE,TAB_TIALD ;Force the entire Navigators Panel (Cockpit) to be shown in entirety.
		jmp cmpMFD_Counter10
@@:		
		
;----------------------------------
;* test for TAB2 switched on or not
;----------------------------------		
		
		test TAB2.TAB_STATUS,1
		jz	@F   ;no ->

;-----------------------
;* test for damaged TAB2
;-----------------------

		mov	bx,TAB2.TAB_SSF_PTR
		test	BYTE PTR [bx],1		;display damaged?
		jnz	@F		;yes ->
        cmp TAB1.TAB_MODE,TAB_TIALD  ;Is TV-Tab1 already showing the small TV-Tab-sized TIALD view?
		je @F   ;yes -> Do NOT view full-screen TIALD view in TAB2! We can't have 2 simulataneous TV-TAB views!				
		mov TAB2.TAB_MODE,TAB_TIALD ;Force the entire Navigators Panel (Cockpit) to be shown in entirety.
		
@@:		
cmpMFD_Counter10:		
		cmp MFD_Counter,10
		jge ResetToZero
		cmp MFD_Counter, 2
		je @F
		jmp BypassResetToZero
@@:
        cmp RadarMode,NUL_RADAR
		je @F
		jmp BypassResetToZero
@@:     

		jmp Rubix
ResetToZero:
		mov MFD_Counter, 0
BypassResetToZero:		
        
Rubix:	
		mov ax, MFD_Counter
		mov NAVIG_MFD.MFD_MODE,ax
		jmp CheckNext
tab2tialdori:		

		
;----------------------------------
;* test for TAB1 switched on or not
;----------------------------------	
	
		test TAB1.TAB_STATUS,1
		jz	@F   ;no ->

;-----------------------
;* test for damaged TAB1
;-----------------------

		mov	bx,TAB1.TAB_SSF_PTR
		test	BYTE PTR [bx],1		;display damaged?
		jnz	@F		;yes ->

        cmp TAB2.TAB_MODE,TAB_TIALD_ORI  ;Is TV-Tab2 already showing the small TV-Tab-sized TIALD view?
		je @F       ;yes -> Do NOT view full-screen TIALD view in TAB1! We can't have 2 simulataneous TV-TAB views!		
		mov TAB1.TAB_MODE,TAB_TIALD_ORI
		jmp CheckNext
@@:

;----------------------------------
;* test for TAB2 switched on or not
;----------------------------------		
		
		test TAB2.TAB_STATUS,1
		jz	@F   ;no ->

;-----------------------
;* test for damaged TAB2
;-----------------------

		mov	bx,TAB2.TAB_SSF_PTR
		test	BYTE PTR [bx],1		;display damaged?
		jnz	@F		;yes ->

        cmp TAB1.TAB_MODE,TAB_TIALD_ORI  ;Is TV-Tab1 already showing the small TV-Tab-sized TIALD view?
		je @F       ;yes -> Do NOT view full-screen TIALD view in TAB2! We can't have 2 simulataneous TV-TAB views!
		mov TAB2.TAB_MODE,TAB_TIALD_ORI
		jmp CheckNext
@@:		
		
CheckNext:		
		KTEST	KF_DispSelect	;select active display?
		_JZ	ExitActDisp	;no ->		
;---------------------------------------
;* which display is currently has mouse?
;---------------------------------------

		test	TAB1.TAB_HAS_MOUSE,1	;does TAB1 have mouse?
		jnz	SortTAB1		;yes ->

		test	TAB2.TAB_HAS_MOUSE,1	;does TAB2 have mouse?
		_JNZ	SortTAB2		;yes ->

;---------------------------------------
;* MFD has mouse, pass to TAB2 then TAB1
;---------------------------------------

;* does TAB2 want mouse?

		mov	al,TAB2.TAB_STATUS
		and	al,TAB2.TAB_REQ_MOUSE	;required and on?

		mov	bx,TAB2.TAB_SSF_PTR
		mov	ah,[bx]
		not	ah	    	;0ffh = ok, 0feh = damaged

		and	al,ah		;required and on and not damaged?

		jz	@F		;no ->

		mov	NAVIG_MFD.MFD_HAS_MOUSE,0
		mov	TAB2.TAB_HAS_MOUSE,1

		jmp	ExitActDisp

;* does TAB1 want mouse?

@@:		mov	al,TAB1.TAB_STATUS
		and	al,TAB1.TAB_REQ_MOUSE	;required and on?

		mov	bx,TAB1.TAB_SSF_PTR
		mov	ah,[bx]
		not	ah	    	;0ffh = ok, 0feh = damaged

		and	al,ah		;required and on and not damaged?

		_JZ	ExitActDisp	;no ->

		mov	NAVIG_MFD.MFD_HAS_MOUSE,0
		mov	TAB1.TAB_HAS_MOUSE,1

		jmp	ExitActDisp

;---------------------------------------
;* TAB1 has mouse, pass to MFD then TAB2
;---------------------------------------

;* does MFD want mouse?

SortTAB1:	
        mov	al,NAVIG_MFD.MFD_STATUS
		and	al,NAVIG_MFD.MFD_REQ_MOUSE	;required and on?

		mov	bx,NAVIG_MFD.MFD_SSF_PTR
		mov	ah,[bx]
		not	ah	    	;0ffh = ok, 0feh = damaged

		and	al,ah		;required and on and not damaged?

		jz	@F		;no ->

		mov	TAB1.TAB_HAS_MOUSE,0
		mov	NAVIG_MFD.MFD_HAS_MOUSE,1

		jmp	ExitActDisp

;* does TAB2 want mouse?

@@:		mov	al,TAB2.TAB_STATUS
		and	al,TAB2.TAB_REQ_MOUSE	;required and on?

		mov	bx,TAB2.TAB_SSF_PTR
		mov	ah,[bx]
		not	ah	    	;0ffh = ok, 0feh = damaged

		and	al,ah		;required and on and not damaged?

		jz	ExitActDisp	;no ->

		mov	TAB1.TAB_HAS_MOUSE,0
		mov	TAB2.TAB_HAS_MOUSE,1

		jmp	ExitActDisp

;---------------------------------------
;* TAB2 has mouse, pass to TAB1 then MFD
;---------------------------------------

;* does TAB1 want mouse?

SortTAB2:	mov	al,TAB1.TAB_STATUS
		and	al,TAB1.TAB_REQ_MOUSE	;required and on?

		mov	bx,TAB1.TAB_SSF_PTR
		mov	ah,[bx]
		not	ah	    	;0ffh = ok, 0feh = damaged

		and	al,ah		;required and on and not damaged?

		jz	@F		;no ->

		mov	TAB2.TAB_HAS_MOUSE,0
		mov	TAB1.TAB_HAS_MOUSE,1

		jmp	ExitActDisp

;* does MFD want mouse?

@@:		mov	al,NAVIG_MFD.MFD_STATUS
		and	al,NAVIG_MFD.MFD_REQ_MOUSE	;required and on?

		mov	bx,NAVIG_MFD.MFD_SSF_PTR
		mov	ah,[bx]
		not	ah	    	;0ffh = ok, 0feh = damaged

		and	al,ah		;required and on and not damaged?

		jz	ExitActDisp	;no ->

		mov	TAB2.TAB_HAS_MOUSE,0
		mov	NAVIG_MFD.MFD_HAS_MOUSE,1

ExitActDisp:	

        ret

SelectActDisp	ENDP


UpdateADI2	PROC	NEAR

;--------------
;* draw horizon
;--------------

;* set visual view mode for artificial horizon

		mov	ax,TV5_VIEWMODE
		mov	cx,0 ;72 hack Frankie
		mov	bl,174;141 hack Frankie
		call	SetViewMode

		mov	si,OFFSET M_VIEW

		mov	cx,M_SinR
		mov	dx,M_CosR

		mov	al,COL_ADI_GND
		mov	ah,COL_ADI_SKY

		call	UserHorizon

;* restore view mode
		test	QuieterCockpit,1	;in cockpit?
		jz GoOverHereMann3	

		mov	ax,INT_VIEWMODE
		call	SetViewMode

		ret
GoOverHereMann3:
        mov	ax,EXT_VIEWMODE
		call	SetViewMode

		ret

UpdateADI2	ENDP


;----------------------------------------------------------------------------
;* UpdateStores - update stores display screen
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all
;* This procedure is to display the store management display data at the bottom-centre of the screen.
;
UpdateStores2	PROC	NEAR

;---------------
;* clear display
;---------------

		mov	cx,SDISP_X_ORG
		mov	bl,SDISP_Y_ORG
		mov	dx,SDISP_X_ORG+SDISP_WIDTH-1
		mov	bh,SDISP_Y_ORG+SDISP_DEPTH-1

		mov	al,COL_CRT1
		call	BlockFill

;--------------------
;* update blink timer
;--------------------

		mov	ax,ArmBlinkTimer
		sub	ax,LastFrame
		jnc	@F

		xor	ArmBlink,1	;toggle blink state

		mov	ax,ARM_BLINK_TIME

@@:		mov	ArmBlinkTimer,ax

;-------------------------
;* sort layout wrt variant
;-------------------------

		mov	bx,TornadoType

		jmp	LayoutSwitch2[bx]

;---------------------------
IDSLayout2	LABEL	NEAR
ECRLayout2	LABEL	NEAR
;---------------------------

;----------------------
;* draw seperator lines
;----------------------

		mov	cx,128
		mov	dx,191
		mov	bl,167
		mov	al,COL_CRT3
		;mov	al,COL_HUD
		call	HLineDraw

		mov	cx,128
		mov	dx,191
		mov	bl,181
		mov	al,COL_CRT3
		;mov	al,COL_HUD
		call	HLineDraw

;------------------
;* display packages
;------------------

		mov	PrtLn,149

		mov	cx,NUM_PACKAGES

		mov	si,OFFSET Packages

PackageLoop2:  	cmp	[si].PACK_WEAP_TYPE,NULL_WEAPON	;null package?
		_JE	SkipPackage2	    		;yes ->

	      	push	cx
		push	si

;* blink if current package and armed

		cmp	si,PackagePtr	;current package?
		jne	SkipPackBlink2	;no ->

		mov	ax,[si].PACK_WEAP_MODE

		cmp	ax,ArmMode	;armed?
		jne	SkipPackBlink2	;no ->

		test	ArmBlink,1   	;blink on?
		_JZ	NextPackage2  	;no ->

;* hi-lite text if current package

SkipPackBlink2:	mov	PrtCl,128

		push	si

		cmp	si,PackagePtr		;current package?

		mov	si,OFFSET WpnSetUp1$	;assume not

		jne	@F			;no ->
		
		mov	si,OFFSET WpnSetUp2$

@@:		call	Print$

		pop	si

;* print target waypoint identifier

		mov	al,[si].PACK_WP_ID
		call	PrintChar

		add	PrtCl,4

;* print weapon type

		push	si

		mov	si,[si].PACK_WEAP_TYPE

		REPT	2		;*4 (string length 8 bytes)
		shl	si,1
		ENDM

		add	si,OFFSET Weapon$

		call	Print$

		mov	al,'x'
		call	PrintChar

		pop	si

;* print number of weapons in package

		mov	DecAttr,00010010b	;(unsigned, 2 digits, left justified)

		mov	ax,[si].PACK_WEAP_NUM
		call	PrintDecWord

		mov	DecAttr,00000000b	;(default)

;* print delivery mode (if applicable)

		mov	ax,[si].PACK_WEAP_MODE

		mov	si,OFFSET ManBomb$
		cmp	ax,ARM_MANUAL
		je	@F

		mov	si,OFFSET LayBomb$
		cmp	ax,ARM_LAYDOWN
		je	@F

		mov	si,OFFSET LftBomb$
		cmp	ax,ARM_LOFT
		je	@F

		mov	si,OFFSET LGBBomb$
		cmp	ax,ARM_LGB
		je	@F

		mov	si,OFFSET DirAlarm$
		cmp	ax,ARM_ALARM_DIR
		je	@F

		mov	si,OFFSET IndAlarm$
		cmp	ax,ARM_ALARM_IND
		je	@F

		jmp	NextPackage2

@@:		mov	PrtCl,180

		call	Print$

NextPackage2:  	pop	si
		pop	cx
		
		add	PrtLn,6

SkipPackage2:	add	si,PACK_REC_SIZE

		_LOOP	PackageLoop2

;----------------------------
;* display air-to-air weapons
;----------------------------

;* cannons

		mov	PrtLn,169
		mov	PrtCl,140

		cmp	Cannons,0		;any cannons?
		je	SkipAirWpn1b		;no ->

;* do not blink when counting down

		test	CannonFired,1		;counting down?
		jnz	@F			;yes ->

		cmp	ArmMode,ARM_CANNON	;armed?
		jne	@F			;no ->

		test	ArmBlink,1		;blink on?
		jz	NextAirWpn1b		;no ->

@@:		cmp	AirArmMode,ARM_CANNON	;current air-to-air weapon?

		mov	si,OFFSET WpnSetUp1$	;assume not (normal)

		jne	@F			;no ->

		mov	si,OFFSET WpnSetUp2$	;(hi-lite)

@@:		call	Print$

		mov	si,OFFSET Cannon$
		call	Print$

;* Sidewinders

NextAirWpn1b:	add	PrtLn,6
SkipAirWpn1b:	mov	PrtCl,144

		cmp	ExtStores[EXT_SIDEWINDER],0	;any Sidewinders?
		je	SkipAirWpn2b			;no ->

		cmp	ArmMode,ARM_SIDEWINDER		;armed?
		jne	@F				;no ->

		test	ArmBlink,1			;blink on?
		jz	SkipAirWpn2b			;no ->

@@:		cmp	AirArmMode,ARM_SIDEWINDER	;current air-to-air weapon?

		mov	si,OFFSET WpnSetUp1$		;assume not (normal)

		jne	@F

		mov	si,OFFSET WpnSetUp2$		;(hi-lite)

@@:		call	Print$

		mov	si,OFFSET Sidewinder$
		call	Print$

;------------------------
;* display chaff / flares
;------------------------

SkipAirWpn2b:	mov	PrtLn,183
		mov	PrtCl,144 ;144

		cmp	ChaffCntr,0	;any chaff?
		je	@F		;no ->

		mov	si,OFFSET Chaff$
		call	Print$

		add	PrtLn,6
@@:		mov	PrtCl,144

		cmp	FlareCntr,0	;any flares?
		je	@F		;no ->

		mov	si,OFFSET Flare$
		call	Print$

@@:		ret

;---------------------------
ADVLayout2	LABEL	NEAR
;---------------------------

;---------------------
;* draw seperator line
;---------------------

		;mov	cx,128
		;mov	dx,191
		;mov	bl,175
		;mov	al,COL_CRT3
		;mov	al,COL_HUD
		;call	HLineDraw

;----------------------------
;* display air-to-air weapons
;----------------------------

;* cannons

		mov	PrtLn,152
		mov	PrtCl,140

		cmp	Cannons,0		;any cannons?
		je	SkipAirWpn3b		;no ->

;* do not blink when counting down

		test	CannonFired,1		;counting down?
		jnz	@F			;yes ->

		cmp	ArmMode,ARM_CANNON	;armed?
		jne	@F			;no ->

		test	ArmBlink,1		;blink on?
		jz	NextAirWpn3b		;no ->

@@:		cmp	AirArmMode,ARM_CANNON	;current air-to-air weapon?

		mov	si,OFFSET WpnSetUp1$	;assume not (normal)

		jne	@F			;no ->

		mov	si,OFFSET WpnSetUp2$	;(hi-lite)

@@:		call	Print$

		mov	si,OFFSET Cannon$
		call	Print$

;* Sidewinders

NextAirWpn3b:	add	PrtLn,7
SkipAirWpn3b:	mov	PrtCl,144

		cmp	ExtStores[EXT_SIDEWINDER],0	;any Sidewinders?
		je	SkipAirWpn4b			;no ->

		cmp	ArmMode,ARM_SIDEWINDER		;armed?
		jne	@F				;no ->

		test	ArmBlink,1			;blink on?
		jz	NextAirWpn4b			;no ->

@@:		cmp	AirArmMode,ARM_SIDEWINDER	;current air-to-air weapon?

		mov	si,OFFSET WpnSetUp1$		;assume not (normal)

		jne	@F

		mov	si,OFFSET WpnSetUp2$		;(hi-lite)

@@:		call	Print$

		mov	si,OFFSET Sidewinder$
		call	Print$

;* Sky Flash

NextAirWpn4b:	add	PrtLn,7
SkipAirWpn4b:	mov	PrtCl,140

		cmp	ExtStores[EXT_SKYFLASH],0	;any Sky Flash?
		je	SkipAirWpn5b			;no ->

		cmp	ArmMode,ARM_SKYFLASH		;armed?
		jne	@F				;no ->

		test	ArmBlink,1			;blink on?
		jz	SkipAirWpn5b			;no ->

@@:		cmp	AirArmMode,ARM_SKYFLASH		;current air-to-air weapon?

		mov	si,OFFSET WpnSetUp1$		;assume not (normal)

		jne	@F

		mov	si,OFFSET WpnSetUp2$		;(hi-lite)

@@:		call	Print$

		mov	si,OFFSET SkyFlash$
		call	Print$

;------------------------
;* display chaff / flares
;------------------------

SkipAirWpn5b:	add	PrtLn,7
		mov	PrtCl,12

		cmp	ChaffCntr,0  	;any chaff?
		je	@F		;no ->

		mov	si,OFFSET Chaff$
		call	Print$

		add	PrtLn,6
@@:		mov	PrtCl,12

		cmp	FlareCntr,0	;any flares?
		je	@F		;no ->

		mov	si,OFFSET Flare$
		call	Print$

@@:		ret

UpdateStores2	ENDP


;----------------------------------------------------------------------------
;* UpdateStores - update stores display screen
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all
;* This procedure is to display the store management display data at the top-left of the screen.
;
UpdateStores3	PROC	NEAR
;---------------
;* clear display
;---------------
		mov	cx,SDISP_X_ORG
		mov	bl,SDISP_Y_ORG
		mov	dx,SDISP_X_ORG+SDISP_WIDTH-1
		mov	bh,SDISP_Y_ORG+SDISP_DEPTH-1

		;mov	al,COL_CRT1
		;call	BlockFill

;--------------------
;* update blink timer
;--------------------

		mov	ax,ArmBlinkTimer
		sub	ax,LastFrame
		jnc	@F

		xor	ArmBlink,1	;toggle blink state

		mov	ax,ARM_BLINK_TIME

@@:		mov	ArmBlinkTimer,ax

;-------------------------
;* sort layout wrt variant
;-------------------------

		mov	bx,TornadoType

		jmp	LayoutSwitch3[bx]

;---------------------------
IDSLayout3	LABEL	NEAR
ECRLayout3	LABEL	NEAR
;---------------------------

;------------------
;* display packages
;------------------

		mov	PrtLn,50;

		mov	cx,NUM_PACKAGES

		mov	si,OFFSET Packages

PackageLoop3:  	cmp	[si].PACK_WEAP_TYPE,NULL_WEAPON	;null package?
		_JE	SkipPackage3	    		;yes ->
		
	    push	cx
		push	si

;* blink if current package and armed

		cmp	si,PackagePtr	;current package?
		jne	SkipPackBlink3	;no ->

		mov	ax,[si].PACK_WEAP_MODE

		cmp	ax,ArmMode	;armed?
		jne	SkipPackBlink3	;no ->

		test	ArmBlink,1   	;blink on?
		_JZ	NextPackage3 	;no ->

;* hi-lite text if current package

SkipPackBlink3:	mov	PrtCl,1

		push	si

		cmp	si,PackagePtr		;current package?

		mov	si,OFFSET WpnSetUp1$	;assume not

		jne	@F			;no ->
		
		mov	si,OFFSET WpnSetUp2$

@@:		call	Print$

		pop	si

;* print target waypoint identifier

		mov	al,[si].PACK_WP_ID
		;call	PrintChar

		add	PrtCl,4

;* print weapon type

		push	si

		mov	si,[si].PACK_WEAP_TYPE

		REPT	2		;*4 (string length 8 bytes)
		shl	si,1
		ENDM

		add	si,OFFSET Weapon$

		call	Print$

		mov	al,'x'
		call	PrintChar

		pop	si

;* print number of weapons in package

		mov	DecAttr,00010010b	;(unsigned, 2 digits, left justified)

		mov	ax,[si].PACK_WEAP_NUM
		call	PrintDecWord

		mov	DecAttr,00000000b	;(default)

;* print delivery mode (if applicable)

		mov	ax,[si].PACK_WEAP_MODE

		mov	si,OFFSET ManBomb$
		cmp	ax,ARM_MANUAL
		je	@F

		mov	si,OFFSET LayBomb$
		cmp	ax,ARM_LAYDOWN
		je	@F

		mov	si,OFFSET LftBomb$
		cmp	ax,ARM_LOFT
		je	@F

		mov	si,OFFSET LGBBomb$
		cmp	ax,ARM_LGB
		je	@F

		mov	si,OFFSET DirAlarm$
		cmp	ax,ARM_ALARM_DIR
		je	@F

		mov	si,OFFSET IndAlarm$
		cmp	ax,ARM_ALARM_IND
		je	@F

		jmp	NextPackage2

@@:		mov	PrtCl,51

		call	Print$

NextPackage3:  	pop	si
		pop	cx
		
		add	PrtLn,6

SkipPackage3:	add	si,PACK_REC_SIZE

		_LOOP	PackageLoop3

;----------------------------
;* display air-to-air weapons
;----------------------------

;* cannons

		mov	PrtLn,70
		mov	PrtCl,10

		cmp	Cannons,0		;any cannons?
		je	SkipAirWpn1c		;no ->

;* do not blink when counting down

		test	CannonFired,1		;counting down?
		jnz	@F			;yes ->

		cmp	ArmMode,ARM_CANNON	;armed?
		jne	@F			;no ->

		test	ArmBlink,1		;blink on?
		jz	NextAirWpn1c		;no ->

@@:		cmp	AirArmMode,ARM_CANNON	;current air-to-air weapon?

		mov	si,OFFSET WpnSetUp1$	;assume not (normal)

		jne	@F			;no ->

		mov	si,OFFSET WpnSetUp2$	;(hi-lite)

@@:		call	Print$

		mov	si,OFFSET Cannon$
		call	Print$

;* Sidewinders

NextAirWpn1c:	add	PrtLn,6
SkipAirWpn1c:	mov	PrtCl,12 ;144

		cmp	ExtStores[EXT_SIDEWINDER],0	;any Sidewinders?
		je	SkipAirWpn2c			;no ->

		cmp	ArmMode,ARM_SIDEWINDER		;armed?
		jne	@F				;no ->

		test	ArmBlink,1			;blink on?
		jz	SkipAirWpn2c			;no ->

@@:		cmp	AirArmMode,ARM_SIDEWINDER	;current air-to-air weapon?

		mov	si,OFFSET WpnSetUp1$		;assume not (normal)

		jne	@F

		mov	si,OFFSET WpnSetUp2$		;(hi-lite)

@@:		call	Print$

		mov	si,OFFSET Sidewinder$
		call	Print$

;------------------------
;* display chaff / flares
;------------------------

SkipAirWpn2c:	add	PrtLn,7
		mov	PrtCl,12 ;144

		cmp	ChaffCntr,0	;any chaff?
		je	@F		;no ->

		mov	si,OFFSET Chaff$
		call	Print$

		add	PrtLn,6
@@:		mov	PrtCl,12

		cmp	FlareCntr,0	;any flares?
		je	@F		;no ->

		mov	si,OFFSET Flare$
		call	Print$

@@:		ret

;---------------------------
ADVLayout3	LABEL	NEAR
;---------------------------

;---------------------
;* draw seperator line
;---------------------

		;mov	cx,128
		;mov	dx,191
		;mov	bl,175
		;mov	al,COL_CRT3
		;call	HLineDraw

;----------------------------
;* display air-to-air weapons
;----------------------------

;* cannons

		mov	PrtLn,52+2
		mov	PrtCl,10
		cmp	Cannons,0		;any cannons?
		je	SkipAirWpn3c		;no ->

;* do not blink when counting down

		test	CannonFired,1		;counting down?
		jnz	@F			;yes ->

		cmp	ArmMode,ARM_CANNON	;armed?
		jne	@F			;no ->

		test	ArmBlink,1		;blink on?
		jz	NextAirWpn3c		;no ->

@@:		cmp	AirArmMode,ARM_CANNON	;current air-to-air weapon?

		mov	si,OFFSET WpnSetUp1$	;assume not (normal)

		jne	@F			;no ->

		mov	si,OFFSET WpnSetUp2$	;(hi-lite)

@@:		call	Print$

		mov	si,OFFSET Cannon$
		call	Print$

;* Sidewinders

NextAirWpn3c:	add	PrtLn,7
SkipAirWpn3c:	mov	PrtCl,10

		cmp	ExtStores[EXT_SIDEWINDER],0	;any Sidewinders?
		je	SkipAirWpn4c			;no ->

		cmp	ArmMode,ARM_SIDEWINDER		;armed?
		jne	@F				;no ->

		test	ArmBlink,1			;blink on?
		jz	NextAirWpn4c			;no ->

@@:		cmp	AirArmMode,ARM_SIDEWINDER	;current air-to-air weapon?

		mov	si,OFFSET WpnSetUp1$		;assume not (normal)

		jne	@F

		mov	si,OFFSET WpnSetUp2$		;(hi-lite)

@@:		call	Print$

		mov	si,OFFSET Sidewinder$
		call	Print$

;* Sky Flash

NextAirWpn4c:	add	PrtLn,7
SkipAirWpn4c:	mov	PrtCl,10

		cmp	ExtStores[EXT_SKYFLASH],0	;any Sky Flash?
		je	SkipAirWpn5c			;no ->

		cmp	ArmMode,ARM_SKYFLASH		;armed?
		jne	@F				;no ->

		test	ArmBlink,1			;blink on?
		jz	SkipAirWpn5c			;no ->

@@:		cmp	AirArmMode,ARM_SKYFLASH		;current air-to-air weapon?

		mov	si,OFFSET WpnSetUp1$		;assume not (normal)

		jne	@F

		mov	si,OFFSET WpnSetUp2$		;(hi-lite)

@@:		call	Print$

		mov	si,OFFSET SkyFlash$
		call	Print$

;------------------------
;* display chaff / flares
;------------------------

SkipAirWpn5c:	add	PrtLn,9
		mov	PrtCl,10

		cmp	ChaffCntr,0  	;any chaff?
		je	@F		;no ->

		mov	si,OFFSET Chaff$
		call	Print$

		add	PrtLn,7
@@:		mov	PrtCl,10

		cmp	FlareCntr,0	;any flares?
		je	@F		;no ->

		mov	si,OFFSET Flare$
		call	Print$

@@:		ret

UpdateStores3	ENDP



PANCODE		ENDS

;============================================================================

		END

