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
EXTRN	ForeCol:BYTE		
EXTRN	BackCol:BYTE		
EXTRN NVG_set:BYTE		
EXTRN	PrintChar:FAR		
EXTRN	PrtLn:WORD		
EXTRN CurrentWPX:WORD		
EXTRN CurrentWPY:WORD
EXTRN CharSprite:FAR
EXTRN MFDAttr1:BYTE
EXTRN ModePtr:WORD		
EXTRN XOrg:WORD		
EXTRN YOrg:BYTE
EXTRN	FloatWP:WORD		
EXTRN	WPRngNMiles:WORD		
EXTRN	MorseDashSound:FAR	
EXTRN	WPETA:WORD
EXTRN AllowSplitScreenBigMap:BYTE		
EXTRN SplitScreenBigMapIsOn:BYTE		
EXTRN SSF_HUD:BYTE
EXTRN SSF_TAB1:BYTE
EXTRN SSF_TAB2:BYTE
EXTRN SSF_NavigMFD:BYTE
EXTRN SSF_PilotMFD:BYTE		
EXTRN DamagedDisp:NEAR	
EXTRN DamagedDispMFD:NEAR	
		EXTRN	BlockFill:FAR
		EXTRN	Print$:FAR
EXTRN ChgGameViewMode:FAR
;EXTRN YawValue:WORD		 
;EXTRN YawValue2:WORD
;EXTRN	DispHdg:WORD
;EXTRN MFD_Counter:WORD
EXTRN	RadarMode:WORD
EXTRN UpdateRWR2:NEAR
EXTRN   HorizonValue_ZRK_AAA:WORD
EXTRN   HorizonValue2:WORD
EXTRN   HorizonValue6:WORD
EXTRN   TrkCamDist:WORD
EXTRN   TrkCamAlt:WORD
EXTRN   HorizonValue:WORD
EXTRN	TornadoType:WORD
EXTRN   QuieterCockpit:BYTE
EXTRN   CurrentViewIsCheckSix:BYTE
EXTRN	Roll:WORD
EXTRN	RFine:WORD
EXTRN	HFine:WORD
EXTRN   UpdateEScope2:NEAR	
EXTRN   UpdateMFD:NEAR
EXTRN   AutoPilotDisp:NEAR
EXTRN   ILSDisp:NEAR
EXTRN   GndMappingRadar:NEAR
EXTRN   RoutePlanDisp:NEAR
EXTRN   MapDisp:NEAR
EXTRN   RadarDisp:NEAR
EXTRN   FLIRDisp_Ori2:NEAR
EXTRN   FLIRDisp_Ori3:NEAR
;EXTRN   FLIRDisp_Ori4:NEAR
EXTRN   TIALDDisp_Ori2:NEAR
EXTRN   RefDisp:NEAR  ;<--- Doesnt rotate!
EXTRN   UpdateTAB:NEAR
;EXTRN   UpdateTAB1:NEAR
;EXTRN   UpdateTAB2:NEAR
EXTRN   UpdateADI2:NEAR
EXTRN   HorizonValue:WORD	
EXTRN	CrewMode:WORD
EXTRN	WPPtr:WORD
;EXTRN	WPRngNMiles:WORD
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
		EXTRN	Key:BYTE
		EXTRN EScopeToggle:BYTE
		EXTRN KF_HillText:BYTE
		EXTRN KF_HillTextCancel:BYTE
		EXTRN KF_TrackingCam:BYTE
		EXTRN KF_TAB1Select:BYTE
		EXTRN KF_TAB2Select:BYTE
		;EXTRN KF_HillTextReverse:BYTE
		
		EXTRN QuieterCockpit:BYTE

;============================================================================
INCLUDE	TAB.INC        
		INCLUDE	MAINDATA.INC
		INCLUDE	CONFIG.INC
INCLUDE	\LIB8086\KEYS.INC
		INCLUDE	\VISUAL\PALETTES.INC

		INCLUDE	\LIB8086\PRINT.INC
		INCLUDE	\LIB8086\USEFUL.INC
 		INCLUDE	\LIB8086\PALMACRO.INC

;============================================================================

EXTRN   TAB1:TAB

DATA		SEGMENT PARA PUBLIC 'DATA'
K_APOSTROPHE	EQU	40
VSIVal		DW	0		;abs(DispVSI)

VSICol		DW	OFFSET TextCol2	;VSI colour

FuelCol		DW	OFFSET TextCol2	;fuel colour

