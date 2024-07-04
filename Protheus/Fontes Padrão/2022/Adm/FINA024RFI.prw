#Include 'Protheus.ch'
#Include "FWMVCDEF.CH"
#INCLUDE "FINA024RFI.CH"


// Fatos Geradores
#DEFINE fgCOMPETENCIA	'1'
#DEFINE fgCAIXA			'2'

// Tipos de Movimento
#DEFINE tmABATIMENTO	'1'
#DEFINE tmPROVISAO		'2'
#DEFINE tmRETENCAO		'3'
#DEFINE tmNAOGERAR		'4'

#DEFINE OPER_ALTERAR		10
#DEFINE OPER_ATIVAR	        11
#DEFINE OPER_COPIAR			12
#DEFINE OPER_VIGENCIA       13
#DEFINE OPER_IMPORTAR       14
#DEFINE OPER_EXPORTAR       15


Static cTblBrowse	:= "FKK"
Static nTamDFOO	:= 60
Static nTamDTip	:= 30
Static __nOper 	:= 0 // Operacao da rotina
Static __lConfirmou:= .F.
Static __lVersao   := .F.
Static __cTipoTits := NIL
Static __lBlind	:= IsBlind()
Static __lGerTitRet := .F.


//---------------------------------
/*/{Protheus.doc} FINA024RFI
Regras Financeiras de Retenção

@author  Sivaldo Oliveira
@since 21/08/25/08/2018
@version 12
/*/
//---------------------------------
Function FINA024RFI(aRotAut As Array, nOpcAut)
	Local aLegenda As Array

	Default aRotAut := {}
	Default nOpcAut := 0

	//Verifico se as tabelas existem antes de prosseguir
	IF AliasIndic("FKK")

		DBSelectArea("FOO")
		DBSelectArea("FKK")
		FKK->(dbSetOrder(2))

		//Inicializa variáveis
		aLegenda := {{"FKK_ATIVO == '1'", "GREEN", STR0002}, {"FKK_ATIVO == '2'", "RED", STR0003}}

		If Len(aRotAut) > 0
			FWMVCRotAuto(FWLoadModel("FINA024RFI"), cTblBrowse, nOpcAut, {{"FKKMASTER", aRotAut}}, , .T.)
		Else
			FxBrowse(cTblBrowse, 2, STR0001, aLegenda)		//"Regras Financeiras de Retenção"
		EndIf

	Else
	    Help("",1,"Help","Help",STR0057,1,0) // 'Dicionário desatualizado, verifique as atualizações do motor tributário Financeiro'
	EndIf

Return

//---------------------------------
/*/{Protheus.doc} MenuDef
Menu
@author  Sivaldo Oliveira
@since 21/08/25/08/2018
@version 12
/*/
//---------------------------------
Static Function MenuDef() As Array
	Local aRotina  As Array
	Local aTitMenu As Array
	Local aActions As Array

	//Inicializa variáveis
	aTitMenu := { {STR0007, "F24FKKATV", 4}, {STR0008, "F024FKKCOP", OP_COPIA}, {"Ajustar Vigência", "F24FKKVIG", 4} }	//"Ativar/Desativar"###"Copiar"
	aActions := { {STR0003, "F024FKKVIS"}, {STR0004, "F024FKKINC"}, {STR0005, "F024FKKALT"}, {STR0006, "F024FKKEXC"} }		//"Visualizar"###"Incluir"###"Alterar"###"Excluir"
	aRotina := FxMenuDef(.T., aTitMenu, aActions)

Return aRotina

//---------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados do detalhe de tipo de retenção
@author  Sivaldo Oliveira
@since 21/08/25/08/2018
@version 12
/*/
//---------------------------------
Static Function ModelDef() As Object
	Local oModel  As Object
	Local oStruFKK As Object
	Local oStruFOO As Object
	Local aRelFOO As Array
	Local bFormPos As CodeBlock
	Local bLinPosFOO As CodeBlock


	//Inicializa variáveis.
	oModel  := Nil
	aRelFOO := {}
	oStruFKK    := FxStruct(1, cTblBrowse)
	oStruFOO    := FxStruct(1, "FOO")

	bFormPos	:= {||F024FKKPos()}
	bLinPosFOO	:= {||F024FOOPos()}

	//Instacia o objeto
	//	oModel := MPFormModel():New("FINA024RFI", Nil, Nil, Nil, Nil)
	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New("FINA024RFI", /*bPreValidacao*/, {||F024RFITOK()} /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

	//Adiciona uma um submodel editável/fields
	// Adiciona ao modelo uma estrutura de formulario de edicao por campo
	oModel:AddFields("FKKMASTER", /*cOwner*/, oStruFKK, /*bPreValidacao*/, bFormPos/*bPosValidacao*/,  /*bLoad*/ )
	oModel:AddGrid( "FOODETAIL", "FKKMASTER", oStruFOO, /*bLinePre*/, bLinPosFOO, /*bPre*/, /*bPos*/, /*bLoad*/)

	//Relacionamento do modelo de dados
	//Cria Relacionamentos FOO -> FKK -> FOO - Tipos de impostos.
	aAdd(aRelFOO	,{ "FOO_FILIAL"	,"xFilial('FOO')"} )
	aAdd(aRelFOO	,{ "FOO_IDRET"	,"FKK_IDRET" 	} )
	oModel:SetRelation("FOODETAIL"	, aRelFOO	, FOO->( IndexKey(1) ))

	// Adiciona UniqueLine por Item na Grid
	oModel:GetModel( "FOODETAIL" ):SetUniqueLine( { "FOO_CODIGO" } )
	oModel:GetModel( "FOODETAIL" ):SetDelAllLine( .F. )

	//Deixa o prrenchimento das tabelas opcional
	oModel:GetModel( 'FOODETAIL' ):SetOptional( .T. )

	//Complementa as informações da estrutura do model
	oStruFKK:SetProperty('FKK_IDRET'  , MODEL_FIELD_INIT , {|| F024FKKRET() } )
	oStruFKK:SetProperty('FKK_VERSAO' , MODEL_FIELD_INIT , {|| F024FKKVER() } )
	oStruFKK:SetProperty('FKK_CODIGO' , MODEL_FIELD_WHEN , {|| F024FKKWHE(oModel,'FKK_CODIGO') } )
	oStruFKK:SetProperty('FKK_PROVIS' , MODEL_FIELD_WHEN , {|| F024FKKWHE(oModel,'FKK_PROVIS') } )

	If __nOper == OPER_ALTERAR
		oStruFKK:SetProperty('FKK_ATIVO'  ,MODEL_FIELD_WHEN , {|| .F. } )
	Endif

	If __nOper == OPER_ATIVAR
		oStruFKK:SetProperty( '*'  ,MODEL_FIELD_WHEN , {|| .F. } )
		oStruFKK:SetProperty('FKK_ATIVO'  ,MODEL_FIELD_WHEN , {|| .T. } )
	Endif

	If __nOper == OPER_VIGENCIA
		oStruFKK:SetProperty( '*'  ,MODEL_FIELD_WHEN , {|| .F. } )
		oStruFKK:SetProperty('FKK_VIGINI'  ,MODEL_FIELD_WHEN , {|| .T. } )
		oStruFKK:SetProperty('FKK_VIGFIM'  ,MODEL_FIELD_WHEN , {|| .T. } )
	Endif


	//Ativa o modelo
	oModel:SetActivate()

Return oModel

