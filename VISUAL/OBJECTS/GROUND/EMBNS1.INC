embns1		OBJECTHEADER <OBJ_SCALE4,1000,embns2,0,COL_BLACK1,12,32,8>
		DB	040,000,064	;   0
		DB	088,000,064	;   1
		DB	056,128,080	;   2
		DB	072,128,080	;   3
		DB	056,000,080	;   4
		DB	072,000,080	;   5
		DB	062,128,080	;   6
		DB	066,128,080	;   7
		DB	066,000,080	;   8
		DB	062,000,080	;   9
		DB	040,128,064	;  10
		DB	088,128,064	;  11
		DB	-1

		DW	OFFSET	embns1_1

		EVEN

embns1_1	DW	35


embns1_0	LABEL	BYTE
		DB	008h,COL_RAIL1,06,10,08,04,-1		; face 0
		DB	002h,4,COL_RAIL2,14,16,-1		; line 3
		DB	002h,4,COL_RAIL2,12,18,-1		; line 4
		DB	008h,COL_HILL2,00,20,04,08,-1		; face 3
		DB	008h,COL_HILL2,10,06,22,02,-1		; face 4
		DB	-1

		EVEN

embns2		OBJECTHEADER <OBJ_SCALE2,8192,embns3,0,COL_BLACK1,6,16,4>
		DB	052,032,064	;   0
		DB	076,032,064	;   1
		DB	060,096,072	;   2
		DB	068,096,072	;   3
		DB	060,032,072	;   4
		DB	068,032,072	;   5
		DB	064,096,072	;   6
		DB	064,032,072	;   7
		DB	052,096,064	;   8
		DB	076,096,064	;   9
		DB	-1

		DW	OFFSET	embns2_1

		EVEN

embns2_1	DW	29


embns2_0	LABEL	BYTE
		DB	008h,COL_RAIL1,06,10,08,04,-1		; face 0
		DB	002h,4,COL_RAIL2,12,14,-1		; line 4
		DB	008h,COL_HILL2,00,16,04,08,-1		; face 3
		DB	008h,COL_HILL2,10,06,18,02,-1		; face 4
		DB	-1

		EVEN

embns3		OBJECTHEADER <OBJ_SCALE1,16384,-1,1,COL_BLACK1,3,8,2>
		DB	058,048,064	;   0
		DB	070,048,064	;   1
		DB	062,080,068	;   2
		DB	066,080,068	;   3
		DB	062,048,068	;   4
		DB	066,048,068	;   5
		DB	064,080,068	;   6
		DB	064,048,068	;   7
		DB	058,080,064	;   8
		DB	070,080,064	;   9
		DB	-1

		DW	OFFSET	embns3_1

		EVEN

embns3_1	DW	29


embns3_0	LABEL	BYTE
		DB	008h,COL_RAIL1,06,10,08,04,-1		; face 0
		DB	002h,4,COL_RAIL2,12,14,-1		; line 4
		DB	008h,COL_HILL2,00,16,04,08,-1		; face 3
		DB	008h,COL_HILL2,10,06,18,02,-1		; face 4
		DB	-1

		EVEN

