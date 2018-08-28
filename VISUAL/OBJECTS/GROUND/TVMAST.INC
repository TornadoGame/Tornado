tvmast		OBJECTHEADER <OBJ_SCALE1,4000,tvmast3,0,COL_BLACK1,14,14,32>
		DB	064,064,064	;   0
		DB	066,064,064	;   1
		DB	066,062,064	;   2
		DB	064,062,064	;   3
		DB	066,064,072	;   4
		DB	066,062,072	;   5
		DB	064,062,072	;   6
		DB	064,064,072	;   7
		DB	066,064,080	;   8
		DB	066,062,080	;   9
		DB	064,062,080	;  10
		DB	064,064,080	;  11
		DB	066,064,088	;  12
		DB	066,062,088	;  13
		DB	064,062,088	;  14
		DB	064,064,088	;  15
		DB	066,064,096	;  16
		DB	066,062,096	;  17
		DB	064,062,096	;  18
		DB	064,064,096	;  19
		DB	064,064,104	;  20
		DB	066,064,104	;  21
		DB	066,062,104	;  22
		DB	064,062,104	;  23
		DB	066,064,112	;  24
		DB	066,062,112	;  25
		DB	064,062,112	;  26
		DB	064,064,112	;  27
		DB	066,064,120	;  28
		DB	066,062,120	;  29
		DB	064,062,120	;  30
		DB	064,064,120	;  31
		DB	064,064,128	;  32
		DB	066,064,128	;  33
		DB	066,062,128	;  34
		DB	064,062,128	;  35
		DB	092,036,064	;  36
		DB	092,090,064	;  37
		DB	038,090,064	;  38
		DB	038,036,064	;  39
		DB	068,060,064	;  40
		DB	062,060,064	;  41
		DB	062,066,064	;  42
		DB	068,066,064	;  43
		DB	074,068,064	;  44
		DB	074,064,064	;  45
		DB	078,064,064	;  46
		DB	078,060,064	;  47
		DB	082,060,064	;  48
		DB	082,068,064	;  49
		DB	074,068,066	;  50
		DB	082,068,066	;  51
		DB	082,060,066	;  52
		DB	078,060,066	;  53
		DB	078,064,066	;  54
		DB	074,064,066	;  55
		DB	074,056,064	;  56
		DB	082,056,064	;  57
		DB	-1

		DW	OFFSET	tvmast_1

		EVEN

tvmast_1	DW	274

tvmgpln_L	DB	046h		; GOSUB
		DW	OFFSET tvmgpln-$-2
tvmbld_mast	DB	028h,66,112,88,-1
		DW	OFFSET tvmbldbk_ft-$-2	; 
		DW	OFFSET tvmmast_L-$-2	; 
		DB	-1

tvmbldbk_ft	DB	028h,92,02,56,-1
		DW	OFFSET tvmbldbk-$-2	; 
		DW	OFFSET tvmbldft-$-2	; 
		DB	-1

tvmmast_L	DB	046h		; GOSUB
		DW	OFFSET tvmmast-$-2
		DB	040h,001h		; IF_lton_tvm
		DW	OFFSET tvmmast_b-$-2	; to ENDIF
		DW	OFFSET THEN_lton_tvm-$-2	; to THEN


tvmgpln		LABEL	BYTE
		DB	008h,COL_ROAD1,94,96,114,112,-1		; face 29
		DB	008h,COL_ROAD1,112,90,92,94,-1		; face 28
		DB	008h,COL_ROAD1,84,86,80,82,-1		; face 19
		DB	-1

tvmbldbk	LABEL	BYTE
		DB	00Ah,COL_GREY2,56,74,32,-1		; line 18
		DB	008h,COL_SAND5,110,108,92,90,-1		; face 21
		DB	008h,COL_SAND5,106,104,96,94,-1		; face 20
		DB	008h,COL_RUST1,104,102,98,96,-1		; face 23
		DB	008h,COL_RUST1,100,110,90,88,-1		; face 25
		DB	008h,COL_GREY2,108,110,100,102,-1	; face 26
		DB	008h,COL_GREY2,102,104,106,108,-1	; face 27
		DB	-1

tvmbldft	LABEL	BYTE
		DB	00Ah,COL_GREY2,58,72,34,-1		; line 18
		DB	008h,COL_SAND5,102,100,88,98,-1		; face 22
		DB	008h,COL_RUST1,108,106,94,92,-1		; face 24
		DB	-1

