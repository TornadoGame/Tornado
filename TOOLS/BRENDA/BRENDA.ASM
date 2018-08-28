;****************************************************************************
;*
;* BRENDA.ASM
;*
;* 01.12.1989 - KJB
;*
;****************************************************************************

		PUBLIC	Brenda

		EXTRN	InstallKbd:FAR
		EXTRN	RestoreKbd:FAR
		EXTRN	LoadFile:FAR
		EXTRN	UpdateMouse:FAR
		EXTRN	CreateFile:FAR
		EXTRN	CloseFile:FAR
		EXTRN	FWrite:FAR
		EXTRN	AbortToDOS:FAR

		EXTRN	SPTemp:WORD
		EXTRN	SSTemp:WORD
		EXTRN	MouseX:WORD
		EXTRN	MouseY:WORD
		EXTRN	OldMouseX:WORD
		EXTRN	OldMouseY:WORD

	        EXTRN	DiskBuffer:BYTE
		EXTRN	Screen1:BYTE
		EXTRN	Screen2:BYTE
		EXTRN	Screen3:BYTE
		EXTRN	Key:BYTE
		EXTRN	LhsButton:BYTE
		EXTRN	RhsButton:BYTE
		EXTRN	MidButton:BYTE
		EXTRN	OldLhsButton:BYTE
		EXTRN	OldRhsButton:BYTE
		EXTRN	OldMidButton:BYTE
		EXTRN	HatchSprite:BYTE
		EXTRN	Col16Sprite:BYTE
		EXTRN	Col32Sprite:BYTE
		EXTRN	HatchTable:BYTE
		EXTRN	EGAHeader:BYTE
		EXTRN	BitPlaneBuffer:BYTE
		EXTRN	BitPlane0:BYTE
		EXTRN	BitPlane1:BYTE
		EXTRN	BitPlane2:BYTE
		EXTRN	BitPlane3:BYTE

		EXTRN	BUF_SIZE:ABS
		EXTRN	SCR_SIZE:ABS
		EXTRN	EGA_HDR_LEN:ABS
		EXTRN	BIT_PLN_BUF_LEN:ABS

;============================================================================

		INCLUDE	C:\LIB8086\KEYS.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

BEL		EQU	7
CR		EQU	13
LF		EQU	10

VGA_SEG		EQU	0a000h

COL16		EQU	16*3		;number of RGB data bytes for 16 cols
COL32		EQU	32*3		;number of RGB data bytes for 32 cols

START_COL	EQU	16		;keep 0 - 15 same as EGA cols

EGA_MASK	EQU	1111b

SeekCol 	DB	0,0

XchgCol		DB	0,0

CGAHiLite	DB	0,0		;1 - CGA highlight on

OldCGAKey	DB	0,0		;key interlock

PaletteFlag	DB	0,0

NumPlanes	DW	0		;4 or 5 (16 or 32 cols)

HiLiteTable	DB	15, 0, 0 	;black hatches
		DB	15, 0,11
		DB	15, 0,13
		DB	13, 0,15
		DB	13,11, 0  	;cyan hatches
		DB	13,11,11
		DB	 0,11,13
		DB	13,11,15
		DB	11,13, 0	;magenta hatches
		DB	 0,13,11
		DB	11,13,13
		DB	11,13,15
		DB	13,15, 0 	;white hatches
		DB	 0,15,11
		DB	 0,15,13
		DB	 0,15,15

		EVEN

RGBMarker	DB	"CMAP"

DataMarker	DB	"BODY"

RdFile		DB	128,0
RdFileName	DB	128 DUP(0)

WtFile		DB	128,0
WtFileName	DB	128 DUP(0)

DownLoad	DW	DownLoad1
		DW	DownLoad2

HatchCols	DB	32 DUP(0)	;only valid if hatch flag = 1

HatchFlags	DB	32 DUP(0)

CLR		EQU	-1
BLK		EQU	0
WHT		EQU	15

M_WIDTH		EQU	9
M_DEPTH		EQU	11

