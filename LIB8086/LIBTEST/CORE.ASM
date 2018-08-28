;****************************************************************************
;*
;* F-16 COMBAT PILOT
;*
;* UK / US EGA v3.1
;*
;* v3.0 - 15.03.1989 - Mastered.
;* v4.0 - 23.05.1989 - Two disk version mastered.
;* v4.1 - 17.05.1989 - Electronic Arts sound effects added for USA version.
;*                   - Changes marked /SOUND/.
;*                   - New files USASOUND.ASM and F16FXIBM.OBJ (EA).
;*                   - Ground speed warning message added to MODEL.ASM.
;*                   - CTRL-E given priority over E in PAN.ASM.
;*		     - N-S / E-W moving map bug fixed (PANSP.ASM).
;*                   - Sidewinder lock bug fixed (AIRVIS.ASM).
;*                   - Stop turning on spot due to wind (MODEL.ASM).
;*                   - UFCP lights changed (PANDAT.ASM).
;*        01.06.1989 - EwrCode bug fix in AIRVIS.ASM.
;* v5.0 - 15.06.1989 - Mastered.
;* v5.1 - 20.06.1989 - Sidewinder kill zone increased (MOVE.ASM).
;*                   - Enemy fire rate increased (GAME.ASM).
;*        21.06.1989 - Extensive changes to improve enemy fire and SAM fire
;*                     (GAME.ASM, MOVE.ASM).
;*                   - oldpwrfg made public (PAN.ASM).
;*        22.06.1989 - planectrl bug fixed (MOVE.ASM).
;*                   - QuickData modified in (TWOPLYR.ASM).
;*                   - Enemy firing tweeked (GAME.ASM, MOVE.ASM).
;* v6.0 - 04.07.1989 - New USA masters.
;* v6.1 - 17.07.1989 - TWOPLYR slow BAUD bug fixed.
;* v7.0 - 17.07.1989 - New USA masters.
;*	
;****************************************************************************
 	
USA	equ 0				;0 = UK / 1 = USA
SCRAM	equ 0
GLADON	equ 0
RUNDEMO	equ 0
maxr	equ 45

		PUBLIC	SoundType	;/SOUND/

		public	main3
		public	FARDownLoad
		public 	firstframe
		public	hand
		PUBLIC	reload
		PUBLIC	Training
		PUBLIC	sorthud
		PUBLIC 	mag
		PUBLIC	frames
		PUBLIC	stab
		PUBLIC	core
		PUBLIC	main
		PUBLIC	hudfg
		PUBLIC	pancall
		PUBLIC	GraphicMode
		PUBLIC 	mission
		PUBLIC  submission
		PUBLIC	ejected
		
;* far subroutines


		extrn	califar:far
		extrn	SetBomb:far
		extrn	SetScram:far
	   	EXTRN	SendAplane:FAR
		EXTRN	Demo:FAR
		EXTRN	InitDemoFar:FAR		
		EXTRN	SetUpEwr:FAR
		EXTRN	Display:FAR
		EXTRN	SetUpApproach:FAR
		EXTRN 	setup:FAR
		EXTRN 	setmap:FAR
		EXTRN 	model:FAR
		EXTRN 	setdata:FAR
		EXTRN 	passdata:FAR
		EXTRN 	hud:FAR
		EXTRN 	panel:FAR
		EXTRN 	fini:FAR
		EXTRN 	crash:FAR
		EXTRN	eject:FAR
		EXTRN	iff:FAR
		EXTRN	passout:FAR
		EXTRN	ChuckAndJrGoFishing:FAR
	
;* external subroutines

		extrn	MakeSam:near
		extrn	findtanks:near
		EXTRN 	frontpanc:NEAR
		EXTRN 	leftpanc:NEAR
		EXTRN 	rightpanc:NEAR
		EXTRN 	backpanc:NEAR
		EXTRN 	overlay:NEAR
		EXTRN 	backpan:NEAR
		EXTRN 	frontpan:NEAR
		EXTRN 	leftpan:NEAR
		EXTRN 	rightpan:NEAR
		EXTRN 	clear:NEAR
		EXTRN 	horizon:NEAR
		EXTRN 	prword:NEAR
		EXTRN 	prbyte:NEAR
		EXTRN 	trig:NEAR
		EXTRN 	visual:NEAR
		EXTRN 	sqr:NEAR
		EXTRN 	angles:NEAR
		EXTRN 	sortfire:NEAR
		EXTRN	gameplay:NEAR

