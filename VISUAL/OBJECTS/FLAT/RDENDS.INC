rdends		OBJECTHEADER <OBJ_SCALE2,8192,rdends_2,0,COL_BLACK1,1,32,0>
		DB	066,062	;   0
		DB	062,062	;   2
		DB	062,128	;   4
		DB	066,128	;   6
		DB	-1

		DW	OFFSET	rdends_1

		EVEN

rdends_1	DW	9


rdends_0	LABEL	BYTE
		DB	008h,COL_RWY1,02,04,06,00,-1		; face 24
		DB	-1

		EVEN

rdends_2	OBJECTHEADER <OBJ_SCALE1,16384,-1,1,COL_RWY1,0,16,0>
		DB	064,064	;   0
		DB	064,096	;   2
		DB	-1

		DW	OFFSET	rdends_2_1

		EVEN

rdends_2_1	DW	7


rdends_2_0	LABEL	BYTE
		DB	00Ah,COL_RWY1,00,02,-1			; face 24
		DB	-1

		EVEN

