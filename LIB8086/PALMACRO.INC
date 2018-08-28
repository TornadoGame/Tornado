;****************************************************************************
;*
;* PALMACRO.INC
;*
;* 16.03.1992 - KJB
;*
;****************************************************************************

;* OVLYRGB - overlay RGB data
;*
;* pass: dest
;*       source
;*       n = num colours
;* ret : nothing
;* kill: ax, cx, si, di, flags
;*
;* note: This code will work with any screen mode but it will only modify
;*       the VGA palette.

OVLYRGB		MACRO	dest,source,n

		push	ds
		push	es

		mov	ax,SEG VGA_RGB_Data
		mov	ds,ax
		mov	es,ax

		IFDIFI	<source>,<si>
		mov	si,OFFSET source
		ENDIF

		IFDIFI	<dest>,<di>
		mov	di,OFFSET dest
		ENDIF

		mov	cx,n*3

		shr	cx,1		;calc number of words to move
		rep	movsw
		rcl	cx,1		;remaining byte (if any)
		rep	movsb

		pop	es
		pop	ds

		ENDM

