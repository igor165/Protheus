#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA293.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA293
Cadastro MVC Agente Quimico

@author Evandro dos Santos Oliveira
@since 16/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA293()

Local oBrw := FwMBrowse():New()

oBrw:SetDescription(STR0001) //"Agente Quimico"
oBrw:SetAlias("CUA")
oBrw:SetMenuDef("TAFA293")
oBrw:Activate()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Funcao generica MVC com as opcoes de menu

@author Evandro dos Santos Oliveira
@since 16/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return(xFunMnuTAF("TAFA293"))

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Evandro dos Santos Oliveira
@since 16/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruCUA := FwFormStruct(1,"CUA")
Local oModel   := MpFormModel():New("TAFA293")

oModel:AddFields("MODEL_CUA",/*cOwner*/,oStruCUA)
oModel:GetModel("MODEL_CUA"):SetPrimaryKey({"CUA_FILIAL","CUA_ID"})

Return(oModel)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Evandro dos Santos Oliveira
@since 16/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel   := FwLoadModel("TAFA293")
Local oStruCUA := FwFormStruct(2,"CUA")
Local oView    := FwFormView():New()

oView:SetModel(oModel)
oView:AddField("VIEW_CUA",oStruCUA,"MODEL_CUA")

oView:EnableTitleView("VIEW_CUA",STR0001) //"Agente Quimico"
oView:CreateHorizontalBox("FIELDSCUA",100)
oView:SetOwnerView("VIEW_CUA","FIELDSCUA")

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
	aAdd( aHeader, "CUA_FILIAL" )
	aAdd( aHeader, "CUA_ID" )
	aAdd( aHeader, "CUA_CODIGO" )
	aAdd( aHeader, "CUA_DESCRI" )
	aAdd( aHeader, "CUA_VALIDA" )

	aAdd( aBody, { "", "000001", "1", "ANILINA", "" } )
	aAdd( aBody, { "", "000002", "2", "ARSENICO", "" } )
	aAdd( aBody, { "", "000003", "3", "CADMIO", "" } )
	aAdd( aBody, { "", "000004", "4", "CHUMBO INORGANICO", "" } )
	aAdd( aBody, { "", "000005", "5", "CHUMBOTETRAETILA", "" } )
	aAdd( aBody, { "", "000006", "6", "CROMO HEXAVALENTE", "" } )
	aAdd( aBody, { "", "000007", "7", "DICLOROMETANO", "" } )
	aAdd( aBody, { "", "000008", "8", "DIMETILFORMAMIDA", "" } )
	aAdd( aBody, { "", "000009", "9", "DISSULFETO DE CARBONO", "" } )
	aAdd( aBody, { "", "000010", "10", "ESTERES ORGANOFOSFORADOS E CARBAMATOS", "" } )
	aAdd( aBody, { "", "000011", "11", "ESTIRENO", "" } )
	aAdd( aBody, { "", "000012", "12", "ETIL-BENZENO", "" } )
	aAdd( aBody, { "", "000013", "13", "FENOL", "" } )
	aAdd( aBody, { "", "000014", "14", "FLUOR E FLUORETOS", "" } )
	aAdd( aBody, { "", "000015", "15", "MERCURIO INORGANICO", "" } )
	aAdd( aBody, { "", "000016", "16", "METANOL", "" } )
	aAdd( aBody, { "", "000017", "17", "METIL-ETIL-CETONA", "" } )
	aAdd( aBody, { "", "000018", "18", "MONOXIDO DE CARBONO", "" } )
	aAdd( aBody, { "", "000019", "19", "N-HEXANO", "" } )
	aAdd( aBody, { "", "000020", "20", "NITROBENZENO", "" } )
	aAdd( aBody, { "", "000021", "21", "PENTACLOROFENOL", "" } )
	aAdd( aBody, { "", "000022", "22", "TETRACLOROETILENO", "" } )
	aAdd( aBody, { "", "000023", "23", "TOLUENO", "" } )
	aAdd( aBody, { "", "000024", "24", "TRICLOROETANO", "" } )
	aAdd( aBody, { "", "000025", "25", "TRICLOROETILENO", "" } )
	aAdd( aBody, { "", "000026", "26", "XILENO", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )