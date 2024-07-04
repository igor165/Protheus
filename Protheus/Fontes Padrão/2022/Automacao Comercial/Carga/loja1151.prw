#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA1151.CH"

// O protheus necessita ter ao menos uma fun��o p�blica para que o fonte seja exibido na inspe��o de fontes do RPO.
Function LOJA1151() ; Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     Classe: � LJCInitialLoadMonitor             � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Monitor e gerenciador de carga.                                        ���
���             �                                                                        ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Class LJCInitialLoadMonitor
	Data oPanel
	Data oMtrDownl
	Data oMtrIL	 
	Data oLbxTerminals		
	Data oLblStaLo	
	Data oLblILTab
	Data oLblILRec	
	Data oLblILGen
	Data oLblStaV1
	Data oLblFilVa
	Data oLblSpeV1
	Data oLblPr1Va
	Data oLblStaV2
	Data oLblTabVa
	Data oLblSpeV2
	Data oLblPr2Va				
	Data oClient
	Data oClientILResult
	Data oLblStaFS
	Data oLblFSIP
	Data oLblFSPor
	Data oLblFSEnv
	Data oLblFSURL
	Data oChkAllTerminals //checkbox para marcar ou desmarcar todos os terminais (ambientes)
	            
	Data aLbxTerminalData
	Data aSelection
	Data aoClients
	Data aoILProgress         
	Data aoStatus			//lista de objetos com os status de cargas de cada cliente (ambiente)
	Data aUpdated			//array com a definicao se o cliente (ambiente) esta atualizado (.T.) ou nao (.F.)
	Data aComunicable
	Data aHasChildren
	
	Data oBMPOK			
	Data oBMPNO			
	Data oBMPConectado	
	Data oBMPNaoConectado
	Data oBMPPlus		
	Data oBMPMinus		
	Data oBMPUnknow		
	
	Data oCacheResult  //cache com o ljcinitialloadmakerresult.xml - para evitar lentidao ao atualizar o status de todos os ambientes

	Method New()
	
	// Manuten��o dos clientes
	Method AddClient()
	Method SetClients()
	Method HasClients()
	Method RefreshStatusClient() // verifica o status de um cliente baseado na lista de status por carga e nas cargas disponiveis
	
	// Exibi��o
	Method Show()	
	Method ShowDetail()	
	Method ShowChild()

	// Eventos da janela
	Method ButtonClick()	
	Method ReverseSelection()
	Method ReverseItemSelection()	
	Method OnLineChange()
	
	// A��es               
	Method ClientsTestComunication()
	Method ConfigureTerminalList()
	Method UpdateTerminalList()
	Method LoadStart()
	Method InitClient()
	Method GetChildrenClients()	
	Method GetClientChildren()
	
	// Atualizadores da tela
	Method RefreshClientInformation()
	Method UpdateProgress()
	Method UpdateFilesProgress()
	Method ClearFilesProgress()
	Method UpdateDownloadProgress()
	Method ClearDownloadProgress()
	Method UpdateTablesProgress()
	Method ClearTablesProgress()
	Method UpdateFSStatus()
		
	// Utilit�rios de tela
	Method HasSelected()		
	Method FormatSize()
	Method SelectAll() //marca ou desmarca todos os terminais (ambientes) no grid
	
	Method CheckMBU()
EndClass

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � New                               � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Construtor.                                                            ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � oClient: Cliente que ter� a carga gerenciada.                          ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Self                                                                   ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method New( oClient ) Class LJCInitialLoadMonitor
	Self:oClient				:= oClient	
	
	// Vari�veis de controle de exibi��o
	Self:aoClients			:= {}
	Self:aSelection			:= {}
	Self:aoILProgress  		:= {}
	Self:aoStatus				:= {}
	Self:aUpdated				:= {}
	Self:aComunicable			:= {}
	Self:aLbxTerminalData		:= {}
	Self:aHasChildren			:= {}
	
	// Resources
	Self:oBMPOK					:= LoadBitmap( GetResources(), "LBOK" )
	Self:oBMPNO					:= LoadBitmap( GetResources(), "LBNO" )
	Self:oBMPConectado			:= LoadBitmap( GetResources(), "BPMSEDT3" )
	Self:oBMPNaoConectado		:= LoadBitmap( GetResources(), "BPMSEDT1" )
	Self:oBMPPlus				:= LoadBitmap( GetResources(), "PMSMAIS" )			
	Self:oBMPMinus				:= LoadBitmap( GetResources(), "PMSMENOS" )
	Self:oBMPUnknow				:= LoadBitmap( GetResources(), "PMSEXPCMP" )	
