;****************************************************************************
;*
;* RAILWAYS.ASM
;*
;* Draw railway network.
;*
;* 20.02.1991 - KJB
;* 04.07.1991 - KJB - Railway tracks added.
;* 12.01.1992 - KJB - Railways extended into SEC_SCALE16 sectors.
;*
;* Notes:-
;*
;* Railways are constructed using the node method (see ROADS.ASM), however,
;* there is only one node per sector which is situated at the sector centre.
;*
;* The node byte is defined as follows:-
;*
;*         b0:  N rail )
;*         b1: NE rail )
;*         b2:  E rail )
;*         b3: SE rail ) 0 = rail disabled
;*         b4:  S rail ) 1 = rail enabled
;*         b5: SW rail )
;*         b6:  W rail )
;*         b7: NW rail )
;*
;* Distant railways are approximated to lines.
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	DrawRailways

		EXTRN	PolyFill:FAR
		EXTRN	LineDraw:FAR

		EXTRN	CalcOutCodes:NEAR
		EXTRN	PolyClip:NEAR
		EXTRN	QuickLineClip:NEAR

		EXTRN	RailLayer1:BYTE

;============================================================================

		INCLUDE	VISEXTRN.INC
		INCLUDE	VISDATA.INC
		INCLUDE	PALETTES.INC
		INCLUDE	\LIB8086\USEFUL.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

;* line / polygon railway bed approximation threshold wrt ZFT

Z_APPROX_THRES	EQU	8192		;<= 8192

;* single / double track approximation threshold wrt ZFT

Z_TRACK_THRES	EQU	1024		;<= Z_APPROX_THRES

;* draw polygon rails wrt SctrScaleMode

PolyRails	DW	PolyRail1	;SEC_SCALE1
		DW	PolyRail2	;SEC_SCALE2
		DW	LineRail8	;SEC_SCALE8
		DW	LineRail16	;SEC_SCALE16

;* draw line rails wrt SctrScaleMode

LineRails	DW	LineRail1	;SEC_SCALE1
		DW	LineRail2	;SEC_SCALE2
		DW	LineRail8	;SEC_SCALE8
		DW	LineRail16	;SEC_SCALE16

;* draw single line tracks wrt SctrScaleMode

SingleTracks	DW	SingleTrack1	;SEC_SCALE1
		DW	SingleTrack2	;SEC_SCALE2

;* draw double line tracks wrt SctrScaleMode

DoubleTracks	DW	DoubleTrack1	;SEC_SCALE1
		DW	DoubleTrack2	;SEC_SCALE2

DrawRailType	DW	0

;* track scaling vars:- lsb = position * scale, msb = offset / scale
 
TrackScaleVals	DW	00004h		;SEC_SCALE1
		DW	00104h		;SEC_SCALE2

TrackScale	DW	0

;* rail length sector grid offsets (1/1 scaling)

RailLength1	DW	$MID+$0		;x - N rail
		DW	$MID+$8192	;y
		DW	$MID+$8192 	;x - NE rail
		DW	$MID+$8192	;y
		DW	$MID+$8192 	;x -  E rail
		DW	$MID+$0		;y
		DW	$MID+$8192 	;x - SE rail
		DW	$MID-$8192	;y
		DW	$MID+$0		;x -  S rail
		DW	$MID-$8192	;y
		DW	$MID-$8192 	;x - SW rail
		DW	$MID-$8192	;y
		DW	$MID-$8192 	;x -  W rail
		DW	$MID+$0		;y
		DW	$MID-$8192 	;x - NW rail
		DW	$MID+$8192	;y

;* rail length sector grid offsets (1/2 scaling)

RailLength2	DW	$MID+$0		;x -  N rail
		DW	$MID+$4096	;y
		DW	$MID+$4096 	;x - NE rail
		DW	$MID+$4096	;y
		DW	$MID+$4096 	;x -  E rail
		DW	$MID+$0		;y
		DW	$MID+$4096 	;x - SE rail
		DW	$MID-$4096	;y
		DW	$MID+$0		;x -  S rail
		DW	$MID-$4096	;y
		DW	$MID-$4096 	;x - SW rail
		DW	$MID-$4096	;y
		DW	$MID-$4096 	;x -  W rail
		DW	$MID+$0		;y
		DW	$MID-$4096 	;x - NW rail
		DW	$MID+$4096	;y

;* rail length sector grid offsets (1/8 scaling)

RailLength8	DW	$MID+$0		;x -  N rail
		DW	$MID+$1024	;y
		DW	$MID+$1024 	;x - NE rail
		DW	$MID+$1024	;y
		DW	$MID+$1024 	;x -  E rail
		DW	$MID+$0		;y
		DW	$MID+$1024 	;x - SE rail
		DW	$MID-$1024	;y
		DW	$MID+$0		;x -  S rail
		DW	$MID-$1024	;y
		DW	$MID-$1024 	;x - SW rail
		DW	$MID-$1024	;y
		DW	$MID-$1024 	;x -  W rail
		DW	$MID+$0		;y
		DW	$MID-$1024 	;x - NW rail
		DW	$MID+$1024	;y

;* rail length sector grid offsets (1/16 scaling)

RailLength16	DW	$MID+$0		;x -  N rail
		DW	$MID+$512	;y
		DW	$MID+$512 	;x - NE rail
		DW	$MID+$512	;y
		DW	$MID+$512 	;x -  E rail
		DW	$MID+$0		;y
		DW	$MID+$512 	;x - SE rail
		DW	$MID-$512	;y
		DW	$MID+$0		;x -  S rail
		DW	$MID-$512	;y
		DW	$MID-$512 	;x - SW rail
		DW	$MID-$512	;y
		DW	$MID-$512 	;x -  W rail
		DW	$MID+$0		;y
		DW	$MID-$512 	;x - NW rail
		DW	$MID+$512	;y

;* rail half width object grid offsets (1/1 scaling)

