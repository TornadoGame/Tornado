;****************************************************************************
;*
;* VISDATA.INC
;*
;* 23.07.1990 - KJB
;*
;****************************************************************************

;---------------------------------
;* viewpoint data record structure
;---------------------------------

;* NOTE: Keep record length even (for COPY_VP macro (see VISMACRO.INC)).

VIEWPOINT	STRUCT

VP_XSEC		DW	0		;x sector
VP_YSEC		DW	0		;y sector
VP_XFT		DW	0		;x ft
VP_YFT		DW	0		;y ft
VP_ZFT		DD	0		;z ft (0 .. 100,000)
VP_HDG		DW	0		;heading
VP_PITCH	DW	0		;pitch
VP_ROLL		DW	0		;roll

VIEWPOINT	ENDS

VIEW_REC_SIZE	EQU	TYPE VIEWPOINT

VP_ZFT_LO	EQU	VP_ZFT
VP_ZFT_HI	EQU	VP_ZFT+2

;---------------------------
;* sector scale mode equates
;---------------------------

SEC_SCALE1 	EQU	0		;1/1 scale
SEC_SCALE2	EQU	2		;1/2 scale
SEC_SCALE8 	EQU	4		;1/8 scale
SEC_SCALE16 	EQU	6		;1/16 scale

;------------
;* view modes
;------------

INT_VIEWMODE	EQU	0		;internal views
ALT_VIEWMODE	EQU	2		;alternate internal views
EXT_VIEWMODE	EQU	4		;external views
TV1_VIEWMODE	EQU	6		;TV1 display
TV2_VIEWMODE	EQU	8		;TV2 display
TV3_VIEWMODE	EQU	10		;TV3 display
TV4_VIEWMODE	EQU	12		;TV4 display
TV5_VIEWMODE	EQU	14		;TV5 display

NUL_VIEWMODE	EQU	0		;map null view mode to internal

;-------------------
;* view rotate modes
;-------------------

ROTATE_NULL	EQU	0		;no rotation
ROTATE_VIEW_RT	EQU	2		;look right (90)
ROTATE_VIEW_LT	EQU	4		;look left (90)
ROTATE_VIEW_UP	EQU	6		;look up (45)
ROTATE_VIEW_DN	EQU	8		;look down (90)
ROTATE_VIEW_BK	EQU	10		;look back (90)

;---------------------
;* sector grid equates
;---------------------

$MID		EQU	128
$0		EQU	0
$256		EQU	2
$512		EQU	4
$1024		EQU	8
$2048		EQU	16
$4096		EQU	32
$8192		EQU	64

;------------------------------
;* sector data record structure
;------------------------------

;* Refer to VISMACRO.INC for CALC_SEC_INDEX and CALC_SEC_PTR macros.

SECTORDATA	STRUCT

SEC_OBJ_PTR	DW	0		;ground object list ptr
SEC_FLAT_PTR	DW	0		;flat ground object list ptr

SECTORDATA	ENDS

SEC_REC_SIZE	EQU	TYPE SECTORDATA

;------------------------
;* sector scan size range
;------------------------

MIN_SEC_SCAN	EQU	3		;minimum sector scan range
MAX_SEC_SCAN	EQU	15		;maximum sector scan range

;----------------
;* map wrap masks
;----------------

MAP_X_WRAP	EQU	0001fh		;0 .. 31
MAP_Y_WRAP	EQU	0001fh		;0 .. 31

;---------------------
;* sector reject range
;---------------------

SCTR_Y_THRES	EQU	11600		;approx 8,192 * sqrt(2)

;---------------------------
;* object scale mode equates
;---------------------------

OBJ_SCALE1 	EQU	0		;1/1 scale
OBJ_SCALE2	EQU	2		;2/1 scale
OBJ_SCALE4	EQU	4		;4/1 scale
OBJ_SCALE8 	EQU	6		;8/1 scale
OBJ_SCALE16 	EQU	8		;16/1 scale

