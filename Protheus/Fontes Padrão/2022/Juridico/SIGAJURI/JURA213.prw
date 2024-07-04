#INCLUDE "JURA213.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA213
Tipo de Contrato
@author André Spirigoni Pinto
@since 09/03/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA213()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0001 ) //"Agrupadores Kurier"
oBrowse:SetAlias( "NZP" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NZP" )
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

@author André Spirigoni Pinto
@since 09/03/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0002, "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA213", 0, 2, 0, NIL } ) //"Visualizar"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA213", 0, 3, 0, NIL } ) //"Incluir"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA213", 0, 4, 0, NIL } ) //"Alterar"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA213", 0, 5, 0, NIL } ) //"Excluir"
aAdd( aRotina, { STR0007, "VIEWDEF.JURA213", 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Tipo de Contrato

@author André Spirigoni Pinto
@since 09/03/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA213" )
Local oStructNZP := FWFormStruct( 2, "NZP" )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA213", oStructNZP, "NZPMASTER"  )
oView:CreateHorizontalBox( "NZPMASTER" , 100 )
oView:SetOwnerView( "JURA213", "NZPMASTER" )

oView:SetDescription( STR0001 )  //"Agrupadores Kurier"
oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Tipo de Contrato

@author André Spirigoni Pinto
@since 09/03/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructNZP := FWFormStruct( 1, "NZP" )
//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA213", /*Pre-Validacao*/, /*Pos-Validacao*/,/*Commit*/,/*Cancel*/)
oModel:AddFields( "NZPMASTER", NIL, oStructNZP, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 )  //"Modelo de Agrupadores Kurier"

oModel:GetModel( "NZPMASTER" ):SetDescription( STR0009 ) //"Dados de Agrupadores Kurier"

//JurSetRules( oModel, "NZPMASTER",, "NZP" )

Return oModel