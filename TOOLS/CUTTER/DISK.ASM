;****************************************************************************
;*
;* DISK.ASM
;*
;* General disk / file handling routines.
;*
;* 02.07.1989 - KJB
;*
;* These routines are simple and only allow one file to be open at a time.
;*
;* File specifications are expected in ASCIIZ format:-
;*
;*    "drive:\path\filename.ext",0
;*
;* The file functions use the carry flag to indicate if there was an error.
;* If an error occurs then you should first check CritErrFlag / CritErrCode
;* for source of error else the error code is returned in ax.
;*
;* Standard error codes:-
;*
;*    001h = Invalid function number
;*    002h = File not found
;*    003h = Path not found
;*    004h = No handle available
;*    005h = Access denied
;*    006h = Invalid handle
;*    007h = Memory control blocks destroyed
;*    008h = Insufficient memory
;*    009h = Invalid memory block address
;*    00ah = Invalid enviroment
;*    00bh = Invalid format
;*    00ch = Invalid access code
;*    00dh = Invalid data
;*    00eh = Not used
;*    00fh = Invalid drive specification
;*    010h = Attempt to remove current directory
;*    011h = Not same device
;*    012h = No more files to be found
;*
;****************************************************************************

		PUBLIC	WaitForMotor
		PUBLIC	CreateFile
		PUBLIC	OpenFile
		PUBLIC	CloseFile
		PUBLIC	FRead
		PUBLIC	FWrite
		PUBLIC	FindFile
		PUBLIC	LoadFile
		PUBLIC	SaveFile
		PUBLIC	FWrite$

		PUBLIC	Handle

		EXTRN	InstallTimer:FAR
		EXTRN	RestoreTimer:FAR

		EXTRN	CritErrCode:WORD

		EXTRN	CritErrFlag:BYTE
		EXTRN	TimerStatus:BYTE

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

Handle		DW	0

DATA		ENDS

;============================================================================

LIBCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:LIBCODE
		ASSUME DS:DATA

;*  WaitForMotor -  wait for floppy drive motor to stop
;*
;* pass: nothing
;* ret : nothing
;* kill: ?

WaitForMotor	PROC	FAR

		mov	al,TimerStatus	;save timer status
		push	ax
		call	RestoreTimer

;* wait for drive A: / B: motors to stop

		push	es

     		mov	ax,0
		mov	es,ax

WaitLoop:   	mov	al,es:[043fh]	;(control information area)
		test	al,0011b	     
		jnz	WaitLoop

		pop	es

		pop	ax
		test	al,al
		jz	WaitMotorExit
		call	InstallTimer
WaitMotorExit:	ret		    	

WaitForMotor	ENDP

;----------------------------------------------------------------------------

;* CreateFile - open existing file or create new file
;*
;* pass: dx -> ASCIIZ filename
;* ret : cf = 0: Handle
;*       cf = 1: CritErrFlag = 0: ax = error code
;*               CritErrFlag = 1: ax = CritErrCode
;* kill: assume all (DOS routines used)

CreateFile	PROC	FAR

		mov	al,TimerStatus	;save timer status
		push	ax

		push	dx
		call	RestoreTimer	;DOS timer intr for floppy control
		pop	dx

		mov	CritErrFlag,0

		mov	cl,00000000b	;file attribute
		mov	ah,03ch		;DOS create file function
		int	021h
		jc	CreateFixTimer	;error ->

		cmp	CritErrFlag,1	;critical error?
		je	CreateFail	;yes ->

		mov	Handle,ax
		clc
		jmp	CreateFixTimer

CreateFail:	mov	ax,CritErrCode
		stc

CreateFixTimer:	pop	dx
		pushf
		push	ax
		test	dl,dl
		jz	CreateExit
		call	InstallTimer
CreateExit:	pop	ax
		popf
		ret

CreateFile	ENDP

;----------------------------------------------------------------------------

;* OpenFile - open existing file
;*
;* pass: dx -> ASCIIZ filename
;* ret : cf = 0: Handle
;*       cf = 1: CritErrFlag = 0: ax = error code
;*               CritErrFlag = 1: ax = CritErrCode
;* kill: assume all (DOS routines used)