//---------------------------------
/*/{Protheus.doc} ViewDef
Criação da View
@author  Sivaldo Oliveira
@since 10/09//2018
@version 12
/*/
//---------------------------------
Static Function ViewDef() As Object
	Local oModel As Object
	Local oView  As Object
	Local oFKK   As Object
	Local oFOO		As Object

	//Inicializa as variáveis
	oModel := FWLoadModel("FINA024RFI")
	oView  := FWFormView():New()
	oFKK   := FxStruct(2, cTblBrowse, Nil, Nil, /*{"FKK_IDRET"}*/, Nil)
	oFOO   := FxStruct(2, "FOO", Nil, Nil, /*{"FKK_IDRET"}*/, Nil)

	//Seta o modelo de dados a ser usado na view
	oView:SetModel(oModel)

	// Cria box visual para separação dos elementos em tela.
	oView:createHorizontalBox( "FORM", 50, /*cIdOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/ )
	oView:createHorizontalBox( "GRID", 50, /*cIdOwner*/, /*lFixPixel*/, /*cIDFolder*/, /*cIDSheet*/ )

	//Adiciona na grid um controle de FormFields
	oView:AddField("VIEWFKK", oFKK, "FKKMASTER")
	oView:EnableTitleView("VIEWFKK", STR0009 )		//"Regras Financeiras"
	oView:SetDescription(STR0001)					//"Regras Financeiras de Retenção"

	oView:AddGrid( "VIEWFOO", oFOO, "FOODETAIL" )
	oView:EnableTitleView("VIEWFOO", "Tributo" )		//"Tipo de Imposto" STR0010

	oView:SetOwnerView( "VIEWFKK", "FORM" )
	oView:SetOwnerView( "VIEWFOO", "GRID" )

	//Retira campos que não ser?o apresentados na View
	oFKK:RemoveField('FKK_IDRET')
	oFKK:RemoveField('FKK_IDFKL')
	oFKK:RemoveField('FKK_IDFKN')
	oFKK:RemoveField('FKK_IDFKO')
	oFKK:RemoveField('FKK_IDFKP')
	oFKK:RemoveField('FKK_IDFKU')
	oFOO:RemoveField('FOO_IDRET')

	oFKK:SetProperty( 'FKK_VERSAO'	, MVC_VIEW_CANCHANGE , .F. )
	oFKK:SetProperty( 'FKK_PROVIS'	, MVC_VIEW_ORDEM,	'10')
	oFKK:SetProperty( 'FKK_ATIVO'	, MVC_VIEW_ORDEM,	'11')
	oFKK:SetProperty( 'FKK_CODRET'	, MVC_VIEW_ORDEM,	'12')
	oFKK:SetProperty( 'FKK_DSCRET'	, MVC_VIEW_ORDEM,	'13')
	oFKK:SetProperty( 'FKK_CODFKP'	, MVC_VIEW_ORDEM,	'13')
	oFKK:SetProperty( 'FKK_DSCFKP'	, MVC_VIEW_ORDEM,	'14')
	oFKK:SetProperty( 'FKK_CODFKL'	, MVC_VIEW_ORDEM,	'15')
	oFKK:SetProperty( 'FKK_DSCFKL'	, MVC_VIEW_ORDEM,	'16')
	oFKK:SetProperty( 'FKK_CODFKN'	, MVC_VIEW_ORDEM,	'17')
	oFKK:SetProperty( 'FKK_DSCFKN'	, MVC_VIEW_ORDEM,	'18')
	oFKK:SetProperty( 'FKK_CODFKO'	, MVC_VIEW_ORDEM,	'19')
	oFKK:SetProperty( 'FKK_DSCFKO'	, MVC_VIEW_ORDEM,	'20')
	oFKK:SetProperty( 'FKK_CODFKU'	, MVC_VIEW_ORDEM,	'21')
	oFKK:SetProperty( 'FKK_DSCFKU'	, MVC_VIEW_ORDEM,	'22')
	oFKK:SetProperty( 'FKK_CONTA'	, MVC_VIEW_ORDEM,	'27')
	oFKK:SetProperty( 'FKK_CTADSC'	, MVC_VIEW_ORDEM,	'28')
	oFKK:SetProperty( 'FKK_CUSTO'	, MVC_VIEW_ORDEM,	'29')
	oFKK:SetProperty( 'FKK_CUSDSC'	, MVC_VIEW_ORDEM,	'30')
	oFKK:SetProperty( 'FKK_ITEM'	, MVC_VIEW_ORDEM,	'31')
	oFKK:SetProperty( 'FKK_ITEDSC'	, MVC_VIEW_ORDEM,	'32')
	oFKK:SetProperty( 'FKK_CLVL'	, MVC_VIEW_ORDEM,	'33')
	oFKK:SetProperty( 'FKK_CLVLDC'	, MVC_VIEW_ORDEM,	'34')
	oFKK:SetProperty( 'FKK_VARCTB'	, MVC_VIEW_ORDEM,	'35')

	oFKK:SetProperty( 'FKK_CODFKL'	, MVC_VIEW_TITULO    , STR0012 )				//"Regra de Título"
	oFKK:SetProperty( 'FKK_CODFKN'	, MVC_VIEW_TITULO    , STR0013 )				//"Regra de Cálculo"
	oFKK:SetProperty( 'FKK_CODFKO'	, MVC_VIEW_TITULO    , STR0014 )				//"Regra de Retenção"
	oFKK:SetProperty( 'FKK_CODFKP'	, MVC_VIEW_TITULO    , STR0015 )				//"Regra de Vencimento"
	oFKK:SetProperty( 'FKK_CODFKU'	, MVC_VIEW_TITULO    , STR0016 )				//"Regra de Valores Acessórios"
	oFKK:SetProperty( 'FKK_PROVIS'	, MVC_VIEW_TITULO    , STR0077 )				//"Gerar Provisão"
	oFKK:SetProperty( 'FKK_CART'	, MVC_VIEW_TITULO    , STR0078 )				//"Aplica-se a Carteira"
	oFKK:SetProperty( 'FKK_VIGINI'	, MVC_VIEW_TITULO    , STR0079 )				//"Inicio da Vigência"
	oFKK:SetProperty( 'FKK_VIGFIM'	, MVC_VIEW_TITULO    , STR0080 )				//"Fim da Vigência"

	oFOO:SetProperty( 'FOO_DESCR'	, MVC_VIEW_ORDEM     , '04')
	oFOO:SetProperty( 'FOO_TIPIMP'	, MVC_VIEW_ORDEM     , '05')
	oFOO:SetProperty( 'FOO_TIPIMP'	, MVC_VIEW_TITULO    , STR0011)		//'Classificação do tipo de imposto'

	oFKK:SetProperty('FKK_CODFKL', MVC_VIEW_LOOKUP, { || F024F3FRI("FKK_CODFKL") } )
	oFKK:SetProperty('FKK_CODFKN', MVC_VIEW_LOOKUP, { || F024F3FRI("FKK_CODFKN") } )
	oFKK:SetProperty('FKK_CODFKO', MVC_VIEW_LOOKUP, { || F024F3FRI("FKK_CODFKO") } )
	oFKK:SetProperty('FKK_CODFKP', MVC_VIEW_LOOKUP, { || F024F3FRI("FKK_CODFKP") } )
	oFKK:SetProperty('FKK_CODFKU', MVC_VIEW_LOOKUP, { || F024F3FRI("FKK_CODFKU") } )

	oFOO:SetProperty('FOO_CODIGO', MVC_VIEW_LOOKUP, { || F024F3FRI("FOO_CODIGO") } )

	If __nOper == OPER_ALTERAR .OR. __nOper == OPER_COPIAR
		oView:SetAfterViewActivate({|oView| F024FKKAft(oView)})
	EndIf

	If __nOper == OPER_ATIVAR .or. __nOper == OPER_ALTERAR  .or. __nOper == OPER_VIGENCIA
		oView:SetOnlyView( "VIEWFOO", "GRID" )
	EndIf

Return oView


//---------------------------------
/*/{Protheus.doc} F024FKKVIS
Define a operação de VISUALIZAÇÃO
@author  Sivaldo Oliveira
@since 10/09//2018
@version 12
/*/
//---------------------------------
Function F024FKKVIS()
	Local oModel   As Object
	Local nOpc	   As Numeric
	Local aButtons As Array

	//Inicializa variáveis
	oModel   := Nil
	nOpc     := MODEL_OPERATION_VIEW
	__nOper  := nOpc
	aButtons := {}

	aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
	oModel := FwLoadModel("FINA024RFI")
	oModel:SetOperation(nOpc)
	oModel:Activate()

	FWExecView( STR0003, "FINA024RFI", nOpc,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,,aButtons,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, oModel )		//"Incluir"

	oModel:Deactivate()
	oModel:Destroy()
	oModel:= Nil

	__nOper := 0

	FKK->(DBSETORDER(2))	//"FKK_FILIAL+FKK_CODIGO+FKK_VERSAO"

Return



//---------------------------------
/*/{Protheus.doc} F024FKKINC
Define a operação de inclusão
@author  Sivaldo Oliveira
@since 10/09//2018
@version 12
/*/
//---------------------------------
Function F024FKKINC()
	Local oModel   As Object
	Local nOpc	   As Numeric
	Local aButtons As Array

	//Inicializa variáveis
	oModel   := Nil
	nOpc     := MODEL_OPERATION_INSERT
	__nOper  := nOpc
	aButtons := {}

	aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
	oModel := FwLoadModel("FINA024RFI")
	oModel:SetOperation(nOpc)
	oModel:Activate()

	FWExecView( OemToAnsi(STR0004), "FINA024RFI", nOpc,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,,aButtons,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, oModel )		//"Incluir"

	oModel:Deactivate()
	oModel:Destroy()
	oModel:= Nil

	__nOper := 0

	FKK->(DBSETORDER(2))	//"FKK_FILIAL+FKK_CODIGO+FKK_VERSAO"

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F024FKKALT()
Define operacao de exclusao