ViewCol		DW	OFFSET TextCol2	;view colour (drone allied / enemy)

AltValPtr  	DW	OFFSET BarAlt$

TextRGBPtr	DW	OFFSET VGA_EXT_TEXT1

TextCol1	DB	0ffh,000h,0ffh,000h,00bh,000h,COL_TEXT_NORM1,COL_BLACK
TextCol2	DB	0ffh,000h,055h,000h,00eh,000h,COL_TEXT_NORM2,COL_BLACK
AlertCol	DB	0ffh,000h,0aah,000h,00ch,000h,COL_TEXT_ALERT,COL_BLACK
AlertCol2	DB	0ffh,000h,0aah,000h,00ch,000h,COL_LT_RED,COL_BLACK
AlertColCyan	DB	0ffh,000h,0aah,000h,00ch,000h,COL_LT_CYAN,COL_BLACK
AlertColYellow	DB	0ffh,000h,0aah,000h,00ch,000h,COL_YELLOW,COL_BLACK
AlertColRed	DB	0ffh,000h,0aah,000h,00ch,000h,COL_WHITE,COL_CRT_RED

Info$		LABEL	BYTE
		P_OVER1
		P_CHAR2
		PV_ATTR	TextCol1
		PD_XY	0*4,193
		DB	"WP=       SP=   KTS "
                DB     "ROL=   ~ "
		DB	"ALT=     FT "
		DB	"VSI=      FT/MIN "
		DB	"FUEL=     LBS "
		DB	"VIEW="
		P_END

MoreInfo$		LABEL	BYTE
		P_OVER1
		P_CHAR2
		PV_ATTR	TextCol1
		PD_XY	0*4,193		
		DB	"RA=   ~ "
		DB	"RR=     /SEC"
		P_END		
		
PFI$		LABEL	BYTE
		P_CHAR2
		PV_ATTR	TextCol2
		P_DECAT	00100011b	;(unsigned, 3 digits, leading zeroes)
		PD_X	(9+4)*4
        PV_DECW Vkts;HorizonValue_ZRK_AAA;Vkts ;EScopeToggle;;horizonValue6;Vkts ;TrkCamAlt
		P_DECAT	00100011b	;(unsigned, 3 digits, leading zeroes)
		PD_X	(20+4)*4
        ;PV_DECW DispHdg		
		PV_DECW Roll;HorizonValue
		
		P_DECAT	00100100b	;(unsigned, 4 digits, leading zeroes)
		PD_X	(29+4)*4
		PP_STR	AltValPtr
		PP_ATTR	VSICol
		P_DECAT	00100101b	;(unsigned, 5 digits, leading zeroes)
		PD_X	(41+4)*4
		PV_DECW	VSIVal;TrkCamDist
		DB	'0'
		PP_ATTR	FuelCol
		P_DECAT	00100101b	;(unsigned, 5 digits, leading zeroes)
		PD_X	(59+4)*4
		PV_DECW	FuelWt;HorizonValue2
		PP_ATTR	ViewCol		;(set colour for view mode text)
		PD_X	(73+4)*4		;(set x pos for view mode text)
		P_DECAT	00000000b	;(default)
		P_END

WAYP$		LABEL	BYTE
		P_CHAR2
		PV_ATTR	AlertCol
	    P_DECAT	00000000b	;(default)
		PD_XY	3*4,193		;(set x pos for view mode text) ;5*4
		PP_ATTR	COL_LT_CYAN
		;PP_STR [WPPtr].WP_ID
		;PV_CHR [WPPtr].WP_ID
		PP_STR WPPtr
		P_END		
		
	
PFIcyan$		LABEL	BYTE
		P_CHAR2
		PV_ATTR	TextCol2
		P_DECAT	00100011b	;(unsigned, 3 digits, leading zeroes)
		PD_XY	3*4,193
		PV_ETA	WPETA		;PP_ATTR	COL_BLACK
		P_END

PFIyellow$		LABEL	BYTE
        P_CHAR2
		PV_ATTR	AlertColYellow
		P_DECAT	00100011b	;(unsigned, 3 digits, leading zeroes)
		PD_XY	3*4,193
		PV_ETA	WPETA		;PP_ATTR	COL_BLACK
		P_END

PFIlightred$		LABEL	BYTE
        P_CHAR2
		PV_ATTR	AlertCol2
		P_DECAT	00100011b	;(unsigned, 3 digits, leading zeroes)
		PD_XY	3*4,193
		PV_ETA	WPETA		;PP_ATTR	COL_BLACK
		P_END
		
		
