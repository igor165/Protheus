#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "LOJA1145.CH"

// O protheus necessita ter ao menos uma função pública para que o fonte seja exibido na inspeção de fontes do RPO.
Function LOJA1145() ; Return


//-------------------------------------------------------------------
/*/{Protheus.doc} LJCInitialLoadLoaderWizard

Classe assistênte do processo de carregar a carga
  

@author Vendas CRM
@since 07/02/10
/*/
//--------------------------------------------------------------------
Class LJCInitialLoadLoaderWizard
	Data oWizard
	Data oPanelConfiguration
	Data oPanelLoad
	
	Data oClient
	Data lImport
	Data lDownload
	Data lActInChildren
	Data lKillOtherThreads
	Data lIsExpress
	Data lForcedExecution
	Data lSucceffulExecution
	
	Data oMGIP
	Data cMGIP
	Data oMGPort
	Data cMGPort
	Data oMGEnvironment
	Data cMGEnvironment
	Data oMGCompany
	Data cMGCompany
	Data oMGBranch
	Data cMGBranch
	Data oBMPTest
	Data oLblTest
	Data oBtnConnectionTest
	
	Data oLblRStaLo
	Data oLblRILGen
	Data oLblRILTab
	Data oLblRILRec	
	Data oLblLStaLo
	Data oLblLILGen
	Data oLblLILTab
	Data oLblLILRec		
	
	Data oLblStaV1
	Data oLblFilVa
	Data oLblSpeV1
	Data oLblPr1Va
	Data oMtrDownl
	Data cMtrDownl		
	Data oLblStaV2
	Data oLblTabVa
	Data oLblSpeV2
	Data oLblPr2Va
	Data oMtrIL
	Data cMtrIL	
	Data oBtnStartLoad	
	Data oBtnLoadPSS	
	Data oBtnCleanLoad
	Data oBtnUpdateAll
	Data oCBStartChildren
	
	Method New()
	Method Show()
	Method ShowExpress()
	Method Initialize()
	Method ButtonClick()
	Method LoadConfiguration()
	Method TestConnection()
	Method UpdateConnectionStatus()
	Method SaveConfiguration()
	Method ValidateConnection()
	Method LoadStart()
	Method StartLoad()
	Method Update()
	Method ClearProgress()
	Method UpdateFilesProgress()
	Method ClearFilesProgress()
	Method UpdateDownloadProgress()
	Method ClearDownloadProgress()
	Method UpdateTablesProgress()
	Method ClearTablesProgress()	
	Method FormatSize()
	Method CheckFinish()
	
	Method CleanTrash() //refatorar nome dos objetos e lugar das chamadas
	Method CheckAutomatic()
	
EndClass         


//-------------------------------------------------------------------
/*/{Protheus.doc} New()

Construtor
  
@param oClient: Cliente que receberá a carga. 
@param lImport Pré-configuração de impostação.
@param lDownload Pré-configuração de baixa.  
@param lActInChildren Pré-configuração de ação nos dependentes.       
@param lKillOtherThreads Pré-configuração de derrubar processos.

@return Nil

@author Vendas CRM
@since 07/02/10
/*/
//--------------------------------------------------------------------
Method New( oClient, lImport, lDownload, lActInChildren, lKillOtherThreads ) Class LJCInitialLoadLoaderWizard
	Default lImport				:= .F.
	Default lDownload 			:= .F.
	Default lActInChildren 		:= .F.
	Default lKillOtherThreads	:= .F.
	
	Self:cMGIP					:= Space(60)
	Self:cMGPort				:= Space(60)
	Self:cMGEnvironment			:= Space(60)
	Self:cMGCompany				:= Space(60)	
	Self:cMGBranch				:= Space(60)	
	Self:oClient				:= oClient
	Self:lImport				:= lImport
	Self:lDownload				:= lDownload
	Self:lActInChildren 		:= lActInChildren
	Self:lKillOtherThreads		:= lKillOtherThreads
	Self:lForcedExecution		:= .F.
	Self:lSucceffulExecution	:= .F.
	Self:lIsExpress			:= .F.
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Show()

Exibe o assistente. 
  
@return Nil

@author Vendas CRM
@since 07/02/10
/*/
//--------------------------------------------------------------------
Method Show() Class LJCInitialLoadLoaderWizard
	Self:Initialize()
	
	ACTIVATE WIZARD Self:oWizard CENTERED
Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} ShowExpress()

Exibe o assistente. Essa versão é utilizada pelo controle de lojas
para abrir o Assistente e forçar a atualização da carga, sem o poder 
de alterar as ações da execução

@return Nil 

@author Vendas CRM
@since 23/10/10
/*/
//--------------------------------------------------------------------
Method ShowExpress( lAutomatic ) Class LJCInitialLoadLoaderWizard	
	Local oLJCMessageManager	:= GetLJCMessageManager()	
	Self:lIsExpress 			:= .T.
	Self:Initialize()
	
	MsgRun(STR0018, STR0010, { || Self:TestConnection() } ) // "Testar conexão" "Testando conexão." "Aguarde..."
	
	If !oLJCMessageManager:HasError()
		Self:oWizard:SetPanel( 3 )				
		Self:lForcedExecution	:= .T.
	Else
		Self:oWizard:SetPanel( 2 )
		Self:lForcedExecution	:= .F.
	EndIf
		
		
	ACTIVATE WIZARD Self:oWizard VALID {||Self:CheckFinish()}  ON INIT {||Self:CheckAutomatic( lAutomatic )} CENTERED
	
	
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Initialize()