MouseSprite	DB	CLR,BLK,CLR,CLR,CLR,CLR,CLR,CLR,CLR	;0
		DB	BLK,WHT,BLK,CLR,CLR,CLR,CLR,CLR,CLR	;1
		DB	BLK,WHT,WHT,BLK,CLR,CLR,CLR,CLR,CLR	;2
		DB	BLK,WHT,WHT,WHT,BLK,CLR,CLR,CLR,CLR	;3
		DB	BLK,WHT,WHT,WHT,WHT,BLK,CLR,CLR,CLR	;4
		DB	BLK,WHT,WHT,WHT,WHT,WHT,BLK,CLR,CLR	;5
		DB	BLK,WHT,WHT,WHT,WHT,WHT,WHT,BLK,CLR	;6
		DB	BLK,WHT,WHT,WHT,WHT,WHT,WHT,WHT,BLK	;7
		DB	BLK,WHT,WHT,BLK,WHT,WHT,BLK,BLK,BLK	;8
		DB	BLK,BLK,BLK,BLK,BLK,WHT,WHT,BLK,CLR	;9
		DB	CLR,CLR,CLR,CLR,CLR,BLK,BLK,BLK,CLR	;10

		EVEN

MouseHouse	DB	M_WIDTH*M_DEPTH DUP(?)

		EVEN

Title$		DB	"VGA BRENDA Utility - KJB - 01.12.1989",CR,LF
		DB	"-------------------------------------",CR,LF
		DB	CR,LF
		DB	"Reads 16 or 32 colour ILBM files and allows you to blend EGA hatches to "
		DB	CR,LF
		DB	"create an EGA picture."
		DB	CR,LF
		DB	CR,LF
		DB	"Select colour to change - mouse left button to select colour from picture."
		DB	CR,LF
		DB	"                        - mouse left button and mouse middle button / space"
		DB	CR,LF
	        DB	"                          bar to select colour from palette."
		DB	CR,LF
		DB	"Select EGA hatch colour - mouse left button and mouse middle button / space"
		DB	CR,LF
		DB	"                          bar."
		DB	CR,LF
		DB	"View EGA screen         - mouse right button."
		DB	CR,LF
		DB	"Highlight CGA colours   - 'C' key (toggle on / off)."
		DB	CR,LF
		DB	"Quit and save ILBM file - ESC key."
		DB	CR,LF
		DB	"Quit                    - SYS REQ key."
		DB	'$'
		
		EVEN

RdFile$		DB	CR,LF,CR,LF
		DB	"Read data from? (drive:\path\filename.ext)"
		DB	CR,LF
		DB	">>>"
		DB	'$'

		EVEN

WtFile$		DB	CR,LF,CR,LF
		DB	"Write data to? (drive:\path\filename.ext)"
		DB	CR,LF
		DB	">>>"
		DB	'$'

		EVEN

DiskErr$	DB	BEL,"DISK ERROR!!! - HIT ESC",CR,LF
		DB	'$'

		EVEN

DATA		ENDS

;============================================================================

CODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:CODE
		ASSUME DS:DATA

Brenda		PROC	NEAR

		call	PrintTitleMsg
		call	GetReadFile
		call	GetWriteFile
		call	VGAMode
		call	LoadInputFile
		call	SetPalette
		call	Uncompress
		call	CreateVGAData
		call	Control
		call	CreateILBMData
		ret

Brenda		ENDP

;----------------------------------------------------------------------------

;* GetReadFile - get filename of data to read
;*
;* pass: nothing
;* ret : RdFile
;* kill: assume all

GetReadFile	PROC	NEAR

		call	RestoreKbd

GetReadAgain:	mov	ah,9
		mov	dx,OFFSET RdFile$
		int	021h

		mov	ah,10
		mov	dx,OFFSET RdFile
		int	021h

		mov	al,RdFile[1]	;any chars entered?
		cmp	al,0
		je	GetReadAgain	;no ->

		mov	bl,al		;change CR to ASCIIZ terminator
		xor	bh,bh
		add	bx,2
		mov	RdFile[bx],0

		call	InstallKbd

		ret

