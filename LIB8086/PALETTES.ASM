;****************************************************************************
;*
;* PALETTES.ASM
;*
;* Palette data for screen drivers.
;*
;* See also PALETTES.INC.
;*
;* 03.08.1989 - KJB
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	HGC_Palette1
		PUBLIC	CGA_Palette1
		PUBLIC	TAN_Palette1
		PUBLIC	VGA_Palette1

		PUBLIC	V16_RGB_Data
		PUBLIC	VGA_RGB_Data
		PUBLIC	VGA_RGB_Fade

;============================================================================

PALDATA		SEGMENT PARA PUBLIC 'DATA'

;=====================================================
;* logical colour to physical colour conversion tables
;=====================================================

;* 4 colour HATCH record

HATCH4		RECORD	C3:2,C2:2,C1:2,C0:2

;* 16 colour HATCH record

HATCH16		RECORD	E1:4,E0:4

;===========================	
HGC_Palette1	LABEL	BYTE
;===========================

BLK		=	00b
MAG		=	10b
CYN		=	01b
WHT		=	11b

		HATCH4	<BLK,BLK,BLK,BLK>	;black
		HATCH4	<CYN,CYN,CYN,CYN>	;blue
		HATCH4	<CYN,CYN,CYN,CYN>	;green
		HATCH4	<CYN,CYN,CYN,CYN>      	;cyan
		HATCH4	<MAG,MAG,MAG,MAG>      	;red
		HATCH4	<MAG,MAG,MAG,MAG>	;magenta
		HATCH4	<MAG,MAG,MAG,MAG>	;brown
		HATCH4	<WHT,WHT,WHT,WHT>	;light grey
		HATCH4	<BLK,BLK,BLK,BLK>	;dark grey
		HATCH4	<CYN,CYN,CYN,CYN>	;light blue
		HATCH4	<CYN,CYN,CYN,CYN>	;light green
		HATCH4	<CYN,CYN,CYN,CYN>	;light cyan
		HATCH4	<MAG,MAG,MAG,MAG>	;light red
		HATCH4	<MAG,MAG,MAG,MAG>	;light magenta
		HATCH4	<WHT,WHT,WHT,WHT>	;yellow
		HATCH4	<WHT,WHT,WHT,WHT>	;white

;* CHANGE THESE COLOURS FOR YOUR APPLICATION

		HATCH4	240 DUP(<WHT,WHT,WHT,WHT>)
	
;===========================
CGA_Palette1	LABEL	BYTE
;===========================

BLK		=	00b
MAG		=	10b
CYN		=	01b
WHT		=	11b

		HATCH4	<BLK,BLK,BLK,BLK>	;black
		HATCH4	<CYN,CYN,CYN,CYN>	;blue
		HATCH4	<CYN,CYN,CYN,CYN>	;green
		HATCH4	<CYN,CYN,CYN,CYN>      	;cyan
		HATCH4	<MAG,MAG,MAG,MAG>      	;red
		HATCH4	<MAG,MAG,MAG,MAG>	;magenta
		HATCH4	<MAG,MAG,MAG,MAG>	;brown
		HATCH4	<WHT,WHT,WHT,WHT>	;light grey
		HATCH4	<BLK,BLK,BLK,BLK>	;dark grey
		HATCH4	<CYN,CYN,CYN,CYN>	;light blue
		HATCH4	<CYN,CYN,CYN,CYN>	;light green
		HATCH4	<CYN,CYN,CYN,CYN>	;light cyan
		HATCH4	<MAG,MAG,MAG,MAG>	;light red
		HATCH4	<MAG,MAG,MAG,MAG>	;light magenta
		HATCH4	<WHT,WHT,WHT,WHT>	;yellow
		HATCH4	<WHT,WHT,WHT,WHT>	;white

;* CHANGE THESE COLOURS FOR YOUR APPLICATION

		HATCH4	240 DUP(<WHT,WHT,WHT,WHT>)

;===========================
TAN_Palette1	LABEL	BYTE
;===========================

