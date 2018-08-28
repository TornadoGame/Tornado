;****************************************************************************
;*
;* DATAXCHG.ASM
;*
;* Load and save game play data, maps etc.
;*
;* 08.12.1992 - KJB
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	LoadGameData
		PUBLIC	SaveGameData
		PUBLIC	LoadMapData
		PUBLIC	SaveMapData

		EXTRN	LoadFile:FAR
		EXTRN	SaveFile:FAR
		EXTRN	BuildSctrTables:FAR

		EXTRN	CloudBase:DWORD
		EXTRN	_CloudBase:DWORD

		EXTRN	GameDataSize:WORD
		EXTRN	MapLayerSize:WORD
		EXTRN	MiscDataSize:WORD
		EXTRN	M_VIEW:WORD
		EXTRN	_M_VIEW:WORD
		EXTRN	EXP_VIEW:WORD
		EXTRN	_EXP_VIEW:WORD
		EXTRN	ExpMapZoom:WORD
		EXTRN	_ExpMapZoom:WORD
		EXTRN	RedWarnings1:WORD
		EXTRN	RedWarnings2:WORD
		EXTRN	AmbWarnings1:WORD
		EXTRN	AmbWarnings2:WORD
		EXTRN	RedWarnings:WORD
		EXTRN	AmbWarnings:WORD
		EXTRN	FuelWt:WORD
		EXTRN	_FuelWt:WORD
		EXTRN	SecScanCnt1:WORD
		EXTRN	_SecScanCnt1:WORD
		EXTRN	SecScanOff1:WORD
		EXTRN	_SecScanOff1:WORD
		EXTRN	SecScanCnt2:WORD
		EXTRN	_SecScanCnt2:WORD
		EXTRN	SecScanOff2:WORD
		EXTRN	_SecScanOff2:WORD
		EXTRN	CloudDepth:WORD
		EXTRN	_CloudDepth:WORD
		EXTRN	ImpactList:WORD

		EXTRN	GamePlayData:BYTE
		EXTRN	MapLayers:BYTE
		EXTRN	MiscData:BYTE
		EXTRN	SectorDataStart:BYTE
		EXTRN	MSctrDataStart:BYTE
		EXTRN	DieFlag:BYTE
		EXTRN	GndTextEnabled:BYTE
		EXTRN	_GndTextEnabled:BYTE
		EXTRN	TreesEnabled:BYTE
		EXTRN	_TreesEnabled:BYTE
		EXTRN	HillTextEnabled:BYTE
		EXTRN	_HillTxtEnabled:BYTE
		EXTRN	CloudsEnabled:BYTE
		EXTRN	_CloudsEnabled:BYTE
		EXTRN	StarsEnabled:BYTE
		EXTRN	_StarsEnabled:BYTE
		EXTRN	GradEnabled:BYTE
		EXTRN	_GradEnabled:BYTE
		EXTRN	Overcast:BYTE
		EXTRN	_Overcast:BYTE
		EXTRN	Fog:BYTE
		EXTRN	_Fog:BYTE
		EXTRN	Night:BYTE
		EXTRN	_Night:BYTE
		EXTRN	PanelLight:BYTE
		EXTRN	_PanelLight:BYTE

		EXTRN	CHStick:BYTE
		EXTRN	_CHStick:BYTE
		EXTRN	ThrustMaster:BYTE
		EXTRN	_ThrustMaster:BYTE
		EXTRN	TM_MinX:WORD
		EXTRN	_TM_MinX:WORD
		EXTRN	TM_MinY:WORD
		EXTRN	_TM_MinY:WORD
		EXTRN	TM_MidX:WORD
		EXTRN	_TM_MidX:WORD
		EXTRN	TM_MidY:WORD
		EXTRN	_TM_MidY:WORD
		EXTRN	TM_MaxX:WORD
		EXTRN	_TM_MaxX:WORD
		EXTRN	TM_MaxY:WORD
		EXTRN	_TM_MaxY:WORD
		EXTRN	TM_CoolieCn:WORD
		EXTRN	_TM_CoolieCn:WORD
		EXTRN	TM_CoolieLt:WORD
		EXTRN	_TM_CoolieLt:WORD
		EXTRN	TM_CoolieDn:WORD
		EXTRN	_TM_CoolieDn:WORD
		EXTRN	TM_CoolieRt:WORD
		EXTRN	_TM_CoolieRt:WORD
		EXTRN	TM_CoolieUp:WORD
		EXTRN	_TM_CoolieUp:WORD

		EXTRN	SEC_MAP_SIZE:ABS
		EXTRN	MSEC_MAP_SIZE:ABS