@author  Mauricio Pequim Jr
@since	14/09/2018
@version 12
/*/
//-------------------------------------------------------------------
Function F024FKKALT()

	Local nOpc As Numeric
	Local aEnableButtons As Array
	Local nRecFKK As Numeric
	Local nRecAtu As Numeric

	aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"###"Fechar"

	nOpc := OP_COPIA
	nRecFKK := FKK->(Recno())
	nRecAtu := 0

	__nOper := OPER_ALTERAR
	__lConfirmou := .F.

	//Somente versões ativas podem ser alteradas/versionadas
	If FKK->FKK_ATIVO == "1"
		FWExecView( STR0005 , "FINA024RFI", nOpc,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,,aEnableButtons,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, /*oModel*/ ) //'Alterar'
	Else
		HELP(' ',1,"F024Altera" ,,STR0017,2,0,,,,,, {STR0018})	//"Somente versões ativas podem sofrer alterações."###"Caso queira reutilizar este cadastro de tipo de reteenção, utilize a opção Cópia ou utilize a opção Ativar/Desativar para alterar o status do cadastro de tipo de impostos."
	EndIf

	__lConfirmou := .F.
	__lVersao := .F.
	__nOper := 0

	FKK->(DBSETORDER(2))	//"FKK_FILIAL+FKK_CODIGO+FKK_VERSAO"

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} F024FKKEXC()
Define operacao de exclusao

@author  Mauricio Pequim Jr
@since	14/09/2018
@version 12
/*/
//-------------------------------------------------------------------
Function F024FKKEXC()

	Local oModel	As Object
	Local nOpc		As Numeric
	Local aEnableButtons	As Array
	Local lExclui		As Logical

	aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"###"Fechar"

	nOpc := MODEL_OPERATION_DELETE

	oModel := FwLoadModel("FINA024RFI")
	oModel:SetOperation(nOpc)
	oModel:Activate()

	lExclui		:= F024VldExc(oModel)

	If lExclui
		FWExecView( STR0006 ,"FINA024RFI", nOpc,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,,aEnableButtons,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, oModel ) //'Excluir'
	Else
		HELP(' ',1,"FA024EXC" ,,STR0019,2,0,,,,,, {STR0020})	//"Exclusão não permitida."###"Por favor, verifique se este imposto não se encontra relacionado a um cadastro de Naturezas, Fornecedor ou Cliente. Neste caso pode-se desativar este tipo de imposto."
	Endif
	oModel:Deactivate()
	oModel:Destroy()
	oModel:= Nil
	FKK->(DBSETORDER(2))	//"FKK_FILIAL+FKK_CODIGO+FKK_VERSAO"

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} F024FKKCOP()
Define operacao de CÓPIA

@author  Mauricio Pequim Jr
@since	14/09/2018
@version 12
/*/
//-------------------------------------------------------------------
Function F024FKKCOP()

	Local nOpc		As Numeric
	Local aEnableButtons	As Array

	aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"###"Fechar"

	nOpc := OP_COPIA

	__nOper := OPER_COPIAR
	__lConfirmou := .F.

	FWExecView( STR0008 , "FINA024RFI", nOpc,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,,aEnableButtons,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, /*oModel*/ ) //'Copiar'

	__lConfirmou := .F.
	__lVersao := .F.
	__nOper := 0

	FKK->(DBSETORDER(2))	//"FKK_FILIAL+FKK_CODIGO+FKK_VERSAO"

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} F24FKKATV()
Define operacao PARA ATIVAR OU DESATIVAR um cadastro de regra
financeira

@author  Mauricio Pequim Jr
@since	14/09/2018
@version 12
/*/
//-------------------------------------------------------------------
Function F24FKKATV()

	Local nOpc As Numeric
	Local aEnableButtons As Array

	aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"###"Fechar"

	nOpc := MODEL_OPERATION_UPDATE

	__nOper := OPER_ATIVAR
	__lConfirmou := .F.

	FWExecView( STR0007, "FINA024RFI", nOpc,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,,aEnableButtons,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, /*oModel*/ ) //'Ativar/Desativar'

	__lConfirmou := .F.
	__nOper := 0

	FKK->(DBSETORDER(2))	//"FKK_FILIAL+FKK_CODIGO+FKK_VERSAO"

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} F24FKKVIG()
Define operacao PARA Ajustar a vigência de um cadastro de regra
financeira

@author  Mauricio Pequim Jr
@since	15/10/2018
@version 12
/*/
//-------------------------------------------------------------------
Function F24FKKVIG()

	Local nOpc As Numeric
	Local aEnableButtons As Array

	aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"###"Fechar"

	nOpc := MODEL_OPERATION_UPDATE

	__nOper := OPER_VIGENCIA
	__lConfirmou := .F.

	FWExecView( "Ajustar Vigência", "FINA024RFI", nOpc,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,,aEnableButtons,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, /*oModel*/ ) //'Ativar/Desativar'

	__lConfirmou := .F.
	__nOper := 0

	FKK->(DBSETORDER(2))	//"FKK_FILIAL+FKK_CODIGO+FKK_VERSAO"

Return




//-------------------------------------------------------------------------------------------------------------------------------------------------------
// VALIDAÇÕES
//-------------------------------------------------------------------------------------------------------------------------------------------------------

//-------------------------------------------------------------------
/*/{Protheus.doc} F024CODFKK()
Pos Validacao de preenchimento do código do registro de retenção

@author Mauricio Pequim Jr
@since	14/09/2018
@version 12
/*/
//-------------------------------------------------------------------
Function F024CODFKK() As Logical

	Local lRet As Logical
	Local oModel As Object
	Local cCodigo As Character
	Local cVersao As Character
	Local lAchou As Logical
	Local lAtivo As Logical
	Local aArea As Array
	Local cCab As Character
	Local cDes As Character
	Local cSol As Character
	Local nOper As Numeric

	lRet 	:= .F.
	lAchou 	:= .F.
	lAtivo 	:= .F.
	aArea 	:= GetArea()
	oModel 	:= FWModelActive()
	cCodigo := oModel:GetValue('FKKMASTER','FKK_CODIGO')
	cVersao := oModel:GetValue('FKKMASTER','FKK_VERSAO')
	nOper	:= oModel:GetOperation()
	cCab	:= ""
	cDes	:= ""
	cSol	:= ""

	If !Empty(cCodigo) .and. !Empty(cVersao)
		DBSelectArea('FKK')
		FKK->(DbSetOrder(2))	// FKK_FILIAL+FKK_CODIGO+FKK_VERSAO
		FKK->(MSSeek(xFilial('FKK')+cCodigo))

		While !lAchou .And. !lAtivo .And. FKK->(!Eof()) .And. FKK->(FKK_FILIAL+FKK_CODIGO) == xFilial('FKK')+cCodigo

			//Busca por Codigo/Versao ja cadastrado
			If FKK->(FKK_CODIGO+FKK_VERSAO) == cCodigo + cVersao
				lAchou := .T.
			Endif

			// Busca por Codigo ja cadastrado com status ATIVO
			If FKK->FKK_ATIVO == '1'
				lAtivo	:= .T.
			EndIf

			FKK->(DbSkip())
		EndDo
	EndIf

	If __nOper != MODEL_OPERATION_INSERT .and. __nOper != OPER_COPIAR .and. nOper != MODEL_OPERATION_INSERT
		cCab := STR0021		//'Código'
		cDes := STR0022		//'Operação não permitida.'
		cSol := STR0023		//'Este campo não pode ser alterado.'
	ElseIf IF(ISALPHA(cCodigo),cCodigo,PADL(ALLTRIM(cCodigo),6)) <= '500000'
		cCab := STR0021		//'Código'
		cDes := STR0024		//'O intervalo de códigos entre 000001 e 500000 está reservado para uso interno da TOTVS.'
		cSol := STR0025		//'Entre com código maior que 500000'
	ElseIf !FreeForUse('FKK','FKK_CODIGO'+xFilial('FKK')+cCodigo)
		cCab := STR0021		//'Código'
		cDes := STR0026		//'O código digitado se encontra em uso.'
		cSol := STR0027		//'Código se encontra reservado.'
	ElseIf lAchou
		cCab := STR0021		//'Código'
		cDes := STR0028		//'O código/versão já se encontram cadastrados.'
		cSol := STR0029		//'Código/versão já cadastrado.'
	ElseIf lAtivo
		cCab := STR0021		//'Código'
		cDes := STR0030		//'O Codigo digitado possui outra versao com status Ativo.'
		cSol := STR0031		//'Codigo com outra versao ativada.'
	Else
		lRet := .T.
	EndIf

	If !Empty(cCab+cDes+cSol)
		HELP(' ',1, cCab ,, cDes ,2,0,,,,,, {cSol} )
	Endif

	RestArea(aArea)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} FIN024VIG()
