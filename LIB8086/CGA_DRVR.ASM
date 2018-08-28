;****************************************************************************
;*
;* CGA_DRVR.ASM
;*
;* Screen dependant routines for Colour Graphics Adapter.
;*
;* 28.04.1989 - KJB
;* 29.08.1991 - KJB - CGA_PrtC3 added.
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	CGA_VMode
		PUBLIC	CGA_DLoad
		PUBLIC	CGA_SetPx
		PUBLIC	CGA_Line
		PUBLIC	CGA_VLine
		PUBLIC	CGA_HLine
		PUBLIC	CGA_PFill
		PUBLIC	CGA_MFill
		PUBLIC	CGA_SFill
		PUBLIC	CGA_PrtC1
		PUBLIC	CGA_PrtC2
		PUBLIC	CGA_PrtC3
		PUBLIC	CGA_SSprite
		PUBLIC	CGA_MSprite
		PUBLIC	CGA_BSprite
		PUBLIC	CGA_QSprite
		PUBLIC	CGA_InitSS
		PUBLIC	CGA_InitMS
		PUBLIC	CGA_BFill
		PUBLIC	CGA_SaveMouse
		PUBLIC	CGA_LoadMouse
		PUBLIC	CGA_SaveScreen
		PUBLIC	CGA_LoadScreen
		PUBLIC	CGA_UncompPic
		PUBLIC	CGA_HFill

		PUBLIC	CGA_CalcAddr

		PUBLIC	CGA_LINEADD

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

CGA_REAL_SCR	EQU	0b800h		;CGA segment ptr

CGA_LINEADD	EQU	80		;80 bytes / line

ColMask		DB     	11000000b
		DB	00110000b
		DB	00001100b
		DB	00000011b

ScrMask		DB 	00111111b
		DB	11001111b
		DB	11110011b
		DB	11111100b

OctTable	DW	Oct2		;Dx > 0, Dy > Dx
		DW	Oct1		;Dx > 0, Dx > Dy
		DW	Oct7		;Dx < 0, Dy > Dx
		DW	Oct8		;Dx < 0, Dx > Dy

LMask		LABEL	WORD
		DB	00000000b,00000000b
		DB	11000000b,00000000b	
		DB	11110000b,00000000b
		DB	11111100b,00000000b	
		DB	11111111b,00000000b
		DB	11111111b,11000000b	
		DB	11111111b,11110000b
		DB	11111111b,11111100b	

RMask		LABEL	WORD
		DB	00111111b,11111111b
		DB	00001111b,11111111b	
		DB	00000011b,11111111b
		DB	00000000b,11111111b	
		DB	00000000b,00111111b
		DB	00000000b,00001111b	
		DB	00000000b,00000011b
		DB	00000000b,00000000b	

MeshMask	DW	0		;mesh fill mask

;* Duplicate bits table (example: 1010 -> 11001100)

DupTable	DB	00000000b	
		DB	00000011b
		DB	00001100b
		DB	00001111b
		DB	00110000b
		DB	00110011b
		DB	00111100b
		DB	00111111b
		DB	11000000b
		DB	11000011b
		DB	11001100b
		DB	11001111b
		DB	11110000b
		DB	11110011b
		DB	11111100b
		DB	11111111b

;* horizon fill masks

HrznMask	LABEL	WORD
		DB	00000000b,00000000b
		DB	11000000b,00000000b
		DB	11110000b,00000000b
		DB	11111100b,00000000b
		DB	11111111b,00000000b
		DB	11111111b,11000000b
		DB	11111111b,11110000b
		DB	11111111b,11111100b

DATA		ENDS

;============================================================================

WSDATA		SEGMENT PARA PUBLIC 'DATA'

WSDATA		ENDS

;============================================================================

GCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:GCODE
		ASSUME DS:DATA

;* CGA_VMode - set video mode
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all
;*
;* note: Reset mouse immediately after setting video mode (see MOUSE.ASM).

CGA_VMode	PROC	FAR

		mov	ah,0 		;service 0, set video mode
		mov	al,004h		;320 * 200, 4 colour
		int	010h		;BIOS

		call	ResetMouse

		mov	ax,WSDATA    	;system memory work screen
		mov	WorkScrPtr,ax
		mov	ax,CGA_REAL_SCR
		mov	RealScrPtr,ax

		ret

CGA_VMode	ENDP

;----------------------------------------------------------------------------

;* CGA_DLoad - download work screen to real screen
;*
;* pass: WorkScrPtr
;*       RealScrPtr
;* ret : nothing
;* kill: ax, bx, cx, dx, si, di, bp, flags
;*
;* note: even lines es:00000h
;*       odd lines  es:02000h

CGA_DLoad	PROC	FAR

		push	ds
		push	es

		mov	ax,RealScrPtr	
		mov	es,ax
		mov	ax,WorkScrPtr
		mov	ds,ax

		xor	si,si
		xor	di,di

		mov	ax,100
		mov	bx,02000h-CGA_LINEADD
		mov	dx,02000h
		mov	bp,CGA_LINEADD