;* external data

		extrn	iffflag:byte
		extrn	control:byte
		extrn	gmakelock:byte
		extrn	makelock:byte
	     	extrn	affirm:byte
	     	extrn	gaffirm:byte
		extrn	inrngfg:byte
		extrn	goodlock:byte
	      	extrn	dialock:byte
		extrn	screen:byte
		extrn	fuelwt:word
		extrn	vflag2:word
		extrn	vflag1:word
		extrn	screenseg:word
		extrn	segptr:word
		extrn	screenstart:word
		extrn	oldflag:word
		extrn	lgfg:word
		extrn	flightno:byte
		extrn	outfg:byte		
		EXTRN	pwrstat:WORD
	    	EXTRN	lgstat:WORD
		EXTRN	DialGndCol:WORD
		EXTRN	sstemp:WORD
		EXTRN	sptemp:WORD
		EXTRN 	mdx:WORD
		EXTRN	speeds:WORD
		EXTRN	delta:WORD
		EXTRN	letter:WORD
		EXTRN 	tick:WORD
		EXTRN	buffptr:WORD
		EXTRN	oldkeyvec:WORD
		EXTRN 	gridx:WORD
		EXTRN	fired:WORD
		EXTRN	your:WORD
		EXTRN 	xft:WORD
		EXTRN	yft:WORD
		EXTRN	zft:WORD	
		EXTRN	xsec:WORD
		EXTRN	hdg:WORD
		EXTRN	pitch:WORD
		EXTRN	roll:WORD
		EXTRN	oldtimervec:WORD
		EXTRN 	ailposn:WORD
		EXTRN	eleposn:WORD
		EXTRN 	fover:WORD
		EXTRN 	lover:WORD
		EXTRN 	bover:WORD
		EXTRN 	rover:WORD
		EXTRN	faint:WORD
       		EXTRN	normcol:WORD
		EXTRN	demos:BYTE
		EXTRN	demon:BYTE
		EXTRN 	nitetime:BYTE
		EXTRN 	lantstat:BYTE
		EXTRN	diefg:BYTE
		EXTRN 	viewmode:BYTE
		EXTRN	preview:BYTE
		EXTRN 	pitd:BYTE
		EXTRN	button:BYTE
		EXTRN 	status:BYTE
		EXTRN 	framecount:BYTE
		EXTRN 	key:BYTE
		EXTRN	framerate:BYTE
		EXTRN	MyHoldMes:BYTE
		EXTRN	ufstat:BYTE
		EXTRN	SoundFlags:WORD		;/SOUND/

;* TWO PLAYER EXTERNALS

		EXTRN	InitFP2Comms:FAR
		EXTRN	StopFP2Comms:FAR
		EXTRN	FP2StartSync:FAR
		EXTRN	FP2LoopSync:FAR
		EXTRN	SendFP2Data:FAR
		EXTRN	ReadFP2Data:FAR
		EXTRN	SelectRunwayFar:FAR
		EXTRN	LandingPractice:FAR
		EXTRN	InitTwoPlayer:FAR
		EXTRN	IntelMessage:FAR
		EXTRN	TestForEnd:FAR
		EXTRN	Stalemate:FAR
		EXTRN	pfine:WORD
		EXTRN	CommsDevice:WORD
		EXTRN	BaudRate:WORD  
		EXTRN	seedl:WORD
		EXTRN	seedh:WORD
		EXTRN	clock:WORD
		EXTRN	mesptr:WORD
		EXTRN	Kills:WORD
		EXTRN	TwoPlayerKills:WORD
		EXTRN	Losses:WORD
		EXTRN	EndCntr:WORD
		EXTRN	your:WORD
		EXTRN	obj2:WORD
		EXTRN	MissilesFired:WORD
		EXTRN	HeatOfTheNite:BYTE
		EXTRN	ysec:BYTE
		EXTRN	wxsec:BYTE
		EXTRN	wysec:BYTE
		EXTRN	epmax:BYTE
		EXTRN	eprate:BYTE
		EXTRN	MyCtrlCode:BYTE
		EXTRN	HisCtrlCode:BYTE
		EXTRN	MyCtrlCode2:BYTE
		EXTRN	HisCtrlCode2:BYTE
		EXTRN	HoldCode:BYTE
		EXTRN	EscCode:BYTE
		EXTRN 	Player:BYTE
		EXTRN	Intelfg:BYTE
		EXTRN	KillMes:BYTE
		EXTRN	DrawMes:BYTE
		EXTRN   commes0:BYTE
		EXTRN	EscMask:ABS
		EXTRN	EjectMask:ABS
		EXTRN	DeadMask:ABS