Inicializa e configura os componentes do assisntência
  
@return Nil 

@author Vendas CRM
@since 07/02/10
/*/
//--------------------------------------------------------------------
Method Initialize() Class LJCInitialLoadLoaderWizard
	Local nP1Row	:= 0
	Local nP1Col	:= 0
	Local nP2Row	:= 0
	Local nP2Col	:= 0
	Local nP3Row	:= 0
	Local nP3Col	:= 0
		
	
	DEFINE WIZARD Self:oWizard TITLE STR0001 HEADER STR0002 MESSAGE STR0003; // "Assistente de importação de carga" "Assistente de configuração e importação de carga do Controle de Lojas" "Introdução"
		TEXT STR0004 + CRLF + STR0005 + CRLF + STR0006 PANEL ; // "Esse assistente lhe auxiará na configuração e importação da carga." "Na página de 'Configuração do servidor de carga', as informações de conexão com o servidor de carga deverão ser informadas. A conexão poderá ser testada logo abaixo dos campos de configuração." "A conexão, download e importação da carga é executada na página 'Execução de carga'."
		NEXT {|| .T. } FINISH {|| Self:CheckFinish() }				
		
	// Painél de configurações
	CREATE PANEL Self:oWizard HEADER STR0007 MESSAGE STR0008 PANEL; // "Assistente de configuração e importação de carga do Controle de Lojas" "Configuração do servidor de carga"
		BACK {|| .T. } NEXT {|| MsgRun(STR0009, STR0010, { || Self:SaveConfiguration() } ), Self:ValidateConnection() } FINISH {|| Self:CheckFinish() } EXEC {|| .T.} // "Salvando configurações." "Aguarde..." "Atualizando status das cargas"

	Self:oPanelConfiguration := TPanel():New( 0, 0, , Self:oWizard:oMPanel[Len(Self:oWizard:oMPanel)], , , , , , 0, 0 )
	Self:oPanelConfiguration:Align := CONTROL_ALIGN_ALLCLIENT		
		
	nP1Row	:= 022
	nP1Col	:= 095		
	@ nP1Row + 002, nP1Col + 002 TO nP1Row + 076, nP1Col + 097 LABEL STR0011 PIXEL OF Self:oPanelConfiguration // "Servidor de carga:"
	@ nP1Row + 012, nP1Col + 022 Say STR0012 Size 008,008 COLOR CLR_BLACK PIXEL OF Self:oPanelConfiguration // "IP:"
	@ nP1Row + 011, nP1Col + 032 MsGet Self:oMGIP Var Self:cMGIP Size 060,010 COLOR CLR_BLACK Picture "@!" PIXEL OF Self:oPanelConfiguration	
	@ nP1Row + 025, nP1Col + 006 Say STR0013 Size 030,008 COLOR CLR_BLACK PIXEL OF Self:oPanelConfiguration // "Porta RPC:"
	@ nP1Row + 023, nP1Col + 032 MsGet Self:oMGPort Var Self:cMGPort Size 060,010 COLOR CLR_BLACK Picture Replicate("9",Len(Self:cMGPort)) PIXEL OF Self:oPanelConfiguration	
	@ nP1Row + 037, nP1Col + 006 Say STR0014 Size 025,008 COLOR CLR_BLACK PIXEL OF Self:oPanelConfiguration	 // "Ambiente:"
	@ nP1Row + 036, nP1Col + 032 MsGet Self:oMGEnvironment Var Self:cMGEnvironment Size 060,010 COLOR CLR_BLACK Picture "@!" PIXEL OF Self:oPanelConfiguration	
	@ nP1Row + 049, nP1Col + 006 Say STR0015 Size 025,008 COLOR CLR_BLACK PIXEL OF Self:oPanelConfiguration // "Empresa:"
	@ nP1Row + 048, nP1Col + 032 MsGet Self:oMGCompany Var Self:cMGCompany Size 060,010 COLOR CLR_BLACK PIXEL OF Self:oPanelConfiguration		
	@ nP1Row + 061, nP1Col + 006 Say STR0016 Size 025,008 COLOR CLR_BLACK PIXEL OF Self:oPanelConfiguration // "Filial:"
	@ nP1Row + 060, nP1Col + 032 MsGet Self:oMGBranch Var Self:cMGBranch Size 060,010 COLOR CLR_BLACK PIXEL OF Self:oPanelConfiguration			
	@ nP1Row + 084, nP1Col + 005 Button Self:oBtnConnectionTest PROMPT STR0017 Size 046,012 Action MsgRun(STR0018, STR0010, { || Self:ButtonClick( Self:oBtnConnectionTest ) } ) PIXEL OF Self:oPanelConfiguration  // "Testar conexão" "Testando conexão." "Aguarde..."
	@ nP1Row + 086, nP1Col + 055 Bitmap Self:oBMPTest RESOURCE "OK" Size 008,008 PIXEL ADJUST NO BORDER OF Self:oPanelConfiguration				
	@ nP1Row + 087, nP1Col + 065 Say Self:oLblTest Prompt STR0019 Size 050,008 COLOR CLR_BLACK PIXEL OF Self:oPanelConfiguration // "Sem informação"
	@ nP1Row + 110, 002 Say STR0072 Size 250,020 COLOR CLR_BLACK Pixel Of Self:oPanelConfiguration // "Lembre-se de executar o 'UPDCARGA - Facilitador para a criação dos campos reservados da carga'."
	
	
	// Painél de configurações
	CREATE PANEL Self:oWizard HEADER STR0020 MESSAGE STR0021 PANEL; // "Assistente de configuração e importação de carga do Controle de Lojas" "Execução de carga"
		BACK {|| .T. } NEXT {|| .T. } FINISH {|| Self:CheckFinish() } EXEC {|| .T.}	
		
	Self:oPanelLoad := TPanel():New( 0, 0, , Self:oWizard:oMPanel[Len(Self:oWizard:oMPanel)], , , , , , 0, 0 )
	Self:oPanelLoad:Align := CONTROL_ALIGN_ALLCLIENT		
		
	nP2Row := 003
	nP2Col := 070
	@ nP2Row + 000, nP2Col + 000 TO nP2Row + 055, nP2Col + 160 LABEL STR0022 PIXEL OF Self:oPanelLoad // "Download:"
	@ nP2Row + 008, nP2Col + 014 Say STR0023 Size 018,008 COLOR CLR_BLACK PIXEL OF Self:oPanelLoad // "Estado:"
	@ nP2Row + 016, nP2Col + 012 Say STR0024 Size 021,008 COLOR CLR_BLACK PIXEL OF Self:oPanelLoad // "Arquivo:"
	@ nP2Row + 024, nP2Col + 005 Say STR0025 Size 028,008 COLOR CLR_BLACK PIXEL OF Self:oPanelLoad // "Velocidade:"
	@ nP2Row + 032, nP2Col + 005 Say STR0026 Size 028,008 COLOR CLR_BLACK PIXEL OF Self:oPanelLoad // "Progresso:"
		
	@ nP2Row + 008, nP2Col + 036 Say Self:oLblStaV1 PROMPT "" Size 120,008 COLOR CLR_BLACK PIXEL OF Self:oPanelLoad
	@ nP2Row + 016, nP2Col + 036 Say Self:oLblFilVa PROMPT "" Size 120,008 COLOR CLR_BLACK PIXEL OF Self:oPanelLoad
	@ nP2Row + 024, nP2Col + 036 Say Self:oLblSpeV1 PROMPT "" Size 120,008 COLOR CLR_BLACK PIXEL OF Self:oPanelLoad
	@ nP2Row + 032, nP2Col + 036 Say Self:oLblPr1Va PROMPT "" Size 120,008 COLOR CLR_BLACK PIXEL OF Self:oPanelLoad
	@ nP2Row + 040, nP2Col + 005 METER Self:oMtrDownl Var Self:cMtrDownl Size 147,008 NOPERCENTAGE PIXEL OF Self:oPanelLoad

	nP3Row := 063
	nP3Col := 070
	@ nP3Row + 000, nP3Col + 000 TO nP3Row + 055, nP3Col + 160 LABEL STR0027 PIXEL OF Self:oPanelLoad // "Carga:"
	@ nP3Row + 008, nP3Col + 014 Say STR0028 Size 018,008 COLOR CLR_BLACK PIXEL OF Self:oPanelLoad // "Estado:"
	@ nP3Row + 016, nP3Col + 014 Say STR0029 Size 018,008 COLOR CLR_BLACK PIXEL OF Self:oPanelLoad // "Tabela:"
	@ nP3Row + 024, nP3Col + 005 Say STR0030 Size 028,008 COLOR CLR_BLACK PIXEL OF Self:oPanelLoad // "Velocidade:"
	@ nP3Row + 032, nP3Col + 005 Say STR0031 Size 028,008 COLOR CLR_BLACK PIXEL OF Self:oPanelLoad // "Progresso:"
				
	@ nP3Row + 008, nP3Col + 036 Say Self:oLblStaV2 PROMPT "" Size 120,008 COLOR CLR_BLACK PIXEL OF Self:oPanelLoad
	@ nP3Row + 016, nP3Col + 036 Say Self:oLblTabVa PROMPT "" Size 120,008 COLOR CLR_BLACK PIXEL OF Self:oPanelLoad
	@ nP3Row + 024, nP3Col + 036 Say Self:oLblSpeV2 PROMPT "" Size 120,008 COLOR CLR_BLACK PIXEL OF Self:oPanelLoad
	@ nP3Row + 032, nP3Col + 036 Say Self:oLblPr2Va PROMPT "" Size 120,008 COLOR CLR_BLACK PIXEL OF Self:oPanelLoad
	@ nP3Row + 040, nP3Col + 005 METER Self:oMtrIL Var Self:cMtrIL Size 147,008 NOPERCENTAGE PIXEL OF Self:oPanelLoad

	nP2Row	:= 000	
	nP2Col	:= 125
	
	
	nP3Row	:= 055	
	nP3Col	:= 125	
	
	If !Self:lIsExpress
		@ 123, 20 Button Self:oBtnStartLoad PROMPT STR0067 Size 076,012 Action Self:ButtonClick( Self:oBtnStartLoad ) PIXEL OF Self:oPanelLoad // "Selecionar cargar"	
		@ 123, 200 Button Self:oBtnLoadPSS PROMPT STR0068 Size 076,012 Action MsgRun( STR0065 + ".........", STR0010, {|| Self:ButtonClick( Self:oBtnLoadPSS ) } ) PIXEL OF Self:oPanelLoad  // "Atualizar senhas"

		If SuperGetMv("MV_LJATUSE",,1) == 1
			Self:oBtnLoadPSS:Enable()
		Else
			LjGrvLog("Carga","A opção para atualizar senha esta desabilitada porque o parametro MV_LJATUSE não esta igual a 1")
			Self:oBtnLoadPSS:Disable()
		EndIf
	EndIf
	
	@ 123, 110 Button Self:oBtnUpdateAll PROMPT STR0069 Size 076,012 Action Self:ButtonClick( Self:oBtnUpdateAll ) PIXEL OF Self:oPanelLoad  // "Atualizar Tudo"
	
	
	
	Self:LoadConfiguration()
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidateConnection()

Método que valida conexão de carga, no Step 2 do Wizard.
  
@return lRet .T. se há conexão, .F. se não.  

@author Varejo
@since 15/05/18 
/*/
//--------------------------------------------------------------------
Method ValidateConnection()  Class LJCInitialLoadLoaderWizard
	Local lRet	:= .F.
	
	 If Self:TestConnection()
	 	lRet := .T.
	 Else
	 	MsgAlert(STR0073) //"Efetue as configurações necessárias para continuar."
	 Endif		
		
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ButtonClick()

