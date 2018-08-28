embnss1		OBJECTHEADER <OBJ_SCALE4,1000,embnss2,0,COL_BLACK1,12,32,8>
		DB	088,128,064	;   0
		DB	040,128,064	;   1
		DB	072,000,080	;   2
		DB	056,000,080	;   3
		DB	072,128,080	;   4
		DB	056,128,080	;   5
		DB	066,000,080	;   6
		DB	062,000,080	;   7
		DB	062,128,080	;   8
		DB	066,128,080	;   9
		DB	088,016,064	;  10
		DB	040,016,064	;  11
		DB	072,000,064	;  12
		DB	056,000,064	;  13
		DB	-1

		DW	OFFSET	embnss1_1

		EVEN

embnss1_1	DW	54


embnss1_0	LABEL	BYTE
		DB	008h,COL_RAIL1,06,10,08,04,-1		; face 0
		DB	002h,4,COL_RAIL2,14,16,-1		; line 3
		DB	002h,4,COL_RAIL2,12,18,-1		; line 4
		DB	008h,COL_HILL2,00,20,04,08,-1		; face 3
		DB	008h,COL_HILL2,10,06,22,02,-1		; face 4
		DB	008h,COL_GREY3,04,24,26,06,-1		; face 5
		DB	008h,COL_GREY2,20,24,04,-1		; face 6
		DB	008h,COL_GREY2,06,26,22,-1		; face 7
		DB	-1

		EVEN

embnss2		OBJECTHEADER <OBJ_SCALE2,8192,embnss3,0,COL_BLACK1,6,16,4>
		DB	076,096,064	;   0
		DB	052,096,064	;   1
		DB	068,032,072	;   2
		DB	060,032,072	;   3
		DB	068,096,072	;   4
		DB	060,096,072	;   5
		DB	064,032,072	;   6
		DB	064,096,072	;   7
		DB	076,040,064	;   8
		DB	052,040,064	;   9
		DB	068,032,064	;  10
		DB	060,032,064	;  11
		DB	-1

		DW	OFFSET	embnss2_1

		EVEN

embnss2_1	DW	48


embnss2_0	LABEL	BYTE
		DB	008h,COL_RAIL1,06,10,08,04,-1		; face 0
		DB	002h,4,COL_RAIL2,12,14,-1		; line 4
		DB	008h,COL_HILL2,00,16,04,08,-1		; face 3
		DB	008h,COL_HILL2,10,06,18,02,-1		; face 4
		DB	008h,COL_GREY3,04,20,22,06,-1		; face 5
		DB	008h,COL_GREY2,16,20,04,-1		; face 6
		DB	008h,COL_GREY2,06,22,18,-1		; face 7
		DB	-1

		EVEN

embnss3		OBJECTHEADER <OBJ_SCALE1,16384,-1,1,COL_BLACK1,3,8,2>
		DB	070,080,064	;   0
		DB	058,080,064	;   1
		DB	066,048,068	;   2
		DB	062,048,068	;   3
		DB	066,080,068	;   4
		DB	062,080,068	;   5
		DB	064,048,068	;   6
		DB	064,080,068	;   7
		DB	070,052,064	;   8
		DB	058,052,064	;   9
		DB	066,048,064	;  10
		DB	062,048,064	;  11
		DB	-1

		DW	OFFSET	embnss3_1

		EVEN

embnss3_1	DW	48


embnss3_0	LABEL	BYTE
		DB	008h,COL_RAIL1,06,10,08,04,-1		; face 0
		DB	002h,4,COL_RAIL2,12,14,-1		; line 3
		DB	008h,COL_HILL2,00,16,04,08,-1		; face 3
		DB	008h,COL_HILL2,10,06,18,02,-1		; face 4
		DB	008h,COL_GREY3,04,20,22,06,-1		; face 5
		DB	008h,COL_GREY2,16,20,04,-1		; face 6
		DB	008h,COL_GREY2,06,22,18,-1		; face 7
		DB	-1

		EVEN

