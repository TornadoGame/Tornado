;****************************************************************************
;*
;* HUD.ASM
;*
;* Head Up Display routines.
;*
;* 21.11.1991 - KJB
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	UpdateHUD

		PUBLIC	HUDEnabled

		EXTRN	Print$:FAR
		EXTRN	PrintChar:FAR
		EXTRN	SetPixel:FAR
		EXTRN	LineDraw:FAR
		EXTRN	VLineDraw:FAR
		EXTRN	HLineDraw:FAR
		EXTRN	SSprite:FAR
		EXTRN	SetSSpriteClip:FAR
		EXTRN	DrawBrackets:FAR
		EXTRN	SetHUDLevel:FAR
		EXTRN	CalcAngDiff:FAR
		EXTRN	VSetViewport:FAR
		EXTRN	VQuickLineClip:FAR
		EXTRN	VDotClip:FAR
		EXTRN	CalcTransMatrix:FAR
		EXTRN	CalcEyeCoords:FAR
		EXTRN	XDotClip:FAR
		EXTRN	XCalcUnclipCRT:FAR
		EXTRN	CalcRngBrgVP_WP:FAR
		EXTRN	CalcTgtRelCo:FAR
		EXTRN	CalcIntercept:FAR
		EXTRN	GetDroneSpeed:FAR

		EXTRN	AirTgtRange:DWORD
		EXTRN	GndTgtRange:DWORD

		EXTRN	Sprite:WORD
		EXTRN	SpriteX:WORD
		EXTRN	SpriteY:WORD
		EXTRN	SpritePtr:WORD
		EXTRN	PrtLn:WORD
		EXTRN	PrtCl:WORD
		EXTRN	HUDDigits:WORD
		EXTRN	DispAlpha:WORD
		EXTRN	DispZdot:WORD
		EXTRN	DispBarAlt:WORD
		EXTRN	TrueRadAlt:WORD
		EXTRN	ZftHi:WORD
		EXTRN	ZftLo:WORD
		EXTRN	M_SinR:WORD
		EXTRN	M_CosR:WORD
		EXTRN	Vkts:WORD
		EXTRN	DispMachNum:WORD
		EXTRN	Hdg:WORD
		EXTRN	HFine:WORD
		EXTRN	PFine:WORD
		EXTRN	RFine:WORD
		EXTRN	TornadoType:WORD
		EXTRN	WPTimeEarlyLate:WORD
		EXTRN	WayTotal:WORD
		EXTRN	WPPtr:WORD
		EXTRN	WPBrg:WORD
		EXTRN	WPBrgFine:WORD
		EXTRN	ILSLocalPos:WORD
		EXTRN	ILSGlidePos:WORD
		EXTRN	ArmMode:WORD
		EXTRN	PackagePtr:WORD
		EXTRN	SafetyHeights:WORD
		EXTRN	JP233Timer:WORD
		EXTRN	LoftClock:WORD
		EXTRN	LoftRatio:WORD
		EXTRN	AirTgtPtr:WORD
		EXTRN	RadarMode:WORD
		EXTRN	Cannons:WORD
		EXTRN	ExtStores:WORD
		EXTRN	Vtas:WORD
		EXTRN	DispAirTgtRng:WORD
		EXTRN	DispAirTgtAlt:WORD
		EXTRN	DispAirTgtVel:WORD
		EXTRN	DispAirTgtHdg:WORD

		EXTRN	IronWork:BYTE
		EXTRN	SSF_HUD:BYTE
		EXTRN	TFAuto:BYTE
		EXTRN	KF_HUDContrast:BYTE
		EXTRN	KF_HUDSwitch:BYTE
		EXTRN	KF_HUDOption:BYTE
		EXTRN	HUDLevel:BYTE
		EXTRN	ILSActive:BYTE
		EXTRN	LaserActive:BYTE
		EXTRN	ArmLock:BYTE
		EXTRN	IRLockFlag:BYTE
		EXTRN	RwrTgtValid:BYTE

		EXTRN	MUZZLE_VELOCITY:ABS

;============================================================================

		INCLUDE	MAINDATA.INC

		INCLUDE	\VISUAL\PALETTES.INC
		INCLUDE	\VISUAL\VSCREEN.INC
		INCLUDE	\VISUAL\VISEXTRN.INC
		INCLUDE	\VISUAL\VISDATA.INC

		INCLUDE	\LIB8086\KEYS.INC
		INCLUDE	\LIB8086\PRINT.INC
 		INCLUDE	\LIB8086\USEFUL.INC

;============================================================================

		EXTRN	M_VIEW:VIEWPOINT
		EXTRN	TGT_VIEW:VIEWPOINT
		EXTRN	CCIP_VIEW:VIEWPOINT

		EXTRN	FloatWP:WAYPOINT

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

;-----------------
;* HUD mode switch (wrt ArmMode)
;-----------------

HUDSwitch	DW	HUDNavigation	;ARM_OFF
		DW	HUDManualBomb	;ARM_MANUAL
		DW	HUDLaydownBomb	;ARM_LAYDOWN
		DW	HUDLoftBomb	;ARM_LOFT
		DW	HUDLaserGuided	;ARM_LGB
		DW	HUDJP233	;ARM_JP233
		DW	HUDAlarmDir	;ARM_ALARM_DIR
		DW	HUDAlarmInd	;ARM_ALARM_IND
		DW	HUDCannon	;ARM_CANNON
		DW	HUDSidewinder	;ARM_SIDEWINDER
		DW	HUDSkyFlash	;ARM_SKYFLASH

;-----------
;* HUD flags
;-----------

HUDEnabled	DB	1		;1 = HUD enabled

MachOption	DB	0		;1 = display mach num

;--------------------
;* HUD origin equates
;--------------------

HUD_X_ORG	EQU	160
HUD_Y_ORG	EQU	48

;----------------------------
;* HUD clipping window limits
;----------------------------

CLIP_ABOVE	DW	0
CLIP_BELOW 	DW	0
CLIP_LEFT	EQU	104
CLIP_RIGHT	EQU	215

;---------------------------------
;* variable heading strip position (wrt HUD_Y_ORG)
;---------------------------------

HdgYOff		DW	0

;--------------
;* HUD viewport
;--------------

VP		VIEWPORT <HUD_X_ORG-48,HUD_Y_ORG-44+1,96,88,0,7>

;-----------------
;* marker position
;-----------------

MarkerX		DW	0
MarkerY		DB	0,0

;----------------------------
;* altitude clock bug co-ords (rel offsets from clock centre, one quad only)
;----------------------------

AltBugXY1	LABEL	BYTE		;outer point

		DB	 0,-10		;0
		DB	 1,-10		;1
		DB	 2,-10		;2
		DB	 3,-10		;3
		DB	 4,-10		;4
		DB	 5, -9		;5
		DB	 6, -9		;6
		DB	 7, -8		;7
		DB	 8, -8		;8
		DB	 9, -7		;9
		DB	10, -6		;10
		DB	11, -5		;11
		DB	12, -4		;12
		DB	12, -3		;13
		DB	13, -2		;14
		DB	13, -1		;15
		DB	13,  0		;16

AltBugXY2	LABEL	BYTE		;inner point

		DB	 0, -9 		;0
		DB	 1, -9 		;1
		DB	 2, -9 		;2
		DB	 3, -9 		;3
		DB	 4, -9 		;4
		DB	 4, -8		;5
		DB	 5, -8		;6
		DB	 6, -7		;7
		DB	 7, -7		;8
		DB	 8, -6		;9
		DB	 9, -5		;10
		DB	10, -4		;11
		DB	11, -4		;12
		DB	11, -3		;13
		DB	12, -2		;14
		DB	12, -1		;15
		DB	12,  0		;16

;------------------------
;* pitch bar x, y offsets (*256 scaled to reduce jitter)
;------------------------

BarXOff		DW	0		;x offset of pitch bar being drawn
BarYOff		DW	0		;y offset of pitch bar being drawn

Px0		DW	0		;delta x between pitch bars
Py0		DW	0		;delta y between pitch bars

;*                                         P11 O (+ve)
;*
;*	     P3	   P4	 P5    P6    P7	   P8	 P9    P10
;*   P1	O-----O-----O-----O-----O-----O-----O-----O-----O
;*	|
;*	|
;*	|                                  P12 O (-ve)
;*   P2	O

Px1		DW	0
Py1		DW	0
Px2		DW	0
Py2		DW	0
Px3		DW	0
Py3		DW	0
Px4		DW	0
Py4		DW	0
Px5		DW	0
Py5		DW	0
Px6		DW	0
Py6		DW	0
Px7		DW	0
Py7		DW	0
Px8		DW	0
Py8		DW	0
Px9		DW	0
Py9		DW	0
Px10		DW	0
Py10		DW	0
Px11		DW	0
Py11		DW	0
Px12		DW	0
Py12		DW	0

;-----------------
;* countdown clock
;-----------------

ClockXOrg	DW	0
ClockYOrg	DB	0,0

CountClock1	LABEL	BYTE		;centre ring

		DB	  0,  -9	;0
		DB	  1,  -9	;1
		DB	  2,  -9	;2
		DB	  3,  -9	;3
		DB	  4,  -8	;4
		DB	  5,  -8	;5
		DB	  6,  -8	;6
		DB	  7,  -7	;7
		DB	  8,  -6	;8
		DB	  9,  -5	;9
		DB	 10,  -4	;10
		DB	 10,  -3	;11
		DB	 11,  -2	;12
		DB	 11,  -1	;13

		DB	 11,   0	;14
		DB	 11,   1	;15
		DB	 11,   2	;16
		DB	 10,   3	;17
		DB	 10,   4	;18
		DB	  9,   5	;19
		DB	  8,   6	;20
		DB	  7,   7	;21
		DB	  6,   8	;22
		DB	  5,   8	;23
		DB	  4,   8	;24
		DB	  3,   9	;25
		DB	  2,   9	;26
		DB	  1,   9	;27

		DB	  0,   9	;28
		DB	 -1,   9	;29
		DB	 -2,   9	;30
		DB	 -3,   9	;31
		DB	 -4,   8	;32
		DB	 -5,   8	;33
		DB	 -6,   8	;34
		DB	 -7,   7	;35
		DB	 -8,   6	;36
		DB	 -9,   5	;37
		DB	-10,   4	;38
		DB	-10,   3	;39
		DB	-11,   2	;40
		DB	-11,   1	;41

		DB	-11,   0	;42
		DB	-11,  -1	;43
		DB	-11,  -2	;44
		DB	-10,  -3	;45
		DB	-10,  -4	;46
		DB	 -9,  -5	;47
		DB	 -8,  -6	;48
		DB	 -7,  -7	;49
		DB	 -6,  -8	;50
		DB	 -5,  -8	;51
		DB	 -4,  -8	;52
		DB	 -3,  -9	;53
		DB	 -2,  -9	;54
		DB	 -1,  -9	;55

CountClock2	LABEL	BYTE		;inner ring

		DB	  0,  -8	;0
		DB	  1,  -8	;1
		DB	  2,  -8	;2
		DB	  3,  -8	;3		 
		DB	  4,  -7	;4
		DB	  5,  -7	;5
		DB	  6,  -7	;6
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
		DB	  6,   7	;20
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
		DB	 -6,   7	;32
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
		DB	 -6,  -7	;46
		DB	 -5,  -7	;47
		DB	 -4,  -7	;48
		DB	 -3,  -8	;49	 
		DB	 -2,  -8	;50
		DB	 -1,  -8	;51

CountClock3	LABEL	BYTE		;outer ring

		DB	  0, -10	;0
		DB	  1, -10	;1
		DB	  2, -10	;2
		DB	  3, -10	;3
		DB	  4,  -9	;4
		DB	  5,  -9	;5
		DB	  6,  -9	;6
		DB	  7,  -8	;7
		DB	  8,  -7	;8
		DB	  9,  -6	;9
		DB	 10,  -5	;10
		DB	 11,  -4	;11
		DB	 11,  -3	;12
		DB	 12,  -2	;13
		DB	 12,  -1	;14

		DB	 12,   0	;15
		DB	 12,   1	;16
		DB	 12,   2	;17
		DB	 11,   3	;18
		DB	 11,   4	;19
		DB	 10,   5	;20
		DB	  9,   6	;21
		DB	  8,   7	;22
		DB	  7,   8	;23
		DB	  6,   9	;24
		DB	  5,   9	;25
		DB	  4,   9	;26
		DB	  3,  10	;27
		DB	  2,  10	;28
		DB	  1,  10	;29

		DB	  0,  10	;30
		DB	 -1,  10	;31
		DB	 -2,  10	;32
		DB	 -3,  10	;33
		DB	 -4,   9	;34
		DB	 -5,   9	;35
		DB	 -6,   9	;36
		DB	 -7,   8	;37
		DB	 -8,   7	;38
		DB	 -9,   6	;39
		DB	-10,   5	;40
		DB	-11,   4	;41
		DB	-11,   3	;42
		DB	-12,   2	;43
		DB	-12,   1	;44

		DB	-12,   0	;45
		DB	-12,  -1	;46
		DB	-12,  -2	;47
		DB	-11,  -3	;48
		DB	-11,  -4	;49
		DB	-10,  -5	;50
		DB	 -9,  -6	;51
		DB	 -8,  -7	;52
		DB	 -7,  -8	;53
		DB	 -6,  -9	;54
		DB	 -5,  -9	;55
		DB	 -4,  -9	;56
		DB	 -3, -10	;57
		DB	 -2, -10	;58
		DB	 -1, -10	;59

