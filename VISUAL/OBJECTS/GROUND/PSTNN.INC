pstnn		OBJECTHEADER <OBJ_SCALE4,1000,pstnn2,0,COL_BLACK1,29,23,6>
		DB	100,070,064	;   0
		DB	100,058,064	;   1
		DB	100,070,072	;   2
		DB	100,058,072	;   3
		DB	090,080,072	;   4
		DB	110,080,072	;   5
		DB	110,048,072	;   6
		DB	090,048,072	;   7
		DB	092,078,074	;   8
		DB	108,078,074	;   9
		DB	108,050,074	;  10
		DB	092,050,074	;  11
		DB	098,062,064	;  12
		DB	100,062,064	;  13
		DB	100,060,064	;  14
		DB	098,060,064	;  15
		DB	100,060,068	;  16
		DB	098,060,068	;  17
		DB	098,062,068	;  18
		DB	100,062,068	;  19
		DB	100,066,068	;  20
		DB	100,068,068	;  21
		DB	100,068,064	;  22
		DB	100,066,064	;  23
		DB	098,066,068	;  24
		DB	098,066,064	;  25
		DB	098,068,064	;  26
		DB	098,068,068	;  27
		DB	100,072,064	;  28
		DB	098,072,064	;  29
		DB	098,056,064	;  30
		DB	100,056,064	;  31
		DB	068,110,064	;  32
		DB	068,018,064	;  33
		DB	122,040,064	;  34
		DB	122,084,064	;  35
		DB	110,076,064	;  36
		DB	110,052,064	;  37
		DB	120,076,064	;  38
		DB	120,052,064	;  39
		DB	110,076,070	;  40
		DB	120,076,070	;  41
		DB	120,052,070	;  42
		DB	110,052,070	;  43
		DB	110,076,068	;  44
		DB	110,060,068	;  45
		DB	110,060,066	;  46
		DB	110,076,066	;  47
		DB	110,058,068	;  48
		DB	110,058,064	;  49
		DB	110,060,064	;  50
		DB	084,064,064	;  51
		DB	084,064,072	;  52
		DB	082,064,076	;  53
		DB	086,064,076	;  54
		DB	086,064,074	;  55
		DB	082,064,074	;  56
		DB	080,082,064	;  57
		DB	080,046,064	;  58
		DB	080,082,066	;  59
		DB	080,046,066	;  60
		DB	090,074,064	;  61
		DB	090,054,064	;  62
		DB	-1

		DW	OFFSET	pstnn_1

		EVEN

pstnn_1		DW	316

pstnngpln_L	DB	046h		; GOSUB
		DW	OFFSET pstnngpln-$-2
pstnnblg_fct	DB	028h,72,10,12,74,-1
		DW	OFFSET pstnnbldg-$-2	; 
		DW	OFFSET pstnnfct_vrg-$-2	; 
		DB	-1

pstnnfct_vrg	DB	028h,122,08,14,124,-1
		DW	OFFSET pstnncan_fct-$-2	; 
		DW	OFFSET pstnnvrg_L-$-2	; 
		DB	-1

pstnncan_fct	DB	028h,14,12,10,08,-1
		DW	OFFSET pstnncan-$-2	; 
		DW	OFFSET pstnnfct-$-2	; 
		DB	-1

pstnnvrg_L	DB	046h		; GOSUB
		DW	OFFSET pstnnvrg-$-2
		DB	042h,001h		; IF_lton_pstnn
		DW	OFFSET pstnnvrg_b-$-2	; to ENDIF
		DW	OFFSET THEN_lton_pstnn-$-2	; to THEN
		DW	OFFSET ELSE_lton_pstnn-$-2	; to ELSE


pstnngpln	LABEL	BYTE
		DB	008h,COL_ROAD1,64,70,68,66,-1		; face 19
		DB	000h,6,COL_GREEN2,124,116,114,122,-1	; face 33
		DB	-1

pstnnbldg	LABEL	BYTE
		DB	008h,COL_RUST2,80,86,74,72,-1		; face 20
		DB	000h,6,COL_DK_CYAN2,88,90,92,94,-1	; face 21
		DB	000h,6,COL_DK_CYAN2,90,96,98,100,-1	; face 22
		DB	002h,6,COL_GREY1,100,90,96,98,-1	; line 23
		DB	002h,7,COL_GREY1,88,90,92,94,88,-1	; line 24
		DB	008h,COL_RUST2,82,76,78,84,-1		; face 25
		DB	008h,COL_RUST3,86,84,78,74,-1		; face 26
		DB	008h,COL_RUST3,82,80,72,76,-1		; face 27
		DB	008h,COL_CYAN_GREY5,80,82,84,86,-1	; face 28
		DB	-1

