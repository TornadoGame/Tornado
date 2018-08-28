;****************************************************************************
;*
;* TAN_DRVR.ASM
;*
;* Screen dependant routines for Tandy machines.
;*
;* 06.06.1989 - KJB
;* 29.08.1991 - KJB - TAN_PrtC3 added.
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	TAN_VMode
		PUBLIC	TAN_DLoad
		PUBLIC	TAN_SetPx
		PUBLIC	TAN_Line
		PUBLIC	TAN_VLine
		PUBLIC	TAN_HLine
		PUBLIC	TAN_PFill
		PUBLIC	TAN_MFill
		PUBLIC	TAN_SFill
		PUBLIC	TAN_PrtC1
		PUBLIC	TAN_PrtC2
		PUBLIC	TAN_PrtC3
		PUBLIC	TAN_SSprite
		PUBLIC	TAN_MSprite
		PUBLIC	TAN_BSprite
		PUBLIC	TAN_QSprite
		PUBLIC	TAN_InitSS
		PUBLIC	TAN_InitMS
		PUBLIC	TAN_BFill
		PUBLIC	TAN_SaveMouse
		PUBLIC	TAN_LoadMouse
		PUBLIC	TAN_SaveScreen
		PUBLIC	TAN_LoadScreen
		PUBLIC	TAN_UncompPic
		PUBLIC	TAN_HFill

		PUBLIC	TAN_CalcAddr

		PUBLIC	SeperateData

		PUBLIC	TAN_LINEADD

		EXTRN	RunLenDecode:FAR
		EXTRN	ResetMouse:FAR

		EXTRN	WorkScrPtr:WORD
		EXTRN	RealScrPtr:WORD
		EXTRN	MinY:WORD
		EXTRN	MaxY:WORD
		EXTRN	LhsX:WORD
		EXTRN	RhsX:WORD
		EXTRN	PrtLn:WORD
		EXTRN	PrtCl:WORD
		EXTRN	CharSetPtr1:WORD
		EXTRN	CharSetPtr2:WORD
		EXTRN	CharSetPtr3:WORD
		EXTRN	ClipXMin:WORD
		EXTRN	ClipXMax:WORD
		EXTRN	ClipYMin:WORD
		EXTRN	ClipYMax:WORD
		EXTRN	SSpriteList:WORD
		EXTRN	MSpriteList:WORD
		EXTRN	QSpriteList:WORD
		EXTRN	HrznXMin:WORD
		EXTRN	HrznXMax:WORD

		EXTRN	PixelCol:BYTE
		EXTRN	LineCol:BYTE
		EXTRN	FillCol:BYTE
		EXTRN	HrznLhsCol:BYTE
		EXTRN	HrznRhsCol:BYTE
		EXTRN	ForeCol:BYTE
		EXTRN	BackCol:BYTE
		EXTRN	PrintOver:BYTE
		EXTRN	SSpriteID:BYTE
		EXTRN	MSpriteID:BYTE
		EXTRN	QSpriteID:BYTE
		EXTRN	WorkScreen:BYTE
		EXTRN	CopyScreen:BYTE
		EXTRN	MouseHouse:BYTE

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

TAN_REAL_SCR	EQU	0b800h		;TAN segment ptr

TAN_LINEADD	EQU	160		;160 bytes / line

ColMask		DB     	11110000b
		DB	00001111b

ScrMask		DB 	00001111b
		DB	11110000b

OctTable	DW	Oct2		;Dx > 0, Dy > Dx
		DW	Oct1		;Dx > 0, Dx > Dy
		DW	Oct7		;Dx < 0, Dy > Dx
		DW	Oct8		;Dx < 0, Dx > Dy

LMask		LABEL	WORD
		DB	00000000b,00000000b
		DB	11110000b,00000000b	
		DB	11111111b,00000000b
		DB	11111111b,11110000b	

RMask		LABEL	WORD
		DB	00001111b,11111111b
		DB	00000000b,11111111b	
		DB	00000000b,00001111b
		DB	00000000b,00000000b	

MeshMask	DW	0		;mesh fill mask

;* Duplicate bits table (1010 -> 1111000011110000)

DupTable	LABEL	WORD
		DB	00000000b,00000000b
		DB	00000000b,00001111b
		DB	00000000b,11110000b
		DB	00000000b,11111111b
		DB	00001111b,00000000b
		DB	00001111b,00001111b
		DB	00001111b,11110000b
		DB	00001111b,11111111b
		DB	11110000b,00000000b
		DB	11110000b,00001111b
		DB	11110000b,11110000b
		DB	11110000b,11111111b
		DB	11111111b,00000000b
		DB	11111111b,00001111b
		DB	11111111b,11110000b
		DB	11111111b,11111111b

;* horizon fill masks

HrznMask	LABEL	WORD
		DB	00000000b,00000000b
		DB	11110000b,00000000b
		DB	11111111b,00000000b
		DB	11111111b,11110000b

DATA		ENDS

;============================================================================

WSDATA		SEGMENT PARA PUBLIC 'DATA'

WSDATA		ENDS

;============================================================================

GCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:GCODE
		ASSUME DS:DATA

;* TAN_VMode - set video mode
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all
;*
;* note: Reset mouse immediately after setting video mode (see MOUSE.ASM).

TAN_VMode	PROC	FAR

		mov	ah,0 		;service 0, set video mode
		mov	al,009h		;320 * 200, 16 colour
		int	010h		;BIOS

		call	ResetMouse

		mov	ax,WSDATA    	;system memory work screen
		mov	WorkScrPtr,ax
		mov	ax,TAN_REAL_SCR
		mov	RealScrPtr,ax

		ret

TAN_VMode	ENDP

;----------------------------------------------------------------------------

;* TAN_DLoad - download work screen to real screen
;*
;* pass: WorkScrPtr
;*       RealScrPtr
;* ret : nothing
;* kill: ax, bx, cx, dx, si, di, bp, flags
;*
;* lines 0, 4, 8 ... 00000h
;* lines 1, 5, 9 ... 02000h
;* lines 2, 6,10 ... 04000h
;* lines 3, 7,11 ... 06000h
 
TAN_DLoad	PROC	FAR

		push	ds
		push	es

		mov	ax,RealScrPtr	
		mov	es,ax
		mov	ax,WorkScrPtr
		mov	ds,ax

		xor	si,si
		xor	di,di

       		mov	ax,50
		mov	bx,160

CopyLoop:	mov	cx,bx		;line 0
		rep	movsb
		add	di,02000h-TAN_LINEADD
		mov	cx,bx		;line 1
		rep	movsb
		add	di,02000h-TAN_LINEADD
		mov	cx,bx		;line 2
		rep	movsb
		add	di,02000h-TAN_LINEADD
		mov	cx,bx		;line 3
		rep	movsb
		sub	di,06000h

		dec	ax
		jnz	CopyLoop

		pop	es
		pop	ds
		ret

TAN_DLoad	ENDP

;----------------------------------------------------------------------------

;* TAN_SetPx - set pixel
;*
;* pass: bl = y (0 - 199)
;*       cx = x (0 - 319)
;*       PixelCol
;* ret : nothing
;* kill: ax, si, di, flags

TAN_SetPx	PROC	FAR

		push	es
		mov	ax,WorkScrPtr
		mov	es,ax

		call	TAN_CalcAddr	;es:di -> screen
		mov 	si,cx 
		and 	si,1
		mov 	al,ScrMask[si]	;screen mask
		and	al,es:[di]	;clear out screen pixel
		mov	ah,PixelCol	
		and	ah,ColMask[si]	;colour mask
		or	al,ah
		stosb			;set pixel colour	

		pop	es
		ret

TAN_SetPx	ENDP

;----------------------------------------------------------------------------

;* TAN_Line - draw line between two points
;*
;* pass: cx, bl = x1, y1
;*       dx, bh = x2, y2
;*       LineCol
;* ret : nothing
;* kill: assume all
;*
;* mods: Octant routines corrected (04.01.1991 - KJB).

