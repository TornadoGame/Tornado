ilsloc09	OBJECTHEADER <OBJ_SCALE4,750,ilsloc09_2,0,COL_BLACK1,19,8,3>
		DB	028,052,064	;   0
		DB	032,052,064	;   1
		DB	032,080,064	;   2
		DB	028,080,064	;   3
		DB	028,076,064	;   4
		DB	032,076,064	;   5
		DB	032,072,064	;   6
		DB	028,072,064	;   7
		DB	028,068,064	;   8
		DB	032,068,064	;   9
		DB	032,064,064	;  10
		DB	028,064,064	;  11
		DB	028,060,064	;  12
		DB	032,060,064	;  13
		DB	032,056,064	;  14
		DB	028,056,064	;  15
		DB	032,048,064	;  16
		DB	028,048,064	;  17
		DB	028,048,070	;  18
		DB	028,052,070	;  19
		DB	028,056,070	;  20
		DB	028,060,070	;  21
		DB	028,064,070	;  22
		DB	028,068,070	;  23
		DB	028,072,070	;  24
		DB	028,076,070	;  25
		DB	028,080,070	;  26
		DB	028,076,068	;  27
		DB	026,076,068	;  28
		DB	026,078,068	;  29
		DB	028,072,068	;  30
		DB	026,072,068	;  31
		DB	026,074,068	;  32
		DB	028,068,068	;  33
		DB	026,068,068	;  34
		DB	026,070,068	;  35
		DB	028,064,068	;  36
		DB	026,064,068	;  37
		DB	026,066,068	;  38
		DB	028,060,068	;  39
		DB	026,060,068	;  40
		DB	026,062,068	;  41
		DB	028,056,068	;  42
		DB	026,056,068	;  43
		DB	026,058,068	;  44
		DB	028,052,068	;  45
		DB	026,052,068	;  46
		DB	026,054,068	;  47
		DB	028,048,068	;  48
		DB	026,048,068	;  49
		DB	026,050,068	;  50
		DB	028,080,068	;  51
		DB	028,080,066	;  52
		DB	028,048,066	;  53
		DB	-1

		DW	OFFSET	ilsloc09_1

		EVEN

ilsloc09_1	DW	204

iloc09cn_bk	DB	028h,52,36,34,06,-1
		DW	OFFSET iloc09cn_ft-$-2	; 
		DW	OFFSET iloc09bk-$-2	; 
		DB	-1

iloc09cn_ft	DB	028h,36,52,06,34,-1
		DW	OFFSET iloc09cn-$-2	; 
		DW	OFFSET iloc09ft-$-2	; 
		DB	-1


iloc09cn	LABEL	BYTE
		DB	006h,5,COL_AMBER4,COL_RED1,36,52,-1	; line 20
		DB	006h,5,COL_AMBER4,COL_RED1,106,104,-1	; line 20
		DB	00Dh,COL_NEW_GREY1,COL_NEW_GREY1,52,36,106,104,-1	; face 21
		DB	-1

iloc09ft	LABEL	BYTE
		DB	008h,COL_GREY2,32,34,06,04,-1		; face 18
		DB	006h,7,COL_AMBER4,COL_RED1,96,32,34,36,-1	; line 11
		DB	006h,7,COL_WHITE1,COL_WHITE1,90,02,00,38,-1	; line 12
		DB	006h,7,COL_AMBER4,COL_RED1,40,30,28,84,-1	; line 13
		DB	006h,7,COL_WHITE1,COL_WHITE1,42,24,26,78,-1	; line 14
		DB	006h,7,COL_AMBER4,COL_RED1,44,22,20,72,-1	; line 15
		DB	006h,7,COL_WHITE1,COL_WHITE1,46,16,18,66,-1	; line 16
		DB	006h,7,COL_AMBER4,COL_RED1,48,14,12,60,-1	; line 17
		DB	006h,7,COL_WHITE1,COL_WHITE1,50,08,10,54,-1	; line 18
		DB	006h,7,COL_AMBER4,COL_RED1,52,06,04,102,-1	; line 19
		DB	-1

