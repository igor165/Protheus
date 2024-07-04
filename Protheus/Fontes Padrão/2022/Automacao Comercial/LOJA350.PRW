#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "LOJA350.CH"
#INCLUDE "DEFMOVCAIXA.CH"

#DEFINE _PICTURE	19

Static oGet

/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ LOJA350  ³Autora ³Solange Zanardi        ³ Data ³ 23/01/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Assistente para o fechamento ou troca de períodos dos cai-  ³±±
±±³          ³xas.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ LOJA350()                               				  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Parametros| aExp1 - Vetor com as moedas utilizadas                     ³±±
±±|          | nExp2 - Sequencia dos paines                               ³±±
±±|          | aExp3 - Vetor com os dados da forma de recebimento         ³±±
±±|          | lExp4 - .T. Indica cancelamento do processo                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGALOJA                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LOJA350(aMoedaUt,nSeq,aReceb,lCancel)

	Local oCaixa			:= Nil													// Objeto do numero de caixa
	Local oNomCaixa			:= Nil													// Objeto para o nome do caixa
	Local oLeituraX			:= Nil													// Objeto para Leitura X
	Local oValor			:= Nil													// Objeto para valor de fundo de troco
	Local oReducaoZ			:= Nil													// Objeto radiobox da Reducao
	Local oCritFch			:= Nil													// Objeto radiobox para verIficação de crítica
	Local oAcuDiario		:= Nil													// Objeto radiobox para processamento de acumulado diário
	Local oLevaVlr			:= Nil													// Objeto radiobox para saber se leva valores
	Local oCbMoeda			:= Nil													// Objeto referente ao combo da moeda
	Local nLeituraX			:= 0													// Emite Leitura X 				1-Sim 2-Nao
	Local nReducaoZ			:= 2													// Emite Red~ção Z 				1-Sim 2-Nao
	Local nCritFch			:= 1													// Emite Relatorio de Critica  	1-Sim 2-Nao
	Local nAcuDiario		:= 1													// Processa Acumulados Diários 	1-Sim 2-Nao
	Local nLevaVlr			:= 1													// Indica se leva valores da conferência para Sangria
	Local cFechCaixa		:= Space(01)											// Verifica se operador pode fechar caixa
	Local cUsaFiscal		:= Space(01) 											// Verifica se utiliza impressora fiscal
	Local cSangTroc			:= Space(01)											// Verifica se utiliza sangria ou troco
	Local cReducaoZ			:= Space(01)											// Verifica se emite Redução Z
	Local lImpFis			:= .F.													// Verifica se a estacao possui impressora fiscal
	Local lLibRez			:= .F.													// Superior liberou a impressão da Redução Z	
	Local lLibFis			:= .F.													// Superior liberou utilização da impressora fiscal
	Local lLibSan			:= .F.													// Superior liberou o procedimento de sangria
	Local lFechado 			:= .T.													// Valida se o caixa já está fechado
	Local lLibConf			:= SuperGetMv("MV_LJLIBCF")							 	// Verifica se cliente utiliza o processo de conferência de caixa
	Local dDataAbr			:= dDataBase											// Data de abertura do caixa
	Local dDataFch			:= dDataBase											// Data de fechamento do caixa
	Local cHoraAbr			:= Time()												// Hora de abertura do caixa
	Local cHoraFch			:= Time()		                						// Hora de fechamento do caixa
	Local nDinheir			:= 0													// Sangria em Dinheiro
	Local nCheques			:= 0													// Sangria em Cheque
	Local nCartao			:= 0													// Sangria em Cartão
	Local nVlrDebi			:= 0													// Sangria em valor de débito
	Local nFinanc			:= 0													// Sangria em Financiamento
	Local nConveni			:= 0													// Sangria em Convênio
	Local nVales			:= 0													// Sangria em Vale
	Local nOutros			:= 0													// Sangria em Outros
	Local aMoedas      		:= {}                                              		// Array com as moedas utilizadas no sistema
	Local nI				:= 0													// Contador
	Local aSimbs   			:= {} 													// Localizações - Array com os simbolos das formas de pgto.
	Local nTamLT_AGENCIA	:= TamSx3("LT_AGENCIA")[1]								// Tamanho de LT_AGENCIA
	Local lLj7067  			:= ExistBlock("LJ7067")  								// Ponto de entrada no final do fechamento automatico do caixa apos a Reducao Z.
	Local lEmitNfce			:= ExistFunc("LjEmitNFCe") .AND.  LjEmitNFCe()		    // Sinaliza se utiliza NFC-e
	Local lINFIs			:= ExistFunc("INFIs")								    // Se a rotia de impressora não-fiscal existe
	Local lImpNotFisc   	:= .F.													// Impressora Não-Fiscal
	Local nPanel			:= 10													// Panel do Caixa
	Local lUseSAT		    := ( ExistFunc("LjUseSat") .AND. LjUseSat())            // Usa SAT
	Local lAutomato         := If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)
    Local aTmpEst           := LjGetStation({"CODIGO", "NOME", "IMPFISC"})          // Dados da estação
	Local nVlrPagDig		:= 0													// Sangria Pagamento Digital
	Local nVlrPagPix		:= 0													// Sangria Pagamento PIX

	If nModulo == 5 .AND. AllTrim(cStrAcesso) == ""
		LojXAcesso()
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existe a tabela SLT. Esta verificacao eh necessaria      ³
	//³ devido ao lancamento do Release 2 do Protheus 8. Se o cliente nao    ³
	//³ rodar o update da versao para criar esta tabela nao podera usar esta ³
	//³ rotina.                                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SLT")
	If Select("SLT") <= 0
		MsgStop( STR0067, STR0070 )	// "Tabela SLT não existe. Não é possível utilizar esta rotina sem executar o update do Protheus 8"###"Atenção"
		Return Nil
	Endif   

	Private nMoedaCorr	:= 1   													// Localizações - Moeda Corrente
	Private cMoedaCorr 	:= SuperGetMV("MV_MOEDA1")                             	// Localizações - Nome da Moeda Corrente
	Private cSimbCorr	:= "."+Space(nTamLT_AGENCIA-1)    			          	// Localizações - Símbolo da Moeda Corrente
	Private aCols		:= aHeader := aDigSan := aSangrias := aVendas := {}   	// Arrays de trabalho 
	Private cCaixa 	 	:= xNumCaixa() 											// Numero do caixa logado
	Private cNomCaixa 	:= cSupCaixa := Space(15)   							// Caixa e Nome do Caixa
	Private nVlTotal	:= 0													// Valor Total Digitado pelo Operador de Caixa
	Private cCodOrigem	:= cCaixa												// Parametros utilizados na funcao de gravação de sangrias	
	Private cCodDestin 	:= Substr(SuperGetMv("MV_CXLOJA"),1,3)					// Variável utilizada na gravação das Sangrias
	Private lRetPanel	:=.F. 													// Controle de Retorno do Painel
	Private oWizard		:= Nil													// Objeto do Wizard
	Private oVltotal	:= Nil													// Objeto do Valor Total
	Private oSayRed		:= Nil													// Controle de Objetos
	Private lSangLoc	:= .F.                                                	// Localizacoes - Determina se sera realizada sangria para outras moedas
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Essas variaveis foram criadas para que a rotina possa ser utilizada³
	//³ de forma recursiva - Localizacoes.                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Default aMoedaUt	:= {}
	Default nSeq		:= 0       
	Default aReceb		:= {}
	Default lCancel		:= .F.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega o array aMoedas com as moedas do sistema  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cPaisLoc <> "BRA"      
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Caso o usuario esteja cancelando o processo interrompe a rotina.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lCancel
			Return (Nil)
		EndIf

		nSeq++
		For nI := 1 To MoedFin()
			If aScan(aMoedaUt,{|x| x == nI}) == 0
				If !Empty(SuperGetMV("MV_MOEDA"+Str(nI,1,0)))
					AAdd(aMoedas,Str(nI,1,0)+" - "+SuperGetMv("MV_MOEDA"+Str(nI,1,0)))
				EndIf
			EndIf

			If !Empty(SuperGetMV("MV_MOEDA"+Str(nI,1,0))) .AND. !Empty(SuperGetMv("MV_SIMB"+Str(nI,1,0)))
				AAdd(aSimbs,SuperGetMv("MV_SIMB"+Str(nI,1,0)))
			EndIf

			If nSeq == 1 .AND. !Empty(SuperGetMV("MV_MOEDA"+Str(nI,1,0)))
				AAdd(aReceb,{Str(nI,1,0)+" - "+SuperGetMv("MV_MOEDA"+Str(nI,1,0)),{},{}})			
			EndIf
		Next nI

		nMoedaCorr := Val(SubStr(aMoedas[1],1,1))
		cMoedaCorr := SuperGetMV("MV_MOEDA"+Str(nMoedaCorr,1,0))    

		If nMoedaCorr <> 1
			cSimbCorr	:= SuperGetMv("MV_SIMB"+Str(nMoedaCorr,1,0))
		Else 
			cSimbCorr	:= "."
		EndIf

		cSimbCorr  := cSimbCorr+Space(nTamLT_AGENCIA-Len(cSimbCorr))
	Else
		If !Empty(SuperGetMV("MV_MOEDA"+Str(nMoedaCorr,1,0)))
			AAdd(aReceb,{"1 - "+SuperGetMv("MV_MOEDA"+Str(nMoedaCorr,1,0)),{},{}})			
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ VerIfica se o caixa está em branco         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(cCaixa)
		MsgInfo(STR0006)	//"Caixa inválido!"
		Return(NIL)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se pode ou nao Fechar/Abrir Caixa ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !ChkPsw(41)
		Return(NIL)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ VerIfica Permissao de Abertura de Caixa    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !LjProfile(4,@cSupCaixa,,,) 								//"Abre a tela para a digitação da senha do supervisor"
		MsgStop( STR0001 + " " + ; 									//"O(a) usuário(a)"
		AllTrim(cUserName) + " " + ; 						//"nome do usuario"
		STR0002 ) 											//"não possui autorização para efetuar o processo de abertura de caixa, contate seu superior."
		Return(NIL)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ VerIfica se o Caixa Existe ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lj030VerIf()															//"VerIfica se o caixa está cadastrado na tabela de caixas SX5"
		Return(NIL)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se existe conferencias de fechamento de caixa      ³
	//³pendentes e/ou o caixa esta aberto em outro terminal.       ³
	//³(Aplicavel quando empregado a confer. de caixa esta ativa)  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If FindFunction("LjPendConf")
		If LjPendConf("F")
            LjxjMsgErr( STR0068, I18n(STR0074, {cCaixa, AllTrim( aTmpEst[1] ) + "-" + AllTrim( aTmpEst[2] )} ) )  //"Caixa está fechado ou existe(m) movimento(s) pendente(s) de conferência ou está aberto em outro terminal."      //"Verifique o caixa #1 (Abertura\Conferência) e confirme se está no terminal correto #2."

			Return Nil
		Endif
	Endif

	If !lAutomato
		If lINFIs
            lImpNotFisc := INFIs(aTmpEst[3])
		Else
			lImpNotFisc := nModulo == 5 .OR. nModulo == 51 .OR. lEmitNfce .OR. lUseSAT
		EndIf
	Else
		lImpNotFisc   := .F.													//Impressora Não-Fiscal
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atualiza a DataBase com a data do movimento da ³
	//³impressora                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
	//³  1 - Analise de credito   VerIficacao do caixa se tem analise de credito                     ³
	//³  2 - Usa TEF              Caixa tem acesso a utilizar o sistema de TEF                       ³
	//³  3 - Usa Imp. Fiscal      Caixa tem acesso a utilizar Impressora Fiscal                      ³
	//³  4 - Supervisão Caixa     Acesso para abrir e fechar o caixa                                 ³
	//³  5 - Sangria/Troco        Acesso para fazer sangria e entrada de troco                       ³
	//³  6 - Redução Z            Acesso para fazer Redução Z                                        ³
	//³  7 - Cancelamento Item    Acesso para cancelar item                                          ³
	//³  8 - Cancelamento Cupom   Acesso para cancelar o cupom                                       ³
	//³  9 - Alterar parcelas     Acesso para alterar parcelas na vEnda balc„o                       ³
	//³ 10 - Saida do AtEndimento Acesso para sair da tela de AtEndimento                            ³
	//³ 11 - Efetuar Descontos    Acesso para efetuar descontos                                      ³
	//³ 12 - Funções FrontLoja    Acesso para as teclas de funções                                   ³
	//³ 13 - Abertura de Gaveta   Acesso para abrir Gaveta                                           ³
	//³ 14 - Atu. Geral Check-Out Acesso para realizar atualizacao geral no Check-Out                ³
	//³ 15 - Altera Conferência   Acesso para realizar a conferência e alteração do fechamento       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se a estacao possui impressora fiscal.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If Len(Alltrim(aTmpEst[3])) == 0 .OR. lEmitNfce .OR. lImpNotFisc
		lImpFis	:= .F.
	Else
		lImpFis	:= .T.
	EndIf
	cUsaFiscal	:= SubStr(cStrAcesso,3,1)  										//Utiliza impressora Fiscal s/n/x
	cFechCaixa 	:= SubStr(cStrAcesso,4,1)  										//Permite abrir o caixa s/n/x
	cSangTroc  	:= SubStr(cStrAcesso,5,1)  										//Permite efetuar sangria e troco
	cReducaoZ  	:= SubStr(cStrAcesso,6,1)  										//Permite efetuar redução z

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Atribuindo valores defaults de liberação de acordo com as permissões de usuário³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lImpFis
		nLeituraX 	:= 1
	Else
		nLeituraX	:= 2
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Painel 1 - Tela inicial do Wizard³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE WIZARD oWizard  		;
	SIZE 0,0,500,550			;
	TITLE   STR0003 			; 											//"Fechamento de Caixa"
	HEADER  STR0004 			; 											//"Assistente para Fechamento de Caixa"
	MESSAGE " "     			;
	TEXT STR0005   			; 												//"O assistente irá ajudá-lo a executar os processos de fechamento de caixa"
	PANEL Next {|| .T.} 		;
	FINISH {|| .T.}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Painel 2 - Selecao do caixa³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CREATE PANEL oWizard 			;
	HEADER STR0007				;   										//"Fechamento de caixa"
	MESSAGE STR0008				;											//"Confira os dados e clique em <Avançar>"
	PANEL BACK {|| nSeq == 1}	;
	Next {|| Lj350Val("1"      ,dDataFch,dDataAbr ,cUsaFiscal,;
	nLeituraX,@lLibFis,nReducaoZ,@lLibReZ ,;
	cReducaoZ,@lFechado,@lLibSan,cSangTroc) .AND. ;  						//Verifica se o caixa já está aberto
	Lj350Panel(2        ,"NEXT"   ,lLibConf,cUsaFiscal,;
	cReducaoZ,cSangTroc,lImpFis ,nSeq       ) } ;    						//Controla o pulo de painéis qdo parametros desabilitados
	FINISH {|| Lj350Sai(lRetPanel,@lCancel) } ;
	EXEC {|| .T.}

	@ 010,050 To 125,235 Of oWizard:oMPanel[2] Pixel
	@ 020,057 Say STR0009 Of oWizard:oMPanel[2] Pixel							//"Caixa : "
	@ 018,080 MsGet oCaixa Var cCaixa When .F. Size 20,8 Of oWizard:oMPanel[2] Pixel
	@ 035,057 Say STR0010 Of oWizard:oMPanel[2] Pixel							//"Nome  : "
	@ 033,080 MsGet oNomCaixa Var cNomCaixa When .F. Size 50,8 Of oWizard:oMPanel[2] Pixel
	If cPaisLoc <> "BRA"
		@ 050,057 Say STR0064 Of oWizard:oMPanel[2] Pixel 						//"Moeda : "
		@ 048,085 MsComboBox oCbMoeda Var cMoedaCorr Items aMoedas On Change ( nMoedaCorr := Val(SubStr(cMoedaCorr,1,1)),;
		cSimbCorr := Iif(nMoedaCorr <> 1,SuperGetMv("MV_SIMB"+Str(nMoedaCorr,1,0)),"."), ;
		cSimbCorr := cSimbCorr+Space(nTamLT_AGENCIA-Len(cSimbCorr)) ) ;
		Size 65,30 Of oWizard:oMPanel[2] Pixel
	EndIf
	@ 092,202 BitMap oBitMap Resname "troco_ocean" Size 32,32 Of oWizard:oMPanel[2] Pixel

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Painel 3 - Conferência de cx ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CREATE PANEL oWizard 			;
	HEADER STR0011 				; 											//"Conferência de caixa"
	MESSAGE STR0012				; 											//"Informe os valores para a conferência do caixa"
	PANEL BACK {|| .T.} 		;
	Next {|| Lj350Panel(3       ,"NEXT"   ,lLibConf,cUsaFiscal,;
	cReducaoZ,cSangTroc,lImpFis ,nSeq)} ;
	FINISH {|| Lj350Sai(lRetPanel,@lCancel) } ;
	EXEC {|| .T.}

	@ 010,050 To 133,247 Of oWizard:oMPanel[3] Pixel

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Painel 4 - Critica de fechamento³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CREATE PANEL oWizard 			;
	HEADER STR0013 				;   										//"Crítica de fechamento"
	MESSAGE STR0014				;   										//"Ao final do processo imprime relatório com conferência de fechamento ?"
	PANEL BACK {|| .T.} 		;
	Next {|| Lj350Panel(4       ,"NEXT"   ,lLibConf,cUsaFiscal,;
	cReducaoZ,cSangTroc,lImpFis ,nSeq) }	;		
	FINISH {|| Lj350Sai(lRetPanel,@lCancel)} 	;
	EXEC {|| .T.}

	@ 010,050 To 125,235 Of oWizard:oMPanel[4] Pixel
	@ 020,057 Radio oCritFch Var nCritFch 3D Size 130,10 Prompt STR0015,STR0016 Of oWizard:oMPanel[4] Pixel		//"Sim" "Não"
	@ 050,050 BitMap oBitMap ResName "printer_l" Size 60,48 Of oWizard:oMPanel[4] Pixel NoBorder

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Painel 5 - Leva os valores dos totais de Caixa Digitados para a Sangria³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CREATE PANEL oWizard 			;
	HEADER STR0047 				;   										//"Valores para Sangria"
	MESSAGE STR0048				;   										//"Deseja carregar os valores digitados anteriormente em conferência nas Sangrias ?"
	PANEL BACK {|| Lj350Panel(5        ,"BACK"   ,lLibConf,cUsaFiscal,;
	cReducaoZ,cSangTroc,lImpFis ,nSeq)} 	   ;
	Next {|| lj350LeVal(nLevaVlr,@nDinheir,@nCheques,@nCartao,;
			@nVales ,@nConveni,@nFinanc ,@nVlrDebi,;
			@nOutros,@nVlrPagDig,@nVlrPagPix ) } 	;
	FINISH {|| Lj350Sai(lRetPanel,@lCancel)} 	;
	EXEC {|| .T.}

	@ 010,050 To 125,235 Of oWizard:oMPanel[5] Pixel
	@ 020,057 Radio oLevaVlr Var nLevaVlr 3D Size 130,10 Prompt STR0015,STR0016 Of oWizard:oMPanel[5] Pixel		//"Sim" "Não"
	@ 092,202 BitMap oBitMap Resname "troco_ocean" Size 32,32 Of oWizard:oMPanel[5] Pixel

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Painel 6 - Sangria³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CREATE PANEL oWizard 			;
	HEADER STR0017 				;   										//"Sangria de caixa"
	MESSAGE STR0018				;   										//"Digite os respectivos valores para efetuar as Sangrias e click no botão <Ok> para salvá-las"
	PANEL BACK {|| Lj350Panel(6,"BACK",lLibConf,cUsaFiscal,cReducaoZ,cSangTroc,lImpFis,nSeq) } 		;
	Next {|| Lj350Panel(6        ,"NEXT"   ,lLibConf,cUsaFiscal,;
	cReducaoZ,cSangTroc,lImpFis ,nSeq) .AND. ;
	Lj350Val("6"      ,dDataFch ,dDataAbr ,cUsaFiscal,;
	nLeituraX,@lLibFis ,nReducaoZ,@lLibReZ  ,;
	cReducaoZ,@lFechado,@lLibSan ,cSangTroc) .AND. ;  //Verifica se o usuario podera efetuar sangrias
	Lj350ValSa(nDinheir,nCheques,nCartao ,nVales,;
				nConveni,nFinanc ,nVlrDebi,nOutros,nVlrPagDig,nVlrPagPix ) } ;
	FINISH {|| Lj350Sai(lRetPanel,@lCancel)} 	;
	EXEC {|| .T.}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Função para a montagem de tela de Sangrias, mesmo padrão    ³
	//³utilizado no Front Loja para obedecer parametros e pontos de³
	//³entrada.                                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Lj350MonSa(@nDinheir,@nCheques,@nCartao ,@nVales,;
				@nConveni,@nFinanc ,@nVlrDebi,@nOutros,@nVlrPagDig,@nVlrPagPix)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Painel 7 - Acumulados diarios³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CREATE PANEL oWizard 				;
	HEADER STR0020 					;    									//"Acumulados diários"
	MESSAGE STR0021					;    									//"Executa o processamento dos acumulados diários ?"
	PANEL BACK {|| Lj350Panel(7        ,"BACK"   ,lLibConf,cUsaFiscal,;
	cReducaoZ,cSangTroc,lImpFis ,nSeq) };
	Next {|| Lj350Panel(7        ,"NEXT"   ,lLibConf,cUsaFiscal,;
	cReducaoZ,cSangTroc,lImpFis ,nSeq) } ;
	FINISH {|| Lj350Sai(lRetPanel,@lCancel)}	;
	EXEC {|| .T.}

	@ 010,050 To 125,235 Of oWizard:oMPanel[7] Pixel
	@ 020,057 Radio oAcuDiario Var nAcuDiario 3D Size 130,10 Prompt STR0015,STR0016 Of oWizard:oMPanel[7] Pixel		//"Sim" ### "Nao"
	@ 056,181 BitMap oBitMap Resname "quantrej" Size 53,68 Of oWizard:oMPanel[7] Pixel

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Painel 8 - Leitura X³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CREATE PANEL oWizard 			;
	HEADER STR0022 				;  											//"Leitura X"
	MESSAGE STR0023				;  											//"Deseja efetuar a Leitura X ?"
	PANEL BACK {|| .T.} 		;
	Next {|| Lj350Val("2"      ,dDataFch ,dDataAbr  ,cUsaFiscal,;
	nLeituraX,@lLibFis ,nReducaoZ,@lLibReZ  ,;
	cReducaoZ,@lFechado,@lLibSan ,cSangTroc) .AND. ;
	Lj350Panel(8        ,"NEXT"   ,lLibConf,cUsaFiscal,;
	cReducaoZ,cSangTroc,lImpFis ,nSeq) } ;
	FINISH {|| Lj350Sai(lRetPanel,@lCancel)} 	;
	EXEC {|| .T.}

	@ 010,050 To 125,235 Of oWizard:oMPanel[8] Pixel
	@ 020,057 Radio oLeituraX Var nLeituraX 3D Size 130,10 Prompt STR0015,STR0016 Of oWizard:oMPanel[8] Pixel		//"Sim" "Nao"
	@ 050,050 BitMap oBitMap ResName "printer_l" Size 60,48 Of oWizard:oMPanel[8] Pixel NoBorder

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Painel 9 - Reducao Z³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CREATE PANEL oWizard 			;
	HEADER STR0024 				;   										//"Redução Z"
	MESSAGE STR0025				;   										//"Deseja efetuar a Redução Z ?"
	PANEL BACK {|| Lj350Panel(9,"BACK",lLibConf,cUsaFiscal,cReducaoZ,cSangTroc,lImpFis,nSeq) } ;
	Next {||Lj350Val("3"      ,dDataFch ,dDataAbr ,cUsaFiscal,;
	nLeituraX,@lLibFis ,nReducaoZ,@lLibReZ  ,;
	cReducaoZ,@lFechado,@lLibSan ,cSangTroc) .AND. ;
	Lj350Val("4"      ,dDataFch ,dDataAbr ,cUsaFiscal,;
	nLeituraX,@lLibFis ,nReducaoZ,@lLibReZ  ,;
	cReducaoZ,@lFechado,@lLibSan ,cSangTroc) .AND. ;
	Lj350Val("5"      ,dDataFch ,dDataAbr ,cUsaFiscal,;
	nLeituraX,@lLibFis ,nReducaoZ,@lLibReZ  ,;
	cReducaoZ,@lFechado,@lLibSan ,cSangTroc) } 	 ;
	FINISH {|| Lj350Sai(lRetPanel,@lCancel) } 	;
	EXEC {|| .T.}

	@ 010,050 To 125,235 Of oWizard:oMPanel[9] Pixel
	@ 020,057 Radio oReducaoZ Var nReducaoZ 3D On Change Lj350Red(nReducaoZ) ;
	Size 130,10 Prompt STR0015,STR0016 Of oWizard:oMPanel[9] Pixel 	//"Sim" ### "Nao"
	@ 050,057 Say oSayRed Prompt STR0026 ; 						 	//"Lembre-se que ao executar a Redução Z, o relatório de fechamento é emitido na impressora fiscal e a partir deste momento não poderão ser efetuadas mais vendas neste dia."
	Size 170,035 Of oWizard:oMPanel[9] Pixel 																
	@ 075,192 BitMap oBitMap ResName "printer_r" Size 60,48 Of oWizard:oMPanel[9] Pixel NoBorder

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Monta o que sera exibido no On Change          			³
	//|No avancar confirmar se quer mesmo emitir a Reducao Z    |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Lj350Red(nReducaoZ)


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Painel 10 - Tela de finalizacao do Wizard³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CREATE PANEL oWizard 				;
	HEADER STR0027 					; 										//"Finalizar"
	MESSAGE STR0028					;										//"Você está pretes a encerrar a operação de fechamento de caixa..."
	PANEL BACK {|| Lj350Panel(10       ,"BACK"   ,lLibConf,cUsaFiscal,;
	cReducaoZ,cSangTroc,lImpFis ,nSeq) } ;
	Next {|| .T. } 					;
	FINISH {|| lRetPanel:=Lj350Fim(aMoedas) } 	;
	EXEC {|| .T.}

	@ 010,050 To 125,235 Of oWizard:oMPanel[10] Pixel
	@ 020,057 Say STR0029 Size 180,30 Of oWizard:oMPanel[10] Pixel				//"Para confirmar o processo de fechamento clique em <Finalizar>"
	@ 092,202 BitMap oBitMap Resname "troco" Size 32,32 Of oWizard:oMPanel[10] PIXEL

	// Se nao for o Robo, chama as telas
	If !lAutomato                                     
		ACTIVATE WIZARD oWizard ON INIT {|| Lj350Panel(1        ,"NEXT"   ,lLibConf,cUsaFiscal,;
		cReducaoZ,cSangTroc,lImpFis ,nSeq)} ;
		CENTERED VALID {|| Lj350Sai(lRetPanel,@lCancel)}
		If lRetPanel .AND. lFechado													//"Aguarde... Efetuando o fechamento do caixa..."
			LjMsgRun(STR0030,,{|| Lj350Proc(nAcuDiario,nCritFch 	,lImpFis  ,nLeituraX ,;
			cUsaFiscal,lLibFis  ,nReducaoZ,cFechCaixa,;
			lLibReZ   ,cReducaoZ,lLibConf ,@aMoedaUt ,;
			nSeq      ,aMoedas  ,aSimbs   ,@aReceb   ,;
			@lCancel)})
		EndIf

	EndIf


	If lLj7067  
		ExecBlock("LJ7067",.F.,.F.)
	EndIf

