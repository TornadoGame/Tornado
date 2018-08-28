;****************************************************************************
;*
;* PREVIEW.ASM
;*
;* Object preview routine.
;*
;* 16.01.1993 - KJB
;* 19.02.1993 - KJB - CheckTimeout added.
;* 22.04.1993 - KJB - Theme music added.
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	ObjectPreview

		EXTRN	LoadPicture:FAR
		EXTRN	LoadFile:FAR
		EXTRN	InterleaveData:FAR
		EXTRN	RetrieveData:FAR
		EXTRN	StoreWorkScreen:FAR
		EXTRN	CopyPreviewPan:FAR
		EXTRN	DrawPreviewPan:FAR
		EXTRN	BlockFill:FAR
		EXTRN	DownLoad:FAR
		EXTRN	SetViewMode:FAR
		EXTRN	MobileVisual:FAR
		EXTRN	SetMouseLimits:FAR
		EXTRN	SetMousePos:FAR
		EXTRN	ReadMouse:FAR
		EXTRN	HLineDraw:FAR
		EXTRN	VLineDraw:FAR
		EXTRN	QFadeOut:FAR
		EXTRN	QFadeIn:FAR
		EXTRN	InstantFadeOut:FAR
		EXTRN	InstantFadeIn:FAR
		EXTRN	Cls:FAR
		EXTRN	SetPixel:FAR
		EXTRN	VGAPhotoDflt:FAR
		EXTRN	CheckTimeout:FAR
		EXTRN	InstallUser100:FAR
		EXTRN	RefreshMusic:FAR

		EXTRN	ElapsedTime:DWORD

		EXTRN	Frames:WORD
		EXTRN	LastFrame:WORD
		EXTRN	MouseXMin:WORD
		EXTRN	MouseXMax:WORD
		EXTRN	MouseYMin:WORD
		EXTRN	MouseYMax:WORD
		EXTRN	MouseX:WORD
		EXTRN	MouseY:WORD
		EXTRN	WorkScrPtr:WORD

		EXTRN	WorkScreen:BYTE
		EXTRN	PreviewMode:BYTE
		EXTRN	DieFlag:BYTE
		EXTRN	Key:BYTE

;============================================================================

		INCLUDE	MAINDATA.INC
		INCLUDE	CONFIG.INC

		INCLUDE	\VISUAL\MOBLIST.INC
		INCLUDE	\VISUAL\VISDATA.INC
		INCLUDE	\VISUAL\PALETTES.INC

		INCLUDE	\LIB8086\KEYS.INC
		INCLUDE	\LIB8086\USEFUL.INC
		INCLUDE	\LIB8086\VGA_DRVR.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

;---------------
;* miscellaneous
;---------------

ModelPtr	DW	OFFSET ModelList

Category	DW	AIR_MODEL

Show3DTimer	DW	0		;secs * 100

Exit3DFlag	DB	0		;1 = exit 3D model display

FadeInFlag	DB	0		;1 = fade in 3D model display

Paused		DB	0		;1 = paused (hdg update inhibited)

PausePlayXchg	DB	0		;1 = exchange pause / play gadget

Timer50		DB	0		;50Hz toggle

		EVEN

;-----------
;* viewpoint
;-----------

ZBASE		EQU	1000

VP		VIEWPOINT <16,16,0,0,ZBASE,256,0,0>

;--------
;* mobile
;--------

P_MOBILE	MOBILE    <MOB_TORNADO1,OTYPE_MOBILE3>
P_VIEW		VIEWPOINT <16,16,0,0,ZBASE>

HFine		DW	0		;fine pdegs
PFine		DW	-16*128		;fine pdegs
RFine		DW	32*128		;fine pdegs

PrevPFine	DW	-16*128		;fine pdegs
PrevRFine	DW	32*128		;fine pdegs

;--------------------
;* screen clip limits
;--------------------

X_MIN		EQU	0
X_MAX		EQU	319
Y_MIN		EQU	0
Y_MAX		EQU	199

;------------
;* mouse data
;------------

MouseXCrt	DW	0
MouseYCrt	DW	0

MOUSE_X_MIN	EQU	0
MOUSE_X_MAX	EQU	639
MOUSE_Y_MIN	EQU	0
MOUSE_Y_MAX	EQU	399

MOUSE_X_START	EQU	320
MOUSE_Y_START	EQU	300

;--------------------
;* graphics data file
;--------------------

GraphicsFile 	DB	"PREVIEW.BT2",0

		EVEN

;---------------------------
;* picture path\filename.ext
;---------------------------

PicFile		LABEL	BYTE
		DB	"..\DIGIPICS\"	;path
PicFileName	DB	"12345678"	;filename
		DB	".PT2"		;extention
		DB	0		;ASCIIZ

		EVEN

;-------------------
;* multiple pictures
;-------------------

NUM_GR4_PICS	EQU	'3'
GR4_MODIFIER	EQU	4		;"GR4_?"

NUM_F3_PICS	EQU	'5'
F3_MODIFIER	EQU	3		;"F3_?"

;---------------
;* fixed colours
;---------------

COL_MOUSE_PTR	EQU	194

;-----------------------
;* gadget data structure
;-----------------------

GADGET		STRUCT	2

GAD_EVENT	DW	NullEvent	;event handler
GAD_SPTR	DW	-1		;sprite source ptr
GAD_XPOS	DW	0		;x position
GAD_YPOS	DW	0		;y position
GAD_WIDTH	DW	0		;width
GAD_DEPTH	DW	0		;depth

GADGET		ENDS

GAD_REC_SIZE	EQU	TYPE GADGET

NUM_GADGETS	EQU	9

;-------------
;* gadget data
;-------------

GadgetPtr	DW	-1		;current active gadget (-1 = inactive)

GadgetList  	LABEL	GADGET

		GADGET	<EjectEvent,     173*320+0,    3, 168, 13, 11>
		GADGET	<PictureEvent,   173*320+16,  18, 168, 27, 11>
		GADGET	<ReverseEvent,   173*320+48,   3, 181, 13, 11>
		GADGET	<ForwardEvent,   173*320+64,  32, 181, 13, 11>
PausePlayGadget	GADGET	<PausePlayEvent, 173*320+80,  18, 181, 12, 11>
		GADGET	<PitchUpEvent,   173*320+160, 57, 171, 11,  9>
		GADGET	<PitchDnEvent,   173*320+176, 57, 180, 11,  9>
		GADGET	<BankREvent,     173*320+144, 63, 168, 15, 24>
		GADGET	<BankLEvent,     173*320+128, 47, 168, 15, 24>

		EVEN

;-------------------------------
;* forward / reverse auto-repeat
;-------------------------------

AUTO_DELAY	EQU	100		;secs * 100
AUTO_RATE	EQU	33		;secs * 100

AutoTimer	DW	AUTO_DELAY

DATA		ENDS

;============================================================================

PREVDATA 	SEGMENT PARA PUBLIC 'DATA'

;----------------------
;* model data structure
;----------------------

MODEL		STRUCT	2

MOD_FILENAME	DB	8 DUP (' ')	;filename
MOD_CAT		DW	0		;category
MOD_NUM		DB	0		;object number
MOD_ANIM	DB	0		;object animation
MOD_DIST	DW	0		;distance from viewpoint (to fit screen)
MOD_DISP	DW	0		;z displacement (to fit screen)
MOD_TTL_X	DW	0		;title x co-ord start
MOD_TTL_Y	DW	0		;title y co-ord start
MOD_TTL_PTR	DW	-1		;title ASCIIZ string ptr
MOD_SUB_TTL_X	DW	0		;sub-title x co-ord start
MOD_SUB_TTL_Y	DW	0		;sub-title y co-ord start
MOD_SUB_TTL_PTR	DW	-1		;sub-title ASCIIZ string ptr

