;****************************************************************************
;*
;* CLOUDS.ASM
;*
;* Draw clouds.
;*
;* 08.04.1991 - KJB
;* 16.03.1992 - KJB - Cloud mode reorganized.
;* 22.03.1992 - KJB - RandomizeClouds routine added.
;* 08.02.1993 - KJB - CloudTop added.
;*
;* Notes:-
;*
;* Cloud data has the same format as feature data except two colour values
;* are required (refer to FEATURES.ASM).
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	InitClouds
		PUBLIC	DrawClouds1
		PUBLIC	DrawClouds2
		PUBLIC	RandomizeClouds

		PUBLIC	CloudsEnabled
		PUBLIC	CloudMode
		PUBLIC	CloudBase
		PUBLIC	CloudDepth
		PUBLIC	CloudTop

		PUBLIC	CLOUD_MODE1
		PUBLIC	CLOUD_MODE2
		PUBLIC	CLOUD_MODE3

		EXTRN	PolyFill:FAR
		EXTRN	MeshFill:FAR
		EXTRN	RvrsPolyFill:FAR
		EXTRN	RvrsMeshFill:FAR
		EXTRN	RandX:FAR

		EXTRN	CalcEyePosition:NEAR
		EXTRN	CalcOutCodes:NEAR
		EXTRN	PolyClip:NEAR

		EXTRN	CloudTable:WORD

		EXTRN	CloudLayer1:BYTE
		EXTRN	CloudLayer2:BYTE

;============================================================================

		INCLUDE	VISEXTRN.INC
		INCLUDE	VISDATA.INC
		INCLUDE	\LIB8086\USEFUL.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

CloudsEnabled	DB	1,0		;1 = enabled, 0 = disabled

CLOUD_MODE1	EQU	0		;viewpoint below clouds
CLOUD_MODE2	EQU	2		;viewpoint in clouds
CLOUD_MODE3	EQU	4		;viewpoint above clouds

CloudMode	DW	0

CloudBase	DD	4096		;0 .. 100,000ft (keep above hills 4,096)

CloudDepth	DW     	2048		;0 .. 8,192ft step 256ft

CloudTop	DD	4096+2048	;(initialized in RandomizeClouds)

ABS_Delta_ZFT	DD	0

CloudNum	DB	0,0

CalcSctrCentre	DW	CalcCentre1	;SEC_SCALE1
		DW	CalcCentre2	;SEC_SCALE2
		DW	CalcCentre8	;SEC_SCALE8
		DW	CalcCentre16	;SEC_SCALE16

ScanVertexList	DW	ScanVertex1	;SEC_SCALE1
		DW	ScanVertex2	;SEC_SCALE2
		DW	ScanVertex8	;SEC_SCALE8
		DW	ScanVertex16	;SEC_SCALE16

;* cyclics for cloud layer 1 wrt CloudMode

Cloud1Cyclic	DW	OFFSET RvrsFaceDraw	;CLOUD_MODE1
		DW	OFFSET FaceDraw		;CLOUD_MODE2
		DW	OFFSET FaceDraw		;CLOUD_MODE3

;* cyclics for cloud layer 2 wrt CloudMode

Cloud2Cyclic	DW	OFFSET RvrsFaceDraw	;CLOUD_MODE1
		DW	OFFSET RvrsFaceDraw	;CLOUD_MODE2
		DW	OFFSET FaceDraw		;CLOUD_MODE3

FaceCyclic	DW	0

FaceDraw	DW	_PolyFill
		DW	_MeshFill

RvrsFaceDraw	DW	_RvrsPolyFill
		DW	_RvrsMeshFill

;* copies of visual variables which require re-calculation 

_ZScaled	DW	0

_XE01		DW	0
_YE01		DW	0
_ZE01		DW	0

_XE02		DW	0
_YE02		DW	0
_ZE02		DW	0

_XE08		DW	0
_YE08		DW	0
_ZE08		DW	0

_XE016		DW	0
_YE016		DW	0
_ZE016		DW	0

DATA		ENDS

;============================================================================

