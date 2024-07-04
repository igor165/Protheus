#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#include "report.ch"
#Include 'TOTVS.ch'
#Include 'PLSA813.ch'

Static cStaLeg := "" //Variável para filtrar a consulta do Passo de credenciamento

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA813
Funcao para abrir o Credenciamento do Candidato
@author Oscar Zanin
@since 13/03/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA813(lAutoma)

Local aCoors := FWGetDialogSize( oMainWnd )
Local oPanelUp	:= NIL
Local oFWLayer	:= NIL
Local oPanelDown	:= NIL
Local oBrowseUp		:= NIL
Local oBrowseDown	:= NIL
Local oRelac		:= NIL
Local oDialog		:= NIL
default lAutoma := iif( valtype(lAutoma) <> "L", .f., lAutoma )	

if !lAutoma
	DEFINE MsDialog oDialog Title 'Credenciamento' From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel

	// Cria o conteiner onde serão colocados os browses
	oFWLayer := FWLayer():New()
	oFWLayer:Init( oDialog, .F., .T. )


	// Define Painel Superior
	oFWLayer:AddLine( 'UP', 70, .F. )
	oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' )
	oPanelUp := oFWLayer:GetColPanel( 'ALL', 'UP' )

	// Painel Inferior
	oFWLayer:AddLine( 'DOWN', 30, .F. )
	oFWLayer:AddCollumn( 'TUDO' , 100, .T., 'DOWN' )
	oPanelDown := oFWLayer:GetColPanel( 'TUDO', 'DOWN' ) 
endif 

// FWmBrowse Superior Candidatos
oBrowseUp:= FWmBrowse():New()
// Aqui se associa o browse ao componente de tela
oBrowseUp:SetOwner( oPanelUp )
oBrowseUp:SetDescription( "Candidatos" )
oBrowseUp:SetAlias( "B9Y" )
// Define de onde virao os botoes deste browse
oBrowseUp:SetMenuDef( 'PLSA813' )
oBrowseUp:SetProfileID( '1' )
oBrowseUp:ForceQuitButton()

//Cria Legenda do Browse
oBrowseUp:AddLegend( "PLS813LEGE()=='1'"	, "RED"	, STR0001)//"Pendente com a Operadora"
oBrowseUp:AddLegend( "PLS813LEGE()=='2'"	, "ORANGE"	, STR0002)//"Pendente com o Prestador"
oBrowseUp:AddLegend( "PLS813LEGE()=='3'"	, "GREEN"	, STR0003)//"Credenciado"
oBrowseUp:AddLegend( "PLS813LEGE()=='4'"	, "GRAY"	, STR0004)//"Indeferido"
oBrowseUp:DisableDetails()
iif(!lAutoma, oBrowseUp:Activate(), '')

// FWmBrowse Inferior Especialidades
oBrowseDown:= FWMBrowse():New()
oBrowseDown:SetOwner( oPanelDown )
oBrowseDown:SetDescription( 'Especialidades' )
oBrowseDown:SetAlias( "B9Q" )
// Referencia vazia para que nao exiba nenhum botao
oBrowseDown:SetMenuDef( '' )
oBrowseDown:SetProfileID( '2' )

oBrowseDown:DisableDetails()
oBrowseDown:DisableConfig()
oBrowseDown:DisableLocate()
oBrowseDown:DisableSeek()
oBrowseDown:DisableSaveConfig()
oBrowseDown:DisableReport()
oBrowseDown:SetAmbiente(.F.)
oBrowseDown:SetWalkThru(.F.)
//Cria Legenda do Browse
oBrowseDown:AddLegend( "PLS813SUBL()=='1'"	, "RED"	, STR0001)//"Pendente com a Operadora"
oBrowseDown:AddLegend( "PLS813SUBL()=='2'"	, "ORANGE"	, STR0002)//"Pendente com o Prestador"
oBrowseDown:AddLegend( "PLS813SUBL()=='3'"	, "GREEN"	, STR0003)//"Credenciado"
oBrowseDown:AddLegend( "PLS813SUBL()=='4'"	, "GRAY"	, STR0004)//"Indeferido"
iif(!lAutoma, oBrowseDown:Activate(), '')

// Relacionamento entre os Paineis
oRelac:= FWBrwRelation():New()
oRelac:AddRelation( oBrowseUp , oBrowseDown , { 	{ 'B9Q_FILIAL', 'xFilial( "B9Q" )' },;
													   	{ 'B9Q_CODPRO', 'B9Y_CODIGO'		},;
													   	{ 'B9Q_CODINT', 'B9Y_CODINT'		}	} )
oRelac:Activate()

if !lAutoma
	Activate MsDialog oDialog Center
endif

Return

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

Add Option aRotina Title STR0005 /*'Visualizar'*/ Action 'VIEWDEF.PLSA813' Operation 2 Access 0

//Caso seja chamada a partir do módulo callcenter, não deve exibir as opções de inclusão e análise dos passos. Apenas visualização.
If FunName() <> "TMKA271"
	Add Option aRotina Title STR0006 /*'Incluir'*/    Action 'VIEWDEF.PLSA813' Operation 3 Access 0
	Add Option aRotina Title STR0007 /*'Analisar' */  Action 'VIEWDEF.PLSA813' Operation 4 Access 0
EndIf

Add Option aRotina Title STR0008 /*'Imprimir' */ Action 'VIEWDEF.PLSA813' Operation 8 Access 0

//Adiciona opções extras no menu 'Outras Ações'
AAdd(aRotina, { STR0009 /*'Anexos'*/	,"PLSBAN813()"	, 0, 0} )
Aadd(aRotina, { STR0010 /*'RDA'*/		,"PLS813ORDA()"	, 0, 0} )

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados
@author Oscar Zanin
@since 13/03/2015
@version P12.
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel // Modelo de dados construído
Local oStrB9Y:= FWFormStruct(1,'B9Y', { |cCampo| PLS813B9Y(cCampo) } ) // Cria as estruturas a serem usadas no Modelo de Dados, ajustando os campos que iráconsiderar
Local oStrB9Q:= FWFormStruct(1,'B9Q') // Cria as estruturas a serem usadas no Modelo de Dados
Local oStrB9V:= FWFormStruct(1,'B9V', { |cCampo| PLSAB9V813(cCampo)} ) // Cria as estruturas a serem usadas no Modelo de Dados
Local oStrB2E:= FWFormStruct(1,'B2E')
Local oStrB2F:= FWFormStruct(1,'B2F')

oModel := MPFormModel():New( 'PLSA813' , , { |oModel| PLS813OK(oModel) } /*Função do Ok*/, , { || PLS813CNCL() } /*Função do Cancelar*/) // Cria o objeto do Modelo de Dados e insere a funçao de pós-validação e de cancelamento

//ADD FIELDS
oModel:addFields('MasterB9Y',/*cOwner*/,oStrB9Y)  // Adiciona ao modelo um componente de formulário

//ADD GRID
oModel:AddGrid('B9VDetail', 'MasterB9Y', oStrB9V, { |oMdlG,nLine,cAcao,cCampo| Vld813Del( oMdlG, nLine, cAcao, cCampo ) }) // Adiciona ao modelo uma componente de grid
oModel:AddGrid('B9QDetail', 'B9VDetail', oStrB9Q, { |oMdlG,nLine,cAcao,cCampo| Vld813Del( oMdlG, nLine, cAcao, cCampo ) }) // Adiciona ao modelo uma componente de grid
oModel:AddGrid('B2EDetail', 'B9QDetail', oStrB2E, { |oMdlG,nLine,cAcao,cCampo| Vld813Del( oMdlG, nLine, cAcao, cCampo ) }, { |oB2E| PLS813Weee(oB2E)}, /*{ || M->B2E_STATUS}*/, /*{ || M->B2E_STATUS}*/) // Adiciona ao modelo uma componente de grid
oModel:AddGrid('B2FDetail', 'B2EDetail', oStrB2F, { |oMdlG,nLine,cAcao,cCampo| Vld813DlAl( oMdlG, nLine, cAcao, cCampo, oModel ) }) // Adiciona ao modelo uma componente de grid

//SET RELATION
oModel:SetRelation( 'B9VDetail', { { 'B9V_FILIAL'	, 'xFilial( "B9V" )' },; //Endereços
										{ 'B9V_CODINT'	, 'B9Y_CODINT' 		},;
										{ 'B9V_CODPRO'	, 'B9Y_CODIGO'		} },;
										B9V->( IndexKey(  ) ) )  // Faz relacionamento entre os componentes do model
										
oModel:SetRelation( 'B9QDetail', {	{ 'B9Q_FILIAL'	, 'xFilial( "B9Q" )' },; //Especialidades
									{ 'B9Q_CODINT'	, 'B9V_CODINT' 		 },;
       								{ 'B9Q_CODLOC'	, 'B9V_CODSEQ' 		 },;
       								{ 'B9Q_CODPRO'	, 'B9V_CODPRO'		 } },;
       				   				B9Q->( IndexKey(4) ) )  // Faz relacionamento entre os componentes do model

oModel:SetRelation( 'B2EDetail', { { 'B2E_FILIAL' 	, 'xFilial( "B2E" )' },; //Passos do Credenciamento
								   { 'B2E_CODESP'	, 'B9Q_CODESP'		},;
								   { 'B2E_CODLOC'	, 'B9Q_CODLOC'		},;
								   { 'B2E_CODIGO'	, 'B9Q_CODPRO'		},;
								   { 'B2E_CODINT'	, 'B9Q_CODINT' 		} },;							
									B2E->( IndexKey(2) ) )  // Faz relacionamento entre os componentes do model								
										
oModel:SetRelation( 'B2FDetail', { { 'B2F_FILIAL' 	, 'xFilial( "B2F" )' },; //Histórico
										{ 'B2F_CODPAS'	, 'B2E_CODPAS'		},;
										{ 'B2F_CODIGO'	, 'B2E_CODIGO'		},;
										{ 'B2F_CODINT'	, 'B2E_CODINT' 		},;
										{ 'B2F_CODLOC'	, 'B2E_CODLOC'		},;
										{ 'B2F_CODESP'	, 'B2E_CODESP'		},;
										{ 'B2F_CODSEQ'	, 'B2E_CODSEQ'		} },;
										B2F->( IndexKey( 1 ) ) )  // Faz relacionamento entre os componentes do model

//SET DESCRIPTION									
oModel:GetModel('MasterB9Y'):SetDescription(FunDesc()) // Adiciona a descrição do Modelo de Dados

//SET OPTIONAL
oModel:GetModel( 'B2FDetail' ):SetOptional( .T. )

//SET PRIMARY KEY
oModel:SetPrimaryKey( {"B9Y_FILIAL", "B9Y_CODIGO"} )

//SET PROPERTY
oStrB2E:SetProperty( 'B2E_STATUS', MODEL_FIELD_WHEN , { || PLS813CanC(oModel)} )
oStrB2E:SetProperty( 'B2E_CODPAS', MODEL_FIELD_WHEN , { || PLS813Whe1(oModel)} )
oStrB2E:setProperty( 'B2E_CODPAS', MODEL_FIELD_VALID, { || PLS813VlPs(oModel)} )
oStrB9Y:SetProperty( 'B9Y_NOME'  , MODEL_FIELD_VALID, { || PLS813VldZ(oModel, "MasterB9Y", "B9Y_NOME")})
oStrB9Y:SetProperty( 'B9Y_CPFCGC', MODEL_FIELD_VALID, { || PLS813Vld2(oModel)})
oStrB9V:SetProperty( 'B9V_ENDER' , MODEL_FIELD_VALID, { || PLS813VldZ(oModel, "B9VDetail", "B9V_ENDER")})
oStrB9V:SetProperty( 'B9V_COMEND', MODEL_FIELD_VALID, { || PLS813VldZ(oModel, "B9VDetail", "B9V_COMEND")})
oStrB9V:SetProperty( 'B9V_BAIRRO', MODEL_FIELD_VALID, { || PLS813VldZ(oModel, "B9VDetail", "B9V_BAIRRO")})
oStrB2F:SetProperty( 'B2F_DESCRI', MODEL_FIELD_VALID, { || PLS813VldZ(oModel, "B2FDetail", "B2F_DESCRI")})
oStrB9V:SetProperty( 'B9V_CODPRO', MODEL_FIELD_INIT , { || oModel:getModel("MasterB9Y"):getValue("B9Y_CODIGO")})
oStrB9Q:SetProperty( 'B9Q_CODPRO', MODEL_FIELD_INIT , { || oModel:getModel("MasterB9Y"):getValue("B9Y_CODIGO")})

oStrB9Q:SetProperty( 'B9Q_CODLOC', MODEL_FIELD_INIT , { || oModel:getModel("B9VDetail"):getValue("B9V_CODSEQ")})
oStrB2E:SetProperty( 'B2E_CODLOC', MODEL_FIELD_INIT , { || oModel:getModel("B9QDetail"):getValue("B9Q_CODLOC")})
oStrB2F:SetProperty( 'B2F_CODESP', MODEL_FIELD_INIT , { || oModel:getModel("B9QDetail"):getValue("B9Q_CODESP")})

oStrB9Y:SetProperty( 'B9Y_NASCTO', MODEL_FIELD_VALID, { || PLS813Vld1(oModel)})
oStrB9Y:SetProperty( 'B9Y_TEL'   , MODEL_FIELD_OBRIGAT, .F.) //Este campo é obrigatório somente para a rotina de Indicação
oStrB9Y:SetProperty( 'B9Y_STCRED', MODEL_FIELD_OBRIGAT, .T.) //Este campo é obrigatório somente para esta rotina

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
Local oModel := FWLoadModel( 'PLSA813' ) // Cria as estruturas a serem usadas na View

