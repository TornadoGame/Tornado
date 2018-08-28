;****************************************************************************
;*
;* PALETTES.ASM
;*
;* Palette data for screen drivers.
;*
;* See also PALETTES.INC.
;*
;* 03.08.1989 - KJB
;* 27.07.1992 - KJB - HGC / CGA / TAN palettes removed.
;* 04.10.1992 - KJB - SwapPalettes added.
;* 28.10.1992 - KJB - Night mode palettes sorted.
;* 18.11.1992 - KJB - Night mode palettes now loaded from disk.
;* 18.11.1992 - KJB - Night mode external text palette modified.
;* 17.01.1993 - KJB - Preview mode palette added.
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	FixIRPalette
		PUBLIC	SetIRPalette
		PUBLIC	FixGMRPalette
		PUBLIC	SetGMRPalette
		PUBLIC	InitPalettes
		PUBLIC	SwapPalettes
		PUBLIC	SetHUDLevel

		PUBLIC	HGC_Palette1
		PUBLIC	CGA_Palette1
		PUBLIC	TAN_Palette1
		PUBLIC	VGA_Palette1

		PUBLIC	V16_RGB_Data
		PUBLIC	VGA_RGB_Data
		PUBLIC	VGA_RGB_Fade

		PUBLIC	VGA_Panel
		PUBLIC	VGA_Panel1
		PUBLIC	VGA_Panel2
		PUBLIC	VGA_GND
		PUBLIC	VGA_GND1
		PUBLIC	VGA_GND2
		PUBLIC	VGA_SKY
		PUBLIC	VGA_SKY1
		PUBLIC	VGA_SKY2
		PUBLIC	VGA_EXT_TEXT
		PUBLIC	VGA_EXT_TEXT1
		PUBLIC	VGA_EXT_TEXT2
		PUBLIC	VGA_INFRA_RED

		PUBLIC	PanelLight
		PUBLIC	HUDLevel

		PUBLIC	R_GREY_CLOUD
		PUBLIC	G_GREY_CLOUD
		PUBLIC	B_GREY_CLOUD
		PUBLIC	R_WHITE_CLOUD
		PUBLIC	G_WHITE_CLOUD
		PUBLIC	B_WHITE_CLOUD

		EXTRN	LoadFile:FAR

		EXTRN	SetPaletteFlag:BYTE
		EXTRN	Palette:BYTE
		EXTRN	Night:BYTE
		EXTRN	PreviewMode:BYTE

;============================================================================

		INCLUDE	PALETTES.INC

		INCLUDE	\TORNADO\CONFIG.INC

		INCLUDE	\LIB8086\USEFUL.INC

;============================================================================

PALDATA		SEGMENT PARA PUBLIC 'DATA'

;=====================================================
;* logical colour to physical colour conversion tables
;=====================================================

;===========================	
HGC_Palette1	LABEL	BYTE
;===========================

;===========================
CGA_Palette1	LABEL	BYTE
;===========================

;===========================
TAN_Palette1	LABEL	BYTE
;===========================

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

;* subset of standard EGA colours (0 .. 4)

		DB	000h,000h,000h	;0
		DB	03fh,015h,015h	;1
		DB	03fh,03fh,015h	;2
		DB	015h,03fh,03fh	;3
		DB	03fh,03fh,03fh	;4

;* external panel text colours (5 .. 7)

VGA_EXT_TEXT	DB	000h,01ah,02ah	;5
		DB	020h,02ch,039h	;6
		DB	03fh,023h,005h	;7

;* special night colours (8 .. 23)

		DB	03fh,03fh,03fh	;8
		DB	033h,033h,033h	;9
		DB	028h,028h,028h	;10
		DB	01ch,01ch,01ch	;11
		DB	011h,011h,011h	;12
		DB	03fh,010h,014h	;13
		DB	032h,003h,007h	;14
		DB	029h,000h,000h	;15
		DB	010h,01ah,028h	;16
		DB	009h,010h,019h	;17
		DB	03fh,03ah,025h	;18
		DB	03fh,02eh,000h	;19
		DB	03fh,025h,000h	;20
		DB	014h,03fh,021h	;21
		DB	03fh,033h,033h	;22
		DB	033h,033h,03fh	;23