Validação das datas de vigência

@author Mauricio Pequim Jr
@since	25/08/2017
@version 12
/*/
//-------------------------------------------------------------------
Function FIN024VIG(nOpcao As Numeric) as Logical

	Local dVigIni As Date
	Local dVigFim As Date
	Local oModel As Object
	Local lRet As Logical
	Local cCab As Character
	Local cDes As Character
	Local cSol As Character
	Local cCodigo As Character
	Local cVersao As Character
	Local aAreaFKK As Array

	DEFAULT nOpcao := 0

	oModel		:= FWModelActive()
	lRet		:= .T.
	dVigIni		:= CTOD("//")
	dVigFim		:= CTOD("//")
	cCab		:= ""
	cSol		:= ""
	cDes		:= ""
	cCodigo		:= oModel:GetValue("FKKMASTER","FKK_CODIGO")
	cVersao		:= oModel:GetValue("FKKMASTER","FKK_VERSAO")
	aAreaFKK	:= FKK->(GetArea())

	If nOpcao == 1				//1 = Emissao FKK_VIGINI
		dVigIni := M->FKK_VIGINI
		dVigFim := oModel:GetValue("FKKMASTER","FKK_VIGFIM")
		If !Empty(dVigFim)
			lRet := dVigFim >= dVigIni
		Endif
	ElseIf nOpcao == 2			//2 = Baixa FKK_VIGFIM
		dVigIni := oModel:GetValue("FKKMASTER","FKK_VIGINI")
		dVigFim := M->FKK_VIGFIM
		lRet := (dVigFim >= dVigIni)
	Endif

	If !lRet
		cDes := STR0032
		cSol := STR0033
	Endif

	If !lRet
		HELP(' ',1, 'DT_VIGENCIA' ,, cDes ,2,0,,,,,, {cSol} )	//"A data de vigência final deve ser posterior a data de vigência inicial."###"Por favor, verifique o conteúdo dos campos Ini. Vigência e Fim Vigência."
	Endif

Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} F024FKKAtv()
Validação do campo FKK_ATIVO

@author Mauricio Pequim Jr
@since	25/08/2017
@version 12
/*/
//-------------------------------------------------------------------
Function F024FKKAtv() As Logical

	Local lRet As Logical

	lRet := Pertence("12")

Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} FIN024FKL()
Pos Validacao de preenchimento do código do regra de titulos

@author Mauricio Pequim Jr
@since	14/09/2018
@version 12
/*/
//-------------------------------------------------------------------
Function FIN024FKL() As Logical

	Local lRet As Logical
	Local oModel As Object
	Local cCodigo As Character
	Local cVersao As Character
	Local aArea As Array
	Local cCab As Character
	Local cDes As Character
	Local cSol As Character

	lRet := .T.
	aArea := GetArea()
	oModel := FWModelActive()
	cCodigo := oModel:GetValue('FKKMASTER','FKK_CODFKL')
	cCab := STR0036		//'Código Regra Títulos'
	cDes := STR0037		//'O código informado não se encontra cadastrado ou não possui versao com status Ativo.'
	cSol := STR0038 	//'Informe um código de regra de titulos válido ou utilize a consulta F3 do campo.'
	__lGerTitRet := .F.

	If !Empty(cCodigo)
		DBSelectArea('FKL')
		FKL->(DbSetOrder(2))	// FKL_FILIAL+FKL_CODIGO
		If !(FKL->(MSSeek(xFilial('FKL')+cCodigo)))
			HELP(' ',1, cCab ,, cDes ,2,0,,,,,, {cSol} )
			lRet := .F.
		Else
			oModel:LoadValue('FKKMASTER','FKK_IDFKL', FKL->FKL_IDRET)
			__lGerTitRet := (FKL->FKL_TIPMOV == '2' .and. FKL->FKL_CARTMV == '1') //Impostos gerados na SE2 devem possuir regra de vencimento
		Endif
	EndIf

	IF oModel:GetValue('FKKMASTER','FKK_FATGER') = "2" .And. oModel:GetValue('FKKMASTER','FKK_CART') == "2" .And. FKL->FKL_TIPMOV == "1"  .And. FKL->FKL_CARTMV == "1"
		cDes := STR0081 // 'Fato gerador configurado como Caixa e carteita de operação como Receber.'
		cSol := STR0082 // 'Regra de título não pode ser do tipo Abatimentos.'
		HELP(' ',1, cCab ,, cDes ,2,0,,,,,, {cSol} )
		lRet := .F.
	ElseIf oModel:GetValue('FKKMASTER','FKK_FATGER') = "1" .And. oModel:GetValue('FKKMASTER','FKK_CART') == "2" .And. FKL->FKL_TIPMOV == "2"  .And. FKL->FKL_CARTMV == "2"
		cDes := STR0083 // 'Fato gerador configurado como Competência e carteita de operação como Receber.'
		cSol := STR0084 // 'Regra de título não pode ser do tipo Impostos.'
		HELP(' ',1, cCab ,, cDes ,2,0,,,,,, {cSol} )
		lRet := .F.
	Endif

	RestArea(aArea)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} FIN024FKN()
Pos Validacao de preenchimento do código do regra de CÁLCULO

@author Mauricio Pequim Jr
@since	14/09/2018
@version 12
/*/
//-------------------------------------------------------------------
Function FIN024FKN() As Logical

	Local lRet As Logical
	Local oModel As Object
	Local cCodigo As Character
	Local cVersao As Character
	Local aArea As Array
	Local cCab As Character
	Local cDes As Character
	Local cSol As Character

	lRet := .T.
	aArea := GetArea()
	oModel := FWModelActive()
	cCodigo := oModel:GetValue('FKKMASTER','FKK_CODFKN')
	cCab := STR0039 	//'Código Regra Cálculo'
	cDes := STR0040		//'O código informado não se encontra cadastrado ou não possui versao com status Ativo.'
	cSol := STR0041 	//'Informe um código de regra de cálculo válido ou utilize a consulta F3 do campo.'

	If !Empty(cCodigo)
		DBSelectArea('FKN')
		FKN->(DbSetOrder(2))	// FKN_FILIAL+FKN_CODIGO
		If !(FKN->(MSSeek(xFilial('FKN')+cCodigo)))
			HELP(' ',1, cCab ,, cDes ,2,0,,,,,, {cSol} )
			lRet := .F.
		Else
			oModel:LoadValue('FKKMASTER','FKK_IDFKN', FKN->FKN_IDRET)
		Endif
	EndIf

	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FIN024FKO()
Pos Validacao de preenchimento do código do regra de titulos

