helipad		OBJECTHEADER <OBJ_SCALE16,512,helipad2,0,COL_BLACK1,32,32,0>
		DB	054,084	;   0
		DB	074,084	;   2
		DB	074,044	;   4
		DB	054,044	;   6
		DB	068,044	;   8
		DB	060,044	;  10
		DB	060,084	;  12
		DB	068,084	;  14
		DB	060,068	;  16
		DB	060,060	;  18
		DB	068,068	;  20
		DB	068,060	;  22
		DB	064,128	;  24
		DB	128,064	;  26
		DB	064,000	;  28
		DB	000,064	;  30
		DB	120,032	;  32
		DB	008,032	;  34
		DB	096,008	;  36
		DB	032,008	;  38
		DB	008,096	;  40
		DB	120,096	;  42
		DB	096,120	;  44
		DB	032,120	;  46
		DB	-1

		DW	OFFSET	helipad_1

		EVEN

helipad_1	DW	43


helipad_0	LABEL	BYTE
		DB	008h,COL_RWY1,36,28,24,44,42,26,32,-1	; face 4
		DB	008h,COL_RWY1,46,24,28,38,34,30,40,-1	; face 5
		DB	008h,COL_WHITE1,04,08,14,02,-1		; face 1
		DB	008h,COL_WHITE1,12,10,06,00,-1		; face 2
		DB	008h,COL_WHITE1,16,20,22,18,-1		; face 3
		DB	-1

		EVEN

helipad2	OBJECTHEADER <OBJ_SCALE8,2048,helipad3,0,COL_BLACK1,16,16,0>
		DB	060,074	;   0
		DB	068,074	;   2
		DB	068,054	;   4
		DB	060,054	;   6
		DB	066,054	;   8
		DB	062,054	;  10
		DB	062,074	;  12
		DB	066,074	;  14
		DB	062,066	;  16
		DB	062,062	;  18
		DB	066,066	;  20
		DB	066,062	;  22
		DB	064,096	;  24
		DB	096,064	;  26
		DB	064,032	;  28
		DB	032,064	;  30
		DB	092,048	;  32
		DB	036,048	;  34
		DB	080,036	;  36
		DB	048,036	;  38
		DB	036,080	;  40
		DB	092,080	;  42
		DB	080,092	;  44
		DB	048,092	;  46
		DB	-1

		DW	OFFSET	helipad2_1

		EVEN

helipad2_1	DW	46


helipad2_0	LABEL	BYTE
		DB	008h,COL_RWY1,36,28,24,44,42,26,32,-1	; face 4
		DB	008h,COL_RWY1,46,24,28,38,34,30,40,-1	; face 5
		DB	000h,6,COL_GREY1,04,08,14,02,-1		; face 1
		DB	000h,6,COL_GREY1,12,10,06,00,-1		; face 2
		DB	000h,6,COL_GREY1,16,20,22,18,-1		; face 3
		DB	-1

		EVEN

helipad3	OBJECTHEADER <OBJ_SCALE1,8000,-1,1,COL_RWY1,2,2,0>
		DB	064,064	;   0
		DB	064,068	;   2
		DB	068,064	;   4
		DB	064,060	;   6
		DB	060,064	;   8
		DB	066,062	;  10
		DB	062,062	;  12
		DB	062,066	;  14
		DB	066,066	;  16
		DB	-1

		DW	OFFSET	helipad3_1

		EVEN

helipad3_1	DW	20


helipad3_0	LABEL	BYTE
		DB	008h,COL_RWY1,06,02,04,-1		; face 4
		DB	008h,COL_RWY1,02,06,08,-1		; face 5
		DB	002h,4,COL_GREY1,00,00,-1		; line 3
		DB	-1

		EVEN

