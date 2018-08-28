;****************************************************************************
;*
;* ROADS.ASM
;*
;* Draw major road network.
;*
;* 12.02.1991 - KJB
;* 12.01.1992 - KJB - Roads extended into SEC_SCALE16 sectors.
;*
;* Notes:-
;*
;* Each sector is divided into quadrants where each quadrant is given a
;* "node" byte to define the road layout within it. Four map layers are
;* therefore required for each sector and are arranged as follows:-
;*
;*         RoadLayer1(-x, +y quad)   Roadlayer2(+x, +y quad)
;*         RoadLayer3(-x, -y quad)   RoadLayer4(+x, -y quad)
;*
;* Each node is situated in the centre of the quadrant and can have up to
;* eight roads eminating from the node to the quadrant boundary. The node
;* byte is defined as follows:-
;*
;*         b0:  N road )
;*         b1: NE road )
;*         b2:  E road )
;*         b3: SE road ) 0 = road disabled
;*         b4:  S road ) 1 = road enabled
;*         b5: SW road )
;*         b6:  W road )
;*         b7: NW road )
;*
;* Distant roads are approximated to lines.
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	DrawRoads

		EXTRN	PolyFill:FAR
		EXTRN	LineDraw:FAR

		EXTRN	CalcOutCodes:NEAR
		EXTRN	PolyClip:NEAR
		EXTRN	QuickLineClip:NEAR

		EXTRN	RoadLayer1:BYTE
		EXTRN	RoadLayer2:BYTE
		EXTRN	RoadLayer3:BYTE
		EXTRN	RoadLayer4:BYTE

;============================================================================

		INCLUDE	VISEXTRN.INC
		INCLUDE	VISDATA.INC
		INCLUDE	PALETTES.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

;* approximation threshold wrt ZFT (max value = 8192)

Z_APPROX_THRES	EQU	8192

;* calc node centre position wrt SctrScaleMode

CalcNodePos	DW	CalcNodePos1	;SEC_SCALE1
		DW	CalcNodePos2	;SEC_SCALE2
		DW	CalcNodePos8	;SEC_SCALE8
		DW	CalcNodePos16	;SEC_SCALE16

;* draw polygon roads wrt SctrScaleMode

PolyRoads	DW	PolyRoad1	;SEC_SCALE1
		DW	PolyRoad2	;SEC_SCALE2
		DW	LineRoad8	;SEC_SCALE8
		DW	LineRoad16	;SEC_SCALE16

;* draw line roads wrt SctrScaleMode

LineRoads	DW	LineRoad1	;SEC_SCALE1
		DW	LineRoad2	;SEC_SCALE2
		DW	LineRoad8	;SEC_SCALE8
		DW	LineRoad16	;SEC_SCALE16

DrawRoadType	DW	0

;* road length sector grid offsets (1/1 scaling)

RoadLength1	DW	$MID+$0		;x -  N road
		DW	$MID+$4096	;y
		DW	$MID+$4096 	;x - NE road
		DW	$MID+$4096	;y
		DW	$MID+$4096 	;x -  E road
		DW	$MID+$0		;y
		DW	$MID+$4096 	;x - SE road
		DW	$MID-$4096	;y
		DW	$MID+$0		;x -  S road
		DW	$MID-$4096	;y
		DW	$MID-$4096 	;x - SW road
		DW	$MID-$4096	;y
		DW	$MID-$4096 	;x -  W road
		DW	$MID+$0		;y
		DW	$MID-$4096 	;x - NW road
		DW	$MID+$4096	;y

;* road length sector grid offsets (1/2 scaling)

RoadLength2	DW	$MID+$0		;x -  N road
		DW	$MID+$2048	;y
		DW	$MID+$2048 	;x - NE road
		DW	$MID+$2048	;y
		DW	$MID+$2048 	;x -  E road
		DW	$MID+$0		;y
		DW	$MID+$2048 	;x - SE road
		DW	$MID-$2048	;y
		DW	$MID+$0		;x -  S road
		DW	$MID-$2048	;y
		DW	$MID-$2048 	;x - SW road
		DW	$MID-$2048	;y
		DW	$MID-$2048 	;x -  W road
		DW	$MID+$0		;y
		DW	$MID-$2048 	;x - NW road
		DW	$MID+$2048	;y

