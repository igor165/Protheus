#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#include "report.ch"
#Include 'TOTVS.ch'
#include 'PLSA814.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA813
Funcao para abrir o Credenciamento do Candidato
@author Oscar Zanin
@since 13/03/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA814(cCodRda,cDescription)

Local oBrowse
default cCodRda 	:= ""
default cDescription := ""
//Instancia objeto
oBrowse := FWMBrowse():New()

//Define tabela de origem do Browse
oBrowse:SetAlias('B98')

//Define nome da tela
if(!empty(cDescription))
	oBrowse:SetDescription(cDescription)
else
	oBrowse:SetDescription(FunDesc())
endIf

//Adiciona Legenda
oBrowse:AddLegend( "PLS814LEGE()=='1'"	, "RED"   , STR0001)//"Pendente com a Operadora"
oBrowse:AddLegend( "PLS814LEGE()=='2'"	, "ORANGE", STR0002)//"Pendente com o Prestador"
oBrowse:AddLegend( "PLS814LEGE()=='3'"	, "GREEN" , STR0003)//"Concluído"
oBrowse:AddLegend( "PLS814LEGE()=='4'"	, "GRAY"  , STR0004)//"Indeferido"
oBrowse:AddLegend( "PLS814LEGE()=='0'"	, "WHITE" , STR0005)//"Sem Anexos (Pendente Operadora)"

if(!empty(cCodRda))
	oBrowse:SetFilterDefault( "B98_CODIGO == '" + cCodRda + "' " )
endIf

oBrowse:Activate()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao para criar o menu da tela
@author Oscar Zanin
@since 13/03/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

Add Option aRotina Title  STR0006/*'Visualizar'*/	Action 'VIEWDEF.PLSA814' Operation 2 Access 0
Add Option aRotina Title  STR0007/*'Analisar'*/  	Action 'vldAnalise' Operation 4 Access 0
Add Option aRotina Title  STR0008/*'Imprimir'*/  	Action 'VIEWDEF.PLSA814' Operation 8 Access 0

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados
@author Oscar Zanin
@since 13/03/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel // Modelo de dados construído
Local oStrB98 := FWFormStruct(1,'B98')// Cria as estruturas a serem usadas no Modelo de Dados, ajustando os campos que iráconsiderar
Local oStrB9Q	:= FWFormStruct(1,'B7L')
Local oStrB9V	:= FWFormStruct(1,'B7L')
Local oStrB5G := FWFormStruct(1,'B5G', { |cCampo| PLS814B5GM(cCampo)})
Local oStrB4H := FWFormStruct(1,'B4H')
Local oStrB7L	:= FWFormStruct(1,'B7L')
Local oStrBC1 := FWFormStruct(1,'B7L')
Local oStrBC0 := FWFormStruct(1,'B7L')
Local lB7L		:= .F.

oModel := MPFormModel():New( 'PLSA814', , { |oModel| PLS814OK(oModel) },, { |oModel| FWFormCancel(oModel) } )// , , { |oModel| PLS813OK(oModel) }, , { || PLS813CNCL() }) // Cria o objeto do Modelo de Dados e insere a funçao de pós-validação e de cancelamento

If (select("B7L") == 0)
	DbSelectArea("B7L")
	lB7L := .T.
EndIf

B7L->(DbSetOrder(1))

If lB7L
	B7L->(DbCloseArea())
EndIf

//ADD FIELD (Model)
//Nome do campo
oStrB7L:AddField( ; 													// Ord. Tipo Desc.
	AllTrim( STR0009/*'Campo'*/ ) , ; 							// [01] C Titulo do campo
	AllTrim( STR0010/*'Nome do campo Alterado'*/ ) , ; 		// [02] C ToolTip do campo
	'B7L_CPOAMG' , ; 									// [03] C identificador (ID) do Field
	'C' , ; 											// [04] C Tipo do campo
	12 , ; 											// [05] N Tamanho do campo
	0 , ; 												// [06] N Decimal do campo
	NIL, ; 											// [07] B Code-block de validação do campo
	NIL , ; 											// [08] B Code-block de validação When do campo
	NIL , ; 											// [09] A Lista de valores permitido do campo
	NIL , ; 											// [10] L Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, "PLS814SX3(B7L->(B7L_CAMPO), 'X3_TITULO')" )/* NIL*/ , ; // [11] B Code-block de inicializacao do campo
	NIL , ; 											// [12] L Indica se trata de um campo chave
	NIL , ; 											// [13] L Indica se o campo pode receber valor em uma operação de update.
	.T. ) 												// [14] L Indica se o campo é virtual

oStrB9V:AddField( ; 													// Ord. Tipo Desc.
	AllTrim( STR0009/*'Campo'*/ ) , ; 							// [01] C Titulo do campo
	AllTrim( STR0010/*'Nome do campo Alterado'*/ ) , ; 		// [02] C ToolTip do campo
	'B7L_CPOAMG' , ; 									// [03] C identificador (ID) do Field
	'C' , ; 											// [04] C Tipo do campo
	12 , ; 											// [05] N Tamanho do campo
	0 , ; 												// [06] N Decimal do campo
	NIL, ; 											// [07] B Code-block de validação do campo
	NIL , ; 											// [08] B Code-block de validação When do campo
	NIL , ; 											// [09] A Lista de valores permitido do campo
	NIL , ; 											// [10] L Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, "PLS814SX3(B7L->(B7L_CAMPO), 'X3_TITULO')" )/* NIL*/ , ; // [11] B Code-block de inicializacao do campo
	NIL , ; 											// [12] L Indica se trata de um campo chave
	NIL , ; 											// [13] L Indica se o campo pode receber valor em uma operação de update.
	.T. )

oStrB9Q:AddField( ; 													// Ord. Tipo Desc.
	AllTrim( STR0009/*'Campo'*/) , ; 							// [01] C Titulo do campo
	AllTrim( STR0010/*'Nome do campo Alterado'*/ ) , ; 		// [02] C ToolTip do campo
	'B7L_CPOAMG' , ; 									// [03] C identificador (ID) do Field
	'C' , ; 											// [04] C Tipo do campo
	12 , ; 											// [05] N Tamanho do campo
	0 , ; 												// [06] N Decimal do campo
	NIL, ; 											// [07] B Code-block de validação do campo
	NIL , ; 											// [08] B Code-block de validação When do campo
	NIL , ; 											// [09] A Lista de valores permitido do campo
	NIL , ; 											// [10] L Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, "PLS814SX3(B7L->(B7L_CAMPO), 'X3_TITULO')" )/* NIL*/ , ; // [11] B Code-block de inicializacao do campo
	NIL , ; 											// [12] L Indica se trata de um campo chave
	NIL , ; 											// [13] L Indica se o campo pode receber valor em uma operação de update.
	.T. )

oStrBC1:AddField( ; 													// Ord. Tipo Desc.
	AllTrim( STR0009/*'Campo'*/) , ; 							// [01] C Titulo do campo
	AllTrim( STR0010/*'Nome do campo Alterado'*/ ) , ; 		// [02] C ToolTip do campo
	'B7L_CPOAMG' , ; 									// [03] C identificador (ID) do Field
	'C' , ; 											// [04] C Tipo do campo
	12 , ; 											// [05] N Tamanho do campo
	0 , ; 												// [06] N Decimal do campo
	NIL, ; 											// [07] B Code-block de validação do campo
	NIL , ; 											// [08] B Code-block de validação When do campo
	NIL , ; 											// [09] A Lista de valores permitido do campo
	NIL , ; 											// [10] L Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, "PLS814SX3(B7L->(B7L_CAMPO), 'X3_TITULO')" )/* NIL*/ , ; // [11] B Code-block de inicializacao do campo
	NIL , ; 											// [12] L Indica se trata de um campo chave
	NIL , ; 											// [13] L Indica se o campo pode receber valor em uma operação de update.
	.T. )

oStrBC0:AddField( ; 													// Ord. Tipo Desc.
	AllTrim( STR0009/*'Campo'*/) , ; 							// [01] C Titulo do campo
	AllTrim( STR0010/*'Nome do campo Alterado'*/ ) , ; 		// [02] C ToolTip do campo
	'B7L_CPOAMG' , ; 									// [03] C identificador (ID) do Field
	'C' , ; 											// [04] C Tipo do campo
	12 , ; 											// [05] N Tamanho do campo
	0 , ; 												// [06] N Decimal do campo
	NIL, ; 											// [07] B Code-block de validação do campo
	NIL , ; 											// [08] B Code-block de validação When do campo
	NIL , ; 											// [09] A Lista de valores permitido do campo
	NIL , ; 											// [10] L Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, "PLS814SX3(B7L->(B7L_CAMPO), 'X3_TITULO')" )/* NIL*/ , ; // [11] B Code-block de inicializacao do campo
	NIL , ; 											// [12] L Indica se trata de um campo chave
	NIL , ; 											// [13] L Indica se o campo pode receber valor em uma operação de update.
	.T. )

//Nome da tabela
oStrB7L:AddField( ; 													// Ord. Tipo Desc.
	AllTrim( STR0011 /*'Tabela'*/ ) , ; 							// [01] C Titulo do campo
	AllTrim( STR0012 /*'Nome da tabela Alterada'*/ ) , ; 		// [02] C ToolTip do campo
	'B7L_ALIAMG' , ; 									// [03] C identificador (ID) do Field
	'C' , ; 											// [04] C Tipo do campo
	30 , ; 											// [05] N Tamanho do campo
	0 , ; 												// [06] N Decimal do campo
	NIL, ; 											// [07] B Code-block de validação do campo
	NIL , ; 											// [08] B Code-block de validação When do campo
	NIL , ; 											// [09] A Lista de valores permitido do campo
	NIL , ; 											// [10] L Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, "PLS814SX2(B7L->(B7L_ALIAS))" )/* NIL*/ , ; // [11] B Code-block de inicializacao do campo
	NIL , ; 											// [12] L Indica se trata de um campo chave
	NIL , ; 											// [13] L Indica se o campo pode receber valor em uma operação de update.
	.T. ) 												// [14] L Indica se o campo é virtual

oStrB9V:AddField( ; 													// Ord. Tipo Desc.
	AllTrim( STR0011 /*'Tabela'*/ ) , ; 							// [01] C Titulo do campo
	AllTrim( STR0012 /*'Nome da tabela Alterada'*/ ) , ; 		// [02] C ToolTip do campo
	'B7L_ALIAMG' , ; 									// [03] C identificador (ID) do Field
	'C' , ; 											// [04] C Tipo do campo
	30 , ; 											// [05] N Tamanho do campo
	0 , ; 												// [06] N Decimal do campo
	NIL, ; 											// [07] B Code-block de validação do campo
	NIL , ; 											// [08] B Code-block de validação When do campo
	NIL , ; 											// [09] A Lista de valores permitido do campo
	NIL , ; 											// [10] L Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, "PLS814SX2(B7L->(B7L_ALIAS))" )/* NIL*/ , ; // [11] B Code-block de inicializacao do campo
	NIL , ; 											// [12] L Indica se trata de um campo chave
	NIL , ; 											// [13] L Indica se o campo pode receber valor em uma operação de update.
	.T. )

oStrB9Q:AddField( ; 													// Ord. Tipo Desc.
	AllTrim( STR0011 /*'Tabela'*/ ) , ; 							// [01] C Titulo do campo
	AllTrim( STR0012 /*'Nome da tabela Alterada'*/ ) , ; 		// [02] C ToolTip do campo
	'B7L_ALIAMG' , ; 									// [03] C identificador (ID) do Field
	'C' , ; 											// [04] C Tipo do campo
	30 , ; 											// [05] N Tamanho do campo
	0 , ; 												// [06] N Decimal do campo
	NIL, ; 											// [07] B Code-block de validação do campo
	NIL , ; 											// [08] B Code-block de validação When do campo
	NIL , ; 											// [09] A Lista de valores permitido do campo
	NIL , ; 											// [10] L Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, "PLS814SX2(B7L->(B7L_ALIAS))" )/* NIL*/ , ; // [11] B Code-block de inicializacao do campo
	NIL , ; 											// [12] L Indica se trata de um campo chave
	NIL , ; 											// [13] L Indica se o campo pode receber valor em uma operação de update.
	.T. )

oStrBC1:AddField( ; 													// Ord. Tipo Desc.
	AllTrim( STR0011 /*'Tabela'*/ ) , ; 							// [01] C Titulo do campo
	AllTrim( STR0012 /*'Nome da tabela Alterada'*/ ) , ; 		// [02] C ToolTip do campo
	'B7L_ALIAMG' , ; 									// [03] C identificador (ID) do Field
	'C' , ; 											// [04] C Tipo do campo
	30 , ; 											// [05] N Tamanho do campo
	0 , ; 												// [06] N Decimal do campo
	NIL, ; 											// [07] B Code-block de validação do campo
	NIL , ; 											// [08] B Code-block de validação When do campo
	NIL , ; 											// [09] A Lista de valores permitido do campo
	NIL , ; 											// [10] L Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, "PLS814SX2(B7L->(B7L_ALIAS))" )/* NIL*/ , ; // [11] B Code-block de inicializacao do campo
	NIL , ; 											// [12] L Indica se trata de um campo chave
	NIL , ; 											// [13] L Indica se o campo pode receber valor em uma operação de update.
	.T. )

oStrBC0:AddField( ; 													// Ord. Tipo Desc.
	AllTrim( STR0011 /*'Tabela'*/ ) , ; 							// [01] C Titulo do campo
	AllTrim( STR0012 /*'Nome da tabela Alterada'*/ ) , ; 		// [02] C ToolTip do campo
	'B7L_ALIAMG' , ; 									// [03] C identificador (ID) do Field
	'C' , ; 											// [04] C Tipo do campo
	30 , ; 											// [05] N Tamanho do campo
	0 , ; 												// [06] N Decimal do campo
	NIL, ; 											// [07] B Code-block de validação do campo
	NIL , ; 											// [08] B Code-block de validação When do campo
	NIL , ; 											// [09] A Lista de valores permitido do campo
	NIL , ; 											// [10] L Indica se o campo tem preenchimento obrigatório
	FwBuildFeature( STRUCT_FEATURE_INIPAD, "PLS814SX2(B7L->(B7L_ALIAS))" )/* NIL*/ , ; // [11] B Code-block de inicializacao do campo
	NIL , ; 											// [12] L Indica se trata de um campo chave
	NIL , ; 											// [13] L Indica se o campo pode receber valor em uma operação de update.
	.T. )

//ADD FIELDS
oModel:addFields('MasterB98', ,oStrB98)  // Adiciona ao modelo um componente de formulário

//ADD GRID
oModel:AddGrid('B9VDetail', 'MasterB98', oStrB9V)
oModel:AddGrid('B9QDetail', 'MasterB98', oStrB9Q)
oModel:AddGrid('B5GDetail', 'MasterB98', oStrB5G, { |oMdlG,nLine,cAcao,cCampo| Vld813Del( oMdlG, nLine, cAcao, cCampo ) }, { |oB5G| PLS814Weee(oB5G)})
oModel:AddGrid('B4HDetail', 'B5GDetail', oStrB4H)
oModel:Addgrid('B7LDetail', 'MasterB98', oStrB7L)
oModel:AddGrid('BC1Detail', 'MasterB98', oStrBC1)
oModel:AddGrid('BC0Detail', 'MasterB98', oStrBC0)

//SET RELATION

	//Informações
oModel:SetRelation( 'B7LDetail', { ;
	{ 'B7L_FILIAL'	, 'xFilial( "B7L" )' },;
	{ 'B7L_CHAVE'		, 'B98_CODSEQ'		} },;
	B7L->( IndexKey( ) ) )
oModel:GetModel( 'B7LDetail' ):SetLoadFilter( { { 'B7L_ALIACH', '"B98"' } } )
	
	//Especialidade
oModel:SetRelation( 'B9QDetail', { ;
	{ 'B7L_FILIAL'	, 'xFilial( "B7L" )' },;
	{ 'B7L_CHAVE'		, 'B98_CODSEQ'		} },;
	B7L->( IndexKey( ) ) )
oModel:GetModel( 'B9QDetail' ):SetLoadFilter( { { 'B7L_ALIACH',  "'B98'" } } )
oModel:GetModel( 'B9QDetail' ):SetLoadFilter( { { 'B7L_ALIAS', "'BAX'" } } )
	
	//Endereço
