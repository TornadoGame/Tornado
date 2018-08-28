;****************************************************************************
;*
;* CGA_STUB.ASM
;*
;* Stub driver for CGA.
;*
;* 23.06.1992 - KJB
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	CGA_VMode
		PUBLIC	CGA_DLoad
		PUBLIC	CGA_SetPx
		PUBLIC	CGA_Line
		PUBLIC	CGA_VLine
		PUBLIC	CGA_HLine
		PUBLIC	CGA_PFill
		PUBLIC	CGA_MFill
		PUBLIC	CGA_SFill
		PUBLIC	CGA_PrtC1
		PUBLIC	CGA_PrtC2
		PUBLIC	CGA_PrtC3
		PUBLIC	CGA_SSprite
		PUBLIC	CGA_MSprite
		PUBLIC	CGA_BSprite
		PUBLIC	CGA_QSprite
		PUBLIC	CGA_InitSS
		PUBLIC	CGA_InitMS
		PUBLIC	CGA_BFill
		PUBLIC	CGA_SaveMouse
		PUBLIC	CGA_LoadMouse
		PUBLIC	CGA_SaveScreen
		PUBLIC	CGA_LoadScreen
		PUBLIC	CGA_UncompPic
		PUBLIC	CGA_HFill

		PUBLIC	CGA_CalcAddr

		PUBLIC	CGA_LINEADD

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

CGA_LINEADD	EQU	0

DATA		ENDS

;============================================================================

GCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:GCODE
		ASSUME DS:DATA

CGA_VMode	LABEL	FAR
CGA_DLoad	LABEL	FAR
CGA_SetPx	LABEL	FAR
CGA_Line	LABEL	FAR
CGA_VLine	LABEL	FAR
CGA_HLine	LABEL	FAR
CGA_PFill	LABEL	FAR
CGA_MFill	LABEL	FAR
CGA_SFill	LABEL	FAR
CGA_PrtC1	LABEL	FAR
CGA_PrtC2	LABEL	FAR
CGA_PrtC3	LABEL	FAR
CGA_SSprite	LABEL	FAR
CGA_MSprite	LABEL	FAR
CGA_BSprite	LABEL	FAR
CGA_QSprite	LABEL	FAR
CGA_InitSS	LABEL	FAR
CGA_InitMS	LABEL	FAR
CGA_BFill	LABEL	FAR
CGA_SaveMouse	LABEL	FAR
CGA_LoadMouse	LABEL	FAR
CGA_SaveScreen	LABEL	FAR
CGA_LoadScreen	LABEL	FAR
CGA_UncompPic	LABEL	FAR
CGA_HFill	LABEL	FAR

		retf

CGA_CalcAddr	LABEL	NEAR

		ret

GCODE		ENDS

;============================================================================

		END

