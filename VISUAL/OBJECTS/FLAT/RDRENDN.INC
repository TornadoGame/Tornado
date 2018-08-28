rdrendn		OBJECTHEADER <OBJ_SCALE2,8192,rdrendn_2,0,COL_BLACK1,1,32,0>
		DB	062,064	;   0
		DB	066,064	;   2
		DB	066,000	;   4
		DB	062,000	;   6
		DB	-1

		DW	OFFSET	rdrendn_1

		EVEN

rdrendn_1	DW	9


rdrendn_0	LABEL	BYTE
		DB	008h,COL_ROAD1,02,04,06,00,-1		; face 24
		DB	-1

		EVEN

rdrendn_2	OBJECTHEADER <OBJ_SCALE1,16384,-1,1,COL_RWY1,0,16,0>
		DB	064,064	;   0
		DB	064,032	;   2
		DB	-1

		DW	OFFSET	rdrendn_2_1

		EVEN

rdrendn_2_1	DW	7


rdrendn_2_0	LABEL	BYTE
		DB	00Ah,COL_ROAD1,00,02,-1			; face 24
		DB	-1

		EVEN

