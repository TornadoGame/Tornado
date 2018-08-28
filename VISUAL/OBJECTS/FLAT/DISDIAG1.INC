disdiag1	OBJECTHEADER <OBJ_SCALE4,2000,disdiag2,0,COL_BLACK1,8,8,0>
		DB	066,080	;   0
		DB	062,080	;   2
		DB	080,066	;   4
		DB	080,062	;   6
		DB	066,048	;   8
		DB	062,048	;  10
		DB	048,062	;  12
		DB	048,066	;  14
		DB	-1

		DW	OFFSET	disdiag1_1

		EVEN

disdiag1_1	DW	16


disdiag1_0	LABEL	BYTE
		DB	008h,COL_WHITE1,00,08,10,02,-1		; face 0
		DB	008h,COL_WHITE1,14,04,06,12,-1		; face 1
		DB	-1

		EVEN

disdiag2	OBJECTHEADER <OBJ_SCALE1,12000,-1,1,COL_GREY1,2,2,0>
		DB	064,068	;   0
		DB	064,060	;   2
		DB	060,064	;   4
		DB	068,064	;   6
		DB	-1

		DW	OFFSET	disdiag2_1

		EVEN

disdiag2_1	DW	12


disdiag2_0	LABEL	BYTE
		DB	00Ah,COL_GREY1,00,02,-1			; line 3
		DB	00Ah,COL_GREY1,04,06,-1			; line 4
		DB	-1

		EVEN

