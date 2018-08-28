Tornado1	OBJECTHEADER <OBJ_SCALE16,256,Tornado2,0,COL_BLACK1,23,32,18>
		DB	064,124,074	;   0
		DB	068,090,080	;   1
		DB	060,090,080	;   2
		DB	054,090,080	;   3
		DB	074,090,080	;   4
		DB	074,080,080	;   5
		DB	054,080,080	;   6
		DB	050,072,080	;   7
		DB	078,072,080	;   8
		DB	096,036,080	;   9
		DB	032,036,080	;  10
		DB	038,028,080	;  11
		DB	090,028,080	;  12
		DB	072,060,080	;  13
		DB	056,060,080	;  14
		DB	056,052,076	;  15
		DB	072,052,076	;  16
		DB	088,028,076	;  17
		DB	040,028,076	;  18
		DB	088,024,076	;  19
		DB	040,024,076	;  20
		DB	062,082,080	;  21
		DB	064,062,082	;  22
		DB	064,028,080	;  23
		DB	064,024,100	;  24
		DB	064,016,100	;  25
		DB	064,102,082	;  26
		DB	064,048,086	;  27
		DB	066,082,080	;  28
		DB	064,082,082	;  29
		DB	066,110,078	;  30
		DB	062,110,078	;  31
		DB	060,110,076	;  32
		DB	068,110,076	;  33
		DB	064,120,076	;  34
		DB	066,120,074	;  35
		DB	060,080,072	;  36
		DB	068,080,072	;  37
		DB	054,084,074	;  38
		DB	060,084,074	;  39
		DB	068,084,074	;  40
		DB	074,084,074	;  41
		DB	060,080,080	;  42
		DB	068,080,080	;  43
		DB	074,080,074	;  44
		DB	054,080,074	;  45
		DB	060,080,074	;  46
		DB	068,080,074	;  47
		DB	072,064,072	;  48
		DB	056,064,072	;  49
		DB	062,052,080	;  50
		DB	066,052,080	;  51
		DB	060,028,078	;  52
		DB	062,028,078	;  53
		DB	066,028,078	;  54
		DB	068,028,078	;  55
		DB	060,028,074	;  56
		DB	062,028,074	;  57
		DB	066,028,074	;  58
		DB	068,028,074	;  59
		DB	064,028,076	;  60
		DB	058,028,076	;  61
		DB	070,028,076	;  62
		DB	072,052,072	;  63
		DB	056,052,072	;  64
		DB	064,030,078	;  65
		DB	060,110,072	;  66
		DB	068,110,072	;  67
		DB	056,064,080	;  68
		DB	072,064,080	;  69
		DB	056,064,074	;  70
		DB	072,064,074	;  71
		DB	064,128,074	;  72
		DB	056,052,080	;  73
		DB	072,052,080	;  74
		DB	062,120,074	;  75
		DB	060,030,078	;  76
		DB	068,030,078	;  77
		DB	110,052,080	;  78
		DB	018,052,080	;  79
		DB	022,062,080	;  80
		DB	106,062,080	;  81
		DB	056,054,080	;  82
		DB	072,054,080	;  83
		DB	062,098,080	;  84
		DB	066,098,080	;  85
		DB	064,120,072	;  86
		DB	024,048,080	;  87
		DB	104,048,080	;  88
		DB	026,038,080	;  89
		DB	102,038,080	;  90
		DB	056,058,080	;  91
		DB	072,058,080	;  92
		DB	054,064,064	;  93
		DB	054,062,066	;  94
		DB	054,066,066	;  95
		DB	054,064,068	;  96
		DB	074,064,068	;  97
		DB	074,066,066	;  98
		DB	074,064,064	;  99
		DB	074,062,066	; 100
		DB	064,100,068	; 101
		DB	064,098,066	; 102
		DB	064,100,064	; 103
		DB	064,102,066	; 104
		DB	064,100,072	; 105
		DB	054,064,074	; 106
		DB	054,080,070	; 107
		DB	052,080,070	; 108
		DB	054,064,072	; 109
		DB	074,064,074	; 110
		DB	074,064,072	; 111
		DB	074,080,070	; 112
		DB	076,080,070	; 113
		DB	056,064,070	; 114
		DB	072,064,070	; 115
		DB	054,064,066	; 116
		DB	074,064,066	; 117
		DB	066,102,072	; 118
		DB	066,108,072	; 119
		DB	062,108,072	; 120
		DB	062,102,072	; 121
		DB	062,108,070	; 122
		DB	062,102,070	; 123
		DB	066,108,070	; 124
		DB	066,102,070	; 125
		DB	-1

		DW	OFFSET	Tornado1_1

		EVEN

Tornado1_1	DW	1004

trn1mid_lo	DB	028h,172,128,126,-1
		DW	OFFSET trn1mid_lf-$-2	; 
		DW	OFFSET trn1lo_L-$-2	; 
		DB	-1

trn1mid_lf	DB	028h,64,104,112,132,-1
		DW	OFFSET trn1mid_rt-$-2	; 
		DW	OFFSET trn1lfhi_lo-$-2	; 
		DB	-1

trn1mid_rt	DB	028h,110,66,134,118,-1
		DW	OFFSET trn1midbk_ft-$-2	; 
		DW	OFFSET trn1rthi_lo-$-2	; 
		DB	-1

trn1midbk_ft	DB	028h,12,216,226,10,-1
		DW	OFFSET trn1fin_mdbklf-$-2	; 
		DW	OFFSET trn1midft_L-$-2	; 
		DB	-1

trn1fin_mdbklf	DB	028h,52,48,120,206,-1
		DW	OFFSET trn1fin_mdbkrt-$-2	; 
		DW	OFFSET trn1midbklf_L-$-2	; 
		DB	-1

