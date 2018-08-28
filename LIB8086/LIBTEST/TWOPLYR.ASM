;****************************************************************************
;*
;* TWOPLYR.ASM - KJB - 12.08.1988
;*
;* TWO PLAYER MODE - DATA STRUCTURE
;* ================================
;* 
;* Control Data
;* ============
;* 
;* BYTE        0: control byte:- 
;* 		     bit 0 = missile launched
;* 	   	     bit 1 = chaff released
;* 		     bit 2 = flares released
;* 		     bit 3 = one of my bullets hit you
;* 		     bit 4 = ESCAPE key pressed
;* 		     bit 5 = HOLD key pressed
;* 		     bit 6 = RELEASE key pressed
;* 		     bit 7 = 0 (MUST be 0 for byte to be +ve)
;* 
;* BYTE        1: control byte:-
;*                   bit 0 = radar on
;* 	   	     bit 1 = I am dead
;* 		     bit 2 = I have ejected
;* 		     bit 3 = I have no weapons
;* 		     bit 4 = I have landed / not taken off
;* 		     bit 5 = You are dead according to me
;* 		     bit 6 = It's nite time
;* 		     bit 7 = Missile locked
;* 
;* Aircraft Data
;* =============
;* 
;* BYTES  2,  3: objtype
;* BYTES  4,  5: xft
;* BYTES  6,  7: yft
;* BYTES  8,  9: zft
;* BYTES 10, 11: heading
;* BYTES 12, 13: pitch
;* BYTES 14, 15: roll
;* BYTES 16, 17: xsec / ysec
;* 
;* Missile Data (only sent if control byte bit 0 is set)
;* ============ 
;* 
;* BYTES 18, 19: objtype
;* BYTES 20, 21: xft
;* BYTES 22, 23: yft
;* BYTES 24, 25: zft
;* BYTES 26, 27: heading
;* BYTES 28, 29: pitch
;* BYTES 30, 31: roll
;* BYTES 32, 33: xsec / ysec
;* BYTES 34, 35: xvel
;* BYTES 36, 37: yvel
;* BYTES 38, 39: zvel
;* BYTES 40, 41: speed
;* 
;* Checksum Data
;* =============
;* 
;* BYTE 18 / 42: checksum previous bytes
;* 
;* ===============================
;* TOTAL WITHOUT MISSILE: 19 BYTES
;* TOTAL WITH MISSILE   : 43 BYTES
;* ===============================
;* 
;****************************************************************************

;* public symbols
		
		public	SelectRunway	;NEAR
		public	ChangeCommsMes	;NEAR

		public	InitFP2Comms 	;FAR
		public	StopFP2Comms	;FAR
		public	FP2StartSync	;FAR
		public	FP2LoopSync	;FAR
		public	SendFP2Data	;FAR
		public	ReadFP2Data	;FAR
		public	SelectRunwayFar	;FAR
		public	InitTwoPlayer	;FAR
		public	IntelMessage	;FAR
		public	TestForEnd	;FAR
		public	StaleMate	;FAR
		public	LandingPractice	;FAR
		public	ChuckAndJrGoFishing 
		
		public	CommsDevice	;WORD
		public	BaudRate	;WORD
		public	Kills		;WORD
		public	Losses		;WORD
		public	MissilesFired	;WORD
		public	TwoPlayerKills	;WORD
		public	EndCntr		;WORD

		public	Player		;BYTE
		public	HoldCode	;BYTE
		public	EscCode		;BYTE
		public	MyCtrlCode	;BYTE
		public	MyCtrlCode2	;BYTE
		public	HisCtrlCode	;BYTE
		public	HisCtrlCode2	;BYTE
		public	Intelfg		;BYTE
		public	KillMes		;BYTE
		public	DrawMes		;BYTE
		public	MyHoldMes	;BYTE
		public	BulletCntr	;BYTE
		public	HeatOfTheNite	;BYTE

		public	MaxBulletHits	;ABS
		public	Com1		;ABS
		public	Com2		;ABS
		public	Baud1200	;ABS
		public	Baud2400	;ABS
		public	Baud4800	;ABS
		public	Baud9600	;ABS
		public	MissileMask	;ABS
		public	ChaffMask	;ABS
		public	FlareMask	;ABS
		public	CannonMask	;ABS
		public	EscMask		;ABS
		public	HoldMask	;ABS
		public	ReleaseMask	;ABS
		public  RadarMask	;ABS
		public	DeadMask	;ABS
		public  EjectMask	;ABS
		public	WeaponsMask	;ABS
		public	LandMask	;ABS
		public 	YouDeadMask	;ABS
		public	NiteMask	;ABS
		public	LockMask	;ABS

;* external references

		extrn	xons2:near	;print comms panel message
		extrn	randomb:near	;al = random number
		extrn	topolarb:near	
		extrn	condegb:near
		extrn	decim:near
		extrn	mksoundb:near
		extrn	Damage:near
		extrn	EGAInit:near
		extrn	CopyEGAScreen:near
		extrn	SetCol:near

		extrn	SoundFlags:word	;/SOUND/
		extrn	Clock:word
		extrn	MesPtr:word
		extrn	xft:word
		extrn	yft:word
		extrn	zft:word
		extrn	hdg:word
		extrn	pitch:word
		extrn	roll:word
		extrn	obj2:word
		extrn	fired:word
		extrn	mobjblock:word
		extrn	airbptr:word
		extrn	your:word
		extrn	hfine:word
		extrn	vtas:word
		extrn	cbase:word
		extrn	ctop:word
		extrn	fuelwt:word
		extrn	pitch:word
		extrn	roll:word
		extrn	pfine:word
		extrn	rfine:word
		extrn	weight:word
		extrn	rpm:word		
		extrn	lgfg:word
		extrn	mobjblock:word
		extrn	xvel:word
		extrn	yvel:word
		extrn	zvel:word
		extrn	Tick:word
		extrn	sound5:word
		extrn	vkts:word
		extrn	gforce:word
		extrn	cpylon:word
		extrn	gmax:word
		extrn	secptr:word
		extrn	rwyctrl:word
		extrn	tinfo:word
		extrn	hdgrat:word
		extrn	arrate:word
		extrn	armax:word
		extrn	xbul:word
		extrn	ybul:word
		extrn	eleposn:word
		extrn	ailposn:word
		extrn	tick:word
		extrn	accel:word
		extrn	thrust:word
		extrn	drag:word
		extrn	rpm:word
		extrn	vkts:word
		extrn	vias:word
		extrn	sinp:word
		extrn	sinr:word
		extrn	cosp:word
		extrn	cosr:word
		extrn	xwinds:word
		extrn	SegPtr:word

		extrn	wxsec:byte
		extrn	wysec:byte
		extrn	tacmode:byte
		extrn	channel:byte
		extrn	afnum:byte			
		extrn	tbuff:byte
		extrn	rhrate:byte
		extrn	rhmax:byte
		extrn	rprate:byte
		extrn	rpmax:byte
		extrn	rrrate:byte
		extrn	rrmax:byte
		extrn	errate:byte
		extrn	ermax:byte
		extrn	ehrate:byte
		extrn	ehmax:byte
		extrn	eprate:byte
		extrn	epmax:byte
		extrn	ahrate:byte
		extrn	ahmax:byte
		extrn	airbrake:byte
		extrn	wheelbrake:byte
		extrn	fireflg:byte
		extrn	Key:byte
		extrn	Commes0:byte
		extrn	diefg:byte
		extrn	secdata:byte
		extrn	xsec:byte
		extrn	ysec:byte
		extrn	inair:byte
		extrn	diefg:byte
		extrn	moronfg:byte
		extrn	engfail:byte
		extrn	reheat:byte
		extrn	throt:byte		
		extrn	pylon:byte
		extrn	pylonfail:byte
		extrn	nos3:byte
		extrn	nos2:byte
		extrn	nos1:byte
		extrn	digit:byte
		extrn	MaxMissiles:byte
		extrn	ejected:byte
		extrn	status:byte
		extrn	undercarrage:byte
		extrn	warmode:byte
		extrn	screen1:byte
		extrn	screen2:byte
		extrn	screen3:byte
		extrn	chaf:byte
		extrn	flares:byte
		extrn	hudfg:byte
		extrn	pflag:byte
		extrn	jetflag:byte
		extrn	lantstat:byte
		extrn	MissileCntr:byte
		extrn	rwyinfo:byte
		extrn	RadMode:byte
		extrn	bultable:byte
		extrn	fcount:byte
		extrn	fbuff:byte
		extrn	nitetime:byte

		extrn	MaxBullets:ABS
	      
