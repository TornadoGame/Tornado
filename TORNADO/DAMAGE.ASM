;****************************************************************************
;*
;* DAMAGE.ASM
;*
;* Damage aircraft.
;*
;* 09.07.1992 - KJB
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	MaxDamage
		PUBLIC	MedDamage
		PUBLIC	MinDamage

		PUBLIC	DamageTimer

		EXTRN	RandX:FAR

		EXTRN	RedWarnings2:WORD
		EXTRN	AmbWarnings2:WORD
		EXTRN	LastFrame:WORD

		EXTRN	SSF_Gear:BYTE
		EXTRN	SSF_WheelBrakes:BYTE
		EXTRN	SSF_AirBrakes:BYTE
		EXTRN	SSF_Engine1:BYTE
		EXTRN	SSF_Engine2:BYTE
		EXTRN	SSF_Sweep:BYTE
		EXTRN	SSF_Flaps:BYTE
		EXTRN	SSF_ThrustRvrs:BYTE
		EXTRN	SSF_SPILS:BYTE
		EXTRN	SSF_HUD:BYTE
		EXTRN	SSF_PilotMFD:BYTE
		EXTRN	SSF_NavigMFD:BYTE
		EXTRN	SSF_TAB1:BYTE
		EXTRN	SSF_TAB2:BYTE
		EXTRN	SSF_Oxygen:BYTE
		EXTRN	SSF_Radar:BYTE
		EXTRN	SSF_ECM:BYTE
		EXTRN	SSF_RWR:BYTE
		EXTRN	SSF_ADC:BYTE
		EXTRN	EngFire1:BYTE
		EXTRN	EngFire2:BYTE
		EXTRN	ECMFitted:BYTE
		EXTRN	ECMActive:BYTE

EXTRN	ShakePriority:BYTE
EXTRN	HShake:BYTE	
EXTRN	VShake:BYTE
EXTRN	ShakeTimer:WORD
EXTRN	HSHAKE_HI:ABS
EXTRN	VSHAKE_HI:ABS
EXTRN	HSHAKE_HI:ABS
EXTRN	VSHAKE_HI:ABS
EXTRN	VSHAKE_OFF:ABS
EXTRN	HSHAKE_OFF:ABS
;============================================================================
INCLUDE	MISCMAC.INC


		INCLUDE	MAINDATA.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

DamageTimer	DW	20*100		;(arbitrary start value) (secs * 100)

DamageSwitch	DW	DamGear		;1
		DW	DamWheelBrakes	;2
		DW	DamAirBrakes	;3
		DW	DamEngine1	;4
		DW	DamEngine2	;5
		DW	DamWingSweep	;6
		DW	DamFlaps	;7
		DW	DamThrustRvrs	;8
		DW	DamSPILS	;9
		DW	DamHUD		;10
		DW	DamPilotMFD	;11
		DW	DamNavigMFD	;12
		DW	DamTAB1		;13
		DW	DamTAB2		;14
		DW	DamOxygen	;15
		DW	DamRadar	;16
		DW	DamECM		;17
		DW	DamRWR		;18
		DW	DamADC		;19
		DW	DamEngineFire	;20

DATA		ENDS

;============================================================================

GENCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:GENCODE
		ASSUME DS:DATA

;* MaxDamage
;* MedDamage
;* MinDamage - gradual damage (damage wrt time)
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

;--------------------------
MaxDamage	PROC	FAR
;--------------------------

;* calc random damage level

		call	RandX		;0.00 ..  2.55
		shl	ax,1		;0.00 ..  5.10
		add	ax,8*100	;8.00 .. 13.10

		mov	dx,ax

		jmp	IntoDamage

;--------------------------
MedDamage	LABEL	FAR
;--------------------------

;* calc random damage level

		call	RandX		;0.00 .. 2.55
		add	ax,1*100	;1.00 .. 3.55

		mov	dx,ax

		jmp	IntoDamage

