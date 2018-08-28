;****************************************************************************
;*
;* EGA_STUB.ASM
;*
;* Stub driver for EGA / V16.
;*
;* 23.06.1992 - KJB
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	EGA_VMode
		PUBLIC	EGA_DLoad
		PUBLIC	EGA_SetPx
		PUBLIC	EGA_Line
		PUBLIC	EGA_VLine
		PUBLIC	EGA_HLine
		PUBLIC	EGA_PFill
		PUBLIC	EGA_MFill
		PUBLIC	EGA_SFill
		PUBLIC	EGA_PrtC1
		PUBLIC	EGA_PrtC2
		PUBLIC	EGA_PrtC3
		PUBLIC	EGA_SSprite
		PUBLIC	EGA_MSprite
		PUBLIC	EGA_BSprite
		PUBLIC	EGA_QSprite
		PUBLIC	EGA_InitSS
		PUBLIC	EGA_InitMS
		PUBLIC	EGA_InitQS
		PUBLIC	EGA_BFill
		PUBLIC	EGA_SaveMouse
		PUBLIC	EGA_LoadMouse
		PUBLIC	EGA_SaveScreen
		PUBLIC	EGA_LoadScreen
		PUBLIC	EGA_UncompPic
		PUBLIC	EGA_HFill

		PUBLIC	EGA_CalcAddr
		PUBLIC	AllocateSpace
		PUBLIC	CreateEGAData
		PUBLIC	MoveEGAData

		PUBLIC	EGAFreeSpace

		PUBLIC	EGA_LINEADD	

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

EGA_LINEADD	EQU	0

EGAFreeSpace	LABEL	WORD

DATA		ENDS

;============================================================================

GCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:GCODE
		ASSUME DS:DATA

EGA_VMode	LABEL	FAR
EGA_DLoad	LABEL	FAR
EGA_SetPx	LABEL	FAR
EGA_Line	LABEL	FAR
EGA_VLine	LABEL	FAR
EGA_HLine	LABEL	FAR
EGA_PFill	LABEL	FAR
EGA_MFill	LABEL	FAR
EGA_SFill	LABEL	FAR
EGA_PrtC1	LABEL	FAR
EGA_PrtC2	LABEL	FAR
EGA_PrtC3	LABEL	FAR
EGA_SSprite	LABEL	FAR
EGA_MSprite	LABEL	FAR
EGA_BSprite	LABEL	FAR
EGA_QSprite	LABEL	FAR
EGA_InitSS 	LABEL	FAR
EGA_InitMS	LABEL	FAR
EGA_InitQS	LABEL	FAR
EGA_BFill	LABEL	FAR
EGA_SaveMouse	LABEL	FAR
EGA_LoadMouse	LABEL	FAR
EGA_SaveScreen	LABEL	FAR
EGA_LoadScreen	LABEL	FAR
EGA_UncompPic	LABEL	FAR
EGA_HFill	LABEL	FAR

		retf

EGA_CalcAddr	LABEL	NEAR
AllocateSpace	LABEL	NEAR
CreateEGAData	LABEL	NEAR
CreateEGAMask	LABEL	NEAR
MoveEGAData	LABEL	NEAR

		ret

GCODE		ENDS

;============================================================================

		END

