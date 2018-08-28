;****************************************************************************
;*
;* HUD2.ASM
;*
;* Head Up Display routines.
;*
;* 21.11.1991 - KJB
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<
        PUBLIC HUDSwitch2
		PUBLIC	UpdateHUD2
EXTRN	KF_HUDContrast:BYTE
		PUBLIC	HUDEnabled2
EXTRN	SSF_Engine1:BYTE
EXTRN QuieterCockpit:BYTE
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
		;EXTRN	KF_HUDContrast:BYTE
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

HUDSwitch2	DW	HUDNavigation2	;ARM_OFF
		DW	HUDManualBomb2	;ARM_MANUAL
		DW	HUDLaydownBomb2	;ARM_LAYDOWN
		DW	HUDLoftBomb2	;ARM_LOFT
		DW	HUDLaserGuided2	;ARM_LGB
		DW	HUDJP2332	;ARM_JP233
		DW	HUDAlarmDir2	;ARM_ALARM_DIR
		DW	HUDAlarmInd2	;ARM_ALARM_IND
		DW	HUDCannon2	;ARM_CANNON
		DW	HUDSidewinder2	;ARM_SIDEWINDER
		DW	HUDSkyFlash2	;ARM_SKYFLASH

;-----------
;* HUD flags
;-----------

HUDEnabled2	DB	1		;1 = HUD enabled

MachOption2	DB	0		;1 = display mach num

;--------------------
;* HUD origin equates
;--------------------

HUD_X_FS_ORG	EQU	160
HUD_Y_FS_ORG	EQU	96  ;96 hack - formerly 48;  76 shows up the countdown clock

;----------------------------
;* HUD clipping window limits
;----------------------------

CLIP_ABOVE2	DW	0
CLIP_BELOW2 	DW	0
CLIP_LEFT2	EQU	104
CLIP_RIGHT2	EQU	215

;---------------------------------
;* variable heading strip position (wrt HUD_Y_FS_ORG)
;---------------------------------

HdgYOff2		DW	0

;--------------
;* HUD viewport
;--------------

VP2		VIEWPORT <HUD_X_FS_ORG-48,HUD_Y_FS_ORG-44+1,96,88,0,7>


;-----------------
;* marker position
;-----------------

MarkerX2		DW	0
MarkerY2		DB	0,0

;----------------------------
;* altitude clock bug co-ords (rel offsets from clock centre, one quad only)
;----------------------------

AltBugXY1b	LABEL	BYTE		;outer point

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

AltBugXY2b	LABEL	BYTE		;inner point

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

BarXOff2		DW	0		;x offset of pitch bar being drawn
BarYOff2		DW	0		;y offset of pitch bar being drawn

Px02		DW	0		;delta x between pitch bars
Py02		DW	0		;delta y between pitch bars

;*                                         P11 O (+ve)
;*
;*	     P3	   P4	 P5    P6    P7	   P8	 P9    Py10b
;*   P1	O-----O-----O-----O-----O-----O-----O-----O-----O
;*	|
;*	|
;*	|                                  P12 O (-ve)
;*   P2	O

Px1b		DW	0
Py1b		DW	0
Px2b		DW	0
Py2b		DW	0
Px3b		DW	0
Py3b		DW	0
Px4b		DW	0
Py4b		DW	0
Px5b		DW	0
Py5b		DW	0
Px6b		DW	0
Py6b		DW	0
Px7b		DW	0
Py7b		DW	0
Px8b		DW	0
Py8b		DW	0
Px9b		DW	0
Py9b		DW	0
Px10b		DW	0
Py10b		DW	0
Px11b		DW	0
Py11b		DW	0
Px12b		DW	0
Py12b		DW	0

;-----------------
;* countdown clock
;-----------------

ClockXOrg2	DW	0
ClockYOrg2	DB	0,0

CountClock1b	LABEL	BYTE		;centre ring

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

CountClock2b	LABEL	BYTE		;inner ring

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

CountClock3b	LABEL	BYTE		;outer ring

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

SetUp2$		LABEL	BYTE
		P_OVER1
		P_CHAR2
		PD_ATTR	000h,000h,000h,000h,0aah,000h,COL_HUD,000h
		P_END

;* print barometric altitude "dddd0" (unsigned, 4 digits)

BarAlt2$		LABEL	BYTE
		P_DECAT	00000100b
		PD_X	HUD_X_FS_ORG+36
		PD_Y	HUD_Y_FS_ORG-33
		PV_DECW	DispBarAlt
		DB	'0'
		P_DECAT	00000000b
		P_END

;* print radar altitude "Rdddd" (unsigned, 4 digits)

RadAlt2$		LABEL	BYTE
		P_DECAT	00000100b
		PD_X	HUD_X_FS_ORG+36
		PD_Y	HUD_Y_FS_ORG-33
		DB	'R'
		PV_DECW	TrueRadAlt
		P_DECAT	00000000b
		P_END

;* print Vkts (unsigned, 4 digits)

Vkts2$		LABEL	BYTE
		P_DECAT	00000100b
		PD_X	HUD_X_FS_ORG-56
		PD_Y	HUD_Y_FS_ORG-33
		PV_DECW	Vkts
		P_DECAT	00000000b
		P_END

;* print cannon rounds (unsigned, 3 digits, left justified)

Cannon2$		LABEL	BYTE
		P_DECAT	00010011b
		PD_X	HUD_X_FS_ORG-52
		PD_Y	HUD_Y_FS_ORG+27
		DB	"GUNS"
		PD_X	HUD_X_FS_ORG-52
		PD_Y	HUD_Y_FS_ORG+33
		DB	"x"
		PV_DECW	Cannons
		P_DECAT	00000000b
		P_END

;* print Sidewinder stores (unsigned, 2 digits, left justified)

Sidewinder2$ 	LABEL	BYTE
		P_DECAT	00010010b
		PD_X	HUD_X_FS_ORG-52
		PD_Y	HUD_Y_FS_ORG+27
		DB	"AIM9"
		PD_X	HUD_X_FS_ORG-48
		PD_Y	HUD_Y_FS_ORG+33
		DB	"x"
		PV_DECW	ExtStores[EXT_SIDEWINDER]
		P_DECAT	00000000b
		P_END

;* print SkyFlash stores (unsigned, 2 digits, left justified)

SkyFlash2$ 	LABEL	BYTE
		P_DECAT	00010010b
		PD_X	HUD_X_FS_ORG-52
		PD_Y	HUD_Y_FS_ORG+27
		DB	"SKYF"
		PD_X	HUD_X_FS_ORG-48
		PD_Y	HUD_Y_FS_ORG+33
		DB	"x"
		PV_DECW	ExtStores[EXT_SKYFLASH]
		P_DECAT	00000000b
		P_END

;* print air target data

AirTgt2$		LABEL	BYTE

		P_DECAT	00000010b	;(unsigned, 2 digits, right justified)

		PD_X	HUD_X_FS_ORG+44
		PD_Y	HUD_Y_FS_ORG+21
		PV_DECW	DispAirTgtRng

		PD_X	HUD_X_FS_ORG+44
		PD_Y	HUD_Y_FS_ORG+27
		PV_DECW	DispAirTgtAlt

		P_DECAT	00000011b	;(unsigned, 3 digits, right justified)

		PD_X	HUD_X_FS_ORG+40
		PD_Y	HUD_Y_FS_ORG+33
		PV_DECW	DispAirTgtVel

		PD_X	HUD_X_FS_ORG+40
		PD_Y	HUD_Y_FS_ORG+39
		PV_PDEG	DispAirTgtHdg

		P_DECAT	00000000b
		P_END

		EVEN

DATA		ENDS

;============================================================================

PANCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:PANCODE
		ASSUME DS:DATA

;* HPIXEL2 - set pixel in HUD
;*
;* pass: x1, y1 (relative to HUD origin)
;* ret : nothing
;* kill: assume all

HPIXEL2		MACRO	x1,y1
		
		mov	cx,HUD_X_FS_ORG+x1
		mov	bl,HUD_Y_FS_ORG+y1
		mov	al,COL_HUD
		call	SetPixel

		ENDM

;----------------------------------------------------------------------------

;* HVLINE2 - draw vertical line in HUD
;*
;* pass: y1, y2, x1 (relative to HUD origin)
;* ret : nothing
;* kill: assume all

HVLINE2		MACRO	y1,y2,x1
		
		mov	bl,HUD_Y_FS_ORG+y1
		mov	bh,HUD_Y_FS_ORG+y2
		mov	cx,HUD_X_FS_ORG+x1
		mov	al,COL_HUD
		call	VLineDraw

		ENDM

;----------------------------------------------------------------------------

;* HHLINE2 - draw horizontal line in HUD
;*
;* pass: x1, x2, y1 (relative to HUD origin)
;* ret : nothing
;* kill: assume all

HHLINE2		MACRO	x1,x2,y1
		
		mov	cx,HUD_X_FS_ORG+x1
		mov	dx,HUD_X_FS_ORG+x2
		mov	bl,HUD_Y_FS_ORG+y1
		mov	al,COL_HUD
		call	HLineDraw

		ENDM

;----------------------------------------------------------------------------

;* UpdateHUD2 - draw HUD brackets / update HUD information
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

UpdateHUD2 	PROC	NEAR
call	InitHUD2
;------------------------------------
;* update HUD brackets / canopy frame
;------------------------------------

		test	IronWork,1	;ironwork enabled?
		jz	@F		;no ->
        test	QuieterCockpit,1
		jz	@F		;no ->
		call	DrawHUDBrackets2

		call	UpdateAoAMeter2
;------------------------
;* update HUD information
;------------------------

@@:		;test	SSF_HUD,1	;HUD damaged?
		;_JNZ	ExitHUD2		;yes ->

		call	InitHUD2

		test	HUDEnabled2,1	;HUD enabled?
		_JZ	ExitHUD2		;no ->

		mov	bx,ArmMode

		jmp	HUDSwitch2[bx]

;---------------------------
HUDNavigation2	LABEL	NEAR
;---------------------------

		call	UpdateAoA2
		call	UpdateVSI2
		call	UpdateAltClock2
		call	UpdateAirSpeed2
		call	UpdateHdg2
		call	UpdatePitch2
		call	UpdateEarlyLate2

		test	ILSActive,1	;ILS active?
		jnz	@F		;yes ->

		call	UpdateACSymbol2

		jmp	ContNav2

@@:		call	UpdateILS2

