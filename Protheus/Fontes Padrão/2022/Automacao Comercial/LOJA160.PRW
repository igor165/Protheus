#INCLUDE "LOJA160.CH"
#INCLUDE "FONT.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWADAPTEREAI.CH"         

#DEFINE MODELIMPRES "EPSON"

Static lZPend		:= .F. 			//verifica se redução Z estava pendente
Static lHomolPaf	:= LjHomolPaf()	//verifica se está em modo de homologação do PAF
Static lTPLPCL		:= HasTemplate("PCL")
Static lLjNfPafEcf	:= LjNfPafEcf(SM0->M0_CGC)
Static lIntDefPro	:= .F. //Processamento por EAI

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡ao    ³ Loja160  ³ Autor ³ Marcelo Kotaki        ³ Data ³ 14/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Leitura e gravacao da Reduzao Z do ECF para o SFI			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGALOJA                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ DATA     ³ BOPS ³Analista³Alteracao                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³07/03/03  ³xxxxxx³Edilson ³Acerto na solicitacao da autorizacao do     ³±±
±±³          ³      ³        ³superior na emissao da Reducao Z.           ³±±
±±³23/06/05  ³083499³Marcos  ³Incluido a funcao LJVLDSERIE para verificar ³±±
±±³          ³      ³        ³se o nro de serie do ECF conectado e o mesmo³±±
±±³          ³      ³        ³cadastrado na estacao                       ³±±
±±³26/07/05  ³084262³A.Veiga ³Acerto na gravacao do numero do cupom       ³±±
±±³          ³      ³        ³inicial. Como esta informacao nao aparece   ³±±
±±³          ³      ³        ³na reducao Z, o numero valido sera o numero ³±±
±±³          ³      ³        ³final do dia anterior + 1.                  ³±±
±±³          ³      ³        ³obs.: Se o arquivo (SFI) estiver vazio o    ³±±
±±³          ³      ³        ³numero inicial sera igual a 000001          ³±±
±±³14/02/06  ³93222 ³Marcelo ³Retirada da mensagem de confirmacao de      ³±±
±±³          ³      ³        ³operacao para garantir a integridade da     ³±±
±±³          ³      ³        ³rotina.                                     ³±±
±±³          ³      ³        ³Revisao do Fonte - PMC                      ³±±
±±³24/10/06  ³111695³Danilo C³Tratamento para a gravacao da aliquota 0,01%³±±
±±³          ³      ³        ³no SFI (Garantido Integral ECF Mato Grosso).³±±
±±³07/02/07  ³117209³Marcio L³Tratamento da reducao Z para Amazonas.      ³±±
±±³05/04/07  ³122711³Conrado ³Alterada a utilização da chamada            ³±±
±±³          ³      ³        ³SubStr(cUsuario,7,15) por cUserName         ³±±
±±³30/05/07  ³126785³Marcio L³Alterada a gravacao do campo FI_PDV, conside³±±
±±³          ³      ³        ³rando todos os bytes que retornou da impres-³±±
±±³          ³      ³        ³sora fiscal.                                ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LOJA160()
Local nOpca          := 0											// Escolha do usuario entre o OK e o CANCELA
Local cImpressora    := ""											// Impressora que sera utilizada
Local oDlg															// Tela	
Local cLock          := cUserName+cEstacao							// Flag para que a rotina nao seja executada simultaneamente em MDI 
Local lRet           := .F.											// Retorno da funcao
Local lCancOrc		 := .T.											// Define se cancela os orçamentos
Local lEfetVen		 := .F.											// Sinaliza	se rodou rotina de efetivacao dos abastecimento antes da RedZ
Local lTrcCard		 := .F.											//Sinaliza a impressão do troco em cartão - somente para SC
Local lImpDavOS      := .F.											// Sinaliza se imprimiu relatório de DAV-OS
Local nRet			 := 0  											// Retorno do ECF(IFAbrECF)
Local lEmitNfce		 := LjEmitNFCe()								// Sinaliza se utiliza NFC-e						
Local lIsMDI 		 := Iif(ExistFunc("LjIsMDI"),LjIsMDI(),SetMDIChild(0)) //Verifica se acessou via SIGAMDI

Private cCadastro    := STR0001										// "Cupom de Redução Z"

If !lEmitNfce .AND. (  ;
	nModulo == 5  .OR. ; //5 =SIGAFAT
	nModulo == 12 .OR. ; //12=SIGALOJA
	nModulo == 23 .OR. ; //23=SIGAFRT
	nModulo == 39 .OR. ; //39=SIGAOMS
	nModulo == 72)		 //72=SIGAPHOTO
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz o controle via LockByName para evitar que um usuario acesse  2 vezes uma rotina que use os perifericos de automacao ³
	//³ evitando assim a concorrencia dos mesmos                                            								    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lIsMDI .AND. !LockByName( cLock )
		Return Nil
	Endif         
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se os modulos forem diferentes de LOJA le o parametro do SX6 para identificar qual a porta de impressao , caso contrario o cadastro de estacao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (cModulo $"FAT, OMS") 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se a comunicacao com a SIGALOJA.DLL nao estiver ativa , executa a funcao de abertura³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Type("nHdlECF") == "U" .OR. nHdlEcf == -1
			Public nHdlEcf
			If( SuperGetMv("MV_FATSLG",,.F.) )
				nHdlEcf := IFAbrir(LJGetStation("IMPFISC"),LJGetStation("PORTIF"))
			Else
				nHdlEcf := IFAbrir(SuperGetMv("MV_IMPFIS"),SuperGetMv("MV_PORTFIS"))
			EndIf
			lFiscal := nHdlECF >= 0
		Endif
		cImpressora := SuperGetMv("MV_IMPFIS")
	Else
		cImpressora := LJGetStation("IMPFISC")
	EndIf
	
	If !lFiscal
		If (cModulo $"FAT, OMS") 
			//'Falha na comunicão com a impressora fiscal. Verifique os parametros MV_IMPFIS, MV_PORTFIS e a conexão física com a impressora fiscal.'
			//"Atençäo"
			MsgStop(STR0010,STR0004)
		Else
			// Para Emitir a Redu‡„o Z da Impressora fiscal, deve-se estar cadastrado como usu rio fiscal e com os parƒmetros da impressora corretos.
			MsgStop(STR0002 + STR0003,STR0004)			// Aten‡„o	
		EndIf
	Else 
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Consiste o numero de serie do equipamento conforme arq. sigaloja.bin somente se o parametro MV_LJNSECF = .T.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		LjVldSerie()
	
		If (cModulo $ "FAT,OMS") .OR. LJProFile(6)
			DEFINE MSDIALOG oDlg FROM 39,85 TO 280,600 TITLE cCadastro PIXEL OF oMainWnd
	
				// Objetivo do Programa
				@ 7,4 TO 80,250 LABEL STR0005 OF oDlg  PIXEL COLOR CLR_RED
	
				// Este programa tem como  objetivo  efetuar  a  impress„o do + cupom de Redução Z da impressora:
				@ 19, 15 SAY STR0006 SIZE 250,10 OF oDlg PIXEL COLOR CLR_RED
				@ 29, 15 SAY cImpressora  SIZE 250,10 OF oDlg PIXEL COLOR CLR_BLUE
	            
				//"Além da impressão o sistema permite a gravação automática do cadastro de redução Z. Desde que o ECF esteja homologado com essa rotina e as configurações de parâmetros estejam adequadas."
				//	@ 49, 15 SAY STR0007 SIZE 230,60 OF oDlg PIXEL COLOR CLR_BLUE
			
				//"A Impressora está ligada corretamente e as configurações de gravação do cadastro de redução Z corretos ?, Atencao"
				DEFINE SBUTTON FROM 95, 180 TYPE 1 ACTION (nOpca := 1, IIF(MsgYesNo(STR0008,STR0009),oDlg:End(),nOpca:=0) ) ENABLE OF oDlg	
	
				DEFINE SBUTTON FROM 95, 220 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
				
			ACTIVATE MSDIALOG oDlg CENTERED
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se o usuario confirrmou executa a leitura da Reducao Z e a impressao³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nOpca == 1
				If cPaisLoc == "ARG"
					Processa({|lEnd| lj160LetAR()})
				Else
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³TPL POSTO(REQUISITO XXXV):Emissao automatica, antes da reducao Z, do(s)  ³
					//³CF(s) referente a abastecimento pendente(Finalizacao da venda).          ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lTPLPCL
						DbSelectArea("SFI")
						SFI->(DbSetOrder(1))
						SFI->(DbGoBottom())
						lEfetVen := LjEfetVen(.T. , SFI->FI_DTMOVTO)	//Tenta realizar efetivacao dos abastecimentos antes da RedZ
					EndIf	

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					// Requisito XLI do Ato Cotepe 0608 para Oficina de Conserto - Emissão		
					// do Relatório Gerencial de DAV-OS Emititdos 
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					lImpDavOS := LjImpDAVOS()

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					// Requisito XIV do Ato Cotepe 01.13 - Emissão do Arquivo TXT de Troco 		
					// em Cartão para comércio varejista de mercadorias em geral
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					lTrcCard := LjImpTrcCd()
				
					If LjCancOrc()
						lCancOrc	:=	.F.						  
					Endif
				   
				   	Processa({|lEnd| lj160Leitura()})
						
					// Para impressoras Epson, e necessario a reabertura do ECF para reinicializacao das variaveis					
					If MODELIMPRES $ cImpressora .And. !lCancOrc
					   	IfAbrECF( nHdlECF )
					EndIf

					//Verifica a data do sistema pois se a data do ECF e a data do sitema
					//estiverem diferentes o cancelamento da Pre-Venda não ocorre.
					LjEcfIFData()
					
					If lCancOrc    
						nRet := IFAbrECF(nHdlECF)
						If nRet == 0
							LjCancOrc()
						Else
							MsgStop( STR0026 +Str(nRet,2,0), STR0009) // "Não foi possível realizar a Abertura do ECF. Não será possível efetuar cancelamento das Pré Vendas pendentes na Retaguarda. Erro: " ###, "Atenção"
						EndIf
					EndIf

					If lTPLPCL .AND. !lEfetVen
						DbSelectArea("SFI")
						SFI->(DbSetOrder(1))
						SFI->(DbGoBottom())
						LjEfetVen(.T. , SFI->FI_DTMOVTO)	//Quando não processada, tenta realizar efetivacao dos abastecimentos apos da RedZ
					EndIf
					
					If !lImpDavOS
						LjImpDAVOS()
					EndIf
					
					If !lTrcCard
						LjImpTrcCd()
					EndIf
				EndIf
			Endif
	
			lRet := .T.
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Executa o ponto de entrada LOJA160³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ExistBlock("LOJA160")
				ExecBlock("LOJA160",.F.,.F.)
			Endif
		Endif
	Endif