;============================================================================
		
stack		segment para stack 'stack'
		assume ss:stack
stab		db 0200h dup("@")
stack		ends

;============================================================================
 
data		segment para public 'data'
		assume ds:data

;* WARNING!!! - no variables above the dummy screen

dscreen		db 1600 dup(0)

IF USA					;/SOUND/
SoundType	db	1,0		;/SOUND/
ELSE					;/SOUND/
SoundType	db	1,0		;/SOUND/
ENDIF				       	;/SOUND/

lastkey		dw -1

keyvec		equ 024h
timervec	equ 020h

lasttank	dw 0
Training	db 0,0

FrontView	equ 71
BackView	equ 73
LeftView	equ 79
RightView	equ 81

overa		dw offset fover
		dw offset rover
		dw offset bover
		dw offset lover

mflag		db 0
mag		db 63
cocol		dw 0
flag		db 0
hudfg		db 0
hand		db 0,0
FingerOfFudge	db 0,0
colss		db 000000b,000001b,000010b,000011b
		db 000100b,000101b,000110b,000111b
	  	db 010000b,010001b,010010b,010011b
		db 010100b,010101b,010110b,010111b

frames		db 4,0

pancallc       	dw offset frontpanc 
		dw offset rightpanc	
		dw offset backpanc
		dw offset leftpanc

pancall		dw offset frontpan 
		dw offset rightpan	
		dw offset backpan
		dw offset leftpan

vidlist		db 035h,02dh,02eh,07h,05bh,02h,057h
		db 057h,02h,03h,00h,00h

keytab		db FrontView,RightView,BackView,LeftView

Gmodes		dw offset cgamode

GraphicMode	db 0,0

OldHold		db 0,0

mission		db 6,0
submission	dw 0

ejected		db 0,0
mtable		db 0,1,3,3

reload		db 2,0

data		ends

;============================================================================

code		segment byte public 'code'
		assume cs:code

core:          	mov ax,data
		mov ds,ax

		mov ax,ss
		mov sstemp,ax
		mov ax,sp
		mov sptemp,ax
		
     		mov ax,0
		mov es,ax

loop5:		mov al,es:[043fh] 	;wait for disc motor to start
		test al,3		;drives a and b
		jnz loop5

		call setup
		
		call setdata

IF RUNDEMO
		mov	demos,1		;KJB
ENDIF

		mov ax,fuelwt
		cmp ax,1000
		ja lp11
		mov fuelwt,1000
lp11:		mov ax,oldflag
		mov lgfg,ax
	   	mov al,0
		mov outfg,al

		call far ptr initmode

	      	call setmap 
		call SetUpEwr	


		


		mov al,control
		cmp al,2
		je qer
		cmp al,4
		jne qer2
 		mov ax,0
	      	int 033h
	      	jmp qer2

qer:		call califar
		
qer2:		nop
		

if GLADON
		jmp Gladiator
endif

;* sort out demo mode

		mov	al,demos
		test	al,al	
		jz	notdemo
		call	InitDemoFar
		jmp	main45
notdemo:

if USA
		mov 	al,mission
		cmp	al,9		;QuickStart
		jne	NoQuick
		call	ChuckAndJrGoFishing
		jmp	main45
NoQuick:
	
endif
	

;* sort out the mission

		call far ptr SortMission



		mov al,mission
		cmp al,8		;gladiator?
		jne not2plyr
		jmp gladiator	

not2plyr:	cmp al,10		;landing practice?
		jne notlanding
		mov iffflag,1
		call LandingPractice
		jmp main45		;no iff input ->

notlanding:	cmp al,5		;scramble
		jne notscramble
		call SetScram
	    	jmp main

notscramble: 	

;----------------------------------------------------------------------------

main:  	      	mov al,mission
		cmp al,6
		jne main31
	      	mov al,flightno
	      	test al,al
	      	jnz main31

		call FindTanks
main31:	 	



		call SelectRunwayFar

mm34:
	if SCRAM

	       	call SetScram
	else
		call sendaplane
	endif



	 	call firstframe		;get iff