RailWidth1	DW	@MID-@32	;x1 -  N rail
		DW	@MID-@32	;y1
		DW	@MID-@32	;x2
		DW	@MID+@32	;y2
		DW	@MID+@32	;x3
		DW	@MID+@32	;y3
		DW	@MID+@32	;x4
		DW	@MID-@32	;y4
		
		DW	@MID-@32	;x1 - NE rail
		DW	@MID+@32	;y1
		DW	@MID+@0		;x2
		DW	@MID+@64	;y2
		DW	@MID+@64	;x3
		DW	@MID+@0		;y3
		DW	@MID+@32	;x4
		DW	@MID-@32	;y4

		DW	@MID-@32	;x1 -  E rail
		DW	@MID+@32	;y1
		DW	@MID+@32	;x2
		DW	@MID+@32	;y2
		DW	@MID+@32	;x3
		DW	@MID-@32	;y3
		DW	@MID-@32	;x4
		DW	@MID-@32	;y4

		DW	@MID+@32	;x1 - SE rail
		DW	@MID+@32	;y1
		DW	@MID+@64	;x2
		DW	@MID+@0		;y2
		DW	@MID+@0		;x3
		DW	@MID-@64	;y3
		DW	@MID-@32	;x4
		DW	@MID-@32	;y4

		DW	@MID+@32	;x1 -  S rail
		DW	@MID+@32	;y1
		DW	@MID+@32	;x2
		DW	@MID-@32	;y2
		DW	@MID-@32	;x3
		DW	@MID-@32	;y3
		DW	@MID-@32	;x4
		DW	@MID+@32	;y4

		DW	@MID+@32	;x1 - SW rail
		DW	@MID-@32	;y1
		DW	@MID+@0		;x2
		DW	@MID-@64	;y2
		DW	@MID-@64	;x3
		DW	@MID+@0		;y3
		DW	@MID-@32	;x4
		DW	@MID+@32	;y4

		DW	@MID+@32	;x1 -  W rail
		DW	@MID-@32	;y1
		DW	@MID-@32	;x2
		DW	@MID-@32	;y2
		DW	@MID-@32	;x3
		DW	@MID+@32	;y3
		DW	@MID+@32	;x4
		DW	@MID+@32	;y4

		DW	@MID-@32	;x1 - NW rail
		DW	@MID-@32	;y1
		DW	@MID-@64	;x2
		DW	@MID+@0		;y2
		DW	@MID+@0		;x3
		DW	@MID+@64	;y3
		DW	@MID+@32	;x4
		DW	@MID+@32	;y4

;* rail half width object grid offsets (1/2 scaling)

RailWidth2	DW	@MID-@16	;x1 -  N rail
		DW	@MID-@16	;y1
		DW	@MID-@16	;x2
		DW	@MID+@16	;y2
		DW	@MID+@16	;x3
		DW	@MID+@16	;y3
		DW	@MID+@16	;x4
		DW	@MID-@16	;y4
		
		DW	@MID-@16	;x1 - NE rail
		DW	@MID+@16	;y1
		DW	@MID+@0		;x2
		DW	@MID+@32	;y2
		DW	@MID+@32	;x3
		DW	@MID+@0		;y3
		DW	@MID+@16	;x4
		DW	@MID-@16	;y4

		DW	@MID-@16	;x1 -  E rail
		DW	@MID+@16	;y1
		DW	@MID+@16	;x2
		DW	@MID+@16	;y2
		DW	@MID+@16	;x3
		DW	@MID-@16	;y3
		DW	@MID-@16	;x4
		DW	@MID-@16	;y4

		DW	@MID+@16	;x1 - SE rail
		DW	@MID+@16	;y1
		DW	@MID+@32	;x2
		DW	@MID+@0		;y2
		DW	@MID+@0		;x3
		DW	@MID-@32	;y3
		DW	@MID-@16	;x4
		DW	@MID-@16	;y4

		DW	@MID+@16	;x1 -  S rail
		DW	@MID+@16	;y1
		DW	@MID+@16	;x2
		DW	@MID-@16	;y2
		DW	@MID-@16	;x3
		DW	@MID-@16	;y3
		DW	@MID-@16	;x4
		DW	@MID+@16	;y4

		DW	@MID+@16	;x1 - SW rail
		DW	@MID-@16	;y1
		DW	@MID+@0		;x2
		DW	@MID-@32	;y2
		DW	@MID-@32	;x3
		DW	@MID+@0		;y3
		DW	@MID-@16	;x4
		DW	@MID+@16	;y4

		DW	@MID+@16	;x1 -  W rail
		DW	@MID-@16	;y1
		DW	@MID-@16	;x2
		DW	@MID-@16	;y2
		DW	@MID-@16	;x3
		DW	@MID+@16	;y3
		DW	@MID+@16	;x4
		DW	@MID+@16	;y4

		DW	@MID-@16	;x1 - NW rail
		DW	@MID-@16	;y1
		DW	@MID-@32	;x2
		DW	@MID+@0		;y2
		DW	@MID+@0		;x3
		DW	@MID+@32	;y3
		DW	@MID+@16	;x4
		DW	@MID+@16	;y4

;* single track end offsets (1/1 scaling)

STrackEnd1	DW	@MID+@0		;x1 -  N track
		DW	@MID-@32	;y1
		DW	@MID+@0		;x2
		DW	@MID+@32	;y2

		DW	@MID+@0		;x1 - NE track
		DW	@MID+@0		;y1
		DW	@MID+@32	;x2
		DW	@MID+@32	;y2

		DW	@MID-@32 	;x1 -  E track
		DW	@MID+@0		;y1
		DW	@MID+@32	;x2
		DW	@MID+@0		;y2

		DW	@MID+@0 	;x1 - SE track
		DW	@MID+@0		;y1
		DW	@MID+@32	;x2
		DW	@MID-@32	;y2

		DW	@MID+@0 	;x1 -  S track
		DW	@MID+@32	;y1
		DW	@MID+@0		;x2
		DW	@MID-@32	;y2

		DW	@MID+@0 	;x1 - SW track
		DW	@MID+@0		;y1
		DW	@MID-@32	;x2
		DW	@MID-@32	;y2

		DW	@MID+@32 	;x1 -  W track
		DW	@MID+@0		;y1
		DW	@MID-@32	;x2
		DW	@MID+@0		;y2

		DW	@MID+@0 	;x1 - NW track
		DW	@MID+@0		;y1
		DW	@MID-@32	;x2
		DW	@MID+@32	;y2

;* single track end offsets (1/2 scaling)

