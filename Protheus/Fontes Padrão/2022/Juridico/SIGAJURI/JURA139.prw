#INCLUDE "JURA139.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA139
Critério de Julgamento

@author Clóvis Eduardo Teixeira
@since 23/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA139()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NY5" )
oBrowse:SetLocate()

JurSetLeg( oBrowse, "NY5" )
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

@author Clóvis Eduardo Teixeira
@since 23/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA139", 0, 2, 0, NIL } ) //"Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA139", 0, 3, 0, NIL } ) //"Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA139", 0, 4, 0, NIL } ) //"Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA139", 0, 5, 0, NIL } ) //"Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA139", 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Critério de Julgamento

@author Clóvis Eduardo Teixeira
@since 23/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA139" )
Local oStruct := FWFormStruct( 2, "NY5" )

JurSetAgrp( 'NY5',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA139_VIEW", oStruct, "NY5MASTER"  )
oView:CreateHorizontalBox( "FORMFIELD", 100 )
oView:SetOwnerView( "JURA139_VIEW", "FORMFIELD" )
oView:SetDescription( STR0007 ) //"Critério de Julgamento"
oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Critério de Julgamento

@author Clóvis Eduardo Teixeira
@since 23/04/09
@version 1.0

@obs NY5MASTER - Dados do Critério de Julgamento

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructNY5 := FWFormStruct( 1, "NY5" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA139", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "NY5MASTER", NIL, oStructNY5, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 ) //"Modelo de Dados de Critério de Julgamento"
oModel:GetModel( "NY5MASTER" ):SetDescription( STR0009 ) //"Dados de Critério de Julgamento"

JurSetRules( oModel, 'NY5MASTER',, 'NY5' )

Return oModel