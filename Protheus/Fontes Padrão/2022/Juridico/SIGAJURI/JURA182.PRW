#INCLUDE "JURA182.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA182
Palavra Chave

@author Jorge Luis Branco Martins Junior
@since 23/05/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA182()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0001 ) //"Palavra Chave"
oBrowse:SetMenuDef('JURA182') 
oBrowse:SetAlias( "NS8" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NS8" )
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
@since 23/05/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0002, "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA182", 0, 2, 0, NIL } ) //"Visualizar"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA182", 0, 3, 0, NIL } ) //"Incluir"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA182", 0, 4, 0, NIL } ) //"Alterar"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA182", 0, 5, 0, NIL } ) //"Excluir"
aAdd( aRotina, { STR0007, "VIEWDEF.JURA182", 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de Dados de Palavra Chave

@author Jorge Luis Branco Martins Junior
@since 23/05/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA182" )
Local oStructNS8 := FWFormStruct( 2, "NS8" )

JurSetAgrp( "NS8",, oStructNS8 )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA182", oStructNS8, "NS8MASTER"  )
oView:CreateHorizontalBox( "NS8MASTER" , 100 )
oView:SetOwnerView( "JURA182", "NS8MASTER" )

oView:SetDescription( STR0001 )  //"Palavra Chave"
oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Palavra Chave

@author Jorge Luis Branco Martins Junior
@since 23/05/14
@version 1.0

@obs NS8MASTER - Dados de Palavra Chave

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructNS8 := FWFormStruct( 1, "NS8" )
//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA182", /*Pre-Validacao*/, /*Pos-Validacao*/, {|oX|JA182Commit(oX)}/*Commit*/,/*Cancel*/)
oModel:AddFields( "NS8MASTER", NIL, oStructNS8, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 )  //"Modelo de Dados de Palavra Chave"

oModel:GetModel( "NS8MASTER" ):SetDescription( STR0009 ) //"Dados de Palavra Chave"

JurSetRules( oModel, "NS8MASTER",, "NS8" )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA182Commit
Commit de dados de Palavra-Chave

@param 	  oModel      Modelo de dados de Palavra Chave

@return 	lRet        Indica que foi feito o cadastro com sucesso

@author Jorge Luis Branco Martins Junior
@since 23/05/14
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA182Commit(oModel)
Local lRet := .T.

	FWFormCommit(oModel)

Return lRet