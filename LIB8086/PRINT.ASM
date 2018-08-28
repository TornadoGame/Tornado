;****************************************************************************
;*
;* PRINT.ASM
;*
;* 01.08.1989 - KJB
;* 29.08.1991 - KJB - Character type 3 added.
;* 30.08.1991 - KJB - P_BLK and P_RED removed.
;*                    P_TITLE and P_TEXT added.
;*                    P_ULINE / P_ULEND added.
;*                    P_RECT / P_REND added.
;* 06.05.1992 - KJB - PD_VGA added.
;*                    PV_PDEG added.
;*                    PV_RNG added.
;*                    PV_ETA added.
;*
;* Print$ Functions
;* ================
;*
;* (-) = not implemented
;* (E) = implemented as an equate
;* (M) = implemented as a macro
;*
;* Miscellaneous functions
;* =======================
;*
;*  0 - P_END   :(M) terminate string
;*  1 - P_INPUT :(M) set InputMode to following byte
;*  2 - P_OVER0 :(M) set 'print over' function off
;*  3 - P_OVER1 :(M) set 'print over' function on
;*  4 - P_CHAR1 :(M) use character type 1 (7*9)
;*  5 - P_CHAR2 :(M) use character type 2 (3*5)
;*  6 - P_CHAR3 :(M) use character type 3 (5*9)
;*  7 - P_CHAR4 :(-) reserved
;*  8 - P_FONT1 :(-) set character type 1 font pointer to following offset
;*  9 - P_FONT2 :(-) set character type 2 font pointer to following offset
;* 10 - P_FONT3 :(-) set character type 3 font pointer to following offset
;* 11 - P_FONT4 :(-) reserved
;* 12 - P_RPT   :(-) repeat character (1st byte counter, 2nd byte character)
;* 13 - P_CRSR  :(M) set cursor type to following character 
;* 14 - P_HEXAT :(M) set hexadecimal print attribute to following byte
;* 15 - P_DECAT :(M) set decimal print attribute to following byte
;* 16 - P_BCDAT :(M) set packed bcd print attribute to following byte
;* 17 - P_DEFCL :(M) set fore / back colours to default values
;* 18 - P_TITLE :(M) set CHAR3, OVER0 and attributes for dialog box title
;* 19 - P_TEXT  :(M) set CHAR3, OVER0 and attributes for dialog box text
;* 20 - P_ULINE :(M) underline start
;* 21 - P_ULEND :(M) underline end
;* 22 - P_RECT  :(M) surround text with rectangle
;* 23 - P_REND  :(M) rectangle end
;* 24 -         :(-)
;* 25 -         :(-)
;* 26 -         :(-)
;* 27 -         :(-)
;* 28 -         :(-)
;* 29 -         :(-)
;* 30 - P_NOP   :(M) no operation
;* 31 - P_EXT   :(E) use extended codes
;* 
;* Extended Codes - Direct functions
;* =================================
;* 
;*  0 -         :(-)
;*  1 -         :(-)
;*  2 - PD_HEXB :(M) print hex byte
;*  3 - PD_HEXW :(M)  ..   ..  word
;*  4 - PD_HEXL :(M)  ..   ..  long
;*  5 - PD_DECB :(M) print decimal byte
;*  6 - PD_DECW :(M)  ..     ..    word
;*  7 - PD_DECL :(-)  ..     ..    long
;*  8 - PD_BCDB :(-) print packed bcd byte
;*  9 - PD_BCDW :(-)  ..     ..   ..  word
;* 10 - PD_BCDL :(-)  ..     ..   ..  long
;* 11 -         :(-)
;* 12 -         :(-)
;* 13 -         :(-)
;* 14 -         :(-)
;* 15 -         :(-)
;* 16 - PD_X    :(M) set print x position (word)
;* 17 - PD_Y    :(M) set print y position (word)
;* 18 - PD_XY   :(M) set print x and y positions (words)
;* 19 - PD_XMOV :(M) add signed word to x print position
;* 20 - PD_YMOV :(M) add signed word to y print position
;* 21 - PD_XYMV :(M) add signed words to x and y print positions
;* 22 - PD_ATTR :(M) set foreground / background colours (8 bytes)
;* 23 - PD_SSPR :(-) print "shifted" sprite
;* 24 - PD_MSPR :(-) print "masked" sprite
;* 25 - PD_QSPR :(M) print "quick" sprite
;* 26 - PD_LINE :(M) draw line
;* 27 - PD_VGA  :(M) set VGA foreground / background colours
;* 28 - PD_PDEG :(-) print pseudo degrees as real degrees
;* 29 - PD_RNG  :(-) print range (*10) as "ddd.d"
;* 30 - PD_ETA  :(-) print time as "mm:ss"
;* 31 -         :(-)
;* 
;* Extended Codes - Variable functions
;* ===================================
;* 
;* 32 - PV_CHR  :(M) print character
;* 33 - PV_STR  :(M) print string
;* 34 - PV_HEXB :(M) print hex byte
;* 35 - PV_HEXW :(M)  ..   ..  word
;* 36 - PV_HEXL :(M)  ..   ..  long
;* 37 - PV_DECB :(M) print decimal byte
;* 38 - PV_DECW :(M)  ..     ..    word
;* 39 - PV_DECL :(-)  ..     ..    long
;* 40 - PV_BCDB :(-) print packed bcd byte
;* 41 - PV_BCDW :(-)  ..     ..   ..  word
;* 42 - PV_BCDL :(-)  ..     ..   ..  long
;* 43 -         :(-)
;* 44 -         :(-)
;* 45 -         :(-)
;* 46 -         :(-)
;* 47 -         :(-)
;* 48 - PV_X    :(M) set print x position (word)
;* 49 - PV_Y    :(M) set print y position (word)
;* 50 - PV_XY   :(M) set print x and y posiotions (words)
;* 51 - PV_XMOV :(-) add signed word to x print position
;* 52 - PV_YMOV :(-) add signed word to y print position
;* 53 - PV_XYMV :(-) add signed words to x and y print positions
;* 54 - PV_ATTR :(M) set foreground / background colours (8 bytes)
;* 55 - PV_SSPR :(-) print "shifted" sprite
;* 56 - PV_MSPR :(-) print "masked" sprite
;* 57 - PV_QSPR :(-) print "quick" sprite
;* 58 - PV_LINE :(-) draw line
;* 59 - PV_VGA  :(-) set VGA foreground / background colours
;* 60 - PV_PDEG :(M) print pseudo degrees as real degrees
;* 61 - PV_RNG  :(M) print range (*10) as "ddd.d"
;* 62 - PV_ETA  :(M) print time as "mm:ss"
;* 63 -         :(-)
;* 
;* Extended Codes - Pointer functions
;* ==================================
;* 
;* 64 - PP_CHR  :(-) print character
;* 65 - PP_STR  :(M) print string
;* 66 - PP_HEXB :(-) print hex byte
;* 67 - PP_HEXW :(-)  ..   ..  word
;* 68 - PP_HEXL :(-)  ..   ..  long
;* 69 - PP_DECB :(-) print decimal byte
;* 70 - PP_DECW :(M)  ..     ..    word
;* 71 - PP_DECL :(-)  ..     ..    long
;* 72 - PP_BCDB :(-) print packed bcd byte
;* 73 - PP_BCDW :(-)  ..     ..   ..  word
;* 74 - PP_BCDL :(-)  ..     ..   ..  long
;* 75 -         :(-)
;* 76 -         :(-)
;* 77 -         :(-)
;* 78 -         :(-)
;* 79 -         :(-)
;* 80 - PP_X    :(-) set print x position (word)
;* 81 - PP_Y    :(-) set print y position (word)
;* 82 - PP_XY   :(-) set print x and y posiotions (words)
;* 83 - PP_XMOV :(-) add signed word to x print position
;* 84 - PP_YMOV :(-) add signed word to y print position
;* 85 - PP_XYMV :(-) add signed words to x and y print positions
;* 86 - PP_ATTR :(M) set foreground / background colours (8 bytes)
;* 87 - PP_SSPR :(-) print "shifted" sprite
;* 88 - PP_MSPR :(-) print "masked" sprite
;* 89 - PP_QSPR :(-) print "quick" sprite
;* 90 - PP_LINE :(-) draw line
;* 91 - PP_VGA  :(-) set VGA foreground / background colours
;* 92 - PP_PDEG :(-) print pseudo degrees as real degrees
;* 93 - PP_RNG  :(-) print range (*10) as "ddd.d"
;* 94 - PP_ETA  :(-) print time as "mm:ss"
;* 95 -         :(-)
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	Print$
		PUBLIC	PrintChar
		PUBLIC	PrintHexByte
		PUBLIC	PrintHexWord
		PUBLIC	PrintHexLong
		PUBLIC	PrintDecByte
		PUBLIC	PrintDecWord

		PUBLIC	CharType
		
		PUBLIC	HexAttr
		PUBLIC	DecAttr
		PUBLIC	BCDAttr

		PUBLIC	CHAR_TYPE1
		PUBLIC	CHAR_TYPE2
		PUBLIC	CHAR_TYPE3

		EXTRN	SetAttributes:FAR		
		EXTRN	PrintChar1:FAR
		EXTRN	PrintChar2:FAR
		EXTRN	PrintChar3:FAR
		EXTRN	SSprite:FAR
		EXTRN	MSprite:FAR
		EXTRN	QSprite:FAR
		EXTRN	LineDraw:FAR
		EXTRN	HLineDraw:FAR
		EXTRN	DrawRectangle:FAR

		EXTRN	PrtLn:WORD
		EXTRN	PrtCl:WORD
		EXTRN	CharSetPtr1:WORD
		EXTRN	CharSetPtr2:WORD
		EXTRN	Sprite:WORD
		EXTRN	SpriteX:WORD
		EXTRN	SpriteY:WORD
		EXTRN	SpritePtr:WORD

		EXTRN	PrintOver:BYTE
		EXTRN	InputMode:BYTE
		EXTRN	CursorChar:BYTE
		EXTRN	ForeCol:BYTE
		EXTRN	BackCol:BYTE