Return(.T.)

/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Lj350Val ³Autora ³Solange Zanardi        ³ Data ³ 23/01/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Efetua a validação para avanço nos painéis                 ³±±
±±³          ³ VerIficando permissões de acesso a cada processo           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Lj350Val(cExp1,dExp2,dExp3,cExp4,nExp5,lExp6,nExp7,;       ³±±
±±³          |          lExp8,cExp9,lExp10,lExp11,cExp12)                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Parametros| cExp1 - Caracter para controle interno da função nº painel ³±±
±±|          | dExp2 - Data de fechamento do caixa                        ³±±
±±|          | dExp3 - Data da abertura do caixa                          ³±±
±±|          | cExp4 - Permissao do caixa para util. da imp.fiscal (SNX)  ³±±
±±|          | nExp5 - Indica se foi setado no painel 1=S 2=N LeituraX    ³±±
±±|          | lExp6 - Indica se o sup.liberou a utilização da imp.fiscal ³±±
±±|          | nExp7 - Indica se foi setado no painel 1=S 2=N ReduçãoZ    ³±±
±±|          | lExp8 - Indica se o sup.liberou a emissao da reducao Z     ³±±
±±|          | cExp9 - Permissao do caixa para emissao da Red.Z    (SNX)  ³±±
±±|          | lExp10- Indica se confirmou o fechamento                   ³±±
±±|          | lExp11- Indica se o sup.liberou a digitação de sangria 	  ³±±
±±|          | cExp12- Permissao do caixa para digitacao de sangria (SNX) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA350                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj350Val(	cTp      	,dDataFch	,dDataAbr 	,cUsaFiscal	,;
	nLeituraX	,lLibFis 	,nReducaoZ	,lLibReZ   	,;
	cReducaoZ	,lFechado	,lLibSan  	,cSangTroc 	)

	Local lRet := .T. // Variavel logica de retorno

	Do Case

		Case cTp == "1"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida se o caixa já está fechado³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lFechado := .T.
		If !Empty(dDataFch)
			MsgStop(STR0037+" "+DToc(dDataFch)+CHR(10)+CHR(13)+STR0038)	//"Este caixa foi fechado em:"
			lFechado	:= .F.                                          	//"Efetue primeiramente sua abertura"
			lRet 		:= .F.
		EndIf

		Case cTp == "2"		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida se pode usar impressora fiscal e efetuar leitura X³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cUsaFiscal	== "N" .AND. nLeituraX == 1
			MsgStop(STR0034)												//"Usuário sem permissãoo para utilizar impressora fiscal"
			lRet 	:=.F.
		ElseIf cUsaFiscal	== "X" .AND. nLeituraX == 1 .AND. !lLibFis
			lLibFis := LjProfile(3,@cSupCaixa,,,)
			lRet 	:= lLibFis
		EndIf

		Case cTp == "3"		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida se pode usar impressora fiscal para efetuar a Reducao Z³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cUsaFiscal	== "N" .AND. nReducaoZ == 1
			MsgStop(STR0034)												//"Usuário sem permissãoo para utilizar impressora fiscal"
			lRet 	:=.F.			
		ElseIf cUsaFiscal	== "X" .AND. nReducaoZ == 1 .AND. !lLibFis
			lLibFis := LjProfile(3,@cSupCaixa,,,)
			lRet 	:= lLibFis
		EndIf

		Case cTp == "4"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida se pode efetuar a Reducao Z³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cReducaoZ	== "N" .AND. nReducaoZ == 1
			MsgStop(STR0035)												//"Usuário sem permissãoo para efetuar a Redução Z"
			lRet 	:=.F.
		ElseIf cReducaoZ	== "X" .AND. nReducaoZ == 1 .AND. !lLibReZ
			lLibReZ := LjProfile(6,@cSupCaixa,,,)
			lRet 	:= lLibRez
		EndIf

		Case cTp == "5" .AND. nReducaoZ == 1
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Confirmar se quer mesmo emitir a Reducao Z³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !MsgYesNo(STR0036)												//"Confirma a emissão da Redução Z ?"
			lRet 	:=.F.
		Else
			lRet 	:=.T.
		EndIf

		Case cTp == "6"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida se pode efetuar a Sangria  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cSangTroc == "X" .AND. !lLibSan
			lLibSan := LjProfile(5,@cSupCaixa,,,)
			lRet 	:= lLibSan
		EndIf

	EndCase
