;****************************************************************************
;*
;* LIB_CGA.SS
;*
;* CGA SSprites required for library.
;*
;* Notes:-
;*
;* Menu "pointers" should have their x and y offset values set to 0.
;*
;* 24.12.1989 - KJB
;*
;****************************************************************************

;* CGA SSprite data (screen co-ords 008, 064)

_StndPtr	DW	00004h		;width in bytes (inc. shift into byte)
		DW	0000ch		;depth
		DW	0		;x offset <<<<< set to 0
		DW	0		;y offset <<<<< set to 0
		DW	0		;shift 0 ptr
		DW	0		;shift 2 ptr

		DB	00fh,0ffh,0ffh,0ffh
		DB	003h,0ffh,0ffh,0ffh
		DB	000h,0ffh,0ffh,0ffh
		DB	000h,03fh,0ffh,0ffh
		DB	000h,00fh,0ffh,0ffh
		DB	000h,003h,0ffh,0ffh
		DB	000h,000h,0ffh,0ffh
		DB	000h,000h,03fh,0ffh
		DB	000h,000h,00fh,0ffh
		DB	000h,000h,00fh,0ffh
		DB	000h,000h,03fh,0ffh
		DB	0ffh,0c0h,03fh,0ffh

		DB	000h,000h,000h,000h
		DB	030h,000h,000h,000h
		DB	03ch,000h,000h,000h
		DB	03fh,000h,000h,000h
		DB	03fh,0c0h,000h,000h
		DB	03fh,0f0h,000h,000h
		DB	03fh,0fch,000h,000h
		DB	03fh,0ffh,000h,000h
		DB	03fh,0ffh,0c0h,000h
		DB	03ch,0fch,000h,000h
		DB	000h,03fh,000h,000h
		DB	000h,000h,000h,000h

		DB	00004h*0000ch*2 DUP(0)

		EVEN

;* CGA SSprite data (screen co-ords 152, 108)

_Button0	DW	00004h		;width in bytes (inc. shift into byte)
		DW	0000bh		;depth
		DW	0fffah		;x offset
		DW	0fffbh		;y offset
		DW	0		;shift 0 ptr
		DW	0		;shift 2 ptr

		DB	000h,000h,003h,0ffh
		DB	000h,000h,003h,0ffh
		DB	000h,000h,003h,0ffh
		DB	000h,000h,003h,0ffh
		DB	000h,000h,003h,0ffh
		DB	000h,000h,003h,0ffh
		DB	000h,000h,003h,0ffh
		DB	000h,000h,003h,0ffh
		DB	000h,000h,003h,0ffh
		DB	000h,000h,003h,0ffh
		DB	000h,000h,003h,0ffh

		DB	000h,000h,000h,000h
		DB	03fh,0ffh,0f0h,000h
		DB	03fh,0ffh,0f0h,000h
		DB	03fh,0ffh,0f0h,000h
		DB	03fh,0ffh,0f0h,000h
		DB	03fh,0ffh,0f0h,000h
		DB	03fh,0ffh,0f0h,000h
		DB	03fh,0ffh,0f0h,000h
		DB	03fh,0ffh,0f0h,000h
		DB	03fh,0ffh,0f0h,000h
		DB	000h,000h,000h,000h

		DB	00004h*0000bh*2 DUP(0)

		EVEN

;* CGA SSprite data (screen co-ords 152, 120)

_Button1	DW	00004h		;width in bytes (inc. shift into byte)
		DW	0000bh		;depth
		DW	0fffah		;x offset
		DW	0fffbh		;y offset
		DW	0		;shift 0 ptr
		DW	0		;shift 2 ptr

		DB	000h,000h,003h,0ffh
		DB	000h,000h,003h,0ffh
		DB	000h,000h,003h,0ffh
		DB	000h,000h,003h,0ffh
		DB	000h,000h,003h,0ffh
		DB	000h,000h,003h,0ffh
		DB	000h,000h,003h,0ffh
		DB	000h,000h,003h,0ffh
		DB	000h,000h,003h,0ffh
		DB	000h,000h,003h,0ffh
		DB	000h,000h,003h,0ffh

		DB	000h,000h,000h,000h
		DB	03fh,0ffh,0f0h,000h
		DB	03fh,0ffh,0f0h,000h
		DB	03fh,0ffh,030h,000h
		DB	03fh,0fch,0f0h,000h
		DB	03fh,0f3h,0f0h,000h
		DB	03fh,0cfh,0f0h,000h
		DB	033h,03fh,0f0h,000h
		DB	03ch,0ffh,0f0h,000h
		DB	03fh,0ffh,0f0h,000h
		DB	000h,000h,000h,000h

		DB	00004h*0000bh*2 DUP(0)

		EVEN

