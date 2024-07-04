#INCLUDE "OGA330.ch"
#include "protheus.ch"
#include "fwmvcdef.ch"


/** {Protheus.doc} OGA330
Rotina para cadastro de Contratos Automáticos

@param: 	Nil
@author: 	Equipe TOTVS Agroindustria
@since: 	01/01/2015
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGA330()     
Local oMBrowse := Nil

oMBrowse := FWMBrowse():New()
oMBrowse:SetAlias( "NJR" )
oMBrowse:SetDescription( STR0001 ) //"Contrato Autormatico"
oMBrowse:AddLegend( "NJR_MODELO=='3'", "PINK", STR0002 ) //"Contrato Automatico"
oMBrowse:SetFilterDefault( "NJR_MODELO == '3'" )
oMBrowse:SetMenuDef('OGA330')
oMBrowse:Activate()

Return( )


/** {Protheus.doc} MenuDef
Função que retorna os itens para construção do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Equipe TOTVS Agroindustria
@since: 	01/01/2015
@Uso: 		OGA330 - Entidades
*/
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0003 , "PesqBrw"        		, 0, 1, 0, .T. } ) //"Pesquisar"
aAdd( aRotina, { STR0004, "ViewDef.OGA330"			, 0, 2, 0, Nil } ) //"Visualizar"
//aAdd( aRotina, { "Incluir"   , "ViewDef.OGA330"			, 0, 3, 0, Nil } )
//aAdd( aRotina, { "Alterar"   , "ViewDef.OGA330"			, 0, 4, 0, Nil } )
//aAdd( aRotina, { "Excluir"   , "ViewDef.OGA330"			, 0, 5, 0, Nil } )
aAdd( aRotina, { STR0005  , "ViewDef.OGA330"			, 0, 8, 0, Nil } ) //"Imprimir"

Return( aRotina )


/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Equipe TOTVS Agroindustria
@since: 	01/01/2015
@Uso: 		OGA330 - Pre-Contrato
*/
Static Function ModelDef()
Local oStruNJR	:= FWFormStruct( 1, "NJR" )
Local oStruNN7 	:= FWFormStruct( 1, "NN7" )
Local oStruNKH 	:= FWFormStruct( 1, "NKH" )
Local oStruNNY	:= FWFormStruct( 1, "NNY" )
Local oStruNNG	:= FWFormStruct( 1, "NNG" )
Local oStruNNF 	:= FWFormStruct( 1, "NNF" )
Local oModel 	:= MPFormModel():New( "OGA330" )

oStruNJR:SetProperty( "NJR_MODELO" , MODEL_FIELD_INIT , {| x | x := "3" }  )

oStruNN7:RemoveField( "NN7_CODCTR" )
oStruNKH:RemoveField( "NKH_CODCTR" )
oStruNNY:RemoveField( "NNY_CODCTR" )
oStruNNG:RemoveField( "NNG_CODCTR" )
oStruNNF:RemoveField( "NNF_CODCTR" )

oStruNJR:SetProperty( "*", MODEL_FIELD_OBRIGAT, .f. )
oStruNN7:SetProperty( "*", MODEL_FIELD_OBRIGAT, .f. )
oStruNKH:SetProperty( "*", MODEL_FIELD_OBRIGAT, .f. )
oStruNNY:SetProperty( "*", MODEL_FIELD_OBRIGAT, .f. )
oStruNNG:SetProperty( "*", MODEL_FIELD_OBRIGAT, .f. )
oStruNNF:SetProperty( "*", MODEL_FIELD_OBRIGAT, .f. )

oModel:SetDescription( STR0002 ) //"Contrato Automatico"

oModel:AddFields( "NJRUNICO", Nil, oStruNJR )
oModel:GetModel( "NJRUNICO" ):SetDescription( "Contrato Automatico" )

oModel:AddGrid( "NN7UNICO", "NJRUNICO", oStruNN7 )
oModel:GetModel( "NN7UNICO" ):SetDescription( STR0006 ) //"Dados das Previsões Financeiras"
oModel:GetModel( "NN7UNICO" ):SetUniqueLine( { "NN7_ITEM" } )
oModel:GetModel( "NN7UNICO" ):SetOptional( .t. )
oModel:SetRelation( "NN7UNICO", { { "NN7_FILIAL", "xFilial( 'NN7' )" }, { "NN7_CODCTR", "NJR_CODCTR" } }, NN7->( IndexKey( 1 ) ) )

oModel:AddGrid( "NKHUNICO", "NJRUNICO", oStruNKH )
oModel:GetModel( "NKHUNICO" ):SetDescription( STR0007 ) //"Dados dos Impostos"
oModel:GetModel( "NKHUNICO" ):SetUniqueLine( { "NKH_ITEM" } )
oModel:GetModel( "NKHUNICO" ):SetOptional( .t. )
oModel:SetRelation( "NKHUNICO", { { "NKH_FILIAL", "xFilial( 'NKH' )" }, { "NKH_CODCTR", "NJR_CODCTR" } }, NKH->( IndexKey( 1 ) ) )

