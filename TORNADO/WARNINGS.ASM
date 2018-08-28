;****************************************************************************
;*
;* WARNINGS.ASM
;*
;* Check for failures and issue warnings.
;*
;* 09.07.1992 - KJB
;*
;* New failures cause the attention getters to flash and the appropriate
;* warning panel lamps to flash. When the attention getters are cancelled
;* (by a key press) the flashing lamps remain on.
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	CheckFailures

		PUBLIC	Attention

		EXTRN	AttentionSound:FAR
		EXTRN	KillAttnSound:FAR

		EXTRN	RedWarnings1:WORD
		EXTRN	RedWarnings2:WORD
		EXTRN	AmbWarnings1:WORD
		EXTRN	AmbWarnings2:WORD
		EXTRN	LastFrame:WORD

		EXTRN	KF_CancelAttn:BYTE
EXTRN   CockpitViews:BYTE
;============================================================================

		INCLUDE	MAINDATA.INC

		INCLUDE	\LIB8086\KEYS.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

Attention	DB	0		;1 = get attention

		EVEN

PrevRedWarn2	DW	0
PrevAmbWarn2	DW	0

FLASH_DELAY	EQU	50		;1/100ths sec

AttnTimer	DW	FLASH_DELAY	;attention timer

DATA		ENDS

;============================================================================

MODCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:MODCODE
		ASSUME DS:DATA

;* CheckFailures
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

CheckFailures	PROC	NEAR

;--------------------------
;* cancel attention getters (if requested)
;--------------------------

		KTEST	KF_CancelAttn	;cancel attention getters?
		jz	@F		;no ->

;* merge new failures with acknowledged failures

		xor	ax,ax
		xchg	ax,RedWarnings2
		and	ax,RED_CANCEL	;cancel non-permanent warnings
		or	RedWarnings1,ax

		xor	ax,ax
		xchg	ax,AmbWarnings2
		and	ax,AMB_CANCEL	;cancel non-permanent warnings
		or	AmbWarnings1,ax

		xor	ax,ax

		mov	Attention,al		;clear lamps

		mov	PrevRedWarn2,ax
		mov	PrevAmbWarn2,ax

		mov	AttnTimer,FLASH_DELAY	;reset delay

		call	KillAttnSound

		jmp	ExitFailures

;---------------------------------
;* update attention flag and timer
;---------------------------------

@@: 		mov	ax,RedWarnings1
		not	ax		;ignore existing failures
		and	ax,RedWarnings2	

		mov	dx,AmbWarnings1
		not	dx		;ignore existing failures
		and	dx,AmbWarnings2	

		or	ax,dx		;any flashing warnings?
		jz	ContFailures	;no ->

		mov	ax,RedWarnings2
		cmp	ax,PrevRedWarn2	;new red warning?
		jne	@F		;yes ->

		mov	ax,AmbWarnings2
		cmp	ax,PrevAmbWarn2	;new amb warning?
		je	SkipSound	;no ->

@@:		
         test CockpitViews,0
		 jnz	@F
         call	AttentionSound
@@:
SkipSound:	mov	ax,AttnTimer	;update timer
		sub	ax,LastFrame
		jnc	@F

		xor	Attention,1	;toggle attention on / off

		mov	ax,FLASH_DELAY

@@:		mov	AttnTimer,ax

;* update previous warning flags

ContFailures:	mov	ax,RedWarnings2
		mov	PrevRedWarn2,ax
		mov	ax,AmbWarnings2
		mov	PrevAmbWarn2,ax

ExitFailures:	ret

CheckFailures	ENDP

MODCODE		ENDS

;============================================================================

		END