FEATOBJ1	SEGMENT PARA PUBLIC 'DATA'

FEATOBJ1	ENDS

;============================================================================

VISCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:VISCODE
		ASSUME DS:DATA

;* InitClouds - initialize data for drawing clouds
;*
;* pass: nothing
;* ret : CloudMode
;* kill: assume all

InitClouds	PROC	NEAR

;-----------------
;* sort cloud mode (even if clouds are not enabled)
;-----------------

 	     	mov	ax,WORD PTR V_VIEW.VP_ZFT_LO
		mov	dx,WORD PTR V_VIEW.VP_ZFT_HI

		mov	bx,CLOUD_MODE1	;assume viewpoint below clouds

		sub	ax,WORD PTR CloudBase
		sbb	dx,WORD PTR CloudBase+2

		jb	SetCloudMode	;below clouds ->

		mov	bx,CLOUD_MODE2	;assume viewpoint in clouds

		sub	ax,CloudDepth
		sbb	dx,0

		jb	SetCloudMode	;in clouds ->

		mov	bx,CLOUD_MODE3	;viewpoint must be above clouds

SetCloudMode:	mov	CloudMode,bx

;------------------------
;* test if clouds enabled
;------------------------

		test	CloudsEnabled,1	;clouds enabled?
		_JZ	InitDone	;no ->

;----------------------------------------------------------
;* scale (ZFT - CloudBase) > 10,000ft so max ZFT < 32,768ft
;----------------------------------------------------------

;* z scaled = zft / 4 + 7,500
;*
;* @  10,000ft z scaled =  10,000 / 4 + 7,500 = 10,000
;* @ 100,000ft z scaled = 100,000 / 4 + 7,500 = 32,500

 	     	mov	ax,WORD PTR V_VIEW.VP_ZFT_LO
		mov	dx,WORD PTR V_VIEW.VP_ZFT_HI

		sub	ax,WORD PTR CloudBase
		sbb	dx,WORD PTR CloudBase+2

		js	SortNegZScaled

		mov	WORD PTR ABS_Delta_ZFT,ax
		mov	WORD PTR ABS_Delta_ZFT+2,dx

		test	dx,dx		;zft > 65,535ft?
		jnz	CalcPosZScaled	;yes ->

		cmp	ax,10000	;zft > 10,000ft?
		jbe	ZOk		;no ->

CalcPosZScaled:	REPT	2		;z ft / 4
		shr	dx,1
		rcr	ax,1
		ENDM

		add	ax,7500		;z ft / 4 + 7,500

		jmp	ZOk

SortNegZScaled:	NEG32	dx,ax

		mov	WORD PTR ABS_Delta_ZFT,ax
		mov	WORD PTR ABS_Delta_ZFT+2,dx

		test	dx,dx		;zft > 65,535ft?
		jnz	CalcNegZScaled	;yes ->

		cmp	ax,10000	;zft > 10,000ft?
		jbe	NegZOk		;no ->

CalcNegZScaled:	REPT	2		;z ft / 4
		shr	dx,1
		rcr	ax,1
		ENDM

		add	ax,7500		;z ft / 4 + 7,500

NegZOk:		NEG32	dx,ax
	
ZOk:		mov	_ZScaled,ax

;------------------------------------
;* calc sector offsets using _ZScaled
;------------------------------------

;* current sector visual

		mov	ax,XRel1
		mov	bx,YRel1
		mov	cx,_ZScaled
		neg	cx

	 	call	CalcEyePosition

		mov	_XE01,ax
		mov	_YE01,bx
		mov	_ZE01,cx

;* 3 by 3 sector visual

		mov	ax,XRel2
		mov	bx,YRel2
		mov	cx,_ZScaled
		neg	cx
		sar	cx,1		;/2 scaling

		call	CalcEyePosition

		mov	_XE02,ax
		mov	_YE02,bx
		mov	_ZE02,cx

;* 7 by 7 sector visual

		mov	ax,XRel8
		mov	bx,YRel8
		mov	cx,_ZScaled
		neg	cx
		sar	cx,1
		sar	cx,1
		sar	cx,1		;/8 scaling

		call	CalcEyePosition

		mov	_XE08,ax
		mov	_YE08,bx
		mov	_ZE08,cx