pstnncan	LABEL	BYTE
		DB	008h,COL_CYAN_GREY4,20,18,10,12,-1	; face 8
		DB	008h,COL_CYAN_GREY4,16,22,14,08,-1	; face 9
		DB	008h,COL_CYAN_GREY5,22,20,12,14,-1	; face 10
		DB	008h,COL_CYAN_GREY5,18,16,08,10,-1	; face 11
		DB	008h,COL_GREY1,18,20,22,16,-1		; face 12
		DB	008h,COL_GREY2,12,10,08,14,-1		; face 13
		DB	-1

pstnnfct	LABEL	BYTE
		DB	008h,COL_GREY3,58,56,62,60,-1		; face 8
		DB	00Eh,COL_GREY1,COL_GREY1,00,04,-1	; line 6
		DB	00Eh,COL_GREY1,COL_GREY1,02,06,-1	; line 7
		DB	008h,COL_AMBER2,42,44,46,40,-1		; face 9
		DB	008h,COL_AMBER2,38,26,28,32,-1		; face 10
		DB	008h,COL_AMBER2,36,34,30,24,-1		; face 11
		DB	008h,COL_AMBER2,48,50,52,54,-1		; face 12
		DB	008h,COL_AMBER3,40,46,50,48,-1		; face 13
		DB	008h,COL_AMBER3,32,28,30,34,-1		; face 14
		DB	008h,COL_AMBER3,38,36,24,26,-1		; face 15
		DB	008h,COL_AMBER3,54,52,44,42,-1		; face 16
		DB	008h,COL_AMBER1,42,40,48,54,-1		; face 17
		DB	008h,COL_AMBER1,38,32,34,36,-1		; face 18
		DB	-1

pstnnvrg	LABEL	BYTE
		DB	00Ch,COL_WHITE1,COL_WHITE1,112,106,108,110,104,-1	; face 30
		DB	006h,5,COL_WHITE1,COL_WHITE1,102,104,-1	; line 31
		DB	00Ch,COL_RUST2,COL_RUST2,118,120,116,114,-1	; face 32
		DB	-1

THEN_lton_pstnn	LABEL	BYTE
		DB	00Dh,COL_NT_AMBER1,COL_NT_AMBER1,106,108,110,112,-1	; face 30
		DB	-1

ELSE_lton_pstnn	LABEL	BYTE
		DB	00Dh,COL_AMBER2,COL_AMBER2,106,108,110,112,-1	; face 46
		DB	-1

pstnnvrg_b	LABEL	BYTE
		DB	-1

		EVEN

pstnn2		OBJECTHEADER <OBJ_SCALE2,3000,pstnn3,0,COL_BLACK1,15,11,3>
		DB	082,068,064	;   0
		DB	082,060,064	;   1
		DB	082,068,068	;   2
		DB	082,060,068	;   3
		DB	078,072,068	;   4
		DB	078,056,068	;   5
		DB	082,062,064	;   6
		DB	082,062,066	;   7
		DB	082,066,066	;   8
		DB	082,066,064	;   9
		DB	066,086,064	;  10
		DB	066,042,064	;  11
		DB	094,052,064	;  12
		DB	094,074,064	;  13
		DB	086,070,064	;  14
		DB	086,058,064	;  15
		DB	092,070,064	;  16
		DB	092,058,064	;  17
		DB	086,070,066	;  18
		DB	092,070,066	;  19
		DB	092,058,066	;  20
		DB	086,058,066	;  21
		DB	086,062,066	;  22
		DB	086,062,064	;  23
		DB	074,064,064	;  24
		DB	074,064,068	;  25
		DB	074,064,070	;  26
		DB	076,064,070	;  27
		DB	072,074,064	;  28
		DB	072,054,064	;  29
		DB	078,070,064	;  30
		DB	078,058,064	;  31
		DB	086,072,068	;  32
		DB	086,056,068	;  33
		DB	-1

		DW	OFFSET	pstnn2_1

		EVEN

pstnn2_1	DW	161

pstn2gpln_L	DB	046h		; GOSUB
		DW	OFFSET pstn2gpln-$-2
pstnn2lf_rt	DB	028h,28,64,66,30,-1
		DW	OFFSET pstnlf-$-2	; 
		DW	OFFSET pstnrt_L-$-2	; 
		DB	-1

pstnrt_L	DB	046h		; GOSUB
		DW	OFFSET pstnrt-$-2
		DB	042h,001h		; IF_lton_pstnn2
		DW	OFFSET pstnrt_b-$-2	; to ENDIF
		DW	OFFSET THEN_lton_pstnn2-$-2	; to THEN
		DW	OFFSET ELSE_lton_pstnn2-$-2	; to ELSE