trn1fin_mdbkrt	DB	028h,120,48,52,206,-1
		DW	OFFSET trn1fin-$-2	; 
		DW	OFFSET trn1midbkrt_L-$-2	; 
		DB	-1

trn1midbkrt_L	DB	046h		; GOSUB
		DW	OFFSET trn1midbkrt-$-2
		DB	042h,010h		; IF_rht_rt_trn1
		DW	OFFSET trn1midbkrt_b-$-2	; to ENDIF
		DW	OFFSET rhtr_trn1-$-2	; to THEN
		DW	OFFSET dryr_trn1-$-2	; to ELSE

trn1midbklf_L	DB	046h		; GOSUB
		DW	OFFSET trn1midbklf-$-2
		DB	042h,008h		; IF_rhtl_trn1
		DW	OFFSET trn1midbklf_b-$-2	; to ENDIF
		DW	OFFSET THEN_rhtl_trn1-$-2	; to THEN
		DW	OFFSET ELSE_rhtl_trn1-$-2	; to ELSE

trn1midft_L	DB	046h		; GOSUB
		DW	OFFSET trn1midft-$-2
		DB	040h,004h		; IF_geardown_29
		DW	OFFSET trn1midft_b-$-2	; to ENDIF
		DW	OFFSET THEN_gdn_30-$-2	; to THEN

trn1rthi_lo	DB	028h,82,144,76,114,-1
		DW	OFFSET trn1rthi_L-$-2	; 
		DW	OFFSET trn1rtloin_out-$-2	; 
		DB	-1

trn1rthi_L	DB	046h		; GOSUB
		DW	OFFSET trn1rthi-$-2
		DB	044h,003h,000h		; SELECT sweep
		DW	OFFSET trn1rthi_b_L-$-2	; to ENDSELECT
		DW	OFFSET CASE1_12trn1-$-2	; to CASE
		DW	OFFSET CASE2_13trn1-$-2	; to CASE
		DW	OFFSET CASE3_14trn1-$-2	; to CASE

trn1rthi_b_L	DB	046h		; GOSUB
		DW	OFFSET trn1rthi_b-$-2
		DB	040h,004h		; IF_geardown_32
		DW	OFFSET trn1rthi_b_b-$-2	; to ENDIF
		DW	OFFSET THEN_33_trn1-$-2	; to THEN

trn1rtloin_out	DB	028h,142,88,224,-1
		DW	OFFSET trn1rtloin_L-$-2	; 
		DW	OFFSET trn1rtloout_L-$-2	; 
		DB	-1

trn1rtloin_L	DB	046h		; GOSUB
		DW	OFFSET trn1rtloin-$-2
		DB	040h,004h		; IF_geardown_35
		DW	OFFSET trn1rtloin_b-$-2	; to ENDIF
		DW	OFFSET THEN_36_trn1-$-2	; to THEN

trn1rtloout_L	DB	046h		; GOSUB
		DW	OFFSET trn1rtloout-$-2
		DB	040h,004h		; IF_geardown_38
		DW	OFFSET trn1rtloout_b-$-2	; to ENDIF
		DW	OFFSET THEN_39_trn1-$-2	; to THEN

trn1lfhi_lo	DB	028h,82,144,76,114,-1
		DW	OFFSET trn1lfhi_L-$-2	; 
		DW	OFFSET trn1lfloin_out-$-2	; 
		DB	-1

trn1lfhi_L	DB	046h		; GOSUB
		DW	OFFSET trn1lfhi-$-2
		DB	044h,003h,000h		; SELECT sweep
		DW	OFFSET trn1lfhi_b_L-$-2	; to ENDSELECT
		DW	OFFSET CASE1_17_trn1-$-2	; to CASE
		DW	OFFSET CASE2_18_trn1-$-2	; to CASE
		DW	OFFSET CASE3_19_trn1-$-2	; to CASE

trn1lfhi_b_L	DB	046h		; GOSUB
		DW	OFFSET trn1lfhi_b-$-2
		DB	040h,004h		; IF_geardown_41
		DW	OFFSET trn1lfhi_b_b-$-2	; to ENDIF
		DW	OFFSET THEN_42_trn1-$-2	; to THEN

trn1lfloin_out	DB	028h,214,90,140,-1
		DW	OFFSET trn1lfloin_L-$-2	; 
		DW	OFFSET trn1lfloout_L-$-2	; 
		DB	-1

trn1lfloin_L	DB	046h		; GOSUB
		DW	OFFSET trn1lfloin-$-2
		DB	040h,004h		; IF_geardown_44
		DW	OFFSET trn1lfloin_b-$-2	; to ENDIF
		DW	OFFSET THEN_45_trn1-$-2	; to THEN

trn1lfloout_L	DB	046h		; GOSUB
		DW	OFFSET trn1lfloout-$-2
		DB	040h,004h		; IF_geardown_47
		DW	OFFSET trn1lfloout_b-$-2	; to ENDIF
		DW	OFFSET THEN_48_trn1-$-2	; to THEN

trn1lo_L	DB	046h		; GOSUB
		DW	OFFSET trn1lo-$-2
		DB	040h,004h		; IF_geardown_50
		DW	OFFSET trn1lo_b-$-2	; to ENDIF
		DW	OFFSET THEN_51_trn1-$-2	; to THEN


trn1fin		LABEL	BYTE
		DB	00Ch,COL_OLIVE4,COL_OLIVE4,44,46,130,-1	; face 71
		DB	00Ch,COL_OLIVE3,COL_OLIVE3,44,54,46,-1	; face 72
		DB	00Ch,COL_OLIVE3,COL_OLIVE3,54,48,50,46,-1	; face 73
		DB	008h,COL_GREY2,114,120,116,-1		; crease lo
		DB	008h,COL_OLIVE2,98,128,126,96,74,72,-1	; face 105
		DB	008h,COL_OLIVE2,118,126,128,112,-1	; fuslg aft und
		DB	-1