;============================================================================

		INCLUDE	USEFUL.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

CHAR_TYPE1	EQU	0	  	;7*9 characters
CHAR_TYPE2	EQU	4		;3*5 characters
CHAR_TYPE3	EQU	8		;5*9 characters

;* HexAttr - b0: print leading '$'
;*           b1: print leading '0'
;*           b2: print trailing 'h'
;*           b3: print trailing ' '

HexAttr		DB	1110b,0

;* DecAttr - b0: ) digit field width
;*           b1: ) 1 - 15 (0 = use default width)
;*           b2: ) if the number is signed then an additional
;*           b3: ) character is printed for the sign
;*           b4: 0 = right justify, 1 = left justify
;*           b5: 0 = leading spaces, 1 = leading zeroes (if right justified)
;*           b6: 0 = use ' ' for '+', 1 = use '+' for '+' (if positive signed)
;*           b7: 0 = unsigned, 1 = signed

DecAttr		DB	0,0

BCDAttr		DB	0,0

CharType	DW	CHAR_TYPE1

_PrintChar	DD	FAR PTR PrintChar1
		DD	FAR PTR PrintChar2
		DD	FAR PTR PrintChar3

DefaultCols	DB	0ffh,000h,0ffh,000h,0ffh,000h,00fh,000h

