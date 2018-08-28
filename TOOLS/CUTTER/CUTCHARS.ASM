;****************************************************************************
;*
;* CUTCHARS.ASM
;*
;* 06.07.1989 - KJB
;*
;****************************************************************************

		PUBLIC	CutChars

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

CutMode		DW	0		;0 = auto, 2 = manual

ModeVars	STRUC
XStart		DW	0
YStart		DW	0
XCntr		DW	0
YCntr		DW	0
XAdd		DW	0
YAdd		DW	0
ModeVars	ENDS

AutoPtr		DW	OFFSET Auto7_9
		DW	OFFSET Auto3_5

Auto7_9		ModeVars <0,0,16,6,8,11>
Auto3_5		ModeVars <0,0,16,6,4,6>

CutCharacters	DW	AutoCut
		DW	ManualCut

CharType	DW	0		;0 = 7*9, 2 = 3*5

CharPtr		DW	OFFSET Char7_9
		DW	OFFSET Char3_5

Char7_9		DW	4,9,4,4,9,9,0,0,0fffeh
Char3_5		DW	2,5,2,2,5,5,0,0,0fffeh

WriteCharData	DW	Write7_9
		DW	Write3_5

Msg1$		DB	CR,LF,CR,LF
		DB	"Cut Character Set",CR,LF
		DB	"-----------------",CR,LF
		DB	CR,LF
		DB	"(read EGA *.LBM files only)"
		DB	'$'

		EVEN

Msg2$		DB	CR,LF,CR,LF
		DB	"Select character size:-",CR,LF,CR,LF
		DB	"A ... 7 * 9 pixels",CR,LF
		DB	" B ... 3 * 5 pixels",CR,LF
		DB	CR,LF
		DB	"Hit key A - B ... "
		DB	'$'

		EVEN

Msg3$		DB	CR,LF,CR,LF
		DB	"Select ink colour of character set:-"
		DB	'$'

		EVEN
		
Msg4$		DB	CR,LF,CR,LF
		DB	"Select mode:-",CR,LF,CR,LF
		DB	"A ... Automatic",CR,LF
		DB	" B ... Manual",CR,LF
		DB	CR,LF
		DB	"Hit key A - B ... "
		DB	'$'

		EVEN

DATA		ENDS

;============================================================================

CODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:CODE
		ASSUME DS:DATA

;* CutChars - cut out characters
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

CutChars	PROC	NEAR

;* get read and write file names

		mov	ah,9
		mov	dx,OFFSET Msg1$
		int	021h

		call	GetReadFile

		call	GetWriteFile

;* get type of character to cut

		mov	ah,9
		mov	dx,OFFSET Msg2$
		int	021h

		mov	dx,'B'-'A'
		call	ScanKeys

		shl	bx,1
		mov	CharType,bx

;* set box parameters wrt character type

		mov	si,CharPtr[bx]
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

;* select ink colour

		mov	ah,9
		mov	dx,OFFSET Msg3$
		int	021h

		call	SelectColour

;* select automatic or manual mode

		mov	ah,9
		mov	dx,OFFSET Msg4$
		int	021h

		mov	dx,'B'-'A'
		call	ScanKeys

		shl	bx,1
		mov	CutMode,bx

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

;* cut the characters

		mov	bx,CutMode
		call	CutCharacters[bx]

;* close write file

		call	CloseFile
		jnc	CloseOk
		jmp	DiskError	
CloseOk:	ret

CutChars	ENDP

;----------------------------------------------------------------------------

;* Write7_9 - write data for 7 * 9 character
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

Write7_9	PROC	NEAR

		push	ds
		push	es

		mov	bl,BYTE PTR BoxY
		mov	cx,BoxX
		call	CalcAddr
		mov	si,di

		mov	dl,MaskColour		;dl = lo nibble compare mask
		mov	dh,dl
		shl	dh,1
		shl	dh,1
		shl	dh,1
		shl	dh,1			;dh = hi nibble compare mask

		mov	ax,SEG WorkScreen
		mov	ds,ax
		mov	ax,SEG DiskBuffer
		mov	es,ax
		mov	di,OFFSET DiskBuffer

		mov	cx,9
Write7_9Loop1:	push	cx
		push	si

		mov	bl,00000000b	;result
		mov	bh,10000000b	;mask

		mov	cx,4
Write7_9Loop2:	lodsb
		mov	ah,al
		and	ah,0f0h
		cmp	ah,dh
		jne	NoHiMatch7_9
		or	bl,bh
NoHiMatch7_9:	shr	bh,1
		and	al,00fh
		cmp	al,dl
		jne	NoLoMatch7_9
		or	bl,bh
