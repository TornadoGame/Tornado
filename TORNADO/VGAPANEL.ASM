;****************************************************************************
;*
;* VGAPANEL.ASM
;*
;* VGA panel disk load / download / update routines.
;*
;* 12.08.1991 - KJB
;* 18.01.1992 - KJB - LOOKDOWN and LOOKUP panels added.
;* 02.04.1992 - KJB - MAPPAN added.
;* 12.06.1992 - KJB - VGA_DrwPilotPan / VGA_DrwNavigPan added.
;* 16.06.1992 - KJB - DrawRadarNoise added.
;* 17.01.1993 - KJB - InterleaveData and RetrieveData made far and public.
;* 17.01.1993 - KJB - DrawPreviewPan added.
;* 18.01.1993 - KJB - StoreWorkScreen added.
;* 21.01.1993 - KJB - CopyPreviewPan added.
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	VGA_InitPanels
		PUBLIC	VGA_LoadPanel
		PUBLIC	VGA_ClrPilotPan
		PUBLIC	VGA_ClrNavigPan
		PUBLIC	VGA_DrwPilotPan
		PUBLIC	VGA_DrwNavigPan
		PUBLIC	VGA_IronWork
		PUBLIC	VGA_Brackets
		PUBLIC	DrawRadarNoise
		PUBLIC	InterleaveData
		PUBLIC	RetrieveData
		PUBLIC	CopyPreviewPan
		PUBLIC	DrawPreviewPan
		PUBLIC	StoreWorkScreen

		EXTRN	LoadFile:FAR

		EXTRN	LoadExtrnPan:NEAR
		EXTRN	LoadFramePan:NEAR

		EXTRN	WorkScreen:WORD
		EXTRN	WorkScrPtr:WORD
		EXTRN	PanelMode:WORD
		EXTRN	AutoMode:WORD
		EXTRN	Reheat:WORD
		EXTRN	FuelWt:WORD
		EXTRN	RedWarnings1:WORD
		EXTRN	RedWarnings2:WORD
		EXTRN	AmbWarnings1:WORD
		EXTRN	AmbWarnings2:WORD
		EXTRN	GearTimer:WORD
		EXTRN	PILOT_MFD:WORD
		EXTRN	NAVIG_MFD:WORD
		EXTRN	TAB1:WORD
		EXTRN	TAB2:WORD
		EXTRN	CrewMode:WORD
		EXTRN	RadarMode:WORD
		EXTRN	TornadoType:WORD
		EXTRN	ArmMode:WORD
		EXTRN	AirArmMode:WORD
		EXTRN	LastFrame:WORD

		EXTRN	PilotPanel:BYTE
		EXTRN	PSidePanel:BYTE
		EXTRN	NavigPanel:BYTE
		EXTRN	NSidePanel:BYTE
		EXTRN	FramePanel:BYTE
		EXTRN	ExtraPanel:BYTE
		EXTRN	VGA_RGB_Data:BYTE
		EXTRN	VGA_Panel:BYTE
		EXTRN	VGA_Panel1:BYTE
		EXTRN	VGA_Panel2:BYTE
		EXTRN	SetPaletteFlag:BYTE
		EXTRN	Gear:BYTE
		EXTRN	WheelBrakes:BYTE
		EXTRN	OxyDollyPos:BYTE
		EXTRN	ThrustRvrs:BYTE
		EXTRN	TFBRisk:BYTE
		EXTRN	SSF_Engine1:BYTE
		EXTRN	SSF_Engine2:BYTE
		EXTRN	Jettison:BYTE
		EXTRN	AppProgFlag:BYTE
		EXTRN	AppProgSeq:BYTE
		EXTRN	Attention:BYTE
		EXTRN	Night:BYTE
		EXTRN	AutoThrot:BYTE
		EXTRN	LateArmAnim:BYTE
		EXTRN	ECMActive:BYTE
		EXTRN	RWRThreatFlags:BYTE
		EXTRN	SSF_RWR:BYTE
		EXTRN	SSF_Gear:BYTE

;============================================================================

		INCLUDE	MAINDATA.INC
		INCLUDE	MFD.INC
		INCLUDE	TAB.INC

		INCLUDE	\LIB8086\USEFUL.INC
		INCLUDE	\LIB8086\VGA_DRVR.INC
		INCLUDE	\LIB8086\PALMACRO.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

PILOTPAN_SEG	EQU	VGA_PAGE_2
PILOTPAN_OFF	EQU	320*96/4 	;<<<<< same as screen position <<<<<
PILOTPAN_SIZE	EQU	320*104
PILOTPAN_SCR	EQU	320*96/4

PSIDEPAN_SEG	EQU	VGA_PAGE_2
PSIDEPAN_OFF	EQU	320*0/4
PSIDEPAN_SIZE	EQU	320*40
PSIDEPAN_SCR	EQU	320*160/4

NAVIGPAN_SEG	EQU	VGA_PAGE_3
NAVIGPAN_OFF	EQU	320*0/4 	;<<<<< same as screen position <<<<<
NAVIGPAN_SIZE	EQU	320*200
NAVIGPAN_SCR	EQU	320*0/4

NSIDEPAN_SEG	EQU	VGA_PAGE_2
NSIDEPAN_OFF	EQU	320*40/4
NSIDEPAN_SIZE	EQU	320*40
NSIDEPAN_SCR	EQU	320*160/4

FRAMEPAN_SEG	EQU	VGA_PAGE_2
FRAMEPAN_OFF	EQU	320*80/4
FRAMEPAN_SIZE	EQU	320*16
FRAMEPAN_SCR	EQU	320*122/4

EXTRAPAN_OFF	EQU	320*0/4
EXTRAPAN_SIZE	EQU	320*200

;* load panel switch (wrt panel type)

LoadPanel	DW	LoadPilotPan	;PILOTPAN
		DW	LoadPSidePan	;PSIDEPAN
		DW	LoadNavigPan	;NAVIGPAN
		DW	LoadNSidePan	;NSIDEPAN
		DW	LoadExtrnPan 	;EXTRNPAN
		DW	LoadLookDownPan	;LOOKDOWN
		DW	LoadFramePan	;LOOKUP
		DW	LoadMapPan	;MAPPAN

;* current panel RGB data

PanelRGBPtr	DW	-1		;(-1 = uninitialized)

;* failures mask

Failures	DW	0

;* ADV weapons status display blink

ARM_BLINK_TIME	EQU	50		;arm blink time (secs*100)

ArmBlinkTimer	DW	ARM_BLINK_TIME	;arm blink timer (secs*100)

ArmBlink	DB	0		;blink state

		EVEN

DATA		ENDS

;============================================================================

PANCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:PANCODE
		ASSUME DS:DATA

;* QEXTRA - QExtraSprite macro
;*
;* pass: xs = x source (4 pixel boundary)
;*       ys = y source (4 pixel boundary)
;*       xd = x dest (4 pixel boundary)
;*       yd = y dest (4 pixel boundary)
;*        w = width (multiple of 4 pixels)
;*        d = depth
;* ret : nothing
;* kill: assume all

QEXTRA		MACRO	xs,ys,xd,yd,w,d

		mov	si,((xs)/4)+((ys)*80)
		mov	di,((xd)/4)+((yd)*80)
		mov	bl,(w)/4
		mov	bh,(d)
		mov	bp,80-((w)/4)
		call	QExtraSprite

		ENDM

;----------------------------------------------------------------------------

;* MEXTRA - MExtraSprite macro
;*
;* pass: xs = x source (4 pixel boundary)
;*       ys = y source (4 pixel boundary)
;*       xd = x dest (4 pixel boundary)
;*       yd = y dest (4 pixel boundary)
;*        w = width (multiple of 4 pixels)
;*        d = depth
;* ret : nothing
;* kill: assume all

