#INCLUDE "JURA001.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} JURA001
Natureza Juridica

@author Raphael Zei Cartaxo Silva
@since 23/04/09
@version 1.0
/*/
//-------------------------------------------------------------------

Function JURA001()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NQ1" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NQ1" )
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
@since 23/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA001", 0, 2, 0, NIL } ) //"Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA001", 0, 3, 0, NIL } ) //"Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA001", 0, 4, 0, NIL } ) //"Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA001", 0, 5, 0, NIL } ) //"Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA001", 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Natureza Juridica

@author Raphael Zei Cartaxo Silva
@since 23/04/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA001" )
Local oStruct := FWFormStruct( 2, "NQ1" )

JurSetAgrp( 'NQ1',, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA001_VIEW", oStruct, "NQ1MASTER"  )
oView:CreateHorizontalBox( "FORMFIELD", 100 )
oView:SetOwnerView( "JURA001_VIEW", "FORMFIELD" )
oView:SetDescription( STR0007 ) //"Natureza Juridica"
oView:EnableControlBar( .T. )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Natureza Juridica

@author Raphael Zei Cartaxo Silva
@since 23/04/09
@version 1.0

@obs NQ1MASTER - Dados do Natureza Juridica

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructNQ1 := FWFormStruct( 1, "NQ1" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA001", /*Pre-Validacao*/, /*Pos-Validacao*/,{|oX|JA001Commit(oX)} /*Commit*/,/*Cancel*/)
oModel:AddFields( "NQ1MASTER", NIL, oStructNQ1, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 ) //"Modelo de Dados de Natureza Juridica"
oModel:GetModel( "NQ1MASTER" ):SetDescription( STR0009 ) //"Dados de Natureza Juridica"

JurSetRules( oModel, 'NQ1MASTER',, 'NQ1' )

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} JA001Commit
Commit de dados de Natureza Jurídica

@author Jorge Luis Branco Martins Junior
@since 16/08/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA001Commit(oModel)
Local lRet := .T.
Local cCod := oModel:GetValue("NQ1MASTER","NQ1_COD")
Local nOpc := oModel:GetOperation()

	FWFormCommit(oModel)
  
	If nOpc == 3
		lRet := JurSetRest('NQ1',cCod)
	EndIf

Return lRet