;-------------
;* string data
;-------------

;* init print attributes

SetUp$		LABEL	BYTE
		P_OVER1
		P_CHAR2
		PD_ATTR	000h,000h,000h,000h,0aah,000h,COL_HUD,000h
		P_END

;* print barometric altitude "dddd0" (unsigned, 4 digits)

BarAlt$		LABEL	BYTE
		P_DECAT	00000100b
		PD_X	HUD_X_ORG+36
		PD_Y	HUD_Y_ORG-33
		PV_DECW	DispBarAlt
		DB	'0'
		P_DECAT	00000000b
		P_END

;* print radar altitude "Rdddd" (unsigned, 4 digits)

RadAlt$		LABEL	BYTE
		P_DECAT	00000100b
		PD_X	HUD_X_ORG+36
		PD_Y	HUD_Y_ORG-33
		DB	'R'
		PV_DECW	TrueRadAlt
		P_DECAT	00000000b
		P_END

;* print Vkts (unsigned, 4 digits)

Vkts$		LABEL	BYTE
		P_DECAT	00000100b
		PD_X	HUD_X_ORG-56
		PD_Y	HUD_Y_ORG-33
		PV_DECW	Vkts
		P_DECAT	00000000b
		P_END

;* print cannon rounds (unsigned, 3 digits, left justified)

Cannon$		LABEL	BYTE
		P_DECAT	00010011b
		PD_X	HUD_X_ORG-52
		PD_Y	HUD_Y_ORG+27
		DB	"GUNS"
		PD_X	HUD_X_ORG-52
		PD_Y	HUD_Y_ORG+33
		DB	"x"
		PV_DECW	Cannons
		P_DECAT	00000000b
		P_END

;* print Sidewinder stores (unsigned, 2 digits, left justified)

Sidewinder$ 	LABEL	BYTE
		P_DECAT	00010010b
		PD_X	HUD_X_ORG-52
		PD_Y	HUD_Y_ORG+27
		DB	"AIM9"
		PD_X	HUD_X_ORG-48
		PD_Y	HUD_Y_ORG+33
		DB	"x"
		PV_DECW	ExtStores[EXT_SIDEWINDER]
		P_DECAT	00000000b
		P_END

;* print SkyFlash stores (unsigned, 2 digits, left justified)

SkyFlash$ 	LABEL	BYTE
		P_DECAT	00010010b
		PD_X	HUD_X_ORG-52
		PD_Y	HUD_Y_ORG+27
		DB	"SKYF"
		PD_X	HUD_X_ORG-48
		PD_Y	HUD_Y_ORG+33
		DB	"x"
		PV_DECW	ExtStores[EXT_SKYFLASH]
		P_DECAT	00000000b
		P_END

;* print air target data

AirTgt$		LABEL	BYTE

		P_DECAT	00000010b	;(unsigned, 2 digits, right justified)

		PD_X	HUD_X_ORG+44
		PD_Y	HUD_Y_ORG+21
		PV_DECW	DispAirTgtRng

		PD_X	HUD_X_ORG+44
		PD_Y	HUD_Y_ORG+27
		PV_DECW	DispAirTgtAlt

		P_DECAT	00000011b	;(unsigned, 3 digits, right justified)

		PD_X	HUD_X_ORG+40
		PD_Y	HUD_Y_ORG+33
		PV_DECW	DispAirTgtVel

		PD_X	HUD_X_ORG+40
		PD_Y	HUD_Y_ORG+39
		PV_PDEG	DispAirTgtHdg

		P_DECAT	00000000b
		P_END

		EVEN

DATA		ENDS

;============================================================================

PANCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:PANCODE
		ASSUME DS:DATA

;* HPIXEL - set pixel in HUD
;*
;* pass: x1, y1 (relative to HUD origin)
;* ret : nothing
;* kill: assume all

HPIXEL		MACRO	x1,y1
		
		mov	cx,HUD_X_ORG+x1
		mov	bl,HUD_Y_ORG+y1
		mov	al,COL_HUD
		call	SetPixel

		ENDM

;----------------------------------------------------------------------------

;* HVLINE - draw vertical line in HUD
;*
;* pass: y1, y2, x1 (relative to HUD origin)
;* ret : nothing
;* kill: assume all

HVLINE		MACRO	y1,y2,x1
		
		mov	bl,HUD_Y_ORG+y1
		mov	bh,HUD_Y_ORG+y2
		mov	cx,HUD_X_ORG+x1
		mov	al,COL_HUD
		call	VLineDraw

		ENDM

;----------------------------------------------------------------------------

;* HHLINE - draw horizontal line in HUD
;*
;* pass: x1, x2, y1 (relative to HUD origin)
;* ret : nothing
;* kill: assume all

HHLINE		MACRO	x1,x2,y1
		
		mov	cx,HUD_X_ORG+x1
		mov	dx,HUD_X_ORG+x2
		mov	bl,HUD_Y_ORG+y1
		mov	al,COL_HUD
		call	HLineDraw

		ENDM

;----------------------------------------------------------------------------

;* UpdateHUD - draw HUD brackets / update HUD information
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

UpdateHUD 	PROC	NEAR

;------------------------------------
;* update HUD brackets / canopy frame
;------------------------------------

		test	IronWork,1	;ironwork enabled?
		jz	@F		;no ->

		call	DrawHUDBrackets

		call	UpdateAoAMeter

;------------------------
;* update HUD information
;------------------------

@@:		test	SSF_HUD,1	;HUD damaged?
		_JNZ	ExitHUD		;yes ->

		call	InitHUD

		test	HUDEnabled,1	;HUD enabled?
		_JZ	ExitHUD		;no ->

		mov	bx,ArmMode

		jmp	HUDSwitch[bx]

;---------------------------
HUDNavigation	LABEL	NEAR
;---------------------------

		call	UpdateAoA
		call	UpdateVSI
		call	UpdateAltClock
		call	UpdateAirSpeed
		call	UpdateHdg
		call	UpdatePitch
		call	UpdateEarlyLate

		test	ILSActive,1	;ILS active?
		jnz	@F		;yes ->

		call	UpdateACSymbol

		jmp	ContNav

@@:		call	UpdateILS

ContNav:	jmp	ExitHUD

;---------------------------
HUDManualBomb	LABEL	NEAR
;---------------------------

		call	UpdateAoA
		call	UpdateVSI
		call	UpdateAltClock
		call	UpdateAirSpeed
		call	UpdateHdg
		call	UpdatePitch
		call	UpdateACSymbol
		call	UpdateEarlyLate

		mov	si,OFFSET M_VIEW
		call	CalcTransMatrix

		call	DrawCCIPMrkr
		call	DrawBombFall

		jmp	ExitHUD

;---------------------------
HUDLaydownBomb	LABEL	NEAR
;---------------------------

		call	UpdateAoA
		call	UpdateVSI
		call	UpdateAltClock
		call	UpdateAirSpeed
		call	UpdateHdg
		call	UpdatePitch
		call	UpdateACSymbol
		call	UpdateEarlyLate

		mov	si,OFFSET M_VIEW
		call	CalcTransMatrix

		call	DrawCCIPMrkr
		call	DrawGndTgtMrkr
		call	DrawBombFall

		jmp	ExitHUD

;---------------------------
HUDLoftBomb	LABEL	NEAR
;---------------------------

		call	UpdateAoA
		call	UpdateVSI
		call	UpdateAltClock
		call	UpdateAirSpeed
		call	UpdateHdg
		call	UpdatePitch
		call	UpdateACSymbol
		call	UpdateEarlyLate

		mov	si,OFFSET M_VIEW
		call	CalcTransMatrix

		call	DrawGndTgtMrkr

		mov	ax,LoftClock

		cmp	ax,-1		;clock valid?
		je	@F		;no ->

		xor	cx,cx
		xor	bl,bl
		call	UpdateClock

		cmp	LoftRatio,-1	;ratio valid?
		je	@F		;no ->

		call	LoftSteeringCue

		jmp	ExitHUD

@@: 		call	DrawSolidFall

		jmp	ExitHUD

;---------------------------
HUDLaserGuided	LABEL	NEAR
;---------------------------

		call	UpdateAoA
		call	UpdateVSI
		call	UpdateAltClock
		call	UpdateAirSpeed
		call	UpdateHdg
		call	UpdatePitch
		call	UpdateACSymbol
		call	UpdateEarlyLate

		call	DrawSolidFall

		call	LaserRangeClock

		jmp	ExitHUD

;---------------------------
HUDJP233	LABEL	NEAR
;---------------------------

		call	UpdateAoA
		call	UpdateVSI
		call	UpdateAltClock
		call	UpdateAirSpeed
		call	UpdateHdg
		call	UpdatePitch
		call	UpdateACSymbol
		call	UpdateEarlyLate

		test	ArmLock,1  	;release in progress?
		jnz	@F	   	;yes ->

;* approaching target

		mov	si,OFFSET M_VIEW
		call	CalcTransMatrix

		call	DrawCCIPMrkr
		call	DrawGndTgtMrkr
		call	DrawSolidFall

		jmp	ExitHUD

;* release in progress

@@:		call	JP233Clock

		jmp	ExitHUD

;---------------------------
HUDAlarmDir	LABEL	NEAR
;---------------------------

		call	UpdateAoA
		call	UpdateVSI
		call	UpdateAltClock
		call	UpdateAirSpeed
		call	UpdateHdg
		call	UpdatePitch
		call	UpdateEarlyLate

		call	DrawCentreCross

		test	RWRTgtValid,1	;target valid?
		jz	@F		;no ->

		mov	si,OFFSET M_VIEW
		call	CalcTransMatrix

		call	DrawGndTgtMrkr

		call	DrawAlarmClock

@@:		jmp	ExitHUD

;---------------------------
HUDAlarmInd	LABEL	NEAR
;---------------------------

		call	UpdateAoA
		call	UpdateVSI
		call	UpdateAltClock
		call	UpdateAirSpeed
		call	UpdateHdg
		call	UpdatePitch
		call	UpdateEarlyLate

		call	DrawCentreCross

		mov	si,OFFSET M_VIEW
		call	CalcTransMatrix

		call	DrawGndTgtMrkr

		call	DrawAlarmClock

		jmp	ExitHUD

;---------------------------
HUDCannon	LABEL	NEAR
;---------------------------

		call	UpdateAoA
		call	UpdateAirSpeed
		call	UpdateHdg
		call	UpdatePitch

		mov	si,OFFSET Cannon$
		call	Print$

		cmp	RadarMode,AIR_RADAR	;air radar on?
		jne	@F			;no ->

;* >>>>> air-to-air mode <<<<<

		call	UpdateAlt

		call	DrawAirTarget
		jc	StandbySight	;invalid target or error ->

		call	DrawIntercept

		call	DrawCentreCross

		call	DispAirTgtData

		jmp	ExitHUD

;* >>>>> air-to-ground mode <<<<<

@@:		call	UpdateVSI
		call	UpdateAltClock
		call	UpdateEarlyLate

;* check target valid (floating waypoint)

		cmp	WPPtr,OFFSET FloatWP	;floating waypoint selected?
		jne	StandbySight		;no ->

		mov	si,OFFSET M_VIEW
		call	CalcTransMatrix

		call	DrawGndTgtMrkr
		jc	StandbySight	;non-visible ->

		call	DrawCentreCross

		call	DrawGndGunClock

		jmp	ExitHUD

StandbySight:	call	DrawStandby

		jmp	ExitHUD

;---------------------------
HUDSidewinder	LABEL	NEAR
;---------------------------

		call	UpdateAoA
		call	UpdateAlt
		call	UpdateAirSpeed
		call	UpdateHdg
		call	UpdatePitch

		mov	si,OFFSET Sidewinder$
		call	Print$

		call	DrawCentreCross

		call	DrawAirTarget
		jc	@F		;invalid target or error ->

		call	DrawIntercept

		call	DispAirTgtData

@@:		jmp	ExitHUD

