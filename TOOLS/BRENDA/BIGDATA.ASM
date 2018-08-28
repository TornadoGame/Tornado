;****************************************************************************
;*
;* BIGDATA.ASM
;*
;* 01.12.1989 - KJB
;*
;****************************************************************************

		PUBLIC	DiskBuffer
		PUBLIC	Screen1
		PUBLIC	Screen2
		PUBLIC	Screen3
		PUBLIC	HatchTable
		PUBLIC	HatchSprite
		PUBLIC	Col16Sprite
		PUBLIC	Col32Sprite
		PUBLIC	EGAHeader
		PUBLIC	BitPlaneBuffer
		PUBLIC	BitPlane0
		PUBLIC	BitPlane1
		PUBLIC	BitPlane2
		PUBLIC	BitPlane3

		PUBLIC	BUF_SIZE
		PUBLIC	SCR_SIZE
		PUBLIC	EGA_HDR_LEN
		PUBLIC	BIT_PLN_BUF_LEN

;============================================================================

FILE_I_O_DATA 	SEGMENT PARA PUBLIC 'DATA'

BUF_SIZE	EQU	64000

DiskBuffer	DB	BUF_SIZE DUP(?)

FILE_I_O_DATA 	ENDS

;============================================================================

SCR_SIZE	EQU	64000

SCR_1_DATA 	SEGMENT PARA PUBLIC 'DATA'

Screen1		DB	SCR_SIZE DUP(?)

SCR_1_DATA 	ENDS

SCR_2_DATA 	SEGMENT PARA PUBLIC 'DATA'

Screen2		DB	SCR_SIZE DUP(?)

SCR_2_DATA 	ENDS

SCR_3_DATA 	SEGMENT PARA PUBLIC 'DATA'

Screen3		DB	SCR_SIZE DUP(?)

;* look up hatch colours
;*
;* col (0 .. 255) * 4: use byte 0 for even x, even y
;*                     use byte 1 for  odd x, even y
;*                     use byte 2 for even x,  odd y
;*                     use byte 3 for  odd x,  odd y

HatchTable	LABEL	BYTE

col1		=	0

		REPT	16

col2		=	0

		REPT	16

		DB	col1,col2,col2,col1

col2		=	col2+1

		ENDM

col1		=	col1+1

		ENDM

SCR_3_DATA 	ENDS

;============================================================================

DATA 		SEGMENT PARA PUBLIC 'DATA'

;* ILBM header for EGA picture
;*
;* note file "BODY" length has been set to 08020h = 32800
;*
;* 200 lines * 4 planes * (40 + 1) bytes per line = 32800
;*
;* this will be the size of the uncompacted data

EGA_HDR_LEN	EQU	35*8

EGAHeader  	db	046H,04FH,052H,04DH,000H,000H,081H,030H	;FORM...0
		db	049H,04CH,042H,04DH,042H,04DH,048H,044H	;ILBMBMHD
		db	000H,000H,000H,014H,001H,040H,000H,0C8H	;.....@..
		db	000H,000H,000H,000H,004H,000H,001H,000H	;........
		db	000H,000H,005H,006H,001H,040H,000H,0C8H	;.....@..
		db	043H,04DH,041H,050H,000H,000H,000H,030H	;CMAP...0
		db	000H,000H,000H,000H,000H,0AAH,000H,0AAH	;........
		db	000H,000H,0AAH,0AAH,0AAH,000H,000H,0AAH	;........
		db	000H,0AAH,0AAH,055H,000H,0AAH,0AAH,0AAH	;...U....
		db	055H,055H,055H,055H,055H,0FFH,055H,0FFH	;UUUUU.U.
		db	055H,055H,0FFH,0FFH,0FFH,055H,055H,0FFH	;UU...UU.
		db	055H,0FFH,0FFH,0FFH,055H,0FFH,0FFH,0FFH	;U...U...
		db	044H,050H,050H,056H,000H,000H,000H,068H	;DPPV...h
		db	000H,000H,000H,000H,000H,000H,000H,000H	;........
		db	001H,068H,000H,000H,001H,040H,000H,0C8H	;.h...@..
		db	000H,002H,000H,05AH,000H,080H,000H,000H	;...Z....
		db	001H,090H,000H,000H,001H,090H,000H,000H	;........
		db	000H,000H,000H,000H,000H,000H,000H,000H	;........
		db	000H,000H,000H,000H,000H,000H,000H,000H	;........
		db	000H,000H,000H,000H,000H,000H,000H,000H	;........
		db	000H,000H,000H,000H,000H,000H,000H,000H	;........
		db	000H,000H,000H,000H,000H,001H,000H,002H	;........
		db	000H,000H,000H,000H,000H,000H,000H,000H	;........
		db	000H,000H,000H,000H,000H,001H,000H,002H	;........
		db	000H,000H,000H,000H,000H,000H,000H,000H	;........
		db	000H,000H,000H,000H,000H,001H,000H,002H	;........
		db	043H,052H,04EH,047H,000H,000H,000H,008H	;CRNG....
		db	000H,000H,00AH,0AAH,000H,000H,001H,00EH	;........
		db	043H,052H,04EH,047H,000H,000H,000H,008H	;CRNG....
		db	000H,000H,00AH,0AAH,000H,000H,000H,000H	;........
		db	043H,052H,04EH,047H,000H,000H,000H,008H	;CRNG....
		db	000H,000H,00AH,0AAH,000H,000H,000H,000H	;........
		db	043H,052H,04EH,047H,000H,000H,000H,008H	;CRNG....
		db	000H,000H,00AH,0AAH,000H,000H,000H,000H	;........
		db	042H,04FH,044H,059H,000H,000H,080H,020H	;BODY... 

;* bit plane buffer

BIT_PLN_BUF_LEN EQU	41*4

BitPlaneBuffer	LABEL	BYTE
	
		DB	39		;copy 39 + 1 bytes literally
BitPlane0	DB	40 DUP(?)

		DB	39		;copy 39 + 1 bytes literally
BitPlane1	DB	40 DUP(?)

		DB	39		;copy 39 + 1 bytes literally
BitPlane2	DB	40 DUP(?)

		DB	39		;copy 39 + 1 bytes literally
BitPlane3	DB	40 DUP(?)

;* hatch sprite

HatchSprite	LABEL	BYTE

col2		=	0

		REPT	16

col1		=	0

		REPT	16

		DB	col1,col2,col1,col2,col1,col2,col1,col2
		DB	col1,col2,col1,col2,col1,col2,col1,col2

col1		=	col1+1

		ENDM

col1		=	0

		REPT	16

		DB	col2,col1,col2,col1,col2,col1,col2,col1
		DB	col2,col1,col2,col1,col2,col1,col2,col1

col1		=	col1+1

		ENDM

col2		=	col2+1

		ENDM

;* sprite to show first 16 colours

Col16Sprite	LABEL	BYTE

col1		=	16

		REPT 	16

		DB	16 DUP (col1)

col1		=	col1+1

		ENDM

;* sprite to show second 16 colours

Col32Sprite	LABEL	BYTE

col1		=	32

		REPT 	16

		DB	16 DUP (col1)

col1		=	col1+1

		ENDM

DATA	 	ENDS

;============================================================================

		END

