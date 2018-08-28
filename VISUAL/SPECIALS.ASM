;****************************************************************************
;*
;* SPECIALS.ASM
;*
;* Draw ground features which require special routines.
;*
;* 15.07.1991 - KJB
;* 14.04.1992 - KJB - Reorganised to remove need for seperate subroutine
;*                    for each special.
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<
	
		PUBLIC	DrawSpecials

		PUBLIC	AIRFIELD_1
		PUBLIC	AIRFIELD_N
		PUBLIC	TOWN_1
		PUBLIC	TOWN_N

		EXTRN	DrawAirfield:NEAR
		EXTRN	DrawTown:NEAR

		EXTRN	SpecialLayer1:BYTE

;============================================================================

		INCLUDE	VISEXTRN.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

AIRFIELD_1	EQU	1
AIRFIELD_N	EQU	8

TOWN_1		EQU	16
TOWN_N		EQU	28

DATA		ENDS

;============================================================================

VISCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:VISCODE
		ASSUME DS:DATA

;* DrawSpecials - draw special ground features
;*
;* pass: MapIndex
;*       SpecialLayer1[]
;* ret : nothing
;* kill: assume all

DrawSpecials	PROC	NEAR

		mov	bp,MapIndex
		mov	al,SpecialLayer1[bp]
		test	al,al		;null?
		jz	ExitSpecials	;yes ->

;----------------
;* draw airfields
;----------------

		cmp	al,AIRFIELD_N	;airfield?
		ja	@F		;no ->

		call	DrawAirfield

		jmp	ExitSpecials

;------------
;* draw towns
;------------

@@:		cmp	al,TOWN_N	;town?
		ja	ExitSpecials	;no ->

		call	DrawTown

ExitSpecials:	ret

DrawSpecials	ENDP

VISCODE		ENDS

;============================================================================

		END