STrackEnd2	DW	@MID+@0		;x1 -  N track
		DW	@MID-@16	;y1
		DW	@MID+@0		;x2
		DW	@MID+@16	;y2

		DW	@MID+@0		;x1 - NE track
		DW	@MID+@0		;y1
		DW	@MID+@16	;x2
		DW	@MID+@16	;y2

		DW	@MID-@16 	;x1 -  E track
		DW	@MID+@0		;y1
		DW	@MID+@16	;x2
		DW	@MID+@0		;y2

		DW	@MID+@0 	;x1 - SE track
		DW	@MID+@0		;y1
		DW	@MID+@16	;x2
		DW	@MID-@16	;y2

		DW	@MID+@0 	;x1 -  S track
		DW	@MID+@16	;y1
		DW	@MID+@0		;x2
		DW	@MID-@16	;y2

		DW	@MID+@0 	;x1 - SW track
		DW	@MID+@0		;y1
		DW	@MID-@16	;x2
		DW	@MID-@16	;y2

		DW	@MID+@16 	;x1 -  W track
		DW	@MID+@0		;y1
		DW	@MID-@16	;x2
		DW	@MID+@0		;y2

		DW	@MID+@0 	;x1 - NW track
		DW	@MID+@0		;y1
		DW	@MID-@16	;x2
		DW	@MID+@16	;y2

;* double track end lh and rh offsets (1/16 scaling)

DTrackEnd16	DW	@MID-@64	;xl -  N track   
		DW	@MID+@0		;yl
		DW	@MID+@64	;xr
		DW	@MID+@0		;yr

		DW	@MID-@64	;xl - NE track   
		DW	@MID+@64	;yl
		DW	@MID+@64	;xr
		DW	@MID-@64	;yr

		DW	@MID+@0		;xl -  E track   
		DW	@MID+@64	;yl
		DW	@MID+@0		;xr
		DW	@MID-@64	;yr

		DW	@MID+@64	;xl - SE track   
		DW	@MID+@64	;yl
		DW	@MID-@64	;xr
		DW	@MID-@64	;yr

		DW	@MID+@64	;xl -  S track   
		DW	@MID+@0		;yl
		DW	@MID-@64	;xr
		DW	@MID+@0		;yr

		DW	@MID+@64	;xl - SW track   
		DW	@MID-@64	;yl
		DW	@MID-@64	;xr
		DW	@MID+@64	;yr

		DW	@MID+@0		;xl -  W track   
		DW	@MID-@64	;yl
		DW	@MID+@0		;xr
		DW	@MID+@64	;yr

		DW	@MID-@64	;xl - NW track   
		DW	@MID-@64	;yl
		DW	@MID+@64	;xr
		DW	@MID+@64	;yr

;* track draw eye co-ord EQUates

P1		EQU	4		;centre point
P2		EQU	6		;1/4 point
P3		EQU	8		;1/2 point
P4		EQU	10		;3/4 point
P5		EQU	12		;end point

LH_P1		EQU	14		;lh centre point
RH_P1		EQU	16		;rh centre point

LH_P2		EQU	18		;lh 1/4 point
RH_P2		EQU	20		;rh 1/4 point

LH_P3		EQU	22		;lh 1/2 point
RH_P3		EQU	24		;rh 1/2 point

LH_P4		EQU	26		;lh 3/4 point
RH_P4		EQU	28		;rh 3/4 point

LH_P5		EQU	30		;lh end point
RH_P5		EQU	32		;rh end point

DATA		ENDS

;============================================================================

VISCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:VISCODE
		ASSUME DS:DATA

;* DrawRailways - read map and draw railway network
;*
;* pass: MapIndex
;*       RailLayer1[]
;* ret : nothing
;* kill: assume all

DrawRailsExit1	LABEL	NEAR

		ret

DrawRailways	PROC	NEAR

		mov	bp,MapIndex
		mov	al,RailLayer1[bp]
		test	al,al		;null node?
		jz	DrawRailsExit1	;yes ->

		mov	dl,al		;store node code

;-------------------
;* draw railway beds
;-------------------

;* if ZFT < Z_APPROX_THRES then
;*    draw polygon rail
;* else
;*    draw line rail
;* end

		mov	bx,SctrScaleMode

		mov	ax,LineRails[bx]	;assume line railways

		cmp	WORD PTR V_VIEW.VP_ZFT_HI,0
		jne	@F			;zft > 65,535ft ->

		cmp	WORD PTR V_VIEW.VP_ZFT_LO,Z_APPROX_THRES
		jae	@F			;zft >= Z_APPROX_THRES ->

		mov	ax,PolyRails[bx]	;polygon railways

@@:		mov	DrawRailType,ax

		push	dx

;* draw node

		mov	al,dl		;al = node code

		xor	bx,bx		;reset index

DrawNextRail:	shr	al,1		;rail to draw?
		jnc	SkipRail	;no ->

		push	ax
		push	bx

		call	DrawRailType

		pop	bx
		pop	ax

SkipRail:	add	bx,4		;index = index + 4
		test	al,al		;any more rails?
		jnz	DrawNextRail	;yes ->

;---------------------
;* draw railway tracks
;---------------------

		pop	dx  		;dl = node code

;* only draw railway tracks in SEC_SCALE1 or SEC_SCALE2 visual

		mov	bx,SctrScaleMode
		cmp	bx,SEC_SCALE2
		ja	DrawRailsExit2
	
;* only draw tracks if polygon railway beds have been drawn

;* note: SEC_SCALE1 and SEC_SCALE2 only therefore ZFT < 8192ft (VP_ZFT_HI = 0)

		mov	ax,WORD PTR V_VIEW.VP_ZFT_LO
		cmp	ax,Z_APPROX_THRES
		jae	DrawRailsExit2

;* draw single or double track 

		cmp	ax,Z_TRACK_THRES
		mov	ax,SingleTracks[bx]
		jae	@F
		mov	ax,DoubleTracks[bx]
@@:		mov	DrawRailType,ax

;* sort track scaling factors

		mov	ax,TrackScaleVals[bx]
		mov	TrackScale,ax

;* draw node

		mov	al,dl		;al = node code

		xor	bx,bx		;reset index

DrawNextTrack:	shr	al,1		;track to draw?
		jnc	SkipTrack	;no ->

		push	ax
		push	bx

		call	DrawRailType

		pop	bx
		pop	ax

SkipTrack:	add	bx,4		;index = index + 4
		test	al,al		;any more tracks?
		jnz	DrawNextTrack	;yes ->

DrawRailsExit2:	ret

DrawRailways	ENDP