MODEL		ENDS

MOD_REC_SIZE	EQU	TYPE MODEL

;------------------
;* model categories
;------------------

AIR_MODEL	EQU	0		;aircraft
HEL_MODEL	EQU	2		;helicopter
GND_MODEL	EQU	4		;ground vehicle

;------------
;* model data
;------------

NUM_MODELS	EQU	28

ModelList	LABEL	MODEL

GR4Model	MODEL	<					\
		     		"GR4_1", 			\
				AIR_MODEL,			\
				MOB_TORNADO1,			\
				WING_SWEEP_MID,			\
				58,				\
				ZBASE+1,			\
				152,168,OFFSET Tornado$,	\
				115,168,OFFSET GR4$		\
			>
		MODEL	<					\
				"MIG27",			\
				AIR_MODEL,			\
				MOB_MIG27_1,			\
				WING_SWEEP_MID,			\
				58,				\
				ZBASE+1,  			\
				168,168,OFFSET Flogger$,	\
				108,168,OFFSET Mig27$		\
			>
F3Model		MODEL	<					\
				"F3_1",				\
				AIR_MODEL,			\
				MOB_TORNADV1,			\
				WING_SWEEP_MID,			\
				58,				\
				ZBASE+1, 			\
				143,168,OFFSET Tornado$,	\
				123,168,OFFSET F3$		\
			>
		MODEL	<					\
		     		"MIG31",			\
		     		AIR_MODEL,			\
		     		MOB_MIG31,			\
				0,				\
				64,				\
				ZBASE,				\
				152,168,OFFSET Foxhound$,     	\
				101,168,OFFSET Mig31$		\
		     	>
		MODEL	<					\
			 	"F15",				\
			 	AIR_MODEL,			\
			 	MOB_F15,			\
				0,				\
				64,				\
				ZBASE,				\
				170,168,OFFSET Eagle$,		\
				141,168,OFFSET F15$		\
	   		>
		MODEL	<					\
				"SU27",				\
				AIR_MODEL,			\
				MOB_SU27_1,			\
				0,				\
				60,				\
				ZBASE+1,			\
				164,168,OFFSET Flanker$,	\
				114,168,OFFSET Su27$		\
			>
		MODEL	<					\
				"F16",				\
				AIR_MODEL,			\
				MOB_F16,			\
				0,				\
				58,				\
				ZBASE+1,  			\
				162,168,OFFSET Falcon$,		\
				131,168,OFFSET F16$		\
			>
		MODEL	<					\
				"MIG29",			\
				AIR_MODEL,			\
				MOB_MIG29,			\
				0,				\
				56,				\
				ZBASE,				\
				168,168,OFFSET Fulcrum$,	\
				108,168,OFFSET Mig29$		\
			>
		MODEL	<					\
				"A10",				\
				AIR_MODEL,			\
				MOB_A10,			\
				0,				\
				52,				\
				ZBASE+1,  			\
				124,168,OFFSET Thunderbolt$, 	\
				86,168,OFFSET A10$		\
			>
		MODEL	<					\
				"SU25",				\
				AIR_MODEL,			\
				MOB_SU25,			\
				0,				\
				47,				\
				ZBASE+1,			\
				152,168,OFFSET Frogfoot$,     	\
				104,168,OFFSET Su25$		\
			>
		MODEL	<					\
				"C130",				\
				AIR_MODEL,			\
				MOB_C130,			\
				0,				\
				116,				\
				ZBASE+3,			\
				152,168,OFFSET Hercules$,     	\
				109,168,OFFSET C130$		\
			>
		MODEL	<					\
				"IL76CAND",			\
				AIR_MODEL,			\
				MOB_IL76,			\
				0,				\
				164,				\
				ZBASE+4,			\
				168,168,OFFSET Candid$,		\
				129,168,OFFSET Il76$		\
			>
		MODEL	<					\
				"E3D",				\
				AIR_MODEL,			\
				MOB_E3D,			\
				0,				\
				164,				\
				ZBASE+4,			\
				165,168,OFFSET Sentry$,		\
				129,168,OFFSET E3D$		\
			>
		MODEL	<					\
				"IL76MAIN",			\
				AIR_MODEL,			\
				MOB_IL76,			\
				AC_SPECIALS,			\
				164,				\
				ZBASE+4,			\
				155,168,OFFSET Mainstay$,  	\
				111,168,OFFSET A50$		\
			>
		MODEL	<					\
				"AH64",				\
				HEL_MODEL,			\
				MOB_AH64,			\
				0,				\
				58,				\
				ZBASE+2, 			\
				173,168,OFFSET Apache$,		\
				117,168,OFFSET AH64$		\
			>
		MODEL	<					\
				"MI24",				\
				HEL_MODEL,			\
				MOB_HIND1,			\
				0,				\
				65,				\
				ZBASE+2,			\
				193,168,OFFSET Hind$,		\
				145,168,OFFSET Mi24$		\
			>
		MODEL	<					\
				"CH47",				\
				HEL_MODEL,			\
				MOB_CHINOOK,			\
				0,				\
				96,				\
				ZBASE+1, 			\
				165,168,OFFSET Chinook$,	\
				112,168,OFFSET CH47$		\
			>
		MODEL	<					\
				"MI26",				\
				HEL_MODEL,			\
				MOB_MI26,			\
				0,				\
				120,				\
				ZBASE+3, 			\
				186,168,OFFSET Halo$,		\
				139,168,OFFSET Mi26$		\
			>
		MODEL	<					\
				"CHALLENG",			\
				GND_MODEL,			\
				MOB_CHAL1,			\
				0,				\
				34,				\
				ZBASE+17, 			\
				111,168,OFFSET Challenger$  	\
			>
		MODEL	<					\
				"T80",				\
				GND_MODEL,			\
				MOB_T80,			\
				0,				\
				28,				\
				ZBASE+14, 			\
				173,168,OFFSET T80$		\
			>
		MODEL	<					\
				"WARRIOR",			\
				GND_MODEL,			\
				MOB_WARRIOR1,			\
				0,				\
				20,				\
				ZBASE+10,			\
				140,168,OFFSET Warrior$		\
			>
		MODEL	<					\
				"BMP2",				\
				GND_MODEL,			\
				MOB_BMP2,			\
				0,				\
				20,				\
				ZBASE+10, 			\
				159,168,OFFSET BMP2$		\
			>
		MODEL	<					\
				"MLRS",				\
				GND_MODEL,			\
				MOB_MLRS1,			\
				0,				\
				22,				\
				ZBASE+16, 			\
				164,168,OFFSET MLRS$		\
			>
		MODEL	<					\
				"MAZ543",			\
				GND_MODEL,			\
				MOB_MAZ543,			\
				0,				\
				32,				\
				ZBASE+16,			\
				143,168,OFFSET MAZ543$		\
			>
		MODEL	<					\
				"PATRIOT",			\
				GND_MODEL,			\
				MOB_PAT1,			\
				0,				\
				32,				\
				ZBASE+24,			\
				145,168,OFFSET Patriot$		\
			>
		MODEL	<					\
				"ZRKROMB",			\
				GND_MODEL,			\
				MOB_ROMB,			\
				0,				\
				24,				\
				ZBASE+14, 			\
				126,168,OFFSET ZRKRomb$		\
			>
		MODEL	<					\
				"GIRAFFE",			\
				GND_MODEL,			\
				MOB_MOBRAD,			\
				0,				\
				32,				\
				ZBASE+30, 			\
				144,168,OFFSET Giraffe$		\
			>
		MODEL	<					\
				"ZSU23",			\
				GND_MODEL,			\
				MOB_ZSU23,			\
				0,				\
				20,				\
				ZBASE+11, 			\
				141,168,OFFSET ZSU23$		\
			>
					      
