#Include "PROTHEUS.CH"
#Include "FILEIO.CH"
#Include "LOJXLOG.CH"

Static __lFirst := .T.
Static cGetCliDir      // Guarda o caminho do rootPath
Static cProfStr1       // Guarda o Retorno da Funcao GetPvProfString

#DEFINE  LOG_DIR	"\AUTOCOM\LOG"+cEmpAnt+StrTran(Alltrim(cFilAnt)," ","")+"\"
#DEFINE REG_DELETED	"DELETED" //Sinaliza registro SL2 deletado
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Este Log eh um recurso a ser habilitado pelo departamento de desenvolvimento para averigua-³
//³cao de possiveis problemas de transacoes TEF.                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#DEFINE LOG_TEF			LjxLog_Tef()
#DEFINE CRLF			CHR(13) + CHR(10)	//Pula linha
#DEFINE TEF_CLISITEF	"6"					//Utiliza a DLL CLISITEF

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    ³LjLogOrc  ³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 11/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se existe e trata Log de Orcamento.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGALOJA                                                   ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjLogOrc()

Local nArquivo		:= 0										// Contador auxliar dos arquivos nos diretorios
Local cLjArq		:= SPACE(8)									// Variavel com o nome do LOG principal utilizado LJ+NumOrc.Caixa
Local nHandle		:= 0										// Utilizada para gravar o Handle do arquivo que está sendo utilizado
Local nSize			:= 0										// Variavel para armazenar o tamanho do arquivo
Local nTamDoc       := TamSx3("L1_DOC")[1]                     // Tamanho do campo L1_DOC
Local cRBuffer		:= SPACE(42)								// Utilizada para armazenar o conteudo do TXT descriptografado
Local cNumOrc		:= SPACE(6)									// Grava o numero do Orcamento do TXT
Local cNumNota		:= SPACE(nTamDoc)							// Grava o numero da NF, de acordo com o posicionamento no SL1
Local cSerie		:= SPACE(3)									// Grava a seria da NF, de acordo com o posicionamento no SL1
Local cCupom		:= SPACE(nTamDoc)							// Grava o numero do cupom fiscal, de acordo com o TXT
Local cCupImp		:= SPACE(nTamDoc)							// Variavel com o ultimo numero do Cupom Fiscal impresso
Local cImpressora 	:= SPACE(30)								// Variavel com o modelo da impressora que foi gravada no TXT
Local cPorta		:= LJGetStation("PORTIF")					// Porta configurada no cadastro de estacoes
Local cCaixa		:=	xNumCaixa()								// Codigo do caixa que esta utilizando o sistema
Local aDirect		:= {}										// Array com as informacoes do diretorio e arquivo de log
Local aAuxArea		:= {}										// Variavel auxiliar para guardar as areas de cada Tabela
Local lLogAtivo		:= .F.										// Verifica se o caixa ativou o log.
Local lLogEtapas	:= .F.										// Verifica se o caixa ativou a gravacao de todas as etapas 
Local lLogRecupera	:= .F.										// Verifica se o caixa ativou a Recuperacao da venda e transacao tef
Local cPrefixo      := ""										// Prefixo configurado de acordo com o cadastro de estacao x impressora fiscal
Local cLjArqEr		:= ""										// Arquivo de ERRO, caso nao consiga abrir o arquivo de log
Local lTef			:= .F. 										// Verifica se a venda é referente a TEF
Local lTefOK		:= .F. 										// Verifica se a venda é referente - Significa que a transação foi efetuada com sucesso
Local lRecup		:= .F. 										// Verifica se a recuperação dos dados foi concluida com sucesso
Local cLjArqSL		:= SPACE(8)									// Arquivo de Log com os dados das vendas TEF
Local lCancCup		:= .F.										// Variavel que retorna se o cupom foi cancelado
Local cLjArqAx		:= ""										// Arquivo auxiliar de LOG
Local nAuxFor		:= 0 										// Campo auxiliar para o FOR
Local nRet			:= 0										// Retorno da funcao IFPegCupom
Local nErase		:= 0										// Variavel para validar se o arquivo foi apagado
Local lTudoOk		:= .F.										// Verifica se no log estah gravado o status de TudoOk
Local lOrcamOK      := .F.										// Verifica se o orcamento esta ok.
Local lTransTef		:= .F.										// Verifica se houve transacao TEF
Local lDadosOK		:= .F.										// Verifica se no log foi gravado os status de dadosok
Local aFilhos		:= {}										// Grava todos os filhos do orcamento, caso exista reserva
Local cAuxNumOrc	:= ""										// Grava o orcamento original
Local lSL1Pai		:= .F.										// Flag para verificar se o orcamento eh pai
Local lRetTef		:= .F.										// Verifica o retorno do TEF
Local lFound		:= .T.										// Verifica se encontrou o orcamento que estah no log
Local lSL1Deletado	:= .F.										// Verifica se registros do orcamento foram deletados para melhorar mensagem ao usuario informando que orcamento foi excluido
Local aAliasDel		:= {}										// Matriz utilizada para a exclusao de registros.
Local cAliasDel		:= ""										// Alias que tera registros excluido.
Local nIndexDel		:= 0										// Indice do alias que tera registros excluido.
Local cSeekDel		:= ""										// Seek do alias que tera registros excluido.
Local bWhileDel		:= {|| }									// While do alias que tera registros excluido.
Local lExcluido		:= .F.										// Indica se os registros foram excluidos com sucesso.
Local lFilho		:= .F.										// Indica se os registros representam um orcamento filho.
Local aTextLog		:= {}										// Matriz de textos que serao gravados no arquivo de log.
Local cCliente 		:= ""
Local cLoja	 		:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada para caso exista a necessidade de fazer backup dos arquivos de log³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "LJLOG_04" )
	ExecBlock( "LJLOG_04", .F., .F. )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica qual a configuracao do CAIXA ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SubStr( LJGetProfile( "LOGERRO" ), 1, 1 ) == "S"  // Verifica se o caixa ativou o log.
	lLogAtivo	:= .T.
EndIf	

If SubStr( LJGetProfile( "LOGERRO" ), 3, 1 ) == "S"  // Verifica se o caixa ativou a gravacao de todas as etapas 
	lLogEtapas	:=  .T.
EndIf

If SubStr( LJGetProfile( "LOGERRO" ), 4, 1 ) == "S"  // Verifica se o caixa ativou a Recuperacao da venda e transacao tef
	lLogRecupera:= .T.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica a existencia do diretorio de Log³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ChkLogDir()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Faz a validacao do arquivo ER????? - ERRO - para ver se nao tem erro na criacao ou delecao do mesmo  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aDirect := Directory( LOG_DIR + "ER??????." + cCaixa)
nAuxFor := Len( aDirect )

For nArquivo := 1 to nAuxFor
	cLjArqEr := aDirect[nArquivo][1]
	cLjArq	 := StrTran( cLjArqEr, "ER", "LJ" )
	If File( LOG_DIR + cLjArq )
		nHandle := FErase( LOG_DIR + cLjArq )
		If nHandle < 0
			For nAuxFor := 1 TO 3
				If FErase( LOG_DIR + cLjArq ) >= 0
					Exit
				EndIf	
			Next nAuxFor
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³So apago o arquivo de ERRO caso o arquivo principal tenha sido excluido.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ! File( LOG_DIR + cLjArq )
		nHandle := FErase( LOG_DIR + cLjArqEr )
		If nHandle < 0
			For nAuxFor := 1 TO 3
				If FErase( LOG_DIR + cLjArqEr ) >= 0
					Exit
				EndIf	
			Next nAuxFor
		EndIf
	EndIf
Next nArquivo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Faz a validacao dos arquivos de LOG                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aDirect := Directory( LOG_DIR + "LJ??????." + cCaixa )
nAuxFor := Len( aDirect )

If nAuxFor > 0
	For nArquivo := 1 TO nAuxFor
		cLjArq	:= aDirect[nArquivo][1]
		cLjArqAx:= StrTran( cLjArq, "LJ", "AX" )
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Abre arquivo de Log Exclusivo. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nHandle := Fopen( LOG_DIR + cLjArq, 16)
	
		If nHandle < 0
			Msgalert(STR0001, cLjarq) // "Nao foi possivel abrir arquivo de Log. Por favor, contacte o administrador do sistema.
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³So efetuo as verificacoes se os logs estiverem habilitados³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lLogAtivo .AND. lLogRecupera
				
				nSize    := FSeek(nHandle, 0, 2)
				cRBuffer := Space( nSize )
				FSeek( nHandle, 0, 0 )
				FRead( nHandle, @cRBuffer, nSize )
				FClose( nHandle )
				cRBuffer	:= Encript( cRBuffer, 1 )
				cNumOrc 	:= SubStr( cRBuffer, 1, 6 )
				If GetNewPar("MV_LJVACC",.F.,Nil) 	// Alterado pois com Concomitancia ativado
					IFPegCupom( nHdlECF, @cCupom ) // o ultimo cupom retornado era incorreto. 
				Else
					cCupom		:= SubStr( cRBuffer, 7, nTamDoc )
				EndIf
				
				cImpressora := SubStr( cRBuffer, 7 + nTamDoc, 30 )
                
				lDadosOK	:= .F.
				If "#TEFS#" $ cRBuffer
					lTransTef := .T.
					lTef      := .T.
				ElseIf "#TEFN#" $ cRBuffer
					lTransTef := .F.
				EndIf
				If "#DADOSOK#" $ cRBuffer
					lDadosOK := .T.
					lTef 	 := .F.
					lTefOk 	 := .F.
				EndIf
				If "#TEF#" $ cRBuffer
					lTef 	:= .T.
					lTefOk 	:= .F.
				EndIf
				If "#TEFOK#" $ cRBuffer
					lTef 	:= .T.
					lTefOk 	:= .T.
				EndIf
				If "#TUDOOK#" $ cRBuffer
					lTudoOK := .T.
				EndIf
				If "#ORCMOK#" $ cRBuffer
					lOrcamOK := .T.
				EndIf
			EndIf
			
			If !lDadosOK .AND. lLogRecupera
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³So continua se existir o arquivo de monitoramento e nao existir o arquivo de erro.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If 	File( LOG_DIR + cLjArq )							.AND.;
					!File( LOG_DIR + StrTran( cLjArq, "LJ", "ER" ) )	.AND.;
					!( File( LOG_DIR + cLjArqAx ) )
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Se o log foi ativado³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lLogAtivo
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Compara se o nome do Arq. corresponde ao conteudo do Log.³
						//³Garante que o valor encriptado e' o mesmo que o nome do  ³
						//³arquivo por questao de seguranca.						³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If cNumOrc == SubStr( cLjArq, 3, 6 )   
							If !Empty( LOG_TEF )
								LjWriteLog( LOG_TEF + cNumOrc + ".TXT", "LOJXLOG" + Replicate( "-", 40 ) )
							EndIf
																					
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Inicializa para o proximo FOR³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							cNumNota	:= Space( nTamDoc )
							cSerie		:= Space( 3 )
							cPrefixo	:= Space( 3 )
							
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Verifica Arquivo SL1³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							DbSelectArea( "SL1" )
							DbSetOrder( 1 )
							If DbSeek( xFilial( "SL1" ) + cNumOrc )
								cNumNota	:= SL1->L1_DOC
								cSerie		:= SL1->L1_SERIE
								cCliente 	:= SL1->L1_CLIENTE
								cLoja	 	:= SL1->L1_LOJA
								cPrefixo	:= LjPrefixo()
								lFound		:= .T.
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Verifica se houve reserva e o orcamento eh pai³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If SL1->L1_TIPO == "P"
									aFilhos	:= LjGrvPai( cNumOrc )
									lSL1Pai	:= .T.
									If lTefOK
										While !lRetTef
											MsgInfo( STR0033) //"Efetuando o cancelamento do TEF "
											If !Empty( SL1->L1_SERIE ) .AND. !Empty( SL1->L1_DOC )
												lRetTef := LOJA011T()
											Else
												lRetTef := LOJA010T("E")
											EndIf
										End
                                    EndIf
								Else
									lSL1Pai	:= .F.
								EndIf
							Else
								LjWriteLog( LOG_TEF + cNumOrc + ".TXT", "Nao foi encontrado o orcamento " + cNumOrc )
								lFound := .F.
							EndIf
						EndIf
						
						If !Empty( LOG_TEF )
							LjWriteLog( LOG_TEF + cNumOrc + ".TXT", "SL1->L1_OPERADO =" + SL1->L1_OPERADO )
							LjWriteLog( LOG_TEF + cNumOrc + ".TXT", "cCaixa =" + cCaixa )
						EndIf

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Se encontrou orcamento no SL1, continua a operacao normalmente³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If lFound
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³So ira fazer o cancelamento se for o mesmo caixa que finalizou a venda ou se o L1_OPERADO for igual a branco³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If SL1->L1_OPERADO == cCaixa .OR. Empty( SL1->L1_OPERADO )
								If ExistBlock( "LJLOG_02" )
									ExecBlock( "LJLOG_02", .F., .F., { cNumOrc } )
								EndIf
								
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Inicio de Transacao para manter a base de dados integra  ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								DbSelectArea("SFT")
								SFT->( DbSetOrder(1) ) //FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO
								If !lOrcamOK .OR. ( !Empty(cNumNota) .And. !SFT->( DbSeek(xFilial("SFT")+"S"+cSerie+cNumNota+cCliente+cLoja) ) )
									aAuxArea := GetArea()
									BEGIN TRANSACTION
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³ Configura na matriz aAliasDel os registros que serao excluidos. ³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										aTextLog := {}
										If !Empty( LOG_TEF )
											aAdd( aTextLog, "Begin Transaction" )
										EndIf
										
										aAliasDel := {}
										If !lOrcamOK
											cAliasDel := "SL1"
											nIndexDel := 1
											cSeekDel  := xFilial( "SL1" ) + cNumOrc
											bWhileDel := {|| SL1->L1_FILIAL + SL1->L1_NUM }
											aAdd(aAliasDel, {cAliasDel, nIndexDel, cSeekDel, bWhileDel, .F.})
											
											cAliasDel := "SL2"
											nIndexDel := 1
											cSeekDel  := xFilial( "SL2" ) + cNumOrc
											bWhileDel := {|| SL2->L2_FILIAL + SL2->L2_NUM }
											aAdd(aAliasDel, {cAliasDel, nIndexDel, cSeekDel, bWhileDel, .F.})
											
											cAliasDel := "SL4"
											nIndexDel := 1
											cSeekDel  := xFilial( "SL4" ) + cNumOrc
											bWhileDel := {|| SL4->L4_FILIAL + SL4->L4_NUM }
											aAdd(aAliasDel, {cAliasDel, nIndexDel, cSeekDel, bWhileDel, .F.})
										EndIf
										
										If !Empty(cNumNota)
											cAliasDel := "SD2"
											nIndexDel := 3
											cSeekDel  := xFilial( "SD2" ) + cNumNota + cSerie
											bWhileDel := {|| SD2->D2_FILIAL + SD2->D2_DOC + SD2->D2_SERIE}
											aAdd(aAliasDel, {cAliasDel, nIndexDel, cSeekDel, bWhileDel, .F.})
											
											cAliasDel := "SE1"
											nIndexDel := 1
											cSeekDel  := xFilial( "SE1" ) + cSerie + cNumNota
											bWhileDel := {|| SE1->E1_FILIAL + SE1->E1_PREFIXO  + SE1->E1_NUM }
											aAdd(aAliasDel, {cAliasDel, nIndexDel, cSeekDel, bWhileDel, .F.})
											
											cAliasDel := "SE5"
											nIndexDel := 7
											cSeekDel  := xFilial( "SE5" ) + cSerie + cNumNota
											bWhileDel := {|| SE5->E5_FILIAL + SE5->E5_PREFIXO + SE5->E5_NUMERO }
											aAdd(aAliasDel, {cAliasDel, nIndexDel, cSeekDel, bWhileDel, .F.})
											
											cAliasDel := "SEF"
											nIndexDel := 3
											cSeekDel  := xFilial( "SEF" ) + cSerie + cNumNota
											bWhileDel := {|| SEF->EF_FILIAL + SEF->EF_PREFIXO + SEF->EF_NUM }
											aAdd(aAliasDel, {cAliasDel, nIndexDel, cSeekDel, bWhileDel, .F.})
											
											cAliasDel := "SF2"
											nIndexDel := 1
											cSeekDel  := xFilial( "SF2" ) + cNumNota + cSerie
											bWhileDel := {|| SF2->F2_FILIAL + SF2->F2_DOC + SF2->F2_SERIE }
											aAdd(aAliasDel, {cAliasDel, nIndexDel, cSeekDel, bWhileDel, .F.})
										EndIf
										
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³Se houver orcamentos filho, deve deletar todos. ³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										If Len( aFilhos ) > 0
											aAliasDel  := {}
											cAuxNumOrc := cNumOrc
											
											For nAuxFor := 1 to Len( aFilhos )
												DbSelectArea("SL1")
												SL1->( DbSetOrder(1) )
												
												If DbSeek( aFilhos[nAuxFor][2] + aFilhos[nAuxFor][1] )
													cNumOrc   := aFilhos[nAuxFor][1]
													cFilFilho := aFilhos[nAuxFor][2]
													cNumNota  := SL1->L1_DOC
													cSerie    := SL1->L1_SERIE
													
													If !lOrcamOK
														cAliasDel := "SL1"
														nIndexDel := 1
														cSeekDel  := cFilFilho + cNumOrc
														bWhileDel := {|| SL1->L1_FILIAL + SL1->L1_NUM }
														aAdd(aAliasDel, {cAliasDel, nIndexDel, cSeekDel, bWhileDel, .T.})
														
														cAliasDel := "SL2"
														nIndexDel := 1
														cSeekDel  := cFilFilho + cNumOrc
														bWhileDel := {|| SL2->L2_FILIAL + SL2->L2_NUM }
														aAdd(aAliasDel, {cAliasDel, nIndexDel, cSeekDel, bWhileDel, .T.})
														
														cAliasDel := "SL4"
														nIndexDel := 1
														cSeekDel  := cFilFilho + cNumOrc
														bWhileDel := {|| SL4->L4_FILIAL + SL4->L4_NUM }
														aAdd(aAliasDel, {cAliasDel, nIndexDel, cSeekDel, bWhileDel, .T.})
													EndIf
													
													If !Empty(cNumNota)
														
														cAliasDel := "SD2"
														nIndexDel := 3
														cSeekDel  := cFilFilho + cNumNota + cSerie
														bWhileDel := {|| SD2->D2_FILIAL + SD2->D2_DOC + SD2->D2_SERIE }
														aAdd(aAliasDel, {cAliasDel, nIndexDel, cSeekDel, bWhileDel, .T.})
														
														cAliasDel := "SE1"
														nIndexDel := 1
														cSeekDel  := cFilFilho + cSerie + cNumNota
														bWhileDel := {|| SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM }
														aAdd(aAliasDel, {cAliasDel, nIndexDel, cSeekDel, bWhileDel, .T.})
														
														cAliasDel := "SE5"
														nIndexDel := 7
														cSeekDel  := cFilFilho + cSerie + cNumNota
														bWhileDel := {|| SE5->E5_FILIAL + SE5->E5_PREFIXO + SE5->E5_NUMERO }
														aAdd(aAliasDel, {cAliasDel, nIndexDel, cSeekDel, bWhileDel, .T.})
														
														cAliasDel := "SEF"
														nIndexDel := 3
														cSeekDel  := cFilFilho + cSerie + cNumNota
														bWhileDel := {|| SEF->EF_FILIAL + SEF->EF_PREFIXO + SEF->EF_NUM }
														aAdd(aAliasDel, {cAliasDel, nIndexDel, cSeekDel, bWhileDel, .T.})
														
														cAliasDel := "SF2"
														nIndexDel := 1
														cSeekDel  := cFilFilho + cNumNota + cSerie
														bWhileDel := {|| SF2->F2_FILIAL + SF2->F2_DOC + SF2->F2_SERIE }
														aAdd(aAliasDel, {cAliasDel, nIndexDel, cSeekDel, bWhileDel, .T.})
													EndIf
												EndIf
											Next nAuxFor
										EndIf
										
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³ Exclui os registros configurados acima.                         ³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										For nAuxFor := 1 to len(aAliasDel)
											cAliasDel := aAliasDel[nAuxFor, 1]
											nIndexDel := aAliasDel[nAuxFor, 2]
											cSeekDel  := aAliasDel[nAuxFor, 3]
											bWhileDel := aAliasDel[nAuxFor, 4]
											lFilho    := aAliasDel[nAuxFor, 5]
											
											//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
											//³ Funcao para apagar os registros referentes ao orcamento. ³
											//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
											lExcluido := LjDelArq(cAliasDel, nIndexDel, cSeekDel, bWhileDel)
											If !Empty(LOG_TEF)
												If cAliasDel == "SL1"
													lSL1Deletado := lExcluido
													//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
													//³ "Registro(s) do alias " ## " (filho)" // " excluído(s)"  ## "não excluído(s)"³
													//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
													aAdd(aTextLog, STR0039 + cAliasDel + IIf(lFilho, STR0042, "") + IIf(lExcluido, STR0040, STR0041) + " - " + dtoc(dDataBase) + " " + Time() + " - " + GetComputerName())
												ElseIf lExcluido
													//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
													//³ "Registro(s) do alias " ## " (filho)" ## " excluído(s)"³
													//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ								
													aAdd(aTextLog, STR0039 + cAliasDel + IIf(lFilho, STR0042, "") + STR0040 + " - " + dtoc(dDataBase) + " " + Time() + " - " + GetComputerName())
												EndIf
											EndIf
										Next nAuxFor
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Fim de Transacao³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									END TRANSACTION
									
									RestArea(aAuxArea)
									
									If !Empty( LOG_TEF )
										aAdd( aTextLog, "lFiscal = " + IIf( lFiscal, "S", "N" ) )
										aAdd( aTextLog, "cCupom  = " + cCupom )
										aAdd( aTextLog, "cCupImp = " + cCupImp )
										aAdd( aTextLog, "lVdaTef  = " + IIF( lTef, "S", "N" ) )
										aAdd( aTextLog, "End Transaction" )
									EndIf
								EndIf
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Grava tudo no arquivo de log.³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If !Empty(LOG_TEF) .AND. !Empty(aTextLog)
									LjWriteLog(LOG_TEF + cNumOrc + ".TXT", aTextLog)
								EndIf
	
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Se os numeros de cupons forem diferentes a impressora nao    ³
								//³ conseguira cancelar, desta forma vou recuperar a venda, pois ³
								//³ possivelmente a venda foi TEF.                               ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If !lSL1Pai
									LjMsgRun( STR0025,, { || lRecup := LjReLogT( cNumOrc ) } ) //"Cancelando Cupom Fiscal..."
								EndIf
	
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Se a venda foi TEF e não foi finalizado o processo da impres-³
								//³ sao do cupom, significa que a confirmação nao foi envida, vou³
								//³ confirmar a transacao apos ter recuperado a venda...         ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If !Empty( LOG_TEF )
									LjWriteLog( LOG_TEF + cNumOrc + ".TXT", "lRetLogT  = " + IIF( lRecup, "S", "N" ) )
									LjWriteLog( LOG_TEF + cNumOrc + ".TXT", "lVdaTefok  = " + IIF( lTefOK, "S", "N" ) )
								EndIf
	
								If lFiscal
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Obtem o Numero do Cupom Fiscal ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									cCupImp := Space( 10 )
									nRet := IFPegCupom( nHdlECF, @cCupImp )
									
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Cancela o Cupom Fiscal ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									If Val(cCupom) == Val(cCupImp) .AND. !lTefOk  
										If !Empty( LOG_TEF )
											LjWriteLog( LOG_TEF + cNumOrc + ".TXT", "cCupom  = " + cCupom )
											LjWriteLog( LOG_TEF + cNumOrc + ".TXT", "cCupImp = " + cCupImp )
										EndIf
	
										If ( lTransTef .AND. !lTudoOK ) .OR. ( !lTransTef .AND. !lDadosOK )
											LjMsgRun( STR0025,, { || lCancCup := LjCanCup( cImpressora, cPorta ) } ) //"Cancelando Cupom Fiscal..."
										EndIf
	
										If !Empty( LOG_TEF )
											LjWriteLog( LOG_TEF + cNumOrc + ".TXT", "lTEF      = " + IIF( lTef, "S", "N" ) )
											LjWriteLog( LOG_TEF + cNumOrc + ".TXT", "lCancCup  = " + IIF( lCancCup, "S", "N" ) )
										EndIf
	
										If ExistBlock( "LJLOG_01" )
											ExecBlock( "LJLOG_01", .F., .F., { lCancCup, cNumOrc } )
										EndIf
	
									Else    
									
										If !Empty( LOG_TEF )                                               
											LjWriteLog( LOG_TEF + cNumOrc + ".TXT", "Cupons diferentes " )
											LjWriteLog( LOG_TEF + cNumOrc + ".TXT", "cCupom  = " + cCupom )
											LjWriteLog( LOG_TEF + cNumOrc + ".TXT", "cCupImp = " + cCupImp )
										EndIf
										
										If lTef
											//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
											//³Verifica se houve recuperacao do log e o TEF esteja sido efetuado com sucesso³
											//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
											If lRecup .AND. !lTefOK
												MsgInfo( STR0034) //"Transação não efetuada, favor reter o cupom" 
												If ExistBlock( "LJLOG_03" )
													ExecBlock( "LJLOG_03", .F., .F., { cCupom, cNumOrc } )
												EndIf
								    		EndIf
										Else
	
											If Len( aFilhos ) > 0
												MsgInfo( "Transação não efetuada, favor reter o cupom " )
											Else
												If lSL1Deletado
													LjWriteLog( LOG_TEF + cNumOrc + ".TXT", "Orcamento excluido. O cupom fiscal nao foi cancelado, pois nao foi o ultimo a ser impresso" )
													Msgalert( STR0029 + " " + STR0002, cCupom )	// "Orcamento excluido." + " " + "O cupom fiscal nao foi cancelado, pois nao foi o ultimo a ser impresso"
												ElseIf !lOrcamOK
													LjWriteLog( LOG_TEF + cNumOrc + ".TXT", "Não foi possivel excluir este orcamento. O cupom fiscal nao foi cancelado, pois nao foi o ultimo a ser impresso" )
													Msgalert( STR0030 + " " + STR0002, cCupom )	// "Não foi possivel excluir este orcamento." + " " + "O cupom fiscal nao foi cancelado, pois nao foi o ultimo a ser impresso"
												EndIf
											EndIf
										EndIf
									EndIf
								EndIf
							Else
								If !Empty( LOG_TEF )
									LjWriteLog( LOG_TEF + cNumOrc + ".TXT", "Cancelamento não efetuado, pois o caixa é diferente do Operador." )
									Msgalert( STR0031, cNumOrc )	// "Cancelamento não efetuado, pois o caixa é diferente do Operador."
								EndIf
	 						EndIf
						EndIf
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Fechando o Log referente ao problema da venda³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						Fclose( nHandle )
						
						If !Empty( LOG_TEF )
							LjWriteLog( LOG_TEF + cNumOrc + ".TXT", "Fechando o arquivo: " + LOG_DIR + cLjArq + " - " + AllTrim( Str( Ferror() ) ) )
						EndIf
					EndIf
				EndIf
			Else
				If !lTudoOK
					If lTransTef
						//"Transação TEF não efetuada, favor reter o cupom."
						MsgAlert(STR0037)
					EndIf
				EndIf			
			EndIf

			If lCancCup
				SL1->( DbSetOrder( 1 ) )
					
				If SL1->( DbSeek( xFilial( "SL1" ) + cNumOrc ) )
					If RecLock( "SL1", .F. )
						Replace SL1->L1_DOC 	With ""
						Replace SL1->L1_SERIE 	With ""
						Replace SL1->L1_PDV 	With ""
						Replace SL1->L1_EMISNF 	With CTOD("  /  /  ")
						Replace SL1->L1_TIPO	With ""
						Replace SL1->L1_OPERADO	With ""
						Replace SL1->L1_NUMCFIS	With ""
						Replace SL1->L1_VENDTEF	With ""
						Replace SL1->L1_DATATEF	With ""
						Replace SL1->L1_HORATEF	With ""
						Replace SL1->L1_DOCTEF	With ""
						Replace SL1->L1_AUTORIZ	With ""
						Replace SL1->L1_DOCCANC	With ""
						Replace SL1->L1_DATCANC	With ""
						Replace SL1->L1_HORCANC	With ""
						Replace SL1->L1_INSTITU	With ""
						Replace SL1->L1_NSUTEF	With ""
						Replace SL1->L1_TIPCART	With ""
						Replace SL1->L1_SITUA	With ""
						
						SL1->( MsUnlock() )
					EndIf
				EndIf

				SL2->( DbSetOrder( 1 ) )
				If SL2->( DbSeek( xFilial( "SL2" ) + cNumOrc ) )
					If RecLock( "SL2", .F. )
						Replace SL2->L2_VENDIDO	With ""
						Replace SL2->L2_DOC 	With ""
						Replace SL2->L2_SERIE 	With ""
						Replace SL2->L2_PDV 	With ""
						SL2->( MsUnlock() )
					EndIf
				EndIf
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Exclui os arquivos de LOG³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If File( LOG_DIR + cLjArq )
				FClose( nHandle )
				If !Empty( LOG_TEF )
					LjWriteLog( LOG_TEF + cNumOrc + '.TXT', 'Exclusão do arquivo: ' + LOG_DIR+cLjArq + ' - Excluiu ? - ' )
				EndIf
				nErase := FErase( LOG_DIR + cLjArq )
				If !Empty( LOG_TEF )			// Se o LOG esta habilitado
					If nErase == 0				// Foi apagado com sucesso
						LjWriteLog( LOG_TEF + cNumOrc + '.TXT', " SIM ")
					Else
						LjWriteLog( LOG_TEF + cNumOrc + '.TXT', " NAO ")
					EndIf
				EndIf
			EndIf
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Apagando o Log com os dados das vendas TEF³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !File( LOG_DIR + cLjArq )
				cLjArqSL := StrTran( cLjArq, "LJ", "SL" )

				If File( LOG_DIR + cLjArqSL )
					nHandle := Fopen( LOG_DIR + cLjArqSL, 16)
					FClose( nHandle )
					If !Empty( LOG_TEF )
						LjWriteLog( LOG_TEF + cNumOrc + '.TXT', 'Exclusão do arquivo: ' + LOG_DIR + cLjArqSL + ' - Excluiu ? - ' )
					EndIf
		
					nErase := FErase( LOG_DIR + cLjArqSL )

					If !Empty( LOG_TEF )		// Se o LOG esta habilitado
						If nErase == 0			// Foi apagado com sucesso
							LjWriteLog( LOG_TEF + cNumOrc + '.TXT', " SIM ")
						Else
							LjWriteLog( LOG_TEF + cNumOrc + '.TXT', " NAO ")
						EndIf
					EndIf
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Apagar arquivo auxiliar³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If File( LOG_DIR + cLjArqAx )
					nHandle := Fopen( LOG_DIR + cLjArqAx, 16)
					FClose( nHandle )
					If !Empty( LOG_TEF )
						LjWriteLog( LOG_TEF + cNumOrc + '.TXT', 'Exclusão do arquivo: ' + LOG_DIR+cLjArqAx + ' - Excluiu ? - ' )
					EndIf
	
					nErase := FErase( LOG_DIR + cLjArqAx )
					If !Empty( LOG_TEF )		// Se o LOG esta habilitado
						If nErase == 0			// Foi apagado com sucesso
							LjWriteLog( LOG_TEF + cNumOrc + '.TXT', " SIM ")
						Else
							LjWriteLog( LOG_TEF + cNumOrc + '.TXT', " NAO ")
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf   
		
	Next nArquivo
	Return .T.	
