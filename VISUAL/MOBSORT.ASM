;****************************************************************************
;*
;* MOBSORT.ASM
;*
;* Mobile object sector sort routines.
;*
;* 17.06.1992 - KJB
;*
;* Sorting mobiles in terms of sectors is useful for quickly locating them in
;* any sector. This is used to scan for mobiles in the 3 by 3 visual but can
;* also be used for gameplay applications such as radars etc.
;*
;* Mobile objects require a compound data structure of the form:-
;*
;*	MOBILE data block +
;*      VIEWPOINT data block +
;*      control data block (optional)
;*
;* Note that the mobile sort bins are kept tidy. All of the bins up to the
;* last bin in use are valid. This optimises bin search times.
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	CreateMobile
		PUBLIC	DeleteMobile
		PUBLIC	UpdateMobile
		PUBLIC	LocateMobiles

;============================================================================

		INCLUDE	VISEXTRN.INC
		INCLUDE	VISDATA.INC
		INCLUDE	VISMACRO.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

END_SORT_BINS	EQU	OFFSET MobSortBins+(MSORT_REC_SIZE*NUM_MOBILES)

DATA		ENDS

;============================================================================

VISCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:VISCODE
		ASSUME DS:DATA

;* CreateMobile - create mobile object in sector sort system
;*
;* pass: si -> MOBILE data block +
;*             VIEWPOINT data block
;* ret : cf = 0: mobile created
;*       cf = 1: creation error (sort bins full)
;* kill: ax, bx, dx, flags (except cf)

CreateMobile	PROC	FAR

;* search bins for sector match

		mov	ax,_VP_XSEC[si]
		mov	dx,_VP_YSEC[si]

		mov	bx,MobSortPtr

@@:		sub	bx,MSORT_REC_SIZE
		cmp	bx,OFFSET MobSortBins	;all bins searched?
		jb	NoMatchFound		;yes ->

		cmp	ax,MSORT_XSEC[bx]	;x sec match?
		jne	@B			;no ->

		cmp	dx,MSORT_YSEC[bx]	;y sec match?
		jne	@B			;no ->

		jmp	LinkMobile

;* no match found - initialize new bin (if available)

NoMatchFound:	mov	bx,MobSortPtr

		cmp	bx,END_SORT_BINS	;any bins available?
		je	CreateError		;no ->

		mov	MSORT_XSEC[bx],ax
		mov	MSORT_YSEC[bx],dx
		mov	MSORT_PTR[bx],-1

		add	MobSortPtr,MSORT_REC_SIZE	;update ptr

;* link mobile into head of list

LinkMobile:	mov	ax,MSORT_PTR[bx]

		mov	MSORT_PTR[bx],si

		mov	MOB_LINK_PTR[si],ax

		inc	NumMobiles

		clc			;cf = 0 = mobile created

		ret

CreateError:	stc			;cf = 1 = creation error

		ret

CreateMobile	ENDP

;----------------------------------------------------------------------------

;* DeleteMobile - delete mobile object from sector sort system
;*
;* pass: si -> MOBILE data block +
;*             VIEWPOINT data block
;* ret : cf = 0: mobile deleted
;*       cf = 1: deletion error (mobile not found)
;* kill: ax, bx, dx, di, flags (except cf)

DeleteMobile	PROC	FAR

;* search bins for sector match

		mov	ax,_VP_XSEC[si]
		mov	dx,_VP_YSEC[si]

		mov	bx,MobSortPtr

@@:		sub	bx,MSORT_REC_SIZE
		cmp	bx,OFFSET MobSortBins	;all bins searched?
		jb	DeleteError		;yes ->

		cmp	ax,MSORT_XSEC[bx]	;x sec match?
		jne	@B			;no ->

		cmp	dx,MSORT_YSEC[bx]	;y sec match?
		jne	@B			;no ->

;* bin found - check if first mobile in bin

		mov	di,MSORT_PTR[bx]

		cmp	di,si		;first object in bin?
		jne	SearchBin	;no ->

;* unlink first object in bin

		mov	ax,MOB_LINK_PTR[si]

		mov	MSORT_PTR[bx],ax

