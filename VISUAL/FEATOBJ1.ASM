;****************************************************************************
;*
;* FEATOBJ1.ASM
;*
;* Data for flat ground features (including rivers).
;*
;* 20.02.1991 - KJB
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<
		
		PUBLIC	FeatureTable
		PUBLIC	RiverTable
		PUBLIC	CloudTable

;============================================================================

		INCLUDE	VISDATA.INC
		INCLUDE	PALETTES.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'
		ASSUME DS:DATA

;---------------------------
FeatureTable	LABEL	WORD
;---------------------------

		DW	OFFSET	NullObject	;  0
		DW	OFFSET	Feat1	;  1
		DW	OFFSET	Feat2	;  2
		DW	OFFSET	Feat3	;  3
		DW	OFFSET	Feat4	;  4
		DW	OFFSET	Feat5	;  5
		DW	OFFSET	Feat6	;  6
		DW	OFFSET	Feat7	;  7
		DW	OFFSET	Feat8	;  8
		DW	OFFSET	Feat9	;  9
		DW	OFFSET	Feat10	; 10
		DW	OFFSET	Feat11	; 11
		DW	OFFSET	Feat12	; 12
		DW	OFFSET	Feat13	; 13
		DW	OFFSET	Feat14	; 14
		DW	OFFSET	Feat15	; 15
		DW	OFFSET	Feat16	; 16
		DW	OFFSET	Feat17	; 17
		DW	OFFSET	Feat18	; 18
		DW	OFFSET	Feat19	; 19
		DW	OFFSET	Feat20	; 20
		DW	OFFSET	Feat21	; 21
		DW	OFFSET	Feat22	; 22
		DW	OFFSET	Feat23	; 23
		DW	OFFSET	Feat24	; 24
		DW	OFFSET	Feat25	; 25
		DW	OFFSET	Feat26	; 26
		DW	OFFSET	Feat27	; 27
		DW	OFFSET	Feat28	; 28
		DW	OFFSET	Feat29	; 29
		DW	OFFSET	Feat30	; 30
		DW	OFFSET	Feat31	; 31
		DW	OFFSET	Feat32	; 32
		DW	OFFSET	Feat33	; 33
		DW	OFFSET	Feat34	; 34
		DW	OFFSET	Feat35	; 35
		DW	OFFSET	Feat36	; 36
		DW	OFFSET	Feat37	; 37
		DW	OFFSET	Feat38	; 38
		DW	OFFSET	Feat39	; 39
		DW	OFFSET	Feat40	; 40
		DW	OFFSET	Feat41	; 41
		DW	OFFSET	Feat42	; 42
		DW	OFFSET	Feat43	; 43
		DW	OFFSET	Feat44	; 44
		DW	OFFSET	Feat45	; 45
		DW	OFFSET	Feat46	; 46
		DW	OFFSET	Feat47	; 47
		DW	OFFSET	Feat48	; 48
		DW	OFFSET	Feat49	; 49
		DW	OFFSET	Feat50	; 50
		DW	OFFSET	Feat51	; 51
		DW	OFFSET	Feat52	; 52
		DW	OFFSET	Feat53	; 53
		DW	OFFSET	Feat54	; 54
		DW	OFFSET	Feat55	; 55
		DW	OFFSET	Feat56	; 56
		DW	OFFSET	NullObject	; 57
		DW	OFFSET	NullObject	; 58
		DW	OFFSET	NullObject	; 59
		DW	OFFSET	NullObject	; 60
		DW	OFFSET	NullObject	; 61
		DW	OFFSET	NullObject	; 62
		DW	OFFSET	NullObject	; 63
		DW	OFFSET	NullObject	; 64
		DW	OFFSET	NullObject	; 65
		DW	OFFSET	NullObject	; 66
		DW	OFFSET	NullObject	; 67
		DW	OFFSET	NullObject	; 68
		DW	OFFSET	NullObject	; 69
		DW	OFFSET	NullObject	; 70
		DW	OFFSET	NullObject	; 71
		DW	OFFSET	NullObject	; 72
		DW	OFFSET	NullObject	; 73
		DW	OFFSET	NullObject	; 74
		DW	OFFSET	NullObject	; 75
		DW	OFFSET	NullObject	; 76
		DW	OFFSET	Feat77	; 77
		DW	OFFSET	Feat78	; 78
		DW	OFFSET	Feat79	; 79
		DW	OFFSET	Feat80	; 80
		DW	OFFSET	Feat81	; 81
		DW	OFFSET	Feat82	; 82
		DW	OFFSET	Feat83	; 83
		DW	OFFSET	NullObject	; 84
		DW	OFFSET	NullObject	; 85
		DW	OFFSET	NullObject	; 86
		DW	OFFSET	NullObject	; 87
		DW	OFFSET	NullObject	; 88
		DW	OFFSET	NullObject	; 89
		DW	OFFSET	NullObject	; 90
		DW	OFFSET	NullObject	; 91
		DW	OFFSET	NullObject	; 92
		DW	OFFSET	NullObject	; 93
		DW	OFFSET	NullObject	; 94
		DW	OFFSET	NullObject	; 95
		DW	OFFSET	NullObject	; 96
		DW	OFFSET	NullObject	; 97
		DW	OFFSET	NullObject	; 98
		DW	OFFSET	NullObject	; 99

