;* VGA SSprite data (screen co-ords 008, 013)

_HUDDigit0_0	DW	00001h		;width in bytes
		DW	00005h		;depth
		DW	00001h*00005h	;size
		DW	0fffeh		;x offset
		DW	0fffeh		;y offset
		DB	003h		;mask colour
		DB	000h		;padding

		DB	085h,085h,085h,003h
		DB	085h,003h,085h,003h
		DB	085h,003h,085h,003h
		DB	085h,003h,085h,003h
		DB	085h,085h,085h,003h

		DB	(00001h+1)*00005h*4 DUP(003h)

		EVEN

;* VGA SSprite data (screen co-ords 016, 013)

_HUDDigit0_1	DW	00001h		;width in bytes
		DW	00005h		;depth
		DW	00001h*00005h	;size
		DW	0fffeh		;x offset
		DW	0fffeh		;y offset
		DB	003h		;mask colour
		DB	000h		;padding

		DB	003h,085h,085h,085h
		DB	003h,085h,003h,085h
		DB	003h,085h,003h,085h
		DB	003h,085h,003h,085h
		DB	003h,085h,085h,085h

		DB	(00001h+1)*00005h*4 DUP(003h)

		EVEN

;* VGA SSprite data (screen co-ords 008, 019)

_HUDDigit1_0	DW	00001h		;width in bytes
		DW	00005h		;depth
		DW	00001h*00005h	;size
		DW	0fffeh		;x offset
		DW	0fffeh		;y offset
		DB	003h		;mask colour
		DB	000h		;padding

		DB	003h,085h,003h,003h
		DB	085h,085h,003h,003h
		DB	003h,085h,003h,003h
		DB	003h,085h,003h,003h
		DB	085h,085h,085h,003h

		DB	(00001h+1)*00005h*4 DUP(003h)

		EVEN

;* VGA SSprite data (screen co-ords 016, 019)

_HUDDigit1_1	DW	00001h		;width in bytes
		DW	00005h		;depth
		DW	00001h*00005h	;size
		DW	0fffeh		;x offset
		DW	0fffeh		;y offset
		DB	003h		;mask colour
		DB	000h		;padding

		DB	003h,003h,085h,003h
		DB	003h,085h,085h,003h
		DB	003h,003h,085h,003h
		DB	003h,003h,085h,003h
		DB	003h,085h,085h,085h

		DB	(00001h+1)*00005h*4 DUP(003h)

		EVEN

;* VGA SSprite data (screen co-ords 008, 025)

_HUDDigit2_0	DW	00001h		;width in bytes
		DW	00005h		;depth
		DW	00001h*00005h	;size
		DW	0fffeh		;x offset
		DW	0fffeh		;y offset
		DB	003h		;mask colour
		DB	000h		;padding

		DB	085h,085h,085h,003h
		DB	003h,003h,085h,003h
		DB	085h,085h,085h,003h
		DB	085h,003h,003h,003h
		DB	085h,085h,085h,003h

		DB	(00001h+1)*00005h*4 DUP(003h)

		EVEN

;* VGA SSprite data (screen co-ords 016, 025)

_HUDDigit2_1	DW	00001h		;width in bytes
		DW	00005h		;depth
		DW	00001h*00005h	;size
		DW	0fffeh		;x offset
		DW	0fffeh		;y offset
		DB	003h		;mask colour
		DB	000h		;padding

		DB	003h,085h,085h,085h
		DB	003h,003h,003h,085h
		DB	003h,085h,085h,085h
		DB	003h,085h,003h,003h
		DB	003h,085h,085h,085h

		DB	(00001h+1)*00005h*4 DUP(003h)

		EVEN

;* VGA SSprite data (screen co-ords 008, 031)

_HUDDigit3_0	DW	00001h		;width in bytes
		DW	00005h		;depth
		DW	00001h*00005h	;size
		DW	0fffeh		;x offset
		DW	0fffeh		;y offset
		DB	003h		;mask colour
		DB	000h		;padding

		DB	085h,085h,085h,003h
		DB	003h,003h,085h,003h
		DB	085h,085h,085h,003h
		DB	003h,003h,085h,003h
		DB	085h,085h,085h,003h

		DB	(00001h+1)*00005h*4 DUP(003h)

		EVEN

