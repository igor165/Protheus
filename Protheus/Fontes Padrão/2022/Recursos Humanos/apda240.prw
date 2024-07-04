#include 'Protheus.ch'
#Include 'fwmvcdef.ch'
#INCLUDE "TOTVS.CH"
#INCLUDE "MSGRAPHI.CH"
#include 'APDA240.CH'
#INCLUDE "PRCONST.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ão    ³ APDA240  ³ Autor ³ Emerson Campos                    ³ Data ³ 08/08/2012 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Visualizacao e grafico relacionado ao Cabecalho Montagem Avaliacoes (RD6)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ APDA240()                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³ FNC            ³  Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia Car.³03/07/14  ³TPZWBQ          ³Incluido o fonte da 11 para a 12 e efetuada ³±± 
±±³            ³          ³                ³a limpeza.                                  ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function APDA240
	Local oBrwRD6

    oBrwRD6 := FWmBrowse():New()		
	oBrwRD6:SetAlias( 'RD6' )
	oBrwRD6:SetDescription(STR0010)	//"Avaliações"
	oBrwRD6:AddLegend( "RD6->RD6_STATUS == '1'" , "BR_VERDE"	, STR0013  )	//"OK"
	oBrwRD6:AddLegend( "RD6->RD6_STATUS == '2'" , "BR_VERMELHO" , STR0014  )	//"Pendente" 
	oBrwRD6:Activate()
Return Nil
  
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MenuDef    ³ Autor ³ Emerson Campos        ³ Data ³08/08/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Menu Funcional                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MenuDef()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
	Local aRotina := {}
 
	ADD OPTION aRotina Title STR0008  	Action 'PesqBrw'         	OPERATION 1 ACCESS 0	//"Pesquisar"
	ADD OPTION aRotina Title STR0009	Action 'VIEWDEF.APDA240' 	OPERATION 2 ACCESS 0	//"Visualizar"	
	//ADD OPTION aRotina Title STR0021	Action 'LEGAPDA240()' 		OPERATION 2 ACCESS 0	//"Legenda"
	
	aadd(aRotina,{ STR0007,"Apd240Gra", 0 , 4} ) //"Gráfico"