DialogTitle	DB	0ffh,000h,0ffh,000h,0ffh,000h,00fh,000h

DialogText	DB	000h,0ffh,000h,0ffh,000h,077h,000h,007h

HexChars	DB	"0123456789ABCDEF"

LeadingChar	DB	' ',0,'0',0

SignChar	DB	0,0,0,0,' ','-','+','-'

NumBuffer	DB	16 DUP(0)

TmpPrtLn	DW	0
TmpPrtCl	DW	0

;* sprite types

S_SPRITE	EQU	0
M_SPRITE	EQU	4
Q_SPRITE	EQU	8

SpriteType	DD	SSprite
		DD	MSprite
		DD	QSprite

Print$Fn	DW	P_END		; 0
		DW	P_INPUT		; 1
		DW	P_OVER0		; 2
		DW	P_OVER1		; 3
		DW	P_CHAR1		; 4
		DW	P_CHAR2		; 5
		DW	P_CHAR3		; 6
		DW	P_END		; 7
		DW	P_END		; 8
		DW	P_END		; 9
		DW	P_END		;10
		DW	P_END		;11
		DW	P_END		;12
		DW	P_CRSR		;13
		DW	P_HEXAT		;14
		DW	P_DECAT		;15
		DW	P_BCDAT		;16
		DW	P_DEFCL		;17
		DW	P_TITLE		;18
		DW	P_TEXT		;19
		DW	P_ULINE		;20
		DW	P_ULEND		;21
		DW	P_RECT		;22
		DW	P_REND		;23
		DW	P_END		;24
		DW	P_END		;25
		DW	P_END		;26
		DW	P_END		;27
		DW	P_END		;28
		DW	P_END		;29
		DW	P_NOP		;30
		DW	P_EXT		;31
			   
