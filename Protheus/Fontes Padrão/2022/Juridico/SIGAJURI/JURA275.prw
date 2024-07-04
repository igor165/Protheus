#Include "JURA275.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA275
Campos Contábeis Complementares

@author Cristiane Nishizaka
@since 10/06/2020
/*/
//-------------------------------------------------------------------
Function JURA275()

Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0001 ) //"Campos Contábeis Complementares"
oBrowse:SetAlias( "O11" )
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

@author Cristiane Nishizaka
@since 10/06/2020
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0002 , "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
aAdd( aRotina, { STR0004 , "VIEWDEF.JURA275", 0, 2, 0, NIL } ) //"Visualizar"
aAdd( aRotina, { STR0005 , "VIEWDEF.JURA275", 0, 3, 0, NIL } ) //"Incluir"
aAdd( aRotina, { STR0006 , "VIEWDEF.JURA275", 0, 4, 0, NIL } ) //"Alterar"
aAdd( aRotina, { STR0007 , "VIEWDEF.JURA275", 0, 5, 0, NIL } ) //"Excluir"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados.

@author Cristiane Nishizaka
@since 10/06/2020
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel     := FWLoadModel( "JURA275" )
Local oStructO11 := FWFormStruct( 2, "O11" )

	// Campo virtual
	oStructO11:AddField( ;
	"O11_CCD"          , ; // [01] Campo
	"04"               , ; // [02] Ordem
	STR0008            , ; // [03] Titulo //"Centro Custo"
	STR0009            , ; // [04] Descricao //"Centro de Custo do processo"
	NIL                , ; // [05] Help
	"GET"              , ; // [06] Tipo do campo   COMBO, Get ou CHECK
	"@!"               , ; // [07] Picture
	                   , ; // [08] Bloco de picture Var
	                   , ; // [09] Chave para ser usado no LooKUp
	.T.                , ; // [10] Logico dizendo se o campo pode ser alterado
	'1'                , ; // [11] Chave para ser usado no LooKUp
	'1'                  ) //

	JurSetAgrp( 'O11',, oStructO11 )

	oView := FWFormView():New()
	oView:SetModel( oModel )

	oView:AddField( "JURA275_VIEW", oStructO11, "O11MASTER"  )
	oView:CreateHorizontalBox( "FORMFIELD", 100 )
	oView:SetOwnerView( "JURA275_VIEW", "FORMFIELD" )
	oView:SetDescription( STR0001 ) // "Campos Contábeis Complementares" 
	oView:EnableControlBar( .T. )
	
	oStructO11:RemoveField( "O11_CAJURI" )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados

@author Cristiane Nishizaka
@since 10/06/2020
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructO11 := FWFormStruct( 1, "O11" )

	oStructO11:AddField(;
		STR0008              ,; // [01] Titulo do campo // "Centro Custo"
		""		             ,; // [02] ToolTip do campo
		"O11_CCD"            ,; // [03] Id do Field
		"C"                  ,; // [04] Tipo do campo
		9                    ,; // [05] Tamanho do campo
		0                    ,; // [06] Decimal do campo
		,;                      // [07] Code-block de validação do campo
		{|| .F.}             ,; // [08] Code-block de validação When do campo
		,;                      // [09] Lista de valores permitido do campo
		.F.                  ,; // [10] Indica se o campo tem preenchimento obrigatório   ]
		{|| NSZ->NSZ_CCUSTO} ,; // [11] Bloco de código de inicialização do campo
		,;                      // [12] Indica se trata-se de um campo chave.
		,;                      // [13] Indica se o campo não pode receber valor em uma operação de update.
		.T.)                    // [14] Indica se o campo é virtual.

	//-----------------------------------------
	//Monta o modelo do formulário
	//-----------------------------------------
	oModel:= MPFormModel():New( "JURA275", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
	oModel:AddFields( "O11MASTER", NIL, oStructO11, /*Pre-Validacao*/, /*Pos-Validacao*/ )
	oModel:SetDescription( STR0010 ) // "Modelo de Dados de Campos Contábeis Complementares"
	oModel:GetModel( "O11MASTER" ):SetDescription( STR0011 ) // 'Dados de Campos Contábeis Complementares'

	JurSetRules( oModel, 'O11MASTER',, 'O11' )

Return oModel
