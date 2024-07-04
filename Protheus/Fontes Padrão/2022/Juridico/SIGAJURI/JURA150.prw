#INCLUDE "JURA150.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA150
Situação de Marca

@author Clóvis Eduardo Teixeira
@since 23/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA150()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NY7" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NY7" )
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
aAdd( aRotina, { STR0002, "VIEWDEF.JURA150", 0, 2, 0, NIL } ) //"Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA150", 0, 3, 0, NIL } ) //"Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA150", 0, 4, 0, NIL } ) //"Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA150", 0, 5, 0, NIL } ) //"Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA150", 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Situação da Marca

@author Clóvis Eduardo Teixeira
@since 23/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA150" )
Local oStruct := FWFormStruct( 2, "NY7" )

JurSetAgrp( 'NY7',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA150_VIEW", oStruct, "NY7MASTER"  )
oView:CreateHorizontalBox( "FORMFIELD", 100 )
oView:SetOwnerView( "JURA150_VIEW", "FORMFIELD" )
oView:SetDescription( STR0007 ) //"Situação da Marca"
oView:EnableControlBar( .T. )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Situação da Marca

@author Clóvis Eduardo Teixeira
@since 23/04/09
@version 1.0

@obs NY7MASTER - Dados do Situação da Marca

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructNY7 := FWFormStruct( 1, "NY7" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA150", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "NY7MASTER", NIL, oStructNY7, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 ) //"Modelo de Dados de Situação da Marca"
oModel:GetModel( "NY7MASTER" ):SetDescription( STR0009 ) //"Dados de Situação da Marca"

JurSetRules( oModel, 'NY7MASTER',, 'NY7' )

Return oModel