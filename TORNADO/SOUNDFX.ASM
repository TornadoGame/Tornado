;****************************************************************************
;*
;* SOUNDFX.ASM
;*
;* Sound effects.
;*
;* 04.01.1993 - KJB
;*
;* Notes
;* 컴컴�
;*
;*    Speaker
;*    컴컴컴�
;*	 Speaker uses channel 1 for all sounds.
;*
;*    SoundBlaster
;*    컴컴컴컴컴컴
;*	 AdLib driver is loaded as "driver 1".
;*	 AdLib uses logical channels 1 and 2.
;*	 SoundBlaster driver is loaded as "driver 2".
;*	 SoundBlaster uses logical channel 3.
;*
;*    AdLib
;*    컴컴�
;*	 AdLib uses channel 1 for engine sound only.
;*	 AdLib uses channel 2 for all other sounds.
;*
;*    Roland
;*    컴컴컴
;*	 Roland uses channel 1 for engine sound only.
;*	 Roland uses channel 2 for all other sounds.
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	InstallSound
		PUBLIC	NormaliseSound
		PUBLIC	SuspendSound
		PUBLIC	ResumeSound
		PUBLIC	RefreshSound
		PUBLIC	UpdateSound
		PUBLIC	ExploSound1
		PUBLIC	ExploSound2
		PUBLIC	ExploSound3
		PUBLIC	ScreechSound
		PUBLIC	MorseDotSound
		PUBLIC	MorseDashSound
		PUBLIC	GearSound
		PUBLIC	AttentionSound
		PUBLIC	KillAttnSound
		PUBLIC	CannonSound
		PUBLIC	LaunchSound
		PUBLIC	RWRAlertSound
		PUBLIC	DecoySound

		PUBLIC	Ch1Timer
		PUBLIC	Ch2Timer
		PUBLIC	Ch3Timer

		PUBLIC	SoundOn
		PUBLIC	EngSoundOn
		PUBLIC	Ch1Priority
		PUBLIC	Ch2Priority
		PUBLIC	Ch3Priority
		PUBLIC	Ch1Flags
		PUBLIC	Ch2Flags
		PUBLIC	Ch3Flags

		EXTRN	LoadFile:FAR
EXTRN	GameViewMode:WORD
EXTRN   CockpitViews:BYTE
		EXTRN	SoundCard:WORD
		EXTRN	Rpm1:WORD
		EXTRN	Rpm2:WORD
		EXTRN	Reheat:WORD
		EXTRN	AirTgtPtr:WORD
		EXTRN	ArmMode:WORD

		EXTRN	SoundOption:BYTE
		EXTRN	DieFlag:BYTE
		EXTRN	InCockpit:BYTE
EXTRN	QuieterCockpit:BYTE
		EXTRN	ShakePriority:BYTE
		EXTRN	IRLockFlag:BYTE

;============================================================================

		INCLUDE	MAINDATA.INC

		INCLUDE	\LIB8086\USEFUL.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

;-------
;* flags
;-------

SoundOn		DB	0		;1 = sound on

EngSoundOn	DB	0		;1 = engine sound on

Installed	DB	0		;1 = installed

Normalised	DB	0		;1 = normalised

BlstFault	DB	0		;1 = fault

		EVEN

;-----------
;* temp data
;-----------

Tmp1		DB	0
Tmp2		DB	0

		EVEN

;----------------
;* sound channels
;----------------

Ch1Priority	DB	0		;0 = free, 1 = low, 255 = high
Ch2Priority	DB	0		;0 = free, 1 = low, 255 = high
Ch3Priority	DB	0		;0 = free, 1 = low, 255 = high

Ch1Flags	DB	0
Ch2Flags	DB	0
Ch3Flags	DB	0

		EVEN

Ch1Timer	DW	0		;secs * 50
Ch2Timer	DW	0		;secs * 50
Ch3Timer	DW	0		;secs * 50

;---------------------
;* sound channel flags
;---------------------

SFLG_LOOP	EQU	00000001b	;looping sound (stop when timer reaches zero)

;-----------------------
;* sound driver overlays
;-----------------------

;* file names

SpeakerBin	DB	"SPEAKER.BIN",0		;SND_SPEAKER
SBlasterBin	DB	"SBLASTER.BIN",0	;SND_SBLASTER
AdLibBin	DB	"ADLIB.BIN",0		;SND_ADLIB
RolandBin	DB	"ROLAND.BIN",0		;SND_ROLAND

		EVEN

;* file sizes

FSIZE_SPEAKER	EQU	2046			;SND_SPEAKER
FSIZE_SBLASTER	EQU	24832			;SND_SBLASTER
FSIZE_ADLIB	EQU	4424			;SND_ADLIB
FSIZE_ROLAND	EQU	7492			;SND_ROLAND

;* file paragraph sizes (16 byte units)

PSIZE_SPEAKER	EQU	(FSIZE_SPEAKER/16)+1 	;SND_SPEAKER
PSIZE_SBLASTER	EQU	(FSIZE_SBLASTER/16)+1	;SND_SBLASTER
PSIZE_ADLIB	EQU	(FSIZE_ADLIB/16)+1   	;SND_ADLIB
PSIZE_ROLAND	EQU	(FSIZE_ROLAND/16)+1  	;SND_ROLAND

;* sound driver segments

Driver1Seg	DW	0
Driver2Seg	DW	0

;------------------------
;* sound routine switches (wrt SoundCard)
;------------------------

_InstallSound	DW	InstallNull	;SND_NULL
		DW	InstallSpkr	;SND_SPEAKER
		DW	InstallBlst	;SND_SBLASTER
		DW	InstallAdLb	;SND_ADLIB
		DW	InstallRlnd	;SND_ROLAND

_NormaliseSound	DW	NormalNull	;SND_NULL
		DW	NormalSpkr	;SND_SPEAKER
		DW	NormalBlst	;SND_SBLASTER
		DW	NormalAdLb	;SND_ADLIB
		DW	NormalRlnd	;SND_ROLAND

_SuspendSound	DW	SuspendNull	;SND_NULL
		DW	SuspendSpkr	;SND_SPEAKER
		DW	SuspendBlst	;SND_SBLASTER
		DW	SuspendAdLb	;SND_ADLIB
		DW	SuspendRlnd	;SND_ROLAND

_RefreshSound	DW	RefreshNull	;SND_NULL
		DW	RefreshSpkr	;SND_SPEAKER
		DW	RefreshBlst	;SND_SBLASTER
		DW	RefreshAdLb	;SND_ADLIB
		DW	RefreshRlnd	;SND_ROLAND

_UpdateSound	DW	UpdateNull	;SND_NULL
		DW	UpdateSpkr	;SND_SPEAKER
		DW	UpdateBlst	;SND_SBLASTER
		DW	UpdateAdLb	;SND_ADLIB
		DW	UpdateRlnd	;SND_ROLAND

_ExploSound1	DW	Explo1Null	;SND_NULL
		DW	Explo1Spkr	;SND_SPEAKER
		DW	Explo1Blst	;SND_SBLASTER
		DW	Explo1AdLb	;SND_ADLIB
		DW	Explo1Rlnd	;SND_ROLAND

_ExploSound2	DW	Explo2Null	;SND_NULL
		DW	Explo2Spkr	;SND_SPEAKER
		DW	Explo2Blst	;SND_SBLASTER
		DW	Explo2AdLb	;SND_ADLIB
		DW	Explo2Rlnd	;SND_ROLAND

_ExploSound3	DW	Explo3Null	;SND_NULL
		DW	Explo3Spkr	;SND_SPEAKER
		DW	Explo3Blst	;SND_SBLASTER
		DW	Explo3AdLb	;SND_ADLIB
		DW	Explo3Rlnd	;SND_ROLAND

_ScreechSound	DW	ScreechNull	;SND_NULL
		DW	ScreechSpkr	;SND_SPEAKER
		DW	ScreechBlst	;SND_SBLASTER
		DW	ScreechAdLb	;SND_ADLIB
		DW	ScreechRlnd	;SND_ROLAND

_MorseDotSound	DW	MorseDotNull	;SND_NULL
		DW	MorseDotSpkr	;SND_SPEAKER
		DW	MorseDotBlst	;SND_SBLASTER
		DW	MorseDotAdLb	;SND_ADLIB
		DW	MorseDotRlnd	;SND_ROLAND

_MorseDashSound	DW	MorseDashNull	;SND_NULL
		DW	MorseDashSpkr	;SND_SPEAKER
		DW	MorseDashBlst	;SND_SBLASTER
		DW	MorseDashAdLb	;SND_ADLIB
		DW	MorseDashRlnd	;SND_ROLAND

_GearSound	DW	GearNull	;SND_NULL
		DW	GearSpkr	;SND_SPEAKER
		DW	GearBlst	;SND_SBLASTER
		DW	GearAdLb	;SND_ADLIB
		DW	GearRlnd	;SND_ROLAND

_AttentionSound	DW	AttentionNull	;SND_NULL
		DW	AttentionSpkr	;SND_SPEAKER
		DW	AttentionBlst	;SND_SBLASTER
		DW	AttentionAdLb	;SND_ADLIB
		DW	AttentionRlnd	;SND_ROLAND

_KillAttnSound	DW	KillAttnNull	;SND_NULL
		DW	KillAttnSpkr	;SND_SPEAKER
		DW	KillAttnBlst	;SND_SBLASTER
		DW	KillAttnAdLb	;SND_ADLIB
		DW	KillAttnRlnd	;SND_ROLAND

_CannonSound	DW	CannonNull  	;SND_NULL
		DW	CannonSpkr  	;SND_SPEAKER
		DW	CannonBlst  	;SND_SBLASTER
		DW	CannonAdLb  	;SND_ADLIB
		DW	CannonRlnd  	;SND_ROLAND

_LaunchSound	DW	LaunchNull  	;SND_NULL
		DW	LaunchSpkr  	;SND_SPEAKER
		DW	LaunchBlst  	;SND_SBLASTER
		DW	LaunchAdLb  	;SND_ADLIB
		DW	LaunchRlnd  	;SND_ROLAND

_RWRAlertSound	DW	RWRAlertNull  	;SND_NULL
		DW	RWRAlertSpkr  	;SND_SPEAKER
		DW	RWRAlertBlst  	;SND_SBLASTER
		DW	RWRAlertAdLb  	;SND_ADLIB
		DW	RWRAlertRlnd  	;SND_ROLAND

_DecoySound	DW	DecoyNull  	;SND_NULL
		DW	DecoySpkr  	;SND_SPEAKER
		DW	DecoyBlst  	;SND_SBLASTER
		DW	DecoyAdLb  	;SND_ADLIB
		DW	DecoyRlnd  	;SND_ROLAND

;-----------------
;* speaker equates
;-----------------

;* procedure codes

SPKR_NORM	EQU	002h		;normalise
SPKR_REFRESH	EQU	001h		;refresh
SPKR_FXON1	EQU	004h		;start effect (ch1)
SPKR_FXOFF1	EQU	005h		;stop effect (ch1)
SPKR_REVS1	EQU	007h		;set engine revs (ch1) (0 .. 255 min)