Método que recebe os eventos de clique do assistênte
  
@param oSender Objeto que gerou o evento de clique.

@return Nil 

@author Vendas CRM
@since 07/02/10 
/*/
//--------------------------------------------------------------------
Method ButtonClick( oSender ) Class LJCInitialLoadLoaderWizard
	Local oLJCMessageManager	:= GetLJCMessageManager()

	If oSender == Self:oBtnConnectionTest		
		Self:SaveConfiguration()
		Self:UpdateConnectionStatus(Self:TestConnection())
	ElseIf oSender == Self:oBtnStartLoad //selecionar cargas
		Self:LoadStart()
	ElseIf oSender == Self:oBtnCleanLoad //limpar
		Self:CleanTrash()
	ElseIf oSender == Self:oBtnUpdateAll //atualizar tudo
		Self:LoadStart(.T.)
	ElseIf oSender == Self:oBtnLoadPSS //atualizar sigapss
		Self:LoadStart(.F., .T.)
	EndIf
	If oLJCMessageManager:HasMessage()
		oLJCMessageManager:Show( STR0035 ) // "Houve um erro ao tentar executar a operação."
		oLJCMessageManager:Clear()
	EndIf
Return

            
//-------------------------------------------------------------------
/*/{Protheus.doc} LoadStart()