TAN_Line	PROC	FAR

		push	es
		mov	ax,WorkScrPtr
		mov	es,ax

;* test for vertical and horizontal lines (use faster routines)

		cmp	cx,dx		;x1 = x2?
		je	VLineLink	;yes, draw vertical line ->
		cmp	bl,bh		;y1 = y2?
		je	HLineLink	;yes, draw horizontal line ->

		jb	NoSwap		;y1 < y2 ->
		xchg	bl,bh
		xchg	cx,dx
NoSwap:		sub	bh,bl		;bh = abs(Dy)
		mov	di,bx
		and	di,000ffh	;di = y1
		xchg	bl,bh
		xor	bh,bh		;bx = abs(Dy)
		xor	si,si		;jmp offset 0
		sub	dx,cx		;dx = Dx
		rcl	si,1		;jmp offset = 1 if Dx < 0
		mov	ax,dx
		cwd
		xor	ax,dx
		sub	ax,dx
		mov	dx,ax		;dx = abs(Dx)
		cmp	bx,dx		;abs(Dx) > abs(Dy)?
		rcl	si,1		;jmp offset * 2 + 1 if abs(Dx) > abs(Dy)
		shl	si,1		;jmp offset = 0, 2, 4, or 6	

;* bx = Dy
;* cx = x1
;* dx = Dx
;* di = y1
;* si = octant jump table offset

		shl	di,1		;*2
		shl	di,1		;*4
		shl	di,1		;*8
		shl	di,1		;*16
		shl	di,1		;*32
		mov	ax,di
		shl	di,1		;*64
		shl	di,1		;*128
		add	di,ax		;y * 160

		mov	bp,bx
		mov	bx,cx
		and	bx,1
		mov	al,ScrMask[bx]
		mov	ah,ColMask[bx]
		and	ah,LineCol
		mov	bx,bp

		shr	cx,1		;/2
		add	di,cx

		mov	bp,TAN_LINEADD

		jmp	OctTable[si]	;jump to octant routine
		
VLineLink:	jmp	IntoVLine	;jump into VLine routine ->
HLineLink:	jmp	IntoHLine	;jump into HLine routine ->

;* al = mask
;* ah = colour
;* bx = Dy
;* dx = Dx
;* di = screen ptr
;* bp = line add on

;* octant 1: Dx > 0, Dx > Dy

Oct1:		mov	cx,dx
		inc	cx		;count = Dx + 1	

		mov	si,dx
		shr	si,1		;error = Dx / 2
		adc	si,0		;1/2 bit round up

Oct1Lp:		and	es:[di],al	;plot x, y
		or	es:[di],ah
		
		dec	cx		;count = count - 1
		jz	Oct1End		;exit if count = 0

		ror	ah,1		;x = x + 1
		ror	ah,1
		ror	ah,1
		ror	ah,1
		ror	al,1
		ror	al,1
		ror	al,1
		ror	al,1
		cmc
		adc	di,0		;inc di if mask wrap around
		sub	si,bx		;error = error - Dy
		ja	Oct1Lp		;if error > 0 then no y change ->

		add	si,dx		;error = error + Dx
		add	di,bp		;y = y + 1
		jmp	Oct1Lp

Oct1End:	pop	es
		ret

;* octant 2: Dx > 0, Dy > Dx

Oct2:		mov	cx,bx
		inc	cx		;count = Dy + 1	

		mov	si,bx
		shr	si,1		;error = Dy / 2
		adc	si,0		;1/2 bit round up

Oct2Lp:		and	es:[di],al	;plot x, y
		or	es:[di],ah
		
		dec	cx		;count = count - 1
		jz	Oct2End		;exit if count = 0

		add	di,bp		;y = y + 1
		sub	si,dx		;error = error - Dx
		ja	Oct2Lp		;if error > 0 then no x change ->
		
		add	si,bx		;error = error + Dy
		ror	ah,1		;x = x + 1
		ror	ah,1
		ror	ah,1
		ror	ah,1
		ror	al,1
		ror	al,1
		ror	al,1
		ror	al,1
		cmc
		adc	di,0		;inc di if mask wrap around
		jmp	Oct2Lp

Oct2End:        pop	es
		ret

;* octant 7: Dx < 0, Dy > Dx

Oct7:		mov	cx,bx
		inc	cx		;count = Dy + 1	

		mov	si,bx
		shr	si,1		;error = Dy / 2
		adc	si,0		;1/2 bit round up

Oct7Lp:		and	es:[di],al	;plot x, y
		or	es:[di],ah
		
		dec	cx		;count = count - 1
		jz	Oct7End		;exit if count = 0

		add	di,bp		;y = y + 1
		sub	si,dx		;error = error - Dx
		ja	Oct7Lp		;if error > 0 then no x change ->
		
		add	si,bx		;error = error + Dy
		rol	ah,1		;x = x - 1
		rol	ah,1
		rol	ah,1 
		rol	ah,1
		rol	al,1
		rol	al,1
		rol	al,1
		rol	al,1
		cmc
		sbb	di,0		;dec di if mask wrap around
		jmp	Oct7Lp

Oct7End:	pop	es
		ret

;* octant 8: Dx < 0, Dx > Dy
 
Oct8:		mov	cx,dx
		inc	cx		;count = Dx + 1	

		mov	si,dx
		shr	si,1		;error = Dx / 2
		adc	si,0		;1/2 bit round up

Oct8Lp:		and	es:[di],al	;plot x, y
		or	es:[di],ah
		
		dec	cx		;count = count - 1
		jz	Oct8End		;exit if count = 0

		rol	ah,1		;x = x - 1
		rol	ah,1
		rol	ah,1
		rol	ah,1
		rol	al,1
		rol	al,1
		rol	al,1
		rol	al,1
		cmc
		sbb	di,0		;dec di if mask wrap around
		sub	si,bx		;error = error - Dy
		ja	Oct8Lp		;if error > 0 then no y change ->

		add	si,dx		;error = error + Dx
		add	di,bp		;y = y + 1
		jmp	Oct8Lp

Oct8End:	pop	es
		ret

TAN_Line	ENDP

;----------------------------------------------------------------------------

;* TAN_VLine - draw vertical line between two points
;*
;* pass: bl = y1
;*       bh = y2
;*       cx = x1
;*       LineCol
;* ret : nothing
;* kill: assume all

TAN_VLine	PROC	FAR

		push	es
		mov	ax,WorkScrPtr
		mov	es,ax

IntoVLine:	cmp	bl,bh		;y1 <= y2?
		jbe	VLineYOk	;yes, co-ords ok ->
		xchg	bl,bh
VLineYOk:	mov	di,bx
		and	di,000ffh	;di = y1
		
		sub	bh,bl		;bh = y2 - y1
		mov	bl,bh
		xor	bh,bh
		inc	bx		;count = (y2 - y1) + 1
		mov	bp,bx

		shl	di,1		;*2
		shl	di,1		;*4
		shl	di,1		;*8
		shl	di,1		;*16
		shl	di,1		;*32
		mov	ax,di
		shl	di,1		;*64
		shl	di,1		;*128
		add	di,ax		;y * 160

		mov	bx,cx
		and	bx,1
		mov	al,ScrMask[bx]
		mov	ah,ColMask[bx]
		and	ah,LineCol

		shr	cx,1		;/2
		add	di,cx		;y * 160 + x / 2

		mov	cx,bp
		mov	bp,TAN_LINEADD

VLineLoop:	and	es:[di],al
		or	es:[di],ah
		add	di,bp
		loop	VLineLoop

		pop	es
		ret

TAN_VLine	ENDP

;----------------------------------------------------------------------------

;* TAN_HLine - draw horizontal line between two points
;*
;* pass: bl = y1
;*       cx = x1
;*       dx = x2
;*       LineCol
;* ret : nothing
;* kill: assume all

TAN_HLine	PROC	FAR

		push	es
		mov	ax,WorkScrPtr
		mov	es,ax

IntoHLine:	cmp	cx,dx		;x1 <= x2?
		jbe	HLineXOk	;yes, co-ords ok ->
		xchg	cx,dx
HLineXOk:   	mov	al,LineCol
		mov	ah,al
		mov	bp,ax

		mov	di,bx
		and	di,000ffh
		shl	di,1		;*2
		shl	di,1		;*4
		shl	di,1		;*8
		shl	di,1		;*16
		shl	di,1		;*32
		mov	ax,di
		shl	di,1		;*64
		shl	di,1		;*128
		add	di,ax		;y * 160

		mov	ax,cx
		shr	ax,1		;/2
		and	ax,0fffeh	;word boundary
		add	di,ax		;y * 80 + x / 2

		mov	bx,cx
		and	bx,3		;lhs word disp

		mov	si,dx
		and	si,3		;rhs word disp

		sub	cx,dx
		neg	cx
		add	cx,bx		;trim off lh side
		sub	cx,4
		sub	cx,si		;trim off rh side

		shl	bx,1		;*2 for word index
		shl	si,1		;*2 for word index

		sar	cx,1		;4 pixels / word
		sar	cx,1		;cx = number of whole words to fill

		js	ShortHLine	;cx < 0 = short line ->

		mov	ax,LMask[bx]	;mask in lh line end
		mov	dx,ax
		and	ax,es:[di]
		not	dx
		and	dx,bp
		or	ax,dx
		stosw

		mov	ax,bp		;fill line middle
		rep	stosw

		mov	ax,RMask[si]	;mask in rh line end
		mov	dx,ax
		and	ax,es:[di]
		not	dx
		and	dx,bp
		or	ax,dx
		stosw

HLineExit:	pop	es
		ret

;* short horizontal line draw (exception)

ShortHLine:	mov	ax,LMask[bx]
		or	ax,RMask[si]
		mov	dx,ax
		and	ax,es:[di]
		not	dx
		and	dx,bp
		or	ax,dx
		stosw
		jmp	HLineExit

TAN_HLine	ENDP

;----------------------------------------------------------------------------

;* TAN_PFill - fill polygon from table
;*
;* pass: MinY, MaxY
;*       LhsX, RhsX
;*       FillCol
;* ret : nothing
;* kill: ax, bx, cx, dx, di, bp, flags

TAN_PFill	PROC	FAR

		push	si
		push	es
		mov	ax,WorkScrPtr
		mov	es,ax

		mov	bp,WORD PTR FillCol
		mov	bx,MinY
		mov	cx,MaxY
	    	test	bx,1
	    	jz	HatchOk
	    	ror	bp,1		;rotate hatch if start on odd line
	    	ror	bp,1
	    	ror	bp,1
	    	ror	bp,1
HatchOk:	sub	cx,bx
		inc	cx		;cx = number of lines
		shl	bx,1		;bx = x table index
		mov	di,bx
		shl	di,1		;*4
		shl	di,1		;*8
		shl	di,1		;*16
		shl	di,1		;*32
		mov	ax,di
		shl	di,1		;*64
		shl	di,1		;*128
		add	di,ax		;*160

;* bx = x table index
;* cx = number of lines
;* di -> screen (x = 0)
;* bp = colour

NextFillLine:	push	bx
		push	cx
		push	di

		mov	ax,RhsX[bx]
		mov	dx,ax
		mov	ax,LhsX[bx]
		mov	cx,ax

		mov	bx,cx
		and	bx,3		;lhs word disp

		mov	si,dx
		and	si,3		;rhs word disp

		sub	cx,dx
		ja	FixPoints	;error lh x > rh x ->
PointsFixed:	neg	cx
		add	cx,bx		;trim off lh side
		sub	cx,4
		sub	cx,si		;trim off rh side

		shr	ax,1		;/2
		and	ax,0fffeh	;word boundary
		add	di,ax		;y + x / 2

		shl	bx,1		;*2 for word index
		shl	si,1		;*2 for word index

		sar	cx,1		;4 pixels / word
		sar	cx,1		;cx = number of whole words to fill

		js	ShortLine	;cx < 0 = short line ->

		mov	ax,LMask[bx]	;mask in lh line end
		mov	dx,ax
		and	ax,es:[di]
		not	dx
		and	dx,bp
		or	ax,dx
		stosw

		mov	ax,bp		;fill line middle
		rep	stosw

		mov	ax,RMask[si]	;mask in rh line end
		mov	dx,ax
		and	ax,es:[di]
		not	dx
		and	dx,bp
		or	ax,dx
		stosw

FillEndLoop:	pop	di
		pop	cx
		pop	bx
		add	bx,2		;next table index
		add	di,TAN_LINEADD 	;y = y + 1
	     	ror	bp,1		;rotate hatch
	     	ror	bp,1
	     	ror	bp,1
	     	ror	bp,1
		loop	NextFillLine
		
		pop	es
		pop	si
		ret

;* lh x > rh x error condition (exception)

FixPoints:	mov	cx,ax		;cx = lh x
		xchg	cx,dx		;swap lh x, rh x
		mov	ax,cx		;ax = lh x
		xchg	bx,si		;swap lh disp, rh disp
		sub	cx,dx
		jmp	PointsFixed

;* short line draw (exception)

ShortLine:	mov	ax,LMask[bx]
		or	ax,RMask[si]
		mov	dx,ax
		and	ax,es:[di]
		not	dx
		and	dx,bp
		or	ax,dx
		stosw
		jmp	FillEndLoop

TAN_PFill	ENDP

;----------------------------------------------------------------------------

;* TAN_MFill - fill "transparent" polygon from table
;*
;* pass: MinY, MaxY
;*       LhsX, RhsX
;*       FillCol
;* ret : nothing
;* kill: ax, bx, cx, dx, di, bp, flags

TAN_MFill	PROC	FAR

		push	si
		push	es
		mov	ax,WorkScrPtr
		mov	es,ax

		mov	ax,0f0f0h
		mov	bp,WORD PTR FillCol
		mov	bx,MinY
		mov	cx,MaxY
		test	bx,1
		jz	MeshHatchOk
		ror	bp,1		;rotate hatch if start on odd line
		ror	bp,1
		ror	bp,1
		ror	bp,1
		ror	ax,1		;rotate mesh mask if start on odd line
		ror	ax,1
		ror	ax,1
		ror	ax,1
MeshHatchOk:	mov	MeshMask,ax
		not	ax
		and	bp,ax		;colour AND NOT mesh mask
		sub	cx,bx
		inc	cx		;cx = number of lines
		shl	bx,1		;bx = x table index
		mov	di,bx
		shl	di,1		;*4
		shl	di,1		;*8
		shl	di,1		;*16
		shl	di,1		;*32
		mov	ax,di
		shl	di,1		;*64
		shl	di,1		;*128
		add	di,ax		;*160

;* bx = x table index
;* cx = number of lines
;* di -> screen (x = 0)
;* bp = colour

NextMeshLine:	push	bx
		push	cx
		push	di

		mov	ax,RhsX[bx]
		mov	dx,ax
		mov	ax,LhsX[bx]
		mov	cx,ax

		mov	bx,cx
		and	bx,3		;lhs word disp

		mov	si,dx
		and	si,3		;rhs word disp

		sub	cx,dx
		ja	FixMeshPts	;error lh x > rh x ->
MeshPtsFixed:	neg	cx
		add	cx,bx		;trim off lh side
		sub	cx,4
		sub	cx,si		;trim off rh side

		shr	ax,1		;/2
		and	ax,0fffeh	;word boundary
		add	di,ax		;y + x / 2

		shl	bx,1		;*2 for word index
		shl	si,1		;*2 for word index

		sar	cx,1		;4 pixels / word
		sar	cx,1		;cx = number of whole words to fill

		mov	dx,MeshMask	;pick up mesh mask

		js	ShortMeshLine	;cx < 0 = short line ->

		mov	ax,LMask[bx]	;mask in lh line end
		or	ax,dx
		mov	bx,ax
		and	ax,es:[di]
		not	bx
		and	bx,bp
		or	ax,bx
		stosw

		mov	ax,TAN_LINEADD/2;words
		sub	ax,cx
		shl	ax,1		;*2
		shl	ax,1		;*4
		shl	ax,1		;*8
		lea	cx,FastMeshFill
		add	cx,ax
		jmp	cx

MeshEndLoop:	pop	di
		pop	cx
		pop	bx
		add	bx,2		;next table index
		add	di,TAN_LINEADD 	;y = y + 1
		ror	bp,1		;rotate hatch
		ror	bp,1
		ror	bp,1
		ror	bp,1
		ror	dx,1		;rotate mesh mask
		ror	dx,1
		ror	dx,1
		ror	dx,1
		mov	MeshMask,dx
		loop	NextMeshLine
		
		pop	es
		pop	si
		ret

;* lh x > rh x error condition (exception)

FixMeshPts:	mov	cx,ax		;cx = lh x
		xchg	cx,dx		;swap lh x, rh x
		mov	ax,cx		;ax = lh x
		xchg	bx,si		;swap lh disp, rh disp
		sub	cx,dx
		jmp	MeshPtsFixed

;* short line draw (exception)

ShortMeshLine:	mov	ax,LMask[bx]
		or	ax,RMask[si]
		or	ax,dx
		mov	bx,ax
		and	ax,es:[di]
		not	bx
		and	bx,bp
		or	ax,bx
		stosw
		jmp	MeshEndLoop

;* mesh fill line middle

FastMeshFill	LABEL	NEAR

;* this macro generates 8 bytes of code each iteration

		REPT	80

		mov	ax,es:[di]
		and	ax,dx
		or	ax,bp
		stosw

		ENDM

		mov	ax,RMask[si]	;mask in rh line end
		or	ax,dx
		mov	bx,ax
		and	ax,es:[di]
		not	bx
		and	bx,bp
		or	ax,bx
		stosw

		jmp	MeshEndLoop

TAN_MFill	ENDP

;----------------------------------------------------------------------------

;* TAN_SFill - fill "smoke" polygon from table
;*
;* pass: MinY, MaxY
;*       LhsX, RhsX
;*       FillCol
;* ret : nothing
;* kill: ax, bx, cx, dx, di, bp, flags

TAN_SFill	PROC	FAR

		push	si
		push	es
		mov	ax,WorkScrPtr
		mov	es,ax

		mov	ax,0ff0fh
		mov	bp,WORD PTR FillCol
		mov	bx,MinY
		mov	cx,MaxY
		test	bx,1
		jz	SmokeHatchOk
		xchg	ax,bp		;rotate hatch if start on odd line
		xchg	al,ah
		xchg	ax,bp
		xchg	al,ah		;rotate mesh mask if start on odd line
SmokeHatchOk:	mov	MeshMask,ax
		not	ax
		and	bp,ax		;colour AND NOT mesh mask
		sub	cx,bx
		inc	cx		;cx = number of lines
		shl	bx,1		;bx = x table index
		mov	di,bx
		shl	di,1		;*4
		shl	di,1		;*8
		shl	di,1		;*16
		shl	di,1		;*32
		mov	ax,di
		shl	di,1		;*64
		shl	di,1		;*128
		add	di,ax		;*160

;* bx = x table index
;* cx = number of lines
;* di -> screen (x = 0)
;* bp = colour

NextSmokeLine:	push	bx
		push	cx
		push	di

		mov	ax,RhsX[bx]
		mov	dx,ax
		mov	ax,LhsX[bx]
		mov	cx,ax

		mov	bx,cx
		and	bx,3		;lhs word disp

		mov	si,dx
		and	si,3		;rhs word disp

		sub	cx,dx
		ja	FixSmokePts	;error lh x > rh x ->
SmokePtsFixed:	neg	cx
		add	cx,bx		;trim off lh side
		sub	cx,4
		sub	cx,si		;trim off rh side

		shr	ax,1		;/2
		and	ax,0fffeh	;word boundary
		add	di,ax		;y + x / 2

		shl	bx,1		;*2 for word index
		shl	si,1		;*2 for word index

		sar	cx,1		;4 pixels / word
		sar	cx,1		;cx = number of whole words to fill

		mov	dx,MeshMask	;pick up mesh mask

		js	ShortSmokeLine	;cx < 0 = short line ->

		mov	ax,LMask[bx]	;mask in lh line end
		or	ax,dx
		mov	bx,ax
		and	ax,es:[di]
		not	bx
		and	bx,bp
		or	ax,bx
		stosw

		mov	ax,TAN_LINEADD/2;words
		sub	ax,cx
		shl	ax,1		;*2
		shl	ax,1		;*4
		shl	ax,1		;*8
		lea	cx,FastSmokeFill
		add	cx,ax
		jmp	cx

SmokeEndLoop:	pop	di
		pop	cx
		pop	bx
		add	bx,2		;next table index
		add	di,TAN_LINEADD 	;y = y + 1
		xchg	dx,bp		;rotate hatch
		xchg	dl,dh
		xchg	dx,bp
		xchg	dl,dh		;rotate mesh mask
		mov	MeshMask,dx
		loop	NextSmokeLine
		
		pop	es
		pop	si
		ret

;* lh x > rh x error condition (exception)

FixSmokePts:	mov	cx,ax		;cx = lh x
		xchg	cx,dx		;swap lh x, rh x
		mov	ax,cx		;ax = lh x
		xchg	bx,si		;swap lh disp, rh disp
		sub	cx,dx
		jmp	SmokePtsFixed

;* short line draw (exception)

ShortSmokeLine:	mov	ax,LMask[bx]
		or	ax,RMask[si]
		or	ax,dx
		mov	bx,ax
		and	ax,es:[di]
		not	bx
		and	bx,bp
		or	ax,bx
		stosw
		jmp	SmokeEndLoop

;* mesh fill line middle

FastSmokeFill	LABEL	NEAR

;* this macro generates 8 bytes of code each iteration

		REPT	80

		mov	ax,es:[di]
		and	ax,dx
		or	ax,bp
		stosw

		ENDM

		mov	ax,RMask[si]	;mask in rh line end
		or	ax,dx
		mov	bx,ax
		and	ax,es:[di]
		not	bx
		and	bx,bp
		or	ax,bx
		stosw

		jmp	SmokeEndLoop

TAN_SFill	ENDP

;----------------------------------------------------------------------------

;* TAN_CalcAddr - calculate screen address
;*
;* pass: bl = y (0 - 199)
;*       cx = x (0 - 319)
;* ret : di = screen address = y * 160 + x / 2
;* kill: ax, flags

TAN_CalcAddr	PROC	NEAR

		mov	al,bl
		xor	ah,ah
		shl	ax,1		;*2
		shl	ax,1		;*4
		shl	ax,1		;*8
		shl	ax,1		;*16
		shl	ax,1		;*32
		mov	di,ax
		shl	ax,1   		;*64
		shl	ax,1		;*128
		add	di,ax		;*160
		mov	ax,cx
		shr	ax,1		;/2
		add	di,ax
		ret

TAN_CalcAddr	ENDP

;----------------------------------------------------------------------------

;* TAN_PrtC1 - print character type 1 (7 by 9)
;*
;* pass: al = ASCII code
;*       PrtLn
;*       PrtCl
;*       ForeCol
;*       BackCol
;*       PrintOver
;*       CharSetPtr1
;* ret : PrtCl modified
;* kill: bp, flags
;* note: PrtCl is rounded down to 4 pixel steps (effectively 80 columns).
;*       No checks are made for PrtLn and PrtCl being off screen.
;*       ForeCol and BackCol are used as words.

TAN_PrtC1	PROC	FAR

		push	ax
		push	bx
		push	cx
		push	dx
		push	si
		push	di
		push	es

		sub	al,' '		;character set starts with space
		xor	ah,ah
		mov	si,ax
		shl	ax,1
		shl	ax,1
		shl	ax,1
		add	si,ax		;si = char * 9
		add	si,CharSetPtr1	;si -> char pattern data

		mov	bl,BYTE PTR PrtLn
		mov	cx,PrtCl
		and	cx,0fffch
		call	TAN_CalcAddr 	;di -> screen

		mov	ax,WorkScrPtr
		mov	es,ax		

		mov	cx,9

;* main print loop

PrtC1Loop:	lodsb			;al = char pattern data
		
;* expand pattern data, ie. 0aah -> 0f0f0f0f0h (4 bits / pixel)

		mov	bl,al
		and	bx,0000fh
		shl	bx,1
		mov	dx,DupTable[bx]

		shr	al,1
		shr	al,1
		shr	al,1
		mov	bl,al
		and	bx,0001eh
		mov	ax,DupTable[bx]

;* ax, dx = expanded data

		mov	bx,ax
		mov	bp,dx

		not	bx		;get background masks
		not	bp

		and	ax,WORD PTR ForeCol	;get foreground pixels
		and	dx,WORD PTR ForeCol

		test	PrintOver,1 	;print 'over' mode?
		jnz	PrtC1Over	;yes ->

		and	bx,WORD PTR BackCol	;get background pixels
		and	bp,WORD PTR BackCol	

		or	ax,bx		;merge foreground / background
		or	dx,bp
		
		xor	bx,bx		;clear all pixels
		xor	bp,bp

PrtC1Over:	and	es:[di],bx	;clear pixels
		or	es:[di],ax	;set pixels
		and	es:[di+2],bp	;clear pixels
		or	es:[di+2],dx	;set pixels

		add	di,TAN_LINEADD	;next line
		loop	PrtC1Loop

		add	PrtCl,8		;next column

		pop	es
		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax

		ret

TAN_PrtC1	ENDP

;----------------------------------------------------------------------------

;* TAN_PrtC2 - print character type 2 (3 by 5)
;*
;* pass: al = ASCII code
;*       PrtLn
;*       PrtCl
;*       ForeCol
;*       BackCol
;*	 PrintOver
;*       CharSetPtr2
;* ret : PrtCl modified
;* kill: bp, flags
;* note: PrtCl is rounded down to 4 pixel steps (effectively 80 columns).
;*       No checks are made for PrtLn and PrtCl being off screen.
;*       Optimized for speed (inline code).
;*       ForeCol and BackCol are used as words.

TAN_PrtC2	PROC	FAR

		push	ax
		push	bx
		push	cx
		push	si
		push	di
		push	es

		sub	al,' '		;character set starts with space
		xor	ah,ah
		mov	si,ax
		shl	ax,1
		shl	ax,1
		add	si,ax		;si = char * 5
		add	si,CharSetPtr2	;si -> char pattern data

		mov	bl,BYTE PTR PrtLn
		mov	cx,PrtCl
		and	cx,0fffch
		call	TAN_CalcAddr 	;di -> screen

		mov	ax,WorkScrPtr
		mov	es,ax		

		mov	bp,TAN_LINEADD

		mov	al,PrintOver
		test	al,al		;print over?
		jnz	TAN_PrtC2Over	;yes ->
		jmp	TAN_PrtC2Norm	;no ->

;* inline print

TAN_PrtC2Over:	REPT	5

		lodsb			;al = char pattern data
		
		and	ax,00fh
		shl	ax,1	   	;*2 for word index
		mov	bx,ax
		mov	ax,DupTable[bx]
  
		not	ax
		and	es:[di],ax  	;clear pixels
		not	ax		
		and	ax,WORD PTR ForeCol	;get foreground pixels
		or	es:[di],ax	;set pixels

		add	di,bp		;next line

		ENDM

		jmp	TAN_PrtC2Com

;* inline print

TAN_PrtC2Norm:	REPT	5

		lodsb			;al = char pattern data
		
		and	ax,00fh
		shl	ax,1	   	;*2 for word index
		mov	bx,ax
		mov	ax,DupTable[bx]
		mov	bx,ax
		
		and	ax,WORD PTR ForeCol	;get foreground pixels
		not	bx
		and	bx,WORD PTR BackCol	;get background pixels
		or	ax,bx

		mov	es:[di],ax	;set pixels

		add	di,bp		;next line

		ENDM

TAN_PrtC2Com:	add	PrtCl,4		;next column

		pop	es
		pop	di
		pop	si
		pop	cx
		pop	bx
		pop	ax

		ret

TAN_PrtC2	ENDP

;----------------------------------------------------------------------------

;* TAN_PrtC3 - print character type 3 (5 by 9)
;*
;* pass: al = ASCII code
;*       PrtLn
;*       PrtCl
;*       ForeCol
;*       BackCol
;*       PrintOver
;*       CharSetPtr3
;* ret : PrtCl modified
;* kill: bp, flags
;* note: PrtCl is rounded down to 2 pixel steps.
;*       No checks are made for PrtLn and PrtCl being off screen.
;*       ForeCol and BackCol are used as words.

TAN_PrtC3	PROC	FAR

		push	ax
		push	bx
		push	cx
		push	dx
		push	si
		push	di
		push	es

		sub	al,' '		;character set starts with space
		xor	ah,ah
		mov	si,ax
		shl	ax,1
		shl	ax,1
		shl	ax,1
		add	si,ax		;si = char * 9
		add	si,CharSetPtr3	;si -> char pattern data

		mov	bl,BYTE PTR PrtLn
		mov	cx,PrtCl
		call	TAN_CalcAddr 	;di -> screen

		mov	ax,WorkScrPtr
		mov	es,ax		

		mov	cx,9

;* main print loop

PrtC3Loop:	lodsb			;al = char pattern data
		
;* expand pattern data, ie. 0aah -> 0f0f0f0f0h (4 bits / pixel)

		mov	bl,al
		and	bx,0000fh
		shl	bx,1
		mov	dx,DupTable[bx]

		shr	al,1
		shr	al,1
		shr	al,1
		mov	bl,al
		and	bx,0001eh
		mov	ax,DupTable[bx]

;* ax, dx = expanded data

		xchg	ax,dx

		mov	bx,ax
		mov	bp,dx

		not	bx		;get background masks
		not	bp

		and	ax,WORD PTR ForeCol	;get foreground pixels
		and	dx,WORD PTR ForeCol

		test	PrintOver,1 	;print 'over' mode?
		jnz	PrtC3Over	;yes ->

		and	bx,WORD PTR BackCol	;get background pixels
		and	bp,WORD PTR BackCol	

		or	ax,bx		;merge foreground / background
		or	dx,bp
		
		xor	bx,bx		;clear all pixels
		xor	bp,bp

PrtC3Over:	and	es:[di],bp	;clear pixels
		or	es:[di],dx	;set pixels
	    	and	es:[di+2],bl	;clear pixels
	    	or	es:[di+2],al	;set pixels

		add	di,TAN_LINEADD	;next line
		loop	PrtC3Loop

		add	PrtCl,6		;next column

		pop	es
		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax

		ret

TAN_PrtC3	ENDP

;----------------------------------------------------------------------------

;* TAN_SSprite - shifted sprite
;*
;* pass: si -> logical sprite data (x, y, ptr)
;* ret : cf = 0 = sprite not visible
;*       cf = 1 = sprite visible
;* kill: ax, bx, cx, dx, si, di, bp, flags
;* note: x co-ord is rounded to even pixel

SSpriteOut:	pop	ds
		clc			;exception - sprite not visible
		jmp	SSpriteExit

TAN_SSprite	PROC	FAR

		push	ds
		push	es

;* fetch logical data

		lodsw	
		mov	bp,ax		;x
		lodsw
		mov	di,ax		;y
		lodsw
		mov	si,ax		;ptr

		mov	ax,WorkScrPtr
		mov	es,ax
		mov	ax,SEG SSpriteID
		mov	ds,ax

		ASSUME	DS:SEG SSpriteID

;* fetch ptr to physical data from list

ContBSprite:	mov	ax,[si]
		mov	si,ax

;* fetch physical data

		lodsw
		mov	cx,ax		;width (bytes)
		lodsw
		mov	dx,ax		;depth

		add	si,2		;skip size

		lodsw	
		add	bp,ax		;x offset
		lodsw
		add	di,ax		;y offset

		add	si,6		;si -> mask pattern data

		sar	bp,1		;x byte offset

;* cx = width (bytes)
;* dx = depth
;* bp = x byte offset
;* di = y
;*
;* ds:si -> sprite mask / pattern data

;* test if sprite is visible

		push	ds
		mov	ax,SEG ClipXMin
		mov	ds,ax

		ASSUME	DS:SEG ClipXMin

		mov	ax,di		;y
		cmp	ax,ClipYMax	;y <= y max?
		jg	SSpriteOut	;no ->

		add	ax,dx		;y + depth
		dec	ax		;y + depth - 1
		cmp	ax,ClipYMin	;(y + depth - 1) >= y min?
		jl	SSpriteOut	;no ->

		mov	ax,bp		;x
		cmp	ax,ClipXMax	;x <= x max?
		jg	SSpriteOut	;no ->

		add	ax,cx		;x + width
		dec	ax		;x + width - 1
		cmp	ax,ClipXMin	;(x + width - 1) >= x min?
		jl	SSpriteOut	;no ->

;* if above - reduce depth and modify ptr

AboveClip:	mov	ax,ClipYMin	
		cmp	di,ax		;y < y min?
		jge	BelowClip	;no ->
		mov	bx,ax		;y min
		xchg	ax,di		;di = y = y min, ax = original y
		sub	bx,ax		;y min - y
		sub	dx,bx		;depth = depth - (y min - y)
		mov	ax,cx		;width
		xchg	bx,dx		;preserve depth
		mul	dx		;(y min - y) * width
		xchg	bx,dx		;restore depth
		shl	ax,1		;*2 for mask and pattern data
		add	si,ax		;ptr = ptr + (y min - y) * width * 2

;* if below - reduce depth

BelowClip:	mov	ax,di		;y
		add	ax,dx		;y + depth
		dec 	ax		;y + depth - 1
		cmp	ax,ClipYMax	;(y + depth - 1) > y max
		jle	LeftClip	;no ->
		sub	ax,ClipYMax	;y + depth - 1 - y max
		sub	dx,ax		;depth = depth - (y+depth-1-y max)

;* if left - reduce width, modify ptr and calc add on

LeftClip:	xor	bx,bx		;add on = 0
		mov	ax,ClipXMin	
		cmp	bp,ax		;x < x min?
		jge	RightClip	;no ->
		mov	bx,ax		;x min
		xchg	ax,bp		;bp = x = x min, ax = original x
		sub	bx,ax		;x min - x
		sub	cx,bx		;width = width - (x min - x)
		shl	bx,1		;*2 for mask and pattern data
		add	si,bx		;ptr = ptr + (x min - x) * 2

;* if right - reduce width, modfiy add on

RightClip:	mov	ax,bp		;x
		add	ax,cx		;x + width
		dec	ax		;x + width - 1
		cmp	ax,ClipXMax	;(x + width - 1) > x max?
		jle	ClipDone	;no ->
		sub	ax,ClipXMax	;x + width - 1 - x max
		sub	cx,ax		;width = width - (x+width-1-x max)
		shl	ax,1		;*2 for mask and pattern data
		add	bx,ax		;modify add on

ClipDone:	pop	ds

;* bx = sprite data add on
;* cx = width (bytes)
;* dx = depth
;* bp = x byte offset
;* di = y
;*
;* ds:si -> sprite mask / pattern data

ContMSprite:	shl	di,1		;*2
		shl	di,1		;*4
		shl	di,1		;*8
		shl	di,1		;*16
		mov	ax,di
		shl	di,1		;*32
		shl	di,1		;*64
		add	di,ax		;*80
		shl	di,1		;y * 160
		add	di,bp		;y * 160 + x byte offset

		mov	bp,TAN_LINEADD
		sub	bp,cx		;screen add on

;* calc computed jump for width

		mov	ax,TAN_LINEADD
		sub	ax,cx
		mov	cx,ax
		shl	ax,1		;*2
		shl	ax,1		;*4
		shl	ax,1		;*8
		sub	ax,cx		;*7
		lea	cx,SSpriteBytes
		add	cx,ax		;cx = computed jump wrt width
		
;* bx = sprite data add on
;* cx = width (computed jump)
;* dx = depth
;* bp = screen address add on
;*
;* ds:si -> sprite mask / pattern data
;* es:di -> screen

SSpriteLoop:	jmp	cx		;jump wrt width
		
;* this macro generates 7 bytes of code each iteration

SSpriteBytes:	REPT	160

		lodsw			;al = mask, ah = pattern
		and	al,es:[di]
		or     	al,ah
		stosb
		
		ENDM

		add	si,bx
		add	di,bp
		dec	dx
		jz	SSpriteDone
		jmp	SSpriteLoop
	
SSpriteDone:	stc			;sprite visible

		ASSUME	DS:DATA

SSpriteExit:   	pop	es
		pop	ds
		ret

TAN_SSprite	ENDP

;----------------------------------------------------------------------------

;* TAN_MSprite - masked sprite
;*
;* pass: si -> logical sprite data (x, y, ptr)
;* ret : nothing
;* kill: ax, bx, cx, dx, si, di, bp, flags

TAN_MSprite	PROC	FAR

		push	ds
		push	es

;* fetch logical data

		lodsw	
		mov	bp,ax		;x
		lodsw
		mov	di,ax		;y
		lodsw
		mov	si,ax		;ptr

		mov	ax,WorkScrPtr
		mov	es,ax
		mov	ax,SEG MSpriteID
		mov	ds,ax

		ASSUME	DS:SEG MSpriteID

;* fetch ptr to physical data from list

		mov	ax,[si]
		mov	si,ax

;* fetch physical data

		lodsw
		mov	cx,ax		;width (bytes)
		lodsw
		mov	dx,ax		;depth

		add	si,12		;skip over data not required

		sar	bp,1		;x byte offset

		xor	bx,bx		;add on = 0

		jmp	ContMSprite

		ASSUME	DS:DATA

		ret

TAN_MSprite	ENDP

;----------------------------------------------------------------------------

;* TAN_BSprite -  use MSprite data as SSprite
;*
;* pass: si -> logical sprite data (x, y, ptr)
;* ret : cf = 0 = sprite not visible
;*       cf = 1 = sprite visible
;* kill: ax, bx, cx, dx, si, di, bp, flags
;* note: x co-ord is rounded to byte boundary

TAN_BSprite	PROC	FAR

		push	ds
		push	es

;* fetch logical data

		lodsw	
		mov	bp,ax		;x
		lodsw
		mov	di,ax		;y
		lodsw
		mov	si,ax		;ptr

		mov	ax,WorkScrPtr
		mov	es,ax
		mov	ax,SEG MSpriteID
		mov	ds,ax

		jmp	ContBSprite

TAN_BSprite	ENDP

;----------------------------------------------------------------------------

;* TAN_QSprite - quick sprite
;*
;* pass: si -> logical sprite data (x, y, ptr)
;* ret : nothing
;* kill: ax, bx, cx, dx, si, di, bp, flags

TAN_QSprite	PROC	FAR

		push	ds
		push	es

;* fetch logical data

		lodsw	
		mov	bp,ax		;x
		lodsw
		mov	di,ax		;y
		lodsw
		mov	si,ax		;ptr

		mov	ax,WorkScrPtr
		mov	es,ax
		mov	ax,SEG QSpriteID
		mov	ds,ax

		ASSUME	DS:SEG QSpriteID

;* fetch ptr to physical data from list

		mov	ax,[si]
		mov	si,ax

;* fetch physical data

		lodsw
		mov	bx,ax		;width (bytes)
		lodsw
		mov	dx,ax		;depth

		add	si,4		;skip over data not required

		sar	bp,1		;x byte offset

		shl	di,1		;*2
		shl	di,1		;*4
		shl	di,1		;*8
		shl	di,1		;*16
		mov	ax,di
		shl	di,1		;*32
		shl	di,1		;*64
		add	di,ax		;*80
		shl	di,1		;y * 160
		add	di,bp		;y * 160 + x byte offset

		mov	bp,TAN_LINEADD
		sub	bp,bx		;screen add on

;* bx = width
;* dx = depth
;* bp = screen address add on
;*
;* ds:si -> sprite data
;* es:di -> screen

QSpriteLoop:	mov	cx,bx
		rep	movsb
		add	di,bp
		dec	dx
		jnz	QSpriteLoop

		ASSUME	DS:DATA
		
		pop	es
		pop	ds
		ret

TAN_QSprite	ENDP

;----------------------------------------------------------------------------

;* TAN_InitSS - initialize shifted sprites
;*
;* pass: SSpriteList
;* ret : nothing
;* kill: ax, bx, cx, dx, si, di, bp, flags
;* note: The WorkScreen is used as a buffer.
;*       Refer to SS_TAN_1.ASM for SSprite data formats.

SS_WIDTH	EQU	0
SS_DEPTH	EQU	2
SS_SIZE		EQU	4
SS_XOFF		EQU	6
SS_YOFF		EQU	8
SS_MASK		EQU	10
SS_BASE		EQU	12
SS_OFFSET	EQU	14
SS_DATA		EQU	16

TAN_InitSS 	PROC	FAR

		push	ds
		push	es

	     	xor	bx,bx
InitSSLoop:	mov	ax,SEG SSpriteList
		mov	ds,ax
		mov	es,ax

		ASSUME	DS:SEG SSpriteList

		mov	si,SSpriteList[bx]	
		cmp	si,-1		;end of list?
		jne	InitSSCont	;no ->
		jmp	InitSSExit

InitSSCont:	push	bx

;* seperate mask / pattern data

		mov	al,[si+SS_MASK]	;mask
		mov	cx,[si+SS_SIZE]	;number of bytes
		add	si,SS_DATA	;si -> combined mask / pattern data
		mov	di,si
		add	di,cx		;di -> pattern buffer
		push	cx
		push	si
		call	SeperateData
		pop	si
		pop	cx

;* copy sprite data to buffer (WorkScreen)

		mov	bx,cx
		shl	cx,1		;size * 2
		mov	ax,SEG WorkScreen
		mov	es,ax
		xor	di,di		;es:di -> start of WorkScreen
		mov	bp,si		;save pointer
		rep	movsb		
		
;* interleave mask / pattern data

		mov	ax,SEG WorkScreen
		mov	ds,ax
		xor	si,si		;ds:si -> sprite data in buffer
		mov	ax,SEG SSpriteList
		mov	es,ax
		mov	di,bp		;es:di -> interleaved sprite data dest
		mov	cx,bx		;counter
InterSSLoop1:	mov	al,[si]		;mask
		stosb
		mov	al,[si+bx]	;pattern
		stosb
		inc	si
		loop	InterSSLoop1

		pop	bx
		add	bx,2  		;next sprite
		jmp	InitSSLoop

		ASSUME	DS:DATA
		ASSUME	ES:DATA

InitSSExit:	pop	es
		pop	ds

		ret

TAN_InitSS	ENDP

;----------------------------------------------------------------------------

;* TAN_InitMS - initialize masked sprites
;*
;* pass: MSpriteList
;* ret : nothing
;* kill: ax, bx, cx, dx, si, di, bp, flags
;* note: The WorkScreen is used as a buffer.
;*       Refer to MS_TAN_1.ASM for MSprite data formats.

MS_WIDTH	EQU	0
MS_DEPTH	EQU	2
MS_SIZE		EQU	4
MS_XOFF		EQU	6
MS_YOFF		EQU	8
MS_MASK		EQU	10
MS_BASE		EQU	12
MS_OFFSET	EQU	14
MS_DATA		EQU	16

TAN_InitMS	PROC	FAR

		push	ds
		push	es

	     	xor	bx,bx
InitMSLoop:	mov	ax,SEG MSpriteList
		mov	ds,ax
		mov	es,ax

		ASSUME	DS:SEG MSpriteList

		mov	si,MSpriteList[bx]	
		cmp	si,-1		;end of list?
		jne	InitMSCont	;no ->
		jmp	InitMSExit

InitMSCont:	push	bx

;* seperate mask / pattern data

		mov	al,[si+MS_MASK]	;mask
		mov	cx,[si+MS_SIZE]	;number of bytes
		add	si,MS_DATA	;si -> combined mask / pattern data
		mov	di,si
		add	di,cx		;di -> pattern buffer
		push	cx
		push	si
		call	SeperateData
		pop	si
		pop	cx

;* copy sprite data to buffer (WorkScreen)

		mov	bx,cx
		shl	cx,1		;size * 2
		mov	ax,SEG WorkScreen
		mov	es,ax
		xor	di,di		;es:di -> start of WorkScreen
		mov	bp,si		;save pointer
		rep	movsb		
		
;* interleave mask / pattern data

		mov	ax,SEG WorkScreen
		mov	ds,ax
		xor	si,si		;ds:si -> sprite data in buffer
		mov	ax,SEG MSpriteList
		mov	es,ax
		mov	di,bp		;es:di -> interleaved sprite data dest
		mov	cx,bx		;counter
InterMSLoop1:	mov	al,[si]		;mask
		stosb
		mov	al,[si+bx]	;pattern
		stosb
		inc	si
		loop	InterMSLoop1

		pop	bx
		add	bx,2  		;next sprite
		jmp	InitMSLoop

		ASSUME	DS:DATA
		ASSUME	ES:DATA

InitMSExit:	pop	es
		pop	ds

		ret

TAN_InitMS	ENDP

;----------------------------------------------------------------------------

;* SeperateData - seperate sprite mask / pattern data
;*
;* pass: al = mask colour
;*	 cx = number of bytes
;*       si -> combined mask / pattern data
;*       di -> pattern buffer
;* ret : nothing
;* kill: ax, bx, cx, dx, si, di, flags

SeperateData	PROC	NEAR

		mov	bh,al
		and	bh,0f0h		;hi mask compare
		mov	bl,al
		and	bl,00fh		;lo mask compare

SeperateLoop:	mov	dl,000h		;new mask
		mov	dh,000h		;new pattern
		mov	al,[si]		;fetch pattern / mask
		mov	ah,al
		and	al,0f0h		;consider hi nibble
		cmp	al,bh		;does this match mask colour?
		jne	NotMask1	;no ->
		or	dl,0f0h
		jmp	NotPattern1
NotMask1:	or	dh,al
NotPattern1:	mov	al,ah
		and	al,00fh		;consider lo nibble
		cmp	al,bl		;does this match mask colour?
		jne	NotMask2	;no ->
		or	dl,00fh
		jmp	NotPattern2
NotMask2:	or	dh,al
NotPattern2:	mov	[si],dl		;store mask
		mov	[di],dh		;store pattern
		inc	si
		inc	di
		loop	SeperateLoop
		ret

SeperateData	ENDP

;----------------------------------------------------------------------------

;* TAN_BFill - fast block fill
;*
;* pass: bx = width (1 - 40)
;*       cx = x start (0 - 312 step 8)
;*       dx = depth
;*       di = y start
;*	 FillCol = physical colour
;* ret : nothing
;* kill: assume all

TAN_BFill	PROC	FAR

		push	es
		mov	ax,WorkScrPtr
		mov	es,ax

		mov	ax,WORD PTR FillCol
		test	di,1
		jz	BFillHatchOk
		ror	ax,1		;rotate hatch if start on odd line
		ror	ax,1
		ror	ax,1
		ror	ax,1
BFillHatchOk:	mov	bp,ax

		shl	di,1		;*2
		shl	di,1		;*4
		shl	di,1		;*8
		shl	di,1		;*16
		shl	di,1		;*32
		mov	ax,di
		shl	di,1		;*64
		shl	di,1		;*128
		add	di,ax		;y * 160

		shr	cx,1		;(2 pixels / byte)
		add	di,cx		;y * 160 + x / 2

		mov	ax,bp		;ax = physical colour

		shl	bx,1		;line width (words)

		mov	bp,TAN_LINEADD/2
		sub	bp,bx		;line width (words)-fill width (words)
		shl	bp,1		;bp = line add on

TAN_BFillLoop:	mov	cx,bx		;width (words)
		rep	stosw		;fill line
		ror	ax,1		;rotate hatch
		ror	ax,1
		ror	ax,1
		ror	ax,1
		add	di,bp		;next line
		dec	dx
		jnz	TAN_BFillLoop

		pop	es	
		ret

TAN_BFill	ENDP
	
;----------------------------------------------------------------------------

;* TAN_SaveMouse - save mouse background into MouseHouse[]
;*
;* pass: cx = x co-ord of top lh corner of mouse
;*       bx = y co-ord of top lh corner of mouse
;* ret : MouseHouse[]
;* kill: assume all

TAN_SaveMouse	PROC	FAR

		push	ds
		push	es

		mov	ax,SEG MouseHouse
		mov	es,ax
		mov	ax,WorkScrPtr
		mov	ds,ax

		call	TAN_CalcAddr
		mov	si,di		;ds:si -> mouse background

		mov	di,OFFSET MouseHouse

		mov	bp,16		;16 lines
TAN_SvMseLoop1:	mov	cx,8		;8 bytes wide (16 pixels)
TAN_SvMseLoop2:	cmp	si,TAN_LINEADD*200
		jae	TAN_SvMseExit	;screen ptr outside screen limits ->
		movsb			;copy byte
		loop	TAN_SvMseLoop2	;next byte
		add	si,TAN_LINEADD-8
		dec	bp		;next line
		jnz	TAN_SvMseLoop1

TAN_SvMseExit:	pop	es
		pop	ds
		ret

TAN_SaveMouse	ENDP

;----------------------------------------------------------------------------

;* TAN_LoadMouse - load mouse background from MouseHouse[]
;*
;* pass: cx = x co-ord of top lh corner of mouse
;*       bx = y co-ord of top lh corner of mouse
;* 	 MouseHouse[]
;* ret : nothing
;* kill: assume all

TAN_LoadMouse	PROC	FAR

		push	ds
		push	es

		mov	ax,WorkScrPtr
		mov	es,ax
		mov	ax,SEG MouseHouse
		mov	ds,ax

		call	TAN_CalcAddr	;es:di -> mouse background

		mov	si,OFFSET MouseHouse

		mov	bp,16		;16 lines
TAN_LdMseLoop1:	mov	cx,8		;8 bytes wide (16 pixels)
TAN_LdMseLoop2:	cmp	di,TAN_LINEADD*200
		jae	TAN_LdMseExit	;screen ptr outside screen limits ->
		movsb			;copy byte
		loop	TAN_LdMseLoop2	;next byte
		add	di,TAN_LINEADD-8
		dec	bp		;next line
		jnz	TAN_LdMseLoop1

TAN_LdMseExit:	pop	es
		pop	ds
		ret

TAN_LoadMouse	ENDP

;----------------------------------------------------------------------------

;* TAN_SaveScreen - copy WorkScreen[] to CopyScreen[]
;*
;* pass: WorkScreen[]
;* ret : CopyScreen[]
;* kill: assume all

TAN_SaveScreen	PROC	FAR

		push	ds
		push	es

		mov	ax,SEG CopyScreen
		mov	es,ax
		mov	ax,WorkScrPtr
		mov	ds,ax

		mov	cx,(200*TAN_LINEADD)/2
		mov	si,OFFSET WorkScreen
		mov	di,OFFSET CopyScreen
		rep	movsw

		pop	es
		pop	ds
		ret

TAN_SaveScreen	ENDP
				
;----------------------------------------------------------------------------

;* TAN_LoadScreen - copy CopyScreen[] to WorkScreen[]
;*
;* pass: CopyScreen[]
;* ret : WorkScreen[]
;* kill: assume all

TAN_LoadScreen	PROC	FAR

		push	ds
		push	es

		mov	ax,WorkScrPtr
		mov	es,ax
		mov	ax,SEG CopyScreen
		mov	ds,ax

		mov	cx,(200*TAN_LINEADD)/2
		mov	si,OFFSET CopyScreen
		mov	di,OFFSET WorkScreen
		rep	movsw

		pop	es
		pop	ds
		ret
	
TAN_LoadScreen	ENDP

;----------------------------------------------------------------------------

;* TAN_UncompPic - uncompress picture data
;*
;* pass: CopyScreen[] = compressed picture data
;* ret : WorkScreen[] = uncompressed picture data
;* kill: assume all

TAN_UncompPic	PROC	FAR

		push	ds
		push	es

		mov	ax,WorkScrPtr
		mov	es,ax
		mov	ax,SEG CopyScreen
		mov	ds,ax

		mov	si,OFFSET CopyScreen
		mov	di,OFFSET WorkScreen

		call	RunLenDecode

		pop	es
		pop	ds
		ret

TAN_UncompPic	ENDP

;----------------------------------------------------------------------------

;* TAN_HFill - fill 'Z' section of horizon
;*
;* pass: cx = num lines
;*       si = y min
;*       HrznXMin
;*       HrznXMax
;*       HrznLhsCol
;*       HrznRhsCol
;* ret : nothing
;* kill: assume all
;*
;* note: Use solid colours only - cross hatch not implemented.

TAN_HFill	PROC	FAR

		push	es
		mov	ax,WorkScrPtr
		mov	es,ax

		shl	si,1		;*2 LhsX[] index
		
		mov	di,si
		shl	di,1		;*4
		shl	di,1		;*8
		shl	di,1		;*16
		shl	di,1		;*32
		mov	ax,di
		shl	di,1		;*64
		shl	di,1		;*128
		add	di,ax		;y * 160

		mov	ax,HrznXMin
		shr	ax,1		;/2
		add	di,ax		;y * 160 + x min / 2

		add	si,OFFSET LhsX	;si -> LhsX[y min]

;* cx = num lines
;* si -> LhsX[y min]
;* di -> screen
 
TAN_HFillLp:	push	cx
		push	di

		lodsw			;fetch x value
		mov	dx,ax		;store x value

		sub	ax,HrznXMin	;x - x min
		shr	ax,1		;/2
		shr	ax,1		;(x - x min) / 4
		mov	cx,ax		;cx = num whole words to fill

		mov	ax,WORD PTR HrznLhsCol
		rep	stosw	  	;fill solid lhs

		mov	bp,ax

		mov	ax,dx
		and	ax,3		;x offset within screen word
		mov	bx,ax
		shl	bx,1		;*2 word index
		mov	ax,HrznMask[bx]	;fetch mask wrt x offset
		
		and	bp,ax		;bp = lhs pixels
		not	ax		;invert mask
		mov	bx,ax
		mov	ax,WORD PTR HrznRhsCol
		and	ax,bx		;ax = rhs pixels
		or	ax,bp  		;ax = lhs pixels / rhs pixels
		
		stosw 			;fill middle word

		mov	ax,HrznXMax
		sub	ax,dx		;x max - x
		shr	ax,1		;/2
		shr	ax,1		;(x max - x) / 4
		mov	cx,ax		;cx = num whole words to fill

		mov	ax,WORD PTR HrznRhsCol
		rep	stosw	  	;fill solid rhs

		pop	di
		pop	cx
		add	di,TAN_LINEADD
		loop	TAN_HFillLp

		pop	es	
		ret

TAN_HFill	ENDP

GCODE		ENDS

;============================================================================

		END

