flyots1		OBJECTHEADER <OBJ_SCALE1,16384,-1,1,COL_BLACK1,2,16,1>
		DB	060,096,066	;   0
		DB	068,096,066	;   1
		DB	060,048,064	;   2
		DB	068,048,064	;   3
		DB	062,096,064	;   4
		DB	066,096,064	;   5
		DB	068,096,064	;   6
		DB	060,096,064	;   7
		DB	068,064,064	;   8
		DB	060,064,064	;   9
		DB	-1

		DW	OFFSET	flyots1_1

		EVEN

flyots1_1	DW	57


flyots1_0	LABEL	BYTE
		DB	009h,COL_GREY4,18,14,08,-1		; face 13
		DB	009h,COL_GREY4,10,12,16,-1		; face 14
		DB	008h,COL_GREY2,18,08,00,-1		; face 13
		DB	008h,COL_GREY2,16,02,10,-1		; face 14
		DB	008h,COL_ROAD1,02,06,04,00,-1		; face 0
		DB	002h,4,COL_GREY1,02,06,-1		; line 8
		DB	002h,4,COL_GREY1,00,04,-1		; line 9
		DB	008h,COL_GREY1,00,04,18,-1		; face 12
		DB	008h,COL_GREY1,06,02,16,-1		; face 13
		DB	-1

		EVEN