Return               

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � AddClient                         � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Adiciona os clientes filhos do cliente gerenciado.                     ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � oClient: Cliente filho, Objeto LJCInitialLoadClient.                   ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Self                                                                   ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method AddClient( oClient ) Class LJCInitialLoadMonitor
	aAdd( Self:aoClients, oClient )
	aAdd( Self:aSelection, .F. )
	aAdd( Self:aoILProgress, Nil )	
	aAdd( Self:aoStatus, Nil )	
	aAdd( Self:aUpdated, .F. )
	aAdd( Self:aComunicable, .F. )		
	aAdd( Self:aHasChildren, Nil )
Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � SetClients                        � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Configura os filhos do cliente configurado.                            ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � aoClients: Array com os LJCInitialLoadClient.                          ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method SetClients( aoClients ) Class LJCInitialLoadMonitor
	Self:aoClients 				:= aoClients
	Self:aSelection				:= Array( Len( aoClients ) )
	aFill( Self:aSelection, .F. )	
	Self:aoILProgress				:= Array( Len( aoClients ) )
	Self:aoStatus					:= Array( Len( aoClients ) )
	Self:aUpdated					:= Array( Len( aoClients ) )
	aFill( Self:aUpdated, .F. )	
	Self:aComunicable				:= Array( Len( aoClients ) )
	aFill( Self:aComunicable, .F. )
	Self:aHasChildren				:= Array( Len( aoClients ) )
Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � HasClients                        � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Retorna se h� clientes filhos do cliente gerenciado.                   ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method HasClients() Class LJCInitialLoadMonitor
Return Len(Self:aoClients) > 0

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � Show                              � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Exibe a tela do monitor de carga.                                      ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � oPanel: TPanel onde ser� adicionado os componentes de tela.            ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method Show( oPanel ) Class LJCInitialLoadMonitor
	Local cVar						:= ""
	Local aRes						:= GetScreenRes()
	Local nTop						:= 0
	Local nLeft						:= 0
	Local nRight					:= 0
	Local nBottom					:= 0
	Local nTamBar					:= 0
	Local oFWLayer					:= Nil
	Local oLTerminals				:= Nil
	Local oLDownloadProgress		:= Nil
	Local oLLoadProgress			:= Nil
	Local oLLegend					:= Nil	
	Local oLMenu					:= Nil	
	Local oLFSConfiguration			:= Nil
	Local oBar						:= Nil
	Local nMaxCollumn2Pixels		:= 0
	Local nCollumn2Per				:= 0
	Local nMaxWidthCollumn2Pixels	:= 0
	Local nWindowsCollumn2Per		:= 0
	Local oLJMessageManager			:= GetLJCMessageManager()
	Local aCoors					:= FWGetDialogSize(oMainWnd)	
	Local lAllTerminals			:= .F. //recebe valor do checkbox de marcar ou desmarcar todos os ambientes
		
	If oPanel == Nil	
		DEFINE MSDIALOG Self:oPanel TITLE STR0001 + " " + Self:oClient:ToString(" ") FROM aCoors[1],aCoors[2] TO aCoors[3]-100,aCoors[4]-100 PIXEL // "Monitor de carga inicial"
	Else
		Self:oPanel := oPanel		
	EndIf
	
	Self:oPanel:ReadClientCoors(.T.,.T.)	
	
	If oPanel == Nil
		// Calcula em porcentagem o tamanho fixo que quero em pixels
		nMaxCollumn2Pixels := 315
		nCollumn2Per :=  (100*nMaxCollumn2Pixels)/(aCoors[4]-100)
		
		nMaxWidthCollumn2Pixels := 150
		nWindowsCollumn2Per := (100*nMaxWidthCollumn2Pixels)/(aCoors[3]-100)
	Else
		// Calcula em porcentagem o tamanho fixo que quero em pixels
		nMaxCollumn2Pixels := 315
		nCollumn2Per :=  (100*nMaxCollumn2Pixels)/oPanel:nClientWidth
		
		nMaxWidthCollumn2Pixels := 150
		nWindowsCollumn2Per := (100*nMaxWidthCollumn2Pixels)/oPanel:nClientHeight
	EndIf	
	
	// Configura o FWLayer	
	oFWLayer := FWLayer():New()
	oFWLayer:Init( Self:oPanel, .F. )
	
	oFWLayer:AddCollumn( "Coluna 1", 100 - nCollumn2Per )
	oFWLayer:AddWindow( "Coluna 1", "Window 1", STR0002, 100, .F., .T., , , , CONTROL_ALIGN_CENTER ) // "Terminais"
	oLTerminals := oFWLayer:GetWinPanel( "Coluna 1", "Window 1" )	
	
	oFWLayer:AddCollumn( "Coluna 2", nCollumn2Per )	
	oFWLayer:AddWindow( "Coluna 2", "Window 2", STR0004, nWindowsCollumn2Per, .T., .T. )	// "Configura��o do servidor de arquivos"
	oLFSConfiguration := oFWLayer:GetWinPanel( "Coluna 2", "Window 2" )		
	oFWLayer:AddWindow( "Coluna 2", "Window 3", STR0005, nWindowsCollumn2Per, .T., .T. )	// "Download no terminal"
	oLDownloadProgress := oFWLayer:GetWinPanel( "Coluna 2", "Window 3" )
	oFWLayer:AddWindow( "Coluna 2", "Window 4", STR0006, nWindowsCollumn2Per, .T., .T. )	// "Carga no terminal"
	oLLoadProgress := oFWLayer:GetWinPanel( "Coluna 2", "Window 4" )

		
	
	
	// Informa��es do servidor de arquivo	
	@ 000,009 Say STR0012 Size 018,008 COLOR CLR_BLACK PIXEL OF oLFSConfiguration // "Status:"
	@ 010,020 Say STR0013 Size 020,008 COLOR CLR_BLACK PIXEL OF oLFSConfiguration // "IP:"
	@ 020,011 Say STR0014 Size 020,008 COLOR CLR_BLACK PIXEL OF oLFSConfiguration // "Porta:"
	@ 030,001 Say STR0015 Size 028,008 COLOR CLR_BLACK PIXEL OF oLFSConfiguration // "Ambiente:"
	@ 040,013 Say STR0016 Size 028,008 COLOR CLR_BLACK PIXEL OF oLFSConfiguration // "URL:"
	
	@ 000,031 Say Self:oLblStaFS PROMPT "" Size 120,008 COLOR CLR_BLACK PIXEL OF oLFSConfiguration
	@ 010,031 Say Self:oLblFSIP  PROMPT "" Size 120,008 COLOR CLR_BLACK PIXEL OF oLFSConfiguration
	@ 020,031 Say Self:oLblFSPor PROMPT "" Size 120,008 COLOR CLR_BLACK PIXEL OF oLFSConfiguration	
	@ 030,031 Say Self:oLblFSEnv PROMPT "" Size 120,008 COLOR CLR_BLACK PIXEL OF oLFSConfiguration	
	@ 040,031 Say Self:oLblFSURL PROMPT "" Size 120,008 COLOR CLR_BLACK PIXEL OF oLFSConfiguration		
	
	// Informa��es do progresso do download
	@ 000,009 Say STR0017 Size 018,008 COLOR CLR_BLACK PIXEL OF oLDownloadProgress // "Estado:"
	@ 010,007 Say STR0018 Size 021,008 COLOR CLR_BLACK PIXEL OF oLDownloadProgress // "Arquivo:"
	@ 020,000 Say STR0019 Size 028,008 COLOR CLR_BLACK PIXEL OF oLDownloadProgress // "Velocidade:"
	@ 030,000 Say STR0020 Size 028,008 COLOR CLR_BLACK PIXEL OF oLDownloadProgress // "Progresso:"
		
	@ 000,031 Say Self:oLblStaV1 PROMPT "" Size 120,008 COLOR CLR_BLACK PIXEL OF oLDownloadProgress
	@ 010,031 Say Self:oLblFilVa PROMPT "" Size 120,008 COLOR CLR_BLACK PIXEL OF oLDownloadProgress
	@ 020,031 Say Self:oLblSpeV1 PROMPT "" Size 120,008 COLOR CLR_BLACK PIXEL OF oLDownloadProgress
	@ 030,031 Say Self:oLblPr1Va PROMPT "" Size 120,008 COLOR CLR_BLACK PIXEL OF oLDownloadProgress
	@ 040,000 METER Self:oMtrDownl Var cVar Size 147,008 NOPERCENTAGE PIXEL OF oLDownloadProgress
	
	// Informa��es do processo de carga
	@ 000,009 Say STR0021 Size 018,008 COLOR CLR_BLACK PIXEL OF oLLoadProgress // "Estado:"
	@ 010,007 Say STR0022 Size 018,008 COLOR CLR_BLACK PIXEL OF oLLoadProgress // "Tabela:"
	@ 020,000 Say STR0023 Size 028,008 COLOR CLR_BLACK PIXEL OF oLLoadProgress // "Velocidade:"
	@ 030,000 Say STR0024 Size 028,008 COLOR CLR_BLACK PIXEL OF oLLoadProgress // "Progresso:"
				
	@ 000,031 Say Self:oLblStaV2 PROMPT "" Size 120,008 COLOR CLR_BLACK PIXEL OF oLLoadProgress
	@ 010,031 Say Self:oLblTabVa PROMPT "" Size 120,008 COLOR CLR_BLACK PIXEL OF oLLoadProgress
	@ 020,031 Say Self:oLblSpeV2 PROMPT "" Size 120,008 COLOR CLR_BLACK PIXEL OF oLLoadProgress
	@ 030,031 Say Self:oLblPr2Va PROMPT "" Size 120,008 COLOR CLR_BLACK PIXEL OF oLLoadProgress
	@ 040,000 METER Self:oMtrIL Var cVar Size 147,008 NOPERCENTAGE PIXEL OF oLLoadProgress
		
	// Terminais
	@ 09,09 LISTBOX Self:oLbxTerminals VAR cVar FIELDS HEADER " ", " ", " ", " ", " ", STR0025, STR0026, STR0027 SIZE 330,150 OF oLTerminals PIXEL // "Localiza��o" "Porta" "Ambiente" 
	@ 010,010 CHECKBOX Self:oChkAllTerminals VAR lAllTerminals PROMPT STR0080 SIZE 150, 008 OF oLTerminals COLORS 0, 16777215 PIXEL ON CHANGE Self:SelectAll(lAllTerminals) //Marcar / desmarcar todos
	
	Self:oLbxTerminals:Align := CONTROL_ALIGN_ALLCLIENT
	Self:oChkAllTerminals:Align := CONTROL_ALIGN_BOTTOM
	Self:ConfigureTerminalList()
		
	oBar := FWButtonBar():new()
	oBar:Init( oLTerminals, 018, 015, CONTROL_ALIGN_TOP )
	If !Left(GetVersao(.F.),3) == "P10"
		oBar:SetBackGround( "fw_pxl_eaf1f6.png", 000, 000, .T. )
	EndIf
	oBar:AddBtnImage( "NEXT", STR0030, {||MsgRun( STR0031, STR0032, {|| Self:ButtonClick(1) } )}, , ,  )
	oBar:AddBtnImage( "PMSRRFSH", STR0034, {||MsgRun( STR0035, STR0032, {|| Self:ButtonClick(2) } )}, , ,  )
	oBar:AddBtnImage( "pmsinfo", STR0038, {||Self:ButtonClick(3)}, , ,  )
	oBar:AddBtnImage( "PMSZOOMIN", STR0037, {||Self:ButtonClick(4)}, , ,  )
	oBar:AddBtnImage( "AVGBOX1", STR0081, {|| Self:ButtonClick(5) }, , ,  )	
	oBar:AddBtnImage( "BMPDEL", STR0082, {|| Self:ButtonClick(6) }, , ,  )	
			 	
	MsgRun( STR0041, STR0032, {|| Self:GetChildrenClients() } ) // "Pegando dependentes do ambiente a ser visualizado." "Aguarde..."
	/*
	If Self:HasClients()
		MsgRun( STR0043, STR0032, {|| Self:ClientsTestComunication() } ) // "Testando conex�o com clientes." "Aguarde..."
	EndIf
	*/
	
	MsgRun( STR0044, STR0032, {|| Self:UpdateTerminalList() } ) // "Atualizando lista de terminais." "Aguarde..."
	MsgRun( STR0046, STR0032, {|| Self:UpdateFSStatus() } ) // "Atualizando status do servidor de arquivos." "Aguarde..."
		 
	 
	If oPanel == Nil	
		ACTIVATE MSDIALOG Self:oPanel CENTERED
	EndIf
	
	
	
	
Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � ShowDetail                        � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Exibe a mensagem detalhada do erro gerado por um comando no cliente    ���
���             � filho.                                                                 ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � nClient: �ndice do cliente.                                            ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method ShowDetail( nClient ) Class LJCInitialLoadMonitor
	Local oDlgII				:= Nil
	Local oFntTit				:= Nil
	Local oFntMsg				:= Nil
	Local oBmp					:= Nil
	Local oMsgDet				:= Nil
	
	DEFINE MSDIALOG oDlgII TITLE STR0047 FROM 0,0 TO 300,600 PIXEL // "Detalhes"
	
	DEFINE FONT oFntTit NAME "Arial"  SIZE 6,16	BOLD
	DEFINE FONT oFntMsg NAME "Arial"  SIZE 5,15
	
	@ 0,0  BITMAP oBmp RESNAME "LOGIN" oF oDlgII SIZE 100,600 NOBORDER WHEN .F. PIXEL
	@05,50 TO 130,300 PROMPT STR0048 PIXEL // "Informa��o"
	@11,52 GET Self:aoILProgress[nClient]:oMessage:ToString() FONT oFntMsg MULTILINE NOBORDER READONLY HSCROLL SIZE 245,115 PIXEL
	
	@135,270 BUTTON "OK" PIXEL ACTION oDlgII:End()
	
	ACTIVATE MSDIALOG oDlgII CENTERED
Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � ShowChild                         � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Abre um novo monitor para gerenciar a carga do filho selecionado.      ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � nClient: �ndice do cliente.                                            ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method ShowChild( nClient ) Class LJCInitialLoadMonitor
	Local oMonitor			:= Nil
	Local oLJCMessageManager	:= GetLJCMessageManager()
	
	MsgRun( STR0049, STR0032, {|| Self:GetClientChildren( nClient ) } ) // "Verificando dependentes do ambiente a ser visualizado." "Aguarde..."
	
	If !oLJCMessageManager:HasError()
		If Self:aHasChildren[nClient] != Nil .And. Self:aHasChildren[nClient]
			oMonitor := LJCInitialLoadMonitor():New( Self:aoClients[nClient] )
			oMonitor:Show()
		Else
			Alert( STR0050 ) // "O terminal selecionado n�o tem dependentes."
		EndIf			
	EndIf
