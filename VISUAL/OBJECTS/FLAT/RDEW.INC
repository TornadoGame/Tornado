rdew		OBJECTHEADER <OBJ_SCALE2,8192,rdew_2,0,COL_BLACK1,32,1,0>
		DB	000,062	;   0
		DB	000,066	;   2
		DB	128,066	;   4
		DB	128,062	;   6
		DB	-1

		DW	OFFSET	rdew_1

		EVEN

rdew_1		DW	9


rdew_0		LABEL	BYTE
		DB	008h,COL_RWY1,02,04,06,00,-1		; face 24
		DB	-1

		EVEN

rdew_2		OBJECTHEADER <OBJ_SCALE1,16384,-1,1,COL_RWY1,16,0,0>
		DB	032,064	;   0
		DB	096,064	;   2
		DB	-1

		DW	OFFSET	rdew_2_1

		EVEN

rdew_2_1	DW	7


rdew_2_0	LABEL	BYTE
		DB	00Ah,COL_RWY1,00,02,-1			; face 24
		DB	-1

		EVEN