Return(lRet)

/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Lj350Panel³Autora ³Solange Zanardi        ³ Data ³ 23/01/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Controla a sequência dos painéis de acordo com as permis-  ³±±
±±³          ³ soes do caixa.                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Lj350Panel(nExp1,cExp2,lExp3,cExp4,cExp5,cExp6,lExp7       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Parametros| nExp1 - Controle de número de painel                       ³±±
±±|          | cExp2 - Controle do tipo de operacao next ou back          ³±±
±±|          | lExp3 - Indica se utiliza conferencia de caixa             ³±±
±±|          | cExp4 - Permissao do caixa para utilização de imp.fiscal   ³±±
±±|          | cExp5 - Permissao do caixa para emissao de Reducao Z       ³±±
±±|          | cExp6 - Permissao do caixa para digitacao de sangria       ³±±
±±|          | lExp7 - Indica se utiliza impressora fiscal                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA350                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function lj350Panel(	nPanel   	,cTipo    	,lLibConf	,cUsaFiscal	,;
	cReducaoZ	,cSangTroc	,lImpFis 	,nSeq      	)

	Local nPaineis := 0  // Numero dos paineis   
	Local lret := .T.

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
			Case nPanel == 1
			// Nao eh necessario a tela inicial do wizard.
			If cPaisLoc <> "BRA" .AND. nSeq <> 1
				oWizard:NPanel+=1
				oWizard:SetPanel(oWizard:NPanel)
			EndIf

			Case nPanel == 2
			If !lLibConf
				nPaineis := Iif(cSangTroc=="N",4,3)
				oWizard:NPanel+=nPaineis
			Else
				LjMsgRun( STR0063,,{|| Lj350Conf()} ) 					//"Aguarde... Verificando dados para a conferência de caixa..."
			EndIf

			Case nPanel == 3
			If cPaisLoc <> "BRA" .AND. nSeq <> 1
				nPaineis := 1			
				oWizard:NPanel+=nPaineis				
			EndIf
			If ExistBlock("LJ35001")
				lRet :=	ExecBlock( "LJ35001", .F., .F. )
				If ValType( lRet ) <> "L"
					lRet := .T.
				EndIf
			EndIf

			Case nPanel == 4
			If cSangTroc=="N"
				nPaineis := 2
				oWizard:NPanel+=nPaineis
			EndIf

			Case nPanel == 6
			If cPaisLoc <> "BRA" .AND. nSeq <> 1
				nPaineis := 3			
				oWizard:NPanel+=nPaineis
			EndIf

			Case nPanel == 7
			If !lImpFis .OR. cUsaFiscal == "N"
				nPaineis := 2
				oWizard:NPanel+=nPaineis
			EndIf

			Case nPanel == 8
			If cReducaoZ == "N"
				nPaineis := 1
				oWizard:NPanel+=nPaineis
			EndIf
		EndCase

	ElseIf cTipo == "BACK"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Quando estou trabalhando com o método BACK        ³
		//³devo me atentar a soma de mais 1 no NPanel, pois o³
		//³próprio comando BACK já efetua um retorno.        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Do Case
			Case nPanel == 5
			If cPaisLoc <> "BRA" .AND. nSeq <> 1
				oWizard:NPanel-=1
			EndIf
			Case nPanel == 6
			If !lLibConf
				oWizard:NPanel-=3
			EndIf
			Case nPanel == 7
			If cSangTroc == "N"
				If lLibConf
					oWizard:NPanel-=2
				Else
					oWizard:NPanel-=4
				EndIf
			EndIf
			Case nPanel == 9
			If lImpFis .OR. cUsaFiscal == "N"
				oWizard:NPanel-=1
			EndIf
			Case nPanel == 10
			If cPaisLoc <> "BRA" .AND. nSeq <> 1
				oWizard:NPanel-=3
			ElseIf !lImpFis
				oWizard:NPanel-=2
			ElseIf cReducaoZ == "N"
				If !lImpFis .OR. cUsaFiscal == "N"
					oWizard:NPanel-=2
				Else
					oWizard:NPanel-=1
				EndIf
			EndIf
		EndCase
	EndIf

Return(lRet)

/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Lj350Conf ³Autora ³Solange Zanardi        ³ Data ³ 23/01/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funçaõ para montar a tela de conferência de caixa		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Lj350Conf()                             				  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Parametros|                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA350                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj350Conf()

	Local oBrowse
	Local nFor			:= 0													//Variavel utilizada para o laço do for	
	Local aMovCxa		:= {}													//Array que recebe da funcao de resumo os totais do caixa
	Local nOpc 			:= 1													//Controle da Getdados
	Local oFont			:= TFont():New( "Arial",08,13,,.T.)						//Fonte usada na tela
	Local aCaixaStr    	:= {}                                                  	//Vetor usado na funcao MovimCxLoc()
	Local aAreaSX3		:= SX3->(GetArea())

	Private aRotina    := {{,,0,4}}
	Private aDDown  	:= Array( 11 ) 	 										//Array criada para que possamos utilizar a função do resumo de caixa
	Private aDDownE    	:= Array(12)											//Localizacoes - Para uso do resumo de caixa localizado
	Private aDDownS    	:= Array(12)											//Localizacoes - Para uso do resumo de caixa localizado
	Private aDadosGer  	:= {}                                                  	//Localizacoes - Para uso do resumo de caixa localizado
	Private aContFina  	:= {0,0,0,0,0,0,0,0,0,0,0,0}							//Contadores utilizados nos tipos de finalizações

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Dados acumulados na aContFina³
	//³1 - CC - CARTAO DE CREDITO   ³
	//³2 - VA - VALES               ³
	//³3 - CO - CONVENIO            ³
	//³4 - FI - FINANCIADO          ³
	//³5 - CD - CARTAO DE DEBITO    ³
	//³6 - CH - CHEQUE              ³
	//³7 - OU - OUTROS              ³
	//³8 - RC - RECEBIMENTO         ³
	//³9 - RC - RECEB. DIVERSOS     ³
	//³10- FID- CARTAO FIDELIDADE  	³
	//³11- PD - Pagamento Digital  	³
	//³12- PX - Pagamento PIX	  	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se ja existir o acols nao monta a tela ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (Len(aCols) == 0) .OR. (cPaisLoc <> "BRA" .AND. AllTrim(SuperGetMV("MV_SIMB" + Str(nMoedaCorr,1,0))) <> AllTRim(aCols[1][1]))

		aHeader 	:= {}
		aCols   	:= {}
		nVltotal    := 0

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Montado o aHeader para o tratamento na tela de digitação ³
		//³de conferência                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SX3")
		SX3->(dbSetOrder(1))
		SX3->(dbSeek("SLT"))
		While !SX3->(Eof()) .AND. SX3->X3_ARQUIVO == "SLT"
			If Alltrim(SX3->X3_CAMPO) $ "LT_FORMPG|LT_DESFORM|LT_VLRDIG"
				If Alltrim(SX3->X3_CAMPO) == "LT_VLRDIG"
					cValidacao := "Lj350Vld()"
				Else
					cValidacao := SX3->X3_VALID
				EndIf
				Aadd(aHeader,{	Trim(X3TITULO()),	X3_CAMPO,		X3_PICTURE,		X3_TAMANHO,;
				X3_DECIMAL,			cValidacao,		X3_USADO,		X3_TIPO,;
				X3_ARQUIVO })
			Endif
			SX3->(dbSkip())
		EndDo

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Executa o mesmo procedimento da montagem do Resumo de Caixa³
		//³para poder montar o aCols                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cPaisLoc == "BRA"
			aMovCxa := MovimCaixa(cCaixa,dDataBase,Nil,@aDDown	,@aContFina)
		Else
			MovimCxLoc(@aMovCxa,aCaixaStr,cCaixa,dDataBase,nMoedaCorr,MsDecimais(nMoedaCorr))
			aDel(aMovCxa,2)
			aSize(aMovCxa, Len(aMovCxa)-1)
		EndIf
		Lj350Vend(aMovCxa)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta tela para informar conferência de caixa³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		@ 003,050 Say STR0043 Of oWizard:oMPanel[3] Pixel						//"Digite o valor de cada uma das formas de pagamento:"
		@ 020,055 Say STR0044 Of oWizard:oMPanel[3] Pixel						//"Caixa"
		@ 019,075 Get cCaixa  	When .F. Size 20,8 Of oWizard:oMPanel[3] Pixel
		@ 019,100 Get cNomCaixa When .F. Size 50,8 Of oWizard:oMPanel[3] Pixel

		If ValType(oGet) == "U"
			oGet := MsGetDados():New(032,052,120,245,nOpc,,,"",.F.,{"LT_VLRDIG"},2,,,,,,,oWizard:oMPanel[3])
			oGet:oBrowse:bEditCol :={ || oGet:oBrowse:GoDown(), oGet:LinhaOk()}
			oGet:nMax := Len(aCols)
		Else
			oGet:oBrowse:Refresh()
		EndIf

		@ 124,130 Say STR0045  Font oFont Color CLR_HBLUE Of oWizard:oMPanel[3] Pixel	//Total Digitado:
		@ 124,197 Say oVltotal Var nVltotal Picture PesqPict("SLT","LT_VLRDIG",_PICTURE) Size 50,21 Font oFont Color CLR_HBLUE Of oWizard:oMPanel[3] Pixel
	Endif
	RestArea(aAreaSX3)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³LJ350Vend ³Autora ³Solange Zanardi        ³ Data ³ 26/01/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Func„o que alimenta totalizadores por referˆncia e          ³±±
±±³          ³vetores de Dados recebidos da funçãpo de resumo de caixa    ³±±
±±³          ³aCaixa.                          				   		      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Lj350Vend(aExp1)                      				  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Parametros| aExp1 - Array vinda da MovimCaixa com mov. do dia          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³LOJA350()                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj350Vend(aCaixa)

	Local cSimb	:= Substr(IIf(Empty(SuperGetMV("MV_SIMB"+Str(nMoedaCorr,1,0))),"R$",SuperGetMV("MV_SIMB"+Str(nMoedaCorr,1,0))),1,3) //Simbolo
	Local nFor	:= 1		// Contador de For
	Local lL1VLRPGDG:= SL1->(ColumnPos("L1_VLRPGDG")) > 0 .AND. SL1->(ColumnPos("L1_VLRPGPX")) > 0 //Verifica se existe o campo onde é gravado o valor da venda paga em Pagamento Digital e PIX

	aVendas 	:= {}
	aSangrias 	:= {}

	aAdd(aSangrias, {cSimb, Substr(Alltrim(Upper(Tabela("24",cSimb,.F.))),1,25),	aCaixa[P_SANG_DINHEIRO]  })
	aAdd(aSangrias, {"CH",  Substr(Alltrim(Upper(Tabela("24","CH" ,.F.))),1,25),	aCaixa[P_SANG_CHEQUE]    })
	aAdd(aSangrias, {"CC",  Substr(Alltrim(Upper(Tabela("24","CC" ,.F.))),1,25),	aCaixa[P_SANG_CARTAO]    })
	aAdd(aSangrias, {"VA",  Substr(Alltrim(Upper(Tabela("24","VA" ,.F.))),1,25),	aCaixa[P_SANG_VALE]      })
	aAdd(aSangrias, {"CO",  Substr(Alltrim(Upper(Tabela("24","CO" ,.F.))),1,25),	aCaixa[P_SANG_CONVENIO]  })
	aAdd(aSangrias, {"FI",  Substr(Alltrim(Upper(Tabela("24","FI" ,.F.))),1,25),	aCaixa[P_SANG_FINANCIADO]})
	aAdd(aSangrias, {"CD",  Substr(Alltrim(Upper(Tabela("24","CD" ,.F.))),1,25),	aCaixa[P_SANG_DEBAUTO]   })
	aAdd(aSangrias, {"DV",  Substr(Alltrim(Upper(STR0050)),1,25),					aCaixa[P_DEVOLUCAO]      })  // DEVOLUCOES.
	aAdd(aSangrias, {"TO",  Substr(Alltrim(Upper(STR0060)),1,25),					aCaixa[P_TRANSF_ORIGEM]  })  // TRANSFERENCIAS.
	aAdd(aSangrias, {"PG",  Substr(Alltrim(Upper(STR0049)),1,25),					aCaixa[P_PAGAMENTOS]     })  // PAGAMENTOS.
	aAdd(aSangrias, {"OU",  Substr(Alltrim(Upper(STR0051)), 01, 25),				aCaixa[P_SANG_OUTROS]    })  // OUTROS.

	If lL1VLRPGDG
		aAdd(aSangrias, {"PD",  Substr(Alltrim(Upper(Tabela("24","PD" ,.F.))),1,25),	aCaixa[P_SANG_PAGDIG]      })
		aAdd(aSangrias, {"PX",  Substr(Alltrim(Upper(Tabela("24","PX" ,.F.))),1,25),	aCaixa[P_SANG_PAGPIX]      })
	EndIf

	aAdd(aVendas,   {cSimb, Substr(Alltrim(Upper(Tabela("24",cSimb,.F.))),1,25),	aCaixa[P_VEND_DINHEIRO]  })
	aAdd(aVendas,   {"CH",  Substr(Alltrim(Upper(Tabela("24","CH" ,.F.))),1,25),	aCaixa[P_VEND_CHEQUE]    })
	aAdd(aVendas,   {"CC",  Substr(Alltrim(Upper(Tabela("24","CC" ,.F.))),1,25),	aCaixa[P_VEND_CARTAO]    })
	aAdd(aVendas,   {"VA",  Substr(Alltrim(Upper(Tabela("24","VA" ,.F.))),1,25),	aCaixa[P_VEND_VALE]      })
	aAdd(aVendas,   {"CO",  Substr(Alltrim(Upper(Tabela("24","CO" ,.F.))),1,25),	aCaixa[P_VEND_CONVENIO]  })
	aAdd(aVendas,   {"FI",  Substr(Alltrim(Upper(Tabela("24","FI" ,.F.))),1,25),	aCaixa[P_VEND_FINANCIADO]})
	aAdd(aVendas,   {"CD",  Substr(Alltrim(Upper(Tabela("24","CD" ,.F.))),1,25),	aCaixa[P_VEND_DEBAUTO]   })
	aAdd(aVendas,   {"CR",  Substr(Alltrim(Upper(STR0061)),1,25),					aCaixa[P_VEND_CREDITO]   }) // CREDITOS.
	aAdd(aVendas,   {"TD",  Substr(Alltrim(Upper(STR0060)),1,25),					aCaixa[P_TRANSF_DESTINO] }) // TRANSERENCIAS.
	aAdd(aVendas,   {"RC",  Substr(Alltrim(Upper(STR0062)),1,25),					aCaixa[P_RECEBIMENTOS]   }) // RECEBIMENTO.
	aAdd(aVendas,   {"OU",  Substr(Alltrim(Upper(STR0051)), 01, 25),				aCaixa[P_VEND_OUTROS]    }) // OUTROS.

	If lL1VLRPGDG
		aAdd(aVendas,   {"PD",  Substr(Alltrim(Upper(Tabela("24","PD" ,.F.))),1,25),	aCaixa[P_VEND_PAGDIG]   })
		aAdd(aVendas,   {"PX",  Substr(Alltrim(Upper(Tabela("24","PX" ,.F.))),1,25),	aCaixa[P_VEND_PAGPIX]   })
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carregando o aCols com os dados a serem digitados pelo operador³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nFor := 1 To Len(aVendas)
		aadd(aCols,{ aVendas[nFor][1] , aVendas[nFor][2] , 0 , aVendas[nFor][3] , aSangrias[nFor][3] })
	Next nFor

Return(.T.)

/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Lj350Vld ³Autora ³Solange Zanardi        ³ Data ³ 23/01/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Funcao para validação do valor digitado pelo operador 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Lj350Vld()                              				  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Parametros|                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA350                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj350Vld()
	Local xRet									//Retorno do função do PE

	Local lRet		:= .T. 						//Retorno da função
	Local lLJ7070	:= ExistBlock("LJ7070")		//Verifica a existencia do PE LJ7070

	Local nTot 		:= 0


	nVltotal 	:= 0

	If M->LT_VLRDIG < 0 
		MsgStop(STR0046) 														//"Os valores de numerários não podem ser negativos"
		lRet := .F.
	EndIf

	For nTot := 1 To Len(aCols)
		nVlTotal +=	Iif(nTot==N,M->LT_VLRDIG,aCols[nTot,3])
	Next nTot

	ObjectMethod(oVltotal,"SetText(nVltotal)")
	oVlTotal:Refresh()

	If lLJ7070
		xRet	:=	ExecBlock("LJ7070", .F. , .F.)
		If ValType(xRet) == "L"
			lRet	:=	xRet
		EndIf
	EndIf

Return lRet

/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Lj350Proc ³Autora ³Solange Zanardi        ³ Data ³ 23/01/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Chamada de todos os processos que compões o fechamento     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Lj350Proc(nExp1,nExp2,lExp3,nExp4,cExp5,lExp6,nExp7,;      ³±±
±±³          |          cExp8,lExp9,cExp10,lExp11)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Parametros| nExp1 - Indica se foi setado no painel 1=S 2=N Acum.Diario ³±±
±±|          | nExp2 - Indica se foi setado no painel 1=S 2=N Rel.Critica ³±±
±±|          | lExp3 - Verifica a utilização de impressora fiscal         ³±±
±±|          | nExp4 - Indica se foi setado no painel 1=S 2=N LeituraX    ³±±
±±|          | cExp5 - Permissao do caixa para utilizacao de imp.fiscal   ³±±
±±|          | lExp6 - Indica se o sup.liberou a utilização da imp.fiscal ³±±
±±|          | nExp7 - Indica se foi setado no painel 1=S 2=N ReduçãoZ    ³±±
±±|          | cExp8 - Permissao do caixa para abertura e fechamento      ³±±
±±|          | lExp9 - Indica se o sup.liberou a emissao da reducao Z     ³±±
±±|          | cExp10- Permissao do caixa para emissao de ReducaoZ        ³±±
±±|          | lExp11- Indica se o cliente utiliza conferencia de caixa   ³±±
±±|          | aExp12- Vetor com as moedas utilizadas                     ³±±
±±|          | nExp13- Sequencia dos paines                               ³±±
±±|          | aExp14- Vetor com as moedas do Sistema                     ³±±
±±|          | aExp15- Vetor com os simbolos do sistema                   ³±±
±±|          | aExp16- Vetor com os dados da forma de recebimento         ³±±
±±|          | lExp17- .T. Indica cancelamento do processo                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA350                                                    ³±±   
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj350Proc(	nAcuDiario	,nCritFch	,lImpFis	,nLeituraX	,;
	cUsaFiscal	,lLibFis	,nReducaoZ	,cFechCaixa	,;
	lLibReZ		,cReducaoZ	,lLibConf	,aMoedaUt  	,;
	nSeq		,aMoedas	,aSimbs		,aReceb    	,;
	lCancel		)

	Local nCheck 			:= 1						//1=Sangria 2=Troco
	Local aMovim   			:= {}						//Recebe os dados do Resumo do Dia
	Local nPosMoeda			:= 0  						// Posicao do Campo Moeda em aReceb
	Local nTamLT_AGENCIA 	:= TamSx3("LT_AGENCIA")[1] 	// Tamanho de LT_AGENCIA
	Local nI       			:= 0                      	// Variavel contador
	Local lLj7071			:= ExistBlock("LJ7071")		// VerIfica se existe o ponto de entrada LJ7071
	Local xRet              := 0                        // Retorno do ponto de entrada LJ7071
	Local lEmitNfce			:= FindFunction("LjEmitNFCe") .AND.  LjEmitNFCe()		// Sinaliza se utiliza NFC-e

	nPosMoeda := aScan(aReceb, {|x| Trim(cMoedaCorr)$Trim(x[1]) })
	aReceb[nPosMoeda][02] := aClone(aDigSan)
	aReceb[nPosMoeda][03] := aClone(aCols)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Utilizo recursividade para que possam ser realizadas varias sangrias em³
	//³ sequencia, uma para cada moeda.                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lSangLoc .AND. cPaisLoc <> "BRA"
		If Len(aMoedas) <> 1
			AAdd(aMoedaUt,nMoedaCorr)
			Loja350(aMoedaUt,nSeq,@aReceb,@lCancel)
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Caso o usuario esteja realizando a sangria de outras moedas, que na seja a  ³
		//³ principal, ou cancelou a sequencia da rotina interrompe a execucao da mesma.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lCancel .OR. (nSeq <> 1)
			If lCancel
				MsgInfo(STR0065)  //"O processo de sangria foi interrompido pelo Usuario. Nao foi realizada a sangria de valores em nenhuma moeda e o caixa permanecera aberto."
			EndIf
			Return(.T.)
		EndIf
	ElseIf (cPaisLoc <> "BRA") .AND. (nSeq <> 1)
		Return(.T.)
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Realiza a sangria em todas as moedas selecionadas pelo usuario.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nI := 1 To Len(aReceb)                     
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Caso a posicao 2 e 3 estejam vazias significa que não foi realizada³
		//³ sangria na respectiva moeda.                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(aReceb[nI][02]) .AND. Empty(aReceb[nI][03])
			Loop
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Valoriza as variaveis referentes a moeda com os valores da ³
		//³ moeda que está sendo processada no momento.			       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nMoedaCorr <> Val(SubStr(aReceb[nI][01],1,1))
			nMoedaCorr := Val(SubStr(aReceb[nI][01],1,1))
			cMoedaCorr := SuperGetMV("MV_MOEDA"+Str(nMoedaCorr,1,0))    
			cSimbCorr  := Iif(nMoedaCorr <> 1,SuperGetMv("MV_SIMB"+Str(nMoedaCorr,1,0)),".")
			cSimbCorr  := cSimbCorr+Space(nTamLT_AGENCIA-Len(cSimbCorr))
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava a Conferência do Caixa |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aCols := aClone(aReceb[nI][03])
		If lLibConf .AND. Len(aCols) > 0
			Lj350GrvCon()
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Grava Sangrias              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aDigSan := aClone(aReceb[nI][02])
		If Len(aDigSan) > 0
			If SuperGetMV("MV_LJ350MV",,2) == 1
				//Somente deixa o valor informado em Dinheiro. Zera os valores das demais formas de pagamento para nao gerar movimentacao
				aDigSan[1][02] := 0 //Cheque
				aDigSan[1][03] := 0 //Cartao de Credito
				aDigSan[1][04] := 0 //Vales
				aDigSan[1][05] := 0 //Convenio
				aDigSan[1][06] := 0 //Financiado
				aDigSan[1][07] := 0 //Cartao de Debito
				aDigSan[1][08] := 0 //Outros
				aDigSan[1][09] := 0 //Pagamento Digital
				aDigSan[1][10] := 0 //Pagamento PIX
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Posicionamento da aDigSan: Dados digitados na Sangria³
			//³01 - Dinheiro                                        ³
			//³02 - Cheques                                         ³
			//³03 - Cartao                                          ³
			//³04 - Vales                                           ³
			//³05 - Convenio                                        ³
			//³06 - Financiado                                      ³
			//³07 - Debito Automatico                               ³
			//³08 - Outros                                          ³
			//³09 - Pagamento Digital                               ³
			//³10 - Pagamento PI	X                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lRet := Frt050SE5(nCheck       	,cCodOrigem   	,cCodDestin    ,aDigSan[1][1],;
								aDigSan[1][2]	,aDigSan[1][3]	,aDigSan[1][7]	,aDigSan[1][6],;
								aDigSan[1][5]	,aDigSan[1][4]	,aDigSan[1][8]	,aSimbs       ,;
								.F.				, .T.			, aDigSan[1][9]	,aDigSan[1][10])
			If !lRet 
				MsgStop(STR0032) 													//"Problemas na gravação da sangria, impossível continuar o fechamento"
				Return(.F.)
			Else
				If ExistBlock("Frt050ST")                                                          
					ExecBlock("Frt050ST",.F.,.F.,{nCheck       ,cSupCaixa     ,aDigSan[1][1],aDigSan[1][2],;
								aDigSan[1][3],aDigSan[1][7],aDigSan[1][6],aDigSan[1][5],;
								aDigSan[1][4],aDigSan[1][8],aDigSan[1][9],aDigSan[1][10]})
				EndIf		   	  
			EndIf			
		EndIf   
	Next nI

	If lLj7071 // Ponto de entrada para controle de execucao da funcao de Acumulados Diarios (Lj320Processa)
		xRet	:=	ExecBlock("LJ7071",.F.,.F.,{nAcuDiario})
		If ValType(xRet) == "N"
			nAcuDiario	:=	xRet
		EndIf 
	EndIf			

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processa Acumulados diarios ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nAcuDiario == 1
		Lj320Processa(dDataBase,.F.,.F.)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Leitura X				   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lEmitNfce .AND. lImpFis .AND. nLeituraX == 1 .AND. (lLibFis .OR. cUsaFiscal	== "S")
		IfLeituraX(nHdlECF)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Reducao Z				   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lEmitNfce .AND. lImpFis .AND. nReducaoZ == 1 .AND. (lLibFis .OR. cUsaFiscal	== "S")
		If lLibReZ .OR. cReducaoZ == "S"
			Lj160Leitura()
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Efetua Fechamento do caixa  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cx_abre_fecha(cCaixa,"F")
	MsgInfo(STR0033) 			//"Fechamento de caixa efetuado com sucesso!!!"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Realiza a sangria em todas as moedas selecionadas pelo usuario.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nI := 1 To Len(aReceb)                     
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Caso a posicao 2 e 3 estejam vazias significa que não foi realizada³
		//³ sangria na respectiva moeda.                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Empty(aReceb[nI][02]) .AND. Empty(aReceb[nI][03])
			Loop
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Valoriza as variaveis referentes a moeda com os valores da ³
		//³ moeda que está sendo processada no momento.			       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nMoedaCorr <> Val(SubStr(aReceb[nI][01],1,1))
			nMoedaCorr := Val(SubStr(aReceb[nI][01],1,1))
			cMoedaCorr := SuperGetMV("MV_MOEDA"+Str(nMoedaCorr,1,0))    
			cSimbCorr  := Iif(nMoedaCorr <> 1,SuperGetMv("MV_SIMB"+Str(nMoedaCorr,1,0)),".")
			cSimbCorr  := cSimbCorr+Space(nTamLT_AGENCIA-Len(cSimbCorr))
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Relatório de Crítica de Fechamento |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lLibConf .AND. nCritFch == 1
			LjMsgRun(STR0019,,{|| Lj350RelCf() })									//"Aguarde... Preparando dados para emissão do relatório de conferência"
		EndIf
	Next nI

