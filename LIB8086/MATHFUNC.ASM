;****************************************************************************
;*
;* MATHFUNC.ASM
;*
;* Miscellaneous maths functions.
;*
;* 15.05.1991 - KJB
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	CalcDeltaTime
		PUBLIC	CalcDeltaXY
		PUBLIC	Sqrt
		PUBLIC	Sqrt32

		PUBLIC	DeltaTime

		EXTRN	LastFrame:WORD
		EXTRN	SinTable:WORD
		EXTRN	CosTable:WORD
		EXTRN	OctTrigTable:WORD
		EXTRN	OctSignTable:WORD

;============================================================================

		INCLUDE	USEFUL.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

DeltaTime	DW	 3277		;frame rate adjust value

;* delta table (look up delta time wrt frame rate)

DeltaTable	DW	 0 		;  0/100th
		DW	 328 		;  1/100th
		DW	 655 		;  2/100th
		DW	 983 		;  3/100th
		DW	 1311 		;  4/100th
		DW	 1638 		;  5/100th
		DW	 1966 		;  6/100th
		DW	 2294 		;  7/100th
		DW	 2621 		;  8/100th
		DW	 2949 		;  9/100th
		DW	 3277 		; 10/100th
		DW	 3604 		; 11/100th
		DW	 3932 		; 12/100th
		DW	 4260 		; 13/100th
		DW	 4587 		; 14/100th
		DW	 4915 		; 15/100th
		DW	 5243 		; 16/100th
		DW	 5570 		; 17/100th
		DW	 5898 		; 18/100th
		DW	 6226 		; 19/100th
		DW	 6553 		; 20/100th
		DW	 6881 		; 21/100th
		DW	 7209 		; 22/100th
		DW	 7536 		; 23/100th
		DW	 7864 		; 24/100th
		DW	 8192 		; 25/100th
		DW	 8519 		; 26/100th
		DW	 8847 		; 27/100th
		DW	 9175 		; 28/100th
		DW	 9502 		; 29/100th
		DW	 9830 		; 30/100th
		DW	 10158 		; 31/100th
		DW	 10485 		; 32/100th
		DW	 10813 		; 33/100th
		DW	 11141 		; 34/100th
		DW	 11468 		; 35/100th
		DW	 11796 		; 36/100th
		DW	 12124 		; 37/100th
		DW	 12451 		; 38/100th
		DW	 12779 		; 39/100th
		DW	 13107 		; 40/100th
		DW	 13434 		; 41/100th
		DW	 13762 		; 42/100th
		DW	 14090 		; 43/100th
		DW	 14417 		; 44/100th
		DW	 14745 		; 45/100th
		DW	 15073 		; 46/100th
		DW	 15400 		; 47/100th
		DW	 15728 		; 48/100th
		DW	 16056 		; 49/100th
		DW	 16384 		; 50/100th
		DW	 16711 		; 51/100th
		DW	 17039 		; 52/100th
		DW	 17367 		; 53/100th
		DW	 17694 		; 54/100th
		DW	 18022 		; 55/100th
		DW	 18350 		; 56/100th
		DW	 18677 		; 57/100th
		DW	 19005 		; 58/100th
		DW	 19333 		; 59/100th
		DW	 19660 		; 60/100th
		DW	 19988 		; 61/100th
		DW	 20316 		; 62/100th
		DW	 20643 		; 63/100th
		DW	 20971 		; 64/100th
		DW	 21299 		; 65/100th
		DW	 21626 		; 66/100th
		DW	 21954 		; 67/100th
		DW	 22282 		; 68/100th
		DW	 22609 		; 69/100th
		DW	 22937 		; 70/100th
		DW	 23265 		; 71/100th
		DW	 23592 		; 72/100th
		DW	 23920 		; 73/100th
		DW	 24248 		; 74/100th
		DW	 24575 		; 75/100th
		DW	 24903 		; 76/100th
		DW	 25231 		; 77/100th
		DW	 25558 		; 78/100th
		DW	 25886 		; 79/100th
		DW	 26214 		; 80/100th
		DW	 26541 		; 81/100th
		DW	 26869 		; 82/100th
		DW	 27197 		; 83/100th
		DW	 27524 		; 84/100th
		DW	 27852 		; 85/100th
		DW	 28180 		; 86/100th
		DW	 28507 		; 87/100th
		DW	 28835 		; 88/100th
		DW	 29163 		; 89/100th
		DW	 29490 		; 90/100th
		DW	 29818 		; 91/100th
		DW	 30146 		; 92/100th
		DW	 30473 		; 93/100th
		DW	 30801 		; 94/100th
		DW	 31129 		; 95/100th
		DW	 31456 		; 96/100th
		DW	 31784 		; 97/100th
		DW	 32112 		; 98/100th
		DW	 32439 		; 99/100th
		DW	 32767 		;100/100th

DATA		ENDS

;============================================================================

LIBCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:LIBCODE
		ASSUME DS:DATA

;* CalcDeltaTime - look up delta time wrt frame rate
;*
;* pass: LastFrame
;* ret : DeltaTime
;* kill: ax, bx, flags

CalcDeltaTime	PROC	FAR

;* check LastFrame <= max time

		mov	ax,LastFrame
		cmp	ax,100
		jbe	TimeOk
		mov	ax,100
		mov	LastFrame,ax