oModel:SetRelation( 'B9VDetail', { ;
	{ 'B7L_FILIAL'	, 'xFilial( "B7L" )' },;
	{ 'B7L_CHAVE'		, 'B98_CODSEQ'		} },;
	B7L->( IndexKey( ) ) )
oModel:GetModel( 'B9VDetail' ):SetLoadFilter( { { 'B7L_ALIACH',  "'B98'" } } )
oModel:GetModel( 'B9VDetail' ):SetLoadFilter( { { 'B7L_ALIAS', "'BB8'" } } )
	
	//Passos da Análise
oModel:SetRelation( 'B5GDetail', { ;
	{ 'B5G_FILIAL' 	, 'xFilial( "B5G" )' },;
	{ 'B5G_CODINT'	, 'B98_CODINT'       },;
	{ 'B5G_CODIGO'	, 'B98_CODSEQ'		} },;//Passos da Análise
	B5G->( IndexKey(  ) ) )  // Faz relacionamento entre os componentes do model
	
	//Histórico
oModel:SetRelation( 'B4HDetail', { ;
	{ 'B4H_FILIAL' 	, 'xFilial( "B4H" )' },;
	{ 'B4H_CODSEQ'	, 'B5G_CODSEQ'		} },; //Histórico
	B4H->( IndexKey(  ) ) )  // Faz relacionamento entre os componentes do model

	//Corpo Clínico
oModel:SetRelation( 'BC1Detail', { ;
	{ 'B7L_FILIAL'	, 'xFilial( "B7L" )' },;
	{ 'B7L_CHAVE'		, 'B98_CODSEQ'		} },;
	B7L->( IndexKey( ) ) )
oModel:GetModel( 'BC1Detail' ):SetLoadFilter( { { 'B7L_ALIACH',  "'B98'" } } )
oModel:GetModel( 'BC1Detail' ):SetLoadFilter( { { 'B7L_ALIAS', "'BC1'" } } )

	//Procedimentos
oModel:SetRelation( 'BC0Detail', { ;
	{ 'B7L_FILIAL'	, 'xFilial( "B7L" )' },;
	{ 'B7L_CHAVE'		, 'B98_CODSEQ'		} },;
	B7L->( IndexKey( ) ) )
oModel:GetModel( 'BC0Detail' ):SetLoadFilter( { { 'B7L_ALIACH',  "'B98'" } } )
oModel:GetModel( 'BC0Detail' ):SetLoadFilter( { { 'B7L_ALIAS', "'BC0'" } } )

//SET DESCRIPTION
oModel:GetModel('MasterB98'):SetDescription(FunDesc()) // Adiciona a descrição do Modelo de Dados

//SET OPTIONAL
oModel:GetModel( 'B4HDetail' ):SetOptional( .T. )
oModel:GetModel( 'B9QDetail' ):SetOptional( .T. )
oModel:getModel( 'B9VDetail' ):setOptional( .T. )
oModel:getModel( 'B7LDetail' ):setOptional( .T. )
oModel:getModel( 'B5GDetail' ):setOptional( .T. )
oModel:getModel( 'BC1Detail' ):setOptional( .T. )
oModel:getModel( 'BC0Detail' ):setOptional( .T. )

//SET NO INSERT LINE
oModel:getModel( 'B7LDetail' ):setNoInsertLine( .T. )
oModel:getModel( 'B9QDetail' ):setNoInsertLine( .T. )
oModel:getModel( 'B9VDetail' ):setNoInsertLine( .T. )
oModel:getModel( 'BC1Detail' ):setNoInsertLine( .T. )
oModel:getModel( 'BC0Detail' ):setNoInsertLine( .T. )
oModel:getModel( 'B4HDetail' ):setNoInsertLine( .T. )


//SET ONLY VIEW
//oModel:GetModel( 'B9VDetail' ):SetOnlyView( .T. )

//SET PRIMARY KEY
oModel:SetPrimaryKey( {"B98_FILIAL", "B98_CODIGO"} )

//SET PROPERTY (Model)
oStrB5G:setProperty( '*', MODEL_FIELD_WHEN, { || PLS814WHEN(oModel)})
oStrB98:setProperty( '*', MODEL_FIELD_WHEN, { || PLS814WHEN(oModel)})
oStrB9Q:setProperty( '*', MODEL_FIELD_WHEN, { || PLS814WHEN(oModel)})
oStrB7L:setProperty( '*', MODEL_FIELD_WHEN, { || PLS814WHEN(oModel)})
oStrBC1:setProperty( '*', MODEL_FIELD_WHEN, { || PLS814WHEN(oModel)})
oStrBC0:setProperty( '*', MODEL_FIELD_WHEN, { || PLS814WHEN(oModel)})
oStrB5G:SetProperty( 'B5G_STATUS', MODEL_FIELD_WHEN , { || PLS814CanC(oModel)} )
oStrB7L:SetProperty( 'B7L_GRAVAD', MODEL_FIELD_WHEN, { || P814when2(oModel)} )
oStrB7L:setProperty( '*', MODEL_FIELD_OBRIGAT, .F.)
oStrB5G:setProperty( 'B5G_CODPAS', MODEL_FIELD_VALID, { || PLS814VLD1(oModel) } )
oStrB9V:setProperty( '*', MODEL_FIELD_WHEN, { || PLS814WHEN(oModel)})
Return oModel // Retorna o Modelo de dados

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface
@author Oscar Zanin
@since 13/03/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef() // Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado

Local oView  // Interface de visualização construída
Local oModel := FWLoadModel( 'PLSA814' ) // Cria as estruturas a serem usadas na View
Local oStrB98 := FWFormStruct(2,'B98', { |cCampo| PLS814B98V(cCampo)})
Local oStrB5G := FWFormStruct(2,'B5G', { |cCampo| PLS814B5GV(cCampo)})
Local oStrB4H := FWFormStruct(2,'B4H', { |cCampo| PLS814B4HV(cCampo)})
Local oStrB9V	:= FWFormStruct(2,'B7L', { |cCampo| PLS814B7LV(cCampo)})
Local oStrB9Q	:= FWFormStruct(2,'B7L', { |cCampo| PLS814B7LV(cCampo)})
Local oStrB7L	:= FWFormStruct(2,'B7L', { |cCampo| PLS814B7LV(cCampo)})
Local oStrBC1	:= FWFormStruct(2,'B7L', { |cCampo| PLS814B7LV(cCampo)})
Local oStrBC0	:= FWFormStruct(2,'B7L', { |cCampo| PLS814B7LV(cCampo)})

oView := FWFormView():New() // Cria o objeto de View

//ADD FIELD (View)
oStrB7L:AddField( ; // Ord. Tipo Desc.
	'B7L_CPOAMG' , ; // [01] C Nome do Campo
	'03' , ; 			// [02] C Ordem
	AllTrim( STR0009 /*'Campo'*/ ) , ; 			// [03] C Titulo do campo
	AllTrim( STR0010 /*'Campo Alterado'*/ ) , ; // [04] C Descrição do campo
	{ 'Nome do campo que foi alterado' } , ; // [05] A Array com Help
	'C' , ; // [06] C Tipo do campo
	'@!' , ;// [07] C Picture
	NIL , ; // [08] B Bloco de Picture Var
	'' , ;  // [09] C Consulta F3
	.F. , ; // [10] L Indica se o campo é evitável
	NIL , ; // [11] C Pasta do campo
	NIL , ; // [12] C Agrupamento do campo
	NIL , ; // [13] A Lista de valores permitido do campo (Combo)
	NIL , ; // [14] N Tamanho Maximo da maior opção do combo
	NIL , ; // [15] C Inicializador de Browse
	.T. , ; // [16] L Indica se o campo é virtual
	NIL )   // [17] C Picture Variável

oStrB9V:AddField( ; // Ord. Tipo Desc.
	'B7L_CPOAMG' , ; // [01] C Nome do Campo
	'03' , ; 			// [02] C Ordem
	AllTrim( STR0009 /*'Campo'*/) , ; 			// [03] C Titulo do campo
	AllTrim( STR0010 /*'Campo Alterado'*/ ) , ; // [04] C Descrição do campo
	{ 'Nome do campo que foi alterado' } , ; // [05] A Array com Help
	'C' , ; // [06] C Tipo do campo
	'@!' , ;// [07] C Picture
	NIL , ; // [08] B Bloco de Picture Var
	'' , ;  // [09] C Consulta F3
	.F. , ; // [10] L Indica se o campo é evitável
	NIL , ; // [11] C Pasta do campo
	NIL , ; // [12] C Agrupamento do campo
	NIL , ; // [13] A Lista de valores permitido do campo (Combo)
	NIL , ; // [14] N Tamanho Maximo da maior opção do combo
	NIL , ; // [15] C Inicializador de Browse
	.T. , ; // [16] L Indica se o campo é virtual
	NIL )   // [17] C Picture Variável

oStrB9Q:AddField( ; // Ord. Tipo Desc.
	'B7L_CPOAMG' , ; // [01] C Nome do Campo
	'03' , ; 			// [02] C Ordem
	AllTrim( STR0009 /*'Campo'*/ ) , ; 			// [03] C Titulo do campo
	AllTrim( STR0010 /*'Campo Alterado'*/ ) , ; // [04] C Descrição do campo
	{ 'Nome do campo que foi alterado' } , ; // [05] A Array com Help
	'C' , ; // [06] C Tipo do campo
	'@!' , ;// [07] C Picture
	NIL , ; // [08] B Bloco de Picture Var
	'' , ;  // [09] C Consulta F3
	.F. , ; // [10] L Indica se o campo é evitável
	NIL , ; // [11] C Pasta do campo
	NIL , ; // [12] C Agrupamento do campo
	NIL , ; // [13] A Lista de valores permitido do campo (Combo)
	NIL , ; // [14] N Tamanho Maximo da maior opção do combo
	NIL , ; // [15] C Inicializador de Browse
	.T. , ; // [16] L Indica se o campo é virtual
	NIL )   // [17] C Picture Variável

oStrBC1:AddField( ; // Ord. Tipo Desc.
	'B7L_CPOAMG' , ; // [01] C Nome do Campo
	'03' , ; 			// [02] C Ordem
	AllTrim( STR0009 /*'Campo'*/ ) , ; 			// [03] C Titulo do campo
	AllTrim( STR0010 /*'Campo Alterado'*/ ) , ; // [04] C Descrição do campo
	{ 'Nome do campo que foi alterado' } , ; // [05] A Array com Help
	'C' , ; // [06] C Tipo do campo
	'@!' , ;// [07] C Picture
	NIL , ; // [08] B Bloco de Picture Var
	'' , ;  // [09] C Consulta F3
	.F. , ; // [10] L Indica se o campo é evitável
	NIL , ; // [11] C Pasta do campo
	NIL , ; // [12] C Agrupamento do campo
	NIL , ; // [13] A Lista de valores permitido do campo (Combo)
	NIL , ; // [14] N Tamanho Maximo da maior opção do combo
	NIL , ; // [15] C Inicializador de Browse
	.T. , ; // [16] L Indica se o campo é virtual
	NIL )   // [17] C Picture Variável

oStrBC0:AddField( ; // Ord. Tipo Desc.
	'B7L_CPOAMG' , ; // [01] C Nome do Campo
	'03' , ; 			// [02] C Ordem
	AllTrim( STR0009 /*'Campo'*/ ) , ; 			// [03] C Titulo do campo
	AllTrim( STR0010 /*'Campo Alterado'*/ ) , ; // [04] C Descrição do campo
	{ 'Nome do campo que foi alterado' } , ; // [05] A Array com Help
	'C' , ; // [06] C Tipo do campo
	'@!' , ;// [07] C Picture
	NIL , ; // [08] B Bloco de Picture Var
	'' , ;  // [09] C Consulta F3
	.F. , ; // [10] L Indica se o campo é evitável
	NIL , ; // [11] C Pasta do campo
	NIL , ; // [12] C Agrupamento do campo
	NIL , ; // [13] A Lista de valores permitido do campo (Combo)
	NIL , ; // [14] N Tamanho Maximo da maior opção do combo
	NIL , ; // [15] C Inicializador de Browse
	.T. , ; // [16] L Indica se o campo é virtual
	NIL )   // [17] C Picture Variável

oStrB7L:AddField( ; // Ord. Tipo Desc.
	'B7L_ALIAMG' , ; // [01] C Nome do Campo
	'02' , ; 			// [02] C Ordem
	AllTrim( STR0011 /*'Tabela'*/ ) , ; 			// [03] C Titulo do campo
	AllTrim( STR0012 /*'Tabela alterada'*/ ) , ; // [04] C Descrição do campo
	{ 'Nome da tabela que foi alterada' } , ; // [05] A Array com Help
	'C' , ; // [06] C Tipo do campo
	'@!' , ;// [07] C Picture
	NIL , ; // [08] B Bloco de Picture Var
	'' , ;  // [09] C Consulta F3
	.F. , ; // [10] L Indica se o campo é evitável
	NIL , ; // [11] C Pasta do campo
	NIL , ; // [12] C Agrupamento do campo
	NIL , ; // [13] A Lista de valores permitido do campo (Combo)
	NIL , ; // [14] N Tamanho Maximo da maior opção do combo
	NIL , ; // [15] C Inicializador de Browse
	.T. , ; // [16] L Indica se o campo é virtual
	NIL )   // [17] C Picture Variável

oStrB9Q:AddField( ; // Ord. Tipo Desc.
	'B7L_ALIAMG' , ; // [01] C Nome do Campo
	'02' , ; 			// [02] C Ordem
	AllTrim( STR0011 /*'Tabela'*/ ) , ; 			// [03] C Titulo do campo
	AllTrim( STR0012 /*'Tabela alterada'*/ ) , ; // [04] C Descrição do campo
	{ 'Nome da tabela que foi alterada' } , ; // [05] A Array com Help
	'C' , ; // [06] C Tipo do campo
	'@!' , ;// [07] C Picture
	NIL , ; // [08] B Bloco de Picture Var
	'' , ;  // [09] C Consulta F3
	.F. , ; // [10] L Indica se o campo é evitável
	NIL , ; // [11] C Pasta do campo
	NIL , ; // [12] C Agrupamento do campo
	NIL , ; // [13] A Lista de valores permitido do campo (Combo)
	NIL , ; // [14] N Tamanho Maximo da maior opção do combo
	NIL , ; // [15] C Inicializador de Browse
	.T. , ; // [16] L Indica se o campo é virtual
	NIL )   // [17] C Picture Variável

oStrB9V:AddField( ; // Ord. Tipo Desc.
	'B7L_ALIAMG' , ; // [01] C Nome do Campo
	'02' , ; 			// [02] C Ordem
	AllTrim( STR0011 /*'Tabela'*/ ) , ; 			// [03] C Titulo do campo
	AllTrim( STR0012 /*'Tabela alterada'*/ ) , ; // [04] C Descrição do campo
	{ 'Nome da tabela que foi alterada' } , ; // [05] A Array com Help
	'C' , ; // [06] C Tipo do campo
	'@!' , ;// [07] C Picture
	NIL , ; // [08] B Bloco de Picture Var
	'' , ;  // [09] C Consulta F3
	.F. , ; // [10] L Indica se o campo é evitável
	NIL , ; // [11] C Pasta do campo
	NIL , ; // [12] C Agrupamento do campo
	NIL , ; // [13] A Lista de valores permitido do campo (Combo)
	NIL , ; // [14] N Tamanho Maximo da maior opção do combo
	NIL , ; // [15] C Inicializador de Browse
	.T. , ; // [16] L Indica se o campo é virtual
	NIL )   // [17] C Picture Variável

oStrBC1:AddField( ; // Ord. Tipo Desc.
	'B7L_ALIAMG' , ; // [01] C Nome do Campo
	'02' , ; 			// [02] C Ordem
	AllTrim( STR0011 /*'Tabela'*/ ) , ; 			// [03] C Titulo do campo
	AllTrim( STR0012 /*'Tabela alterada'*/ ) , ; // [04] C Descrição do campo
	{ 'Nome da tabela que foi alterada' } , ; // [05] A Array com Help
	'C' , ; // [06] C Tipo do campo
	'@!' , ;// [07] C Picture
	NIL , ; // [08] B Bloco de Picture Var
	'' , ;  // [09] C Consulta F3
	.F. , ; // [10] L Indica se o campo é evitável
	NIL , ; // [11] C Pasta do campo
	NIL , ; // [12] C Agrupamento do campo
	NIL , ; // [13] A Lista de valores permitido do campo (Combo)
	NIL , ; // [14] N Tamanho Maximo da maior opção do combo
	NIL , ; // [15] C Inicializador de Browse
	.T. , ; // [16] L Indica se o campo é virtual
	NIL )   // [17] C Picture Variável

