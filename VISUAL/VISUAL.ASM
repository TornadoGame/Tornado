;****************************************************************************
;*
;* VISUAL.ASM
;*
;* Top level 3D visual routine.
;*
;* 04.02.1991 - KJB
;* 16.03.1992 - KJB - CloudMode reorganized ("no clouds" condition removed).
;*                    Overcast flag added.
;* 17.01.1993 - KJB - MobileVisual added.
;* 03.04.1993 - KJB - RotateView added.
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	Visual
		PUBLIC	MobileVisual

		EXTRN	InitVisual:NEAR
		EXTRN	CalcAngles:NEAR
		EXTRN	CalcAFactors:NEAR
		EXTRN	RotateView:NEAR
		EXTRN	CalcSctrGrid:NEAR
		EXTRN	CalcObjGrid:NEAR
		EXTRN	CalcSctrOffsets:NEAR
		EXTRN	DrawHorizon:NEAR
		EXTRN	ScanSectors:NEAR
		EXTRN	DrawStars:NEAR
		EXTRN	DrawObjects1:NEAR
		EXTRN	DrawObjects2:NEAR
		EXTRN	DrawObjects3:NEAR
		EXTRN	DrawFarObjects:NEAR
		EXTRN	InitClouds:NEAR
		EXTRN	DrawClouds1:NEAR
		EXTRN	DrawClouds2:NEAR
		EXTRN	UserVisual:NEAR
		EXTRN	ScanCraters:NEAR
		EXTRN	ScanSmoke:NEAR
		EXTRN	DrawMobile:NEAR

		EXTRN	CloudMode:WORD

		EXTRN	Overcast:BYTE

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

;* sort drawing order wrt CloudMode

SortClouds	DW	BelowClouds	;CLOUD_MODE1
		DW	InClouds	;CLOUD_MODE2
		DW	AboveClouds  	;CLOUD_MODE3

DATA		ENDS

;============================================================================

VISCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:VISCODE
		ASSUME DS:DATA

;* Visual - top level 3D visual routine
;*
;* pass: si -> VIEWPOINT data block
;* ret : nothing
;* kill: assume all

Visual		PROC	FAR

		call	InitVisual

		call	CalcAngles

		call	CalcAFactors

		call	RotateView

		call	CalcSctrGrid	

		call	CalcObjGrid

		call	CalcSctrOffsets

		call	InitClouds

		call	DrawHorizon

		call	ScanSectors

		call	UserVisual

		call	ScanCraters

		call	ScanSmoke

;----------------------------------
;* sort drawing order wrt CloudMode
;----------------------------------

		mov	bx,CloudMode
		jmp	SortClouds[bx]

;------------------------
;* viewpoint below clouds
;------------------------

BelowClouds:   	test	Overcast,1	;overcast?
		jnz	@F		;yes ->

		call	DrawStars	;draw stars at night

		call	DrawObjects3	;objects above clouds

		call	DrawClouds2	;cloud top

		call	DrawObjects2	;objects in clouds

		call	DrawClouds1	;cloud base

@@:		call	DrawFarObjects	;far objects

		call	DrawObjects1	;objects below clouds

		ret

;---------------------
;* viewpoint in clouds
;---------------------

InClouds:   	test	Overcast,1	;overcast?
		jnz	@F		;yes ->

		call	DrawStars	;draw stars at night

		call	DrawObjects3	;objects above clouds

		call	DrawClouds2	;cloud top

		call	DrawFarObjects	;far objects

		call	DrawObjects1	;objects below clouds

		call	DrawClouds1	;cloud base

		call	DrawObjects2	;objects in clouds

@@:		ret

;------------------------
;* viewpoint above clouds
;------------------------

AboveClouds:   	call	DrawStars	;draw stars at night

		test	Overcast,1	;overcast?
		jnz	@F		;yes ->

		call	DrawFarObjects	;far objects

		call	DrawObjects1	;objects below clouds

		call	DrawClouds1	;cloud base

		call	DrawObjects2	;objects in clouds

@@:		call	DrawClouds2	;cloud top

		call	DrawObjects3	;objects above clouds

		ret

Visual		ENDP

;----------------------------------------------------------------------------

;* MobileVisual - display single mobile object (for preview mode etc.)
;*
;* pass: si -> VIEWPOINT data block
;*	 di -> MOBILE data block + 
;*	       VIEWPOINT data block
;* ret : nothing
;* kill: assume all

MobileVisual	PROC	FAR

		push	di

		call	InitVisual

		call	CalcAngles

		call	CalcAFactors

		call	CalcSctrGrid	

		call	CalcObjGrid

		call	CalcSctrOffsets

		call	InitClouds

		pop	si

		call	DrawMobile

		call	DrawObjects1

		ret

MobileVisual 	ENDP

VISCODE		ENDS

;============================================================================

		END