Return aRotina

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ModelDef   ³ Autor ³ Emerson Campos        ³ Data ³30/08/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Modelo de dados Visualizacao e grafico relacionado ao        ³±±
±±³          ³ Cabecalho Montagem Avaliacoes (RD6)                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ModelDef()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ModelDef()
	Local oMdlRD6	
	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruRD6 	:= FWFormStruct( 1, 'RD6', /*bAvalCampo*/,/*lViewUsado*/ )
	Local oStruRD9 	:= FWFormStruct( 1, 'RD9', /*bAvalCampo*/, /*lViewUsado*/ )
	Local oStruRDA 	:= FWFormStruct( 1, 'RDA', /*bAvalCampo*/, /*lViewUsado*/ )
	// Localiza a ordem a ser utilizada
	Local nRD9Ord	:= RetOrdem( "RD9" , "RD9_FILIAL+RD9_CODAVA+RD9_CODADO+RD9_CODPRO+DTOS(RD9_DTIAVA)" )
	Local nRDAOrd	:= RetOrdem( "RDA" , "RDA_FILIAL+RDA_CODAVA+RDA_CODADO+RDA_CODPRO+DTOS(RDA_DTIAVA)" )
		
	// Bloco de codigo da Fields
	Local bTOkVld		:= { |oGrid| RD6TOk( oGrid, oMdlRD6)}
	
	oStruRD9:AddField(            ;		// Ord. Tipo Desc.
		AllTrim( 'Legenda' )    , ;     // [01]  C   Titulo do campo
		AllTrim( 'Legenda' )    , ;     // [02]  C   ToolTip do campo
		'RD9_LEGEND'            , ;     // [03]  C   I5d
		'C'                     , ;     // [04]  C   Tipo do campo
		15                      , ;     // [05]  N   Tamanho do campo
		0                       , ;     // [06]  N   Decimal do campo
		NIL						, ;    	// [07]  B   Code-block de validação do campo
		NIL                     , ;     // [08]  B   Code-block de validação When do campo
		NIL		                , ;     // [09]  A   Lista de valores permitido do campo
		NIL                     , ;     // [10]  L   Indica se o campo tem preenchimento obrigatório
		FwBuildFeature( STRUCT_FEATURE_INIPAD,'LegRD9(RD9->RD9_FILIAL,RD9->RD9_CODAVA,RD9->RD9_CODADO,RD9->RD9_CODPRO,DTOS(RD9->RD9_DTIAVA))' ), ;     // [11]  B   Code-block de inicializacao do campo
		NIL                     , ;     // [12]  L   Indica se trata-se de um campo chave
		NIL                     , ;     // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.T.                       )     // [14]  L   Indica se o campo é virtual
	
	oStruRD9:SetProperty( 'RD9_NOME'  , MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, 'Posicione("RD0",1,xFilial("RD0")+RD9->RD9_CODADO,"RD0_NOME")' ) )
	 
	oStruRDA:AddField(            ;		// Ord. Tipo Desc.
		AllTrim( 'Legenda' )    , ;     // [01]  C   Titulo do campo
		AllTrim( 'Legenda' )    , ;     // [02]  C   ToolTip do campo
		'RDA_LEGEND'            , ;     // [03]  C   I5d
		'C'                     , ;     // [04]  C   Tipo do campo
		15                      , ;     // [05]  N   Tamanho do campo
		0                       , ;     // [06]  N   Decimal do campo
		NIL						, ;    	// [07]  B   Code-block de validação do campo
		NIL                     , ;     // [08]  B   Code-block de validação When do campo
		NIL		                , ;     // [09]  A   Lista de valores permitido do campo
		NIL                     , ;     // [10]  L   Indica se o campo tem preenchimento obrigatório
		FwBuildFeature( STRUCT_FEATURE_INIPAD,'LegRDA(RDA->RDA_FILIAL,RDA->RDA_CODAVA,RDA->RDA_CODADO,RDA->RDA_CODPRO,RDA->RDA_CODDOR,DTOS(RDA->RDA_DTIAVA),RDA->RDA_CODNET,RDA->RDA_NIVEL,RDA->RDA_TIPOAV)' ), ;     // [11]  B   Code-block de inicializacao do campo
		NIL                     , ;     // [12]  L   Indica se trata-se de um campo chave
		NIL                     , ;     // [13]  L   Indica se o campo pode receber valor em uma operação de update.
		.T.                       )     // [14]  L   Indica se o campo é virtual
	    
	oStruRDA:SetProperty( 'RDA_NOME'  , MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, 'Posicione("RD0",1,xFilial("RD0")+RDA->RDA_CODDOR,"RD0_NOME")' ) )
	 
	// Cria o objeto do Modelo de Dados
	oMdlRD6 := MPFormModel():New('APDA240', /*bPreValid*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/ )
	
	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oMdlRD6:AddFields( 'MODELRD6Inf', /*cOwner*/, oStruRD6, /*bLOkVld*/, bTOkVld, /*bCarga*/ )
	
	oMdlRD6:AddGrid( 'RD9DETAIL', 'MODELRD6Inf', oStruRD9, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
	oMdlRD6:AddGrid( 'RDADETAIL', 'RD9DETAIL'  , oStruRDA, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
    
	// Faz relaciomaneto entre os compomentes do model
	oMdlRD6:SetRelation( 'RD9DETAIL', {{'RD9_FILIAL', 'xFilial( "RD9" )'}, {'RD9_CODAVA', 'RD6_CODIGO'}, {'RD9_DTIAVA', 'RD6_DTINI' } } , RD9->( IndexKey( nRD9Ord ) )  )
	oMdlRD6:SetRelation( 'RDADETAIL', {{'RDA_FILIAL', 'xFilial( "RDA" )'}, {'RDA_CODAVA', 'RD9_CODAVA'}, {'RDA_CODADO', 'RD9_CODADO'}, {'RDA_CODPRO', 'RD9_CODPRO'}, {'RDA_DTIAVA', 'RD9_DTIAVA'}} , RDA->( IndexKey( nRDAOrd ) )  )
	
    // Adiciona a descricao do Componente do Modelo de Dados
	oMdlRD6:GetModel( 'MODELRD6Inf' ):SetDescription( STR0011 )	//"Avaliações Disponíveis"
	oMdlRD6:GetModel( 'RD9DETAIL'   ):SetDescription( 'Itens Avaliacoes x Avaliados'   )	//'Itens Avaliacoes x Avaliados'
	oMdlRD6:GetModel( 'RDADETAIL'   ):SetDescription( 'Itens Avaliados x Avaliadores'  )	//'Itens Avaliados x Avaliadores'
	
	// Nao Permite Incluir, Alterar ou Excluir linhas na formgrid 
	oMdlRD6:GetModel( 'RD9DETAIL' ):SetNoInsertLine()
	oMdlRD6:GetModel( 'RD9DETAIL' ):SetNoUpdateLine()
	oMdlRD6:GetModel( 'RD9DETAIL' ):SetNoDeleteLine()
	
	oMdlRD6:GetModel( 'RDADETAIL' ):SetNoInsertLine()
	oMdlRD6:GetModel( 'RDADETAIL' ):SetNoUpdateLine()
	oMdlRD6:GetModel( 'RDADETAIL' ):SetNoDeleteLine()
    	
	// Adiciona a descricao do Componente do Modelo de Dados
	oMdlRD6:GetModel( 'MODELRD6Inf' ):SetDescription(STR0011)	//"Avaliações Disponíveis"
		
Return oMdlRD6

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ViewDef    ³ Autor ³ Emerson Campos        ³ Data ³30/08/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Modelo de dados e Visualizacao e grafico relacionado ao      ³±±
±±³          ³ Cabecalho Montagem Avaliacoes (RD6)                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ViewDef()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ViewDef()
	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oMdlRD6   := FWLoadModel( 'APDA240' )
	// Cria a estrutura a ser usada na View
	Local oStruRD6 := FWFormStruct( 2, 'RD6' )
	Local oStruRD9 := FWFormStruct( 2, 'RD9' )
	Local oStruRDA := FWFormStruct( 2, 'RDA' )
	Local oView
	
	oStruRD9:AddField( ;                         // Ord. Tipo Desc.
	'RD9_LEGEND'                       	, ;      // [01]  C   Nome do Campo
	'01'                             	, ;      // [02]  C   Ordem
	AllTrim( 'Legenda' )          		, ;      // [03]  C   Titulo do campo
	AllTrim( 'Legenda' )       			, ;      // [04]  C   Descricao do campo
	{ 'Legenda' } 						, ;      // [05]  A   Array com Help
	'C'                                	, ;      // [06]  C   Tipo do campo
	'@BMP'                              , ;      // [07]  C   Picture
	NIL                                	, ;      // [08]  B   Bloco de Picture Var
	''                                 	, ;      // [09]  C   Consulta F3
	.F.                                	, ;      // [10]  L   Indica se o campo é alteravel
	NIL                                	, ;      // [11]  C   Pasta do campo
	NIL                                	, ;      // [12]  C   Agrupamento do campo
	NIL				                  	, ;      // [13]  A   Lista de valores permitido do campo (Combo)
	NIL                                	, ;      // [14]  N   Tamanho maximo da maior opção do combo
	Nil 								, ;      // [15]  C   Inicializador de Browse                  
	.T.                                	, ;      // [16]  L   Indica se o campo é virtual
	NIL                                	, ;      // [17]  C   Picture Variavel
	NIL                                   )      // [18]  L   Indica pulo de linha após o campo
	
	oStruRD9:SetProperty( 'RD9_CODAVA'  , MVC_VIEW_ORDEM, '02' )//Avaliação
	oStruRD9:SetProperty( 'RD9_CODADO'  , MVC_VIEW_ORDEM, '03' )//Avaliado
	oStruRD9:SetProperty( 'RD9_NOME'    , MVC_VIEW_ORDEM, '04' )//Nome do Avaliado
	//oStruRD9:SetProperty( 'RD9_NOME'    , MVC_VIEW_TITULO, 'Emerson')
	oStruRD9:SetProperty( 'RD9_CODPRO'  , MVC_VIEW_ORDEM, '05' )//Cod. Projeto
	oStruRD9:SetProperty( 'RD9_DTIAVA'  , MVC_VIEW_ORDEM, '06' )//Per Inicial
	oStruRD9:SetProperty( 'RD9_DTFAVA'  , MVC_VIEW_ORDEM, '07' )//Per Final
     
	oStruRDA:AddField( ;                         // Ord. Tipo Desc.
	'RDA_LEGEND'                       	, ;      // [01]  C   Nome do Campo
	'01'                             	, ;      // [02]  C   Ordem
	AllTrim( 'Legenda' )          		, ;      // [03]  C   Titulo do campo
	AllTrim( 'Legenda' )       			, ;      // [04]  C   Descricao do campo
	{ 'Legenda' } 						, ;      // [05]  A   Array com Help
	'C'                                	, ;      // [06]  C   Tipo do campo
	'@BMP'                              , ;      // [07]  C   Picture
	NIL                                	, ;      // [08]  B   Bloco de Picture Var
	''                                 	, ;      // [09]  C   Consulta F3
	.F.                                	, ;      // [10]  L   Indica se o campo é alteravel
	NIL                                	, ;      // [11]  C   Pasta do campo
	NIL                                	, ;      // [12]  C   Agrupamento do campo
	NIL				                  	, ;      // [13]  A   Lista de valores permitido do campo (Combo)
	NIL                                	, ;      // [14]  N   Tamanho maximo da maior opção do combo
	Nil 								, ;      // [15]  C   Inicializador de Browse                 
	.T.                                	, ;      // [16]  L   Indica se o campo é virtual
	NIL                                	, ;      // [17]  C   Picture Variavel
	NIL                                   )      // [18]  L   Indica pulo de linha após o campo

	oStruRDA:SetProperty( 'RDA_CODAVA'  , MVC_VIEW_ORDEM, '02')//Avaliação
	oStruRDA:SetProperty( 'RDA_CODADO'  , MVC_VIEW_ORDEM, '03')//Avaliado
	oStruRDA:SetProperty( 'RDA_CODPRO'  , MVC_VIEW_ORDEM, '04')//Cod. Projeto
	oStruRDA:SetProperty( 'RDA_DTIAVA'  , MVC_VIEW_ORDEM, '05')//Per Inicial
	oStruRDA:SetProperty( 'RDA_DTFAVA'  , MVC_VIEW_ORDEM, '06')//Per Final
	oStruRDA:SetProperty( 'RDA_CODDOR'  , MVC_VIEW_ORDEM, '07')//Avaliador
	
	oStruRDA:SetProperty( 'RDA_NOME'    , MVC_VIEW_ORDEM, '08') //Nome
	//oStruRDA:SetProperty( 'RDA_NOME'    , MVC_VIEW_INIBROW,'Posicione("RD0",1,xFilial("RD0")+RDA->RDA_CODDOR,"RD0_NOME")')
	
	oStruRDA:SetProperty( 'RDA_TIPOAV'  , MVC_VIEW_ORDEM, '09')//Tp Avaliador
	oStruRDA:SetProperty( 'RDA_CODTIP'  , MVC_VIEW_ORDEM, '10')//Cod Tp. Avaliador
	oStruRDA:SetProperty( 'RDA_CODNET'  , MVC_VIEW_ORDEM, '11')//Rede
	oStruRDA:SetProperty( 'RDA_NIVEL'   , MVC_VIEW_ORDEM, '12')//Nivel Rede

	// Cria o objeto de View
	oView := FWFormView():New()
	
	// Define qual o Modelo de dados sera utilizado
	oView:SetModel( oMdlRD6 )
	
	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_RD6Inf', oStruRD6, 'MODELRD6Inf' )
	 
	//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
	oView:AddGrid(  'VIEW_RD9', oStruRD9, 'RD9DETAIL' )
	oView:AddGrid(  'VIEW_RDA', oStruRDA, 'RDADETAIL' )

	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'FORMFIELD' 		, 20 )
	oView:CreateHorizontalBox( 'GRID_AVA_ADO'   , 40 )
	oView:CreateHorizontalBox( 'GRID_ADO_DOR' 	, 40 )

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_RD6Inf'	, 'FORMFIELD'   	)
	oView:SetOwnerView( 'VIEW_RD9'		, 'GRID_AVA_ADO'    )
	oView:SetOwnerView( 'VIEW_RDA'		, 'GRID_ADO_DOR'  	)
    
	// Liga a identificacao do componente
	oView:EnableTitleView( 'VIEW_RD6Inf' )
	oView:EnableTitleView( 'VIEW_RD9', 'Itens Avaliacoes x Avaliados'  , RGB( 224, 30, 43 )  )	//'Itens Avaliacoes x Avaliados'
	oView:EnableTitleView( 'VIEW_RDA', 'Itens Avaliados x Avaliadores' , 0 )	//'Itens Avaliados x Avaliadores'
    
	// Criar novo botao na barra de botoes
	oView:AddUserButton( STR0021, 'CLIPS', { |oView| LEGAPDA240() } )  //Legenda

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_RD6Inf', 'FORMFIELD' )

Return oView

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ RD6TOk     ³ Autor ³ Emerson Campos        ³ Data ³08/08/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao da Fields                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RD6TOk()                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Obs.     ³ Esta rotina gera o grafico para o remote, no caso do portal a³±±
±±³          ³ funcao GetMonitoring encontra-se no fonte WSAPD016.PRW       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RD6TOk( oGrid, oMdlRD6 )
	Local lRet      := .T.
Return lRet

Function Apd240Gra()
	Local cAlias
	Local cCode			:= RD6_CODIGO
	Local cTitAval		:= ''
	Local cDtFimAval	:= ''
	Local cFiltro		:= ''
	Local lAval			:= .F.
	Local lAAval		:= .F.
	Local lCons			:= .F.
	Local nPorcA		:= 0
	Local nPorcAA		:= 0
	Local nPorcC		:= 0 
	Local nI			:= 1	
	Local aArea     	:= GetArea()
	Local aAdvSize		:= {}
	Local aInfoAdvSize	:= {}
	Local aObjCoords	:= {}
	Local aObjSize		:= {}
	Local aTotais		:= {0,0,0,0,0,0}
	Local oDlg
	/*
	 aTotais[1]	:= soma dos avaliadores finalizados,
	 aTotais[2]	:= total de avaliadores,
	 aTotais[3]	:= soma dos auto-avaliados finalizados,
	 aTotais[4]	:= total de auto-avaliacoes,
	 aTotais[5]	:= soma dos consensos finalizados,
	 aTotais[6]	:= total de consensos
	*/ 
	
 	DbSelectArea("RDC")
   		RDC->(DbSetOrder(1))
   		RDC->(DbSeek(xFilial("RDC")+cCode))              
   		While  RDC->(!Eof()) .AND. RDC->RDC_CODAVA == cCode
   			If RDC->RDC_TIPOAV == '1'		//Avaliador
			lAval	:= .T.
			aTotais[1]++
			If ! Empty(RDC->RDC_DATRET)
				aTotais[2]++
			EndIf
		ElseIf RDC->RDC_TIPOAV == '2' 	//Auto- Avaliacao
			lAAval	:= .T.
			aTotais[3]++
			If ! Empty(RDC->RDC_DATRET)
				aTotais[4]++
			EndIf
		ElseIf RDC->RDC_TIPOAV == '3'	//Consenso 
			lCons	:= .T.
			aTotais[5]++
			If ! Empty(RDC->RDC_DATRET)
				aTotais[6]++
			EndIf
		EndIf
   			RDC->( DbSkip() )
   		EndDo
   /**************************************************************
	* Efetua os calculos para apresentar o resultado no grafico   *
	**************************************************************/
	nPorcA	:= Round((aTotais[2]*100)/aTotais[1], 2) 
	nPorcAA	:= Round((aTotais[4]*100)/aTotais[3], 2) 
	nPorcC	:= Round((aTotais[6]*100)/aTotais[5], 2)	
    
	DbSelectArea("RD6")
   		RD6->(DbSetOrder(1))
   		RD6->(DbSeek(xFilial("RD6")+cCode))              
   		While  RD6->(!Eof()) .AND. RD6->RD6_CODIGO == cCode
   			cTitAval	:= RD6->RD6_DESC
		cDtFimAval	:= RD6->RD6_DTFIM
   			RD6->( DbSkip() )
   	EndDo
 
	/**************************************************************
	* Monta as Dimensoes dos Objetos                              *
	**************************************************************/
	aAdvSize		:= MsAdvSize()
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )  
    
	DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
	DEFINE MSDIALOG oDlg FROM aAdvSize[7],0 TO 500,700 TITLE STR0001 PIXEL	// "Status da Avaliação"
	  
		oFWChart := FWChartFactory():New()
		oFWChart := oFWChart:getInstance( BARCHART )    
		
	   	oFWChart:init( oDlg, .F. )
		oFWChart:setTitle( cTitAval + " - " + STR0002 + DToC(cDtFimAval), CONTROL_ALIGN_CENTER )
		oFWChart:setLegend( CONTROL_ALIGN_BOTTOM )
		oFWChart:setMask( "*@* %" )
		oFWChart:setPicture( "@E 999.99" )
		
		If lAAval			
			oFWChart:addSerie( STR0004, nPorcAA ) 	//'Auto-Avaliação'
		EndIf
		
		If lAval			
			oFWChart:addSerie( STR0005, nPorcA )	//'Avaliador'
		EndIf
		
		If lCons			
			oFWChart:addSerie( STR0006, nPorcC )	//'Consenso'
		EndIf
				
		oFWChart:build() 		  
	
	ACTIVATE DIALOG oDlg CENTERED
	
	RestArea(aArea)