Local oStrB9Y:= FWFormStruct(2,'B9Y', { |cCampo| PLS813B9YV(cCampo)} ) // Cria as estruturas a serem usadas no Modelo de Dados, ajustando os campos que irá considerar
Local oStrB9Q:= FWFormStruct(2,'B9Q', { |cCampo| PLS813B9Q(cCampo) } ) // Cria as estruturas a serem usadas no Modelo de Dados, ajustando os campos que irá considerar
Local oStrB9V:= FWFormStruct(2,'B9V', { |cCampo| PLSAB9V813(cCampo)} ) // Cria as estruturas a serem usadas no Modelo de Dados, ajustando os campos que irá considerar
Local oStrB2E:= FWFormStruct(2,'B2E', { |cCampo| PLS813B2E(cCampo) } ) // Cria as estruturas a serem usadas no Modelo de Dados, ajustando os campos que irá considerar
Local oStrB2F:= FWFormStruct(2,'B2F', { |cCampo| PLS813B2F(cCampo) } ) // Cria as estruturas a serem usadas no Modelo de Dados, ajustando os campos que irá considerar

B9Q->(DbCloseArea()) //O novo Grid (inferior do Browse)deixa a B9Q aberta, tem que fazer isso pra ele não
						//trazer uma especialidade aleatória ao inserir linhas no Grid de especialidades.

oView := FWFormView():New() // Cria o objeto de View

//SET MODEL
oView:SetModel(oModel)		// Define qual Modelo de dados será utilizado

//ADD FIELD
oView:AddField('ViewB9Y' , oStrB9Y,'MasterB9Y' ) // Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)

//ADD GRID
oView:AddGrid( 'ViewB9Q' , oStrB9Q,'B9QDetail' ) //Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
oView:AddGrid( 'ViewB2E' , oStrB2E,'B2EDetail' ) //Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
oView:AddGrid( 'ViewB9V' , oStrB9V,'B9VDetail' ) //Adiciona no nosso View um controle do tipo Grid (antiga Getdados)
oView:AddGrid( 'ViewB2F' , oStrB2F,'B2FDetail' ) //Adiciona no nosso View um controle do tipo Grid (antiga Getdados)

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

//ADD SHEET
oView:AddSheet( 'ABA', 'T1', 'Endereço'  ) //Cria Primeira aba (Tabela B9P)
oView:AddSheet( 'ABA', 'T2', 'Especialidade'  ) //Cria Segunda aba (Tabelas B9V, B9R, B9Q e Campo B9P_OBSERV)
oView:AddSheet( 'ABA', 'T3', 'Passos do Credenciamento'  ) //Cria Segunda aba (Tabelas B9V, B9R, B9Q e Campo B9P_OBSERV)

//SET OWNER
oView:SetOwnerView('ViewB9Y', 'SUPERIOR'	) // Relaciona o identificador (ID) da View com o "box" para exibição
oView:SetOwnerView('ViewB2F', 'BAIXO'	 	) // Relaciona o identificador (ID) da View com o "box" para exibição
oView:SetOwnerView('ViewB9V', 'A'			) // Relaciona o identificador (ID) da View com o "box" para exibição (Grids dentro do detalhe MEIO)
oView:SetOwnerView('ViewB9Q', 'B'			) // Relaciona o identificador (ID) da View com o "box" para exibição (Grids dentro do detalhe MEIO)
oView:SetOwnerView('ViewB2E', 'C'			) // Relaciona o identificador (ID) da View com o "box" para exibição (Grids dentro do detalhe MEIO)

//INCREMENTAL FIELD
oView:AddIncrementField( 'ViewB9Q' , 'B9Q_CODSEQ') //Adiciona Campo incremental na View
oView:AddIncrementField( 'ViewB9V' , 'B9V_CODSEQ') //Adiciona Campo incremental da View

//FIELD ACTION
oView:SetFieldAction('B9V_CEP'   , { |oModel| PLS806CEP(oModel)} )  //Preenche os campos correspondentes ao digitar o CEP
oView:SetFieldAction('B2F_DESCRI', { |oModel| PLS813DBas(oModel, oView,"B2F_DATAIN" ,"B2FDetail")})  //Preenche a data atual ao inserir uma observação no histórico
oView:SetFieldAction('B2E_CODPAS', { |oModel| PLS813DBaZ(oModel, oView,"B2E_DATAIN" ,"B2EDetail",.F.)})  //Preenche a data atual e Responsável pelo passo
oView:SetFieldAction('B2E_STATUS', { |oModel| PLS813Mem2(oModel, oView), PLS813AAAA(oModel, oView)})	//PAssa o valor da model para a variável de memória 
oView:SetFieldAction('B9Y_CPFCGC', { |oModel| M->B9Y_CPFCGC := oModel:GetModel('MasterB9Y'):GetValue('B9Y_CPFCGC')/*PLSA806PIC()*/}) //Máscara CPF / CNPJ

//SET PROPERTY
oStrB9V:SetProperty( 'B9V_CEP', MVC_VIEW_ORDEM , '02'    ) //Passa o CEP para o início da Grid
oStrB9V:SetProperty( 'B9V_CEP', MVC_VIEW_LOOKUP, 'B9VCEP') //Adiciona a Consulta padrão ao campo
oStrB9Y:SetProperty( 'B9Y_SEXO', MVC_VIEW_ORDEM, '12'	 ) //Move o campo para a posição constante na especificação
oStrB9V:SetProperty( 'B9V_DEFERE', MVC_VIEW_ORDEM, '00'	 ) //Primeiro campo da Grid
oStrB9Q:SetProperty( 'B9Q_DEFERE', MVC_VIEW_ORDEM, '00'	 ) //Primeiro campo da Grid
oStrB9Y:SetProperty( 'B9Y_CPFCGC', MVC_VIEW_PVAR, {|oModel| PLSA813PIC()}) //Máscara CPF / CNPJ
oStrB9Q:SetProperty( 'B9Q_DESESP', MVC_VIEW_INIBROW, ""	 ) //não utiliza inicializador no Grid

//ADD USER BUTTON
oView:AddUserButton(STR0011 /*"Gerar Senha"*/, "", { || PLS813SE(oModel) } ) //Cria o botão de Gerar Senha na View
oView:AddUserButton(STR0012 /*"Anexos"*/, "", {|| PLSBAN813(oModel) } ) //Abre o banco de conhecimento relacionado à tabela BAU
oView:AddUserButton(STR0013 /*"Analisar Disponibilidade"*/, "", {|| PLSA813DISP(oModel) } )//Inicia Rotina de verificação de Disponibilidade
oView:AddUserButton(STR0010 /*"RDA"*/, "", {|| PLS813VCad(oModel)} )//Gera RDA/Envia usuário para a tela da RDA
oView:AddUserButton(STR0014 /*"Gerar Contrato"*/, "", {|| PLS813GCON(oModel) } )//Envia usuário para a tela de gerar contrato

//ENABLE TITLE VIEW
oView:EnableTitleView( 'ViewB2F', STR0064 /*"Histórico"*/	) //Atribui título para a View

If oView:GetOperation() <> 3 //!(INCLUI) //Inicializa a variável STATIC
	cStaLeg := B9Y->B9Y_STCRED
else
	cStaleg := ""
EndIf

Return oView // Retorna o objeto de View criado


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS813LEGE()
Definição da Legenda a ser apresentada
@author Oscar Zanin
@since 13/03/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS813LEGE()

Local cRet

cRet := B9Y_STCRED

Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS813B9Y
Filtra os campos a serem apresentados na tela e considerados no Model
@author Oscar Zanin
@since 16/03/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS813B9Y(cCampo)

Local lRet	:= .T.
	
If cCampo == "B9Y_CARTEI"
	lRet := .F.
EndIf

If cCampo == "B9Y_NOMBEN"
	lRet := .F.
EndIf

If cCampo == "B9Y_RAZSOC"
	lRet := .F.
EndIf

If cCampo == "B9Y_OBS   "
	lRet := .F.
EndIf

If cCampo == "B9Y_SOINDI"
	lRet := .F.
EndIf

If cCampo == "B9Y_LOGIN "
	lRet := .F.
EndIf

If cCampo == "B9Y_SENHA "
	lRet := .F.
EndIf
	
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS813B9Q
Filtra os campos a serem apresentados na tela e considerados na View
@author Oscar Zanin
@since 23/03/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS813B9Q(cCampo)

Local lRet := .F.

If cCampo == "B9Q_CODSEQ"
	lRet := .T.
EndIf

If cCampo == "B9Q_CODESP"
	lRet := .T.
EndIF

If cCampo == "B9Q_DESESP"
	lRet := .T.
EndIf

If cCampo == "B9Q_TEMFOR"
	lRet := .T.
EndIf

If cCampo == "B9Q_DESTEM"
	lRet := .T.
EndIf

If cCampo == "B9Q_TEMESP"
	lRet := .T.
EndIf

If cCampo == "B9Q_DTMESP"
	lRet := .T.
EndIf

If cCampo == "B9Q_DEFERE"
	lRet	:= .T.
EndIf