;* road length sector grid offsets (1/8 scaling)

RoadLength8	DW	$MID+$0		;x -  N road
		DW	$MID+$512	;y
		DW	$MID+$512 	;x - NE road
		DW	$MID+$512	;y
		DW	$MID+$512 	;x -  E road
		DW	$MID+$0		;y
		DW	$MID+$512 	;x - SE road
		DW	$MID-$512	;y
		DW	$MID+$0		;x -  S road
		DW	$MID-$512	;y
		DW	$MID-$512 	;x - SW road
		DW	$MID-$512	;y
		DW	$MID-$512 	;x -  W road
		DW	$MID+$0		;y
		DW	$MID-$512 	;x - NW road
		DW	$MID+$512	;y

;* road length sector grid offsets (1/16 scaling)

RoadLength16	DW	$MID+$0		;x -  N road
		DW	$MID+$256	;y
		DW	$MID+$256 	;x - NE road
		DW	$MID+$256	;y
		DW	$MID+$256 	;x -  E road
		DW	$MID+$0		;y
		DW	$MID+$256 	;x - SE road
		DW	$MID-$256	;y
		DW	$MID+$0		;x -  S road
		DW	$MID-$256	;y
		DW	$MID-$256 	;x - SW road
		DW	$MID-$256	;y
		DW	$MID-$256 	;x -  W road
		DW	$MID+$0		;y
		DW	$MID-$256 	;x - NW road
		DW	$MID+$256	;y

;* road half width object grid offsets (1/1 scaling)

RoadWidth1	DW	@MID-@32	;x1 -  N road
		DW	@MID-@32	;y1
		DW	@MID-@32	;x2
		DW	@MID+@32	;y2
		DW	@MID+@32	;x3
		DW	@MID+@32	;y3
		DW	@MID+@32	;x4
		DW	@MID-@32	;y4
		
		DW	@MID-@32	;x1 - NE road
		DW	@MID+@32	;y1
		DW	@MID+@0		;x2
		DW	@MID+@64	;y2
		DW	@MID+@64	;x3
		DW	@MID+@0		;y3
		DW	@MID+@32	;x4
		DW	@MID-@32	;y4

		DW	@MID-@32	;x1 -  E road
		DW	@MID+@32	;y1
		DW	@MID+@32	;x2
		DW	@MID+@32	;y2
		DW	@MID+@32	;x3
		DW	@MID-@32	;y3
		DW	@MID-@32	;x4
		DW	@MID-@32	;y4

		DW	@MID+@32	;x1 - SE road
		DW	@MID+@32	;y1
		DW	@MID+@64	;x2
		DW	@MID+@0		;y2
		DW	@MID+@0		;x3
		DW	@MID-@64	;y3
		DW	@MID-@32	;x4
		DW	@MID-@32	;y4

		DW	@MID+@32	;x1 -  S road
		DW	@MID+@32	;y1
		DW	@MID+@32	;x2
		DW	@MID-@32	;y2
		DW	@MID-@32	;x3
		DW	@MID-@32	;y3
		DW	@MID-@32	;x4
		DW	@MID+@32	;y4

		DW	@MID+@32	;x1 - SW road
		DW	@MID-@32	;y1
		DW	@MID+@0		;x2
		DW	@MID-@64	;y2
		DW	@MID-@64	;x3
		DW	@MID+@0		;y3
		DW	@MID-@32	;x4
		DW	@MID+@32	;y4

		DW	@MID+@32	;x1 -  W road
		DW	@MID-@32	;y1
		DW	@MID-@32	;x2
		DW	@MID-@32	;y2
		DW	@MID-@32	;x3
		DW	@MID+@32	;y3
		DW	@MID+@32	;x4
		DW	@MID+@32	;y4

		DW	@MID-@32	;x1 - NW road
		DW	@MID-@32	;y1
		DW	@MID-@64	;x2
		DW	@MID+@0		;y2
		DW	@MID+@0		;x3
		DW	@MID+@64	;y3
		DW	@MID+@32	;x4
		DW	@MID+@32	;y4