;--------------------------
MinDamage	LABEL	FAR
;--------------------------

		mov	dx,LastFrame	;damage wrt time

;---------------------------
IntoDamage	LABEL	NEAR
;---------------------------

;* update timer

		mov	ax,DamageTimer
		sub	ax,dx
		jnc	@F

;* create some damage

		call	RandomDamage

;* reset damage interval

		call	RandX		; 0.00 ..  2.55 secs
		shl	ax,1		; 0.00 ..  5.10 secs
		shl	ax,1		; 0.00 .. 10.10 secs
		add	ax,10*100	;10.00 .. 20.10 secs

@@:		mov	DamageTimer,ax

		ret

MaxDamage	ENDP

;----------------------------------------------------------------------------

;* RandomDamage - damage random item
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

RandomDamage	PROC	NEAR

;------------------------------
;* select random item to damage
;------------------------------

		call	RandX

		mov	dx,20
		mul	dx		;0 .. 20 * 255
		mov	bl,ah		;0 .. 19
		xor	bh,bh
		shl	bx,1		;*2 word index

		jmp	DamageSwitch[bx]
		;jmp DamTAB1
 
;0---------------------------
DamGear		LABEL	NEAR
;---------------------------

		mov	SSF_Gear,1
		or	RedWarnings2,RED_UC
        SHAKE	SHAKE_NOSE_DOWN,HSHAKE_HI,VSHAKE_HI,65535;
		ret

;1---------------------------
DamWheelBrakes	LABEL	NEAR
;---------------------------

		mov	SSF_WheelBrakes,1
		or	AmbWarnings2,AMB_WB
        SHAKE	SHAKE_NOSE_DOWN,HSHAKE_HI,VSHAKE_HI,65535;
		ret

;2---------------------------
DamAirBrakes	LABEL	NEAR
;---------------------------

		mov	SSF_AirBrakes,1
		or	AmbWarnings2,AMB_AB
        SHAKE	SHAKE_NOSE_DOWN,HSHAKE_HI,VSHAKE_HI,65535;
		ret

;3---------------------------
DamEngine1	LABEL	NEAR
;---------------------------

		mov	SSF_Engine1,1
		or	RedWarnings2,RED_L_ENG
        SHAKE	SHAKE_NOSE_DOWN,HSHAKE_HI,VSHAKE_HI,65535;
		ret

;4---------------------------
DamEngine2	LABEL	NEAR
;---------------------------

		mov	SSF_Engine2,1
		or	RedWarnings2,RED_R_ENG
        SHAKE	SHAKE_NOSE_DOWN,HSHAKE_HI,VSHAKE_HI,65535;
		ret

;5---------------------------
DamWingSweep	LABEL	NEAR
;---------------------------

		mov	SSF_Sweep,1
		or	AmbWarnings2,AMB_SWP
        SHAKE	SHAKE_NOSE_DOWN,HSHAKE_HI,VSHAKE_HI,65535;
		ret

;6---------------------------
DamFlaps	LABEL	NEAR
;---------------------------

		mov	SSF_Flaps,1
		or	AmbWarnings2,AMB_FLPS
        SHAKE	SHAKE_NOSE_DOWN,HSHAKE_HI,VSHAKE_HI,65535;
		ret

;7---------------------------
DamThrustRvrs	LABEL	NEAR
;---------------------------

		mov	SSF_ThrustRvrs,1
		or	RedWarnings2,RED_REV
        SHAKE	SHAKE_NOSE_DOWN,HSHAKE_HI,VSHAKE_HI,65535;
		ret

;8---------------------------
DamSPILS	LABEL	NEAR
;---------------------------

		mov	SSF_SPILS,1
		or	RedWarnings2,RED_SPILS
        SHAKE	SHAKE_NOSE_DOWN,HSHAKE_HI,VSHAKE_HI,65535;
		ret