@author Mauricio Pequim Jr
@since	14/09/2018
@version 12
/*/
//-------------------------------------------------------------------
Function FIN024FKO() As Logical

	Local lRet As Logical
	Local oModel As Object
	Local cCodigo As Character
	Local cVersao As Character
	Local aArea As Array
	Local cCab As Character
	Local cDes As Character
	Local cSol As Character

	lRet := .T.
	aArea := GetArea()
	oModel := FWModelActive()
	cCodigo := oModel:GetValue('FKKMASTER','FKK_CODFKO')
	cCab := STR0042 	//'Código Regra Retenção'
	cDes := STR0043		//'O código informado não se encontra cadastrado ou não possui versao com status Ativo.'
	cSol := STR0044 	//'Informe um código de regra de retenção válido ou utilize a consulta F3 do campo.'

	If !Empty(cCodigo)
		DBSelectArea('FKO')
		FKO->(DbSetOrder(2))	// FKL_FILIAL+FKL_CODIGO
		If !(FKO->(MSSeek(xFilial('FKO')+cCodigo)))
			HELP(' ',1, cCab ,, cDes ,2,0,,,,,, {cSol} )
			lRet := .F.
		Else
			oModel:LoadValue('FKKMASTER','FKK_IDFKO', FKO->FKO_IDRET)
		Endif
	EndIf

	RestArea(aArea)

Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} FIN024FKP()
Pos Validacao de preenchimento do código do registro de retenção

@author Mauricio Pequim Jr
@since	14/09/2018
@version 12
/*/
//-------------------------------------------------------------------
Function FIN024FKP() As Logical

	Local lRet As Logical
	Local oModel As Object
	Local cCodigo As Character
	Local cVersao As Character
	Local aArea As Array
	Local cCab As Character
	Local cDes As Character
	Local cSol As Character

	lRet := .T.
	aArea := GetArea()
	oModel := FWModelActive()
	cCodigo := oModel:GetValue('FKKMASTER','FKK_CODFKP')
	cCab := STR0045 		//'Código Regra Vencimento'
	cDes := STR0046 		//'O código informado não se encontra cadastrado ou não possui versao com status Ativo.'
	cSol := STR0047 		//'Informe um código de de regra de vencimento válido ou utilize a consulta F3 do campo.'

	If !Empty(cCodigo)
		DBSelectArea('FKP')
		FKP->(DbSetOrder(2))	// FKP_FILIAL+FKP_CODIGO
		If !(FKP->(MSSeek(xFilial('FKP')+cCodigo)))
			HELP(' ',1, cCab ,, cDes ,2,0,,,,,, {cSol} )
			lRet := .F.
		Else
			oModel:LoadValue('FKKMASTER','FKK_IDFKP', FKP->FKP_IDRET)
		Endif
	EndIf

	RestArea(aArea)

Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} FIN024FKU()
Pos Validacao de preenchimento do código do regra de
Valores Acessórios

@author Mauricio Pequim Jr
@since	14/09/2018
@version 12
/*/
//-------------------------------------------------------------------
Function FIN024FKU() As Logical

	Local lRet As Logical
	Local oModel As Object
	Local cCodigo As Character
	Local cVersao As Character
	Local aArea As Array
	Local cCab As Character
	Local cDes As Character
	Local cSol As Character

	lRet := .T.
	aArea := GetArea()
	oModel := FWModelActive()
	cCodigo := oModel:GetValue('FKKMASTER','FKK_CODFKU')
	cCab := STR0048 		//'Código Regra de Valores Acessórios'
	cDes := STR0049 		//'O código informado não se encontra cadastrado ou não possui versao com status Ativo.'
	cSol := STR0050 		//'Informe um código de regra de Valores Acessórios válido ou utilize a consulta F3 do campo.'

	If !Empty(cCodigo)
		DBSelectArea('FKU')
		FKU->(DbSetOrder(2))	// FKU_FILIAL+FKU_CODIGO
		If !(FKU->(MSSeek(xFilial('FKU')+cCodigo)))
			HELP(' ',1, cCab ,, cDes ,2,0,,,,,, {cSol} )
			lRet := .F.
		Else
			oModel:LoadValue('FKKMASTER','FKK_IDFKU', FKU->FKU_IDRET)
		Endif
	EndIf

	RestArea(aArea)

Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} F024F3FRI()
consulta Padrão SXB

@author	pequim
@since	14/09/2018
@version 12
/*/
//-------------------------------------------------------------------

Function F024F3FRI( cCmpF3 )

	Local cF3	:= ''

	DEFAULT cCmpF3	:= ""

	cF3		:=	""

	If cCmpF3 == 'FKK_CODFKL'
		cF3 :=	"FKL"
	ElseIf cCmpF3 == 'FKK_CODFKN'
		cF3 :=	"FKN"
	ElseIf cCmpF3 == 'FKK_CODFKO'
		cF3 :=	"FKO"
	ElseIf cCmpF3 == 'FKK_CODFKP'
		cF3 :=	"FKP"
	ElseIf cCmpF3 == 'FKK_CODFKU'
		cF3 :=	"FKU"
	ElseIf cCmpF3 == 'FOO_CODIGO'
		cF3 :=	"F2E"
	EndIf

Return cF3


//-------------------------------------------------------------------
/*/{Protheus.doc} F024FKKINI()
Preenchimento dos campos virtuais

@author Mauricio Pequim Jr
@since	25/08/2017
@version 12
/*/
//-------------------------------------------------------------------
Function F024FKKINI(cCampo As Character) As Character

	Local cRet As Character
	Local cCodigo As Character
	Local nOper	As Numeric
	Local oModel As Object
	Local oFKK As Object

	DEFAULT cCampo := ""

	oModel		:= FWModelActive()
	oFKK 		:= oModel:GetModel("FKKMASTER")
	oFOO 		:= oModel:GetModel("FOODETAIL")
	nOper		:= oModel:GetOperation()
	cRet		:= ""
	cCodigo		:= ""

	If !Empty(cCampo)
		Do Case

			Case cCampo == "FKK_VERSAO"	//VERSÃO
				If nOper == MODEL_OPERATION_INSERT
					cRet		:= '0001'
				Endif


			Case cCampo == "FKK_DSCRET"	//DESCRIÇÃO CODIGO RETENÇÃO
				cCodigo		:= oModel:GetValue("FKKMASTER","FKK_CODRET")

				If !Empty(cCodigo)
					SX5->(MsSeek(xFilial("SX5") + "37"+ cCodigo ))
					cRet :=  PADR(SX5->(X5Descri()),nTamDFOO)
				Endif


			Case cCampo == "FKK_DSCFKL"	//DESCRIÇÃO REGRA TITULOS
				cCodigo		:= oModel:GetValue("FKKMASTER","FKK_CODFKL")

				If !Empty(cCodigo)
					FKL->(dbSetOrder(2))		//"FKL_FILIAL+FKL_CODIGO"
					If FKL->(MsSeek(xFilial("FKL")+cCodigo))
						cRet := FKL->FKL_DESCR
					Endif
				Endif


			Case cCampo == "FKK_DSCFKN"	//DESCRIÇÃO REGRA CALCULO
				cCodigo		:= oModel:GetValue("FKKMASTER","FKK_CODFKN")

				If !Empty(cCodigo)
					FKN->(dbSetOrder(2))		//"FKN_FILIAL+FKN_CODIGO"
					If FKN->(MsSeek(xFilial("FKN")+cCodigo))
						cRet := FKN->FKN_DESCR
					Endif
				Endif


			Case cCampo == "FKK_DSCFKO"	//DESCRIÇÃO REGRA RETENÇÃO
				cCodigo		:= oModel:GetValue("FKKMASTER","FKK_CODFKO")

				If !Empty(cCodigo)
					FKO->(dbSetOrder(2))		//"FKO_FILIAL+FKO_CODIGO"
					If FKO->(MsSeek(xFilial("FKO")+cCodigo))
						cRet := FKO->FKO_DESCR
					Endif
				Endif


			Case cCampo == "FKK_DSCFKP"	//DESCRIÇÃO VENCTOS
				cCodigo		:= oModel:GetValue("FKKMASTER","FKK_CODFKP")

				If !Empty(cCodigo)
					FKP->(dbSetOrder(2))		//"FKP_FILIAL+FKP_CODIGO"
					If FKP->(MsSeek(xFilial("FKP")+cCodigo))
						cRet := FKP->FKP_DESCR
					Endif
				Endif


			Case cCampo == "FKK_DSCFKU"	//DESCRIÇÃO REGRA RETENÇÃO
				cCodigo		:= oModel:GetValue("FKKMASTER","FKK_CODFKU")

				If !Empty(cCodigo)
					FKU->(dbSetOrder(2))		//"FKU_FILIAL+FKU_CODIGO"
					If FKU->(MsSeek(xFilial("FKU")+cCodigo))
						cRet := FKU->FKU_DESCR
					Endif
				Endif

			Case cCampo == "FKK_CTADSC"	//Conta
				cCodigo		:= oModel:GetValue("FKKMASTER","FKK_CONTA")

				If !Empty(cCodigo)
					cRet := Posicione('CT1',1,xFilial('CT1')+cCodigo,'CT1_DESC01')
				Endif


			Case cCampo == "FKK_CUSDSC"	//Centro de Custo
				cCodigo		:= oModel:GetValue("FKKMASTER","FKK_CUSTO")

				If !Empty(cCodigo)
					cRet := Posicione('CTT',1,xFilial('CTT')+cCodigo,'CTT_DESC01')
				Endif


			Case cCampo == "FKK_ITEDSC"	//Item
				cCodigo		:= oModel:GetValue("FKKMASTER","FKK_ITEM")

				If !Empty(cCodigo)
					cRet := Posicione('CTD',1,xFilial('CTD')+cCodigo,'CTD_DESC01')
				Endif


			Case cCampo == "FKK_CLVLDC"	//Classe de Valor
				cCodigo		:= oModel:GetValue("FKKMASTER","FKK_CLVL")

				If !Empty(cCodigo)
					cRet := Posicione('CTH',1,xFilial('CTH')+cCodigo,'CTH_DESC01')
				Endif


			Case cCampo == "FOO_DESCR"	//Descrição código
				If nOper != MODEL_OPERATION_INSERT
					cCodigo	:= FOO->FOO_CODIGO
					If !Empty(cCodigo)
						F2E->(DbSetOrder(2))	//F2E_FILIAL+F2E_TRIB
						F2E->(MsSeek(xFilial("F2E") + cCodigo ))
						cRet :=  PADR(F2E->F2E_DESC,nTamDFOO)
					Endif
				EndIf

		EndCase

	Endif