ExtPrint$Fn	DW	P_END		; 0
		DW	P_END		; 1
		DW	PD_HEXB		; 2
		DW	PD_HEXW		; 3
		DW	PD_HEXL		; 4
		DW	PD_DECB		; 5
		DW	PD_DECW		; 6
		DW	P_END		; 7
		DW	P_END		; 8
		DW	P_END		; 9
		DW	P_END		;10
		DW	P_END		;11
		DW	P_END		;12
		DW	P_END		;13
		DW	P_END		;14
		DW	P_END		;15
		DW	PD_X		;16
		DW	PD_Y		;17
		DW	PD_XY		;18
		DW	PD_XMOV		;19
		DW	PD_YMOV		;20
		DW	PD_XYMV		;21
		DW	PD_ATTR		;22
		DW	P_END		;23
		DW	P_END		;24
		DW	PD_QSPR		;25
		DW	PD_LINE		;26
		DW	PD_VGA		;27
		DW	P_END		;28
		DW	P_END		;29
		DW	P_END		;30
		DW	P_END		;31

		DW	PV_CHR		;32
		DW	PV_STR		;33
		DW	PV_HEXB		;34
		DW	PV_HEXW		;35
		DW	PV_HEXL		;36
		DW	PV_DECB		;37 
		DW	PV_DECW		;38
		DW	P_END		;39
		DW	P_END		;40
		DW	P_END		;41
		DW	P_END		;42
		DW	P_END		;43
		DW	P_END		;44
		DW	P_END		;45
		DW	P_END		;46
		DW	P_END		;47
		DW	PV_X		;48
		DW	PV_Y		;49
		DW	PV_XY		;50
		DW	P_END		;51
		DW	P_END		;52
		DW	P_END		;53
		DW	PV_ATTR		;54
		DW	P_END		;55
		DW	P_END		;56
		DW	P_END		;57
		DW	P_END		;58
		DW	P_END		;59
		DW	PV_PDEG		;60
		DW	PV_RNG		;61
		DW	PV_ETA		;62
		DW	P_END		;63
		
		DW	P_END		;64
		DW	PP_STR		;65
		DW	P_END		;66
		DW	P_END		;67
		DW	P_END		;68
		DW	P_END		;69 
		DW	PP_DECW		;70
		DW	P_END		;71
		DW	P_END		;72
		DW	P_END		;73
		DW	P_END		;74
		DW	P_END		;75
		DW	P_END		;76
		DW	P_END		;77
		DW	P_END		;78
		DW	P_END		;79
		DW	P_END		;80
		DW	P_END		;81
		DW	P_END		;82
		DW	P_END		;83
		DW	P_END		;84
		DW	P_END		;85
		DW	PP_ATTR		;86
		DW	P_END		;87
		DW	P_END		;88
		DW	P_END		;89
		DW	P_END		;90
		DW	P_END		;91
		DW	P_END		;92
		DW	P_END		;93
		DW	P_END		;94
		DW	P_END		;95

MAX_EXT_FN	EQU	95

DATA		ENDS

;============================================================================

LIBCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:LIBCODE
		ASSUME DS:DATA

;* Print$ - print string of characters
;*
;* pass: si -> ASCIIZ string
;*       normal PrintChar vars
;* ret : si -> end of string + 1
;* kill: flags
;* note: This routine is RECURSIVE.

Print$		PROC	FAR

		push	ax
		push	bx
		push	cx
		push	dx
		push	di
		push	bp

Print$Loop:	lodsb
		cmp	al,' '		;print function?
		jb	SortPrint$Fn	;yes ->
		call	FAR PTR PrintChar
		jmp	Print$Loop

SortPrint$Fn:	mov	bl,al
		xor	bh,bh
		shl	bx,1
		jmp	Print$Fn[bx]

;* Print$ functions

P_END:		pop	bp
		pop	di
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		ret

P_INPUT:	lodsb
		mov	InputMode,al
		jmp	Print$Loop
	
P_OVER0:	mov	PrintOver,0
		jmp	Print$Loop

P_OVER1:	mov	PrintOver,1
		jmp	Print$Loop

P_CHAR1:	mov	CharType,CHAR_TYPE1
		jmp	Print$Loop
		
P_CHAR2:	mov	CharType,CHAR_TYPE2
		jmp	Print$Loop

