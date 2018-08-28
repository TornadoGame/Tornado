;****************************************************************************
;*
;* SECDATA1.ASM
;*
;* Sector data.
;*
;* 14.03.1991 - KJB
;* 31.08.1992 - KJB - Data added for "static" ground mobiles.
;* 09.12.1992 - KJB - BuildSctrTables added.
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	BuildSctrTables

		PUBLIC	SectorTable
		PUBLIC	MobSectorTable

		PUBLIC	SectorDataStart
		PUBLIC	MSctrDataStart

		PUBLIC	SEC_TBL_SIZE
		PUBLIC	SEC_MAP_SIZE
		PUBLIC	MSEC_TBL_SIZE
		PUBLIC	MSEC_MAP_SIZE

;============================================================================

		INCLUDE	VISDATA.INC
		INCLUDE	GNDLIST.INC
		INCLUDE	FLTLIST.INC
		INCLUDE	MOBLIST.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'
		ASSUME DS:DATA

;-------------------------------
;* flat objects / ground objects
;-------------------------------

SEC_TBL_SIZE	EQU	256*SEC_REC_SIZE	;256 sectors * SEC_REC_SIZE

SectorTable	LABEL	BYTE

		INCLUDE	MAP\SECTORS\SECTABLE.INC

		DW	(SEC_TBL_SIZE-($-OFFSET SectorTable))/2 DUP(OFFSET NullObjList)

;-------------------------
;* "static" mobile objects
;-------------------------

MSEC_TBL_SIZE	EQU	256*2		;256 sectors

MobSectorTable	LABEL	BYTE

		INCLUDE	MAP\SECTORS\MSECTBLE.INC

		DW	(MSEC_TBL_SIZE-($-OFFSET MobSectorTable))/2 DUP(OFFSET NullObjList)

DATA		ENDS

;============================================================================

SECDATA1	SEGMENT PARA PUBLIC 'DATA'
		ASSUME DS:SECDATA1

SectorDataStart	LABEL	BYTE

SEC_MAP_SIZE	EQU	10000*4		;approx. 10,000 objects

		INCLUDE	MAP\SECTORS\OBSECDEF.INC

		DB	SEC_MAP_SIZE-($-OFFSET SectorDataStart) DUP(0)

SECDATA1	ENDS

;============================================================================

MSECDATA1	SEGMENT PARA PUBLIC 'DATA'
		ASSUME DS:MSECDATA1

MSctrDataStart	LABEL	BYTE

MSEC_MAP_SIZE	EQU	2000*STAT_REC_SIZE	;approx. 2,000 objects

		INCLUDE	MAP\SECTORS\MSECDEF.INC

		DB	MSEC_MAP_SIZE-($-OFFSET MSctrDataStart) DUP(0)

MSECDATA1	ENDS

;============================================================================

VISCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:VISCODE
		ASSUME DS:DATA

;* BuildSctrTables - initialize sector tables
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

BuildSctrTables	PROC	FAR

;----------------------------------------
;* scan sector data and build SectorTable
;----------------------------------------

		mov	cx,256			;expect data for 256 sectors

		mov	si,OFFSET SectorTable

		mov	di,OFFSET SectorDataStart

		mov	ax,SECDATA1
		mov	es,ax

InitSctrLoop:	mov	[si].SEC_OBJ_PTR,di	;object ptr

@@:		cmp	BYTE PTR ES:[di],-1	;end of list?
		je	@F			;yes ->
		add	di,4
		jmp	@B

@@:		inc	di			;skip terminator

		mov	[si].SEC_FLAT_PTR,di	;flat object ptr

@@:		cmp	BYTE PTR ES:[di],-1	;end of list?
		je	@F			;yes ->
		add	di,4
		jmp	@B

@@:		inc	di			;skip terminator

		add	si,SEC_REC_SIZE		;next table entry

		loop	InitSctrLoop

		mov	ax,DATA
		mov	es,ax

;-------------------------------------------
;* scan sector data and build MobSectorTable
;-------------------------------------------

		mov	cx,256			;expect data for 256 sectors

		mov	si,OFFSET MobSectorTable

		mov	di,OFFSET MSctrDataStart

		mov	ax,MSECDATA1
		mov	es,ax

InitMSctrLoop:	mov	[si],di			;static mobile ptr

@@:		cmp	ES:[di].STAT_NUM,-1	;end of list?
		je	@F			;yes ->
		add	di,STAT_REC_SIZE
		jmp	@B

@@:		add	di,2			;skip terminator and padding

		add	si,2			;next table entry

		loop	InitMSctrLoop

		mov	ax,DATA
		mov	es,ax

		ret

BuildSctrTables	ENDP

VISCODE		ENDS

;============================================================================

		END