Return cRet




//-------------------------------------------------------------------
/*/{Protheus.doc} F024FKKVER()
Inicializador padr?o do campo FKK_VERSAO

@author Mauricio Pequim Jr
@since	25/08/2017
@version 12
/*/
//-------------------------------------------------------------------
Function F024FKKVER(oModel As Object) As Character

	Local cCod As Character
	Local cRet As Character
	Local nOper	As Numeric

	DEFAULT oModel := NIL

	cCod	:= ""
	cRet	:= ""

	If __nOper == OPER_ALTERAR
		cCod := FKK->FKK_CODIGO
		cRet := FKK->FKK_VERSAO
		While .T.
			cRet := Soma1(cRet,4)
			FKK->(DbSetOrder(2))
			If !(FKK->(MsSeek(xFilial("FKK")+cCod+cRet)))
				If oModel != NIL
					oModel:LoadValue("FKKMASTER","FKK_VERSAO",cRet)
				EndIf
				Exit
			Endif
		EndDo
	ElseIf __nOper == OPER_COPIAR
		cRet := '0001'
		If oModel != NIL
			oModel:LoadValue("FKKMASTER","FKK_VERSAO",cRet)
			oModel:LoadValue("FKKMASTER","FKK_CODIGO","")
			oModel:LoadValue("FKKMASTER","FKK_DESCR" ,"")
		EndIf
	Else
		cRet := '0001'
	EndIF

Return cRet



//-------------------------------------------------------------------
/*/{Protheus.doc} F024FKKPos()
Pos Validacao de preenchimento do FORM

@author  Mauricio Pequim Jr
@since	25/08/2017
@version 12
/*/
//-------------------------------------------------------------------
Function F024FKKPos() As Logical

Local lRet As Logical
Local oModel, oFKK As Object
Local nOper		As Numeric

oModel		:= FWModelActive()
nOper		:= oModel:GetOperation()
oFKK 		:= oModel:GetModel("FKKMASTER")
lRet		:= .T.

If nOper == MODEL_OPERATION_INSERT

	DBSelectArea("FKK")
	FKK->( DbSetOrder(1) )

	If FKK->( DbSeek( xFilial("FKK")+oFKK:GetValue("FKK_IDRET") ) )
		HELP(" ",1,"FA024DUP",,STR0051,1,0)	//'Regra Financeira de Retenção já cadastrada'
		lRet	:= .F.
	EndIf

EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} F024FOOPos()
Pos Validacao dos dados da aba Tipo de Impostos

@author Mauricio Pequim Jr
@since	24/10/2017
@version 12
/*/
//-------------------------------------------------------------------
Function F024FOOPos (lLinha) As Logical

Local lRet As Logical
Local oModel As Object
Local oSubFOO As Object
Local nTamModel As Numeric
Local nLinAtu As Numeric
Local nLinFOO As Numeric
Local nY As Numeric

DEFAULT lLinha := .T.		//Indicador de que está validando a linha

lRet		:= .T.
oModel		:= FWModelActive()
oSubFOO		:= oModel:GetModel('FOODETAIL')
nTamModel	:= oSubFOO:Length()
nLinAtu		:= oSubFOO:GetLine()
nLinFOO 	:= 0

If lLinha .and. oSubFOO:GetValue("FOO_TIPIMP") == ' '
	If (!(__lBlind), HELP(' ',1, 'FOO_VAZIO' ,, STR0051,2,0 ), )	//"O tipo de imposto deve ter sua classificação preenchida (Principal ou Secundário)"
	lRet := .F.
ElseIf !lLinha .AND. (oSubFOO:SeekLine( { {"FOO_TIPIMP", ' ' } } ) )
	cTipoImp	:= oSubFOO:GetValue("FOO_CODIGO")
	If (!(__lBlind), HELP(' ',1, 'FOO_VAZIO' ,, STR0051,2,0,,,,,, {STR0052 +" "+ cTipoImp } ), )
	lRet := .F.
ElseIf !lLinha .AND. !(oSubFOO:SeekLine( { {"FOO_TIPIMP", '1' } } ) )
	If (!(__lBlind), HELP(' ',1, 'FOO_NOPRINC' ,, STR0053,2,0,,,,,, {STR0054 } ), )
	lRet := .F.
Else
	If lLinha
		nLinFOO 	:= oSubFOO:GetLine()
		cTipoImp	:= oSubFOO:GetValue("FOO_CODIGO")
		cClassImp	:= oSubFOO:GetValue("FOO_TIPIMP")
	ElseIf (oSubFOO:SeekLine( { {"FOO_TIPIMP", '1' } } ) )
		nLinFOO 	:= oSubFOO:GetLine()
		cTipoImp	:= oSubFOO:GetValue("FOO_CODIGO")
		cClassImp	:= '1'
	Endif

	//Verifico no Model a ocorrência de outro tipo de imposto como principal
	For nY := 1 To nTamModel
		oSubFOO:GoLine( nY )
		If !oSubFOO:IsDeleted()
			If cClassImp == '1'
				If oSubFOO:GetValue("FOO_TIPIMP") == '1' .and. nLinFOO != nY
					If (!(__lBlind), HELP(' ',1, 'FOO_PRINCIPAL' ,, STR0055,2,0,,,,,, {STR0056 + cTipoImp } ), )	//"Apenas um tipo de imposto pode ser o Principal."###'Tipo de imposto principal: '
					lRet := .F.
					Exit
				EndIf
			Else
				Exit
			EndIF
		Endif
	Next
	oSubFOO:GoLine( nLinAtu )
Endif

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} F024FKKRET()
Inicializador padrao do campo FKK_IDRET

@author Mauricio Pequim Jr
@since	25/08/2017
@version 12
/*/
//-------------------------------------------------------------------
Function F024FKKRET(oModel As Object) As Character

Local cRet As Character
Local nOper	As Numeric
Local aAreaFKK As Array

DEFAULT oModel := NIL

cRet	:= ""

aAreaFKK := FKK->(GetArea())

If __nOper == MODEL_OPERATION_INSERT .OR. __nOper == OPER_ALTERAR .OR. __nOper == OPER_COPIAR

	While .T.
		cRet := FWUUIDV4()
		FKK->(DbSetOrder(1))
		If !(FKK->(MsSeek(xFilial("FKK")+cRet))) .and. FreeForUse("FKK",cRet)
			FKK->(RestArea(aAreaFKK))
			Exit
		Endif
	EndDo

	//Em caso de alteração ou cópia, ajusto a versão do imposto
	If __nOper == OPER_ALTERAR .OR. __nOper == OPER_COPIAR
		If oModel != NIL
			oModel:LoadValue("FKKMASTER","FKK_IDRET",cRet)
			F024FKKVER(oModel)
			FKK->(RestArea(aAreaFKK))
		EndIf
	Endif
Else
	cRet := FKK->FKK_IDRET
Endif

Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} F024FKKAft()
Refresh da View utilizado para alteração

@author Mauricio Pequim Jr
@since	25/08/2017
@version 12
/*/
//-------------------------------------------------------------------
Function F024FKKAft(oView As Model) As Logical

oView:Refresh()

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} F024RFITOK()
Pós Validacao do model

@author Karen Yoshie Honda
@since	28/08/2017
@version 12
/*/
//-------------------------------------------------------------------
Static Function F024RFITOK() As Logical

Local lRet As Logical
Local oModel As Object
Local nOper As Numeric
Local nI As Numeric
Local aAreaFKK As Array
Local dVigIni As Date
Local dVigFim As Date
Local cCodigo As Character
Local cVersao As Character
Local cIdFKL As Character
Local cVerFKK As Character
Local cDes As Character
Local cSol As Character


