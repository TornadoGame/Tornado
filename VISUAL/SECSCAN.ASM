;****************************************************************************
;*
;* SECSCAN.ASM
;*
;* Sector scanning routines.
;*
;* 04.01.1991 - KJB
;* 13.01.1992 - KJB - Sector rejection optimized.
;* 05.01.1992 - KJB - ScanTrees added.
;*                    NoMansLand flag added.
;* 16.03.1992 - KJB - Overcast test added.
;* 31.08.1992 - KJB - "static" mobiles added.
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	ScanSectors

		EXTRN	QuickOutCodes:NEAR
		EXTRN	DrawFeatures1:NEAR
		EXTRN	DrawFeatures2:NEAR
		EXTRN	DrawRivers:NEAR
		EXTRN	DrawRoads:NEAR
		EXTRN	DrawRailways:NEAR
		EXTRN	ScanHills:NEAR
		EXTRN	DrawSector:NEAR
		EXTRN	DrawSpecials:NEAR
		EXTRN	ScanTrees:NEAR
		EXTRN	DrawStatMobiles:NEAR

		EXTRN	CloudMode:WORD

		EXTRN	HillLayer9:BYTE
		EXTRN	Overcast:BYTE

		EXTRN	CLOUD_MODE1:ABS

;============================================================================

		INCLUDE	VISEXTRN.INC
		INCLUDE	VISDATA.INC

		INCLUDE	\LIB8086\USEFUL.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

OBJ_Z_THRES	EQU	(16384-7500)*4	;object z threshold (scaled)

CalcSctrCentre	DW	CalcCentre1	;SEC_SCALE1
		DW	CalcCentre2	;SEC_SCALE2
		DW	CalcCentre8	;SEC_SCALE8
		DW	CalcCentre16	;SEC_SCALE16

SectorReject	DW	TestSector1	;SEC_SCALE1
		DW	TestSector2	;SEC_SCALE2
		DW	TestSector8	;SEC_SCALE8
		DW	TestSector16	;SEC_SCALE16

FlatScanMaxOff	DW	0		;flat scan size max offset

HillsOnlyFlag	DB	0		;0 = normal sector, 1 = hills only sector

CompRejectTest	DB	0		;1 = complete (slow) sector reject test
					;0 = incomplete (fast) sector reject test

		EVEN

DATA		ENDS

;============================================================================

VISCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:VISCODE
		ASSUME DS:DATA

;* ScanSectors - scan sectors for flat ground detail and ground objects
;*
;* pass: V_VIEW
;* ret : nothing
;* kill: assume all

ScanSectors	PROC	NEAR

		mov	NumVisSctrs,0	;reset visible sector counter

;--------------------------------------------
;* test visibility wrt Overcast and CloudMode
;--------------------------------------------

		test	OverCast,1	;overcast?
		jz	@F		;no ->

		cmp	CloudMode,CLOUD_MODE1	;below clouds?
		_JNE	ExitSectors		;no ->
	
;----------------------------------------------------------------------
;* calculate flat scan size wrt zft (still draw hills to max scan size)
;----------------------------------------------------------------------

@@:		mov	ax,WORD PTR V_VIEW.VP_ZFT_HI
		test	ax,ax	   	;zft > 65,535ft?
		jnz	MaxScanSize	;yes ->

		mov	ax,WORD PTR V_VIEW.VP_ZFT_LO
		cmp	ax,7*512	;zft >= z threshold?
		jae	MaxScanSize	;yes ->

		mov	al,ah		;/256
		and	ax,1110b	;/512 * 2 = 0 .. 12 step 2
		add	ax,3		;+3 = MIN_SEC_SCAN .. MAX_SEC_SCAN step 2

		cmp	ax,SecScanCnt1	;scan size <= max scan size?
		jbe	SetScanSize	;yes ->

MaxScanSize:	mov	ax,SecScanCnt1	;use max scan size

SetScanSize:	shr	ax,1		;max offset (count / 2)
		mov	FlatScanMaxOff,ax

;--------------------------------
;* for y sector offset = -n to +n
;--------------------------------

		mov	cx,SecScanCnt1	;y count
		mov	di,SecScanOff1	;y sector offset

ScanYLoop1:	push	cx
		push	di

;--------------------------------
;* for x sector offset = -m to +m
;--------------------------------

		mov	cx,SecScanCnt1	;x count
		mov	si,SecScanOff1	;x sector offset

ScanXLoop1:	push	cx
		push	si
		push	di

