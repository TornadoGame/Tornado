;****************************************************************************
;*
;* VSCREEN.INC
;*
;* 05.02.1992 - KJB
;*
;****************************************************************************

;---------------------
;* viewport data block
;---------------------

VIEWPORT	STRUCT

V_X_ORG		DW	0		;x origin ) top lh
V_Y_ORG		DW	0		;y origin ) corner
V_WIDTH		DW	0		;width
V_DEPTH		DW	0		;depth
V_SCALE_UP	DB	0		;scale up shift count
V_SCALE_DN	DB	0		;scale down shift count

VIEWPORT	ENDS

VP_REC_SIZE	EQU	TYPE VIEWPORT