Exibe o diálogo com as opções para solicitação de carga e importação
 
@param lUpdateAll .T. = atualizcao completa do ambiente (aplica todas as cargas incrementais pendentes no ambiente) 
  
@return Nil

@author Vendas CRM
@since 07/02/10 
/*/
//--------------------------------------------------------------------
Method LoadStart(lUpdateAll, lLoadPSS) Class LJCInitialLoadLoaderWizard
	Local oLJCMessageManager			:= GetLJCMessageManager()
	Local oLJMessenger				 	:= LJCInitialLoadMessenger():New( Self:oClient )
	Local oLJILResult					:= Nil		//Lista com todas as cargas
	Local oSelectorLoad 				:= nil		//tela para selecionar e tomar acoes sobre as cargas
	Local oRequest						:= Nil		//requisicao de carga
	Local lCargaAut						:= SuperGetMV("MV_LJILOLE",,"0") == "1" .And. ExistFunc("LOJA1157EXPRESS")
	Local lAutomatic					:= SuperGetMV("MV_LJILAUT", .F., .F.) //determina se executa o carregamento express de forma automatica
	
	Default lUpdateAll 					:= .F.
	Default lLoadPSS 					:= .F. //atualiza arquivo de senhas - sigapss
	
	
	If !oLJCMessageManager:HasError()	
		Self:TestConnection()
	
		If !oLJCMessageManager:HasError() 
			LjGrvLog( "Carga","Carrega lista de cargas")
			MsgRun( STR0070 + ".........", STR0010, {|| oLJILResult := oLJMessenger:GetILResult() } )	//atusx  //busca lista das carga
			
			If !oLJCMessageManager:HasError() 	
				If oLJILResult <> Nil
				
					
					If !oLJCMessageManager:HasError()	
					
						oRequest := LJCInitialLoadRequest():New(oLJILResult , Self:oClient, Self:lDownload, Self:lImport, Self:lActInChildren, Self:lKillOtherThreads, nil , lUpdateAll, Self:lIsExpress, lLoadPSS )
						oSelectorLoad := LJCInitialLoadSelector():New(oLJILResult, oRequest)	
						
						
						// se vier do lojxfunb
						If isInCallStack("LOJA1157EXPRESS")
							//Chamada da tela de seleção da ação das cargas pendentes.  
							//se for automatico não requer acionamento do botão de atualização
							
							LjGrvLog( "Carga","Abre Assistente Carga express MV_LJILOLE ",lCargaAut )
							LjGrvLog( "Carga","Carga express de forma automatica MV_LJILAUT ",lAutomatic )
							If lCargaAut .AND. lAutomatic 
								lUpdateAll := .T.  // update será automatica e não manual
								oSelectorLoad:lExecute := .T.  
							EndIf
	
							//caso tenha cido acionado o botão de carga. ele será utlizado se o parametro
							//estiver falso
							If lCargaAut .AND. (!lAutomatic .OR. lUpdateAll)
								oSelectorLoad:SelectActions()
							EndIf
						EndIf			
						
						If !lLoadPSS	//se nao for atualizacao de senhas exibe telas de selecao das cargas e/ou acoes
							If !lUpdateAll //se for carregamento manual
								oSelectorLoad:Show()
							Else //se for express ou atualizar tudo selecionado pelo usuario
															
								If !Self:lIsExpress
									oSelectorLoad:SelectActions() //define as opcoes Download, import, aplicar nos filhos, matar outras threads
								EndIf
								If oSelectorLoad:lExecute
									oSelectorLoad:MarkIncLoad()
								EndIf
							EndIf
						EndIf
							
						If oSelectorLoad:lExecute .OR. lLoadPSS	
							Self:oWizard:oBack:Disable()
							Self:oWizard:oNext:Disable()
							Self:oWizard:oCancel:Disable()
							Self:oWizard:oFinish:Disable()
							Self:oBtnUpdateAll:Disable()
							If !Self:lIsExpress
								Self:oBtnStartLoad:Disable()
								Self:oBtnLoadPSS:Disable()		
							EndIf
							
							Self:StartLoad(oRequest)
							
							Self:oWizard:oBack:Enable()
							Self:oWizard:oNext:Enable()
							Self:oWizard:oCancel:Enable()
							Self:oWizard:oFinish:Enable()
							Self:oBtnUpdateAll:Enable()
							If !Self:lIsExpress
								Self:oBtnStartLoad:Enable()
								Self:oBtnLoadPSS:Enable()
							EndIf
							
						EndIf
					EndIf
				Else			
					oLJCMessageManager:ThrowMessage( LJCMessage():New("LJCInitialLoadLoaderWizard", 1, STR0066 ) ) // "O ambiente configurado no parâmetro MV_LJAMBIE não foi encontrado no cadastro de ambientes."
				EndIf
			EndIf
		EndIf	
	EndIf
	
	If oRequest <> NIL
	 	Self:lDownload 			:= oRequest:lDownload 
	 	Self:lImport 			:= oRequest:lImport
	 	Self:lActInChildren 	:= oRequest:lActInChildren
	 	Self:lKillOtherThreads 	:= oRequest:lKillOtherThreads
	EndIf
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} LoadConfiguration()

Carrega a configuração para a tela
  
@return Nil

@author Vendas CRM
@since 07/02/10 
/*/
//--------------------------------------------------------------------
Method LoadConfiguration() Class LJCInitialLoadLoaderWizard
	Local oLJCMessageManager	:= GetLJCMessageManager()
	
	Self:oMGIP:cText 			:= PadR( Self:oClient:cLocation, 60 )
	Self:oMGPort:cText 			:= PadR( AllTrim( Str( Self:oClient:nPort ) ), 60 )
	Self:oMGEnvironment:cText 	:= PadR( Self:oClient:cEnvironment, 60 )
	Self:oMGCompany:cText 		:= PadR( Self:oClient:cCompany, 60 )
	Self:oMGBranch:cText  		:= PadR( Self:oClient:cBranch, 60 )
			
	Self:UpdateConnectionStatus(Self:TestConnection())
	
	oLJCMessageManager:Clear()
Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} TestConnection()