;* effect codes

SPKR_FX_INT_ENG	EQU	000h		;internal engine
SPKR_FX_EXT_ENG	EQU	001h		;external engine
SPKR_FX_ATTN	EQU	00dh		;attention getters
SPKR_FX_RWR	EQU	00ch		;RWR alert
SPKR_FX_CANNON	EQU	008h		;cannon
SPKR_FX_EXPLO1	EQU	003h		;explosion 1
SPKR_FX_EXPLO2	EQU	004h		;explosion 2
SPKR_FX_EXPLO3	EQU	002h		;explosion 3
SPKR_FX_LAUNCH	EQU	007h		;missile launch
SPKR_FX_SCREECH	EQU	00ah		;wheel screech
SPKR_FX_DECOY	EQU	005h		;chaff / flare
SPKR_FX_MDOT	EQU	013h		;Morse dot
SPKR_FX_MDASH	EQU	012h		;Morse dash
SPKR_FX_GEAR	EQU	010h		;gear up / down
SPKR_FX_GROWL	EQU	00bh		;lock on growl
SPKR_FX_RUMBLE	EQU	009h		;rumble

;* sound priorities (each effect must have a unique priority (identifer))

SPKR_PR_LAUNCH	EQU	255		;missile launch
SPKR_PR_ATTN	EQU	250		;attention getters
SPKR_PR_RWR	EQU	240		;RWR alert
SPKR_PR_CANNON	EQU	210		;cannon
SPKR_PR_EXPLO1	EQU	200		;explosion 1
SPKR_PR_EXPLO2	EQU	190		;explosion 2 - 190
SPKR_PR_EXPLO3	EQU	180		;explosion 3 - 180
SPKR_PR_SCREECH	EQU	150		;wheel screech
SPKR_PR_DECOY	EQU	125		;chaff / flare
SPKR_PR_MDOT	EQU	100		;Morse dot
SPKR_PR_MDASH	EQU	99		;Morse dash
SPKR_PR_GEAR	EQU	80		;gear up / down
SPKR_PR_GROWL	EQU	5		;lock on growl
SPKR_PR_RUMBLE	EQU	1		;rumble

;* sound flags

SPKR_FL_ATTN	EQU	SFLG_LOOP	;attention getters
SPKR_FL_RWR	EQU	SFLG_LOOP	;RWR alert
SPKR_FL_CANNON	EQU	0		;cannon
SPKR_FL_EXPLO1	EQU	0		;explosion 1
SPKR_FL_EXPLO2	EQU	0		;explosion 2
SPKR_FL_EXPLO3	EQU	0		;explosion 3
SPKR_FL_LAUNCH	EQU	0		;missile launch
SPKR_FL_SCREECH	EQU	0		;wheel screech
SPKR_FL_DECOY	EQU	0		;chaff / flare
SPKR_FL_MDOT	EQU	0		;Morse dot
SPKR_FL_MDASH	EQU	0		;Morse dash
SPKR_FL_GEAR	EQU	0		;gear up / down
SPKR_FL_GROWL	EQU	0		;lock on growl
SPKR_FL_RUMBLE	EQU	0		;rumble

;* timer values (secs * 50) (-1 = continuous)

SPKR_TM_ATTN	EQU	150		;attention getters
SPKR_TM_RWR	EQU	50		;RWR alert
SPKR_TM_CANNON	EQU	25		;cannon
SPKR_TM_EXPLO1	EQU	50		;explosion 1
SPKR_TM_EXPLO2	EQU	50		;explosion 2
SPKR_TM_EXPLO3	EQU	25		;explosion 3
SPKR_TM_LAUNCH	EQU	10		;missile launch
SPKR_TM_SCREECH	EQU	8		;wheel screech
SPKR_TM_DECOY	EQU	5		;chaff / flare
SPKR_TM_MDOT	EQU	5		;Morse dot
SPKR_TM_MDASH	EQU	20		;Morse dash
SPKR_TM_GEAR	EQU	40		;gear up / down
SPKR_TM_GROWL	EQU	-1		;lock on growl
SPKR_TM_RUMBLE	EQU	-1		;rumble

;----------------------
;* SoundBlaster equates
;----------------------

;* procedure codes

BLST_INIT	EQU	005h		;initialize
BLST_NORM	EQU	002h		;normalise
BLST_FXON1	EQU	000h		;start effect (ch1)
BLST_FXOFF1	EQU	001h		;stop effect (ch1)
BLST_REVS1	EQU	004h		;set engine revs (ch1) (0 .. 212 max)
BLST_FAULT	EQU	006h		;test for DSP fault

;* effect codes

BLST_FX_INT_ENG	EQU	007h		;internal engine
BLST_FX_EXT_ENG	EQU	003h		;external engine
BLST_FX_CANNON	EQU	000h		;cannon
BLST_FX_EXPLO1	EQU	001h		;explosion 1
BLST_FX_EXPLO2	EQU	002h		;explosion 2
BLST_FX_EXPLO3	EQU	004h		;explosion 3
BLST_FX_SCREECH	EQU	008h		;wheel screech

;* sound priorities (each effect must have a unique priority (identifer))

BLST_PR_CANNON	EQU	210		;cannon
BLST_PR_EXPLO1	EQU	200		;explosion 1
BLST_PR_EXPLO2	EQU	190		;explosion 2
BLST_PR_EXPLO3	EQU	180		;explosion 3
BLST_PR_SCREECH	EQU	150		;wheel screech

;* sound flags

BLST_FL_CANNON	EQU	0		;cannon
BLST_FL_EXPLO1	EQU	0		;explosion 1
BLST_FL_EXPLO2	EQU	0	 	;explosion 2
BLST_FL_EXPLO3	EQU	0	 	;explosion 3
BLST_FL_SCREECH	EQU	0	 	;wheel screech

;* timer values (secs * 50) (-1 = continuous)

BLST_TM_CANNON	EQU	25		;cannon
BLST_TM_EXPLO1	EQU	65		;explosion 1
BLST_TM_EXPLO2	EQU	65		;explosion 2
BLST_TM_EXPLO3	EQU	35		;explosion 3
BLST_TM_SCREECH	EQU	8		;wheel screech

;---------------
;* AdLib equates
;---------------

;* procedure codes

ADLB_INIT	EQU	014h		;initialize
ADLB_NORM	EQU	002h		;normalise
ADLB_REFRESH	EQU	001h		;refresh
ADLB_FXON1	EQU	004h		;start effect (ch1)
ADLB_FXON2	EQU	005h		;start effect (ch2)
ADLB_FXOFF1	EQU	006h		;stop effect (ch1)
ADLB_FXOFF2	EQU	007h		;stop effect (ch2)
ADLB_REVS1	EQU	00ah		;set engine revs (ch1) (0 .. 255 max)
ADLB_REVS2	EQU	00bh		;set engine revs (ch2) (0 .. 255 max)
ADLB_VOL1	EQU	00eh		;set volume (ch1) (0 .. 63 max)
ADLB_VOL2	EQU	00fh		;set volume (ch2) (0 .. 63 max)

;* effect codes

ADLB_FX_INT_ENG	EQU	000h		;internal engine
ADLB_FX_EXT_ENG	EQU	001h		;external engine
ADLB_FX_ATTN	EQU	00dh		;attention getters
ADLB_FX_RWR	EQU	00ch		;RWR alert
ADLB_FX_CANNON	EQU	008h		;cannon
ADLB_FX_EXPLO1	EQU	003h		;explosion 1
ADLB_FX_EXPLO2	EQU	004h		;explosion 2
ADLB_FX_EXPLO3	EQU	002h		;explosion 3
ADLB_FX_LAUNCH	EQU	007h		;missile launch
ADLB_FX_SCREECH	EQU	00ah		;wheel screech
ADLB_FX_DECOY	EQU	005h		;chaff / flare
ADLB_FX_MDOT	EQU	013h		;Morse dot
ADLB_FX_MDASH	EQU	012h		;Morse dash
ADLB_FX_GEAR	EQU	010h		;gear up / down
ADLB_FX_GROWL	EQU	00bh		;lock on growl
ADLB_FX_RUMBLE	EQU	009h		;rumble

;* sound priorities (each effect must have a unique priority (identifer))
ADLB_PR_LAUNCH	EQU	255		;missile launch
ADLB_PR_ATTN	EQU	250		;attention getters
ADLB_PR_RWR	EQU	240		;RWR alert
ADLB_PR_CANNON	EQU	210		;cannon
ADLB_PR_EXPLO1	EQU	200		;explosion 1
ADLB_PR_EXPLO2	EQU	190		;explosion 2
ADLB_PR_EXPLO3	EQU	180		;explosion 3
ADLB_PR_SCREECH	EQU	150		;wheel screech
ADLB_PR_DECOY	EQU	125		;chaff / flare
ADLB_PR_MDOT	EQU	100		;Morse dot
ADLB_PR_MDASH	EQU	99		;Morse dash
ADLB_PR_GEAR	EQU	80		;gear up / down
ADLB_PR_GROWL	EQU	5		;lock on growl
ADLB_PR_RUMBLE	EQU	1		;rumble

;* sound flags

ADLB_FL_ATTN	EQU	SFLG_LOOP	;attention getters
ADLB_FL_RWR	EQU	SFLG_LOOP	;RWR alert
ADLB_FL_CANNON	EQU	0		;cannon
ADLB_FL_EXPLO1	EQU	0		;explosion 1
ADLB_FL_EXPLO2	EQU	0		;explosion 2
ADLB_FL_EXPLO3	EQU	0		;explosion 3
ADLB_FL_LAUNCH	EQU	0		;missile launch
ADLB_FL_SCREECH	EQU	0		;wheel screech
ADLB_FL_DECOY	EQU	0		;chaff / flare
ADLB_FL_MDOT	EQU	0		;Morse dot
ADLB_FL_MDASH	EQU	0		;Morse dash
ADLB_FL_GEAR	EQU	0		;gear up / down
ADLB_FL_GROWL	EQU	0		;lock on growl
ADLB_FL_RUMBLE	EQU	0		;rumble

;* timer values (secs * 50) (-1 = continuous)

ADLB_TM_ATTN	EQU	150		;attention getters
ADLB_TM_RWR	EQU	50		;RWR alert
ADLB_TM_CANNON	EQU	25		;cannon
ADLB_TM_EXPLO1	EQU	65		;explosion 1
ADLB_TM_EXPLO2	EQU	65		;explosion 2
ADLB_TM_EXPLO3	EQU	35		;explosion 3
ADLB_TM_LAUNCH	EQU	40		;missile launch
ADLB_TM_SCREECH	EQU	8		;wheel screech
ADLB_TM_DECOY	EQU	5		;chaff / flare
ADLB_TM_MDOT	EQU	5		;Morse dot
;ADLB_TM_MDASH	EQU	20		;Morse dash
ADLB_TM_MDASH	EQU	-1		;Morse dash
ADLB_TM_GEAR	EQU	75		;gear up / down
ADLB_TM_GROWL	EQU	-1		;lock on growl
ADLB_TM_RUMBLE	EQU	-1		;rumble

