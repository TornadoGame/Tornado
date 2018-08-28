skyflash	OBJECTHEADER <OBJ_SCALE16,1024,skyflash2,0,COL_BLACK1,1,32,1>
		DB	064,088,064	;   0
		DB	064,066,064	;   1
		DB	062,064,064	;   2
		DB	066,064,064	;   3
		DB	064,078,064	;   4
		DB	066,076,064	;   5
		DB	062,076,064	;   6
		DB	064,076,066	;   7
		DB	064,076,062	;   8
		DB	064,064,066	;   9
		DB	064,064,062	;  10
		DB	064,040,064	;  11
		DB	064,000,064	;  12
		DB	064,064,064	;  13
		DB	066,042,064	;  14
		DB	062,042,064	;  15
		DB	064,042,066	;  16
		DB	064,042,062	;  17
		DB	-1

		DW	OFFSET	skyflash_1

		EVEN

skyflash_1	DW	100

skflplume_msl	DB	028h,18,04,20,06,-1
		DW	OFFSET skflplume_L-$-2	; 
		DW	OFFSET skflbody-$-2	; 
		DB	-1

skflplume_L	DB	046h		; GOSUB
		DW	OFFSET skflplume-$-2
		DB	040h,001h		; IF_burning_skfl
		DW	OFFSET skflplume_b-$-2	; to ENDIF
		DW	OFFSET THEN_skfl_burn-$-2	; to THEN


skflplume	LABEL	BYTE
		DB	-1

THEN_skfl_burn	LABEL	BYTE
		DB	00Dh,COL_GREY1,COL_GREY1,24,30,28,-1	; face 16
		DB	00Dh,COL_GREY1,COL_GREY1,24,32,34,-1	; face 15
		DB	00Ch,COL_NT_YELLOW1,COL_NT_YELLOW1,34,22,32,26,-1	; face 14
		DB	00Dh,COL_NT_AMBER1,COL_NT_AMBER1,26,28,22,30,-1	; face 15
		DB	00Dh,COL_NT_AMBER1,COL_NT_AMBER1,30,32,28,34,-1	; face 15
		DB	-1

skflplume_b	LABEL	BYTE
		DB	-1

skflbody	LABEL	BYTE
		DB	00Ch,COL_CYAN_GREY2,COL_CYAN_GREY2,04,02,06,-1	; face 1
		DB	00Ch,COL_CYAN_GREY2,COL_CYAN_GREY2,12,08,10,-1	; face 2
		DB	006h,5,COL_CYAN_GREY1,COL_CYAN_GREY1,00,02,-1	; line 3
		DB	00Ch,COL_CYAN_GREY2,COL_CYAN_GREY2,18,02,20,-1	; face 4
		DB	00Ch,COL_CYAN_GREY2,COL_CYAN_GREY2,14,08,16,-1	; face 5
		DB	-1

		EVEN

skyflash2	OBJECTHEADER <OBJ_SCALE1,16384,-1,1,COL_CYAN_GREY2,0,2,0>
		DB	064,066,064	;   0
		DB	064,064,064	;   1
		DB	064,062,064	;   2
		DB	064,060,064	;   3
		DB	-1

		DW	OFFSET	skyflash2_1

		EVEN

skyflash2_1	DW	31

skflplume_2_L	DB	046h		; GOSUB
		DW	OFFSET skflplume_2-$-2
		DB	040h,001h		; IF_burning_skfl2
		DW	OFFSET skflplume_b2-$-2	; to ENDIF
		DW	OFFSET THEN_burn_skfl2-$-2	; to THEN


skflplume_2	LABEL	BYTE
		DB	00Eh,COL_CYAN_GREY2,COL_CYAN_GREY2,00,02,-1	; line 3
		DB	-1

THEN_burn_skfl2	LABEL	BYTE
		DB	00Eh,COL_NT_AMBER1,COL_NT_AMBER1,04,06,-1	; line 6
		DB	00Eh,COL_NT_YELLOW1,COL_NT_YELLOW1,04,02,-1	; face 9
		DB	-1

skflplume_b2	LABEL	BYTE
		DB	-1

		EVEN