lRet := .T.
oModel := FWModelActive()
nOper := oModel:GetOperation()
nI := 0
aAreaFKK := FKK->(GetArea())

cVerFKK := ''
cDes := ''
cSol := ''

If nOper != MODEL_OPERATION_DELETE

	If __nOper == OPER_ALTERAR
		cCodigo := oModel:GetValue('FKKMASTER','FKK_CODIGO')
		cVersao := oModel:GetValue('FKKMASTER','FKK_VERSAO')
		dVigIni := oModel:GetValue("FKKMASTER","FKK_VIGINI")
		dVigFim := oModel:GetValue("FKKMASTER","FKK_VIGFIM")
		cIdFKL	:= oModel:GetValue("FKKMASTER","FKK_IDFKL")

		FKL->(DbSetOrder(1))	// FKL_FILIAL+FKL_IDRET
		If FKL->(MSSeek(xFilial('FKL')+cIdFKL))
			__lGerTitRet := (FKL->FKL_TIPMOV == '2' .and. FKL->FKL_CARTMV == '1') //Impostos gerados na SE2 devem possuir regra de vencimento
		Endif

		//DATAS DE VIGENCIA
		If cVersao != '0001' .and. !Empty(dVigIni) .and. !Empty(dVigFim)
			//Verifico intersecção de vigências
			FKK->(dbSetOrder(2))	//FKK_FILIAL = FKK_CODIGO
			cChaveFKK := xFilial("FKK") + cCodigo
			If DbSeek(cChaveFKK)
				lRet := F24VldVig(cChaveFKK, dVigIni, dVigFim, cVersao)
			Endif
		Endif
	EndIF

	If lRet
		If __nOper == OPER_VIGENCIA
			cCodigo := oModel:GetValue('FKKMASTER','FKK_CODIGO')
			cVersao := oModel:GetValue('FKKMASTER','FKK_VERSAO')
			dVigIni := oModel:GetValue("FKKMASTER","FKK_VIGINI")
			dVigFim := oModel:GetValue("FKKMASTER","FKK_VIGFIM")

			//DATAS DE VIGENCIA
			If !Empty(dVigIni) .and. !Empty(dVigFim)
				//Verifico intersecção de vigências
				FKK->(dbSetOrder(2))	//FKK_FILIAL = FKK_CODIGO
				cChaveFKK := xFilial("FKK") + cCodigo
				If DbSeek(cChaveFKK)
					lRet := F24VldVig(cChaveFKK, dVigIni, dVigFim, cVersao)
				Endif
			Endif
		Else
			//Regra de Vencimento Obrigatoria quando Regra de titulo gerar retenção
			If lRet .and. __lGerTitRet .and. Empty(oModel:GetValue('FKKMASTER','FKK_IDFKP') )
				lRet := .F.
				HELP(' ',1, STR0074 ,, STR0075 ,1,0,,,,,, {STR0076} )	//'REGRA VENCIMENTO x REGRA TITULOS'###"Para os casos onde a regra de títulos gere uma retenção, é necessário a amarração de uma regra de vencimento."###"Por favor, relacione uma regra de vencimento ou altere a regra de títulos."
			Endif

			//Validação de Carteira Receber com Abatimento e Fato Gerador Caixa
			If (lRet .AND. oModel:GetValue('FKKMASTER','FKK_CART') == '2' .AND. oModel:GetValue('FKKMASTER','FKK_FATGER') == '2')
				//Posicionando na Regra de Titulo
				FKL->(DBSetOrder(02)) //FKL_FILIAL + FKL_CODIGO
				If (FKL->(DBSeek(FWxFilial('FKL') + oModel:GetValue('FKKMASTER','FKK_CODFKL'))))
					If (FKL->FKL_TIPMOV == '1') //Abatimento
						lRet := .F.
						HELP(' ',1, 'ABFATGER' ,, STR0085, 1, 0,,,,,, {STR0086} ) //"Não é possível vincular/amarrar um regra de título de abatimento a uma regra financeira com fator gerador caixa."#"Por favor, alterar a Regra de Título ou Fato Gerador."
					EndIf
				EndIf
			EndIf

			//Tipo de Impostos
			If lRet
				lRet := F024PosFOO(.F.)
			Endif
		EndIF
	Endif
	__lConfirmou := lRet

Endif

Return lRet



//-------------------------------------------------------------------
/*/ {Protheus.doc} F024FKKWhe
Permissão de edição de campos (When)

@param oGridModel - Model que chamou a validação
@param cCampo - Campo a ser validada permissão de edição

@author Mauricio Pequim Jr
@since 01/09/2017

@return Logico com permissão ou não de edição do campo
/*/
//-------------------------------------------------------------------
Function F024FKKWhe(oModel As Object, cCampo As Character)

Local lRet As Logical

DEFAULT oModel := NIL
DEFAULT cCampo := ""

lRet := .T.

If cCampo == "FKK_CODIGO" .AND. __nOper == OPER_ALTERAR
	lRet := .F.
Endif


If cCampo == 'FKK_PROVIS'
	lRet := (oModel:GetValue('FKKMASTER','FKK_FATGER') == '2')	//Campo ativo apenas para regime de Caixa
Endif


If  (__nOper == OPER_ALTERAR  .OR. __nOper == OPER_COPIAR) .AND. __lVersao == .F.
	__lVersao := .T.
	F024FKKVER(oModel)
EndIf

Return lRet


//-------------------------------------------------------------------
/*/ {Protheus.doc} FIN024CDI
validação do Código do Imposto (FOO_CODIGO)

@author Mauricio Pequim Jr
@since 01/09/2017

@return Logico
/*/
//-------------------------------------------------------------------
Function FIN024CDI()

Local lRet As Logical
Local oModel As Object
Local cCodigo As Character

oModel := FWModelActive()
cCodigo := oModel:GetValue("FOODETAIL","FOO_CODIGO")
lRet := .F.

F2E->(DbSetOrder(2))	//F2E_FILIAL+F2E_TRIB
If F2E->(MsSeek(xFilial("F2E") + cCodigo ))
	cRet :=  PADR(F2E->F2E_DESC,nTamDFOO)
	lRet := .T.
	oModel:LoadValue("FOODETAIL","FOO_DESCR", cRet)
Endif

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} F024VldExc()
Valida permissão de Exclusão

@author Mauricio Pequim Jr
@since	25/08/2017
@version 12
/*/
//-------------------------------------------------------------------
STATIC Function F024VldExc(oModel As Object) As Logical

Local lRet As Logical
Local cCodigo As Character
Local aAreaFOI As Array
Local aAreaFOJ As Array
Local aAreaFOK As Array

DEFAULT oModel	:= 	FWModelActive()

aAreaFOI := FOI->(GetArea())
aAreaFOJ := FOJ->(GetArea())
aAreaFOK := FOK->(GetArea())

lRet := .T.

FOI->(dbSetOrder(2))
FOJ->(dbSetOrder(2))
FOK->(dbSetOrder(2))

cCodigo := oModel:GetValue("FKKMASTER","FKK_CODIGO")

If 	FOI->(MSSeek(xFilial("FOI")+cCodigo)) .or. ;
	FOJ->(MSSeek(xFilial("FOJ")+cCodigo)) .or. ;
	FOK->(MSSeek(xFilial("FOK")+cCodigo))

	lRet := .F.
Endif

FOI->(RestArea(aAreaFOI))
FOJ->(RestArea(aAreaFOJ))
FOK->(RestArea(aAreaFOK))

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} F024PosFOO()
Pos Validacao dos dados da aba Tipo de Impostos

@author Mauricio Pequim Jr
@since	24/10/2017
@version 12
/*/
//-------------------------------------------------------------------
STATIC Function F024PosFOO (lLinha) As Logical

Local lRet As Logical
Local oModel As Object
Local oSubFOO As Object
Local nTamModel As Numeric
Local nLinAtu As Numeric
Local nLinFOO As Numeric
Local nY As Numeric

DEFAULT lLinha := .T.		//Indicador de que está validando a linha

lRet		:= .T.
oModel		:= FWModelActive()
oSubFOO		:= oModel:GetModel('FOODETAIL')
cTamModel	:= oSubFOO:Length()
nLinAtu		:= oSubFOO:GetLine()
nLinFOO 	:= 0

If lLinha .and. oSubFOO:GetValue("FOO_TIPIMP") == ' '
	If (!(__lBlind), HELP(' ',1, 'FOO_VAZIO' ,, STR0051,2,0 ), )
	lRet := .F.

