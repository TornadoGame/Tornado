sidingw		OBJECTHEADER <OBJ_SCALE4,2048,sidingw2,0,COL_BLACK1,32,32,0>
		DB	000,062	;   0
		DB	064,070	;   2
		DB	000,066	;   4
		DB	064,074	;   6
		DB	064,062	;   8
		DB	064,066	;  10
		DB	128,058	;  12
		DB	128,054	;  14
		DB	128,074	;  16
		DB	128,070	;  18
		DB	128,078	;  20
		DB	128,082	;  22
		DB	012,082	;  24
		DB	012,078	;  26
		DB	128,076	;  28
		DB	006,076	;  30
		DB	006,092	;  32
		DB	128,128	;  34
		DB	056,128	;  36
		DB	-1

		DW	OFFSET	sidingw_1

		EVEN

sidingw_1	DW	46


sidingw1_0	LABEL	BYTE
		DB	00Ah,COL_RAIL2,12,10,-1			; line 5
		DB	00Ah,COL_RAIL2,14,08,-1			; line 6
		DB	00Ah,COL_RAIL2,04,06,16,-1		; line 3
		DB	00Ah,COL_RAIL2,00,02,18,-1		; line 4
		DB	008h,COL_RWY1,36,34,28,30,32,-1		; face 7
		DB	002h,5,COL_RAIL2,06,22,24,-1		; line 5
		DB	002h,5,COL_RAIL2,02,20,26,-1		; line 6
		DB	-1

		EVEN

sidingw2	OBJECTHEADER <OBJ_SCALE1,16384,-1,1,COL_RAIL2,8,8,0>
		DB	048,064	;   0
		DB	064,064	;   2
		DB	064,066	;   4
		DB	080,064	;   6
		DB	080,062	;   8
		DB	080,066	;  10
		DB	080,068	;  12
		DB	052,068	;  14
		DB	052,066	;  16
		DB	050,066	;  18
		DB	050,070	;  20
		DB	080,080	;  22
		DB	062,080	;  24
		DB	-1

		DW	OFFSET	sidingw2_1

		EVEN

sidingw2_1	DW	45


sidingw2_0	LABEL	BYTE
		DB	00Ah,COL_RAIL2,06,02,-1			; line 5
		DB	00Ah,COL_RAIL2,08,02,-1			; line 6
		DB	00Ah,COL_RAIL2,00,04,10,-1		; line 3
		DB	00Ah,COL_RAIL2,00,06,-1			; line 4
		DB	008h,COL_RWY1,24,22,10,18,20,-1		; face 7
		DB	002h,5,COL_RAIL2,04,12,14,-1		; line 5
		DB	002h,5,COL_RAIL2,02,10,16,-1		; line 6
		DB	-1

		EVEN

