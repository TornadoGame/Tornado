;****************************************************************************
;*
;* TRIG.ASM
;*
;* Miscellaneous trig functions / look up tables etc.
;*
;* See TRIG.INC
;*
;* 21.07.1989 - KJB
;* 24.01.1992 - KJB - New ArcTanTable added.
;*                    FastArcTan and ArcTan routines added.
;* 11.03.1992 - KJB - ArcTanTable extended.
;*                    FastArcTan2 and ArcTan2 routines added.
;* 11.12.1992 - KJB - ArcSinTable and FastArcSin routine added.
;*	     	      ArcCosTable and FastArcCos routine added.
;* 17.03.1993 - KJB - ArcSin / ArcCos tables moved to stack segment.
;* 21.03.1993 - KJB - Tan / ArcTan tables moved to stack segment.
;* 04.04.1993 - KJB - ArcTan360 added.
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	Tangent
		PUBLIC	FastArcTan
		PUBLIC	ArcTan
		PUBLIC	FastArcTan2
		PUBLIC	ArcTan2
		PUBLIC	FastArcSin
		PUBLIC	FastArcCos
		PUBLIC	ArcTan360

		PUBLIC	SinTable
		PUBLIC	CosTable
		PUBLIC	TanTable
		PUBLIC	ArcTanTable
		PUBLIC	OctTrigTable
		PUBLIC	OctSignTable
		PUBLIC	ArcSinTable
		PUBLIC	ArcCosTable

;============================================================================

		INCLUDE	USEFUL.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

;----------------------------------------------------------------------------
;*
;* sine and cosine tables (0 .. 511 pseudo degs = 0 .. 359 real degrees)
;*
;* use p degs to look up sin(p deg) * 32767 or cos(p deg) * 32767
;*
;* example of use:-
;*
;* 	bx = p degs
;*
;*	and	bx,001ffh	;ensure 0 - 511
;*      shl	bx,1
;*      mov	ax,SinTable[bx]
;*
;----------------------------------------------------------------------------

SinTable	LABEL	WORD

		DW	00000h		;sin(0 p degs)
		DW	00192h		;sin(1 p degs)
		DW	00324h		;sin(2 p degs)
		DW	004B6h		;sin(3 p degs)
		DW	00648h		;sin(4 p degs)
		DW	007D9h		;sin(5 p degs)
		DW	0096Ah		;sin(6 p degs)
		DW	00AFBh		;sin(7 p degs)
		DW	00C8Ch		;sin(8 p degs)
		DW	00E1Ch		;sin(9 p degs)
		DW	00FABh		;sin(10 p degs)
		DW	0113Ah		;sin(11 p degs)
		DW	012C8h		;sin(12 p degs)
		DW	01455h		;sin(13 p degs)
		DW	015E2h		;sin(14 p degs)
		DW	0176Eh		;sin(15 p degs)
		DW	018F9h		;sin(16 p degs)
		DW	01A82h		;sin(17 p degs)
		DW	01C0Bh		;sin(18 p degs)
		DW	01D93h		;sin(19 p degs)
		DW	01F1Ah		;sin(20 p degs)
		DW	0209Fh		;sin(21 p degs)
		DW	02223h		;sin(22 p degs)
		DW	023A6h		;sin(23 p degs)
		DW	02528h		;sin(24 p degs)
		DW	026A8h		;sin(25 p degs)
		DW	02826h		;sin(26 p degs)
		DW	029A3h		;sin(27 p degs)
		DW	02B1Fh		;sin(28 p degs)
		DW	02C99h		;sin(29 p degs)
		DW	02E11h		;sin(30 p degs)
		DW	02F87h		;sin(31 p degs)
		DW	030FBh		;sin(32 p degs)
		DW	0326Eh		;sin(33 p degs)
		DW	033DFh		;sin(34 p degs)
		DW	0354Dh		;sin(35 p degs)
		DW	036BAh		;sin(36 p degs)
		DW	03824h		;sin(37 p degs)
		DW	0398Ch		;sin(38 p degs)
		DW	03AF2h		;sin(39 p degs)
		DW	03C56h		;sin(40 p degs)
		DW	03DB8h		;sin(41 p degs)
		DW	03F17h		;sin(42 p degs)
		DW	04073h		;sin(43 p degs)
		DW	041CEh		;sin(44 p degs)
		DW	04325h		;sin(45 p degs)
		DW	0447Ah		;sin(46 p degs)
		DW	045CDh		;sin(47 p degs)
		DW	0471Ch		;sin(48 p degs)
		DW	04869h		;sin(49 p degs)
		DW	049B4h		;sin(50 p degs)
		DW	04AFBh		;sin(51 p degs)
		DW	04C3Fh		;sin(52 p degs)
		DW	04D81h		;sin(53 p degs)
		DW	04EBFh		;sin(54 p degs)
		DW	04FFBh		;sin(55 p degs)
		DW	05133h		;sin(56 p degs)
		DW	05268h		;sin(57 p degs)
		DW	0539Bh		;sin(58 p degs)
		DW	054C9h		;sin(59 p degs)
		DW	055F5h		;sin(60 p degs)
		DW	0571Dh		;sin(61 p degs)
		DW	05842h		;sin(62 p degs)
		DW	05964h		;sin(63 p degs)
		DW	05A82h		;sin(64 p degs)
		DW	05B9Ch		;sin(65 p degs)
		DW	05CB3h		;sin(66 p degs)
		DW	05DC7h		;sin(67 p degs)
		DW	05ED7h		;sin(68 p degs)
		DW	05FE3h		;sin(69 p degs)
		DW	060EBh		;sin(70 p degs)
		DW	061F0h		;sin(71 p degs)
		DW	062F1h		;sin(72 p degs)
		DW	063EEh		;sin(73 p degs)
		DW	064E8h		;sin(74 p degs)
		DW	065DDh		;sin(75 p degs)
		DW	066CFh		;sin(76 p degs)
		DW	067BCh		;sin(77 p degs)
		DW	068A6h		;sin(78 p degs)
		DW	0698Bh		;sin(79 p degs)
		DW	06A6Dh		;sin(80 p degs)
		DW	06B4Ah		;sin(81 p degs)
		DW	06C23h		;sin(82 p degs)
		DW	06CF8h		;sin(83 p degs)
		DW	06DC9h		;sin(84 p degs)
		DW	06E96h		;sin(85 p degs)
		DW	06F5Eh		;sin(86 p degs)
		DW	07022h		;sin(87 p degs)
		DW	070E2h		;sin(88 p degs)
		DW	0719Dh		;sin(89 p degs)
		DW	07254h		;sin(90 p degs)
		DW	07307h		;sin(91 p degs)
		DW	073B5h		;sin(92 p degs)
		DW	0745Fh		;sin(93 p degs)
		DW	07504h		;sin(94 p degs)
		DW	075A5h		;sin(95 p degs)
		DW	07641h		;sin(96 p degs)
		DW	076D8h		;sin(97 p degs)
		DW	0776Bh		;sin(98 p degs)
		DW	077FAh		;sin(99 p degs)
		DW	07884h		;sin(100 p degs)
		DW	07909h		;sin(101 p degs)
		DW	07989h		;sin(102 p degs)
		DW	07A05h		;sin(103 p degs)
		DW	07A7Ch		;sin(104 p degs)
		DW	07AEEh		;sin(105 p degs)
		DW	07B5Ch		;sin(106 p degs)
		DW	07BC5h		;sin(107 p degs)
		DW	07C29h		;sin(108 p degs)
		DW	07C88h		;sin(109 p degs)
		DW	07CE3h		;sin(110 p degs)
		DW	07D39h		;sin(111 p degs)
		DW	07D89h		;sin(112 p degs)
		DW	07DD5h		;sin(113 p degs)
		DW	07E1Dh		;sin(114 p degs)
		DW	07E5Fh		;sin(115 p degs)
		DW	07E9Ch		;sin(116 p degs)
		DW	07ED5h		;sin(117 p degs)
		DW	07F09h		;sin(118 p degs)
		DW	07F37h		;sin(119 p degs)
		DW	07F61h		;sin(120 p degs)
		DW	07F86h		;sin(121 p degs)
		DW	07FA6h		;sin(122 p degs)
		DW	07FC1h		;sin(123 p degs)
		DW	07FD8h		;sin(124 p degs)
		DW	07FE9h		;sin(125 p degs)
		DW	07FF5h		;sin(126 p degs)
		DW	07FFDh		;sin(127 p degs)

