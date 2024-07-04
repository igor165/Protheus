#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "LOJA340.CH"

/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³LOJA340() ³Autora ³Solange Zanardi        ³ Data ³ 20/01/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Assistente para abertura de caixa 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LOJA340()                            					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 														      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGALOJA                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                Alteracoes desde sua criacao                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³26/07/06  ³Danilo Calil   ³Bops 100967                                 ³±±
±±³          ³               ³Atualiza a database com a data de movimento ³±±
±±³          ³               ³do ECF.                                     ³±±
±±³27/03/07  ³Danilo Calil   ³Bops 105168                                 ³±±
±±³          ³               ³Substituicao de funcoes:                    ³±±
±±³          ³               ³- Lj010VldGet por LjxDVldGet                ³±±
±±³05/04/07  ³Conrado Quilles³Bops 122711                                 ³±±
±±³          ³               ³Alterada a utilização da chamada            ³±±
±±³          ³               ³SubStr(cUsuario,7,15) por cUserName         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LOJA340()

	Local oCaixa																//Objeto do numero de caixa
	Local oNomCaixa																//Objeto para o nome do caixa
	Local oLeituraX																//Objeto para Leitura X
	Local oValor																//Objeto para valor de fundo de troco
	Local oCodOrigem															//Objeto com o conteúdo do caixa originário de troco	
	Local oData																	//Objeto referente a data de abertura	
	Local oLbx                                                                  //ListBox para edicao das moedas - Localizacoes
	Local nLeituraX 	:= 1													//Emite leitura x 1-Sim 2-Nao
	Local cAbreCaixa  	:= Space(01) 											//Verifica permissao para abertura de caixa
	Local cTroco 	 	:= Space(01) 											//Verifica permissao para sangria e troco 
	Local cUsaFiscal	:= Space(01) 											//Verifica se utiliza impressora fiscal
	Local lImpFis   	:= .F.													//Indica se utiliza impressora fiscal
	Local lLibTro 		:= .F.													//Indica se liberou o fundo de troco com a senha de supervisor
	Local lLibFis 		:= .F.													//Indica se liberou a utilizacao da impressora fiscal com a senha de supervisor
	Local cNomCaixa 	:= Space(15)   											//Nome do Caixa
	Local dDataAbr 																//Data de abertura do caixa
	Local dDataFch																//Data de fechamento do caixa
	Local cHoraAbr		                										//Hora de abertura do caixa
	Local cHoraFch		                										//Hora de fechamento do caixa
	Local aMoedas       := {}                                                   //Array com as moedas utilizadas no sistema
	Local aSimbs        := {}													//Simbolos
	Local aSizes        := {40,40}												//Tamanho
	Local aFields       := {STR0039,STR0040}  //"Moeda"###"Valor"				//Campos
	Local nI                                                                    //Contador
	Local lEmitNfce		:= ExistFunc("LjEmitNFCe") .AND.  LjEmitNFCe()		//Sinaliza se utiliza NFC-e
	Local nPanel		:= 0													//Qtde de Panel, quando NFC-e nao cria Panel para LeituraX
	Local lINFIs			:= ExistFunc("INFIs")							//Se a rotia de impressora não-fiscal existe
	Local lImpNotFisc   := .F.													//Impressora Não-Fiscal
	Local lUseSAT		:= ( ExistFunc("LjUseSat") .AND. LjUseSat())			//Usa SAT
	Local lPanelX	    := .T.

	Local lAutomato     := If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)

	Private oWizard																//Objeto da janela
	Private cCaixa 	 	:= xNumCaixa() 											//Numero do caixa logado
	Private lRetPanel	:=.F. 													//Controle de Retorno do Painel
	Private cSupCaixa 	:= Space(15)   											//Supervisor do Caixa controle da ljprofile
	Private lAbre       :=.T.           										//Verifica se permite reabrir o caixa
	Private nValor    	:= 0													//Valor de Fundo de Caixa

	Private cCodOrigem 	:= Substr(GetMv("MV_CXLOJA"),1,3)						// Origem do troco, caixa central
	Private cCodDestin 	:= cCaixa                  								// Quem irá receber o troco
	Private nMoedaCorr  := 1                                                    // Moeda Corrente do Caixa
	Private cMoedaCorr  := ""                                                   // Moeda Selecionado no combo da moeda corrente do caixa

	If nModulo == 5 .AND. AllTrim(cStrAcesso) == ""
		LojXAcesso()
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega o array aMoedas com as moedas do sistema //
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cPaisLoc <> "BRA"
		For nI := 1 To MoedFin()             
			If !Empty(SuperGetMV("MV_MOEDA"+Str(nI,1,0)))
				AAdd(aMoedas,{SuperGetMv("MV_MOEDA"+Str(nI,1,0))+" ("+SuperGetMv("MV_SIMB"+Str(nI,1,0))+")",0,nI,MsDecimais(nI)})
			EndIf              

			// Carrega o array aSimbs com o simbolo das moedas do sistema.
			If !Empty(SuperGetMv("MV_SIMB"+Str(nI,1,0)))
				AAdd(aSimbs,SuperGetMv("MV_SIMB"+Str(nI,1,0)))
			EndIf
		Next nI
	Else
		AAdd(aMoedas,{SuperGetMv("MV_MOEDA1")+" ("+SuperGetMv("MV_SIMB1")+")",0,1,MsDecimais(1)})	
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o caixa está em branco         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(cCaixa)
		MsgInfo(STR0006)														//"Caixa inválido!"
		Return(NIL)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se pode ou nao Fechar/Abrir Caixa ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !ChkPsw(41)
		Return(NIL)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica Permissao de Abertura de Caixa    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !LjProfile(4,@cSupCaixa,,,) 								//Abre a tela para a digitação da senha do supervisor
		MsgStop( STR0001 + " " + ; 									// "O(a) usuário(a)"
		AllTrim(cUserName) + " " + ; 						// nome do usuario
		STR0002 ) 											//"não possui autorização para efetuar o processo de abertura de caixa, contate seu superior."
		Return(NIL)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o Caixa Existe ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lj030Verif()															// Verifica se o caixa está cadastrado na tabela de caixas SX5
		Return(NIL)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se existe conferencias de fechamento de caixa      ³
	//³pendentes e/ou o caixa esta aberto em outro terminal.       ³
	//³(Aplicavel quando empregado a confer. de caixa esta ativa)  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If FindFunction("LjPendConf")
		If LjPendConf("A")
			MsgAlert(STR0041)
			Return Nil
		Endif
	Endif

	If !lAutomato
		If lINFIs
			lImpNotFisc := INFIs(LjGetStation("IMPFISC"))
		Else
			lImpNotFisc := nModulo == 5 .OR. nModulo == 51 .OR. lEmitNfce .OR. lUseSAT
		EndIf
	Else
		lImpNotFisc   := .F.													//Impressora Não-Fiscal
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza a database do sistema caso não tenha sido³
	//³realizada a Redução Z pendente.                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lFiscal .AND. !lEmitNfce .AND. !lImpNotFisc
		LjEcfIFData()
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posicionar no caixa de trabalho e carregar variáveis a serem utilizadas³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SA6")
	DbSetOrder(1)
	DbSeek(xFilial("SA6")+AllTrim(cCaixa))
	cHoraAbr 	:= SA6->A6_HORAABR
	dDataAbr 	:= SA6->A6_DATAABR
	cHoraFch 	:= SA6->A6_HORAFCH
	dDataFch 	:= SA6->A6_DATAFCH
	cNomCaixa  	:= Capital(SA6->A6_NREDUZ)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  1 - Analise de credito   Verificacao do caixa se tem analise de credito                     ³
	//³  2 - Usa TEF              Caixa tem acesso a utilizar o sistema de TEF                       ³
	//³  3 - Usa Imp. Fiscal      Caixa tem acesso a utilizar Impressora Fiscal                      ³
	//³  4 - Supervisão Caixa     Acesso para abrir e fechar o caixa                                 ³
	//³  5 - Sangria/Troco        Acesso para fazer sangria e entrada de troco                       ³
	//³  6 - Redução Z            Acesso para fazer Redução Z                                        ³
	//³  7 - Cancelamento Item    Acesso para cancelar item                                          ³
	//³  8 - Cancelamento Cupom   Acesso para cancelar o cupom                                       ³
	//³  9 - Alterar parcelas     Acesso para alterar parcelas na venda balc„o                       ³
	//³ 10 - Saida do Atendimento Acesso para sair da tela de Atendimento  --- OUTRO MODULO          ³
	//³ 11 - Efetuar Descontos    Acesso para efetuar descontos                                      ³
	//³ 12 - Funções FrontLoja    Acesso para as teclas de funções       (F12)   --- FRONT LOJA      ³
	//³ 13 - Abertura de Gaveta   Acesso para abrir Gaveta                                           ³
	//³ 14 - Atu. Geral Check-Out Acesso para realizar atualizacao geral no Check-Out --- FRONT LOJA ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	lImpFis    	:= IIf(Len(Alltrim(LjGetStation("IMPFISC")))==0,.F.,.T.)   		//Verifica se a estacao possui impressora fiscal
	cUsaFiscal	:= SubStr(cStrAcesso,3,1)  										//Utiliza impressora Fiscal s/n/x
	cAbreCaixa 	:= SubStr(cStrAcesso,4,1)  										//Permite abrir o caixa s/n/x
	cTroco 	 	:= SubStr(cStrAcesso,5,1)  										//Permite efetuar sangria ou fundo de troco s/n/x

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se a estação ou o usuário não usarem impressora fiscal deixar a leitura X como Não³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lImpFis .OR. cUsaFiscal == "N" .OR. lImpNotFisc
		nLeituraX := 2
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tela inicial do Wizard³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE WIZARD oWizard  		;
	TITLE   STR0003 		; 												//"Abertura de Caixa"
	HEADER  STR0004 		; 												//"Assistente para Abertura de Caixa"
	MESSAGE " "     		;
	TEXT STR0005   		; 												//"O assistente irá ajudá-lo a executar os processos de abertura de caixa"
	PANEL NEXT {|| .T.} 	;
	FINISH {|| .T.}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Abertura do caixa³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CREATE PANEL oWizard   		;
	HEADER  STR0007  	; 												//"Abertura do Caixa"
	MESSAGE STR0008 		; 												//"Confira os dados e clique em <Avançar>"
	PANEL BACK {|| .T.} 	;
	NEXT {|| Lj340Val("1",dDataAbr,dDataFch,cUsaFiscal,@lLibFis,cHoraAbr,nLeituraX,cTroco,@lLibTro) .AND. ; //Verifico se o caixa já está aberto
	Lj340Panel(2,"NEXT",cUsaFiscal,cTroco,lImpFis) } ; 			
	FINISH {|| Lj340Sai(lRetPanel) } ;
	EXEC {|| .T.}

	@ 010,050 To 125,235 Of oWizard:oMPanel[2] Pixel
	@ 020,057 Say STR0009 Of oWizard:oMPanel[2] 	Pixel				   		//"Caixa : "
	@ 018,080 MsGet oCaixa 	Var cCaixa 				When .F. Size 20,8 Of oWizard:oMPanel[2] Pixel
	@ 035,057 Say STR0010 Of oWizard:oMPanel[2] 	Pixel						//"Nome  : "
	@ 033,080 MsGet oNomCaixa Var cNomCaixa 		When .F. Size 50,8 Of oWizard:oMPanel[2] Pixel
	@ 092,202 BitMap oBitMap Resname "troco_ocean" Size 32,32 Of oWizard:oMPanel[2] Pixel	


	lPanelX := !lEmitNfce .AND. !lImpNotFisc 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Entrada de Troco             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CREATE PANEL oWizard   ;
	HEADER STR0015  ; 													//"Fundo de caixa"
	MESSAGE STR0016 ; 													//"Informe abaixo o valor de fundo de caixa"
	PANEL BACK {|| .T.} ;
	NEXT {|| Lj340Val("2",dDataAbr,dDataFch,cUsaFiscal,@lLibFis,cHoraAbr,nLeituraX,cTroco,@lLibTro) .AND. ; //Valida se pode informar o troco
	(!lPanelX .OR. Lj340Panel(3,"NEXT",cUsaFiscal,cTroco,lImpFis)) } ; 
	FINISH {|| Lj340Sai(lRetPanel) } ;
	EXEC {|| .T.}

	@ 010,050 To 125,235 Of oWizard:oMPanel[3] Pixel
	@ 020,057 Say STR0032 Of oWizard:oMPanel[3] Pixel							//"Do Caixa: "
	@ 018,085 Msget oCodOrigem Var cCodOrigem F3 "23" Size 30,08 Of oWizard:oMPanel[3] Pixel ;
	Valid SX5->(DbSeek(xFilial("SX5")+"23"+cCodOrigem)) .AND. SA6->(DbSeek(xFilial("SA6")+cCodOrigem) .AND. cCodOrigem <> cCaixa)
	@ 020,120 Say STR0033 Of oWizard:oMPanel[3] Pixel							//"Para o Caixa: "
	@ 018,155 Msget oCaixa Var cCaixa  When .F. Size 20,08  Of oWizard:oMPanel[3] Pixel 
	@ 035,057 Say STR0017 Of oWizard:oMPanel[3] Pixel							//"Data  : "
	@ 033,085 Msget oData Var dDataBase When .F. Size 40,08 Of oWizard:oMPanel[3] Pixel	
	If cPaisLoc == "BRA"
		@ 050,057 Say STR0019 Of oWizard:oMPanel[3] Pixel							//"Valor : "
		@ 048,085 MsGet oValor Var nValor Valid Positivo() Picture "@E 999,999.99" Size 50,08 Of oWizard:oMPanel[3] Pixel
	Else
		//                      LS  CE  CD  LI
		oLBx := TWBrowse():New(050,057,120,060,,aFields,aSizes,oWizard:oMPanel[3],,,,,,,,,,,,.F.,,.T.,,.F.,,,)
		oLBx:SetArray(aMoedas)       
		oLBx:bLDblClick	:= {|| Lj340EdList(@aMoedas,@oLbx)}
		oLBx:bLine := {|| {aMoedas[oLBx:nAt,1],TransForm(aMoedas[oLBx:nAt,2],Tm(aMoedas[oLBx:nAt,2],16,aMoedas[oLBx:nAt,4]))}}
	EndIf
	@ 092,202 BitMap oBitMap RESNAME "troco" Size 32,32 Of oWizard:oMPanel[3] Pixel

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Leitura X                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lPanelX
		nPanel := 5
		CREATE PANEL oWizard   ;
		HEADER  STR0011 ; 													//"Leitura X"
		MESSAGE STR0012 ; 													//"Deseja efetuar a Leitura X na impressora fiscal ?"
		PANEL BACK {|| Lj340Panel(4,"BACK",cUsaFiscal,cTroco,lImpFis) } ;
		NEXT {|| Lj340Val("4",dDataAbr,dDataFch,cUsaFiscal,@lLibFis,cHoraAbr,nLeituraX,cTroco,@lLibTro) .AND. ;	//Valida se pode usar impressora fiscal 
		Lj340Val("3",dDataAbr,dDataFch,cUsaFiscal,@lLibFis,cHoraAbr,nLeituraX,cTroco,@lLibTro) }     ;  //Valida o horário para abertura do caixa
		FINISH {|| Lj340Sai(lRetPanel) } ;
		EXEC {|| .T.}

		@ 010,050 To 125,235 Of oWizard:oMPanel[4] Pixel
		@ 020,057 Radio oLeituraX Var nLeituraX 3D ;
		Size 130,10 	;
		PROMPT 		;
		STR0013,		; 													//"Sim"
		STR0014 		;  													//"Não"
		Of oWizard:oMPanel[4] Pixel	
		@ 050,050 BitMap oBitMap RESNAME "printer_l" Size 60,48 Of oWizard:oMPanel[4] Pixel	NOBORDER
	Else
		nPanel := 4
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tela de finalizacao do Wizard³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CREATE PANEL oWizard   ;
	HEADER STR0020  ; 													//"Finalizar"
	MESSAGE STR0025 ; 													//"Você está pretes a finalizar a operação de abertura de caixa..."
	PANEL BACK {|| Lj340Panel(nPanel,"BACK",cUsaFiscal,cTroco,lImpFis) } ;
	NEXT {|| .T. } ;
	FINISH {|| lRetPanel:=Lj340Fim() } ;
	EXEC {|| .T.}

	@ 010,050 To 125,235 Of oWizard:oMPanel[nPanel] Pixel
	@ 020,057 Say STR0021 Size 180,30 Of oWizard:oMPanel[nPanel] Pixel 				//"Para confirmar o processo de abertura clique em <Finalizar>"
	@ 092,202 BitMap oBitMap RESNAME "discount" Size 32,32 Of oWizard:oMPanel[nPanel] Pixel	

	// Se nao for o Robo, chama as telas
	If !lAutomato                                     
		ACTIVATE WIZARD oWizard CENTERED VALID {|| Lj340Sai(lRetPanel)}
		If lRetPanel .AND. lAbre
			LjMsgRun(STR0031,,{|| Lj340Proc(cAbreCaixa,lImpFis,nLeituraX,lLibFis,cUsaFiscal,lLibTro,cTroco,aMoedas,aSimbs, lImpNotFisc) }) //"Aguarde... Efetuando a Abertura do Caixa..."
		EndIf

	EndIf

