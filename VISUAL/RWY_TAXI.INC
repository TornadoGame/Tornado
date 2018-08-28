;****************************************************************************
;*
;* RWY_TAXI.INC
;*
;* Data structures and equates for runways / taxiways.
;*
;* 05.08.1991 - KJB
;*
;****************************************************************************

;-------------------
;* RUNWAY data block
;-------------------

RUNWAY		STRUCT

RWY_DIR		DW	0		;direction
RWY_WIDTH	DW	0		;width
RWY_X1		DW	0		;end 1 x co-ord (0 .. 64)
RWY_Y1		DW	0		;end 1 y co-ord (0 .. 64)
RWY_X2		DW	0		;end 2 x co-ord (0 .. 64)
RWY_Y2		DW	0		;end 2 y co-ord (0 .. 64)

RUNWAY		ENDS

RWY_REC_SIZE	EQU	TYPE RUNWAY

;* runway direction equates

RWY_1836	EQU	0*8		;end 1 =  S end, end 2 =  N end
RWY_1331	EQU	1*8		;end 1 = SE end, end 2 = NW end
RWY_0927	EQU	2*8		;end 1 =  E end, end 2 =  W end
RWY_0422	EQU	3*8		;end 1 = NE end, end 2 = SW end

;* runway width equates

RWY_WIDTH256	EQU	0
RWY_WIDTH192	EQU	2
RWY_WIDTH128	EQU	4

;----------------
;* ILS data block
;----------------

ILS		STRUCT	2

ILS_X_DATUM	DW	0	;airfield centre position (calc rng / brg)
ILS_Y_DATUM	DW	0	;(placed on NS and EW runway centre lines)

ILS_AVAILABLE	DB	0	;ILS available flags (see ILS flags)

ILS_N_TDOWN_X	DW	0	;N approach touchdown position
ILS_N_TDOWN_Y	DW	0
ILS_S_TDOWN_X	DW	0	;S approach touchdown position
ILS_S_TDOWN_Y	DW	0
ILS_E_TDOWN_X	DW	0	;E approach touchdown position
ILS_E_TDOWN_Y	DW	0
ILS_W_TDOWN_X	DW	0	;W approach touchdown position
ILS_W_TDOWN_Y	DW	0

ILS		ENDS

ILS_REC_SIZE	EQU	TYPE ILS

;-----------
;* ILS flags
;-----------

ILS_N		EQU	1000b		;north approach ILS
ILS_S		EQU	0100b		;south approach ILS
ILS_E		EQU	0010b		;east approach ILS
ILS_W		EQU	0001b		;west approach ILS

;-----------------
;* TAXI data block
;-----------------

TAXI		STRUCT

TAXI_END_PTR	DW	-1		;route end ptr
TAXI_X_MOD	DW	0		;route end x modifier
TAXI_Y_MOD	DW	0		;route end y modifier

TAXI		ENDS

TAXI_REC_SIZE	EQU	TYPE	TAXI

;------------------
;* TNODE data block
;------------------

TNODE		STRUCT

TNODE_XFT	DW	0
TNODE_YFT	DW	0

TNODE		ENDS

TNODE_REC_SIZE	EQU	TYPE	TNODE