Return(lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS813OK
Valida a inclusão do Registro
@author Oscar Zanin
@since 17/03/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS813OK(oModel)

Local lRet		:= .T.
Local oB9Y		:= oModel:GetModel("MasterB9Y")
Local oB9V		:= oModel:GetModel("B9VDetail")
Local oB9Q		:= oModel:GetModel("B9QDetail")

Local cMes		:= ""
Local cAno		:= ""
Local cProt	:= ""

Local nB9V		:= 0
Local nB9Q		:= 0

Local nTam9V	:= oB9V:Length()
Local nTam9Q	:= oB9Q:Length()

Local nOpc 	:= oModel:GetOperation()
Local nCont	:= 0

PLS813VDEL(oModel) //Remove registros vinculados a registros deletados

//Gera o número do Protocolo
If nOpc == 3
  	cMes        := ALLTRIM(STRZERO(Month(Date()), 2))
  	cAno        := SUBSTR(ALLTRIM(STR(Year(Date()))), -2) 
  	cProt       := cMes + cAno + ALLTRIM(oB9Y:GetValue('B9Y_CODIGO'))
  	oB9Y:SetValue('B9Y_NROPRO', cProt)	
EndIf         

//Este For vai posicionar registro por registro da Grid, verificando
//cada localidade e cada especialidade vinculada à ela e cada passo
//vinculado à especialidade. A Ideia disso é evitar problemas com o 
//X2 Único, pois poderão haver mais de um passo igual para a mesma especialidade.
//O segundo For tem por objetivo Verificar as observações vinculadas a cada passo.    
For nB9V	:= 1 To nTam9V
	oB9V:GoLine( nB9V ) //posiciona no registro do endereço
	
	oB9Q	:= oModel:GetModel("B9QDetail")
	nTam9Q	:= oB9Q:Length()

	For nB9Q := 1 To nTam9Q
		oB9Q:GoLine( nB9Q ) //Posiciona no Registro da Especialidade
		oB9Q:SetValue('B9Q_CODLOC', oB9V:getValue("B9V_CODSEQ"))
		PLSA813SEQ(oModel, "B2E", "B2E_CODSEQ", "B2EDetail", 3, nCont, oB9V:getValue("B9V_CODSEQ"), oB9Q:getValue("B9Q_CODESP")) //Executa função para preencher o sequencial, Referente
		nCont := nCont + 1																  //à tabela de Passo de Credenciamento		
	Next
Next	

P813Defere(oModel) //Realiza a checagem se alguma especialidade foi Deferida.

PLS813MAIL(oModel)

cStaLeg := '' //Limpa a variável STATIC

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS813B2E
Filtra os campos a serem apresentados na tela e considerados na View
@author Oscar Zanin
@since 23/03/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS813B2E(cCampo)

Local lRet := .F.

If cCampo == "B2E_CODPAS"
	lRet := .T.
EndIf

If cCampo == "B2E_DESCRI"
	lRet := .T.
EndIf

If cCampo == "B2E_DATAIN"
	lRet := .T.
EndIf

If cCampo == "B2E_DATAFM"
	lRet := .T.
EndIf

If cCampo == "B2E_USUARI"
	lRet := .T.
EndIf

If cCampo == "B2E_USUARF"
	lRet := .T.
EndIF

If cCampo == "B2E_STATUS"
	lRet := .T.
EndIf

Return (lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS813B2F
Filtra os campos a serem apresentados na tela e considerados na View
@author Oscar Zanin
@since 23/03/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS813B2F(cCampo)

Local lRet := .F.

If cCampo == "B2F_DATAIN"
	lRet := .T.
EndIf

If cCampo == "B2F_DESCRI"
	lRet := .T.
EndIf

Return (lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS813DBas
Preenche o campo da data de inclusão da observação no histórico (função para Grids)
@author Oscar Zanin.
@since 23/03/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS813DBas(oModel, oView, cCampo, cModel)

Local oB2F := oModel:GetModel(cModel)

oB2F:SetValue(cCampo, dDataBase)

oView:Refresh()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS813B9YV
Filtra os campos a serem apresentados na tela e considerados na View
@author Oscar Zanin
@since 16/03/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS813B9YV(cCampo)

Local lRet	:= .T.
	
If cCampo == "B9Y_CARTEI"
	lRet := .F.
EndIf

If cCampo == "B9Y_NOMBEN"
	lRet := .F.
EndIf

If cCampo == "B9Y_RAZSOC"
	lRet := .F.
EndIf

If cCampo == "B9Y_OBS   "
	lRet := .F.
EndIf

If cCampo == "B9Y_NROPRO"
	lRet := .F.
EndIf

If cCampo == "B9Y_CODINT"
	lRet := .F.
EndIf

If cCampo == "B9Y_DESINT"
	lRet := .F.
EndIf

If cCampo == "B9Y_ROTINA"
	lRet := .F.
EndIf

If cCampo == "B9Y_DATAIN"
	lRet := .F.
EndIf

If cCampo == "B9Y_CODRDA"
	lRet := .F.
EndIf

If cCampo == "B9Y_SOINDI"
	lRet := .F.
EndIf

If cCampo == "B9Y_LOGIN "
	lRet := .F.
EndIf

If cCampo == "B9Y_SENHA "
	lRet := .F.
EndIf
	
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS813PaCr
Preenche o passo do credenciamento Atual ao preencher um novo passo e o
Responsável pela inclusão do Passo.
@author Oscar Zanin
@since 23/03/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS813PaCr(oModel)

Local oB9Y 	:= oModel:Getmodel("MasterB9Y")
Local oB2E 	:= oModel:getModel("B2EDetail")
Local oB2F 	:= oModel:getModel("B2FDetail")
Local oB9Q	:= oModel:GetModel("B9QDetail")
Local cPasso 	:= oB2E:GetValue("B2E_CODPAS")
Local cCodInt := PLSINTPAD()
Local cStatus := Posicione("B99", 1, xFilial('B99')+cCodInt+cPasso, "B99_STLEGP")

oB9Y:setValue( "B9Y_STCRED", cStatus )
oB9Y:SetValue( "B9Y_PCRED" , cPasso+'-'+Posicione("B99", 1, xFilial('B99')+cCodInt+cPasso, "B99_DESCRI"))
oB2E:SetValue( "B2E_USUARI", UsrFullName( RetCodUsr() ) )
oB2E:SetValue( "B2E_CODLOC", oB9Q:GETValue( "B9Q_CODLOC",oB9Q:nLine) )
oB2F:SetValue( "B2F_CODLOC", oB9Q:GETValue( "B9Q_CODLOC",oB9Q:nLine) )
oB2F:LoadValue( "B2F_CODIGO", oB9Y:GETValue( "B9Y_CODIGO") ) 
oB2E:LoadValue( "B2E_CODIGO", oB9Y:GETValue( "B9Y_CODIGO") ) 
oB9Q:SetValue( "B9Q_STCRED", cStatus )

Return (cPasso)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS813DBaZ
Preenche o campo da data de inclusão da observação no histórico (função para Grids)
E executa preenchimento dos campos relacionados
@author Oscar Zanin
@since 23/03/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS813DBaZ(oModel, oView, cCampo, cModel,lAutoma)

Local oB2E 		:= oModel:GetModel(cModel)
Local dDataI
Local cCodPas		:= oB2E:GetValue("B2E_CODPAS")
Local cCodMail	:= ""
Local cCodInt		:= PLSINTPAD() 
Local cDescri		:= Posicione("B99", 1, xFilial("B99") + cCodInt + cCodPas, "B99_DESCRI")

default lAutoma :=.F.

B99->(DbSelectArea("B99"))
B99->(DbSetOrder(1))

If B99->(MsSeek(xFilial("B99") + cCodInt + cCodPas))
				
	cCodMail := AllTrim(B99->B99_CODEMA)
	
EndIF

B99->(DbCloseArea())

IF !(cCodMail == "")

		If !lAutoma .And. !(MsgYesNo(STR0015 /*"A inclusão deste passo está associada ao envio de informação para o Candidato, confirma a inclusão deste passo?"*/, STR0016 /*"Atenção!"*/))
			
			cCodPas := ""
		
		EndIf
EndIf

If AllTrim(cCodPas) == ""

	oB2E:ClearField("B2E_CODPAS", , .T.)
	oB2E:ClearField(cCampo)
	oB2E:ClearField("B2E_DESCRI")
	oB2E:ClearField("B2E_USUARI")
	oB2E:SetValue("B2E_STATUS", .F.)
	oB2E:ClearField("B2E_DATAFM")
	
	M->B2E_DATAIN := ""
	M->B2E_CODPAS	:= cCodPas

Else

	oB2E:SetValue(cCampo, dDataBase)
	oB2E:Setvalue("B2E_DESCRI", cDescri)
	
	dDataI := oB2E:GetValue("B2E_DATAIN")

	M->B2E_DATAIN := dDataI
	M->B2E_CODPAS	:= cCodPas

	PLS813PaCr(oModel)
	
EndIf

iif(!lAutoma,oView:Refresh(), )

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS813SE
Valida se os campos necessários estão preenchidos e inicializa a rotina de
geração de senhas.
@author Oscar Zanin
@since 23/03/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS813SE(oModel)

Local oMaster := oModel:GetModel("MasterB9Y")
Local oB9V		:= oModel:GetModel("B9VDetail")

Local cCodU	:= oMaster:GetValue("B9Y_CODIGO")
Local cMailU	:= oMaster:GetValue("B9Y_EMAIL")
Local cCodLoc	:= oB9V:GetValue("B9V_CODSEQ")
Local cCodRDA	:= oMaster:GetValue("B9Y_CODRDA")
Local cCPFCGC	:= oMaster:GetValue("B9Y_CPFCGC")

Local lTeste	:= .T.

Local cLogin	:= ""
Local cSenha	:= ""

Local nRecno	:= B9Y->(Recno())

If Vazio(cCodRDA)
	
	Help(nil, nil , "Atenção"  , nil, STR0017/*"Não houve geração da RDA para o candidato! Impossível criar senha!"*/ , 1, 0, nil, nil, nil, nil, nil,nil) 
	lTeste := .F.

ElseIf Vazio(cCodU)

	Help(nil, nil , "Atenção"  , nil, STR0018/*"Código do candidato não gerado! Impossível criar senha!"*/, 1, 0, nil, nil, nil, nil, nil,nil) 
	lTeste := .F.
	
ElseIf Vazio(cMailU)
	
	Help(nil, nil , "Atenção"  , nil, STR0019/*"Email não preenchido! Impossível criar senha!"*/, 1, 0, nil, nil, nil, nil, nil,nil) 
	lTeste := .F.

ElseIf Vazio(cCodLoc)
	
	Help(nil, nil , "Atenção"  , nil, STR0020/*"Localidade não preenchida! Impossível criar senha!"*/, 1, 0, nil, nil, nil, nil, nil,nil) 
	lTeste := .F.

ElseIf Vazio(cCPFCGC)
	
	Help(nil, nil , "Atenção"  , nil, STR0065/*CPF/CNPJ não informado, impossível gerar senha!*/, 1, 0, nil, nil, nil, nil, nil,nil) 
	lTeste := .F.

EndIf

If !(Vazio(cCodRDA)) .AND. lTeste //Se tem RDA e não deu erro...

	B9Y->(DbSelectArea("B9Y"))
	B9Y->(DbSetOrder(4))
	If B9Y->(MsSeek(xFilial("B9Y") + PLSINTPAD() + cCodRDA)) //Posiciona no primeiro registro da RDA
		
		//Varremos a tabela, pra ver se já não foi gerada a senha e login para o candidato
		While B9Y->(!(EoF())) .AND. B9Y->B9Y_CODINT = PLSINTPAD() .AND. B9Y->B9Y_CODRDA = cCodRDA .AND. lTeste
			
			//Se achamos algum registro, atribuímos os valores de Login e Senha pras variáveis
			//e .F. para o lTeste
			If !Empty(B9Y->B9Y_LOGIN) .AND. !Empty(B9Y->B9Y_SENHA)
				
				lTeste := .F.
				cLogin := B9Y->B9Y_LOGIN
				cSenha	:= B9Y->B9Y_SENHA
				
			EndIf
			
			B9Y->(DbSkip())
			
		EndDo
		
		If !lTeste //Se lTeste ficou .F., então achamos Login e Senha.. 
		
			B9Y->(DbSetFilter( {|| B9Y_CODRDA = B9Y->B9Y_CODRDA}, ""))
			B9Y->(DbGoTop())
		
			B9Y->(RecLock("B9Y", .F.))
				
				//Varremos a abela gravando o Login e Senha pras ocorrências do mesmo codigo de RDA
				While B9Y->(!(EoF())) .AND. B9Y->B9Y_CODINT = PLSINTPAD() .AND. B9Y->B9Y_CODRDA = cCodRDA
			
					B9Y->B9Y_LOGIN := cLogin
					B9Y->B9Y_SENHA := cSenha
					B9Y->(DbSkip())
					
				EndDo
				
			B9Y->(MsUnlock())
			
			Help(nil, nil , "Atenção"  , nil, STR0021/*"O candidato já possui Login e Senha cadastrado!"*/, 1, 0, nil, nil, nil, nil, nil,nil) 
			
		EndIf
	B9Y->(DbCloseArea())
	
	EndIf	
EndIf

If lTeste
	
	PLSA812(cCPFCGC, cMailU, cCodLoc, , ,nRecno) //Login padrão via cadastramento é o CPF/CNPJ
														//Pode ser alterado através do ponto de entrada
														// PL812LOG, verificar o fonte PLSA812 para melhores
														//informações
	
	oMaster:SetValue("B9Y_STCRED", '2')
	
EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS813Memo
Altera a variável de memória para que o filtro da consulta padrão do passo funcione corretamente.
--Função descontinuada a aprtir do chamado
@author Oscar Zanin
@since 24/03/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS813Memo(oModel)

Local oA		:= oModel:GetModel("MasterB9Y")
Local cStatus	:= oA:Getvalue("B9Y_STCRED")
	
cStaLeg := cStatus

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSBAN813
Banco de conhecimento da rotina. Irá ser adequado para exibir os documentos cadastrados no Portal.
@author Oscar Zanin
@since 26/03/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSBAN813(oModel) 

Local oB9Y 	//:= oModel:GetModel("MasterB9Y")
Local cCodRDA := "" //oB9Y:GetValue("B9Y_CODRDA")
Local cMsg		:= STR0022 //"Não foi cadastrada a RDA do prestador, não é possível utilizar o Banco de Conhecimento"

Private aRotina 		:= {}

If ValType(oModel) == "O"
	
	oB9Y 	 := oModel:GetModel("MasterB9Y")
	cCodRDA := oB9Y:GetValue("B9Y_CODRDA")

else
	
	cCodRDA := B9Y->B9Y_CODRDA
	
EndIf
	
If AllTrim(cCodRDA) <> ""

	aRotina := {{"Conhecimento",'MsDocument',0/*permite exclusao do registro*/,1/*visualizar arquivo*/},{"Inclusão Rápida",'PLSDOcs',0,3}}
	
	BAU->(DbSelectArea("BAU"))
	BAU->(DbSetOrder(1))
	
	If BAU->(MsSeek(xFilial("BAU") + cCodRDA)) //Posiciona no registro do Candidato
	
		MsDocument( "BAU", BAU->( RecNo() ), 2 )
	
	EndIf
	
	BAU->(DbCloseArea())
	
else
	
	Help(nil, nil , STR0016  , nil, cMsg, 1, 0, nil, nil, nil, nil, nil,nil) 
	
EndIf

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS813OBR1
Define se obrigatório ou não
@author Oscar Zanin
@since 26/03/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS813OBR1()

Local lRet 	:= .T.
Local dDataI	:= M->B2E_DATAIN

If !(Empty(dDataI))
	
	lRet := .T.

EndIf

Return (lRet)



//-------------------------------------------------------------------
/*/{Protheus.doc} PLS813CRDA
Abre a tela da RDA posicionada para ajustar o conteúdo.
@author Oscar Zanin
@since 27/03/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS813CRDA(oModel,lAutoma)

Local oB9V			:= oModel:GetModel('B9VDetail')
Local oB9Q			:= oModel:GetModel('B9QDetail')

Local nOper	 	:= oModel:GetOperation()
Local cCodRDA		:= iif(!lAutoma,PLS813VERI(oModel),)

Local n9V			:= 0
Local nTam9V		:= oB9V:Length()
Local n9Q			:= 0
Local nTam9Q		:= 0
default lAutoma := .F.	

Static aRetorno	:= {}

//Grupo de Variáveis provenientes do PLSA360, estão aqui pra chamar a rotina sem passar pelo Browse
PRIVATE aRotina     := PLS813Menu() //Esta função é o MenuDef do PLSA360. Só está qui devido o MenuDef ser STATIC.
PRIVATE _aRotina 	:= aClone(aRotina) //na função Plsa360TOk do PLSA360 é utilizado o _aRotina
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

	PLS813PRDA(oModel, cCodRDA, nOper) //Direciona para a Tela de RDA

else
	
	//Se não foi gerada a RDA, pergunta se o usuário deseja prosseguir a geração, devido haver campos obrigatórios no
	//outro cadastro que não constam neste cadastro.
	If !lAutoma .And. MsgYesNo(STR0023 /*"Não há RDA criada para o Candidato, deseja prosseguir a geração? Posteriormente, serão necessários dados complementares"*/)
	
		PLS813SetV(oModel) //Realiza a gravação dos dados mínimos e envia aviso.
		
		oModel:GetModel("MasterB9Y"):SetValue("B9Y_CODRDA", PLS813VERI(oModel)) //Atribui o número da RDA gerado na BAU para o oModel, para podermos gravar ele na B9Y (Credenciamento).
		
		M->B9Y_CODRDA := oModel:GetModel("MasterB9Y"):GetValue("B9Y_CODRDA")
		
		cCodRDA := M->B9Y_CODRDA
		
		PLSA813VBAW(cCodRDA)	//Grava Operadoras a que a RDA está Vinculada
		
		For n9V := 1 To nTam9V //Varre a Grid de endereços
		
			oB9V:GoLine( n9V )
			
			PLS813RPTD(oModel) //Verifica se o Endereço já está cadastrado
			
			oB9Q	:= oModel:GetModel("B9QDetail")
			nTam9Q	:= oB9Q:Length() //Pega o tamanho da Grid de Especialidades Vinculada
		
			For n9Q := 1 To nTam9Q
			
				oB9Q:GoLine( n9Q )
				cCodEsp := oB9Q:GetValue("B9Q_CODESP") //Código Especialidade
				cCodLoc := oB9V:GetValue("B9V_CODSEQ") //Código Localidade
				
				PLS813VBBF(cCodEsp, cCodRDA) //Verifica e Grava Endereço, se inexistente

				PLS813VBAX(cCodEsp, cCodRDA, cCodLoc, cCodEsp) //Verifica e Grava as Especialidades do Endereço, se inexistente
				
			Next
		Next		
		Help(nil, nil , STR0025 , nil, STR0024, 1, 0, nil, nil, nil,nil,nil,{STR0026+" "+STR0027})//A partir da próxima vez que utilizar a opção'RDA', será direcionado diretamente ao cadastro de RDA do Candidato.",RDA Gerada com sucesso!"*	
	EndIf
EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS813VERI
Verifica se já existe uma RDA Cadastrada para o Candidato.
@author Oscar Zanin
@since 30/03/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS813VERI(oModel)

Local oB9Y 	:= oModel:GetModel("MasterB9Y")
Local cCPFCGC := oB9Y:GetValue("B9Y_CPFCGC")
Local cCodRDA := oB9Y:GetValue("B9Y_CODRDA")

If ( Vazio(cCodRDA) )
	
	BAU->(DbSelectArea("BAU"))
	BAU->(DbSetOrder(4))
	
	If ( BAU->(MsSeek(xFilial("BAU") + cCPFCGC)) ) //Verifica se o CPF/CNPJ já está cadastrado na BAU, se sim, vincula o credencimaneto à esta RDA
		
		cCodRDA := BAU->BAU_CODIGO
		oB9Y:SetValue('B9Y_CODRDA', cCodRDA)

	EndIf
	
	BAU->(DbCloseArea())
	
EndIf

Return (cCodRDA)
	
	
//-------------------------------------------------------------------
/*/{Protheus.doc} PLS813RPTD
Verifica se o endereço já está cadastrado e se já existem "homônimos" e realiza a 
gravação, caso seja um novo registro.
@author Oscar Zanin
@since 30/03/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS813RPTD(oModel)

Local oB9V		:= oModel:GetModel("B9VDetail")

Local cEnd		:= oB9V:GetValue("B9V_ENDER")
Local cLog		:= oB9V:GetValue("B9V_CODLOG")
Local cCid		:= oB9V:GetValue("B9V_CODCID")
Local cComple	:= oB9V:GetValue("B9V_COMEND")
Local cCodRDA	:= PLS813VERI(oModel)
Local cCodInt	:= PLSINTPAD()
Local cCodLoc	:= AllTrim(oB9V:GetValue("B9V_TIPLOC"))
Local cCEP		:= oB9V:GetValue("B9V_CEP")

Local lGrava	:= .T.

If ( !(Vazio(cCodRDA)) )

	BB8->(DbSelectArea("BB8"))
	BB8->(DbSetOrder(1))
	
	If ( BB8->(MsSeek( xFilial("BB8") + cCodRDA + cCodInt)) )
	
		While ((BB8->BB8_FILIAL == xFilial("BB8")) .AND. (BB8->BB8_CODIGO == cCodRDA) .AND. (BB8->BB8_CODINT == cCodInt) .AND. !BB8->(EoF()) )
	
			If ( BB8->BB8_CEP == cCEP ) .AND. (AllTrim(cCEP) <> "")
		
				lGrava := .F.
				
			EndIf
			
			If ( ( BB8->BB8_END == cEnd) .AND. ( BB8->BB8_TIPLOG == cLog ) .AND. (BB8->BB8_COMEND ==  cComple) .AND. ( BB8->BB8_CODMUN == cCid) ) .AND. lGrava
		
				lGrava := .F.
			
			EndIf
		
			If ((BB8->BB8_CODMUN == cCid)  .AND. PLS813omni(BB8->BB8_END, cEnd) .AND. lGrava)//Nesta parte ele verifica os parecidos
				
				If MsgYesNo(STR0028 /*"Foi detectada semelhança entre os endereços: "*/ + chr(13) + chr(13) + AllTrim(cEnd) + chr(13) + STR0029 /*" e "*/ + chr(13) + chr(13) + AllTrim(BB8->BB8_END) + chr(13) + STR0030 /*". Caso seja o mesmo endereço, escolha 'SIM', para que não seja gravado em duplicidade, caso não seja o mesmo endereço, escolha 'NÃO', para prosseguir a gravação."*/, STR0016/*"Atenção!"*/)
	
					lGrava := .F.
	
				EndIF	
			EndIf
			
		BB8->(DbSkip())
		EndDo
	EndIf
	
	If lGrava
				
		PLS813VBB8(cEnd, cCodRDA, cCodLoc, cCid, oModel)
			
	EndIF
	
	BB8->(DbCloseArea())
	
EndIf

Return (lGrava)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS813omni
Compara os endereços para achar "parecidos". A regra da função é:
- Retirar as "junções de nome" (de/da/do...)
- Retirar Acentuação e Espaços Extras no final e início da String (AllTrim)
- Gerar duas SubStrings para cada endereço, uma com os 7 primeiros caracteres e outra com os 7 últimos
- Utiliza a função para comparar "parecidos", retirando alguns caracteres pré-estabelecidos da cadeia.
- Realiza a comparação da SubString Inicial e Final.
@author Oscar Zanin
@since 07/04/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS813omni(cEndOne, cEndTwo)

Local lRet		:= .F.
Local cEsqE1	:= ""
Local cEsqE2	:= ""
Local cDirE1	:= ""
Local cDire2	:= ""
Local nPos		:= 0
Local cAux		:= ""
Local cNewEnd	:= ""
Local cEnd1 	:= AllTrim(cEndOne)
Local cEnd2 	:= AllTrim(cEndTwo)
Local nTEsq	:= 0
Local nTDir	:= 0

//Verifica a String para retirar as "junções", igual na função de verificação de homônimos
While (nPos := AT(" ", UPPER(cEnd1) +" ")) > 0 .and. !Empty(cEnd1)
	cAux   := Substr(UPPER(cEnd1), 1,nPos-1)
	cEnd1 := UPPER(substr(cEnd1,nPos+1,len(cEnd1)))
	If !Empty(cAux) .and. !UPPER(cAux) $ "DA/DE/DI/DO/DU/JR/I/II/III/DOS/DAS/E/."
		cNewEnd += cAux
	Endif
EndDo

cNewEnd := PLSNoAcento(cNewEnd)//Retira eventuais acentos

cEsqE1 := PLS813XPTO(Left(cNewEnd,7)) //
cDirE1 := PLS813XPTO(Right(cNewEnd,7))

cNewEnd := ""

While (nPos := AT(" ", UPPER(cEnd2) +" ")) > 0 .and. !Empty(cEnd2)
	cAux   := Substr(UPPER(cEnd2), 1,nPos-1)
	cEnd2 := UPPER(substr(cEnd2,nPos+1,len(cEnd2)))
	If !Empty(cAux) .and. !UPPER(cAux) $ "DA/DE/DI/DO/DU/JR/I/II/III/DOS/DAS/E/."
		cNewEnd += cAux
	Endif
EndDo

cNewEnd := PLSNoAcento(cNewEnd)

cEsqE2	:= PLS813XPTO(Left(cNewEnd,7))
cDire2	:= PLS813XPTO(Right(cNewEnd,7))

nTEsq := MIN(Len(cEsqE1), Len(cEsqE2))
nTDir := Min(Len(cDirE1), Len(cDirE2))	


If (Left(cEsqE1, nTesq) == Left(cEsqE2, nTEsq)) .AND. (Right(cDirE1, nTDir) == Right(cDirE2, nTDir))
	
	lRet := .T.

EndIF

Return (lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS813Mem2
Altera a variável de memória para que a Pós Validação da linha do Grid Funcione corretamente
@author Oscar Zanin
@since 01/04/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS813Mem2(oModel, oView)

Local oA		:= oModel:GetModel("B2EDetail")
Local lStat	:= oA:GetValue("B2E_STATUS")

M->B2E_STATUS := lStat

If lStat .AND. MsgYesNo(STR0031 /*"Confirma a finalização do passo?"*/, STR0032 /*"Finalizar Passo"*/)

	oA:SetValue("B2E_DATAFM", dDataBase)

Else
	
	oA:LoadValue("B2E_STATUS", .F.)
	oA:ClearField("B2E_DATAFM")
	
EndIf

oView:Refresh()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS813Weee
Validação de inclusão de linha
@author Oscar Zanin
@since 02/04/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS813Weee(oB2E)

Local lRet := .F.	
Local nTam := oB2E:Length()

If nTam == 1
	
	lRet := .T.

Else
	
	oB2E:GoLine(nTam - 1)
	lRet := oB2E:GetValue("B2E_STATUS")

EndIf

If !lRet
	
	MsgInfo(STR0033 /*"Foi inserido um passo sem a data fim do anterior, verifique o preenchimento"*/)

EndIF

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS813CanC
Verifica se o passo foi iniciado para permitir sua finalização
@author Oscar Zanin
@since 02/04/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS813CanC(oModel)

Local lRet		:= .F.
Local oB2E		:= oModel:GetModel("B2EDetail")
Local lStatus := oB2E:GetValue('B2E_STATUS')
Local cCodPas	:= IIf(ValType(oB2E:GetValue("B2E_CODPAS")) == "U", "", oB2E:GetValue("B2E_CODPAS"))

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
/*/{Protheus.doc} PLSA813SEQ
Prenche o Campo Sequencial da tabela selecionada
O índice DEVE ser iniciado por FILIAL + CODINT + CODSEQ
@author Oscar Zanin
@since 02/04/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA813SEQ(oModel, cAlias, cCampo, cSubMod, nIndice, nCont, cCodLoc, cCodEsp)

LOCAL oModelV		:= oModel:GetModel( cSubMod )
LOCAL cCodSeq		:= ""
Local nTam			:= oModelV:Length()
Local cCodInt		:= PLSINTPAD()
Local nI			:= 0
local nFor			:= 0
Local oB2F			:= oModel:GetModel("B2FDetail")
Local nADD			:= 1				//Esta função é feita especialmente para trabalhar com Grids esse nADD irá compensar o fato de não									//Termos dados gravados ainda, nem termos campos em memória
Default nCont 		:= 0				//Como iremos trabalhar com Grids, o parâmetro nCont irá compensar as diferenças em situações "MultiGrid"
											//para que a contegem siga sequencial mesmo trocando o registro pai selecionado
nADD := nCont + 1

//&cAlias->(DbSelectArea(&('"'+&cAlias+'"')))
//&cAlias->(DbSetOrder(nIndice)) 

DbSelectArea(cAlias)
(cAlias)->(DbSetOrder(nIndice)) 

For nI := 1 To nTam
	
	oModelV:GoLine(nI)		//Selecionamos o Registro da Grid
	
	//&(cAlias)->(MsSeek(xFilial(&cAliasA) + cCodInt)) //Posicionamos na tabela
	(cAlias)->(MsSeek(xFilial(cAlias) + cCodInt)) //Posicionamos na tabela
	
	If ( Vazio( oModelV:GetValue(cCampo) ) ) //Caso não haja um CODSEQ já preenchido...
	
		//Busca o último CODSEQ cadastrado
		//While(!&(cAlias)->(EOF()) .AND. &(cAlias)->(&(&(cAlias)+"_FILIAL")) == xFilial(&cAliasA) .AND. &(cAlias)->&(&(cAlias)+"_CODINT") == cCodInt)
		While(!(cAlias)->(EOF()) .AND. (cAlias)->((cAlias)+"_FILIAL") == xFilial(cAlias) .AND. (cAlias)->((cAlias)+"_CODINT") == cCodInt)
		
			//cCodSeq	:=	(cAlias)->&cCampo
			//&(cAlias)->(DbSkip())
			
			cCodSeq	:=	(cAlias)->cCampo
			(cAlias)->(DbSkip())
			
		EndDo

		//Incrementa e formata o resultado
		cCodSeq := StrZero(Val(cCodSeq) + nADD, Len(Space(TamSX3(cCampo)[1])))

		oModelV:SetValue(&('"'+cCampo+'"'), cCodSeq) //Atribui Valor ao Model
		
		nADD := nADD + 1 //Somamos 1 no nAdd para a próxima busca, pois não temos nada gravado no BD ainda
	EndIf
	
	//São grids e posso ter vários itens, devo percorrer e preencher todos, para a "integridade" ......
	oModelV:SetValue('B2E_CODIGO', oModel:getModel("MasterB9Y"):getValue("B9Y_CODIGO"))
	oModelV:SetValue('B2E_CODLOC', cCodLoc)
	oModelV:SetValue('B2E_CODESP', cCodEsp)

	for nFor := 1 to oB2F:Length()
		oB2F:GoLine(nFor)
		if ( empty(oB2F:getValue("B2F_DATAIN")) .and. empty(oB2F:getValue("B2F_DESCRI")) )
			oB2F:DeleteLine()
		endif
	next
Next

(cAlias)->(DbCloseArea())

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS813Whe1
Modo de edição da Grid de Passos de Credenciamento
@author Oscar Zanin
@since 06/04/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS813Whe1(oModel)

Local oB2E	:= oModel:GetModel('B2EDetail')
Local lStatus	:= oB2E:GetValue('B2E_STATUS')
Local lRet	:= .F.

If !lStatus
	
	lRet := .T.

EndIf

Return (lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS813PRDA
Envia para o cadastro de RDA, caso já possua um cadastro de RDA
@author Oscar Zanin
@since 06/04/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS813PRDA(oModel, cCodRDA, nOper)

Private nRecno	:= 9999999

BAU->(DbSelectArea("BAU"))
BAU->(DbSetOrder(1)) //Esta área deve permanecer aberta até o final da função, para que o sistema
						//não perca o registro quando chamarmos o cadastro de RDA em modo alteração.

IF BAU->(MsSeek(xFilial("BAU") + cCodRDA))

	nRecno := BAU->(Recno()) //Conseguimos o Recno do registro

EndIf

If nRecno <> 9999999 .AND. !INCLUI //Se Possui cadastro e a operação não é incluir
	
	PLSA360MNT("BAU",nRecno,4) //Chamada da Rotina de RDA, em modo alteração, para o registro que selecionamos

ElseIF nRecno == 9999999 .AND. INCLUI //Se Não Possui cadastro e a operação é incluir
	
	PLSA360MNT("BAU",nRecno,4) //Chamada da Rotina de RDA, em modo alteração, para o registro que selecionamos

ElseIf nRecno <> 9999999 .AND. INCLUI //Se Possui cadastro e a operação é incluir
	
	MsgInfo(STR0034 /*"Candidato já possui cadastro de RDA, não é possível incluir outro. Utilize a opção 'Analisar'"*/)

EndIf

BAU->(DbCloseArea())

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS813SetV
Preenche os dados mínimos possíveis do cadastro da RDA e envia o usuário 
para a tela, para complementar o cadastro. a RDA é gerada Bloqueada.
@author Oscar Zanin
@since 06/04/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS813SetV(oModel)

Local cCodigo := ""
Local oB9Y		:= oModel:GetModel('MasterB9Y')
Local cCPFCGC	:= oB9Y:GetValue('B9Y_CPFCGC')
Local cNome	:= oB9Y:GetValue('B9Y_NOME')
Local cCRM		:= oB9Y:GetValue('B9Y_CRMNUM')
Local cCRMEst	:= oB9Y:GetValue('B9Y_CRMEST')
Local cTipPes	:= ""
Local nReg
Local cCodRDA	:= ""
Local cAcao 		:= "4" 	//Motivo Administrativo
Local cCodCred	:= "904"	//Definir o Código de bloqueio de credenciamento ou usar o Administrativo
Local cTipo		:= '0' //0 = Bloqueio -> 1 = Desbloqueio
Local lBloq			:= .T.

If Len(AllTrim(cCPFCGC)) == 11
	
	cTipPes	:= "F"

ElseIf Len(Alltrim(cCPFCGC)) == 14		
	
	cTipPes	:= "J"

EndIf

BAU->(DbSelectArea("BAU"))

cCodigo := GETSX8Num("BAU","BAU_CODIGO")
BAU->(ConfirmSx8())

BEGIN TRANSACTION

	BAU->(RecLock("BAU", .T.))
	
		BAU->BAU_FILIAL	:= xFilial("BAU")
		BAU->BAU_CODIGO	:= cCodigo 
		If AllTrim(cTipPes) <> ""
			BAU->BAU_TIPPE	:= cTipPes
		EndIf
		BAU->BAU_DTINCL	:= Date()
		BAU->BAU_CPFCGC 	:= cCPFCGC
		BAU->BAU_NOME		:= cNome
		BAU->BAU_CONREG	:= cCRM
		BAU->BAU_ESTCR	:= cCRMEst
		BAU->BAU_CODBLO := cCodCred
		BAU->BAU_DATBLO := Date()
		BAU->BAU_AOINT  := "N"
		BAU->BAU_ACAO	  := cAcao
		
	BAU->(MsUnlock())
		
	oB9Y:SetValue('B9Y_CODRDA', BAU->BAU_CODIGO)

	cCodRDA	:= oB9Y:GetValue('B9Y_CODRDA')
	
	BC4->(DbSelectArea("BC4"))
	BC4->(DbSetFilter({ || BC4_CODCRE == cCodRDA}, "")) //Filtra a tabela pelo código da RDA

	If BC4->(MsSeek(xFilial("BC4") + cCodRDA)) //Verifica se há algum registro anterior
		
		lBloq := .F. //Se já está na tabela, não gera histórico de bloqueio do cadastro.. pq não é o cadastro..
	
	EndIf
	
	If lBloq //Grava o histórico do Bloqueio pelo Credenciamento
	
		BC4->(RecLock("BC4", .T.))

			BC4->BC4_FILIAL := xFilial("BC4")
			BC4->BC4_CODCRE := cCodRDA
			BC4->BC4_TIPO	  := cTipo
			BC4->BC4_DATA   := Date()
			BC4->BC4_HORA   := Left(Time(),2) + SubStr(Time(), 4, 2)
			BC4->BC4_OBS	  := STR0035 //"BLOQUEIO REFERENTE DEVIDO PROCESSO DE CREDENCIAMENTO"
			BC4->BC4_MOTBLO := cCodCred
			BC4->BC4_USUOPE := UsrFullName( RetCodUsr() )

		BC4->(MsUnlock())
	
	EndIf
	
	BC4->(DbCloseArea())

END TRANSACTION

nReg	:= BAU->(LastRec())

//cCodRDA	:= oB9Y:GetValue('B9Y_CODRDA')

BAU->(DbCloseArea())

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS813Menu
Cópia do MenuDef() do fonte PLSA360 (tela da RDA) isso está aqui para que a chamada
das telas deste cadastro que são feitas nesse fonte funcionem corretamente.
Devido à função MenuDef() ser STATIC, não é possível outra solução.
@author Oscar Zanin
@since 07/04/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS813Menu()

//Não há STR0s aqui devido esta rotina servir somente para inicializar o aRotina que
//é utilizado para chamar a rotina do PLSA360, no Botão RDA.
Private aRotina := {	{ "Pesquisar"		,'AxPesqui'		, 0 ,	1 	, 0, .F.},; //"Pesquisar"
						{ "Visualizar"	,'PLSA360MNT'		, 0 ,	2	, 0, Nil},; //"Visualizar"
						{ "Incluir"		,'PLSA360MNT'		, 0 ,	3  	, 0, Nil},; //"Incluir"
						{ "Alterar"		,'PLSA360MNT'		, 0 ,	4  	, 0, Nil},; //"Alterar"
						{ "Excluir"		,'PLSA360MNT'		, 0 ,	5  	, 0, Nil},; //"Excluir"
						{ "(Des)Bloquear"	,'PLSA360BLO'		, 0 ,	5  	, 0, Nil},; //"(Des)Bloquear"
						{ "Complemento"	,'PLSA365MNT'   	, 0 ,	3  	, 0, Nil},; //"Complemento"
						{ "Valor Producao"	,'PLSVALPAG'  , 0 ,	0  	, 0, Nil},; //"Valor Producao"
						{ "Legenda"			,'PLSA360LEG' , 0 ,	0  	, 0, .F.},; //"Legenda"
						{ "Vinculação RPS"	,'PLSA360RPS' , 0 ,	0  	, 0, Nil}}	  //"Vinculação RPS".

    	aadd(aRotina, {"Vinculo TISS" 			, "MsgRun('',,{||PLVINCTIS('BAU',BAU->BAU_CODIGO, 1)})", 0 ,1})
		aadd(aRotina, {"Excluir Vinculo TISS" 	, "MsgRun('',,{||PLVINCTIS('BAU',BAU->BAU_CODIGO, 0)})", 0 ,1})

Return(aRotina)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS813VCad
Permite o uso do Botão 'RDA' somente se o cadastro do candidato já estiver sido confirmado.
@author Oscar Zanin
@since 07/04/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS813VCad(oModel)

Local oB9Y		:= oModel:GetModel("MasterB9Y")
Local cCodPro	:= oB9Y:GetValue("B9Y_CODIGO")
Local lRet		:= .F.

B9Y->(DbSelectArea("B9Y"))
B9Y->(DbSetOrder(1))

If B9Y->(MsSeek(xFilial("B9Y") + PLSINTPAD() + cCodPro))
	
	lRet	:= .T.

EndIF

If lRet
	
	PLS813CRDA(oModel,.F.)

else
	
	MsgInfo(STR0036 /*"Antes de Criar a RDA, é necessário finalizar o cadastramento do Candidato!"*/)

EndIf

B9Y->(DbCloseArea())

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} P813Defere
Faz as verificações quando do deferimento do credenciamento de uma especialidade
@author Oscar Zanin
@since 07/04/2015
@version P12
/*/
//-------------------------------------------------------------------
Function P813Defere(oModel)

Local oB9Y		:= oModel:Getmodel("MasterB9Y")
Local oB9Q		:= oModel:GetModel("B9QDetail")
Local oB9V		:= oModel:GetModel("B9VDetail")

Local cCodLoc	:= ""
Local cCodEsp	:= ""
Local cCodRDA	:= oB9Y:GetValue("B9Y_CODRDA")

Local nTam9Q	:= oB9Q:Length()
Local n9Q		:= 0

Local nTam9V	:= oB9V:Length()
Local n9V		:= 0

Local lDeferiu := .F.

If !(Vazio(cCodRDA))
	
	//Preenche a BAW -> Operadoras da RDA
	PLSA813VBAW(cCodRDA)	
		
	For n9V := 1 To nTam9V //Varre as Localidades
		oB9V:GoLine( n9V )
	
		If oB9V:GetValue('B9V_DEFERE')
		
			PLS813RPTD(oModel) //Verifica Endereços iguais e semelhantes
		
			lDeferiu := .F.
		
			oB9Q	:= oModel:GetModel("B9QDetail")
			nTam9Q	:= oB9Q:Length() //Busca o tamanho da Grid de especialidades relacionada
		
			For n9Q := 1 To nTam9Q //Varre as Especialidades
				oB9Q:GoLine( n9Q )	
			
				If oB9Q:GetValue('B9Q_DEFERE')	
					
					If (AllTrim(cCodRDA) == "")

						PLS813KRDA(oModel)
						cCodRDA := oB9Y:GetValue("B9Y_CODRDA")

					EndIf
					
					cCodEsp := oB9Q:GetValue("B9Q_CODESP")
					cCodLoc := oB9V:GetValue("B9V_CODSEQ")
				
					PLS813VBBF(cCodEsp, cCodRDA) //Grava Localidade

					PLS813ZBAX(cCodEsp, cCodRDA, cCodLoc, cCodEsp) //Grava Especialidade
				
					lDeferiu := .T.
			
				EndIf
			Next
		EndIf
	Next
EndIf

If lDeferiu
	
	PLS813DBLOQ(cCodRDA)
	
	MsgInfo(STR0037 /*"Registros gravados no cadastro de RDA!"*/, STR0038 /*"Cadastro Atualizado!"*/)

EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS813VBBF
Realiza a gravação dos dados na BBF
@author Oscar Zanin
@since 07/04/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS813VBBF(cCodEsp, cCodRDA)

Local lExiste	:= .F.
Local cCodInt	:= PLSINTPAD()

BBF->(DbSelectArea("BBF"))
BBF->(DbSetOrder(1))

//Verifica se o registro que está sendo gravado já existe
If BBF->(MsSeek(xFilial("BBF") + cCodRDA + cCodInt + cCodEsp))
	
	lExiste	:= .T.
	
EndIf

//Caso não exista, grava o registro
If !lExiste
	
	BEGIN TRANSACTION
	
	BBF->(RecLock("BBF", .T.))
		
		BBF->BBF_FILIAL	:= xFilial("BBF")
		BBF->BBF_CODIGO	:= cCodRDA
		BBF->BBF_CODESP 	:= cCodInt + cCodEsp
		BBF->BBF_DATINC	:= dDataBase
		BBF->BBF_CODINT	:= cCodInt
		BBF->BBF_CDESP	:= cCodEsp
	
	BBF->(MsUnlock())
	
	END TRANSACTION

EndIf

BBF->(DbCloseArea())

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS813VBAX
Realiza a gravação dos dados na BAX
--Bloqueando as especialidades!
@author Oscar Zanin
@since 07/04/2015 -> 15/04/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS813VBAX(cCodEsp, cCodRDA, cCodLoc, cCodEsp)