MEXTRA		MACRO	xs,ys,xd,yd,w,d

		mov	si,((xs)/4)+((ys)*80)
		mov	di,((xd)/4)+((yd)*80)
		mov	bl,(w)/4
		mov	bh,(d)
		mov	bp,80-((w)/4)
		call	MExtraSprite

		ENDM

;----------------------------------------------------------------------------

;* VIDBLIT - VideoBlitter macro
;*
;* pass: page = source video page
;*         xs = x source (4 pixel boundary)
;*         ys = y source (4 pixel boundary)
;*         xd = x dest (4 pixel boundary)
;*         yd = y dest (4 pixel boundary)
;*          w = width (multiple of 4 pixels)
;*          d = depth
;* ret : nothing
;* kill: assume all

VIDBLIT		MACRO	page,xs,ys,xd,yd,w,d

		mov	dx,page
		mov	si,((xs)/4)+((ys)*80)
		mov	di,((xd)/4)+((yd)*80)
		mov	bl,(w)/4
		mov	bh,(d)
		mov	bp,80-((w)/4)
		call	VideoBlitter

		ENDM

;----------------------------------------------------------------------------

;* VGA_InitPanels
;*
;* pass: nothing
;* ret : cf = 0 = no error
;*       cf = 1 = error
;* kill: assume all
;*       VGA_SEQ_MAPMSK

VGA_InitPanels	PROC	NEAR

		push	es

;--------------------------
;* init pilot's front panel
;--------------------------

		mov	dx,OFFSET PilotPanel

		mov	cx,PILOTPAN_SIZE

		mov	ax,SEG WorkScreen
		mov	es,ax
		xor	di,di		;es:di -> start of WorkScreen

		call	LoadFile
		jnc	@F
		jmp	InitExit	;cf = 1 = error ->

@@:		mov	ax,PILOTPAN_SEG
		mov	es,ax
		mov	di,PILOTPAN_OFF
		mov	cx,PILOTPAN_SIZE

		call	InterleaveData

;-------------------------
;* init pilot's side panel
;-------------------------

		mov	dx,OFFSET PSidePanel

		mov	cx,PSIDEPAN_SIZE

		mov	ax,SEG WorkScreen
		mov	es,ax
		xor	di,di		;es:di -> start of WorkScreen

		call	LoadFile
		jnc	@F
		jmp	InitExit	;cf = 1 = error ->

@@:		mov	ax,PSIDEPAN_SEG
		mov	es,ax
		mov	di,PSIDEPAN_OFF
		mov	cx,PSIDEPAN_SIZE

		call	InterleaveData

;------------------------------
;* init navigator's front panel
;------------------------------

		mov	dx,OFFSET NavigPanel

		mov	cx,NAVIGPAN_SIZE

		mov	ax,SEG WorkScreen
		mov	es,ax
		xor	di,di		;es:di -> start of WorkScreen

		call	LoadFile
		_JC	InitExit	;cf = 1 = error ->

		mov	ax,NAVIGPAN_SEG
		mov	es,ax
		mov	di,NAVIGPAN_OFF
		mov	cx,NAVIGPAN_SIZE

		call	InterleaveData

;-----------------------------
;* init navigator's side panel
;-----------------------------

		mov	dx,OFFSET NSidePanel

		mov	cx,NSIDEPAN_SIZE

		mov	ax,SEG WorkScreen
		mov	es,ax
		xor	di,di		;es:di -> start of WorkScreen

		call	LoadFile
		_JC	InitExit	;cf = 1 = error ->

		mov	ax,NSIDEPAN_SEG
		mov	es,ax
		mov	di,NSIDEPAN_OFF
		mov	cx,NSIDEPAN_SIZE

		call	InterleaveData

;-------------------------
;* init canopy frame panel
;-------------------------

		mov	dx,OFFSET FramePanel

		mov	cx,FRAMEPAN_SIZE

		mov	ax,SEG WorkScreen
		mov	es,ax
		xor	di,di		;es:di -> start of WorkScreen

		call	LoadFile
		jc	InitExit	;cf = 1 = error ->

		mov	ax,FRAMEPAN_SEG
		mov	es,ax
		mov	di,FRAMEPAN_OFF
		mov	cx,FRAMEPAN_SIZE

		call	InterleaveData

;------------------
;* init extra panel
;------------------

		mov	dx,OFFSET ExtraPanel

		mov	cx,EXTRAPAN_SIZE

		mov	ax,SEG WorkScreen
		mov	es,ax
		xor	di,di		;es:di -> start of WorkScreen

		call	LoadFile
		jc	InitExit	;cf = 1 = error ->

;* interleave extra panel into VGA work screen page

		mov	ax,WorkScrPtr
		mov	es,ax
		mov	di,EXTRAPAN_OFF
		mov	cx,EXTRAPAN_SIZE

		call	InterleaveData

;* retrieve extra panel back into WorkScreen[] and CopyScreen[] buffers

		mov	dx,WorkScrPtr

		call	RetrieveData

;--------------------
;* ADV panel overlays
;--------------------

		cmp	TornadoType,ADV_TORNADO
		jne	@F

		push	WorkScrPtr

;* weapon status panel

		mov	WorkScrPtr,PILOTPAN_SEG

		VIDBLIT	NAVIGPAN_SEG,128,149,56,96,64,45

;* late arming switch animation

		mov	WorkScrPtr,NAVIGPAN_SEG

		VIDBLIT	NAVIGPAN_SEG,208,87,128,94,64,11

		pop	WorkScrPtr

;------------------
;* reset error flag
;------------------

@@:		clc			;cf = 0 = no error

InitExit:	pop	es

		ret

VGA_InitPanels	ENDP

;----------------------------------------------------------------------------

;* InterleaveData - copy panel data to VGA screen page and interleave
;*
;* pass: cx = size
;*       es:di -> VGA page:offset
;* ret : nothing
;* kill: assume all
;*       VGA_SEQ_MAPMSK

InterleaveData	PROC	FAR

		push	ds

		shr	cx,1		;/2
		shr	cx,1		;/4 (size of one plane)

		SLCTREG	VGA_SEQ,VGA_SEQ_MAPMSK

		mov	ax,SEG WorkScreen
		mov	ds,ax
		xor	si,si		;ds:si -> start of WorkScreen

		mov	al,0001b	;map 0
		out	dx,al
		mov	bx,0
		push	cx
		push	di
@@:		mov	al,[si+bx]
		stosb
		add	bx,4
		loop	@B
		pop	di
		pop	cx

		mov	al,0010b	;map 1
		out	dx,al
		mov	bx,1
		push	cx
		push	di
@@:		mov	al,[si+bx]
		stosb
		add	bx,4
		loop	@B
		pop	di
		pop	cx

		mov	al,0100b	;map 2
		out	dx,al
		mov	bx,2
		push	cx
		push	di
@@:		mov	al,[si+bx]
		stosb
		add	bx,4
		loop	@B
		pop	di
		pop	cx

		mov	al,1000b	;map 3
		out	dx,al
		mov	bx,3
		push	cx
		push	di
@@:		mov	al,[si+bx]
		stosb
		add	bx,4
		loop	@B
		pop	di
		pop	cx

		pop	ds

		ret

InterleaveData	ENDP

;----------------------------------------------------------------------------

;* RetrieveData - copy data from VGA screen page to WorkScreen[] and
;*                CopyScreen[] buffers combined.
;*
;* pass: dx = VGA page
;* ret : nothing
;* kill: assume all
;*       VGA_CTRL_RDMAP