ContNav2:	jmp	ExitHUD2

;---------------------------
HUDManualBomb2	LABEL	NEAR
;---------------------------

		call	UpdateAoA2
		call	UpdateVSI2
		call	UpdateAltClock2
		call	UpdateAirSpeed2
		call	UpdateHdg2
		call	UpdatePitch2
		call	UpdateACSymbol2
		call	UpdateEarlyLate2

		mov	si,OFFSET M_VIEW
		call	CalcTransMatrix

		call	DrawCCIPMrkr2
		call	DrawBombFall2

		jmp	ExitHUD2

;---------------------------
HUDLaydownBomb2	LABEL	NEAR
;---------------------------

		call	UpdateAoA2
		call	UpdateVSI2
		call	UpdateAltClock2
		call	UpdateAirSpeed2
		call	UpdateHdg2
		call	UpdatePitch2
		call	UpdateACSymbol2
		call	UpdateEarlyLate2

		mov	si,OFFSET M_VIEW
		call	CalcTransMatrix

		call	DrawCCIPMrkr2
		call	DrawGndTgtMrkr2
		call	DrawBombFall2

		jmp	ExitHUD2

;---------------------------
HUDLoftBomb2	LABEL	NEAR
;---------------------------

		call	UpdateAoA2
		call	UpdateVSI2
		call	UpdateAltClock2
		call	UpdateAirSpeed2
		call	UpdateHdg2
		call	UpdatePitch2
		call	UpdateACSymbol2
		call	UpdateEarlyLate2

		mov	si,OFFSET M_VIEW
		call	CalcTransMatrix

		call	DrawGndTgtMrkr2

		mov	ax,LoftClock

		cmp	ax,-1		;clock valid?
		je	@F		;no ->

		xor	cx,cx
		xor	bl,bl
		call	UpdateClock2

		cmp	LoftRatio,-1	;ratio valid?
		je	@F		;no ->

		call	LoftSteeringCue2

		jmp	ExitHUD2

@@: 		call	DrawSolidFall2

		jmp	ExitHUD2

;---------------------------
HUDLaserGuided2	LABEL	NEAR
;---------------------------

		call	UpdateAoA2
		call	UpdateVSI2
		call	UpdateAltClock2
		call	UpdateAirSpeed2
		call	UpdateHdg2
		call	UpdatePitch2
		call	UpdateACSymbol2
		call	UpdateEarlyLate2

		call	DrawSolidFall2

		call	LaserRangeClock2

		jmp	ExitHUD2

;---------------------------
HUDJP2332	LABEL	NEAR
;---------------------------

		call	UpdateAoA2
		call	UpdateVSI2
		call	UpdateAltClock2
		call	UpdateAirSpeed2
		call	UpdateHdg2
		call	UpdatePitch2
		call	UpdateACSymbol2
		call	UpdateEarlyLate2

		test	ArmLock,1  	;release in progress?
		jnz	@F	   	;yes ->

;* approaching target

		mov	si,OFFSET M_VIEW
		call	CalcTransMatrix

		call	DrawCCIPMrkr2
		call	DrawGndTgtMrkr2
		call	DrawSolidFall2

		jmp	ExitHUD2

;* release in progress

@@:		call	JP233Clock2

		jmp	ExitHUD2

;---------------------------
HUDAlarmDir2	LABEL	NEAR
;---------------------------

		call	UpdateAoA2
		call	UpdateVSI2
		call	UpdateAltClock2
		call	UpdateAirSpeed2
		call	UpdateHdg2
		call	UpdatePitch2
		call	UpdateEarlyLate2

		call	DrawCentreCross2

		test	RWRTgtValid,1	;target valid?
		jz	@F		;no ->

		mov	si,OFFSET M_VIEW
		call	CalcTransMatrix

		call	DrawGndTgtMrkr2

		call	DrawAlarmClock2

@@:		jmp	ExitHUD2

;---------------------------
HUDAlarmInd2	LABEL	NEAR
;---------------------------

		call	UpdateAoA2
		call	UpdateVSI2
		call	UpdateAltClock2
		call	UpdateAirSpeed2
		call	UpdateHdg2
		call	UpdatePitch2
		call	UpdateEarlyLate2

		call	DrawCentreCross2

		mov	si,OFFSET M_VIEW
		call	CalcTransMatrix

		call	DrawGndTgtMrkr2

		call	DrawAlarmClock2

		jmp	ExitHUD2

;---------------------------
HUDCannon2	LABEL	NEAR
;---------------------------

		call	UpdateAoA2
		call	UpdateAirSpeed2
		call	UpdateHdg2
		call	UpdatePitch2

		mov	si,OFFSET Cannon2$
		call	Print$

		cmp	RadarMode,AIR_RADAR	;air radar on?
		jne	@F			;no ->

;* >>>>> air-to-air mode <<<<<

		call	UpdateAlt2

		call	DrawAirTarget2
		jc	StandbySight2	;invalid target or error ->

		call	DrawIntercept2

		call	DrawCentreCross2

		call	DispAirTgtData2

		jmp	ExitHUD2

;* >>>>> air-to-ground mode <<<<<

@@:		call	UpdateVSI2
		call	UpdateAltClock2
		call	UpdateEarlyLate2

;* check target valid (floating waypoint)

		cmp	WPPtr,OFFSET FloatWP	;floating waypoint selected?
		jne	StandbySight2		;no ->

		mov	si,OFFSET M_VIEW
		call	CalcTransMatrix

		call	DrawGndTgtMrkr2
		jc	StandbySight2	;non-visible ->

		call	DrawCentreCross2

		call	DrawGndGunClock2

		jmp	ExitHUD2

StandbySight2:	call	DrawStandby2

		jmp	ExitHUD2

;---------------------------
HUDSidewinder2	LABEL	NEAR
;---------------------------

		call	UpdateAoA2
		call	UpdateAlt2
		call	UpdateAirSpeed2
		call	UpdateHdg2
		call	UpdatePitch2

		mov	si,OFFSET Sidewinder2$
		call	Print$

		call	DrawCentreCross2

		call	DrawAirTarget2
		jc	@F		;invalid target or error ->

		call	DrawIntercept2

		call	DispAirTgtData2

@@:		jmp	ExitHUD2

;---------------------------
HUDSkyFlash2	LABEL	NEAR
;---------------------------

		call	UpdateAoA2
		call	UpdateAlt2
		call	UpdateAirSpeed2
		call	UpdateHdg2
		call	UpdatePitch2

		mov	si,OFFSET SkyFlash2$
		call	Print$

		call	DrawCentreCross2 

		call	DrawAirTarget2
		jc	ExitHUD2		;invalid target or error ->

		call	DrawIntercept2

		call	DispAirTgtData2

ExitHUD2:	
        ret

UpdateHUD2  	ENDP

;----------------------------------------------------------------------------

;* InitHUD2 - initialize HUD
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

InitHUD2		PROC	NEAR

;------------------------
;* check for HUD on / off
;------------------------

		;mov	al,Key[K_CTRL]
		;and	al,Key[K_O]	;quit?
		KTEST	KF_HUDSwitch
		jz	@F


		KTEST	KF_HUDSwitch
		jz	@F

		xor	HUDEnabled2,1	;toggle on / off

		jnz	InitCont2	;on ->

		jmp	InitDone2

@@:		
        test	HUDEnabled2,1	;HUD enabled?
		jz	InitDone2	;no ->

;----------------------------------
;* check for mach num option toggle
;----------------------------------

		KTEST	KF_HUDOption
		jz	@F

		xor	MachOption2,1	;toggle mach num option

		jmp	InitCont2

;-------------------------------
;* check for HUD contrast change
;-------------------------------

@@:		
        KTEST	KF_HUDContrast
		jz	InitCont2
        mov	SSF_Engine1,1
		mov	al,HUDLevel
		inc	al
		and	al,3
		mov	HUDLevel,al

		call	SetHUDLevel

;-----------------------------------------------------
;* sort heading strip position and HUD clipping window
;-----------------------------------------------------

InitCont2:	cmp	TornadoType,ADV_TORNADO
		je	@F

		mov	HdgYOff2,40
		mov	CLIP_ABOVE2,5+48;5  ;ori=5
		mov	CLIP_BELOW2, 80+48;;HUD_Y_FS_ORG+26;hack ori=80, then HUD_Y_FS_ORG+32
		;+120 if HUD_Y_FS_ORG is 96 hacked success kbs frankie on 26/11/2017
		
		jmp	SetClip2

@@:		mov	HdgYOff2,-38
		mov	CLIP_ABOVE2,16+48  ;hack ori=16, then 16+48
		mov	CLIP_BELOW2,94+48
		;hack ori=94, then 94+48

SetClip2:	call	SetHUDClip2

;-----------------------
;* init print attributes
;-----------------------

		mov	si,OFFSET SetUp2$
		call	Print$

;-------------------
;* init HUD viewport
;-------------------

;* roll with horizon

		mov	ax,RFine
		neg	ax
		mov	cl,7
		shr	ax,cl

		mov	si,OFFSET VP2
		call	VSetViewport
		
InitDone2:	ret

InitHUD2		ENDP

;----------------------------------------------------------------------------

;* DrawHUDBrackets2
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

DrawHUDBrackets2	PROC	NEAR

		call	DrawBrackets

		ret

DrawHUDBrackets2	ENDP

;----------------------------------------------------------------------------

;* UpdateAoAMeter2 - display AoA (angle of attack) on HUD bracket meter
;*
;* pass: DispAlpha
;* ret : nothing
;* kill: assume all
;*
;* note: DispAlpha = -8*16 .. 21*16.

UpdateAoAMeter2	PROC	NEAR

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

		mov	bl,HUD_Y_FS_ORG+44
		mov	bh,bl		;y2 = y1
		sub	bl,al		;y1 = y1 - bar length

		push	bx
		mov	cx,HUD_X_FS_ORG-84
		mov	al,COL_HUD
		call	VLineDraw
		pop	bx

		push	bx
		mov	cx,HUD_X_FS_ORG-83
		mov	al,COL_HUD
		call	VLineDraw
		pop	bx

		mov	cx,HUD_X_FS_ORG-82
		mov	al,COL_HUD
		call	VLineDraw

		ret

UpdateAoAMeter2	ENDP

;---------------------------------------------------------------------------

