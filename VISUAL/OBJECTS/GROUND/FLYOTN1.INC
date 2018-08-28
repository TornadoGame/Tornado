flyotn1		OBJECTHEADER <OBJ_SCALE1,16384,-1,1,COL_BLACK1,2,16,1>
		DB	068,032,066	;   0
		DB	060,032,066	;   1
		DB	068,080,064	;   2
		DB	060,080,064	;   3
		DB	066,032,064	;   4
		DB	062,032,064	;   5
		DB	060,032,064	;   6
		DB	068,032,064	;   7
		DB	060,064,064	;   8
		DB	068,064,064	;   9
		DB	-1

		DW	OFFSET	flyotn1_1

		EVEN

flyotn1_1	DW	57


flyotn1_0	LABEL	BYTE
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