;----------------------------------------------------------------------------

;* PolyRail1 - draw polygon rail (SEC_SCALE1)
;*
;* pass: bx = index for rail length offset tables
;* ret : nothing
;* kill: assume all

PolyRail1	PROC	NEAR

		mov	si,RailLength1[bx]
		mov	di,RailLength1[bx+2]
		
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

		mov	si,RailWidth1[bx+0]	;x1
		mov	di,RailWidth1[bx+2]	;y1
		mov	ax,XGX[si]
		add	ax,XGY[di]
		add	ax,XPos1
		mov	Xe[0],ax	;Xe = XPos1 + (XGX + XGY)
		mov	ax,YGX[si]
		add	ax,YGY[di]
		add	ax,YPos1
		mov	Ye[0],ax	;Ye = YPos1 + (YGX + YGY)
		mov	ax,ZGX[si]
		add	ax,ZGY[di]
		add	ax,ZPos1
		mov	Ze[0],ax	;Ze = ZPos1 + (ZGX + ZGY)
		
		mov	si,RailWidth1[bx+4]	;x2
		mov	di,RailWidth1[bx+6]	;y2
		mov	ax,XGX[si]
		add	ax,XGY[di]
		add	ax,XPos1
		add	ax,cx
		mov	Xe[2],ax	;Xe = XPos1 + (XSX + XSY) + (XGX + XGY)
		mov	ax,YGX[si]
		add	ax,YGY[di]
		add	ax,YPos1
		add	ax,dx
		mov	Ye[2],ax	;Ye = YPos1 + (YSX + YSY) + (YGX + YGY)
		mov	ax,ZGX[si]
		add	ax,ZGY[di]
		add	ax,ZPos1
		add	ax,bp
		mov	Ze[2],ax	;Ze = ZPos1 + (ZSX + ZSY) + (ZGX + ZGY)
	
		mov	si,RailWidth1[bx+8]	;x3
		mov	di,RailWidth1[bx+10]	;y3
		mov	ax,XGX[si]
		add	ax,XGY[di]
		add	ax,XPos1
		add	ax,cx
		mov	Xe[4],ax	;Xe = XPos1 + (XSX + XSY) + (XGX + XGY)
		mov	ax,YGX[si]
		add	ax,YGY[di]
		add	ax,YPos1
		add	ax,dx
		mov	Ye[4],ax	;Ye = YPos1 + (YSX + YSY) + (YGX + YGY)
		mov	ax,ZGX[si]
		add	ax,ZGY[di]
		add	ax,ZPos1
		add	ax,bp
		mov	Ze[4],ax	;Ze = ZPos1 + (ZSX + ZSY) + (ZGX + ZGY)
	
		mov	si,RailWidth1[bx+12]	;x4
		mov	di,RailWidth1[bx+14]	;y4
		mov	ax,XGX[si]
		add	ax,XGY[di]
		add	ax,XPos1
		mov	Xe[6],ax	;Xe = XPos1 + (XGX + XGY)
		mov	ax,YGX[si]
		add	ax,YGY[di]
		add	ax,YPos1
		mov	Ye[6],ax	;Ye = YPos1 + (YGX + YGY)
		mov	ax,ZGX[si]
		add	ax,ZGY[di]
		add	ax,ZPos1
		mov	Ze[6],ax	;Ze = ZPos1 + (ZGX + ZGY)
	
		mov	si,6
		call	CalcOutCodes
		jc	ExitPolyRail1	;rail non-visible ->

		mov	si,OFFSET StndPoly4
		mov	di,OFFSET CrtBuffer
		call	PolyClip
		jc	ExitPolyRail1	;rail non-visible ->

		mov	al,COL_RAIL1
		mov	si,OFFSET CrtBuffer
		call	PolyFill

ExitPolyRail1:	ret

PolyRail1	ENDP		
		
;----------------------------------------------------------------------------

;* PolyRail2 - draw polygon rail (SEC_SCALE2)
;*
;* pass: bx = index for rail length offset tables
;* ret : nothing
;* kill: assume all

PolyRail2	PROC	NEAR

		mov	si,RailLength2[bx]
		mov	di,RailLength2[bx+2]
		
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

		mov	si,RailWidth2[bx+0]	;x1
		mov	di,RailWidth2[bx+2]	;y1
		mov	ax,XGX[si]
		add	ax,XGY[di]
		add	ax,XPos2
		mov	Xe[0],ax	;Xe = XPos2 + (XGX + XGY)
		mov	ax,YGX[si]
		add	ax,YGY[di]
		add	ax,YPos2
		mov	Ye[0],ax	;Ye = YPos2 + (YGX + YGY)
		mov	ax,ZGX[si]
		add	ax,ZGY[di]
		add	ax,ZPos2
		mov	Ze[0],ax	;Ze = ZPos2 + (ZGX + ZGY)
		
		mov	si,RailWidth2[bx+4]	;x2
		mov	di,RailWidth2[bx+6]	;y2
		mov	ax,XGX[si]
		add	ax,XGY[di]
		add	ax,XPos2
		add	ax,cx
		mov	Xe[2],ax	;Xe = XPos2 + (XSX + XSY) + (XGX + XGY)
		mov	ax,YGX[si]
		add	ax,YGY[di]
		add	ax,YPos2
		add	ax,dx
		mov	Ye[2],ax	;Ye = YPos2 + (YSX + YSY) + (YGX + YGY)
		mov	ax,ZGX[si]
		add	ax,ZGY[di]
		add	ax,ZPos2
		add	ax,bp
		mov	Ze[2],ax	;Ze = ZPos2 + (ZSX + ZSY) + (ZGX + ZGY)
	
		mov	si,RailWidth2[bx+8]	;x3
		mov	di,RailWidth2[bx+10]	;y3
		mov	ax,XGX[si]
		add	ax,XGY[di]
		add	ax,XPos2
		add	ax,cx
		mov	Xe[4],ax	;Xe = XPos2 + (XSX + XSY) + (XGX + XGY)
		mov	ax,YGX[si]
		add	ax,YGY[di]
		add	ax,YPos2
		add	ax,dx
		mov	Ye[4],ax	;Ye = YPos2 + (YSX + YSY) + (YGX + YGY)
		mov	ax,ZGX[si]
		add	ax,ZGY[di]
		add	ax,ZPos2
		add	ax,bp
		mov	Ze[4],ax	;Ze = ZPos2 + (ZSX + ZSY) + (ZGX + ZGY)
	
		mov	si,RailWidth2[bx+12]	;x4
		mov	di,RailWidth2[bx+14]	;y4
		mov	ax,XGX[si]
		add	ax,XGY[di]
		add	ax,XPos2
		mov	Xe[6],ax	;Xe = XPos2 + (XGX + XGY)
		mov	ax,YGX[si]
		add	ax,YGY[di]
		add	ax,YPos2
		mov	Ye[6],ax	;Ye = YPos2 + (YGX + YGY)
		mov	ax,ZGX[si]
		add	ax,ZGY[di]
		add	ax,ZPos2
		mov	Ze[6],ax	;Ze = ZPos2 + (ZGX + ZGY)
	
		mov	si,6
		call	CalcOutCodes
		jc	ExitPolyRail2	;rail non-visible ->

		mov	si,OFFSET StndPoly4
		mov	di,OFFSET CrtBuffer
		call	PolyClip
		jc	ExitPolyRail2	;rail non-visible ->

		mov	al,COL_RAIL1
		mov	si,OFFSET CrtBuffer
		call	PolyFill

