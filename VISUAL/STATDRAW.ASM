;****************************************************************************
;*
;* STATDRAW.ASM
;*
;* Draw "static" mobiles in sector.
;*
;* 31.08.1992 - KJB
;*
;* Format of sector "static" mobile list:-
;*
;*		STATMOB	<obj num, anim flags, etc.>
;*		STATMOB	<obj num, anim flags, etc.>
;*		..	   ..         ..       ..
;*		STATMOB	<obj num, anim flags, etc.>
;*		DB	-1		;list terminator
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	DrawStatMobiles

		EXTRN	DrawMobile:NEAR

		EXTRN	MobSectorTable:WORD

		EXTRN	MobileLayer1:BYTE

;============================================================================

		INCLUDE	VISEXTRN.INC
		INCLUDE	VISDATA.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

TMP_MOB		MOBILE <>
TMP_VIEW	VIEWPOINT <>
		
DATA		ENDS

;============================================================================

MSECDATA1	SEGMENT PARA PUBLIC 'DATA'

MSECDATA1	ENDS

;============================================================================

VISCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:VISCODE
		ASSUME DS:DATA

;* DrawStatMobiles - scan sector for "static" mobile objects and place in object buffer
;*
;* pass: si = x sector offset (-1, 0, +1)
;*       di = y sector offset (-1, 0, +1)
;*       MapIndex
;*       MobileLayer1
;*	 V_VIEW
;* ret : ObjectBufPtr
;* kill: assume all
;*
;* note: Only call this routine from a 3 * 3 sector scan and if the sector is
;*       on the map (not in no man's land).

DrawStatMobiles	PROC	NEAR

		mov	bp,MapIndex
		mov	bl,MobileLayer1[bp]

		test	bl,bl		;null sector?
		jz	NullSector	;yes ->

;* sort sector position

		mov	ax,V_VIEW.VP_XSEC
		add	ax,si
		mov	TMP_VIEW.VP_XSEC,ax
	
		mov	ax,V_VIEW.VP_YSEC
		add	ax,di
		mov	TMP_VIEW.VP_YSEC,ax
	
;* sort sector list ptr

		xor	bh,bh
		shl	bx,1		;*2 word index

		mov	si,MobSectorTable[bx]

;* "static" mobile draw loop

ScanLoop:  	mov	ax,MSECDATA1
		mov	es,ax

		mov	al,ES:STAT_NUM[si]
		cmp	al,-1		;end of list?
		je	ExitSector

		mov	TMP_MOB.MOB_NUM,al

		mov	TMP_MOB.MOB_TYPE,OTYPE_MOBILE1

		mov	al,ES:STAT_ANIM[si]
		mov	TMP_MOB.MOB_ANIM,al

;* (note: MOB_LINK_PTR is not required and defaults to -1)

		mov	ax,ES:STAT_XFT[si]
		mov	TMP_VIEW.VP_XFT,ax

		mov	ax,ES:STAT_YFT[si]
		mov	TMP_VIEW.VP_YFT,ax

		mov	ax,ES:STAT_HDG[si]
		mov	TMP_VIEW.VP_HDG,ax

		mov	ax,DATA
		mov	es,ax

		push	si
		mov	si,OFFSET TMP_MOB
		call	DrawMobile
		pop	si

		add	si,STAT_REC_SIZE

		jmp	ScanLoop

ExitSector:	mov	ax,DATA
		mov	es,ax

NullSector:	ret

DrawStatMobiles	ENDP

VISCODE		ENDS

;============================================================================

		END

