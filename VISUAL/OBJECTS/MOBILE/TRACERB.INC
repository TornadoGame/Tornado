tracerb		OBJECTHEADER <OBJ_SCALE8,2048,tracerb2,0,COL_BLACK1,1,32,2>
		DB	066,100,066	;   0
		DB	066,104,066	;   1
		DB	062,124,066	;   2
		DB	062,128,066	;   3
		DB	062,128,060	;   4
		DB	062,124,060	;   5
		DB	066,104,060	;   6
		DB	066,100,060	;   7
		DB	-1

		DW	OFFSET	tracerb_1

		EVEN

tracerb_1	DW	67

tracerb_0_L	DB	046h		; GOSUB
		DW	OFFSET tracerb_0-$-2
		DB	040h,001h		; IF_rtext_1
		DW	OFFSET tracerb_0_b_L-$-2	; to ENDIF
		DW	OFFSET THEN_tb1a-$-2	; to THEN

tracerb_0_b_L	DB	046h		; GOSUB
		DW	OFFSET tracerb_0_b-$-2
		DB	040h,002h		; IF_lfext_4
		DW	OFFSET tracerb_0_b_b_L-$-2	; to ENDIF
		DW	OFFSET THEN_tb1b-$-2	; to THEN

tracerb_0_b_b_L	DB	046h		; GOSUB
		DW	OFFSET tracerb_0_b_b-$-2
		DB	040h,004h		; IF_rtint_7
		DW	OFFSET tracerb_0_b_b_b_L-$-2	; to ENDIF
		DW	OFFSET THEN_tb1c-$-2	; to THEN

tracerb_0_b_b_b_L	DB	046h		; GOSUB
		DW	OFFSET tracerb_0_b_b_b-$-2
		DB	040h,008h		; IF_lfint_10
		DW	OFFSET tracerb_0_b_b_b_b-$-2	; to ENDIF
		DW	OFFSET THEN_tb1d-$-2	; to THEN


tracerb_0	LABEL	BYTE
		DB	-1

THEN_tb1a	LABEL	BYTE
		DB	00Eh,COL_NT_YELLOW1,COL_NT_YELLOW1,02,00,-1	; line 1
		DB	-1

tracerb_0_b	LABEL	BYTE
		DB	-1

THEN_tb1b	LABEL	BYTE
		DB	00Ah,COL_NT_YELLOW1,04,06,-1		; line 4
		DB	-1

tracerb_0_b_b	LABEL	BYTE
		DB	-1

THEN_tb1c	LABEL	BYTE
		DB	00Ah,COL_NT_YELLOW1,14,12,-1		; line 11
		DB	-1

tracerb_0_b_b_b	LABEL	BYTE
		DB	-1

THEN_tb1d	LABEL	BYTE
		DB	00Ah,COL_NT_YELLOW1,10,08,-1		; line 12
		DB	-1

tracerb_0_b_b_b_b	LABEL	BYTE
		DB	-1

		EVEN

tracerb2		OBJECTHEADER <OBJ_SCALE4,4096,-1,1,COL_NT_YELLOW1,0,15,0>
		DB	064,082,064	;   0
		DB	064,094,064	;   1
		DB	-1

		DW	OFFSET	tracerb2_1

		EVEN

tracerb2_1	DW	66

tracerb_0_2_L	DB	046h		; GOSUB
		DW	OFFSET tracerb_0_2-$-2
		DB	040h,001h		; IF_rtext_c2
		DW	OFFSET tracerb_0_b2_L-$-2	; to ENDIF
		DW	OFFSET THEN_tb2a-$-2	; to THEN

tracerb_0_b2_L	DB	046h		; GOSUB
		DW	OFFSET tracerb_0_b2-$-2
		DB	040h,002h		; IF_lfext_c2
		DW	OFFSET tracerb_0_b_b2_L-$-2	; to ENDIF
		DW	OFFSET THEN_tb2b-$-2	; to THEN

tracerb_0_b_b2_L	DB	046h		; GOSUB
		DW	OFFSET tracerb_0_b_b2-$-2
		DB	040h,004h		; IF_rtint_c2
		DW	OFFSET tracerb_0_b_b_b2_L-$-2	; to ENDIF
		DW	OFFSET THEN_tb2c-$-2	; to THEN

tracerb_0_b_b_b2_L	DB	046h		; GOSUB
		DW	OFFSET tracerb_0_b_b_b2-$-2
		DB	040h,008h		; IF_lfint_c2
		DW	OFFSET tracerb_0_b_b_b_b2-$-2	; to ENDIF
		DW	OFFSET THEN_tb2d-$-2	; to THEN


tracerb_0_2	LABEL	BYTE
		DB	-1

THEN_tb2a	LABEL	BYTE
		DB	00Ah,COL_NT_YELLOW1,00,00,-1		; line 13
		DB	-1

tracerb_0_b2	LABEL	BYTE
		DB	-1

THEN_tb2b	LABEL	BYTE
		DB	00Ah,COL_NT_YELLOW1,02,02,-1		; line 14
		DB	-1

tracerb_0_b_b2	LABEL	BYTE
		DB	-1

THEN_tb2c	LABEL	BYTE
		DB	00Ah,COL_NT_YELLOW1,00,00,-1		; line 15
		DB	-1

tracerb_0_b_b_b2	LABEL	BYTE
		DB	-1

THEN_tb2d	LABEL	BYTE
		DB	00Ah,COL_NT_YELLOW1,02,02,-1		; line 16
		DB	-1

tracerb_0_b_b_b_b2	LABEL	BYTE
		DB	-1

		EVEN