;---------------------------
HUDSkyFlash	LABEL	NEAR
;---------------------------

		call	UpdateAoA
		call	UpdateAlt
		call	UpdateAirSpeed
		call	UpdateHdg
		call	UpdatePitch

		mov	si,OFFSET SkyFlash$
		call	Print$

		call	DrawCentreCross

		call	DrawAirTarget
		jc	ExitHUD		;invalid target or error ->

		call	DrawIntercept

		call	DispAirTgtData

ExitHUD:	ret

UpdateHUD  	ENDP

;----------------------------------------------------------------------------

;* InitHUD - initialize HUD
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

InitHUD		PROC	NEAR

;------------------------
;* check for HUD on / off
;------------------------

		KTEST	KF_HUDSwitch
		jz	@F

		xor	HUDEnabled,1	;toggle on / off

		jnz	InitCont	;on ->

		jmp	InitDone

@@:		test	HUDEnabled,1	;HUD enabled?
		jz	InitDone	;no ->

;----------------------------------
;* check for mach num option toggle
;----------------------------------

		KTEST	KF_HUDOption
		jz	@F

		xor	MachOption,1	;toggle mach num option

		jmp	InitCont

;-------------------------------
;* check for HUD contrast change
;-------------------------------

@@:		KTEST	KF_HUDContrast
		jz	InitCont

		mov	al,HUDLevel
		inc	al
		and	al,3
		mov	HUDLevel,al

		call	SetHUDLevel

;-----------------------------------------------------
;* sort heading strip position and HUD clipping window
;-----------------------------------------------------

InitCont:	cmp	TornadoType,ADV_TORNADO
		je	@F

		mov	HdgYOff,40
		mov	CLIP_ABOVE,5
		mov	CLIP_BELOW,80

		jmp	SetClip

@@:		mov	HdgYOff,-38
		mov	CLIP_ABOVE,16
		mov	CLIP_BELOW,94

SetClip:	call	SetHUDClip

;-----------------------
;* init print attributes
;-----------------------

		mov	si,OFFSET SetUp$
		call	Print$

;-------------------
;* init HUD viewport
;-------------------

;* roll with horizon

		mov	ax,RFine
		neg	ax
		mov	cl,7
		shr	ax,cl

		mov	si,OFFSET VP
		call	VSetViewport

InitDone:	ret

InitHUD		ENDP

;----------------------------------------------------------------------------

;* DrawHUDBrackets
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

DrawHUDBrackets	PROC	NEAR

		call	DrawBrackets

		ret

DrawHUDBrackets	ENDP

;----------------------------------------------------------------------------

;* UpdateAoAMeter - display AoA (angle of attack) on HUD bracket meter
;*
;* pass: DispAlpha
;* ret : nothing
;* kill: assume all
;*
;* note: DispAlpha = -8*16 .. 21*16.

UpdateAoAMeter	PROC	NEAR

;* sort -ve AoA

		mov	ax,DispAlpha
		test	ax,ax		;-ve AoA?
		jns	@F		;no ->
		xor	ax,ax		;set -ve AoA to 0

;* calc bar length

@@:		REPT	3		;bar length = AoA / 8 = 0 .. 42
		shr	ax,1
		ENDM
		adc	ax,0		;1/2 bit round up (0 ..43)

;* draw meter bar (3 pixels wide)

		mov	bl,HUD_Y_ORG+44
		mov	bh,bl		;y2 = y1
		sub	bl,al		;y1 = y1 - bar length

		push	bx
		mov	cx,HUD_X_ORG-84
		mov	al,COL_AOA
		call	VLineDraw
		pop	bx

		push	bx
		mov	cx,HUD_X_ORG-83
		mov	al,COL_AOA
		call	VLineDraw
		pop	bx

		mov	cx,HUD_X_ORG-82
		mov	al,COL_AOA
		call	VLineDraw

		ret

UpdateAoAMeter	ENDP

;---------------------------------------------------------------------------

;* UpdateAoA - update AoA (angle of attack) display
;*
;* pass: DispAlpha
;* ret : nothing
;* kill: assume all
;*
;* note: DispAlpha = -8*16 .. 21*16.

UpdateAoA	PROC	NEAR

;* draw AoA graduations

		HPIXEL	-56, -15
		HPIXEL	-54, -15
		HPIXEL	-54, -10
		HPIXEL	-56,  -5
		HPIXEL	-54,  -5
		HPIXEL	-54,   0
		HPIXEL	-56,  +5
		HPIXEL	-54,  +5
		HPIXEL	-54, +10

;* draw AoA zero line

		HHLINE	-54, -52, +15

;* sort -ve AoA

		mov	ax,DispAlpha
		test	ax,ax		;-ve AoA?
		jns	@F		;no ->
		xor	ax,ax		;set -ve AoA to 0

;* calc AoA indicator line length (1 pixel = 1 degree)

@@:		REPT	4		;line length = AoA / 16 = 0 .. 21
		shr	ax,1
		ENDM
		adc	ax,0		;1/2 bit round up (0 .. 22)

;* draw AoA indicator line

		mov	bl,HUD_Y_ORG+15
		mov	bh,bl		;y2 = y1
		sub	bl,al		;y1 = y1 - line length

		mov	cx,HUD_X_ORG-51
		mov	al,COL_HUD
		call	VLineDraw

		ret

UpdateAoA	ENDP

;----------------------------------------------------------------------------

;* UpdateVSI - update Vertical Speed Indicator display
;*
;* pass: DispZdot
;* ret : nothing
;* kill: assume all
;*
;* note: DispZdot *8 scaled.

UpdateVSI	PROC	NEAR

;* draw VSI graduations

		HPIXEL	+51, -15
		HPIXEL	+49, -10
		HPIXEL	+51, -10
		HPIXEL	+51,  -5
		HPIXEL	+51,  +5
		HPIXEL	+49, +10
		HPIXEL	+51, +10
		HPIXEL	+51, +15

;* draw VSI zero line
		
		HPIXEL	+52,   0
		HPIXEL	+53,   0

;* calc VSI indicator line length (use abs(DispZdot) to avoid -1 truncation error)
;*
;* 1 pixel = 1 ft / sec (therefore 10 pixels = 600 ft / min)

		mov	ax,DispZdot

		ABSV	ax

		REPT	3		;/8
		shr	ax,1
		ENDM

		cmp	ax,20		;abs(DispZdot) <= 20ft / sec
		jbe	@F		;yes ->
		mov	ax,20		;limit to 20ft / sec

@@:		xor	ax,dx		;restore sign
		sub	ax,dx

;* draw VSI indicator line

		mov	bl,HUD_Y_ORG
		mov	bh,bl		;y2 = y1
		sub	bl,al		;y1 = y1 - line length

		mov	cx,HUD_X_ORG+54
		mov	al,COL_HUD
		call	VLineDraw

		ret

UpdateVSI	ENDP

;----------------------------------------------------------------------------

;* UpdateAltClock - update altitude clock display
;*
;* pass: ZftHi, ZftLo
;*       DispBarAlt
;*       TrueRadAlt
;* ret : nothing
;* kill: assume all
;*
;* note: Assumes ZftHi, ZftLo does not exceed 99,999ft.

UpdateAltClock	PROC	NEAR

;* draw altitude clock graduations

		HPIXEL	+45, -42
		HPIXEL	+53, -40
		HPIXEL	+58, -35
		HPIXEL	+58, -27
		HPIXEL	+53, -22
		HPIXEL	+45, -20
		HPIXEL	+37, -22
		HPIXEL	+32, -27
		HPIXEL	+32, -35
		HPIXEL	+37, -40

;----------------
;* print altitude
;----------------

;* if TrueRadAlt < 5000 then
;*    print radar altitude "Rdddd"
;* else
;*    print barometric altitude "dddd0" (lsd always zero)
;* end

		mov	ax,TrueRadAlt
		cmp	ax,5000		;disp bar alt?
		jae	@F		;yes ->

;* print radar altitude

		xor	dx,dx

		push	ax		;store clock bug value
		push	dx

		mov	si,OFFSET RadAlt$
		call	Print$

		jmp	AltClockBug

;* print barometric altitude

@@:		push	ZftLo		;store clock bug value
		push	ZftHi

		mov	si,OFFSET BarAlt$
		call	Print$

;-------------------------
;* calc clock bug position
;-------------------------

;* pos = remainder(alt / 1000) * 2066 / 32768 = 0 .. 63

AltClockBug:	pop	dx		;restore clock bug value
		pop	ax

		mov	bx,1000
		div	bx		;dx = remainder(zft / 1000)

		mov	ax,2066
		mul	dx
		FRACADJ	ax		;remainder(zft / 1000) * 2066 / 32768

;* select pos

		cmp	ax,48
		jae	BugQuad4
		cmp	ax,32
		jae	BugQuad3
		cmp	ax,16
		jae	BugQuad2

;* case 0 .. 15
;*    index = pos * 2
;*    x sign = 0
;*    y sign = 0

BugQuad1:	mov	bx,ax
		shl	bx,1		;index = pos * 2
		mov	dx,00000h	;x sign = 0, y sign = 0
		jmp	DrawAltBug

;* case 16 .. 31
;*    index = (32 - pos) * 2
;*    x sign = 0
;*    y sign = -1

BugQuad2:	mov	bx,32
		sub	bx,ax
		shl	bx,1		;index = (32 - pos) * 2
		mov	dx,0ff00h	;x sign = 0, y sign = -1
		jmp	DrawAltBug

;* case 32 .. 47
;*    index = (pos - 32) * 2
;*    x sign = -1
;*    y sign = -1

BugQuad3:	mov	bx,ax
		sub	bx,32
		shl	bx,1		;index = (pos - 32) * 2
		mov	dx,0ffffh	;x sign = -1, y sign = -1
		jmp	DrawAltBug

;* case 48 .. 63
;*    index = (64 - pos) * 2
;*    x sign = -1
;*    y sign = 0
;* end

BugQuad4:	mov	bx,64
		sub	bx,ax
		shl	bx,1		;index = (64 - pos) * 2
		mov	dx,000ffh	;x sign = -1, y sign = 0

DrawAltBug:	push	bx
		push	dx

		mov	al,AltBugXY1[bx+0]
		xor	al,dl		;sort x sign
		sub	al,dl
		cbw
		add	ax,HUD_X_ORG+45	;add offset to clock x origin
		mov	cx,ax

		mov	al,AltBugXY1[bx+1]
		xor	al,dh		;sort y sign
		sub	al,dh
		add	al,HUD_Y_ORG-31	;add offset to clock y origin
		mov	bl,al		

		mov	al,COL_HUD

		call	SetPixel

		pop	dx
		pop	bx

		mov	al,AltBugXY2[bx+0]
		xor	al,dl		;sort x sign
		sub	al,dl
		cbw
		add	ax,HUD_X_ORG+45	;add offset to clock x origin
		mov	cx,ax

		mov	al,AltBugXY2[bx+1]
		xor	al,dh		;sort y sign
		sub	al,dh
		add	al,HUD_Y_ORG-31	;add offset to clock y origin
		mov	bl,al

		mov	al,COL_HUD

		call	SetPixel

;* print 'T' if auto-terrain following

		test	TFAuto,1	;auto-terrain following?
		jz	@F		;no ->

		mov	PrtLn,HUD_Y_ORG-27
		mov	PrtCl,HUD_X_ORG+44

		mov	al,'T'
		call	PrintChar

@@:		ret

UpdateAltClock	ENDP

;----------------------------------------------------------------------------

;* UpdateAlt - update altitude display
;*
;* pass: DispBarAlt
;*       TrueRadAlt
;* ret : nothing
;* kill: assume all

UpdateAlt	PROC	NEAR

;* if TrueRadAlt < 5000 then
;*    print radar altitude "Rdddd"
;* else
;*    print barometric altitude "dddd0" (lsd always zero)
;* end

		mov	si,OFFSET RadAlt$	;assume disp rad alt

		cmp	TrueRadAlt,5000		;disp rad alt?
		jb	@F			;yes ->

		mov	si,OFFSET BarAlt$	;disp bar alt

@@:		call	Print$

		ret

UpdateAlt	ENDP

;----------------------------------------------------------------------------

;* UpdateACSymbol
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

UpdateACSymbol	PROC	NEAR

		cmp	TornadoType,ADV_TORNADO	;ADV?
		jne	@F			;no ->

		HVLINE	-6, -3,  0	;fin (ADV only)

@@:		HHLINE	-1, +1, -2
		HHLINE	-1, +1, +2
		HHLINE	-8, -3,  0
		HHLINE	+3, +8,  0
		HVLINE	-1, +1, -2
		HVLINE	-1, +1, +2

		ret

UpdateACSymbol	ENDP

;----------------------------------------------------------------------------

;* UpdateAirSpeed
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

UpdateAirSpeed	PROC	NEAR

		test	MachOption,1	;display mach num?
		jnz	@F		;yes ->

;----------------------
;* display airspeed kts
;----------------------

		mov	si,OFFSET Vkts$
		call	Print$

		jmp	AirSpeedExit

;------------------
;* display mach num
;------------------

