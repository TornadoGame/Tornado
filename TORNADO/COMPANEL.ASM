;****************************************************************************
;*
;* COMPANEL.ASM
;*
;* Common panel disk load / download / update routines.
;*
;* 09.08.1991 - KJB
;* 18.01.1992 - KJB - LOOKDOWN and LOOKUP panels added.
;* 02.04.1992 - MAPPAN added.
;* 12.06.1992 - DrawPilotPanel / DrawNavigPanel added.
;*
;* The panel types are as follows:-
;*
;*    1) pilot's front panel
;*    2) pilot's left and right side panel
;*    3) navigator's front panel
;*    4) navigator's left and right side panel
;*    5) external panel (no graphics required)
;*    6) look down panel (pilot's kneepads)
;*    7) look up (canopy frame)
;*
;* It is not practical to store all of the panel data in the system memory as
;* too much memory is required. Therefore the panel data is stored in binary
;* data files on disk. This is a nuisance when switching views as the program
;* freezes momentarily when loading panel data (especially from floppy disk).
;*
;* The panel data is not compressed so that it can be loaded directly into
;* the work screen.
;*
;* The EGA / VGA cards can take advantage of their extra video memory by
;* loading the panel data into spare screen pages at the start of the program,
;* then simply copying the data from video memory to video memory when
;* required. There should be no noticeable delay using this method.
;*
;* Panel sizes:-
;*
;*    1) PILOTPAN - 320 * 104, y start co-ord = 96
;*    2) PSIDEPAN - 320 *  40, y start co-ord = 160
;*    3) NAVIGPAN - 320 * 200, y start co-ord = 0
;*    4) NSIDEPAN - 320 *  40, y start co-ord = 160
;*    5) EXTRNPAN - 320 *   8, y start co-ord = 192
;*    6) LOOKDOWN - ** see note
;*    7) LOOKUP   - ** see note
;* 
;*    ** LOOKDOWN and LOOKUP are combined into one picture file (EXTRAPAN).
;*
;*       This picture comprises half the "look down" panel (a single leg and
;*       knee pad which can be reflected to make the complete panel) and the
;*       canopy frame components required for the pilot's panel and "look up"
;*       panel.
;*       
;*       This data should be stored wherever it suits the particular graphics
;*       mode, but making use of any unused memory:-
;*
;*          VGA - store in WorkScreen[] and CopyScreen[] buffers combined
;*          EGA - TBA
;*          TAN - TBA
;*          CGA - TBA
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	SetPanelMode
		PUBLIC	InitPanels
		PUBLIC	LoadPanel
		PUBLIC	ClearPilotPanel
		PUBLIC	ClearNavigPanel
		PUBLIC	DrawPilotPanel
		PUBLIC	DrawNavigPanel
		PUBLIC	DrawIronWork
		PUBLIC	DrawBrackets
		PUBLIC	UpdatePanel

		PUBLIC	PilotPanel
		PUBLIC	PSidePanel
		PUBLIC	NavigPanel
		PUBLIC	NSidePanel
		PUBLIC	FramePanel
		PUBLIC	ExtraPanel

		PUBLIC	PanelLoad

		EXTRN	UpdatePilot:NEAR
		EXTRN	UpdateNavig:NEAR
		EXTRN	UpdateExtrn:NEAR
		EXTRN	UpdateLookDown:NEAR
		EXTRN	UpdateFrame:NEAR

		EXTRN	VGA_InitPanels:NEAR

		EXTRN	VGA_LoadPanel:NEAR

		EXTRN	VGA_ClrPilotPan:NEAR

		EXTRN	VGA_ClrNavigPan:NEAR

		EXTRN	VGA_DrwPilotPan:NEAR

		EXTRN	VGA_DrwNavigPan:NEAR

		EXTRN	VGA_IronWork:NEAR

		EXTRN	VGA_Brackets:NEAR

		EXTRN	PanelMode:WORD
		EXTRN	ScreenMode:WORD

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

;------------------
;* panel file names (VGA filenames only)
;------------------

PilotPanel	DB	"PILOTPAN.BT2",0
PSidePanel	DB	"PSIDEPAN.BT2",0
NavigPanel	DB	"NAVIGPAN.BT2",0
NSidePanel	DB	"NSIDEPAN.BT2",0
FramePanel	DB	"FRAMEPAN.BT2",0
ExtraPanel	DB	"EXTRAPAN.BT2",0

		EVEN

