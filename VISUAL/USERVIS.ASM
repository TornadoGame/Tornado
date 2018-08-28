;****************************************************************************
;*
;* USERVIS.ASM
;*
;* User visual routine (visual breakout box).
;*
;* Customise the visual in this routine.
;*
;* 28.08.1991 - KJB
;* 22.06.1992 - KJB - New mobile object scan added.
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	UserVisual

		EXTRN	LocateMobiles:FAR

		EXTRN	DrawMobile:NEAR

;============================================================================

		INCLUDE	\VISUAL\VISEXTRN.INC
		INCLUDE	\VISUAL\VISDATA.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

DATA		ENDS

;============================================================================

VISCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:VISCODE
		ASSUME DS:DATA

;* UserVisual - customised visual routine
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

UserVisual	PROC	NEAR

;---------------------
;* draw mobile objects
;---------------------

;* for y sector offset = -1 to +1

		mov	cx,3		;y count
		mov	di,-1		;y sector offset

ScanYLoop:	push	cx
		push	di

;* for x sector offset = -1 to +1

		mov	cx,3		;x count
		mov	si,-1		;x sector offset

ScanXLoop:	push	cx
		push	si
		push	di

;* calc sector map co-ords

		mov	ax,V_VIEW.VP_XSEC
		add	ax,si		;x sec = vp x sec + x sec offset
		mov	dx,V_VIEW.VP_YSEC
		add	dx,di		;y sec = vp y sec + y sec offset

;* draw mobiles in sector (if any)

		call	LocateMobiles
		jc	SkipSector	;no mobiles located ->

MobLoop: 	cmp	si,-1		;list terminator?
		je	SkipSector	;yes ->

		push	si
		call	DrawMobile
		pop	si

		mov	si,MOB_LINK_PTR[si]

		jmp	MobLoop

;* next x sector

SkipSector:	pop	di
		pop	si
		pop	cx
		add	si,1		;x = x + 1
		loop	ScanXLoop

;* next y sector

		pop	di
		pop	cx
		add	di,1		;y = y + 1
		loop	ScanYLoop

		ret

UserVisual	ENDP

VISCODE		ENDS

;============================================================================

		END

