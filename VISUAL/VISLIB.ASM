;****************************************************************************
;*
;* VISLIB.ASM
;*
;* 3D visual library routines.
;*
;* 04.02.1991 - KJB
;* 03.04.1993 - KJB - RotateView added.
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	InitVisual
		PUBLIC	CalcAngles
		PUBLIC	CalcAFactors
		PUBLIC	CalcBFactors
		PUBLIC	CalcCFactors
		PUBLIC	CalcDFactors
		PUBLIC	CalcSctrGrid
		PUBLIC	CalcObjGrid
		PUBLIC	CalcRotateGrid1
		PUBLIC	CalcRotateGrid2
		PUBLIC	CalcRotateGrid3
		PUBLIC	CalcSctrOffsets
		PUBLIC	CalcEyePosition
		PUBLIC	RotateView

		EXTRN	ArcTan360:FAR
		EXTRN	FastArcSin:FAR

		EXTRN	SinTable:WORD
		EXTRN	CosTable:WORD

;============================================================================

		INCLUDE	VISEXTRN.INC
		INCLUDE	VISDATA.INC
		INCLUDE	VISMACRO.INC
		INCLUDE	\LIB8086\USEFUL.INC
		INCLUDE	\LIB8086\TRIG.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

CalcScale	DW	CalcScale16	;case z scaled < MAX_RANGE16
		DW	CalcScale8	;case z scaled < MAX_RANGE8
		DW	CalcScale4	;case z scaled < MAX_RANGE4
		DW	CalcScale2	;case z scaled < MAX_RANGE2
		DW	CalcScale1	;case else

;* jump tables for calc object sub-divisions (variable size)

MAKEPOS		MACRO	N
		DW	PosSubDiv&N
		ENDM

COUNT		=	0

CalcPosSubDiv	LABEL	WORD
		REPT	33
		MAKEPOS	%COUNT
COUNT		=	COUNT+1
		ENDM

MAKENEG		MACRO	N
		DW	NegSubDiv&N
		ENDM

COUNT		=	0

CalcNegSubDiv	LABEL	WORD
		REPT	33
		MAKENEG	%COUNT
COUNT		=	COUNT+1
		ENDM

;--------------------
;* rotate view switch
;--------------------

RotateSwitch	DW	RotateNull	;ROTATE_NULL
		DW	RotateViewRt	;ROTATE_VIEW_RT
		DW	RotateViewLt	;ROTATE_VIEW_LT
		DW	RotateViewUp	;ROTATE_VIEW_UP
		DW	RotateViewDn	;ROTATE_VIEW_DN
		DW	RotateViewBk	;ROTATE_VIEW_BK

DATA		ENDS

;============================================================================

VISCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:VISCODE
		ASSUME DS:DATA

;* InitVisual - visual initialization
;*
;* pass: si -> VIEWPOINT data record
;* ret : V_VIEW
;* kill: assume all

InitVisual	PROC	NEAR

;* copy viewpoint data to V_VIEW data record

		COPY_VP	V_VIEW,si

;* calculate sector sub-division grid co-ords

;* XGrid1 = ((XFT / 256) + 32) = 0 .. 63

		mov	al,BYTE PTR V_VIEW.VP_XFT+1
		add	al,32
		cbw
		mov	XGrid1,ax	;current sector visual x grid (0 .. 63)

;* XGrid2 = XGrid1 / 2 = 0 .. 31

		shr	ax,1
		mov	XGrid2,ax	;3 by 3 sector visual x grid (0 .. 31)

;* XGrid8 = XGrid1 / 8 = 0 .. 7

		shr	ax,1
		shr	ax,1
		mov	XGrid8,ax	;7 by 7 sector visual x grid (0 .. 7)

;* XGrid16 = XGrid1 / 16 = 0 .. 3

		shr	ax,1
		mov	XGrid16,ax	;15 by 15 sector visual x grid (0 .. 3)

;* YGrid1 = ((YFT / 256) + 32) = 0 .. 63
		
		mov	al,BYTE PTR V_VIEW.VP_YFT+1
		add	al,32
		cbw
		mov	YGrid1,ax	;current sector visual y grid (0 .. 63)
	
;* YGrid2 = YGrid1 / 2 = 0 .. 31

		shr	ax,1
		mov	YGrid2,ax	;3 by 3 sector visual y grid (0 .. 31)

;* YGrid8 = YGrid1 / 8 = 0 .. 7

		shr	ax,1
		shr	ax,1
		mov	YGrid8,ax	;7 by 7 sector visual y grid (0 .. 7)

;* YGrid16 = YGrid1 / 16 = 0 .. 3

		shr	ax,1
		mov	YGrid16,ax	;15 by 15 sector visual y grid (0 .. 3)

;* scale ZFT > 10,000ft so max ZFT < 32,768ft

 	     	mov	ax,WORD PTR V_VIEW.VP_ZFT_LO
		mov	dx,WORD PTR V_VIEW.VP_ZFT_HI

		test	dx,dx		;zft > 65,535ft?
		jnz	CalcZScaled	;yes ->

		cmp	ax,10000	;zft > 10,000ft?
		jbe	ZOk		;no ->

;* z scaled = zft / 4 + 7,500
;*
;* @  10,000ft z scaled =  10,000 / 4 + 7,500 = 10,000
;* @ 100,000ft z scaled = 100,000 / 4 + 7,500 = 32,500

CalcZScaled:	REPT	2		;zft / 4
		shr	dx,1
		rcr	ax,1
		ENDM

		add	ax,7500		;zft / 4 + 7,500

ZOk:		mov	ZScaled,ax

;* clear object distance sort arrays

		mov	ax,-1
		mov	cx,NUM_BINS
		mov	di,OFFSET ObjectDist1
		rep	stosw

		mov	ObjectDist2[BEHIND_BIN],ax
		mov	ObjectDist2[IN_FRONT_BIN],ax

		mov	ObjectDist3[BEHIND_BIN],ax
		mov	ObjectDist3[IN_FRONT_BIN],ax

;* clear far object distance sort array

		mov	cx,NUM_FAR_BINS
		mov	di,OFFSET FarObjectDist
		rep	stosw

;* reset object buffer pointer
		
		mov	ax,OFFSET ObjectBuffer
		mov	ObjectBufPtr,ax

;* set rotated grid size to minimum size

		xor	ax,ax
		mov	XGridSize,ax
		mov	YGridSize,ax
		mov	ZGridSize,ax

		ret

