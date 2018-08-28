;****************************************************************************
;*
;* CONTROL.ASM
;*
;* Control routine.
;*
;* 23.07.1990 - KJB
;*
;* Command Line Options
;* 컴컴컴컴컴컴컴컴컴컴
;*
;*	/a  ... start airborne (default 5000ft, 450kts) (use before /av /az)
;*	/ah ... set heading for start airborne (range = /ah0 .. /ah360 degs)
;*      /av ... set speed (ias) for start airborne (range = /av200 .. /av800 kts)
;*      /az ... set altitude for start airborne (range = /az1 .. /az99999 ft)
;*      /ax ... set x sector (xft = 0), for start airborne (range = /ax0 .. /ax31)
;*      /ay ... set y sector (yft = 0), for start airborne (range = /ax0 .. /ax31)
;*
;*	/b  ... set Baud rate (use after /t1 or /t2) (range = /b12 .. /b1152)
;*
;*	/ch ... CH FlightStick Pro
;*
;*	/cg ... green cockpit lighting
;*	/cr ... red cockpit lighting
;*
;*	/dx ... data exchange enabled
;*
;*	/d1 ... drone cycling demo mode
;*	/d2 ... flying demo mode
;*
;*	/e  ... map explore mode
;*
;*      /f1 ... light fog
;*      /f2 ... heavy fog
;*
;*	/fo ... fade out loading screen
;*
;*	/fr ... set max frame rate (debugging) (range = /fr1 .. /fr16 frames/sec)
;*
;*      /gt ... global timeout enabled (demos) (range = /gt0 .. /gt99999 secs)
;*
;*	/if ... infinite fuel
;*      /ig ... infinite g-force (no blackouts or redouts)
;*	/iw ... infinite weapons
;*
;*	/ma ... AdLib theme music
;*	/mb ... SoundBlaster theme music
;*	/mn ... no theme music
;*	/mr ... Roland LAPC1 theme music
;*	/ms ... internal speaker theme music
;*
;*	/mt ... map test
;*
;*	/nc ... no collisions
;*
;*      /n1 ... night 1 (dusk)
;*      /n2 ... night 2
;*      /n3 ... night 3
;*      /n4 ... night 4 (midnight)
;*
;*      /o  ... overcast
;*
;*      /p  ... object preview mode
;*      /pa ... auto-run object preview mode
;*
;*      /qs ... quick start ("/qs" is same as "/a /if /ig /iw /nc /w")
;*
;*	/rt ... radar test TAB display enabled (debugging)
;*
;*	/sa ... AdLib sound effects
;*	/sb ... SoundBlaster sound effects
;*	/sn ... no sound effects
;*	/sr ... Roland LAPC1 sound effects
;*	/ss ... internal speaker sound effects
;*
;*      /t1 ... two player mode (com1:), 9600 Baud
;*      /t2 ... two player mode (com2:), 9600 Baud
;*
;*      /tm ... ThrustMaster joystick
;*
;*	/va ... ADV variant
;*	/ve ... ECR variant
;*	/vi ... IDS variant
;*
;*      /w  ... set fixed weight (range = /w33000 .. /w60000 lbs)
;*
;*	/xw ... cross winds enabled (range = /xw5 .. /xw75 kts)
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	Control
		PUBLIC	CheckTimeout

		EXTRN	QuickSetUp:FAR
		EXTRN	DownLoad:FAR
		EXTRN	InstallUser20:FAR
		EXTRN	InstallUser100:FAR
		EXTRN	GameIntr20:FAR
		EXTRN	GameIntr100:FAR
		EXTRN	Visual:FAR
		EXTRN	ConfigureVisual:FAR
		EXTRN	InitModel:FAR
		EXTRN	Model:FAR
		EXTRN	SetGameViewMode:FAR
		EXTRN	UpdateGameView:FAR
		EXTRN	InitPanels:FAR
		EXTRN	UpdatePanel:FAR
		EXTRN	UpdateAvionics:FAR
		EXTRN	UserOptions:FAR
		EXTRN	MapExplore:FAR
		EXTRN	ConvNum$:FAR
		EXTRN	UpdatePlanes:FAR
		EXTRN	UpdateHelicops:FAR
		EXTRN	UpdateConvoys:FAR
		EXTRN	UpdateAAA:FAR
		EXTRN	UpdateSAM:FAR
		EXTRN	UpdateWeapons:FAR
		EXTRN	UpdateGLOC:FAR
		EXTRN	WeaponsControl:FAR
		EXTRN	FadeOut:FAR
		EXTRN	FadeDown:FAR
		EXTRN	FadeUp:FAR
		EXTRN	LoadPicture:FAR
		EXTRN	VGAPhotoDflt:FAR
		EXTRN	PrintDebugInfo:FAR
		EXTRN	VisualInfo:FAR
		EXTRN	SwitchOnLights:FAR
		EXTRN	SetViewMode:FAR
		EXTRN	CalcGndHeight:FAR
		EXTRN	InstallSound:FAR
		EXTRN	NormaliseSound:FAR
		EXTRN	SuspendSound:FAR
		EXTRN	ResumeSound:FAR
		EXTRN	UpdateSound:FAR
		EXTRN	ReadDACBlock:FAR
		EXTRN	DeleteMobile:FAR
		EXTRN	CreateMobile:FAR
		EXTRN	AdvanceWP:FAR
		EXTRN	ObjectPreview:FAR
		EXTRN	InitComms:FAR
		EXTRN	StopComms:FAR
		EXTRN	SyncComms:FAR
		EXTRN	TxTornadoData:FAR
		EXTRN	RxOpponentData:FAR
		EXTRN	ClearComms:FAR
		EXTRN	InitTwoPlayer:FAR
		EXTRN	InstallMusic:FAR
		EXTRN	NormaliseMusic:FAR
		EXTRN	SuspendMusic:FAR
		EXTRN	ResumeMusic:FAR

		EXTRN	InitGame:NEAR
		EXTRN	LoadGameData:NEAR
		EXTRN	SaveGameData:NEAR
		EXTRN	LoadMapData:NEAR
		EXTRN	SaveMapData:NEAR

		EXTRN	ElapsedTime:DWORD
		EXTRN	TimeLimit:DWORD

		EXTRN	ARGC:WORD
		EXTRN	ARGV:WORD
		EXTRN	MaxFrameRate:WORD
		EXTRN	ViewPtr:WORD
		EXTRN	FixedWeight:WORD
		EXTRN	TornadoType:WORD
		EXTRN	Ticker:WORD
		EXTRN	Frames:WORD
		EXTRN	CountDown:WORD
		EXTRN	PSP:WORD
		EXTRN	SoundCard:WORD
		EXTRN	MusicCard:WORD
		EXTRN	StartAirspeed:WORD
		EXTRN	WPPtr:WORD
		EXTRN	WPBrg:WORD
		EXTRN	TrkCamBrg:WORD
		EXTRN	ExtStores:WORD
		EXTRN	PackagePtr:WORD
		EXTRN	SeedLo:WORD
		EXTRN	SeedHi:WORD
		EXTRN	XWindVmax:WORD
		EXTRN	XWindDir:WORD

		EXTRN	Key:BYTE
		EXTRN	DieFlag:BYTE
		EXTRN	ExploreMode:BYTE
		EXTRN	PreviewMode:BYTE
		EXTRN	DemoMode:BYTE
		EXTRN	Overcast:BYTE
		EXTRN	Fog:BYTE
		EXTRN	Night:BYTE
		EXTRN	DebugWeight:BYTE
		EXTRN	ThrustMaster:BYTE
		EXTRN	MouseFlag:BYTE
		EXTRN	KF_Quit:BYTE
		EXTRN	KF_Pause:BYTE
		EXTRN	DisableInput:BYTE
		EXTRN	Paused:BYTE
		EXTRN	RadarTest:BYTE
		EXTRN	PanelLight:BYTE
		EXTRN	NoCollisions:BYTE
		EXTRN	ReturnCode:BYTE
		EXTRN	InfiniteWeapons:BYTE
		EXTRN	InfiniteFuel:BYTE
		EXTRN	InfiniteGForce:BYTE
		EXTRN	PROG_END:BYTE
		EXTRN	WorkScreen:BYTE
		EXTRN	VGA_RGB_Data:BYTE
		EXTRN	StartAirborne:BYTE
		EXTRN	AutoTrack:BYTE
		EXTRN	GlobalTimeout:BYTE
		EXTRN	TwoPlayer:BYTE
		EXTRN	CommsDevice:BYTE
		EXTRN	BaudRate:BYTE
		EXTRN	RxFlag:BYTE
		EXTRN	TxGameEnd:BYTE
		EXTRN	RxGameEnd:BYTE
		EXTRN	TmpDieFlag:BYTE
		EXTRN	NoFire:BYTE
		EXTRN	CHStick:BYTE

		EXTRN	VGA:ABS
		EXTRN	COM1:ABS
		EXTRN	COM2:ABS
		EXTRN	BAUD1200:ABS
		EXTRN	BAUD2400:ABS
		EXTRN	BAUD4800:ABS	
		EXTRN	BAUD9600:ABS	
		EXTRN	BAUD14400:ABS	
		EXTRN	BAUD19200:ABS	
		EXTRN	BAUD38400:ABS	
		EXTRN	BAUD57600:ABS	
		EXTRN	BAUD115200:ABS

