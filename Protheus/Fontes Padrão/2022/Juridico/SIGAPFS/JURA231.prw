#INCLUDE "JURA231.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} JURA231
Sugestão de Título do Caso.

@author Jorge Luis Branco Martins Junior
@since 16/01/17
@version 1.0
/*/
//-------------------------------------------------------------------

Function JURA231()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "OH2" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "OH2" )
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
@since 16/01/17
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA231", 0, 2, 0, NIL } ) //"Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA231", 0, 3, 0, NIL } ) //"Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA231", 0, 4, 0, NIL } ) //"Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA231", 0, 5, 0, NIL } ) //"Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA231", 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Sugestão de Título do Caso

@author Jorge Luis Branco Martins Junior
@since 16/01/17
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA231" )
Local oStruct := FWFormStruct( 2, "OH2" )

JurSetAgrp( 'OH2',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA231_VIEW", oStruct, "OH2MASTER"  )
oView:CreateHorizontalBox( "FORMFIELD", 100 )
oView:SetOwnerView( "JURA231_VIEW", "FORMFIELD" )
oView:SetDescription( STR0007 ) //"Sugestão de Título do Caso"
oView:EnableControlBar( .T. )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Sugestão de Título do Caso

@author Jorge Luis Branco Martins Junior
@since 16/01/17
@version 1.0

@obs OH2MASTER - Dados do Sugestão de Título do Caso

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructOH2 := FWFormStruct( 1, "OH2" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA231", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "OH2MASTER", NIL, oStructOH2, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 ) //"Modelo de Dados de Sugestão de Título do Caso"
oModel:GetModel( "OH2MASTER" ):SetDescription( STR0009 ) //"Dados de Sugestão de Título do Caso"

JurSetRules( oModel, 'OH2MASTER',, 'OH2' )

Return oModel