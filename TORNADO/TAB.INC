;****************************************************************************
;*
;* TAB.INC
;*
;* TAB modes and data structure (originally in TAB.ASM).
;*
;* 16.10.1992 - KJB
;*
;****************************************************************************

;-----------
;* TAB modes
;-----------

TAB_PLN		EQU	0
TAB_MAP		EQU	2
TAB_REF		EQU	4
TAB_FLIR 	EQU	6
TAB_TIALD	EQU	8
TAB_RADAR	EQU	10

TAB_LOOPBACK	EQU	12

;----------------
;* TAB data block
;----------------

TAB		STRUCT	2

TAB_X_ORG	DW	0		;x origin (top lh corner)
TAB_Y_ORG	DB	0		;y origin
TAB_STATUS	DB	0		;1 = on, 0 = off
TAB_MODE	DW	0		;function mode
TAB_SSF_PTR	DW	-1		;system status flag ptr
TAB_REQ_MOUSE	DB	0		;1 = mouse required for TAB mode
TAB_HAS_MOUSE	DB	0		;1 = TAB has mouse
TAB_SELECT	DB	0		;select key flag
TAB_TOGGLE	DB	0		;toggle key flag

TAB		ENDS

