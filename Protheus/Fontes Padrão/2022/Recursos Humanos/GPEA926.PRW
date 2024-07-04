#include 'Protheus.ch'
#Include 'fwmvcdef.ch'
#include 'GPEA926.CH'

Static cEFDAviso
Static cVersEnvio	:= ""
Static cVersGPE		:= ""
//Integração com o TAF
Static lIntTAF		:= ((SuperGetMv("MV_RHTAF",, .F.) == .T.) .AND. Val(SuperGetMv("MV_FASESOC",/*lHelp*/,' ')) >= 1 )
Static lMiddleware	:= If( cPaisLoc == 'BRA' .AND. Findfunction("fVerMW"), fVerMW(), .F. )
Static lRfzTpInsc	:= ChkFile("RFZ") .And. RFZ->(ColumnPos('RFZ_TPINSC')) > 0
Static cVerTaf		:= StrTran(StrTran(SuperGetMv("MV_TAFVLES",, "2.4"), "_", "."), "0", "", 1, 2)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ão    ³ GPEA926  ³ Autor ³ Emerson Campos                    ³ Data ³ 05/09/2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastro de Sucessão de Vínculos (RFZ)                  					³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GPEA926()                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data     ³ Chamado/FNC    ³  Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Raquel Hager³08/07/2014³TPZTOA	  	   ³Inclusao de fonte na versao 12(datat fonte  ³±±
±±³            ³          ³         	   ³versao 11 - 01/06/2014)					    ³±±
±±³Raquel Hager³05/09/2014³TQLPQN	  	   ³Correcao para validacao do grid - fGP926Edit³±±
±±³Sidney O.   ³19/09/2014³TQOHEZ	  	   ³Ajuste na validação do CNPJ                 ³±±
±±³            ³          ³                ³Ajuste na validação fTpAdmVld para receber  ³±±
±±³            ³          ³                ³um parametro de tipo de admissão            ³±±
±±³Christiane V³02/07/2015³ TSMUY2         ³Adaptações para versão 2.0 do eSocial       ³±±
±±³Raquel Hager³24/08/2016³TVTOQD          ³Remoção do uso do parâmetro MV_INTTAF para  ³±±
±±³            ³          ³                ³release 12.1.7.							       ³±±
±±³Marcia Moura³27/04/2017³DRHESOCP-38    ³Remoção do uso do parâmetro MV_INTTAF para   ³±±
±±³Cecilia C.  ³03/11/2017³DRHESOCP-1608  ³Inclusão de função Gp926When().              ³±±
±±³Cecilia C.  ³14/11/2017³DRHESOCP-1900    ³Ajuste para permitir manutenção da sucessão³±±
±±³            ³          ³                 ³de vínculo em funcionário ainda não integra³±±
±±³            ³          ³                 ³do com TAF.                                ³±±
±±³Cecília Carv³08/01/2018³DRHESOCP-2682   ³Ajuste para geração de contrato intermitente³±±
±±³            ³          ³                ³ - evento S-2200.                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function GPEA926 (xAutoCab,xAutoItens,nOpcAuto)
Local cFiltraRh
Local oBrwSRA
Local xRetFilRh
Local cFil
Local cMat
Local oModelAuto
Local lRet			:= .T.
Private cCpf		:= ""
Private cCateg		:= ""

Private lGp926Auto  :=(xAutoCab<>NIl)
Private aAutoCab	:= {}
Private aAutoItens  := {}
Private lNewVerEsoc := .F.

// RECEBE A VERSÃO DO TAF.
cVerTaf:= StrTran(Iif(cVerTaf == "2.4.01", "2.4", cVerTaf), "S.1", "9")
fVersEsoc("S1030", .F.,,, @cVersEnvio, @cVersGPE)
If lIntTaf .And. FindFunction("fVersEsoc") .And. FindFunction("ESocMsgVer")
	If !lMiddleware .And. cVersGPE <> cVersEnvio .And. (cVersGPE >= "9.0" .Or. cVersEnvio >= "9.0")
        //# "Atenção! # A versão do leiaute GPE é XXX e a do TAF é XXXX, sendo assim, estão divergentes. A rotina será encerrada"
		ESocMsgVer(.T.,/*cEvento*/, cVersGPE, cVersEnvio)
		Return ()
	EndIf
EndIf

