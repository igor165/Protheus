#INCLUDE "JURA072.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA072
Retificação de Time Sheet

@author David Gonçalves Fernandes
@since 12/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA072()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NSB" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NSB" )
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
@since 12/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA072", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA072", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA072", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA072", 0, 5, 0, NIL } ) // "Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA072", 0, 8, 0, NIL } ) // "Imprimir"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Retificação de Time Sheet

@author David Gonçalves Fernandes
@since 12/05/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA072" )
Local oStruct := FWFormStruct( 2, "NSB" )

JurSetAgrp( 'NSB',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA072_VIEW", oStruct, "NSBMASTER"  )
oView:CreateHorizontalBox( "FORMFIELD", 100 )
oView:SetOwnerView( "JURA072_VIEW", "FORMFIELD" )
oView:SetDescription( STR0007 ) // "Retificação de Time Sheet"
oView:EnableControlBar( .T. )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Retificação de Time Sheet

@author David Gonçalves Fernandes
@since 12/05/09
@version 1.0

@obs NSBMASTER - Dados do Retificação de Time Sheet

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStruct    := FWFormStruct( 1, "NSB" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA072", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "NSBMASTER", NIL, oStruct, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 ) // "Modelo de Dados de Retificação de Time Sheet"
oModel:GetModel( "NSBMASTER" ):SetDescription( STR0009 ) // "Dados de Retificação de Time Sheet"

JurSetRules( oModel, 'NSBMASTER',, 'NSB' )

Return oModel
