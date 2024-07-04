#INCLUDE "JURA156.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA156
Tipo de Solicitação

@author Jorge Luis Branco Martins Junior
@since 23/08/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA156()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NYA" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NYA" )
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
@since 23/08/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"           , 0, 1, 0, .T. } ) //"Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA156"   , 0, 2, 0, NIL } ) //"Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA156"   , 0, 3, 0, NIL } ) //"Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA156"   , 0, 4, 0, NIL } ) //"Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA156"   , 0, 5, 0, NIL } ) //"Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA156"   , 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Tipo de Solicitação

@author Jorge Luis Branco Martins Junior
@since 23/08/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA156" )
Local oStruct := FWFormStruct( 2, "NYA" )

JurSetAgrp( 'NYA',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA156_VIEW", oStruct, "NYAMASTER"  )
oView:CreateHorizontalBox( "FORMFIELD", 100 )
oView:SetOwnerView( "JURA156_VIEW", "FORMFIELD" )
oView:SetDescription( STR0007 ) //"Tipo de Solicitação"
oView:EnableControlBar( .T. )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Tipo de Solicitação

@author Jorge Luis Branco Martins Junior
@since 23/08/13
@version 1.0

@obs  NYAMASTER -- Dados do Tipo de Solicitação

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructNYA := FWFormStruct( 1, "NYA" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA156", /*Pre-Validacao*/, /*Pos-Validacao*/, {|oX|JA156Commit(oX)}/*Commit*/,/*Cancel*/)
oModel:AddFields( "NYAMASTER", NIL, oStructNYA, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 ) //"Modelo de Dados de Tipo de Solicitação"
oModel:GetModel( "NYAMASTER" ):SetDescription( STR0009 ) //"Dados de Tipo de Solicitação"

JurSetRules( oModel, 'NYAMASTER',, 'NYA' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA156Commit
Commit de dados de Tipo de Solicitação

@author Jorge Luis Branco Martins Junior
@since 23/08/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA156Commit(oModel)
Local lRet := .T.
Local cCod := oModel:GetValue("NYAMASTER","NYA_COD")
Local nOpc := oModel:GetOperation()

	FWFormCommit(oModel)
  
	If nOpc == 3
		lRet := JurSetRest('NYA',cCod)
	EndIf

Return lRet