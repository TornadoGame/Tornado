skid36		OBJECTHEADER <OBJ_SCALE16,1024,-1,1,COL_GREY1,8,32,0>
		DB	072,058	;   0
		DB	070,092	;   2
		DB	072,088	;   4
		DB	056,058	;   6
		DB	054,094	;   8
		DB	056,092	;  10
		DB	064,102	;  12
		DB	062,126	;  14
		DB	064,128	;  16
		DB	068,080	;  18
		DB	070,082	;  20
		DB	070,050	;  22
		DB	052,052	;  24
		DB	052,082	;  26
		DB	054,078	;  28
		DB	060,120	;  30
		DB	062,096	;  32
		DB	074,074	;  34
		DB	078,092	;  36
		DB	076,102	;  38
		DB	050,082	;  40
		DB	048,104	;  42
		DB	052,110	;  44
		DB	-1

		DW	OFFSET	skid36_1

		EVEN

skid36_1	DW	50


skid36_0	LABEL	BYTE
		DB	009h,COL_NEW_GREY4,00,02,04,-1		; face 1
		DB	009h,COL_NEW_GREY4,06,08,10,-1		; face 2
		DB	009h,COL_NEW_GREY4,12,14,16,-1		; face 3
		DB	009h,COL_NEW_GREY4,22,18,20,-1		; face 4
		DB	009h,COL_NEW_GREY4,24,26,28,-1		; face 5
		DB	009h,COL_NEW_GREY4,30,14,32,-1		; face 6
		DB	009h,COL_NEW_GREY4,34,38,36,-1		; face 7
		DB	009h,COL_NEW_GREY4,42,44,40,-1		; face 8
		DB	-1

		EVEN