@@:		mov	ax,DispMachNum

		aam			;ah = integer, al = fraction

;* print "d.d"

		mov	PrtLn,HUD_Y_ORG-33
		mov	PrtCl,HUD_X_ORG-52

		add	al,'0'
		add	ah,'0'

		push	ax
		mov	al,ah
		call	PrintChar
		add	PrtCl,4
		pop	ax
		call	PrintChar

		HPIXEL	-47, -29

AirSpeedExit:	ret

UpdateAirSpeed	ENDP

;---------------------------------------------------------------------------

;* UpdateHdg - update heading strip
;*
;* pass: HFine
;* ret : nothing
;* kill: assume all

UpdateHdg	PROC	NEAR

;* set sprite clipping window

		mov	bl,HUD_Y_ORG
		add	bl,BYTE PTR HdgYOff
		mov	bh,bl
		sub	bl,6
		mov	cx,HUD_X_ORG-24
		mov	dx,HUD_X_ORG+23
		call	SetSSpriteClip

;* draw heading datum marker

		mov	bl,HUD_Y_ORG+1
		add	bl,BYTE PTR HdgYOff
		mov	bh,bl
		add	bh,3
		mov	cx,HUD_X_ORG
		mov	al,COL_HUD
		call	VLineDraw

;* calc heading reading and offset:-
;*
;* reading = HFine * (720 / 65536) / 20 = 0 .. 35
;* offset  = remainder(HFine * (720 / 65536) / 20) = 0 .. 19 (2 pixels / degree)

;* KJB - 11.03.1992 - modified for improved accuracy

		mov	ax,HFine
		mov	dx,720
		mul	dx
		shl	ax,1
		ROUNDUP	dx

		cmp	dx,720
		jb	@F

		xor	dx,dx		;wrap around

@@:		mov	ax,dx

		xor	dx,dx
		mov	bx,20
		div	bx		;(HFine / 64 * 23040 / 32768) / 20

		push	ax		;store reading
		push	dx		;store offset

;* draw heading dots (every 5 degs (10 pixels))

		mov	cx,HUD_X_ORG-20
		sub	cx,dx
		mov	bl,HUD_Y_ORG
		add	bl,BYTE PTR HdgYOff

		mov	dx,7		;draw 7 dots

HdgDotLoop:	cmp	cx,HUD_X_ORG-24	;clip left?
		jb	@F		;yes ->
		cmp	cx,HUD_X_ORG+23	;clip right?
		ja	HdgDigits	;yes ->

		push	bx
		push	cx
		push	dx

		mov	al,COL_HUD
		call	SetPixel

		pop	dx
		pop	cx
		pop	bx

@@:		add	cx,10
		dec	dx
		jnz	HdgDotLoop

;* draw heading digits (every 10 degs (20 pixels))

HdgDigits:	sub	bx,4
		mov	SpriteY,bx

		pop	dx		;restore offset
		pop	bp		;restore reading

		neg	dx
		add	dx,HUD_X_ORG-20-1
		mov	SpriteX,dx

		mov	bx,dx
		and	bx,00001h
		shl	bx,1		;0 or 2 wrt even or odd x offset

		sub	bp,1		;start one value to left of reading
		jnc	@F		;no wrap around ->
		add	bp,36		;wrap

@@:		mov	cx,4		;display 4 values

HdgDigitLoop:	push	cx
		push	bp

		mov	ax,bp

		test	ax,ax		;hdg "00"?
		jnz	@F
		mov	ax,36		;display as "36"

@@:		aam			;ah = msd, al = lsd

;* print msd

		push	ax
		push	bx

;* sprite offset = digit * 4 + (0 or 2 wrt even or odd) + OFFSET HUDDigits

		shl	ah,1		;*2
		shl	ah,1		;*4
		add	bl,ah
		add	bx,OFFSET HUDDigits

		mov	SpritePtr,bx

		mov	si,OFFSET Sprite
		call	SSprite

		pop	bx
		pop	ax

;* print lsd

		add	SpriteX,4

		push	bx

;* sprite offset = digit * 4 + (0 or 2 wrt even or odd) + OFFSET HUDDigits

		shl	al,1		;*2
		shl	al,1		;*4
		add	bl,al
		add	bx,OFFSET HUDDigits

		mov	SpritePtr,bx

		mov	si,OFFSET Sprite
		call	SSprite

		pop	bx

		pop	bp
		pop	cx

		add	SpriteX,20-4
		inc	bp
		cmp	bp,35		;wrap around?
		jbe	@F		;no ->
		mov	bp,0
@@:		loop	HdgDigitLoop

		call	SetHUDClip

;* draw bearing indicator (to next waypoint)

		cmp	WayTotal,0	;any waypoints?
		ja	@F		;yes ->

		cmp	WPPtr,OFFSET FloatWP	;floating waypoint selected?
		jne	SkipBrg			;no ->

@@:		mov	ax,Hdg
		mov	dx,WPBrg
		call	CalcAngDiff

		mov	bp,dx		;store sign

		cmp	ax,14		;limit to 10 degs
		jbe	@F

		mov	ax,14

;* convert 0 .. 14 pdegs to 0 .. 20 pixels (*20/14 = *1.4286)

@@:		mov	dx,46811	;1.4286*32768
		mul	dx
		FRACADJ	cx

		xor	cx,bp		;restore sign
		sub	cx,bp

		add	cx,HUD_X_ORG

		mov	bl,HUD_Y_ORG+2
		add	bl,BYTE PTR HdgYOff

		mov	al,COL_HUD
		push	bx
		push	cx
		call	SetPixel
		pop	cx
		pop	bx

		dec	cx
		inc	bl

		mov	al,COL_HUD
		push	bx
		push	cx
		call	SetPixel
		pop	cx
		pop	bx

		add	cx,2

		mov	al,COL_HUD
		push	bx
		push	cx
		call	SetPixel
		pop	cx
		pop	bx

		inc	cx
		inc	bl

		mov	al,COL_HUD
		push	bx
		push	cx
		call	SetPixel
		pop	cx
		pop	bx

		sub	cx,4

		mov	al,COL_HUD
		call	SetPixel

SkipBrg:	ret

UpdateHdg	ENDP

;----------------------------------------------------------------------------

;* ROTATE - calc rotated x, y offsets for pitch bars
;*
;* pass: x = x offset
;*       y = y offset
;*       xdest = x rotated
;*       ydest = y rotated
;*       M_CosR
;*       M_SinR
;* ret : xdest (*256 scaled)
;*       ydest (*256 scaled)
;* kill: assume all

ROTATE		MACRO	x,y,xdest,ydest

		IF	x EQ 0

;* xdest = M_SinR * y
;* ydest = M_CosR * y

		mov	ax,M_SinR
		mov	dx,y*256	;*256 scaling for accuracy
		imul	dx
		FRACADJ	ax

		ABSV	ax		;ax = abs(x), dx = sign(x)
		mov	cx,ax
		shr	cx,1		;*0.5
		shr	cx,1		;*0.25
		adc	ax,cx		;*1.25 (aspect ratio)
		xor	ax,dx		;restore sign
		sub	ax,dx

		mov	xdest,ax

		mov	ax,M_CosR
		mov	dx,y*256	;*256 scaling for accuracy
		imul	dx
		FRACADJ	dx

		mov	ydest,dx

		ELSEIF	y EQ 0

;* xdest = M_CosR * x
;* ydest = M_SinR * -x

		mov	ax,M_CosR
		mov	dx,x*256	;*256 scaling for accuracy
		imul	dx
		FRACADJ	ax

		ABSV	ax		;ax = abs(x), dx = sign(x)
		mov	cx,ax
		shr	cx,1		;*0.5
		shr	cx,1		;*0.25
		adc	ax,cx		;*1.25 (aspect ratio)
		xor	ax,dx		;restore sign
		sub	ax,dx

		mov	xdest,ax

		mov	ax,M_SinR
		mov	dx,-x*256	;*256 scaling for accuracy
		imul	dx
		FRACADJ	dx

		mov	ydest,dx

		ELSE

;* xdest = M_CosR * x + M_SinR * y
;* ydest = M_CosR * y - M_SinR * x

		mov	ax,M_CosR
		mov	dx,x*256	;*256 scaling for accuracy
		imul	dx
		FRACADJ	bp

		mov	ax,M_SinR
		mov	dx,y*256	;*256 scaling for accuracy
		imul	dx
		FRACADJ	ax

		add	ax,bp

		ABSV	ax		;ax = abs(x), dx = sign(x)
		mov	cx,ax
		shr	cx,1		;*0.5
		shr	cx,1		;*0.25
		adc	ax,cx		;*1.25 (aspect ratio)
		xor	ax,dx		;restore sign
		sub	ax,dx

		mov	xdest,ax

		mov	ax,M_SinR
		mov	dx,x*256	;*256 scaling for accuracy
		imul	dx
		FRACADJ	bp

		mov	ax,M_CosR
		mov	dx,y*256	;*256 scaling for accuracy
		imul	dx
		FRACADJ	dx

		sub	dx,bp

		mov	ydest,dx

		ENDIF

		ENDM

;----------------------------------------------------------------------------

;* REFLECT - draw rhs pitch bar line and reflect to draw lhs line
;*
;* pass: x1, y1, x2, y2 (Px0, Py0 etc.)
;* ret : nothing
;* kill: assume all

REFLECT		MACRO	x1,y1,x2,y2

;* draw rhs line

		mov	cx,x1
		mov	bx,y1
		mov	si,x2
		mov	di,y2

		call	ClipScaledLine

;* draw lhs line

		mov	cx,x1
		mov	bx,y1
		mov	si,x2
		mov	di,y2

		neg	cx		;reflect points
		neg	bx
		neg	si
		neg	di

		call	ClipScaledLine

		ENDM
		
;----------------------------------------------------------------------------

;* UpdatePitch - update pitch bars
;*
;* pass: PFine
;* ret : nothing
;* kill: assume all

UpdatePitch	PROC	NEAR

;---------------------
;* calc rotated points
;---------------------

		ROTATE	 0,-21,  Px0,  Py0
		ROTATE	 8,  0,  Px1,  Py1
		ROTATE	 8,  4,  Px2,  Py2
		ROTATE	10,  0,  Px3,  Py3
		ROTATE	13,  0,  Px4,  Py4
		ROTATE	15,  0,  Px5,  Py5
		ROTATE	18,  0,  Px6,  Py6
		ROTATE	20,  0,  Px7,  Py7
		ROTATE	23,  0,  Px8,  Py8
		ROTATE	25,  0,  Px9,  Py9
		ROTATE	28,  0, Px10, Py10
		ROTATE	21, -4, Px11, Py11
		ROTATE	21,  4, Px12, Py12

;-------------------------------
;* calc pitch bar origin co-ords
;-------------------------------

		mov	ax,PFine
		mov	dx,23040/10
		imul	dx
		FRACADJ	ax		;ax = dx = -9 .. 0 .. +9  [*128]

		mov	bp,ax		;store pitch value

		and	dx,0007fh	;ax = remainder 0 .. 127

		xchg	dl,dh		;*256 gives binary fraction 0 .. 1

		neg	dx		;frac = -frac

;* calc start x offset = Px0 * frac + Px0 * 2

		mov	bx,dx

		mov	ax,Px0
		imul	dx
		FRACADJ	dx		;Px0 * frac

		mov	ax,Px0
		shl	ax,1		;Px0 * 2
		add	ax,dx	   	;Px0 * frac + Px0 * 2

		mov	BarXOff,ax

;* calc start y offset = Py0 * frac + Py0 * 2

		mov	ax,Py0
		imul	bx
		FRACADJ	dx		;Py0 * frac

		mov	ax,Py0
		shl	ax,1		;Py0 * 2
		add	ax,dx		;Py0 * frac + Py0 * 2

		mov	BarYOff,ax

;-----------------
;* draw pitch bars
;-----------------

		REPT	7		;pitch / 128 = -9 .. 0 .. +9
		sar	bp,1
		ENDM

		mov	dx,-1		;count direction

		add	bp,2		;calc value of start bar

		call	LimitPitch

		mov	cx,4		;draw 4 bars
BarLoop: 	push	cx

		push	dx
		push	bp

		test	bp,bp		;draw zero bar?
		jz	Bar0		;yes ->

		cmp	bp,+9		;draw +90 bar?
		je	Bar90		;yes ->

		cmp	bp,-9		;draw -90 bar?
		je	Bar_90		;yes ->

		call	DrawPitchBar
		jmp	NextBar

Bar0:		call	DrawZeroBar
		jmp	NextBar

Bar90:		call	DrawSolidBar
		jmp	NextBar

Bar_90:		call	DrawBrokenBar

NextBar: 	pop	bp
		pop	dx

		add	bp,dx

		call	LimitPitch

		mov	ax,Px0
		sub	BarXOff,ax
		mov	ax,Py0
		sub	BarYOff,ax

		pop	cx
		loop	BarLoop

		ret

