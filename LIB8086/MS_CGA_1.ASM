;****************************************************************************
;*
;* MS_CGA_1.ASM
;*
;* 27.06.1989 - KJB
;*
;* CGA MSprite Data
;* ----------------
;*
;* If you add more CGA MSprite data files (in case this file gets too long)
;* then call the files MS_CGA_2.ASM, MS_CGA_3.ASM etc.
;*
;* MS_CGA_1 MUST be the first MS_CGA_? file in the link list as the data at
;* the start of the segment is position dependant (for overlays).
;*
;* Sometimes it is useful to use MSprite data as SSprites (ie. for very large
;* sprites, which look ok on byte boundaries, but would take up too much room
;* with the extra shifted data required. Therefore the MSprite header data is
;* the same as the SSprite data.
;*
;* The normal value for x, y offset is 0, but MSprites which are used as 
;* SSprites may need these values to be set.
;* 
;* The routine which converts MSprites to SSprites is BSprite (block sprite).
;*
;* Format of Physical Sprite Data (before initialization)
;* ------------------------------------------------------
;*
;*	DW	width			;width in bytes
;* 	DW	depth
;* 	DW	x offset		;x offset to top left hand corner
;*	DW	y offset		;y offset to top left hand corner
;*	DW	0
;*	DW	0
;*
;*	DB	mask,mask etc.		;mask data
;*
;*	DB	pattern,pattern etc.	;pattern data
;*
;* Format of Physical Sprite Data (after initialization)
;* -----------------------------------------------------
;*
;* 	DW	width	       		;width in bytes
;*	DW	depth			
;* 	DW	x offset		;x offset to top left hand corner
;*	DW	y offset		;y offset to top left hand corner
;*	DW	shift 0 pointer		;pointer to 0 pixel displacement data
;*	DW	shift 2 pointer		;pointer to 0 pixel displacement data
;*
;*	DB	mask,pattern,mask etc.
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

MSpriteID	DB	"CGA MSprite DATA"

MSpriteList	LABEL	WORD
		DW	-1			;list terminator

;================================
;* END OF POSITION DEPENDANT DATA
;================================

MSPRDATA 	ENDS

;============================================================================

		END

