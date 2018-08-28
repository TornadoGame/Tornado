; Utility Macros - Version 1.0 - for Microsoft Macro Assembler 6.0
; (C) Copyright Microsoft Corporation, 1987,1988,1989,1990

;* @ArgCount - Macro function returns the number of arguments in a
;* VARARG list.
;*
;* Params:  arglist - arguments to be counted

@ArgCount MACRO arglist:VARARG
    LOCAL count
    count = 0
    FOR arg, <arglist>
        count = count + 1
    ENDM
    EXITM %count
ENDM

;* @ArgI - Macro function returns an argument specified by number
;* from a VARARG list.
;*
;* Shows:   Directives - FOR       LOCAL    EXITM
;*                       TEXTEQU   =
;*          Operator   - EQ
;*
;* Params:  index - one-based number of the argument to be returned
;*          arglist - argument list

@ArgI MACRO index:REQ, arglist:VARARG
    LOCAL count, retstr
    count = 0
    FOR arg, <arglist>
        count = count + 1
        IF count EQ index
            retstr TEXTEQU <arg>
        ENDIF
    ENDM
    EXITM retstr
ENDM

;* @ArgRev - Macro function returns a reversed order version of a
;* VARARG list.
;*
;* Shows:   Operators           - <>         !        %
;*          String directive    - SUBSTR
;*          Predefined function - @SizeStr
;*
;* Params:  arglist - arguments to be reversed

@ArgRev MACRO arglist
    LOCAL txt, arg
    txt TEXTEQU <>
%   FOR arg, arglist
        txt CATSTR <arg>, <!,>, txt
    ENDM

    txt SUBSTR  txt, 1, @SizeStr( %txt ) - 1
    txt CATSTR  <!<>, txt, <!>>
    EXITM txt
ENDM

;* @SaveRegs and @RestoreRegs - Macros to save and restore a list
;* of macros. @SaveRegs pushes each register in the argument list.
;* and saves each register name in a text macro. @RestoreRegs uses
;* the saved register list to pop each register.
;*
;* Shows:   Directives - CATSTR    INSTR
;*
;*
;* Params:  For @SaveRegs, the registers to be pushed
;*          For @RestoreRegs, none

pregs   TEXTEQU <>  ; Initialize global text macro to empty

@SaveRegs MACRO regs:VARARG
        LOCAL reg
pregs   CATSTR  <!<>, <regs>, <!>>
%       FOR reg, <regs>
            push reg                                ;; Push each register
        ENDM
ENDM

@RestoreRegs MACRO
    LOCAL   reg
%   FOR reg, @ArgRev( pregs )                   ;; @ArgRev from MACROS.INC
        pop reg                                 ;; Pop each register
    ENDM
ENDM

;* @PushAll and @PopAll - Macros to push and pop all general purpose
;* registers. Registers are pushed in the following order:
;*    AX, CX, DX, BX, SP, BP, SI, DI
;* They are popped in the reverse order. Uses most efficient method
;* available at assembly time (not at run time).
;*
;* Shows:   Instruction - pusha     popa
;*          Operator    - AND
;*
;* Params:  None

@PushAll MACRO
    IF @Cpu AND 00000010y       ;; If assembling on 80186/286/386,
        pusha                   ;;  use efficient PUSHA
    ELSE                        ;; Otherwise push individually
        push ax
        push cx
        push dx
        push bx
        push sp
        push bp
        push si
        push di
    ENDIF
ENDM

@PopAll MACRO
    IF @Cpu AND 00000010y       ;; If assembling on 80186/286/386,
        popa                    ;;  use efficient POPA
    ELSE                        ;; Otherwise pop individually
        pop di
        pop si
        pop bp
        pop sp
        pop bx
        pop dx
        pop cx
        pop ax
    ENDIF
ENDM

;* echof - Macro to display assembly-time value of expressions. The
;* syntax is similar to the C printf function. Useful for debugging
;* macros. For example, the following line displays the SIZE of an
;* array:
;*          echof  <The value of $ is $>, (SIZE array), %(SIZE array)
;*
;* Params:  format - Text to be displayed with a $ placeholder for
;*                   each expression to be evaluated and inserted.
;*          args -   List of expressions to be evaluated. Text of
;*                   each value will be inserted into the format.

echof   MACRO   format:REQ, args:VARARG
    LOCAL   string, pos, lastpos

    ;; Initialize variables
    pos     =   1
    string  TEXTEQU <>
    ;; Loop through, finding $ and building output string
    FOR val, <args>
        ;; If beyond end of format string, exit FOR loop
        IF pos GE @SizeStr( format )
            pos = 0
            EXITM
        ENDIF
        ;; Save last position and find the next $
        lastpos = pos
        pos     = @InStr( pos, format, <$> )
        ;; If $ not found, exit FOR loop
        IF pos EQ 0
            EXITM
        ENDIF
        ;; Append text up the next $
        string  CATSTR string, @SubStr( format, lastpos, pos - lastpos )
        ;; Append matching value and skip past $
        string  CATSTR string, <val>
        pos     = pos + 1
    ENDM
    IF pos
        ;; Attach any trailing characters
        IF pos LE @SizeStr( format )
            string CATSTR string, @SubStr( format, pos )
        ENDIF
        ;; Display the finished string
%       ECHO string
    ELSE
        ECHO echof error: $ count does not match argument count
    ENDIF
ENDM

;* Equates for conditional handling of pointers

        IF @DataSize
lesIF   TEXTEQU    <les>
ldsIF   TEXTEQU    <lds>
esIF    TEXTEQU    <es:>
        ELSE
lesIF   TEXTEQU    <mov>
ldsIF   TEXTEQU    <mov>
esIF    TEXTEQU    <>
        ENDIF

;* pushc - Macro that pushes a constant using the most efficient
;* method for the current processor. The 80286 version pushes
;* directly. Since this is illegal on the 8086, this version pushes
;* through AX.
;*
;* Shows:   Operator    - OPATTR
;*          Text macro  - @Cpu

IF  @Cpu AND 00000010y
    pushc  MACRO op             ;; 80186 or higher
        push op
    ENDM
ELSE
    pushc  MACRO op             ;; 8088/8086
        IFE (OPATTR (adr)) AND 00000100y
            mov  ax, op         ;; If it's really a constant
            push ax             ;;   push through register
        ELSE
            push op             ;; If not constant, push normal
        ENDIF
    ENDM
ENDIF