Efetua o teste de conexão para verificar se é possível se comunicar
com o servidor de arquivos do loja.

@return lRet .T. se há conexão, .F. se não.  

@author Vendas CRM
@since 07/02/10
/*/
//--------------------------------------------------------------------
Method TestConnection() Class LJCInitialLoadLoaderWizard
	Local oLJCMessageManager	:= GetLJCMessageManager()
	Local oLJMessenger		:= Nil
	Local lRet				:= .F.
	
	Self:SaveConfiguration()
	
	oLJMessenger := LJCInitialLoadMessenger():New( Self:oClient )
	
	If !oLJCMessageManager:HasError()
		lRet := oLJMessenger:CheckCommunication()
	EndIf
	
	If oLJCMessageManager:HasError()
		oLJCMessageManager:ThrowMessage( LJCMessage():New("LJCInitialLoadLoaderWizard", 1, STR0036 ) ) // "Não foi possível se conectar no servidor informado!"
	EndIf
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} UpdateConnectionStatus()

Atualiza a tela com o status da possibilidade de conexão.
  
@param lConnected Se foi possível se conectar. 

@return 07/02/10

@author Vendas CRM
@since 07/02/10
/*/
//--------------------------------------------------------------------
Method UpdateConnectionStatus( lConnected ) Class LJCInitialLoadLoaderWizard
	If lConnected
		Self:oBMPTest:SetBMP( "OK" )
		Self:oLblTest:SetText( STR0037 ) // "Conectado"
	Else
		Self:oBMPTest:SetBMP( "CANCEL" )	
		Self:oLblTest:SetText( STR0038 ) // "Não conectado"
	EndIf
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} SaveConfiguration()

