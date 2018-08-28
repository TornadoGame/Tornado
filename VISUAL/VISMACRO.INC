;****************************************************************************
;*
;* VISMACRO.INC
;*
;* 07.01.1992 - KJB
;*
;****************************************************************************

;* CALC_SEC_INDEX - calc SectorTable[] record index
;*
;* pass: al = sector number
;* ret : bx = SectorTable[] record index
;* kill: flags

CALC_SEC_INDEX	MACRO

		mov	bl,al
		xor	bh,bh
		REPT	2     		;sector number * 4
		shl	bx,1
		ENDM

		ENDM

;----------------------------------------------------------------------------

;* CALC_SEC_PTR - calc SectorTable[] record pointer
;*
;* pass: al = sector number
;* ret : bx = SectorTable[] record pointer
;* kill: flags

CALC_SEC_PTR	MACRO

		CALC_SEC_INDEX

		add	bx,OFFSET SectorTable

		ENDM

;----------------------------------------------------------------------------

;* COPY_VP - copy VIEWPOINT data black
;*
;* pass: source ptr
;*       dest ptr
;* ret : dest[] = source[]
;* kill: cx, si, di

COPY_VP		MACRO	dest,source

		IFDIFI	<source>,<si>
		mov	si,OFFSET source
		ENDIF

		IFDIFI	<dest>,<di>
		mov	di,OFFSET dest
		ENDIF

		mov	cx,VIEW_REC_SIZE/2
		rep	movsw

		ENDM

;----------------------------------------------------------------------------

;* MOVEXY - update viewpoint x, y position
;*
;* pass: VP_PTR -> VIEWPOINT data block ([bx], [si], [di] or an immediate offset)
;*       xadd (register)
;*	 yadd (register)
;* ret : VP_XSEC, VP_YSEC, VP_XFT, VP_YFT
;* kill: xadd, yadd, flags
;*
;* examples:	MOVEXY	TMP_VIEW,cx,bx			;direct
;*
;*		MOVEXY	[si],cx,bx			;indirect

MOVEXY		MACRO	VP_PTR,xadd,yadd
		LOCAL	MvXY1,MvXY2,MvXY3,MvXY4

;* update xsec, xft

		add	xadd,VP_PTR.VP_XFT	;x + xadd
		cmp	xadd,8192		;change sector?
		jl	MvXY1			;no ->
		sub	xadd,16384
		inc	VP_PTR.VP_XSEC

MvXY1:		cmp	xadd,-8192		;change sector?
		jge	MvXY2			;no ->
		add	xadd,16384
		dec	VP_PTR.VP_XSEC

MvXY2:		mov	VP_PTR.VP_XFT,xadd

;* update ysec, yft

		add	yadd,VP_PTR.VP_YFT	;y + yadd
		cmp	yadd,8192 		;change sector?
		jl	MvXY3			;no ->
		sub	yadd,16384
		dec	VP_PTR.VP_YSEC

MvXY3:		cmp	yadd,-8192		;change sector?
		jge	MvXY4			;no ->
		add	yadd,16384
		inc	VP_PTR.VP_YSEC

MvXY4:		mov	VP_PTR.VP_YFT,yadd

		ENDM