RetrieveData	PROC	FAR

		push	ds
		push	es

		mov	ds,dx

		mov	ax,SEG WorkScreen
		mov	es,ax
		xor	di,di		;es:di -> start of WorkScreen

		SLCTREG	VGA_CTRL,VGA_CTRL_RDMAP

		mov	al,0		;map 0
		out	dx,al
		xor	si,si		;ds:si -> start of map
		mov	cx,320*200/4
		rep	movsb

		mov	al,1		;map 1
		out	dx,al
		xor	si,si		;ds:si -> start of map
		mov	cx,320*200/4
		rep	movsb

		mov	al,2		;map 2
		out	dx,al
		xor	si,si		;ds:si -> start of map
		mov	cx,320*200/4
		rep	movsb

		mov	al,3		;map 3
		out	dx,al
		xor	si,si		;ds:si -> start of map
		mov	cx,320*200/4
		rep	movsb

		pop	es
		pop	ds

		ret

RetrieveData	ENDP

;----------------------------------------------------------------------------

;* VGA_LoadPanel
;*
;* pass: nothing
;* ret : cf = 0 = no error
;*       cf = 1 = error
;* kill: assume all

VGA_LoadPanel	PROC	NEAR

		mov	bx,PanelMode

		mov	si,OFFSET VGA_Panel1

		cmp	bx,LOOKDOWN	;look down panel?
		jne	@F		;no ->

		mov	si,OFFSET VGA_Panel2

@@:		cmp	si,PanelRGBPtr	;current palette ok?
		je	@F		;yes, no need to change ->

		mov	PanelRGBPtr,si

		OVLYRGB	VGA_Panel,si,80

		mov	SetPaletteFlag,1

@@:		call	LoadPanel[bx]

		clc			;cf = 0 = no error

		ret

VGA_LoadPanel	ENDP

;----------------------------------------------------------------------------

;* LoadPilotPan
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all
;*       VGA_SEQ_MAPMSK

LoadPilotPan	PROC	NEAR

		push	ds
		push	es

		SETREGV	VGA_SEQ,VGA_SEQ_MAPMSK,1111b

		SLCTREG	VGA_CTRL,VGA_CTRL_MODE
		in	al,dx
		or	al,01b		;write mode 1
		out	dx,al

		mov	ax,WorkScrPtr
		mov	es,ax
		mov	di,PILOTPAN_SCR

		mov	ax,PILOTPAN_SEG
		mov	ds,ax
		mov	si,PILOTPAN_OFF

		mov	cx,PILOTPAN_SIZE/4

		rep	movsb
		
		in	al,dx
		and	al,NOT 11b	;write mode 0
		out	dx,al

		pop	es
		pop	ds

		ret

LoadPilotPan	ENDP

;----------------------------------------------------------------------------

;* LoadPSidePan
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all
;*       VGA_SEQ_MAPMSK

LoadPSidePan	PROC	NEAR

		push	ds
		push	es

		SETREGV	VGA_SEQ,VGA_SEQ_MAPMSK,1111b

		SLCTREG	VGA_CTRL,VGA_CTRL_MODE
		in	al,dx
		or	al,01b		;write mode 1
		out	dx,al

		mov	ax,WorkScrPtr
		mov	es,ax
		mov	di,PSIDEPAN_SCR

		mov	ax,PSIDEPAN_SEG
		mov	ds,ax
		mov	si,PSIDEPAN_OFF

		mov	cx,PSIDEPAN_SIZE/4

		rep	movsb
		
		in	al,dx
		and	al,NOT 11b	;write mode 0
		out	dx,al

		pop	es
		pop	ds

;* if night mode then redraw some panel detail

		cmp	Night,0		;night?
		je	@F		;no ->

		VIDBLIT	NAVIGPAN_SEG,128,57,16,177,32,10
		VIDBLIT	NAVIGPAN_SEG,160,57,272,177,32,10

		VIDBLIT	NAVIGPAN_SEG,176,67,80,165,8,12
		VIDBLIT	NAVIGPAN_SEG,184,67,240,165,8,12

		VIDBLIT	NAVIGPAN_SEG,128,67,0,187,24,11
		VIDBLIT	NAVIGPAN_SEG,152,67,296,187,24,11

@@:		ret

LoadPSidePan	ENDP

;----------------------------------------------------------------------------

;* LoadNavigPan
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all
;*       VGA_SEQ_MAPMSK

LoadNavigPan	PROC	NEAR

		push	ds
		push	es

		SETREGV	VGA_SEQ,VGA_SEQ_MAPMSK,1111b

		SLCTREG	VGA_CTRL,VGA_CTRL_MODE
		in	al,dx
		or	al,01b		;write mode 1
		out	dx,al

		mov	ax,WorkScrPtr
		mov	es,ax
		mov	di,NAVIGPAN_SCR

		mov	ax,NAVIGPAN_SEG
		mov	ds,ax
		mov	si,NAVIGPAN_OFF

		mov	cx,NAVIGPAN_SIZE/4

		rep	movsb
		
		in	al,dx
		and	al,NOT 11b	;write mode 0
		out	dx,al

		pop	es
		pop	ds

		ret

LoadNavigPan	ENDP

;----------------------------------------------------------------------------

;* LoadNSidePan
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all
;*       VGA_SEQ_MAPMSK

LoadNSidePan	PROC	NEAR

		push	ds
		push	es

		SETREGV	VGA_SEQ,VGA_SEQ_MAPMSK,1111b

		SLCTREG	VGA_CTRL,VGA_CTRL_MODE
		in	al,dx
		or	al,01b		;write mode 1
		out	dx,al

		mov	ax,WorkScrPtr
		mov	es,ax
		mov	di,NSIDEPAN_SCR

		mov	ax,NSIDEPAN_SEG
		mov	ds,ax
		mov	si,NSIDEPAN_OFF

		mov	cx,NSIDEPAN_SIZE/4

		rep	movsb
		
		in	al,dx
		and	al,NOT 11b	;write mode 0
		out	dx,al

		pop	es
		pop	ds

;* if night mode then redraw some panel detail

		cmp	Night,0		;night?
		je	@F		;no ->

		VIDBLIT	NAVIGPAN_SEG,128,78,16,165,8,12
		VIDBLIT	NAVIGPAN_SEG,136,78,304,165,8,12

@@:		ret

LoadNSidePan	ENDP

;----------------------------------------------------------------------------

;* LoadLookDownPan
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all
;*       VGA_SEQ_MAPMSK

LoadLookDownPan	PROC	NEAR

;* load left half look down panel

		QEXTRA	0,0,0,0,160,200

;* load right half look down panel (left half reflected)

		push	ds
		push	es

		SLCTREG	VGA_SEQ,VGA_SEQ_MAPMSK

		mov	ax,WorkScrPtr
		mov	es,ax

		mov	ax,SEG WorkScreen
		mov	ds,ax

		mov	si,(320*200/4)*0	;ds:si -> sprite data (map 0)
		mov	di,79			;es:di -> screen

		mov	al,1000b	;map 3
		out	dx,al
		mov	ax,200		;depth count
ReflectDLp1:	mov	cx,40		;width count
ReflectWLp1:	movsb
		sub	di,2
		loop	ReflectWLp1
		add	si,40		;next line
		add	di,40+80
		dec	ax
		jnz	ReflectDLp1

		mov	si,(320*200/4)*1	;ds:si -> sprite data (map 1)
		mov	di,79			;es:di -> screen

		mov	al,0100b	;map 2
		out	dx,al
		mov	ax,200		;depth count
ReflectDLp2:	mov	cx,40		;width count
ReflectWLp2:	movsb
		sub	di,2
		loop	ReflectWLp2
		add	si,40		;next line
		add	di,40+80
		dec	ax
		jnz	ReflectDLp2

		mov	si,(320*200/4)*2	;ds:si -> sprite data (map 2)
		mov	di,79			;es:di -> screen

		mov	al,0010b	;map 1
		out	dx,al
		mov	ax,200		;depth count