trn1midbkrt	LABEL	BYTE
		DB	008h,COL_OLIVE2,138,148,102,56,86,-1	; face 105
		DB	008h,COL_OLIVE4,44,102,130,-1		; face 66
		DB	008h,COL_OLIVE4,56,102,44,58,-1		; fwd spine upr
		DB	008h,COL_GREY2,130,108,120,-1		; crease rt
		DB	008h,COL_GREY1,130,154,110,108,-1	; face 82
		DB	-1

rhtr_trn1	LABEL	BYTE
		DB	008h,COL_NT_AMBER1,110,124,118,116,120,108,-1	; exfc afb rt
		DB	-1

dryr_trn1	LABEL	BYTE
		DB	008h,COL_GREY4,110,124,118,116,120,108,-1	; exhst face rt
		DB	-1

trn1midbkrt_b	LABEL	BYTE
		DB	008h,COL_OLIVE2,148,154,130,102,-1	; face 64
		DB	008h,COL_OLIVE3,148,124,154,-1		; face 69
		DB	008h,COL_OLIVE4,148,32,124,-1		; face 68
		DB	008h,COL_GREY2,124,110,154,-1		; face 75
		DB	008h,COL_OLIVE4,124,32,126,-1		; face 77
		DB	008h,COL_OLIVE3,118,124,126,-1		; face 76
		DB	008h,COL_OLIVE4,148,138,96,126,-1	; face 73
		DB	-1

trn1midbklf	LABEL	BYTE
		DB	008h,COL_OLIVE2,42,100,146,136,84,-1	; face 105
		DB	008h,COL_OLIVE4,44,130,100,-1		; face 65
		DB	008h,COL_OLIVE4,58,44,100,42,-1		; fwd spine upl
		DB	008h,COL_GREY2,130,120,106,-1		; crease lf
		DB	008h,COL_GREY1,104,152,130,106,-1	; face 82
		DB	008h,COL_OLIVE3,146,152,122,-1		; face 70
		DB	008h,COL_OLIVE4,146,122,30,-1		; face 67
		DB	008h,COL_GREY2,152,104,122,-1		; face 73
		DB	008h,COL_OLIVE3,128,122,112,-1		; face 75
		DB	008h,COL_OLIVE4,128,30,122,-1		; face 76
		DB	008h,COL_OLIVE4,136,146,128,98,-1	; face 73
		DB	-1

THEN_rhtl_trn1	LABEL	BYTE
		DB	008h,COL_NT_AMBER1,112,122,104,106,120,114,-1	; exfc afb lf
		DB	-1

ELSE_rhtl_trn1	LABEL	BYTE
		DB	008h,COL_GREY4,106,120,114,112,122,104,-1	; exhst face lf
		DB	-1

trn1midbklf_b	LABEL	BYTE
		DB	008h,COL_OLIVE2,100,130,152,146,-1	; face 63
		DB	-1

trn1midft	LABEL	BYTE
		DB	008h,COL_OLIVE2,42,84,62,-1		; face 75
		DB	008h,COL_OLIVE2,60,86,56,-1		; face 75
		DB	008h,COL_OLIVE5,60,56,170,-1		; face 78
		DB	008h,COL_OLIVE5,42,62,168,-1		; face 77
		DB	00Ah,COL_BLACK1,00,144,-1		; line 78
		DB	008h,COL_OLIVE3,64,62,84,-1		; face 76
		DB	008h,COL_OLIVE3,60,66,86,-1		; face 76
		DB	008h,COL_GREY2,68,60,62,-1		; face 77
		DB	008h,COL_GREY2,68,70,66,60,-1		; face 76
		DB	008h,COL_GREY2,68,62,64,150,-1		; face 75
		DB	008h,COL_DK_CYAN2,60,170,52,-1		; face 76
		DB	008h,COL_DK_CYAN2,62,52,168,-1		; face 75
		DB	008h,COL_DK_CYAN3,170,56,58,52,-1	; face 74
		DB	008h,COL_DK_CYAN3,52,58,42,168,-1	; face 73
		DB	008h,COL_DK_CYAN1,60,52,62,-1		; canopy frnt
		DB	008h,COL_GREY2,00,68,150,-1		; face 79
		DB	008h,COL_GREY2,68,00,70,-1		; face 80
		DB	008h,COL_OLIVE4,86,66,134,74,-1		; fuslg sidert
		DB	008h,COL_OLIVE4,64,84,72,132,-1		; face 82
		DB	008h,COL_GREY3,150,64,132,-1		; face 77
		DB	008h,COL_GREY3,134,66,70,-1		; face 78
		DB	008h,COL_GREY3,134,172,132,-1		; face 79
		DB	008h,COL_GREY3,70,00,172,134,-1		; face 78
		DB	008h,COL_GREY3,172,00,150,132,-1	; face 77
		DB	008h,COL_OLIVE2,74,134,132,72,-1	; face 78
		DB	-1

THEN_gdn_30	LABEL	BYTE
		DB	008h,COL_GREY4,236,238,240,242,210,-1	; U/C nose well intr
		DB	-1

trn1midft_b	LABEL	BYTE
		DB	-1

trn1rthi	LABEL	BYTE
		DB	008h,COL_OLIVE4,138,10,88,142,-1	; face 81
		DB	008h,COL_OLIVE4,88,10,08,82,-1		; face 42
		DB	008h,COL_OLIVE2,86,02,08,10,138,-1	; face 105
		DB	002h,4,COL_OLIVE3,10,86,-1		; line 84
		DB	00Ch,COL_OLIVE3,COL_OLIVE3,16,138,10,-1	; rt wing glove
		DB	-1

CASE1_12trn1	LABEL	BYTE
		DB	00Ch,COL_OLIVE2,COL_OLIVE2,138,16,162,156,26,-1	; WING rt 25
		DB	-1

