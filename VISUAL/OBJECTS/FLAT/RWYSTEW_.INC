rwystew_1	OBJECTHEADER <OBJ_SCALE8,1000,rwystew2,0,COL_BLACK1,32,1,0>
		DB	128,062	;   0
		DB	128,064	;   2
		DB	000,064	;   4
		DB	000,062	;   6
		DB	-1

		DW	OFFSET	rwystew_1_1

		EVEN

rwystew_1_1	DW	10


rwystew_1_0	LABEL	BYTE
		DB	000h,6,COL_WHITE1,02,00,06,04,-1	; face 17
		DB	-1

		EVEN

rwystew2	OBJECTHEADER <OBJ_SCALE1,4096,rwystew3,0,COL_BLACK1,4,0,0>
		DB	072,064	;   0
		DB	056,064	;   2
		DB	-1

		DW	OFFSET	rwystew2_1

		EVEN

rwystew2_1	DW	8


rwystew2_0	LABEL	BYTE
		DB	002h,4,COL_WHITE1,00,02,-1		; line 0
		DB	-1

		EVEN

rwystew3	OBJECTHEADER <OBJ_SCALE1,16384,-1,1,COL_BLACK1,4,0,0>
		DB	072,064	;   0
		DB	056,064	;   2
		DB	-1

		DW	OFFSET	rwystew3_1

		EVEN

rwystew3_1	DW	8


rwystew3_0	LABEL	BYTE
		DB	002h,4,COL_GREY1,00,02,-1		; line 0
		DB	-1

		EVEN