Local lExiste	:= .F.
Local cCodInt	:= PLSINTPAD()

BAX->(DbSelectArea("BAX"))
BAX->(DbSetOrder(4))

//Verifica se já existe o registro gravado
If BAX->(MsSeek(xFilial("BAX") + cCodInt + cCodRDA + cCodLoc + cCodEsp))
	
	lExiste	:= .T.

EndIf

//Se não existe, realiza a gravação
If !lExiste
	
	BEGIN TRANSACTION
	
	BAX->(RecLock("BAX", .T.))
		
		BAX->BAX_FILIAL	:= xFilial("BAX")
		BAX->BAX_CODIGO	:= cCodRDA
		BAX->BAX_CODESP 	:= cCodEsp
		BAX->BAX_DATINC	:= dDataBase
		BAX->BAX_CODINT	:= cCodInt
		BAX->BAX_CODLOC	:= cCodLoc
		BAX->BAX_GUIMED	:= "0"
		BAX->BAX_VALCH	:= 0
		BAX->BAX_FORMUL	:= "1"
		BAX->BAX_LIMATM	:= "0"
		BAX->BAX_ORDPES	:= "1"
		BAX->BAX_ESPPRI	:= "0"
		BAX->BAX_BANDA	:= 0
		BAX->BAX_UCO		:= 0
		BAX->BAX_DATBLO	:= Date()
	
	BAX->(MsUnlock())
	
	END TRANSACTION

EndIf

BAX->(DbCloseArea())

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS813VBB8
Realiza a gravação dos dados na BB8
--Caso o Local não venha preenchido, será assumido o código 001
@author Oscar Zanin
@since 07/04/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS813VBB8(cEnd, cCodRDA, cCodLoc, cCid, oModel)