ElseIF lEmitNfce
	MsgInfo( STR0029 + Chr(10) + STR0030 ) //"A Redução Z está disponível apenas para Emissor de Cupom Fiscal (ECF) configurado."  ## //"Não há emissão em Equipamento não fiscal com NFC-e."
Else
	MsgInfo( STR0012 + Chr( 10 ) +	; 	// "A Redução Z está disponível apenas para os módulos: "
			 STR0013 + Chr( 10 ) +	;	// "SIGALOJA"  
			 STR0014 + Chr( 10 ) +	;	// "SIGAFRT"
			 STR0015 + Chr( 10 ) +	; 	// "SIGAPHOTO"
			 STR0016 + Chr( 10 ) +	;	// "SIGAFAT"
			 STR0017 )					// "SIGAOMS"
EndIf		 	 	

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡ao    ³Lj160Leitu³ Autor ³ Marcelo Kotaki        ³ Data ³ 14/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua Leitura Z                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGALOJA                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³21/11/05  ³xxxxxx³Henry   ³Ajuste do ConfirmSx8 na troca de numeracao  ³±±
±±³          ³      ³        ³so SFI                                      ³±±
±±³14/02/06  ³93222 ³Marcelo ³Revisao do fonte - PMC                      ³±±
±±³21/09/06  ³106989³Danilo C³Inclusao de Conouts na busca do SFI antes da³±±
±±³          ³      ³        ³gravacao.                                   ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Lj160Leitura()
Local aArea			 := GetArea()									// Salva a area atual
Local aReducao       := {}											// Array auxiliar para leitura dos dados da reducao e gravacao do SFI
Local cReducao       := space(5000)									// Armazena o conteudo do parametro que define se na operacao da Reducao Z, grava o Mapa Resumo.
Local cTribut        := ""											// Valor dos tributos para impressao
Local nCont															// Contador auxiliar	
Local dAuxData														// Data auxiliar para controle da Data do movimento
Local dData															// Data base
Local dDataMovto													// Data real de movimento
Local nGTIni														// Contador do Grande Total (ECF)	
Local nImpDebt       := 0											// Total de impostos (Tributo)
Local nAtAux		 := 0											// Variavel auxiliar para busca dentro de STRING.
Local nTamCOO		 := 0											// Tamanho do campo FI_COO
Local nTamFICRO		 := TamSx3("FI_CRO")[1]							// Tamanho do campo FI_CRO
Local cCOOIni        := "1"											// Numero inicial do cupom da data do movimento
Local nLenAux 		 := 0 											// Variavel auxiliar para o LEN
Local cMV_LJGRMR	 := IIF(lLjNfPafEcf, "S", SuperGetMv("MV_LJGRMR", ,"S"))  // Variavel auxiliar para nao ler diversas vezes o mesmo parametro
Local cPDV           := AllTrim(LjGetStation("PDV")) 
Local oProcessOff 	:= Nil											//Objeto do tipo LJCProcessoOffLine 
Local lAmbOffLn 	:= SuperGetMv("MV_LJOFFLN", Nil, .F.)			//Identifica se o ambiente esta operando em offline
Local cPafMd5		:= "" 											//Chave MD5
Local cLegTrib 		:= ""       									//Legenda da Aliquota
Local cCodAliq		:= ""                                           //Aliquota
Local aField		:= {}											//Array de campos e valores de ICMS e ISS
Local nValor		:= 0
Local nOutrosR		:= 0                                            //Outros Recebimentos
Local nBas001		:= 0											//Base 001
Local nPosTotAliq	:= 0											//Posicao do totalizador das aliquotas
Local nTamTribt		:= 0											//Tamanho do corte para alíquotas
Local nTamCorte		:= 0											//Tamanho do corte para alíquotas
Local nRet			:= 0
Local cChaveSFI 	:= ""
Local cHrRetEcf		:= ""
Local cHoraRedZ		:= ""
Local cNumCup		:= ""

