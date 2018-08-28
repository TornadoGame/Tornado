stnrlsb1	OBJECTHEADER <OBJ_SCALE2,8192,-1,1,COL_RAIL2,8,32,0>
		DB	072,128	;   0
		DB	074,128	;   2
		DB	076,128	;   4
		DB	078,128	;   6
		DB	068,128	;   8
		DB	070,128	;  10
		DB	066,096	;  12
		DB	078,040	;  14
		DB	076,040	;  16
		DB	074,024	;  18
		DB	072,024	;  20
		DB	064,112	;  22
		DB	066,112	;  24
		DB	064,096	;  26
		DB	070,020	;  28
		DB	080,128	;  30
		DB	080,020	;  32
		DB	-1

		DW	OFFSET	stnrlsb1_1

		EVEN

stnrlsb1_1	DW	57


stnrlsb1_0	LABEL	BYTE
		DB	008h,COL_RAIL1,28,10,30,32,-1		; face 9
		DB	002h,4,COL_RAIL2,00,20,-1		; line 2
		DB	002h,4,COL_RAIL2,02,18,-1		; line 3
		DB	002h,4,COL_RAIL2,04,16,-1		; line 4
		DB	002h,4,COL_RAIL2,06,14,-1		; line 5
		DB	002h,4,COL_RAIL2,08,22,-1		; line 6
		DB	002h,4,COL_RAIL2,10,24,-1		; line 7
		DB	002h,4,COL_RAIL2,00,26,-1		; line 8
		DB	002h,4,COL_RAIL2,02,12,-1		; line 9
		DB	-1

		EVEN