Return                     

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � ButtonClick                       � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � M�todo que recebe os eventos de clique do monitor.                     ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � oSender: Componente que gerou o evento de clique.                      ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method ButtonClick( nButton ) Class LJCInitialLoadMonitor
	Local oLJCMessageManager := GetLJCMessageManager()
	Local nCount			:= 0

	Do Case
		Case nButton == 1
			Self:LoadStart()
		Case nButton == 2
			Self:oCacheResult := Nil //limpa o resultado cacheado para garantir que vai pegar atualizado	
			If Self:HasClients()
				If Self:HasSelected()
					For nCount := 1 To Len( Self:aSelection )
						If Self:aSelection[nCount]
							Self:RefreshClientInformation( nCount )
						EndIf
					Next
				Else
					Self:RefreshClientInformation( Self:oLbxTerminals:nAt )
				EndIf
			EndIf
		Case nButton == 3
			// Verifica se h� alguma mensagem para o Client		
			If Self:HasClients() .And. Len(Self:aoILProgress) >= Self:oLbxTerminals:nAt .And. Self:aoILProgress[Self:oLbxTerminals:nAt] != Nil .And. Self:aoILProgress[Self:oLbxTerminals:nAt]:oMessage != Nil
				Self:ShowDetail( Self:oLbxTerminals:nAt )
			Else
				Alert( STR0052 ) // "N�o h� detalhes do terminal selecionado."
			EndIf
		Case nButton == 4
			// Verifica se h� alguma mensagem para o Client
			If Self:HasClients() 
				If !oLJCMessageManager:HasError()
					Self:ShowChild( Self:oLbxTerminals:nAt )
				EndIf
			Else
				Alert( STR0053 ) // "N�o h� dependentes no terminal selecionado."
			EndIf
		Case nButton == 5
			LOJA1156()
		Case nButton == 6
			LOJA1176()
	
	EndCase
	
	If oLJCMessageManager:HasMessage()
		oLJCMessageManager:Show( STR0054 ) // "Houve um erro ao tentar executar a opera��o."
		oLJCMessageManager:Clear()		
	Else
		// Atualiza lista dos clientes
		Self:UpdateTerminalList()	
	EndIf	