;* general purpose visual colours (24 .. 70)

		DB	03fh,03fh,03fh	;24
		DB	032h,032h,032h	;25
		DB	025h,025h,025h	;26
		DB	01fh,01fh,01fh	;27
		DB	018h,018h,018h	;28
		DB	000h,000h,000h	;29
		DB	023h,029h,029h	;30
		DB	020h,027h,027h	;31
		DB	01eh,025h,025h	;32
		DB	01bh,023h,023h	;33
		DB	019h,021h,021h	;34
		DB	017h,01fh,01fh	;35
		DB	038h,02fh,021h	;36
		DB	031h,028h,01ch	;37
		DB	02bh,022h,017h	;38
		DB	024h,01bh,013h	;39
		DB	01eh,016h,00fh	;40
		DB	02fh,022h,01ch	;41
		DB	02dh,01fh,019h	;42
		DB	02ch,01dh,016h	;43
		DB	02bh,01ah,014h	;44
		DB	02ah,018h,012h	;45
		DB	038h,038h,038h	;46
		DB	02bh,02bh,02bh	;47
		DB	013h,013h,013h	;48
		DB	00ch,00ch,00ch	;49
		DB	03eh,03fh,000h	;50
		DB	03fh,037h,000h	;51
		DB	03fh,02eh,000h	;52
		DB	03fh,026h,000h	;53
		DB	03fh,020h,000h	;54
		DB	03fh,018h,000h	;55
		DB	000h,032h,022h	;56
		DB	000h,02eh,01eh	;57
		DB	000h,029h,01ch	;58
		DB	000h,021h,019h	;59
		DB	000h,032h,031h	;60
		DB	000h,02ch,02bh	;61
		DB	000h,028h,026h	;62
		DB	000h,025h,023h	;63
		DB	01ch,025h,01ch	;64
		DB	019h,022h,019h	;65
		DB	016h,01fh,016h	;66
		DB	014h,01dh,014h	;67
		DB	012h,01ah,011h	;68
		DB	010h,018h,00fh	;69
		DB	03dh,03dh,03dh	;70
		DB	010h,012h,018h	;71
		DB	000h,000h,004h	;72

;* special visual colours (73 .. 79)

		DB	022h,022h,022h	;73
		DB	01bh,01bh,01bh	;74
VGA_GND		DB	000h,025h,019h	;75
		DB	01eh,025h,023h	;76
		DB	019h,019h,019h	;77
		DB	015h,017h,017h	;78
		DB	000h,01eh,01dh	;79

;* visual hill colours (80 .. 95)

		DB	000h,026h,019h	;80
		DB	002h,027h,01ah	;81
		DB	005h,028h,01bh	;82
		DB	00fh,029h,01ch	;83
		DB	015h,02ah,01ch	;84
		DB	019h,02bh,01ch	;85
		DB	01ch,02ch,01bh	;86
		DB	020h,02ch,01ah	;87
		DB	023h,02ch,019h	;88
		DB	026h,02ch,018h	;89
		DB	028h,02ch,018h	;90
		DB	02ah,02ch,017h	;91
		DB	02ch,02ch,017h	;92
		DB	02eh,02bh,017h	;93
		DB	030h,02ah,017h	;94
		DB	032h,029h,017h	;95

;* visual sky colours (96 .. 111)

VGA_SKY		DB	03fh,03fh,03fh	;96
		DB	03bh,03dh,03fh	;97
		DB	037h,03bh,03fh	;98
		DB	034h,03ah,03fh	;99
		DB	031h,038h,03fh	;100
		DB	02dh,037h,03fh	;101
		DB	02ah,035h,03fh	;102
		DB	026h,033h,03fh	;103
		DB	023h,032h,03fh	;104
		DB	01fh,030h,03fh	;105
		DB	01ch,02fh,03fh	;106
		DB	018h,02dh,03fh	;107
		DB	015h,02bh,03fh	;108
		DB	012h,02ah,03fh	;109
		DB	00eh,028h,03fh	;110
		DB	00bh,027h,03fh	;111

;* moving map hill colours (112 .. 127)

VGA_MiscPanel	LABEL	BYTE

		DB	00bh,022h,00eh	;112
		DB	00bh,023h,00ch	;113
		DB	00dh,025h,00bh	;114
		DB	010h,027h,00ch	;115
		DB	013h,028h,00ch	;116
		DB	016h,02ah,00dh	;117
		DB	01ah,02ch,00dh	;118
		DB	01eh,02dh,00dh	;119
		DB	022h,02fh,00eh	;120
		DB	026h,031h,00eh	;121
		DB	02bh,032h,00eh	;122
		DB	02fh,034h,00fh	;123
		DB	034h,036h,00fh	;124
		DB	037h,035h,00fh	;125
		DB	039h,033h,00fh	;126
		DB	03bh,031h,010h	;127

;* panel / instrument / HUD colours (128 .. 141)

		DB	028h,028h,02bh	;128
		DB	01ch,01ch,020h	;129
		DB	02ah,005h,005h	;130
		DB	01eh,01eh,021h	;131
		DB	00bh,00bh,00fh	;132
VGA_HUD		DB	009h,03ah,011h	;133
		DB	03fh,022h,008h	;134
		DB	01ch,01ch,021h	;135
		DB	038h,03ah,03bh	;136
		DB	000h,000h,000h	;137
		DB	02bh,02bh,02bh	;138
		DB	00ah,013h,022h	;139
		DB	025h,000h,000h	;140
		DB	02dh,007h,000h	;141

;* extra panel colours (142 .. 143)

		DB	000h,030h,000h	;142
		DB	000h,036h,000h	;143