;----------------
;* Roland equates
;----------------

;* procedure codes

RLND_INIT	EQU	014h		;initialize
RLND_NORM	EQU	013h		;normalise
RLND_REFRESH	EQU	001h		;refresh
RLND_FXON1	EQU	004h		;start effect (ch1)
RLND_FXON2	EQU	005h		;start effect (ch2)
RLND_FXOFF1	EQU	006h		;stop effect (ch1)
RLND_FXOFF2	EQU	007h		;stop effect (ch2)
RLND_REVS1	EQU	00ah		;set engine revs (ch1) (0 .. 127 max)
RLND_REVS2	EQU	00bh		;set engine revs (ch2) (0 .. 127 max)
RLND_VOL1	EQU	00eh		;set volume (ch1) (0 .. 127 max)
RLND_VOL2	EQU	00fh		;set volume (ch2) (0 .. 127 max)

;* effect codes

RLND_FX_INT_ENG	EQU	000h		;internal engine
RLND_FX_EXT_ENG	EQU	001h		;external engine
RLND_FX_ATTN	EQU	00dh		;attention getters
RLND_FX_RWR	EQU	00ch		;RWR alert
RLND_FX_CANNON	EQU	008h		;cannon
RLND_FX_EXPLO1	EQU	003h		;explosion 1
RLND_FX_EXPLO2	EQU	004h		;explosion 2
RLND_FX_EXPLO3	EQU	002h		;explosion 3
RLND_FX_LAUNCH	EQU	007h		;missile launch
RLND_FX_SCREECH	EQU	00ah		;wheel screech
RLND_FX_DECOY	EQU	005h		;chaff / flare
RLND_FX_MDOT	EQU	013h		;Morse dot
RLND_FX_MDASH	EQU	012h		;Morse dash
RLND_FX_GEAR	EQU	010h		;gear up / down
RLND_FX_GROWL	EQU	00bh		;lock on growl
RLND_FX_RUMBLE	EQU	009h		;rumble

;* sound priorities (each effect must have a unique priority (identifer))
RLND_PR_LAUNCH	EQU	255		;missile launch
RLND_PR_ATTN	EQU	250		;attention getters
RLND_PR_RWR	EQU	240		;RWR alert
RLND_PR_CANNON	EQU	210		;cannon
RLND_PR_EXPLO1	EQU	200		;explosion 1
RLND_PR_EXPLO2	EQU	190		;explosion 2
RLND_PR_EXPLO3	EQU	180		;explosion 3
RLND_PR_SCREECH	EQU	150		;wheel screech
RLND_PR_DECOY	EQU	125		;chaff / flare
RLND_PR_MDOT	EQU	100		;Morse dot
RLND_PR_MDASH	EQU	99		;Morse dash
RLND_PR_GEAR	EQU	80		;gear up / down
RLND_PR_GROWL	EQU	5		;lock on growl
RLND_PR_RUMBLE	EQU	1		;rumble

;* sound flags

RLND_FL_ATTN	EQU	SFLG_LOOP	;attention getters
RLND_FL_RWR	EQU	SFLG_LOOP	;RWR alert
RLND_FL_CANNON	EQU	0		;cannon
RLND_FL_EXPLO1	EQU	0		;explosion 1
RLND_FL_EXPLO2	EQU	0		;explosion 2
RLND_FL_EXPLO3	EQU	0		;explosion 3
RLND_FL_LAUNCH	EQU	0		;missile launch
RLND_FL_SCREECH	EQU	0		;wheel screech
RLND_FL_DECOY	EQU	0		;chaff / flare
RLND_FL_MDOT	EQU	0		;Morse dot
RLND_FL_MDASH	EQU	0		;Morse dash
RLND_FL_GEAR	EQU	0		;gear up / down
RLND_FL_GROWL	EQU	0		;lock on growl
RLND_FL_RUMBLE	EQU	0		;rumble

;* timer values (secs * 50) (-1 = continuous)

RLND_TM_ATTN	EQU	150		;attention getters
RLND_TM_RWR	EQU	50		;RWR alert
RLND_TM_CANNON	EQU	25		;cannon
RLND_TM_EXPLO1	EQU	65		;explosion 1
RLND_TM_EXPLO2	EQU	65		;explosion 2
RLND_TM_EXPLO3	EQU	35		;explosion 3
RLND_TM_LAUNCH	EQU	35		;missile launch
RLND_TM_SCREECH	EQU	8		;wheel screech
RLND_TM_DECOY	EQU	5		;chaff / flare
RLND_TM_MDOT	EQU	5		;Morse dot
RLND_TM_MDASH	EQU	20		;Morse dash
RLND_TM_GEAR	EQU	75		;gear up / down
RLND_TM_GROWL	EQU	-1		;lock on growl
RLND_TM_RUMBLE	EQU	-1		;rumble

DATA		ENDS			

;============================================================================

SNDCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:SNDCODE
		ASSUME DS:DATA

;* SOUND1 - invoke sound driver 1 interrupt
;*
;* pass: opt = option
;* ret : see sound routine documentation
;* kill: assume all

SOUND1		MACRO	opt

		mov	ah,opt
		int	080h

		ENDM

;----------------------------------------------------------------------------

;* SOUND2 - invoke sound driver 2 interrupt
;*
;* pass: opt = option
;* ret : see sound routine documentation
;* kill: assume all

SOUND2		MACRO	opt

		mov	ah,opt
		int	081h

		ENDM

;----------------------------------------------------------------------------

;* SETCH1 - set channel 1
;*
;* pass: start    = start effect code (wrt card)
;*	 sound	  = sound number (wrt card)
;*	 priority = priority level
;*	 flags	  = sound flags
;*       timer	  = sec * 50
;* ret : Ch1Priority
;*	 Ch1Flags
;*       Ch1Timer
;* kill: assume all

SETCH1		MACRO	start,sound,priority,flags,timer

		cli
		mov	Ch1Priority,priority
		mov	Ch1Flags,flags
		mov	Ch1Timer,timer
		sti
		mov	al,sound
		xor	dl,dl		;default playback rate
		SOUND1	start

		ENDM

;----------------------------------------------------------------------------

;* SETCH2 - set channel 2
;*
;* pass: start    = start effect code (wrt card)
;*	 sound	  = sound number (wrt card)
;*	 priority = priority level
;*	 flags	  = sound flags
;*       timer	  = sec * 50
;* ret : Ch2Priority
;*	 Ch2Flags
;*       Ch2Timer
;* kill: assume all

SETCH2		MACRO	start,sound,priority,flags,timer

		cli
		mov	Ch2Priority,priority
		mov	Ch2Flags,flags
		mov	Ch2Timer,timer
		sti
		mov	al,sound
		xor	dl,dl		;default playback rate
		SOUND1	start

		ENDM

;----------------------------------------------------------------------------

;* SETCH3 - set channel 3
;*
;* pass: start    = start effect code (wrt card)
;*	 sound	  = sound number (wrt card)
;*	 priority = priority level
;*	 flags	  = sound flags
;*       timer	  = sec * 50
;* ret : Ch3Priority
;*	 Ch3Flags
;*       Ch3Timer
;* kill: assume all

SETCH3		MACRO	start,sound,priority,flags,timer

		cli
		mov	Ch3Priority,priority
		mov	Ch3Flags,flags
		mov	Ch3Timer,timer
		sti
		mov	al,sound
		xor	dl,dl		;default playback rate
		SOUND2	start

		ENDM

;----------------------------------------------------------------------------

;* CLRCH1 - clear channel 1
;*
;* pass: stop = stop effect code (wrt card)
;* ret : Ch1Priority
;*	 Ch1Flags
;*       Ch1Timer
;* kill: assume all

CLRCH1		MACRO	stop

		SOUND1	stop

		cli
		xor	ax,ax
		mov	Ch1Priority,al
		mov	Ch1Flags,al
		mov	Ch1Timer,ax
		sti

		ENDM

;----------------------------------------------------------------------------

;* CLRCH2 - clear channel 2
;*
;* pass: stop = stop effect code (wrt card)
;* ret : Ch2Priority
;*	 Ch2Flags
;*       Ch2Timer
;* kill: assume all

CLRCH2		MACRO	stop

		SOUND1	stop

		cli
		xor	ax,ax
		mov	Ch2Priority,al
		mov	Ch2Flags,al
		mov	Ch2Timer,ax
		sti

		ENDM

;----------------------------------------------------------------------------

;* CLRCH3 - clear channel 3
;*
;* pass: stop = stop effect code (wrt card)
;* ret : Ch3Priority
;*	 Ch3Flags
;*       Ch3Timer
;* kill: assume all

CLRCH3		MACRO	stop

		SOUND2	stop

		cli
		xor	ax,ax
		mov	Ch3Priority,al
		mov	Ch3Flags,al
		mov	Ch3Timer,ax
		sti

		ENDM

;----------------------------------------------------------------------------

;* InstallSound - load sound card driver(s) and initialize
;*
;* pass: SoundCard
;* ret : cf = 0 = ok
;*       cf = 1 = error
;*	    DieFlag
;* kill: assume all (except cf)

InstallSound	PROC	FAR

;* init SoundOn flag wrt SoundOption

		cmp	SoundOption,SOUND_OPT_OFF
		je	@F

		mov	SoundOn,1

;* install sound card driver

@@:		mov	bx,SoundCard
		jmp	_InstallSound[bx]

;---------------------------
InstallNull	LABEL	NEAR
;---------------------------

		clc			;cf = 0 = ok
		ret

;---------------------------
InstallSpkr	LABEL	NEAR
;---------------------------

;* allocate memory for speaker driver

		mov	bx,PSIZE_SPEAKER
		mov	ah,048h		;DOS allocate memory block
		int	021h
		_JC	InstallMemErr

		mov	Driver1Seg,ax

;* load speaker driver

		push	es
		mov	cx,FSIZE_SPEAKER
		mov	dx,OFFSET SpeakerBin
		mov	es,ax
		xor	di,di
		call	LoadFile
		pop	es
		_JC	InstallFileErr

;* set speaker driver interrupt vector (080h)

		push	ds
		mov	al,080h
		mov	ds,Driver1Seg
		xor	dx,dx
		mov	ah,025h		;DOS set interrupt vector
		int	021h
		pop	ds

		mov	Installed,1

		clc			;cf = 0 = ok
		ret

;---------------------------
InstallBlst	LABEL	NEAR
;---------------------------

;* allocate memory for SoundBlaster driver

		mov	bx,PSIZE_SBLASTER
		mov	ah,048h		;DOS allocate memory block
		int	021h
		_JC	InstallMemErr

		mov	Driver2Seg,ax

;* load SoundBlaster driver

		push	es
		mov	cx,FSIZE_SBLASTER
		mov	dx,OFFSET SBlasterBin
		mov	es,ax
		xor	di,di
		call	LoadFile
		pop	es
		_JC	InstallFileErr

;* set SoundBlaster driver interrupt vector (081h)

		push	ds
		mov	al,081h
		mov	ds,Driver2Seg
		xor	dx,dx
		mov	ah,025h		;DOS set interrupt vector
		int	021h
		pop	ds

;* init SoundBlaster (check card is present)

		SOUND2	BLST_INIT

		cmp	al,055h		;card present?
		_JE	InstallCardErr	;no ->

;* >>>>> fall into AdLib code <<<<<

;---------------------------
InstallAdLb	LABEL	NEAR
;---------------------------

;* allocate memory for AdLib driver

		mov	bx,PSIZE_ADLIB
		mov	ah,048h		;DOS allocate memory block
		int	021h
		_JC	InstallMemErr

		mov	Driver1Seg,ax

;* load AdLib driver

		push	es
		mov	cx,FSIZE_ADLIB
		mov	dx,OFFSET AdLibBin
		mov	es,ax
		xor	di,di
		call	LoadFile
		pop	es
		_JC	InstallFileErr

;* set AdLib driver interrupt vector (080h)

		push	ds
		mov	al,080h
		mov	ds,Driver1Seg
		xor	dx,dx
		mov	ah,025h		;DOS set interrupt vector
		int	021h
		pop	ds

;* init AdLib (check card is present)

		SOUND1	ADLB_INIT

		cmp	al,055h		;card present?
		_JE	InstallCardErr	;no ->

		mov	Installed,1

		clc			;cf = 0 = ok
		ret

;---------------------------
InstallRlnd	LABEL	NEAR
;---------------------------

;* allocate memory for Roland driver

		mov	bx,PSIZE_ROLAND
		mov	ah,048h		;DOS allocate memory block
		int	021h
		_JC	InstallMemErr

		mov	Driver1Seg,ax

;* load Roland driver

		push	es
		mov	cx,FSIZE_ROLAND
		mov	dx,OFFSET RolandBin
		mov	es,ax
		xor	di,di
		call	LoadFile
		pop	es
		_JC	InstallFileErr

;* set Roland driver interrupt vector (080h)

		push	ds
		mov	al,080h
		mov	ds,Driver1Seg
		xor	dx,dx
		mov	ah,025h		;DOS set interrupt vector
		int	021h
		pop	ds

;* init Roland (check card is present)

		SOUND1	RLND_INIT

		cmp	al,055h		;card present?
		_JE	InstallCardErr	;no ->

		mov	Installed,1

		clc			;cf = 0 = ok
		ret

;---------------------------
InstallMemErr	LABEL	NEAR
;---------------------------

		mov	DieFlag,SYS_ERR_SMEM

		stc			;cf = 1 = error
		ret

;---------------------------
InstallFileErr	LABEL	NEAR
;---------------------------

		mov	DieFlag,SYS_ERR_SDRVR

		stc			;cf = 1 = error
		ret

;---------------------------
InstallCardErr	LABEL	NEAR
;---------------------------

		mov	DieFlag,SYS_ERR_SCARD

		stc			;cf = 1 = error
		ret

InstallSound	ENDP

;----------------------------------------------------------------------------

;* NormaliseSound - turn off sound (restore system)
;*
;* pass: SoundCard
;* ret : nothing
;* kill: assume all

NormaliseSound	PROC	FAR

;* only normalise if installed and not already normalised

		test	Installed,1	;installed?
		jz	@F		;no ->

		test	Normalised,1	;already normalised?
		jnz	@F		;yes ->

		mov	Normalised,1

		mov	bx,SoundCard
		jmp	_NormaliseSound[bx]

@@:		ret

;---------------------------
NormalNull	LABEL	NEAR
;---------------------------

		ret

;---------------------------
NormalSpkr	LABEL	NEAR
;---------------------------

		SOUND1	SPKR_NORM

		cli
		SOUND1	SPKR_REFRESH	;refresh required to assert normalise
		sti

		ret

;---------------------------
NormalBlst	LABEL	NEAR
;---------------------------

		SOUND2	BLST_NORM

		SOUND1	ADLB_NORM

		ret

;---------------------------
NormalAdLb	LABEL	NEAR
;---------------------------

;* check if changed to AdLib after SoundBlaster fault

		test	BlstFault,1	;SoundBlaster fault?
		jnz	NormalBlst	;yes, normalise SoundBlaster ->

		SOUND1	ADLB_NORM

		ret

;---------------------------
NormalRlnd	LABEL	NEAR
;---------------------------

		SOUND1	RLND_NORM

		ret

NormaliseSound	ENDP

;----------------------------------------------------------------------------

;* SuspendSound - suspend sound effects
;*
;* pass: SoundCard
;* ret : nothing
;* kill: assume all

SuspendSound	PROC	FAR

;* clear vars

		xor	ax,ax

		mov	SoundOn,al
		mov	EngSoundOn,al

;* turn off effects

		mov	bx,SoundCard
		jmp	_SuspendSound[bx]

;---------------------------
SuspendNull	LABEL	NEAR
;---------------------------

		ret

;---------------------------
SuspendSpkr	LABEL	NEAR
;---------------------------

		CLRCH1	SPKR_FXOFF1

		ret

;---------------------------
SuspendBlst	LABEL	NEAR
;---------------------------

		CLRCH3	BLST_FXOFF1

;* >>>>> fall into AdLib code <<<<<

;---------------------------
SuspendAdLb	LABEL	NEAR
;---------------------------

		CLRCH1	ADLB_FXOFF1
		CLRCH2	ADLB_FXOFF2

		ret

;---------------------------
SuspendRlnd	LABEL	NEAR
;---------------------------

		CLRCH1	RLND_FXOFF1
		CLRCH2	RLND_FXOFF2

		ret

SuspendSound	ENDP

;----------------------------------------------------------------------------

;* ResumeSound - resume sound effects
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

ResumeSound	PROC	FAR

		cmp	SoundOption,SOUND_OPT_OFF	;sound effects off?
		je	@F				;yes, do not resume ->

		mov	SoundOn,1

		mov	EngSoundOn,0	;retrigger engine sound

@@:		ret

ResumeSound	ENDP

;----------------------------------------------------------------------------

;* RefreshSound - refresh sound effects (under interrupt)
;*
;* pass: SoundCard
;* ret : nothing
;* kill: assume all
;*
;* note: Call from 50Hz interrupt.

RefreshSound	PROC	FAR

;------------------
;* update channel 1
;------------------

		cmp	Ch1Priority,0	;channel 1 in use?
		je	SkipCh1		;no ->

		mov	ax,Ch1Timer
		cmp	ax,-1		;continuous?
		je	SkipCh1		;yes ->
		sub	ax,1		;time up?
		jnc	@F		;no ->
		xor	ax,ax
		mov	Ch1Priority,al
@@:		mov	Ch1Timer,ax

;------------------
;* update channel 2
;------------------

SkipCh1:	cmp	Ch2Priority,0	;channel 2 in use?
		je	SkipCh2		;no ->

		mov	ax,Ch2Timer
		cmp	ax,-1		;continuous?
		je	SkipCh2		;yes ->
		sub	ax,1		;time up?
		jnc	@F		;no ->
		xor	ax,ax
		mov	Ch2Priority,al
@@:		mov	Ch2Timer,ax

;------------------
;* update channel 3
;------------------

SkipCh2:	cmp	Ch3Priority,0	;channel 3 in use?
		je	SkipCh3		;no ->

		mov	ax,Ch3Timer
		cmp	ax,-1		;continuous?
		je	SkipCh3		;yes ->
		sub	ax,1		;time up?
		jnc	@F		;no ->
		xor	ax,ax
		mov	Ch3Priority,al
@@:		mov	Ch3Timer,ax

;---------
;* refresh
;---------

SkipCh3:	mov	bx,SoundCard
		jmp	_RefreshSound[bx]

;---------------------------
RefreshNull	LABEL	NEAR
;---------------------------

		ret

;---------------------------
RefreshSpkr	LABEL	NEAR
;---------------------------

		SOUND1	SPKR_REFRESH

		ret

;---------------------------
RefreshBlst	LABEL	NEAR
RefreshAdLb	LABEL	NEAR
;---------------------------

		SOUND1	ADLB_REFRESH

		ret

;---------------------------
RefreshRlnd	LABEL	NEAR
;---------------------------

		SOUND1	RLND_REFRESH

		ret

RefreshSound	ENDP

;----------------------------------------------------------------------------

;* UpdateSound
;*
;* pass: SoundCard
;* ret : nothing
;* kill: assume all

UpdateSound	PROC	FAR

		test	SoundOn,1	;sound enabled?
		jz	@F		;no ->
		
		mov	bx,SoundCard
		jmp	_UpdateSound[bx]

@@:		ret

;---------------------------
UpdateNull	LABEL	NEAR
;---------------------------

		ret

;---------------------------
UpdateSpkr	LABEL	NEAR
;---------------------------

;* >>>>> looping sounds timeout <<<<<

		cmp	Ch1Priority,0		;sound channel free?
		jne	@F			;no ->

		test	Ch1Flags,SFLG_LOOP	;looping sound?
		jz	@F			;no ->

		CLRCH1	SPKR_FXOFF1

;* >>>>> lock on growl sound <<<<<

@@:		cmp	Ch1Priority,SPKR_PR_GROWL	;override?
		ja	SkipGrowlSpkr			;no ->

;* check air radar lock

		cmp	AirTgtPtr,-1
		je	GrowlOffSpkr

;* Sidewinders must have IR lock

		cmp	ArmMode,ARM_SIDEWINDER
		jne	@F

		test	IRLockFlag,1
		jz	GrowlOffSpkr

;* growl on, start growl if not if growling already

@@:		cmp	Ch1Priority,SPKR_PR_GROWL
		je	SkipGrowlSpkr

		mov	EngSoundOn,0

		SETCH1	SPKR_FXON1,		\
			SPKR_FX_GROWL,		\
			SPKR_PR_GROWL,		\
			SPKR_FL_GROWL,		\
			SPKR_TM_GROWL

		jmp	SkipGrowlSpkr

;* growl off, stop growl if growling

GrowlOffSpkr:	cmp	Ch1Priority,SPKR_PR_GROWL
		jne	SkipGrowlSpkr

		CLRCH1	SPKR_FXOFF1

;* >>>>> rumble sound <<<<<

SkipGrowlSpkr:	cmp	Ch1Priority,SPKR_PR_RUMBLE	;override?
		ja	SkipRumbleSpkr			;no ->

		mov	al,ShakePriority

		mov	ah,1			;assume rumble

		cmp	al,SHAKE_BRAKE		;brake?
		je	@F			;yes ->
		cmp	al,SHAKE_BUFFET		;buffet?
		je	@F			;yes ->
		cmp	al,SHAKE_OFF_HARD	;off hard?
		je	@F			;yes ->
		cmp	al,SHAKE_WHEELS_UP	;wheels up?
		je	@F			;yes ->

		xor	ah,ah			;no rumble

@@:		cmp	Ch1Priority,SPKR_PR_RUMBLE	;rumbling already?
		je	ContRumbleSpkr			;yes ->

		test	ah,ah		;start rumble?
		jz	SkipRumbleSpkr	;no ->

		mov	EngSoundOn,0

		SETCH1	SPKR_FXON1,		\	;start rumble
			SPKR_FX_RUMBLE,		\
			SPKR_PR_RUMBLE,		\
			SPKR_FL_RUMBLE,		\
			SPKR_TM_RUMBLE

		jmp	SkipRumbleSpkr