;**************************************
;
;	START OF MAIN LOOP
;
;**************************************
main45:		call ChangeView	
 
mn20: 		mov al,demon
		test al,al
		jz skipdemo
		call Demo
skipdemo:
	
over:	 	mov al,mission
		cmp al,8
		je ovb
		mov al,demos
		test al,al
		jnz ovb
		call SetBomb
ovb:		call model   
		mov al,mission
		cmp al,6
		jne over33

		mov ax,clock
		sub ax,lasttank
		cmp ax,350
		jb over33
		mov ax,clock
		mov lasttank,ax

	     	call gameplay		;changes xft,yft,zft,hdg,pitch,roll
over33:		call sortfire
		call trig
main3:	    	call horizon	    	;draws horizon
		call visual	      	;draws objects in visible sectors

;* sorthud MUST be last visual thing done

     	     	call UploadPanel


		call sorthud
	     	
		call download

	 	mov al,key[29]		;test CTRL-E for eject
		and al,key[18]	   
		jz ctrl_esc
		call eject

ctrl_esc:	mov al,key[1] 		;test CTRL-ESC for abort
		and al,key[29]
		jz testend
		mov diefg,18

testend:	mov al,diefg
	      	test al,al
	      	jnz sortending		;end of game ->

;* test for pause

pause:		mov al,key[25]		;P key pressed? 
		test al,al
		jz framewait
pause1:		mov al,key[25]		;P key released?
		test al,al
		jnz pause1

;* switch to front panel and print 'PAUSED - P TO CONT' in comms panel

		mov ax,mesptr
		push ax
       		mov ax,offset MyHoldMes
		mov mesptr,ax
		call firstframe
		call download
		pop ax
		mov mesptr,ax

		or	SoundFlags,08000h	;/SOUND/

pause2:		mov al,key[25]		;P key pressed? 
		test al,al
		jz pause2
pause3:		mov al,key[25]		;P key released?
		test al,al
		jnz pause3

	    	mov tick,4		;frig tick

;* limit ticks 4 min - maxr max

framewait:	mov al,byte ptr tick
		cmp al,4
		jb framewait
		cmp al,maxr
		jbe frameok
		mov al,maxr
frameok:	mov frames,al
	    	
		mov bl,al
		xor bh,bh
		sal bx,1
		mov ax,speeds[bx]
		mov delta,ax
		mov tick,0
		jmp main45   
;*************************************
;
;	END OF MAIN LOOP
;
;*************************************	

sortending:	mov al,diefg		;check any non-crash conditions
	 	cmp al,10
		je fini2 		;safe eject ->
		cmp al,18
		je fini2		;aborted ->
		cmp al,19
		je fini2		;in hanger ->
		cmp al,22
		je fini2		;dead stick landing ->
     		cmp al,24		;heavy landing
		je fini2
     		cmp al,25		;captured by enemy
		je fini2


fini3:		call crash	
fini2:		call passdata
		call fini

		mov ax,3
		int 010h
		mov ah,04ch
		xor al,al
		int 021h
		retf

;----------------------------------------------------------------------------

;* replaces main loop if 'gladiator' option selected

gladiator:	
;* do once only ...

		call InitFP2Comms
		mov al,NiteTime
		mov HeatOfTheNite,al

;* do at start of each game ...

startgame:	call InitTwoPlayer
		call SelectRunwayFar

		call firstframe		;get iff		

		mov al,diefg
		cmp al,18
		je fini2		;failed iff ->

		call FP2StartSync

		xor ax,ax
		mov epmax,al
		mov eprate,al
		mov pfine,ax
	
;* main game loop ...
	
gloop10:	call ChangeView	
 


		mov al,key[1] 		;set escape code if CTRL-ESC pressed
		and al,key[29]
		or EscCode,al

		mov al,key[29]		;test ctrl-E for eject
		and al,key[18]	   
		or ejected,al
	
		mov al,HoldCode
		mov OldHold,al
		test al,al
		jns skip1
		
		mov	viewmode,0	;pause just pressed, force front view
		mov	reload,2

		jmp skip2
skip1:		jnz cont1

skip2:		call model
		call sortfire

		mov ax,your		;have I been hit by a missile?
		test ax,ax
		jz cont1
		mov diefg,12

cont1:	   	call SendFP2Data	;***** TX DATA *****

		
		mov al,OldHold
		test al,al
		js skip3   
		jnz cont2
  
skip3:		call trig
	    	call horizon

