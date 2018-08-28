;****************************************************************************
;*
;* EXTRNPAN.ASM
;*
;* External panel driver.
;*
;* 10.12.1991 - KJB
;* 13.04.1992 - KJB - External panel modified for VIEW_MAP.
;* 24.06.1992 - KJB - External panel modified for VIEW_DRONE.
;* 26.06.1992 - KJB - External panel modified for VIEW_SPECTATOR.
;* 08.07.1992 - KJB - External panel modified for VIEW_REMOTE.
;* 13.08.1992 - KJB - "VIEW = DRONE" change text colour wrt side.
;* 18.08.1992 - KJB - Text palette switching wrt view mode.
;* 27.09.1992 - KJB - External panel modified for VIEW_DEMO.
;* 14.11.1992 - KJB - External panel modified for VIEW_DESTROYED.
;* 21.11.1992 - KJB - External panel modified for VIEW_WEAPON.
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	LoadExtrnPan
		PUBLIC	UpdateExtrn

		EXTRN	BlockFill:FAR
		EXTRN	Print$:FAR

		EXTRN	Vkts:WORD
		EXTRN	DispBarAlt:WORD
		EXTRN	TrueRadAlt:WORD
		EXTRN	DispHdg:WORD
		EXTRN	DispVSI:WORD
		EXTRN	FuelWt:WORD
		EXTRN	GameViewMode:WORD
		EXTRN	PrtCl:WORD
		EXTRN	DroneMode:WORD

		EXTRN	PrintOver:BYTE
		EXTRN	VGA_RGB_Data:BYTE
		EXTRN	VGA_EXT_TEXT:BYTE
		EXTRN	VGA_EXT_TEXT1:BYTE
		EXTRN	VGA_EXT_TEXT2:BYTE
		EXTRN	SetPaletteFlag:BYTE
		EXTRN	DemoMode:BYTE

;============================================================================

		INCLUDE	MAINDATA.INC
		INCLUDE	CONFIG.INC

		INCLUDE	\VISUAL\PALETTES.INC

		INCLUDE	\LIB8086\PRINT.INC
		INCLUDE	\LIB8086\USEFUL.INC
 		INCLUDE	\LIB8086\PALMACRO.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

VSIVal		DW	0		;abs(DispVSI)

VSICol		DW	OFFSET TextCol2	;VSI colour

FuelCol		DW	OFFSET TextCol2	;fuel colour

ViewCol		DW	OFFSET TextCol2	;view colour (drone allied / enemy)

AltValPtr  	DW	OFFSET BarAlt$

TextRGBPtr	DW	OFFSET VGA_EXT_TEXT1

TextCol1	DB	0ffh,000h,0ffh,000h,00bh,000h,COL_TEXT_NORM1,COL_BLACK
TextCol2	DB	0ffh,000h,055h,000h,00eh,000h,COL_TEXT_NORM2,COL_BLACK
AlertCol	DB	0ffh,000h,0aah,000h,00ch,000h,COL_TEXT_ALERT,COL_BLACK

Info$		LABEL	BYTE
		P_OVER1
		P_CHAR2
		PV_ATTR	TextCol1
		PD_XY	0*4,193
		DB	"SPEED=    KTS "
		DB	"HDG=   ~ "
		DB	"ALT=     FT "
		DB	"VSI=      FT/MIN "
		DB	"FUEL=     LBS "
		DB	"VIEW="
		P_END

PFI$		LABEL	BYTE
		P_CHAR2
		PV_ATTR	TextCol2
		P_DECAT	00100100b	;(unsigned, 4 digits, leading zeroes)
		PD_XY	6*4,193
		PV_DECW	Vkts
		P_DECAT	00100011b	;(unsigned, 3 digits, leading zeroes)
		PD_X	18*4
		PV_DECW	DispHdg
		P_DECAT	00100100b	;(unsigned, 4 digits, leading zeroes)
		PD_X	27*4
		PP_STR	AltValPtr
		PP_ATTR	VSICol
		P_DECAT	00100101b	;(unsigned, 5 digits, leading zeroes)
		PD_X	39*4
		PV_DECW	VSIVal
		DB	'0'
		PP_ATTR	FuelCol
		P_DECAT	00100101b	;(unsigned, 5 digits, leading zeroes)
		PD_X	57*4
		PV_DECW	FuelWt
		PP_ATTR	ViewCol		;(set colour for view mode text)
		PD_X	71*4		;(set x pos for view mode text)
		P_DECAT	00000000b	;(default)
		P_END

BarAlt$		LABEL	BYTE
		PV_DECW	DispBarAlt
		DB	'0'
		P_END

RadAlt$		LABEL	BYTE
		PV_ATTR	AlertCol
		DB	'R'
		PV_DECW	TrueRadAlt
		P_END

Tracking$	LABEL	BYTE
		DB	"TRACKING"
		P_END

Satellite$	LABEL	BYTE
		DB	"SATELLITE"
		P_END

Map$		LABEL	BYTE
		DB	"MAP"
		P_END

Drone$		LABEL	BYTE
		DB	"DRONE"
		P_END

Spectator$	LABEL	BYTE
		DB	"SPECTATOR"
		P_END

Remote$		LABEL	BYTE
		DB	"REMOTE"
		P_END