Local oB9V		:= oModel:GetModel('B9VDetail')

Local cCEP		:= oB9V:Getvalue('B9V_CEP')
Local cCodInt	:= PLSINTPAD()
Local cEst		:= Posicione("BID", 1, xFilial("BID")+cCid, "BID_EST")
Local cMun		:= Posicione("BID", 1, xFilial("BID")+cCid, "BID_DESCRI")
Local cLoc		:= Posicione("BD1", 1, xFilial("BD1")+cCodInt+cCodLoc, "BD1_DESLOC")
Local cSeqBB8	:= ""

If AllTrim(cCodLoc) == ""
	
	cCodLoc 	:= GetNewPar('MV_LOCPAD', '001')
	cLoc		:= Posicione("BD1", 1, xFilial("BD1")+cCodInt+cCodLoc, "BD1_DESLOC")
	
EndIF

BB8->(DbSelectArea("BB8"))
BB8->(DbSetOrder(1))

//Busca o último Sequencial da BB8
If (BB8->(MsSeek(xFilial("BB8")+cCodRDA+cCodInt)))
	
	While BB8->BB8_FILIAL == xFilial("BB8") .AND. BB8->BB8_CODIGO == cCodRDA .AND. BB8->BB8_CODINT == cCodInt .AND. !(BB8->(EoF()))
		
		cSeqBB8 := BB8->BB8_CODLOC
		BB8->(DbSkip())
	
	EndDo
EndIf

//Incrementa e formata
cSeqBB8 := StrZero(Val(cSeqBB8)+1, 3)

//Realiza a gravação	
BEGIN TRANSACTION

BB8->(RecLock("BB8", .T.))
	
	BB8->BB8_FILIAL	:= xFilial("BB8")
	BB8->BB8_CODINT	:= cCodInt
	BB8->BB8_CODIGO	:= cCodRDA
	BB8->BB8_CODLOC	:= cSeqBB8
	BB8->BB8_CEP		:= cCEP
	BB8->BB8_END		:= AllTrim(cEnd)
	BB8->BB8_LOCAL	:= cCodLoc
	BB8->BB8_DESLOC	:= cLoc
	BB8->BB8_CODMUN	:= cCid
	BB8->BB8_MUN		:= cMun
	BB8->BB8_EST		:= cEst

BB8->(MsUnlock())	

END TRANSACTION

BB8->(DbCloseArea())

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSNoAcento
Remove os acentos digitados, retornando a String em caracteres Maiúsculos sem acentos.
Estão sendo considerados os acentos "´", "`", "^", "~" e "¨".
@author Oscar Zanin
@since 07/04/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSNoAcento(cString)

Local nTam  := Len(cString)
Local nPos  := 0
Local cAux  := ""
Local cRetorno := ""
Local cStringU := AllTrim(UPPER(cString))

//Verifica caractere a caractere se há algum acentuado
//Ex: entrada = São José ; saída = SAO JOSE
For nPos := 1 To nTam
	
	cAux := SubStr(cStringU, nPos, 1)
	
	If cAux $ "Ã/Â/Ä/À/Á"
		cAux := "A"
	EndIf
	
	If cAux $ "Õ/Ô/Ó/Ò/Ö"
		cAux := "O"
	EndIf
	
	If cAux $ "É/È/Ê/Ë"
		cAux := "E"
	EndIF
	
	If cAux $ "Ú/Ù/Û/Ü"
		cAux := "U"
	EndIF
	
	If cAux $ "Í/Ì/Î/Ï"
		cAux := "I"
	EndIf
	
	If cAux $ "Ç"
		cAux := "C"
	EndIf
	
	If cAux $ "Ñ"
		cAux := "N"
	EndIf
	
	cRetorno += cAux

Next

Return (cRetorno)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS813XPTO
Faz a verificação de endereços semelhantes
@author Oscar Zanin
@since 07/04/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS813XPTO(cEnd)

Local nTam := Len(cEnd)
Local cRetorno := ""
Local nPos  := 0
Local cAux  := ""
Local cTrab := UPPER(AllTrim(cEnd))

//Verifica caractere a caractere se existe algum dos chars estabelecidos
//retornando uma string sem eles.Ex: entrada = Massayuki ; saída = Maaui
For nPos := 1 To nTam

	cAux := SubStr(cTrab, nPos, 1)
	
	IF !cAux $ "C/S/X/H/Z/K/W/V"
		cRetorno += cAux
	EndIF
Next

Return (cRetorno)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA813VBAW
Faz a gravação dos dados na tabela BAW
@author Oscar Zanin
@since 07/04/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA813VBAW(cCodRDA)

Local lExiste	:= .F.
Local cCodInt	:= PLSINTPAD()

BAW->(DbSelectArea("BAW"))
BAW->(DbSetOrder(1))

//Verifica se já existe na tabela
If BAW->(MsSeek(xFilial("BAW") + cCodRDA + cCodInt))
	
	lExiste	:= .T.
	
EndIf

//Realiza a gravação, caso não exista
If !lExiste
	
	BEGIN TRANSACTION
	
	BAW->(RecLock("BAW", .T.))
		
		BAW->BAW_FILIAL	:= xFilial("BAW")
		BAW->BAW_CODIGO	:= cCodRDA
		BAW->BAW_CODINT	:= cCodInt
	
	BAW->(MsUnlock())
	
	END TRANSACTION

EndIf

BAW->(DbCloseArea())

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS813MAIL
Envio de e-mail conforme o passo
@author Oscar Zanin
@since 08/04/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS813MAIL(oModel)

Local oB9Y			:= oModel:GetModel("MasterB9Y")
Local oB2E			:= oModel:GetModel("B2EDetail")
Local oB9V			:= oModel:Getmodel("B9VDetail")
Local oB9Q			:= oModel:GetModel("B9QDetail")

Local cCodPas		:= ""
Local cMailCan	:= oB9Y:GetValue("B9Y_EMAIL")
Local cCodInt		:= PLSINTPAD()
Local cCodMail	:= ""
Local cCC			:= ""
Local cCCo			:= ""
Local cMsg			:= ""

Local n2E			:= 0
Local n9V			:= 0
Local n9Q			:= 0
Local nTam2E		:= oB2E:Length()
Local nTam9V		:= oB9V:Length()
Local nTam9Q		:= oB9Q:Length()


B99->(DbSelectArea("B99"))
B99->(DbSetOrder(1))

For n9V	:= 1 To nTam9V
	oB9V:GoLine( n9V ) //Posiciona no registro do endereço
	
	oB9Q   := oModel:GetModel("B9QDetail") //Selecionamos as Especialidades referentes à Localidade
	nTam9Q	:= oB9Q:Length()					//E pegamos o tamanho do objeto para o próximo For
		
	For n9Q := 1 To nTam9Q
		oB9Q:GoLine( n9Q )	//Posiciona no Registro da Especialidade
		
		oB2E	:= oModel:GetModel("B2EDetail") //Selecionamos os Passos referentes à Especialidade
		nTam2E	:= oB2E:Length()					//E pegamos o tamanho do objeto para o próximo For
				
		For n2E := 1 To nTam2E
			oB2E:GoLine( n2E )
			
			If !(oB2E:GetValue('B2E_ENVIOU')) //Se não enviou e-mail ainda
			
				cCodPas	:= oB2E:GetValue("B2E_CODPAS") //Pegamos o Código do Passo para as verificações
			
			
				If B99->(MsSeek(xFilial("B99") + cCodInt + cCodPas))
					
					cCodMail := AllTrim(B99->B99_CODEMA) //Pegamos o Código de e-mail associado ao passo

					If !empty(cCodMail)	
						
						cMsg := STR0040 /*"O e-mail referente ao Passo "*/ + cCodPas + STR0041 //" Foi enviado com Sucesso!"

						PLSinaliza(cCodMail,cMsg,0,cMailCan,STR0039 /*"Status Credenciamento"*/,;
									oB2E, 'B2E_ENVIOU', .T., .F., "",;
									.F., "", .F., "000002", "",;
									.F.,"")
					Endif
				
				EndIf
				
			EndIf//If !(oB2E:GetValue('B2E_ENVIOU')) //Se não enviou e-mail ainda
			
			//Reinicializamos as Strings, para não reenviar o e-mail para destinatários indevidos
			//caso ele tenha mais passos com e-mail para verificar.
			cCC 	:= ""
			cCCO	:= ""

		Next
	Next
Next

B99->( DbCloseArea() )

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS813Vld2
Valida o CPF/CNPJ digitado
@author Oscar Zanin
@since 09/04/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS813Vld2(oModel)

Local oB9Y    := oModel:GetModel("MasterB9Y")
Local cCPFCGC := oB9Y:GetValue("B9Y_CPFCGC")
Local lRet		:= .F.

If CGC(cCPFCGC) .OR. Vazio(cCPFCGC)
	
	lRet := .T.

EndIf

