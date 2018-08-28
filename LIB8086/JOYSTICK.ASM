;****************************************************************************
;*
;* JOYSTICK.ASM
;*
;* 08.09.1989 - KJB - Original joystick routines (digital output).
;* 02.04.1991 - KJB - Rewritten to give analogue output.
;* 21.10.1991 - KJB - NPOS equate added.
;* 14.11.1991 - KJB - RECOVER macro added.
;* 07.03.1992 - KJB - "old" vars added.
;* 15.03.1992 - KJB - Timeout code added.
;* 15.04.1992 - KJB - RECOVER placed immediately after all joystick I/O in
;*                    ReadAnalogue subroutine.
;*                    RECOVER "nop" replaced with "jmp $+2".
;* 28.07.1992 - KJB - Joystick sensitivity added (for ThrustMaster fix).
;* 13.11.1992 - KJB - "just" fired flags added.
;* 06.04.1993 - KJB - ThrustMaster routines added.
;* 20.04.1993 - KJB - CH FlightStick Pro mods made.
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	RecalJoysticks
		PUBLIC	ReadJoysticks

		PUBLIC	JoyA_Flag
		PUBLIC	JoyB_Flag

		PUBLIC	JoyA_XRef
		PUBLIC	JoyA_YRef
		PUBLIC	JoyA_XScale
		PUBLIC	JoyA_YScale
		PUBLIC	JoyA_XPos
		PUBLIC	JoyA_YPos
		PUBLIC	JoyA_XVal
		PUBLIC	JoyA_YVal
		PUBLIC	JoyA_Fire1
		PUBLIC	JoyA_Fire2
		PUBLIC	JoyA_JustFired1
		PUBLIC	JoyA_JustFired2

		PUBLIC	OldJoyA_XVal
		PUBLIC	OldJoyA_YVal
		PUBLIC	OldJoyA_Fire1
		PUBLIC	OldJoyA_Fire2

		PUBLIC	JoyB_XRef
		PUBLIC	JoyB_YRef
		PUBLIC	JoyB_XScale
		PUBLIC	JoyB_YScale
		PUBLIC	JoyB_XPos
		PUBLIC	JoyB_YPos
		PUBLIC	JoyB_XVal
		PUBLIC	JoyB_YVal
		PUBLIC	JoyB_Fire1
		PUBLIC	JoyB_Fire2
		PUBLIC	JoyB_JustFired1
		PUBLIC	JoyB_JustFired2

		PUBLIC	OldJoyB_XVal
		PUBLIC	OldJoyB_YVal
		PUBLIC	OldJoyB_Fire1
		PUBLIC	OldJoyB_Fire2

		PUBLIC	JoySensitivity

		PUBLIC	CHStick

		PUBLIC	ThrustMaster
		PUBLIC	TM_MinX
		PUBLIC	TM_MinY
		PUBLIC	TM_MidX
		PUBLIC	TM_MidY
		PUBLIC	TM_MaxX
		PUBLIC	TM_MaxY
		PUBLIC	TM_CoolieCn
		PUBLIC	TM_CoolieLt
		PUBLIC	TM_CoolieDn
		PUBLIC	TM_CoolieRt
		PUBLIC	TM_CoolieUp
		PUBLIC	TM_XPos
		PUBLIC	TM_YPos
		PUBLIC	TM_XVal
		PUBLIC	TM_YVal
		PUBLIC	TM_CooliePos
		PUBLIC	TM_CoolieHat
		PUBLIC	TM_CoolieVal

		PUBLIC	COOLIE_UP
		PUBLIC	COOLIE_DN
		PUBLIC	COOLIE_LT
		PUBLIC	COOLIE_RT

;============================================================================

		INCLUDE	USEFUL.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

NPOS	 	EQU	32		;number of joystick positions

GAME_PORT	EQU	00201h		;game port address

JOY_A_XPOS	EQU	00000001b
JOY_A_YPOS	EQU	00000010b
JOY_B_XPOS	EQU	00000100b
JOY_B_YPOS	EQU	00001000b
JOY_A_FIRE1	EQU	00010000b
JOY_A_FIRE2	EQU	00100000b
JOY_B_FIRE1	EQU	01000000b
JOY_B_FIRE2	EQU	10000000b

JoyA_Flag	DB	0		;1 = joystick fitted
JoyB_Flag	DB	0		;1 = joystick fitted

JoyA_XRef	DW	0		;x ref = centre x * 2
JoyA_YRef	DW	0		;y ref = centre y * 2
JoyA_XScale	DW	0		;x scale = NPOS * 65536 / x ref (fraction)
JoyA_YScale	DW	0		;y scale = NPOS * 65536 / y ref (fraction)
JoyA_XPos	DW	0		;x pos = current x position
JoyA_YPos	DW	0		;y pos = current y position
JoyA_XVal	DW	0		;x val = x pos * x scale (0 .. NPOS)
JoyA_YVal	DW	0		;y val = y pos * y scale (0 .. NPOS)
JoyA_Fire1	DB	0		;1 = fire pressed
JoyA_Fire2	DB	0		;1 = fire pressed
JoyA_JustFired1	DB	0		;1 = fire just pressed
JoyA_JustFired2	DB	0		;1 = fire just pressed