;* moving map colours (144 .. 158)

		DB	00bh,022h,00eh	;144
		DB	020h,014h,00ah	;145
		DB	013h,013h,013h	;146
		DB	008h,00fh,027h	;147
		DB	000h,02ch,02bh	;148
		DB	000h,021h,019h	;149
		DB	000h,02eh,01eh	;150
		DB	000h,000h,000h	;151
		DB	03fh,015h,015h	;152
		DB	02ch,02ch,02ch	;153
		DB	02ah,015h,000h	;154
		DB	000h,000h,000h	;155
		DB	03fh,015h,015h	;156
		DB	02ch,02ch,02ch	;157
		DB	03eh,023h,005h	;158

;* CRT colours (159 .. 175)

		DB	033h,00ah,000h	;159
		DB	000h,009h,001h	;160
		DB	000h,00ch,000h	;161
		DB	000h,00fh,000h	;162
		DB	000h,012h,000h	;163
		DB	000h,015h,000h	;164
		DB	000h,018h,000h	;165
		DB	000h,01bh,000h	;166
		DB	000h,01eh,000h	;167
		DB	000h,021h,000h	;168
		DB	000h,024h,000h	;169
		DB	000h,027h,000h	;170
		DB	000h,02ah,000h	;171
		DB	000h,02dh,000h	;172
		DB	000h,030h,000h	;173
		DB	000h,033h,000h	;174
		DB	000h,036h,000h	;175

;* panel colours (176 .. 255)

VGA_Panel	LABEL	BYTE

		DB	80 DUP(0,0,0)

;----------------------
;* VGA palette overlays
;----------------------

;* standard panel colours (176 .. 255)

VGA_Panel1	LABEL	BYTE

		DB	036h,03bh,039h	;176
		DB	031h,038h,036h	;177
		DB	02dh,036h,033h	;178
		DB	028h,033h,031h	;179
		DB	025h,031h,02fh	;180
		DB	021h,02eh,02dh	;181
		DB	01dh,02ch,02bh	;182
		DB	01ah,029h,029h	;183
		DB	016h,026h,027h	;184
		DB	013h,022h,024h	;185
		DB	011h,01eh,022h	;186
		DB	00eh,01bh,01fh	;187
		DB	00ch,018h,01dh	;188
		DB	009h,014h,01bh	;189
		DB	007h,011h,018h	;190
		DB	006h,00eh,016h	;191
		DB	000h,000h,002h	;192
		DB	003h,003h,006h	;193
		DB	005h,005h,008h	;194
		DB	007h,007h,00bh	;195
		DB	009h,009h,00dh	;196
		DB	00bh,00bh,00fh	;197
		DB	00dh,00dh,011h	;198
		DB	00fh,00fh,013h	;199
		DB	011h,011h,015h	;200
		DB	013h,013h,017h	;201
		DB	015h,015h,019h	;202
		DB	017h,017h,01bh	;203
		DB	01ah,01ah,01eh	;204
		DB	01ch,01ch,020h	;205
		DB	01eh,01eh,022h	;206
		DB	020h,020h,024h	;207
		DB	022h,022h,026h	;208
		DB	024h,024h,028h	;209
		DB	026h,026h,02ah	;210
		DB	028h,028h,02bh	;211
		DB	02ah,02ah,02dh	;212
		DB	02ch,02ch,02fh	;213
		DB	02eh,02eh,031h	;214
		DB	030h,030h,034h	;215
		DB	032h,032h,036h	;216
		DB	034h,034h,038h	;217
		DB	036h,036h,039h	;218
		DB	038h,038h,03bh	;219
		DB	03ah,03ah,03dh	;220
		DB	009h,000h,000h	;221
		DB	010h,001h,001h	;222
		DB	01ch,007h,007h	;223
		DB	024h,003h,003h	;224
		DB	02ah,005h,005h	;225
		DB	033h,009h,007h	;226
		DB	038h,009h,009h	;227
		DB	03fh,00ch,007h	;228
		DB	000h,007h,000h	;229
		DB	00bh,00bh,00fh	;230
		DB	00dh,00dh,012h	;231
		DB	010h,010h,015h	;232
		DB	013h,013h,018h	;233
		DB	015h,015h,019h	;234
		DB	026h,026h,02ah	;235
		DB	02eh,02eh,031h	;236
		DB	036h,022h,000h	;237
		DB	03fh,028h,005h	;238
		DB	033h,020h,000h	;239
		DB	036h,022h,000h	;240
		DB	012h,00ah,000h	;241
		DB	019h,00eh,001h	;242
		DB	027h,01bh,000h	;243
		DB	02bh,01ch,000h	;244
		DB	000h,01eh,000h	;245
		DB	039h,026h,000h	;246
		DB	015h,001h,001h	;247
		DB	03fh,028h,005h	;248
		DB	023h,01fh,01bh	;249
		DB	01fh,01ch,01ch	;250
		DB	025h,01fh,020h	;251
		DB	027h,022h,01eh	;252
		DB	01eh,01ah,016h	;253
		DB	03fh,015h,03fh	;254
		DB	032h,032h,036h	;255