oStrBC0:AddField( ; // Ord. Tipo Desc.
	'B7L_ALIAMG' , ; // [01] C Nome do Campo
	'02' , ; 			// [02] C Ordem
	AllTrim( STR0011 /*'Tabela'*/ ) , ; 			// [03] C Titulo do campo
	AllTrim( STR0012 /*'Tabela alterada'*/ ) , ; // [04] C Descrição do campo
	{ 'Nome da tabela que foi alterada' } , ; // [05] A Array com Help
	'C' , ; // [06] C Tipo do campo
	'@!' , ;// [07] C Picture
	NIL , ; // [08] B Bloco de Picture Var
	'' , ;  // [09] C Consulta F3
	.F. , ; // [10] L Indica se o campo é evitável
	NIL , ; // [11] C Pasta do campo
	NIL , ; // [12] C Agrupamento do campo
	NIL , ; // [13] A Lista de valores permitido do campo (Combo)
	NIL , ; // [14] N Tamanho Maximo da maior opção do combo
	NIL , ; // [15] C Inicializador de Browse
	.T. , ; // [16] L Indica se o campo é virtual
	NIL )   // [17] C Picture Variável

//SET MODEL
oView:SetModel(oModel)		// Define qual Modelo de dados será utilizado

//ADD FIELD
oView:AddField('ViewB98' , oStrB98,'MasterB98' ) // Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)

//ADD GRID
oView:AddGrid( 'ViewB9Q' , oStrB9Q,'B9QDetail' ) //Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
oView:AddGrid( 'ViewB5G' , oStrB5G,'B5GDetail' ) //Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
oView:AddGrid( 'ViewB9V' , oStrB9V,'B9VDetail' ) //Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
oView:AddGrid( 'ViewB4H' , oStrB4H,'B4HDetail' ) //Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
oView:AddGrid( 'ViewB7L' , oStrB7L,'B7LDetail' )
oView:AddGrid( 'ViewBC1' , oStrBC1,'BC1Detail' )
oView:AddGrid( 'ViewBC0' , oStrBC0,'BC0Detail' )

//CREATE BOX (Principais)
oView:CreateHorizontalBox( 'SUPERIOR' 	, 40) // Cria um "box" horizontal para receber cada elemento da view e Associa à Aba Correspondente
oView:CreateHorizontalBox( 'MEIO'		, 35) // Cria um "box" horizontal para receber cada elemento da view e Associa à Aba Correspondente
oView:CreateHorizontalBox( 'BAIXO'		, 25) // Cria um "box" horizontal para receber cada elemento da view e Associa à Aba Correspondente

//CREATE FOLDER
oView:CreateFolder( 'ABA', 'MEIO' ) //Cria estrutura de abas

//CREATE BOX (Sub Box, para as Grids)
oView:CreateHorizontalBox( 'A'		, 100,,, 'ABA', 'T1'  ) // Cria um "box" horizontal para receber cada elemento da view e Associa à Aba Correspondente
oView:CreateHorizontalBox( 'B'		, 100,,, 'ABA', 'T2'  ) // Cria um "box" horizontal para receber cada elemento da view e Associa à Aba Correspondente
oView:CreateHorizontalBox( 'C'		, 100,,, 'ABA', 'T3'  ) // Cria um "box" horizontal para receber cada elemento da view e Associa à Aba Correspondente
oView:CreateHorizontalBox( 'D'		, 100,,, 'ABA', 'T4'  )
oView:CreateHorizontalBox( 'E'		, 100,,, 'ABA', 'T5'	 )
oView:CreateHorizontalBox( 'F'		, 100,,, 'ABA', 'T6'	 )

//ADD SHEET
oView:AddSheet( 'ABA', 'T1', STR0013 /*'Passos da Análise'*/	) //Cria Segunda aba (Tabelas B9V, B9R, B9Q e Campo B9P_OBSERV)
oView:AddSheet( 'ABA', 'T2', STR0014 /*'Endereço' */ 			) //Cria Primeira aba (Tabela B9P)
oView:AddSheet( 'ABA', 'T3', STR0015 /*'Especialidade'*/  	 	) //Cria Segunda aba (Tabelas B9V, B9R, B9Q e Campo B9P_OBSERV)
oView:AddSheet( 'ABA', 'T4', STR0016 /*'Informações'*/		 	)
oView:AddSheet( 'ABA', 'T5', STR0041 /*'Corpo Clinico'*/ 		) //, { || PLS814BC1(oModel, oView) } ) //Cria Quinta aba
oView:AddSheet( 'ABA', 'T6', STR0042 /*'Procedimentos'*/		)

//SET OWNER
oView:SetOwnerView('ViewB98', 'SUPERIOR'	) // Relaciona o identificador (ID) da View com o "box" para exibição
oView:SetOwnerView('ViewB4H', 'BAIXO'	 	) // Relaciona o identificador (ID) da View com o "box" para exibição
oView:SetOwnerView('ViewB5G', 'A'			) // Relaciona o identificador (ID) da View com o "box" para exibição (Grids dentro do detalhe MEIO)
oView:SetOwnerView('ViewB9V', 'B'			) // Relaciona o identificador (ID) da View com o "box" para exibição (Grids dentro do detalhe MEIO)
oView:SetOwnerView('ViewB9Q', 'C'			) // Relaciona o identificador (ID) da View com o "box" para exibição (Grids dentro do detalhe MEIO)
oView:setOwnerView('ViewB7L', 'D'			)
oView:setOwnerView('ViewBC1', 'E'			)
oView:setOwnerView('ViewBC0', 'F'			)

//INCREMENTAL FIELD

//FIELD ACTION
oView:setFieldAction('B4H_OBSERV', { |oModel| PLS813DBas(oModel, oView,"B4H_DATA"   , "B4HDetail")})
oView:SetFieldAction('B5G_CODPAS', { |oModel| PLS814DBaZ(oModel, oView,"B5G_DATAIN" , "B5GDetail", "B7LDetail")})
oView:SetFieldAction('B5G_STATUS', { |oModel| PLS814Mem2(oModel, oView)})	//PAssa o valor da model para a variável de memória
oView:SetFieldAction('B7L_GRAVAD', { |oModel| PLS814Sinc(oModel, oView) } )
oView:SetFieldAction('BC1_GRAVAD', { |oModel| PLS814Sinc(oModel, oView) } )
oView:SetFieldAction('BC0_GRAVAD', { |oModel| PLS814Sinc(oModel, oView) } )

//SET PROPERTY (View)
oStrB98:setProperty( 'B98_TIPSOL', MVC_VIEW_TITULO, STR0044 /*Tipo de solicitação*/ )
oStrB9V:SetProperty( 'B7L_GRAVAD', MVC_VIEW_ORDEM, '00'	 ) //Primeiro campo da Grid
oStrB9V:SetProperty( 'B7L_GRAVAD', MVC_VIEW_TITULO, STR0043	/*Deferido*/ )
oStrB9Q:SetProperty( 'B7L_GRAVAD', MVC_VIEW_ORDEM, '00'	 ) //Primeiro campo da Grid
oStrB9Q:SetProperty( 'B7L_GRAVAD', MVC_VIEW_TITULO, STR0043	/*Deferido*/ )
oStrB7L:setProperty( 'B7L_GRAVAD', MVC_VIEW_ORDEM, '00'	 ) //Primeiro campo da Grid
oStrB7L:SetProperty( 'B7L_GRAVAD', MVC_VIEW_TITULO, STR0043	/*Deferido*/ )
oStrBC1:setProperty( 'B7L_GRAVAD', MVC_VIEW_ORDEM, '00'  )
oStrBC1:SetProperty( 'B7L_GRAVAD', MVC_VIEW_TITULO, STR0043	/*Deferido*/ )
oStrBC0:setProperty( 'B7L_GRAVAD', MVC_VIEW_ORDEM, '00'  )
oStrBC0:SetProperty( 'B7L_GRAVAD', MVC_VIEW_TITULO, STR0043	/*Deferido*/ )
oStrB98:setProperty( '*', MVC_VIEW_CANCHANGE, .F.)
oStrB9V:setProperty( '*', MVC_VIEW_CANCHANGE, .F.)
oStrB9V:setProperty( 'B7L_GRAVAD', MVC_VIEW_CANCHANGE, .T.)
oStrB9Q:setProperty( '*', MVC_VIEW_CANCHANGE, .F.)
oStrB9Q:setProperty( 'B7L_GRAVAD', MVC_VIEW_CANCHANGE, .T.)
oStrB7L:setProperty( '*', MVC_VIEW_CANCHANGE, .F.)
oStrB7L:setProperty( 'B7L_GRAVAD', MVC_VIEW_CANCHANGE, .T.)
oStrBC1:setProperty( '*', MVC_VIEW_CANCHANGE, .F.)
oStrBC1:setProperty( 'B7L_GRAVAD', MVC_VIEW_CANCHANGE, .T.)
oStrBC0:setProperty( '*', MVC_VIEW_CANCHANGE, .F.)
oStrBC0:setProperty( 'B7L_GRAVAD', MVC_VIEW_CANCHANGE, .T.)


//ADD USER BUTTON
oView:AddUserButton(STR0017 /*"Anexos"*/       				, "",	{|| PLSBAN814(oModel)  } )
oView:AddUserButton(STR0018 /*"Gerar Aditivo"*/				, "",	{|| PLS814GCON(oModel) } )
oView:AddUserButton(STR0019 /*"Cadastro RDA"*/				, "",	{|| PLS814CRDA(oModel, 1)} )//Envia usuário para a tela da RDA
oView:AddUserButton(STR0046 /*"Complemento RDA"*/			, "",	{|| PLS814CRDA(oModel, 2)} )
oView:addUserButton(STR0020 /*"Analise de Disponibilidade"*/, "",	{ || PLSA814DISP(oModel)})

//ENABLE TITLE VIEW
oView:EnableTitleView('ViewB4H','Histórico')

Return oView // Retorna o objeto de View criado


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS814LEGE
Definição da Legenda a ser apresentada
@author Oscar Zanin
@since 05/06/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS814LEGE()

Local cRet

cRet := B98_STATUS

Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS814B5GM
Definição dos campos que pertencerão ao Model
@author Oscar Zanin
@since 05/06/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS814B5GM(cCampo)

Local lRet := .T.

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS814B5GV
Definição dos campos que pertencerão ao Model
@author Oscar Zanin
@since 05/06/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS814B5GV(cCampo)

Local lRet := .F.

If (cCampo != "B5G_CODIGO")

	lRet := .T.
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSBAN814
Banco de conhecimento da rotina. Irá ser adequado para exibir os documentos cadastrados no Portal.
@author Oscar Zanin
@since 05/06/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSBAN814(oModel)

Local oB98 	//:= oModel:GetModel("MasterB98")
Local cCodSeq := "" //oB98:GetValue("B98_CODRDA")
Local cMsg		:= STR0021 //"Não foi cadastrada a RDA do prestador, não é possível utilizar o Banco de Conhecimento"

Private aRotina 		:= {}
PRIVATE cCadastro   	:= FunDesc()

If ValType(oModel) == "O"

	oB98 	 := oModel:GetModel("MasterB98")
	cCodSeq := oB98:GetValue("B98_CODSEQ")
else

	cCodSeq := B98->B98_CODSEQ
EndIf

If AllTrim(cCodSeq) <> ""

	aRotina := {{STR0022 /*"Conhecimento"*/,'MsDocument',0/*permite exclusao do registro*/,1/*visualizar arquivo*/},{STR0023 /*"Inclusão Rápida"*/,'PLSDOcs',0,3}}

	B98->(DbSetOrder(1))

	If B98->(MsSeek(xFilial("B98") + cCodSeq)) //Posiciona no registro do Candidato

		MsDocument( "B98", B98->( RecNo() ), 2 )
	EndIf

	B98->(DbCloseArea())
else

	MsgAlert(cMsg, "Atenção")
EndIf

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS814B98M
Definição dos campos que pertencerão ao Model
@author Oscar Zanin
@since 05/06/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS814B98M(cCampo)

Local lRet := .T.

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS814B98V
Definição dos campos que pertencerão à View
@author Oscar Zanin
@since 05/06/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS814B98V(cCampo)

Local lRet := .T.

If (cCampo == "B98_CODSEV")
	lRet := .F.
EndIf

If (cCampo == "B98_CODINT")
	lRet := .F.
EndIf

If (cCampo == "B98_NUMPRO")
	lRet := .F.
EndIf

If (cCampo == "B98_APROVA")
	lRet := .F.
EndIf

If (cCampo == "B98_INDEFE")
	lRet := .F.
EndIf

If (cCampo == "B98_ATIVO ")
	lRet := .F.
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS814DBaZ
Preenche o campo da data de inclusão da observação no histórico (função para Grids)
E executa preenchimento dos campos relacionados. Exibe confirmação da inserção de
passos de Conclusão ou Indeferimento, ou caso haja envio de e-mail vinculado.
@author Oscar Zanin
@since 05/06/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS814DBaZ(oModel, oView, cCampo, cModel, oB7L)

Local oB5G 		:= oModel:GetModel(cModel)
Local oB98			:= oModel:getModel("MasterB98")
Local dDataI
Local cCodPas		:= oB5G:GetValue("B5G_CODPAS")
Local cCodMail	:= ""
Local cCodInt		:= PLSINTPAD() //oB5G:GetValue("B5G_CODINT")
Local cDescri		:= Posicione("B4G", 3, xFilial("B4G") + cCodInt + cCodPas, "B4G_DESCRI")
Local cStatus		:= Posicione("B4G", 3, xFilial("B5G") + ccodInt + cCodPas, "B4G_STLEG")

If (cStatus = '3')

	If !(MsgYesNo(STR0024 + P814CHKABA(oModel, oB7L)/*'Ao inserir o passo do tipo "Concluído" e finalizá-lo, não será mais possível alterar o registro! Confirma a inclusão do passo?'*/, STR0025 /*"Atenção"*/))

		cCodPas := ""
	EndIf
EndIf

If (cStatus = '4')

	if !(MsgYesNo(STR0026 + P814CHKABA(oModel, oB7L)/*"Ao inserir o passo de Indeferimento, o registro será bloqueado para edição! Confirma a inclusão do passo?"*/, STR0025/*"Atenção"*/))

		cCodPas := ""
	EndIf
EndIf

B4G->(DbSetOrder(3))

If B4G->(MsSeek(xFilial("B4G") + cCodInt + cCodPas))

	cCodMail := AllTrim(B4G->B4G_CODEMA)
EndIF

B4G->(DbCloseArea())

IF !(cCodMail == "")

	If !(MsgYesNo(STR0027 /*"A inclusão deste passo está associada ao envio de informação para o Candidato, confirma a inclusão deste passo?"*/, STR0025/*"Atenção!"*/))

		cCodPas := ""
	EndIf
EndIf

If AllTrim(cCodPas) == ""

	oB5G:ClearField("B5G_CODPAS", , .T.)
	oB5G:ClearField(cCampo)
	oB5G:ClearField("B5G_DESCRI")
	oB5G:ClearField("B5G_USUARI")
	oB5G:SetValue("B5G_STATUS", .F.)
	oB5G:ClearField("B5G_DATAFM")

	M->B5G_DATAIN := ""
	M->B5G_CODPAS	:= cCodPas

Else

	oB5G:SetValue(cCampo, dDataBase)
	oB5G:Setvalue("B5G_DESCRI", cDescri)
	oB98:setValue("B98_STATUS", cStatus)

	dDataI := oB5G:GetValue("B5G_DATAIN")

	M->B5G_DATAIN := dDataI
	M->B5G_CODPAS	:= cCodPas

	PLS814PaCr(oModel)

EndIf

oView:Refresh()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS814PaCr
Preenche o passo do credenciamento Atual ao preencher um novo passo e o
Responsável pela inclusão do Passo.
@author Oscar Zanin
@since 05/06/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS814PaCr(oModel)

Local oB5G 	:= oModel:getModel("B5GDetail")
Local cPasso 	:= oB5G:GetValue("B5G_CODPAS")

oB5G:SetValue( "B5G_USUARI", UsrFullName( RetCodUsr() ) )