OldJoyA_XVal	DW	0		;)
OldJoyA_YVal	DW	0		;) previous values of
OldJoyA_Fire1	DB	0		;) joystick variables
OldJoyA_Fire2	DB	0		;)

JoyB_XRef	DW	0		;x ref = centre x * 2
JoyB_YRef	DW	0		;y ref = centre y * 2
JoyB_XScale	DW	0		;x scale = NPOS * 65536 / x ref (fraction)
JoyB_YScale	DW	0		;y scale = NPOS * 65536 / y ref (fraction)
JoyB_XPos	DW	0		;x pos = current x position
JoyB_YPos	DW	0		;y pos = current y position
JoyB_XVal	DW	0		;x val = x pos * x scale (0 .. NPOS)
JoyB_YVal	DW	0		;y val = y pos * y scale (0 .. NPOS)
JoyB_Fire1	DB	0		;1 = fire pressed
JoyB_Fire2	DB	0		;1 = fire pressed
JoyB_JustFired1	DB	0		;1 = fire just pressed
JoyB_JustFired2	DB	0		;1 = fire just pressed

OldJoyB_XVal	DW	0		;)
OldJoyB_YVal	DW	0		;) previous values of
OldJoyB_Fire1	DB	0		;) joystick variables
OldJoyB_Fire2	DB	0		;)

;* joystick sensitivity

JoySensitivity	DB	0		;0 = normal, 1 = high sensitivity

		EVEN

;--------------------
;* CH FlightStick Pro
;--------------------

CHStick		DB	0		;1 = CH FlightStick Pro fitted

		EVEN

;--------------
;* ThrustMaster 
;--------------

ThrustMaster	DB	0		;1 = ThrustMaster joystick fitted

		EVEN

;* calibration values

TM_MinX		DW	0		;x top lh corner
TM_MinY		DW	0		;y top lh corner
TM_MidX		DW	0		;x centre
TM_MidY		DW	0		;y centre
TM_MaxX		DW	0		;x bottom rh corner
TM_MaxY		DW	0		;y bottom rh corner
TM_CoolieCn	DW	0		;coolie hat centre
TM_CoolieLt	DW	0		;coolie hat left
TM_CoolieDn	DW	0		;coolie hat down
TM_CoolieRt	DW	0		;coolie hat right
TM_CoolieUp	DW	0		;coolie hat up

;* current position

TM_XPos		DW	0		;x pos = current x position
TM_YPos		DW	0		;y pos = current y position

TM_XVal		DW	0		;x val = 0 .. NPOS
TM_YVal		DW	0		;y val = 0 .. NPOS

TM_CooliePos	DW	0		;coolie hat position

COOLIE_UP	EQU	1
COOLIE_DN	EQU	2
COOLIE_LT	EQU	3
COOLIE_RT	EQU	4

TM_CoolieHat	DB	0		;1 = coolie hat available

TM_CoolieVal	DB	0		;coolie hat value (if changed)
TM_CoolieNew	DB	0		;coolie hat value (this frame)
TM_CoolieOld	DB	0		;coolie hat value (last frame)

		EVEN
			
;* fire buttons

TM_FIRE1	EQU	JOY_A_FIRE1	;main fire button (trigger)
TM_FIRE2	EQU	JOY_A_FIRE2	;top button (next to coolie hat)
TM_FIRE3	EQU	JOY_B_FIRE1	;left hand button (thumb)
TM_FIRE4	EQU	JOY_B_FIRE2	;bottom button (pinkie)

DATA		ENDS

;============================================================================

LIBCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:LIBCODE
		ASSUME DS:DATA

;* RecalJoysticks - recalibrate joysticks (assume joysticks centered)
;*
;* pass: nothing
;* ret : JoyA_Flag = 1: JoyA_XRef
;*                      JoyA_YRef
;*                      JoyA_XScale
;*                      JoyA_YScale
;*       JoyB_Flag = 1: JoyB_XRef
;*                      JoyB_YRef
;*                      JoyB_XScale
;*                      JoyB_YScale
;* kill: assume all

RecalJoysticks	PROC	FAR

;--------------------
;* sort joystick type (intercept ThrustMaster)
;--------------------

		test	ThrustMaster,1
		_JNZ	RecalThrust

;-----------------------------
;* assume joysticks not fitted
;-----------------------------

		xor	ax,ax

		mov	JoyA_Flag,al
		mov	JoyB_Flag,al

		mov	JoyA_XRef,ax
		mov	JoyA_YRef,ax
		mov	JoyA_XScale,ax
		mov	JoyA_YScale,ax
		mov	JoyA_XPos,ax
		mov	JoyA_YPos,ax
		mov	JoyA_XVal,ax
		mov	JoyA_YVal,ax
		mov	JoyA_Fire1,al
		mov	JoyA_Fire2,al
		mov	JoyA_JustFired1,al
		mov	JoyA_JustFired2,al

		mov	JoyB_XRef,ax
		mov	JoyB_YRef,ax
		mov	JoyB_XScale,ax
		mov	JoyB_YScale,ax
		mov	JoyB_XPos,ax
		mov	JoyB_YPos,ax
		mov	JoyB_XVal,ax
		mov	JoyB_YVal,ax
		mov	JoyB_Fire1,al
		mov	JoyB_Fire2,al
		mov	JoyB_JustFired1,al
		mov	JoyB_JustFired2,al

		mov	TM_CoolieVal,al
		mov	TM_CoolieNew,al
		mov	TM_CoolieOld,al

