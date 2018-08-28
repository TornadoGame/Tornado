;****************************************************************************
;*
;* QS_VGA_1.ASM
;*
;* 01.07.1991 - KJB
;*
;* VGA QSprite Data
;* ----------------
;*
;* If you add more VGA QSprite data files (in case this file gets too long)
;* then call the files QS_VGA_2.ASM, QS_VGA_3.ASM etc.
;*
;* QS_VGA_1 MUST be the first QS_VGA_? file in the link list as the data at
;* the start of the segment is position dependant (for overlays).
;* 
;* The uninitialized sprite pattern data is in a linear format (for better
;* compression), so the data must be interleaved to match the screen format
;* used.
;*
;* Note that the VGA QSprite data width is always a multiple of 8 pixels.
;* This is for compatibility with the EGA card.
;*
;* Format of VGA Physical Sprite Data (before initialization)
;* ----------------------------------------------------------
;*
;* 	DW	width in bytes (/4)
;*	DW	depth			
;*	DW	size
;*
;*	DB	 p0, p1, p2, p3, p4, p5, p6, p7	;8w * 3d linear data
;*	DB	 p8, p9,p10,p11,p12,p13,p14,p15
;*	DB	p16,p17,p18,p19,p20,p21,p22,p23
;*
;* Format of VGA Physical Sprite Data (after initialization)
;* ---------------------------------------------------------
;*
;* 	DW	width in bytes (/4)
;*	DW	depth			
;*	DW	size
;*
;*	DB	 p0, p4, p8,p12,p16,p20		;map 0 data
;*	DB	 p1, p5, p9,p13,p17,p21		;map 1 data
;*	DB	 p2, p6,p10,p14,p18,p22		;map 2 data
;*	DB	 p3, p7,p11,p15,p19,p23		;map 3 data
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

QSpriteID	DB	"VGA QSprite DATA"

QSpriteList	LABEL	WORD
CloseSymbol	DW	OFFSET _CloseSymbol	;LIB_VGA.QS
		DW	-1			;list terminator

;================================
;* END OF POSITION DEPENDANT DATA
;================================

		INCLUDE	\LIB8086\LIB_VGA.QS

QSPRDATA 	ENDS

;============================================================================

		END

