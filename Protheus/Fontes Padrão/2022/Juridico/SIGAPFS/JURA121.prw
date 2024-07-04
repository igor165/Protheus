#INCLUDE "JURA121.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA121
Moedas Bloqueadas P Fatura

@author David Gonçalves Fernandes
@since 05/06/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA121()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NTN" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NTN" )
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

@author David Gonçalves Fernandes
@since 05/06/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA121", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA121", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA121", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA121", 0, 5, 0, NIL } ) // "Excluir"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Moedas Bloqueadas P Fatura

@author David Gonçalves Fernandes
@since 05/06/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA121" )
Local oStruct := FWFormStruct( 2, "NTN" )

JurSetAgrp( 'NTN',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA121_VIEW", oStruct, "NTNMASTER"  )
oView:CreateHorizontalBox( "FORMFIELD", 100 )
oView:SetOwnerView( "JURA121_VIEW", "FORMFIELD" )
oView:SetDescription( STR0007 ) // "Moedas Bloqueadas P Fatura"
oView:EnableControlBar( .T. )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Moedas Bloqueadas P Fatura

@author David Gonçalves Fernandes
@since 05/06/09
@version 1.0

@obs NTNMASTER - Dados do Moedas Bloqueadas P Fatura

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStruct    := FWFormStruct( 1, "NTN" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA121", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "NTNMASTER", NIL, oStruct, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 ) // "Modelo de Dados de Moedas Bloqueadas P Fatura"
oModel:GetModel( "NTNMASTER" ):SetDescription( STR0009 ) // "Dados de Moedas Bloqueadas P Fatura"
JurSetRules( oModel, "NTNMASTER",, "NTN",, "JURA121" )

Return oModel