ModelListEnd	LABEL	MODEL

		EVEN

;----------------------------
;* model title ASCIIZ strings
;----------------------------

Tornado$	DB	"TORNADO",0
Flogger$	DB	"FLOGGER",0
Foxhound$	DB	"FOXHOUND",0
Eagle$		DB	"EAGLE",0
Flanker$	DB	"FLANKER",0
Falcon$		DB	"FALCON",0
Fulcrum$	DB	"FULCRUM",0
Thunderbolt$	DB	"THUNDERBOLT",0
Frogfoot$	DB	"FROGFOOT",0
Hercules$	DB	"HERCULES",0
Candid$		DB	"CANDID",0
Sentry$		DB	"SENTRY",0
Mainstay$	DB	"MAINSTAY",0
Apache$		DB	"APACHE",0
Hind$		DB	"HIND",0
Chinook$	DB	"CHINOOK",0
Halo$		DB	"HALO",0
Challenger$	DB	"CHALLENGER",0
T80$		DB	"T-80",0
Warrior$	DB	"WARRIOR",0
BMP2$		DB	"BMP-2",0
MLRS$		DB	"MLRS",0
MAZ543$		DB	"MAZ-543",0
Patriot$	DB	"PATRIOT",0
ZRKRomb$	DB	"ZRK ROMB",0
ZSU23$		DB	"ZSU-23-4",0
Giraffe$	DB	"GIRAFFE",0

		EVEN

;--------------------------------
;* model sub-title ASCIIZ strings
;--------------------------------

GR4$		DB	"GR4",0
Mig27$		DB	"MIG-27",0
F3$		DB	"F3",0
Mig31$		DB	"MIG-31",0
F15$		DB	"F-15",0
Su27$		DB	"SU-27",0
F16$		DB	"F-16",0
Mig29$		DB	"MIG-29",0
A10$		DB	"A-10",0
Su25$		DB	"SU-25",0
C130$		DB	"C-130",0
Il76$		DB	"IL-76",0
E3D$		DB	"E-3D",0
A50$		DB	"A-50",0
AH64$		DB	"AH-64",0
Mi24$		DB	"MI-24",0
CH47$		DB	"CH-47",0
Mi26$		DB	"MI-26",0

		EVEN

;------------------------
;* title character widths
;------------------------

TITLE_SPACE	EQU	17+1		;average character width + 1 pixel gap

TITLE_HYPHEN	EQU	9+1

TitleWidthAZ	DB	20		;'A'
		DB	16		;'B'
		DB	19		;'C'
		DB	18		;'D'
		DB	15		;'E'
		DB	14		;'F'
		DB	19		;'G'
		DB	17		;'H'
		DB	 5		;'I'
		DB	13		;'J'
		DB	18		;'K'
		DB	14		;'L'
		DB	20		;'M'
		DB	17		;'N'
		DB	19		;'O'
		DB	16		;'P'
		DB	19		;'Q'
		DB	16		;'R'
		DB	16		;'S'
		DB	17		;'T'
		DB	17		;'U'
		DB	18		;'V'
		DB	23		;'W'
		DB	18		;'X'
		DB	17		;'Y'
		DB	16		;'Z'

TitleWidth09	DB	14		;'0'
		DB	 9 		;'1'
		DB	14		;'2'
		DB	14		;'3'
		DB	14		;'4'
		DB	14		;'5'
		DB	14		;'6'
		DB	14		;'7'
		DB	14		;'8'
		DB	14		;'9'

		EVEN

;----------------------------
;* sub-title character widths
;----------------------------

SUB_TTL_SPACE	EQU	12+1		;average character width + 1 pixel gap

SUB_TTL_HYPHEN	EQU	4+1

STitleWidthAZ	DB	15		;'A'
		DB	10		;'B'
		DB	11		;'C'
		DB	12		;'D'
		DB	 9		;'E'
		DB	 9		;'F'
		DB	12		;'G'
		DB	12		;'H'
		DB	 3		;'I'
		DB	 5		;'J'
		DB	13		;'K'
		DB	 9		;'L'
		DB	15		;'M'
		DB	13		;'N'
		DB	14		;'O'
		DB	10		;'P'
		DB	14		;'Q'
		DB	11		;'R'
		DB	 9		;'S'
		DB	11		;'T'
		DB	12		;'U'
		DB	13		;'V'
		DB	22		;'W'
		DB	14		;'X'
		DB	13		;'Y'
		DB	12		;'Z'

STitleWidth09	DB	11		;'0'
		DB	 3 		;'1'
		DB	10		;'2'
		DB	 8		;'3'
		DB	11		;'4'
		DB	 8		;'5'
		DB	10		;'6'
		DB	10		;'7'
		DB	10		;'8'
		DB	10		;'9'

		EVEN

;---------------------
;* kern data structure
;---------------------	   

KERN		STRUCT

KERN_THIS_CHAR	DB	0		;if this character is followed
KERN_NEXT_CHAR	DB	0		;by this character then adjust
KERN_X_ADJUST	DB	0		;x position by this amount

KERN		ENDS

KERN_REC_SIZE	EQU	TYPE KERN

;------------------------------
;* title character kerning data
;------------------------------

TitleKern	LABEL	KERN

		KERN	<'-','2',-1>
		KERN	<'-','4',-1>
		KERN	<'-','5',-1>
		KERN	<'-','8',-1>
		KERN	<'A','C',-1>
		KERN	<'A','G',-1>
		KERN	<'A','T',-4>
		KERN	<'A','Y',-4>
		KERN	<'C','A',-1>
		KERN	<'F','A',-3>
		KERN	<'F','O',-1>
		KERN	<'L','C',-1>
		KERN	<'L','O',-1>
		KERN	<'L','T',-6>
		KERN	<'O','T',-1>
		KERN	<'O','X',-1>
		KERN	<'P','A',-3>
		KERN	<'T','-',-6>
		KERN	<'T','A',-4>
		KERN	<'T','O',-1>
		KERN	<'W','A',-3>
		KERN	<'Z','-',-2>

		DB	-1		;end of list

		EVEN

;----------------------------------
;* sub-title character kerning data
;----------------------------------

SubTitleKern	LABEL	KERN

		KERN	<'-','1',-1>
		KERN	<'-','2',-3>
		KERN	<'-','3',-3>
		KERN	<'-','4',-1>
		KERN	<'-','6',-1>
		KERN	<'-','7',-3>
		KERN	<'A','-',-1>
		KERN	<'C','-',-1>
		KERN	<'E','-',-1>
		KERN	<'F','-',-1>
		KERN	<'L','-',-2>

		DB	-1		;end of list

		EVEN

PREVDATA	ENDS

;============================================================================

PREVCODE 	SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:PREVCODE
		ASSUME DS:DATA

;* ObjectPreview
;*
;* pass: PreviewMode
;* ret : nothing
;* kill: assume all

ObjectPreview	PROC	FAR

		call	InitPreview

		cmp	DieFlag,0	;error?
		jne	PreviewExit	;yes ->

