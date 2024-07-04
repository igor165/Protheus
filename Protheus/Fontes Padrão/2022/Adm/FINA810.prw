#include 'PROTHEUS.CH'
#include 'FWMVCDEF.CH'
#include 'FINA810.CH'
#include 'FWEDITPANEL.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA810
Cadastros de Layouts de Cartas de Cobranca

@author Pedro Pereira Lima
@since 27/08/2015
@version 12.1.7
/*/
//-------------------------------------------------------------------
Function FINA810()
	Local oBrowse 		As Object
	Private cFilter		As Character
	Private cExpression As Character

	cFilter		:= ''
	cExpression	:= ''

	If !TableInDic("FWP") .OR. !TableInDic("FWQ") .OR. !TableInDic("FWS") .OR. !TableInDic("FWT") 
        MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
        Return()	
	EndIf

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'FWP' )
	oBrowse:SetDescription( STR0001 ) //'Cartas de Cobrança'

	//Adiciona Legenda                                           
	oBrowse:AddLegend("FWP_STATUS == '1' " , "GREEN",STR0002) //Ativo
	oBrowse:AddLegend("FWP_STATUS == '2' " , "RED"	,STR0003) //Inativo
		
	//Cria a consulta de maneira dinamica
	MPSx3LKOn("SX3SE1",STR0013,{"X3_CAMPO","X3_TITULO"},"SX3->X3_ARQUIVO == 'SE1'") //'Campos "Títulos a Receber"'
		
	oBrowse:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição de Menu

@author Pedro Pereira Lima
@since 27/08/2015
@version 12.1.7
/*/
//-------------------------------------------------------------------
Static Function MenuDef() As Array
	Local aRotina As Array
	
	aRotina := {}

	ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.FINA810' OPERATION 2 ACCESS 0 //'Visualizar'
	ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.FINA810' OPERATION 3 ACCESS 0 //'Incluir'
	ADD OPTION aRotina Title STR0006 Action 'VIEWDEF.FINA810' OPERATION 4 ACCESS 0 //'Alterar'
	ADD OPTION aRotina Title STR0007 Action 'VIEWDEF.FINA810' OPERATION 5 ACCESS 0 //'Excluir'
	ADD OPTION aRotina Title STR0008 Action 'VIEWDEF.FINA810' OPERATION 8 ACCESS 0 //'Imprimir'

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Cria a estrutura a ser usada no Modelo de Dados