;--------------------------
;* initialize panels switch (wrt ScreenMode)
;--------------------------

_InitPanels	DW	Null		;HGC
		DW	Null		;HEM
		DW	Null		;CGA
		DW	Null		;EGA
		DW	Null		;TAN
		DW	Null		;TEM
		DW	Null		;V16
		DW	VGA_InitPanels	;VGA

;-------------------
;* load panel switch (wrt ScreenMode)
;-------------------

_LoadPanel	DW	Null		;HGC
		DW	Null		;HEM
		DW	Null		;CGA
		DW	Null		;EGA
		DW	Null		;TAN
		DW	Null		;TEM
		DW	Null		;V16
		DW	VGA_LoadPanel	;VGA

;--------------------------
;* clear pilot panel switch (wrt ScreenMode)
;--------------------------

_ClrPilotPanel	DW	Null		;HGC
		DW	Null		;HEM
		DW	Null		;CGA
		DW	Null		;EGA
		DW	Null		;TAN
		DW	Null		;TEM
		DW	Null		;V16
		DW	VGA_ClrPilotPan	;VGA

;--------------------------
;* clear navig panel switch (wrt ScreenMode)
;--------------------------

_ClrNavigPanel	DW	Null		;HGC
		DW	Null		;HEM
		DW	Null		;CGA
		DW	Null		;EGA
		DW	Null		;TAN
		DW	Null		;TEM
		DW	Null		;V16
		DW	VGA_ClrNavigPan	;VGA

;---------------------------------
;* draw pilot panel sprites switch (wrt ScreenMode)
;---------------------------------

_DrawPilotPanel	DW	Null		;HGC
		DW	Null		;HEM
		DW	Null		;CGA
		DW	Null		;EGA
		DW	Null		;TAN
		DW	Null		;TEM
		DW	Null		;V16
		DW	VGA_DrwPilotPan	;VGA

;---------------------------------
;* draw navig panel sprites switch (wrt ScreenMode)
;---------------------------------

_DrawNavigPanel	DW	Null		;HGC
		DW	Null		;HEM
		DW	Null		;CGA
		DW	Null		;EGA
		DW	Null		;TAN
		DW	Null		;TEM
		DW	Null		;V16
		DW	VGA_DrwNavigPan	;VGA

;----------------------------
;* draw ironwork panel switch (wrt ScreenMode)
;----------------------------

_DrawIronWork	DW	Null		;HGC
		DW	Null		;HEM
		DW	Null		;CGA
		DW	Null		;EGA
		DW	Null		;TAN
		DW	Null		;TEM
		DW	Null		;V16
		DW	VGA_IronWork	;VGA

;--------------------------
;* draw HUD brackets switch (wrt ScreenMode)
;--------------------------

_DrawBrackets	DW	Null		;HGC
		DW	Null		;HEM
		DW	Null		;CGA
		DW	Null		;EGA
		DW	Null		;TAN
		DW	Null		;TEM
		DW	Null		;V16
		DW	VGA_Brackets	;VGA

;------------------
;* panel load count (wrt ScreenMode)
;------------------

;* EGA / V16 / VGA (flip screens) must load panel twice, count = 2
;* HGC / CGA / TAN (copy screens) only load panel once, count = 1

PanelLoad	DB	0,0		;panel load count

CountLoad	DB	1		;HGC
		DB	1		;HEM
		DB	1		;CGA
		DB	2		;EGA
		DB	1		;TAN
		DB	1		;TEM
		DB	2		;V16
		DB	2		;VGA

		EVEN

;---------------------
;* update panel switch (wrt PanelMode)
;---------------------

_UpdatePanel	DW	UpdatePilot	;PILOTPAN
		DW	Null		;PSIDEPAN
		DW	UpdateNavig	;NAVIGPAN
		DW	Null 		;NSIDEPAN
		DW	UpdateExtrn 	;EXTRNPAN
		DW	UpdateLookDown	;LOOKDOWN
		DW	UpdateFrame	;LOOKUP
		DW	UpdateExtrn	;MAPPAN

DATA		ENDS

;============================================================================

PANCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:PANCODE
		ASSUME DS:DATA

;* SetPanelMode
;*
;* pass: ax = panel mode required
;* ret : PanelMode
;*       PanelLoad
;* kill: ax, bx, flags

SetPanelMode	PROC	FAR

		mov	PanelMode,ax

		mov	bx,ScreenMode
		shr	bx,1		;/2 byte index
		mov	al,CountLoad[bx]
		mov	PanelLoad,al

		ret

SetPanelMode	ENDP

;----------------------------------------------------------------------------

;* InitPanels
;*
;* pass: ScreenMode
;* ret : cf = 0 = no error
;*       cf = 1 = error
;* kill: assume all
;*
;* NOTE: Only initialize panels AFTER sprites have been initialize else panel
;*       data stored in WorkScreen[] or CopyScreen[] will be destroyed.

InitPanels	PROC	FAR

		mov	bx,ScreenMode
		call	_InitPanels[bx]

		ret

InitPanels	ENDP

;----------------------------------------------------------------------------

;* LoadPanel
;*
;* pass: ScreenMode
;* ret : cf = 0 = no error
;*       cf = 1 = error
;* kill: assume all

LoadPanel	PROC	FAR

		mov	bx,ScreenMode
		call	_LoadPanel[bx]

		ret

LoadPanel	ENDP

;----------------------------------------------------------------------------

;* ClearPilotPanel - clear pilot's panel instruments
;*
;* pass: ScreenMode
;* ret : nothing
;* kill: assume all

ClearPilotPanel	PROC	FAR

		mov	bx,ScreenMode
		call	_ClrPilotPanel[bx]

		ret

ClearPilotPanel	ENDP

;----------------------------------------------------------------------------

;* ClearNavigPanel - clear navigator's panel instruments
;*
;* pass: ScreenMode
;* ret : nothing
;* kill: assume all

ClearNavigPanel	PROC	FAR

		mov	bx,ScreenMode
		call	_ClrNavigPanel[bx]

		ret

ClearNavigPanel	ENDP

;----------------------------------------------------------------------------

;* DrawPilotPanel - draw pilot's panel sprites
;*
;* pass: ScreenMode
;* ret : nothing
;* kill: assume all

DrawPilotPanel	PROC	FAR

		mov	bx,ScreenMode
		call	_DrawPilotPanel[bx]

		ret

DrawPilotPanel	ENDP

;----------------------------------------------------------------------------

;* DrawNavigPanel - draw navigator's panel sprites
;*
;* pass: ScreenMode
;* ret : nothing
;* kill: assume all

DrawNavigPanel	PROC	FAR

		mov	bx,ScreenMode
		call	_DrawNavigPanel[bx]

		ret

DrawNavigPanel	ENDP

;----------------------------------------------------------------------------

;* DrawIronWork - draw ironwork panel
;*
;* pass: ScreenMode
;* ret : nothing
;* kill: assume all

DrawIronWork	PROC	FAR

		mov	bx,ScreenMode
		call	_DrawIronWork[bx]

		ret

DrawIronWork	ENDP

;----------------------------------------------------------------------------

;* DrawBrackets - draw HUD brackets
;*
;* pass: ScreenMode
;* ret : nothing
;* kill: assume all

DrawBrackets	PROC	FAR

		mov	bx,ScreenMode
		call	_DrawBrackets[bx]

		ret

DrawBrackets	ENDP

;----------------------------------------------------------------------------

;* UpdatePanel
;*
;* pass: PanelMode
;*       PanelLoad
;* ret : nothing
;* kill: assume all

UpdatePanel	PROC	FAR

;------------
;* load panel (if required)
;------------

		cmp	PanelLoad,0	;load panel?
		je	@F		;no ->

		dec	PanelLoad	;update load count

		call	LoadPanel

;--------------
;* update panel (wrt PanelMode)
;--------------

@@:		mov	bx,PanelMode
		call	_UpdatePanel[bx]

		ret

UpdatePanel	ENDP

;----------------------------------------------------------------------------

;* Null - null routine
;*
;* pass: nothing
;* ret : cf = 0 = no error (required for some routines)
;* kill: nothing

Null		PROC	NEAR

		clc		;cf = 0 = no error
		ret

Null		ENDP

PANCODE		ENDS

;============================================================================

		END