;* 15 by 15 sector visual

		mov	ax,XRel16
		mov	bx,YRel16
		mov	cx,_ZScaled
		neg	cx
		sar	cx,1
		sar	cx,1
		sar	cx,1
		sar	cx,1		;/16 scaling

		call	CalcEyePosition

		mov	_XE016,ax
		mov	_YE016,bx
		mov	_ZE016,cx

InitDone:	ret

InitClouds	ENDP

;----------------------------------------------------------------------------

;* DrawClouds1 - scan map and draw clouds at CloudBase
;*
;* pass: CloudLayer1[]
;* ret : nothing
;* kill: assume all

ExitClouds1	LABEL	NEAR

		ret

DrawClouds1	PROC	NEAR

		test	CloudsEnabled,1	;clouds enabled?
		jz	ExitClouds1	;no ->

;---------------------------
;* sort cyclic wrt CloudMode
;---------------------------

		mov	bx,CloudMode
		mov	ax,Cloud1Cyclic[bx]
		mov	FaceCyclic,ax

;--------------------------------
;* for y sector offset = -n to +n
;--------------------------------

		mov	cx,SecScanCnt2	;y count
		mov	di,SecScanOff2	;y sector offset

ScanYLoop1:	push	cx
		push	di

;--------------------------------
;* for x sector offset = -n to +n
;--------------------------------

		mov	cx,SecScanCnt2	;x count
		mov	si,SecScanOff2	;x sector offset

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

;---------------------
;* test for null cloud
;---------------------

		mov	bp,ax
		mov	al,CloudLayer1[bp]
		test	al,al		;null cloud?
		jz	SkipSector1	;yes ->
		mov	CloudNum,al

;------------------------
;* calc sector scale mode
;------------------------

		call	CalcSctrScale

;------------------------------------------------------------------
;* calc sector centre position and if sector is visible, draw cloud
;------------------------------------------------------------------

		xor	bp,bp		;draw clouds at CloudBase

		call	CalcSctrCentre[bx]
		jc	SkipSector1	;sector non-visible ->

		call	DrawOneCloud

;---------------
;* next x sector
;---------------

SkipSector1:	pop	di
		pop	si
		pop	cx
		add	si,1		;x = x + 1
		loop	ScanXLoop1

;---------------
;* next y sector
;---------------

		pop	di
		pop	cx
		add	di,1		;y = y + 1
		loop	ScanYLoop1

		ret

DrawClouds1	ENDP

;----------------------------------------------------------------------------

;* DrawClouds2 - scan map and draw clouds at CloudBase + CloudDepth
;*
;* pass: CloudLayer2[]
;* ret : nothing
;* kill: assume all

ExitClouds2	LABEL	NEAR

		ret

DrawClouds2	PROC	NEAR

		test	CloudsEnabled,1	;clouds enabled?
		jz	ExitClouds2	;no ->

;---------------------------
;* sort cyclic wrt CloudMode
;---------------------------

		mov	bx,CloudMode
		mov	ax,Cloud2Cyclic[bx]
		mov	FaceCyclic,ax

;--------------------------------
;* for y sector offset = -n to +n
;--------------------------------

		mov	cx,SecScanCnt2	;y count
		mov	di,SecScanOff2	;y sector offset

ScanYLoop2:	push	cx
		push	di

;--------------------------------
;* for x sector offset = -n to +n
;--------------------------------

		mov	cx,SecScanCnt2	;x count
		mov	si,SecScanOff2	;x sector offset

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

;---------------------
;* test for null cloud
;---------------------

		mov	bp,ax
		mov	al,CloudLayer2[bp]
		test	al,al		;null cloud?
		jz	SkipSector2	;yes ->
		mov	CloudNum,al

;------------------------
;* calc sector scale mode
;------------------------

		call	CalcSctrScale

