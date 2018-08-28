;****************************************************************************
;*
;* PILOTPAN.ASM
;*
;* Pilot's panel driver.
;*
;* 16.10.1991 - KJB
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	UpdatePilot

		PUBLIC	OxyDollyPos
		PUBLIC	DialXY1
		PUBLIC	DialXY2
		PUBLIC	DialXY3

		EXTRN	ClearPilotPanel:FAR
		EXTRN	DrawPilotPanel:FAR
		EXTRN	SetViewMode:FAR
		EXTRN	UserHorizon:FAR
		EXTRN	BlockFill:FAR
		EXTRN	SetPixel:FAR
		EXTRN	VLineDraw:FAR
		EXTRN	MSprite:FAR
		EXTRN	QSprite:FAR
		EXTRN	LineDraw:FAR
		EXTRN	Print$:FAR
		EXTRN	PrintChar:FAR

		EXTRN	UpdateHUD:NEAR
		EXTRN	UpdatePilotMFD:NEAR

		EXTRN	M_VIEW:WORD
		EXTRN	Hdg:WORD
		EXTRN	Roll:WORD
		EXTRN	M_SinR:WORD
		EXTRN	M_CosR:WORD
		EXTRN	ZftHi:WORD
		EXTRN	ZftLo:WORD
		EXTRN	Vkts:WORD
		EXTRN	DispMachNum:WORD
		EXTRN	Rpm1:WORD
		EXTRN	Rpm2:WORD
		EXTRN	FuelFlow1:WORD
		EXTRN	FuelFlow2:WORD
		EXTRN	FuelWt:WORD
		EXTRN	Temp1:WORD
		EXTRN	Temp2:WORD
		EXTRN	DispRadAlt:WORD
		EXTRN	DispHdg:WORD
		EXTRN	DispGForce:WORD
		EXTRN	GndHtData:WORD
		EXTRN	DispVSI:WORD
		EXTRN	CrntWingVal:WORD
		EXTRN	CrntFlapVal:WORD
		EXTRN	Sprite:WORD
		EXTRN	SpriteX:WORD
		EXTRN	SpriteY:WORD
		EXTRN	SpritePtr:WORD
		EXTRN	PrtLn:WORD
		EXTRN	PrtCl:WORD
		EXTRN	ILSLocalPos:WORD
		EXTRN	ILSGlidePos:WORD
		EXTRN	ILSRangeLo:WORD
		EXTRN	ILSRangeHi:WORD
		EXTRN	LastFrame:WORD
		EXTRN	ArmMode:WORD
		EXTRN	TornadoType:WORD
		EXTRN	NumRWRThreats:WORD
		EXTRN	RWRThreats:WORD

		EXTRN	CrntFlapPos:BYTE
		EXTRN	AirBrakes:BYTE
		EXTRN	ILSActive:BYTE
		EXTRN	SSF_Oxygen:BYTE
		EXTRN	SSF_RWR:BYTE
		EXTRN	Night:BYTE

;============================================================================

		INCLUDE	MAINDATA.INC

		INCLUDE	\VISUAL\VISDATA.INC
		INCLUDE	\VISUAL\PALETTES.INC

		INCLUDE	\LIB8086\PRINT.INC
		INCLUDE	\LIB8086\USEFUL.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

TempVal		DW	0

;------------------------------------
;* HSI localiser and glide slope vars
;------------------------------------

LOCAL_X		EQU	95		;localiser needle origin
LOCAL_Y		EQU	184

LocalXPos	DW	LOCAL_X		;localiser x pos

GLIDE_X		EQU	78		;glide slope needle origin
GLIDE_Y		EQU	186

GlideYPos	DB	GLIDE_Y		;glide slope y pos

		EVEN

;---------------------------------
;* oxygen dolly indicator position
;---------------------------------

OXY_TIME	EQU	200		;secs * 100

OxyDollyTimer	DW	0		;secs * 100

OxyDollyPos	DB	0		;0 .. 1

		EVEN

;--------------------------
;* RWR threat symbol switch
;--------------------------

;* low priority symbols (green)

RWRLoSymbol	DW	SAMSymbol	;THREAT_SAM
		DW	AAASymbol	;THREAT_AAA
		DW	EWRSymbol	;THREAT_EWR
		DW	ACSymbol 	;THREAT_AC
		DW	-1		;THREAT_RAD_MSL
		DW	-1		;THREAT_IR_MSL

;* high priority symbols (non-green)

RWRHiSymbol	DW	-1		;THREAT_SAM
		DW	-1		;THREAT_AAA
		DW	-1		;THREAT_EWR
		DW	-1		;THREAT_AC
		DW	MSLSymbol1	;THREAT_RAD_MSL
		DW	MSLSymbol2	;THREAT_IR_MSL

;-----------------------------
;* meter dial co-ords (size 1)
;-----------------------------