;* UpdateAoA2 - update AoA (angle of attack) display
;*
;* pass: DispAlpha
;* ret : nothing
;* kill: assume all
;*
;* note: DispAlpha = -8*16 .. 21*16.

UpdateAoA2	PROC	NEAR

;* draw AoA graduations

		HPIXEL2	-56, -15
		HPIXEL2	-54, -15
		HPIXEL2	-54, -10
		HPIXEL2	-56,  -5
		HPIXEL2	-54,  -5
		HPIXEL2	-54,   0
		HPIXEL2	-56,  +5
		HPIXEL2	-54,  +5
		HPIXEL2	-54, +10

;* draw AoA zero line

		HHLINE2	-54, -52, +15

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

		mov	bl,HUD_Y_FS_ORG+15
		mov	bh,bl		;y2 = y1
		sub	bl,al		;y1 = y1 - line length

		mov	cx,HUD_X_FS_ORG-51
		mov	al,COL_HUD
		call	VLineDraw

		ret

UpdateAoA2	ENDP

;----------------------------------------------------------------------------

;* UpdateVSI2 - update Vertical Speed Indicator display
;*
;* pass: DispZdot
;* ret : nothing
;* kill: assume all
;*
;* note: DispZdot *8 scaled.

UpdateVSI2	PROC	NEAR

;* draw VSI graduations

		HPIXEL2	+51, -15
		HPIXEL2	+49, -10
		HPIXEL2	+51, -10
		HPIXEL2	+51,  -5
		HPIXEL2	+51,  +5
		HPIXEL2	+49, +10
		HPIXEL2	+51, +10
		HPIXEL2	+51, +15

;* draw VSI zero line
		
		HPIXEL2	+52,   0
		HPIXEL2	+53,   0

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

		mov	bl,HUD_Y_FS_ORG
		mov	bh,bl		;y2 = y1
		sub	bl,al		;y1 = y1 - line length

		mov	cx,HUD_X_FS_ORG+54
		mov	al,COL_HUD
		call	VLineDraw

		ret

UpdateVSI2	ENDP

;----------------------------------------------------------------------------

;* UpdateAltClock2 - update altitude clock display
;*
;* pass: ZftHi, ZftLo
;*       DispBarAlt
;*       TrueRadAlt
;* ret : nothing
;* kill: assume all
;*
;* note: Assumes ZftHi, ZftLo does not exceed 99,999ft.

UpdateAltClock2	PROC	NEAR

;* draw altitude clock graduations

		HPIXEL2	+45, -42
		HPIXEL2	+53, -40
		HPIXEL2	+58, -35
		HPIXEL2	+58, -27
		HPIXEL2	+53, -22
		HPIXEL2	+45, -20
		HPIXEL2	+37, -22
		HPIXEL2	+32, -27
		HPIXEL2	+32, -35
		HPIXEL2	+37, -40

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

		mov	si,OFFSET RadAlt2$
		call	Print$

		jmp	AltClockBug2

;* print barometric altitude

@@:		push	ZftLo		;store clock bug value
		push	ZftHi

		mov	si,OFFSET BarAlt2$
		call	Print$

;-------------------------
;* calc clock bug position
;-------------------------

;* pos = remainder(alt / 1000) * 2066 / 32768 = 0 .. 63

AltClockBug2:	pop	dx		;restore clock bug value
		pop	ax

		mov	bx,1000
		div	bx		;dx = remainder(zft / 1000)

		mov	ax,2066
		mul	dx
		FRACADJ	ax		;remainder(zft / 1000) * 2066 / 32768

;* select pos

		cmp	ax,48
		jae	BugQuad4b
		cmp	ax,32
		jae	BugQuad3b
		cmp	ax,16
		jae	BugQuad2b

;* case 0 .. 15
;*    index = pos * 2
;*    x sign = 0
;*    y sign = 0

BugQuad1b:	mov	bx,ax
		shl	bx,1		;index = pos * 2
		mov	dx,00000h	;x sign = 0, y sign = 0
		jmp	DrawAltBug2

;* case 16 .. 31
;*    index = (32 - pos) * 2
;*    x sign = 0
;*    y sign = -1

BugQuad2b:	mov	bx,32
		sub	bx,ax
		shl	bx,1		;index = (32 - pos) * 2
		mov	dx,0ff00h	;x sign = 0, y sign = -1
		jmp	DrawAltBug2

;* case 32 .. 47
;*    index = (pos - 32) * 2
;*    x sign = -1
;*    y sign = -1

BugQuad3b:	mov	bx,ax
		sub	bx,32
		shl	bx,1		;index = (pos - 32) * 2
		mov	dx,0ffffh	;x sign = -1, y sign = -1
		jmp	DrawAltBug2

;* case 48 .. 63
;*    index = (64 - pos) * 2
;*    x sign = -1
;*    y sign = 0
;* end

BugQuad4b:	mov	bx,64
		sub	bx,ax
		shl	bx,1		;index = (64 - pos) * 2
		mov	dx,000ffh	;x sign = -1, y sign = 0

DrawAltBug2:	push	bx
		push	dx

		mov	al,AltBugXY1b[bx+0]
		xor	al,dl		;sort x sign
		sub	al,dl
		cbw
		add	ax,HUD_X_FS_ORG+45	;add offset to clock x origin
		mov	cx,ax

		mov	al,AltBugXY1b[bx+1]
		xor	al,dh		;sort y sign
		sub	al,dh
		add	al,HUD_Y_FS_ORG-31	;add offset to clock y origin
		mov	bl,al		

		mov	al,COL_HUD

		call	SetPixel

		pop	dx
		pop	bx

		mov	al,AltBugXY2b[bx+0]
		xor	al,dl		;sort x sign
		sub	al,dl
		cbw
		add	ax,HUD_X_FS_ORG+45	;add offset to clock x origin
		mov	cx,ax

		mov	al,AltBugXY2b[bx+1]
		xor	al,dh		;sort y sign
		sub	al,dh
		add	al,HUD_Y_FS_ORG-31	;add offset to clock y origin
		mov	bl,al

		mov	al,COL_HUD

		call	SetPixel

;* print 'T' if auto-terrain following

		test	TFAuto,1	;auto-terrain following?
		jz	@F		;no ->

		mov	PrtLn,HUD_Y_FS_ORG-27
		mov	PrtCl,HUD_X_FS_ORG+44

		mov	al,'T'
		call	PrintChar

@@:		ret

UpdateAltClock2	ENDP

;----------------------------------------------------------------------------

;* UpdateAlt2 - update altitude display
;*
;* pass: DispBarAlt
;*       TrueRadAlt
;* ret : nothing
;* kill: assume all

UpdateAlt2	PROC	NEAR

;* if TrueRadAlt < 5000 then
;*    print radar altitude "Rdddd"
;* else
;*    print barometric altitude "dddd0" (lsd always zero)
;* end

		mov	si,OFFSET RadAlt2$	;assume disp rad alt

		cmp	TrueRadAlt,5000		;disp rad alt?
		jb	@F			;yes ->

		mov	si,OFFSET BarAlt2$	;disp bar alt

@@:		call	Print$

		ret

UpdateAlt2	ENDP

;----------------------------------------------------------------------------

;* UpdateACSymbol2
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

UpdateACSymbol2	PROC	NEAR

		cmp	TornadoType,ADV_TORNADO	;ADV?
		jne	@F			;no ->

		HVLINE2	-6, -3,  0	;fin (ADV only)

@@:		HHLINE2	-1, +1, -2
		HHLINE2	-1, +1, +2
		HHLINE2	-8, -3,  0
		HHLINE2	+3, +8,  0
		HVLINE2	-1, +1, -2
		HVLINE2	-1, +1, +2

		ret

UpdateACSymbol2	ENDP

;----------------------------------------------------------------------------

;* UpdateAirSpeed2
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

UpdateAirSpeed2	PROC	NEAR

		test	MachOption2,1	;display mach num?
		jnz	@F		;yes ->

;----------------------
;* display airspeed kts
;----------------------

		mov	si,OFFSET Vkts2$
		call	Print$

		jmp	AirSpeedExit2

;------------------
;* display mach num
;------------------

@@:		mov	ax,DispMachNum

		aam			;ah = integer, al = fraction

;* print "d.d"

		mov	PrtLn,HUD_Y_FS_ORG-33
		mov	PrtCl,HUD_X_FS_ORG-52

		add	al,'0'
		add	ah,'0'

		push	ax
		mov	al,ah
		call	PrintChar
		add	PrtCl,4
		pop	ax
		call	PrintChar

		HPIXEL2	-47, -29

AirSpeedExit2:	ret

UpdateAirSpeed2	ENDP

;---------------------------------------------------------------------------

;* UpdateHdg2 - update heading strip
;*
;* pass: HFine
;* ret : nothing
;* kill: assume all

UpdateHdg2	PROC	NEAR

;* set sprite clipping window

		mov	bl,HUD_Y_FS_ORG
		add	bl,BYTE PTR HdgYOff2
		mov	bh,bl
		sub	bl,6
		mov	cx,HUD_X_FS_ORG-24
		mov	dx,HUD_X_FS_ORG+23
		call	SetSSpriteClip

;* draw heading datum marker

		mov	bl,HUD_Y_FS_ORG+1
		add	bl,BYTE PTR HdgYOff2
		mov	bh,bl
		add	bh,3
		mov	cx,HUD_X_FS_ORG
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

		mov	cx,HUD_X_FS_ORG-20
		sub	cx,dx
		mov	bl,HUD_Y_FS_ORG
		add	bl,BYTE PTR HdgYOff2

		mov	dx,7		;draw 7 dots

HdgDotLoop2:	cmp	cx,HUD_X_FS_ORG-24	;clip left?
		jb	@F		;yes ->
		cmp	cx,HUD_X_FS_ORG+23	;clip right?
		ja	HdgDigits2	;yes ->

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
		jnz	HdgDotLoop2

;* draw heading digits (every 10 degs (20 pixels))

HdgDigits2:	sub	bx,4
		mov	SpriteY,bx

		pop	dx		;restore offset
		pop	bp		;restore reading

		neg	dx
		add	dx,HUD_X_FS_ORG-20-1
		mov	SpriteX,dx

		mov	bx,dx
		and	bx,00001h
		shl	bx,1		;0 or 2 wrt even or odd x offset

		sub	bp,1		;start one value to left of reading
		jnc	@F		;no wrap around ->
		add	bp,36		;wrap

@@:		mov	cx,4		;display 4 values

