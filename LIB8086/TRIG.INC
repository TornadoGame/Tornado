;****************************************************************************
;*
;* TRIG.INC
;*
;* Trig macros.
;*
;* 21.07.1989 - KJB
;*
;****************************************************************************

;* SINE - look up sine of angle (pseudo degrees)
;*
;* pass: source (0 .. 511 pdegs)
;* ret : dest = sin(source)
;* kill: bx, flags

SINE		MACRO	dest,source

		IFDIFI	<source>,<bx>
		mov	bx,source    
		ENDIF
		and	bx,001ffh 
		shl	bx,1		
		mov	dest,SinTable[bx]
		
		ENDM

;----------------------------------------------------------------------------

;* COSINE - look up cosine of angle (pseudo degrees)
;*
;* pass: source (0 .. 511 pdegs)
;* ret : dest = cos(source)
;* kill: bx, flags

COSINE		MACRO	dest,source

		IFDIFI	<source>,<bx> 
		mov	bx,source
		ENDIF
		and	bx,001ffh     
		shl	bx,1		
		mov	dest,CosTable[bx]
		
		ENDM

;----------------------------------------------------------------------------

;* SINCOS - look up sine and cosine of angle (pseudo degrees)
;*
;* pass: source (0 .. 511 pdegs)
;* ret : sin_dest = sin(source)
;*       cos_dest = cos(source)
;* kill: bx, flags

SINCOS		MACRO	sin_dest,cos_dest,source

		IFDIFI	<source>,<bx> 
		mov	bx,source
		ENDIF
		and	bx,001ffh     
		shl	bx,1	     
		IFDIFI	<sin_dest>,<bx>	
		mov	sin_dest,SinTable[bx]
		mov	cos_dest,CosTable[bx]
		ELSE
		mov	cos_dest,CosTable[bx]
		mov	sin_dest,SinTable[bx]
		ENDIF
		
		ENDM




