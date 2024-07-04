#INCLUDE "JURA155.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA155
Área de Negócio

@author Jorge Luis Branco Martins Junior
@since 23/08/13
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA155()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NY9" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NY9" )
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
@since 23/08/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"						, 0, 1, 0, .T. } ) //"Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA155"	, 0, 2, 0, NIL } ) //"Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA155"	, 0, 3, 0, NIL } ) //"Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA155"	, 0, 4, 0, NIL } ) //"Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA155"	, 0, 5, 0, NIL } ) //"Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA155"	, 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Área de Negócio

@author Jorge Luis Branco Martins Junior
@since 23/04/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA155" )
Local oStruct := FWFormStruct( 2, "NY9" )

JurSetAgrp( 'NY9',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA155_VIEW", oStruct, "NY9MASTER"  )
oView:CreateHorizontalBox( "FORMFIELD", 100 )
oView:SetOwnerView( "JURA155_VIEW", "FORMFIELD" )
oView:SetDescription( STR0007 ) //"Área de Negócio"
oView:EnableControlBar( .T. )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Área de Negócio

@author Jorge Luis Branco Martins Junior
@since 23/08/13
@version 1.0

@obs NY9MASTER - Dados do Área de Negócio

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructNY9 := FWFormStruct( 1, "NY9" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA155", /*Pre-Validacao*/, /*Pos-Validacao*/, {|oX|JA155Commit(oX)}/*Commit*/,/*Cancel*/)
oModel:AddFields( "NY9MASTER", NIL, oStructNY9, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 ) //"Modelo de Dados de Área de Negócio"
oModel:GetModel( "NY9MASTER" ):SetDescription( STR0009 ) //"Dados de Área de Negócio"

JurSetRules( oModel, 'NY9MASTER',, 'NY9' )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA155Commit
Commit de dados de Área de Negócio

@author Jorge Luis Branco Martins Junior
@since 23/08/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA155Commit(oModel)
Local lRet := .T.
Local cCod := oModel:GetValue("NY9MASTER","NY9_COD")
Local nOpc := oModel:GetOperation()

	FWFormCommit(oModel)
  
	If nOpc == 3
		lRet := JurSetRest('NY9',cCod)
	EndIf

Return lRet