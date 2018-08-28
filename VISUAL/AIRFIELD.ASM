;****************************************************************************
;*
;* AIRFIELD.ASM
;*
;* Draw airfields.
;*
;* Airfields are included in the "specials" map layer.
;*
;* 05.08.1991 - KJB
;* 14.04.1992 - KJB - Reorganised to remove need for seperate subroutine
;*                    for each airfield.
;* 14.07.1992 - KJB - Taxiway / runway drawing order changed so that runways
;*                    are always drawn after taxiways. This is so that runway
;*                    lights take priority over taxiway lights.
;* 27.08.1992 - KJB - Taxi route data.
;*
;****************************************************************************

		OPTION	M510		;<<<<< MASM v5.10 <<<<<

		PUBLIC	DrawAirfield

		PUBLIC	AirfieldTable
		PUBLIC	ILSData
		PUBLIC	TaxiRoutePtrs

		EXTRN	DrawRunways:NEAR
		EXTRN	DrawTaxiways:NEAR

		EXTRN	AIRFIELD_1:ABS
		EXTRN	AIRFIELD_N:ABS

;============================================================================

		INCLUDE	PALETTES.INC
		INCLUDE	RWY_TAXI.INC

;============================================================================

DATA		SEGMENT PARA PUBLIC 'DATA'

;----------------
;* airfield table
;----------------

;* index = (special number - AIRFIELD_1) * 4

AirfieldTable	LABEL	WORD

		DW	OFFSET RunwayList1	;1 (AIRFIELD_1)
		DW	OFFSET Taxiways1
		DW	OFFSET RunwayList2	;2
		DW	OFFSET Taxiways2
		DW	OFFSET RunwayList3	;3
		DW	OFFSET Taxiways3
		DW	OFFSET RunwayList4	;4
		DW	OFFSET Taxiways4
		DW	OFFSET RunwayList5	;5
		DW	OFFSET Taxiways5
		DW	OFFSET RunwayList6	;6
		DW	OFFSET Taxiways6
		DW	OFFSET RunwayList7	;7
		DW	OFFSET Taxiways7
		DW	OFFSET RunwayList8	;8 (AIRFIELD_N)
		DW	OFFSET Taxiways8

;-------------
;* runway data
;-------------

;* Note: The active runway should always be the last runway in the list so
;*       that it is drawn last. This reduces runway light obstruction.

RunwayList1	RUNWAY	<RWY_1836,RWY_WIDTH192,30,29,30,49>
		RUNWAY	<RWY_0422,RWY_WIDTH192,35,47,17,29>
		RUNWAY	<RWY_0927,RWY_WIDTH256,48,32,16,32>
		DW	-1

RunwayList2	RUNWAY	<RWY_1331,RWY_WIDTH192,45,31,29,47>
		RUNWAY	<RWY_0422,RWY_WIDTH192,43,39,26,22>
		RUNWAY	<RWY_1836,RWY_WIDTH256,32,16,32,48>
		DW	-1

RunwayList3	RUNWAY	<RWY_1836,RWY_WIDTH192,24,15,24,35>
		RUNWAY	<RWY_1331,RWY_WIDTH128,34,15,16,33>
		RUNWAY	<RWY_0927,RWY_WIDTH256,48,29,15,29>
		DW	-1

RunwayList4	RUNWAY	<RWY_0927,RWY_WIDTH128,48,39,16,39>
		RUNWAY	<RWY_0927,RWY_WIDTH256,48,41,16,41>
		RUNWAY	<RWY_1836,RWY_WIDTH128,25,16,25,48>
		RUNWAY	<RWY_1836,RWY_WIDTH256,23,16,23,48>
		DW	-1

RunwayList5	RUNWAY	<RWY_0422,RWY_WIDTH192,45,41,28,24>
		RUNWAY	<RWY_1331,RWY_WIDTH192,36,22,20,38>
		RUNWAY	<RWY_0927,RWY_WIDTH256,50,38,14,38>
		DW	-1

RunwayList6	RUNWAY	<RWY_1331,RWY_WIDTH192,48,22,20,50>
		RUNWAY	<RWY_1836,RWY_WIDTH256,36,14,36,49>
		DW	-1

RunwayList7	RUNWAY	<RWY_0927,RWY_WIDTH128,48,48,16,48>
		DW	-1

RunwayList8	RUNWAY	<RWY_1331,RWY_WIDTH192,43,14,17,40>
		RUNWAY	<RWY_0927,RWY_WIDTH256,50,39,17,39>
		DW	-1

;----------
;* ILS data
;----------

ILSData		LABEL	WORD

ILSData1	ILS	<0,0,ILS_E+ILS_W,0,0,0,0,-3840,0,3840,0>

ILSData2	ILS	<0,-2048,ILS_N+ILS_S,0,-3840,0,3840,0,0,0,0>