;9---------------------------
DamHUD		LABEL	NEAR
;---------------------------

		mov	SSF_HUD,1
		or	AmbWarnings2,AMB_HUD
        SHAKE	SHAKE_NOSE_DOWN,HSHAKE_HI,VSHAKE_HI,65535;
		ret

;10---------------------------
DamPilotMFD	LABEL	NEAR
;---------------------------

		mov	SSF_PilotMFD,1
		or	AmbWarnings2,AMB_MFD1
        SHAKE	SHAKE_NOSE_DOWN,HSHAKE_HI,VSHAKE_OFF,65535;
		ret

;11---------------------------
DamNavigMFD	LABEL	NEAR
;---------------------------

		mov	SSF_NavigMFD,1
		or	AmbWarnings2,AMB_MFD2
        SHAKE	SHAKE_NOSE_DOWN,HSHAKE_HI,VSHAKE_OFF,65535;
		ret

;12---------------------------
DamTAB1		LABEL	NEAR
;---------------------------

		mov	SSF_TAB1,1
		or	AmbWarnings2,AMB_L_TAB
        SHAKE	SHAKE_NOSE_DOWN,HSHAKE_HI,VSHAKE_OFF,65535;
		ret

;13---------------------------
DamTAB2		LABEL	NEAR
;---------------------------

		mov	SSF_TAB2,1
		or	AmbWarnings2,AMB_R_TAB
        SHAKE	SHAKE_NOSE_DOWN,HSHAKE_HI,VSHAKE_OFF,65535;
		ret

;14---------------------------
DamOxygen	LABEL	NEAR
;---------------------------

		mov	SSF_Oxygen,1
		or	RedWarnings2,RED_OXY
        SHAKE	SHAKE_NOSE_DOWN,HSHAKE_HI,VSHAKE_OFF,65535;
		ret

;15---------------------------
DamRadar	LABEL	NEAR
;---------------------------

		mov	SSF_Radar,1
		or	AmbWarnings2,AMB_RAD
        SHAKE	SHAKE_NOSE_DOWN,HSHAKE_HI,VSHAKE_OFF,65535;
		ret

;16---------------------------
DamECM		LABEL	NEAR
;---------------------------

		test	ECMFitted,1
		jz	@F

		mov	SSF_ECM,1
		or	AmbWarnings2,AMB_ECM
        SHAKE	SHAKE_NOSE_DOWN,HSHAKE_HI,VSHAKE_OFF,65535;
		mov	ECMActive,0

@@:		ret

;17---------------------------
DamRWR		LABEL	NEAR
;---------------------------

		mov	SSF_RWR,1
		or	AmbWarnings2,AMB_RWR
        SHAKE	SHAKE_NOSE_DOWN,HSHAKE_HI,VSHAKE_OFF,65535;
		ret

;18---------------------------
DamADC		LABEL	NEAR
;---------------------------

		mov	SSF_ADC,1
		or	AmbWarnings2,AMB_ADC
        SHAKE	SHAKE_NOSE_DOWN,HSHAKE_HI,VSHAKE_OFF,65535;
		ret

;19---------------------------
DamEngineFire	LABEL	NEAR
;---------------------------

;* reduce chance of engine fire

		call	RandX
		cmp	al,128
		jb	SkipFire

;* random lh eng fire

		call	RandX
		cmp	al,127
		ja	@F

		mov	EngFire1,1
		or	RedWarnings2,RED_L_FIRE
		SHAKE	SHAKE_NOSE_DOWN,HSHAKE_HI,VSHAKE_HI,65535;
		
;* random rh eng fire

@@:		call	RandX
		cmp	al,127
		ja	SkipFire

		mov	EngFire2,1
		or	RedWarnings2,RED_R_FIRE
        SHAKE	SHAKE_NOSE_DOWN,HSHAKE_HI,VSHAKE_HI,65535;
		
SkipFire:	ret

RandomDamage	ENDP

GENCODE		ENDS

;============================================================================

		END