;* standard "look down" colours (176 .. 255)

VGA_Panel2	LABEL	BYTE

		DB	038h,03ah,03bh	;176
		DB	036h,037h,038h	;177
		DB	034h,036h,036h	;178
		DB	032h,033h,034h	;179
		DB	030h,031h,032h	;180
		DB	02eh,02fh,030h	;181
		DB	02ch,02dh,02eh	;182
		DB	02ah,02bh,02ch	;183
		DB	028h,029h,02ah	;184
		DB	025h,027h,027h	;185
		DB	024h,025h,025h	;186
		DB	021h,023h,023h	;187
		DB	020h,021h,021h	;188
		DB	01dh,01eh,01fh	;189
		DB	01bh,01ch,01dh	;190
		DB	019h,01ah,01bh	;191
		DB	017h,018h,018h	;192
		DB	015h,016h,016h	;193
		DB	013h,014h,014h	;194
		DB	011h,012h,012h	;195
		DB	00fh,010h,010h	;196
		DB	00dh,00eh,00eh	;197
		DB	00bh,00bh,00ch	;198
		DB	009h,009h,00ah	;199
		DB	007h,007h,007h	;200
		DB	005h,005h,005h	;201
		DB	003h,003h,003h	;202
		DB	000h,000h,000h	;203
		DB	003h,006h,002h	;204
		DB	005h,007h,003h	;205
		DB	006h,008h,004h	;206
		DB	007h,009h,004h	;207
		DB	007h,00ah,005h	;208
		DB	008h,00bh,005h	;209
		DB	009h,00bh,006h	;210
		DB	009h,00ch,006h	;211
		DB	00ah,00dh,007h	;212
		DB	00bh,00eh,007h	;213
		DB	00bh,00eh,008h	;214
		DB	00ch,00fh,008h	;215
		DB	00dh,010h,009h	;216
		DB	00eh,011h,009h	;217
		DB	00eh,012h,00ah	;218
		DB	00fh,012h,00bh	;219
		DB	010h,013h,00bh	;220
		DB	011h,014h,00ch	;221
		DB	011h,015h,00ch	;222
		DB	012h,015h,00dh	;223
		DB	013h,016h,00eh	;224
		DB	014h,017h,00fh	;225
		DB	015h,018h,00fh	;226
		DB	015h,019h,010h	;227
		DB	016h,019h,011h	;228
		DB	017h,01ah,011h	;229
		DB	018h,01bh,012h	;230
		DB	018h,01ch,013h	;231
		DB	019h,01dh,014h	;232
		DB	01ah,01dh,014h	;233
		DB	01bh,01eh,015h	;234
		DB	01ch,01fh,016h	;235
		DB	020h,023h,019h	;236
		DB	002h,005h,006h	;237
		DB	004h,008h,00eh	;238
		DB	004h,00ah,00dh	;239
		DB	03fh,03dh,01ah	;240
		DB	037h,035h,016h	;241
		DB	030h,02eh,013h	;242
		DB	029h,027h,010h	;243
		DB	021h,01fh,00dh	;244
		DB	01ah,018h,00ah	;245
		DB	013h,011h,007h	;246
		DB	00ch,00bh,004h	;247
		DB	00dh,006h,006h	;248
		DB	011h,006h,006h	;249
		DB	015h,006h,006h	;250
		DB	019h,005h,005h	;251
		DB	01dh,004h,004h	;252
		DB	021h,001h,001h	;253
		DB	025h,000h,000h	;254
		DB	03fh,03fh,03fh	;255

;* HUD colours

VGA_HUD_COLS 	DB	009h,03ah,011h	;(should match VGA_HUD)
		DB	006h,02ah,00ch
		DB	003h,01bh,007h
		DB	001h,00ch,003h

;* ground below clouds

VGA_GND1	DB	000h,025h,019h	;70
		DB	01eh,025h,023h	;71
	
;* ground above clouds

VGA_GND2	DB	03fh,03fh,03fh	;70
		DB	03fh,03fh,03fh	;71

;* clear blue sky

VGA_SKY1	DB	03fh,03fh,03fh	;96
		DB	03bh,03dh,03fh	;97
		DB	037h,03bh,03fh	;98
		DB	034h,03ah,03fh	;99
		DB	031h,038h,03fh	;100
		DB	02dh,037h,03fh	;101
		DB	02ah,035h,03fh	;102
		DB	026h,033h,03fh	;103
		DB	023h,032h,03fh	;104
		DB	01fh,030h,03fh	;105
		DB	01ch,02fh,03fh	;106
		DB	018h,02dh,03fh	;107
		DB	015h,02bh,03fh	;108
		DB	012h,02ah,03fh	;109
		DB	00eh,028h,03fh	;110
		DB	00bh,027h,03fh	;111

;* overcast sky

