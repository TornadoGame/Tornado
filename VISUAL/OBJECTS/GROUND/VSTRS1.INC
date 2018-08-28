vstrs1		OBJECTHEADER <OBJ_SCALE2,2000,vstrs2,0,COL_BLACK1,32,13,4>
		DB	126,062,064	;   0
		DB	002,062,064	;   1
		DB	126,060,064	;   2
		DB	002,060,064	;   3
		DB	122,060,064	;   4
		DB	122,050,064	;   5
		DB	116,050,064	;   6
		DB	116,054,064	;   7
		DB	054,054,064	;   8
		DB	054,060,064	;   9
		DB	054,060,068	;  10
		DB	122,060,068	;  11
		DB	122,050,068	;  12
		DB	116,050,068	;  13
		DB	116,054,068	;  14
		DB	054,054,068	;  15
		DB	120,058,070	;  16
		DB	056,058,070	;  17
		DB	120,052,070	;  18
		DB	026,060,064	;  19
		DB	042,060,064	;  20
		DB	042,056,070	;  21
		DB	026,056,070	;  22
		DB	042,038,070	;  23
		DB	026,038,070	;  24
		DB	026,056,064	;  25
		DB	042,056,064	;  26
		DB	042,038,064	;  27
		DB	026,038,064	;  28
		DB	034,056,072	;  29
		DB	034,044,072	;  30
		DB	000,066,064	;  31
		DB	128,066,064	;  32
		DB	128,062,064	;  33
		DB	000,062,064	;  34
		DB	064,066,068	;  35
		DB	064,066,064	;  36
		DB	096,062,068	;  37
		DB	096,062,064	;  38
		DB	032,062,068	;  39
		DB	032,062,064	;  40
		DB	-1

		DW	OFFSET	vstrs1_1

		EVEN

vstrs1_1	DW	230

vstrshs_rd	DB	028h,22,20,18,-1
		DW	OFFSET vstrslf_rt-$-2	; 
		DW	OFFSET vstrsrd_L-$-2	; 
		DB	-1

vstrslf_rt	DB	028h,40,54,46,-1
		DW	OFFSET vstrslf-$-2	; 
		DW	OFFSET vstrsrt-$-2	; 
		DB	-1

vstrsrd_L	DB	046h		; GOSUB
		DW	OFFSET vstrsrd-$-2
		DB	040h,001h		; IF_lton_vstrs
		DW	OFFSET vstrsrd_b-$-2	; to ENDIF
		DW	OFFSET THEN_lton_vstrs-$-2	; to THEN


vstrslf		LABEL	BYTE
		DB	008h,COL_ROAD1,40,52,50,38,-1		; face 14
		DB	008h,COL_RUST3,48,46,54,56,-1		; face 15
		DB	008h,COL_RUST3,44,50,52,42,58,-1	; face 26
		DB	002h,4,COL_NEW_GREY1,42,44,-1		; line 25
		DB	008h,COL_RUST4,46,42,52,54,-1		; face 17
		DB	008h,COL_RUST4,44,48,56,50,-1		; face 18
		DB	008h,COL_CYAN_GREY5,60,58,42,46,-1	; face 19
		DB	008h,COL_CYAN_GREY4,48,44,58,60,-1	; face 20
		DB	008h,COL_CYAN_GREY4,60,46,48,-1		; face 21
		DB	-1

vstrsrt		LABEL	BYTE
		DB	008h,COL_NEW_GREY1,30,28,14,16,-1	; face 2
		DB	008h,COL_NEW_GREY1,12,26,24,10,-1	; face 3
		DB	008h,COL_GREY1,26,12,14,28,-1		; face 4
		DB	008h,COL_GREY1,30,16,18,20,-1		; face 5
		DB	008h,COL_GREY1,24,22,08,10,-1		; face 6
		DB	008h,COL_NEW_GREY1,22,20,18,08,-1	; face 7
		DB	008h,COL_CYAN_GREY5,34,32,28,30,-1	; face 8
		DB	008h,COL_CYAN_GREY5,26,36,24,-1		; face 9
		DB	008h,COL_CYAN_GREY4,28,32,36,26,-1	; face 10
		DB	008h,COL_CYAN_GREY4,20,34,30,-1		; face 11
		DB	008h,COL_CYAN_GREY4,34,20,22,32,-1	; face 12
		DB	008h,COL_CYAN_GREY5,32,22,24,36,-1	; face 13
		DB	-1

vstrsrd		LABEL	BYTE
		DB	008h,COL_ROAD1,02,00,04,06,-1		; face 1
		DB	008h,COL_ROAD1,62,64,66,68,-1		; face 26
		DB	002h,4,COL_CYAN_GREY3,80,78,-1		; line 24
		DB	002h,4,COL_CYAN_GREY3,72,70,-1		; line 25
		DB	002h,4,COL_CYAN_GREY3,74,76,-1		; line 26
		DB	-1

