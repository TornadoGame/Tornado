stnrlsa1	OBJECTHEADER <OBJ_SCALE2,8192,-1,1,COL_RAIL2,21,32,0>
		DB	066,128	;   0
		DB	070,128	;   2
		DB	070,096	;   4
		DB	066,096	;   6
		DB	080,128	;   8
		DB	080,096	;  10
		DB	086,128	;  12
		DB	086,096	;  14
		DB	072,000	;  16
		DB	072,128	;  18
		DB	074,000	;  20
		DB	074,128	;  22
		DB	076,128	;  24
		DB	076,000	;  26
		DB	078,128	;  28
		DB	078,000	;  30
		DB	096,128	;  32
		DB	096,096	;  34
		DB	106,128	;  36
		DB	106,106	;  38
		DB	088,080	;  40
		DB	088,128	;  42
		DB	090,080	;  44
		DB	090,128	;  46
		DB	092,080	;  48
		DB	092,128	;  50
		DB	094,080	;  52
		DB	094,128	;  54
		DB	062,128	;  56
		DB	062,096	;  58
		DB	058,100	;  60
		DB	058,128	;  62
		DB	070,000	;  64
		DB	068,000	;  66
		DB	096,072	;  68
		DB	080,000	;  70
		DB	-1

		DW	OFFSET	stnrlsa1_1

		EVEN

stnrlsa1_1	DW	104


stnrlsa1_0	LABEL	BYTE
		DB	008h,COL_RAIL1,64,02,32,68,70,-1	; face 15
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