;----------------------------------------------------------------------------

data	segment para public 'data'
	assume ds:data

;* set these vars from 'comms selection' page

CommsDevice	dw	Com2		;3 = com1:, 2 = com2:
BaudRate	dw	Baud9600	
Player		db	0,0		;0 = blue, 1 = red

;* UART register LS addresses (CommsDevice forms MS address)

TxHold		equ	0f8h		;tx holding reg
RxData		equ	0f8h		;rx data reg
LSBaud		equ	0f8h		;Baud-rate divisor LSB
MSBaud		equ	0f9h		;Baud-rate divisor MSB
IntrEnable	equ	0f9h		;interrupt enable reg
IntrIdent	equ	0fah		;interrupt identification reg
LineCtrl	equ	0fbh		;line-control reg
ModemCtrl	equ	0fch		;modem-control reg
LineStat	equ	0fdh		;line-status reg
ModemStat	equ	0feh		;modem-status reg

;* interrupt vector table locations

Com1Vector	equ	4*12		;com1: interrupt
Com2Vector	equ	4*11		;com2: interrupt

;* comms device reg ms addresses

Com1		equ	3
Com2		equ	2

;* keyboard equates

ESC		equ	1
CTRL		equ	29
P		equ	25

;* CtrlCode equates

MissileMask	equ	00000001b
ChaffMask	equ	00000010b
FlareMask	equ	00000100b
CannonMask	equ	00001000b
EscMask		equ	00010000b
HoldMask	equ	00100000b
ReleaseMask	equ	01000000b

RadarMask	equ	00000001b
DeadMask	equ	00000010b
EjectMask	equ	00000100b
WeaponsMask	equ	00001000b
LandMask	equ	00010000b
YouDeadMask	equ	00100000b
NiteMask	equ	01000000b
LockMask	equ	10000000b

TxQHead		db	255 dup(0)	;transmit queue
TxQTail		db	0
TxQWtPtr	dw	offset TxQHead	;tx queue write pointer
TxQRdPtr	dw	offset TxQHead	;tx queue read pointer

RxQHead		db	255 dup(0)	;receive queue
RxQTail		db	0
RxQWtPtr	dw	offset RxQHead	;rx queue write pointer
RxQRdPtr	dw	offset RxQHead	;rx queue read pointer

;* comms error flags
;*
;*    b15: tx queue overflow
;*    b14: rx queue overflow
;*    b13: checksum error
;*    b12: sync timeout
;*    b11: data timeout
;*    b10: no cable
;*    b9 : 0
;*    b8 : 0
;*    b7 : 0
;*    b6 : 0
;*    b5 : 0
;*    b4 : break detect
;*    b3 : framing error
;*    b2 : parity error
;*    b1 : overrun error
;*    b0 : 0
 
CommsError	dw	0		;error flags

;* Set up conditions - refer to 8088 Assembler Langauge Programming by
;*                     Willen and Krantz for serial comms register data
;*
;* Default conditions:- 9600 Baud
;*                      8 data bits
;*                      1 stop bit
;*                      no parity

SetUpCond	db	00ch		;Baud-rate divisor LSB
		db	000h		;Baud-rate divisor MSB
		db	00000011b	;line-control reg
		db	00001011b	;modem-control reg
		db	00000111b	;interrupt-enable reg

		even

Baud50		equ	0
Baud300		equ	1
Baud600		equ	2
Baud1200	equ	3
Baud2400	equ	4
Baud4800	equ	5
Baud9600	equ	6
Baud19200	equ	7

BaudList	dw	00900h		;50
		dw	00180h		;300
		dw	000c0h		;600
		dw	00060h		;1200
		dw	00030h		;2400
		dw	00018h		;4800
		dw	0000ch		;9600
		dw	00006h		;19200

SyncChar	db	0,0
CheckSum    	db	0,0
TimeUp		dw	0,0
MyCtrlCode	db	0
MyCtrlCode2	db	0
HisCtrlCode	db	0
HisCtrlCode2	db	0
HoldCode	db	0,0		;b7 = hold just pressed
					;b1 = he pressed hold
					;b0 = I pressed hold
EscCode		db	0,0

;* FP2 I/O buffers

MaxRecSize 	equ	43
MinRecSize	equ	19

TxBuf		db	MaxRecSize dup(0)

RxBuf		db	MaxRecSize dup(0)

RxBufEnd	dw	0

NBytes		dw	0	

;* comms panel messages

WaitMes		db	'OPPONENT[NOT[READY'
ErrorMes	db	'SERIAL[COMMS[ERROR'
QuitMes		db	'QUIT[GLADIATOR[^^^'
MyHoldMes	db	'PAUSED[',12,'[P[TO[CONT'
HisHoldMes	db	'[OPPONENT[PAUSED^['
IntelMes1	db	'[[ENEMY[LOCATED^[['
IntelMes2	db	'RNG[',0,0,0,'ML[[BRG[',0,0,0
KillMes		db	'[[KILL[CONFIRMED[['
DrawMes		db      '[[[[STALEMATE^[[[['
ScoreMes	db	'KILLS',11,0,0,'[LOSSES',11,0,0

		even

SwapTable	db	0,1,2,4,3,5 	;used to swap 3 <-> 4

;* runway data: xft, yft, hfine

RunEndData	dw	    2,  2000, 256*32 	;runway a north end
		dw	-2000,  1000, 128*32	;runway b west end
		dw	-1414,  1414, 192*32	;runway c north end
		dw	    2, -2000, 0*32	;runway a south end
		dw       2000,  1000, 384*32	;runway b east end
		dw	 1414, -1414, 448*32	;runway c south end

;* pylon loading data

MyPylonData	db	2,2,1,1,1,1,1,1,0	;type: 1 = sidewndr,2 = amraam
		db	1,1,2,2,2,2,2,2,0	;number on pylon

Intelfg		db	0,0			;0 = intelligence msg diabled
						;1 = calc range / bearing
						;2 = just display message
IMClk		dw	0			;intel message clock

Kills		dw	0
Losses		dw	0
MissilesFired	dw	0
TwoPlayerKills	dw	0
	
EndFlashTmr	dw	0
OldMesPntr	dw	0

EndCntr		dw	0		;no comms when <> 0

MaxBulletHits	equ	5		;number of bullet hits before you die

BulletCntr	db	0,0		;number of my bullets hit opponent

OldType		dw	0

;* landing practice sector offset table - xsec offset, ysec offset

secoffset	db	 0, -3		;heading north
		db	-3,  0		;heading east
		db	 0,  3		;heading south
		db	 3,  0		;heading west

HeatOfTheNite	db	0,0

;* data for USA QuickStart

;* data depends on F-16 heading (N, S, E, W) ...
;*
;*    		db	xsec offset, ysec offset	;F-16
;*		db	xsec offset, ysec offset	;MIG-27
;*		db	xsec offset, ysec offset	;MIG-29
;*		db	xsec offset, ysec offset	;MIG-31
;*		dw	hfine				;F-16
;*		dw	hdg				;MIG-27
;*		dw	hdg				;MIG-29
;*		dw	hdg				;MIG-31

QuickData	db	 0, -5   	;North
		db	 0, -1	
		db      -3,  0
		db	 2,  2
		dw	0*32	
		dw	256	
		dw	128
		dw	320

		db	-5,  0	   	;East
		db	-1,  0	
		db       0,  3
		db	 2, -2
		dw	128*32	
		dw	384	
		dw	256
		dw	448

		db	 0,  5	   	;South
		db	 0,  1	
		db       3,  0
		db	-2, -2
		dw	256*32	
		dw	0	
		dw	384
		dw	64

		db	 5,  0	   	;West
		db	 1,  0	
		db       0, -3
		db	-2,  2
		dw	384*32	
		dw	128	
		dw	0
		dw	192

data		ends

;----------------------------------------------------------------------------

codeb	segment byte public 'code'
	assume cs:codeb