Return



/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � ReverseItemSelection              � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Reverte a sele��o do item.                                             ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method ReverseItemSelection() Class LJCInitialLoadMonitor
	Local nItem := Self:Self:oLbxTerminals:nAt
	Self:aSelection[nItem] := !Self:aSelection[nItem]
	
	Self:UpdateTerminalList()
Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � ReverseSelection                  � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Reverte a sele��o dos items.                                           ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method ReverseSelection() Class LJCInitialLoadMonitor
	Local nCount	:= 1
	Local lSelect	:= Nil
	
	For nCount := 1 To Len( Self:aSelection )
		If lSelect == Nil
			lSelect := !Self:aSelection[nCount]
		End
		Self:aSelection[nCount] := lSelect
	Next
	
	Self:UpdateTerminalList()
Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � OnLineChange                      � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � M�todo que recebe os eventos de mudan�a de linha.                      ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method OnLineChange() Class LJCInitialLoadMonitor	
	If Self:HasClients()
		// Atualiza estado da carga inicial
		Self:ClearFilesProgress()
		Self:ClearTablesProgress()
		
		// Se o cliente j� tiver um progress conhecido anotado, informa na tela, se n�o o usu�rio dever� utilizar o bot�o Atualizar para pegar o estado do cliente
		If Self:aoILProgress[Self:oLbxTerminals:nAt] != Nil
			Self:UpdateProgress( Self:aoILProgress[Self:oLbxTerminals:nAt] )
		EndIf
			
		// For�a refresh da tela
		Self:oPanel:Refresh()
	EndIf
Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � ClientsTestComunication           � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Testa a comunica��o com os clientes filhos.                            ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method ClientsTestComunication() Class LJCInitialLoadMonitor
	Local oLJCMessageManager	:= GetLJCMessageManager()
	Local oLJMessenger			:= Nil
	Local nCount				:= 0
	Local lResult
	
	For nCount := 1 To Len( Self:aoClients )
		oLJMessenger := LJCInitialLoadMessenger():New( Self:aoClients[nCount] )
		lResult := oLJMessenger:CheckCommunication()
		If !oLJCMessageManager:HasError()
			Self:aComunicable[nCount] := lResult
		Else
			Self:aComunicable[nCount] := .F.
		EndIf
		
		oLJCMessageManager:Clear()
	Next
	

Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � ConfigureTerminalList             � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Configura o listbox com a lista de terminais.                          ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method ConfigureTerminalList() CLass LJCInitialLoadMonitor
	Self:oLbxTerminals:SetArray( {} )
	Self:oLbxTerminals:bLine := 	{||	{	;
										LoadBitmap( GetResources(), "LBNO" )		,;
										LoadBitmap( GetResources(), "BPMSEDT1" )	,;
										""											,;
										LoadBitmap( GetResources(), "BR_CINZA" )	,;
										""											,;
										LoadBitmap( GetResources(), "PMSEXPCMP" )	,;
										""											,;
										""											,;
										""                                          ,;
										""											;
										}	;
									}
	Self:oLbxTerminals:bChange := {|| Self:OnLineChange() }
	Self:oLbxTerminals:bLDblClick := {|| Self:ReverseItemSelection() }
	Self:oLbxTerminals:bHeaderClick := { |oObj, nCol| If( nCol == 1, Self:ReverseSelection(), ) }									
Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � UpdateTerminalList                � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Atualiza as informa��es exibidas das listas de terminais.              ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method UpdateTerminalList() Class LJCInitialLoadMonitor
	Local bLine				:= Nil
	Local nCount			:= 0
	Local aTemp				:= {}			
	
	If Len(Self:aoClients) > 0	         
		// Monta array com as informa��es de cada cliente
		Self:aLbxTerminalData	:= {}	
		For nCount := 1 To Len( Self:aoClients )
			aTemp := Array(11)
			
			// Se o item est� selecionado ou n�o
			If Len(Self:aSelection) >= nCount
				If Self:aSelection[nCount]
					aTemp[1] := Self:oBMPOK
				Else
					aTemp[1] := Self:oBMPNO
				EndIf
			EndIf 		
			
			// Se houve comunica��o com o cliente
			If Len(Self:aComunicable) >= nCount
				If Self:aComunicable[nCount]
					aTemp[2] := Self:oBMPConectado
					aTemp[3] := STR0055 // "Conectado"
				Else
					aTemp[2] := Self:oBMPNaoConectado
					aTemp[3] := STR0056 // "N�o conectado"
				EndIf
			EndIf 
			
			// Status da carga inicial no cliente
			If Len(Self:aoILProgress) >= nCount .And. Self:aoILProgress[nCount] != Nil
				aTemp[4] := LoadBitmap( GetResources(), Self:aoILProgress[nCount]:GetStepBMPName() )
				aTemp[5] := Self:aoILProgress[nCount]:GetStepName()				
			Else
				aTemp[4] := LoadBitmap( GetResources(), "BR_CINZA" )
				aTemp[5] := STR0064 // "Sem informa��o"
			EndIf		
			
			// Se o cliente tem filhos
			/*If Len(Self:aHasChildren) >= nCount .And. !Self:aHasChildren[nCount] = Nil
				If Self:aHasChildren[nCount]
					aTemp[6] := Self:oBMPPlus
					aTemp[7] := STR0065 // "Com dependentes"
				Else
					aTemp[6] := Self:oBMPMinus 
					aTemp[7] := STR0066 // "Sem dependentes"
				EndIf
			Else
				aTemp[6] := Self:oBMPUnknow
				aTemp[7] := STR0064 // "Sem informa��o"
			EndIf
			*/
			aTemp[6] := Self:aoClients[nCount]:cLocation
			aTemp[7] := AllTrim(Str(Self:aoClients[nCount]:nPort))
			aTemp[8] := Self:aoClients[nCount]:cEnvironment
			
			aAdd( Self:aLbxTerminalData, aClone(aTemp) )
		Next
			
		// Protege contra estouro de �ndice
		Self:oLbxTerminals:nAt := If(Self:oLbxTerminals:nAt <= 0							, Self:oLbxTerminals:nAt := 1, nil /*Self:oLbxTerminals:nAt*/ )
		Self:oLbxTerminals:nAt := If(Self:oLbxTerminals:nAt > Len( Self:aLbxTerminalData )	, Self:oLbxTerminals:nAt := 1, nil /*Len( Self:aLbxTerminalData )*/ )
		
		// Configura o array do listbox
		Self:oLbxTerminals:SetArray( Self:aLbxTerminalData )		
		
		bLine := 	{||	(If( Len(Self:aLbxTerminalData) <= Self:oLbxTerminals:nAt, Self:oLbxTerminals:nAt := Len(Self:aLbxTerminalData),),;
							Self:aLbxTerminalData[Self:oLbxTerminals:nAt];
						);
					}
					
		Self:oLbxTerminals:bLine := bLine
	
		Self:oLbxTerminals:Refresh()
	Else
		Self:ConfigureTerminalList()
	EndIf
	
	
Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � LoadStart                         � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Exibe o di�logo com as op��es para solicita��o de carga e importa��o.  ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/              
Method LoadStart() Class LJCInitialLoadMonitor
	Local oDlg				:= Nil
	Local oActInChildren	:= Nil
	Local lActInChildren	:= .F.
	Local oCancel			:= Nil
	Local oDownload			:= Nil
	Local lDownload			:= .F.
	Local oExecute			:= Nil
	Local oImport			:= Nil
	Local lImport			:= .F.
	Local oKillOtherThreads	:= Nil
	Local lKillOtherThreads := .F.
	Local oText				:= Nil	
	Local lExecute			:= .F.
	Local nCount				:= 1
	
	
	Local oSelectLoads	 	:= Nil
	Local oUpdateAll		:= Nil
	Local oRequest		:= Nil
	Local oLJILResult 	:= Nil
	Local lUpdateAll		:= .F.
	Local oLJMessenger		:= Nil
	Local oLJCMessageManager	:= GetLJCMessageManager()
	Local oSelectorClient		:= Nil  
	Local lShowStatus			:= .T. //define se mostra status na tela de selecao de cargas
	Local nQtySelectedClients	:=0
	Local lImport				:= .F.
	Local lDownload			:= .F.
	Local lActInChildren		:= .F.
	Local lKillOtherThreads	:= .F.
	 	
	//se selecionou apenas um cliente, passa ele para o selecionador e analisa o status dele, senao , nao exibe status
	
	For nCount := 1 To Len( Self:aSelection )
		If Self:aSelection[nCount]
			nQtySelectedClients++
			oSelectorClient := Self:aoClients[nCount] 
		EndIf
	Next nCount

	If nQtySelectedClients == 1
		lShowStatus := .T. 
	Else
		oSelectorClient := nil
		lShowStatus := .F. //quando tiver varios ambientes selecionados, esconde o status das cargas
	EndIf 
	 
	lImport				:= If(GetMV( "MV_LJILLIM",,"0" )=="1", .T., .F.)
	lDownload				:= If(GetMV( "MV_LJILLDO",,"0" )=="1", .T., .F.)	
	lActInChildren		:= If(GetMV( "MV_LJILLAC",,"0" )=="1", .T., .F.)
	lKillOtherThreads		:= If(GetMV( "MV_LJILLKT",,"0" )=="1", .T., .F.) 
	 
	oLJILResult := LJILLoadResult()
   	oRequest := LJCInitialLoadRequest():New(oLJILResult, oSelectorClient, lDownload, lImport, lActInChildren, lKillOtherThreads)
	oSelectorLoad := LJCInitialLoadSelector():New(oLJILResult, oRequest, lShowStatus)	
	oSelectorLoad:DefineGroupStatusClient(oSelectorClient) //define o array de status para o cliente selecionado (se estiver selecionado apenas um cliente) 
                                
	DEFINE MSDIALOG oDlg TITLE STR0057 FROM 000, 000  TO 195, 280 COLORS 0, 16777215 PIXEL // "Iniciar carga"

    @ 015, 045 BUTTON oSelectLoads PROMPT STR0083 SIZE 050, 012 OF oDlg PIXEL ACTION (	MsgRun( STR0086, STR0032, {|| oSelectorLoad:Show() } )  , oDlg:End()) // "Selecionar Cargas"
    @ 035, 045 BUTTON oUpdateAll PROMPT STR0084 SIZE 050, 012 OF oDlg PIXEL ACTION (lUpdateAll := .T. , oSelectorLoad:lExecute := .T. , oDlg:End()) // "Atualizar Tudo"
    @ 055, 045 BUTTON oUpdateAll PROMPT STR0085 SIZE 050, 012 OF oDlg PIXEL ACTION ( oRequest:lLoadPSS := .T., oSelectorLoad:lExecute := .T. , oDlg:End()) // "Atualizar Tudo"
    @ 075, 045 BUTTON oCancel PROMPT STR0051 SIZE 050, 012 OF oDlg PIXEL ACTION (oDlg:End()) // "Cancelar"
    
	ACTIVATE MSDIALOG oDlg CENTERED
	
	If oSelectorLoad:lExecute
		If Self:HasClients()
			If Self:HasSelected()
				
				If lUpdateAll //se for atualizar todo o ambiente (sem selecionar manualmente as cargas)
					oSelectorLoad:SelectActions() //define as opcoes Download, import, aplicar nos filhos, matar outras threads
				EndIf
				
				For nCount := 1 To Len( Self:aSelection )
					If Self:aSelection[nCount]
					
						If lUpdateAll //se for atualizar todo o ambiente (sem selecionar manualmente as cargas)
							oSelectorLoad:MarkIncLoad(Self:aoClients[nCount])		
						EndIf
						
						Self:InitClient( Self:aoClients[nCount], oRequest:lDownload, oRequest:lImport, oRequest:lActInChildren, oRequest:lKillOtherThreads, oRequest:aSelection, lUpdateAll, oRequest:lLoadPSS )
						
					EndIf
				Next
			Else
				Self:InitClient( Self:aoClients[Self:oLbxTerminals:nAt],  oRequest:lDownload, oRequest:lImport, oRequest:lActInChildren, oRequest:lKillOtherThreads, oRequest:aSelection, lUpdateAll, oRequest:lLoadPSS)
			EndIf
		EndIf
	
	PutMV( "MV_LJILLIM", If(oRequest:lImport,"1","0") )	
	PutMV( "MV_LJILLDO", If(oRequest:lDownload,"1","0") )	
	PutMV( "MV_LJILLAC", If(oRequest:lActInChildren,"1","0") )	
	PutMV( "MV_LJILLKT", If(oRequest:lKillOtherThreads,"1","0") )		
		
	EndIf
	
	
	
Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � InitClient                        � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Inicia a carga em um cliente filho.                                    ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � oClient: LJCInitialLoadClient que deve ser iniciado.                   ���
���             � lDownload: .T. para efetuar o download no cliente, .F. n�o.            ���
���             � lImport: .T. para efetuar importa��o no cliente, .F. n�o.              ���
���             � lActInChildren: .T. para replicar a��o para os filhos, .F. n�o.        ���
���             � lKillOtherThreads: .T. para se necess�rio derrubar os processos,       ���
���             � .F. n�o                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method InitClient( oClient, lDownload, lImport, lActInChildren, lKillOtherThreads, aLoadSelection, lUpdateAll, lLoadPSS ) Class LJCInitialLoadMonitor
	Local oLJCMessageManager	:= GetLJCMessageManager()
	Local oRequester			:= LJCInitialLoadChildRequester():New( Self:oClient, lDownload, lImport, lActInChildren, lKillOtherThreads, aLoadSelection, lLoadPSS )
	
	//no Requester passa o pai como client
	//no StartIL passa o filho que vai receber a carga, ou nil para aplicar em todos os filhos do pai definido
	oRequester:StartIL( oClient, lUpdateAll )
	
	If oLJCMessageManager:HasError()
		oLJCMessageManager:Show( STR0067 ) // "N�o foi poss�vel iniciar a carga."
		oLJCMessageManager:Clear()
	EndIf
Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � GetChildrenClients                � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Pega a lista de clientes filhos do cliente atual.                      ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                       '                                        ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method GetChildrenClients() Class LJCInitialLoadMonitor
	Local oLJCMessageManager:= GetLJCMessageManager()
	Local oLJMessenger		:= LJCInitialLoadMessenger():New( Self:oClient )
	Local aoClients			:= {}
	
	If !oLJCMessageManager:HasError()
		aoClients := oLJMessenger:GetChildren()
		Self:SetClients( aoClients )
	EndIf
	
	If oLJCMessageManager:HasMessage()
		oLJCMessageManager:Show( STR0068 ) // "N�o foi poss�vel obter os ambientes dependentes do ambiente atual."
		oLJCMessageManager:Clear()
	EndIf
Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � GetClientChildren                 � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Pega os clientes filhos de um cliente filho.                           ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � nClient: �ndice do cliente filho.                                      ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method GetClientChildren( nClient ) Class LJCInitialLoadMonitor
	Local oLJCMessageManager		:= GetLJCMessageManager()
	Local oLJMessenger			:= Nil
	Local aoChildrenClients		:= {}	
		
	// Verifica se j� se tem a informa��o se o cliente tem dependentes ou n�o
	If Self:aHasChildren[nClient] == Nil
		oLJMessenger := LJCInitialLoadMessenger():New( Self:aoClients[nClient] )	
		aoChildrenClients := oLJMessenger:GetChildren()
		
		If !oLJCMessageManager:HasError()
			If Len( aoChildrenClients ) > 0
				Self:aHasChildren[nClient] := .T.
			Else
				Self:aHasChildren[nClient] := .F.
			EndIf
		EndIf
	EndIf
Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � UpdateProgress                    � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Atualiza o progresso da baixa e da carga na tela.                      ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � oProgress: Objeto LJCInitialLoadProgress com o progresso do filho.     ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method UpdateProgress( oProgress ) Class LJCInitialLoadMonitor	
	Local nPos := 0

	// Se existir o progresso do download, atualiza UI
	If oProgress:oFilesProgress != Nil
		Self:UpdateFilesProgress( oProgress:oFilesProgress )
	EndIf
	
	// Se existir o progress da carga dos dados, atualiza UI
	If oProgress:oTablesProgress != Nil
		Self:UpdateTablesProgress( oProgress:oTablesProgress )
	EndIf
	
	// Atualiza progresso geral do cliente
	nPos := aScan( Self:aoClients, {|x| x==oProgress:oClient } )
	
	If nPos > 0
		Self:aoILProgress[nPos] := oProgress
	EndIf
	
	Self:oPanel:Refresh()
Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � RefreshClientInformation          � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Efetua a requisi��o do progresso da baixa e da carga do cliente, e     ���
���             � atualiza a tela com as informa��es.                                    ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � nClient: �ndice do cliente filho.                                      ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method RefreshClientInformation( nClient ) Class LJCInitialLoadMonitor
	Local oLJCMessageManager		:= GetLJCMessageManager()
	Local oLJMessenger			:= Nil
	Local oProgress				:= Nil
	Local oLJILResult			:= Nil
	
	// Sempre pega o progresso da carga inicial
	oLJMessenger := LJCInitialLoadMessenger():New( Self:aoClients[nClient] )	
	
	If oLJMessenger:CheckCommunication() //testa comunicacao
		oProgress := oLJMessenger:GetProgress()
		If !oLJCMessageManager:HasError()
			
			Self:aComunicable[nClient] := .T.
			
			Self:UpdateProgress( oProgress )
			
			//avalia e define cliente como atualizado ou desatualizado
			Self:RefreshStatusClient( nClient )
			Self:aoILProgress[nClient]:lClientUpdated := Self:aUpdated[nClient] 
			
		EndIf
	Else
		oLJCMessageManager:Clear()
	EndIf
	
Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � UpdateFilesProgress               � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Atualiza o progresso da baixa dos arquivos no cliente filho.           ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � oFilesProgress: Objeto LJCInitialLoadFilesProgress                     ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method UpdateFilesProgress( oFilesProgress ) Class LJCInitialLoadMonitor
	If oFilesProgress:oDownloadProgress != Nil
		Self:UpdateDownloadProgress( oFilesProgress:oDownloadProgress )
	EndIf
	
	If Len( oFilesProgress:aFiles ) > 0 .And. oFilesProgress:nActualFile <= Len( oFilesProgress:aFiles )
		Self:oLblFilVa:SetText( oFilesProgress:aFiles[oFilesProgress:nActualFile] + " (" + AllTrim(Str(oFilesProgress:nActualFile))  + "/" + AllTrim(Str(Len( oFilesProgress:aFiles ))) + ")")	
	EndIf
Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � UpdateFSStatus                    � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Atualiza a tela com as informa��es da disponibilidade do servidor      ���
���             � de arquivos do loja.                                                   ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method UpdateFSStatus() Class LJCInitialLoadMonitor
	Local oLJCMessageManager	:= GetLJCMessageManager()
	Local oLJMessenger			:= Nil
	Local oLJFSConfiguration	:= Nil
	Local lStatusRetrieved		:= .F.
	
	oLJMessenger := LJCInitialLoadMessenger():New( Self:oClient )
	
	If !oLJCMessageManager:HasError()
		oLJFSConfiguration	:= oLJMessenger:GetFSConfiguration()		
		
		If !oLJCMessageManager:HasError() .And. oLJFSConfiguration != Nil
                                               
			If oLJFSConfiguration:Validate()
				Self:oLblStaFS:SetText( STR0072 ) // "Habilitado"
			Else
				Self:oLblStaFS:SetText( STR0073 ) // "N�o habilitado"
			EndIf
			Self:oLblFSIP:SetText( AllTrim(oLJFSConfiguration:GetFSLocation()) )
			Self:oLblFSPor:SetText( AllTrim(oLJFSConfiguration:GetHTTPPort()) )
			Self:oLblFSEnv:SetText( AllTrim(oLJFSConfiguration:GetHTTPEnvironment()) )
			Self:oLblFSURL:SetText( AllTrim(oLJFSConfiguration:GetFileServerURL()) )
			lStatusRetrieved := .T.

		EndIf
	EndIf
	
	If !lStatusRetrieved
		Self:oLblStaFS:SetText( STR0073 ) // "N�o habilitado"
	EndIf
	
	If oLJCMessageManager:HasMessage()
		oLJCMessageManager:Show( STR0074 ) // "N�o foi poss�vel pegar o status do servidor de arquivos."
		oLJCMessageManager:Clear()
	EndIf
Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � ClearFilesProgress                � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Limpa o progresso da baixa dos arquivo de carga no cliente.            ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method ClearFilesProgress() Class LJCInitialLoadMonitor
	Self:ClearDownloadProgress()

	Self:oLblFilVa:SetText( "" )		
Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � UpdateDownloadProgress            � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Atualiza na tela o progresso da baixa do arquivo.                      ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � oDownloadProgress: Objeto LJCFileDownloaderDownloadProgress.           ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method UpdateDownloadProgress( oDownloadProgress ) Class LJCInitialLoadMonitor
	Do Case
		Case oDownloadProgress:nStatus == 1
			Self:oLblStaV1:SetText( STR0075 ) // "Iniciado"
		Case oDownloadProgress:nStatus == 2
			Self:oLblStaV1:SetText( STR0076 ) // "Baixando"
		Case oDownloadProgress:nStatus == 3
			Self:oLblStaV1:SetText( STR0077 ) // "Finalizado"
		Case oDownloadProgress:nStatus == 4
			Self:oLblStaV1:SetText( STR0057 ) // "Erro"
	End
	
	Self:oLblSpeV1:SetText( Self:FormatSize( oDownloadProgress:NBYTESPERSECOND) + "/s" )
	Self:oLblPr1Va:SetText( Self:FormatSize( oDownloadProgress:NDOWNLOADEDBYTES) + "/" + Self:FormatSize( oDownloadProgress:NTOTALBYTES) + " (" +  AllTrim(Str(Round((oDownloadProgress:NDOWNLOADEDBYTES*100)/oDownloadProgress:NTOTALBYTES,2))) + "%)" )
	Self:oMtrDownl:Set( (oDownloadProgress:NDOWNLOADEDBYTES*100)/oDownloadProgress:NTOTALBYTES )
	Self:oMtrDownl:SetTotal(100)
Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � ClearDownloadProgress             � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Limpa o progresso de download na tela.                                 ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method ClearDownloadProgress() Class LJCInitialLoadMonitor
	Self:oLblStaV1:SetText( "" )
	Self:oLblSpeV1:SetText( "" )
	Self:oLblPr1Va:SetText( "" )
	Self:oMtrDownl:Set( 0 )
	Self:oMtrDownl:SetTotal(100)	
Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � UpdateTablesProgress              � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Atualiza na tela o progress do importa��o da carga.                    ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � oTablesProgress: Objeto LJCInitialLoadTablesProgress.                  ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method UpdateTablesProgress( oTablesProgress ) Class LJCInitialLoadMonitor
	Do Case
		Case oTablesProgress:nStatus == 1
			Self:oLblStaV2:SetText( STR0075 ) // "Iniciado"
		Case oTablesProgress:nStatus == 2
			Self:oLblStaV2:SetText( STR0078 ) // "Descompactando"
		Case oTablesProgress:nStatus == 3
			Self:oLblStaV2:SetText( STR0079 ) // "Importando"
		Case oTablesProgress:nStatus == 4
			Self:oLblStaV2:SetText( STR0077 ) // "Finalizado"
		Case oTablesProgress:nStatus == 5
			Self:oLblStaV2:SetText( STR0057 ) // "Erro"
	EndCase
	
	If Len(oTablesProgress:aTables) > 0 .And. (oTablesProgress:nActualTable >= 0 .And. oTablesProgress:nActualTable <= Len(oTablesProgress:aTables) )
		Self:oLblTabVa:SetText( oTablesProgress:aTables[oTablesProgress:nActualTable] + " (" + AllTrim(Str(oTablesProgress:nActualTable)) + "/" + AllTrim(Str(Len(oTablesProgress:aTables))) + ")" )
	EndIf
	
	If ValType( oTablesProgress:nActualRecord ) != "U" .And. ValType(oTablesProgress:nTotalRecords) != "U"
		If oTablesProgress:nActualRecord > 0 .And. oTablesProgress:nTotalRecords > 0
			Self:oLblPr2Va:SetText( AllTrim(Str(oTablesProgress:nActualRecord)) + "/" + AllTrim(Str(oTablesProgress:nTotalRecords)) + " (" + AllTrim(Str(Round((oTablesProgress:nActualRecord*100)/oTablesProgress:nTotalRecords,2))) + "%)" )
			
			Self:oMtrIL:Set( (oTablesProgress:nActualRecord*100)/oTablesProgress:nTotalRecords )
			Self:oMtrIL:SetTotal(100)		
		EndIf
	EndIf
	
	If ValType( oTablesProgress:nRecordsPerSecond ) != "U"
		Self:oLblSpeV2:SetText( AllTrim(Str(oTablesProgress:nRecordsPerSecond)) + "r/s" )
	EndIf
Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � ClearTablesProgress               � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Limpa o progresso da importa��o da carga.                              ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum.                                                                ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � Nil                                                                    ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method ClearTablesProgress() Class LJCInitialLoadMonitor
	Self:oLblStaV2:SetText( "" )
	Self:oLblTabVa:SetText( "" )
	Self:oLblPr2Va:SetText( "" )			
	Self:oMtrIL:Set( 0 )
	Self:oMtrIL:SetTotal(100)			
	Self:oLblSpeV2:SetText( "" )			
