;****************************************************************************
;*
;* MOBDRAW.ASM
;*
;* Mobile object drawing routines.
;*
;* 22.03.1991 - KJB
;* 04.02.1992 - KJB - DrawMobile modified to accept MOBILE data block.
;* 16.03.1992 - KJB - CloudsEnabled test removed.
;* 22.06.1992 - KJB - Pass parameters modified.
;* 07.07.1992 - KJB - Mobile on bridge sort added. 
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	DrawMobile

		EXTRN	CalcEyePosition:NEAR
		EXTRN	ObjectDistSort1:NEAR
		EXTRN	ObjectDistSort2:NEAR
		EXTRN	ObjectDistSort3:NEAR
		EXTRN	ObjectDistSort4:NEAR

		EXTRN	CloudBase:DWORD
		
		EXTRN	CloudDepth:WORD

;============================================================================

		INCLUDE	VISEXTRN.INC
		INCLUDE	VISDATA.INC
		INCLUDE	\LIB8086\USEFUL.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

Temp1		DW	0
Temp2		DW	0

		DW	-16384
SectorAdjust	DW	0
		DW	+16384

DATA		ENDS

;============================================================================

VISCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:VISCODE
		ASSUME DS:DATA

;* DrawMobile - test if mobile object is visible, calculate position and
;*              place in object buffer
;*
;* pass: si -> MOBILE data block +
;*             VIEWPOINT data block
;*       V_VIEW
;*       ObjectBufPtr
;* ret : cf = 0: object visible
;*       cf = 1: object non-visible
;*       ObjectBufPtr
;* kill: assume all (except cf)

FailMobile	LABEL	NEAR

		stc			;cf = 1 = object non-visible
		ret

DrawMobile	PROC	NEAR

;* any room left in object buffer?

		mov	ax,ObjectBufPtr
		cmp	ax,OFFSET ObjectBufEnd
		je	FailMobile	;no room ->

;* pick up parameters from MOBILE data block

		mov	al,MOB_TYPE[si]
		mov	ah,MOB_NUM[si]
		mov	dl,MOB_ANIM[si]

		mov	Temp1,ax
		mov	Temp2,dx

		add	si,MOB_REC_SIZE	;si -> VIEWPOINT data block

;* delta x sec = obj x sec - vp x sec

		mov	ax,VP_XSEC[si]
		sub	ax,V_VIEW.VP_XSEC

		mov	di,ax

;* if abs(delta x sec) > 1 then object is non-visible

		ABSV	ax
		cmp	ax,1	  	;object in current or adjacent sector?
		ja	FailMobile	;no ->

;* delta y sec = obj y sec - vp y sec

		mov	ax,VP_YSEC[si]
		sub	ax,V_VIEW.VP_YSEC

		mov	bx,ax

;* if abs(delta y sec) > 1 then object is non-visible

		ABSV	ax
		cmp	ax,1	  	;object in current or adjacent sector?
		ja	FailMobile	;no ->

;* x rel = obj xft - vp xft + (delta x sec * 16384)

		shl	di,1		;-2, 0, +2

		mov	ax,VP_XFT[si]
		sub	ax,V_VIEW.VP_XFT
		add	ax,SectorAdjust[di]

		cmp	ax,-16384	;in range?
		jl	FailMobile	;no ->
		cmp	ax,+16383	;in range?
		jg	FailMobile	;no ->

		mov	bp,ax		;bp = x rel

;* y rel = obj yft - vp yft + (-(delta y sec) * 16384)

		shl	bx,1		;-2, 0, +2

		mov	ax,VP_YFT[si]
		sub	ax,V_VIEW.VP_YFT
		sub	ax,SectorAdjust[bx]

		cmp	ax,-16384	;in range?
		jl	FailMobile	;no ->
		cmp	ax,+16383	;in range?
		jg	FailMobile	;no ->

		mov	bx,ax		;bx = y rel

;* z rel = obj zft - vp zft

