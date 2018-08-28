;****************************************************************************
;*
;* CRATERS.ASM
;*
;* Crater creator.
;*
;* 22.10.1992 - KJB
;* 28.01.1993 - KJB - Heading added to craters.
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	MakeCrater

		PUBLIC	ScanCraters

		PUBLIC	CraterNum
		PUBLIC	CraterBuffer

		EXTRN	DrawMobile:NEAR

;============================================================================

		INCLUDE	VISDATA.INC
		INCLUDE	MOBLIST.INC
		
;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

NextCraterPtr	DW	OFFSET CraterBuffer

CraterNum	DB	0		;CRATER_NULL
		DB	MOB_CRATER1M	;CRATER_SIZE1
		DB	MOB_CRATER2M 	;CRATER_SIZE2
		DB	MOB_HEAVE	;CRATER_HEAVE
		DB	MOB_CANCRAT	;CRATER_SHELL

TMP_MOB		MOBILE <>
TMP_VIEW	VIEWPOINT <>
		
DATA		ENDS

;============================================================================

CRATERDATA 	SEGMENT PARA PUBLIC 'DATA'

;* cyclic buffer for craters

CraterBuffer	LABEL	CRATER

		CRATER	NUM_CRATERS DUP(<>)

CraterBufEnd	LABEL	CRATER

CRATERDATA  	ENDS

;============================================================================

VISCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:VISCODE
		ASSUME DS:DATA

;* MakeCrater
;*
;* pass: al = crater type (see VISDATA.INC)
;*       si -> VIEWPOINT <>
;* ret : nothing
;* kill: assume all
;*
;* note: Assume that a surface check has been applied before calling this
;*       routine and that the crater is to be placed on suitable ground.

MakeCrater	PROC	FAR

;--------------------------------
;* place crater at given position
;--------------------------------

		mov	dx,CRATERDATA
		mov	es,dx

		mov	di,NextCraterPtr

		mov	ES:[di].CRATER_TYPE,al

		mov	ES:[di].CRATER_ANIM,6	;init 5 stages + 1

		mov	ax,[si].VP_XSEC
		mov	ES:[di].CRATER_XSEC,ax

		mov	ax,[si].VP_YSEC
		mov	ES:[di].CRATER_YSEC,ax

		mov	ax,[si].VP_XFT
		mov	ES:[di].CRATER_XFT,ax

		mov	ax,[si].VP_YFT
		mov	ES:[di].CRATER_YFT,ax

;* (note: Assume that zft < 65536ft)

		mov	ax,WORD PTR [si].VP_ZFT_LO
		mov	ES:[di].CRATER_ZFT,ax

		mov	ax,WORD PTR [si].VP_HDG
		mov	ES:[di].CRATER_HDG,ax

		mov	dx,DATA
		mov	es,dx

;-------------------
;* update "next" ptr
;-------------------

		add	di,CRATER_REC_SIZE

		cmp	di,OFFSET CraterBufEnd	;end of buffer?
		jb	@F			;no ->

		mov	di,OFFSET CraterBuffer

@@:		mov	NextCraterPtr,di

		ret

MakeCrater	ENDP

;----------------------------------------------------------------------------

;* ScanCraters - scan crater buffer and draw craters
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all
;*
;* note: Craters are low priority objects and could possibly clog the object
;*	 buffer. Therefore call this routine "later on" in the visual drawing
;*	 order.

ScanCraters	PROC	NEAR

		mov	cx,NUM_CRATERS

		mov	si,OFFSET CraterBuffer

;-----------
;* scan loop
;-----------

CraterLoop:    	push	cx

;* make temporary mobile and viewpoint data blocks for crater

		mov	ax,CRATERDATA
		mov	es,ax

		mov	al,ES:[si].CRATER_TYPE
		cmp	al,CRATER_NULL
		jz	DoneCraters

		mov	bx,OFFSET CraterNum
		xlat
		mov	TMP_MOB.MOB_NUM,al

		mov	TMP_MOB.MOB_TYPE,OTYPE_MOBILE1

		mov	al,ES:[si].CRATER_ANIM
		test	al,al			;anim already zero?
		jz	@F			;yes ->
		dec	al			;next anim sequence
		mov	ES:[si].CRATER_ANIM,al

@@:		mov	TMP_MOB.MOB_ANIM,al

;* (note: MOB_LINK_PTR is not required and defaults to -1)

		mov	ax,ES:[si].CRATER_XSEC
		mov	TMP_VIEW.VP_XSEC,ax

		mov	ax,ES:[si].CRATER_YSEC
		mov	TMP_VIEW.VP_YSEC,ax

		mov	ax,ES:[si].CRATER_XFT
		mov	TMP_VIEW.VP_XFT,ax

		mov	ax,ES:[si].CRATER_YFT
		mov	TMP_VIEW.VP_YFT,ax

;* (note: VP_ZFT_HI defaults to 0)

		mov	ax,ES:[si].CRATER_ZFT
		mov	WORD PTR TMP_VIEW.VP_ZFT_LO,ax

		mov	ax,ES:[si].CRATER_HDG
		mov	TMP_VIEW.VP_HDG,ax

		xor	ax,ax
		mov	TMP_VIEW.VP_PITCH,ax
		mov	TMP_VIEW.VP_ROLL,ax

		mov	ax,DATA
		mov	es,ax

;* draw crater

		push	si
		mov	si,OFFSET TMP_MOB
		call	DrawMobile
		pop	si

		add	si,CRATER_REC_SIZE

		pop	cx
		loop	CraterLoop

		ret

;-------------------------------------
;* early out, tidy up before returning
;-------------------------------------

DoneCraters:	mov	ax,DATA
		mov	es,ax

		pop	cx

		ret

ScanCraters	ENDP

VISCODE		ENDS

;============================================================================

		END