oModel:AddGrid( "NNYUNICO", "NJRUNICO", oStruNNY )
oModel:GetModel( "NNYUNICO" ):SetDescription( STR0008 ) //"Dados do Intervalo de Cadência"
oModel:GetModel( "NNYUNICO" ):SetUniqueLine( { "NNY_ITEM" } )
oModel:GetModel( "NNYUNICO" ):SetOptional( .t. )
oModel:SetRelation( "NNYUNICO", { { "NNY_FILIAL", "xFilial( 'NNY' )" }, { "NNY_CODCTR", "NJR_CODCTR" } }, NNY->( IndexKey( 1 ) ) )

oModel:AddGrid( "NNGUNICO", "NJRUNICO", oStruNNG )
oModel:GetModel( "NNGUNICO" ):SetDescription( STR0010 ) //"Dados das Cessões de Credito"
oModel:GetModel( "NNGUNICO" ):SetUniqueLine( { "NNG_ITEM" } )
oModel:GetModel( "NNGUNICO" ):SetOptional( .t. )
oModel:SetRelation( "NNGUNICO", { { "NNG_FILIAL", "xFilial( 'NNG' )" }, { "NNG_CODCTR", "NJR_CODCTR" } }, NNG->( IndexKey( 1 ) ) )

oModel:AddGrid( "NNFUNICO", "NJRUNICO", oStruNNF )
oModel:GetModel( "NNFUNICO" ):SetDescription( STR0011 ) //"Dados das Corretoras"
oModel:GetModel( "NNFUNICO" ):SetUniqueLine( { "NNF_ITEM" } )
oModel:GetModel( "NNFUNICO" ):SetOptional( .t. )
oModel:SetRelation( "NNFUNICO", { { "NNF_FILIAL", "xFilial( 'NNF' )" }, { "NNF_CODCTR", "NJR_CODCTR" } }, NNF->( IndexKey( 1 ) ) )

Return( oModel )


/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina

@param: 	Nil
@return:	oView - View do modelo de dados
@author: 	Equipe TOTVS Agroindustria
@since: 	01/01/2015
@Uso: 		OGA010 - Entidades
*/
Static Function ViewDef()
Local oStruNJR	:= FWFormStruct( 2, "NJR" )
Local oStruNN7	:= FWFormStruct( 2, "NN7" )
Local oStruNKH	:= FWFormStruct( 2, "NKH" )
Local oStruNNY	:= FWFormStruct( 2, "NNY" )
Local oStruNNG	:= FWFormStruct( 2, "NNG" )
Local oStruNNF	:= FWFormStruct( 2, "NNF" )
Local oModel	:= FWLoadModel( "OGA330" )
Local oView		:= FWFormView():New()

oStruNN7:RemoveField( "NN7_CODCTR" )
oStruNKH:RemoveField( "NKH_CODCTR" )
oStruNNY:RemoveField( "NNY_CODCTR" )
oStruNNG:RemoveField( "NNG_CODCTR" )
oStruNNF:RemoveField( "NNF_CODCTR" )

oView:SetModel( oModel )
oView:AddField( "VIEW_NJR", oStruNJR, "NJRUNICO" )
oView:AddGrid( "VIEW_NN7", oStruNN7, "NN7UNICO" )
oView:AddGrid( "VIEW_NKH", oStruNKH, "NKHUNICO" )
oView:AddGrid( "VIEW_NNY", oStruNNY, "NNYUNICO" )
oView:AddGrid( "VIEW_NNG", oStruNNG, "NNGUNICO" )
oView:AddGrid( "VIEW_NNF", oStruNNF, "NNFUNICO" )

oView:AddIncrementField( "VIEW_NN7", "NN7_ITEM" )
oView:AddIncrementField( "VIEW_NKH", "NKH_ITEM" )
oView:AddIncrementField( "VIEW_NNY", "NNY_ITEM" )
oView:AddIncrementField( "VIEW_NNG", "NNG_ITEM" )
oView:AddIncrementField( "VIEW_NNF", "NNF_ITEM" )

oView:CreateHorizontalBox( "SUPERIOR" , 60 )
oView:CreateHorizontalBox( "INFERIOR" , 40 )

oView:CreateFolder( "GRADES", "INFERIOR")
oView:AddSheet( "GRADES", "PASTA01", OemToAnsi( STR0012) ) //"Financeiro"
oView:AddSheet( "GRADES", "PASTA02", OemToAnsi( STR0013) ) //"Impostos"
oView:AddSheet( "GRADES", "PASTA03", OemToAnsi( STR0014) ) //"Cadência"
oView:AddSheet( "GRADES", "PASTA04", OemToAnsi( STR0015) ) //"Cessão de Crédito"
oView:AddSheet( "GRADES", "PASTA05", OemToAnsi( STR0016) ) //"Corretoras"
oView:AddSheet( "GRADES", "PASTA06", OemToAnsi( STR0017) ) //"Despesas"