Return(.T.)

/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Lj350MonSa³Autora ³Solange Zanardi        ³ Data ³ 23/01/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta tela para a inclusao de sangrias no caixa            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Lj350MonSa(nExp1,nExp2,nExp3,nExp4,nExp5,nExp6,nExp7,nExp8)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Parametros| nExp1 - Valor em Dinheiro                                  ³±±
±±|          | nExp2 - Valor em Cheques                                   ³±±
±±|          | nExp3 - Valor em Cartao de Credito                         ³±±
±±|          | nExp4 - Valor dos Vales                                    ³±±
±±|          | nExp5 - Valor de Convenios                                 ³±±
±±|          | nExp6 - Valor Financiado                                   ³±±
±±|          | nExp7 - Valor do Cartão de Débito                          ³±±
±±|          | nExp8 - Valor Outros                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA350                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj350MonSa(	nDinheir	,nCheques	,nCartao	,nVales		,;
						nConveni	,nFinanc 	,nVlrDebi	,nOutros	,;
						nVlrPagDig	,nVlrPagPix	)

	Local nCheck		:= 2							//1=Sangria 2=Troco
	Local lLibConf		:= SuperGetMv("MV_LJLIBCF")		//Verifica se cliente utiliza o processo de conferência de caixa
	Local oCodOrigem	:= Nil							// Objeto MsGet do Código de Origem
	Local oCodDestin	:= Nil							// Objeto MsGet do Código de Destino
	Local oDinheir		:= Nil							// Objeto MsGet do Dinheiro
	Local oCheques		:= Nil							// Objeto MsGet do Cheque
	Local oCartao		:= Nil							// Objeto MsGet do Cartão
	Local oVlrDebi		:= Nil							// Objeto MsGet do Valor Débito
	Local oFinanc		:= Nil							// Objeto MsGet do Financiamento
	Local oConveni		:= Nil							// Objeto MsGet do Convênio
	Local oVales		:= Nil							// Objeto MsGet do Vale
	Local oOutros		:= Nil 							// Objetos da tela de Sangria
	Local oPagDig		:= Nil 							// Objetos MsGet do Pagamento Digital
	Local oPagPix		:= Nil 							// Objetos MsGet do Pagamento PIX
	Local lPagDigtal	:= SL1->(ColumnPos("L1_VLRPGDG")) > 0 .AND. SL1->(ColumnPos("L1_VLRPGPX")) > 0 // Indica o uso de Pagamentos Digitais e PIX

	Default nVlrPagDig 	:= 0
	Default nVlrPagPix	:= 0

	If ExistBlock("FRT050SA")
		aRet 		:= ExecBlock("FRT050SA",.F.,.F.,{1,cCodOrigem,cCodDestin})
		If ValType( aRet ) = "A" .AND. Len( aRet ) >= 11
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

			If Len(aRet) > 11
				nVlrPagDig := aRet[12]
				nVlrPagPix := aRet[13]
			EndIf

		EndIf
	EndIf

	SX5->(DbSetOrder(1))																			// Primeiro indice para validacao do caixa digitado
	SA6->(DbSetOrder(1)) 																			// Primeiro indice para obtencao da Agencia/Conta para geracao do SE5

	@ 003,050 Say STR0040 Size 50,10 Of oWizard:oMPanel[6] Pixel									//"Do Caixa: "	
	@ 001,080 MsGet oCodOrigem Var cCodOrigem When .F. Size 30,10 Of oWizard:oMPanel[6] Pixel 

	@ 003,117 Say STR0041 Size 50,10 Of oWizard:oMPanel[6] Pixel  									//"Para o Caixa:"
	@ 001,157 MsGet oCodDestin Var cCodDestin F3 "23" Size 30,10 Of oWizard:oMPanel[6] Pixel  ;
	Valid SX5->(DbSeek(xFilial("SX5")+"23"+cCodDestin)) .AND. SA6->(DbSeek(xFilial("SA6")+cCodDestin) .AND. cCodDestin <> cCaixa .AND. ;
	IIF(A6_BLOCKED == "1",(MsgStop(STR0069,STR0070),.F.), .T. )) //"Banco bloqueado, selecione outro banco."###"Atenção"

	If lPagDigtal
		@ 015,050 To 155,247 Of oWizard:oMPanel[6] Pixel
	Else
		@ 015,050 To 138,247 Of oWizard:oMPanel[6] Pixel
	EndIf

	@ 018,057 Say STR0052 Size  60,10 Of oWizard:oMPanel[6]  Pixel 															//"Dinheiro:"
	@ 018,117 MsGet oDinheir Var nDinheir Picture PesqPict("SL1","L1_DINHEIR",_PICTURE,nMoedaCorr) 	;
	Size  70,10 Of oWizard:oMPanel[6]  	Pixel  RIGHT ;
	Valid Iif( lLibConf , Lj350Alert(nDinheir <= aCols[1,3] .AND. nDinheir >= 0, STR0052, aCols[1][3]) , nDinheir >= 0 )	//"Dinheiro:"

	@ 031,057 Say STR0053 Size  60,10 Of oWizard:oMPanel[6]  Pixel  							   							//"Cheques:"
	@ 031,117 MsGet oCheques Var nCheques Picture PesqPict("SL1","L1_CHEQUES",_PICTURE,nMoedaCorr) 	;
	Size  70,10 Of oWizard:oMPanel[6]  	Pixel  RIGHT ;
	Valid Iif( lLibConf , Lj350Alert(nCheques <= aCols[2,3] .AND. nCheques >= 0, STR0053, aCols[2][3]) , nCheques >= 0 )	//"Cheques:"

	@ 044,057 Say STR0054 Size  60,10 Of oWizard:oMPanel[6]  Pixel 															//"Cartão de Crédito:"
	@ 044,117 MsGet oCartao Var nCartao Picture PesqPict("SL1","L1_CARTAO",_PICTURE,nMoedaCorr) 	;
	Size  70,10 Of oWizard:oMPanel[6]  	Pixel  RIGHT ;
	Valid Iif( lLibConf , Lj350Alert(nCartao <= aCols[3,3] .AND. nCartao >= 0, STR0054, aCols[3][3]), nCartao >= 0 )		//"Cartão de Crédito:"

	@ 057,057 Say STR0055 Size  60,10 Of oWizard:oMPanel[6]  Pixel 															//"Cartão de Débito:"
	@ 057,117 MsGet oVlrDebi Var nVlrDebi Picture PesqPict("SL1","L1_VLRDEBI",_PICTURE,nMoedaCorr) 	;
	Size  70,10 Of oWizard:oMPanel[6]  	Pixel  RIGHT ;
	Valid Iif( lLibConf , Lj350Alert(nVlrDebi <= aCols[7,3] .AND. nVlrDebi >= 0, STR0055, aCols[7][3]) , nVlrDebi >= 0)		//"Cartão de Débito:"

	@ 070,057 Say STR0056 Size  60,10 Of oWizard:oMPanel[6]  Pixel 															//"Financiado:"
	@ 070,117 MsGet oFinanc Var nFinanc Picture PesqPict("SL1","L1_FINANC",_PICTURE,nMoedaCorr) 	;
	Size  70,10 Of oWizard:oMPanel[6]  	Pixel  RIGHT ;
	Valid Iif( lLibConf , Lj350Alert(nFinanc <= aCols[6,3] .AND. nFinanc >= 0, STR0056, aCols[6][3]) , nFinanc >= 0 )		//"Financiado:"

	@ 083,057 Say STR0057 Size  60,10 Of oWizard:oMPanel[6]  Pixel 															//"Convênio:"
	@ 083,117 MsGet oConveni Var nConveni Picture PesqPict("SL1","L1_CONVENI",_PICTURE,nMoedaCorr) 	;
	Size  70,10 Of oWizard:oMPanel[6]  	Pixel  RIGHT ;
	Valid Iif( lLibConf , Lj350Alert(nConveni <= aCols[5,3] .AND. nConveni >= 0, STR0057, aCols[5][3]) , nConveni >= 0 ) 	//"Convênio:"

	@ 096,057 Say STR0058 Size 60,10 Of oWizard:oMPanel[6]  Pixel  															//"Vales:"
	@ 096,117 MsGet oVales Var nVales Picture PesqPict("SL1","L1_VALES",_PICTURE,nMoedaCorr) 		;
	Size  70,10 Of oWizard:oMPanel[6]  	Pixel  RIGHT ;
	Valid Iif( lLibConf , Lj350Alert(nVales <= aCols[4,3] .AND. nVales >= 0 ,STR0058, aCols[4][3]), nVales >= 0 )			//"Vales:"

	@ 109,057 Say STR0059 Size 60,10 Of oWizard:oMPanel[6]  Pixel 															//"Outros:"
	@ 109,117 MsGet oOutros Var nOutros Picture PesqPict("SL1","L1_OUTROS",_PICTURE,nMoedaCorr) 	;
	Size  70,10 Of oWizard:oMPanel[6]  	Pixel  RIGHT ;
	Valid Iif( lLibConf , Lj350Alert(nOutros <= aCols[8,3] .AND. nOutros >= 0, STR0059, aCols[8][3]) , nOutros >= 0 )		//"Outros:"

	If lPagDigtal
		@ 122,057 Say STR0075 Size 60,10 Of oWizard:oMPanel[6]  Pixel																// "Pagamento Digital:"
		@ 122,117 MsGet oPagDig Var nVlrPagDig Picture PesqPict("SL1","L1_VLRPGDG",_PICTURE,nMoedaCorr) 	;
		Size  70,10 Of oWizard:oMPanel[6]  	Pixel  RIGHT ;
		Valid Iif( lLibConf , Lj350Alert(nVlrPagDig <= aCols[12,3] .AND. nVlrPagDig >= 0, STR0075, aCols[12][3]) , nVlrPagDig >= 0 ) // "Pagamento Digital:"
	
		@ 134,057 Say STR0076 Size 60,10 Of oWizard:oMPanel[6]  Pixel																// "Pagamento PIX:"
		@ 134,117 MsGet oPagPix Var nVlrPagPix Picture PesqPict("SL1","L1_VLRPGPX",_PICTURE,nMoedaCorr) 	;
		Size  70,10 Of oWizard:oMPanel[6]  	Pixel  RIGHT ;
		Valid Iif( lLibConf , Lj350Alert(nVlrPagPix <= aCols[12,3] .AND. nVlrPagPix >= 0, STR0076, aCols[13][3]) , nVlrPagPix >= 0 ) // "Pagamento PIX"
	EndIf