pstn2gpln	LABEL	BYTE
		DB	008h,COL_ROAD1,20,26,24,22,-1		; face 19
		DB	000h,6,COL_GREEN2,62,58,56,60,-1	; face 33
		DB	006h,5,COL_RUST2,COL_RUST2,56,58,-1	; line 16
		DB	008h,COL_GREY3,00,00,02,02,-1		; face 8
		DB	-1

pstnlf		LABEL	BYTE
		DB	008h,COL_RUST2,36,42,30,28,-1		; face 20
		DB	002h,5,COL_DK_CYAN2,36,44,46,-1		; line 17
		DB	008h,COL_RUST2,38,32,34,40,-1		; face 25
		DB	008h,COL_RUST3,42,40,34,30,-1		; face 26
		DB	008h,COL_RUST3,38,36,28,32,-1		; face 27
		DB	008h,COL_CYAN_GREY5,36,38,40,42,-1	; face 28
		DB	-1

pstnrt		LABEL	BYTE
		DB	00Eh,COL_GREY1,COL_GREY1,00,04,-1	; line 6
		DB	00Eh,COL_GREY1,COL_GREY1,02,06,-1	; line 7
		DB	006h,5,COL_WHITE1,COL_WHITE1,48,50,-1	; line 31
		DB	00Ch,COL_WHITE1,COL_WHITE1,50,52,54,-1	; face 19
		DB	-1

THEN_lton_pstnn2	LABEL	BYTE
		DB	00Eh,COL_NT_AMBER1,COL_NT_AMBER1,52,54,-1	; line 21
		DB	-1

ELSE_lton_pstnn2	LABEL	BYTE
		DB	00Eh,COL_AMBER2,COL_AMBER2,52,54,-1	; line 26
		DB	-1

pstnrt_b	LABEL	BYTE
		DB	00Ch,COL_GREY1,COL_GREY2,08,64,66,10,-1	; face 13
		DB	00Ah,COL_AMBER2,12,14,-1		; line 14
		DB	00Ah,COL_AMBER2,18,16,-1		; line 15
		DB	-1

		EVEN

pstnn3		OBJECTHEADER <OBJ_SCALE1,16384,-1,1,COL_GREY1,7,5,1>
		DB	072,068,066	;   0
		DB	072,060,066	;   1
		DB	068,074,064	;   2
		DB	068,054,064	;   3
		DB	078,058,064	;   4
		DB	078,070,064	;   5
		DB	076,068,064	;   6
		DB	078,068,064	;   7
		DB	078,060,064	;   8
		DB	076,060,064	;   9
		DB	070,064,064	;  10
		DB	070,064,066	;  11
		DB	068,070,064	;  12
		DB	068,058,064	;  13
		DB	072,068,064	;  14
		DB	072,060,064	;  15
		DB	076,068,066	;  16
		DB	076,060,066	;  17
		DB	-1

		DW	OFFSET	pstnn3_1

		EVEN

pstnn3_1	DW	73

pstn3_0_L	DB	046h		; GOSUB
		DW	OFFSET pstn3_0-$-2
		DB	042h,001h		; IF_lton_pstnn3
		DW	OFFSET pstn3_0_b-$-2	; to ENDIF
		DW	OFFSET THEN_lton_pstnn3-$-2	; to THEN
		DW	OFFSET ELSE_lton_pstnn3-$-2	; to ELSE


pstn3_0		LABEL	BYTE
		DB	008h,COL_ROAD1,04,10,08,06,-1		; face 19
		DB	000h,6,COL_CYAN_GREY5,12,14,16,18,-1	; face 28
		DB	000h,6,COL_GREEN2,30,26,24,28,-1	; face 33
		DB	006h,5,COL_RUST2,COL_RUST2,24,26,-1	; line 16
		DB	006h,5,COL_WHITE1,COL_WHITE1,20,22,-1	; pstnn2lf_rt
		DB	-1

THEN_lton_pstnn3	LABEL	BYTE
		DB	00Eh,COL_NT_AMBER1,COL_NT_AMBER1,22,22,-1	; line 7
		DB	-1

ELSE_lton_pstnn3	LABEL	BYTE
		DB	00Eh,COL_AMBER2,COL_AMBER2,22,22,-1	; line 12
		DB	-1

pstn3_0_b	LABEL	BYTE
		DB	00Ch,COL_GREY1,COL_GREY2,00,32,34,02,-1	; face 13
		DB	-1

		EVEN