;----------------------------------------
;* maximum ranges of object scale equates
;----------------------------------------

MAX_RANGE1 	EQU	16384		;OBJ_SCALE1
MAX_RANGE2	EQU	8192		;OBJ_SCALE2
MAX_RANGE4	EQU	4096		;OBJ_SCALE4
MAX_RANGE8 	EQU	2048		;OBJ_SCALE8
MAX_RANGE16 	EQU	1024		;OBJ_SCALE16

;---------------------
;* object grid equates
;---------------------

@MID		EQU	64
@0		EQU	0
@16		EQU	2
@32		EQU	4
@48		EQU	6
@64		EQU	8
@80		EQU	10
@96		EQU	12
@112		EQU	14
@128		EQU	16
@192		EQU	24
@256		EQU	32
@384		EQU	48
@512		EQU	64

;------------------------------
;* object data record structure
;------------------------------

OBJECTDATA	STRUCT

OBJ_TYPE	DB	0		;object type
OBJ_NUM		DB	0		;object number
OBJ_XPOS	DW	0		;x position
OBJ_YPOS	DW	0		;y position
OBJ_ZPOS	DW	0		;z position
OBJ_USERW1	DW	0		;)
OBJ_USERW2	DW	0		;)
OBJ_USERW3	DW	0		;) varies with object type
OBJ_USERW4	DW	0		;)       (see below)
OBJ_USERB1	DB	0		;)
OBJ_USERB2	DB	0		;)
OBJ_PTR		DW	0		;ptr to next object record

OBJECTDATA	ENDS

OBJ_REC_SIZE	EQU	TYPE OBJECTDATA	

;* user vars for ground objects

OBJ_XGRID	EQU	OBJ_USERW1	;x grid
OBJ_YGRID	EQU	OBJ_USERW2	;y grid

;* user vars for mobile objects

OBJ_HDG		EQU	OBJ_USERW1	;heading
OBJ_PITCH	EQU	OBJ_USERW2	;pitch
OBJ_ROLL	EQU	OBJ_USERW3	;roll

;* user vars for ground and mobile objects

OBJ_ANIM_FLAGS	EQU	OBJ_USERB1	;animation flags

;* user vars for hill faces

OBJ_XSECPOS	EQU	OBJ_USERW1	;x sector centre position
OBJ_YSECPOS	EQU	OBJ_USERW2	;y sector centre position
OBJ_ZSECPOS	EQU	OBJ_USERW3	;z sector centre position
OBJ_MAPINDEX	EQU	OBJ_USERW4	;map index
OBJ_SECSCALE	EQU	OBJ_USERB1	;sector scale
OBJ_FACE_FLAGS	EQU	OBJ_USERB2	;hill face flags

;* special y value for hill face distance sort

OBJ_YMIN	EQU	OBJ_XPOS	;minimum y position

;* user vars for smoke

OBJ_SMOKE_RFT	EQU	OBJ_USERW1	;smoke radius
OBJ_SMOKE_COL	EQU	OBJ_USERB1	;smoke colour

;---------------------
;* object type equates
;---------------------

OTYPE_GROUND	EQU	0		;static ground objects
OTYPE_MOBILE1	EQU	2		;mobile objects (skew only)
OTYPE_MOBILE2	EQU	4		;mobile objects (skew and pitch)
OTYPE_MOBILE3	EQU	6		;mobile objects (skew, pitch and roll)
OTYPE_MOBILE4	EQU	8		;mobile objects on bridge (skew and pitch)
OTYPE_HILLFACE	EQU	10		;hill face
OTYPE_SMOKE	EQU	12		;smoke

;-------------------------------------
;* object header data record structure
;-------------------------------------

OBJECTHEADER	STRUCT