CosTable	LABEL	WORD

		DW	07FFFh		;sin(128 p degs)
		DW	07FFDh		;sin(129 p degs)
		DW	07FF5h		;sin(130 p degs)
		DW	07FE9h		;sin(131 p degs)
		DW	07FD8h		;sin(132 p degs)
		DW	07FC1h		;sin(133 p degs)
		DW	07FA6h		;sin(134 p degs)
		DW	07F86h		;sin(135 p degs)
		DW	07F61h		;sin(136 p degs)
		DW	07F37h		;sin(137 p degs)
		DW	07F09h		;sin(138 p degs)
		DW	07ED5h		;sin(139 p degs)
		DW	07E9Ch		;sin(140 p degs)
		DW	07E5Fh		;sin(141 p degs)
		DW	07E1Dh		;sin(142 p degs)
		DW	07DD5h		;sin(143 p degs)
		DW	07D89h		;sin(144 p degs)
		DW	07D39h		;sin(145 p degs)
		DW	07CE3h		;sin(146 p degs)
		DW	07C88h		;sin(147 p degs)
		DW	07C29h		;sin(148 p degs)
		DW	07BC5h		;sin(149 p degs)
		DW	07B5Ch		;sin(150 p degs)
		DW	07AEEh		;sin(151 p degs)
		DW	07A7Ch		;sin(152 p degs)
		DW	07A05h		;sin(153 p degs)
		DW	07989h		;sin(154 p degs)
		DW	07909h		;sin(155 p degs)
		DW	07884h		;sin(156 p degs)
		DW	077FAh		;sin(157 p degs)
		DW	0776Bh		;sin(158 p degs)
		DW	076D8h		;sin(159 p degs)
		DW	07641h		;sin(160 p degs)
		DW	075A5h		;sin(161 p degs)
		DW	07504h		;sin(162 p degs)
		DW	0745Fh		;sin(163 p degs)
		DW	073B5h		;sin(164 p degs)
		DW	07307h		;sin(165 p degs)
		DW	07254h		;sin(166 p degs)
		DW	0719Dh		;sin(167 p degs)
		DW	070E2h		;sin(168 p degs)
		DW	07022h		;sin(169 p degs)
		DW	06F5Eh		;sin(170 p degs)
		DW	06E96h		;sin(171 p degs)
		DW	06DC9h		;sin(172 p degs)
		DW	06CF8h		;sin(173 p degs)
		DW	06C23h		;sin(174 p degs)
		DW	06B4Ah		;sin(175 p degs)
		DW	06A6Dh		;sin(176 p degs)
		DW	0698Bh		;sin(177 p degs)
		DW	068A6h		;sin(178 p degs)
		DW	067BCh		;sin(179 p degs)
		DW	066CFh		;sin(180 p degs)
		DW	065DDh		;sin(181 p degs)
		DW	064E8h		;sin(182 p degs)
		DW	063EEh		;sin(183 p degs)
		DW	062F1h		;sin(184 p degs)
		DW	061F0h		;sin(185 p degs)
		DW	060EBh		;sin(186 p degs)
		DW	05FE3h		;sin(187 p degs)
		DW	05ED7h		;sin(188 p degs)
		DW	05DC7h		;sin(189 p degs)
		DW	05CB3h		;sin(190 p degs)
		DW	05B9Ch		;sin(191 p degs)
		DW	05A82h		;sin(192 p degs)
		DW	05964h		;sin(193 p degs)
		DW	05842h		;sin(194 p degs)
		DW	0571Dh		;sin(195 p degs)
		DW	055F5h		;sin(196 p degs)
		DW	054C9h		;sin(197 p degs)
		DW	0539Ah		;sin(198 p degs)
		DW	05268h		;sin(199 p degs)
		DW	05133h		;sin(200 p degs)
		DW	04FFBh		;sin(201 p degs)
		DW	04EBFh		;sin(202 p degs)
		DW	04D81h		;sin(203 p degs)
		DW	04C3Fh		;sin(204 p degs)
		DW	04AFBh		;sin(205 p degs)
		DW	049B3h		;sin(206 p degs)
		DW	04869h		;sin(207 p degs)
		DW	0471Ch		;sin(208 p degs)
		DW	045CDh		;sin(209 p degs)
		DW	0447Ah		;sin(210 p degs)
		DW	04325h		;sin(211 p degs)
		DW	041CEh		;sin(212 p degs)
		DW	04073h		;sin(213 p degs)
		DW	03F17h		;sin(214 p degs)
		DW	03DB8h		;sin(215 p degs)
		DW	03C56h		;sin(216 p degs)
		DW	03AF2h		;sin(217 p degs)
		DW	0398Ch		;sin(218 p degs)
		DW	03824h		;sin(219 p degs)
		DW	036BAh		;sin(220 p degs)
		DW	0354Dh		;sin(221 p degs)
		DW	033DEh		;sin(222 p degs)
		DW	0326Eh		;sin(223 p degs)
		DW	030FBh		;sin(224 p degs)
		DW	02F87h		;sin(225 p degs)
		DW	02E11h		;sin(226 p degs)
		DW	02C99h		;sin(227 p degs)
		DW	02B1Fh		;sin(228 p degs)
		DW	029A3h		;sin(229 p degs)
		DW	02826h		;sin(230 p degs)
		DW	026A8h		;sin(231 p degs)
		DW	02528h		;sin(232 p degs)
		DW	023A6h		;sin(233 p degs)
		DW	02223h		;sin(234 p degs)
		DW	0209Fh		;sin(235 p degs)
		DW	01F1Ah		;sin(236 p degs)
		DW	01D93h		;sin(237 p degs)
		DW	01C0Bh		;sin(238 p degs)
		DW	01A82h		;sin(239 p degs)
		DW	018F8h		;sin(240 p degs)
		DW	0176Eh		;sin(241 p degs)
		DW	015E2h		;sin(242 p degs)
		DW	01455h		;sin(243 p degs)
		DW	012C8h		;sin(244 p degs)
		DW	0113Ah		;sin(245 p degs)
		DW	00FABh		;sin(246 p degs)
		DW	00E1Bh		;sin(247 p degs)
		DW	00C8Ch		;sin(248 p degs)
		DW	00AFBh		;sin(249 p degs)
		DW	0096Ah		;sin(250 p degs)
		DW	007D9h		;sin(251 p degs)
		DW	00648h		;sin(252 p degs)
		DW	004B6h		;sin(253 p degs)
		DW	00324h		;sin(254 p degs)
		DW	00192h		;sin(255 p degs)
		DW	00000h		;sin(256 p degs)
		DW	0FE6Eh		;sin(257 p degs)
		DW	0FCDCh		;sin(258 p degs)
		DW	0FB4Ah		;sin(259 p degs)
		DW	0F9B8h		;sin(260 p degs)
		DW	0F827h		;sin(261 p degs)
		DW	0F695h		;sin(262 p degs)
		DW	0F505h		;sin(263 p degs)
		DW	0F374h		;sin(264 p degs)
		DW	0F1E4h		;sin(265 p degs)
		DW	0F055h		;sin(266 p degs)
		DW	0EEC6h		;sin(267 p degs)
		DW	0ED38h		;sin(268 p degs)
		DW	0EBABh		;sin(269 p degs)
		DW	0EA1Eh		;sin(270 p degs)
		DW	0E892h		;sin(271 p degs)
		DW	0E707h		;sin(272 p degs)
		DW	0E57Dh		;sin(273 p degs)
		DW	0E3F5h		;sin(274 p degs)
		DW	0E26Dh		;sin(275 p degs)
		DW	0E0E6h		;sin(276 p degs)
		DW	0DF61h		;sin(277 p degs)
		DW	0DDDCh		;sin(278 p degs)
		DW	0DC5Ah		;sin(279 p degs)
		DW	0DAD8h		;sin(280 p degs)
		DW	0D958h		;sin(281 p degs)
		DW	0D7D9h		;sin(282 p degs)
		DW	0D65Ch		;sin(283 p degs)
		DW	0D4E1h		;sin(284 p degs)
		DW	0D367h		;sin(285 p degs)
		DW	0D1EFh		;sin(286 p degs)
		DW	0D079h		;sin(287 p degs)
		DW	0CF04h		;sin(288 p degs)
		DW	0CD92h		;sin(289 p degs)
		DW	0CC21h		;sin(290 p degs)
		DW	0CAB3h		;sin(291 p degs)
		DW	0C946h		;sin(292 p degs)
		DW	0C7DCh		;sin(293 p degs)
		DW	0C673h		;sin(294 p degs)
		DW	0C50Dh		;sin(295 p degs)
		DW	0C3AAh		;sin(296 p degs)
		DW	0C248h		;sin(297 p degs)
		DW	0C0E9h		;sin(298 p degs)
		DW	0BF8Ch		;sin(299 p degs)
		DW	0BE32h		;sin(300 p degs)
		DW	0BCDBh		;sin(301 p degs)
		DW	0BB86h		;sin(302 p degs)
		DW	0BA33h		;sin(303 p degs)
		DW	0B8E3h		;sin(304 p degs)
		DW	0B796h		;sin(305 p degs)
		DW	0B64Ch		;sin(306 p degs)
		DW	0B505h		;sin(307 p degs)
		DW	0B3C1h		;sin(308 p degs)
		DW	0B27Fh		;sin(309 p degs)
		DW	0B141h		;sin(310 p degs)
		DW	0B005h		;sin(311 p degs)
		DW	0AECDh		;sin(312 p degs)
		DW	0AD97h		;sin(313 p degs)
		DW	0AC65h		;sin(314 p degs)
		DW	0AB36h		;sin(315 p degs)
		DW	0AA0Bh		;sin(316 p degs)
		DW	0A8E3h		;sin(317 p degs)
		DW	0A7BEh		;sin(318 p degs)
		DW	0A69Ch		;sin(319 p degs)
		DW	0A57Eh		;sin(320 p degs)
		DW	0A463h		;sin(321 p degs)
		DW	0A34Ch		;sin(322 p degs)
		DW	0A239h		;sin(323 p degs)
		DW	0A129h		;sin(324 p degs)
		DW	0A01Dh		;sin(325 p degs)
		DW	09F14h		;sin(326 p degs)
		DW	09E10h		;sin(327 p degs)
		DW	09D0Fh		;sin(328 p degs)
		DW	09C11h		;sin(329 p degs)
		DW	09B18h		;sin(330 p degs)
		DW	09A23h		;sin(331 p degs)
		DW	09931h		;sin(332 p degs)
		DW	09844h		;sin(333 p degs)
		DW	0975Ah		;sin(334 p degs)
		DW	09675h		;sin(335 p degs)
		DW	09593h		;sin(336 p degs)
		DW	094B6h		;sin(337 p degs)
		DW	093DDh		;sin(338 p degs)
		DW	09308h		;sin(339 p degs)
		DW	09237h		;sin(340 p degs)
		DW	0916Ah		;sin(341 p degs)
		DW	090A2h		;sin(342 p degs)
		DW	08FDEh		;sin(343 p degs)
		DW	08F1Eh		;sin(344 p degs)
		DW	08E63h		;sin(345 p degs)
		DW	08DACh		;sin(346 p degs)
		DW	08CF9h		;sin(347 p degs)
		DW	08C4Bh		;sin(348 p degs)
		DW	08BA1h		;sin(349 p degs)
		DW	08AFCh		;sin(350 p degs)
		DW	08A5Bh		;sin(351 p degs)
		DW	089BFh		;sin(352 p degs)
		DW	08928h		;sin(353 p degs)
		DW	08895h		;sin(354 p degs)
		DW	08806h		;sin(355 p degs)
		DW	0877Ch		;sin(356 p degs)
		DW	086F7h		;sin(357 p degs)
		DW	08677h		;sin(358 p degs)
		DW	085FBh		;sin(359 p degs)
		DW	08584h		;sin(360 p degs)
		DW	08511h		;sin(361 p degs)
		DW	084A4h		;sin(362 p degs)
		DW	0843Bh		;sin(363 p degs)
		DW	083D7h		;sin(364 p degs)
		DW	08378h		;sin(365 p degs)
		DW	0831Dh		;sin(366 p degs)
		DW	082C7h		;sin(367 p degs)
		DW	08277h		;sin(368 p degs)
		DW	0822Bh		;sin(369 p degs)
		DW	081E3h		;sin(370 p degs)
		DW	081A1h		;sin(371 p degs)
		DW	08164h		;sin(372 p degs)
		DW	0812Bh		;sin(373 p degs)
		DW	080F7h		;sin(374 p degs)
		DW	080C9h		;sin(375 p degs)
		DW	0809Fh		;sin(376 p degs)
		DW	0807Ah		;sin(377 p degs)
		DW	0805Ah		;sin(378 p degs)
		DW	0803Fh		;sin(379 p degs)
		DW	08028h		;sin(380 p degs)
		DW	08017h		;sin(381 p degs)
		DW	0800Bh		;sin(382 p degs)
		DW	08003h		;sin(383 p degs)
		DW	08001h		;sin(384 p degs)
		DW	08003h		;sin(385 p degs)
		DW	0800Bh		;sin(386 p degs)
		DW	08017h		;sin(387 p degs)
		DW	08028h		;sin(388 p degs)
		DW	0803Fh		;sin(389 p degs)
		DW	0805Ah		;sin(390 p degs)
		DW	0807Ah		;sin(391 p degs)
		DW	0809Fh		;sin(392 p degs)
		DW	080C9h		;sin(393 p degs)
		DW	080F7h		;sin(394 p degs)
		DW	0812Bh		;sin(395 p degs)
		DW	08164h		;sin(396 p degs)
		DW	081A1h		;sin(397 p degs)
		DW	081E3h		;sin(398 p degs)
		DW	0822Bh		;sin(399 p degs)
		DW	08277h		;sin(400 p degs)
		DW	082C8h		;sin(401 p degs)
		DW	0831Dh		;sin(402 p degs)
		DW	08378h		;sin(403 p degs)
		DW	083D7h		;sin(404 p degs)
		DW	0843Bh		;sin(405 p degs)
		DW	084A4h		;sin(406 p degs)
		DW	08512h		;sin(407 p degs)
		DW	08584h		;sin(408 p degs)
		DW	085FBh		;sin(409 p degs)
		DW	08677h		;sin(410 p degs)
		DW	086F7h		;sin(411 p degs)
		DW	0877Dh		;sin(412 p degs)
		DW	08806h		;sin(413 p degs)
		DW	08895h		;sin(414 p degs)
		DW	08928h		;sin(415 p degs)
		DW	089BFh		;sin(416 p degs)
		DW	08A5Ch		;sin(417 p degs)
		DW	08AFCh		;sin(418 p degs)
		DW	08BA1h		;sin(419 p degs)
		DW	08C4Bh		;sin(420 p degs)
		DW	08CF9h		;sin(421 p degs)
		DW	08DACh		;sin(422 p degs)
		DW	08E63h		;sin(423 p degs)
		DW	08F1Eh		;sin(424 p degs)
		DW	08FDEh		;sin(425 p degs)
		DW	090A2h		;sin(426 p degs)
		DW	0916Ah		;sin(427 p degs)
		DW	09237h		;sin(428 p degs)
		DW	09308h		;sin(429 p degs)
		DW	093DDh		;sin(430 p degs)
		DW	094B6h		;sin(431 p degs)
		DW	09593h		;sin(432 p degs)
		DW	09675h		;sin(433 p degs)
		DW	0975Ah		;sin(434 p degs)
		DW	09844h		;sin(435 p degs)
		DW	09932h		;sin(436 p degs)
		DW	09A23h		;sin(437 p degs)
		DW	09B18h		;sin(438 p degs)
		DW	09C12h		;sin(439 p degs)
		DW	09D0Fh		;sin(440 p degs)
		DW	09E10h		;sin(441 p degs)
		DW	09F15h		;sin(442 p degs)
		DW	0A01Dh		;sin(443 p degs)
		DW	0A12Ah		;sin(444 p degs)
		DW	0A239h		;sin(445 p degs)
		DW	0A34Dh		;sin(446 p degs)
		DW	0A464h		;sin(447 p degs)
		DW	0A57Fh		;sin(448 p degs)
		DW	0A69Dh		;sin(449 p degs)
		DW	0A7BEh		;sin(450 p degs)
		DW	0A8E3h		;sin(451 p degs)
		DW	0AA0Bh		;sin(452 p degs)
		DW	0AB37h		;sin(453 p degs)
		DW	0AC66h		;sin(454 p degs)
		DW	0AD98h		;sin(455 p degs)
		DW	0AECDh		;sin(456 p degs)
		DW	0B006h		;sin(457 p degs)
		DW	0B141h		;sin(458 p degs)
		DW	0B280h		;sin(459 p degs)
		DW	0B3C1h		;sin(460 p degs)
		DW	0B505h		;sin(461 p degs)
		DW	0B64Dh		;sin(462 p degs)
		DW	0B797h		;sin(463 p degs)
		DW	0B8E4h		;sin(464 p degs)
		DW	0BA34h		;sin(465 p degs)
		DW	0BB86h		;sin(466 p degs)
		DW	0BCDBh		;sin(467 p degs)
		DW	0BE33h		;sin(468 p degs)
		DW	0BF8Dh		;sin(469 p degs)
		DW	0C0EAh		;sin(470 p degs)
		DW	0C249h		;sin(471 p degs)
		DW	0C3AAh		;sin(472 p degs)
		DW	0C50Eh		;sin(473 p degs)
		DW	0C674h		;sin(474 p degs)
		DW	0C7DCh		;sin(475 p degs)
		DW	0C947h		;sin(476 p degs)
		DW	0CAB3h		;sin(477 p degs)
		DW	0CC22h		;sin(478 p degs)
		DW	0CD92h		;sin(479 p degs)
		DW	0CF05h		;sin(480 p degs)
		DW	0D079h		;sin(481 p degs)
		DW	0D1F0h		;sin(482 p degs)
		DW	0D368h		;sin(483 p degs)
		DW	0D4E2h		;sin(484 p degs)
		DW	0D65Dh		;sin(485 p degs)
		DW	0D7DAh		;sin(486 p degs)
		DW	0D959h		;sin(487 p degs)
		DW	0DAD9h		;sin(488 p degs)
		DW	0DC5Ah		;sin(489 p degs)
		DW	0DDDDh		;sin(490 p degs)
		DW	0DF61h		;sin(491 p degs)
		DW	0E0E7h		;sin(492 p degs)
		DW	0E26Dh		;sin(493 p degs)
		DW	0E3F5h		;sin(494 p degs)
		DW	0E57Eh		;sin(495 p degs)
		DW	0E708h		;sin(496 p degs)
		DW	0E893h		;sin(497 p degs)
		DW	0EA1Fh		;sin(498 p degs)
		DW	0EBABh		;sin(499 p degs)
		DW	0ED39h		;sin(500 p degs)
		DW	0EEC7h		;sin(501 p degs)
		DW	0F055h		;sin(502 p degs)
		DW	0F1E5h		;sin(503 p degs)
		DW	0F375h		;sin(504 p degs)
		DW	0F505h		;sin(505 p degs)
		DW	0F696h		;sin(506 p degs)
		DW	0F827h		;sin(507 p degs)
		DW	0F9B9h		;sin(508 p degs)
		DW	0FB4Ah		;sin(509 p degs)
		DW	0FCDCh		;sin(510 p degs)
		DW	0FE6Eh		;sin(511 p degs)
		DW	00000h		;sin(0 p degs)
		DW	00192h		;sin(1 p degs)
		DW	00324h		;sin(2 p degs)
		DW	004B6h		;sin(3 p degs)
		DW	00648h		;sin(4 p degs)
		DW	007D9h		;sin(5 p degs)
		DW	0096Ah		;sin(6 p degs)
		DW	00AFBh		;sin(7 p degs)
		DW	00C8Ch		;sin(8 p degs)
		DW	00E1Ch		;sin(9 p degs)
		DW	00FABh		;sin(10 p degs)
		DW	0113Ah		;sin(11 p degs)
		DW	012C8h		;sin(12 p degs)
		DW	01455h		;sin(13 p degs)
		DW	015E2h		;sin(14 p degs)
		DW	0176Eh		;sin(15 p degs)
		DW	018F9h		;sin(16 p degs)
		DW	01A82h		;sin(17 p degs)
		DW	01C0Bh		;sin(18 p degs)
		DW	01D93h		;sin(19 p degs)
		DW	01F1Ah		;sin(20 p degs)
		DW	0209Fh		;sin(21 p degs)
		DW	02223h		;sin(22 p degs)
		DW	023A6h		;sin(23 p degs)
		DW	02528h		;sin(24 p degs)
		DW	026A8h		;sin(25 p degs)
		DW	02826h		;sin(26 p degs)
		DW	029A3h		;sin(27 p degs)
		DW	02B1Fh		;sin(28 p degs)
		DW	02C99h		;sin(29 p degs)
		DW	02E11h		;sin(30 p degs)
		DW	02F87h		;sin(31 p degs)
		DW	030FBh		;sin(32 p degs)
		DW	0326Eh		;sin(33 p degs)
		DW	033DFh		;sin(34 p degs)
		DW	0354Dh		;sin(35 p degs)
		DW	036BAh		;sin(36 p degs)
		DW	03824h		;sin(37 p degs)
		DW	0398Ch		;sin(38 p degs)
		DW	03AF2h		;sin(39 p degs)
		DW	03C56h		;sin(40 p degs)
		DW	03DB8h		;sin(41 p degs)
		DW	03F17h		;sin(42 p degs)
		DW	04073h		;sin(43 p degs)
		DW	041CEh		;sin(44 p degs)
		DW	04325h		;sin(45 p degs)
		DW	0447Ah		;sin(46 p degs)
		DW	045CDh		;sin(47 p degs)
		DW	0471Ch		;sin(48 p degs)
		DW	04869h		;sin(49 p degs)
		DW	049B4h		;sin(50 p degs)
		DW	04AFBh		;sin(51 p degs)
		DW	04C3Fh		;sin(52 p degs)
		DW	04D81h		;sin(53 p degs)
		DW	04EBFh		;sin(54 p degs)
		DW	04FFBh		;sin(55 p degs)
		DW	05133h		;sin(56 p degs)
		DW	05268h		;sin(57 p degs)
		DW	0539Bh		;sin(58 p degs)
		DW	054C9h		;sin(59 p degs)
		DW	055F5h		;sin(60 p degs)
		DW	0571Dh		;sin(61 p degs)
		DW	05842h		;sin(62 p degs)
		DW	05964h		;sin(63 p degs)
		DW	05A82h		;sin(64 p degs)
		DW	05B9Ch		;sin(65 p degs)
		DW	05CB3h		;sin(66 p degs)
		DW	05DC7h		;sin(67 p degs)
		DW	05ED7h		;sin(68 p degs)
		DW	05FE3h		;sin(69 p degs)
		DW	060EBh		;sin(70 p degs)
		DW	061F0h		;sin(71 p degs)
		DW	062F1h		;sin(72 p degs)
		DW	063EEh		;sin(73 p degs)
		DW	064E8h		;sin(74 p degs)
		DW	065DDh		;sin(75 p degs)
		DW	066CFh		;sin(76 p degs)
		DW	067BCh		;sin(77 p degs)
		DW	068A6h		;sin(78 p degs)
		DW	0698Bh		;sin(79 p degs)
		DW	06A6Dh		;sin(80 p degs)
		DW	06B4Ah		;sin(81 p degs)
		DW	06C23h		;sin(82 p degs)
		DW	06CF8h		;sin(83 p degs)
		DW	06DC9h		;sin(84 p degs)
		DW	06E96h		;sin(85 p degs)
		DW	06F5Eh		;sin(86 p degs)
		DW	07022h		;sin(87 p degs)
		DW	070E2h		;sin(88 p degs)
		DW	0719Dh		;sin(89 p degs)
		DW	07254h		;sin(90 p degs)
		DW	07307h		;sin(91 p degs)
		DW	073B5h		;sin(92 p degs)
		DW	0745Fh		;sin(93 p degs)
		DW	07504h		;sin(94 p degs)
		DW	075A5h		;sin(95 p degs)
		DW	07641h		;sin(96 p degs)
		DW	076D8h		;sin(97 p degs)
		DW	0776Bh		;sin(98 p degs)
		DW	077FAh		;sin(99 p degs)
		DW	07884h		;sin(100 p degs)
		DW	07909h		;sin(101 p degs)
		DW	07989h		;sin(102 p degs)
		DW	07A05h		;sin(103 p degs)
		DW	07A7Ch		;sin(104 p degs)
		DW	07AEEh		;sin(105 p degs)
		DW	07B5Ch		;sin(106 p degs)
		DW	07BC5h		;sin(107 p degs)
		DW	07C29h		;sin(108 p degs)
		DW	07C88h		;sin(109 p degs)
		DW	07CE3h		;sin(110 p degs)
		DW	07D39h		;sin(111 p degs)
		DW	07D89h		;sin(112 p degs)
		DW	07DD5h		;sin(113 p degs)
		DW	07E1Dh		;sin(114 p degs)
		DW	07E5Fh		;sin(115 p degs)
		DW	07E9Ch		;sin(116 p degs)
		DW	07ED5h		;sin(117 p degs)
		DW	07F09h		;sin(118 p degs)
		DW	07F37h		;sin(119 p degs)
		DW	07F61h		;sin(120 p degs)
		DW	07F86h		;sin(121 p degs)
		DW	07FA6h		;sin(122 p degs)
		DW	07FC1h		;sin(123 p degs)
		DW	07FD8h		;sin(124 p degs)
		DW	07FE9h		;sin(125 p degs)
		DW	07FF5h		;sin(126 p degs)
		DW	07FFDh		;sin(127 p degs)