Return(.T.)

/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Lj350ValSa³Autora ³Solange Zanardi        ³ Data ³ 23/01/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Carrego a array aDigSan de acordo com os dados digitados   ³±±
±±³          ³ em tela e tbm suprindo as necessidades das funções do Front³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Lj350ValSa(nExp1,nExp2,nExp3,nExp4,nExp5,nExp6,nExp7,nExp8)³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Parametros| nExp1 - Valor em Dinheiro                                  ³±±
±±|          | nExp2 - Valor em Cheques                                   ³±±
±±|          | nExp3 - Valor em Cartao de Credito                         ³±±
±±|          | nExp4 - Valor dos Vales                                    ³±±
±±|          | nExp5 - Valor de Convenios                                 ³±±
±±|          | nExp6 - Valor Financiado                                   ³±±
±±|          | nExp7 - Valor do Cartão de Débito                          ³±±
±±|          | nExp8 - Valor Outros                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA350                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj350ValSa(	nDinheir	,nCheques	,nCartao 	,nVales		,;
						nConveni	,nFinanc 	,nVlrDebi	,nOutros	,;
						nVlrPagDig	,nVlrPagPix )

	Local lRet    	:= .T. 	// Variavel logica do Retorno
	Local nTotSan 	:= 0	// Acumulador de Valores do Cupom

	Default nVlrPagDig := 0
	Default nVlrPagPix := 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posicionamento da aDigSan: Dados digitados na Sangria³
	//³01 - Dinheiro                                        ³
	//³02 - Cheques                                         ³
	//³03 - Cartao                                          ³
	//³04 - Vales                                           ³
	//³05 - Convenio                                        ³
	//³06 - Financiado                                      ³
	//³07 - Debito Automatico                               ³
	//³08 - Outros                                          ³
	//³09 - Pagamento Digital                               ³
	//³10 - Pagamento PIX                               	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	aDigSan 	:= {}
	nTotSan 	:= (nDinheir + nCheques + nCartao + nVales +;
					nConveni + nFinanc + nVlrDebi + nOutros +;
					nVlrPagDig + nVlrPagPix )

	If	nDinheir 	< 0 .OR.	nCheques	< 0	.OR.	nCartao		< 0	.OR.	nVales<0	.OR.;
		nConveni	< 0	.OR.	nFinanc		< 0	.OR.	nVlrDebi	< 0	.OR.	nOutros<0	.OR.;
		nVlrPagDig	< 0 .OR.	nVlrPagPix	< 0

		MsgStop(STR0042) 														//"Não podem ser efetuadas Sangrias com valores negativos, corrija-os..."
		lRet := .F.
	Else
		If nTotSan > 0
			aadd(aDigSan, {	nDinheir	,; 	//01 - Dinheiro
							nCheques	,; 	//02 - Cheques
							nCartao		,;	//03 - Cartao Credito
							nVales		,;	//04 - Vales
							nConveni	,;	//05 - Convenio
							nFinanc 	,;	//06 - Financiado
							nVlrDebi	,;	//07 - Cartao de Debito
							nOutros		,;	//08 - Outros
							nVlrPagDig	,;	//09 - Pagamento Digital
							nVlrPagPix	})	//10 - Pagamento PIX

			lRet := .T.
		EndIf	
	EndIf