cEFDAviso	:= If(cPaisLoc == 'BRA' .AND. Findfunction("fEFDAviso"), fEFDAviso(), "0")			//Se nao encontrar este parametro apenas emitira alertas

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Carregando Filtro de BROWSE                                  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
//--Seta e Carrega os Mnemonicos.
SetMnemonicos(NIL,NIL,.T.)
	
If !lGp926Auto
	oBrwSRA := FWmBrowse():New()		
	oBrwSRA:SetAlias( 'SRA' )
	oBrwSRA:SetDescription(STR0001)	//"Cadastro de Sucessão de Vínculos"
	
	oBrwSRA:AddLegend( "SRA->RA_SITFOLH==' '"	, "GREEN"	, OemToAnsi(STR0002)  )//"Situação Normal"  
	oBrwSRA:AddLegend( "SRA->RA_RESCRAI$'30/31'", "PINK"  	, OemToAnsi(STR0003)  )//"Transferido" 
	oBrwSRA:AddLegend( "SRA->RA_SITFOLH=='D'"	, "RED"		, OemToAnsi(STR0004)  )//"Demitido"
	oBrwSRA:AddLegend( "SRA->RA_SITFOLH=='A'"	, "YELLOW"  , OemToAnsi(STR0005)  )//"Afastado"
	oBrwSRA:AddLegend( "SRA->RA_SITFOLH=='F'"	, "BLUE"	, OemToAnsi(STR0006)  )//"Férias"     
						
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
		AutoGRLog(STR0007+" "+ Alias()+" "+Dtoc(MsDate())+' '+Time() ) // "Tabela "
		AutoGrLog("RA_FILIAL: "+cFil)
		AutoGrLog("RA_MAT: "+cMat)
		AutoGRLog(STR0008) // "Pesquisa não encontrada com os dados acima"   
		AutoGRLog(Replicate("-",80))
		lRet := .F.
	EndIf

	If lRet
		aRotina := MenuDef()
		
		//Executa rotina automatica SEM Interface
		lRet := FWMVCRotAuto(ModelDef(),"SRA",nOpcAuto,{{"SRAMASTER",aAutoCab},{"RFZDETAIL",aAutoItens}},.F.,.T.)
	Endif			
Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MenuDef    ³ Autor ³ Emerson Campos        ³ Data ³05/09/2013³±±
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

ADD OPTION aRotina Title STR0009  Action 'PesqBrw'         	OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina Title STR0010  Action 'VIEWDEF.GPEA926'  OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina Title STR0011  Action 'VIEWDEF.GPEA926' 	OPERATION 4 ACCESS 0 //"Alterar"
Return aRotina

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ModelDef    ³ Autor ³ Emerson Campos        ³ Data ³05/09/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Modelo de dados e Regras de Preenchimento para o Cadastro de  ³±±
±±³          ³Sucessão de Vínculos do Funcionario (RFZ)                     ³±±
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
Local bAvalCampo 	:= {|cCampo| AllTrim(cCampo)+"|" $ "|RA_MAT|RA_NOME|RA_ADMISSA|"}
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruSRA 		:= FWFormStruct(1, 'SRA', bAvalCampo,/*lViewUsado*/)
Local oStruRFZ 		:= FWFormStruct(1, 'RFZ', /*bAvalCampo*/,/*lViewUsado*/)
Local oMdlRFZ

// Blocos de codigo do modelo
Local bLinePos		:= {|| fGp926LinOk()}
Local bPosValid		:= {|| fGp926TdOk() }
Local bCommit		:= {|oMdlRFZ| f926Comm(oMdlRFZ)}
 
// Cria o objeto do Modelo de Dados
oMdlRFZ := MPFormModel():New('GPEA926', /*bPreValid*/ , bPosValid, bCommit, /*bCancel*/)

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oMdlRFZ:AddFields('SRAMASTER', /*cOwner*/, oStruSRA, /*bFldPreVal*/, /*bFldPosVal*/, /*bCarga*/)

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oMdlRFZ:AddGrid( 'RFZDETAIL', 'SRAMASTER', oStruRFZ, /*bLinePre*/, bLinePos, /*bPreVal*/, /*bPosVal*/, /*bLoad*/ )
	
// Faz relaciomaneto entre os compomentes do model
oMdlRFZ:SetRelation('RFZDETAIL', {{'RFZ_FILIAL', 'xFilial("RFZ")'}, {'RFZ_MAT', 'RA_MAT'}}, RFZ->(IndexKey(1)))

