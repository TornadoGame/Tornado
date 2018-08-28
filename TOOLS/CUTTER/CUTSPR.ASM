;****************************************************************************
;*
;* CUTSPR.ASM
;*
;* 06.07.1989 - KJB
;* 22.08.1989 - KJB - "EVEN" written after sprite data added.
;*
;****************************************************************************

		PUBLIC	CutSprites

		EXTRN	CreateFile:FAR
		EXTRN	CloseFile:FAR
		EXTRN	UpdateMouse:FAR
		EXTRN	SetMousePos:FAR
		EXTRN	FWrite$:FAR
	
		EXTRN	GetReadFile:NEAR
		EXTRN	GetWriteFile:NEAR
       		EXTRN	LoadPicFile:NEAR
		EXTRN	VideoMode:NEAR
		EXTRN	DownLoad:NEAR
		EXTRN	DeltaDownLoad:NEAR
		EXTRN	SortRaw:NEAR
		EXTRN	SelectColour:NEAR
		EXTRN	ScanKeys:NEAR
		EXTRN	XorBox:NEAR
		EXTRN	UpdateBox:NEAR
		EXTRN	ResetBox:NEAR
		EXTRN	FrameWait:NEAR
		EXTRN	DiskError:NEAR
		EXTRN	CalcAddr:NEAR
		EXTRN	Beep:NEAR

       		EXTRN	ScreenType:WORD
		EXTRN	BoxX:WORD
		EXTRN	BoxY:WORD
		EXTRN	BoxWidth:WORD
		EXTRN	BoxDepth:WORD
		EXTRN	BoxMinWidth:WORD
		EXTRN	BoxMaxWidth:WORD
		EXTRN	BoxMinDepth:WORD
		EXTRN	BoxMaxDepth:WORD
		EXTRN	BoxXStep:WORD
		EXTRN	BoxYStep:WORD
		EXTRN	BoxXBoundary:WORD
		EXTRN	MouseX:WORD
		EXTRN	MouseY:WORD

		EXTRN	Key:BYTE
		EXTRN	MaskColour:BYTE
		EXTRN	WtFileName:BYTE
		EXTRN	RhsButton:BYTE
		EXTRN	DiskBuffer:BYTE
		EXTRN	WorkScreen:BYTE

;============================================================================

		INCLUDE KEYS.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

BEL		EQU	7
TAB		EQU	9
CR		EQU	13
LF		EQU	10

HexChars	DB	"0123456789abcdef"

SpriteType	DW	0		;0 = SSprite, 2 = MSprite, 4 = QSprite

DataType	DW	0		;0 = CGA / 2 = TANDY

DataPtr		DW	OFFSET CGABoxData
		DW	OFFSET TANBoxData

CGABoxData	DW	OFFSET CGABoxDataSS
		DW	OFFSET CGABoxDataMS
		DW	OFFSET CGABoxDataQS

TANBoxData	DW	OFFSET TANBoxDataSS
		DW	OFFSET TANBoxDataMS
		DW	OFFSET TANBoxDataQS

CGABoxDataSS	DW	8,16,2,320,1,200,2,1,0fffeh	;SSprite
CGABoxDataMS	DW	8,16,2,320,1,200,2,1,0fffeh	;MSprite
CGABoxDataQS	DW	8,16,4,320,1,200,4,1,0fff8h	;QSprite

TANBoxDataSS	DW	8,16,1,320,1,200,1,1,0fffeh	;SSprite
TANBoxDataMS	DW	8,16,1,320,1,200,1,1,0fffeh	;MSprite
TANBoxDataQS	DW	8,16,4,320,1,200,4,1,0fff8h	;QSprite

CutMode		DW	OFFSET CGAModes
		DW	OFFSET TANModes

CGAModes	DW	CGA_SSprite
		DW	CGA_MSprite
		DW	CGA_QSprite

TANModes	DW	TAN_SSprite
		DW	TAN_MSprite
		DW	TAN_QSprite

BLK		EQU	00000000b
CYN		EQU	01010101b
MAG		EQU	10101010b
WHT		EQU	11111111b

MaskPtr		DW	OFFSET ResetTable
PatternPtr	DW	OFFSET CGATable

;* convert 16 cols to 4 cols

CGATable	DB	BLK		;0000b
		DB	CYN		;0001b
		DB	BLK		;0010b
		DB	BLK		;0011b
		DB	MAG		;0100b
		DB	MAG		;0101b
		DB	BLK		;0110b
		DB	BLK		;0111b
		DB	BLK		;1000b
		DB	CYN		;1001b
		DB	CYN		;1010b
		DB	CYN		;1011b
		DB	MAG		;1100b
		DB	MAG		;1101b
		DB	WHT		;1110b
		DB	WHT		;1111b

SetTable	DB	16 DUP(WHT)
		
ResetTable	DB	16 DUP(BLK)