ReflectDLp3:	mov	cx,40		;width count
ReflectWLp3:	movsb
		sub	di,2
		loop	ReflectWLp3
		add	si,40		;next line
		add	di,40+80
		dec	ax
		jnz	ReflectDLp3

		mov	si,(320*200/4)*3	;ds:si -> sprite data (map 3)
		mov	di,79			;es:di -> screen

		mov	al,0001b	;map 0
		out	dx,al
		mov	ax,200		;depth count
ReflectDLp4:	mov	cx,40		;width count
ReflectWLp4:	movsb
		sub	di,2
		loop	ReflectWLp4
		add	si,40		;next line
		add	di,40+80
		dec	ax
		jnz	ReflectDLp4

		pop	es
		pop	ds

;* draw asymmetrical detail

		QEXTRA	8,49,160,0,48,77	;joystick

		QEXTRA	8,127,144,185,32,15	;strap

		ret

LoadLookDownPan	ENDP

;----------------------------------------------------------------------------

;* LoadMapPan
;*
;* pass: nothing
;* ret : nothing
;* kill: nothing

LoadMapPan	PROC	NEAR

		ret

LoadMapPan	ENDP

;----------------------------------------------------------------------------

;* REDRAW - redraw panel area
;*
;* pass: x     = x co-ord (multiples of 8 pixels (for EGA compatibility))
;*       y     = y co-ord
;*       width = width (multiples of 8 pixels (for EGA compatibility))
;*       depth = depth
;*       ds    = source vga page
;*       es    = dest vga page
;* ret : nothing
;* kill: assume all (execpt dx)

REDRAW		MACRO	x,y,width,depth

		mov	si,y*320/4+x/4	;source offset
		mov	di,si		;dest offset = source offset

		mov	bp,320/4-width/4;add on

		mov	bx,width/4
		mov	ax,depth

;* block copy

@@:		mov	cx,bx
		rep	movsb
		add	si,bp
		add	di,bp
		dec	ax
		jnz	@B

		ENDM

;----------------------------------------------------------------------------

;* VGA_ClrPilotPan - clear pilot's panel instruments
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all
;*       VGA_SEQ_MAPMSK

VGA_ClrPilotPan	PROC	NEAR

		push	ds
		push	es

		SETREGV	VGA_SEQ,VGA_SEQ_MAPMSK,1111b

		SLCTREG	VGA_CTRL,VGA_CTRL_MODE
		in	al,dx
		or	al,01b		;write mode 1
		out	dx,al

		mov	ax,WorkScrPtr
		mov	es,ax
		mov	ax,PILOTPAN_SEG
		mov	ds,ax

;-------------
;* redraw list
;-------------

		REDRAW	208, 143,  96,  19	;lh & rh eng rpm, fuel flow rate
		REDRAW	208, 171,  96,  19	;lh & rh eng temp, fuel quantity
		REDRAW	 32, 118,  32,  19	;radar altimeter
		REDRAW	  0, 144,  32,  19	;vertical speed indicator
		REDRAW	  0, 170,  32,  17	;secondary control surface position indicator
		REDRAW	 32, 144,  40,  23	;combined speed indicator
		REDRAW	 32, 174,  40,  23	;servo altimeter
		REDRAW	 72, 172,  40,  25	;horizontal situation indicator
		REDRAW	  8, 125,  24,  12	;landing gear position indicator
		REDRAW	304, 146,  16,   5	;standby compass
		REDRAW	272, 116,  32,  19	;accelerometer
		REDRAW	 48, 110,  16,   3	;auto-pilot and auto-throttle indicators
		REDRAW  216, 110,  48,  24	;radar warning receiver

		in	al,dx
		and	al,NOT 11b	;write mode 0
		out	dx,al

		pop	es
		pop	ds

		ret

VGA_ClrPilotPan	ENDP
 
;----------------------------------------------------------------------------

;* VGA_ClrNavigPan - clear navigator's panel instruments
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all
;*       VGA_SEQ_MAPMSK

VGA_ClrNavigPan	PROC	NEAR

		push	ds
		push	es

		SETREGV	VGA_SEQ,VGA_SEQ_MAPMSK,1111b

		SLCTREG	VGA_CTRL,VGA_CTRL_MODE
		in	al,dx
		or	al,01b		;write mode 1
		out	dx,al

		mov	ax,WorkScrPtr
		mov	es,ax
		mov	ax,NAVIGPAN_SEG
		mov	ds,ax

;-------------
;* redraw list
;-------------

		REDRAW	128,  14,  64,  23	;servo altimeter + combined speed indicator
		REDRAW	 64, 172,  40,  25	;horizontal situation indicator
		REDRAW	 40, 139,  24,  12	;landing gear position indicator
		REDRAW   24, 163,  32,  21	;clock
		REDRAW	208, 141,  96,  55	;warning panel

		in	al,dx
		and	al,NOT 11b	;write mode 0
		out	dx,al

		pop	es
		pop	ds

		ret

VGA_ClrNavigPan	ENDP

;----------------------------------------------------------------------------

;* VGA_DrwPilotPan - draw pilot's panel sprites
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

VGA_DrwPilotPan	PROC	NEAR

;-------------------
;* draw landing gear
;-------------------

		test	SSF_Gear,1	;damaged?
		jnz	@F		;yes ->

		cmp	GearTimer,0	;gear in motion?
		jne	RedGearLamps1	;yes ->

@@:		test	Gear,1		;gear lowered?
		jz	PilotGearOk	;no ->

		VIDBLIT	NAVIGPAN_SEG,80,31,8,132,24,5

		jmp	PilotGearOk

RedGearLamps1:	VIDBLIT	NAVIGPAN_SEG,80,26,8,125,24,5

;----------------
;* draw ADI bezel
;----------------

PilotGearOk:	MEXTRA	56,49,80,141,24,19

;-----------------------
;* draw wheelbrakes lamp
;-----------------------

		test	WheelBrakes,1	;applied?
		jz	@F		;no ->

		VIDBLIT	PILOTPAN_SEG,160,180,0,128,8,12

		jmp	WBrakesOk

@@:		VIDBLIT	PILOTPAN_SEG,0,128,0,128,8,12

;-----------------------
;* oxygen flow indicator
;-----------------------

WBrakesOk:	test	OxyDollyPos,1
		jz	@F

		VIDBLIT	PILOTPAN_SEG,144,181,312,168,8,3

		jmp	DollyOk

@@:		VIDBLIT	PILOTPAN_SEG,152,181,312,168,8,3

;----------------------
;* auto-pilot indicator
;----------------------

DollyOk:	cmp	AutoMode,AUTO_OFF	;auto-pilot engaged?
		je	@F			;no ->

		VIDBLIT	PILOTPAN_SEG,144,184,48,110,8,3

;-------------------------
;* auto-throttle indicator
;-------------------------

@@:		test	AutoThrot,1	;auto-throttle engaged?
		jz	@F		;no ->

		VIDBLIT	PILOTPAN_SEG,152,184,56,110,8,3

;--------------------
;* 'B' risk indicator (IDS / ECR)
;--------------------

@@:		cmp	TornadoType,ADV_TORNADO
		je	BRiskOk

		test	TFBRisk,1	;'B' risk warning?
		jz	@F		;no ->

		VIDBLIT	PILOTPAN_SEG,176,185,64,135,8,6

		jmp	BRiskOk

@@:		VIDBLIT	PILOTPAN_SEG,64,135,64,135,8,6

;-------------------
;* reheat indicators
;-------------------

;* engine 1 (lhs)

BRiskOk:	cmp	Reheat,0	;reheat on?
		je	@F		;no ->

		test	SSF_Engine1,1	;engine ok?
		jnz	@F		;no ->

		cmp	FuelWt,0	;any fuel?
		je	@F		;no ->

		VIDBLIT	PILOTPAN_SEG,144,175,288,108,16,6

		jmp	Eng1Ok

@@:		VIDBLIT	PILOTPAN_SEG,288,108,288,108,16,6

;* engine 2 (rhs)