GetReadFile	ENDP

;----------------------------------------------------------------------------

;* GetWriteFile - get filename of data to write
;*
;* pass: nothing
;* ret : WtFile
;* kill: assume all

GetWriteFile	PROC	NEAR

		call	RestoreKbd

GetWriteAgain:	mov	ah,9
		mov	dx,OFFSET WtFile$
		int	021h

		mov	ah,10
		mov	dx,OFFSET WtFile
		int	021h

		mov	al,WtFile[1]	;any chars entered?
		cmp	al,0
		je	GetWriteAgain	;no ->

		mov	bl,al		;change CR to ASCIIZ terminator
		xor	bh,bh
		add	bx,2
		mov	WtFile[bx],0

		call	InstallKbd

		ret

GetWriteFile	ENDP

;----------------------------------------------------------------------------

;* DiskError - piss poor disk error handling!!!
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

DiskError	PROC	NEAR

		mov	ax,DATA
		mov	ds,ax
		mov	es,ax

		mov	ah,0		;80*25 Alpha mode
		mov	al,3
		int	010h

		mov	ah,9
		mov	dx,OFFSET DiskErr$
		int	021h

ErrorWait:	mov	al,Key[K_ESC]
		test	al,al
		jz	ErrorWait

		cli
		mov	ax,SPTemp
		mov	sp,ax
		mov	ax,SSTemp
		mov	ss,ax
		sti

		jmp	AbortToDOS

DiskError	ENDP

;----------------------------------------------------------------------------

PrintTitleMsg	PROC	NEAR

		mov	ah,000h		;select video mode
		mov	al,003h
		int	010h

		mov	ah,9
		mov	dx,OFFSET Title$
		int	021h

		ret

PrintTitleMsg	ENDP

;----------------------------------------------------------------------------

VGAMode		PROC	NEAR

		mov	ah,000h		;select video mode
		mov	al,013h
		int	010h
		ret

VGAMode		ENDP

;----------------------------------------------------------------------------

LoadInputFile	PROC	NEAR

		push	es
		mov	cx,BUF_SIZE
		mov	dx,OFFSET RdFileName
		mov	ax,SEG DiskBuffer
		mov	es,ax
		mov	di,OFFSET DiskBuffer
		call	LoadFile
		pop	es
		jnc	ReadFileOk
		jmp	DiskError
ReadFileOk:	ret

LoadInputFile	ENDP

;----------------------------------------------------------------------------

SetPalette	PROC	NEAR

		push	ds
		push	es

;* search for RGB data

		mov	bx,WORD PTR [RGBMarker]
		mov	cx,WORD PTR [RGBMarker+2]

		mov	ax,SEG DiskBuffer
		mov	ds,ax
		mov	si,offset DiskBuffer

RGBSearchOn:	mov	al,[si+0]
		cmp	al,bl
		jne	RGBNextData
		mov	al,[si+1]	
		cmp	al,bh
		jne	RGBNextData
		mov	al,[si+2]
		cmp	al,cl
		jne	RGBNextData
		mov	al,[si+3]	
		cmp	al,ch
		je	RGBFoundMarker
RGBNextData:	inc	si
		cmp	si,BUF_SIZE
		jb	RGBSearchOn
	 	jmp	DiskError

RGBFoundMarker:	mov	al,[si+7]
		mov	ah,[si+6]

		cmp	ax,COL16	;16 colour palette?
		mov	bp,4		;assume so
		mov	cx,16
		je	SetCols		;yes ->
		cmp	ax,COL32	;32 colour palette?
		mov	bp,5		;assume so
		mov	cx,32
		je	SetCols		;yes ->
		jmp	DiskError

SetCols:	add	si,8		;ds:si -> start of RGB data

;* scale gun values (/4)

		push	cx
		push	si

