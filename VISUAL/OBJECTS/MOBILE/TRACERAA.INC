traceraa		OBJECTHEADER <OBJ_SCALE8,2048,traceraa2,0,COL_BLACK1,1,32,2>
		DB	066,100,066	;   0
		DB	066,104,066	;   1
		DB	062,124,066	;   2
		DB	062,128,066	;   3
		DB	062,128,060	;   4
		DB	062,124,060	;   5
		DB	066,104,060	;   6
		DB	066,100,060	;   7
		DB	-1

		DW	OFFSET	traceraa_1

		EVEN

traceraa_1	DW	67

traceraa_0_L	DB	046h		; GOSUB
		DW	OFFSET traceraa_0-$-2
		DB	040h,001h		; IF_rtext_1
		DW	OFFSET traceraa_0_b_L-$-2	; to ENDIF
		DW	OFFSET THEN_t1a-$-2	; to THEN

traceraa_0_b_L	DB	046h		; GOSUB
		DW	OFFSET traceraa_0_b-$-2
		DB	040h,002h		; IF_lfext_4
		DW	OFFSET traceraa_0_b_b_L-$-2	; to ENDIF
		DW	OFFSET THEN_t1b-$-2	; to THEN

traceraa_0_b_b_L	DB	046h		; GOSUB
		DW	OFFSET traceraa_0_b_b-$-2
		DB	040h,004h		; IF_rtint_7
		DW	OFFSET traceraa_0_b_b_b_L-$-2	; to ENDIF
		DW	OFFSET THEN_t1c-$-2	; to THEN

traceraa_0_b_b_b_L	DB	046h		; GOSUB
		DW	OFFSET traceraa_0_b_b_b-$-2
		DB	040h,008h		; IF_lfint_10
		DW	OFFSET traceraa_0_b_b_b_b-$-2	; to ENDIF
		DW	OFFSET THEN_t1d-$-2	; to THEN


traceraa_0	LABEL	BYTE
		DB	-1

THEN_t1a	LABEL	BYTE
		DB	00Eh,COL_NT_RED1,COL_NT_RED1,02,00,-1	; line 1
		DB	-1

traceraa_0_b	LABEL	BYTE
		DB	-1

THEN_t1b	LABEL	BYTE
		DB	00Ah,COL_NT_RED1,04,06,-1		; line 4
		DB	-1

traceraa_0_b_b	LABEL	BYTE
		DB	-1

THEN_t1c	LABEL	BYTE
		DB	00Ah,COL_NT_RED1,14,12,-1		; line 11
		DB	-1

traceraa_0_b_b_b	LABEL	BYTE
		DB	-1

THEN_t1d	LABEL	BYTE
		DB	00Ah,COL_NT_RED1,10,08,-1		; line 12
		DB	-1

traceraa_0_b_b_b_b	LABEL	BYTE
		DB	-1

		EVEN

traceraa2		OBJECTHEADER <OBJ_SCALE4,4096,-1,1,COL_NT_RED1,0,15,0>
		DB	064,082,064	;   0
		DB	064,094,064	;   1
		DB	-1

		DW	OFFSET	traceraa2_1

		EVEN

traceraa2_1	DW	66

traceraa_0_2_L	DB	046h		; GOSUB
		DW	OFFSET traceraa_0_2-$-2
		DB	040h,001h		; IF_rtext_c2
		DW	OFFSET traceraa_0_b2_L-$-2	; to ENDIF
		DW	OFFSET THEN_t2a-$-2	; to THEN

traceraa_0_b2_L	DB	046h		; GOSUB
		DW	OFFSET traceraa_0_b2-$-2
		DB	040h,002h		; IF_lfext_c2
		DW	OFFSET traceraa_0_b_b2_L-$-2	; to ENDIF
		DW	OFFSET THEN_t2b-$-2	; to THEN

traceraa_0_b_b2_L	DB	046h		; GOSUB
		DW	OFFSET traceraa_0_b_b2-$-2
		DB	040h,004h		; IF_rtint_c2
		DW	OFFSET traceraa_0_b_b_b2_L-$-2	; to ENDIF
		DW	OFFSET THEN_t2c-$-2	; to THEN

traceraa_0_b_b_b2_L	DB	046h		; GOSUB
		DW	OFFSET traceraa_0_b_b_b2-$-2
		DB	040h,008h		; IF_lfint_c2
		DW	OFFSET traceraa_0_b_b_b_b2-$-2	; to ENDIF
		DW	OFFSET THEN_t2d-$-2	; to THEN


traceraa_0_2	LABEL	BYTE
		DB	-1

THEN_t2a	LABEL	BYTE
		DB	00Ah,COL_NT_RED1,00,00,-1		; line 13
		DB	-1

traceraa_0_b2	LABEL	BYTE
		DB	-1

THEN_t2b	LABEL	BYTE
		DB	00Ah,COL_NT_RED1,02,02,-1		; line 14
		DB	-1

traceraa_0_b_b2	LABEL	BYTE
		DB	-1

THEN_t2c	LABEL	BYTE
		DB	00Ah,COL_NT_RED1,00,00,-1		; line 15
		DB	-1

traceraa_0_b_b_b2	LABEL	BYTE
		DB	-1

THEN_t2d	LABEL	BYTE
		DB	00Ah,COL_NT_RED1,02,02,-1		; line 16
		DB	-1

traceraa_0_b_b_b_b2	LABEL	BYTE
		DB	-1

		EVEN