;-------------------------
;* TAN HEADERS AND FOOTERS
;-------------------------

TAN_SS_HDR	DB	";* TAN SSprite data "
		DB	"(screen co-ords "
TAN_SS_XPos	DB	"xxx, "
TAN_SS_YPos	DB	"yyy)"
		DB	CR,LF,CR,LF
		DB	TAB,TAB,"DW",TAB,'0'
TAN_SS_Width	DB	"xxxxh",TAB,TAB,";width in bytes",CR,LF
		DB	TAB,TAB,"DW",TAB,'0'
TAN_SS_Depth	DB	"xxxxh",TAB,TAB,";depth",CR,LF
		DB	TAB,TAB,"DW",TAB,'0'
TAN_SS_Width2	DB	"xxxxh*0"
TAN_SS_Depth2	DB	"xxxxh",TAB,";size",CR,LF
		DB	TAB,TAB,"DW",TAB,'0'
TAN_SS_XOffset	DB	"xxxxh",TAB,TAB,";x offset",CR,LF
		DB	TAB,TAB,"DW",TAB,'0'
TAN_SS_YOffset	DB	"xxxxh",TAB,TAB,";y offset",CR,LF
		DB	TAB,TAB,"DW",TAB,'0'
TAN_SS_Mask	DB	"xxxxh",TAB,TAB,";mask colour",CR,LF
		DB	TAB,TAB,"DW",TAB,'0',TAB,TAB,";EGA page",CR,LF
		DB	TAB,TAB,"DW",TAB,'0',TAB,TAB,";EGA page offset",CR,LF
		DB	CR,LF,'$'

		EVEN

TAN_SS_FTR	DB	TAB,TAB,"DB",TAB,'0'
TAN_SS_Width3	DB	"xxxxh*0"
TAN_SS_Depth3	DB	"xxxxh DUP(0)",CR,LF
		DB	CR,LF,'$'

		EVEN

TAN_SS_EXTRA	DB	TAB,TAB,"DB",TAB,'0'
TAN_SS_Buffer	DB	"xxxxh DUP(0)",TAB,";extra buffer required "
		DB	"for EGA masks",CR,LF
		DB	CR,LF,'$'

		EVEN

TAN_MS_HDR	DB	";* TAN MSprite data "
		DB	"(screen co-ords "
TAN_MS_XPos	DB	"xxx, "
TAN_MS_YPos	DB	"yyy)"
		DB	CR,LF,CR,LF
		DB	TAB,TAB,"DW",TAB,'0'
TAN_MS_Width	DB	"xxxxh",TAB,TAB,";width in bytes",CR,LF
		DB	TAB,TAB,"DW",TAB,'0'
TAN_MS_Depth	DB	"xxxxh",TAB,TAB,";depth",CR,LF
		DB	TAB,TAB,"DW",TAB,'0'
TAN_MS_Width2	DB	"xxxxh*0"
TAN_MS_Depth2	DB	"xxxxh",TAB,";size",CR,LF
		DB	TAB,TAB,"DW",TAB,'0'
TAN_MS_XOffset	DB	"xxxxh",TAB,TAB,";x offset",CR,LF
		DB	TAB,TAB,"DW",TAB,'0'
TAN_MS_YOffset	DB	"xxxxh",TAB,TAB,";y offset",CR,LF
		DB	TAB,TAB,"DW",TAB,'0'
TAN_MS_Mask	DB	"xxxxh",TAB,TAB,";mask colour",CR,LF
		DB	TAB,TAB,"DW",TAB,'0',TAB,TAB,";EGA page",CR,LF
		DB	TAB,TAB,"DW",TAB,'0',TAB,TAB,";EGA page offset",CR,LF
		DB	CR,LF,'$'

		EVEN

TAN_MS_FTR	DB	TAB,TAB,"DB",TAB,'0'
TAN_MS_Width3	DB	"xxxxh*0"
TAN_MS_Depth3	DB	"xxxxh DUP(0)",CR,LF
		DB	CR,LF,'$'

		EVEN

TAN_QS_HDR	DB	";* TAN QSprite data "
		DB	"(screen co-ords "
TAN_QS_XPos	DB	"xxx, "
TAN_QS_YPos	DB	"yyy)"
		DB	CR,LF,CR,LF
		DB	TAB,TAB,"DW",TAB,'0'
TAN_QS_Width	DB	"xxxxh",TAB,TAB,";width in bytes",CR,LF
		DB	TAB,TAB,"DW",TAB,'0'
TAN_QS_Depth	DB	"xxxxh",TAB,TAB,";depth",CR,LF
		DB	TAB,TAB,"DW",TAB,'0',TAB,TAB,";EGA page",CR,LF
		DB	TAB,TAB,"DW",TAB,'0',TAB,TAB,";EGA page offset",CR,LF
		DB	CR,LF,'$'

		EVEN

;-------------------------
;* CGA HEADERS AND FOOTERS
;-------------------------