EndIf
Return .F.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ LjGrLog  ³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 12/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava Arquivo de Log de Orcamento.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ LOJA010C / LOJA220C                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LjGrLog(	nHandle,	cOrc,	cLjArq,	cImpressora,;
					cPorta )

Local nTamCup    := TamSx3("L1_DOC")[1]
Local cCup 		 := Space(nTamCup)
Local cCaixa	 :=	xNumCaixa()
Local nRet
Local nLen       := 0
Local lVendaAss  := IsInCallStack("LOJA701")
Local lEmitNfce	 := LjEmitNFCe() // Sinaliza se utiliza NFC-e

//Caso a consulta padrao F3 estiver aberta nao deixara executar 
If Type("InConPad") <> "U" .AND. InConPad
	Return .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ESTA FUNCAO PODE CONTER MAIS 5 CARACTERES AO FINAL DA STRING SE FOR VENDA  ³
//³TEF = (#TEF#) CONSIDERAR CASO SEJA NECESSÁRIA A CRIACAO DE NOVOS PARAMETROS³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Obter Numero do Cupom Fiscal ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lFiscal .AND. !lEmitNfce
	cCup := Space(10)
	nRet := IFPegCupom( nHdlECF, @cCup )
	If ! Empty( cCup ) .AND. ( Funname() == "LOJA010" .OR. lVendaAss .OR. Funname() == "LOJA020" )
		cCup := Strzero( (Val( cCup ) + 1), nTamCup )
	EndIf
ElseIf lEmitNfce	//tratamento NFC-e
	cCup := "NFCE"
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica a existencia do diretorio de Log³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ChkLogDir()

cLjArq	:= 'LJ' + cOrc + '.' + cCaixa

If File( LOG_DIR + cLjArq )
	Ferase( LOG_DIR + cLjArq )
EndIf

