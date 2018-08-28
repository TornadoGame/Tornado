disnsew1	OBJECTHEADER <OBJ_SCALE4,2000,disnsew2,0,COL_BLACK1,6,6,0>
		DB	054,076	;   0
		DB	052,074	;   2
		DB	074,076	;   4
		DB	076,074	;   6
		DB	076,054	;   8
		DB	074,052	;  10
		DB	054,052	;  12
		DB	052,054	;  14
		DB	-1

		DW	OFFSET	disnsew1_1

		EVEN

disnsew1_1	DW	16


disnsew1_0	LABEL	BYTE
		DB	008h,COL_WHITE1,00,08,10,02,-1		; face 0
		DB	008h,COL_WHITE1,14,04,06,12,-1		; face 1
		DB	-1

		EVEN

disnsew2	OBJECTHEADER <OBJ_SCALE1,12000,-1,1,COL_GREY1,2,2,0>
		DB	060,068	;   0
		DB	068,068	;   2
		DB	068,060	;   4
		DB	060,060	;   6
		DB	-1

		DW	OFFSET	disnsew2_1

		EVEN

disnsew2_1	DW	12


disnsew2_0	LABEL	BYTE
		DB	00Ah,COL_GREY1,00,04,-1			; line 3
		DB	00Ah,COL_GREY1,06,02,-1			; line 4
		DB	-1

		EVEN

