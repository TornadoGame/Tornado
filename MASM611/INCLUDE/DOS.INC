; DOS Interface Macros - Version 1.3 - for Microsoft Macro Assembler 6.1
; (C) Copyright Microsoft Corporation, 1987, 1988, 1989, 1990, 1993

; Typedefs for testing pointers
NPVOID  TYPEDEF NEAR PTR
FPVOID  TYPEDEF FAR  PTR


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  For more information on the following structures refer to
;  the Microsoft MS-DOS Programmer's Reference for Version 5.0
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
BOOTSECTOR STRUCT 1t
    bsJump          DB 3 DUP(?)
    bsOemName       DB '????????'
    bsBytesPerSec   DW ?
    bsSecPerClust   DB ?
    bsResSectors    DW ?
    bsFATs          DB ?
    bsRootDirEnts   DW ?
    bsSectors       DW ?
    bsMedia         DB ?
    bsFATsecs       DW ?
    bsSecPerTrack   DW ?
    bsHeads         DW ?
    bsHiddenSecs    DD ?
    bsHugeSectors   DD ?
    bsDriveNumber   DB ?
    bsReserved1     DB ?
    bsBootSignature DB ?
    bsVolumeID      DD ?
    bsVolumeLabel   DB 11 DUP(?)
    bsFileSysType   DB 8 DUP(?)
BOOTSECTOR ENDS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Used with: Interrupt 21h Function 440Dh Minor Code 60h
;             Interrupt 21h Function 440Dh Minor Code 40h
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DEVICEPARAMS STRUCT 1t
    dpSpecFunc      DB ?
    dpDevType       DB ?
    dpDevAttr       DW ?
    dpCylinders     DW ?
    dpMediaType     DB ?
    dpBytesPerSec   DW ?
    dpSecPerClust   DB ?
    dpResSectors    DW ?
    dpFATs          DB ?
    dpRootDirEnts   DW ?
    dpSectors       DW ?
    dpMedia         DB ?
    dpFATsecs       DW ?
    dpSecPerTrack   DW ?
    dpHeads         DW ?
    dpHiddenSecs    DD ?
    dpHugeSectors   DD ?
    dpReserved1     DB 6 DUP(?) ;; A documentation error in the
    dpTrkLayoutCnt  DW ?        ;; MS-DOS Programmer's Reference 5.0
DEVICEPARAMS ENDS               ;; omits these last two fields.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Used with: Interrupt 21h Function 11h
;             Interrupt 21h Function 12h
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DIRENTRY STRUCT 1t
    deName          DB '????????'
    deExtension     DB '???'
    deAttributes    DB ?
    deReserved1     DB 10 DUP(?)
    deTime          DW ?
    deDate          DW ?
    deStartCluster  DW ?
    deFileSize      DD ?
DIRENTRY ENDS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Used with: Interrupt 25h
;             Interrupt 26h
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DISKIO STRUCT 1t
    diStartSector   DD ?
    diSectors       DW ?
    diBuffer        DD ?
DISKIO ENDS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Used with: Interrupt 21h Function 1Fh
;             Interrupt 21h Function 32h
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DPB STRUCT 1t
    dpbDrive        DB ?
    dpbUnit         DB ?
    dpbSectorSize   DW ?
    dpbClusterMask  DB ?
    dpbClusterShift DB ?
    dpbFirstFAT     DW ?
    dpbFATCount     DB ?
    dpbRootEntries  DW ?
    dpbFirstSector  DW ?
    dpbMaxCluster   DW ?
    dpbFATSize      DW ?
    dpbDirSector    DW ?
    dpbDriverAddr   DD ?
    dpbMedia        DB ?
    dpbFirstAccess  DB ?
    dpbNextDPB      DD ?
    dpbNextFree     DW ?
    dpbFreeCnt      DW ?
DPB ENDS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Used with: Interrupt 21h Function 11h
;             Interrupt 21h Function 12h
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
EXTENDEDFCB STRUCT 1t
    extSignature    DB 0FFh
    extReserved1    DB 5 DUP(0)
    extAttribute    DB ?
    extDriveID      DB ?
    extFileName     DB '????????'
    extExtent       DB '???'
    extCurBlockNo   DW ?
    extRecSize      DW ?
    extFileSize     DB 4 DUP(?)
    extFileDate     DW ?
    extFileTime     DW ?
    extReserved2    DB 8 DUP(?)
    extCurRecNo     DB ?
    extRandomRecNo  DB 4 DUP(?)
EXTENDEDFCB ENDS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Used with: Interrupt 21h Function 11h
;             Interrupt 21h Function 12h
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
EXTHEADER STRUCT 1t
    ehSignature     DB 0FFh
    ehReserved      DB 5 DUP(?)
    ehSearchAttrs   DB ?