PFIred$		LABEL	BYTE
        P_CHAR2
		PV_ATTR	AlertColRed
		P_DECAT	00100011b	;(unsigned, 3 digits, leading zeroes)
		PD_XY	3*4,193
		PV_ETA	WPETA		;PP_ATTR	COL_BLACK
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
		DB	"TRK"  ;TRACKING
		P_END

ZSUView1$	LABEL	BYTE
		DB	"ZSU"  ;ZSU-23-4 Shilka to Tornado view
		P_END		
		
ZSUView2$	LABEL	BYTE
		DB	"ZS2"  ;ZSU-23-4 Shilka to Tornado view
		P_END		
		
ZRKView$	LABEL	BYTE
		DB	"ZRK"  ;ZRK ROMB (SA-8) to Tornado view
		P_END				

ZRKZSUView$ LABEL	BYTE
		DB	"ENY"  ;ZRK ROMB (SA-8) to Tornado view
		P_END			
		
Satellite$	LABEL	BYTE
		DB	"REV" ;6 O'clock
		P_END

Map$		LABEL	BYTE
		DB	"MAP"
		P_END

Drone$		LABEL	BYTE
		DB	"DRN"  ;DRONE
		P_END

Spectator$	LABEL	BYTE
		DB	"SPC"  ;SPECTATOR
		P_END

Remote$		LABEL	BYTE
		DB	"FLY"  ;REMOTE
		P_END

Demo$		LABEL	BYTE
		P_OVER1
		P_CHAR2
		PV_ATTR	TextCol1
		PD_XY	0*4,193

	IF	OPT_HOLOBYTE EQ 1

		;DB	"   TORNADO - CALL SPECTRUM HOLOBYTE DIRECT SALES AT 510-522-3584 FOR DETAILS.   "
        DB " "
	ELSEIF	OPT_COKTEL EQ 1

		;DB	"      TORNADO (c) 1993 DI LTD. PHONE COKTEL VISION TEL. 33 (1) 46.30.99.57      "
		DB " "

	ELSEIF	OPT_LEADER EQ 1

		;DB	"  TORNADO (c) 1993 DI LTD. PHONE LEADER DISTRIBUZIONE S.R.L. TEL. 0332/874111   "
		DB " "

	ELSEIF	OPT_SYSTEM4 EQ 1

		;DB	"     TORNADO (c) 1993 DI LTD. PHONE SYSTEM 4 DE ESPANA, S.A. TELF. 610 57 12    "
		DB " "

	ELSE

	IF	0

		;DB	"TORNADO (c) 1993 DIGITAL INTEGRATION LIMITED. CALL (UK) 0276-684959 FOR DETAILS."
		DB " "

	ELSE

		DB	"DEMO"

	ENDIF

	ENDIF

		P_END

Destroyed$	LABEL	BYTE
		DB	"KIL" ;DESTROYED
		P_END
		
Strike$		LABEL	BYTE
		DB	"NAV"     ;hacked on 4/11/2017. Formerly WEAPON
		P_END

	
Weapon$		LABEL	BYTE
		DB	"WPN"     ;hacked on 4/11/2017. Formerly WEAPON
		P_END
		
;Pilot$		LABEL	BYTE
;		DB	"PILOT"     ;hacked on 4/11/2017. Formerly WEAPON
;		P_END	
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

@@:		cmp NVG_set,1
        je @F
        mov	al,COL_BLACK
		jmp SkipCOL_CRT2
@@:		
        mov al,COL_CRT2
SkipCOL_CRT2:		
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

@@:		;mov	si,OFFSET MoreInfo$
		;call	Print$
        mov	si,OFFSET Info$
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
@@:				          
        ;mov	si,OFFSET WAYP$
		;call	Print$	
		mov	PrtCl,8*4  ;3*4
		mov	PrtLn,193	
        cmp WPPtr, -1
        je @F		
		mov	si,WPPtr
		jmp Skipppa
@@:	    mov	[WPPtr].WP_ID,'-'
		mov	si,WPPtr
Skipppa:		
		mov	al,[si].WP_ID
		mov ForeCol, COL_TEXT_ALERT
		mov BackCol, COL_BLACK
		call	PrintChar		
;* print countdown timer to current waypoint		
        cmp WPRngNMiles,10
		ja Miles_Cyan 
        cmp WPRngNMiles,5
		ja Miles_Yellow
        cmp WPRngNMiles,0
		ja Miles_LightRed
		mov	si,OFFSET PFIred$
		jmp @F