CASE2_13trn1	LABEL	BYTE
		DB	00Ch,COL_OLIVE2,COL_OLIVE2,180,184,138,16,176,-1	; WING rt 45
		DB	-1

CASE3_14trn1	LABEL	BYTE
		DB	00Ch,COL_OLIVE2,COL_OLIVE2,18,24,166,138,16,-1	; WING rt 67
		DB	-1

trn1rthi_b	LABEL	BYTE
		DB	008h,COL_OLIVE3,82,80,94,142,88,-1	; face 78
		DB	-1

THEN_33_trn1	LABEL	BYTE
		DB	008h,COL_GREY4,142,88,94,-1		; U/C rt well upper
		DB	-1

trn1rthi_b_b	LABEL	BYTE
		DB	00Ch,COL_OLIVE2,COL_OLIVE2,34,38,124,32,-1	; rt stabilator
		DB	008h,COL_GREY4,08,02,80,82,-1		; intake face rt
		DB	-1

trn1rtloin	LABEL	BYTE
		DB	008h,COL_OLIVE4,142,94,74,96,-1		; geardoor face rt
		DB	-1

THEN_36_trn1	LABEL	BYTE
		DB	00Ch,COL_GREY4,COL_GREY4,194,196,198,200,-1	; U/C rt mainwheel
		DB	006h,7,COL_GREY2,COL_GREY4,230,234,96,230,-1	; U/C rt main leg
		DB	00Ch,COL_OLIVE3,COL_GREY3,142,88,224,-1	; U/C rt maindoor ex
		DB	-1

trn1rtloin_b	LABEL	BYTE
		DB	-1

trn1rtloout	LABEL	BYTE
		DB	-1

THEN_39_trn1	LABEL	BYTE
		DB	00Ch,COL_OLIVE4,COL_GREY2,142,224,226,220,-1	; U/C rt maindoor ex
		DB	00Ch,COL_OLIVE2,COL_GREY3,226,222,220,-1	; U/C rt maindoor ex
		DB	-1

trn1rtloout_b	LABEL	BYTE
		DB	-1

trn1lfhi	LABEL	BYTE
		DB	008h,COL_OLIVE4,12,136,140,90,-1	; face 76
		DB	008h,COL_OLIVE4,06,12,90,76,-1		; face 41
		DB	00Ch,COL_OLIVE3,COL_OLIVE3,12,136,14,-1	; lf wing glove
		DB	-1

CASE1_17_trn1	LABEL	BYTE
		DB	00Ch,COL_OLIVE2,COL_OLIVE2,28,158,160,14,136,-1	; WING lf 25
		DB	-1

CASE2_18_trn1	LABEL	BYTE
		DB	00Ch,COL_OLIVE2,COL_OLIVE2,182,178,174,14,136,-1	; WING lf 45
		DB	-1

CASE3_19_trn1	LABEL	BYTE
		DB	00Ch,COL_OLIVE2,COL_OLIVE2,164,22,20,14,136,-1	; WING lf 67
		DB	-1

trn1lfhi_b	LABEL	BYTE
		DB	008h,COL_OLIVE2,12,06,04,84,136,-1	; face 105
		DB	002h,4,COL_OLIVE3,84,12,-1		; line 85
		DB	00Ch,COL_OLIVE2,COL_OLIVE2,122,40,36,30,-1	; lf stabilator
		DB	008h,COL_OLIVE3,78,76,90,140,92,-1	; face 75
		DB	-1

THEN_42_trn1	LABEL	BYTE
		DB	008h,COL_GREY4,92,90,140,-1		; U/C lf well upper
		DB	-1

trn1lfhi_b_b	LABEL	BYTE
		DB	008h,COL_GREY4,04,06,76,78,-1		; intake face left
		DB	-1

trn1lfloin	LABEL	BYTE
		DB	008h,COL_OLIVE4,92,140,98,72,-1		; geardoor face lf
		DB	-1

THEN_45_trn1	LABEL	BYTE
		DB	00Ch,COL_GREY4,COL_GREY4,192,188,186,190,-1	; U/C lf main wheel
		DB	006h,7,COL_GREY2,COL_GREY4,232,228,98,232,-1	; U/C lf main leg
		DB	00Ch,COL_OLIVE3,COL_GREY3,214,90,140,-1	; U/C lf maindoor
		DB	-1

trn1lfloin_b	LABEL	BYTE
		DB	-1

trn1lfloout	LABEL	BYTE
		DB	-1

THEN_48_trn1	LABEL	BYTE
		DB	00Ch,COL_OLIVE4,COL_GREY2,212,216,214,140,-1	; U/C lf maindoor
		DB	00Ch,COL_OLIVE2,COL_GREY3,216,212,218,-1	; U/C lf maindoor
		DB	-1

trn1lfloout_b	LABEL	BYTE
		DB	-1

trn1lo		LABEL	BYTE
		DB	-1

THEN_51_trn1	LABEL	BYTE
		DB	00Ch,COL_GREY4,COL_GREY4,202,204,206,208,-1	; U/C nosewheel
		DB	006h,5,COL_GREY2,COL_GREY2,202,210,-1	; U/C nose leg
		DB	00Ch,COL_OLIVE3,COL_GREY2,240,242,246,244,-1	; U/C nose door lf
		DB	00Ch,COL_OLIVE3,COL_GREY2,238,248,250,236,-1	; U/C nose door rt
		DB	-1

trn1lo_b	LABEL	BYTE
		DB	-1

		EVEN