ScaleLoop:	shr	BYTE PTR [si+0],1
		shr	BYTE PTR [si+0],1
		shr	BYTE PTR [si+1],1
		shr	BYTE PTR [si+1],1
		shr	BYTE PTR [si+2],1
		shr	BYTE PTR [si+2],1
		add	si,3
		loop	ScaleLoop

		pop	si
		pop	cx

		mov	ax,SEG DiskBuffer
		mov	es,ax

		mov	ah,010h		;set palette regs
		mov	al,012h		;update block of colour registers
		mov	bx,START_COL
		mov	dx,si

		push	bp		
		int	010h
		pop	bp

		pop	es
		pop	ds

		mov	NumPlanes,bp

		ret

SetPalette	ENDP

;----------------------------------------------------------------------------

DownLoad1	PROC

		push	ds
		push	es

		mov	ax,SEG Screen1
		mov	ds,ax

		mov	ax,VGA_SEG
		mov	es,ax

		mov	cx,SCR_SIZE

		xor	si,si
		xor	di,di

		rep	movsb

		pop	es
		pop	ds
		ret

DownLoad1	ENDP

;----------------------------------------------------------------------------

DownLoad2	PROC

		push	ds
		push	es

		mov	ax,SEG Screen2
		mov	ds,ax

		mov	ax,VGA_SEG
		mov	es,ax

		mov	cx,SCR_SIZE

		xor	si,si
		xor	di,di

		rep	movsb

		pop	es
		pop	ds
		ret

DownLoad2	ENDP

;----------------------------------------------------------------------------

;* uncompress ILBM file into Screen2
;*
;* Run Length Encoding format:-
;*
;*  0 ... +127: copy the next n + 1 bytes literally
;* -1 ... -127: copy the next byte -n + 1 times
;*        -128: no operation

Uncompress	PROC	NEAR

		push	ds
		push	es

		mov	bx,WORD PTR [DataMarker]
		mov	cx,WORD PTR [DataMarker+2]

		mov	ax,SEG DiskBuffer
		mov	ds,ax
		mov	si,offset DiskBuffer

		mov	ax,SEG Screen2
		mov	es,ax
		mov	di,OFFSET Screen2

;* search for data marker

RLESearchOn:	mov	al,[si+0]
		cmp	al,bl
		jne	RLENextData
		mov	al,[si+1]	
		cmp	al,bh
		jne	RLENextData
		mov	al,[si+2]
		cmp	al,cl
		jne	RLENextData
		mov	al,[si+3]	
		cmp	al,ch
		je	RLEFoundMarker
RLENextData:	inc	si
		cmp	si,BUF_SIZE
		jb	RLESearchOn
	 	jmp	DiskError

RLEFoundMarker:	mov	al,[si+7]	
		mov	ah,[si+6]	;ax = length of data
		
		add	si,8		;ds:si -> start of data

		mov	bp,ax
		add	bp,si		;ds:bp -> end of data + 1

UncompressLoop:	lodsb
		test	al,al
		js	BlockFill

		mov	cl,al
		xor	ch,ch
		inc	cx
		rep	movsb
		jmp	NextByte

BlockFill:	cmp	al,-128
		je	NextByte

		neg	al
		mov	cl,al
		xor	ch,ch
		inc	cx
		lodsb
		rep	stosb

NextByte:      	cmp	si,bp
		jb	UncompressLoop

		pop	es
		pop	ds

		ret

Uncompress	ENDP

;----------------------------------------------------------------------------

;* create VGA data (Screen1) from bit plane data (Screen2)
;*
;* then create approx EGA data (Screen2) from VGA data (Screen1)

CreateVGAData	PROC	NEAR

		push	ds
		push	es

		mov	bp,NumPlanes

		mov	ax,SEG Screen2
		mov	ds,ax

		mov	ax,SEG Screen1
		mov	es,ax

		xor	al,al		;clear Screen1
		mov	cx,SCR_SIZE
		mov	di,OFFSET Screen1
		rep	stosb
		
		mov	si,OFFSET Screen2
		mov	di,OFFSET Screen1

		mov	cx,200
LineLoop:	push	cx

		mov	dl,00001b	;plane mask

		mov	cx,bp