;-------------------------------------
;* joystick A - calc x ref and x scale
;-------------------------------------

		xor	bp,bp		;clear result
		
		REPT	4
		mov	ah,JOY_A_XPOS
		call	ReadAnalogue
		jc	SkipRecalA	;timeout ->
		add	bp,ax
		ENDM

;* x ref = (accumulated centre x) / 4 * 2 = (accumulated centre x) / 2

		shr	bp,1		;/2
		mov	JoyA_XRef,bp

;* x scale = NPOS * 65536 / x ref

		mov	dx,NPOS
		xor	ax,ax

		cmp	bp,dx
		jbe	SkipRecalA	;error ->

		div	bp
		
		mov	JoyA_XScale,ax

;-------------------------------------
;* joystick A - calc y ref and y scale
;-------------------------------------

		xor	bp,bp		;clear result
		
		REPT	4
		mov	ah,JOY_A_YPOS
		call	ReadAnalogue
		jc	SkipRecalA	;timeout ->
		add	bp,ax
		ENDM

;* y ref = (accumulated centre y) / 4 * 2 = (accumulated centre y) / 2

		shr	bp,1		;/2
		mov	JoyA_YRef,bp

;* y scale = NPOS * 65536 / y ref

		mov	dx,NPOS
		xor	ax,ax

		cmp	bp,dx
		jbe	SkipRecalA	;error ->

		div	bp
		
		mov	JoyA_YScale,ax

		mov	al,1
		mov	JoyA_Flag,al

;-------------------------------------
;* joystick B - calc x ref and x scale
;-------------------------------------

SkipRecalA:  	xor	bp,bp		;clear result
		
		REPT	4
		mov	ah,JOY_B_XPOS
		call	ReadAnalogue
		jc	SkipRecalB	;timeout ->
		add	bp,ax
		ENDM

;* x ref = (accumulated centre x) / 4 * 2 = (accumulated centre x) / 2

		shr	bp,1		;/2
		mov	JoyB_XRef,bp

;* x scale = NPOS * 65536 / x ref

		mov	dx,NPOS
		xor	ax,ax

		cmp	bp,dx
		jbe	SkipRecalB	;error ->

		div	bp
		
		mov	JoyB_XScale,ax

;-------------------------------------
;* joystick B - calc y ref and y scale
;-------------------------------------

		xor	bp,bp		;clear result
		
		REPT	4
		mov	ah,JOY_B_YPOS
		call	ReadAnalogue
		jc	SkipRecalB	;timeout ->
		add	bp,ax
		ENDM

;* y ref = (accumulated centre y) / 4 * 2 = (accumulated centre y) / 2

		shr	bp,1		;/2
		mov	JoyB_YRef,bp

;* y scale = NPOS * 65536 / y ref

		mov	dx,NPOS
		xor	ax,ax

		cmp	bp,dx
		jbe	SkipRecalB	;error ->

		div	bp
		
		mov	JoyB_YScale,ax

		mov	al,1
		mov	JoyB_Flag,al

SkipRecalB:	ret

RecalJoysticks	ENDP

;----------------------------------------------------------------------------

;* ReadJoysticks - read joysticks A and B (if fitted)
;*
;* pass: JoyA_Flag = 1: JoyA_XRef
;*                      JoyA_YRef
;*                      JoyA_XScale
;*                      JoyA_YScale
;*       JoyB_Flag = 1: JoyB_XRef
;*                      JoyB_YRef
;*                      JoyB_XScale
;*                      JoyB_YScale
;* ret : JoyA_Flag = 1: JoyA_XPos
;*                      JoyA_YPos
;*                      JoyA_XVal
;*                      JoyA_YVal
;*                      JoyA_Fire1
;*                      JoyA_Fire2
;*                      JoyA_JustFired1
;*                      JoyA_JustFired2
;*       JoyB_Flag = 1: JoyB_XPos
;*                      JoyB_YPos
;*                      JoyB_XVal
;*                      JoyB_YVal
;*                      JoyB_Fire1
;*                      JoyB_Fire2
;*                      JoyB_JustFired1
;*                      JoyB_JustFired2
;* kill: assume all

ReadJoysticks	PROC	FAR

;--------------------
;* sort joystick type (intercept ThrustMaster)
;--------------------

		test	ThrustMaster,1
		_JNZ	ReadThrust