Tornado2	OBJECTHEADER <OBJ_SCALE8,512,Tornado3,0,COL_BLACK1,11,16,9>
		DB	064,094,068	;   0
		DB	066,076,072	;   1
		DB	062,076,072	;   2
		DB	060,076,072	;   3
		DB	068,076,072	;   4
		DB	068,072,072	;   5
		DB	060,072,072	;   6
		DB	058,068,072	;   7
		DB	070,068,072	;   8
		DB	080,050,072	;   9
		DB	048,050,072	;  10
		DB	052,046,072	;  11
		DB	076,046,072	;  12
		DB	068,062,072	;  13
		DB	060,062,072	;  14
		DB	060,058,070	;  15
		DB	068,058,070	;  16
		DB	076,046,070	;  17
		DB	052,046,070	;  18
		DB	076,044,070	;  19
		DB	052,044,070	;  20
		DB	064,072,072	;  21
		DB	064,064,072	;  22
		DB	064,046,072	;  23
		DB	064,044,082	;  24
		DB	064,040,082	;  25
		DB	064,082,072	;  26
		DB	064,056,074	;  27
		DB	064,086,070	;  28
		DB	062,086,070	;  29
		DB	066,086,070	;  30
		DB	064,092,070	;  31
		DB	062,072,068	;  32
		DB	066,072,068	;  33
		DB	060,074,068	;  34
		DB	062,074,068	;  35
		DB	066,074,068	;  36
		DB	068,074,068	;  37
		DB	062,072,072	;  38
		DB	066,072,072	;  39
		DB	068,072,068	;  40
		DB	060,072,068	;  41
		DB	068,064,068	;  42
		DB	060,064,068	;  43
		DB	064,058,072	;  44
		DB	062,046,070	;  45
		DB	064,046,070	;  46
		DB	066,046,070	;  47
		DB	062,046,068	;  48
		DB	064,046,068	;  49
		DB	066,046,068	;  50
		DB	068,058,068	;  51
		DB	060,058,068	;  52
		DB	064,048,070	;  53
		DB	062,086,068	;  54
		DB	066,086,068	;  55
		DB	060,064,072	;  56
		DB	068,064,072	;  57
		DB	064,096,068	;  58
		DB	060,058,072	;  59
		DB	068,058,072	;  60
		DB	062,048,070	;  61
		DB	066,048,070	;  62
		DB	086,058,072	;  63
		DB	042,058,072	;  64
		DB	044,064,072	;  65
		DB	084,064,072	;  66
		DB	060,060,072	;  67
		DB	068,060,072	;  68
		DB	044,056,072	;  69
		DB	084,056,072	;  70
		DB	046,052,072	;  71
		DB	082,052,072	;  72
		DB	060,064,064	;  73
		DB	060,064,066	;  74
		DB	068,064,066	;  75
		DB	068,064,064	;  76
		DB	064,082,066	;  77
		DB	064,080,064	;  78
		DB	064,082,064	;  79
		DB	064,082,068	;  80
		DB	060,072,066	;  81
		DB	058,072,066	;  82
		DB	068,072,066	;  83
		DB	070,072,066	;  84
		DB	064,086,068	;  85
		DB	064,086,066	;  86
		DB	-1

		DW	OFFSET	Tornado2_1

		EVEN

Tornado2_1	DW	614

trn2md_hi	DB	028h,128,52,126,46,-1
		DW	OFFSET trn2wpl_md-$-2	; 
		DW	OFFSET trn2hi-$-2	; 
		DB	-1

trn2wpl_md	DB	028h,126,52,128,46,-1
		DW	OFFSET trn2wpl_L-$-2	; 
		DW	OFFSET trn2md_lo-$-2	; 
		DB	-1

trn2wpl_L	DB	046h		; GOSUB
		DW	OFFSET trn2wpl-$-2
		DB	044h,003h,000h		; SELECT sweep
		DW	OFFSET trn2wpl_b-$-2	; to ENDSELECT
		DW	OFFSET CASE1_5-$-2	; to CASE
		DW	OFFSET CASE2_6-$-2	; to CASE
		DW	OFFSET CASE3_7-$-2	; to CASE

trn2md_lo	DB	028h,82,96,100,80,-1
		DW	OFFSET trn2md_lf-$-2	; 
		DW	OFFSET trn2lo_L-$-2	; 
		DB	-1

trn2md_lf	DB	028h,58,90,96,108,-1
		DW	OFFSET trn2md_rt-$-2	; 
		DW	OFFSET trn2lf-$-2	; 
		DB	-1

trn2md_rt	DB	028h,94,60,110,100,-1
		DW	OFFSET trn2md_L-$-2	; 
		DW	OFFSET trn2rt-$-2	; 
		DB	-1

trn2md_L	DB	046h		; GOSUB
		DW	OFFSET trn2md-$-2
		DB	042h,008h		; IF_rhtl_trn2
		DW	OFFSET trn2md_b_L-$-2	; to ENDIF
		DW	OFFSET rhtl_trn2-$-2	; to THEN
		DW	OFFSET dryl_trn2-$-2	; to ELSE

trn2md_b_L	DB	046h		; GOSUB
		DW	OFFSET trn2md_b-$-2
		DB	042h,010h		; IF_rht_rt_trn2
		DW	OFFSET trn2md_b_b-$-2	; to ENDIF
		DW	OFFSET rhtr_trn2-$-2	; to THEN
		DW	OFFSET dryr_trn2-$-2	; to ELSE

trn2lo_L	DB	046h		; GOSUB
		DW	OFFSET trn2lo-$-2
		DB	040h,004h		; IF_geardown_11
		DW	OFFSET trn2lo_b-$-2	; to ENDIF
		DW	OFFSET THEN_12b-$-2	; to THEN


trn2wpl		LABEL	BYTE
		DB	008h,COL_OLIVE2,118,12,10,120,-1	; face 71
		DB	002h,4,COL_OLIVE5,42,44,-1		; line 78
		DB	006h,5,COL_DK_CYAN3,COL_DK_CYAN3,42,52,-1	; face 73
		DB	00Ch,COL_OLIVE3,COL_OLIVE3,16,114,10,-1	; rt wing glove
		DB	-1

