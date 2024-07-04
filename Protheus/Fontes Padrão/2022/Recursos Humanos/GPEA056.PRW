#include 'Protheus.ch'
#Include 'fwmvcdef.ch'
#include 'GPEA056.CH'
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ão    ³ GPEA056  ³ Autor ³ Emerson Campos                    ³ Data ³ 11/10/2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastro de Programação de Rateio (RHQ)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPEA056()                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³ FNC            ³  Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia Car.³15/05/2013³                ³ Subindo o fonte da versao 11 para 12 e fa- ³±±
±±³            ³          ³                ³ zendo limpeza.                             ³±±
±±³Sidney O.   ³08/07/2014³ TPZUWN         ³ Removido o campo Filial do formulario de   ³±±
±±³            ³          ³                ³ rateio.                                    ³±±
±±³Renan Borges³12/04/2016³TURTIA          ³Ajuste para mostrar codigo de classe valor  ³±±
±±³            ³          ³                ³corretamente quando MV_ITMCLVL igual a 3 e  ³±±
±±³            ³          ³                ³não possuir o Item no registro de "Progra-  ³±±
±±³            ³          ³                ³mação de Rateio".                           ³±±
±±³Esther V.   ³14/08/2017³DRHPAG-4948     ³ Adicionada opcao de programacao em Lote.   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GPEA056 (xAutoCab,xAutoItens,nOpcAuto)
Local cFiltraRh
Local oBrwSRA
Local xRetFilRh
Local cFil
Local cMat
Local oModelAuto
Local lRet			:= .T.

Private lGp056Auto  :=(xAutoCab<>NIl)
Private aAutoCab	:= {}
Private aAutoItens  := {}

If !lGp056Auto
	oBrwSRA := FWmBrowse():New()		
	oBrwSRA:SetAlias( 'SRA' )
	oBrwSRA:SetDescription(STR0006)	//"Programação de Rateio"
	
	oBrwSRA:AddLegend( "SRA->RA_SITFOLH==' '"	, "GREEN"	, OemToAnsi(STR0008)  )//"Situa‡„o Normal"
	oBrwSRA:AddLegend( "SRA->RA_RESCRAI$'30/31'", "PINK"  	, OemToAnsi(STR0009)  )//"Transferido 
	oBrwSRA:AddLegend( "SRA->RA_SITFOLH=='D'"	, "RED"		, OemToAnsi(STR0010)  )//"Demitido"
	oBrwSRA:AddLegend( "SRA->RA_SITFOLH=='A'"	, "YELLOW"  , OemToAnsi(STR0011)  )//"Afastado"
	oBrwSRA:AddLegend( "SRA->RA_SITFOLH=='F'"	, "BLUE"	, OemToAnsi(STR0012)  )//"F‚rias" 
						
	//Inicializa o filtro utilizando a funcao FilBrowse
	xRetFilRh := CHKRH(FunName(),"SRA","1")
	If ValType(xRetFilRh) == "L"
		cFiltraRh := if(xRetFilRh,".T.",".F.")
	Else
		cFiltraRh := xRetFilRh
	EndIf
	//Filtro padrao do Browse conforme tabela SRA (Funcionários)
	oBrwSRA:SetFilterDefault(cFiltraRh)
	
	oBrwSRA:DisableDetails()	
	oBrwSRA:Activate()