ElseIf !lLinha .AND. (oSubFOO:SeekLine( { {"FOO_TIPIMP", ' ' } } ) )
	cTipoImp	:= oSubFOO:GetValue("FOO_CODIGO")
	If (!(__lBlind), HELP(' ',1, 'FOO_VAZIO' ,, STR0051,2,0,,,,,, {STR0052 +" "+ cTipoImp } ), )
	lRet := .F.

ElseIf !lLinha .AND. !(oSubFOO:SeekLine( { {"FOO_TIPIMP", '1' } } ) )
	If (!(__lBlind), HELP(' ',1, 'FOO_NOPRINC' ,, STR0053,2,0,,,,,, {STR0054 } ), )	//"Ao menos um tipo de imposto deve ser o Principal"###"Por favor, verifique a grid Tipo de Imposto"
	lRet := .F.

Else
	If lLinha
		nLinFOO 	:= oSubFOO:GetLine()
		cTipoImp	:= oSubFOO:GetValue("FOO_CODIGO")
		cClassImp	:= oSubFOO:GetValue("FOO_TIPIMP")
	ElseIf (oSubFOO:SeekLine( { {"FOO_TIPIMP", '1' } } ) )
		nLinFOO 	:= oSubFOO:GetLine()
		cTipoImp	:= oSubFOO:GetValue("FOO_CODIGO")
		cClassImp	:= '1'
	Endif

	//Verifico no Model a ocorrência de outro tipo de imposto como principal
	For nY := 1 To cTamModel
		oSubFOO:GoLine( nY )
		If !oSubFOO:IsDeleted()
			If cClassImp == '1'
				If oSubFOO:GetValue("FOO_TIPIMP") == '1' .and. nLinFOO != nY
					If (!(__lBlind), HELP(' ',1, 'FOO_PRINCIPAL' ,, STR0055,2,0,,,,,, {STR0056 + cTipoImp } ), )	//"Apenas um tipo de imposto pode ser o Principal."###'Tipo de imposto principal: '
					lRet := .F.
					Exit
				EndIf
			Else
				Exit
			EndIF
		Endif
	Next
	oSubFOO:GoLine( nLinAtu )
Endif

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} FIN024TPI()
Validação do campo FOO_TIPIMP

@author Mauricio Pequim Jr
@since	23/10/2017
@version 12
/*/
//-------------------------------------------------------------------
Function FIN024TPI()

Local cClassImp As Character
Local nY As Numeric
Local nLinFOO As Numeric
Local nTamFOO As Numeric
Local lRet As Logical
Local oModel As Object
Local oSubFOO As Object

oModel		:= FWModelActive()
oSubFOO		:= oModel:GetModel("FOODETAIL")
cClassImp	:= oSubFOO:GetValue("FOO_TIPIMP")
nLinFOO 	:= oSubFOO:GetLine()
nTamFOO		:= oSubFOO:Length()
nY			:= 0
lRet		:= .T.

If Empty(cClassImp)
	HELP(' ',1, 'FOO_VAZIO' ,, STR0060,2,0 )		//"O tipo de imposto deve ter sua classificação preenchida (Principal ou Secundário)"
	lRet := .F.
Endif

If lRet .and. !(Pertence("12")) //!(cClassImp $ "1|2")
	lRet := .F.
Endif

If Empty(oSubFOO:GetValue("FOO_CODIGO")) .And. !Empty(cClassImp)
	HELP(' ',1, 'FO_CODIGO' ,, STR0061,2,0 )		//"O Código digitado possui outra versão com status: Ativo."
	lRet := .F.
EndIf

If lRet .and. cClassImp == '1' 	//Principal
	For nY := 1 To nTamFOO
		oSubFOO:GoLine( nY )
		If !oSubFOO:IsDeleted()
			If cClassImp == oSubFOO:GetValue("FOO_TIPIMP") .and. nLinFOO != nY
				HELP(' ',1, 'FOO_PRINCIPAL' ,, STR0062,2,0,,,,,, {STR0063 + oSubFOO:GetValue("FOO_CODIGO")  } )	//"Apenas um tipo de imposto pode ser o Principal."###'Tipo de imposto principal: '
				lRet := .F.
				Exit
			EndIf
		EndIF
	Next
Endif

oSubFOO:GoLine( nLinFOO )

Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} F24VldVig()
Validação dos campos de vigência

@author Mauricio Pequim Jr
@since	23/10/2017
@version 12
/*/
//-------------------------------------------------------------------
Function F24VldVig(cChaveFKK As Character, dVigIni As Date, dVigFim As Date, cVersao As Character) As Logical

	Local oModel As Object
	Local lRet As Logical
	Local cDes As Character
	Local cSol As Character

	DEFAULT cChaveFKK := ''
	DEFAULT dVigIni := CTOD("//")
	DEFAULT dVigFim := CTOD("//")
	DEFAULT cVersao := ''

	oModel := FWModelActive()
	lRet := .T.
	cDes := ''
	cSol := ''


	If !Empty(cChaveFKK) .and. !Empty(dVigIni) .and. !Empty(dVigFim) .and. !Empty(cVersao)

		While FKK->(!EOF()) .and. cChaveFKK == FKK->(FKK_FILIAL+FKK_CODIGO)

			DO CASE
				//Intersecção Total (inicio e fim)
				Case dVigIni >= FKK->FKK_VIGINI .and. dVigFim <= FKK->FKK_VIGFIM .and. FKK->FKK_VERSAO != cVersao
					cDes 	:= STR0064		// "Existe uma versão com vigência conflitante com a informada (vigência inicial e final internas)."
					cSol 	:= STR0065		//"por favor, verifique as datas de vigência inicial e final."
					cVerFKK := STR0066 + FKK->FKK_VERSAO	//"Versão: "
					lRet := .F.
				//Intersecção de data inicial
				Case dVigIni >= FKK->FKK_VIGINI .and. dVigIni <= FKK->FKK_VIGFIM .and. FKK->FKK_VERSAO != cVersao
					cDes	:= STR0067 	//"Existe uma versão com vigência inicial conflitante com a informada."
					cSol	:= STR0068	//"Por favor, verifique as datas de vigência inicial."
					cVerFKK := STR0066 + FKK->FKK_VERSAO	//"Versão: "
					lRet := .F.

				//Intersecção de data final
				Case dVigFim >= FKK->FKK_VIGINI .and. dVigFim <= FKK->FKK_VIGFIM .and. FKK->FKK_VERSAO != cVersao
					cDes 	:= STR0069 		//"Existe uma versão com vigência final conflitante com a informada."
					cSol 	:= STR0070 		//"Por favor, verifique as datas de vigência final."
					cVerFKK := STR0066 + FKK->FKK_VERSAO	//"Versão: "
					lRet := .F.

				//Intersecção de externa
				Case dVigIni <= FKK->FKK_VIGINI .and. dVigFim >= FKK->FKK_VIGFIM .and. FKK->FKK_VERSAO != cVersao
					cDes	:= STR0071		//"Existe uma versão com vigência conflitante com a informada (vigência inicial e final externas)."
					cSol	:= STR0072 		//"Por favor, verifique as datas de vigência inicial e final."
					cVerFKK := STR0066 + FKK->FKK_VERSAO	//"Versão: "
					lRet := .F.

				Case FKK->FKK_VERSAO == cVersao
					dIniVigOri := FKK->FKK_VIGINI
					dFimVigOri := FKK->FKK_VIGFIM

			ENDCASE

			If !lRet
				HELP(' ',1, STR0073 ,, cDes+' '+cVerFKK ,2,0,,,,,, {cSol} )		//"INTERVALO DE VIGÊNCIA"
				Exit
			Else
				FKK->(DbSkip())
			Endif
		EndDo

		//Se for Ajuste de Vigência
		If lRet .and. __nOper == OPER_VIGENCIA
			If !F024VldExc(oModel)
				lRet := MsgYesNo("Você está alterando a vigência de uma regra financeira que se encontra relacionada a um cliente, fornecedor ou natureza."+CRLF+"Nenhum cálculo realizado anteriormente com base nessa regra financeira será recalculado."+CRLF+"Confirma a alteração?", "Atenção")
				If !lRet
					//Volto os balores originais a
					oModel:SetValue("FKKMASTER","FKK_VIGINI", dVigIni)
					oModel:SetValue("FKKMASTER","FKK_VIGFIM", dVigFim)
					lRet := .T.
				Endif
			Endif
		Endif
	Endif
Return lRet