;------------------------------------------------------------------
;* calc sector centre position and if sector is visible, draw cloud
;------------------------------------------------------------------

		mov	ax,CloudDepth	;draw clouds at CloudBase + CloudDepth
		
		xchg	al,ah		;/256
		xor	ah,ah
		shl	ax,1		;*2 word index
		mov	bp,ax

		call	CalcSctrCentre[bx]
		jc	SkipSector2	;sector non-visible ->

		call	DrawOneCloud

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

		ret

DrawClouds2	ENDP

;----------------------------------------------------------------------------

;* DrawOneCloud - draw a single cloud
;*
;* pass: CloudNum
;* ret : nothing
;* kill: assume all

DrawOneCloud	PROC	NEAR

;* fetch pointer to cloud data

		mov	bl,CloudNum
		xor	bh,bh
		shl	bx,1		;*2 index

		mov	si,CloudTable[bx]

;* test if cloud is within visual range

		mov	ax,FEATOBJ1
		mov	es,ax

		ES_LODSW		;fetch max visual range

		cmp	ax,SctrScaleMode
		jae	InRange		;in range ->

		mov	ax,DATA
		mov	es,ax
		jmp	ExitOneCloud

;* scan vertex list and calculate eye co-ord data wrt sector scale mode

InRange:	mov	bx,SctrScaleMode
		call	ScanVertexList[bx]

		mov	ax,DATA
		mov	es,ax

;* test if cloud is visible

		push	si
		mov	si,di
		call	CalcOutCodes
		pop	si
		jc	ExitOneCloud	;cloud non-visible ->

;* copy face data from FEATOBJ1 segment to DATA segment

		mov	bx,SctrScaleMode

		mov	ax,FEATOBJ1
		mov	ds,ax

		mov	si,[si+bx]	;point to face data wrt scale mode

		lodsw			;fetch counter
		mov	cx,ax
		
		mov	di,OFFSET CopyBuffer

		FAST_MOVE

		mov	ax,DATA
		mov	ds,ax

;* generate faces

		mov	si,OFFSET CopyBuffer

NextFace:	lodsb		    	;fetch attribute
		cmp	al,-1		;end of face list?
		je	ExitOneCloud	;yes ->

		push	ax	  	;store attribute

		lodsw			;fetch logical colours
		mov	Colours,ax

		mov	di,OFFSET CrtBuffer
		call	PolyClip
		pop	bx		;restore attribute
		jc	NextFace	;polygon non-visible ->

		push	si		;store face ptr

		mov	si,OFFSET CrtBuffer

		and	bx,0001b	;select solid / mesh
		shl	bx,1		;*2 index
		add	bx,FaceCyclic

		jmp	[bx]

_PolyFill:	mov	al,Col1
		call	PolyFill
		pop	si		;restore face ptr
		jmp	Nextface

_MeshFill:	mov	al,Col1
		call	MeshFill
		pop	si		;restore face ptr
		jmp	Nextface

_RvrsPolyFill:	mov	al,Col2
		call	RvrsPolyFill
		pop	si		;restore face ptr
		jmp	Nextface

_RvrsMeshFill:	mov	al,Col2
		call	RvrsMeshFill
		pop	si		;restore face ptr
		jmp	Nextface

ExitOneCloud:	ret

DrawOneCloud	ENDP

;----------------------------------------------------------------------------

;* CalcSctrScale - calc sector scale mode
;*
;* pass: si = x sector offset (-7 .. +7)
;*       di = y sector offset (-7 .. +7)
;*	 ABS_Delta_ZFT
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

		mov	ax,WORD PTR ABS_Delta_ZFT+2
		test	ax,ax		;zft > 65,535ft?
		jnz	SetScaleMode	;yes ->

		mov	ax,WORD PTR ABS_Delta_ZFT
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
;*       bp = z offset
;* ret : cf = 0: sector visible
;*               XPos1, YPos1, ZPos1
;*       cf = 1: sector non-visible
;* kill: assume all (except cf)
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

		mov	bx,bp
	
		mov	ax,_XE01
		add	ax,XSX[si]
		add	ax,XSY[di]
		add	ax,XSZ[bx]
		mov	XPos1,ax

		mov	ax,_YE01
		add	ax,YSX[si]
		add	ax,YSY[di]
		add	ax,YSZ[bx]
		mov	YPos1,ax

		mov	ax,_ZE01
		add	ax,ZSX[si]
		add	ax,ZSY[di]
		add	ax,ZSZ[bx]
		mov	ZPos1,ax

		clc			;current sector always visible
		ret