/*
NOTA : A partir da versão 0.3.135.13 da SIGALOJA foi adicionado mais dois parâmetros em cRedução 
		( desconto e cancelamento de ISS);	Para a TOTVSAPI não foi gerada nova versão pois somente 
		foram utilizados os fontes do Protheus, portanto valida a versão da SIGALOJA.

	  ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  ³Descricao do retorno da variavel cReducao                      			³
	  ³-------------------------------------------------------------------------³
	  ³Seq- LAYOUT              - Conteudo                            			³
	  ³-------------------------------------------------------------------------³
	  ³01 - XX/XX/XX            - Data do Movimento                   			³
	  ³02 - XXXX                - Numero do ECF                       			³
	  ³03 - XXXXXXXXXXXXX       - Serie do ECF                        			³
	  ³04 - XXXX                - Numero de reducoes                  			³
	  ³05 - XXXXXXXXXXXXXXXX.XX - Grande Total Final                  			³
	  ³06 - XXXXXX              - Numero doumento Inical              			³
	  ³07 - XXXXXX              - Numero doumento Final               			³
	  ³08 - XXXXXXXXXXXX.XX     - Valor do Cancelamento               			³
	  ³09 - XXXXXXXX.XX         - Valor Contabil ( Venda Liquida )    			³
	  ³10 - XXXXXXXX.XX         - Desconto                            			³
	  ³11 - XXXXXXXX.XX         - Nao tributado SUBSTITUIcao TRIB     			³
	  ³12 - XXXXXXXX.XX         - Nao tributado ISENTO                			³
	  ³13 - XXXXXXXX.XX         - Nao tributado Nao Tributado         			³
	  ³14 - XX/XX/XX            - Data da Reducao Z                   			³
	  ³15 - XXXXXX              - Contador de Ordem de Operação       			³
	  ³16 - 0000000000000000    - Outros Recebimentos                 			³
	  ³17 - XXX                 - Contador de Ordem de Reinicio       			³
	  ³18 - XX                  - Quantidade de Aliquotas Programadas no ECF  ³	  
	  ³19 - XXXXXXXXXXXXX.XX    - valor desconto de ISS               		  	³
	  ³20 - XXXXXXXXXXXXX.XX    - valor de cancelamento de ISS        		  	³
	  ³21 - TXX,XX999999999.99  - Todas as Aliquotas e seus valores.. 		  	³
	  ³                           que estao gravados no ECF           		  	³	  
	  ³                           Ex.: T07.00 99999999999.99 99999999999.99	  	³	  	  
	  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
*/

CursorWait()
cReducao 	:= cMV_LJGRMR + cReducao		//Define se na operacao da Reducao Z grava o Mapa Resumo 
dDataRedZ	:= Date()
cHoraRedZ	:= StrTran(Time(),":")
If LjNfPafEcf(SM0->M0_CGC) //PAF-ECF deve capturar a hora do ECF
	nRet := IFStatus( nHdlECF, '1', @cHrRetEcf )
	If nRet == 0
		cHoraRedZ	:= StrTran(cHrRetEcf,":")
	EndIf
EndIf

/*  Tratar o tamanho do COO conforme o ECF,
	alguns modelos tem 6 outros 9 dígitos */
cNumCup	:= IFRetUlCup()
nRet	:= IIF(cNumCup == "ERROR",-1,0)

If nRet == 0
	nTamCOO := Len(cNumCup)
Else
	nTamCOO := TamSX3("FI_COO")[1]
EndIf

cCOOIni := StrZero(1, nTamCOO )

LjGrvLog("","EXECUTANDO A REDUCAO Z")
IfReducaoZ( nHdlECF, @cReducao )
LjGrvLog("","RETORNO ECF",cReducao)

// Verifica se o retorno da impressora termina com "|"
If !Empty(AllTrim(cReducao)) .And. !(AllTrim(cReducao) == cMV_LJGRMR) .And. Len(cReducao) > 0
	// Se o retorno da impressora na ultima posicao for diferente, incremente "|" na ultima posicao
	If Substr(cReducao, Len(cReducao), 1) <> "|"
		cReducao := cReducao + "|"
	Endif
EndIf

If lHomolPaf
	Sleep(1000)
	Conout('LOJA160 -> Conteudo de cReducao: ' + cReducao)
	LjGrvLog(Nil, "LOJA160 -> Conteudo de cReducao: " + cReducao)		
EndIf

While LEN(cReducao) > 0
	nAtAux := At("|", cReducao)
	If nAtAux > 0
		AAdd(aReducao, SUBS(cReducao,1,nAtAux-1) )
		cReducao := SUBS(cReducao, nAtAux + 1, LEN(cReducao) )
	Else
		cReducao := ""
	Endif
End

