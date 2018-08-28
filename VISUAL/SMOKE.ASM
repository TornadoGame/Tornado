;****************************************************************************
;*
;* SMOKE.ASM
;*
;* Smoke effects generator.
;*
;* 29.11.1992 - KJB
;* 08.02.1993 - KJB - "air" smoke effects added.
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	MakeSmokeEffect

		PUBLIC	ScanSmoke

		EXTRN	RandX:FAR
		EXTRN	CalcGndHeight:FAR

		EXTRN	DrawSmoke:NEAR

		EXTRN	LastFrame:WORD
		EXTRN	DeltaTime:WORD

;============================================================================

		INCLUDE	VISDATA.INC
		INCLUDE	PALETTES.INC

		INCLUDE	\LIB8086\USEFUL.INC
		
;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

NextSmokePtr	DW	OFFSET SmokeBuffer

TMP_SMOKE	SMOKE <>

;* init smoke effect switch

InitSmoke	DW	InitCrater1	;SMOKE_CRATER1
		DW	InitCrater2	;SMOKE_CRATER2
		DW	InitCrater3	;SMOKE_CRATER3
		DW	InitBurning	;SMOKE_BURNING
		DW	InitKickUp	;SMOKE_KICK_UP
		DW	InitAirExplo	;SMOKE_AIR_EXPLO
		DW	InitAirTrail	;SMOKE_AIR_TRAIL

;* control smoke switch

CtrlSmoke	DW	CtrlNull	;STYPE_NULL
		DW	CtrlGnd1	;STYPE_GND1
		DW	CtrlAir1	;STYPE_AIR1
		
DATA		ENDS

;============================================================================

SMOKEDATA 	SEGMENT PARA PUBLIC 'DATA'

;* cyclic buffer for smoke

SmokeBuffer	LABEL	SMOKE

		SMOKE	NUM_SMOKE DUP(<>)

SmokeBufEnd	LABEL	SMOKE

SMOKEDATA  	ENDS

;============================================================================

VISCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:VISCODE
		ASSUME DS:DATA

;* MakeSmokeEffect
;*
;* pass: bx = smoke effect type (see VISDATA.INC)
;*       si -> VIEWPOINT data block
;* ret : nothing
;* kill: assume all

MakeSmokeEffect	PROC	FAR

;-----------------------
;* copy viewpoint origin
;-----------------------

		mov	ax,[si].VP_XSEC
		mov	TMP_SMOKE.SMOKE_XSEC,ax

		mov	ax,[si].VP_YSEC
		mov	TMP_SMOKE.SMOKE_YSEC,ax

		mov	ax,[si].VP_XFT
		mov	TMP_SMOKE.SMOKE_XFT,ax

		mov	ax,[si].VP_YFT
		mov	TMP_SMOKE.SMOKE_YFT,ax

		mov	ax,WORD PTR [si].VP_ZFT_LO
		mov	WORD PTR TMP_SMOKE.SMOKE_ZFT_LO,ax

		mov	ax,WORD PTR [si].VP_ZFT_HI
		mov	WORD PTR TMP_SMOKE.SMOKE_ZFT_HI,ax

;-------------------
;* init smoke effect
;-------------------

		call	InitSmoke[bx]

		ret

MakeSmokeEffect	ENDP

;----------------------------------------------------------------------------

;* MakeSingleSmoke
;*
;* pass: NextSmokePtr
;*       TMP_SMOKE data block
;* ret : NextSmokePtr
;* kill: assume all

MakeSingleSmoke	PROC	NEAR

		mov	ax,SMOKEDATA
		mov	es,ax

		mov	si,OFFSET TMP_SMOKE
		mov	di,NextSmokePtr
		mov	cx,SMOKE_REC_SIZE

		FAST_MOVE

		mov	ax,DATA
		mov	es,ax

		cmp	di,OFFSET SmokeBufEnd	;end of buffer?
		jb	@F			;no ->

		mov	di,OFFSET SmokeBuffer	;wrap around

@@:		mov	NextSmokePtr,di

		ret

MakeSingleSmoke	ENDP

;----------------------------------------------------------------------------

;* RND_SMOKE_COL - set random smoke colour
;*
;* pass: nothing
;* ret : TMP_SMOKE.SMOKE_COL
;* kill: ax, flags

RND_SMOKE_COL	MACRO	

		call	RandX
		and	al,1
		add	al,COL_SMOKE_GREY1
		mov	TMP_SMOKE.SMOKE_COL,al

		ENDM

;----------------------------------------------------------------------------

;* InitGnd1 - init ground smoke type 1 effects
;*
;* InitCrater1 - init smoke for SMOKE_CRATER1 effect
;* InitCrater2 - init smoke for SMOKE_CRATER2 effect
;* InitCrater3 - init smoke for SMOKE_CRATER3 effect
;* InitBurning - init smoke for SMOKE_BURNING effect
;* InitKickUp  - init smoke for SMOKE_KICK_UP effect
;*
;* pass: si -> VIEWPOINT data block
;*       TMP_SMOKE
;* ret : TMP_SMOKE
;* kill: assume all

;---------------------------
InitCrater1	LABEL	NEAR
;---------------------------

		mov	TMP_SMOKE.SMOKE_SIB_CNTR,0

		mov	cx,1		;number of additional smokes

		jmp	InitGnd1

;---------------------------
InitCrater2	LABEL	NEAR
;---------------------------

		mov	TMP_SMOKE.SMOKE_SIB_CNTR,0

		mov	cx,3		;number of additional smokes

		jmp	InitGnd1

;---------------------------
InitCrater3	LABEL	NEAR
;---------------------------

		mov	TMP_SMOKE.SMOKE_SIB_CNTR,0

		mov	cx,7		;number of additional smokes

		jmp	InitGnd1

;---------------------------
InitBurning	LABEL	NEAR
;---------------------------

		mov	TMP_SMOKE.SMOKE_SIB_CNTR,10

		mov	cx,9		;number of additional smokes

		jmp	InitGnd1

;---------------------------
InitKickUp	LABEL	NEAR
;---------------------------

		mov	TMP_SMOKE.SMOKE_SIB_CNTR,0

		mov	cx,3		;number of additional smokes

;---------------------------
InitGnd1	PROC	NEAR
;---------------------------

;------------------
;* init first smoke (always at viewpoint datum)
;------------------

		mov	TMP_SMOKE.SMOKE_TYPE,STYPE_GND1

		RND_SMOKE_COL

		mov	TMP_SMOKE.SMOKE_FLAGS,0

		mov	TMP_SMOKE.SMOKE_ZFINE,0

		mov	TMP_SMOKE.SMOKE_RFT,0

		mov	TMP_SMOKE.SMOKE_TIME,0

		call	RandX
		add	ax,8 ;128
		mov	TMP_SMOKE.SMOKE_EXP_TIME,ax

		push	cx
		push	si
		call	MakeSingleSmoke
		pop	si
		pop	cx

;------------------------
;* init additional smokes
;------------------------

		jcxz	InitGnd1Exit	;no additional smokes ->

AddSmokeLoop: 	push	cx

		RND_SMOKE_COL

		call	RandX
		add	ax,8;128
		mov	TMP_SMOKE.SMOKE_EXP_TIME,ax

;* offset xft from origin (keep within sector)

		call	RandX
		cbw
		sar	ax,1		;-64ft .. +63ft offset
		add	ax,[si].VP_XFT
		cmp	ax,8191
		jle	@F
		mov	ax,8191
@@:		cmp	ax,-8192
		jge	@F
		mov	ax,-8192
@@:		mov	TMP_SMOKE.SMOKE_XFT,ax