;* road half width object grid offsets (1/2 scaling)

RoadWidth2	DW	@MID-@16	;x1 -  N road
		DW	@MID-@16	;y1
		DW	@MID-@16	;x2
		DW	@MID+@16	;y2
		DW	@MID+@16	;x3
		DW	@MID+@16	;y3
		DW	@MID+@16	;x4
		DW	@MID-@16	;y4
		
		DW	@MID-@16	;x1 - NE road
		DW	@MID+@16	;y1
		DW	@MID+@0		;x2
		DW	@MID+@32	;y2
		DW	@MID+@32	;x3
		DW	@MID+@0		;y3
		DW	@MID+@16	;x4
		DW	@MID-@16	;y4

		DW	@MID-@16	;x1 -  E road
		DW	@MID+@16	;y1
		DW	@MID+@16	;x2
		DW	@MID+@16	;y2
		DW	@MID+@16	;x3
		DW	@MID-@16	;y3
		DW	@MID-@16	;x4
		DW	@MID-@16	;y4

		DW	@MID+@16	;x1 - SE road
		DW	@MID+@16	;y1
		DW	@MID+@32	;x2
		DW	@MID+@0		;y2
		DW	@MID+@0		;x3
		DW	@MID-@32	;y3
		DW	@MID-@16	;x4
		DW	@MID-@16	;y4

		DW	@MID+@16	;x1 -  S road
		DW	@MID+@16	;y1
		DW	@MID+@16	;x2
		DW	@MID-@16	;y2
		DW	@MID-@16	;x3
		DW	@MID-@16	;y3
		DW	@MID-@16	;x4
		DW	@MID+@16	;y4

		DW	@MID+@16	;x1 - SW road
		DW	@MID-@16	;y1
		DW	@MID+@0		;x2
		DW	@MID-@32	;y2
		DW	@MID-@32	;x3
		DW	@MID+@0		;y3
		DW	@MID-@16	;x4
		DW	@MID+@16	;y4

		DW	@MID+@16	;x1 -  W road
		DW	@MID-@16	;y1
		DW	@MID-@16	;x2
		DW	@MID-@16	;y2
		DW	@MID-@16	;x3
		DW	@MID+@16	;y3
		DW	@MID+@16	;x4
		DW	@MID+@16	;y4

		DW	@MID-@16	;x1 - NW road
		DW	@MID-@16	;y1
		DW	@MID-@32	;x2
		DW	@MID+@0		;y2
		DW	@MID+@0		;x3
		DW	@MID+@32	;y3
		DW	@MID+@16	;x4
		DW	@MID+@16	;y4

DATA		ENDS

;============================================================================

VISCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:VISCODE
		ASSUME DS:DATA

;* DrawRoads - read map and draw major road network
;*
;* pass: MapIndex
;*       RoadLayer1[]
;*       RoadLayer2[]
;*       RoadLayer3[]
;*       RoadLayer4[]
;* ret : nothing
;* kill: assume all

DrawRoads	PROC	NEAR

;* if ZFT < Z_APPROX_THRES then
;*    draw polygon roads
;* else
;*    draw line roads
;* end

		mov	bx,SctrScaleMode

		mov	ax,LineRoads[bx]	;assume line roads

		cmp	WORD PTR V_VIEW.VP_ZFT_HI,0
		jne	@F			;zft > 65,535ft ->

		cmp	WORD PTR V_VIEW.VP_ZFT_LO,Z_APPROX_THRES
		jae	@F			;zft >= Z_APPROX_THRES ->

		mov	ax,PolyRoads[bx]	;polygon roads

