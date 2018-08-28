rdende		OBJECTHEADER <OBJ_SCALE2,8192,rdende_2,0,COL_BLACK1,32,1,0>
		DB	066,066	;   0
		DB	066,062	;   2
		DB	000,062	;   4
		DB	000,066	;   6
		DB	-1

		DW	OFFSET	rdende_1

		EVEN

rdende_1	DW	9


rdende_0	LABEL	BYTE
		DB	008h,COL_RWY1,02,04,06,00,-1		; face 24
		DB	-1

		EVEN

rdende_2	OBJECTHEADER <OBJ_SCALE1,16384,-1,1,COL_RWY1,16,0,0>
		DB	064,064	;   0
		DB	032,064	;   2
		DB	-1

		DW	OFFSET	rdende_2_1

		EVEN

rdende_2_1	DW	7


rdende_2_0	LABEL	BYTE
		DB	00Ah,COL_RWY1,00,02,-1			; face 24
		DB	-1

		EVEN