//Define Chave Única
oMdlRFZ:GetModel('RFZDETAIL'):SetUniqueLine({'RFZ_MAT', 'RFZ_TPADM'})

//Permite grid sem dados
oMdlRFZ:GetModel('RFZDETAIL'):SetOptional(.T.)

oMdlRFZ:GetModel('SRAMASTER'):SetOnlyView(.T.)
oMdlRFZ:GetModel('SRAMASTER'):SetOnlyQuery(.T.)


// Adiciona a descricao do Modelo de Dados
oMdlRFZ:SetDescription(OemToAnsi(STR0001))  // "Cadastro de Sucessão de Vínculos"

// Adiciona a descricao do Componente do Modelo de Dados
oMdlRFZ:GetModel('SRAMASTER'):SetDescription(OemToAnsi(STR0013)) // "Funcionários"
oMdlRFZ:GetModel('RFZDETAIL'):SetDescription(OemToAnsi(STR0014)) // "Sucessão de Vínculos"

//Não permitir serem inseridas linhas na grid.
//oMdlRFZ:GetModel( 'RFZDETAIL' ):SetNoInsertLine( .T. )

Return oMdlRFZ	
	
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ViewDef     ³ Autor ³ Emerson Campos        ³ Data ³ 21/06/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Visualizador de dados do Cadastro de Sucessão de Vínculos do ³±±
±±³          ³ Funcionario (RFZ)                                            ³±±
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
Local bAvalCampo 	:= {|cCampo| AllTrim(cCampo)+"|" $ "|RA_MAT|RA_NOME|RA_ADMISSA"}
//Define os campos do RFZ que não serão apresentados na tela	
Local bAvalRFZ 	:= Nil
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel('GPEA926')
// Cria a estrutura a ser usada na View
Local oStruSRA := FWFormStruct(2, 'SRA', bAvalCampo)
Local oStruRFZ := Nil

If ( ExistFunc( 'fVersEsoc' ), fVersEsoc( "S2200", .F.,,,@cVersEnvio, @cVersGPE),)

If Empty(cVersGPE)
	cVersGPE := cVersEnvio
EndIf

If (cVersEnvio <= "2.5")
	bAvalRFZ := {|cCampo| !AllTrim(cCampo)+"|" $ "RFZ_PRCAD|"}
	oStruRFZ := FWFormStruct(2, 'RFZ', bAvalRFZ)
Else
	oStruRFZ := FWFormStruct(2, 'RFZ')
Endif

// Cria o objeto de View
oView := FWFormView():New()
 
// Define qual o Modelo de dados será utilizado
oView:SetModel(oModel)

// Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('VIEW_SRA', oStruSRA, 'SRAMASTER')

oStruSRA:SetNoFolder()

// Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid('VIEW_RFZ', oStruRFZ, 'RFZDETAIL')

oStruRFZ:RemoveField("RFZ_MAT")
If lRfzTpInsc
	oStruRFZ:SetProperty("RFZ_TPINSC", MVC_VIEW_ORDEM, "06")
EndIf
 
// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox('SUPERIOR', 12)
oView:CreateHorizontalBox('INFERIOR', 88)

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView('VIEW_SRA', 'SUPERIOR')
oView:SetOwnerView('VIEW_RFZ', 'INFERIOR')

// Liga a identificacao do componente
oView:EnableTitleView('VIEW_SRA', OemToAnsi(STR0013)) // "Funcionário"
oView:EnableTitleView('VIEW_RFZ', OemToAnsi(STR0014)) // "Sucessão de Vínculos"

// Desabilita botao 'Salvar e Criar'
oView:SetCloseOnOk({ || .T. }) 

cCPF	:= cCPF := AllTrim(SRA->RA_CIC) + ";" + AllTrim(SRA->RA_MAT)
cCateg	:= SRA->RA_CATEFD
Return oView

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fGp926LinOk ³ Autor ³ Emerson Campos        ³ Data ³05/09/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Pos-validacao da linha do Cadastro de Sucessão de Vínculos   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fGp926LinOk( )                                      			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oMdlRFZ = Objeto do modelo                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRetorno = .T. ou .F.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function fGp926LinOk()
Local lRet   	:= .T. 
Local oModel    := FWModelActive()
Local oMdlRFZ 	:= oModel:GetModel( 'RFZDETAIL' )
Local NRFZLines	:= oMdlRFZ:Length()
Local nI         := 0
Local nDttraPOS  := 0