OBJ_HDR_SCALE	DW	0		;scale mode (OBJ_SCALE1, OBJ_SCALE2, etc.)
OBJ_HDR_RANGE	DW	0		;max range
OBJ_HDR_PTR	DW	-1		;ptr to next approximation (-1 terminator)
OBJ_HDR_FLAGS	DB	0		;flags (see below)
OBJ_HDR_COL	DB	0		;colour (if approximated to pixel)
OBJ_HDR_XGRID	DW	32		;x grid size ) 
OBJ_HDR_YGRID	DW	32		;y grid size ) minimum grid size
OBJ_HDR_ZGRID	DW	32		;z grid size )

OBJECTHEADER	ENDS

OBJ_HDR_SIZE	EQU	TYPE OBJECTHEADER

OBJ_FLG_PIXEL	EQU	00000001b	;1 = pixel approximation enabled

;------------------------------
;* miscellaneous object equates
;------------------------------

NUM_OBJECTS	EQU	256		;max number of objects

NUM_BINS	EQU	64+1		;(64 * 256ft = 16,384ft) + behind bin

NUM_FAR_OBJECTS	EQU	256		;max number of far objects

NUM_FAR_BINS	EQU	64+1		;(64 * 2,048ft = 131,072ft) + behind bin

BEHIND_BIN	EQU	0		;behind bin index

IN_FRONT_BIN	EQU	2		;in front bin index

;------------------------
;* face attribute equates (b7 always 0, except when attribute = -1 (list terminator))
;------------------------

FACE_EXTENDED	EQU	01000000b	;1 = extended function, 0 = standard function
FACE_DECISION	EQU	00100000b	;1 = decision plane, 0 = standard face
FACE_EXCLUDE	EQU	00010000b	;1 = exclude second choice of decision, 0 = include 
FACE_PRIMARY	EQU	00001000b	;1 = primary face, 0 = secondary face
FACE_VISIBLE	EQU	00000100b	;1 = outside / inside visible, 0 = outside visible
FACE_STRUCTURE	EQU	00000010b	;1 = line structure, 0 = polygon structure
FACE_FILL_TYPE	EQU	00000001b	;1 = mesh fill, 0 = solid fill

;-------------------------------------
;* mobile object data record structure
;-------------------------------------

MOBILE		STRUCT	2

MOB_NUM		DB	0		;object number
MOB_TYPE	DB	0		;object type
MOB_ANIM	DB	0		;animation flags
MOB_LINK_PTR	DW	-1		;mobile sector sort linked list ptr

MOBILE		ENDS

MOB_REC_SIZE	EQU	TYPE MOBILE

;-----------------------------------------------------------------
;* offsets to reach VIEWPOINT in compound mobile object data block
;-----------------------------------------------------------------

_VP_XSEC	EQU	MOB_REC_SIZE+VP_XSEC
_VP_YSEC	EQU	MOB_REC_SIZE+VP_YSEC
_VP_XFT		EQU	MOB_REC_SIZE+VP_XFT
_VP_YFT		EQU	MOB_REC_SIZE+VP_YFT
_VP_ZFT		EQU	MOB_REC_SIZE+VP_ZFT
_VP_HDG		EQU	MOB_REC_SIZE+VP_HDG
_VP_PITCH	EQU	MOB_REC_SIZE+VP_PITCH
_VP_ROLL 	EQU	MOB_REC_SIZE+VP_ROLL

_VP_ZFT_LO	EQU	MOB_REC_SIZE+VP_ZFT_LO
_VP_ZFT_HI	EQU	MOB_REC_SIZE+VP_ZFT_HI

;------------------------------------------------
;* mobile object sector sort bin record structure
;------------------------------------------------

NUM_MOBILES	EQU	256		;max number of mobiles objects

MOBSORT		STRUCT

MSORT_XSEC	DW	0		;x sector
MSORT_YSEC	DW	0		;y sector
MSORT_PTR	DW	-1		;linked list ptr (-1 = list terminator)

MOBSORT		ENDS

MSORT_REC_SIZE	EQU	TYPE MOBSORT

;--------------------------
;* ground object data block
;--------------------------

;* Note: This data structure has not been used in the visual (because the
;*       data is accessed serially for speed) but has been included for use
;*	 by external routines.

