#INCLUDE "JURA196.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA196
Tipos de Relatorio de Pre-fatura

@author Mauricio Canalle
@since 22/02/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA196()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )   // "Tipos de Relatorio de Pre-fatura"
oBrowse:SetAlias( "NZO" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NZO" )
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
@author Mauricio Canalle
@since 22/02/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA196", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA196", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA196", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA196", 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA196", 0, 8, 0, NIL } ) // "Imprimir"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Tipos de Relatorio Pre-fatura  

@author Mauricio Canalle
@since 22/02/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA196" )
Local oStruct := FWFormStruct( 2, "NZO" )

JurSetAgrp( 'NZO',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA196_VIEW", oStruct, "NZOMASTER"  )
oView:CreateHorizontalBox( "FORMFIELD", 100 )
oView:SetOwnerView( "JURA196_VIEW", "FORMFIELD" )
oView:SetDescription( STR0007 ) // "Tipos de Relatorio de Pre-fatura"
oView:EnableControlBar( .T. )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Tipos de Relatorio de Pre-fatura

@author Mauricio Canalle
@since 22/02/2016
@version 1.0

@obs NZOMASTER - Dados do Tipos de Relatorio pre-fatura 

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStruct    := FWFormStruct( 1, "NZO" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA196", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "NZOMASTER", NIL, oStruct, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 ) // "Modelo de Dados de Tipos de Relatorio de Pre-fatura"
oModel:GetModel( "NZOMASTER" ):SetDescription( STR0009 ) // "Dados de Tipos de Relatorio de Pre-fatura"

JurSetRules( oModel, 'NZOMASTER',, 'NZO' )

Return oModel