PreviewLoop:	call	Show3DModel

		call	CheckTimeout

		cmp	DieFlag,0	;continue?
		jne	PreviewExit	;no ->

	IF	OPT_NO_PICS EQ 0

		call	ShowPicture

		call	CheckTimeout

		cmp	DieFlag,0	;continue?
		jne	PreviewExit	;no ->

	ENDIF

;* advance if auto-run

		cmp	PreviewMode,2	;auto-run?
		jne	@F		;no ->

		call	NextModelPtr

@@:		jmp	PreviewLoop

PreviewExit:	ret

ObjectPreview	ENDP

;----------------------------------------------------------------------------

;* InitPreview
;*
;* pass: nothing
;* ret : DieFlag
;* kill: assume all

InitPreview	PROC	NEAR

;------------------------------
;* install user timer interrupt
;------------------------------

		mov	ax,OFFSET PreviewIntr100
		mov	dx,SEG PreviewIntr100
		call	InstallUser100

;---------------
;* load graphics
;---------------

		push	es

		mov	dx,OFFSET GraphicsFile

		mov	ax,SEG WorkScreen
		mov	es,ax
		xor	di,di		;es:di -> start of WorkScreen

		mov	cx,320*200

		call	LoadFile

		pop	es

		jnc	@F		;ok ->

		mov	DieFlag,SYS_ERR_LD_PREV

		jmp	InitExit

;------------------------------
;* store graphics in VGA page 2
;------------------------------

@@:		mov	dx,VGA_PAGE_2

		call	StoreWorkScreen

;-------------------------------------------
;* interleave panel graphics into VGA page 3
;-------------------------------------------

		push	es

		mov	ax,VGA_PAGE_3
		mov	es,ax
		xor	di,di
		mov	cx,320*40

		call	InterleaveData

		pop	es

;------------------
;* initialize mouse
;------------------

		mov	MouseXMin,MOUSE_X_MIN
		mov	MouseXMax,MOUSE_X_MAX
		mov	MouseYMin,MOUSE_Y_MIN
		mov	MouseYMax,MOUSE_Y_MAX

		call	SetMouseLimits

		mov	cx,MOUSE_X_START
		mov	bx,MOUSE_Y_START
		call	SetMousePos

;--------------
;* reset timers (because of time taken to initialize (load files etc.))
;--------------

		xor	ax,ax

		cli
		mov	Frames,ax
		mov	WORD PTR ElapsedTime,ax
		mov	WORD PTR ElapsedTime+2,ax
		sti

InitExit:	ret

InitPreview	ENDP

;----------------------------------------------------------------------------

;* ShowPicture
;*
;* pass: ModelPtr
;* ret : DieFlag
;* kill: assume all

ShowPicture	PROC	NEAR

;---------------
;* sort filename
;---------------

		mov	si,ModelPtr

		mov	ax,PREVDATA
		mov	ds,ax

		add	si,MOD_FILENAME

		mov	di,OFFSET PicFileName

		mov	cx,8
		rep	movsb

		mov	ax,DATA
		mov	ds,ax

;---------------
;* cycle picture (if more than one available)
;---------------

		mov	si,ModelPtr

		mov	ah,NUM_GR4_PICS	;assume GR4
		mov	bx,GR4_MODIFIER

		cmp	si,OFFSET GR4Model
		je	@F

		mov	ah,NUM_F3_PICS	;assume F3
		mov	bx,F3_MODIFIER

		cmp	si,OFFSET F3Model
		je	@F

		jmp	SkipCycle

@@:   		mov	dx,PREVDATA
		mov	ds,dx

		mov	al,[si][bx].MOD_FILENAME

		inc	al

		cmp	al,ah
		jbe	@F

		mov	al,'1'

@@:		mov	[si][bx].MOD_FILENAME,al

		mov	dx,DATA
		mov	ds,dx

;--------------
;* load picture
;--------------

SkipCycle:	mov	cx,10*100	;assume auto-run

		cmp	PreviewMode,2	;auto-run?
		je	@F		;yes ->

		mov	cx,10*60*100

@@:		mov	dx,OFFSET PicFile
		mov	al,1		;rapid fades
		call	LoadPicture

		ret

ShowPicture	ENDP

;----------------------------------------------------------------------------

;* Show3DModel
;*
;* pass: ModelPtr
;* ret : DieFlag
;* kill: assume all

Show3DModel	PROC	NEAR

;------------
;* initialize
;------------

		mov	Show3DTimer,10*100

		mov	Exit3DFlag,0

		mov	FadeInFlag,1

		mov	Frames,0

		mov	LastFrame,0

;* clear and fade screen

		mov	al,COL_BLACK
		call	Cls
		call	DownLoad

		call	InstantFadeOut

;* retrieve graphics data

		mov	dx,VGA_PAGE_2

		call	RetrieveData

;* set viewmode

		mov	ax,ALT_VIEWMODE

		call	SetViewMode

;* set up model and viewpoint

		call	SetUpModel

;---------------------------
ModelLoop	LABEL	NEAR
;---------------------------

;-------------------
;* update auto-timer
;-------------------

		call	UpdateTimer

;------------
;* check keys
;------------

		call	CheckKeys

;------------------
;* sort mouse input
;------------------

		call	SortMouseInput

;------------------
;* clear background
;------------------

		mov	al,COL_BLACK
		mov	cx,0
		mov	bl,0
		mov	dx,319
		mov	bh,159

		call	BlockFill

;--------------------
;* draw control panel
;--------------------

		call	DrawPreviewPan

		call	DrawGadgets

;-----------------
;* rotate 3D model
;-----------------

		test	Paused,1	;paused?
		jnz	@F		;yes, do not rotate hdg ->

;* rotate hdg (4 secs / revolution)

		mov	ax,LastFrame
		mov	dx,109		;65536 / (4 * 100)
		mul	dx
		add	HFine,ax

;* calc hdg, pitch and roll from fine values

@@:		mov	cl,7		;/128

		mov	ax,HFine
		shr	ax,cl
		ROUNDUP	ax
		and	ax,001ffh
		mov	P_VIEW.VP_HDG,ax

		mov	ax,PFine
		shr	ax,cl
		ROUNDUP	ax
		and	ax,001ffh
		mov	P_VIEW.VP_PITCH,ax

		mov	ax,RFine
		shr	ax,cl
		ROUNDUP	ax
		and	ax,001ffh
		mov	P_VIEW.VP_ROLL,ax

;--------------------------
;* rotate helicopter blades
;--------------------------

		cmp	Category,HEL_MODEL	;helicopter?
		jne	SkipBlades		;no ->

		mov	al,P_MOBILE.MOB_ANIM
  		and	al,ROTOR_ALL			;current rotor pos
		add	al,ROTOR_POS2			;rotate one position
		cmp	al,ROTOR_POS3			;end of rotation?
		jbe	@F				;no ->
		mov	al,ROTOR_POS1			;start of rotation
@@:		and	P_MOBILE.MOB_ANIM,NOT ROTOR_ALL	;clear old rotation
		or	P_MOBILE.MOB_ANIM,al		;set new rotation

;---------------
;* draw 3D model
;---------------

SkipBlades:	mov	si,OFFSET VP
		mov	di,OFFSET P_MOBILE

		call	MobileVisual

;--------------------
;* draw mouse pointer
;--------------------

		call	DrawMousePtr

