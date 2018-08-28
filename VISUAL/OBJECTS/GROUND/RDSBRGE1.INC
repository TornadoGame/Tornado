rdsbrge1	OBJECTHEADER <OBJ_SCALE4,1600,rdsbrge2,0,COL_BLACK1,32,8,32>
		DB	000,048,080	;   0
		DB	000,080,080	;   1
		DB	128,048,080	;   2
		DB	128,080,080	;   3
		DB	000,050,076	;   4
		DB	000,078,076	;   5
		DB	128,078,076	;   6
		DB	128,050,076	;   7
		DB	062,078,064	;   8
		DB	066,078,064	;   9
		DB	066,050,064	;  10
		DB	062,050,064	;  11
		DB	062,078,076	;  12
		DB	062,050,076	;  13
		DB	066,050,076	;  14
		DB	066,078,076	;  15
		DB	062,052,080	;  16
		DB	064,054,080	;  17
		DB	066,052,080	;  18
		DB	064,050,080	;  19
		DB	062,076,080	;  20
		DB	064,078,080	;  21
		DB	066,076,080	;  22
		DB	064,074,080	;  23
		DB	062,052,128	;  24
		DB	064,054,124	;  25
		DB	066,052,128	;  26
		DB	064,050,124	;  27
		DB	062,076,128	;  28
		DB	064,078,124	;  29
		DB	066,076,128	;  30
		DB	064,074,124	;  31
		DB	066,076,108	;  32
		DB	128,076,080	;  33
		DB	066,076,118	;  34
		DB	062,076,108	;  35
		DB	062,076,118	;  36
		DB	000,076,080	;  37
		DB	000,052,080	;  38
		DB	028,052,080	;  39
		DB	042,052,080	;  40
		DB	054,052,080	;  41
		DB	066,052,118	;  42
		DB	066,052,108	;  43
		DB	128,052,080	;  44
		DB	116,076,080	;  45
		DB	100,076,080	;  46
		DB	086,076,080	;  47
		DB	074,076,080	;  48
		DB	054,076,080	;  49
		DB	042,076,080	;  50
		DB	028,076,080	;  51
		DB	012,076,080	;  52
		DB	012,052,080	;  53
		DB	062,052,118	;  54
		DB	062,052,108	;  55
		DB	074,052,080	;  56
		DB	086,052,080	;  57
		DB	100,052,080	;  58
		DB	116,052,080	;  59
		DB	000,048,064	;  60
		DB	000,080,064	;  61
		DB	128,080,064	;  62
		DB	128,048,064	;  63
		DB	062,076,098	;  64
		DB	066,076,098	;  65
		DB	062,052,098	;  66
		DB	066,052,098	;  67
		DB	064,052,128	;  68
		DB	064,076,128	;  69
		DB	-1

		DW	OFFSET	rdsbrge1_1

		EVEN

rdsbrge1_1	DW	300

rdsbe1lo_hi	DB	028h,02,06,04,00,-1
		DW	OFFSET rdsbe1lo-$-2	; 
		DW	OFFSET rdsbe1ft_md-$-2	; 
		DB	-1

rdsbe1ft_md	DB	028h,88,48,76,-1
		DW	OFFSET rdsbe1ft_L-$-2	; 
		DW	OFFSET rdsbe1bk_md-$-2	; 
		DB	-1

rdsbe1ft_L	DB	046h		; GOSUB
		DW	OFFSET rdsbe1ft-$-2
		DB	040h,001h		; IF_lton_rsbe1a
		DW	OFFSET rdsbe1ft_b-$-2	; to ENDIF
		DW	OFFSET THEN_lton_rsbe1a-$-2	; to THEN

rdsbe1bk_md	DB	028h,74,60,66,-1
		DW	OFFSET rdsbe1bk_L-$-2	; 
		DW	OFFSET rdsbe1md-$-2	; 
		DB	-1

rdsbe1bk_L	DB	046h		; GOSUB
		DW	OFFSET rdsbe1bk-$-2
		DB	040h,001h		; IF_lton_rsbe1b
		DW	OFFSET rdsbe1bk_b-$-2	; to ENDIF
		DW	OFFSET THEN_lton_rsbe1b-$-2	; to THEN


