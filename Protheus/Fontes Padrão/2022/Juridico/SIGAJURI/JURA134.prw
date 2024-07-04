#INCLUDE "JURA134.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA134
Tipo de Contrato
@author Jorge Luis Branco Martins Junior
@since 31/10/12
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA134()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0001 ) //"Tipo de Contrato"
oBrowse:SetAlias( "NY0" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NY0" )
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

@author Jorge Luis Branco Martins Junior
@since 31/10/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0002, "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA134", 0, 2, 0, NIL } ) //"Visualizar"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA134", 0, 3, 0, NIL } ) //"Incluir"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA134", 0, 4, 0, NIL } ) //"Alterar"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA134", 0, 5, 0, NIL } ) //"Excluir"
aAdd( aRotina, { STR0007, "VIEWDEF.JURA134", 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Tipo de Contrato

@author Jorge Luis Branco Martins Junior
@since 31/10/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA134" )
Local oStructNY0 := FWFormStruct( 2, "NY0" )

JurSetAgrp( "NY0",, oStructNY0 )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA134", oStructNY0, "NY0MASTER"  )
oView:CreateHorizontalBox( "NY0MASTER" , 100 )
oView:SetOwnerView( "JURA134", "NY0MASTER" )

oView:SetDescription( STR0001 )  //"Tipo de Contrato"
oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Tipo de Contrato

@author Jorge Luis Branco Martins Junior
@since 31/10/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructNY0 := FWFormStruct( 1, "NY0" )
//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA134", /*Pre-Validacao*/, /*Pos-Validacao*/, {|oX|JA134Commit(oX)}/*Commit*/,/*Cancel*/)
oModel:AddFields( "NY0MASTER", NIL, oStructNY0, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 )  //"Modelo de Tipo de Contrato"

oModel:GetModel( "NY0MASTER" ):SetDescription( STR0009 ) //"Dados de Tipo de Contrato"

JurSetRules( oModel, "NY0MASTER",, "NY0" )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA134Commit
Commit de dados de Tipo de Contrato

@author Jorge Luis Branco Martins Junior
@since 31/10/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA134Commit(oModel)
Local lRet := .T.
Local cCod := oModel:GetValue("NY0MASTER","NY0_COD")
Local nOpc := oModel:GetOperation()

	FWFormCommit(oModel)
  
	If nOpc == 3
		lRet := JurSetRest('NY0',cCod)
	EndIf

Return lRet