;============================================================================

;* InitFP2Comms - far routine for FP2 comms initialize

;* pass: CommsDevice
;*       BaudRate
;* ret : nothing
;* kill: ax, bx, dx, si, di, flags

InitFP2Comms:	mov	ax,BaudRate
		call	SetBaudRate
		call	InitComms
		retf

;============================================================================

;* StopFP2Comms - far routine for FP2 comms deactivate

;* pass: CommsDevice
;* ret : nothing
;* kill: al, dx, flags

StopFP2Comms:	call	StopComms
		retf

;============================================================================

;* FP2StartSync - initial sync up routine

;* pass: nothing
;* ret : nothing
;* kill: assume all

FP2StartSync:	mov	ax,offset Commes0 
		call	ChangeCommsMes

		mov	al,-2		;sync char
		mov	cx,25 
		call	WaitForSync
		jnc	FP2SyncOK

		mov	al,EscCode
		test	al,al
		jnz	FP2SyncESC

		mov	ax,offset WaitMes
		call	ChangeCommsMes

		mov	al,-2		;sync char
		mov	cx,25
		call	WaitForSync
		jnc	FP2SyncOK

		mov	al,EscCode
		test	al,al
		jnz	FP2SyncESC

		jmp	FP2StartSync

FP2SyncESC:	mov	ax,offset QuitMes
		call	ChangeCommsMes
		jmp	FP2SyncExit

FP2SyncOK:	call	ClearError
		call	PrintScore
		mov	ax,offset ScoreMes
		call	ChangeCommsMes
		mov	cx,4*50
		call	SetClock
ScoreWait:	call	IsTimeUp
		jnc	ScoreWait				

FP2SyncExit:	retf

;============================================================================

;* FP2LoopSync - end of loop  sync up
;*
;* pass: nothing
;* ret : cf = 0 = sync OK
;*       cf = 1 = timeout
;* kill: assume all
;*
;* If EndCntr <> 0 then no comms.

FP2LoopSync:	mov	ax,EndCntr
		test	ax,ax
		jnz	FP2LoopExit
		mov	al,-3		;sync char
		mov	cx,2*50
		call	WaitForSync
		jnc	FP2LoopExit
		mov	ax,offset ErrorMes
		mov	MesPtr,ax
FP2LoopExit:	retf

;============================================================================

;* ChangeCommsMes - change comms panel message and down load screen

;* pass: ax -> message
;* ret : nothing
;* kill: assume all

;* EGA MOD - KJB - 17.02.1989

ChangeCommsMes:	push	ds
		push	es

		mov	MesPtr,ax

		mov	ax,SegPtr
		mov	es,ax

		call	EGAInit

		mov	dx,003c4h	;EGA Sequencer
		mov	al,2		;select map mask reg
		out	dx,al
		inc	dx
		mov	al,1111b	;write to all four planes at once
		out	dx,al

		mov 	al,1
		mov 	dx,03ceh
		out 	dx,al
		inc	dx
		mov	al,1111b
		out	dx,al

		mov	ah,1010b
		call	SetCol

		call	xons2

;* copy dummy screen to displayed screen

		call	EGAInit

		mov	ax,SegPtr
		mov	ds,ax	  
		xor	ax,00200h
		mov	es,ax

		call	CopyEGAScreen

		pop	es
		pop	ds
		ret

;============================================================================

;* SendFP2Data - send FP2 data packet

;* pass: no regs
;* ret : nothing
;* kill: assume all
;*
;* If EndCntr <> 0 then no comms.

SendFP2Data:	mov	ax,EndCntr
		test	ax,ax
		jz	SendOK
		jmp	SendReturn

;* test for ESCape

SendOK:		xor	ah,ah
		mov	al,EscCode
		test	al,al
		jz	NotEscape
		or	ah,EscMask
NotEscape:	

;* test for PAUSE

		mov	al,Key[P]
		test	al,al		;pause / continue key?
		jz	NotPause
		mov	Key[P],0
		mov	al,HoldCode
		test	al,al		;is it pause or continue?
		mov	al,HoldMask	;assume hold
		jz	GotMask
		mov	al,ReleaseMask
GotMask:	or	ah,al
NotPause:  

;* test for chaff / flares
	
		mov	al,byte ptr your+44
		and	al,110b		;chaff / flares released
		or	ah,al

;* test for bullets hit opponent

		mov	al,byte ptr obj2+46
		cmp	al,BulletCntr
		je	NoBulletsHit
		mov	BulletCntr,al
		or	ah,CannonMask
NoBulletsHit:

		mov	MyCtrlCode,ah
 
		xor	ah,ah	   	;check to see if I have died
		mov	al,diefg	;collision / hypoxia or something
		test	al,al
		jz	Alive
		or	ah,DeadMask
		cmp	al,23		;collided with enemy?
		jne	Alive	
		or	ah,YouDeadMask
Alive:		
		mov	bx,obj2
		mov	OldType,bx
		cmp	bx,14		;have I killed him?
		jne	NoDice
		or	ah,YouDeadMask
NoDice:	
		mov	al,ejected	;have I ejected?
		test	al,al
		jz	OnBoard
		or	ah,EjectMask
OnBoard:

;* test if I have any weapons - only check necsessary nosX[Y] values

		xor	al,al	
		or	al,nos3[0]	;test bullets (500 max)
		or	al,nos2[0]
		or	al,nos1[0]
		or	al,nos2[1]	;test sidewinders (12 max)
		or	al,nos1[1]
		or	al,nos1[2]	;test aamrams (2 max)
		jnz	GotWeapons
		or	ah,WeaponsMask
GotWeapons:

;* am I stationry (ie. plane has not taken off or landed)

		mov	bx,zft
		or	bx,vkts
		jnz	IsMoving
		or	ah,LandMask
IsMoving:
		mov	al,byte ptr your+44
		and	al,001b		;radar on
		or	ah,al

;* is it day or nite?

		mov	al,nitetime	;0 = day, 1 = nite
		test	al,al
		jz	DayTime
		or	ah,NiteMask
DayTime:
		
		mov	MyCtrlCode2,ah

;* plane data

		mov	NBytes,MinRecSize

		mov	di,offset TxBuf+2

		mov	ax,your		;object type 
		stosw
		mov	ax,xft
		stosw
		mov	ax,yft
		stosw
		mov	ax,zft
		stosw
		mov	ax,hdg
		stosw
		mov	ax,pitch
		stosw
		mov	ax,roll
		stosw
		mov	ax,word ptr xsec;packed xsec / ysec
		stosw

;* missile data (if any)

		mov	si,fired
		test	si,si		;missile fired this frame?
		jz	NoMissile
		or	MyCtrlCode,MissileMask
		mov	NBytes,MaxRecSize
	  	mov	cx,12
		rep	movsw

;* was missile locked on?

		mov	ax,[si+2]
		cmp	ax,0ffffh
		je	NoMissile
		or	MyCtrlCode2,LockMask
NoMissile:

;* control code

		mov	si,offset TxBuf

		mov	al,MyCtrlCode
		mov	[si+0],al
		mov	al,MyCtrlCode2
		mov	[si+1],al

		mov	ah,0   		;generate checksum
		mov	cx,NBytes
		dec	cx
GenCheckSum:	lodsb
		add	ah,al
		loop	GenCheckSum
		mov	[si],ah		

		mov	cx,NBytes
		mov	si,offset TxBuf
		call	SendMessage
SendReturn:	retf

;============================================================================

;* InitComms - initialize serial comms port
;*
;* pass: CommsDevice
;* ret : nothing
;* kill: ax, dx, si, di, flags

InitComms:	cli  			;disable intr's - a really good idea!

;* disable UART intr's then set intr vector address

		mov	dh,byte ptr CommsDevice
		mov	dl,IntrEnable
		mov	al,0
		out	dx,al

		push	es
		mov	ax,0
		mov	es,ax
		mov	di,Com1Vector	;assume com1:
		cmp	dh,Com1		;is it com1:?
		je	GotCommsVctr	;yes ->
		mov	di,Com2Vector
GotCommsVctr:	mov	ax,offset CommsIntr
		stosw
		mov	ax,cs
		stosw
		pop	es

;* set up UART wrt SetUpCond data

		mov	si,offset SetUpCond