DialXY1		LABEL	BYTE

		DB	  0,   9	;0
		DB	 -1,   9	;1
		DB	 -2,   9	;2
		DB	 -3,   9	;3
		DB	 -4,   8	;4
		DB	 -5,   8	;5
		DB	 -6,   8	;6
		DB	 -7,   7	;7
		DB	 -8,   6	;8
		DB	 -9,   5	;9
		DB	-10,   4	;10
		DB	-10,   3	;11
		DB	-11,   2	;12
		DB	-11,   1	;13
		DB	-11,   0	;14
		DB	-11,  -1	;15
		DB	-11,  -2	;16
		DB	-10,  -3	;17
		DB	-10,  -4	;18
		DB 	 -9,  -5	;19
		DB	 -8,  -6	;20
		DB	 -7,  -7	;21
		DB	 -6,  -8	;22
		DB	 -5,  -8	;23
		DB	 -4,  -8	;24
		DB	 -3,  -9	;25
		DB	 -2,  -9	;26
		DB	 -1,  -9	;27
		DB	  0,  -9	;28
		DB	  1,  -9	;29
		DB	  2,  -9	;30
		DB	  3,  -9	;31
		DB	  4,  -8	;32
		DB	  5,  -8	;33
		DB	  6,  -8	;34
		DB	  7,  -7	;35
		DB	  8,  -6	;36
		DB	  9,  -5	;37
		DB	 10,  -4	;38
		DB	 10,  -3	;39
		DB	 11,  -2	;40
		DB	 11,  -1	;41
		DB	 11,   0	;42
		DB	 11,   1	;43
		DB	 11,   2	;44
		DB	 10,   3	;45
		DB	 10,   4	;46
		DB	  9,   5	;47
		DB	  8,   6	;48
		DB	  7,   7	;49
		DB	  6,   8	;50
		DB	  5,   8	;51
		DB	  4,   8	;52
		DB	  3,   9	;53
		DB	  2,   9	;54
		DB	  1,   9	;55
		DB	  0,   9	;56 <<<<< first co-ord repeated <<<<<

;-----------------------------
;* meter dial co-ords (size 2)
;-----------------------------

DialXY2		LABEL	BYTE

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

;-----------------------------
;* meter dial co-ords (size 3)
;-----------------------------

DialXY3		LABEL	BYTE

		DB	  0, -12	;0
		DB	  1, -12	;1
		DB	  2, -12	;2
		DB	  3, -12	;3
		DB	  4, -12	;4
		DB	  5, -11	;5
		DB	  6, -11	;6
		DB	  7, -11	;7
		DB	  8, -10	;8
		DB	  9, -10	;9
		DB	 10,  -9	;10
		DB	 11,  -8	;11
		DB	 12,  -7	;12
		DB	 13,  -6	;13
		DB	 14,  -5	;14
		DB	 14,  -4	;15
		DB	 15,  -3	;16
		DB	 15,  -2	;17
		DB	 15,  -1	;18
		DB	 15,   0	;19
		DB	 15,   1	;20
		DB	 15,   2	;21
		DB	 15,   3	;22
		DB	 14,   4	;23
		DB	 14,   5	;24
		DB	 13,   6	;25
		DB	 12,   7	;26
		DB	 11,   8	;27
		DB	 10,   9	;28
		DB	  9,  10	;29
		DB	  8,  10	;30
		DB	  7,  11	;31
		DB	  6,  11	;32
		DB	  5,  11	;33
		DB	  4,  12	;34
		DB	  3,  12	;35 
		DB	  2,  12	;36
		DB	  1,  12	;37
		DB	  0,  12	;38
		DB	 -1,  12	;39
		DB	 -2,  12	;40
		DB	 -3,  12	;41 
		DB	 -4,  12	;42
		DB	 -5,  11	;43
		DB	 -6,  11	;44
		DB	 -7,  11	;45
		DB	 -8,  10	;46
		DB	 -9,  10	;47
		DB	-10,   9	;48
		DB	-11,   8	;49
		DB	-12,   7	;50
		DB	-13,   6	;51
		DB	-14,   5	;52
		DB	-14,   4	;53
		DB	-15,   3	;54
		DB	-15,   2	;55
		DB	-15,   1	;56
		DB	-15,   0	;57
		DB	-15,  -1	;58
		DB	-15,  -2	;59
		DB	-15,  -3	;60
		DB	-14,  -4	;61
		DB	-14,  -5	;62
		DB	-13,  -6	;63
		DB	-12,  -7	;64
		DB	-11,  -8	;65
		DB	-10,  -9	;66
		DB	 -9, -10	;67
		DB	 -8, -10	;68
		DB	 -7, -11	;69
		DB	 -6, -11	;70
		DB	 -5, -11	;71
		DB	 -4, -12	;72
		DB	 -3, -12	;73
		DB	 -2, -12	;74
		DB	 -1, -12	;75
		DB	  0, -12	;76 <<<<< first co-ord repeated <<<<<

;--------------------------------
;* control surface indicator data
;--------------------------------