;----------------------------------------------------------------------------
;*
;* octant trig / sign tables
;*
;* use to solve equations of the form:-
;*
;*    delta x = trig(theta) * factor
;*    delta y = trig(theta) * factor
;*
;* where theta = 0 .. 511 pseudo degrees
;*
;----------------------------------------------------------------------------

OctTrigTable	LABEL	WORD

		DW	OFFSET SinTable	;x1
		DW	OFFSET CosTable	;y1
		DW	OFFSET CosTable ;x2
		DW	OFFSET SinTable ;y2
		DW	OFFSET CosTable	;x3
		DW	OFFSET SinTable	;y3
		DW      OFFSET SinTable ;x4
		DW	OFFSET CosTable ;y4
		DW	OFFSET SinTable	;x5
		DW	OFFSET CosTable	;y5
		DW	OFFSET CosTable ;x6
		DW	OFFSET SinTable ;y6
		DW	OFFSET CosTable	;x7
		DW	OFFSET SinTable	;y7
		DW	OFFSET SinTable ;x8
		DW	OFFSET CosTable ;y8

OctSignTable	LABEL	WORD

		DW	 0, 0		;+x1, +y1
		DW	 0, 0		;+x2, +y2
		DW	 0,-1		;+x3, -y3
		DW	 0,-1		;+x4, -y4
		DW	-1,-1		;-x5, -y5
		DW	-1,-1		;-x6, -y6
		DW	-1, 0		;-x7, +y7
		DW	-1, 0		;-x8, +y8

;---------------------------
;* arctan360 quadrant switch
;---------------------------

QuadSwitch	DW	Quad1		;+x, +y (00)
		DW	Quad4		;-x, +y	(01)
		DW	Quad2		;+x, -y	(10)
		DW	Quad3		;-x, -y	(11)

DATA		ENDS

;============================================================================

STACK		SEGMENT PARA PUBLIC 'STACK'
		ASSUME SS:STACK

