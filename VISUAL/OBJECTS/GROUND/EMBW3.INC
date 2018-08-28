embw3		OBJECTHEADER <OBJ_SCALE4,1000,embw3_2,0,COL_BLACK1,32,10,6>
		DB	128,044,064	;   0
		DB	128,084,064	;   1
		DB	000,056,072	;   2
		DB	000,072,072	;   3
		DB	128,056,076	;   4
		DB	128,072,076	;   5
		DB	000,062,072	;   6
		DB	000,066,072	;   7
		DB	128,066,076	;   8
		DB	128,062,076	;   9
		DB	000,048,064	;  10
		DB	000,080,064	;  11
		DB	-1

		DW	OFFSET	embw3_1

		EVEN

embw3_1		DW	35


embw3_0		LABEL	BYTE
		DB	008h,COL_RAIL1,06,10,08,04,-1		; face 0
		DB	002h,4,COL_RAIL2,14,16,-1		; line 3
		DB	002h,4,COL_RAIL2,12,18,-1		; line 4
		DB	008h,COL_HILL2,00,20,04,08,-1		; face 3
		DB	008h,COL_HILL2,10,06,22,02,-1		; face 4
		DB	-1

		EVEN

embw3_2		OBJECTHEADER <OBJ_SCALE2,8192,embw3_3,0,COL_BLACK1,16,5,3>
		DB	096,054,064	;   0
		DB	096,074,064	;   1
		DB	032,060,068	;   2
		DB	032,068,068	;   3
		DB	096,060,070	;   4
		DB	096,068,070	;   5
		DB	032,064,068	;   6
		DB	096,064,070	;   7
		DB	032,056,064	;   8
		DB	032,072,064	;   9
		DB	-1

		DW	OFFSET	embw3_2_1

		EVEN

embw3_2_1	DW	29


embw3_2_0	LABEL	BYTE
		DB	008h,COL_RAIL1,06,10,08,04,-1		; face 0
		DB	002h,4,COL_RAIL2,12,14,-1		; line 4
		DB	008h,COL_HILL2,00,16,04,08,-1		; face 3
		DB	008h,COL_HILL2,10,06,18,02,-1		; face 4
		DB	-1

		EVEN

embw3_3		OBJECTHEADER <OBJ_SCALE1,16384,-1,1,COL_BLACK1,8,3,2>
		DB	080,058,064	;   0
		DB	080,070,064	;   1
		DB	048,062,066	;   2
		DB	048,066,066	;   3
		DB	080,062,068	;   4
		DB	080,066,068	;   5
		DB	048,064,066	;   6
		DB	080,064,068	;   7
		DB	048,060,064	;   8
		DB	048,068,064	;   9
		DB	-1

		DW	OFFSET	embw3_3_1

		EVEN

embw3_3_1	DW	29


embw3_3_0	LABEL	BYTE
		DB	008h,COL_RAIL1,06,10,08,04,-1		; face 0
		DB	002h,4,COL_RAIL2,12,14,-1		; line 4
		DB	008h,COL_HILL2,00,16,04,08,-1		; face 3
		DB	008h,COL_HILL2,10,06,18,02,-1		; face 4
		DB	-1

		EVEN

