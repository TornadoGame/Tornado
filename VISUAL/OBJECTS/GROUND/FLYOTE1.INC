flyote1		OBJECTHEADER <OBJ_SCALE1,16384,-1,1,COL_BLACK1,16,2,1>
		DB	032,060,066	;   0
		DB	032,068,066	;   1
		DB	080,060,064	;   2
		DB	080,068,064	;   3
		DB	032,062,064	;   4
		DB	032,066,064	;   5
		DB	032,068,064	;   6
		DB	032,060,064	;   7
		DB	064,068,064	;   8
		DB	064,060,064	;   9
		DB	-1

		DW	OFFSET	flyote1_1

		EVEN

flyote1_1	DW	57


flyote1_0	LABEL	BYTE
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

