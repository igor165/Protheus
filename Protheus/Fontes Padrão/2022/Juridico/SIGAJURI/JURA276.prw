#Include "JURA276.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA276
Modelos de Exportação Personalizada

@since 23/06/2020
/*/
//-------------------------------------------------------------------
Function JURA276()

Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0001 ) //"Modelos de Exportação Personalizada"
oBrowse:SetAlias( "NQ5" )
oBrowse:SetMenuDef('JURA276')
oBrowse:SetLocate()
JurSetBSize( oBrowse )

oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
@since 23/06/2020
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0002, "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA276", 0, 2, 0, NIL } ) //"Visualizar"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA276", 0, 3, 0, NIL } ) //"Incluir"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA276", 0, 4, 0, NIL } ) //"Alterar"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA276", 0, 5, 0, NIL } ) //"Excluir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados 

@since 23/06/2020
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructNQ5 := FWFormStruct( 1, "NQ5" )
Local oStructNQ8 := FWFormStruct( 1, "NQ8" )
Local lTLegal    := JModRst()

	oModel:= MPFormModel():New( "JURA276", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
	oModel:SetDescription( STR0007 ) // "Modelo de Dados de Exportação Personalizada"
	oModel:AddFields( "NQ5MASTER", NIL, oStructNQ5, /*Pre-Validacao*/, /*Pos-Validacao*/ )

	//-- Grid dos campos da configuração do modelo de Exportação
	oModel:AddGrid( "NQ8DETAIL", "NQ5MASTER" /*cOwner*/, oStructNQ8, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/,)
	oModel:GetModel( "NQ8DETAIL" ):SetUniqueLine( { "NQ8_CCONFG", "NQ8_CAMPO", "NQ8_APE1NV", "NQ8_APE2NV", "NQ8_FILTRO" } )  // Não permite duplicação de campo
	oModel:SetRelation( "NQ8DETAIL", { { "NQ8_FILIAL", "xFilial('NQ8')" }, { "NQ8_CCONFG", "NQ5_COD" } }, NQ8->( IndexKey( 1 ) ) )
	oModel:SetOptional( 'NQ8DETAIL' , .T. )

	oStructNQ5:SetProperty('NQ5_USER', MODEL_FIELD_INIT,{|| __cUserID})

	oStructNQ8:SetProperty('NQ8_CCONFG', MODEL_FIELD_INIT, {|oMdl| oMdl:GetModel():GetModel('NQ5MASTER'):GetValue('NQ5_COD')})
	oStructNQ8:SetProperty("NQ8_TAB1NV",MODEL_FIELD_OBRIGAT,.F.)
	oStructNQ8:SetProperty("NQ8_TAB2NV",MODEL_FIELD_OBRIGAT,.F.)
	oStructNQ8:SetProperty("NQ8_APE2NV",MODEL_FIELD_OBRIGAT,.F.)
	If lTLegal
		oStructNQ8:SetProperty('NQ8_ORDEM', MODEL_FIELD_INIT,{|oMdl| GetSxEnum('NQ8','NQ8_ORDEM',  cEmpAnt + cFilAnt +oMdl:GetModel():GetModel('NQ5MASTER'):GetValue('NQ5_COD') )})
	EndIf
	

	JurSetRules( oModel, 'NQ5MASTER',, 'NQ5' )

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função responsavel pela definição da view
@type Static Function
@author 
@since 18/11/2020
@version 1.0
@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
Local oView   := FWFormView():New()
Local oModel  := FwLoadModel('JURA276')
Local oStructNQ5 := FWFormStruct(2, 'NQ5')
Local oStructNQ8 := FWFormStruct(2, 'NQ8')

oView:SetModel(oModel)

oView:AddField('VIEW_NQ5',oStructNQ5,'NQ5MASTER')
oView:AddGrid('VIEW_NQ8' ,oStructNQ8,'NQ8DETAIL')

oView:CreateHorizontalBox('BOX_NQ5', 50 )
oView:CreateHorizontalBox('BOX_NQ8', 50 )

oView:SetOwnerView('VIEW_NQ5' ,'BOX_NQ5' )
oView:SetOwnerView('VIEW_NQ8' ,'BOX_NQ8' )


oView:AddIncrementField("NQ8DETAIL", "NQ8_ORDEM")

oView:SetDescription(STR0001) //'Rotinas Customizadas'

Return oView