;============================================================================

		INCLUDE	MAINDATA.INC
		INCLUDE	CONFIG.INC

		INCLUDE	\LIB8086\KEYS.INC
		INCLUDE	\LIB8086\USEFUL.INC

		INCLUDE	\VISUAL\VISDATA.INC

;============================================================================

		EXTRN	M_MOBILE:MOBILE
		EXTRN	M_VIEW:VIEWPOINT

		EXTRN	Packages:PACKAGE

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

;------------
;* misc flags
;------------

DataExchange	DB	0		;1 = data exchange enabled

FadeOutFlag	DB	0		;1 = fade out loading screen

MapTestMode 	DB	0		;1 = map test enabled

		EVEN

;------------------------
;* title picture filename
;------------------------

	IF	OPT_TITLE_PIC EQ 1

TitlePic	DB	"TITLEPIC.PT2",0

		EVEN

	ENDIF

;--------------------------
;* DI logo picture filename
;--------------------------

	IF	OPT_LOGO_PIC EQ 1

LogoPic		DB	"DILOGO.PT2",0

		EVEN

	ENDIF

;--------------------
;* map test viewpoint (start at bottom lh corner of map)
;--------------------

TEST_VIEW	VIEWPOINT <0,31,-8192,-8192,0,0,0,0>

DATA		ENDS

;============================================================================

CODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:CODE
		ASSUME DS:DATA

;* Control
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

Control		PROC	NEAR

;---------------------------------
;* mouse essential - ensure fitted
;---------------------------------

		test	MouseFlag,1	;mouse fitted?
		jnz	@F		;yes ->

		mov	DieFlag,SYS_ERR_MOUSE

		jmp	ControlExit	;no ->

;------------------------
;* set maximum frame rate 
;------------------------

;* The timer interrupt is 100Hz. There is not enough resolution to handle
;* frame rates above 20 frames / second. Also the keyboard scan interrupt
;* is set to 20Hz and must be more frequent than the frame rate.

@@:		mov	MaxFrameRate,6	;6/100th = 17 frames / second

;----------------------
;* command line options
;----------------------

		call	SortCmndLine

;-----------------------------
;* load game play and map data
;-----------------------------

		test	DataExchange,1	;exchange data?
		jz	@F		;no ->

		call	LoadGameData
		_JC	ControlExit	;disk error ->

		call	LoadMapData
		_JC	ControlExit	;disk error ->

;-------------------------
;* fade out loading screen
;-------------------------

@@:		test	FadeOutFlag,1	;fade out loading screen?
		jz	@F		;no ->

		call	FadeLoadScreen

;---------------------------------------------------
;* init graphics mode / init random number generator
;---------------------------------------------------

@@:		mov	ax,VGA
		call	QuickSetUp

;--------------------
;* show title picture 
;--------------------

	IF	OPT_TITLE_PIC EQ 1

		mov	dx,OFFSET TitlePic
		mov	cx,5*100
		xor	al,al		;regular fades
		call	LoadPicture

		cmp	DieFlag,0	;quit or loading error?
		_JNE	ControlExit	;yes ->

	ENDIF

;----------------------
;* show DI logo picture 
;----------------------

	IF	OPT_LOGO_PIC EQ 1

		mov	dx,OFFSET LogoPic
		mov	cx,5*100
		xor	al,al		;regular fades
		call	LoadPicture

		cmp	DieFlag,0	;quit or loading error?
		_JNE	ControlExit	;yes ->

	ENDIF

;---------------
;* set up visual
;---------------

