embew1		OBJECTHEADER <OBJ_SCALE4,1000,embew2,0,COL_BLACK1,32,12,8>
		DB	000,088,064	;   0
		DB	000,040,064	;   1
		DB	128,072,080	;   2
		DB	128,056,080	;   3
		DB	000,072,080	;   4
		DB	000,056,080	;   5
		DB	128,066,080	;   6
		DB	128,062,080	;   7
		DB	000,062,080	;   8
		DB	000,066,080	;   9
		DB	128,088,064	;  10
		DB	128,040,064	;  11
		DB	-1

		DW	OFFSET	embew1_1

		EVEN

embew1_1	DW	35


embew1_0	LABEL	BYTE
		DB	008h,COL_RAIL1,06,10,08,04,-1		; face 0
		DB	002h,4,COL_RAIL2,14,16,-1		; line 3
		DB	002h,4,COL_RAIL2,12,18,-1		; line 4
		DB	008h,COL_HILL2,00,20,04,08,-1		; face 3
		DB	008h,COL_HILL2,10,06,22,02,-1		; face 4
		DB	-1

		EVEN

embew2		OBJECTHEADER <OBJ_SCALE2,8192,embew3,0,COL_BLACK1,16,6,4>
		DB	032,076,064	;   0
		DB	032,052,064	;   1
		DB	096,068,072	;   2
		DB	096,060,072	;   3
		DB	032,068,072	;   4
		DB	032,060,072	;   5
		DB	096,064,072	;   6
		DB	032,064,072	;   7
		DB	096,076,064	;   8
		DB	096,052,064	;   9
		DB	-1

		DW	OFFSET	embew2_1

		EVEN

embew2_1	DW	29


embew2_0	LABEL	BYTE
		DB	008h,COL_RAIL1,06,10,08,04,-1		; face 0
		DB	002h,4,COL_RAIL2,12,14,-1		; line 4
		DB	008h,COL_HILL2,00,16,04,08,-1		; face 3
		DB	008h,COL_HILL2,10,06,18,02,-1		; face 4
		DB	-1

		EVEN

embew3		OBJECTHEADER <OBJ_SCALE1,16384,-1,1,COL_BLACK1,8,3,2>
		DB	048,070,064	;   0
		DB	048,058,064	;   1
		DB	080,066,068	;   2
		DB	080,062,068	;   3
		DB	048,066,068	;   4
		DB	048,062,068	;   5
		DB	080,064,068	;   6
		DB	048,064,068	;   7
		DB	080,070,064	;   8
		DB	080,058,064	;   9
		DB	-1

		DW	OFFSET	embew3_1

		EVEN

embew3_1	DW	29


embew3_0	LABEL	BYTE
		DB	008h,COL_RAIL1,06,10,08,04,-1		; face 0
		DB	002h,4,COL_RAIL2,12,14,-1		; line 4
		DB	008h,COL_HILL2,00,16,04,08,-1		; face 3
		DB	008h,COL_HILL2,10,06,18,02,-1		; face 4
		DB	-1

		EVEN