Return (cPasso)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS814CanC
Verifica se o passo foi iniciado para permitir sua finalização
@author Oscar Zanin
@since 05/06/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS814CanC(oModel)

Local lRet		:= .F.
Local oB5G		:= oModel:GetModel("B5GDetail")
Local lStatus := oB5G:GetValue('B5G_STATUS')
Local cCodPas	:= IIf(ValType(oB5G:GetValue("B5G_CODPAS")) == "U", "", oB5G:GetValue("B5G_CODPAS"))

If lStatus
	lRet := .F.
else
	If ValType(cCodPas) == "C"
		If AllTrim(cCodPas) <> ""
			lRet := .T.
		EndIf
	EndIf
EndIF

Return (lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS814Mem2
Altera a variável de memória para que a Pós Validação da linha do Grid Funcione corretamente
@author Oscar Zanin
@since 01/04/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS814Mem2(oModel, oView)

Local oA		:= oModel:GetModel("B5GDetail")
Local lStat	:= oA:GetValue("B5G_STATUS")

M->B5G_STATUS := lStat

If lStat .AND. MsgYesNo(STR0028 /*"Confirma a finalização do passo?"*/, STR0029 /*"Finalizar Passo"*/)

	oA:SetValue("B5G_DATAFM", dDataBase)
	PLS814APRO(oModel)

Else

	oA:LoadValue("B5G_STATUS", .F.)
	oA:ClearField("B5G_DATAFM")

EndIf

oView:Refresh()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS814GCON
Envia para a Rotina de gerar contrato, com o número da RDA já preenchido
@author Oscar Zanin
@since 08/06/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS814GCON(oModel)

Local oB98 := oModel:Getmodel("MasterB98")
Local cRDA := oB98:GetValue("B98_CODIGO")
Local cCodInt := PLSINTPAD()
Local nRecno		:= 0
Local oExecView

B2G->(DbSetOrder(1))

If B2G->(MsSeek(xFilial("B2G")+cCodInt+cRDA))

	nRecno := B2G->(Recno()) //Se já existe, pegamos o Recno do registro
else
	//É necessário Gravar o registro na B2G, caso não haja outro do prestador, pois
	//ele gera erro caso o formulário principal não seja alterado e a ideia da rotina
	//é entregar esse pedaço do cadastro já preenchido para o usuário.
	RecLock("B2G", .T.)
	B2G->B2G_FILIAL	:= xFilial("B2G")
	B2G->B2G_CODINT	:= cCodInt
	B2G->B2G_RDA		:= cRDA
	MsUnlock()
	nRecno := B2G->(Recno())

EndIf

B2G->(DbGoTo(nRecno)) //Movemos até o registro existente ou recém-criado

//Esse bloco de comandos abre a tela do cadastro de Geração de contrato
oExecView := FWViewExec():New() 		//Criamos o objeto que abre a View
oExecView:SetTitle('Gerar Aditivo') 	//Define título da Janela
oExecView:SetSource('PLSA731') 			//Definimos o Model que iremos utilizar, no caso, o Model do fonte PLSA731
oExecView:SetModal(.F.) 					//View não abre em janela Modal
oExecView:SetCloseOnOk({|| .T.}) 		//A tela irá fechar ao confirmar o Ok
oExecView:SetOperation(4) 				//Como sempre haverá um registro, o cadastro abre sempre como alteração
oExecView:OpenView(.F.)				 	//Abrimos o cadastro

B2G->(DbCloseArea())

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS814APRO
Verifica se o passo finalizado foi de conclusão e indica como solicitação
aprovada, ou verifica se o passo foi de indeferimento e indica como solicitação
reprovada.
@author Oscar Zanin
@since 08/06/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS814APRO(oModel)

Local oB98		:= oModel:GetModel("MasterB98")
Local oB5G		:= oModel:GetModel("B5GDetail")
Local cPasso	:= oB5G:GetValue("B5G_CODPAS")
Local cStPas	:= ""
Local cCodInt	:= PLSINTPAD()
Local lB4G		:= .F.

If (Select("B4G") == 0)
	DbselectArea("B4G")
	lB4G := .T.
EndIf

B4G->(DbSetOrder(3))
B4G->(MsSeek(xFilial("B4G") + cCodInt + cPasso))
cStPas := B4G->B4G_STLEG

If lB4G
	B4G->(DbCloseArea())
EndIf

If (cStPas == "3")
	MsgAlert(STR0030)// "Solicitação aprovada, a edição da mesma está bloqueada. Opções de consulta de anexos e geração de documentos continuarão habilitadas.")
	oB98:setValue("B98_APROVA", .T.)
EndIf

If (cStPas == "4")
	MsgAlert(STR0031)//"Solicitação indeferida, a edição da mesma está bloqueada.")
	oB98:setValue("B98_INDEFE", .T.)
EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS814MAIL
Envio de e-mail conforme o passo
@author Oscar Zanin
@since 08/04/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS814MAIL(oModel)

Local oB98			:= oModel:GetModel("MasterB98")
Local oB5G			:= oModel:GetModel("B5GDetail")
Local cCodRDA		:= oB98:Getvalue("B98_CODSEQ")
Local cCodPas		:= ""
Local cMailCan	:= PLS814SkEm(cCodRDA)
Local cCodInt		:= PLSINTPAD()
Local cCodMail	:= ""
Local cMsg			:= ""
Local lEnvMail	:= ""
Local nB5G			:= 0
Local nTamB5G		:= oB5G:Length()

B5G->(DbSetOrder(1))
B4G->(DbSetOrder(3))
For nB5G := 1 To nTamB5G
	If !(oB5G:GetValue('B5G_ENVIOU')) //Se não enviou e-mail ainda
		cCodPas	:= oB5G:GetValue("B5G_CODPAS") //Pegamos o Código do Passo para as verificações
		If B4G->(MsSeek(xFilial("B4G") + cCodInt + cCodPas))
			cCodMail := AllTrim(B4G->B4G_CODEMA) //Pegamos o Código de e-mail associado ao passo
			lEnvMail := IIF(B4G->B4G_ENVEMA == '1', .T., .F.)
			cMsg := STR0032 /*'E-mail referente ao passo '*/ + cCodPas + STR0033 /*' enviado com sucesso!'*/
			if (lEnvMail)//chama envio de e-mail
				PLSinaliza(cCodMail, cMsg, 1, cMailCan, "Solicitação de alteração contratual", oB5G, "B5G_ENVIOU", .T.)
			EndIf
		EndIf
	EndIf
Next

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSinaliza
Envio de e-mail genérico
@author Oscar Zanin
@since 08/04/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSinaliza(cCodSin,cMsg,nTpMsg,cEmail,cDescri,;
					oObj, cCpo, xValor, xAttach, cPergunta,;
					lPergunta, cBody, lPrcCpo, cCodProcess, cCcoAdicional,;
					lMsgEmail,cMsgNotFnd)
//Parâmetros
//cCodSin  = Código do sinalizador da tabela BOJ *Obrigatório//, que será buscado na tabela BOJ *Obrigatório
//cMsg	    = Mensagem a ser exibida após o envio do e-mail (Deixar em branco para não exibir alerta)
//nTpMsg   = Tipo da caixa de alerta. 0 = MsgAlert, 1 = MsgInfo, 2 = MsgStop
//cEmail   = E-mail de destino *Obrigatório
//cDescri  = Descrição para o processo no appserver
//oObj     = Objeto a receber retorno após envio
//cCpo     = Campo do objeto que irá receber o retorno
//xValor   = Valor a ser retornado
//xAttach  = Adicionar Anexos
//cPergunta = Código do grupo do Pergunte
//lPergunta = Se exibirá, ou não, a janela do pergunte
//cBody     = texto para o corpo da mensagem
//lPrcCpo   = indica se haverá pré-compilação do valor do aCposEData
//cCodProcess = Código do processamento
//cCcoAdicional = cópia oculta
//lMsgEmail = .t. para mostrar aviso ou .f. para não mostrar. default é .f.
Local cCodInt	:= PLSINTPAD()
Local cCC		:= ""
Local cCCO		:= ""
Local nTCC		:= 0
Local nTCCO	:= 0
Local aCposEData	:= {}
Local cCampo		:= ""
Local lInicia		:= .T.
Local lGrvObj		:= .F.
local lEnv          := .T.

Default cCcoAdicional 	  := ""
Default cMsg 	  := ""
Default nTpMsg  := 0
Default cDescri := ""
Default xAttach := .F.
Default cPergunta := ""
Default lPergunta := .F.
Default cBody		:= ""
Default lPrcCpo	:= .F.
Default cCodProcess := "000002"
Default lMsgEmail	:= .T.
Default cMsgNotFnd	:= ""

If Len(cCodSin) == 6
	BOJ->(DbSetOrder(1))
Else
	BOJ->(DbSetOrder(2))
EndIf

If Empty(cEmail) 
	If lMsgEmail
		MsgAlert(STR0034 )//"E-mail não cadastrado, workflow não enviado.")
	EndIf
	lInicia := .F.
EndIf

If !Empty(oObj) .AND. !Empty(cCpo) .AND. !Empty(xValor)
	lGrvObj := .T.
EndIf

If Empty(cCodSin) .AND. !(Empty(cPergunta))
	Pergunte(cPergunta, lPergunta)
	cCodSin := AllTrim(mv_par01)
	If Vazio(cCodSin)
		MsgAlert(STR0035)//"Código do sinalizador não informado, workflow não enviado.")
		return
	EndIf
EndIf

If lInicia
	//Função para preencher os campos de com cópia e com cópia oculta
	If BOJ->(MsSeek(xFilial("BOJ") + cCodSin))

		BOU->(DbSetOrder(1))
		BOU->(MsSeek(xFilial("BOU") + cCodSin))

		//Adicionando os emails adicionais que deverão ser enviados em cópia
		if !(Empty(cCcoAdicional))
			if(SUBSTR(cCcoAdicional, len(cCcoAdicional), 1) = ';')
				cCCo := cCcoAdicional
			else
				cCCo := cCcoAdicional + ";"
			endif
		endif

		//Preenchemos as Strings de Com Cópia (cCC) e Com Cópia OCula (cCCO)
		While (BOU->BOU_CODSIN == cCodSin) .AND. (!(BOU->(EoF())))

			If BOU->BOU_TIPENV == '0'
				cCC		:= cCC + AllTrim(BOU->BOU_EMAIL) + ";"
			else
				cCCo	:= cCCo + AllTrim(BOU->BOU_EMAIL) + ";"
			EndIf

			BOU->(DbSkip())
		EndDo

		nTCC	:= Len(cCC)
		nTCCo	:= Len(cCCo)

		If (nTCC > 0)
			cCC	:= Left(cCC, (nTCC - 1)) //Tiramos o último ';'
		Else
			cCC	:= ""
		EndIf

		If (nTCCo > 0)
			cCCo := Left(cCCo, (nTCCo - 1)) //Tiramos o último ';'
		Else
			cCCo := ""
		EndIF

		BOU->(DbCloseArea())

		//Busca na tabela de posicionamentos cadastrados para preencher os campos macro do email
		B1P->(DbSetOrder(1))
		If B1P->(MsSeek(xFilial("B1P") + cCodSin))
			While(B1P->(!Eof()) .AND. B1P->B1P_FILIAL == xFilial("B1P") .AND. B1P->B1P_CODSIN == cCodSin )
				DbSelectArea(B1P->B1P_ALIAS)
				DbSetOrder(VAL(B1P->B1P_INDICE))
				&("MsSeek("+B1P->B1P_CHAVE+")")
				B1P->(DbSkip())
			EndDo
		EndIF

		//Busca na tabela para trazer os campos macro e seus valores que serão preenchidos no email
		B1U->(DbSetOrder(1))

		If B1U->(MsSeek(xFilial("B1U") + cCodSin))
			While(B1U->(!Eof()) .AND. B1U->B1U_FILIAL == xFilial("B1U") .AND. B1U->B1U_CODSIN == cCodSin )
				If   "U" <> Type(B1U->B1U_DADO)
					//quando o campo é cadastrado, está entre '%', preciso remover para jogar no array de campos do envio do email (aCposEData)
					cCampo := SubStr ( ALLTRIM(B1U->B1U_CAMPO), 2, Len(B1U->B1U_CAMPO) )
					cCampo := SubStr ( cCampo, 1, (Len(cCampo) - 1)  )
					AADD(aCposEData, {cCampo, &(B1U->B1U_DADO) })
				endIf
				B1U->(DbSkip())
			EndDo
		EndIf

		B1U->(DbCloseArea())

		//Chamada da Função do envio de email
		If !(Empty(Alltrim(cCodSin)))

			//Adiciona texto do usuário
			If !(Empty(Alltrim(BOJ->BOJ_TEXTO)))
				AADD(aCposEData, {"TEXTO", BOJ->BOJ_TEXTO})
			EndIf

			//envio do e-mail/workflow
			PlsWFProc(cCodProcess, cDescri, BOJ->BOJ_ASSUNT,cBody, cEmail, cCC, cCCO, BOJ->BOJ_DIRECT,aCposEData, xAttach ,lPrcCpo,@lEnv)

			//Grava retorno no objeto
			If lGrvObj
				oObj:SetValue(cCpo, xValor)
			EndIf

			//Verifica e exibe mensagem
			If !Vazio(cMsg) .and. lEnv
				If (nTpMsg == 0)
					MsgAlert(cMsg)
				else
					if (nTpMsg == 1)
						MsgInfo(cMsg)
					else
						MsgStop(cMsg)
					EndIf
				EndIf
			EndIf

		EndIf//If !(Empty(Alltrim(cCodSin)))
	Else
		//Verifica e exibe mensagem
		If !Vazio(cMsgNotFnd)
			If (nTpMsg == 0)
				MsgAlert(cMsgNotFnd)
			else
				if (nTpMsg == 1)
					MsgInfo(cMsgNotFnd)
				else
					MsgStop(cMsgNotFnd)
				EndIf
			EndIf
		EndIf
	EndIf//If BOJ->(MsSeek(xFilial("BOJ") + cCodSin))
EndIf

//Reinicializamos as Strings, para não reenviar o e-mail para destinatários indevidos
//caso ele tenha vários envios no mesmo comando.
cCC 	:= ""
cCCO	:= ""

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS814SkEm
Busca o e-mail no cadastro da RDA
@author Oscar Zanin
@since 08/06/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS814SkEm(cCodRDA)

Local cEmail 	:= ""
Local lBau		:= .F.

If (Select("BAU") == 0)
	DbSelectArea("BAU")
	lBau := .T.
EndIf

BAU->(DbSetOrder(1))
BAU->(MsSeek(xFilial("BAU") +  cCodRDA))
cEmail := BAU->BAU_EMAIL

If lBau
	BAU->(DbCloseArea())
	lBau := .F.
EndIf

Return cEmail


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS814OK
Valida a inclusão do Registro
@author Oscar Zanin
@since 08/06/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS814OK(oModel)

Local lRet 		:= .T.
Local aDados 	:= {}
local oView     := FWViewActive()
Local oB98		:= oModel:GetModel("MasterB98")
Local oB7L		:= oModel:getmodel("B7LDetail")
Local oB5G		:= oModel:GetModel("B5GDetail")
Local nTamB7L 	:= oB7L:length()
local nI 		:= 1
Local nReg 		:= 0
local cCodRda 	:= oModel:getModel("MasterB98"):getValue("B98_CODIGO")


PLS814MAIL(oModel)
VrLinha(oModel)

If oModel:Getmodel('MasterB98'):getValue('B98_APROVA') .AND. !(oModel:getModel('MasterB98'):getValue('B98_ATIVO'))

	For nI := 1 To nTamB7L

		oB7L:goLine(nI)

		If ( oB7L:GetValue("B7L_GRAVAD") .AND. (GetSx3Cache(oB7L:getValue("B7L_CAMPO"), "X3_CONTEXT") <> "V") )
			nReg++
			Aadd(aDados, { nReg, {oB7L:getValue("B7L_ALIAS"), oB7L:getValue("B7L_CAMPO"), oB7L:getValue("B7L_VLPOS"), oB7L:getValue("B7L_RECREG"), oB7L:getValue("B7L_TIPO"), oB7L:getValue("B7L_CHVREG")}} )
		EndIf
	Next

	If (oModel:getModel("BC1Detail"):Length() > 1 .OR. !(EMPTY(oModel:getModel("BC1Detail"):GetValue("B7L_ALIAMG"))))
		//Funcao para replicar os dados da BC1 para BB0 e alterar o campo BB0_CGC para o alias BB0.
		 PLS814BC1(@aDados)
	EndIf
 

	If (Len(aDados) > 0 )
		lRet := PLS814GGRV(aDados, cCodRDA)
		oModel:getModel('MasterB98'):loadValue('B98_ATIVO', .T.)
	else

		oB98:loadValue('B98_APROVA',.f.) // para conseguir atualizar o status na view após o help pois existe uma validação genérica no when que não deixava
		oB98:setValue('B98_STATUS', "4")
		oB98:loadValue('B98_OBSERV',"Profissional cadastrado já existe")
		oB98:loadValue('B98_APROVA',.t.) // para bloquear os campos de edição do grid 

		oB5G:loadValue('B5G_CODPAS',"")
		oB5G:loadValue("B5G_DESCRI","")
		oB5G:loadValue('B5G_DATAIN',stod(""))
		oB5G:loadValue('B5G_STATUS',.F.)
		oB5G:loadValue('B5G_DATAFM',stod(""))
		oB5G:loadValue('B5G_USUARI',"")
		oB5G:loadValue('B5G_CODSEQ',"")
		oB5G:loadValue('B5G_CODINT',"")
		oB5G:loadValue('B5G_ENVIOU',.F.)
		oB5G:loadValue('B5G_CODBEN',"")
		oB5G:loadValue('B5G_CODPBE',"")

		CSEQUEN := oModel:getModel('MasterB98'):getValue("B98_CODSEQ")

		B98->(DbSetOrder(1))
		
		if(B98->(MsSeek(xFilial("B98")+CSEQUEN)))
			RecLock("B98", .F.)

			B98->(B98_APROVA)	:= .T.
			B98->(B98_STATUS)	:= "4"
			B98->(B98_OBSERV)	:= "Profissional cadastrado já existe"
						
			MsUnlock()
		endif

		Help(nil, nil , "Registro Duplicado", nil, "O profissional cadastrado já existe", 1, 0, nil, nil, nil, nil, nil, {} )

		oView:Refresh('MasterB98')
		oView:Refresh('B5GDetail')
		
		lRet := .f.	

	EndIf
	

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS814Weee
Validação de inclusão de linha
@author Oscar Zanin
@since 08/06/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS814Weee(oB5G)

Local lRet := .F.
Local nTam := oB5G:Length()

If nTam == 1
	lRet := .T.
Else
	oB5G:GoLine(nTam - 1)
	lRet := oB5G:GetValue("B5G_STATUS")
EndIf

If !lRet
	MsgInfo(STR0036)//"Foi inserido um passo sem a data fim do anterior, verifique o preenchimento")
EndIF

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS814WHEN
When do formulário, para travar a edição caso a solicitação seja aprovada
ou Indeferida.
@author Oscar Zanin
@since 09/06/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS814WHEN(oModel)

Local oB98 	:= oModel:getModel("MasterB98")
Local lAprova	:= oB98:getValue("B98_APROVA") //Verifica se aprovado

If !(lAprova)
	lAprova := oB98:getValue("B98_INDEFE") //Verifica se indeferido
EndIf

lAprova := !(lAprova)

return lAprova


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS814FTCP
Cria filtro da Consulta Padrão B98B4G
@author Oscar Zanin
@since 09/06/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS814FTCP()

Local cCompara 	:= ""
Local lB4G			:= .F.

cStaLeg := B98->B98_STATUS

If (select("B4G") ==0)
	DbSelectArea("B4G")
	lB4G := .T.
EndIF

//Atribui o valor corrente do campo B98_STCRED. Campo em memória não funciona
//em todas as bases, por isso da variável STATIC e o filtro ser desse jeito.
If Vazio(cStaLeg)
	cCompara := B98->B98_STATUS
Else
	cCompara := cStaLeg
EndIF

If lB4G
	B4G->(DbcloseArea())
EndIf

Return (cCompara)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS814GGRV
Gravação genérica a partir do log de alterações do portal.
Inclusão da funcionalidade de exclusão de registro por Rodrigo Morgon em 24/08/2015.
@author Oscar Zanin
@since 09/06/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS814GGRV(aDados, cCodRDA)
//A Rotina deve receber um Array BiDimensional no seguinte formato:
//Array[X, Y]
//[X]       = Registro a processar
//[Y]       = Array com quatro posições
//[X, 2, 1] = Alias da tabela a gravar
//[X, 2, 2] = Campo da tabela a gravar
//[X, 2, 3] = Valor a gravar
//[X, 2, 4] = Recno do Registro, deve vir em branco, ou zero, caso seja inclusão
//[X, 2, 5] = Operação a realizar (1 = inclui, 2 = altera, 3 = exclui)
//[X, 2, 6] = Chave de agrupamento dos campos nos respectivos registros

Local nTam := Len(aDados)
Local nI := 1
Local nJ := 0
local nK := 0
Local cTabela := ""
Local cCampo := ""
Local xValor := ""
Local nRecno := 0
Local lInclui := .F.
Local lTam := .T.
Local nTamCpo := 0
Local cTpoCpo := ""
Local cOpc := ""
Local cAgrup := ""
Local aGravaNew := {}
Local lRet := .F.
Local lExclui := .F.
Local cCodIntz	:= PLSINTPAD()

//Variáveis para os Whiles da gravação
Local cTabAnt := ""
Local cOpcAnt := ""
Local cAgpAnt := ""
Local nRecant := 0
Local lSelect := .F.
LOCAL nPos    := 0

DEFAULT cCodRDA := ""

//Ordena o vetor Por Tabela + Operação + Recno
Asort(aDados,,, { |x, y| x[2, 1] + x[2, 5] + x[2, 4] < y[2, 1] + y[2, 5] + y[2, 4]})
BEGIN TRANSACTION
	While (nI <= nTam) //"While Geral"

		//Pegamos nossos dados Oficiais..
		cTabela := aDados[nI, 2, 1]
		cCampo  := aDados[nI, 2, 2]
		xValor  := AllTrim(aDados[nI, 2, 3])
		nRecno  := Val(AllTrim(aDados[nI, 2, 4]))
		cOpc    := aDados[nI, 2, 5]
		cAgrup  := aDados[nI, 2, 6]

		//Pegamos os dados de controle..
		cTabAnt := cTabela
		cOpcAnt := cOpc
		cAgpAnt := cAgrup
		nRecAnt := nRecno

		//Atribui valor convertido e formatado para xValor
		xValor  := P814Valor(cCampo, xValor)

		//Verificamos e selecionamos a área, se precisar
		if ( select(cTabela) == 0 )
			DbSelectArea(cTabela)
			lSelect := .T.
		EndIF

		//	Definimos Inclusão / Exclusão / Alteração
		If     cOpc == '1'
			lInclui := .T.
			lExclui := .F.
		elseif cOpc == '3'
			lInclui := .F.
			lExclui := .T.
		else
			lInclui := .F.
			lExclui := .F.
		EndIf

		If lInclui //Se for inclusão de registro

			//Enquanto Tabela, a opção de operação e a Chave de Agrupamento forem iguais e ainda estiver dentro do tamanho do array
			While( (cTabela == cTabAnt) .AND. (cOpc == cOpcAnt) .AND. (cAgrup == cAgpAnt) .AND. lTam )

				Aadd( aGravaNew, {cTabela, AllTrim(cCampo), xValor, cAgrup} ) //Adiciona dados no vetor de gravação

				If ( (nI + nJ) < nTam ) //Verifica se não vai estourar o tamanho do array

					//Pega valores anteriores
					cTabAnt := cTabela
					cOpcAnt := cOpc
					cAgpAnt := cAgrup

					//Se não estoura o array, soma 1 ao nJ e busca os valores da próxima posição
					nJ++
					cTabela := aDados[nI+nJ, 2, 1]
					cCampo  := aDados[nI+nJ, 2, 2]
					xValor  := AllTrim(aDados[nI+nJ, 2, 3])
					xValor  := P814Valor(cCampo, xValor)
					cAgrup  := aDados[nI+nJ, 2, 6]
				else

					//Se estoura o array, força a saída do laço
					lTam := .F.
					nJ++
				EndIf
			EndDo

			//Alimenta filial
			aAdd(aGravaNew, {aGravaNew[1, 1], aGravaNew[1, 1] + "_FILIAL", xFilial(aGravaNew[1, 1]), aGravaNew[1, 4]})

			For nK := 1 To Len(aGravaNew)
				//Verificar caso haja nova especialidade, se há cadastro na BBF
				if     (aGravaNew[nK, 2] == "BAX_CODESP")
					PLS813VBBF(aGravaNew[nK, 3], cCodRDA)
					//Verificar se há Local de atendimento, para trazer a descrição a gravar
				elseif (aGravaNew[nK, 2] == "BB8_LOCAL")
					aAdd(aGravaNew, {aGravaNew[nK, 1], "BB8_DESLOC", Posicione("BD1", 1, xFilial("BD1")+cCodIntz+aGravaNew[nK, 3], 'BD1_DESLOC'), aGravaNew[nK, 4]})
				EndIf
			Next

			//Faz a gravação dos dados
			//Formato esperado do array:
			//aGravaNew[X, Y]
			//[X]    = Posição do elemento
			//[X, 1] = Alias da tabela
			//[X, 2] = Campo da tabela
			//[X, 3] = Valor a gravar
			RecLock(cTabAnt, .T.) //Lock na tabela
			For nK := 1 To Len(aGravaNew)
				nPos := (aGravaNew[nK, 1])->(FIELDPOS(aGravaNew[nK, 2]))
				IF nPos > 0
					(aGravaNew[nK, 1])->(FIELDPUT(nPos, aGravaNew[nK, 3]))
				ENDIF
			Next
			MsUnlock()

			nI := nI + nJ //Próximo nI a entrar no While geral
			nJ := 0
			aGravaNew := {} //Limpa vetor de gravação
			lTam := .T. //Retorna o lTam

		elseif lExclui //Se for exclusão de registro

			//Enquanto Tabela e Recno for o mesmo e ainda estiver dentro do tamanho do array
			While( (cTabela == cTabAnt) .AND. (nRecno == nRecAnt) .AND. lTam .AND. (cOpc == cOpcAnt) )
				If ((nI + nJ) < nTam) //Verifica se não vai estourar o tamanho do array
					//Pega valores anteriores
					cTabAnt := cTabela
					cOpcAnt := cOpc
					nRecAnt := nRecno

					//Se não, soma 1 ao nJ e busca os valores da próxima posição
					nJ++
					cTabela := aDados[nI+nJ, 2, 1]
					nRecno  := Val(AllTrim(aDados[nI+nJ, 2, 4]))
				else
					//Se sim, força a saída do laço
					lTam := .F.
					nJ++
				EndIf
			EndDo

			(cTabAnt)->(DbGoTo(nRecAnt))
			RecLock(cTabAnt, .F.)
			(cTabAnt)->(dbDelete())
			MsUnlock()

			nI := nI + nJ //Próximo nI a entrar no While geral
			nJ := 0
			lTam := .T. //Devolve o lTam
			aGravaNew := {} //Limpa vetor

		else //Se for alteração

			//Enquanto Tabela e Recno for o mesmo e ainda estiver dentro do tamanho do array
			While( (cTabela == cTabAnt) .AND. (nRecno == nRecAnt) .AND. lTam .AND. (cOpc == cOpcAnt) )
				Aadd( aGravaNew, {cTabela, AllTrim(cCampo), xValor} ) //Adiciona dados no vetor de gravação
				If ((nI + nJ) < nTam) //Verifica se não vai estourar o tamanho do array

					//Pega valores anteriores
					cTabAnt := cTabela
					cOpcAnt := cOpc
					nRecAnt := nRecno

					//Se não, soma 1 ao nJ e busca os valores da próxima posição
					nJ++
					cTabela := aDados[nI+nJ, 2, 1]
					cCampo  := aDados[nI+nJ, 2, 2]
					xValor  := AllTrim(aDados[nI+nJ, 2, 3])
					xValor  := P814Valor(cCampo, xValor)
					nRecno  := Val(AllTrim(aDados[nI+nJ, 2, 4]))

				else
					//Se sim, força a saída do laço
					lTam := .F.
					nJ++
				EndIf
			EndDo

			(cTabAnt)->(DbGoTo(nRecAnt)) //Posiciona no registro
			//Faz a gravação dos dados
			//Formato esperado do array:
			//aGravaNew[X, Y]
			//[X]    = Posição do elemento
			//[X, 1] = Alias da tabela
			//[X, 2] = Campo da tabela
			//[X, 3] = Valor a gravar
			RecLock(cTabAnt, .F.) //Lock na tabela
			For nK := 1 To Len(aGravaNew)
				nPos := (aGravaNew[nK, 1])->(FIELDPOS(aGravaNew[nK, 2]))
				IF nPos > 0
					(aGravaNew[nK, 1])->(FIELDPUT(nPos, aGravaNew[nK, 3]))
				ENDIF
			Next
			MsUnlock()

			nI := nI + nJ //Próximo nI a entrar no While geral
			nJ := 0
			lTam := .T. //Devolve o lTam
			aGravaNew := {} //Limpa vetor
		EndIf

		//Fechamos a área, se tivermos aberto
		if lSelect
			DbSelectArea(cTabela)
			lSelect := .F.
		EndIF
	EndDo

	lRet := .T.
END TRANSACTION

return(lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} P814Valor
Converte o valor tipo Caractere para o tipo e tamanho correto, conforme
dicionário de dados.
@author Oscar Zanin
@since 23/06/2015
@version P12
/*/
//-------------------------------------------------------------------
Function P814Valor(cCampo, cValor)

Local nTamCpo	:= 0
Local cTpoCpo	:= ""
Local xValor	:= ""

nTamCpo := GetSx3Cache(cCampo, 'X3_TAMANHO') + GetSx3Cache(cCampo, 'X3_DECIMAL') //Tamanho do campo a ser gravado
cTpoCpo := GetSx3Cache(cCampo, 'X3_TIPO') //Tipo do campo a ser gravado

xValor := Left(cValor + Space(nTamCpo), nTamCpo)

//Convertemos o valor para o tipo de dado e tamanho apropriados. Ele vem como Caractere.

//Para númérico..
if cTpoCpo == "N"
	xValor := StrZero(xValor, nTamCpo)
EndIf

//Para Data
if cTpoCpo == "D"
	xValor := SToD(xValor)
EndIf

//Para Lógico
if (cTpoCpo == "L")
	if (xValor == "F")
		xValor := .F.
	elseif (xValor == "T")
		xValor := .T.
	EndIF
EndIf

Return (xValor)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA814DISP
Análise de Disponibilidade, a partir do estudo de dimensionamento gerado na rotina de
Dimensionamento de Rede
@author Oscar Zanin
@since 13/06/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA814DISP(oModel)

Local oB5G := oModel:GetModel("B5GDetail")
Local oB4H := oModel:getModel("B4HDetail")
Local nTam5G := oB5G:Length()
Local nTam4H := oB4H:Length()
Local cAno    := AllTrim(Str(Year(Date())))
Local nTam		:= oModel:getModel("B9QDetail"):Length()
Local cChvReg	:= oModel:getModel("B9QDetail"):getValue("B7L_CHVREG")
Local cCampo	:= oModel:getModel("B9QDetail"):getValue("B7L_CAMPO")
Local cEspec	:= ""
Local cCodLoc	:= ""
Local cChave	:= oModel:getModel("B9QDetail"):getValue("B7L_CHAVE")
Local cCodigo	:= oModel:getModel("MasterB98"):getValue("B98_CODIGO")
Local cCodInt := PLSINTPAD()

B7L->(DbSetOrder(3))

B7L->(MsSeek(xFilial("B7L") + cChave + "BAX_CODESP"))
cEspec	 := B7L->(B7L_VLPOS)

B7L->(MsSeek(xFilial("B7L") + cChave + "BAX_CODLOC"))
cCodLoc := B7L->(B7L_VLPOS)

If( B7L->(MsSeek(xFilial("B7L") + cChave + "BB8_CODCID")) )
	cCidade := oModel:getModel("B9VDetail"):getValue("B7L_VLPOS")
else
	BB8->(DbSetOrder(1))
	BB8->(MsSeek(xFilial("BB8") + cCodInt + cCodigo + cCodLoc ))
	cCidade := BB8->(BB8_CODLOC)
	BB8->(DbCloseArea())
EndIf

B9S->(DbSetOrder(4)) //Índice criado para esta rotina

if ( Vazio(cCodInt) .OR. Vazio(cEspec) .OR. Vazio (cAno) .OR. Vazio(cCidade) )
	MsgStop(STR0037)//"A solicitação não contém os dados necssários para a verificação!")
	return
EndIF

If B9S->(MsSeek(xFilial("B9S") + cCodInt + cEspec + cAno + cCidade))

	//Um está como NUMÉRICO e o Outro como TEXTO
	If B9S->B9S_MEDNEC < Val(B9S->B9S_MEDATU)

		If MsgYesNo("Sim, ou não?")
			oB98:SetValue('B98_STATUS', '4')
			oB5G:GoLine(nTam5G)

			If oB5G:GetValue('B5G_STATUS')
				oB5G:AddLine()

				oB5G:SetValue('B5G_CODPAS', GetNewPar('MV_MOTPAD'))
				oB5G:SetValue('B5G_DATAIN', Date())
				oB5G:SetValue('B5G_DESCRI', POSICIONE("B4G",1,XFILIAL("B4G")+PLSINTPAD()+GetNewPar('MV_MOTPAD'),"B4G_DESCRI"))
				oB4H:GoLine(nTam4H)

				If Vazio(oB4H:GetValue('B4H_OBSERV'))
					oB4H:SetValue('B4H_OBSERV', STR0038)//"Indeferimento automático devido incompatibildiade do candidato com o Estudo de Dimensionamento Atual")
					oB4H:SetValue('B4H_DATA', Date())
				else
					oB4H:AddLine()
					oB4H:SetValue('B4H_OBSERV', STR0038)//"Indeferimento automático devido incompatibildiade do candidato com o Estudo de Dimensionamento Atual")
					oB4H:SetValue('B4H_DATA', Date())
				EndIf
				oB5G:SetValue('B5G_STATUS', .T.)
				oB5G:SetValue('B5G_DATAFM', Date())
				oB5G:SetValue( "B5G_USUARI", UsrFullName( RetCodUsr() ) )
			else

				oB4H:GoLine(nTam4H)
				If Vazio(oB4H:GetValue('B4H_OBSERV'))
					oB4H:SetValue('B4H_OBSERV', STR0038) //"Indeferimento automático devido incompatibildiade do candidato com o Estudo de Dimensionamento Atual")
					oB4H:SetValue('B4H_DATA', Date())
				else
					oB4H:AddLine()
					oB4H:SetValue('B4H_OBSERV', STR0038)//"Indeferimento automático devido incompatibildiade do candidato com o Estudo de Dimensionamento Atual")
					oB4H:SetValue('B4H_DATA', Date())
				EndIf

				oB5G:SetValue('B5G_STATUS', .T.)
				oB5G:SetValue('B5G_DATAFM', Date())

				oB5G:AddLine()

				oB5G:SetValue('B5G_CODPAS', GetNewPar('MV_MOTPAD'))
				oB5G:SetValue('B5G_DATAIN', Date())
				oB5G:SetValue('B5G_DESCRI', POSICIONE("B4G",1,XFILIAL("B4G")+PLSINTPAD()+GetNewPar('MV_MOTPAD'),"B4G_DESCRI"))

				oB4H:GoLine(nTam4H)
				If Vazio(oB4H:GetValue('B4H_OBSERV'))
					oB4H:SetValue('B4H_OBSERV', STR0038)//"Indeferimento automático devido incompatibildiade do candidato com o Estudo de Dimensionamento Atual")
					oB4H:SetValue('B4H_DATA', Date())
				else
					oB4H:AddLine()
					oB4H:SetValue('B4H_OBSERV', STR0038)//"Indeferimento automático devido incompatibildiade do candidato com o Estudo de Dimensionamento Atual")
					oB4H:SetValue('B4H_DATA', Date())
				EndIf

				oB5G:SetValue('B5G_STATUS', .T.)
				oB5G:SetValue('B5G_DATAFM', Date())
				oB5G:SetValue( "B5G_USUARI", UsrFullName( RetCodUsr() ) )
			EndIf
		EndIF

	else

		MsgInfo(STR0039)//"A Candidatura do prestador para a especialidade está dentro das necessidades apontadas no estudo de dimensionamento atual")

	EndIF

else

	MsgAlert(STR0040 /*"Não há estudo de dimensionamento para basear a rotina"*/, STR0025 /*"Atenção"*/)

EndIf

B9S->(DbCloseArea())

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS814B4HV
Define os campos que irão compor a View
@author Oscar Zanin
@since 09/06/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS814B4HV(cCampo)

Local lRet := .T.

If (cCampo == "B4H_CODSEQ")
	lRet := .F.
EndIf

If (cCampo == "B4H_SEQB4H")
	lRet := .F.
EndIf

Return lRet


//----------------------------------------------------------------------
/*/{Protheus.doc} PLS814ELOG
Mostra os registros do log de alterações do portal ***Transformada na Grid 'Informações'
Mantida aqui somente para caso precisemos de um log geral no futuro***
@author Oscar Zanin
@since 09/06/2015
@version P12
/*/
//----------------------------------------------------------------------
Function PLS814ELOG(oModel)

Local oB98		:= oModel:getModel("MasterB98")
Local cCodSeq := oB98:GetValue("B98_CODSEQ")
Local aArea   := GetArea()
Local aResult := {}
Local cQuery	:= ""
Local oFont

//Trocar os B7L pelo Alias da tabela de log de alterações do Portal
//B7L_ALIAS = Campo que irá conter o Alias da tabela
//B7L_CAMPO  = Campo que irá conter o nome do campo alterado
//B7L_VLANT = Campo que irá conter o valor anterior à mudança
//B7L_VLPOS = Campo que irá conter o valor posterior à mudança
//B7L_CHAVE = Campo que irá conter o número da solicitação (para viuncular à B98)
//Descomentar o Select e Alimentar o aResult pra tudo correr bem

//--- Objetos do ListBox
Local oDlgRes
Local oLbx
Local cTitle := "Log das alterações realizadas"

//---Header do ListBox
Local cStr01 	:= "Tabela"
Local cStr02 	:= "Campo"
Local cStr03 	:= "Valor Anterior"
Local cStr04 	:= "Valor Alterado"

DEFINE FONT oFont NAME "Ms Sans Serif" BOLD

cQuery := " SELECT B7L_ALIAS, B7L_CAMPO, B7L_VLANT, B7L_VLPOS "
cQuery += " FROM " + RetSqlName('B7L') + " B7L "
cQuery += " WHERE B7L.B7L_FILIAL ='" + xFilial("B7L") + "'"
cQuery += " AND B7L.B7L_CHAVE = '" + cCodSeq +"' "
cQuery += " AND B7L.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"QUERY", .F., .T.)

If Empty(QUERY->B9S_CODMUN)
	MSGINFO("Não existe estudo para o ano selecionado","Informação")
	Return
Else
	While (!Eof())
		Aadd( aResult, { QUERY->B9S_CODMUN,POSICIONE("BID",1,XFILIAL("BID")+QUERY->B9S_CODMUN,"BID_DESCRI"), QUERY->B9S_ESPECI,POSICIONE("BAQ",7,XFILIAL("BAQ")+QUERY->B9S_ESPECI,"BAQ_DESCRI"), QUERY->B9S_MEDNEC, QUERY->B9S_MEDATU } )
		dbSkip()
	Enddo
EndIf

DEFINE MSDIALOG oDlgRes FROM 0,0 TO 600,1250 TITLE cTitle PIXEL

@ 30,01 LISTBOX oLbx FIELDS HEADER cStr01,cStr02,cStr03,cStr04 SIZE 624,250 OF oDlgRes PIXEL

oLbx:SetArray(aResult)
oLbx:bLine := {||{;
	aResult[oLbx:nAt, 1],;
	aResult[oLbx:nAt, 2],;
	aResult[oLbx:nAt, 3],;
	aResult[oLbx:nAt, 4]}}

ACTIVATE MSDIALOG oDlgRes ON INIT ( EnchoiceBar( oDlgRes, {|| oDlgRes:End() }, {|| oDlgRes:End() } ) ) CENTERED

oFont:End()
DeleteObject( oDlgRes )
DeleteObject( oLbx )
QUERY->(dbCloseArea())
RestArea( aArea )

Return Nil

//----------------------------------------------------------------------
/*/{Protheus.doc} PLS814GRVS
Função para realizar a grvação dos dados da solicitação de Aditivo contratual
no portal.
@author Oscar Zanin
@since 10/06/2015
@version P12
/*/
//----------------------------------------------------------------------
Function PLS814GRVS(cCodSol, cCodRDA, cObserv)

Local cCodInt	:= PLSINTPAD()
Local cCodSeq	:= ""

BEGIN TRANSACTION

	B98->(DbSetOrder(1))

	RecLock("B98", .T.)

	//Gerar Sequencial
	cCodSeq := B98->(GetSX8num("B98", "B98_CODSEQ"))
	B98->(ConfirmSX8())

	B98->(B98_FILIAL) := xFilial("B98")
	B98->(B98_STATUS) := "0" //Solicitação com documentos pendentes
	B98->(B98_CODSEQ)	:= cCodSeq
	B98->(B98_CODIGO)	:= StrZero( Val(cCodRDA), 6)
	B98->(B98_CODSOL)	:= /*StrZero( Val(cCodRDA), 6)+*/cCodSol
	B98->(B98_CODINT)	:= cCodInt
	B98->(B98_TIPSOL)	:= '6'
	//Se há observação..
	If !(Vazio(cObserv))
		B98->(B98_OBSERV)	:= Left(cObserv, TamSX3("B98_OBSERV")[1])
	EndIf
	MsUnlock()
END TRANSACTION

Return (cCodSeq)


//----------------------------------------------------------------------
/*/{Protheus.doc} PLS814SEND
Ativa o Registro da solicitação para a análise.

@author Oscar Zanin
@since 10/06/2015
@version P12
/*/
//----------------------------------------------------------------------
Function PLS814SEND(cCodRDA, cChave)

Local lB98		:= .F.
Local cRet		:= ""

//Observação
//Partes comentadas são para vinculação do envio de e-mail para o Solicitante
//Não será desenvolvido no momento, mas caso venha a ser, já há um início aqui
BEGIN TRANSACTION
	If (Select("B98") == 0)
		DbSelectArea("B98")
		lB98 := .T.
	EndIf
	B98->(DbSetOrder(1))
	B98->(MsSeek(xFilial("B98")+cChave))
	if(B98->(MsSeek(xFilial("B98")+cChave)))
		RecLock("B98", .F.)
		//		B98->(B98_ATIVO) := .T.
		B98->(B98_STATUS)	:= "1"
		B98->(B98_DATA)	:= dDatabase
		MsUnlock()
	EndIf

	If lB98
		B98->(DbCloseArea())
	EndIf

END TRANSACTION