THEN_lton_vstrs	LABEL	BYTE
		DB	00Ah,COL_NT_YELLOW1,78,78,-1		; line 27
		DB	00Ah,COL_NT_YELLOW1,70,70,-1		; line 28
		DB	00Ah,COL_NT_YELLOW1,74,74,-1		; line 29
		DB	-1

vstrsrd_b	LABEL	BYTE
		DB	-1

		EVEN

vstrs2		OBJECTHEADER <OBJ_SCALE1,16384,-1,1,COL_BLACK1,16,6,2>
		DB	094,064,064	;   0
		DB	034,064,064	;   1
		DB	094,062,064	;   2
		DB	034,062,064	;   3
		DB	092,062,064	;   4
		DB	092,058,064	;   5
		DB	090,058,064	;   6
		DB	090,060,064	;   7
		DB	060,060,064	;   8
		DB	060,062,064	;   9
		DB	060,062,066	;  10
		DB	092,062,066	;  11
		DB	092,058,066	;  12
		DB	090,058,066	;  13
		DB	090,060,066	;  14
		DB	060,060,066	;  15
		DB	046,062,064	;  16
		DB	054,062,064	;  17
		DB	054,060,066	;  18
		DB	046,060,066	;  19
		DB	054,052,066	;  20
		DB	046,052,066	;  21
		DB	046,060,064	;  22
		DB	054,060,064	;  23
		DB	054,052,064	;  24
		DB	046,052,064	;  25
		DB	050,060,068	;  26
		DB	050,054,068	;  27
		DB	032,064,064	;  28
		DB	096,064,064	;  29
		DB	064,064,066	;  30
		DB	080,064,066	;  31
		DB	048,064,066	;  32
		DB	-1

		DW	OFFSET	vstrs2_1

		EVEN

vstrs2_1	DW	176

vstrs2hs_rd	DB	028h,08,20,18,-1
		DW	OFFSET vstrs2lf-$-2	; 
		DW	OFFSET vstrs2rd_L-$-2	; 
		DB	-1

vstrs2rd_L	DB	046h		; GOSUB
		DW	OFFSET vstrs2rd-$-2
		DB	040h,001h		; IF_lton_vstrs2
		DW	OFFSET vstrs2rd_b-$-2	; to ENDIF
		DW	OFFSET THEN_lton_vstrs2-$-2	; to THEN


vstrs2lf	LABEL	BYTE
		DB	008h,COL_ROAD1,34,46,44,32,-1		; face 14
		DB	008h,COL_RUST3,38,44,46,36,52,-1	; face 26
		DB	002h,4,COL_NEW_GREY1,36,38,-1		; line 25
		DB	008h,COL_RUST4,40,36,46,48,-1		; face 17
		DB	008h,COL_NEW_GREY1,30,28,14,16,-1	; face 2
		DB	008h,COL_NEW_GREY1,12,26,24,10,-1	; face 3
		DB	008h,COL_GREY1,26,12,14,28,-1		; face 4
		DB	008h,COL_GREY1,30,16,18,20,-1		; face 5
		DB	008h,COL_CYAN_GREY5,20,22,28,30,-1	; face 8
		DB	008h,COL_CYAN_GREY4,28,22,24,26,-1	; face 10
		DB	00Ah,COL_CYAN_GREY4,20,30,-1		; face 11
		DB	008h,COL_CYAN_GREY5,54,52,36,40,-1	; face 19
		DB	008h,COL_CYAN_GREY4,42,38,52,54,-1	; face 20
		DB	008h,COL_CYAN_GREY4,54,40,42,-1		; face 21
		DB	008h,COL_RUST3,42,40,48,50,-1		; face 15
		DB	008h,COL_RUST4,38,42,50,44,-1		; face 18
		DB	008h,COL_GREY1,24,22,08,10,-1		; face 6
		DB	008h,COL_NEW_GREY1,22,20,18,08,-1	; face 7
		DB	-1

vstrs2rd	LABEL	BYTE
		DB	008h,COL_ROAD1,02,00,04,06,-1		; face 1
		DB	00Ah,COL_ROAD1,56,58,-1			; line 25
		DB	-1

THEN_lton_vstrs2	LABEL	BYTE
		DB	00Ah,COL_NT_YELLOW1,64,64,-1		; line 27
		DB	00Ah,COL_NT_YELLOW1,60,60,-1		; line 28
		DB	00Ah,COL_NT_YELLOW1,62,62,-1		; line 29
		DB	-1

vstrs2rd_b	LABEL	BYTE
		DB	-1

		EVEN