ExitPolyRail2:	ret

PolyRail2	ENDP		

;----------------------------------------------------------------------------

;* LineRail1 - draw line rail (SEC_SCALE1)
;*
;* pass: bx = index for rail length offset tables
;* ret : nothing
;* kill: assume all

LineRail1	PROC	NEAR

		mov	si,RailLength1[bx]
		mov	di,RailLength1[bx+2]

		mov	ax,XPos1
		mov	Xe[0],ax	;Xe = XPos1
		add	ax,XSX[si]
		add	ax,XSY[di]
		mov	Xe[2],ax	;Xe = XPos1 + (XSX + XSY)
		
		mov	ax,YPos1
		mov	Ye[0],ax	;Ye = YPos1
		add	ax,YSX[si]
		add	ax,YSY[di]
		mov	Ye[2],ax	;Ye = YPos1 + (YSX + YSY)
	
		mov	ax,ZPos1
		mov	Ze[0],ax	;Ze = ZPos1
		add	ax,ZSX[si]
		add	ax,ZSY[di]
		mov	Ze[2],ax	;Ze = ZPos1 + (ZSX + ZSY)

		call	QuickLineClip
		jc	ExitLineRail1	;rail non-visible ->

		mov	al,COL_RAIL1
		mov	cx,XCrt[0]
		mov	bl,YCrt[0]
		mov	dx,XCrt[2]
		mov	bh,YCrt[2]
		call	LineDraw

ExitLineRail1:	ret

LineRail1	ENDP
	
;----------------------------------------------------------------------------

;* LineRail2 - draw line rail (SEC_SCALE2)
;*
;* pass: bx = index for rail length offset tables
;* ret : nothing
;* kill: assume all

LineRail2	PROC	NEAR

		mov	si,RailLength2[bx]
		mov	di,RailLength2[bx+2]

		mov	ax,XPos2
		mov	Xe[0],ax	;Xe = XPos2
		add	ax,XSX[si]
		add	ax,XSY[di]
		mov	Xe[2],ax	;Xe = XPos2 + (XSX + XSY)
		
		mov	ax,YPos2
		mov	Ye[0],ax	;Ye = YPos2
		add	ax,YSX[si]
		add	ax,YSY[di]
		mov	Ye[2],ax	;Ye = YPos2 + (YSX + YSY)
	
		mov	ax,ZPos2
		mov	Ze[0],ax	;Ze = ZPos2
		add	ax,ZSX[si]
		add	ax,ZSY[di]
		mov	Ze[2],ax	;Ze = ZPos2 + (ZSX + ZSY)

		call	QuickLineClip
		jc	ExitLineRail2	;rail non-visible ->

		mov	al,COL_RAIL1
		mov	cx,XCrt[0]
		mov	bl,YCrt[0]
		mov	dx,XCrt[2]
		mov	bh,YCrt[2]
		call	LineDraw

ExitLineRail2:	ret

LineRail2	ENDP
	
;----------------------------------------------------------------------------

;* LineRail8 - draw line rail (SEC_SCALE8)
;*
;* pass: bx = index for rail length offset tables
;* ret : nothing
;* kill: assume all

LineRail8	PROC	NEAR

		mov	si,RailLength8[bx]
		mov	di,RailLength8[bx+2]

		mov	ax,XPos8
		mov	Xe[0],ax	;Xe = XPos8
		add	ax,XSX[si]
		add	ax,XSY[di]
		mov	Xe[2],ax	;Xe = XPos8 + (XSX + XSY)
		
		mov	ax,YPos8
		mov	Ye[0],ax	;Ye = YPos8
		add	ax,YSX[si]
		add	ax,YSY[di]
		mov	Ye[2],ax	;Ye = YPos8 + (YSX + YSY)
	
		mov	ax,ZPos8
		mov	Ze[0],ax	;Ze = ZPos8
		add	ax,ZSX[si]
		add	ax,ZSY[di]
		mov	Ze[2],ax	;Ze = ZPos8 + (ZSX + ZSY)

		call	QuickLineClip
		jc	ExitLineRail8	;rail non-visible ->

		mov	al,COL_RAIL1
		mov	cx,XCrt[0]
		mov	bl,YCrt[0]
		mov	dx,XCrt[2]
		mov	bh,YCrt[2]
		call	LineDraw

ExitLineRail8:	ret

LineRail8	ENDP

;----------------------------------------------------------------------------

;* LineRail16 - draw line rail (SEC_SCALE16)
;*
;* pass: bx = index for rail length offset tables
;* ret : nothing
;* kill: assume all

LineRail16	PROC	NEAR

		mov	si,RailLength16[bx]
		mov	di,RailLength16[bx+2]

		mov	ax,XPos16
		mov	Xe[0],ax	;Xe = XPos16
		add	ax,XSX[si]
		add	ax,XSY[di]
		mov	Xe[2],ax	;Xe = XPos16 + (XSX + XSY)
		
		mov	ax,YPos16
		mov	Ye[0],ax	;Ye = YPos16
		add	ax,YSX[si]
		add	ax,YSY[di]
		mov	Ye[2],ax	;Ye = YPos16 + (YSX + YSY)
	
		mov	ax,ZPos16
		mov	Ze[0],ax	;Ze = ZPos16
		add	ax,ZSX[si]
		add	ax,ZSY[di]
		mov	Ze[2],ax	;Ze = ZPos16 + (ZSX + ZSY)

		call	QuickLineClip
		jc	ExitLineRail16	;rail non-visible ->

		mov	al,COL_RAIL1
		mov	cx,XCrt[0]
		mov	bl,YCrt[0]
		mov	dx,XCrt[2]
		mov	bh,YCrt[2]
		call	LineDraw

