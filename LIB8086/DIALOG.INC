;****************************************************************************
;*
;* DIALOG.INC
;*
;* Data structures etc. for dialog boxes.
;*
;* 20.01.1990 - KJB
;*
;* 19.06.1991 - KJB - OPTION changed to OPTYPE for MASM v6.00 compatibilty.
;*
;****************************************************************************

;* general purpose null

NULL		EQU	-1

;* max number of buttons

NUM_BUTTONS	EQU	16		;(ie. bit 0 .. bit 15)

;* max number of options

NUM_OPTIONS	EQU	10		;(ie. F1 .. F10)

;* button bit masks

B0		EQU	00001h
B1		EQU	00002h
B2		EQU	00004h
B3		EQU	00008h
B4		EQU	00010h
B5		EQU	00020h
B6		EQU	00040h
B7		EQU	00080h
B8		EQU	00100h
B9		EQU	00200h
B10		EQU	00400h
B11		EQU	00800h
B12		EQU	01000h
B13		EQU	02000h
B14		EQU	04000h
B15		EQU	08000h

;* action data structure

ACTION		STRUC

ACT_PTR		DW	0		;pointer to OPTYPE record
ACT_OUT		DW	0		;"out" mask
ACT_IN		DW	0		;"in" mask

ACTION		ENDS

ACT_REC_SIZE	EQU	TYPE ACTION

;* target button data structure

TARGET		STRUC

TGT_ACT		DW	0		;pointer to ACTION record
TGT_X		DW	0		;crt x co-ord
TGT_Y		DW	0		;crt y co-ord

TARGET		ENDS

TGT_REC_SIZE	EQU	TYPE TARGET

;* option numbers

OPT_0		EQU	NULL		;null option (no default option)
OPT_1		EQU	ACT_REC_SIZE*0
OPT_2		EQU	ACT_REC_SIZE*1
OPT_3		EQU	ACT_REC_SIZE*2
OPT_4		EQU	ACT_REC_SIZE*3
OPT_5		EQU	ACT_REC_SIZE*4
OPT_6		EQU	ACT_REC_SIZE*5
OPT_7		EQU	ACT_REC_SIZE*6
OPT_8		EQU	ACT_REC_SIZE*7
OPT_9		EQU	ACT_REC_SIZE*8
OPT_10		EQU	ACT_REC_SIZE*9
		
;* dialog box data structure

DIALOG		STRUC

BOX_X_ORG	DW	0		;x origin (top lh corner - 8 pixel boundary)
BOX_Y_ORG	DW	0		;y origin (top lh corner)
BOX_WIDTH	DW	0		;width (pixels - multiple of 8)
BOX_DEPTH	DW	0		;depth (pixels)
BOX_TEXT	DW	NULL		;pointer to text string
BOX_OPTION	DW	OPT_0	 	;default option
BOX_STATUS	DW	0		;button status

DIALOG		ENDS

BOX_REC_SIZE	EQU	TYPE DIALOG

;* option data structure

OPTYPE		STRUC

OPT_ACTION	DW	0		;action ptr
OPT_PARAM1	DW	0		;) spare data for "action" parameters
OPT_PARAM2	DW	0		;) this data should be kept at end of
OPT_PARAM3	DW	0		;) structure so that it is "optional"
OPT_PARAM4	DW	0		;)

OPTYPE		ENDS

OPT_REC_SIZE	EQU	TYPE OPTYPE

;* button data structure

BUTTON		STRUC	

BUT_X_OFF	DW	0		;x offset of centre from BOX_X_ORG
BUT_Y_OFF	DW	0		;y offset of centre from BOX_Y_ORG

BUTTON		ENDS

BUT_REC_SIZE	EQU	TYPE BUTTON

;* list terminators

END_LIST	EQU	-1

ENDOPT		MACRO
		DW	END_LIST
		ENDM

ENDBOX		MACRO
		DW	END_LIST
		ENDM

END_REC_SIZE	EQU	2

;* dialog text postions

OPT_GAP		EQU	20		;y gap between options

TXT_GAP		EQU	12		;y gap between text

;* screen rectangle data structure

RECT		STRUC

RECT_X		DW	0
RECT_Y		DW	0
RECT_WIDTH	DW	0
RECT_DEPTH	DW	0

RECT		ENDS

RECT_REC_SIZE	EQU	TYPE RECT

ENDRECT		MACRO
		DW	END_LIST
		ENDM