Return(lRet)

/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Lj350LeVal³Autora ³Solange Zanardi        ³ Data ³ 23/01/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Se o usuario escolheu a opção de levar os valores digitados³±±
±±³          ³ na conf. para a tela de sangrias carrego os dados automat. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Lj350LeVal(nExp1,nExp2,nExp3,nExp4,nExp5,nExp6,nExp7,nExp8,;³±±
±±³          |          nExp9)                                            |±±   
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Parametros| nExp1 - Indica se o operador optou em levar valores para a ³±±
±±|          |         tela de Sangrias                                   ³±±
±±|          | nExp2 - Valor em Dinheiro                                  ³±±
±±|          | nExp3 - Valor em Cheques                                   ³±±
±±|          | nExp4 - Valor em Cartao de Credito                         ³±±
±±|          | nExp5 - Valor dos Vales                                    ³±±
±±|          | nExp6 - Valor de Convenios                                 ³±±
±±|          | nExp7 - Valor Financiado                                   ³±±
±±|          | nExp8 - Valor do Cartão de Débito                          ³±±
±±|          | nExp9 - Valor Outros                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA350                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function lj350LeVal(	nLevaVlr,nDinheir	,nCheques	,nCartao 	,;
						nVales  ,nConveni	,nFinanc 	,nVlrDebi	,;
						nOutros	, nVlrPagDig,nVlrPagPix	)

	Local lLibConf		:= SuperGetMv("MV_LJLIBCF")				//Verifica se cliente utiliza o processo de conferência de caixa

	Default nVlrPagDig 	:= 0
	Default nVlrPagPix	:= 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posicionamento da aDigSan: Dados digitados na Sangria³
	//³01 - Dinheiro                                        ³
	//³02 - Cheques                                         ³
	//³03 - Cartao                                          ³
	//³04 - Vales                                           ³
	//³05 - Convenio                                        ³
	//³06 - Financiado                                      ³
	//³07 - Debito Automatico                               ³
	//³08 - Outros                                          ³
	//³09 - Pagamento Digital                               ³
	//³10 - Pagamento PIX                               	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If lLibConf .AND. nLevaVlr == 1 .AND. Len(aDigSan) == 0 .AND. Len(aCols) > 0
		nDinheir := aCols[1,3]
		nCheques := aCols[2,3]
		nCartao  := aCols[3,3]
		nVales   := aCols[4,3]
		nConveni := aCols[5,3]
		nFinanc  := aCols[6,3] 
		nVlrDebi := aCols[7,3]
		nOutros  := aCols[11,3]

		If Len(aCols) > 11
			nVlrPagDig	:= aCols[12,3]
			nVlrPagPix	:= aCols[13,3]
		EndIf

	EndIf