CopyLoop:	mov	cx,bp		;copy even line
		rep	movsb
		add	di,bx
		mov	cx,bp		;copy odd line
		rep	movsb		
		sub	di,dx
		dec	ax
		jnz	CopyLoop

		pop	es
		pop	ds
		ret

CGA_DLoad	ENDP

;----------------------------------------------------------------------------

;* CGA_SetPx - set pixel
;*
;* pass: bl = y (0 - 199)
;*       cx = x (0 - 319)
;*       PixelCol
;* ret : nothing
;* kill: ax, si, di, flags

CGA_SetPx	PROC	FAR

		push	es
		mov	ax,WorkScrPtr
		mov	es,ax

		call	CGA_CalcAddr	;es:di -> screen
		mov 	si,cx 
		and 	si,3
		mov 	al,ScrMask[si]	;screen mask
		and	al,es:[di]	;clear out screen pixel
		mov	ah,PixelCol	
		and	ah,ColMask[si]	;colour mask
		or	al,ah
		stosb			;set pixel colour	

		pop	es
		ret

CGA_SetPx	ENDP

;----------------------------------------------------------------------------

;* CGA_Line - draw line between two points
;*
;* pass: cx, bl = x1, y1
;*       dx, bh = x2, y2
;*       LineCol
;* ret : nothing
;* kill: assume all
;*
;* mods: Octant routines corrected (04.01.1991 - KJB).

CGA_Line	PROC	FAR

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
		mov	ax,di
		shl	di,1		;*32
		shl	di,1		;*64
		add	di,ax		;y * 80

		mov	bp,bx
		mov	bx,cx
		and	bx,3
		mov	al,ScrMask[bx]
		mov	ah,ColMask[bx]
		and	ah,LineCol
		mov	bx,bp

		shr	cx,1		;/2
		shr	cx,1		;/4
		add	di,cx

		mov	bp,CGA_LINEADD

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

CGA_Line	ENDP

;----------------------------------------------------------------------------

;* CGA_VLine - draw vertical line between two points
;*
;* pass: bl = y1
;*       bh = y2
;*       cx = x1
;*       LineCol
;* ret : nothing
;* kill: assume all

CGA_VLine	PROC	FAR

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
		mov	ax,di
		shl	di,1		;*32
		shl	di,1		;*64
		add	di,ax		;y * 80

		mov	bx,cx
		and	bx,3
		mov	al,ScrMask[bx]
		mov	ah,ColMask[bx]
		and	ah,LineCol

		shr	cx,1		;/2
		shr	cx,1		;/4
		add	di,cx		;y * 80 + x / 4

		mov	cx,bp
		mov	bp,CGA_LINEADD

VLineLoop:	and	es:[di],al
		or	es:[di],ah
		add	di,bp
		loop	VLineLoop

		pop	es
		ret

CGA_VLine	ENDP

;----------------------------------------------------------------------------

;* CGA_HLine - draw horizontal line between two points
;*
;* pass: bl = y1
;*       cx = x1
;*       dx = x2
;*       LineCol
;* ret : nothing
;* kill: assume all

CGA_HLine	PROC	FAR

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
		mov	ax,di
		shl	di,1		;*32
		shl	di,1		;*64
		add	di,ax		;y * 80

		mov	ax,cx
		shr	ax,1		;/2
		shr	ax,1		;/4
		and	ax,0fffeh	;word boundary
		add	di,ax		;y * 80 + x / 4

		mov	bx,cx
		and	bx,7		;lhs word disp

		mov	si,dx
		and	si,7		;rhs word disp

		sub	cx,dx
		neg	cx
		add	cx,bx		;trim off lh side
		sub	cx,8
		sub	cx,si		;trim off rh side

		shl	bx,1		;*2 for word index
		shl	si,1		;*2 for word index

		sar	cx,1		;8 pixels / word
		sar	cx,1
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

CGA_HLine	ENDP

;----------------------------------------------------------------------------

;* CGA_PFill - fill polygon from table
;*
;* pass: MinY, MaxY
;*       LhsX, RhsX
;*       FillCol
;* ret : nothing
;* kill: ax, bx, cx, dx, di, bp, flags
;* note: FillCol used as word.

CGA_PFill	PROC	FAR

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
HatchOk:	sub	cx,bx
		inc	cx		;cx = number of lines
		shl	bx,1		;bx = x table index
		mov	di,bx
		shl	di,1		;*4
		shl	di,1		;*8
		shl	di,1		;*16
		mov	ax,di
		shl	di,1		;*32
		shl	di,1		;*64
		add	di,ax		;*80

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
		and	bx,7		;lhs word disp

		mov	si,dx
		and	si,7		;rhs word disp

		sub	cx,dx
		ja	FixPoints	;error lh x > rh x ->