Return(.T.)

/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Lj340Val ³Autora ³Solange Zanardi        ³ Data ³ 20/01/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validação das permissões dos caixas                        |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Lj340Val(cExp1,dExp2,dExp3,cExp4,lExp5,cExp6,nExp7,;       ³±±
±±³          |          cExp8,lExp9)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Parametros| cExp1 - Caracter para controle interno da função nº painel ³±±
±±|          | dExp2 - Data da abertura do caixa                          ³±±
±±|          | dExp3 - Data de fechamento do caixa                        ³±±
±±|          | cExp4 - Permissao do caixa para util. da imp.fiscal (SNX)  ³±±
±±|          | lExp5 - Indica se o sup.liberou a utilização da imp.fiscal ³±±
±±|          | cExp6 - Hora de Abertura do caixa                          ³±±
±±|          | nExp7 - Indica se foi setado no painel 1=S 2=N LeituraX    ³±±
±±|          | cExp8 - Permissao do caixa para entrada de troco    (SNX)  ³±±
±±|          | lExp9 - Indica se o sup.liberou a digitação do troco   	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA340                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj340Val(cTp     , dDataAbr , dDataFch  , cUsaFiscal , ;
	lLibFis , cHoraAbr , nLeituraX , cTroco     , ;
	lLibTro)

	Local lRet 		:= .T.				   		//Retorno da validacao
	Local cRet 		:= Space(01)				//Data do ECF
	Local xRet      := .T.                      //Retorno do ponto de entrada LJ340VLD
	Local lLj340Vld := ExistBlock("LJ340VLD")   //Ponto de entrada que permite validar a abertura automatica do caixa
	Local lEmitNfce	:= FindFunction("LjEmitNFCe") .AND.  LjEmitNFCe()		// Sinaliza se utiliza NFC-e
	Local lMvLjPdvPa:= FindFunction("LjxBGetPaf") .And. LjxBGetPaf()[2] //Indica se é PDV
	Local aDtHrECF  := IIF(lEmitNfce ,  LjDtHrECF(.T.) , {dDataBase,  Time()} )   //Data/Hora do caixa

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de entrada que permite validar a abertura automatica do caixa³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lLj340Vld
		xRet := ExecBlock("LJ340VLD",.F.,.F.)
		If ValType(xRet) == "L"
			lRet := xRet
		EndIf
	EndIf

	If lRet
		Do Case
			Case cTP == "1"									
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valida se o caixa já está aberto³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lAbre := .T. 														// Variável para controlar reabertura de caixa
			If !Empty(dDataAbr)                             
				MsgStop(STR0028+" "+Dtoc(dDataAbr)+CHR(10)+CHR(13)+STR0036)		//"Este caixa já foi aberto em:"
				lAbre := .F.			                                        //"Efetue primeiramente o seu fechamento"
				lRet  := .F.
			ElseIf !Empty(dDataFch) .AND. dDataFch == dDataBase
				If !MsgYesNo(STR0029+" "+Dtoc(dDataFch)+CHR(10)+CHR(13)+STR0037)//"Este caixa já foi fechado em:" 											
					lAbre := .F.                                                //"Confirma reabertura nesta data ?"
					lRet  := .F.
				EndIf
			ElseIf dDataAbr > aDtHrECF[1] .AND. cHoraAbr > SubStr(aDtHrECF[2],1,5)
				Help(" ",1,"LJHORAABR")
				lRet := .F.
			EndIf

			Case cTp == "2"									
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valida se pode informar o troco³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If	cTroco == "N" .AND. nValor > 0
				MsgInfo(STR0026) 												//"Usuário sem permissão para informar troco"
				lRet := .F.
			ElseIf cTroco == "X" .AND. nValor > 0 .AND. !lLibTro
				lLibTro := LjProfile(5,@cSupCaixa,,,) 
				lRet := lLibTro 
			Endif

			Case cTp == "3"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valido o horário da Ecf ou do Sistema     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !lEmitNfce .AND. nLeituraX == 1 .AND. cUsaFiscal == "S" .OR. lLibFis	//Se usa ou foi liberado para usar impressora fiscal

				IFStatus(nHdlECF, "2", @cRet)

				If dDataBase <> CtoD(cRet)
					MsgStop(STR0034)		 									//"A data do ECF está diferente da data do Sistema."
					lRet := .F.
				Else
					If SM0->M0_ESTCOB $ "MG|AM|SP"
						If !VerifHora()
							/* "Conforme previsto no Requisito XVII (Ato Cotepe/ICMS 9, de 13 de Março de 2013),
							para PAF-ECF admite-se somente uma tolerância em minutos entre a hora do Sistema e a hora do ECF,
							limitada a uma hora, desde que na mesma data." */
							If lMvLjPdvPa
								MsgStop(STR0042)
							Else
								MsgStop(STR0035) 									//"Hora do Sistema diferente da hora do ECF."
							EndIf
							lRet := .F.
						EndIf
					EndIf
				EndIf

			EndIf

			Case cTp == "4"    
			If cUsaFiscal == "N" .AND. nLeituraX == 1
				MsgInfo(STR0027) 												//"Usuário sem permissão para utilizar impressora fiscal"
				lRet := .F.
			ElseIf cUsaFiscal == "X" .AND. nLeituraX == 1 .AND. !lLibFis
				lLibFis := LjProfile(3,@cSupCaixa,,,)
				lRet 	:= lLibFis
			EndIf


		EndCase

	EndIf	
