;****************************************************************************
;*
;* CRITICAL.ASM
;*
;* Critical error handler.
;*
;* 29.06.1989 - KJB
;*
;****************************************************************************

		PUBLIC	InstallCritErr
		PUBLIC	RestoreCritErr

		PUBLIC	CritErrFlag
		PUBLIC	CritErrCode

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

;* critical error codes:-
;*
;*    00ch = general, non-specific
;*    00bh = read error
;*    00ah = write error
;*    009h = printer out of paper
;*    008h = sector not found
;*    007h = unknown media
;*    006h = seek error
;*    005h = bad request structure length
;*    004h = CRC error
;*    003h = unknown command requested
;*    002h = drive not ready (ie. no disk, door open)
;*    001h = invalid drive number
;*    000h = write protect error

CritErrFlag	DB	0,0		;0 = no error, 1 = error

CritErrCode	DW	0		;see above

DOSVctrSeg	DW	0		;DOS keyboard intr segment
DOSVctrOff	DW	0		;DOS keyboard intr offset

DATA		ENDS

;============================================================================

LIBCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:LIBCODE
		ASSUME DS:DATA

;* InstallCritErr - set critical error interrupt vector
;*
;* pass: nothing
;* ret : DOSVctrSeg = DOS critical error intr segment
;*       DOSVctrOff = DOS critical error intr offset
;* kill: assume all (DOS routine used)

InstallCritErr	PROC	FAR

		push	ds
		push	es

		mov	ah,035h		;DOS Get Interrupt Vector function
		mov	al,024h		;critical error interrupt
		int	021h  		;DOS
		mov	DOSVctrSeg,es
		mov	DOSVctrOff,bx

		mov	dx,OFFSET CritErrIntr
		mov	ax,SEG CritErrIntr
		mov	ds,ax
		mov	ah,025h		;DOS Set Interrupt Vector function
		mov	al,024h		;critical error interrupt
		int	021h		;DOS

		pop	es
		pop	ds
		ret

InstallCritErr	ENDP

;----------------------------------------------------------------------------

;* RestoreCritErr - restore critical error interrupt vector
;*
;* pass: DOSVctrSeg = critical error intr segment
;*       DOSVctrOff = critical error intr offset
;* ret : nothing
;* kill: assume all (DOS routine used)

RestoreCritErr	PROC	FAR

		push	ds
		push	es

		mov	dx,DOSVctrOff
		mov	ax,DOSVctrSeg
		mov	ds,ax
		mov	ah,025h		;DOS Set Interrupt Vector function
		mov	al,024h		;critical error interrupt
		int	021h		;DOS

		pop	es
		pop	ds
		ret

RestoreCritErr	ENDP

;----------------------------------------------------------------------------

;* CritErrIntr - critical error interrupt
;*
;* pass: nothing
;* ret : al = 0 (ignore error and press onwards)
;*       CritErrFlag = 1
;*       CritErrCode = error code
;* kill: nothing

CritErrIntr 	PROC	FAR

		push 	ax
      		push 	ds     

	      	mov 	ax,SEG CritErrFlag
      		mov 	ds,ax

		mov	CritErrFlag,1

		mov	CritErrCode,di
      	
		pop 	ds
      		pop 	ax

		mov	al,0		;ignore error

		iret

CritErrIntr  	ENDP

LIBCODE		ENDS

;============================================================================

		END