;* offset yft from origin (keep within sector)

		call	RandX
		cbw
		sar	ax,1		;-64ft .. +63ft offset
		add	ax,[si].VP_YFT
		cmp	ax,8191
		jle	@F
		mov	ax,8191
@@:		cmp	ax,-8192
		jge	@F
		mov	ax,-8192
@@:		mov	TMP_SMOKE.SMOKE_YFT,ax

		push	si
		call	MakeSingleSmoke
		pop	si

		pop	cx

		loop	AddSmokeLoop

InitGnd1Exit:	ret

InitGnd1	ENDP

;----------------------------------------------------------------------------

;* InitAir1 - init air smoke type 1 effects
;*
;* InitAirExplo - init smoke for SMOKE_AIR_EXPLO effect
;* InitAirTrail - init smoke for SMOKE_AIR_TRAIL effect
;*
;* pass: si -> VIEWPOINT data block
;*       TMP_SMOKE
;* ret : TMP_SMOKE
;* kill: assume all

;---------------------------
InitAirExplo	LABEL	NEAR
;---------------------------

		mov	cx,15		;number of additional smokes

		jmp	InitAir1

;---------------------------
InitAirTrail	LABEL	NEAR
;---------------------------

		mov	cx,3		;number of additional smokes

;---------------------------
InitAir1	PROC	NEAR
;---------------------------

		push	cx
		push	si
		call	CalcGndHeight
		pop	si
		pop	cx

		mov	bp,ax		;bp = ground height

;------------------
;* init first smoke (always at viewpoint datum)
;------------------

		mov	TMP_SMOKE.SMOKE_TYPE,STYPE_AIR1

		RND_SMOKE_COL

		mov	TMP_SMOKE.SMOKE_FLAGS,0

		mov	TMP_SMOKE.SMOKE_ZFINE,0

		mov	TMP_SMOKE.SMOKE_RFT,0

		mov	TMP_SMOKE.SMOKE_TIME,0

		mov	TMP_SMOKE.SMOKE_SIB_CNTR,0

		call	RandX
		add	ax,8;128
		mov	TMP_SMOKE.SMOKE_EXP_TIME,ax

		call	CheckAirPos

		push	cx
		push	si
		push	bp
		call	MakeSingleSmoke
		pop	bp
		pop	si
		pop	cx

;------------------------
;* init additional smokes
;------------------------

		jcxz	InitAir1Exit	;no additional smokes ->

AirSmokeLoop: 	push	cx

		RND_SMOKE_COL

		call	RandX
		add	ax,8;128
		mov	TMP_SMOKE.SMOKE_EXP_TIME,ax

;* offset xft from origin (keep within sector)

		call	RandX
		cbw
		sar	ax,1		;-64ft .. +63ft offset
		add	ax,[si].VP_XFT
		cmp	ax,8191
		jle	@F
		mov	ax,8191
@@:		cmp	ax,-8192
		jge	@F
		mov	ax,-8192
@@:		mov	TMP_SMOKE.SMOKE_XFT,ax

;* offset yft from origin (keep within sector)

		call	RandX
		cbw
		sar	ax,1		;-64ft .. +63ft offset
		add	ax,[si].VP_YFT
		cmp	ax,8191
		jle	@F
		mov	ax,8191
@@:		cmp	ax,-8192
		jge	@F
		mov	ax,-8192
@@:		mov	TMP_SMOKE.SMOKE_YFT,ax

;* offset zft from origin

		call	RandX
		cbw
		sar	ax,1		;-64ft .. +63ft offset
		cwd
		add	ax,WORD PTR [si].VP_ZFT_LO
		adc	dx,WORD PTR [si].VP_ZFT_HI
		jns	@F
		xor	ax,ax
		xor	dx,dx
