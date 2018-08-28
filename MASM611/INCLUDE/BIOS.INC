; BIOS Interface Macros - Version 1.2 - for Microsoft Macro Assembler 6.1
; (C) Copyright Microsoft Corporation, 1987,1988,1989,1990

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Syntax:    @GetMode
;
;  Summary:   Gets the current video mode and page
;
;  Arguments: None
;
;  Returns:   AL     Mode
;	      AH     Width in characters
;	      BH     Page
;
;  Modifies:  AX, BH
;
;  Uses:      Interrupt 10h Function 0Fh
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@GetMode MACRO
    mov   ah, 0Fh
    int   10h
ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Syntax:    @SetMode mode
;
;  Summary:   Sets the current video mode and page
;
;  Argument:  <mode>	 8-bit video mode.
;
;  Returns:   No return value
;
;  Modifies:  AX
;
;  Uses:      Interrupt 10h Function 00h
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@SetMode MACRO mode
    mov   al, mode
    xor   ah, ah
    int   10h
ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Syntax:    @SetColor color
;
;  Summary:   Sets the background color
;
;  Argument:  <color>	  8-bit background color (0-15); border
;			  color in text modes
;
;  Returns:   No return value
;
;  Modifies:  AX, BX
;
;  Uses:      Interrupt 10h Function 0Bh
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@SetColor MACRO color
    sub   bh, bh
    mov   bl, color
    mov   ah, 0Bh
    int   10h
ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Syntax:    @SetPalette color
;
;  Summary:   Sets the color palette
;
;  Argument:  <color>	  8-bit color palette; 0-1 for modes 5 and 6
;
;  Returns:   No return value
;
;  Modifies:  AX, BX
;
;  Uses:      Interrupt 10h Function 0Bh
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@SetPalette MACRO color
    mov   bh, 1
    mov   bl, color
    mov   ah, 0Bh
    int   10h
ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Syntax:    @SetPage page
;
;  Summary:   Sets the video page
;
;  Argument:  <page>	 8-bit page number; 0-3 for modes 2 and 3
;
;  Returns:   No return value
;
;  Modifies:  AX
;
;  Uses:      Interrupt 10h Function 05h
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@SetPage MACRO pagenum
    mov   al, pagenum
    mov   ah, 05h
    int   10h
ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Syntax:    @GetCsr [page]
;
;  Summary:   Gets the cursor position and size
;
;  Argument:  <page>	 8-bit page with cursor; if none given,
;			 0 assumed
;
;  Returns:   DL     Column
;	      DH     Row
;	      CL     Starting scan line
;	      CH     Ending scan line
;
;  Modifies:  AX, DX, CX, BH
;
;  Uses:      Interrupt 10h Function 03h
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@GetCsr MACRO pagenum
    IFNB <pagenum>
        mov   bh, pagenum
    ELSE
        xor   bh, bh
    ENDIF
    mov   ah, 03h
    int   10h
ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Syntax:    @SetCsrPos [column] [,[row] [,page]]
;
;  Summary:   Sets the cursor position
;
;  Arguments: <column>	   8-bit column; if none given, DL used.
;
;	      <row>	   8-bit row; if none given, DH used.
;
;	      <page>	   8-bit page with cursor; if none given,
;			   0 assumed.
;
;  Returns:   No return value
;
;  Modifies:  AX, DX, BH
;
;  Uses:      Interrupt 10h Function 02h
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@SetCsrPos MACRO column, row, pagenum
    IFNB <column>
        mov   dl, column
    ENDIF
    IFNB <row>
        mov   dh, row
    ENDIF
    IFNB <pagenum>
        mov   bh, pagenum
    ELSE
        xor   bh, bh
    ENDIF
    mov   ah, 02h
    int   10h
ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Syntax:    @SetCsrSize startline, endline
;
;  Summary:   Sets the cursor size and shape by specifying active scan
;	      lines. For color adapters, the lines are 0-7. For the
;	      monochrome adapter, the lines are 0-13.
;
;  Arguments: <startline>     8-bit starting scan line (default CGA = 6;
;			      MA = 12)
;
;	      <endline>       8-bit ending scan line (default CGA = 7;
;			      MA = 13)
;
;  Returns:   No return value
;
;  Modifies:  AX, CX
;
;  Uses:      Interrupt 10h Function 01h
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@SetCsrSize MACRO first, last
    mov   ch, first
    mov   cl, last
    mov   ah, 01h
    int   10h
ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Syntax:    @GetCharAtr [page]
;
;  Summary:   Gets the character and attribute at the cursor location
;
;  Argument:  <page>	 8-bit page to check; if none given, 0 assumed
;
;  Returns:   AH     Attribute
;	      AL     ASCII character
;
;  Modifies:  AX, BH
;
;  Uses:      Interrupt 10h Function 08h
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@GetCharAtr MACRO pagenum
    IFNB <pagenum>
        mov   bh, pagenum
    ELSE
        sub   bh, bh
    ENDIF
    mov   ah, 08h
    int   10h
ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Syntax:    @PutCharAtr [character] [,[attrib] [,[page] [,count]]]
;
;	      @PutChar [character] [,[page] [,count]]
;
;  Summary:   Puts one or more characters and attributes at the current
;	      cursor position. For @PutChar, the current attribute is
;	      used in text modes and any specified attribute is ignored.
;
;  Arguments: <character>     8-bit ASCII character to put; if none
;			      given, AL used.
;
;	      <attrib>	      8-bit attribute to put; if none given,
;			      BL used.
;
;	      <page>	      8-bit page to put on; if none given, 0
;			      assumed.
;
;	      <count>	      Number to put; if none given, 1 assumed.
;
;  Returns:   No return value
;
;  Modifies:  AX, BX, CX
;
;  Uses:      Interrupt 10h Function 09h
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@PutCharAtr MACRO chr, atrib, pagenum, loops
    IFNB <chr>
        mov   al, chr
    ENDIF
    IFNB    <atrib>
        mov   bl, atrib
    ENDIF
    IFNB <pagenum>
        mov   bh, pagenum
    ELSE
        xor   bh, bh
    ENDIF
    IFNB <loops>
        mov   cx, loops
    ELSE
        mov   cx, 1
    ENDIF
    mov   ah, 09h
    int   10h
