;****************************************************************************
;*
;* SS_TAN_1.ASM
;*
;* 13.07.1989 - KJB
;*
;* TAN SSprite Data
;* ----------------
;*
;* If you add more TAN SSprite data files (in case this file gets too long)
;* then call the files SS_TAN_2.ASM, SS_TAN_3.ASM etc.
;*
;* SS_TAN_1 MUST be the first SS_TAN_? file in the link list as the data at
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
;* TAN data). Unfortunately, some EGA masks require more data space than the
;* TAN data provides. In these cases, an extra buffer of zeros is placed
;* after the pattern buffer.
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
;*	DB	? DUP(0)		;extra buffer required for EGA masks
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
;*	DB	? DUP(0)		;extra buffer required for EGA masks
;*
;* Format of EGA Physical Sprite Data (after initialization)
;* ---------------------------------------------------------
;*
;*      new width = width / 4 + 1 if remainder + 1 for 'shift into' byte
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
;*      DB	shift 0 mask data
;*      DB	shift 2 mask data
;*      DB	shift 4 mask data
;*      DB	shift 6 mask data
;*
;*      TAN data converted to EGA format and stored in EGA card memory.
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	SSpriteID
		PUBLIC	SSpriteList

		PUBLIC	StndPtr
		PUBLIC	Button0
		PUBLIC	Button1

;============================================================================

SSPRDATA  	SEGMENT PARA PUBLIC 'DATA'

;==================================
;* START OF POSITION DEPENDANT DATA
;==================================

;* segment identifier (must be 16 bytes long)

SSpriteID	DB	"TAN SSprite DATA"

SSpriteList	LABEL	WORD
StndPtr		DW	OFFSET _StndPtr		;LIB_TAN.SS
Button0		DW	OFFSET _Button0		;LIB_TAN.SS
Button1		DW	OFFSET _Button1		;LIB_TAN.SS
		DW	-1			;list terminator

;================================
;* END OF POSITION DEPENDANT DATA
;================================

		INCLUDE	\LIB8086\LIB_TAN.SS

SSPRDATA 	ENDS

;============================================================================

		END