PlaneLoop:	push	cx

		mov	cx,40		;40 bytes / line

ByteLoop:	lodsb

		REPT	8
		cbw			;b7 = 0, ah = 000h, b7 = 1, ah = 0ffh
		and	ah,dl
		or	es:[di],ah
		rol	al,1
		inc	di
		ENDM

		loop	ByteLoop

		shl	dl,1
		sub	di,320

		pop	cx
		loop	PlaneLoop
		
		add	di,320

		pop	cx
		loop	LineLoop

;* create approx EGA data from VGA data

		mov	ax,SEG Screen1
		mov	ds,ax

		mov	ax,SEG Screen2
		mov	es,ax

		mov	cx,SCR_SIZE

		mov	si,OFFSET Screen1
		mov	di,OFFSET Screen2

EGALoop:	lodsb
		and	al,EGA_MASK
		stosb
		loop	EGALoop				

;* add START_COL to each pixel

		mov	ax,SEG Screen1
		mov	ds,ax
		mov	es,ax

		mov	cx,SCR_SIZE

		mov	si,OFFSET Screen1
		mov	di,OFFSET Screen1

AddLoop:	lodsb
		add	al,START_COL
		stosb
		loop	AddLoop				

;* now copy into Screen3

		mov	ax,SEG Screen3
		mov	es,ax

		mov	cx,SCR_SIZE

		mov	si,OFFSET Screen1
		mov	di,OFFSET Screen3
		
		rep	movsb

		pop	es
		pop	ds

		ret

CreateVGAData	ENDP

;----------------------------------------------------------------------------

Control		PROC	NEAR

		call	ShowMouse

ControlLoop:	call	HideMouse

;* toggle CGAHiLIte flag if 'C' key is pressed

		mov	al,Key[K_C]
		mov	ah,al
		xchg	ah,OldCGAKey
		test	al,al		;key pressed?
		jz	SkipCGAFlip	;no ->	     
		test	ah,ah		;was key pressed last time?
		jnz	SkipCgaFlip	;yes ->
		xor	CGAHiLite,1
SkipCGAFlip:
			
		call	ShowPalettes
	
		call	UpdateMouse
		call	ShowMouse

		call	TestColSelect

		mov	bl,RhsButton	;show EGA screen if RHS button pressed
		and	bx,1
		shl	bx,1
		call	DownLoad[bx]

		mov	al,Key[K_ESC]
		test	al,al
		jnz	ControlExit
		jmp	ControlLoop   
ControlExit:	ret

Control		ENDP

;----------------------------------------------------------------------------

ShowMouse	PROC	NEAR

		push	ds
		push	es

;* store background in MouseHouse

		mov	ax,MouseX
		mov	cx,ax
		mov	ax,MouseY
		mov	bl,al
		call	CalcAddr

		mov	ax,SEG Screen1
		mov	ds,ax

		mov	bp,di		;store for later

		mov	si,di
		mov	di,OFFSET MouseHouse

		REPT	M_DEPTH
		mov	cx,M_WIDTH
		rep	movsb
		add	si,320-M_WIDTH
		ENDM

		mov	ax,DATA
		mov	ds,ax
		
		mov	ax,SEG Screen1
		mov	es,ax

		mov	si,OFFSET MouseSprite
		mov	di,bp		;di -> screen

		mov	dx,M_DEPTH
MouseDrawLoop1:	mov	cx,M_WIDTH
MouseDrawLoop2:	lodsb
		cmp	al,CLR
		je	SkipPixel
		mov	es:[di],al
SkipPixel:	inc	di
		loop	MouseDrawLoop2
		add	di,320-M_WIDTH
		dec	dx
		jnz	MouseDrawLoop1

		pop	es
		pop	ds
		ret
	
ShowMouse	ENDP

;----------------------------------------------------------------------------

HideMouse	PROC	NEAR

		push	es

