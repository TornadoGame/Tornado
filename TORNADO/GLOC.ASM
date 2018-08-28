;****************************************************************************
;*
;* GLOC.ASM
;*
;* Blackout / redout / hypoxia effects etc.
;*
;* 18.09.1992 - KJB
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	UpdateGLOC

		EXTRN	GForce:WORD
		EXTRN	ElePosn:WORD
		EXTRN	ZftHi:WORD
		EXTRN	ZftLo:WORD
		EXTRN	LastFrame:WORD
		EXTRN	FadeStart2:WORD
		EXTRN	FadeCount2:WORD

		EXTRN	FadeLevel2:BYTE
		EXTRN	FadeRCol2:BYTE
		EXTRN	FadeGCol2:BYTE
		EXTRN	FadeBCol2:BYTE
		EXTRN	SSF_Oxygen:BYTE
		EXTRN	DisableInput:BYTE
		EXTRN	DieFlag:BYTE
		EXTRN	InfiniteGForce:BYTE

;============================================================================

		INCLUDE	MAINDATA.INC

		INCLUDE	\LIB8086\USEFUL.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

;----------
;* blackout
;----------

BLKOUT_TIME	EQU	30*100		;secs * 100 (must be >= 127)
BLKOUT_G_LEVEL	EQU	6*16		;g * 16

BlkTimer	DW	0		;secs * 100

;--------
;* redout
;--------

REDOUT_TIME	EQU	30*100		;secs * 100 (must be >= 127)
REDOUT_G_LEVEL	EQU	-2*16		;g * 16

RedTimer	DW	0		;secs * 100

;------
;* GLOC
;------

GLOC_PERIOD	EQU	5*100		;secs * 100

GLOCTimer	DW	0		;secs * 100

;---------
;* hypoxia
;---------

OxyTimer	DW	0		;secs * 100

Curtains	DB	0,0		;1 = blackout and die

CurtainsTimer	DW	0		;secs * 100

DATA		ENDS

;============================================================================

GENCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:GENCODE
		ASSUME DS:DATA

;* UpdateGLOC
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

UpdateGLOC	PROC	FAR

;* if Curtains then sort blackout and die

		test	Curtains,1
		_JNZ	ContCurtains

;* if GLOCTimer <> 0 then sort GLOC

		cmp	GLOCTimer,0
		_JNE	ContGLOC

;* if BlkTimer timer <> 0 then sort blackout

		cmp	BlkTimer,0
		jne	ContBlackout

;* if RedTimer <> 0 then sort redout

		cmp	RedTimer,0
		_JNE	ContRedout

;* if infinite g-force then no blackouts or redouts

		test	InfiniteGForce,1
		jnz	@F

;* if GForce >= BLKOUT_G_LEVEL then sort blackout

		cmp	GForce,BLKOUT_G_LEVEL
		jge	ContBlackout

;* if GForce <= REDOUT_G_LEVEL then sort redout

		cmp	GForce,REDOUT_G_LEVEL
		jle	ContRedout

@@:		jmp	ContHypoxia

;---------------------------
ContBlackout	LABEL	NEAR
;---------------------------

;* if ElePosn <= -8192 then
;*    BlkTimer = max(BlkTimer - LastFrame * 2, 0) ;pushing - rapid recovery
;* else 
;*    if g force < BLKOUT_G_LEVEL
;*       BlkTimer = max(BlkTimer - LastFrame, 0)  ;recovery
;*    else
;*       BlkTimer = min(BlkTimer + LastFrame, BLKOUT_TIME)
;*    endif
;* endif

		mov	dx,LastFrame

		cmp	ElePosn,-8192
		jg	@F

		mov	ax,BlkTimer
		shl	dx,1
		sub	ax,dx
		MINM	ax

		jmp	BlkOk

@@:		cmp	GForce,BLKOUT_G_LEVEL
		jge	@F

		mov	ax,BlkTimer
		sub	ax,dx
		MINM	ax

		jmp	BlkOk

@@:		mov	ax,BlkTimer
		add	ax,dx
		cmp	ax,BLKOUT_TIME
		jbe	BlkOk
		mov	ax,BLKOUT_TIME

		mov	GLOCTimer,GLOC_PERIOD	;blackout

BlkOk:		mov	BlkTimer,ax

;* FadeLevel2 = min(BlkTimer - (BLKOUT_TIME-127), 0)

		sub	ax,BLKOUT_TIME-127

		MINM	ax		;0 .. 127

		mov	FadeLevel2,al

;* set blackout fade RGB values

		test	al,al		;level = 0?
		jz	@F		;yes ->

;* only set if fade level > 0 (prevents palette glitch on slow machines)

		mov	FadeRCol2,0	;red
		mov	FadeGCol2,0	;green
		mov	FadeBCol2,0	;blue

		mov	FadeStart2,0
		mov	FadeCount2,256

@@:		jmp	ContHypoxia