;-----------------
;* download screen
;-----------------

		call	DownLoad

		test	FadeInFlag,1	;fade in?
		jz	@F		;no ->

		call	QFadeIn

		mov	FadeInFlag,0

		mov	Frames,0

		mov	LastFrame,0

;------------
;* take photo
;------------

@@:	IF	OPT_PHOTO EQ 1

		test	Key[K_F12],1
		jz	@F
		call	VGAPhotoDflt
@@:		

	ENDIF

;----------------
;* check for exit
;----------------

		cmp	DieFlag,0	;quit?
		jne	@F		;yes ->

		test	Exit3DFlag,1	;exit?
		jnz	@F		;yes ->

		jmp	ModelLoop

@@:		call	QFadeOut

		mov	al,COL_BLACK
		call	Cls
		call	DownLoad

		call	InstantFadeIn	;clear fade

		ret

Show3DModel	ENDP

;----------------------------------------------------------------------------

;* SetUpModel - set up model and viewpoint
;*
;* pass: ModelPtr
;* ret : VP
;*       P_MOBILE
;*	 P_VIEW
;* kill: assume all

SetUpModel	PROC	NEAR

;* in case switching from air model to gnd model store pitch and roll

		cmp	Category,GND_MODEL
		je	SkipStore

		mov	ax,PFine
		mov	PrevPFine,ax
		mov	ax,RFine
		mov	PrevRFine,ax

		jmp	SkipRestore

;* in case switching from gnd model to air model restore pitch and roll

SkipStore:	mov	ax,PrevPFine
		mov	PFine,ax
		mov	ax,PrevRFine
		mov	RFine,ax

SkipRestore:	mov	si,ModelPtr

;* fetch and set model parameters

		mov	ax,PREVDATA
		mov	es,ax

		mov	al,ES:[si].MOD_NUM
		mov	P_MOBILE.MOB_NUM,al

		mov	al,ES:[si].MOD_ANIM
		mov	P_MOBILE.MOB_ANIM,al

		mov	ax,ES:[si].MOD_CAT
		mov	Category,ax

		mov	ax,ES:[si].MOD_DIST
		mov	VP.VP_YFT,ax

		mov	ax,ES:[si].MOD_DISP
		mov	WORD PTR VP.VP_ZFT_LO,ax

		mov	ax,DATA
		mov	es,ax

;* set viewpoint pitch wrt category

		mov	VP.VP_PITCH,0		;assume air model

		cmp	Category,GND_MODEL	;gnd model?
		jne	@F			;no ->

		mov	VP.VP_PITCH,512-38	;-26.5degs

		mov	PFine,0
		mov	RFine,0

;* create new panel wrt model

@@: 		call	MakePreviewPan

		ret

SetUpModel	ENDP

;----------------------------------------------------------------------------

;* UpdateTimer
;*
;* pass: Show3DTimer
;* ret : Show3DTimer
;*       Exit3DFlag
;* kill: assume all

UpdateTimer	PROC	NEAR

		cmp	PreviewMode,2	;auto-run?
		jne	ExitTimer	;no ->

		mov	ax,Show3DTimer
		sub	ax,LastFrame
		jnc	@F

		or	Exit3DFlag,1

		xor	ax,ax

@@:		mov	Show3DTimer,ax

ExitTimer:	ret

UpdateTimer	ENDP

;----------------------------------------------------------------------------

;* CheckKeys
;*
;* pass: nothing
;* ret : DieFlag
;*       Exit3DFlag
;* kill: assume all

CheckKeys	PROC	NEAR

;* quit preview mode?

		mov	al,Key[K_CTRL]
		and	al,Key[K_Q]	;quit?
		jz	@F		;no ->

		mov	DieFlag,DIE_QUIT

;* switch to picture?

@@:		mov	al,Key[K_SPACE]
		or	al,Key[K_ENTER]
		or	al,Key[K_ESC]

		or	Exit3DFlag,al

		ret

CheckKeys	ENDP

;----------------------------------------------------------------------------

;* SortMouseInput
;*
;* pass: nothing
;* ret : GadgetPtr
;* kill: assume all

SortMouseInput	PROC	NEAR

;------------
;* read mouse
;------------

		mov	GadgetPtr,-1	;assume no active gadget

		call	ReadMouse

;* al = 1 = lhs button pressed
;* ah = 1 = rhs button pressed
;* cx = MouseX
;* bx = MouseY
;* dl = 1 = lhs button just pressed
;* dh = 1 = rhs button just pressed

;---------------
;* sort auto-run (exit if mouse button pressed)
;---------------

		cmp	PreviewMode,2	;auto-run?
		jne	@F		;no ->

		or	al,ah		;mouse button pressed?

		or	Exit3DFlag,al

		jmp	ExitMouseInput

;------------------------
;* calc mouse crt co-ords
;------------------------

@@:		shr	cx,1
		ROUNDUP	cx
		cmp	cx,X_MAX
		jle	@F
		mov	cx,X_MAX

@@:	    	shr	bx,1
		ROUNDUP	bx
		cmp	bx,Y_MAX
		jle	@F
		mov	bx,Y_MAX

@@:		mov	MouseXCrt,cx
		mov	MouseYCrt,bx

;------------------------
;* check for button click
;------------------------

		or	al,ah		;any mouse button clicked?
		jz	ExitMouseInput	;no ->

;--------------
;* scan gadgets
;--------------

		mov	si,OFFSET GadgetList
		mov	cx,NUM_GADGETS

GadgetScanLoop:	mov	ax,MouseXCrt
		sub	ax,[si].GAD_XPOS
		jb	@F			;miss ->
		cmp	ax,[si].GAD_WIDTH
		jae	@F			;miss ->

		mov	ax,MouseYCrt
		sub	ax,[si].GAD_YPOS
		jb	@F			;miss ->
		cmp	ax,[si].GAD_DEPTH
		jb	HitGadget		;hit ->

@@:		add	si,GAD_REC_SIZE		;next gadget
		loop	GadgetScanLoop

		jmp	ExitMouseInput

HitGadget:	mov	GadgetPtr,si

;------------
;* sort event
;------------

		call	[si].GAD_EVENT

ExitMouseInput:	ret			

SortMouseInput	ENDP

;----------------------------------------------------------------------------

;* DrawMousePtr
;*
;* pass: MouseXCrt
;*       MouseYCrt
;* ret : nothing
;* kill: assume all

DrawMousePtr	PROC	NEAR

		cmp	PreviewMode,2	;auto-run?
		_JE	ExitMousePtr	;yes ->

;--------------------
;* draw mouse pointer
;--------------------

;*              ³ (a)
;*              ³
;*      (c) ÄÄÄÄ ÄÄÄÄ (d)
;*              ³
;*              ³ (b)

;-----------------
;* draw stroke (a)
;-----------------

		mov	cx,MouseXCrt
		mov	bx,MouseYCrt

		sub	bx,2
		cmp	bx,Y_MIN
		jl	SkipA

		mov	ax,bx
		sub	ax,2
		cmp	ax,Y_MIN
		jge	@F
		mov	ax,Y_MIN

@@:		mov	bh,al

		mov	al,COL_MOUSE_PTR
		call	VLineDraw

;-----------------
;* draw stroke (b)
;-----------------

SkipA:		mov	cx,MouseXCrt
		mov	bx,MouseYCrt

		add	bx,2
		cmp	bx,Y_MAX
		jg	SkipB

		mov	ax,bx
		add	ax,2
		cmp	ax,Y_MAX
		jle	@F
		mov	ax,Y_MAX

@@:		mov	bh,al

		mov	al,COL_MOUSE_PTR
		call	VLineDraw