@@:		mov	WORD PTR TMP_SMOKE.SMOKE_ZFT_LO,ax
		mov	WORD PTR TMP_SMOKE.SMOKE_ZFT_HI,dx

		call	CheckAirPos

		push	si
		push	bp
		call	MakeSingleSmoke
		pop	bp
		pop	si

		pop	cx

		loop	AirSmokeLoop

InitAir1Exit:	ret

InitAir1	ENDP

;----------------------------------------------------------------------------

;* CheckAirPos - check air smoke does not penetrate ground
;*
;* pass: TMP_SMOKE
;*       bp = ground height
;* ret : TMP_SMOKE
;* kill: ax, dx, flags

CheckAirPos	PROC	NEAR

;* if zft < 65536 then
;*
;*    zdiff = zft - ground height
;*
;*    if zdiff < 0 then
;*       zft = ground height + 32
;*       expand time = 128
;*    else
;*       if zdiff < expand time / 4 then
;*          expand time = zdiff * 4
;*          if expand time < 128 then
;*             zft = ground height + 32
;*             expand time = 128
;*          endif
;*       endif
;*    endif
;* endif

		cmp	WORD PTR TMP_SMOKE.SMOKE_ZFT_HI,0
		ja	ExitAirPos

		mov	ax,WORD PTR TMP_SMOKE.SMOKE_ZFT_LO
		sub	ax,bp

		jb	SetMinSize

		mov	dx,TMP_SMOKE.SMOKE_EXP_TIME

		REPT	2
		shr	dx,1
		ENDM

		cmp	ax,dx
		jae	ExitAirPos

		REPT	2
		shl	ax,1
		ENDM

		cmp	ax,8;128
		jae	@F

SetMinSize:	mov	ax,bp
		add	ax,8;32

		mov	WORD PTR TMP_SMOKE.SMOKE_ZFT_LO,ax

		mov	ax,8;128

@@:		mov	TMP_SMOKE.SMOKE_EXP_TIME,ax

ExitAirPos:	ret

CheckAirPos	ENDP

;----------------------------------------------------------------------------

;* ScanSmoke - scan smoke buffer and draw smoke
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all
;*
;* note: Smoke circles are low priority objects and could possibly clog the
;*	 object buffer. Therefore call this routine "later on" in the visual
;*	 drawing order.

ScanSmoke	PROC	NEAR

;-----------
;* scan loop
;-----------

		mov	cx,NUM_SMOKE

		mov	si,OFFSET SmokeBuffer

		mov	ax,SMOKEDATA
		mov	ds,ax

SmokeLoop:	cmp	[si].SMOKE_TYPE,STYPE_NULL	;smoke active?
		jne	SortSmoke			;yes ->

NextSmoke:	add	si,SMOKE_REC_SIZE

		loop	SmokeLoop

		mov	ax,DATA
		mov	ds,ax

		ret

;-----------------------------------
;* copy smoke data into working copy
;-----------------------------------

SortSmoke: 	push	cx		;store loop count
		push	si		;store smoke ptr

		mov	di,OFFSET TMP_SMOKE
		mov	cx,SMOKE_REC_SIZE

		FAST_MOVE

		mov	ax,DATA
		mov	ds,ax

;--------------
;* update smoke
;--------------

		mov	bx,TMP_SMOKE.SMOKE_TYPE
		call	CtrlSmoke[bx]
		jc	@F		;smoke cleared ->

;------------
;* draw smoke
;------------

		mov	si,OFFSET TMP_SMOKE
		call	DrawSmoke

;-----------------------------------
;* copy smoke data from working copy
;-----------------------------------

@@:		pop	di		;smoke ptr
		push	di

		mov	cx,SMOKE_REC_SIZE
		mov	si,OFFSET TMP_SMOKE

		mov	ax,SMOKEDATA
		mov	es,ax

		FAST_MOVE

		mov	ax,DATA
		mov	es,ax

;-------------------------------
;* prepare to re-enter scan loop
;-------------------------------

		mov	ax,SMOKEDATA
		mov	ds,ax

		pop	si		;restore smoke ptr
		pop	cx		;restore loop count

		jmp	NextSmoke

