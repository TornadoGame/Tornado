rdrns		OBJECTHEADER <OBJ_SCALE2,8192,rdrns_2,0,COL_BLACK1,1,32,0>
		DB	066,000	;   0
		DB	062,000	;   2
		DB	062,128	;   4
		DB	066,128	;   6
		DB	-1

		DW	OFFSET	rdrns_1

		EVEN

rdrns_1		DW	9


rdrns_0		LABEL	BYTE
		DB	008h,COL_ROAD1,02,04,06,00,-1		; face 24
		DB	-1

		EVEN

rdrns_2		OBJECTHEADER <OBJ_SCALE1,16384,-1,1,COL_RWY1,0,16,0>
		DB	064,032	;   0
		DB	064,096	;   2
		DB	-1

		DW	OFFSET	rdrns_2_1

		EVEN

rdrns_2_1	DW	7


rdrns_2_0	LABEL	BYTE
		DB	00Ah,COL_ROAD1,00,02,-1			; face 24
		DB	-1

		EVEN

