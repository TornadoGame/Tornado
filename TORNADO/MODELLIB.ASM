;****************************************************************************
;*
;* MODELLIB.ASM
;*
;* 21.01.1992 - KJB
;* 04.04.1992 - KJB - MoveViewpoint added.
;* 21.07.1992 - KJB - CalcSineFine added.
;* 14.02.1993 - KJB - CalcVias and CalcVkts added.
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	InitCtrlDevice
		PUBLIC	LimitPFine
		PUBLIC	LimitPitch
		PUBLIC	MoveViewpoint
		PUBLIC	CalcSineFine
		PUBLIC	CalcVias
		PUBLIC	CalcVkts

		EXTRN	RecalJoysticks:FAR

		EXTRN	ControlDevice:WORD
		EXTRN	EleKbdWash:WORD
		EXTRN	AilKbdWash:WORD
		EXTRN	RudKbdWash:WORD
		EXTRN	ThrottleFine:WORD
		EXTRN	ReheatFine:WORD
		EXTRN	SinTable:WORD
		EXTRN	SqrtRhoTable:WORD

		EXTRN	JoyA_Flag:BYTE
		EXTRN	JoyB_Flag:BYTE
		EXTRN	JoyA_Fire1:BYTE
		EXTRN	JoyA_Fire2:BYTE
		EXTRN	JoyA_JustFired1:BYTE
		EXTRN	JoyA_JustFired2:BYTE
		EXTRN	JoyB_Fire1:BYTE
		EXTRN	JoyB_Fire2:BYTE
		EXTRN	JoyB_JustFired1:BYTE
		EXTRN	JoyB_JustFired2:BYTE

;============================================================================

		INCLUDE	MAINDATA.INC

		INCLUDE	\VISUAL\VISDATA.INC

		INCLUDE	\LIB8086\USEFUL.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

InitCtrlSwitch	DW	InitKbd1	;CTRL_DEV_KBD1
		DW	InitKbd2	;CTRL_DEV_KBD2
		DW	InitJoy1	;CTRL_DEV_JOY1
		DW	InitJoy2	;CTRL_DEV_JOY2

DATA		ENDS

;============================================================================

MODCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:MODCODE
		ASSUME DS:DATA

;* InitCtrlDevice - initialize control device
;*
;* pass: ControlDevice
;* ret : nothing
;* kill: assume all

InitCtrlDevice	PROC	FAR

		call	RecalJoysticks

		mov	bx,ControlDevice
		jmp	InitCtrlSwitch[bx]

;---------------------------
InitKbd1	LABEL	NEAR
;---------------------------

		mov	EleKbdWash,32768
		mov	AilKbdWash,32768
		mov	RudKbdWash,32768

;* ensure joystick buttons are clear

		xor	al,al

		mov	JoyA_Fire1,al
		mov	JoyA_Fire2,al
		mov	JoyA_JustFired1,al
		mov	JoyA_JustFired2,al

		mov	JoyB_Fire1,al
		mov	JoyB_Fire2,al
		mov	JoyB_JustFired1,al
		mov	JoyB_JustFired2,al

		ret

;---------------------------
InitKbd2	LABEL	NEAR
;---------------------------

		mov	EleKbdWash,4000
		mov	AilKbdWash,2000
		mov	RudKbdWash,2000

;* ensure joystick buttons are clear

		xor	al,al

		mov	JoyA_Fire1,al
		mov	JoyA_Fire2,al
		mov	JoyA_JustFired1,al
		mov	JoyA_JustFired2,al

		mov	JoyB_Fire1,al
		mov	JoyB_Fire2,al
		mov	JoyB_JustFired1,al
		mov	JoyB_JustFired2,al

		ret

;---------------------------
InitJoy1	LABEL	NEAR
;---------------------------

;* if single joystick not fitted then default to keyboard

		test	JoyA_Flag,1	;joystick fitted?
		jnz	@F		;yes ->

		mov	ControlDevice,CTRL_DEV_KBD1

		jmp	InitKbd1

@@:		mov	RudKbdWash,32768

		ret

;---------------------------
InitJoy2	LABEL	NEAR
;---------------------------

;* if both joysticks not fitted then default to keyboard

		mov	al,JoyA_Flag
		test	al,JoyB_Flag	;joysticks fitted?
		jnz	@F		;yes ->

		mov	ControlDevice,CTRL_DEV_KBD1

		jmp	InitKbd1

@@:		mov	ThrottleFine,0	;reset throttle fine
		mov	ReheatFine,0	;reset reheat fine

		ret

InitCtrlDevice	ENDP

;----------------------------------------------------------------------------

;* LimitPFine - limit pitch angle (+90 .. 0 .. -90)
;*
;* pass: ax = hdg   )
;*       bx = pitch ) 0 .. 65535 fine pdegs
;*       cx = roll  )
;*       dx = pitch direction (0 = +ve, -1 = -ve) [optional]
;* ret : ax = hdg   )
;*       bx = pitch ) 0 .. 65535 fine pdegs
;*       cx = roll  )
;*       dx = pitch direction (0 = +ve, -1 = -ve)
;* kill: flags

LimitPFine	PROC	FAR

		cmp	bx,128*128	;pitch <= 90 degs?
		jbe	@F		;yes ->
		cmp	bx,384*128	;pitch >= -90 degs
		jae	@F		;yes ->

		sub	bx,256*128	;flip pitch 180 degs
		neg	bx		;invert sign

		sub	ax,256*128	;flip heading 180 degs

		sub	cx,256*128	;flip roll 180 degs

		not	dx		;flip pitch direction

@@:		ret

LimitPFine	ENDP

;----------------------------------------------------------------------------

