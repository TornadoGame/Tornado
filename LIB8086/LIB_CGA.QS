;****************************************************************************
;*
;* LIB_CGA.QS
;*
;* CGA QSprites required for library.
;*
;* 13.01.1989 - KJB
;*
;****************************************************************************

;* CGA QSprite data (screen co-ords 152, 156)

_CloseSymbol	DW	00004h		;width in bytes 
		DW	0000ch		;depth

		DB	0ffh,0ffh,0ffh,0ffh
		DB	0c0h,000h,000h,000h
		DB	0cfh,0ffh,0ffh,0c0h
		DB	0cfh,0ffh,0ffh,0c0h
		DB	0cfh,0ffh,0ffh,0c0h
		DB	0cch,000h,000h,0c0h
		DB	0cch,0ffh,0fch,0c0h
		DB	0cch,000h,000h,0c0h
		DB	0cfh,0ffh,0ffh,0c0h
		DB	0cfh,0ffh,0ffh,0c0h
		DB	0cfh,0ffh,0ffh,0c0h
		DB	0c0h,000h,000h,000h

		EVEN

