#INCLUDE "JURA212.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA212
Causa Raiz com Classificação

@author Rafael Tenorio da Costa
@since 07/12/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA212()

	Local oBrowse
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetDescription( STR0007 )
	oBrowse:SetAlias( "O04" )
	oBrowse:SetLocate()
	JurSetLeg( oBrowse, "O04" )
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
	aAdd( aRotina, { STR0002, "VIEWDEF.JURA212", 0, 2, 0, NIL } ) //"Visualizar"
	aAdd( aRotina, { STR0003, "VIEWDEF.JURA212", 0, 3, 0, NIL } ) //"Incluir"
	aAdd( aRotina, { STR0004, "VIEWDEF.JURA212", 0, 4, 0, NIL } ) //"Alterar"
	aAdd( aRotina, { STR0005, "VIEWDEF.JURA212", 0, 5, 0, NIL } ) //"Excluir"
	aAdd( aRotina, { STR0006, "VIEWDEF.JURA212", 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Causa Raiz

@author Rafael Tenorio da Costa
@since 07/12/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oView
	Local oModel  	 := FWLoadModel( "JURA212" )
	Local oStructO04 := FWFormStruct( 2, "O04" )
	Local oStructO0A := Nil
	Local lExisteO0A := FWAliasInDic("O0A")
	
	JurSetAgrp( 'O04',, oStructO04 )
	
	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:SetDescription( STR0007 )		//"Causa Raiz"
	
	oView:AddField( "JURA212_FIELD", oStructO04, "O04MASTER"  )
	oView:CreateHorizontalBox( "FORMFIELD", IIF(lExisteO0A, 50, 100) )
	oView:SetOwnerView( "JURA212_FIELD", "FORMFIELD" )
	oView:EnableTitleView( "JURA212_FIELD"  )
	
	If lExisteO0A
		oStructO0A := FWFormStruct( 2, "O0A" )
		oStructO0A:RemoveField( "O0A_CCAUSA" )
		
		oView:AddGrid( "JURA212_DETAIL", oStructO0A, "O0ADETAIL" )
		oView:CreateHorizontalBox( "FORMDETAIL", 50 )
		oView:AddIncrementField( "O0ADETAIL", "O0A_COD" )
		oView:SetOwnerView( "JURA212_DETAIL", "FORMDETAIL")
		oView:EnableTitleView( "JURA212_DETAIL" )
	EndIf
	
	oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Causa Raiz

@author Rafael Tenorio da Costa
@since 07/12/16
@version 1.0

@obs O04MASTER - Dados do Causa Raiz
/*/
//-------------------------------------------------------------------
Static Function Modeldef()

	Local oModel     := NIL
	Local oStructO04 := FWFormStruct( 1, "O04" )
	Local oStructO0A := Nil
	
	//-----------------------------------------
	//Monta o modelo do formulário
	//-----------------------------------------
	oModel:= MPFormModel():New( "JURA212", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/, /*Cancel*/)
	oModel:SetDescription( STR0008 )		//"Modelo de Dados de Causa Raiz"
	
	oModel:AddFields( "O04MASTER", NIL, oStructO04, /*Pre-Validacao*/, /*Pos-Validacao*/ )
	oModel:GetModel( "O04MASTER" ):SetDescription( STR0009 ) 	//"Dados de Causa Raiz"
	JurSetRules( oModel, 'O04MASTER',, 'O04' )
	
	If FWAliasInDic("O0A")
		oStructO0A := FWFormStruct( 1, "O0A" )
		
		oModel:AddGrid("O0ADETAIL", "O04MASTER", oStructO0A, /*bLinePre*/, /*bLinePos*/, /*bPre*/, /*bPost*/)
		oModel:GetModel("O0ADETAIL"):SetDescription(STR0010)		//"Dados da Classificação da Causa Raiz"
		oModel:SetRelation("O0ADETAIL", { {"O0A_FILIAL", "XFILIAL('O0A')"}, {"O0A_CCAUSA", "O04_COD"} }, O0A->( IndexKey(1) ) )		//O0A_FILIAL+O0A_CCAUSA+O0A_COD
		oModel:GetModel("O0ADETAIL"):SetUniqueLine( {"O0A_DESC"} )
		oModel:SetOptional("O0ADETAIL", .T.)
	EndIf

Return oModel