Eng1Ok:		cmp	Reheat,0	;reheat on?
		je	@F		;no ->

		test	SSF_Engine2,1	;engine ok?
		jnz	@F		;no ->

		cmp	FuelWt,0	;any fuel?
		je	@F		;no ->

		VIDBLIT	PILOTPAN_SEG,168,180,304,112,8,6

		jmp	Eng2Ok

@@:		VIDBLIT	PILOTPAN_SEG,304,112,304,112,8,6

;---------------------
;* draw jettison lamps
;---------------------

Eng2Ok:		mov	al,Jettison

		cmp	al,JET_NULL
		je	JettisonOk

		cmp	al,JET_EXT_TANKS
		jne	@F

		VIDBLIT	PILOTPAN_SEG,144,160,0,193,32,5

		jmp	JettisonOk

@@:		cmp	al,JET_EXT_STORES
		jne	@F

		VIDBLIT	PILOTPAN_SEG,144,165,0,193,32,5

		jmp	JettisonOk

@@:		VIDBLIT	PILOTPAN_SEG,144,170,0,193,32,5

;----------------------------------
;* draw thrust reversers indicators
;----------------------------------

JettisonOk:	test	ThrustRvrs,1	;applied?
		jz	@F		;no ->

		VIDBLIT	PILOTPAN_SEG,144,151,0,109,32,9

		jmp	RvrsOk

@@:		VIDBLIT	PILOTPAN_SEG,0,109,0,109,32,9

;----------------------------------
;* draw approach progress indicator
;----------------------------------

RvrsOk:		test	AppProgFlag,1	;in fan marker?
		jz	@F		;no ->

		test	AppProgSeq,01b	;lamp on?
		jnz	@F		;no ->

		VIDBLIT	PILOTPAN_SEG,160,175,272,103,16,5

		jmp	AppProgOk

@@:		VIDBLIT	PILOTPAN_SEG,272,103,272,103,16,5

;------------------------
;* draw attention getters
;------------------------

AppProgOk:	test	Attention,1	;get attention?
	  	jz	@F		;no ->

	  	VIDBLIT	PILOTPAN_SEG,128,144,48,97,32,7
	  	VIDBLIT	PILOTPAN_SEG,160,144,240,97,32,7

	  	jmp	PilotAttnOk

@@:	  	VIDBLIT	PILOTPAN_SEG,48,97,48,97,32,7
		VIDBLIT	PILOTPAN_SEG,240,97,240,97,32,7

;----------------------------
;* draw MFD mouse active lamp
;----------------------------

PilotAttnOk:	mov	si,OFFSET PILOT_MFD

;* check MFD on, not damaged, display requires mouse and display has mouse

		mov	al,MFD_STATUS[si]
		and	al,MFD_REQ_MOUSE[si]
		and	al,MFD_HAS_MOUSE[si]

		mov	si,MFD_SSF_PTR[si]
		mov	ah,[si]
		not	ah	    	;0ffh = ok, 0feh = damaged

		and	al,ah

		jz	@F		;off ->

	  	VIDBLIT	PILOTPAN_SEG,128,165,112,193,16,7

		jmp	PilotMFDOk

@@:	  	VIDBLIT	PILOTPAN_SEG,112,193,112,193,16,7

;-------------------------
;* draw late arming switch
;-------------------------

PilotMFDOk:	cmp	Night,0		;night?
		jne	NightLateArm	;yes ->

		mov	al,LateArmAnim

		cmp	al,0
		jne	@F

	  	VIDBLIT	NAVIGPAN_SEG,128,94,112,96,8,11

		jmp	LateArmOk

@@:		cmp	al,3
		jne	@F

	  	VIDBLIT	NAVIGPAN_SEG,152,94,112,96,8,11
		MEXTRA	80,49,112,88,8,8

		jmp	LateArmOk

@@:	  	VIDBLIT	NAVIGPAN_SEG,144,94,112,96,8,11
		MEXTRA	80,49,112,88,8,8

		jmp	LateArmOk

NightLateArm:	mov	al,LateArmAnim

		cmp	al,0
		jne	@F

	  	VIDBLIT	NAVIGPAN_SEG,160,94,112,96,8,11

		jmp	LateArmOk

@@:		cmp	al,3
		jne	@F

	  	VIDBLIT	NAVIGPAN_SEG,184,94,112,96,8,11
		MEXTRA	80,57,112,88,8,8

		jmp	LateArmOk

@@:	  	VIDBLIT	NAVIGPAN_SEG,176,94,112,96,8,11
		MEXTRA	80,57,112,88,8,8

;-----------------
;* draw radar lamp
;-----------------

LateArmOk:	cmp	RadarMode,NUL_RADAR	;radar on?
		je	@F			;no ->

		VIDBLIT	PILOTPAN_SEG,128,187,216,99,8,5

		jmp	PilotRadarOk

@@:		VIDBLIT	PILOTPAN_SEG,216,99,216,99,8,5

;---------------
;* draw ECM lamp
;---------------

PilotRadarOk:	test	ECMActive,1 	;ECM on?
		jz	@F	    	;no ->

		VIDBLIT	PILOTPAN_SEG,136,187,224,99,16,5

		jmp	PilotECMOk

@@:		VIDBLIT	PILOTPAN_SEG,224,99,224,99,16,5

;---------------------------
;* ADV weapon status display
;---------------------------

PilotECMOk:	cmp	TornadoType,ADV_TORNADO
		_JNE	WpnStatusOk

;* update blink timer

		mov	ax,ArmBlinkTimer
		sub	ax,LastFrame
		jnc	@F

		xor	ArmBlink,1	;toggle blink state

		mov	ax,ARM_BLINK_TIME

@@:		mov	ArmBlinkTimer,ax

;* clear panel

		VIDBLIT	NAVIGPAN_SEG,152,165,80,112,24,16

;* blink if weapon armed

		mov	ax,AirArmMode

		cmp	ax,ArmMode
		jne	@F

		test	ArmBlink,1
		jz	WpnStatusOk

;* cannon

@@:		cmp	ax,ARM_CANNON
		jne	@F

		VIDBLIT	NAVIGPAN_SEG,144,78,80,112,24,4

		jmp	WpnStatusOk

;* Sidewinder

@@:		cmp	ax,ARM_SIDEWINDER
		jne	@F

		VIDBLIT	NAVIGPAN_SEG,144,82,80,118,24,4

		jmp	WpnStatusOk

;* Sky Flash

@@:		cmp	ax,ARM_SKYFLASH
		jne	WpnStatusOk

		VIDBLIT	NAVIGPAN_SEG,144,86,80,124,24,4

;------------------------
;* radar warning receiver
;------------------------

WpnStatusOk:	test	SSF_RWR,1	;damaged?
		_JNZ	RWROk		;yes ->

		test	RWRThreatFlags,RWR_SAM
		jz	@F

		VIDBLIT	NAVIGPAN_SEG,16,74,248,110,16,4

@@:		test	RWRThreatFlags,RWR_AAA
		jz	@F

		VIDBLIT	NAVIGPAN_SEG,16,79,248,115,16,4

@@:		test	RWRThreatFlags,RWR_EWR
		jz	@F

		VIDBLIT	NAVIGPAN_SEG,16,84,248,120,16,4

@@:		test	RWRThreatFlags,RWR_AC
		jz	@F

		VIDBLIT	NAVIGPAN_SEG,16,89,248,125,16,4

@@:		test	RWRThreatFlags,RWR_MSL
		jz	RWROk

		VIDBLIT	NAVIGPAN_SEG,16,94,248,130,16,4

RWROk:		ret

VGA_DrwPilotPan	ENDP

;----------------------------------------------------------------------------

;* VGA_DrwNavigPan - draw navigator's panel sprites
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

VGA_DrwNavigPan	PROC	NEAR

