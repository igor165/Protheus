#INCLUDE "JURA013.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA013
Motivo Encerramento

@author Juliana Iwayama Velho
@since 23/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA013()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NQI" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NQI" )
JurSetBSize( oBrowse )
oBrowse:Activate()

Return NIL


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author Juliana Iwayama Velho
@since 23/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA013", 0, 2, 0, NIL } ) //"Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA013", 0, 3, 0, NIL } ) //"Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA013", 0, 4, 0, NIL } ) //"Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA013", 0, 5, 0, NIL } ) //"Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA013", 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Motivo Encerramento

@author Juliana Iwayama Velho
@since 23/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA013" )
Local oStruct := FWFormStruct( 2, "NQI" )

JurSetAgrp( 'NQI',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA013_VIEW", oStruct, "NQIMASTER"  )
oView:CreateHorizontalBox( "FORMFIELD", 100 )
oView:SetOwnerView( "JURA013_VIEW", "FORMFIELD" )
oView:SetDescription( STR0007 ) //"Motivo Encerramento"
oView:EnableControlBar( .T. )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Motivo Encerramento

@author Juliana Iwayama Velho
@since 23/04/09
@version 1.0

@obs NQIMASTER - Dados do Motivo Encerramento

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructNQI := FWFormStruct( 1, "NQI" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA013", /*Pre-Validacao*/, /*Pos-Validacao*/,{|oX|JA013Commit(oX)} /*Commit*/,/*Cancel*/)
oModel:AddFields( "NQIMASTER", NIL, oStructNQI, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 ) //"Modelo de Dados de Motivo Encerramento"
oModel:GetModel( "NQIMASTER" ):SetDescription( STR0009 ) //"Dados de Motivo Encerramento"

JurSetRules( oModel, 'NQIMASTER',, 'NQI' )

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} JA013Commit
Commit de dados de Motivo de encerramento 

@author Jorge Luis Branco Martins Junior
@since 16/08/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA013Commit(oModel)
Local lRet := .T.
Local cCod := oModel:GetValue("NQIMASTER","NQI_COD")
Local nOpc := oModel:GetOperation()

	FWFormCommit(oModel)
  
	If nOpc == 3
		lRet := JurSetRest('NQI',cCod)
	EndIf

Return lRet