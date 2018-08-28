skid18		OBJECTHEADER <OBJ_SCALE16,1024,-1,1,COL_GREY1,8,32,0>
		DB	056,070	;   0
		DB	058,036	;   2
		DB	056,040	;   4
		DB	072,070	;   6
		DB	074,034	;   8
		DB	072,036	;  10
		DB	064,026	;  12
		DB	066,002	;  14
		DB	064,000	;  16
		DB	060,048	;  18
		DB	058,046	;  20
		DB	058,078	;  22
		DB	076,076	;  24
		DB	076,046	;  26
		DB	074,050	;  28
		DB	068,008	;  30
		DB	066,032	;  32
		DB	054,054	;  34
		DB	050,036	;  36
		DB	052,026	;  38
		DB	078,046	;  40
		DB	080,024	;  42
		DB	076,018	;  44
		DB	-1

		DW	OFFSET	skid18_1

		EVEN

skid18_1	DW	50


skid18_0	LABEL	BYTE
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

