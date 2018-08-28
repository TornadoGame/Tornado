;****************************************************************************
;*
;* SS_VGA_1.ASM
;*
;* 08.01.1991 - KJB
;*
;* VGA SSprite Data
;* ----------------
;*
;* If you add more VGA SSprite data files (in case this file gets too long)
;* then call the files SS_VGA_2.ASM, SS_VGA_3.ASM etc.
;*
;* SS_VGA_1 MUST be the first SS_VGA_? file in the link list as the data at
;* the start of the segment is position dependant (for overlays).
;*
;* The uninitialized sprite pattern data is in a linear format (for better
;* compression), so the data must be interleaved to match the screen format
;* used.
;*
;* Note that the VGA SSprite data width is always a multiple of 4 pixels.
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
;*	DB	(width + 1) * depth * 4 DUP(mask colour)
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
;*	DB	msk, p2, p6,msk,p10,p14,msk,p18,p22	;map 0 data
;*	DB	msk, p3, p7,msk,p11,p15,msk,p19,p23	;map 1 data
;*	DB	 p0, p4,msk, p8,p12,msk,p16,p20,msk	;map 2 data
;*	DB	 p1, p5,msk, p9,p13,msk,p17,p21,msk	;map 3 data
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	SSpriteID
		PUBLIC	SSpriteList

		PUBLIC	HUDDigits

;============================================================================

SSPRDATA  	SEGMENT PARA PUBLIC 'DATA'

;==================================
;* START OF POSITION DEPENDANT DATA
;==================================

;* segment identifier (must be 16 bytes long)

SSpriteID	DB	"VGA SSprite DATA"

SSpriteList	LABEL	WORD

HUDDigits	LABEL	WORD

		DW	OFFSET _HUDDigit0_0	;HUDDIGIT.SS
		DW	OFFSET _HUDDigit0_1	;HUDDIGIT.SS
		DW	OFFSET _HUDDigit1_0	;HUDDIGIT.SS
		DW	OFFSET _HUDDigit1_1	;HUDDIGIT.SS
		DW	OFFSET _HUDDigit2_0	;HUDDIGIT.SS
		DW	OFFSET _HUDDigit2_1	;HUDDIGIT.SS
		DW	OFFSET _HUDDigit3_0	;HUDDIGIT.SS
		DW	OFFSET _HUDDigit3_1	;HUDDIGIT.SS
		DW	OFFSET _HUDDigit4_0	;HUDDIGIT.SS
		DW	OFFSET _HUDDigit4_1	;HUDDIGIT.SS
		DW	OFFSET _HUDDigit5_0	;HUDDIGIT.SS
		DW	OFFSET _HUDDigit5_1	;HUDDIGIT.SS
		DW	OFFSET _HUDDigit6_0	;HUDDIGIT.SS
		DW	OFFSET _HUDDigit6_1	;HUDDIGIT.SS
		DW	OFFSET _HUDDigit7_0	;HUDDIGIT.SS
		DW	OFFSET _HUDDigit7_1	;HUDDIGIT.SS
		DW	OFFSET _HUDDigit8_0	;HUDDIGIT.SS
		DW	OFFSET _HUDDigit8_1	;HUDDIGIT.SS
		DW	OFFSET _HUDDigit9_0	;HUDDIGIT.SS
		DW	OFFSET _HUDDigit9_1	;HUDDIGIT.SS
		DW	-1			;list terminator

;================================
;* END OF POSITION DEPENDANT DATA
;================================

		INCLUDE	VGA\SPRITES\HUDDIGIT.SS

SSPRDATA 	ENDS

;============================================================================

		END

