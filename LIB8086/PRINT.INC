;****************************************************************************
;*
;* PRINT.INC
;*
;* Print$ macros.
;*
;* 01.08.1989 - KJB
;* 29.08.1991 - KJB - P_CHAR3 added.
;* 30.08.1991 - KJB - P_BLK changed to P_TITLE.
;*                    P_RED changed to P_TEXT.
;*                    P_ULINE / P_ULEND added.
;*                    P_RECT / P_REND added.
;* 06.05.1992 - KJB - PD_VGA added.
;*                    PV_PDEG added.
;*                    PV_RNG added.
;*                    PV_ETA added.
;*
;****************************************************************************

P_END		MACRO
		DB	0
		ENDM

INPUT_ALL	EQU	0
INPUT_ALPHA	EQU	1
INPUT_NUM	EQU	2

P_INPUT		MACRO	mode
		DB	1,mode
		ENDM

P_OVER0		MACRO	
		DB	2
		ENDM

P_OVER1		MACRO
		DB	3
		ENDM

P_CHAR1		MACRO
		DB	4
		ENDM

P_CHAR2		MACRO
		DB	5
		ENDM

P_CHAR3		MACRO
		DB	6
		ENDM

P_CRSR		MACRO	cursor
		DB	13,cursor
		ENDM

P_HEXAT		MACRO	attr
		DB	14,attr
		ENDM

P_DECAT		MACRO	attr
		DB	15,attr
		ENDM

P_BCDAT		MACRO	attr
		DB	16,attr
		ENDM

P_DEFCL		MACRO
		DB	17
		ENDM

P_TITLE		MACRO
		DB	18
		ENDM

P_TEXT		MACRO
		DB	19
		ENDM

P_ULINE		MACRO
		DB	20
		ENDM

P_ULEND		MACRO	attr
		DB	21,attr
		ENDM

P_RECT		MACRO
		DB	22
		ENDM

P_REND		MACRO	attr
		DB	23,attr
		ENDM

P_NOP		MACRO
		DB	30
		ENDM

P_EXT		EQU	31

PV_CHR		MACRO	addr
		DB	P_EXT,32
		DW	OFFSET addr
		ENDM

PV_STR		MACRO	addr
		DB	P_EXT,33
		DW	OFFSET addr
		ENDM

PP_STR		MACRO	addr
		DB	P_EXT,65
		DW	OFFSET addr
		ENDM

PD_HEXB		MACRO	val
		DB	P_EXT,2
		DB	val
		ENDM

PV_HEXB		MACRO	addr
		DB	P_EXT,34
		DW	OFFSET addr
		ENDM

PD_HEXW		MACRO	val
		DB	P_EXT,3
		DW	val
		ENDM

PV_HEXW		MACRO	addr
		DB	P_EXT,35
		DW	OFFSET addr
		ENDM

PD_HEXL		MACRO	val
		DB	P_EXT,4
		DD	val
		ENDM

PV_HEXL		MACRO	addr
		DB	P_EXT,36
		DW	OFFSET addr
		ENDM

PD_DECB		MACRO	val
		DB	P_EXT,5
		DB	val
		ENDM

PV_DECB		MACRO	addr
		DB	P_EXT,37
		DW	OFFSET addr
		ENDM

PD_DECW		MACRO	val
		DB	P_EXT,6
		DW	val
		ENDM

PV_DECW		MACRO	addr
		DB	P_EXT,38
		DW	OFFSET addr
		ENDM

PP_DECW		MACRO	addr
		DB	P_EXT,70
		DW	OFFSET addr
		ENDM

PD_X		MACRO	x
		DB	P_EXT,16
		DW	x
		ENDM

PV_X		MACRO	addr
		DB	P_EXT,48
		DW	OFFSET addr
		ENDM
		
PD_Y		MACRO	y
		DB	P_EXT,17
		DW	y
		ENDM

PV_Y		MACRO	addr
		DB	P_EXT,49
		DW	OFFSET addr
		ENDM

PD_XY		MACRO	x,y
		DB	P_EXT,18
		DW	x,y
		ENDM

PV_XY		MACRO	addr1,addr2
		DB	P_EXT,50
		DW	OFFSET addr1
		DW	OFFSET addr2
		ENDM

PD_XMOV		MACRO	x
		DB	P_EXT,19
		DW	x
		ENDM

PD_YMOV		MACRO	y
		DB	P_EXT,20
		DW	y
		ENDM

PD_XYMV		MACRO	x,y
		DB	P_EXT,21
		DW	x,y
		ENDM

PD_ATTR		MACRO	f2,b2,f4,b4,f16,b16,f256,b256
		DB	P_EXT,22,f2,b2,f4,b4,f16,b16,f256,b256
		ENDM

PV_ATTR		MACRO	addr
		DB	P_EXT,54
		DW	OFFSET addr
		ENDM

PP_ATTR		MACRO	addr
		DB	P_EXT,86
		DW	OFFSET addr
		ENDM

PD_QSPR		MACRO	x,y,addr
		DB	P_EXT,25
		DW	x
		DW	y
		DW	OFFSET addr
		ENDM

PD_LINE		MACRO	col,x1,y1,x2,y2
		DB	P_EXT,26
		DB	col,0
		DW	x1
		DB	y1,0
		DW	x2
		DB	y2,0
		ENDM

PD_VGA		MACRO	fcol,bcol
		DB	P_EXT,27,fcol,bcol
		ENDM

PV_PDEG		MACRO	addr
		DB	P_EXT,60
		DW	OFFSET addr
		ENDM

PV_RNG		MACRO	addr
		DB	P_EXT,61
		DW	OFFSET addr
		ENDM

PV_ETA		MACRO	addr
		DB	P_EXT,62
		DW	OFFSET addr
		ENDM

