embsth4		OBJECTHEADER <OBJ_SCALE4,1000,embs4_2,0,COL_BLACK1,12,32,8>
		DB	044,000,064	;   0
		DB	084,000,064	;   1
		DB	056,128,080	;   2
		DB	072,128,080	;   3
		DB	056,000,076	;   4
		DB	072,000,076	;   5
		DB	062,128,080	;   6
		DB	066,128,080	;   7
		DB	066,000,076	;   8
		DB	062,000,076	;   9
		DB	040,112,064	;  10
		DB	088,112,064	;  11
		DB	056,128,064	;  12
		DB	072,128,064	;  13
		DB	-1

		DW	OFFSET	embsth4_1

		EVEN

embsth4_1	DW	54


embsth4_0	LABEL	BYTE
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

embs4_2		OBJECTHEADER <OBJ_SCALE2,8192,embs4_3,0,COL_BLACK1,6,16,4>
		DB	054,032,064	;   0
		DB	074,032,064	;   1
		DB	060,096,072	;   2
		DB	068,096,072	;   3
		DB	060,032,070	;   4
		DB	068,032,070	;   5
		DB	064,096,072	;   6
		DB	064,032,070	;   7
		DB	052,088,064	;   8
		DB	076,088,064	;   9
		DB	060,096,064	;  10
		DB	068,096,064	;  11
		DB	-1

		DW	OFFSET	embs4_2_1

		EVEN

embs4_2_1	DW	48


embs4_2_0	LABEL	BYTE
		DB	008h,COL_RAIL1,06,10,08,04,-1		; face 0
		DB	002h,4,COL_RAIL2,12,14,-1		; line 3
		DB	008h,COL_HILL2,00,16,04,08,-1		; face 3
		DB	008h,COL_HILL2,10,06,18,02,-1		; face 4
		DB	008h,COL_GREY3,04,20,22,06,-1		; face 5
		DB	008h,COL_GREY2,16,20,04,-1		; face 6
		DB	008h,COL_GREY2,06,22,18,-1		; face 7
		DB	-1

		EVEN

embs4_3		OBJECTHEADER <OBJ_SCALE1,16384,-1,1,COL_BLACK1,3,8,2>
		DB	058,048,064	;   0
		DB	070,048,064	;   1
		DB	062,080,068	;   2
		DB	066,080,068	;   3
		DB	062,048,068	;   4
		DB	066,048,068	;   5
		DB	064,080,068	;   6
		DB	064,048,068	;   7
		DB	058,076,064	;   8
		DB	070,076,064	;   9
		DB	062,080,064	;  10
		DB	066,080,064	;  11
		DB	-1

		DW	OFFSET	embs4_3_1

		EVEN

embs4_3_1	DW	48


embs4_3_0	LABEL	BYTE
		DB	008h,COL_RAIL1,06,10,08,04,-1		; face 0
		DB	002h,4,COL_RAIL2,12,14,-1		; line 3
		DB	008h,COL_HILL2,00,16,04,08,-1		; face 3
		DB	008h,COL_HILL2,10,06,18,02,-1		; face 4
		DB	008h,COL_GREY3,04,20,22,06,-1		; face 5
		DB	008h,COL_GREY2,16,20,04,-1		; face 6
		DB	008h,COL_GREY2,06,22,18,-1		; face 7
		DB	-1

		EVEN