HdgDigitLoop2:	push	cx
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
@@:		loop	HdgDigitLoop2

		call	SetHUDClip2

;* draw bearing indicator (to next waypoint)

		cmp	WayTotal,0	;any waypoints?
		ja	@F		;yes ->

		cmp	WPPtr,OFFSET FloatWP	;floating waypoint selected?
		jne	SkipBrg2			;no ->

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

		add	cx,HUD_X_FS_ORG

		mov	bl,HUD_Y_FS_ORG+2
		add	bl,BYTE PTR HdgYOff2

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

SkipBrg2:	ret

UpdateHdg2	ENDP

;----------------------------------------------------------------------------

;* ROTATE2 - calc rotated x, y offsets for pitch bars
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

ROTATE2		MACRO	x,y,xdest,ydest

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

;* REFLECT2 - draw rhs pitch bar line and reflect to draw lhs line
;*
;* pass: x1, y1, x2, y2 (Px02, Py02 etc.)
;* ret : nothing
;* kill: assume all

REFLECT2		MACRO	x1,y1,x2,y2

;* draw rhs line

		mov	cx,x1
		mov	bx,y1
		mov	si,x2
		mov	di,y2

		call	ClipScaledLine2

;* draw lhs line

		mov	cx,x1
		mov	bx,y1
		mov	si,x2
		mov	di,y2

		neg	cx		;reflect points
		neg	bx
		neg	si
		neg	di

		call	ClipScaledLine2

		ENDM
		
;----------------------------------------------------------------------------

;* UpdatePitch2 - update pitch bars
;*
;* pass: PFine
;* ret : nothing
;* kill: assume all

UpdatePitch2	PROC	NEAR

;---------------------
;* calc rotated points
;---------------------

		ROTATE2	 0,-21,  Px02,  Py02
		ROTATE2	 8,  0,  Px1b,  Py1b
		ROTATE2	 8,  4,  Px2b,  Py2b
		ROTATE2	10,  0,  Px3b,  Py3b
		ROTATE2	13,  0,  Px4b,  Py4b
		ROTATE2	15,  0,  Px5b,  Py5b
		ROTATE2	18,  0,  Px6b,  Py6b
		ROTATE2	20,  0,  Px7b,  Py7b
		ROTATE2	23,  0,  Px8b,  Py8b
		ROTATE2	25,  0,  Px9b,  Py9b
		ROTATE2	28,  0, Px10b, Py10b
		ROTATE2	21, -4, Px11b, Py11b
		ROTATE2	21,  4, Px12b, Py12b

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

;* calc start x offset = Px02 * frac + Px02 * 2

		mov	bx,dx

		mov	ax,Px02
		imul	dx
		FRACADJ	dx		;Px02 * frac

		mov	ax,Px02
		shl	ax,1		;Px02 * 2
		add	ax,dx	   	;Px02 * frac + Px02 * 2

		mov	BarXOff2,ax

;* calc start y offset = Py02 * frac + Py02 * 2

		mov	ax,Py02
		imul	bx
		FRACADJ	dx		;Py02 * frac

		mov	ax,Py02
		shl	ax,1		;Py02 * 2
		add	ax,dx		;Py02 * frac + Py02 * 2

		mov	BarYOff2,ax

;-----------------
;* draw pitch bars
;-----------------

		REPT	7		;pitch / 128 = -9 .. 0 .. +9
		sar	bp,1
		ENDM

		mov	dx,-1		;count direction

		add	bp,2		;calc value of start bar

		call	LimitPitch2

		mov	cx,4		;draw 4 bars
BarLoop2: 	push	cx

		push	dx
		push	bp

		test	bp,bp		;draw zero bar?
		jz	Bar0		;yes ->

		cmp	bp,+9		;draw +90 bar?
		je	Bar90		;yes ->

		cmp	bp,-9		;draw -90 bar?
		je	Bar_90		;yes ->

		call	DrawPitchBar2
		jmp	NextBar2

Bar0:		call	DrawZeroBar2
		jmp	NextBar2

Bar90:		call	DrawSolidBar2
		jmp	NextBar2

Bar_90:		call	DrawBrokenBar2

NextBar2: 	pop	bp
		pop	dx

		add	bp,dx

		call	LimitPitch2

		mov	ax,Px02
		sub	BarXOff2,ax
		mov	ax,Py02
		sub	BarYOff2,ax

		pop	cx
		loop	BarLoop2

		ret

UpdatePitch2	ENDP

;----------------------------------------------------------------------------

;* LimitPitch2 - limit pitch value
;*
;* pass: bp = pitch value
;*       dx = count direction
;* ret : bp = pitch value -9 .. 0 .. +9
;*       dx = count direction
;* kill: flags

LimitPitch2	PROC	NEAR

		cmp	bp,9		;pitch <= 90 degs?
		jle	@F		;yes ->

		sub	bp,18		;flip pitch 180 degs
		jmp	SortFlip2

@@:		cmp	bp,-9		;pitch >= =90 degs?
		jge	@F		;yes ->

		add	bp,18		;flip pitch 180 degs

SortFlip2:	neg	bp		;invert sign
		neg	dx		;invert count direction

;* flip points

		neg	Px1b
		neg	Py1b
		neg	Px2b
		neg	Py2b
		neg	Px3b
		neg	Py3b
		neg	Px4b
		neg	Py4b
		neg	Px5b
		neg	Py5b
		neg	Px6b
		neg	Py6b
		neg	Px7b
		neg	Py7b
		neg	Px8b
		neg	Py8b
		neg	Px9b
		neg	Py9b
		neg	Px10b
		neg	Py10b
		neg	Px11b
		neg	Py11b
		neg	Px12b
		neg	Py12b

@@:		ret

LimitPitch2	ENDP

;----------------------------------------------------------------------------

;* DrawPitchBar2 - draw standard pitch bar
;*
;* pass: bp = pitch value -90 .. 0 .. +90
;* ret : nothing
;* kill: assume all

DrawPitchBar2	PROC	NEAR

		push	bp		;store pitch value

		test	bp,bp		;+ve pitch?
		jns	PosPitch2	;no ->
		jmp	NegPitch2

;-----------------
;* +ve pitch value
;-----------------

PosPitch2:	call	DrawSolidBar2
		call	DrawDownStroke2

;* set +ve digit origin

		mov	ax,Px11b
		add	ax,BarXOff2
		sub	ax,256		;align digits
		xchg	al,ah		;/256
		shl	ah,1		;1/2 bit round up
		adc	al,0
		cbw
		add	ax,HUD_X_FS_ORG
		mov	SpriteX,ax

		mov	ax,Py11b
		add	ax,BarYOff2
		xchg	al,ah		;/256
		shl	ah,1		;1/2 bit round up
		adc	al,0
		cbw
		add	ax,HUD_Y_FS_ORG
		mov	SpriteY,ax

		pop	bp

		jmp	PrintPitch2

;-----------------
;* -ve pitch value
;-----------------

NegPitch2:	call	DrawBrokenBar2
		call	DrawDownStroke2

;* set -ve digit origin

		mov	ax,Px12b
		add	ax,BarXOff2
		sub	ax,256		;align digits
		xchg	al,ah		;/256
		shl	ah,1		;1/2 bit round up
		adc	al,0
		cbw
		add	ax,HUD_X_FS_ORG
		mov	cx,ax
		mov	SpriteX,ax

		mov	ax,Py12b
		add	ax,BarYOff2
		xchg	al,ah		;/256
		shl	ah,1		;1/2 bit round up
		adc	al,0
		cbw
		add	ax,HUD_Y_FS_ORG
		mov	bl,al
		mov	SpriteY,ax

;* draw minus sign

		mov	bh,bl

		mov	dx,cx
		sub	cx,6
		sub	dx,4

		call	ClipLine2

		pop	bp

		neg	bp

;* print pitch value
;*
;* msd sprite offset = digit * 4 + (0 or 2 wrt even or odd) + OFFSET HUDDigits
;* '0' sprite offset = (0 or 2 wrt even or odd) + OFFSET HUDDigits

PrintPitch2:	mov	ax,SpriteX
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

DrawPitchBar2	ENDP

;----------------------------------------------------------------------------

;* DrawZeroBar2 - draw zero degrees pitch bar
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

DrawZeroBar2	PROC	NEAR

		REFLECT2	Px1b,Py1b,Px10b,Py10b

		ret

DrawZeroBar2	ENDP

;----------------------------------------------------------------------------

;* DrawSolidBar2 - draw solid pitch bar
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

DrawSolidBar2	PROC	NEAR

		REFLECT2	Px1b,Py1b,Px9b,Py9b

		ret

DrawSolidBar2	ENDP

;----------------------------------------------------------------------------

;* DrawBrokenBar2 - draw broken pitch bar
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

DrawBrokenBar2	PROC	NEAR

		REFLECT2	Px1b,Py1b,Px3b,Py3b
		REFLECT2	Px4b,Py4b,Px5b,Py5b
		REFLECT2	Px6b,Py6b,Px7b,Py7b
		REFLECT2	Px8b,Py8b,Px9b,Py9b

		ret

DrawBrokenBar2	ENDP

;----------------------------------------------------------------------------

;* DrawDownStroke2 - draw pitch bar down stroke
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

DrawDownStroke2	PROC	NEAR

		mov	cx,Px1b
		mov	bx,Py1b
		mov	si,Px2b
		mov	di,Py2b

		call	ClipScaledLine2

		mov	cx,Px1b
		mov	bx,Py1b
		mov	si,Px2b
		mov	di,Py2b

		sub	si,cx
		sub	di,bx
		neg	cx
		neg	bx
		add	si,cx
		add	di,bx

		call	ClipScaledLine2

		ret

DrawDownStroke2	ENDP

;----------------------------------------------------------------------------

;* SetHUDClip2 - set HUD clipping window
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

SetHUDClip2	PROC	NEAR
		mov	bl,BYTE PTR CLIP_ABOVE2
		mov	bh,BYTE PTR CLIP_BELOW2
		mov	cx,CLIP_LEFT2
		mov	dx,CLIP_RIGHT2
		call	SetSSpriteClip

		ret

SetHUDClip2	ENDP

;----------------------------------------------------------------------------

;* ClipScaledLine2 - clip scaled line wrt HUD window, draw if totally visible
;*
;* pass: cx = x1 (*256 scaled offset from HUD_X_FS_ORG)
;*       bx = y1 (*256 scaled offset from HUD_Y_FS_ORG)
;*       si = x2 (*256 scaled offset from HUD_X_FS_ORG)
;*       di = y2 (*256 scaled offset from HUD_Y_FS_ORG)
;* ret : nothing
;* kill: assume all