CASE1_5		LABEL	BYTE
		DB	00Ch,COL_OLIVE2,COL_OLIVE2,114,16,132,126,26,-1	; WING rt 25
		DB	00Ch,COL_OLIVE2,COL_OLIVE2,28,128,130,14,112,-1	; WING lf 25
		DB	-1

CASE2_6		LABEL	BYTE
		DB	00Ch,COL_OLIVE2,COL_OLIVE2,144,26,114,16,140,-1	; WING rt 45
		DB	00Ch,COL_OLIVE2,COL_OLIVE2,28,142,138,14,112,-1	; WING lf 45
		DB	-1

CASE3_7		LABEL	BYTE
		DB	00Ch,COL_OLIVE2,COL_OLIVE2,18,24,136,114,16,-1	; WING rt 67
		DB	00Ch,COL_OLIVE2,COL_OLIVE2,134,22,20,14,112,-1	; WING lf 67
		DB	-1

trn2wpl_b	LABEL	BYTE
		DB	00Ch,COL_OLIVE3,COL_OLIVE3,12,112,14,-1	; lf wing glove
		DB	008h,COL_OLIVE2,04,76,12,06,-1		; face 72
		DB	008h,COL_OLIVE2,08,10,78,02,-1		; face 73
		DB	006h,5,COL_DK_CYAN1,COL_DK_CYAN1,56,52,-1	; canopy frnt
		DB	-1

trn2md		LABEL	BYTE
		DB	008h,COL_GREY2,62,60,58,-1		; face 153
		DB	008h,COL_GREY1,94,90,122,124,-1		; face 68
		DB	008h,COL_OLIVE2,122,118,120,124,-1	; face 69
		DB	-1

rhtl_trn2	LABEL	BYTE
		DB	008h,COL_NT_AMBER1,96,90,92,98,-1	; exfc afb lf
		DB	-1

dryl_trn2	LABEL	BYTE
		DB	008h,COL_GREY4,90,92,98,96,-1		; exhst face lf
		DB	-1

trn2md_b	LABEL	BYTE
		DB	-1

rhtr_trn2	LABEL	BYTE
		DB	008h,COL_NT_AMBER1,98,92,94,100,-1	; exfc afb rt
		DB	-1

dryr_trn2	LABEL	BYTE
		DB	008h,COL_GREY4,92,94,100,98,-1		; exhst face rt
		DB	-1

trn2md_b_b	LABEL	BYTE
		DB	008h,COL_OLIVE3,56,60,78,-1		; face 76
		DB	008h,COL_GREY2,62,00,60,-1		; face 76
		DB	008h,COL_OLIVE4,78,60,110,66,-1		; fuslg sidert
		DB	008h,COL_GREY3,110,60,00,-1		; face 78
		DB	008h,COL_OLIVE3,58,56,76,-1		; face 76
		DB	008h,COL_OLIVE4,58,76,64,108,-1		; face 82
		DB	008h,COL_GREY3,00,58,108,-1		; face 77
		DB	008h,COL_GREY2,00,62,58,-1		; face 153
		DB	008h,COL_OLIVE4,88,46,106,-1		; face 81
		DB	00Ch,COL_OLIVE4,COL_OLIVE4,106,46,88,-1	; face 97
		DB	008h,COL_OLIVE2,56,78,76,-1		; face 72
		DB	004h,6,COL_DK_CYAN2,COL_DK_CYAN2,56,42,52,-1	; face 76
		DB	008h,COL_OLIVE2,104,96,100,102,84,66,64,86,-1	; face 152
		DB	00Ah,COL_BLACK1,00,116,-1		; line 78
		DB	008h,COL_GREY3,110,00,108,-1		; face 79
		DB	008h,COL_OLIVE2,66,110,108,64,-1	; face 78
		DB	-1

trn2rt		LABEL	BYTE
		DB	008h,COL_OLIVE4,124,120,102,-1		; face 95
		DB	008h,COL_OLIVE3,102,100,94,124,-1	; face 95
		DB	008h,COL_OLIVE4,74,102,120,08,-1	; face 73
		DB	00Ch,COL_OLIVE2,COL_OLIVE2,34,38,94,124,32,-1	; rt stab
		DB	008h,COL_GREY4,08,02,72,74,-1		; intake face rt
		DB	008h,COL_OLIVE3,74,72,66,84,-1		; face 78
		DB	002h,4,COL_OLIVE4,84,66,-1		; geardoor face rt
		DB	-1

trn2lf		LABEL	BYTE
		DB	008h,COL_OLIVE4,122,104,118,-1		; face 95
		DB	008h,COL_OLIVE3,90,96,104,122,-1	; face 95
		DB	008h,COL_OLIVE4,06,118,104,68,-1	; face 72
		DB	00Ch,COL_OLIVE2,COL_OLIVE2,122,90,40,36,30,-1	; lf stab
		DB	008h,COL_GREY4,04,06,68,70,-1		; intake face left
		DB	008h,COL_OLIVE3,70,68,86,64,-1		; face 75
		DB	002h,4,COL_OLIVE4,64,86,-1		; geardoor face lf
		DB	-1

trn2lo		LABEL	BYTE
		DB	-1

