;****************************************************************************
;*
;* LIB_TAN.SS
;*
;* TAN SSprites required for library.
;*
;* Notes:-
;*
;* Menu "pointers" should have their x and y offset values set to 0.
;*
;* 24.12.1989 - KJB
;*
;****************************************************************************

;* TAN SSprite data (screen co-ords 008, 064)

_StndPtr	DW	00005h		;width in bytes
		DW	0000ch		;depth
		DW	00005h*0000ch	;size
		DW	0		;x offset <<<<< set to 0
		DW	0		;y offset <<<<< set to 0
		DW	09999h		;mask colour
		DW	0		;EGA page
		DW	0		;EGA page offset

		DB	000h,099h,099h,099h,099h
		DB	00fh,009h,099h,099h,099h
		DB	00fh,0f0h,099h,099h,099h
		DB	00fh,0ffh,009h,099h,099h
		DB	00fh,0ffh,0f0h,099h,099h
		DB	00fh,0ffh,0ffh,009h,099h
		DB	00fh,0ffh,0ffh,0f0h,099h
		DB	00fh,0ffh,0ffh,0ffh,009h
		DB	00fh,0ffh,0ffh,0ffh,0f0h
		DB	00fh,0f0h,0ffh,0f0h,000h
		DB	000h,000h,00fh,0ffh,009h
		DB	099h,099h,090h,000h,009h

		DB	00005h*0000ch DUP(0)

		DB	00018h DUP(0)	;extra buffer required for EGA masks

		EVEN

;* TAN SSprite data (screen co-ords 152, 132)

_Button0	DW	00006h		;width in bytes
		DW	0000bh		;depth
		DW	00006h*0000bh	;size
		DW	0fffah		;x offset
		DW	0fffbh		;y offset
		DW	09999h		;mask colour
		DW	0		;EGA page
		DW	0		;EGA page offset

		DB	0ffh,0ffh,0ffh,0ffh,0ffh,0f9h
		DB	0f7h,077h,077h,077h,077h,009h
		DB	0f7h,077h,077h,077h,077h,009h
		DB	0f7h,077h,077h,077h,077h,009h
		DB	0f7h,077h,077h,077h,077h,009h
		DB	0f7h,077h,077h,077h,077h,009h
		DB	0f7h,077h,077h,077h,077h,009h
		DB	0f7h,077h,077h,077h,077h,009h
		DB	0f7h,077h,077h,077h,077h,009h
		DB	0f7h,077h,077h,077h,077h,009h
		DB	000h,000h,000h,000h,000h,009h

		DB	00006h*0000bh DUP(0)

		EVEN

;* TAN SSprite data (screen co-ords 152, 144)

_Button1	DW	00006h		;width in bytes
		DW	0000bh		;depth
		DW	00006h*0000bh	;size
		DW	0fffah		;x offset
		DW	0fffbh		;y offset
		DW	09999h		;mask colour
		DW	0		;EGA page
		DW	0		;EGA page offset

		DB	0ffh,0ffh,0ffh,0ffh,0ffh,0f9h
		DB	0f7h,077h,077h,077h,077h,009h
		DB	0f7h,077h,077h,077h,077h,009h
		DB	0f7h,077h,077h,077h,007h,009h
		DB	0f7h,077h,077h,070h,077h,009h
		DB	0f7h,077h,077h,007h,077h,009h
		DB	0f7h,077h,070h,077h,077h,009h
		DB	0f7h,007h,007h,077h,077h,009h
		DB	0f7h,070h,077h,077h,077h,009h
		DB	0f7h,077h,077h,077h,077h,009h
		DB	000h,000h,000h,000h,000h,009h

		DB	00006h*0000bh DUP(0)

		EVEN