cont2: 		mov cx,2*50		
		call ReadFP2Data	;***** RX DATA *****
		
		mov al,OldHold
		test al,al
		js skip4
		jnz cont3
 
skip4:		call visual 

		mov al,Intelfg 
		test al,al		;is intelligence message enabled?
		jz nointel	 	;no ->
		call IntelMessage

;* sorthud MUST be last visual thing done

nointel:      	call uploadpanel
		call sorthud
	      
	      	call download

cont3:		;* moved here to stop screen swapping when paused

		mov al,MyCtrlCode	;check for ESCape
		or al,HisCtrlCode
		test al,EscMask
		jz notescape
		jmp fini22
notescape:

;* test for eject

		mov  al,MyCtrlCode2
		test al,EjectMask	;have I ejected?
		jnz myeject		;yes ->
		mov al,HisCtrlCode2
		test al,EjectMask	;has he ejected?
		jz testdead
		jmp initend		;yes, init end sequence ->
		
;* test for dead
		
testdead:	mov al,MyCtrlCode2  
		mov ah,HisCtrlCode2

		mov bl,al 		;are we both dead?
		and bl,ah
		test bl,DeadMask
		jnz bothdead		;yes ->

		test al,DeadMask	;am I dead?
		jnz medead		;yes ->

		test ah,DeadMask	;is he dead?
		jnz initend		;yes ->

;* test for stalemate
		
		call Stalemate
		jc initend2

loopback:	call FP2LoopSync
	
gendloop:	mov al,OldHold		
		test al,al		;is game held?
		jz cont4		;no ->
		and HoldCode,07fh	;clear just held bit, test for released
		jnz cont4		;not released ->
		mov tick,4
cont4:

;* test for end of 'ending' sequence

		call TestForEnd
		jnc notend
		jmp startgame
notend:		

;* limit ticks 4 min - maxr max

framewait2:	mov al,byte ptr tick
		cmp al,4
		jb framewait2
		cmp al,maxr
		jbe frameok2
		mov al,maxr
frameok2:	mov frames,al
	
		mov bl,al
		xor bh,bh
		sal bx,1
		mov ax,speeds[bx]
		mov delta,ax
		mov tick,0

		jmp gloop10		;>>>>> go back round again >>>>>
	
;* handle eject / eject and die

myeject:	call eject
		mov al,diefg
		cmp al,10		;safe landing?
		je ejectok		;yes ->
		call crash
ejectok:	inc Losses		;aircraft destroyed
		jmp startgame

;* handle both dead / me dead

bothdead:	inc TwoPlayerKills	
medead:		inc Losses
		call crash
		jmp startgame
			
;* win game

initend:	inc TwoPlayerKills
		mov ax,offset KillMes
		jmp initend3

;* stalemate

initend2:	mov ax,offset DrawMes

initend3:	mov mesptr,ax
		mov EndCntr,7*50  
		xor ax,ax
		mov word ptr MyCtrlCode,ax
		mov word ptr HisCtrlCode,ax
		mov HoldCode,al

		mov	viewmode,0	;force front view
		mov	reload,2

		jmp loopback

;* the only way out ...

fini22:		call StopFP2Comms
		mov ax,TwoPlayerKills
		mov Kills,ax
		jmp fini2

;----------------------------------------------------------------------------

;* generate first frame and input iff
;*
;* ret : cf = 0 = iff ok
;*       cf = 1 = iff failed (also diefg = 18 = ABORTED)
;*
;* This routine can be called again but iff will be ignored. 

firstframe:	mov viewmode,0
		mov reload,3
		call model    
		call trig     
	    	call horizon  
		call visual  
		call uploadpanel 
	    	mov ax,data   
		mov es,ax     
		mov ds,ax     
		call sorthud  
	IFE USA
	     	call iff 		;last routine before ret (cf valid)
	ENDIF
		ret	       	

;----------------------------------------------------------------------------

sorthud:	mov al,hudfg
		test al,al
		jnz loop33
		
		mov al,viewmode
		test al,al
		jnz loop33

	  	call hud
	
loop33:		mov al,viewmode
		cmp al,2
		jne main4
	   	
	       ;	call backpan
	     	mov al,2

main4:		mov bl,al
		xor bh,bh
		sal bx,1
		mov si,overa[bx]
		call overlay

;* if redout / blackout then overlay effect

	     	mov ax,faint
	     	test ax,ax
	      	jz skippass
		call passout
		mov reload,2