Else

	dbSelectArea("SRA")
	aAutoCab	:= xAutoCab
	aAutoItens 	:= xAutoItens
	
	If (nT := aScan(aAutoCab,{|x| UPPER(Alltrim(x[1]))=='RA_FILIAL'})) > 0
		cFil := aAutoCab[nT,2]
	Else
		cFil := xFilial("SRA")
	EndIf
	If (nT := aScan(aAutoCab,{|x| UPPER(Alltrim(x[1]))=='RA_MAT'})) > 0
		cMat := aAutoCab[nT,2]
	EndIf
	
	dbSelectArea('SRA')
	dbSetOrder(1)
	If !dbSeek(cFil+cMat)
		AutoGRLog(STR0013+" "+ Alias()+" "+Dtoc(MsDate())+' '+Time() ) // "Tabela "
		AutoGrLog("RA_FILIAL: "+cFil)
		AutoGrLog("RA_MAT: "+cMat)
		AutoGRLog(STR0014) // "Pesquisa nao encontrada com dados acima"
		AutoGRLog(Replicate("-",80))
		lRet := .F.
	EndIf

	If lRet
		aRotina := MenuDef()
		
		//Executa rotina automatica SEM Interface
		lRet := FWMVCRotAuto(ModelDef(),"SRA",nOpcAuto,{{"SRAMASTER",aAutoCab},{"RHQDETAIL",aAutoItens}},.F.,.T.)
	Endif
			
Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MenuDef     ³ Autor ³ Emerson               ³ Data ³ 11/10/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Menu Funcional                                                ³±±
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
	
	ADD OPTION aRotina Title STR0001  Action 'PesqBrw'         OPERATION 1 ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina Title STR0002  Action 'VIEWDEF.GPEA056' OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina Title STR0003  Action 'VIEWDEF.GPEA056' OPERATION 4 ACCESS 0 //"Manutenção"
	ADD OPTION aRotina Title STR0004  Action 'VIEWDEF.GPEA056' OPERATION 5 ACCESS 0 //"Excluir"
	If SX1->(DbSeek("GPEA056A"))
		ADD OPTION aRotina Title STR0015  Action 'VIEWDEF.GPEA056A' OPERATION 4 ACCESS 0 //"Rateio em Lote"
	EndIf
	
