rwystns_1	OBJECTHEADER <OBJ_SCALE8,1000,rwystns2,0,COL_BLACK1,1,32,0>
		DB	062,000	;   0
		DB	064,000	;   2
		DB	064,128	;   4
		DB	062,128	;   6
		DB	-1

		DW	OFFSET	rwystns_1_1

		EVEN

rwystns_1_1	DW	10


rwystns_1_0	LABEL	BYTE
		DB	000h,6,COL_WHITE1,02,00,06,04,-1	; face 17
		DB	-1

		EVEN

rwystns2	OBJECTHEADER <OBJ_SCALE1,4096,rwystns3,0,COL_BLACK1,0,4,0>
		DB	064,056	;   0
		DB	064,072	;   2
		DB	-1

		DW	OFFSET	rwystns2_1

		EVEN

rwystns2_1	DW	8


rwystns2_0	LABEL	BYTE
		DB	002h,4,COL_WHITE1,00,02,-1		; line 0
		DB	-1

		EVEN

rwystns3	OBJECTHEADER <OBJ_SCALE1,16384,-1,1,COL_BLACK1,0,4,0>
		DB	064,056	;   0
		DB	064,072	;   2
		DB	-1

		DW	OFFSET	rwystns3_1

		EVEN

rwystns3_1	DW	8


rwystns3_0	LABEL	BYTE
		DB	002h,4,COL_GREY1,00,02,-1		; line 0
		DB	-1

		EVEN