Miles_Cyan:		
		mov	si,OFFSET PFIcyan$				
		jmp @F		
Miles_Yellow:
		mov	si,OFFSET PFIyellow$
		jmp @F
Miles_LightRed:		
		mov	si,OFFSET PFIlightred$				
@@:		call	Print$		
	
	
;* calc DispHdg (1 .. 360)

        mov	si,OFFSET PFI$
		call	Print$	
		
;* sort view mode

		mov	ax,GameViewMode

		mov	si,OFFSET Tracking$
		cmp	ax,VIEW_TRACKING	;tracking?
		je	ViewOk			;yes ->

		mov	si,OFFSET ZSUView1$
		cmp	ax,VIEW_ZSU1	;ZSU View1?
		je	ViewOk			;yes ->

		mov	si,OFFSET ZSUView2$
		cmp	ax,VIEW_ZSU2	;ZSU View2?
		je	ViewOk			;yes ->		
		
		mov	si,OFFSET ZRKView$
		cmp	ax,VIEW_ZRK	;tracking?
		je	ViewOk			;yes ->		

		mov	si,OFFSET ZRKZSUView$
		cmp	ax,VIEW_ZRK_AAA	;tracking?
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

		cmp	CrewMode,CREW_PILOT	;pilot?
		je  ShowWeaponStatusLine; yes ->
		mov	si,OFFSET Strike$ ;kbs
		jmp ViewOk
ShowWeaponStatusLine:		
		mov	si,OFFSET Weapon$
		;kbs

ViewOk:	call	Print$
		cmp	CrewMode,CREW_NAVIG ;Navigator?
		je ExitUpdate

		KTEST KF_HillText		
		jz @F
	    KCLEAR KF_HillText
		cmp SplitScreenBigMapIsOn,1  ;Check if the Half Map is active
		je @F ;--> yes
		;Half Map is inactive, so bring the user back to the first F1-type (i.e., tracking cam view)screen
		mov	EScopeToggle,0
		mov AllowSplitScreenBigMap,0
@@:		
        cmp CurrentViewIsCheckSix,1
		jne @F
        mov AllowSplitScreenBigMap,0		
		je ExitUpdate
@@:		
		;test	Key[K_OPN_SQ_BRKT],1
		;jz	@F
		;KCLEAR Key[K_OPN_SQ_BRKT]		
		;test	Key[K_5],1
		test Key[K_OPN_SQ_BRKT],1
		jz @F
		;KCLEAR  Key[K_5]
        KCLEAR Key[K_OPN_SQ_BRKT]		
		
        ;If the half-map is currently being viewed, don't go beyond this point of the "[" tab!
        cmp EScopeToggle,1
		jne jiffy ;--> No
        cmp SplitScreenBigMapIsOn,1
        jne jiffy ;--> No
		call MorseDashSound
        jmp leap2 ;EScopeToggle is left as 1
jiffy:		
		
		cmp TornadoType,ADV_TORNADO
		jne Non_ADVprocess
        jmp ADVprocess
ADVprocess:		
		cmp EScopeToggle,0
		je leap1
		cmp EScopeToggle,3
		je leap3
		cmp EScopeToggle,8
		je leap4		
		cmp EScopeToggle,18
		je leap5
		sub	EScopeToggle,1
		jmp leap2
leap3:	mov	EScopeToggle,1
		jmp leap2
leap4:	mov	EScopeToggle,6
		jmp leap2
leap5:	mov	EScopeToggle,16
		jmp leap2		
Non_ADVprocess:		
		cmp EScopeToggle,0
		je leap1
		sub	EScopeToggle,1
		jmp leap2
leap1:  mov	EScopeToggle,20
		jmp leapOfFaith
@@:		;KTEST KF_TAB2Select

		test	Key[K_CLS_SQ_BRKT],1
		jz @F
        KCLEAR Key[K_CLS_SQ_BRKT]	

        ;test	Key[K_CLS_SQ_BRKT],1
		;jz	@F
		;KCLEAR Key[K_CLS_SQ_BRKT]	
		
        ;If the half-map is currently being viewed, don't go beyond this point of the "[" tab!
        cmp EScopeToggle,10
		jne iffy ;--> No
        cmp SplitScreenBigMapIsOn,1
        jne iffy ;--> No
		call MorseDashSound
        jmp leap2 ;EScopeToggle is left as 10