;-------------------------
;* calc sector map co-ords
;-------------------------

		mov	ax,V_VIEW.VP_XSEC
		add	ax,si		;x sec = vp x sec + x sec offset
		mov	dx,ax
		mov	ax,V_VIEW.VP_YSEC
		add	ax,di		;y sec = vp y sec + y sec offset

		mov	XSecScan,dx
		mov	YSecScan,ax

;-------------------------------------------------------
;* is the sector inside the map area or in no mans land?
;-------------------------------------------------------

		mov	bl,1		;assume outside map

		cmp	dx,32		;x sec inside map?
		jae	@F		;no ->
		cmp	ax,32		;y sec inside map?
		jae	@F		;no ->

		xor	bl,bl

@@:		mov	NoMansLand,bl

;-------------------------------------
;* sector wrap around for no mans land
;-------------------------------------

		and	dx,MAP_X_WRAP
		and	ax,MAP_Y_WRAP
		
;-------------------------------------
;* calc map index = x sec + y sec * 32
;-------------------------------------

		REPT	5
		shl	ax,1
		ENDM
		add	ax,dx

		mov	MapIndex,ax

;------------------------------------
;* draw complete sector or hills only
;------------------------------------

		mov	bp,ax

		mov	HillsOnlyFlag,0

;* if hills in sector then do complete sector reject test

		mov	al,HillLayer9[bp]
		rol	al,1
		and	al,001h		;1 = hills in sector
		mov	CompRejectTest,al

;* is x index inside or outside flat scan range?

		mov	ax,si
		ABSV	ax
		cmp	ax,FlatScanMaxOff
		ja	CheckForHills	;outside flat scan range ->

;* is y index inside or outside flat scan range?

		mov	ax,di
		ABSV	ax
		cmp	ax,FlatScanMaxOff
		jbe	ContSector1	;inside flat scan range ->

;* are there hills in this sector?

CheckForHills:	mov	al,HillLayer9[bp]
		test	al,al
		jns	SkipSector1	;no hills ->

		mov	HillsOnlyFlag,1

;------------------------
;* calc sector scale mode
;------------------------

ContSector1:	call	CalcSctrScale

;-----------------------------------------------------------
;* calc sector centre position and test if sector is visible
;-----------------------------------------------------------

		call	CalcSctrCentre[bx]

		call	SectorReject[bx]
		jc	SkipSector1	;sector non-visible ->

		inc	NumVisSctrs	;update visible sector counter

;-----------------------------------
;* draw flat ground detail and hills
;-----------------------------------

		test	HillsOnlyFlag,1	;hills only?
		jnz	Hills 		;yes ->

	       	call	DrawFeatures1

		test	NoMansLand,1	;no man's land?
		jnz	@F		;yes ->
	       	call	DrawFeatures2

@@:	       	call	DrawRivers
	       	call	DrawRoads
	       	call	DrawRailways

		test	NoMansLand,1	;no man's land?
		jnz	Hills		;yes ->
	       	call	DrawSpecials

Hills: 		call	ScanHills

;---------------
;* next x sector
;---------------

SkipSector1:	pop	di
		pop	si
		pop	cx
		add	si,1		;x = x + 1
		dec	cx
		jz	EndXLoop1
		jmp	ScanXLoop1
EndXLoop1:

;---------------
;* next y sector
;---------------

		pop	di
		pop	cx
		add	di,1		;y = y + 1
		dec	cx
		jz	EndYLoop1
		jmp	ScanYLoop1
EndYLoop1:

;--------------------------------------
;* draw sector objects in 3 by 3 visual
;--------------------------------------

;* check if zft is above ground object z threshold

		mov	ax,WORD PTR V_VIEW.VP_ZFT_HI
		test	ax,ax	   	;zft > 65,535ft?
		_JNZ	ExitSectors	;yes ->

		mov	ax,WORD PTR V_VIEW.VP_ZFT_LO
		cmp	ax,OBJ_Z_THRES	;zft >= z threshold?
		_JAE	ExitSectors	;yes ->

;* always do complete sector reject test

		mov	CompRejectTest,1

;--------------------------------
;* for y sector offset = -1 to +1
;--------------------------------

		mov	cx,3		;y count
		mov	di,-1		;y sector offset

ScanYLoop2:	push	cx
		push	di

;--------------------------------
;* for x sector offset = -1 to +1
;--------------------------------

		mov	cx,3		;x count
		mov	si,-1		;x sector offset

ScanXLoop2:	push	cx
		push	si
		push	di