tvmmast		LABEL	BYTE
		DB	00Ah,COL_GREY1,02,56,-1			; line 3
		DB	00Ah,COL_GREY1,04,58,-1			; line 1
		DB	00Ah,COL_GREY1,06,60,-1			; line 0
		DB	00Ah,COL_GREY1,62,00,-1			; line 2
		DB	00Ah,COL_GREY1,08,10,12,14,08,-1	; line 4
		DB	00Ah,COL_GREY1,22,16,18,20,22,-1	; line 5
		DB	00Ah,COL_GREY1,30,24,26,28,30,-1	; line 6
		DB	00Ah,COL_GREY1,38,32,34,36,38,-1	; line 7
		DB	00Ah,COL_GREY1,40,42,44,46,40,-1	; line 8
		DB	00Ah,COL_GREY1,54,48,50,52,54,-1	; line 9
		DB	008h,COL_WHITE1,66,68,70,64,-1		; face 14
		DB	008h,COL_GREY2,60,58,56,62,-1		; face 36
		DB	008h,COL_WHITE1,70,68,58,60,-1		; face 10
		DB	008h,COL_WHITE1,66,64,62,56,-1		; face 11
		DB	008h,COL_GREY1,70,60,62,64,-1		; face 13
		DB	008h,COL_GREY1,66,56,58,68,-1		; face 12
		DB	-1

THEN_lton_tvm	LABEL	BYTE
		DB	00Ah,COL_NT_RED1,68,68,-1		; line 37
		DB	00Ah,COL_NT_RED1,64,64,-1		; line 39
		DB	00Ah,COL_NT_RED1,70,70,-1		; line 40
		DB	00Ah,COL_NT_RED1,66,66,-1		; line 38
		DB	-1

tvmmast_b	LABEL	BYTE
		DB	00Ah,COL_GREY2,62,76,38,-1		; line 18
		DB	00Ah,COL_GREY2,60,78,36,-1		; line 19
		DB	-1

		EVEN

tvmast3		OBJECTHEADER <OBJ_SCALE1,16384,-1,1,COL_BLACK1,14,14,32>
		DB	064,064,064	;   0
		DB	064,064,096	;   1
		DB	064,064,120	;   2
		DB	064,064,128	;   3
		DB	092,036,064	;   4
		DB	092,090,064	;   5
		DB	038,090,064	;   6
		DB	038,036,064	;   7
		DB	068,060,064	;   8
		DB	062,060,064	;   9
		DB	062,066,064	;  10
		DB	068,066,064	;  11
		DB	074,068,064	;  12
		DB	074,064,064	;  13
		DB	078,064,064	;  14
		DB	078,060,064	;  15
		DB	082,060,064	;  16
		DB	082,068,064	;  17
		DB	074,068,066	;  18
		DB	082,068,066	;  19
		DB	082,060,066	;  20
		DB	078,060,066	;  21
		DB	078,064,066	;  22
		DB	074,064,066	;  23
		DB	074,056,064	;  24
		DB	082,056,064	;  25
		DB	-1

		DW	OFFSET	tvmast3_1

		EVEN

tvmast3_1	DW	129

tvmgpln3_L	DB	046h		; GOSUB
		DW	OFFSET tvmgpln3-$-2
		DB	040h,001h		; IF_lton_tvm2
		DW	OFFSET tvmgpln3_b-$-2	; to ENDIF
		DW	OFFSET THEN_lton_tvm2-$-2	; to THEN


tvmgpln3	LABEL	BYTE
		DB	008h,COL_ROAD1,30,32,50,48,-1		; face 29
		DB	008h,COL_ROAD1,48,26,28,30,-1		; face 28
		DB	008h,COL_ROAD1,20,22,16,18,-1		; face 19
		DB	00Ah,COL_GREY2,04,10,02,-1		; line 18
		DB	008h,COL_SAND5,46,44,28,26,-1		; face 21
		DB	008h,COL_SAND5,42,40,32,30,-1		; face 20
		DB	008h,COL_RUST1,40,38,34,32,-1		; face 23
		DB	008h,COL_RUST1,36,46,26,24,-1		; face 25
		DB	008h,COL_GREY2,44,46,36,38,-1		; face 26
		DB	008h,COL_GREY2,38,40,42,44,-1		; face 27
		DB	00Ah,COL_GREY2,04,08,02,-1		; line 18
		DB	008h,COL_SAND5,38,36,24,34,-1		; face 22
		DB	008h,COL_RUST1,44,42,30,28,-1		; face 24
		DB	00Ah,COL_GREY2,04,12,02,-1		; line 18
		DB	00Ah,COL_GREY2,04,14,02,-1		; line 19
		DB	00Ah,COL_WHITE1,04,06,-1		; line 20
		DB	00Ah,COL_GREY1,00,04,-1			; line 17
		DB	-1

THEN_lton_tvm2	LABEL	BYTE
		DB	00Ah,COL_NT_RED1,06,06,-1		; line 18
		DB	-1

tvmgpln3_b	LABEL	BYTE
		DB	-1

		EVEN

