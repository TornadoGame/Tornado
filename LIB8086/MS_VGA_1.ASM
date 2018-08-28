;****************************************************************************
;*
;* MS_VGA_1.ASM
;*
;* 01.07.1991 - KJB
;*
;* VGA MSprite Data
;* ----------------
;*
;* If you add more VGA MSprite data files (in case this file gets too long)
;* then call the files MS_VGA_2.ASM, MS_VGA_3.ASM etc.
;*
;* MS_VGA_1 MUST be the first MS_VGA_? file in the link list as the data at
;* the start of the segment is position dependant (for overlays).
;*
;* VGA MSprites are exactly the same as SSprites (except they do not require
;* clipping and do not require shifted data). The MSprite header data is the
;* same as the SSprite header data. MSprites can be used as SSprites (ie. can
;* be clipped) if they are used in conjunction with the BSprite (block sprite)
;* routine.
;*
;* The x, y offsets are ignored by MSprite but they are used by BSprite.
;*
;* The uninitialized sprite pattern data is in a linear format (for better
;* compression), so the data must be interleaved to match the screen format
;* used.
;*
;* Note that the VGA MSprite data width is always a multiple of 4 pixels.
;*
;* Format of VGA Physical Sprite Data (before initialization)
;* ----------------------------------------------------------
;*
;* 	DW	width in bytes (/4)
;*	DW	depth			
;*	DW	size
;*	DW	x offset
;*	DW	y offset
;*	DB	mask colour
;*	DB	0 (padding)
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
;*	DW	x offset
;*	DW	y offset
;*	DB	mask colour
;*	DB	0 (padding)
;*
;*	DB	 p0, p4, p8,p12,p16,p20		;map 0 data
;*	DB	 p1, p5, p9,p13,p17,p21		;map 1 data
;*	DB	 p2, p6,p10,p14,p18,p22		;map 2 data
;*	DB	 p3, p7,p11,p15,p19,p23		;map 3 data
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

MSpriteID	DB	"VGA MSprite DATA"

MSpriteList	LABEL	WORD
		DW	-1			;list terminator

;================================
;* END OF POSITION DEPENDANT DATA
;================================

MSPRDATA 	ENDS

;============================================================================

		END

