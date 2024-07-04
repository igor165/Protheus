#INCLUDE "JURA004.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA004
Assunto

@author Claudio Donizete de Souza
@since 10/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA004()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0001 ) //"Assunto"
oBrowse:SetAlias( "NQ4" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NQ4" )
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

@author Claudio Donizete de Souza
@since 10/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0002, "PesqBrw"        , 0, 1, 0, .T. } )  //"Pesquisar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA004", 0, 2, 0, NIL } ) //"Visualizar"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA004", 0, 3, 0, NIL } ) //"Incluir"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA004", 0, 4, 0, NIL } ) //"Alterar"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA004", 0, 5, 0, NIL } ) //"Excluir"
aAdd( aRotina, { STR0007, "VIEWDEF.JURA004", 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Objeto Jurídico

@author Claudio Donizete de Souza
@since 10/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA004" )
Local oStructNQ4 := FWFormStruct( 2, "NQ4" )

JurSetAgrp( "NQ4",, oStructNQ4 )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA004_NQ4", oStructNQ4, "NQ4MASTER"  )
oView:CreateHorizontalBox( "NQ4MASTER" , 100 )
oView:SetOwnerView( "JURA004_NQ4", "NQ4MASTER" )

oView:SetDescription( STR0001 )  //"Assunto"
oView:EnableControlBar( .T. )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Objeto Jurídico

@author Claudio Donizete de Souza
@since 10/10/09
@version 1.0

@obs NQ4MASTER - Dados do Objeto Jurídico

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructNQ4 := FWFormStruct( 1, "NQ4" )
//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA004", /*Pre-Validacao*/, /*Pos-Validacao*/, {|oX|JA004Commit(oX)}/*Commit*/,/*Cancel*/)
oModel:AddFields( "NQ4MASTER", NIL, oStructNQ4, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 )  //"Modelo de Dados do Assunto"

oModel:GetModel( "NQ4MASTER" ):SetDescription( STR0009 ) //"Dados do Assunto"

JurSetRules( oModel, "NQ4MASTER",, "NQ4" )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA004Commit
Commit de dados de Objeto Jurídico

@author Jorge Luis Branco Martins Junior
@since 16/08/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA004Commit(oModel)
Local lRet := .T.
Local cCod := oModel:GetValue("NQ4MASTER","NQ4_COD")
Local nOpc := oModel:GetOperation()

	FWFormCommit(oModel)
  
	If nOpc == 3
		lRet := JurSetRest('NQ4',cCod)
	EndIf
	
	If nOpc == 5
		JUREXCRESTR("NQ4", cCod) //Faz a exclusão do cadastro de restrição
	EndIf

Return lRet