Private	aHeader	:= oMdlRFZ:AHEADER
nDttraPOS := GdFieldPos("RFZ_DTTRA")

If cEFDAviso <> "2"	
	For nI := 1 To nRFZLines	
		oMdlRFZ:GoLine( nI )		
		If !(oMdlRFZ:IsDeleted())
		    lRet := fTpAdmVld(oMdlRFZ:GetValue( 'RFZ_TPADM' )) //"O campo 'Tp.Admissão' é de preenchimento obrigatório!"
		    
		    If Empty(oMdlRFZ:GetValue( 'RFZ_INDADM' ))
		    	Help( , , 'HELP', , OemToAnsi( STR0030 +" "+ STR0032 +" "+ STR0031 ), 1, 0 )//"O campo 'Indic.Admiss' é de preenchimento obrigatório!"
				If cEFDAviso == "1"
					lRet := .F.
				EndIf
		    EndIf
		    
		    If Empty(oMdlRFZ:GetValue( 'RFZ_INDPEM' ))    	
		    	Help( , , 'HELP', , OemToAnsi( STR0030 +" "+ STR0033 +" "+ STR0031 ), 1, 0 )//"O campo 'Ind.Prim.Emp' é de preenchimento obrigatório!"
				If cEFDAviso == "1"
					lRet := .F.
				EndIf
		    EndIf 
		    
			If lRet
				IF ( lRet := SM0->( dbSeek( cEmpAnt + SRA->RA_FILIAL ) ) )
					If oMdlRFZ:GetValue( 'RFZ_TPADM' ) $ "2*3*4"
						 
						If SM0->M0_CGC == oMdlRFZ:GetValue( 'RFZ_CNPJAN' )
							Help( , , 'HELP', , OemToAnsi(STR0017), 1, 0 )//"O CNPJ informado deve ser diferente do CNPJ da filial de cadastro do participante."
							//-- Se tornar impeditivo o prosseguimento devido a presenca de inconsistencias
							If cEFDAviso == "1"
								lRet	:= .F.
							EndIf
						EndIf
						If lRet .AND. oMdlRFZ:GetValue( 'RFZ_CNPJAN' ) == "00000000000000"
							Help( , , 'HELP', , OemToAnsi(STR0036), 1, 0 )//"O CNPJ informado não é válido!"//-- Se tornar impeditivo o prosseguimento devido a presenca de inconsistencias
							If cEFDAviso == "1"
								lRet	:= .F.
							EndIf
						EndIf		
						If lRet
							//Valida se o CNPJ é válido
							lRet	:= CGC( oMdlRFZ:GetValue( 'RFZ_CNPJAN' ) )
							If cEFDAviso == "0" .AND. !lRet
								lRet	:= .T.	
							EndIf
						EndIf
					EndIf  	
				EndIf
			EndIf
		
		
			If oMdlRFZ:GetValue( 'RFZ_TPADM' ) $ "1*2*3*4"
				If oMdlRFZ:GetValue( 'RFZ_TPADM', nI ) <> "1" 			
					If Empty(oMdlRFZ:GetValue( 'RFZ_CNPJAN' )) .OR.;
						Empty(oMdlRFZ:GetValue( 'RFZ_MATANT' )) .OR.;
						Empty(oMdlRFZ:GetValue( 'RFZ_DTADAN' ))
					   	//"Se for selecionado as opções 2 ou 3 em Tp.Admissão, os campos 'CNPJ Empresa', 'Mat. Anterior' e 'Dt.Admissão' são de preenchimento obrigatório!"  	 
						Help( , , 'HELP', , OemToAnsi( STR0041 ), 1, 0 )  
						lRet := .F.
					EndIf
				EndIf
			EndIf

			If lRet .And. RFZ->(ColumnPos("RFZ_PRCAD")) > 0 .And. !Empty(oMdlRFZ:GetValue('RFZ_PRCAD')) .And. oMdlRFZ:GetValue('RFZ_INDADM') <> "3"
				Help(,, 'PRCAD',, + CRLF + OemToAnsi(STR0049) + AllTrim(TITSX3("RFZ_PRCAD")[1]) + OemToAnsi(STR0050) + AllTrim(TITSX3("RFZ_INDADM")[1]) + OemToAnsi(STR0051), 1, 0 ) // "Campo: "##" só deve ser preenchido quando "##" for igual a 3."
				lRet := .F.
			EndIf

			If nDttraPOS > 0 .And. cVersGPE >= "2.4"
				If oMdlRFZ:GetValue( 'RFZ_TPADM' ) <> "1"
					If Empty(oMdlRFZ:GetValue( 'RFZ_DTTRA' ))
						Help( ' ' , 1 , "HELP" , , OemToAnsi(STR0044) , 1 , 0 )
						lRet:= .F.
					EndIf
				EndIf				
			EndIf
			
		EndIf
	Next nI
EndIf
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fGp926TdOk  ³ Autor ³ Emerson Campos        ³ Data ³05/09/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Pos-validacao do modelo relativo ao Cad Sucessão de Vínculos ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ fGp926TdOk( )                             			        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oMdlRFZ = Objeto do modelo                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRetorno = .T. ou .F.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function fGp926TdOk()
Return fGp926LinOk()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³fTpDepBox() ³ Autor ³ Emerson Campos        ³ Data ³ 30/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Tipo de dependente                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³fTpDepBox()		                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function fTpAdmBox()
Local cTitulo           := OemToAnsi(STR0021) // "Tp.Admissão" 
Local MvPar             := &(ReadVar())
Local MvParDef          := "" 
Local MvStrRet          := ""
Local lRet              := .T. 
Local l1Elem            := .F.  
Local nGrupo            := 0
Local aArea             := GetArea()

Private aOcor := {}

VAR_IXB := MvPar

aOcor := {;			
			OemToAnsi(STR0022),;		//"1=Admissão;" 
			OemToAnsi(STR0023),;		//"2=Transferência de empresa do mesmo grupo econômico;" 
			OemToAnsi(STR0039),;		//"3=Transferência da empresa consorciada ou de consórcio"
			OemToAnsi(STR0040),;		//"4=Transferência por motivo de sucessão, incorporação, cisão ou fusão"
			OemToAnsi(STR0058) ;		//"7=Transferência quando a empresa sucedida é considerada inapta por inexistência de fato" 
	          } 

MvParDef := "12347"
	