CGA_SS_HDR	DB	";* CGA SSprite data "
		DB	"(screen co-ords "
CGA_SS_XPos	DB	"xxx, "
CGA_SS_YPos	DB	"yyy)"
		DB	CR,LF,CR,LF
		DB	TAB,TAB,"DW",TAB,'0'
CGA_SS_Width	DB	"xxxxh",TAB,TAB,";width in bytes "
		DB	"(inc. shift into byte)",CR,LF
		DB	TAB,TAB,"DW",TAB,'0'
CGA_SS_Depth	DB	"xxxxh",TAB,TAB,";depth",CR,LF
		DB	TAB,TAB,"DW",TAB,'0'
CGA_SS_XOffset	DB	"xxxxh",TAB,TAB,";x offset",CR,LF
		DB	TAB,TAB,"DW",TAB,'0'
CGA_SS_YOffset	DB	"xxxxh",TAB,TAB,";y offset",CR,LF
		DB	TAB,TAB,"DW",TAB,'0',TAB,TAB,";shift 0 ptr",CR,LF
		DB	TAB,TAB,"DW",TAB,'0',TAB,TAB,";shift 2 ptr",CR,LF
		DB	CR,LF,'$'

		EVEN

CGA_SS_FTR	DB	TAB,TAB,"DB",TAB,'0'
CGA_SS_Width2	DB	"xxxxh*0"
CGA_SS_Depth2	DB	"xxxxh*2 DUP(0)",CR,LF
		DB	CR,LF,'$'

		EVEN

CGA_MS_HDR	DB	";* CGA MSprite data "
		DB	"(screen co-ords "
CGA_MS_XPos	DB	"xxx, "
CGA_MS_YPos	DB	"yyy)"
		DB	CR,LF,CR,LF
		DB	TAB,TAB,"DW",TAB,'0'
CGA_MS_Width	DB	"xxxxh",TAB,TAB,";width in bytes ",CR,LF
		DB	TAB,TAB,"DW",TAB,'0'
CGA_MS_Depth	DB	"xxxxh",TAB,TAB,";depth",CR,LF
		DB	TAB,TAB,"DW",TAB,'0'
CGA_MS_XOffset	DB	"xxxxh",TAB,TAB,";x offset",CR,LF
		DB	TAB,TAB,"DW",TAB,'0'
CGA_MS_YOffset	DB	"xxxxh",TAB,TAB,";y offset",CR,LF
		DB	TAB,TAB,"DW",TAB,'0',TAB,TAB,";shift 0 ptr",CR,LF
		DB	TAB,TAB,"DW",TAB,'0',TAB,TAB,";shift 2 ptr "
		DB	"(same as shift 0)",CR,LF
		DB	CR,LF,'$'

		EVEN

CGA_QS_HDR	DB	";* CGA QSprite data "
		DB	"(screen co-ords "
CGA_QS_XPos	DB	"xxx, "
CGA_QS_YPos	DB	"yyy)"
		DB	CR,LF,CR,LF
		DB	TAB,TAB,"DW",TAB,'0'
CGA_QS_Width	DB	"xxxxh",TAB,TAB,";width in bytes ",CR,LF
		DB	TAB,TAB,"DW",TAB,'0'
CGA_QS_Depth	DB	"xxxxh",TAB,TAB,";depth",CR,LF
		DB	CR,LF,'$'

		EVEN

EVEN$		DB	TAB,TAB,"EVEN",CR,LF,CR,LF,'$'

;----------
;* MESSAGES
;----------

Msg1$		DB	CR,LF,CR,LF
		DB	"Cut Sprites",CR,LF
		DB	"-----------",CR,LF
		DB	CR,LF
		DB	"(read EGA *.LBM files only)"
		DB	'$'

		EVEN

Msg2$		DB	CR,LF,CR,LF
		DB	"Select sprite data format:-",CR,LF
		DB	CR,LF
		DB	"A ... CGA",CR,LF
		DB	" B ... TANDY",CR,LF
		DB	CR,LF
		DB	"Hit key A - B ... "
		DB	'$'

		EVEN

Msg3$		DB	CR,LF,CR,LF
		DB	"Select sprite type:-",CR,LF
		DB	CR,LF
		DB	"A ... SSprite (shifted sprite)",CR,LF
		DB	" B ... MSprite (masked sprite)",CR,LF
		DB	"  C ... QSprite (quick sprite)",CR,LF
		DB	CR,LF
		DB	"Hit key A - C ... "
		DB	'$'
		
		EVEN

Msg4$		DB	CR,LF,CR,LF
		DB	"Select mask colour:-"
		DB	'$'

		EVEN

DATA		ENDS

;============================================================================

CODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:CODE
		ASSUME DS:DATA

;* CutSprites - cut out sprites
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

CutSprites	PROC	NEAR

