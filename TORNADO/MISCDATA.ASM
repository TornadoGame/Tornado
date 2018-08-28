;****************************************************************************
;*
;* MISCDATA.ASM
;*
;* Miscellaneous gameplay data.
;*
;* 16.02.1993 - KJB
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	MiscDataSize

		PUBLIC	MiscData
		PUBLIC	SctrGameLayer1
		PUBLIC	EWRFloorLayer1
		PUBLIC	MobRadarLayer1
		PUBLIC	RadarTable
		PUBLIC	RadarLists

;============================================================================

		INCLUDE	MAINDATA.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

MiscDataSize	DW	OFFSET EndMiscData-OFFSET MiscData

DATA		ENDS

;============================================================================

STACK		SEGMENT PARA PUBLIC 'STACK'
		ASSUME SS:STACK

;-----------------------------------------------------------------------
;* NOTE: Data is stored in the stack segment due to lack of space in the
;*       main DATA segment. Using SS: override does not appear to add
;*       any additional cycles to i286 and i386 timings. i486 has one
;*       extra cycle if the instruction is in cache. Therefore, use SS:
;*       override (don't worry about always using [bp]).
;-----------------------------------------------------------------------

;---------------------------
MiscData	LABEL	BYTE
;---------------------------

;* sector gameplay flags (see MAINDATA.INC)

SctrGameLayer1	DB	32*32 DUP(0)

;* EWR floor data (see MAINDATA.INC)

EWRFloorLayer1	DB	32*32 DUP(0)

;* radar index (1 .. 255 = index, 0 = null)

MobRadarLayer1	DB	32*32 DUP(0)

;* radar list pointers

RadarTable	RADARS	256 DUP(<>)

;* radar lists (enough space for worst case - each radar in a unique sector)

RadarLists	DW	(NUM_SAM_AAA)*2*2 DUP(-1)

;---------------------------
EndMiscData	LABEL	BYTE
;---------------------------

STACK		ENDS

;============================================================================

		END

