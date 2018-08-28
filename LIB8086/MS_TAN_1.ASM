;****************************************************************************
;*
;* MS_TAN_1.ASM
;*
;* 13.07.1989 - KJB
;*
;* TAN MSprite Data
;* ----------------
;*
;* If you add more TAN MSprite data files (in case this file gets too long)
;* then call the files MS_TAN_2.ASM, MS_TAN_3.ASM etc.
;*
;* MS_TAN_1 MUST be the first MS_TAN_? file in the link list as the data at
;* the start of the segment is position dependant (for overlays).
;*
;* The uninitialized sprites have the mask and pattern data combined followed
;* by a buffer of zeros into which the pattern will be placed before
;* interleaving. This improves the compression of the program data.
;*
;* The EGA sprite data is generated from this data.
;*
;* The EGA pattern data is copied from system memory into the EGA card.
;* However, the EGA mask data is left in the system memory (overwrites the
;* TAN data).
;*
;* Sometimes it is useful to use MSprite data as SSprites (ie. for very large
;* sprites, which look ok on byte boundaries, but would take up too much room
;* with the extra shifted data required. Therefore the MSprite header data is
;* the same as the SSprite data.
;*
;* The routine which converts MSprites to SSprites is BSprite (block sprite).
;*
;* The x, y offsets are ignored by MSprite but they are used by BSprite.
;*
;* Format of Physical Sprite Data (before initialization)
;* ------------------------------------------------------
;*
;* 	DW	width	       		;width in bytes
;*	DW	depth	
;*      DW	size = width * depth
;* 	DW	x offset		;x offset to top left hand corner
;*	DW	y offset		;y offset to top left hand corner
;*      DW	mask colour
;*	DW	0
;*	DW	0
;*
;*	DB	mask and pattern data combined
;*
;*      DB	width*depth DUP(0)	;buffer for extracted pattern data
;*
;* Format of TAN Physical Sprite Data (after initialization)
;* ---------------------------------------------------------
;*
;* 	DW	width	       		;width in bytes
;*	DW	depth			
;*      DW	size = width * depth
;* 	DW	x offset		;x offset to top left hand corner
;*	DW	y offset		;y offset to top left hand corner
;*      DW	mask colour
;*	DW	0
;*	DW	0
;*
;*	DB	mask,pattern,mask etc.
;*
;* Format of EGA Physical Sprite Data (after initialization)
;* ---------------------------------------------------------
;*
;*      new width = width / 4 + 1 if remainder
;*
;* 	DW	new width      		;width in bytes
;*	DW	depth			
;*      DW	size = new width * depth
;* 	DW	x offset		;x offset to top left hand corner
;*	DW	y offset		;y offset to top left hand corner
;*      DW	mask colour
;*	DW	0			;EGA page
;*	DW	0			;EGA page offset
;*
;*      DB	mask data
;*
;*      TAN data converted to EGA format and stored in EGA card memory.
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	MSpriteID
		PUBLIC	MSpriteList

;============================================================================

MSPRDATA  	SEGMENT PARA PUBLIC 'DATA'

;==================================
;* START OF POSITION DEPENDANT DATA
;==================================

;* segment identifier (must be 16 bytes long)

MSpriteID	DB	"TAN MSprite DATA"

MSpriteList	LABEL	WORD
		DW	-1			;list terminator

;================================
;* END OF POSITION DEPENDANT DATA
;================================

MSPRDATA 	ENDS

;============================================================================

		END