iffy:					
		
        add EScopeToggle,1 ;Toggle value from 0 to 1
@@:
leap2:	cmp	EScopeToggle,1
		jne @F 
		mov AllowSplitScreenBigMap,1
		test	QuieterCockpit,1	;in cockpit?
		jnz @F ;->yes
		;Only display the original FLIR display IF the TV-TAB1 is not showing the full-screen FLIR (otherwise game will hang!)
		;cmp	TAB1.TAB_MODE,TAB_FLIR_ORI ;Strange oversight: TAB_FLIR_ORI means full-screen FLIR in TAB!!
		;je DontShowOriFLIR_And_Addd0
		;call UpdateEScope2
		call FLIRDisp_Ori3
		call UpdateADI2	
		call UpdateRWR2
		jmp ExitUpdate
;DontShowOriFLIR_And_Addd0:
        add EScopeToggle,1
@@:		cmp	EScopeToggle,2
		jne @F 
		mov AllowSplitScreenBigMap,1
        ;ADV Tornado don't have the Terrain-following EScope - so add 1 EScopeToggle 
		;and skip to next "cmp EScopeToggle" section if flying ADV		
		cmp TornadoType,ADV_TORNADO
		je DontShowOriFLIR_And_Add0
		test	QuieterCockpit,1	;in cockpit?
		jnz @F ;->yes
		;Only display the original FLIR display IF the TV-TAB1 is not showing the full-screen FLIR (otherwise game will hang!)
		;cmp	TAB1.TAB_MODE,TAB_FLIR_ORI ;Strange oversight: TAB_FLIR_ORI means full-screen FLIR in TAB!!
		;je DontShowOriFLIR_And_Add0
		call UpdateEScope2
		call FLIRDisp_Ori3
		call UpdateADI2	
		call UpdateRWR2		
		jmp ExitUpdate
DontShowOriFLIR_And_Add0:
        add EScopeToggle,1
@@:		cmp	EScopeToggle,3
		jne @F 
		mov AllowSplitScreenBigMap,1
		test	QuieterCockpit,1	;in cockpit?
		jnz @F ;->yes
		;Only display the original FLIR display IF the TV-TAB1 is not showing the full-screen FLIR (otherwise game will hang!)
		;cmp	TAB1.TAB_MODE,TAB_FLIR_ORI ;Strange oversight: TAB_FLIR_ORI means full-screen FLIR in TAB!!
		;je DontShowOriFLIR_And_Add1
		call UpdateEScope2
		call FLIRDisp_Ori3
		call UpdateADI2	
		call UpdateRWR2		
		mov al, SSF_TAB1
		and al, SSF_TAB2
        jz	NoDamage3
        call	DamagedDisp
		jmp ExitUpdate
NoDamage3: call UpdateTAB 
		call TIALDDisp_Ori2  ; <-- This has to be last on the list!
		jmp ExitUpdate
DontShowOriFLIR_And_Add1:
        add EScopeToggle,1
@@:		cmp	EScopeToggle,4
		jne @F 
		mov AllowSplitScreenBigMap,1
		test	QuieterCockpit,1	;in cockpit?
		jnz @F ;->yes		
		;Only display the original FLIR display IF the TV-TAB1 is not showing the full-screen FLIR (otherwise game will hang!)
		;cmp	TAB1.TAB_MODE,TAB_FLIR_ORI ;Strange oversight: TAB_FLIR_ORI means full-screen FLIR in TAB!!
		;je DontShowOriFLIR_And_Add2
		call UpdateEScope2
		call FLIRDisp_Ori3
		call UpdateADI2		;try this
		call UpdateRWR2		;try this
		mov al, SSF_TAB1
		and al, SSF_TAB2
        jz	NoDamage4
        call	DamagedDisp
		jmp ExitUpdate
NoDamage4:call UpdateTAB 
        call RefDisp			
		jmp ExitUpdate
;DontShowOriFLIR_And_Add2:
        add EScopeToggle,1
@@:		cmp	EScopeToggle,5
		jne @F 
		mov AllowSplitScreenBigMap,1
		test	QuieterCockpit,1	;in cockpit?
		jnz @F ;->yes
		
		;Only display the original FLIR display IF the TV-TAB1 is not showing the full-screen FLIR (otherwise game will hang!)
		;cmp	TAB1.TAB_MODE,TAB_FLIR_ORI ;Strange oversight: TAB_FLIR_ORI means full-screen FLIR in TAB!!
		;je DontShowOriFLIR_And_Add2c
		call UpdateEScope2
		call FLIRDisp_Ori3
		
		call UpdateADI2	
		call UpdateRWR2		
        
		mov al, SSF_TAB1
		and al, SSF_TAB2
        jz	NoDamage5
        call	DamagedDisp
		jmp ExitUpdate