UpdatePitch	ENDP

;----------------------------------------------------------------------------

;* LimitPitch - limit pitch value
;*
;* pass: bp = pitch value
;*       dx = count direction
;* ret : bp = pitch value -9 .. 0 .. +9
;*       dx = count direction
;* kill: flags

LimitPitch	PROC	NEAR

		cmp	bp,9		;pitch <= 90 degs?
		jle	@F		;yes ->

		sub	bp,18		;flip pitch 180 degs
		jmp	SortFlip

@@:		cmp	bp,-9		;pitch >= =90 degs?
		jge	@F		;yes ->

		add	bp,18		;flip pitch 180 degs

SortFlip:	neg	bp		;invert sign
		neg	dx		;invert count direction

;* flip points

		neg	Px1
		neg	Py1
		neg	Px2
		neg	Py2
		neg	Px3
		neg	Py3
		neg	Px4
		neg	Py4
		neg	Px5
		neg	Py5
		neg	Px6
		neg	Py6
		neg	Px7
		neg	Py7
		neg	Px8
		neg	Py8
		neg	Px9
		neg	Py9
		neg	Px10
		neg	Py10
		neg	Px11
		neg	Py11
		neg	Px12
		neg	Py12

@@:		ret

LimitPitch	ENDP

;----------------------------------------------------------------------------

;* DrawPitchBar - draw standard pitch bar
;*
;* pass: bp = pitch value -90 .. 0 .. +90
;* ret : nothing
;* kill: assume all

DrawPitchBar	PROC	NEAR

		push	bp		;store pitch value

		test	bp,bp		;+ve pitch?
		jns	PosPitch	;no ->
		jmp	NegPitch

;-----------------
;* +ve pitch value
;-----------------

PosPitch:	call	DrawSolidBar
		call	DrawDownStroke

;* set +ve digit origin

		mov	ax,Px11
		add	ax,BarXOff
		sub	ax,256		;align digits
		xchg	al,ah		;/256
		shl	ah,1		;1/2 bit round up
		adc	al,0
		cbw
		add	ax,HUD_X_ORG
		mov	SpriteX,ax

		mov	ax,Py11
		add	ax,BarYOff
		xchg	al,ah		;/256
		shl	ah,1		;1/2 bit round up
		adc	al,0
		cbw
		add	ax,HUD_Y_ORG
		mov	SpriteY,ax

		pop	bp

		jmp	PrintPitch

;-----------------
;* -ve pitch value
;-----------------

NegPitch:	call	DrawBrokenBar
		call	DrawDownStroke

;* set -ve digit origin

		mov	ax,Px12
		add	ax,BarXOff
		sub	ax,256		;align digits
		xchg	al,ah		;/256
		shl	ah,1		;1/2 bit round up
		adc	al,0
		cbw
		add	ax,HUD_X_ORG
		mov	cx,ax
		mov	SpriteX,ax

		mov	ax,Py12
		add	ax,BarYOff
		xchg	al,ah		;/256
		shl	ah,1		;1/2 bit round up
		adc	al,0
		cbw
		add	ax,HUD_Y_ORG
		mov	bl,al
		mov	SpriteY,ax

;* draw minus sign

		mov	bh,bl

		mov	dx,cx
		sub	cx,6
		sub	dx,4

		call	ClipLine

		pop	bp

		neg	bp

;* print pitch value
;*
;* msd sprite offset = digit * 4 + (0 or 2 wrt even or odd) + OFFSET HUDDigits
;* '0' sprite offset = (0 or 2 wrt even or odd) + OFFSET HUDDigits

PrintPitch:	mov	ax,SpriteX
		and	ax,00001h	;0 or 1 (even or odd)
		shl	ax,1		;0 or 2

		add	ax,OFFSET HUDDigits

		push	ax		;store sprite offset for '0'

		shl	bp,1		;*2
		shl	bp,1		;*4

		add	ax,bp

		mov	SpritePtr,ax

		mov	si,OFFSET Sprite
		call	SSprite

;* print '0'

		pop	ax		;restore sprite offset for '0'

		mov	SpritePtr,ax

		add	SpriteX,4

		mov	si,OFFSET Sprite
		call	SSprite

		ret

DrawPitchBar	ENDP

;----------------------------------------------------------------------------

;* DrawZeroBar - draw zero degrees pitch bar
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

DrawZeroBar	PROC	NEAR

		REFLECT	Px1,Py1,Px10,Py10

		ret

DrawZeroBar	ENDP

;----------------------------------------------------------------------------

;* DrawSolidBar - draw solid pitch bar
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

DrawSolidBar	PROC	NEAR

		REFLECT	Px1,Py1,Px9,Py9

		ret

DrawSolidBar	ENDP

;----------------------------------------------------------------------------

;* DrawBrokenBar - draw broken pitch bar
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

DrawBrokenBar	PROC	NEAR

		REFLECT	Px1,Py1,Px3,Py3
		REFLECT	Px4,Py4,Px5,Py5
		REFLECT	Px6,Py6,Px7,Py7
		REFLECT	Px8,Py8,Px9,Py9

		ret

DrawBrokenBar	ENDP

;----------------------------------------------------------------------------

;* DrawDownStroke - draw pitch bar down stroke
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

DrawDownStroke	PROC	NEAR

		mov	cx,Px1
		mov	bx,Py1
		mov	si,Px2
		mov	di,Py2

		call	ClipScaledLine

		mov	cx,Px1
		mov	bx,Py1
		mov	si,Px2
		mov	di,Py2

		sub	si,cx
		sub	di,bx
		neg	cx
		neg	bx
		add	si,cx
		add	di,bx

		call	ClipScaledLine

		ret

DrawDownStroke	ENDP

;----------------------------------------------------------------------------

;* SetHUDClip - set HUD clipping window
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

SetHUDClip	PROC	NEAR

		mov	bl,BYTE PTR CLIP_ABOVE
		mov	bh,BYTE PTR CLIP_BELOW
		mov	cx,CLIP_LEFT
		mov	dx,CLIP_RIGHT
		call	SetSSpriteClip

		ret

SetHUDClip	ENDP

;----------------------------------------------------------------------------

;* ClipScaledLine - clip scaled line wrt HUD window, draw if totally visible
;*
;* pass: cx = x1 (*256 scaled offset from HUD_X_ORG)
;*       bx = y1 (*256 scaled offset from HUD_Y_ORG)
;*       si = x2 (*256 scaled offset from HUD_X_ORG)
;*       di = y2 (*256 scaled offset from HUD_Y_ORG)
;* ret : nothing
;* kill: assume all

ClipScaledLine	LABEL	NEAR

;* sort y1

		mov	ax,bx
		add	ax,BarYOff
		ABSV	ax
		xchg	al,ah		;/256
		shl	ah,1		;1/2 bit round up
		adc	al,0
		xor	al,dl		;restore sign
		sub	al,dl
		add	al,HUD_Y_ORG
		mov	bl,al

;* sort x1

		mov	ax,cx
		add	ax,BarXOff
		ABSV	ax
		xchg	al,ah		;/256
		shl	ah,1		;1/2 bit round up
		adc	al,0
		xor	ah,ah
		xor	ax,dx		;restore sign
		sub	ax,dx
		add	ax,HUD_X_ORG
		mov	cx,ax

;* sort y2

		mov	ax,di
		add	ax,BarYOff
		ABSV	ax
		xchg	al,ah		;/256
		shl	ah,1		;1/2 bit round up
		adc	al,0
		xor	al,dl		;restore sign
		sub	al,dl
		add	al,HUD_Y_ORG
		mov	bh,al

;* sort x2

		mov	ax,si
		add	ax,BarXOff
		ABSV	ax
		xchg	al,ah		;/256
		shl	ah,1		;1/2 bit round up
		adc	al,0
		xor	ah,ah
		xor	ax,dx		;restore sign
		sub	ax,dx
		add	ax,HUD_X_ORG
		mov	dx,ax

;* ClipLine - clip line wrt HUD window, draw if totally visible
;*
;* pass: cx = x1
;*       bl = y1
;*       dx = x2
;*       bh = y2
;* ret : nothing
;* kill: assume all

ClipLine	PROC	NEAR

		mov	al,BYTE PTR CLIP_ABOVE

		cmp	bl,al		;y1 ok?
		jb	@F		;no ->
		cmp	bh,al		;y2 ok?
		jb	@F		;no ->

		mov	al,BYTE PTR CLIP_BELOW

		cmp	bl,al		;y1 ok?
		ja	@F		;no ->
		cmp	bh,al		;y2 ok?
		ja	@F		;no ->

		cmp	cx,CLIP_LEFT	;x1 ok?
		jb	@F		;no ->
		cmp	dx,CLIP_LEFT	;x2 ok?
		jb	@F		;no ->

		cmp	cx,CLIP_RIGHT	;x1 ok?
		ja	@F		;no ->
		cmp	dx,CLIP_RIGHT	;x2 ok?
		ja	@F		;no ->

		mov	al,COL_HUD
		call	LineDraw

@@:		ret

ClipLine	ENDP

;----------------------------------------------------------------------------

;* UpdateEarlyLate - update time early / late indcator
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all
;*
;* note: If WPTimeEarlyLate = -32768 then invalid. Do not display. 
;*
;*	 If early, the indicator is right of the centre position.
;*	 If late, the indicator is left of the centre position.

UpdateEarlyLate	PROC	NEAR

		cmp	WPTimeEarlyLate,-32768	;invalid?
		je	ExitEarlyLate		;yes ->

		HPIXEL	-59,-27		;30 secs late
		HPIXEL	-47,-27		;on time
		HPIXEL	-35,-27		;30 secs early

;* 2.56 secs / pixel gives approx +/-30 sec range

		mov	ax,WPTimeEarlyLate

		SBOUND	ax,-12*256,12*256

		mov	al,ah
		cbw
		add	ax,HUD_X_ORG-47
		mov	cx,ax

		mov	bl,HUD_Y_ORG-26
		mov	bh,HUD_Y_ORG-24

		mov	al,COL_HUD
		call	VLineDraw

ExitEarlyLate:	ret

UpdateEarlyLate	ENDP

;----------------------------------------------------------------------------

;* UpdateILS - update ILS symbology
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all
;*
;* note: Only call if ILS is active.

UpdateILS	PROC

;------------------------
;* draw HUD centre marker
;------------------------

;* draw down stroke

		HVLINE	-3,-1,0
		HVLINE	 1, 3,0

;* draw cross stroke

		HHLINE	-3,-1,0
		HHLINE	 1, 3,0

;------------------------------------------
;* draw ILS (localizer / glideslope) marker
;------------------------------------------

;* project marker into 64 * 48 (square aspect) rectangle centred on HUD centre

		mov	ax,ILSLocalPos
		mov	dx,-64/2
		imul	dx
		FRACADJ	cx
		add	cx,HUD_X_ORG

		mov	ax,ILSGlidePos
		mov	dx,48/2
		imul	dx
		FRACADJ	bx
		add	bx,HUD_Y_ORG

;* draw down stroke

		push	bx
		push	cx

		mov	bh,bl
		sub	bl,5
		sub	bh,2
		mov	al,COL_HUD
		call	VLineDraw

		pop	cx
		pop	bx

		push	bx
		push	cx

		mov	bh,bl
		add	bl,2
		add	bh,5
		mov	al,COL_HUD
		call	VLineDraw

		pop	cx
		pop	bx

;* draw cross stroke

		push	bx
		push	cx

		mov	dx,cx
		sub	cx,6
		sub	dx,2
		mov	al,COL_HUD
		call	HLineDraw

		pop	cx
		pop	bx

		mov	dx,cx
		add	cx,2
		add	dx,6
		mov	al,COL_HUD
		call	HLineDraw

		ret

UpdateILS	ENDP

;----------------------------------------------------------------------------

;* DrawGndTgtMrkr - draw target marker
;*
;* pass: TGT_VIEW
;* ret : cf = 0 = visible: MarkerX
;*			   MarkerY
;*       cf = 1 = non-visible: MarkerX = -1
;*			       MarkerY = -1
;* kill: assume all (except cf)

DrawGndTgtMrkr	PROC	NEAR

		mov	MarkerX,-1	;assume non-visible
		mov	MarkerY,-1

;----------------------------------
;* project target position onto HUD
;----------------------------------

		mov	si,OFFSET TGT_VIEW
		call	ProjectHUDPoint
		_JC	FailGndTgtMrkr	;non-visible ->

;--------------------
;* clip target marker (crude clip on marker centre)
;--------------------

		cmp	cx,HUD_X_ORG-44
		_JB	FailGndTgtMrkr	;non-visible ->

		cmp	cx,HUD_X_ORG+44
		_JA	FailGndTgtMrkr	;non-visible ->

		cmp	bl,HUD_Y_ORG-40
		jb	FailGndTgtMrkr	;non-visible ->

		cmp	bl,HUD_Y_ORG+40
		ja	FailGndTgtMrkr	;non-visible ->

		mov	MarkerX,cx
		mov	MarkerY,bl

