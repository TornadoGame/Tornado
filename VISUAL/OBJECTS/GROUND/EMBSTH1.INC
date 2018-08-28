embsth1		OBJECTHEADER <OBJ_SCALE4,1000,embs1_2,0,COL_BLACK1,8,32,2>
		DB	080,128,064	;   0
		DB	048,128,064	;   1
		DB	080,000,064	;   2
		DB	048,000,064	;   3
		DB	076,128,068	;   4
		DB	052,128,068	;   5
		DB	066,000,064	;   6
		DB	062,000,064	;   7
		DB	062,128,068	;   8
		DB	066,128,068	;   9
		DB	-1

		DW	OFFSET	embsth1_1

		EVEN

embsth1_1	DW	33


embsth1_0	LABEL	BYTE
		DB	008h,COL_RAIL1,06,10,08,04,-1		; face 0
		DB	002h,4,COL_RAIL2,14,16,-1		; line 3
		DB	002h,4,COL_RAIL2,12,18,-1		; line 4
		DB	008h,COL_HILL2,06,02,10,-1		; face 1
		DB	008h,COL_HILL2,04,08,00,-1		; face 2
		DB	-1

		EVEN

embs1_2		OBJECTHEADER <OBJ_SCALE2,8192,embs1_3,0,COL_BLACK1,4,16,1>
		DB	072,096,064	;   0
		DB	056,096,064	;   1
		DB	072,032,064	;   2
		DB	056,032,064	;   3
		DB	070,096,066	;   4
		DB	058,096,066	;   5
		DB	064,032,064	;   6
		DB	064,096,066	;   7
		DB	-1

		DW	OFFSET	embs1_2_1

		EVEN

embs1_2_1	DW	27


embs1_2_0	LABEL	BYTE
		DB	008h,COL_RAIL1,06,10,08,04,-1		; face 0
		DB	002h,4,COL_RAIL2,12,14,-1		; line 4
		DB	008h,COL_HILL2,06,02,10,-1		; face 1
		DB	008h,COL_HILL2,04,08,00,-1		; face 2
		DB	-1

		EVEN

embs1_3		OBJECTHEADER <OBJ_SCALE1,16384,-1,1,COL_BLACK1,2,8,0>
		DB	068,080,064	;   0
		DB	060,080,064	;   1
		DB	068,048,064	;   2
		DB	060,048,064	;   3
		DB	066,080,064	;   4
		DB	062,080,064	;   5
		DB	-1

		DW	OFFSET	embs1_3_1

		EVEN

embs1_3_1	DW	14


embs1_3_0	LABEL	BYTE
		DB	008h,COL_HILL2,06,02,10,-1		; face 1
		DB	008h,COL_HILL2,04,08,00,-1		; face 2
		DB	-1

		EVEN

