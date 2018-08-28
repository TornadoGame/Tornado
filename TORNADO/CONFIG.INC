;****************************************************************************
;*
;* CONFIG.INC
;*
;* Program configuration options.
;*
;* 23.11.1992 - KJB
;*
;* >>>>> IMPORTANT <<<<<
;*
;* Set MAIN.LNK to /m. DO NOT USE /co (codeview data attached to EXE).
;*
;* Refer to LIB8086\KEYBOARD.ASM for SYSREQ_ENABLED option.
;*
;****************************************************************************

;----------------------
;* display debug values
;----------------------

OPT_DEBUG  	EQU	1		;1 = enabled, 0 = disabled

;--------------
;* turbo option
;--------------

OPT_TURBO	EQU	0		;1 = enabled, 0 = disabled

;--------------
;* photo option
;--------------

OPT_PHOTO	EQU	0		;1 = enabled, 0 = disabled

;-----------------------------
;* display title screen option
;-----------------------------

OPT_TITLE_PIC	EQU	0		;1 = enabled, 0 = disabled

;-------------------------------
;* display DI logo screen option
;-------------------------------

OPT_LOGO_PIC	EQU	0		;1 = enabled, 0 = disabled

;---------------------
;* create running demo (default to demo mode / explore mode available)
;---------------------

OPT_DEMO	EQU	0		;0 = no demo
					;1 = drone cycling demo
					;2 = flying demo

;---------------------
;* create flyable demo (no weapons, limited fuel etc.)
;---------------------

OPT_FLY_DEMO	EQU	0		;1 = enabled, 0 = disabled

;----------------------------------
;* create preview mode only version
;----------------------------------

OPT_PREVIEW	EQU	0		;1 = enabled, 0 = disabled

;---------------------------------------
;* no digitised pictures in preview mode
;---------------------------------------

OPT_NO_PICS	EQU	0		;1 = enabled, 0 = disabled

;---------------------------
;* Spectrum HoloByte options
;---------------------------

OPT_HOLOBYTE	EQU	0		;1 = enabled, 0 = disabled

;-----------------------
;* Coktel Vision options
;-----------------------

OPT_COKTEL	EQU	0		;1 = enabled, 0 = disabled

;----------------
;* Leader options
;----------------

OPT_LEADER	EQU	0		;1 = enabled, 0 = disabled

;------------------
;* System 4 options
;------------------

OPT_SYSTEM4	EQU	0		;1 = enabled, 0 = disabled