Return 

Function LegRD9(cCodFil, cCodAva, cCodAdo, cCodPro, cDtiAva)
Local cRet		:= 'BR_VERDE'
Local nRDAOrd	:= RetOrdem( "RDA", "RDA_FILIAL+RDA_CODAVA+RDA_CODADO+RDA_CODPRO+DTOS(RDA_DTIAVA)" )   
Local nRD9Ord	:= RetOrdem( "RDC", "RDC_FILIAL+RDC_CODAVA+RDC_CODADO+RDC_CODPRO+RDC_CODDOR+DTOS(RDC_DTIAVA)+RDC_CODNET+RDC_NIVEL+RDC_TIPOAV" )
	
	dbSelectArea("RDA")
	RDA->(dbSetOrder(nRDAOrd))
	RDA->(DBSeek(xFilial("RDA") + cCodAva + cCodAdo + cCodPro + cDtiAva))	
	
	If RDA->(!EOF())
		While  RDA->(!EOF()) .AND. RDA_CODAVA == cCodAva .AND. RDA_CODADO == cCodAdo .AND.;
		                            RDA_CODPRO == cCodPro .AND. DTOS(RDA_DTIAVA) == cDtiAva 
			dbSelectArea("RDC")
			RDC->(dbSetOrder(nRD9Ord))	
		   	RDC->(DBSeek(xFilial("RDC") + RDA->RDA_CODAVA + RDA->RDA_CODADO + RDA->RDA_CODPRO + RDA->RDA_CODDOR +;
		   								   DTOS(RDA->RDA_DTIAVA) + RDA->RDA_CODNET + RDA->RDA_NIVEL + RDA->RDA_TIPOAV))
		   	If RDC->(!EOF())
			   	While  RDC->(!EOF()) .AND. RDC_CODAVA == cCodAva .AND. RDC_CODADO == cCodAdo .AND.;
			   								RDC_CODPRO == cCodPro .AND. RDC_CODDOR == RDA->RDA_CODDOR .AND.;
			   								DTOS(RDC_DTIAVA) == cDtiAva .AND. RDA->RDA_CODNET == RDA->RDA_CODNET .AND. ;
			   								RDC_NIVEL == RDA->RDA_NIVEL .AND. RDC_TIPOAV == RDA->RDA_TIPOAV
			   								
				   	If	RDC->RDC_TIPOAV == '1' .AND. Empty(RDC->RDC_DATENV) .AND. Empty(RDC->RDC_DATRET)
			   			//Avaliador - Dt Envio vazio - Dt Retorno vazio         
			   			cRet	:= 'BR_VERMELHO'
			   		ElseIf	RDC->RDC_TIPOAV == '1' .AND. !Empty(RDC->RDC_DATENV) .AND. Empty(RDC->RDC_DATRET)         
			   			//Avaliador - Dt Envio preenchido - Dt Retorno vazio
			   			cRet	:= 'BR_VERMELHO'
			   		ElseIf	RDC->RDC_TIPOAV == '2' .AND. Empty(RDC->RDC_DATENV) .AND. Empty(RDC->RDC_DATRET)         
			   			//Auto-Avaliacao - Dt Envio vazio - Dt Retorno vazio 
			   			cRet	:= 'BR_VERMELHO'
			   		ElseIf	RDC->RDC_TIPOAV == '2' .AND. !Empty(RDC->RDC_DATENV) .AND. Empty(RDC->RDC_DATRET)         
			   			//Auto-Avaliacao - Dt Envio preenchido - Dt Retorno vazio
			   			cRet	:= 'BR_VERMELHO'
			   		ElseIf	RDC->RDC_TIPOAV == '3' .AND. Empty(RDC->RDC_DATENV) .AND. Empty(RDC->RDC_DATRET)         
			   			//Consenso - Dt Envio vazio - Dt Retorno vazio 
			   			cRet	:= 'BR_VERMELHO'
			   		ElseIf	RDC->RDC_TIPOAV == '3' .AND. !Empty(RDC->RDC_DATENV) .AND. Empty(RDC->RDC_DATRET)         
			   			//Consenso - Dt Envio preenchido - Dt Retorno vazio
			   			cRet	:= 'BR_VERMELHO'		
			   		EndIf	 
			   		RDC->(DbSkip())
			    EndDo
			Else
				cRet	:= 'BR_VERMELHO'	
			EndIf		
			
		    RDA->(DbSkip())
		EndDo
	Else
		cRet	:= 'BR_VERMELHO'
	EndIf