;-------------------
;* draw landing gear
;-------------------

		test	SSF_Gear,1	;damaged?
		jnz	@F		;yes ->

		cmp	GearTimer,0	;gear in motion?
		jne	RedGearLamps2	;yes ->

@@:		test	Gear,1		;gear lowered?
		jz	NavigGearOk	;no ->

		VIDBLIT	NAVIGPAN_SEG,80,41,40,146,24,5

		jmp	NavigGearOk

RedGearLamps2:	VIDBLIT	NAVIGPAN_SEG,80,36,40,139,24,5

;----------------
;* draw ADI bezel
;----------------

NavigGearOk:	MEXTRA	56,49,72,141,24,19

;----------------------
;* auto-pilot indicator
;----------------------

		cmp	AutoMode,AUTO_OFF	;auto-pilot engaged?
		je	@F			;no ->

		VIDBLIT	PILOTPAN_SEG,128,182,124,130,8,5

		jmp	NavigAutoOk

@@:		VIDBLIT	NAVIGPAN_SEG,124,130,124,130,8,5

;-------------------------
;* auto-throttle indicator
;-------------------------

NavigAutoOk:	test	AutoThrot,1	;auto-throttle engaged?
		jz	@F		;no ->

		VIDBLIT	PILOTPAN_SEG,128,172,132,130,16,5

		jmp	NavigThrotOk

@@:		VIDBLIT	NAVIGPAN_SEG,132,130,132,130,16,5

;------------------------
;* draw attention getters
;------------------------

NavigThrotOk:	test	Attention,1	;get attention?
	  	jz	@F		;no ->

	  	VIDBLIT	PILOTPAN_SEG,176,151,0,103,16,17
	  	VIDBLIT	PILOTPAN_SEG,176,168,304,103,16,17

	  	jmp	NavigAttnOk

@@:	  	VIDBLIT	NAVIGPAN_SEG,0,103,0,103,16,17
	  	VIDBLIT	NAVIGPAN_SEG,304,103,304,103,16,17

;---------------
;* warning panel
;---------------

;* red captions

NavigAttnOk:	mov	ax,RedWarnings1
		test	Attention,1	;flash new failures?
		jz	@F		;no ->
		or	ax,RedWarnings2

@@:		mov	Failures,ax

		test	Failures,RED_OXY
		jz	@F
	  	VIDBLIT	NAVIGPAN_SEG,208+(3*16),26+(0*8),208+(3*16),141+(0*8),16,7

@@:		test	Failures,RED_L_FIRE
		jz	@F
	  	VIDBLIT	NAVIGPAN_SEG,208+(0*16),26+(1*8),208+(0*16),141+(1*8),16,7

@@:		test	Failures,RED_R_FIRE
		jz	@F
	  	VIDBLIT	NAVIGPAN_SEG,208+(5*16),26+(1*8),208+(5*16),141+(1*8),16,7

@@:		test	Failures,RED_AUT
		jz	@F
	  	VIDBLIT	NAVIGPAN_SEG,208+(3*16),26+(1*8),208+(3*16),141+(1*8),16,7

@@:		test	Failures,RED_REV
		jz	@F
	  	VIDBLIT	NAVIGPAN_SEG,208+(1*16),26+(0*8),208+(1*16),141+(0*8),16,7

@@:		test	Failures,RED_SPILS
		jz	@F
	  	VIDBLIT	NAVIGPAN_SEG,208+(1*16),26+(2*8),208+(1*16),141+(2*8),16,7

@@:		test	Failures,RED_UC
		jz	@F
	  	VIDBLIT	NAVIGPAN_SEG,208+(2*16),26+(2*8),208+(2*16),141+(2*8),16,7

@@:		test	Failures,RED_FUEL
		jz	@F
	  	VIDBLIT	NAVIGPAN_SEG,208+(3*16),26+(2*8),208+(3*16),141+(2*8),16,7

@@:		test	Failures,RED_L_ENG
		jz	@F
	  	VIDBLIT	NAVIGPAN_SEG,208+(0*16),26+(2*8),208+(0*16),141+(2*8),16,7

@@:		test	Failures,RED_R_ENG
		jz	@F
	  	VIDBLIT	NAVIGPAN_SEG,208+(5*16),26+(2*8),208+(5*16),141+(2*8),16,7

;* amber captions

@@:		mov	ax,AmbWarnings1
		test	Attention,1	;flash new failures?
		jz	@F		;no ->
		or	ax,AmbWarnings2

@@:		mov	Failures,ax

		test	Failures,AMB_CNFG
		jz	@F
	  	VIDBLIT	NAVIGPAN_SEG,208+(4*16),26+(3*8),208+(4*16),141+(3*8),16,7

@@:		test	Failures,AMB_ADC
		jz	@F
	  	VIDBLIT	NAVIGPAN_SEG,208+(0*16),26+(6*8),208+(0*16),141+(6*8),16,7

@@:		test	Failures,AMB_ECM
		jz	@F
	  	VIDBLIT	NAVIGPAN_SEG,208+(0*16),26+(4*8),208+(0*16),141+(4*8),16,7

@@:		test	Failures,AMB_UC
		jz	@F
	  	VIDBLIT	NAVIGPAN_SEG,208+(2*16),26+(4*8),208+(2*16),141+(4*8),16,7

@@:		test	Failures,AMB_WB
		jz	@F
	  	VIDBLIT	NAVIGPAN_SEG,208+(3*16),26+(5*8),208+(3*16),141+(5*8),16,7

@@:		test	Failures,AMB_AB
		jz	@F
	  	VIDBLIT	NAVIGPAN_SEG,208+(5*16),26+(4*8),208+(5*16),141+(4*8),16,7

@@:		test	Failures,AMB_FLPS
		jz	@F
	  	VIDBLIT	NAVIGPAN_SEG,208+(2*16),26+(6*8),208+(2*16),141+(6*8),16,7

@@:		test	Failures,AMB_SWP
		jz	@F
	  	VIDBLIT	NAVIGPAN_SEG,208+(2*16),26+(5*8),208+(2*16),141+(5*8),16,7

@@:		test	Failures,AMB_HUD
		jz	@F
	  	VIDBLIT	NAVIGPAN_SEG,208+(4*16),26+(6*8),208+(4*16),141+(6*8),16,7

@@:		test	Failures,AMB_MFD1
		jz	@F
	  	VIDBLIT	NAVIGPAN_SEG,208+(0*16),26+(3*8),208+(0*16),141+(3*8),16,7

@@:		test	Failures,AMB_MFD2
		jz	@F
	  	VIDBLIT	NAVIGPAN_SEG,208+(5*16),26+(3*8),208+(5*16),141+(3*8),16,7

@@:		test	Failures,AMB_L_TAB
		jz	@F
	  	VIDBLIT	NAVIGPAN_SEG,208+(0*16),26+(5*8),208+(0*16),141+(5*8),16,7

@@:		test	Failures,AMB_R_TAB
		jz	@F
	  	VIDBLIT	NAVIGPAN_SEG,208+(5*16),26+(5*8),208+(5*16),141+(5*8),16,7

@@:		test	Failures,AMB_RAD
		jz	@F
	  	VIDBLIT	NAVIGPAN_SEG,208+(3*16),26+(3*8),208+(3*16),141+(3*8),16,7

@@:		test	Failures,AMB_RWR
		jz	@F
	  	VIDBLIT	NAVIGPAN_SEG,208+(1*16),26+(4*8),208+(1*16),141+(4*8),16,7

;----------------------------
;* draw MFD mouse active lamp
;----------------------------

@@:		mov	si,OFFSET NAVIG_MFD

