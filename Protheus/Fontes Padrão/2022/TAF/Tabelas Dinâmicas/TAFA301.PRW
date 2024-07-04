#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA301.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA301
Cadastro MVC Codigo da Análise            

@author Evandro dos Santos Oliveira
@since 23/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA301()

Local oBrw := FwMBrowse():New()

oBrw:SetDescription(STR0001) //"Codigo da Análise"
oBrw:SetAlias("CUM")
oBrw:SetMenuDef("TAFA301")
oBrw:Activate()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Funcao generica MVC com as opcoes de menu

@author Evandro dos Santos Oliveira
@since 23/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return(xFunMnuTAF("TAFA301"))

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Evandro dos Santos Oliveira
@since 23/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruCUM := FwFormStruct(1,"CUM")
Local oModel   := MpFormModel():New("TAFA301")

oModel:AddFields("MODEL_CUM",/*cOwner*/,oStruCUM)
oModel:GetModel("MODEL_CUM"):SetPrimaryKey({"CUM_FILIAL","CUM_ID"})

Return(oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Evandro dos Santos Oliveira
@since 23/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel   := FwLoadModel("TAFA301")
Local oStruCUM := FwFormStruct(2,"CUM")
Local oView    := FwFormView():New()

oView:SetModel(oModel)
oView:AddField("VIEW_CUM",oStruCUM,"MODEL_CUM")

oView:EnableTitleView("VIEW_CUM",STR0001) //"Codigo da Análise"
oView:CreateHorizontalBox("FIELDSCUM",100)
oView:SetOwnerView("VIEW_CUM","FIELDSCUM")

Return(oView)

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualização da tabela autocontida.

@Param		nVerEmp	-	Versão corrente na empresa
			nVerAtu	-	Versão atual ( passado como referência )

@Return	aRet		-	Array com estrutura de campos e conteúdo da tabela

@Author	Felipe de Carvalho Seolin
@Since		24/11/2015
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function FAtuCont( nVerEmp, nVerAtu )

Local aHeader	:=	{}
Local aBody	:=	{}
Local aRet		:=	{}

nVerAtu := 1003

If nVerEmp < nVerAtu
	aAdd( aHeader, "CUM_FILIAL" )
	aAdd( aHeader, "CUM_ID" )
	aAdd( aHeader, "CUM_CODIGO" )
	aAdd( aHeader, "CUM_DESCRI" )
	aAdd( aHeader, "CUM_VALIDA" )

	aAdd( aBody, { "", "000001", "1.1", "P-AMINOFENOL", "" } )
	aAdd( aBody, { "", "000002", "1.2", "METAHEMOGLOBINA", "" } )
	aAdd( aBody, { "", "000003", "1.3", "P-AMINOFENOL E METAHEMOGLOBINA", "" } )
	aAdd( aBody, { "", "000004", "2.1", "ARSENICO", "" } )
	aAdd( aBody, { "", "000005", "3.1", "CADMIO", "" } )
	aAdd( aBody, { "", "000006", "4.1", "CHUMBO E AC. DELTA AMINO LEVULINICO", "" } )
	aAdd( aBody, { "", "000007", "4.2", "ZINCOPROTOPORFIRINA", "" } )
	aAdd( aBody, { "", "000008", "5.1", "CHUMBO", "" } )
	aAdd( aBody, { "", "000009", "6.1", "CROMO", "" } )
	aAdd( aBody, { "", "000010", "7.1", "CARBOXIHEMOGLOBINA", "" } )
	aAdd( aBody, { "", "000011", "8.1", "N-METILFORMAMIDA", "" } )
	aAdd( aBody, { "", "000012", "9.1", "AC. 2-TIO-TIAZOLIDINA", "" } )
	aAdd( aBody, { "", "000013", "10.1", "ACETIL-COLINESTERASE ERITROCITARIA", "" } )
	aAdd( aBody, { "", "000014", "10.2", "COLINESTERASE PLASMATICA", "" } )
	aAdd( aBody, { "", "000015", "10.3", "COLINESTERASE ERITROCITARIA E PLASMATICA (SANGUE TOTAL)", "" } )
	aAdd( aBody, { "", "000016", "11.1", "AC. MANDELICO", "" } )
	aAdd( aBody, { "", "000017", "11.2", "AC. FENIL-GLIOXILICO", "" } )
	aAdd( aBody, { "", "000018", "11.3", "AC. MANDELICO E AC. FENIL-GLIOXILICO", "" } )
	aAdd( aBody, { "", "000019", "12.1", "FENOL", "" } )
	aAdd( aBody, { "", "000020", "13.1", "FLUORETO", "" } )
	aAdd( aBody, { "", "000021", "14.1", "MERCURIO", "" } )
	aAdd( aBody, { "", "000022", "15.1", "METANOL", "" } )
	aAdd( aBody, { "", "000023", "16.1", "METIL-ETIL-CETONA", "" } )
	aAdd( aBody, { "", "000024", "17.1", "CARBOXIHEMOGLOBINA", "" } )
	aAdd( aBody, { "", "000025", "18.1", "2,5 HEXANODIONA", "" } )
	aAdd( aBody, { "", "000026", "19.1", "METAHEMOGLOBINA", "" } )
	aAdd( aBody, { "", "000027", "20.1", "PENTACLOROFENOL", "" } )
	aAdd( aBody, { "", "000028", "21.1", "AC. TRICLOROACETICO", "" } )
	aAdd( aBody, { "", "000029", "22.1", "AC. TRICLOROACETICO", "" } )
	aAdd( aBody, { "", "000030", "23.1", "AC. HIPURICO", "" } )
	aAdd( aBody, { "", "000031", "24.1", "TRICLOROCOMPOSTOS TOTAIS", "" } )
	aAdd( aBody, { "", "000032", "25.1", "TRICLOROCOMPOSTOS TOTAIS", "" } )
	aAdd( aBody, { "", "000033", "26.1", "AC. METIL-HIPURICO", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )