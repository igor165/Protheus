#INCLUDE "JURA242.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} JURA242
Evento Financeiro.

@author bruno.ritter
@since 23/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------

Function JURA242()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 ) //"Evento Financeiro"
oBrowse:SetAlias( "OHC" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "OHC" )
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

@author bruno.ritter
@since 23/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA242", 0, 2, 0, NIL } ) //"Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA242", 0, 3, 0, NIL } ) //"Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA242", 0, 4, 0, NIL } ) //"Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA242", 0, 5, 0, NIL } ) //"Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA242", 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Evento Financeiro

@author bruno.ritter
@since 23/08/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA242" )
Local oStruct := FWFormStruct( 2, "OHC" )

JurSetAgrp( 'OHC',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA242_VIEW", oStruct, "OHCMASTER"  )
oView:CreateHorizontalBox( "FORMFIELD", 100 )
oView:SetOwnerView( "JURA242_VIEW", "FORMFIELD" )
oView:SetDescription( STR0007 ) //"Evento Financeiro"
oView:EnableControlBar( .T. )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Evento Financeiro

@author bruno.ritter
@since 23/08/2017
@version 1.0

@obs OHCMASTER - Dados do Evento Financeiro

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructOHC := FWFormStruct( 1, "OHC" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA242", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "OHCMASTER", NIL, oStructOHC, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 ) //"Modelo de Dados de Evento Financeiro"
oModel:GetModel( "OHCMASTER" ):SetDescription( STR0009 ) //"Dados de Evento Financeiro"

JurSetRules( oModel, 'OHCMASTER',, 'OHC' )

Return oModel
