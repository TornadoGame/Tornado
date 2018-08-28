;****************************************************************************
;*
;* JETTISON.ASM
;*
;* Jettison control.
;*
;* 08.07.1992 - KJB
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	JetExtTanks
		PUBLIC	JetExtStores
		PUBLIC	JetAll

		EXTRN	ExtStores:WORD
		EXTRN	FuelWt:WORD
		EXTRN	FuelWtFine:WORD
		EXTRN	TornadoType:WORD
		EXTRN	ChaffCntr:WORD
		EXTRN	FlareCntr:WORD
		EXTRN	ArmMode:WORD
		EXTRN	AirArmMode:WORD
		EXTRN	PackagePtr:WORD
		EXTRN	Cannons:WORD

		EXTRN	Jettison:BYTE
		EXTRN	ECMFitted:BYTE
		EXTRN	ECMActive:BYTE

		EXTRN	MAX_IDS_FUEL:ABS
		EXTRN	MAX_ADV_FUEL:ABS

;============================================================================

		INCLUDE	MAINDATA.INC

;============================================================================

		EXTRN	Packages:PACKAGE

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

DATA		ENDS

;============================================================================

MODCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:MODCODE
		ASSUME DS:DATA

;* JetExtTanks - jettison external fuel tanks
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

JetExtTanks	PROC	NEAR

		cmp	Jettison,JET_EXT_TANKS	;already jettisoned?
		jae	@F			;yes ->

		call	Jettison1

		mov	Jettison,JET_EXT_TANKS

@@:		ret

JetExtTanks	ENDP

;----------------------------------------------------------------------------

;* JetExtStores - jettison external stores
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

JetExtStores	PROC	NEAR

		cmp	Jettison,JET_EXT_STORES	;already jettisoned?
		jae	@F		   	;yes ->

		call	Jettison2

		mov	Jettison,JET_EXT_STORES

@@:		ret

JetExtStores	ENDP

;----------------------------------------------------------------------------

;* JetAll - jettison all
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

JetAll		PROC	NEAR

		cmp	Jettison,JET_ALL	;already jettisoned?
		je	@F			;yes ->

		call	Jettison3

		mov	Jettison,JET_ALL

@@:		ret

JetAll		ENDP

;----------------------------------------------------------------------------

;* Jettison3 - jettison internal fuel + external stores + external tanks
;* Jettison2 - jettison external stores + external tanks
;* Jettison1 - jettison external tanks
;*
;* pass: nothing
;* ret : nothing
;* kill: assume all

;---------------------------
Jettison3	PROC	NEAR	;internal fuel + external stores + external tanks
;---------------------------

		cmp	FuelWt,1000	;less than minimal fuel already?
		jb	@F		;yes ->

		mov	FuelWt,1000
		mov	FuelWtFine,0

@@:		mov	ExtStores[EXT_SIDEWINDER],0

;---------------------------
Jettison2	LABEL	NEAR	;external stores + external tanks
;---------------------------

		xor	ax,ax

		mov	ExtStores[EXT_GPB1000],ax
		mov	ExtStores[EXT_RET1000],ax
		mov	ExtStores[EXT_LGB1000],ax
		mov	ExtStores[EXT_BL755],ax
		mov	ExtStores[EXT_JP233],ax
		mov	ExtStores[EXT_ALARM],ax
		mov	ExtStores[EXT_SKYFLASH],ax
		mov	ExtStores[EXT_BOZ100],ax
		mov	ExtStores[EXT_SKYSHADOW],ax

;* clear chaff, flares and ECM (except ADV)

		cmp	TornadoType,ADV_TORNADO	;ADV
		je	@F			;yes (internal) ->

		mov	ChaffCntr,ax
		mov	FlareCntr,ax

		mov	ECMFitted,al
		mov	ECMActive,al

;* clear all packages

@@:		mov	si,OFFSET Packages

		mov	cx,NUM_PACKAGES

@@:		mov	[si].PACK_WEAP_TYPE,NULL_WEAPON
		add	si,PACK_REC_SIZE
		loop	@B

		mov	PackagePtr,-1

;* disarm (unless cannon or Sidewinder armed and available)

		cmp	ArmMode,ARM_CANNON
		jne	@F

		cmp	Cannons,0
		ja	ArmOk

@@:		cmp	ArmMode,ARM_SIDEWINDER
		jne	@F

		cmp	ExtStores[EXT_SIDEWINDER],0
		ja	ArmOk

@@:		mov	ArmMode,ARM_OFF

		mov	ax,ARM_CANNON	;assume cannons available

		cmp	Cannons,0	;any cannons?
		ja	@F		;yes ->

		mov	ax,ARM_OFF

@@:		mov	AirArmMode,ax

ArmOk:

;---------------------------
Jettison1	LABEL	NEAR	;external tanks
;---------------------------

		mov	ExtStores[EXT_DROPTANK],0

		mov	ax,MAX_ADV_FUEL	;assume ADV

		cmp	TornadoType,ADV_TORNADO	;ADV?
		je	@F			;yes ->

		mov	ax,MAX_IDS_FUEL

@@:		cmp	FuelWt,ax  	;any external fuel?
		jb	@F	   	;no ->

		mov	FuelWt,ax
 		mov	FuelWtFine,0

@@:		ret

Jettison3	ENDP

MODCODE		ENDS

;============================================================================

		END