InitVisual	ENDP

;----------------------------------------------------------------------------

;* CalcAngles - calculate sin and cos of angles
;*
;* pass: V_VIEW.VP_HDG
;*       V_VIEW.VP_PITCH
;*       V_VIEW.VP_ROLL
;* ret : V_SinH, V_CosH
;*       V_SinP, V_CosP
;*       V_SinR, V_CosR
;* kill: ax, bx, flags

CalcAngles	PROC	NEAR

;* heading

		mov	ax,V_VIEW.VP_HDG
		and	ax,001ffh
		mov	bx,ax
		shl	bx,1
		mov	ax,SinTable[bx]
		mov	V_SinH,ax
		mov	ax,CosTable[bx]
		mov	V_CosH,ax

;* pitch

		mov	ax,V_VIEW.VP_PITCH
		and	ax,001ffh
		mov	bx,ax
		shl	bx,1
		mov	ax,SinTable[bx]
		mov	V_SinP,ax
		mov	ax,CosTable[bx]
		mov	V_CosP,ax

;* roll

		mov	ax,V_VIEW.VP_ROLL
		and	ax,001ffh
		mov	bx,ax
		shl	bx,1
		mov	ax,SinTable[bx]
		mov	V_SinR,ax
		mov	ax,CosTable[bx]
		mov	V_CosR,ax

		ret

CalcAngles	ENDP

;----------------------------------------------------------------------------

;* CalcAFactors - calculate rotation matrix "A" factors
;*
;* pass: V_SinH, V_CosH
;*       V_SinP, V_CosP
;*       V_SinR, V_CosR
;* ret : A1, A2, A3
;*       A4, A5, A6
;*       A7, A8, A9
;* kill: assume all

CalcAFactors	PROC	NEAR

		mov	ax,V_CosR
		mov	bp,ax

		mov	ax,V_CosH
		mov	si,ax
		imul	bp
		FRACADJ	bx		;bx = cosH.cosR

		mov	ax,V_SinH
		mov	di,ax
		imul	bp
		FRACADJ	cx		;cx = sinH.cosR

		mov	ax,V_SinR
		mov	bp,ax

		imul	si
		FRACADJ	si		;si = cosH.sinR

		mov	ax,bp
		imul	di
		FRACADJ	di		;di = sinH.sinR

		mov	ax,V_SinP
		mov	bp,ax

		mov	ax,di
		imul	bp
		FRACADJ	ax		;ax = sinP.sinH.sinR
		add	ax,bx		;ax = sinP.sinH.sinR + cosH.cosR
		mov	A1,ax

		mov	ax,si	
		imul	bp
		FRACADJ	ax		;ax = sinP.cosH.sinR
		sub	ax,cx		;ax = sinP.cosH.sinR - sinH.cosR
		mov	A2,ax

		mov	ax,cx
		imul	bp
		FRACADJ	dx		;dx = sinP.sinH.cosR
		mov	ax,si
		sub	ax,dx		;ax = cosH.sinR - sinP.sinH.cosR
		mov	A7,ax

		mov	ax,bx
		imul	bp
		FRACADJ	dx		;dx = sinP.cosH.cosR
		mov	ax,di
		neg	ax		;ax = -sinH.sinR
		sub	ax,dx		;ax = -sinH.sinR - sinP.cosH.cosR
		mov	A8,ax

		mov	ax,V_CosP
		mov	bp,ax
		
		mov	ax,V_SinR
		neg	ax		;ax = -sinR
		imul	bp
		FRACADJ	ax		;ax = -sinR.cosP
		mov	A3,ax

		mov	ax,V_SinH
		imul	bp
		FRACADJ	ax	 	;ax = sinH.cosP
		mov	A4,ax

		mov	ax,V_CosH
		imul	bp
		FRACADJ	ax		;ax = cosH.cosP
		mov	A5,ax

		mov	ax,V_CosR
		imul	bp
		FRACADJ	ax		;ax = cosR.cosP
		mov	A9,ax

		mov	ax,V_SinP	;ax = sinP
		mov	A6,ax

		ret

CalcAFactors	ENDP

;----------------------------------------------------------------------------

;* CalcBFactors - calculate rotation matrix "B" factors (skew object)
;*
;* pass: ax = heading angle (p degs)
;*       A1, A2, A3
;*       A4, A5, A6
;*       A7, A8, A9
;* ret : B1, B2, B3
;*       B4, B5, B6
;*       B7, B8, B9
;* kill: assume all
	
FastBFactors	LABEL	NEAR

		mov	cx,9
		mov	si,OFFSET A1
		mov	di,OFFSET B1
		rep	movsw
		ret
	
CalcBFactors	PROC	NEAR

		test	ax,ax		;hdg = 0?
		jz	FastBFactors	;yes ->

		SINCOS	si,di,ax	;si = sin(hdg), di = cos(hdg)

SIN_HDG		EQU	si
COS_HDG		EQU	di

;* B1 = A1.cos(hdg) - A2.sin(hdg)

		mov	ax,A1
		mov	bx,ax
		mov	ax,A2
		mov	cx,ax

		imul	SIN_HDG
		FRACADJ	bp
		mov	ax,bx
		imul	COS_HDG
		FRACADJ	ax
		sub	ax,bp
		mov	B1,ax
		
;* B2 = A1.sin(hdg) + A2.cos(hdg)

		mov	ax,bx
		imul	SIN_HDG
		FRACADJ	bp
		mov	ax,cx
		imul	COS_HDG
		FRACADJ	ax
		add	ax,bp
		mov	B2,ax
	
;* B3 = A3

		mov	ax,A3
		mov	B3,ax

;* B4 = A4.cos(hdg) - A5.sin(hdg)

		mov	ax,A4
		mov	bx,ax
		mov	ax,A5
		mov	cx,ax

		imul	SIN_HDG
		FRACADJ	bp
		mov	ax,bx
		imul	COS_HDG
		FRACADJ	ax
		sub	ax,bp
		mov	B4,ax
	
;* B5 = A4.sin(hdg) + A5.cos(hdg)

		mov	ax,bx
		imul	SIN_HDG
		FRACADJ	bp
		mov	ax,cx
		imul	COS_HDG
		FRACADJ	ax
		add	ax,bp
		mov	B5,ax
	
;* B6 = A6

		mov	ax,A6
		mov	B6,ax