;* if two player then fix random number seed (keep clouds the same)

		push	SeedLo
		push	SeedHi

		test	TwoPlayer,1
		jz	@F

		mov	SeedLo,12431
		mov	SeedHi,8765

@@:		call	ConfigureVisual

		pop	SeedHi
		pop	SeedLo

		jnc	@F		;palette RGB data loaded ok ->

		mov	DieFlag,SYS_ERR_RGB

		jmp	ControlExit

@@:		test	DataExchange,1	;exchange data?
		jnz	@F		;yes ->

		call	SwitchOnLights

;--------------------------
;* test for "map test" mode
;--------------------------

@@:		test	MapTestMode,1	;map test enabled?
		jz	@F		;no ->

		call	MapTest

		jmp	ControlExit

;---------------
;* resize memory
;---------------

@@:		call	ResizeMemory
		_JC	ControlExit

;-------------------
;* load sound driver
;-------------------

		call	InstallSound
		_JC	ControlExit

;-------------------
;* load music driver
;-------------------

		call	InstallMusic
		_JC	ControlExit

;-------------------------
;* test for "explore" mode
;-------------------------

		test	ExploreMode,1	;map explore mode?
		jz	@F		;no ->

		call	MapExplore

		call	FadeOut

		jmp	SaveData

;-------------------------
;* test for "preview" mode
;-------------------------

@@:		cmp	PreviewMode,0	;preview mode?
		je	@F		;no ->

		call	ObjectPreview

		jmp	SaveData

;-----------------
;* init panel data
;-----------------

@@:		cmp	DemoMode,0	;demo mode?
		jne	@F		;yes, panels not required ->

		call	InitPanels
		jnc	@F		;panel data loaded ok ->

		mov	DieFlag,SYS_ERR_PANELS

		jmp	ControlExit

;-------------------------------
;* install user timer interrupts
;-------------------------------

@@:		mov	ax,OFFSET GameIntr20
		mov	dx,SEG GameIntr20
		call	InstallUser20

		mov	ax,OFFSET GameIntr100
		mov	dx,SEG GameIntr100
		call	InstallUser100

;-----------------
;* initialize game
;-----------------

		call	InitGame

;------------------------
;* sort startup view mode
;------------------------

		mov	ax,VIEW_PILOT	;assume not demo

		cmp	DemoMode,0	;demo mode?
		je	@F		;no ->

		call	InitDemo

@@:		call	SetGameViewMode

;----------------------------
;* test for "two player" mode
;----------------------------

		test	TwoPlayer,1	;two player?
		_JNZ	TwoPlyrControl	;yes ->

;--------------
;* reset timers (because of time taken to initialize (load files etc.))
;--------------

		xor	ax,ax

		cli
		mov	Frames,ax
		mov	WORD PTR ElapsedTime,ax
		mov	WORD PTR ElapsedTime+2,ax
		sti

;------------------
;* initialize model
;------------------

		call	InitModel

;--------------
;* control loop
;--------------

ControlLoop	LABEL	NEAR

;-------
;* model
;-------

		call	Model

;----------
;* gameplay
;----------

		call	UpdatePlanes

		call	UpdateHelicops

		call	UpdateConvoys

		call	UpdateAAA

		call	UpdateSAM

		call	UpdateWeapons

		call	UpdateGLOC

;----------------------------
;* avionics / weapons systems
;----------------------------

		call	UpdateAvionics
		
		call	WeaponsControl

;--------
;* visual
;--------

		call	UserOptions

		call	UpdateGameView

		mov	si,ViewPtr
		cmp	si,-1		;visual disabled?
		je	@F		;yes ->

		call	Visual

;-------
;* panel
;-------

@@:		call	UpdatePanel

;---------------
;* sound effects
;---------------

		call	UpdateSound

;-----------------
;* download screen
;-----------------

	IF	OPT_DEBUG EQ 1

		test	Key[K_HASH],1
		jz	@F
		call	PrintDebugInfo
@@:

	ENDIF

	IF	OPT_DEBUG EQ 1

		test	Key[K_F11],1
		jz	@F
		call	VisualInfo
@@:		
	
	ENDIF

		call	DownLoad

		call	SortPause

	IF	OPT_PHOTO EQ 1

		test	Key[K_F12],1
		jz	@F
		call	VGAPhotoDflt
@@:		

	ENDIF

;----------------------
;* test for end of game
;----------------------

		call	CheckTimeout

		cmp	DieFlag,0	;end of game condition?
		_JE	ControlLoop	;no ->

		call	NormaliseSound
		call	NormaliseMusic

		call	FadeOut

;-----------------------------
;* same game play and map data
;-----------------------------

SaveData:	test	DataExchange,1	;exchange data?
		jz	ControlExit	;no ->

		call	SaveGameData
		jc	ControlExit	;disk error ->

		call	SaveMapData
		jc	ControlExit	;disk error ->

;---------------------------
ControlExit	LABEL	NEAR
;---------------------------

		call	NormaliseSound
		call	NormaliseMusic

		mov	al,DieFlag
		mov	ReturnCode,al

		ret

;---------------------------
TwoPlyrControl	LABEL	NEAR
;---------------------------

		call	InitTwoPlayer

;------------
;* init comms
;------------

		mov	al,CommsDevice
		mov	ah,BaudRate
		call	InitComms

;------------------
;* comms start sync
;------------------

		mov	al,-2
		mov	ah,1		;Ctrl Q enabled
		mov	cx,30*100
		call	SyncComms
		jnc	@F		;sync received ->

		mov	DieFlag,SYS_ERR_SYNC_TO

		jmp	ControlExit

;-----------------------
;* transmit Tornado data
;-----------------------

@@:		call	TxTornadoData

;-----------------------
;* receive opponent data
;-----------------------

		call	RxOpponentData

;---------
;* re-sync
;---------

		mov	al,-3
		xor	ah,ah		;Ctrl Q disabled
		mov	cx,2*100
		call	SyncComms

;--------------
;* reset timers (because of time taken to initialize / sync up)
;--------------

		xor	ax,ax

		cli
		mov	Frames,ax
		mov	WORD PTR ElapsedTime,ax
		mov	WORD PTR ElapsedTime+2,ax
		sti

;------------------
;* initialize model
;------------------

		call	InitModel

;-------------------------
;* two player control loop
;-------------------------

TwoPlayerLoop	LABEL	NEAR

;-------
;* model
;-------

		call	Model