P_CHAR3:	mov	CharType,CHAR_TYPE3
		jmp	Print$Loop

P_CRSR:		lodsb
		mov	CursorChar,al
		jmp	Print$Loop
	
P_HEXAT:	lodsb
		mov	HexAttr,al
		jmp	Print$Loop
		
P_DECAT:	lodsb
		mov	DecAttr,al
		jmp	Print$Loop
	
P_BCDAT:	lodsb
		mov	BCDAttr,al
		jmp	Print$Loop
	
P_DEFCL:	push	si
		mov	si,OFFSET DefaultCols
		call	SetAttributes
		pop	si
		jmp	Print$Loop

P_TITLE:  	mov	CharType,CHAR_TYPE3
		mov	PrintOver,0
		push	si
		mov	si,OFFSET DialogTitle
		call	SetAttributes
		pop	si
		jmp	Print$Loop

P_TEXT:		mov	CharType,CHAR_TYPE3
		mov	PrintOver,0
		push	si
		mov	si,OFFSET DialogText 
		call	SetAttributes
		pop	si
		jmp	Print$Loop

P_ULINE:     	mov	ax,PrtLn
		mov	TmpPrtLn,ax
		mov	ax,PrtCl
		mov	TmpPrtCl,ax
		jmp	Print$Loop

P_ULEND:	cmp	CharType,CHAR_TYPE2
		je	@F

		lodsb
		mov	cx,TmpPrtCl
		mov	bl,BYTE PTR TmpPrtLn
		add	bl,9
		mov	dx,PrtCl
		sub	dx,2
		push	si
		call	HLineDraw
		pop	si
		jmp	Print$Loop

@@:		lodsb
		mov	cx,TmpPrtCl
		mov	bl,BYTE PTR TmpPrtLn
		add	bl,6
		mov	dx,PrtCl
		sub	dx,2
		push	si
		call	HLineDraw
		pop	si
		jmp	Print$Loop

P_RECT:     	mov	ax,PrtLn
		mov	TmpPrtLn,ax
		mov	ax,PrtCl
		mov	TmpPrtCl,ax
		jmp	Print$Loop

P_REND:		cmp	CharType,CHAR_TYPE2
		je	@F

		lodsb
		mov	cx,TmpPrtCl
		sub	cx,3
		mov	bl,BYTE PTR TmpPrtLn
		sub	bl,3
		mov	dx,PrtCl
		add	dx,1
		mov	bh,bl
		add	bh,12
		push	si
		call	DrawRectangle
		pop	si
		jmp	Print$Loop

@@:		lodsb
		mov	cx,TmpPrtCl
		sub	cx,2
		mov	bl,BYTE PTR TmpPrtLn
		sub	bl,2
		mov	dx,PrtCl
		mov	bh,bl
		add	bh,8
		push	si
		call	DrawRectangle
		pop	si
		jmp	Print$Loop

P_NOP:		jmp	Print$Loop
	
P_EXT:		lodsb			;fetch extended code
		cmp	al,MAX_EXT_FN	;in range?
		jbe	ExtOk		;yes ->
		jmp	P_END		;terminate string ->
ExtOk:		mov	bl,al
		xor	bh,bh
		shl	bx,1
		jmp	ExtPrint$Fn[bx]
	
;* extended Print$ functions

PV_CHR:		lodsw
		mov	bx,ax
		mov	al,[bx]
		call	FAR PTR PrintChar
		jmp	Print$Loop

PV_STR:		lodsw
		push	si
		mov	si,ax
		call	Print$
		pop	si
		jmp	Print$Loop

PP_STR:		lodsw
		push	si
		mov	si,ax
		mov	ax,[si]
		mov	si,ax
	       	call	Print$
		pop	si
		jmp	Print$Loop

PD_HEXB:	lodsb
		call	FAR PTR PrintHexByte
		jmp	Print$Loop

PV_HEXB:	lodsw
		mov	bx,ax
		mov	al,[bx]
		call	FAR PTR PrintHexByte
		jmp	Print$Loop

PD_HEXW:	lodsw
		call	FAR PTR PrintHexWord
		jmp	Print$Loop

PV_HEXW:	lodsw
		mov	bx,ax
		mov	ax,[bx]
		call	FAR PTR PrintHexWord
		jmp	Print$Loop

PD_HEXL:	lodsw
		mov	dx,ax
		lodsw
		xchg	ax,dx
		call	FAR PTR PrintHexLong
		jmp	Print$Loop

PV_HEXL:	lodsw
		mov	bx,ax
		mov	ax,[bx]
		mov	dx,[bx+2]
		call	FAR PTR PrintHexLong
		jmp	Print$Loop

PD_DECB:	lodsb
		call	FAR PTR PrintDecByte
		jmp	Print$Loop

PV_DECB:	lodsw
		mov	bx,ax
		mov	al,[bx]
		call	FAR PTR PrintDecByte
		jmp	Print$Loop

PD_DECW:	lodsw
		call	FAR PTR PrintDecWord
		jmp	Print$Loop

PV_DECW:	lodsw
		mov	bx,ax
		mov	ax,[bx]
		call	FAR PTR PrintDecWord
		jmp	Print$Loop

PP_DECW:	lodsw
		mov	bx,ax
		mov	ax,[bx]
		mov	bx,ax
		mov	ax,[bx]
		call	FAR PTR PrintDecWord
		jmp	Print$Loop

PD_X:		lodsw
		mov	PrtCl,ax
		jmp	Print$Loop

PV_X:		lodsw
		mov	bx,ax
		mov	ax,[bx]
		mov	PrtCl,ax
		jmp	Print$Loop

PD_Y:		lodsw
		mov	PrtLn,ax
		jmp	Print$Loop

PV_Y:		lodsw
		mov	bx,ax
		mov	ax,[bx]
		mov	PrtLn,ax
		jmp	Print$Loop

PD_XY:		lodsw
		mov	PrtCl,ax
		lodsw
		mov	PrtLn,ax
		jmp	Print$Loop

PV_XY:		lodsw
		mov	bx,ax
		mov	ax,[bx]
		mov	PrtCl,ax
		lodsw
		mov	bx,ax
		mov	ax,[bx]
		mov	PrtLn,ax
		jmp	Print$Loop

PD_XMOV:	lodsw
		add	PrtCl,ax
		jmp	Print$Loop

PD_YMOV:  	lodsw
	       	add	PrtLn,ax
		jmp	Print$Loop

PD_XYMV:  	lodsw
		add	PrtCl,ax
		lodsw
		add	PrtLn,ax
		jmp	Print$Loop

PD_ATTR:	call	SetAttributes
		add	si,8
		jmp	Print$Loop

PV_ATTR:	lodsw
		push	si	
		mov	si,ax
		call	SetAttributes
		pop	si
		jmp	Print$Loop

PP_ATTR:	lodsw
		push	si	
		mov	si,ax
		mov	ax,[si]
		mov	si,ax
		call	SetAttributes
		pop	si
		jmp	Print$Loop

PD_SSPR:	mov	bx,S_SPRITE
		jmp	ContDSprite

PD_MSPR:	mov	bx,M_SPRITE
		jmp	ContDSprite

PD_QSPR:	mov	bx,Q_SPRITE

ContDSprite:	push	si
		call	SpriteType[bx]
		pop	si
		add	si,6
		jmp	Print$Loop

PD_LINE:	mov	al,[si+0]	;col
		mov	cx,[si+2]	;x1
		mov	bl,[si+4]	;y1
		mov	dx,[si+6]	;x2
		mov	bh,[si+8]	;y2
		push	si
		call	LineDraw
		pop	si
		add	si,10
		jmp	Print$Loop

PD_VGA:		lodsb
		mov	ah,al
		mov	WORD PTR ForeCol,ax
		lodsb
		mov	ah,al
		mov	WORD PTR BackCol,ax
		jmp	Print$Loop

PV_PDEG:	push	WORD PTR DecAttr
		lodsw
		mov	bx,ax
		mov	ax,[bx]
		mov	dx,23040
		imul	dx
		FRACADJ	ax
		jnz	@F
		mov	ax,360
@@:		mov	DecAttr,00100011b	;(unsigned, 3 digits, leading zeroes)
		call	FAR PTR PrintDecWord
		pop	WORD PTR DecAttr
		jmp	Print$Loop

PV_RNG:		push	WORD PTR DecAttr
		lodsw
		mov	bx,ax
		mov	ax,[bx]
		xor	dx,dx
		mov	bx,10
		div	bx
		push	dx
		mov	DecAttr,00000011b	;(unsigned, 3 digits, leading spaces)
		call	FAR PTR PrintDecWord
		mov	al,'.'
		call	FAR PTR PrintChar
		pop	ax
		add	al,'0'
		call	FAR PTR PrintChar
		pop	WORD PTR DecAttr
		jmp	Print$Loop