OpenFile	PROC	FAR

		mov	al,TimerStatus	;save timer status
		push	ax

		push	dx
		call	RestoreTimer	;DOS timer intr for floppy control
		pop	dx

		mov	CritErrFlag,0

		mov	al,00000000b	;access code
		mov	ah,03dh		;DOS open file function
		int	021h
		jc	OpenFixTimer	;error ->

		cmp	CritErrFlag,1	;critical error?
		je	OpenFail	;yes ->

		mov	Handle,ax
		clc
		jmp	OpenFixTimer

OpenFail:	mov	ax,CritErrCode
		stc

OpenFixTimer:	pop	dx
		pushf
		push	ax
		test	dl,dl
		jz	OpenExit
		call	InstallTimer
OpenExit:	pop	ax
		popf
		ret

OpenFile	ENDP

;----------------------------------------------------------------------------

;* CloseFile - close file
;*
;* pass: Handle
;* ret : cf = 0: nothing
;*       cf = 1: CritErrFlag = 0: ax = error code
;*               CritErrFlag = 1: ax = CritErrCode
;* kill: assume all (DOS routines used)

CloseFile	PROC	FAR

		mov	al,TimerStatus	;save timer status
		push	ax

		call	RestoreTimer	;DOS timer intr for floppy control

		mov	CritErrFlag,0

		mov	bx,Handle
		mov	ah,03eh		;DOS close file function
		int	021h
		jc	CloseFixTimer	;error ->

		cmp	CritErrFlag,1	;critical error?
		je	CloseFail	;yes ->

		clc
		jmp	CloseFixTimer

CloseFail:	mov	ax,CritErrCode
		stc

CloseFixTimer:	pop	dx
		pushf
		push	ax
		test	dl,dl
		jz	CloseExit
		call	InstallTimer
CloseExit:	pop	ax
		popf
		ret

CloseFile	ENDP

;----------------------------------------------------------------------------

;* FRead - read data from file
;*
;* pass: cx = number of bytes to read
;*       es:di -> buffer (DOS uses ds:dx, but this more convenient)
;*       Handle
;* ret : cf = 0: ax = number of bytes read (0 = EOF)
;*       cf = 1: CritErrFlag = 0: ax = error code
;*               CritErrFlag = 1: ax = CritErrCode
;* kill: assume all (DOS routines used)

FRead		PROC	FAR

		mov	al,TimerStatus	;save timer status
		push	ax

		push	cx
		push	di
		call	RestoreTimer	;DOS timer intr for floppy control
		pop	di
		pop	cx

		mov	CritErrFlag,0

		mov	bx,Handle
		push	ds
		mov	ax,es
		mov	ds,ax
		mov	dx,di
		mov	ah,03fh		;DOS read file function
		int	021h
		pop	ds
		jc	FReadFixTimer	;error ->

		cmp	CritErrFlag,1	;critical error?
		je	FReadFail	;yes ->

		clc
		jmp	FReadFixTimer

FReadFail:	mov	ax,CritErrCode
		stc

FReadFixTimer:	pop	dx
		pushf
		push	ax
		test	dl,dl
		jz	FReadExit
		call	InstallTimer
FReadExit:	pop	ax
		popf
		ret

FRead		ENDP

;----------------------------------------------------------------------------

;* FWrite - write data to file
;*
;* pass: cx = number of bytes to write
;*       es:di -> buffer (DOS uses ds:dx, but this more convenient)
;*       Handle
;* ret : cf = 0: ax = number of bytes written
;*       cf = 1: CritErrFlag = 0: ax = error code
;*               CritErrFlag = 1: ax = CritErrCode
;* kill: assume all (DOS routines used)

FWrite		PROC	FAR

		mov	al,TimerStatus	;save timer status
		push	ax

		push	cx
		push	di
		call	RestoreTimer	;DOS timer intr for floppy control
		pop	di
		pop	cx

		mov	CritErrFlag,0

		mov	bx,Handle
		push	ds
		mov	ax,es
		mov	ds,ax
		mov	dx,di
		mov	ah,040h		;DOS write file function
		int	021h
		pop	ds
		jc	FWriteFixTimer	;error ->

		cmp	CritErrFlag,1	;critical error?
		je	FWriteFail	;yes ->

		clc
		jmp	FWriteFixTimer

FWriteFail:	mov	ax,CritErrCode
		stc