EXTHEADER ENDS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Used with: Interrupt 21h Function 0Fh
;             Interrupt 21h Function 10h
;             Interrupt 21h Function 11h
;             Interrupt 21h Function 12h
;             Interrupt 21h Function 13h
;             Interrupt 21h Function 14h
;             Interrupt 21h Function 15h
;             Interrupt 21h Function 16h
;             Interrupt 21h Function 17h
;             Interrupt 21h Function 1Bh
;             Interrupt 21h Function 1Ch and @ChkDrv MACRO
;             Interrupt 21h Function 21h
;             Interrupt 21h Function 22h
;             Interrupt 21h Function 23h
;             Interrupt 21h Function 24h
;             Interrupt 21h Function 27h
;             Interrupt 21h Function 28h
;             Interrupt 21h Function 29h
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FCB STRUCT 1t
    fcbDriveID      DB ?
    fcbFileName     DB '????????'
    fcbExtent       DB '???'
    fcbCurBlockNo   DW ?
    fcbRecSize      DW ?
    fcbFileSize     DB 4 DUP(?)
    fcbFileDate     DW ?
    fcbFileTime     DW ?
    fcbReserved1    DB 8 DUP(?)
    fcbCurRecNo     DB ?
    fcbRandomRecNo  DB 4 DUP(?)
FCB ENDS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Used with: Interrupt 21h Function 4Eh and @GetFirst MACRO
;             Interrupt 21h Function 4Fh and @GetNext MACRO
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FILEINFO STRUCT 1t
    fiReserved1     DB 21 DUP(?)
    fiAttribute     DB ?
    fiFileTime      DW ?
    fiFileDate      DW ?
    fiSize          DD ?
    fiFileName      DB 13 DUP(?)
FILEINFO ENDS

; This structure declaration is included for compatability with earlier
; versions of DOS.INC.  The structure declaration above, which matches 
; the MS-DOS Programmer's Reference 5.0, should be used for new code.
FILE_INFO STRUCT
  pad           BYTE    21 DUP (?)      ; pad to 43 bytes
  Attrib        BYTE    ?               ; file attribute
  Time          WORD    ?               ; file time
  Date          WORD    ?               ; file date
  Len           DWORD   ?               ; file size
  FName         BYTE    13 DUP (?)      ; file name
FILE_INFO ENDS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Used with: Interrupt 21h Function 440Dh Minor Code 42h
;             Interrupt 21h Function 440Dh Minor Code 62h
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
FVBLOCK STRUCT 1t
    fvSpecFunc      DB 0
    fvHead          DW ?
    fvCylinder      DW ?
FVBLOCK ENDS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Used with: Interrupt 21h Function 440Dh Minor Code 66h
;             Interrupt 21h Function 440Dh Minor Code 46h
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MID STRUCT 1t
    midInfoLevel    DW 0
    midSerialNum    DD ?
    midVolLabel     DD 11 DUP(?)
    midFileSysType  DB 8 DUP(?)
MID ENDS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Used with: Interrupt 21h Function 440Dh Minor Code 41h
;             Interrupt 21h Function 440Dh Minor Code 61h
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PARTENTRY STRUCT 1t
    peBootable      DB ?
    peBeginHead     DB ?
    peBeginSector   DB ?
    peBeginCylinder DB ?
    peFileSystem    DB ?
    peEndHead       DB ?
    peEndSector     DB ?
    peEndCylinder   DB ?
    peStartSector   DD ?
    peSectors       DD ?
PARTENTRY ENDS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Used with: Interrupt 21h Function 17h
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
RENAMEFCB STRUCT 1t
    renDriveID      DB ?
    renOldName      DB '????????'
    renOldExtent    DB '???'
    renReserved1    DB 5 DUP(?)
    renNewName      DB '????????'
    renNewExtent    DB '???'
    renReserved2    DB 9 DUP(?)
RENAMEFCB ENDS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Used with: Interrupt 21h Function 440Dh Minor Code 61h
;             Interrupt 21h Function 440Dh Minor Code 41h
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
RWBLOCK STRUCT 1t
    rwSpecFunc      DB 0
    rwHead          DW ?
    rwCylinder      DW ?
    rwFirstSector   DW ?
    rwSectors       DW ?
    rwBuffer        DD ?
RWBLOCK ENDS


; Internal
__LdAdr MACRO reg:REQ, adr:REQ
    IF (OPATTR (adr)) AND 00010000y
        mov     reg, adr               ;; Register
    ELSEIF (OPATTR (adr)) AND 00000100y
        mov     reg, adr               ;; Constant
    ELSEIF (TYPE (adr) EQ BYTE)  OR (TYPE (adr) EQ SBYTE)
        mov    reg, OFFSET adr         ;; Bytes
    ELSEIF (TYPE (adr) EQ NPVOID) OR (TYPE (adr) EQ WORD)
        mov    reg, adr                ;; Near pointer
    ELSEIF (TYPE (adr) EQ FPVOID) OR (TYPE (adr) EQ DWORD)
        mov    reg, WORD PTR adr[0]    ;; Far pointer
        mov    ds,  WORD PTR adr[2]
    ELSE
        .ERR <Illegal argument>
    ENDIF