;============================================================================

		INCLUDE	MAINDATA.INC

		INCLUDE	\VISUAL\VISDATA.INC
		INCLUDE	\VISUAL\VISMACRO.INC

		INCLUDE	\LIB8086\USEFUL.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

GndDataSize	DW	0		;OBSECDEF.IN file size
MobDataSize	DW	0		;MSECDEF.IN file size

;* "in" files

GamePlayIn	DB	"..\DATAXCHG\GAMEPLAY.IN",0
LayersIn	DB	"..\DATAXCHG\LAYER.IN",0
GndObjectsIn	DB	"..\DATAXCHG\OBSECDEF.IN",0
MobObjectsIn	DB	"..\DATAXCHG\MSECDEF.IN",0
MiscDataIn	DB	"..\DATAXCHG\MISCDATA.IN",0

		EVEN

;* "out" files

GamePlayOut	DB	"..\DATAXCHG\GAMEPLAY.OUT",0
ImpactOut	DB	"..\DATAXCHG\IMPACT.OUT",0
GndObjectsOut	DB	"..\DATAXCHG\OBSECDEF.OUT",0
MobObjectsOut	DB	"..\DATAXCHG\MSECDEF.OUT",0

		EVEN

DATA		ENDS

;============================================================================

CODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:CODE
		ASSUME DS:DATA

;* LoadGameData
;*
;* pass: nothing
;* ret : cf = 0: ok
;*       cf = 1: disk error
;* kill: assume all

LoadGameData	PROC	NEAR

;---------------------
;* load game play data
;---------------------

		mov	cx,GameDataSize
		mov	dx,OFFSET GamePlayIn
		mov	di,OFFSET GamePlayData
		push	WORD PTR GamePlayData	;store data start datum
		call	LoadFile
		pop	WORD PTR GamePlayData	;restore data start datum
		mov	al,SYS_ERR_LD_GAME
		_JC	LoadGameError

;----------------
;* load misc data
;----------------

		mov	cx,MiscDataSize
		mov	dx,OFFSET MiscDataIn
		mov	di,OFFSET MiscData
		mov	ax,SEG MiscData
		mov	es,ax
		call	LoadFile
		mov	ax,DATA
		mov	es,ax
		mov	al,SYS_ERR_LD_MISC
		_JC	LoadGameError

;-------------------------
;* transfer duplicate data
;-------------------------

;* model

		COPY_VP	M_VIEW,_M_VIEW

		mov	ax,_FuelWt
		mov	FuelWt,ax

;* explore mode

		COPY_VP	EXP_VIEW,_EXP_VIEW

		mov	ax,_ExpMapZoom
		mov	ExpMapZoom,ax