VGA_SKY2	DB	03fh,03fh,03fh	;96
		DB	03eh,03eh,03eh	;97
		DB	03dh,03dh,03dh	;98
		DB	03ch,03ch,03ch	;99
		DB	03bh,03bh,03bh	;100
		DB	03ah,03ah,03ah	;101
		DB	039h,039h,039h	;102
		DB	038h,038h,038h	;103
		DB	037h,037h,037h	;104
		DB	036h,036h,036h	;105
		DB	035h,035h,035h	;106
		DB	034h,034h,034h	;107
		DB	033h,033h,033h	;108
		DB	032h,032h,032h	;109
		DB	031h,031h,031h	;110
		DB	030h,030h,030h	;111

;* external panel text colours

VGA_EXT_TEXT1	DB	000h,01ah,02ah	;5
		DB	020h,02ch,039h	;6
		DB	03fh,023h,005h	;7

		DB	000h,013h,021h	;5 (night 1)
		DB	016h,01eh,029h	;6
		DB	02eh,018h,002h	;7

		DB	000h,011h,01eh	;5 (night 2)
		DB	014h,01bh,026h	;6
		DB	027h,013h,001h	;7

		DB	000h,00bh,016h	;5 (night 3)
		DB	00eh,012h,01bh	;6
		DB	01dh,00dh,001h	;7

		DB	000h,009h,012h	;5 (night 4)
		DB	00ch,00eh,017h	;6
		DB	016h,009h,001h	;7

;* external panel text colours (view = map or explore)

VGA_EXT_TEXT2	DB	018h,03fh,000h	;5
		DB	03fh,03fh,000h	;6
		DB	03fh,028h,000h	;7

		DB	014h,038h,000h	;5 (night 1)
		DB	037h,038h,000h	;6
		DB	038h,023h,000h	;7

		DB	011h,031h,000h	;5 (night 2)
		DB	031h,033h,000h	;6
		DB	031h,01eh,000h	;7

		DB	00fh,02dh,000h	;5 (night 3)
		DB	02eh,030h,000h	;6
		DB	02eh,01ch,000h	;7

		DB	00bh,029h,000h	;5 (night 4)
		DB	02ah,02dh,000h	;6
		DB	02bh,019h,000h	;7

;* preview mode (176 .. 207)

VGA_Preview 	DB	005h,012h,012h	;176
		DB	005h,012h,012h	;177
		DB	006h,013h,013h	;178
		DB	007h,013h,013h	;179
		DB	008h,014h,014h	;180
		DB	009h,014h,014h	;181
		DB	00ah,015h,015h	;182
		DB	00bh,015h,015h	;183
		DB	00bh,016h,016h	;184
		DB	00dh,017h,017h	;185
		DB	00eh,017h,017h	;186
		DB	00fh,018h,018h	;187
		DB	014h,01ch,01ch	;188
		DB	015h,01eh,01eh	;189
		DB	006h,009h,009h	;190
		DB	019h,023h,023h	;191
		DB	021h,021h,021h	;192
		DB	00fh,018h,018h	;193
		DB	03fh,022h,000h	;194
		DB	000h,000h,000h	;195
		DB	004h,00fh,00fh	;196
		DB	03fh,003h,000h	;197
		DB	03fh,003h,000h	;198
		DB	03fh,003h,000h	;199
		DB	03fh,003h,000h	;200
		DB	03fh,003h,000h	;201
		DB	03fh,003h,000h	;202
		DB	03fh,003h,000h	;203
		DB	03fh,003h,000h	;204
		DB	03fh,003h,000h	;205
		DB	03fh,003h,000h	;206
		DB	03fh,003h,000h	;207

;---------------------------
VGA_RGB_Fade	LABEL	BYTE
;---------------------------

		DB	256 DUP(0,0,0)	;fade buffer

;--------------------------
;* infra-red visual colours
;--------------------------

VGA_INFRA_RED	LABEL	BYTE

		DB	IR_COL_COUNT DUP(0)

PALDATA		ENDS

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

PanelLight	DB	0		;0 = red, 1 = green

HUDLevel	DB	0		;0 .. 3

InitNightHUD	DB	1		;night 1
		DB	1		;night 2
		DB	2		;night 3
		DB	2		;night 4

		EVEN

;---------------------------------
;* night palette overlay filenames
;---------------------------------

;* replace x with G or R (wrt panel light)
;* replace y with 1, 2, 3 or 4 (wrt night mode)

PanelOverlay	DB	"PANEL_xy.RGB",0
KneesOverlay	DB	"KNEES_xy.RGB",0

		EVEN

;---------------------------
RGBFadeColours	LABEL	BYTE
;---------------------------

;* fade into grey clouds (should match overcast COL_SKY16)

R_GREY_CLOUD	DB	48
G_GREY_CLOUD	DB	48
B_GREY_CLOUD	DB	48

;* fade into pure white clouds

R_WHITE_CLOUD	DB	63
G_WHITE_CLOUD	DB	63
B_WHITE_CLOUD	DB	63

		EVEN

DATA		ENDS

