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
LINESPC EQU	8
		EVEN
	
Debug2$		LABEL	BYTE
		P_OVER0
		P_CHAR2
		PD_VGA	COL_WHITE,COL_HUD;COL_LT_RED
		P_DECAT	080h

X		=	0
Y		=	0

;		PD_XY	X,Y
;		DB	"FRAMES  :"
;		PV_DECW	LastFrame
;Y		=	Y+6
;
		PD_XY	X,Y
		DB	"POLYGONS:"
		PV_DECW	PolyCount
Y		=	Y+6

Y		=	Y+6

		P_DECAT	000h
		P_END
EVEN

InfoDI$		LABEL	BYTE
		PD_ATTR	0ffh,000h,0ffh,000h,0ffh,000h,COL_HUD,COL_BLACK
		P_OVER1
		P_CHAR2
PX		=	108
PY		=	15
		PD_XY	PX,PY		;frame rate
		DB "*DIGITAL INTEGRATION 1993*"
PX		=	94
PY		=	PY+6+LINESPC
		PD_XY	PX,PY		;polygon count
		DB "DAVID K MARSHALL: Project Manager"
PX		=	8		
PY		=	PY+LINESPC
		PD_XY	PX,PY		;x sector
		DB "KEVIN BEZANT, NICK MASCALL, TONY HOSIER, ROBIN HEYDON, MATTHEW SMITH: Design"		
PX		=	78		
PY		=	PY+LINESPC
		PD_XY	PX,PY		;x sector
		DB "NICK MASCALL, DAVID MARSHALL: Manual text"
PX		=	48
PY		=	PY+LINESPC
		PD_XY	PX,PY		;x sector
		DB "KERRY LE-GRAY, WENDY HOSKIN: Graphics, artwork & package"
PX		=	94
PY		=	PY+LINESPC
		PD_XY	PX,PY		;xft
		DB "DERROL EULING: Technical drawings"
PX		=	64
PY		=	PY+LINESPC
		PD_XY	PX,PY		;xft
		DB "ROD SWIFT, RUSSELL ALCOCK, JEFFREY LOVE: Testing"
PX		=	78
PY		=	PY+LINESPC
		PD_XY	PX,PY		;xft
		DB "ROD COBAIN, STEPHANIE BURNETT: Production"
PX		=	110
PY		=	PY+LINESPC
		PD_XY	PX,PY		;xft
		DB "DEBBIE DURRANT: Marketing"
PX		=	48
PY		=	PY+LINESPC
	    PD_XY	PX,PY		;xft
		DB "VICKI MCBURNIE, JULIE-ANN MERRIT, GILL NIL: Anc. support"
PX		=	120
PY		=	PY+LINESPC
		PD_XY	PX,PY		;xft
		DB "DAVID WHITTAKER: SFX"		
PX		=	62
PY		=	PY+LINESPC
		PD_XY	PX,PY		;xft
		DB "DAVID PUNSHON, RICHARD WELLS, DOMINIC KING: Music"											
PX		=	128
PY		=	PY+14+LINESPC
		PD_XY	PX,PY		;polygon count
		DB "*COMMUNITY 2018*"		
PX		=	66
PY		=	PY+6+LINESPC
		PD_XY	PX,PY		;xft
		DB "FRANKIE, TAILFIN, ATARIBABY, MUPF: Mods, Github"
PX		=	110
PY		=	PY+LINESPC
		PD_XY	PX,PY		;xft
		DB "SPEEDWAGON, TOMN: Testing"		
PX		=	100
PY		=	PY+LINESPC
		PD_XY	PX,PY		;xft
		DB "and to many others, thank you!"		
;PX		=	2
;PY		=	PY+LINESPC
;		PD_XY	PX,PY		;xft
;		DB	"ANDREWM, ERICEJ, KENNETHC, BASILC, HEINZ-BERNDE, GILLESPIE P, RICHARD P,"
;PX		=	16
;PY		=	PY+LINESPC
;		PD_XY	PX,PY		;xft
;		DB	"GRAEMEM, CARL H, ZURGER6, BRUCEM, SIMO, JENSS, AJALBERD8, WINGEDH, FOOS,"
;PX		=	20
;PY		=	PY+LINESPC
;		PD_XY	PX,PY		;xft
;		DB	"PETERMIGMAN, ANDREWR, ATURI83, BLUEY, BREWC, DENIS, MIRANDO, NORTHFOX,"
;PX		=	28
;PY		=	PY+LINESPC
;		PD_XY	PX,PY		;xft
;		DB	"ANDREWR, ATURI83, BLUEY, BREWC, DENIS, MIRANDO, NORTHFOX, AIRFOX, "
;PX		=	40
;PY		=	PY+LINESPC
;		PD_XY	PX,PY		;xft
;		DB	"RICHTHO, RICKB, SENA, TOMN, ZURGER, CHRISR: Fans"		
PX		=	266
PY		=	PY+LINESPC+6
		PD_XY	PX,PY		;xft
		DB	"In memory of"						
PX		=	196
PY		=	PY+8
		PD_XY	PX,PY		;xft
		DB	"David K. Marshall (1953-2016)"												
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
		mov	si,OFFSET Debug2$
		call	Print$
		mov	si,OFFSET InfoDI$
		call	Print$
        ret
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