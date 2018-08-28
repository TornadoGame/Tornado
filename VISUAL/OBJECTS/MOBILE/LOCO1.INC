loco1		OBJECTHEADER <OBJ_SCALE16,512,loco2,0,COL_BLACK1,5,30,15>
		DB	054,004,072	;   0
		DB	074,004,072	;   1
		DB	054,124,072	;   2
		DB	074,124,072	;   3
		DB	056,004,092	;   4
		DB	056,108,092	;   5
		DB	072,108,092	;   6
		DB	072,004,092	;   7
		DB	054,112,086	;   8
		DB	074,112,086	;   9
		DB	074,004,086	;  10
		DB	054,004,086	;  11
		DB	054,124,082	;  12
		DB	074,124,082	;  13
		DB	056,120,064	;  14
		DB	056,094,064	;  15
		DB	072,094,064	;  16
		DB	072,120,064	;  17
		DB	056,008,064	;  18
		DB	056,030,064	;  19
		DB	072,030,064	;  20
		DB	072,008,064	;  21
		DB	056,004,072	;  22
		DB	056,030,072	;  23
		DB	056,094,072	;  24
		DB	056,124,072	;  25
		DB	072,124,072	;  26
		DB	072,094,072	;  27
		DB	072,030,072	;  28
		DB	072,004,072	;  29
		DB	056,124,068	;  30
		DB	072,124,068	;  31
		DB	072,004,068	;  32
		DB	056,004,068	;  33
		DB	064,112,088	;  34
		DB	064,108,094	;  35
		DB	064,124,084	;  36
		DB	064,004,094	;  37
		DB	056,040,066	;  38
		DB	072,040,066	;  39
		DB	072,084,066	;  40
		DB	056,084,066	;  41
		DB	054,034,072	;  42
		DB	054,090,072	;  43
		DB	074,090,072	;  44
		DB	074,034,072	;  45
		DB	054,108,086	;  46
		DB	074,108,086	;  47
		DB	062,124,082	;  48
		DB	066,124,082	;  49
		DB	064,124,080	;  50
		DB	-1

		DW	OFFSET	loco1_1

		EVEN

loco1_1		DW	257

loco1_0_L	DB	046h		; GOSUB
		DW	OFFSET loco1_0-$-2
		DB	042h,001h		; IF_loco1_lton
		DW	OFFSET loco1_b-$-2	; to ENDIF
		DW	OFFSET loco1_lton-$-2	; to THEN
		DW	OFFSET loco1_ltoff-$-2	; to ELSE


loco1_0		LABEL	BYTE
		DB	008h,COL_GREY3,90,88,80,78,-1		; side bottom right
		DB	008h,COL_GREY3,86,84,76,82,-1		; side bottom left
		DB	008h,COL_NEW_GREY3,60,50,48,30,28,-1	; front bogie left
		DB	008h,COL_NEW_GREY3,46,44,66,36,38,-1	; back bogie left
		DB	008h,COL_NEW_GREY3,54,52,62,34,32,-1	; front bogie right
		DB	008h,COL_NEW_GREY3,56,40,42,64,58,-1	; back bogie right
		DB	008h,COL_NEW_GREY3,44,58,64,66,-1	; back bogie back
		DB	008h,COL_NEW_GREY3,52,50,60,62,-1	; front bogie front
		DB	008h,COL_CYAN_GREY5,20,18,26,06,02,-1	; side lower right
		DB	008h,COL_CYAN_GREY5,04,24,16,22,00,-1	; side lower left
		DB	008h,COL_AMBER1,10,08,22,92,-1		; side upper left
		DB	000h,5,COL_DK_CYAN2,16,10,92,-1		; side window left
		DB	002h,5,COL_GREY2,10,92,16,-1		; line 26
		DB	008h,COL_AMBER1,94,20,14,12,-1		; face 27
		DB	000h,5,COL_DK_CYAN2,12,18,94,-1		; side window right
		DB	002h,5,COL_GREY2,18,94,12,-1		; line 27
		DB	008h,COL_CYAN_GREY3,72,68,16,24,-1	; front upper left
		DB	002h,4,COL_CYAN_GREY4,16,24,-1		; line 28
		DB	008h,COL_CYAN_GREY3,18,68,72,26,-1	; front upper right
		DB	002h,4,COL_CYAN_GREY4,26,18,-1		; line 29
		DB	008h,COL_DK_CYAN1,18,12,70,68,-1	; windscreen right
		DB	002h,5,COL_GREY2,68,18,12,-1		; line 23
		DB	008h,COL_DK_CYAN1,70,10,16,68,-1	; windscreen left
		DB	002h,6,COL_GREY2,70,68,16,10,-1		; line 22
		DB	008h,COL_GREY3,20,02,00,22,08,74,14,-1	; bk end
		DB	008h,COL_CYAN_GREY3,74,08,10,70,-1	; roof left
		DB	002h,4,COL_GREY2,70,10,-1		; line 24
		DB	008h,COL_CYAN_GREY3,14,74,70,12,-1	; roof right
		DB	002h,4,COL_GREY2,12,70,-1		; line 25
		DB	-1

loco1_lton	LABEL	BYTE
		DB	008h,COL_AMBER1,24,04,06,26,72,-1	; face 36
		DB	000h,6,COL_NT_WHITE1,98,72,96,100,-1	; face 37
		DB	-1

loco1_ltoff	LABEL	BYTE
		DB	008h,COL_AMBER1,06,26,72,24,04,-1	; front end
		DB	000h,6,COL_CYAN_GREY1,72,96,100,98,-1	; face 31
		DB	-1

loco1_b		LABEL	BYTE
		DB	-1

		EVEN

loco2		OBJECTHEADER <OBJ_SCALE8,1024,loco3,0,COL_BLACK1,2,15,7>
		DB	060,034,068	;   0
		DB	068,034,068	;   1
		DB	060,094,068	;   2
		DB	068,094,068	;   3
		DB	060,034,078	;   4
		DB	060,086,078	;   5
		DB	068,086,078	;   6
		DB	068,034,078	;   7
		DB	060,088,074	;   8
		DB	068,088,074	;   9
		DB	068,034,074	;  10
		DB	060,034,074	;  11
		DB	060,094,072	;  12
		DB	068,094,072	;  13
		DB	060,092,064	;  14
		DB	060,080,064	;  15
		DB	068,080,064	;  16
		DB	068,092,064	;  17
		DB	060,036,064	;  18
		DB	060,046,064	;  19
		DB	068,046,064	;  20
		DB	068,036,064	;  21
		DB	060,048,068	;  22
		DB	060,078,068	;  23
		DB	068,078,068	;  24
		DB	068,048,068	;  25
		DB	064,088,074	;  26
		DB	064,094,072	;  27
		DB	060,052,064	;  28
		DB	068,052,064	;  29
		DB	068,074,064	;  30
		DB	060,074,064	;  31
		DB	064,094,070	;  32
		DB	-1

		DW	OFFSET	loco2_1

		EVEN

loco2_1		DW	155

loco2_0_L	DB	046h		; GOSUB
		DW	OFFSET loco2_0-$-2
		DB	042h,001h		; IF_lton_loco2
		DW	OFFSET loco2_0_b-$-2	; to ENDIF
		DW	OFFSET THEN_ltonloc2-$-2	; to THEN
		DW	OFFSET ELSE_ltofloc2-$-2	; to ELSE


loco2_0		LABEL	BYTE
		DB	008h,COL_CYAN_GREY5,20,18,26,06,02,-1	; side lower right
		DB	000h,6,COL_NEW_GREY3,48,06,34,32,-1	; front bogie right
		DB	000h,6,COL_NEW_GREY3,50,40,42,02,-1	; back bogie right
		DB	000h,6,COL_AMBER1,18,20,14,12,-1	; face 27
		DB	000h,6,COL_GREY3,50,48,60,58,-1		; side bottom right
		DB	008h,COL_CYAN_GREY5,04,24,16,22,00,-1	; side lower left
		DB	000h,6,COL_GREY3,46,44,56,62,-1		; side bottom left
		DB	000h,6,COL_NEW_GREY3,04,46,30,28,-1	; front bogie left
		DB	000h,6,COL_NEW_GREY3,44,00,36,38,-1	; back bogie left
		DB	000h,6,COL_AMBER1,10,08,22,16,-1	; side upper left
		DB	00Ah,COL_NEW_GREY3,06,04,-1		; front bogie front
		DB	008h,COL_CYAN_GREY3,16,24,26,18,-1	; face 25
		DB	008h,COL_GREY2,18,12,10,16,-1		; face 29
		DB	008h,COL_GREY3,02,00,08,14,-1		; bk end
		DB	008h,COL_CYAN_GREY3,08,10,12,14,-1	; face 28
		DB	-1

THEN_ltonloc2	LABEL	BYTE
		DB	008h,COL_AMBER1,04,06,26,24,-1		; face 24
		DB	002h,4,COL_NT_WHITE1,54,64,-1		; line 24
		DB	-1

ELSE_ltofloc2	LABEL	BYTE
		DB	008h,COL_AMBER1,06,26,24,04,-1		; face 24
		DB	002h,4,COL_CYAN_GREY1,54,64,-1		; face 36
		DB	-1

loco2_0_b	LABEL	BYTE
		DB	-1

		EVEN

loco3		OBJECTHEADER <OBJ_SCALE2,8192,-1,1,COL_CYAN_GREY5,0,3,1>
		DB	064,058,064	;   0
		DB	064,070,064	;   1
		DB	064,058,066	;   2
		DB	064,068,066	;   3
		DB	064,070,066	;   4
		DB	-1

		DW	OFFSET	loco3_1

		EVEN

loco3_1		DW	48

loco3_0_L	DB	046h		; GOSUB
		DW	OFFSET loco3_0-$-2
		DB	042h,001h		; IF_lton_loc3
		DW	OFFSET loco3_0_b-$-2	; to ENDIF
		DW	OFFSET THEN_ltonloc3-$-2	; to THEN
		DW	OFFSET ELSE_ltofloc3-$-2	; to ELSE


loco3_0		LABEL	BYTE
		DB	00Ch,COL_CYAN_GREY5,COL_CYAN_GREY5,04,08,02,00,-1	; side lower right
		DB	006h,5,COL_NEW_GREY3,COL_NEW_GREY3,00,02,-1	; front bogie left
		DB	006h,5,COL_AMBER1,COL_AMBER1,04,06,-1	; line 11
		DB	-1

THEN_ltonloc3	LABEL	BYTE
		DB	00Ah,COL_NT_WHITE1,08,02,-1		; line 9
		DB	-1

ELSE_ltofloc3	LABEL	BYTE
		DB	00Ah,COL_CYAN_GREY1,08,02,-1		; face 36
		DB	-1

loco3_0_b	LABEL	BYTE
		DB	-1

		EVEN

