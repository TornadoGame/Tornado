;****************************************************************************
;*
;* HEM_DRVR.ASM
;*
;* Screen dependant routines for Hercules emulation routines.
;*
;* 28.04.1989 - KJB
;*
;* The Hercules Graphics Card can be emulated using the CGA mode 6.
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	HEM_VMode

		EXTRN	ResetMouse:FAR

		EXTRN	WorkScrPtr:WORD
		EXTRN	RealScrPtr:WORD

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

HEM_REAL_SCR	EQU	0b800h		;HEM segment ptr

DATA		ENDS

;============================================================================

WSDATA		SEGMENT PARA PUBLIC 'DATA'

WSDATA		ENDS

;============================================================================

GCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:GCODE
		ASSUME DS:DATA

;* HEM_VMode - set video mode
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all
;*
;* note: Reset mouse immediately after setting video mode (see MOUSE.ASM).

HEM_VMode	PROC	FAR

		mov	ah,0 		;service 0, set video mode
		mov	al,006h		;640 * 200, 2 colour
		int	010h		;BIOS

		call	ResetMouse

		mov	ax,WSDATA    	;system memory work screen
		mov	WorkScrPtr,ax
		mov	ax,HEM_REAL_SCR
		mov	RealScrPtr,ax

		ret

HEM_VMode	ENDP

GCODE		ENDS

;============================================================================

		END