;-----------
;* loop sync (sync after joystick has been read)
;-----------

		call	ClearComms

		mov	al,-4
		xor	ah,ah		;Ctrl Q disabled
		mov	cx,2*100
		call	SyncComms

;----------
;* gameplay
;----------

		call	UpdateWeapons

		call	UpdateGLOC

;----------------------------
;* avionics / weapons systems
;----------------------------

		call	UpdateAvionics
		
		call	WeaponsControl

;-----------------------
;* transmit Tornado data
;-----------------------

		call	TxTornadoData

;--------
;* visual
;--------

		call	UserOptions

		call	UpdateGameView

		mov	si,ViewPtr
		cmp	si,-1		;visual disabled?
		je	@F		;yes ->

;* visual enabled - receive opponent data in UserVisual

		mov	RxFlag,1

		call	Visual

		mov	RxFlag,0

		jmp	RxDataOk

;* visual disabled - receive opponent data here

@@:		call	RxOpponentData

;-------
;* panel
;-------

RxDataOk:	call	UpdatePanel

;---------------
;* sound effects
;---------------

		call	UpdateSound

;-----------------
;* download screen
;-----------------

	IF	OPT_DEBUG EQ 1

		test	Key[K_HASH],1
		jz	@F
		call	PrintDebugInfo
@@:	

	ENDIF

	IF	OPT_DEBUG EQ 1

		test	Key[K_F11],1
		jz	@F
		call	VisualInfo
@@:		
	
	ENDIF

		call	DownLoad

;----------------------
;* test for end of game
;----------------------

		call	CheckTimeout

		cmp	DieFlag,0	;end of game condition?
		_JE	TwoPlayerLoop	;no ->

		mov	al,TxGameEnd	;sent or received game end flag?
		or	al,RxGameEnd
		_JZ	TwoPlayerLoop	;no ->

		call	StopComms

		call	NormaliseSound
		call	NormaliseMusic

		call	FadeOut

		jmp	SaveData

Control		ENDP

;----------------------------------------------------------------------------

;* SortCmndLine
;*
;* pass: ARGC
;*       ARGV[]
;* ret : nothing
;* kill: assume all

SortCmndLine	PROC	NEAR

		mov	cx,ARGC

		_JCXZ	ExitCmndLine

		xor	bx,bx

ArgLoop:	mov	si,ARGV[bx]

		mov	ah,[si+0]	;ah = 1st character
		mov	al,[si+1]	;al = 2nd character

;* convert 1st character to uppercase

		cmp	ah,'a'
		jb	@F
		cmp	ah,'z'
		ja	@F

		sub	ah,'a'-'A'

;* convert 2nd character to uppercase

@@:		cmp	al,'a'
		jb	@F
		cmp	al,'z'
		ja	@F

		sub	al,'a'-'A'

;* check for valid options

@@:		cmp	ax,'AH'		;set heading (for start airborne)?
		_JE	SetHeading	;yes ->

		cmp	ax,'AV'		;set airspeed (for start airborne)?
		_JE	SetAirspeed	;yes ->

		cmp	ax,'AX'		;set x sector (for start airborne)?
		_JE	SetXSector	;yes ->

		cmp	ax,'AY'		;set y sector (for start airborne)?
		_JE	SetYSector	;yes ->

		cmp	ax,'AZ'		;set altitude (for start airborne)?
		_JE	SetAltitude	;yes ->

		cmp	ah,'A'		;start airborne?
		_JE	SetAirborne	;yes ->

		cmp	ah,'B'		;Baud rate?
		_JE	SetBaudRate	;yes ->

		cmp	ax,"CH"		;CH FlightStick Pro?
		_JE	SetFlightStick	;yes ->

		cmp	ah,'C'		;cockpit lighting?
		_JE	SetLighting	;yes ->

		cmp	ax,"DX"		;exchange data?
		_JE	SetDataExchange	;yes ->

		cmp	ax,'D1'		;drone cycling demo mode?
		_JE	SetDemoMode1	;yes ->
		
		cmp	ax,'D2'		;flying demo mode?
		_JE	SetDemoMode2	;yes ->
		
		cmp	ah,'E'		;explore mode?
		_JE	SetExploreMode	;yes ->

		cmp	ax,"FO"		;fade out loading screen?
		_JE	SetFadeOut	;yes ->

		cmp	ax,"FR"		;set maximum frame rate?
		_JE	SetFrameRate	;yes ->

		cmp	ah,'F'		;fog?
		_JE	SetFog		;yes ->

		cmp	ax,"GT"		;global timeout?
		_JE	SetTimeout	;yes ->

		cmp	ax,"IF"		;infinite fuel?
		_JE	SetInfiniteFuel	;yes ->

		cmp	ax,"IG"		;infinite g-force?
		_JE	SetInfiniteG	;yes ->

		cmp	ax,"IW"		;infinite weapons?
		_JE	SetInfiniteWpns	;yes ->

		cmp	ax,"MA"		;AdLib card?
		_JE	SetAdLibMusic	;yes ->

		cmp	ax,"MB"		;SoundBlaster card?
		_JE	SetBlasterMusic	;yes ->

		cmp	ax,"MN"		;no sound card?
		_JE	SetNoMusic	;yes ->

		cmp	ax,"MR"		;Roland LAPC1 card?
		_JE	SetRolandMusic	;yes ->

		cmp	ax,"MS"		;internal speaker?
		_JE	SetSpeakerMusic	;yes ->

		cmp	ax,"MT"		;map test?
		_JE	SetMapTestMode	;yes ->

		cmp	ax,"NC"		;no collisions?
		_JE	SetNoCollisions	;yes ->

		cmp	ah,'N'		;night?
		_JE	SetNight	;yes ->

		cmp	ah,'O'		;overcast?
		_JE	SetOvercast	;yes ->

		cmp	ax,'PA'		;auto-run preview mode?
		_JE	SetPreviewAuto	;yes ->

		cmp	ah,'P'		;preview mode?
		_JE	SetPreviewMode	;yes ->

		cmp	ax,'QS'		;quick start?
		_JE	SetQuickStart	;yes ->

		cmp	ax,"RT"		;radar test enabled?
		_JE	SetRadarTest	;yes ->

		cmp	ax,"SA"		;AdLib card?
		_JE	SetAdLib	;yes ->

		cmp	ax,"SB"		;SoundBlaster card?
		_JE	SetSoundBlaster	;yes ->

		cmp	ax,"SN"		;no sound card?
		_JE	SetNoSound	;yes ->

		cmp	ax,"SR"		;Roland LAPC1 card?
		_JE	SetRoland	;yes ->

		cmp	ax,"SS"		;internal speaker?
		_JE	SetSpeaker	;yes ->

		cmp	ax,"T1"		;two player, com1?
		_JE	SetCom1		;yes ->

		cmp	ax,"T2"		;two player, com2?
		_JE	SetCom2		;yes ->

		cmp	ax,"TM"		;ThrustMaster?
		_JE	SetThrustMaster	;yes ->

		cmp	ah,'V'		;set variant?
		_JE	SetVariant	;yes ->

		cmp	ah,'W'		;set fixed weight?
		_JE	SetWeight	;yes ->

		cmp	ax,'XW'		;set crosswinds?
		_JE	SetXWinds	;yes ->

