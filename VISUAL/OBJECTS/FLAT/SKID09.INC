skid09		OBJECTHEADER <OBJ_SCALE16,1024,-1,1,COL_GREY1,32,8,0>
		DB	058,056	;   0
		DB	092,058	;   2
		DB	088,056	;   4
		DB	058,072	;   6
		DB	094,074	;   8
		DB	092,072	;  10
		DB	102,064	;  12
		DB	126,066	;  14
		DB	128,064	;  16
		DB	080,060	;  18
		DB	082,058	;  20
		DB	050,058	;  22
		DB	052,076	;  24
		DB	082,076	;  26
		DB	078,074	;  28
		DB	120,068	;  30
		DB	096,066	;  32
		DB	074,054	;  34
		DB	092,050	;  36
		DB	102,052	;  38
		DB	082,078	;  40
		DB	104,080	;  42
		DB	110,076	;  44
		DB	-1

		DW	OFFSET	skid09_1

		EVEN

skid09_1	DW	50


skid09_0	LABEL	BYTE
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