;============================================================================

VISCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:VISCODE
		ASSUME DS:DATA

;* FixIRPalette - restore palette translate table (after infra-red visual)
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all
;*
;* note: Works for VGA only.

FixIRPalette	PROC	FAR

		push	ds

		mov	ax,PALDATA
		mov	ds,ax
			 
		mov	si,OFFSET VGA_Palette1+IR_COL_START
		mov	di,OFFSET Palette+IR_COL_START

		mov	cx,IR_COL_COUNT

		FAST_MOVE

		pop	ds

		ret

FixIRPalette	ENDP

;----------------------------------------------------------------------------

;* SetIRPalette - set palette translate table for infra-red visual
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all
;*
;* note: Works for VGA only.

SetIRPalette	PROC	FAR

		push	ds

		mov	ax,PALDATA
		mov	ds,ax
			 
		mov	si,OFFSET VGA_INFRA_RED
		mov	di,OFFSET Palette+IR_COL_START

		mov	cx,IR_COL_COUNT

		FAST_MOVE

		pop	ds

		ret

SetIRPalette	ENDP

;----------------------------------------------------------------------------

;* FixGMRPalette - restore palette translate table (after radar draw)
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all
;*
;* note: Works for VGA only.

FixGMRPalette	PROC	FAR

		mov	Palette[COL_MAP_HILL1],COL_MAP_HILL1
		mov	Palette[COL_MAP_HILL2],COL_MAP_HILL2
		mov	Palette[COL_MAP_HILL3],COL_MAP_HILL3
		mov	Palette[COL_MAP_HILL4],COL_MAP_HILL4
		mov	Palette[COL_MAP_HILL5],COL_MAP_HILL5
		mov	Palette[COL_MAP_HILL6],COL_MAP_HILL6
		mov	Palette[COL_MAP_HILL7],COL_MAP_HILL7
		mov	Palette[COL_MAP_HILL8],COL_MAP_HILL8
		mov	Palette[COL_MAP_HILL9],COL_MAP_HILL9
		mov	Palette[COL_MAP_HILL10],COL_MAP_HILL10
		mov	Palette[COL_MAP_HILL11],COL_MAP_HILL11
		mov	Palette[COL_MAP_HILL12],COL_MAP_HILL12
		mov	Palette[COL_MAP_HILL13],COL_MAP_HILL13
		mov	Palette[COL_MAP_HILL14],COL_MAP_HILL14
		mov	Palette[COL_MAP_HILL15],COL_MAP_HILL15
		mov	Palette[COL_MAP_HILL16],COL_MAP_HILL16

		mov	Palette[COL_MAP_GND1],COL_MAP_GND1
		mov	Palette[COL_MAP_ROAD1],COL_MAP_ROAD1
		mov	Palette[COL_MAP_RAIL1],COL_MAP_RAIL1
		mov	Palette[COL_MAP_RWY1],COL_MAP_RWY1
		mov	Palette[COL_MAP_RIVER1],COL_MAP_RIVER1
		mov	Palette[COL_MAP_GREEN1],COL_MAP_GREEN1
		mov	Palette[COL_MAP_GREEN2],COL_MAP_GREEN2
		mov	Palette[COL_MAP_ALLIED],COL_MAP_ALLIED
		mov	Palette[COL_MAP_RWY2],COL_MAP_RWY2
		mov	Palette[COL_MAP_ENEMY],COL_MAP_ENEMY

		ret

FixGMRPalette	ENDP

;----------------------------------------------------------------------------

;* SetGMRPalette - set palette translate table for radar draw
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all
;*
;* note: Works for VGA only.

SetGMRPalette	PROC	FAR

		mov	Palette[COL_MAP_HILL1],COL_CRT2
		mov	Palette[COL_MAP_HILL2],COL_CRT3
		mov	Palette[COL_MAP_HILL3],COL_CRT2
		mov	Palette[COL_MAP_HILL4],COL_CRT3
		mov	Palette[COL_MAP_HILL5],COL_CRT4
		mov	Palette[COL_MAP_HILL6],COL_CRT5
		mov	Palette[COL_MAP_HILL7],COL_CRT4
		mov	Palette[COL_MAP_HILL8],COL_CRT5
		mov	Palette[COL_MAP_HILL9],COL_CRT6
		mov	Palette[COL_MAP_HILL10],COL_CRT7
		mov	Palette[COL_MAP_HILL11],COL_CRT6
		mov	Palette[COL_MAP_HILL12],COL_CRT7
		mov	Palette[COL_MAP_HILL13],COL_CRT8
		mov	Palette[COL_MAP_HILL14],COL_CRT9
		mov	Palette[COL_MAP_HILL15],COL_CRT8
		mov	Palette[COL_MAP_HILL16],COL_CRT9

		mov	Palette[COL_MAP_GND1],COL_CRT1
		mov	Palette[COL_MAP_ROAD1],COL_CRT4
		mov	Palette[COL_MAP_RAIL1],COL_CRT8
		mov	Palette[COL_MAP_RWY1],COL_CRT4
		mov	Palette[COL_MAP_RIVER1],COL_CRT6
		mov	Palette[COL_MAP_GREEN1],COL_CRT2
		mov	Palette[COL_MAP_GREEN2],COL_CRT3
		mov	Palette[COL_MAP_ALLIED],COL_CRT8
		mov	Palette[COL_MAP_RWY2],COL_CRT4
		mov	Palette[COL_MAP_ENEMY],COL_CRT8

		ret

