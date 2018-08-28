;****************************************************************************
;*
;* VGAPHOTO.ASM
;*
;* Capture VGA screen and save to disk as an ILBM file (VGAPHOTO.LBM).
;*
;* 23.08.1991 - KJB
;* 02.04.1992 - KJB - Auto-incrementing filename added.
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	VGAPhotoDflt
		PUBLIC	VGAPhotoUser

		EXTRN	CreateFile:FAR
		EXTRN	FWrite:FAR
		EXTRN	CloseFile:FAR
		EXTRN	AbortToDOS:FAR
		EXTRN	ReadDACBlock:FAR

		EXTRN	ScreenMode:WORD
		EXTRN	RealScrPtr:WORD

		EXTRN	WorkScreen:BYTE

		EXTRN	VGA:ABS
		EXTRN	VGA_LINEADD:ABS

;============================================================================

		INCLUDE	VGA_DRVR.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

FileName	DB	"PHOTO_"
ID_MSD		DB	"0"
ID_LSD		DB	"0"
		DB	".LBM",0

		EVEN

ByteCount128	DB	128-1
ByteCount64	DB	64-1	

ScreenAddr	DW	0

DATA		ENDS

;============================================================================

HDR_DATA  	SEGMENT PARA PUBLIC 'DATA'

;* ILBM header for VGA picture:-
;*
;* Note: File "BODY" length has been set to 0fc58h = 64600
;*
;*       200 * (07fh + 128 bytes + 07fh + 128 bytes + 03fh + 64 bytes) = 64600
;*
;*       This will be the size of the uncompacted data.
;*
;*       The TINY data has been removed and FORM length has been adjusted.

ILBM_HDR_LEN	EQU	1198

ILBMHeader  	DB	046H,04fH,052H,04dH,000H,001H,000H,0feH	;FORM....
		DB	050H,042H,04dH,020H,042H,04dH,048H,044H	;PBM BMHD
		DB	000H,000H,000H,014H,001H,040H,000H,0c8H	;.....@..
		DB	000H,000H,000H,000H,008H,000H,001H,000H	;........
		DB	000H,0ffH,005H,006H,001H,040H,000H,0c8H	;.....@..
		DB	043H,04dH,041H,050H,000H,000H,003H,000H	;CMAP....