;* if bin empty then
;*    if not last bin in use then
;*       copy contents of last bin to this bin (house keeping)
;*    endif
;* endif

		cmp	ax,-1		;bin empty?
		jne	DeleteOk	;no ->

		mov	di,MobSortPtr
		sub	di,MSORT_REC_SIZE	;ptr -> last bin in use

		cmp	bx,di		;is empty bin the last bin in use?
		je	@F		;yes ->

		mov	ax,MSORT_XSEC[di]
		mov	MSORT_XSEC[bx],ax

		mov	ax,MSORT_YSEC[di]
		mov	MSORT_YSEC[bx],ax

		mov	ax,MSORT_PTR[di]
		mov	MSORT_PTR[bx],ax

@@:		sub	MobSortPtr,MSORT_REC_SIZE	;update ptr

		jmp	DeleteOk

;* search bin for ptr match

SearchBin:	mov	ax,MOB_LINK_PTR[di]

		cmp	ax,-1		;list terminator?
		je	DeleteError	;yes ->

		cmp	ax,si		;found ptr match?
		je	UnlinkMobile	;yes ->

		mov	di,ax

		jmp	SearchBin

UnlinkMobile:	mov	ax,MOB_LINK_PTR[si]

		mov	MOB_LINK_PTR[di],ax

DeleteOk:	dec	NumMobiles

		clc			;cf = 0 = mobile deleted

		ret

DeleteError:	stc			;cf = 1 = deletion error

		ret

DeleteMobile	ENDP

;----------------------------------------------------------------------------

;* UpdateMobile - move mobile object and sort sector change
;*
;* pass: ax = delta xft
;*       bx = delta yft
;*       cx = delta zft
;*       si -> MOBILE data block +
;*             VIEWPOINT data block
;* ret : cf = 0: move successful
;*       cf = 1: delete / create error
;* kill: ax, bx, cx, dx, di, flags (except cf)

UpdateMobile	PROC	FAR

;* sort zft

		xchg	ax,cx

		cwd

		add	WORD PTR _VP_ZFT_LO[si],ax
		adc	WORD PTR _VP_ZFT_HI[si],dx

		mov	ax,cx

;* store old sector values

		mov	cx,_VP_XSEC[si]
		mov	dx,_VP_YSEC[si]

;* update position

		MOVEXY	MOB_REC_SIZE[si],ax,bx

;* changed sector?

		cmp	cx,_VP_XSEC[si]	;x sec changed?
		jne	@F		;yes ->

		cmp	dx,_VP_YSEC[si]	;y sec changed?
		je	UpdateOk	;no ->

;* delete mobile (using old sector values)

@@:		xchg	cx,_VP_XSEC[si]
		xchg	dx,_VP_YSEC[si]

		push	dx
		call	DeleteMobile
		pop	dx
		jc	UpdateError	;delete error ->

;* create mobile (using new sector values)

		mov	_VP_XSEC[si],cx
		mov	_VP_YSEC[si],dx

		call	CreateMobile
		jc	UpdateError	;delete error ->

UpdateOk:	clc			;cf = 0 = ok

		ret

UpdateError:	stc			;cf = 1 = delete / create error

		ret

UpdateMobile	ENDP

;----------------------------------------------------------------------------

;* LocateMobiles - locate mobiles in given sector
;*
;* pass: ax = x sector
;*       dx = y sector
;* ret : cf = 0: mobiles located in sector
;*               si -> linked list of mobiles in sector (-1 terminated)
;*       cf = 1: no mobiles located in sector
;*               si = -1 (null pointer)
;* kill: bx, flags (except cf)

LocateMobiles	PROC	FAR

		mov	bx,MobSortPtr

@@:		sub	bx,MSORT_REC_SIZE
		cmp	bx,OFFSET MobSortBins	;all bins searched?
		jb	NoMobsLocated		;yes ->

		cmp	ax,MSORT_XSEC[bx]	;x sec match?
		jne	@B			;no ->

		cmp	dx,MSORT_YSEC[bx]	;y sec match?
		jne	@B			;no ->

		mov	si,MSORT_PTR[bx]

		clc			;cf = 0 = mobiles in sector

		ret

NoMobsLocated:	mov	si,-1

		stc			;cf = 1 = no mobiles in sector

		ret

LocateMobiles	ENDP

VISCODE		ENDS

;============================================================================

		END

