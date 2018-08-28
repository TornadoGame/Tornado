firepool	OBJECTHEADER <OBJ_SCALE16,512,firepool2,0,COL_BLACK1,17,17,0>
		DB	096,096	;   0
		DB	096,032	;   2
		DB	032,032	;   4
		DB	032,096	;   6
		DB	098,098	;   8
		DB	098,030	;  10
		DB	030,030	;  12
		DB	030,098	;  14
		DB	-1

		DW	OFFSET	firepool_1

		EVEN

firepool_1	DW	50


firepool_0	LABEL	BYTE
		DB	008h,COL_RIVER1,06,00,02,04,-1		; face 1
		DB	000h,6,COL_NEW_GREY2,06,14,08,00,-1	; face 2
		DB	000h,6,COL_NEW_GREY2,00,08,10,02,-1	; face 3
		DB	000h,6,COL_NEW_GREY2,02,10,12,04,-1	; face 4
		DB	000h,6,COL_NEW_GREY2,04,12,14,06,-1	; face 5
		DB	002h,7,COL_GREY3,06,00,02,04,06,-1	; line 6
		DB	-1

		EVEN

firepool2	OBJECTHEADER <OBJ_SCALE1,16384,-1,1,COL_RWY1,1,1,0>
		DB	066,066	;   0
		DB	062,066	;   2
		DB	062,062	;   4
		DB	066,062	;   6
		DB	-1

		DW	OFFSET	firepool2_1

		EVEN

firepool2_1	DW	18


firepool2_0	LABEL	BYTE
		DB	008h,COL_RIVER1,02,00,06,04,-1		; face 1
		DB	002h,7,COL_NEW_GREY2,02,00,06,04,02,-1	; line 2
		DB	-1

		EVEN