;-----------------
;* draw stroke (c)
;-----------------

SkipB:		mov	cx,MouseXCrt
		mov	bx,MouseYCrt

		sub	cx,2
		cmp	cx,X_MIN
		jl	SkipC

		mov	dx,cx
		sub	dx,2
		cmp	dx,X_MIN
		jge	@F
		mov	dx,X_MIN

@@:		mov	al,COL_MOUSE_PTR
		call	HLineDraw

;-----------------
;* draw stroke (d)
;-----------------

SkipC:		mov	cx,MouseXCrt
		mov	bx,MouseYCrt

		add	cx,2
		cmp	cx,X_MAX
		jg	ExitMousePtr

		mov	dx,cx
		add	dx,2
		cmp	dx,X_MAX
		jle	@F
		mov	dx,X_MAX

@@:		mov	al,COL_MOUSE_PTR
		call	HLineDraw

ExitMousePtr: 	ret

DrawMousePtr	ENDP

;----------------------------------------------------------------------------

;* NullEvent
;*
;* pass: si -> GADGET
;*       dl = 1 = lhs button just pressed
;*       dh = 1 = rhs button just pressed
;* ret : nothing
;* kill: nothing

NullEvent	PROC	NEAR

		ret

NullEvent	ENDP

;----------------------------------------------------------------------------

;* EjectEvent
;*
;* pass: si -> GADGET
;*       dl = 1 = lhs button just pressed
;*       dh = 1 = rhs button just pressed
;* ret : nothing
;* kill: nothing

EjectEvent	PROC	NEAR

		mov	DieFlag,DIE_QUIT

		ret

EjectEvent	ENDP

;----------------------------------------------------------------------------

;* PictureEvent
;*
;* pass: si -> GADGET
;*       dl = 1 = lhs button just pressed
;*       dh = 1 = rhs button just pressed
;* ret : nothing
;* kill: nothing

PictureEvent	PROC	NEAR

		or	Exit3DFlag,1

		ret

PictureEvent	ENDP

;----------------------------------------------------------------------------

;* ReverseEvent
;*
;* pass: si -> GADGET
;*       dl = 1 = lhs button just pressed
;*       dh = 1 = rhs button just pressed
;* ret : nothing
;* kill: nothing

ReverseEvent	PROC	NEAR

		or	dl,dh		;just pressed?
		jz	@F		;no ->

		mov	AutoTimer,AUTO_DELAY
		
		jmp	ContReverse

@@:		mov	ax,LastFrame
		sub	AutoTimer,ax
		jnc	@F

		mov	AutoTimer,AUTO_RATE
		
ContReverse:	call	PrevModelPtr

		call	SetUpModel

@@:		ret

ReverseEvent	ENDP

;----------------------------------------------------------------------------

;* ForwardEvent
;*
;* pass: si -> GADGET
;*       dl = 1 = lhs button just pressed
;*       dh = 1 = rhs button just pressed
;* ret : nothing
;* kill: nothing

ForwardEvent	PROC	NEAR

		or	dl,dh		;just pressed?
		jz	@F		;no ->

		mov	AutoTimer,AUTO_DELAY
		
		jmp	ContForward

@@:		mov	ax,LastFrame
		sub	AutoTimer,ax
		jnc	@F

		mov	AutoTimer,AUTO_RATE
		
ContForward:	call	NextModelPtr

		call	SetUpModel

@@:		ret

ForwardEvent	ENDP

;----------------------------------------------------------------------------

;* PausePlayEvent
;*
;* pass: si -> GADGET
;*       dl = 1 = lhs button just pressed
;*       dh = 1 = rhs button just pressed
;* ret : nothing
;* kill: nothing

PausePlayEvent	PROC	NEAR

		test	PausePlayXchg,1	;exchange in progress?
		jnz	@F		;yes ->

		xor	Paused,1	;toggle pause / play

		mov	PausePlayXchg,1	;exchange gadgets

		call	MakePreviewPan

@@:		ret

PausePlayEvent	ENDP

;----------------------------------------------------------------------------

;* PitchUpEvent
;*
;* pass: si -> GADGET
;*       dl = 1 = lhs button just pressed
;*       dh = 1 = rhs button just pressed
;* ret : PFine
;* kill: nothing

PitchUpEvent	PROC	NEAR

		cmp	Category,GND_MODEL
		je	SkipPitchUp

		mov	ax,LastFrame
		mov	cl,7
		shl	ax,cl

		add	ax,PFine

		cmp	ax,64*128	;45degs max pitch up
		jle	@F

		mov	ax,64*128

@@:		mov	PFine,ax

		ret

SkipPitchUp:	mov	GadgetPtr,-1	;deselect gadget

		ret

PitchUpEvent	ENDP

;----------------------------------------------------------------------------

;* PitchDnEvent
;*
;* pass: si -> GADGET
;*       dl = 1 = lhs button just pressed
;*       dh = 1 = rhs button just pressed
;* ret : PFine
;* kill: nothing

PitchDnEvent	PROC	NEAR

		cmp	Category,GND_MODEL
		je	SkipPitchDn

		mov	ax,LastFrame
		mov	cl,7
		shl	ax,cl

		neg	ax

		add	ax,PFine

		cmp	ax,-64*128	;-45degs max pitch down
		jge	@F

		mov	ax,-64*128

@@:		mov	PFine,ax

		ret

SkipPitchDn:	mov	GadgetPtr,-1	;deselect gadget

		ret

PitchDnEvent	ENDP

;----------------------------------------------------------------------------

;* BankREvent
;*
;* pass: si -> GADGET
;*       dl = 1 = lhs button just pressed
;*       dh = 1 = rhs button just pressed
;* ret : RFine
;* kill: nothing

BankREvent	PROC	NEAR

		cmp	Category,GND_MODEL
		je	SkipBankR

		mov	ax,LastFrame
		mov	cl,7
		shl	ax,cl

		add	ax,RFine

		cmp	ax,64*128	;45 degs max bank right
		jle	@F

		mov	ax,64*128

@@:		mov	RFine,ax

		ret

SkipBankR:	mov	GadgetPtr,-1	;deselect gadget

		ret

BankREvent	ENDP

;----------------------------------------------------------------------------

;* BankLEvent
;*
;* pass: si -> GADGET
;*       dl = 1 = lhs button just pressed
;*       dh = 1 = rhs button just pressed
;* ret : RFine
;* kill: nothing

BankLEvent	PROC	NEAR

		cmp	Category,GND_MODEL
		je	SkipBankL

		mov	ax,LastFrame
		mov	cl,7
		shl	ax,cl

		neg	ax

		add	ax,RFine

		cmp	ax,-64*128	;-45degs max bank left
		jge	@F

		mov	ax,-64*128

@@:		mov	RFine,ax

		ret

SkipBankL:	mov	GadgetPtr,-1	;deselect gadget

		ret

BankLEvent	ENDP

;----------------------------------------------------------------------------

;* NextModelPtr - point to next model data block (with wrap around)
;*
;* pass: ModelPtr
;* ret : si = ModelPtr
;* kill: flags

NextModelPtr	PROC	NEAR

		mov	si,ModelPtr

		add	si,MOD_REC_SIZE

		cmp	si,OFFSET ModelListEnd	;wrap around?
		jb	@F	   		;no ->

		mov	si,OFFSET ModelList

@@:		mov	ModelPtr,si

		ret

NextModelPtr	ENDP

;----------------------------------------------------------------------------

