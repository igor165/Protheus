#INCLUDE "JURA199.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA199
Base da Decisão

@author Rafael Tenorio da Costa
@since 07/12/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA199()

	Local oBrowse
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription( STR0007 )
	oBrowse:SetAlias( "O03" )
	oBrowse:SetLocate()
	JurSetLeg( oBrowse, "O03" )
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

@author Rafael Tenorio da Costa
@since 07/12/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}
	
	aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0002, "VIEWDEF.JURA199", 0, 2, 0, NIL } ) //"Visualizar"
	aAdd( aRotina, { STR0003, "VIEWDEF.JURA199", 0, 3, 0, NIL } ) //"Incluir"
	aAdd( aRotina, { STR0004, "VIEWDEF.JURA199", 0, 4, 0, NIL } ) //"Alterar"
	aAdd( aRotina, { STR0005, "VIEWDEF.JURA199", 0, 5, 0, NIL } ) //"Excluir"
	aAdd( aRotina, { STR0006, "VIEWDEF.JURA199", 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Base da Decisão

@author Rafael Tenorio da Costa
@since 07/12/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oView
	Local oModel  := FWLoadModel( "JURA199" )
	Local oStruct := FWFormStruct( 2, "O03" )
	
	JurSetAgrp( 'O03',, oStruct )
	
	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( "JURA199_VIEW", oStruct, "O03MASTER"  )
	oView:CreateHorizontalBox( "FORMFIELD", 100 )
	oView:SetOwnerView( "JURA199_VIEW", "FORMFIELD" )
	oView:SetDescription( STR0007 ) 					//"Base da Decisão"
	oView:EnableControlBar( .T. )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Base da Decisão

@author Rafael Tenorio da Costa
@since 07/12/16
@version 1.0

@obs O03MASTER - Dados do Base da Decisão
/*/
//-------------------------------------------------------------------
Static Function Modeldef()

	Local oModel     := NIL
	Local oStructO03 := FWFormStruct( 1, "O03" )
	
	//-----------------------------------------
	//Monta o modelo do formulário
	//-----------------------------------------
	oModel:= MPFormModel():New( "JURA199", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/, /*Cancel*/)
	oModel:AddFields( "O03MASTER", NIL, oStructO03, /*Pre-Validacao*/, /*Pos-Validacao*/ )
	oModel:SetDescription( STR0008 ) 							//"Modelo de Dados de Base da Decisão"
	oModel:GetModel( "O03MASTER" ):SetDescription( STR0009 ) 	//"Dados de Base da Decisão"
	
	JurSetRules( oModel, 'O03MASTER',, 'O03' )

Return oModel