Return (cRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS814CRDA
Abre a tela da RDA posicionada para ajustar o conteúdo.
@author Oscar Zanin
@since 10/06/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS814CRDA(oModel, nRot)

Local oB98			:= oModel:GetModel('MasterB98')
Local nOper	 		:= oModel:GetOperation()
Local cCodRDA		:= oB98:GetValue("B98_CODIGO")

Static aRetorno	:= {}

//Grupo de Variáveis provenientes do PLSA360, estão aqui pra chamar a rotina sem passar pelo Browse
PRIVATE aRotina     := PLS813Menu() //Esta função é o MenuDef do PLSA360. Só está qui devido o MenuDef ser STATIC.
PRIVATE cCadastro   := FunDesc() //Rede de Atendimento (RDA) - Cadastro
PRIVATE aHeader     := {}
PRIVATE aCols       := {}
PRIVATE n           := 1
PRIVATE lUsrConf    := .F.
PRIVATE aCdCores    := {}
Private K_Excluir   := 5
Private K_Incluir   := 3
Private K_Alterar   := 4

If (!(empty(cCodRDA)))

	if nRot == 1
		PLS813PRDA(oModel, cCodRDA, nOper) //Direciona para a Tela de RDA
	else

		PLS814Comp(oModel, cCodRDA, nOper) //Direciona para a Tela de Complemento da RDA
	EndIf
EndIF

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS814B7LV
Definição dos campos que pertencerão à View
@author Oscar Zanin
@since 05/06/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS814B7LV(cCampo)

Local lRet := .F.

If (cCampo == "B7L_GRAVAD") .OR.	(cCampo == "B7L_VLANT ");
	.OR.	(cCampo == "B7L_VLPOS ");
	.OR.	(cCampo == "B7L_DATA  ");
	.OR.	(cCampo == "B7L_HORA  ");
	.OR.	(cCampo == "B7L_USER  ")

	lRet := .T.
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS814SX2
Busca o nome da tabela no arquivo SX2
@author Oscar Zanin
@since 18/06/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS814SX2(cTabela)

Local cNomeAlias	:= ""

if (Select("SX2")==0)
	DbSelectArea("SX2")
EndIf
SX2->(DbSelectArea(1))
SX2->(MsSeek(cTabela))
cNomeAlias := SX2->(X2_NOME)

return (cNomeAlias)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS814SX3
Busca o nome do campo nmo arquivo X3
@author Oscar Zanin
@since 18/06/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS814SX3(cCampo, cCpoX3)

Local xValor	:= ""

If !(Vazio(cCampo))
	xValor := GetSx3Cache(cCampo, cCpoX3)
EndIf

return (xValor)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS814VLD1
Valid da Grid da B5G
@author Oscar Zanin
@since 18/06/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS814VLD1(oModel)

Local lRet := .F.
Local lB4G := .F.
Local cCodPas	:= oModel:GetModel("B5GDetail"):getValue("B5G_CODPAS")

//Não usar o ExistCpo.
If (select("B4G") == 0)
	DbSelectArea("B4G")
	lB4G := .T.
EndIf

If ( B4G->(MsSeek(xFilial('B4G') + cCodPas)) .OR. Vazio(cCodPas) )
	lRet := .T.
EndIf

return (lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS814Sinc
Sincroniza as informações de aprovação dos campos nas Grids de Especialidade,
Localidade, Informaçõas, Corpo Clínico e Procedimentos.
@author Oscar Zanin
@since 26/06/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS814Sinc(oModel, oView)

Local oB7L  	:= oModel:getModel("B7LDetail")
Local oB9Q		:= oModel:getModel("B9QDetail")
Local oB9V		:= oModel:getModel("B9VDetail")
Local oBC1		:= oModel:getModel("BC1Detail")
Local oBC0		:= oModel:getModel("BC0Detail")
Local nTamV	:= oB9V:Length()
Local nTamQ	:= oB9Q:Length()
Local nTam 	:= oB7L:Length()
Local nTamBC1	:= oBC1:Length()
Local nTamBC0	:= oBC0:Length()
Local nI    	:= 0
Local cChave	:= oB9Q:getValue("B7L_CHAVE")
Local cChvReg	:= oB9Q:getValue("B7L_CHVREG")
Local lStatus	:= oB9Q:getValue("B7L_GRAVAD")
Local cChaveBC1	:= oBC1:getValue("B7L_CHAVE")
Local cChvRegBC1	:= oBC1:getValue("B7L_CHVREG")
Local lStatusBC1	:= oBC1:getValue("B7L_GRAVAD")
Local cChaveBC0	:= oBC0:getValue("B7L_CHAVE")
Local cChvRegBC0	:= oBC0:getValue("B7L_CHVREG")
Local lStatusBC0	:= oBC0:getValue("B7L_GRAVAD")


For nI := 1 To nTam
	oB7L:GoLine(nI)
	If ( (oB7L:getValue("B7L_ALIAS") == "BAX" .OR. oB7L:getValue("B7L_ALIAS") == "BB8") .AND. oB7L:getValue("B7L_CHAVE") == cChave .AND. oB7L:getValue("B7L_CHVREG") == cChvReg )
		P814when2(oModel, .T.)
		oB7L:loadValue("B7L_GRAVAD", lStatus)
	EndIf
Next

For nI := 1 To nTamQ
	oB9Q:GoLine(nI)
	If ( (oB9Q:getValue("B7L_ALIAS") == "BAX") .AND. oB9Q:getValue("B7L_CHAVE") == cChave .AND. oB9Q:getValue("B7L_CHVREG") == cChvReg )
		oB9Q:loadValue("B7L_GRAVAD", lStatus)
	EndIf
Next

For nI := 1 To nTamV
	oB9V:GoLine(nI)
	If ( (oB9V:getValue("B7L_ALIAS") == "BB8") .AND. oB9V:getValue("B7L_CHAVE") == cChave .AND. oB9V:getValue("B7L_CHVREG") == cChvReg )
		oB9V:loadValue("B7L_GRAVAD", lStatus)
	EndIf
Next

For nI := 1 To nTamBC1
	oBC1:GoLine(nI)
	oB7L:GoLine(nI)
	If ( (oBC1:getValue("B7L_ALIAS") == "BC1") .AND. oBC1:getValue("B7L_CHAVE") == cChaveBC1 .AND. oBC1:getValue("B7L_CHVREG") == cChvRegBC1 )
		oBC1:loadValue("B7L_GRAVAD", lStatusBC1)
		oB7L:loadValue("B7L_GRAVAD", lStatusBC1)
	EndIf
Next

For nI := 1 To nTamBC0
	oB7L:GoLine(nI)
	oBC0:GoLine(nI)
	If ( (oBC0:getValue("B7L_ALIAS") == "BC0") .AND. oBC0:getValue("B7L_CHAVE") == cChaveBC0 .AND. oBC0:getValue("B7L_CHVREG") == cChvRegBC0 )
		oBC0:loadValue("B7L_GRAVAD", lStatusBC0)
		oB7L:loadValue("B7L_GRAVAD", lStatusBC0)
	EndIf
Next

oView:refresh()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} P814when2
Faz a tela se comportar como deve, permitindo marcar/desmarcar somente os
itens de especialidade na aba especialidade, travando os de localidade e
liberando os demais na aba de Informações.
Atualizada para corpo clínico e procedimentos.
@author Oscar Zanin
@since 26/06/2015
@version P12
/*/
//-------------------------------------------------------------------
Function P814when2(oModel, lTrueRet)

Local oB7L	:= oModel:getModel("B7LDetail")
Local cTabela  := oB7L:getValue("B7L_ALIAS")
Local lRet := .T.

If !EMPTY(lTrueRet)
	Return lTrueRet
EndIf

If (cTabela == "BAX" .OR. cTabela == "BB8" .OR. cTabela == "BC1" .OR. cTabela == "BC0")
	lRet := .F.
else
	lRet := PLS814WHEN(oModel)
EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS814BC1
Manipula os registros da B7L para alimentar corretamente as tabelas:
- BB0 (Profissionais)
- BC1 (Corpo Clínico)
@author rodrigo.morgon
@since 20/07/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS814BC1(aDados)

Local i 		:= 1 
Local n 		:= 1
Local lRet	 	:= .T.
Local aArea 	:= GetArea()
Local nNovoCodP := ""
local aCampBC1 	:= {"BC1_CODIGO", "BC1_CODINT", "BC1_CODLOC", "BC1_CODESP", "BC1_ESTCR", "BC1_NUMCR", "BC1_SIGLCR"}
LOCAL cChave 	:= ""
LOCAL lAchouBC1 := .F.
LOCAL nPos	    := 0
local cCodInt 	:= PlsIntpad()

//Ordena o array aDados para garantir que o CGC esteja localizado antes dos outros campos.
aSort(aDados,,, { |x, y| x[2, 1] + x[2, 2] < y[2, 1] + y[2, 2]})

	BC1->(DbSetOrder(2)) //index 2: BC1_FILIAL, BC1_CODIGO, BC1_CODINT, BC1_CODLOC, BC1_CODESP, BC1_ESTCR, BC1_NUMCR, BC1_SIGLCR, R_E_C_N_O_, D_E_L_E_T_
		cChave := ""
		FOR n := 1 TO LEN(aCampBC1)
			nPos := ASCAN(aDados, {| x| ALLTRIM(x[2, 2]) == aCampBC1[n]})
			IF nPos > 0
				cChave  += PADR(aDados[nPos, 2, 3], TamSx3(aCampBC1[n])[1])  
			ENDIF
		NEXT
		cChave2 :=  SubStr(cChave, 1, 6) + cCodInt + SubStr(cChave, 7, len(cChave)) // variavel criada para adicionar o codint no seek  
		lAchouBC1 := BC1->(MsSeek(xFilial() + cChave2))

IF (!lAchouBC1) //verifica se existe duplicidade de registros 
		if (aDados[i] <> NIL .and. (aDados[i, 2, 1] == "BC1" .and. aDados[i, 2, 2] == PADR("BB0_CGC", 10)))

			//Profissional não encontrado, alterar ALIAS do campo BB0_CGC de BC1 para BB0
			aDados[i, 2, 1] := "BB0"

			//Adiciona campo de vínculo (BB0_VINC)
			aadd(aDados, {Len(aDados)+1, {"BB0", PADR("BB0_VINC", 10),	"1",	SPACE(3), "1", aDados[i, 2, 6]}})

			//Obtem novo codigo de profissional
			nNovoCodP := GETSX8NUM("BB0","BB0_CODIGO")

			//Adiciona campo de codigo do profissional (BB0_CODIGO)
			aadd(aDados, {Len(aDados)+1, {"BB0", PADR("BB0_CODIGO", 10),	nNovoCodP,	SPACE(3), "1", aDados[i, 2, 6]}})

			//Adiciona codigo do profissional ao corpo clínico
			aadd(aDados, {Len(aDados)+1, {"BC1", PADR("BC1_CODPRF", 10),	nNovoCodP, SPACE(3), "1", aDados[i, 2, 6]}})					

		endif

		aadd(aDados, {Len(aDados)+1, {"BC1", PADR("BC1_CODINT", 10),	PLSINTPAD(), ALLTRIM(STR(BC1->(RECNO()))), IIF(BC1->(EOF()), "1", "2"), aDados[i, 2, 6]}})
		aadd(aDados, {Len(aDados)+1, {"BC1", PADR("BC1_TIPLAN", 10),	"2"  	   ,SPACE(3), "1", aDados[i, 2, 6]}})

		for i := 1 to Len(aDados)

			if (aDados[i, 2, 2] == PADR("BC1_NOMPRF", 10)) 
				AAdd(aDados, {Len(aDados)+1, {"BB0", PADR("BB0_NOME"  , 10), aDados[i, 2, 3], SPACE(3), "1", aDados[i, 2, 6]}})
			elseif (aDados[i, 2, 2] == PADR("BC1_SIGLCR", 10)) 
				AAdd(aDados, {Len(aDados)+1, {"BB0", PADR("BB0_CODSIG", 10), aDados[i, 2, 3], SPACE(3), "1", aDados[i, 2, 6]}})
			elseif (aDados[i, 2, 2] == PADR("BC1_NUMCR" , 10)) 
				AAdd(aDados, {Len(aDados)+1, {"BB0", PADR("BB0_NUMCR" , 10), aDados[i, 2, 3], SPACE(3), "1", aDados[i, 2, 6]}})
			elseif (aDados[i, 2, 2] == PADR("BC1_ESTCR" , 10)) 
				AAdd(aDados, {Len(aDados)+1, {"BB0", PADR("BB0_ESTADO", 10), aDados[i, 2, 3], SPACE(3), "1", aDados[i, 2, 6]}})
			endif

		next

		aadd(aDados, {Len(aDados)+1, {"BB0", PADR("BB0_CODOPE", 10),	PLSINTPAD(), ALLTRIM(STR(BB0->(RECNO()))), IIF(BB0->(EOF()), "1", "2"), aDados[i, 2, 6]}})
else
	aDados := {} // caso exista duplicidade de registros zeramos o array e não gravamos nenhum campo
endif
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS814LOG
Faz gravação da solicitação + tabela de log para a rotina de corpo clínico
@author Oscar Zanin
@since 22/07/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS814LOG(cDados, cLogin)

Local cXFilial 	:= xFilial("B7L")
Local cCodInt 	:= PLSINTPAD()
Local cCodSeq 	:= ""
Local aDados 	:= Separa(cDados, '~')
Local cSequen 	:= ""
Local cRet 		:= ""
Local nI 		:= 1
Local lGrava 	:= .T.
Local cChave 	:= ""
LOCAL nPos 		:= 0
LOCAL aCmpBlq 	:= {"BC1_CODBLO", "BC1_MOTBLO", "BC1_DATBLO", "BC1_OBSERV"}	//	Limpar esses campos se estiver Bloqueado
LOCAL xConteudo := ""
LOCAL lAchou 	:= .F.
LOCAL cAliasBC1 := "" 
LOCAL cAliasB7L := "" // variável resposável para verificar se existe algum registro repetido/existente na B7L


For nI := 1 To Len(aDados)
	aDados[nI] := Separa(aDados[nI], ';')
Next

cAliasB7L := valB7L(aDados) 
lAchou 	  := !( (cAliasB7L)->(eOf()) ) // verifico se já não existe algum registro na base para não gerar duplicidade.

If lAchou 
	lGrava := .F.
EndIF

IF lGrava
	B7L->(DbSetOrder(2))
	If B7L->(MsSeek(xFilial() + "BC1" + aDados[5, 1]))
		WHILE !B7L->(EOF()) .AND. xFilial() + "BC1" + ALLTRIM(aDados[5, 1]) == B7L->(B7L_FILIAL + B7L_ALIAS + ALLTRIM(B7L_VLPOS))
			lGrava := B7L->B7L_GRAVAD	//	Isso irá permitir que o Clinico seja reativado varias vezes
			B7L->(DBSKIP())
		ENDDO
	EndIf
ENDIF

If lGrava
	BEGIN TRANSACTION
		
		cAliasBC1 := valBC1(aDados)
		//Validação do sequencial para evitar erros de chave duplicada
		cCodSeq := getSXENum("B98", "B98_CODSEQ")
        B98->(confirmSX8())
                
        B98->(DbSetOrder(1))
        while B98->(MsSeek(xFilial("B98") + cCodSeq))
            cCodSeq := getSXENum("B98", "B98_CODSEQ")
            B98->(confirmSX8())
        enddo		
				
		B98->(RecLock("B98", .T.))
    		B98->B98_FILIAL	:= cXFilial
    		B98->B98_STATUS	:= "1"
    		B98->B98_CODSEQ	:= cCodSeq
    		B98->B98_CODIGO	:= StrZero( Val(aDados[1, 1]), 6)
    		B98->B98_CODSOL	:= GetNewPar("MV_PLSB98", "999998")
    		B98->B98_CODINT	:= cCodInt
    		B98->B98_DATA	:= dDatabase
    		B98->B98_TIPSOL := '4'
		B98->(MsUnlock())
		
		For nI := 1 To len(aDados)
			xConteudo := ""
			
			//Validação do sequencial para evitar erros de chave duplicada
            cSequen := GetSXENum("B7L", "B7L_SEQUEN")
            B7L->(confirmSX8())
                    
            B7L->(DbSetOrder(1))
            while B7L->(MsSeek(xFilial("B7L") + cSequen))
                cSequen := GetSXENum("B7L", "B7L_SEQUEN")
                B7L->(confirmSX8())
            enddo
            
			B7L->(Reclock("B7L", .T.))
    			B7L->B7L_FILIAL := cXFilial
    			B7L->B7L_SEQUEN := cSequen
    			B7L->B7L_ALIAS  := "BC1"
    			B7L->B7L_CAMPO  := aDados[nI, 2]
    			B7L->B7L_ALIACH := "B98"
    			B7L->B7L_CHAVE  := cCodSeq
    			IF !( (cAliasBC1)->(eOf()) )
    				IF (nPos := (cAliasBC1)->(FIELDPOS(aDados[nI, 2]))) > 0
    					xConteudo := (cAliasBC1)->(FIELDGET(nPos))
    					IF     VALTYPE(xConteudo) == "D"
    						xConteudo := DTOC(xConteudo)
    					ELSEIF VALTYPE(xConteudo) == "N"
    						xConteudo := ALLTRIM(STR(xConteudo))
    					ENDIF
    				ENDIF
    			ENDIF
    			B7L->B7L_VLANT  := xConteudo
    			B7L->B7L_VLPOS  := aDados[nI, 1]
    			B7L->B7L_GRAVAD := .F.
    			B7L->B7L_TIPO   := IIF(lAchou, "2", "1")	//	Alteração, Inclusão
    			B7L->B7L_RECREG := IIF(lAchou, ALLTRIM(STR((cAliasBC1)->(RECNO()))), "0")
    			B7L->B7L_DATA   := dDataBase
    			B7L->B7L_HORA   := Left(Time(), 5)
    			B7L->B7L_USER   := cLogin
    			B7L->B7L_CHVREG := "1"
			B7L->(MsUnlock())
		Next
		
		IF !( (cAliasBC1)->(eOf()) )	//	Achou um item Bloqueado
			For nI := 1 To len(aCmpBlq)	//	Insere os Campos de Bloqueio
				xConteudo := ""
				
				//Validação do sequencial para evitar erros de chave duplicada
                cSequen := GetSXENum("B7L", "B7L_SEQUEN")
                B7L->(confirmSX8())
                        
                B7L->(DbSetOrder(1))
                while B7L->(MsSeek(xFilial("B7L") + cSequen))
                    cSequen := GetSXENum("B7L", "B7L_SEQUEN")
                    B7L->(confirmSX8())
                enddo
                
				B7L->(Reclock("B7L", .T.))				
    				B7L->B7L_FILIAL := cXFilial
    				B7L->B7L_SEQUEN := cSequen
    				B7L->B7L_ALIAS  := "BC1"
    				B7L->B7L_CAMPO  := aCmpBlq[nI]
    				B7L->B7L_ALIACH := "B98"
    				B7L->B7L_CHAVE  := cCodSeq
    				
    				IF (nPos := (cAliasBC1)->(FIELDPOS(aCmpBlq[nI]))) > 0
    					xConteudo := (cAliasBC1)->(FIELDGET(nPos))
    					IF     VALTYPE(xConteudo) == "D"
    						xConteudo := DTOC(xConteudo)
    					ELSEIF VALTYPE(xConteudo) == "N"
    						xConteudo := ALLTRIM(STR(xConteudo))
    					ENDIF
    				ENDIF
    				
    				B7L->B7L_VLANT  := xConteudo
    				B7L->B7L_VLPOS  := ""	//	Limpa Campo de Desbloqueo
    				B7L->B7L_GRAVAD := .F.
    				B7L->B7L_TIPO   := "2"	//	Alteração
    				B7L->B7L_RECREG := ALLTRIM(STR((cAliasBC1)->(RECNO())))
    				B7L->B7L_DATA   := dDataBase
    				B7L->B7L_HORA   := Left(Time(), 5)
    				B7L->B7L_USER   := cLogin
    				B7L->B7L_CHVREG := "1"
				B7L->(MsUnlock())
			Next
		ENDIF
	(cAliasBC1)->(dbcloseArea())
	END TRANSACTION
	(cAliasB7L)->(dbcloseArea())
	cRet := cCodSeq
EndIf

Return (cRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS814PROC
Faz gravação da solicitação de inclusão/bloqueio/desbloqueio de procedimento
@author Rodrigo Morgon
@since 21/08/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS814PROC(aDados, cLogin)

Local cXFilial   := xFilial("B7L")
Local cCodInt	 := PLSINTPAD()
Local cCodSeq	 := ""
Local cSequen    := ""
Local cRet		 := ""
Local nI		 := 1
Local lGrava     := .T.
Local lExclu     := .F.
Local cChave     := ""
Local aConteudo  := {}
Local nX		 := 1
Local nY		 := 1
Local cPadBkp    := ""
Local cRecNo 	 := 0
Local cCdPadPro  := NIL

PRIVATE aTabDup := PlsBusTerDup(SuperGetMv("MV_TISSCAB",.F.,"87"))

For nI := 1 To Len(aDados)

	aConteudo := {}

	for nY := 1 to Len(aDados[nI])
		aadd(aConteudo, Separa(aDados[nI, nY], "@"))
	next

	for nY := 1 to Len(aConteudo)
		aConteudo[nY, 2] := Separa(aConteudo[nY, 2],"*")[1]
	next

	//Faz gravação para cada linha de registro da grid.

	//DE/PARA do procedimento da tabela da ANS para o código interno do Protheus
	cPadBkp := PLSGETVINC("BTU_VLRBUS", "BR4", .F., "87", aConteudo[4, 2], .T.)
	aConteudo[4, 2] := AllTrim(cPadBkp)

	cCdPadPro := PLSGETVINC("BTU_VLRBUS", "BR8", .F., aConteudo[4, 2],  aConteudo[4, 2] + AllTrim(aConteudo[5, 2]), .F. ,aTabDup, @cPadBkp)

	//BC0_FILIAL+BC0_CODIGO+BC0_CODINT+BC0_CODLOC+BC0_CODESP+BC0_CODTAB+BC0_CODOPC
	cChave := xFilial("BC0") + aConteudo[1, 2] + cCodInt + aConteudo[2, 2] + aConteudo[3, 2] + PADR(aConteudo[4, 2],3) + PADR(cCdPadPro,16)

	//Define se será exclusão do log
	lExclu := (aConteudo[6, 2] == "2")

	BC0->(DbSetOrder(1))
	//Verifica se já existe registro e se a solicitação no log é de exclusão.
	If BC0->(MsSeek(cChave))
		If lExclu
			cRecNo := BC0->(RecNo())
		Else
			lGrava := .F.
		EndIf
	EndIf

	If lGrava
		BEGIN TRANSACTION
			B98->(DbSetOrder(1))
			RecLock("B98", .T.)
			cCodSeq := B98->(GetSX8num("B98", "B98_CODSEQ")) //Gerar Sequencial
			B98->(ConfirmSX8())
			B98->(B98_FILIAL) := xFilial("B98")
			B98->(B98_STATUS) := "1"
			B98->(B98_CODSEQ)	:= cCodSeq
			B98->(B98_CODIGO)	:= StrZero( Val(aConteudo[1, 2]), 6)
			B98->(B98_CODSOL)	:= GetNewPar("MV_PLSB98", "999998")
			B98->(B98_CODINT)	:= cCodInt
			B98->(B98_DATA)	:= dDatabase
			B98->(B98_TIPSOL)	:= '5'
			MsUnlock()
			//Adiciona campos fixos para o procedimento
			aadd(aConteudo, {"BC0_FORMUL", "1"})
			aadd(aConteudo, {"BC0_TIPO", "3"})
			aadd(aConteudo, {"BC0_CODINT", cCodInt})

			For nX := 1 To len(aConteudo)
				Reclock("B7L", .T.)
				B7L->B7L_FILIAL := cXFilial
				cSequen := GetSXENum("B7L","B7L_SEQUEN")
				B7L->(ConfirmSx8())
				B7L->B7L_SEQUEN 	:= cSequen
				B7L->B7L_ALIAS	:= "BC0"
				B7L->B7L_CAMPO	:= aConteudo[nX, 1]
				B7L->B7L_ALIACH	:= "B98"
				B7L->B7L_CHAVE	:= cCodSeq
				If lExclu
					B7L->B7L_VLANT	:= aConteudo[nX, 2]
					B7L->B7L_VLPOS	:= "Excluído"
					B7L->B7L_TIPO		:= "3"
					B7L->B7L_RECREG	:= AllTrim(Str(cRecNo))
				Else
					B7L->B7L_VLANT	:= ""
					B7L->B7L_VLPOS	:= aConteudo[nX, 2]
					B7L->B7L_TIPO	:= "1"
					B7L->B7L_RECREG	:= "0"
				EndIf
				B7L->B7L_GRAVAD	:= .F.
				B7L->B7L_DATA		:= dDataBase
				B7L->B7L_HORA		:= Left(Time(),5)
				B7L->B7L_USER		:= cLogin
				B7L->B7L_CHVREG	:= "1"
				MsUnlock()
			Next
		END TRANSACTION
		cRet := "true|" + cCodSeq
	Else
		cRet := "false|Registro já existente."
	EndIf
Next

Return (cRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} P814CHKABA
Verifica a análise da solicitação, gera um alerta sobre as abas que tem
itens informados, porém não foram deferidos.
É chamada ao inserir um passo de Conslusão ou Indeferimento.
@author Oscar Zanin
@since 26/10/2015
@version P12
/*/
//-------------------------------------------------------------------
Function P814CHKABA(oModel, cB7L)

Local oAAA		:= oModel:getModel(cB7L)
Local aAux		:= {}
Local cRet		:= "" + chr(13) + chr(13)
Local nI		:= 0

For nI := 1 TO oAAA:Length()
	oAAA:GoLine(nI)
	If !(oAAA:GetValue("B7L_GRAVAD")) .AND. Ascan(aAux, AllTrim(oAAA:getValue('B7L_ALIAS'))) == 0
		Aadd(aAux, AllTrim(oAAA:getValue('B7L_ALIAS')))
	EndIf
Next

If Len(aAux) > 0

	cRet += "Observações" + chr(13) + chr(13)

	For nI := 1 To Len(aAux)
		Do Case
			Case aAux[nI] == "BAX"
				cRet += "Há dados informados e não deferidos na aba 'Especialidade'" + chr(13)
			Case aAux[nI] == "BB8"
				cRet += "Há dados informados e não deferidos na aba 'Endereço'" + chr(13)
			Case aAux[nI] == "BC0"
				cRet += "Há dados informados e não deferidos na aba 'Procedimentos'" + chr(13)
			Case aAux[nI] == "BC1"
				cRet += "Há dados informados e não deferidos na aba 'Corpo Clínico'" + chr(13)
			Otherwise
				cRet += "Há dados informados e não deferidos na aba 'Informações'" + chr(13)
		EndCase
	Next

EndIf

Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS814Comp
Envia para o Complemento do cadastro da RDA
@author Oscar Zanin
@since 25/04/2016
@version P12
/*/
//-------------------------------------------------------------------
Function PLS814Comp(oModel, cCodRDA, nOper)

Local nRecno	:= 9999999

BAU->(DbSetOrder(1)) //Esta área deve permanecer aberta até o final da função, para que o sistema
//não perca o registro quando chamarmos o cadastro de RDA em modo alteração.

IF BAU->(MsSeek(xFilial("BAU") + cCodRDA))

	nRecno := BAU->(Recno()) //Conseguimos o Recno do registro
EndIf

If nRecno <> 9999999

	PLSA365MNT("BAU",nRecno,4) //Chamada do Complemento da RDA
Else

	MsgStop(STR0045 /*"Opção disponível apenas para RDAs cadastradas!"*/)