Demo$		LABEL	BYTE
		P_OVER1
		P_CHAR2
		PV_ATTR	TextCol1
		PD_XY	0*4,193

	IF	OPT_HOLOBYTE EQ 1

		DB	"   TORNADO - CALL SPECTRUM HOLOBYTE DIRECT SALES AT 510-522-3584 FOR DETAILS.   "

	ELSEIF	OPT_COKTEL EQ 1

		DB	"      TORNADO (c) 1993 DI LTD. PHONE COKTEL VISION TEL. 33 (1) 46.30.99.57      "

	ELSEIF	OPT_LEADER EQ 1

		DB	"  TORNADO (c) 1993 DI LTD. PHONE LEADER DISTRIBUZIONE S.R.L. TEL. 0332/874111   "

	ELSEIF	OPT_SYSTEM4 EQ 1

		DB	"     TORNADO (c) 1993 DI LTD. PHONE SYSTEM 4 DE ESPANA, S.A. TELF. 610 57 12    "

	ELSE

	IF	0

		DB	"TORNADO (c) 1993 DIGITAL INTEGRATION LIMITED. CALL (UK) 0276-684959 FOR DETAILS."

	ELSE

		DB	"                  TORNADO (c) 1993 DIGITAL INTEGRATION LIMITED                  "

	ENDIF

	ENDIF

		P_END

Destroyed$	LABEL	BYTE
		DB	"DESTROYED"
		P_END

Weapon$		LABEL	BYTE
		DB	"WEAPON"
		P_END

		EVEN

DATA		ENDS

;============================================================================

PANCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:PANCODE
		ASSUME DS:DATA

;* LoadExtrnPan - load external panel (any screen mode)
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

LoadExtrnPan	PROC	NEAR

;* sort text RGB colours

		mov	si,OFFSET VGA_EXT_TEXT1

		cmp	si,TextRGBPtr	;palette colours ok?
		je	@F		;yes ->

		mov	TextRGBPtr,si

		OVLYRGB	VGA_EXT_TEXT,si,3

		mov	SetPaletteFlag,1

;* clear text area

@@:		mov	al,COL_BLACK
		mov	bl,192
		mov	bh,199
		mov	cx,0
		mov	dx,319
		call	BlockFill

;* print info bar

		mov	si,OFFSET Info$		;assume not demo view

		cmp	DemoMode,0		;demo mode?
		je	@F			;no ->

		mov	si,OFFSET Demo$

@@:		call	Print$

		ret

LoadExtrnPan	ENDP

;----------------------------------------------------------------------------

;* UpdateExtrn - update external panel
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

UpdateExtrn	PROC	NEAR

		cmp	DemoMode,0	;demo mode?
		_JNE	ExitUpdate   	;yes ->

;* if VIEW_MAP then
;*    sort text RGB colours
;*    print Info$
;*    print over = on
;* else
;*    print over = off
;* endif

		xor	al,al		;assume not VIEW_MAP

		cmp	GameViewMode,VIEW_MAP	;map view?
		jne	SkipMap			;no ->

;* sort text RGB colours

		mov	si,OFFSET VGA_EXT_TEXT2

		cmp	si,TextRGBPtr	;palette colours ok?
		je	@F		;yes ->

		mov	TextRGBPtr,si

		OVLYRGB	VGA_EXT_TEXT,si,3

		mov	SetPaletteFlag,1

;* print Info$

@@:		mov	si,OFFSET Info$
		call	Print$

		mov	al,1				

SkipMap:	mov	PrintOver,al

;* sort altitude display (barometric or radar)

		mov	ax,OFFSET BarAlt$

		cmp	TrueRadAlt,5000	;disp bar alt?
		jae	@F		;yes ->

		mov	ax,OFFSET RadAlt$

@@:		mov	AltValPtr,ax

;* sort VSI text col (display -ve VSI in ALERT colour)

		mov	si,OFFSET TextCol2	;assume VSI +ve

		mov	ax,DispVSI
		test	ax,ax		;VSI +ve?
		jns	@F		;yes ->

		mov	si,OFFSET AlertCol

@@:		mov	VSICol,si

		ABSV	ax

		mov	VSIVal,ax

;* sort fuel text col (display <= 1000lbs fuel in ALERT colour)

		mov	si,OFFSET TextCol2	;assume > 1000lbs fuel

		cmp	FuelWt,1000	;> 1000lbs fuel?
		ja	@F		;yes ->

		mov	si,OFFSET AlertCol

@@:		mov	FuelCol,si

;* view mode text colour

		mov	ViewCol,OFFSET TextCol2	;assume not drone mode

		cmp	GameViewMode,VIEW_DRONE	;drone?
		jne	@F	       		;no ->

		test	DroneMode,010b		;enemy?
		jz	@F			;no ->

		mov	ViewCol,OFFSET AlertCol	

;* print primary flight information

@@:		mov	si,OFFSET PFI$
		call	Print$

;* sort view mode

		mov	ax,GameViewMode

		mov	si,OFFSET Tracking$
		cmp	ax,VIEW_TRACKING	;tracking?
		je	ViewOk			;yes ->

		mov	si,OFFSET Satellite$
		cmp	ax,VIEW_SATELLITE	;satellite?
		je	ViewOk			;yes ->

		mov	si,OFFSET Map$
		cmp	ax,VIEW_MAP		;map?
		je	ViewOk			;yes ->

		mov	si,OFFSET Spectator$
		cmp	ax,VIEW_SPECTATOR	;spectator?
		je	ViewOk			;yes ->

		mov	si,OFFSET Remote$
		cmp	ax,VIEW_REMOTE		;remote?
		je	ViewOk			;yes ->

		mov	si,OFFSET Drone$
		cmp	ax,VIEW_DRONE		;drone?
		je	ViewOk			;yes ->

		mov	si,OFFSET Destroyed$
		cmp	ax,VIEW_DESTROYED	;destroyed?
		je	ViewOk			;yes ->

		mov	si,OFFSET Weapon$

ViewOk:		call	Print$

ExitUpdate:	ret

UpdateExtrn	ENDP

PANCODE		ENDS

;============================================================================

		END

