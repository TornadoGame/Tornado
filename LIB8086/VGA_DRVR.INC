;****************************************************************************
;*
;* VGA_DRVR.INC
;*
;* VGA registers etc.
;*
;* 10.12.1990 - KJB
;*
;****************************************************************************

VGA_PAGE_0	EQU	0a000h
VGA_PAGE_1	EQU	0a400h
VGA_PAGE_2	EQU	0a800h
VGA_PAGE_3	EQU	0ac00h

;* VGA REGISTER DEFAULTS:-
;*
;* The VGA registers are set as follows. Any routine which changes
;* the default settings MUST return them to this default status.
;*
;* VGA_SEQ_MAPMSK  = xxxh
;* VGA_CTRL_SETRES = 000h
;* VGA_CTRL_ENABLE = 000h
;* VGA_CTRL_COLCMP = 000h
;* VGA_CTRL_ROTATE = 000h
;* VGA_CTRL_RDMAP  = xxxh
;* VGA_CTRL_MODE   = 000h
;* VGA_CTRL_COLMSK = 00fh
;* VGA_CTRL_BITMSK = 0ffh
;*
;* xxxh = don't care

VGA_SEQ		EQU	003c4h
VGA_SEQ_MAPMSK	EQU	002h		;xxxxIRGB
VGA_SEQ_MEMMOD	EQU	004h

VGA_CTRL	EQU	003ceh
VGA_CTRL_SETRES	EQU	000h		;xxxxIRGB
VGA_CTRL_ENABLE	EQU	001h		;xxxxIRGB
VGA_CTRL_COLCMP	EQU	002h		;xxxxIRGB
VGA_CTRL_ROTATE	EQU	003h		;xxxFFxxx - FF = function
VGA_CTRL_RDMAP	EQU	004h		;xxxxxxRR - RR = read
VGA_CTRL_MODE	EQU	005h		;xxxxR0WW -  R = read, WW = write
VGA_CTRL_MISC	EQU	006h
VGA_CTRL_COLMSK	EQU	007h		;xxxxIRGB
VGA_CTRL_BITMSK	EQU	008h

VGA_CRTC    	EQU	003d4h
VGA_CRTC_HI	EQU	00ch
VGA_CRTC_LO	EQU	00dh
VGA_CRTC_ULINE	EQU	014h
VGA_CRTC_MODE	EQU	017h

VGA_CRT_STAT	EQU	003dah
VGA_VSYNC	EQU	1000b		;vertical sync bit

VGA_PEL_WRITE	EQU	003c8h		;palette load address for write
VGA_PEL_READ	EQU	003c7h		;palette load address for read
VGA_PEL_DATA	EQU	003c9h		;palette load data register

;------------------------------------------------
;* registers required for horizontal screen shake
;------------------------------------------------

;* WARNING: VGA_ATTR is modified under interrupt. Do not use this register
;*          elsewhere without introducing a signalling system to guard its
;*          use.

VGA_INPUT_1	EQU	003dah		;(note: same as VGA_CRT_STAT)
VGA_ATTR	EQU	003c0h

VGA_ATTR_HPAN	EQU	033h		;use pan values 0, 2, 4 and 6 only

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