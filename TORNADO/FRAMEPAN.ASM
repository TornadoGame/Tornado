;****************************************************************************
;*
;* FRAMEPAN.ASM
;*
;* Canopy frame panel driver.
;*
;* 30.01.1992 - KJB
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	LoadFramePan
		PUBLIC	UpdateFrame

		EXTRN	BlockFill:FAR
		EXTRN	DrawIronWork:FAR

		EXTRN	IronWork:BYTE

;============================================================================

		INCLUDE	\VISUAL\PALETTES.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

DATA		ENDS

;============================================================================

PANCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:PANCODE
		ASSUME DS:DATA

;* LoadFramePan - load canopy frame panel (any screen mode)
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

LoadFramePan	PROC	NEAR

		mov	al,COL_BLACK
		mov	bl,192
		mov	bh,199
		mov	cx,0
		mov	dx,319
		call	BlockFill

		ret

LoadFramePan	ENDP

;----------------------------------------------------------------------------

;* UpdateFrame - update canopy frame panel
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

UpdateFrame	PROC	NEAR

		test	IronWork,1	;ironwork shown?
		jz	@F		;no ->

		call	DrawIronWork

@@:		ret

UpdateFrame	ENDP

PANCODE		ENDS

;============================================================================

		END