ClipScaledLine2	LABEL	NEAR

;* sort y1

		mov	ax,bx
		add	ax,BarYOff2
		ABSV	ax
		xchg	al,ah		;/256
		shl	ah,1		;1/2 bit round up
		adc	al,0
		xor	al,dl		;restore sign
		sub	al,dl
		add	al,HUD_Y_FS_ORG
		mov	bl,al

;* sort x1

		mov	ax,cx
		add	ax,BarXOff2
		ABSV	ax
		xchg	al,ah		;/256
		shl	ah,1		;1/2 bit round up
		adc	al,0
		xor	ah,ah
		xor	ax,dx		;restore sign
		sub	ax,dx
		add	ax,HUD_X_FS_ORG
		mov	cx,ax

;* sort y2

		mov	ax,di
		add	ax,BarYOff2
		ABSV	ax
		xchg	al,ah		;/256
		shl	ah,1		;1/2 bit round up
		adc	al,0
		xor	al,dl		;restore sign
		sub	al,dl
		add	al,HUD_Y_FS_ORG
		mov	bh,al

;* sort x2

		mov	ax,si
		add	ax,BarXOff2
		ABSV	ax
		xchg	al,ah		;/256
		shl	ah,1		;1/2 bit round up
		adc	al,0
		xor	ah,ah
		xor	ax,dx		;restore sign
		sub	ax,dx
		add	ax,HUD_X_FS_ORG
		mov	dx,ax

;* ClipLine2 - clip line wrt HUD window, draw if totally visible
;*
;* pass: cx = x1
;*       bl = y1
;*       dx = x2
;*       bh = y2
;* ret : nothing
;* kill: assume all

ClipLine2	PROC	NEAR

		mov	al,BYTE PTR CLIP_ABOVE2

		cmp	bl,al		;y1 ok?
		jb	@F		;no ->
		cmp	bh,al		;y2 ok?
		jb	@F		;no ->

		mov	al,BYTE PTR CLIP_BELOW2

		cmp	bl,al		;y1 ok?
		ja	@F		;no ->
		cmp	bh,al		;y2 ok?
		ja	@F		;no ->

		cmp	cx,CLIP_LEFT2	;x1 ok?
		jb	@F		;no ->
		cmp	dx,CLIP_LEFT2	;x2 ok?
		jb	@F		;no ->

		cmp	cx,CLIP_RIGHT2	;x1 ok?
		ja	@F		;no ->
		cmp	dx,CLIP_RIGHT2	;x2 ok?
		ja	@F		;no ->

		mov	al,COL_HUD
		call	LineDraw

@@:		ret

ClipLine2	ENDP

;----------------------------------------------------------------------------

;* UpdateEarlyLate2 - update time early / late indcator
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all
;*
;* note: If WPTimeEarlyLate = -32768 then invalid. Do not display. 
;*
;*	 If early, the indicator is right of the centre position.
;*	 If late, the indicator is left of the centre position.

UpdateEarlyLate2	PROC	NEAR

		cmp	WPTimeEarlyLate,-32768	;invalid?
		je	ExitEarlyLate2		;yes ->

		HPIXEL2	-59,-27		;30 secs late
		HPIXEL2	-47,-27		;on time
		HPIXEL2	-35,-27		;30 secs early

;* 2.56 secs / pixel gives approx +/-30 sec range

		mov	ax,WPTimeEarlyLate

		SBOUND	ax,-12*256,12*256

		mov	al,ah
		cbw
		add	ax,HUD_X_FS_ORG-47
		mov	cx,ax

		mov	bl,HUD_Y_FS_ORG-26
		mov	bh,HUD_Y_FS_ORG-24

		mov	al,COL_HUD
		call	VLineDraw

ExitEarlyLate2:	ret

UpdateEarlyLate2	ENDP

;----------------------------------------------------------------------------

;* UpdateILS2 - update ILS symbology
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all
;*
;* note: Only call if ILS is active.

UpdateILS2	PROC

;------------------------
;* draw HUD centre marker
;------------------------

;* draw down stroke

		HVLINE2	-3,-1,0
		HVLINE2	 1, 3,0

;* draw cross stroke

		HHLINE2	-3,-1,0
		HHLINE2	 1, 3,0

;------------------------------------------
;* draw ILS (localizer / glideslope) marker
;------------------------------------------

;* project marker into 64 * 48 (square aspect) rectangle centred on HUD centre

		mov	ax,ILSLocalPos
		mov	dx,-64/2
		imul	dx
		FRACADJ	cx
		add	cx,HUD_X_FS_ORG

		mov	ax,ILSGlidePos
		mov	dx,48/2
		imul	dx
		FRACADJ	bx
		add	bx,HUD_Y_FS_ORG

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

UpdateILS2	ENDP

;----------------------------------------------------------------------------

;* DrawGndTgtMrkr2 - draw target marker
;*
;* pass: TGT_VIEW
;* ret : cf = 0 = visible: MarkerX2
;*			   MarkerY2
;*       cf = 1 = non-visible: MarkerX2 = -1
;*			       MarkerY2 = -1
;* kill: assume all (except cf)

DrawGndTgtMrkr2	PROC	NEAR

		mov	MarkerX2,-1	;assume non-visible
		mov	MarkerY2,-1

;----------------------------------
;* project target position onto HUD
;----------------------------------

		mov	si,OFFSET TGT_VIEW
		call	ProjectHUDPoint2
		_JC	FailGndTgtMrkr2	;non-visible ->

;--------------------
;* clip target marker (crude clip on marker centre)
;--------------------

		cmp	cx,HUD_X_FS_ORG-44
		_JB	FailGndTgtMrkr2	;non-visible ->

		cmp	cx,HUD_X_FS_ORG+44
		_JA	FailGndTgtMrkr2	;non-visible ->

		cmp	bl,HUD_Y_FS_ORG-40-48 ;hack or=-40
		jb	FailGndTgtMrkr2	;non-visible ->

		cmp	bl,HUD_Y_FS_ORG+40-48 ;hack ori=-40
		ja	FailGndTgtMrkr2	;non-visible ->

		mov	MarkerX2,cx
		mov	MarkerY2,bl

;-------------------
;* draw cross symbol (rotated with horizon)
;-------------------

		mov	Xe[0],-4*128
		mov	Ye[0],0
		mov	Xe[2],-2*128
		mov	Ye[2],0

		call	RotateMrkrLine2

		mov	Xe[0],2*128-1
		mov	Ye[0],0
		mov	Xe[2],4*128
		mov	Ye[2],0

		call	RotateMrkrLine2

		mov	Xe[0],0
		mov	Ye[0],4*128
		mov	Xe[2],0
		mov	Ye[2],2*128

		call	RotateMrkrLine2

		mov	Xe[0],0
		mov	Ye[0],-2*128
		mov	Xe[2],0
		mov	Ye[2],-4*128

		call	RotateMrkrLine2

		clc			;visible
		ret

FailGndTgtMrkr2:	stc			;non-visible
		ret

DrawGndTgtMrkr2	ENDP

;----------------------------------------------------------------------------

;* DrawCCIPMrkr2 - draw CCIP marker
;*
;* pass: nothing
;* ret : cf = 0 = visible: MarkerX2
;*			   MarkerY2
;*       cf = 1 = non-visible: MarkerX2 = -1
;*			       MarkerY2 = -1
;* kill: assume all (except cf)

DrawCCIPMrkr2	PROC	NEAR

		mov	MarkerX2,-1	;assume non-visible
		mov	MarkerY2,-1

;--------------------------------
;* project CCIP position onto HUD
;--------------------------------

		mov	si,OFFSET CCIP_VIEW
		call	ProjectHUDPoint2
		jc	FailCCIPMrkr2	;non-visible ->

;------------------
;* clip CCIP marker (crude clip on marker centre)
;------------------

		cmp	cx,HUD_X_FS_ORG-44
		jb	FailCCIPMrkr2	;non-visible ->

		cmp	cx,HUD_X_FS_ORG+44
		ja	FailCCIPMrkr2	;non-visible ->

		cmp	bl,HUD_Y_FS_ORG-40
		jb	FailCCIPMrkr2	;non-visible ->

		cmp	bl,HUD_Y_FS_ORG+40
		ja	FailCCIPMrkr2	;non-visible ->

		mov	MarkerX2,cx
		mov	MarkerY2,bl

;------------------
;* draw CCIP symbol (rotated with horizon)
;------------------

		mov	Xe[0],-3*128
		mov	Ye[0],0
		mov	Xe[2],+3*128
		mov	Ye[2],0

		call	RotateMrkrLine2

		clc			;visible
		ret

FailCCIPMrkr2:	stc			;non-visible
		ret

DrawCCIPMrkr2	ENDP

;----------------------------------------------------------------------------

;* RotateMrkrLine2 - rotate and draw line
;*
;* pass: MarkerX2, MarkerY2 = marker origin (clipped)
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

RotateMrkrLine2	PROC	NEAR

		call	VQuickLineClip	;(always visible)

		mov	cx,XCrt[0]
		mov	bl,YCrt[0]
		mov	dx,XCrt[2]
		mov	bh,YCrt[2]

		sub	cx,HUD_X_FS_ORG
		sub	bl,HUD_Y_FS_ORG-48  ;hack
		;-48 brings down the target marker to the centre; 
		sub	dx,HUD_X_FS_ORG
		sub	bh,HUD_Y_FS_ORG-48  ;hack
		;-48 brings down the target marker to the centre; 

		add	cx,MarkerX2
		add	bl,MarkerY2
		add	dx,MarkerX2
		add	bh,MarkerY2

		mov	al,COL_HUD
		call	LineDraw

		ret

RotateMrkrLine2	ENDP

;----------------------------------------------------------------------------

;* ProjectHUDPoint2 - project point to HUD
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

ProjectHUDPoint2	PROC	NEAR
	
		call	CalcTgtRelCo
		jc	@F		;error ->

		call	CalcEyeCoords

		mov	Xe[0],ax
		mov	Ye[0],bx
		mov	Ze[0],cx

		call	XDotClip

@@:		ret

ProjectHUDPoint2	ENDP

;----------------------------------------------------------------------------

