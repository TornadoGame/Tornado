sidingew	OBJECTHEADER <OBJ_SCALE4,2048,sidingew2,0,COL_BLACK1,32,32,0>
		DB	000,054	;   0
		DB	128,054	;   2
		DB	000,058	;   4
		DB	128,058	;   6
		DB	000,070	;   8
		DB	128,070	;  10
		DB	000,074	;  12
		DB	128,074	;  14
		DB	000,078	;  16
		DB	000,082	;  18
		DB	128,082	;  20
		DB	128,078	;  22
		DB	128,076	;  24
		DB	000,076	;  26
		DB	000,128	;  28
		DB	128,128	;  30
		DB	-1

		DW	OFFSET	sidingew_1

		EVEN

sidingew_1	DW	45


sidingew1_0	LABEL	BYTE
		DB	002h,4,COL_RAIL2,00,02,-1		; line 3
		DB	002h,4,COL_RAIL2,04,06,-1		; line 4
		DB	002h,4,COL_RAIL2,08,10,-1		; line 5
		DB	002h,4,COL_RAIL2,12,14,-1		; line 6
		DB	008h,COL_RWY1,28,30,24,26,-1		; face 5
		DB	002h,4,COL_RAIL2,18,20,-1		; line 6
		DB	002h,4,COL_RAIL2,16,22,-1		; line 7
		DB	-1

		EVEN

sidingew2	OBJECTHEADER <OBJ_SCALE1,16384,-1,1,COL_RAIL2,8,8,0>
		DB	048,062	;   0
		DB	080,062	;   2
		DB	048,064	;   4
		DB	080,064	;   6
		DB	048,066	;   8
		DB	080,066	;  10
		DB	048,068	;  12
		DB	080,068	;  14
		DB	048,080	;  16
		DB	080,080	;  18
		DB	-1

		DW	OFFSET	sidingew2_1

		EVEN

sidingew2_1	DW	33


sidingew2_0	LABEL	BYTE
		DB	002h,4,COL_RAIL2,00,02,-1		; line 3
		DB	002h,4,COL_RAIL2,04,06,-1		; line 5
		DB	008h,COL_RWY1,16,18,10,08,-1		; face 5
		DB	002h,4,COL_RAIL2,12,14,-1		; line 6
		DB	002h,4,COL_RAIL2,08,10,-1		; line 7
		DB	-1

		EVEN