;* restore background from MouseHouse

		mov	ax,MouseX
		mov	cx,ax
		mov	ax,MouseY
		mov	bl,al
		call	CalcAddr

		mov	ax,SEG Screen1
		mov	es,ax

		mov	si,OFFSET MouseHouse

		REPT	M_DEPTH
		mov	cx,M_WIDTH
		rep	movsb
		add	di,320-M_WIDTH
		ENDM

		pop	es
		ret
	
HideMouse	ENDP

;----------------------------------------------------------------------------

;* pass: bl = y
;*       cx = x
;* ret : di = screen address
;* kill: ax, flags

CalcAddr    	PROC	NEAR

		mov	al,bl
		xor	ah,ah
		shl	ax,1		;y*2
		shl	ax,1		;y*4
		shl	ax,1		;y*8
		shl	ax,1		;y*16
		mov	di,ax
		shl	ax,1		;y*32
		shl	ax,1		;y*64
		add	di,ax		;y*80
		shl	di,1		;y*160
		shl	di,1		;y*320
		add	di,cx		;y*320+x
		ret

CalcAddr	ENDP

;----------------------------------------------------------------------------

ShowPalettes	PROC	NEAR

		push	ds
		push	es

		mov	bp,NumPlanes

		mov	al,Key[K_SPACE]
		or	al,MidButton
		jnz	ShowPalSprites
	
		mov	al,PaletteFlag
		test	al,al		;reload screen?
		jz	SkipReload	;no ->

		mov	PaletteFlag,0

		mov	ax,SEG Screen3
		mov	ds,ax

		mov	ax,SEG Screen1
		mov	es,ax

		mov	cx,SCR_SIZE

		mov	si,OFFSET Screen3
		mov	di,OFFSET Screen1

		rep	movsb

SkipReload:	jmp	ShowPalExit

ShowPalSprites:	mov	PaletteFlag,1

		mov	ax,SEG Screen1
		mov	es,ax

		mov	si,OFFSET HatchSprite
		xor	di,di

		mov	cx,16
EGALoop1:	push	cx

		REPT	4

		mov	cx,256
		rep	movsb
		add	di,320-256
		mov	cx,256
		rep	movsb
		add	di,320-256
		sub	si,512

		ENDM

		add	si,512

		pop	cx
		loop	EGALoop1

;* hi lite CGA colours

		mov	al,CGAHiLIte
		test	al,al
		jz	SkipHiLite

		mov	cx,16
		mov	si,OFFSET HiLiteTable
HiLiteLoop:	push	cx

		mov	al,[si+2]	;y
		xor	ah,ah
		mov	dx,8*320
		mul	dx
		add	ax,7*320
		mov	dx,ax

		mov	al,[si+1]	;x
		xor	ah,ah
		shl	ax,1		;*2
		shl	ax,1		;*4		
		shl	ax,1		;*8
		shl	ax,1		;*16
	
		xor	di,di
		add	di,ax
		add	di,dx

		mov	al,[si+0]	;col
		mov	cx,16
		rep	stosb

		add	si,3
		pop	cx
		loop	HiLiteLoop
		
SkipHiLite:

		mov	si,OFFSET Col16Sprite
		mov	di,144*320

		REPT	8

		mov	cx,256
		rep	movsb
		add	di,320-256
		sub	si,256

		ENDM

		mov	al,15
		mov	cx,256
		mov	di,143*320
		rep	stosb
		
		mov	al,15
		mov	cx,256
		mov	di,152*320
		rep	stosb

		mov	al,15
		mov	cx,256
		mov	di,161*320
		rep	stosb

		mov	bx,0
		mov	cx,16
		mov	di,153*320
ShowHatchLoop1:	push 	cx
		push	di

		mov	al,HatchFlags[bx]
		test	al,al		;has this colour been selected?
		jz	SkipThisCol1
		
		mov	al,HatchCols[bx]
		xor	ah,ah
		shl	ax,1
		shl	ax,1
		mov	si,OFFSET HatchTable
		add	si,ax

		mov	ax,SEG Screen3
		mov	ds,ax
	
		mov	al,[si]
		mov	ah,[si+1]

		mov	dx,DATA
		mov	ds,dx

		REPT	8

		mov	cx,8
		rep	stosw
		add	di,320-16
		xchg	al,ah

		ENDM