;* DrawBombFall2 - draw bomb fall line
;*
;* pass: MarkerY2
;* ret : nothing
;* kill: assume all

DrawBombFall2	PROC	NEAR

		cmp	MarkerY2,-1	;target marker visible?
		_JE	DrawSolidFall2	;no (return via DrawSolidFall2) ->

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

		js	HtMargOk2	;< 0 (no limit on -ve result) ->

		test	dx,dx		;> 65535?
		jnz	@F		;yes ->

		cmp	ax,8191		;> 8191?
		jbe	HtMargOk2	;no ->

@@:		mov	ax,8191

HtMargOk2: 	mov	dx,ax

;* calc target designator position relative to HUD origin

		mov	al,MarkerY2
		xor	ah,ah
		sub	ax,HUD_Y_FS_ORG

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

DrawBombFall2	ENDP

;----------------------------------------------------------------------------

;* DrawSolidFall2 - draw solid bomb fall line
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

DrawSolidFall2	PROC	NEAR

		mov	Xe[0],0
		mov	Ye[0],-2*128	;keep out of aircraft symbol
		mov	Xe[2],0
		mov	Ye[2],-8192

		call	VQuickLineClip
		jc	@F		;non-visible ->

		mov	al,COL_HUD ;Black
		mov	cx,XCrt[0]
		mov	bl,YCrt[0]
		mov	dx,XCrt[2]
		mov	bh,YCrt[2]
		call	LineDraw

@@:		ret

DrawSolidFall2	ENDP

;----------------------------------------------------------------------------

;* CLKCLIP2 - clip and draw countdown clock pixel
;*
;* pass: cx = x
;*	 bl = y
;* ret : nothing
;* kill: assume all
;*
;* note: Clipping rectangle same as HUD viewport (see VP2 <> above).

CLKCLIP2		MACRO
		LOCAL	_skip

		cmp	cx,HUD_X_FS_ORG-48
		jl	_skip
		cmp	cx,HUD_X_FS_ORG-48+96
		jge	_skip

		;Why was this whole section commented off? hack!
		;cmp	bl,HUD_Y_FS_ORG-44+1   ;<-- hack Frankie 12/12/2017
		;jl	_skip                  ;<-- hack Frankie 12/12/2017
		;cmp	bl,HUD_Y_FS_ORG-44+1+88;<-- hack Frankie 12/12/2017
		;jge	_skip                  ;<-- hack Frankie 12/12/2017

		;add bl,48; hack 22/8/2018
		
		mov	al,COL_HUD;This is the countdown clock! COL_BLACK
		call	SetPixel

_skip:

		ENDM

;----------------------------------------------------------------------------

;* UpdateClock2 - draw countdown clock
;*
;* pass: ax = clock value (0 .. 32767)
;*	 cx = x offset from HUD origin
;*       bl = y offset from HUD origin
;* ret : nothing
;* kill: assume all

UpdateClock2	PROC	NEAR

;-------------------
;* calc clock origin
;-------------------

		add	cx,HUD_X_FS_ORG
		mov	ClockXOrg2,cx

		add	bl,HUD_Y_FS_ORG
		mov	ClockYOrg2,bl

;------------------
;* draw centre ring
;------------------

		push	ax

		mov	dx,55
		imul	dx
		FRACADJ	cx

		inc	cx

		mov	si,OFFSET CountClock1b

@@:		push	cx

		lodsb			;fetch x offset
		cbw
		add	ax,ClockXOrg2
		mov	cx,ax

		lodsb	  		;fetch y offset
		add	al,ClockYOrg2
		mov	bl,al

		push	si

		CLKCLIP2

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

		mov	al,CountClock2b[bx]	;fetch x offset
		cbw
		add	ax,ClockXOrg2
		mov	cx,ax

		mov	bl,CountClock2b[bx+1]	;fetch y offset
		add	bl,ClockYOrg2

		CLKCLIP2

		pop	ax

;* outer ring

		mov	dx,59
		imul	dx
		FRACADJ	bx

		shl	bx,1		;*2 index

		mov	al,CountClock3b[bx]	;fetch x offset
		cbw
		add	ax,ClockXOrg2
		mov	cx,ax

		mov	bl,CountClock3b[bx+1]	;fetch y offset
		add	bl,ClockYOrg2

		CLKCLIP2

;------------------------
;* draw 12 o'clock marker
;------------------------

		mov	al,CountClock3b[0]	;fetch x offset
		cbw
		add	ax,ClockXOrg2
		mov	cx,ax

		mov	bl,CountClock3b[1]	;fetch y offset
		add	bl,ClockYOrg2

		CLKCLIP2

		ret

UpdateClock2	ENDP

;----------------------------------------------------------------------------

;* LaserRangeClock2 - laser range countdown clock
;*
;* pass: LaserActive
;*	 FloatWP
;* ret : nothing
;* kill: assume all

LaserRangeClock2	PROC	NEAR

		test	LaserActive,1	;laser active?
		jz	ExitlaserRange2	;no ->

		mov	si,OFFSET M_VIEW
		mov	di,OFFSET FloatWP
		call	CalcRngBrgVP_WP

;* limit range to 32767

		test	dx,dx		;range > 65535?
		jnz	@F		;yes ->

		cmp	ax,32767	;range > 32767?
		jbe	LaserRangeOk2	;no ->

@@:		mov	ax,32767

LaserRangeOk2:	xor	cx,cx
		xor	bl,bl

		call	UpdateClock2

ExitLaserRange2:	ret

LaserRangeClock2	ENDP

;----------------------------------------------------------------------------

;* JP233Clock2 - JP233 release clock
;*
;* pass: JP233Timer
;* ret : nothing
;* kill: assume all

JP233Clock2	PROC	NEAR

;* note: It is not important that the release clock starts at 12 o'clock, 
;*       however, scale JP233Timer to use a decent amount of the available
;*	 resolution. See WEAPONS.ASM for JP233_PERIOD and scale accordingly.

		mov	ax,JP233Timer
		mov	cl,6		;*64
		shl	ax,cl

		xor	cx,cx
		xor	bl,bl

		call	UpdateClock2

		ret

JP233Clock2	ENDP

;----------------------------------------------------------------------------

;* LoftSteeringCue2 - steering cue for loft
;*
;* pass: LoftRatio
;* ret : nothing
;* kill: assume all

BASE_LINE_Y	EQU	20
BASE_LINE_WIDTH	EQU	40

LoftSteeringCue2	PROC	NEAR

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

		mov	al,COL_HUD ;Black?
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

		add	bx,HUD_Y_FS_ORG+BASE_LINE_Y
		mov	ax,bx
		ABSV	ax
		shr	ax,1
		ROUNDUP	ax
		xor	ax,dx
		sub	ax,dx
		mov	bx,ax

		add	cx,HUD_X_FS_ORG
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

@@:		HHLINE2	-BASE_LINE_WIDTH/2,BASE_LINE_WIDTH/2,BASE_LINE_Y

		ret

LoftSteeringCue2	ENDP

;----------------------------------------------------------------------------

;* TGTCLIP2 - clip and draw air target pixel
;*
;* pass: cx = x target marker centre
;*	 bl = y target marker centre
;*       x1, y1 (relative to target marker centre)
;* ret : nothing
;* kill: ax, dx, si, di, bp, flags
;*
;* note: Clipping rectangle same as HUD viewport (see VP2 <> above).

TGTCLIP2		MACRO	x1,y1
		LOCAL	_skip

		push	bx
		push	cx

		add	cx,x1
		add	bl,y1

		cmp	cx,HUD_X_FS_ORG-48
		jl	_skip
		cmp	cx,HUD_X_FS_ORG-48+96
		jge	_skip

		cmp	bl,HUD_Y_FS_ORG-44+1
		jl	_skip
		cmp	bl,HUD_Y_FS_ORG-44+1+88
		jge	_skip

		add bl,48 ;hack by Frankie Kam on 22/8/2018
		
		mov	al,COL_HUD
		call	SetPixel

_skip:		pop	cx
		pop	bx

		ENDM

;----------------------------------------------------------------------------

;* DrawAirTarget2
;*
;* pass: AirTgtPtr
;* ret : cf = 0 = ok
;*       cf = 1 = invalid target or error
;* kill: assume all

DrawAirTarget2	PROC	NEAR

		cmp	AirTgtPtr,-1 	;valid target?
		_JE	FailAirTarget2	;no ->

;--------------------------------------
;* calc unclipped CRT co-ords of target
;--------------------------------------

		mov	si,OFFSET M_VIEW
		call	CalcTransMatrix

		mov	si,AirTgtPtr	;si -> MOBILE + VIEWPOINT

		add	si,MOB_REC_SIZE	;si -> VIEWPOINT

		call	CalcTgtRelCo
		_JC	FailAirTarget2	;error ->

		call	CalcEyeCoords

		mov	Xe[0],ax
		mov	Ye[0],bx
		mov	Ze[0],cx

		call	XCalcUnclipCRT
		_JC	FailAirTarget2	;error ->

;-----------------------------------------
;* hard clip to keep target symbol visible (useful for steering)
;-----------------------------------------

		cmp	cx,HUD_X_FS_ORG-48
		jge	@F
		mov	cx,HUD_X_FS_ORG-48

@@:		cmp	cx,HUD_X_FS_ORG+47
		jle	@F
		mov	cx,HUD_X_FS_ORG+47

@@:		cmp	bx,48-43;HUD_Y_FS_ORG-43
		jge	@F
		mov	bx,48-43;HUD_Y_FS_ORG-43
         
@@:		cmp	bx,48+44;HUD_Y_FS_ORG+44
		jle	@F
		mov	bx,48+44;HUD_Y_FS_ORG+44
		
;-------------------
;* draw cross symbol
;-------------------

;*              ³ (a)
;*              ³
;*      (c) ÄÄÄÄ ÄÄÄÄ (d)
;*              ³
;*              ³ (b)

;* draw stroke (a)

@@:		add bx, 48
        push	bx
		push	cx

		sub	bx,2
		cmp	bx,HUD_Y_FS_ORG-43
		jl	SkipA2

		mov	ax,bx
		sub	ax,5
		cmp	ax,HUD_Y_FS_ORG-43;+48 ;22/8/2018
		jge	@F
		mov	ax,HUD_Y_FS_ORG-43;+48 ;22/8/2018
        
		;This correctly positions the Cross Symbol
		;48 pixels down the screen
		;when in full-screen mode (Shift+D)		
        ;add ax, 48 ;hack frankie on 22/8/2018