;* check MFD on, not damaged, display requires mouse and display has mouse

		mov	al,MFD_STATUS[si]
		and	al,MFD_REQ_MOUSE[si]
		and	al,MFD_HAS_MOUSE[si]

		mov	si,MFD_SSF_PTR[si]
		mov	ah,[si]
		not	ah	    	;0ffh = ok, 0feh = damaged

		and	al,ah

		jz	@F		;off ->

	  	VIDBLIT	PILOTPAN_SEG,128,151,112,106,16,7

		jmp	NavigMFDOk

@@:	  	VIDBLIT	NAVIGPAN_SEG,112,106,112,106,16,7

;----------------------------------
;* draw TAB1 (lh) mouse active lamp
;----------------------------------

NavigMFDOk:	mov	si,OFFSET TAB1

;* check TAB on, not damaged, display requires mouse and display has mouse

		mov	al,TAB_STATUS[si]
		and	al,TAB_REQ_MOUSE[si]
		and	al,TAB_HAS_MOUSE[si]

		mov	si,TAB_SSF_PTR[si]
		mov	ah,[si]
		not	ah	    	;0ffh = ok, 0feh = damaged

		and	al,ah

		jz	@F		;off ->

	  	VIDBLIT	PILOTPAN_SEG,184,185,32,115,8,7

		jmp	NavigTAB1Ok

@@:	  	VIDBLIT	NAVIGPAN_SEG,32,115,32,115,8,7

;----------------------------------
;* draw TAB2 (rh) mouse active lamp
;----------------------------------

NavigTAB1Ok:	mov	si,OFFSET TAB2

;* check TAB on, not damaged, display requires mouse and display has mouse

		mov	al,TAB_STATUS[si]
		and	al,TAB_REQ_MOUSE[si]
		and	al,TAB_HAS_MOUSE[si]

		mov	si,TAB_SSF_PTR[si]
		mov	ah,[si]
		not	ah	    	;0ffh = ok, 0feh = damaged

		and	al,ah

		jz	@F		;off ->

	  	VIDBLIT	PILOTPAN_SEG,128,158,224,115,16,7

		jmp	NavigTAB2Ok

@@:	  	VIDBLIT	NAVIGPAN_SEG,224,115,224,115,16,7

;-----------------
;* draw radar lamp
;-----------------

NavigTAB2Ok:	cmp	RadarMode,NUL_RADAR	;radar on?
		je	@F			;no ->

		VIDBLIT	PILOTPAN_SEG,136,182,176,130,8,5

		jmp	NavigRadarOk

@@:		VIDBLIT	NAVIGPAN_SEG,176,130,176,130,8,5

;---------------
;* draw ECM lamp
;---------------

NavigRadarOk:	test	ECMActive,1 	;ECM on?
		jz	@F	    	;no ->

		VIDBLIT	PILOTPAN_SEG,128,177,184,130,16,5

		jmp	NavigECMOk

@@:		VIDBLIT	NAVIGPAN_SEG,184,130,184,130,16,5

NavigECMOk:	ret

VGA_DrwNavigPan	ENDP

;----------------------------------------------------------------------------

;* VGA_IronWork - draw ironwork panel
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

VGA_IronWork	PROC	NEAR

;* draw large solid ironwork section

		push	ds
		push	es

		SETREGV	VGA_SEQ,VGA_SEQ_MAPMSK,1111b

		SLCTREG	VGA_CTRL,VGA_CTRL_MODE
		in	al,dx
		or	al,01b		;write mode 1
		out	dx,al

		mov	ax,WorkScrPtr
		mov	es,ax
		mov	di,FRAMEPAN_SCR

		mov	ax,FRAMEPAN_SEG
		mov	ds,ax
		mov	si,FRAMEPAN_OFF

		mov	cx,FRAMEPAN_SIZE/4

		rep	movsb
		
		in	al,dx
		and	al,NOT 11b	;write mode 0
		out	dx,al

		pop	es
		pop	ds

;* lhs ironwork

		MEXTRA	160, 14,  0,112, 40, 10
		MEXTRA	200,  7, 40,105, 40,  7
		MEXTRA	240,  0, 80, 98, 80,  6
		MEXTRA	160,  0,  0,156, 24, 10
		MEXTRA	256,171, 32,156, 32,  6
		MEXTRA	272,177, 48,162, 16, 20
		MEXTRA	312,171, 88,156,  8, 26
		MEXTRA	160,171, 56,182,  8, 10
		MEXTRA	192,171, 88,182, 24, 10
		MEXTRA	224,171, 96,174, 24,  7

		QEXTRA	200, 14, 40,112, 40, 10
		QEXTRA	240,  6, 80,104, 80, 18
		QEXTRA	160, 48,  0,138,160, 18
		QEXTRA	288,171, 64,156, 24, 26
		QEXTRA	168,171, 64,182, 24, 10

;* rhs ironwork

		MEXTRA	280, 38,280,112, 40, 10
		MEXTRA	240, 30,240,104, 40,  8
		MEXTRA	160, 24,160, 98, 80,  6
		MEXTRA	296, 24,296,156, 24, 10
		MEXTRA	288,144,256,156, 32,  6
		MEXTRA	288,150,256,162, 16, 20
		MEXTRA	256,144,224,156,  8, 26
		MEXTRA	208,182,256,182,  8, 10
		MEXTRA	160,182,208,182, 24, 10
		MEXTRA	224,179,200,174, 24,  7

		QEXTRA	240, 38,240,112, 40, 10
		QEXTRA	160, 30,160,104, 80, 18
		QEXTRA	160, 66,160,138,160, 18
		QEXTRA	264,144,232,156, 24, 26
		QEXTRA	184,182,232,182, 24, 10

;* reflector / central ironwork

		QEXTRA	160,193,120,174, 80,  2
		QEXTRA	160,196,112,183, 96,  2
		QEXTRA	160,199, 96,156,128,  1

		ret

VGA_IronWork	ENDP

;----------------------------------------------------------------------------

;* VGA_Brackets - draw HUD brackets
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

VGA_Brackets	PROC	NEAR

;* lhs bracket

		MEXTRA	160, 84, 56, 10, 16, 11
		MEXTRA	168, 95, 64, 21,  8, 75
		MEXTRA	200, 84, 96, 10,  8, 63
		MEXTRA	200,147, 96, 73, 16, 23
		MEXTRA	160,171, 56,  0,  8, 10
		MEXTRA	192,171, 88,  0, 24, 10		
		QEXTRA	176, 84, 72, 10, 24, 86
		QEXTRA	168,171, 64,  0, 24, 10
		
;* rhs bracket

		MEXTRA	224, 84,216, 10,  8, 63
		MEXTRA	216,147,208, 73, 16, 23
		MEXTRA	256, 84,248, 10, 16, 36
		MEXTRA	248,120,240, 46,  8, 50
		MEXTRA	160,182,208,  0, 24, 10
		MEXTRA	208,182,256,  0,  8, 10
		QEXTRA	248, 84,240, 10,  8, 36
		QEXTRA	232, 84,224, 10, 16, 86
		QEXTRA	184,182,232,  0, 24, 10

;* reflector

		QEXTRA	160,196,112,  1, 96,  2

		ret

VGA_Brackets	ENDP

;----------------------------------------------------------------------------

;* QExtraSprite - quick "extra" panel sprite
;*
;* pass: si -> source address (4 pixel boundary)
;*       di -> dest address (4 pixel boundary)
;*       bl = width (pixels / 4)
;*       bh = depth (pixels)
;*       bp = add on (80 - width / 4)
;* ret : nothing
;* kill: assume all
;*       VGA_SEQ_MAPMSK

QExtraSprite	PROC	NEAR

		push	ds
		push	es

		SLCTREG	VGA_SEQ,VGA_SEQ_MAPMSK

		mov	ax,WorkScrPtr
		mov	es,ax

		mov	ax,SEG WorkScreen
		mov	ds,ax

		xor	ch,ch		;reset counter high byte

		mov	al,0001b	;map 0
		out	dx,al
		mov	ah,bh		;depth count
		push	si
		push	di