Salva a configuração da tela para o objeto que o representa. 

@return .T

@author Vendas CRM
@since  07/02/10
/*/
//--------------------------------------------------------------------
Method SaveConfiguration() Class LJCInitialLoadLoaderWizard
	If (Empty(Self:oClient:cLocation) .OR. EmpTy(Self:oClient:nPort) .OR.;
	   Empty(Self:oClient:cEnvironment) .OR. EmpTy(Self:oClient:cCompany);
	   );
	   .OR.;
	   ( !Empty( Self:oMGIP:cText) .AND.  !Empty(AllTrim( Self:oMGPort:cText )) .AND.;
	     !Empty( Self:oMGEnvironment:cText ) .AND. !Empty(Self:oMGCompany:cText)  .AND.;
	     !Empty(Self:oMGBranch:cText);
	   	)
		Self:oClient:cLocation		:= AllTrim( Self:oMGIP:cText )
		Self:oClient:nPort			:= Val( AllTrim( Self:oMGPort:cText ) )
		Self:oClient:cEnvironment	:= AllTrim( Self:oMGEnvironment:cText )
		Self:oClient:cCompany		:= AllTrim( Self:oMGCompany:cText )
		Self:oClient:cBranch		:= AllTrim( Self:oMGBranch:cText )
		
	EndIf	
Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} StartLoad()

Inicia o processo de carregar a carga.  
 
@param oRequest objeto com dados da requisição de carga 
@return Nil
@author Vendas CRM
@since 07/02/10
/*/
//--------------------------------------------------------------------
Method StartLoad(oRequest) Class LJCInitialLoadLoaderWizard
	Local oLJCMessageManager			:= GetLJCMessageManager()
	Local oLJMessenger				:= LJCInitialLoadMessenger():New( Self:oClient )
	Local cWebFileServer				:= ""
	
	LjGrvLog( "Carga","carrega carga Inicio")
			
	Self:lSucceffulExecution	:= .F.
	
	Self:ClearProgress()
	
	If !oLJCMessageManager:HasError()	
		Self:TestConnection()
		
		If !oLJCMessageManager:HasError()	
			cWebFileServer := oLJMessenger:GetFileServerURL()
			
			If !oLJCMessageManager:HasError()
				LoadProcess( oRequest, cWebFileServer, Self )
									
				If !oLJCMessageManager:HasError()
					Self:lSucceffulExecution	:= .T.
				EndIf
				
			EndIf
		EndIf
	EndIf
	
	LjGrvLog( "Carga","carrega carga Fim")
	
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Update()

Recebe a notificação da atualizaçã do progresso do processo de carregar a carga.
  
@param oProgress Objeto LJCInitialLoadLoaderProgress.
@return Nil
@author Vendas CRM
@since 07/02/10
/*/
//--------------------------------------------------------------------
Method Update( oProgress ) Class LJCInitialLoadLoaderWizard	

	// Se existir o progresso do download, atualiza UI
	If oProgress:oFilesProgress != Nil
		Self:UpdateFilesProgress( oProgress:oFilesProgress )
	EndIf
	
	// Se existir o progress da carga dos dados, atualiza UI
	If oProgress:oTablesProgress != Nil
		Self:UpdateTablesProgress( oProgress:oTablesProgress )
	EndIf
	
	LJILSaveProgress( oProgress )	
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ClearProgress()

Limpa o progresso na tela

@return Nil

@author Vendas CRM
@since 07/02/10
/*/
//--------------------------------------------------------------------
Method ClearProgress() Class LJCInitialLoadLoaderWizard
	Self:ClearFilesProgress()
	Self:ClearTablesProgress()
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} UpdateFilesProgress()

Atualiza o progresso de baixa do arquivo de carga.  
  
@param oFilesProgress Objeto LJCInitialLoadFilesProgress.

@return Nil