@@:		mov	DrawRoadType,ax

		mov	bp,MapIndex
		mov	al,RoadLayer1[bp]
		test	al,al		;null node?
		jz	Layer2		;yes ->
		mov	si,-$4096
		mov	di,+$4096
		call	DrawNode

		mov	bp,MapIndex
Layer2:		mov	al,RoadLayer2[bp]
		test	al,al		;null node?
		jz	Layer3		;yes ->
		mov	si,+$4096
		mov	di,+$4096
		call	DrawNode

		mov	bp,MapIndex
Layer3:		mov	al,RoadLayer3[bp]
		test	al,al		;null node?
		jz	Layer4		;yes ->
		mov	si,-$4096
		mov	di,-$4096
		call	DrawNode

		mov	bp,MapIndex
Layer4:		mov	al,RoadLayer4[bp]
		test	al,al		;null node?
		jz	DrawRoadsExit	;yes ->
		mov	si,+$4096
		mov	di,-$4096
		call	DrawNode

DrawRoadsExit:	ret

DrawRoads	ENDP

;----------------------------------------------------------------------------

;* DrawNode - draw roads around node
;*
;* pass: al = node code
;*       si = node position x sector index (for SEC_SCALE1 mode)
;*       di = node position y sector index (for SEC_SCALE1 mode)
;* ret : nothing
;* kill: assume all

DrawNode	PROC	NEAR

		mov	dl,al		;store node code

;* calc node position wrt sector scale mode

		mov	bx,SctrScaleMode
		call	CalcNodePos[bx]

		mov	al,dl		;restore node code

		xor	bx,bx		;reset index

DrawNextRoad:	shr	al,1		;road to draw?
		jnc	SkipRoad	;no ->

		push	ax
		push	bx

		call	DrawRoadType

		pop	bx
		pop	ax

SkipRoad:	add	bx,4		;index = index + 4
		test	al,al		;any more roads?
		jnz	DrawNextRoad	;yes ->
		
		ret

DrawNode	ENDP

;----------------------------------------------------------------------------

;* CalcNodePos1 - calc node position for SEC_SCALE1 mode
;*
;* pass: si = node position x sector index (for SEC_SCALE1 mode)
;*       di = node position y sector index (for SEC_SCALE1 mode)
;* ret : XPos, YPos, ZPos
;* kill: ax, flags

CalcNodePos1	PROC	NEAR

		mov	ax,XPos1
		add	ax,XSX[$MID][si]
		add	ax,XSY[$MID][di]
		mov	XPos,ax

		mov	ax,YPos1
		add	ax,YSX[$MID][si]
		add	ax,YSY[$MID][di]
		mov	YPos,ax

		mov	ax,ZPos1
		add	ax,ZSX[$MID][si]
		add	ax,ZSY[$MID][di]
		mov	ZPos,ax

		ret

CalcNodePos1	ENDP

;----------------------------------------------------------------------------

;* CalcNodePos2 - calc node position for SEC_SCALE2 mode
;*
;* pass: si = node position x sector index (for SEC_SCALE1 mode)
;*       di = node position y sector index (for SEC_SCALE1 mode)
;* ret : XPos, YPos, ZPos
;* kill: ax, si, di, flags

CalcNodePos2	PROC	NEAR

		sar	si,1		;/2 x index
		sar	di,1		;/2 y index

		mov	ax,XPos2
		add	ax,XSX[$MID][si]
		add	ax,XSY[$MID][di]
		mov	XPos,ax

		mov	ax,YPos2
		add	ax,YSX[$MID][si]
		add	ax,YSY[$MID][di]
		mov	YPos,ax

		mov	ax,ZPos2
		add	ax,ZSX[$MID][si]
		add	ax,ZSY[$MID][di]
		mov	ZPos,ax

		ret

CalcNodePos2	ENDP

;----------------------------------------------------------------------------

