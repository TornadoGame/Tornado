;****************************************************************************
;*
;* SS_CGA_1.ASM
;*
;* 27.06.1989 - KJB
;*
;* CGA SSprite Data
;* ----------------
;*
;* If you add more CGA SSprite data files (in case this file gets too long)
;* then call the files SS_CGA_2.ASM, SS_CGA_3.ASM etc.
;*
;* SS_CGA_1 MUST be the first SS_CGA_? file in the link list as the data at
;* the start of the segment is position dependant (for overlays).
;* 
;* Format of Physical Sprite Data (before initialization)
;* ------------------------------------------------------
;*
;* 	DW	width	       		;width in bytes (inc. shift into byte)
;*	DW	depth	
;* 	DW	x offset		;x offset to top left hand corner
;*	DW	y offset		;y offset to top left hand corner
;*	DW	0
;*	DW	0
;*
;*	DB	mask,mask etc.		;shift 0 mask data
;*
;*	DB	pattern,pattern etc.  	;shift 0 pattern data
;*
;*      DB	width*depth*2 DUP(0)	;shift 2 data
;*
;* Format of Physical Sprite Data (after initialization)
;* -----------------------------------------------------
;*
;* 	DW	width	       		;width in bytes (inc. shift into byte)
;*	DW	depth			
;* 	DW	x offset		;x offset to top left hand corner
;*	DW	y offset		;y offset to top left hand corner
;*	DW	shift 0 pointer		;pointer to 0 pixel displacement data
;*	DW	shift 2 pointer		;pointer to 2 pixel displacement data
;*
;*	DB	mask,pattern,mask etc.	;shift 0 data
;*
;*	DB	mask,pattern,mask etc.	;shift 2 data
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

SSpriteID	DB	"CGA SSprite DATA"

SSpriteList	LABEL	WORD
StndPtr		DW	OFFSET _StndPtr  	;LIB_CGA.SS
Button0		DW	OFFSET _Button0		;LIB_CGA.SS
Button1		DW	OFFSET _Button1		;LIB_CGA.SS
		DW	-1			;list terminator

;================================
;* END OF POSITION DEPENDANT DATA
;================================

		INCLUDE	\LIB8086\LIB_CGA.SS

SSPRDATA 	ENDS

;============================================================================

		END

