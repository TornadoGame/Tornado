bomblet		OBJECTHEADER <OBJ_SCALE16,1024,-1,1,COL_GREY4,0,1,0>
		DB	064,064,064	;   0
		DB	064,062,064	;   1
		DB	-1

		DW	OFFSET	bomblet_1

		EVEN

bomblet_1	DW	7


bomblet_0	LABEL	BYTE
		DB	00Ah,COL_GREY4,00,02,-1			; line 1
		DB	-1

		EVEN