;* get read and write file names

		mov	ah,9
		mov	dx,OFFSET Msg1$
		int	021h

		call	GetReadFile

		call	GetWriteFile

		mov	ah,9
		mov	dx,OFFSET Msg2$
		int	021h

		mov	dx,'B'-'A'
		call	ScanKeys

		shl	bx,1
		mov	DataType,bx

;* get sprite type

		mov	ah,9
		mov	dx,OFFSET Msg3$
		int	021h

		mov	dx,'C'-'A'
		call	ScanKeys

		shl	bx,1
		mov	SpriteType,bx

;* set box parameters wrt data type

		mov	si,DataType
		mov	si,DataPtr[si]
		mov	si,[bx+si]

		lodsw
		mov	BoxWidth,ax
		lodsw
		mov	BoxDepth,ax
		lodsw
		mov	BoxMinWidth,ax
		lodsw
		mov	BoxMaxWidth,ax
		lodsw
		mov	BoxMinDepth,ax
		lodsw
		mov	BoxMaxDepth,ax
		lodsw
		mov	BoxXStep,ax
		lodsw
		mov	BoxYStep,ax
		lodsw	
		mov	BoxXBoundary,ax

;* select mask colour (not required for QSprites)
		
		mov	MaskColour,-1	;assume no mask

		cmp	SpriteType,4
		je	NoMask

		mov	ah,9
		mov	dx,OFFSET Msg4$
		int	021h

		call	SelectColour

NoMask:

;* load picture file

		mov	ScreenType,2	;Read EGA only

		call	VideoMode
		call	LoadPicFile
		call	SortRaw
		call	DownLoad

;* create write file

		mov	dx,OFFSET WtFileName
		call	CreateFile
		jnc	CreateOk
		jmp	DiskError
CreateOk:

;* display initial box

		call	ResetBox
		call	XorBox
		call	DeltaDownLoad

;* cut the sprites
		
		call	ManualCut

;* close write file

		call	CloseFile
		jnc	CloseOk
		jmp	DiskError	
CloseOk:	ret

CutSprites	ENDP

;----------------------------------------------------------------------------

;* ManualCut - cut chars manually
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

ManualCut	PROC	NEAR

CutLoop:	mov	al,Key[K_ESC]	;test for ESCape
		test	al,al
		jnz	CutDone

;* update box

		call	UpdateBox
		call	DeltaDownLoad

;* write data if 'W' key pressed or rh mouse button pressed

	  	mov	al,RhsButton
		or	al,Key[K_W]
		jz	SkipWrite

		call	XorBox
		call	DeltaDownLoad

		call	Beep

		mov	bx,DataType
		mov	si,CutMode[bx]
		mov	bx,SpriteType
		call	[si+bx]

		call	XorBox
		call	DeltaDownLoad

;* wait for 'W' key and / or rh mouse button to be released
		
		mov	cx,MouseX
		mov	dx,MouseY
		push	cx
		push	dx
NotReleased:  	call	UpdateMouse
		mov	al,RhsButton
		or	al,Key[K_W]
		jnz	NotReleased
		pop	dx
		pop	cx
		call	SetMousePos

SkipWrite:	call	FrameWait

		jmp	CutLoop

CutDone:	ret

ManualCut	ENDP

;----------------------------------------------------------------------------

;* CGA_SSprite - cut CGA SSprite
;*
;* pass: box parameters
;*       MaskColour
;* ret : nothing
;* kill: assume all

CGA_SSprite	PROC	NEAR

;* sort header parameters

;* x, y co-ords

		mov	ax,BoxX
		mov	di,OFFSET CGA_SS_XPos
		call	DecWord$
		mov	ax,BoxY
		mov	di,OFFSET CGA_SS_YPos
		call	DecWord$

;* width in bytes = (BoxWidth / 2) + 1

		mov	ax,BoxWidth 
		shr	ax,1   
		inc	ax     
		mov	di,OFFSET CGA_SS_Width
		call	HexWord$

;* depth = BoxDepth
		
		mov	ax,BoxDepth
		mov	di,OFFSET CGA_SS_Depth
		call	HexWord$

;* x offset = -(BoxWidth)

		mov	ax,BoxWidth
		neg	ax
		mov	di,OFFSET CGA_SS_XOffset
		call	HexWord$

;* y offset = -(BoxDepth / 2)

		mov	ax,BoxDepth
		shr	ax,1
		neg	ax
		mov	di,OFFSET CGA_SS_YOffset
		call	HexWord$

		mov	di,OFFSET CGA_SS_HDR
		call	FWrite$

		mov	MaskPtr,OFFSET SetTable
		mov	PatternPtr,OFFSET ResetTable
		call	GenCGAData

		mov	MaskPtr,OFFSET ResetTable
		mov	PatternPtr,OFFSET CGATable
		call	GenCGAData

;* sort footer parameters

;* width in bytes = (BoxWidth / 2) + 1

		mov	ax,BoxWidth 
		shr	ax,1   
		inc	ax     
		mov	di,OFFSET CGA_SS_Width2
		call	HexWord$