FlapsXY		DB	-5,  0		;0 (zero)
		DB	-5,  1		;1
		DB	-5,  2		;2 (mnvr)
		DB	-4,  3		;3 (mid)
		DB	-3,  4		;4
		DB	-2,  5		;5
		DB	-1,  5		;6
		DB	 0,  5		;7 (full)

SlatsXY		DB	 6,  0		;0 (zero)
		DB	 6,  2		;1 (mnvr)
		DB	 6,  2		;2 (mid)
		DB	 5,  3		;3 (full)

WingsXY		DB	-9,  0		;0 (25 degs)
		DB	-9,  1		;1
		DB	-8,  2		;2
		DB	-8,  3		;3
		DB	-7,  4		;4
		DB	-6,  5		;5 (45 degs)
		DB	-5,  6		;6
		DB	-4,  6		;7
		DB	-3,  6		;8
		DB	-2,  7		;9
		DB	-1,  7		;10
		DB	-0,  7		;11 (67 degs)

;-------------
;* string data
;-------------

SetUp$		LABEL	BYTE
		P_OVER1
		P_CHAR2
		PD_ATTR	000h,000h,000h,000h,077h,000h,COL_COUNTER,000h
		P_END

;* print lh and rh engine rpm

Rpm$		LABEL	BYTE
		P_DECAT	00100011b	;(unsigned, 3 digits, leading zeroes)
		PD_XY	216,155
		PV_DECB	Rpm1+1
		PD_X	248
		PV_DECB	Rpm2+1
		P_DECAT	00000000b	;(default)
		P_END

;* print barometric altitude

BarAlt$		LABEL	BYTE
		P_DECAT	00100011b	;(unsigned, 3 digits, leading zeroes)
		PD_XY	44,186
		PV_DECW	TempVal
		P_DECAT	00000000b	;(default)
		P_END

;* print heading on standby compass

Compass$	LABEL	BYTE
		P_DECAT	00100011b	;(unsigned, 3 digits, leading zeroes)
		PD_XY	308,146
		PV_DECW	DispHdg
		P_DECAT	00000000b	;(default)
		P_END

		EVEN

DATA		ENDS

;============================================================================

STACK		SEGMENT PARA PUBLIC 'STACK'
		ASSUME SS:STACK

