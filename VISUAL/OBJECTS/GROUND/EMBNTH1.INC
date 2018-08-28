embnth1		OBJECTHEADER <OBJ_SCALE4,1000,embn1_2,0,COL_BLACK1,8,32,2>
		DB	048,000,064	;   0
		DB	080,000,064	;   1
		DB	048,128,064	;   2
		DB	080,128,064	;   3
		DB	052,000,068	;   4
		DB	076,000,068	;   5
		DB	062,128,064	;   6
		DB	066,128,064	;   7
		DB	066,000,068	;   8
		DB	062,000,068	;   9
		DB	-1

		DW	OFFSET	embnth1_1

		EVEN

embnth1_1	DW	33


embnth1_0	LABEL	BYTE
		DB	008h,COL_RAIL1,06,10,08,04,-1		; face 0
		DB	002h,4,COL_RAIL2,14,16,-1		; line 3
		DB	002h,4,COL_RAIL2,12,18,-1		; line 4
		DB	008h,COL_HILL2,06,02,10,-1		; face 1
		DB	008h,COL_HILL2,04,08,00,-1		; face 2
		DB	-1

		EVEN

embn1_2		OBJECTHEADER <OBJ_SCALE2,8192,embn1_3,0,COL_BLACK1,4,16,1>
		DB	056,032,064	;   0
		DB	072,032,064	;   1
		DB	056,096,064	;   2
		DB	072,096,064	;   3
		DB	058,032,066	;   4
		DB	070,032,066	;   5
		DB	064,096,064	;   6
		DB	064,032,066	;   7
		DB	-1

		DW	OFFSET	embn1_2_1

		EVEN

embn1_2_1	DW	27


embn1_2_0	LABEL	BYTE
		DB	008h,COL_RAIL1,06,10,08,04,-1		; face 0
		DB	002h,4,COL_RAIL2,12,14,-1		; line 4
		DB	008h,COL_HILL2,06,02,10,-1		; face 1
		DB	008h,COL_HILL2,04,08,00,-1		; face 2
		DB	-1

		EVEN

embn1_3		OBJECTHEADER <OBJ_SCALE1,16384,-1,1,COL_BLACK1,2,8,0>
		DB	060,048,064	;   0
		DB	068,048,064	;   1
		DB	060,080,064	;   2
		DB	068,080,064	;   3
		DB	062,048,064	;   4
		DB	066,048,064	;   5
		DB	-1

		DW	OFFSET	embn1_3_1

		EVEN

embn1_3_1	DW	14


embn1_3_0	LABEL	BYTE
		DB	008h,COL_HILL2,06,02,10,-1		; face 1
		DB	008h,COL_HILL2,04,08,00,-1		; face 2
		DB	-1

		EVEN

