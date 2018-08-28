;****************************************************************************
;*
;* RANDOM.ASM
;*
;* Random number generator.
;*
;* 02.05.1989 - KJB
;* 17.08.1992 - KJB - FastRandX / RndTable[] added.
;* 29.10.1992 - KJB - Use "real-time" clock to reseed random number generator.
;*		      The system clock was used previously, but this destroyed
;*	              the midnight signal (potential bug).
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

  		PUBLIC	RandX
		PUBLIC	ReSeed
		PUBLIC	FastRandX

		PUBLIC	SeedLo
		PUBLIC	SeedHi

		PUBLIC	RndIndex
		PUBLIC	RndTable

		EXTRN	Ticker:WORD

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

SeedLo		DW	12431
SeedHi		DW	8765

RndIndex	DB	0,0

RndTable	DB	256 DUP(0)

DATA		ENDS

;============================================================================

LIBCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:LIBCODE
		ASSUME DS:DATA

;* RandX - generate 8-bit random number
;*
;* pass: SeedLo
;*       SeedHi
;* ret : ax = random number (0 .. 255)
;* kill: flags

RandX		PROC	FAR

		push	dx
		mov	ax,SeedLo
		mov	dx,SeedHi	

		test 	dx,dx
		jns 	ZeroBit1
		xor 	ax,0b553h
		xor 	dl,076h
ZeroBit1:	sal 	ax,1
		rcl 	dx,1 

		test 	dx,dx
		jns 	ZeroBit2
		xor 	ax,0b553h
		xor 	dl,076h
ZeroBit2:	sal 	ax,1
		rcl 	dx,1 

		test 	dx,dx
		jns 	ZeroBit3
		xor 	ax,0b553h
		xor 	dl,076h
ZeroBit3:	sal 	ax,1
		rcl 	dx,1 

		test 	dx,dx
		jns 	ZeroBit4
		xor 	ax,0b553h
		xor 	dl,076h
ZeroBit4:	sal 	ax,1
		rcl 	dx,1 

		test 	dx,dx
		jns 	ZeroBit5
		xor 	ax,0b553h
		xor 	dl,076h
ZeroBit5:	sal 	ax,1
		rcl 	dx,1 

		test 	dx,dx
		jns 	ZeroBit6
		xor 	ax,0b553h
		xor 	dl,076h
ZeroBit6:	sal 	ax,1
		rcl 	dx,1 

		test 	dx,dx
		jns 	ZeroBit7
		xor 	ax,0b553h
		xor 	dl,076h
ZeroBit7:	sal 	ax,1
		rcl 	dx,1 

		test 	dx,dx
		jns 	ZeroBit8
		xor 	ax,0b553h
		xor 	dl,076h
ZeroBit8:	sal 	ax,1
		rcl 	dx,1 

		mov 	SeedLo,ax
		mov 	SeedHi,dx
		mov 	al,dh
		xor 	ah,ah
		pop 	dx
		ret		

RandX		ENDP

;----------------------------------------------------------------------------

;* ReSeed - reseed random number generator
;*
;* pass: nothing
;* ret : SeedLo, SeedHi
;* kill: assume all (BIOS routine used)

ReSeed		PROC	FAR

		mov	ah,002h		;get real-time clock time
		int	01ah		;time of day service

;* (note: Ignore real-time clock defective signal.)

		mov	ax,Ticker
		add	ax,cx		;(ch = hours, cl = mins)
		add	ax,dx		;(dh = secs, dl = ?)

		push	ax

		mov	ah,004h		;get real-time clock date
		int	01ah		;time of day service

;* (note: Ignore real-time clock defective signal.)

		pop	ax

		add	ax,cx		;(ch = century, cl = year)
		add	ax,dx		;(dh = month, dl = day)

		jnz	SeedOk		;seed ok if <> 0 ->

		mov	ax,05b7dh	;set seed to arbitrary value

SeedOk:		mov	dx,ax
		not	dx

		mov	SeedHi,dx
		mov	SeedLo,ax

;* refill RndTable

		mov	cx,256
		mov	di,OFFSET RndTable
@@:		call	RandX
		stosb
		loop	@B

;* randomise RndIndex

		call	RandX

		mov	RndIndex,al

		ret

ReSeed		ENDP
	
;----------------------------------------------------------------------------

;* FastRandX - lookup 8-bit random number
;*
;* pass: RndIndex
;* ret : ax = random number (0 .. 255)
;*       RndIndex
;* kill: flags

FastRandX	PROC	FAR

		push	bx

		mov	bx,OFFSET RndTable

		mov	al,RndIndex
		xlat
		xor	ah,ah

		pop	bx

		inc	RndIndex	;next index

		ret

FastRandX	ENDP

LIBCODE		ENDS

;============================================================================

		END