nHandle := Fcreate( LOG_DIR + cLjArq,0 )
If Ferror() <> 0
	MsgAlert(STR0024, cLjarq) // "Nao foi possivel criar arquivo de Log."
	Return (.F.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Manter a string cImpressora sempre com 30 posicoes para não pergar informacoes a mais do TEF³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nLen = Len( cImpressora )
cImpressora = Iif(nLen>=30,substr(cImpressora,1,30), substr(cImpressora,1,nLen)+space(30-nLen))
cImpressora = Iif(nLen==0,space(30), cImpressora )
Fwrite(nHandle, Encript( cOrc + cCup + cImpressora, 0))
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ LjDelLog ³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 18/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Deleta Arquivo de Log de Orcamento.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ LOJA010C / LOJA220C                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LjDelLog(	nHandle,	aCloACols,	aColsAux,	cLjArq,;
					cOrc,		nDescAux,	cCliente,	cLoja )

Local lLog2		:= SubStr(LJGetProfile("LOGERRO"),2,1) == "S" // Log de Monitoramento
Local lLog4		:= SubStr(LJGetProfile("LOGERRO"),4,1) == "S" // Log de Recuperacao
Local nHnd		:= 0
Local lRet		:= .T.
Local nRet		:= 0
Local nHndAux	:= 0
Local cLjArqAx	:= StrTran( cLjArq, "LJ", "AX" )

//Caso a consulta padrao F3 estiver aberta nao deixara executar 
If Type("InConPad") <> "U" .AND. InConPad
	Return .F.
EndIf

nHndAux := FCreate( LOG_DIR + cLjArqAx )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica a existencia do diretorio de Log³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ChkLogDir()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica a existencia do arquivo LJ???????? pois essa funcao estah³
//³sendo chamada duas vezes no processo da finalização da venda      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If File( LOG_DIR + cLjArq )

	If lLog4

		lRet := LjDeLogR( cOrc )

		If !Empty( LOG_TEF )
			LjWriteLog( LOG_TEF + cOrc + '.TXT', AllTrim(ProcName(0)) + " => lRet = " + iIf( lRet, "S", "N" ))
		EndIf
		
	EndIf
	
	If nHandle <= 0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Deu problema no fechamento do arquivo, portanto cria uma "flag" para ao entrar nao³
		//³cancelar o cupom nem excluir os registros da base.                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nHnd := FCreate( LOG_DIR + StrTran( cLjArq, "LJ", "ER") )
		FClose( nHnd )

		MsgAlert( STR0001 ) // "Nao foi possivel abrir arquivo de Log."

		If !Empty( LOG_TEF )
			LjWriteLog( LOG_TEF + cOrc + '.TXT', AllTrim(ProcName(0)) + " => Erro na abertura do arquivo " + LOG_DIR+cLjArq + ;
			            Chr(13) + " Criado o arquivo " + LOG_DIR+StrTran(cLjArq, "LJ", "ER") + " = " + ;
			            iIf( File(LOG_DIR+StrTran(cLjArq, "LJ", "ER")), "S", "N" ))
		EndIf

		Return (.F.)

	EndIf
	
	If lLog2
		LjAdiLog( nHandle, aCloAcols, aColsAux, nDescAux, cCliente, cLoja)
	EndIf
	
	Fseek( nHandle, 0, 0 )
	Fwrite( nHandle, space( TamSx3( "L1_DOC" )[1] ) )
	Fclose( nHandle )

	nRet := Ferase( LOG_DIR + cLjArq )
	
	If !Empty( LOG_TEF )
		LjWriteLog( LOG_TEF + cOrc + '.TXT', AllTrim(ProcName(0)) + " => nRet = " + AllTrim(Str(nRet)))
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Deu problema no fechamento do arquivo, portanto cria uma "flag" para ao entrar nao³
	//³cancelar o cupom nem excluir os registros da base.                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If File( LOG_DIR + cLjArq )

		nHnd := FCreate( LOG_DIR + StrTran( cLjArq, "LJ", "ER" ) )
		FClose( nHnd )
		
		If !Empty( LOG_TEF )
			LjWriteLog( LOG_TEF + cOrc + '.TXT', AllTrim(ProcName(0)) + " => Erro na exclusão do arquivo " + LOG_DIR+cLjArq + ;
			            Chr(13) + " Criado o arquivo " + LOG_DIR+StrTran(cLjArq, "LJ", "ER") + " = " + ;
			            iIf( File(LOG_DIR+StrTran(cLjArq, "LJ", "ER")), "S", "N" ))
		EndIf
	Else
		Fclose( nHndAux )
		Ferase( LOG_DIR + cLjArqAx )
	EndIf

EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ LjAdiLog ³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 19/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Adiciona informacoes no Arquivo Log de Ocorrencias.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGALOJA                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LjAdiLog(	nHandle,	aCloAcols,	aColsAux,	nDescAux,;
					cCliente,	cLoja )

Local cHora 	:= Time()
Local cCaixa	:= xNumCaixa()
Local cSerie	:= Space(3)
Local cMensag
Local cCupom
Local cNumOrc
Local cImp
Local cRBuffer
Local cValor
Local i				:= 0
Local z				:= 0
Local nValor		:= 0
Local nValTemp		:= 0
Local nDifer		:= 0
Local nCont			:= 0
Local nCntSL2		:= 0
Local nCntSD2		:= 0
Local nHandle2		:= 0
Local nTam			:= TamSx3("L1_DOC")[1]
Local cNumNota		:= Space(nTam)
Local lError		:= .F.
Local nPosVlItem	:= 0
Local nPosVlIpi		:= 0
Local nPosVrUnit	:= 0
Local nPosValDesc	:= 0
Local cFunName		:= FunName()  // Nome da funcao chamada no menu.
Local lVendaAss 	:= IsInCallStack("LOJA701") .OR. IsInCallStack("LJ7Venda")  .OR. IsInCallStack("FTVDVenda")    //No caso do Restaurante tambem deve ser .T.

If lVendaAss .OR. cFunName == "LOJA720"
	nPosVlItem 	:= GdFieldPos("LR_VLRITEM")
	nPosVlIpi 	:= GdFieldPos("LR_VALIPI")
	nPosVrUnit 	:= GdFieldPos("LR_VRUNIT")
	nPosValDesc	:= GdFieldPos("LR_VALDESC")
Else
	nPosVlItem 	:= GdFieldPos("L2_VLRITEM")
	nPosVlIpi 	:= GdFieldPos("L2_VALIPI")
	nPosVrUnit 	:= GdFieldPos("L2_VRUNIT")
	nPosValDesc	:= GdFieldPos("L2_VALDESC")
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Le arquivo de Log do Orcamento.             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nSize	:= Fseek( nHandle,0,2 )
cRBuffer:= Space( nSize )
Fseek( nHandle,0,0 )
Fread( nHandle,@cRBuffer,nSize )
cRBuffer:= Encript( cRBuffer,1 )

cNumOrc := SubStr( cRBuffer,  1,  6)
cCupom	:= SubStr( cRBuffer,  7, nTam)
cImp	:= SubStr( cRBuffer, 7 + nTam, 30)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abre Arquivo de Log Ocorrencias³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! File( LOG_DIR + "LOJALOG." + cCaixa )
	nHandle2 := Fcreate( LOG_DIR + "LOJALOG." + cCaixa, 0)
	If Ferror() <> 0
		MsgAlert( STR0024, "LOJALOG." + cCaixa )		// "Nao foi possivel criar arquivo de Log."
		Return (.F.)
	EndIf
	Fwrite( nHandle2, "Microsiga Software S/A - " + STR0003 + cCaixa + chr(13) + chr(10) ) // "Caixa: "
	Fwrite( nHandle2, STR0004 + chr(13) + chr(10))			// "SigaLoja - Arquivo de Log"
	Fwrite( nHandle2, " " + chr(13) + chr(10))
Else
	nHandle2 	:=	Fopen( LOG_DIR + "LOJALOG." + cCaixa, 17)
	If Ferror() <> 0
		Msgalert( STR0001, "LOJALOG." + cCaixa )				// "Nao foi possivel abrir arquivo de Log."
		Return .F.
	EndIf
	Fseek( nHandle2,0,2 )
EndIf

If lVendaAss .OR. cFunName == "LOJA720"
	Fwrite( nHandle2, STR0028 + Chr(13) + Chr(10) )	// "Venda Assistida"
ElseIf cFunName == "LOJA010" .OR. cFunName == "LOJA020"
	Fwrite( nHandle2, STR0005 + chr(13) + chr(10) )	// "Venda Balcao"
Else
	Fwrite( nHandle2, STR0006 + chr(13) + chr(10) )	// "Venda Rapida"
EndIf
Fwrite( nHandle2, STR0007 + Dtoc( dDataBase ) + chr(13) + chr(10) )		// "Data		: "
Fwrite( nHandle2, STR0008 + cHora + chr(13) +  chr(10) )				// "Hora		: "
Fwrite( nHandle2, STR0009 + cImp + chr(13) + chr(10) )					// "Impress.	: "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Numero da N.F.		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea( "SL1" )
DbSetOrder( 1 )
If DbSeek( xFilial( "SL1" ) + cNumOrc )
	cNumNota	:= SL1->L1_DOC
	If Empty( cCupom )
		cCupom	:= cNumNota
	EndIf
EndIf

If ! Empty( cCupom )
	Fwrite( nHandle2, STR0010 + cCupom + chr(13) + chr(10) )			// "Cupom/NF.: "
Else
	Fwrite( nHandle2, STR0010 + STR0011 + chr(13) + chr(10) )			// "Cupom/NF.: ** Orcamento ** "
EndIf
Fwrite( nHandle2, STR0012 + cNumOrc + chr(13) + chr(10) )				// "Orcamento: "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³   Comparacao de aColsAux.  	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len( aColsAux ) <> Len( aCloaCols )							// Verifica No. de Itens (Linhas).
	lError := .T.
Else
	For i := 1 To Len( aColsAux )
		If Len( aColsAux[i] ) <> Len( aCloaCols[i] )			// Ver. No. de Col. p/cada linha.
			lError := .T.
			Exit
		Else
			For z := 1 To Len( aColsAux[i] )  // Ver. Conteudo de cada elemento.
				If aColsAux[i][z] <> aCloaCols[i][z]
					lError := .T.
					Exit
				EndIf
			Next z
		EndIf
	Next i
EndIf
If lError
	cMensage := STR0013 // "Mensagem : Teve alteracao no Acols! "
	Fwrite( nHandle2,cMensage + chr(13) + chr(10) )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Comparacao de valores e No.itens (nao deletados)  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For i := 1 to Len( aCloaCols )
	If lVendaAss .OR. cFunName == "LOJA720"
		If !aCloaCols[i][Len(aCloaCols[i])]			//  Considera apenas itens nao deletados.
			nValor += Round( aCloaCols[i][nPosVlItem] ,2 )
			nCont ++
		EndIf
	ElseIf cFunName == "LOJA010" .OR. cFunName == "LOJA020"
		If !aCloaCols[i][Len(aCloaCols[i])]			//  Considera apenas itens nao deletados.
			nValor += Round( aCloaCols[i][nPosVlItem] ,2 ) + Round( aCloaCols[i][nPosVlIpi] ,2 )
			nCont ++
		EndIf
	Else
		nValor += Round( aCloaCols[i][nPosVrUnit] ,2 )
		nCont ++
	EndIf
Next i

nValor := nValor - nDescAux
If lVendaAss .OR. cFunName == "LOJA720"
	cValor := Str( nValor, 13, 2 ) + STR0023			// " (Valor bruto)"
Else
	cValor := Str( nValor, 13, 2 ) + STR0022 			// " (Valor liquido)"
EndIf

Fwrite(nHandle2, STR0014 + cValor + chr(13) + chr(10) )	// "Valor    : "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica Arquivo SL1 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea( "SL1" )
DbSetOrder( 1 )
If DbSeek( xFilial( "SL1" ) + cNumOrc )
	cNumNota := SL1->L1_DOC
	cSerie   := SL1->L1_SERIE
	nValTemp := Round( SL1->L1_VLRLIQ, 2 )

	If ! ( Str( nValor, 13, 2 ) == Str( nValTemp, 13, 2 ) )
		cMensag := STR0015 + " (SL1) - " + Str( nValTemp, 13, 2 )		// "Mensagem : Diferenca no Valor Total"
		Fwrite( nHandle2, cMensag + chr(13) + chr(10) )
	EndIf
EndIf

If ! Empty( cNumNota )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica Arquivo SF2 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea( "SF2" )
	DbSetOrder( 1 )
	If DbSeek( xFilial( "SF2" ) + cNumNota + cSerie )
		nValTemp := ( Round( SF2->F2_VALMERC, 2 ) + Round( SF2->F2_VALIPI, 2 ) )
		If ! ( Str( nValor, 13, 2 ) == Str( nValTemp, 13, 2 ) )
			cMensag := STR0015 + " (SF2) - " + Str( nValTemp, 13, 2 )	// "Mensagem : Diferenca no Valor Total"
			Fwrite( nHandle2, cMensag + chr(13) + chr(10) )
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica Arquivo SL2 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea( "SL2" )
	DbSetOrder( 1 )
	DbSeek( xFilial( "SL2" ) + cNumOrc )
	While ! EOF() .AND. ( xFilial( "SL2" ) + cNumOrc == SL2->L2_FILIAL + SL2->L2_NUM )
		nCntSL2 ++
		dbSkip()
	Enddo
	If nCntSL2 <> nCont
		cMensag := STR0016 + " (SL2)"						// "Mensagem : Diferenca no numero de itens (SL2)"
		Fwrite( nHandle2, cMensag + chr(13) + chr(10) )
	EndIf
	
	DbSelectArea( "SL2" )
	DbSetOrder( 1 )
	DbSeek( xFilial( "SL2" ) + cNumOrc )

	For i := 1 to nCont
		nValTemp := Round( SL2->L2_VLRITEM, 2 ) + Round( SL2->L2_VALIPI, 2 ) + Round( SL2->L2_DESCPRO, 2 )
		If lVendaAss .OR. cFunName == "LOJA720"
			nDifer  := Round( aCloaCols[i][nPosVlItem], 2 )
		ElseIf cFunName == "LOJA010" .OR. cFunName == "LOJA020"
			nDifer	:= Round( aCloaCols[i][nPosVlItem], 2 ) + Round( aCloaCols[i][nPosVlIpi], 2 )
		Else
			nDifer	:= Round( aCloaCols[i][nPosVrUnit], 2 )
		EndIf
		If ! ( Str( nDifer, 13, 2 ) == Str( nValTemp, 13, 2 ) )
			cMensag := STR0017 + " (SL2) - " + Str( nValTemp, 13, 2 )	// "Mensagem : Diferenca no Valor Item"
			Fwrite(nHandle2, cMensag + chr(13) + chr(10) )
		EndIf

		If ! EOF()
			dbSkip()
		EndIf
	Next i
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica Arquivo SD2 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea( "SD2" )
	DbSetOrder( 3 )
	DbSeek( xFilial( "SD2" ) + cNumNota + cSerie )
	While ! eof() .AND. ( xFilial( "SD2" ) + cSerie + cNumNota == SD2->D2_FILIAL + SD2->D2_SERIE + SD2->D2_DOC )
		nCntSD2 ++
		dbSkip()
	Enddo
	If nCntSD2 <> nCont
		cMensag := STR0016 + " (SD2)"					// "Mensagem : Diferenca no numero de itens"
		Fwrite(nHandle2, cMensag + chr(13) + chr(10) )
	EndIf
	
	DbSelectArea( "SD2" )
	DbSetOrder( 7 )
	DbSeek( xFilial( "SD2" ) + iif( lVendaAss .OR. cFunName == "LOJA720", SL1->L1_PDV, cNumPdv ) + cSerie + cNumNota + cCliente + cLoja )

	For i := 1 to nCont
		nValTemp	:= Round( SD2->D2_TOTAL, 2 ) + Round( SD2->D2_VALIPI, 2 ) + Round( SD2->D2_DESCON, 2 )
		If lVendaAss .OR. cFunName == "LOJA720"
			nDifer  := Round( aCloaCols[i][nPosVlItem], 2 )
		ElseIf cFunName == "LOJA010" .OR. cFunName == "LOJA020"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valor + Ipi + Desconto³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nDifer	:= Round( aCloaCols[i][nPosVlItem], 2 ) + Round( aCloaCols[i][nPosVlIPI], 2 ) + Round( aCloaCols[i][nPosValDesc], 2 )
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valor + Desconto³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nDifer	:= Round( aCloaCols[i][nPosVrUnit], 2 ) + Round( aCloaCols[i][nPosDesc], 2 )
		EndIf

		If ! ( Str( nDifer, 13, 2 ) == Str( nValTemp, 13, 2 ) )
			cMensag := STR0017 + " (SD2) - " + Str( nValTemp, 13, 2 )	// ("Mensagem : Diferenca no Valor Item"
			Fwrite(nHandle2, cMensag + chr(13) + chr(10) )
		EndIf

		If !EOF()
			dbSkip()
		EndIf
	Next i
	
EndIf

Fwrite( nHandle2, repl('-',70) + chr(13) + chr(10) )
Fclose( nHandle2 )

Return .T.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ LjCanCup ³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 25/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cancela Cupom Fiscal                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ LOJA010 / LOJA220                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LjCanCup( cImpressora, cPorta )
Local nRet := -1

nRet := IFCancCup( nHdlECF )

Return ( nRet == 0 )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ LjGrLogR ³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 02/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava Log de Recuperacao                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ LOJA010 / LOJA220                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LjGrLogR( cOrc, aColsAux, nPosAux )

Local cLJArq	:= Space(08)
Local nHandle	:= 0
Local nI		:= 0
Local cCaixa	:= xNumCaixa()
Local cLinha	:= ""
Local xCols
Local cTipo		:= ""
Local lLJMod3	:= SuperGetMV("MV_LJMOD3")
Local cCRLF		:= Chr(13) + Chr(10)
Local lVendaAss := IsInCallStack("LOJA701")
Local lLock		:= .T.

cLJArq := "RC" + cOrc + "." + cCaixa

If FunName() $ "LOJA010|LOJA220"

	If ! lLJMod3

		If ! File( LOG_DIR + cLJArq )

			nHandle := FCreate( LOG_DIR + cLJArq, FC_NORMAL )

			If FError() <> 0
				MsgAlert( STR0024, cLJArq )			// "Nao foi possivel criar arquivo de Log."
				Return (.F.)
			EndIf

			lLogRecupera := .T.						// Indica que o log acabou de ser criado.

			FWrite( nHandle, FunName() + cCRLF )

			If FunName() == "LOJA010"

				FWrite( nHandle, ValType(oVend:cText) )
				FWrite( nHandle, oVend:cText + cCRLF )

				FWrite( nHandle, ValType(oCliente:cText) )
				FWrite( nHandle, oCliente:cText + cCRLF )

				FWrite( nHandle, ValType(oLoja:cText) )
				FWrite( nHandle, oLoja:cText + cCRLF )

			ElseIf FunName() == "LOJA220"

				FWrite( nHandle, ValType( cVendLoja ) )
				FWrite( nHandle, cVendLoja + cCRLF )

				FWrite( nHandle, ValType( cCliente ) )
				FWrite( nHandle, cCliente + cCRLF )

				FWrite( nHandle, ValType( cLojacli ) )
				FWrite( nHandle, cLojacli + cCRLF )

			EndIf

		Else

			nHandle := FOpen( LOG_DIR + cLJArq,FO_WRITE )
			lLock	:= LockByName(cLJArq,.T.,.T.)	//Faz bloqueio para acesso exclusivo
			
			If (FError() <> 0) .OR. !lLock
				MsgAlert( STR0001, cLJArq ) 				// "Nao foi possivel abrir arquivo de Log."
				UnLockByName(cLJArq,.T.,.T.) 				//Faz desbloqueio do acesso exclusivo
				Return (.F.)
			EndIf

			FSeek( nHandle, 0, 2 )  //-- Posiciona no final do arquivo.

		EndIf

		For nI := 1 To Len( aColsAux[nPosAux] )

			xCols := aColsAux[nPosAux,nI]
			cTipo := ValType( xCols )

			Do Case
				Case cTipo == "N"
					cLinha := Str( xCols )

				Case cTipo == "D"
					cLinha := DToC( xCols )

				Case cTipo == "L"
					cLinha := Iif( xCols, ".T.", ".F." )

				Case cTipo == "U"
					cLinha := ""

				OtherWise
					cLinha := xCols
			EndCase

			FWrite( nHandle, cTipo + cLinha + cCRLF )

		Next nI
		
		FWrite( nHandle, "@" + cCRLF )					// Marca de fim de Linha do Acols
		FClose( nHandle )
		UnLockByName(cLJArq,.T.,.T.)					//Faz desbloqueio do acesso exclusivo

	EndIf

ElseIf lVendaAss

	If ! File(LOG_DIR + cLJArq)

		nHandle := FCreate( LOG_DIR + cLJArq, FC_NORMAL )

		If FError() <> 0
			MsgAlert( STR0024, cLJArq )				// "Nao foi possivel criar arquivo de Log."
			Return (.F.)
		EndIf

		FWrite( nHandle, FunName() + cCRLF )

		FWrite( nHandle, ValType(M->LQ_VEND) )
		FWrite( nHandle, M->LQ_VEND + cCRLF )

		FWrite( nHandle, ValType(M->LQ_CLIENTE) )
		FWrite( nHandle, M->LQ_CLIENTE + cCRLF )

		FWrite( nHandle, ValType(M->LQ_LOJA) )
		FWrite( nHandle, M->LQ_LOJA + cCRLF )

	Else

		nHandle := FOpen( LOG_DIR + cLJArq, FO_WRITE )
		lLock	:= LockByName(cLJArq,.T.,.T.)		//Faz bloqueio do acesso exclusivo

		If (FError() <> 0) .OR. !lLock
			MsgAlert( STR0001, cLJArq )				// "Nao foi possivel abrir arquivo de Log."
			UnLockByName(cLJArq,.T.,.T.)			//Faz desbloqueio do acesso exclusivo
			Return (.F.)
		EndIf

		FSeek( nHandle, 0, 2 )						//-- Posiciona no final do arquivo.

	EndIf

	For nI := 1 To Len( aHeader )

		cTipo  := ValType(aColsAux[nPosAux,nI])
		xCols  := aColsAux[nPosAux,nI]		
		cLinha := aHeader[nI,02] + "|" + cTipo + "|"
		
		Do Case
			Case cTipo == "N"
				cLinha += Str( xCols )

			Case cTipo == "D"
				cLinha += DToC( xCols )

			Case cTipo == "L"
				cLinha += iIf( xCols, ".T.", ".F." )

			Case cTipo == "U"
				cLinha += ""

			OtherWise
				cLinha += xCols
		EndCase
		
		FWrite( nHandle, cLinha + cCRLF )

	Next nI
	
	FWrite( nHandle, "|DT|" + cCRLF )				// Marca de fim de Linha do Acols	

	For nI := 1 To Len(aHeaderDet)

		cTipo  := ValType(aColsDet[nPosAux,nI])
		xCols  := aColsDet[nPosAux,nI]		
		cLinha := aHeaderDet[nI,02] + "|" + cTipo + "|"
		
		Do Case
			Case cTipo == "N"
				cLinha += Str( xCols )

			Case cTipo == "D"
				cLinha += DToC( xCols )

			Case cTipo == "L"
				cLinha += iIf( xCols, ".T.", ".F." )

			Case cTipo == "U"
				cLinha += ""

			OtherWise
				cLinha += xCols
		EndCase
		
		FWrite( nHandle, cLinha + cCRLF )

	Next nI
	
	FWrite( nHandle, IIf( aColsAux[nPosAux,Len(aColsAux[nPosAux])], ".T.", ".F." ) + cCRLF )
	FWrite( nHandle, "@" + cCRLF )					// Marca de fim de Linha do Acols
	FClose( nHandle )
	UnLockByName(cLJArq,.T.,.T.)					//Faz desbloqueio do acesso exclusivo

EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ LjDeLogR ³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 09/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Deleta Log de Recuperacao                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ LOJA010 / LOJA220                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LjDeLogR( cOrcamento )

Local lLog      := SUBSTR( LJGetProfile( "LOGERRO" ), 4, 1) == "S"					// Log de Recuperacao
Local aDirect   := DIRECTORY( LOG_DIR + "RC" + cOrcamento + "." + xNumCaixa() )		// Log dos Itens 
Local aDirectPA := DIRECTORY( LOG_DIR + "SL" + cOrcamento + "." + xNumCaixa() )		// Log das Parcelas
Local cArqLog   := ""				// Arquivo de Log
Local lRetValue := .F.				// Variavel para retorno da funcao
Local nAuxFor	:= 0				// Variavel auxiliar do For

If !Empty( aDirectPA )				// Soma os dois arrays, com o log de itens e de parcelas 
   aEval( aDirectPA,{|x| AADD(aDirect,{X[1],X[2],X[3],X[4],X[5]})})
EndIf

If lLog .AND. !Empty( cOrcamento )

   For nAuxFor :=1 to Len( aDirect )
       cArqLog := Alltrim( aDirect[nAuxFor][1] )

       If !Empty( cArqLog )	.AND. File( LOG_DIR + cArqLog )
          If Ferase( LOG_DIR + cArqLog ) == 0					// Se conseguiu apagar o arquivo
             lRetValue := .T.
          EndIf
       EndIf   

   Next nAuxFor

EndIf       

Return lRetValue

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    ³ LjRecLog ³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 09/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Recupera dados atraves do Log de Recuperacao               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ LOJA010 / LOJA220                                          ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjRecLog( cOrc )
Local lArroba	:= .F.
Local lTipo		:= .F. 
Local lRecup	:= .T.
Local cTipo 	:= ""
Local cCampo	:= ""
Local cRBuffer	:= ""
Local cModulo	:= ""
Local aColsRec	:= {{}}
Local nSize		:= 0
Local nHandle	:= 0
Local nItem		:= 0
Local n			:= 0
Local nLinha    := 0
Local lVendaAss := IsInCallStack("LOJA701")
Local lLock		:= .T.

//³Verifica a existencia do diretorio de Log³
ChkLogDir()

If ExistFunc("GetlSemServer") .And. GetlSemServer()
	LjAjuRestOrc(cOrc)
EndIf

If LjExiLog( cOrc )[1]
	If FunName() $ "LOJA010|LOJA220"
		If MsgYesNo( STR0021 )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Abre arquivo de Log Exclusivo. ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nHandle := Fopen( LOG_DIR + LjExiLog( cOrc )[2] )
			lLock	:= LockByName(LjExiLog( cOrc )[2],.T.,.T.)	//Faz bloqueio do acesso exclusivo
			If (Ferror() <> 0) .OR. !lLock
				MsgAlert( STR0001, LjExiLog( cOrc )[2] )			// "Nao foi possivel abrir arquivo de Log."
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Leitura do Log de Recuperacao  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nItem 	:= 1
				nSize 	:= Fseek( nHandle, 0, 2 )
				Fseek ( nHandle, 0, 0 )

				For n := 0 to nSize
					cRBuffer 	:= Space(1)
					Fseek( nHandle, n, 0 )
					Fread( nHandle, @cRBuffer, 1 )
				
					If cRBuffer == "@"    		// Outro Produto do Log
						lArroba := .T.
						nItem ++
						AAdd( aColsRec,{} )
					ElseIf cRBuffer == CHR(10) 	// Outra Linha do Log
					    nLinha ++
						If lArroba
							lArroba	:= .F.
						Else
							If nLinha == 2
								If FunName() == "LOJA010"
									oVend:cText	:= cCampo
								ElseIf FunName() == "LOJA220"
									cVendLoja	:= cCampo
								EndIf
							ElseIf nLinha == 3
								If FunName() == "LOJA010"
									oCliente:cText	:= cCampo
								ElseIf FunName() == "LOJA220"
									cCliente		:= cCampo
								EndIf
							ElseIf nLinha == 4
								If FunName() == "LOJA010"
									oLoja:cText	:= cCampo
								ElseIf FunName() == "LOJA220"
									cLojacli	:= cCampo
								EndIf
							ElseIf nLinha == 1 .OR. nLinha > 4
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³   Adiciona campo a matriz      ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If Left( cCampo, 7 ) <> "LOJA010" .AND. Left( cCampo, 7 ) <> "LOJA220"
									If cTipo == "N"
										cCampo	:= Val( cCampo )
									ElseIf cTipo == "D"
										cCampo 	:= Ctod( cCampo )
									ElseIf cTipo == "L"
										cCampo := (cCampo == ".T.")
									EndIf
									AADD( aColsRec[nItem], cCampo )
								Else
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³   Adiciona campo a matriz      ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									cModulo	:= Left( cCampo,7 )
									If cModulo # FunName()			// Abandona se For outro Modulo
										Fclose( nHandle )
										Ferase( LOG_DIR + LjExiLog( cOrc )[2] )
										aColsRec := {{}}
										Return ( aColsRec )
									EndIf
								EndIf
	                        EndIf
							lTipo 		:= .T.
							cCampo 		:= ""
						EndIf
					ElseIf ( cRBuffer <> Chr(13) .AND. cRBuffer <> Chr(10) .AND. cRBuffer <> "@" )
						If lTipo	// Indica se e' a posicao do tipo no Log
							lTipo := .F.
							cTipo := cRBuffer
						Else
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³   Monta campo da Matriz        ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							cCampo := cCampo + cRBuffer
						EndIf
					EndIf
				Next n
			
				If Empty( aColsRec[nItem] )
					Adel( aColsRec, nItem )
					Asize( aColsRec, nItem - 1 )
				EndIf
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³   Apaga o Log de Recuperacao   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Fclose( nHandle )
		UnLockByName(LjExiLog( cOrc )[2],.T.,.T.) 	//Faz desbloqueio do acesso exclusivo
		Ferase( LOG_DIR+LjExiLog( cOrc )[2] )
	ElseIf lVendaAss
		aColsRec := {}
		If !MsgYesNo( STR0021 )								// "Deseja Recuperar itens abortados, nesta Venda ?"
			If MsgYesNo( STR0035) //"Deseja realmente cancelar a recuperação da ultima venda ?"							
				LjWriteLog( LOG_TEF + cOrc + ".TXT", "Usuario cancelou a recuperacao do orcamento" )
	  			lRecup := .F.					
			EndIf
		EndIf

		If lRecup
			Processa({|lEnd| LjRecupVenda(cOrc, @aColsRec)},STR0032)//"Recuperando Itens..." 
		Else
			Processa({|lEnd| LjRecupVenda(cOrc, @aColsRec)},STR0036)//"Cancelando reservas geradas para este orçamento..." 
			If !empty(aColsRec)
				Processa({|lEnd| LjExcluRes  (cOrc, @aColsRec)},STR0036)//"Cancelando reservas geradas para este orçamento..." 
			EndIf
			aColsRec := {}		// Limpo o aColsRec. Ele soh foi alimentado para cancelar as reservas
		EndIf
	EndIf
EndIf

Return aColsRec

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    ³ LjExiLog ³ Autor ³ Edilson Mendes        ³ Data ³ 09/01/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica a existencia de Log de recuperacao                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cOrcamento: Núemro do Orça,emto                            ³±±
±±³          ³ cArqLog   : Iniciais do arquivo para verificacao "RC" "SL" ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ LOJA010 / LOJA220                                          ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjExiLog( cOrcamento, cArqLog )
Local lLog      := SUBSTR( LJGetProfile( "LOGERRO" ), 4, 1) == "S"				// Log de Recuperacao
Local aDirect   := DIRECTORY( LOG_DIR + IIf(Valtype( cArqLog ) == "U", "RC", cArqLog ) + cOrcamento + '.' + xNumCaixa() )
Local aRet		:= {}
Local lRetValue := .F.
Local cArquivo  := ""

If lLog .AND. !EMPTY( cOrcamento ) .AND. !EMPTY( aDirect ) .AND. ( Type( "lLogRecupera") == "U" .OR. !lLogRecupera )
   If !EMPTY( aDirect[1][1] ) .AND. FILE( LOG_DIR+aDirect[1][1] )
      cArquivo  := aDirect[1][1]
      lRetValue := .T.
   EndIf
EndIf

aRet := { lRetValue, cArquivo }

Return aRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    ³ ChkLogDir³ Autor ³ Cesar Valadao         ³ Data ³ 26/07/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica a existencia do diretorio de Log                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ LOJA010 / LOJA220                                          ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ChkLogDir
If __lFirst
	MakeDir( "\AUTOCOM" )
	MakeDir( "\AUTOCOM\LOG" + cEmpAnt + StrTran(Alltrim(cFilAnt)," ","") )
	__lFirst := .F.
EndIf

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    ³ LjGrLogT ³ Autor ³ Solange Zanardi       ³ Data ³ 22/09/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Recupera em formato de array os Logs gerados durante os    ³±±
±±³          ³ processos de gravação                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ LOJA010                                                    ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjGrLogT(	cNumOrc		,	cNumNota	,	cCaixa		,	aTefDados	,;
					nDinheiro	,	nCheques	,	nValorCart	,	nValorDebi	,;
					nValorConv	,	nValorVale	,	nValorFin	,	nOutros		,;
					nDescloj	,	nDescPer	,	cNumPdv		,	cSerieLG	,;
					nVlrPagDig	, nVlrPagPix	)

Local cAlias      := Alias()
Local cOrdem      := IndexOrd()
Local nRecno      := Recno() 
Local nRegSL1     := SL1->(Recno())
Local nOrdSL1     := SL1->(indexOrd())
Local nRegSL2     := SL2->(Recno())
Local nOrdSL2     := SL2->(indexOrd())
Local nRegSL4     := SL4->(Recno())
Local nOrdSL4     := SL4->(indexOrd())
Local cLjArq	  := Space(08)
Local nHandle	  := 0
Local c           := 0           
Local nTotc       := 0
Local lLjMod3     := GetNewPar("MV_LJMOD3",.F.)
Local cxFilial    := xFilial("SL1")
Local nContador   := 0
Local nAuxFor	  := 0
Local lVendaAss   := IsInCallStack("LOJA701")

DEFAULT cSerieLG  	:= cSerie
DEFAULT aTefDados	:= {}
DEFAULT aNccItens	:= {}
DEFAULT nVlrPagDig 	:= 0
DEFAULT nVlrPagPix  := 0

If ( ! lLjMod3 ) .OR.  lVendaAss 

	cLjArq := 'SL' + cNumOrc + '.' + cCaixa

	If !File( LOG_DIR + cLjArq )
		nHandle := Fcreate( LOG_DIR + cLjArq, FC_NORMAL )

		If Ferror() <> 0
			MsgAlert( STR0024, cLjarq )					// "Nao foi possivel criar arquivo de Log"
			Return (.F.)
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Iniciando a gravação do Cabeçalho do Log³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        Fwrite( nHandle, "@ORC#" + PADR( cNumOrc, 10 ) + "#CUP#" + PADR( cNumNota, 10 ) + "#SER#" +	PADR( cSerieLG, 10 ) +;
        		"#RED#" + PadR( If( Len( aTefDados ) > 0, aTefDados[1][11], Space(10) ),10 ) + chr(13)+chr(10) )

 	    DbSelectArea( "SL1" ) // Já estou posicionada no registro correto para gravação
        nContador := 1 // so tenho um registro no SL1
 	    nTotc := fcount()

 	    For c := 1 to nTotc
            If !Empty( fieldget(c) )
                LjGrLinT( nHandle, "SL1", Fieldname(c), Fieldget(c), nContador )
            EndIf    
 	    Next c

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Gravando dados completos da venda³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        LjGrLinT( nHandle, "SL1", "L1_DOC",		cNumNota,		nContador )
        LjGrLinT( nHandle, "SL1", "L1_SERIE",	cSerieLG,		nContador )
        LjGrLinT( nHandle, "SL1", "L1_PDV",		cNumPdv,		nContador )
        LjGrLinT( nHandle, "SL1", "L1_NUMCFIS",	cNumNota,		nContador )
        LjGrLinT( nHandle, "SL1", "L1_EMISNF",	dDataBase,		nContador )
        LjGrLinT( nHandle, "SL1", "L1_VALBRUT",	SL1->L1_VLRTOT,	nContador )
        LjGrLinT( nHandle, "SL1", "L1_VALMERC",	SL1->L1_VLRLIQ,	nContador )

        If SL1->L1_TIPO <> "P"
	        LjGrLinT( nHandle, "SL1", "L1_TIPO", "V", nContador )
	    EndIf

        LjGrLinT( nHandle, "SL1", "L1_DINHEIRO",nDinheiro,			nContador )
        LjGrLinT( nHandle, "SL1", "L1_CHEQUES",	nCheques,			nContador )
        LjGrLinT( nHandle, "SL1", "L1_CARTAO",	nValorCart,			nContador )
        LjGrLinT( nHandle, "SL1", "L1_VLRDEBI",	nValorDebi,			nContador )
        LjGrLinT( nHandle, "SL1", "L1_CONVENI",	nValorConv,			nContador )
        LjGrLinT( nHandle, "SL1", "L1_VALES",	nValorVale,			nContador )
        LjGrLinT( nHandle, "SL1", "L1_FINANC",	nValorFin,			nContador )
        LjGrLinT( nHandle, "SL1", "L1_OUTROS",	nOutros,			nContador )

		If nVlrPagDig > 0 .And. SL1->(ColumnPos("L1_VLRPGDG")) > 0
			LjGrLinT( nHandle, "SL1", "L1_VLRPGDG",	nVlrPagDig,		nContador )
		EndIf
		If nVlrPagPix > 0 .And. SL1->(ColumnPos("L1_VLRPGPX")) > 0
			LjGrLinT( nHandle, "SL1", "L1_VLRPGPX",	nVlrPagPix,		nContador )
		EndIf

        LjGrLinT( nHandle, "SL1", "L1_DESCONT",	nDescloj,			nContador )
        LjGrLinT( nHandle, "SL1", "L1_DESCNF",	nDescPer,			nContador )
        LjGrLinT( nHandle, "SL1", "L1_OPERADO",	cCaixa,				nContador )
        LjGrLinT( nHandle, "SL1", "L1_HORA",	SubStr(Time(),1,5),	nContador )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Gravar Dados da Transação TEF³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 	    If aTefDados <> Nil .AND. Len( aTefDados ) > 0 
           LjGrLinT( nHandle, "SL1", "L1_VENDTEF","S",				nContador )
           LjGrLinT( nHandle, "SL1", "L1_DATATEF",aTefDados[1][2],	nContador )
           LjGrLinT( nHandle, "SL1", "L1_HORATEF",aTefDados[1][3],	nContador )
           LjGrLinT( nHandle, "SL1", "L1_DOCTEF", aTefDados[1][4],	nContador )
           LjGrLinT( nHandle, "SL1", "L1_AUTORIZ",aTefDados[1][5],	nContador )
           LjGrLinT( nHandle, "SL1", "L1_INSTITU",aTefDados[1][8],	nContador )
           LjGrLinT( nHandle, "SL1", "L1_DOCCANC",aTefDados[1][6],	nContador )
           LjGrLinT( nHandle, "SL1", "L1_DATCANC",aTefDados[1][12],	nContador )
           LjGrLinT( nHandle, "SL1", "L1_HORCANC",aTefDados[1][7],	nContador )
           LjGrLinT( nHandle, "SL1", "L1_NSUTEF", aTefDados[1][9],	nContador )
           LjGrLinT( nHandle, "SL1", "L1_TIPCART",aTefDados[1][10],	nContador )

	 	   If !Empty( aTefDados[1][15] )
               LjGrLinT( nHandle, "SL1", "L1_FORMPG", aTefDados[1][15], nContador )
		   EndIf
        EndIf

        If nTotc > 0
  	       Fwrite( nHandle, "@SL1" + chr(13) + chr(10) )				// Marca Fim de Registro
  	    EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Gravando dados a serem recuperados SL2³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea( "SL2" )
		DbSetOrder( 1 )
		DbSeek( cxFilial + cNumOrc )
		nContador	:= 0

		While !Eof( ) .AND. cxFilial == SL2->L2_FILIAL .AND. cNumOrc == SL2->L2_NUM 
            nContador++          
       	    nTotc := Fcount()

  	        For c:=1 to nTotc
                If !Empty( Fieldget(c) )
                    LjGrLinT( nHandle, "SL2", Fieldname(c), Fieldget(c), nContador )
                EndIf
 	        Next c

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Dados Adicionais ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            LjGrLinT(nHandle,"SL2","L2_DOC",cNumNota,nContador)
            LjGrLinT(nHandle,"SL2","L2_SERIE",cSerieLG,nContador)
            LjGrLinT(nHandle,"SL2","L2_PDV",cNumPdv,nContador)
            LjGrLinT(nHandle,"SL2","L2_VENDIDO","S",nContador)
  	        Fwrite(nHandle,"@SL2"+chr(13)+chr(10)) // Marca Fim de Registro
			dbSkip()
		End

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Gravando dados a serem recuperados SL4³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 	    DbSelectArea( "SL4" )
	    DbSetOrder( 1 )
	    DbSeek( cxFilial + cNumOrc )
        nContador := 0

	    While !Eof() .AND. cxFilial == SL4->L4_FILIAL .AND. cNumOrc == SL4->L4_NUM 
            nContador++          
       	    nTotc := Fcount()

  	        For c:=1 to nTotc
                If !Empty( Fieldget(c) )
                   LjGrLinT( nHandle, "SL4", Fieldname(c), Fieldget(c), nContador )
				ElseIf Fieldname(c) == "L4_ADMINIS" .AND. aTefDados <> Nil .AND. Len( aTefDados ) > 0 
					LJGrLinT( nHandle, "SL4", Fieldname(c), aTefDados[1][8], nContador )
                EndIf
 	        Next c

   	        Fwrite( nHandle, "@SL4" + chr(13) + chr(10) )			// Marca Fim de Registro
			dbSkip()
	    End

		If Len ( aNccItens ) > 0

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Grava o registro da NCC³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nAuxFor := 1 to Len ( aNccItens )
				Fwrite( nHandle, "NCC#" + IIF( aNCCItens[nAuxFor][1], ".T.", ".F." ) + "#" + Alltrim ( STR( aNccItens[nAuxFor][5] ) ) + chr(13)+chr(10) )
			Next nAuxFor
			
			Fwrite( nHandle, "@NCC" + chr(13)+chr(10) )
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Fechando arquivo de Log SL³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
  		Fclose( nHandle )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Retorna o alias e retornando as posições anteriores³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 
 	    DbSelectArea( "SL1" )
   	    DbSetOrder( nOrdSL1 )
 	    dbGoto( nRegSL1 )

 	    DbSelectArea( "SL2" )
   	    DbSetOrder( nOrdSL2 )
 	    dbGoto( nRegSL2 )

 	    DbSelectArea( "SL4" )
   	    DbSetOrder( nOrdSL4 )
 	    dbGoto( nRegSL4 )

		DbSelectArea( cAlias )
		DbSetOrder( cOrdem )
		dbGoto( nRecno )
	EndIf
EndIf	    

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    ³ LjGrLinT ³ Autor ³ Solange Zanardi       ³ Data ³ 22/09/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava a linha do Log de Recuperacao                        ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nHand  = Núero do TXT em memoria						      ³±±
±±³          ³cAlias = Alias do arquivo para identificacao 			      ³±±
±±³          ³cCampo = Nome do campo no arquivo					          ³±±
±±³          ³cConteudo = Counteudo do campo							  ³±±
±±³          ³cTipo  = Tipo de ca´mpo                                     ³±±
±±³          ³nCont  = Contador de Registro                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ LOJXLOG                                                    ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjGrLinT(	nHand,	cAlias,	cCampo,	cConteudo,;
					nContador )

Local cGrava  := ""
Local cTipo   := ""
Local cString := ""

cCampo	:= Alltrim( upper( cCampo ) )
cTipo	:= Valtype( cConteudo )

If cTipo == "N"
   cGrava := STR( cConteudo, 30, TamSx3( cCampo )[2] )
ElseIf cTipo == "D"
   cGrava := DTOC( cConteudo )
ElseIf cTipo == "L"
   cGrava := IIf( cConteudo, ".T.",".F." )
Else
   cGrava := cConteudo
EndIf

cString := cAlias + '#' + StrTran( Str( nContador,3 )," ","0" ) + '#' + PADR( cCampo, 10 ) + '#' + cTipo + "#" + Alltrim( cGrava ) + chr(13) + chr(10)

Fwrite( nHand, cString )

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    ³ LjReLogT ³ Autor ³ Solange Zanardi       ³ Data ³ 22/09/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Recupera em formato de array e grava os dados apagados     ³±±
±±³          ³ nas devidas tabelas do sistema                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cOrc    - Número do orçamento                              ³±±
±±³          ³ cArray  - Nome da Array a ser montada                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³FORMATO DO ARQUIVO DE LOG                                              ³±±
±±³SL1#001#L1_FILIAL #C#000001                                            ³±±
±±³123456789012345678901234567890                                         ³±±
±±³         1         2         3 ...                                     ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjReLogT( cOrc )
Local nHandle		:= 0								// Utilizada para gravar o Handle do arquivo que está sendo utilizado
Local nSize			:= 0								// Variavel para armazenar o tamanho do arquivo
Local cRBuffer		:= ""								// Utilizada para armazenar o conteudo da linha do TXT
Local cNota			:= ""								// Numero do cupom fiscal
Local aRecSL1		:= {}								// Array com os dados que serao gravados no SL1
Local aRecSL2		:= {}								// Array com os dados que serao gravados no SL2
Local aRecSL4		:= {}								// Array com os dados que serao gravados no SL4
Local aAuxArea		:= {}								// Variavel auxiliar para guardar as areas de cada Tabela
Local nPos			:= 0								// Posicao no array aRecSL4
Local nAuxFor		:= 0								// Variavel auxiliar no For
Local cCampo		:= ""								// Grava o conteudo do campo
Local lRet			:= .F.								// Retorno da funcao
Local cOrca			:= ""								// Numero do Orcamento
Local cRede			:= '00'								// Rede do cartao de Credito
Local cL4_ADMINIS	:= ""								// Variavel com o codigo do cartao de Credito + Descricao
Local nVlrTot		:= 0								// Variavel com o L1_VLRTOT
Local nNCCUsada		:= 0								// Valor do credito L1_CREDITO
Local nNCCGerada	:= 0								// Total do valor do L1_CREDITO - L1_VLRTOT
Local nTotGeral		:= 0								// Total Geral
Local lNCCUsada		:= .T.								// Verifica se tem NCC sendo utilizada
Local cMvSimb1		:= SuperGetMV( "MV_SIMB1" )			// Simbolo da moeda
Local cNumDoc       := ""								// Guarda conteudo do campo L1_DOC. Usada para verificar se deve chamr função LjGrvTudo.
Local lGrvSL1       := .F.								// Indica se a função FRTGeraSL conseguiu gravar o SL1 com sucesso. Tambem usada para verificar se deve chamr função LjGrvTudo.
Local lLock			:= .T.
Local cSeri			:= ""

Private aNCCItens := {}									// Array com as NCCs que podem ser utilizadas

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica a existencia do diretorio de Log³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ChkLogDir()

If !Empty( LOG_TEF )
	LjWriteLog( LOG_TEF + cOrc + '.TXT', '-- LJReLogT - Inicio ' + Replicate('-',40) )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica a existencia do log de recuperacao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If LjExiLog( cOrc, "RC" )[1]

	If ! Empty( LOG_TEF )
		LjWriteLog( LOG_TEF + cOrc + '.TXT', 'LJExiLog - S / 1SL)' + LjExiLog( cOrc, "RC" )[2] )
	EndIf

	nHandle := Fopen( LOG_DIR + LjExiLog( cOrc, "RC" )[2] )
	lLock	:= LockByName(LjExiLog( cOrc, "RC" )[2],.T.,.T.)	//Faz bloqueio do acesso exclusivo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se houve erro na abertura³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (Ferror() <> 0 ) .OR. !lLock
		MsgAlert( STR0001, LjExiLog( cOrc, "RC" )[2] )		//"Nao foi possivel abrir arquivo de Log. Por favor, entre em contato com o Administrador do Sistema"

		If ! Empty(LOG_TEF)
			LjWriteLog( LOG_TEF + cOrc + '.TXT', 'FError() <> 0')
		EndIf

	Else
		If ! Empty(LOG_TEF)
			LjWriteLog( LOG_TEF + cOrc + '.TXT', 'Recuperaçaõ da venda.')
		EndIf
	
		nSize	:=Fseek( nHandle, 0, 2 )					// vai para o final do arquivo
		Fseek(	nHandle, 0, 0 )								// volta para o inicio do arquivo

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Varre o arquivo inteiro³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nAuxFor	:= 0 to nSize

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Vou verificar se o primeiro caracter é @ 1º linha³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cRBuffer	:= Space(1)
			Fseek( nHandle, nAuxFor, 0 )
			Fread( nHandle, @cRBuffer, 1 )

			If cRBuffer <> Chr(10)             		// Não é Final de Linha somar string
				cCampo := cCampo + cRBuffer

			ElseIf cRBuffer == chr(10)         		// Encontrei o final da linha
				If SubStr( cCampo, 1, 5 ) == "@ORC#"	// Primeira linha do Log
					cOrca := Alltrim( SubStr( cCampo, 06, 10 ) )
					cNota := Alltrim( SubStr( cCampo, 21, 10 ) )
					cSeri := Alltrim( SubStr( cCampo, 31, 10 ) )
					cRede := Alltrim( SubStr( cCampo, 51, 10 ) )

				ElseIf SubStr(cCampo,1,2) == "SL" // Conteudo dos registros do SL
					cCampo	:= StrTran( cCampo,Chr(13),"")
					cNomFil	:= Alltrim( SubStr( cCampo, 09, 10 ) )
					CTipFil	:= Alltrim( SubStr( cCampo, 20, 01 ) )
					cConFil	:= Alltrim( SubStr( cCampo, 22, Len( cCampo ) - 21 ) )

					cConFil	:=	IIf( CTipFil=="N", Val( cConFil ),;
							 	IIf( CTipFil=="D", Ctod( cConFil ),;
							 	IIf( CTipFil=="L", ( CTipFil = '.T.' ), cConFil ) ) )

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³A funcao ljgrvtudo ira refazer estes valores, se mandar conteudo ela continuara somando³
					//³Gerando um valor dobrado ...                                                           ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If SubStr( cCampo, 1, 3 ) == "SL1"
						If cNomFil == 'L1_VALICM' .OR. cNomFil == 'L1_VALIPI' .OR. cNomFil == 'L1_VALISS' 
							cConFil:=0
						EndIf

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Quando ocorre a recuperacao do LOG, deve corrigir o L4_ADMINIS³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If cNomFil == 'L1_INSTITU' .AND. !Empty( cConFil )
						    SAE->(DbSetOrder(1))						    
							SAE->(DbSeek(xFilial("SAE")))
							While !SAE->( EOF() ) .AND. SAE->AE_FILIAL == xFilial("SAE")
								If Upper( Alltrim( cConFil ) ) == Alltrim( Upper( Left( SAE->AE_DESC, 16 ) ) )
									cL4_ADMINIS := SAE->AE_COD + ' - ' + SAE->AE_DESC
									Exit
								EndIf
								SAE->(dbSkip())
							End
		                EndIf
		            EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Fim de Recuperacao³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If SubStr( cCampo, 1, 3 ) == 'SL1'
						AADD( aRecSL1,{ cNomFil, cConFil } )

					ElseIf SubStr( cCampo, 1, 3) == 'SL2'   
						AADD( aRecSL2,{ cNomFil, cConFil } )

					ElseIf SubStr( cCampo, 1, 3 ) == 'SL4'   
						AADD( aRecSL4,{ cNomFil, cConFil } )
					EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Conteudo dos registros da NCC³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				ElseIf SubStr( cCampo, 1, 3) == "NCC"
					lNCCUsada	:= &(AllTrim( SubStr( cCampo, 5, 3 ) ) )
					cRecNo 		:=	 AllTrim( SubStr( cCampo, 9 ) )
										
					aAuxArea := GetArea()
					
					DbSelectArea( "SE1" )

					SE1->( DbGoto ( Val( cRecNo ) ) )
					AAdd( aNCCItens, { lNCCUsada, SE1->E1_SALDO, SE1->E1_NUM, SE1->E1_EMISSAO, SE1->( Recno() ) } )
					
					DbSelectArea( "SL1" )
					DbSetOrder( 1 )
					
				    If SL1->( DbSeek( xFilial( "SL1" ) + cOrc ) )
				    	nVlrTot 	:= SL1->L1_VLRTOT
				    	nNCCUsada 	:= SL1->L1_CREDITO
				    EndIf

					DbSelectArea( "SL4" )
					DbSetOrder( 1 )
					
				    If SL4->( DbSeek( xFilial( "SL4" ) + cOrc ) )
				    	nTotGeral := 0
				    	
				    	While !Sl4->( EOF() ) .AND. SL4->L4_NUM == cOrc

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Soma os valores colocados na condição de pagamento.³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							nTotGeral += SL4->L4_VALOR
							
							SL4->( DbSkip() )
						End

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Desconta o valor total da venda e os impostos (PIS/COFINS/CSLL).³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						nTotGeral  := ( nVlrTot - nTotGeral )

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Calcula a nova NCC a ser gerada. Substraindo o que já foi usado de NCC com o que sobrou no nTotGeral.³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						nNCCGerada := Abs( ( nNCCUsada - nTotGeral ) )

						If nNCCGerada > 0
							Aviso( "Nota de Crédito ao Cliente", "Irá restar um crédito no valor de: " + cMvSimb1 + " " + AllTrim( Transform( nNccGerada, PesqPict( "SE1", "E1_VALOR") ) ), { "Ok" } )
						Else
							nNCCGerada := 0
						EndIf
				    EndIf
				
					RestArea( aAuxArea )

				ElseIf SubStr(cCampo,1,3) == "@SL"				// Fim de Registro SL
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Identifica Fim de Registro - Gera o SL³
					//³Limpa o array para a proxima inclusao ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If SubStr( cCampo, 2, 3 ) == 'SL1'					    
						lGrvSL1  := FRTGeraSL( 'SL1', aRecSL1, .T. )
						aRecSL1 := {}
						If lGrvSL1 .AND. !SL1->(EOF())  
						   cNumDoc  := SL1->L1_DOC
						   If !Empty( LOG_TEF )
							  LjWriteLog( LOG_TEF + cOrc + '.TXT', "Atualiza cNumDoc. cNumDoc: " + cNumDoc )
						   EndIf															   						   
						Else
						   If !Empty( LOG_TEF )
							  LjWriteLog( LOG_TEF + cOrc + '.TXT', "Nao atualiza cNumDoc. lGrvSL1: " + IIf(lGrvSL1,".T.",".F.") )
						   EndIf															   
                        EndIf
					ElseIf SubStr( cCampo, 2, 3 ) == 'SL2'   
						FRTGeraSL( 'SL2', aRecSL2, .T. )
						aRecSL2 := {}

					ElseIf SubStr( cCampo, 2, 3 ) == 'SL4'

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Quando ocorre a recuperacao do LOG, deve corrigir o L4_ADMINIS³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						nPos := AScan( aRecSL4, {|x| x[1] == "L4_FORMA" } )

						If nPos > 0 .AND. ( aRecSL4[nPos][2] == "CC" .OR. aRecSL4[nPos][2] == "CD")
							nPos := AScan( aRecSL4, {|x| x[1] == "L4_ADMINIS" } )
							If nPos > 0
								aRecSL4[nPos][2] := cL4_ADMINIS
							EndIf
						EndIf

						FRTGeraSL( 'SL4', aRecSL4, .T. )
						aRecSL4 := {}

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Tenho certeza de que gravou tudo então retorno verdadeiro, a proxima funcao ira gravar o resto das informações³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						lRet := .T.                        
					EndIf
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Apos processar encontrando o primeiro chr(10) zero a string de trabalho³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cCampo := ""
			ElseIf cRBuffer == chr(13)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄV¿
				//³Apos processar encontrando o primeiro chr(13) zero a string de trabalho³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄVÙ
				cCampo := ""
			EndIf
		Next nAuxFor
		
		If ! Empty( LOG_TEF )
			LjWriteLog( LOG_TEF + cOrc + '.TXT', 'lRet = ' + IIf( lRet, "S", "N" ) )
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se as arrays foram criadas corretamente gerar os arquivos SD2/SE1/SE5/SEF/SF2³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet
		    If Empty(cNumDoc)
				Conout( "Orçamento " + cOrca + " recuperado com sucesso..." )
					
			   If !Empty( LOG_TEF )
			      LjWriteLog( LOG_TEF + cOrc + '.TXT', "Orçamento " + cOrca + " recuperado com sucesso..." )
			   EndIf			   
			Else
				If !LjGrvTudo(	.F.,		.T.,	 nNCCUsada, aNCCItens,;
								nNCCGerada)
				  Conout( "Problemas na recuperação do Cupom Fiscal " + cNota + " referente ao orçamento " + cOrca )
				
				  If ! Empty( LOG_TEF )
					 LjWriteLog( LOG_TEF + cOrc + '.TXT', "Problemas na recuperação do Cupom Fiscal " + cNota + " referente ao orçamento " + cOrca )
				  EndIf									
			   Else 
				  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				  //³Caso seja necessario gravar campos especificos, pois os SL? vieram do arquivo de log³
				  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				  If ExistBlock( "LJLOG_05" )
					 ExecBlock( "LJLOG_05", .F., .F., { cOrc } )
				  EndIf

				  Conout( "Cupom Fiscal " + cNota + " referente ao orçamento " + cOrca + " recuperado com sucesso..." )
					
				  If ! Empty( LOG_TEF )
					 LjWriteLog( LOG_TEF + cOrc + '.TXT', "Cupom Fiscal " + cNota + " referente ao orçamento " + cOrca + " recuperado com sucesso..." )
				  EndIf

				  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				  //³Gravação dos dados para a confirmação da transacao ³
				  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				  DbSelectArea( "SL1" )
				
				  If ! Empty( LOG_TEF )
					 LjWriteLog( LOG_TEF + cOrc + '.TXT', 'Gravação SL1. Registro Nro. = ' + AllTrim( Str( SL1->( RecNo() ) ) ) )
				  EndIf
				
				  If !Empty( SL1->L1_NSUTEF )
					 aTefDados := {{"","","","","","","","","","","","","",{},""}}
					 aTefDados[1][2] := Alltrim( SL1->L1_DATATEF )
					 aTefDados[1][9] := Alltrim( SL1->L1_NSUTEF )
					 aTefDados[1][11]:= cRede
				  EndIf
			   EndIf
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Apos processar fechar e apagar os arquivos de Log³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Fclose( nHandle )
		UnLockByName(LjExiLog( cOrc, "RC" )[2],.T.,.T.) 	//Faz desbloqueio do acesso exclusivo
		
		If ! Empty( LOG_TEF )
			LjWriteLog( LOG_TEF + cOrc + '.TXT', 'Fechou o arquivo 1SL - ' + AllTrim( Str( FError() ) ) )
		EndIf
	EndIf
EndIf

If !Empty( LOG_TEF )
	LjWriteLog( LOG_TEF + cOrc + '.TXT', '-- LJReLogT - Final ' + Replicate('-',40) )
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjWriteLogºAutora ³Solange Zanardi     º Data ³  18/05/2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função criada para a gravação dos Logs de TEF              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGALOJA                                                   º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjWriteLog( cArq, uTexto )
Local nHandle := 0
Local nAuxFor := 0
Local cTexto  := ""

cArq := StrTran(Alltrim(cArq)," ","")
If !File( cArq )
	MakeDir( "\AUTOCOM" )
	MakeDir( "\AUTOCOM\TEF" + cEmpAnt + StrTran(Alltrim(cFilAnt)," ","") )
	nHandle := FCreate( cArq )
	FClose( nHandle )
Endif
If File( cArq )
	nHandle := FOpen( cArq, 2 )
	FSeek ( nHandle, 0, 2 )			// Posiciona no final do arquivo.
	If ValType(uTexto) == "C"
		cTexto := dtoc(dDataBase) + " " + Time() + " " + uTexto
		FWrite( nHandle, cTexto + CRLF, Len(cTexto) + 2 )
	ElseIf ValType(uTexto) == "A"
		For nAuxFor := 1 to len(uTexto)
			cTexto := dtoc(dDataBase) + " " + Time() + " " + uTexto[nAuxFor]
			FWrite( nHandle, cTexto + CRLF, Len(cTexto) + 2 )
		Next nAuxFor
	EndIf
	FClose( nHandle )
EndIf

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LjGrvPai  ºAutora ³Hanna Caroline      º Data ³  17/11/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função criada para a gravacao dos filhos caso exista       º±±
±±º          ³ reserva                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJXLOG                                                    º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function LjGrvPai( cNumOrc )
Local aFilhos	:= {}				//Array com os filhos do orcamento quando existe reserva
Local aAuxArea	:= {}				//Array com a gravacao da area
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica os itens do SL2, para identificar os oscamentos filho ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SL2")
aAuxArea := GetArea()
DbSetOrder(1)

If DbSeek( xFilial("SL2") + cNumOrc )
	While	( !Eof()) 						   		.AND.;
			( xFilial("SL2") == SL2->L2_FILIAL )	.AND.;
			( cNumOrc == SL2->L2_NUM )

			If !Empty( SL2->L2_ORCRES )
				AADD( aFilhos, { SL2->L2_ORCRES, SL2->L2_FILRES } )
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Exclui a reserva³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty( SL2->L2_RESERVA )
				DbSelectArea("SC0")
				DbSetOrder(1)
				If DbSeek( SL2->L2_FILRES + SL2->L2_RESERVA + SL2->L2_PRODUTO )
					Reclock( "SC0",.F. )
					SC0->( DbDelete() )					
					SC0->( MsUnlock() )
				EndIf
			EndIf
			SL2->(DbSkip())
	End		
EndIf
RestArea( aAuxArea )
Return aFilhos

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjDelArq  ºAutora ³Hanna Caroline      º Data ³  17/11/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para exclusao do arquivos de orcamento.             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpC1: Nome do arquivo que sera manipulado                 º±±
±±º          ³ ExpN2: Indice                                              º±±
±±º          ³ ExpC3: Busca a ser realizada na tabela                     º±±
±±º          ³ ExpB4: Expressao do while para delecao                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SigaLoja                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LjDelArq( cArquivo, nIndice, cSeek, bWhile )

Local lRetorno := .T.				// Retorno da Funcao.
Local aAuxArea := GetArea()			// Array com a gravacao da area.

DEFAULT cSeek	:= ""				// Bloco de codigo para o Seek.
DEFAULT bWhile	:= {|| .T.}			// Bloco de codigo para o While.

DbSelectArea( cArquivo )
DbSetOrder( nIndice )

If DbSeek( cSeek )
	While (!eof() .AND. Eval( bWhile ) == cSeek)
		If RecLock( cArquivo, .F. )
			DbDelete()
			MsUnlock()
		Else
			lRetorno := .F.
		EndIf
		DbSkip()
	End
EndIf
RestArea( aAuxArea )
Return lRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjRecupVenda  ºAutora ³Marcelo Dolis       º Data ³  31/10/2006 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para exclusao do arquivos de orcamento.                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpC1: Nome do arquivo que sera manipulado                     º±±
±±º          ³ ExpN2: Indice                                                  º±±
±±º          ³ ExpC3: Busca a ser realizada na tabela                         º±±
±±º          ³ ExpC4: Expressao do while para delecao                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SigaLoja                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LjRecupVenda(cOrc, aColsRec)

Local cTipo 	:= ""
Local cCampo	:= ""
Local cRBuffer	:= ""
Local cModulo	:= ""
Local nSize		:= 0
Local nHandle	:= 0
Local nItem		:= 0
Local nLinha    := 0
Local nLidos    := 0
Local nPos      := 0
Local cField    := ""
Local nReg      := 0
Local aVetC     := {}
Local aVetD     := {}
Local lLock		:= .T.

nHandle := FOpen( LOG_DIR + LJExiLog(cOrc)[02])
lLock	:= LockByName(LJExiLog(cOrc)[02],.T.,.T.)	//Faz bloqueio do acesso exclusivo

If FError() <> 0 .OR. (!lLock)
	MsgAlert( STR0001, LjExiLog(cOrc)[2] )		// "Nao foi possivel abrir arquivo de Log."
	UnLockByName(LJExiLog(cOrc)[02],.T.,.T.) 	//Faz desbloqueio do acesso exclusivo
	Return { {} }
EndIf

nSize := FSeek( nHandle, 0, 2 )					//-- Pega o Tamanho do Arquivo
FSeek( nHandle, 0, 0 )							//-- Posiciona na primeira linha

nLinha	:= 1
nLidos	:= 0
cCampo	:= ""
cModulo	:= "C"
nItem	:= 1

aVetC  := Array(1, ( Len(aHeader) + 1 ) )
aVetD  := Array(1, ( Len(aHeaderDet) + 1 ) )

While nLidos < nSize

	nLidos += FRead( nHandle, @cRBuffer, 1 )
	
	If ! ( cRBuffer $ Chr(13) + Chr(10) + "@" )

		cCampo += cRBuffer

	Else
	
		If cRBuffer == "@"						//-- Final dos Itens
                             
			aAdd(aVetC, Array(( Len(aHeader) + 1 )))
			aAdd(aVetD, Array(( Len(aHeaderDet) + 1 )))

			cModulo := "C"
			nItem ++

		ElseIf cRBuffer == Chr(10)

			Do Case
				Case nLinha == 1

					If FunName() <> cCampo

						FClose( nHandle )
						FErase( LOG_DIR + LjExiLog( cOrc )[2] )

						Return {}

					EndIf

				Case nLinha == 2
					M->LQ_VEND		:= PadR( AllTrim( SubStr( cCampo, 2 ) ), TamSX3("LQ_VEND")[01], " " )

				Case nLinha == 3
					M->LQ_CLIENTE	:= PadR( AllTrim( SubStr( cCampo, 2 ) ), TamSX3("LQ_CLIENTE")[01], " " )

				Case nLinha == 4
					M->LQ_LOJA		:= PadR( AllTrim( SubStr( cCampo, 2 ) ), TamSX3("LQ_LOJA")[01], " " )

				OtherWise

					If AllTrim(cCampo) == "|DT|"
						cModulo := "D"

					ElseIf cCampo $ ".F.T."
						aVetC[nItem,Len(aVetC[nItem])] := ( cCampo == ".T." )
						aVetD[nItem,Len(aVetD[nItem])] := ( cCampo == ".T." )

					Else

						If cModulo == "C"

							cField := AllTrim( SubStr( cCampo, 1, ( At("|", cCampo) - 1 ) ) )
							cTipo  := AllTrim( SubStr( cCampo, ( At("|", cCampo) + 1 ), 1) )
							cCampo := AllTrim( SubStr( cCampo, ( At("|", cCampo) + 3 ) ) )

							If ( nPos := aScan(aHeader, { |x| AllTrim(x[02]) == cField }) ) > 0

								If cField == "LR_ITEM"
									If ( nReg := aScan(aVetC, { |x| AllTrim(x[nPos]) == cCampo }) ) > 0
										nItem := nReg
										aSize(aVetC, ( Len(aVetC) - 1 ))
										aSize(aVetD, ( Len(aVetD) - 1 ))
									EndIf
								EndIf

								If cTipo == "N"
									aVetC[nItem,nPos] := Val( cCampo )
								ElseIf cTipo == "D"
									aVetC[nItem,nPos] := CToD( cCampo )
								ElseIf cTipo == "L"
									aVetC[nItem,nPos] := ( cCampo == ".T." )
								ElseIf cTipo == "U"
									aVetC[nItem,nPos] := Nil
								Else
									aVetC[nItem,nPos] := cCampo
								EndIf

							EndIf

						Else

							cField := AllTrim( SubStr( cCampo, 1, ( At("|", cCampo) - 1 ) ) )
							cTipo  := AllTrim( SubStr( cCampo, ( At("|", cCampo) + 1 ), 1) )
							cCampo := AllTrim( SubStr( cCampo, ( At("|", cCampo) + 3 ) ) )

							If ( nPos := aScan( aHeaderDet, { |x| AllTrim(x[02]) == cField }) ) > 0

								If cTipo == "N"
									aVetD[nItem,nPos] := Val( cCampo )
								ElseIf cTipo == "D"
									aVetD[nItem,nPos] := CToD( cCampo )
								ElseIf cTipo == "L"
									aVetD[nItem,nPos] := ( cCampo == ".T." )
								ElseIf cTipo == "U"
									aVetD[nItem,nPos] := Nil
								Else
									aVetD[nItem,nPos] := cCampo
								EndIf

							EndIf

						EndIf

					EndIf

			EndCase

			nLinha ++
			cCampo := ""

		EndIf

	EndIf

EndDo

aSize(aVetC, ( Len( aVetC ) - 1 ))
aSize(aVetD, ( Len( aVetD ) - 1 ))

aColsRec     := Array(02)
aColsRec[01] := aClone( aVetC )
aColsRec[02] := aClone( aVetD )
      
FClose( nHandle )
UnLockByName(LJExiLog(cOrc)[02],.T.,.T.) 	//Faz desbloqueio do acesso exclusivo

REturn


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³LOJXLOG   ºAutor  ³Marcelo Dolis       º Data ³  06/06/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Recuperacao de vendas interrompidas devido a perda de cone- º±±
±±º          ³xao.                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SigaLoja                                                    º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjRecuperacao()
Local cNumOrc  											// Numero do orcamento
Local cLjArq											// Nome do arquivo para recuperacao
Local aDirect											// Listagem do diretorio de logs
Local cCaixa	:= xNumCaixa()						// Codigo do caixa que esta utilizando o sistema
Local lEmitNfce	:= LjEmitNFCe() // Sinaliza se utiliza NFC-e

If lFiscal .AND. !lEmitNfce
	//Cancela um eventual cupom aberto
	Lj7Canc()
	
	//Tratamento para queda de energia, a venda finalizou no ECF mas não no Protheus
	If ExistFunc("LjVldUlVnd")
		LjVldUlVnd()
	EndIf
EndIF

//Recuperação de venda Pendente
If !lEmitNfce .And. !LjLogOrc()

	//Procura os arquivo de recuperacao
	aDirect := Directory( LOG_DIR + "RC??????." + cCaixa )

	If len(aDirect) > 0
		
		cLjArq	:= aDirect[1][1]
		
		cNumOrc := substr(cLjArq, 3, 6)
		
		//Chama rotina que armazena os dados para que na proxima venda assistida sejam recuperados os dados.
		LjReLogT( cNumOrc )
	EndIf
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LjExcluRes    ºAutor  ³Geronimo B. Alves   º Data ³  27/06/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao para cancelamento das reservas de orcamento que não     º±±
±±º          ³ serah recuperado.                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpC1: Numero do orcamento que tera suas reservas canceladas   º±±
±±º          ³ ExpA2: Array que conterah os itens do orcamento                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SigaLoja                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function LjExcluRes(cOrc, aColsRec)

Local aArea				:= GetArea()		// Area atual do sistema
Local nPosReserva		:= Ascan(aHeaderDet,{|x| Alltrim(Upper(x[2])) == "LR_RESERVA"})	// Posicao da reserva
Local nLinaColsRec		:= 0				// Contador do FOR que le o aColsRec
Local nLinaNumReserva	:= 0				// Contador do FOR que le o aNumReserva
Local aNumReserva		:= {}				// Armazeno numeros de reservas a serem excluidas
Local aReserva			:= {}				// Dados das reservas que serao canceladas (na tabela SC0)
Local nLen_aHeaderDet	:= Len(aHeaderDet)	// Tamanho do array aHeaderDet
Local aLJ_Codigo		:= {}				// Contem o Codigo da Loja no SLJ e o codigo da filial correspondente

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Leio o acols do orcamento que nao sera recuperado e armazeno os numeros de reservas a serem excluidas  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nLinaColsRec := 1 to len(aColsRec)
	If Len( aColsRec[ nLinaColsRec,1 ] ) == nLen_aHeaderDet + 1					// Nao leio os registros do produto. somente os dos detalhes do produto
		If ! empty(aColsRec[ nLinaColsRec, 1, nPosReserva ] )					// Se registro tem numero de reserva
			If Ascan(aNumReserva, aColsRec[nLinaColsRec, 1, nPosReserva] ) = 0	// E não foi armazenada ainda na array
				aadd( aNumReserva ,	aColsRec[nLinaColsRec, 1, nPosReserva ]  )	// Armazeno numero da reserva para processamento
			EndIf
		EndIf
	EndIf
Next nLinaColsRec

DbSelectArea("SLJ")		// Identificacao de Lojas
dbSetOrder(1)
DbSeek( xFilial( "SLJ" ) )
While ! eof() .AND. SLJ->LJ_FILIAL = xFilial( "SLJ" )
	Aadd( aLJ_Codigo , { SLJ->LJ_CODIGO , SLJ->LJ_RPCFIL } )
	Dbskip()
Enddo

DbSelectArea("SC0")		// Tabela de reservas
dbSetOrder(1)

For nLinaNumReserva := 1 to len(aNumReserva)
	dbSeek( xFilial("SC0") + aNumReserva[ nLinaNumReserva] )
	While !Eof() .AND. xFilial("SC0") == SC0->C0_FILIAL .AND. SC0->C0_NUM == aNumReserva[ nLinaNumReserva ]
		If SC0->C0_TIPO == "LJ"
			nPosLJ_Codigo := Ascan( aLJ_Codigo , {|x| x[2] == SC0->C0_FILRES })
			If nPosLJ_Codigo > 0
				IF Empty( SC0->C0_NUMLOTE )								// Não Controla o lote do produto
					aAdd(aReserva, {SC0->C0_NUM,;
									aLJ_Codigo[ nPosLJ_Codigo, 1 ],;	//Codigo da Loja no SLJ
									SC0->C0_PRODUTO ,;
									SC0->C0_LOCAL } )
				Else
					aAdd(aReserva, {SC0->C0_NUM,;
									aLJ_Codigo[ nPosLJ_Codigo, 1 ],;	//Codigo da Loja no SLJ
									SC0->C0_PRODUTO ,;
									SC0->C0_LOCAL ,;
									SC0->C0_NUMLOTE ,;
									SC0->C0_LOTECTL ,;
									SC0->C0_LOCALIZ ,;
									SC0->C0_NUMSERI } )
				EndIf
			EndIf
		EndIf
		Dbskip()
	End
Next nLinaNumReserva
							
If len(aReserva) > 0							// Se existe reservas, 
	LjCancRes( aReserva )			// Cancelo as reservas do orcamento que nao foi recuperado
EndIf

RestArea(aArea) 
Return    

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³LjxLog_Tef  ³ Autor³ Vendas Clientes       ³ Data³04/09/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Chama a Funcao GetPvProfString,GetClientDir somente uma vez³±±
±±³Descri‡„o ³ E Carrega a Variavel Log_tef.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGAFRT                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/ 
Static Function LjxLog_Tef()
Local cLogTef  := ""      // Recebe o path do log

If cGetCliDir == NIL
	cGetCliDir := GetClientDir()
EndIf 
If cProfStr1 == NIL
   cProfStr1   := GetPvProfString( "Logs TEF","Habilita","01",cGetCliDir + "SIGALOJA.INI" )
EndIF
If File (cGetCliDir + "SIGALOJA.INI") .AND. cProfStr1 == "01"
	cLogTef    := "\AUTOCOM\TEF" + cEmpAnt + StrTran(Alltrim(cFilAnt)," ","") + "\"
EndIf                         
Return cLogTef 


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	  ³ LJAltLogR    ³ Autor³ Vendas Clientes    ³ Data³21/03/2013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Altera Log de Recuperacao								  ³±±
±±³Descri‡„o ³ 															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ SIGALOJA                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function LJAltLogR(cOrc, aColsAux, nPosAux )
Local lRet    := .T.
Local lAchou  := .F.
Local cLJArq  := ""
Local cLine   := ""
Local nHandle := 0
Local nPos    := 0
Local nSize   := 0
Local cItem   := aColsAux[nPosAux][Ascan(aHeaderDet,{|x| Alltrim(Upper(x[2])) == "LR_ITEM"})] //Número do item
Local cCaixa	:= xNumCaixa() 
Local lLock		:= .T.

cLJArq  := "RC" + cOrc + "." + cCaixa

If File( LOG_DIR + cLJArq )

	nHandle := FT_FUse( LOG_DIR + cLJArq ) //Abre o arquivo
	
	If nHandle <> -1

		FT_FGoTop()	
		
		While !FT_FEOF()
			
			cLine  := FT_FReadLn()
			
			If "LR_ITEM   |C|" + AllTrim(cItem) $ cLine
				lAchou := .T.
				nPos   := FT_FRecno()-1
				Exit
			EndIf
	
			FT_FSKIP()	  
	
		End
	
		FT_FUSE() //Fecha arquivo aberto
	
	EndIf
	
	//Se achou, abre o arquivo novamente como edição
	If lAchou .And. (nHandle := FOpen( LOG_DIR + cLJArq, FO_WRITE )) <> -1 .AND. ( lLock := LockByName(cLJArq,.T.,.T.) )  
		
		nSize := Fseek( nHandle, 0, 2 )
		
		Fseek(	nHandle, nPos, 0 ) 
		
		While nPos <= nSize 
			
			cLine := Space(1)
			
			Fseek( nHandle, nPos, 0 )
			
			//Le a letra posicionada para psoterior utilização
			Fread( nHandle, @cLine, 1 )				
			
			//Retorna para a posição antes da leitura
			Fseek( nHandle, nPos, 0 )
			
			//Sobreescreve 
			FWrite( nHandle, " ", 1)
			
			If cLine == "@" //'@' fim do item
				Exit
			EndIf
			
			nPos++
		End
		
		FClose( nHandle )
		UnLockByName(cLJArq,.T.,.T.) 	//Faz desbloqueio do acesso exclusivo
	
	EndIf
	
	If nHandle == -1 .OR. (!lLock)
		MsgAlert( STR0001, cLJArq )	// "Nao foi possivel abrir arquivo de Log."
		UnLockByName(cLJArq,.T.,.T.) 	//Faz desbloqueio do acesso exclusivo
		lRet := .F.	
	EndIf

EndIf

If lRet
	lRet := LjGrLogR( cOrc, aColsAux, nPosAux ) //Inclui o registro no arquivo
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³LjAjuRestOrcºAutor  ³ Vendas Cliente  º Data ³ 05/Abr/2013 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Renomeia o arquivo de log para a numeração atual do orca-  º±±
±±º          ³ mento para que o mesmo possa ser restaurado.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ ExpL1 - Numero do orçamento atual                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Logico -  .T.(Renomeou) ;   .F.(Nao Renomeou)              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ LOJA701                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LjAjuRestOrc( cOrcAtual )
Local lRet		:= .T.
Local nI		:= 0
Local aDirect	:= {}
Local lLog		:= SuperGetMv("MV_LJRECIT",,.F.) .And. Subs(LJGetProfile("LOGERRO"),4,1)=="S"

If lLog .And. !File( LOG_DIR + "RC" + cOrcAtual + "." + xNumCaixa() )
	
	aDirect := DIRECTORY( LOG_DIR + "RC*" + "." + xNumCaixa() )
	
	If Len(aDirect) > 0

 		//Ordena por ultima data e hora
		aSort( aDirect,,, { |x,y| dToS(x[3])+x[4] > dToS(y[3])+y[4] } )
 		
		FRename( LOG_DIR + aDirect[1][1] , LOG_DIR + "RC" + cOrcAtual + "." + xNumCaixa() )
		
		//Caso possua mais de um log para o caixa, estes demais logs serão excluidos.
		If Len(aDirect) > 1
			For nI := 2 To Len(aDirect)
				FErase( LOG_DIR + aDirect[nI][1] )
			Next 
		EndIf

	EndIf

EndIf

Return lRet   

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Fun‡„o    ³ LjGrLogD  ³ Autor ³ Fabiana Cristina     ³ Data ³ 22/10/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava Arquivo de Log de Orcamento.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ LOJA010C / LOJA220C                                        ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function LjGrLogD(cAlias, aArray)
Local cOldAlias 	:= Alias()        //Alias anterior
Local lRet	    	:= .T.            //Retorno da rotina
Local nX        	:= 0              //Variavel contadora
Local aCamposAlt 	:= {}           //Campos a serem editados                                                                                                                                  '
Local nPosFil  		:= 0             //Posicao do campo filial
Local nPosNum 		:= 0             //Posicao do l1_num
Local nPosItem		:= 0             //Posicao do item
Local cSitua 		:= ""            //situacao
Local nCamposAlt 	:= 0			 //Campos a serem editados
Local cSitTrib		:= ""              //Situação Tributária
Local lHomolPaf		:= LjHomolPaf() 	//PAF Homologação?
Local nPos			:= 0                  //Posicao
Local lAchou		:= .F.  
Local lGrava		:= .T.              
Local nC			:= 0                  //Variavel contadora
Local cCampo		:= ""                 //Campo
Local xAux			:= ""
Local nPosDel		:= 0                  //Excluído

Default cAlias		:= ""
Default aArray 	:= {}  

/*
cSitua :
E- excluir
A- Alterar
I- Incluir
*/
If cAlias == "SL2"
	
	aCamposAlt := { "_PRODUTO",;
				  	"_DESCRI", ;
				  	"_QUANT", ;
				  	"_UM", ;
				  	"_DESC", ;
				  	"_SITTRIB",;  
				  	"_PRCTAB",;
				  	"_TES"} 	
	
	nCamposAlt := Len(aCamposAlt)
	
	lAchou := .F.
	nPosFil := aScan(aArray , {|l| l[1] == "L2_FILIAL"})
	nPosNum := aScan(aArray , {|l| l[1] == "L2_NUM"})
	nPosItem := aScan(aArray , {|l| l[1] == "L2_ITEM"})   

	If nPosFil > 0 .AND. nPosNum > 0 .AND. nPosItem > 0 
   		
       	nPosDel := aScan(aArray , {|l| l[1] == REG_DELETED})
	
		If nPosDel > 0 .AND. aArray[nPosDel, 2] // Registro Deletado == REG_DELETED
			cSitua := "E"	
		Else                    
            cSitua := "I"
        EndIf
      
		cCampo := Right(cAlias,2)+"_SITTRIB"
		nX := aScan(aArray, { |l| l[1] == cCampo }) 
		If nX > 0 .And. Empty(AllTrim(aArray[nX, 2])) .And. lHomolPaf
			cSitTrib := STBFMSitTrib( aArray[aScan(aArray , {|l| l[1] == "L2_PRODUTO"}),2],"","",.T.)
		
			If !Empty(cSitTrib)
				cSitTrib := StrTran(cSitTrib,",")
				cSitTrib := StrTran(cSitTrib,".")						
			EndIf
			aArray[nX, 2] := cSitTrib
		EndIf  
	
		DbSelectArea("MFT")
		
		/*Faço a pesquisa se foi gerado Log pois se o item fora excluido devo alterar a linha da MFT*/		
		MFT->(DbSetOrder(1)) //MFT_FILIAL, MFT_NUM, MFT_ITEM, MFT_PRODUT, MFT_ALTERA, MFT_HRALT
		lAchou := MFT->(DbSeek(xFilial("MFT")+ PadR(aArray[ nPosNum, 2],TAMSX3("MFT_NUM")[1]) + aArray[ nPosItem, 2]))
		
		//Se o registro existir e não for deleção, seto Alteração
		If lAchou .And. cSitua == "I"
			cSitua := "A"
			
			//Valida se registro realmente foi alterado ( Campos com nome diferentes )
			If	MFT->MFT_VALDES <> aArray[aScan(aArray, { |l| l[1] == Left("L2_VALDESC",10) } ),2] .Or. ;
				MFT->MFT_VLRITE <> aArray[aScan(aArray, { |l| l[1] == Left("L2_VLRITEM",10) } ),2]
				lGrava := .T.
			Else
				lGrava := .F.
			EndIf
			
			//Pesquisa nos arrays se teve alguma alteração: Grid X Tabela ( Campos com nomes iguais )
			If !lGrava
				For nX := 1 to Len(aCamposAlt)
					cCampo	:= Right(cAlias,2)+aCamposAlt[nX]
					nPos	:= aScan(aArray, { |l| l[1] == cCampo })
					
					cCampo := Left("MFT"+aCamposAlt[nX],10)
					If MFT->(&(cCampo)) <> aArray[nPos,2]
						lGrava := .T.
					EndIf
				Next nX
			EndIf
		Else
			lGrava := .T.
		EndIf
		
		If lGrava
			RecLock("MFT", !lAchou)
			REPLACE MFT->MFT_FILIAL WITH  xFilial("MFT") 
			REPLACE MFT->MFT_NUM 	WITH  aArray[ nPosNum, 2]
			REPLACE MFT->MFT_ITEM 	WITH  aArray[ nPosItem, 2]
			REPLACE MFT->MFT_ALTERA WITH  Date()
			REPLACE MFT->MFT_HRALT 	WITH  Time()
			REPLACE MFT->MFT_SITUA	WITH  cSitua
			REPLACE MFT->MFT_VENDID	WITH  IIF(cSitua == "E","N","S")
			
			nPos   := aScan(aArray, { |l| l[1] == Left("L2_VALDESC",10) } )
			If nPos > 0
				xAux := aArray[ nPos, 2]
			Else
				xAux := 0
			EndIf
			REPLACE MFT->MFT_VALDES WITH xAux
			
			nPos   := aScan(aArray, { |l| l[1] == Left("L2_VLRITEM",10) } )
			If nPos > 0
				xAux := aArray[ nPos, 2]
			Else
				xAux := 0
			EndIf
			REPLACE MFT->MFT_VLRITE WITH xAux
						
			For nC := 1 to nCamposAlt
				cCampo := Left(Right(cAlias,2)+aCamposAlt[nC],10)
				nPos   := aScan(aArray, { |l| l[1] == cCampo } )
				
				If nPos > 0
			        cCampo := Left("MFT"+aCamposAlt[nC],10)
					REPLACE MFT->(&(cCampo)) WITH aArray[ nPos, 2]
			    EndIf
			Next nC
			
			If MFT->(ColumnPos("MFT_DECQTD")) > 0
				REPLACE MFT->MFT_DECVLU	WITH  TamSX3("L2_VRUNIT")[2]
				REPLACE MFT->MFT_DECQTD	WITH  TamSX3("L2_QUANT")[2]
				REPLACE MFT->MFT_DOC	WITH  aArray[ nPosNum, 2]
			EndIf
			
			MFT->(MsUnLock())
			
			RecLock("MFT",.F.)
			REPLACE MFT->MFT_PAFMD5 WITH STxPafMd5("MFT")
			MFT->(MsUnlock())
		EndIf
	EndIf
EndIf
	
DbSelectArea(cOldAlias)

Return lRet

//--------------------------------------------------------
/*/{Protheus.doc} LjNFCeUltV()
Verifica se a ultima venda deste PDV ficou com processamento pendente 
devido queda do sistema.

@type	 function
@author  Varejo
@version P11.8
@since   25/07/2016
@return	 Nil
/*/
//-------------------------------------------------------- 
Function LjNFCeUltV()

Local aAreaSL1 		:= SL1->( GetArea() )
Local nRecnoSL1 	:= 0
Local cPDV 			:= PadR(LjGetStation("LG_PDV"),TamSX3("L1_PDV")[1])
Local cModDoc 		:= "" 			// Codigo do modelo do documento eletronico (55=NF-e, 65=NFC-e)
Local lInutiliza	:= .F.			// Indica se o documento deve ser inutilizado
Local lAutorizado	:= .F. 			// Indica que a venda será integrada mas devido a falha na impressão e o prazo de cancelamento expirado ela deve ser encaminhada para devolução.
Local aRetCanc		:= {.F.,.F.}	// Retorno da função LJCancOnLine
Local nOpcao		:= 1			// Opção a ser executada para a recuperação da venda
Local cFilNum       := ""
Local lProcSL1      := .F.

// Validação para o Cancelamento OnLine
Local lLOJGNFCE		:= IIf(ExistFunc("LOJGNFCE")	,GetApoInfo("LOJGNFCE.PRW")[4] 	>= CtoD("02/08/2019"),.F.)	// Verifica a existência do fonte LOJGNFCE.PRW
Local lLOJA140		:= IIf(ExistFunc("LJ140CCANC")	,GetApoInfo("LOJA140.PRX")[4] 	>= CtoD("05/04/2019"),.F.)	// Verifica a existência da função LJ140CCANC
Local lLOJCNFCE		:= IIf(ExistFunc("LOJCNFCE"),.T.,.F.) 														// Verifica a existência do fonte LOJCNFCE.PRW
Local lLOJXNFCE		:= IIf(ExistFunc("LOJXNFCE"),.T.,.F.)														// Verifica a existência do fonte LOJCNFCE.PRW
Local lCancOnline	:= IIF(lLOJGNFCE .AND. lLOJA140 .AND. lLOJCNFCE .AND. lLOJXNFCE , .T. , .F. )				// Valida se é possível utilizar o Cancelamento OnLine
Local nRetTEF		:= 0																						// Guarda o retorno da ação TEf que foi tomada na entrada do sistema
Local cMsgConf 		:= ""																						// Mensagem de CONFIRMAÇÃO
Local cMsgCanc		:= ""																						// Mensagem de CANCELAMENTO
Local cMsgCncTef	:= ""																						// Mensagem de CANCELAMENTO TEF
Local cMsgPend		:= ""																						// Mensagem de PENDENCIA
Local lAutoExA		:= IsBlind()																				// Verifica se a rotina sera executada via execauto ou nao
Local aPagDigPix	:= {}																						// Dados do pagamento Digital PIX/PD
Local lCancTrnTD	:= .T. 																						// Indica o status do cancelamento da transação de Pagamento Digital PX/PD

LjGrvLog( "LjNFCeUltV ", "Fontes referente ao Cancelamento OnLine?", lCancOnline )

/*
STATUS:
T1=Gravado o orcamento (antes de pegar o numero do DOC)
T2=Consumiu numero de Doc e Serie e atualizou os campos L1_DOC e L1_SERIE
T3=Processou a NFC-e (TSS)
*/

// Mensagem de CANCELAMENTO Nota e transação TEF
cMsgCanc	:= 	STR0075 	+ CRLF +;	// "Devido ter ocorrido algum problema na última venda, a transação TEF(com cartão) foi CANCELADA!"
				""			+ CRLF +;
				STR0077 				// "A Nota Fiscal, será CANCELADA e a tela de venda será aberta para finalizar a venda novamente!"

// Mensagem de CONFIRMAÇÃO
cMsgConf 	:=	STR0081		+ CRLF +;	// "Nesta venda, uma transação TEF foi CONFIRMADA!"
				STR0082					// "A venda será finalizada e impressa a Nota Fiscal!"

// Mensagem de CONFIRMAÇÃO TEF
cMsgCnfTef 	:=	STR0081		+ CRLF +;	// "Nesta venda, uma transação TEF foi CONFIRMADA!"
				""			+ CRLF +;
				STR0085		+ CRLF +;	// "A venda será RECUPERADA, mas não será possível FINALIZAR, pois a transação TEF(CARTÃO) já foi CONFIRMADA!"
				""			+ CRLF +;				
				STR0086					// "INFORME O DEPARTAMENTO DE TI."				

// Mensagem de CANCELAMENTO Nota e transação TEF
cMsgCncTef	:= 	STR0075 				// "Devido ter ocorrido algum problema na última venda, a transação TEF(com cartão) foi CANCELADA!"

// Mensagem de PENDENCIA
cMsgPend	:= 	STR0083 	+ CRLF +;	// "Esta venda esta a com transação TEF(CARTÂO) PENDENTE!!!"
				""			+ CRLF +;			
				STR0077 				// "A Nota Fiscal, será CANCELADA e a tela de venda será aberta para finalizar a venda novamente!"

//Posiciona na ultima venda do PDV em questao
SL1->(DbSetOrder(9)) //L1_FILIAL+L1_SITUA+L1_PDV+L1_DOC
If SL1->(DbSeek(xFilial("SL1")+"T2")) .Or. SL1->(DbSeek(xFilial("SL1")+"T3")) //Busca por SITUA T2 ou T3 (Transacao ficou pendente em algum ponto)
	While SL1->( !EoF() ) .And. SL1->L1_FILIAL+Left(SL1->L1_SITUA,1) == xFilial("SL1") + "T"

		cFilNum := SL1->L1_FILIAL + "\" + SL1->L1_NUM
		LjGrvLog(cFilNum, "Analisando vendas com situação pendente.", SL1->L1_SITUA)

		If ( AllTrim(SL1->L1_ESTACAO) == AllTrim(cEstacao) .And. ( SL1->L1_PDV == cPDV .Or. Empty(SL1->L1_PDV) ) .And.;
			!Empty(SL1->L1_DOC) .And. !Empty(SL1->L1_SERIE) .And. Empty(SL1->L1_SERSAT) ) //Nao permite continuar se for venda de SAT

			//Tentar criar semaforo para não recuperada uma venda que esta em processo de finalização
			lProcSL1 := Lj7XSL1("C")
			LjGrvLog(cFilNum, "Venda será processada\cancelada ? (Lj7XSL1)", lProcSL1)

			If lProcSL1
			
				/*
				Verifica se a venda foi realizada da seguinte forma:
				- Cartão Crédito ou Débito;
				- Via SITEF;
				- lMV_LJCFTEF := SuperGetMV("MV_LJCFTEF",,.T.)	// Define se as transacoes TEF pendentes serao Confirmadas ou Canceladas
				- cMVLJTEFPD  := LjTEFPend() 					// Verifica se as transacoes TEF pendentes serao "1=Confirmadas", "2=Canceladas" ou "3=Permanecem Pendentes"
				*/

				// Verifica se é uma transação TEF e se a mesma, foi Confirmada/Cancelada/Pendente na entrada do sistema
				nRetTEF := Lj7TemCart(SL1->L1_NUM)				

				// Verifica se a venda ja foi transmitida e autorizada pela SEFAZ
				If SL1->L1_SITUA == "T3" .AND. !Empty(SL1->L1_KEYNFCE) .AND. Empty(SL1->L1_ORCRES)

					lAutorizado := .T.
					
					Do Case

						//Transação TEF CONFIRMADA na entrada do sistema
						Case nRetTEF == 1       
							If lAutoExA
								Conout( "LOJXLOG - Nesta venda, uma transação TEF foi CONFIRMADA!")				
								Conout( "LOJXLOG - A venda será finalizada e impressa a Nota Fiscal!")	
							Else
								// Aqui confirma venda, porque já existe o SL1->L1_KEYNFCE 
								MsgAlert(cMsgConf, STR0018 +  "!!!")
								Lj7ConfNF()	
							EndIf	
		
						//Transação TEF CANCELADA na entrada do sistema
						Case nRetTEF == 2
							If lAutoExA
								Conout( "LOJXLOG - Devido ter ocorrido algum problema na última venda, a transação TEF(com cartão) foi CANCELADA!")
								Conout( "LOJXLOG - A Nota Fiscal, será CANCELADA e a tela de venda será aberta para finalizar a venda novamente!")						
							Else	
								MsgAlert(cMsgCanc, STR0018  + "!!!")
								lInutiliza 	:= .T.
							EndIf	
	
						//Transação TEF PENDENTE na entrada do sistema
						Case nRetTEF == 3
							If lAutoExA
								Conout( "LOJXLOG - Esta venda esta a com transação TEF(CARTÂO) PENDENTE!!!")
								Conout( "LOJXLOG - A Nota Fiscal, será CANCELADA e a tela de venda será aberta para finalizar a venda novamente!")
							Else
								MsgAlert(cMsgPend, STR0018 + "!!!")				
								lInutiliza 	:= .T.
							EndIf
	
						//Transação TEF CANCELADA na entrada do sistema
						Case nRetTEF == 4
							If lAutoExA
								Conout( "LOJXLOG - Devido ter ocorrido algum problema na última venda, a transação TEF(com cartão) foi CANCELADA!")
								Conout( "LOJXLOG - A Nota Fiscal, será CANCELADA e a tela de venda será aberta para finalizar a venda novamente!")
							Else
								MsgAlert(cMsgCanc, STR0018  + "!!!")
								lInutiliza 	:= .T.
							EndIf

						//Usuario define se venda será confirmada ou cancelada dependendo da configuração do parâmetro MV_LJCREVD
						OTherWise 
							lInutiliza := DefConCanV(cFilNum)
							
					End Case
					
				ElseIf SL1->L1_SITUA == "T2" .AND. Empty(SL1->L1_KEYNFCE) .AND. Empty(SL1->L1_ORCRES)
	
					Do Case

						//Transação TEF CONFIRMADA na entrada do sistema
						Case nRetTEF == 1
							If lAutoExA
								Conout( "LOJXLOG - Nesta venda, uma transação TEF foi CONFIRMADA!")
								Conout( "LOJXLOG - A venda será RECUPERADA, mas não será possível FINALIZAR, pois a transação TEF(CARTÃO) já foi CONFIRMADA!")
								Conout( "LOJXLOG - INFORME O DEPARTAMENTO DE TI.")
							Else
								// Aqui não confirma venda, porque não existe o SL1->L1_KEYNFCE 					
								MsgAlert(cMsgCnfTef, STR0018  + "!!!")
								lInutiliza 	:= .T.
							EndIf
	
						//Transação TEF CANCELADA na entrada do sistema
						Case nRetTEF == 2
							If lAutoExA
								Conout( "LOJXLOG - Devido ter ocorrido algum problema na última venda, a transação TEF(com cartão) foi CANCELADA!")				
							Else	
								MsgAlert(cMsgCncTef, STR0018  + "!!!")
								lInutiliza 	:= .T.
							EndIf
	
						//Transação TEF PENDENTE na entrada do sistema
						Case nRetTEF == 3
							If lAutoExA
								Conout( "LOJXLOG - Esta venda esta a com transação TEF(CARTÂO) PENDENTE!!!")
								Conout( "LOJXLOG - A Nota Fiscal, será CANCELADA e a tela de venda será aberta para finalizar a venda novamente!")
							Else				
								MsgAlert(cMsgPend, STR0018 + "!!!")				
								lInutiliza 	:= .T.
							EndIf
	
						//Transação TEF CANCELADA na entrada do sistema
						Case nRetTEF == 4
							If lAutoExA
								Conout( "LOJXLOG - Devido ter ocorrido algum problema na última venda, a transação TEF(com cartão) foi CANCELADA!")				
							Else					
								MsgAlert(cMsgCncTef, STR0018  + "!!!")
								lInutiliza 	:= .T.
							EndIf

						OTherWise

							lInutiliza 	:= .T.
							LjGrvLog("Processamento de orçamento","Venda encaminhada para cancelamento/inutilização (SLX). " + SL1->(L1_DOC+L1_SERIE) )									
					End Case
					
				Else

					lInutiliza 	:= .T.
					LjGrvLog(cFilNum, "Venda encaminhada para cancelamento/inutilização.", SL1->L1_SITUA)
				EndIf

				nRecnoSL1 := SL1->( Recno() )
				Exit
			EndIf
		EndIf
		
		SL1->(DbSkip())
	End
EndIf

If lProcSL1 .And. nRecnoSL1 > 0 

	RestArea(aAreaSL1)          //Reposiciona na area anterior, para manter o indice padrao que eh iniciado no Browse	
	SL1->( DbGoTo(nRecnoSL1) )  //Posiciona no Registro da venda

    //Finaliza o semaforo criado para bloqueio de edição da venda
    Lj7XSL1("D")
EndIf

If lInutiliza
	
	If !SL1->L1_IMPNF
		cModDoc := "65"
	Else
		cModDoc := "55"
	EndIf

	If  lAutorizado .AND. cModDoc == "65" .AND. lCancOnline

		// Cancela transacao Digital PX/PD
		If ExistFunc("LjPDGtPGrv") .And. ExistFunc("LjPDCanTrn")
			aPagDigPix	:= LjPDGtPGrv(SL1->L1_NUM, .T.)

			If Len(aPagDigPix) > 0 .And. !LjPDCanTrn(@aPagDigPix)
				//Se o cancelamento de Pagamento Digital não teve sucesso, não permite prosseguir com o cancelamento da venda
				Help( " ", 1, "TOTVSTDP", ,STR0089, 1, 0 ) // "Operação de cancelamento de Pagamento Digital/PIX não realizada, portanto a venda não poderá ser cancelada."
				lCancTrnTD := .F.
				aRetCanc[01] := .F. 
				aRetCanc[02] := .T.
			EndIf
		EndIf

		If lCancTrnTD
			aRetCanc := LJCancOnLine( nRecnoSL1, cModDoc )		
		EndIf
		
		/*
		// Possíveis retornos da LJCancOnLine
		// 01 - aRetCanc{.T.,.F.} -> Cancelamento realizado, abre tela para continuar venda
		// 02 - aRetCanc{.F.,.T.} -> Cancelamento não realizado - Rejeição - Grava a venda para Devolução
		// 03 - aRetCanc{.F.,.F.} -> Cancelamento não realizado - Falta de comunicação ou de Retorno da SEFAX - Envia para SLX
		*/
	
		If aRetCanc[1]
			nOpcao := 1
		ElseIf !aRetCanc[1] .AND. aRetCanc[2]
			nOpcao := 2
		ElseIf !aRetCanc[1] .AND. !aRetCanc[2]	
			nOpcao := 3
		EndIf		

	EndIf

	Do Case

		Case nOpcao == 1			

			// Cancelamento realizado, recupera o orçamento e abre a tela para continuar venda		

			If Empty(SL1->L1_ORCRES)
				LjGrvLog( "LjNFCeUltV - NumOrc: " + SL1->L1_NUM,  " Venda com reserva, enviado para cancelamento via JOB na SLX, orçamento recuperado na tela para continuar venda.", )
			Else
				LjGrvLog( "LjNFCeUltV - NumOrc: " + SL1->L1_NUM,  "Cancelamento realizado, orçamento recuperado na tela para continuar venda.", )
			EndIf
			
			If !aRetCanc[1] // Se já cancelou online não envia para a SLX
				//Inclui o DOCUMENTO na SLX para ser inutilizado
				Lj7SLXDocE(cModDoc, SL1->L1_DOC, SL1->L1_SERIE, SL1->L1_PDV, SL1->L1_OPERADO, Nil)
			EndIf
			
			//Limpa os campos para poder finalizar a venda novamente
			RecLock("SL1",.F.)
			SL1->L1_DOC		:= ""
			SL1->L1_SERIE	:= ""
			SL1->L1_KEYNFCE	:= ""
			SL1->L1_SITUA	:= ""
			SL1->( MsUnLock() )

			If !Empty(SL1->L1_FILRES) .And. !Empty(SL1->L1_ORCRES) //Se for reserva.				
				DbSelectArea("SL1")
				DbSetOrder(1)//L1_FILIAL+L1_NUM
				SL1->(DbSeek( SL1->L1_FILRES + SL1->L1_ORCRES)) //Posiciona no registro Pai para finalizar novamente
				LjGrvLog("","Venda com reserva posiciona na venda Pai. " + SL1->L1_FILRES + SL1->L1_ORCRES)
			Else
				LjGrvLog("","Venda sem reserva. " + SL1->L1_FILRES + SL1->L1_ORCRES)
			EndIf

			// Limpa dados da transação
			DbSelectArea("SL4")
			SL4->(DbSetOrder(1)) // L4_FILIAL+L4_NUM+L4_ORIGEM
			SL4->(DbSeek( xFilial("SL4") + SL1->L1_NUM))
			While SL4->(!EOF()) .AND. SL4->L4_FILIAL + SL4->L4_NUM == xFilial("SL4") + SL1->L1_NUM 
				RecLock("SL4",.F.)
				SL4->L4_DATATEF	:= ""
				SL4->L4_HORATEF	:= ""
				SL4->L4_DOCTEF	:= ""
				SL4->L4_AUTORIZ	:= ""
				SL4->L4_NSUTEF	:= ""
				SL4->L4_NOMECLI	:= ""
				SL4->L4_FORMAID	:= ""
				SL4->L4_BANDEIR := ""
				SL4->L4_TRNID	:= ""
				SL4->L4_TRNPCID	:= ""
				SL4->L4_TRNEXID	:= ""
				SL4->( MsUnLock() )

				SL4->(dbSkip())
			EndDo	
			
			MsgAlert(STR0058 + SL1->L1_NUM + STR0059 ) // "O sistema recuperou a venda (orcamento " "). Será aberta a tela para finalização."
			
			//Seta as variaveis Privates para iniciar a rotina para finalizacao da venda
			INCLUI := .F.
			ALTERA := .T.
			
			//Chama a tela da Venda Assistida para finalizar a venda.
			Lj7Venda("SL1", SL1->(Recno()), 4)

		Case nOpcao == 2
			// Cancelamento não realizado - Rejeição - Grava a venda para Devolução	

			LjGrvLog( "LjNFCeUltV - NumOrc: " + SL1->L1_NUM,  "Cancelamento não realizado - Rejeição SEFAZ -  Grava a venda para Devolução", SL1->(L1_SERIE+L1_DOC) )

			LjMsgRun(STR0072 + SL1->(L1_SERIE+L1_DOC),, {|| LjGrvTudo(.F.) } ) // "Aguarde, gravando documento: "
			
			RecLock("SL1",.F.)
			SL1->L1_SITUA := "OK"
			SL1->( MsUnLock() )
			
			If lCancTrnTD
				Help( " ", 1, "Cancelamento", ,;
						STR0060	+ CRLF +;
						STR0061		+ CRLF +;
						STR0062	+ AllTrim(SL1->L1_DOC) + CHR(10) +;
						STR0063	+ AllTrim(SL1->L1_SERIE), 1, 0 ) // "Documento fora do prazo previsto para cancelamento, por essa razão a gravação da venda foi realizada." "Verifique a necessidade de realizar devolução do documento." "Documento:" "Serie"
			Else
				Help( " ", 1, "Cancelamento", ,;
						STR0090	+ CRLF +;
						STR0061		+ CRLF +;
						STR0062	+ AllTrim(SL1->L1_DOC) + CHR(10) +;
						STR0063	+ AllTrim(SL1->L1_SERIE), 1, 0 ) // "Transação do Pagamento digital (PIX/Carteira Digital) não pode ser feita, por esta razão a gravação da venda foi realizada." "Verifique a necessidade de realizar devolução do documento." "Documento:" "Serie"
			EndIf				
		
		Case nOpcao == 3
			// Cancelamento não realizado - Falta de comunicação ou de Retorno da SEFAX - Envia para SLX

			LjGrvLog( "LjNFCeUltV - NumOrc: " + SL1->L1_NUM,  "Cancelamento não realizado - Falta de comunicação ou de Retorno da SEFAZ - Envia para SLX", SL1->(L1_SERIE+L1_DOC) )

			//Inclui o documento na SLX para ser inutilizado
			Lj7SLXDocE(cModDoc, SL1->L1_DOC, SL1->L1_SERIE, SL1->L1_PDV, SL1->L1_OPERADO, Nil)

			//Indica envio para cancelamento
			RecLock("SL1",.F.)
			SL1->L1_DOC		:= ""
			SL1->L1_SERIE	:= ""
			SL1->L1_KEYNFCE	:= ""
			SL1->L1_SITUA 	:= ""
			SL1->( MsUnLock() )

			If !Empty(SL1->L1_FILRES) .And. !Empty(SL1->L1_ORCRES)//Se for reserva.
				DbSelectArea("SL1")
				DbSetOrder(1)//L1_FILIAL+L1_NUM
				SL1->(DbSeek( SL1->L1_FILRES + SL1->L1_ORCRES)) //Posiciona no registro Pai para finalizar novamente
				LjGrvLog("","Venda com reserva posiciona na venda Pai. " + SL1->L1_FILRES + SL1->L1_ORCRES)
			Else
				LjGrvLog("","Venda sem reserva. " + SL1->L1_FILRES + SL1->L1_ORCRES)
			EndIf			

			If lAutoExA
				Conout("A venda foi enviada para cancelamento via Job. Inicie um novo orçamento.")
			Else
				MsgAlert(STR0064) // "A venda foi enviada para cancelamento via Job. Inicie um novo orçamento."
			Endif
		
	EndCase	

Else

	//Busca venda pendente de gerar pedido/financeiro

	SL1->(DbSetOrder(9)) //L1_FILIAL+L1_SITUA+L1_PDV+L1_DOC
	If SL1->(DbSeek( xFilial("SL1")+"P3" )) //P3=Transacao finalizada pendente  pedido/financeiro
		While SL1->( !EoF() ) .And. SL1->L1_FILIAL+SL1->L1_SITUA == xFilial("SL1")+"P3"
		
			If AllTrim(SL1->L1_ESTACAO) == AllTrim(cEstacao) .And. AllTrim(SL1->L1_NSO) $ "P3|P4|P5"

				//Chama a tela da Venda Assistida para finalizar a venda.
				MsgAlert(STR0047 + SL1->L1_NUM + STR0048)////#"O sistema recuperou a venda (orcamento " ##") para ser finalizada corretamente. Será aberta a tela para finalizar esta venda."
											
				//Seta as variaveis Privates para iniciar a rotina para finalizacao da venda
				INCLUI := .F.
				ALTERA := .T.
				Lj7Venda("SL1", SL1->(Recno()), 4)				
				Exit
			
			EndIf			
			SL1->(DbSkip())
			
		End
	EndIf
	
	RestArea(aAreaSL1)		
EndIf

Return

//----------------------------------------------------------
/*/{Protheus.doc} LjSATUltV
Reponsável por efetuar a recuperação de vendas SAT.

@type		function
@author	Varejo
@version	P11.8
@since		08/12/2016
@return	Nil
/*/
//----------------------------------------------------------
Function LjSATUltV()
Local lRecovery		:= .F.
Local aAreaSL1		:= {}
Local cSitua		:= ""
Local cMsg			:= ""
Local lRet			:= .T.
Local lFinaCanc		:= .F.
Local nRecnoSL1 	:= 0
Local cArqSessao	:= GetClientDir() + "sessaosat.txt"
Local cSerRec		:= ""
Local cDocRec		:= ""
Local lVldLivr      := .T.
Local lSatFinCnc	:= .F.

aAreaSL1 := SL1->(GetArea())

cSerRec := PadR(LjGetStation("LG_SERIE"),TamSX3("L1_SERIE")[1])
cDocRec := GetPvProfString("SAT","DOC","",cArqSessao)

/*----------------------------------------------------------------------------------------------------
	Status:
	T1=Gravado o orcamento (antes de pegar o numero do DOC)
	T2/T3=Consumiu numero de Doc e Serie e atualizou os campos L1_DOC e L1_SERIE e processou o SAT
----------------------------------------------------------------------------------------------------*/
SL1->(DbSetOrder(2))		//L1_FILIAL+L1_SERIE+L1_DOC+L1_PDV
If !Empty(cDocRec) .And. SL1->(DbSeek(xFilial("SL1")+cSerRec+cDocRec)) 
	cSitua := AllTrim(SL1->L1_SITUA)	
	nRecnoSL1 := SL1->(Recno())
	If Upper(cSitua) <> "OK"
		lRecovery := .T.
	EndIf
Else
	SL1->(DbSetOrder(9)) 	//L1_FILIAL+L1_SITUA+L1_PDV+L1_DOC
	If SL1->(DbSeek( xFilial("SL1")+"T1" ))  
		cSitua := AllTrim(SL1->L1_SITUA)
		lRecovery := .T.
		nRecnoSL1 := SL1->(Recno())
	EndIf
EndIf

//Valida se houve queda no meio do processo de cancelamento de venda
If !lRecovery
	LjxLPCnSat(@lRecovery,	@lFinaCanc	, @nRecnoSL1)
EndIf	

lRet := LJSATInicia(lRecovery)

If lRecovery
	
	lVldLivr := LjxVlLivr(nRecnoSL1) 
	
	RestArea(aAreaSL1) //Reposiciona na area anterior, para manter o indice padrao que eh iniciado no Browse

	SL1->(DbGoTo(nRecnoSL1)) //Posiciona no Registro da ultima venda

	lSatFinCnc := LjSatFinCnc(.F.)

	If lFinaCanc .And. lSatFinCnc
		
		//" Venda referente ao orçamento #" + XXXXX + " cancelada no Equipamento de SAT está pendente de cancelamento no Protheus " + CHR(13) + " Será realizado o cancelamento dessa venda!"
		cMsg := STR0051 + AllTrim(SL1->L1_NUM) + STR0052 + CHR(13) + STR0053
		MsgAlert(cMsg)
		
		If LJ140Exc( "SL1", SL1->(Recno()),2,,,,,,.T.,,,,.T.)
			cMsg := STR0051 + AllTrim(SL1->L1_NUM) + STR0087 //" Venda referente ao orçamento #" ## " Cancelada !"
			MsgAlert(cMsg)			
			LjGrvLog("SAT", "Recuperacao de cancelamento - " + cMsg)
			
			LjSaCtrCnc(.F.,.T.,.F.,.F.,"") //Apaga o arquivo de sinal de cancelamento
			LjSatFinCnc(.T.) //apaga a sessão
		Else
			cMsg := STR0051 + AllTrim(SL1->L1_NUM) + STR0088  //" Venda referente ao orçamento #" ## " não pode ser cancelada !"
			MsgAlert(cMsg)			
			LjGrvLog("SAT", "Recuperacao de cancelamento não efetuado " + cMsg)
		EndIf
		
	ElseIf cSitua == "T3" .Or. SATValidCanc() //Verifica se chegou a enviar para o SAT ou nao. Se enviou deve cancelar.
		LJSatUltimo(lRecovery)

		//Retorna posição do orçamento novo (cópia)
		If AllTrim(SL1->L1_SITUA) <> "ER"
			cMsg := STR0047 + SL1->L1_NUM + STR0091 //#"O sistema recuperou a venda (orcamento " ##") para ser finalizada corretamente."
			MsgAlert(cMsg)
			LjGrvLog("SAT", "Recuperacao venda - " + cMsg)

			//Seta as variaveis Privates para iniciar a rotina para finalizacao da venda
			INCLUI := .F.
			ALTERA := .T.

			//Chama a tela da Venda Assistida para finalizar a venda.
			Lj7Venda("SL1", SL1->(Recno()), 4)
		Else
			cMsg := STR0049 + SL1->L1_NUM + STR0050 //"Não foi possivel recuperar a venda corretamente (orcamento " ##"). será necessário efetuar manualmente esta operação."

			MsgAlert(cMsg)
			LjGrvLog("SAT", "Recuperacao venda - " + cMsg)
		EndIf
	
	ElseIf cSitua == "OK" .And. !lVldLivr
		cMsg := STR0049 + SL1->L1_NUM + STR0054 //"Não foi possivel recuperar a venda corretamente (orcamento " ##") retenha o Cupom e realize o cancelamento dessa venda."

		MsgStop(cMsg)
		LjGrvLog("SAT", "Recuperacao venda - " + cMsg)

	ElseIf cSitua == "OK" .And. !lSatFinCnc
		cMsg := STR0092 + CHR(10) +; // "Não foi possível recuperar o cancelamento pelo aparelho SAT."
				STR0093 + SL1->L1_DOC + STR0094 + SL1->L1_SERIE + CHR(10) + CHR(13) + ; // "Documento: " ## " Serie: "
		 		STR0095 // "Tente efetuar o cancelamento manualmente pela rotina de Exclusão/Cancelamento de venda."
		
		LjSaCtrCnc(.F.,.T.,.F.,.F.,"") //Apaga o arquivo de sinal de cancelamento caso exista
		MsgStop(cMsg)
		LjGrvLog("SAT", "Recuperacao venda nao efetuado - " + cMsg)

	EndIf

Else
	RestArea(aAreaSL1)
EndIf

Return lRet

//----------------------------------------------------------
/*/{Protheus.doc} LjxLPCnSat
Função para pesquisa de cancelamentos do SAT incompletos

@type		function
@author	Varejo
@version	P11.8
@since		19/04/2017
@return	Nil
/*/
//----------------------------------------------------------
Function LjxLPCnSat(lRecovery,	lFinaCanc	, nRecnoSL1)
Local cSitua	:= ""
Local aRetSitC	:= {}
Local lPDV		:= (nModulo == 23)

Default lRecovery:= .F.
Default	lFinaCanc:= .F.
Default nRecnoSL1:= 0

//Cn=Transacao de cancelamento ficou pendente em algum ponto
aRetSitC:= LjSaTraCtr(LjSaCtrCnc(.F.,.F.,.T.,.F.,""))
cSitua	:= aRetSitC[1]

Do Case 
	Case cSitua $ "C1" .Or. Empty(cSitua)
		LjSaCtrCnc(.F.,.T.,.F.,.F.,"") //Apaga o arquivo de sinal de cancelamento				
	OtherWise
		LjGrvLog("SAT","Localizado Cancelamento não finalizado pendente")
		SL1->(DbSetOrder(8)) //L1_FILIAL + L1_PDV + L1_DOC
		//Venda finalizada no PDV e cancelada mantém o L1_DOC mas grava o L1_SITUA COMO "07" ou L1_STORC como "C" se a venda não subiu
		If SL1->(DbSeek(aRetSitC[2]+aRetSitC[3]+aRetSitC[4])) .AND. !(lPDV .And. ;
																	 (RTrim(SL1->L1_SITUA) == "07" .OR. RTrim(SL1->L1_STORC) == "C" ))
			nRecnoSL1 := SL1->(Recno())
			lRecovery := .T.
			lFinaCanc := .T.
			LjGrvLog("SAT","SL1 posicionado - L1_NUM [" + SL1->L1_NUM +"]")
		EndIf
EndCase

Return aRetSitC

//---------------------------------------------------------------------------
/*/
{Protheus.Doc} LjLogItCC
Log de Geração de Registro para a venda concomitante
@author  Varejo
@version 	P12
@since   	03/08/2017
@return  	lRet , Boolean , Retorno
/*/
//---------------------------------------------------------------------------
Function LjLogItCC(lCancItem)
Local lRet      	:= .T.       			// Variavel de retorno
Local aArea     	:= GetArea()			// Array contendo informações da area
Local cSerie   	 	:= ""					// Variavel contendo a serie
Local cCupom    	:= ""					// Variavel contendo o numero do cupom 
Local cPDV      	:= ""					// Variavel contendo o numro do pdv
Local cCaixa    	:= ""					// Variavel contendo o numero do caixa
Local cContDoc		:= ""
Local cSupervisor	:= ""
Local cSitTrib		:= ""
Local cIndSLX		:= ""
Local nRetCupom		:= 0
Local nTamDoc		:= 0
Local nTamL1PDV		:= TamSx3("L1_PDV")[1]                           // Tamanho do campo L1_PDV
Local nPosItem		:= 0											 // Posicao do item
Local nPosVlrItem   := 0											 // Posicao do valor do produto
Local nPosProduto	:= 0                                             // Posicao da descrição do produto
Local nPosQtde		:= 0                                             // Posicao da quantidade
Local nPosVlrUni   	:= 0											 // Posicao do valor unitario do produto
Local nX			:= 0
Local nTamL1_Doc	:= 0
Local lEmitNfce		:= LjEmitNFCe()
Local lNovo			:= .F.

Default lCancItem 	:= .F.

//função Type inserida pois ao abrir o sistema e existir uma venda para cancelar é gerado log e o aCols nao foi declarado
If (Type("aCols") == "A" .AND. (Len(aCols) > 0)) .And. (Type("aPosCpo") == "A" .AND. (Len(aPosCpo) > 0)) 
	nPosItem	:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_ITEM"})][2]
	nPosVlrUni 	:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_VRUNIT"})][2]
	nPosVlrItem	:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_VLRITEM"})][2]
	nPosProduto	:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_PRODUTO"})][2]
	nPosQtde	:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_QUANT"})][2]
EndIf

If !(nPosItem > 0 .And. LjVassConc(1) .And. LjxBGetPaf()[2]) .Or. lEmitNfce
	lRet := .F.
EndIf

If lRet
	cSerie		:= LjGetStation( "Serie" )
	nRetCupom	:= IfPegCupom( nHdlECF, @cCupom)	
	cPDV   		:= LjGetStation( "PDV" )
	cCaixa 		:= xNumCaixa()
	
	If nRetCupom <> 0
		lRet := .F.
	EndIf
EndIf

If lRet
	nTamDoc		:= Len(cCupom)
	nTamL1_Doc	:= TamSx3("L1_DOC")[1]
	cCupom		:= StrZero((Val(cCupom)),nTamDoc)
	cCupom 		:= PadR( cCupom , nTamL1_Doc )
	cPDV		:= PadR( cPDV , nTamL1PDV )
	nX			:= N
	
	If lCancItem
		SLX->(DbSetOrder( 1 )) 	//LX_FILIAL+LX_PDV+LX_CUPOM+LX_SERIE+LX_ITEM
		cIndSLX := xFilial("SLX") + PadR(cPDV, TamSX3("LX_PDV")[1]) + ;
							PadR(cCupom, TamSX3("LX_CUPOM")[1]) + PadR(cSerie, TamSX3("LX_SERIE")[1]) +;
							aCols[nX][nPosItem]
					
		If SLX->(DbSeek(cIndSLX))
			lNovo := .F.
		Else
			lNovo := .T.
		EndIf
	Else
		lNovo := .T.
	EndIf

	RecLock("SLX",lNovo)
	REPLACE SLX->LX_FILIAL  WITH xFilial("SLX")
	REPLACE SLX->LX_PDV     WITH cPDV
	REPLACE SLX->LX_OPERADO WITH cCaixa 
	REPLACE SLX->LX_DTMOVTO WITH dDatabase	
	REPLACE SLX->LX_CUPOM   WITH cCupom
	If lNovo		
		SerieNfId("SLX",1,"LX_SERIE",dDataBase,LjEspecieNF(),cSerie)	//Log Cancelamento x Devolução
		REPLACE SLX->LX_SITUACA WITH "SC"
		REPLACE SLX->LX_SITUA	WITH "SC"
		REPLACE SLX->LX_HORA    WITH Time()
	Else
		REPLACE SLX->LX_SITUACA WITH "00"
		REPLACE SLX->LX_SITUA	WITH "00"
	EndIf
	REPLACE SLX->LX_ITEM    WITH aCols[nX][nPosItem]
	REPLACE SLX->LX_VRUNIT  WITH aCols[nX][nPosVlrUni]
	REPLACE SLX->LX_VALOR   WITH aCols[nX][nPosVlrItem]
	REPLACE SLX->LX_PRODUTO WITH aCols[nX][nPosProduto]
	REPLACE SLX->LX_QTDE    WITH aCols[nX][nPosQtde]					
	REPLACE SLX->LX_TPCANC  WITH "I"
	REPLACE SLX->LX_SUPERVI WITH cSupervisor
	
	IFStatus(nHdlECF, "35", @cContDoc)
	REPLACE LX_CONTDOC WITH cContDoc
		
	If SLX->(ColumnPos("LX_SITTRIB")) > 0
		cSitTrib := Lj7Strib( Nil, Nil, Nil, Nil, nX )
		Lj7AjustSt( @cSitTrib )
		REPLACE LX_SITTRIB WITH cSitTrib
	EndIf
	SLX->(MsUnlock())
	
	If lNovo
		//Pode mandar gerar o SLI porem a tabela não sobe devido o _SITUA da SLX
		FRTGeraSLI( cCaixa, "LOG", Str(SLX->(Recno()),17,0), "NOVO" )
	EndIf
EndIf

RestArea( aArea )

Return lRet

//--------------------------------------------------------
/*{Protheus.doc}LjLUpItcc
Para queda de energia de venda Concomitante 
@author  	Varejo
@version 	P12
@since   	18/07/2017
@return  	Logico
/*/
//--------------------------------------------------------
Function LjLUpItcc()
Local lRet	:= .T.
Local aAreaSLX:= {}
Local aArea	:= GetArea()

DbSelectArea( "SLX" )  
aAreaSLX := SLX->(GetArea()) 
SLX->(DbSetOrder( 3 ))	//LX_FILIAL+LX_SITUA
If SLX->(DbSeek(xFilial("SLX")+ "SC" ))
	While !SLX->(Eof())
		If SLX->LX_SITUA == "SC"
		 	//Sobe registro de venda que teve queda de energia
			RecLock("SLX",.F.)
			REPLACE SLX->LX_SITUACA WITH "00"
			REPLACE SLX->LX_SITUA WITH ""
			REPLACE SLX->LX_DTMOVTO WITH dDatabase //caso cancele no outro dia
			REPLACE SLX->LX_HORA WITH Time()
			SLX->(MsUnlocK())
		EndIf
		SLX->(DbSkip())
    End
EndIf

RestArea(aAreaSLX)
RestArea(aArea)

Return lRet

//--------------------------------------------------------
/*{Protheus.doc}LjLDelItcc
Exclui registros de venda que foram finalizadas 
@author  	Varejo
@version 	P12
@since   	18/07/2017
@return  	Logico
/*/
//--------------------------------------------------------
Function LjLDelItcc(cNumCupom)
Local lRet	:= .T.
Local cPDV 	:= PadR(LjGetStation("PDV"),TamSX3("L1_PDV")[1])
Local cSerie:= PadR(LjGetStation( "SERIE" ),TamSX3("LX_SERIE")[1])
Local aAreaSLX:= {}
Local aArea	:= {}
Local cCupom:= ""
Local cPesq	:= ""

Default cNumCupom := ""

cCupom := cNumCupom
If Empty(AllTrim(cCupom))
	IfPegCupom(nHdlECF, @cCupom)
EndIf

cCupom	:= PadR(cCupom,TamSX3("LX_CUPOM")[1])
cPesq	:= xFilial("SLX")+ cPDV + cCupom + cSerie

aArea := GetArea()
DbSelectArea( "SLX" )
aAreaSLX := SLX->(GetArea())
SLX->(DbSetOrder( 1 ))	//LX_FILIAL+LX_PDV+LX_CUPOM+LX_SERIE+LX_ITEM
If SLX->(DbSeek(cPesq))
	While !SLX->(Eof()) .AND.;
	 	(SLX->LX_FILIAL+SLX->LX_PDV+SLX->LX_CUPOM+SLX->LX_SERIE ==  cPesq)
		
		If AllTrim(SLX->LX_SITUA) == "SC"
			RecLock("SLX",.F.)
			REPLACE SLX->LX_SITUACA WITH ""
			REPLACE SLX->LX_SITUA WITH ""
			SLX->(MsUnlocK())
			
			RecLock("SLX",.F.)			
			SLX->(DbDelete())
			SLX->(MsUnlocK())
		EndIf
		SLX->(DbSkip())
    End
EndIf

RestArea(aAreaSLX)
RestArea(aArea)

Return lRet

//--------------------------------------------------------
/*{Protheus.doc}LjxVlLivr
Verifica se foi criado os registros fiscal, caso existir inconsistencia retorna falso
@author  	Rene Julian
@version 	P12
@since   	25/08/2018
@return  	Logico   - Caso existir inconsistencia na venda retorna falso
/*/
//--------------------------------------------------------
Static Function LjxVlLivr(nRecnoSL1)
Local lRet 		:= .T.          // variavel de retorno da função
Local cDoc 	 	:= ""			// Numero do Doc
Local cSerie 	:= ""			// Serie 
Local cTipMov   := Padr("S",TamSx3("FT_TIPOMOV")[1])   // Tipo do movimento 'S' Saida  
Local aArea     := GetArea()	// variavel para controle da area
Local cSitua    := ""			// controle do tipo Situa do orçamento 
Local lValid    := nModulo == 12 .And. SuperGetMV("MV_LJGRVON",,.T.)  // Se tiver trabalhando on line verifico a existencia dos registros fiscais

Default nRecnoSL1 := 0 

If nRecnoSL1 > 0 .And. lValid
	SL1->(DbGoTo(nRecnoSL1))  // posiciono no registro da SL1 para pegar o numero doc e serie
	cDoc := SL1->L1_DOC
	cSerie := SL1->L1_SERIE 
	cSitua  := SL1->L1_SITUA
	LjGrvLog("SAT", "LjxVlLivr - Orcamento:"+ SL1->L1_NUM + " - Doc: " + cDoc + " - Serie: " + cSerie )
	If !Empty(cDoc) .And. !Empty(cSerie) .And. Upper(AllTrim(cSitua)) == "OK"  // se tiver doc serie e situa como ok a venda esta finalizada
		
		DbSelectArea("SF2")//Verifico a existencia do registro da SF2
		DbSetOrder(1)		//F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
		If !DbSeek(xFilial("SF2")+ cDoc + cSerie)
			LjGrvLog("SAT", "LjxVlLivr - Orcamento:"+ SL1->L1_NUM + " - nao achou o registro na tabela SF2 ")
			lRet := .F.
		EndIf 
		DbSelectArea("SD2")//Verifico a existencia do registro da SD2
		DbSetOrder(3)		//D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
		If !DbSeek(xFilial("SD2")+ cDoc + cSerie)
			LjGrvLog("SAT", "LjxVlLivr - Orcamento:"+ SL1->L1_NUM + " - nao achou o registro na tabela SD2 ")
			lRet := .F.
		EndIf 
		DbSelectArea("SF3")//Verifico a existencia do registro da SF3
		DbSetOrder(6)		//F3_FILIAL+F3_NFISCAL+F3_SERIE
		If !DbSeek(xFilial("SF3")+ cDoc + cSerie)
			LjGrvLog("SAT", "LjxVlLivr - Orcamento:"+ SL1->L1_NUM + " - nao achou o registro na tabela SF3 ")
			lRet := .F.
		EndIf 
		DbSelectArea("SFT")//Verifico a existencia do registro da SFT
		DbSetOrder(1)		//FT_FILIAL+FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM+FT_PRODUTO
		If !DbSeek(xFilial("SFT")+ cTipMov + cSerie + cDoc )
			LjGrvLog("SAT", "LjxVlLivr - Orcamento:"+ SL1->L1_NUM + " - nao achou o registro na tabela SFT ")
			lRet := .F.
		EndIf 
		
		RestArea(aArea)
		
	EndIf 
	
EndIf 

Return lRet

//--------------------------------------------------------
/*{Protheus.doc}LJCancOnLine
Envia a venda para cancelamento online
@author  	JMM
@version 	P12.1.27
@since   	10/01/2020
@param		nRecnoSL1	- RECNO do registro da tabela SL1 da venda a ser cancelada
			cModDoc		- Modelo do documento
@return  	Array aRet - aRet[1] -> Indica sucesso no cancelamento ou não - aRet[2] -> Indica se deve integrar a venda (explodir).
@Obs		Somente para NFC-e Modelo de doc 65
/*/
//--------------------------------------------------------

Static Function LJCancOnLine(nRecnoSL1, cModDoc)

Local aRet			:= {.F.,.F.}
Local oCancNfce		:= NIL									// Objeto de retorno do cancelamento online
Local aAreaSL1		:= SL1->(GetArea())
Local nMvSpedExc	:= SuperGetMV("MV_NFCEEXC",,24)			// Indica a quantidade de horas que a NFCe pode ser cancelada
Local lFisLivro 	:= (SuperGetMV("MV_LJLVFIS",,1) == 2)	// Utiliza novo conceito para geracao do SF3
Local lL1RETSFZ		:= SL1->(ColumnPos("L1_RETSFZ")) > 0	//campo o qual será gravado as informações de retorno da SEFAZ
Local lCriaSLX 		:= .F.									//Indica se deve criar a tabela SLX
Local lPrazoCanc	:= .T.									// Indica se esta dentro do prazo para cancelamento na SEFAZ
Local lCancOnline	:= .F.									// Indica sucesso no cancelamento Online
Local cHoraSL1		:= ""									// Guarda a informação do campo SL1->L1_HORA

Default cModDoc 	:= ""

SL1->(DbGoTo(nRecnoSL1))

If nMvSpedExc <= 0
	nMvSpedExc := 1
EndIf

// Converte o prazo em minutos e desconta 5
nMvSpedExc := ( nMvSpedExc * 60 ) - 5

// Se SL1->L1_HORA estiver gravado "HH:MM" sem os segundos, adiciona os segundos no formato "HH:MM:00"
 cHoraSL1	:= Iif( Len(SL1->L1_HORA)==5, SL1->L1_HORA + ":00", SL1->L1_HORA )

// Verifica se esta dentro do prazo de cancelamento
lPrazoCanc :=  !(Hrs2Min( ElapTime( cHoraSL1, TIME() ) ) >= nMvSpedExc) .OR. SL1->L1_EMISNF == DATE()

oCancNfce := LOJCNFCE():New()

//Tenta realizar o cancelamento Online
LjMsgRun(STR0065 + SL1->(L1_SERIE+L1_DOC),, {|| oCancNfce:LjCancOnline(SL1->(L1_SERIE+L1_DOC))} ) //"Aguarde, Cancelando documento: "

If oCancNfce:aResultCancelamento[1]
	
	//Grava log informando que a venda foi cancelada online
	LjGrvLog( "LJCancOnLine - NumOrc: " + SL1->L1_NUM, "NFC-e cancelada ONLINE, Id: " + SL1->(L1_SERIE+L1_DOC) ) 
	
	RecLock("SL1")
		Replace SL1->L1_SITUA with "X2"
	SL1->( MsUnlock() )

	lCancOnline := .T.

	// -- Gravação da tabela SLX para vendas NFC-E Canceladas.
	lCriaSLX := .T.
	
	aRet[1] := .T.

	If IsBlind()
		Conout("LJCancOnLine - Cancelamento realizado com sucesso.")		
	Else
		MsgAlert(STR0066)// "Cancelamento realizado com sucesso."
	Endif

Else
	
	If oCancNfce:aResultMetodo[1] .AND. oCancNfce:aResultTSS[1] //Nota transmitida porem com rejeição	
		
		LjGrvLog( "LJCancOnLine - NumOrc: " + SL1->L1_NUM,  "Não foi possivel realizar o cancelamento." + CRLF + "Motivo: " + oCancNfce:aResultCancelamento[3]) 
		
		If IsBlind()
			Conout("Não foi possivel realizar o cancelamento.. Motivo: " + oCancNfce:aResultCancelamento[3])
		Else
			MsgAlert(STR0067 + CRLF + STR0068 + oCancNfce:aResultCancelamento[3]) // "Não foi possivel realizar o cancelamento. Motivo: Rejeição "
		Endif

		// Independente da rejeição indica para gravar a venda, para ser possível a devolução
		aRet[2] := .T.	
	
	ElseIF !oCancNfce:aResultTSS[1] // Falha de comunicação com TSS/SEFAZ

		LjGrvLog( "LJCancOnLine - NumOrc: " + SL1->L1_NUM,  "Não foi possivel realizar o cancelamento. Motivo: Sem comunicação com TSS / SEFAZ.")
		LjGrvLog( "LJCancOnLine - NumOrc: " + SL1->L1_NUM,  "Retorno do TSS: " + oCancNfce:aResultTSS[3])		

		If IsBlind()
			Conout("Não foi possivel realizar o cancelamento. Motivo: Sem comunicação com TSS / SEFAZ.")
		Else
			MsgAlert(STR0069 + SL1->(L1_SERIE+L1_DOC) + CRLF + STR0070 + CRLF ) // "Não foi possivel realizar o cancelamento do documento " "Motivo: Sem comunicação com TSS / SEFAZ."
		Endif

		/*
		// Se o cancelamento não foi transmitido por falta de comunicação com TSS/SEFAZ e estiver FORA do prazo de cancelamento
		// indica para gravar a venda, para ser possível a devolução, se estiver no prazo de cancelamento indica para gravar na SLX para cancelar via Job
		*/
		If !lPrazoCanc
			aRet[2] := .T.	
		EndIf	
	Else

		LjGrvLog( "LJCancOnLine - NumOrc: " + SL1->L1_NUM,  "Não foi possivel realizar o cancelamento. Motivo: falta de retorno SEFAZ.")

		If IsBlind()
			Conout("Não foi possivel realizar o cancelamento. Motivo: falta de retorno da SEFAZ.")
		Else
			MsgAlert( STR0067 + CRLF + STR0071) // "Não foi possivel realizar o cancelamento. Motivo: falta de retorno da SEFAZ."
		Endif

		If !lPrazoCanc
			aRet[2] := .T.
		EndIf
	EndIf

EndIf

If lCriaSLX
	// -- Gravação da tabela SLX para vendas NFC-E Canceladas.
	Lj7SLXDocE(	If(lCancOnline,cModDoc,"")	, SL1->L1_DOC				, SL1->L1_SERIE	, SL1->L1_PDV	,;
				SL1->L1_OPERADO				, If(lCancOnline,"X2","RX")	, ""			, ""			,;
				SL1->L1_NUM					, "A"						, "  "			)
EndIf

// Grava SF3 online
If aRet[1] .And. lFisLivro .And. cPaisLoc == "BRA" .And. lL1RETSFZ
	//Atualiza dados de Cancelamento de Documento Eletronico nas tabelas SL1, SF3, SFT.
	LjAtuCanc( "SL1", SL1->(Recno()) )
EndIf

RestArea(aAreaSL1)

return aRet
//--------------------------------------------------------
/*/{Protheus.doc} Lj7TemCart
	Retorna qual ação foi tomada pelo na entrada do sistema
	@author  	Gilmar Costa
	@version 	P12.1.27
	@since   	07/01/2021
	@param		nRecnoSL1	- RECNO do registro da tabela SL1 da venda a ser cancelada
	@return  	Tipo de ação tomada pelo sistema
	@Obs		Somente para NFC-e	
	/*/
//--------------------------------------------------------	
Function Lj7TemCart(cDocSL1)
Local nRet 			:= 0									// Indica ação que será tomada com a pendência do SITEF - 2-Cancela / 3-Confirma
Local lMV_LJCFTEF	:= SuperGetMV("MV_LJCFTEF",,.T.)		// Define se as transacoes TEF pendentes serao Confirmadas ou Canceladas
Local cMVLJTEFPD	:= LjTEFPend(1) 						// Verifica se as transacoes TEF pendentes serao "1=Confirmadas", "2=Canceladas" ou "3=Permanecem Pendentes"
Local lTEFSave		:= SuperGetMV("MV_TEFSAVE",,2) == 1 	// Sistema deve guardar e recuperar os dados da transação TEF realizada na venda caso ocorra algum problema antes de concluir a venda? (1=Sim;2=Não)  
Local lTemVndCar	:= .F.									// Guarda se houve venda em Cartão 
Local lDesfSav		:= .F. 									//Desfaz transação não salva
Local aAreaSL4 		:= SL4->(GetArea())
Local cTipTef       := LjGetStation("LG_TIPTEF")			// Tipo do TEf

If cTipTef $ TEF_CLISITEF .AND. Type("oTef") == "O"

	// Procura por forma de pagamento igual "CC" ou "CD"
	DbSelectArea("SL4")
	DbSetOrder(1)			
	If DbSeek(xFilial("SL4") + cDocSL1)
		While !EOF() .AND. (xFilial("SL4") == SL1->L1_FILIAL .AND. SL4->L4_NUM == SL1->L1_NUM)
			If Alltrim(SL4->L4_FORMA) == "CC" .OR. Alltrim(SL4->L4_FORMA) == "CD"
				lTemVndCar := .T.
				Exit
			Endif
			SL4->(DbSkip())
		End
	Endif

	If lTemVndCar

		If  ExistFunc("LjExiTEF")
			lDesfSav := !LjExiTEF(cDocSL1) 
		EndIf
		// lDesfSav := .T. - Não existe arquivo .CSV de recuperação
		// lDesfSav := .F. - Existe arquivo .CSV de recuperação

		// Indica que a transação foi CONFIRMADA na entrada do sistema
		If (lMV_LJCFTEF .And. Empty(cMVLJTEFPD)) .Or. cMVLJTEFPD == "1" 		// 1=Confirma
			nRet := 1			// Indica que a transação TEF pendente foi CONFIRMADA		

		// Indica que a transação foi CANCELADA na entrada do sistema
 		ElseIf (!lMV_LJCFTEF .AND. Empty(cMVLJTEFPD)) .OR. cMVLJTEFPD == "2" 	// 2=Cancela
			nRet := 2			// Indica que a transação TEF pendente foi CANCELADA

		// Indica que a transação fiCOU PENDENTE na entrada do sistema
		ElseIf cMVLJTEFPD == "3" .AND. lTEFSave .AND. !lDesfSav    				// 3=Pendente  (cMVLJTEFPD=="3") + lTEFSave(MV_TEFSAVE="1") + existe arquivo .CSV de recuperação(lDesfSav=.F.)
			nRet := 3			// Indica que a transação TEF ficou PENDENTE

		// Indica que a transação foi CANCELADA na entrada do sistema
		ElseIf cMVLJTEFPD == "3" .AND. !lTEFSave .AND. lDesfSav    				// 4=Cancela  (cMVLJTEFPD=="3") + lTEFSave(MV_TEFSAVE="1") + existe arquivo .CSV de recuperação(lDesfSav=.F.)
			nRet := 4			// Indica que a transação TEF ficou PENDENTE		

		EndIf

	EndIf
EndIf

RestArea(aAreaSL4) 

Return(nRet)

//--------------------------------------------------------
/*/{Protheus.doc} Lj7ConfNF
    Confirma venda que ficou pendente.

	@author  	Gilmar Costa
	@version 	P12.1.27
	@since   	12/01/2021
	@param		Tipo de ação tomada pelo sistema, dependendo dos parãmetros na entrada do sistema 
	@return  	Nil
	@Obs		Somente para NFC-e	
	/*/
//--------------------------------------------------------
Function Lj7ConfNF()

    Local lLJGRVON  := SuperGetMV("MV_LJGRVON",,.T.) 	    //Verifica se utiliza gravação via Job ou OnLine
    Local cSitua    := "" 							 	    //Armazena informação que será gravada nno campo L1_SITUA
    Local lAutoExA  := IsBlind()						    //Verifica se a rotina sera executada via execauto ou nao
    Local cFilNum   := SL1->L1_FILIAL + "\" + SL1->L1_NUM

    LjGrvLog(cFilNum, "Falha na finalização da venda, será finalizada e impressa corretamente.", SL1->L1_SITUA)

    //Atualiza L1_SITUA
    If lLJGRVON

        If !lAutoExA
            LjMsgRun(STR0072 + SL1->(L1_SERIE + L1_DOC), , { || LjGrvTudo(.F.) } )  //"Aguarde, gravando documento: "
        Else
            Conout(STR0072 + SL1->(L1_SERIE + L1_DOC) )                             //"Aguarde, gravando documento: "
            LjGrvTudo(.F.)
        EndIf	

        cSitua := "OK"
    Else

        cSitua := "RX"
    EndIf	

    If !lAutoExA
        Lj7ImpDanfe()
    EndIf	

    RecLock("SL1", .F.)
        SL1->L1_SITUA := cSitua
    SL1->( MsUnLock() )

    LjGrvLog(cFilNum, "Impressão da venda realizada com sucesso, foi atualizado o L1_SITUA.", SL1->L1_SITUA)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} DefConCanV