@@:		mov	cl,bl		;width count
		rep	movsb
		add	si,bp		;next line
		add	di,bp
		dec	ah
		jnz	@B
		pop	di
		pop	si
		add	si,320*200/4	;next map

		mov	al,0010b	;map 1
		out	dx,al
		mov	ah,bh		;depth count
		push	si
		push	di
@@:		mov	cl,bl		;width count
		rep	movsb
		add	si,bp		;next line
		add	di,bp
		dec	ah
		jnz	@B
		pop	di
		pop	si
		add	si,320*200/4	;next map

		mov	al,0100b	;map 2
		out	dx,al
		mov	ah,bh		;depth count
		push	si
		push	di
@@:		mov	cl,bl		;width count
		rep	movsb
		add	si,bp		;next line
		add	di,bp
		dec	ah
		jnz	@B
		pop	di
		pop	si
		add	si,320*200/4	;next map

		mov	al,1000b	;map 3
		out	dx,al
		mov	ah,bh		;depth count
@@:		mov	cl,bl		;width count
		rep	movsb
		add	si,bp		;next line
		add	di,bp
		dec	ah
		jnz	@B

		pop	es
		pop	ds		
				
		ret

QExtraSprite	ENDP

;----------------------------------------------------------------------------

;* MExtraSprite - masked "extra" panel sprite
;*
;* pass: si -> source address (4 pixel boundary)
;*       di -> dest address (4 pixel boundary)
;*       bl = width (pixels / 4)
;*       bh = depth (pixels)
;*       bp = add on (80 - width / 4)
;* ret : nothing
;* kill: assume all
;*       VGA_SEQ_MAPMSK
;*
;* note: Mask colour is assumed to be colour 0.

MExtraSprite	PROC	NEAR

		push	ds
		push	es

		SLCTREG	VGA_SEQ,VGA_SEQ_MAPMSK

		mov	ax,WorkScrPtr
		mov	es,ax

		mov	ax,SEG WorkScreen
		mov	ds,ax

		xor	ch,ch		;reset counter high byte

		mov	al,0001b	;map 0
		out	dx,al
		mov	ah,bh		;depth count
		push	si
		push	di
MxLp1_1:	mov	cl,bl		;width count
MxLp1_2:	lodsb
		test	al,al		;mask colour
		jz	@F		;yes ->
		mov	es:[di],al
@@:		inc	di
		loop	MxLp1_2
		add	si,bp		;next line
		add	di,bp
		dec	ah
		jnz	MxLp1_1
		pop	di
		pop	si
		add	si,320*200/4	;next map

		mov	al,0010b	;map 1
		out	dx,al
		mov	ah,bh		;depth count
		push	si
		push	di
MxLp2_1:	mov	cl,bl		;width count
MxLp2_2:	lodsb
		test	al,al		;mask colour
		jz	@F		;yes ->
		mov	es:[di],al
@@:		inc	di
		loop	MxLp2_2
		add	si,bp		;next line
		add	di,bp
		dec	ah
		jnz	MxLp2_1
		pop	di
		pop	si
		add	si,320*200/4	;next map

		mov	al,0100b	;map 2
		out	dx,al
		mov	ah,bh		;depth count
		push	si
		push	di
MxLp3_1:	mov	cl,bl		;width count
MxLp3_2:	lodsb
		test	al,al		;mask colour
		jz	@F		;yes ->
		mov	es:[di],al
@@:		inc	di
		loop	MxLp3_2
		add	si,bp		;next line
		add	di,bp
		dec	ah
		jnz	MxLp3_1
		pop	di
		pop	si
		add	si,320*200/4	;next map

		mov	al,1000b	;map 3
		out	dx,al
		mov	ah,bh		;depth count
MxLp4_1:	mov	cl,bl		;width count
MxLp4_2:	lodsb
		test	al,al		;mask colour
		jz	@F		;yes ->
		mov	es:[di],al
@@:		inc	di
		loop	MxLp4_2
		add	si,bp		;next line
		add	di,bp
		dec	ah
		jnz	MxLp4_1

		pop	es
		pop	ds		
				
		ret

MExtraSprite	ENDP

;----------------------------------------------------------------------------

;* VideoBlitter - video memory to video memory block image transfer
;*
;* pass: dx = source video page
;*       si -> source address (4 pixel boundary)
;*       di -> dest address (4 pixel boundary)
;*       bl = width (pixels / 4)
;*       bh = depth (pixels)
;*       bp = add on (80 - width / 4)
;* ret : nothing
;* kill: assume all
;*       VGA_SEQ_MAPMSK

VideoBlitter	PROC	NEAR

		push	ds
		push	es

		mov	ax,WorkScrPtr
		mov	es,ax
		mov	ds,dx

		SETREGV	VGA_SEQ,VGA_SEQ_MAPMSK,1111b

		SLCTREG	VGA_CTRL,VGA_CTRL_MODE
		in	al,dx
		or	al,01b		;write mode 1
		out	dx,al

		xor	ch,ch		;reset counter high byte

@@:		mov	cl,bl
		rep	movsb
		add	si,bp
		add	di,bp
		dec	bh
		jnz	@B

		in	al,dx
		and	al,NOT 11b	;write mode 0
		out	dx,al

		pop	es
		pop	ds

		ret

VideoBlitter	ENDP

;----------------------------------------------------------------------------

;* DrawRadarNoise - draw air radar background noise
;*
;* pass: CrewMode
;* ret : nothing
;* kill: assume all
;*
;* note: Only implemented for VGA display.

DrawRadarNoise	PROC	NEAR

		cmp	CrewMode,CREW_PILOT	;pilot?
		jne	@F			;no, nav ->

		VIDBLIT	NAVIGPAN_SEG,16,26,128,144,64,48

		ret

@@:		VIDBLIT	NAVIGPAN_SEG,16,26,128,57,64,48

		ret

DrawRadarNoise	ENDP

;----------------------------------------------------------------------------

;* CopyPreviewPan - copy preview mode panel
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all
;*
;* note: Only implemented for VGA display.

CopyPreviewPan	PROC	FAR

		VIDBLIT	VGA_PAGE_3,0,0,0,160,320,40

		ret

CopyPreviewPan	ENDP

;----------------------------------------------------------------------------

;* DrawPreviewPan - draw preview mode panel
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all
;*
;* note: Only implemented for VGA display.

DrawPreviewPan	PROC	FAR

		VIDBLIT	VGA_PAGE_3,0,160,0,160,320,40

		ret

DrawPreviewPan	ENDP

;----------------------------------------------------------------------------

;* StoreWorkScreen - store WorkScreen in VGA page
;*
;* pass: dx = VGA page
;* ret : nothing
;* kill: assume all
;*       VGA_SEQ_MAPMSK
;*
;* note: Only implemented for VGA display.
;*
;*       Data can be restored with RetrieveData routine.

StoreWorkScreen	PROC	FAR

		push	ds
		push	es

		mov	ax,SEG WorkScreen
		mov	ds,ax
		xor	si,si		;ds:si -> start of WorkScreen

		mov	es,dx

		SLCTREG	VGA_SEQ,VGA_SEQ_MAPMSK

		mov	al,0001b	;map 0
		out	dx,al
		mov	cx,(320*200)/4
		xor	di,di
		rep	movsb

		mov	al,0010b	;map 1
		out	dx,al
		mov	cx,(320*200)/4
		xor	di,di
		rep	movsb

		mov	al,0100b	;map 2
		out	dx,al
		mov	cx,(320*200)/4
		xor	di,di
		rep	movsb

		mov	al,1000b	;map 3
		out	dx,al
		mov	cx,(320*200)/4
		xor	di,di
		rep	movsb

		pop	es
		pop	ds

		ret

StoreWorkScreen	ENDP

PANCODE		ENDS

;============================================================================

		END