Return cRet

Function LegRDA(cCodFil, cCodAva, cCodAdo, cCodPro, cCodDor, cDtiAva, cCodNet, cNivel, cTipoAv)
Local cRet		:= 'BR_VERDE'
Local nRD9Ord	:= RetOrdem( "RD9", "RD9_FILIAL+RD9_CODAVA+RD9_CODADO+RD9_CODPRO+DTOS(RD9_DTIAVA)")
Local nRDAOrd	:= RetOrdem( "RDC", "RDC_FILIAL+RDC_CODAVA+RDC_CODADO+RDC_CODPRO+RDC_CODDOR+DTOS(RDC_DTIAVA)+RDC_CODNET+RDC_NIVEL+RDC_TIPOAV" )
    dbSelectArea("RD9")
    RD9->(dbSetOrder(nRD9Ord))
    RD9->(DBSeek(xFilial("RD9") + cCodAva + cCodAdo + cCodPro + cDtiAva ))
    
	If RD9->(!EOF())
		dbSelectArea("RDC")
		RDC->(dbSetOrder(nRDAOrd))	
	   	RDC->(DBSeek(xFilial("RDC") + cCodAva + cCodAdo + cCodPro + cCodDor + cDtiAva + cCodNet + cNivel + cTipoAv))
	    
	    If RDC->(!EOF())  		
	   		If	RDC->RDC_TIPOAV == '1' .AND. Empty(RDC->RDC_DATENV) .AND. Empty(RDC->RDC_DATRET)
	   			//Avaliador - Dt Envio vazio - Dt Retorno vazio         
	   			cRet	:= 'BR_VERMELHO'
	   		ElseIf	RDC->RDC_TIPOAV == '1' .AND. !Empty(RDC->RDC_DATENV) .AND. Empty(RDC->RDC_DATRET)         
	   			//Avaliador - Dt Envio preenchido - Dt Retorno vazio
	   			cRet	:= 'BR_AMARELO'
	   		ElseIf	RDC->RDC_TIPOAV == '2' .AND. Empty(RDC->RDC_DATENV) .AND. Empty(RDC->RDC_DATRET)         
	   			//Auto-Avaliacao - Dt Envio vazio - Dt Retorno vazio 
	   			cRet	:= 'PMSTASK1'
	   		ElseIf	RDC->RDC_TIPOAV == '2' .AND. !Empty(RDC->RDC_DATENV) .AND. Empty(RDC->RDC_DATRET)         
	   			//Auto-Avaliacao - Dt Envio preenchido - Dt Retorno vazio
	   			cRet	:= 'PMSTASK2'
	   		ElseIf	RDC->RDC_TIPOAV == '3' .AND. Empty(RDC->RDC_DATENV) .AND. Empty(RDC->RDC_DATRET)         
	   			//Consenso - Dt Envio vazio - Dt Retorno vazio 
	   			cRet	:= 'BPMSEDT1'
	   		ElseIf	RDC->RDC_TIPOAV == '3' .AND. !Empty(RDC->RDC_DATENV) .AND. Empty(RDC->RDC_DATRET)         
	   			//Consenso - Dt Envio preenchido - Dt Retorno vazio
	   			cRet	:= 'BPMSEDT2'		
	   		EndIf
	   	Else
	   		cRet	:= ''
	   	EndIf
 	Else
 		cRet	:= ''
   	EndIf	 
Return cRet 


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o   ³LegAPDA240³ Autor ³ Emerson Campos        ³ Data ³05/09/2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o³ Cria uma janela contendo a legenda da mBrowse              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LegAPDA240                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LegAPDA240()
Local aCores:= {}

IF Type( "cCadastro" ) == "U"
	Private cCadastro := STR0021							//"Legenda"
EndIF

aCores:= {	{"BR_VERMELHO"	,OemToAnsi(STR0015)	}	,;	//"Avaliação não enviada"
			{"BR_AMARELO"   ,OemToAnsi(STR0016)	}	,;	//"Avaliação não retornada"
			{"PMSTASK1"		,OemToAnsi(STR0017)	}	,;	//"Auto-avaliação não enviada"
			{"PMSTASK2"		,OemToAnsi(STR0018)	}	,;	//"Auto-avaliação não retornada"	
			{"BPMSEDT1"		,OemToAnsi(STR0019)	}	,;	//"Avaliação de consenso não enviada"
			{"BPMSEDT2"		,OemToAnsi(STR0020)	}	,;	//"Avaliação de consenso não retornada"
			{"BR_VERDE"		,OemToAnsi(STR0013)	}	 ;	//"OK"  
		 }			

BrwLegenda(	OemToAnsi(cCadastro)						,;	//Titulo do Cadastro
			OemToAnsi( STR0021 )						,;	//"Legenda"
			aCores 										;
		  )

Return( .T. )