;---------------------------------------
;* copy previous values of joystick vars
;---------------------------------------

		mov	ax,JoyA_XVal
		mov	OldJoyA_XVal,ax
		mov	ax,JoyA_YVal
		mov	OldJoyA_YVal,ax
		mov	al,JoyA_Fire1
		mov	OldJoyA_Fire1,al
		mov	al,JoyA_Fire2
		mov	OldJoyA_Fire2,al
		
		mov	ax,JoyB_XVal
		mov	OldJoyB_XVal,ax
		mov	ax,JoyB_YVal
		mov	OldJoyB_YVal,ax
		mov	al,JoyB_Fire1
		mov	OldJoyB_Fire1,al
		mov	al,JoyB_Fire2
		mov	OldJoyB_Fire2,al

;* reset fire flags

		xor	al,al

		mov	JoyA_Fire1,al
		mov	JoyA_Fire2,al
		mov	JoyA_JustFired1,al
		mov	JoyA_JustFired2,al
		mov	JoyB_Fire1,al
		mov	JoyB_Fire2,al
		mov	JoyB_JustFired1,al
		mov	JoyB_JustFired2,al

;-----------------------------
;* read joystick A (if fitted)
;-----------------------------

ReadJoyA:	test	JoyA_Flag,1	;joystick A fitted?
		_JZ	JoyAOpenCct	;no ->

		mov	ah,JOY_A_XPOS
		call	ReadAnalogue
		_JC	JoyATimeOut	;timeout ->

		test	JoySensitivity,1	;high sensitivity?
		jz	SkipJoyA_XSens		;no ->

;* pos = max(((pos * 4) - ref) / 2, 0)

		shl	ax,1
		shl	ax,1
		sub	ax,JoyA_XRef
		jnc	@F
		xor	ax,ax
@@:		shr	ax,1

SkipJoyA_XSens:	mov	JoyA_XPos,ax

		mov	dx,JoyA_XScale
		mul	dx		;x val = x pos * x scale
		shl	ax,1
		adc	dx,0	 	;1/2 bit round up
		mov	ax,dx
		cmp	ax,NPOS		;x val > NPOS?
		jbe	XOkA		;no ->
		mov	ax,NPOS
XOkA:		mov	JoyA_XVal,ax

		mov	ah,JOY_A_YPOS
		call	ReadAnalogue
		_JC	JoyATimeOut	;timeout ->

		test	JoySensitivity,1	;high sensitivity?
		jz	SkipJoyA_YSens		;no ->

;* pos = max(((pos * 4) - ref) / 2, 0)

		shl	ax,1
		shl	ax,1
		sub	ax,JoyA_YRef
		jnc	@F
		xor	ax,ax
@@:		shr	ax,1

SkipJoyA_YSens:	mov	JoyA_YPos,ax

		mov	dx,JoyA_YScale
		mul	dx		;y val = y pos * y scale
		shl	ax,1
		adc	dx,0	 	;1/2 bit round up
		mov	ax,dx
		cmp	ax,NPOS		;y val > NPOS?
		jbe	YOkA		;no ->
		mov	ax,NPOS
YOkA:		mov	JoyA_YVal,ax

;* test for fire buttons pressed

		test	CHStick,1	;CH stick?
		jnz	SortCHStick	;yes ->

		mov	dx,GAME_PORT
		in	al,dx

		test	al,JOY_A_FIRE1	;fire button 1 pressed?
		jnz	@F		;no ->
		mov	JoyA_Fire1,1

		test	OldJoyA_Fire1,1		;fire pressed last time?
		jnz	@F			;yes ->
		mov	JoyA_JustFired1,1	;just fired

@@:		test	al,JOY_A_FIRE2	;fire button 2 pressed?
		jnz	@F		;no ->
		mov	JoyA_Fire2,1

		test	OldJoyA_Fire2,1		;fire pressed last time?
		jnz	@F			;yes ->
		mov	JoyA_JustFired2,1	;just fired

@@:		jmp	ReadJoyB

;* sort CH FlightStick Pro buttons and coolie hat

SortCHStick:	mov	TM_CoolieVal,0

		mov	al,TM_CoolieNew
		mov	TM_CoolieOld,al

		mov	TM_CoolieNew,0

		mov	dx,GAME_PORT
		in	al,dx

		and	al,11110000b

		cmp	al,11100000b	;button A1?
		je	CHButtonA1	;yes ->
		cmp	al,11010000b	;button A2?
		je	CHButtonA2	;yes ->
		cmp	al,10110000b	;button B1?
		je	CHButtonB1	;yes ->
		cmp	al,01110000b	;button B2?
		je	CHButtonB2	;yes ->

		cmp	al,00000000b	;coolie up?
		je	CHCoolieUp	;yes ->
		cmp	al,10000000b	;coolie down?
		je	CHCoolieDn	;yes ->
		cmp	al,01000000b	;coolie right?
		je	CHCoolieRt	;yes ->
		cmp	al,11000000b	;coolie left?
		je	CHCoolieLt	;yes ->

		jmp	ReadJoyExit

CHButtonA1:  	mov	JoyA_Fire1,1

		test	OldJoyA_Fire1,1		;fire pressed last time?
		jnz	@F			;yes ->
		mov	JoyA_JustFired1,1	;just fired

