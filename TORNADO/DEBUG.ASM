;****************************************************************************
;*
;* DEBUG.ASM
;*
;* Print debugging information.
;*
;* 09.03.1992 - KJB
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	PrintDebugInfo

		EXTRN	Print$:FAR
		EXTRN	PrintHexByte:FAR

		EXTRN	LastFrame:WORD
		EXTRN	PolyCount:WORD
		EXTRN	PrtLn:WORD
		EXTRN	PrtCl:WORD
		EXTRN	TxQWtPtr:WORD
		EXTRN	TxQRdPtr:WORD
		EXTRN	RxQWtPtr:WORD
		EXTRN	RxQRdPtr:WORD

		EXTRN	Key:BYTE
		EXTRN	TxQHead:BYTE
		EXTRN	RxQHead:BYTE
		EXTRN	ForeCol:BYTE
		EXTRN	BackCol:BYTE
		EXTRN	HexAttr:BYTE

;============================================================================

		INCLUDE	\VISUAL\PALETTES.INC

		INCLUDE	\LIB8086\KEYS.INC
		INCLUDE	\LIB8086\PRINT.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

Debug$		LABEL	BYTE
		P_OVER0
		P_CHAR2
		PD_VGA	COL_WHITE,COL_LT_RED
		P_DECAT	080h

X		=	0
Y		=	0

		PD_XY	X,Y
		DB	"FRAMES    : "
		PV_DECW	LastFrame
Y		=	Y+6

		PD_XY	X,Y
		DB	"POLYS     : "
		PV_DECW	PolyCount
Y		=	Y+6

Y		=	Y+6

		P_DECAT	000h
		P_END

		EVEN

DATA		ENDS

;============================================================================

CODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:CODE
		ASSUME DS:DATA

;* PrintDebugInfo
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

PrintDebugInfo	PROC	FAR

		mov	si,OFFSET Debug$
		call	Print$

;----------------------------------
;* print two player tx / rx buffers
;----------------------------------

	IF	0

		mov	HexAttr,1000b
		mov	PrtLn,164
		mov	PrtCl,0

		mov	cx,25*3
		mov	si,OFFSET TxQHead
		mov	ForeCol,COL_WHITE

Lp1:		mov	BackCol,COL_LT_RED
		cmp	si,TxQRdPtr
		jne	@F
		mov	BackCol,COL_LT_CYAN
@@:		cmp	si,TxQWtPtr
		jne	@F
		mov	BackCol,COL_BLACK
@@:		lodsb
		call	PrintHexByte
		cmp	PrtCl,288
		jbe	@F
		mov	PrtCl,0
		add	PrtLn,6
@@:		loop	Lp1

		mov	HexAttr,1000b
		mov	PrtLn,182
		mov	PrtCl,0

		mov	cx,25*3
		mov	si,OFFSET RxQHead
		mov	ForeCol,COL_YELLOW

Lp2:		mov	BackCol,COL_LT_RED
		cmp	si,RxQRdPtr
		jne	@F
		mov	BackCol,COL_LT_CYAN
@@:		cmp	si,RxQWtPtr
		jne	@F
		mov	BackCol,COL_BLACK
@@:		lodsb
		call	PrintHexByte
		cmp	PrtCl,288
		jbe	@F
		mov	PrtCl,0
		add	PrtLn,6
@@:		loop	Lp2

		mov	HexAttr,1110b

	ENDIF

		ret

PrintDebugInfo	ENDP

CODE		ENDS

;============================================================================

		END

