chev09_1	OBJECTHEADER <OBJ_SCALE4,2000,chev09_2,0,COL_BLACK1,8,30,0>
		DB	048,080	;   0
		DB	048,048	;   2
		DB	048,100	;   4
		DB	056,064	;   6
		DB	066,064	;   8
		DB	048,028	;  10
		DB	048,112	;  12
		DB	048,016	;  14
		DB	072,064	;  16
		DB	080,068	;  18
		DB	052,124	;  20
		DB	080,080	;  22
		DB	058,124	;  24
		DB	068,124	;  26
		DB	074,124	;  28
		DB	080,100	;  30
		DB	080,112	;  32
		DB	080,060	;  34
		DB	080,048	;  36
		DB	056,004	;  38
		DB	050,004	;  40
		DB	080,028	;  42
		DB	080,016	;  44
		DB	066,004	;  46
		DB	072,004	;  48
		DB	-1

		DW	OFFSET	chev09_1_1

		EVEN

chev09_1_1	DW	50


chev09_1_0	LABEL	BYTE
		DB	008h,COL_AMBER1,06,02,00,-1		; face 0
		DB	008h,COL_AMBER1,10,08,16,14,-1		; face 1
		DB	008h,COL_AMBER1,12,16,08,04,-1		; face 2
		DB	008h,COL_AMBER1,18,20,24,22,-1		; face 3
		DB	008h,COL_AMBER1,30,26,28,32,-1		; face 4
		DB	008h,COL_AMBER1,36,38,40,34,-1		; face 5
		DB	008h,COL_AMBER1,48,46,42,44,-1		; face 6
		DB	-1

		EVEN

chev09_2	OBJECTHEADER <OBJ_SCALE4,4096,chev09_3,0,COL_BLACK1,8,30,0>
		DB	048,076	;   0
		DB	048,052	;   2
		DB	048,104	;   4
		DB	054,064	;   6
		DB	068,064	;   8
		DB	048,024	;  10
		DB	080,072	;  12
		DB	054,124	;  14
		DB	070,124	;  16
		DB	080,104	;  18
		DB	080,056	;  20
		DB	054,004	;  22
		DB	080,024	;  24
		DB	070,004	;  26
		DB	-1

		DW	OFFSET	chev09_2_1

		EVEN

chev09_2_1	DW	35


chev09_2_0	LABEL	BYTE
		DB	00Ah,COL_AMBER1,04,08,10,-1		; line 5
		DB	00Ah,COL_AMBER1,14,12,-1		; line 5
		DB	00Ah,COL_AMBER1,16,18,-1		; line 5
		DB	00Ah,COL_AMBER1,22,20,-1		; line 4
		DB	00Ah,COL_AMBER1,26,24,-1		; line 5
		DB	00Ah,COL_AMBER1,00,06,02,00,-1		; line 5
		DB	-1

		EVEN

chev09_3	OBJECTHEADER <OBJ_SCALE2,8192,-1,1,COL_AMBER1,4,15,0>
		DB	056,094	;   0
		DB	072,094	;   2
		DB	072,034	;   4
		DB	056,034	;   6
		DB	-1

		DW	OFFSET	chev09_3_1

		EVEN

chev09_3_1	DW	9


chev09_3_0	LABEL	BYTE
		DB	009h,COL_AMBER1,02,04,06,00,-1		; face 0
		DB	-1

		EVEN

