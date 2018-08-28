HAStxy_1	OBJECTHEADER <OBJ_SCALE2,4000,-1,1,COL_GREY2,11,21,0>
		DB	056,048	;   0
		DB	072,048	;   2
		DB	060,030	;   4
		DB	072,026	;   6
		DB	072,022	;   8
		DB	082,036	;  10
		DB	086,036	;  12
		DB	064,048	;  14
		DB	064,032	;  16
		DB	062,028	;  18
		DB	070,028	;  20
		DB	-1

		DW	OFFSET	HAStxy_1_1

		EVEN

HAStxy_1_1	DW	30


HAStxy_1_0	LABEL	BYTE
		DB	008h,COL_RWY1,10,12,08,06,-1		; face 1
		DB	008h,COL_RWY1,02,10,06,20,-1		; face 6
		DB	008h,COL_RWY1,02,20,18,04,00,-1		; face 5
		DB	002h,4,COL_WHITE1,14,16,-1		; line 3
		DB	-1

		EVEN