;* CalcNodePos8 - calc node position for SEC_SCALE8 mode
;*
;* pass: si = node position x sector index (for SEC_SCALE1 mode)
;*       di = node position y sector index (for SEC_SCALE1 mode)
;* ret : XPos, YPos, ZPos
;* kill: ax, si, di, flags

CalcNodePos8	PROC	NEAR

		REPT	3
		sar	si,1		;/8 x index
		sar	di,1		;/8 y index
		ENDM

		mov	ax,XPos8
		add	ax,XSX[$MID][si]
		add	ax,XSY[$MID][di]
		mov	XPos,ax

		mov	ax,YPos8
		add	ax,YSX[$MID][si]
		add	ax,YSY[$MID][di]
		mov	YPos,ax

		mov	ax,ZPos8
		add	ax,ZSX[$MID][si]
		add	ax,ZSY[$MID][di]
		mov	ZPos,ax

		ret

CalcNodePos8	ENDP

;----------------------------------------------------------------------------

;* CalcNodePos16 - calc node position for SEC_SCALE16 mode
;*
;* pass: si = node position x sector index (for SEC_SCALE1 mode)
;*       di = node position y sector index (for SEC_SCALE1 mode)
;* ret : XPos, YPos, ZPos
;* kill: ax, si, di, flags

CalcNodePos16	PROC	NEAR

		REPT	4
		sar	si,1		;/16 x index
		sar	di,1		;/16 y index
		ENDM

		mov	ax,XPos16
		add	ax,XSX[$MID][si]
		add	ax,XSY[$MID][di]
		mov	XPos,ax

		mov	ax,YPos16
		add	ax,YSX[$MID][si]
		add	ax,YSY[$MID][di]
		mov	YPos,ax

		mov	ax,ZPos16
		add	ax,ZSX[$MID][si]
		add	ax,ZSY[$MID][di]
		mov	ZPos,ax

		ret

CalcNodePos16	ENDP

;----------------------------------------------------------------------------

;* PolyRoad1 - draw polygon road (SEC_SCALE1)
;*
;* pass: bx = index for road length offset tables
;* ret : nothing
;* kill: assume all

PolyRoad1	PROC	NEAR

		mov	si,RoadLength1[bx]
		mov	di,RoadLength1[bx+2]
		
		mov	ax,XSX[si]
		add	ax,XSY[di]
		mov	cx,ax		;cx = XSX + XSY

		mov	ax,YSX[si]
		add	ax,YSY[di]
		mov	dx,ax		;dx = YSX + YSY

		mov	ax,ZSX[si]
		add	ax,ZSY[di]
		mov	bp,ax		;bp = ZSX + ZSY

		shl	bx,1		;*8
		shl	bx,1		;*16 index

		mov	si,RoadWidth1[bx+0]	;x1
		mov	di,RoadWidth1[bx+2]	;y1
		mov	ax,XGX[si]
		add	ax,XGY[di]
		add	ax,XPos
		mov	Xe[0],ax	;Xe = XPos + (XGX + XGY)
		mov	ax,YGX[si]
		add	ax,YGY[di]
		add	ax,YPos
		mov	Ye[0],ax	;Ye = YPos + (YGX + YGY)
		mov	ax,ZGX[si]
		add	ax,ZGY[di]
		add	ax,ZPos
		mov	Ze[0],ax	;Ze = ZPos + (ZGX + ZGY)
		
		mov	si,RoadWidth1[bx+4]	;x2
		mov	di,RoadWidth1[bx+6]	;y2
		mov	ax,XGX[si]
		add	ax,XGY[di]
		add	ax,XPos
		add	ax,cx
		mov	Xe[2],ax	;Xe = XPos + (XSX + XSY) + (XGX + XGY)
		mov	ax,YGX[si]
		add	ax,YGY[di]
		add	ax,YPos
		add	ax,dx
		mov	Ye[2],ax	;Ye = YPos + (YSX + YSY) + (YGX + YGY)
		mov	ax,ZGX[si]
		add	ax,ZGY[di]
		add	ax,ZPos
		add	ax,bp
		mov	Ze[2],ax	;Ze = ZPos + (ZSX + ZSY) + (ZGX + ZGY)
	
		mov	si,RoadWidth1[bx+8]	;x3
		mov	di,RoadWidth1[bx+10]	;y3
		mov	ax,XGX[si]
		add	ax,XGY[di]
		add	ax,XPos
		add	ax,cx
		mov	Xe[4],ax	;Xe = XPos + (XSX + XSY) + (XGX + XGY)
		mov	ax,YGX[si]
		add	ax,YGY[di]
		add	ax,YPos
		add	ax,dx
		mov	Ye[4],ax	;Ye = YPos + (YSX + YSY) + (YGX + YGY)
		mov	ax,ZGX[si]
		add	ax,ZGY[di]
		add	ax,ZPos
		add	ax,bp
		mov	Ze[4],ax	;Ze = ZPos + (ZSX + ZSY) + (ZGX + ZGY)
	
		mov	si,RoadWidth1[bx+12]	;x4
		mov	di,RoadWidth1[bx+14]	;y4
		mov	ax,XGX[si]
		add	ax,XGY[di]
		add	ax,XPos
		mov	Xe[6],ax	;Xe = XPos + (XGX + XGY)
		mov	ax,YGX[si]
		add	ax,YGY[di]
		add	ax,YPos
		mov	Ye[6],ax	;Ye = YPos + (YGX + YGY)
		mov	ax,ZGX[si]
		add	ax,ZGY[di]
		add	ax,ZPos
		mov	Ze[6],ax	;Ze = ZPos + (ZGX + ZGY)
	
		mov	si,6
		call	CalcOutCodes
		jc	ExitPolyRoad1	;road non-visible ->

		mov	si,OFFSET StndPoly4
		mov	di,OFFSET CrtBuffer
		call	PolyClip
		jc	ExitPolyRoad1	;road non-visible ->

		mov	al,COL_ROAD1
		mov	si,OFFSET CrtBuffer
		call	PolyFill

