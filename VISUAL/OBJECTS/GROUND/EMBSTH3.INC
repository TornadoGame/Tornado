embsth3		OBJECTHEADER <OBJ_SCALE4,1000,embs3_2,0,COL_BLACK1,10,32,6>
		DB	084,128,064	;   0
		DB	044,128,064	;   1
		DB	072,000,072	;   2
		DB	056,000,072	;   3
		DB	072,128,076	;   4
		DB	056,128,076	;   5
		DB	066,000,072	;   6
		DB	062,000,072	;   7
		DB	062,128,076	;   8
		DB	066,128,076	;   9
		DB	080,000,064	;  10
		DB	048,000,064	;  11
		DB	-1

		DW	OFFSET	embsth3_1

		EVEN

embsth3_1	DW	35


embsth3_0	LABEL	BYTE
		DB	008h,COL_RAIL1,06,10,08,04,-1		; face 0
		DB	002h,4,COL_RAIL2,14,16,-1		; line 3
		DB	002h,4,COL_RAIL2,12,18,-1		; line 4
		DB	008h,COL_HILL2,00,20,04,08,-1		; face 3
		DB	008h,COL_HILL2,10,06,22,02,-1		; face 4
		DB	-1

		EVEN

embs3_2		OBJECTHEADER <OBJ_SCALE2,8192,embs3_3,0,COL_BLACK1,5,16,3>
		DB	074,096,064	;   0
		DB	054,096,064	;   1
		DB	068,032,068	;   2
		DB	060,032,068	;   3
		DB	068,096,070	;   4
		DB	060,096,070	;   5
		DB	064,032,068	;   6
		DB	064,096,070	;   7
		DB	072,032,064	;   8
		DB	056,032,064	;   9
		DB	-1

		DW	OFFSET	embs3_2_1

		EVEN

embs3_2_1	DW	29


embs3_2_0	LABEL	BYTE
		DB	008h,COL_RAIL1,06,10,08,04,-1		; face 0
		DB	002h,4,COL_RAIL2,12,14,-1		; line 4
		DB	008h,COL_HILL2,00,16,04,08,-1		; face 3
		DB	008h,COL_HILL2,10,06,18,02,-1		; face 4
		DB	-1

		EVEN

embs3_3		OBJECTHEADER <OBJ_SCALE1,16384,-1,1,COL_BLACK1,3,8,2>
		DB	070,080,064	;   0
		DB	058,080,064	;   1
		DB	066,048,066	;   2
		DB	062,048,066	;   3
		DB	066,080,068	;   4
		DB	062,080,068	;   5
		DB	064,048,066	;   6
		DB	064,080,068	;   7
		DB	068,048,064	;   8
		DB	060,048,064	;   9
		DB	-1

		DW	OFFSET	embs3_3_1

		EVEN

embs3_3_1	DW	29


embs3_3_0	LABEL	BYTE
		DB	008h,COL_RAIL1,06,10,08,04,-1		; face 0
		DB	002h,4,COL_RAIL2,12,14,-1		; line 4
		DB	008h,COL_HILL2,00,16,04,08,-1		; face 3
		DB	008h,COL_HILL2,10,06,18,02,-1		; face 4
		DB	-1

		EVEN

