;****************************************************************************
;*
;* MFD.INC
;*
;* MFD modes and data structure (originally in MFD.ASM).
;*
;* 16.10.1992 - KJB
;*
;****************************************************************************

;-----------
;* MFD modes
;-----------

MFD_MAP		EQU	0
MFD_RADAR	EQU	2
MFD_AUTO_PILOT	EQU	4
MFD_ILS		EQU	6
MFD_FLIR_ORI	EQU	8
MFD_FLIR	EQU	10

MFD_LOOPBACK	EQU	12

;----------------
;* MFD data block
;----------------

MFD		STRUCT	2

MFD_X_ORG	DW	0		;x origin (top lh corner)
MFD_Y_ORG	DB	0		;y origin
MFD_STATUS	DB	0		;1 = on, 0 = off
MFD_MODE	DW	0		;function mode
MFD_MAP_ZOOM	DW	0		;zoom level
MFD_MAP_ORG	DW	0		;map origin
MFD_SSF_PTR	DW	-1		;system status flag ptr
MFD_REQ_MOUSE	DB	0		;1 = mouse required for MFD mode
MFD_HAS_MOUSE	DB	0		;1 = MFD has mouse

MFD		ENDS