;* B7 = A7.cos(hdg) - A8.sin(hdg)

		mov	ax,A7
		mov	bx,ax
		mov	ax,A8
		mov	cx,ax

		imul	SIN_HDG
		FRACADJ	bp
		mov	ax,bx
		imul	COS_HDG
		FRACADJ	ax
		sub	ax,bp
		mov	B7,ax
	
;* B8 = A7.sin(hdg) + A8.cos(hdg)
     
		mov	ax,bx
		imul	SIN_HDG
		FRACADJ	bp
		mov	ax,cx
		imul	COS_HDG
		FRACADJ	ax
		add	ax,bp
		mov	B8,ax
	
;* B9 = A9

		mov	ax,A9
		mov	B9,ax

		ret

CalcBFactors	ENDP

;----------------------------------------------------------------------------

;* CalcCFactors - calculate rotation matrix "C" factors (pitch object)
;*
;* pass: ax = pitch angle (p degs)
;*       B1, B2, B3
;*       B4, B5, B6
;*       B7, B8, B9
;* ret : C1, C2, C3
;*       C4, C5, C6
;*       C7, C8, C9
;* kill: assume all
	
FastCFactors	LABEL	NEAR

		mov	cx,9
		mov	si,OFFSET B1
		mov	di,OFFSET C1
		rep	movsw
		ret
	
CalcCFactors	PROC	NEAR

		test	ax,ax		;pitch = 0?
		jz	FastCFactors	;yes ->

		SINCOS	si,di,ax	;si = sin(pitch), di = cos(pitch)

SIN_PITCH	EQU	si
COS_PITCH	EQU	di

;* C1 = B1

		mov	ax,B1
		mov	C1,ax

;* C2 = B2.cos(pitch) + B3.sin(pitch)

		mov	ax,B2
		mov	bx,ax
		mov	ax,B3
		mov	cx,ax

		imul	SIN_PITCH
		FRACADJ	bp
		mov	ax,bx
		imul	COS_PITCH
		FRACADJ	ax
		add	ax,bp
		mov	C2,ax

;* C3 = -B2.sin(pitch) + B3.cos(pitch)

		mov	ax,bx
		imul	SIN_PITCH
		FRACADJ	bp
		mov	ax,cx
		imul	COS_PITCH
		FRACADJ	ax
		sub	ax,bp
		mov	C3,ax

;* C4 = B4

		mov	ax,B4
		mov	C4,ax

;* C5 = B5.cos(pitch) + B6.sin(pitch)

		mov	ax,B5
		mov	bx,ax
		mov	ax,B6
		mov	cx,ax

		imul	SIN_PITCH
		FRACADJ	bp
		mov	ax,bx
		imul	COS_PITCH
		FRACADJ	ax
		add	ax,bp
		mov	C5,ax

;* C6 = -B5.sin(pitch) + B6.cos(pitch)

		mov	ax,bx
		imul	SIN_PITCH
		FRACADJ	bp
		mov	ax,cx
		imul	COS_PITCH
		FRACADJ	ax
		sub	ax,bp
		mov	C6,ax

;* C7 = B7

		mov	ax,B7
		mov	C7,ax

;* C8 = B8.cos(pitch) + B9.sin(pitch)

		mov	ax,B8
		mov	bx,ax
		mov	ax,B9
		mov	cx,ax

		imul	SIN_PITCH
		FRACADJ	bp
		mov	ax,bx
		imul	COS_PITCH
		FRACADJ	ax
		add	ax,bp
		mov	C8,ax

;* C9 = -B8.sin(pitch) + B9.cos(pitch)

		mov	ax,bx
		imul	SIN_PITCH
		FRACADJ	bp
		mov	ax,cx
		imul	COS_PITCH
		FRACADJ	ax
		sub	ax,bp
		mov	C9,ax

		ret

CalcCFactors	ENDP

;----------------------------------------------------------------------------

;* CalcDFactors - calculate rotation matrix "D" factors (roll object)
;*
;* pass: ax = roll angle (p degs)
;*       C1, C2, C3
;*       C4, C5, C6
;*       C7, C8, C9
;* ret : D1, D2, D3
;*       D4, D5, D6
;*       D7, D8, D9
;* kill: assume all
	
FastDFactors	LABEL	NEAR

		mov	cx,9
		mov	si,OFFSET C1
		mov	di,OFFSET D1
		rep	movsw
		ret
	
CalcDFactors	PROC	NEAR

		test	ax,ax		;roll = 0?
		jz	FastDFactors	;yes ->

		SINCOS	si,di,ax	;si = sin(roll), di = cos(roll)

SIN_ROLL	EQU	si
COS_ROLL	EQU	di

;* D1 = C1.cos(roll) - C3.sin(roll)

		mov	ax,C1
		mov	bx,ax
		mov	ax,C3
		mov	cx,ax

		imul	SIN_ROLL
		FRACADJ	bp
		mov	ax,bx
		imul	COS_ROLL
		FRACADJ	ax
		sub	ax,bp
		mov	D1,ax

;* D2 = C2

		mov	ax,C2
		mov	D2,ax

;* D3 = C1.sin(roll) + C3.cos(roll)

		mov	ax,bx
		imul	SIN_ROLL
		FRACADJ	bp
		mov	ax,cx
		imul	COS_ROLL
		FRACADJ	ax
		add	ax,bp
		mov	D3,ax

;* D4 = C4.cos(roll) - C6.sin(roll)

		mov	ax,C4
		mov	bx,ax
		mov	ax,C6
		mov	cx,ax

		imul	SIN_ROLL
		FRACADJ	bp
		mov	ax,bx
		imul	COS_ROLL
		FRACADJ	ax
		sub	ax,bp
		mov	D4,ax

;* D5 = C5

		mov	ax,C5
		mov	D5,ax

;* D6 = C4.sin(roll) + C6.cos(roll)

		mov	ax,bx
		imul	SIN_ROLL
		FRACADJ	bp
		mov	ax,cx
		imul	COS_ROLL
		FRACADJ	ax
		add	ax,bp
		mov	D6,ax

;* D7 = C7.cos(roll) - C9.sin(roll)

		mov	ax,C7
		mov	bx,ax
		mov	ax,C9
		mov	cx,ax

		imul	SIN_ROLL
		FRACADJ	bp
		mov	ax,bx
		imul	COS_ROLL
		FRACADJ	ax
		sub	ax,bp
		mov	D7,ax

;* D8 = C8

		mov	ax,C8
		mov	D8,ax