;* depth = BoxDepth
		
		mov	ax,BoxDepth
		mov	di,OFFSET CGA_SS_Depth2
		call	HexWord$

		mov	di,OFFSET CGA_SS_FTR
		call	FWrite$

		mov	di,OFFSET EVEN$
		call	FWrite$

		ret

CGA_SSprite	ENDP

;----------------------------------------------------------------------------

;* CGA_MSprite - cut CGA MSprite
;*
;* pass: box parameters
;*       MaskColour
;* ret : nothing
;* kill: assume all

CGA_MSprite	PROC	NEAR

;* sort header parameters

;* x, y co-ords

		mov	ax,BoxX
		mov	di,OFFSET CGA_MS_XPos
		call	DecWord$
		mov	ax,BoxY
		mov	di,OFFSET CGA_MS_YPos
		call	DecWord$

;* width in bytes = (BoxWidth / 2)

		mov	ax,BoxWidth 
		shr	ax,1   
		mov	di,OFFSET CGA_MS_Width
		call	HexWord$

;* depth = BoxDepth
		
		mov	ax,BoxDepth
		mov	di,OFFSET CGA_MS_Depth
		call	HexWord$

;* x offset = -(BoxWidth)

		mov	ax,BoxWidth
		neg	ax
		mov	di,OFFSET CGA_MS_XOffset
		call	HexWord$

;* y offset = -(BoxDepth / 2)

		mov	ax,BoxDepth
		shr	ax,1
		neg	ax
		mov	di,OFFSET CGA_MS_YOffset
		call	HexWord$

		mov	di,OFFSET CGA_MS_HDR
		call	FWrite$

		mov	MaskPtr,OFFSET SetTable
		mov	PatternPtr,OFFSET ResetTable
		call	GenCGAData

		mov	MaskPtr,OFFSET ResetTable
		mov	PatternPtr,OFFSET CGATable
		call	GenCGAData

		mov	di,OFFSET EVEN$
		call	FWrite$

		ret

CGA_MSprite	ENDP

;----------------------------------------------------------------------------

;* CGA_QSprite - cut CGA QSprite
;*
;* pass: box parameters
;*       MaskColour
;* ret : nothing
;* kill: assume all

CGA_QSprite	PROC	NEAR

;* sort header parameters

;* x, y co-ords

		mov	ax,BoxX
		mov	di,OFFSET CGA_QS_XPos
		call	DecWord$
		mov	ax,BoxY
		mov	di,OFFSET CGA_QS_YPos
		call	DecWord$

;* width in bytes = (BoxWidth / 2)

		mov	ax,BoxWidth 
		shr	ax,1   
		mov	di,OFFSET CGA_QS_Width
		call	HexWord$

;* depth = BoxDepth
		
		mov	ax,BoxDepth
		mov	di,OFFSET CGA_QS_Depth
		call	HexWord$

		mov	di,OFFSET CGA_QS_HDR
		call	FWrite$

		mov	MaskPtr,OFFSET CGATable
		mov	PatternPtr,OFFSET CGATable
		call	GenCGAData

		mov	di,OFFSET EVEN$
		call	FWrite$

		ret

CGA_QSprite	ENDP

;----------------------------------------------------------------------------

;* TAN_SSprite - cut TAN SSprite
;*
;* pass: box parameters
;*       MaskColour
;* ret : nothing
;* kill: assume all

TAN_SSprite	PROC	NEAR

;* sort header parameters

;* x, y co-ords

		mov	ax,BoxX
		mov	di,OFFSET TAN_SS_XPos
		call	DecWord$
		mov	ax,BoxY
		mov	di,OFFSET TAN_SS_YPos
		call	DecWord$

;* width in bytes

		mov	ax,BoxWidth 
		mov	di,OFFSET TAN_SS_Width
		call	HexWord$

;* depth = BoxDepth
		
		mov	ax,BoxDepth
		mov	di,OFFSET TAN_SS_Depth
		call	HexWord$

;* width in bytes

		mov	ax,BoxWidth 
		mov	di,OFFSET TAN_SS_Width2
		call	HexWord$

;* depth = BoxDepth
		
		mov	ax,BoxDepth
		mov	di,OFFSET TAN_SS_Depth2
		call	HexWord$

;* x offset = -(BoxWidth)

		mov	ax,BoxWidth
		neg	ax
		mov	di,OFFSET TAN_SS_XOffset
		call	HexWord$

;* y offset = -(BoxDepth / 2)

		mov	ax,BoxDepth
		shr	ax,1
		neg	ax
		mov	di,OFFSET TAN_SS_YOffset
		call	HexWord$

