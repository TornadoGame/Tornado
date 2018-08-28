;****************************************************************************
;*
;* INPUT.ASM
;*
;* Keyboard input routines.
;*
;* 14.07.1989 - KJB
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	ReadKbd
		PUBLIC	GetChar
		PUBLIC	KeyRelease
		PUBLIC	KeyPress
		PUBLIC	Input$
		PUBLIC	UpdateMenuKeys
		PUBLIC	ScanMenuKeys

		PUBLIC	CursorChar
		PUBLIC	InputMode

		EXTRN	Print$:FAR
		EXTRN	DownLoad:FAR

		EXTRN	Key:BYTE

;============================================================================

		INCLUDE	KEYS.INC
		INCLUDE	PRINT.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

InputMode	DB	INPUT_ALL,0	;(see PRINT.INC)

Filter		DW	SetChar	 	;INPUT_ALL
		DW	AlphaOnly	;INPUT_ALPHA
		DW	NumOnly		;INPUT_NUM

CursorChar	DB	127,0

TablePtr	DW	OFFSET KeyTable
		DW	OFFSET ShiftTable

KeyTable	DB	NUL,ESCP, '1', '2', '3', '4', '5', '6'	;0
		DB	'7', '8', '9', '0', '-', '=', DEL, NUL	;8
		DB	'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I'	;16
		DB	'O', 'P', '[', ']', ENT, NUL, 'A', 'S'	;24
		DB	'D', 'F', 'G', 'H', 'J', 'K', 'L', ';'	;32
		DB      "'", '\', NUL, '`', 'Z', 'X', 'C', 'V'	;40
		DB	'B', 'N', 'M', ',', '.', '/', NUL, '*'	;48
		DB	NUL, ' ', NUL, NUL, NUL, NUL, NUL, NUL	;56
		DB	NUL, NUL, NUL, NUL, NUL, NUL, NUL, NUL	;64
		DB	NUL, NUL, '-', DEL, NUL, NUL, '+', NUL	;72
		DB	NUL, NUL, NUL, DEL, NUL, NUL, NUL, NUL	;80

ShiftTable	DB	NUL,ESCP, '!', '@', '#', '$', '%', '^'	;0
		DB	'&', '*', '(', ')', '_', '+', DEL, NUL	;8
		DB	'q', 'w', 'e', 'r', 't', 'y', 'u', 'i'	;16
		DB	'o', 'p', '{', '}', ENT, NUL, 'a', 's'	;24
		DB	'd', 'f', 'g', 'h', 'j', 'k', 'l', ':'	;32
		DB      '"', '|', NUL, '~', 'z', 'x', 'c', 'v'	;40
		DB	'b', 'n', 'm', '<', '>', '?', NUL, '*'	;48
		DB	NUL, ' ', NUL, NUL, NUL, NUL, NUL, NUL	;56
		DB	NUL, NUL, NUL, NUL, NUL, NUL, NUL, NUL	;64
		DB	NUL, NUL, '-', DEL, NUL, NUL, '+', NUL	;72
		DB	NUL, NUL, NUL, DEL, NUL, NUL, NUL, NUL	;80

;* menu keys:-
;*
;*    ESC      : exit
;*    SPACE    : default option
;*    F1 .. F10: used to select options

MENUKEY		STRUC

KEY_NUM		DB	0		;key code
KEY_NEW		DB	0		;new value
KEY_OLD		DB	0		;old value

MENUKEY		ENDS

MKEY_REC_SIZE	EQU	TYPE MENUKEY

MenuKeyList	MENUKEY	<K_ESC>		;highest priority
		MENUKEY	<K_SPACE>
		MENUKEY	<K_F1>
		MENUKEY	<K_F2>
		MENUKEY	<K_F3>
		MENUKEY	<K_F4>
		MENUKEY	<K_F5>
		MENUKEY	<K_F6>
		MENUKEY	<K_F7>
		MENUKEY	<K_F8>
		MENUKEY	<K_F9>
		MENUKEY	<K_F10>		;lowest priority
		DB	-1		;list terminator

		EVEN

DATA		ENDS

;============================================================================

LIBCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:LIBCODE
		ASSUME DS:DATA

;* ReadKbd - get character from keyboard
;*
;* pass: Key[]
;* ret : cf = 1 : al = ASCII char
;*                ah = scan code
;*       cf = 0 : no character ready
;* kill: flags

ReadKbd		PROC	FAR

		push	bx
		push	cx
      		push	si

		mov	bx,0
		mov	cx,88
ReadLoop: 	mov	al,Key[bx]
		test	al,al
		jnz	KeyPressed	
ContLoop:	inc	bx
		loop	ReadLoop

		xor	ax,ax		;al = ah = 0 (cf = 0)
		jmp	ReadKbdExit
			    
KeyPressed:	mov	al,KeyTable[bx]
		cmp	al,NUL
		je	ContLoop

		mov	al,Key[K_SHIFT]	
		mov	si,ax
		and	si,0001b
		shl	si,1
		mov	si,TablePtr[si]

		mov	al,[si+bx]	;al = ASCII code
		mov	ah,bl		;ah = key code
		stc			;cf = 1

ReadKbdExit:	pop	si
		pop	cx
		pop	bx
		ret

ReadKbd		ENDP

;----------------------------------------------------------------------------

;* GetChar - get character (wait for key press)
;*
;* pass: Key[]
;* ret : al = character
;*       ah = scan code
;* kill: flags

GetChar		PROC	FAR

		call	ReadKbd		;key pressed?
		jnc	GetChar		;no ->
		ret		   

GetChar		ENDP

;----------------------------------------------------------------------------

;* KeyRelease - wait for key to be released
;*
;* pass: ah = scan code
;*       Key[]
;* ret : nothing
;* kill: al, flags

KeyRelease 	PROC	FAR

		push	bx
		mov	bl,ah
		xor	bh,bh
ReleaseLoop:	mov	al,Key[bx]
		test	al,al
		jnz	ReleaseLoop
		pop	bx
		ret

KeyRelease	ENDP

;----------------------------------------------------------------------------

;* KeyPress - wait for any key to be pressed, then wait for release
;*
;* pass: nothing
;* ret : nothing
;* kill: ax, flags

KeyPress	PROC	FAR

		call	GetChar
		call	KeyRelease
		ret

KeyPress	ENDP
 
;----------------------------------------------------------------------------

;* Input$ - input string
;*
;* pass: si -> start of string (positional data etc.)
;*       di -> start of string input field (0 terminated)
;*       InputMode
;* ret : cx = number of bytes entered
;* kill: ax, bx, dx, bp, flags

Input$		PROC	FAR

		xor	bx,bx

		call	ClearToEnd
		call	PrintInput$	;init vars (attr's, cursor char etc.)

		xor	ah,ah		;fall through first KeyRelease

InputLoop:	cmp	[di+bx],BYTE PTR 0
		je	NoCursor
		mov	al,CursorChar
		mov	[di+bx],al
				
NoCursor:	call	PrintInput$
		call	KeyRelease
		call	GetChar

		cmp	al,ESCP		;ESCaPe (clear input field)?
		je	Escape		;yes ->

		cmp	al,DEL		;DELete?
		je	Delete		;yes ->

		cmp	al,ENT		;ENTer (terminate input)?
		je	Enter		;yes ->

		mov	bp,WORD PTR InputMode
		shl	bp,1
		jmp	ds:Filter[bp]

AlphaOnly:	cmp	al,'A'
		jb	RejectChar
		cmp	al,'Z'
		jbe	SetChar
		cmp	al,'a'
		jb	RejectChar
		cmp	al,'z'
		jbe	SetChar
		jmp	RejectChar

NumOnly:	cmp	al,'0'
		jb	RejectChar
		cmp	al,'9'
		jbe	SetChar
		jmp	RejectChar

RejectChar:	jmp	InputLoop

SetChar:	cmp	[di+bx],BYTE PTR 0	
		je	SkipChar	;no room for char ->
		mov	[di+bx],al
		inc	bx
SkipChar:	jmp	InputLoop

Escape:		xor	bx,bx
		call	ClearToEnd 
		jmp	InputLoop

Delete:		test	bx,bx		;anything to DELete?
		jz	SkipDelete	;no ->
		dec	bx
		call	ClearToEnd
SkipDelete:	jmp	InputLoop

Enter:		call	ClearToEnd	;clear cursor
		call	PrintInput$
		call	KeyRelease
		mov	cx,bx
		ret

Input$		ENDP

;----------------------------------------------------------------------------

;* PrintInput$
;*
;* pass: si -> input string
;* ret : nothing
;* kill: cx, dx, bp, flags

PrintInput$	PROC	NEAR

		push	ax
		push	bx
		push	si
		push	di
		call	Print$
		call	DownLoad
		pop	di
		pop	si
		pop	bx
		pop	ax
		ret

PrintInput$	ENDP

;----------------------------------------------------------------------------

;* ClearToEnd - clear input field from cursor to end
;*
;* pass: di+bx -> cursor position
;* ret : input field cleared
;* kill: flags

ClearToEnd	PROC	NEAR

		push	bx

ClearLoop:	cmp	[di+bx],BYTE PTR 0
		je	Cleared
		mov	[di+bx],BYTE PTR ' '
		inc	bx
		jmp	ClearLoop

Cleared:	pop	bx
		ret

ClearToEnd	ENDP

;----------------------------------------------------------------------------

;* UpdateMenuKeys
;*
;* pass: Key[]
;*       MenuKeyList[]
;* ret : MenuKeyList[]
;* kill: ax, bx, si, flags

UpdateMenuKeys	PROC	FAR

		mov	bx,OFFSET Key
		mov	si,OFFSET MenuKeyList

UpdateMKeysLp:	mov	al,KEY_NUM[si]	;fetch key code
		cmp	al,-1		;end of list?
		je	UpdateMKeysExit	;yes ->

		mov	ah,KEY_NEW[si]	;fetch new key
		mov	KEY_OLD[si],ah	;set old key
		xlat			;fetch new key
		mov	KEY_NEW[si],al	;set new key

		add	si,MKEY_REC_SIZE;next key
		jmp	UpdateMKeysLp

UpdateMKeysExit:ret

UpdateMenuKeys	ENDP

;----------------------------------------------------------------------------

;* ScanMenuKeys - scan menu keys to see if any have just been pressed
;*
;* pass: MenuKeyList[]
;* ret : cf = 1 = key pressed, al = key code
;*       cf = 0 = no key pressed, al = 0
;* kill: ah, si, flags

ScanMenuKeys	PROC	FAR

		mov	si,OFFSET MenuKeyList
		
ScanMKeysLp:	mov	al,KEY_NUM[si]	;fetch key code
		cmp	al,-1		;end of list?
		je	ScanMKeysFail	;yes ->

		mov	ah,KEY_OLD[si]	
		cmp	ah,KEY_NEW[si]	;cf = 1 if old = 0 and new = 1 (only)
		jc	ScanMKeysPass	;key just pressed ->

		add	si,MKEY_REC_SIZE;next key
		jmp	ScanMKeysLp

ScanMKeysFail:	xor	al,al		;cf = 0

ScanMKeysPass:	ret

ScanMenuKeys	ENDP

LIBCODE		ENDS

;============================================================================

		END

