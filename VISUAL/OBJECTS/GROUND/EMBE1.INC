embe1		OBJECTHEADER <OBJ_SCALE4,1000,embe1_2,0,COL_BLACK1,32,8,2>
		DB	000,080,064	;   0
		DB	000,048,064	;   1
		DB	128,080,064	;   2
		DB	128,048,064	;   3
		DB	000,076,068	;   4
		DB	000,052,068	;   5
		DB	128,066,064	;   6
		DB	128,062,064	;   7
		DB	000,062,068	;   8
		DB	000,066,068	;   9
		DB	-1

		DW	OFFSET	embe1_1

		EVEN

embe1_1		DW	33


embe1_0		LABEL	BYTE
		DB	008h,COL_RAIL1,06,10,08,04,-1		; face 0
		DB	002h,4,COL_RAIL2,14,16,-1		; line 3
		DB	002h,4,COL_RAIL2,12,18,-1		; line 4
		DB	008h,COL_HILL2,06,02,10,-1		; face 1
		DB	008h,COL_HILL2,04,08,00,-1		; face 2
		DB	-1

		EVEN

embe1_2		OBJECTHEADER <OBJ_SCALE2,8192,embe1_3,0,COL_BLACK1,16,4,1>
		DB	032,072,064	;   0
		DB	032,056,064	;   1
		DB	096,072,064	;   2
		DB	096,056,064	;   3
		DB	032,070,066	;   4
		DB	032,058,066	;   5
		DB	096,064,064	;   6
		DB	032,064,066	;   7
		DB	-1

		DW	OFFSET	embe1_2_1

		EVEN

embe1_2_1	DW	27


embe1_2_0	LABEL	BYTE
		DB	008h,COL_RAIL1,06,10,08,04,-1		; face 0
		DB	002h,4,COL_RAIL2,12,14,-1		; line 4
		DB	008h,COL_HILL2,06,02,10,-1		; face 1
		DB	008h,COL_HILL2,04,08,00,-1		; face 2
		DB	-1

		EVEN

embe1_3		OBJECTHEADER <OBJ_SCALE1,16384,-1,1,COL_BLACK1,8,2,0>
		DB	048,068,064	;   0
		DB	048,060,064	;   1
		DB	080,068,064	;   2
		DB	080,060,064	;   3
		DB	048,066,064	;   4
		DB	048,062,064	;   5
		DB	-1

		DW	OFFSET	embe1_3_1

		EVEN

embe1_3_1	DW	14


embe1_3_0	LABEL	BYTE
		DB	008h,COL_HILL2,06,02,10,-1		; face 1
		DB	008h,COL_HILL2,04,08,00,-1		; face 2
		DB	-1

		EVEN

