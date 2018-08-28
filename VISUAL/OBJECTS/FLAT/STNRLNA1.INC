stnrlna1	OBJECTHEADER <OBJ_SCALE2,8192,-1,1,COL_RAIL2,21,32,0>
		DB	066,032	;   0
		DB	070,032	;   2
		DB	070,000	;   4
		DB	066,000	;   6
		DB	080,032	;   8
		DB	080,000	;  10
		DB	086,032	;  12
		DB	086,000	;  14
		DB	072,128	;  16
		DB	072,000	;  18
		DB	074,128	;  20
		DB	074,000	;  22
		DB	076,128	;  24
		DB	076,000	;  26
		DB	078,128	;  28
		DB	078,000	;  30
		DB	096,032	;  32
		DB	096,000	;  34
		DB	106,022	;  36
		DB	106,000	;  38
		DB	088,048	;  40
		DB	088,000	;  42
		DB	090,048	;  44
		DB	090,000	;  46
		DB	092,048	;  48
		DB	092,000	;  50
		DB	094,048	;  52
		DB	094,000	;  54
		DB	062,032	;  56
		DB	062,000	;  58
		DB	058,000	;  60
		DB	058,028	;  62
		DB	070,128	;  64
		DB	068,128	;  66
		DB	096,056	;  68
		DB	080,128	;  70
		DB	-1

		DW	OFFSET	stnrlna1_1

		EVEN

stnrlna1_1	DW	104


stnrlna1_0	LABEL	BYTE
		DB	008h,COL_RAIL1,04,64,70,68,34,-1	; face 15
		DB	000h,6,COL_GREY2,00,02,04,06,-1		; face 0
		DB	000h,6,COL_GREY2,08,12,14,10,-1		; face 1
		DB	002h,4,COL_RAIL2,16,18,-1		; line 3
		DB	002h,4,COL_RAIL2,20,22,-1		; line 4
		DB	002h,4,COL_RAIL2,24,26,-1		; line 5
		DB	002h,4,COL_RAIL2,28,30,-1		; line 6
		DB	000h,6,COL_GREY2,32,36,38,34,-1		; face 14
		DB	002h,4,COL_RAIL2,40,42,-1		; line 15
		DB	002h,4,COL_RAIL2,44,46,-1		; line 16
		DB	002h,5,COL_RAIL2,54,52,20,-1		; line 17
		DB	002h,5,COL_RAIL2,50,48,16,-1		; line 18
		DB	000h,6,COL_GREY2,56,58,60,62,-1		; face 11
		DB	002h,4,COL_RAIL2,44,64,-1		; line 12
		DB	002h,4,COL_RAIL2,40,66,-1		; line 13
		DB	-1

		EVEN

