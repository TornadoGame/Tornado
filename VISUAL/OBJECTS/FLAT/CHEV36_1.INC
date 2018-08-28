chev36_1	OBJECTHEADER <OBJ_SCALE4,2000,chev36_2,0,COL_BLACK1,30,8,0>
		DB	048,048	;   0
		DB	080,048	;   2
		DB	028,048	;   4
		DB	064,056	;   6
		DB	064,066	;   8
		DB	100,048	;  10
		DB	016,048	;  12
		DB	112,048	;  14
		DB	064,072	;  16
		DB	060,080	;  18
		DB	004,052	;  20
		DB	048,080	;  22
		DB	004,058	;  24
		DB	004,068	;  26
		DB	004,074	;  28
		DB	028,080	;  30
		DB	016,080	;  32
		DB	068,080	;  34
		DB	080,080	;  36
		DB	124,058	;  38
		DB	124,052	;  40
		DB	100,080	;  42
		DB	112,080	;  44
		DB	124,068	;  46
		DB	124,074	;  48
		DB	-1

		DW	OFFSET	chev36_1_1

		EVEN

chev36_1_1	DW	50


chev36_1_0	LABEL	BYTE
		DB	008h,COL_AMBER1,06,02,00,-1		; face 0
		DB	008h,COL_AMBER1,10,08,16,14,-1		; face 1
		DB	008h,COL_AMBER1,12,16,08,04,-1		; face 2
		DB	008h,COL_AMBER1,18,20,24,22,-1		; face 3
		DB	008h,COL_AMBER1,30,26,28,32,-1		; face 4
		DB	008h,COL_AMBER1,36,38,40,34,-1		; face 5
		DB	008h,COL_AMBER1,48,46,42,44,-1		; face 6
		DB	-1

		EVEN

chev36_2	OBJECTHEADER <OBJ_SCALE4,4096,chev36_3,0,COL_BLACK1,30,8,0>
		DB	052,048	;   0
		DB	076,048	;   2
		DB	024,048	;   4
		DB	064,054	;   6
		DB	064,068	;   8
		DB	104,048	;  10
		DB	056,080	;  12
		DB	004,054	;  14
		DB	004,070	;  16
		DB	024,080	;  18
		DB	072,080	;  20
		DB	124,054	;  22
		DB	104,080	;  24
		DB	124,070	;  26
		DB	-1

		DW	OFFSET	chev36_2_1

		EVEN

chev36_2_1	DW	35


chev36_2_0	LABEL	BYTE
		DB	00Ah,COL_AMBER1,04,08,10,-1		; line 5
		DB	00Ah,COL_AMBER1,14,12,-1		; line 5
		DB	00Ah,COL_AMBER1,16,18,-1		; line 5
		DB	00Ah,COL_AMBER1,22,20,-1		; line 4
		DB	00Ah,COL_AMBER1,26,24,-1		; line 5
		DB	00Ah,COL_AMBER1,00,06,02,00,-1		; line 5
		DB	-1

		EVEN

chev36_3	OBJECTHEADER <OBJ_SCALE2,8192,-1,1,COL_AMBER1,15,4,0>
		DB	034,056	;   0
		DB	034,072	;   2
		DB	094,072	;   4
		DB	094,056	;   6
		DB	-1

		DW	OFFSET	chev36_3_1

		EVEN

chev36_3_1	DW	9


chev36_3_0	LABEL	BYTE
		DB	009h,COL_AMBER1,02,04,06,00,-1		; face 0
		DB	-1

		EVEN