SkipThisCol1:	pop	di
		pop	cx
		add	di,16
		inc	bx
		dec	cx
		jz	EndHatchLp1
		jmp	ShowHatchLoop1
EndHatchLp1:
	
		cmp	bp,5		;32 colour picture?
		je	Do32Palette
		jmp	ShowPalExit	;no ->

Do32Palette:	mov	si,OFFSET Col32Sprite
		mov	di,168*320

		REPT	8

		mov	cx,256
		rep	movsb
		add	di,320-256
		sub	si,256

		ENDM

		mov	al,15
		mov	cx,256
		mov	di,167*320
		rep	stosb
		
		mov	al,15
		mov	cx,256
		mov	di,176*320
		rep	stosb

		mov	al,15
		mov	cx,256
		mov	di,185*320
		rep	stosb
	
		mov	bx,16
		mov	cx,16
		mov	di,177*320
ShowHatchLoop2:	push 	cx
		push	di

		mov	al,HatchFlags[bx]
		test	al,al		;has this colour been selected?
		jz	SkipThisCol2
		
		mov	al,HatchCols[bx]
		xor	ah,ah
		shl	ax,1
		shl	ax,1
		mov	si,OFFSET HatchTable
		add	si,ax

		mov	ax,SEG Screen3
		mov	ds,ax
	
		mov	al,[si]
		mov	ah,[si+1]

		mov	dx,DATA
		mov	ds,dx

		REPT	8

		mov	cx,8
		rep	stosw
		add	di,320-16
		xchg	al,ah

		ENDM

SkipThisCol2:	pop	di
		pop	cx
		add	di,16
		inc	bx
		dec	cx
		jz	EndHatchLp2
		jmp	ShowHatchLoop2
EndHatchLp2:
	
ShowPalExit:	pop	es
		pop	ds
		ret

ShowPalettes	ENDP

;----------------------------------------------------------------------------

TestColSelect	PROC	NEAR

		mov	al,LhsButton
		test	al,al
		jnz	DoLhsButton
		jmp	TestColExit
		
DoLhsButton:	mov	al,PaletteFlag
		test	al,al
		jnz	DisplayPalette

		mov	ax,MouseX
		mov	cx,ax
		mov	ax,MouseY
		mov	bx,ax
		call	CalcAddr

		mov	ax,SEG Screen3
		mov	es,ax

		mov	al,es:[di]		;read col

		mov	dx,DATA
		mov	es,dx

		jmp	SetSeekCol

DisplayPalette:	mov	ax,MouseX
		cmp	ax,256		;x in range?
		jae	TestColExit	;no ->

		mov	dx,ax

;* are we pointing at an xchg colour?

		mov	ax,MouseY
		cmp    	ax,127		;selecting EGA colour?
		ja	TestSeekCol	;no ->

		cmp	SeekCol,0	;seek col selected?
		je	TestColExit	;no ->

		shr	ax,1	
		shr	ax,1
		shr	ax,1		;/8
		and	dx,000f0h
		add	ax,dx		;x and 0f0h + y / 8
		mov	XchgCol,al

		mov	bl,SeekCol
		xor	bh,bh
		sub	bx,16
		mov	HatchCols[bx],al
		mov	HatchFlags[bx],1
		
		call	SeekAndXchg

		jmp	TestColExit

;* are we pointing at a seek colour?

TestSeekCol:	cmp	ax,144		;in first 16 cols?
		jb	TestColExit	;no ->
		cmp	ax,151
		jbe	First16		;yes ->

		cmp	NumPlanes,5	;32 colour picture?
		jne	TestColExit	;no ->

		cmp	ax,168		;in second 16 cols?
		jb	TestColExit	;no ->
		cmp	ax,175
		ja	TestColExit	;no ->

		mov	al,32
		jmp	CalcSeekCol

First16:	mov	al,16