PointsFixed:	neg	cx
		add	cx,bx		;trim off lh side
		sub	cx,8
		sub	cx,si		;trim off rh side

		shr	ax,1		;/2
		shr	ax,1		;/4
		and	ax,0fffeh	;word boundary
		add	di,ax		;y + x / 4

		shl	bx,1		;*2 for word index
		shl	si,1		;*2 for word index

		sar	cx,1		;8 pixels / word
		sar	cx,1
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
		add	di,CGA_LINEADD 	;y = y + 1
		ror	bp,1		;rotate hatch
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

CGA_PFill	ENDP

;----------------------------------------------------------------------------

;* CGA_MFill - fill "transparent" polygon from table
;*
;* pass: MinY, MaxY
;*       LhsX, RhsX
;*       FillCol
;* ret : nothing
;* kill: ax, bx, cx, dx, di, bp, flags
;* note: FillCol used as word.

CGA_MFill	PROC	FAR

		push	si
		push	es
		mov	ax,WorkScrPtr
		mov	es,ax

		mov	ax,0cccch	;even mesh mask
		mov	bp,WORD PTR FillCol
		mov	bx,MinY
		mov	cx,MaxY
		test	bx,1
		jz	MeshHatchOk
		ror	bp,1		;rotate hatch if start on odd line
		ror	bp,1
		ror	ax,1		;rotate mesh mask if start on odd line
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
		mov	ax,di
		shl	di,1		;*32
		shl	di,1		;*64
		add	di,ax		;*80

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
		and	bx,7		;lhs word disp

		mov	si,dx
		and	si,7		;rhs word disp

		sub	cx,dx
		ja	FixMeshPts	;error lh x > rh x ->
MeshPtsFixed:	neg	cx
		add	cx,bx		;trim off lh side
		sub	cx,8
		sub	cx,si		;trim off rh side

		shr	ax,1		;/2
		shr	ax,1		;/4
		and	ax,0fffeh	;word boundary
		add	di,ax		;y + x / 4

		shl	bx,1		;*2 for word index
		shl	si,1		;*2 for word index

		sar	cx,1		;8 pixels / word
		sar	cx,1
		sar	cx,1		;cx = number of whole words to fill

		mov	ax,MeshMask	;pick up mesh mask
		mov	dx,ax

		js	ShortMeshLine	;cx < 0 = short line ->

		mov	ax,LMask[bx]	;mask in lh line end
		or	ax,dx		
		mov	bx,ax
		and	ax,es:[di]
		not	bx
		and	bx,bp
		or	ax,bx
		stosw

		mov	ax,CGA_LINEADD/2;words
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
		add	di,CGA_LINEADD 	;y = y + 1
		ror	bp,1		;rotate hatch
		ror	bp,1
		ror	dx,1		;rotate mesh mask
		ror	dx,1
		mov	ax,dx
		mov	MeshMask,ax
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

		REPT	40

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

CGA_MFill	ENDP

;----------------------------------------------------------------------------

;* CGA_SFill - fill "smoke" polygon from table
;*
;* pass: MinY, MaxY
;*       LhsX, RhsX
;*       FillCol
;* ret : nothing
;* kill: ax, bx, cx, dx, di, bp, flags
;* note: FillCol used as word.

CGA_SFill	PROC	FAR

		push	si
		push	es
		mov	ax,WorkScrPtr
		mov	es,ax

		mov	ax,03f3fh	;even mesh mask
		mov	bp,WORD PTR FillCol
		mov	bx,MinY
		mov	cx,MaxY
		test	bx,1
		jz	SmokeHatchOk
		ror	bp,1		;rotate hatch if start on odd line
		ror	bp,1
		ror	bp,1
		ror	bp,1
		ror	ax,1		;rotate mesh mask if start on odd line
		ror	ax,1
		ror	ax,1
		ror	ax,1
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
		mov	ax,di
		shl	di,1		;*32
		shl	di,1		;*64
		add	di,ax		;*80

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
		and	bx,7		;lhs word disp

		mov	si,dx
		and	si,7		;rhs word disp

		sub	cx,dx
		ja	FixSmokePts	;error lh x > rh x ->
SmokePtsFixed:	neg	cx
		add	cx,bx		;trim off lh side
		sub	cx,8
		sub	cx,si		;trim off rh side

		shr	ax,1		;/2
		shr	ax,1		;/4
		and	ax,0fffeh	;word boundary
		add	di,ax		;y + x / 4

		shl	bx,1		;*2 for word index
		shl	si,1		;*2 for word index

		sar	cx,1		;8 pixels / word
		sar	cx,1
		sar	cx,1		;cx = number of whole words to fill

		mov	ax,MeshMask	;pick up mesh mask
		mov	dx,ax

		js	ShortSmokeLine	;cx < 0 = short line ->

		mov	ax,LMask[bx]	;mask in lh line end
		or	ax,dx		
		mov	bx,ax
		and	ax,es:[di]
		not	bx
		and	bx,bp
		or	ax,bx
		stosw

		mov	ax,CGA_LINEADD/2;words
		sub	ax,cx
		shl	ax,1		;*2
		shl	ax,1		;*4
		shl	ax,1		;*8
		lea	cx,FastSmokeFill
		add	cx,ax
		jmp	cx

