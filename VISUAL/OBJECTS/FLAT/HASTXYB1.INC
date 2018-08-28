HAStxyb1	OBJECTHEADER <OBJ_SCALE2,4000,-1,1,COL_GREY2,11,21,0>
		DB	072,048	;   0
		DB	056,048	;   2
		DB	064,048	;   4
		DB	068,030	;   6
		DB	066,028	;   8
		DB	058,028	;  10
		DB	056,026	;  12
		DB	056,022	;  14
		DB	046,036	;  16
		DB	042,036	;  18
		DB	064,032	;  20
		DB	-1

		DW	OFFSET	HAStxyb1_1

		EVEN

HAStxyb1_1	DW	30


HAStxyb1_0	LABEL	BYTE
		DB	008h,COL_RWY1,08,10,02,00,06,-1		; face 4
		DB	002h,4,COL_WHITE1,04,20,-1		; line 7
		DB	008h,COL_RWY1,10,12,16,02,-1		; face 5
		DB	008h,COL_RWY1,12,14,18,16,-1		; face 6
		DB	-1

		EVEN