Return (lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS813VldZ
Remove os acentos digitados e espaços à esquerda
@author Oscar Zanin
@since 09/04/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS813VldZ(oModel, cSubModel, cCampo)

Local oB9Y  := oModel:GetModel(cSubModel)
Local cNome := oB9Y:GetValue(cCampo)
Local lRet  := .T.

cNome := LTrim(cNome)
cNome := PLSNoAcento(cNome)

oB9Y:SetValue(cCampo, cNome)

Return (lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS813Vld1
Validar a data de nascimento, alertando se for igual ou superior à atual ou
se não houver, ao menos, 18 anos entre a data de nascimento e a data atual.
@author Oscar Zanin
@since 09/04/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS813Vld1(oModel)

Local oB9Y     := oModel:GetModel("MasterB9Y")
Local dDataNas := oB9Y:GetValue("B9Y_NASCTO")
Local dDataAtu := Date()
Local nDifTime := 0
Local lRet  := .T.

If dDataNas >= dDataAtu
	
	lRet := .F.
	MsgAlert(STR0042 /*"A data de nascimento informada é maior que a data atual!"*/)

EndIf

If lRet

	nDifTime := dDataAtu - dDataNas //a varável vai receber a diferença das datas em dias
	
	If nDifTime / 365 < 18 //convertendo pra anos e comparando...
		
		lRet := .F.
		MsgAlert(STR0043 /*"Verifique a data digitada, com esta data o Candidato teria menos de 18 anos de idade!"*/)
		
	EndIf
EndIf

Return (lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA813DISP
Análise de Disponibilidade, a partir do estudo de dimensionamento gerado na rotina de
Dimensionamento de Rede
@author Oscar Zanin
@since 13/04/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA813DISP(oModel)

Local oB9Y := oModel:Getmodel("MasterB9Y")
Local oB9V := oModel:Getmodel("B9VDetail")
Local oB9Q := oModel:GetModel("B9QDetail")
Local oB2E := oModel:GetModel("B2EDetail")
Local oB2F := oModel:GetModel("B2FDetail")

Local cCidade := oB9V:GetValue("B9V_CODCID")
Local cEspec  := oB9Q:GetValue("B9Q_CODESP")
Local cCodInt := PLSINTPAD()

Local nTam2E := oB2E:Length()
Local nTam2F := oB2F:Length()

Local cAno    := AllTrim(Str(Year(Date())))

B9S->(DbselectArea("B9S"))
//DbSetFilter({|| BAW_CODIGO = BAU->BAU_CODIGO},"")
//DbSetFilter( { || B9S_CODMUN = B9V->B9V_CODCID /*oB9V:GetValue('B9V_CODCID')*/ }, "")
B9S->(DbSetOrder(4)) //Índice criado para esta rotina

If B9S->(MsSeek(xFilial("B9S") + cCodInt + cEspec + cAno + cCidade))
	
	//Um está como NUMÉRICO e o Outro como TEXTO
	If B9S->B9S_MEDNEC < Val(B9S->B9S_MEDATU)
	
		If MsgYesNo(STR0044 /*"Conforme o último estudo de Dimensionamento de rede, está configurada a seguinte situação: "*/ + ;
				chr(13) + chr(13) +;
				STR0045 /*"Estudo de dimensionamento"*/ +;
				chr(13) +;
				STR0046 /*"Cidade: "*/ + B9S->B9S_CODMUN + chr(13) +;
				STR0047 /*" Especialidade: "*/ + B9S->B9S_ESPECI + chr(13) +;
				STR0048 /*" Quantidade de profissionais dimensionada: "*/ + Str(B9S->B9S_MEDNEC) + chr(13) +;
				STR0049 /*" Quantidade de profissionais cadastrada: "*/ + B9S->B9S_MEDATU +;
				chr(13) + chr(13) +;
				STR0050 /*"A candidatura do candidato NÃO se enquadra nas necessidades dimensionadas para a região. Gostaria de Indeferí-la?"*/,STR0051 /*"Análise do Dimensionamento"*/)
			
			oB9Y:SetValue('B9Y_STCRED', '4')
			oB2E:GoLine(nTam2E)
			
			If oB2E:GetValue('B2E_STATUS')
				oB2E:AddLine()

				oB2E:SetValue('B2E_CODPAS', GetNewPar('MV_MOTPAD'))
				oB2E:SetValue('B2E_DATAIN', Date())
				oB2E:SetValue('B2E_DESCRI', POSICIONE("B99",1,XFILIAL("B99")+PLSINTPAD()+GetNewPar('MV_MOTPAD'),"B99_DESCRI"))
				oB2F:GoLine(nTam2F)
				
				If Vazio(oB2F:GetValue('B2F_DESCRI'))
					oB2F:SetValue('B2F_DESCRI', STR0052 /*"Indeferimento automático devido incompatibildiade do candidato com o Estudo de Dimensionamento Atual"*/)
					oB2F:SetValue('B2F_DATAIN', Date())
				else
					oB2F:AddLine()
					oB2F:SetValue('B2F_DESCRI', STR0052 /*"Indeferimento automático devido incompatibildiade do candidato com o Estudo de Dimensionamento Atual"*/)
					oB2F:SetValue('B2F_DATAIN', Date())
				EndIf
				oB2E:SetValue('B2E_STATUS', .T.)
				oB2E:SetValue('B2E_DATAFM', Date())
				oB2E:SetValue( "B2E_USUARI", UsrFullName( RetCodUsr() ) )
			else
			
				oB2F:GoLine(nTam2F)
				If Vazio(oB2F:GetValue('B2F_DESCRI'))
					oB2F:SetValue('B2F_DESCRI', STR0052 /*"Indeferimento automático devido incompatibildiade do candidato com o Estudo de Dimensionamento Atual"*/)
					oB2F:SetValue('B2F_DATAIN', Date())
				else
					oB2F:AddLine()
					oB2F:SetValue('B2F_DESCRI', STR0052 /*"Indeferimento automático devido incompatibildiade do candidato com o Estudo de Dimensionamento Atual"*/)
					oB2F:SetValue('B2F_DATAIN', Date())
				EndIf
				
				oB2E:SetValue('B2E_STATUS', .T.)
				oB2E:SetValue('B2E_DATAFM', Date())
				
				oB2E:AddLine()

				oB2E:SetValue('B2E_CODPAS', GetNewPar('MV_MOTPAD'))
				oB2E:SetValue('B2E_DATAIN', Date())
				oB2E:SetValue('B2E_DESCRI', POSICIONE("B99",1,XFILIAL("B99")+PLSINTPAD()+GetNewPar('MV_MOTPAD'),"B99_DESCRI"))
				
				oB2F:GoLine(nTam2F)
				If Vazio(oB2F:GetValue('B2F_DESCRI'))
					oB2F:SetValue('B2F_DESCRI', STR0052 /*"Indeferimento automático devido incompatibildiade do candidato com o Estudo de Dimensionamento Atual"*/)
					oB2F:SetValue('B2F_DATAIN', Date())
				else
					oB2F:AddLine()
					oB2F:SetValue('B2F_DESCRI', STR0052 /*"Indeferimento automático devido incompatibildiade do candidato com o Estudo de Dimensionamento Atual"*/)
					oB2F:SetValue('B2F_DATAIN', Date())
				EndIf
				
				oB2E:SetValue('B2E_STATUS', .T.)
				oB2E:SetValue('B2E_DATAFM', Date())
				oB2E:SetValue( "B2E_USUARI", UsrFullName( RetCodUsr() ) )
			EndIf			
		EndIF	
	
	else
		
		MsgInfo(STR0063 /*"A Candidatura do prestador para a especialidade está dentro das necessidades apontadas no estudo de dimensionamento atual"*/)
	
	EndIF		

else
	
	MsgAlert(STR0053 /*"Não há estudo de dimensionamento para basear a rotina"*/, STR0016 /*"Atenção"*/)

EndIf	

B9S->(DbCloseArea())

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS813POCI
Alerta quando o Status escolhido for Credenciado, ou Indeferido
@author Oscar Zanin
@since 15/04/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS813POCI(oModel)

Local oB9Y  	:= oModel:Getmodel("MasterB9Y")
Local cStCred := oB9Y:GetValue('B9Y_STCRED')

If (cStCred = '3')
	
	MsgInfo(STR0054 /*"Ao inserir o passo de Credenciamento e finalizá-lo, não será mais possível alterar o registro!"*/, STR0016 /*"Atenção"*/)
	
EndIf	

If (cStCred = '4')
	
	MsgInfo(STR0055 /*"Ao inserir o passo de Indeferimento, o registro ficará bloqueado, mas poderá ser reativado com o passo correspondente"*/, STR0016 /*"Atenção"*/)
	
EndIf			

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS813ZBAX
Realiza a gravação dos dados na BAX
--Desbloqueando as Especialidades!
@author Oscar Zanin
@since 15/04/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS813ZBAX(cCodEsp, cCodRDA, cCodLoc, cCodEsp)

Local lExiste	:= .F.
Local cCodInt	:= PLSINTPAD()
Local nRecno 	:= 0

BAX->(DbSelectArea("BAX"))
BAX->(DbSetOrder(4))

//Verifica se já existe o registro gravado
If BAX->(MsSeek(xFilial("BAX") + cCodInt + cCodRDA + cCodLoc + cCodEsp))
	
	lExiste	:= .T.
	nRecno 	:= BAX->(Recno())
	
	BAX->(DbGoTo(nRecno))
	
	BAX->(RecLock("BAX", .F.))
		
		//Se o registro já existe, grava deletando a data de bloqueio
		BAX->BAX_FILIAL	:= xFilial("BAX")
		BAX->BAX_CODIGO	:= cCodRDA
		BAX->BAX_CODESP 	:= cCodEsp
		BAX->BAX_DATINC	:= dDataBase
		BAX->BAX_CODINT	:= cCodInt
		BAX->BAX_CODLOC	:= cCodLoc
		BAX->BAX_GUIMED	:= "0"
		BAX->BAX_VALCH	:= 0
		BAX->BAX_FORMUL	:= "1"
		BAX->BAX_LIMATM	:= "0"
		BAX->BAX_ORDPES	:= "1"
		BAX->BAX_ESPPRI	:= "0"
		BAX->BAX_BANDA	:= 0
		BAX->BAX_UCO		:= 0
		BAX->BAX_DATBLO	:= StoD("  /  /    ")

	BAX->(MsUnlock())		
	
EndIf

//Se não existe, realiza a gravação
If !lExiste
	
	BEGIN TRANSACTION
	
	BAX->(RecLock("BAX", .T.))
		
		BAX->BAX_FILIAL	:= xFilial("BAX")
		BAX->BAX_CODIGO	:= cCodRDA
		BAX->BAX_CODESP 	:= cCodEsp
		BAX->BAX_DATINC	:= dDataBase
		BAX->BAX_CODINT	:= cCodInt
		BAX->BAX_CODLOC	:= cCodLoc
		BAX->BAX_GUIMED	:= "0"
		BAX->BAX_VALCH	:= 0
		BAX->BAX_FORMUL	:= "1"
		BAX->BAX_LIMATM	:= "0"
		BAX->BAX_ORDPES	:= "1"
		BAX->BAX_ESPPRI	:= "0"
		BAX->BAX_BANDA	:= 0
		BAX->BAX_UCO		:= 0
	
	BAX->(MsUnlock())
	
	END TRANSACTION

EndIf

BAX->(DbCloseArea())

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS813AAAA
Preenche o campo de deferimento da especialidade e localidade, caso seja finalizado um passo de Credenciamento
@author Oscar Zanin
@since 16/04/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS813AAAA(oModel, oView)

Local oB2E := oModel:GetModel('B2EDetail')
Local oB9Q := oModel:GetModel('B9QDetail')
Local oB9V := oModel:GetModel('B9VDetail')

Local cCodInt := PLSINTPAD()

Local cPCred  := oB2E:GetValue('B2E_CODPAS')
Local cStLeg  := ""

Local lAprova := oB2E:GetValue("B2E_STATUS")

B99->(DbSelectArea("B99"))
B99->(DbSetOrder(1))

//Verificamos o Status relacionado ao passo
If B99->(MsSeek( xFilial("B99") + cCodInt + cPCred))
	
	cStLeg := B99->B99_STLEGP
	
EndIf

//Se o Status for 3 (Credenciamento) e o passo tiver sido concluído..
If cStLeg == '3' .AND. lAprova
	
	If !(oB9Q:GetValue("B9Q_DEFERE"))
	
		oB9Q:SetValue('B9Q_DEFERE', .T.) //Marcamos o deferimento da especialidade
	
	EndIf
	
	If !(oB9V:GetValue("B9V_DEFERE"))
	
		oB9V:SetValue('B9V_DEFERE', .T.) //Marcamos o deferimento da localidade
	
	EndIf

EndIf

B99->(DbCloseArea())

oView:Refresh()
	
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS813KRDA
Realiza a gravação de Tudo bloqueado, ao clicar no Ok, caso tenha algum deferimento.
@author Oscar Zanin
@since 16/04/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS813KRDA(oModel)

Local oB9V			:= oModel:GetModel("B9VDetail")
Local oB9Q			:= oModel:GetModel("B9QDetail")

Local cCodRDA		:= PLS813VERI(oModel)

Local n9V			:= 0
Local nTam9V		:= oB9V:Length()
Local n9Q			:= 0
Local nTam9Q		:= 0

If (empty(cCodRDA))

	PLS813SetV(oModel) //Realiza a gravação dos dados mínimos e envia aviso.
		
	oModel:GetModel("MasterB9Y"):SetValue("B9Y_CODRDA", PLS813VERI(oModel)) //Atribui o número da RDA gerado na BAU para o oModel, para podermos gravar ele na B9Y (Credenciamento).
		
	M->B9Y_CODRDA := oModel:GetModel("MasterB9Y"):GetValue("B9Y_CODRDA")

	cCodRDA := M->B9Y_CODRDA
	
	PLSA813VBAW(cCodRDA)	//Grava Operadoras a que a RDA está Vinculada
		
	For n9V := 1 To nTam9V //Varre a Grid de endereços
	
		oB9V:GoLine( n9V )
			
		PLS813RPTD(oModel) //Verifica se o Endereço já está cadastrado
			
		oB9Q	:= oModel:GetModel("B9QDetail")
		nTam9Q	:= oB9Q:Length() //Pega o tamanho da Grid de Especialidades Vinculada
	
		For n9Q := 1 To nTam9Q
	
			oB9Q:GoLine( n9Q )
			cCodEsp := oB9Q:GetValue("B9Q_CODESP")
			cCodLoc := oB9V:GetValue("B9V_CODSEQ")
				
			PLS813VBBF(cCodEsp, cCodRDA) //Verifica e Grava Endereço, se inexistente

			PLS813VBAX(cCodEsp, cCodRDA, cCodLoc, cCodEsp) //Verifica e Grava as Especialidades do Endereço, se inexistente

		Next
	Next
EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS813DBLOQ
Desbloqueia a RDA em caso de deferimento de QUALQUER especialidade
@author Oscar Zanin
@since 16/04/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS813DBLOQ(cCodRDA)

Local nRecno	:= 0
Local cCodCred	:= "904"	//Definir o Código de bloqueio de credenciamento ou usar o Administrativo
Local cTipo		:= '0' //0 = Bloqueio -> 1 = Desbloqueio
Local cLogUsr		:= Alltrim(B9Y->B9Y_LOGIN)
Local cNewPer		:= AllTrim(GetNewPar("MV_CDPRFD",""))

BAU->(DbSelectArea("BAU"))
BAU->(DbSetOrder(1))

If BAU->(MsSeek(xFilial("BAU") + cCodRDA)) //Verifica se a RDA está cadastrada
	
	nRecno := BAU->(Recno())
	
	BAU->(DbGoTo(nRecno)) //Posiciona

	BEGIN TRANSACTION 
	
	BAU->(REcLock("BAU", .F.)) //Grvamos o desbloqueio da RDA
		
		BAU->BAU_CODBLO := ""
		BAU->BAU_DATBLO := StoD("  /  /    ")
		BAU->BAU_AOINT  := ""
		BAU->BAU_ACAO	  := ""
	
	BAU->(MsUnlock())

	BC4->(DbSelectArea("BC4"))
	BC4->(DbSetFilter({ || BC4_CODCRE == cCodRDA}, ""))

	If BC4->(MsSeek(xFilial("BC4") + cCodRDA)) //Busca histórico
		
		While (BC4->BC4_FILIAL == xFilial("BC4") .AND. BC4->(!(EoF())))
		
			cTipo := BC4->BC4_TIPO
			BC4->(DbSkip())
	
		EndDo
	EndIF
	
	If (cTipo == '1') //Invertemos o Tipo (se estava bloqueado, vai desbloquear, e vice-versa)
	
		cTipo := '0'
	else
		cTipo := '1'
	EndIF
	
	BC4->(RecLock("BC4", .T.)) //Gravamos o histórico
		
		BC4->BC4_FILIAL := xFilial("BC4")
		BC4->BC4_CODCRE := cCodRDA
		BC4->BC4_TIPO	  := cTipo
		BC4->BC4_DATA   := Date()
		BC4->BC4_HORA   := Left(Time(),2) + SubStr(Time(), 4, 2)
		BC4->BC4_OBS	  := STR0056 //"DESBLOQUEIO DEVIDO DEFERIMENTO DE CREDENCIAMENTO"
		BC4->BC4_MOTBLO := cCodCred
		BC4->BC4_USUOPE := UsrFullName( RetCodUsr() )
		
	BC4->(MsUnlock())

	BC4->(DbCloseArea())

	//Altera oi perfil de acesso do prospect para o perfil de prestador
	If !(EmpTy(cLogUsr))

		BSW->(DbSelectArea("BSW"))
			BSW->(DbSetOrder(1))
			If BSW->(MsSeek(xFilial("BSW")+cLogUsr))
				BSW->(RecLock("BSW", .F.))
					
					BSW->BSW_PERACE := cNewPer
					
				BSW->(MsUnlock())
			EndIf
		BSW->(DbCloseArea())
		
	EndIF	

	END TRANSACTION

BAU->(DbCloseArea())

EndIf
return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS813ORDA
Abre a rotina de RDA filtrada pelo registro selecionado no Browse
@author Oscar Zanin
@since 16/04/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS813ORDA()

local cCampo := 'B9Y->B9Y_CODRDA'

//A ideia aqui é mostrar somente o registro da RDA do candidato selecionado, 
//no Browse do cadastro de RDA
BAU->(DbSetFilter({|| BAU_CODIGO == &cCampo},'BAU_CODIGO == '+cCampo))
PLSA360()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS813GCON
Envia para a Rotina de gerar contrato, com o númeroi da RDA já preenchido
@author Oscar Zanin
@since 22/04/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS813GCON(oModel)

Local oB9Y := oModel:Getmodel("MasterB9Y")
Local cRDA := oB9Y:GetValue("B9Y_CODRDA")
Local cCodInt := PLSINTPAD()
Local nRecno		:= 0
Local oExecView	

If Vazio(B9Y->B9Y_CODRDA)
	
	MsgAlert(STR0057 /*"É preciso realizar o cadastramento da RDA antes de gerar o contrato!"*/, STR0016 /*"Atenção"*/)
else
	
	B2G->(DbSelectArea("B2G"))
	B2G->(DbSetOrder(1))
	
	If B2G->(MsSeek(xFilial("B2G")+cCodInt+cRDA))	
	
		nRecno := B2G->(Recno()) //Se já existe, pegamos o Recno do registro
	else
		//É necessário Gravar o registro na B2G, caso não haja outro do prestador, pois
		//ele gera erro caso o formulário principal não seja alterado e a ideia da rotina
		//é entregar esse pedaço do cadastro já preenchido para o usuário.
		B2G->(RecLock("B2G", .T.))
			B2G->B2G_FILIAL	:= xFilial("B2G")
			B2G->B2G_CODINT	:= cCodInt
			B2G->B2G_RDA		:= cRDA
		B2G->(MsUnlock())
		nRecno := B2G->(Recno())
		
	EndIf
	
	B2G->(DbGoTo(nRecno)) //Movemos até o registro existente ou recém-criado
	
	//Esse bloco de comandos abre a tela do cadastro de Geração de contrato		
	oExecView := FWViewExec():New() 		//Criamos o objeto que abre a View
	oExecView:SetTitle(STR0058 /*'Gerar Contrato'*/) //Define título da Janela
	oExecView:SetSource('PLSA731') 			//Definimos o Model que iremos utilizar, no caso, o Model do fonte PLSA731
	oExecView:SetModal(.F.) 					//View não abre em janela Modal
	oExecView:SetCloseOnOk({|| .T.}) 		//A tela irá fechar ao confirmar o Ok
	oExecView:SetOperation(4) 				//Como sempre haverá um registro, o cadastro abre sempre como alteração
	oExecView:OpenView(.F.)				 	//Abrimos o cadastro

	B2G->(DbCloseArea())	
	
EndIF

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS813VDEL
Tratamento para deletar registros de especialiade, Passos e observações, caso algum seja incluído
e posteriormente excluído, para não gravar registros sem vínculos
@author Oscar Zanin
@since 23/04/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS813VDEL(oModel)

Local oB9V		:= oModel:GetModel( 'B9VDetail' ) //Endereço
Local oB9Q		:= oModel:GetModel( 'B9QDetail' ) //Especialidade
Local oB2E		:= oModel:GetModel( 'B2EDetail' )
Local oB2F		:= oModel:GetModel( 'B2FDetail' )
Local nI		:= 0
Local nJ		:= 0
Local nK		:= 0
Local nL		:= 0

//Verifica primeiro o passo, depois a especialidade e por último o endereço, pq se fosse na ordem
//inversa, ele iria passar por todos os FOR, se desse um positivo de endereço.

For nK := 1 To oB2E:Length() //Verifica quantas linhas tem o Model de Passos
	oB2E:GoLine(nK) //Vai para a primeira linha
	
	If oB2E:IsDeleted() //Se o passo foi excluído, deleta as observações vinculadas
	
		For nL := 1 To oB2F:Length() //Exclusão das observações referentes ao passo excluído
			oB2F:GoLine( nL )
			If oB2F:GetValue( 'B2F_CODPAS' ) == oB2E:GetValue( 'B2E_CODPAS' )
			oB2F:DeleteLine()
								
			EndIF//If B2F
		Next//For B2F
	EndIf //If B2E
Next//For B2E

For nJ := 1 To oB9Q:Length() //Verifica quantas linhas tem o Model de Especialidades
	oB9Q:GoLine( nJ ) //Vai para a primeira linha
	
	If oB9Q:IsDeleted() //Se a especialidade foi excluída, deleta os passos e observações vinculados
				
		For nK := 1 To oB2E:Length() //Exclusão dos passos correspondentes à especialidade excluída
			oB2E:GoLine(nK)
			If oB2E:GetValue( 'B2E_CODESP' ) == oB9Q:GetValue( 'B9Q_CODESP' )
				oB2E:DeleteLine()
						
				For nL := 1 To oB2F:Length() //Exclusão das observações referentes à especialidade excluída
					oB2F:GoLine( nL )
					If oB2F:GetValue( 'B2F_CODPAS' ) == oB2E:GetValue( 'B2E_CODPAS' )
						oB2F:DeleteLine()
								
					EndIF//If B2F
				Next//For B2F
			EndIf //If B2E
		Next//For B2E
	EndIf//If B9Q
Next//For B9Q

For nI := 1 To oB9V:Length() //Verifica quantas linhas tem o Model de Endereços
	oB9V:GoLine( nI ) //Vai para a primeira linha
	
	If oB9V:IsDeleted() //Se o endereço foi deletado, exclúi as especialidades, passos e observações vinculados
	
		For nJ := 1 To oB9Q:Length() //Exclusão das Especialidades sem endereço correspondente
			oB9Q:GoLine( nJ )
			If oB9Q:GetValue( 'B9Q_CODLOC' ) == oB9V:GetValue('B9V_CODSEQ')
				oB9Q:DeleteLine()
				
				For nK := 1 To oB2E:Length() //Exclusão dos passos correspondentes à especialidade excluída
					oB2E:GoLine(nK)
					If oB2E:GetValue( 'B2E_CODESP' ) == oB9Q:GetValue( 'B9Q_CODESP' )
						oB2E:DeleteLine()
						
						For nL := 1 To oB2F:Length() //Exclusão das observações referentes à especialidade excluída
							oB2F:GoLine( nL )
							If oB2F:GetValue( 'B2F_CODPAS' ) == oB2E:GetValue( 'B2E_CODPAS' )
								oB2F:DeleteLine()
								
							EndIF//If B2F
						Next//For B2F
					EndIf //If B2E
				Next//For B2E
			EndIf//If B9Q
		Next//For B9Q	
	EndIf//If B9V
Next//For B9V

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Vld813Del
Pré-validação das Grids para impedir a exclusão de registros já gravados. 
Registros incluídos e não salvos podem ser excluídos.
@author Oscar Zanin
@since 23/04/2015
@version P12
/*/
//-------------------------------------------------------------------
Function Vld813Del( oModelGrid, nLinha, cAcao, cCampo )
Local lRet   := .T.
Local oModel     := oModelGrid:GetModel()
Local nOperation := oModel:GetOperation()

// Valida se pode ou nao deletar uma linha do Grid
If cAcao == 'DELETE' .AND. nOperation == MODEL_OPERATION_UPDATE .AND. !(oModelGrid:IsInserted())
	lRet := .F.
	MsgAlert(STR0059 /*'Não é permitido apagar registros salvos anteriormente!'*/, STR0016/*'Atenção!'*/)
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} Vld813DlAl
Pré-validação das Grids para impedir a exclusão de registros já gravados. 
Registros incluídos e não salvos podem ser excluídos.
@author Oscar Zanin
@since 23/04/2015
@version P12
/*/
//-------------------------------------------------------------------
Function Vld813DlAl( oModelGrid, nLinha, cAcao, cCampo, oModelGeral )

Local lRet   		:= .T.
Local oModel		:= oModelGrid:GetModel()
Local oB2E			:= oModelGeral:Getmodel('B2EDetail')
Local lStatus		:= oB2E:Getvalue('B2E_STATUS')
Local cCodPas		:= oB2E:GetValue('B2E_CODPAS')
Local nOperation 	:= oModel:GetOperation()
Local dData		    := oModelGrid:GetValue('B2F_DATAIN')

If lStatus .and. !FWIsInCallStack('PLS813OK')
	lRet := .F.
	MsgAlert(STR0060 /*'Não é permitido editar o histórico de um passo concluído!'*/, STR0016/*'Atenção!'*/)