;* D9 = C7.sin(roll) + C9.cos(roll)

		mov	ax,bx
		imul	SIN_ROLL
		FRACADJ	bp
		mov	ax,cx
		imul	COS_ROLL
		FRACADJ	ax
		add	ax,bp
		mov	D9,ax

		ret

CalcDFactors	ENDP

;----------------------------------------------------------------------------

;* CalcSctrGrid - calculate sector grid
;*
;* pass: A1, A2, A3
;*       A4, A5, A6
;*       A7, A8, A9
;* ret : XSX[], XSY[], XSZ[]
;*       YSX[], YSY[], YSZ[]
;*       ZSX[], ZSY[], ZSZ[]
;* kill: assume all

CalcSctrGrid	PROC	NEAR

		mov	ax,A1
		mov	di,OFFSET XSX
		call	CalcSctrSubDiv 
		
		mov	ax,A2
		mov	di,OFFSET XSY
		call	CalcSctrSubDiv	    	

		mov	ax,A3
		mov	di,OFFSET XSZ
		call	CalcSctrZSubDiv

		mov	ax,A4
		mov	di,OFFSET YSX
		call	CalcSctrSubDiv

		mov	ax,A5
		mov	di,OFFSET YSY
		call	CalcSctrSubDiv				

		mov	ax,A6
		mov	di,OFFSET YSZ
		call	CalcSctrZSubDiv

		mov	ax,A7
		mov	di,OFFSET ZSX
		call	CalcSctrSubDiv

		mov	ax,A8
		mov	di,OFFSET ZSY
		call	CalcSctrSubDiv				

		mov	ax,A9
		mov	di,OFFSET ZSZ
		call	CalcSctrZSubDiv

		ret

CalcSctrGrid	ENDP

;----------------------------------------------------------------------------

;* CalcSctrSubDiv - calculate sector grid sub-divisions (+/-16k step 256)
;*
;* pass: ax = "A" factor
;*       di -> sector grid sub-divisions array
;* ret : di[]
;* kill: assume all

ZeroSctrSubDiv	LABEL	NEAR
	
		mov	cx,129		;set all values to 0
		rep	stosw
		ret

CalcSctrSubDiv	PROC	NEAR

		test	ax,ax

		jz	ZeroSctrSubDiv	;all values are zero ->
		jns	PosSctrSubDiv	;pos value ->
		jmp	NegSctrSubDiv	;neg value ->

PosSctrSubDiv:	xor	dx,dx		;ax, dx = 65536 * value

		shr	ax,1		;/2 for +/-16k grid
		rcr	dx,1

		mov	bx,ax		;bx, cx = 65536 * value / 2
		mov	cx,dx
		
		mov	cl,ch		;bx, cx = 65536 * value / 2 / 64
		mov	ch,bl
		mov	bl,bh
		xor	bh,bh
		REPT	2
		shl	cx,1
		rcl	bx,1
		ENDM

MIDVAL		=	64*2		
INDEX		=	64*2

		REPT	64
		mov	[di][MIDVAL+INDEX],ax
		neg	ax
		mov	[di][MIDVAL-INDEX],ax

		IF	INDEX NE 2
		neg	ax
		sub	dx,cx
		sbb	ax,bx
		ENDIF

INDEX		=	INDEX-2
		ENDM

		ret

NegSctrSubDiv:	neg	ax		;make positive

		xor	dx,dx		;ax, dx = 65536 * value

		shr	ax,1		;/2 for +/-16k grid
		rcr	dx,1

		mov	bx,ax		;bx, cx = 65536 * value / 2
		mov	cx,dx
		
		mov	cl,ch		;bx, cx = 65536 * value / 2 / 64
		mov	ch,bl
		mov	bl,bh
		xor	bh,bh
		REPT	2
		shl	cx,1
		rcl	bx,1
		ENDM

MIDVAL		=	64*2		
INDEX		=	64*2

		REPT	64
		mov	[di][MIDVAL-INDEX],ax
		neg	ax
		mov	[di][MIDVAL+INDEX],ax

		IF	INDEX NE 2
		neg	ax
		sub	dx,cx
		sbb	ax,bx
		ENDIF

INDEX		=	INDEX-2
		ENDM

		ret

CalcSctrSubDiv	ENDP

;----------------------------------------------------------------------------

;* CalcSctrZSubDiv - calculate sector grid "Z" sub-divisions (+4k step 256)
;*
;* pass: ax = "A" factor
;*       di -> sector grid sub-divisions array
;* ret : di[]
;* kill: assume all
;*
;* note: Z sector grids are +4k step 256 only.

ZeroSctrZSubDiv	LABEL	NEAR
	
		mov	cx,17		;set all values to 0
		rep	stosw
		ret

CalcSctrZSubDiv	PROC	NEAR

		test	ax,ax

		jz	ZeroSctrZSubDiv	;all values are zero ->
		jns	PosSctrZSubDiv	;pos value ->
		jmp	NegSctrZSubDiv	;neg value ->

PosSctrZSubDiv:	xor	dx,dx		;ax, dx = 65536 * value

		REPT	3
		shr	ax,1		;/8 for +4k grid
		rcr	dx,1
		ENDM
	
		mov	bx,ax		;bx, cx = 65536 * value / 8
		mov	cx,dx
	
		REPT	4
		shr	bx,1 		;bx, cx = 65536 * value / 8 / 16
		rcr	cx,1
		ENDM
	
INDEX		=	16*2

		REPT	16
		mov	[di][INDEX],ax

		IF	INDEX NE 2
		sub	dx,cx
		sbb	ax,bx
		ENDIF

INDEX		=	INDEX-2
		ENDM

		ret

NegSctrZSubDiv:	neg	ax		;make positive

		xor	dx,dx		;ax, dx = 65536 * value

		REPT	3
		shr	ax,1		;/8 for +4k grid
		rcr	dx,1
		ENDM
	
		mov	bx,ax		;bx, cx = 65536 * value / 8
		mov	cx,dx

		REPT	4
		shr	bx,1 		;bx, cx = 65536 * value / 8 / 16
		rcr	cx,1
		ENDM
	
		NEG32	ax,dx

INDEX		=	16*2

		REPT	16
		mov	[di][INDEX],ax

		IF	INDEX NE 2
		add	dx,cx
		adc	ax,bx
		ENDIF

INDEX		=	INDEX-2
		ENDM

		ret

CalcSctrZSubDiv	ENDP

