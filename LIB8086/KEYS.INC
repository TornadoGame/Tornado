;****************************************************************************
;*
;* KEYS.INC
;*
;* Keyboard scan code equates.
;*
;* 15.06.1989 - KJB
;* 11.09.1991 - KJB - game key structure and macros added.
;* 23.03.1992 - KJB - KCLEAR macro debugged.
;*
;****************************************************************************

;---------------------------------
;* game key structure, macros etc.
;---------------------------------

GAMEKEY		STRUCT

K_STATUS	DB	0		;current key status
K_LOCK		DB	0		;lock flag (used for toggle, debounce etc.)
K_STATE		DB	0		;key state set under interrupt

GAMEKEY		ENDS

;* KUPDATE - update game key (under interrupt)
;*
;* pass: flag = game key
;*       key1 = primary key
;*       fn   = logical function ) optional
;*       key2 = secondary key	 )    ..
;* ret : game key state
;* kill: al, flags

KUPDATE		MACRO	flag,key1,fn,key2

		mov	al,Key[key1]

		IFNB 	<fn>

	   	IFIDNI	<fn>,<_AND_>
      		and	al,Key[key2]
		ENDIF

		IFIDNI	<fn>,<_OR_>
		or	al,Key[key2]
		ENDIF

		ENDIF

		or	BYTE PTR flag[K_STATE],al

		ENDM

;* KTOGGLE - toggle game key (update once per frame)
;*
;* pass: flag = game key
;* ret : game key status, lock and state
;* kill: ax, flags

KTOGGLE		MACRO	flag

;* status = status xor (lock = 0 and state = 1)
;* lock   = state
;* state  = 0

		xor	al,al
		xchg	al,BYTE PTR flag[K_STATE]
		mov	ah,al
		xchg	ah,BYTE PTR flag[K_LOCK]
		not	ah
		and	al,ah
		xor	BYTE PTR flag[K_STATUS],al

		ENDM
		
;* KBOUNCE - debounce game key (update once per frame)
;*
;* pass: flag = game key
;* ret : game key status, lock and state
;* kill: ax, flags

KBOUNCE		MACRO	flag

;* status = (lock = 0 and state = 1)
;* lock   = state
;* state  = 0

		xor	al,al
		xchg	al,BYTE PTR flag[K_STATE]
		mov	ah,al
		xchg	ah,BYTE PTR flag[K_LOCK]
		not	ah
		and	al,ah
		mov	BYTE PTR flag[K_STATUS],al

		ENDM

;* KFOLLOW - follow game key (update once per frame)
;*
;* pass: flag = game key
;* ret : game key status and state
;* kill: al, flags

KFOLLOW		MACRO	flag

;* status = state
;* state  = 0

		xor	al,al
		xchg	al,BYTE PTR flag[K_STATE]
		mov	BYTE PTR flag[K_STATUS],al

		ENDM

;* KTEST - test game key
;*
;* pass: flag = game key
;* ret : al = key status
;*       zf = 0 (nz) = key pressed
;*       zf = 1 (z)  = key not pressed
;* kill: flags

KTEST		MACRO	flag

		mov	al,BYTE PTR flag[K_STATUS]
		test	al,al

		ENDM

;* KFETCH - fetch key value
;*
;* pass: flag = game key
;* ret : al = key status
;* kill: nothing

KFETCH		MACRO	flag

		mov	al,BYTE PTR flag[K_STATUS]

		ENDM

;* KCLEAR - clear game key
;*
;* pass: flag = game key
;* ret : game key status
;* kill: nothing

KCLEAR		MACRO	flag

		mov	BYTE PTR flag[K_STATUS],0

		ENDM

;----------------------------
;* ASCII control code equates
;----------------------------

NUL		EQU	0
DEL		EQU	8
ENT		EQU	13
ESCP		EQU	27

;-------------------
;* scan code equates
;-------------------

K_ESC		EQU	1
K_SPACE		EQU	57
K_DEL1		EQU	14
K_DEL2		EQU	83
K_DEL3		EQU	75
K_SYSREQ    	EQU	84
K_NUMLOCK	EQU	69
K_CAPSLOCK	EQU	58
K_CTRL		EQU	29
K_SHIFT    	EQU	42
K_SHIFT1    	EQU	42		;mapped to K_SHIFT2
K_SHIFT2    	EQU	54		;mapped to K_SHIFT1
K_ENTER		EQU	28
K_BACKSPACE	EQU	14
K_ALT		EQU	56
K_TAB		EQU	15
K_PLUS		EQU	13		;mapped to K_PAD_PLUS
K_MINUS		EQU	12		;mapped to K_PAD_MINUS
K_LESSTHAN	EQU	51
K_GRTRTHAN	EQU	52
K_HASH		EQU	43
K_OPN_SQ_BRKT	EQU	26
K_CLS_SQ_BRKT	EQU	27
K_APOSTROPHE	EQU	40
K_SEMICOLON	EQU	39
K_BACKSLASH	EQU	86

K_PAD_INS	EQU	82
K_PAD_DEL	EQU	83
K_PAD_PLUS	EQU	78		;mapped to K_PLUS
K_PAD_MINUS	EQU	74		;mapped to K_MINUS
K_PAD_STAR	EQU	55

K_HOME		EQU	71
K_END		EQU	79
K_PGUP		EQU	73
K_PGDN		EQU	81

K_CRSRLF    	EQU	75
K_CRSRRT    	EQU	77
K_CRSRUP    	EQU	72
K_CRSRDN    	EQU	80

K_CENTRE	EQU	76

K_MOUSELF	EQU	71
K_MOUSERT	EQU	73

K_AMS_JOYLF	EQU	122
K_AMS_JOYRT	EQU	121
K_AMS_JOYUP	EQU	124
K_AMS_JOYDN	EQU	123
K_AMS_JOYF1	EQU	120
K_AMS_JOYF2	EQU	119

K_AMS_MOUSELF	EQU	126
K_AMS_MOUSERT	EQU	125

K_1		EQU	2
K_2		EQU	3
K_3		EQU	4
K_4		EQU	5
K_5		EQU	6
K_6		EQU	7
K_7		EQU	8
K_8		EQU	9
K_9		EQU	10
K_0		EQU	11

K_F1		EQU	59
K_F2		EQU	60
K_F3		EQU	61
K_F4		EQU	62
K_F5		EQU	63
K_F6		EQU	64
K_F7		EQU	65
K_F8		EQU	66
K_F9		EQU	67
K_F10		EQU	68
K_F11		EQU	87
K_F12		EQU	88

K_A		EQU	30
K_B		EQU	48
K_C		EQU	46
K_D		EQU	32
K_E		EQU	18
K_F		EQU	33
K_G		EQU	34
K_H		EQU	35
K_I		EQU	23
K_J		EQU	36
K_K		EQU	37
K_L		EQU	38
K_M		EQU	50
K_N		EQU	49
K_O		EQU	24
K_P		EQU	25
K_Q		EQU	16
K_R		EQU	19
K_S		EQU	31
K_T		EQU	20
K_U		EQU	22
K_V		EQU	47
K_W		EQU	17
K_X		EQU	45
K_Y		EQU	21
K_Z		EQU	44