SetGMRPalette	ENDP

;----------------------------------------------------------------------------

;* InitPalettes - init palettes wrt visual configuration
;*
;* pass: nothing
;* ret : cf = 0 = ok
;*       cf = 1 = palette RGB data load error
;* kill: assume all

InitPalettes	PROC	NEAR

		mov	SetPaletteFlag,1	;reload palette

;-------------------
;* sort preview mode
;-------------------

		cmp	PreviewMode,0		;preview mode?
		je	SkipPreview		;no ->

		mov	ax,PALDATA
		mov	ds,ax
		mov	es,ax

		mov	si,OFFSET VGA_Preview
		mov	di,OFFSET VGA_Panel

		mov	cx,32*3

		rep	movsb

		mov	ax,DATA
		mov	ds,ax
		mov	es,ax

		jmp	PaletteOk

;------------------------
;* sort infra-red colours (must be done before palette is modified for night mode)
;------------------------

SkipPreview:	mov	ax,PALDATA
		mov	ds,ax
		mov	es,ax

		mov	si,OFFSET VGA_RGB_Data+(IR_COL_START*3)
		mov	di,OFFSET VGA_INFRA_RED

		mov	cx,IR_COL_COUNT

;* grey scale = R * 0.3 + G * 0.59 + B * 0.11

IRLoop:		lodsb			;R
		mov	ah,al		;R * 256
		xor	al,al
		mov	dx,9830		;0.3 = 9830 / 32768
		imul	dx		;R * 256 * 0.3

		mov	bx,ax		;(R * 0.3)
		mov	bp,dx

		lodsb			;G
		mov	ah,al		;G * 256
		xor	al,al
		mov	dx,19333	;0.59 = 19333 / 32768
		imul	dx		;G * 256 * 0.59

		add	bx,ax		;(R * 0.3 + G * 0.59)
		adc	bp,dx

		lodsb			;B
		mov	ah,al		;B * 256
		xor	al,al
		mov	dx,3604		;0.11 = 3604 / 32768
		imul	dx		;B * 256 * 0.11

		add	ax,bx		;(R * 0.3 + G * 0.59 + B * 0.11)
		adc	dx,bp

		shl	ax,1		;*2 (adjust after fractional multiply)
		rcl	dx,1

		shl	ax,1
		ROUNDUP	dx		;dh = 0 .. 63

		REPT	2
		shr	dh,1		;0 .. 15
		ENDM

		mov	al,COL_CRT1
		add	al,dh

		stosb

		loop	IRLoop

;--------------------------------------
;* fix some colours which convert badly
;--------------------------------------

		ASSUME	DS:PALDATA

		mov	VGA_INFRA_RED[COL_RWY1-IR_COL_START],COL_CRT5
		mov	VGA_INFRA_RED[COL_RAIL1-IR_COL_START],COL_CRT5
		mov	VGA_INFRA_RED[COL_RAIL2-IR_COL_START],COL_CRT4

		ASSUME	DS:DATA

		mov	ax,DATA
		mov	ds,ax
		mov	es,ax

;---------------------------------------
;* modify palette colours wrt night mode
;---------------------------------------

		mov	cl,Night
		test	cl,cl		;night?
		_JZ	PaletteOk	;no ->

;* modify visual colours (divide wrt night mode)

		mov	ax,PALDATA
		mov	ds,ax
		mov	es,ax

		mov	si,OFFSET VGA_RGB_Data+(NIGHT_COL_START*3)
		mov	bp,NIGHT_COL_COUNT*3
		call	ScaleRGBValues

		mov	si,OFFSET VGA_GND1
		mov	bp,2*3
		call	ScaleRGBValues

		mov	si,OFFSET VGA_GND2
		mov	bp,2*3
		call	ScaleRGBValues

		mov	si,OFFSET VGA_SKY1
		mov	bp,16*3
		call	ScaleRGBValues

		mov	si,OFFSET VGA_SKY2
		mov	bp,16*3
		call	ScaleRGBValues

		mov	ax,DATA
		mov	ds,ax
		mov	es,ax

;* overlay night panel palettes

		call	SetNightPanel
		jc	ExitPalettes	;palette RGB data load error ->

;* modify fade colours (divide wrt night mode)

		mov	si,OFFSET RGBFadeColours
		mov	bp,2*3
		mov	cl,Night
		call	ScaleRGBValues