BLK		=	0000b
BLU		=	0001b
GRN		=	0010b
CYN		=	0011b
RED		=	0100b
MAG		=	0101b
BRN		=	0110b
LGY		=	0111b
DGY		=	1000b
LBL		=	1001b
LGR		=	1010b
LCY		=	1011b
LRD		=	1100b
LMG		=	1101b
YLW		=	1110b
WHT		=	1111b

		HATCH16	<BLK,BLK>
		HATCH16	<BLU,BLU>
		HATCH16	<GRN,GRN>
		HATCH16	<CYN,CYN>
		HATCH16	<RED,RED>
		HATCH16	<MAG,MAG>
		HATCH16	<BRN,BRN>
		HATCH16	<LGY,LGY>
		HATCH16	<DGY,DGY>
		HATCH16	<LBL,LBL>
		HATCH16	<LGR,LGR>
		HATCH16	<LCY,LCY>
		HATCH16	<LRD,LRD>
		HATCH16	<LMG,LMG>
		HATCH16	<YLW,YLW>
		HATCH16	<WHT,WHT>

;* CHANGE THESE COLOURS FOR YOUR APPLICATION

		HATCH16	240 DUP(<WHT,WHT>)
	
;===========================
VGA_Palette1	LABEL	BYTE
;===========================

COL		=	0

		REPT	256
		DB	COL
COL		=	COL+1
		ENDM

;----------------------------------------------------------------------------

;=================
;* RGB data tables
;=================

;* Note: The VGA gun value range is 0 .. 63 (6 bits). RGB data extracted
;*       from Deluxe Paint LBM files should be /4 to be scaled correctly.

;===========================
V16_RGB_Data	LABEL	BYTE
;===========================

		DB	000h,000h,000h	;0
		DB	000h,000h,02ah	;1
		DB	000h,02ah,000h	;2
		DB	000h,02ah,02ah	;3
		DB	02ah,000h,000h	;4
		DB	02ah,000h,02ah	;5
		DB	02ah,015h,000h	;6
		DB	02ah,02ah,02ah	;7
		DB	015h,015h,015h	;8
		DB	015h,015h,03fh	;9
		DB	015h,03fh,015h	;10
		DB	015h,03fh,03fh	;11
		DB	03fh,015h,015h	;12
		DB	03fh,015h,03fh	;13
		DB	03fh,03fh,015h	;14
		DB	03fh,03fh,03fh	;15

