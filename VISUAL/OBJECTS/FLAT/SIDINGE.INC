sidinge		OBJECTHEADER <OBJ_SCALE4,2048,sidinge2,0,COL_BLACK1,32,32,0>
		DB	000,070	;   0
		DB	064,070	;   2
		DB	000,074	;   4
		DB	064,074	;   6
		DB	000,054	;   8
		DB	000,058	;  10
		DB	064,066	;  12
		DB	064,062	;  14
		DB	128,066	;  16
		DB	128,062	;  18
		DB	000,076	;  20
		DB	124,076	;  22
		DB	072,128	;  24
		DB	000,128	;  26
		DB	000,078	;  28
		DB	000,082	;  30
		DB	112,082	;  32
		DB	112,078	;  34
		DB	124,084	;  36
		DB	-1

		DW	OFFSET	sidinge_1

		EVEN

sidinge_1	DW	46


sidinge1_0	LABEL	BYTE
		DB	00Ah,COL_RAIL2,12,10,-1			; line 5
		DB	00Ah,COL_RAIL2,14,08,-1			; line 6
		DB	00Ah,COL_RAIL2,04,06,16,-1		; line 3
		DB	00Ah,COL_RAIL2,00,02,18,-1		; line 4
		DB	008h,COL_RWY1,22,20,26,24,36,-1		; face 5
		DB	002h,5,COL_RAIL2,02,28,34,-1		; line 6
		DB	002h,5,COL_RAIL2,06,30,32,-1		; line 7
		DB	-1

		EVEN

sidinge2	OBJECTHEADER <OBJ_SCALE1,16384,-1,1,COL_RAIL2,8,8,0>
		DB	048,064	;   0
		DB	064,064	;   2
		DB	048,066	;   4
		DB	064,066	;   6
		DB	048,062	;   8
		DB	080,064	;  10
		DB	078,066	;  12
		DB	066,080	;  14
		DB	048,080	;  16
		DB	048,068	;  18
		DB	076,068	;  20
		DB	076,066	;  22
		DB	078,068	;  24
		DB	-1

		DW	OFFSET	sidinge2_1

		EVEN

sidinge2_1	DW	45


sidinge2_0	LABEL	BYTE
		DB	00Ah,COL_RAIL2,02,00,-1			; line 5
		DB	00Ah,COL_RAIL2,02,08,-1			; line 6
		DB	00Ah,COL_RAIL2,04,06,10,-1		; line 3
		DB	00Ah,COL_RAIL2,00,10,-1			; line 4
		DB	008h,COL_RWY1,12,04,16,14,24,-1		; face 5
		DB	002h,5,COL_RAIL2,02,04,22,-1		; line 6
		DB	002h,5,COL_RAIL2,06,18,20,-1		; line 7
		DB	-1

		EVEN