Return aRotina

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ModelDef    ³ Autor ³ Emerson               ³ Data ³ 11/10/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Modelo de dados e Regras de Preenchimento para o Cadastro de  ³±±
±±³          ³Programação de Rateio (RHQ)                                   ³±±
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

	//Define os campos do SRA que serão apresentados na tela	
	Local bAvalCampo 	:= {|cCampo| AllTrim(cCampo)+"|" $ "RA_MAT|RA_NOME|RA_ADMISSA|"}
	Local lItemClVl  	:= SuperGetMv( "MV_ITMCLVL", .F., "2" ) $ "1*3"
	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruSRA 		:= FWFormStruct(1, 'SRA', bAvalCampo,/*lViewUsado*/)
	Local oStruRHQ 		:= FWFormStruct(1, 'RHQ', /*bAvalCampo*/,/*lViewUsado*/)
	Local oMdlRHQ
	
	// Blocos de codigo do modelo
	Local bLinePos		:= {|oMdl| Gp056PosLine(oMdl)}
	Local bPosValid 	:= {|oMdl| Gp056PosVal(oMdl)}
	    
	// REMOVE CAMPOS DA ESTRUTURA
	oStruRHQ:RemoveField('RHQ_MAT')
	oStruRHQ:RemoveField('RHQ_FILIAL')
	 
	//Atribui 
	oStruRHQ:SetProperty( 'RHQ_ORIGEM'  , MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, "'S'" ) ) 
	
	// Cria o objeto do Modelo de Dados
	oMdlRHQ := MPFormModel():New('GPEA056', /*bPreValid*/ , bPosValid, /*bCommit*/, /*bCancel*/)
	
	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oMdlRHQ:AddFields('SRAMASTER', /*cOwner*/, oStruSRA, /*bFldPreVal*/, /*bFldPosVal*/, /*bCarga*/)
	
	// Adiciona ao modelo uma estrutura de formulário de edição por grid
	oMdlRHQ:AddGrid( 'RHQDETAIL', 'SRAMASTER', oStruRHQ, /*bLinePre*/, bLinePos, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
		
	// Faz relaciomaneto entre os compomentes do model
	oMdlRHQ:SetRelation('RHQDETAIL', {{'RHQ_FILIAL', 'xFilial("RHQ")'}, {'RHQ_MAT', 'RA_MAT'}}, RHQ->(IndexKey(1)))
	
	//Define Chave Única
	If lItemClVl
		oMdlRHQ:GetModel('RHQDETAIL'):SetUniqueLine({'RHQ_DEMES', 'RHQ_CC', 'RHQ_ITEM', 'RHQ_CLVL', 'RHQ_ORIGEM'})
	Else
		oMdlRHQ:GetModel('RHQDETAIL'):SetUniqueLine({'RHQ_DEMES', 'RHQ_CC', 'RHQ_ORIGEM'})
	EndIf
	
	//Permite grid sem dados
	oMdlRHQ:GetModel('RHQDETAIL'):SetOptional(.T.)
	
	oMdlRHQ:GetModel('SRAMASTER'):SetOnlyView(.T.)
	oMdlRHQ:GetModel('SRAMASTER'):SetOnlyQuery(.T.)
	//oMdlRHQ:SetOnlyQuery('SRAMASTER')
	
	// Adiciona a descricao do Modelo de Dados
	oMdlRHQ:SetDescription(OemToAnsi(STR0007))  // "Cadastro Programação de Rateio"
	
	// Adiciona a descricao do Componente do Modelo de Dados
	oMdlRHQ:GetModel('SRAMASTER'):SetDescription(OemToAnsi(STR0005)) // "Funcionários"
	oMdlRHQ:GetModel('RHQDETAIL'):SetDescription(OemToAnsi(STR0006)) // "Programação de Rateio"

Return oMdlRHQ
	
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ViewDef     ³ Autor ³ Emerson               ³ Data ³ 11/10/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Visualizador de dados do Cadastro de de Programação de Rateio³±±
±±³          ³ (RHQ)                                                        ³±±
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

	Local oView
	//Define os campos do SRA que serão apresentados na tela	
	Local bAvalCampo 	:= {|cCampo| AllTrim(cCampo)+"|" $ "RA_MAT|RA_NOME|RA_ADMISSA|"}
	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModel   := FWLoadModel('GPEA056')
	// Cria a estrutura a ser usada na View
	Local oStruSRA := FWFormStruct(2, 'SRA', bAvalCampo)
	Local oStruRHQ := FWFormStruct(2, 'RHQ')
	// Define se trabalha com item e classe contabil
	Local lItemClVl  := SuperGetMv( "MV_ITMCLVL", .F., "2" ) $ "1*3"
	
	// Cria o objeto de View
	oView := FWFormView():New()
	
	// Remove campos da estrutura e ajusta ordem dos campos na view
	//Remove
	oStruRHQ:RemoveField('RHQ_FILIAL')
	oStruRHQ:RemoveField('RHQ_MAT')
	//Ajusta
	oStruRHQ:SetProperty('RHQ_DEMES', MVC_VIEW_ORDEM,'01')
	oStruRHQ:SetProperty('RHQ_AMES' , MVC_VIEW_ORDEM,'02')
	oStruRHQ:SetProperty('RHQ_CC'   , MVC_VIEW_ORDEM,'03')
	If !lItemClVl
		//Remove
		oStruRHQ:RemoveField( 'RHQ_ITEM' )
		oStruRHQ:RemoveField( 'RHQ_CLVL' )
		//Ajusta		
		oStruRHQ:SetProperty('RHQ_PERC' , MVC_VIEW_ORDEM,'04')
	Else
		//Ajusta
	   	oStruRHQ:SetProperty('RHQ_ITEM' , MVC_VIEW_ORDEM,'04')
	   	oStruRHQ:SetProperty('RHQ_CLVL' , MVC_VIEW_ORDEM,'05')
		oStruRHQ:SetProperty('RHQ_PERC' , MVC_VIEW_ORDEM,'06')
	EndIf
	
	// Define qual o Modelo de dados será utilizado
	oView:SetModel(oModel)
	
	// Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField('VIEW_SRA', oStruSRA, 'SRAMASTER')
	
	oStruSRA:SetNoFolder()
	
	// Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
	oView:AddGrid('VIEW_RHQ', oStruRHQ, 'RHQDETAIL')
	
	// Adiciona um painel com os campos para filtrar as informações do grid
	oView:AddOtherObject("FILTRO", {|oPanel| AtuFiltro(oPanel, oView)})
	
	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox('SUPERIOR', 10)
	
	// Divide o box superior em dois
	oView:CreateVerticalBox('FUNCCPOS', 60, 'SUPERIOR')
	oView:CreateVerticalBox('FILTRO', 40, 'SUPERIOR')
	
	oView:CreateHorizontalBox('INFERIOR', 90)
	
	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView('VIEW_SRA', 'FUNCCPOS')
	oView:SetOwnerView('FILTRO', 'FILTRO')
	oView:SetOwnerView('VIEW_RHQ', 'INFERIOR')
	
	// Liga a identificacao do componente
	oView:EnableTitleView('VIEW_RHQ', OemToAnsi(STR0007)) // "Cadastro Programação de Rateio"
	
Return oView

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Gp056LinePos³ Autor ³ Emerson               ³ Data ³ 13/10/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao responsavel validação linha Cad Programação de Rateios³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Gp056LinePos( oMdlRHQ )                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oMdlRHQ = Objeto do modelo                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRetorno = .T. ou .F.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Gp056PosLine( oMdlRHQ )	
Local lRetorno		:= .T.
Local cAnoMesAux	:= ""	
Local cPerIniAux	:= ""
Local cPerFimAux	:= ""

/*******************************************************************
* Valida se a dataAte e menor que a dataDe                         *
*******************************************************************/ 
If ! valAteMenorDe( oMdlRHQ )
	Help("",1,"GP056DTAMAIORD") //"O Campo 'A Mês/Ano' deve estar vazio, igual ou maior que o campo 'De Mês/Ano'." "Corrija o campo 'A Mês/Ano'".
	lRetorno := .F.
EndIf

If SuperGetMv( "MV_ITMCLVL", .F., "2" ) == "1"
	If Empty(oMdlRHQ:GetValue('RHQ_ITEM')) .OR. Empty(oMdlRHQ:GetValue('RHQ_CLVL'))
		Help("",1,OemtoAnsi(STR0016),,OemtoAnsi(STR0017),1,0) //"Item /Classe de valor obrigatório"
		lRetorno := .F.
	EndIf
EndIf

If lRetorno .and. oMdlRHQ:isInserted()
	cAnoMesAux := oMdlRHQ:GetValue('RHQ_DEMES')
	cAnoMesAux := SubStr(cAnoMesAux, 3, 4) + SubStr(cAnoMesAux, 1, 2)
	cPerIniAux := SubStr(cPerIni, 3, 4) + SubStr(cPerIni, 1, 2)
	cPerFimAux := SubStr(cPerFim, 3, 4) + SubStr(cPerFim, 1, 2)
	//Se o período informado é superior ao filtro, verifica se existe registro gravado para não ocorrer chave duplicada
	If ( !Empty(cPerIniAux) .and. cAnoMesAux < cPerIniAux ) .or. cAnoMesAux > cPerFimAux
		If RHQ->(DbSeek(SRA->RA_FILIAL + SRA->RA_MAT + oMdlRHQ:GetValue('RHQ_DEMES') + oMdlRHQ:GetValue('RHQ_CC') + oMdlRHQ:GetValue('RHQ_ITEM') + oMdlRHQ:GetValue('RHQ_CLVL') + oMdlRHQ:GetValue('RHQ_ORIGEM')))
			Help("",1,"GP056DTCONFLIT")	//"A data informada no campo 'De Mês/Ano' é conflitante com um período previamente cadastrado."  "Revise os períodos."
			lRetorno := .F.
		EndIf
	EndIf
EndIf

Return lRetorno

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Gp056PosVal ³ Autor ³ Emerson               ³ Data ³ 13/10/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Pos-validacao do Cadastro de Rateio de Provisão              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Gp056PosVal( oMdlRHQ )                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oMdlRHQ = Objeto do modelo                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRetorno = .T. ou .F.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Gp056PosVal( oMdlRHQ )

	Local oModel := oMdlRHQ:GetModel('RHQDETAIL')	
	Local lRetorno
	    
	/*******************************************************************
	* Valida se todos os agrupamentos de Rateio totalizam 100% e se o  *
	* retorno deve ser verdadeiro para efetuar a validacao.            *
	*******************************************************************/
	lRetorno := valRatEConflPer(oModel)
	
Return lRetorno

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³valAteMenorDe³ Autor ³ Emerson              ³ Data ³ 13/10/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao responsavel pela validação da dataAte não ser menor   ³±± 
±±³Descri‡…o ³ que a dataDe 												³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ valAteMenorDe( oMdlRHQ )                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oMdlRHQ = Objeto do modelo                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRetorno = .T. ou .F.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function valAteMenorDe( oMdlRHQ )
Local lRetorno		:= .T.
Local nMesDe		:= 0
Local nAnoDe		:= 0
Local nMesAte		:= 0
Local nAnoAte		:= 0

nMesDe 	:= Val(Substr(oMdlRHQ:GetValue('RHQ_DEMES'),1,2))
nAnoDe 	:= Val(Substr(oMdlRHQ:GetValue('RHQ_DEMES'),3,4))

nMesAte	:= Val(Substr(oMdlRHQ:GetValue('RHQ_AMES'),1,2))
nAnoAte := Val(Substr(oMdlRHQ:GetValue('RHQ_AMES'),3,4))

If !Empty(oMdlRHQ:GetValue('RHQ_AMES'))	
	If nAnoAte < nAnoDe
		lRetorno := .F.
	ElseIf nAnoAte <= nAnoDe
		If nMesAte < nMesDe
			lRetorno := .F.
		EndIf
	EndIf
EndIf
Return lRetorno		

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³valPerAberto³ Autor ³ Emerson               ³ Data ³ 13/10/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao responsavel pela validação se o periodo inserido nao  ³±± 
±±³          ³ esta sendo atendido em outra condicao    					³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ valPerAberto( dChkDtDe, dChkDtAte, dDeAnoMes, dAteAnoMes )   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ dChkDtDe   = Data de a ser conferida                         ³±±
±±³          ³ dChkDtAte  = Data ate a ser conferida                        ³±±
±±³          ³ dDeAnoMes  = Data de que servira de parametro na conferencia ³±±
±±³          ³ dAteAnoMes = Data ate que servira de parametro na conferencia³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRetorno = .T. ou .F.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function valPerAberto( dChkDtDe, dChkDtAte, dDeAnoMes, dAteAnoMes )		
lRetorno := .T.

If Empty(dChkDtAte) .AND. Empty(dAteAnoMes)		
	Help("",1,"GP056DTCONFLIT")	//"A data informada no campo 'De Mês/Ano' é conflitante com um período previamente cadastrado."  "Revise os períodos."
	lRetorno := .F.
ElseIf !Empty(dChkDtAte) .AND. !Empty(dAteAnoMes)
	If ConflictDate( dChkDtDe, dChkDtAte, dDeAnoMes, dAteAnoMes )			
   			Help("",1,"GP056DTCONFLIT")	//"A data informada no campo 'De Mês/Ano' é conflitante com um período previamente cadastrado."  "Revise os períodos."
   			lRetorno := .F.
	EndIf
ElseIf Empty(dChkDtAte) .AND. !Empty(dAteAnoMes)
	If dChkDtDe <= dAteAnoMes	    	
   			Help("",1,"GP056DTCONFLIT")	//"A data informada no campo 'De Mês/Ano' é conflitante com um período previamente cadastrado."  "Revise os períodos."
   			lRetorno := .F.
	EndIf
EndIf
Return lRetorno 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³valDtRetro  ³ Autor ³ Emerson               ³ Data ³ 17/10/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao responsavel pela validação se a data é retroativa a   ³±± 
±±³          ³ data atual.                              					³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ valDtRetro( oMdlRHQ )                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oMdlRHQ = Objeto do modelo                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRetorno = .T. ou .F.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function valDtRetro( oMdlRHQ )
Local lRetorno 		:= .T.
Local dChkDtDe		:= StoD(Substr(oMdlRHQ:GetValue('RHQ_DEMES'),3,4)+Substr(oMdlRHQ:GetValue('RHQ_DEMES'),1,2)+"01")
Local cPer         := ""
Local cSem         := ""
Local cProc        := ""
Local cRot         := ""
Local dFolMes      := StoD("    /  /  ")

cProc 	:= SRA->RA_PROCES
cRot 	:= fGetCalcRot("1")
//Carrega o periodo atual de calculo (aberto)                  
fGetLastPer( @cPer,@cSem , cProc, cRot )
dFolMes := StoD(Substr(cPer,1,4)+Substr(cPer,5,2)+"01")
If dChkDtDe < dFolMes
   	Help("",1,"GP056DTDERETRO") //"A data informada no campo 'De Mês/Ano' é inferior a data atual." "Ajuste o campo 'De Mês/Ano".
   	lRetorno := .F.		
EndIf

Return lRetorno

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³valRatEConflPer³ Autor ³ Emerson            ³ Data ³ 13/10/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta o agrupamento dos rateios, valida se os mesmos totali- ³±±
±±³          ³ zam 100% e validam se os periodos sao confiltantes           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ valRatEConflPer( oModel )                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oMdlRHQ = Objeto do modelo                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRetorno = .T. ou .F.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function valRatEConflPer(oMdlRHQ)	
Local nL
Local nLinGrid
Local nLinArray
Local nAcum
Local nTotLin 		:= oMdlRHQ:GetQtdLine()
Local aAcum   		:= {}
Local lAchou		:= .F.
Local lRetorno		:= .T.

For nLinGrid := 1 to nTotLin
	// A linha da Grid nao pode estar deletada
	If !oMdlRHQ:IsDeleted(nLinGrid)			
		If Empty(aAcum)
			// Na primeira passada insere o valor do primeiro agrupamento
			AADD(aAcum	,{oMdlRHQ:GetValue('RHQ_DEMES', nLinGrid)+oMdlRHQ:GetValue('RHQ_AMES' , nLinGrid),;
			      		  oMdlRHQ:GetValue('RHQ_PERC' , nLinGrid),;
			      		  oMdlRHQ:GetValue('RHQ_DEMES', nLinGrid),;
			      		  oMdlRHQ:GetValue('RHQ_AMES' , nLinGrid)};
			    )
		Else	   		
	   	   	lAchou := .F.
	   	   	// Percorre o acumulado no Array para tentar encontrar se o agrupamento atual já existe	   	   		   		
	   		For nLinArray := 1 to Len(aAcum) 
		   		If aAcum[nLinArray][1] == oMdlRHQ:GetValue('RHQ_DEMES', nLinGrid)+oMdlRHQ:GetValue('RHQ_AMES' , nLinGrid)
		   			aAcum[nLinArray][2] := aAcum[nLinArray][2] + oMdlRHQ:GetValue('RHQ_PERC' , nLinGrid)
		   			lAchou := .T.
		   			Exit
		   		EndIf		   		
			Next
			//Se não foi localizado o agrupamento atual nos existentes, insere-se um novo agrupamento no final do array 
			If !lAchou
					AADD(aAcum	,{oMdlRHQ:GetValue('RHQ_DEMES', nLinGrid)+oMdlRHQ:GetValue('RHQ_AMES' , nLinGrid),;
			      		  		  oMdlRHQ:GetValue('RHQ_PERC' , nLinGrid),;
					      		  oMdlRHQ:GetValue('RHQ_DEMES', nLinGrid),;
					      		  oMdlRHQ:GetValue('RHQ_AMES' , nLinGrid)};
					    )
			EndIf
        EndIf
   EndIf
Next
	
nAcum := Len(aAcum)
For nLinArray := 1 to nAcum
	/*******************************************************************
	* Valida se a totalizacao dos agrupamentos de rateio estao em 100% *
	*******************************************************************/
	If aAcum[nLinArray][2] <> 100 .AND. lRetorno			
		Help("",1,"GP056CEMPORC") //A soma dos percentuais de rateio não totaliza 100%." "Ajuste os percentuais a fim de atingirem 100% do rateio.
		lRetorno := .F.
		Exit	
	EndIf
	
	/*******************************************************************
	* Valida se o periodo nao esta em conflito com outro ja cadastrado *
	*******************************************************************/
	If lRetorno
		For nL := 1 to nAcum
			If nLinArray <> nL
				If !valPerAberto(;
									StoD(Substr(aAcum[nL][3],3,4)+Substr(aAcum[nL][3],1,2)+"01"),;
									If(Empty(aAcum[nL][4]),Nil,StoD(Substr(aAcum[nL][4],3,4)+Substr(aAcum[nL][4],1,2)+"01")),;
									StoD(Substr(aAcum[nLinArray][3],3,4)+Substr(aAcum[nLinArray][3],1,2)+"01"),;
						   			If(Empty(aAcum[nLinArray][4]),Nil,StoD(Substr(aAcum[nLinArray][4],3,4)+Substr(aAcum[nLinArray][4],1,2)+"01"));
						   		 )
					lRetorno := .F.
					Exit
				EndIf	
			EndIf		
		Next
	EndIf
	/*******************************************************************
	* Ao Encontrar um erro sai das validacoes                          *
	*******************************************************************/
	If !lRetorno
		Exit
	EndIf	
Next
Return lRetorno 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Gp056Dt    ³ Autor ³ Emerson Campos      ³ Data ³ 14/10/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica o mes e ano digitado                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Gp056Dt()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRetorno = .T. ou .F.                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA056                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Gp056Dt()
Local cCampo	:= ReadVar()
Local cVar		:= &(cCampo)
Local nMes		:= 0
Local nAno		:= 0
Local lRetorno 	:= .T.
Local oModel  	:= FWModelActive()
Local oMdlRHQ

If !Empty(cVar)
	nMes := Val(Substr(cVar,1,2))
	nAno := Val(Substr(cVar,3,4))
	
	If nMes < 1 .OR. nMes > 12
		Help("",1,"Cs020Mes")			// Mes Invalido
		lRetorno := .F.
	EndIf	
	
	If nAno == 0 .AND. lRetorno
		Help("",1,"Cs020Ano")			// Ano Invalido
		lRetorno := .F.
	EndIf
EndIf

If lRetorno .and. cCampo == "M->RHQ_DEMES"
	If oModel:getID() == "GPEA056A"
		oMdlRHQ	:= oModel:GetModel('RHQLOTE')
	Else
		oMdlRHQ	:= oModel:GetModel('RHQDETAIL')
	EndIf
	If ! valDtRetro( oMdlRHQ )
		lRetorno := .F.
	EndIf
EndIf

Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ IntegDef    ³ Autor ³                    ³ Data ³ 28/03/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEA056                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function IntegDef( cXML, nTypeTrans, cTypeMessage, cVersao )

Local aRet := {}

aRet:= GPEI056 ( cXml, nTypeTrans, cTypeMessage, cVersao )

Return aRet


/*/{Protheus.doc} AtuFiltro
Cria a interface para filtrar o grid
@author cicero.pereira
@since 02/05/2018
@param oPanel, object, Painel criado na ViewDef onde será ancorado os componentes
@param oView, object, Objeto FWFormView
/*/
Static function AtuFiltro(oPanel, oView)
	
	Static cPerIni := Space(6)
	Static cPerFim := Space(6)
	
	FiltraGrid(oView, .T.)
	
	@ 0,0 GROUP TO 40,360 LABEL STR0018 OF oPanel PIXEL // "Filtro"
	
	@ 10,20 SAY STR0019 SIZE 40,10 PIXEL OF oPanel // "Mês/Ano de:"
	@ 20,20 MSGET cPerIni SIZE 40,10 PIXEL OF oPanel PICTURE "@R 99/9999"
	
	@ 10,80 SAY STR0020 SIZE 40,13 PIXEL OF oPanel // "Mês/Ano Até:"
	@ 20,80 MSGET cPerFim SIZE 40,10 PIXEL OF oPanel PICTURE "@R 99/9999"
	
	@ 20,140 Button STR0021 Size 40, 12 Message STR0021 Pixel Action FiltraGrid( oView, .F. ) of oPanel // "Atualizar Filtro"

Return

/*/{Protheus.doc} FiltraGrid
Atualiza o objeto do grid com o fltro informado, ou com o período atual da folha
@author cicero.pereira
@since 02/05/2018
@param oView, object, Objeto FWFormView
@param lPerAtu, logical, Se filtra pelo período atual da folha
/*/
Static Function FiltraGrid(oView, lPerAtu)
	
	Local cFiltro 	:= ""
	Local oModel  	:= FWModelActive()
	Local aPerAtual	:= {}
	Local cIni		:= Right(cPerIni, 4) + Left(cPerIni, 2) 
	Local cFim		:= Right(cPerFim, 4) + Left(cPerFim, 2)
	
	Default lPerAtu := .F.
	
	If lPerAtu
		// Filtra pelo período atual da folha
		If fGetPerAtual( @aPerAtual, xFilial("RCH", SRA->RA_FILIAL), SRA->RA_PROCES, fGetRotOrdinar())
			cIni := cFim := aPerAtual[1][1]
			cPerIni := cPerFim := Right(aPerAtual[1][1], 2) + Left(aPerAtual[1][1], 4)
		Else
			cIni := cPerIni := Space(6)
			cFim := cPerFim := Replicate("9", 6)
		EndIf
	EndIf
	
	cFiltro := "SELECT * FROM " + RetSQLName("RHQ") + " WHERE((SUBSTRING(RHQ_DEMES, 3, 4) || SUBSTRING(RHQ_DEMES, 1, 2) >= '" + cIni + "' AND SUBSTRING(RHQ_DEMES, 3, 4) || SUBSTRING(RHQ_DEMES, 1, 2) <= '" + cFim + "') OR "
	cFiltro += " (SUBSTRING(RHQ_AMES, 3, 4) || SUBSTRING(RHQ_AMES, 1, 2) >= '" + cIni + "' AND SUBSTRING(RHQ_AMES, 3, 4) || SUBSTRING(RHQ_AMES, 1, 2) <= '" + cFim + "') OR "
	cFiltro += " (SUBSTRING(RHQ_DEMES, 3, 4) || SUBSTRING(RHQ_DEMES, 1, 2) <= '" + cFim + "' AND SUBSTRING(RHQ_AMES, 3,4) || SUBSTRING(RHQ_AMES, 1,2) >= '" + cIni + "') OR "
	cFiltro += " (SUBSTRING(RHQ_DEMES, 3, 4) || SUBSTRING(RHQ_DEMES, 1, 2) <= '" + cIni + "' AND RHQ_AMES = '      '))"
	
	cFiltro := ChangeQuery(cFiltro)
	
	cFiltro := SubStr(cFiltro, At("(", cFiltro))
	cFiltro := SubStr(cFiltro, 0, RAt(")", cFiltro))
	
	oModel:DeActivate()
	oModel:GetModel("RHQDETAIL"):ClearData( .F., .F.) 
	oModel:GetModel('RHQDETAIL'):SetLoadFilter( {}, cFiltro)
	oModel:Activate()
	
	oView:Refresh()
	
Return