;----------------------------------------------------------------------------

;* CalcObjGrid - calculate object grid
;*
;* pass: A1, A2, A3
;*       A4, A5, A6
;*       A7, A8, A9
;* ret : XGX[], XGY[], XGZ[]
;*       YGX[], YGY[], YGZ[]
;*       ZGX[], ZGY[], ZGZ[]
;* kill: assume all

CalcObjGrid	PROC	NEAR

		mov	ax,A1
		mov	di,OFFSET XGX
		call	CalcObjSubDiv 
		
		mov	ax,A2
		mov	di,OFFSET XGY
		call	CalcObjSubDiv

		mov	ax,A3
		mov	di,OFFSET XGZ
		call	CalcObjSubDiv

		mov	ax,A4
		mov	di,OFFSET YGX
		call	CalcObjSubDiv

		mov	ax,A5
		mov	di,OFFSET YGY
		call	CalcObjSubDiv

		mov	ax,A6
		mov	di,OFFSET YGZ
		call	CalcObjSubDiv

		mov	ax,A7
		mov	di,OFFSET ZGX
		call	CalcObjSubDiv

		mov	ax,A8
		mov	di,OFFSET ZGY
		call	CalcObjSubDiv

		mov	ax,A9
		mov	di,OFFSET ZGZ
		call	CalcObjSubDiv

		ret

CalcObjGrid	ENDP

;----------------------------------------------------------------------------

;* CalcRotateGrid1 - calculate rotated object grid with skew only
;*
;* pass: B1, B2, B3
;*       B4, B5, B6
;*       B7, B8, B9
;*       XGridSize,YGridSize
;* ret : R_XGX[], R_XGY[]
;*       R_YGX[], R_YGY[]
;*       R_ZGX[], R_ZGY[]
;* kill: assume all
;*
;* note: R_XGZ[] = XGZ[] )
;*       R_YGZ[] = YGZ[] ) no need calc these grids (use XGZ[], YGZ[] and ZGZ[])
;*       R_ZGZ[] = ZGZ[] )

CalcRotateGrid1	PROC	NEAR

		mov	ax,B1
		mov	si,XGridSize
		mov	di,OFFSET R_XGX
		call	CalcObjVSubDiv 
		
		mov	ax,B2
		mov	si,YGridSize
		mov	di,OFFSET R_XGY
		call	CalcObjVSubDiv

		mov	ax,B4
		mov	si,XGridSize
		mov	di,OFFSET R_YGX
		call	CalcObjVSubDiv

		mov	ax,B5
		mov	si,YGridSize
		mov	di,OFFSET R_YGY
		call	CalcObjVSubDiv

		mov	ax,B7
		mov	si,XGridSize
		mov	di,OFFSET R_ZGX
		call	CalcObjVSubDiv

		mov	ax,B8
		mov	si,YGridSize
		mov	di,OFFSET R_ZGY
		call	CalcObjVSubDiv

		ret

CalcRotateGrid1	ENDP

;----------------------------------------------------------------------------

;* CalcRotateGrid2 - calculate rotated object grid with skew and pitch
;*
;* pass: C1, C2, C3
;*       C4, C5, C6
;*       C7, C8, C9
;*       XGridSize,YGridSize,ZGridSize
;* ret : R_XGX[], R_XGY[], R_XGZ[]
;*       R_YGX[], R_YGY[], R_YGZ[]
;*       R_ZGX[], R_ZGY[], R_ZGZ[]
;* kill: assume all

CalcRotateGrid2	PROC	NEAR

		mov	ax,C1
		mov	si,XGridSize
		mov	di,OFFSET R_XGX
		call	CalcObjVSubDiv 
		
		mov	ax,C2
		mov	si,YGridSize
		mov	di,OFFSET R_XGY
		call	CalcObjVSubDiv

		mov	ax,C3
		mov	si,ZGridSize
		mov	di,OFFSET R_XGZ
		call	CalcObjVSubDiv

		mov	ax,C4
		mov	si,XGridSize
		mov	di,OFFSET R_YGX
		call	CalcObjVSubDiv

		mov	ax,C5
		mov	si,YGridSize
		mov	di,OFFSET R_YGY
		call	CalcObjVSubDiv

		mov	ax,C6
		mov	si,ZGridSize
		mov	di,OFFSET R_YGZ
		call	CalcObjVSubDiv

		mov	ax,C7
		mov	si,XGridSize
		mov	di,OFFSET R_ZGX
		call	CalcObjVSubDiv

		mov	ax,C8
		mov	si,YGridSize
		mov	di,OFFSET R_ZGY
		call	CalcObjVSubDiv

		mov	ax,C9
		mov	si,ZGridSize
		mov	di,OFFSET R_ZGZ
		call	CalcObjVSubDiv

		ret

CalcRotateGrid2	ENDP

;----------------------------------------------------------------------------

;* CalcRotateGrid3 - calculate rotated object grid with skew, pitch and roll
;*
;* pass: D1, D2, D3
;*       D4, D5, D6
;*       D7, D8, D9
;*       XGridSize,YGridSize,ZGridSize
;* ret : R_XGX[], R_XGY[], R_XGZ[]
;*       R_YGX[], R_YGY[], R_YGZ[]
;*       R_ZGX[], R_ZGY[], R_ZGZ[]
;* kill: assume all

CalcRotateGrid3	PROC	NEAR

		mov	ax,D1
		mov	si,XGridSize
		mov	di,OFFSET R_XGX
		call	CalcObjVSubDiv 
		
		mov	ax,D2
		mov	si,YGridSize
		mov	di,OFFSET R_XGY
		call	CalcObjVSubDiv

		mov	ax,D3
		mov	si,ZGridSize
		mov	di,OFFSET R_XGZ
		call	CalcObjVSubDiv

		mov	ax,D4
		mov	si,XGridSize
		mov	di,OFFSET R_YGX
		call	CalcObjVSubDiv

		mov	ax,D5
		mov	si,YGridSize
		mov	di,OFFSET R_YGY
		call	CalcObjVSubDiv

		mov	ax,D6
		mov	si,ZGridSize
		mov	di,OFFSET R_YGZ
		call	CalcObjVSubDiv

		mov	ax,D7
		mov	si,XGridSize
		mov	di,OFFSET R_ZGX
		call	CalcObjVSubDiv

		mov	ax,D8
		mov	si,YGridSize
		mov	di,OFFSET R_ZGY
		call	CalcObjVSubDiv

		mov	ax,D9
		mov	si,ZGridSize
		mov	di,OFFSET R_ZGZ
		call	CalcObjVSubDiv

		ret

