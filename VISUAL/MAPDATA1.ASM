;****************************************************************************
;*
;* MAPDATA1.ASM
;*
;* 11.02.1991 - KJB
;* 31.08.1992 - KJB - MobileLayer1 added for "static" mobiles.
;*
;* Notes:-
;*
;* Map size is 32 * 32 sectors.
;*
;* Map data is stored in the STACK segment! There is not enough room in the
;* standard DATA segment for the map.
;*
;* To read map data use:-
;*
;*		mov	al,RoadLayer1[bp]	;SS: implicit with [bp]
;*
;* or		mov	al,SS:RoadLayer1[bx]	;must use SS: prefix
;*
;* Map co-ord 0, 0 is the top left hand corner of the map, and is the first
;* element in the map layer arrays.
;*
;* >>>>> IMPORTANT <<<<<
;*
;* Refer to \LIB8086\STACK.ASM for notes on segment combine types.
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	MapLayerSize

		PUBLIC	MapLayers
		PUBLIC	EndLayers

		PUBLIC	SectorLayer1
		PUBLIC	FeatureLayer1
		PUBLIC	FeatureLayer2
		PUBLIC	RiverLayer1
		PUBLIC	RoadLayer1
		PUBLIC	RoadLayer2
		PUBLIC	RoadLayer3
		PUBLIC	RoadLayer4
		PUBLIC	RailLayer1
		PUBLIC	CloudLayer1
		PUBLIC	CloudLayer2
		PUBLIC	HillLayer1
		PUBLIC	HillLayer2
		PUBLIC	HillLayer3
		PUBLIC	HillLayer4
		PUBLIC	HillLayer5
		PUBLIC	HillLayer6
		PUBLIC	HillLayer7
		PUBLIC	HillLayer8
		PUBLIC	HillLayer9
		PUBLIC	SpecialLayer1
		PUBLIC	TreeLayer1
		PUBLIC	TreeLayer2
		PUBLIC	TreeLayer3
		PUBLIC	TreeLayer4
		PUBLIC	MobileLayer1

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

MapLayerSize	DW	OFFSET EndLayers-OFFSET MapLayers

DATA		ENDS

;============================================================================

STACK		SEGMENT PARA PUBLIC 'STACK'
		ASSUME SS:STACK

;---------------------------
MapLayers	LABEL	BYTE
;---------------------------

SectorLayer1	LABEL	BYTE

		INCLUDE	MAP\LAYERS\SECTOR1.INC

FeatureLayer1	LABEL	BYTE

		INCLUDE	MAP\LAYERS\FEATURE1.INC

FeatureLayer2	LABEL	BYTE

		INCLUDE	MAP\LAYERS\FEATURE2.INC

RiverLayer1	LABEL	BYTE

		INCLUDE	MAP\LAYERS\RIVER1.INC

RoadLayer1	LABEL	BYTE

		INCLUDE	MAP\LAYERS\ROAD1.INC

RoadLayer2	LABEL	BYTE

		INCLUDE	MAP\LAYERS\ROAD2.INC

RoadLayer3	LABEL	BYTE
	
		INCLUDE	MAP\LAYERS\ROAD3.INC

RoadLayer4	LABEL	BYTE

		INCLUDE	MAP\LAYERS\ROAD4.INC

RailLayer1	LABEL	BYTE

		INCLUDE	MAP\LAYERS\RAILWAY1.INC

CloudLayer1	LABEL	BYTE

		INCLUDE	MAP\LAYERS\CLOUD1.INC

CloudLayer2	LABEL	BYTE

		INCLUDE	MAP\LAYERS\CLOUD2.INC

HillLayer1	LABEL	BYTE

		INCLUDE	MAP\LAYERS\HILL1.INC

HillLayer2	LABEL	BYTE

		INCLUDE	MAP\LAYERS\HILL2.INC

HillLayer3	LABEL	BYTE

		INCLUDE	MAP\LAYERS\HILL3.INC

HillLayer4	LABEL	BYTE

		INCLUDE	MAP\LAYERS\HILL4.INC

HillLayer5	LABEL	BYTE

		INCLUDE	MAP\LAYERS\HILL5.INC

HillLayer6	LABEL	BYTE

		INCLUDE	MAP\LAYERS\HILL6.INC

HillLayer7	LABEL	BYTE

		INCLUDE	MAP\LAYERS\HILL7.INC

HillLayer8	LABEL	BYTE

		INCLUDE	MAP\LAYERS\HILL8.INC

HillLayer9	LABEL	BYTE

		INCLUDE	MAP\LAYERS\HILL9.INC

SpecialLayer1	LABEL	BYTE

		INCLUDE	MAP\LAYERS\SPECIAL1.INC

TreeLayer1	LABEL	BYTE

		INCLUDE	MAP\LAYERS\TREE1.INC

TreeLayer2	LABEL	BYTE

		INCLUDE	MAP\LAYERS\TREE2.INC

TreeLayer3	LABEL	BYTE

		INCLUDE	MAP\LAYERS\TREE3.INC

TreeLayer4	LABEL	BYTE

		INCLUDE	MAP\LAYERS\TREE4.INC

MobileLayer1	LABEL	BYTE

		INCLUDE	MAP\LAYERS\MOBILE1.INC

;---------------------------
EndLayers	LABEL	BYTE
;---------------------------

STACK		ENDS

;============================================================================

		END