If cMV_LJGRMR == "S" .AND. LEN(aReducao) > 0 
	
	DbSelectArea("SFI")
	SFI->( DbSetOrder(1) )
	SFI->( DbSeek(xFilial("SFI")) )
	dAuxData:= SFI->FI_DTMOVTO
	dData  	:= CTOD( aReducao[1] )
	Conout("01. LOJA160 -  Data existente SFI - dAuxData: " + dToC(dAuxData) + " Data Reducao Z - dData: " + dToc(dData))
	LjGrvLog( Nil, "01. LOJA160 -  Data existente SFI - dAuxData: " + dToC(dAuxData) + " Data Reducao Z - dData: " + dToc(dData))	

	// Se retornou vazio considera a data base como data do movimento
	If Empty(dData)                               
		dData := dDataBase
	Endif

	nGTIni     := 0
	dDataMovto := dData

	Conout("02. LOJA160 -  PDV da Reducao: " + aReducao[2] + ". String inteira: " + aReducao[2])
	LjGrvLog( Nil, "02. LOJA160 -  PDV da Reducao: " + aReducao[2] + ". String inteira: " + aReducao[2])
	
	Conout("03. LOJA160 -  dAuxData <= dData .AND. !EMPTY(dData): " + IIF(dAuxData <= dData .AND. !EMPTY(dAuxData),"Sim","Nao" ) )
	LjGrvLog( Nil, "03. LOJA160 -  dAuxData <= dData .AND. !EMPTY(dData): " + IIF(dAuxData <= dData .AND. !EMPTY(dAuxData),"Sim","Nao" ) )

	Conout("04. LOJA160 -  Campo FI_PDV: " + SFI->FI_PDV)
	LjGrvLog( Nil, "04. LOJA160 -  Campo FI_PDV: " + SFI->FI_PDV)
	
	//Soma mais um dia, considerando o dia seguinte, pois quando entrar no WHILE abaixo, vai procurar Reducao Z realizada no mesmo dia,
	//onde pode aconteceer de existir mais de uma Reducao Z realizada no mesmo dia, no caso de ocorrer intervencao tecnica no ECF.
	dData := dData+1
	While dAuxData <= dData .AND. !EMPTY(dAuxData)
		dData := dData-1

		//--------------------------------------------------------------
		//|BOPS 126.785 - Como será gravado o PDV conforme o retorno   |
		//|do ECF, eh necessario realizar 2 DbSeek(), para nao perder a|
		//|gravacao do registro anterior, apos a aplicação do patch    |
		//|deste BOPS.                                                 |
		//--------------------------------------------------------------
		If SFI->( DbSeek(xFilial("SFI") + DTOS(dData) + aReducao[2]) ) .OR. ;
			SFI->( DbSeek(xFilial("SFI") + DTOS(dData) + Subs(aReducao[2], 2, 3)) )
			Conout("05. LOJA160 -  Realizou a busca no SFI.")
			LjGrvLog( Nil, "05. LOJA160 -  Realizou a busca no SFI.")
			cChaveSFI := SFI->FI_FILIAL+DTOS(SFI->FI_DTMOVTO)+SFI->FI_PDV
			//Devido a situacao onde pode ocorrer mais de uma Reducao Z no mesmo dia (no caso de ocorrer intervencao tecnica no ECF)
			//deve ser considerada a ultima Reducao Z gerado naquele dia para pegar as informacoes corretas para gravar corretamente
			//os campos FI_GTINI e o FI_NUMINI da proxima Reducao que esta sendo gerada.
			While SFI->( !EoF() ) .And. SFI->FI_FILIAL+DTOS(SFI->FI_DTMOVTO)+SFI->FI_PDV == cChaveSFI
				nGTIni 	:= SFI->FI_GTFINAL
				cCOOIni := StrZero( Val(SFI->FI_COO) + 1, nTamCOO )
				SFI->( DbSkip() )
			End
			Exit
		Endif
	End

	Conout("06. LOJA160 -  nGTIni: ",nGTIni)
	LjGrvLog( Nil, "06. LOJA160 -  nGTIni: ",nGTIni)
	
	Conout("07. LOJA160 -  cCOOIni: ",cCOOIni)
	LjGrvLog( Nil, "07. LOJA160 -  cCOOIni: ",cCOOIni)	

	nLenAux	:= Val(aReducao[21])
	nPosTotAliq:= 21
	nTamTribt := 14
	nTamCorte := 38
		
	For nCont := 1 To nLenAux
		cTribut := cTribut + aReducao[nPosTotAliq + nCont] + '|'
	Next nCont
		
	While LEN(cTribut) > 0
		/* Valida o estado e as aliquotas  para lancar separadamente */
		If ( Subs(cTribut,2,5) == "00,00" ) .AND. LjAnalisaLeg(16)[1]
			nOutrosR := Val(Subs(cTribut,8,14))		
		ElseIf ( Subs(cTribut,2,5) == "00,01" ) .AND. LjAnalisaLeg(16)[1]
			/* Grava a aliq. 0,01%(Garantido Integral ECF Mato Grosso) */
			If SFI->(ColumnPos("FI_BAS001")) > 0
				nBas001 := Val(Subs(cTribut,8,14))
			EndIf
		Else
			cCampo :="FI_BAS"
			
			If Val( Subs(cTribut,2,2) ) >= 10
				cCampo += Subs(cTribut,2,2)
			Else
				cCampo += Subs(cTribut,3,1)
			Endif         
			
			If Val( Subs(cTribut,5,2) ) > 0
				cCampo += Subs(cTribut,5,2)
			Endif
			
			If SFI->(ColumnPos(cCampo)) > 0
				nValor := Val( SubStr(cTribut,8,14) )
				//Verifico se a aliquota ja nao esta para gravar, isso pois pegamos casos 
				//em que a impressora tinha a mesma aliquota cadastrada mais de 1 vez
				If aScan(aField,{|x| Alltrim(x[1]) = Alltrim(cCampo) }) = 0 
				
					Aadd( aField, LjLdField(cCampo, nValor) )
					
					nImpDebt += Val( SubStr(cTribut,23,nTamTribt) )
					
					//PAF-ECF: Grava o código da alíquota Ex.: para FI_BAS18 grava o código
					// no campo FI_COD18 = T1800 para validacao de banco(BLOCO VII)
					If Len( AllTrim(cCampo) ) == 7 .OR. Len( AllTrim(cCampo) ) == 9
						cLegTrib	:= "T0"		// Acrescenta um zero para entrar no padrao do arquivo
					Else
						cLegTrib	:= "T"
					EndIf
	
					cCodAliq := Subs(cLegTrib + PadR(AllTrim(StrTran(Subs(cCampo,7,Len(cCampo)) , ",", ".")) , 4 ,"0" ),0,5)					
					cCampo := "FI_COD" + Substr( cCampo, 7, Len(cCampo)-6 )
					Aadd( aField, LjLdField(cCampo, cCodAliq) )
				EndIf
			EndIf
		Endif
		cTribut := Subs(cTribut,nTamCorte)
	End

	// **** Tratamento de algumas informacoes do aReducao **** 
	aReducao[4] := Lj160AjusC(aReducao[4])
	aReducao[7]	:= RemoveASC0(aReducao[7], "")	//remove caractares CHR(0) da string
	aReducao[18]:= AllTrim( SubStr(aReducao[18],;
							IIf( (Len(aReducao[18]) - nTamFICRO) < 0,	1, (Len(aReducao[18]) - nTamFICRO) + 1 ),;
							Len(aReducao[18])) )

	//*** Realiza a gravacao do SFI ***
	LjGrvLog("","DATA",dDataMovto)
	LjGrvLog("","CAMPO DE ALIQ",aField)
	
	Lj160Grv(	dDataMovto	, cCOOIni, nGTIni	, aReducao, ;
				nOutrosR	, nBas001, aField	, nImpDebt, ;
				@cPafMD5	,		 , cHoraRedZ)

	If lAmbOffLn
		//Instancia o objeto LJCProcessoOffLine se necessario
		oProcessOff := LJCProcessoOffLine():New("009")
		//Adiciona a tabela para inserir no processo off-line
		oProcessOff:Inserir("SFI", xFilial("SFI") + DTOS(dDataMovto) + aReducao[2], 1, "INSERT") //FI_DTMOVTO+FI_PDV
		//Processa os dados
		oProcessOff:Processar()
	Endif

	/*Geração dos Arquivos Obrigatorios do PAF*/ 
	If lLjNfPafEcf
 		STBProcRedZ( .F. , dDataMovto , xFilial("SFI") + DTOS(dDataMovto) + aReducao[2],cPDV)
	EndIf
	
	Conout("08. LOJA160 -  Fim de Gravação da SFI")
	LjGrvLog( Nil, "08. LOJA160 -  Fim de Gravação da SFI")	
Endif

CursorArrow()
RestArea(aArea)

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjCancOrc ºAutor  ³Marcio Lopes        º Data ³  05/02/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se imprime e cancela os orcamentos que ficaram pen-º±±
±±º          ³dentes no dia, antes de imprimir a reducao Z.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetono    ³ ExpL1 - Retono logico                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA701/SIGAFRT                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º DATA     ³ BOPS ³Analista³Alteracao                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍØÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º29/06/2007³126563³Norbert ³Criacao do parametro MV_LJPRVEN para permi- º±±
±±º          ³      ³        ³tir que estabelecimentos especificos no est-º±±
±±º          ³      ³        ³ado AM nao sejam obrigados a emitir o cance-º±±
±±º          ³      ³        ³lamento dos orcamentos nao finalizados.     º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjCancOrc() 
Local aRet		:= LjAnalisaLeg(24)					// Retorno da legislacao do estado
Local lRet 		:= .F.								// Retorno da funcao
Local lEmite	:= SuperGetMv("MV_LJPRVEN",,.T.)	// Define se o cliente trata o orcamento como pre-venda
Local nOpc	    := 1							//Cancelar Orcamentos abertos
Local lRedZPend	:= .F.							//Verifica se a redução Z está pendente no ECF
Local cRet		:= ""                           //Valor de retorno da Impressora - não utilizado somente passado como parâmetro

If cPaisLoc == "BRA"  
	If lLjNfPafEcf .OR. nModulo == 23 //23=SIGAFRT
	                          
	    //Procedimento de cancelamento utilizado pelo SIGALOJA(Offline/PAF-ECF) e FrontLoja
		If lEmite
			//Verifica se Redução Z esta pendente 
			If IFStatus(nHdlECF, "8", @cRet) == 10 
				lRedZPend	:=	.T.
				lZPend		:=	.T.  
			EndIf

			If !lRedZPend // Se lRedZPend == .T., ECF está com redução Z pendente
				LjMsgRun( STR0023,, { || LjImpOrc() } )   //"Aguarde....Cancelando Pré-Vendas"
				lRet := .T.				
			EndIf
		Else
			lRet := .T.	
		EndIf	
	
	Else
		If aRet[1] .AND. lEmite
			nOpc := Aviso( STR0018, STR0019, {STR0020, STR0021},, STR0022) // ### "Atenção" ### ""Deseja cancelar pré vendas em aberto?" ### {"&Sim","&Não"} ### "Redução Z"
		Else
			nOpc := 2
		EndIf	
	
		If nOpc == 1
			If Len(aRet) >= 1 
				If aRet[1] .AND. lEmite
					LJMsgLeg( aRet )
					LjMsgRun( STR0023,, { || LjImpOrc() } )   //"Aguarde....Cancelando Pré-Vendas"
					lRet := .T.
				Else
					lRet := .T.
				EndIf
			EndIf
		Else
			lRet := .T.	
		EndIf	
	EndIf
