#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA299.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA299
Cadastro MVC Grupos de Rendimento            

@author Evandro dos Santos Oliveira
@since 23/12/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA299()

Local oBrw := FwMBrowse():New()

oBrw:SetDescription(STR0001) //"Grupos de Rendimento"
oBrw:SetAlias("CUE")
oBrw:SetMenuDef("TAFA299")
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
Return(xFunMnuTAF("TAFA299"))

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

Local oStruCUE := FwFormStruct(1,"CUE")
Local oModel   := MpFormModel():New("TAFA299")

oModel:AddFields("MODEL_CUE",/*cOwner*/,oStruCUE)
oModel:GetModel("MODEL_CUE"):SetPrimaryKey({"CUE_FILIAL","CUE_ID"})

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

Local oModel   := FwLoadModel("TAFA299")
Local oStruCUE := FwFormStruct(2,"CUE")
Local oView    := FwFormView():New()

oView:SetModel(oModel)
oView:AddField("VIEW_CUE",oStruCUE,"MODEL_CUE")

oView:EnableTitleView("VIEW_CUE",STR0001) //"Grupos de Rendimento"
oView:CreateHorizontalBox("FIELDSCUE",100)
oView:SetOwnerView("VIEW_CUE","FIELDSCUE")

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
	aAdd( aHeader, "CUE_FILIAL" )
	aAdd( aHeader, "CUE_ID" )
	aAdd( aHeader, "CUE_CODIGO" )
	aAdd( aHeader, "CUE_DESCRI" )
	aAdd( aHeader, "CUE_VALIDA" )

	aAdd( aBody, { "", "000001", "01", "RENDIMENTOS DO TRABALHO", "" } )
	aAdd( aBody, { "", "000002", "02", "RENDIMENTOS DE CAPITAL", "" } )
	aAdd( aBody, { "", "000003", "03", "OUTROS RENDIMENTOS", "" } )
	aAdd( aBody, { "", "000004", "04", "RENDIMENTOS DE RESIDENTES OU DOMICILIADOS NO EXTERIOR", "" } )

	aAdd( aRet, { aHeader, aBody } )
EndIf

Return( aRet )