NoLoMatch7_9:	shr	bh,1
		loop	Write7_9Loop2

		mov	al,TAB
		stosb
		stosb
		mov	al,'D'
		stosb
		mov	al,'B'
		stosb
		mov	al,TAB
		stosb

		mov	cx,8
Write7_9Loop3:	mov	al,'0'
		shl	bl,1
		adc	al,0
		stosb
		loop	Write7_9Loop3

		mov	al,'b'
		stosb
		mov	al,CR
		stosb
		mov	al,LF
		stosb

		pop	si
		add	si,160
		pop	cx
		loop	Write7_9Loop1
		
		mov	al,CR
		stosb
		mov	al,LF
		stosb
		mov	al,'$'
		stosb

		mov	di,OFFSET DiskBuffer
		call	FWrite$
		jnc	Write7_9Ok
	   	jmp	DiskError

Write7_9Ok:	pop	es
		pop	ds

		ret

Write7_9	ENDP

;----------------------------------------------------------------------------

;* Write3_5 - write data for 3 * 5 character
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

Write3_5	PROC	NEAR

		push	ds
		push	es

		mov	bl,BYTE PTR BoxY
		mov	cx,BoxX
		call	CalcAddr
		mov	si,di

		mov	dl,MaskColour		;dl = lo nibble compare mask
		mov	dh,dl
		shl	dh,1
		shl	dh,1
		shl	dh,1
		shl	dh,1			;dh = hi nibble compare mask

		mov	ax,SEG WorkScreen
		mov	ds,ax
		mov	ax,SEG DiskBuffer
		mov	es,ax
		mov	di,OFFSET DiskBuffer

		mov	cx,5
Write3_5Loop1:	push	cx
		push	si

		mov	bl,00000000b	;result
		mov	bh,10001000b	;mask

		mov	cx,2
Write3_5Loop2:	lodsb
		mov	ah,al
		and	ah,0f0h
		cmp	ah,dh
		jne	NoHiMatch3_5
		or	bl,bh
NoHiMatch3_5:	shr	bh,1
		and	al,00fh
		cmp	al,dl
		jne	NoLoMatch3_5
		or	bl,bh
NoLoMatch3_5:	shr	bh,1
		loop	Write3_5Loop2

		mov	al,TAB
		stosb
		stosb
		mov	al,'D'
		stosb
		mov	al,'B'
		stosb
		mov	al,TAB
		stosb

		mov	cx,8
Write3_5Loop3:	mov	al,'0'
		shl	bl,1
		adc	al,0
		stosb
		loop	Write3_5Loop3

		mov	al,'b'
		stosb
		mov	al,CR
		stosb
		mov	al,LF
		stosb

		pop	si
		add	si,160
		pop	cx
		loop	Write3_5Loop1
		
		mov	al,CR
		stosb
		mov	al,LF
		stosb
		mov	al,'$'
		stosb

		mov	di,OFFSET DiskBuffer
		call	FWrite$
	   	jnc	Write3_5Ok
	   	jmp	DiskError

Write3_5Ok:	pop	es
		pop	ds

		ret

Write3_5	ENDP

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

		mov	bx,CharType
		call	WriteCharData[bx]		

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

;* AutoCut - cut chars automatically
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

AutoCut		PROC	NEAR

		call	XorBox

		mov	bx,CharType
		mov	si,AutoPtr[bx]

		mov	ax,[si].XStart
		mov	BoxX,ax
		mov	ax,[si].YStart
		mov	BoxY,ax
		
		push	si
		call	XorBox
		pop	si
		
		mov	dx,[si].YCntr
AutoLoop1:	mov	cx,[si].XCntr
AutoLoop2:	mov	al,Key[K_ESC]
		test	al,al
		jnz	AutoExit

		push	cx
		push	dx
		push	si

		call	XorBox
		call	DeltaDownLoad

		mov	bx,CharType
		call	WriteCharData[bx]		

		call	FrameWait

		call	XorBox
		call	DeltaDownLoad

		call	FrameWait

		call	XorBox

		pop	si
		pop	dx
		pop	cx

		mov	ax,[si].XAdd
		add	BoxX,ax

		push	cx
		push	dx
		push	si
		call	XorBox
		pop	si
		pop	dx
		pop	cx
		loop	AutoLoop2

		push	dx
		push	si
		call	XorBox
		pop	si
		pop	dx
		mov	ax,[si].XStart
		mov	BoxX,ax
		mov	ax,[si].YAdd
		add	BoxY,ax
		push	dx
		push	si
		call	XorBox
		pop	si
		pop	dx
		dec	dx
		jnz	AutoLoop1

AutoExit:	ret

AutoCut		ENDP

CODE		ENDS

;============================================================================

		END

