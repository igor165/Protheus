#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "QIEA030.CH"


/*/{Protheus.doc} QIEA030RUS
Units of Measure master data (Russia).

@author Flavio Lopes
@since 21/02/2016
@version MA3 - Russia
/*/
Function QIEA030RUS(xRotAuto)
Local oBrowse as object
Private lQ030Auto as logical

lQ030Auto := (xRotAuto <> Nil)

If FindFunction('A207UM'+cPaisLoc)
	&('A207UM'+cPaisLoc+'()')
Else
	A207UM()
Endif

oBrowse := BrowseDef()
oBrowse:Activate()

Return Nil

/*/{Protheus.doc} BrowseDef
Browse definition

@author Flavio Lopes
@since 21/02/2016
@version MA3 - Russia
/*/
//-------------------------------------------------------------------
Static Function BrowseDef()
Local oBrowse as object

oBrowse := FWLoadBrw("QIEA030")

Return oBrowse 

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu definition

@author Flavio Lopes
@since 21/02/2016
@version MA3 - Russia
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina :=  FWLoadMenuDef("QIEA030")
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Defini1o do modelo de dados
@author 	Flavio Lopes
@since 		16/01/2016
@version 	1.0
@project	MA3
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel as object

oModel 	:= FwLoadModel('QIEA030')

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Defini1o do interface
@author 	Flavio Lopes
@since 		16/01/2016
@version 	1.0
@project MA3
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel 	as object
Local oView		as object

oView	:= FWLoadView("QIEA030")

Return oView

//-----------------------------------------------------------------------
/*/{Protheus.doc} A207UMRUS
Load data in table SAH - Unit of Meassures. (specific for Russia)

@author 	Flavio Lopes
@since 		16/01/2016
@version 	1.0
@project	MA3
/*/
//-----------------------------------------------------------------------
Function A207UMRUS() 
Local aSAHData	:= {}
Local lAdd		as Logical
Local nX		as Numeric

if SAH->(LASTREC())<1
	aSAHData	:= {}
//				AH_UNIMED,AH_DESCPO			AH_DESCES		AH_DESCIN		AH_UMRES			AH_CODOKEI
	aAdd(aSAHData,{STR0013	,STR0014			,""			,""				,Lower(STR0013)		,"006"})
	aAdd(aSAHData,{STR0015	,STR0016			,""			,""				,Lower(STR0015)		,"163"})
	aAdd(aSAHData,{STR0017	,STR0018			,""			,""				,Lower(STR0019)		,"053"})
	aAdd(aSAHData,{STR0020	,STR0021			,""			,""				,Lower(STR0020)		,"005"})
	aAdd(aSAHData,{STR0022	,STR0023			,""			,""				,Lower(STR0022)		,"359"})

	aAdd(aSAHData,{STR0024	,STR0025			,""			,""				,Lower(STR0024)		,"642"})
	aAdd(aSAHData,{STR0026	,STR0027			,""			,""				,Lower(STR0026)		,"166"})
	aAdd(aSAHData,{STR0028	,STR0029			,""			,""				,Lower(STR0028)		,"008"})
	aAdd(aSAHData,{STR0030	,STR0031			,""			,""				,Lower(STR0030)		,"112"})
	aAdd(aSAHData,{STR0032	,STR0033			,""			,""				,Lower(STR0032)		,"055"})

	aAdd(aSAHData,{STR0034	,STR0035			,""			,""				,Lower(STR0034)		,"113"})
	aAdd(aSAHData,{STR0036	,STR0037			,""			,""				,Lower(STR0036)		,"111"})
	aAdd(aSAHData,{STR0038	,STR0039			,""			,""				,Lower(STR0038)		,"161"})
	aAdd(aSAHData,{STR0040	,STR0041			,""			,""				,Lower(STR0040)		,"003"})
	aAdd(aSAHData,{STR0042	,STR0043			,""			,""				,Lower(STR0044)		,"355"})

	aAdd(aSAHData,{STR0045	,STR0046			,""			,""				,Lower(STR0047)		,"356"})
	aAdd(aSAHData,{STR0048	,STR0049			,""			,""				,Lower(STR0048)		,"168"})
	aAdd(aSAHData,{STR0050	,STR0051			,""			,""				,Lower(STR0050)		,"796"})
	aAdd(aSAHData,{STR0052	,STR0053			,""			,""				,Lower(STR0052)		,"004"})

	DbSelectArea("SAH") 
	SAH->(DbSetOrder(1))
	
	For nX:=1 To Len(aSAHData)
	lAdd := ! SAH->(DBSeek(xFilial("SAH") + aSAHData[nX][1]))
	Reclock("SAH", lAdd)
		SAH->AH_FILIAL	:= xFilial("SAH")
		SAH->AH_UNIMED	:= aSAHData[nX][1]
		SAH->AH_DESCPO	:= aSAHData[nX][2]
		SAH->AH_DESCES	:= aSAHData[nX][3]
		SAH->AH_DESCIN	:= aSAHData[nX][4]
		SAH->AH_UMRES	:= aSAHData[nX][5]
		SAH->AH_CODOKEI	:= aSAHData[nX][6]
		MsUnlock()
	Next nX
Endif
Return .T.