SmokeEndLoop:	mov	cl,4
		ror	bp,cl		;rotate hatch
		ror	dx,cl		;rotate mesh mask
		pop	di
		pop	cx
		pop	bx
		add	bx,2		;next table index
		add	di,CGA_LINEADD 	;y = y + 1
		mov	ax,dx
		mov	MeshMask,ax
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

		REPT	40

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

CGA_SFill	ENDP

;----------------------------------------------------------------------------

;* CGA_CalcAddr - calculate screen address
;*
;* pass: bl = y (0 - 199)
;*       cx = x (0 - 319)
;* ret : di = screen address = y * 80 + x / 4
;* kill: ax, flags

CGA_CalcAddr	PROC	NEAR

		mov	al,bl
		xor	ah,ah
		shl	ax,1		;*2
		shl	ax,1		;*4
		shl	ax,1		;*8
		shl	ax,1		;*16
		mov	di,ax
		shl	ax,1   		;*32
		shl	ax,1		;*64
		add	di,ax		;*80
		mov	ax,cx
		shr	ax,1		;/2
		shr	ax,1		;/4
		add	di,ax
		ret

CGA_CalcAddr	ENDP

;----------------------------------------------------------------------------

;* CGA_PrtC1 - print character type 1 (7 by 9)
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

CGA_PrtC1	PROC	FAR

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
		call	CGA_CalcAddr 	;di -> screen

		mov	ax,WorkScrPtr
		mov	es,ax		

		mov	bx,offset DupTable

		mov	cx,9

;* main print loop

PrtC1Loop:	lodsb			;al = char pattern data
		
;* expand pattern data, ie. 10010001 -> 1100001100000011 (2 bits / pixel)

		mov	ah,al

;* expand b3 - b0 into high byte

		and	al,00fh
		xlat
		xchg	al,ah

;* expand b7 - b4 into low byte

		shr	al,1
		shr	al,1
		shr	al,1
		shr	al,1
		xlat

		mov	dx,ax
		not	dx		;screen AND mask (assume print 'over')
		mov	bp,dx

		and	ax,WORD PTR ForeCol	;get foreground pixels
		and	bp,WORD PTR BackCol 	;get background pixels

		test	PrintOver,1	;print 'over' mode?
		jnz	PrtC1Over	;yes ->

		xor	dx,dx		;clear all pixels
		or	ax,bp		;merge foreground / background

;* ax = pattern
;* dx = screen AND mask

PrtC1Over:	and	es:[di],dx	;clear pixels
		or	es:[di],ax	;set pixels

		add	di,CGA_LINEADD	;next line
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

CGA_PrtC1	ENDP

;----------------------------------------------------------------------------

;* CGA_PrtC2 - print character type 2 (3 by 5)
;*
;* pass: al = ASCII code
;*       PrtLn
;*       PrtCl
;*       ForeCol
;*       BackCol
;*       PrintOver
;*       CharSetPtr2
;* ret : PrtCl modified
;* kill: bp, flags
;* note: PrtCl is rounded down to 4 pixel steps (effectively 80 columns).
;*       No checks are made for PrtLn and PrtCl being off screen.
;*       Optimized for speed (inline code).

CGA_PrtC2	PROC	FAR

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
		call	CGA_CalcAddr 	;di -> screen

		mov	ax,WorkScrPtr
		mov	es,ax		

		mov	bx,offset DupTable
		mov	bp,CGA_LINEADD

		mov	al,PrintOver
		test	al,al		;print over?
		jz	CGA_PrtC2Norm	;no ->

;* inline print

		REPT	5

		lodsb			;al = char pattern data
		
;* expand pattern data, ie. 1001 -> 11000011 (2 bits / pixel)

		and	al,00fh
		xlat

		mov	ah,al
		not	ah

		and	al,ForeCol	;get foreground pixels

		and	es:[di],ah	;clear pixels
		or	es:[di],al	;set pixels

		add	di,bp		;next line

		ENDM

		jmp	CGA_PrtC2Com

;* inline print

CGA_PrtC2Norm:	REPT	5

		lodsb			;al = char pattern data
		
;* expand pattern data, ie. 1001 -> 11000011 (2 bits / pixel)

		and	al,00fh
		xlat

		mov	ah,al
		not	ah

		and	al,ForeCol	;get foreground pixels
		and	ah,BackCol 	;get background pixels
		or	al,ah		;merge foreground / background

		mov	es:[di],al	;set pixels

		add	di,bp		;next line

		ENDM

CGA_PrtC2Com:	add	PrtCl,4		;next column

		pop	es
		pop	di
		pop	si
		pop	cx
		pop	bx
		pop	ax

		ret

CGA_PrtC2	ENDP

;----------------------------------------------------------------------------

;* CGA_PrtC3 - print character type 3 (5 by 9)
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

CGA_PrtC3	PROC	FAR

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
		call	CGA_CalcAddr 	;di -> screen

		mov	ax,WorkScrPtr
		mov	es,ax		

		mov	bx,offset DupTable

		mov	cx,9

;* bp flags: b0 = 1 = print over
;*           b1 = 1 = 2 pixel offset

		mov	bp,PrtCl
		and	bp,0010b
		or	bp,WORD PTR PrintOver

;* main print loop

PrtC3Loop:	lodsb			;al = char pattern data
    
		test	bp,0010b	;2 pixel offset?
		jz	@F		;no ->
		shr	al,1
		shr	al,1
		
;* expand pattern data, ie. 10010001 -> 1100001100000011 (2 bits / pixel)

@@:		mov	ah,al

;* expand b3 - b0 into high byte

		and	al,00fh
		xlat
		xchg	al,ah

;* expand b7 - b4 into low byte

		shr	al,1
		shr	al,1
		shr	al,1
		shr	al,1
		xlat

		mov	dx,ax
		not	dx		;screen AND mask (assume print 'over')

		and	ax,WORD PTR ForeCol	;get foreground pixels

		test	bp,0001b	;print 'over' mode?
		jnz	PrtC3Over	;yes ->

		and	dx,WORD PTR BackCol 	;get background pixels

		or	ax,dx		;merge foreground / background

;* set AND mask wrt 0 or 2 pixel offset

		mov	dx,0f0ffh	;assume 0 pixel offset
		test	PrtCl,0010b	;2 pixel offset?
		jz	@F		;no ->
		mov	dx,0ff0fh

@@:		and	ax,dx
		not	dx

;* ax = pattern
;* dx = screen AND mask

PrtC3Over:	and	es:[di],dx	;clear pixels
		or	es:[di],ax	;set pixels

		add	di,CGA_LINEADD	;next line
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

CGA_PrtC3	ENDP

;----------------------------------------------------------------------------

;* CGA_SSprite - shifted sprite
;*
;* pass: si -> logical sprite data (x, y, ptr)
;* ret : cf = 0 = sprite not visible
;*       cf = 1 = sprite visible
;* kill: ax, bx, cx, dx, si, di, bp, flags
;* note: x co-ord is rounded to even pixel

SSpriteOut:	pop	ds		
		clc			;exception - sprite not visible
		jmp	SSpriteExit

CGA_SSprite	PROC	FAR

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

		lodsw	
		add	bp,ax		;x offset
		lodsw
		add	di,ax		;y offset

		mov	bx,bp
		and	bx,00002h	;0 or 2 pixel displacement
		mov	ax,[si+bx]
		mov	si,ax		;si -> mask / pattern data

		sar	bp,1
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
		add	di,ax		;y * 80
		add	di,bp		;y * 80 + x byte offset

		mov	bp,CGA_LINEADD
		sub	bp,cx		;screen add on

;* calc computed jump for width

		mov	ax,CGA_LINEADD
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

SSpriteBytes:	REPT	80

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

CGA_SSprite	ENDP

;----------------------------------------------------------------------------

;* CGA_MSprite - masked sprite
;*
;* pass: si -> logical sprite data (x, y, ptr)
;* ret : nothing
;* kill: ax, bx, cx, dx, si, di, bp, flags

CGA_MSprite	PROC	FAR

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

		add	si,8		;skip over x, y offsets and shift ptrs

		sar	bp,1
		sar	bp,1		;x byte offset

		xor	bx,bx		;add on = 0

		jmp	ContMSprite

		ASSUME	DS:DATA

CGA_MSprite	ENDP

;----------------------------------------------------------------------------

;* CGA_BSprite - use MSprite data as SSprite
;*
;* pass: si -> logical sprite data (x, y, ptr)
;* ret : cf = 0 = sprite not visible
;*       cf = 1 = sprite visible
;* kill: ax, bx, cx, dx, si, di, bp, flags
;* note: x co-ord is rounded to byte boundary

CGA_BSprite	PROC	FAR

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

CGA_BSprite	ENDP
	
;----------------------------------------------------------------------------

;* CGA_QSprite - quick sprite
;*
;* pass: si -> logical sprite data (x, y, ptr)
;* ret : nothing
;* kill: ax, bx, cx, dx, si, di, bp, flags

CGA_QSprite	PROC	FAR

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

		sar	bp,1
		sar	bp,1		;x byte offset

		shl	di,1		;*2
		shl	di,1		;*4
		shl	di,1		;*8
		shl	di,1		;*16
		mov	ax,di
		shl	di,1		;*32
		shl	di,1		;*64
		add	di,ax		;y * 80
		add	di,bp		;y * 80 + x byte offset

		mov	bp,CGA_LINEADD
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

CGA_QSprite	ENDP

;----------------------------------------------------------------------------

;* CGA_InitSS - initialize shifted sprites
;*
;* pass: SSpriteList
;* ret : nothing
;* kill: ax, bx, cx, dx, si, di, bp, flags
;* note: The WorkScreen is used as a buffer.
;*       Refer to SS_CGA_1.ASM for SSprite data formats.

SS_WIDTH	EQU	0
SS_DEPTH	EQU	2
SS_XOFF		EQU	4
SS_YOFF		EQU	6
SS_PTR0		EQU	8
SS_PTR2		EQU	10
SS_DATA		EQU	12

CGA_InitSS	PROC	FAR

		push	ds
		push	es

	     	xor	bx,bx
InitSSLoop:	mov	ax,SEG SSpriteList
		mov	ds,ax

		ASSUME	DS:SEG SSpriteList

		mov	si,SSpriteList[bx]	
		cmp	si,-1		;end of list?
		jne	InitSSCont	;no ->
		jmp	InitSSExit

InitSSCont:	push	bx

;* calc size of data (mask and pattern) for one shift

		mov	ax,[si+SS_WIDTH]
		mov	dx,[si+SS_DEPTH]
		mul	dx
		shl	ax,1
		mov	dx,ax		;dx = size of mask pattern data

;* initialize shift 0 and shift 2 pointers

		mov	ax,si
		add	ax,SS_DATA	;ax -> shift 0 data
		mov	[si+SS_PTR0],ax
		add	ax,dx		;ax -> shift 2 data
		mov	[si+SS_PTR2],ax
		
		add	si,SS_DATA	;si -> mask data

;* copy sprite data to buffer (WorkScreen)

		mov	ax,SEG WorkScreen
		mov	es,ax
		xor	di,di		;es:di -> start of WorkScreen
		mov	cx,dx		;counter
		mov	bp,si		;save pointer
		rep	movsb		
		
;* interleave shift 0 data

		mov	ax,SEG WorkScreen
		mov	ds,ax
		xor	si,si		;ds:si -> sprite data in buffer
		mov	ax,SEG SSpriteList
		mov	es,ax
		mov	di,bp		;es:di -> shift 0 data position
		mov	bx,dx
		shr	bx,1		;size / 2
		mov	cx,bx		;counter
InterSSLoop1:	mov	al,[si]		;mask
		stosb
		mov	al,[si+bx]	;pattern
		stosb
		inc	si
		loop	InterSSLoop1

;* invert mask before shifting

		xor	si,si		;ds:si -> sprite data in buffer
		mov	cx,bx		;size / 2
InvMaskLoop1:	not	BYTE PTR [si]
		inc	si
		loop	InvMaskLoop1

;* shift mask / pattern (2 pixels = 4 bits)

		xor	si,si		;ds:si -> sprite data in buffer
		mov	cx,dx		;shift mask and pattern
		xor	bl,bl
ShiftSSLoop:	mov	al,[si]
		xor	ah,ah
		shr	al,1		;shift 1
		rcr	ah,1
		shr	al,1		;shift 2
		rcr	ah,1
		shr	al,1		;shift 3
		rcr	ah,1
		shr	al,1		;shift 4
		rcr	ah,1
		or	al,bl
		mov	[si],al
		inc	si		;next byte
		mov	bl,ah
		loop	ShiftSSLoop

;* invert mask after shifting

		mov	bx,dx
		shr	bx,1		;size / 2

		xor	si,si		;ds:si -> sprite data in buffer
		mov	cx,bx		;size / 2
InvMaskLoop2:	not	BYTE PTR [si]
		inc	si
		loop	InvMaskLoop2

;* interleave shift 2 data

		xor	si,si		;ds:si -> sprite data in buffer
		mov	di,bp		;es:di -> shift 0 data position
		add	di,dx		;es:di -> shift 2 data position
		mov	cx,bx		;counter (size / 2)
InterSSLoop2:	mov	al,[si]		;mask
		stosb
		mov	al,[si+bx]	;pattern
		stosb
		inc	si
		loop	InterSSLoop2

		pop	bx
		add	bx,2  		;next sprite
		jmp	InitSSLoop

		ASSUME	DS:DATA
		ASSUME	ES:DATA

InitSSExit:	pop	es
		pop	ds
		ret

CGA_InitSS	ENDP

;----------------------------------------------------------------------------

;* CGA_InitMS - initialize masked sprites
;*
;* pass: MSpriteList
;* ret : nothing
;* kill: ax, bx, cx, dx, si, di, bp, flags
;* note: The WorkScreen is used as a buffer.
;*       Refer to MS_CGA_1.ASM for MSprite data formats.

MS_WIDTH	EQU	0
MS_DEPTH	EQU	2
MS_XOFF		EQU	4
MS_YOFF		EQU	6
MS_PTR0		EQU	8
MS_PTR2		EQU	10
MS_DATA		EQU	12

CGA_InitMS	PROC	FAR

		push	ds
		push	es

	     	xor	bx,bx
InitMSLoop:	mov	ax,SEG MSpriteList
		mov	ds,ax

		ASSUME	DS:SEG MSpriteList

		mov	si,MSpriteList[bx]	
		cmp	si,-1		;end of list?
		je	InitMSExit	;yes ->

		push	bx

;* calc size of data (mask and pattern)

		mov	ax,[si+MS_WIDTH]
		mov	dx,[si+MS_DEPTH]
		mul	dx
		shl	ax,1
		mov	dx,ax		;dx = size of mask pattern data

;* initialize shift 0 and shift 2 pointers (both point to shift 0 data)

		mov	ax,si
		add	ax,MS_DATA	;ax -> shift 0 data
		mov	[si+MS_PTR0],ax
		mov	[si+MS_PTR2],ax

		add	si,MS_DATA	;si -> mask data

;* copy sprite data to buffer (WorkScreen)

		mov	ax,SEG WorkScreen
		mov	es,ax
		xor	di,di		;es:di -> start of WorkScreen
		mov	cx,dx		;counter
		mov	bp,si		;save pointer
		rep	movsb		
		
;* interleave data

		mov	ax,SEG WorkScreen
		mov	ds,ax
		xor	si,si		;ds:si -> sprite data in buffer
		mov	ax,SEG MSpriteList
		mov	es,ax
		mov	di,bp		;es:di -> shift 0 data position
		mov	bx,dx
		shr	bx,1		;size / 2
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

CGA_InitMS	ENDP

;----------------------------------------------------------------------------

;* CGA_BFill - fast block fill
;*
;* pass: bx = width (1 - 40)
;*       cx = x start (0 - 312 step 8)
;*       dx = depth
;*       di = y start
;*       FillCol = physical colour
;* ret : nothing
;* kill: assume all

CGA_BFill	PROC	FAR

		push	es
		mov	ax,WorkScrPtr
		mov	es,ax

		mov	ax,WORD PTR FillCol
		test	di,1
		jz	BFillHatchOk
		ror	ax,1		;rotate hatch if start on odd line
		ror	ax,1
BFillHatchOk:	mov	bp,ax

		shl	di,1		;*2
		shl	di,1		;*4
		shl	di,1		;*8
		shl	di,1		;*16
		mov	ax,di
		shl	di,1		;*32
		shl	di,1		;*64
		add	di,ax		;y * 80

		shr	cx,1
		shr	cx,1		;(4 pixels / byte)	
		add	di,cx		;y * 80 + x / 4

		mov	ax,bp 		;ax = physical colour

		mov	bp,CGA_LINEADD/2
		sub	bp,bx		;line width (words)-fill width (words)
		shl	bp,1		;bp = line add on

CGA_BFillLoop:	mov	cx,bx		;width (words)
		rep	stosw		;fill line
		ror	ax,1		;rotate hatch
		ror	ax,1
		add	di,bp		;next line
		dec	dx
		jnz	CGA_BFillLoop

		pop	es	
		ret

CGA_BFill	ENDP

;----------------------------------------------------------------------------

;* CGA_SaveMouse - save mouse background into MouseHouse[]
;*
;* pass: cx = x co-ord of top lh corner of mouse
;*       bx = y co-ord of top lh corner of mouse
;* ret : MouseHouse[]
;* kill: assume all

CGA_SaveMouse	PROC	FAR

		push	ds
		push	es

		mov	ax,SEG MouseHouse
		mov	es,ax
		mov	ax,WorkScrPtr
		mov	ds,ax

		call	CGA_CalcAddr
		mov	si,di		;ds:si -> mouse background

		mov	di,OFFSET MouseHouse

		mov	bp,16		;16 lines
CGA_SvMseLoop1:	mov	cx,5		;5 bytes wide (16 pixels + shift byte)
CGA_SvMseLoop2:	cmp	si,CGA_LINEADD*200
		jae	CGA_SvMseExit	;screen ptr outside screen limits ->
		movsb			;copy byte
		loop	CGA_SvMseLoop2	;next byte
		add	si,CGA_LINEADD-5
		dec	bp		;next line
		jnz	CGA_SvMseLoop1

CGA_SvMseExit:	pop	es
		pop	ds
		ret

CGA_SaveMouse	ENDP

;----------------------------------------------------------------------------

;* CGA_LoadMouse - load mouse background from MouseHouse[]
;*
;* pass: cx = x co-ord of top lh corner of mouse
;*       bx = y co-ord of top lh corner of mouse
;* 	 MouseHouse[]
;* ret : nothing
;* kill: assume all

CGA_LoadMouse	PROC	FAR

		push	ds
		push	es

		mov	ax,WorkScrPtr
		mov	es,ax
		mov	ax,SEG MouseHouse
		mov	ds,ax

		call	CGA_CalcAddr	;es:di -> mouse background

		mov	si,OFFSET MouseHouse

		mov	bp,16		;16 lines
CGA_LdMseLoop1:	mov	cx,5		;5 bytes wide (16 pixels + shift byte)
CGA_LdMseLoop2:	cmp	di,CGA_LINEADD*200
		jae	CGA_LdMseExit	;screen ptr outside screen limits ->
		movsb			;copy byte
		loop	CGA_LdMseLoop2	;next byte
		add	di,CGA_LINEADD-5
		dec	bp		;next line
		jnz	CGA_LdMseLoop1

CGA_LdMseExit:	pop	es
		pop	ds
		ret

CGA_LoadMouse	ENDP

;----------------------------------------------------------------------------

;* CGA_SaveScreen - copy WorkScreen[] to CopyScreen[]
;*
;* pass: WorkScreen[]
;* ret : CopyScreen[]
;* kill: assume all

CGA_SaveScreen	PROC	FAR

		push	ds
		push	es

		mov	ax,SEG CopyScreen
		mov	es,ax
		mov	ax,WorkScrPtr
		mov	ds,ax

		mov	cx,(200*CGA_LINEADD)/2
		mov	si,OFFSET WorkScreen
		mov	di,OFFSET CopyScreen
		rep	movsw

		pop	es
		pop	ds
		ret

CGA_SaveScreen	ENDP
				
;----------------------------------------------------------------------------

;* CGA_LoadScreen - copy CopyScreen[] to WorkScreen[]
;*
;* pass: CopyScreen[]
;* ret : WorkScreen[]
;* kill: assume all

CGA_LoadScreen	PROC	FAR

		push	ds
		push	es

		mov	ax,WorkScrPtr
		mov	es,ax
		mov	ax,SEG CopyScreen
		mov	ds,ax

		mov	cx,(200*CGA_LINEADD)/2
		mov	si,OFFSET CopyScreen
		mov	di,OFFSET WorkScreen
		rep	movsw

		pop	es
		pop	ds
		ret
	
CGA_LoadScreen	ENDP

;----------------------------------------------------------------------------

;* CGA_UncompPic - uncompress picture data
;*
;* pass: CopyScreen[] = compressed picture data
;* ret : WorkScreen[] = uncompressed picture data
;* kill: assume all

CGA_UncompPic	PROC	FAR

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

CGA_UncompPic	ENDP

;----------------------------------------------------------------------------

;* CGA_HFill - fill 'Z' section of horizon
;*
;* pass: cx = num lines
;*       si = y min
;*       HrznXMin
;*       HrznXMax
;*       HrznLhsCol
;*       HrznRhsCol
;* ret : nothing
;* kill: assume all

CGA_HFill	PROC	FAR

		push	es
		mov	ax,WorkScrPtr
		mov	es,ax

;* rotate hatch if start on odd line

		test	si,1		;odd line?
		jz	@F		;no ->
		mov	ax,WORD PTR HrznLhsCol
		ror	ax,1
		ror	ax,1
		mov	WORD PTR HrznLhsCol,ax
		mov	ax,WORD PTR HrznRhsCol
		ror	ax,1
		ror	ax,1
		mov	WORD PTR HrznRhsCol,ax

@@:		shl	si,1		;*2 LhsX[] index
		
		mov	di,si
		shl	di,1		;*4
		shl	di,1		;*8
		shl	di,1		;*16
		mov	ax,di
		shl	di,1		;*32
		shl	di,1		;*64
		add	di,ax		;y * 80

		mov	ax,HrznXMin
		shr	ax,1		;/2
		shr	ax,1		;/4
		add	di,ax		;y * 160 + x min / 4

		add	si,OFFSET LhsX	;si -> LhsX[y min]

;* cx = num lines
;* si -> LhsX[y min]
;* di -> screen
 
CGA_HFillLp:	push	cx
		push	di

		lodsw			;fetch x value
		mov	dx,ax		;store x value

		sub	ax,HrznXMin	;x - x min
		shr	ax,1		;/2
		shr	ax,1		;/4
		shr	ax,1		;(x - x min) / 8
		mov	cx,ax		;cx = num whole words to fill

		mov	ax,WORD PTR HrznLhsCol
		rep	stosw	  	;fill solid lhs

		mov	bp,ax

		ror	ax,1		;rotate hatch
		ror	ax,1
		mov	WORD PTR HrznLhsCol,ax

		mov	ax,dx
		and	ax,7		;x offset within screen word
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
		shr	ax,1		;/4
		shr	ax,1		;(x max - x) / 8
		mov	cx,ax		;cx = num whole words to fill

		mov	ax,WORD PTR HrznRhsCol
		rep	stosw	  	;fill solid rhs

		ror	ax,1		;rotate hatch
		ror	ax,1
		mov	WORD PTR HrznRhsCol,ax

		pop	di
		pop	cx
		add	di,CGA_LINEADD
		loop	CGA_HFillLp

		pop	es	
		ret

CGA_HFill	ENDP

GCODE		ENDS

;============================================================================

		END