;-------------------------
;* calc sector map co-ords
;-------------------------

		mov	ax,V_VIEW.VP_XSEC
		add	ax,si		;x sec = vp x sec + x sec offset
		mov	dx,ax
		mov	ax,V_VIEW.VP_YSEC
		add	ax,di		;y sec = vp y sec + y sec offset

		mov	XSecScan,dx
		mov	YSecScan,ax

;-------------------------------------------------------
;* is the sector inside the map area or in no mans land?
;-------------------------------------------------------

		mov	bl,1		;assume outside map

		cmp	dx,32		;x sec inside map?
		jae	@F		;no ->
		cmp	ax,32		;y sec inside map?
		jae	@F		;no ->

		xor	bl,bl

@@:		mov	NoMansLand,bl
	
;-------------------------------------
;* sector wrap around for no mans land
;-------------------------------------

		and	dx,MAP_X_WRAP
		and	ax,MAP_Y_WRAP
		
;-------------------------------------
;* calc map index = x sec + y sec * 32
;-------------------------------------

		REPT	5
		shl	ax,1
		ENDM
		add	ax,dx

		mov	MapIndex,ax

;------------------------
;* calc sector scale mode
;------------------------

		call	CalcSctrScale

;-----------------------------------------------------------
;* calc sector centre position and test if sector is visible
;-----------------------------------------------------------

		push	si		;store x sec offset
		push	di		;store y sec offset

		call	CalcSctrCentre[bx]

		call	SectorReject[bx]

		pop	di		;restore y sec offset
		pop	si		;restore x sec offset

		jc	SkipSector2	;sector non-visible ->

;------------------------
;* draw objects in sector
;------------------------

		test	NoMansLand,1	;no man's land?
		jnz	@F		;yes ->

		push	si
		push	di
		call	DrawSector
		pop	di
		pop	si

		push	si
		push	di
		call	DrawStatMobiles
		pop	di
		pop	si

@@:		call	ScanTrees

;---------------
;* next x sector
;---------------

SkipSector2:	pop	di
		pop	si
		pop	cx
		add	si,1		;x = x + 1
		loop	ScanXLoop2

;---------------
;* next y sector
;---------------

		pop	di
		pop	cx
		add	di,1		;y = y + 1
		loop	ScanYLoop2

ExitSectors:	ret

ScanSectors	ENDP

;----------------------------------------------------------------------------

;* CalcSctrScale - calc sector scale mode
;*
;* pass: si = x sector offset (-7 .. +7)
;*       di = y sector offset (-7 .. +7)
;*       V_VIEW.VP_ZFT
;* ret : bx = SctrScaleMode
;* kill: ax, cx, dx, bp, flags 

CalcSctrScale	PROC	NEAR

		mov	bx,SEC_SCALE16	;assume > 3 sectors

		mov	ax,si
		ABSV	ax		;ax = abs(x sec offset)
		cmp	ax,3	  	;> 3 sectors?
		ja	SetScaleMode	;yes ->
		mov	cx,ax
		
		mov	ax,di
		ABSV	ax		;ax = abs(y sec offset)
		cmp	ax,3		;> 3 sectors?
		ja	SetScaleMode	;yes ->
		mov	bp,ax
	
		mov	bx,SEC_SCALE8	;assume zft >= 8,192ft

		mov	ax,WORD PTR V_VIEW.VP_ZFT_HI
		test	ax,ax		;zft > 65,535ft?
		jnz	SetScaleMode	;yes ->

		mov	ax,WORD PTR V_VIEW.VP_ZFT_LO
		cmp	ax,8192		;zft >= 8,192ft?
		jae	SetScaleMode	;yes ->

		mov	bx,SEC_SCALE1	;assume current sector

		mov	ax,si
		or	ax,di		;current sector?
		jz	SetScaleMode	;yes ->

		mov	bx,SEC_SCALE8	;assume not adjacent to current sector

		cmp	cx,1		;adjacent to current sector?
		ja	SetScaleMode	;no ->

		cmp	bp,1		;adjacent to current sector?
		ja	SetScaleMode	;no ->
		
		mov	bx,SEC_SCALE2	;must be adjacent to current sector

SetScaleMode:	mov	SctrScaleMode,bx

		ret

CalcSctrScale	ENDP

;----------------------------------------------------------------------------

