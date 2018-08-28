;****************************************************************************
;*
;* QS_CGA_1.ASM
;*
;* 27.06.1989 - KJB
;*
;* CGA QSprite Data
;* ----------------
;*
;* If you add more CGA QSprite data files (in case this file gets too long)
;* then call the files QS_CGA_2.ASM, QS_CGA_3.ASM etc.
;*
;* QS_CGA_1 MUST be the first QS_CGA_? file in the link list as the data at
;* the start of the segment is position dependant (for overlays).
;* 
;* Format of Physical Sprite Data (no initialization required)
;* -----------------------------------------------------------
;*
;* 	DW	width	       		;width in bytes
;*	DW	depth			
;*
;*	DB	pattern,pattern etc.
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

QSpriteID	DB	"CGA QSprite DATA"

QSpriteList	LABEL	WORD
CloseSymbol	DW	OFFSET _CloseSymbol	;LIB_CGA.QS
		DW	-1			;list terminator

;================================
;* END OF POSITION DEPENDANT DATA
;================================

		INCLUDE	\LIB8086\LIB_CGA.QS

QSPRDATA 	ENDS

;============================================================================

		END

