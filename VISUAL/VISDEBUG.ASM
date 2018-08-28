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
		EXTRN	SurfaceCheck:FAR
		EXTRN	GroundCollision:FAR
		EXTRN	StaticCollision:FAR
		EXTRN	TreeCollision:FAR

		EXTRN	LastFrame:WORD
		EXTRN	PolyCount:WORD

;============================================================================

		INCLUDE	VISEXTRN.INC
		INCLUDE	VISDATA.INC
		INCLUDE	PALETTES.INC

		INCLUDE	\LIB8086\PRINT.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

ObjBufSpace	DW	0

SurfaceType	DW	0

GndObjectHit	DB	0

StatObjectHit	DB	0

TreeObjectHit	DB	0

		EVEN

Info$		LABEL	BYTE
		PD_ATTR	0ffh,000h,0ffh,000h,0ffh,000h,COL_WHITE,COL_BLACK
		P_OVER0
		P_CHAR2

PX		=	0
PY		=	0

		P_DECAT	000h

		PD_XY	PX,PY		;frame rate
		DB	"TICKS PER FRAME:"
		PV_DECW	LastFrame

PY		=	PY+6

		PD_XY	PX,PY		;polygon count
		DB	"POLYGON COUNT  :"
		PV_DECW	PolyCount

PY		=	PY+6

		P_DECAT	080h

		PD_XY	PX,PY		;x sector
		DB	"X SEC          :"
		PV_DECW	V_VIEW.VP_XSEC

PY		=	PY+6

		PD_XY	PX,PY		;y sector
		DB	"Y SEC          :"
		PV_DECW	V_VIEW.VP_YSEC

PY		=	PY+6

		PD_XY	PX,PY		;xft
		DB	"XFT            :"
		PV_DECW	V_VIEW.VP_XFT

PY		=	PY+6

		PD_XY	PX,PY		;yft
		DB	"YFT            :"
		PV_DECW	V_VIEW.VP_YFT

PY		=	PY+6

		PD_XY	PX,PY		;zft
		DB	"ZFT            :"
		PV_HEXL	V_VIEW.VP_ZFT

PY		=	PY+6

		P_DECAT	000h

		PD_XY	PX,PY		;z scaled
		DB	"Z SCALED       :"
		PV_DECW	ZScaled

PY		=	PY+6

		PD_XY	PX,PY		;heading
		DB	"HDG            :"
		PV_DECW	V_VIEW.VP_HDG

PY		=	PY+6

		PD_XY	PX,PY		;pitch
		DB	"PITCH          :"
		PV_DECW	V_VIEW.VP_PITCH

PY		=	PY+6

		PD_XY	PX,PY		;roll
		DB	"ROLL           :"
		PV_DECW	V_VIEW.VP_ROLL

PY		=	PY+6

		PD_XY	PX,PY		;number of visible sectors
		DB	"NUM VIS SECS   :"
		PV_DECW	NumVisSctrs

PY		=	PY+6

		PD_XY	PX,PY		;object buffer space remaining
		DB	"OBJ BUF SPACE  :"
		PV_DECW	ObjBufSpace

PY		=	PY+6

		PD_XY	PX,PY		;number of active mobile objects
		DB	"NUM MOBILES    :"
		PV_DECW	NumMobiles

PY		=	PY+6

		PD_XY	PX,PY		;surface type
		DB	"SURFACE TYPE   :"
		PV_DECW	SurfaceType

PY		=	PY+6

		PD_XY	PX,PY		;ground object collision
		DB	"GND OBJECT HIT :"
		PV_DECB	GndObjectHit

PY		=	PY+6

		PD_XY	PX,PY		;static mobile collision
		DB	"STAT OBJECT HIT:"
		PV_DECB	StatObjectHit

PY		=	PY+6

		PD_XY	PX,PY		;tree object collision
		DB	"TREE OBJECT HIT:"
		PV_DECB	TreeObjectHit

		P_DECAT	000h

		P_END

		EVEN

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

		mov	ax,OFFSET ObjectBufEnd
		sub	ax,ObjectBufPtr

		xor	dx,dx
		mov	bx,OBJ_REC_SIZE
		div	bx
		
		mov	ObjBufSpace,ax

;* find surface type

		mov	si,OFFSET V_VIEW
		call	SurfaceCheck
		mov	SurfaceType,ax

;* collision test

		mov	si,OFFSET V_VIEW
		call	GroundCollision
		mov	GndObjectHit,al

		mov	si,OFFSET V_VIEW
		call	StaticCollision
		mov	StatObjectHit,al

		mov	si,OFFSET V_VIEW
		call	TreeCollision
		mov	TreeObjectHit,al

;* display information

		mov	si,OFFSET Info$
		call	Print$

		ret

VisualInfo	ENDP

VISCODE		ENDS

;============================================================================

		END

