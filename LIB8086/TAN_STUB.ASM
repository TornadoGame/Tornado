;****************************************************************************
;*
;* TAN_STUB.ASM
;*
;* Stub driver for TAN.
;*
;* 23.06.1992 - KJB
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	TAN_VMode
		PUBLIC	TAN_DLoad
		PUBLIC	TAN_SetPx
		PUBLIC	TAN_Line
		PUBLIC	TAN_VLine
		PUBLIC	TAN_HLine
		PUBLIC	TAN_PFill
		PUBLIC	TAN_MFill
		PUBLIC	TAN_SFill
		PUBLIC	TAN_PrtC1
		PUBLIC	TAN_PrtC2
		PUBLIC	TAN_PrtC3
		PUBLIC	TAN_SSprite
		PUBLIC	TAN_MSprite
		PUBLIC	TAN_BSprite
		PUBLIC	TAN_QSprite
		PUBLIC	TAN_InitSS
		PUBLIC	TAN_InitMS
		PUBLIC	TAN_BFill
		PUBLIC	TAN_SaveMouse
		PUBLIC	TAN_LoadMouse
		PUBLIC	TAN_SaveScreen
		PUBLIC	TAN_LoadScreen
		PUBLIC	TAN_UncompPic
		PUBLIC	TAN_HFill

		PUBLIC	TAN_CalcAddr

		PUBLIC	SeperateData

		PUBLIC	TAN_LINEADD

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

TAN_LINEADD	EQU	0

DATA		ENDS

;============================================================================

GCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:GCODE
		ASSUME DS:DATA

TAN_VMode	LABEL	FAR
TAN_DLoad	LABEL	FAR
TAN_SetPx	LABEL	FAR
TAN_Line	LABEL	FAR
TAN_VLine	LABEL	FAR
TAN_HLine	LABEL	FAR
TAN_PFill	LABEL	FAR
TAN_MFill	LABEL	FAR
TAN_SFill	LABEL	FAR
TAN_PrtC1	LABEL	FAR
TAN_PrtC2	LABEL	FAR
TAN_PrtC3	LABEL	FAR
TAN_SSprite	LABEL	FAR
TAN_MSprite	LABEL	FAR
TAN_BSprite	LABEL	FAR
TAN_QSprite	LABEL	FAR
TAN_InitSS 	LABEL	FAR
TAN_InitMS	LABEL	FAR
TAN_BFill	LABEL	FAR
TAN_SaveMouse	LABEL	FAR
TAN_LoadMouse	LABEL	FAR
TAN_SaveScreen	LABEL	FAR
TAN_LoadScreen	LABEL	FAR
TAN_UncompPic	LABEL	FAR
TAN_HFill	LABEL	FAR

		retf

TAN_CalcAddr	LABEL	NEAR
SeperateData	LABEL	NEAR

		ret

GCODE		ENDS

;============================================================================

		END