CalcSeekCol:	shr	dx,1
		shr	dx,1
		shr	dx,1
		shr	dx,1

		add	al,dl

SetSeekCol:	mov	SeekCol,al
		
		mov	ah,010h
		mov	bh,al
		mov	al,1
		int	010h

TestColExit:	ret

TestColSelect	ENDP

;----------------------------------------------------------------------------

SeekAndXchg	PROC	NEAR

		push	ds
		push	es

		mov	al,XchgCol
		xor	ah,ah
		shl	ax,1
		shl	ax,1
		mov	bx,ax

		mov	dl,SeekCol

		xor	si,si

		mov	ax,SEG Screen3
		mov	ds,ax
		mov	ax,SEG Screen2
		mov	es,ax

		ASSUME	DS:SEG Screen3

		mov	cx,200
XchgLp1:	push	cx

		mov	cx,320
XchgLp2:	mov	al,[si]
		cmp	al,dl		;seek col here?
		jne	SkipXchg	;no ->

		mov	al,HatchTable[bx]
		mov	es:[si],al
		
SkipXchg:	inc	si
		xor	bx,0001b
		loop	XchgLp2

		xor	bx,0010b
		pop	cx
		loop	XchgLp1

		pop	es
		pop	ds

		ASSUME	DS:DATA

		ret

SeekAndXchg	ENDP

;----------------------------------------------------------------------------

CreateILBMData	PROC	NEAR

		mov	dx,OFFSET WtFileName
		call	CreateFile
		jc	CreateILBMError

		mov	cx,EGA_HDR_LEN
		mov	di,OFFSET EGAHeader
		call	FWrite
		jc	CreateILBMError

		xor	si,si

		mov	cx,200		;200 lines
WriteLoop:	push	cx
		push	si
		
		call	CreateLineData

		mov	cx,BIT_PLN_BUF_LEN
		mov	di,OFFSET BitPlaneBuffer
		call	FWrite
		jc	CreateILBMError

		pop	si
		add	si,320
		pop	cx
		loop	WriteLoop
		
		call	CloseFile
		jc	CreateILBMError

		ret

CreateILBMError:jmp	DiskError

CreateILBMData	ENDP

;----------------------------------------------------------------------------

CreateLineData	PROC	NEAR

		push	es

		xor	al,al

		mov	cx,40
		mov	di,OFFSET BitPlane0
		rep	stosb
		
		mov	cx,40
		mov	di,OFFSET BitPlane1
		rep	stosb

		mov	cx,40
		mov	di,OFFSET BitPlane2
		rep	stosb

		mov	cx,40
		mov	di,OFFSET BitPlane3
		rep	stosb
	
		mov	ax,SEG Screen2
		mov	es,ax

		xor	bx,bx

		mov	cx,40
CreateLoop:	push	cx

DO_BIT		MACRO	bit

		mov	al,es:[si+7-bit]
		mov	ah,al
	
		mov	al,ah
		and	al,0001b
		mov	cl,bit
		shl	al,cl
		or	BitPlane0[bx],al
		shr	ah,1

		mov	al,ah
		and	al,0001b
		mov	cl,bit
		shl	al,cl
		or	BitPlane1[bx],al
		shr	ah,1
			
		mov	al,ah
		and	al,0001b
		mov	cl,bit
		shl	al,cl
		or	BitPlane2[bx],al
		shr	ah,1
	
		mov	al,ah
		and	al,0001b
		mov	cl,bit
		shl	al,cl
		or	BitPlane3[bx],al
		shr	ah,1
	
		ENDM
	
		DO_BIT	7
		DO_BIT	6
		DO_BIT	5
		DO_BIT	4
		DO_BIT	3
		DO_BIT	2
		DO_BIT	1
		DO_BIT	0

		add	bx,1
		add	si,8

		pop	cx
		dec	cx
		jz	EndCreateLoop
		jmp	CreateLoop

EndCreateLoop:	pop	es
		ret

CreateLineData	ENDP

CODE		ENDS

;============================================================================

		END