;* enable access to Baud-rate divisor reg's

		mov	dl,LineCtrl
		mov	al,10000000b
		out	dx,al

;* set Baud-rate divisor reg's

		mov	dl,LSBaud
		mov	al,[si+0]    	;Baud-rate LSB data
		out	dx,al
		mov	dl,MSBaud
		mov	al,[si+1]	;Baud-rate MSB data
		out	dx,al

;* set line-control reg

		mov	dl,LineCtrl
		mov	al,[si+2]	;line-control data
		out	dx,al

;* set modem-control reg

		mov	dl,ModemCtrl
		mov	al,[si+3]      	;modem-control data
		out	dx,al

;* set interrupt-enable reg

		mov	dl,IntrEnable
		mov	al,[si+4]	;interrupt-enable data
		out	dx,al

		sti

;* any 'left over' pending intr's will occur NOW, so reset queues afterwards

		call	ClearTxQueue
		call	ClearRxQueue
		call	ClearError

		ret	

;============================================================================

;* StopComms - disable comms interrupts
;*
;* pass: CommsDevice
;* ret : nothing
;* kill: al, dx, flags

;* disable all UARTS intr's

StopComms:	mov	dh,byte ptr CommsDevice
		mov	dl,IntrEnable
		mov	al,0
		out	dx,al
		ret

;============================================================================

;* CommsIntr - serial comms interrupt handler
;*
;* Note: This routine only caters for error condition interrupt, received
;*       data is ready interrupt and transmitter ready interrupt. The modem
;*       status changed interrupt should not be enabled.

CommsIntr:	push	ax
		push	dx
		push	si
		push	ds

		mov	ax,data
		mov	ds,ax

		mov	dh,byte ptr CommsDevice

;* identify the cause of the interrupt

		mov	dl,IntrIdent
		in	al,dx
Again:		and	al,0110b     	;mask out unwanted bits
		cmp	al,0110b	;error condition interrupt?
		je	ErrorIntr	;yes ->
		cmp	al,0100b	;received data ready interrupt?
		je	RxIntr		;yes ->
       
;* transmitter ready interrupt
		
TxIntr:		mov	si,TxQRdPtr
		cmp	si,TxQWtPtr	;is queue empty?
		je	IntrPending	;yes ->
		mov	al,[si]	
		mov	dl,TxHold
		out	dx,al
		inc	si
		cmp	si,offset TxQTail
		jbe	NoTxWrap
		mov	si,offset TxQHead
NoTxWrap:	mov	TxQRdPtr,si
		jmp	short IntrPending

;* received data ready interrupt

RxIntr:		mov	dl,RxData
		in	al,dx
		mov	si,RxQWtPtr
		mov	[si],al
		inc	si
		cmp	si,offset RxQTail
		jbe	NoRxWrap
		mov	si,offset RxQHead
NoRxWrap:	mov	RxQWtPtr,si
		cmp	si,RxQRdPtr    	;queue full?
		jne	IntrPending	;no ->
		or	CommsError,04000h
		jmp	short IntrPending

;* error condition interrupt

ErrorIntr:	mov	dl,LineStat
		in	al,dx
		and	al,01eh		;clear unwanted bits
		mov	byte ptr CommsError,al		

;* test to see if any interrupts are pending

IntrPending: 	mov	dl,IntrIdent
	     	in	al,dx
	     	test	al,0001b
	     	jz	Again		;intr pending ->

;* inform the interrupt controller that the interrupt has been serviced.

		mov 	al,020h
		out	020h,al

		pop	ds
		pop	si
		pop	dx
		pop	ax
		iret

;============================================================================

;* SendChar - send character
;*
;* pass: al = character
;* ret : TxQWtPtr may be modified if char is put in transmit queue
;*       CommsError may be modified if transmit queue becomes full
;* kill: ax, dx, si, flags

SendChar:	cli			;disable intr's - important
		mov	ah,al

;* if the transmit queue is empty and the transmit holding reg is empty then
;* send the char immediately else put the char in the transmit queue

		mov	si,TxQWtPtr
		cmp	si,TxQRdPtr   	;is tx queue empty?
		jne	AddToQueue	;no ->
		mov	dh,byte ptr CommsDevice
		mov	dl,LineStat
		in	al,dx
		test	al,00100000b	;is tx hold reg empty?
		jz	AddToQueue	;no ->

;* transmit character

		mov	dl,TxHold
		mov	al,ah
		out	dx,al
		jmp	short CharSent

;* put char in transmit queue

AddToQueue:	mov	[si],ah
		inc	si

;* check for and handle queue wrap around

		cmp	si,offset TxQTail
		jbe	NoWtWrap
		mov	si,offset TxQHead

NoWtWrap:	mov	TxQWtPtr,si

;* check for buffer full

		cmp	si,TxQRdPtr
		jne	CharSent
		or	CommsError,08000h
		
CharSent:	sti
		ret

;============================================================================

;* ClearTxQueue - reset transmit queue pointers
;*
;* pass: nothing
;* ret : TxQWtPtr = TxQRdPtr = offset TxQHead
;* kill: nothing

ClearTxQueue:	pushf
		cli
		mov	TxQWtPtr,offset TxQHead
		mov	TxQRdPtr,offset TxQHead
		popf
		ret

;============================================================================

;* ClearRxQueue - reset receive queue pointers
;*
;* pass: nothing
;* ret : RxQWtPtr = RxQRdPtr = offset RxQHead
;* kill: nothing

ClearRxQueue:	pushf
		cli
		mov	RxQWtPtr,offset RxQHead
		mov	RxQRdPtr,offset RxQHead
		popf
		ret

;============================================================================

;* ClearError - clear error flags
;*
;* pass: nothing
;* ret : CommsError = 0
;* kill: nothing

ClearError:	pushf
		cli
		mov	CommsError,0
		popf
		ret

;============================================================================

;* SendMessage - send n characters
;*
;* pass: cx = n characters
;*       si -> data to be sent
;* ret : nothing
;* kill: ax, cx, dx, si, flags

SendMessage:	lodsb
		push	si
		call	SendChar
		pop	si
		loop	SendMessage
		ret

;============================================================================

;* ReadChar - read a character from the receive queue
;*
;* pass: nothing
;* ret : cf = 0: al = character
;*       cf = 1: al = 0 (receive queue empty)
;* kill: si, flags

ReadChar:	cli

;* test if receive queue is empty

		mov	si,RxQRdPtr
		cmp	si,RxQWtPtr
		je	NoData

;* read character from receive queue and update pointer

		mov	al,[si]
		inc	si
		cmp	si,offset RxQTail
		jbe	NoRdWrap
		mov	si,offset RxQHead
NoRdWrap:	mov	RxQRdPtr,si
		clc		   	;cf = 0
		jmp	short ReadCharOut

;* receive queue empty

NoData:		xor	al,al
		stc			;cf = 1
		
ReadCharOut:	sti
		ret		

;============================================================================ 

;* SetBaudRate - set Baud rate
;*
;* pass: ax = 0 = 50
;*            1 = 300
;*            2 = 600
;*            3 = 1200
;*            4 = 2400
;*            5 = 4800
;*            6 = 9600
;* ret : nothing
;* kill: ax, bx, flags

SetBaudRate:	shl	ax,1
		mov	bx,ax
		mov	ax,BaudList[bx]
		mov	word ptr SetUpCond,ax
		ret

;============================================================================

;* WaitForSync - wait for sync character
;*
;* pass: al = sync character
;* 	 cx = timeout limit (50 = 1 sec)
;* ret : cf = 0: sync received
;*       cf = 1: TIMEOUT / ESC key pressed
;* kill: ax, bx, cx, dx, si, flags

WaitForSync:	mov	SyncChar,al

		call	SetClock

;* BUG FIX - wait for TX queue to be empty before sending SYNC bytes

EmptyLoop:	call	IsTimeUp
		jc	SyncExit
		mov	ax,TxQWtPtr
		cmp	ax,TxQRdPtr
		jne	EmptyLoop

SyncLoop:	call	IsTimeUp
		jc	SyncExit    	;cf = 1 = TIMEOUT / ESC key

		mov	al,SyncChar
		call	SendChar
		call	ReadChar   
		jc	SyncLoop
		cmp	al,SyncChar
		jne	SyncLoop	;zf = 1 and cf = 0 = sync received