CalcCentre1	ENDP

;----------------------------------------------------------------------------

;* CalcCentre2 - calc sector centre position for SEC_SCALE2 sector
;*
;* pass: si = x sector offset
;*       di = y sector offset
;*       bp = z offset
;* ret : cf = 0: sector visible
;*               XPos2, YPos2, ZPos2
;*       cf = 1: sector non-visible
;* kill: assume all (except cf)

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
	
		mov	bx,bp
	
		mov	ax,YSZ[bx]
		sar	ax,1		;/2 scaling
		add	ax,_YE02
		add	ax,YSX[si]
		add	ax,YSY[di]
		cmp	ax,-SCTR_Y_THRES/2
		jl	FailSector2	;reject sector ->
		mov	YPos2,ax

		mov	ax,XSZ[bx]
		sar	ax,1		;/2 scaling
		add	ax,_XE02
		add	ax,XSX[si]
		add	ax,XSY[di]
		mov	XPos2,ax

		mov	ax,ZSZ[bx]
		sar	ax,1		;/2 scaling
		add	ax,_ZE02
		add	ax,ZSX[si]
		add	ax,ZSY[di]
		mov	ZPos2,ax

		clc			;cf = 0 = visible
		ret

FailSector2:	stc			;cf = 1 = non-visible
		ret

CalcCentre2	ENDP

;----------------------------------------------------------------------------

;* CalcCentre8 - calc sector centre position for SEC_SCALE8 sector
;*
;* pass: si = x sector offset
;*       di = y sector offset
;*       bp = z offset
;* ret : cf = 0: sector visible
;*               XPos8, YPos8, ZPos8
;*       cf = 1: sector non-visible
;* kill: assume all (except cf)

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
	
		mov	bx,bp
	
		mov	ax,YSZ[bx]
		sar	ax,1
		sar	ax,1
		sar	ax,1		;/8 scaling
		add	ax,_YE08
		add	ax,YSX[si]
		add	ax,YSY[di]
		cmp	ax,-SCTR_Y_THRES/8
		jl	FailSector8	;reject sector ->
		mov	YPos8,ax

		mov	ax,XSZ[bx]
		sar	ax,1
		sar	ax,1
		sar	ax,1		;/8 scaling
		add	ax,_XE08
		add	ax,XSX[si]
		add	ax,XSY[di]
		mov	XPos8,ax

		mov	ax,ZSZ[bx]
		sar	ax,1
		sar	ax,1
		sar	ax,1		;/8 scaling
		add	ax,_ZE08
		add	ax,ZSX[si]
		add	ax,ZSY[di]
		mov	ZPos8,ax

		clc			;cf = 0 = visible
		ret

FailSector8:	stc			;cf = 1 = non-visible
		ret

CalcCentre8	ENDP

;----------------------------------------------------------------------------

;* CalcCentre16 - calc sector centre position for SEC_SCALE16 sector
;*
;* pass: si = x sector offset
;*       di = y sector offset
;*       bp = z offset
;* ret : cf = 0: sector visible
;*               XPos16, YPos16, ZPos16
;*       cf = 1: sector non-visible
;* kill: assume all (except cf)

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
	
		mov	bx,bp
	
		mov	ax,YSZ[bx]
		sar	ax,1
		sar	ax,1
		sar	ax,1
		sar	ax,1		;/16 scaling
		add	ax,_YE016
		add	ax,YSX[si]
		add	ax,YSY[di]
		cmp	ax,-SCTR_Y_THRES/16
		jl	FailSector16	;reject sector ->
		mov	YPos16,ax

		mov	ax,XSZ[bx]
		sar	ax,1
		sar	ax,1
		sar	ax,1
		sar	ax,1		;/16 scaling
		add	ax,_XE016
		add	ax,XSX[si]
		add	ax,XSY[di]
		mov	XPos16,ax

		mov	ax,ZSZ[bx]
		sar	ax,1
		sar	ax,1
		sar	ax,1
		sar	ax,1		;/16 scaling
		add	ax,_ZE016
		add	ax,ZSX[si]
		add	ax,ZSY[di]
		mov	ZPos16,ax

		clc			;cf = 0 = visible
		ret