@@:		
        mov	bh,al

		mov	al,COL_HUD ;Black
		call	VLineDraw

;* draw stroke (b)

SkipA2:		pop	cx
		pop	bx

		push	bx
		push	cx

		add	bx,2
		cmp	bx,HUD_Y_FS_ORG+44
		jg	SkipB2

		mov	ax,bx
		add	ax,5
		cmp	ax,HUD_Y_FS_ORG+44;+48 ;22/8/2018
		jle	@F
		mov	ax,HUD_Y_FS_ORG+44;+48 ;22/8/2018
		
		;This correctly positions the Cross Symbol
		;48 pixels down the screen
		;when in full-screen mode (Shift+D)				
		;add ax, 48 ;hack frankie on 22/8/2018
		
@@:		
        mov	bh,al

		mov	al,COL_HUD ;Black
		call	VLineDraw

;* draw stroke (c)

SkipB2:		pop	cx
		pop	bx

		push	bx
		push	cx

		sub	cx,2
		cmp	cx,HUD_X_FS_ORG-48
		jl	SkipC2

		mov	dx,cx
		sub	dx,7
		cmp	dx,HUD_X_FS_ORG-48
		jge	@F
		mov	dx,HUD_X_FS_ORG-48

@@:		mov	al,COL_HUD ;COL_BLACK
		call	HLineDraw

;* draw stroke (d)

SkipC2:		pop	cx
		pop	bx

		push	bx
		push	cx

		add	cx,2
		cmp	cx,HUD_X_FS_ORG+47
		jg	SkipD

		mov	dx,cx
		add	dx,7
		cmp	dx,HUD_X_FS_ORG+47
		jle	@F
		mov	dx,HUD_X_FS_ORG+47

@@:		mov	al,COL_HUD;Black
		call	HLineDraw

SkipD:		pop	cx
		pop	bx

;-------------------
;* calc range circle (wrt weapon type)
;-------------------

		mov	ax,ArmMode

		cmp	ax,ARM_CANNON
		je	CannonRange2

		cmp	ax,ARM_SIDEWINDER
		_JE	SidewinderRange2

		cmp	ax,ARM_SKYFLASH
		_JE	SkyFlashRange2

		jmp	FailAirTarget2	;(should never happen)

;---------------------------
CannonRange2	LABEL	NEAR
;---------------------------

;* draw 400m marker

		cmp	WORD PTR AirTgtRange+2,0
		ja	Cont400m2
		cmp	WORD PTR AirTgtRange,1192	;1192 = ((20 / 55) * 32768) / 10
		jb	Skip400m2

Cont400m2:	TGTCLIP2	  9,  7
		TGTCLIP2	 10,  8

Skip400m2:

;* draw 600m marker

		cmp	WORD PTR AirTgtRange+2,0
		ja	Cont600m2
		cmp	WORD PTR AirTgtRange,2145	;2145 = ((36 / 55) * 32768) / 10
		jb	Skip600m2

Cont600m2:	TGTCLIP2	 -9,  7
		TGTCLIP2	-10,  8

Skip600m2:

;* range clock fsd = 3,276ft

		mov	ax,32767	;assume range > fsd

		cmp	WORD PTR AirTgtRange+2,0
		ja	ContAirTarget2

		cmp	WORD PTR AirTgtRange,3276
		ja	ContAirTarget2

		mov	ax,WORD PTR AirTgtRange

		mov	dx,10
		mul	dx

		jmp	ContAirTarget2

;---------------------------
SidewinderRange2	LABEL	NEAR
;---------------------------

;* range clock fsd = 32,767ft

		mov	ax,32767	;assume range > fsd

		cmp	WORD PTR AirTgtRange+2,0
		ja	ContAirTarget2

		cmp	WORD PTR AirTgtRange,32767
		ja	ContAirTarget2

		mov	ax,WORD PTR AirTgtRange

		jmp	ContAirTarget2

;---------------------------
SkyFlashRange2	LABEL	NEAR
;---------------------------

;* range clock fsd = 131,071ft

		mov	ax,32767	;assume range > fsd

		cmp	WORD PTR AirTgtRange+2,1
		ja	ContAirTarget2

		mov	ax,WORD PTR AirTgtRange
		mov	dx,WORD PTR AirTgtRange+2

		REPT	2		;/4
		shr	dx,1
		rcr	ax,1
		ENDM

;---------------------------
ContAirTarget2	LABEL	NEAR
;---------------------------

		push	bx
		push	cx

		sub	cx,HUD_X_FS_ORG
		sub	bl,HUD_Y_FS_ORG
		call	UpdateClock2

		pop	cx
		pop	bx

;--------------
;* sort IR lock
;--------------

		test	IRLockFlag,1
		_JZ	SkipIRLock2

		TGTCLIP2	  1, -5
		TGTCLIP2	  2, -4
		TGTCLIP2	  3, -3
		TGTCLIP2	  4, -2
		TGTCLIP2	  3, -1
		TGTCLIP2	  1,  1
		TGTCLIP2	 -1,  1
		TGTCLIP2	 -3, -1
		TGTCLIP2	 -4, -2
		TGTCLIP2	 -3, -3
		TGTCLIP2	 -2, -4
		TGTCLIP2	 -1, -5

SkipIRLock2:	clc			;ok
		ret

FailAirTarget2:	stc			;invalid target or error
		ret

DrawAirTarget2	ENDP

;----------------------------------------------------------------------------

;* DrawCentreCross2 - draw small cross at HUD centre (air-to-air modes)
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

DrawCentreCross2	PROC	NEAR

;* draw centre cross

		HVLINE2	-2,-1, 0
		HVLINE2	 1, 2, 0
		HHLINE2	-2,-1, 0
		HHLINE2	 1, 2, 0

;* if Sidewinder armed but no IR lock then draw diamond around centre cross

		cmp	ArmMode,ARM_SIDEWINDER
		jne	@F

		test	IRLockFlag,1
		jnz	@F

		mov	cx,HUD_X_FS_ORG
		mov	bl,HUD_Y_FS_ORG-4
		mov	dx,HUD_X_FS_ORG+3
		mov	bh,HUD_Y_FS_ORG-1
		mov	al,COL_HUD
		call	LineDraw

		mov	cx,HUD_X_FS_ORG+4
		mov	bl,HUD_Y_FS_ORG
		mov	dx,HUD_X_FS_ORG+1
		mov	bh,HUD_Y_FS_ORG+3
		mov	al,COL_HUD
		call	LineDraw

		mov	cx,HUD_X_FS_ORG
		mov	bl,HUD_Y_FS_ORG+4
		mov	dx,HUD_X_FS_ORG-3
		mov	bh,HUD_Y_FS_ORG+1
		mov	al,COL_HUD
		call	LineDraw

		mov	cx,HUD_X_FS_ORG-4
		mov	bl,HUD_Y_FS_ORG
		mov	dx,HUD_X_FS_ORG-1
		mov	bh,HUD_Y_FS_ORG-3
		mov	al,COL_HUD
		call	LineDraw

@@:		ret

DrawCentreCross2	ENDP

;----------------------------------------------------------------------------

;* DrawGndGunClock2
;*
;* pass: GndTgtRange
;* ret : nothing
;* kill: assume all

DrawGndGunClock2	PROC	NEAR

;* draw 900m marker

		cmp	WORD PTR GndTgtRange+2,0
		ja	Cont900m2
		cmp	WORD PTR GndTgtRange,2979	;2979 = ((20 / 55) * 32768) / 4
		jb	Skip900m2

Cont900m2:	mov	cx,HUD_X_FS_ORG+9
		mov	bl,HUD_Y_FS_ORG+7
		mov	al,COL_HUD
		call	SetPixel

		mov	cx,HUD_X_FS_ORG+10
		mov	bl,HUD_Y_FS_ORG+8
		mov	al,COL_HUD
		call	SetPixel

Skip900m2:

;* draw 1500m marker

		cmp	WORD PTR GndTgtRange+2,0
		ja	Cont1500m2
		cmp	WORD PTR GndTgtRange,5362	;5362 = ((36 / 55) * 32768) / 4
		jb	Skip1500m2

Cont1500m2:	mov	cx,HUD_X_FS_ORG-9
		mov	bl,HUD_Y_FS_ORG+7
		mov	al,COL_HUD
		call	SetPixel

		mov	cx,HUD_X_FS_ORG-10
		mov	bl,HUD_Y_FS_ORG+8
		mov	al,COL_HUD
		call	SetPixel

Skip1500m2:

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
		call	UpdateClock2

		ret

DrawGndGunClock2	ENDP

;----------------------------------------------------------------------------

;* DrawAlarmClock2 (ha! ha!)
;*
;* pass: GndTgtRange
;* ret : nothing
;* kill: assume all

DrawAlarmClock2	PROC	NEAR

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
		call	UpdateClock2

		ret

DrawAlarmClock2	ENDP

;----------------------------------------------------------------------------

;* DrawStandby2 - draw standby sight
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

DrawStandby2	PROC	NEAR

;* centre dot

		mov	cx,HUD_X_FS_ORG
		mov	bl,HUD_Y_FS_ORG
		mov	al,COL_SIGHT
		call	SetPixel

;* up stroke

		mov	cx,HUD_X_FS_ORG
		mov	bl,HUD_Y_FS_ORG-17
		mov	bh,HUD_Y_FS_ORG-6
		mov	al,COL_SIGHT
		call	VLineDraw

		mov	cx,HUD_X_FS_ORG-2
		mov	dx,HUD_X_FS_ORG+2
		mov	bl,HUD_Y_FS_ORG-18
		mov	al,COL_SIGHT
		call	HLineDraw

		mov	cx,HUD_X_FS_ORG-2
		mov	dx,HUD_X_FS_ORG+2
		mov	bl,HUD_Y_FS_ORG-14
		mov	al,COL_SIGHT
		call	HLineDraw

		mov	cx,HUD_X_FS_ORG-3
		mov	dx,HUD_X_FS_ORG+3
		mov	bl,HUD_Y_FS_ORG-10
		mov	al,COL_SIGHT
		call	HLineDraw

		mov	cx,HUD_X_FS_ORG-6
		mov	dx,HUD_X_FS_ORG-4
		mov	bl,HUD_Y_FS_ORG-9
		mov	al,COL_SIGHT
		call	HLineDraw

		mov	cx,HUD_X_FS_ORG+4
		mov	dx,HUD_X_FS_ORG+6
		mov	bl,HUD_Y_FS_ORG-9
		mov	al,COL_SIGHT
		call	HLineDraw

		mov	cx,HUD_X_FS_ORG-7
		mov	bl,HUD_Y_FS_ORG-8
		mov	al,COL_SIGHT
		call	SetPixel

		mov	cx,HUD_X_FS_ORG+7
		mov	bl,HUD_Y_FS_ORG-8
		mov	al,COL_SIGHT
		call	SetPixel

		mov	cx,HUD_X_FS_ORG-2
		mov	dx,HUD_X_FS_ORG+2
		mov	bl,HUD_Y_FS_ORG-5
		mov	al,COL_SIGHT
		call	HLineDraw

		mov	cx,HUD_X_FS_ORG-3
		mov	bl,HUD_Y_FS_ORG-4
		mov	al,COL_SIGHT
		call	SetPixel

		mov	cx,HUD_X_FS_ORG+3
		mov	bl,HUD_Y_FS_ORG-4
		mov	al,COL_SIGHT
		call	SetPixel