ExitPolyRoad1:	ret

PolyRoad1	ENDP		
		
;----------------------------------------------------------------------------

;* PolyRoad2 - draw polygon road (SEC_SCALE2)
;*
;* pass: bx = index for road length offset tables
;* ret : nothing
;* kill: assume all

PolyRoad2	PROC	NEAR

		mov	si,RoadLength2[bx]
		mov	di,RoadLength2[bx+2]
		
		mov	ax,XSX[si]
		add	ax,XSY[di]
		mov	cx,ax		;cx = XSX + XSY

		mov	ax,YSX[si]
		add	ax,YSY[di]
		mov	dx,ax		;dx = YSX + YSY

		mov	ax,ZSX[si]
		add	ax,ZSY[di]
		mov	bp,ax		;bp = ZSX + ZSY

		shl	bx,1		;*8
		shl	bx,1		;*16 index

		mov	si,RoadWidth2[bx+0]	;x1
		mov	di,RoadWidth2[bx+2]	;y1
		mov	ax,XGX[si]
		add	ax,XGY[di]
		add	ax,XPos
		mov	Xe[0],ax	;Xe = XPos + (XGX + XGY)
		mov	ax,YGX[si]
		add	ax,YGY[di]
		add	ax,YPos
		mov	Ye[0],ax	;Ye = YPos + (YGX + YGY)
		mov	ax,ZGX[si]
		add	ax,ZGY[di]
		add	ax,ZPos
		mov	Ze[0],ax	;Ze = ZPos + (ZGX + ZGY)
		
		mov	si,RoadWidth2[bx+4]	;x2
		mov	di,RoadWidth2[bx+6]	;y2
		mov	ax,XGX[si]
		add	ax,XGY[di]
		add	ax,XPos
		add	ax,cx
		mov	Xe[2],ax	;Xe = XPos + (XSX + XSY) + (XGX + XGY)
		mov	ax,YGX[si]
		add	ax,YGY[di]
		add	ax,YPos
		add	ax,dx
		mov	Ye[2],ax	;Ye = YPos + (YSX + YSY) + (YGX + YGY)
		mov	ax,ZGX[si]
		add	ax,ZGY[di]
		add	ax,ZPos
		add	ax,bp
		mov	Ze[2],ax	;Ze = ZPos + (ZSX + ZSY) + (ZGX + ZGY)
	
		mov	si,RoadWidth2[bx+8]	;x3
		mov	di,RoadWidth2[bx+10]	;y3
		mov	ax,XGX[si]
		add	ax,XGY[di]
		add	ax,XPos
		add	ax,cx
		mov	Xe[4],ax	;Xe = XPos + (XSX + XSY) + (XGX + XGY)
		mov	ax,YGX[si]
		add	ax,YGY[di]
		add	ax,YPos
		add	ax,dx
		mov	Ye[4],ax	;Ye = YPos + (YSX + YSY) + (YGX + YGY)
		mov	ax,ZGX[si]
		add	ax,ZGY[di]
		add	ax,ZPos
		add	ax,bp
		mov	Ze[4],ax	;Ze = ZPos + (ZSX + ZSY) + (ZGX + ZGY)
	
		mov	si,RoadWidth2[bx+12]	;x4
		mov	di,RoadWidth2[bx+14]	;y4
		mov	ax,XGX[si]
		add	ax,XGY[di]
		add	ax,XPos
		mov	Xe[6],ax	;Xe = XPos + (XGX + XGY)
		mov	ax,YGX[si]
		add	ax,YGY[di]
		add	ax,YPos
		mov	Ye[6],ax	;Ye = YPos + (YGX + YGY)
		mov	ax,ZGX[si]
		add	ax,ZGY[di]
		add	ax,ZPos
		mov	Ze[6],ax	;Ze = ZPos + (ZGX + ZGY)
	
		mov	si,6
		call	CalcOutCodes
		jc	ExitPolyRoad2	;road non-visible ->

		mov	si,OFFSET StndPoly4
		mov	di,OFFSET CrtBuffer
		call	PolyClip
		jc	ExitPolyRoad2	;road non-visible ->

		mov	al,COL_ROAD1
		mov	si,OFFSET CrtBuffer
		call	PolyFill