SyncExit:	pushf
		jnc	NoSyncTimeout
		or	CommsError,01000h

;* send SYNC again in case other machine missed the SYNC

NoSyncTimeout:	mov	al,SyncChar
		call	SendChar

;* clear I/O queues - this is really required for slow BAUD rates as
;* too many characters in the transmit queue can cause SYNC timeouts

		call	ClearTxQueue
		call	ClearRxQueue

		popf
		ret

;============================================================================

;* ReadFP2Data - read FP2 data packet
;*
;* pass: cx = timeout limit (50 = 1 sec)
;* ret : cf = 0: no timeout
;*       cf = 1: TIMEOUT
;*       zf = 0: check sum fail
;*       zf = 1: check sum ok
;* kill: ax, bx, cx, dx, si, flags
;*
;* If EndCntr <> 0 then no comms.

ReadFP2Data:	mov	ax,EndCntr
		test	ax,ax
		jz	ReadOK
       		xor	ax,ax		;zf = 1, cf = 0
		jmp	ReadReturn

ReadOK:		call	SetClock
		mov	CheckSum,0
		mov	di,offset RxBuf

;* wait for first +ve data byte (start of data packet)

WaitForPos:	call	IsTimeUp
		jc	ReadFP2Exit	;cf = 1 = TIMEOUT
		call	ReadChar
		jc	WaitForPos
		test	al,al
		js	WaitForPos

;* sort RxBufEnd w.r.t. missile data present 

		mov	bx,MinRecSize
		test	al,MissileMask
		jz	GotRecSize
		mov	bx,MaxRecSize
GotRecSize:	add	bx,di
		mov	RxBufEnd,bx
		jmp	IntoRecLoop 	;skip reading char

ReceiveLoop:	call	IsTimeUp
		jc	ReadFP2Exit	;cf = 1 = TIMEOUT
		call	ReadChar   
		jc	ReceiveLoop
IntoRecLoop:	stosb
		cmp	di,RxBufEnd
		je	ReadFP2Exit 	;cf = 0 = OK   
	   	add	CheckSum,al
		jmp	ReceiveLoop

ReadFP2Exit:	jnc	NoDataTimeout
		pushf
		or	CommsError,00800h
		popf
NoDataTimeout:	rcl	dx,1		;save carry

;* if RX data = TX data then data has looped back due to no cable connected

TestForCable:	mov	cx,MinRecSize
		mov	si,offset TxBuf	
		mov	di,offset RxBuf
		repe	cmpsb
		jnz	CableOK
		or	CommsError,00400h
		or	dx,1		;set carry

CableOK:	mov	bx,RxBufEnd
		mov	al,[bx-1]
		cmp	al,CheckSum	;set zf wrt chksum
		jz	NoChkSumError
		or	CommsError,02000h
NoChkSumError:	rcr	dx,1		;restore carry
	
;* sort valid data or report comms error

		pushf

		jc	BadData
		jnz	BadData

		jmp	GoodData

BadData:	jmp	DataInvalid

GoodData:	mov	si,offset RxBuf

		lodsb
		mov	HisCtrlCode,al
		lodsb
		mov	HisCtrlCode2,al
		
;* opposition plane data

		mov	cx,8
		mov	di,offset obj2
		rep	movsw

;* opposition missile data

		mov	al,HisCtrlCode
		test	al,MissileMask	;did he just fire a missile at me?
		jz	Phew		;no ->

;* find a space in the moving object list for his missile - the size of 
;* mobjblock is increased by one record so if a missile can be fired
;* there must be room for it on the list ...

exx		equ	48		;see FIRE.ASM

		mov	ax,0ffffh
		mov	di,offset mobjblock
SearchLoop:	cmp	[di],ax
		je	Found
		add	di,exx
Calc:		cmp	di,offset mobjblock+exx*12
		jb	SearchLoop

		jmp	Phew		;should never happen

Found:		cmp	di,airbptr
		jb	ListOK
		mov	ax,di
		add	ax,exx
		mov	airbptr,ax

ListOK:		mov	cx,12
		rep	movsw

		mov	dx,offset your	;assume missile locked
		mov	al,HisCtrlCode2
		test	al,LockMask	;was missile locked?
		jnz	MissileLocked
		mov	dx,0ffffh	;no lock
MissileLocked:

		mov	ax,Clock	;lifetime clock
		stosw
		mov	ax,dx		;lock
		stosw
		xor	ax,ax		;reset chaff / flare affect cntr
		stosw
		mov	ax,1		;mark missile as enemy
		stosw

Phew: 

;* sort out radar on / chaff released / flares released

		mov	al,HisCtrlCode
		and	al,110b
		mov	ah,al
		mov	al,HisCtrlCode2
		and	al,001b
		or	al,ah
		mov	byte ptr obj2+44,al		

;* sort out hit by opponents bullets

		mov	al,HisCtrlCode
		test	al,CannonMask
		jz	Phew2
		mov	al,byte ptr your+46
		inc	al
		mov	byte ptr your+46,al
		cmp	al,MaxBulletHits
		jb	CauseDamage
		mov	diefg,12
CauseDamage:	call	Damage

Phew2:

;* does he think that I am dead?

		mov	al,HisCtrlCode2
		test	al,YouDeadMask
		jz	Phew3
		mov	diefg,23
		or	MyCtrlCode2,DeadMask
Phew3:

;* did I tell him that he was dead?

		mov	al,MyCtrlCode2
		test	al,YouDeadMask
		jz	Pity
		or	HisCtrlCode2,DeadMask
		mov	ax,OldType	;turn back into explosion (if he was one)
		mov	obj2,ax
Pity:

;* what time of day is it?

		mov	nitetime,0	;assume day
		mov	al,MyCtrlCode2
		or	al,HisCtrlCode2
		test	al,NiteMask
		jz	GoodDayOldChap
		mov	nitetime,1
GoodDayOldChap:

;* if comms message is 'serial comms error' then clear it

		mov	ax,offset ErrorMes
		cmp	ax,MesPtr
		jne	NoClearMsg
		mov	ax,offset Commes0
		mov	MesPtr,ax
NoClearMsg:

;* sort out pause / continue

		mov	al,HoldCode
		test	al,al		;is game held?
		jz	TestForHold	;no ->
		mov	al,HisCtrlCode
		test	al,ReleaseMask	;did he press release?
		jz	TryMyRelease	;no ->
		mov	al,HoldCode
		test	al,2		;can he release?
		jz	TryMyRelease	;no ->
		mov	HoldCode,0
		mov	ax,offset commes0
		mov	MesPtr,ax
		jmp	PauseEnd
TryMyRelease:	mov	al,MyCtrlCode
		test	al,ReleaseMask	;did I press release?
		jz	PauseEnd	;no ->
		mov	al,HoldCode
		test	al,1		;can I release?
		jz	PauseEnd	;no ->
		mov	HoldCode,0
		mov	ax,offset commes0
		mov	MesPtr,ax
		jmp	PauseEnd

TestForHold:	mov	al,HisCtrlCode
		test	al,HoldMask
		jz	TryMyHold
		or	HoldCode,10000010b
		mov	ax,offset HisHoldMes
		mov	MesPtr,ax
TryMyHold:	mov	al,MyCtrlCode
		test	al,HoldMask
		jz	PauseEnd
		or	HoldCode,10000001b
		mov	ax,offset MyHoldMes
		mov	MesPtr,ax
PauseEnd:
		jmp	ReadFP2Out

DataInvalid:	mov	ax,Offset ErrorMes
		mov	MesPtr,ax

		xor	al,al
		mov	HisCtrlCode,al
		mov	HisCtrlCode2,al
	
;* do any other vars need to be reset if data is invalid?

ReadFP2Out:	popf
ReadReturn:	retf

;============================================================================

;* SetClock - set timeout clock
;*
;* pass: cx     = timeout period (50 = 1 sec)
;*       Clock  = current time
;* ret : TImeUp = timeout time
;* kill: ax, dx, flags

SetClock:	mov	ax,Clock
		mov	dx,Clock+2
		add	ax,cx
		adc	dx,0
		mov	TimeUp,ax
		mov	TimeUp+2,dx
		ret
	       
;============================================================================