GNDOBJ		STRUCT	2

GND_NUM		DB	0		;object number
GND_ANIM	DB	0		;animation data
GND_XGRID	DB	0		;xgrid
GND_YGRID	DB	0		;ygrid

GNDOBJ		ENDS

GND_REC_SIZE	EQU	TYPE GNDOBJ

;--------------------------
;* static mobile data block
;--------------------------

STATMOB		STRUCT	2

STAT_NUM	DB	0		;object number
STAT_ANIM	DB	0		;animation data
STAT_XFT	DW	0		;xft
STAT_YFT	DW	0		;yft
STAT_HDG	DW	0		;heading (0 .. 511 pdegs)

STATMOB		ENDS

STAT_REC_SIZE	EQU	TYPE STATMOB

;---------------
;* surface types
;---------------

SURFACE_UNKNOWN	EQU	0
SURFACE_RUNWAY	EQU	2
SURFACE_TAXIWAY	EQU	4
SURFACE_HARD	EQU	6
SURFACE_ROAD	EQU	8
SURFACE_RAILWAY	EQU	10
SURFACE_RIVER	EQU	12
SURFACE_LAKE	EQU	14

;-----------------------------
;* CRATER types and data block
;-----------------------------

NUM_CRATERS	EQU	128

CRATER_NULL	EQU	0
CRATER_SIZE1	EQU	1		;small
CRATER_SIZE2	EQU	2		;large
CRATER_HEAVE	EQU	3		;heave
CRATER_SHELL	EQU	4		;cannon shell

CRATER		STRUCT	2

CRATER_TYPE	DB	CRATER_NULL
CRATER_ANIM	DB	0		;5 .. 0
CRATER_XSEC	DW	0
CRATER_YSEC	DW	0
CRATER_XFT	DW	0
CRATER_YFT	DW	0
CRATER_ZFT	DW	0
CRATER_HDG	DW	0

CRATER		ENDS

CRATER_REC_SIZE	EQU	TYPE CRATER

;------------------
;* smoke data block
;------------------

NUM_SMOKE	EQU	128

;* smoke effect types

SMOKE_CRATER1	EQU	0		;smoke from crater (min effect)
SMOKE_CRATER2	EQU	2		;smoke from crater (med effect)
SMOKE_CRATER3	EQU	4		;smoke from crater (max effect)
SMOKE_BURNING	EQU	6		;smoke from burning building
SMOKE_KICK_UP	EQU	8		;kick up dust from ground
SMOKE_AIR_EXPLO	EQU	10		;smoke from air explosion
SMOKE_AIR_TRAIL	EQU	12		;smoke from burning aircraft

;* smoke behaviour types

STYPE_NULL	EQU	0		;no smoke
STYPE_GND1	EQU	2		;ground smoke type 1
STYPE_AIR1	EQU	4		;air smoke type 1

SMOKE		STRUCT	2

SMOKE_TYPE	DW	STYPE_NULL	;behaviour type
SMOKE_COL	DB	0		;logical colour
SMOKE_FLAGS	DB	0		;flags (see below)
SMOKE_XSEC	DW	0		;x sector
SMOKE_YSEC	DW	0		;y sector
SMOKE_XFT	DW	0		;xft
SMOKE_YFT	DW	0		;yft
SMOKE_ZFT	DD	0		;zft
SMOKE_ZFINE	DW	0		;zft fine
SMOKE_RFT	DW	0		;radius ft
SMOKE_TIME	DW	0		;elapsed time (secs * 100)
SMOKE_EXP_TIME	DW	0		;expand time (secs * 100)
SMOKE_SIB_CNTR	DW	0		;sibling counter

SMOKE		ENDS

SMOKE_REC_SIZE	EQU	TYPE SMOKE

SMOKE_ZFT_LO	EQU	SMOKE_ZFT
SMOKE_ZFT_HI	EQU	SMOKE_ZFT+2

SFLG_REPRO	EQU	00000001b	;1 = reproduced sibling