FailSector16:	stc			;cf = 1 = non-visible
		ret

CalcCentre16	ENDP

;----------------------------------------------------------------------------

;* ScanVertex1 - scan vertex list and calc eye co-ords (SEC_SCALE1)
;*
;* pass: es:si -> vertex list
;* ret : es:si -> end of vertex list + 1
;*       di = indexes last vertex value in eye co-ord arrays
;*       Xe[], Ye[], Ze[]
;* kill: ax, bx, cx, dx, bp, flags

ScanVertex1	PROC	NEAR

		xor	di,di		;reset eye co-ord index

		xor	bx,bx		;reset index (high byte always 0)

		jmp	VertexLoop1

SkipVertex1:	add	si,2

VertexLoop1:	ES_LODSB		;fetch vertex flags
		cmp	al,-1		;end of vertex list?
		je	ExitVertex1	;yes ->
		test	al,0001b	;vertex required?
		jz	SkipVertex1	;no ->
		
		ES_LODSB		;fetch x index
		mov	bl,al
		mov	cx,XSX[bx]	;XSX
		mov	dx,YSX[bx]	;YSX
		mov	bp,ZSX[bx]	;ZSX

		ES_LODSB		;fetch y index
		mov	bl,al
		add	cx,XSY[bx]	;XSX + XSY
		add	dx,YSY[bx]	;YSX + YSY
		add	bp,ZSY[bx]	;ZSX + ZSY

		add	cx,XPos1 	;XPos1 + XSX + XSY
		mov	Xe[di],cx

		add	dx,YPos1 	;YPos1 + YSX + YSY
		mov	Ye[di],dx

		add	bp,ZPos1 	;ZPos1 + ZSX + ZSY
		mov	Ze[di],bp

		add	di,2		;next index

		jmp	VertexLoop1

ExitVertex1:	sub	di,2		;di indexes last vertex
		ret

ScanVertex1	ENDP

;----------------------------------------------------------------------------

;* ScanVertex2 - scan vertex list and calc eye co-ords (SEC_SCALE2)
;*
;* pass: es:si -> vertex list
;* ret : es:si -> end of vertex list + 1
;*       di = indexes last vertex value in eye co-ord arrays
;*       Xe[], Ye[], Ze[]
;* kill: ax, bx, cx, dx, bp, flags

ScanVertex2	PROC	NEAR

		xor	di,di		;reset eye co-ord index

		xor	bx,bx		;reset index (high byte always 0)

		jmp	VertexLoop2

SkipVertex2:	add	si,2

VertexLoop2:	ES_LODSB		;fetch vertex flags
		cmp	al,-1		;end of vertex list?
		je	ExitVertex2	;yes ->
		test	al,0010b	;vertex required?
		jz	SkipVertex2	;no ->
		
		ES_LODSB		;fetch x index
		mov	bl,al
		mov	cx,XSX[bx]	;XSX
		mov	dx,YSX[bx]	;YSX
		mov	bp,ZSX[bx]	;ZSX

		ES_LODSB		;fetch y index
		mov	bl,al
		add	cx,XSY[bx]	;XSX + XSY
		add	dx,YSY[bx]	;YSX + YSY
		add	bp,ZSY[bx]	;ZSX + ZSY

		sar	cx,1		;/2 scaling
		add	cx,XPos2 	;XPos2 + XSX + XSY
		mov	Xe[di],cx

		sar	dx,1		;/2 scaling
		add	dx,YPos2  	;YPos2 + YSX + YSY
		mov	Ye[di],dx

		sar	bp,1		;/2 scaling
		add	bp,ZPos2 	;ZPos2 + ZSX + ZSY
		mov	Ze[di],bp

		add	di,2		;next index

		jmp	VertexLoop2