;* VGA SSprite data (screen co-ords 016, 031)

_HUDDigit3_1	DW	00001h		;width in bytes
		DW	00005h		;depth
		DW	00001h*00005h	;size
		DW	0fffeh		;x offset
		DW	0fffeh		;y offset
		DB	003h		;mask colour
		DB	000h		;padding

		DB	003h,085h,085h,085h
		DB	003h,003h,003h,085h
		DB	003h,085h,085h,085h
		DB	003h,003h,003h,085h
		DB	003h,085h,085h,085h

		DB	(00001h+1)*00005h*4 DUP(003h)

		EVEN

;* VGA SSprite data (screen co-ords 008, 037)

_HUDDigit4_0	DW	00001h		;width in bytes
		DW	00005h		;depth
		DW	00001h*00005h	;size
		DW	0fffeh		;x offset
		DW	0fffeh		;y offset
		DB	003h		;mask colour
		DB	000h		;padding

		DB	085h,003h,003h,003h
		DB	085h,003h,003h,003h
		DB	085h,003h,085h,003h
		DB	085h,085h,085h,003h
		DB	003h,003h,085h,003h

		DB	(00001h+1)*00005h*4 DUP(003h)

		EVEN

;* VGA SSprite data (screen co-ords 016, 037)

_HUDDigit4_1	DW	00001h		;width in bytes
		DW	00005h		;depth
		DW	00001h*00005h	;size
		DW	0fffeh		;x offset
		DW	0fffeh		;y offset
		DB	003h		;mask colour
		DB	000h		;padding

		DB	003h,085h,003h,003h
		DB	003h,085h,003h,003h
		DB	003h,085h,003h,085h
		DB	003h,085h,085h,085h
		DB	003h,003h,003h,085h

		DB	(00001h+1)*00005h*4 DUP(003h)

		EVEN

;* VGA SSprite data (screen co-ords 008, 043)

_HUDDigit5_0	DW	00001h		;width in bytes
		DW	00005h		;depth
		DW	00001h*00005h	;size
		DW	0fffeh		;x offset
		DW	0fffeh		;y offset
		DB	003h		;mask colour
		DB	000h		;padding

		DB	085h,085h,085h,003h
		DB	085h,003h,003h,003h
		DB	085h,085h,003h,003h
		DB	003h,003h,085h,003h
		DB	085h,085h,003h,003h

		DB	(00001h+1)*00005h*4 DUP(003h)

		EVEN

;* VGA SSprite data (screen co-ords 016, 043)

_HUDDigit5_1	DW	00001h		;width in bytes
		DW	00005h		;depth
		DW	00001h*00005h	;size
		DW	0fffeh		;x offset
		DW	0fffeh		;y offset
		DB	003h		;mask colour
		DB	000h		;padding

		DB	003h,085h,085h,085h
		DB	003h,085h,003h,003h
		DB	003h,085h,085h,003h
		DB	003h,003h,003h,085h
		DB	003h,085h,085h,003h

		DB	(00001h+1)*00005h*4 DUP(003h)

		EVEN

;* VGA SSprite data (screen co-ords 008, 049)

_HUDDigit6_0	DW	00001h		;width in bytes
		DW	00005h		;depth
		DW	00001h*00005h	;size
		DW	0fffeh		;x offset
		DW	0fffeh		;y offset
		DB	003h		;mask colour
		DB	000h		;padding

		DB	085h,085h,085h,003h
		DB	085h,003h,003h,003h
		DB	085h,085h,085h,003h
		DB	085h,003h,085h,003h
		DB	085h,085h,085h,003h

		DB	(00001h+1)*00005h*4 DUP(003h)

		EVEN

;* VGA SSprite data (screen co-ords 016, 049)