;---------------------------
RiverTable	LABEL	WORD
;---------------------------

		DW	OFFSET NullObject	;0
		DW	OFFSET RivTile1		;1				DW	OFFSET RivTile2;2 
		DW	OFFSET RivTile2 	;2  
		DW	OFFSET RivTile3 	;3  
		DW	OFFSET RivTile4 	;4  
		DW	OFFSET RivTile5 	;5  
		DW	OFFSET RivTile6 	;6  
		DW	OFFSET RivTile7 	;7  
		DW	OFFSET RivTile8 	;8  
		DW	OFFSET RivTile9 	;9  
		DW	OFFSET RivTile10	;10 
		DW	OFFSET RivTile11	;11 
		DW	OFFSET RivTile12	;12 
		DW	OFFSET RivTile13	;13 
		DW	OFFSET RivTile14	;14 
		DW	OFFSET RivTile15	;15 
		DW	OFFSET RivTile16	;16 
		DW	OFFSET RivTile17	;17 
		DW	OFFSET RivTile18	;18 
		DW	OFFSET RivTile19	;19 
		DW	OFFSET RivTile20	;20 
		DW	OFFSET RivTile21	;21 
		DW	OFFSET RivTile22	;22 
		DW	OFFSET RivTile23	;23 
		DW	OFFSET RivTile24	;24 
		DW	OFFSET RivTile25	;25 
		DW	OFFSET RivTile26	;26 
		DW	OFFSET RivTile27	;27 
		DW	OFFSET RivTile28	;28 
		DW	OFFSET RivTile29	;29 
		DW	OFFSET RivTile30	;30 
		DW	OFFSET RivTile31	;31 
		DW	OFFSET RivTile32	;32 
		DW	OFFSET RivTile33	;33 
		DW	OFFSET RivTile34	;34 
		DW	OFFSET RivTile35	;35 
		DW	OFFSET RivTile36	;36 
		DW	OFFSET RivTile37	;37 
		DW	OFFSET RivTile38	;38 
		DW	OFFSET RivTile39	;39 
		DW	OFFSET RivTile40	;40 
		DW	OFFSET RivTile41	;41 
		DW	OFFSET RivTile42	;42 
		DW	OFFSET RivTile43	;43 
		DW	OFFSET RivTile44	;44 
		DW	OFFSET RivTile45	;45 
		DW	OFFSET RivTile46	;46 
		DW	OFFSET RivTile47	;47 
		DW	OFFSET RivTile48	;48 
		DW	OFFSET RivTile49	;49 
		DW	OFFSET RivTile50	;50 
		DW	OFFSET RivTile51	;51 
		DW	OFFSET RivTile52	;52 
		DW	OFFSET RivTile53	;53 
		DW	OFFSET RivTile54	;54 
		DW	OFFSET RivTile55	;55 
		DW	OFFSET RivTile56	;56 
		DW	OFFSET RivTile57	;57 
		DW	OFFSET RivTile58	;58 
		DW	OFFSET RivTile59	;59 
		DW	OFFSET RivTile60	;60 
		DW	OFFSET RivTile61	;61 
		DW	OFFSET RivTile62	;62 
		DW	OFFSET RivTile63	;63 
		DW	OFFSET RivTile64	;64

;---------------------------
CloudTable	LABEL	WORD
;---------------------------

		DW	OFFSET	NullCloud	;  0
		DW	OFFSET	Cloud1	;  1
		DW	OFFSET	Cloud2	;  2
		DW	OFFSET	Cloud3	;  3
		DW	OFFSET	Cloud4	;  4
		DW	OFFSET	Cloud5	;  5
		DW	OFFSET	Cloud6	;  6
		DW	OFFSET	Cloud7	;  7
		DW	OFFSET	Cloud8	;  8
		DW	OFFSET	Cloud9	;  9
		DW	OFFSET	Cloud10	; 10
		DW	OFFSET	Cloud11	; 11
		DW	OFFSET	Cloud12	; 12
		DW	OFFSET	Cloud13	; 13
		DW	OFFSET	Cloud14	; 14
		DW	OFFSET	Cloud15	; 15
		DW	OFFSET	Cloud16	; 16
		DW	OFFSET	Cloud17	; 17
		DW	OFFSET	Cloud18	; 18
		DW	OFFSET	Cloud19	; 19
		DW	OFFSET	Cloud20	; 20
		DW	OFFSET	Cloud21	; 21
		DW	OFFSET	Cloud22	; 22
		DW	OFFSET	Cloud23	; 23
		DW	OFFSET	Cloud24	; 24
		DW	OFFSET	Cloud25	; 25
		DW	OFFSET	Cloud26	; 26
		DW	OFFSET	Cloud27	; 27
		DW	OFFSET	Cloud28	; 28

DATA		ENDS

;============================================================================

FEATOBJ1	SEGMENT PARA PUBLIC 'DATA'
		ASSUME DS:FEATOBJ1

;* null object - a large red square

NullObject	DW	SEC_SCALE16

		DB	1111b,  0 * 2 + 64,  0 * 2 + 64	;0
		DB	1111b,  0 * 2 + 64, 64 * 2 + 64	;2
		DB	1111b, 64 * 2 + 64, 64 * 2 + 64	;4
		DB	1111b, 64 * 2 + 64,  0 * 2 + 64	;6
 		DB	-1

		DW	OFFSET	NullObj1_1
		DW	OFFSET	NullObj1_1
		DW	OFFSET	NullObj1_1
		DW	OFFSET	NullObj1_1
		
		EVEN

NullObj1_1	DW	8

		DB	00000b, COL_LT_RED, 0, 2, 4, 6, -1
		DB	-1

		EVEN

NullCloud	DW	-1		;unfinished

		INCLUDE	OBJECTS\FEATURES\FEATILES.INC
		INCLUDE	OBJECTS\FEATURES\RIVTILES.INC
		INCLUDE	OBJECTS\FEATURES\CLOUDTLS.INC

FEATOBJ1	ENDS

;============================================================================

		END