ExitVertex2:	sub	di,2		;di indexes last vertex
		ret

ScanVertex2	ENDP

;----------------------------------------------------------------------------

;* ScanVertex8 - scan vertex list and calc eye co-ords (SEC_SCALE8)
;*
;* pass: es:si -> vertex list
;* ret : es:si -> end of vertex list + 1
;*       di = indexes last vertex value in eye co-ord arrays
;*       Xe[], Ye[], Ze[]
;* kill: ax, bx, cx, dx, bp, flags

ScanVertex8	PROC	NEAR

		xor	di,di		;reset eye co-ord index

		xor	bx,bx		;reset index (high byte always 0)

		jmp	VertexLoop8

SkipVertex8:	add	si,2

VertexLoop8:	ES_LODSB		;fetch vertex flags
		cmp	al,-1		;end of vertex list?
		je	ExitVertex8	;yes ->
		test	al,0100b	;vertex required?
		jz	SkipVertex8	;no ->
		
		ES_LODSB		;fetch x index
		mov	bl,al
		mov	cx,XSX[bx]	;XSX
		mov	dx,YSX[bx]	;YSX
		mov	bp,ZSX[bx]	;ZSX

		ES_LODSB		;fetch y index
		mov	bl,al
		add	cx,XSY[bx]	;XSX + XSY
		add	dx,YSY[bx]	;YSX + YSY
		add	bp,ZSY[bx]	;ZSX + ZSY

		sar	cx,1
		sar	cx,1
		sar	cx,1		;/8 scaling
		add	cx,XPos8 	;XPos8 + XSX + XSY
		mov	Xe[di],cx

		sar	dx,1
		sar	dx,1
		sar	dx,1		;/8 scaling
		add	dx,YPos8 	;YPos8 + YSX + YSY
		mov	Ye[di],dx

		sar	bp,1
		sar	bp,1
		sar	bp,1		;/8 scaling
		add	bp,ZPos8 	;ZPos8 + ZSX + ZSY
		mov	Ze[di],bp

		add	di,2		;next index

		jmp	VertexLoop8

ExitVertex8:	sub	di,2		;di indexes last vertex
		ret

ScanVertex8	ENDP

;----------------------------------------------------------------------------

;* ScanVertex16 - scan vertex list and calc eye co-ords (SEC_SCALE16)
;*
;* pass: es:si -> vertex list
;* ret : es:si -> end of vertex list + 1
;*       di = indexes last vertex value in eye co-ord arrays
;*       Xe[], Ye[], Ze[]
;* kill: ax, bx, cx, dx, bp, flags

ScanVertex16	PROC	NEAR

		xor	di,di		;reset eye co-ord index

		xor	bx,bx		;reset index (high byte always 0)

		jmp	VertexLoop16

SkipVertex16:	add	si,2

VertexLoop16:	ES_LODSB		;fetch vertex flags
		cmp	al,-1		;end of vertex list?
		je	ExitVertex16	;yes ->
		test	al,1000b	;vertex required?
		jz	SkipVertex16	;no ->

		ES_LODSB		;fetch x index
		mov	bl,al
		mov	cx,XSX[bx]	;XSX
		mov	dx,YSX[bx]	;YSX
		mov	bp,ZSX[bx]	;ZSX

		ES_LODSB		;fetch y index
		mov	bl,al
		add	cx,XSY[bx]	;XSX + XSY
		add	dx,YSY[bx]	;YSX + YSY
		add	bp,ZSY[bx]	;ZSX + ZSY

		sar	cx,1
		sar	cx,1
		sar	cx,1
		sar	cx,1		;/16 scaling
		add	cx,XPos16	;XPos16 + XSX + XSY
		mov	Xe[di],cx

		sar	dx,1
		sar	dx,1
		sar	dx,1
		sar	dx,1		;/16 scaling
		add	dx,YPos16	;YPos16 + YSX + YSY
		mov	Ye[di],dx

		sar	bp,1
		sar	bp,1
		sar	bp,1
		sar	bp,1		;/16 scaling
		add	bp,ZPos16  	;ZPos16 + ZSX + ZSY
		mov	Ze[di],bp

		add	di,2		;next index

		jmp	VertexLoop16