ENDM

; 0Ah
@PutChar MACRO chr, atrib, pagenum, loops
    IFNB <chr>
        mov   al, chr
    ENDIF
    IFNB    <atrib>
        mov   bl, atrib
    ENDIF
    IFNB <pagenum>
        mov   bh, pagenum
    ELSE
        xor   bh, bh
    ENDIF
    IFNB <loops>
        mov   cx, loops
    ELSE
        mov   cx, 1
    ENDIF
    mov   ah, 0Ah
    int   10h
ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Syntax:    @Scroll dist [,[attr][,[upcol [,[uprow [,[dncol][,dnrow]]]]]]]
;
;  Summary:   Scrolls a specified window up or down
;
;  Arguments: <dist>	  8-bit number of lines to scroll; positive
;			  scrolls down; negative scrolls up; 0 clears.
;
;	      <attr>	  8-bit attribute for blank lines; if none
;			  given, 07h (white on black).
;
;	      <upcol>	  Upper left column; if none given, CL used.
;
;	      <uprow>	  Upper left row; if none given, CH used.
;
;	      <dncol>	  Lower right column; if none given, DL used.
;
;	      <dnrow>	  Lower right row; if none given, DH used.
;
;  Returns:   No return value
;
;  Modifies:  AX, CX, DX, BH
;
;  Uses:      Interrupt 10h Function 06h and 07h
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@Scroll MACRO distance:REQ, atrib:=<07h>, upcol, uprow, dncol, dnrow
    IFNB <upcol>
        mov   cl, upcol
    ENDIF
    IFNB <uprow>
        mov   ch, uprow
    ENDIF
    IFNB <dncol>
        mov   dl, dncol
    ENDIF
    IFNB <dnrow>
        mov   dh, dnrow
    ENDIF
    mov   bh, atrib
    IF distance LE 0
        mov   ax, 0600h + (-(distance) AND 0FFh)
    ELSE
        mov   ax, 0700h + (distance AND 0FFh)
    ENDIF
    int   10h
ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;  Syntax:    @Cls [page]
;
;  Summary:   Clears the screen
;
;  Argument:  <page>	 Video page (8-bit); if none given, 0 assumed
;
;  Returns:   No return value
;
;  Modifies:  AX, BX, CX, DX
;
;  Uses:      Interrupt 10h Function 08h, 06h, and 02h
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@Cls MACRO pagenum
    IFNB <pagenum>
        IFDIFI <pagenum>, <bh>
            mov   bh, pagenum
        ENDIF
    ELSE
        sub   bh, bh
    ENDIF
    mov   ah, 08h
    int   10h
    mov   bh, ah
    sub   cx, cx
    mov   dx, 324Fh
    mov   ax, 0600h
    int   10h
    mov   bh, bl
    sub   dx, dx
    mov   ah, 02h
    int   10h
ENDM