;* IsTimeUp - is timeout period up yet?
;*
;* pass: Clock, TimeUp
;* ret : cf = 0 = no timeout
;*       cf = 1 = timeout
;*       EscCode = 1 if CTRL-ESC pressed
;* kill: ax, dx, cx, dx, flags

IsTimeUp:     	mov	al,Key[ESC]
		and	al,Key[CTRL]
		or	EscCode,al

		mov	ax,Clock
		mov	dx,Clock+2
		mov	bx,TimeUp
		mov	cx,TimeUp+2
		sub	bx,ax
		sbb	cx,dx
IsTimeExit:	ret	     

;============================================================================

;* SelectRunway - select airfield and runway
;*
;* pass: xsec
;*       ysec
;*       LS rwyctrl = control byte
;*       MS rwyctrl = hanger
;*
;* control byte: bit 0 = 0 = fixed airfield (xsec, ysec are valid)
;*		 bit 0 = 1 = select random airfield
;*
;*               bit 1 = 0 = start from hanger
;*               bit 1 = 1 = start on runway
;*
;*               bit 2 = 0 = fixed hanger (MS rwyctrl is valid)
;*               bit 2 = 1 = random hanger
;*
;* ret : di -> rwyinfo record for airfield
;* kill: assume all
;*
;* rwyinfo: records 0 - 7  = allied airfields
;*                  8 - 15 = enemy airfields
;*          16 bytes / record

SelectRunway:	mov	al,byte ptr rwyctrl
		test	al,001b
		jnz	RandomAirfield

;* fixed airfield - secdata ptr = secptr( 2 * (ysec * 64 + xsec) )

		mov	bh,ysec
		xor	bl,bl
		shr	bx,1
		shr	bx,1		;ysec * 64
		or 	bl,xsec		;(ysec * 64 + xsec)
		shl	bx,1		;2 * (ysec * 64 + xsec)
		mov	si,secptr[bx]	;secdata ptr

		mov	al,[si+2]	;runway number
		xor	ah,ah
		shl	ax,1
		shl	ax,1
		shl	ax,1
		shl	ax,1 		;*16
		mov	di,offset rwyinfo
		add	di,ax
		jmp	FoundAirfield

;* random airfield

RandomAirfield:	mov	di,offset rwyinfo
		mov	al,Player
		test	al,al
		jz	PlayerAllied
		add	di,8*16
PlayerAllied:	call	randomb
		and	ax,7
		mov	afnum,al	;store airfield number for demo
		shl	ax,1
		shl	ax,1
		shl	ax,1
		shl	ax,1		;*16
		add	di,ax
		mov	al,[di+0]
		test	al,al
		jz	RandomAirfield

		mov	al,[di+4]
		mov	xsec,al
		mov	wxsec[0],al
		mov	al,[di+5]
		mov	ysec,al
		mov	wysec[0],al

		mov	bh,al
		xor	bl,bl
		shr	bx,1
		shr	bx,1		;ysec * 64
		or 	bl,xsec		;(ysec * 64 + xsec)
		shl	bx,1		;2 * (ysec * 64 + xsec)
		mov	si,secptr[bx]	;secdata ptr

FoundAirfield:

;* si -> secdata 
;* di -> rwyinfo

		mov	al,byte ptr rwyctrl
		test	al,010b
		jnz	RunwayStart

;* start in hanger

		test	al,100b
		jnz	RandomHanger

;* start in fixed hanger - MS rwyctrl indexes hanger object

       		mov	al,byte ptr rwyctrl+1
		xor	ah,ah
		mov	bx,ax
		shl	bx,1
		add	bx,ax		;*3
		add	bx,8
		jmp	FoundHanger

;* start in random hanger - select nth hanger in object list

RandomHanger:	call	randomb
		and	ax,7
		inc	ax
		mov	cx,ax		;look for nth hanger (1 -> 8)

		mov	al,[si+3]	;number of objects
		xor	ah,ah
		mov	dx,ax
		shl	dx,1
		add	dx,ax		;*3
		add	dx,8		;dx = end of obj list offset

		mov	bp,cx		;store original counter

		mov	bx,8-3
HangerLoop:	add	bx,3
		cmp	bx,dx		;wrap around?
		jne	IndexOK	  	;no ->
		cmp	cx,bp		;any hangers at all?
		je	RunwayStart	;no ->
		mov	bx,8
IndexOK:	mov	al,[si+bx]	;obj type
		cmp	al,2		;hanger?
		jne	HangerLoop
		loop	HangerLoop	;select nth hanger 

FoundHanger:	mov	ah,[si+bx+1]	;xposn
		xor	al,al
		shl	ax,1
		shl	ax,1
		sub	ax,8192
		mov	xft,ax

		mov	ah,[si+bx+2]	;yposn
		xor	al,al
		shl	ax,1
		shl	ax,1
		sub	ax,8192
		mov	yft,ax

		mov	ax,0		;assume heading north
		js	HeadingOK
		mov	ax,256*32	;heading south

HeadingOK:    	mov	hfine,ax
		jmp	RunwayEnd

;* start on random runway - select runway a, b or c - if they exist		 

RunwayStart:	mov	bx,offset SwapTable
		mov	cl,[si+1]	;bit 0 = runway a, 1 = b, 2 = c
FindRndRunway:	call	randomb
		and	al,3
		jz	FindRndRunway
		xlat			;convert 3 -> 4 giving al = 1, 2 or 4
		and	al,cl		;does rnd runway exist?
		jz	FindRndRunway	;no ->
		xlat			;convert 4 -> 3 giving al = 1, 2 or 3
		dec	al		;0, 1, 2
		xor	ah,ah
		mov	si,offset RunEndData
		shl	ax,1		;*2
		add	si,ax
		shl	ax,1		;*4
		add	si,ax		;*6 in total

		call	randomb
		test	al,1
		jz	NotOtherEnd
		add	si,18

NotOtherEnd:	lodsw
		mov	xft,ax
		lodsw	
		mov	yft,ax
		lodsw
		mov	hfine,ax
		
RunwayEnd:	ret

SelectRunwayFar:call	SelectRunway
		retf

;============================================================================

;* InitTwoPlayer - initialize vars for two player mode
;*
;* pass: no regs
;* ret : no regs
;* kill: assume all

InitTwoPlayer:	xor	ax,ax
		mov	tacmode,al
		mov	channel[0],al
		mov	channel[1],al
		mov	channel[2],al
		mov	xwinds,ax
		mov	tbuff,al
		mov	sinp,ax
		mov	sinr,ax
		mov	cosp,ax
		mov	cosr,ax
		mov	tick,4
		mov	vtas,ax
		mov	vkts,ax
		mov	rpm,ax
		mov	thrust,ax
		mov	drag,ax
		mov	drag+2,ax
		mov	accel,ax
		mov	eleposn,ax
		mov	ailposn,ax
		mov	hdgrat,ax
		mov	arrate,ax
		mov	armax,ax
		mov	rhrate,al
		mov	rhmax,al
		mov	rprate,al
		mov	rpmax,al
		mov	rrrate,al
		mov	rrmax,al
		mov	errate,al
		mov	ermax,al
		mov	ehrate,al
		mov	ehmax,al
		mov	eprate,al
		mov	epmax,al
		mov	ahrate,al
		mov	ahmax,al
		mov	inair,al
		mov	vtas,ax
		mov	diefg,al
		mov	moronfg,al
		mov	engfail,al
		mov	fireflg,al
		mov	reheat,al
		mov	cbase,30000
		mov	ctop,35000
		mov	zft,ax
		mov	pitch,ax
		mov	roll,ax
		mov	pfine,ax
		mov	rfine,ax
		mov	fuelwt,4000
		mov	weight,21086+4000 	;weight+fuelwt	
		mov	throt,al
		mov	rpm,ax
		mov	lgfg,ax
		mov	xvel,ax
		mov	yvel,ax
		mov	zvel,ax
		mov	gforce,32
		mov	gmax,32
		mov	your,ax
		mov	warmode,al
		mov	undercarrage,al	  
		mov	status,1
		mov	Intelfg,1	;calculate range / bearing
		mov	MaxMissiles,4
		mov	ejected,al
		mov	EndCntr,ax
	     	mov	EscCode,al
		mov	HoldCode,al
		mov	MyCtrlCode,al
		mov	MyCtrlCode2,al
		mov	HisCtrlCode,al
		mov	HisCtrlCode2,al
		mov	hudfg,al
		mov	pflag,al
		mov	jetflag,al
		mov	lantstat,1
		mov	MissileCntr,al
		mov	BulletCntr,al
		mov	tinfo,ax
		mov	tinfo+2,ax
		mov	tinfo+4,ax
		mov	tinfo+6,ax
   		mov	xbul,160
		mov	ybul,64