ExitLineRail16:	ret

LineRail16	ENDP

;----------------------------------------------------------------------------

;* SingleTrack1 - draw single track (SEC_SCALE1)
;*
;* pass: bx = index for rail length offset tables
;* ret : nothing
;* kill: assume all

SingleTrack1	PROC	NEAR

		mov	si,RailLength1[bx]
		mov	di,RailLength1[bx+2]

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

		mov	si,STrackEnd1[bx+0]	;x1
		mov	di,STrackEnd1[bx+2]	;y1
		mov	ax,XPos1
		add	ax,XGX[si]
		add	ax,XGY[di]
		mov	Xe[0],ax	;Xe = XPos1 + (XGX + XGY)
		mov	ax,YPos1
		add	ax,YGX[si]
		add	ax,YGY[di]
		mov	Ye[0],ax	;Ye = YPos1 + (YGX + YGY)
		mov	ax,ZPos1
		add	ax,ZGX[si]
		add	ax,ZGY[di]
		mov	Ze[0],ax	;Ze = ZPos1 + (ZGX + ZGY)

		mov	si,STrackEnd1[bx+4]	;x2
		mov	di,STrackEnd1[bx+6]	;y2
		mov	ax,XPos1
		add	ax,XGX[si]
		add	ax,XGY[di]
		add	ax,cx
		mov	Xe[2],ax	;Xe = XPos1 + (XGX + XGY) + (XSX + XSY)
		mov	ax,YPos1
		add	ax,YGX[si]
		add	ax,YGY[di]
		add	ax,dx
		mov	Ye[2],ax	;Ye = YPos1 + (YGX + YGY) + (YSX + YSY)
		mov	ax,ZPos1
		add	ax,ZGX[si]
		add	ax,ZGY[di]
		add	ax,bp
		mov	Ze[2],ax	;Ze = ZPos1 + (ZGX + ZGY) + (ZSX + ZSY)

		call	QuickLineClip
		jc	ExitSingle1	;track non-visible ->

		mov	al,COL_RAIL2
		mov	cx,XCrt[0]
		mov	bl,YCrt[0]
		mov	dx,XCrt[2]
		mov	bh,YCrt[2]
		call	LineDraw

ExitSingle1:	ret

SingleTrack1	ENDP
	
;----------------------------------------------------------------------------

;* SingleTrack2 - draw single track (SEC_SCALE2)
;*
;* pass: bx = index for rail length offset tables
;* ret : nothing
;* kill: assume all

SingleTrack2	PROC	NEAR

		mov	si,RailLength2[bx]
		mov	di,RailLength2[bx+2]

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

		mov	si,STrackEnd2[bx+0]	;x1
		mov	di,STrackEnd2[bx+2]	;y1
		mov	ax,XPos2
		add	ax,XGX[si]
		add	ax,XGY[di]
		mov	Xe[0],ax	;Xe = XPos2 + (XGX + XGY)
		mov	ax,YPos2
		add	ax,YGX[si]
		add	ax,YGY[di]
		mov	Ye[0],ax	;Ye = YPos2 + (YGX + YGY)
		mov	ax,ZPos2
		add	ax,ZGX[si]
		add	ax,ZGY[di]
		mov	Ze[0],ax	;Ze = ZPos2 + (ZGX + ZGY)

		mov	si,STrackEnd2[bx+4]	;x2
		mov	di,STrackEnd2[bx+6]	;y2
		mov	ax,XPos2
		add	ax,XGX[si]
		add	ax,XGY[di]
		add	ax,cx
		mov	Xe[2],ax	;Xe = XPos2 + (XGX + XGY) + (XSX + XSY)
		mov	ax,YPos2
		add	ax,YGX[si]
		add	ax,YGY[di]
		add	ax,dx
		mov	Ye[2],ax	;Ye = YPos2 + (YGX + YGY) + (YSX + YSY)
		mov	ax,ZPos2
		add	ax,ZGX[si]
		add	ax,ZGY[di]
		add	ax,bp
		mov	Ze[2],ax	;Ze = ZPos2 + (ZGX + ZGY) + (ZSX + ZSY)

		call	QuickLineClip
		jc	ExitSingle2	;track non-visible ->

		mov	al,COL_RAIL2
		mov	cx,XCrt[0]
		mov	bl,YCrt[0]
		mov	dx,XCrt[2]
		mov	bh,YCrt[2]
		call	LineDraw

ExitSingle2:	ret

SingleTrack2	ENDP

;----------------------------------------------------------------------------

;* DoubleTrack1 - draw double track (SEC_SCALE1)
;*
;* pass: bx = index for rail length offset tables
;* ret : nothing
;* kill: assume all

DoubleTrack1	PROC	NEAR

;------------------------------------------------------
;* calc node centre point (P1) and track end point (P5)
;------------------------------------------------------

		mov	si,RailLength1[bx]
		mov	di,RailLength1[bx+2]

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

		mov	si,STrackEnd1[bx+0]	;x1
		mov	di,STrackEnd1[bx+2]	;y1
		mov	ax,XPos1
		add	ax,XGX[si]
		add	ax,XGY[di]
		mov	Xe[P1],ax	;Xe = XPos1 + (XGX + XGY)
		mov	ax,YPos1
		add	ax,YGX[si]
		add	ax,YGY[di]
		mov	Ye[P1],ax	;Ye = YPos1 + (YGX + YGY)
		mov	ax,ZPos1
		add	ax,ZGX[si]
		add	ax,ZGY[di]
		mov	Ze[P1],ax	;Ze = ZPos1 + (ZGX + ZGY)

		mov	si,STrackEnd1[bx+4]	;x2
		mov	di,STrackEnd1[bx+6]	;y2
		mov	ax,XPos1
		add	ax,XGX[si]
		add	ax,XGY[di]
		add	ax,cx
		mov	Xe[P5],ax	;Xe = XPos1 + (XGX + XGY) + (XSX + XSY)
		mov	ax,YPos1
		add	ax,YGX[si]
		add	ax,YGY[di]
		add	ax,dx
		mov	Ye[P5],ax	;Ye = YPos1 + (YGX + YGY) + (YSX + YSY)
		mov	ax,ZPos1
		add	ax,ZGX[si]
		add	ax,ZGY[di]
		add	ax,bp
		mov	Ze[P5],ax	;Ze = ZPos1 + (ZGX + ZGY) + (ZSX + ZSY)