THEN_12b	LABEL	BYTE
		DB	008h,COL_GREY4,84,80,66,-1		; U/C rt well upper
		DB	008h,COL_GREY4,64,82,86,-1		; U/C lf well upper
		DB	00Ah,COL_GREY2,84,150,-1		; line 83
		DB	00Eh,COL_GREY4,COL_GREY4,148,146,-1	; U/C lf main wheel
		DB	00Ch,COL_OLIVE3,COL_GREY3,162,82,86,-1	; U/C lf maindoor
		DB	00Ch,COL_GREY2,COL_OLIVE4,86,162,164,-1	; face 84
		DB	006h,5,COL_GREY3,COL_OLIVE2,164,86,-1	; U/C lf maindoor
		DB	00Ch,COL_GREY4,COL_GREY4,154,156,158,-1	; U/C nosewheel
		DB	00Ch,COL_OLIVE3,COL_GREY2,170,160,154,172,-1	; U/C nose door lf
		DB	00Ch,COL_OLIVE3,COL_GREY2,170,172,154,160,-1	; U/C nose door rt
		DB	00Ah,COL_GREY2,86,148,-1		; line 84
		DB	00Eh,COL_GREY4,COL_GREY4,150,152,-1	; U/C rt mainwheel
		DB	00Ch,COL_OLIVE3,COL_GREY3,84,80,166,-1	; U/C rt maindoor ex
		DB	00Ch,COL_GREY2,COL_OLIVE4,84,168,166,-1	; U/C rt maindoor
		DB	006h,5,COL_GREY3,COL_OLIVE2,168,84,-1	; U/C rt maindoor ex
		DB	-1

trn2lo_b	LABEL	BYTE
		DB	-1

trn2hi		LABEL	BYTE
		DB	00Ch,COL_OLIVE3,COL_OLIVE3,44,54,46,-1	; face 72
		DB	006h,5,COL_OLIVE5,COL_OLIVE5,44,88,-1	; line 79
		DB	00Ch,COL_OLIVE3,COL_OLIVE3,54,48,50,46,-1	; face 73
		DB	-1

		EVEN

Tornado3	OBJECTHEADER <OBJ_SCALE8,1024,Tornado4,0,COL_BLACK1,11,15,9>
		DB	064,094,068	;   0
		DB	066,076,072	;   1
		DB	062,076,072	;   2
		DB	060,076,072	;   3
		DB	068,076,072	;   4
		DB	068,072,072	;   5
		DB	060,072,072	;   6
		DB	080,050,072	;   7
		DB	048,050,072	;   8
		DB	052,046,072	;   9
		DB	076,046,072	;  10
		DB	064,062,072	;  11
		DB	064,046,072	;  12
		DB	064,046,082	;  13
		DB	064,040,082	;  14
		DB	064,082,072	;  15
		DB	064,072,072	;  16
		DB	062,086,070	;  17
		DB	066,086,070	;  18
		DB	062,072,068	;  19
		DB	066,072,068	;  20
		DB	060,072,068	;  21
		DB	068,072,068	;  22
		DB	062,046,072	;  23
		DB	066,046,072	;  24
		DB	062,046,068	;  25
		DB	066,046,068	;  26
		DB	068,058,068	;  27
		DB	060,058,068	;  28
		DB	062,086,068	;  29
		DB	066,086,068	;  30
		DB	060,058,072	;  31
		DB	068,058,072	;  32
		DB	064,086,070	;  33
		DB	046,052,072	;  34
		DB	082,052,072	;  35
		DB	044,056,072	;  36
		DB	084,056,072	;  37
		DB	042,058,072	;  38
		DB	086,058,072	;  39
		DB	044,064,072	;  40
		DB	084,064,072	;  41
		DB	060,064,072	;  42
		DB	068,064,072	;  43
		DB	064,046,068	;  44
		DB	-1

		DW	OFFSET	Tornado3_1

		EVEN

Tornado3_1	DW	279

trn3_0_L	DB	046h		; GOSUB
		DW	OFFSET trn3_0-$-2
		DB	042h,008h		; IF_rhtl_trn3
		DW	OFFSET trn3_0_b_L-$-2	; to ENDIF
		DW	OFFSET rhtl_trn3-$-2	; to THEN
		DW	OFFSET dryl_trn3-$-2	; to ELSE

trn3_0_b_L	DB	046h		; GOSUB
		DW	OFFSET trn3_0_b-$-2
		DB	042h,010h		; IF_rhtr_trn3
		DW	OFFSET trn3_0_b_b_L-$-2	; to ENDIF
		DW	OFFSET rhtr_trn3-$-2	; to THEN
		DW	OFFSET dryr_trn3-$-2	; to ELSE

trn3_0_b_b_L	DB	046h		; GOSUB
		DW	OFFSET trn3_0_b_b-$-2
		DB	044h,003h,000h		; SELECT sweep
		DW	OFFSET trn3_02-$-2	; to ENDSELECT
		DW	OFFSET CASE1_2trn3-$-2	; to CASE
		DW	OFFSET CASE2_3trn3-$-2	; to CASE
		DW	OFFSET CASE3_4trn3-$-2	; to CASE


trn3_0		LABEL	BYTE
		DB	008h,COL_OLIVE4,44,54,64,08,-1		; face 46
		DB	008h,COL_OLIVE4,48,64,54,52,-1		; face 46
		DB	008h,COL_OLIVE4,62,46,50,56,-1		; face 46
		DB	008h,COL_OLIVE4,06,62,56,42,-1		; face 46
		DB	008h,COL_OLIVE2,54,44,42,56,50,52,-1	; face 45
		DB	008h,COL_OLIVE2,64,62,06,08,-1		; face 68
		DB	006h,5,COL_OLIVE4,COL_OLIVE4,24,32,-1	; line 79
		DB	008h,COL_OLIVE4,02,36,60,40,-1		; face 58
		DB	008h,COL_OLIVE4,38,58,34,04,-1		; face 58
		DB	008h,COL_CYAN_GREY5,04,06,42,38,-1	; face 38
		DB	008h,COL_CYAN_GREY5,44,08,02,40,-1	; face 39
		DB	008h,COL_OLIVE2,60,58,38,40,-1		; face 39
		DB	008h,COL_GREY2,00,36,34,-1		; face 30
		DB	008h,COL_GREY3,00,58,60,-1		; face 28
		DB	008h,COL_GREY3,00,34,58,-1		; face 27
		DB	008h,COL_GREY3,00,60,36,-1		; face 28
		DB	008h,COL_OLIVE3,34,36,02,04,-1		; face 22
		DB	002h,4,COL_DK_CYAN3,32,30,-1		; line 26
		DB	002h,4,COL_DK_CYAN1,30,66,-1		; line 27
		DB	00Ch,COL_OLIVE3,COL_OLIVE3,28,24,22,26,-1	; face 34
		DB	-1