;* CalcCentre1 - calc sector centre position for SEC_SCALE1 (current) sector
;*
;* pass: si = x sector offset
;*       di = y sector offset
;* ret : XPos1, YPos1, ZPos1
;* kill: ax, si, di, flags
;*
;* note: For current sector assume:-
;*
;*          x sector offset (si) = y sector offset (di) = 0

CalcCentre1	PROC	NEAR

;* calc current sector centre position:-
;*
;* x sector grid index = (x sec offset * 64 - XGrid1 + 32 + 64) * 2
;*
;* y sector grid index = (-(y sec offset) * 64 - YGrid1 + 32 + 64) * 2

		sub	si,XGrid1
		add	si,32+64
		shl	si,1

		sub	di,YGrid1
		add	di,32+64
		shl	di,1
	
		mov	ax,XE01
		add	ax,XSX[si]
		add	ax,XSY[di]
		mov	XPos1,ax

		mov	ax,YE01
		add	ax,YSX[si]
		add	ax,YSY[di]
		mov	YPos1,ax

		mov	ax,ZE01
		add	ax,ZSX[si]
		add	ax,ZSY[di]
		mov	ZPos1,ax

		ret

CalcCentre1	ENDP

;----------------------------------------------------------------------------

;* CalcCentre2 - calc sector centre position for SEC_SCALE2 sector
;*
;* pass: si = x sector offset
;*       di = y sector offset
;* ret : XPos2, YPos2, ZPos2
;* kill: ax, si, di, flags

CalcCentre2	PROC	NEAR

;* calc 3 by 3 visual sector centre position:-
;*
;* x sector grid index = (x sec offset * 32 - XGrid2 + 16 + 64) * 2
;*
;* y sector grid index = (-(y sec offset) * 32 - YGrid2 + 16 + 64) * 2

		neg	di		;-(y sec offset)

	  	REPT	5
		shl	si,1		;x sec offset * 32
		shl	di,1		;-(y sec offset) * 32
		ENDM

		sub	si,XGrid2
		add	si,16+64
		shl	si,1

		sub	di,YGrid2
		add	di,16+64
		shl	di,1
	
		mov	ax,XE02
		add	ax,XSX[si]
		add	ax,XSY[di]
		mov	XPos2,ax

		mov	ax,YE02
		add	ax,YSX[si]
		add	ax,YSY[di]
		mov	YPos2,ax

		mov	ax,ZE02
		add	ax,ZSX[si]
		add	ax,ZSY[di]
		mov	ZPos2,ax

		ret

CalcCentre2	ENDP

;----------------------------------------------------------------------------

;* CalcCentre8 - calc sector centre position for SEC_SCALE8 sector
;*
;* pass: si = x sector offset
;*       di = y sector offset
;* ret : XPos8, YPos8, ZPos8
;* kill: ax, si, di, flags

CalcCentre8	PROC	NEAR

;* calc 7 by 7 visual sector centre position:-
;*
;* x sector grid index = (x sec offset * 8 - XGrid8 + 4 + 64) * 2
;*
;* y sector grid index = (-(y sec offset) * 8 - YGrid8 + 4 + 64) * 2

		neg	di		;-(y sec offset)

		REPT	3
		shl	si,1		;x sec offset * 8
		shl	di,1		;-(y sec offset) * 8
		ENDM

		sub	si,XGrid8
		add	si,4+64
		shl	si,1

		sub	di,YGrid8
		add	di,4+64
		shl	di,1
	
		mov	ax,XE08
		add	ax,XSX[si]
		add	ax,XSY[di]
		mov	XPos8,ax

		mov	ax,YE08
		add	ax,YSX[si]
		add	ax,YSY[di]
		mov	YPos8,ax

		mov	ax,ZE08
		add	ax,ZSX[si]
		add	ax,ZSY[di]
		mov	ZPos8,ax

		ret

CalcCentre8	ENDP

;----------------------------------------------------------------------------

;* CalcCentre16 - calc sector centre position for SEC_SCALE16 sector
;*
;* pass: si = x sector offset
;*       di = y sector offset
;* ret : XPos16, YPos16, ZPos16
;* kill: ax, si, di, flags

CalcCentre16	PROC	NEAR

