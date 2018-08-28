;****************************************************************************
;*
;* HGC_STUB.ASM
;*
;* Stub driver for HGC.
;*
;* 23.06.1992 - KJB
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	HGC_VMode
		PUBLIC	HGC_DLoad

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

DATA		ENDS

;============================================================================

GCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:GCODE
		ASSUME DS:DATA

HGC_VMode	LABEL	FAR
HGC_DLoad	LABEL	FAR

		retf

GCODE		ENDS

;============================================================================

		END



