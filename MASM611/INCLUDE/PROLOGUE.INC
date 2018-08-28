pushcontext listing
.nolist
;
;       (C) Copyright Microsoft Corporation 1992

;       This file is used to create the same sets of prologue and epilogue
;       sequences which the Microsoft C 6.00 compiler will produce.  This
;       file would be used for writing windows programs and to provide
;       such features as stack checking in the assembler portions of
;       a C based project.


;       The following global variables will affect the prolog/epilog
;       sequences produced
;
;       ?WP_DEBUG - If 1 then prolog/epilog sequences will be forced
;       ?WP_CHECKSTACK - If 1 then a check stack will be forced on all
;                       procedures
;       ?WP_INCBP - If 1 then the inc bp sequence will be generated on
;               all far procedures
;       ?WP_LOADDS - If 1 then the load ds sequence will be generated on
;               all far procedures
;
ifndef ?WP_DEBUG
?WP_DEBUG = 0
endif
ifndef ?WP_CHECKSTACK
?WP_CHECKSTACK = 0
endif
ifndef ?WP_INCBP
?WP_INCBP = 0
endif
ifndef ?WP_LOADDS
?WP_LOADDS = 0
endif

;
;       Complain if we are in a segment as this will affect how the
;       externdefs are done and therefore the fixups and code
;       created on the checkstack calls
;
% ifnb   <@CurSeg>
echo    Include should not be contained in a segment
endif

externdef C     _aNchkstk:near          ; Extern the symbols
externdef C     _aFchkstk:far           ; for later reference

;
;       This macro will produce the same output as will the 
;       C6 compiler for the given switches.
;
;       The following may be placed in the MacroArgs field of the
;               proc defintion:
;
;       CHECKSTACK
;       NOCHECKSTACK
;       LOADDS
;       NOLOADDS
;       FORCEFRAME
;       INCBP
;       NOINCBP

option prologue:cPrologue

cPrologue macro szProcName, flags, cbParams, cbLocals, rgRegs, rgUserParams
	LOCAL   ?doPrologue
	LOCAL   ?loadds
	LOCAL   ?checkstack
	LOCAL   ?incbp
	LOCAL   ?cbLocals
;       pushcontext     listing
;       .nolistmacro
;       .listmacroall
	
	?doPrologue = 0
	?loadds = 0
	?checkstack = 0
	?incbp = 0
	?cbLocals = cbLocals

;;      Set the defaults based on the global values specified
;;
if      ?WP_DEBUG NE 0                  ;; Force frames by default
 ?doPrologue = 1
endif

if      ?WP_CHECKSTACK NE 0             ;; Force checkstack by default
 ?checkstack = 1
endif

if      ?WP_INCBP NE 0                  ;; Force incbp by default if far
 if flags AND 020h
  ?incbp = 1
 endif
endif

if      ?WP_LOADDS NE 0                 ;; Force loadds by default if far
 if flags AND 020h
  ?loadds = 1
 endif
endif

;;
;;      Get all of the user parameters parsed
;;

ifnb    <rgUserParams>          ;;      Parse user params if exsisting
 for p,<rgUserParams>           ;;      For every user param

  ifidn <p>, <CHECKSTACK>       ;;      Is it checkstack?
   ?checkstack = 1              ;;              Yes -- do checkstack
  endif

  ifidn <p>, <NOCHECKSTACK>     ;;      Don't do checkstack?
   ?checkstack = 0              ;;              Yes -- clear checkstack 
  endif

  ifidn <p>, <LOADDS>   ;;      Is it LoadDS
   ?loadds = 1                  ;;              Yes -- do loadds sequence
  endif

  ifidn <p>, <NOLOADDS> ;;      Don't do LoadDS?
   ?loadds = 0                  ;;              Yes -- clear loadds flag
  endif

  ifidn <p>, <INCBP>            ;; Is it IncBP
   if flags AND 020h            ;;      and far?        
    ?incbp = 1                  ;;      Yes -- do IncBP sequence
   endif
  endif

  ifidn <p>, <NOINCBP>  ;;      Is it NoIncBP
   ?incbp = 0                   ;;              Yes -- Clear the incbp flag
  endif

  ifidn <p>, <FORCEFRAME>       ;;      Is it ForceFrame?
   ?doPrologue = 1                      ;;              Yes -- force out a frame
  endif

 endm                   ;; End of user parameter parsing loop
endif

;;  Frames are generated iff
;;      1. cbLocals + cbParams != 0
;;      2. FORCEFRAME is set
;;      3. INCBP is set and proc is far
;;      4. LOADDS is set
;;
;; Force a prolog?      

?doPrologue = ?doPrologue OR ?incbp OR ?loadds OR ?checkstack OR (?cbLocals NE 0) OR (cbParams NE 0)

if      ?doPrologue EQ 0        ;; No prolog needed -- so get out of here
;       popcontext listing
	exitm<0>
endif

if      ?loadds EQ 1            ;; Create the loadds code -- force in
	push    ds              ;;      Put DS into AX -- we will place
	pop     ax              ;;      back in DS later.  This sequence
	nop                     ;;      is altered by the OS if needed