@author Vendas CRM
@since 07/02/10 
/*/
//--------------------------------------------------------------------
Method UpdateFilesProgress( oFilesProgress ) Class LJCInitialLoadLoaderWizard
	If oFilesProgress:oDownloadProgress != Nil
		Self:UpdateDownloadProgress( oFilesProgress:oDownloadProgress )
	EndIf
	
	If Len( oFilesProgress:aFiles ) > 0 .And. oFilesProgress:nActualFile <= Len( oFilesProgress:aFiles )
		Self:oLblFilVa:SetText( oFilesProgress:aFiles[oFilesProgress:nActualFile] + " (" + AllTrim(Str(oFilesProgress:nActualFile))  + "/" + AllTrim(Str(Len( oFilesProgress:aFiles ))) + ")")	
	EndIf
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ClearFilesProgress()

Limpa na tela o progresso da baixa dos arquivos de carga.    

@return Nil

@author Vendas CRM
@since 07/02/10
/*/
//--------------------------------------------------------------------
Method ClearFilesProgress() Class LJCInitialLoadLoaderWizard
	Self:ClearDownloadProgress()

	Self:oLblFilVa:SetText( "" )		
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} UpdateDownloadProgress()

Atualiza na tela o progresso da baixa do arquivo.  
  
@param oDownloadProgress Objeto LJCFileDownloaderDownloadProgress.

@return Nil

@author Vendas CRM
@since 07/02/10
/*/
//--------------------------------------------------------------------
Method UpdateDownloadProgress( oDownloadProgress ) Class LJCInitialLoadLoaderWizard
	Do Case
		Case oDownloadProgress:nStatus == 1
			Self:oLblStaV1:SetText( STR0039 ) // "Iniciado"
		Case oDownloadProgress:nStatus == 2
			Self:oLblStaV1:SetText( STR0040 ) // "Baixando"
		Case oDownloadProgress:nStatus == 3
			Self:oLblStaV1:SetText( STR0041 ) // "Finalizado"
		Case oDownloadProgress:nStatus == 4
			Self:oLblStaV1:SetText( STR0042 ) // "Erro"
	End
	
	Self:oLblSpeV1:SetText( Self:FormatSize( oDownloadProgress:NBYTESPERSECOND) + "/s" )
	Self:oLblPr1Va:SetText( Self:FormatSize( oDownloadProgress:NDOWNLOADEDBYTES) + "/" + Self:FormatSize( oDownloadProgress:NTOTALBYTES) + " (" +  AllTrim(Str(Round((oDownloadProgress:NDOWNLOADEDBYTES*100)/oDownloadProgress:NTOTALBYTES,2))) + "%)" )
	Self:oMtrDownl:Set( (oDownloadProgress:NDOWNLOADEDBYTES*100)/oDownloadProgress:NTOTALBYTES )
	Self:oMtrDownl:SetTotal(100)
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ClearDownloadProgress()

Limpa na tela o progress da baixa do arquivo.   

@return Nil

@author Vendas CRM
@since 07/02/10 
/*/
//--------------------------------------------------------------------
Method ClearDownloadProgress() Class LJCInitialLoadLoaderWizard
	Self:oLblStaV1:SetText( "" )
	Self:oLblSpeV1:SetText( "" )
	Self:oLblPr1Va:SetText( "" )
	Self:oMtrDownl:Set( 0 )
	Self:oMtrDownl:SetTotal(100)	
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} UpdateTablesProgress()

Atualiza na tela o progresso de descompactação e importação da carga
  
@param oTablesProgress Objeto LJCInitialLoadTablesProgress

@return Nil

@author Vendas CRM
@since 07/02/10
/*/
//--------------------------------------------------------------------
Method UpdateTablesProgress( oTablesProgress ) Class LJCInitialLoadLoaderWizard
Local nAtuReg := 0
	
	Do Case
		Case oTablesProgress:nStatus == 1
			Self:oLblStaV2:SetText( STR0043 ) // "Iniciado"
		Case oTablesProgress:nStatus == 2
			Self:oLblStaV2:SetText( STR0044 ) // "Descompactando"
		Case oTablesProgress:nStatus == 3
			Self:oLblStaV2:SetText( STR0045 ) // "Importando"
		Case oTablesProgress:nStatus == 4
			Self:oLblStaV2:SetText( STR0046 ) // "Finalizado"
		Case oTablesProgress:nStatus == 5
			Self:oLblStaV2:SetText( STR0047 ) // "Erro"
		Case oTablesProgress:nStatus == 6
			Self:oLblStaV2:SetText( STR0071 ) // "Gerando arquivo temporário"
	EndCase
	
	If Len(oTablesProgress:aTables) > 0 .And. (oTablesProgress:nActualTable >= 0 .And. oTablesProgress:nActualTable <= Len(oTablesProgress:aTables) )
		Self:oLblTabVa:SetText( oTablesProgress:aTables[oTablesProgress:nActualTable] + " (" + AllTrim(Str(oTablesProgress:nActualTable)) + "/" + AllTrim(Str(Len(oTablesProgress:aTables))) + ")" )
	EndIf
	
	If ValType( oTablesProgress:nActualRecord ) != "U" .And. ValType(oTablesProgress:nTotalRecords) != "U"
		
		
		If oTablesProgress:nActualRecord > 0 .And. oTablesProgress:nTotalRecords > 0

			nAtuReg := Iif (oTablesProgress:nActualRecord >  oTablesProgress:nTotalRecords,oTablesProgress:nTotalRecords,oTablesProgress:nActualRecord)
			Self:oLblPr2Va:SetText( AllTrim(Str(nAtuReg)) + "/" + AllTrim(Str(oTablesProgress:nTotalRecords)) + " (" + AllTrim(Str(Round((nAtuReg*100)/oTablesProgress:nTotalRecords,2))) + "%)" )

			IF oTablesProgress:nActualRecord >= oTablesProgress:nTotalRecords
				Self:oMtrIL:Set(100)	
			ELSEif (oTablesProgress:nActualRecord/oTablesProgress:nTotalRecords) < 0.8
				Self:oMtrIL:Set((oTablesProgress:nActualRecord*100) /oTablesProgress:nTotalRecords)	
			EndIf
			Self:oMtrIL:SetTotal(100)	

		EndIf
	EndIf
	
	If ValType( oTablesProgress:nRecordsPerSecond ) != "U"
		Self:oLblSpeV2:SetText( AllTrim(Str(oTablesProgress:nRecordsPerSecond)) + "r/s" )
	EndIf
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ClearTablesProgress()

Limpa o progress na tela da descompactação e importação da carga

@return Nil

@author Vendas CRM
@since 07/02/10
/*/
//--------------------------------------------------------------------
Method ClearTablesProgress() Class LJCInitialLoadLoaderWizard
	Self:oLblStaV2:SetText( "" )
	Self:oLblTabVa:SetText( "" )
	Self:oLblPr2Va:SetText( "" )			
	Self:oMtrIL:Set( 0 )
	Self:oMtrIL:SetTotal(100)			
	Self:oLblSpeV2:SetText( "" )			
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} FormatSize()