ENDM


; Internal
__LdSeg MACRO dest:REQ, src:REQ
    IFIDNI <src>, <es>                 ;; Segment register
        mov     ax, src
        mov     dest, ax
    ELSEIFIDNI <src>, <ss>
        mov     ax, src
        mov     dest, ax
    ELSEIFIDNI <src>, <ds>
        mov     ax, src
        mov     dest, ax
    ELSEIFIDNI <src>, <cs>
        mov     ax, src
        mov     dest, ax
    ELSEIF (OPATTR (src)) AND 00000100y ;; Constant
        mov     ax, src
        mov     dest, ax
    ELSE                                ;; Memory or general register
        mov     dest, src
    ENDIF
ENDM

; Internal
__LdDub MACRO dub:REQ
    IF ((OPATTR (dub)) AND 00000100y)
        IF ((dub) LE 0FFFFh)
             sub  cx, cx
             mov  dx, dub
        ELSE
             sub  cx, HIGWORD dub
             mov  dx, LOWWORD dub
        ENDIF
    ELSEIF   TYPE (dub) EQ 2
        sub  cx, cx
        mov  dx, dub
    ELSEIF TYPE (dub) EQ 4
        mov  cx, dub[2]
        mov  dx, dub[0]
    ELSEIF TYPE (dub) EQ 0
        sub     cx, cx
        mov     dx, dub
    ELSE
        .ERR
        ECHO Illegal argument
    ENDIF
ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Syntax:    @GetChar [echo] [,[break] [,clearbuf]]
;
;  Summary:   Gets a keystroke from the keyboard
;
;  Arguments: <echo>         Nonzero to echo keystroke; default yes.
;                            Must be a constant.
;
;             <break>        Nonzero to accept CTRL+C; default yes. Must
;                            be a constant.
;
;             <clearbuf>     Nonzero to clear keyboard buffer; default
;                            no. Must be a constant.
;
;             NOTE: Arguments can be omitted to get defaults.
;
;  Returns:   ASCII code of key in AL
;
;  Modifies:  AX, else DL used if echo on and CTRL+C off
;
;  Uses:      Interrupt 21h Function 01h, 07h, 08h, 0Ch
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@GetChar MACRO ech:=<1>, cc:=<1>, clear:=<0>
    LOCAL   funct, disp
    disp    = 1
    IF  ech
        IF  cc
            funct   = 01h       ;; Echo with break checking
        ELSE
            funct   = 07h       ;; Echo without break checking
            disp    = 02h       ;; Need separate call to echo
        ENDIF
    ELSE
        IF  cc
            funct   = 08h       ;; No echo with break checking
        ELSE
            funct   = 07h       ;; No echo without break checking
        ENDIF
    ENDIF
    IFE clear
        mov     ah, funct       ;; Load function directly
    ELSE
        mov     ah, 0Ch         ;; If clear set, call function
        mov     al, funct       ;;  indirectly with function 0Ch
    ENDIF
    int     21h                 ;; Call DOS
    IF disp EQ 02h              ;; Separate call for echo without
        mov     dl, al          ;;  break checking
        mov     ah, disp
        int     21h
    ENDIF
ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Syntax:    @GetStr buffer [,[terminator] [,[limit] [,segment]]]
;
;  Summary:   Gets a string from the keyboard
;
;  Arguments: <buffer>         Offset of buffer for string. Must be an
;                              offset address.
;
;                              Byte 1    Maximum length of string before
;                                        call.
;                              Byte 2    Actual length of string after
;                                        call.
;                              Byte 3+   Bytes of string.
;
;             <terminator>     Terminating byte: null (0) or $ (24h).
;                              May be a constant or register, but not memory.
;
;             <limit>          Maximum length of string. Must be a
;                              constant. If not given as an argument,
;                              must be in buffer before call.
;
;             <segment>        Segment of buffer; DS if not given.
;
;  Returns:   Pointer to string in SI, length of string in BX
;
;  Modifies:  AX, DX, BX, SI
;
;  Uses:      Interrupt 21h Function 0Ah
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@GetStr MACRO ofset:REQ, terminator, limit, segmnt
    __LdAdr dx, <ofset>
    IFNB    <segmnt>
        __LdSeg ds, <segmnt>
    ENDIF
    mov     ah, 0Ah
    mov     si, dx
    IFNB    <limit>
        mov     BYTE PTR [si], limit
    ENDIF
    int     21h
    inc     si
    mov     bl, [si]
    sub     bh, bh
    inc     si
    IFNB    <terminator>
        mov     BYTE PTR [bx+si], terminator
    ENDIF
ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Syntax:    @ShowChar char [,char]...
;
;  Summary:   Displays one or more characters to screen
;
;  Argument:  <char>     8-bit ASCII code
;
;  Returns:   No return value
;
;  Modifies:  AX, DL
;
;  Uses:      Interrupt 21h Function 02h
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@ShowChar MACRO chr:VARARG
    mov     ah, 02h
    FOR arg, <chr>
        IFDIFI  <arg>, <dl>
            mov     dl, arg
        ENDIF
        int     21h
    ENDM
ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Syntax:    @PrtChar char [,char]...
;
;  Summary:   Prints one or more characters to LPT1
;
;  Argument:  <char>     8-bit ASCII code
;
;  Returns:   No return value
;
;  Modifies:  AX, DL
;
;  Uses:      Interrupt 21h Function 05h
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@PrtChar MACRO chr:VARARG
    mov     ah, 05h
    FOR arg, <chr>
        IFDIFI  <arg>, <dl>
            mov     dl, arg
        ENDIF
        int     21h
    ENDM
ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Syntax:    @ShowStr address [,segment]
;
;  Summary:   Displays a $-terminated string
;
;  Arguments: <address>     Address of string terminated by "$" (24h).
;                           Must be an offset address.
;
;             <segment>     Segment of address string; DS if not given.
;
;  Returns:   No return value
;
;  Modifies:  AX, DX; DS if segment changed
;
;  Uses:      Interrupt 21h Function 09h
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@ShowStr MACRO ofset:REQ, segmnt
    LOCAL  msg, sseg
    IF @InStr( 1, ofset, <!"> ) EQ 1
        sseg    TEXTEQU @CurSeg
        .DATA
        msg     BYTE    ofset, "$"
    @CurSeg ENDS
        sseg    SEGMENT
        mov     dx, OFFSET msg
    ELSE
        __LdAdr dx, ofset
        IFNB    <segmnt>
            __LdSeg ds, <segmnt>
        ENDIF
    ENDIF
    mov     ah, 9
    int     21h
ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Syntax:    @Read buffer, length [,[handle] [,segment]]
;
;  Summary:   Reads data from a file or device
;
;  Arguments: <buffer>      Offset of buffer where data will be stored.
;                           Must be an offset address.
;
;             <length>      Length of data in bytes.
;
;             <handle>      File or device handle; if none given,
;                           keyboard (handle 0) is assumed.
;
;             <segment>     Segment of address string; DS if not given.
;
;  Returns:   If carry: clear, bytes read in AX
;
;  Modifies:  AX, DX, BX, CX; DS if segment changed
;
;  Uses:      Interrupt 21h Function 3Fh
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@Read MACRO ofset:REQ, bytes:REQ, handle:=<0>, segmnt
    IFDIF   <handle>, <0>
        mov     bx, handle
    ELSE
        sub     bx, bx
    ENDIF
    mov     cx, bytes
    __LdAdr dx, <ofset>
    IFNB    <segmnt>
        __LdSeg ds, <segmnt>
    ENDIF
    mov     ah, 3Fh
    int     21h
ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Syntax:    @Write buffer, length [,[handle] [,segment]]
;
;  Summary:   Writes data to a file or device
;
;  Arguments: <buffer>      Offset of buffer where data is stored. Must
;                           be an offset address.
;
;             <length>      Length of data in bytes.
;
;             <handle>      File or device handle; if none given, screen
;                           (handle 1) is assumed.
;
;             <segment>     Segment of address string; DS if not given.
;
;  Returns:   If carry: clear, bytes written in AX
;
;  Modifies:  AX, DX, BX, CX; DS if segment changed
;
;  Uses:      Interrupt 21h Function 40h
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@Write MACRO ofset:REQ, bytes:REQ, handle:=<1>, segmnt
    mov     bx, handle
    mov     cx, bytes
    __LdAdr dx, <ofset>
    IFNB    <segmnt>
        __LdSeg ds, <segmnt>
    ENDIF
    mov     ah, 40h
    int     21h
ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Syntax:    @MakeFile path [,[attrib] [,[segment] [,kind]]]
;
;  Summary:   Creates a file
;
;  Arguments: <path>        ASCIIZ string of file. Must be an offset
;                           address.
;
;             <attrib>      File attribute; 0 is default if none given.
;
;             <segment>     Segment of address string; DS if not given.
;
;             <kind>        If none given, a file is created even if one
;                           already exists. Under DOS 3.x, "tmp" can be
;                           given to create a unique file or "new" to
;                           create a file only if one doesn't already
;                           exist.
;
;  Returns:   If carry: clear, file handle in AX
;
;  Modifies:  AX, DX, CX; DS if segment changed
;
;  Uses:      Interrupt 21h Function 3Ch, 5Ah, 5Bh
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@MakeFile MACRO path:REQ, atrib:=<0>, segmnt, kind
    IFDIF   <atrib>, <0>
        mov     cx, atrib
    ELSE
        sub     cx, cx
    ENDIF
    __LdAdr dx, <path>
    IFNB    <segmnt>
        __LdSeg ds, <segmnt>
    ENDIF
    IFIDNI  <kind>, <tmp>
        mov     ah, 5Ah
    ELSEIFIDNI <kind>, <new>
        mov    ah, 5Bh
    ELSE
        mov    ah, 3Ch
    ENDIF
    int     21h
ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Syntax:    @OpenFile path, access [,segment]
;
;  Summary:   Opens a file for input or output
;
;  Arguments: <path>        ASCIIZ string of file. Must be an offset
;                           address.
;
;             <access>      File access code. Must be a constant. The
;                           default value is 0 (normal read/write file).
;
;             <segment>     Segment of address string; DS if not given.
;
;  Returns:   If carry: set, error code in AX
;             If carry: clear, file handle in AX
;
;  Modifies:  AX, DX; DS if segment changed
;
;  Uses:      Interrupt 21h Function 3Dh
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@OpenFile MACRO path:REQ, access:=<0>, segmnt
    __LdAdr dx, <path>
    IFNB    <segmnt>
        __LdSeg ds, <segmnt>
    ENDIF
    mov     ax, 3D00h + (access AND 0FFh)
    int     21h
ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Syntax:    @CloseFile handle
;
;  Summary:   Closes an open file handle
;
;  Argument:  <handle>     Previously opened file handle
;
;  Returns:   If carry: set, error code in AX
;
;  Modifies:  AX, BX
;
;  Uses:      Interrupt 21h Function 3Eh
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@CloseFile MACRO handle:REQ
    mov     bx, handle
    mov     ah, 3Eh
    int     21h
ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Syntax:    @DelFile path [,segment]
;
;  Summary:   Deletes a specified file
;
;  Arguments: <path>        Offset of ASCIIZ file specification. Must
;                           be an offset address.
;
;             <segment>     Segment of path; DS if none given.
;
;  Returns:   If carry: set, error code in AX
;
;  Modifies:  AX, DX; DS if segment changed
;
;  Uses:      Interrupt 21h Function 41h
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@DelFile MACRO path:REQ, segmnt
    __LdAdr dx, <path>
    IFNB    <segmnt>
        __LdSeg ds, <segmnt>
    ENDIF
    mov     ah, 41h
    int     21h
ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Syntax:    @MoveFile old, new [,[segold] [,segnew]]
;
;  Summary:   Moves or renames a file by changing its path specification
;
;  Arguments: <old>        Offset of file specification to be renamed.
;                          Must be an offset address.
;
;             <new>        Offset of new file specification. Must be an
;                          offset address.
;
;             <segold>     Segment of old name; DS if none given.
;
;             <segnew>     Segment of new name; ES if none given.
;
;  Returns:   If carry: set, error code in AX
;
;  Modifies:  AX, DX, DI; DS, ES if corresponding segments changed
;
;  Uses:      Interrupt 21h Function 56h
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@MoveFile MACRO old:REQ, new:REQ, segold, segnew
    __LdAdr dx, <old>
    __LdAdr di, <new>
    IFNB    <segold>
        __LdSeg ds, <segold>
    ENDIF
    IFNB    <segnew>
        __LdSeg es, <segnew>
    ENDIF
    mov     ah, 56h
    int     21h
ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Syntax:    @GetFirst path [,[attribute] [,segment]]
;             @GetNext
;
;  Summary:   Converts file specifications (optionally including wild
;             cards) into filenames. These macros are usually used with
;             @GetDTA and @SetDTA. Use @SetDTA to set the address where
;             the data for each file will be stored.
;
;  Arguments: <path>          Offset address of fully specified ASCIIZ
;                             file name; can have wild cards. Must be an
;                             offset address.
;
;             <attribute>     File attribute to search for; 0 for normal
;                             if none given.
;
;             <segment>       Segment of path; uses DS if none given.
;
;  Returns:   If carry: set, error code in AX
;
;  Modifies:  For @GetFirst, AX, CX, DX; DS if segment changed;
;             for @GetNext, AX only
;
;  Uses:      Interrupt 21h Function 4Eh
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@GetFirst MACRO path:REQ, atrib, segmnt
    IFNB    <atrib>
        mov     cx, atrib
    ELSE
        sub     cx, cx
    ENDIF
    __LdAdr dx, <path>
    IFNB    <segmnt>
        __LdSeg ds, <segmnt>
    ENDIF
    mov     ah, 4Eh
    int     21h
ENDM


; 4Fh
@GetNext MACRO
    mov     ah, 4Fh
    int     21h
ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Syntax:    @GetDTA
;
;             @SetDTA buffer [,segment]
;
;  Summary:   Gets or sets the Disk Transfer Address (DTA). These
;             macros are usually used to set the address for file
;             information data used by @GetFirst and @GetNext.
;
;  Arguments: <buffer>      Offset of new DTA buffer. Must be an offset
;                           address.
;
;             <segment>     Segment of new DTA buffer; DS if none given.
;
;  Returns:   @GetDTA: ES:BX points to DTA
;             @SetDTA: No return value
;
;  Modifies:  AX for both; ES, BX for @GetDTA; DS, DX for @SetDTA
;
;  Uses:      Interrupt 21h Function 2Fh
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@GetDTA MACRO
    mov     ah, 2Fh
    int     21h
ENDM

; 1Ah
@SetDTA MACRO buffer:REQ, segmnt
    __LdAdr dx, <buffer>
    IFNB    <segmnt>
        __LdSeg ds, <segmnt>
    ENDIF
    mov     ah, 1Ah
    int     21h
ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Syntax:    @GetFileSize handle
;
;  Summary:   Gets the file size by moving the file pointer to
;             end-of-file
;
;             NOTE: The file pointer is reset to zero. Thus this
;                   macro should not be called during operations that move
;                   the pointer.
;
;  Argument:  <handle>     Previously opened file handle.
;
;  Returns:   If carry: clear, file length in DX:AX
;
;  Modifies:  AX, BX, CX, DX
;
;  Uses:      Interrupt 21h Function 42h
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@GetFileSize MACRO handle:REQ
    mov     bx, handle
    sub     cx, cx
    sub     dx, dx
    mov     ax, 4202h
    int     21h
    push    dx
    push    ax
    sub     dx, dx
    mov     ax, 4200h
    int     21h
    pop     ax
    pop     dx
ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Syntax:    @MovePtrAbs handle [,distance]
;
;             @MovePtrRel handle [,distance]
;
;  Summary:   Moves the file pointer in an open file. The pointer can be
;             moved to an absolute position, or relative to its current
;             position.
;
;  Arguments: <handle>       Previously opened file handle.
;
;             <distance>     Distance to move pointer (16-bit) constant
;                            or a 16- or 32-bit variable; or leave
;                            blank and set distance in CX:DX before
;                            macro call.
;
;  Returns:   If carry: clear, file pointer position in DX:AX
;
;  Modifies:  AX, BX, CX, DX
;
;  Uses:      Interrupt 21h Function 42h
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@MovePtrAbs MACRO handle:REQ, distance
    IFNB    <distance>
        __LdDub <distance>
    ENDIF
    mov     bx, handle
    mov     ax, 4200h
    int     21h
ENDM

; 42h
@MovePtrRel MACRO handle:REQ, distance
    IFNB    <distance>
        __LdDub <distance>
    ENDIF
    mov     bx, handle
    mov     ax, 4201h
    int     21h
ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Syntax:    @MkDir path [,segment]
;
;             @RmDir path [,segment]
;
;             @ChDir path [,segment]
;
;  Summary:   Creates, deletes, or changes to the specified directory
;
;  Arguments: <path>        Offset of ASCIIZ string containing
;                           directory. Must be offset address.
;
;             <segment>     Segment of path; DS if none given.
;
;  Returns:   If carry: set, error code in AX
;
;  Modifies:  AX, DX; DS if segment changed
;
;  Uses:      Interrupt 21h Function 39h
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@MkDir MACRO path:REQ, segmnt
    __LdAdr dx, <path>
    IFNB    <segmnt>
        __LdSeg ds, <segmnt>
    ENDIF
    mov     ah, 39h
    int     21h
ENDM

; 3Ah
@RmDir MACRO path:REQ, segmnt
    __LdAdr dx, <path>
    IFNB    <segmnt>
        __LdSeg ds, <segmnt>
    ENDIF
    mov     ah, 3Ah
    int     21h
ENDM

; 3Bh
@ChDir MACRO path:REQ, segmnt
    __LdAdr dx, <path>
    IFNB    <segmnt>
        __LdSeg ds, <segmnt>
    ENDIF
    mov     ah, 3Bh
    int     21h
ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Syntax:    @GetDir buffer [,[drive] [,segment]]
;
;  Summary:   Returns the current directory of the specified drive
;
;  Arguments: <buffer>      Offset of buffer to receive ASCIIZ
;                           directory. Must be an offset address.
;
;             <drive>       8-bit drive number (0 = current, 1 = A,
;                           2 = B, ...; 0 if none given).
;
;             <segment>     Segment of path; DS if none given.
;
;  Returns:   If carry: set, error code in AX
;
;  Modifies:  AX, SI, DL; DS if segment changes
;
;  Uses:      Interrupt 21h Function 47h
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@GetDir MACRO buffer:REQ, drive, segmnt
    IFNB    <drive>
        mov     dl, drive
    ELSE
        sub     dl, dl
    ENDIF
    __LdAdr si, <buffer>
    IFNB    <segmnt>
        __LdSeg ds, <segmnt>
    ENDIF
    mov     ah, 47h
    int     21h
ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Syntax:    @GetDrv
;
;             @SetDrv drive
;
;  Summary:   Gets or sets the current drive
;
;  Argument:  <drive>     8-bit drive number (0 = A, 1 = B, ...)
;
;  Returns:   For @GetDrv, drive number in AL (0 = A, 1 = B, ...);
;             for @SetDrv, number of drives in AL
;
;  Modifies:  AX for both; DL for @SetDrv
;
;  Uses:      Interrupt 21h Function 19h
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@GetDrv MACRO
    mov     ah, 19h
    int     21h
ENDM

; 0Eh
@SetDrv MACRO drive:REQ
    mov     dl, drive
    mov     ah, 0Eh
    int     21h
ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Syntax:    @ChkDrv [drive]
;
;  Summary:   Gets various data about a disk
;
;  Argument:  <drive>     8-bit drive number (0 = current, A = 1,
;                         B = 2, ...); if none given, current assumed
;
;  Returns:   AX     Sectors per cluster; -1 if drive invalid
;             BX     Available clusters
;             CX     Bytes per sector
;             DX     Clusters per drive
;
;  Modifies:  AX, BX, CX, DX
;
;  Uses:      Interrupt 21h Function 1Ch
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@ChkDrv MACRO drive
    IFNB    <drive>
        mov     dl, drive
    ELSE
        sub     dl, dl
    ENDIF
    mov     ah, 1Ch
    int     21h
ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Syntax:    @Exit [return]
;
;  Summary:   Exits to DOS with return code
;
;  Argument:  <return>     8-bit code to return to DOS; if none given,
;                          AL is used. If given, must be a constant.
;
;  Returns:   No return value
;
;  Modifies:  AX
;
;  Uses:      Interrupt 21h Function 4Ch
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@Exit MACRO return
    IFB     <return>
        mov     ah, 4Ch
    ELSE
        mov     ax, 4C00h + (return AND 0FFh)
    ENDIF
    int     21h
ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Syntax:    @TSR paragraphs [,return]
;
;  Summary:   Terminates a program, but leaves it resident in memory
;
;  Arguments: <paragraphs>     Memory in paragraphs (16 bytes) to
;                              allocate for resident program.
;             <return>         Code to return to DOS; if none, AL used.
;                              Must be a constant.
;
;  Returns:   No return value
;
;  Modifies:  AX, DX
;
;  Uses:      Interrupt 21h Function 31h
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@TSR MACRO paragraphs:REQ, return
    mov     dx, paragraphs
    IFB     <return>
        mov     ah, 31h
    ELSE
        mov     ax, 3100h + (return AND 0FFh)
    ENDIF
    int     21h
ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Syntax:    @FreeBlock [segment]
;
;  Summary:   Frees a block of memory
;
;  Argument:  <segment>     Starting address of memory to be freed; if
;                           none given, ES address assumed
;
;  Returns:   If carry: set, error code in AX
;
;  Modifies:  AX; ES if segment given
;
;  Uses:      Interrupt 21h Function 49h
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@FreeBlock MACRO segmnt
    IFNB    <segmnt>
        __LdSeg es, <segmnt>
    ENDIF
    mov     ah, 49h
    int     21h
ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Syntax:    @GetBlock paragraphs [, retry]
;
;  Summary:   Allocates a block of memory
;
;  Argument:  <paragraphs>     Paragraphs (16 bytes) of memory wanted
;             <retry>          If nonzero, allocate largest block
;                              available
;
;  Returns:   AX     If carry: clear, the segment of the allocated
;                    memory. If carry: set, an error code
;             BX     Paragraphs actually allocated. If <retry> is not
;                    zero, it may be less than requested.
;
;  Modifies:  AX, BX
;
;  Uses:      Interrupt 21h Function 48h
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@GetBlock MACRO graphs:REQ, retry:=<0>
    LOCAL   tryit
    mov     bx, graphs
    tryit:  mov     ah, 48h
    int     21h

    IF      retry
    jc  tryit
    ENDIF
ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Syntax:    @ModBlock paragraphs [,segment]
;
;  Summary:   Modifies an allocated block of memory
;
;  Arguments: <paragraphs>     Paragraphs (16 bytes) of memory wanted.
;
;             <segment>        Starting address of memory to be freed; if
;                              none given, ES address assumed.
;
;  Returns:   If carry is set, the error code is returned in AX;
;               otherwise, the ES register contains the segment address of
;               allocated memory. If carry is clear, the BX register contains
;               the number of paragraphs allocated.
;
;  Modifies:  AX, BX; ES if segment given
;
;  Uses:      Interrupt 21h Function 4Ah
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@ModBlock MACRO graphs:REQ, segmnt
    IFNB    <segmnt>
        __LdSeg es, <segmnt>
    ENDIF
    mov     bx, graphs
    mov     ah, 4Ah
    int     21h
ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Syntax:    @GetDate
;
;  Summary:   Gets the system date
;
;  Arguments: None
;
;  Returns:   AL     Day of week (0 = Sunday, 1 = Monday, ...)
;             CX     Year (1980-2099)
;             DH     Month (1-12)
;             DL     Day (1-31)
;
;  Modifies:  AX, CX, DX
;
;  Uses:      Interrupt 21h Function 2Ah
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@GetDate MACRO
    mov     ah, 2Ah
    int     21h
ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Syntax:    @SetDate month, day, year
;
;  Summary:   Sets the system date
;
;  Arguments: <month>     8-bit month (1-12)
;
;             <day>       8-bit day (1-31)
;
;             <year>      16-bit year (1980-2099)
;
;  Returns:   AL     If date was valid 0, else -1
;
;  Modifies:  AX, CX, DX
;
;  Uses:      Interrupt 21h Function 2Bh
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@SetDate MACRO month:REQ, day:REQ, year:REQ
    mov     cx, year
    mov     dh, month
    mov     dl, day
    mov     ah, 2Bh
    int     21h
ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Syntax:    @GetTime
;
;  Summary:   Gets the system time
;
;  Arguments: None
;
;  Returns:   CH     Hour (0-23)
;             CL     Minute (0-59)
;             DH     Second (0-59)
;             DL     Hundredth (0-99)
;
;  Modifies:  AX, CX, DX
;
;  Uses:      Interrupt 21h Function 2Ch
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@GetTime MACRO
    mov     ah, 2Ch
    int     21h
ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Syntax:    @SetTime hour,minute,second,hundredth
;
;  Summary:   Sets the system time
;
;  Arguments: <hour>          8-bit hours (0-23)
;
;             <minute>        8-bit minutes (0-59)
;
;             <second>        8-bit seconds (0-59)
;
;             <hundredth>     8-bit hundredth of seconds (0-99)
;
;  Returns:   AL     If time was valid 0, else -1
;
;  Modifies:  AX, CX, DX
;
;  Uses:      Interrupt 21h Function 2Dh
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@SetTime MACRO hour:REQ, minutes:REQ, seconds:REQ, hundredths:REQ
    mov     ch, hour
    mov     cl, minutes
    mov     dh, seconds
    mov     dl, hundredths
    mov     ah, 2Dh
    int     21h
ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Syntax:    @GetVer
;
;  Summary:   Gets the DOS version
;
;  Arguments: None
;
;  Returns:   AL        Major version (0 for versions prior to 2.0)
;             AH        Minor version
;             BH        OEM serial number
;             BL:CX     24-bit user number
;
;  Modifies:  AX, BX, CX
;
;  Uses:      Interrupt 21h Function 30h
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@GetVer MACRO
    mov     ah, 30h
    int     21h
ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Syntax:    @GetInt interrupt
;
;             @SetInt interrupt, vector [,segment]
;
;  Summary:   Gets or sets the vector for a specified interrupt
;             routine
;
;  Arguments: <interrupt>     8-bit interrupt number. Must be a
;                             constant.
;
;             <vector>        Offset of interrupt routine.
;
;             <segment>       Segment of routine; if none given, DS
;                             assumed for data; segment ignored for
;                             code labels.
;
;  Returns:   For @GetInt, ES:BX points to interrupt routine;
;             for @SetInt, no return value
;
;  Modifies:  AX for both; ES and BX for @GetInt; DS and DX for
;             @SetInt
;
;  Uses:      Interrupt 21h Function 35h
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@GetInt MACRO   interrupt:REQ
    mov     ax, 3500h + (interrupt AND 0FFh)
    int     21h
ENDM

; 25h
@SetInt MACRO interrupt:REQ, vector:REQ, segmnt
    IF  (TYPE (vector) EQ NPVOID) OR (TYPE (vector) EQ FPVOID)
        mov     dx, OFFSET vector
        mov     ax, SEG vector
        mov     ds, ax
    ELSE
        __LdAdr dx, <vector>
        IFNB    <segmnt>
            __LdSeg ds, <segmnt>
        ENDIF
    ENDIF
    mov     ax, 2500h + (interrupt AND 0FFh)
    int     21h
ENDM
