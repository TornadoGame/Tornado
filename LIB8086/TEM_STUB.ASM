;****************************************************************************
;*
;* TEM_DRVR.ASM
;*
;* Stub driver for TEM.
;*
;* 23.06.1992 - KJB
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	TEM_VMode
		PUBLIC	TEM_DLoad

		PUBLIC	SetUpEGATable
		PUBLIC	ConvTANToEGA

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

TEM_LINEADD	EQU	0

DATA		ENDS

;============================================================================

GCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:GCODE
		ASSUME DS:DATA

TEM_VMode	LABEL	FAR
TEM_DLoad	LABEL	FAR
SetUpEGATable	LABEL	FAR
ConvTANToEGA	LABEL	FAR

		retf

GCODE		ENDS

;============================================================================

		END