;* look up DeltaTime wrt LastFrame

TimeOk:		mov	bx,ax
		shl	bx,1		;*2 word index
		mov	ax,DeltaTable[bx]
		mov	DeltaTime,ax

		ret

CalcDeltaTime	ENDP

;---------------------------------------------------------------------------

;* CalcDeltaXY - calc delta x = trig(theta) * factor
;*               calc delta y = trig(theta) * factor
;*
;* pass: ax = theta = 0 .. 511 pseudo degrees
;*       dx = factor
;* ret : bx = delta y
;*       cx = delta x
;* kill: ax, dx, si, di, bp, flags

CalcDeltaXY	PROC	FAR

		mov	bp,dx		;store factor

		shl	ax,1		;0 .. 511 * 2
		
		mov	bl,al		;bl = 0 .. 127 * 2 (within quadrant)

		shl	ax,1		;ah = octant (0 .. 7)
		xchg	al,ah
		and	ax,0111b
		shl	ax,1		;*2
		shl	ax,1		;*4
		mov	di,ax		;di = octant trig / sign table index

		mov	al,bl
		ABSV	al   		;neg angle if 64 .. 127 * 2
		mov	bl,al
		xor	bh,bh		;bx = sin / cos table index

		mov	si,OctTrigTable[di]
		mov	ax,[si+bx]	;ax = trig(theta)
		imul	bp
		FRACADJ	cx		;cx = trig(theta) * factor

		mov	ax,OctSignTable[di]
		xor	cx,ax		;restore sign
		sub	cx,ax		;cx = delta x

		mov	si,OctTrigTable[di+2]
		mov	ax,[si+bx]	;ax = trig(theta)
		imul	bp
		FRACADJ	bx		;bx = trig(theta) * factor

		mov	ax,OctSignTable[di+2]
		xor	bx,ax		;restore sign
		sub	bx,ax		;bx = delta y

		ret

CalcDeltaXY	ENDP

;----------------------------------------------------------------------------

;* Sqrt - square root function
;*
;* pass: ax = n (unsigned)
;* ret : ax = sqrt(n)
;* kill: bx, dx, bp, flags

;* if n <> 0 then
;*    mask = 1100000000000000b
;*    approx = 10000000b
;*    while not (num and mask)
;*       mask >> 2
;*       approx >> 1
;*    end
;*    root = approx
;*    while (approx >> 1)
;*       root = root + approx
;*       test = root ^ 2
;*       if test = n then
;*          return(root)
;*       else
;*          if test > n then
;*             root = root - approx
;*          end
;*       end
;*    end
;*    return(root)
;* else
;*    return(0)
;* end

Sqrt		PROC	FAR

		test	ax,ax		;zero?
		jz	SqrtExit	;yes ->

		mov	bp,ax		;bp = n
		mov	dx,0c000h	;dx = mask
		mov	bx,080h		;bx = approx

@@:		test	ax,dx		;while not (num and mask)
		jnz	@F

		shr	dx,1		;mask >> 2
		shr	dx,1
		shr	bx,1		;approx >> 1

		jmp	@B

@@:		mov	dx,bx		;root = approx

@@:		shr	bx,1		;while (approx >> 1)
		jc	@F

		add	dx,bx		;root = root + approx

		mov	al,dl
		mul	al		;test = root ^ 2

		cmp	ax,bp
		je	@F		;test = n ->
		jb	@B		;test < n ->

		sub	dx,bx		;root = root - approx

		jmp	@B

@@:		mov	ax,dx		;return root

SqrtExit:	ret

Sqrt		ENDP

;----------------------------------------------------------------------------

;* Sqrt32 - 32-bit square root function
;*
;* pass: dx, ax = n (unsigned)
;* ret : ax = sqrt(n)
;* kill: bx, cx, dx, si, di, flags

Sqrt32		PROC	FAR

		test	dx,dx		;zero?
		jnz	@F		;no ->
		test	ax,ax
		jz	Sqrt32Exit	;yes ->

@@:		mov	cx,dx		;cx, bx = n
		mov	bx,ax
		mov	dx,0c000h	;dx, ax = mask
		xor	ax,ax
		mov	di,08000h 	;di = approx

Sqrt32Loop1:	test	cx,dx		;while not (num and mask)
		jnz	@F
		test	bx,ax
		jnz	@F

		REPT	2		;mask >> 2
		shr	dx,1
		rcr	ax,1
		ENDM

		shr	di,1		;approx >> 1

		jmp	Sqrt32Loop1

@@:		mov	si,di		;root = approx

Sqrt32Loop2: 	shr	di,1		;while (approx >> 1)
		jc	Sqrt32Result

		add	si,di		;root = root + approx

		mov	ax,si
		mul	ax		;test = root ^ 2

		cmp	dx,cx
		jb	Sqrt32Loop2	;test < n ->
		ja	@F		;test > n ->
		cmp	ax,bx
		jb	Sqrt32Loop2	;test < n ->
		je	Sqrt32Result	;test = n ->

@@:		sub	si,di		;root = root - approx

		jmp	Sqrt32Loop2

Sqrt32Result:	mov	ax,si		;return root

Sqrt32Exit:	ret

Sqrt32		ENDP

LIBCODE		ENDS

;============================================================================

		END

