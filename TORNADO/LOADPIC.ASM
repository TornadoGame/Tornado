;****************************************************************************
;*
;* LOADPIC.ASM
;*
;* Display digitized pictures.
;*
;* 02.10.1992 - KJB
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	LoadPicture

		EXTRN	FadeOut:FAR
		EXTRN	QFadeOut:FAR
		EXTRN	FadeIn:FAR
		EXTRN	QFadeIn:FAR
		EXTRN	InstantFadeOut:FAR
		EXTRN	InstantFadeIn:FAR
		EXTRN	Cls:FAR
		EXTRN	DownLoad:FAR
		EXTRN	LoadFile:FAR
		EXTRN	UnpackDeltaPic:FAR
		EXTRN	SwapPalettes:FAR
		EXTRN	ReadMouse:FAR

		EXTRN	CountDown:WORD

		EXTRN	WorkScreen:BYTE
		EXTRN	Key:BYTE
		EXTRN	DieFlag:BYTE

;============================================================================

		INCLUDE	MAINDATA.INC

		INCLUDE	\VISUAL\PALETTES.INC

		INCLUDE	\LIB8086\KEYS.INC
		INCLUDE	\LIB8086\USEFUL.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

FadeFlag	DB	0

		EVEN

DATA		ENDS

;============================================================================

PICCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:PICCODE
		ASSUME DS:DATA

;* LoadPicture
;*
;* pass: dx -> ASCIIZ file name
;*       cx = timeout (secs * 100)
;*	 al = 0 = regular fades
;*	 al = 1 = rapid fades
;* ret : cf = 0 = ok
;*       cf = 1 = load error
;*	 DieFlag
;* kill: assume all (except cf)

LoadPicture	PROC	FAR

		mov	FadeFlag,al

;-----------------------
;* clear screen to black
;-----------------------

		push	cx
		push	dx

		mov	al,COL_BLACK
		call	Cls
		call	DownLoad

		call	InstantFadeOut

		pop	dx

;------------------------------
;* load and unpack picture file
;------------------------------

		push	es

		mov	ax,SEG WorkScreen
		mov	es,ax
		mov	di,OFFSET WorkScreen

		mov	cx,64000

		call	LoadFile

		pop	es

		_JC	LoadError	;cf = 1 = load error ->

		call	UnpackDeltaPic

;---------------
;* swap palettes (load picture palette, save regular palette)
;---------------

		push	es
		mov	ax,SEG WorkScreen
		mov	es,ax
		mov	di,OFFSET WorkScreen
		call	SwapPalettes
		pop	es

;-----------------
;* fade in picture
;-----------------

		test	FadeFlag,1	;rapid fade?
		jnz	@F		;yes ->

		call	FadeIn

		jmp	FadeInOk	

@@:		call	QFadeIn

;------------------------------
;* wait for response or timeout
;------------------------------

FadeInOk:	pop	cx

		mov	CountDown,cx	;set timeout

WaitLoop:	mov	al,Key[K_CTRL]
		and	al,Key[K_Q]	;quit?
		jnz	SortQuit	;yes ->

		mov	al,Key[K_SPACE]
		or	al,Key[K_ENTER]
		or	al,Key[K_ESC]	;continue key pressed?
		jnz	WaitNoMore	;yes ->

		call	ReadMouse
		or	al,ah		;mouse button pressed?
		jnz	WaitNoMore	;yes ->

		cmp	CountDown,0	;timeout?
		jne	WaitLoop	;no ->

		jmp	WaitNoMore

SortQuit:	mov	DieFlag,DIE_QUIT

;------------------
;* fade out picture
;------------------

WaitNoMore:	test	FadeFlag,1	;rapid fade?
		jnz	@F		;yes ->

		call	FadeOut

		jmp	FadeOutOk

@@:		call	QFadeOut

;---------------
;* swap palettes (load regular palette, save picture palette)
;---------------

FadeOutOk:   	push	es
		mov	ax,SEG WorkScreen
		mov	es,ax
		mov	di,OFFSET WorkScreen
		call	SwapPalettes
		pop	es

		mov	al,COL_BLACK
		call	Cls
		call	DownLoad

		call	InstantFadeIn	;clear fade

		clc			;cf = 0 = ok

		ret

LoadError:	pop	cx		;clean up stack

		mov	DieFlag,SYS_ERR_LD_PIC

		ret

LoadPicture	ENDP

PICCODE		ENDS

;============================================================================

		END