EndIf

BAU->(DbCloseArea())

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PL814FBRW ºAutor  ³Karine Riquena Limp º Data ³  10.05.16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que abre a rotina de solicitação de alteração       º±±
±±º          ³ contratual com filtros                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PL814FBRW(cCodRda,cDescription)
private aRotina := {}

aAdd( aRotina, { 'Pesquisar' , 				'PesqBrw'         , 0, 1, 0, .T. } )
aAdd( aRotina, { 'Visualizar', 				'VIEWDEF.PLSA814' , 0, 2, 0, NIL } )
PLSA814(cCodRda, cDescription)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLInSrB5G
Inicializador padrão do campo B5G_CODSEQ, com semáforo, para evitar duplicidade de código.
@since 07/2019
@version P12
/*/
//-------------------------------------------------------------------
Function PLInSrB5G()
local cSeqB5G	:= ""
local nSemaf	:= PLSAbreSem("PLSEMB5G.SMF")

cSeqB5G := B5G->(getSx8Num('B5G', 'B5G_CODSEQ',, 5))

B5G->(dbSetOrder(5)) //B5G_FILIAL+B5G_CODSEQ
while B5G->( dbSeek( xFilial("B5G") + cSeqB5G ) )
	cSeqB5G := BXX->(getSx8Num('B5G', 'B5G_CODSEQ',, 5))
endDo

PLSFechaSem(nSemaf,"PLSEMB5G.SMF")
Return cSeqB5G

/*/
{Protheus.doc} VrLinha
	Caso a flag B7L_GRAVAD seja marcada mas a linha estiver vazia ela sera apagada.
	@type  Static Function
	@author user
	@since 08/2020
	@version P12
	@param param, param_type, param_descr
/*/	
Static Function VrLinha(oModel)
local lret      := .T.
local Ncont     := 0
Local oObjBC1	:= oModel:getModel("BC1Detail")
Local oObjBC0	:= oModel:getModel("BC0Detail")
Local oObjB9Q   := oModel:getModel("B9QDetail")
Local oObjB9V   := oModel:getModel("B9VDetail")


For Ncont := 1 to oObjBC1:Length()
	oObjBC1:GoLine(Ncont)
	if ( oObjBC1:getValue("B7L_GRAVAD") == .T. .AND. empty(oObjBC1:getValue("B7L_CHAVE")) .AND. empty(oObjBC1:getValue("B7L_ALIAS")) .AND.  empty(oObjBC1:getValue("B7L_ALIACH"))  )
		oObjBC1:DeleteLine()
	endif
Next

For Ncont := 1 to oObjBC0:Length()
	oObjBC0:GoLine(Ncont)
	if ( oObjBC0:getValue("B7L_GRAVAD") == .T. .AND. empty(oObjBC0:getValue("B7L_CHAVE")) .AND. empty(oObjBC0:getValue("B7L_ALIAS")) .AND.  empty(oObjBC0:getValue("B7L_ALIACH"))  )
		oObjBC0:DeleteLine()
	endif
Next

For Ncont := 1 to oObjB9Q:Length()
	oObjB9Q:GoLine(Ncont)
	if ( oObjB9Q:getValue("B7L_GRAVAD") == .T. .AND. empty(oObjB9Q:getValue("B7L_CHAVE")) .AND. empty(oObjB9Q:getValue("B7L_ALIAS")) .AND.  empty(oObjB9Q:getValue("B7L_ALIACH"))  )
		oObjB9Q:DeleteLine()
	endif
Next

For Ncont := 1 to oObjB9V:Length()
	oObjB9V:GoLine(Ncont)
	if ( oObjB9V:getValue("B7L_GRAVAD") == .T. .AND. empty(oObjB9V:getValue("B7L_CHAVE")) .AND. empty(oObjB9V:getValue("B7L_ALIAS")) .AND.  empty(oObjB9V:getValue("B7L_ALIACH"))  )
		oObjB9V:DeleteLine()
	endif
Next

Return lret


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} valBC1
@author    Daniel Silva 
@version   P12
@since     23/08/2022
/*/	

static function valBC1(aRet)

local oFwQuery  := FWPreparedStatement():New()
local cSql      := ""
local cAlias 	:= ""
local cNumCr	:= PADR(aret[5, 1], TamSX3("BC1_NUMCR")[1])
Local cCodInt 	:= PLSINTPAD()
	 
cSql := " SELECT BC1_CODIGO, BC1_CODINT, BC1_CODLOC, BC1_CODESP, BC1_ESTCR, BC1_NUMCR, BC1_SIGLCR, BC1_CODBLO, BC1_MOTBLO, BC1_DATBLO, BC1_OBSERV  " 
cSql += " FROM " + RetSqlName("BC1") + " BC1 "
cSql += " WHERE BC1_FILIAL = ? "
cSql += " AND   BC1_CODIGO = ? "
cSql += " AND   BC1_CODINT = ? "
cSql += " AND   BC1_CODLOC = ? " 
cSql += " AND   BC1_CODESP = ? " 
cSql += " AND   BC1_ESTCR = ? "  
cSql += " AND   BC1_NUMCR = ? "
cSql += " AND   BC1_SIGLCR = ? " 
cSql += " AND   D_E_L_E_T_ = ? " 


cSql := ChangeQuery(cSql)
oFwQuery:SetQuery(cSql)
oFwQuery:SetString(1, xFilial("BCI"))
oFwQuery:SetString(2, aRet[1][1])
oFwQuery:SetString(3, cCodInt)
oFwQuery:SetString(4, aRet[2][1])
oFwQuery:SetString(5, aRet[3][1])
oFwQuery:SetString(6, alltrim(aRet[6][1]))
oFwQuery:SetString(7, cNumCr)
oFwQuery:SetString(8, aRet[8][1])
oFwQuery:SetString(9, ' ')
cSql   := oFwQuery:GetFixQuery()
cAlias := MpSysOpenQuery(cSql)

RETURN cAlias

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} valB7L
verifica se existem registros duplicados na B7L.
@author    Daniel Silva 
@version   P12
@since     23/08/2022
/*/

static function valB7L(aRet)

local oFwQuery  := FWPreparedStatement():New()
local cSql      := ""
local cAlias 	:= ""
local cNumCr	:= PADR(aret[5, 1], TamSX3("BC1_NUMCR")[1])
local filial 	:= xFilial("B7L")
	 
cSql := " SELECT A.B7L_CHAVE, A.B7L_VLANT, A.B7L_VLPOS, A.R_E_C_N_O_ "
cSql += " FROM " + RetSqlName("B7L") + " A "
cSql += 	" INNER JOIN " + RetSqlName("B7L") + " B "
cSql += " ON B.B7L_FILIAL = A.B7L_FILIAL AND "
cSql += " B.B7L_CHAVE = A.B7L_CHAVE "
cSql += 	" INNER JOIN " + RetSqlName("B7L") + " C "
cSql += " ON C.B7L_FILIAL = A.B7L_FILIAL AND "
cSql += " C.B7L_CHAVE = A.B7L_CHAVE "
cSql += 	" INNER JOIN " + RetSqlName("B7L") + " D "
cSql += " ON D.B7L_FILIAL = D.B7L_FILIAL AND "
cSql += " D.B7L_CHAVE = A.B7L_CHAVE "
cSql += 	" INNER JOIN " + RetSqlName("B7L") + " E "
cSql += " ON E.B7L_FILIAL = E.B7L_FILIAL AND "
cSql += " E.B7L_CHAVE = A.B7L_CHAVE "
cSql += 	" INNER JOIN " + RetSqlName("B7L") + " F "
cSql += " ON F.B7L_FILIAL = F.B7L_FILIAL AND "
cSql += " F.B7L_CHAVE = A.B7L_CHAVE "
cSql += 	" WHERE "
cSql += " (A.B7L_FILIAL = '" + filial + "'  AND A.B7L_CAMPO = 'BC1_NUMCR ' AND A.B7L_VLPOS = ? AND A.D_E_L_E_T_ = ' ')  AND " 
cSql += " (B.B7L_FILIAL = '" + filial + "'  AND B.B7L_CAMPO = 'BC1_CODIGO' AND B.B7L_VLPOS = ? AND B.D_E_L_E_T_ = ' ')  AND "
cSql += " (C.B7L_FILIAL = '" + filial + "'  AND C.B7L_CAMPO = 'BC1_ESTCR'  AND C.B7L_VLPOS = ? AND C.D_E_L_E_T_ = ' ')  AND "
cSql += " (D.B7L_FILIAL = '" + filial + "'  AND D.B7L_CAMPO = 'BC1_SIGLCR' AND D.B7L_VLPOS = ? AND D.D_E_L_E_T_ = ' ')  AND "
cSql += " (E.B7L_FILIAL = '" + filial + "'  AND E.B7L_CAMPO = 'BC1_CODLOC' AND E.B7L_VLPOS = ? AND E.D_E_L_E_T_ = ' ')  AND "
cSql += " (F.B7L_FILIAL = '" + filial + "'  AND F.B7L_CAMPO = 'BC1_CODESP' AND F.B7L_VLPOS = ? AND F.D_E_L_E_T_ = ' ')  "
cSql += " GROUP BY A.B7L_CHAVE, A.B7L_VLANT, A.B7L_VLPOS, A.R_E_C_N_O_ "

cSql := ChangeQuery(cSql)
oFwQuery:SetQuery(cSql)
oFwQuery:SetString(1, cNumCr) 
oFwQuery:SetString(2, aRet[1][1]) 
oFwQuery:SetString(3, alltrim(aRet[6][1])) 
oFwQuery:SetString(4, aRet[8][1])
oFwQuery:SetString(5, aRet[2][1]) 
oFwQuery:SetString(6, aRet[3][1]) 
cSql   := oFwQuery:GetFixQuery()
cAlias := MpSysOpenQuery(cSql)

return cAlias

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} valB7L
verifica se o status atual do registro pode ser analisado
@author    Daniel Silva 
@version   P12
@since     12/09/2022
/*/

function vldAnalise()

local lret := .t.

if (B98_STATUS == "3")  
	Help(nil, nil , "Não é possível analisar o registro", nil, "Profissional com status Concluído", 1, 0, nil, nil, nil, nil, nil, {} )
elseif(B98_STATUS == "4")
	Help(nil, nil , "Não é possível analisar o registro", nil, "Profissional com status Indeferido", 1, 0, nil, nil, nil, nil, nil, {} )
else 
	FWExecView('Analisar','PLSA814', MODEL_OPERATION_UPDATE,, {|| .T. } )
endif 
	
return lret

