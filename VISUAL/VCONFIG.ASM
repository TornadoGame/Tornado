;****************************************************************************
;*
;* VCONFIG.ASM
;*
;* Configure visual.
;*
;* 16.07.1992 - KJB
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	ConfigureVisual

		EXTRN	RandomizeClouds:NEAR
		EXTRN	InitPalettes:NEAR

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

DATA		ENDS

;============================================================================

VISCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:VISCODE
		ASSUME DS:DATA

;* ConfigureVisual - set up visual
;*
;* pass: nothing
;* ret : cf = 0 = ok
;*       cf = 1 = palette RGB data load error
;* kill: assume all
;*
;* note: Call once only (after map is loaded).

ConfigureVisual	PROC	FAR

		call	RandomizeClouds

		call	InitPalettes	;(cf indicates load error)

		ret

ConfigureVisual	ENDP

VISCODE		ENDS

;============================================================================

		END

