#INCLUDE "JURA152.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA152
Tipo documento Juridico

@author Raphael Zei Cartaxo Silva
@since 01/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA152()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NUL" )
oBrowse:SetLocate()
//oBrowse:DisableDetails()
JurSetLeg( oBrowse, "NUL" )
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

@author Raphael Zei Cartaxo Silva
@since 01/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) // "Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA152", 0, 2, 0, NIL } ) // "Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA152", 0, 3, 0, NIL } ) // "Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA152", 0, 4, 0, NIL } ) // "Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA152", 0, 5, 0, NIL } ) // "Excluir"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Tipo documento Juridico

@author Raphael Zei Cartaxo Silva
@since 01/07/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA152" )
Local oStruct := FWFormStruct( 2, "NUL" )

JurSetAgrp( 'NUL',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA152_VIEW", oStruct, "NULMASTER"  )
oView:CreateHorizontalBox( "FORMFIELD", 100 )
oView:SetOwnerView( "JURA152_VIEW", "FORMFIELD" )
oView:SetDescription( STR0007 ) // "Tipo documento Juridico"
oView:EnableControlBar( .T. )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Tipo documento Juridico

@author Raphael Zei Cartaxo Silva
@since 01/07/09
@version 1.0

@obs NULMASTER - Dados do Tipo documento Juridico

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStruct    := FWFormStruct( 1, "NUL" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA152", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "NULMASTER", NIL, oStruct, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 ) // "Modelo de Dados de Tipo documento Juridico"
oModel:GetModel( "NULMASTER" ):SetDescription( STR0009 ) // "Dados de Tipo documento Juridico"
JurSetRules( oModel, "NULMASTER",, "NUL",, "JURA152" )

Return oModel