;* PrevModelPtr - point to previous model data block (with wrap around)
;*
;* pass: ModelPtr
;* ret : si = ModelPtr
;* kill: flags

PrevModelPtr	PROC	NEAR

		mov	si,ModelPtr

		cmp	si,OFFSET ModelList	;wrap around?
		ja	@F	   		;no ->

		mov	si,OFFSET ModelListEnd

@@:		sub	si,MOD_REC_SIZE

		mov	ModelPtr,si

		ret

PrevModelPtr	ENDP

;----------------------------------------------------------------------------

;* DrawGadgets
;*
;* pass: GadgetPtr
;* ret : nothing
;* kill: assume all

DrawGadgets	PROC	NEAR

;----------------------------
;* sort pause / play exchange
;----------------------------

		test	PausePlayXchg,1	;exchange gadgets?
		jz	SkipXchg	;no ->

;* only exchange if pause / play gadget inactive

		cmp	GadgetPtr,OFFSET PausePlayGadget
		je	SkipXchg

		mov	si,173*320+80	;assume switch to pause gadget

		test	Paused,1	;paused?
		jz	@F		;no ->

		mov	si,173*320+112	;play gadget

@@:		mov	PausePlayGadget.GAD_SPTR,si

		mov	PausePlayXchg,0	;exchanged

;--------------------
;* draw active gadget (if any)
;--------------------

SkipXchg:	mov	si,GadgetPtr

		cmp	si,-1		;null ptr?
		je	@F		;yes ->

		mov	cx,[si].GAD_XPOS
		mov	bx,[si].GAD_YPOS
		mov	dx,[si].GAD_WIDTH
		mov	bp,[si].GAD_DEPTH
		mov	si,[si].GAD_SPTR

		call	DrawSprite

@@:		ret

DrawGadgets	ENDP

;----------------------------------------------------------------------------

;* MakePreviewPan
;*
;* pass: ModelPtr
;* ret : nothing
;* kill: assume all
;*
;* note: This routine copies the blank preview panel and prints the title and
;*       sub-title text onto it. The panel is drawn from this copy which saves
;*       printing the text each frame (as the DrawSprite routine is slow).

MakePreviewPan	PROC	NEAR

		push	WorkScrPtr

		mov	WorkScrPtr,VGA_PAGE_3

;--------------------
;* copy default panel
;--------------------

		call	CopyPreviewPan

;-----------------------------------------------
;* blank out roll / pitch gadget if ground model
;-----------------------------------------------

		cmp	Category,GND_MODEL
		jne	@F

		mov	cx,47
		mov	bx,168
		mov	dx,31
		mov	bp,24
		mov	si,173*320+192

		call	DrawSprite

;----------------------------
;* draw play gadget if paused
;----------------------------

@@:		test	Paused,1
		jz	@F

		mov	cx,18
		mov	bx,181
		mov	dx,12
		mov	bp,11
		mov	si,173*320+96

		call	DrawSprite

;-------------------------
;* print title / sub-title
;-------------------------

@@: 		call	PrintTitle$

		call	PrintSubTitle$

		pop	WorkScrPtr

		ret

MakePreviewPan	ENDP

;----------------------------------------------------------------------------

;* PrintTitle$
;*
;* pass: ModelPtr
;* ret : nothing
;* kill: assume all
;*
;* note: Only prints 'A' .. 'Z', '0' .. '9', '-' and ' '.
;*
;*       String must be in PREVDATA segment.

PrintTitle$	PROC	NEAR

;-------------------------
;* pickup string x, y, ptr
;-------------------------

		mov	si,ModelPtr

		mov	ax,PREVDATA
		mov	ds,ax

		ASSUME	DS:PREVDATA

		mov	cx,[si].MOD_TTL_X
		mov	bx,[si].MOD_TTL_Y
		mov	si,[si].MOD_TTL_PTR

;------------------------
;* check for null pointer
;------------------------

		cmp	si,-1		;null pointer?
		_JE	ExitTitle$	;yes ->

;------------------
;* scan string loop
;------------------

TitleLoop:	lodsb			;fetch char

		mov	ah,[si]		;fetch next char
		
		test	al,al		;end of string?
		_JZ	ExitTitle$	;yes ->

		push	si		;store string ptr

;------------
;* sort space
;------------

		cmp	al,' '		;space?
		jne	@F		;no ->

		mov	dx,TITLE_SPACE	;width

		mov	si,-1		;sprite source ptr (-1 = non-printable)

		jmp	ContTitle

;-------------
;* sort hyphen
;-------------

@@:		cmp	al,'-'		;hyphen?
		jne	@F		;no ->

		mov	dx,TITLE_HYPHEN	;width

		mov	si,97*320+240	;sprite source ptr

		jmp	ContTitle

;-----------------
;* sort '0' .. '9'
;-----------------

@@:		cmp	al,'0'		;'0' .. '9'?
		jb	@F		;no ->
		cmp	al,'9'		;'0' .. '9'?
		ja	@F		;no ->

;* look up char width

		mov	di,ax
		and	di,000ffh
		sub	di,'0'

		mov	dl,TitleWidth09[di]	;dx = char width
		xor	dh,dh

;* for chars '0' .. '9' ptr = (97 * 320) + (char - '0') * 24

		mov	si,ax		;store this char / next char

		sub	al,'0'
		mov	ah,24
		mul	ah
		add	ax,97*320

		xchg	ax,si		;ax = chars / si = ptr

		jmp	ContTitle

;-----------------
;* sort 'A' .. 'Z'
;-----------------

@@:		cmp	al,'A'		;'A' .. 'Z'?
		jb	SkipTitleChar	;no, invalid char ->
		cmp	al,'Z'		;'A' .. 'Z'?
		ja	SkipTitleChar	;no, invalid char ->

;* look up char width

		mov	di,ax
		and	di,000ffh
		sub	di,'A'

		mov	dl,TitleWidthAZ[di]	;dx = char width
		xor	dh,dh

;* calc sprite source ptr

		mov	si,ax		;store this char / next char

		cmp	al,'M'		;'A' .. 'M'?
		ja	@F		;no ->

;* for chars 'A' .. 'M' ptr = (51 * 320) + (char - 'A') * 24

		sub	al,'A'
		mov	ah,24
		mul	ah
		add	ax,51*320

		xchg	ax,si		;ax = chars / si = ptr

		jmp	ContTitle

;* for chars 'N' .. 'Z' ptr = (74 * 320) + (char - 'N') * 24

@@:		sub	al,'N'
		mov	ah,24
		mul	ah
		add	ax,74*320

		xchg	ax,si		;ax = chars / si = ptr

;---------------------------
ContTitle	LABEL	NEAR
;---------------------------

		xor	bp,bp			;assume zero kern adjustment

		mov	di,OFFSET TitleKern

TitleKernLp:	cmp	[di].KERN_THIS_CHAR,-1	;end of list?
		je	TitleKernOk		;yes ->

		cmp	al,[di].KERN_THIS_CHAR	;this char match?
		jne	@F			;no ->
		cmp	ah,[di].KERN_NEXT_CHAR	;next char match?
		jne	@F			;no ->

		push	ax

		mov	al,[di].KERN_X_ADJUST
		cbw
		mov	bp,ax

		pop	ax

		jmp	TitleKernOk

@@:		add	di,KERN_REC_SIZE

		jmp	TitleKernLp

;-------------
;* draw sprite
;-------------