;-------------------
;* draw cross symbol (rotated with horizon)
;-------------------

		mov	Xe[0],-4*128
		mov	Ye[0],0
		mov	Xe[2],-2*128
		mov	Ye[2],0

		call	RotateMrkrLine

		mov	Xe[0],2*128-1
		mov	Ye[0],0
		mov	Xe[2],4*128
		mov	Ye[2],0

		call	RotateMrkrLine

		mov	Xe[0],0
		mov	Ye[0],4*128
		mov	Xe[2],0
		mov	Ye[2],2*128

		call	RotateMrkrLine

		mov	Xe[0],0
		mov	Ye[0],-2*128
		mov	Xe[2],0
		mov	Ye[2],-4*128

		call	RotateMrkrLine

		clc			;visible
		ret

FailGndTgtMrkr:	stc			;non-visible
		ret

DrawGndTgtMrkr	ENDP

;----------------------------------------------------------------------------

;* DrawCCIPMrkr - draw CCIP marker
;*
;* pass: nothing
;* ret : cf = 0 = visible: MarkerX
;*			   MarkerY
;*       cf = 1 = non-visible: MarkerX = -1
;*			       MarkerY = -1
;* kill: assume all (except cf)

DrawCCIPMrkr	PROC	NEAR

		mov	MarkerX,-1	;assume non-visible
		mov	MarkerY,-1

;--------------------------------
;* project CCIP position onto HUD
;--------------------------------

		mov	si,OFFSET CCIP_VIEW
		call	ProjectHUDPoint
		jc	FailCCIPMrkr	;non-visible ->

;------------------
;* clip CCIP marker (crude clip on marker centre)
;------------------

		cmp	cx,HUD_X_ORG-44
		jb	FailCCIPMrkr	;non-visible ->

		cmp	cx,HUD_X_ORG+44
		ja	FailCCIPMrkr	;non-visible ->

		cmp	bl,HUD_Y_ORG-40
		jb	FailCCIPMrkr	;non-visible ->

		cmp	bl,HUD_Y_ORG+40
		ja	FailCCIPMrkr	;non-visible ->

		mov	MarkerX,cx
		mov	MarkerY,bl

;------------------
;* draw CCIP symbol (rotated with horizon)
;------------------

		mov	Xe[0],-3*128
		mov	Ye[0],0
		mov	Xe[2],+3*128
		mov	Ye[2],0

		call	RotateMrkrLine

		clc			;visible
		ret

FailCCIPMrkr:	stc			;non-visible
		ret

DrawCCIPMrkr	ENDP

;----------------------------------------------------------------------------

;* RotateMrkrLine - rotate and draw line
;*
;* pass: MarkerX, MarkerY = marker origin (clipped)
;*	 Xe[0], Ye[0] = end a co-ords (*128 scaled)
;*       Xe[2], Ye[2] = end b co-ords (*128 scaled)
;* ret : nothing
;* kill: assume all
;*
;* note: This routine uses vscreen to rotate a line about the viewport centre.
;*
;*	 The line is then translated to its true origin and drawn.
;*
;*	 Unfortunately vscreen does not provide a translation facility. The
;*       purpose of using vscreen here is simply to rotate the line and add
;*	 aspect ratio correction.
;*
;*       The clipping provided by vscreen is of no use.

RotateMrkrLine	PROC	NEAR

		call	VQuickLineClip	;(always visible)

		mov	cx,XCrt[0]
		mov	bl,YCrt[0]
		mov	dx,XCrt[2]
		mov	bh,YCrt[2]

		sub	cx,HUD_X_ORG
		sub	bl,HUD_Y_ORG
		sub	dx,HUD_X_ORG
		sub	bh,HUD_Y_ORG

		add	cx,MarkerX
		add	bl,MarkerY
		add	dx,MarkerX
		add	bh,MarkerY

		mov	al,COL_HUD
		call	LineDraw

		ret

RotateMrkrLine	ENDP

;----------------------------------------------------------------------------

;* ProjectHUDPoint - project point to HUD
;*
;* pass: M_VIEW
;*	 si -> VIEWPOINT target
;* ret : cf = 0 = visible: cx = x crt
;*                         bl = y crt
;*       cf = 1 = non-visible or error
;* kill: assume all (except bl, cx, cf)
;*
;* note: CalcTransMatrix must be called before calling this routine (in order
;*	 to initialize 'A' factors).
;*
;*	 Assume viewmode is INT_VIEWMODE (HUD is only available in Pilot's
;*	 cockpit).

ProjectHUDPoint	PROC	NEAR

		call	CalcTgtRelCo
		jc	@F		;error ->

		call	CalcEyeCoords

		mov	Xe[0],ax
		mov	Ye[0],bx
		mov	Ze[0],cx

		call	XDotClip

@@:		ret

ProjectHUDPoint	ENDP

;----------------------------------------------------------------------------

;* DrawBombFall - draw bomb fall line
;*
;* pass: MarkerY
;* ret : nothing
;* kill: assume all

DrawBombFall	PROC	NEAR

		cmp	MarkerY,-1	;target marker visible?
		_JE	DrawSolidFall	;no (return via DrawSolidFall) ->

;* sort height margin wrt weapon safety height

		mov	si,PackagePtr

		mov	bx,[si].PACK_WEAP_TYPE

		mov	ax,SafetyHeights[bx]

;* height margin = min(-(safety height - alt) * 4, 8191)

		xor	dx,dx

		sub	ax,WORD PTR M_VIEW.VP_ZFT_LO
		sbb	dx,WORD PTR M_VIEW.VP_ZFT_HI

		REPT	2		;*4
		shl	ax,1
		rcl	dx,1
		ENDM

		NEG32	dx,ax

		js	HtMargOk	;< 0 (no limit on -ve result) ->

		test	dx,dx		;> 65535?
		jnz	@F		;yes ->

		cmp	ax,8191		;> 8191?
		jbe	HtMargOk	;no ->

@@:		mov	ax,8191

HtMargOk: 	mov	dx,ax

;* calc target designator position relative to HUD origin

		mov	al,MarkerY
		xor	ah,ah
		sub	ax,HUD_Y_ORG

		mov	cl,7		;*128

		sal	ax,cl		;convert to vscreen scaling

		neg	ax

;* bomb fall line top = height margin + designator y rel position

		add	ax,dx		;ax = y line top

		mov	bx,ax
		add	bx,-5*128	;bx = y end of upper line section

		mov	cx,bx
		add	cx,-5*128	;cx = y start of lower line section

;* keep bomb fall line out of aircraft symbol

		cmp	ax,-2*128
		jle	@F
		mov	ax,-2*128

@@:		cmp	bx,-2*128
		jle	@F
		mov	bx,-2*128

@@:		cmp	cx,-2*128
		jle	@F
		mov	cx,-2*128

;* draw upper section of bomb fall line

@@: 		push	cx

		mov	Xe[0],0
		mov	Ye[0],ax
		mov	Xe[2],0
		mov	Ye[2],bx

		call	VQuickLineClip
		jc	@F		;non-visible ->

		mov	al,COL_HUD
		mov	cx,XCrt[0]
		mov	bl,YCrt[0]
		mov	dx,XCrt[2]
		mov	bh,YCrt[2]
		call	LineDraw

;* draw lower section of bomb fall line

@@:		pop	cx

		mov	Xe[0],0
		mov	Ye[0],cx
		mov	Xe[2],0
		mov	Ye[2],-8192

		call	VQuickLineClip
		jc	@F		;non-visible ->

		mov	al,COL_HUD
		mov	cx,XCrt[0]
		mov	bl,YCrt[0]
		mov	dx,XCrt[2]
		mov	bh,YCrt[2]
		call	LineDraw

@@:		ret

DrawBombFall	ENDP

;----------------------------------------------------------------------------

;* DrawSolidFall - draw solid bomb fall line
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

DrawSolidFall	PROC	NEAR

		mov	Xe[0],0
		mov	Ye[0],-2*128	;keep out of aircraft symbol
		mov	Xe[2],0
		mov	Ye[2],-8192

		call	VQuickLineClip
		jc	@F		;non-visible ->

		mov	al,COL_HUD
		mov	cx,XCrt[0]
		mov	bl,YCrt[0]
		mov	dx,XCrt[2]
		mov	bh,YCrt[2]
		call	LineDraw

@@:		ret

DrawSolidFall	ENDP

;----------------------------------------------------------------------------

;* CLKCLIP - clip and draw countdown clock pixel
;*
;* pass: cx = x
;*	 bl = y
;* ret : nothing
;* kill: assume all
;*
;* note: Clipping rectangle same as HUD viewport (see VP <> above).

CLKCLIP		MACRO
		LOCAL	_skip

		cmp	cx,HUD_X_ORG-48
		jl	_skip
		cmp	cx,HUD_X_ORG-48+96
		jge	_skip

		cmp	bl,HUD_Y_ORG-44+1
		jl	_skip
		cmp	bl,HUD_Y_ORG-44+1+88
		jge	_skip

		mov	al,COL_HUD
		call	SetPixel

_skip:

		ENDM

;----------------------------------------------------------------------------

;* UpdateClock - draw countdown clock
;*
;* pass: ax = clock value (0 .. 32767)
;*	 cx = x offset from HUD origin
;*       bl = y offset from HUD origin
;* ret : nothing
;* kill: assume all

UpdateClock	PROC	NEAR

;-------------------
;* calc clock origin
;-------------------

		add	cx,HUD_X_ORG
		mov	ClockXOrg,cx

		add	bl,HUD_Y_ORG
		mov	ClockYOrg,bl

;------------------
;* draw centre ring
;------------------

		push	ax

		mov	dx,55
		imul	dx
		FRACADJ	cx

		inc	cx

		mov	si,OFFSET CountClock1

@@:		push	cx

		lodsb			;fetch x offset
		cbw
		add	ax,ClockXOrg
		mov	cx,ax

		lodsb	  		;fetch y offset
		add	al,ClockYOrg
		mov	bl,al

		push	si

		CLKCLIP

		pop	si
		pop	cx

		loop	@B

		pop	ax

;-------------------------
;* draw end of line marker
;-------------------------

;* inner ring

		push	ax

		mov	dx,51
		imul	dx
		FRACADJ	bx

		shl	bx,1		;*2 index

		mov	al,CountClock2[bx]	;fetch x offset
		cbw
		add	ax,ClockXOrg
		mov	cx,ax

		mov	bl,CountClock2[bx+1]	;fetch y offset
		add	bl,ClockYOrg

		CLKCLIP

		pop	ax

;* outer ring

		mov	dx,59
		imul	dx
		FRACADJ	bx

		shl	bx,1		;*2 index

		mov	al,CountClock3[bx]	;fetch x offset
		cbw
		add	ax,ClockXOrg
		mov	cx,ax

		mov	bl,CountClock3[bx+1]	;fetch y offset
		add	bl,ClockYOrg

		CLKCLIP

;------------------------
;* draw 12 o'clock marker
;------------------------

		mov	al,CountClock3[0]	;fetch x offset
		cbw
		add	ax,ClockXOrg
		mov	cx,ax

		mov	bl,CountClock3[1]	;fetch y offset
		add	bl,ClockYOrg

		CLKCLIP

		ret

UpdateClock	ENDP

;----------------------------------------------------------------------------

;* LaserRangeClock - laser range countdown clock
;*
;* pass: LaserActive
;*	 FloatWP
;* ret : nothing
;* kill: assume all

LaserRangeClock	PROC	NEAR

		test	LaserActive,1	;laser active?
		jz	ExitlaserRange	;no ->

		mov	si,OFFSET M_VIEW
		mov	di,OFFSET FloatWP
		call	CalcRngBrgVP_WP

;* limit range to 32767

		test	dx,dx		;range > 65535?
		jnz	@F		;yes ->

		cmp	ax,32767	;range > 32767?
		jbe	LaserRangeOk	;no ->

@@:		mov	ax,32767

LaserRangeOk:	xor	cx,cx
		xor	bl,bl

		call	UpdateClock

ExitLaserRange:	ret

LaserRangeClock	ENDP

;----------------------------------------------------------------------------

;* JP233Clock - JP233 release clock
;*
;* pass: JP233Timer
;* ret : nothing
;* kill: assume all

JP233Clock	PROC	NEAR

;* note: It is not important that the release clock starts at 12 o'clock, 
;*       however, scale JP233Timer to use a decent amount of the available
;*	 resolution. See WEAPONS.ASM for JP233_PERIOD and scale accordingly.

		mov	ax,JP233Timer
		mov	cl,6		;*64
		shl	ax,cl

		xor	cx,cx
		xor	bl,bl

		call	UpdateClock

		ret

