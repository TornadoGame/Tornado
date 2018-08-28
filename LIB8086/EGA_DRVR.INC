;****************************************************************************
;*
;* EGA_DRVR.INC
;*
;* EGA registers etc.
;*
;* 05.12.1989 - KJB
;*
;****************************************************************************

EGA_PAGE_0	EQU	0a000h
EGA_PAGE_1	EQU	0a200h
EGA_PAGE_2	EQU	0a400h
EGA_PAGE_3	EQU	0a600h
EGA_PAGE_4	EQU	0a800h
EGA_PAGE_5	EQU	0aa00h
EGA_PAGE_6	EQU	0ac00h
EGA_PAGE_7	EQU	0ae00h

;* EGA REGISTER DEFAULTS:-
;*
;* The EGA registers are set as follows. Any routine which changes
;* the default settings MUST return them to this default status.
;*
;* EGA_SEQ_MAPMSK  = 00fh
;* EGA_CTRL_SETRES = xxxh
;* EGA_CTRL_ENABLE = 00fh
;* EGA_CTRL_COLCMP = 000h
;* EGA_CTRL_ROTATE = 000h
;* EGA_CTRL_RDMAP  = xxxh
;* EGA_CTRL_MODE   = 000h
;* EGA_CTRL_COLMSK = 00fh
;* EGA_CTRL_BITMSK = xxxh
;*
;* xxxh = don't care

EGA_SEQ		EQU	003c4h
EGA_SEQ_MAPMSK	EQU	002h		;xxxxIRGB

EGA_CTRL	EQU	003ceh
EGA_CTRL_SETRES	EQU	000h		;xxxxIRGB
EGA_CTRL_ENABLE	EQU	001h		;xxxxIRGB
EGA_CTRL_COLCMP	EQU	002h		;xxxxIRGB
EGA_CTRL_ROTATE	EQU	003h		;xxxFFxxx - FF = function
EGA_CTRL_RDMAP	EQU	004h		;xxxxxxRR - RR = read
EGA_CTRL_MODE	EQU	005h		;xxxxR0WW -  R = read, WW = write
EGA_CTRL_MISC	EQU	006h
EGA_CTRL_COLMSK	EQU	007h		;xxxxIRGB
EGA_CTRL_BITMSK	EQU	008h

EGA_CRTC    	EQU	003d4h
EGA_CRTC_HI	EQU	00ch
EGA_CRTC_LO	EQU	00dh

EGA_CRT_STAT	EQU	003dah
EGA_VSYNC	EQU	1000b		;vertical sync bit

;----------------------------------------------------------------------------

SETREGV		MACRO	Device,Register,Value

		mov	dx,Device
		mov	al,Register
		out	dx,al
		inc	dx
		mov	al,Value
		out	dx,al

		ENDM

SLCTREG		MACRO	Device,Register

		mov	dx,Device
		mov	al,Register
		out	dx,al
		inc	dx

		ENDM