;* init HUD colour wrt night mode

		mov	al,Night	;1 .. 4
		dec	al		;0 .. 3
		mov	bx,OFFSET InitNightHUD
		xlat
		mov	HUDLevel,al

		call	SetHUDLevel

PaletteOk:	clc			;cf = 0 = ok

ExitPalettes:	ret

InitPalettes	ENDP

;----------------------------------------------------------------------------

;* ScaleRGBValues
;*
;* pass: si -> RGB data
;*       bp = count
;*       cl = scale factor
;* ret : nothing
;* kill: si, bp, flags

ScaleRGBValues	PROC	NEAR

@@:		mov	al,[si]
		shr	al,cl
		ROUNDUP	al
		mov	[si],al

		inc	si

		dec	bp
		jnz	@B

		ret

ScaleRGBValues	ENDP

;----------------------------------------------------------------------------

;* SwapPalettes
;*
;* pass: es:di -> new palette
;* ret : nothing
;* kill: assume all

SwapPalettes	PROC	FAR

		mov	SetPaletteFlag,1	;reload palette

		push	ds

		mov	ax,SEG VGA_RGB_Data
		mov	ds,ax

		mov	si,OFFSET VGA_RGB_Data

		mov	cx,256*3

@@:		mov	al,[si]
		xchg	al,es:[di]
		mov	[si],al

		inc	si
		inc	di

		loop	@B

		pop	ds
		
		ret

SwapPalettes	ENDP

;----------------------------------------------------------------------------

;* SetNightPanel
;*
;* pass: PanelLight
;*	 Night
;* ret : cf = 0 = ok
;*       cf = 1 = palette RGB data load error
;* kill: assume all

SetNightPanel	PROC	NEAR

;---------------
;* sort filename (wrt panel lighting and night mode)
;---------------

		mov	al,'R'		;assume red lighting

		cmp	PanelLight,0	;red?
		je	@F		;yes ->

		mov	al,'G'

@@:		mov	PanelOverlay[6],al
		mov	KneesOverlay[6],al

		mov	al,Night
		add	al,'0'
		mov	PanelOverlay[7],al
		mov	KneesOverlay[7],al

;---------------
;* load palettes
;---------------

;* load panel RGB data

		mov	ax,PALDATA
		mov	es,ax

		mov	cx,144*3
		mov	dx,OFFSET PanelOverlay
		mov	di,OFFSET VGA_MiscPanel

	IF	OPT_DEMO EQ 0

		call	LoadFile
		jc	ExitNightPanel	;palette RGB data load error ->

	ENDIF

;* copy VGA_Panel data to VGA_Panel1

		mov	ax,PALDATA
		mov	ds,ax

		mov	cx,80*3
		mov	si,OFFSET VGA_Panel
		mov	di,OFFSET VGA_Panel1
		FAST_MOVE

		mov	ax,DATA
		mov	ds,ax

;* load kneepad RGB data

		mov	cx,80*3
		mov	dx,OFFSET KneesOverlay
		mov	di,OFFSET VGA_Panel2

	IF	OPT_DEMO EQ 0

		call	LoadFile
		jc	ExitNightPanel	;palette RGB data load error ->

	ENDIF

;-----------------------------
;* sort external text palettes (wrt night mode)
;-----------------------------

		mov	al,Night	;1, 2, 3, 4
		mov	ah,3*3
		mul	ah		;9, 18, 27, 36
		mov	bx,ax		

		mov	ax,PALDATA
		mov	ds,ax

		mov	cx,3*3
		mov	si,OFFSET VGA_EXT_TEXT1
		add	si,bx
		mov	di,OFFSET VGA_EXT_TEXT
		FAST_MOVE

		mov	cx,3*3
		mov	si,OFFSET VGA_EXT_TEXT1
		add	si,bx
		mov	di,OFFSET VGA_EXT_TEXT1
		FAST_MOVE

		mov	cx,3*3
		mov	si,OFFSET VGA_EXT_TEXT2
		add	si,bx
		mov	di,OFFSET VGA_EXT_TEXT2
		FAST_MOVE

		clc			;cf = 0 = ok

ExitNightPanel:	mov	ax,DATA
		mov	ds,ax
		mov	es,ax

		ret

SetNightPanel	ENDP

;----------------------------------------------------------------------------

;* SetHUDLevel
;*
;* pass: HUDLevel
;* ret : nothing
;* kill: assume all

SetHUDLevel	PROC	FAR

		mov	SetPaletteFlag,1

		mov	al,HUDLevel
		xor	ah,ah

		mov	dx,ax
		add	ax,ax		;*2
		add	ax,dx		;*3

		mov	si,OFFSET VGA_HUD_COLS

		add	si,ax

		mov	ax,PALDATA
		mov	ds,ax
		mov	es,ax

		mov	di,OFFSET VGA_HUD
		mov	cx,1*3
		rep	movsb

		mov	ax,DATA
		mov	ds,ax
		mov	es,ax

		ret

SetHUDLevel	ENDP

VISCODE		ENDS

;============================================================================

		END