iloc09bk	LABEL	BYTE
		DB	006h,6,COL_WHITE1,COL_WHITE1,96,98,100,-1	; line 10
		DB	006h,6,COL_WHITE1,COL_WHITE1,90,92,94,-1	; line 11
		DB	006h,6,COL_WHITE1,COL_WHITE1,84,86,88,-1	; line 12
		DB	006h,6,COL_WHITE1,COL_WHITE1,78,80,82,-1	; line 13
		DB	006h,6,COL_WHITE1,COL_WHITE1,72,74,76,-1	; line 14
		DB	006h,6,COL_WHITE1,COL_WHITE1,66,68,70,-1	; line 15
		DB	006h,6,COL_WHITE1,COL_WHITE1,60,62,64,-1	; line 16
		DB	006h,6,COL_WHITE1,COL_WHITE1,54,56,58,-1	; line 17
		DB	-1

		EVEN

ilsloc09_2	OBJECTHEADER <OBJ_SCALE2,1500,ilsloc09_3,0,COL_BLACK1,9,4,1>
		DB	048,058,064	;   0
		DB	048,072,064	;   1
		DB	046,072,064	;   2
		DB	048,070,064	;   3
		DB	048,068,064	;   4
		DB	048,066,064	;   5
		DB	048,064,064	;   6
		DB	048,062,064	;   7
		DB	048,060,064	;   8
		DB	048,056,064	;   9
		DB	046,056,064	;  10
		DB	046,056,066	;  11
		DB	046,058,066	;  12
		DB	046,060,066	;  13
		DB	046,062,066	;  14
		DB	046,064,066	;  15
		DB	046,066,066	;  16
		DB	046,068,066	;  17
		DB	046,070,066	;  18
		DB	046,072,066	;  19
		DB	-1

		DW	OFFSET	ilsloc09_2_1

		EVEN

ilsloc09_2_1	DW	101

iloc09bk_ft2	DB	028h,22,38,04,20,-1
		DW	OFFSET iloc09bk2-$-2	; 
		DW	OFFSET iloc09ft2-$-2	; 
		DB	-1


iloc09bk2	LABEL	BYTE
		DB	00Dh,COL_NEW_GREY1,COL_NEW_GREY1,38,22,20,04,-1	; face 21
		DB	006h,5,COL_WHITE1,COL_WHITE1,38,22,-1	; line 18
		DB	-1

iloc09ft2	LABEL	BYTE
		DB	008h,COL_GREY2,18,20,04,02,-1		; face 18
		DB	006h,5,COL_AMBER4,COL_RED1,38,02,-1	; line 15
		DB	006h,5,COL_WHITE1,COL_WHITE1,36,06,-1	; line 16
		DB	006h,5,COL_AMBER4,COL_RED1,34,08,-1	; line 17
		DB	006h,5,COL_WHITE1,COL_WHITE1,32,10,-1	; line 18
		DB	006h,5,COL_AMBER4,COL_RED1,30,12,-1	; line 19
		DB	006h,5,COL_WHITE1,COL_WHITE1,28,14,-1	; line 20
		DB	006h,5,COL_AMBER4,COL_RED1,26,16,-1	; line 21
		DB	006h,5,COL_WHITE1,COL_WHITE1,24,00,-1	; line 22
		DB	006h,5,COL_AMBER4,COL_RED1,22,18,-1	; line 23
		DB	-1

		EVEN

ilsloc09_3	OBJECTHEADER <OBJ_SCALE1,16384,-1,1,COL_BLACK1,4,2,0>
		DB	056,068,064	;   0
		DB	056,060,064	;   1
		DB	056,064,064	;   2
		DB	-1

		DW	OFFSET	ilsloc09_3_1

		EVEN

ilsloc09_3_1	DW	22


iloc09_30	LABEL	BYTE
		DB	00Ah,COL_NEW_GREY1,00,02,-1		; line 5
		DB	00Ah,COL_AMBER4,00,00,-1		; line 2
		DB	00Ah,COL_AMBER4,04,04,-1		; line 3
		DB	00Ah,COL_AMBER4,02,02,-1		; line 4
		DB	-1

		EVEN

