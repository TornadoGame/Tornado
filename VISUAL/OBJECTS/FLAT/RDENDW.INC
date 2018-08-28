rdendw		OBJECTHEADER <OBJ_SCALE2,8192,rdendw_2,0,COL_BLACK1,32,1,0>
		DB	062,062	;   0
		DB	062,066	;   2
		DB	128,066	;   4
		DB	128,062	;   6
		DB	-1

		DW	OFFSET	rdendw_1

		EVEN

rdendw_1	DW	9


rdendw_0	LABEL	BYTE
		DB	008h,COL_RWY1,02,04,06,00,-1		; face 24
		DB	-1

		EVEN

rdendw_2	OBJECTHEADER <OBJ_SCALE1,16384,-1,1,COL_RWY1,16,0,0>
		DB	064,064	;   0
		DB	096,064	;   2
		DB	-1

		DW	OFFSET	rdendw_2_1

		EVEN

rdendw_2_1	DW	7


rdendw_2_0	LABEL	BYTE
		DB	00Ah,COL_RWY1,00,02,-1			; face 24
		DB	-1

		EVEN

