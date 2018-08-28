;****************************************************************************
;*
;* MISCMAC.INC
;*
;* Miscellaneous macros.
;*
;* 03.11.1992 - KJB
;*
;****************************************************************************

;* SHAKE - set up screen shaker (unless higher priority shake in progress)
;*
;* pass: priority (see MAINDATA.INC)
;*	 hval = HSHAKE_OFF, HSHAKE_LO or HSHAKE_HI (see VGA_DRVR.ASM)
;*	 vval = VSHAKE_OFF, VSHAKE_LO or VSHAKE_HI (see VGA_DRVR.ASM)
;*	 time = secs * 100
;* ret : nothing
;* kill: flags

SHAKE		MACRO	priority,hval,vval,time
		LOCAL	_skip

		cmp	ShakePriority,priority	;;higher priority shake in progress?
		ja	_skip			;;yes ->

		mov	ShakePriority,priority
		mov	HShake,hval
		mov	VShake,vval
		mov	ShakeTimer,time

_skip:

		ENDM

;----------------------------------------------------------------------------

;* UNSHAKE - stop screen shake (if same shake)
;*
;* pass: nothing
;* ret : nothing
;* kill: flags

UNSHAKE		MACRO	priority
		LOCAL	_skip

		cmp	ShakePriority,priority	;;same shake?
		jne	_skip			;;no ->

		cli		
		mov	ShakePriority,0
		mov	ShakeTimer,0
		sti

_skip:

		ENDM

;----------------------------------------------------------------------------

;* DESTROY - destroy Tornado
;*
;* pass: die = die flag (see MAINDATA.INC)
;*	 level = destruction level (see MAINDATA.INC)
;* ret : nothing
;* kill: assume all

DESTROY		MACRO	die,level

	IFDIFI	<die>,<al>
		mov	al,die
	ENDIF
	IFDIFI	<level>,<ah>
		mov	ah,level
	ENDIF
		call	DestroyTornado

		ENDM

;----------------------------------------------------------------------------

;* CALC_EWR_INDEX - calc index into EWRTable[]
;*
;* pass: al = EWR number
;* ret : bx = EWRTable[] index
;* kill: ax, flags

CALC_EWR_INDEX	MACRO

		xor	ah,ah
		shl	ax,1		;*2
		mov	bx,ax
		shl	bx,1		;*4
		add	bx,ax		;*6

		ENDM

;----------------------------------------------------------------------------

;* CALC_RAD_INDEX - calc index into RadarTable[]
;*
;* pass: al = sector number
;* ret : bp = RadarTable[] index
;* kill: ax, flags

CALC_RAD_INDEX	MACRO

		xor	ah,ah
		mov	bp,ax
		REPT	2		;*4
		shl	bp,1
		ENDM

		ENDM