EndIf

If AllTrim(cCodPas) == ""
	lRet := .F.
	MsgAlert(STR0061 /*'Não é permitido adicionar um histórico sem informar o passo!'*/, STR0016/*Atenção!*/)
EndIF

If (cAcao == 'DELETE' .OR. cAcao == 'SETVALUE') .AND. nOperation == MODEL_OPERATION_UPDATE .AND. !(oModelGrid:IsInserted()) .AND. !Vazio(dDAta)
	lRet := .F.
	MsgAlert(STR0062 /*'Não é permitido Apagar ou Editar registros salvos anteriormente!'*/, STR0016/*'Atenção!'*/)
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSAB9V813
Tratamento para ajustar os campos a ser utilizados da tabela B9V.
@author Oscar Zanin
@since 23/04/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSAB9V813(cCampo)

Local lRet	:= .T.

	If cCampo == "B9V_EMAIL " //Não para o e-mail
		lRet := .F.
	EndIf
	
	If cCampo == "B9V_CONTAT" //Não para o contato
		lRet := .F.
	EndIf
	
	If cCampo == "B9V_CNES  " //Não para o CNES
		lRet := .F.
	EndIf
	
	If cCampo == "B9V_CODPRE" //Não para o Código do Prestador
		lRet := .F.
	EndIf

	If cCampo == "B9V_DESINT" //Não para a Descrição da operadora
		lRet := .F.
	EndIf				

	If cCampo == "B9V_SEQB9V" //Não para o Sequencial da tabela
		lRet := .F.
	EndIf
	
	If cCampo == "B9V_TEL   " //Não para o Telefone
		lRet := .F.
	EndIf
	
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} Plsa813Pic
Gera a máscara do CPF/CNPJ no preenchimento do campo.
@author Oscar Zanin
@since 24/04/2015
@version P12
/*/
//-------------------------------------------------------------------
Function Plsa813Pic()

Local cTipo   := ""
Local cCPFCGC := ""

cCPFCGC := AllTrim(M->B9Y_CPFCGC)

If Len(cCPFCGC) == 11 //Se 11 caracteres, formata para CPF
	cTipo := "F"
ElseIf Len(cCPFCGC) == 14 //Se 14 caracteres, formata para CNPJ
	cTipo := "J"
EndIf

Return PicPes(cTipo)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS813FTCP
Cria filtro da Consulta Padrão B9YB99
--Função descontinuada, o filtro não deve mais ocorrer com o chamado TVHXG9
@author Oscar Zanin
@since 07/05/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS813FTCP()

Local cCompara 	:= ""
Local lB99			:= .F.

If (select("B99") ==0)
	B99->(DbSelectArea("B99"))
	lB99 := .T.
EndIF

//Atribui o valor corrente do campo B9Y_STCRED. Campo em memória não funciona
//em todas as bases, por isso da variável STATIC e o filtro ser desse jeito.
If Empty(cStaLeg)
	cCompara := B9Y->B9Y_STCRED
Else
	cCompara := cStaLeg
EndIF                                                                                                                                                                                                                      

If lB99
	B99->(DbcloseArea())
EndIf

Return (cCompara)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS813CNCL
Ação no cancelar, limpa a variável static para o próximo uso. 
Dá RollBack no Sequencial.
@author Oscar Zanin
@since 08/05/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS813CNCL()

cStaLeg := ""

if INCLUI //Se cancelou na inclusão somente
	ROLLBACKSXE()
EndIf
	
Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS813SUBL
Definição da Legenda a ser apresentada (Browse inferior)
@author Oscar Zanin
@since 22/05/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS813SUBL()

Local cRet

cRet := B9Q_STCRED

Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS813IBRW
Definição inicializador padrão do browse
@author Oscar Zanin
@since 22/05/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS813IBRW()

Local cRet

If Vazio(B9Q->B9Q_CODESP)
		
	cRet := ''
Else
	
	cRet := POSICIONE("BAQ",7,XFILIAL("BAQ")+B9Q->B9Q_CODESP,"BAQ_DESCRI")
EndIf

Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PLS813VlPs
Definição inicializador padrão do browse
@author Oscar Zanin
@since 23/07/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS813VlPs(oModel)

Local lRet 	:= .F.
Local cCodPas	:= oModel:getModel("B2EDetail"):getValue("B2E_CODPAS")
Local cCodInt := PLSINTPAD()

B99->(DbSetOrder(1))
If B99->(MsSeek(xFilial("B99")+cCodInt+cCodPas))

	lRet := .T.

EndIf

return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} P813VerCRED
Verifica se quem está logando é um prestador que está em Credenciamento
Permitindo o mesmo logar com uma RDA bloqueada
@author Oscar Zanin
@since 11/03/2016
@version P12
/*/
//-------------------------------------------------------------------
Function P813VerCRED()
Local lRet 		:= .F.
Local aArea 		:= GetArea()
Local cPerfPad	:= AllTrim(GetNewPar("MV_CDPERF",""))
Local cLogin		:= BSW->BSW_LOGUSR

If !(EmpTy(cPerfPad))
	If AllTrim(BSW->BSW_PERACE) == cPerfPad
		
		B9Y->(DbsetOrder(5))
		If B9Y->(MsSeek(xFilial("B9Y")+AllTrim(cLogin)))
			
			IF B9Y->B9Y_STCRED <> "3" .AND. B9Y->B9Y_STCRED <> "4"
				lRet := .T.
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aArea)
Return lRet
