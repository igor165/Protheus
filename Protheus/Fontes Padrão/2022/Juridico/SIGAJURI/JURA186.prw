#INCLUDE "JURA186.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA186
Tipos de Serviços

@author Rafael Tenorio da Costa
@since 17/04/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA186()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )	//"Tipos de Serviços"
oBrowse:SetAlias( "NZA" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NZA" )
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

@author Rafael Tenorio da Costa
@since 17/04/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA186", 0, 2, 0, NIL } ) //"Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA186", 0, 3, 0, NIL } ) //"Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA186", 0, 4, 0, NIL } ) //"Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA186", 0, 5, 0, NIL } ) //"Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA186", 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Tipos de Serviços

@author Rafael Tenorio da Costa
@since 17/04/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA186" )
Local oStruct := FWFormStruct( 2, "NZA" )

JurSetAgrp( "NZA",, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA186_VIEW", oStruct, "NZAMASTER"  )
oView:CreateHorizontalBox( "FORMFIELD", 100 )
oView:SetOwnerView( "JURA186_VIEW", "FORMFIELD" )
oView:SetDescription( STR0007 ) 						//"Tipos de Serviços"
oView:EnableControlBar( .T. )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Tipos de Serviços

@author Rafael Tenorio da Costa
@since 17/04/2015
@version 1.0

@obs NZAMASTER - Dados do Tipos de Serviços

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructNZA := FWFormStruct( 1, "NZA" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA186", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/, /*Cancel*/)
oModel:AddFields( "NZAMASTER", NIL, oStructNZA, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 ) 							//"Modelo de Dados de Tipos de Serviços"
oModel:GetModel( "NZAMASTER" ):SetDescription( STR0009 )	//"Dados de Tipos de Serviços"

JurSetRules( oModel, 'NZAMASTER',, "NZA" )

Return oModel