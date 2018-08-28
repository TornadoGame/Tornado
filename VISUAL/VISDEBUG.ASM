;****************************************************************************
;*
;* VISDEBUG.ASM
;*
;* Display visual debug information.
;*
;* 28.06.1991 - KJB
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	VisualInfo
		EXTRN	Print$:FAR
		EXTRN	LastFrame:WORD
		EXTRN	PolyCount:WORD
		EXTRN InstallMusic:FAR
EXTRN RefreshMusic:FAR
;============================================================================

		INCLUDE	VISEXTRN.INC
		INCLUDE	VISDATA.INC
		INCLUDE	PALETTES.INC

		INCLUDE	\LIB8086\PRINT.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'
LINESPC EQU	12
ObjBufSpace	DW	0

SurfaceType	DW	0

GndObjectHit	DB	0

StatObjectHit	DB	0

TreeObjectHit	DB	0

;		EVEN
;Info$		LABEL	BYTE
;		PD_ATTR	0ffh,000h,0ffh,000h,0ffh,000h,COL_HUD,COL_BLACK
;		P_OVER1
;		P_CHAR2
;
;PX		=	114
;PY		=	15
;		PD_XY	PX,PY		;frame rate
;		DB	"*TEAM CREDITS (1993)*"
;PX		=	94
;PY		=	PY+4+LINESPC
;		PD_XY	PX,PY		;polygon count
;		DB	"DAVID K MARSHALL: Project Manager"
;PX		=	8		
;PY		=	PY+LINESPC
;		PD_XY	PX,PY		;x sector
;		DB	"KEVIN BEZANT, NICK MASCALL, TONY HOSIER, ROBIN HEYDON, MATTHEW SMITH: Design"		
;PX		=	72		
;PY		=	PY+LINESPC
;		PD_XY	PX,PY		;x sector
;		DB	"NICK MASCALL, DAVID MARSHALL: Manual text"
;PX		=	4
;PY		=	PY+LINESPC
;		PD_XY	PX,PY		;x sector
;		DB	"KERRY LE-GRAY, WENDY HOSKIN: Manual, graphics, artwork & package"
;PX		=	84
;PY		=	PY+LINESPC
;		PD_XY	PX,PY		;xft
;		DB	"DERROL EULING: Technical drawings"
;PX		=	54
;PY		=	PY+LINESPC
;		PD_XY	PX,PY		;xft
;		DB	"ROD SWIFT, RUSSELL ALCOCK, JEFFREY LOVE: Beta testing"
;PX		=	78
;PY		=	PY+LINESPC
;		PD_XY	PX,PY		;xft
;		DB	"ROD COBAIN, STEPHANIE BURNETT: Production"
;PX		=	110
;PY		=	PY+LINESPC
;		PD_XY	PX,PY		;xft
;		DB	"DEBBIE DURRANT: Marketing"
;PX		=	38
;PY		=	PY+LINESPC
;		PD_XY	PX,PY		;xft
;		DB	"VICKI MCBURNIE, JULIE-ANN MERRIT, GILL NIL: Ancillary support"
;PX		=	100
;PY		=	PY+LINESPC
;		PD_XY	PX,PY		;xft
;		DB	"DAVID WHITTAKER: Sound effects"		
;PX		=	32
;PY		=	PY+LINESPC
;		PD_XY	PX,PY		;xft
;		DB	"DAVID PUNSHON, RICHARD WELLS, DOMINIC KING: Music & sound"											
;PX		=	268
;PY		=	PY+LINESPC+8
;		PD_XY	PX,PY		;xft
;		DB	"In memory of"						
;PX		=	188
;PY		=	PY+8
;		PD_XY	PX,PY		;xft
;		DB	"David K. Marshall (1953-2016)"												
;		P_END
;		
;		EVEN
		
DATA		ENDS

;============================================================================

VISCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:VISCODE
		ASSUME DS:DATA

;* VisualInfo - display visual debug information 
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all
;*
;* note: This information is only useful after the visual has been processed.

VisualInfo	PROC	FAR

;* calc remaining space in object buffer

		;mov	ax,OFFSET ObjectBufEnd
		;sub	ax,ObjectBufPtr

		;xor	dx,dx
		;mov	bx,OBJ_REC_SIZE
		;div	bx
		
		;mov	ObjBufSpace,ax

;* find surface type

		;mov	si,OFFSET V_VIEW
		;call	SurfaceCheck
		;mov	SurfaceType,ax

;* collision test

		;mov	si,OFFSET V_VIEW
		;call	GroundCollision
		;mov	GndObjectHit,al

		;mov	si,OFFSET V_VIEW
		;call	StaticCollision
		;mov	StatObjectHit,al

		;mov	si,OFFSET V_VIEW
		;call	TreeCollision
		;mov	TreeObjectHit,al

;* display information

;		mov	si,OFFSET Info$
;		call	Print$

		ret

VisualInfo	ENDP


VISCODE		ENDS

;============================================================================

		END