rdsbe1lo	LABEL	BYTE
		DB	009h,COL_GREY4,122,124,126,120,-1	; face 36
		DB	008h,COL_GREY4,28,14,12,30,-1		; face 35
		DB	008h,COL_GREY4,24,10,08,26,-1		; face 36
		DB	008h,COL_GREY3,20,28,30,18,-1		; face 3
		DB	008h,COL_GREY3,16,24,26,22,-1		; face 4
		DB	008h,COL_GREY1,18,30,24,16,-1		; face 5
		DB	008h,COL_GREY1,22,26,28,20,-1		; face 6
		DB	008h,COL_GREY2,02,10,12,06,-1		; face 1
		DB	008h,COL_GREY2,74,02,06,66,-1		; face 30
		DB	006h,5,COL_GREY1,COL_GREY1,06,02,-1	; line 27
		DB	008h,COL_GREY2,08,00,04,14,-1		; face 2
		DB	008h,COL_GREY2,00,76,88,04,-1		; face 31
		DB	006h,5,COL_GREY1,COL_GREY1,00,04,-1	; line 28
		DB	008h,COL_ROAD1,88,76,74,66,-1		; face 29
		DB	-1

rdsbe1ft	LABEL	BYTE
		DB	008h,COL_NEW_GREY1,54,38,32,48,-1	; face 18
		DB	00Ah,COL_NEW_GREY2,88,52,118,84,116,86,114,134,112,-1	; line 34
		DB	00Ah,COL_NEW_GREY2,76,48,106,108,78,110,80,132,82,-1	; line 34
		DB	008h,COL_NEW_GREY2,52,36,38,54,-1	; face 14
		DB	008h,COL_WHITE1,54,48,52,-1		; face 27
		DB	-1

THEN_lton_rsbe1a	LABEL	BYTE
		DB	00Ah,COL_NT_RED1,136,136,-1		; line 37
		DB	-1

rdsbe1ft_b	LABEL	BYTE
		DB	-1

rdsbe1bk	LABEL	BYTE
		DB	008h,COL_NEW_GREY1,58,42,44,60,-1	; face 17
		DB	00Ah,COL_NEW_GREY2,66,60,90,68,92,64,94,130,96,-1	; line 35
		DB	00Ah,COL_NEW_GREY2,74,56,104,72,102,70,100,128,98,-1	; line 36
		DB	008h,COL_NEW_GREY2,56,40,42,58,-1	; face 16
		DB	008h,COL_WHITE1,58,60,56,-1		; face 30
		DB	-1

THEN_lton_rsbe1b	LABEL	BYTE
		DB	00Ah,COL_NT_RED1,138,138,-1		; line 38
		DB	-1

rdsbe1bk_b	LABEL	BYTE
		DB	-1

rdsbe1md	LABEL	BYTE
		DB	008h,COL_NEW_GREY1,62,46,40,56,-1	; face 19
		DB	008h,COL_NEW_GREY1,50,34,36,52,-1	; face 20
		DB	008h,COL_NEW_GREY2,60,44,46,62,-1	; face 13
		DB	008h,COL_NEW_GREY2,48,32,34,50,-1	; face 15
		DB	008h,COL_GREY1,50,52,48,-1		; face 28
		DB	008h,COL_GREY1,62,56,60,-1		; face 29
		DB	-1

		EVEN

rdsbrge2	OBJECTHEADER <OBJ_SCALE2,4000,rdsbrge3,0,COL_BLACK1,16,4,16>
		DB	032,056,072	;   0
		DB	032,072,072	;   1
		DB	096,056,072	;   2
		DB	096,072,072	;   3
		DB	032,058,070	;   4
		DB	032,070,070	;   5
		DB	096,070,070	;   6
		DB	096,058,070	;   7
		DB	064,070,064	;   8
		DB	064,058,064	;   9
		DB	064,070,070	;  10
		DB	064,058,070	;  11
		DB	064,058,072	;  12
		DB	064,070,072	;  13
		DB	064,058,096	;  14
		DB	064,070,096	;  15
		DB	064,070,086	;  16
		DB	096,070,072	;  17
		DB	064,070,090	;  18
		DB	032,070,072	;  19
		DB	032,058,072	;  20
		DB	046,058,072	;  21
		DB	054,058,072	;  22
		DB	060,058,072	;  23
		DB	064,058,090	;  24
		DB	064,058,086	;  25
		DB	096,058,072	;  26
		DB	090,070,072	;  27
		DB	082,070,072	;  28
		DB	074,070,072	;  29
		DB	068,070,072	;  30
		DB	060,070,072	;  31
		DB	054,070,072	;  32
		DB	046,070,072	;  33
		DB	038,070,072	;  34
		DB	038,058,072	;  35
		DB	068,058,072	;  36
		DB	074,058,072	;  37
		DB	082,058,072	;  38
		DB	090,058,072	;  39
		DB	032,056,064	;  40
		DB	032,072,064	;  41
		DB	096,072,064	;  42
		DB	096,056,064	;  43
		DB	064,070,080	;  44
		DB	064,058,080	;  45
		DB	-1

		DW	OFFSET	rdsbrge2_1

		EVEN