JP233Clock	ENDP

;----------------------------------------------------------------------------

;* LoftSteeringCue - steering cue for loft
;*
;* pass: LoftRatio
;* ret : nothing
;* kill: assume all

BASE_LINE_Y	EQU	20
BASE_LINE_WIDTH	EQU	40

LoftSteeringCue	PROC	NEAR

;* hdg error = sbound(WPBrgFine - HFine, -1024, 1024) * 2

		mov	ax,WPBrgFine
		sub	ax,HFine
		SBOUND	ax,-1024,1024
		sal	ax,1

		mov	Xe[0],ax

;* pitch error = (32767 - LoftRatio) / 16 (0 .. 16 * 128)

		mov	ax,32767
		sub	ax,LoftRatio
		REPT	4		;/16
		shr	ax,1
		ENDM
		ROUNDUP	ax

		mov	Ye[0],ax

;* draw steering cue dot

		call	VDotClip
		jc	@F		;non-visible ->

		mov	al,COL_HUD
		push	bx
		push	cx
		call	SetPixel
		pop	cx
		pop	bx

		mov	al,COL_HUD
		push	bx
		push	cx
		dec	cx
		call	SetPixel
		pop	cx
		pop	bx

		mov	al,COL_HUD
		push	bx
		push	cx
		inc	cx
		call	SetPixel
		pop	cx
		pop	bx

		mov	al,COL_HUD
		push	bx
		push	cx
		dec	bl
		call	SetPixel
		pop	cx
		pop	bx

		mov	al,COL_HUD
		push	bx
		push	cx
		inc	bl
		call	SetPixel
		pop	cx
		pop	bx

;* draw centre line (average between base line and dot)

		add	bx,HUD_Y_ORG+BASE_LINE_Y
		mov	ax,bx
		ABSV	ax
		shr	ax,1
		ROUNDUP	ax
		xor	ax,dx
		sub	ax,dx
		mov	bx,ax

		add	cx,HUD_X_ORG
		mov	ax,cx
		ABSV	ax
		shr	ax,1
		ROUNDUP	ax
		xor	ax,dx
		sub	ax,dx
		mov	cx,ax
		mov	dx,ax

		sub	cx,BASE_LINE_WIDTH/4
		add	dx,BASE_LINE_WIDTH/4

		mov	al,COL_HUD
		call	HLineDraw

;* draw base line

@@:		HHLINE	-BASE_LINE_WIDTH/2,BASE_LINE_WIDTH/2,BASE_LINE_Y

		ret

LoftSteeringCue	ENDP

;----------------------------------------------------------------------------

;* TGTCLIP - clip and draw air target pixel
;*
;* pass: cx = x target marker centre
;*	 bl = y target marker centre
;*       x1, y1 (relative to target marker centre)
;* ret : nothing
;* kill: ax, dx, si, di, bp, flags
;*
;* note: Clipping rectangle same as HUD viewport (see VP <> above).

TGTCLIP		MACRO	x1,y1
		LOCAL	_skip

		push	bx
		push	cx

		add	cx,x1
		add	bl,y1

		cmp	cx,HUD_X_ORG-48
		jl	_skip
		cmp	cx,HUD_X_ORG-48+96
		jge	_skip

		cmp	bl,HUD_Y_ORG-44+1
		jl	_skip
		cmp	bl,HUD_Y_ORG-44+1+88
		jge	_skip

		mov	al,COL_HUD
		call	SetPixel

_skip:		pop	cx
		pop	bx

		ENDM

;----------------------------------------------------------------------------

;* DrawAirTarget
;*
;* pass: AirTgtPtr
;* ret : cf = 0 = ok
;*       cf = 1 = invalid target or error
;* kill: assume all

DrawAirTarget	PROC	NEAR

		cmp	AirTgtPtr,-1 	;valid target?
		_JE	FailAirTarget	;no ->

;--------------------------------------
;* calc unclipped CRT co-ords of target
;--------------------------------------

		mov	si,OFFSET M_VIEW
		call	CalcTransMatrix

		mov	si,AirTgtPtr	;si -> MOBILE + VIEWPOINT

		add	si,MOB_REC_SIZE	;si -> VIEWPOINT

		call	CalcTgtRelCo
		_JC	FailAirTarget	;error ->

		call	CalcEyeCoords

		mov	Xe[0],ax
		mov	Ye[0],bx
		mov	Ze[0],cx

		call	XCalcUnclipCRT
		_JC	FailAirTarget	;error ->

;-----------------------------------------
;* hard clip to keep target symbol visible (useful for steering)
;-----------------------------------------

		cmp	cx,HUD_X_ORG-48
		jge	@F
		mov	cx,HUD_X_ORG-48

@@:		cmp	cx,HUD_X_ORG+47
		jle	@F
		mov	cx,HUD_X_ORG+47

@@:		cmp	bx,HUD_Y_ORG-43
		jge	@F
		mov	bx,HUD_Y_ORG-43

@@:		cmp	bx,HUD_Y_ORG+44
		jle	@F
		mov	bx,HUD_Y_ORG+44

;-------------------
;* draw cross symbol
;-------------------

;*              ³ (a)
;*              ³
;*      (c) ÄÄÄÄ ÄÄÄÄ (d)
;*              ³
;*              ³ (b)

;* draw stroke (a)

@@:		push	bx
		push	cx

		sub	bx,2
		cmp	bx,HUD_Y_ORG-43
		jl	SkipA

		mov	ax,bx
		sub	ax,5
		cmp	ax,HUD_Y_ORG-43
		jge	@F
		mov	ax,HUD_Y_ORG-43

@@:		mov	bh,al

		mov	al,COL_HUD
		call	VLineDraw

;* draw stroke (b)

SkipA:		pop	cx
		pop	bx

		push	bx
		push	cx

		add	bx,2
		cmp	bx,HUD_Y_ORG+44
		jg	SkipB

		mov	ax,bx
		add	ax,5
		cmp	ax,HUD_Y_ORG+44
		jle	@F
		mov	ax,HUD_Y_ORG+44

@@:		mov	bh,al

		mov	al,COL_HUD
		call	VLineDraw

;* draw stroke (c)

SkipB:		pop	cx
		pop	bx

		push	bx
		push	cx

		sub	cx,2
		cmp	cx,HUD_X_ORG-48
		jl	SkipC

		mov	dx,cx
		sub	dx,7
		cmp	dx,HUD_X_ORG-48
		jge	@F
		mov	dx,HUD_X_ORG-48

@@:		mov	al,COL_HUD
		call	HLineDraw

;* draw stroke (d)

SkipC:		pop	cx
		pop	bx

		push	bx
		push	cx

		add	cx,2
		cmp	cx,HUD_X_ORG+47
		jg	SkipD

		mov	dx,cx
		add	dx,7
		cmp	dx,HUD_X_ORG+47
		jle	@F
		mov	dx,HUD_X_ORG+47

@@:		mov	al,COL_HUD
		call	HLineDraw

SkipD:		pop	cx
		pop	bx

;-------------------
;* calc range circle (wrt weapon type)
;-------------------

		mov	ax,ArmMode

		cmp	ax,ARM_CANNON
		je	CannonRange

		cmp	ax,ARM_SIDEWINDER
		_JE	SidewinderRange

		cmp	ax,ARM_SKYFLASH
		_JE	SkyFlashRange

		jmp	FailAirTarget	;(should never happen)

;---------------------------
CannonRange	LABEL	NEAR
;---------------------------

;* draw 400m marker

		cmp	WORD PTR AirTgtRange+2,0
		ja	Cont400m
		cmp	WORD PTR AirTgtRange,1192	;1192 = ((20 / 55) * 32768) / 10
		jb	Skip400m

Cont400m:	TGTCLIP	  9,  7
		TGTCLIP	 10,  8

Skip400m:

;* draw 600m marker

		cmp	WORD PTR AirTgtRange+2,0
		ja	Cont600m
		cmp	WORD PTR AirTgtRange,2145	;2145 = ((36 / 55) * 32768) / 10
		jb	Skip600m

Cont600m:	TGTCLIP	 -9,  7
		TGTCLIP	-10,  8

Skip600m:

;* range clock fsd = 3,276ft

		mov	ax,32767	;assume range > fsd

		cmp	WORD PTR AirTgtRange+2,0
		ja	ContAirTarget

		cmp	WORD PTR AirTgtRange,3276
		ja	ContAirTarget

		mov	ax,WORD PTR AirTgtRange

		mov	dx,10
		mul	dx

		jmp	ContAirTarget

;---------------------------
SidewinderRange	LABEL	NEAR
;---------------------------

;* range clock fsd = 32,767ft

		mov	ax,32767	;assume range > fsd

		cmp	WORD PTR AirTgtRange+2,0
		ja	ContAirTarget

		cmp	WORD PTR AirTgtRange,32767
		ja	ContAirTarget

		mov	ax,WORD PTR AirTgtRange

		jmp	ContAirTarget

;---------------------------
SkyFlashRange	LABEL	NEAR
;---------------------------

;* range clock fsd = 131,071ft

		mov	ax,32767	;assume range > fsd

		cmp	WORD PTR AirTgtRange+2,1
		ja	ContAirTarget

		mov	ax,WORD PTR AirTgtRange
		mov	dx,WORD PTR AirTgtRange+2

		REPT	2		;/4
		shr	dx,1
		rcr	ax,1
		ENDM

;---------------------------
ContAirTarget	LABEL	NEAR
;---------------------------

		push	bx
		push	cx

		sub	cx,HUD_X_ORG
		sub	bl,HUD_Y_ORG
		call	UpdateClock

		pop	cx
		pop	bx

;--------------
;* sort IR lock
;--------------

		test	IRLockFlag,1
		_JZ	SkipIRLock

		TGTCLIP	  1, -5
		TGTCLIP	  2, -4
		TGTCLIP	  3, -3
		TGTCLIP	  4, -2
		TGTCLIP	  3, -1
		TGTCLIP	  1,  1
		TGTCLIP	 -1,  1
		TGTCLIP	 -3, -1
		TGTCLIP	 -4, -2
		TGTCLIP	 -3, -3
		TGTCLIP	 -2, -4
		TGTCLIP	 -1, -5

SkipIRLock:	clc			;ok
		ret

FailAirTarget:	stc			;invalid target or error
		ret

DrawAirTarget	ENDP

;----------------------------------------------------------------------------

;* DrawCentreCross - draw small cross at HUD centre (air-to-air modes)
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

DrawCentreCross	PROC	NEAR

;* draw centre cross

		HVLINE	-2,-1, 0
		HVLINE	 1, 2, 0
		HHLINE	-2,-1, 0
		HHLINE	 1, 2, 0

;* if Sidewinder armed but no IR lock then draw diamond around centre cross

		cmp	ArmMode,ARM_SIDEWINDER
		jne	@F

		test	IRLockFlag,1
		jnz	@F

		mov	cx,HUD_X_ORG
		mov	bl,HUD_Y_ORG-4
		mov	dx,HUD_X_ORG+3
		mov	bh,HUD_Y_ORG-1
		mov	al,COL_HUD
		call	LineDraw

		mov	cx,HUD_X_ORG+4
		mov	bl,HUD_Y_ORG
		mov	dx,HUD_X_ORG+1
		mov	bh,HUD_Y_ORG+3
		mov	al,COL_HUD
		call	LineDraw

		mov	cx,HUD_X_ORG
		mov	bl,HUD_Y_ORG+4
		mov	dx,HUD_X_ORG-3
		mov	bh,HUD_Y_ORG+1
		mov	al,COL_HUD
		call	LineDraw

		mov	cx,HUD_X_ORG-4
		mov	bl,HUD_Y_ORG
		mov	dx,HUD_X_ORG-1
		mov	bh,HUD_Y_ORG-3
		mov	al,COL_HUD
		call	LineDraw

@@:		ret

DrawCentreCross	ENDP

;----------------------------------------------------------------------------

;* DrawGndGunClock
;*
;* pass: GndTgtRange
;* ret : nothing
;* kill: assume all

DrawGndGunClock	PROC	NEAR

;* draw 900m marker

		cmp	WORD PTR GndTgtRange+2,0
		ja	Cont900m
		cmp	WORD PTR GndTgtRange,2979	;2979 = ((20 / 55) * 32768) / 4
		jb	Skip900m

Cont900m:	mov	cx,HUD_X_ORG+9
		mov	bl,HUD_Y_ORG+7
		mov	al,COL_HUD
		call	SetPixel

		mov	cx,HUD_X_ORG+10
		mov	bl,HUD_Y_ORG+8
		mov	al,COL_HUD
		call	SetPixel

Skip900m:

;* draw 1500m marker

		cmp	WORD PTR GndTgtRange+2,0
		ja	Cont1500m
		cmp	WORD PTR GndTgtRange,5362	;5362 = ((36 / 55) * 32768) / 4
		jb	Skip1500m