;* LimitPitch - limit pitch angle (+90 .. 0 .. -90)
;*
;* pass: ax = hdg   )
;*       bx = pitch ) 0 .. 511 pdegs
;*       cx = roll  )
;*       dx = pitch direction (0 = +ve, -1 = -ve) [optional]
;* ret : ax = hdg   )
;*       bx = pitch ) 0 .. 511 pdegs
;*       cx = roll  )
;*       dx = pitch direction (0 = +ve, -1 = -ve)
;* kill: flags

LimitPitch	PROC	FAR

		cmp	bx,128		;pitch <= 90 degs?
		jbe	@F		;yes ->
		cmp	bx,384		;pitch >= -90 degs
		jae	@F		;yes ->

		sub	bx,256		;flip pitch 180 degs
		neg	bx		;invert sign
		and	bx,001ffh	;(0 .. 511)

		sub	ax,256		;flip heading 180 degs
		and	ax,001ffh	;(0 .. 511)

		sub	cx,256		;flip roll 180 degs
		and	cx,001ffh	;(0 .. 511)

		not	dx		;flip pitch direction

@@:		ret

LimitPitch	ENDP

;----------------------------------------------------------------------------

;* MoveViewpoint
;*
;* pass: si -> VIEWPOINT data block
;*       dx, ax = x offset
;*       cx, bx = y offset
;* ret : VP_XSEC[si], VP_XFT[si]
;*       VP_YSEC[si], VP_YFT[si]
;* kill: assume all (except si)

MoveViewpoint	PROC	FAR

;----------------
;* calc new x pos
;----------------

;* linear xft = xsec * 16384 + xft + 8192

		mov	bp,VP_XSEC[si]
		xor	di,di
		REPT	2		;/4 (xsec * 65536 / 4 = xsec * 16384)
		sar	bp,1
		rcr	di,1
		ENDM

		push	ax

		mov	ax,VP_XFT[si]
		add	ax,8192

		add	di,ax
		adc	bp,0

		pop	ax

;* new x pos = linear xft + x offset

		add	di,ax
		adc	bp,dx

;* xsec = linear xft / 16384, xft = (linear xft and 03fffh) - 8192

		mov	ax,di

		REPT	2   		;*4 (xsec * 4 / 65536 = xsec / 16384)
		shl	di,1
		rcl	bp,1
		ENDM
		mov	VP_XSEC[si],bp

		and	ax,03fffh
		sub	ax,8192
		mov	VP_XFT[si],ax

;----------------
;* calc new y pos
;----------------

;* linear yft = ysec * 16384 + (-yft + 8191)

		mov	bp,VP_YSEC[si]
		xor	di,di
		REPT	2		;/4 (ysec * 65536 / 4 = ysec * 16384)
		sar	bp,1
		rcr	di,1
		ENDM

		mov	ax,VP_YFT[si]
		neg	ax
		add	ax,8191

		add	di,ax
		adc	bp,0

;* new y pos = linear yft - y offset

		sub	di,bx
		sbb	bp,cx

;* ysec = linear yft / 16384, yft = -((linear yft and 03fffh) - 8191)

		mov	ax,di

		REPT	2   		;*4 (ysec * 4 / 65536 = ysec / 16384)
		shl	di,1
		rcl	bp,1
		ENDM
		mov	VP_YSEC[si],bp

		and	ax,03fffh
		sub	ax,8191
		neg	ax
		mov	VP_YFT[si],ax

		ret

MoveViewpoint	ENDP

;----------------------------------------------------------------------------

;* CalcSineFine - look up and interpolate sin(fine pdegs)
;*
;* pass: ax = fine pdegs
;* ret : ax = sin(fine pdegs)
;* kill: assume all (except ax)
;*
;* note: Only valid for angles +90 .. -90degs.

CalcSineFine	PROC	FAR

		ABSV	ax		;ax = abs(frac), dx = sign(frac)

		mov	bp,dx		;store sign(frac)
		mov	dx,ax		;store abs(frac)

		mov	cl,7		;prime for /128

		mov	bx,ax
		shr	bx,cl		;/128

		shl	bx,1		;*2 word index

		mov	ax,SinTable[bx]

		and	dx,0007fh	;extract remaining bits
		jz	@F		;(trap PFine = 04000h case) ->
   
		mov	si,ax

		mov	ax,SinTable[bx+2]

		sub	ax,si		;ax = diff

		mul	dx

		shr	ax,cl		;/128

		adc	ax,si		;(1/2 bit round up)

@@:		xor	ax,bp		;restore sign
		sub	ax,bp

		ret

CalcSineFine	ENDP

;----------------------------------------------------------------------------

;* CalcVias
;*
;* pass: dx, ax = zft
;*       bp = vtas [*8]
;* ret : ax = vias [*8]
;* kill: bx, dx, flags

CalcVias	PROC	FAR

;* look up sqrt(rho) (tabulated from 0 .. 70,000ft step 1,000ft)

		mov	bx,1000
		div	bx

		cmp	ax,70
		jbe	@F
		mov	ax,70

@@:		mov	bx,ax
		shl	bx,1

		mov	ax,SqrtRhoTable[bx]

;* vias = vtas * sqrt(rho)

		imul	bp

		FRACADJ	ax

		ret

CalcVias	ENDP

;----------------------------------------------------------------------------

;* CalcVkts
;*
;* pass: ax = vias [*8]
;* ret : ax = vkts
;* kill: dx, flags

CalcVkts	PROC	FAR

;* vkts = vias [*8] / 1.7 * 8 = vias * 2409 / 32768

		mov	dx,2409
		imul	dx
		FRACADJ	ax

		ret

CalcVkts	ENDP

MODCODE		ENDS

;============================================================================

		END