Return

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � FormatSize                        � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Formata um valor em bytes em um texto para ser exibida amigavelmente.  ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � nSize: Tamanho em bytes.                                               ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � cRet: Texto amig�vel.                                                  ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method FormatSize( nSize ) Class LJCInitialLoadMonitor
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

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � HasSelected                       � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Retorna se o h� algum cliente filho selecionado.                       ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � Nenhum                                                                 ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � lHasSelected: .T. se h�, .F. se n�o.                                   ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method HasSelected() Class LJCInitialLoadMonitor
	Local nCount		:= 0
	Local lHasSelected	:= .F.
	
	For nCount := 1 To Len( Self:aSelection )
		If Self:aSelection[nCount]
			lHasSelected := .T.
			Exit
		EndIf
	Next
Return lHasSelected


/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � RefreshStatusClient               � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Atualiza o status do cliente                       ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � nClient: indice do array de clientes                                   ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � nenhum                              ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method RefreshStatusClient(nClient) Class LJCInitialLoadMonitor

Local oLJCMessageManager	:= GetLJCMessageManager()
Local oLJMessenger			:= Nil
Local lClientUpdated 		:= .T.
Local lTempFound			:= .F.	// flag temporaria para determinar se encontrou o status de importado para a carga procurada
Local nCount				:= 0
Local nCountStatus			:= 0