;* mask colour
		
		mov	al,MaskColour
		and	al,00fh
		mov	ah,al
		shl	ah,1
		shl	ah,1
		shl	ah,1
		shl	ah,1
		or	al,ah
		mov	ah,al
		mov	di,OFFSET TAN_SS_Mask
		call	HexWord$
	
		mov	di,OFFSET TAN_SS_HDR
		call	FWrite$

		call	GenTANData

;* sort footer parameters

;* width in bytes

		mov	ax,BoxWidth 
		mov	di,OFFSET TAN_SS_Width3
		call	HexWord$

;* depth = BoxDepth
		
		mov	ax,BoxDepth
		mov	di,OFFSET TAN_SS_Depth3
		call	HexWord$

		mov	di,OFFSET TAN_SS_FTR
		call	FWrite$

;* sort extra data

;* calc size of TAN data

		mov	ax,BoxWidth
		mov	bx,BoxDepth
		mul	bx
		shl	ax,1		;*2 for mask and pattern data
		mov	bp,ax		;bp = size of TAN data

;* calc size of EGA shifted mask data

		mov	ax,BoxWidth
		mov	bx,ax
		shr	ax,1
		shr	ax,1
		and	bx,0011b	;round up if any remainder
		cmp	bx,1		;0 = cf = 1; 1, 2 or 3 = cf = 0
		cmc			;0 = cf = 0; 1, 2 or 3 = cf = 1
		adc	ax,0		;add 1 if remainder
		inc	ax		;add 1 for shift byte
		mov	bx,BoxDepth
		mul	bx
		shl	ax,1		;*4 for 4 shifts
		shl	ax,1		;ax = size required for EGA masks

		sub	ax,bp		;diff in data sizes
		jbe	EnoughRoom	;TAN data size >= EGA size required

		mov	di,OFFSET TAN_SS_Buffer
		call	HexWord$
 
		mov	di,OFFSET TAN_SS_EXTRA
		call	FWrite$

EnoughRoom:	mov	di,OFFSET EVEN$
		call	FWrite$

		ret

TAN_SSprite	ENDP

;----------------------------------------------------------------------------

;* TAN_MSprite - cut TAN MSprite
;*
;* pass: box parameters
;*       MaskColour
;* ret : nothing
;* kill: assume all

TAN_MSprite	PROC	NEAR

;* sort header parameters

;* x, y co-ords

		mov	ax,BoxX
		mov	di,OFFSET TAN_MS_XPos
		call	DecWord$
		mov	ax,BoxY
		mov	di,OFFSET TAN_MS_YPos
		call	DecWord$

;* width in bytes

		mov	ax,BoxWidth 
		mov	di,OFFSET TAN_MS_Width
		call	HexWord$

;* depth = BoxDepth
		
		mov	ax,BoxDepth
		mov	di,OFFSET TAN_MS_Depth
		call	HexWord$

;* width in bytes

		mov	ax,BoxWidth 
		mov	di,OFFSET TAN_MS_Width2
		call	HexWord$

;* depth = BoxDepth
		
		mov	ax,BoxDepth
		mov	di,OFFSET TAN_MS_Depth2
		call	HexWord$

;* x offset = -(BoxWidth)

		mov	ax,BoxWidth
		neg	ax
		mov	di,OFFSET TAN_MS_XOffset
		call	HexWord$

;* y offset = -(BoxDepth / 2)

		mov	ax,BoxDepth
		shr	ax,1
		neg	ax
		mov	di,OFFSET TAN_MS_YOffset
		call	HexWord$

;* mask colour
		
		mov	al,MaskColour
		and	al,00fh
		mov	ah,al
		shl	ah,1
		shl	ah,1
		shl	ah,1
		shl	ah,1
		or	al,ah
		mov	ah,al
		mov	di,OFFSET TAN_MS_Mask
		call	HexWord$
	
		mov	di,OFFSET TAN_MS_HDR
		call	FWrite$

		call	GenTANData

;* sort footer parameters

;* width in bytes

		mov	ax,BoxWidth 
		mov	di,OFFSET TAN_MS_Width3
		call	HexWord$

;* depth = BoxDepth
		
		mov	ax,BoxDepth
		mov	di,OFFSET TAN_MS_Depth3
		call	HexWord$

		mov	di,OFFSET TAN_MS_FTR
		call	FWrite$

		mov	di,OFFSET EVEN$
		call	FWrite$

		ret

TAN_MSprite	ENDP

;----------------------------------------------------------------------------

;* TAN_QSprite - cut TAN QSprite
;*
;* pass: box parameters
;*       MaskColour
;* ret : nothing
;* kill: assume all

TAN_QSprite	PROC	NEAR

;* sort header parameters

;* x, y co-ords

		mov	ax,BoxX
		mov	di,OFFSET TAN_QS_XPos
		call	DecWord$
		mov	ax,BoxY
		mov	di,OFFSET TAN_QS_YPos
		call	DecWord$

;* width in bytes

		mov	ax,BoxWidth 
		mov	di,OFFSET TAN_QS_Width
		call	HexWord$

