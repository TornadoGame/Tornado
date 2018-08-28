embnrth3	OBJECTHEADER <OBJ_SCALE4,1000,embn3_2,0,COL_BLACK1,10,32,6>
		DB	044,000,064	;   0
		DB	084,000,064	;   1
		DB	056,128,072	;   2
		DB	072,128,072	;   3
		DB	056,000,076	;   4
		DB	072,000,076	;   5
		DB	062,128,072	;   6
		DB	066,128,072	;   7
		DB	066,000,076	;   8
		DB	062,000,076	;   9
		DB	048,128,064	;  10
		DB	080,128,064	;  11
		DB	-1

		DW	OFFSET	embnrth3_1

		EVEN

embnrth3_1	DW	35


embnrth3_0	LABEL	BYTE
		DB	008h,COL_RAIL1,06,10,08,04,-1		; face 0
		DB	002h,4,COL_RAIL2,14,16,-1		; line 3
		DB	002h,4,COL_RAIL2,12,18,-1		; line 4
		DB	008h,COL_HILL2,00,20,04,08,-1		; face 3
		DB	008h,COL_HILL2,10,06,22,02,-1		; face 4
		DB	-1

		EVEN

embn3_2		OBJECTHEADER <OBJ_SCALE2,8192,embn3_3,0,COL_BLACK1,5,16,3>
		DB	054,032,064	;   0
		DB	074,032,064	;   1
		DB	060,096,068	;   2
		DB	068,096,068	;   3
		DB	060,032,070	;   4
		DB	068,032,070	;   5
		DB	064,096,068	;   6
		DB	064,032,070	;   7
		DB	056,096,064	;   8
		DB	072,096,064	;   9
		DB	-1

		DW	OFFSET	embn3_2_1

		EVEN

embn3_2_1	DW	29


embn3_2_0	LABEL	BYTE
		DB	008h,COL_RAIL1,06,10,08,04,-1		; face 0
		DB	002h,4,COL_RAIL2,12,14,-1		; line 4
		DB	008h,COL_HILL2,00,16,04,08,-1		; face 3
		DB	008h,COL_HILL2,10,06,18,02,-1		; face 4
		DB	-1

		EVEN

embn3_3		OBJECTHEADER <OBJ_SCALE1,16384,-1,1,COL_BLACK1,3,8,2>
		DB	058,048,064	;   0
		DB	070,048,064	;   1
		DB	062,080,066	;   2
		DB	066,080,066	;   3
		DB	062,048,068	;   4
		DB	066,048,068	;   5
		DB	064,080,066	;   6
		DB	064,048,068	;   7
		DB	060,080,064	;   8
		DB	068,080,064	;   9
		DB	-1

		DW	OFFSET	embn3_3_1

		EVEN

embn3_3_1	DW	29


embn3_3_0	LABEL	BYTE
		DB	008h,COL_RAIL1,06,10,08,04,-1		; face 0
		DB	002h,4,COL_RAIL2,12,14,-1		; line 4
		DB	008h,COL_HILL2,00,16,04,08,-1		; face 3
		DB	008h,COL_HILL2,10,06,18,02,-1		; face 4
		DB	-1

		EVEN

