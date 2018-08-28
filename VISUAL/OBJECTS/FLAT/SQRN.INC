sqrn		OBJECTHEADER <OBJ_SCALE1,16384,-1,1,COL_RWY1,18,32,0>
		DB	028,100	;   0
		DB	100,100	;   2
		DB	100,000	;   4
		DB	028,000	;   6
		DB	-1

		DW	OFFSET	sqrn_1

		EVEN

sqrn_1		DW	9


sqrn_0		LABEL	BYTE
		DB	008h,COL_RWY1,02,04,06,00,-1		; face 24
		DB	-1

		EVEN

