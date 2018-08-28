;****************************************************************************
;*
;* QS_TAN_1.ASM
;*
;* 13.07.1989 - KJB
;*
;* TAN QSprite Data
;* ----------------
;*
;* If you add more TAN QSprite data files (in case this file gets too long)
;* then call the files QS_TAN_2.ASM, QS_TAN_3.ASM etc.
;*
;* QS_TAN_1 MUST be the first QS_TAN_? file in the link list as the data at
;* the start of the segment is position dependant (for overlays).
;* 
;* The EGA sprite data is generated from this data.
;*
;* The EGA pattern data is copied from system memory into the EGA card.
;*
;* Note that the TAN QSprite data width is always a multiple of 8 pixels.
;* This is for compatibility with the EGA card.
;*
;* Format of TAN Physical Sprite Data (no initialization required)
;* ---------------------------------------------------------------
;*
;* 	DW	width	       		;width in bytes
;*	DW	depth			
;*	DW	0
;*	DW	0
;*
;*	DB	pattern,pattern etc.
;*
;* Format of EGA Physical Sprite Data (after initialization)
;* ---------------------------------------------------------
;*
;* 	DW	width / 4      		;width in bytes
;*	DW	depth			
;*	DW	0			;EGA page
;*	DW	0			;EGA page offset
;*
;*	DB	pattern,pattern etc.	;TAN data intact
;*
;*      TAN data converted to EGA format and stored in EGA card memory.
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	QSpriteID
		PUBLIC	QSpriteList

		PUBLIC	CloseSymbol

;============================================================================

QSPRDATA  	SEGMENT PARA PUBLIC 'DATA'

;==================================
;* START OF POSITION DEPENDANT DATA
;==================================

;* segment identifier (must be 16 bytes long)

QSpriteID	DB	"TAN QSprite DATA"

QSpriteList	LABEL	WORD
CloseSymbol	DW	OFFSET _CloseSymbol	;LIB_TAN.QS
		DW	-1			;list terminator

;================================
;* END OF POSITION DEPENDANT DATA
;================================

		INCLUDE	\LIB8086\LIB_TAN.QS

QSPRDATA 	ENDS

;============================================================================

		END