Formata um valor em bytes em um texto para ser exibida amigavelmente.
  
@param nSize Tamanho em bytes

@return cRet Texto amigável

@author Vendas CRM
@since 07/02/10
/*/
//--------------------------------------------------------------------
Method FormatSize( nSize ) Class LJCInitialLoadLoaderWizard
	Local cRet	:= ""

	Do Case
		Case nSize < 1024			
			cRet := Transform(Int(nSize),"9999") + "B"
		Case nSize >= 1024 .And. nSize < 1024*1024
			cRet := Transform(Round(nSize/1024,2),"9999.99") + "KB"
		Case nSize >= 1024*1024 .And. nSize < 1024*1024*1024
			cRet := Transform(Round(nSize/(1024*1024),2),"9999.99") + "MB"			
		Case nSize >= 1024*1024*1024 .And. nSize < 1024*1024*1024*1024
			cRet := Transform(Round(nSize/(1024*1024*1024),2),"9999.99") + "GB"
	EndCase
Return AlLTrim(cRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} CheckFinish()

Verifica se a tela pode ser encerrada. Quando se é utilizado o modo 
express do wizard, se tiver carga mais nova é obrigatório sua 
atualização.
  
@param nSize Tamanho em bytes

@return cRet Texto amigável. 

@author Vendas CRM
@since 23/10/10
/*/
//--------------------------------------------------------------------
Method CheckFinish() Class  LJCInitialLoadLoaderWizard
	Local lRet	:= .T.
	Local oLJCMessageManager := GetLJCMessageManager()
	
	Self:TestConnection()  
	
	If !oLJCMessageManager:HasError()
		If Self:lForcedExecution .And. !Self:lSucceffulExecution
			Aviso( STR0062, STR0063, {STR0064} ) // "Atenção" "É obrigatório a execução da carga!" "OK"
			lRet := .F.
		EndIf
	Else
		If oLJCMessageManager:HasMessage()
			oLJCMessageManager:Show( STR0035 ) // "Houve um erro ao tentar executar a operação."
	   		oLJCMessageManager:Clear() 
	  	EndIf
	   	lRet := .T.
	EndIf
	
Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} CleanTrash()

Apaga todos os arquivos e pastas de cargas que não existem na retaguarda.
Utilizado para apagar dos ambie

@return 

@author Vendas CRM
@since 10/07/2012
/*/
//--------------------------------------------------------------------
Method CleanTrash() Class  LJCInitialLoadLoaderWizard

Local oDelete			:= Nil
Local oLoadResult 	:= LJILLoadResult()


oDelete := LJCInitialLoadDeleteLoad():New(oLoadResult,Nil)
oDelete:CleanClientTrash()

Return


//--------------------------------------------------------------------------------
/*/{Protheus.doc} CheckAutomatic()

No carregamento express da carga, verifica se está configurado para iniciar 
automaticamente o carregamento, e entao inicia sem intervenção do usuário.  

@param lAutomatic Determina se inicia automaticamente ou não o carregamento da 
carga express.

@return Nil

@author Vendas CRM
@since 10/07/2012
/*/
//--------------------------------------------------------------------------------
Method CheckAutomatic( lAutomatic ) Class LJCInitialLoadLoaderWizard
	
If lAutomatic
	Self:LoadStart()
	/* Esta proteção se refere a não apagar os objetos instanciados e seus dados. 
	   Dados que são utilizados posteriormente em testes de conexão na finalização
	   do carga automática
	*/
	If !lAutomatic
		Self:oWizard:NAVIGATOR(0)
	EndIf
EndIf
	
Return 
 
 