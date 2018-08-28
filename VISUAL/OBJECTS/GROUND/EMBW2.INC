embw2		OBJECTHEADER <OBJ_SCALE4,1000,embw2_2,0,COL_BLACK1,32,8,4>
		DB	000,080,064	;   0
		DB	000,048,064	;   1
		DB	128,072,072	;   2
		DB	128,056,072	;   3
		DB	000,076,068	;   4
		DB	000,052,068	;   5
		DB	128,066,072	;   6
		DB	128,062,072	;   7
		DB	000,062,068	;   8
		DB	000,066,068	;   9
		DB	128,080,064	;  10
		DB	128,048,064	;  11
		DB	-1

		DW	OFFSET	embw2_1

		EVEN

embw2_1		DW	35


embw2_0		LABEL	BYTE
		DB	008h,COL_RAIL1,06,10,08,04,-1		; face 0
		DB	002h,4,COL_RAIL2,14,16,-1		; line 3
		DB	002h,4,COL_RAIL2,12,18,-1		; line 4
		DB	008h,COL_HILL2,00,20,04,08,-1		; face 3
		DB	008h,COL_HILL2,10,06,22,02,-1		; face 4
		DB	-1

		EVEN

embw2_2		OBJECTHEADER <OBJ_SCALE2,8192,embw2_3,0,COL_BLACK1,16,4,2>
		DB	032,072,064	;   0
		DB	032,056,064	;   1
		DB	096,068,068	;   2
		DB	096,060,068	;   3
		DB	032,070,066	;   4
		DB	032,058,066	;   5
		DB	096,064,068	;   6
		DB	032,064,066	;   7
		DB	096,072,064	;   8
		DB	096,056,064	;   9
		DB	-1

		DW	OFFSET	embw2_2_1

		EVEN

embw2_2_1	DW	29


embw2_2_0	LABEL	BYTE
		DB	008h,COL_RAIL1,06,10,08,04,-1		; face 0
		DB	002h,4,COL_RAIL2,12,14,-1		; line 3
		DB	008h,COL_HILL2,00,16,04,08,-1		; face 3
		DB	008h,COL_HILL2,10,06,18,02,-1		; face 4
		DB	-1

		EVEN

embw2_3		OBJECTHEADER <OBJ_SCALE1,16384,-1,1,COL_BLACK1,8,2,1>
		DB	080,066,066	;   0
		DB	080,062,066	;   1
		DB	048,066,064	;   2
		DB	048,062,064	;   3
		DB	080,064,066	;   4
		DB	048,064,064	;   5
		DB	080,068,064	;   6
		DB	080,060,064	;   7
		DB	048,060,064	;   8
		DB	048,068,064	;   9
		DB	-1

		DW	OFFSET	embw2_3_1

		EVEN

embw2_3_1	DW	29


embw2_3_0	LABEL	BYTE
		DB	008h,COL_RAIL1,02,06,04,00,-1		; face 0
		DB	002h,4,COL_RAIL2,08,10,-1		; line 3
		DB	008h,COL_HILL2,06,02,14,16,-1		; face 2
		DB	008h,COL_HILL2,18,12,00,04,-1		; face 3
		DB	-1

		EVEN