;* put MFD's in dogfight mode
	    
	       	mov 	RadMode,3	;asc mode
		mov 	screen1,2	;weapon
		mov 	screen2,4  	;air radar
		mov 	screen3,6	;dial
   
;* init weapons
;*
;*   2 AMRAAMs
;*  12 SIDEWINDERS
;* 500 BULLETS

		mov	si,offset MyPylonData
		mov	di,offset pylon
		mov	cx,9
		rep	movsw

		mov	di,offset nos3	;clear all other weapons
		xor	ax,ax
		mov	cx,18
		rep	stosw

		mov	nos3[0],5
		mov	nos2[0],0
		mov	nos1[0],0

		mov	nos3[1],0
		mov	nos2[1],1
		mov	nos1[1],2

		mov	nos3[2],0
		mov	nos2[2],0
		mov	nos1[2],2

		mov	di,offset pylonfail
		xor	al,al
		mov	cx,9
		rep	stosb		;clear weapons fail

		mov	cpylon,9

		mov	chaf+0,0	;chaf = 30 unpacked bcd
		mov	chaf+1,3
		mov	flares+0,0	;flares = 30 unpacked bcd
		mov	flares+1,3

;* init moving objects list

		mov ax,0ffffh	 
		mov cx,24*34
		mov di,offset mobjblock
		rep stosw
		
exx		equ 48			;see AIRVIS.ASM

		mov ax,offset mobjblock+4*exx
		mov airbptr,ax

		mov	byte ptr your+46,0
		mov	byte ptr obj2+46,0

		mov	obj2+22,0	;null plane control

		mov	obj2+6,0	;zft = 0

;* clear bullet list

		xor	al,al
		mov	cx,MaxBullets
		mov	si,offset bultable
bulclrloop:	mov	[si],al
		add	si,6
		loop	bulclrloop
		mov	fcount,al
		mov	fbuff,al

;* disable ils at all airfields

		xor	al,al
		mov	cx,16
   		mov	si,offset rwyinfo+6
ClearILSLoop:	mov	[si],al
		add	si,16
		loop	ClearILSLoop		

;* sort out time of day

		mov	al,HeatOfTheNite
		test	al,al
		jnz	SetTime
		call	randomb
		cmp	al,256*1/10
		mov	al,0
		rcl	al,1
SetTime:	mov	NiteTime,al
	
		retf

;============================================================================

;* IntelMessage - generate intelligence message
;*
;* pass: Intelfg - 0 = intelligence message disabled
;*                 1 = calculate range / bearing
;*                 2 = just display intelligence messages
;* ret : no regs
;* kill: assume all

IntelMessage:	mov	al,Intelfg
		test	al,al
		jnz	IntelEnabled
		jmp	EndMessage

IntelEnabled:	cmp	al,1		;have we calculated range / bearing?
		je	DoCalcs     
		jmp	GotData
	      
;* calc distances in ft/64
	
DoCalcs:	mov	si,offset obj2	;si -> enemy data

		mov 	ax,[si+4]
		sub 	ax,yft		;delta yft=obj yft-f16 yft
		sar 	ax,1
		sar 	ax,1
		sar 	ax,1
		sar 	ax,1
		sar 	ax,1
		sar 	ax,1		;delta yft/64
		mov 	cx,ax
		xor 	al,al
		mov 	ah,[si+15]  
		sub 	ah,ysec		;delta ysec=obj ysec-f16 ysec (*256)
		add 	ax,cx		;ydiff=(256*delta ysec)+(delta yft/64)
		mov 	dx,ax

		mov 	ax,[si+2]
		sub 	ax,xft		;delta xft=obj xft-f16 xft
		sar 	ax,1
		sar 	ax,1
		sar 	ax,1
		sar 	ax,1
		sar 	ax,1
		sar 	ax,1		;delta xft/64
		mov 	cx,ax
		xor 	al,al
		mov 	ah,[si+14]
		sub 	ah,xsec		;delta xsec=obj xsec-f16 xsec (*256)
		add 	ax,cx		;xdiff=(256*delta xsec)+(delta xft/64)
		mov	cx,ax

		call	topolarb	;ax = range ft/64, bp = bearing
		push	bp

		mov	bx,794		
		mul	bx		;distance in miles
		mov	ax,dx
		call	decim
		mov	si,offset digit
		mov	di,offset IntelMes2
		mov	al,[si+0]
		mov	[di+6],al
		mov	al,[si+1]
		mov	[di+5],al
		mov	al,[si+2]
		mov	[di+4],al

		pop	ax   		;bearing
		call	condegb
		call	decim
		mov	si,offset digit
		mov	al,[si+0]
		mov	[di+17],al
		mov	al,[si+1]
		mov	[di+16],al
		mov	al,[si+2]
		mov	[di+15],al

		mov	ax,Clock 	;init timer
		mov	IMClk,ax
		mov	Intelfg,2	;done calculation
		mov	ax,offset IntelMes1
		mov	MesPtr,ax

GotData:	mov	ax,zft
		cmp	ax,25		;have I taken off yet?
		jae	DisableIntel	;yes, disable intelligence message ->

		mov	ax,obj2+6	;enemy zft
		cmp	ax,25		;has he taken off yet?
		jae	DisableIntel	;yes, disable intelligence message ->

		mov	ax,Clock	;time to change message yet?
		sub	ax,IMClk	
		cmp	ax,2*50
		jc	EndMessage	;no ->
		mov	ax,Clock
		mov	IMClk,ax

;* change message if it is one of ours

		mov	ax,offset IntelMes1
		cmp	ax,MesPtr
		je	Mes2
		mov	ax,offset IntelMes2
		cmp	ax,MesPtr
		jne	EndMessage
		mov	ax,offset IntelMes1
		jmp	MesSelected
Mes2:		mov	ax,offset IntelMes2
MesSelected:	mov	MesPtr,ax
		jmp	EndMessage

DisableIntel:	mov	Intelfg,0

		mov	ax,offset obj2	;enable UFCP target T0
		mov	tinfo,ax

;* clear message if it is one of ours

		mov	ax,MesPtr	
		cmp	ax,offset IntelMes1
		je	OurMes
		cmp	ax,offset IntelMes2
		jne	EndMessage
OurMes:		mov	ax,offset Commes0
		mov	MesPtr,ax

EndMessage:	retf

;============================================================================

;* PrintScore - print kills / losses
;*
;* pass: TwoPlayerKills, Losses
;* ret : no regs
;* kill: assume all

PrintScore:	mov	si,offset ScoreMes
		mov	ax,TwoPlayerKills
		call	decim
		mov	al,digit
		mov	[si+7],al
		mov	al,digit+1
		mov	[si+6],al
		mov	ax,Losses
		call	decim
		mov	al,digit
		mov	[si+17],al
		mov	al,digit+1
		mov	[si+16],al
		ret

;============================================================================

;* TestForEnd - handle 'ending' sequence
;*
;* pass: Tick
;* ret : cf = 0 = not end yet
;*       cf = 1 = end of game now
;* kill: assume all

TestForEnd:	mov 	ax,EndCntr
		test 	ax,ax
		jz 	NotEnding  	;cf = 0
		
		mov	ax,EndFlashTmr	;is it time to flash message yet?
		add	ax,Tick
		mov	EndFlashTmr,ax
		cmp	ax,25
		jc	NoFlash		;no ->
	    
		xor	ax,ax
		mov	EndFlashTmr,ax
		mov	ax,offset Commes0
		cmp	ax,MesPtr
		je	PrtOldMes
		mov	bx,MesPtr
		mov	OldMesPntr,bx
		jmp	PrtCom
PrtOldMes:	mov	si,offset sound5
		call	mksoundb
		or	SoundFlags,001h	;/SOUND/
		mov	ax,OldMesPntr