;* depth = BoxDepth
		
		mov	ax,BoxDepth
		mov	di,OFFSET TAN_QS_Depth
		call	HexWord$

		mov	di,OFFSET TAN_QS_HDR
		call	FWrite$

		call	GenTANData

		mov	di,OFFSET EVEN$
		call	FWrite$

		ret

TAN_QSprite	ENDP

;----------------------------------------------------------------------------

;* GenCGAData - generate CGA sprite data
;*
;* pass: MaskPtr
;*       PatternPtr
;*       MaskColour
;*       BoxX
;*       BoxY
;*       BoxWidth
;*       BoxDepth
;* ret : nothing
;* kill: assume all

GenCGAData	PROC	NEAR

		push	es

		mov	bl,BYTE PTR BoxY
		mov	cx,BoxX
		call	CalcAddr
		mov	si,di

		mov	ax,SEG DiskBuffer
		mov	es,ax
		mov	di,OFFSET DiskBuffer

		mov	cx,BoxWidth
		shr	cx,1		;width in words (4 pixels / byte)
		mov	dx,BoxDepth

		xor	bp,bp		;byte counter

;* cx = width (words)
;* dx = depth
;* bp = byte counter
;* ds:si -> screen
;* es:di -> disk buffer

GenCGALoop1:	push	cx
		push	dx
		push	bp
		push	si
		push	di

GenCGALoop2:	lodsw 			;al = nibbles AB, ah = nibbles CD

		call	SortCGANibbles	;al = compacted byte

		call	PutHexByte

		loop	GenCGALoop2

;* if SSprite then add "shift into" byte (0ffh for mask, 000h for pattern)

		cmp	SpriteType,0	;SSprite?
		jne	NotCGASSprite	;no ->

		mov	bx,MaskPtr	;0ffh for mask, 000h for pattern
		mov	al,[bx]
		call	PutHexByte

NotCGASSprite:	cmp	bp,0		;if cntr 0 skip new line
		je	SkipCGANewLn
		mov	es:[di+0],BYTE PTR CR
		mov	es:[di+1],BYTE PTR LF
		add	di,2
SkipCGANewLn:	mov	es:[di+0],BYTE PTR '$'

		mov	di,OFFSET DiskBuffer
		call	FWrite$
		jnc	WriteCGADataOk
		jmp	DiskError

WriteCGADataOk:	pop	di
		pop	si
		pop	bp
		pop	dx
		pop	cx
		add	si,160		;next line
		dec	dx
		jnz	GenCGALoop1

		mov	di,OFFSET DiskBuffer
		mov	es:[di+0],BYTE PTR CR
		mov	es:[di+1],BYTE PTR LF
		mov	es:[di+2],BYTE PTR '$'
		call	FWrite$

		pop	es
		ret

GenCGAData	ENDP

;----------------------------------------------------------------------------

;* SortCGANibbles
;*
;* pass: al,ah = ABCD
;*       MaskPtr
;*       PatternPtr
;*       MaskColour
;* ret : al = ABCD compacted into byte
;*       si -> next word
;* kill: ah, bx, dx, flags

SortCGANibbles	PROC	NEAR

		xor	dh,dh		;clear result

;* sort nibble A

		mov	dl,al		
		and	al,0f0h		
		shr	al,1
		shr	al,1
		shr	al,1
		shr	al,1
		mov	bx,PatternPtr	;assume non-mask
		cmp	al,MaskColour
		jne	GenCGAPtrOkA
		mov	bx,MaskPtr
GenCGAPtrOkA:	xlat
		and	al,11000000b
		or	dh,al

;* sort nibble B

		mov	al,dl		
		and	al,00fh		
		mov	bx,PatternPtr	;assume non-mask
		cmp	al,MaskColour
		jne	GenCGAPtrOkB
		mov	bx,MaskPtr
GenCGAPtrOkB:	xlat
		and	al,00110000b
		or	dh,al

;* sort nibble C

		mov	al,ah		
		and	al,0f0h		
		shr	al,1
		shr	al,1
		shr	al,1
		shr	al,1
		mov	bx,PatternPtr	;assume non-mask
		cmp	al,MaskColour
		jne	GenCGAPtrOkC
		mov	bx,MaskPtr
GenCGAPtrOkC:	xlat
		and	al,00001100b
		or	dh,al

;* sort nibble D

		mov	al,ah		
		and	al,00fh		
		mov	bx,PatternPtr	;assume non-mask
		cmp	al,MaskColour
		jne	GenCGAPtrOkD
		mov	bx,MaskPtr
GenCGAPtrOkD:	xlat
		and	al,00000011b
		or	al,dh

		ret

SortCGANibbles	ENDP

;----------------------------------------------------------------------------

;* PutHexByte - put hex byte into disk buffer
;*
;* pass: al = byte
;*       bp = byte counter
;*       es:di -> disk buffer
;* ret : bp modified
;*       es:di updated
;* kill: ax, bx, flags