NoDamage5: call UpdateTAB              ;Can comment off!??????
		call RoutePlanDisp	
		jmp ExitUpdate
;DontShowOriFLIR_And_Add2c:
        add EScopeToggle,1
@@:
Leap6:	cmp	EScopeToggle,6
		jne @F 
		mov AllowSplitScreenBigMap,1
		test	QuieterCockpit,1	;in cockpit?
		jnz @F ;->yes
		
		;Only display the original FLIR display IF the TV-TAB1 is not showing the full-screen FLIR (otherwise game will hang!)
		;cmp	TAB1.TAB_MODE,TAB_FLIR_ORI ;Strange oversight: TAB_FLIR_ORI means full-screen FLIR in TAB!!
		;je DontShowOriFLIR_And_Adb
		call UpdateEScope2
		;call UpdateTAB 
		call FLIRDisp_Ori3
		call UpdateADI2
		call UpdateRWR2		
		mov al, SSF_TAB1
		and al, SSF_TAB2
        jz	NoDamage6
        call	DamagedDisp
		jmp ExitUpdate
NoDamage6:call UpdateMFD
        call MapDisp
		jmp ExitUpdate
;DontShowOriFLIR_And_Adb:
        add EScopeToggle,1
@@:		cmp	EScopeToggle,7
		jne @F 
		mov AllowSplitScreenBigMap,1
		;ADV Tornado don't have the Ground Mapping Radar - so add 1 EScopeToggle 
		;and skip to next "cmp EScopeToggle" section if flying ADV		
		cmp TornadoType,ADV_TORNADO
		je DontShowOriFLIR_And_Add2b
		
		test	QuieterCockpit,1	;in cockpit?
		jnz @F ;->yes
		
		;Only display the original FLIR display IF the TV-TAB1 is not showing the full-screen FLIR (otherwise game will hang!)
		;cmp	TAB1.TAB_MODE,TAB_FLIR_ORI ;Strange oversight: TAB_FLIR_ORI means full-screen FLIR in TAB!!
		;je DontShowOriFLIR_And_Add2b
		call UpdateEScope2
		;call UpdateTAB 
		call FLIRDisp_Ori3
		call UpdateADI2
		call UpdateRWR2		
		mov al, SSF_NavigMFD
		and al, SSF_PilotMFD
        jz	NoDamage7
        call	DamagedDispMFD
		jmp ExitUpdate
NoDamage7: call UpdateMFD
        call GndMappingRadar		
		jmp ExitUpdate
DontShowOriFLIR_And_Add2b:
        add EScopeToggle,1
@@:		cmp	EScopeToggle,8
		jne @F 
		mov AllowSplitScreenBigMap,1
		
		test	QuieterCockpit,1	;in cockpit?
		jnz @F ;->yes
		
		;Only display the original FLIR display IF the TV-TAB1 is not showing the full-screen FLIR (otherwise game will hang!)
		;cmp	TAB1.TAB_MODE,TAB_FLIR_ORI ;Strange oversight: TAB_FLIR_ORI means full-screen FLIR in TAB!!
		;je DontShowOriFLIR_And_Add2bc
		call UpdateEScope2
		;call UpdateTAB 
		call FLIRDisp_Ori3
		call UpdateADI2
		call UpdateRWR2		
		mov al, SSF_NavigMFD
		and al, SSF_PilotMFD
        jz	NoDamage7b
        call	DamagedDispMFD
		jmp ExitUpdate
NoDamage7b: call UpdateMFD
		mov RadarMode,AIR_RADAR
		call RadarDisp
		jmp ExitUpdate
;DontShowOriFLIR_And_Add2bc:
        add EScopeToggle,1
@@:		cmp	EScopeToggle,9
		jne @F 
		mov AllowSplitScreenBigMap,1
		test	QuieterCockpit,1	;in cockpit?
		jnz @F ;->yes
		;Only display the original FLIR display IF the TV-TAB1 is not showing the full-screen FLIR (otherwise game will hang!)
		;cmp	TAB1.TAB_MODE,TAB_FLIR_ORI ;Strange oversight: TAB_FLIR_ORI means full-screen FLIR in TAB!!
		;je DontShowOriFLIR_And_Add6
		call UpdateEScope2
		;call UpdateTAB 
		call FLIRDisp_Ori3
		call UpdateADI2
		call UpdateRWR2	
		mov al, SSF_NavigMFD
		and al, SSF_PilotMFD
        jz	NoDamage8
        call	DamagedDispMFD
		jmp ExitUpdate