ExitVertex16:	sub	di,2		;di indexes last vertex
		ret

ScanVertex16	ENDP

;----------------------------------------------------------------------------

;* RandomizeClouds - shift cloud layers around map
;*
;* pass: CloudLayer1[]
;*       CloudLayer2[]
;* ret : CloudLayer1[]
;*       CloudLayer2[]
;* kill: assume all

RandomizeClouds	PROC	NEAR

;----------------
;* calc cloud top
;----------------

		mov	ax,WORD PTR CloudBase
		mov	dx,WORD PTR CloudBase+2

		add	ax,CloudDepth
		adc	dx,0

		mov	WORD PTR CloudTop,ax
		mov	WORD PTR CloudTop+2,dx

;------------------
;* shift x position
;------------------

		call	RandX
		and	ax,0001fh	;0 .. 31
		jz	SkipXShift	;0 ->

		mov	cx,ax

		mov	ax,SEG CloudLayer1
		mov	ds,ax
		mov	es,ax

;* shift CloudLayer1[]

		push	cx

XLoop1:		push	cx

		mov	cx,32

		mov	si,OFFSET CloudLayer1+1
		mov	di,OFFSET CloudLayer1

@@:		push	cx
		mov	al,[di]		;shift row left
		mov	cx,31
		rep	movsb
		mov	[di],al
		inc	si
		inc	di
		pop	cx
		loop	@B

		pop	cx
		loop	XLoop1

		pop	cx
		
;* shift CloudLayer2[]

XLoop2:		push	cx

		mov	cx,32

		mov	si,OFFSET CloudLayer2+1
		mov	di,OFFSET CloudLayer2

@@:		push	cx
		mov	al,[di]		;shift row left
		mov	cx,31
		rep	movsb
		mov	[di],al
		inc	si
		inc	di
		pop	cx
		loop	@B

		pop	cx
		loop	XLoop2

		mov	ax,DATA
		mov	ds,ax
		mov	es,ax

;------------------
;* shift y position
;------------------

SkipXShift: 	call	RandX
		and	ax,0001fh	;0 .. 31
		jz	SkipYShift	;0 ->

		mov	cx,ax

		mov	ax,SEG CloudLayer1
		mov	ds,ax
		mov	es,ax

;* shift CloudLayer1[]

		push	cx

YLoop1:		push	cx

;* store first row on stack

		mov	cx,16

		mov	si,OFFSET CloudLayer1

@@:		lodsw
		push	ax
		loop	@B

;* shift 31 rows up (overwriting first row)

		mov	cx,31*32/2

		mov	si,OFFSET CloudLayer1+32
		mov	di,OFFSET CloudLayer1

		rep	movsw

;* restore last row from stack

		mov	cx,16

		mov	di,OFFSET CloudLayer1+32*32-2

		std
@@:		pop	ax
		stosw
		loop	@B
		cld

		pop	cx
		loop	YLoop1

		pop	cx

;* shift CloudLayer2[]

YLoop2:		push	cx

;* store first row on stack

		mov	cx,16

		mov	si,OFFSET CloudLayer2

@@:		lodsw
		push	ax
		loop	@B

;* shift 31 rows up (overwriting first row)

		mov	cx,31*32/2

		mov	si,OFFSET CloudLayer2+32
		mov	di,OFFSET CloudLayer2

		rep	movsw

;* restore last row from stack

		mov	cx,16

		mov	di,OFFSET CloudLayer2+32*32-2

		std
@@:		pop	ax
		stosw
		loop	@B
		cld

		pop	cx
		loop	YLoop2

		mov	ax,DATA
		mov	ds,ax
		mov	es,ax

SkipYShift:	ret

RandomizeClouds	ENDP

VISCODE		ENDS

;============================================================================

		END