PutHexByte	PROC	NEAR

		cmp	bp,0		;new line?
		jne	ContinueLine	;no ->

		mov	es:[di+0],BYTE PTR TAB
		mov	es:[di+1],BYTE PTR TAB
		mov	es:[di+2],BYTE PTR 'D'
		mov	es:[di+3],BYTE PTR 'B'
		mov	es:[di+4],BYTE PTR TAB
		add	di,5
		jmp	SortHexByte

ContinueLine:	mov	es:[di+0],BYTE PTR ','
		add	di,1

SortHexByte:	mov	es:[di+0],BYTE PTR '0'

		mov	bx,OFFSET HexChars

		mov	ah,al
	     	shr	al,1
		shr	al,1
		shr	al,1
		shr	al,1
		xlat
		mov	es:[di+1],al
		mov	al,ah
		and	al,00fh
		xlat
		mov	es:[di+2],al
		mov	es:[di+3],BYTE PTR 'h'
		add	di,4

		inc	bp
		cmp	bp,8		;end of line?
		jne	ExitHexByte	;no ->
	  
		mov	es:[di+0],BYTE PTR CR
		mov	es:[di+1],BYTE PTR LF
		add	di,2
	
		xor	bp,bp

ExitHexByte:	ret

PutHexByte	ENDP

;----------------------------------------------------------------------------

;* HexWord$ - calc hex word and put into string
;*
;* pass: ax = word
;*       es:di -> string
;* ret : hex word in string
;* kill: ax, bx, cx, dx, di, flags

HexWord$	PROC	NEAR

		mov	bx,OFFSET HexChars
		mov	cx,4
		mov	dx,ax

HexWord$Loop:	mov	al,dh
		shr	al,1
		shr	al,1
		shr	al,1
		shr	al,1
		xlat
		stosb
		shl	dx,1
		shl	dx,1
		shl	dx,1
		shl	dx,1
		loop	HexWord$Loop

		ret

HexWord$	ENDP

;----------------------------------------------------------------------------

;* DecWord$ - calc dec word 0 - 999 and put into string
;*
;* pass: ax = dec word
;*       es:di -> string
;* ret : dec word in string
;* kill: ax, bx, dx, flags

DecWord$	PROC	NEAR

Hundreds:	cmp	ax,99
		jbe	NoHundreds

		xor	dx,dx
		mov	bx,100
		div	bx
		add	al,'0'
		stosb
		mov	ax,dx
		jmp	Tens

NoHundreds:	mov	es:[di],BYTE PTR '0'
		inc	di

Tens:		cmp	ax,9
		jbe	NoTens

		xor	dx,dx
		mov	bx,10
		div	bx
		add	al,'0'
		stosb
		mov	ax,dx
		jmp	Units

NoTens:		mov	es:[di],BYTE PTR '0'
		inc	di

Units:		add	al,'0'
		stosb
		ret
		
DecWord$	ENDP

;----------------------------------------------------------------------------

;* GenTANData - generate TAN sprite data
;*
;* pass: MaskColour
;*       BoxX
;*       BoxY
;*       BoxWidth
;*       BoxDepth
;* ret : nothing
;* kill: assume all

GenTANData	PROC	NEAR

		push	es

		mov	bl,BYTE PTR BoxY
		mov	cx,BoxX
		call	CalcAddr
		mov	si,di

		mov	ax,SEG DiskBuffer
		mov	es,ax
		mov	di,OFFSET DiskBuffer

		mov	cx,BoxWidth
		mov	dx,BoxDepth

		xor	bp,bp		;byte counter

;* cx = width (bytes)
;* dx = depth
;* bp = byte counter
;* ds:si -> screen
;* es:di -> disk buffer

GenTANLoop1:	push	cx
		push	dx
		push	bp
		push	si
		push	di

GenTANLoop2:	lodsb

		call	PutHexByte

		loop	GenTANLoop2

		cmp	bp,0		;if cntr 0 skip new line
		je	SkipTANNewLn
		mov	es:[di+0],BYTE PTR CR
		mov	es:[di+1],BYTE PTR LF
		add	di,2
SkipTANNewLn:	mov	es:[di+0],BYTE PTR '$'

		mov	di,OFFSET DiskBuffer
		call	FWrite$
		jnc	WriteTANDataOk
		jmp	DiskError

WriteTANDataOk:	pop	di
		pop	si
		pop	bp
		pop	dx
		pop	cx
		add	si,160		;next line
		dec	dx
		jnz	GenTANLoop1

		mov	di,OFFSET DiskBuffer
		mov	es:[di+0],BYTE PTR CR
		mov	es:[di+1],BYTE PTR LF
		mov	es:[di+2],BYTE PTR '$'
		call	FWrite$

		pop	es
		ret

GenTANData	ENDP

CODE		ENDS

;============================================================================

		END