;--------------------------------------------
;* sub-divide to calc 1/4, 1/2 and 3/4 points
;--------------------------------------------

;* P3 = P1 + (P5 - P1) / 2

ContTrackDraw:	mov	ax,Xe[P5]
		sub	ax,Xe[P1]	;(P5 - P1)
		sar	ax,1		;(P5 - P1) / 2
		mov	cx,ax
		add	ax,Xe[P1]	;P1 + (P5 - P1) / 2		
		mov	Xe[P3],ax	;P3 = P1 + (P5 - P1) / 2

		mov	ax,Ye[P5]
		sub	ax,Ye[P1]	;(P5 - P1)
		sar	ax,1		;(P5 - P1) / 2
		mov	dx,ax
		add	ax,Ye[P1]	;P1 + (P5 - P1) / 2		
		mov	Ye[P3],ax	;P3 = P1 + (P5 - P1) / 2

		mov	ax,Ze[P5]
		sub	ax,Ze[P1]	;(P5 - P1)
		sar	ax,1		;(P5 - P1) / 2
		mov	bp,ax
		add	ax,Ze[P1]	;P1 + (P5 - P1) / 2		
		mov	Ze[P3],ax	;P3 = P1 + (P5 - P1) / 2

;* P2 = P1 + (P5 - P1) / 4
		
		sar	cx,1		;(P5 - P1) / 4
		mov	ax,Xe[P1]
		add	ax,cx		;P1 + (P5 - P1) / 4
		mov	Xe[P2],ax	;P2 = P1 + (P5 - P1) / 4

		sar	dx,1		;(P5 - P1) / 4
		mov	ax,Ye[P1]
		add	ax,dx		;P1 + (P5 - P1) / 4
		mov	Ye[P2],ax	;P2 = P1 + (P5 - P1) / 4

		sar	bp,1		;(P5 - P1) / 4
		mov	ax,Ze[P1]
		add	ax,bp		;P1 + (P5 - P1) / 4
		mov	Ze[P2],ax	;P2 = P1 + (P5 - P1) / 4

;* P4 = P5 - (P5 - P1) / 4

		mov	ax,Xe[P5]
		sub	ax,cx		;P5 - (P5 - P1) / 4	
		mov	Xe[P4],ax	;P4 = P5 - (P5 - P1) / 4

		mov	ax,Ye[P5]
		sub	ax,dx		;P5 - (P5 - P1) / 4	
		mov	Ye[P4],ax	;P4 = P5 - (P5 - P1) / 4

		mov	ax,Ze[P5]
		sub	ax,bp		;P5 - (P5 - P1) / 4	
		mov	Ze[P4],ax	;P4 = P5 - (P5 - P1) / 4

;-----------------------------------------------------------------
;* calc lh and rh track points (scaled independently wrt distance) 
;-----------------------------------------------------------------

		mov	si,P1
		mov	di,LH_P1
		call	SortDoubleEnd

		mov	si,P2
		mov	di,LH_P2
		call	SortDoubleEnd

		mov	si,P3
		mov	di,LH_P3
		call	SortDoubleEnd

		mov	si,P4
		mov	di,LH_P4
		call	SortDoubleEnd

		mov	si,P5
		mov	di,LH_P5
		call	SortDoubleEnd

;-----------------
;* draw the tracks
;-----------------

TRACK		MACRO	point1,point2

		mov	ax,Xe[point1]
		mov	Xe[0],ax
		mov	ax,Ye[point1]
		mov	Ye[0],ax
		mov	ax,Ze[point1]
		mov	Ze[0],ax

		mov	ax,Xe[point2]
		mov	Xe[2],ax
		mov	ax,Ye[point2]
		mov	Ye[2],ax
		mov	ax,Ze[point2]
		mov	Ze[2],ax

		call	QuickLineClip
		jc	@F		;track non-visible ->

		mov	al,COL_RAIL2
		mov	cx,XCrt[0]
		mov	bl,YCrt[0]
		mov	dx,XCrt[2]
		mov	bh,YCrt[2]
		call	LineDraw
@@:

		ENDM

		TRACK	LH_P1,LH_P2
		TRACK	LH_P2,LH_P3
		TRACK	LH_P3,LH_P4
		TRACK	LH_P4,LH_P5

		TRACK	RH_P1,RH_P2
		TRACK	RH_P2,RH_P3
		TRACK	RH_P3,RH_P4
		TRACK	RH_P4,RH_P5

		ret

DoubleTrack1	ENDP
	
;----------------------------------------------------------------------------

;* DoubleTrack2 - draw double track (SEC_SCALE2)
;*
;* pass: bx = index for rail length offset tables
;* ret : nothing
;* kill: assume all

DoubleTrack2	PROC	NEAR
			  
		mov	si,RailLength2[bx]
		mov	di,RailLength2[bx+2]

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

		mov	si,STrackEnd2[bx+0]	;x1
		mov	di,STrackEnd2[bx+2]	;y1
		mov	ax,XPos2
		add	ax,XGX[si]
		add	ax,XGY[di]
		mov	Xe[P1],ax	;Xe = XPos2 + (XGX + XGY)
		mov	ax,YPos2
		add	ax,YGX[si]
		add	ax,YGY[di]
		mov	Ye[P1],ax	;Ye = YPos2 + (YGX + YGY)
		mov	ax,ZPos2
		add	ax,ZGX[si]
		add	ax,ZGY[di]
		mov	Ze[P1],ax	;Ze = ZPos2 + (ZGX + ZGY)

		mov	si,STrackEnd2[bx+4]	;x2
		mov	di,STrackEnd2[bx+6]	;y2
		mov	ax,XPos2
		add	ax,XGX[si]
		add	ax,XGY[di]
		add	ax,cx
		mov	Xe[P5],ax	;Xe = XPos2 + (XGX + XGY) + (XSX + XSY)
		mov	ax,YPos2
		add	ax,YGX[si]
		add	ax,YGY[di]
		add	ax,dx
		mov	Ye[P5],ax	;Ye = YPos2 + (YGX + YGY) + (YSX + YSY)
		mov	ax,ZPos2
		add	ax,ZGX[si]
		add	ax,ZGY[di]
		add	ax,bp
		mov	Ze[P5],ax	;Ze = ZPos2 + (ZGX + ZGY) + (ZSX + ZSY)

		jmp	ContTrackDraw	;>>>>> return via DoubleTrack1 >>>>>