endif

if      ?incbp EQ 1             ;; Mark as a far procedure for stack
	inc     bp              ;;      walking
endif

	push    bp              ;; Create the frame
	mov     bp,sp

if      ?loadds EQ 1            ;; Load up DS with the value in AX
	push    ds              ;;
	mov     ds,ax           ;;
	?cbLocals = ?cbLocals + 2
endif

if      ?checkstack EQ 1        ;; Now  allocate space for locals
	mov     ax,cbLocals     ;;      # of bytes of locals (unadjusted)
% ifidn <@CurSeg>, <_TEXT>
	call    _aNchkstk       ;;      Call run time routine to allocate
 else
	call    _aFchkstk
 endif
else    ; ?checkstack NE 1
  if    cbLocals NE 0
	sub     sp,cbLocals     ;;      make space on the stack for locals
  endif
endif

ifnb    rgRegs                  ;; There are registers to be saved.  do so
	for r,rgRegs
		push    r
	endm
endif
;       popcontext listing
	exitm <?cbLocals>

endm



;
;       This macro will produce the same output as will the 
;       C6 compiler for the given switches.
;
;       The following may be placed in the MacroArgs field of the
;               proc defintion:
;
;       CHECKSTACK
;       NOCHECKSTACK
;       LOADDS
;       NOLOADDS
;       FORCEFRAME
;       INCBP
;       NOINCBP

option epilogue:cEpilogue

cEpilogue macro szProcName, flags, cbParams, cbLocals, rgRegs, rgUserParams
	LOCAL   ?doPrologue
	LOCAL   ?loadds
	LOCAL   ?checkstack
	LOCAL   ?incbp
;       pushcontext     listing
;       .nolistmacro
;       .listmacroall
	
	?doPrologue = 0
	?loadds = 0
	?checkstack = 0
	?incbp = 0

;;      Set the defaults based on the global values specified
;;
if      ?WP_DEBUG NE 0                  ;; Force frames by default
 ?doPrologue = 1
endif

if      ?WP_CHECKSTACK NE 0             ;; Force checkstack by default
 ?checkstack = 1
endif

if      ?WP_INCBP NE 0                  ;; Force incbp by default
 if flags AND 020h
  ?incbp = 1
 endif
endif

if      ?WP_LOADDS NE 0                 ;; Force loadds by default
 if flags AND 020h
  ?loadds = 1
 endif
endif

;;
;;      Get all of the user parameters parsed
;;

ifnb    <rgUserParams>          ;;      Parse user params if exsisting
 for p,<rgUserParams>           ;;      For every user param

  ifidn <p>, <CHECKSTACK>       ;;      Is it checkstack?
   ?checkstack = 1              ;;              Yes -- do checkstack
  endif

  ifidn <p>, <NOCHECKSTACK>     ;;      Don't do checkstack?
   ?checkstack = 0              ;;              Yes -- clear checkstack 
  endif

  ifidn <p>, <LOADDS>   ;;      Is it LoadDS
   ?loadds = 1                  ;;              Yes -- do loadds sequence
  endif

  ifidn <p>, <NOLOADDS> ;;      Don't do LoadDS?
   ?loadds = 0                  ;;              Yes -- clear loadds flag
  endif

  ifidn <p>, <INCBP>    ;;      Is it IncBP
   if flags AND 020h
    ?incbp = 1                  ;;              Yes -- do IncBP sequence
   endif
  endif

  ifidn <p>, <NOINCBP>  ;;      Is it NoIncBP
   ?incbp = 0                   ;;              Yes -- Clear the incbp flag
  endif

  ifidn <p>, <FORCEFRAME>       ;;      Is it ForceFrame?
   ?doPrologue = 1                      ;;              Yes -- force out a frame
  endif

 endm                   ;; End of user parameter parsing loop
endif

;;  Frames are generated iff
;;      1. cbLocals + cbParams != 0
;;      2. FORCEFRAME is set
;;      3. INCBP is set and proc is far
;;      4. LOADDS is set
;;
;; Force a prolog?      

?doPrologue = ?doPrologue OR ?incbp OR ?loadds OR ?checkstack OR (cbLocals NE 0) OR (cbParams NE 0)

if      ?doPrologue EQ 0        ;; No epilog needed -- so get out of here
	ret
	exitm
endif

ifnb    rgRegs                  ;; Pop off the registers -- they are in
	for r,rgRegs            ;; inverse order from the prologue call
		pop     r
	endm
endif

if      ?loadds                 ;;
	dec     bp
	dec     bp
	mov     sp,bp
	pop     ds
	pop     bp
else

	mov     sp,bp
	pop     bp
endif

if      ?incbp                  ;; Remove the increment of BP if necessary
	dec     bp
endif

if      flags AND 010h          ;; Caller pops stack arguments
	ret
else                            ;; Callee pops args
 if     cbParams NE 0           ;; Put out the correct form of return
	ret     cbParams
 else
	ret
 endif
endif
endm

popcontext      listing
.listmacro