;* calc 15 by 15 visual sector centre position:-
;*
;* x sector grid index = (x sec offset * 4 - XGrid16 + 2 + 64) * 2
;*
;* y sector grid index = (-(y sec offset) * 4 - YGrid16 + 2 + 64) * 2

		neg	di		;-(y sec offset)

		REPT	2
		shl	si,1		;x sec offset * 4
		shl	di,1		;-(y sec offset) * 4
		ENDM

		sub	si,XGrid16
		add	si,2+64
		shl	si,1

		sub	di,YGrid16
		add	di,2+64
		shl	di,1
	
		mov	ax,XE016
		add	ax,XSX[si]
		add	ax,XSY[di]
		mov	XPos16,ax

		mov	ax,YE016
		add	ax,YSX[si]
		add	ax,YSY[di]
		mov	YPos16,ax

		mov	ax,ZE016
		add	ax,ZSX[si]
		add	ax,ZSY[di]
		mov	ZPos16,ax

		ret

CalcCentre16	ENDP

;----------------------------------------------------------------------------

;* TestSector1 - test if SEC_SCALE1 sector is visible
;*
;* pass: nothing
;* ret : cf = 0
;* kill: nothing

TestSector1	PROC	NEAR
	  
		clc			;current sector always visible
		ret

TestSector1	ENDP

;----------------------------------------------------------------------------

;* TestSector2 - test if SEC_SCALE2 sector is visible
;*
;* pass: XPos2, YPos2, ZPos2
;*       CompRejectTest
;* ret : cf = 0: sector visible
;*       cf = 1: sector non-visible
;* kill: assume all (except cf)

FailSector2	LABEL	NEAR

		stc			;cf = 1 = non-visible
		ret

TestSector2	PROC	NEAR

;-------------------------------
;* test if sector too far behind
;-------------------------------

		mov	ax,YPos2
		cmp	ax,-SCTR_Y_THRES/2
		jl	FailSector2

;--------------------------------------------------------------
;* test if sector perimeter at zft = 0ft and 4,096ft is visible
;--------------------------------------------------------------

X_INDEX		=	(32/2)*2
Y_INDEX		=	(32/2)*2
Z_INDEX		=	(16/2)*2

		mov	bx,XPos2
		mov	cx,ax
		mov	dx,ZPos2

;* calc points for sector perimeter at zft = 0

		mov	ax,bx
		add	ax,XSX[$MID+X_INDEX]
		add	ax,XSY[$MID+Y_INDEX]
		mov	Xe[0],ax

		mov	ax,cx
		add	ax,YSX[$MID+X_INDEX]
		add	ax,YSY[$MID+Y_INDEX]
		mov	Ye[0],ax

		mov	ax,dx
		add	ax,ZSX[$MID+X_INDEX]
		add	ax,ZSY[$MID+Y_INDEX]
		mov	Ze[0],ax

		mov	ax,bx
		add	ax,XSX[$MID+X_INDEX]
		add	ax,XSY[$MID-Y_INDEX]
		mov	Xe[2],ax

		mov	ax,cx
		add	ax,YSX[$MID+X_INDEX]
		add	ax,YSY[$MID-Y_INDEX]
		mov	Ye[2],ax

		mov	ax,dx
		add	ax,ZSX[$MID+X_INDEX]
		add	ax,ZSY[$MID-Y_INDEX]
		mov	Ze[2],ax

		mov	ax,bx
		add	ax,XSX[$MID-X_INDEX]
		add	ax,XSY[$MID-Y_INDEX]
		mov	Xe[4],ax

		mov	ax,cx
		add	ax,YSX[$MID-X_INDEX]
		add	ax,YSY[$MID-Y_INDEX]
		mov	Ye[4],ax

		mov	ax,dx
		add	ax,ZSX[$MID-X_INDEX]
		add	ax,ZSY[$MID-Y_INDEX]
		mov	Ze[4],ax

		mov	ax,bx
		add	ax,XSX[$MID-X_INDEX]
		add	ax,XSY[$MID+Y_INDEX]
		mov	Xe[6],ax

		mov	ax,cx
		add	ax,YSX[$MID-X_INDEX]
		add	ax,YSY[$MID+Y_INDEX]
		mov	Ye[6],ax

		mov	ax,dx
		add	ax,ZSX[$MID-X_INDEX]
		add	ax,ZSY[$MID+Y_INDEX]
		mov	Ze[6],ax

		test	CompRejectTest,1	;complete sector reject test?
		jnz	@F			;yes ->
		jmp	FastSector2

;* calc points for sector perimeter at zft = 4,096