rhtl_trn3	LABEL	BYTE
		DB	008h,COL_NT_AMBER1,46,24,88,50,-1	; exh afb lf
		DB	-1

dryl_trn3	LABEL	BYTE
		DB	008h,COL_GREY4,46,24,88,50,-1		; exh dry lf
		DB	-1

trn3_0_b	LABEL	BYTE
		DB	-1

rhtr_trn3	LABEL	BYTE
		DB	008h,COL_NT_AMBER1,24,48,52,88,-1	; exh afb rt
		DB	-1

dryr_trn3	LABEL	BYTE
		DB	008h,COL_GREY4,24,48,52,88,-1		; exh dry rt
		DB	-1

trn3_0_b_b	LABEL	BYTE
		DB	-1

CASE1_2trn3	LABEL	BYTE
		DB	00Ch,COL_OLIVE2,COL_OLIVE2,80,12,84,76,-1	; WING lf 25
		DB	00Ch,COL_OLIVE2,COL_OLIVE2,78,86,10,82,-1	; WING rt 25
		DB	-1

CASE2_3trn3	LABEL	BYTE
		DB	00Ch,COL_OLIVE2,COL_OLIVE2,84,68,72,12,-1	; WING lf 45
		DB	00Ch,COL_OLIVE2,COL_OLIVE2,74,70,86,10,-1	; WING rt 45
		DB	-1

CASE3_4trn3	LABEL	BYTE
		DB	00Ch,COL_OLIVE2,COL_OLIVE2,10,14,20,64,-1	; WING rt 67
		DB	00Ch,COL_OLIVE2,COL_OLIVE2,62,18,16,12,-1	; WING lf 67
		DB	-1

trn3_02		LABEL	BYTE
		DB	00Ch,COL_OLIVE2,COL_OLIVE2,64,20,18,62,-1	; face 25
		DB	006h,5,COL_OLIVE3,COL_OLIVE3,22,24,-1	; line 28
		DB	-1

		EVEN

Tornado4	OBJECTHEADER <OBJ_SCALE4,4096,-1,1,COL_OLIVE5,5,7,4>
		DB	064,078,066	;   0
		DB	064,070,068	;   1
		DB	064,068,068	;   2
		DB	072,058,068	;   3
		DB	056,058,068	;   4
		DB	058,056,068	;   5
		DB	070,056,068	;   6
		DB	064,064,068	;   7
		DB	064,056,068	;   8
		DB	064,056,072	;   9
		DB	064,052,072	;  10
		DB	064,072,068	;  11
		DB	064,068,066	;  12
		DB	064,056,066	;  13
		DB	064,062,068	;  14
		DB	054,060,068	;  15
		DB	074,060,068	;  16
		DB	054,062,068	;  17
		DB	074,062,068	;  18
		DB	054,064,068	;  19
		DB	074,064,068	;  20
		DB	-1

		DW	OFFSET	Tornado4_1

		EVEN

Tornado4_1	DW	126

trn4_0_L	DB	046h		; GOSUB
		DW	OFFSET trn4_0-$-2
		DB	044h,003h,000h		; SELECT sweep
		DW	OFFSET trn4_02-$-2	; to ENDSELECT
		DW	OFFSET CASE1_2trn4-$-2	; to CASE
		DW	OFFSET CASE2_3trn4-$-2	; to CASE
		DW	OFFSET CASE3_4trn4-$-2	; to CASE


trn4_0		LABEL	BYTE
		DB	00Ch,COL_OLIVE4,COL_OLIVE4,00,26,16,22,-1	; face 36
		DB	006h,5,COL_OLIVE4,COL_OLIVE4,16,02,-1	; line 79
		DB	006h,5,COL_GREY3,COL_GREY3,22,00,-1	; line 27
		DB	002h,4,COL_DK_CYAN3,02,22,-1		; line 26
		DB	006h,5,COL_CYAN_GREY5,COL_CYAN_GREY5,02,24,-1	; face 38
		DB	00Ch,COL_OLIVE3,COL_OLIVE3,20,16,14,18,-1	; face 34
		DB	00Ah,COL_GREY4,16,26,-1			; exh dry rt
		DB	-1

CASE1_2trn4	LABEL	BYTE
		DB	00Ch,COL_OLIVE2,COL_OLIVE2,38,04,14,34,-1	; WING lf 25
		DB	00Ch,COL_OLIVE2,COL_OLIVE2,36,14,04,40,-1	; WING rt 25
		DB	-1

CASE2_3trn4	LABEL	BYTE
		DB	00Ch,COL_OLIVE2,COL_OLIVE2,14,08,30,04,-1	; WING lf 45
		DB	00Ch,COL_OLIVE2,COL_OLIVE2,32,06,14,04,-1	; exh dry rt
		DB	-1

CASE3_4trn4	LABEL	BYTE
		DB	00Ch,COL_OLIVE2,COL_OLIVE2,04,06,12,28,-1	; WING rt 67
		DB	00Ch,COL_OLIVE2,COL_OLIVE2,28,10,08,04,-1	; WING lf 67
		DB	-1

trn4_02		LABEL	BYTE
		DB	00Ch,COL_OLIVE2,COL_OLIVE2,28,12,10,-1	; face 25
		DB	-1

		EVEN

