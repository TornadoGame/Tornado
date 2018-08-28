stnrlnb1	OBJECTHEADER <OBJ_SCALE2,8192,-1,1,COL_RAIL2,8,32,0>
		DB	072,000	;   0
		DB	074,000	;   2
		DB	076,000	;   4
		DB	078,000	;   6
		DB	068,000	;   8
		DB	070,000	;  10
		DB	066,032	;  12
		DB	078,088	;  14
		DB	076,088	;  16
		DB	074,104	;  18
		DB	072,104	;  20
		DB	064,016	;  22
		DB	066,016	;  24
		DB	064,032	;  26
		DB	080,000	;  28
		DB	080,106	;  30
		DB	070,106	;  32
		DB	-1

		DW	OFFSET	stnrlnb1_1

		EVEN

stnrlnb1_1	DW	57


stnrlnb1_0	LABEL	BYTE
		DB	008h,COL_RAIL1,10,32,30,28,-1		; face 9
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

