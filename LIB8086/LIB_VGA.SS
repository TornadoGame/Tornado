;****************************************************************************
;*
;* LIB_VGA.SS
;*
;* VGA SSprites required for library.
;*
;* Notes:-
;*
;* Menu "pointers" should have their x and y offset values set to 0.
;*
;* 30.08.1991 - KJB
;*
;****************************************************************************

;* VGA SSprite data (screen co-ords 008, 064)

_StndPtr	DW	00003h		;width in bytes
		DW	0000ch		;depth
		DW	00003h*0000ch	;size
		DW	0		;x offset <<<<< set to 0
		DW	0		;y offset <<<<< set to 0
		DB	009h		;mask colour
		DB	000h		;padding

		DB	000h,000h,009h,009h,009h,009h,009h,009h
		DB	009h,009h,009h,009h
		DB	000h,00fh,000h,009h,009h,009h,009h,009h
		DB	009h,009h,009h,009h
		DB	000h,00fh,00fh,000h,009h,009h,009h,009h
		DB	009h,009h,009h,009h
		DB	000h,00fh,00fh,00fh,000h,009h,009h,009h
		DB	009h,009h,009h,009h
		DB	000h,00fh,00fh,00fh,00fh,000h,009h,009h
		DB	009h,009h,009h,009h
		DB	000h,00fh,00fh,00fh,00fh,00fh,000h,009h
		DB	009h,009h,009h,009h
		DB	000h,00fh,00fh,00fh,00fh,00fh,00fh,000h
		DB	009h,009h,009h,009h
		DB	000h,00fh,00fh,00fh,00fh,00fh,00fh,00fh
		DB	000h,009h,009h,009h
		DB	000h,00fh,00fh,00fh,00fh,00fh,00fh,00fh
		DB	00fh,000h,009h,009h
		DB	000h,00fh,00fh,000h,00fh,00fh,00fh,000h
		DB	000h,000h,009h,009h
		DB	000h,000h,000h,000h,000h,00fh,00fh,00fh
		DB	000h,009h,009h,009h
		DB	009h,009h,009h,009h,009h,000h,000h,000h
		DB	000h,009h,009h,009h

		DB	(00003h+1)*0000ch*4 DUP(009h)

		EVEN

;* VGA SSprite data (screen co-ords 152, 132)

_Button0	DW	00003h		;width in bytes
		DW	0000bh		;depth
		DW	00003h*0000bh	;size
		DW	0fffah		;x offset
		DW	0fffbh		;y offset
		DB	009h		;mask colour
		DB	000h		;padding

		DB	00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh
		DB	00fh,00fh,00fh,009h
		DB	00fh,007h,007h,007h,007h,007h,007h,007h
		DB	007h,007h,000h,009h
		DB	00fh,007h,007h,007h,007h,007h,007h,007h
		DB	007h,007h,000h,009h
		DB	00fh,007h,007h,007h,007h,007h,007h,007h
		DB	007h,007h,000h,009h
		DB	00fh,007h,007h,007h,007h,007h,007h,007h
		DB	007h,007h,000h,009h
		DB	00fh,007h,007h,007h,007h,007h,007h,007h
		DB	007h,007h,000h,009h
		DB	00fh,007h,007h,007h,007h,007h,007h,007h
		DB	007h,007h,000h,009h
		DB	00fh,007h,007h,007h,007h,007h,007h,007h
		DB	007h,007h,000h,009h
		DB	00fh,007h,007h,007h,007h,007h,007h,007h
		DB	007h,007h,000h,009h
		DB	00fh,007h,007h,007h,007h,007h,007h,007h
		DB	007h,007h,000h,009h
		DB	000h,000h,000h,000h,000h,000h,000h,000h
		DB	000h,000h,000h,009h

		DB	(00003h+1)*0000bh*4 DUP(009h)

		EVEN

;* VGA SSprite data (screen co-ords 152, 144)

_Button1	DW	00003h		;width in bytes
		DW	0000bh		;depth
		DW	00003h*0000bh	;size
		DW	0fffah		;x offset
		DW	0fffbh		;y offset
		DB	009h		;mask colour
		DB	000h		;padding

		DB	00fh,00fh,00fh,00fh,00fh,00fh,00fh,00fh
		DB	00fh,00fh,00fh,009h
		DB	00fh,007h,007h,007h,007h,007h,007h,007h
		DB	007h,007h,000h,009h
		DB	00fh,007h,007h,007h,007h,007h,007h,007h
		DB	007h,007h,000h,009h
		DB	00fh,007h,007h,007h,007h,007h,007h,007h
		DB	000h,007h,000h,009h
		DB	00fh,007h,007h,007h,007h,007h,007h,000h
		DB	007h,007h,000h,009h
		DB	00fh,007h,007h,007h,007h,007h,000h,007h
		DB	007h,007h,000h,009h
		DB	00fh,007h,007h,007h,007h,000h,007h,007h
		DB	007h,007h,000h,009h
		DB	00fh,007h,000h,007h,000h,007h,007h,007h
		DB	007h,007h,000h,009h
		DB	00fh,007h,007h,000h,007h,007h,007h,007h
		DB	007h,007h,000h,009h
		DB	00fh,007h,007h,007h,007h,007h,007h,007h
		DB	007h,007h,000h,009h
		DB	000h,000h,000h,000h,000h,000h,000h,000h
		DB	000h,000h,000h,009h

		DB	(00003h+1)*0000bh*4 DUP(009h)

		EVEN