Return(lRet)

/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Lj340Panel³Autora ³Solange Zanardi        ³ Data ³ 23/01/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Controla a sequência dos painéis de acordo com as permis-  ³±±
±±³          ³ soes do caixa.                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Lj340Panel(nExp1,cExp2,cExp3,cExp4,lExp5)                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Parametros| nExp1 - Controle de número de painel                       ³±±
±±|          | cExp2 - Controle do tipo de operacao next ou back          ³±±
±±|          | cExp3 - Permissao do caixa para utilização de imp.fiscal   ³±±
±±|          | cExp4 - Permissao do caixa para digitacao de troco         ³±±
±±|          | lExp5 - Indica se utiliza impressora fiscal                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA340                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function lj340Panel(nPanel , cTipo , cUsaFiscal , cTroco , ;
	lImpFis)          

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³1 -  Painel de Bem Vindo                                   ³
	//³2 -  Painel para Seleção de Caixa                          ³
	//³3 -  Painel para Dig. Conferência de Caixa                 ³
	//³4 -  Painel para conf. da Impressão de Crítica             ³
	//³5 -  Painel para conf. de cópia dos dados dig. para sangria³
	//³6 -  Painel para digitação de Sangrias                     ³
	//³7 -  Painel da Leitura X                                   ³
	//³8 -  Painel da Redução Z                                   ³
	//³9 -  Painel de Finalização                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If cTipo == "NEXT"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Trato todas as combinações de parâmetros para que o assistente³
		//³pule as telas sobre as quais o operador não tem acesso.       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Do Case
			Case nPanel == 2
			If cTroco == "N"
				If !lImpFis .OR. cUsaFiscal == "N"
					oWizard:NPanel+=2
				Else
					oWizard:NPanel+=1
				EndIf	
			EndIf

			Case nPanel == 3
			If !lImpFis .OR. cUsaFiscal == "N"
				oWizard:NPanel+=1
			EndIf
		EndCase

	ElseIf cTipo == "BACK"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Quando estou trabalhando com o método BACK        ³
		//³devo me atentar a soma de mais 1 no NPanel, pois o³
		//³próprio comando BACK já efetua um retorno.        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Do Case
			Case nPanel == 4
			If cTroco == "N"
				oWizard:NPanel-=1
			EndIf

			Case nPanel == 5
			If !lImpFis .OR. cUsaFiscal == "N"
				If cTroco == "N"
					oWizard:NPanel-=2
				Else
					oWizard:NPanel-=1
				EndIf	
			EndIf
		EndCase
	EndIf