NextArg:	add	bx,2

		_LOOP	ArgLoop

ExitCmndLine:	ret

;---------------------------
SetHeading	LABEL	NEAR
;---------------------------

;* format expected: "/ah180" (range = 0 .. 360)

		add	si,2		;si -> number

		push	bx
		push	cx
		call	ConvNum$
		pop	cx
		pop	bx

;* limit max

		cmp	dx,0
		ja	SetMaxHdg
		cmp	ax,360
		ja	SetMaxHdg

;* convert degs to pdegs

HdgOk:		mov	dx,46603	;512 / 360 * 32768 = 46603
		mul	dx
		FRACADJ	dx
		
		and	dx,511		;0 .. 511
		mov	M_VIEW.VP_HDG,dx

		jmp	NextArg

SetMaxHdg:	mov	ax,360

		jmp	HdgOk

;---------------------------
SetAirspeed	LABEL	NEAR
;---------------------------

;* format expected: "/av450" (range = 200 .. 800)

		add	si,2		;si -> number

		push	bx
		push	cx
		call	ConvNum$
		pop	cx
		pop	bx

;* limit max

		cmp	dx,0
		ja	SetMaxSpeed
		cmp	ax,800
		ja	SetMaxSpeed

;* limit min

		cmp	ax,200
		jb	SetMinSpeed

SpeedOk:	mov	StartAirspeed,ax

		jmp	NextArg

SetMaxSpeed:	mov	ax,800

		jmp	SpeedOk

SetMinSpeed:	mov	ax,200

		jmp	SpeedOk

;---------------------------
SetXSector	LABEL	NEAR
;---------------------------

;* format expected: "/ax10" (range = 0 .. 31)

		add	si,2		;si -> number

		push	bx
		push	cx
		call	ConvNum$
		pop	cx
		pop	bx

		and	ax,31		;0 .. 31

		mov	M_VIEW.VP_XSEC,ax
		mov	M_VIEW.VP_XFT,0

		jmp	NextArg

;---------------------------
SetYSector	LABEL	NEAR
;---------------------------

;* format expected: "/ay10" (range = 0 .. 31)

		add	si,2		;si -> number

		push	bx
		push	cx
		call	ConvNum$
		pop	cx
		pop	bx

		and	ax,31		;0 .. 31

		mov	M_VIEW.VP_YSEC,ax
		mov	M_VIEW.VP_YFT,0

		jmp	NextArg

;---------------------------
SetAltitude	LABEL	NEAR
;---------------------------

;* format expected: "/az5000" (range = 1 .. 99999)

		add	si,2		;si -> number

		push	bx
		push	cx
		call	ConvNum$
		pop	cx
		pop	bx

;* limit min

		mov	bp,ax
		or	bp,dx		;zero?
		jnz	@F		;no ->

		mov	ax,1

;* set altitude

@@:		mov	WORD PTR M_VIEW.VP_ZFT_LO,ax
		mov	WORD PTR M_VIEW.VP_ZFT_HI,dx

		jmp	NextArg

;---------------------------
SetAirborne	LABEL	NEAR
;---------------------------

;* start airborne / alt = 5000ft / ias = 450kts

		mov	StartAirborne,1

		mov	WORD PTR M_VIEW.VP_ZFT_LO,5000
		mov	WORD PTR M_VIEW.VP_ZFT_HI,0

		mov	StartAirspeed,450

		jmp	NextArg

;---------------------------
SetBaudRate	LABEL	NEAR
;---------------------------

;* format expected: "/b96" (range = 12 .. 1152)

		inc	si		;si -> number

		push	bx
		push	cx
		call	ConvNum$
		pop	cx
		pop	bx

		mov	dl,BAUD1200
		cmp	ax,12
		jbe	@F

		mov	dl,BAUD2400
		cmp	ax,24
		jbe	@F

		mov	dl,BAUD4800
		cmp	ax,48
		jbe	@F

		mov	dl,BAUD9600
		cmp	ax,96
		jbe	@F

		mov	dl,BAUD14400
		cmp	ax,144
		jbe	@F

		mov	dl,BAUD19200
		cmp	ax,192
		jbe	@F

		mov	dl,BAUD38400
		cmp	ax,384
		jbe	@F

		mov	dl,BAUD57600
		cmp	ax,576
		jbe	@F

		mov	dl,BAUD115200

@@:		mov	BaudRate,dl

		jmp	NextArg

;---------------------------
SetFlightStick	LABEL	NEAR
;---------------------------

		mov	CHStick,1

		jmp	NextArg

;---------------------------
SetLighting	LABEL	NEAR
;---------------------------

;* format expected: "/cg" = green lighting
;*                  "/cr" = red lighting

		mov	ah,0		;assume red

		cmp	al,'R'		;red lighting?
		je	@F		;yes ->

		mov	ah,1		;green

@@:		mov	PanelLight,ah

		jmp	NextArg

;---------------------------
SetDataExchange	LABEL	NEAR
;---------------------------

		mov	DataExchange,1

		mov	FadeOutFlag,1

		jmp	NextArg

;---------------------------
SetDemoMode1	LABEL	NEAR
;---------------------------

		mov	DemoMode,1

		jmp	NextArg

;---------------------------
SetDemoMode2	LABEL	NEAR
;---------------------------

		mov	DemoMode,2

		jmp	NextArg

;---------------------------
SetExploreMode	LABEL	NEAR
;---------------------------

		mov	ExploreMode,1

		jmp	NextArg

;---------------------------
SetFadeOut	LABEL	NEAR
;---------------------------

		mov	FadeOutFlag,1

		jmp	NextArg

;---------------------------
SetFrameRate	LABEL	NEAR
;---------------------------