Else
	lRet := .T.	
EndIf 

If ValType("lPAFOrc") == "L"
	lPAFOrc := .F.
EndIF
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjImpOrc  ºAutor  ³Marcio Lopes        º Data ³  05/02/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Imprime o orcamento e depois cancela                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA701                                                    º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LjImpOrc()
Local aArea 	:= Getarea()				     	// Guarda a area corrente
Local aOrcamens := {}
Local lRet	    := .F. 
Local nCont     := 1     
Local lMvLjPdvPa:= (lLjNfPafEcf .AND. LjxBGetPaf()[2]) .OR. nModulo == 23  //23=SIGAFRT
Local cDtLimite := ""

//Busca os orcamentos da retaguarda e carrega no PDV 
If lMvLjPdvPa
	lRet := LJ7PesqOrc( Nil, @aOrcamens, Nil, Nil, "LOJA160")

	If lRet
		For nCont:=1 To Len(aOrcamens)
			LJ7VldCarrega( Nil, aOrcamens[nCont][2], aOrcamens[nCont][4], "LOJA160")
		Next nCont
	EndIf
EndIf

DbSelectArea("SL2")
SL2->(DbSetOrder(1))

DbSelectArea("SL1")
SL1->(DbSetOrder(7))

//Cancela as pre-vendas a partir de 2 dias atras
If lMvLjPdvPa  
    If lRet
 		//Se a redução Z está pendente deve cancelar as pre-vendas de a partir dois atras
 		//caso nao esteja deve cancelar as pre-vendas de a partir um dia atras   
    	If lZPend
    		cDtLimite	:= Dtos(dDataBase-2)
    		lZPend		:= .F. 
    	Else
    		cDtLimite := Dtos(dDatabase-1) 
    	EndIf	 
    	
		For nCont:=1 To Len(aOrcamens)    
			DbSelectArea("SL1")
			SL1->(DbSetOrder(13)) //L1_FILIAL+L1_TPORC+L1_NUMORC
			
			If SL1->(DbSeek(xFilial("SL1")+"P"+aOrcamens[nCont][4])) .OR. SL1->(DbSeek(xFilial("SL1")+"0"+aOrcamens[nCont][4]))
    			If DTos(SL1->L1_EMISSAO) <= cDtLimite
    				If Lj140ICOrc()
    				
    					RecLock("SL1", .F.)
						REPLACE SL1->L1_STORC WITH "C"
						SL1->(MsUnlock())   

				    	FR271CMyCall( "FR271CSTORC", { "SL1"} , aOrcamens[nCont][2])
				    EndIf	
    			EndIf
    		EndIf
    	Next nCont
    
    EndIf
Else
	DbSeek( xFilial("SL1") + DtoS(dDataBase) )
	While !Eof() .AND. (DtoS(SL1->L1_EMISSAO) >= DtoS(dDataBase) .AND. DtoS(SL1->L1_EMISSAO) <= DtoS(dDataBase))
		If Empty(SL1->L1_DOC) .AND. UPPER(SL1->L1_STORC) <> "C"
			If Lj140ICOrc()
				RecLock("SL1", .F.)
				REPLACE SL1->L1_STORC WITH "C"
				SL1->(MsUnlock())   
			EndIf	
		EndIf
		SL1->(dbSkip())
	End 
EndIf        
RestArea(aArea)
Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³Lj160AjusC  ºAutor  ³vendas crm          º Data ³  22/06/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ajusta caracteres especiais                                   º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ loja160                                                      º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Lj160AjusC(cStr)

Local cRet := ''			// Retorno
Local nVal := 0   			// Amazena valor para Bk

Default cStr := '0' 		// Inicializa com zero, mas usar funcao val
	
nVal := Val(cStr)
cRet := cValtoChar(nVal)

Return cRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡ao    ³Lj160LetAR³ Autor ³ Vendasc / CRM         ³ Data ³ 06/07/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Efetua Leitura Z (Argentina)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGALOJA                                                    ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Lj160LetAR()
Local aArea			:= GetArea()														// Salva a area atual
Local aReducao		:= {}																// Array auxiliar para leitura dos dados da reducao e gravacao do SFI
Local cReducao		:= Space(5000)														// Armazena o conteudo do parametro que define se na operacao da Reducao Z, grava o Mapa Resumo.
Local cHoraRedZ		:= ""																// Hora da reducao Z
Local dDataRedZ																			// Data do momento da reducao Z
Local dDataMovto																		// Data real de movimento
Local nAtAux		:= 0																// Variavel auxiliar para busca dentro de STRING.
Local nSaveSX8		:= GetSX8Len()														// Ultimo numero do SX8
Local cMV_LJGRMR	:= SuperGetMv("MV_LJGRMR")											// Variavel auxiliar para nao ler diversas vezes o mesmo parametro
Local lGerInte		:= SuperGetMV("MV_LJGRINT",.F. ,.F.)								//Verifica se a integracao esta habilitada
Local oProcessOff	:= Nil																//Objeto do tipo LJCProcessoOffLine
Local lAmbOffLn		:= SuperGetMv("MV_LJOFFLN", Nil, .F.)								//Identifica se o ambiente esta operando em offline
Local cNumero		:= "" 

