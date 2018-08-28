;****************************************************************************
;*
;* EGAPHOTO.ASM
;*
;* Capture EGA screen and save to disk as an ILBM file (EGAPHOTO.LBM).
;*
;* 05.12.1989 - KJB
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	EGAPhotoDflt
		PUBLIC	EGAPhotoUser

		EXTRN	CreateFile:FAR
		EXTRN	FWrite:FAR
		EXTRN	CloseFile:FAR
		EXTRN	AbortToDOS:FAR

		EXTRN	ScreenMode:WORD
		EXTRN	RealScrPtr:WORD

		EXTRN	EGA:ABS
		EXTRN	EGA_LINEADD:ABS

;============================================================================

		INCLUDE	EGA_DRVR.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

FileName	DB	"EGAPHOTO.LBM",0

		EVEN

ByteCount	DB	40-1,0	

ScreenAddr	DW	0

DATA		ENDS

;============================================================================

HDR_DATA  	SEGMENT PARA PUBLIC 'DATA'

;* ILBM header for EGA picture
;*
;* note file "BODY" length has been set to 08020h = 32800
;*
;* 200 lines * 4 planes * (40 + 1) bytes per line = 32800
;*
;* this will be the size of the uncompacted data

ILBM_HDR_LEN	EQU	35*8

ILBMHeader  	DB	046H,04FH,052H,04DH,000H,000H,081H,030H	;FORM...0
		DB	049H,04CH,042H,04DH,042H,04DH,048H,044H	;ILBMBMHD
		DB	000H,000H,000H,014H,001H,040H,000H,0C8H	;.....@..
		DB	000H,000H,000H,000H,004H,000H,001H,000H	;........
		DB	000H,000H,005H,006H,001H,040H,000H,0C8H	;.....@..
		DB	043H,04DH,041H,050H,000H,000H,000H,030H	;CMAP...0
		DB	000H,000H,000H,000H,000H,0AAH,000H,0AAH	;........
		DB	000H,000H,0AAH,0AAH,0AAH,000H,000H,0AAH	;........
		DB	000H,0AAH,0AAH,055H,000H,0AAH,0AAH,0AAH	;...U....
		DB	055H,055H,055H,055H,055H,0FFH,055H,0FFH	;UUUUU.U.
		DB	055H,055H,0FFH,0FFH,0FFH,055H,055H,0FFH	;UU...UU.
		DB	055H,0FFH,0FFH,0FFH,055H,0FFH,0FFH,0FFH	;U...U...
		DB	044H,050H,050H,056H,000H,000H,000H,068H	;DPPV...h
		DB	000H,000H,000H,000H,000H,000H,000H,000H	;........
		DB	001H,068H,000H,000H,001H,040H,000H,0C8H	;.h...@..
		DB	000H,002H,000H,05AH,000H,080H,000H,000H	;...Z....
		DB	001H,090H,000H,000H,001H,090H,000H,000H	;........
		DB	000H,000H,000H,000H,000H,000H,000H,000H	;........
		DB	000H,000H,000H,000H,000H,000H,000H,000H	;........
		DB	000H,000H,000H,000H,000H,000H,000H,000H	;........
		DB	000H,000H,000H,000H,000H,000H,000H,000H	;........
		DB	000H,000H,000H,000H,000H,001H,000H,002H	;........
		DB	000H,000H,000H,000H,000H,000H,000H,000H	;........
		DB	000H,000H,000H,000H,000H,001H,000H,002H	;........
		DB	000H,000H,000H,000H,000H,000H,000H,000H	;........
		DB	000H,000H,000H,000H,000H,001H,000H,002H	;........
		DB	043H,052H,04EH,047H,000H,000H,000H,008H	;CRNG....
		DB	000H,000H,00AH,0AAH,000H,000H,001H,00EH	;........
		DB	043H,052H,04EH,047H,000H,000H,000H,008H	;CRNG....
		DB	000H,000H,00AH,0AAH,000H,000H,000H,000H	;........
		DB	043H,052H,04EH,047H,000H,000H,000H,008H	;CRNG....
		DB	000H,000H,00AH,0AAH,000H,000H,000H,000H	;........
		DB	043H,052H,04EH,047H,000H,000H,000H,008H	;CRNG....
		DB	000H,000H,00AH,0AAH,000H,000H,000H,000H	;........
		DB	042H,04FH,044H,059H,000H,000H,080H,020H	;BODY... 

		EVEN

HDR_DATA   	ENDS

;============================================================================

GCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:GCODE
		ASSUME DS:DATA

;* EGAPhotoDflt - capture EGA screen and save to disk as an ILBM file
;* EGAPhotoUser - as EGAPhotoDflt but use given filespec
;*
;* pass: EGAPhotoDflt: nothing
;*       EGAPhotoUser: dx -> ASCIIZ filespec (ie. "drive:\path\filename.ext",0)
;* ret : nothing
;* kill: assume all
;*       EGA_CTRL_RDMAP

EGAPhotoDflt	PROC	FAR

		mov	dx,OFFSET FileName

EGAPhotoUser	LABEL	FAR

		push	es

		cmp	ScreenMode,EGA	;EGA screen mode?
		jne	EGAPhotoExit	;no ->
		
		call	CreateFile
		jc	EGAPhotoError

		mov	cx,ILBM_HDR_LEN
		mov	ax,HDR_DATA
		mov	es,ax
		mov	di,OFFSET ILBMHeader
		call	FWrite
		jc	EGAPhotoError

		mov	ScreenAddr,0

		mov	cx,200
WriteLoop:	push	cx

		call	WriteScreenLine
		
		pop	cx
		add	ScreenAddr,EGA_LINEADD
		loop	WriteLoop

		call	CloseFile
		jc	EGAPhotoError	

EGAPhotoExit:	pop	es
		ret

EGAPhotoError:	jmp	AbortToDOS	;disk error, return to DOS

EGAPhotoDflt	ENDP

;----------------------------------------------------------------------------

;* WriteScreenLine - write screen line to ILBM file (4 bit planes)
;*
;* pass: ScreenAddr
;*       RealScrPtr
;* ret : nothing
;* kill: assume all
;*       EGA_CTRL_RDMAP

WriteScreenLine	PROC	NEAR

;* write bit planes 0, 1, 2 and 3

		mov	ah,0
		mov	cx,4
	
BitPlaneLoop:	push	ax
		push	cx
			
		SETREGV	EGA_CTRL,EGA_CTRL_RDMAP,ah

;* write byte count (ie. copy next n+1 bytes literally)

		mov	cx,1
		mov	ax,DATA
		mov	es,ax
		mov	di,OFFSET ByteCount
		call	FWrite
		jc	EGAPhotoError
	
		mov	cx,40
		mov	ax,RealScrPtr
		mov	es,ax
		mov	ax,ScreenAddr
		mov	di,ax
		call	FWrite
		jc	EGAPhotoError

		pop	cx
		pop	ax
		inc	ah		;next bit plane
		loop	BitPlaneLoop

		ret

WriteScreenLine	ENDP

GCODE		ENDS

;============================================================================

		END