@@:		add	bx,XSZ[Z_INDEX]
		add	cx,YSZ[Z_INDEX]
		add	dx,ZSZ[Z_INDEX]

		mov	ax,bx
		add	ax,XSX[$MID+X_INDEX]
		add	ax,XSY[$MID+Y_INDEX]
		mov	Xe[8],ax

		mov	ax,cx
		add	ax,YSX[$MID+X_INDEX]
		add	ax,YSY[$MID+Y_INDEX]
		mov	Ye[8],ax

		mov	ax,dx
		add	ax,ZSX[$MID+X_INDEX]
		add	ax,ZSY[$MID+Y_INDEX]
		mov	Ze[8],ax

		mov	ax,bx
		add	ax,XSX[$MID+X_INDEX]
		add	ax,XSY[$MID-Y_INDEX]
		mov	Xe[10],ax

		mov	ax,cx
		add	ax,YSX[$MID+X_INDEX]
		add	ax,YSY[$MID-Y_INDEX]
		mov	Ye[10],ax

		mov	ax,dx
		add	ax,ZSX[$MID+X_INDEX]
		add	ax,ZSY[$MID-Y_INDEX]
		mov	Ze[10],ax

		mov	ax,bx
		add	ax,XSX[$MID-X_INDEX]
		add	ax,XSY[$MID-Y_INDEX]
		mov	Xe[12],ax

		mov	ax,cx
		add	ax,YSX[$MID-X_INDEX]
		add	ax,YSY[$MID-Y_INDEX]
		mov	Ye[12],ax

		mov	ax,dx
		add	ax,ZSX[$MID-X_INDEX]
		add	ax,ZSY[$MID-Y_INDEX]
		mov	Ze[12],ax

		mov	ax,bx
		add	ax,XSX[$MID-X_INDEX]
		add	ax,XSY[$MID+Y_INDEX]
		mov	Xe[14],ax

		mov	ax,cx
		add	ax,YSX[$MID-X_INDEX]
		add	ax,YSY[$MID+Y_INDEX]
		mov	Ye[14],ax

		mov	ax,dx
		add	ax,ZSX[$MID-X_INDEX]
		add	ax,ZSY[$MID+Y_INDEX]
		mov	Ze[14],ax

		mov	si,14
		call	QuickOutCodes
		ret

FastSector2:	mov	si,6
		call	QuickOutCodes
		ret

TestSector2	ENDP

;----------------------------------------------------------------------------

;* TestSector8 - test if SEC_SCALE8 sector is visible
;*
;* pass: XPos8, YPos8, ZPos8
;*       CompRejectTest
;* ret : cf = 0: sector visible
;*       cf = 1: sector non-visible
;* kill: assume all (except cf)

FailSector8	LABEL	NEAR

		stc			;cf = 1 = non-visible
		ret

TestSector8	PROC	NEAR

;-------------------------------
;* test if sector too far behind
;-------------------------------

		mov	ax,YPos8
		cmp	ax,-SCTR_Y_THRES/8
		jl	FailSector8

;--------------------------------------------------------------
;* test if sector perimeter at zft = 0ft and 4,096ft is visible
;--------------------------------------------------------------

X_INDEX		=	(32/8)*2
Y_INDEX		=	(32/8)*2
Z_INDEX		=	(16/8)*2

		mov	bx,XPos8
		mov	cx,ax
		mov	dx,ZPos8

;* calc points for sector perimeter at zft = 0

		mov	ax,bx
		add	ax,XSX[$MID+X_INDEX]
		add	ax,XSY[$MID+Y_INDEX]
		mov	Xe[0],ax

		mov	ax,cx
		add	ax,YSX[$MID+X_INDEX]
		add	ax,YSY[$MID+Y_INDEX]
		mov	Ye[0],ax

		mov	ax,dx
		add	ax,ZSX[$MID+X_INDEX]
		add	ax,ZSY[$MID+Y_INDEX]
		mov	Ze[0],ax

		mov	ax,bx
		add	ax,XSX[$MID+X_INDEX]
		add	ax,XSY[$MID-Y_INDEX]
		mov	Xe[2],ax

		mov	ax,cx
		add	ax,YSX[$MID+X_INDEX]
		add	ax,YSY[$MID-Y_INDEX]
		mov	Ye[2],ax

		mov	ax,dx
		add	ax,ZSX[$MID+X_INDEX]
		add	ax,ZSY[$MID-Y_INDEX]
		mov	Ze[2],ax

		mov	ax,bx
		add	ax,XSX[$MID-X_INDEX]
		add	ax,XSY[$MID-Y_INDEX]
		mov	Xe[4],ax

		mov	ax,cx
		add	ax,YSX[$MID-X_INDEX]
		add	ax,YSY[$MID-Y_INDEX]
		mov	Ye[4],ax

		mov	ax,dx
		add	ax,ZSX[$MID-X_INDEX]
		add	ax,ZSY[$MID-Y_INDEX]
		mov	Ze[4],ax

		mov	ax,bx
		add	ax,XSX[$MID-X_INDEX]
		add	ax,XSY[$MID+Y_INDEX]
		mov	Xe[6],ax

		mov	ax,cx
		add	ax,YSX[$MID-X_INDEX]
		add	ax,YSY[$MID+Y_INDEX]
		mov	Ye[6],ax

		mov	ax,dx
		add	ax,ZSX[$MID-X_INDEX]
		add	ax,ZSY[$MID+Y_INDEX]
		mov	Ze[6],ax

		test	CompRejectTest,1	;complete sector reject test?
		jnz	@F			;yes ->
		jmp	FastSector8