skippass:	ret

;----------------------------------------------------------------------------

;* Home - front view
;* PgUp - back view
;* End  - left view
;* PgDn - right view

ChangeView:   	mov cx,0
		mov bx,lastkey
		test bx,bx
		js sort5
		mov al,key[bx]
		test al,al
		jnz sorte
		mov bx,-1
		jmp change

sort5:	     	mov cx,0
		mov bx,FrontView
		mov al,key[bx]
		test al,al
		jnz change

		mov cx,2
		mov bx,BackView
		mov al,key[bx]
		test al,al
		jnz change

		mov cx,3
		mov bx,LeftView
		mov al,key[bx]
		test al,al
		jnz change

		mov cx,1
		mov bx,RightView
		mov al,key[bx]
		test al,al
		jnz change

sorte:		ret

			
change:		mov LastKey,bx
		cmp viewmode,cl
		je sorte2  	;same view
		mov viewmode,cl
		mov reload,2
		

sorte2:		mov al,key[42]
		or al,key[54]
		test al,al
		jz sorte
;
; shift pressed cancel key
;
sorte3:		mov LastKey,-1
		ret
  
UploadPanel: 	and your[44],001b	;clear chaff/flare - leave radar on

  

		mov al,reload
		test al,al
		jz up01
		dec reload

		mov bl,viewmode
		xor bh,bh
		sal bx,1
		call pancall[bx]

up01:		mov bl,viewmode
		xor bh,bh
		sal bx,1
		call pancallc[bx]


		ret


FARDownLoad:	call download
		retf

download:	
emovesc:	mov bl,screen
		xor bh,bh
		add bx,2
		and bx,2
		mov screen,bl

		mov ax,screenseg[bx]
		mov segptr,ax 
	   	mov ax,screenstart[bx]
		mov cx,ax
		mov dx,03d4h


		cli
		mov al,0ch
		mov ah,ch
		out dx,ax
		jmp $+2
		
	   	mov al,0dh
		mov ah,cl
		out dx,ax
		jmp $+2
	      	sti

loop56:	    	mov dx,03dah 	;make sure v trace is not occuring
	    	in al,dx
	    	test al,1000b
	    	jnz loop56
	
;
;	start address is loaded at the start of v trace
;
loop44:		mov dx,03dah
		in al,dx  	;wait for vertical retrace to occur
		test al,1000b
	     	jz loop44


		ret		

	
;----------------------------------------------------------------------------

code		ends

;============================================================================

codeb		segment byte public 'code'
		assume cs:codeb


;----------------------------------------------------------------------------

initmode:	mov bl,GraphicMode
		xor bh,bh
		sal bx,1
		call Gmodes[bx]
		retf

;----------------------------------------------------------------------------

cgamode:	mov ax,0dh
	   	int 010h		
		ret		

;----------------------------------------------------------------------------
				

;----------------------------------------------------------------------------
    
colours:	push ax
		cli
		mov dx,03dah
		in al,dx
		pop ax
		mov dx,03c0h
		out dx,al
		mov al,ah
		out dx,al
		mov al,020h
		out dx,al
		sti
		retf

;----------------------------------------------------------------------------

;* sort mission - sort out training mission

;* submission b0: free flight		mission =  9
;*            b1: landing pracice	   ..	= 10
;*            b2: scramble		   ..	=  5
;*            b3: hammerblow		   ..	=  3
;*            b4: deepstrike		   ..	=  4
;*            b5: tankbuster		   ..	=  2
;*            b6: watchtower		   ..   =  1

SortMission:	mov	al,mission
		cmp	al,7		;training ->
		jne	SortMissEnd	;no ->

		mov	bx,submission

		mov	al,9	  	;free flight?
		shr	bx,1
		jc	GotMission
		mov	al,10	  	;landing practice?
		shr	bx,1
		jc	GotMission
		mov	al,5	  	;scramble?
		shr	bx,1
		jc	GotMission
		mov	al,3	  	;hammerblow?
		shr	bx,1
		jc	GotMission
		mov	al,4	  	;deepstrike?
		shr	bx,1
		jc	GotMission
		mov	al,2	  	;tankbuster?
		shr	bx,1
		jc	GotMission
		mov	al,1	  	;watchtower
GotMission:	mov	mission,al
		mov	Training,1

SortMissEnd:	retf

;----------------------------------------------------------------------------

codeb		ends

		end core