;* visual

		mov	ax,_SecScanCnt1
		mov	SecScanCnt1,ax
		mov	ax,_SecScanOff1
		mov	SecScanOff1,ax
		mov	ax,_SecScanCnt2
		mov	SecScanCnt2,ax
		mov	ax,_SecScanOff2
		mov	SecScanOff2,ax
		mov	ax,WORD PTR _CloudBase
		mov	WORD PTR CloudBase,ax
		mov	ax,WORD PTR _CloudBase+2
		mov	WORD PTR CloudBase+2,ax
		mov	ax,_CloudDepth
		mov	CloudDepth,ax
		mov	al,_GndTextEnabled
		mov	GndTextEnabled,al
		mov	al,_TreesEnabled
		mov	TreesEnabled,al
		mov	al,_HillTxtEnabled
		mov	HillTextEnabled,al
		mov	al,_CloudsEnabled
		mov	CloudsEnabled,al
		mov	al,_StarsEnabled
		mov	StarsEnabled,al
		mov	al,_GradEnabled
		mov	GradEnabled,al
		mov	al,_Overcast
		mov	Overcast,al
		mov	al,_Fog
		mov	Fog,al
		mov	al,_Night
		mov	Night,al
		mov	al,_PanelLight
		mov	PanelLight,al

;* CH FlightStick Pro

		mov	al,_CHStick
		mov	CHStick,al

;* ThrustMaster FCS

		mov	al,_ThrustMaster
		mov	ThrustMaster,al
		mov	ax,_TM_MinX
		mov	TM_MinX,ax
		mov	ax,_TM_MinY
		mov	TM_MinY,ax
		mov	ax,_TM_MidX
		mov	TM_MidX,ax
		mov	ax,_TM_MidY
		mov	TM_MidY,ax
		mov	ax,_TM_MaxX
		mov	TM_MaxX,ax
		mov	ax,_TM_MaxY
		mov	TM_MaxY,ax
		mov	ax,_TM_CoolieCn
		mov	TM_CoolieCn,ax
		mov	ax,_TM_CoolieLt
		mov	TM_CoolieLt,ax
		mov	ax,_TM_CoolieDn
		mov	TM_CoolieDn,ax
		mov	ax,_TM_CoolieRt
		mov	TM_CoolieRt,ax
		mov	ax,_TM_CoolieUp
		mov	TM_CoolieUp,ax

		clc		;cf = 0 = ok
		ret

LoadGameError:	mov	DieFlag,al
		ret

LoadGameData	ENDP

;----------------------------------------------------------------------------

;* SaveGameData
;*
;* pass: nothing
;* ret : cf = 0: ok
;*       cf = 1: disk error
;* kill: assume all

SaveGameData	PROC	NEAR

;------------------
;* combine warnings
;------------------

		mov	ax,RedWarnings1
		or	ax,RedWarnings2
		mov	RedWarnings,ax

		mov	ax,AmbWarnings1
		or	ax,AmbWarnings2
		mov	AmbWarnings,ax

;-------------------------
;* transfer duplicate data
;-------------------------

;* model

		COPY_VP	_M_VIEW,M_VIEW

		mov	ax,FuelWt
		mov	_FuelWt,ax

;* explore mode

		COPY_VP	_EXP_VIEW,EXP_VIEW

		mov	ax,ExpMapZoom
		mov	_ExpMapZoom,ax

;* visual

		mov	ax,SecScanCnt1
		mov	_SecScanCnt1,ax
		mov	ax,SecScanOff1
		mov	_SecScanOff1,ax
		mov	ax,SecScanCnt2
		mov	_SecScanCnt2,ax
		mov	ax,SecScanOff2
		mov	_SecScanOff2,ax
		mov	ax,WORD PTR CloudBase
		mov	WORD PTR _CloudBase,ax
		mov	ax,WORD PTR CloudBase+2
		mov	WORD PTR _CloudBase+2,ax
		mov	ax,CloudDepth
		mov	_CloudDepth,ax
		mov	al,GndTextEnabled
		mov	_GndTextEnabled,al
		mov	al,TreesEnabled
		mov	_TreesEnabled,al
		mov	al,HillTextEnabled
		mov	_HillTxtEnabled,al
		mov	al,CloudsEnabled
		mov	_CloudsEnabled,al
		mov	al,StarsEnabled
		mov	_StarsEnabled,al
		mov	al,GradEnabled
		mov	_GradEnabled,al

;* ThrustMaster

		mov	ax,TM_MidX
		mov	_TM_MidX,ax
		mov	ax,TM_MidY
		mov	_TM_MidY,ax