Cont1500m:	mov	cx,HUD_X_ORG-9
		mov	bl,HUD_Y_ORG+7
		mov	al,COL_HUD
		call	SetPixel

		mov	cx,HUD_X_ORG-10
		mov	bl,HUD_Y_ORG+8
		mov	al,COL_HUD
		call	SetPixel

Skip1500m:

;* range clock fsd = 8191ft

		mov	ax,32767	;assume range > fsd

		cmp	WORD PTR GndTgtRange+2,0
		ja	@F

		cmp	WORD PTR GndTgtRange,8191
		ja	@F

		mov	ax,WORD PTR GndTgtRange

		REPT	2		;*4
		shl	ax,1
		ENDM

@@:		xor	cx,cx
		xor	bl,bl
		call	UpdateClock

		ret

DrawGndGunClock	ENDP

;----------------------------------------------------------------------------

;* DrawAlarmClock (ha! ha!)
;*
;* pass: GndTgtRange
;* ret : nothing
;* kill: assume all

DrawAlarmClock	PROC	NEAR

;* range clock fsd = 131,071ft

		mov	ax,32767	;assume range > fsd

		cmp	WORD PTR GndTgtRange+2,1
		ja	@F

		mov	ax,WORD PTR GndTgtRange
		mov	dx,WORD PTR GndTgtRange+2

		REPT	2		;/4
		shr	dx,1
		rcr	ax,1
		ENDM

@@:		xor	cx,cx
		xor	bl,bl
		call	UpdateClock

		ret

DrawAlarmClock	ENDP

;----------------------------------------------------------------------------

;* DrawStandby - draw standby sight
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

DrawStandby	PROC	NEAR

;* centre dot

		mov	cx,HUD_X_ORG
		mov	bl,HUD_Y_ORG
		mov	al,COL_SIGHT
		call	SetPixel

;* up stroke

		mov	cx,HUD_X_ORG
		mov	bl,HUD_Y_ORG-17
		mov	bh,HUD_Y_ORG-6
		mov	al,COL_SIGHT
		call	VLineDraw

		mov	cx,HUD_X_ORG-2
		mov	dx,HUD_X_ORG+2
		mov	bl,HUD_Y_ORG-18
		mov	al,COL_SIGHT
		call	HLineDraw

		mov	cx,HUD_X_ORG-2
		mov	dx,HUD_X_ORG+2
		mov	bl,HUD_Y_ORG-14
		mov	al,COL_SIGHT
		call	HLineDraw

		mov	cx,HUD_X_ORG-3
		mov	dx,HUD_X_ORG+3
		mov	bl,HUD_Y_ORG-10
		mov	al,COL_SIGHT
		call	HLineDraw

		mov	cx,HUD_X_ORG-6
		mov	dx,HUD_X_ORG-4
		mov	bl,HUD_Y_ORG-9
		mov	al,COL_SIGHT
		call	HLineDraw

		mov	cx,HUD_X_ORG+4
		mov	dx,HUD_X_ORG+6
		mov	bl,HUD_Y_ORG-9
		mov	al,COL_SIGHT
		call	HLineDraw

		mov	cx,HUD_X_ORG-7
		mov	bl,HUD_Y_ORG-8
		mov	al,COL_SIGHT
		call	SetPixel

		mov	cx,HUD_X_ORG+7
		mov	bl,HUD_Y_ORG-8
		mov	al,COL_SIGHT
		call	SetPixel

		mov	cx,HUD_X_ORG-2
		mov	dx,HUD_X_ORG+2
		mov	bl,HUD_Y_ORG-5
		mov	al,COL_SIGHT
		call	HLineDraw

		mov	cx,HUD_X_ORG-3
		mov	bl,HUD_Y_ORG-4
		mov	al,COL_SIGHT
		call	SetPixel

		mov	cx,HUD_X_ORG+3
		mov	bl,HUD_Y_ORG-4
		mov	al,COL_SIGHT
		call	SetPixel

;* down stroke

		mov	cx,HUD_X_ORG
		mov	bl,HUD_Y_ORG+17
		mov	bh,HUD_Y_ORG+6
		mov	al,COL_SIGHT
		call	VLineDraw

		mov	cx,HUD_X_ORG-2
		mov	dx,HUD_X_ORG+2
		mov	bl,HUD_Y_ORG+18
		mov	al,COL_SIGHT
		call	HLineDraw

		mov	cx,HUD_X_ORG-2
		mov	dx,HUD_X_ORG+2
		mov	bl,HUD_Y_ORG+14
		mov	al,COL_SIGHT
		call	HLineDraw

		mov	cx,HUD_X_ORG-3
		mov	dx,HUD_X_ORG+3
		mov	bl,HUD_Y_ORG+10
		mov	al,COL_SIGHT
		call	HLineDraw

		mov	cx,HUD_X_ORG-6
		mov	dx,HUD_X_ORG-4
		mov	bl,HUD_Y_ORG+9
		mov	al,COL_SIGHT
		call	HLineDraw

		mov	cx,HUD_X_ORG+4
		mov	dx,HUD_X_ORG+6
		mov	bl,HUD_Y_ORG+9
		mov	al,COL_SIGHT
		call	HLineDraw

		mov	cx,HUD_X_ORG-7
		mov	bl,HUD_Y_ORG+8
		mov	al,COL_SIGHT
		call	SetPixel

		mov	cx,HUD_X_ORG+7
		mov	bl,HUD_Y_ORG+8
		mov	al,COL_SIGHT
		call	SetPixel

		mov	cx,HUD_X_ORG-2
		mov	dx,HUD_X_ORG+2
		mov	bl,HUD_Y_ORG+5
		mov	al,COL_SIGHT
		call	HLineDraw

		mov	cx,HUD_X_ORG-3
		mov	bl,HUD_Y_ORG+4
		mov	al,COL_SIGHT
		call	SetPixel

		mov	cx,HUD_X_ORG+3
		mov	bl,HUD_Y_ORG+4
		mov	al,COL_SIGHT
		call	SetPixel

;* left stroke

		mov	cx,HUD_X_ORG-21
		mov	dx,HUD_X_ORG-7
		mov	bl,HUD_Y_ORG
		mov	al,COL_SIGHT
		call	HLineDraw

		mov	cx,HUD_X_ORG-22
		mov	bl,HUD_Y_ORG-2
		mov	bh,HUD_Y_ORG+2
		mov	al,COL_SIGHT
		call	VLineDraw

		mov	cx,HUD_X_ORG-17
		mov	bl,HUD_Y_ORG-2
		mov	bh,HUD_Y_ORG+2
		mov	al,COL_SIGHT
		call	VLineDraw

		mov	cx,HUD_X_ORG-12
		mov	bl,HUD_Y_ORG-2
		mov	bh,HUD_Y_ORG+2
		mov	al,COL_SIGHT
		call	VLineDraw

		mov	cx,HUD_X_ORG-11
		mov	bl,HUD_Y_ORG-4
		mov	bh,HUD_Y_ORG-3
		mov	al,COL_SIGHT
		call	VLineDraw

		mov	cx,HUD_X_ORG-11
		mov	bl,HUD_Y_ORG+3
		mov	bh,HUD_Y_ORG+4
		mov	al,COL_SIGHT
		call	VLineDraw

		mov	cx,HUD_X_ORG-10
		mov	bl,HUD_Y_ORG-5
		mov	al,COL_SIGHT
		call	SetPixel

		mov	cx,HUD_X_ORG-10
		mov	bl,HUD_Y_ORG+5
		mov	al,COL_SIGHT
		call	SetPixel

		mov	cx,HUD_X_ORG-6
		mov	bl,HUD_Y_ORG-1
		mov	bh,HUD_Y_ORG+1
		mov	al,COL_SIGHT
		call	VLineDraw

		mov	cx,HUD_X_ORG-5
		mov	bl,HUD_Y_ORG-2
		mov	al,COL_SIGHT
		call	SetPixel

		mov	cx,HUD_X_ORG-5
		mov	bl,HUD_Y_ORG+2
		mov	al,COL_SIGHT
		call	SetPixel

;* right stroke

		mov	cx,HUD_X_ORG+21
		mov	dx,HUD_X_ORG+7
		mov	bl,HUD_Y_ORG
		mov	al,COL_SIGHT
		call	HLineDraw

		mov	cx,HUD_X_ORG+22
		mov	bl,HUD_Y_ORG-2
		mov	bh,HUD_Y_ORG+2
		mov	al,COL_SIGHT
		call	VLineDraw

		mov	cx,HUD_X_ORG+17
		mov	bl,HUD_Y_ORG-2
		mov	bh,HUD_Y_ORG+2
		mov	al,COL_SIGHT
		call	VLineDraw

		mov	cx,HUD_X_ORG+12
		mov	bl,HUD_Y_ORG-2
		mov	bh,HUD_Y_ORG+2
		mov	al,COL_SIGHT
		call	VLineDraw

		mov	cx,HUD_X_ORG+11
		mov	bl,HUD_Y_ORG-4
		mov	bh,HUD_Y_ORG-3
		mov	al,COL_SIGHT
		call	VLineDraw

		mov	cx,HUD_X_ORG+11
		mov	bl,HUD_Y_ORG+3
		mov	bh,HUD_Y_ORG+4
		mov	al,COL_SIGHT
		call	VLineDraw

		mov	cx,HUD_X_ORG+10
		mov	bl,HUD_Y_ORG-5
		mov	al,COL_SIGHT
		call	SetPixel

		mov	cx,HUD_X_ORG+10
		mov	bl,HUD_Y_ORG+5
		mov	al,COL_SIGHT
		call	SetPixel

		mov	cx,HUD_X_ORG+6
		mov	bl,HUD_Y_ORG-1
		mov	bh,HUD_Y_ORG+1
		mov	al,COL_SIGHT
		call	VLineDraw

		mov	cx,HUD_X_ORG+5
		mov	bl,HUD_Y_ORG-2
		mov	al,COL_SIGHT
		call	SetPixel

		mov	cx,HUD_X_ORG+5
		mov	bl,HUD_Y_ORG+2
		mov	al,COL_SIGHT
		call	SetPixel

		ret

DrawStandby	ENDP

;----------------------------------------------------------------------------

;* DrawIntercept - draw intercept point (based on cannon shell velocity)
;*
;* pass: AirTgtPtr
;*	 AirTgtRange
;* ret : nothing
;* kill: assume all
;*
;* note: Only call this routine after DrawAirTarget so that CalcTransMatrix
;*       has been called.

DrawIntercept	PROC	NEAR

;* check target valid

		cmp	AirTgtPtr,-1
		_JE	ExitIntercept

		mov	si,AirTgtPtr

;* target speed

		call	GetDroneSpeed

		mov	cx,ax

;* target range

		mov	ax,WORD PTR AirTgtRange
		mov	dx,WORD PTR AirTgtRange+2

;* target viewpoint

		add	si,MOB_REC_SIZE

;* shell velocity

		mov	bx,Vtas
		add	bx,MUZZLE_VELOCITY
		cmp	bx,32767
		jbe	@F
		mov	bx,32767

;* result viewpoint

@@:		mov	di,OFFSET TGT_VIEW

;* calc intercept point

		call	CalcIntercept

;* project intercept point onto HUD

		call	ProjectHUDPoint
		jc	ExitIntercept

;* clip HUD point (crude clip on marker centre)

		cmp	cx,HUD_X_ORG-47
		jb	ExitIntercept

		cmp	cx,HUD_X_ORG+46
		ja	ExitIntercept

		cmp	bl,HUD_Y_ORG-42
		jb	ExitIntercept

		cmp	bl,HUD_Y_ORG+43
		ja	ExitIntercept

;* draw marker

		push	bx
		push	cx
		mov	al,COL_HUD
		call	SetPixel
		pop	cx
		pop	bx

		push	bx
		push	cx
		mov	al,COL_HUD
		inc	cx
		call	SetPixel
		pop	cx
		pop	bx

		push	bx
		push	cx
		mov	al,COL_HUD
		dec	cx
		call	SetPixel
		pop	cx
		pop	bx

		push	bx
		push	cx
		mov	al,COL_HUD
		dec	bl
		call	SetPixel
		pop	cx
		pop	bx

		mov	al,COL_HUD
		inc	bl
		call	SetPixel

ExitIntercept:	ret

DrawIntercept	ENDP

;----------------------------------------------------------------------------

;* DispAirTgtData - display air target data
;*
;* pass: AirTgtPtr
;* ret : nothing
;* kill: assume all

DispAirTgtData	PROC	NEAR

		cmp	AirTgtPtr,-1
		je	@F

		mov	si,OFFSET AirTgt$
		call	Print$

@@:		ret

DispAirTgtData	ENDP

PANCODE		ENDS

;============================================================================

		END