PV_ETA:		push	WORD PTR DecAttr
		lodsw
		mov	bx,ax
		mov	ax,[bx]
		cmp	ax,(60*60)-1
		jbe	@F
		mov	ax,(60*60)-1
@@:		mov	bl,60
		div	bl
		mov	DecAttr,00000010b	;(unsigned, 2 digits, leading spaces)
		call	FAR PTR PrintDecByte
		mov	al,':'
		call	FAR PTR PrintChar
		mov	al,ah
		mov	DecAttr,00100010b	;(unsigned, 2 digits, leading zeroes)
		call	FAR PTR PrintDecByte
		pop	WORD PTR DecAttr
		jmp	Print$Loop

Print$		ENDP

;----------------------------------------------------------------------------

;* PrintChar - print ASCII character
;*
;* pass: al = ASCII
;*       CharType
;*       PrtLn
;*       PrtCl
;*       ForeCol
;*       BackCol
;*       PrintOver
;* ret : PrtCl modified
;* kill: flags
;* note: PrtCl is rounded down to 4 pixel steps (effectively 80 columns).
;*       No checks are made for PrtLn and PrtCl being off screen.

PrintChar	PROC	FAR

		push	bp
		mov	bp,CharType
		call	_PrintChar[bp]
		pop	bp
		ret
	
PrintChar	ENDP
		
;----------------------------------------------------------------------------

;* PrintHexByte - print hexadecimal byte
;*
;* pass: al = hex byte
;*       HexAttr
;*       normal PrintChar vars
;* ret : nothing
;* kill: flags

PrintHexByte	PROC	FAR

		push	ax
		push	bx
		push	cx

		mov	cl,al
		call	HexHeader
		mov	al,cl
		call	HexByte
		call	HexFooter

		pop	cx
		pop	bx
		pop	ax
		ret

PrintHexByte	ENDP				
		
;----------------------------------------------------------------------------

;* PrintHexWord - print hexadecimal word
;*
;* pass: ax = hex word
;*       HexAttr
;*       normal PrintChar vars
;* ret : nothing
;* kill: flags

PrintHexWord	PROC	FAR

		push	ax
		push	bx
		push	cx

		mov	cx,ax
		call	HexHeader
		mov	al,ch
		call	HexByte
		mov	al,cl
		call	HexByte
		call	HexFooter

		pop	cx
		pop	bx
		pop	ax
		ret

PrintHexWord	ENDP				
	
;----------------------------------------------------------------------------

;* PrintHexLong - print hexadecimal lond
;*
;* pass: dx, ax = hex long
;*       HexAttr
;*       normal PrintChar vars
;* ret : nothing
;* kill: flags

PrintHexLong	PROC	FAR

		push	ax
		push	bx
		push	cx

		mov	cx,ax
		call	HexHeader
		mov	al,dh
		call	HexByte
		mov	al,dl
		call	HexByte
		mov	al,ch
		call	HexByte
		mov	al,cl
		call	HexByte
		call	HexFooter
		
		pop	cx
		pop	bx
		pop	ax
		ret

PrintHexLong	ENDP				

;----------------------------------------------------------------------------

;* HexHeader - print hex number header
;*
;* pass: HexAttr
;* ret : nothing 
;* kill: ax, flags

HexHeader	PROC	NEAR

		mov	ah,HexAttr
		test	ah,0001b	;leading '$'?
		jz	NoHex_$
		mov	al,'$'
		call	PrintChar
NoHex_$:  	test	ah,0010b	;leading '0'?
		jz	NoHex_0
		mov	al,'0'
		call	PrintChar
NoHex_0:  	ret

HexHeader	ENDP
	
;----------------------------------------------------------------------------

;* HexByte - print hex byte
;* 
;* pass: al = hex byte
;* ret : nothing
;* kill: ax, bx, flags

HexByte		PROC	NEAR

		mov	bx,OFFSET HexChars
		mov	ah,al
		shr	al,1
		shr	al,1
		shr	al,1
		shr	al,1
		xlat
		call	PrintChar
		mov	al,ah
		and	al,00fh
		xlat
		call	PrintChar
		ret

HexByte		ENDP

;----------------------------------------------------------------------------