;---------------------------
ContRedout	LABEL	NEAR
;---------------------------

;* if ElePosn >= 8192 then
;*    RedTimer = max(RedTimer - LastFrame * 2, 0) ;pulling - rapid recovery
;* else 
;*    if g force > REDOUT_G_LEVEL
;*       RedTimer = max(RedTimer - LastFrame, 0)  ;recovery
;*    else
;*       RedTimer = min(RedTimer + LastFrame, REDOUT_TIME)
;*    endif
;* endif

		mov	dx,LastFrame

		cmp	ElePosn,8192
		jl	@F

		mov	ax,RedTimer
		shl	dx,1
		sub	ax,dx
		MINM	ax

		jmp	RedOk

@@:		cmp	GForce,REDOUT_G_LEVEL
		jle	@F

		mov	ax,RedTimer
		sub	ax,dx
		MINM	ax

		jmp	RedOk

@@:		mov	ax,RedTimer
		add	ax,dx
		cmp	ax,REDOUT_TIME
		jbe	RedOk
		mov	ax,REDOUT_TIME

		mov	GLOCTimer,GLOC_PERIOD	;redout

RedOk:		mov	RedTimer,ax

;* FadeLevel2 = min(RedTimer - (REDOUT_TIME-127), 0)

		sub	ax,REDOUT_TIME-127

		MINM	ax		;0 .. 127

		mov	FadeLevel2,al

;* set redout fade RGB values

		test	al,al		;level = 0?
		jz	@F		;yes ->

;* only set if fade level > 0 (prevents palette glitch on slow machines)

		mov	FadeRCol2,63	;red
		mov	FadeGCol2,0	;green
		mov	FadeBCol2,0	;blue

		mov	FadeStart2,0
		mov	FadeCount2,256

@@:		jmp	ContHypoxia

;---------------------------
ContGLOC	LABEL	NEAR
;---------------------------

		mov	ax,GLOCTimer
		sub	ax,LastFrame
		jbe	@F		;recover ->

		mov	GLOCTimer,ax

		or	DisableInput,DIP_GLOC

		jmp	ContHypoxia

@@:		mov	GLOCTimer,0

		and	DisableInput,NOT DIP_GLOC

;---------------------------
ContHypoxia	LABEL	NEAR
;---------------------------

;* if oxygen failure and alt > 8,000ft then blackout and die after time (wrt alt)
;*
;* @8,000ft, survive time = 10mins
;* @56,000ft, survive time = 2mins
;*
;* survive time = 56000 - ubound(alt, 8000, 56000) + 12000 = 12000 .. 60000
;*							   = 2mins .. 10mins
;*
;* if oxygen failure then
;*    if alt > 8000ft then
;*       OxyTimer = min(OxyTimer + LastFrame, 65535)
;*       if OxyTimer > survive time then
;*          blackout and die
;*       endif
;*    else
;*       OxyTimer = max(OxyTimer - LastFrame * 4, 0)	;rapid recovery
;*    endif
;* endif

		test	SSF_Oxygen,1	;oxygen system failure?
		_JZ	ExitGLOC	;no ->

		mov	ax,56000	;assume alt > 65,535ft

		cmp	ZftHi,0		;alt > 65,535ft?
		ja	ContOxyFail	;yes ->

		mov	ax,ZftLo

		cmp	ax,8000		;alt > 8,000ft?
		ja    	@F		;yes ->

;* rapid recovery

		mov	ax,OxyTimer

		mov	dx,LastFrame
		REPT	2		;*4 
		shl	dx,1
		ENDM

		sub	ax,dx

		MINM	ax

		mov	OxyTimer,ax

		jmp	ExitGLOC

;* calc survive time

@@:		cmp	ax,56000	;limit to 56,000ft
		jbe	ContOxyFail
		mov	ax,56000

ContOxyFail:  	mov	bp,56000
		sub	bp,ax
		add	bp,12000	;bp = survive time

		mov	ax,OxyTimer
		add	ax,LastFrame
		MAXM	ax
		mov	OxyTimer,ax

;* if OxyTimer > survive time then blackout and die

		cmp	ax,bp
		jbe	ExitGLOC

		mov	Curtains,1

		or	DisableInput,DIP_HYPOXIA

;* set blackout fade RGB values

		mov	FadeRCol2,0	;red
		mov	FadeGCol2,0	;green
		mov	FadeBCol2,0	;blue

		mov	FadeStart2,0
		mov	FadeCount2,256

;---------------------------
ContCurtains	LABEL	NEAR
;---------------------------

		mov	ax,CurtainsTimer
		add	ax,LastFrame
		mov	CurtainsTimer,ax

		cmp	ax,127		;set fade level 0 .. 127
		jbe	@F

		mov	ax,127

		mov	DieFlag,DIE_HYPOXIA

@@:		mov	FadeLevel2,al

ExitGLOC:	ret

UpdateGLOC	ENDP

GENCODE		ENDS

;============================================================================

		END