;* down stroke

		mov	cx,HUD_X_FS_ORG
		mov	bl,HUD_Y_FS_ORG+17
		mov	bh,HUD_Y_FS_ORG+6
		mov	al,COL_SIGHT
		call	VLineDraw

		mov	cx,HUD_X_FS_ORG-2
		mov	dx,HUD_X_FS_ORG+2
		mov	bl,HUD_Y_FS_ORG+18
		mov	al,COL_SIGHT
		call	HLineDraw

		mov	cx,HUD_X_FS_ORG-2
		mov	dx,HUD_X_FS_ORG+2
		mov	bl,HUD_Y_FS_ORG+14
		mov	al,COL_SIGHT
		call	HLineDraw

		mov	cx,HUD_X_FS_ORG-3
		mov	dx,HUD_X_FS_ORG+3
		mov	bl,HUD_Y_FS_ORG+10
		mov	al,COL_SIGHT
		call	HLineDraw

		mov	cx,HUD_X_FS_ORG-6
		mov	dx,HUD_X_FS_ORG-4
		mov	bl,HUD_Y_FS_ORG+9
		mov	al,COL_SIGHT
		call	HLineDraw

		mov	cx,HUD_X_FS_ORG+4
		mov	dx,HUD_X_FS_ORG+6
		mov	bl,HUD_Y_FS_ORG+9
		mov	al,COL_SIGHT
		call	HLineDraw

		mov	cx,HUD_X_FS_ORG-7
		mov	bl,HUD_Y_FS_ORG+8
		mov	al,COL_SIGHT
		call	SetPixel

		mov	cx,HUD_X_FS_ORG+7
		mov	bl,HUD_Y_FS_ORG+8
		mov	al,COL_SIGHT
		call	SetPixel

		mov	cx,HUD_X_FS_ORG-2
		mov	dx,HUD_X_FS_ORG+2
		mov	bl,HUD_Y_FS_ORG+5
		mov	al,COL_SIGHT
		call	HLineDraw

		mov	cx,HUD_X_FS_ORG-3
		mov	bl,HUD_Y_FS_ORG+4
		mov	al,COL_SIGHT
		call	SetPixel

		mov	cx,HUD_X_FS_ORG+3
		mov	bl,HUD_Y_FS_ORG+4
		mov	al,COL_SIGHT
		call	SetPixel

;* left stroke

		mov	cx,HUD_X_FS_ORG-21
		mov	dx,HUD_X_FS_ORG-7
		mov	bl,HUD_Y_FS_ORG
		mov	al,COL_SIGHT
		call	HLineDraw

		mov	cx,HUD_X_FS_ORG-22
		mov	bl,HUD_Y_FS_ORG-2
		mov	bh,HUD_Y_FS_ORG+2
		mov	al,COL_SIGHT
		call	VLineDraw

		mov	cx,HUD_X_FS_ORG-17
		mov	bl,HUD_Y_FS_ORG-2
		mov	bh,HUD_Y_FS_ORG+2
		mov	al,COL_SIGHT
		call	VLineDraw

		mov	cx,HUD_X_FS_ORG-12
		mov	bl,HUD_Y_FS_ORG-2
		mov	bh,HUD_Y_FS_ORG+2
		mov	al,COL_SIGHT
		call	VLineDraw

		mov	cx,HUD_X_FS_ORG-11
		mov	bl,HUD_Y_FS_ORG-4
		mov	bh,HUD_Y_FS_ORG-3
		mov	al,COL_SIGHT
		call	VLineDraw

		mov	cx,HUD_X_FS_ORG-11
		mov	bl,HUD_Y_FS_ORG+3
		mov	bh,HUD_Y_FS_ORG+4
		mov	al,COL_SIGHT
		call	VLineDraw

		mov	cx,HUD_X_FS_ORG-10
		mov	bl,HUD_Y_FS_ORG-5
		mov	al,COL_SIGHT
		call	SetPixel

		mov	cx,HUD_X_FS_ORG-10
		mov	bl,HUD_Y_FS_ORG+5
		mov	al,COL_SIGHT
		call	SetPixel

		mov	cx,HUD_X_FS_ORG-6
		mov	bl,HUD_Y_FS_ORG-1
		mov	bh,HUD_Y_FS_ORG+1
		mov	al,COL_SIGHT
		call	VLineDraw

		mov	cx,HUD_X_FS_ORG-5
		mov	bl,HUD_Y_FS_ORG-2
		mov	al,COL_SIGHT
		call	SetPixel

		mov	cx,HUD_X_FS_ORG-5
		mov	bl,HUD_Y_FS_ORG+2
		mov	al,COL_SIGHT
		call	SetPixel

;* right stroke

		mov	cx,HUD_X_FS_ORG+21
		mov	dx,HUD_X_FS_ORG+7
		mov	bl,HUD_Y_FS_ORG
		mov	al,COL_SIGHT
		call	HLineDraw

		mov	cx,HUD_X_FS_ORG+22
		mov	bl,HUD_Y_FS_ORG-2
		mov	bh,HUD_Y_FS_ORG+2
		mov	al,COL_SIGHT
		call	VLineDraw

		mov	cx,HUD_X_FS_ORG+17
		mov	bl,HUD_Y_FS_ORG-2
		mov	bh,HUD_Y_FS_ORG+2
		mov	al,COL_SIGHT
		call	VLineDraw

		mov	cx,HUD_X_FS_ORG+12
		mov	bl,HUD_Y_FS_ORG-2
		mov	bh,HUD_Y_FS_ORG+2
		mov	al,COL_SIGHT
		call	VLineDraw

		mov	cx,HUD_X_FS_ORG+11
		mov	bl,HUD_Y_FS_ORG-4
		mov	bh,HUD_Y_FS_ORG-3
		mov	al,COL_SIGHT
		call	VLineDraw

		mov	cx,HUD_X_FS_ORG+11
		mov	bl,HUD_Y_FS_ORG+3
		mov	bh,HUD_Y_FS_ORG+4
		mov	al,COL_SIGHT
		call	VLineDraw

		mov	cx,HUD_X_FS_ORG+10
		mov	bl,HUD_Y_FS_ORG-5
		mov	al,COL_SIGHT
		call	SetPixel

		mov	cx,HUD_X_FS_ORG+10
		mov	bl,HUD_Y_FS_ORG+5
		mov	al,COL_SIGHT
		call	SetPixel

		mov	cx,HUD_X_FS_ORG+6
		mov	bl,HUD_Y_FS_ORG-1
		mov	bh,HUD_Y_FS_ORG+1
		mov	al,COL_SIGHT
		call	VLineDraw

		mov	cx,HUD_X_FS_ORG+5
		mov	bl,HUD_Y_FS_ORG-2
		mov	al,COL_SIGHT
		call	SetPixel

		mov	cx,HUD_X_FS_ORG+5
		mov	bl,HUD_Y_FS_ORG+2
		mov	al,COL_SIGHT
		call	SetPixel

		ret

DrawStandby2	ENDP

;----------------------------------------------------------------------------

;* DrawIntercept2 - draw intercept point (based on cannon shell velocity)
;*
;* pass: AirTgtPtr
;*	 AirTgtRange
;* ret : nothing
;* kill: assume all
;*
;* note: Only call this routine after DrawAirTarget2 so that CalcTransMatrix
;*       has been called.

DrawIntercept2	PROC	NEAR

;* check target valid

		cmp	AirTgtPtr,-1
		_JE	ExitIntercept2

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

		call	ProjectHUDPoint2
		jc	ExitIntercept2

;* clip HUD point (crude clip on marker centre)

		cmp	cx,HUD_X_FS_ORG-47
		jb	ExitIntercept2

		cmp	cx,HUD_X_FS_ORG+46
		ja	ExitIntercept2

		cmp	bl,48-42;+48 ;22/8/2018
		jb	ExitIntercept2

		cmp	bl,48+43;+48 ;22/8/2018
		ja	ExitIntercept2
 
        ;This correctly positions the Intercept Point
		;48 pixels down the screen where bl = y crt
		;when in full-screen mode (Shift+D)
        add bl,48 ;hack by Frankie 22/8/2018
		
;* draw marker

		push	bx
		push	cx
		mov	al,COL_HUD ;Black
		call	SetPixel
		pop	cx
		pop	bx

		push	bx
		push	cx
		mov	al,COL_HUD ;Black
		inc	cx
		call	SetPixel
		pop	cx
		pop	bx

		push	bx
		push	cx
		mov	al,COL_HUD ;COL_BLACK
		dec	cx
		call	SetPixel
		pop	cx
		pop	bx

		push	bx
		push	cx
		mov	al,COL_HUD ;BLACK
		dec	bl
		call	SetPixel
		pop	cx
		pop	bx

		mov	al,COL_HUD ;Black
		inc	bl
		call	SetPixel

ExitIntercept2:	ret

DrawIntercept2	ENDP

;----------------------------------------------------------------------------

;* DispAirTgtData2 - display air target data
;*
;* pass: AirTgtPtr
;* ret : nothing
;* kill: assume all

DispAirTgtData2	PROC	NEAR

		cmp	AirTgtPtr,-1
		je	@F

		mov	si,OFFSET AirTgt2$
		call	Print$

@@:		ret

DispAirTgtData2	ENDP


PANCODE		ENDS

;============================================================================

		END