;* format expected: "/fr4" (range = 1 .. 16)

		add	si,2		;si -> number

		push	bx
		push	cx
		call	ConvNum$
		pop	cx
		pop	bx

;* limit max

		cmp	dx,0
		ja	SetMaxFrames
		cmp	ax,16
		ja	SetMaxFrames

;* limit min

		cmp	ax,1
		jb	SetMinFrames

;* max frame rate = 100 / frames per sec

FramesOk:	mov	bx,ax

		xor	dx,dx
		mov	ax,100

		div	bx

		mov	MaxFrameRate,ax

		jmp	NextArg

SetMaxFrames:	mov	ax,16

		jmp	FramesOk

SetMinFrames:	mov	ax,1

		jmp	FramesOk

;---------------------------
SetFog		LABEL	NEAR
;---------------------------

;* format expected: "/f1" = light fog
;*                  "/f2" = heavy fog

		cmp	al,'1'		;light fog?
		je	@F		;yes ->

		cmp	al,'2'		;heavy fog?
		je	@F

		mov	al,'1'		;default to light fog

@@:		sub	al,'0'

		mov	Fog,al

		mov	Overcast,1	;always overcast if foggy

		jmp	NextArg

;---------------------------
SetTimeout	LABEL	NEAR
;---------------------------

;* format expected: "/gt300" (range = 0 .. 99999)

		add	si,2		;si -> number

		push	bx
		push	cx

		call	ConvNum$

;* convert to secs * 100

		REPT	2		;*4
		shl	ax,1
		rcl	dx,1
		ENDM

		mov	bx,ax
		mov	cx,dx

		REPT	3		;*8 (*32)
		shl	ax,1
		rcl	dx,1
		ENDM

		add	bx,ax		;*36
		adc	cx,dx

		REPT	1		;*1 (*64)
		shl	ax,1
		rcl	dx,1
		ENDM

		add	ax,bx		;*100
		adc	dx,cx

		mov	WORD PTR TimeLimit,ax
		mov	WORD PTR TimeLimit+2,dx

		pop	cx
		pop	bx

		mov	GlobalTimeout,1

		jmp	NextArg

;---------------------------
SetInfiniteFuel	LABEL	NEAR
;---------------------------

		mov	InfiniteFuel,1

		jmp	NextArg

;---------------------------
SetInfiniteG	LABEL	NEAR
;---------------------------

		mov	InfiniteGForce,1

		jmp	NextArg

;---------------------------
SetInfiniteWpns	LABEL	NEAR
;---------------------------

		mov	InfiniteWeapons,1

		jmp	NextArg

;---------------------------
SetAdLibMusic	LABEL	NEAR
;---------------------------

		mov	MusicCard,SND_ADLIB

		jmp	NextArg

;---------------------------
SetBlasterMusic	LABEL	NEAR
;---------------------------

		mov	MusicCard,SND_SBLASTER

		jmp	NextArg

;---------------------------
SetNoMusic	LABEL	NEAR
;---------------------------

		mov	MusicCard,SND_NULL

		jmp	NextArg

;---------------------------
SetRolandMusic	LABEL	NEAR
;---------------------------

		mov	MusicCard,SND_ROLAND

		jmp	NextArg

;---------------------------
SetSpeakerMusic	LABEL	NEAR
;---------------------------

		mov	MusicCard,SND_SPEAKER

		jmp	NextArg

;---------------------------
SetMapTestMode	LABEL	NEAR
;---------------------------

		mov	MapTestMode,1

		jmp	NextArg

;---------------------------
SetNoCollisions	LABEL	NEAR
;---------------------------

		mov	NoCollisions,1

		jmp	NextArg

;---------------------------
SetNight	LABEL	NEAR
;---------------------------

;* format expected: "/n1" = night 1 (dusk)
;*                  "/n2" = night 2
;*                  "/n3" = night 3
;*                  "/n4" = night 4 (midnight)

		cmp	al,'1'		;night 1?
		je	@F		;yes ->

		cmp	al,'2'		;night 2?
		je	@F		;yes ->

		cmp	al,'3'		;night 3?
		je	@F		;yes ->

		cmp	al,'4'		;night 4?
		je	@F		;yes ->

		mov	al,'1'		;default to dusk

@@:		sub	al,'0'

		mov	Night,al

		jmp	NextArg

;---------------------------
SetOvercast	LABEL	NEAR
;---------------------------

		mov	Overcast,1

		jmp	NextArg

;---------------------------
SetPreviewAuto	LABEL	NEAR
;---------------------------

		mov	PreviewMode,2

		jmp	NextArg

;---------------------------
SetPreviewMode	LABEL	NEAR
;---------------------------

		mov	PreviewMode,1

		jmp	NextArg

;---------------------------
SetQuickStart	LABEL	NEAR
;---------------------------

;* "/qs" is same as "/a /if /ig /iw /nc /w"

		mov	StartAirborne,1

		mov	WORD PTR M_VIEW.VP_ZFT_LO,5000
		mov	WORD PTR M_VIEW.VP_ZFT_HI,0

		mov	StartAirspeed,450

		mov	InfiniteFuel,1

		mov	InfiniteGForce,1

		mov	InfiniteWeapons,1

		mov	NoCollisions,1

		mov	FixedWeight,33000

		mov	DebugWeight,1

		jmp	NextArg

;---------------------------
SetRadarTest	LABEL	NEAR
;---------------------------

		mov	RadarTest,1

		jmp	NextArg

;---------------------------
SetAdLib	LABEL	NEAR
;---------------------------

		mov	SoundCard,SND_ADLIB

		jmp	NextArg

;---------------------------
SetSoundBlaster	LABEL	NEAR
;---------------------------

		mov	SoundCard,SND_SBLASTER

		jmp	NextArg

;---------------------------
SetNoSound	LABEL	NEAR
;---------------------------

		mov	SoundCard,SND_NULL

		jmp	NextArg

;---------------------------
SetRoland	LABEL	NEAR
;---------------------------

		mov	SoundCard,SND_ROLAND

		jmp	NextArg

;---------------------------
SetSpeaker	LABEL	NEAR
;---------------------------

		mov	SoundCard,SND_SPEAKER

		jmp	NextArg

;---------------------------
SetCom1		LABEL	NEAR
;---------------------------

		mov	TwoPlayer,1
		mov	CommsDevice,COM1
		mov	BaudRate,BAUD9600

		jmp	NextArg