/* 
	  ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  ³Descricao do retorno da variavel cReducao                      			³
	  ³-------------------------------------------------------------------------³
	  ³Seq- LAYOUT              - Conteudo                            			³
	  ³-------------------------------------------------------------------------³
	  ³01 - XXXX				- Status da impressora                 			³
	  ³02 - XXXX				- Status fiscal                      			³
	  ³03 - XXXX				- Numero da reducao Z                 			³
	  ³04 - XXXXX				- Quantidade de documentos fiscais cancelados	³
	  ³05 - XXXXX				- Quantidade de documentos nao fiscal homologado³
	  ³06 - XXXXX				- Quantidade de documentos nao fiscal			³
	  ³07 - XXXXXX				- Quantidade de documentos fiscais emitidos		³
	  ³08 - X					- Reservado (sempre 0)							³
	  ³09 - XXXXXXXX			- Numero do ultimo documento B/C emitido		³
	  ³10 - XXXXXXXX			- Numero do ultimo documento A emitido			³
	  ³11 - XXXXXXXXXXXX		- Valor vendido em documentos fiscais			³
	  ³12 - XXXXXXXXXXXX		- Valor IVA em documentos fiscais				³
	  ³13 - XXXXXXXXXXXX		- Valor impostos internos em documentos fiscais	³
	  ³14 - XXXXXXXXXXXX		- Valor percepcao em documentos fiscais			³
	  ³15 - XXXXXXXXXXXX		- Valor IVA nao inscrito em documentos fiscais	³
	  ³16 - XXXXXXXX			- Numero ultima Nota de credito B/C emitida		³
	  ³17 - XXXXXXXX			- Numero ultima Nota de credito A emitida		³
	  ³18 - XXXXXXXXXXXX		- Credito em notas de credito					³
	  ³19 - XXXXXXXXXXXX		- Valor IVA em notas de credito					³
	  ³20 - XXXXXXXXXXXX		- Valor impostos internos em notas de credito	³
	  ³21 - XXXXXXXXXXXX		- Valor percepcao em notas de credito			³
	  ³22 - XXXXXXXXXXXX		- Valor IVA nao inscrito em notas de credito	³
	  ³23 - XXXXXXXX			- Numero ultimo remito							³
	  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

CursorWait()

cReducao	:= cMV_LJGRMR + cReducao		//Define se na operacao da Reducao Z grava o Mapa Resumo 
dDataRedZ	:= Date()
cHoraRedZ	:= StrTran(Time(),":")
LjGrvLog("LOJA160","Executando a Redução Z no Equipamento Fiscal")
IfReducaoZ( nHdlECF, @cReducao )
LjGrvLog("LOJA160","Retorno da Redução Z ",cReducao)

// Verifica se o retorno da impressora termina com CHR(28)
If !Empty(AllTrim(cReducao)) .And. !(AllTrim(cReducao) == cMV_LJGRMR) .And. Len(cReducao) > 0
	// Se o retorno da impressora na ultima posicao for diferente, incremente CHR(28) na ultima posicao
	If Substr(cReducao, Len(cReducao), 1) <> CHR(28)
		cReducao := cReducao + CHR(28)
	Endif
EndIf

While LEN(cReducao) > 0
	nAtAux := At(CHR(28), cReducao)
	If nAtAux > 0
		AAdd(aReducao, SUBS(cReducao,1,nAtAux-1) )
		cReducao := SUBS(cReducao, nAtAux + 1, LEN(cReducao) )
	Else
		AAdd(aReducao, SUBS(cReducao,1,LEN(cReducao)) )
		cReducao := ""
	Endif
End

If 	cMV_LJGRMR == "S" .AND. LEN(aReducao) > 0 

	dDataMovto := dDataBase

	DbSelectArea("SFI")
	SFI->(DbSetOrder(1)) //FI_FILIAL + FI_DTMOVTO + FI_PDV + FI_NUMREDZ
	If !SFI->(DbSeek( xFilial("SFI") + DTOS( dDataMovto ) + LjGetStation("LG_PDV") + PadL(aReducao[3], TamSX3("FI_NUMREDZ")[1]) ))
		
		cNumero := LJ200Num( dDataMovto )	// Data do Movimento
		
		RecLock( "SFI", .T. )
		Replace FI_FILIAL   WITH  xFilial("SFI")		
		Replace FI_DTMOVTO  WITH  dDataMovto
		Replace FI_PDV		WITH  LjGetStation("LG_PDV")
		Replace FI_NUMREDZ 	WITH  aReducao[3]
		Replace FI_NUMERO	WITH  cNumero
		Replace FI_SERPDV	WITH  LjGetStation("SERPDV")

		If SFI->(ColumnPos("FI_DOCBC")) > 0
			Replace FI_DOCBC 	WITH  aReducao[9]
		Endif

		If SFI->(ColumnPos("FI_DOCA")) > 0
			Replace FI_DOCA 	WITH  aReducao[10]
		Endif

		If SFI->(ColumnPos("FI_DOCFIS")) > 0
			Replace FI_DOCFIS 	WITH  Val(aReducao[11])
		Endif

		If SFI->(ColumnPos("FI_IVAFIS")) > 0
			Replace FI_IVAFIS 	WITH  Val(aReducao[12])
		Endif

		If SFI->(ColumnPos("FI_IINTFIS")) > 0
			Replace FI_IINTFIS	WITH  Val(aReducao[13])
		Endif

		If SFI->(ColumnPos("FI_PERCFIS")) > 0
			Replace FI_PERCFIS	WITH  Val(aReducao[14])
		Endif

		If SFI->(ColumnPos("FI_NCREDBC")) > 0
			Replace FI_NCREDBC 	WITH  aReducao[16]
		Endif

		If SFI->(ColumnPos("FI_NCREDA")) > 0
			Replace FI_NCREDA	WITH  aReducao[17]
		Endif

		If SFI->(ColumnPos("FI_NCRED")) > 0
			Replace FI_NCRED	WITH  Val(aReducao[18])
		Endif

		If SFI->(ColumnPos("FI_IVANCC")) > 0
			Replace FI_IVANCC	WITH  Val(aReducao[19])
		Endif

		If SFI->(ColumnPos("FI_IINTNCC")) > 0
			Replace FI_IINTNCC	WITH  Val(aReducao[20])
		Endif

		If SFI->(ColumnPos("FI_PERCNCC")) > 0
			Replace FI_PERCNCC	WITH  Val(aReducao[21])
		Endif

		If SFI->(ColumnPos("FI_ULTREMI")) > 0
			Replace FI_ULTREMI	WITH  aReducao[23]
		Endif
			
		If SFI->(ColumnPos("FI_DTREDZ")) > 0
			Replace FI_DTREDZ WITH dDataRedZ
		EndIf    
		
		If SFI->(ColumnPos("FI_HRREDZ")) > 0
			Replace FI_HRREDZ WITH cHoraRedZ
		EndIf

		SFI->(MsUnlock())
		
		If nModulo == 12 .AND. lGerInte //12=SIGALOJA
		    FRT20InSFI("SFI", xFilial( "SFI" ) + DTOS(dDataMovto) + aReducao[2])
		EndIf		
		
		While GetSx8Len() > nSaveSX8
			ConfirmSX8()
		End
		
		If lAmbOffLn
			//Instancia o objeto LJCProcessoOffLine se necessario
			oProcessOff := LJCProcessoOffLine():New("009")
			//Adiciona a tabela para inserir no processo off-line
			oProcessOff:Inserir("SFI", xFilial("SFI") + DTOS(SFI->FI_DTMOVTO) + SFI->FI_PDV, 1, "INSERT")
			//Processa os dados 
			oProcessOff:Processar()
		EndIf
		
	Endif

Endif

CursorArrow()
RestArea(aArea)

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjEfetVen ºAutor  ³Vendas Clientes     º Data ³  01/06/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Imprime os orcamentos referentes a abastecimentos que fica- º±±
±±º          ³ram pendentes no dia, antes de imprimir a reducao Z.        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetono    ³ ExpL1 - Nil			                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA701,TPLPCL10                                           º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjEfetVen( lImpEnc , dDtRedZ )
Local lRet			:= .F.
Local nRetEcf		:= 0                       
Local cRetEcf		:= "" //Retorna data do ECF

DEFAULT lImpEnc := .T. //Define se havera impressao de encerrante pois na rotina TPLPCL10 nao deve imprimir
DEFAULT dDtRedZ := dDataBase

If lLjNfPafEcf .AND. lTPLPCL .AND. ExistFunc("T_TpPclVenda")	
	//Verifica se RedZ esta pendente
	nRetEcf := IFStatus( nHdlECF, '19', @cRetEcf )

	//Retorna nRetEcf == 0 quando Reducao Z Pendente, cRetEcf contem data do ECF
	If !(nRetEcf == 0)
		LjMsgRun( STR0024,, { || T_TpPclVenda() } )   //"Aguarde....Emitindo Abastecimentos Pendentes"
	     
		//Requisito XXXIII - Controle de Encerrantes apos ou antes emissao da RedZ
		If lImpEnc
			LjTotalPCL(dDtRedZ)
		EndIf			
		lRet	:= .T.          
	EndIf

EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjTotalPCLºAutor  ³Vendas Clientes     º Data ³  01/06/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Imprime abastecimentos totalizando por bico                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetono    ³ ExpL1 - Nil			                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA701                                                    º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjTotalPCL(dData)

Local dDataAbast := dData

If lLjNfPafEcf .AND. lTPLPCL .AND. ExistTemplate("TpPclEcfTo")
	LjMsgRun( STR0025,, { || T_TpPclEcfTo(dDataAbast) } )  //"Aguarde....Emitindo Relatorio Gerencial de Abastecimentos"
EndIf

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³Lj160Grv	ºAutor  ³Vendas Clientes     º Data ³  15/03/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Realiza a gravacao da reducao Z na tabela SFI				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetono    ³ ExpL1 - Nil			                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Lj160Leitura                                               º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Lj160Grv(dDataMovto, cCOOIni	, nGTIni, aReducao,;
				 	nOutrosR, nBas001	, aField, nImpDebt,;
					cPafMD5, cLoja 		, cHoraRedZ)

Local dDataRedZ	:= Date()								// Data da Reducao Z
Local nSaveSX8		:= GetSX8Len()						// Ultimo numero do SX8
Local cNumero		:= LJ200Num( dDataMovto )			// Data do Movimento 
Local nI			:= 1					   			// Contador do For
Local lGerInte		:= SuperGetMV("MV_LJGRINT",.F.,.F.)	// Verifica se a integracao esta habilitada
Local lIntSIAC		:= SuperGetMV("MV_SCINTEG",NiL,.F.)	// Verifica se a integracao SIAC esta ativa
//variaveis para separacao das aliquotas de ISS
Local nCountPos	:= 0
Local cLinhaISS	:= ""
Local cTribISS	:= ""
Local cCampo	:= ""
Local cBaseISS	:= ""
Local cVlrBISS	:= ""
Local cTotIss	:= ""
Local cCodIss	:= ""
Local lRet		:= .F.
Local lIntegDef	:= FWHasEAI("LOJA160",, .T., .T.) .AND. lIntDefPro //Integracao via Mensagem Unica
Local cPafTrbMD5:= ""
Local lTribEspISS:= .F. //Valida tributação especifica para alíquotas de ISS - IS1 / NS1 / FS1

Default	nOutrosR	:= 0
Default	nBas001		:= 0
Default	aField		:= {}
Default	cPafMD5		:= ""
Default	nImpDebt	:= 0
Default cLoja	 	:= xFilial("SFI")
Default cHoraRedZ	:= StrTran(Time(),":") 				

LjGrvLog("","VERIFICA SE JA EXISTE  A REDUCAO",DTOS(dDataMovto) + aReducao[2])
DbSelectArea("SFI")
SFI->( DbSetOrder(1) )    
//Tratamento para validar se existe o movimento do dia, indice antigo nao era no campo FI_DTMOVTO,
//validava FI_DTREDZ, quando duas reducoes no mesmo dia, ocorria erro. (RedZ pendente movimento dia anterior e redZ do dia)
If !SFI->( DbSeek(xFilial("SFI") + DTOS(dDataMovto) + aReducao[2] +  aReducao[4] ) )
	Conout("08. LOJA160 - Inicia gravacao no SFI")

	RecLock("SFI",.T.)
	Replace FI_FILIAL   WITH  cLoja
	Replace FI_DTMOVTO  WITH  dDataMovto
	Replace FI_PDV		WITH  aReducao[2]
	Replace FI_SERPDV 	WITH  aReducao[3]
	Replace FI_NUMREDZ 	WITH  aReducao[4]
	Replace FI_GTFINAL 	WITH  Val(aReducao[5])
	Replace FI_NUMINI 	WITH  cCOOIni
	Replace FI_NUMFIM 	WITH  aReducao[7]
	Replace FI_CANCEL	WITH  Val(aReducao[8])
	Replace FI_VALCON 	WITH  Val(aReducao[9])
	Replace FI_DESC		WITH  Val(aReducao[10])
	Replace FI_SUBTRIB	WITH  Val(aReducao[11])
	Replace FI_ISENTO	WITH  Val(aReducao[12])
	Replace FI_NTRIB	WITH  Val(aReducao[13])
	Replace FI_ISS		WITH  Val( SubStr(aReducao[17],1,14) )
	Replace FI_CRO		WITH  aReducao[18]
	Replace FI_COO		WITH  aReducao[15]
	Replace FI_OUTROSR	WITH  Val(aReducao[16])
	Replace FI_NUMERO	WITH  cNumero
	Replace FI_GTINI	WITH  nGTIni
	
	//Integracao Mensagem Unica nao grava
	If !lIntegDef 
		Replace FI_DESISS WITH Val(aReducao[19])		
		Replace FI_CANISS WITH Val(aReducao[20])
	EndIf
	
	//Integracao Mensagem Unica mantem a data informada
	If lIntegDef
		If Len(aReducao) >= 21
			Replace FI_DTREDZ WITH aReducao[21]
		EndIf
		
		If Len(aReducao) >= 22
			Replace FI_HRREDZ WITH aReducao[22]
		EndIf
	Else
		Replace FI_DTREDZ WITH dDataRedZ
		Replace FI_HRREDZ WITH cHoraRedZ
	EndIf		
					
	Replace FI_OUTROSR WITH nOutrosR		
	Replace FI_BAS001 WITH nBas001
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gravacao dos campos extras ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(aField)
		For nI := 1 To Len(aField)
			If SFI->( ColumnPos(aField[nI][1]) ) > 0
				Replace &(aField[nI][1]) With aField[nI][2]
			Else
				Conout("O campo '" + aField[nI][1] + "' não existe na base. Dados da Alíquota não serão gravados")
			EndIf
		End
	EndIf
	
	//Tratamento Aliquotas ICMS para integracao Mensagem Unica
	If lIntegDef .And. Len(aReducao) >= 23
		For nI := 1 To Len(aReducao[23])
			cCampo	:= "FI_COD" + aReducao[23][nI]
			cTribICM := "T"
			
			//Se tributo menor que 9, adiciona 0
			If Val(aReducao[23][nI]) <= 9
				cTribICM += "0"					
			EndIf
			
			cTribICM += aReducao[23][nI]		
			cTribICM += "00"
			
			If ColumnPos(cCampo) > 0        
				REPLACE &(cCampo)	WITH cTribICM				    		
			EndIf
		Next nI
	EndIf

	//-----------------------------------
	//|Tratamento para Aliquotas de ISS | 
	//-----------------------------------	
	If !lIntSIAC
		//Pega as aliquotas e os valores de ISS para que sejam gravados separadamente  
		nAtAux 		:= At(";",aReducao[17])+1
		aReducao[17]:= Subs(aReducao[17], nAtAux , Len(aReducao[17]) ) // Pega a partir da "2" posição de aReducao[17] pois a primeira traz o valor total de ISS		
		
		While Len(aReducao[17]) > 0 .AND. nAtAux > 0
			nAtAux := At(";", aReducao[17])
			If nAtAux > 0
				lTribEspISS := .F.
				
				cLinhaISS	:= SUBS(aReducao[17],1,nAtAux-1)
				If SubStr(cLinhaISS,1,2) $ "IS|NS|FS" //IS1 - NS1 - FS1
					cTribISS := Substr(cLinhaISS,1,3)
					nCountPos:= -3
					lTribEspISS := .T.
				ElseIf SubStr(cLinhaISS,1,1) == "S" // Caso venha com o indice da aliquota de ISS deve tratar 
					cTribISS	:= Substr(cLinhaISS,2,5)
					nCountPos	:= 0
				Else
					cTribISS	:= Substr(cLinhaISS,4,5)
					nCountPos	:= 2
				EndIf
				
				If lTribEspISS
					If cTribISS == "IS1"
						cCampo := "FI_ISSISEN"
						cCodIss:= "IS"
						
					ElseIf cTribISS == "NS1"
						cCampo := "FI_ISSNTRI"
						cCodIss:= "NS"
						
					ElseIf cTribISS == "FS1"
						cCampo := "FI_ISSFTRI"
						cCodIss:= "FS"
					EndIf
				Else
					cCodIss		:= AllTrim(Str(Val(cTribISS)))
					cTribISS	:= StrTran(cTribISS,'.','')
					cTribISS	:= StrTran(cTribISS,',','')
					
					If !(Len(cTribISS) == 4)
						cTribISS	:= StrZero( Val(cTribISS) , 5 , 2 )
						cTribISS	:= StrTran(cTribISS,'.','')
						cTribISS	:= StrTran(cTribISS,',','')
						cTribISS	:= "0" + cTribISS
					EndIf
					
					cCampo := "FI_BIS" + cTribISS
				EndIf
				
				cBaseISS	:= Subs(cLinhaISS,nCountPos+8,14) 			// Pega o valor de base
				cVlrBISS	:= Subs(cLinhaISS,nCountPos+23,Len(cLinhaISS))	// Pega o valor deduzido
				
				If ColumnPos(cCampo) > 0
				    REPLACE &(cCampo)	WITH Val(cBaseISS)
				Else				
					Conout("O campo '" + cCampo + "' não existe na base. Dados da Alíquota não serão gravados")
				EndIf
				
				If !lTribEspISS
					cCampo 		:= "FI_ISS" + cTribISS
					If ColumnPos(cCampo) > 0
					    REPLACE &(cCampo) 	WITH Val(cVlrBISS)
					Else				
						Conout("O campo '" + cCampo + "' não existe na base. Dados da Alíquota não serão gravados")				    
					EndIf
				EndIf
				
				cCampo 		:= "FI_ICOD" + cCodIss
				If ColumnPos(cCampo) > 0
					If lTribEspISS
						cTotIss := cCodIss
					Else
						cTotIss	:= StrZero( Val(cCodIss) , 5 , 2)
						cTotIss	:= StrTran( cTotIss , "." , "" )
						cTotIss	:= "S" + StrTran( cTotIss , "," ,"")
					EndIf
					REPLACE &(cCampo) 	WITH cTotIss 
				Else				
					Conout("O campo '" + cCampo + "' não existe na base. Dados da Alíquota não serão gravados")				    
				EndIf
				
				aReducao[17]:= SUBS(aReducao[17], nAtAux + 1, LEN(aReducao[17]) )
			Else       
			    If ColumnPos("FI_BIS0500") > 0
					REPLACE FI_BIS0500 WITH 0
				EndIf
				If ColumnPos("FI_ISS0500") > 0
					REPLACE FI_ISS0500 WITH 0
				EndIf
			Endif
		End
	EndIf
	
	Replace FI_IMPDEBT With nImpDebt
	
	Replace SFI->FI_XMLENV With "N" //Campo Usado no PAF mas sempre será gravado
	Replace SFI->FI_XMLEPAF WITH " "
	Replace SFI->FI_XMLRPAF WITH " "
	
	SFI->( MsUnlock() )
	
	//Gravação dos campos de validação do MD5 da SFI
	If lLjNfPafEcf
		cPafMD5		:= STxPafMd5("SFI")
		cPafTrbMD5	:= STxPafMd5("SFI",,"2")
		
		RecLock("SFI",.F.)
		Replace SFI->FI_PAFMD5 With	cPafMd5
		Replace SFI->FI_MD5TRIB With cPafTrbMD5
		SFI->(MsUnlock())
	EndIf
	
	RecLock("SFI",.F.)
	Replace FI_SITUA   With "00"
	SFI->( MsUnlock() )
	
	If nModulo == 12 .AND. lGerInte //12=SIGALOJA
		FRT20InSFI( "SFI", xFilial("SFI") + DTOS(dDataMovto) + aReducao[2] )
	EndIf

	While GetSx8Len() > nSaveSX8
		ConfirmSX8()
	End
	lRet := .T.
	LjGrvLog("LOJA160","Finaliza gravacao no SFI")
	Conout("09. LOJA160 - Finaliza gravacao no SFI")
Else
	lRet := .F.
	LjGrvLog("LOJA160","Nao foi possivel gravar a Reducao Z, pois a mesma ja existe")
	Conout("08. LOJA160 - Nao foi possivel gravar a Reducao Z, pois a mesma ja existe")
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjLdField ºAutor  ³Vendas Clientes     º Data ³  15/03/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Para cada aliquota de ICMS ou ISS da reducao Z, carregamos  º±±
±±º			 | um array com a informacao de campo e valor 				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetono    ³ ExpL1 -Array			                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Lj160Leitura                                               º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LjLdField(cCampo, xValor)

Local aArray := Array(2)

Default cCampo := ""
Default xValor := 0

aArray[1] := cCampo
aArray[2] := xValor

Return aArray


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjImpDAVOSºAutor  ³Vendas Clientes     º Data ³  27/09/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Imprime os orcamentos referentes a abastecimentos que fica- º±±
±±º          ³ram pendentes no dia, antes de imprimir a reducao Z.        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetono    ³ ExpL1 - Nil			                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA701                                                    º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjImpDAVOS()

Local lRet			:= .F.
Local nRetEcf		:= 0                       
Local cRetEcf		:= "" //Retorna data do ECF
Local dData		:= dDataBase

If lLjNfPafEcf .AND. SuperGetMV("MV_LJDAVOS",,.F.)
	//Verifica se RedZ esta pendente
	nRetEcf := IFStatus( nHdlECF, '19', @cRetEcf )

	//Retorna nRetEcf == 0 quando Reducao Z Pendente, cRetEcf contem data do ECF		
	If !(nRetEcf == 0)
		dData	:= CtoD(cRetEcf)-1 //Dia anterior ao movimento atual
		LjMsgRun( STR0027,, { || lRet := LjxDavEmt(dData,dData,.F.,"") } )   //"Aguarde....Pesquisando Ordens de Serviço"
	EndIf

EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjImpTrcCdºAutor  ³Vendas Clientes     º Data ³  21/03/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Imprime as vendas que possuem troco em cartão				  º±±
±±º          ³no arquivo TXT											  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetono    ³ ExpL1 - Nil			                                	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Loja160                                                    º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjImpTrcCd()
Local lRet			:= .F.
Local nRetEcf		:= 0                       
Local cRetEcf		:= "" //Retorna data do ECF
Local dData		:= dDataBase

//Troco em cartão somente para o Estado de Santa Catarina
If lLjNfPafEcf .AND. SM0->M0_ESTCOB == "SC" .AND. SuperGetMV("MV_LJCOMVA",,.F.)
	//Verifica se RedZ esta pendente
	nRetEcf := IFStatus( nHdlECF, '19', @cRetEcf )

	//Retorna nRetEcf == 0 quando Reducao Z Pendente, cRetEcf contem data do ECF		
	If !(nRetEcf == 0)
       dData	:= CtoD(cRetEcf)-1 //Dia anterior ao movimento atual
		LjMsgRun( "Aguarde....Verificando Vendas com Troco em Cartão",, { || lRet := LjxTrcCard(dData,dData) } )   //"Aguarde....Verificando Vendas com Troco em Cartão"
	EndIf
EndIf

Return lRet

//--------------------------------------------------------
/*/{Protheus.doc} IntegDef()
Rotina para Definicao de Integracao via Mensagem Unica                
@param cXml		Conteudo da mensagem (XML)
@param cTypeTran	Tipo da transacao 
@param cTypeMsg	Tipo da mensagem

@author  alessandrosantos
@version P12.17
@since   14/09/2016
@return  aRet  Aray com resultado da execucao e a mensagem Xml de retorno
				aRet[1]-(boolean) Indica o resultado da execução da função
				aRet[2]-(caracter) Mensagem Xml para envio                                                                    
/*/
//--------------------------------------------------------
Static Function IntegDef(cXml, nType, cTypeMsg) 
Local aRet := {}

lIntDefPro := .T.
aRet := LOJI160(cXml, nType, cTypeMsg)
lIntDefPro := .F.

Return aRet