ILSData3	ILS	<-256,-768,ILS_E+ILS_W,0,0,0,0,-4096,-768,3840,-768>

ILSData4	ILS	<-2304,-2048,ILS_N+ILS_S,-2304,-3840,-2304,3840,0,0,0,0>

ILSData5	ILS	<0,1536,ILS_E+ILS_W,0,0,0,0,-4352,1536,4352,1536>

ILSData6	ILS	<1024,-2048,ILS_N+ILS_S,1024,-4352,1024,4096,0,0,0,0>

ILSData7	ILS	<0,4096,ILS_E+ILS_W,0,0,0,0,-3840,4096,3840,4096>

ILSData8	ILS	<256,1792,ILS_E+ILS_W,0,0,0,0,-3584,1792,4352,1792>

;-----------------
;* taxi route data (taxi drone aircraft off runway)
;-----------------

;* Taxi routes are only specified for the active runway. Drone aircraft will
;* only land on active runways. The taxi route should begin somewhere after
;* the midpoint of the runway to allow the landing aircraft to decelerate.
;* The last taxiway should be long enough to cater for a queue of aircraft.
;*
;* TAXI data block:-
;*
;* TAXI_END_PTR : Pointer to last co-ord in taxi route list.
;* TAXI_X_MOD   : Modifies last x co-ord (wrt hdg) after aircraft has stopped.
;* TAXI_Y_MOD   : Modifies last y co-ord (wrt hdg) after aircraft has stopped.
;*
;* Route co-ord range = -8,192 .. +8,191ft (ie. standard sector size).

TaxiRoutePtrs	DW	OFFSET TaxiRoutes1
		DW	OFFSET TaxiRoutes2
		DW	OFFSET TaxiRoutes3
		DW	OFFSET TaxiRoutes4
		DW	OFFSET TaxiRoutes5
		DW	OFFSET TaxiRoutes6
		DW	OFFSET TaxiRoutes7
		DW	OFFSET TaxiRoutes8

;---------------------------
TaxiRoutes1	LABEL	WORD
;---------------------------

		DW	-1			;N
		DW	OFFSET TaxiRoute1_E	;E
		DW	-1			;S
		DW	OFFSET TaxiRoute1_W	;W

TaxiRoute1_E	TAXI	<OFFSET	EndRoute1_E,-141,-141>
		TNODE	<2560,0>
		TNODE	<2560,512>
		TNODE	<2304,768>
		TNODE	<-2304,768>
EndRoute1_E	TNODE	<256,3328>

TaxiRoute1_W	TAXI	<OFFSET	EndRoute1_W,-141,-141>
		TNODE	<-2816,0>
		TNODE	<-2944,128>
EndRoute1_W	TNODE	<256,3328>
	
;---------------------------
TaxiRoutes2	LABEL	WORD
;---------------------------

		DW	OFFSET TaxiRoute2_N	;N
		DW	-1			;E
		DW	OFFSET TaxiRoute2_S	;S
		DW	-1			;W

TaxiRoute2_N	TAXI	<OFFSET	EndRoute2_N,0,200>
		TNODE	<0,3072>
		TNODE	<-768,3840>
		TNODE	<-1024,3584>
EndRoute2_N	TNODE	<-1024,512>
	
TaxiRoute2_S	TAXI	<OFFSET	EndRoute2_S,0,200>
		TNODE	<0,-2048>
		TNODE	<256,-2048>
		TNODE	<768,-1536>
		TNODE	<768,3840>
		TNODE	<512,4096>
		TNODE	<-512,4096>
		TNODE	<-1024,3584>
EndRoute2_S	TNODE	<-1024,512>

;---------------------------
TaxiRoutes3	LABEL	WORD
;---------------------------

		DW	-1			;N
		DW	OFFSET TaxiRoute3_E	;E
		DW	-1			;S
		DW	OFFSET TaxiRoute3_W	;W

TaxiRoute3_E	TAXI	<OFFSET	EndRoute3_E,200,0>
		TNODE	<1792,-768>
		TNODE	<1792,-1024>
EndRoute3_E	TNODE	<-1792,-1024>
	
TaxiRoute3_W	TAXI	<OFFSET	EndRoute3_W,200,0>
		TNODE	<-2048,-768>
		TNODE	<-2048,-1024>
		TNODE	<-1024,-1792>
		TNODE	<-512,-1792>
		TNODE	<-512,-1280>
		TNODE	<0,-1280>
		TNODE	<1792,-1792>
		TNODE	<1792,-1024>
EndRoute3_W	TNODE	<-1792,-1024>

;---------------------------
TaxiRoutes4	LABEL	WORD
;---------------------------

		DW	OFFSET TaxiRoute4_N	;N
		DW	-1			;E
		DW	OFFSET TaxiRoute4_S	;S
		DW	-1			;W