ContRumbleSpkr:	test	ah,ah		;rumble still valid?
		jnz	SkipRumbleSpkr	;yes ->

		CLRCH1	SPKR_FXOFF1	;stop rumble

;* >>>>> engine sound <<<<<

SkipRumbleSpkr:	cmp	SoundOption,SOUND_OPT_ENG	;engine sound option?
		jne	EngOffSpkr			;no ->

		cmp	Ch1Priority,0	;channel 1 in use?
		jne	EngOffSpkr	;yes ->

		mov	ax,Rpm1
		or	ax,Rpm2		;any rpm?
		jz	EngOffSpkr	;no (engines damaged, no fuel etc.) ->

;* calc "revs" value

;* Rpm1 (0 .. 100 * 256 (idle = 63%))
;* Rpm2 (0 .. 100 * 256 (idle = 63%))
;* Reheat (0 .. 128)

;* revs = max(Rpm1, Rpm2)

		mov	ax,Rpm1
		mov	dx,Rpm2
		cmp	ax,dx
		jae	@F
		mov	ax,dx

;* revs = 74 - max(revs - idle, 0) / 128 + 48 = 122 .. 48

@@:		sub	ax,63*256
		MINM	ax

		mov	cl,7
		shr	ax,cl		;0 .. 74

		mov	ah,74
		sub	ah,al		;74 .. 0
		add	ah,48		;122 .. 48

		mov	Tmp1,ah
	
;* sort engine sound

		test	EngSoundOn,1	;engine sound on?
		jnz	EngAdjustSpkr	;yes ->

;* start engine sound

		mov	al,SPKR_FX_INT_ENG	;assume internal engine
	
		test	QuieterCockpit,1		;in cockpit?
		jnz	@F			;yes ->

		mov	al,SPKR_FX_EXT_ENG	;external engine

@@:		SOUND1	SPKR_FXON1

		mov	EngSoundOn,1

;* adjust engine revs

EngAdjustSpkr:	mov	al,Tmp1

		SOUND1	SPKR_REVS1

		jmp	EngOkSpkr

;* turn engine sound off (if not already)

EngOffSpkr:	test	EngSoundOn,1	;engine sound already off?
		jz	EngOkSpkr	;yes ->

		CLRCH1	SPKR_FXOFF1

		mov	EngSoundOn,0

EngOkSpkr:	ret

;---------------------------
UpdateBlst	LABEL	NEAR
;---------------------------

;* >>>>> check DSP status <<<<<

		SOUND2	BLST_FAULT

		test	al,al			;fault?
		jz	@F			;no ->

		mov	BlstFault,1		;flag fault condition

		mov	EngSoundOn,0		;retrigger engine sound

		mov	SoundCard,SND_ADLIB	;switch to AdLib

		jmp	UpdateAdLb

@@:

;* >>>>> engine sound <<<<<

		cmp	SoundOption,SOUND_OPT_ENG	;engine sound option?
		jne	EngOffBlst			;no ->

		cmp	Ch3Priority,0	;channel 3 in use?
		jne	EngOffBlst	;yes ->

		mov	ax,Rpm1
		or	ax,Rpm2		;any rpm?
		jz	EngOffBlst	;no (engines damaged, no fuel etc.) ->

;* calc "revs" value

;* Rpm1 (0 .. 100 * 256 (idle = 63%))
;* Rpm2 (0 .. 100 * 256 (idle = 63%))
;* Reheat (0 .. 128)

;* revs = max(Rpm1, Rpm2)

		mov	ax,Rpm1
		mov	dx,Rpm2
		cmp	ax,dx
		jae	@F
		mov	ax,dx

;* if revs >= idle then
;*    revs = (revs - idle) / 128 + 40 + Reheat / 8 = 40 .. 130
;* else
;*    revs = revs / 512 + 8 = 8 .. 39
;* endif

@@:		cmp	ax,63*256	;revs < idle?
		jb	@F		;yes ->

		sub	ax,63*256

		mov	cl,7		
		shr	ax,cl		;0 .. 74
		add	al,40		;40 .. 114

		mov	dl,al

		mov	ax,Reheat
		mov	cl,3
		shr	ax,cl		;0 .. 16

		add	dl,al		;16 .. 130

		jmp	EngContBlst

;* spool down

@@:		mov	cl,9
		shr	dx,cl		;0 .. 31
		add	dl,8		;8 .. 39
     
;* sort engine sound

EngContBlst:	test	EngSoundOn,1	;engine sound on?
		jz	@F		;no ->

;* adjust engine revs

		SOUND2	BLST_REVS1

		jmp	EngOkBlst

;* start engine sound

@@:		mov	al,BLST_FX_INT_ENG	;assume internal engine

		test	QuieterCockpit,1		;in cockpit?
		jnz	@F			;yes ->

		mov	al,BLST_FX_EXT_ENG	;external engine

@@:		SOUND2	BLST_FXON1

		mov	EngSoundOn,1

		jmp	EngOkBlst

;* turn engine sound off (if not already)

EngOffBlst:	test	EngSoundOn,1	;engine sound already off?
		jz	EngOkBlst	;yes ->

		CLRCH3	BLST_FXOFF1

		mov	EngSoundOn,0

;* >>>>> jump into AdLib code <<<<<

EngOkBlst:	jmp	IntoUpdateAdLb

;---------------------------
UpdateAdLb	LABEL	NEAR
;---------------------------

;* >>>>> engine sound <<<<<

		cmp	SoundOption,SOUND_OPT_ENG	;engine sound option?
		jne	EngOffAdLb			;no ->

		mov	ax,Rpm1
		or	ax,Rpm2		;any rpm?
		jz	EngOffAdLb	;no (engines damaged, no fuel etc.) ->

;* calc "revs" value

;* Rpm1 (0 .. 100 * 256 (idle = 63%))
;* Rpm2 (0 .. 100 * 256 (idle = 63%))
;* Reheat (0 .. 128)

;* revs = max(Rpm1, Rpm2)

		mov	ax,Rpm1
		mov	dx,Rpm2
		cmp	ax,dx
		jae	@F
		mov	ax,dx

@@:		mov	bp,ax		;store revs

;* revs = max(revs - idle, 0) / 47 + Reheat / 4 = 0 .. 233

		sub	ax,63*256	
		MINM	ax

		xor	dx,dx
		mov	bx,47
		div	bx		;0 .. 201

		mov	dx,Reheat
		mov	cl,2
		shr	dx,cl		;0 .. 32

		add	al,dl		;0 .. 233

		mov	Tmp1,al

;* vol = revs / 2048 + 32 + Reheat / 32 = 12 .. 54

		mov	ax,bp		;restore revs
		mov	cl,11
		shr	ax,cl		;0 .. 12

		add	al,32		;12 .. 44

		mov	dx,Reheat
		mov	cl,5
		shr	dx,cl		;0 .. 4

		add	al,dl		;12 .. 48

		mov	Tmp2,al

;* sort engine sound

		test	EngSoundOn,1	;engine sound on?
		jnz	EngAdjustAdLb	;yes ->

;* start engine sound

		mov	al,ADLB_FX_INT_ENG	;assume internal engine

		test	QuieterCockpit,1		;in cockpit?
		jnz	@F			;yes ->

		mov	al,ADLB_FX_EXT_ENG	;external engine

@@:		SOUND1	ADLB_FXON1

		mov	EngSoundOn,1

;* adjust engine revs

EngAdjustAdLb:	mov	al,Tmp1

		SOUND1	ADLB_REVS1

		mov	al,Tmp2

		SOUND1	ADLB_VOL1

		jmp	IntoUpdateAdLb

;* turn engine sound off (if not already)

EngOffAdLb:	test	EngSoundOn,1	;engine sound already off?
		jz	IntoUpdateAdLb	;yes ->
zxcv:
		CLRCH1	ADLB_FXOFF1

		mov	EngSoundOn,0

;* >>>>> looping sounds timeout <<<<<

IntoUpdateAdLb:	cmp	Ch2Priority,0		;sound channel free?
		jne	@F			;no ->

		test	Ch2Flags,SFLG_LOOP	;looping sound?
		jz	@F			;no ->

		CLRCH2	ADLB_FXOFF2

;* >>>>> lock on growl sound <<<<<

@@:		cmp	Ch2Priority,ADLB_PR_GROWL	;override?
		ja	SkipGrowlAdLb			;no ->

;* check air radar lock

		cmp	AirTgtPtr,-1
		je	GrowlOffAdLb

;* Sidewinders must have IR lock

		cmp	ArmMode,ARM_SIDEWINDER
		jne	@F

		test	IRLockFlag,1
		jz	GrowlOffAdLb

;* growl on, start growl if not if growling already

@@:		cmp	Ch2Priority,ADLB_PR_GROWL
		je	SkipGrowlAdLb

		SETCH2	ADLB_FXON2,		\
			ADLB_FX_GROWL,		\
			ADLB_PR_GROWL,		\
			ADLB_FL_GROWL,		\
			ADLB_TM_GROWL

		jmp	SkipGrowlAdLb

;* growl off, stop growl if growling

GrowlOffAdLb:	cmp	Ch2Priority,ADLB_PR_GROWL
		jne	SkipGrowlAdLb

		CLRCH2	ADLB_FXOFF2

;* >>>>> rumble sound <<<<<

SkipGrowlAdLb:	cmp	Ch2Priority,ADLB_PR_RUMBLE	;override?
		ja	SkipRumbleAdLb			;no ->

		mov	al,ShakePriority

		mov	ah,1			;assume rumble

		cmp	al,SHAKE_BRAKE		;brake?
		je	@F			;yes ->
		cmp	al,SHAKE_BUFFET		;buffet?
		je	@F			;yes ->
		cmp	al,SHAKE_OFF_HARD	;off hard?
		je	@F			;yes ->
		cmp	al,SHAKE_WHEELS_UP	;wheels up?
		je	@F			;yes ->

		xor	ah,ah			;no rumble

@@:		cmp	Ch2Priority,ADLB_PR_RUMBLE	;rumbling already?
		je	ContRumbleAdLb			;yes ->

		test	ah,ah		;start rumble?
		jz	SkipRumbleAdLb	;no ->

		SETCH2	ADLB_FXON2,		\	;start rumble
			ADLB_FX_RUMBLE,		\
			ADLB_PR_RUMBLE,		\
			ADLB_FL_RUMBLE,		\
			ADLB_TM_RUMBLE

		jmp	SkipRumbleAdLb

ContRumbleAdLb:	test	ah,ah		;rumble still valid?
		jnz	SkipRumbleAdLb	;yes ->

		CLRCH2	ADLB_FXOFF2	;stop rumble

SkipRumbleAdLb:	ret

;---------------------------
UpdateRlnd	LABEL	NEAR
;---------------------------

;* >>>>> looping sounds timeout <<<<<

		cmp	Ch2Priority,0		;sound channel free?
		jne	@F			;no ->

		test	Ch2Flags,SFLG_LOOP	;looping sound?
		jz	@F			;no ->

		CLRCH2	RLND_FXOFF2