;-----------------------------------------------------------------------
;* NOTE: Data is stored in the stack segment due to lack of space in the
;*       main DATA segment. Using SS: override does not appear to add
;*       any additional cycles to i286 and i386 timings. i486 has one
;*       extra cycle if the instruction is in cache. Therefore, use SS:
;*       override (don't worry about always using [bp]).
;-----------------------------------------------------------------------

;--------------------------------
;* RWR direction indicator circle
;--------------------------------

;* centre co-ords

RWR_CIRCLE_X 	EQU	236
RWR_CIRCLE_Y 	EQU	121

;* circle co-ords

RWRCircle	LABEL	BYTE

		DB	  0, -10	;0
		DB	  1, -10	;1
		DB	  2, -10	;2
		DB	  3, -10	;3
		DB	  4,  -9	;4
		DB	  5,  -9	;5
		DB	  6,  -9	;6
		DB	  7,  -8	;7
		DB	  8,  -7	;8
		DB	  9,  -7	;9
		DB	 10,  -6	;10
		DB	 10,  -5	;11
		DB	 11,  -4	;12
		DB	 11,  -3	;13
		DB	 12,  -2	;14
		DB	 12,  -1	;15
		DB	 12,   0	;16
		DB	 12,   1	;17
		DB	 12,   2	;18
		DB	 11,   3	;19
		DB	 11,   4	;20
		DB	 10,   5	;21
		DB	 10,   6	;22
		DB	  9,   7	;23
		DB	  8,   7	;24
		DB	  7,   8	;25
		DB	  6,   9	;26
		DB	  5,   9	;27
		DB	  4,   9	;28
		DB	  3,  10	;29
		DB	  2,  10	;30
		DB	  1,  10	;31
		DB	  0,  10	;32
		DB	 -1,  10	;33
		DB	 -2,  10	;34
		DB	 -3,  10	;35
		DB	 -4,   9	;36
		DB	 -5,   9	;37
		DB	 -6,   9	;38
		DB	 -7,   8	;39
		DB	 -8,   7	;40
		DB	 -9,   7	;41
		DB	-10,   6	;42
		DB	-10,   5	;43
		DB	-11,   4	;44
		DB	-11,   3	;45
		DB	-12,   2	;46
		DB	-12,   1	;47
		DB	-12,   0	;48
		DB	-12,  -1	;49
		DB	-12,  -2	;50
		DB	-11,  -3	;51
		DB	-11,  -4	;52
		DB	-10,  -5	;53
		DB	-10,  -6	;54
		DB	 -9,  -7	;55
		DB	 -8,  -7	;56
		DB	 -7,  -8	;57
		DB	 -6,  -9	;58
		DB	 -5,  -9	;59
		DB	 -4,  -9	;60
		DB	 -3, -10	;61
		DB	 -2, -10	;62
		DB	 -1, -10	;63
		DB	  0, -10	;64 <<<<< first co-ord repeated <<<<<

STACK		ENDS

;============================================================================

PANCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:PANCODE
		ASSUME DS:DATA

;* UpdatePilot - update pilot's panel
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

UpdatePilot	PROC	NEAR

		call	UpdateHUD

		call	InitPanel

		call	UpdateEngRPM

		call	UpdateEngTemp

		call	UpdateFuel

		call	UpdateADI

		call	UpdateHSI

		call	UpdateGMeter

		call	UpdateCompass

		call	UpdateCtrlSFace

		call	UpdateAltimeter

		call	UpdateVSI

		call	UpdateSpeed

		call	UpdateRadAlt

		call	UpdateEScope

		call	UpdatePilotMFD

		call	UpdateOxyDolly

		call	DrawPilotPanel

		call	DrawADIRollBug

		call	UpdateRWR

		ret

UpdatePilot	ENDP

;----------------------------------------------------------------------------

;* InitPanel - initialize
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

InitPanel	PROC	NEAR

		call	ClearPilotPanel

		mov	si,OFFSET SetUp$
		call	Print$

		ret

InitPanel	ENDP

;----------------------------------------------------------------------------

;* UpdateEngRPM - update lh and rh engine RPM indicators
;*
;* pass: Rpm1
;*       Rpm2
;* ret : nothing
;* kill: assume all

UpdateEngRPM	PROC	NEAR

;----------------------------
;* print lh and rh engine rpm
;----------------------------

		mov	si,OFFSET Rpm$
		call	Print$

;-------------------
;* lhs rpm indicator
;-------------------

XCENTRE		=	221
YCENTRE		=	152

;* index = Rpm1 * (45 / 32768) + 7

		mov	ax,Rpm1
		mov	dx,45
		imul	dx
		FRACADJ	si
		add	si,7
		shl	si,1		;*2 index

		mov	cx,XCENTRE
		mov	bl,YCENTRE

		mov	dx,cx
		mov	al,DialXY1[si+0]	;x offset
		cbw
		add	dx,ax

		mov	bh,bl
		add	bh,DialXY1[si+1]	;y offset

		mov	al,COL_NEEDLE

		call	LineDraw

;-------------------
;* rhs rpm indicator
;-------------------

XCENTRE		=	253
YCENTRE		=	152

;* index = Rpm2 * (45 / 32768) + 7

		mov	ax,Rpm2
		mov	dx,45
		imul	dx
		FRACADJ	si
		add	si,7
		shl	si,1		;*2 index

		mov	cx,XCENTRE
		mov	bl,YCENTRE

		mov	dx,cx
		mov	al,DialXY1[si+0]	;x offset
		cbw
		add	dx,ax

		mov	bh,bl
		add	bh,DialXY1[si+1]	;y offset

		mov	al,COL_NEEDLE

		call	LineDraw

		ret

UpdateEngRPM	ENDP

;----------------------------------------------------------------------------

;* UpdateEngTemp - update lh and rh engine temperature indicators
;*
;* pass: Temp1
;*       Temp2
;* ret : nothing
;* kill: assume all

UpdateEngTemp	PROC	NEAR

;-------------------------
;* engine 1 temp indicator
;-------------------------

XCENTRE		=	221
YCENTRE		=	180

;* index = Temp1 * (82 / 32768) + 8

		mov	ax,Temp1
		mov	dx,82
		imul	dx
		FRACADJ	si
		add	si,8
		shl	si,1		;*2 index

		mov	cx,XCENTRE
		mov	bl,YCENTRE

		mov	dx,cx
		mov	al,DialXY1[si+0]	;x offset
		cbw
		add	dx,ax

		mov	bh,bl
		add	bh,DialXY1[si+1]	;y offset

		mov	al,COL_NEEDLE

		call	LineDraw

;-------------------------
;* engine 2 temp indicator
;-------------------------

XCENTRE		=	253
YCENTRE		=	180

;* index = Temp2 * (82 / 32768) + 8

		mov	ax,Temp2
		mov	dx,82
		imul	dx
		FRACADJ	si
		add	si,8
		shl	si,1		;*2 index

		mov	cx,XCENTRE
		mov	bl,YCENTRE

		mov	dx,cx
		mov	al,DialXY1[si+0]	;x offset
		cbw
		add	dx,ax

		mov	bh,bl
		add	bh,DialXY1[si+1]	;y offset

		mov	al,COL_NEEDLE

		call	LineDraw

		ret

UpdateEngTemp	ENDP

;----------------------------------------------------------------------------

;* UpdateFuel - update fuel flow and quantity indicators
;*
;* pass: FuelFlow1
;*       FuelFlow2
;*       FuelWt
;* ret : nothing
;* kill: assume all

UpdateFuel	PROC	NEAR

;---------------------
;* fuel flow indicator
;---------------------

XCENTRE		=	285
YCENTRE		=	152

;* index = (FuelFlow1 + FuelFlow2) / 2 * (89 / 32768) + 5

		mov	ax,FuelFlow1
		add	ax,FuelFlow2
		shr	ax,1 		;/2
		mov	dx,89
		imul	dx
		FRACADJ	si
		add	si,5
		shl	si,1		;*2 index

		mov	cx,XCENTRE
		mov	bl,YCENTRE

		mov	dx,cx
		mov	al,DialXY1[si+0]	;x offset
		cbw
		add	dx,ax

		mov	bh,bl
		add	bh,DialXY1[si+1]	;y offset

		mov	al,COL_NEEDLE

		call	LineDraw

;-----------------------
;* fuel weight indicator
;-----------------------

XCENTRE		=	285
YCENTRE		=	180

;* index = FuelWt * (61 / 32768) + 5

		mov	ax,FuelWt
		mov	dx,61
		imul	dx
		FRACADJ	si
		add	si,5
		shl	si,1		;*2 index

		mov	cx,XCENTRE
		mov	bl,YCENTRE

		mov	dx,cx
		mov	al,DialXY1[si+0]	;x offset
		cbw
		add	dx,ax

		mov	bh,bl
		add	bh,DialXY1[si+1]	;y offset

		mov	al,COL_NEEDLE

		call	LineDraw

		ret

UpdateFuel	ENDP

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
		mov	cx,80
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

;------------
;* draw bezel
;------------

;* //MOD// 12.06.1992 - ADI bezel now drawn in DrawPilotPanel.

;---------------
;* draw roll bug
;---------------

;* //MOD// 12.06.1992 - ADI roll bug now drawn in DrawADIRollBug.

		ret

UpdateADI	ENDP

;----------------------------------------------------------------------------

;* DrawADIRollBug - draw attitude direction indicator roll bug
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

DrawADIRollBug	PROC	NEAR

XCENTRE		=	92
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

XCENTRE		=	95
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

;* UpdateGMeter - update accelerometer
;*
;* pass: DispGForce
;* ret : nothing
;* kill: assume all

UpdateGMeter	PROC	NEAR

XCENTRE		=	285
YCENTRE		=	125

;* g = DispGForce - 16
;* if g >= 0 then
;*    index = g / 4 + 14
;* else
;*    index = -g / 4 + 14 (flip y)
;* end

		mov	cx,XCENTRE
		mov	bl,YCENTRE

		mov	si,DispGForce
		sub	si,16
		js	@F		;g < 0 ->

		shr	si,1		;/2
		and	si,0fffeh	;/4 (*2 index)
		add	si,14*2

		mov	dx,cx
		mov	al,DialXY1[si+0]	;x offset
		cbw
		add	dx,ax

		mov	bh,bl
		add	bh,DialXY1[si+1]	;y offset

		jmp	ContGMeter

@@:		neg	si
		shr	si,1		;/2
		and	si,0fffeh	;/4 (*2 index)
		add	si,14*2

		mov	dx,cx
		mov	al,DialXY1[si+0]	;x offset
		cbw
		add	dx,ax

		mov	bh,bl
		mov	al,DialXY1[si+1]	;y offset
		neg	al			;flip y
		add	bh,al

ContGMeter:	mov	al,COL_NEEDLE

		call	LineDraw

		ret

UpdateGMeter	ENDP

;----------------------------------------------------------------------------

;* UpdateCompass - update standby compass
;*
;* pass: DispHdg
;* ret : nothing
;* kill: assume all

UpdateCompass	PROC	NEAR

		mov	si,OFFSET Compass$
		call	Print$

		ret

UpdateCompass	ENDP

;----------------------------------------------------------------------------

;* UpdateCtrlSFace - update secondary control surfaces position indicator
;*
;* pass: CrntFlapVal
;*       CrntFlapPos
;*       CrntWingVal
;* 	 AirBrakes
;* ret : nothing
;* kill: assume all

UpdateCtrlSFace	PROC	NEAR

;--------------------------
;* flaps position indicator
;--------------------------

XCENTRE		=	11
YCENTRE		=	170

;* index = CrntFlapVal * (382 / 32768) = 0 .. 7

		mov	ax,CrntFlapVal
		mov	dx,382
		imul	dx
		FRACADJ	si
		shl	si,1		;*2 index

		mov	cx,XCENTRE
		mov	bl,YCENTRE

		mov	dx,cx
		mov	al,FlapsXY[si+0]	;x offset
		cbw
		add	dx,ax

		mov	bh,bl
		add	bh,FlapsXY[si+1]	;y offset

		mov	al,COL_NEEDLE

		call	LineDraw

;--------------------------
;* slats position indicator
;--------------------------

XCENTRE		=	22
YCENTRE		=	170

;* index = CrntFlapPos = 0 .. 3

		mov	al,CrntFlapPos
		xor	ah,ah
		mov	si,ax
		shl	si,1		;*2 index

		mov	cx,XCENTRE
		mov	bl,YCENTRE

		mov	dx,cx
		mov	al,SlatsXY[si+0]	;x offset
		cbw
		add	dx,ax

		mov	bh,bl
		add	bh,SlatsXY[si+1]	;y offset

		mov	al,COL_NEEDLE

		call	LineDraw

;--------------------------
;* wings position indicator
;--------------------------

XCENTRE		=	26
YCENTRE		=	178

;* index = CrntWingVal * (515 / 32768)

		mov	ax,CrntWingVal
		mov	dx,515
		imul	dx
		FRACADJ	si
		shl	si,1		;*2 index

		mov	cx,XCENTRE
		mov	bl,YCENTRE

		mov	dx,cx
		mov	al,WingsXY[si+0]	;x offset
		cbw
		add	dx,ax

		mov	bh,bl
		add	bh,WingsXY[si+1]	;y offset

		mov	al,COL_NEEDLE

		call	LineDraw

;---------------------
;* airbrakes indicator
;---------------------

XCENTRE		=	11
YCENTRE		=	180

		mov	cx,XCENTRE
		mov	bl,YCENTRE

		mov	dx,XCENTRE-3	;assume airbrakes in
		mov	bh,YCENTRE+4

		test	AirBrakes,1	;airbrakes in?
		jz	@F		;yes ->

		mov	dx,XCENTRE-5	;airbrakes out
		mov	bh,YCENTRE+2

@@:		mov	al,COL_NEEDLE

		call	LineDraw

		ret

UpdateCtrlSFace	ENDP

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

XCENTRE		=	53
YCENTRE		=	185

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

XCENTRE		=	53
YCENTRE		=	185

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

;* UpdateVSI - update vertical speed indicator
;*
;* pass: DispVSI
;* ret : nothing
;* kill: assume all

UpdateVSI	PROC	NEAR

XCENTRE		=	19
YCENTRE		=	153

;* index = DispVSI * (1311 / 32768) + 14

		mov	ax,DispVSI
		ABSV	ax		;ax = abs(vsi)
		mov	bp,dx		;bp = sign(vsi)

		cmp	ax,675		;> meter fsd?
		jbe	@F		;no ->
		mov	ax,675		;limit to fsd

@@:		mov	dx,1311
		imul	dx
		FRACADJ	si
		add	si,14
		shl	si,1		;*2 index

		mov	cx,XCENTRE
		mov	bl,YCENTRE

		mov	dx,cx
		mov	al,DialXY1[si+0]	;x offset
		cbw
		add	dx,ax

		mov	bh,bl
		mov	al,DialXY1[si+1]	;y offset
		cbw
		xor	ax,bp		;flip y if -vsi
		sub	ax,bp
		add	bh,al

		mov	al,COL_NEEDLE

		call	LineDraw

		ret

UpdateVSI	ENDP

;----------------------------------------------------------------------------

;* UpdateSpeed - update combined speed indicator
;*
;* pass: DispMachNum
;*       Vkts
;* ret : nothing
;* kill: assume all

UpdateSpeed	PROC	NEAR

XCENTRE		=	53
YCENTRE		=	155

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

;* UpdateRadAlt - update radar altimeter
;*
;* pass: DispRadAlt
;* ret : nothing
;* kill: assume all

UpdateRadAlt	PROC	NEAR

XCENTRE		=	49
YCENTRE		=	127

;* if DispRadAlt < 1000 then
;*    index = DispRadAlt * (983 / 32768) + 5
;* else
;*    index = (DispRadAlt - 1000) * (131 / 32768) + 35
;* end

		mov	ax,DispRadAlt	;limit to 5,000ft
		cmp	ax,5000
		jbe	@F
		mov	ax,5000

@@:		cmp	ax,1000		;<= 1,000ft?
		ja	@F		;no ->

;* radar alt <= 1,000ft

		mov	dx,983
		imul	dx
		FRACADJ	si
		add	si,5
		jmp	RadAltOk

;* radar alt > 1,000ft

@@:		sub	ax,1000		;DispRadAlt - 1000
		mov	dx,131
		imul	dx
		FRACADJ	si
		add	si,35

RadAltOk:	shl	si,1		;*2 index

		mov	cx,XCENTRE
		mov	bl,YCENTRE

		mov	dx,cx
		mov	al,DialXY1[si+0]	;x offset
		cbw
		add	dx,ax

		mov	bh,bl
		add	bh,DialXY1[si+1]	;y offset

		mov	al,COL_NEEDLE

		call	LineDraw

		ret

UpdateRadAlt	ENDP

;----------------------------------------------------------------------------

;* UpdateEScope - update E-Scope
;*
;* pass: GndHtData[]
;* ret : nothing
;* kill: assume all

UpdateEScope	PROC	NEAR

ESCOPE_X	EQU	72
ESCOPE_Y	EQU	111
ESCOPE_WIDTH	EQU	32
ESCOPE_DEPTH	EQU	20
ESCOPE_DATUM	EQU	6

;* check IDS / ECR

		cmp	TornadoType,ADV_TORNADO
		_JE	ExitEScope

;* clear display

		mov	cx,ESCOPE_X
		mov	bl,ESCOPE_Y
		mov	dx,ESCOPE_X+ESCOPE_WIDTH-1
		mov	bh,ESCOPE_Y+ESCOPE_DEPTH-1

		mov	al,COL_CRT1
		call	BlockFill

;* check alt < 5,000ft

		cmp	ZftHi,0		;alt < 65,535ft?
		ja	@F		;no ->
		cmp	ZftLo,5000	;alt < 5,000ft?
		jb	AltOk		;yes ->

@@:		jmp	EtchDatum

AltOk:	     	xor	bx,bx		;index
		mov	cx,32		;number of ground height samples

GndHtLoop:	push	bx
		push	cx

;* draw ground height trace

;* x pos = -cx (32 .. 1) + ESCOPE_X + ESCOPE_WIDTH

		neg	cx

		add	cx,ESCOPE_X+ESCOPE_WIDTH

;* y pos = (alt - ground height) / 64 + ESCOPE_Y + ESCOPE_DATUM + 1

		mov	ax,ZftLo
		sub	ax,GndHtData[bx]
		ABSV	ax
		REPT	6   		;/64
		shr	ax,1
		ENDM
		adc	ax,0		;1/2 bit round up
		xor	ax,dx		;restore sign
		sub	ax,dx

		add	ax,ESCOPE_Y+ESCOPE_DATUM+1

		cmp	ax,ESCOPE_Y	;trace above display?
		jge	@F		;no ->

		mov	bl,ESCOPE_Y-1	;set y for full noise
		jmp	DrawNoise

@@:		cmp	ax,ESCOPE_Y+ESCOPE_DEPTH-1	;trace below display?
		jg	SkipTrace			;yes ->

		mov	bl,al

		push	bx
		push	cx

		mov	al,COL_CRT16
		call	SetPixel

		pop	cx
		pop	bx

;* draw noise under trace (if any)

DrawNoise:	mov	bh,ESCOPE_Y+ESCOPE_DEPTH-1

		cmp	bl,bh		;any noise?
		je	SkipTrace	;no ->

		inc	bl		;y = y + 1

		mov	al,COL_CRT6
		call	VLineDraw

SkipTrace: 	pop	cx
		pop	bx

		add	bx,2		;next index

		loop	GndHtLoop

;* etch aircraft datum

EtchDatum:	mov	al,COL_CRT16
		mov	cx,ESCOPE_X
		mov	bl,ESCOPE_Y+ESCOPE_DATUM
		call	SetPixel

		mov	al,COL_CRT16
		mov	cx,ESCOPE_X+1
		mov	bl,ESCOPE_Y+ESCOPE_DATUM
		call	SetPixel

ExitEScope:	ret

UpdateEScope 	ENDP

;----------------------------------------------------------------------------

;* UpdateOxyDolly - update oxygen flow indicator
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

UpdateOxyDolly	PROC	NEAR

		test	SSF_Oxygen,1	;oxygen system working?
		jnz	ExitOxyDolly	;no ->

		mov	ax,OxyDollyTimer
		sub	ax,LastFrame
		jnc	@F

		xor	OxyDollyPos,1

		mov	ax,OXY_TIME

@@:		mov	OxyDollyTimer,ax

ExitOxyDolly:	ret

UpdateOxyDolly	ENDP

;----------------------------------------------------------------------------

;* RWR_PIX - plot RWR symbol pixel
;*
;* pass: cx  = x symbol centre
;*       bl  = y symbol centre
;*       x   = x offset
;*       y   = y offset
;*       col = logical colour
;* ret : nothing
;* kill: assume all

RWR_PIX		MACRO	x,y,col

		push	bx
		push	cx

		add	cx,x
		add	bl,y

		mov	al,col
		call	SetPixel

		pop	cx
		pop	bx

		ENDM

;----------------------------------------------------------------------------

;* UpdateRWR - update radar warning receiver
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all
;*
;* note: This routine must be called AFTER DrawPilotPanel else the threat
;*	 symbols are overwritten.

UpdateRWR	PROC	NEAR

;----------------------
;* check if RWR damaged
;----------------------

		test	SSF_RWR,1
		jnz	RWRExit

;-----------------------------------
;* draw low priority threat symobols
;-----------------------------------

		mov	cx,NumRWRThreats
		jcxz	RWRExit

		mov	bp,OFFSET RWRThreats

RWRLoop1:	mov	si,[bp].RWR_THREAT

		cmp	RWRLoSymbol[si],-1
		je	@F

		push	cx
		push	bp
		
		mov	bp,[bp].RWR_DIR

		REPT	3
		shr	bp,1		;0 .. 63
		ENDM

		ROUNDUP	bp		;0 .. 64

		shl	bp,1		;0 .. 128 step 2

		mov	cx,RWR_CIRCLE_X
		mov	bl,RWR_CIRCLE_Y

		mov	al,RWRCircle[bp+0]	;x offset
		cbw
		add	cx,ax

		add	bl,RWRCircle[bp+1]	;y offset

		call	RWRLoSymbol[si]

		pop	bp
		pop	cx

@@:		add	bp,RWR_REC_SIZE

		loop	RWRLoop1

;------------------------------------
;* draw high priority threat symobols
;------------------------------------

		mov	cx,NumRWRThreats

		mov	bp,OFFSET RWRThreats

RWRLoop2:	mov	si,[bp].RWR_THREAT

		cmp	RWRHiSymbol[si],-1
		je	@F

		push	cx
		push	bp
		
		mov	bp,[bp].RWR_DIR

		REPT	3
		shr	bp,1		;0 .. 63
		ENDM

		ROUNDUP	bp		;0 .. 64

		shl	bp,1		;0 .. 128 step 2

		mov	cx,RWR_CIRCLE_X
		mov	bl,RWR_CIRCLE_Y

		mov	al,RWRCircle[bp+0]	;x offset
		cbw
		add	cx,ax

		add	bl,RWRCircle[bp+1]	;y offset

		call	RWRHiSymbol[si]

		pop	bp
		pop	cx

@@:		add	bp,RWR_REC_SIZE

		loop	RWRLoop2

RWRExit:	ret

UpdateRWR	ENDP

;----------------------------------------------------------------------------

;* SAMSymbol - draw RWR SAM symbol
;*
;* pass: cx = x
;*	 bl = y
;* ret : nothing
;* kill: assume all

SAMSymbol	PROC	NEAR

		RWR_PIX	 0, -1, COL_CRT16
		RWR_PIX	 0,  0, COL_CRT16
		RWR_PIX	-1,  1, COL_CRT16
		RWR_PIX	 1,  1, COL_CRT16

		ret

SAMSymbol	ENDP

;----------------------------------------------------------------------------

;* AAASymbol - draw RWR AAA symbol
;*
;* pass: cx = x
;*	 bl = y
;* ret : nothing
;* kill: assume all

AAASymbol	PROC	NEAR

		RWR_PIX	 0, -1, COL_CRT16
		RWR_PIX	-1,  0, COL_CRT16
		RWR_PIX	 0,  0, COL_CRT16
		RWR_PIX	 1,  0, COL_CRT16
		RWR_PIX	-1,  1, COL_CRT16
		RWR_PIX	 1,  1, COL_CRT16

		ret

AAASymbol	ENDP

;----------------------------------------------------------------------------

;* EWRSymbol - draw RWR EWR symbol
;*
;* pass: cx = x
;*	 bl = y
;* ret : nothing
;* kill: assume all

EWRSymbol	PROC	NEAR

		RWR_PIX	 0, -1, COL_CRT16
		RWR_PIX	-1,  0, COL_CRT16
		RWR_PIX	 1,  0, COL_CRT16
		RWR_PIX	 0,  1, COL_CRT16

		ret

EWRSymbol	ENDP

;----------------------------------------------------------------------------

;* ACSymbol - draw RWR AC symbol
;*
;* pass: cx = x
;*	 bl = y
;* ret : nothing
;* kill: assume all

ACSymbol	PROC	NEAR

		RWR_PIX	-1, -1, COL_CRT16
		RWR_PIX	 0, -1, COL_CRT16
		RWR_PIX	 1, -1, COL_CRT16
		RWR_PIX	-1,  0, COL_CRT16
		RWR_PIX	 1,  0, COL_CRT16
		RWR_PIX	-1,  1, COL_CRT16
		RWR_PIX	 0,  1, COL_CRT16
		RWR_PIX	 1,  1, COL_CRT16

		ret

ACSymbol	ENDP

;----------------------------------------------------------------------------

;* MSLSymbol1 - draw RWR radar guided MSL symbol
;*
;* pass: cx = x
;*	 bl = y
;* ret : nothing
;* kill: assume all

MSLSymbol1	PROC	NEAR

		RWR_PIX	 0, -1, COL_RAD_MISS
		RWR_PIX	-1,  0, COL_RAD_MISS
		RWR_PIX	 0,  0, COL_RAD_MISS
		RWR_PIX	 1,  0, COL_RAD_MISS
		RWR_PIX	 0,  1, COL_RAD_MISS

		ret

MSLSymbol1	ENDP

;----------------------------------------------------------------------------

;* MSLSymbol2 - draw RWR IR guided MSL symbol
;*
;* pass: cx = x
;*	 bl = y
;* ret : nothing
;* kill: assume all

MSLSymbol2	PROC	NEAR

		RWR_PIX	 0, -1, COL_IR_MISS
		RWR_PIX	-1,  0, COL_IR_MISS
		RWR_PIX	 0,  0, COL_IR_MISS
		RWR_PIX	 1,  0, COL_IR_MISS
		RWR_PIX	 0,  1, COL_IR_MISS

		ret

MSLSymbol2	ENDP

PANCODE		ENDS

;============================================================================

		END