TaxiRoute4_N	TAXI	<OFFSET	EndRoute4_N,0,-200>
		TNODE	<-2304,1792>
		TNODE	<-3072,1792>
		TNODE	<-3072,-4096>
		TNODE	<-1792,-4096>
EndRoute4_N	TNODE	<-1792,1536>
	
TaxiRoute4_S	TAXI	<OFFSET	EndRoute4_S,0,-200>
		TNODE	<-2304,-2560>
		TNODE	<-1792,-2560>
EndRoute4_S	TNODE	<-1792,1536>

;---------------------------
TaxiRoutes5	LABEL	WORD
;---------------------------

		DW	-1			;N
		DW	OFFSET TaxiRoute5_E	;E
		DW	-1			;S
		DW	OFFSET TaxiRoute5_W	;W

TaxiRoute5_E	TAXI	<OFFSET	EndRoute5_E,141,-141>
		TNODE	<4608,1536>
		TNODE	<4608,1024>
		TNODE	<1024,-2560>
EndRoute5_E	TNODE	<-2560,1024>

TaxiRoute5_W	TAXI	<OFFSET	EndRoute5_W,141,-141>
		TNODE	<-4608,1536>
		TNODE	<-4608,1280>
		TNODE	<-4352,768>
		TNODE	<-1024,-2048>
		TNODE	<-256,-1280>
EndRoute5_W	TNODE	<-2560,1024>

;---------------------------
TaxiRoutes6	LABEL	WORD
;---------------------------

		DW	OFFSET TaxiRoute6_N	;N
		DW	-1			;E
		DW	OFFSET TaxiRoute6_S	;S
		DW	-1			;W

TaxiRoute6_N	TAXI	<OFFSET	EndRoute6_N,141,-141>
		TNODE	<1024,512>
EndRoute6_N	TNODE	<-2560,4096>
	
TaxiRoute6_S	TAXI	<OFFSET	EndRoute6_S,141,-141>
		TNODE	<1024,-4608>
		TNODE	<512,-4608>
		TNODE	<256,-4352>
		TNODE	<256,1280>
EndRoute6_S	TNODE	<-2560,4096>

;---------------------------
TaxiRoutes7	LABEL	WORD
;---------------------------

		DW	-1			;N
		DW	OFFSET TaxiRoute7_E	;E
		DW	-1			;S
		DW	OFFSET TaxiRoute7_W	;W

TaxiRoute7_E	TAXI	<OFFSET	EndRoute7_E,141,141>
		TNODE	<3584,4096>
		TNODE	<3584,3840>
EndRoute7_E	TNODE	<1280,1536>
	
TaxiRoute7_W	TAXI	<OFFSET	EndRoute7_W,-141,141>
		TNODE	<-3072,4096>
		TNODE	<-3072,3840>
EndRoute7_W	TNODE	<-768,1536>

;---------------------------
TaxiRoutes8	LABEL	WORD
;---------------------------

		DW	-1			;N
		DW	OFFSET TaxiRoute8_E	;E
		DW	-1			;S
		DW	OFFSET TaxiRoute8_W	;W

TaxiRoute8_E	TAXI	<OFFSET	EndRoute8_E,141,-141>
		TNODE	<4608,1792>
		TNODE	<4608,1536>
		TNODE	<4096,1024>
		TNODE	<-256,1024>
		TNODE	<0,-768>
		TNODE	<0,-1792>
EndRoute8_E	TNODE	<-2816,1024>
	
TaxiRoute8_W	TAXI	<OFFSET	EndRoute8_W,141,-141>
		TNODE	<-3840,1792>
		TNODE	<-3840,1024>
		TNODE	<256,-3072>
		TNODE	<1280,-3072>
EndRoute8_W	TNODE	<-2816,1024>

DATA		ENDS

;============================================================================

FEATOBJ1	SEGMENT PARA PUBLIC 'DATA'

		INCLUDE	OBJECTS\FEATURES\TAXITILE.INC

FEATOBJ1	ENDS

;============================================================================

VISCODE		SEGMENT BYTE PUBLIC 'CODE'
		ASSUME CS:VISCODE
		ASSUME DS:DATA

;* DrawAirfield - draw runways / taxiways
;*
;* pass: al = specials number (AIRFIELD_1 .. AIRFIELD_N)
;* ret : nothing
;* kill: assume all

DrawAirfield	PROC	NEAR

		mov	bl,al

		sub	bl,AIRFIELD_1
		xor	bh,bh
		shl	bx,1	;*2
		shl	bx,1	;*4

;* draw taxiways first (give runway lights higher priority than taxiway lights)

		mov	si,AirfieldTable[bx+2]
		push	bx
		call	DrawTaxiways
		pop	bx

		mov	si,AirfieldTable[bx]
		call	DrawRunways

		ret

DrawAirfield	ENDP

VISCODE		ENDS

;============================================================================

		END