PrtCom:		mov	MesPtr,ax	

NoFlash:	mov 	ax,EndCntr
		sub 	ax,Tick
		mov 	EndCntr,ax
		ja 	NotEnding   	;cf = 0
		stc
NotEnding:	retf

;============================================================================

;* StaleMate - test for stalemate
;*
;* pass: no regs
;* ret : cf = 0 = no stalemate / game already ending
;*       cf = 1 = stalemate
;* kill: ax, flags
;*
;* Conditions for stalemate are:-
;*    both aircraft out of weapons
;*    both aircraft on ground after at least one has taken off
;*
;* For the second condition we can use Intelfg to see if one plane has
;* taken off (Intelfg = 0).

StaleMate:	mov	ax,EndCntr
		test	ax,ax		;already ending?
		jnz	NotDraw

		mov	al,MyCtrlCode2
		and	al,HisCtrlCode2
		test	al,WeaponsMask
		jnz	IsDraw

		test	al,LandMask
		jz	NotDraw
		mov	al,Intelfg
		test	al,al
		jz	IsDraw

NotDraw:	clc			;cf = 0
		retf

IsDraw:		stc			;cf = 1
		retf

;============================================================================

;* LandingPractice - set up conditions for landing practice

LandingPractice:mov	rwyctrl,011b	;rnd airfield, start on runway
SelectAnother:	call	SelectRunway
		mov	ax,hfine	
		test	ax,00fffh	;have we selected a diagonal runway?
		jnz	SelectAnother	;yes ->

;* calc xsec, ysec offsets for approx 10 miles (3 sectors)

		xchg	al,ah		;hfine / 256
		shr	ax,1
		shr	ax,1
		shr	ax,1		
		and	ax,110b		;hfine / 2048 = table offset
		mov	bx,ax
		mov	ax,word ptr secoffset[bx]
		add	xsec,al
		add	ysec,ah

;* init model - set by trial and error - 125kts, 2500ft
		
		mov	throt,85
		mov	vtas,213*8
		mov	rfine,0
		mov	pfine,261+332
		mov	wheelbrake,0
		mov	airbrake,0
		mov	inair,1
		mov	undercarrage,0
		mov	zft,2500
		mov	screen1,0
		mov	screen2,3
		mov	screen3,6

		retf

;============================================================================

;* ChuckAndJrGoFishing - for MIGs

F_16		equ	0
MIG_27		equ	2
MIG_29		equ	4
MIG_31		equ	6

ChuckAndJrGoFishing:

;* select a random airfield / random runway (except diagonal)

		mov	rwyctrl,011b	;rnd a/f, start on runway
AFSearch:	call	SelectRunway
		mov	ax,hfine
		test	ax,00fffh	;have we selected a diagonal runway?		
		jnz	AFSearch

		xchg	al,ah		;hfine / 256
		and	ax,110000b	;0, 16, 32 or 48 -> N, E, S or W
		mov	si,offset QuickData
		add	si,ax

		push	si

		mov	ax,word ptr xsec ;al = xsec a/f, ah = ysec a/f
		push	ax

;* set up the F-16

		mov	ax,[si+F_16]	;al = F16 xsec offset, ah = ysec offset
		add	xsec,al
		add	ysec,ah

		mov	throt,100
		mov	vtas,500*8
		mov	rfine,0
		mov	pfine,261+332
		mov	wheelbrake,0
		mov	airbrake,0
		mov	inair,1
		mov	undercarrage,1
		mov	zft,1000

		mov	fuelwt,4000
		mov	weight,21086+4000 	;weight+fuelwt	

	       	mov 	RadMode,3	;asc mode
		mov 	screen1,2	;weapon
		mov 	screen2,4  	;air radar
		mov 	screen3,6	;dial

;* init weapons
;*
;*   2 AMRAAMs
;*  12 SIDEWINDERS
;* 500 BULLETS

		mov	si,offset MyPylonData
		mov	di,offset pylon
		mov	cx,9
		rep	movsw

		mov	di,offset nos3	;clear all other weapons
		xor	ax,ax
		mov	cx,18
		rep	stosw

		mov	nos3[0],5
		mov	nos2[0],0
		mov	nos1[0],0

		mov	nos3[1],0
		mov	nos2[1],1
		mov	nos1[1],2

		mov	nos3[2],0
		mov	nos2[2],0
		mov	nos1[2],2

		mov	di,offset pylonfail
		xor	al,al
		mov	cx,9
		rep	stosb		;clear weapons fail

		mov	cpylon,9

		mov	chaf+0,0	;chaf = 30 unpacked bcd
		mov	chaf+1,3
		mov	flares+0,0	;flares = 30 unpacked bcd
		mov	flares+1,3

		mov	cpylon,2       	;select Sidewinder
		mov	warmode,1

;* init moving objects list

		mov ax,0ffffh	 
		mov cx,24*34
		mov di,offset mobjblock
		rep stosw
		
exx		equ 48			;see AIRVIS.ASM

		mov ax,offset mobjblock+4*exx
		mov airbptr,ax

;* now sort out some MIGs

		pop	bx		;bl = xsec a/f, bh = ysec a/f

		pop	si

		mov	di,offset mobjblock
		mov	[di+0],word ptr 1	;MIG-27
		mov	[di+2],word ptr 0	;xft
		mov	[di+4],word ptr 0	;yft
		mov	[di+6],1000		;zft
		mov	ax,[si+MIG_27+8]
		mov	[di+8],ax		;heading
		mov	[di+10],word ptr 0	;pitch
		mov	[di+12],word ptr 0	;roll
		mov	al,bl
		add	al,[si+MIG_27]
		mov	[di+14],al		;xsec
		mov	al,bh
		add	al,[si+MIG_27+1]
		mov	[di+15],al		;ysec
		mov	[di+16],word ptr 0	;xvel
		mov	[di+18],word ptr 0	;yvel
		mov	[di+20],word ptr 0	;zvel
		mov	[di+22],word ptr 8	;dogfight
		mov	[di+30],word ptr 1	;enemy
		mov	[di+44],word ptr 1	;radar on
		mov	[di+46],word ptr 0	;bullet hit cntr

		mov	di,offset mobjblock+48
		mov	[di+0],word ptr 2	;MIG-29
		mov	[di+2],word ptr 0	;xft
		mov	[di+4],word ptr 0	;yft
		mov	[di+6],2000		;zft
		mov	ax,[si+MIG_29+8]
		mov	[di+8],ax		;heading
		mov	[di+10],word ptr 0	;pitch
		mov	[di+12],word ptr 0	;roll
		mov	al,bl
		add	al,[si+MIG_29]
		mov	[di+14],al		;xsec
		mov	al,bh
		add	al,[si+MIG_29+1]
		mov	[di+15],al		;ysec
		mov	[di+16],word ptr 0	;xvel
		mov	[di+18],word ptr 0	;yvel
		mov	[di+20],word ptr 0	;zvel
		mov	[di+22],word ptr 8	;dogfight
		mov	[di+30],word ptr 1	;enemy
		mov	[di+44],word ptr 1	;radar on
		mov	[di+46],word ptr 0	;bullet hit cntr

		mov	di,offset mobjblock+48+48
		mov	[di+0],word ptr 3	;MIG-31
		mov	[di+2],word ptr 0	;xft
		mov	[di+4],word ptr 0	;yft
		mov	[di+6],1000		;zft
		mov	ax,[si+MIG_31+8]
		mov	[di+8],ax		;heading
		mov	[di+10],word ptr 0	;pitch
		mov	[di+12],word ptr 0	;roll
		mov	al,bl
		add	al,[si+MIG_31]
		mov	[di+14],al		;xsec
		mov	al,bh
		add	al,[si+MIG_31+1]
		mov	[di+15],al		;ysec
		mov	[di+16],word ptr 0	;xvel
		mov	[di+18],word ptr 0	;yvel
		mov	[di+20],word ptr 0	;zvel
		mov	[di+22],word ptr 8	;dogfight
		mov	[di+30],word ptr 1	;enemy
		mov	[di+44],word ptr 1	;radar on
		mov	[di+46],word ptr 0	;bullet hit cntr

		retf

codeb		ends

;----------------------------------------------------------------------------

		end
	