CMAP		DB	000H,000H,000H,000H,000H,0aaH,000H,0aaH	;........
		DB	000H,000H,0aaH,0aaH,0aaH,000H,000H,0aaH	;........
		DB	000H,0aaH,0aaH,055H,000H,0aaH,0aaH,0aaH	;...U....
		DB	055H,055H,055H,055H,055H,0ffH,055H,0ffH	;UUUUU.U.
		DB	055H,055H,0ffH,0ffH,0ffH,055H,055H,0ffH	;UU...UU.
		DB	055H,0ffH,0ffH,0ffH,055H,0ffH,0ffH,0ffH	;U...U...
		DB	0efH,0efH,0efH,0dfH,0dfH,0dfH,0d3H,0d3H	;........
		DB	0d3H,0c3H,0c3H,0c3H,0b7H,0b7H,0b7H,0abH	;........
		DB	0abH,0abH,09bH,09bH,09bH,08fH,08fH,08fH	;........
		DB	07fH,07fH,07fH,073H,073H,073H,067H,067H	;sssgg
		DB	067H,057H,057H,057H,04bH,04bH,04bH,03bH	;gWWWKKK;
		DB	03bH,03bH,02fH,02fH,02fH,023H,023H,023H	;;;///###
		DB	0ffH,000H,000H,0efH,000H,000H,0e3H,000H	;........
		DB	000H,0d7H,000H,000H,0cbH,000H,000H,0bfH	;........
		DB	000H,000H,0b3H,000H,000H,0a7H,000H,000H	;........
		DB	09bH,000H,000H,08bH,000H,000H,07fH,000H	;.......
		DB	000H,073H,000H,000H,067H,000H,000H,05bH	;.s..g..[
		DB	000H,000H,04fH,000H,000H,040H,000H,000H	;..O..@..
		DB	0ffH,0daH,0daH,0ffH,0baH,0baH,0ffH,09fH	;........
		DB	09fH,0ffH,07fH,07fH,0ffH,05fH,05fH,0ffH	;...__.
		DB	040H,040H,0ffH,020H,020H,0ffH,000H,000H	;@@.  ...
		DB	0fcH,0a8H,05cH,0fcH,098H,040H,0fcH,088H	;..\..@..
		DB	020H,0fcH,078H,000H,0e4H,06cH,000H,0ccH	; .x..l..
		DB	060H,000H,0b4H,054H,000H,09cH,04cH,000H	;`..T..L.
		DB	0fcH,0fcH,0d8H,0fcH,0fcH,0b8H,0fcH,0fcH	;........
		DB	09cH,0fcH,0fcH,07cH,0fcH,0f8H,05cH,0fcH	;...|..\.
		DB	0f4H,040H,0fcH,0f4H,020H,0fcH,0f4H,000H	;.@.. ...
		DB	0e4H,0d8H,000H,0ccH,0c4H,000H,0b4H,0acH	;........
		DB	000H,09cH,09cH,000H,084H,084H,000H,070H	;.......p
		DB	06cH,000H,058H,054H,000H,040H,040H,000H	;l.XT.@@.
		DB	0d0H,0fcH,05cH,0c4H,0fcH,040H,0b4H,0fcH	;..\..@..
		DB	020H,0a0H,0fcH,000H,090H,0e4H,000H,080H	; .......
		DB	0ccH,000H,074H,0b4H,000H,060H,09cH,000H	;..t..`..
		DB	0d8H,0fcH,0d8H,0bcH,0fcH,0b8H,09cH,0fcH	;........
		DB	09cH,080H,0fcH,07cH,060H,0fcH,05cH,040H	;...|`.\@
		DB	0fcH,040H,020H,0fcH,020H,000H,0fcH,000H	;.@ . ...
		DB	000H,0ffH,000H,000H,0efH,000H,000H,0e3H	;........
		DB	000H,000H,0d7H,000H,007H,0cbH,000H,007H	;........
		DB	0bfH,000H,007H,0b3H,000H,007H,0a7H,000H	;........
		DB	007H,09bH,000H,007H,08bH,000H,007H,07fH	;.......
		DB	000H,007H,073H,000H,007H,067H,000H,007H	;..s..g..
		DB	05bH,000H,007H,04fH,000H,004H,040H,000H	;[..O..@.
		DB	0daH,0ffH,0ffH,0b8H,0fcH,0fcH,09cH,0fcH	;........
		DB	0fcH,07cH,0fcH,0f8H,05cH,0fcH,0fcH,040H	;.|..\..@
		DB	0fcH,0fcH,020H,0fcH,0fcH,000H,0fcH,0fcH	;.. .....
		DB	000H,0e4H,0e4H,000H,0ccH,0ccH,000H,0b4H	;........
		DB	0b4H,000H,09cH,09cH,000H,084H,084H,000H	;........
		DB	070H,070H,000H,058H,058H,000H,040H,040H	;pp.XX.@@
		DB	05cH,0bcH,0fcH,040H,0b0H,0fcH,020H,0a8H	;\..@.. .
		DB	0fcH,000H,09cH,0fcH,000H,08cH,0e4H,000H	;........
		DB	07cH,0ccH,000H,06cH,0b4H,000H,05cH,09cH	;|..l..\.
		DB	0daH,0daH,0ffH,0baH,0bfH,0ffH,09fH,09fH	;........
		DB	0ffH,07fH,080H,0ffH,05fH,060H,0ffH,040H	;..._`.@
		DB	040H,0ffH,020H,025H,0ffH,000H,005H,0ffH	;@. %....
		DB	000H,000H,0ffH,000H,000H,0efH,000H,000H	;........
		DB	0e3H,000H,000H,0d7H,000H,000H,0cbH,000H	;........
		DB	000H,0bfH,000H,000H,0b3H,000H,000H,0a7H	;........
		DB	000H,000H,09bH,000H,000H,08bH,000H,000H	;........
		DB	07fH,000H,000H,073H,000H,000H,067H,000H	;..s..g.
		DB	000H,05bH,000H,000H,04fH,000H,000H,040H	;.[..O..@
		DB	0f0H,0daH,0ffH,0e5H,0baH,0ffH,0daH,09fH	;........
		DB	0ffH,0d0H,07fH,0ffH,0caH,05fH,0ffH,0bfH	;...._..
		DB	040H,0ffH,0b5H,020H,0ffH,0aaH,000H,0ffH	;@.. ....
		DB	09aH,000H,0e5H,080H,000H,0cfH,075H,000H	;......u.
		DB	0b5H,060H,000H,09fH,050H,000H,085H,045H	;.`..P..E
		DB	000H,070H,035H,000H,05aH,02aH,000H,040H	;.p5.Z*.@
		DB	0ffH,0daH,0ffH,0ffH,0baH,0ffH,0ffH,09fH	;........
		DB	0ffH,0ffH,07fH,0ffH,0ffH,05fH,0ffH,0ffH	;...._..
		DB	040H,0ffH,0ffH,020H,0ffH,0ffH,000H,0ffH	;@.. ....
		DB	0e0H,000H,0e5H,0caH,000H,0cfH,0b5H,000H	;........
		DB	0b5H,09fH,000H,09fH,085H,000H,085H,06fH	;.......o
		DB	000H,070H,05aH,000H,05aH,040H,000H,040H	;.pZ.Z@.@
		DB	0ffH,0eaH,0dfH,0ffH,0e0H,0d0H,0ffH,0daH	;........
		DB	0c5H,0ffH,0d5H,0bfH,0ffH,0cfH,0b0H,0ffH	;........
		DB	0c5H,0a5H,0ffH,0bfH,09fH,0ffH,0baH,090H	;........
		DB	0ffH,0b0H,080H,0ffH,0a5H,070H,0ffH,09fH	;.....p..
		DB	060H,0f0H,095H,05fH,0eaH,08fH,05aH,0dfH	;`.._..Z.
		DB	08aH,055H,0d0H,080H,050H,0caH,07fH,04fH	;.U..P.O
		DB	0bfH,07aH,04aH,0b5H,070H,045H,0aaH,06aH	;.zJ.pE.j
		DB	040H,0a0H,065H,03fH,09fH,060H,03aH,090H	;@.e?.`:.
		DB	05fH,035H,08aH,05aH,030H,080H,050H,02fH	;_5.Z0.P/
		DB	075H,04fH,02aH,06fH,04aH,025H,05fH,040H	;uO*oJ%_@
		DB	020H,055H,03fH,01fH,04aH,03aH,01aH,040H	; U?.J:.@
		DB	030H,01aH,03aH,02fH,015H,02aH,020H,00fH	;0.:/.* .
		DB	000H,000H,000H,000H,000H,000H,000H,000H	;........
		DB	000H,000H,000H,000H,000H,000H,000H,000H	;........
		DB	000H,000H,000H,000H,000H,000H,000H,000H	;........
		DB	0c7H,02bH,02bH,0c7H,04fH,02bH,0c7H,077H	;.++.O+.w
		DB	02bH,0c7H,09fH,02bH,0c7H,0c7H,02bH,09fH	;+..+..+.
		DB	0c7H,02bH,077H,0c7H,02bH,04fH,0c7H,02bH	;.+w.+O.+
		DB	02bH,0c7H,033H,02bH,0c7H,05fH,02bH,0c7H	;+.3+._+.
		DB	08bH,02bH,0c7H,0b7H,02bH,0abH,0c7H,02bH	;.+..+..+
		DB	07fH,0c7H,02bH,053H,0c7H,02fH,02bH,0c7H	;.+S./+.
		DB	05bH,02bH,0c7H,087H,02bH,0c7H,0b3H,02bH	;[+..+..+
		DB	0c7H,0c7H,02bH,0afH,0c7H,02bH,083H,0c7H	;..+..+..
		DB	02bH,057H,0c7H,02bH,02bH,0ffH,0ffH,0ffH	;+W.++...
		DB	044H,050H,050H,053H,000H,000H,000H,06eH	;DPPS...n
		DB	000H,002H,000H,000H,000H,000H,000H,000H	;........
		DB	000H,000H,000H,000H,000H,000H,001H,068H	;.......h
		DB	000H,000H,001H,040H,000H,0c8H,000H,002H	;...@....
		DB	000H,00fH,002H,080H,000H,000H,000H,0b8H	;........
		DB	000H,000H,000H,0b8H,000H,000H,000H,000H	;........
		DB	000H,000H,000H,000H,000H,000H,000H,000H	;........
		DB	000H,000H,000H,000H,000H,000H,000H,000H	;........
		DB	000H,000H,000H,000H,000H,000H,000H,000H	;........
		DB	000H,000H,000H,000H,000H,000H,000H,000H	;........
		DB	000H,000H,000H,001H,000H,000H,000H,000H	;........
		DB	000H,000H,000H,000H,000H,000H,000H,000H	;........
		DB	000H,000H,000H,001H,000H,000H,000H,000H	;........
		DB	000H,000H,000H,000H,000H,000H,000H,000H	;........
		DB	000H,000H,000H,001H,000H,000H,043H,052H	;......CR
		DB	04eH,047H,000H,000H,000H,008H,000H,000H	;NG......
		DB	000H,000H,000H,000H,010H,01fH,043H,052H	;......CR
		DB	04eH,047H,000H,000H,000H,008H,000H,000H	;NG......
		DB	000H,000H,000H,000H,020H,02fH,043H,052H	;.... /CR
		DB	04eH,047H,000H,000H,000H,008H,000H,000H	;NG......
		DB	000H,000H,000H,000H,060H,06fH,043H,052H	;....`oCR
		DB	04eH,047H,000H,000H,000H,008H,000H,000H	;NG......
		DB	000H,000H,000H,000H,090H,09fH,043H,052H	;......CR
		DB	04eH,047H,000H,000H,000H,008H,000H,000H	;NG......
		DB	000H,000H,000H,000H,000H,000H,043H,052H	;......CR
		DB	04eH,047H,000H,000H,000H,008H,000H,000H	;NG......
		DB	000H,000H,000H,000H,000H,000H,043H,052H	;......CR
		DB	04eH,047H,000H,000H,000H,008H,000H,000H	;NG......
		DB	000H,000H,000H,000H,000H,000H,043H,052H	;......CR
		DB	04eH,047H,000H,000H,000H,008H,000H,000H	;NG......
		DB	000H,000H,000H,000H,000H,000H,043H,052H	;......CR
		DB	04eH,047H,000H,000H,000H,008H,000H,000H	;NG......
		DB	000H,000H,000H,000H,000H,000H,043H,052H	;......CR
		DB	04eH,047H,000H,000H,000H,008H,000H,000H	;NG......
		DB	000H,000H,000H,000H,000H,000H,043H,052H	;......CR
		DB	04eH,047H,000H,000H,000H,008H,000H,000H	;NG......
		DB	000H,000H,000H,000H,000H,000H,043H,052H	;......CR
		DB	04eH,047H,000H,000H,000H,008H,000H,000H	;NG......
		DB	000H,000H,000H,000H,000H,000H,043H,052H	;......CR
		DB	04eH,047H,000H,000H,000H,008H,000H,000H	;NG......
		DB	000H,000H,000H,000H,000H,000H,043H,052H	;......CR
		DB	04eH,047H,000H,000H,000H,008H,000H,000H	;NG......
		DB	000H,000H,000H,000H,000H,000H,043H,052H	;......CR
		DB	04eH,047H,000H,000H,000H,008H,000H,000H	;NG......
		DB	000H,000H,000H,000H,000H,000H,043H,052H	;......CR
		DB	04eH,047H,000H,000H,000H,008H,000H,000H	;NG......
		DB	000H,000H,000H,000H,000H,000H,042H,04fH	;......BO
		DB	044H,059H,000H,000H,0fcH,058H		;DY...X

		EVEN

HDR_DATA   	ENDS

;============================================================================

GCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:GCODE
		ASSUME DS:DATA

;* VGAPhotoDflt - capture VGA screen and save to disk as an ILBM file
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all
;*       VGA_CTRL_RDMAP

VGAPhotoDflt	PROC	FAR

		mov	dx,OFFSET FileName

		call	FAR PTR VGAPhotoUser

;* modify filename for next photo ("PHOTO_00.LBM" .. "PHOTO_99.LBM")

		inc	ID_LSD
		cmp	ID_LSD,'9'+1
		jne	@F
		mov	ID_LSD,'0'
		inc	ID_MSD

@@:		ret

VGAPhotoDflt	ENDP

;----------------------------------------------------------------------------

;* VGAPhotoUser - capture VGA screen and save to disk as an ILBM file
;*
;* pass: dx -> ASCIIZ filespec (ie. "drive:\path\filename.ext",0)
;* ret : nothing
;* kill: assume all
;*       VGA_CTRL_RDMAP

VGAPhotoUser	PROC	FAR

		push	es

		cmp	ScreenMode,VGA	;VGA screen mode?
		jne	VGAPhotoExit	;no ->

;-------------
;* create file
;-------------
		
		call	CreateFile
		jc	VGAPhotoError

;-----------------------------------
;* copy DAC colour registers to CMAP
;-----------------------------------

		mov	ax,HDR_DATA
		mov	es,ax
		mov	di,OFFSET CMAP	;es:di -> CMAP RGB data

		mov	al,0		;start colour 0
		mov	cx,256		;copy 256 colours

		call	ReadDACBlock

;* scale gun values * 4

		mov	cx,256*3
		mov	di,OFFSET CMAP
@@:		mov	al,es:[di]
		shl	al,1		;*2
		shl	al,1		;*4
		stosb
		loop	@B
		
;---------------------------
;* write header data to file
;---------------------------

		mov	cx,ILBM_HDR_LEN
		mov	di,OFFSET ILBMHeader
		call	FWrite
		jc	VGAPhotoError

;-----------------------------------------------------------
;* copy interleaved screen data to linear data in WorkScreen 
;-----------------------------------------------------------

		call	SortScrData

;---------------------------
;* write screen data to file
;---------------------------

		mov	ScreenAddr,0

		mov	cx,200
WriteLoop:	push	cx

		call	WriteScreenLine

		pop	cx
		loop	WriteLoop

;------------
;* close file
;------------

		call	CloseFile
		jc	VGAPhotoError	

VGAPhotoExit:	pop	es
		ret

VGAPhotoError:	jmp	AbortToDOS	;disk error, return to DOS

VGAPhotoUser	ENDP

;----------------------------------------------------------------------------

;* WriteScreenLine
;*
;* pass: ScreenAddr
;* ret : ScreenAddr
;* kill: assume all

WriteScreenLine	PROC	NEAR

;* write byte count (ie. copy next 128 bytes literally)

		mov	cx,1
		mov	ax,DATA
		mov	es,ax
		mov	di,OFFSET ByteCount128
		call	FWrite
		jc	VGAPhotoError

;* write 128 screen bytes

		mov	cx,128
		mov	ax,SEG WorkScreen
		mov	es,ax
		mov	di,ScreenAddr
		call	FWrite
		jc	VGAPhotoError
		add	ScreenAddr,128
				
;* write byte count (ie. copy next 128 bytes literally)

		mov	cx,1
		mov	ax,DATA
		mov	es,ax
		mov	di,OFFSET ByteCount128
		call	FWrite
		jc	VGAPhotoError

;* write 128 screen bytes

		mov	cx,128
		mov	ax,SEG WorkScreen
		mov	es,ax
		mov	di,ScreenAddr
		call	FWrite
		jc	VGAPhotoError
		add	ScreenAddr,128

;* write byte count (ie. copy next 64 bytes literally)

		mov	cx,1
		mov	ax,DATA
		mov	es,ax
		mov	di,OFFSET ByteCount64
		call	FWrite
		jc	VGAPhotoError

;* write 64 screen bytes

		mov	cx,64
		mov	ax,SEG WorkScreen
		mov	es,ax
		mov	di,ScreenAddr
		call	FWrite
		jc	VGAPhotoError
		add	ScreenAddr,64

		ret

WriteScreenLine	ENDP

;----------------------------------------------------------------------------

;* SortScrData -  copy interleaved screen data to linear data in WorkScreen
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all
;*       VGA_CTRL_RDMAP

SortScrData	PROC	NEAR

		push	ds

		SLCTREG	VGA_CTRL,VGA_CTRL_RDMAP

		mov	ax,SEG WorkScreen
		mov	es,ax

		mov	ax,RealScrPtr
		mov	ds,ax

		mov	al,0		;map 0
		out	dx,al
		mov	cx,200*80
		xor	si,si		;ds:si -> start of real screen
		mov	di,0		;es:di -> start of WorkScreen + 0
@@:		movsb
		add	di,3
		loop	@B

		mov	al,1		;map 1
		out	dx,al
		mov	cx,200*80
		xor	si,si		;ds:si -> start of real screen
		mov	di,1		;es:di -> start of WorkScreen + 1
@@:		movsb
		add	di,3
		loop	@B

		mov	al,2		;map 2
		out	dx,al
		mov	cx,200*80
		xor	si,si		;ds:si -> start of real screen
		mov	di,2		;es:di -> start of WorkScreen + 2
@@:		movsb
		add	di,3
		loop	@B

		mov	al,3		;map 3
		out	dx,al
		mov	cx,200*80
		xor	si,si		;ds:si -> start of real screen
	        mov	di,3		;es:di -> start of WorkScreen + 3
@@:		movsb
		add	di,3
		loop	@B

		pop	ds

		ret

SortScrData	ENDP

GCODE		ENDS

;============================================================================

		END