;-----------------------------------------------------------------------
;* NOTE: Data is stored in the stack segment due to lack of space in the
;*       main DATA segment. Using SS: override does not appear to add
;*       any additional cycles to i286 and i386 timings. i486 has one
;*       extra cycle if the instruction is in cache. Therefore, use SS:
;*       override (don't worry about always using [bp]).
;-----------------------------------------------------------------------

;---------------------------
ArcSinTable	LABEL	WORD
;---------------------------

		DW	0		;arcsin(0)
		DW	41		;arcsin(0.003)
		DW	81		;arcsin(0.007)
		DW	122		;arcsin(0.011)
		DW	163		;arcsin(0.015)
		DW	204		;arcsin(0.019)
		DW	244		;arcsin(0.023)
		DW	285		;arcsin(0.027)
		DW	326		;arcsin(0.031)
		DW	367		;arcsin(0.035)
		DW	408		;arcsin(0.039)
		DW	448		;arcsin(0.042)
		DW	489		;arcsin(0.046)
		DW	530		;arcsin(0.050)
		DW	571		;arcsin(0.054)
		DW	612		;arcsin(0.058)
		DW	652		;arcsin(0.062)
		DW	693		;arcsin(0.066)
		DW	734		;arcsin(0.070)
		DW	775		;arcsin(0.074)
		DW	816		;arcsin(0.078)
		DW	857		;arcsin(0.082)
		DW	897		;arcsin(0.085)
		DW	938		;arcsin(0.089)
		DW	979		;arcsin(0.093)
		DW	1020		;arcsin(0.097)
		DW	1061		;arcsin(0.101)
		DW	1102		;arcsin(0.105)
		DW	1143		;arcsin(0.109)
		DW	1184		;arcsin(0.113)
		DW	1225		;arcsin(0.117)
		DW	1266		;arcsin(0.121)
		DW	1307		;arcsin(0.125)
		DW	1348		;arcsin(0.128)
		DW	1389		;arcsin(0.132)
		DW	1431		;arcsin(0.136)
		DW	1472		;arcsin(0.140)
		DW	1513		;arcsin(0.144)
		DW	1554		;arcsin(0.148)
		DW	1595		;arcsin(0.152)
		DW	1636		;arcsin(0.156)
		DW	1678		;arcsin(0.160)
		DW	1719		;arcsin(0.164)
		DW	1760		;arcsin(0.167)
		DW	1802		;arcsin(0.171)
		DW	1843		;arcsin(0.175)
		DW	1884		;arcsin(0.179)
		DW	1926		;arcsin(0.183)
		DW	1967		;arcsin(0.187)
		DW	2009		;arcsin(0.191)
		DW	2050		;arcsin(0.195)
		DW	2092		;arcsin(0.199)
		DW	2134		;arcsin(0.203)
		DW	2175		;arcsin(0.207)
		DW	2217		;arcsin(0.210)
		DW	2259		;arcsin(0.214)
		DW	2300		;arcsin(0.218)
		DW	2342		;arcsin(0.222)
		DW	2384		;arcsin(0.226)
		DW	2426		;arcsin(0.230)
		DW	2468		;arcsin(0.234)
		DW	2510		;arcsin(0.238)
		DW	2551		;arcsin(0.242)
		DW	2593		;arcsin(0.246)
		DW	2636		;arcsin(0.25)
		DW	2678		;arcsin(0.253)
		DW	2720		;arcsin(0.257)
		DW	2762		;arcsin(0.261)
		DW	2804		;arcsin(0.265)
		DW	2847		;arcsin(0.269)
		DW	2889		;arcsin(0.273)
		DW	2931		;arcsin(0.277)
		DW	2974		;arcsin(0.281)
		DW	3016		;arcsin(0.285)
		DW	3059		;arcsin(0.289)
		DW	3101		;arcsin(0.292)
		DW	3144		;arcsin(0.296)
		DW	3187		;arcsin(0.300)
		DW	3229		;arcsin(0.304)
		DW	3272		;arcsin(0.308)
		DW	3315		;arcsin(0.312)
		DW	3358		;arcsin(0.316)
		DW	3401		;arcsin(0.320)
		DW	3444		;arcsin(0.324)
		DW	3487		;arcsin(0.328)
		DW	3530		;arcsin(0.332)
		DW	3573		;arcsin(0.335)
		DW	3617		;arcsin(0.339)
		DW	3660		;arcsin(0.343)
		DW	3704		;arcsin(0.347)
		DW	3747		;arcsin(0.351)
		DW	3791		;arcsin(0.355)
		DW	3834		;arcsin(0.359)
		DW	3878		;arcsin(0.363)
		DW	3922		;arcsin(0.367)
		DW	3965		;arcsin(0.371)
		DW	4009		;arcsin(0.375)
		DW	4053		;arcsin(0.378)
		DW	4097		;arcsin(0.382)
		DW	4142		;arcsin(0.386)
		DW	4186		;arcsin(0.390)
		DW	4230		;arcsin(0.394)
		DW	4275		;arcsin(0.398)
		DW	4319		;arcsin(0.402)
		DW	4364		;arcsin(0.406)
		DW	4408		;arcsin(0.410)
		DW	4453		;arcsin(0.414)
		DW	4498		;arcsin(0.417)
		DW	4543		;arcsin(0.421)
		DW	4588		;arcsin(0.425)
		DW	4633		;arcsin(0.429)
		DW	4678		;arcsin(0.433)
		DW	4723		;arcsin(0.437)
		DW	4768		;arcsin(0.441)
		DW	4814		;arcsin(0.445)
		DW	4859		;arcsin(0.449)
		DW	4905		;arcsin(0.453)
		DW	4951		;arcsin(0.457)
		DW	4997		;arcsin(0.460)
		DW	5043		;arcsin(0.464)
		DW	5089		;arcsin(0.468)
		DW	5135		;arcsin(0.472)
		DW	5181		;arcsin(0.476)
		DW	5228		;arcsin(0.480)
		DW	5274		;arcsin(0.484)
		DW	5321		;arcsin(0.488)
		DW	5367		;arcsin(0.492)
		DW	5414		;arcsin(0.496)
		DW	5461		;arcsin(0.5)
		DW	5508		;arcsin(0.503)
		DW	5556		;arcsin(0.507)
		DW	5603		;arcsin(0.511)
		DW	5651		;arcsin(0.515)
		DW	5698		;arcsin(0.519)
		DW	5746		;arcsin(0.523)
		DW	5794		;arcsin(0.527)
		DW	5842		;arcsin(0.531)
		DW	5890		;arcsin(0.535)
		DW	5938		;arcsin(0.539)
		DW	5987		;arcsin(0.542)
		DW	6035		;arcsin(0.546)
		DW	6084		;arcsin(0.550)
		DW	6133		;arcsin(0.554)
		DW	6182		;arcsin(0.558)
		DW	6231		;arcsin(0.562)
		DW	6281		;arcsin(0.566)
		DW	6330		;arcsin(0.570)
		DW	6380		;arcsin(0.574)
		DW	6430		;arcsin(0.578)
		DW	6480		;arcsin(0.582)
		DW	6530		;arcsin(0.585)
		DW	6580		;arcsin(0.589)
		DW	6631		;arcsin(0.593)
		DW	6681		;arcsin(0.597)
		DW	6732		;arcsin(0.601)
		DW	6783		;arcsin(0.605)
		DW	6835		;arcsin(0.609)
		DW	6886		;arcsin(0.613)
		DW	6938		;arcsin(0.617)
		DW	6990		;arcsin(0.621)
		DW	7042		;arcsin(0.625)
		DW	7094		;arcsin(0.628)
		DW	7147		;arcsin(0.632)
		DW	7199		;arcsin(0.636)
		DW	7252		;arcsin(0.640)
		DW	7306		;arcsin(0.644)
		DW	7359		;arcsin(0.648)
		DW	7413		;arcsin(0.652)
		DW	7466		;arcsin(0.656)
		DW	7521		;arcsin(0.660)
		DW	7575		;arcsin(0.664)
		DW	7630		;arcsin(0.667)
		DW	7684		;arcsin(0.671)
		DW	7740		;arcsin(0.675)
		DW	7795		;arcsin(0.679)
		DW	7851		;arcsin(0.683)
		DW	7907		;arcsin(0.687)
		DW	7963		;arcsin(0.691)
		DW	8019		;arcsin(0.695)
		DW	8076		;arcsin(0.699)
		DW	8133		;arcsin(0.703)
		DW	8191		;arcsin(0.707)
		DW	8249		;arcsin(0.710)
		DW	8307		;arcsin(0.714)
		DW	8365		;arcsin(0.718)
		DW	8424		;arcsin(0.722)
		DW	8483		;arcsin(0.726)
		DW	8543		;arcsin(0.730)
		DW	8602		;arcsin(0.734)
		DW	8663		;arcsin(0.738)
		DW	8723		;arcsin(0.742)
		DW	8784		;arcsin(0.746)
		DW	8846		;arcsin(0.75)
		DW	8907		;arcsin(0.753)
		DW	8970		;arcsin(0.757)
		DW	9032		;arcsin(0.761)
		DW	9095		;arcsin(0.765)
		DW	9159		;arcsin(0.769)
		DW	9223		;arcsin(0.773)
		DW	9288		;arcsin(0.777)
		DW	9353		;arcsin(0.781)
		DW	9418		;arcsin(0.785)
		DW	9484		;arcsin(0.789)
		DW	9551		;arcsin(0.792)
		DW	9618		;arcsin(0.796)
		DW	9686		;arcsin(0.800)
		DW	9754		;arcsin(0.804)
		DW	9823		;arcsin(0.808)
		DW	9892		;arcsin(0.812)
		DW	9963		;arcsin(0.816)
		DW	10034		;arcsin(0.820)
		DW	10105		;arcsin(0.824)
		DW	10177		;arcsin(0.828)
		DW	10251		;arcsin(0.832)
		DW	10324		;arcsin(0.835)
		DW	10399		;arcsin(0.839)
		DW	10475		;arcsin(0.843)
		DW	10551		;arcsin(0.847)
		DW	10628		;arcsin(0.851)
		DW	10706		;arcsin(0.855)
		DW	10785		;arcsin(0.859)
		DW	10866		;arcsin(0.863)
		DW	10947		;arcsin(0.867)
		DW	11029		;arcsin(0.871)
		DW	11113		;arcsin(0.875)
		DW	11198		;arcsin(0.878)
		DW	11284		;arcsin(0.882)
		DW	11371		;arcsin(0.886)
		DW	11460		;arcsin(0.890)
		DW	11550		;arcsin(0.894)
		DW	11642		;arcsin(0.898)
		DW	11736		;arcsin(0.902)
		DW	11831		;arcsin(0.906)
		DW	11929		;arcsin(0.910)
		DW	12028		;arcsin(0.914)
		DW	12130		;arcsin(0.917)
		DW	12234		;arcsin(0.921)
		DW	12340		;arcsin(0.925)
		DW	12449		;arcsin(0.929)
		DW	12561		;arcsin(0.933)
		DW	12677		;arcsin(0.937)
		DW	12796		;arcsin(0.941)
		DW	12919		;arcsin(0.945)
		DW	13046		;arcsin(0.949)
		DW	13178		;arcsin(0.953)
		DW	13315		;arcsin(0.957)
		DW	13459		;arcsin(0.960)
		DW	13610		;arcsin(0.964)
		DW	13770		;arcsin(0.968)
		DW	13939		;arcsin(0.972)
		DW	14121		;arcsin(0.976)
		DW	14319		;arcsin(0.980)
		DW	14538		;arcsin(0.984)
		DW	14786		;arcsin(0.988)
		DW	15079		;arcsin(0.992)
		DW	15462		;arcsin(0.996)
		DW	16384		;arcsin(1)

;---------------------------
ArcCosTable	LABEL	WORD
;---------------------------

		DW	16384		;arccos(0)
		DW	16343		;arccos(0.003)
		DW	16303		;arccos(0.007)
		DW	16262		;arccos(0.011)
		DW	16221		;arccos(0.015)
		DW	16180		;arccos(0.019)
		DW	16140		;arccos(0.023)
		DW	16099		;arccos(0.027)
		DW	16058		;arccos(0.031)
		DW	16017		;arccos(0.035)
		DW	15976		;arccos(0.039)
		DW	15936		;arccos(0.042)
		DW	15895		;arccos(0.046)
		DW	15854		;arccos(0.050)
		DW	15813		;arccos(0.054)
		DW	15772		;arccos(0.058)
		DW	15732		;arccos(0.062)
		DW	15691		;arccos(0.066)
		DW	15650		;arccos(0.070)
		DW	15609		;arccos(0.074)
		DW	15568		;arccos(0.078)
		DW	15527		;arccos(0.082)
		DW	15487		;arccos(0.085)
		DW	15446		;arccos(0.089)
		DW	15405		;arccos(0.093)
		DW	15364		;arccos(0.097)
		DW	15323		;arccos(0.101)
		DW	15282		;arccos(0.105)
		DW	15241		;arccos(0.109)
		DW	15200		;arccos(0.113)
		DW	15159		;arccos(0.117)
		DW	15118		;arccos(0.121)
		DW	15077		;arccos(0.125)
		DW	15036		;arccos(0.128)
		DW	14995		;arccos(0.132)
		DW	14953		;arccos(0.136)
		DW	14912		;arccos(0.140)
		DW	14871		;arccos(0.144)
		DW	14830		;arccos(0.148)
		DW	14789		;arccos(0.152)
		DW	14748		;arccos(0.156)
		DW	14706		;arccos(0.160)
		DW	14665		;arccos(0.164)
		DW	14624		;arccos(0.167)
		DW	14582		;arccos(0.171)
		DW	14541		;arccos(0.175)
		DW	14500		;arccos(0.179)
		DW	14458		;arccos(0.183)
		DW	14417		;arccos(0.187)
		DW	14375		;arccos(0.191)
		DW	14334		;arccos(0.195)
		DW	14292		;arccos(0.199)
		DW	14250		;arccos(0.203)
		DW	14209		;arccos(0.207)
		DW	14167		;arccos(0.210)
		DW	14125		;arccos(0.214)
		DW	14084		;arccos(0.218)
		DW	14042		;arccos(0.222)
		DW	14000		;arccos(0.226)
		DW	13958		;arccos(0.230)
		DW	13916		;arccos(0.234)
		DW	13874		;arccos(0.238)
		DW	13833		;arccos(0.242)
		DW	13791		;arccos(0.246)
		DW	13748		;arccos(0.25)
		DW	13706		;arccos(0.253)
		DW	13664		;arccos(0.257)
		DW	13622		;arccos(0.261)
		DW	13580		;arccos(0.265)
		DW	13537		;arccos(0.269)
		DW	13495		;arccos(0.273)
		DW	13453		;arccos(0.277)
		DW	13410		;arccos(0.281)
		DW	13368		;arccos(0.285)
		DW	13325		;arccos(0.289)
		DW	13283		;arccos(0.292)
		DW	13240		;arccos(0.296)
		DW	13197		;arccos(0.300)
		DW	13155		;arccos(0.304)
		DW	13112		;arccos(0.308)
		DW	13069		;arccos(0.312)
		DW	13026		;arccos(0.316)
		DW	12983		;arccos(0.320)
		DW	12940		;arccos(0.324)
		DW	12897		;arccos(0.328)
		DW	12854		;arccos(0.332)
		DW	12811		;arccos(0.335)
		DW	12767		;arccos(0.339)
		DW	12724		;arccos(0.343)
		DW	12680		;arccos(0.347)
		DW	12637		;arccos(0.351)
		DW	12593		;arccos(0.355)
		DW	12550		;arccos(0.359)
		DW	12506		;arccos(0.363)
		DW	12462		;arccos(0.367)
		DW	12419		;arccos(0.371)
		DW	12375		;arccos(0.375)
		DW	12331		;arccos(0.378)
		DW	12287		;arccos(0.382)
		DW	12242		;arccos(0.386)
		DW	12198		;arccos(0.390)
		DW	12154		;arccos(0.394)
		DW	12109		;arccos(0.398)
		DW	12065		;arccos(0.402)
		DW	12020		;arccos(0.406)
		DW	11976		;arccos(0.410)
		DW	11931		;arccos(0.414)
		DW	11886		;arccos(0.417)
		DW	11841		;arccos(0.421)
		DW	11796		;arccos(0.425)
		DW	11751		;arccos(0.429)
		DW	11706		;arccos(0.433)
		DW	11661		;arccos(0.437)
		DW	11616		;arccos(0.441)
		DW	11570		;arccos(0.445)
		DW	11525		;arccos(0.449)
		DW	11479		;arccos(0.453)
		DW	11433		;arccos(0.457)
		DW	11387		;arccos(0.460)
		DW	11341		;arccos(0.464)
		DW	11295		;arccos(0.468)
		DW	11249		;arccos(0.472)
		DW	11203		;arccos(0.476)
		DW	11156		;arccos(0.480)
		DW	11110		;arccos(0.484)
		DW	11063		;arccos(0.488)
		DW	11017		;arccos(0.492)
		DW	10970		;arccos(0.496)
		DW	10923		;arccos(0.5)
		DW	10876		;arccos(0.503)
		DW	10828		;arccos(0.507)
		DW	10781		;arccos(0.511)
		DW	10733		;arccos(0.515)
		DW	10686		;arccos(0.519)
		DW	10638		;arccos(0.523)
		DW	10590		;arccos(0.527)
		DW	10542		;arccos(0.531)
		DW	10494		;arccos(0.535)
		DW	10446		;arccos(0.539)
		DW	10397		;arccos(0.542)
		DW	10349		;arccos(0.546)
		DW	10300		;arccos(0.550)
		DW	10251		;arccos(0.554)
		DW	10202		;arccos(0.558)
		DW	10153		;arccos(0.562)
		DW	10103		;arccos(0.566)
		DW	10054		;arccos(0.570)
		DW	10004		;arccos(0.574)
		DW	9954		;arccos(0.578)
		DW	9904		;arccos(0.582)
		DW	9854		;arccos(0.585)
		DW	9804		;arccos(0.589)
		DW	9753		;arccos(0.593)
		DW	9703		;arccos(0.597)
		DW	9652		;arccos(0.601)
		DW	9601		;arccos(0.605)
		DW	9549		;arccos(0.609)
		DW	9498		;arccos(0.613)
		DW	9446		;arccos(0.617)
		DW	9394		;arccos(0.621)
		DW	9342		;arccos(0.625)
		DW	9290		;arccos(0.628)
		DW	9237		;arccos(0.632)
		DW	9185		;arccos(0.636)
		DW	9132		;arccos(0.640)
		DW	9078		;arccos(0.644)
		DW	9025		;arccos(0.648)
		DW	8971		;arccos(0.652)
		DW	8918		;arccos(0.656)
		DW	8863		;arccos(0.660)
		DW	8809		;arccos(0.664)
		DW	8754		;arccos(0.667)
		DW	8700		;arccos(0.671)
		DW	8644		;arccos(0.675)
		DW	8589		;arccos(0.679)
		DW	8533		;arccos(0.683)
		DW	8477		;arccos(0.687)
		DW	8421		;arccos(0.691)
		DW	8365		;arccos(0.695)
		DW	8308		;arccos(0.699)
		DW	8251		;arccos(0.703)
		DW	8193		;arccos(0.707)
		DW	8135		;arccos(0.710)
		DW	8077		;arccos(0.714)
		DW	8019		;arccos(0.718)
		DW	7960		;arccos(0.722)
		DW	7901		;arccos(0.726)
		DW	7841		;arccos(0.730)
		DW	7782		;arccos(0.734)
		DW	7721		;arccos(0.738)
		DW	7661		;arccos(0.742)
		DW	7600		;arccos(0.746)
		DW	7538		;arccos(0.75)
		DW	7477		;arccos(0.753)
		DW	7414		;arccos(0.757)
		DW	7352		;arccos(0.761)
		DW	7289		;arccos(0.765)
		DW	7225		;arccos(0.769)
		DW	7161		;arccos(0.773)
		DW	7096		;arccos(0.777)
		DW	7031		;arccos(0.781)
		DW	6966		;arccos(0.785)
		DW	6900		;arccos(0.789)
		DW	6833		;arccos(0.792)
		DW	6766		;arccos(0.796)
		DW	6698		;arccos(0.800)
		DW	6630		;arccos(0.804)
		DW	6561		;arccos(0.808)
		DW	6492		;arccos(0.812)
		DW	6421		;arccos(0.816)
		DW	6350		;arccos(0.820)
		DW	6279		;arccos(0.824)
		DW	6207		;arccos(0.828)
		DW	6133		;arccos(0.832)
		DW	6060		;arccos(0.835)
		DW	5985		;arccos(0.839)
		DW	5909		;arccos(0.843)
		DW	5833		;arccos(0.847)
		DW	5756		;arccos(0.851)
		DW	5678		;arccos(0.855)
		DW	5599		;arccos(0.859)
		DW	5518		;arccos(0.863)
		DW	5437		;arccos(0.867)
		DW	5355		;arccos(0.871)
		DW	5271		;arccos(0.875)
		DW	5186		;arccos(0.878)
		DW	5100		;arccos(0.882)
		DW	5013		;arccos(0.886)
		DW	4924		;arccos(0.890)
		DW	4834		;arccos(0.894)
		DW	4742		;arccos(0.898)
		DW	4648		;arccos(0.902)
		DW	4553		;arccos(0.906)
		DW	4455		;arccos(0.910)
		DW	4356		;arccos(0.914)
		DW	4254		;arccos(0.917)
		DW	4150		;arccos(0.921)
		DW	4044		;arccos(0.925)
		DW	3935		;arccos(0.929)
		DW	3823		;arccos(0.933)
		DW	3707		;arccos(0.937)
		DW	3588		;arccos(0.941)
		DW	3465		;arccos(0.945)
		DW	3338		;arccos(0.949)
		DW	3206		;arccos(0.953)
		DW	3069		;arccos(0.957)
		DW	2925		;arccos(0.960)
		DW	2774		;arccos(0.964)
		DW	2614		;arccos(0.968)
		DW	2445		;arccos(0.972)
		DW	2263		;arccos(0.976)
		DW	2065		;arccos(0.980)
		DW	1846		;arccos(0.984)
		DW	1598		;arccos(0.988)
		DW	1305		;arccos(0.992)
		DW	922		;arccos(0.996)
		DW	0		;arccos(1)

;----------------------------------------------------------------------------
;*
;* tangent table (0 .. 90 pseudo degs = 0 .. 63 real degrees)
;*
;* use p degs to look up tan(p deg) * 32767 / 2
;*
;----------------------------------------------------------------------------

TanTable 	LABEL	WORD

		DW	00000h		;tan(0 p degs)
		DW	000C9h		;tan(1 p degs)
		DW	00192h		;tan(2 p degs)
		DW	0025Bh		;tan(3 p degs)
		DW	00325h		;tan(4 p degs)
		DW	003EFh		;tan(5 p degs)
		DW	004B9h		;tan(6 p degs)
		DW	00583h		;tan(7 p degs)
		DW	0064Eh		;tan(8 p degs)
		DW	00719h		;tan(9 p degs)
		DW	007E5h		;tan(10 p degs)
		DW	008B1h		;tan(11 p degs)
		DW	0097Eh		;tan(12 p degs)
		DW	00A4Ch		;tan(13 p degs)
		DW	00B1Bh		;tan(14 p degs)
		DW	00BEAh		;tan(15 p degs)
		DW	00CBBh		;tan(16 p degs)
		DW	00D8Ch		;tan(17 p degs)
		DW	00E5Fh		;tan(18 p degs)
		DW	00F33h		;tan(19 p degs)
		DW	01008h		;tan(20 p degs)
		DW	010DEh		;tan(21 p degs)
		DW	011B6h		;tan(22 p degs)
		DW	0128Fh		;tan(23 p degs)
		DW	0136Ah		;tan(24 p degs)
		DW	01446h		;tan(25 p degs)
		DW	01524h		;tan(26 p degs)
		DW	01604h		;tan(27 p degs)
		DW	016E6h		;tan(28 p degs)
		DW	017CAh		;tan(29 p degs)
		DW	018B0h		;tan(30 p degs)
		DW	01998h		;tan(31 p degs)
		DW	01A82h		;tan(32 p degs)
		DW	01B6Fh		;tan(33 p degs)
		DW	01C5Eh		;tan(34 p degs)
		DW	01D50h		;tan(35 p degs)
		DW	01E45h		;tan(36 p degs)
		DW	01F3Ch		;tan(37 p degs)
		DW	02037h		;tan(38 p degs)
		DW	02134h		;tan(39 p degs)
		DW	02235h		;tan(40 p degs)
		DW	02339h		;tan(41 p degs)
		DW	02441h		;tan(42 p degs)
		DW	0254Dh		;tan(43 p degs)
		DW	0265Ch		;tan(44 p degs)
		DW	0276Fh		;tan(45 p degs)
		DW	02887h		;tan(46 p degs)
		DW	029A3h		;tan(47 p degs)
		DW	02AC3h		;tan(48 p degs)
		DW	02BE8h		;tan(49 p degs)
		DW	02D13h		;tan(50 p degs)
		DW	02E42h		;tan(51 p degs)
		DW	02F77h		;tan(52 p degs)
		DW	030B1h		;tan(53 p degs)
		DW	031F2h		;tan(54 p degs)
		DW	03338h		;tan(55 p degs)
		DW	03486h		;tan(56 p degs)
		DW	035DAh		;tan(57 p degs)
		DW	03735h		;tan(58 p degs)
		DW	03897h		;tan(59 p degs)
		DW	03A01h		;tan(60 p degs)
		DW	03B73h		;tan(61 p degs)
		DW	03CEEh		;tan(62 p degs)
		DW	03E72h		;tan(63 p degs)
		DW	04000h		;tan(64 p degs)
		DW	04197h		;tan(65 p degs)
		DW	04338h		;tan(66 p degs)
		DW	044E5h		;tan(67 p degs)
		DW	0469Ch		;tan(68 p degs)
		DW	04860h		;tan(69 p degs)
		DW	04A31h		;tan(70 p degs)
		DW	04C0Fh		;tan(71 p degs)
		DW	04DFBh		;tan(72 p degs)
		DW	04FF7h		;tan(73 p degs)
		DW	05202h		;tan(74 p degs)
		DW	0541Dh		;tan(75 p degs)
		DW	0564Bh		;tan(76 p degs)
		DW	0588Bh		;tan(77 p degs)
		DW	05ADFh		;tan(78 p degs)
		DW	05D48h		;tan(79 p degs)
		DW	05FC8h		;tan(80 p degs)
		DW	0625Fh		;tan(81 p degs)
		DW	06510h		;tan(82 p degs)
		DW	067DDh		;tan(83 p degs)
		DW	06AC6h		;tan(84 p degs)
		DW	06DCFh		;tan(85 p degs)
		DW	070F9h		;tan(86 p degs)
		DW	07447h		;tan(87 p degs)
		DW	077BBh		;tan(88 p degs)
		DW	07B59h		;tan(89 p degs)
		DW	07F24h		;tan(90 p degs)

;----------------------------------------------------------------------------
;*
;* arctan table (0 .. 2 step 1/256)
;*
;* use binary fraction to look up arctan(fraction) fine pseudo degrees
;*
;----------------------------------------------------------------------------

ArcTanTable	LABEL	WORD

		DW	00000h		;arctan(0.000) =  0.000 degs
		DW	00029h		;arctan(0.004) =  0.224 degs
		DW	00051h		;arctan(0.008) =  0.448 degs
		DW	0007Ah		;arctan(0.012) =  0.671 degs
		DW	000A3h		;arctan(0.016) =  0.895 degs
		DW	000CCh		;arctan(0.020) =  1.119 degs
		DW	000F4h		;arctan(0.023) =  1.343 degs
		DW	0011Dh		;arctan(0.027) =  1.566 degs
		DW	00146h		;arctan(0.031) =  1.790 degs
		DW	0016Fh		;arctan(0.035) =  2.013 degs
		DW	00197h		;arctan(0.039) =  2.237 degs
		DW	001C0h		;arctan(0.043) =  2.460 degs
		DW	001E9h		;arctan(0.047) =  2.684 degs
		DW	00211h		;arctan(0.051) =  2.907 degs
		DW	0023Ah		;arctan(0.055) =  3.130 degs
		DW	00262h		;arctan(0.059) =  3.353 degs
		DW	0028Bh		;arctan(0.063) =  3.576 degs
		DW	002B4h		;arctan(0.066) =  3.799 degs
		DW	002DCh		;arctan(0.070) =  4.022 degs
		DW	00305h		;arctan(0.074) =  4.245 degs
		DW	0032Dh		;arctan(0.078) =  4.467 degs
		DW	00356h		;arctan(0.082) =  4.690 degs
		DW	0037Eh		;arctan(0.086) =  4.912 degs
		DW	003A7h		;arctan(0.090) =  5.134 degs
		DW	003CFh		;arctan(0.094) =  5.356 degs
		DW	003F7h		;arctan(0.098) =  5.578 degs
		DW	00420h		;arctan(0.102) =  5.799 degs
		DW	00448h		;arctan(0.105) =  6.021 degs
		DW	00470h		;arctan(0.109) =  6.242 degs
		DW	00499h		;arctan(0.113) =  6.463 degs
		DW	004C1h		;arctan(0.117) =  6.684 degs
		DW	004E9h		;arctan(0.121) =  6.905 degs
		DW	00511h		;arctan(0.125) =  7.125 degs
		DW	00539h		;arctan(0.129) =  7.345 degs
		DW	00561h		;arctan(0.133) =  7.565 degs
		DW	00589h		;arctan(0.137) =  7.785 degs
		DW	005B1h		;arctan(0.141) =  8.005 degs
		DW	005D9h		;arctan(0.145) =  8.224 degs
		DW	00601h		;arctan(0.148) =  8.443 degs
		DW	00629h		;arctan(0.152) =  8.662 degs
		DW	00651h		;arctan(0.156) =  8.881 degs
		DW	00678h		;arctan(0.160) =  9.099 degs
		DW	006A0h		;arctan(0.164) =  9.317 degs
		DW	006C8h		;arctan(0.168) =  9.535 degs
		DW	006EFh		;arctan(0.172) =  9.752 degs
		DW	00717h		;arctan(0.176) =  9.970 degs
		DW	0073Eh		;arctan(0.180) = 10.187 degs
		DW	00766h		;arctan(0.184) = 10.403 degs
		DW	0078Dh		;arctan(0.188) = 10.620 degs
		DW	007B5h		;arctan(0.191) = 10.836 degs
		DW	007DCh		;arctan(0.195) = 11.051 degs
		DW	00803h		;arctan(0.199) = 11.267 degs
		DW	0082Ah		;arctan(0.203) = 11.482 degs
		DW	00851h		;arctan(0.207) = 11.697 degs
		DW	00878h		;arctan(0.211) = 11.911 degs
		DW	0089Fh		;arctan(0.215) = 12.125 degs
		DW	008C6h		;arctan(0.219) = 12.339 degs
		DW	008EDh		;arctan(0.223) = 12.553 degs
		DW	00914h		;arctan(0.227) = 12.766 degs
		DW	0093Bh		;arctan(0.230) = 12.978 degs
		DW	00961h		;arctan(0.234) = 13.191 degs
		DW	00988h		;arctan(0.238) = 13.403 degs
		DW	009AEh		;arctan(0.242) = 13.614 degs
		DW	009D5h		;arctan(0.246) = 13.825 degs
		DW	009FBh		;arctan(0.250) = 14.036 degs
		DW	00A22h		;arctan(0.254) = 14.247 degs
		DW	00A48h		;arctan(0.258) = 14.457 degs
		DW	00A6Eh		;arctan(0.262) = 14.666 degs
		DW	00A94h		;arctan(0.266) = 14.876 degs
		DW	00ABAh		;arctan(0.270) = 15.085 degs
		DW	00AE0h		;arctan(0.273) = 15.293 degs
		DW	00B06h		;arctan(0.277) = 15.501 degs
		DW	00B2Ch		;arctan(0.281) = 15.709 degs
		DW	00B51h		;arctan(0.285) = 15.916 degs
		DW	00B77h		;arctan(0.289) = 16.123 degs
		DW	00B9Dh		;arctan(0.293) = 16.329 degs
		DW	00BC2h		;arctan(0.297) = 16.535 degs
		DW	00BE7h		;arctan(0.301) = 16.740 degs
		DW	00C0Dh		;arctan(0.305) = 16.945 degs
		DW	00C32h		;arctan(0.309) = 17.150 degs
		DW	00C57h		;arctan(0.313) = 17.354 degs
		DW	00C7Ch		;arctan(0.316) = 17.558 degs
		DW	00CA1h		;arctan(0.320) = 17.761 degs
		DW	00CC6h		;arctan(0.324) = 17.964 degs
		DW	00CEBh		;arctan(0.328) = 18.166 degs
		DW	00D10h		;arctan(0.332) = 18.368 degs
		DW	00D34h		;arctan(0.336) = 18.569 degs
		DW	00D59h		;arctan(0.340) = 18.770 degs
		DW	00D7Dh		;arctan(0.344) = 18.970 degs
		DW	00DA2h		;arctan(0.348) = 19.170 degs
		DW	00DC6h		;arctan(0.352) = 19.370 degs
		DW	00DEAh		;arctan(0.355) = 19.569 degs
		DW	00E0Fh		;arctan(0.359) = 19.767 degs
		DW	00E33h		;arctan(0.363) = 19.965 degs
		DW	00E56h		;arctan(0.367) = 20.163 degs
		DW	00E7Ah		;arctan(0.371) = 20.360 degs
		DW	00E9Eh		;arctan(0.375) = 20.556 degs
		DW	00EC2h		;arctan(0.379) = 20.752 degs
		DW	00EE5h		;arctan(0.383) = 20.947 degs
		DW	00F09h		;arctan(0.387) = 21.142 degs
		DW	00F2Ch		;arctan(0.391) = 21.337 degs
		DW	00F50h		;arctan(0.395) = 21.531 degs
		DW	00F73h		;arctan(0.398) = 21.724 degs
		DW	00F96h		;arctan(0.402) = 21.917 degs
		DW	00FB9h		;arctan(0.406) = 22.109 degs
		DW	00FDCh		;arctan(0.410) = 22.301 degs
		DW	00FFFh		;arctan(0.414) = 22.493 degs
		DW	01021h		;arctan(0.418) = 22.683 degs
		DW	01044h		;arctan(0.422) = 22.874 degs
		DW	01067h		;arctan(0.426) = 23.063 degs
		DW	01089h		;arctan(0.430) = 23.253 degs
		DW	010ABh		;arctan(0.434) = 23.441 degs
		DW	010CEh		;arctan(0.438) = 23.629 degs
		DW	010F0h		;arctan(0.441) = 23.817 degs
		DW	01112h		;arctan(0.445) = 24.004 degs
		DW	01134h		;arctan(0.449) = 24.191 degs
		DW	01156h		;arctan(0.453) = 24.376 degs
		DW	01177h		;arctan(0.457) = 24.562 degs
		DW	01199h		;arctan(0.461) = 24.747 degs
		DW	011BBh		;arctan(0.465) = 24.931 degs
		DW	011DCh		;arctan(0.469) = 25.115 degs
		DW	011FDh		;arctan(0.473) = 25.298 degs
		DW	0121Fh		;arctan(0.477) = 25.481 degs
		DW	01240h		;arctan(0.480) = 25.663 degs
		DW	01261h		;arctan(0.484) = 25.844 degs
		DW	01282h		;arctan(0.488) = 26.025 degs
		DW	012A3h		;arctan(0.492) = 26.206 degs
		DW	012C3h		;arctan(0.496) = 26.386 degs
		DW	012E4h		;arctan(0.500) = 26.565 degs
		DW	01305h		;arctan(0.504) = 26.744 degs
		DW	01325h		;arctan(0.508) = 26.922 degs
		DW	01345h		;arctan(0.512) = 27.100 degs
		DW	01366h		;arctan(0.516) = 27.277 degs
		DW	01386h		;arctan(0.520) = 27.453 degs
		DW	013A6h		;arctan(0.523) = 27.629 degs
		DW	013C6h		;arctan(0.527) = 27.805 degs
		DW	013E6h		;arctan(0.531) = 27.979 degs
		DW	01405h		;arctan(0.535) = 28.154 degs
		DW	01425h		;arctan(0.539) = 28.327 degs
		DW	01444h		;arctan(0.543) = 28.501 degs
		DW	01464h		;arctan(0.547) = 28.673 degs
		DW	01483h		;arctan(0.551) = 28.845 degs
		DW	014A2h		;arctan(0.555) = 29.017 degs
		DW	014C1h		;arctan(0.559) = 29.187 degs
		DW	014E0h		;arctan(0.563) = 29.358 degs
		DW	014FFh		;arctan(0.566) = 29.527 degs
		DW	0151Eh		;arctan(0.570) = 29.697 degs
		DW	0153Dh		;arctan(0.574) = 29.865 degs
		DW	0155Bh		;arctan(0.578) = 30.033 degs
		DW	0157Ah		;arctan(0.582) = 30.201 degs
		DW	01598h		;arctan(0.586) = 30.368 degs
		DW	015B7h		;arctan(0.590) = 30.534 degs
		DW	015D5h		;arctan(0.594) = 30.700 degs
		DW	015F3h		;arctan(0.598) = 30.865 degs
		DW	01611h		;arctan(0.602) = 31.030 degs
		DW	0162Fh		;arctan(0.605) = 31.194 degs
		DW	0164Ch		;arctan(0.609) = 31.357 degs
		DW	0166Ah		;arctan(0.613) = 31.520 degs
		DW	01688h		;arctan(0.617) = 31.682 degs
		DW	016A5h		;arctan(0.621) = 31.844 degs
		DW	016C2h		;arctan(0.625) = 32.005 degs
		DW	016E0h		;arctan(0.629) = 32.166 degs
		DW	016FDh		;arctan(0.633) = 32.326 degs
		DW	0171Ah		;arctan(0.637) = 32.486 degs
		DW	01737h		;arctan(0.641) = 32.645 degs
		DW	01754h		;arctan(0.645) = 32.803 degs
		DW	01770h		;arctan(0.648) = 32.961 degs
		DW	0178Dh		;arctan(0.652) = 33.118 degs
		DW	017AAh		;arctan(0.656) = 33.275 degs
		DW	017C6h		;arctan(0.660) = 33.431 degs
		DW	017E2h		;arctan(0.664) = 33.587 degs
		DW	017FEh		;arctan(0.668) = 33.742 degs
		DW	0181Bh		;arctan(0.672) = 33.896 degs
		DW	01837h		;arctan(0.676) = 34.050 degs
		DW	01853h		;arctan(0.680) = 34.203 degs
		DW	0186Eh		;arctan(0.684) = 34.356 degs
		DW	0188Ah		;arctan(0.688) = 34.509 degs
		DW	018A6h		;arctan(0.691) = 34.660 degs
		DW	018C1h		;arctan(0.695) = 34.811 degs
		DW	018DDh		;arctan(0.699) = 34.962 degs
		DW	018F8h		;arctan(0.703) = 35.112 degs
		DW	01913h		;arctan(0.707) = 35.262 degs
		DW	0192Eh		;arctan(0.711) = 35.410 degs
		DW	01949h		;arctan(0.715) = 35.559 degs
		DW	01964h		;arctan(0.719) = 35.707 degs
		DW	0197Fh		;arctan(0.723) = 35.854 degs
		DW	0199Ah		;arctan(0.727) = 36.001 degs
		DW	019B4h		;arctan(0.730) = 36.147 degs
		DW	019CFh		;arctan(0.734) = 36.293 degs
		DW	019E9h		;arctan(0.738) = 36.438 degs
		DW	01A04h		;arctan(0.742) = 36.582 degs
		DW	01A1Eh		;arctan(0.746) = 36.726 degs
		DW	01A38h		;arctan(0.750) = 36.870 degs
		DW	01A52h		;arctan(0.754) = 37.013 degs
		DW	01A6Ch		;arctan(0.758) = 37.155 degs
		DW	01A86h		;arctan(0.762) = 37.297 degs
		DW	01A9Fh		;arctan(0.766) = 37.439 degs
		DW	01AB9h		;arctan(0.770) = 37.579 degs
		DW	01AD3h		;arctan(0.773) = 37.720 degs
		DW	01AECh		;arctan(0.777) = 37.859 degs
		DW	01B05h		;arctan(0.781) = 37.999 degs
		DW	01B1Fh		;arctan(0.785) = 38.137 degs
		DW	01B38h		;arctan(0.789) = 38.276 degs
		DW	01B51h		;arctan(0.793) = 38.413 degs
		DW	01B6Ah		;arctan(0.797) = 38.550 degs
		DW	01B83h		;arctan(0.801) = 38.687 degs
		DW	01B9Ch		;arctan(0.805) = 38.823 degs
		DW	01BB4h		;arctan(0.809) = 38.959 degs
		DW	01BCDh		;arctan(0.813) = 39.094 degs
		DW	01BE5h		;arctan(0.816) = 39.228 degs
		DW	01BFEh		;arctan(0.820) = 39.362 degs
		DW	01C16h		;arctan(0.824) = 39.496 degs
		DW	01C2Eh		;arctan(0.828) = 39.629 degs
		DW	01C46h		;arctan(0.832) = 39.762 degs
		DW	01C5Eh		;arctan(0.836) = 39.894 degs
		DW	01C76h		;arctan(0.840) = 40.025 degs
		DW	01C8Eh		;arctan(0.844) = 40.156 degs
		DW	01CA6h		;arctan(0.848) = 40.286 degs
		DW	01CBEh		;arctan(0.852) = 40.416 degs
		DW	01CD5h		;arctan(0.855) = 40.546 degs
		DW	01CEDh		;arctan(0.859) = 40.675 degs
		DW	01D04h		;arctan(0.863) = 40.803 degs
		DW	01D1Bh		;arctan(0.867) = 40.931 degs
		DW	01D33h		;arctan(0.871) = 41.059 degs
		DW	01D4Ah		;arctan(0.875) = 41.186 degs
		DW	01D61h		;arctan(0.879) = 41.312 degs
		DW	01D78h		;arctan(0.883) = 41.438 degs
		DW	01D8Eh		;arctan(0.887) = 41.564 degs
		DW	01DA5h		;arctan(0.891) = 41.689 degs
		DW	01DBCh		;arctan(0.895) = 41.814 degs
		DW	01DD3h		;arctan(0.898) = 41.938 degs
		DW	01DE9h		;arctan(0.902) = 42.061 degs
		DW	01DFFh		;arctan(0.906) = 42.184 degs
		DW	01E16h		;arctan(0.910) = 42.307 degs
		DW	01E2Ch		;arctan(0.914) = 42.429 degs
		DW	01E42h		;arctan(0.918) = 42.551 degs
		DW	01E58h		;arctan(0.922) = 42.672 degs
		DW	01E6Eh		;arctan(0.926) = 42.793 degs
		DW	01E84h		;arctan(0.930) = 42.913 degs
		DW	01E9Ah		;arctan(0.934) = 43.033 degs
		DW	01EB0h		;arctan(0.938) = 43.152 degs
		DW	01EC5h		;arctan(0.941) = 43.271 degs
		DW	01EDBh		;arctan(0.945) = 43.390 degs
		DW	01EF0h		;arctan(0.949) = 43.508 degs
		DW	01F06h		;arctan(0.953) = 43.625 degs
		DW	01F1Bh		;arctan(0.957) = 43.742 degs
		DW	01F30h		;arctan(0.961) = 43.859 degs
		DW	01F45h		;arctan(0.965) = 43.975 degs
		DW	01F5Ah		;arctan(0.969) = 44.091 degs
		DW	01F6Fh		;arctan(0.973) = 44.206 degs
		DW	01F84h		;arctan(0.977) = 44.321 degs
		DW	01F99h		;arctan(0.980) = 44.435 degs
		DW	01FAEh		;arctan(0.984) = 44.549 degs
		DW	01FC3h		;arctan(0.988) = 44.662 degs
		DW	01FD7h		;arctan(0.992) = 44.775 degs
		DW	01FECh		;arctan(0.996) = 44.888 degs
		DW	02000h		;arctan(1.000) = 45.000 degs
		DW	02014h		;arctan(1.004) = 45.112 degs
		DW	02029h		;arctan(1.008) = 45.223 degs
		DW	0203Dh		;arctan(1.012) = 45.334 degs
		DW	02051h		;arctan(1.016) = 45.444 degs
		DW	02065h		;arctan(1.020) = 45.554 degs
		DW	02079h		;arctan(1.023) = 45.664 degs
		DW	0208Dh		;arctan(1.027) = 45.773 degs
		DW	020A0h		;arctan(1.031) = 45.881 degs
		DW	020B4h		;arctan(1.035) = 45.990 degs
		DW	020C8h		;arctan(1.039) = 46.097 degs
		DW	020DBh		;arctan(1.043) = 46.205 degs
		DW	020EFh		;arctan(1.047) = 46.312 degs
		DW	02102h		;arctan(1.051) = 46.418 degs
		DW	02116h		;arctan(1.055) = 46.525 degs
		DW	02129h		;arctan(1.059) = 46.630 degs
		DW	0213Ch		;arctan(1.062) = 46.736 degs
		DW	0214Fh		;arctan(1.066) = 46.841 degs
		DW	02162h		;arctan(1.070) = 46.945 degs
		DW	02175h		;arctan(1.074) = 47.049 degs
		DW	02188h		;arctan(1.078) = 47.153 degs
		DW	0219Bh		;arctan(1.082) = 47.256 degs
		DW	021ADh		;arctan(1.086) = 47.359 degs
		DW	021C0h		;arctan(1.090) = 47.462 degs
		DW	021D3h		;arctan(1.094) = 47.564 degs
		DW	021E5h		;arctan(1.098) = 47.665 degs
		DW	021F8h		;arctan(1.102) = 47.767 degs
		DW	0220Ah		;arctan(1.105) = 47.868 degs
		DW	0221Ch		;arctan(1.109) = 47.968 degs
		DW	0222Fh		;arctan(1.113) = 48.068 degs
		DW	02241h		;arctan(1.117) = 48.168 degs
		DW	02253h		;arctan(1.121) = 48.267 degs
		DW	02265h		;arctan(1.125) = 48.366 degs
		DW	02277h		;arctan(1.129) = 48.465 degs
		DW	02289h		;arctan(1.133) = 48.563 degs
		DW	0229Ah		;arctan(1.137) = 48.661 degs
		DW	022ACh		;arctan(1.141) = 48.759 degs
		DW	022BEh		;arctan(1.145) = 48.856 degs
		DW	022D0h		;arctan(1.148) = 48.952 degs
		DW	022E1h		;arctan(1.152) = 49.049 degs
		DW	022F3h		;arctan(1.156) = 49.145 degs
		DW	02304h		;arctan(1.160) = 49.240 degs
		DW	02315h		;arctan(1.164) = 49.335 degs
		DW	02327h		;arctan(1.168) = 49.430 degs
		DW	02338h		;arctan(1.172) = 49.525 degs
		DW	02349h		;arctan(1.176) = 49.619 degs
		DW	0235Ah		;arctan(1.180) = 49.713 degs
		DW	0236Bh		;arctan(1.184) = 49.806 degs
		DW	0237Ch		;arctan(1.187) = 49.899 degs
		DW	0238Dh		;arctan(1.191) = 49.992 degs
		DW	0239Eh		;arctan(1.195) = 50.084 degs
		DW	023AEh		;arctan(1.199) = 50.176 degs
		DW	023BFh		;arctan(1.203) = 50.268 degs
		DW	023D0h		;arctan(1.207) = 50.359 degs
		DW	023E0h		;arctan(1.211) = 50.450 degs
		DW	023F1h		;arctan(1.215) = 50.540 degs
		DW	02401h		;arctan(1.219) = 50.631 degs
		DW	02411h		;arctan(1.223) = 50.721 degs
		DW	02422h		;arctan(1.227) = 50.810 degs
		DW	02432h		;arctan(1.230) = 50.899 degs
		DW	02442h		;arctan(1.234) = 50.988 degs
		DW	02452h		;arctan(1.238) = 51.077 degs
		DW	02462h		;arctan(1.242) = 51.165 degs
		DW	02472h		;arctan(1.246) = 51.253 degs
		DW	02482h		;arctan(1.250) = 51.340 degs
		DW	02492h		;arctan(1.254) = 51.427 degs
		DW	024A2h		;arctan(1.258) = 51.514 degs
		DW	024B2h		;arctan(1.262) = 51.601 degs
		DW	024C1h		;arctan(1.266) = 51.687 degs
		DW	024D1h		;arctan(1.270) = 51.773 degs
		DW	024E1h		;arctan(1.273) = 51.858 degs
		DW	024F0h		;arctan(1.277) = 51.944 degs
		DW	024FFh		;arctan(1.281) = 52.028 degs
		DW	0250Fh		;arctan(1.285) = 52.113 degs
		DW	0251Eh		;arctan(1.289) = 52.197 degs
		DW	0252Dh		;arctan(1.293) = 52.281 degs
		DW	0253Dh		;arctan(1.297) = 52.365 degs
		DW	0254Ch		;arctan(1.301) = 52.448 degs
		DW	0255Bh		;arctan(1.305) = 52.531 degs
		DW	0256Ah		;arctan(1.309) = 52.614 degs
		DW	02579h		;arctan(1.312) = 52.696 degs
		DW	02588h		;arctan(1.316) = 52.778 degs
		DW	02597h		;arctan(1.320) = 52.860 degs
		DW	025A6h		;arctan(1.324) = 52.941 degs
		DW	025B4h		;arctan(1.328) = 53.022 degs
		DW	025C3h		;arctan(1.332) = 53.103 degs
		DW	025D2h		;arctan(1.336) = 53.184 degs
		DW	025E0h		;arctan(1.340) = 53.264 degs
		DW	025EFh		;arctan(1.344) = 53.344 degs
		DW	025FDh		;arctan(1.348) = 53.424 degs
		DW	0260Ch		;arctan(1.352) = 53.503 degs
		DW	0261Ah		;arctan(1.355) = 53.582 degs
		DW	02629h		;arctan(1.359) = 53.661 degs
		DW	02637h		;arctan(1.363) = 53.739 degs
		DW	02645h		;arctan(1.367) = 53.817 degs
		DW	02653h		;arctan(1.371) = 53.895 degs
		DW	02661h		;arctan(1.375) = 53.973 degs
		DW	0266Fh		;arctan(1.379) = 54.050 degs
		DW	0267Eh		;arctan(1.383) = 54.127 degs
		DW	0268Bh		;arctan(1.387) = 54.204 degs
		DW	02699h		;arctan(1.391) = 54.280 degs
		DW	026A7h		;arctan(1.395) = 54.356 degs
		DW	026B5h		;arctan(1.398) = 54.432 degs
		DW	026C3h		;arctan(1.402) = 54.508 degs
		DW	026D1h		;arctan(1.406) = 54.583 degs
		DW	026DEh		;arctan(1.410) = 54.658 degs
		DW	026ECh		;arctan(1.414) = 54.733 degs
		DW	026F9h		;arctan(1.418) = 54.807 degs
		DW	02707h		;arctan(1.422) = 54.881 degs
		DW	02714h		;arctan(1.426) = 54.955 degs
		DW	02722h		;arctan(1.430) = 55.029 degs
		DW	0272Fh		;arctan(1.434) = 55.102 degs
		DW	0273Ch		;arctan(1.437) = 55.176 degs
		DW	0274Ah		;arctan(1.441) = 55.248 degs
		DW	02757h		;arctan(1.445) = 55.321 degs
		DW	02764h		;arctan(1.449) = 55.393 degs
		DW	02771h		;arctan(1.453) = 55.465 degs
		DW	0277Eh		;arctan(1.457) = 55.537 degs
		DW	0278Bh		;arctan(1.461) = 55.609 degs
		DW	02798h		;arctan(1.465) = 55.680 degs
		DW	027A5h		;arctan(1.469) = 55.751 degs
		DW	027B2h		;arctan(1.473) = 55.822 degs
		DW	027BFh		;arctan(1.477) = 55.892 degs
		DW	027CCh		;arctan(1.480) = 55.962 degs
		DW	027D8h		;arctan(1.484) = 56.032 degs
		DW	027E5h		;arctan(1.488) = 56.102 degs
		DW	027F2h		;arctan(1.492) = 56.172 degs
		DW	027FEh		;arctan(1.496) = 56.241 degs
		DW	0280Bh		;arctan(1.500) = 56.310 degs
		DW	02817h		;arctan(1.504) = 56.379 degs
		DW	02824h		;arctan(1.508) = 56.447 degs
		DW	02830h		;arctan(1.512) = 56.515 degs
		DW	0283Dh		;arctan(1.516) = 56.583 degs
		DW	02849h		;arctan(1.520) = 56.651 degs
		DW	02855h		;arctan(1.523) = 56.719 degs
		DW	02862h		;arctan(1.527) = 56.786 degs
		DW	0286Eh		;arctan(1.531) = 56.853 degs
		DW	0287Ah		;arctan(1.535) = 56.920 degs
		DW	02886h		;arctan(1.539) = 56.986 degs
		DW	02892h		;arctan(1.543) = 57.053 degs
		DW	0289Eh		;arctan(1.547) = 57.119 degs
		DW	028AAh		;arctan(1.551) = 57.185 degs
		DW	028B6h		;arctan(1.555) = 57.250 degs
		DW	028C2h		;arctan(1.559) = 57.316 degs
		DW	028CEh		;arctan(1.563) = 57.381 degs
		DW	028DAh		;arctan(1.566) = 57.446 degs
		DW	028E5h		;arctan(1.570) = 57.510 degs
		DW	028F1h		;arctan(1.574) = 57.575 degs
		DW	028FDh		;arctan(1.578) = 57.639 degs
		DW	02909h		;arctan(1.582) = 57.703 degs
		DW	02914h		;arctan(1.586) = 57.767 degs
		DW	02920h		;arctan(1.590) = 57.830 degs
		DW	0292Bh		;arctan(1.594) = 57.894 degs
		DW	02937h		;arctan(1.598) = 57.957 degs
		DW	02942h		;arctan(1.602) = 58.020 degs
		DW	0294Eh		;arctan(1.605) = 58.082 degs
		DW	02959h		;arctan(1.609) = 58.145 degs
		DW	02964h		;arctan(1.613) = 58.207 degs
		DW	02970h		;arctan(1.617) = 58.269 degs
		DW	0297Bh		;arctan(1.621) = 58.331 degs
		DW	02986h		;arctan(1.625) = 58.392 degs
		DW	02991h		;arctan(1.629) = 58.454 degs
		DW	0299Ch		;arctan(1.633) = 58.515 degs
		DW	029A7h		;arctan(1.637) = 58.576 degs
		DW	029B2h		;arctan(1.641) = 58.637 degs
		DW	029BEh		;arctan(1.645) = 58.697 degs
		DW	029C8h		;arctan(1.648) = 58.758 degs
		DW	029D3h		;arctan(1.652) = 58.818 degs
		DW	029DEh		;arctan(1.656) = 58.878 degs
		DW	029E9h		;arctan(1.660) = 58.937 degs
		DW	029F4h		;arctan(1.664) = 58.997 degs
		DW	029FFh		;arctan(1.668) = 59.056 degs
		DW	02A0Ah		;arctan(1.672) = 59.115 degs
		DW	02A14h		;arctan(1.676) = 59.174 degs
		DW	02A1Fh		;arctan(1.680) = 59.233 degs
		DW	02A2Ah		;arctan(1.684) = 59.291 degs
		DW	02A34h		;arctan(1.687) = 59.349 degs
		DW	02A3Fh		;arctan(1.691) = 59.407 degs
		DW	02A49h		;arctan(1.695) = 59.465 degs
		DW	02A54h		;arctan(1.699) = 59.523 degs
		DW	02A5Eh		;arctan(1.703) = 59.580 degs
		DW	02A69h		;arctan(1.707) = 59.638 degs
		DW	02A73h		;arctan(1.711) = 59.695 degs
		DW	02A7Dh		;arctan(1.715) = 59.752 degs
		DW	02A88h		;arctan(1.719) = 59.808 degs
		DW	02A92h		;arctan(1.723) = 59.865 degs
		DW	02A9Ch		;arctan(1.727) = 59.921 degs
		DW	02AA7h		;arctan(1.730) = 59.977 degs
		DW	02AB1h		;arctan(1.734) = 60.033 degs
		DW	02ABBh		;arctan(1.738) = 60.089 degs
		DW	02AC5h		;arctan(1.742) = 60.145 degs
		DW	02ACFh		;arctan(1.746) = 60.200 degs
		DW	02AD9h		;arctan(1.750) = 60.255 degs
		DW	02AE3h		;arctan(1.754) = 60.310 degs
		DW	02AEDh		;arctan(1.758) = 60.365 degs
		DW	02AF7h		;arctan(1.762) = 60.420 degs
		DW	02B01h		;arctan(1.766) = 60.474 degs
		DW	02B0Bh		;arctan(1.770) = 60.528 degs
		DW	02B15h		;arctan(1.773) = 60.582 degs
		DW	02B1Eh		;arctan(1.777) = 60.636 degs
		DW	02B28h		;arctan(1.781) = 60.690 degs
		DW	02B32h		;arctan(1.785) = 60.744 degs
		DW	02B3Ch		;arctan(1.789) = 60.797 degs
		DW	02B45h		;arctan(1.793) = 60.850 degs
		DW	02B4Fh		;arctan(1.797) = 60.903 degs
		DW	02B59h		;arctan(1.801) = 60.956 degs
		DW	02B62h		;arctan(1.805) = 61.009 degs
		DW	02B6Ch		;arctan(1.809) = 61.061 degs
		DW	02B75h		;arctan(1.812) = 61.113 degs
		DW	02B7Fh		;arctan(1.816) = 61.166 degs
		DW	02B88h		;arctan(1.820) = 61.218 degs
		DW	02B92h		;arctan(1.824) = 61.269 degs
		DW	02B9Bh		;arctan(1.828) = 61.321 degs
		DW	02BA5h		;arctan(1.832) = 61.372 degs
		DW	02BAEh		;arctan(1.836) = 61.424 degs
		DW	02BB7h		;arctan(1.840) = 61.475 degs
		DW	02BC0h		;arctan(1.844) = 61.526 degs
		DW	02BCAh		;arctan(1.848) = 61.577 degs
		DW	02BD3h		;arctan(1.852) = 61.627 degs
		DW	02BDCh		;arctan(1.855) = 61.678 degs
		DW	02BE5h		;arctan(1.859) = 61.728 degs
		DW	02BEEh		;arctan(1.863) = 61.778 degs
		DW	02BF7h		;arctan(1.867) = 61.828 degs
		DW	02C01h		;arctan(1.871) = 61.878 degs
		DW	02C0Ah		;arctan(1.875) = 61.928 degs
		DW	02C13h		;arctan(1.879) = 61.977 degs
		DW	02C1Ch		;arctan(1.883) = 62.026 degs
		DW	02C24h		;arctan(1.887) = 62.075 degs
		DW	02C2Dh		;arctan(1.891) = 62.124 degs
		DW	02C36h		;arctan(1.895) = 62.173 degs
		DW	02C3Fh		;arctan(1.898) = 62.222 degs
		DW	02C48h		;arctan(1.902) = 62.271 degs
		DW	02C51h		;arctan(1.906) = 62.319 degs
		DW	02C5Ah		;arctan(1.910) = 62.367 degs
		DW	02C62h		;arctan(1.914) = 62.415 degs
		DW	02C6Bh		;arctan(1.918) = 62.463 degs
		DW	02C74h		;arctan(1.922) = 62.511 degs
		DW	02C7Ch		;arctan(1.926) = 62.559 degs
		DW	02C85h		;arctan(1.930) = 62.606 degs
		DW	02C8Eh		;arctan(1.934) = 62.653 degs
		DW	02C96h		;arctan(1.937) = 62.700 degs
		DW	02C9Fh		;arctan(1.941) = 62.747 degs
		DW	02CA7h		;arctan(1.945) = 62.794 degs
		DW	02CB0h		;arctan(1.949) = 62.841 degs
		DW	02CB8h		;arctan(1.953) = 62.888 degs
		DW	02CC1h		;arctan(1.957) = 62.934 degs
		DW	02CC9h		;arctan(1.961) = 62.980 degs
		DW	02CD2h		;arctan(1.965) = 63.026 degs
		DW	02CDAh		;arctan(1.969) = 63.072 degs
		DW	02CE2h		;arctan(1.973) = 63.118 degs
		DW	02CEBh		;arctan(1.977) = 63.164 degs
		DW	02CF3h		;arctan(1.980) = 63.209 degs
		DW	02CFBh		;arctan(1.984) = 63.255 degs
		DW	02D03h		;arctan(1.988) = 63.300 degs
		DW	02D0Ch		;arctan(1.992) = 63.345 degs
		DW	02D14h		;arctan(1.996) = 63.390 degs
		DW	02D1Ch		;arctan(2.000) = 63.435 degs

STACK		ENDS

;============================================================================

LIBCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:LIBCODE
		ASSUME DS:DATA

;* Tangent - calculate tan(p deg)
;*
;* pass: ax = p deg (0 .. 90 (quad 1), 422 .. 511 (quad 4))
;* ret : dx = tan(ax)
;* kill: bx, flags

Tangent		PROC	FAR

		mov	bx,ax		;bx = tan table index

		cmp	bx,90		;quad 1?
		jbe	TanQuad1	;yes ->
		cmp	bx,422		;quad 4?
		jae	TanQuad4	;yes ->

		xor	dx,dx		;error, return 0
		ret

TanQuad1:      	shl	bx,1		;*2 word index
		mov	dx,SS:TanTable[bx]
		ret

TanQuad4:	sub	bx,512		;reverse tan table index
		neg	bx
		shl	bx,1		;*2 word index
		mov	dx,SS:TanTable[bx]
		neg	dx
		ret

Tangent		ENDP

;----------------------------------------------------------------------------

;* FastArcTan - fast arctan look up
;*
;* pass: ax = signed binary fraction
;* ret : ax = arctan(frac) (fine pdegs)
;* kill: bx, cx, dx, flags

FastArcTan	PROC	FAR

		ABSV	ax		;ax = abs(frac), dx = sign(frac)

		mov	cl,7		;prime for /128

		mov	bx,ax
		shr	bx,cl		;/128
		adc	bx,0		;1/2 bit round up

		shl	bx,1		;*2 word index

		mov	ax,SS:ArcTanTable[bx]

		xor	ax,dx		;restore sign
		sub	ax,dx

		ret

FastArcTan	ENDP

;----------------------------------------------------------------------------

;* ArcTan - arctan look up and interpolation
;*
;* pass: ax = signed binary fraction
;* ret : ax = arctan(frac) (fine pdegs)
;* kill: bx, cx, dx, si, bp, flags

ArcTan		PROC	FAR

		ABSV	ax		;ax = abs(frac), dx = sign(frac)

		mov	bp,dx		;store sign(frac)
		mov	dx,ax		;store abs(frac)

		mov	cl,7		;prime for /128

		mov	bx,ax
		shr	bx,cl		;/128

		shl	bx,1		;*2 word index

		mov	ax,SS:ArcTanTable[bx]

		and	dx,0007fh	;extract remaining bits
		jz	@F		;(trap frac = 08000h case) ->
   
		mov	si,ax

		mov	ax,SS:ArcTanTable[bx+2]

		sub	ax,si		;ax = diff

		mul	dx

		shr	ax,cl		;/128

		adc	ax,si		;(1/2 bit round up)

@@:		xor	ax,bp		;restore sign
		sub	ax,bp

		ret

ArcTan		ENDP

;----------------------------------------------------------------------------

;* FastArcTan2 - fast arctan look up (-2 .. +2)
;*
;* pass: ax = signed binary fraction (/2)
;* ret : ax = arctan(frac) (fine pdegs)
;* kill: bx, cx, dx, flags

FastArcTan2	PROC	FAR

		ABSV	ax		;ax = abs(frac), dx = sign(frac)

		mov	cl,6		;prime for /64

		mov	bx,ax
		shr	bx,cl		;/64
		adc	bx,0		;1/2 bit round up

		shl	bx,1		;*2 word index

		mov	ax,SS:ArcTanTable[bx]

		xor	ax,dx		;restore sign
		sub	ax,dx

		ret

FastArcTan2	ENDP

;----------------------------------------------------------------------------

;* ArcTan2 - arctan look up and interpolation (-2 .. +2)
;*
;* pass: ax = signed binary fraction (/2)
;* ret : ax = arctan(frac) (fine pdegs)
;* kill: bx, cx, dx, si, bp, flags

ArcTan2		PROC	FAR

		ABSV	ax		;ax = abs(frac), dx = sign(frac)

		mov	bp,dx		;store sign(frac)
		mov	dx,ax		;store abs(frac)

		mov	cl,6		;prime for /64

		mov	bx,ax
		shr	bx,cl		;/64

		shl	bx,1		;*2 word index

		mov	ax,SS:ArcTanTable[bx]

		and	dx,0003fh	;extract remaining bits
		jz	@F		;(trap frac = 08000h case) ->
   
		mov	si,ax

		mov	ax,SS:ArcTanTable[bx+2]

		sub	ax,si		;ax = diff

		mul	dx

		shr	ax,cl		;/64

		adc	ax,si		;(1/2 bit round up)

@@:		xor	ax,bp		;restore sign
		sub	ax,bp

		ret

ArcTan2		ENDP

;----------------------------------------------------------------------------

;* FastArcSin
;*
;* pass: ax = signed binary fraction
;* ret : ax = arcsin(frac) (fine pdegs)
;* kill: cx, dx, bp, flags

FastArcSin	PROC	FAR

		ABSV	ax

		mov	cl,7		;/128

		mov	bp,ax
		shr	bp,cl		;/128
		adc	bp,0		;1/2 bit round up

		shl	bp,1		;*2 word index

		mov	ax,ArcSinTable[bp]

		xor	ax,dx		;restore sign
		sub	ax,dx

		ret

FastArcSin	ENDP

;----------------------------------------------------------------------------

;* FastArcCos
;*
;* pass: ax = signed binary fraction
;* ret : ax = arccos(frac) (fine pdegs)
;* kill: cx, dx, bp, flags

FastArcCos	PROC	FAR

		ABSV	ax

		mov	cl,7		;/128

		mov	bp,ax
		shr	bp,cl		;/128
		adc	bp,0		;1/2 bit round up

		shl	bp,1		;*2 word index

		mov	ax,ArcCosTable[bp]

;* if frac < 0 then return 180 - arccos(frac)

		test	dx,dx		;frac < 0?
		jns	@F		;no ->

		mov	dx,ax

		mov	ax,(256*128)-1	;(-1 keeps result +ve)

		sub	ax,dx

@@:		ret

FastArcCos	ENDP

;----------------------------------------------------------------------------

;* ArcTan360
;* 
;* pass: cx = x
;*       dx = y
;* ret : ax = arctan(x / y) = 0 .. 360 degs (fine pdegs)
;* kill: assume all (except ax)

ArcTan360	PROC	FAR

		xor	bx,bx		;clear quad index

		test	cx,cx
		jz	XZero		;sort x = 0 ->
		jns	@F
		neg	cx
		or	bx,0010b

@@:		test	dx,dx
		jz	YZero		;sort y = 0 ->
		jns	@F
		neg	dx
		or	bx,0100b

@@:		cmp	cx,dx
		jb	YGrtr		;y > x ->
		ja	XGrtr		;x > y ->

		mov	dx,64*128	;45 degs

		jmp	QuadSwitch[bx]

;---------------------------
YGrtr		LABEL	NEAR
;---------------------------

;* theta = arctan(x / y)

		xchg	cx,dx
		xor	ax,ax
		shr	dx,1
		rcr	ax,1
		div	cx

		push	bx
		call	ArcTan
		pop	bx

		mov	dx,ax

		jmp	QuadSwitch[bx]

;---------------------------
XGrtr		LABEL	NEAR
;---------------------------

;* theta = 90 - arctan(y / x)

		xor	ax,ax
		shr	dx,1
		rcr	ax,1
		div	cx

		push	bx
		call	ArcTan
		pop	bx

		mov	dx,128*128
		sub	dx,ax

		jmp	QuadSwitch[bx]

;---------------------------
Quad1		LABEL	NEAR
;---------------------------

;* result = theta

		mov	ax,dx
		ret

;---------------------------
Quad2	 	LABEL	NEAR
;---------------------------

;* result = 180 - theta

		mov	ax,256*128
		sub	ax,dx
		ret
		
;---------------------------
Quad3		LABEL	NEAR
;---------------------------

;* result = 180 + theta

		mov	ax,256*128
		add	ax,dx
		ret
		
;---------------------------
Quad4		LABEL	NEAR
;---------------------------

;* result = 360 - theta

		xor	ax,ax
		sub	ax,dx
		ret

;---------------------------
XZero		LABEL	NEAR
;---------------------------

		test	dx,dx
		js	@F

;* result = 0

		xor	ax,ax
		ret

;* result = 180

@@:		mov	ax,256*128
		ret

;---------------------------
YZero		LABEL	NEAR
;---------------------------

		test	bx,0010b
		jnz	@F

;* result = 90

		mov	ax,128*128
		ret

;* result = 270

@@:		mov	ax,384*128
		ret

ArcTan360	ENDP

LIBCODE		ENDS

;============================================================================

		END