@author Pedro Pereira Lima
@since 27/08/2015
@version 12.1.7
/*/
//-------------------------------------------------------------------
Static Function ModelDef() As Object
	Local oStruFWP	As Object
	Local oStruFWQ	As Object
	Local oStruFWS	As Object
	Local oModel	As Object
	Local bWhenCod	As Codeblock
	Local bWhen		As Codeblock
	Local bInit		As CodeBlock
	Local bIniFWQ	As Codeblock
	Local bValid	As Codeblock
	Local bValFWS	As Codeblock

	oStruFWP 	:= FWFormStruct( 1, 'FWP', /*bAvalCampo*/, /*lViewUsado*/ )
	oStruFWQ 	:= FWFormStruct( 1, 'FWQ', /*bAvalCampo*/, /*lViewUsado*/ )
	oStruFWS 	:= FWFormStruct( 1, 'FWS', /*bAvalCampo*/, /*lViewUsado*/ )

	bWhenCod	:= FWBuildFeature( STRUCT_FEATURE_WHEN  , "INCLUI")
	bWhen		:= FWBuildFeature( STRUCT_FEATURE_WHEN  , "M->FWP_ENVIO $ '2|3'")
	bInit		:= FWBuildFeature( STRUCT_FEATURE_INIPAD, "1")
	bIniFWQ		:= FWBuildFeature( STRUCT_FEATURE_INIPAD,"Iif(!INCLUI,Fa810InitF(),'')")
	bValid		:= FWBuildFeature( STRUCT_FEATURE_VALID , "ExistChav('FWP')")
	bValFWS		:= FWBuildFeature( STRUCT_FEATURE_VALID , "Fa810VldSX('SE1',M->FWS_CAMPO) .Or. Fa180VldFd( M->FWS_CAMPO )")

	// Seto a propriedade dos campos
	oStruFWP:SetProperty('FWP_CODCRT' ,MODEL_FIELD_WHEN,bWhenCod)
	oStruFWP:SetProperty('FWP_CODCRT' ,MODEL_FIELD_VALID,bValid)
	oStruFWP:SetProperty('FWP_POSVER' ,MODEL_FIELD_WHEN,bWhen)
	oStruFWP:SetProperty('FWP_POSHOR' ,MODEL_FIELD_WHEN,bWhen)
	oStruFWP:SetProperty('FWP_STATUS' ,MODEL_FIELD_INIT,bInit)
	oStruFWP:SetProperty('FWP_ENVIO'  ,MODEL_FIELD_INIT,bInit)
	oStruFWS:SetProperty('FWS_CAMPO'  ,MODEL_FIELD_VALID,bValFWS)

	// Adiciono o campo virtual 'FWQ_EXPRES' na estrutura da FWQ
	oStruFWQ:AddField( STR0014,STR0015,'FWQ_EXPRES','C',254,0,/*bValid*/,{|| .T.},/**/,.F.,bIniFWQ,,,.T.) // 'Expressão' - 'Expressão de Filtro'

	// Instancio o model da rotinda
	oModel := MPFormModel():New(STR0009, /*bPreValidacao*/ ,/*bTudoOk*/,{ |oModel| Fa810GrvMd( oModel ) },/*bCancel*/) //'FINA810'

	// Definição da hierarquia do model
	// MASTER - Layout da Carta de Cobrança
	oModel:AddFields( 'FWPMASTER', /*cOwner*/ , oStruFWP,/*bPreValidacao*/ , /*bPosValidacao*/ , /*bPreVal*/ , /*bPosVal*/ , /*BLoad*/ )
	// DETAIL - Regras de Filtro
	oModel:AddFields( 'FWQDETAIL', 'FWPMASTER', oStruFWQ,/*bPreValidacao*/ , /*bPosValidacao*/ , /*bPreVal*/ , /*bPosVal*/ , /*BLoad*/ )
	// DETAIL - Dados dos Títulos
	oModel:AddGrid( 'FWSDETAIL', 'FWPMASTER',oStruFWS,/*bPreValidacao*/ , /*bPosValidacao*/ , /*bPreVal*/ , /*bPosVal*/ , /*BLoad*/ )

	// Definição do relacionamento entre as entidades dentro da hierarquia
	oModel:SetRelation( 'FWQDETAIL', { { 'FWQ_FILIAL', 'xFilial( "FWQ" )' }, { 'FWQ_LAYOUT', 'FWP_CODCRT' } }, FWQ->( IndexKey( 1 ) ) )
	oModel:SetRelation( 'FWSDETAIL', { { 'FWS_FILIAL', 'xFilial( "FWS" )' }, { 'FWS_LAYOUT', 'FWP_CODCRT' } }, FWS->( IndexKey( 1 ) ) )

	//Definição da chave primária
	oModel:SetPrimaryKey({'FWP_FILIAL','FWP_CODCRT'})

	// Seto a descrição dos model's
	oModel:SetDescription( STR0001 ) //'Cartas de Cobrança'
	oModel:GetModel( 'FWPMASTER' ):SetDescription( STR0010 ) //'Layout da Carta de Cobrança'
	oModel:GetModel( 'FWQDETAIL' ):SetDescription( STR0011 ) //'Regras de Envio'
	oModel:GetModel( 'FWSDETAIL' ):SetDescription( STR0012 ) //'Dados dos Títulos'

	//Seto a linha única da grid
	oModel:GetModel( 'FWSDETAIL' ):SetUniqueLine( {'FWS_CAMPO'} )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definição de View do Sistema

@author Pedro Pereira Lima
@since 27/08/2015
@version 12.1.7
/*/
//-------------------------------------------------------------------
Static Function ViewDef() As Object
	// Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
	Local oModel	As Object

	// Cria as estruturas a serem usadas na View
	Local oStruFWP	As Object
	Local oStruFWQ	As Object
	Local oStruFWS	As Object

	// Interface de visualização
	Local oView		As Object

	oModel   := FWLoadModel( STR0009 )
	oStruFWP := FWFormStruct( 2, 'FWP' )
	oStruFWQ := FWFormViewStruct():New() //Defino a estrutura de forma manual para essa view
	oStruFWS := FWFormViewStruct():New() //Defino a estrutura de forma manual para essa view

	// Seto os campos da view manulmente
	oStruFWQ:AddField('FWQ_EXPRES','02',STR0014,STR0015,{},'C',''  ,/*bPictVar*/,'FWQFIL'   ,.T.)
	oStruFWS:AddField('FWS_SEQ'   ,'01',STR0020,STR0021,{},'C','@!',/*bPictVar*/,/*cLookUp*/,.T.)
	oStruFWS:AddField('FWS_CAMPO' ,'02',STR0016,STR0017,{},'C','@!',/*bPictVar*/,'SX3SE1'   ,.T.)
	oStruFWS:AddField('FWS_DESCRI','03',STR0018,STR0019,{},'C',''  ,/*bPictVar*/,/*cLookUp*/,.T.)

	// Instancio a interface
	oView := FWFormView():New()
	// Definição do model da interface
	oView:SetModel(oModel)

	// Definição das Fields e Grids e suas respectivas estruturas
	oView:AddField('FWPMASTER', oStruFWP )
	oView:AddField('FWQDETAIL', oStruFWQ )
	oView:AddGrid('FWSDETAIL' , oStruFWS)

	//Defino o campo incremental
	oView:AddIncrementField('FWSDETAIL' , 'FWS_SEQ')

	// Defino o layout da view
	oView:SetViewProperty("FWPMASTER","SETLAYOUT",{FF_LAYOUT_HORZ_DESCR_TOP,4})

	// Definição do layout da interface
	oView:CreateHorizontalBox( 'BOXSUP', 065)
	oView:CreateHorizontalBox( 'BOXINF', 035)

	// Criação do folder
	oView:CreateFolder('FOLDERINF', 'BOXINF')

	// Definição das folhas
	oView:AddSheet('FOLDERINF','SHEETFWQ',STR0011)
	oView:AddSheet('FOLDERINF','SHEETFWS',STR0012)

	// Definição do Owner da view principal
	oView:SetOwnerView('FWPMASTER','BOXSUP')

	//Definição do Owner da view filha 1 (FWQ)
	oView:CreateHorizontalBox( 'BOXFWQ', 100, /*owner*/, /*lUsePixel*/, 'FOLDERINF', 'SHEETFWQ')
	oView:SetOwnerView('FWQDETAIL','BOXFWQ')

	//Definição do Owner da view filha 2 (FWS)
	oView:CreateHorizontalBox( 'BOXFWS', 100, /*owner*/, /*lUsePixel*/, 'FOLDERINF', 'SHEETFWS')
	oView:SetOwnerView('FWSDETAIL','BOXFWS')

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} Fa810Filtr()
Executa rotina para montar expressão de filtro que será gravada no campo FWQ_FILTRA
Utilizada na consulta específica do campo FWQ_FILTRA

@author Pedro Pereira Lima
@since 28/08/2015
@version 12.1.7
/*/
//-------------------------------------------------------------------
Function Fa810Filtr() As Logical
	Local cTable	As Character
	
	cTable := 'SA1'

	cFilter 	:= ''
	cExpression	:= ''

	cFilter		:= BuildExpr(cTable,,/*cFiltro*/,.T.,,,,,,,,.T.,.F.)
	cExpression := MontDescr(cTable,cFilter,.T.,.F.)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} Fa810RetF()
Retorna a expressão de filtro convertida em texto
Utilizada na consulta específica do campo FWQ_FILTRA

@author Pedro Pereira Lima
@since 28/08/2015
@version 12.1.7
/*/
//-------------------------------------------------------------------
Function Fa810RetF() As Character
//Função para retornar a variável (private) contendo a expressão de filtro
//Devido a tipagem da função, pode ocorrer mensagem de warning do tipo "warning W0017 'return' : cannot convert from 'U' to 'C'"
Return cExpression

//-------------------------------------------------------------------
/*/{Protheus.doc} Fa810InitF()
Inicializador padrão do campo virtual FWQ_EXPRES

@author Pedro Pereira Lima
@since 31/08/2015
@version 12.1.7
/*/
//-------------------------------------------------------------------
Function Fa810InitF() As Character
	Local cReturn	As Character
	Local cTable	As Character

	cReturn	:= ''
	cTable	:= 'SA1'
	
	If !Empty(FWQ->FWQ_FILTRA)
		cReturn := MontDescr(cTable,FWQ->FWQ_FILTRA,.T.,.F.)
	EndIf

Return cReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} Fa810GrvMd()
Função para gravação do Model

@author Pedro Pereira Lima
@since 31/08/2015
@version 12.1.7
/*/
//-------------------------------------------------------------------
Function Fa810GrvMd( oModel As Object ) As Logical
	Local oModelFWQ	As Object

	oModelFWQ := oModel:GetModel( 'FWQDETAIL' )

	If oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:GetOperation() == MODEL_OPERATION_UPDATE
		oModelFWQ:SetValue( 'FWQ_FILTRA' , cFilter)
	EndIf

	FWFormCommit( oModel )

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} Fa810VldSX()
Função para validação da linha do grid FWS, verificando se o campo
selecionado/digitado existe no SX3

@author Pedro Pereira Lima
@since 31/08/2015
@version 12.1.7
/*/
//-------------------------------------------------------------------
Function Fa810VldSX( cTable As Character, cCampo As Character ) As Logical
	Local lRet	As Logical

	Default cTable := ''
	Default cCampo := ''

	lRet := .F.

	If !Empty(cTable) .And. !Empty(cCampo)
		SX3->(dbSetOrder(2))
		SX3->(dbSeek(AllTrim(cCampo)))
	
		If SX3->X3_ARQUIVO == cTable
			lRet := .T.
		EndIf
	EndIf

	If lRet
		lRet := ExistCpo('SX3',M->FWS_CAMPO,2)
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Fa180VldFd()
Função para validação da linha do grid FWS, verificando se o campo
digitado é um dos campos específicos. São eles:
DATRASO - Quantidade de dias em que o título está atrasado
TOTAL - Valor total do título, considerando juros, multas e etc.

@author Pedro Pereira Lima
@since 31/08/2015
@version 12.1.7
/*/
//-------------------------------------------------------------------
Function Fa180VldFd( cCampo As Character ) As Logical
	Local lRet		As Logical
	Local oCampo	As Object
	
	lRet 	:= .F.
	oCampo	:= FWModelActive()	

	cCampo := AllTrim(cCampo)

	If cCampo == "DATRASO" .Or. cCampo == "TOTAL"
		lRet := .T.
	
		If cCampo == "DATRASO"
			oCampo:LoadValue('FWSDETAIL','FWS_DESCRI',STR0022)
		ElseIf cCampo == "TOTAL"
			oCampo:LoadValue('FWSDETAIL','FWS_DESCRI',STR0023)
		EndIf
	EndIf

Return lRet