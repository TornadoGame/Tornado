embsth2		OBJECTHEADER <OBJ_SCALE4,1000,embs2_2,0,COL_BLACK1,8,32,4>
		DB	048,000,064	;   0
		DB	080,000,064	;   1
		DB	056,128,072	;   2
		DB	072,128,072	;   3
		DB	052,000,068	;   4
		DB	076,000,068	;   5
		DB	062,128,072	;   6
		DB	066,128,072	;   7
		DB	066,000,068	;   8
		DB	062,000,068	;   9
		DB	048,128,064	;  10
		DB	080,128,064	;  11
		DB	-1

		DW	OFFSET	embsth2_1

		EVEN

embsth2_1	DW	35


embsth2_0	LABEL	BYTE
		DB	008h,COL_RAIL1,06,10,08,04,-1		; face 0
		DB	002h,4,COL_RAIL2,14,16,-1		; line 3
		DB	002h,4,COL_RAIL2,12,18,-1		; line 4
		DB	008h,COL_HILL2,00,20,04,08,-1		; face 3
		DB	008h,COL_HILL2,10,06,22,02,-1		; face 4
		DB	-1

		EVEN

embs2_2		OBJECTHEADER <OBJ_SCALE2,8192,embs2_3,0,COL_BLACK1,4,16,2>
		DB	056,032,064	;   0
		DB	072,032,064	;   1
		DB	060,096,068	;   2
		DB	068,096,068	;   3
		DB	058,032,066	;   4
		DB	070,032,066	;   5
		DB	064,096,068	;   6
		DB	064,032,066	;   7
		DB	056,096,064	;   8
		DB	072,096,064	;   9
		DB	-1

		DW	OFFSET	embs2_2_1

		EVEN

embs2_2_1	DW	29


embs2_2_0	LABEL	BYTE
		DB	008h,COL_RAIL1,06,10,08,04,-1		; face 0
		DB	002h,4,COL_RAIL2,12,14,-1		; line 3
		DB	008h,COL_HILL2,00,16,04,08,-1		; face 3
		DB	008h,COL_HILL2,10,06,18,02,-1		; face 4
		DB	-1

		EVEN

embs2_3		OBJECTHEADER <OBJ_SCALE1,16384,-1,1,COL_BLACK1,2,8,1>
		DB	062,080,066	;   0
		DB	066,080,066	;   1
		DB	062,048,064	;   2
		DB	066,048,064	;   3
		DB	064,080,066	;   4
		DB	064,048,064	;   5
		DB	060,080,064	;   6
		DB	068,080,064	;   7
		DB	068,048,064	;   8
		DB	060,048,064	;   9
		DB	-1

		DW	OFFSET	embs2_3_1

		EVEN

embs2_3_1	DW	29


embs2_3_0	LABEL	BYTE
		DB	008h,COL_RAIL1,02,06,04,00,-1		; face 0
		DB	002h,4,COL_RAIL2,08,10,-1		; line 3
		DB	008h,COL_HILL2,06,02,14,16,-1		; face 2
		DB	008h,COL_HILL2,18,12,00,04,-1		; face 3
		DB	-1

		EVEN