ExitPolyRoad2:	ret

PolyRoad2	ENDP		

;----------------------------------------------------------------------------

;* LineRoad1 - draw line road (SEC_SCALE1)
;*
;* pass: bx = index for road length offset tables
;* ret : nothing
;* kill: assume all

LineRoad1	PROC	NEAR

		mov	si,RoadLength1[bx]
		mov	di,RoadLength1[bx+2]

		mov	ax,XPos
		mov	Xe[0],ax	;Xe = XPos
		add	ax,XSX[si]
		add	ax,XSY[di]
		mov	Xe[2],ax	;Xe = XPos + (XSX + XSY)
		
		mov	ax,YPos
		mov	Ye[0],ax	;Ye = YPos
		add	ax,YSX[si]
		add	ax,YSY[di]
		mov	Ye[2],ax	;Ye = YPos + (YSX + YSY)
	
		mov	ax,ZPos
		mov	Ze[0],ax	;Ze = ZPos
		add	ax,ZSX[si]
		add	ax,ZSY[di]
		mov	Ze[2],ax	;Ze = ZPos + (ZSX + ZSY)

		call	QuickLineClip
		jc	ExitLineRoad1	;road non-visible ->

		mov	al,COL_ROAD1
		mov	cx,XCrt[0]
		mov	bl,YCrt[0]
		mov	dx,XCrt[2]
		mov	bh,YCrt[2]
		call	LineDraw

ExitLineRoad1:	ret

LineRoad1	ENDP
	
;----------------------------------------------------------------------------

;* LineRoad2 - draw line road (SEC_SCALE2)
;*
;* pass: bx = index for road length offset tables
;* ret : nothing
;* kill: assume all