;---------------------------
SetCom2		LABEL	NEAR
;---------------------------

		mov	TwoPlayer,1
		mov	CommsDevice,COM2
		mov	BaudRate,BAUD9600

		jmp	NextArg

;---------------------------
SetThrustMaster	LABEL	NEAR
;---------------------------

		mov	ThrustMaster,1

		jmp	NextArg

;---------------------------
SetVariant	LABEL	NEAR
;---------------------------

		mov	dx,ADV_TORNADO
		cmp	al,'A'
		je	@F

		mov	dx,ECR_TORNADO
		cmp	al,'E'
		je	@F

		mov	dx,IDS_TORNADO

@@:		mov	TornadoType,dx

;* sort ADV stores

		cmp	dx,ADV_TORNADO
		jne	StoresOk

;* clear IDS only stores

		xor	ax,ax

		mov	ExtStores[EXT_GPB1000],ax
		mov	ExtStores[EXT_RET1000],ax
		mov	ExtStores[EXT_LGB1000],ax
		mov	ExtStores[EXT_BL755],ax
		mov	ExtStores[EXT_JP233],ax
		mov	ExtStores[EXT_ALARM],ax
		mov	ExtStores[EXT_BOZ100],ax
		mov	ExtStores[EXT_SKYSHADOW],ax

		push	cx

		mov	si,OFFSET Packages

		mov	cx,NUM_PACKAGES

@@:		mov	[si].PACK_WEAP_TYPE,NULL_WEAPON
		add	si,PACK_REC_SIZE
		loop	@B

		mov	PackagePtr,-1

		pop	cx

;* ensure Sky Flash loaded

		cmp	ExtStores[EXT_SKYFLASH],0
		ja	StoresOk

	IF	OPT_FLY_DEMO EQ 0

		mov	ExtStores[EXT_SKYFLASH],4

	ENDIF

StoresOk:	jmp	NextArg

;---------------------------
SetWeight	LABEL	NEAR
;---------------------------

;* format expected: "/w45000" (range = 33000 .. 60000)

		inc	si		;si -> number

		push	bx
		push	cx
		call	ConvNum$
		pop	cx
		pop	bx

;* limit max

		cmp	dx,0
		ja	SetMaxWeight
		cmp	ax,60000
		ja	SetMaxWeight

;* limit min

		cmp	ax,33000
		jb	SetMinWeight

WeightOk:	mov	FixedWeight,ax

		mov	DebugWeight,1

		jmp	NextArg

SetMaxWeight:	mov	ax,60000

		jmp	WeightOk

SetMinWeight:	mov	ax,33000

		jmp	WeightOk

;---------------------------
SetXWinds	LABEL	NEAR
;---------------------------

;* format expected: "/xw20" (range = 5 .. 75)

		add	si,2		;si -> number

		push	bx
		push	cx
		call	ConvNum$
		pop	cx
		pop	bx

		cmp	ax,75
		jbe	@F
		mov	ax,75

@@:		cmp	ax,5
		jae	@F
		mov	ax,5

;* convert knots to ft/sec

@@:		mov	dx,3482		;3482 = 1.7 * 8 * 256
		mul	dx
		mov	al,ah		;/256
		mov	ah,dl

		mov	XWindVmax,ax

;* set headwind

		mov	ax,M_VIEW.VP_HDG
		mov	XWindDir,ax

		jmp	NextArg

SortCmndLine	ENDP

;----------------------------------------------------------------------------

;* SortPause - test for and handle pause
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

SortPause	PROC	NEAR

		KTEST	KF_Pause	;key pressed?
		_JZ	ExitPause	;no ->

		mov	Paused,1

		call	SuspendSound
		call	SuspendMusic

;* store timers / counters

		cli
		push	Ticker
		push	Frames
		push	CountDown
		push	WORD PTR ElapsedTime
		push	WORD PTR ElapsedTime+2
		sti

		call	FadeDown

		mov	Frames,0

PauseLoop:	mov	ax,Frames
		cmp	ax,MaxFrameRate
		jb	PauseLoop

		mov	Frames,0

		KBOUNCE	KF_Quit
		KBOUNCE	KF_Pause

		KTEST	KF_Quit
		jz	SkipQuit

;* if TmpDieFlag <> 0 then
;*    DieFlag = TmpDieFlag
;* else
;*    DieFlag = DIE_QUIT
;* endif

		mov	al,TmpDieFlag

		test	al,al
		jnz	@F

		mov	al,DIE_QUIT

@@:		mov	DieFlag,al

		jmp	PauseDone

SkipQuit: 	KTEST	KF_Pause
		jz	PauseLoop

PauseDone: 	call	FadeUp

;* restore timers / counters

		cli
		pop	WORD PTR ElapsedTime+2
		pop	WORD PTR ElapsedTime
		pop	CountDown
		pop	Frames
		pop	Ticker
		sti

		call	ResumeSound
		call	ResumeMusic

		mov	Paused,0

ExitPause:	ret

SortPause	ENDP

;----------------------------------------------------------------------------

;* InitDemo
;*
;* pass: nothing
;* ret : ax = game viewmode
;* kill: assume all

InitDemo	PROC	NEAR

		cmp	DemoMode,1	;cycling demo?
		jne	InitFlyingDemo	;no ->

;---------------------------
InitCyclingDemo	LABEL	NEAR		;init drone cycling demo mode
;---------------------------

		mov	DisableInput,DIP_DEMO

		mov	InfiniteFuel,1

		mov	NoCollisions,1

		mov	NoFire,1

		mov	ax,VIEW_DEMO

		ret

;---------------------------
InitFlyingDemo	LABEL	NEAR		;init flying demo mode
;---------------------------

;* note: Assume that the waypoint route is "continuous" (see MAINDATA.ASM),
;*       and that there are at least 3 waypoints.

		mov	DisableInput,DIP_DEMO

		mov	StartAirborne,1

		mov	InfiniteFuel,1

		mov	AutoTrack,1

		mov	NoCollisions,1

		mov	NoFire,1

		mov	TrkCamBrg,256+16

;* delete Tornado mobile

		mov	si,OFFSET M_MOBILE
		call	DeleteMobile

;* start at current waypoint

		mov	si,WPPtr

		mov	ax,[si].WP_XSEC
		mov	M_VIEW.VP_XSEC,ax

		mov	ax,[si].WP_YSEC
		mov	M_VIEW.VP_YSEC,ax

		mov	ax,[si].WP_XFT
		mov	M_VIEW.VP_XFT,ax

		mov	ax,[si].WP_YFT
		mov	M_VIEW.VP_YFT,ax

		mov	ax,[si].WP_ZFT
		mov	WORD PTR M_VIEW.VP_ZFT_LO,ax
		mov	WORD PTR M_VIEW.VP_ZFT_HI,0