;===========================
VGA_RGB_Data	LABEL	BYTE
;===========================

		DB	000h,000h,000h	;0
		DB	000h,000h,02ah	;1
		DB	000h,02ah,000h	;2
		DB	000h,02ah,02ah	;3
		DB	02ah,000h,000h	;4
		DB	02ah,000h,02ah	;5
		DB	02ah,015h,000h	;6
		DB	02ah,02ah,02ah	;7
		DB	015h,015h,015h	;8
		DB	015h,015h,03fh	;9
		DB	015h,03fh,015h	;10
		DB	015h,03fh,03fh	;11
		DB	03fh,015h,015h	;12
		DB	03fh,015h,03fh	;13
		DB	03fh,03fh,015h	;14
		DB	03fh,03fh,03fh	;15
		DB	03bh,03bh,03bh	;16
		DB	037h,037h,037h	;17
		DB	034h,034h,034h	;18
		DB	030h,030h,030h	;19
		DB	02dh,02dh,02dh	;20
		DB	02ah,02ah,02ah	;21
		DB	026h,026h,026h	;22
		DB	023h,023h,023h	;23
		DB	01fh,01fh,01fh	;24
		DB	01ch,01ch,01ch	;25
		DB	019h,019h,019h	;26
		DB	015h,015h,015h	;27
		DB	012h,012h,012h	;28
		DB	00eh,00eh,00eh	;29
		DB	00bh,00bh,00bh	;30
		DB	008h,008h,008h	;31
		DB	03fh,000h,000h	;32
		DB	03bh,000h,000h	;33
		DB	038h,000h,000h	;34
		DB	035h,000h,000h	;35
		DB	032h,000h,000h	;36
		DB	02fh,000h,000h	;37
		DB	02ch,000h,000h	;38
		DB	029h,000h,000h	;39
		DB	026h,000h,000h	;40
		DB	022h,000h,000h	;41
		DB	01fh,000h,000h	;42
		DB	01ch,000h,000h	;43
		DB	019h,000h,000h	;44
		DB	016h,000h,000h	;45
		DB	013h,000h,000h	;46
		DB	010h,000h,000h	;47
		DB	03fh,036h,036h	;48
		DB	03fh,02eh,02eh	;49
		DB	03fh,027h,027h	;50
		DB	03fh,01fh,01fh	;51
		DB	03fh,017h,017h	;52
		DB	03fh,010h,010h	;53
		DB	03fh,008h,008h	;54
		DB	03fh,000h,000h	;55
		DB	03fh,02ah,017h	;56
		DB	03fh,026h,010h	;57
		DB	03fh,022h,008h	;58
		DB	03fh,01eh,000h	;59
		DB	039h,01bh,000h	;60
		DB	033h,018h,000h	;61
		DB	02dh,015h,000h	;62
		DB	027h,013h,000h	;63
		DB	03fh,03fh,036h	;64
		DB	03fh,03fh,02eh	;65
		DB	03fh,03fh,027h	;66
		DB	03fh,03fh,01fh	;67
		DB	03fh,03eh,017h	;68
		DB	03fh,03dh,010h	;69
		DB	03fh,03dh,008h	;70
		DB	03fh,03dh,000h	;71
		DB	039h,036h,000h	;72
		DB	033h,031h,000h	;73
		DB	02dh,02bh,000h	;74
		DB	027h,027h,000h	;75
		DB	021h,021h,000h	;76
		DB	01ch,01bh,000h	;77
		DB	016h,015h,000h	;78
		DB	010h,010h,000h	;79
		DB	034h,03fh,017h	;80
		DB	031h,03fh,010h	;81
		DB	02dh,03fh,008h	;82
		DB	028h,03fh,000h	;83
		DB	024h,039h,000h	;84
		DB	020h,033h,000h	;85
		DB	01dh,02dh,000h	;86
		DB	018h,027h,000h	;87
		DB	036h,03fh,036h	;88
		DB	02fh,03fh,02eh	;89
		DB	027h,03fh,027h	;90
		DB	020h,03fh,01fh	;91
		DB	018h,03fh,017h	;92
		DB	010h,03fh,010h	;93
		DB	008h,03fh,008h	;94
		DB	000h,03fh,000h	;95
		DB	000h,03fh,000h	;96
		DB	000h,03bh,000h	;97
		DB	000h,038h,000h	;98
		DB	000h,035h,000h	;99
		DB	001h,032h,000h	;100
		DB	001h,02fh,000h	;101
		DB	001h,02ch,000h	;102
		DB	001h,029h,000h	;103
		DB	001h,026h,000h	;104
		DB	001h,022h,000h	;105
		DB	001h,01fh,000h	;106
		DB	001h,01ch,000h	;107
		DB	001h,019h,000h	;108
		DB	001h,016h,000h	;109
		DB	001h,013h,000h	;110
		DB	001h,010h,000h	;111
		DB	036h,03fh,03fh	;112
		DB	02eh,03fh,03fh	;113
		DB	027h,03fh,03fh	;114
		DB	01fh,03fh,03eh	;115
		DB	017h,03fh,03fh	;116
		DB	010h,03fh,03fh	;117
		DB	008h,03fh,03fh	;118
		DB	000h,03fh,03fh	;119
		DB	000h,039h,039h	;120
		DB	000h,033h,033h	;121
		DB	000h,02dh,02dh	;122
		DB	000h,027h,027h	;123
		DB	000h,021h,021h	;124
		DB	000h,01ch,01ch	;125
		DB	000h,016h,016h	;126
		DB	000h,010h,010h	;127
		DB	017h,02fh,03fh	;128
		DB	010h,02ch,03fh	;129
		DB	008h,02ah,03fh	;130
		DB	000h,027h,03fh	;131
		DB	000h,023h,039h	;132
		DB	000h,01fh,033h	;133
		DB	000h,01bh,02dh	;134
		DB	000h,017h,027h	;135
		DB	036h,036h,03fh	;136
		DB	02eh,02fh,03fh	;137
		DB	027h,027h,03fh	;138
		DB	01fh,020h,03fh	;139
		DB	017h,018h,03fh	;140
		DB	010h,010h,03fh	;141
		DB	008h,009h,03fh	;142
		DB	000h,001h,03fh	;143
		DB	000h,000h,03fh	;144
		DB	000h,000h,03bh	;145
		DB	000h,000h,038h	;146
		DB	000h,000h,035h	;147
		DB	000h,000h,032h	;148
		DB	000h,000h,02fh	;149
		DB	000h,000h,02ch	;150
		DB	000h,000h,029h	;151
		DB	000h,000h,026h	;152
		DB	000h,000h,022h	;153
		DB	000h,000h,01fh	;154
		DB	000h,000h,01ch	;155
		DB	000h,000h,019h	;156
		DB	000h,000h,016h	;157
		DB	000h,000h,013h	;158
		DB	000h,000h,010h	;159
		DB	03ch,036h,03fh	;160
		DB	039h,02eh,03fh	;161
		DB	036h,027h,03fh	;162
		DB	034h,01fh,03fh	;163
		DB	032h,017h,03fh	;164
		DB	02fh,010h,03fh	;165
		DB	02dh,008h,03fh	;166
		DB	02ah,000h,03fh	;167
		DB	026h,000h,039h	;168
		DB	020h,000h,033h	;169
		DB	01dh,000h,02dh	;170
		DB	018h,000h,027h	;171
		DB	014h,000h,021h	;172
		DB	011h,000h,01ch	;173
		DB	00dh,000h,016h	;174
		DB	00ah,000h,010h	;175
		DB	03fh,036h,03fh	;176
		DB	03fh,02eh,03fh	;177
		DB	03fh,027h,03fh	;178
		DB	03fh,01fh,03fh	;179
		DB	03fh,017h,03fh	;180
		DB	03fh,010h,03fh	;181
		DB	03fh,008h,03fh	;182
		DB	03fh,000h,03fh	;183
		DB	038h,000h,039h	;184
		DB	032h,000h,033h	;185
		DB	02dh,000h,02dh	;186
		DB	027h,000h,027h	;187
		DB	021h,000h,021h	;188
		DB	01bh,000h,01ch	;189
		DB	016h,000h,016h	;190
		DB	010h,000h,010h	;191
		DB	03fh,03ah,037h	;192
		DB	03fh,038h,034h	;193
		DB	03fh,036h,031h	;194
		DB	03fh,035h,02fh	;195
		DB	03fh,033h,02ch	;196
		DB	03fh,031h,029h	;197
		DB	03fh,02fh,027h	;198
		DB	03fh,02eh,024h	;199
		DB	03fh,02ch,020h	;200
		DB	03fh,029h,01ch	;201
		DB	03fh,027h,018h	;202
		DB	03ch,025h,017h	;203
		DB	03ah,023h,016h	;204
		DB	037h,022h,015h	;205
		DB	034h,020h,014h	;206
		DB	032h,01fh,013h	;207
		DB	02fh,01eh,012h	;208
		DB	02dh,01ch,011h	;209
		DB	02ah,01ah,010h	;210
		DB	028h,019h,00fh	;211
		DB	027h,018h,00eh	;212
		DB	024h,017h,00dh	;213
		DB	022h,016h,00ch	;214
		DB	020h,014h,00bh	;215
		DB	01dh,013h,00ah	;216
		DB	01bh,012h,009h	;217
		DB	017h,010h,008h	;218
		DB	015h,00fh,007h	;219
		DB	012h,00eh,006h	;220
		DB	010h,00ch,006h	;221
		DB	00eh,00bh,005h	;222
		DB	00ah,008h,003h	;223
		DB	000h,000h,000h	;224
		DB	000h,000h,000h	;225
		DB	000h,000h,000h	;226
		DB	000h,000h,000h	;227
		DB	000h,000h,000h	;228
		DB	000h,000h,000h	;229
		DB	000h,000h,000h	;230
		DB	000h,000h,000h	;231
		DB	031h,00ah,00ah	;232
		DB	031h,013h,00ah	;233
		DB	031h,01dh,00ah	;234
		DB	031h,027h,00ah	;235
		DB	031h,031h,00ah	;236
		DB	027h,031h,00ah	;237
		DB	01dh,031h,00ah	;238
		DB	013h,031h,00ah	;239
		DB	00ah,031h,00ch	;240
		DB	00ah,031h,017h	;241
		DB	00ah,031h,022h	;242
		DB	00ah,031h,02dh	;243
		DB	00ah,02ah,031h	;244
		DB	00ah,01fh,031h	;245
		DB	00ah,014h,031h	;246
		DB	00bh,00ah,031h	;247
		DB	016h,00ah,031h	;248
		DB	021h,00ah,031h	;249
		DB	02ch,00ah,031h	;250
		DB	031h,00ah,02bh	;251
		DB	031h,00ah,020h	;252
		DB	031h,00ah,015h	;253
		DB	031h,00ah,00ah	;254
		DB	03fh,03fh,03fh	;255

;===========================
VGA_RGB_Fade	LABEL	BYTE
;===========================

		DB	256 DUP(0,0,0)	;fade buffer

PALDATA		ENDS

;============================================================================

		END

