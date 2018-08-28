stnrails1	OBJECTHEADER <OBJ_SCALE2,8192,-1,1,COL_RAIL2,22,32,0>
		DB	080,128	;   0
		DB	086,128	;   2
		DB	086,000	;   4
		DB	080,000	;   6
		DB	096,128	;   8
		DB	096,000	;  10
		DB	108,128	;  12
		DB	108,000	;  14
		DB	088,128	;  16
		DB	088,000	;  18
		DB	090,128	;  20
		DB	090,000	;  22
		DB	092,128	;  24
		DB	092,000	;  26
		DB	094,128	;  28
		DB	094,000	;  30
		DB	070,128	;  32
		DB	070,000	;  34
		DB	066,128	;  36
		DB	066,000	;  38
		DB	072,128	;  40
		DB	074,128	;  42
		DB	076,128	;  44
		DB	078,128	;  46
		DB	072,000	;  48
		DB	074,000	;  50
		DB	076,000	;  52
		DB	078,000	;  54
		DB	062,128	;  56
		DB	062,000	;  58
		DB	056,000	;  60
		DB	056,128	;  62
		DB	-1

		DW	OFFSET	stnrails1_1

		EVEN

stnrails1_1	DW	85


stnrails1_0	LABEL	BYTE
		DB	008h,COL_RAIL1,32,08,10,34,-1		; face 13
		DB	002h,4,COL_RAIL2,16,18,-1		; line 3
		DB	002h,4,COL_RAIL2,20,22,-1		; line 4
		DB	002h,4,COL_RAIL2,24,26,-1		; line 5
		DB	002h,4,COL_RAIL2,28,30,-1		; line 6
		DB	002h,4,COL_RAIL2,40,48,-1		; line 9
		DB	002h,4,COL_RAIL2,42,50,-1		; line 10
		DB	002h,4,COL_RAIL2,44,52,-1		; line 11
		DB	002h,4,COL_RAIL2,46,54,-1		; line 12
		DB	008h,COL_GREY2,62,56,58,60,-1		; face 11
		DB	008h,COL_GREY2,36,32,34,38,-1		; face 9
		DB	008h,COL_GREY2,00,02,04,06,-1		; face 10
		DB	008h,COL_GREY2,12,14,10,08,-1		; face 11
		DB	-1

		EVEN