_HUDDigit6_1	DW	00001h		;width in bytes
		DW	00005h		;depth
		DW	00001h*00005h	;size
		DW	0fffeh		;x offset
		DW	0fffeh		;y offset
		DB	003h		;mask colour
		DB	000h		;padding

		DB	003h,085h,085h,085h
		DB	003h,085h,003h,003h
		DB	003h,085h,085h,085h
		DB	003h,085h,003h,085h
		DB	003h,085h,085h,085h

		DB	(00001h+1)*00005h*4 DUP(003h)

		EVEN

;* VGA SSprite data (screen co-ords 008, 055)

_HUDDigit7_0	DW	00001h		;width in bytes
		DW	00005h		;depth
		DW	00001h*00005h	;size
		DW	0fffeh		;x offset
		DW	0fffeh		;y offset
		DB	003h		;mask colour
		DB	000h		;padding

		DB	085h,085h,085h,003h
		DB	003h,003h,085h,003h
		DB	003h,003h,085h,003h
		DB	003h,003h,085h,003h
		DB	003h,003h,085h,003h

		DB	(00001h+1)*00005h*4 DUP(003h)

		EVEN

;* VGA SSprite data (screen co-ords 016, 055)

_HUDDigit7_1	DW	00001h		;width in bytes
		DW	00005h		;depth
		DW	00001h*00005h	;size
		DW	0fffeh		;x offset
		DW	0fffeh		;y offset
		DB	003h		;mask colour
		DB	000h		;padding

		DB	003h,085h,085h,085h
		DB	003h,003h,003h,085h
		DB	003h,003h,003h,085h
		DB	003h,003h,003h,085h
		DB	003h,003h,003h,085h

		DB	(00001h+1)*00005h*4 DUP(003h)

		EVEN

;* VGA SSprite data (screen co-ords 008, 061)

_HUDDigit8_0	DW	00001h		;width in bytes
		DW	00005h		;depth
		DW	00001h*00005h	;size
		DW	0fffeh		;x offset
		DW	0fffeh		;y offset
		DB	003h		;mask colour
		DB	000h		;padding

		DB	085h,085h,085h,003h
		DB	085h,003h,085h,003h
		DB	085h,085h,085h,003h
		DB	085h,003h,085h,003h
		DB	085h,085h,085h,003h

		DB	(00001h+1)*00005h*4 DUP(003h)

		EVEN

;* VGA SSprite data (screen co-ords 016, 061)

_HUDDigit8_1	DW	00001h		;width in bytes
		DW	00005h		;depth
		DW	00001h*00005h	;size
		DW	0fffeh		;x offset
		DW	0fffeh		;y offset
		DB	003h		;mask colour
		DB	000h		;padding

		DB	003h,085h,085h,085h
		DB	003h,085h,003h,085h
		DB	003h,085h,085h,085h
		DB	003h,085h,003h,085h
		DB	003h,085h,085h,085h

		DB	(00001h+1)*00005h*4 DUP(003h)

		EVEN

;* VGA SSprite data (screen co-ords 008, 067)

_HUDDigit9_0	DW	00001h		;width in bytes
		DW	00005h		;depth
		DW	00001h*00005h	;size
		DW	0fffeh		;x offset
		DW	0fffeh		;y offset
		DB	003h		;mask colour
		DB	000h		;padding

		DB	085h,085h,085h,003h
		DB	085h,003h,085h,003h
		DB	085h,085h,085h,003h
		DB	003h,003h,085h,003h
		DB	085h,085h,085h,003h

		DB	(00001h+1)*00005h*4 DUP(003h)

		EVEN

;* VGA SSprite data (screen co-ords 016, 067)

_HUDDigit9_1	DW	00001h		;width in bytes
		DW	00005h		;depth
		DW	00001h*00005h	;size
		DW	0fffeh		;x offset
		DW	0fffeh		;y offset
		DB	003h		;mask colour
		DB	000h		;padding

		DB	003h,085h,085h,085h
		DB	003h,085h,003h,085h
		DB	003h,085h,085h,085h
		DB	003h,003h,003h,085h
		DB	003h,085h,085h,085h

		DB	(00001h+1)*00005h*4 DUP(003h)

		EVEN

