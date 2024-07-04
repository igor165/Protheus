#INCLUDE "JURA053.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE "PARMTYPE.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} JURA053
Composição do Titulo do Caso

@author Clóvis Eduardo Teixeira
@since 09/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA053()
Local oBrowse
NRQ->(dbSetOrder(2))
oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NRQ" )
oBrowse:SetLocate()

oBrowse:Activate()

NRQ->(dbSetOrder(1))
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
@since 18/02/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA053", 0, 2, 0, NIL } ) //"Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA053", 0, 3, 0, NIL } ) //"Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA053", 0, 4, 0, NIL } ) //"Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA053", 0, 5, 0, NIL } ) //"Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA053", 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Motivo Encerramento

@author Clóvis Eduardo Teixeira
@since 23/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA053" )
Local oStruct := FWFormStruct( 2, "NRQ" )

JurSetAgrp( 'NRQ',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA053_VIEW", oStruct, "NRQMASTER"  )
oView:CreateHorizontalBox( "FORMFIELD", 100 )
oView:SetOwnerView( "JURA053_VIEW", "FORMFIELD" )
oView:SetDescription( STR0007 ) //"Composição do Titulo do Caso"
oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Motivo Encerramento

@author Clóvis Eduardo Teixeira
@since 23/04/09
@version 1.0
@obs NRQMASTER - Dados Composição do Titulo do Caso

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructNRQ := FWFormStruct( 1, "NRQ" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA053", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "NRQMASTER", NIL, oStructNRQ, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 ) //"Modelo de Dados Composição do Titulo do Caso"
oModel:GetModel( "NRQMASTER" ):SetDescription( STR0009 ) //"Dados Composição do Titulo do Caso"

JurSetRules( oModel, 'NRQMASTER',, 'NRQ' )

Return oModel    