CalcRotateGrid3	ENDP

;----------------------------------------------------------------------------

;* CalcObjVSubDiv - calculate object grid sub-divisions (variable grid size)
;*
;* pass: ax = factor
;*       si = grid size (0 .. 32)
;*       di -> object grid sub-divisions array
;* ret : di[]
;* kill: assume all

CalcObjVSubDiv	PROC	NEAR

		test	ax,ax
	
		js	NegObjVSubDiv	;neg value ->

PosObjVSubDiv:	mov	ch,al		;bx, cx = 65536 * value / 64 / 32
		xor	cl,cl		
		mov	bl,ah
		xor	bh,bh
		REPT	3
		shr	bx,1
		rcr	cx,1
		ENDM

		mul	si		;dx, ax = value * grid size

		mov	dh,al		;ax, dx = (65536 * value) * (grid size / 32) / 64
		mov	al,ah
		mov	ah,dl
		xor	dl,dl
		REPT	3
		shr	ax,1
		rcr	dx,1
		ENDM
		
		shl	si,1		;*2 index

		jmp	CalcPosSubDiv[si]

NegObjVSubDiv:	neg	ax		;make positive

		mov	ch,al		;bx, cx = 65536 * value / 64 / 32
		xor	cl,cl		
		mov	bl,ah
		xor	bh,bh
		REPT	3
		shr	bx,1
		rcr	cx,1
		ENDM

		mul	si		;dx, ax = value * grid size

		mov	dh,al		;ax, dx = (65536 * value) * (grid size / 32) / 64
		mov	al,ah
		mov	ah,dl
		xor	dl,dl
		REPT	3
		shr	ax,1
		rcr	dx,1
		ENDM

		shl	si,1		;*2 index

		jmp	CalcNegSubDiv[si]

CalcObjVSubDiv	ENDP

;----------------------------------------------------------------------------

;* CalcObjSubDiv - calculate object grid sub-divisions (+/-512 step 16)
;*
;* pass: ax = "A" factor
;*       di -> object grid sub-divisions array
;* ret : di[]
;* kill: assume all

ZeroObjSubDiv	LABEL	NEAR
	
		mov	cx,65		;set all values to 0
		rep	stosw
		ret

CalcObjSubDiv	PROC	NEAR

		test	ax,ax
	
		jz	ZeroObjSubDiv	;all values are zero ->
		jns	PosObjSubDiv	;pos value ->
		jmp	NegObjSubDiv	;neg value ->

PosObjSubDiv:	mov	dh,al		;ax, dx = 65536 * value / 256
		xor	dl,dl
		mov	al,ah
		xor	ah,ah
		
		mov	bx,ax		;bx, cx = 65536 * value / 256
		mov	cx,dx
	
		REPT	2		;ax, dx = 65536 * value / 64 (for +/-512 grid)
		shl	dx,1
		rcl	ax,1
		ENDM

		REPT	3		;bx, cx = 65536 * value / 64 / 32
		shr	bx,1
		rcr	cx,1
		ENDM

MIDVAL		=	32*2		
INDEX		=	32*2
COUNT		=	32		

CALCPOS		MACRO	N

PosSubDiv&N:	mov	[di][MIDVAL+INDEX],ax
		neg	ax
		mov	[di][MIDVAL-INDEX],ax

		ENDM

		REPT	32

		CALCPOS	%COUNT

		IF	INDEX NE 2
		neg	ax
		sub	dx,cx
		sbb	ax,bx
		ENDIF

INDEX		=	INDEX-2
COUNT		=	COUNT-1
		ENDM

PosSubDiv0:	ret

NegObjSubDiv:	neg	ax		;make positive

		mov	dh,al		;ax, dx = 65536 * value / 256
		xor	dl,dl
		mov	al,ah
		xor	ah,ah
		
		mov	bx,ax		;bx, cx = 65536 * value / 256
		mov	cx,dx
	
		REPT	2		;ax, dx = 65536 * value / 64 (for +/-512 grid)
		shl	dx,1
		rcl	ax,1
		ENDM

		REPT	3		;bx, cx = 65536 * value / 64 / 32
		shr	bx,1
		rcr	cx,1
		ENDM

MIDVAL		=	32*2		
INDEX		=	32*2
COUNT		=	32		

CALCNEG		MACRO	N

NegSubDiv&N:	mov	[di][MIDVAL-INDEX],ax
		neg	ax
		mov	[di][MIDVAL+INDEX],ax

		ENDM

		REPT	32

		CALCNEG	%COUNT

		IF	INDEX NE 2
		neg	ax
		sub	dx,cx
		sbb	ax,bx
		ENDIF

INDEX		=	INDEX-2
COUNT		=	COUNT-1
		ENDM

NegSubDiv0:	ret

CalcObjSubDiv	ENDP

;----------------------------------------------------------------------------

;* CalcSctrOffsets - calculate rel co-ords and eye co-ords of sector sub-div
;*                   offsets for all visuals
;*
;* pass: "A" factors
;*       V_VIEW.VP_XFT
;*       V_VIEW.VP_YFT
;*       ZScaled
;* ret :   XRel1,   YRel1,   ZRel1
;*          XE01,    YE01,    ZE01
;*        XE01_2,  YE01_2,  ZE01_2 )
;*        XE01_4,  YE01_4,  ZE01_4 ) only valid if zft in range
;*        XE01_8,  YE01_8,  ZE01_8 ) 
;*       XE01_16, YE01_16, ZE01_16 )
;*         XRel2,   YRel2,   ZRel2
;*          XE02,    YE02,    ZE02
;*         XRel8,   YRel8,   ZRel8
;*          XE08,    YE08,    ZE08
;*        XRel16,  YRel16,  ZRel16
;*         XE016,   YE016,   ZE016
;* kill: assume all

CalcSctrOffsets	PROC	NEAR

;-----------------------
;* current sector visual (including values for overscaled objects)
;-----------------------

		xor	al,al	 	;clear all valid flags
		mov	Valid1_2,al
		mov	Valid1_4,al
		mov	Valid1_8,al
		mov	Valid1_16,al

		mov	ax,ZScaled
		mov	bp,ax
		neg	ax
	   	mov	ZRel1,ax
		mov	cx,ax

		mov	ax,V_VIEW.VP_YFT
		and	ax,000ffh	;256 sub-div
		neg	ax
		mov	YRel1,ax
		mov	bx,ax

		mov	ax,V_VIEW.VP_XFT
		and	ax,000ffh	;256 sub-div
		neg	ax
		mov	XRel1,ax
		
		xor	si,si		;reset index

	 	cmp	bp,MAX_RANGE16	;zft in range for 16 * overscaled values?
		jb	ScaleSwitch	;yes ->
		add	si,2

	 	cmp	bp,MAX_RANGE8	;zft in range for 8 * overscaled values?
		jb	ScaleSwitch	;yes ->
		add	si,2

	 	cmp	bp,MAX_RANGE4	;zft in range for 4 * overscaled values?
		jb	ScaleSwitch	;yes ->
		add	si,2

	 	cmp	bp,MAX_RANGE2	;zft in range for 2 * overscaled values?
		jb	ScaleSwitch	;yes ->
		add	si,2

ScaleSwitch:	jmp	CalcScale[si]

;* calc values for all scales up to * 16 overscaled

CalcScale16:	REPT	4
		shl	ax,1		;x rel * 16
		shl	bx,1		;y rel * 16
		shl	cx,1		;z rel * 16
		ENDM

		call	CalcEyePosition

		jmp	StoreScale16

;* calc values for all scales up to * 8 overscaled

CalcScale8:	REPT	3
		shl	ax,1		;x rel * 8
		shl	bx,1		;y rel * 8
		shl	cx,1		;z rel * 8
		ENDM

		call	CalcEyePosition

		jmp	StoreScale8

;* calc values for all scales up to * 4 overscaled

CalcScale4:	REPT	2
		shl	ax,1		;x rel * 4
		shl	bx,1		;y rel * 4
		shl	cx,1		;z rel * 4
		ENDM

		call	CalcEyePosition

		jmp	StoreScale4

;* calc values for all scales up to * 2 overscaled

CalcScale2:	REPT	1
		shl	ax,1		;x rel * 2
		shl	bx,1		;y rel * 2
		shl	cx,1		;z rel * 2
		ENDM

		call	CalcEyePosition

		jmp	StoreScale2

;* calc values for normal scaling only

CalcScale1: 	call	CalcEyePosition

		jmp	StoreScale1

StoreScale16:	mov	XE01_16,ax
		mov	YE01_16,bx
		mov	ZE01_16,cx

		sar	ax,1
		sar	bx,1
		sar	cx,1
		
		mov	Valid1_16,1	;set valid flag

StoreScale8:	mov	XE01_8,ax
		mov	YE01_8,bx
		mov	ZE01_8,cx

		sar	ax,1
		sar	bx,1
		sar	cx,1

		mov	Valid1_8,1	;set valid flag

StoreScale4:	mov	XE01_4,ax
		mov	YE01_4,bx
		mov	ZE01_4,cx

		sar	ax,1
		sar	bx,1
		sar	cx,1

		mov	Valid1_4,1	;set valid flag

StoreScale2:	mov	XE01_2,ax
		mov	YE01_2,bx
		mov	ZE01_2,cx

		sar	ax,1
		sar	bx,1
		sar	cx,1

		mov	Valid1_2,1	;set valid flag

StoreScale1:	mov	XE01,ax
		mov	YE01,bx
		mov	ZE01,cx

;----------------------
;* 3 by 3 sector visual
;----------------------

		mov	ax,ZScaled
		neg	ax
		sar	ax,1
	   	mov	ZRel2,ax
		mov	cx,ax

		mov	ax,V_VIEW.VP_YFT
		and	ax,001ffh	;512 sub-div
		neg	ax
		sar	ax,1
		mov	YRel2,ax
		mov	bx,ax

		mov	ax,V_VIEW.VP_XFT
		and	ax,001ffh	;512 sub-div
		neg	ax
		sar	ax,1
		mov	XRel2,ax
		
		call	CalcEyePosition

		mov	XE02,ax
		mov	YE02,bx
		mov	ZE02,cx

;----------------------
;* 7 by 7 sector visual
;----------------------

		mov	ax,ZScaled
		neg	ax
		sar	ax,1
		sar	ax,1
		sar	ax,1
	   	mov	ZRel8,ax
		mov	cx,ax

		mov	ax,V_VIEW.VP_YFT
		and	ax,007ffh	;2048 sub-div
		neg	ax
		sar	ax,1
		sar	ax,1
		sar	ax,1
		mov	YRel8,ax
		mov	bx,ax

		mov	ax,V_VIEW.VP_XFT
		and	ax,007ffh	;2048 sub-div
		neg	ax
		sar	ax,1
		sar	ax,1
		sar	ax,1
		mov	XRel8,ax
		
		call	CalcEyePosition

		mov	XE08,ax
		mov	YE08,bx
		mov	ZE08,cx

;------------------------
;* 15 by 15 sector visual
;------------------------

		mov	ax,ZScaled
		neg	ax
		sar	ax,1
		sar	ax,1
		sar	ax,1
		sar	ax,1
	   	mov	ZRel16,ax
		mov	cx,ax

		mov	ax,V_VIEW.VP_YFT
		and	ax,00fffh	;4096 sub-div
		neg	ax
		sar	ax,1
		sar	ax,1
		sar	ax,1
		sar	ax,1
		mov	YRel16,ax
		mov	bx,ax

		mov	ax,V_VIEW.VP_XFT
		and	ax,00fffh	;4096 sub-div
		neg	ax
		sar	ax,1
		sar	ax,1
		sar	ax,1
		sar	ax,1
		mov	XRel16,ax
		
		call	CalcEyePosition

		mov	XE016,ax
		mov	YE016,bx
		mov	ZE016,cx

		ret

CalcSctrOffsets	ENDP

;----------------------------------------------------------------------------

;* CalcEyePosition - calc eye co-ords from rel co-ords
;*
;* pass: ax = x rel
;*       bx = y rel
;*       cx = z rel
;* ret : ax = x eye
;*       bx = y eye
;*       cx = z eye
;* kill: dx, si, di, bp, flags

CalcEyePosition	PROC	NEAR

		mov	si,ax
		mov	di,bx
		push	cx

		mov	ax,A1
		imul	si
		FRACADJ	bp		;bp = A1.x rel

		mov	ax,A4
		imul	si
		FRACADJ	bx		;bx = A4.x rel

		mov 	ax,A7
		imul 	si
		FRACADJ	cx		;cx = A7.x rel

		mov	ax,A2
		imul 	di
		FRACADJ	dx
		add 	bp,dx		;bp = A1.x rel + A2.y rel

		mov	ax,A5
		imul	di
		FRACADJ	dx
		add	bx,dx		;bx = A4.x rel + A5.y rel

		mov	ax,A8
		imul	di
		FRACADJ	dx
		add	cx,dx		;cx = A7.x rel + A8.y rel

		pop	si

		mov	ax,A6
		imul 	si
		FRACADJ	dx
		add	bx,dx		;bx = A4.x rel + A5.y rel + A6.z rel

		mov	ax,A9
		imul	si
		FRACADJ	dx
		add	cx,dx		;cx = A7.x rel + A8.y rel + A9.z rel

		mov	ax,A3
		imul	si
		FRACADJ	ax
		add	ax,bp		;ax = A1.x rel + A2.y rel + A3.z rel

		ret

CalcEyePosition	ENDP

;----------------------------------------------------------------------------

;* RotateView
;*
;* pass: ViewRotateMode
;* ret : nothing
;* kill: assume all

RotateView	PROC	NEAR

		mov	bx,ViewRotateMode
		jmp	RotateSwitch[bx]

;---------------------------
RotateNull	LABEL	NEAR
;---------------------------

		ret

;---------------------------
RotateViewRt	LABEL	NEAR
;---------------------------

;* xe = -ye
;* ye = xe

		mov	ax,A4
		neg	ax
		xchg	ax,A1
		mov	A4,ax

		mov	ax,A5
		neg	ax
		xchg	ax,A2
		mov	A5,ax

		mov	ax,A6
		neg	ax
		xchg	ax,A3
		mov	A6,ax

		jmp	ContRotate

;---------------------------
RotateViewLt	LABEL	NEAR
;---------------------------

;* xe = ye
;* ye = -xe

		mov	ax,A1
		neg	ax
		xchg	ax,A4
		mov	A1,ax

		mov	ax,A2
		neg	ax
		xchg	ax,A5
		mov	A2,ax

		mov	ax,A3
		neg	ax
		xchg	ax,A6
		mov	A3,ax

		jmp	ContRotate

;---------------------------
RotateViewUp	LABEL	NEAR
;---------------------------

;* A4 = A4.cos(45) + A7.sin(45)
;* A7 = A7.cos(45) - A4.sin(45)

		mov	ax,A4
		mov	dx,23170
		imul	dx
		FRACADJ	cx		;cx = A4.sin(45) = A4.cos(45)
		mov	ax,A7
		mov	dx,23170
		imul	dx
		FRACADJ	dx		;dx = A7.sin(45) = A7.cos(45)
		mov	ax,cx
		add	ax,dx
		mov	A4,ax
		sub	dx,cx
		mov	A7,dx

;* A5 = A5.cos(45) + A8.sin(45)
;* A8 = A8.cos(45) - A5.sin(45)

		mov	ax,A5
		mov	dx,23170
		imul	dx
		FRACADJ	cx		;cx = A5.sin(45) = A5.cos(45)
		mov	ax,A8
		mov	dx,23170
		imul	dx
		FRACADJ	dx	    	;dx = A8.sin(45) = A8.cos(45)
		mov	ax,cx
		add	ax,dx
		mov	A5,ax
		sub	dx,cx
		mov	A8,dx

;* A6 = A6.cos(45) + A9.sin(45)
;* A9 = A9.cos(45) - A6.sin(45)

		mov	ax,A6
		mov	dx,23170
		imul	dx
		FRACADJ	cx		;cx = A6.sin(45) = A6.cos(45)
		mov	ax,A9
		mov	dx,23170
		imul	dx
		FRACADJ	dx		;dx = A9.sin(45) = A9.cos(45)
		mov	ax,cx
		add	ax,dx
		mov	A6,ax
		sub	dx,cx
		mov	A9,dx

;* new hdg = arctan360(A4 / A5)

		mov	cx,A4
		mov	dx,A5
		call	ArcTan360

		mov	cl,7
		shr	ax,cl
		ROUNDUP	ax
		and	ax,001ffh

		mov	V_VIEW.VP_HDG,ax

		jmp	ContRotate

;---------------------------
RotateViewDn	LABEL	NEAR
;---------------------------

;* ye = -ze
;* ze = ye

		mov	ax,A7
		neg	ax
		xchg	ax,A4
		mov	A7,ax

		mov	ax,A8
		neg	ax
		xchg	ax,A5
		mov	A8,ax

		mov	ax,A9
		neg	ax
		xchg	ax,A6
		mov	A9,ax

		jmp	ContRotate

;---------------------------
RotateViewBk	LABEL	NEAR
;---------------------------

;* xe = -xe

		neg	A1
		neg	A2
		neg	A3

;* ye = -ye

		neg	A4
		neg	A5
		neg	A6

;* roll = -roll

		mov	ax,V_VIEW.VP_ROLL
		neg	ax
		and	ax,511
		mov	V_VIEW.VP_ROLL,ax

;* pitch = -pitch

		mov	ax,V_VIEW.VP_PITCH
		neg	ax
		and	ax,511
		mov	V_VIEW.VP_PITCH,ax

		call	CalcAngles

		ret

;---------------------------
ContRotate	LABEL	NEAR
;---------------------------

;----------------
;* calc new pitch
;----------------

;* new pitch = arcsin(A6)

		mov	ax,A6

		call	FastArcSin

;* convert fine pdegs to pdegs

		mov	cl,7
		shr	ax,cl
		ROUNDUP	ax
		and	ax,001ffh

		mov	V_VIEW.VP_PITCH,ax

;---------------
;* calc new roll
;---------------

;* if pitch = 90 degs or pitch = -90 degs then
;*    new roll = 0
;* else
;*    new roll = arctan360(-A3 / A9)
;* endif

		xor	dx,dx

		cmp	ax,128
		je	@F
		cmp	ax,384
		je	@F

		mov	cx,A3
		neg	cx
		mov	dx,A9

		call	ArcTan360

		mov	cl,7
		shr	ax,cl
		ROUNDUP	ax
		and	ax,001ffh

		mov	dx,ax

@@:		mov	V_VIEW.VP_ROLL,dx

		call	CalcAngles

		ret

RotateView	ENDP

VISCODE		ENDS

;============================================================================

		END