;* >>>>> lock on growl sound <<<<<

@@:		cmp	Ch2Priority,RLND_PR_GROWL	;override?
		ja	SkipGrowlRlnd			;no ->

;* check air radar lock

		cmp	AirTgtPtr,-1
		je	GrowlOffRlnd

;* Sidewinders must have IR lock

		cmp	ArmMode,ARM_SIDEWINDER
		jne	@F

		test	IRLockFlag,1
		jz	GrowlOffRlnd

;* growl on, start growl if not if growling already

@@:		cmp	Ch2Priority,RLND_PR_GROWL
		je	SkipGrowlRlnd

		SETCH2	RLND_FXON2,		\
			RLND_FX_GROWL,		\
			RLND_PR_GROWL,		\
			RLND_FL_GROWL,		\
			RLND_TM_GROWL

		jmp	SkipGrowlRlnd

;* growl off, stop growl if growling

GrowlOffRlnd:	cmp	Ch2Priority,RLND_PR_GROWL
		jne	SkipGrowlRlnd

		CLRCH2	RLND_FXOFF2

;* >>>>> rumble sound <<<<<

SkipGrowlRlnd:	cmp	Ch2Priority,RLND_PR_RUMBLE	;override?
		ja	SkipRumbleRlnd			;no ->

		mov	al,ShakePriority

		mov	ah,1			;assume rumble

		cmp	al,SHAKE_BRAKE		;brake?
		je	@F			;yes ->
		cmp	al,SHAKE_BUFFET		;buffet?
		je	@F			;yes ->
		cmp	al,SHAKE_OFF_HARD	;off hard?
		je	@F			;yes ->
		cmp	al,SHAKE_WHEELS_UP	;wheels up?
		je	@F			;yes ->

		xor	ah,ah			;no rumble

@@:		cmp	Ch2Priority,RLND_PR_RUMBLE	;rumbling already?
		je	ContRumbleRlnd			;yes ->

		test	ah,ah		;start rumble?
		jz	SkipRumbleRlnd	;no ->

		SETCH2	RLND_FXON2,		\	;start rumble
			RLND_FX_RUMBLE,		\
			RLND_PR_RUMBLE,		\
			RLND_FL_RUMBLE,		\
			RLND_TM_RUMBLE

		jmp	SkipRumbleRlnd

ContRumbleRlnd:	test	ah,ah		;rumble still valid?
		jnz	SkipRumbleRlnd	;yes ->

		CLRCH2	RLND_FXOFF2	;stop rumble

;* >>>>> engine sound <<<<<

SkipRumbleRlnd:	cmp	SoundOption,SOUND_OPT_ENG	;engine sound option?
		jne	EngOffRlnd			;no ->

		mov	ax,Rpm1
		or	ax,Rpm2		;any rpm?
		jz	EngOffRlnd	;no (engines damaged, no fuel etc.) ->

;* calc "revs" value

;* Rpm1 (0 .. 100 * 256 (idle = 63%))
;* Rpm2 (0 .. 100 * 256 (idle = 63%))
;* Reheat (0 .. 128)

;* revs = max(Rpm1, Rpm2)

		mov	ax,Rpm1
		mov	dx,Rpm2
		cmp	ax,dx
		jae	@F
		mov	ax,dx

;* revs = max(revs - idle, 0) / 128 + 26 = 26 .. 100

@@: 		mov	bp,ax		;store revs

		sub	ax,63*256	
		MINM	ax
		mov	cl,7
		shr	ax,cl		;0 .. 74

		add	al,26		;26 .. 100
		
		mov	Tmp1,al

;* vol = revs / 256 + 8 + Reheat / 16 = 8 .. 116

		mov	ax,bp		;restore revs

		mov	al,ah		;0 .. 100
		add	al,8		;8 .. 108

		mov	dx,Reheat
		mov	cl,4
		shr	dx,cl		;0 .. 8

		add	al,dl		;8 .. 116

		mov	Tmp2,al
		
;* sort engine sound

		test	EngSoundOn,1	;engine sound on?
		jnz	EngAdjustRlnd	;yes ->

;* start engine sound

		mov	al,RLND_FX_INT_ENG	;assume internal engine

		test	QuieterCockpit,1		;in cockpit?
		jnz	@F			;yes ->

		mov	al,RLND_FX_EXT_ENG	;external engine

@@:		SOUND1	RLND_FXON1

		mov	EngSoundOn,1

;* adjust engine revs

EngAdjustRlnd:	mov	al,Tmp1

		SOUND1	RLND_REVS1

		mov	al,Tmp2

		SOUND1	RLND_VOL1
		
		jmp	EngOkRlnd

;* turn engine sound off (if not already)

EngOffRlnd:	test	EngSoundOn,1	;engine sound already off?
		jz	EngOkRlnd	;yes ->

		CLRCH1	RLND_FXOFF1

		mov	EngSoundOn,0

EngOkRlnd:	ret

UpdateSound	ENDP

;----------------------------------------------------------------------------

;* ExploSound1 - make explosion sound
;*
;* pass: SoundCard
;* ret : nothing
;* kill: assume all

ExploSound1	PROC	FAR

		test	SoundOn,1	;sound enabled?
		jz	@F		;no ->
		
		mov	bx,SoundCard
		jmp	_ExploSound1[bx]

@@:		ret

;---------------------------
Explo1Null	LABEL	NEAR
;---------------------------

		ret

;---------------------------
Explo1Spkr	LABEL	NEAR
;---------------------------

		cmp	Ch1Priority,SPKR_PR_EXPLO1	;override?
		ja	Explo1ExitSpkr			;no ->

;* prevent retrigger in same frame

		jne	@F		;explosion sound not playing ->

		cmp	Ch1Timer,SPKR_TM_EXPLO1-5
		ja	Explo1ExitSpkr

@@:		mov	EngSoundOn,0

		SETCH1	SPKR_FXON1,    		\
			SPKR_FX_EXPLO1,		\
			SPKR_PR_EXPLO1,		\
			SPKR_FL_EXPLO1,		\
			SPKR_TM_EXPLO1

Explo1ExitSpkr:	ret

;---------------------------
Explo1Blst	LABEL	NEAR
;---------------------------

		cmp	Ch3Priority,BLST_PR_EXPLO1	;override?
		ja	Explo1ExitBlst			;no ->

;* prevent retrigger in same frame

		jne	@F		;explosion sound not playing ->

		cmp	Ch3Timer,BLST_TM_EXPLO1-5
		ja	Explo1ExitBlst

@@:		mov	EngSoundOn,0

		SETCH3	BLST_FXON1,    		\
			BLST_FX_EXPLO1,		\
			BLST_PR_EXPLO1,		\
			BLST_FL_EXPLO1,		\
			BLST_TM_EXPLO1

Explo1ExitBlst:	ret

;---------------------------
Explo1AdLb	LABEL	NEAR
;---------------------------

		cmp	Ch2Priority,ADLB_PR_EXPLO1	;override?
		ja	Explo1ExitAdLb			;no ->

;* prevent retrigger in same frame

		jne	@F		;explosion sound not playing ->

		cmp	Ch2Timer,ADLB_TM_EXPLO1-5
		ja	Explo1ExitAdLb

@@:		SETCH2	ADLB_FXON2,    		\
			ADLB_FX_EXPLO1,		\
			ADLB_PR_EXPLO1,		\
			ADLB_FL_EXPLO1,		\
			ADLB_TM_EXPLO1

Explo1ExitAdLb:	ret

;---------------------------
Explo1Rlnd	LABEL	NEAR
;---------------------------

		cmp	Ch2Priority,RLND_PR_EXPLO1	;override?
		ja	Explo1ExitRlnd			;no ->

;* prevent retrigger in same frame

		jne	@F		;explosion sound not playing ->

		cmp	Ch2Timer,RLND_TM_EXPLO1-5
		ja	Explo1ExitRlnd

@@:		SETCH2	RLND_FXON2,    		\
			RLND_FX_EXPLO1,		\
			RLND_PR_EXPLO1,		\
			RLND_FL_EXPLO1,		\
			RLND_TM_EXPLO1

Explo1ExitRlnd:	ret

ExploSound1	ENDP

;----------------------------------------------------------------------------

;* ExploSound2 - make explosion sound
;*
;* pass: SoundCard
;* ret : nothing
;* kill: assume all

ExploSound2	PROC	FAR

		test	SoundOn,1	;sound enabled?
		jz	@F		;no ->
		
		mov	bx,SoundCard
		jmp	_ExploSound2[bx]

@@:		ret

;---------------------------
Explo2Null	LABEL	NEAR
;---------------------------

		ret

;---------------------------
Explo2Spkr	LABEL	NEAR
;---------------------------

		cmp	Ch1Priority,SPKR_PR_EXPLO2	;override?
		ja	Explo2ExitSpkr			;no ->

;* prevent retrigger in same frame

		jne	@F		;explosion sound not playing ->

		cmp	Ch1Timer,SPKR_TM_EXPLO2-5
		ja	Explo2ExitSpkr

@@:		mov	EngSoundOn,0

		SETCH1	SPKR_FXON1,    		\
			SPKR_FX_EXPLO2,		\
			SPKR_PR_EXPLO2,		\
			SPKR_FL_EXPLO2,		\
			SPKR_TM_EXPLO2

Explo2ExitSpkr:	ret

;---------------------------
Explo2Blst	LABEL	NEAR
;---------------------------

		cmp	Ch3Priority,BLST_PR_EXPLO2	;override?
		ja	Explo2ExitBlst			;no ->

;* prevent retrigger in same frame

		jne	@F		;explosion sound not playing ->

		cmp	Ch3Timer,BLST_TM_EXPLO2-5
		ja	Explo2ExitBlst

@@:		mov	EngSoundOn,0

		SETCH3	BLST_FXON1,		\
			BLST_FX_EXPLO2,		\
			BLST_PR_EXPLO2,		\
			BLST_FL_EXPLO2,		\
			BLST_TM_EXPLO2

Explo2ExitBlst:	ret

;---------------------------
Explo2AdLb	LABEL	NEAR
;---------------------------

		cmp	Ch2Priority,ADLB_PR_EXPLO2	;override?
		ja	Explo2ExitAdLb			;no ->

;* prevent retrigger in same frame

		jne	@F		;explosion sound not playing ->

		cmp	Ch2Timer,ADLB_TM_EXPLO2-5
		ja	Explo2ExitAdLb

@@:		SETCH2	ADLB_FXON2,    		\
			ADLB_FX_EXPLO2,		\
			ADLB_PR_EXPLO2,		\
			ADLB_FL_EXPLO2,		\
			ADLB_TM_EXPLO2

Explo2ExitAdLb:	ret

;---------------------------
Explo2Rlnd	LABEL	NEAR
;---------------------------

		cmp	Ch2Priority,RLND_PR_EXPLO2	;override?
		ja	Explo2ExitRlnd			;no ->

