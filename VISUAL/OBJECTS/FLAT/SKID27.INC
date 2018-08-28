skid27		OBJECTHEADER <OBJ_SCALE16,1024,-1,1,COL_GREY1,32,8,0>
		DB	070,072	;   0
		DB	036,070	;   2
		DB	040,072	;   4
		DB	070,056	;   6
		DB	034,054	;   8
		DB	036,056	;  10
		DB	026,064	;  12
		DB	002,062	;  14
		DB	000,064	;  16
		DB	048,068	;  18
		DB	046,070	;  20
		DB	078,070	;  22
		DB	076,052	;  24
		DB	046,052	;  26
		DB	050,054	;  28
		DB	008,060	;  30
		DB	032,062	;  32
		DB	054,074	;  34
		DB	036,078	;  36
		DB	026,076	;  38
		DB	046,050	;  40
		DB	024,048	;  42
		DB	018,052	;  44
		DB	-1

		DW	OFFSET	skid27_1

		EVEN

skid27_1	DW	50


skid27_0	LABEL	BYTE
		DB	009h,COL_NEW_GREY3,00,02,04,-1		; face 1
		DB	009h,COL_NEW_GREY3,06,08,10,-1		; face 2
		DB	009h,COL_NEW_GREY3,12,14,16,-1		; face 3
		DB	009h,COL_NEW_GREY3,22,18,20,-1		; face 4
		DB	009h,COL_NEW_GREY3,24,26,28,-1		; face 5
		DB	009h,COL_NEW_GREY3,30,14,32,-1		; face 6
		DB	009h,COL_NEW_GREY3,34,38,36,-1		; face 7
		DB	009h,COL_NEW_GREY3,42,44,40,-1		; face 8
		DB	-1

		EVEN