;* calc points for sector perimeter at zft = 4,096

@@:		add	bx,XSZ[Z_INDEX]
		add	cx,YSZ[Z_INDEX]
		add	dx,ZSZ[Z_INDEX]

		mov	ax,bx
		add	ax,XSX[$MID+X_INDEX]
		add	ax,XSY[$MID+Y_INDEX]
		mov	Xe[8],ax

		mov	ax,cx
		add	ax,YSX[$MID+X_INDEX]
		add	ax,YSY[$MID+Y_INDEX]
		mov	Ye[8],ax

		mov	ax,dx
		add	ax,ZSX[$MID+X_INDEX]
		add	ax,ZSY[$MID+Y_INDEX]
		mov	Ze[8],ax

		mov	ax,bx
		add	ax,XSX[$MID+X_INDEX]
		add	ax,XSY[$MID-Y_INDEX]
		mov	Xe[10],ax

		mov	ax,cx
		add	ax,YSX[$MID+X_INDEX]
		add	ax,YSY[$MID-Y_INDEX]
		mov	Ye[10],ax

		mov	ax,dx
		add	ax,ZSX[$MID+X_INDEX]
		add	ax,ZSY[$MID-Y_INDEX]
		mov	Ze[10],ax

		mov	ax,bx
		add	ax,XSX[$MID-X_INDEX]
		add	ax,XSY[$MID-Y_INDEX]
		mov	Xe[12],ax

		mov	ax,cx
		add	ax,YSX[$MID-X_INDEX]
		add	ax,YSY[$MID-Y_INDEX]
		mov	Ye[12],ax

		mov	ax,dx
		add	ax,ZSX[$MID-X_INDEX]
		add	ax,ZSY[$MID-Y_INDEX]
		mov	Ze[12],ax

		mov	ax,bx
		add	ax,XSX[$MID-X_INDEX]
		add	ax,XSY[$MID+Y_INDEX]
		mov	Xe[14],ax

		mov	ax,cx
		add	ax,YSX[$MID-X_INDEX]
		add	ax,YSY[$MID+Y_INDEX]
		mov	Ye[14],ax

		mov	ax,dx
		add	ax,ZSX[$MID-X_INDEX]
		add	ax,ZSY[$MID+Y_INDEX]
		mov	Ze[14],ax

		mov	si,14
		call	QuickOutCodes
		ret

FastSector8: 	mov	si,6
		call	QuickOutCodes
		ret

TestSector8	ENDP

;----------------------------------------------------------------------------

;* TestSector16 - test if SEC_SCALE16 sector is visible
;*
;* pass: XPos16, YPos16, ZPos16
;*       CompRejectTest
;* ret : cf = 0: sector visible
;*       cf = 1: sector non-visible
;* kill: assume all (except cf)

FailSector16	LABEL	NEAR

		stc			;cf = 1 = non-visible
		ret

TestSector16	PROC	NEAR

;-------------------------------
;* test if sector too far behind
;-------------------------------

		mov	ax,YPos16
		cmp	ax,-SCTR_Y_THRES/16
		jl	FailSector16

;--------------------------------------------------------------
;* test if sector perimeter at zft = 0ft and 4,096ft is visible
;--------------------------------------------------------------

X_INDEX		=	(32/16)*2
Y_INDEX		=	(32/16)*2
Z_INDEX		=	(16/16)*2

		mov	bx,XPos16
		mov	cx,ax
		mov	dx,ZPos16