ScanSmoke	ENDP

;----------------------------------------------------------------------------

;* CtrlNull
;*
;* pass: nothing
;* ret : cf = 1 = smoke cleared
;* kill: nothing

CtrlNull	PROC	NEAR

		stc
		ret

CtrlNull	ENDP

;----------------------------------------------------------------------------

;* CtrlGnd1 - control routine for ground smoke type 1
;*
;* pass: TMP_SMOKE
;* ret : TMP_SMOKE
;*       cf = 0 = smoke ok
;*       cf = 1 = smoke cleared
;* kill: assume all (except cf)
;*
;* note: Phase 1: Expand radius keeping base of smoke on crater base.
;*	 Phase 2: Contract radius and drift upwards until radius is zero.

CtrlGnd1	PROC	NEAR

;--------------
;* update timer
;--------------

		mov	ax,TMP_SMOKE.SMOKE_TIME
		add	ax,LastFrame
		mov	TMP_SMOKE.SMOKE_TIME,ax

;------------
;* sort phase
;------------

		mov	dx,TMP_SMOKE.SMOKE_EXP_TIME

		cmp	ax,dx		;expand phase?
		jbe	Gnd1Phase1	;yes ->

		sub	ax,dx

		shl	dx,1		;contract phase is double expand phase

		cmp	ax,dx	    	;contract phase?
		jbe	Gnd1Phase2	;yes ->

;-------------------
;* end of smoke life
;-------------------

		mov	TMP_SMOKE.SMOKE_TYPE,STYPE_NULL

		stc			;cf = 1 = smoke cleared
		ret

;---------------------------
Gnd1Phase1	LABEL	NEAR		;expand radius
;---------------------------

		REPT	3;2		;radius = time / 4
		shr	ax,1
		ENDM

		mov	dx,TMP_SMOKE.SMOKE_RFT
		mov	TMP_SMOKE.SMOKE_RFT,ax

;* reset base zft

		sub	WORD PTR TMP_SMOKE.SMOKE_ZFT_LO,dx
		sbb	WORD PTR TMP_SMOKE.SMOKE_ZFT_HI,0

;* set centre zft wrt radius

		add	WORD PTR TMP_SMOKE.SMOKE_ZFT_LO,ax
		adc	WORD PTR TMP_SMOKE.SMOKE_ZFT_HI,0

		clc			;cf = 0 = smoke ok
		ret

;---------------------------
Gnd1Phase2	LABEL	NEAR		;contract radius and drift upwards
;---------------------------

;* reproduce sibling?

		test	TMP_SMOKE.SMOKE_FLAGS,SFLG_REPRO	;already reproduced?
		_JNZ	SkipRepro				;yes ->

		cmp	TMP_SMOKE.SMOKE_SIB_CNTR,0		;reproduce any more?
		_JE	SkipRepro				;no ->

