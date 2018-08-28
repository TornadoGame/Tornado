chev27_1	OBJECTHEADER <OBJ_SCALE4,2000,chev27_2,0,COL_BLACK1,8,30,0>
		DB	080,080	;   0
		DB	080,048	;   2
		DB	080,112	;   4
		DB	072,064	;   6
		DB	056,064	;   8
		DB	080,016	;  10
		DB	080,100	;  12
		DB	080,028	;  14
		DB	062,064	;  16
		DB	048,080	;  18
		DB	070,124	;  20
		DB	048,068	;  22
		DB	076,124	;  24
		DB	048,112	;  26
		DB	054,124	;  28
		DB	048,100	;  30
		DB	060,124	;  32
		DB	048,048	;  34
		DB	048,060	;  36
		DB	076,004	;  38
		DB	070,004	;  40
		DB	048,016	;  42
		DB	048,028	;  44
		DB	054,004	;  46
		DB	060,004	;  48
		DB	-1

		DW	OFFSET	chev27_1_1

		EVEN

chev27_1_1	DW	50


chev27_1_0	LABEL	BYTE
		DB	008h,COL_AMBER1,10,08,16,14,-1		; face 1
		DB	008h,COL_AMBER1,12,16,08,04,-1		; face 2
		DB	008h,COL_AMBER1,18,20,24,22,-1		; face 3
		DB	008h,COL_AMBER1,30,26,28,32,-1		; face 4
		DB	008h,COL_AMBER1,36,38,40,34,-1		; face 5
		DB	008h,COL_AMBER1,48,46,42,44,-1		; face 6
		DB	008h,COL_AMBER1,06,00,02,-1		; face 6
		DB	-1

		EVEN

chev27_2	OBJECTHEADER <OBJ_SCALE4,4096,chev27_3,0,COL_BLACK1,8,30,0>
		DB	080,076	;   0
		DB	080,052	;   2
		DB	074,064	;   4
		DB	080,104	;   6
		DB	080,024	;   8
		DB	060,064	;  10
		DB	048,072	;  12
		DB	074,124	;  14
		DB	048,104	;  16
		DB	058,124	;  18
		DB	048,056	;  20
		DB	074,004	;  22
		DB	048,024	;  24
		DB	058,004	;  26
		DB	-1

		DW	OFFSET	chev27_2_1

		EVEN

chev27_2_1	DW	35


chev27_2_0	LABEL	BYTE
		DB	00Ah,COL_AMBER1,06,10,08,-1		; line 5
		DB	00Ah,COL_AMBER1,02,04,00,02,-1		; line 5
		DB	00Ah,COL_AMBER1,22,20,-1		; line 5
		DB	00Ah,COL_AMBER1,14,12,-1		; line 5
		DB	00Ah,COL_AMBER1,18,16,-1		; line 5
		DB	00Ah,COL_AMBER1,26,24,-1		; line 5
		DB	-1

		EVEN

chev27_3	OBJECTHEADER <OBJ_SCALE2,8192,-1,1,COL_AMBER1,4,15,0>
		DB	056,094	;   0
		DB	072,094	;   2
		DB	072,034	;   4
		DB	056,034	;   6
		DB	-1

		DW	OFFSET	chev27_3_1

		EVEN

chev27_3_1	DW	9


chev27_3_0	LABEL	BYTE
		DB	009h,COL_AMBER1,02,04,06,00,-1		; face 0
		DB	-1

		EVEN