DoubleTrack2	ENDP

;----------------------------------------------------------------------------

;* SortDoubleEnd - draw double track end points
;*
;* pass: bx = index for double track end offset tables
;*       si = index for point source
;*       di = index for lh and rh points destination
;*       TrackScale
;* ret : Xe[di+0], Ye[di+0], Ze[di+0] (lh point)
;*       Xe[di+2], Ye[di+2], Ze[di+2] (rh point)
;* kill: assume all (except bx)

SortDoubleEnd	PROC	NEAR
			  
;----------------------------------
;* calc max(abs(x), abs(y), abs(z))
;----------------------------------

		mov	ax,Ze[si]
		ABSV	ax
		mov	bp,ax		;bp = abs(z)
	
		mov	ax,Ye[si]
		ABSV	ax
		mov	cx,ax		;cx = abs(y)

		mov	ax,Xe[si]
		ABSV	ax		;ax = abs(x)

		cmp	ax,cx		;abs(x) >= abs(y)?
		jae	@F		;yes ->
		mov	ax,cx

@@:		cmp	ax,bp		;max(abs(x), abs(y)) >= abs(z)?
		jae	@F		;yes ->
		mov	ax,bp

;--------------------------------
;* calc scaling mode wrt distance
;--------------------------------

;* note: To ensure that no clipping errors occur, the scaling distances have
;*       been calculated using 3D Euclidian distances:-
;*
;*       max dist = sqrt(sqr(dx) + sqr(dy) + sqr(dz))
;*
;*       where d = dx = dy = dz
;*
;*       max dist = sqrt(3 * sqr(d))
;*
;*	 d = sqrt(sqr(max dist) / 3)
;*
;*       However, ze is scaled (worst case ze * 2.5 for INT_VIEWMODE).
;*
;*       Therefore, dz at worst would be 2.5 * 2 * dz = 5 * dz.
;*
;*       max dist = sqrt(sqr(dx) + sqr(y) + 5 * sqr(dz))
;*
;*       where d = dx = dy = dz
;*
;*       max dist = sqrt(7 * sqr(d))
;*
;*	 d = sqrt(sqr(max dist) / 7)
;*
;*       max dist = 1024, d = sqrt(sqr(1024) / 7) = 387
;*       max dist = 2048, d = sqrt(sqr(2048) / 7) = 774
;*       max dist = 4096, d = sqrt(sqr(4096) / 7) = 1548
;*       max dist = 8192, d = sqrt(sqr(8192) / 7) = 3096

@@:		mov	cx,TrackScale	;cl = position scale, ch = offset scale

		cmp	ax,387		;*16 scaling ok?
		jb	ScaleOk		;yes ->
		dec	cl
		inc	ch

		cmp	ax,774		;*8 scaling ok?
		jb	ScaleOk		;yes ->
		dec	cl
		inc	ch

		cmp	ax,1548		;*4 scaling ok?
		jb	ScaleOk		;yes ->
		dec	cl
		inc	ch

		cmp	ax,3096		;*2 scaling ok?
		jb	ScaleOk		;yes ->
		dec	cl
		inc	ch

;-------------------
;* sort lh end point
;-------------------
 
ScaleOk:	push	bx		;store offset index
		push	si		;store point index
		push	di  		;store result index

		mov	di,Xe[si]	;x pos
		mov	dx,Ye[si]	;y pos
		mov	bp,Ze[si]	;z pos

		sal	di,cl		;scale x pos
		sal	dx,cl		;scale y pos
		sal	bp,cl		;scale z pos

		xchg	cl,ch		;cl = offset scale, ch = position scale

		mov	si,DTrackEnd16[bx+0]	;xl
		mov	bx,DTrackEnd16[bx+2]	;yl

		mov	ax,XGX[si]
		add	ax,XGY[bx]
		sar	ax,cl  		;scale x offset
		add	ax,di

		pop	di 		;restore result index

		mov	Xe[di],ax

		mov	ax,YGX[si]
		add	ax,YGY[bx]
		sar	ax,cl	    	;scale y offset
		add	ax,dx
		mov	Ye[di],ax

		mov	ax,ZGX[si]
		add	ax,ZGY[bx]
		sar	ax,cl		;scale z offset
		add	ax,bp
		mov	Ze[di],ax

		xchg	cl,ch		;cl = position scale, ch = offset scale
		add	di,2		;di indexes rh point result
		pop	si  		;restore point index
		pop	bx		;restore offset index

;-------------------
;* sort rh end point
;-------------------
 
		push	bx		;store offset index
		push	di  		;store result index

		mov	di,Xe[si]	;x pos
		mov	dx,Ye[si]	;y pos
		mov	bp,Ze[si]	;z pos

		sal	di,cl		;scale x pos
		sal	dx,cl		;scale y pos
		sal	bp,cl		;scale z pos

		xchg	cl,ch		;cl = offset scale, ch = position scale

		mov	si,DTrackEnd16[bx+4]	;xr
		mov	bx,DTrackEnd16[bx+6]	;yr

		mov	ax,XGX[si]
		add	ax,XGY[bx]
		sar	ax,cl	     	;scale x offset
		add	ax,di

		pop	di 		;restore result index

		mov	Xe[di],ax

		mov	ax,YGX[si]
		add	ax,YGY[bx]
		sar	ax,cl		;scale y offset
		add	ax,dx
		mov	Ye[di],ax

		mov	ax,ZGX[si]
		add	ax,ZGY[bx]
		sar	ax,cl		;scale z offset
		add	ax,bp
		mov	Ze[di],ax

		pop	bx		;restore offset index

		ret

SortDoubleEnd	ENDP

VISCODE		ENDS

;============================================================================

		END