rdsbrge2_1	DW	205

rdsbe2lo_hi	DB	028h,02,06,04,00,-1
		DW	OFFSET rdsbe2lo-$-2	; 
		DW	OFFSET rdsbe2ft_md-$-2	; 
		DB	-1

rdsbe2ft_md	DB	028h,52,28,40,-1
		DW	OFFSET rdsbe2ft_L-$-2	; 
		DW	OFFSET rdsbe2bk_md-$-2	; 
		DB	-1

rdsbe2ft_L	DB	046h		; GOSUB
		DW	OFFSET rdsbe2ft-$-2
		DB	040h,001h		; IF_lton_rsbe2a
		DW	OFFSET rdsbe2ft_b-$-2	; to ENDIF
		DW	OFFSET THEN_lton_rsbe2a-$-2	; to THEN

rdsbe2bk_md	DB	028h,38,30,34,-1
		DW	OFFSET rdsbe2bk_L-$-2	; 
		DW	OFFSET rdsbe2md-$-2	; 
		DB	-1

rdsbe2bk_L	DB	046h		; GOSUB
		DW	OFFSET rdsbe2bk-$-2
		DB	040h,001h		; IF_lton_rsbe2b
		DW	OFFSET rdsbe2bk_b-$-2	; to ENDIF
		DW	OFFSET THEN_lton_rsbe2b-$-2	; to THEN


rdsbe2lo	LABEL	BYTE
		DB	009h,COL_GREY4,82,84,86,80,-1		; face 36
		DB	008h,COL_GREY4,08,14,12,10,-1		; face 27
		DB	008h,COL_GREY3,18,22,20,16,-1		; face 3
		DB	008h,COL_GREY3,16,20,22,18,-1		; face 4
		DB	00Ah,COL_GREY1,16,20,-1			; face 5
		DB	00Ah,COL_GREY1,18,22,-1			; face 6
		DB	008h,COL_GREY2,02,10,12,06,-1		; face 1
		DB	008h,COL_ROAD1,02,06,04,00,-1		; face 29
		DB	006h,5,COL_GREY1,COL_GREY1,06,02,-1	; line 27
		DB	006h,5,COL_GREY1,COL_GREY1,00,04,-1	; line 28
		DB	008h,COL_GREY2,08,00,04,14,-1		; face 2
		DB	-1

rdsbe2ft	LABEL	BYTE
		DB	00Ah,COL_NEW_GREY2,52,28,78,48,76,50,74,90,72,-1	; line 34
		DB	00Ah,COL_NEW_GREY2,40,28,70,48,42,50,44,90,46,-1	; line 34
		DB	00Ah,COL_NEW_GREY1,28,24,-1		; face 15
		DB	-1

THEN_lton_rsbe2a	LABEL	BYTE
		DB	00Ah,COL_NT_RED1,28,28,-1		; line 31
		DB	-1

rdsbe2ft_b	LABEL	BYTE
		DB	-1

rdsbe2bk	LABEL	BYTE
		DB	00Ah,COL_NEW_GREY2,34,30,54,36,56,32,58,88,60,-1	; line 35
		DB	00Ah,COL_NEW_GREY2,38,30,68,36,66,32,64,88,62,-1	; line 36
		DB	00Ah,COL_NEW_GREY1,30,26,-1		; face 19
		DB	-1

THEN_lton_rsbe2b	LABEL	BYTE
		DB	00Ah,COL_NT_RED1,30,30,-1		; line 32
		DB	-1

rdsbe2bk_b	LABEL	BYTE
		DB	-1

rdsbe2md	LABEL	BYTE
		DB	-1

		EVEN