;* //MOD// 06.11.1992 - Altitude compression applied to z rel. This cures
;*	                problems such as trains drifting off railways etc.
;*
;*			The same compression used for ZScaled is applied:-
;*
;*			   if abs(z rel) > 10000 then 
;*			      abs(z rel) = abs(z rel) / 4 + 7500
;*			   endif

		mov	cx,WORD PTR VP_ZFT_LO[si]
		mov	ax,WORD PTR VP_ZFT_HI[si]

		sub	cx,WORD PTR V_VIEW.VP_ZFT_LO
		sbb	ax,WORD PTR V_VIEW.VP_ZFT_HI

		cwd			;dx = sign(z rel)

		jns	@F

		NEG32	ax,cx

;* compress z rel (assume abs(z rel) <= 100,000)

@@:		test	ax,ax		;abs(z rel) > 65535?
		jnz	@F		;yes ->

		cmp	cx,10000	;abs(z rel) > 10000?
		jbe	ZRelOk		;no ->

@@:		REPT	2		;abs(z rel) / 4
		shr	ax,1
		rcr	cx,1
		ENDM

		add	cx,7500		;abs(z rel) / 4 + 7500

		cmp	cx,+16383	;in range?
		ja	FailMobileLink	;no ->

ZRelOk:		xor	cx,dx		;restore sign
		sub	cx,dx

		mov	ax,bp		;ax = x rel

		jmp	CalcPos

;---------------------------------
FailMobileLink:	jmp	FailMobile
;---------------------------------

;* calc eye co-ords

CalcPos:	push	si
		call	CalcEyePosition
		pop	si

;* check y pos in range (prevent dist sort overflow)

		cmp	bx,-1024	;in range (approx 512 * sqrt(2))?
		jl	FailMobileLink	;no ->
		cmp	bx,+16383	;in range?
		jg	FailMobileLink	;no ->

;* check x pos in range

		cmp	ax,-16384	;in range?
		jl	FailMobileLink	;no ->
		cmp	ax,+16383	;in range?
		jg	FailMobileLink	;no ->

;* check z pos in range

		cmp	cx,-16384	;in range?
		jl	FailMobileLink	;no ->
		cmp	cx,+16383	;in range?
		jg	FailMobileLink	;no ->

;* sort object data

		mov	di,ObjectBufPtr

		mov	OBJ_XPOS[di],ax
		mov	OBJ_YPOS[di],bx
		mov	OBJ_ZPOS[di],cx

		mov	ax,VP_HDG[si]
		mov	OBJ_HDG[di],ax

		mov	ax,VP_PITCH[si]
		mov	OBJ_PITCH[di],ax

		mov	ax,VP_ROLL[si]
		mov	OBJ_ROLL[di],ax

		mov	ax,Temp1
		mov	OBJ_TYPE[di],al
		mov	OBJ_NUM[di],ah
		
		mov	ax,Temp2
		mov	OBJ_ANIM_FLAGS[di],al

;* sort object distance (select distance sort wrt clouds)

 	     	mov	ax,WORD PTR VP_ZFT_LO[si]
		mov	dx,WORD PTR VP_ZFT_HI[si]

		sub	ax,WORD PTR CloudBase
		sbb	dx,WORD PTR CloudBase+2

		jb	BelowClouds	;below clouds ->

		sub	ax,CloudDepth
		sbb	dx,0

		jb	InClouds	;in clouds ->

AboveClouds:	mov	dx,bx
		call	ObjectDistSort3
		jmp	Sorted

InClouds:	mov	dx,bx
		call	ObjectDistSort2
		jmp	Sorted

BelowClouds:	mov	dx,bx

		cmp	OBJ_TYPE[di],OTYPE_MOBILE4	;mobile on bridge?
		je	@F				;yes ->

		call	ObjectDistSort1
		jmp	Sorted

@@:		call	ObjectDistSort4

Sorted:		add	di,OBJ_REC_SIZE

		mov	ObjectBufPtr,di	;update object buffer pointer
		
		clc			;cf = 0 = object visible
		ret

DrawMobile	ENDP

VISCODE		ENDS

;============================================================================

		END