@@:	     	jmp	ReadJoyExit

CHButtonA2: 	mov	JoyA_Fire2,1

		test	OldJoyA_Fire2,1		;fire pressed last time?
		jnz	@F			;yes ->
		mov	JoyA_JustFired2,1	;just fired

@@:	    	jmp	ReadJoyExit

CHButtonB1:	mov	JoyB_Fire1,1

		test	OldJoyB_Fire1,1		;fire pressed last time?
		jnz	@F			;yes ->
		mov	JoyB_JustFired1,1	;just fired

@@:	     	jmp	ReadJoyExit

CHButtonB2:	mov	JoyB_Fire2,1

		test	OldJoyB_Fire2,1		;fire pressed last time?
		jnz	@F			;yes ->
		mov	JoyB_JustFired2,1	;just fired

@@:	     	jmp	ReadJoyExit

CHCoolieUp:	mov	TM_CoolieNew,COOLIE_UP
		jmp	CHCoolieOk

CHCoolieDn:	mov	TM_CoolieNew,COOLIE_DN
		jmp	CHCoolieOk

CHCoolieLt:	mov	TM_CoolieNew,COOLIE_LT
		jmp	CHCoolieOk

CHCoolieRt:	mov	TM_CoolieNew,COOLIE_RT

CHCoolieOk:	mov	al,TM_CoolieNew
		cmp	al,TM_CoolieOld
		je	@F

		mov	TM_CoolieVal,al

@@:		jmp	ReadJoyExit

;* joystick timeout

JoyATimeOut:	mov	JoyA_Flag,0

;* joystick not fitted

JoyAOpenCct:	xor	ax,ax

		mov	JoyA_XPos,ax
		mov	JoyA_YPos,ax
		mov	JoyA_XVal,ax
		mov	JoyA_YVal,ax

;-----------------------------
;* read joystick B (if fitted)
;-----------------------------

ReadJoyB: 	test	JoyB_Flag,1	;joystick B fitted?
		_JZ	JoyBOpenCct	;no ->

		mov	ah,JOY_B_XPOS
		call	ReadAnalogue
		_JC	JoyBTimeOut	;timeout ->

		test	JoySensitivity,1	;high sensitivity?
		jz	SkipJoyB_XSens		;no ->

;* pos = max(((pos * 4) - ref) / 2, 0)

		shl	ax,1
		shl	ax,1
		sub	ax,JoyB_XRef
		jnc	@F
		xor	ax,ax
@@:		shr	ax,1

SkipJoyB_XSens:	mov	JoyB_XPos,ax

		mov	dx,JoyB_XScale
		mul	dx		;x val = x pos * x scale
		shl	ax,1
		adc	dx,0	 	;1/2 bit round up
		mov	ax,dx
		cmp	ax,NPOS		;x val > NPOS?
		jbe	XOkB		;no ->
		mov	ax,NPOS
XOkB:		mov	JoyB_XVal,ax

		mov	ah,JOY_B_YPOS
		call	ReadAnalogue
		jc	JoyBTimeOut	;timeout ->

		test	JoySensitivity,1	;high sensitivity?
		jz	SkipJoyB_YSens		;no ->

;* pos = max(((pos * 4) - ref) / 2, 0)

		shl	ax,1
		shl	ax,1
		sub	ax,JoyB_YRef
		jnc	@F
		xor	ax,ax
@@:		shr	ax,1

SkipJoyB_YSens:	mov	JoyB_YPos,ax

		mov	dx,JoyB_YScale
		mul	dx		;y val = y pos * y scale
		shl	ax,1
		adc	dx,0	 	;1/2 bit round up
		mov	ax,dx
		cmp	ax,NPOS		;y val > NPOS?
		jbe	YOkB		;no ->
		mov	ax,NPOS
YOkB:		mov	JoyB_YVal,ax

;* test for fire buttons pressed

		mov	dx,GAME_PORT
		in	al,dx

		test	al,JOY_B_FIRE1	;fire button 1 pressed?
		jnz	@F		;no ->
		mov	JoyB_Fire1,1

		test	OldJoyB_Fire1,1		;fire pressed last time?
		jnz	@F			;yes ->
		mov	JoyB_JustFired1,1	;just fired

@@:		test	al,JOY_B_FIRE2	;fire button 2 pressed?
		jnz	@F		;no ->
		mov	JoyB_Fire2,1

		test	OldJoyB_Fire2,1		;fire pressed last time?
		jnz	@F			;yes ->
		mov	JoyB_JustFired2,1	;just fired

@@:		jmp	ReadJoyExit

;* joystick timeout

JoyBTimeOut:	mov	JoyB_Flag,0

;* joystick not fitted

JoyBOpenCct:	xor	ax,ax

		mov	JoyB_XPos,ax
		mov	JoyB_YPos,ax
		mov	JoyB_XVal,ax
		mov	JoyB_YVal,ax

ReadJoyExit:	ret

ReadJoysticks	ENDP

;----------------------------------------------------------------------------