oView:CreateHorizontalBox( "PASTA_NN7", 100, , , "GRADES", "PASTA01" )
oView:CreateHorizontalBox( "PASTA_NKH", 100, , , "GRADES", "PASTA02" )
oView:CreateHorizontalBox( "PASTA_NNY", 100, , , "GRADES", "PASTA03" )
oView:CreateHorizontalBox( "PASTA_NNG", 100, , , "GRADES", "PASTA04" )
oView:CreateHorizontalBox( "PASTA_NNF", 100, , , "GRADES", "PASTA05" )

oView:SetOwnerView( "VIEW_NJR", "SUPERIOR" )
oView:SetOwnerView( "VIEW_NN7", "PASTA_NN7" )
oView:SetOwnerView( "VIEW_NKH", "PASTA_NKH" )
oView:SetOwnerView( "VIEW_NNY", "PASTA_NNY" )
oView:SetOwnerView( "VIEW_NNG", "PASTA_NNG" )
oView:SetOwnerView( "VIEW_NNF", "PASTA_NNF" )

oView:EnableTitleView( "VIEW_NJR" )
oView:EnableTitleView( "VIEW_NN7" )
oView:EnableTitleView( "VIEW_NKH" )
oView:EnableTitleView( "VIEW_NNY" )
oView:EnableTitleView( "VIEW_NNG" )
oView:EnableTitleView( "VIEW_NNF" )

oView:SetCloseOnOk( {||.t.} )

Return( oView )


/** {Protheus.doc} OGA330VLD
Rotina para validação do uso do contrato nos campos referentes ao mesmo

@param: 	Nil
@author: 	Equipe TOTVS Agroindustria
@since: 	01/01/2015
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGA330VLD( cCodigo, cTipo )
Local lRetorno		:= .t.
Local aAreaAtu		:= GetArea()
Local aAreaNJR		:= NJR->( GetArea() )
Local lTipo			:= ValType( cTipo ) = "C"
 
If ValType( cCodigo ) == "U"
	cCodigo := &( ReadVar() )
EndIf

IF Empty(ccodigo) .and. Type( "__cCodigo" ) <> 'U' //__cCodigo é uma variavel Publica declarada na Consulta Parao cusotmizada OGX010CT
	cCodigo := __cCodigo
EndIF

If ! Empty( cCodigo )
	dbSelectArea( "NJR" )
	dbSetOrder( 1 )
	If dbSeek( xFilial( "NJR" ) + cCodigo )
		
		/** se o pre-contrato estiver previsto, e nao for permitido utiliza-lo */
		If NJR->( NJR_MODELO ) = "1" .And. NJR->( NJR_STATUS ) = "P"
			Help( , , STR0018, , STR0019, 1, 0 ) //"AJUDA"###"Nao é permitido o uso de -Pre-Contrato"
			lRetorno := .f.
		EndIf
		
		/** se o contrato estiver previsto, finalizado ou encerrado nao permite utiliza-lo */
		If NJR->( NJR_MODELO ) $ "2|3" .And. NJR->( NJR_STATUS ) $ "P|E|F"
			Help( , , STR0018, , STR0020, 1, 0 ) //"AJUDA"###"Status do contrato nao permite movimentacao."
			lRetorno := .f.
		Else
			
			/** Valida se o contrato permite movimentacao para o tipo informado */
			If lTipo
				
				If NJR->( NJR_MODELO ) $ "2|3" .And. NJR->( NJR_STATUS ) $ "A|I"
					
					/** Contrato de Compra somente permite modelo 5 (Compra) e 8 (Dev.Compra) */
					If   ( NJR->( NJR_TIPO ) == "1" .And. .Not. cTipo $ "5|8" ) ;
					.Or. ( NJR->( NJR_TIPO ) == "2" .And. .Not. cTipo $ "4|9" ) ;
					.Or. ( NJR->( NJR_TIPO ) == "3" .And. .Not. cTipo $ "3|6" ) ;
					.Or. ( NJR->( NJR_TIPO ) == "4" .And. .Not. cTipo $ "2|7" )	
						Help( , , STR0018, , STR0021, 1, 0 ) //"AJUDA"###"Tipo do contrato nao permite o tipo de movimentacao."
						lRetorno := .f.
					EndIf
					
				EndIf
				
			EndIf
			
		EndIf
		
	Else
		
		Help( , , STR0018, , STR0022, 1, 0 ) //"AJUDA"###"Contrato nao localizado na base de dados."
		lRetorno := .f.
		
	EndIf
EndIf

RestArea( aAreaNJR )
RestArea( aAreaAtu )
Return( lRetorno )