NoDamage8:call UpdateMFD
        call AutoPilotDisp	
		jmp ExitUpdate
;DontShowOriFLIR_And_Add6:
        add EScopeToggle,1
@@:
Gobackto10:	cmp	EScopeToggle,10
		jne @F 
		mov AllowSplitScreenBigMap,1
		
		test	QuieterCockpit,1	;in cockpit?
		jnz @F ;->yes
		
		;Only display the original FLIR display IF the TV-TAB1 is not showing the full-screen FLIR (otherwise game will hang!)
		;cmp	TAB1.TAB_MODE,TAB_FLIR_ORI ;Strange oversight: TAB_FLIR_ORI means full-screen FLIR in TAB!!
		;je DontShowOriFLIR_And_Add3
		call UpdateEScope2
		;call UpdateTAB 
		call FLIRDisp_Ori3
		call UpdateADI2
		call UpdateRWR2
		mov al, SSF_NavigMFD
		and al, SSF_PilotMFD
        jz	NoDamage9
        call	DamagedDispMFD
		jmp ExitUpdate
NoDamage9:		
		call UpdateMFD
        call ILSDisp		
		jmp ExitUpdate
;DontShowOriFLIR_And_Add3:
        add EScopeToggle,1
@@:
        cmp	EScopeToggle,11
		jne @F 
		mov AllowSplitScreenBigMap,0
		
;If the half-map is currently being viewed, don't go beyond this point of the "[" tab!
        ;cmp SplitScreenBigMapIsOn,1
        ;jne @F ;--> No
        ;mov EScopeToggle,10
        ;jmp leap2
;@@:			
		test	QuieterCockpit,1	;in cockpit?
		jnz @F ;->yes
        call UpdateEScope2
		;call UpdateTAB
		call UpdateADI2
		;call UpdateRWR2
		mov al, SSF_TAB1
		and al, SSF_TAB2
        jz	NoDamage12
        call	DamagedDisp
		jmp ExitUpdate
NoDamage12:				
		call UpdateMFD
		call MapDisp         
		jmp ExitUpdate
@@:
		cmp	EScopeToggle,12
		jne @F 
		mov AllowSplitScreenBigMap,0
				
		test	QuieterCockpit,1	;in cockpit?
		jnz @F ;->yes
        call UpdateEScope2
		call UpdateADI2		
		;call UpdateRWR2
		mov al, SSF_TAB1
		and al, SSF_TAB2
        jz	NoDamage13
        call	DamagedDisp
		jmp ExitUpdate
NoDamage13:			
		call UpdateTAB              ;Can comment off!??????
		call RoutePlanDisp
		jmp ExitUpdate
@@:
		cmp	EScopeToggle,13
		jne @F 
		mov AllowSplitScreenBigMap,0
				
		test	QuieterCockpit,1	;in cockpit?
		jnz @F ;->yes
		call UpdateEScope2
		call UpdateADI2		
		;call UpdateRWR2
		mov al, SSF_TAB1
		and al, SSF_TAB2
        jz	NoDamage14
        call	DamagedDisp
		jmp ExitUpdate
NoDamage14:			
		call UpdateTAB
		call RefDisp
		jmp ExitUpdate
@@:
		cmp	EScopeToggle,14
		jne @F 
		mov AllowSplitScreenBigMap,0
				
		test	QuieterCockpit,1	;in cockpit?
		jnz @F ;->yes
		
		;Only display the original FLIR display IF the TV-TAB1 is not showing the full-screen FLIR (otherwise game will hang!)
		;cmp	TAB1.TAB_MODE,TAB_FLIR_ORI ;Strange oversight: TAB_FLIR_ORI means full-screen FLIR in TAB!!
		;je DontShowOriFLIR_And_Add4
		call UpdateEScope2
		call UpdateADI2		
		;call UpdateRWR2
		mov al, SSF_TAB1
		and al, SSF_TAB2
        jz	NoDamage15
        call	DamagedDisp
		jmp ExitUpdate
NoDamage15:			
		call UpdateTAB 
		call FLIRDisp_Ori2
		jmp ExitUpdate