;* ReadAnalogue - read analogue input from game adapter
;*
;* pass: ah = test mask: 0001b = joystick A X co-ord
;*                       0010b = joystick A Y co-ord
;*                       0100b = joystick B X co-ord
;*                       1000b = joystick B Y co-ord
;* ret : cf = 0: ax = duration of unstable state
;*       cf = 1: timeout error
;* kill: cx, dx, flags
;* note: Refer to 8088 Assembler Language Programming. The IBM PC.
;*       Willen and Krantz. Pub. SAMS. ISBN 0-672-22400-3.
;*
;*       Some game ports are not compatible with fast processors. Use the
;*       RECOVER macro after i/o to allow the game port to recover from
;*       this stressful experience.

RECOVER		MACRO
		REPT	10
		jmp	$+2
		ENDM
		ENDM

ReadAnalogue	PROC	NEAR

		mov	dx,GAME_PORT

		cli			;disable intr's for precise timing

		mov	cx,0		;set timeout count
StableLoop:	in	al,dx		;read game port

		RECOVER		

		test	al,ah		;test selected input
		jz	UnstableState	;input in stable state ->

		loop	StableLoop	;wait for stable state
		stc			;set timeout error
		jmp	AnalogueExit	

UnstableState:	out	dx,al		;force game adapter to unstable state

		RECOVER		

		mov	cx,0		;set timeout count
UnstableLoop:	in	al,dx		;read game port

		RECOVER		

		test	al,ah		;test selected input
		jz	StableState	;input in stable state ->

		loop	UnstableLoop	;wait for stable state
		stc			;set timeout error
		jmp	AnalogueExit

StableState:	neg	cx		;cx = duration of unstable state
		mov	ax,cx		;return analogue value in ax		
		clc			;clear timeout error

AnalogueExit:	sti			;enable intr's
		ret

ReadAnalogue	ENDP

;----------------------------------------------------------------------------

;* RecalThrust - recal ThrustMaster joystick
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

RecalThrust	PROC	FAR

;-----------------------------
;* assume joysticks not fitted
;-----------------------------

		xor	ax,ax

		mov	JoyA_Flag,al

		mov	JoyA_XVal,ax
		mov	JoyA_YVal,ax
		mov	JoyA_Fire1,al
		mov	JoyA_Fire2,al
		mov	JoyA_JustFired1,al
		mov	JoyA_JustFired2,al
		mov	JoyB_Fire1,al
		mov	JoyB_Fire2,al
		mov	JoyB_JustFired1,al
		mov	JoyB_JustFired2,al

		mov	TM_XPos,ax
		mov	TM_YPos,ax
		mov	TM_XVal,ax
		mov	TM_YVal,ax
		mov	TM_CooliePos,ax

		mov	TM_MidX,ax
		mov	TM_MidY,ax

		mov	TM_CoolieHat,al
		mov	TM_CoolieVal,al
		mov	TM_CoolieNew,al
		mov	TM_CoolieOld,al

;----------------
;* recal centre x
;----------------

		mov	ah,JOY_A_XPOS
		call	ReadAnalogue
		jc	SkipRecalThrust
		mov	TM_MidX,ax

;----------------
;* recal centre y
;----------------

		mov	ah,JOY_A_YPOS
		call	ReadAnalogue
		jc	SkipRecalThrust
		mov	TM_MidY,ax

;-------------------------------
;* check if coolie hat available
;-------------------------------

		mov	ah,JOY_B_YPOS
		call	ReadAnalogue
		jc	@F

		mov	TM_CoolieHat,1

@@:	 	mov	JoyA_Flag,1

SkipRecalThrust:

		ret

RecalThrust	ENDP

;----------------------------------------------------------------------------

;* ReadThrust - read ThrustMaster joystick
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

ReadThrust	PROC	FAR

;---------------------------------------
;* copy previous values of joystick vars
;---------------------------------------

		mov	ax,JoyA_XVal
		mov	OldJoyA_XVal,ax
		mov	ax,JoyA_YVal
		mov	OldJoyA_YVal,ax
		mov	al,JoyA_Fire1
		mov	OldJoyA_Fire1,al
		mov	al,JoyA_Fire2
		mov	OldJoyA_Fire2,al
		
		mov	al,JoyB_Fire1
		mov	OldJoyB_Fire1,al
		mov	al,JoyB_Fire2
		mov	OldJoyB_Fire2,al

;* reset fire flags

		xor	al,al

		mov	JoyA_Fire1,al
		mov	JoyA_Fire2,al
		mov	JoyA_JustFired1,al
		mov	JoyA_JustFired2,al
		mov	JoyB_Fire1,al
		mov	JoyB_Fire2,al
		mov	JoyB_JustFired1,al
		mov	JoyB_JustFired2,al

;* reset coolie hat

		mov	TM_CoolieVal,al

;---------------------------
;* check ThrustMaster fitted
;---------------------------

		test	JoyA_Flag,1
		_JZ	TMOpenCct

;-------------------
;* debug calibration
;-------------------

	IF	0

