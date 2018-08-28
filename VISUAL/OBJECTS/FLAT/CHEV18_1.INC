chev18_1	OBJECTHEADER <OBJ_SCALE4,2000,chev18_2,0,COL_BLACK1,30,8,0>
		DB	080,080	;   0
		DB	048,080	;   2
		DB	100,080	;   4
		DB	064,072	;   6
		DB	064,062	;   8
		DB	028,080	;  10
		DB	112,080	;  12
		DB	016,080	;  14
		DB	064,056	;  16
		DB	068,048	;  18
		DB	124,076	;  20
		DB	080,048	;  22
		DB	124,070	;  24
		DB	124,060	;  26
		DB	124,054	;  28
		DB	100,048	;  30
		DB	112,048	;  32
		DB	060,048	;  34
		DB	048,048	;  36
		DB	004,070	;  38
		DB	004,076	;  40
		DB	028,048	;  42
		DB	016,048	;  44
		DB	004,060	;  46
		DB	004,054	;  48
		DB	-1

		DW	OFFSET	chev18_1_1

		EVEN

chev18_1_1	DW	50


chev18_1_0	LABEL	BYTE
		DB	008h,COL_AMBER1,06,02,00,-1		; face 0
		DB	008h,COL_AMBER1,10,08,16,14,-1		; face 1
		DB	008h,COL_AMBER1,12,16,08,04,-1		; face 2
		DB	008h,COL_AMBER1,18,20,24,22,-1		; face 3
		DB	008h,COL_AMBER1,30,26,28,32,-1		; face 4
		DB	008h,COL_AMBER1,36,38,40,34,-1		; face 5
		DB	008h,COL_AMBER1,48,46,42,44,-1		; face 6
		DB	-1

		EVEN

chev18_2	OBJECTHEADER <OBJ_SCALE4,4096,chev18_3,0,COL_BLACK1,30,8,0>
		DB	076,080	;   0
		DB	052,080	;   2
		DB	104,080	;   4
		DB	064,074	;   6
		DB	064,060	;   8
		DB	024,080	;  10
		DB	072,048	;  12
		DB	124,074	;  14
		DB	124,058	;  16
		DB	104,048	;  18
		DB	056,048	;  20
		DB	004,074	;  22
		DB	024,048	;  24
		DB	004,058	;  26
		DB	-1

		DW	OFFSET	chev18_2_1

		EVEN

chev18_2_1	DW	35


chev18_2_0	LABEL	BYTE
		DB	00Ah,COL_AMBER1,04,08,10,-1		; line 5
		DB	00Ah,COL_AMBER1,14,12,-1		; line 5
		DB	00Ah,COL_AMBER1,16,18,-1		; line 5
		DB	00Ah,COL_AMBER1,22,20,-1		; line 4
		DB	00Ah,COL_AMBER1,26,24,-1		; line 5
		DB	00Ah,COL_AMBER1,00,06,02,00,-1		; line 5
		DB	-1

		EVEN

chev18_3	OBJECTHEADER <OBJ_SCALE2,8192,-1,1,COL_AMBER1,15,4,0>
		DB	034,056	;   0
		DB	034,072	;   2
		DB	094,072	;   4
		DB	094,056	;   6
		DB	-1

		DW	OFFSET	chev18_3_1

		EVEN

chev18_3_1	DW	9


chev18_3_0	LABEL	BYTE
		DB	009h,COL_AMBER1,02,04,06,00,-1		; face 0
		DB	-1

		EVEN