TitleKernOk:	cmp	si,-1		;non-printable character?
		je	@F		;yes ->

		mov	ax,DATA
		mov	ds,ax

		push	bx
		push	cx
		push	dx
		push	bp

		mov	bp,22		;depth

		call	DrawSprite

		pop	bp
		pop	dx
		pop	cx
		pop	bx

		mov	ax,PREVDATA
		mov	ds,ax

@@:		add	cx,dx		;char width
		add	cx,bp		;kern adjustment
		inc	cx		;pixel gap

SkipTitleChar:	pop	si		;restore string ptr

		jmp	TitleLoop

;---------
;* tidy up
;---------

ExitTitle$:	mov	ax,DATA
		mov	ds,ax

		ASSUME	DS:DATA

		ret

PrintTitle$	ENDP

;----------------------------------------------------------------------------

;* PrintSubTitle$
;*
;* pass: ModelPtr
;* ret : nothing
;* kill: assume all
;*
;* note: Only prints 'A' .. 'Z', '0' .. '9', '-' and ' '.
;*
;*       String must be in PREVDATA segment.

PrintSubTitle$	PROC	NEAR

;-------------------------
;* pickup string x, y, ptr
;-------------------------

		mov	si,ModelPtr

		mov	ax,PREVDATA
		mov	ds,ax

		ASSUME	DS:PREVDATA

		mov	cx,[si].MOD_SUB_TTL_X
		mov	bx,[si].MOD_SUB_TTL_Y
		mov	si,[si].MOD_SUB_TTL_PTR

;------------------------
;* check for null pointer
;------------------------

		cmp	si,-1		;null pointer?
		_JE	ExitSubTitle$	;yes ->

;------------------
;* scan string loop
;------------------

SubTitleLoop:	lodsb			;fetch char

		mov	ah,[si]		;fetch next char
		
		test	al,al		;end of string?
		_JZ	ExitSubTitle$	;yes ->

		push	si		;store string ptr

;------------
;* sort space
;------------

		cmp	al,' '		;space?
		jne	@F		;no ->

		mov	dx,SUB_TTL_SPACE	;width

		mov	si,-1		;sprite source ptr (-1 = non-printable)

		jmp	ContSubTitle

;-------------
;* sort hyphen
;-------------

@@:		cmp	al,'-'		;hyphen?
		jne	@F		;no ->

		mov	dx,SUB_TTL_HYPHEN	;width

		mov	si,154*320+240	;sprite source ptr

		jmp	ContSubTitle

;-----------------
;* sort '0' .. '9'
;-----------------

@@:		cmp	al,'0'		;'0' .. '9'?
		jb	@F		;no ->
		cmp	al,'9'		;'0' .. '9'?
		ja	@F		;no ->

;* look up char width

		mov	di,ax
		and	di,000ffh
		sub	di,'0'

		mov	dl,STitleWidth09[di]	;dx = char width
		xor	dh,dh

;* for chars '0' .. '9' ptr = (154 * 320) + (char - '0') * 24

		mov	si,ax		;store this char / next char

		sub	al,'0'
		mov	ah,24
		mul	ah
		add	ax,154*320

		xchg	ax,si		;ax = chars / si = ptr

		jmp	ContSubTitle

;-----------------
;* sort 'A' .. 'Z'
;-----------------

@@:		cmp	al,'A'		;'A' .. 'Z'?
		jb	SkipSTitleChar	;no, invalid char ->
		cmp	al,'Z'		;'A' .. 'Z'?
		ja	SkipSTitleChar	;no, invalid char ->

;* look up char width

		mov	di,ax
		and	di,000ffh
		sub	di,'A'

		mov	dl,STitleWidthAZ[di]	;dx = char width
		xor	dh,dh

;* calc sprite source ptr

		mov	si,ax		;store this char / next char

		cmp	al,'M'		;'A' .. 'M'?
		ja	@F		;no ->

;* for chars 'A' .. 'M' ptr = (120 * 320) + (char - 'A') * 24

		sub	al,'A'
		mov	ah,24
		mul	ah
		add	ax,120*320

		xchg	ax,si		;ax = chars / si = ptr

		jmp	ContSubTitle

;* for chars 'N' .. 'Z' ptr = (137 * 320) + (char - 'N') * 24

@@:		sub	al,'N'
		mov	ah,24
		mul	ah
		add	ax,137*320

		xchg	ax,si		;ax = chars / si = ptr

;---------------------------
ContSubTitle	LABEL	NEAR
;---------------------------

		xor	bp,bp			;assume zero kern adjustment

		mov	di,OFFSET SubTitleKern

STitleKernLp:	cmp	[di].KERN_THIS_CHAR,-1	;end of list?
		je	STitleKernOk		;yes ->

		cmp	al,[di].KERN_THIS_CHAR	;this char match?
		jne	@F			;no ->
		cmp	ah,[di].KERN_NEXT_CHAR	;next char match?
		jne	@F			;no ->

		push	ax

		mov	al,[di].KERN_X_ADJUST
		cbw
		mov	bp,ax

		pop	ax

		jmp	STitleKernOk

@@:		add	di,KERN_REC_SIZE

		jmp	STitleKernLp

;-------------
;* draw sprite
;-------------

STitleKernOk:	cmp	si,-1		;non-printable character?
		je	@F		;yes ->

		mov	ax,DATA
		mov	ds,ax

		push	bx
		push	cx
		push	dx
		push	bp

		mov	bp,16		;depth

		call	DrawSprite

		pop	bp
		pop	dx
		pop	cx
		pop	bx

		mov	ax,PREVDATA
		mov	ds,ax

@@:		add	cx,dx		;char width
		add	cx,bp		;kern adjustment
		inc	cx		;pixel gap

SkipSTitleChar:	pop	si		;restore string ptr

		jmp	SubTitleLoop

;---------
;* tidy up
;---------

ExitSubTitle$:	mov	ax,DATA
		mov	ds,ax

		ASSUME	DS:DATA

		ret

PrintSubTitle$	ENDP

;----------------------------------------------------------------------------

;* DrawSprite
;*
;* pass: si -> sprite data
;*       cx = x dest
;*       bl = y dest
;*       dx = width
;*       bp = depth
;* ret : nothing
;* kill: assume all

DrawSprite	PROC	NEAR

;---------------------------
SpriteYLoop	LABEL	NEAR
;---------------------------

		push	bx
		push	cx
		push	dx
		push	si
		push	bp

;---------------------------
SpriteXLoop	LABEL	NEAR
;---------------------------

		mov	di,SEG WorkScreen
		mov	ds,di

		lodsb			;fetch pixel

		mov	di,DATA
		mov	ds,di

		test	al,al		;transparent?
		jz	@F		;yes ->

		push	bx
		push	cx
		push	dx
		push	si
		call	SetPixel
		pop	si
		pop	dx
		pop	cx
		pop	bx

@@:		inc	cx		;x = x + 1
		dec	dx
		jnz	SpriteXLoop

		pop	bp
		pop	si
		pop	dx
		pop	cx
		pop	bx

		inc	bx		;y = y + 1    
		add	si,320
		dec	bp
		jnz	SpriteYLoop

		ret

DrawSprite	ENDP

;----------------------------------------------------------------------------

;* PreviewIntr100 - 100Hz interrupt routine
;*
;* pass: nothing
;* ret : nothing
;* kill: nothing

PreviewIntr100	PROC	FAR

;--------------------
;* update theme music
;--------------------

		xor	Timer50,1	;toggle 50Hz
		jz	@F		;skip ->

		call	RefreshMusic

@@:		ret

PreviewIntr100	ENDP

PREVCODE	ENDS

;============================================================================

		END

