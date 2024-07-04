#INCLUDE "JURA198.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA198
Fundamento Prognóstico

@author Rafael Tenorio da Costa
@since  08/12/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA198()

	Local oBrowse
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription( STR0007 )	//"Fundamento Prognóstico"
	oBrowse:SetAlias("O02")
	oBrowse:SetLocate()
	JurSetLeg( oBrowse, "O02" )
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
@since 08/12/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}
	
	aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0002, "VIEWDEF.JURA198", 0, 2, 0, NIL } ) //"Visualizar"
	aAdd( aRotina, { STR0003, "VIEWDEF.JURA198", 0, 3, 0, NIL } ) //"Incluir"
	aAdd( aRotina, { STR0004, "VIEWDEF.JURA198", 0, 4, 0, NIL } ) //"Alterar"
	aAdd( aRotina, { STR0005, "VIEWDEF.JURA198", 0, 5, 0, NIL } ) //"Excluir"
	aAdd( aRotina, { STR0006, "VIEWDEF.JURA198", 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Fundamento Prognóstico

@author Rafael Tenorio da Costa
@since  08/12/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel	 := FwLoadModel( "JURA198" )
	Local oStructO02 := Nil
	Local oStructO06 := Nil
	Local oView		 := Nil
	
	//--------------------------------------------------------------
	//Montagem da interface via dicionario de dados
	//--------------------------------------------------------------
	oStructO02 := FWFormStruct( 2, "O02" )
	oStructO06 := FWFormStruct( 2, "O06" )
	
	oStructO06:RemoveField("O06_CFUPRO")
	
	//--------------------------------------------------------------
	//Montagem do View normal se Container
	//--------------------------------------------------------------
	JurSetAgrp( 'O02',, oStructO02 )
	
	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:SetDescription( STR0007 ) //"Fundamento Prognóstico"
	
	oView:AddField( "JURA198_O02MASTER", oStructO02, "O02MASTER" )
	oView:AddGrid(  "JURA198_O06DETAIL", oStructO06, "O06DETAIL" )
	
	oView:CreateHorizontalBox( "FORM_O02MASTER", 40 )
	oView:CreateHorizontalBox( "FORM_O06DETAIL", 60 )
	
	oView:SetOwnerView( "JURA198_O02MASTER" , "FORM_O02MASTER" )
	oView:SetOwnerView( "JURA198_O06DETAIL" , "FORM_O06DETAIL" )
	
	oView:AddIncrementField( "O06DETAIL" , "O06_COD"  )	
	//oView:AddIncrementField( "NQE3NIVEL" , "NQE_COD"  )
	
	oView:EnableTitleView( "JURA198_O02MASTER" )
	oView:EnableTitleView( "JURA198_O06DETAIL" )
	
	oView:SetUseCursor( .T. )
	oView:EnableControlBar(.T.)

Return oView
	
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Fundamento Prognóstico

@author Rafael Tenorio da Costa
@since 08/12/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStructO02 := NIL
Local oStructO06 := NIL
Local oModel	 := NIL

//-----------------------------------------
//Monta a estrutura do formulário com base no dicionário de dados
//-----------------------------------------
oStructO02 := FWFormStruct(1,"O02")
oStructO06 := FWFormStruct(1,"O06")

oStructO06:RemoveField( "O06_CFUPRO" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MpFormModel():New( "JURA198", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/ )
oModel:SetDescription( STR0008 ) //"Modelo de Dados do Fundamento Prognóstico"

oModel:AddFields( "O02MASTER", /*cOwner*/, oStructO02,/*Pre-Validacao*/,/*Pos-Validacao*/)
oModel:GetModel( "O02MASTER" ):SetDescription( STR0007 ) //"Fundamento Prognóstico"

//O06 - Classificação Fundamento
oModel:AddGrid( "O06DETAIL", "O02MASTER" /*cOwner*/, oStructO06, /*bLinePre*/, /*bLinePost*/,/*bPre*/, /*bPost*/ )
oModel:GetModel( "O06DETAIL"  ):SetDescription( STR0009 ) //"Classificação Fundamento"
oModel:SetRelation( "O06DETAIL", { { "O06_FILIAL", "XFILIAL('O06')" }, { "O06_CFUPRO", "O02_COD" } }, O06->( IndexKey( 1 ) ) )

oModel:GetModel( "O06DETAIL" ):SetUniqueLine( { "O06_DESC" } )
//oModel:GetModel( "NQE3NIVEL" ):SetDelAllLine( .T. )     

oModel:SetOptional( "O06DETAIL" , .T. )

JurSetRules( oModel, 'O02MASTER',, 'O02' )
JurSetRules( oModel, 'O06DETAIL',, 'O06' )

//oModel:SetOnDemand()

Return oModel