;----------
;* min x, y (joystick to top lh corner and press fire button 4)
;----------

		mov	dx,GAME_PORT
		in	al,dx
		test	al,TM_FIRE4
		jnz	SkipCalMin

		mov	TM_MinX,0
		mov	TM_MinY,0

		mov	ah,JOY_A_XPOS
		call	ReadAnalogue
		jc	@F
		mov	TM_MinX,ax
@@:		

		mov	ah,JOY_A_YPOS
		call	ReadAnalogue
		jc	@F
		mov	TM_MinY,ax
@@:		

SkipCalMin:

;----------
;* mid x, y (joystick to centre and press fire button 1)
;----------

		mov	dx,GAME_PORT
		in	al,dx
		test	al,TM_FIRE1
		jnz	SkipCalMid

		mov	TM_MidX,0
		mov	TM_MidY,0

		mov	ah,JOY_A_XPOS
		call	ReadAnalogue
		jc	@F
		mov	TM_MidX,ax
@@:		

		mov	ah,JOY_A_YPOS
		call	ReadAnalogue
		jc	@F
		mov	TM_MidY,ax
@@:		

SkipCalMid:

;----------
;* max x, y (joystick to bottom rh corner and press fire button 3)
;----------

		mov	dx,GAME_PORT
		in	al,dx
		test	al,TM_FIRE3
		jnz	SkipCalMax

		mov	TM_MaxX,0
		mov	TM_MaxY,0

		mov	ah,JOY_A_XPOS
		call	ReadAnalogue
		jc	@F
		mov	TM_MaxX,ax
@@:		

		mov	ah,JOY_A_YPOS
		call	ReadAnalogue
		jc	@F
		mov	TM_MaxY,ax
@@:		

SkipCalMax:

	ENDIF

;------------------------
;* read joystick position
;------------------------

		mov	ah,JOY_A_XPOS
		call	ReadAnalogue
		_JC	TMTimeout
		mov	TM_XPos,ax

		mov	ah,JOY_A_YPOS
		call	ReadAnalogue
		_JC	TMTimeout
		mov	TM_YPos,ax

;-----------------------
;* calc joystick x value (0 .. NPOS)
;-----------------------

;* if x pos < mid x then
;*    (left of centre)
;*    x val = ((x pos - min x) * NPOS / 2) / (mid x - min x)
;* else
;*    (right of centre)
;*    x val = ((x pos - mid x) * NPOS / 2) / (max x - mid x) + NPOS / 2
;* endif

		mov	ax,TM_XPos
		cmp	ax,TM_MidX
		jae	XRight

;-------------------------
;* joystick left of centre
;-------------------------

		mov	bp,TM_MinX	;normal sens

		test	JoySensitivity,1
		jz	@F

		mov	ax,TM_MidX	;high sens
		sub	ax,TM_MinX
		MINM	ax
		shr	ax,1
		adc	ax,TM_MinX
		mov	bp,ax

@@:		mov	ax,TM_XPos
		sub	ax,bp
		MINM	ax
		mov	dx,NPOS/2
		mul	dx

		mov	bx,TM_MidX
		sub	bx,bp
		jnc	@F
		xor	bx,bx

@@:		cmp	bx,dx
		jbe	XDivOv		;(keep same value as last frame)

		div	bx

		jmp	XOk

;--------------------------
;* joystick right of centre
;--------------------------

XRight:	   	mov	bp,TM_MaxX	;normal sens

		test	JoySensitivity,1
		jz	@F

		mov	ax,TM_MaxX	;high sens
		sub	ax,TM_MidX
		MINM	ax
		shr	ax,1
		adc	ax,TM_MidX
		mov	bp,ax

@@:		mov	ax,TM_XPos
		sub	ax,TM_MidX
		MINM	ax
		mov	dx,NPOS/2
		mul	dx

		mov	bx,bp
		sub	bx,TM_MidX
		jnc	@F
		xor	bx,bx

@@:		cmp	bx,dx
		jbe	XDivOv		;(keep same value as last frame)

		div	bx

		add	ax,NPOS/2

;---------------------
;* keep x val in range (0 .. NPOS)
;---------------------

XOk:		cmp	ax,NPOS
		jbe	@F

		mov	ax,NPOS

@@:		mov	TM_XVal,ax

XDivOv:

;-----------------------
;* calc joystick y value (0 .. NPOS)
;-----------------------

;* if y pos < mid y then
;*    (above centre)
;*    y val = ((y pos - min y) * NPOS / 2) / (mid y - min y)
;* else
;*    (below centre)
;*    y val = ((y pos - mid y) * NPOS / 2) / (max y - mid y) + NPOS / 2
;* endif

		mov	ax,TM_YPos
		cmp	ax,TM_MidY
		jae	YBelow

;-----------------------
;* joystick above centre
;-----------------------

		mov	bp,TM_MinY	;normal sens

		test	JoySensitivity,1
		jz	@F

		mov	ax,TM_MidY	;high sens
		sub	ax,TM_MinY
		MINM	ax
		shr	ax,1
		adc	ax,TM_MinY
		mov	bp,ax