LineRoad2	PROC	NEAR

		mov	si,RoadLength2[bx]
		mov	di,RoadLength2[bx+2]

		mov	ax,XPos
		mov	Xe[0],ax	;Xe = XPos
		add	ax,XSX[si]
		add	ax,XSY[di]
		mov	Xe[2],ax	;Xe = XPos + (XSX + XSY)
		
		mov	ax,YPos
		mov	Ye[0],ax	;Ye = YPos
		add	ax,YSX[si]
		add	ax,YSY[di]
		mov	Ye[2],ax	;Ye = YPos + (YSX + YSY)
	
		mov	ax,ZPos
		mov	Ze[0],ax	;Ze = ZPos
		add	ax,ZSX[si]
		add	ax,ZSY[di]
		mov	Ze[2],ax	;Ze = ZPos + (ZSX + ZSY)

		call	QuickLineClip
		jc	ExitLineRoad2	;road non-visible ->

		mov	al,COL_ROAD1
		mov	cx,XCrt[0]
		mov	bl,YCrt[0]
		mov	dx,XCrt[2]
		mov	bh,YCrt[2]
		call	LineDraw

ExitLineRoad2:	ret

LineRoad2	ENDP
	
;----------------------------------------------------------------------------

;* LineRoad8 - draw line road (SEC_SCALE8)
;*
;* pass: bx = index for road length offset tables
;* ret : nothing
;* kill: assume all

LineRoad8	PROC	NEAR

		mov	si,RoadLength8[bx]
		mov	di,RoadLength8[bx+2]

		mov	ax,XPos
		mov	Xe[0],ax	;Xe = XPos
		add	ax,XSX[si]
		add	ax,XSY[di]
		mov	Xe[2],ax	;Xe = XPos + (XSX + XSY)
		
		mov	ax,YPos
		mov	Ye[0],ax	;Ye = YPos
		add	ax,YSX[si]
		add	ax,YSY[di]
		mov	Ye[2],ax	;Ye = YPos + (YSX + YSY)
	
		mov	ax,ZPos
		mov	Ze[0],ax	;Ze = ZPos
		add	ax,ZSX[si]
		add	ax,ZSY[di]
		mov	Ze[2],ax	;Ze = ZPos + (ZSX + ZSY)

		call	QuickLineClip
		jc	ExitLineRoad8	;road non-visible ->

		mov	al,COL_ROAD1
		mov	cx,XCrt[0]
		mov	bl,YCrt[0]
		mov	dx,XCrt[2]
		mov	bh,YCrt[2]
		call	LineDraw

ExitLineRoad8:	ret

LineRoad8	ENDP
	
;----------------------------------------------------------------------------

;* LineRoad16 - draw line road (SEC_SCALE16)
;*
;* pass: bx = index for road length offset tables
;* ret : nothing
;* kill: assume all

LineRoad16	PROC	NEAR

		mov	si,RoadLength16[bx]
		mov	di,RoadLength16[bx+2]

		mov	ax,XPos
		mov	Xe[0],ax	;Xe = XPos
		add	ax,XSX[si]
		add	ax,XSY[di]
		mov	Xe[2],ax	;Xe = XPos + (XSX + XSY)
		
		mov	ax,YPos
		mov	Ye[0],ax	;Ye = YPos
		add	ax,YSX[si]
		add	ax,YSY[di]
		mov	Ye[2],ax	;Ye = YPos + (YSX + YSY)
	
		mov	ax,ZPos
		mov	Ze[0],ax	;Ze = ZPos
		add	ax,ZSX[si]
		add	ax,ZSY[di]
		mov	Ze[2],ax	;Ze = ZPos + (ZSX + ZSY)

		call	QuickLineClip
		jc	ExitLineRoad16	;road non-visible ->

		mov	al,COL_ROAD1
		mov	cx,XCrt[0]
		mov	bl,YCrt[0]
		mov	dx,XCrt[2]
		mov	bh,YCrt[2]
		call	LineDraw

ExitLineRoad16:	ret

LineRoad16	ENDP
	
VISCODE		ENDS

;============================================================================

		END