;* reproduce

		push	ax
		push	dx

		dec	TMP_SMOKE.SMOKE_SIB_CNTR

		push	WORD PTR TMP_SMOKE.SMOKE_COL	;(col + flags)
		push	WORD PTR TMP_SMOKE.SMOKE_ZFT_LO
		push	WORD PTR TMP_SMOKE.SMOKE_ZFT_HI
		push	TMP_SMOKE.SMOKE_ZFINE
		push	TMP_SMOKE.SMOKE_RFT
		push	TMP_SMOKE.SMOKE_TIME
		push	TMP_SMOKE.SMOKE_EXP_TIME

		mov	ax,TMP_SMOKE.SMOKE_RFT
		sub	WORD PTR TMP_SMOKE.SMOKE_ZFT_LO,ax	;reset base zft
		sbb	WORD PTR TMP_SMOKE.SMOKE_ZFT_HI,0

		RND_SMOKE_COL

		mov	TMP_SMOKE.SMOKE_FLAGS,0

		mov	TMP_SMOKE.SMOKE_ZFINE,0

		mov	TMP_SMOKE.SMOKE_RFT,0

		mov	TMP_SMOKE.SMOKE_TIME,0

		call	RandX
		add	ax,8;128
		mov	TMP_SMOKE.SMOKE_EXP_TIME,ax

		call	MakeSingleSmoke

		pop	TMP_SMOKE.SMOKE_EXP_TIME
		pop	TMP_SMOKE.SMOKE_TIME
		pop	TMP_SMOKE.SMOKE_RFT
		pop	TMP_SMOKE.SMOKE_ZFINE
		pop	WORD PTR TMP_SMOKE.SMOKE_ZFT_HI
		pop	WORD PTR TMP_SMOKE.SMOKE_ZFT_LO
		pop	WORD PTR TMP_SMOKE.SMOKE_COL	;(col + flags)

		or	TMP_SMOKE.SMOKE_FLAGS,SFLG_REPRO

		pop	dx
		pop	ax

SkipRepro:	shr	dx,1
		shr	ax,1

		sub	dx,ax

		REPT	3;2		;radius = (expand time - time) / 4
		shr	dx,1
		ENDM

		mov	TMP_SMOKE.SMOKE_RFT,dx

;* drift upwards

		mov	ax,DeltaTime
		xor	dx,dx

		REPT	6		;climb rate = 32ft / sec (64 * bin frac)
		shl	ax,1
		rcl	dx,1
		ENDM

		add	TMP_SMOKE.SMOKE_ZFINE,ax
		add	WORD PTR TMP_SMOKE.SMOKE_ZFT_LO,dx
		adc	WORD PTR TMP_SMOKE.SMOKE_ZFT_HI,0

		clc			;cf = 0 = smoke ok
		ret

CtrlGnd1	ENDP

;----------------------------------------------------------------------------

;* CtrlAir1 - control routine for air smoke type 1
;*
;* pass: TMP_SMOKE
;* ret : TMP_SMOKE
;*       cf = 0 = smoke ok
;*       cf = 1 = smoke cleared
;* kill: assume all (except cf)
;*
;* note: Phase 1: Expand radius.
;*	 Phase 2: Contract radius.

CtrlAir1	PROC	NEAR

;--------------
;* update timer
;--------------

		mov	ax,TMP_SMOKE.SMOKE_TIME
		add	ax,LastFrame
		mov	TMP_SMOKE.SMOKE_TIME,ax

;------------
;* sort phase
;------------

		mov	dx,TMP_SMOKE.SMOKE_EXP_TIME

		cmp	ax,dx		;expand phase?
		jbe	Air1Phase1	;yes ->

		sub	ax,dx

		shl	dx,1		;contract phase is double expand phase

		cmp	ax,dx	    	;contract phase?
		jbe	Air1Phase2	;yes ->

;-------------------
;* end of smoke life
;-------------------

		mov	TMP_SMOKE.SMOKE_TYPE,STYPE_NULL

		stc			;cf = 1 = smoke cleared
		ret

;---------------------------
Air1Phase1	LABEL	NEAR		;expand radius
;---------------------------

		REPT	3;2		;radius = time / 4
		shr	ax,1
		ENDM

		mov	TMP_SMOKE.SMOKE_RFT,ax

		clc			;cf = 0 = smoke ok
		ret

;---------------------------
Air1Phase2	LABEL	NEAR		;contract radius
;---------------------------

		shr	dx,1
		shr	ax,1

		sub	dx,ax

		REPT	3;2		;radius = (expand time - time) / 4
		shr	dx,1
		ENDM

		mov	TMP_SMOKE.SMOKE_RFT,dx

		clc			;cf = 0 = smoke ok
		ret

CtrlAir1	ENDP

VISCODE		ENDS

;============================================================================

		END