Return(.T.)

/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Lj340Proc³Autora ³Solange Zanardi        ³ Data ³ 20/01/04       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Efetua os procedimentos para a abertura de Caixa                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Lj340Proc(cExp1,lExp2,nExp3,lExp4,cExp5,lExp6,cExp7,nExp8,nExp9) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Parametros| cExp1 - Permissao do caixa abertura e fechamento    (SNX)        ³±±
±±|          | lExp2 - Indica se o caixa utiliza impressora fiscal              ³±±
±±|          | nExp3 - Indica se foi setado no painel 1=S 2=N LeituraX          ³±±
±±|          | lExp4 - Indica se o sup.liberou a utilização da imp.fiscal       ³±±
±±|          | cExp5 - Permissao do caixa para utilizacao de imp.fiscal         ³±±
±±|          | lExp6 - Indica se o sup.liberou a entrada de troco               ³±±
±±|          | cExp7 - Permissao do caixa para entrada de troco                 ³±±
±±|          | nExp8 - Array com os valores para entrada de troco (Localizacoes)³±±
±±|          | nExp9 - Array com os simbolos das moedas                         ³±±
±±|          | lExp10 - Impressora Não Fiscal?                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA340       |                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                     	        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³31/07/07  ³Erik Belluco   ³Bops 128060                                       ³±±
±±³          ³               ³Criado ponto de entrada LJ340ABRCX que recebe como³±±
±±³          ³               ³parametro aMoedas									³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj340Proc(cAbreCaixa , lImpFis , nLeituraX , lLibFis , ;
	cUsaFiscal , lLibTro , cTroco    , aMoedas , ;
	aSimbs, lImpNotFisc)

	Local lRet 			:= .T.									// Indica se o troco foi gravado com sucesso
	Local nI  			:= 0									// Controle auxiliar de loop
	Local lLj340AbrCx  	:= FindFunction("U_LJ340ABRCX") 		// Variavel que recebe o ponto de entrada LJ340FIM 
	Local lEmitNfce		:= FindFunction("LjEmitNFCe") .AND.  LjEmitNFCe()		// Sinaliza se utiliza NFC-e

	Default lImpNotFisc := .f.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Efetua abertura do caixa    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cx_abre_fecha(cCaixa,"A")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Leitura X				   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lEmitNfce .AND. lImpFis .AND. nLeituraX == 1 .AND. !lImpNotFisc .AND.  (lLibFis .OR. cUsaFiscal	== "S")
		IFLeituraX(nHdlECF)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gravando Troco de acordo com a função do Front Loja 	      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nI := 1 To Len(aMoedas)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Determina o valor e a moeda corrente para entrada de Troco.|
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cPaisLoc <> "BRA"
			nValor    := aMoedas[nI][02]
			nMoedaCorr:= aMoedas[nI][03]
		EndIf

		If (lLibTro .OR. cTroco == "S") .AND. nValor > 0
			lRet := Lj340Troc(aSimbs)
			If !lRet
				Return(.F.)	
			EndIf
		EndIf
	Next nI

	If cPaisLoc == "MEX"
		If lLj340AbrCx
			U_LJ340ABRCX(aMoedas)
		EndIf   
	EndIf

	MsgAlert(STR0022) 															//"Abertura de caixa efetuada com sucesso!"
Return(.T.)

/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Lj340Troc ³Autora ³Solange Zanardi        ³ Data ³ 03/02/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Prepara os dados para o envio de informações à função de   ³±±
±±³          ³ gravação de troco do Front Loja                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Lj340Troc()                            					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Parametros|ExpA1 (1 - aSimbs) Array de simbolos de moeda.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA340                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Data      | Analista | Bops  | Descricao                               |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³02/10/2007| Nunzio   |132489 | Passagem do parametro lSigaLoja = .T.   |±±
±±³			 | 			|		| para a funcao Frt050SE5, para sempre    |±±
±±³			 | 			|		| gravar o SE5 quando for chamada pelo 	  |±±
±±³			 | 			|		| siga loja e o caixa origem for diferente|±±
±±³			 | 			|		| do logado.					          |±±  
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj340Troc(aSimbs)

	Local aRet      	:= {} 													// Retorno do Ponto de Entrada
	Local lRet      	:= .F.													// Retorno da funcao
	Local nCheck		:= 2													//1=Sangria 2=Troco

	If ExistBlock("FRT050SA")
		aRet := ExecBlock("FRT050SA",.F.,.F.,{nCheck,cCodOrigem,cCodDestin})
		nCheck		:= aRet[1]
		cCodOrigem	:= aRet[2]
		cCodDestin	:= aRet[3]
		nDinheir	:= aRet[4]
		nCheques	:= aRet[5]
		nCartao		:= aRet[6]
		nVlrDebi	:= aRet[7]
		nFinanc		:= aRet[8]
		nConveni	:= aRet[9]
		nVales		:= aRet[10]
		nOutros		:= aRet[11]
	EndIf

	SX5->(DbSetOrder(1)) 														// Primeiro indice para validacao do caixa digitado
	SA6->(DbSetOrder(1)) 														// Primeiro indice para obtencao da Agencia/Conta para geracao do SE5

	lRet := Frt050SE5(nCheck, cCodOrigem, cCodDestin, nValor,0,0,0,0,0,0,0,aSimbs,.F., .T.)
	If lRet .AND. ExistBlock("Frt050ST")
		ExecBlock("Frt050ST",.F.,.F.,{nCheck,cSupCaixa,nValor,0,0,0,0,0,0,0})
	EndIf
Return(lRet)

/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Lj340Sai ³Autora ³Solange Zanardi        ³ Data ³ 20/01/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Mensagem para confirmar saida do assistente.        		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Lj340Sai(lExp1)                        					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Parametros| lExp1  -	Indicador de saída do painel                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA340                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj340Sai(lConfirma)

	If lConfirma 																//Se confimou gravacao sai do assistente
		Return(.T.)		
	Else
		If MsgNoYes(STR0030) 													//"Deseja abandonar o assistente ?"	
			Return(.T.)	
		EndIf	
	EndIf

Return(.F.)

/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Lj340Fim ³Autora ³Solange Zanardi        ³ Data ³ 20/01/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Confirmação para o processo de abertura de caixa            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Lj340Fim()                             					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Parametros|                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA340                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj340Fim()

	If MsgNoYes(STR0023) 														//"Ao confirmar o procedimento, será efetuada a abertura de caixa. Deseja prosseguir com a operação ?"	 
		Return(.T.)	
	EndIf	

Return(.F.)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Lj340EdList  ³ Autor ³    Julio Cesar        ³Data  ³08/04/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Permite editar o valor que sera recebido como entrada de troco³±±
±±³          ³ para cada moeda existente no sistema.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Lj340EdList(ExpA1,ExpO1)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 := Array com cada uma das moedas existentes no sistema. ³±±
±±³          ³ ExpO1 := Objeto referente ao TWBrowse                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Loja340 - Assistente de abertura de caixa.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                Alteracoes desde sua criacao                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³15/06/07  ³Norbert Waage  ³Bops 127759 - Correcao da picture utilizada na ³±±
±±³          ³               ³edicao do valor. Utilizacao das validacoes ca- ³±±
±±³          ³               ³dastradas no SX3 para o campo E5_VALOR.        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Lj340EdList(aMoedas,oLbx)

	Local aArea		:= GetArea()					// Armazena a area atual
	Local aAreaSX3	:= SX3->(GetArea())			// Armazena a area do SX3
	Local nValEnt	:= aMoedas[oLBx:nAt,2]			// Valor de entrada de troco
	Local cPict		:= ""							// Picture utilizada na edicao da celula
	Local cValid	:= "Lj340VldGet()"				// Validacao do valor informado

	DbSelectArea("SX3")
	DbSetOrder(2)

	If DbSeek("E5_VALOR")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Recupera a Picture do campo E5_VALOR³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cPict	:= SX3->X3_PICTURE

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Recupera a validacao do campo E5_VALOR³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(SX3->X3_VALID)
			cValid	+= ' .AND. (' + AllTrim(SX3->X3_VALID) + ')'
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Recupera a validacao de usuario do campo E5_VALOR³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(SX3->X3_VLDUSER)
			cValid	+= ' .AND. (' + AllTrim(SX3->X3_VLDUSER) + ')'
		EndIf

	EndIf

	oLBx:ColPos := 2
	MaFisEditCell(@nValEnt,oLBx,cPict,2,cValid) 

	SysRefresh()
	oLBx:Refresh()

	RestArea(aAreaSX3)
	RestArea(aArea)

Return(Nil)


/*    
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Lj340VldGet  ³ Autor ³Norbert Waage Junior   ³Data  ³18/06/07  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Realiza a validacao do valor informado pelo usuario no        ³±±
±±³          ³ TWBrowse.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ ExpL1 := Lj340VldGet()                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ ExpL1 := .T. para o dado valido e .F. para o dado invalido    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ LOJA340                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj340VldGet()

	Local lRet := .T.

	If M->CELL <= 0
		lRet := .F.
	EndIf

Return(lRet)