If Self:oCacheResult == Nil
	Self:oCacheResult := LJILLoadResult()
EndIf	
		

//Define a lista de status das cargas do cliente
oLJMessenger := LJCInitialLoadMessenger():New( Self:aoClients[nClient] )
If !oLJCMessageManager:HasError()	
	Self:aoStatus[nClient] := oLJMessenger:GetStatusLoad()
EndIf

//percorre a lista de cargas disponiveis no servidor
//para cada carga procura por ela na lista de status do cliente 
//Se em alguma carga NAO encontrar o status de importado, considera desatualizado.
For nCount := 1 to Len(Self:oCacheResult:aoGroups) //percorre lista de cargas disponiveis
	
	If Self:oCacheResult:aoGroups[nCount]:cEntireIncremental == "2" //so avalia carga incremental
	
		lTempFound := .F.
		For nCountStatus := 1 to Len(Self:aoStatus[nClient]:aoStatus) //percorre lista de status das cargas do cliente (ambiente)
			//procura o status da carga na lista e verifica se esta importada
			If (Self:oCacheResult:aoGroups[nCount]:cCode == Self:aoStatus[nClient]:aoStatus[nCountStatus]:cCodeLoad) .AND. (Self:aoStatus[nClient]:aoStatus[nCountStatus]:cStatus == "2")
				lTempFound := .T.
				Exit
			EndIf
		Next nCountStatus
	
		If !lTempFound //se nao encontrar o status importado para alguma carga, define o ambiente como desatualizado e aborta a procura
			lClientUpdated := .F.
			Exit
		EndIf
		
	EndIf


Next nCount


Self:aUpdated[nClient] := lClientUpdated

Return 

/*
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ͻ��
���     M�todo: � SelectAll               � Autor: Vendas CRM � Data: 07/02/10 ���
����������������������������������������������������������������������������������������͹��
���  Descri��o: � Seleciona ou desmarca a selecao de todos os clientes                   ���
���             �                                                                        ���
����������������������������������������������������������������������������������������͹��
��� Parametros: � lAllTerminals: determina se marca ou desmarca os clientes               ���
����������������������������������������������������������������������������������������͹��
���    Retorno: � nenhum                              ���
����������������������������������������������������������������������������������������ͼ��
��������������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������������
*/
Method SelectAll(lAllTerminals) Class LJCInitialLoadMonitor
Local nI		:= 0 

For nI := 1 to Len(Self:aSelection)
		Self:aSelection[nI] := lAllTerminals 
Next nI

Self:UpdateTerminalList()

Return 