Return(.T.)

/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Lj350Grv ³Autora ³Vendas Clientes        ³ Data ³ 23/01/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Efetuo a gravação dos dados digitados pelo operador, lembran³±±
±±³          ³do que temos como premissa um fechamento por caixa pois     ³±±
±±³          ³não temos controle de turnos                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Lj350GrvCon()                           				  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Parametros|                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA350                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj350GrvCon()

	Local lRet 			:= .T. 								// Variavel logica de retorno
	Local cSeek 		:= Space(01)  						// String para Seek em SLT
	Local nFor 			:= 1           						// Contador 
	Local aID			:= {}								//[1]-CAIXA [2]-ESTACAO [3]-SERIE [4]-PDV
	Local lConfFecha	:= SuperGetMV("MV_LJCONFF",,.F.) .AND. IIf(FindFunction("LjUpd70Ok"),LjUpd70Ok(),.F.)	//Utiliza conferencia de fecha. de caixa
	Local aMov			:= {}								//Retorna o numero do movimento e data de abertura
	Local aDataHr 		:= {} 								//A data de fechamento do caixa deve ser a data da ECF ou data atual, nao a data base.
	Local nTamFP		:= TamSX3("LT_FORMPG")[1]          //Tamanho do campo de forma de pagamento
	Local nTamMV		:= TamSX3("LT_NUMMOV")[1]			//Tamanho do campo de movimento
	Local nTamADF		:= 0								//Tamanho do campo de administradora financeira
	Local cChave		:= ""

	If lConfFecha
		aID 	:= LjInfoCxAt(1,.T.)
		aDataHr := LjDtHrECF(.T.)
		aMov 	:= LjNumMov({"NUMMOV","DTABERT"})	
		nTamADF	:= TamSX3("LT_ADMIFIN")[1]
	Else
		aID 		:= Array(4)
		aID[1] 		:= PadR(AllTrim(xNumCaixa()),TamSX3("L1_OPERADO")[1])
		aID[2] 		:= PadR(AllTrim(LjGetStation("CODIGO")),TamSX3("LG_CODIGO")[1])
		aID[3] 		:= PadR(AllTrim(LjGetStation("SERIE")),TamSX3("LG_SERIE")[1])
		aID[4] 		:= PadR(AllTrim(LjGetStation("PDV")),TamSX3("LG_PDV")[1])
		aDataHr := LjDtHrECF(.T.)
		aAdd(aMov,LjNumMov())
		aAdd(aMov,Date())
	Endif
	dbSelectArea("SLT")
	SLT->(dbSetOrder(1))	//LT_FILIAL+LT_OPERADO+DTOS(LT_DTFECHA)+LT_FORMPG
	If lConfFecha
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Clonar a SLT para auxiliar o processo de exclusao ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ChkFile("SLT",.F.,"_SLT")
		dbSelectArea("_SLT")
		_SLT->(dbSetOrder(4))	//LT_FILIAL+LT_OPERADO+DTOS(LT_DTFECHA)+LT_FORMPG+LT_PDV+LT_NUMMOV+LT_ADMIFIN
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se nao utiliza conferencia de fechamento, excluir todos as conferencias da combinacao : OPERADOR + DATA FECHA  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cSeek := xFilial("SLT") + aID[1] + DtoS(aDataHr[1])
		If SLT->(dbSeek(cSeek))
			While  !SLT->(Eof()) .AND. SLT->LT_FILIAL + SLT->LT_OPERADO + DTOS(SLT->LT_DTFECHA) == cSeek
				If SLT->(Deleted())
					SLT->(dbSkip())
					Loop
				Endif	
				If (SLT->LT_AGENCIA == cSimbCorr) .AND. RecLock("SLT")
					SLT->(dbDelete())
					MsUnlock()
				EndIf
				SLT->(dbSkip())
			EndDo
		EndIf
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Incluindo Registros³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nFor := 1 To Len(aCols)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se utiliza conferencia de fechamento, excluir por conferencia  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lConfFecha
			cChave := xFilial("SLT")
			cChave += aID[1]								//OPERADOR
			cChave += DtoS(aDataHr[1])						//FECHAMENTO
			If cPaisLoc # "BRA"
				cChave += PadR(aCols[nFor][1] + Alltrim(Str(nMoedaCorr)),nTamFP)	//FORMA PAGTO
			Else
				cChave += PadR(aCols[nFor][1],nTamFP)		//FORMA PAGTO
			EndIf               
			cChave += aID[4]								//PDV
			cChave += PadR(aMov[1],nTamMV)					//MOVIMENTO
			cChave += Space(nTamADF)      					//AÊDM FIN
			cChave += DtoS(aMov[2])							//DATA MOVIMENTO
			If _SLT->(dbSeek(cChave))
				//Caso exista uma conferencia com a mesma chave unica (indice 04), excluir
				RecLock("_SLT",.F.)
				_SLT->(dbDelete())
				MsUnlock()
				dbCommit()
			Endif
		Endif
		RecLock("SLT",.T.)
		SLT->LT_FILIAL 	:= xFilial("SLT")
		SLT->LT_OPERADO	:= aID[1]
		SLT->LT_DTFECHA	:= aDataHr[1]
		SLT->LT_VLRDIG 	:= aCols[nFor][3]
		SLT->LT_SANPAR	:= aCols[nFor][5]
		SLT->LT_AGENCIA	:= cSimbCorr
		If SLT->(FieldPos("LT_DESFORM")) > 0
			SLT->LT_DESFORM := aCols[nFor][2]
		Endif	
		If SLT->(FieldPos("LT_ESTACAO")) > 0
			SLT->LT_ESTACAO := aID[2]
		Endif
		If SLT->(FieldPos("LT_PDV")) > 0
			SLT->LT_PDV := aID[4]
		Endif
		If SLT->(FieldPos("LT_SITUA")) > 0
			SLT->LT_SITUA := "RX"
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se Existir o Campo LT_NumMov,Grava o Numero do Ultimo Movimento do SLW ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SLT->(FieldPos("LT_NUMMOV"))>0
			SLT->LT_NUMMOV :=  aMov[1]
		EndIf
		If SLT->(FieldPos("LT_DTMOV"))>0
			SLT->LT_DTMOV :=  aMov[2]
		EndIf
		If cPaisLoc <> "BRA"
			If SLT->(FieldPos("LT_MOEDA")) > 0
				SLT->LT_MOEDA   := nMoedaCorr
				SLT->LT_FORMPG 	:= aCols[nFor][1] + Alltrim(Str(nMoedaCorr))
			EndIf	
		Else
			SLT->LT_FORMPG := aCols[nFor][1]  	
		EndIf                                                               
		MsUnlock()
	Next nFor
	If lConfFecha
		_SLT->(dbCloseArea())
	Endif

Return(lRet)