;* prevent retrigger in same frame

		jne	@F		;explosion sound not playing ->

		cmp	Ch2Timer,RLND_TM_EXPLO2-5
		ja	Explo2ExitRlnd

@@:		SETCH2	RLND_FXON2,    		\
			RLND_FX_EXPLO2,		\
			RLND_PR_EXPLO2,		\
			RLND_FL_EXPLO2,		\
			RLND_TM_EXPLO2

Explo2ExitRlnd:	ret

ExploSound2	ENDP

;----------------------------------------------------------------------------

;* ExploSound3 - make explosion sound
;*
;* pass: SoundCard
;* ret : nothing
;* kill: assume all

ExploSound3	PROC	FAR

		test	SoundOn,1	;sound enabled?
		jz	@F		;no ->
		
		mov	bx,SoundCard
		jmp	_ExploSound3[bx]

@@:		ret

;---------------------------
Explo3Null	LABEL	NEAR
;---------------------------

		ret

;---------------------------
Explo3Spkr	LABEL	NEAR
;---------------------------

		cmp	Ch1Priority,SPKR_PR_EXPLO3	;override?
		ja	Explo3ExitSpkr			;no ->

;* prevent retrigger in same frame

		jne	@F		;explosion sound not playing ->

		cmp	Ch1Timer,SPKR_TM_EXPLO3-5
		ja	Explo3ExitSpkr

@@:		mov	EngSoundOn,0

		SETCH1	SPKR_FXON1,    		\
			SPKR_FX_EXPLO3,		\
			SPKR_PR_EXPLO3,		\
			SPKR_FL_EXPLO3,		\
			SPKR_TM_EXPLO3

Explo3ExitSpkr:	ret

;---------------------------
Explo3Blst	LABEL	NEAR
;---------------------------

		cmp	Ch3Priority,BLST_PR_EXPLO3	;override?
		ja	Explo3ExitBlst			;no ->

;* prevent retrigger in same frame

		jne	@F		;explosion sound not playing ->

		cmp	Ch3Timer,BLST_TM_EXPLO3-5
		ja	Explo3ExitBlst

@@:		mov	EngSoundOn,0

		SETCH3	BLST_FXON1,		\
			BLST_FX_EXPLO3,		\
			BLST_PR_EXPLO3,		\
			BLST_FL_EXPLO3,		\
			BLST_TM_EXPLO3

Explo3ExitBlst:	ret

;---------------------------
Explo3AdLb	LABEL	NEAR
;---------------------------

		cmp	Ch2Priority,ADLB_PR_EXPLO3	;override?
		ja	Explo3ExitAdLb			;no ->

;* prevent retrigger in same frame

		jne	@F		;explosion sound not playing ->

		cmp	Ch2Timer,ADLB_TM_EXPLO3-5
		ja	Explo3ExitAdLb

@@:		SETCH2	ADLB_FXON2,    		\
			ADLB_FX_EXPLO3,		\
			ADLB_PR_EXPLO3,		\
			ADLB_FL_EXPLO3,		\
			ADLB_TM_EXPLO3

Explo3ExitAdLb:	ret

;---------------------------
Explo3Rlnd	LABEL	NEAR
;---------------------------

		cmp	Ch2Priority,RLND_PR_EXPLO3	;override?
		ja	Explo3ExitRlnd			;no ->

;* prevent retrigger in same frame

		jne	@F		;explosion sound not playing ->

		cmp	Ch2Timer,RLND_TM_EXPLO3-5
		ja	Explo3ExitRlnd

@@:		SETCH2	RLND_FXON2,    		\
			RLND_FX_EXPLO3,		\
			RLND_PR_EXPLO3,		\
			RLND_FL_EXPLO3,		\
			RLND_TM_EXPLO3

Explo3ExitRlnd:	ret

ExploSound3	ENDP

;----------------------------------------------------------------------------

;* ScreechSound - make wheel screech sound
;*
;* pass: SoundCard
;* ret : nothing
;* kill: assume all

ScreechSound	PROC	FAR

		test	SoundOn,1	;sound enabled?
		jz	@F		;no ->
		
		mov	bx,SoundCard
		jmp	_ScreechSound[bx]

@@:		ret

;---------------------------
ScreechNull	LABEL	NEAR
;---------------------------

		ret

;---------------------------
ScreechSpkr	LABEL	NEAR
;---------------------------

		cmp	Ch1Priority,SPKR_PR_SCREECH	;override?
		ja	@F				;no ->

		mov	EngSoundOn,0

		SETCH1	SPKR_FXON1,		\
			SPKR_FX_SCREECH,	\
			SPKR_PR_SCREECH,	\
			SPKR_FL_SCREECH,	\
			SPKR_TM_SCREECH

@@:		ret

;---------------------------
ScreechBlst	LABEL	NEAR
;---------------------------

		cmp	Ch3Priority,BLST_PR_SCREECH	;override?
		ja	@F				;no ->

		mov	EngSoundOn,0

		SETCH3	BLST_FXON1,		\
			BLST_FX_SCREECH,	\
			BLST_PR_SCREECH,	\
			BLST_FL_SCREECH,	\
			BLST_TM_SCREECH

@@:		ret

;---------------------------
ScreechAdLb	LABEL	NEAR
;---------------------------

		cmp	Ch2Priority,ADLB_PR_SCREECH	;override?
		ja	@F				;no ->

		SETCH2	ADLB_FXON2,		\
			ADLB_FX_SCREECH,	\
			ADLB_PR_SCREECH,	\
			ADLB_FL_SCREECH,	\
			ADLB_TM_SCREECH

@@:		ret

;---------------------------
ScreechRlnd	LABEL	NEAR
;---------------------------

		cmp	Ch2Priority,RLND_PR_SCREECH	;override?
		ja	@F				;no ->

		SETCH2	RLND_FXON2,		\
			RLND_FX_SCREECH,	\
			RLND_PR_SCREECH,	\
			RLND_FL_SCREECH,	\
			RLND_TM_SCREECH

@@:		ret

ScreechSound	ENDP

;----------------------------------------------------------------------------

;* MorseDotSound - make Morse dot sound
;*
;* pass: SoundCard
;* ret : nothing
;* kill: assume all

MorseDotSound	PROC	FAR

		test	SoundOn,1	;sound enabled?
		jz	@F		;no ->
		
		mov	bx,SoundCard
		jmp	_MorseDotSound[bx]

@@:		ret

;---------------------------
MorseDotNull	LABEL	NEAR
;---------------------------

		ret

;---------------------------
MorseDotSpkr	LABEL	NEAR
;---------------------------

		cmp	Ch1Priority,SPKR_PR_MDOT	;override?
		ja	@F				;no ->

		mov	EngSoundOn,0

		SETCH1	SPKR_FXON1,		\
			SPKR_FX_MDOT,		\
			SPKR_PR_MDOT,		\
			SPKR_FL_MDOT,		\
			SPKR_TM_MDOT

@@:		ret

;---------------------------
MorseDotBlst	LABEL	NEAR
MorseDotAdLb	LABEL	NEAR
;---------------------------

		cmp	Ch2Priority,ADLB_PR_MDOT	;override?
		ja	@F				;no ->

		SETCH2	ADLB_FXON2,		\
			ADLB_FX_MDOT,		\
			ADLB_PR_MDOT,		\
			ADLB_FL_MDOT,		\
			ADLB_TM_MDOT                                ;kbs

@@:		ret

;---------------------------
MorseDotRlnd	LABEL	NEAR
;---------------------------

		cmp	Ch2Priority,RLND_PR_MDOT	;override?
		ja	@F				;no ->

		SETCH2	RLND_FXON2,		\
			RLND_FX_MDOT,		\
			RLND_PR_MDOT,		\
			RLND_FL_MDOT,		\
			RLND_TM_MDOT

@@:		ret

MorseDotSound	ENDP

;----------------------------------------------------------------------------

;* MorseDashSound - make Morse dash sound
;*
;* pass: SoundCard
;* ret : nothing
;* kill: assume all

MorseDashSound	PROC	FAR

		test	SoundOn,1	;sound enabled?
		jz	@F		;no ->
		
		mov	bx,SoundCard
		jmp	_MorseDashSound[bx]

@@:		ret

;---------------------------
MorseDashNull	LABEL	NEAR
;---------------------------

		ret

;---------------------------
MorseDashSpkr	LABEL	NEAR
;---------------------------

		cmp	Ch1Priority,SPKR_PR_MDASH	;override?
		ja	@F				;no ->

		mov	EngSoundOn,0

		SETCH1	SPKR_FXON1,		\
			SPKR_FX_MDASH,		\
			SPKR_PR_MDASH,		\
			SPKR_FL_MDASH,		\
			SPKR_TM_MDASH

@@:		ret

;---------------------------
MorseDashBlst	LABEL	NEAR
MorseDashAdLb	LABEL	NEAR
;---------------------------

		cmp	Ch2Priority,ADLB_PR_MDASH	;override?
		ja	@F				;no ->

		SETCH2	ADLB_FXON2,		\
			ADLB_FX_MDASH,		\
			ADLB_PR_MDASH,		\
			ADLB_FL_MDASH,		\
			ADLB_TM_MDASH

@@:		ret

;---------------------------
MorseDashRlnd	LABEL	NEAR
;---------------------------

		cmp	Ch2Priority,RLND_PR_MDASH	;override?
		ja	@F				;no ->

		SETCH2	RLND_FXON2,		\
			RLND_FX_MDASH,		\
			RLND_PR_MDASH,		\
			RLND_FL_MDASH,		\
			RLND_TM_MDASH

@@:		ret

MorseDashSound	ENDP

;----------------------------------------------------------------------------

;* GearSound - make gear up / down sound
;*
;* pass: SoundCard
;* ret : nothing
;* kill: assume all

GearSound	PROC	FAR

		test	SoundOn,1	;sound enabled?
		jz	@F		;no ->
		
		mov	bx,SoundCard
		jmp	_GearSound[bx]

@@:		ret

;---------------------------
GearNull	LABEL	NEAR
;---------------------------

		ret

;---------------------------
GearSpkr	LABEL	NEAR
;---------------------------

		cmp	Ch1Priority,SPKR_PR_GEAR	;override?
		ja	@F				;no ->

		mov	EngSoundOn,0

		SETCH1	SPKR_FXON1,		\
			SPKR_FX_GEAR,		\
			SPKR_PR_GEAR,		\
			SPKR_FL_GEAR,		\
			SPKR_TM_GEAR

@@:		ret

;---------------------------
GearBlst	LABEL	NEAR
GearAdLb	LABEL	NEAR
;---------------------------

		cmp	Ch2Priority,ADLB_PR_GEAR	;override?
		ja	@F				;no ->

		SETCH2	ADLB_FXON2,		\
			ADLB_FX_GEAR,		\
			ADLB_PR_GEAR,		\
			ADLB_FL_GEAR,		\
			ADLB_TM_GEAR

@@:		ret

;---------------------------
GearRlnd	LABEL	NEAR
;---------------------------

		cmp	Ch2Priority,RLND_PR_GEAR	;override?
		ja	@F				;no ->

		SETCH2	RLND_FXON2,		\
			RLND_FX_GEAR,		\
			RLND_PR_GEAR,		\
			RLND_FL_GEAR,		\
			RLND_TM_GEAR

