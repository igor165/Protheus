#INCLUDE "mata964.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} MATA964 Ajustes Manuais da Apuracao de ICMS

@author Flavio Luiz Vicco
@since 09/07/2018
@version 1.00
/*/
//-------------------------------------------------------------------
Function MATA964()
Local oBrowse := Nil

oBrowse:=FWMBrowse():New()
oBrowse:SetAlias("CDO")
oBrowse:SetDescription(STR0001) //"Cadastro de lançamentos manuais da Apuração de ICMS"
oBrowse:Activate()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@return aRotina - Array com as opcoes de menu

@author Flavio Luiz Vicco
@since 09/07/2018
@version 1.00
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Private aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION "PesqBrw"         OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.MATA964" OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.MATA964" OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.MATA964" OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.MATA964" OPERATION 5 ACCESS 0 //"Excluir"

If ExistBlock("MA964MNU")
	ExecBlock("MA964MNU",.F.,.F.)
EndIf

Return(aRotina)

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Flavio Luiz Vicco
@since 09/07/2018
@version 1.00
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel := Nil
Local oStruCDO := FWFormStruct(1,"CDO")

oModel:=MpFormModel():New("MATA964")
oModel:AddFields("MODEL_CDO",,oStruCDO,)
oModel:SetPrimaryKey({ "CDO_CODAJU" })
oModel:SetDescription(STR0001) //"Cadastro de lancamentos da Apuracao de ICMS"

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Flavio Luiz Vicco
@since 09/07/2018
@version 1.00
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView    := FWFormView():New()
Local oModel   := FwLoadModel("MATA964")
Local oStruCDO := FWFormStruct(2,"CDO")

oView:SetModel(oModel)
oView:AddField("VIEW_CAB", oStruCDO, "MODEL_CDO")

oView:CreateHorizontalBox("FORMFIELD", 	100)
oView:SetOwnerView("VIEW_CAB", "FORMFIELD")

Return oView