/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Lj350RelCf³Autora ³Solange Zanardi        ³ Data ³ 04/01/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera dados para emissão do relatório  de conferencia       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Lj350RelCf()                            				  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Parametros|                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA350                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj350RelCf()

	Local aMovim        := {}
	Local aCaixaStr     := {}     

	Private aDDown     	:= Array(11)				// Array criada para que possamos utilizar a função do resumo de caixa
	Private aDDownE     := Array(12)				// Localizacoes - Para uso do resumo de caixa localizado
	Private aDDownS     := Array(12)				// Localizacoes - Para uso do resumo de caixa localizado
	Private aDadosGer   := {}						// Localizacoes - Para uso do resumo de caixa localizado
	Private aContFina   := {0,0,0,0,0,0,0,0,0,0,0,0 }	// Contadores utilizados nos tipos de finalizações

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa o mesmo procedimento da montagem do Resumo de Caixa³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cPaisLoc == "BRA"
		aMovim := MovimCaixa(	cCaixa,		dDataBase,	Nil,	@aDDown,;
		@aContFina)
	Else
		MovimCxLoc(	@aMovim,		aCaixaStr,	cCaixa,		dDataBase,;
		nMoedaCorr,		MsDecimais(nMoedaCorr))
		aDel(aMovim,2)
		ASize(aMovim, Len(aMovim)-1)							
	EndIf
	Lj350Movim(aMovim)

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³LJ350Movim³Autora ³Solange Zanardi        ³ Data ³ 26/01/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Func„o para a montagem do resumo de caixa e divergência apos³±±
±±³          ³todas as gravações terem sido efetuadas                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Lj350Movim(aExp1)                     				  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Parametros| aExp1 - Array vinda da MovimCaixa com mov. do dia          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³LOJA350                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj350Movim(aCaixa)

	Local cSimb			:= Substr(IIf(Empty(SuperGetMV("MV_SIMB1")),"R$",SuperGetMV("MV_SIMB1")),1,2)
	Local nTroco    	:= aCaixa[P_TROCO]	// Troco
	Local aTotVen   	:= {}	// Total da Venda
	Local aTotSan 		:= {}	// Vetor com os dados de pagamento
	Local nTotCredito  	:= 0   	// Total do Credito
	Local nTotDebito   	:= 0	// Total do Debito
	Local nSaldFinal   	:= 0	// Troco + Credito
	Local aDigitado 	:= {}	// Vetor com o valor das vendas
	Local nTotDigi     	:= 0	// Total digitado 
	Local nTotSang		:= 0 	// Total da Venda
	Local nTotVend     	:= 0	// Total da Venda
	Local nFor			:= 1
	Local lL1VLRPGDG	:= SL1->(ColumnPos("L1_VLRPGDG")) > 0 .AND. SL1->(ColumnPos("L1_VLRPGPX")) > 0 //Verifica se existe o campo onde é gravado o valor da venda paga em Pagamento Digital e PIX

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Vou deixar todos os dados do Resumo de Caixa Prontos  ³
	//³para que o cliente possa alterar o RdMake de impressão³
	//³de divergências.                                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aadd(aTotSan,{cSimb, Substr(Alltrim(Upper(Tabela("24",cSimb,.F.))),1,25),	aCaixa[P_SANG_DINHEIRO  ]})
	aadd(aTotSan,{"CH",  Substr(Alltrim(Upper(Tabela("24","CH",.F.))),1,25),	aCaixa[P_SANG_CHEQUE    ]})
	aadd(aTotSan,{"CC",  Substr(Alltrim(Upper(Tabela("24","CC",.F.))),1,25),	aCaixa[P_SANG_CARTAO    ]})
	aadd(aTotSan,{"VA",  Substr(Alltrim(Upper(Tabela("24","VA",.F.))),1,25),	aCaixa[P_SANG_VALE      ]})
	aadd(aTotSan,{"CO",  Substr(Alltrim(Upper(Tabela("24","CO",.F.))),1,25),	aCaixa[P_SANG_CONVENIO  ]})
	aadd(aTotSan,{"FI",  Substr(Alltrim(Upper(Tabela("24","FI",.F.))),1,25),	aCaixa[P_SANG_FINANCIADO]})
	aadd(aTotSan,{"CD",  Substr(Alltrim(Upper(Tabela("24","CD",.F.))),1,25),	aCaixa[P_SANG_DEBAUTO   ]})
	aadd(aTotSan,{"OU",  Substr(Alltrim(Upper(STR0051)),1,25),					aCaixa[P_SANG_OUTROS    ]})  // OUTROS.
	aadd(aTotSan,{"DV",  Substr(Alltrim(Upper(STR0050)),1,25),					aCaixa[P_DEVOLUCAO      ]})  // DEVOLUCOES
	aadd(aTotSan,{"TO",  Substr(Alltrim(Upper(STR0060)),1,25),					aCaixa[P_TRANSF_ORIGEM  ]})  // TRANSFERENCIAS.
	aadd(aTotSan,{"PG",  Substr(Alltrim(Upper(STR0049)),1,25),					aCaixa[P_PAGAMENTOS     ]})  // PAGAMENTOS.

	If lL1VLRPGDG
		aadd(aTotSan,{"PD",  Substr(Alltrim(Upper(Tabela("24","PD",.F.))),1,25),	aCaixa[P_SANG_PAGDIG	]})
		aadd(aTotSan,{"PX",  Substr(Alltrim(Upper(Tabela("24","PX",.F.))),1,25),	aCaixa[P_SANG_PAGPIX	]})
	EndIf

	nTotDebito := 	aCaixa[P_SANG_DINHEIRO ] + aCaixa[P_SANG_CHEQUE     ] + ;
					aCaixa[P_SANG_CARTAO   ] + aCaixa[P_SANG_VALE       ] + ;
					aCaixa[P_SANG_CONVENIO ] + aCaixa[P_SANG_FINANCIADO ] + ;
					aCaixa[P_SANG_DEBAUTO  ] + aCaixa[P_PAGAMENTOS      ] + ;
					aCaixa[P_TRANSF_ORIGEM ] + aCaixa[P_DEVOLUCAO       ] + ;
					aCaixa[P_SANG_OUTROS   ] + aCaixa[P_SANG_PAGDIG 	] + ;
					aCaixa[P_SANG_PAGPIX	]

	aadd(aTotVen,{cSimb, Substr(Alltrim(Upper(Tabela("24",cSimb,.F.))),1,25),	aCaixa[P_VEND_DINHEIRO]   })
	aadd(aTotVen,{"CH",  Substr(Alltrim(Upper(Tabela("24","CH",.F.))),1,25),	aCaixa[P_VEND_CHEQUE]     })
	aadd(aTotVen,{"CC",  Substr(Alltrim(Upper(Tabela("24","CC",.F.))),1,25),	aCaixa[P_VEND_CARTAO]     })
	aadd(aTotVen,{"VA",  Substr(Alltrim(Upper(Tabela("24","VA",.F.))),1,25),	aCaixa[P_VEND_VALE]       })
	aadd(aTotVen,{"CO",  Substr(Alltrim(Upper(Tabela("24","CO",.F.))),1,25),	aCaixa[P_VEND_CONVENIO]   })
	aadd(aTotVen,{"FI",  Substr(Alltrim(Upper(Tabela("24","FI",.F.))),1,25),	aCaixa[P_VEND_FINANCIADO] })
	aadd(aTotVen,{"CD",  Substr(Alltrim(Upper(Tabela("24","CD",.F.))),1,25),	aCaixa[P_VEND_DEBAUTO]    })
	aadd(aTotVen,{"CR",  Substr(Alltrim(Upper(STR0061)),1,25),					aCaixa[P_VEND_CREDITO]    }) // CREDITOS.
	aadd(aTotVen,{"TD",  Substr(Alltrim(Upper(STR0060)),1,25),					aCaixa[P_TRANSF_DESTINO]  }) // TRANSERENCIAS.
	aadd(aTotVen,{"RC",  Substr(Alltrim(Upper(STR0062)),1,25),					aCaixa[P_RECEBIMENTOS]    }) // RECEBIMENTO.
	aadd(aTotVen,{"OU",  Substr(Alltrim(Upper(STR0051)),1,25),					aCaixa[P_VEND_OUTROS]     }) // OUTROS.

	If lL1VLRPGDG
		aadd(aTotVen,{"PD",  Substr(Alltrim(Upper(Tabela("24","PD",.F.))),1,25),	aCaixa[P_VEND_PAGDIG]	})
		aadd(aTotVen,{"PX",  Substr(Alltrim(Upper(Tabela("24","PX",.F.))),1,25),	aCaixa[P_VEND_PAGPIX]	})
	EndIf

	nTotCredito :=	aCaixa[P_VEND_DINHEIRO ] + aCaixa[P_VEND_CHEQUE     ] + ;
					aCaixa[P_VEND_CARTAO   ] + aCaixa[P_VEND_VALE       ] + ;
					aCaixa[P_VEND_CONVENIO ] + aCaixa[P_VEND_FINANCIADO ] + ;
					aCaixa[P_VEND_DEBAUTO  ] + aCaixa[P_VEND_CREDITO    ] + ;
					aCaixa[P_VEND_OUTROS   ] + aCaixa[P_TRANSF_DESTINO  ] + ;
					aCaixa[P_RECEBIMENTOS  ] + aCaixa[P_VEND_PAGDIG		] + ;
					aCaixa[P_VEND_PAGPIX	]

	nSaldFinal := nTroco + nTotCredito - nTotDebito
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|Fim da Geracao dos dados do Resumo de Caixa  |
	//|inclusive com as formas de pagamento que nao |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//|Vou montar uma array com a mesma ordem para os valores digitados     |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SLT")
	DbSetOrder(1)  // Ordem: Codigo + Data de Fechamento + Forma.
	For nFor := 1 To Len(aVendas)
		If DbSeek(xFilial("SLT") + cCaixa + dtos(dDataBase) + aTotVen[nFor][1] )
			aadd(aDigitado,{aVendas[nFor][1],aVendas[nFor][2],SLT->LT_VLRDIG})
			nTotDigi  += SLT->LT_VLRDIG
			nTotSang  += SLT->LT_SANPAR
			nTotVend  += aVendas[nFor][3]
		EndIf
	Next nFor

	// Executo o RdMake Padrão do Sistema.
	If ExistBlock("Lj350Imp")
		ExecBlock("Lj350Imp",.F.,.F.,{	aVendas,	aSangrias,		aDigitado,	nTotVend,;
		nTotSang,	nTotDigi,		nTroco,		aTotVen,;
		aTotSan,	nTotCredito,	nTotDebito,	nSaldFinal })
	EndIf

Return(.T.)

/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Lj350Red ³Autora ³Solange Zanardi        ³ Data ³ 23/01/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inibe ou Exibe a mensagem da Reducao Z.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Lj350Red(nExp1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Parametros| nExp1 - Valor do Objeto                 				  	  ³±±                                                        
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA350                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj350Red(nIt)
	If nIt == 1
		oSayRed:Show()	
	Else
		oSayRed:Hide()
	EndIf

Return(.T.)

/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Lj350Sai ³Autora ³Solange Zanardi        ³ Data ³ 23/01/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Confirmação de saída do assistente                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Lj350Sai(lExp1)                        					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Parametros| lExp1  -	Indicador de saída do painel                      ³±±
±±|          | lExp2  -	.T. Indica cancelamento do Processo               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA350                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj350Sai(lConfirma,lCancel)

	If lConfirma		
		If ValType(oGet) <> "U"
			oGet := Nil
		EndIf                          
		Return(.T.)		
	Else
		If MsgNoYes(STR0039)     												//"Deseja abandonar o assistente de fechamento ?"
			If ValType(oGet) <> "U"
				oGet := Nil
			EndIf     
			lCancel := .T.
			Return(.T.)
		EndIf	
	EndIf

Return(.F.)

/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Lj350Fim ³Autora ³Solange Zanardi        ³ Data ³ 23/01/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Solicita finalização de operação                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Lj350Fim()                             					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±|Parametros| aExp1 - Vetor com as moedas do sistema                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ LOJA350                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj350Fim(aMoedas)

	If (cPaisLoc <> "BRA") .AND. (Len(aMoedas) <> 1)
		If (lSangLoc := MsgNoYes(STR0066)) //"Deseja realizar sangria em mais alguma moeda?"
			Return(.T.)				
		EndIf
	EndIf

	If MsgNoYes(STR0031) 														//"Se voce confirmar os procedimentos de fechamento ou troca de turno de caixa serao efetuados."+CHR(13)+"Confirma ? " ### "Atencao!"
		Return(.T.)	
	EndIf	

Return(.F.)


/*/{Protheus.doc} Lj350Alert

Utilizado para Validação de formas de pagamento na tela Sangria de Caixa.

@type static function

@author Marisa Cruz
@since 29/01/2020
@version P12.1.25

@param lSentenca   , lógico  , Qual sentença satisfaz a Sangria de Caixa
@param cDescri     , caracter, Descrição das formas de pagamento
@param nLimite     , numérico, O limite digitado na tela anterior - Conferência de Caixa

@return Lógico, Validação da Sangria de Caixa por forma de pagamento

/*/
Static Function Lj350Alert(lSentenca, cDescri, nLimite)

Local lRet   := .T.
Local cMoeda := SuperGetMv("MV_SIMB" + Str(nMoedaCorr,1,0), .F., "R$")	// Simbolo da moeda principal

Default lSentenca   := .T.			//Qual sentença satisfaz a Sangria de Caixa
Default cDescri		:= ""			//Descrição da forma de pagamento
Default nLimite		:= 9999999		//O limite digitado na tela anterior - Conferência de Caixa

If !lSentenca
	MsgAlert(STR0071 + StrTran(cDescri,":","") + STR0072 + "(" + cMoeda + " " + Alltrim(Transform(nLimite, "@E 999,999,999.99")) + ")",STR0070) //"O valor em "###" deve ser menor ou igual ao digitado na Conferência de Caixa "###"Atenção"
	lRet := .F.
EndIf

Return lRet