;* HexFooter - print hex number footer
;*
;* pass: HexAttr
;* ret : nothing 
;* kill: ax, flags

HexFooter	PROC	NEAR

		mov	ah,HexAttr
		test	ah,0100b	;trailing 'h'?
		jz	NoHex_h
		mov	al,'h'
		call	PrintChar
NoHex_h: 	test	ah,1000b	;trailing ' '?
		jz	NoHex_Sp
		mov	al,' '
		call	PrintChar
NoHex_Sp:	ret

HexFooter	ENDP

;----------------------------------------------------------------------------

;* PrintDecByte - print decimal byte	
;*
;* pass: al = dec byte
;*       DecAttr
;*       normal PrintChar vars
;* ret : nothing
;* kill: flags

PrintDecByte	PROC	FAR

		push 	ax
		push	bx
		push	cx
	
 		mov	bl,DecAttr	;attribute flags
		mov	cx,3		;default digit field width	
		
		mov	bh,al
		and	al,bl		;b7 = 1 if negative and signed
		cbw
		mov	al,bh		;ax = decimal word
		jmp	PrintDecCom	;use PrintDecWord routime ->

PrintDecByte	ENDP

;----------------------------------------------------------------------------

;* PrintDecWord - print decimal word
;*
;* pass: ax = dec word
;*       DecAttr
;*       normal PrintChar vars
;* ret : nothing
;* kill: flags

PrintDecWord	PROC	FAR

		push 	ax
		push	bx
		push	cx
	
 		mov	bl,DecAttr	;attribute flags
		mov	cx,5		;default digit field width	
		
PrintDecCom:	push	dx
		push	si
		push	di

;* set digit field width

		test	bl,1111b	;use default digit field width?
		jz	DefaultWidth	;yes ->
		mov	cx,bx
		and	cx,1111b	;digit field width

;* look up sign character

DefaultWidth:	xor	si,si
		xor	dx,dx		;assume unsigned
		shl	bl,1	       	;is number signed?
		jnc	UnsignedNum	;no ->
		rcl	si,1
		cwd
		xor	ax,dx
		sub	ax,dx		;two's comp
UnsignedNum:	shl	bl,1		;use ' ' or '+' for pos signed numbers
		rcl	si,1
		shl	dx,1		;sign of number
		rcl	si,1
		mov	bh,SignChar[si]		
		
;* look up leading character

		xor	si,si
		shl	bl,1		;leading char for right justified
		rcl	si,1
		shl	bl,1		;right or left justify
		rcl	si,1
		mov	bl,LeadingChar[si]

;* clear num buffer

		mov	dx,ax
		xor	ax,ax
		mov	di,OFFSET NumBuffer
		stosw
		stosw
		stosw
		stosw
		stosw
		stosw
		stosw
		stosw
		mov	ax,dx
		dec	di

;* ax = absolute number
;* bl = leading character
;* bh = sign character
;* cx = digit field width
;* di -> end of NumBuffer

;* sort out decimal number

		mov	si,10
DecDivLoop:	xor	dx,dx
		div	si		;dl = lsd
		add	dl,'0'		;convert to ASCII
		mov	[di],dl
		dec	di
		dec	cx
		test	ax,ax		;is quotient 0?
		jz	DecDivDone	;yes ->
		test	cx,cx		;all digits done?
		jnz	DecDivLoop	;no ->

;* sort out sign and leading characters

DecDivDone:	std			;<<<< AUTO-DECREMENT !!! <<<<<

		cmp	bl,'0'		;is leading char '0'?
		je	LeadingZero	;yes, sign char not required yet ->
		mov	al,bh
		stosb			;insert sign char into buffer
LeadingZero:	mov	al,bl
		rep	stosb		;insert leading chars (if any)
SkipLeadingChar:cmp	bl,'0'		;is leading char '0'?
		jne	PrintNumBuffer	;no, sign char already inserted ->
		mov	al,bh		
		stosb

;* now print the buffer

PrintNumBuffer:	cld			;<<<<< AUTO-INCREMENT !!! <<<<<

		mov	cx,16
		mov	si,OFFSET NumBuffer
PrintNumLoop:	lodsb	
		test	al,al		;null character?
		jz	NullChar	;yes ->
		call	PrintChar		
NullChar:	loop	PrintNumLoop

		pop	di
		pop	si
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		ret

PrintDecWord	ENDP

LIBCODE		ENDS

;============================================================================

		END