@@:		mov	ax,TM_YPos
		sub	ax,bp
		MINM	ax
		mov	dx,NPOS/2
		mul	dx

		mov	bx,TM_MidY
		sub	bx,bp
		jnc	@F
		xor	bx,bx

@@:		cmp	bx,dx
		jbe	YDivOv		;(keep same value as last frame)

		div	bx

		jmp	YOk

;-----------------------
;* joystick below centre
;-----------------------

YBelow:		mov	bp,TM_MaxY	;normal sens

		test	JoySensitivity,1
		jz	@F

		mov	ax,TM_MaxY	;high sens
		sub	ax,TM_MidY
		MINM	ax
		shr	ax,1
		adc	ax,TM_MidY
		mov	bp,ax

@@:		mov	ax,TM_YPos
		sub	ax,TM_MidY
		MINM	ax
		mov	dx,NPOS/2
		mul	dx

		mov	bx,bp
		sub	bx,TM_MidY
		jnc	@F
		xor	bx,bx

@@:		cmp	bx,dx
		jbe	YDivOv		;(keep same value as last frame)

		div	bx

		add	ax,NPOS/2

;---------------------
;* keep y val in range (0 .. NPOS)
;---------------------

YOk:		cmp	ax,NPOS
		jbe	@F

		mov	ax,NPOS

@@:		mov	TM_YVal,ax

YDivOv:

;----------------------------
;* read "coolie hat" position
;----------------------------

		test	TM_CoolieHat,1
		_JZ	SkipCoolieHat

		mov	al,TM_CoolieNew
		mov	TM_CoolieOld,al

		mov	TM_CooliePos,0
		mov	TM_CoolieVal,0
		mov	TM_CoolieNew,0

		mov	ah,JOY_B_YPOS
		call	ReadAnalogue
		_JC	TMTimeout
		mov	TM_CooliePos,ax

;* coolie up

		mov	ax,TM_CoolieRt
		sub	ax,TM_CoolieUp
		MINM	ax
		shr	ax,1
		add	ax,TM_CoolieUp

		cmp	TM_CooliePos,ax
		ja	@F

		mov	TM_CoolieNew,COOLIE_UP

		jmp	ContCoolie

;* coolie right

@@:		mov	ax,TM_CoolieDn
		sub	ax,TM_CoolieRt
		MINM	ax
		shr	ax,1
		add	ax,TM_CoolieRt

		cmp	TM_CooliePos,ax
		ja	@F

		mov	TM_CoolieNew,COOLIE_RT

		jmp	ContCoolie

;* coolie down

@@:		mov	ax,TM_CoolieLt
		sub	ax,TM_CoolieDn
		MINM	ax
		shr	ax,1
		add	ax,TM_CoolieDn

		cmp	TM_CooliePos,ax
		ja	@F

		mov	TM_CoolieNew,COOLIE_DN

		jmp	ContCoolie

;* coolie left

@@:		mov	ax,TM_CoolieCn
		sub	ax,TM_CoolieLt
		MINM	ax
		shr	ax,1
		add	ax,TM_CoolieLt

		cmp	TM_CooliePos,ax
		ja	@F

		mov	TM_CoolieNew,COOLIE_LT

@@:

;---------------------------
ContCoolie	LABEL	NEAR
;---------------------------

;* check for coolie hat change

		mov	al,TM_CoolieNew
		cmp	al,TM_CoolieOld
		je	@F

		mov	TM_CoolieVal,al

;* test for fire buttons pressed

@@:		mov	dx,GAME_PORT
		in	al,dx

		test	al,TM_FIRE1
		jnz	@F
		mov	JoyA_Fire1,1

		test	OldJoyA_Fire1,1
		jnz	@F
		mov	JoyA_JustFired1,1

@@:		test	al,TM_FIRE2
		jnz	@F
		mov	JoyA_Fire2,1

		test	OldJoyA_Fire2,1
		jnz	@F
		mov	JoyA_JustFired2,1

@@:		test	al,TM_FIRE3
		jnz	@F
		mov	JoyB_Fire1,1

		test	OldJoyB_Fire1,1
		jnz	@F
		mov	JoyB_JustFired1,1

@@:		test	al,TM_FIRE4
		jnz	@F
		mov	JoyB_Fire2,1

		test	OldJoyB_Fire2,1
		jnz	@F
		mov	JoyB_JustFired2,1

@@:

SkipCoolieHat:	

;--------------------
;* sort joystick vars
;--------------------

		mov	ax,TM_XVal
		mov	JoyA_XVal,ax

		mov	ax,TM_YVal
		mov	JoyA_YVal,ax

		ret

;---------------------------
TMTimeout	LABEL	NEAR
;---------------------------

		mov	JoyA_Flag,0

;---------------------------
TMOpenCct	LABEL	NEAR
;---------------------------

		xor	ax,ax

		mov	TM_XPos,ax
		mov	TM_YPos,ax
		mov	TM_XVal,ax
		mov	TM_YVal,ax

		ret

ReadThrust	ENDP

LIBCODE		ENDS

;============================================================================

		END