;* calc points for sector perimeter at zft = 0

		mov	ax,bx
		add	ax,XSX[$MID+X_INDEX]
		add	ax,XSY[$MID+Y_INDEX]
		mov	Xe[0],ax

		mov	ax,cx
		add	ax,YSX[$MID+X_INDEX]
		add	ax,YSY[$MID+Y_INDEX]
		mov	Ye[0],ax

		mov	ax,dx
		add	ax,ZSX[$MID+X_INDEX]
		add	ax,ZSY[$MID+Y_INDEX]
		mov	Ze[0],ax

		mov	ax,bx
		add	ax,XSX[$MID+X_INDEX]
		add	ax,XSY[$MID-Y_INDEX]
		mov	Xe[2],ax

		mov	ax,cx
		add	ax,YSX[$MID+X_INDEX]
		add	ax,YSY[$MID-Y_INDEX]
		mov	Ye[2],ax

		mov	ax,dx
		add	ax,ZSX[$MID+X_INDEX]
		add	ax,ZSY[$MID-Y_INDEX]
		mov	Ze[2],ax

		mov	ax,bx
		add	ax,XSX[$MID-X_INDEX]
		add	ax,XSY[$MID-Y_INDEX]
		mov	Xe[4],ax

		mov	ax,cx
		add	ax,YSX[$MID-X_INDEX]
		add	ax,YSY[$MID-Y_INDEX]
		mov	Ye[4],ax

		mov	ax,dx
		add	ax,ZSX[$MID-X_INDEX]
		add	ax,ZSY[$MID-Y_INDEX]
		mov	Ze[4],ax

		mov	ax,bx
		add	ax,XSX[$MID-X_INDEX]
		add	ax,XSY[$MID+Y_INDEX]
		mov	Xe[6],ax

		mov	ax,cx
		add	ax,YSX[$MID-X_INDEX]
		add	ax,YSY[$MID+Y_INDEX]
		mov	Ye[6],ax

		mov	ax,dx
		add	ax,ZSX[$MID-X_INDEX]
		add	ax,ZSY[$MID+Y_INDEX]
		mov	Ze[6],ax

		test	CompRejectTest,1	;complete sector reject test?
		jnz	@F			;yes ->
		jmp	FastSector16

;* calc points for sector perimeter at zft = 4,096

@@:		add	bx,XSZ[Z_INDEX]
		add	cx,YSZ[Z_INDEX]
		add	dx,ZSZ[Z_INDEX]

		mov	ax,bx
		add	ax,XSX[$MID+X_INDEX]
		add	ax,XSY[$MID+Y_INDEX]
		mov	Xe[8],ax

		mov	ax,cx
		add	ax,YSX[$MID+X_INDEX]
		add	ax,YSY[$MID+Y_INDEX]
		mov	Ye[8],ax

		mov	ax,dx
		add	ax,ZSX[$MID+X_INDEX]
		add	ax,ZSY[$MID+Y_INDEX]
		mov	Ze[8],ax

		mov	ax,bx
		add	ax,XSX[$MID+X_INDEX]
		add	ax,XSY[$MID-Y_INDEX]
		mov	Xe[10],ax

		mov	ax,cx
		add	ax,YSX[$MID+X_INDEX]
		add	ax,YSY[$MID-Y_INDEX]
		mov	Ye[10],ax

		mov	ax,dx
		add	ax,ZSX[$MID+X_INDEX]
		add	ax,ZSY[$MID-Y_INDEX]
		mov	Ze[10],ax

		mov	ax,bx
		add	ax,XSX[$MID-X_INDEX]
		add	ax,XSY[$MID-Y_INDEX]
		mov	Xe[12],ax

		mov	ax,cx
		add	ax,YSX[$MID-X_INDEX]
		add	ax,YSY[$MID-Y_INDEX]
		mov	Ye[12],ax

		mov	ax,dx
		add	ax,ZSX[$MID-X_INDEX]
		add	ax,ZSY[$MID-Y_INDEX]
		mov	Ze[12],ax

		mov	ax,bx
		add	ax,XSX[$MID-X_INDEX]
		add	ax,XSY[$MID+Y_INDEX]
		mov	Xe[14],ax

		mov	ax,cx
		add	ax,YSX[$MID-X_INDEX]
		add	ax,YSY[$MID+Y_INDEX]
		mov	Ye[14],ax

		mov	ax,dx
		add	ax,ZSX[$MID-X_INDEX]
		add	ax,ZSY[$MID+Y_INDEX]
		mov	Ze[14],ax

		mov	si,14
		call	QuickOutCodes
		ret

FastSector16:	mov	si,6
		call	QuickOutCodes
		ret

TestSector16	ENDP

VISCODE		ENDS

;============================================================================

		END