Usuario define se venda será confirmada ou cancelada dependendo 
da configuração do parâmetro MV_LJCREVD.

@param  cFilNum - L1_FILIAL e L1_NUM, utilizado para LOG
@author Rafael Tenorio da Costa
@since 	21/01/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DefConCanV(cFilNum)

    //Controle de recuperação de venda
    //1= Não obriga a liberação do supervisor, quando for inutilizar uma venda recuperada.
    //2= Obriga a liberação do supervisor, quando for inutilizar uma venda recuperada.
    //3= Venda recuperada será finalizada corretamente.
    Local cCtrRecVen := AllTrim( SuperGetMv("MV_LJCREVD", , "1") )
    Local lInutiliza := .F.                                          // Indica se o documento deve ser inutilizado

    While .T.

        If cCtrRecVen == "3" .Or. Aviso(STR0055, I18n(STR0056 + CRLF + CRLF + STR0057, {cFilNum}), {STR0073, STR0074}, 2, /*cText*/, 2) == 2  //"Falha na última Venda"   //"Foi detectada uma inconsistência na finalização da última venda #1."   //"Deseja Imprimir\Finalizar a venda corretamente ou Cancelar\Inutilizar todo o processo da última venda ?"    //"Cancelar"   //"Imprimir"
        
            If cCtrRecVen == "3"
                LjxjMsgErr( I18n(STR0056, {cFilNum}), STR0082)    //"Foi detectada uma inconsistência na finalização da última venda #1."     //"A venda será finalizada e a Nota Fiscal impressa!"
            EndIf

            //Confirma venda que ficou pendente
            Lj7ConfNF()

            Exit                            
        Else

            //Solicita validação do superior
            If cCtrRecVen == "2"
                
                If FwAuthSuper(__cUserId)
                    LjGrvLog(cFilNum, "Superior do usuário aprovou cancelamento/inutilização.", __cUserId)
                Else
                    LjxjMsgErr(STR0079, STR0080)    //"Autorização do superior não foi efetuada. O Cancelamento\Inutilização só poderá ocorrer mediante autorização do superior."       //"Efetue a autorização com o superior ou conclua a Impresssão\Finalização da venda."
                    Loop
                EndIf
            EndIf

            lInutiliza := .T.
            LjGrvLog(cFilNum, "Venda encaminhada para cancelamento/inutilização.", SL1->L1_SITUA)
            Exit
        EndIf
    EndDo

Return lInutiliza