rdsbrge3	OBJECTHEADER <OBJ_SCALE1,16384,-1,1,COL_BLACK1,8,2,8>
		DB	048,060,068	;   0
		DB	048,068,068	;   1
		DB	080,060,068	;   2
		DB	080,068,068	;   3
		DB	048,062,066	;   4
		DB	048,066,066	;   5
		DB	080,066,066	;   6
		DB	080,062,066	;   7
		DB	064,066,064	;   8
		DB	064,062,064	;   9
		DB	064,066,066	;  10
		DB	064,062,066	;  11
		DB	064,062,068	;  12
		DB	064,066,068	;  13
		DB	064,062,080	;  14
		DB	064,066,080	;  15
		DB	080,066,068	;  16
		DB	048,066,068	;  17
		DB	048,062,068	;  18
		DB	080,062,068	;  19
		DB	048,060,064	;  20
		DB	048,068,064	;  21
		DB	080,068,064	;  22
		DB	080,060,064	;  23
		DB	-1

		DW	OFFSET	rdsbrge3_1

		EVEN

rdsbrge3_1	DW	177

rsbe1lo_hi3	DB	028h,02,06,04,00,-1
		DW	OFFSET rsbe1lo3_L-$-2	; 
		DW	OFFSET rsbe1bk_cn3-$-2	; 
		DB	-1

rsbe1lo3_L	DB	046h		; GOSUB
		DW	OFFSET rsbe1lo3-$-2
		DB	040h,001h		; IF_lton_rsbe3a
		DW	OFFSET rsbe1lo3_b-$-2	; to ENDIF
		DW	OFFSET THEN_lton_rsbe3a-$-2	; to THEN

rsbe1bk_cn3	DB	028h,10,30,12,-1
		DW	OFFSET rsbe1hibk3-$-2	; 
		DW	OFFSET rsbe1ft_cn3-$-2	; 
		DB	-1

rsbe1ft_cn3	DB	028h,14,28,08,-1
		DW	OFFSET rsbe1hift3-$-2	; 
		DW	OFFSET rsbe1hicn3_L-$-2	; 
		DB	-1

rsbe1hicn3_L	DB	046h		; GOSUB
		DW	OFFSET rsbe1hicn3-$-2
		DB	040h,001h		; IF_lton_rsbe3b
		DW	OFFSET rsbe1hicn3_b-$-2	; to ENDIF
		DW	OFFSET THEN_lton_rsbe3b-$-2	; to THEN


rsbe1lo3	LABEL	BYTE
		DB	009h,COL_GREY3,42,44,46,40,-1		; face 36
		DB	008h,COL_GREY4,08,14,12,10,-1		; face 25
		DB	008h,COL_GREY3,18,22,20,16,-1		; face 3
		DB	008h,COL_GREY3,16,20,22,18,-1		; face 4
		DB	008h,COL_GREY2,02,10,12,06,-1		; face 1
		DB	002h,4,COL_GREY1,16,20,-1		; face 5
		DB	008h,COL_ROAD1,02,06,04,00,-1		; face 27
		DB	006h,5,COL_GREY1,COL_GREY1,06,02,-1	; line 27
		DB	006h,5,COL_GREY1,COL_GREY1,00,04,-1	; line 28
		DB	008h,COL_GREY2,08,00,04,14,-1		; face 2
		DB	00Dh,COL_NEW_GREY2,COL_NEW_GREY2,36,28,38,-1	; face 25
		DB	006h,5,COL_GREY1,COL_GREY1,28,24,-1	; face 15
		DB	-1

THEN_lton_rsbe3a	LABEL	BYTE
		DB	00Ah,COL_NT_RED1,28,28,-1		; line 25
		DB	-1

rsbe1lo3_b	LABEL	BYTE
		DB	002h,4,COL_GREY1,18,22,-1		; face 6
		DB	-1

rsbe1hibk3	LABEL	BYTE
		DB	-1

rsbe1hift3	LABEL	BYTE
		DB	-1

rsbe1hicn3	LABEL	BYTE
		DB	00Dh,COL_NEW_GREY2,COL_NEW_GREY2,32,30,34,-1	; face 24
		DB	006h,5,COL_GREY1,COL_GREY1,30,26,-1	; face 16
		DB	-1

THEN_lton_rsbe3b	LABEL	BYTE
		DB	00Ah,COL_NT_RED1,30,30,-1		; line 28
		DB	-1

rsbe1hicn3_b	LABEL	BYTE
		DB	-1

		EVEN

