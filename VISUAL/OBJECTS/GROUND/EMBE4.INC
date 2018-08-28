embe4		OBJECTHEADER <OBJ_SCALE4,1000,embe4_2,0,COL_BLACK1,32,12,8>
		DB	128,044,064	;   0
		DB	128,084,064	;   1
		DB	000,056,080	;   2
		DB	000,072,080	;   3
		DB	128,056,076	;   4
		DB	128,072,076	;   5
		DB	000,062,080	;   6
		DB	000,066,080	;   7
		DB	128,066,076	;   8
		DB	128,062,076	;   9
		DB	016,040,064	;  10
		DB	016,088,064	;  11
		DB	000,056,064	;  12
		DB	000,072,064	;  13
		DB	-1

		DW	OFFSET	embe4_1

		EVEN

embe4_1		DW	54


embe4_0		LABEL	BYTE
		DB	008h,COL_RAIL1,06,10,08,04,-1		; face 0
		DB	002h,4,COL_RAIL2,14,16,-1		; line 3
		DB	002h,4,COL_RAIL2,12,18,-1		; line 4
		DB	008h,COL_HILL2,00,20,04,08,-1		; face 3
		DB	008h,COL_HILL2,10,06,22,02,-1		; face 4
		DB	008h,COL_GREY3,04,24,26,06,-1		; face 5
		DB	008h,COL_GREY2,20,24,04,-1		; face 6
		DB	008h,COL_GREY2,06,26,22,-1		; face 7
		DB	-1

		EVEN

embe4_2		OBJECTHEADER <OBJ_SCALE2,8192,embe4_3,0,COL_BLACK1,16,6,4>
		DB	096,054,064	;   0
		DB	096,074,064	;   1
		DB	032,060,072	;   2
		DB	032,068,072	;   3
		DB	096,060,070	;   4
		DB	096,068,070	;   5
		DB	032,064,072	;   6
		DB	096,064,070	;   7
		DB	040,052,064	;   8
		DB	040,076,064	;   9
		DB	032,060,064	;  10
		DB	032,068,064	;  11
		DB	-1

		DW	OFFSET	embe4_2_1

		EVEN

embe4_2_1	DW	48


embe4_2_0	LABEL	BYTE
		DB	008h,COL_RAIL1,06,10,08,04,-1		; face 0
		DB	002h,4,COL_RAIL2,12,14,-1		; line 3
		DB	008h,COL_HILL2,00,16,04,08,-1		; face 3
		DB	008h,COL_HILL2,10,06,18,02,-1		; face 4
		DB	008h,COL_GREY3,04,20,22,06,-1		; face 5
		DB	008h,COL_GREY2,16,20,04,-1		; face 6
		DB	008h,COL_GREY2,06,22,18,-1		; face 7
		DB	-1

		EVEN

embe4_3		OBJECTHEADER <OBJ_SCALE1,16384,-1,1,COL_BLACK1,8,3,2>
		DB	080,058,064	;   0
		DB	080,070,064	;   1
		DB	048,062,068	;   2
		DB	048,066,068	;   3
		DB	080,062,068	;   4
		DB	080,066,068	;   5
		DB	048,064,068	;   6
		DB	080,064,068	;   7
		DB	054,058,064	;   8
		DB	054,070,064	;   9
		DB	048,062,064	;  10
		DB	048,066,064	;  11
		DB	-1

		DW	OFFSET	embe4_3_1

		EVEN

embe4_3_1	DW	48


embe4_3_0	LABEL	BYTE
		DB	008h,COL_RAIL1,06,10,08,04,-1		; face 0
		DB	002h,4,COL_RAIL2,12,14,-1		; line 3
		DB	008h,COL_HILL2,00,16,04,08,-1		; face 3
		DB	008h,COL_HILL2,10,06,18,02,-1		; face 4
		DB	008h,COL_GREY3,04,20,22,06,-1		; face 5
		DB	008h,COL_GREY2,16,20,04,-1		; face 6
		DB	008h,COL_GREY2,06,22,18,-1		; face 7
		DB	-1

		EVEN