;DontShowOriFLIR_And_Add4:
        add EScopeToggle,1
@@:
		cmp	EScopeToggle,15
		jne @F 
		mov AllowSplitScreenBigMap,0
		
		test	QuieterCockpit,1	;in cockpit?
		jnz @F ;->yes
		;Only display the original TIALD display IF the TV-TAB1 is not showing the full-screen TIALD (otherwise game will hang!)
		;cmp	TAB1.TAB_MODE,TAB_TIALD_ORI ;Strange oversight: TAB_TIALD_ORI means full-screen TIALD in TAB!!
		;je DontShowOriTIALD_And_Add1		
		call UpdateEScope2
		call UpdateADI2		
		;call UpdateRWR2
		mov al, SSF_TAB1
		and al, SSF_TAB2
        jz	NoDamage16
        call	DamagedDisp
		jmp ExitUpdate
NoDamage16:			
		call UpdateTAB	
		call TIALDDisp_Ori2
		jmp ExitUpdate
;DontShowOriTIALD_And_Add1:
         add EScopeToggle,1		
@@:
		cmp	EScopeToggle,16
		jne @F 
		mov AllowSplitScreenBigMap,0
				
		test	QuieterCockpit,1	;in cockpit?
		jnz @F ;->yes
		call UpdateEScope2
		call UpdateADI2		
		;call UpdateRWR2
		mov al, SSF_NavigMFD
		and al, SSF_PilotMFD
        jz	NoDamage17
        call	DamagedDispMFD
		jmp ExitUpdate
NoDamage17:		
		call UpdateMFD
		call AutoPilotDisp
		jmp ExitUpdate
@@:
		cmp	EScopeToggle,17
		jne @F 
		mov AllowSplitScreenBigMap,0
				
		;ADV Tornado don't have the Ground Mapping Radar - so add 1 EScopeToggle 
		;and skip to next "cmp EScopeToggle" section if flying ADV		
		cmp TornadoType,ADV_TORNADO
		je DontShowOriTIALD_And_Addqa1
		
		test	QuieterCockpit,1
		jnz @F ;->yes
        call UpdateEScope2
		call UpdateADI2	
		;call UpdateRWR2
		mov al, SSF_NavigMFD
		and al, SSF_PilotMFD
        jz	NoDamage18
        call	DamagedDispMFD
		jmp ExitUpdate
NoDamage18:		
		call UpdateMFD
        call GndMappingRadar
		jmp ExitUpdate
DontShowOriTIALD_And_Addqa1:		
        add	EScopeToggle,1
@@:
		cmp	EScopeToggle,18
		jne @F 
		mov AllowSplitScreenBigMap,0
		
		test	QuieterCockpit,1
		jnz @F ;->yes
        call UpdateEScope2
		call UpdateADI2	
		;call UpdateRWR2
		mov al, SSF_NavigMFD
		and al, SSF_PilotMFD
        jz	NoDamage18b
        call	DamagedDispMFD
		jmp ExitUpdate
NoDamage18b:		
		call UpdateMFD
		mov RadarMode,AIR_RADAR
		call RadarDisp
		jmp ExitUpdate
@@:
		cmp	EScopeToggle,19
		jne @F 
		mov AllowSplitScreenBigMap,0
		
		test	QuieterCockpit,1
		jnz @F ;->yes
        call UpdateEScope2
		call UpdateADI2	
		;call UpdateRWR2
		mov al, SSF_NavigMFD
		and al, SSF_PilotMFD
        jz	NoDamage19
        call	DamagedDispMFD
		jmp ExitUpdate
NoDamage19:				
		call UpdateMFD
        call AutoPilotDisp
		jmp ExitUpdate
@@:
leapOfFaith:
		cmp	EScopeToggle,20
		jne @F 
		mov AllowSplitScreenBigMap,0
				
		test	QuieterCockpit,1
		jnz @F ;->yes
        call UpdateEScope2
		call UpdateADI2	
		;call UpdateRWR2
		mov al, SSF_NavigMFD
		and al, SSF_PilotMFD
        jz	NoDamage20
        call	DamagedDispMFD
		jmp ExitUpdate
NoDamage20:		
		call UpdateMFD
        call ILSDisp
		jmp ExitUpdate		
@@:
		cmp	EScopeToggle,21
		jne ExitUpdate
		mov	EScopeToggle,0
ExitUpdate:	ret

UpdateExtrn	ENDP

PANCODE		ENDS

;============================================================================

		END