;* convert vtas (ft/sec * 8) to vias

		mov	ax,[si].WP_SPEED

		xor	dh,dh		;*256
		mov	dl,ah
		mov	ah,al
		xor	al,al

		mov	bx,3482		;1.7 * 8 * 256 = 3482
		div	bx

		mov	StartAirspeed,ax

;* hdg = brg to next waypoint

		call	AdvanceWP	

		mov	ax,WPBrg

		mov	M_VIEW.VP_HDG,ax

		mov	M_VIEW.VP_PITCH,0
		mov	M_VIEW.VP_ROLL,0

;* create Tornado mobile

		mov	si,OFFSET M_MOBILE
		call	CreateMobile

		mov	ax,VIEW_TRACKING

		ret

InitDemo	ENDP

;----------------------------------------------------------------------------

;* MapTest
;*
;* pass: nothing
;* ret : DieFlag
;* kill: assume all
;*
;* note: This test may take hours to complete! Every sector is viewed at
;*	 1024ft intervals. At 10 frames per second this would take:-
;*
;*	    32 * 32 * 16 * 16 / 10 / 60 / 60 = 7.3 hours

MapTest		PROC	NEAR

		mov	ax,EXT_VIEWMODE
		call	SetViewMode

;* for xsec = 0 to 31
;*    for xft = -8192 to 7168 step 1024
;*       for y sec = 31 to 0
;*          for yft = -8192 to 7168 step 1024
;*             draw visual
;*          next yft
;*       next ysec
;*    next xft
;* next xsec

		mov	TEST_VIEW.VP_XSEC,0

NextXSec:	mov	TEST_VIEW.VP_XFT,-8192

NextXft:	mov	TEST_VIEW.VP_YSEC,31

NextYSec:	mov	TEST_VIEW.VP_YFT,-8192

NextYft:	mov	si,OFFSET TEST_VIEW
		call	CalcGndHeight
		add	ax,250
		mov	WORD PTR TEST_VIEW.VP_ZFT_LO,ax

		mov	si,OFFSET TEST_VIEW
		call	Visual

		call	VisualInfo

		call	DownLoad

		mov	al,Key[K_CTRL]		;CTRL-Q quits map test
		and	al,Key[K_Q]
		jnz	QuitMapTest		;quit ->

		add	TEST_VIEW.VP_YFT,1024
		cmp	TEST_VIEW.VP_YFT,8191
		jle	NextYft

		sub	TEST_VIEW.VP_YSEC,1
		cmp	TEST_VIEW.VP_YSEC,0
		jge	NextYSec

		add	TEST_VIEW.VP_XFT,1024
		cmp	TEST_VIEW.VP_XFT,8191
		jle	NextXft

		add	TEST_VIEW.VP_XSEC,1
		cmp	TEST_VIEW.VP_XSEC,31
		jle	NextXSec

		mov	DieFlag,SYS_ERR_MAP_OK

		ret

QuitMapTest:	mov	DieFlag,DIE_QUIT

		ret

MapTest		ENDP

;----------------------------------------------------------------------------

;* ResizeMemory
;*
;* pass: PSP
;* ret : cf = 0 = ok
;*	 cf = 1 = error
;*	    DieFlag
;* kill: assume all

ResizeMemory	PROC	NEAR

;* calc program size in paragraphs (16 byte units)
;*
;* size = SEG PROG_END - PSP + OFFSET PROG_END / 16 + 1

		mov	bx,SEG PROG_END
		sub	bx,PSP

		mov	ax,OFFSET PROG_END
		mov	cl,4
		shr	ax,cl		;/16
		inc	ax

		add	bx,ax

;* resize memory block

		push	es
		mov	es,PSP
		mov	ah,04ah
		int	021h
		pop	es
		jnc	@F		;no error ->

		mov	DieFlag,SYS_ERR_RESIZE

@@:		ret

ResizeMemory	ENDP

;----------------------------------------------------------------------------

;* FadeLoadScreen - fade out loading screen (if loaded from mission planner)
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

FadeLoadScreen	PROC	NEAR

;------------------------------------
;* save palette data into work screen
;------------------------------------

		push	ds
		push	es

		mov	si,SEG VGA_RGB_Data
		mov	ds,si
		mov	si,OFFSET VGA_RGB_Data

		mov	di,SEG WorkScreen
		mov	es,di
		mov	di,OFFSET WorkScreen

		mov	cx,256*3	;256 * RGB
		FAST_MOVE

;-------------------------
;* read current DAC values
;-------------------------

		mov	di,SEG VGA_RGB_Data
		mov	es,di
		mov	di,OFFSET VGA_RGB_Data

		xor	al,al		;start col 0
		mov	cx,256		;read all RGB values

		call	ReadDACBlock

		pop	es
		pop	ds

;-------------------------
;* fade out loading screen
;-------------------------

		call	FadeOut

;------------------------------------
;* load palette data from work screen
;------------------------------------

		push	ds
		push	es

		mov	si,SEG WorkScreen
		mov	ds,si
		mov	si,OFFSET WorkScreen

		mov	di,SEG VGA_RGB_Data
		mov	es,di
		mov	di,OFFSET VGA_RGB_Data

		mov	cx,256*3	;256 * RGB
		FAST_MOVE

		pop	es
		pop	ds

		ret

FadeLoadScreen	ENDP

;----------------------------------------------------------------------------

;* CheckTimeout - check for timeout
;*
;* pass: GlobalTimeout
;*       TimeLimit 
;*	 ElapsedTime
;* ret : DieFlag
;* kill: assume all

CheckTimeout	PROC	FAR

		test	GlobalTimeout,1
		jz	SkipTimeout

		cli
		mov	ax,WORD PTR ElapsedTime
		mov	dx,WORD PTR ElapsedTime+2
		sti

		cmp	dx,WORD PTR TimeLimit+2
		jb	SkipTimeout
		ja	@F
		cmp	ax,WORD PTR TimeLimit
		jb	SkipTimeout

@@:		mov	DieFlag,SYS_ERR_TIMEOUT

SkipTimeout:	ret

CheckTimeout	ENDP

CODE		ENDS

;============================================================================

		END