FWriteFixTimer:	pop	dx
		pushf
		push	ax
		test	dl,dl
		jz	FWriteExit
		call	InstallTimer
FWriteExit:	pop	ax
		popf
		ret

FWrite		ENDP

;----------------------------------------------------------------------------

;* FindFile - find out if file is on the disk
;*
;* pass: dx -> ASCIIZ filename
;* ret : cf = 0: file found
;*       cf = 1: CritErrFlag = 0: ax = error code
;*               CritErrFlag = 1: ax = CritErrCode
;* kill: assume all (DOS routines used)
;* note: If cf = 1 then error code is usually 002h or 012h (see above).
;*       According to Norton, this DOS function does NOT set CF to signal
;*       an error.

FindFile	PROC	FAR

		mov	al,TimerStatus	;save timer status
		push	ax

		push	dx
		call	RestoreTimer	;DOS timer intr for floppy control
		pop	dx

		mov	CritErrFlag,0

		mov	cl,00000000b	;file attribute
		mov	ah,04eh		;DOS find first function
		int	021h

		cmp	ax,002h		;file not found error?
		je	DOSFindFail	;yes ->
		cmp	ax,012h		;no more files to be found error?
		je	DOSFindFail	;yes ->

		cmp	CritErrFlag,1	;critical error?
		je	FindFail	;yes ->

		clc
		jmp	FindFixTimer

FindFail:	mov	ax,CritErrCode
DOSFindFail:	stc

FindFixTimer:	pop	dx
		pushf
		push	ax
		test	dl,dl
		jz	FindExit
		call	InstallTimer
FindExit:	pop	ax
		popf
		ret

FindFile	ENDP

;----------------------------------------------------------------------------

;* LoadFile - load file into buffer
;*
;* pass: cx = number of bytes to read
;*       dx -> ASCIIZ filename
;*       es:di -> buffer
;* ret : cf = 0: ax = number of bytes read (0 = EOF)
;*       cf = 1: CritErrFlag = 0: ax = error code
;*               CritErrFlag = 1: ax = CritErrCode
;* kill: assume all (DOS routines used)

LoadFile	PROC	FAR

		push	cx
		push	dx	
		push	di
		push	es
		call	FindFile
		pop	es
		pop	di
		pop	dx
		pop	cx
		jc	LoadFileExit

		push	cx
		push	di
		push	es
		call	OpenFile
		pop	es
		pop	di
		pop	cx
		jc	LoadFileExit

		call	FRead
		jc	LoadFileExit

		push	ax		;save number of bytes read
		call	CloseFile
		pop	bx
		jc	LoadFileExit
		mov	ax,bx
		
LoadFileExit:	ret

LoadFile	ENDP

;----------------------------------------------------------------------------

;* SaveFile - save file into buffer
;*
;* pass: cx = number of bytes to write
;*       dx -> ASCIIZ filename
;*       es:di -> buffer
;* ret : cf = 0: ax = number of bytes written
;*       cf = 1: CritErrFlag = 0: ax = error code
;*               CritErrFlag = 1: ax = CritErrCode
;* kill: assume all (DOS routines used)

SaveFile	PROC	FAR

		push	cx
		push	di
		push	es
		call	CreateFile
		pop	es
		pop	di
		pop	cx
		jc	SaveFileExit

		call	FWrite
		jc	SaveFileExit

		push	ax   		;save number of bytes written
		call	CloseFile
		pop	bx
		jc	SaveFileExit
		mov	ax,bx
		
SaveFileExit:	ret

SaveFile	ENDP

;----------------------------------------------------------------------------

;* FWrite$ - write '$' terminated string to file
;*
;* pass: es:di -> '$' terminated string
;* ret : cf = 0: ax = number of bytes written
;*       cf = 1: CritErrFlag = 0: ax = error code
;*               CritErrFlag = 1: ax = CritErrCode
;* kill: assume all (DOS routines used)

FWrite$		PROC	FAR

		mov	al,'$'
		mov	bp,-1
FWrite$Loop:	inc	bp
		cmp	es:[di+bp],al
		jne	FWrite$Loop
		mov	cx,bp
		call	FWrite	
		ret

FWrite$		ENDP

LIBCODE		ENDS

;============================================================================

		END