@@:		ret

GearSound	ENDP

;----------------------------------------------------------------------------

;* AttentionSound - make attention getter sound
;*
;* pass: SoundCard
;* ret : nothing
;* kill: assume all

AttentionSound	PROC	FAR

		test	SoundOn,1	;sound enabled?
		jz	@F		;no ->
		
		mov	bx,SoundCard
		jmp	_AttentionSound[bx]

@@:		ret

;---------------------------
AttentionNull	LABEL	NEAR
;---------------------------

		ret

;---------------------------
AttentionSpkr	LABEL	NEAR
;---------------------------

		cmp	Ch1Priority,SPKR_PR_ATTN	;override?
		ja	@F				;no ->

		mov	EngSoundOn,0

		SETCH1	SPKR_FXON1,		\
			SPKR_FX_ATTN,		\
			SPKR_PR_ATTN,		\
			SPKR_FL_ATTN,		\
			SPKR_TM_ATTN

@@:		ret

;---------------------------
AttentionBlst	LABEL	NEAR
AttentionAdLb	LABEL	NEAR
;---------------------------
        test CockpitViews,0
		jnz	@F
		cmp	Ch2Priority,ADLB_PR_ATTN	;override?
		ja	@F				;no ->

		SETCH2	ADLB_FXON2,		\
			ADLB_FX_ATTN,		\
			ADLB_PR_ATTN,		\
			ADLB_FL_ATTN,		\
			ADLB_TM_ATTN

@@:		ret

;---------------------------
AttentionRlnd	LABEL	NEAR
;---------------------------

		cmp	Ch2Priority,RLND_PR_ATTN	;override?
		ja	@F				;no ->

		SETCH2	RLND_FXON2,		\
			RLND_FX_ATTN,		\
			RLND_PR_ATTN,		\
			RLND_FL_ATTN,		\
			RLND_TM_ATTN

@@:		ret

AttentionSound	ENDP

;----------------------------------------------------------------------------

;* KillAttnSound - kill attention getter sound
;*
;* pass: SoundCard
;* ret : nothing
;* kill: assume all

KillAttnSound	PROC	FAR

		test	SoundOn,1	;sound enabled?
		jz	@F		;no ->
		
		mov	bx,SoundCard
		jmp	_KillAttnSound[bx]

@@:		ret

;---------------------------
KillAttnNull	LABEL	NEAR
;---------------------------

		ret

;---------------------------
KillAttnSpkr	LABEL	NEAR
;---------------------------

		cmp	Ch1Priority,SPKR_PR_ATTN	;override?
		jne	@F				;no ->

;* attention sound fails to cancel sometimes - so try more than once

		CLRCH1	ADLB_FXOFF1
		CLRCH1	ADLB_FXOFF1
		CLRCH1	ADLB_FXOFF1

@@:		ret

;---------------------------
KillAttnBlst	LABEL	NEAR
KillAttnAdLb	LABEL	NEAR
;---------------------------

		cmp	Ch2Priority,ADLB_PR_ATTN	;override?
		jne	@F				;no ->

		CLRCH2	ADLB_FXOFF2

@@:		ret

;---------------------------
KillAttnRlnd	LABEL	NEAR
;---------------------------

		cmp	Ch2Priority,RLND_PR_ATTN	;override?
		jne	@F				;no ->

		CLRCH2	RLND_FXOFF2

@@:		ret

KillAttnSound	ENDP

;----------------------------------------------------------------------------

;* CannonSound - make cannon sound
;*
;* pass: SoundCard
;* ret : nothing
;* kill: assume all

CannonSound	PROC	FAR

		test	SoundOn,1	;sound enabled?
		jz	@F		;no ->
		
		mov	bx,SoundCard
		jmp	_CannonSound[bx]

@@:		ret

;---------------------------
CannonNull	LABEL	NEAR
;---------------------------

		ret

;---------------------------
CannonSpkr	LABEL	NEAR
;---------------------------

		cmp	Ch1Priority,SPKR_PR_CANNON	;override?
		jae	@F				;no ->

		mov	EngSoundOn,0

		SETCH1	SPKR_FXON1,		\
			SPKR_FX_CANNON,		\
			SPKR_PR_CANNON,		\
			SPKR_FL_CANNON,		\
			SPKR_TM_CANNON

@@:		ret

;---------------------------
CannonBlst	LABEL	NEAR
;---------------------------

		cmp	Ch3Priority,BLST_PR_CANNON	;override?
		jae	@F				;no ->

		mov	EngSoundOn,0

		SETCH3	BLST_FXON1,		\
			BLST_FX_CANNON,		\
			BLST_PR_CANNON,		\
			BLST_FL_CANNON,		\
			BLST_TM_CANNON

@@:		ret

;---------------------------
CannonAdLb	LABEL	NEAR
;---------------------------

		cmp	Ch2Priority,ADLB_PR_CANNON	;override?
		jae	@F				;no ->

		SETCH2	ADLB_FXON2,		\
			ADLB_FX_CANNON,		\
			ADLB_PR_CANNON,		\
			ADLB_FL_CANNON,		\
			ADLB_TM_CANNON

@@:		ret

;---------------------------
CannonRlnd	LABEL	NEAR
;---------------------------

		cmp	Ch2Priority,RLND_PR_CANNON	;override?
		jae	@F				;no ->

		SETCH2	RLND_FXON2,		\
			RLND_FX_CANNON,		\
			RLND_PR_CANNON,		\
			RLND_FL_CANNON,		\
			RLND_TM_CANNON

@@:		ret

CannonSound	ENDP

;----------------------------------------------------------------------------

;* LaunchSound - make launch missile sound
;*
;* pass: SoundCard
;* ret : nothing
;* kill: assume all

LaunchSound	PROC	FAR

		test	SoundOn,1	;sound enabled?
		jz	@F		;no ->
		
		mov	bx,SoundCard
		jmp	_LaunchSound[bx]

@@:		ret

;---------------------------
LaunchNull	LABEL	NEAR
;---------------------------

		ret

;---------------------------
LaunchSpkr	LABEL	NEAR
;---------------------------

		cmp	Ch1Priority,SPKR_PR_LAUNCH	;override?
		ja	@F				;no ->

		mov	EngSoundOn,0

		SETCH1	SPKR_FXON1,		\
			SPKR_FX_LAUNCH,		\
			SPKR_PR_LAUNCH,		\
			SPKR_FL_LAUNCH,		\
			SPKR_TM_LAUNCH

@@:		ret

;---------------------------
LaunchBlst	LABEL	NEAR
LaunchAdLb	LABEL	NEAR
;---------------------------

		cmp	Ch2Priority,ADLB_PR_LAUNCH	;override?
		ja	@F				;no ->

		SETCH2	ADLB_FXON2,		\
			ADLB_FX_LAUNCH,		\
			ADLB_PR_LAUNCH,		\
			ADLB_FL_LAUNCH,		\
			ADLB_TM_LAUNCH

@@:		ret

;---------------------------
LaunchRlnd	LABEL	NEAR
;---------------------------

		cmp	Ch2Priority,RLND_PR_LAUNCH	;override?
		ja	@F				;no ->

		SETCH2	RLND_FXON2,		\
			RLND_FX_LAUNCH,		\
			RLND_PR_LAUNCH,		\
			RLND_FL_LAUNCH,		\
			RLND_TM_LAUNCH

@@:		ret

LaunchSound	ENDP

;----------------------------------------------------------------------------

;* RWRAlertSound - make RWR alert sound
;*
;* pass: SoundCard
;* ret : nothing
;* kill: assume all

RWRAlertSound	PROC	FAR

		test	SoundOn,1	;sound enabled?
		jz	@F		;no ->
		
		mov	bx,SoundCard
		jmp	_RWRAlertSound[bx]

@@:		ret

;---------------------------
RWRAlertNull	LABEL	NEAR
;---------------------------

		ret

;---------------------------
RWRAlertSpkr	LABEL	NEAR
;---------------------------

		cmp	Ch1Priority,SPKR_PR_RWR	;override?
		ja	@F		    	;no ->

		mov	EngSoundOn,0

		SETCH1	SPKR_FXON1,		\
			SPKR_FX_RWR,		\
			SPKR_PR_RWR,		\
			SPKR_FL_RWR,		\
			SPKR_TM_RWR

@@:		ret

;---------------------------
RWRAlertBlst	LABEL	NEAR
RWRAlertAdLb	LABEL	NEAR
;---------------------------

		cmp	Ch2Priority,ADLB_PR_RWR	;override?
		ja	@F		       	;no ->

		SETCH2	ADLB_FXON2,		\
			ADLB_FX_RWR,		\
			ADLB_PR_RWR,		\
			ADLB_FL_RWR,		\
			ADLB_TM_RWR

@@:		ret

;---------------------------
RWRAlertRlnd	LABEL	NEAR
;---------------------------

		cmp	Ch2Priority,RLND_PR_RWR	;override?
		ja	@F			;no ->

		SETCH2	RLND_FXON2,		\
			RLND_FX_RWR,		\
			RLND_PR_RWR,		\
			RLND_FL_RWR,		\
			RLND_TM_RWR

@@:		ret

RWRAlertSound	ENDP

;----------------------------------------------------------------------------

;* DecoySound - make chaff / flare release sound
;*
;* pass: SoundCard
;* ret : nothing
;* kill: assume all

DecoySound	PROC	FAR

		test	SoundOn,1	;sound enabled?
		jz	@F		;no ->
		
		mov	bx,SoundCard
		jmp	_DecoySound[bx]

@@:		ret

;---------------------------
DecoyNull	LABEL	NEAR
;---------------------------

		ret

;---------------------------
DecoySpkr	LABEL	NEAR
;---------------------------

		cmp	Ch1Priority,SPKR_PR_DECOY	;override?
		ja	@F				;no ->

		mov	EngSoundOn,0

		SETCH1	SPKR_FXON1,		\
			SPKR_FX_DECOY,		\
			SPKR_PR_DECOY,		\
			SPKR_FL_DECOY,		\
			SPKR_TM_DECOY

@@:		ret

;---------------------------
DecoyBlst	LABEL	NEAR
DecoyAdLb	LABEL	NEAR
;---------------------------

		cmp	Ch2Priority,ADLB_PR_DECOY	;override?
		ja	@F				;no ->

		SETCH2	ADLB_FXON2,		\
			ADLB_FX_DECOY,		\
			ADLB_PR_DECOY,		\
			ADLB_FL_DECOY,		\
			ADLB_TM_DECOY

@@:		ret

;---------------------------
DecoyRlnd	LABEL	NEAR
;---------------------------

		cmp	Ch2Priority,RLND_PR_DECOY	;override?
		ja	@F				;no ->

		SETCH2	RLND_FXON2,		\
			RLND_FX_DECOY,		\
			RLND_PR_DECOY,		\
			RLND_FL_DECOY,		\
			RLND_TM_DECOY

@@:		ret

DecoySound	ENDP

SNDCODE		ENDS

;============================================================================

		END