;---------------------
;* save game play data
;---------------------

		mov	cx,GameDataSize
		mov	dx,OFFSET GamePlayOut
		mov	di,OFFSET GamePlayData
		call	SaveFile
		jc	SaveGameError

;-------------------------------
;* save weapon impact point data
;-------------------------------

		mov	cx,NUM_IMPACTS*IMP_REC_SIZE
		mov	dx,OFFSET ImpactOut
		mov	ax,SEG ImpactList
		mov	es,ax
		mov	di,OFFSET ImpactList
		call	SaveFile
		mov	ax,DATA
		mov	es,ax
		jc	SaveImpError

		ret

SaveGameError:	mov	DieFlag,SYS_ERR_SV_GAME
		ret

SaveImpError:	mov	DieFlag,SYS_ERR_SV_IMP
		ret

SaveGameData	ENDP

;----------------------------------------------------------------------------

;* LoadMapData
;*
;* pass: nothing
;* ret : cf = 0: ok
;*       cf = 1: disk error
;* kill: assume all

LoadMapData	PROC	NEAR

;---------------
;* load LAYER.IN
;---------------

		mov	cx,MapLayerSize
		mov	dx,OFFSET LayersIn
		mov	di,OFFSET MapLayers
		mov	ax,SEG MapLayers
		mov	es,ax
		call	LoadFile
		mov	ax,DATA
		mov	es,ax
		mov	al,SYS_ERR_LD_LYR
		jc	LoadMapError

;------------------
;* load OBSECDEF.IN
;------------------

		mov	cx,SEC_MAP_SIZE
		mov	dx,OFFSET GndObjectsIn
		mov	di,OFFSET SectorDataStart
		mov	ax,SEG SectorDataStart
		mov	es,ax
		call	LoadFile
		mov	GndDataSize,ax
		mov	ax,DATA
		mov	es,ax
		mov	al,SYS_ERR_LD_OBJ
		jc	LoadMapError

;-----------------
;* load MSECDEF.IN
;-----------------

		mov	cx,MSEC_MAP_SIZE
		mov	dx,OFFSET MobObjectsIn
		mov	di,OFFSET MSctrDataStart
		mov	ax,SEG MSctrDataStart
		mov	es,ax
		call	LoadFile
		mov	MobDataSize,ax
		mov	ax,DATA
		mov	es,ax
		mov	al,SYS_ERR_LD_MOB
		jc	LoadMapError

;---------------------------
;* init visual sector tables
;---------------------------

		call	BuildSctrTables

		clc			;cf = 0 = ok
		ret

LoadMapError:	mov	DieFlag,al
		ret

LoadMapData	ENDP

;----------------------------------------------------------------------------

;* SaveMapData
;*
;* pass: nothing
;* ret : cf = 0: ok
;*       cf = 1: disk error
;* kill: assume all

SaveMapData	PROC	NEAR

;-------------------
;* save OBSECDEF.OUT
;-------------------

		mov	cx,GndDataSize
		mov	dx,OFFSET GndObjectsOut
		mov	di,OFFSET SectorDataStart
		mov	ax,SEG SectorDataStart
		mov	es,ax
		call	SaveFile
		mov	ax,DATA
		mov	es,ax
		mov	al,SYS_ERR_SV_OBJ
		jc	SaveMapError

;------------------
;* save MSECDEF.OUT
;------------------

		mov	cx,MobDataSize
		mov	dx,OFFSET MobObjectsOut
		mov	di,OFFSET MSctrDataStart
		mov	ax,SEG MSctrDataStart
		mov	es,ax
		call	SaveFile
		mov	ax,DATA
		mov	es,ax
		mov	al,SYS_ERR_SV_MOB
		jc	SaveMapError

		ret

SaveMapError:	mov	DieFlag,al
		ret

SaveMapData	ENDP

CODE		ENDS

;============================================================================

		END