If f_Opcoes(@MvPar,cTitulo,aOcor,MvParDef,,,l1Elem,1)
      For nGrupo := 1 To Len(MvPar)
            If (SubStr(MvPar, nGrupo, 1) # "*")
                  MvStrRet += SubStr(mvpar, nGrupo, 1)
            Else
                  MvStrRet += Space(1)
            Endif
      Next nGrupo
      VAR_IXB := AllTrim(MvStrRet)
EndIf

RestArea(aArea)
Return(lRet) 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fTpAdmVld()   ³ Autor ³ Emerson Campos   ³ Data ³05/09/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao de validacao do campo RFZ_TPADM (Tp. Admissão       ³±±
±±³Descricao ³ Trabalhador)                                     	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Geral                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Function fTpAdmVld(cTpAdm)
Local lRet 		:= .T. 
Local oModel    := FWModelActive()
Local oMdlRFZ 	:= oModel:GetModel( 'RFZDETAIL' )

Default cTpAdm := M->RFZ_TPADM

If !cTpAdm $ "1*2*3*4*7"
	Help( , , 'HELP', , OemToAnsi(STR0026), 1, 0 )//"Selecione um tipo de admissão válido!" 
	lRet := .F.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao   ³fGP926CNPJ ºAutor  ³Emerson Campos      º Data ³  05/09/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.    ³ Verifica se o campo CNPJ é um CNPJ válido no território     º±±
±±º         ³nacional e deverá ser diferente do CNPJ do cendente, ou seja,º±±
±±º         ³da filial a qual o funcionário está associado.               º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³ GPEA926                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fGP926CNPJ()
Local lRet	    := .T.
Local lInsc	    := .F.
Local aArea	 	:= GetArea()
Local aAreaSM0 	:= SM0->( GetArea() )
Local cCNPJ    	:= ""
Local oModel    := FWModelActive()
Local oMdlRFZ 	:= oModel:GetModel( 'RFZDETAIL' )
Local nLine		:= oMdlRFZ:GetLine()

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Obtem o CGC da Empresa de Origem							 ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
IF ( lRet := SM0->( dbSeek( cEmpAnt + SRA->RA_FILIAL ) ) .Or. IsBlind())
	If ReadVar() == "M->RFZ_CNPJAN"	
		cCNPJ := M->RFZ_CNPJAN
		lInsc := .T.
	ElseIf ReadVar() == "M->RFZ_CNPJCE"
		cCNPJ := M->RFZ_CNPJCE
	EndIf
	
	If !Empty(cCNPJ)
		If SM0->M0_CGC == cCNPJ
			Help( , , 'HELP', , OemToAnsi(STR0017), 1, 0 ) //"O número de inscrição informado deve ser diferente do número de inscrição da filial de cadastro do participante."
			lRet	:= .F.
		Else
			If cCNPJ == "00000000000000"
				lRet := .F.
			ElseIf !lRfzTpInsc .Or. Empty(oMdlRFZ:GetValue( 'RFZ_TPINSC', nLine )) 
				If Len( Alltrim(cCNPJ) ) <> 11
					lRet := CGC(cCNPJ)
					If !lRet
						Help( , , 'HELP', , OemToAnsi(STR0036), 1, 0 ) //"O número de inscrição informado não é válido!"
					EndIf	
				Else
					lRet := ChkCPF(cCNPJ)
				EndIf	
			ElseIf lRfzTpInsc .And. lInsc .and. !Empty(oMdlRFZ:GetValue( 'RFZ_TPINSC', nLine )) .And. oMdlRFZ:GetValue( 'RFZ_TPINSC', nLine ) $ "1/2"
				If oMdlRFZ:GetValue( 'RFZ_TPINSC', nLine ) == "2" .And. (!ChkCPF( cCNPJ ) .Or. Len( Alltrim(cCNPJ) ) != 11)
					lRet := .F.
				ElseIf oMdlRFZ:GetValue( 'RFZ_TPINSC', nLine ) == "1" .And. (!CGC( cCNPJ ) .Or. Len( Alltrim(cCNPJ) ) != 14)
					lRet := .F.
					Help( , , 'HELP', , OemToAnsi(STR0036), 1, 0 ) //"O número de inscrição informado não é válido!"
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Restaura os Dados de Entrada								 ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
RestArea( aAreaSM0 )
RestArea( aArea )

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao   ³fGP926Edit ºAutor  ³Emerson Campos      º Data ³  20/08/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.    ³ When dos campos relativo ao eSocial					      º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso      ³ GPEA926                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function fGP926Edit()
Local lRet 		:= .F.
Local oModelGrid	:= FwModelActive()
Local oModel  	:= oModelGrid:GetModel('RFZDETAIL')

If ReadVar() $ "M->RFZ_CATODS" 
	If (oModel:GetValue('RFZ_TPADM') == "4" .AND.  (SRA->RA_CATEFD == '401'))
		lRet := .T.
	EndIf
ElseIf oModel:GetValue('RFZ_TPADM') $ "1*2*3*4"
	lRet 		:= .T.
	If oModel:GetValue('RFZ_TPADM') == "1" .AND. ReadVar() $ "M->RFZ_CNPJAN*M->RFZ_MATANT*M->RFZ_DTADAN*M->RFZ_OBSVAN" 
		lRet := .F.
	ElseIf oModel:GetValue('RFZ_TPADM') $ "1*2*3" .AND. ReadVar() $ "M->RFZ_CNPJCE*M->RFZ_MATCED*M->RFZ_DTADCE*M->RFZ_ONUS" 
		lRet := .F.
	EndIf
EndIf

Return lRet 

/*/{Protheus.doc} fGP926Pict
Função para mudar a picture de campos CPNJ/CPF
@type      	Function
@author   	Allyson Mesashi
@since		23/12/2019
@version	1.0
/*/
Function fGP926Pict()
	Local cPicRJ 	:=  "@R 99.999.999/9999-99"
	Local oModel    := FWModelActive()
	Local oMdlRFZ 	:= oModel:GetModel( 'RFZDETAIL' )
	Local nLine		:= oMdlRFZ:GetLine()

	If oMdlRFZ:GetValue( 'RFZ_TPINSC', nLine ) == "2"//CPF
		cPicRJ := "@R 999.999.999-99"
	ElseIf !Empty(oMdlRFZ:GetValue( 'RFZ_TPINSC', nLine )) .And. oMdlRFZ:GetValue( 'RFZ_TPINSC', nLine ) != "1"//CNPJ
		cPicRJ := "@R 99999999999999"
	Endif

	cPicRJ := cPicRJ + "%C"

Return cPicRJ

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ RFXDATAIVL    ³ Autor ³ Emerson Campos   ³ Data ³11/07/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Função para validação da data inicial da estabilidade      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Geral                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Function fDtAdAnVld(nOpc)
Local lRet 		:= .T.
Local oModel 	:= FWModelActive()

If nOpc == 1 
	lRet := ChkValDt(oModel:GetValue( 'RFZDETAIL', 'RFZ_DTADAN'),SRA->RA_ADMISSA,">",STR0027+" "+dtoc(SRA->RA_ADMISSA),.T.)//"A data de ínicio do vínculo trabalhista deve ser anterior a data de admissão do trabalhador. Funcionário admitido em:"
EndIf

If nOpc == 2 
	lRet := ChkValDt(oModel:GetValue( 'RFZDETAIL', 'RFZ_DTADCE'),SRA->RA_ADMISSA,">",STR0028+" "+dtoc(SRA->RA_ADMISSA),.T.)//"A data de admissão do trabalhador no empregador de origem(cedente) deve ser anterior a data de admissão do trabalhador. Funcionário admitido em:"
EndIf 
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ f926Comm      ³ Autor ³ Glaucia Messina  ³ Data ³05/07/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Função para integracao TAF evento S-2200                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ GPEA926                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/
Static Function f926Comm(oModel)
Local aArea			:= GetArea()
Local lRet		    := .T.
Local cTipoAdm		:= 0
Local cStatus		:= ""
Local cStat1    	:= "" 
Local cCod			:= ""
Local cTrabVincu	:= fCatTrabEFD("TCV") //"101|102|103|104|105|106|111|301|302|303|306|309" //Trabalhador com vinculo
Local cTSV			:= "410" // para envio de trabalhadores sem vínculo somente se a categoria for 410
Local cFilEnv		:= ""
Local aFilInTaf 	:= {}
Local aArrayFil 	:= {}
Local oMdlRFZ		:= oModel:GetModel("RFZDETAIL")
Local aTpAlt	    := {.F., .F., .F., .F.}
Local aErros		:= {}
Local cMsgLog		:= ""
Local nCont			:= 0

Local aInfoC		:= {}
Local cChaveMid		:= ""
Local cNrInsc		:= ""
Local cTpInsc		:= ""
Local lAdmPubl		:= .F.
Local nIndice		:= 0

cCPF 	:= If( Type("cCPF") == "U"	, SRA->RA_CIC 	, cCPF)
cCateg	:= If( Type("cCateg") == "U", SRA->RA_CATEFD , cCateg)


If Type('cVersEnvio') == "U"
	If ( ExistFunc( 'fVersEsoc' ), fVersEsoc( "S2200", .F.,,,@cVersEnvio),cVersEnvio:= "2.2")
Endif 

If (lIntTAF .Or. lMiddleware) .AND. !(EMPTY(cCPF)) .AND. !(EMPTY(cCateg)) .And. FUNNAME() <> "GPEM035"

	IF !EMPTY(oMdlRFZ) .AND. ALLTRIM(oMdlRFZ:GetValue("RFZ_CATEG")) $ cTrabVincu .AND. !EMPTY(oMdlRFZ:GetValue("RFZ_ONUS"))
		Help( , , 'HELP', , OemToAnsi(STR0045), 1, 0 )
		oMdlRFZ:SetValue("RFZ_ONUS","")
	ENDIF

	If !lMiddleware
		fGp23Cons(@aFilInTaf, @aArrayFil,@cFilEnv)
	EndIf
	RegToMemory("SRA")
	
	If cCateg $ cTrabVincu .And. Empty(SRA->RA_CODUNIC)
		MsgAlert(OemToAnsi(STR0042)) //Funcionario sem codigo unico gerado. Acessar o Cad. Funcionario ou Realizar Carga Inicial
		lRet := .F.
	Else	
		If Empty(cFilEnv)
			cFilEnv:= cFilAnt
		EndIf	

		If cCateg <> cTSV 
			cCod 		:= AllTrim(SRA->RA_CIC) + ";" + ALLTRIM(SRA->RA_CODUNIC)
			nIndice		:= Retorder( "C9V" , "C9V_FILIAL+C9V_CPF+C9V_MATRIC+C9V_ATIVO") 
		Else
			cCod 		:= AllTrim( SRA->RA_CIC ) + ";" + AllTrim( SRA->RA_CATEFD ) + ";" + DTOS( SRA->RA_ADMISSA )
			nIndice		:= Retorder( "C9V" , "C9V_FILIAL+C9V_CPF+C9V_CATCI+C9V_ATIVO" )
		EndIf

		If !lMiddleware
			cStatus := TAFGetStat( "S-2200", cCod, cEmpAnt, cFilEnv , nIndice)
		Else
			cStatus := "-1"
			fPosFil( cEmpAnt, SRA->RA_FILIAL )
			aInfoC   := fXMLInfos()
			If LEN(aInfoC) >= 4
				cTpInsc  := aInfoC[1]
				lAdmPubl := aInfoC[4]
				cNrInsc  := aInfoC[2]
			Else
				cTpInsc  := ""
				lAdmPubl := .F.
				cNrInsc  := "0"
			EndIf
			cChaveMid	:= cTpInsc + PADR( Iif( !lAdmPubl .And. cTpInsc == "1", SubStr(cNrInsc, 1, 8), cNrInsc), 14) + "S2200" + Padr(SRA->RA_CODUNIC, 40, " ")
			cStatus 	:= "-1"			
			//RJE_TPINSC+RJE_INSCR+RJE_EVENTO+RJE_KEY+RJE_INI
			GetInfRJE( 2, cChaveMid, @cStatus )
		EndIf
		cStat1  := TAFGetStat( "S-2300", cCod, cEmpAnt, cFilEnv , nIndice)
	
		//Verifica o status dos registros
	   If( cStatus == "2" .and.  cStat1 <> "2" )
			If !lMiddleware
				oModel:SetErrorMessage("",,oModel:GetId(),"","",OemToAnsi(STR0043)) //Em transito
			Else
				oModel:SetErrorMessage("",,oModel:GetId(),"","",OemToAnsi(STR0047)) //"Registro de admissão do funcionário em trânsito ao RET. A alteração não será efetivada."
			EndIf
			lRet := .F.
	   Else
		   fStatusTAF(@aTpAlt,cStatus,cStat1, FUNNAME())
	   EndIf	
	
		If lRet .And. ( cCateg $ cTrabVincu .Or.  cCateg == cTSV )
			If aTpAlt[1] .And. cCateg $ cTrabVincu
				lRet:= fIntAdmiss("SRA", Nil, oModel:GetOperation(), "S2200", Nil, Nil, Nil, oModel, Nil, @aErros, cVersEnvio, oMdlRFZ)
			ElseIf aTpAlt[2] .And. cCateg == cTSV
				lRet := fInt2300New("SRA",,,"S2300",,,cVersEnvio,,,,,oMdlRFZ)
			Else
				lRet := .F.
			Endif
		Endif
		If lRet .And. ExistFunc('fEFDMsg')
			fEFDMsg()
		ElseIf Len(aErros) > 0
			For nCont := 1 to Len(aErros)
				If aErros[nCont] == "TPJORN"
					cMsgLog += CRLF + STR0048//"O Tipo de Jornada não foi localizado, favor verificar o cadastro do funcionário para que o mesmo seja integrado corretamente." 
				Else
					cMsgLog += CRLF + aErros[nCont]
				EndIf
			Next
			oModel:SetErrorMessage("",,oModel:GetId(),"","",cMsgLog)
		EndIf		
	EndIf

	If lRet
		FWFormCommit(oModel)
	EndIf
Else
    FWFormCommit(oModel)	
Endif

RestArea(aArea)
Return lRet

/*/{Protheus.doc} Gp926When
Função responsável por validação de when do campo RFZ_DTTRA
@type function
@author Cecilia C
@since 03/11/2017
@version 1.0
@return lRet, boolean, Retorno se libera a edição do campo
/*/
Function Gp926When()
Local oModelGrid	:= FwModelActive()
Local oModel  	:= oModelGrid:GetModel('RFZDETAIL')
Local lRet		:= .F. 

If (oModel:GetValue('RFZ_TPADM')) <> "1"
	lRet:= .T.
Endif

Return( lRet )
