#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "JURA259.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA259
Cadastro dos Tipos da Liminar

@author  Rafael Tenorio da Costa
@since 	 20/04/18
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA259()

	Local oBrowse
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription( STR0007 )	//"Tipos da Liminar"
	oBrowse:SetAlias( "O0R" )
	oBrowse:SetLocate()
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

@author  Rafael Tenorio da Costa
@since 	 20/04/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}
	
	aAdd( aRotina, { STR0001, "PesqBrw"        	, 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0002, "VIEWDEF.JURA259"	, 0, 2, 0, NIL } ) //"Visualizar"
	aAdd( aRotina, { STR0003, "VIEWDEF.JURA259"	, 0, 3, 0, NIL } ) //"Incluir"
	aAdd( aRotina, { STR0004, "VIEWDEF.JURA259"	, 0, 4, 0, NIL } ) //"Alterar"
	aAdd( aRotina, { STR0005, "VIEWDEF.JURA259"	, 0, 5, 0, NIL } ) //"Excluir"
	aAdd( aRotina, { STR0006, "VIEWDEF.JURA259"	, 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Base da Decisão

@author  Rafael Tenorio da Costa
@since 	 20/04/18
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oView
	Local oModel  := FWLoadModel( "JURA259" )
	Local oStruct := FWFormStruct( 2, "O0R" )
	
	JurSetAgrp( 'O0R',, oStruct )
	
	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( "JURA259_VIEW", oStruct, "O0RMASTER"  )
	oView:CreateHorizontalBox( "FORMFIELD", 100 )
	oView:SetOwnerView( "JURA259_VIEW", "FORMFIELD" )
	oView:SetDescription( STR0007 ) 					//"Tipos da Liminar"
	oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Base da Decisão

@author  Rafael Tenorio da Costa
@since 	 20/04/18
@version 1.0

@obs O0RMASTER - Tipos da Liminar
/*/
//-------------------------------------------------------------------
Static Function Modeldef()

	Local oModel     := NIL
	Local oStructO0R := FWFormStruct( 1, "O0R" )
	
	//-----------------------------------------
	//Monta o modelo do formulário
	//-----------------------------------------
	oModel:= MPFormModel():New( "JURA259", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/, /*Cancel*/)
	oModel:AddFields( "O0RMASTER", NIL, oStructO0R, /*Pre-Validacao*/, /*Pos-Validacao*/ )
	oModel:SetDescription( STR0008 ) 							//"Modelo de dados dos Tipos da Liminar"
	oModel:GetModel( "O0RMASTER" ):SetDescription( STR0009 ) 	//"Dados dos Tipos da Liminar"
	
	JurSetRules( oModel, 'O0RMASTER', , 'O0R' )

Return oModel