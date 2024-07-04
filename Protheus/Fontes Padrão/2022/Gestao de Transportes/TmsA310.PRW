#INCLUDE "TmsA310.ch"
#Include 'Protheus.ch'
#INCLUDE "FWLIBVERSION.CH"

Static lTM310XML  := ExistBlock('TM310XML')
Static cTMSERP    := SuperGetMv("MV_TMSERP",,"0") //| Habilita integração Mensagem Única via EAI para outras Marcas 0=Desligado;1=DATASUL
Static lEAIFunOK  := (FindFunction("GETROTINTEG") .And. FindFunction("FwHasEAI") .And. Len(getSrcArray("TRANSPORTDOCUMENTCLASS.PRW")) > 0)
Static cGerFreEvt := "1" //| Define o Evento de geração do Titulo de Frete de Carreteiro, sendo: 1-Inclusão do Contrato;2-Fechamento da Viagem;
Static lTM210VCte := ExistBlock('TM210VCTE')
Static lTmsRdpU   := SuperGetMV( 'MV_TMSRDPU',.F., 'N' ) <> 'N'  //F-Fechamento, S=Saida, C=Chegada, N=Não Utiliza o Romaneio unico por Lote de Redespacho
Static cTMSRDPU   := SuperGetMV("MV_TMSRDPU",,"N")               //F-Fechamento Vge, S=Saida Vge, C=Chegada Vge,N=Nao Utiliza
Static lRestRepom := SuperGetMV('MV_VSREPOM',,"1") == "2.2"
Static cImpCTC 	  := SuperGetMv("MV_IMPCTC",,"0") //--Responsável pelo cálculo dos impostos (0=ERP/1=Operadora).
Static lMetrica   := FindFunction('TMSMetrica') .And. FindFunction('FWLsPutAsyncInfo') .And. FwLibVersion() >= "20200727" 

Static cCodFonCol := ""
Static cProcesCol := ""

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSA310  ³ Autor ³ Alex Egydio           ³ Data ³26.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Fechamento de Viagem                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA310(ExpC1, ExpC2, ExpN1)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Tipo de Servico TMS.                               ³±±
±±³          ³ ExpC2 = Tipo de Transporte TMS.                            ³±±
±±³          ³ ExpC3 - Indice do DTQ                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gestao de Transporte                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA310(cSer310,cTra310,nInd310)

Local aCores      := {}
Local aSetKey     := {}
Local lMDFeAut    := SuperGetMV("MV_MDFEAUT",,.F.)  .And. ExistFunc("TmsMDFeAut") //--MDFe Automatico

Private cFiltro   := ""
Private cCadastro := STR0001 //'Fechamento de Viagem'
Private aIndex    := {}
Private bFiltraBrw
Private cSerTms   := cSer310
Private cTipTra   := cTra310

DEFAULT nInd310	:= 3
DEFAULT cSer310	:= ' '
DEFAULT cTra310	:= ' '

If Type("aRotina") == "U"
	Private aRotina	   := MenuD310()
EndIf

Aadd(aCores,{"DTQ_STATUS=='1'",'BR_VERDE'		})	//-- Em Aberto
Aadd(aCores,{"DTQ_STATUS=='5'",'BR_VERMELHO' 	})	//-- Fechada
Aadd(aCores,{"DTQ_STATUS=='2'",'BR_AMARELO'		})	//-- Em Transito
Aadd(aCores,{"DTQ_STATUS=='4'",'BR_LARANJA'		})	//-- Chegada em Filial
Aadd(aCores,{"DTQ_STATUS=='3'",'BR_AZUL'	   	})	//-- Encerrada
Aadd(aCores,{"DTQ_STATUS=='9'",'BR_PRETO'		})	//-- Cancelada

dbSelectArea('DTQ')
dbSetOrder( nInd310 )

If !Empty(cSer310)
	cFiltro := "DTQ_FILIAL == '" + xFilial("DTQ") + "' .And. "
	cFiltro += "DTQ_SERTMS == '" + cSer310 + "' .And. "
	cFiltro += "DTQ_TIPTRA == '" + cTra310 + "'"

	CursorWait()
	bFiltraBrw := {|| FilBrowse("DTQ",@aIndex,@cFiltro) }
	Eval(bFiltraBrw)
	CursorArrow()
EndIf

If ExistFunc("TmsAutViag") .And. DTQ->(ColumnPos("DTQ_CODAUT")) > 0   
	If TmsAutViag(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,DTQ->DTQ_CODAUT,"TMSA190")
		lMDFeAut := .T.
	EndIf
EndIf

If lMDFeAut

	AAdd(aSetKey, { VK_F12 , { || Pergunte("TMSA310",.T.) } } )
EndIf	

//-- Inicializa Teclas de Atalhos
TmsKeyOn(aSetKey)

//-- Endereca a funcao de BROWSE
mBrowse( 6,1,22,75,'DTQ', , , , , ,aCores )

If !Empty(cSer310)
	EndFilBrw("DTQ",aIndex)
EndIf

TmsKeyOff(aSetKey)

RetIndex('DTQ')

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA310Mnt³ Autor ³ Alex Egydio           ³ Data ³26.01.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Fechamento de Viagem                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA310Mnt(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA310                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSA310Mnt( cAlias, nReg, nOpcx,lReserv,lConfirma )

Local aSays       := {}
Local aButtons    := {}
Local aArea       := GetArea()
Local aAreaDTX    := DTX->( GetArea() )
Local aAreaDTQ    := DTQ->( GetArea() )
Local aAreaDTW    := DTW->( GetArea() )
Local aAreaDUA    := DUA->( GetArea() )
Local aAreaDTR    := DTR->( GetArea() )
Local aAreaDUV    := DUV->( GetArea() )
Local aAreaDA3    := DA3->( GetArea() )
Local cFilOri     := DTQ->DTQ_FILORI
Local cViagem     := DTQ->DTQ_VIAGEM
Local lOk         := .T.
Local lPeTm310TOk := ExistBlock('TM310TOK')
Local lTM310GerCC := ExistBlock('TM310GCC')
Local lVgeInter   := .F.
Local lTMSOPdg    := AliasInDic('DEG') .And. SuperGetMV('MV_TMSOPDG',,'0') == '2' //-- Integracao com Operadoras de Frota
Local lFrotaProp  := .F.
Local aMsgErr     := {}
Local cAliasSE2   := ""
Local cQuery      := ""
Local lPercurso   := SuperGetMv("MV_TMSPERC",.F.,.F.)
Local lGeraCTC    := .T.
Local aRegDTR	:= {}
Local nX		:= 0
Local lDTRAtu	:= DTR->(FieldPos("DTR_IDPDG")) > 0
Local cNumIdOpe	:= ""
Local cNumIdPdg	:= ""
Local cCodOpe	:= ""
Local cNumCIOT	:= ""
Local lCiotAgre	:= .F.
Local lCancCiot	:= .F.
Local lIncCiot	:= .F.
Local lYesNo	:= .F.
Local lCont     := .F.

Default lReserv   := .T.
Default lConfirma := .T.

DTX->( DbSetOrder( 3 ) )

// Obtem a opcao do aRotina
If Type("aRotina") == "U" .Or. Empty(aRotina)
	Private aRotina	:= MenuD310()
EndIf
nOpcx := aRotina[nOpcx,4]

//-- Verifica se o agendamento está sendo utilizado por outro usuário no painel de agendamentos
If !TMSAVerAge("6",,,,,,,,,,,,"2",.T.,.T.,,DTQ->DTQ_VIAGEM,)
	Return .F.
EndIf

If nOpcx == 3 // Fechar
	cCadastro := STR0001 //'Fechamento de Viagem'
	If	TMSChkViag( cFilOri, cViagem, .T., .F., .F., .T., .T., .T.,.F. , , .T., , , , , , ,.T.)

			//--- Verifica se o Contrato de Carreteiro foi gerado para o envio dos impostos
		If cTmsErp == "0" .And. cImpCTC == "0" .And. FindFunction("TMSJIsPgB") .AND. TMSJIsPgB( cFilOri, cViagem )
			
			If lTM310GerCC
				lYesNo	:= ExecBlock( 'TM310GCC', .F., .F., { cFilOri, cViagem } )
			EndIf

			If lYesNo .AND. MsgYesNo( STR0081 + cViagem + '?', cCadastro ) // STR0081 'Deseja realizar a geração do Contrato de Carreteiro para a viagem '
				TMSA250Ger( cFilOri , cViagem )
			EndIf

			lOk := .T.

		ElseIf lRestRepom .And. lTMSOPdg .And. cTmsErp == "0" .And. cImpCTC == "0" .And. FindFunction("TM15CntCar")
 
			lOk:= TM15CntCar(cFilOri,cViagem)
			If !lOk 
				If DEG->(ColumnPos('DEG_GERCTC')) > 0 
					DEG->(DbSetOrder(1))
					If DEG->(MsSeek(xFilial("DEG")+"01"))
						lGeraCTC:= DEG->DEG_GERCTC  == "1"
					EndIf 
				EndIf 

				If lGeraCTC
					If FindFunction("TMSA250Ger")
						lOk	:= TMSA250Ger( cFilOri , cViagem )
						If !lOk 
							Help( ' ', 1, 'TMSA31041') // Não é possivel efetuar o fechamento da viagem pois o Contrato de Carreteiro não foi gerado.
						EndIf 
					EndIf 	
				Else
					lOk:= .T.			
				EndIf 
			EndIf
			
		EndIf

		//-- Executa ponto de entrada
		If	lPeTm310TOk
			lOk := ExecBlock('TM310TOK',.F.,.F.,nOpcx)
		EndIf

		If lOk
			//--Teste da função que retornará o CEP de Origem e Destino 
			If ExistFunc('TMSCEOrDes')
				TMSCEOrDes(cFilOri,cViagem,DTQ->DTQ_SERTMS)
			EndIf
			If lConfirma
				Aadd( aSays, STR0006 ) //'Este programa tem como objetivo, efetuar o fechamento da viagem e gerar operacoes '
				Aadd( aSays, STR0007 ) //'de transporte. Apos a confirmacao, a viagem ficara com status ( Em Transito ) .'

				Aadd( aButtons, { 1, .T., {|o| Processa({|| lOk:= TMSA310Grv(nOpcx)},cCadastro), o:oWnd:End() } } )
				Aadd( aButtons, { 2, .T., {|o| o:oWnd:End() } } )

				FormBatch( cCadastro, aSays, aButtons )
			Else
				
				lOk:= TMSA310Grv(nOpcx)

			EndIf

		EndIf

	EndIf
ElseIf nOpcx == 5 // Estornar

	DTW->( DbSetOrder( 3 ) )
	DUA->( DbSetOrder( 2 ) )
	DTR->( DbSetOrder( 1 ) )

	If DTR->(MsSeek(xFilial("DTR")+cFilOri+cViagem))
		cCodOpe := DTR->DTR_CODOPE
		If !Empty(DTR->DTR_FILVGE) .And. !Empty(DTR->DTR_NUMVGE) .And. DTQ->DTQ_STATUS == StrZero(2,Len(DTQ->DTQ_STATUS)) // Em Transito
			lVgeInter := .T.
		EndIf
	EndIf

	If DTQ->DTQ_FILATU <> cFilAnt
		Help( ' ', 1, 'TMSA31006',, cFilOri, 2, 8 ) // Estorno habilitado somente para a filial
		lOk := .F.
	EndIf

	DUD->(dbSetOrder(2))
	If DUD->(dbSeek(xFilial("DUD")+cFilOri+cViagem))
		While DUD->(!EOF()) .AND. DUD->(DUD_FILIAL == xFilial("DUD") .AND. DUD_FILORI == cFilOri .AND. DUD_VIAGEM == cViagem   )
	
			If !Empty(DUD->DUD_MANIFE) .And. lPercurso
				Help("", 1, "TMSA21008",, DUD->DUD_FILDOC + ' ' + DUD->DUD_DOC + ' ' + DUD->DUD_SERIE,3,1) // "Documento ja manifestado, nao e permitido efetuar o estorno."
				lOk := .F.
				Exit
			EndIf
			DUD->(dbSkip())
		EndDo
	EndIf

	If lOk
		cAliasSE2 := GetNextAlias()
		cQuery := 'SELECT SE2.E2_NUM FROM '
		cQuery += RetSqlName("DYX") + " DYX INNER JOIN "
		cQuery += RetSqlName("DYV") + " DYV "
		cQuery += " ON DYX_IDCDIA = DYV_IDCDIA INNER JOIN "
		cQuery += RetSqlName("SE2") + " SE2 "
		cQuery += "  ON E2_PREFIXO = DYX.DYX_PRETIT AND E2_NUM = DYX.DYX_NUMTIT "
		cQuery += "  WHERE DYV.DYV_FILIAL = '"  + xFilial("DYV") + "' "
		cQuery += "  AND DYV.DYV_FILORI = '"  + DTQ->DTQ_FILORI  + "' "
		cQuery += "  AND DYV.DYV_VIAGEM = '"  + DTQ->DTQ_VIAGEM  + "' "
		cQuery += "  AND DYX.DYX_FILIAL = '"  + xFilial("DYX")   + "' "
		cQuery += "  AND SE2.E2_FILIAL =  '"  + xFilial("SE2")   + "' "
		cQuery += "  AND DYV.DYV_STATUS = '1' "
		cQuery += "  AND SE2.E2_BAIXA <> ' ' AND SE2.E2_SALDO = 0 "
		cQuery += "  AND DYV.D_E_L_E_T_ = ' ' "
		cQuery += "  AND DYX.D_E_L_E_T_ = ' ' "
		cQuery += "  AND SE2.D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasSE2, .F., .T.)
		If (cAliasSE2)->(!Eof()) .And. !Empty((cAliasSE2)->E2_NUM)
			Help('', 1,"TMSA31027",, STR0059,1) // Existem títulos de diária ja baixados, favor estornar.
			lOk := .F.
		EndIf
		(cAliasSE2)->(DbCloseArea())
	EndIf

	If lOk .And. !lVgeInter
		If !TMSChkViag( cFilOri, cViagem, .F., .F., .F., .T., .T.,, .F.,,,,,, .T. )
			lOk := .F.
		ElseIf DTQ->DTQ_STATUS # StrZero(5, Len(DTQ->DTQ_STATUS))
			Help( " ", 1,"TMSA31015",, RetTitle("DTQ_STATUS") + " :  " + StrZero(5, Len(DTQ->DTQ_STATUS)), 2, 0)  // Somente poderao ser estornadas viagens com o status informado
			lOk := .F.
		EndIf

		If DTW->( MsSeek( cSeek := xFilial( 'DTW' ) + cFilOri + cViagem ))
			While !DTW->(Eof()) .And. DTW->DTW_FILIAL + DTW->DTW_FILORI+ DTW->DTW_VIAGEM == cSeek
				If DTW->DTW_FILATU == cFilAnt .And. DTW->DTW_TIPOPE == StrZero(2,Len(DTW->DTW_TIPOPE)) .And.;
					( DTW->DTW_STATUS == StrZero( 2, Len( DTW->DTW_STATUS ) ) .Or. DTW->DTW_STATUS == StrZero( 9, Len( DTW->DTW_STATUS ) ) )
					Help( ' ', 1, 'TMSA31004' ) // Ja Existem Operacoes de Transporte Apontadas para a Viagem
					lOk := .F.
					Exit
				EndIf
				DTW->(dbSkip())
			EndDo
		EndIf
	EndIf

	//--- Valida se os Movimentos foram estornados
	If lOk .And. lTMSOPdg .And. lRestRepom .And. FindFunction("RepIncMov") .AND. cCodOpe == "01"
		lOk:= RepIncMov(cFilOri,cViagem,.F.)
	EndIf

	//-- Executa ponto de entrada
	If	lOk .And. lPeTm310TOk
		lOk := ExecBlock('TM310TOK',.F.,.F.,nOpcx)
	EndIf

	If TableIndic("DM0") .And. SuperGetMV("MV_TMAPCKL",,.F.) .And. SuperGetMV("MV_TMINTEV",,"") == "1" .And. ExistFunc("TMSIntChk") .AND. ExistFunc("TMHVerFin")
		lOk := TMHVerFin( cFilOri, cViagem )
		If !lOk
			Help( "", 1, 'TMSA310Mnt', , STR0084, 1, 0, , , , , , { STR0085 } ) //STR0084 "Não é possivel estornar Fechamento, esta viagem já possui documentos entregues no Aplicativo Meu Checklist." STR0085 "Caso seja precise estornar o apontamento, será necessario excluir o Checklist pelo portal do Aplicativo Meu Checklist."
		EndIf
	EndIf

	If lOk
	   If lConfirma
			lOk:= MsgYesNo( STR0011 + cFilOri + ' ' + cViagem) // 'Confirma Estorno de Fechamento da Viagem No. ' # Sim # Nao
       EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³REALIZA A INTEGRACAO COM OPERADORAS DE FROTA³
		//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
		//³Quando o controle de veiculos NAO estiver   ³
		//³ativo, o estorno do controle de viagem com  ³
		//³a Operadora de Frotas ira ocorrer no momento³
		//³do estorno da Operacao de Saida de viagem   ³
		//³Quando o controle de veiculos estiver ativo,³
		//³o estorno do controle de viagem sera        ³
		//³realizado atraves do estorno do fechamento  ³
		//³da viagem.                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Begin Transaction
			If lOk .And. lTMSOPdg .And. DTR->DTR_CODOPE == '01' .And. !Empty(DTR->DTR_PRCTRA)
				DTR->( DbSetOrder(1) )
				If DTR->(MsSeek(xFilial('DTR')+ DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM))

					lFrotaProp := Posicione('DA3',1,xFilial('DA3')+DTR->DTR_CODVEI,'DA3_FROVEI') == '1'
					CursorWait()
					MsgRun( STR0034,; //-- 'Realizando comunicacao com a Operadora...'
							STR0035,; //-- 'Aguarde...'
							{|| lOk := TMA310Oper( DTR->DTR_CODOPE, DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, @aMsgErr, nOpcx, DTR->DTR_CODVEI, .T. )} )
					CursorArrow()

					If !lOk .And. !Empty(aMsgErr)
						TmsMsgErr( aMsgErr )
					EndIf
				EndIf
			ElseIf lOk .And.  lTMSOPdg .And. DTR->DTR_CODOPE == '02'
				DTY->(DbSetOrder(2))
				If DTY->(MsSeek(xFilial('DTY')+ DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM))
					//-- Limpa marcas dos agendamentos
					//-- Analisar a inserção desta rotina antes de cada Return( .F. ) ou ( .T. ), quando utilizado TmsVerAge
					If !IsInCallStack("TMSAF76")
						TMSALimAge(StrZero(ThreadId(),20))
					EndIf
					Help(' ', 1, 'TMSXFUNA06')	//-- Manutencoes nao sao permitidas em viagens que ja tenham contrato de carreteiro
					lOk := .F.
				EndIf

				DTR->(DbSetOrder(1))
				If DTR->(MsSeek(xFilial('DTR')+ DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM)) .And. lOk .And. !Empty(DTQ->DTQ_IDOPE)
					cNumIdOpe    := AllTrim(DTQ->DTQ_IDOPE)
                	cNumIdPdg    := AllTrim(DTQ->DTQ_IDPDG)
					CursorWait()
					MsgRun( STR0034,; //-- 'Realizando comunicacao com a Operadora...'
							STR0035,; //-- 'Aguarde...'
							{|| lOk := TMA310Oper( DTR->DTR_CODOPE, DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, @aMsgErr, nOpcx, DTR->DTR_CODVEI, .T., , @cNumIdOpe, , , @cNumIdPdg )} )
					CursorArrow()

					If !lOk .And. !Empty(aMsgErr)
						TmsMsgErr( aMsgErr )
					EndIf
				EndIf
			ElseIf lOk .And. lTMSOPdg .And. DTR->DTR_CODOPE == '03'
				// Estorno Fechamento
				DTR->(DbSetOrder(1))
				If DTR->( MsSeek( xFilial('DTR')+ DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM ) ) .And. lOk .AND. lDTRAtu
					
					cWhile	:= xFilial('DTR')+ DTQ->( DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM )

					While !DTR->(EOF()) .AND. xFilial('DTR') + DTR->DTR_FILORI + DTR->DTR_VIAGEM == cWhile .AND. lOk .AND. ( !Empty(DTR->DTR_PRCTRA) .OR. !Empty(DTR->DTR_IDPDG) )
						cNumIdOpe	:= DTR->DTR_PRCTRA
						cNumIdPdg	:= DTR->DTR_IDPDG
						cNumCIOT	:= DTR->DTR_CIOT
						lCiotAgre   := DTR->DTR_TPCIOT == '2'
						
						//Posiciona na tabela de veículos.
						DA3->( DbSetOrder(1) )
						DA3->( MsSeek( xFilial('DA3') + DTR->DTR_CODVEI ) )

						CursorWait()
						MsgRun( STR0034,; //-- 'Realizando comunicacao com a Operadora...'
								STR0035,; //-- 'Aguarde...'
								{ || lOk := PgBContrat( DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, nOpcx, @aMsgErr, "", @cNumIdOpe, @cNumIdPdg, DTR->DTR_ITEM, @cNumCIOT, @lCancCiot, @lIncCiot ) } )
						CursorArrow()

						AAdd( aRegDTR, { cNumIdOpe, cNumIdPdg, DTR->DTR_ITEM, cNumCIOT, lCiotAgre, lIncCiot, lCancCiot } )

						DTR->( DbSkip() )
					EndDo

					If !lOk .And. !Empty(aMsgErr)
						TmsMsgErr( aMsgErr )
					EndIf
				EndIf
			EndIf

			If AliasInDic("DN1") .And. ExistFunc("TM310PrcFe")
				lOk := TM310PrcFe(nOpcx,1,@lCont)
			EndIf
 
			If lOk
				Processa( { || lOk:= TMSA310Est( cFilOri, cViagem, lVgeInter ) }, STR0014 ) //'Estornando Fechamento da Viagem'
			EndIf

			If lOk .And. lCont .And. AliasInDic("DN1") .And. ExistFunc("TM310PrcFe")
				lOk := TM310PrcFe(nOpcx,2,@lCont)
			EndIf

			//-- Caso exista viagem interliga, atualiza os pesos no registro de entradas/saidas.
			If lOk .And. lVgeInter
				DUV->(DbSetOrder(4))
				If DUV->(MsSeek(xFilial("DUV")+DTR->DTR_FILVGE+DTR->DTR_NUMVGE))
					aPesoVge:= TMSPesoVge(DTR->DTR_FILORI,DTR->DTR_VIAGEM)
					RecLock("DUV",.F.)
						DUV->DUV_PESO   := DUV->DUV_PESO   - aPesoVge[1]
						DUV->DUV_PESOM3 := DUV->DUV_PESOM3 - aPesoVge[2]
						DUV->DUV_PESOST := DUV->DUV_PESOST - aPesoVge[4]
						DUV->DUV_PES3ST := DUV->DUV_PES3ST - aPesoVge[5]
					MsUnlock()
				EndIf
			ElseIf !lOk
				DisarmTransaction()
				// Este bloco deve gravar o id em casos onde 
				// o cancelamento da operação na Operadora de Frotas
				// não foi concluido com sucesso.
				
				DTR->(DbSetOrder(1))//DTR_FILIAL, DTR_FILORI, DTR_VIAGEM, DTR_ITEM
				For nX := 1 To Len(aRegDTR)
					If DTR->( MsSeek( xFilial('DTR') + DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM + aRegDTR[nX][3] ) ) .AND. DTR->DTR_CODOPE == "03"
						RecLock( "DTR", .F. )
							DTR->DTR_PRCTRA	:= aRegDTR[nX][1]
							DTR->DTR_IDPDG	:= aRegDTR[nX][2]
						DTR->( MsUnlock() )
						
						// Por ter ocorrido erro na integração preciso verificar se é CIOT Agregado foi aberto aRegDTR[nX][5] == .T.
						If aRegDTR[nX][5]
							// AAdd( aRegDTR, { cNumIdOpe, cNumIdPdg, DTR->DTR_ITEM, cNumCIOT, lCiotAgre, lIncCiot, lCancCiot } )
							// No estorno, por já ter CIOT ABERTO ou inclusão (lIncCiot) não preciso verificar a sua abertura
							// Se o CIOT foi CANCELADO (lCancCiot aRegDTR[nX][7] == .T.) preciso ajustar o STATUS da Tabela DJL 
							If aRegDTR[nX][7]
								TMSXJCiot( .F., aRegDTR[nX][4], DTR->DTR_CODVEI, DTR->DTR_DTFMCI, "9" )
							EndIf
						EndIf
						
					EndIf
				Next nX
				
			EndIf
		End Transaction
	EndIf
EndIf

RestArea( aAreaDUV )
RestArea( aAreaDTR )
RestArea( aAreaDTQ )
RestArea( aAreaDTX )
RestArea( aAreaDTW )
RestArea( aAreaDUA )
RestArea( aAreaDA3 )
RestArea( aArea )

//-- Destrava o registro
DTQ->(MsUnlock())

//-- Nao chama novamente a tela, qd for inclusao
MBRCHGLoop()

//-- Limpa marcas dos agendamentos
If !IsInCallStack("TMSAF76")
	TMSALimAge(StrZero(ThreadId(),20))
EndIf

Return lOk
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA310Est³ Autor ³ Richard Anderson      ³ Data ³22.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Estorno de Fechamento de Viagem                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA310Est(ExpC1,ExpC2,ExpL1)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Filial de Origem                                   ³±±
±±³          ³ ExpC2 = Viagem                                             ³±±
±±³          ³ ExpL1 = Viagem Interligada                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA310                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSA310Est( cFilOri, cViagem, lVgeInter )

	Local cSeek      := ""
	Local aAreaDTQ   := DTQ->( GetArea() )
	Local aAreaDT5   := DT5->( GetArea() )
	Local aAreaDT6   := DT6->( GetArea() )
	Local aAreaDTR	 := DTR->( GetArea() )
	Local aAreaDA3	 := DA3->( GetArea() )
	Local aAreaSDG	 := SDG->( GetArea() )
	Local lRet       := .T.
	Local aRot350    := { {,,0,1},{,,0,2},{,,0,3},{,,0,5},{,,0,6} } //-- Utilizada no estorno de Viagens Interligadas
	Local aRot310    := aClone(aRotina)
	Local lTMA310GRV := ExistBlock('TMA310GRV')
	Local lTMA310GER := ExistBlock('TMA310GER')
	Local cAtivCHG   := SuperGetMv("MV_ATIVCHG",," ") // Atividade de Chegada.
	Local cCodFav	 := ''
	Local cLojFav	 := ''

	// Controle de Diarias
	Local aItenEst    := {} 					// Recebe os itens do controle de diarias
	Local nCount      := 0 					// Recebe o Contador

	Local cMV_TMSRRE  := SuperGetMv("MV_TMSRRE" ,.F.,"") // 1=Calculo Frete, 2=Cotação, 3=Viagem, 4=Sol.Coleta, Em Branco= Nao Utiliza
	// Título e despesa de pedágio

	Local cPrefixo:= TMA250GerPrf(cFilAnt)
	Local aCodFav	:= {}
	Local cCodForn	:= ''
	Local cLojForn	:= ''
	Local cSeekSDG	:= ''

	Local lTMS3GFE    := Iif(FindFunction('TmsIntGFE'),TmsIntGFE('02'),.F.)
	Local cTMS3GFE    := SuperGetMV("MV_TMS3GFE",,"N")  //F-Fechamento Vge, S=Saida Vge, C=Chegada Vge,N=Nao Integra
	Local lMsgEnv	  := .F. //--Indica se a mensagem financeira já foi enviada ao datasul
	Local cMsgEaiErr  := ""
	Local aAreas      := {}
	Local cOriPdg	  := ""
	Local lMDFEAUT    := SuperGetMv('MV_MDFEAUT',,.F.) .And. ExistFunc("TmsMDFeAut") //--MDFe Automático 
	Local nMdfeExc    := SuperGetMv("MV_MDFEEXC", .F., 0   ) //-- Prazo em horas para cancelamento do MDF-e autorizado
	Local aMDFe, nHoras, cfunOld
	Local lContinua   := .T.
	Local aAreaSM0    := {}
	Local cFilBack	  := cFilAnt	
	Local lUFAtiv     := DTX->(ColumnPos("DTX_UFATIV")) > 0
	Local aAreaMDFe	  := GetArea() 
	Local lCmOnLine  := SuperGetMv("MV_CUSMED") == "O" //Custo médio online. Criado para tratar inconsistência do projeto SonarQube
	Local lCriaHeader:= lCmOnLine
	Local lTMSIntChk  := TableIndic("DM0") .And. SuperGetMV("MV_TMAPCKL",,.F.) .And. SuperGetMV("MV_TMINTEV",,"") == "1" .And. ExistFunc("TMSIntChk")
    Local cMomGerAdi  := '' // 0 Geração da Viagem 1 Fechamento da Viagem
    Local aRetForn    := {}
	Local aSX5		  := {}
	Local cTipVeiFor  := ""
	Local lPerAdto    := ""
	Local aCabSDG	  := {} 

	//-- Executa ponto de entrada antes de efetuar o estorno
	If	lTma310Grv
		lContinua := ExecBlock('TMA310GRV',.F.,.F., {5, cFilOri, cViagem} )
		If ValType(lContinua) <> "L"
			lContinua := .F.
		EndIf
		If !lContinua
			Return .F.
		EndIf
	EndIf

	Begin Transaction

		If cTMSERP == "0" .And. DTQ->DTQ_SERTMS $ "2;3" // Transporte;Entrega
			ProcRegua( 2 )
			IncProc()
			// Cancela baixa do estoque dos documentos da viagem
			lRet := TMSDelBxEst( cFilOri, cViagem )
		Else
			ProcRegua( 1 )
		EndIf

		IncProc()

		If lRet

			// Exclui Operacoes de Transporte
			DTW->( DbSetOrder( 1 ) )
			DTW->( MsSeek( cSeek := xFilial( 'DTW' ) + cFilOri + cViagem ) )
			While DTW->DTW_FILIAL+DTW->DTW_FILORI+DTW->DTW_VIAGEM == cSeek

				// Verifica se a Operacao foi Gerada pelo Fechamento de Viagem e pela Filial Atual
				If DTW->DTW_TIPOPE <> StrZero(2, Len(DTW->DTW_TIPOPE)) .Or. DTW->DTW_FILATU <> cFilAnt
					DTW->(dbSkip())
					Loop
				EndIf

				//-- Caso exista viagem interligada, estorna operacoes da viagem atual
				If lVgeInter
					If DTW->DTW_STATUS == StrZero( 2, Len( DTW->DTW_STATUS ) ) // Encerrado
						aRotina := aClone(aRot350)
						TMSA350Est( "DTW", DTW->(RecNo()), 4, lVgeInter )
						aRotina := aClone(aRot310)
					EndIf
				EndIf

				RecLock( 'DTW', .F. )
				DbDelete()
				MsUnLock()
				DTW->( DbSkip() )
			EndDo

			//--Exclui as Operações por Documento - DLT
			If TableInDic("DLT")
				DLT->(DbSetOrder(1))
				DLT->( MsSeek( cSeek := xFilial("DLT")+ cFilOri + cViagem ) ) 	
				While !DLT->(Eof()) .And. DLT->( DLT_FILIAL + DLT->DLT_FILORI  + DLT->DLT_VIAGEM ) == cSeek
					Reclock('DLT',.F.)
					DLT->(DbDelete())
					DLT->(MsUnLock())
					DLT->(DbSkip())
				EndDo
			EndIf  
			
			// Atualizar viagem
			RecLock("DTQ",.F.)
			DTQ->DTQ_DATFEC := CriaVar( "DTQ_DATFEC", .F. )
			DTQ->DTQ_HORFEC := CriaVar( "DTQ_HORFEC", .F. )
			If !Empty(DTQ->DTQ_FILATU) .And. DTQ->DTQ_FILATU <> DTQ->DTQ_FILORI
				DTQ->DTQ_STATUS := StrZero( 4, Len( DTQ->DTQ_STATUS ) ) // Chegada Em Filial
			Else
				DTQ->DTQ_STATUS := StrZero( 1, Len( DTQ->DTQ_STATUS ) ) // Em Aberto
			EndIf

			DTQ->DTQ_IDCLI := " "

			MsUnLock()

			//-- Estorna as operacoes canceladas
			DTW->(dbSetOrder(3))
			DTW->(MsSeek( cSeek := xFilial('DTW')+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM))
			While DTW->(! Eof() .And. DTW_FILIAL+DTW_FILORI+DTW_VIAGEM == cSeek )
				If DTW->DTW_STATUS == StrZero( 9, Len(DTW->DTW_STATUS)) .And. ;
						( Empty(DTW->DTW_FILATI) .Or. DTW->DTW_FILATI == cFilAnt ) .And. ;
						DTW->DTW_ATIVID <> cAtivCHG // Cancelado ### Chegada de Viagem
					DTW->( RecLock('DTW',.F.) )
					DTW->DTW_DATREA := CriaVar('DTW_DATREA', .F.)
					DTW->DTW_HORREA := CriaVar('DTW_HORREA', .F.)
					DTW->DTW_STATUS := StrZero(1,Len(DTW->DTW_STATUS))	//-- Aberto
					DTW->( MsUnLock() )
				EndIf
				DTW->(dbSkip())
			EndDo

			//--- Estorno dos Bloqueios RRE
			If "3" $ cMV_TMSRRE
				TMA310EstR(5)   //5- Indica que é um Estorno do Fechamento
			EndIf

			//----------------------------------------------------------------------
			//-- RENTABILIDADE PREVIA
			//----------------------------------------------------------------------
			If AliasInDic("DL3")
				A310Rentab( DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM,5)
			EndIf
		
			//-- Tratamento De Custeio De Viagens De Coleta
			If DTQ->DTQ_SERTMS $ '1/3' //-- Coleta/Entrega

				//-- Limpa Referências De Valorização da Coleta
				Tmsa310LVC( DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, .t. , .t. )

			EndIf

			//-- Executa ponto de entrada depois da gravacao do estorno
			If	lTma310Ger
				ExecBlock('TMA310GER',.F.,.F., {5, cFilOri, cViagem} )
			EndIf

			// Estorno do controle de diarias
			aItenEst := A310DiaEst(cFilOri, cViagem)
			For nCount := 1 To Len(aItenEst)

				If !TMSAB30ESI(aItenEst[nCount][1],aItenEst[nCount][2],aItenEst[nCount][3])
					DisarmTransaction()
				Endif

			Next nCount

			// Exclui O Percurso de viagem
			If AliasIndic("DL0") .AND. FindFunction("AF16IncPer")

				dbSelectArea("DL0")
				DL0->(dbSetOrder(2))
				If DL0->(MsSeek( FWxFilial("DL0")+cFilOri+cViagem ))
					DL0->(MsSeek( FWxFilial("DL0")+cFilOri+cViagem + Replicate("Z",Len(DL0->DL0_PERCUR)),.T.))
					DL0->(DbSkip(-1))
					AF16IncPer(5,,,.T.,) // Exclui o Registro.
				EndIf

			EndIf

			//--- Chama integração TMS x GFE

			If lRet .And. ( (DTQ->DTQ_TIPVIA <> StrZero(5,Len(DTQ->DTQ_TIPVIA)) .And. lTMS3GFE .And. cTMS3GFE == 'F') .Or. (DTQ->DTQ_TIPVIA == StrZero(5,Len(DTQ->DTQ_TIPVIA)) .And. cTMSRDPU == 'F') ) //Fechamento da Viagem
				aAreas:=GetArea()
				lRet:= Tms3GfeInt(cFilOri, cViagem, .F., .T.)
				RestArea(aAreas)
				If !lRet
					DisarmTransaction()
				EndIf
			EndIf

			If lRet
				
				Pergunte("TM250D",.F.)
				// mv_par01 - Mostra lancamentos contabeis
				// mv_par02 - Aglutina lancamentos contabeis
				// mv_par03 - Contabiliza on-line
				lExibeLanc:= If(mv_par01 == 1,.T.,.F.)  //-- Mostra Lanctos. Contabeis ?
				lAglutina := If(mv_par02 == 1,.T.,.F.)  //-- Aglutina Lanctos. Contabeis ?
				lOnline   := If(mv_par03 == 2,.F.,.T.)
				nHdlPrv	:= 0
				nTotal	:= 0
				aRecSDGEmi := {}
				aRecSDGBai := {}
				// Verifica se o custo medio e' calculado On Line
				If lCmOnLine
					// Se necessario cria o cabecalho do arquivo de prova
					If lCriaHeader
						lCriaHeader := .F.
						cArquivo:= ""
						aSX5 := FWGetSX5("09","TMS")
						cLoteCTC:=IIF(!Empty(aSX5),aSX5[1][4],"TMS ")
						nHdlPrv := HeadProva(cLoteCTC,"TMSA310",cUserName,@cArquivo)

						If nHdlPrv < 0
							Help(" ",1,"SEM_LANC") //"Nao foi possivel abrir o arquivo de Contra Prova"
							cFilAnt := cFilAntBkp
							lRet := .F.
							If !lRet
								DisarmTransaction()
							EndIf
						EndIf
					EndIf
				EndIf

				//--Estorno dos títulos de pedágios e despesas geradas a partir do fechamento da viagem
				DTR->(dbSetOrder(1))
				If DTR->(dbSeek(FwxFilial('DTR')+cFilOri+cViagem)) .And. lRet
					While DTR->(!Eof()) .And. DTR->(DTR_FILIAL+DTR_FILORI+DTR_VIAGEM) == FwxFilial('DTR')+cFilOri+cViagem
						cOriPdg := AllTrim(DTR->DTR_ORIPDG)
						If DTR->DTR_TITPDG == '1' .And. cOriPdg == 'TMSA310' .Or. DTR->DTR_PRVFRE > 0

							aCodFav := T250BscFav(DTR->DTR_CODVEI,DTR->DTR_CODFOR,DTR->DTR_LOJFOR,DTR->DTR_FILORI,DTR->DTR_VIAGEM )	// retorna o codigo do Favorecido
							If Empty(aCodFav)
								cCodForn := DTR->DTR_CODFOR
								cLojForn := DTR->DTR_LOJFOR
							Else
								cCodForn := aCodFav[1][1]
								cLojForn := aCodFav[1][2]
							EndIf
							
							cTipVeiFor  := POSICIONE( "DA3", 1, FWxFilial("DA3")+ DTR->DTR_CODVEI , "DA3_TIPVEI")

							//| busca o contrato considerando o tipo de veículo da viagem
							aRetForn := TMSContrFor(cCodForn,cLojForn,,DTQ->DTQ_SERTMS,DTQ->DTQ_TIPTRA,.F.,cTipVeiFor,DTQ->DTQ_TPOPVG)

							//| busca o contrato sem considerar o veículo
							If Len(aRetForn) <= 0
								//| busca o contrato considerando o tipo de veículo da viagem
								aRetForn := TMSContrFor(cCodForn,cLojForn,,DTQ->DTQ_SERTMS,DTQ->DTQ_TIPTRA,.F.,,DTQ->DTQ_TPOPVG)
							EndIf

							If Len(aRetForn) > 0
								cMomGerAdi := aRetForn[1][13]  // 0 Geração da Viagem 1 Fechamento da Viagem
							EndIf

							lRet := TMA250DelTit( cPrefixo, cViagem, , cCodForn, cLojForn, , , , , , , @cMsgEaiErr, 2, cMomGerAdi )

							lMsgEnv :=  cTMSERP == '1' .And. lRet //--Indica que a mensagem já foi enviada							

							If lRet
								lPerAdto:= Iif(DTR->DTR_PERADI > 0,.T.,.F.)

								A250DelSDG( cFilOri, cViagem, DTR->DTR_CODVEI, cPrefixo, cCodForn, cLojForn, , , , , lPerAdto, "TMSA310", "2" )
							EndIf

							If lRet

								DTR->(RecLock("DTR",.F.))
								DTR->DTR_TITPDG := Space(Len(DTR->DTR_TITPDG))
								DTR->DTR_ORIPDG := Space(Len(DTR->DTR_ORIPDG))								
								If cMomGerAdi = '1' .And. lPerAdto
									DTR->DTR_ADIFRE := 0
									DTR->DTR_TITADI := '2'
								EndIf
								DTR->(MsUnLock())

							EndIf
						EndIf

						SDG->(dbSetOrder(5))
						DA3->(dbSetOrder(1))
						cSeekSDG := FwxFilial('SDG')+DTR->(DTR_FILORI+DTR_VIAGEM+DTR_CODVEI)
						If SDG->(MsSeek(FwxFilial('SDG')+DTR->(DTR_FILORI+DTR_VIAGEM+DTR_CODVEI)))
							While SDG->(!Eof()) .And. SDG->(DG_FILIAL+DG_FILORI+DG_VIAGEM+DG_CODVEI) == cSeekSDG
								If SDG->DG_TITGER == '1' .And. Upper(AllTrim(SDG->DG_ORITIT)) == 'TMSA310'
									If DA3->(Msseek(FwxFilial('DA3')+DTR->DTR_CODVEI))

										//-- Se o Credor do Adiantamento nao for o proprietario do veiculo
										If DTR->(DTR_CREADI+DTR_LOJCRE) <> cCodForn+cLojForn
											cCodForn := DTR->DTR_CREADI
											cLojForn := DTR->DTR_LOJCRE
										Else
											cCodForn := DA3->DA3_CODFOR
											cLojForn := DA3->DA3_LOJFOR
											If !Empty (aCodFav := T250BscFav(DTR->DTR_CODVEI,cCodForn,cLojForn,DTR->DTR_FILORI,DTR->DTR_VIAGEM))// retorna o codigo do Favorecido
												cCodFav := aCodFav[1][1]
												cLojFav := aCodFav[1][2]
											EndIf
										EndIf

										If !lMsgEnv //--Se a Mensagem ainda não foi enviada ao ERP Datasul
											lRet := TMA250DelTit(cPrefixo, DTR->DTR_VIAGEM, ,cCodForn, cLojForn, cCodFav, cLojFav, SDG->DG_PARC,,,,@cMsgEAIErr)
										EndIf
										If lRet
											//--Atualiza o SDG informando que o adiantamento não está com o título gerado.
											
											FwFreeArray( aCabSDG )
											aCabSDG	:= {} 
											Aadd( aCabSDG , { "DG_TITGER", Space(Len(SDG->DG_TITGER)) , Nil } )
											Aadd( aCabSDG , { "DG_ORITIT", Space(Len(SDG->DG_ORITIT)) , Nil } )
											AtuTabSDG( acabSDG , 4 )

											Reclock('DTR',.F.)
												DTR->DTR_TITADI := Space(Len(DTR->DTR_TITADI))
												If cMomGerAdi = '1'
													DTR->DTR_ADIFRE := 0
													DTR->DTR_TITADI := '2'
												EndIf
											MsUnLock()
										EndIf
									EndIf
								EndIf
								SDG->(dbSkip())
							EndDo
						EndIf
						DTR->(dbSkip())
					EndDo

					// Verifica se o custo medio e' calculado On Line se
					If lCmOnLine .And. nTotal > 0
						// Se ele criou o arquivo de prova ele deve gravar o rodape'
						RodaProva(nHdlPrv,nTotal)

						// Envia para Lançamento Contabil
						cA100Incl( cArquivo, nHdlPrv, 3, cLoteCTC, lExibeLanc, lAglutina )
					EndIf

				EndIf

				//-- Mensagem de falha de integração do EAI
				If cTMSERP == "1" .And. !Empty(cMsgEAIErr)
				     Help(" ", 1, "TM310-EAI-01",, cMsgEaiErr, 2, 4) // Mensagem retornada pelo EAI Datasul...
				EndIf
			EndIf
		Else
			Help( " ", 1, "TMSA31012",, cFilOri+'/'+cViagem, 2, 8 ) // Nao foram encontrados documentos para a Viagem
		EndIf

	End Transaction

	If (lMdfeAut .Or. ExistFunc("TmsAutViag")) .And. FindFunction("TMA190Srv") .And. lRet //Verifica o serviço de transporte da viagem
		lMdfeAut:= TMA190Srv(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM)
	EndIf

	If lRet .And. lMDFEAUT
		aMDFe := {}
		DTX->(DbSetOrder(5)) //-- DTX_FILIAL+DTX_FILORI+DTX_VIAGEM+DTX_CODVEI
		DTX->(MsSeek(xFilial("DTX") +  DTQ->(DTQ_FILORI+DTQ_VIAGEM) ))
		WHile DTX->(!Eof()) .And. DTX->(DTX_FILIAL+DTX_FILORI+DTX_VIAGEM) == xFilial("DTX")+ DTQ->(DTQ_FILORI+DTQ_VIAGEM)
			//-- Conta a qtde de horas desde a emissão do MDF-e
			nHoras := Round(SubtHoras( DTX->DTX_DATMAN, ;
			                           SubStr(DTX->DTX_HORMAN,1,2) + ":" + SubStr(DTX->DTX_HORMAN,3,2) , ;
									   Date(), 		  SubStr(Time(),1,2)		  + ":" + SubStr(Time(),4,2) ),2) //Prazo em Horas

			//-- Se estiver dentro do prazo para cancelamento, ou rejeitado ou não transmitido, exclui e transmite cancelamento
			If DTX->DTX_TIPMAN  <> '2' .Or.  DTX->DTX_STIMDF == '0' .Or. DTX->DTX_STIMDF == '3' .Or. nHoras <=  nMdfeExc 
				// Salva Variaveis de ambiente
				cfunOld := FunName()
				SaveInter()
				aAreaMDFe := DTX->(GetArea())

				RegToMemory("DTQ",.F.)
				SetFunName("TMSA190")
				aRotina := {	{ ""  ,"", 0, 1 },;
								{ ""  ,"", 0, 2 },;
								{ ""  ,"", 0, 3 },;
								{ ""  ,"", 0, 4 },;
								{ ""  ,"", 0, 5 } }

				//-- Exclui o MDF-e
				lRet := TmsA190Mnt("DTX", DTX->(Recno()), 5, DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM,,.F.,,.T.)

				//-- Restaura variáveis de ambiente
				RestInter()
				SetFunName(cfunOld)
				RestArea(aAreaMDFe)
				
			//-- Se já passou do prazo para cancelamento do MDF-e, encerra-o
			Else
				Aadd(aMDFe,{DTX->DTX_FILMAN,;
							DTX->DTX_MANIFE,;
							DTX->DTX_MANIFE,;
							DTX->DTX_SERMAN,;
							DTX->DTX_VIAGEM,;
							Iif(lUFAtiv, DTX->DTX_UFATIV, '')})
			EndIf

			DTX->(DbSkip())
		EndDo
		If !Empty(aMDFe)
			//-- Alterar o conteudo da variavel cFilAnt		
			aAreaSM0  := SM0->( GetArea() )												
			cFilAnt   := Posicione('SM0',1,cEmpAnt+aMDFe[Len(aMDFe),1],'FWCODFIL()')														
			lContinua := TmsMDFeAut(aMDFe, 2) //--Encerra o Manifesto   
			If lContinua
				TmsLimpDUD(DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM,aMdfe)	//--Limpar a DUD
			EndIf 								         
			cFilAnt := Posicione('SM0',1,cEmpAnt+cFilBack,'FWCODFIL()') 
			RestArea(aAreaSM0)
		EndIf
	EndIf

	If (DTQ->DTQ_SERTMS == "1" .Or. DTQ->DTQ_SERTMS == "3") .And. lTMSIntChk .And. lRet	//-- Somente para viagem de coleta ou entrega # Existe Check List configurado, o estorno é no fechamento da viagem !!
		EstDocChk( DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM )
	EndIf

	RestArea( aAreaDT5 )
	RestArea( aAreaDT6 )
	RestArea( aAreaDTQ )
	RestArea( aAreaSDG )
	RestArea( aAreaDTR )
	RestArea( aAreaDA3 )

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA310Grv³ Autor ³ Alex Egydio           ³ Data ³26.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gravacao                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA310Grv()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA310                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TMSA310Grv(nOpcx,lFecAuto,lHelpAuto,dDatFec,cHorFec) 

Local aAreaAnt	  := GetArea()
Local aAreaDA8	  := DA8->( GetArea() )
Local aAreaDC5	  := DC5->( GetArea() )
Local aAreaDC6	  := DC6->( GetArea() )
Local aAreaDT5	  := DT5->( GetArea() )
Local aAreaDT6 	  := DT6->( GetArea() )
Local aAreaDUV    := DUV->( GetArea() )
Local aAreaDTR    := DTR->( GetArea() )
Local aAreaDA3    := DA3->( GetArea() )
Local aAreaDUD    := {}
Local aAreaDUP    := {}
Local aAreaDA4    := {}
Local cSeekDC5	  := ''
Local cHoraPre	  := ''
Local dDataPre	  := dDataBase
Local nSequen	  := 0
Local lRet        := .T.
Local aCab        := {}
Local aFilDCA     := {}
Local aServic     := {}
Local aMsgErr	  := {}
Local cAtivChg    := GetMv('MV_ATIVCHG',,'')
Local cAtivSai    := GetMv('MV_ATIVSAI',,'')
Local cAtvChgCli  := SuperGetMv('MV_ATVCHGC',,'')
Local cAtvSaiCli  := SuperGetMv('MV_ATVSAIC',,'')
Local cAtvSaiApo  := SuperGetMv('MV_ATVSAPA',,'')   //-- Atividade de Saida do Ponto de Apoio
Local cAtvChgApo  := SuperGetMv('MV_ATVCHPA',,'')   //-- Atividade de Chegada no Ponto de Apoio
Local cAtivDca    := GetMv('MV_ATIVDCA',,'')
Local cAtivRta    := GetMv('MV_ATIVRTA',,'')
Local cAtivRtp    := GetMv('MV_ATIVRTP',,'')
Local cVeiGen     := GetMv('MV_VEIGEN' ,,'') // Veiculo generico.
Local cMotGen     := GetMv('MV_MOTGEN' ,,'') // Motorista generico.
Local nA          := 0
Local nB          := 0
Local nC          := 0
Local lAtivSai    := .T.
Local lAtivChg    := .T.
Local lAtivOk     := .T.
Local lAtivOk1    := .T.
Local lAtivOk2    := .T.
Local lAtivDca    := .T.	//-- Atividade de Descarregamento
Local lAtivRta    := .T.	//-- Atividade de Retorno de Aeroporto
Local lAtivRtp    := .T.	//-- Atividade de Retorno de Porto
Local aOcorrenc   := {}
Local lContinua   := .T.
Local cSeekDTW    := ''
Local aPesoVge    := {}
Local dDatIni     := CtoD("  /  /  ")
Local cHorIni     := ""
Local dDatRea     := CtoD("  /  /  ")
Local cHorRea     := ""
Local aOldAreaDTQ := {}
Local lTMA310GRV  := ExistBlock('TMA310GRV')
Local lTMA310DTW  := ExistBlock('TMA310DTW')
Local cOcoRee     := SuperGetMv('MV_OCORREE',,'') //-- Quais ocorrencias geram reentrega
Local nSeqOco     := 0
Local nQtdOco     := 0
Local cLoteAut    := ""
Local cDocRee     := ""
Local aPerfil     := {}
Local cCdrOri     := AllTrim(SuperGetMv('MV_CDRORI',,''))
Local aLoteAut    := {}
Local nSeek       := 0
Local cDocTMS     := SuperGetMv('MV_TPDCREE',,'')   //-- Quais doctos geram reentrega
Local lUsaNfs     := SuperGetMv('MV_TMSUNFS',,.F.)  //-- Filial utiliza nota fiscal ?
Local aDocImp     := {}
Local aRotAnt     := {}
Local lTMA310GER  := ExistBlock('TMA310GER')
Local nPCanOp     := GetMv('MV_PCANOP',,1) // Opcoes para o param. MV_PCANOP: 0-Cancelar Operacao/1-Pergunta sobre o Canc./2-Nao Cancela
Local lPergOp     := nPCanOp == 1          // Exibe pergunta(Cancela operacoes Sim/Nao)
Local lCancelaDTW := .F.
Local cCmpEnt     := GetMV("MV_COMPENT")
Local cQuery      := ""
Local cAliasNew   := ""
Local aDocCarr    := {} // Documentos que nao foram carregados
Local aRetPE      := {}
Local lTM310FFL	  := ExistBlock("TM310FFL")
Local lAddServic  := .T.
Local lLotExpress := TmsExp()
Local lRetExp	  := .T.
Local cNumLot	  := ""
Local aLotes      := {}
Local aLotes2     := {}
Local nCur1		  := 0
Local cChaveViag  := ''
Local cCodOpe	  := ''
Local cNumIdOpe	  := ''
Local oDadosViag  := Nil
Local aClientes	  := {}
Local aTempCli    := {}
Local nTempCli
Local aDocs		  := {}
Local nTamCliente := 0
Local nCntCli	  := 0
Local lOperCli		:= Len(GetSrcArray("TMSXFUNX.PRW")) > 0 
Local lVldOPeCli  := .T. //Variável que controla a geração de operações sem o remetente informado na solcitação de coleta.
Local cRoteir 	  := ""

//-- Integração via EAI
Local cEAIMsg       := ""
Local lGrvIdOpe		:= .F.
//-- Redespacho
Local lDt2TIPRDP  := DT2->(FieldPos('DT2_TIPRDP'))>0
Local nCnt        := 0

Local lAutRee     := .T.
Local lTM310AUT   := ExistBlock("TM310AUT")

Local lOcorRee    := .F.
Local aOcoRetNf   := {}

//Diarias do Motorista
Local cCodDia 		:= ""			// Recebe o Codigo da diaria
Local nRecPar 		:= 0			// Recebe o Recno da Parametrização corrente
Local cCodCtrDia	:= ""			// Recebe o codigo do controle de diaria
Local aItensDia		:= {}			// Recebe os itens inseridos no controle de diarias
Local aCmpLot		:= {}
Local aInfDT8		:= {}
Local lRotaAut		:= FindFunction("F11RotRote") .AND. F11RotRote(DTQ->DTQ_ROTA)
Local nTamRotGer	:= 0
Local nCntRot		:= 0
Local lIncSerCli	:= .F. //--Variável de controle para determinar se já foi incluído o serviço para as atividades de chegada e saída do cliente(ROTA AUTOMÁTICA)
Local aServCli		:= {}
Local lFirstFil		:= .F. //-- Qdo utilizado Roteiro com saída e chegada em cliente e o primeiro cliente do roteiro é uma filial
Local lLastFil 		:= .F. //-- Qdo utilizado Roteiro com saída e chegada em cliente e o último cliente do roteiro é uma filial
Local aSM0			:= FWLoadSM0()
Local cMV_TMSRRE    := SuperGetMv("MV_TMSRRE" ,.F.,"") // 1=Calculo Frete, 2=Cotação, 3=Viagem, 4=Sol.Coleta, Em Branco= Nao Utiliza
Local lTabRRE       := AliasIndic("DJA")

//--Geracao Título de Pedágio no fechamento da viagem
Local aRetForn	    := {} //--Retorno do Contrato de Fornecedor
Local aForn		    := {} //--Fornecedores da viagem que terão o título de pedágio gerados no SE2 - Contas a Pagar.
Local lGeraSDG	    := .F. //--Informa se o custo do pedágio será gerado na rotina de geração do título do pedágio
Local cDesPDG 	    := Padr( GetMV("MV_DESPDG"), Len( DT7->DT7_CODDES ) ) // Codigo de Despesa de Pedagio
Local cDesAdf       := Padr( SuperGetMV('MV_DESADF',,''), Len( DT7->DT7_CODDES ) ) //-- Despesa para lancamento de Adto. de Frete
Local nItemSDG	    := 1
Local cBxTitPdg	    := '' //--Informa se a baixa do titulo de pedágio será realizada automaticamente.
Local cCodForn	    := ''
Local cLojForn	    := ''
Local cDocSDGPDG	:= ''

//-- Calculo frete previsto
Local aTabPag		:= {}
Local nTab			:= 1
Local cTabFre		:= ""
Local cTipTab		:= ""
Local cTabCar		:= ""
Local nMaxCus		:= 0
Local aFrete		:= {}
Local nGrupVei		:= 0
Local aDiaHist		:= {}
Local cSerOld		:= ""
Local aTabPagCar	:= {}
Local nLinha		:= 0
Local aFornec		:= {}
Local nCnt2			:= 1
Local nFretePrev	:= 0
Local cFilOri		:= ""
Local cViagem		:= ""
Local lRentab		:= .F.
Local lTMS3GFE      := Iif(FindFunction('TmsIntGFE'),TmsIntGFE('02'),.F.)
Local cTMS3GFE      := SuperGetMV("MV_TMS3GFE",,"N")  //F-Fechamento Vge, S=Saida Vge, C=Chegada Vge,N=Nao Integra
Local cTipVeiFor    := "" //|Utilizado para buscar o contrato do fornecedor na tabela DVG
Local cCodVeiFor    := "" //|Utilizado para buscar o contrato do fornecedor na tabela DVG
Local nVrPerAdi     := 0
Local aVlrAdiFrt	:= {}
Local cAliasDUD     := ""
Local aRet          := {}
Local aAreas        := {}
Local aMDFe         := {}
Local aManifes      := {}	
Local cCodUFCAL     := ''
Local lTipOpVg      := DTQ->(ColumnPos("DTQ_TPOPVG")) > 0
Local nCont		    := 0	
Local nResult		:= 0
Local lMDFeAut      := SuperGetMV("MV_MDFEAUT",,.F.)  .And. ExistFunc("TmsMDFeAut") //--MDFe Automatico
Local lUFAtiv		:= DTX->(ColumnPos("DTX_UFATIV")) > 0
Local cOpeDoc		:= ""
Local lcriaDLT		:= .F. 
Local lIdDTW		:= DTW->(ColumnPos("DTW_IDDTW")) > 0
Local cIdDTW		:= ""
Local nAux			:= 0
Local aCabDTW		:= {}
Local lTMSIntChk    := TableIndic("DM0") .And. SuperGetMV("MV_TMAPCKL",,.F.) .And. SuperGetMV("MV_TMINTEV",,"") == "1" .And. ExistFunc("TMSIntChk")
Local aDocsChk      := {}
Local aRetEnv       := {}
Local lVgeMod3      := Iif(FindFunction("TmsVgeMod3"),TmsVgeMod3(),.F.)
Local lContrAut     := .T.
Local aMsg			:= {}
Local aMsgChk 		:= {}
Local lAvisa 		:= !IsBlind()
Local aReenvC		:= {}
Local lSoCol        := .T.
Local lEstOk        := .F.
Local cNumCiot      := ""
Local cNumIdCli     := ""
Local cNumIdPdg     := ""
Local aCabSDG	    := {} 
Local lDTRAbast     := DTR->(ColumnPos("DTR_VLABST")) > 0
Local cDesABST      := Padr( SuperGetMV('MV_DESABST',,''), Len( DT7->DT7_CODDES ) ) // Codigo de Despesa de Abastecimento
Local aRetBkp		:= {}
Local aRegDTR		:= {}
Local nX			:= 0
Local lCodAut  := .F.

Local lOk       := .T.

Private oDTClass    := NIL

Default lFecAuto	:= .F.
Default lHelpAuto	:= .F.
Default dDatFec		:= dDataBase
Default cHorFec		:= StrTran(Left(Time(),5),':','')

If Type("aIndex") <> "A"
	aIndex := {}	
EndIf
If Type("cFiltro") <> "C"
	cFiltro:= ""
EndIf

DUY->(DbSetOrder(1))

//-- ExecBlock TM310OCO
//-- Ponto               : Apos obter as ocorrencias dos parametros MV_OCORREE
//-- Parametros Enviados : Array com a seguinte informacao:
//--                       PARAMIXB[01] = Codigo das ocorrencias que geram reentrega.
//--
//-- Retorno Esperado    : Array no seguinte formato:
//--                       aRetPE[01] = Codigo das ocorrencias que geram reentrega.
If ExistBlock('TM310OCO')
	aRetPE:= ExecBlock("TM310OCO",.F.,.F., {cOcoRee})
	If !Empty(aRetPE) .And. len(aRetPE) = 1
		If !Empty(aRetPE[1])
		   cOcoRee:=aRetPE[1]
		EndIf
	EndIf
EndIf

//-- Verifica se todos os documentos da viagem estão autorizados pelo SEFAZ
If nOpcx == 3 .And. DTQ->DTQ_SERTMS $ "2:3"
	//-- Tipos de documentos a analisar
	//-- '2' - "CTRC"
	//-- '6' - "CTRC Devolucao"
	//-- '7' - "CTRC Reentrega"
	//-- '8' - "CTRC Complemento"
	//-- '9' - "CTRC Retorno"
	//-- 'A' - "CTRC Cortesia"
	//-- 'E' - "CTRC Armazenagem"
	//-- 'M' - "CTRC Anulacao"
	//-- 'P' - "CTRC Anulacao"
	
	If (lMdfeAut .Or. ExistFunc("TmsAutViag")) .And. FindFunction("TMA190Srv")  //Verifica o serviço de transporte da viagem
		lMdfeAut:= TMA190Srv(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM)
	EndIf

	If lMDFeAut
		// Verifica se possui manifestos com cancelamento não transmitidos.
		If A210VCnMan(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,@aManifes,.T.)
			Return .F.
		EndIf
		
		// Verifica se possui manifestos com encerramento não transmitidos.
		If ExistFunc('A210VEnMan') .And. A210VEnMan(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,@aManifes,.T.)
			Return .F.
		EndIf	
	EndIf

	cAliasDUD := GetNextAlias()
	cQuery := "SELECT DUD_FILDOC,DUD_DOC,DUD_SERIE "
	cQuery += "  FROM " + RetSqlName("DUD") + " DUD "

	cQuery += "  INNER JOIN " + RetSqlName("DT6") + " DT6 "
	cQuery += "    ON DT6_FILIAL = '" + xFilial("DT6") + "' "
	cQuery += "   AND DT6_FILDOC = DUD_FILDOC "
	cQuery += "   AND DT6_DOC    = DUD_DOC "
	cQuery += "   AND DT6_SERIE  = DUD_SERIE "
	cQuery += "   AND (DT6_IDRCTE NOT IN  ('100','136') AND DT6_CHVCTG = '" + Space(Len(DT6->DT6_CHVCTG)) + "')"
	cQuery += "	  AND DT6_DOCTMS IN ('2','6','7','8','9','A','E','M','P') "
	cQuery += "   AND DT6.D_E_L_E_T_ = ' ' "

	cQuery += " INNER JOIN " + RetSqlName('DTP') + " DTP ON "
	cQuery += "       DTP.DTP_FILIAL = '"+ xFilial("DTP") +"'"
	cQuery += "   AND DTP.DTP_FILORI = DT6.DT6_FILORI "
	cQuery += "   AND DTP.DTP_LOTNFC = DT6.DT6_LOTNFC "
	cQuery += "   AND DTP.DTP_TIPLOT IN ('" + StrZero(3,Len(DTP->DTP_TIPLOT)) + "', '" + StrZero(4,Len(DTP->DTP_TIPLOT)) + "') "  //-- 3 - Eletronico -- 4 CTe Unico
	cQuery	+= "   AND DTP.D_E_L_E_T_ = ' ' "

	cQuery	+= " WHERE DUD_FILIAL = '" + xFilial("DUD") + "' "
	cQuery  += "   AND DUD_FILORI = '" + DTQ->DTQ_FILORI + "' "
	cQuery  += "   AND DUD_VIAGEM = '" + DTQ->DTQ_VIAGEM + "' "
	cQuery  += "   AND DUD_SERIE  <> 'COL' "
	cQuery	+= "   AND DUD.D_E_L_E_T_ = ' ' "

	cQuery 	:= ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGenQry(,,cQuery),cAliasDUD,.F.,.T.)

	If (cAliasDUD)->(!Eof())
		Aadd(aMsgErr,{STR0070,'00',''}) //--"Os documentos abaixo não foram autenticados pela SEFAZ."
		While (cAliasDUD)->(!Eof())
			Aadd(aMsgErr,{(cAliasDUD)->DUD_FILDOC + "/" + (cAliasDUD)->DUD_DOC + "/" + (cAliasDUD)->DUD_SERIE,'00',''})
			(cAliasDUD)->(DbSkip())
		EndDo
	EndIf
	(cAliasDUD)->(DbCloseArea())
	RestArea(aAreaAnt)

	If !Empty(aMsgErr)
		TmsMsgErr(aMsgErr)
		Return .F.
	EndIf
EndIf

//-- Tratamento Para Valorização Da Coleta
If DTQ->DTQ_SERTMS $ '1/3' //-- Coleta/Entrega
	
	//-- Inicializa o Controle Transacional
	Begin Transaction

	//-- Posiciona No Movimento Da Viagem
	DbSelectArea("DUD")
	DbSetOrder(2) //-- DUD_FILIAL+DUD_FILORI+DUD_VIAGEM+DUD_SEQUEN+DUD_FILDOC+DUD_DOC+DUD_SERIE
	MsSeek( FWxFilial("DUD") + DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM , .F. )
	
	DbSelectArea("DT5")
	DT5->(DbSetOrder( 4 )) //-- DT5_FILIAL+DT5_FILDOC+DT5_DOC+DT5_SERIE
	DbSelectArea("DT6")
	DT6->(DbSetOrder( 1 )) //-- DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE

	aCmpLot := {} //-- Inicializa Variável
	While !DUD->(Eof()) .And. (DUD->(DUD_FILIAL + DUD_FILORI + DUD_VIAGEM) == (FWxFilial("DUD") + DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM))

		If DUD->DUD_SERIE == "COL"

			If DT5->(MsSeek(FWxFilial('DT5')+DUD->DUD_FILDOC+DUD->DUD_DOC+DUD->DUD_SERIE)) .AND. DT6->(MsSeek(FWxFilial('DT6') + DUD->DUD_FILDOC + DUD->DUD_DOC + DUD->DUD_SERIE ) )
				lVigFret := If( !Empty(DT6->DT6_TABFRE) .AND. !Empty(DT6->DT6_TIPTAB), TMS310VgTF( DT6->DT6_TABFRE, DT6->DT6_TIPTAB ), .T. )
				If !lVigFret
					aAdd( aMsg ,{	DUD->DUD_VIAGEM,;  //-- 01
									DT6->DT6_FILDOC,;  //-- 02
									DT6->DT6_DOC   ,;  //-- 03
									DT6->DT6_SERIE ,;  //-- 04
									DT6->DT6_DATEMI,;  //-- 05
									DT6->DT6_CDRORI,;  //-- 06
									DT6->DT6_CDRDES,;  //-- 07
									DT6->DT6_CLIREM,;  //-- 08
									DT6->DT6_LOJREM,;  //-- 09
									DT6->DT6_CLIDES,;  //-- 10
									DT6->DT6_LOJDES,;  //-- 11
									DT6->DT6_NCONTR,;  //-- 12
									DT6->DT6_SERVIC,;  //-- 13
									DT6->DT6_CODNEG } )//-- 14
				EndIf
				//-- Somente Calcula Se Os Campos Forem Informados
				If !Empty(DT5->DT5_CODNEG) .And. !Empty(DT5->DT5_SERVIC) .AND. lVigFret

					//-- Inclui As NFs No Vetor
					If aScan( aCmpLot , DUD->DUD_DOC + DUD->DUD_SERIE ) == 0
						aAdd( aCmpLot , DUD->DUD_DOC + DUD->DUD_SERIE )
					EndIf
				EndIf
			EndIf
		EndIf

		DUD->(DbSkip())
	EndDo

	If Len(aMsg) > 0
		TMS310AVg( aMsg, lAvisa, .T. )
	EndIf
	//-- Se Houver Documentos Executa Rotina De Avaliação De Lote
	If Len(aCmpLot) > 0
		
		//-- Gera Lote DTP
		If Tmsa310Lot( DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, DTQ->DTQ_SERTMS, DTQ->DTQ_TIPTRA, @aLotes )

			//-- Carrega Vetor Secundário Com Os Lotes Gerados
			For nCur1 := 1 To Len(aLotes)

				If aScan( aLotes2 , aLotes[nCur1,19] ) == 0
					aAdd( aLotes2 , aLotes[nCur1,19] )
				EndIf

			Next nCur1
		EndIf

		//-- Executa Loop Para Todos Lotes Do Vetor
		For nCur1 := 1 To Len(aLotes2)

			cNumLot := aLotes2[nCur1]

			//-- Posiciona No Cadastro Do Lote
			DbSelectArea("DTP")
			DbSetOrder(1)	//-- DTP_FILIAL+DTP_LOTNFC
			If MsSeek( FWxFilial("DTP") + cNumLot , .F. ) .And. DTP->DTP_TIPLOT == '5' //-- Processa Somente Lotes De Coleta

				//-- Ajusta dados Do Lote
				RecLock("DTP", .F. )
				Replace DTP_STATUS With	'2' //-- Digitado
				DTP->(MsUnlock())

				//-- Processa o Cálculo Do Frete Para Valorização Dos Documentos Da Viagem
				TMSA200Mnt("DTP",DTP->(Recno()), 2 , Nil , .f. )

			EndIf

		Next nCur1

		//-- Verifica Se Valorizou Os Documentos Da Coleta
		If !(Tmsa310Vlr( DTQ->DTQ_FILORI , DTQ->DTQ_VIAGEM, .t. ))
			DisarmTransaction() //-- Estorna Criação Do Lote e Gravação Do Campo DUD_LOTE
			lRet := .F.
		Else

			//-- Gera Réplica da Tabela DT8
			//-- Posiciona No Movimento Da Viagem
			DbSelectArea("DUD")
			DbSetOrder(2) //-- DUD_FILIAL+DUD_FILORI+DUD_VIAGEM+DUD_SEQUEN+DUD_FILDOC+DUD_DOC+DUD_SERIE
			MsSeek( FWxFilial("DUD") + DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM , .F. )

			While !DUD->(Eof()) .And. (DUD->(DUD_FILIAL + DUD_FILORI + DUD_VIAGEM) == (FWxFilial("DUD") + DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM))

				If DUD->DUD_SERIE == "COL"

					aInfDT8 := {} //-- Inicializa Variável
					aAdd( aInfDT8, {'DT8_FILDOC'	, DUD->DUD_FILDOC })
					aAdd( aInfDT8, {'DT8_DOC'		, DUD->DUD_DOC    })
					aAdd( aInfDT8, {'DT8_SERIE'		, DUD->DUD_SERIE  })

					//-- Gera Réplica da Tabela DT8
					TmsAtuDJI( DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, '1', '1', aInfDT8, .f. )

				EndIf

				DUD->(DbSkip())
			EndDo
		EndIf
	EndIf

	//-- Finaliza Controle Transacional
	End Transaction
	If !lRet
		Return ( .F. )
	EndIf

EndIf

If lFecAuto
	//-- Habilita gravacao do LOG
	If ( Type("lMSErroAuto") <> "L" )
		lMSErroAuto := .T.
	EndIf
EndIf

If lHelpAuto
	//-- Grava Help´s em arquivo de LOG
	If ( Type("lMsHelpAuto") <> "L" )
		lMsHelpAuto := .T.
	EndIf
EndIf

If(	lLotExpress )
	DTP->(dbSetOrder(3)) //-- Busca lote da viagem.
	If ( DTP->(MsSeek(xFilial("DTP")+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM)) )
		//-- Verifica o tipo de lote se é eletrônico.
		If ( DTP->DTP_TIPLOT == "3" .Or. DTP->DTP_TIPLOT == "4")
			lRetExp := TMSA200Tra(.T.,DTP->DTP_FILORI,DTP->DTP_LOTNFC,,,,,"TMSA310")
		EndIf
	EndIf
EndIf

If (lRetExp)
	If DTQ->( SimpleLock() )
		RecLock('DTQ',.F. )
		DUD->(dbSetOrder(2))
		//-- Se Nao for Viagem Vazia e Nao Encontrar DUD (Documentos da Viagem)
		If DTQ->DTQ_TIPVIA == StrZero(1,Len(DTQ->DTQ_TIPVIA)) .And. !DUD->(MsSeek(xFilial('DUD')+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM))
			Help( " ", 1, "TMSA31012",, DTQ->DTQ_FILORI+'/'+DTQ->DTQ_VIAGEM, 2, 8 ) // Nao foram encontrados documentos para a Viagem
			DTQ->( MsUnLock() )
			Return ( .F. )
		EndIf

		If (DTQ->DTQ_FILATU == DTQ->DTQ_FILDES) .And. DTQ->DTQ_STATUS <> "1"
			Help("", 1, "TMSA31016") //O Fechamento nao sera realizado, pois a Viagem ja chegou no seu Destino Final.
			DTQ->( MsUnLock() )
			Return ( .F. )
		EndIf

		If DTQ->DTQ_SERTMS $ "2;3" //Transporte e Entrega
			//-- Nao Fazer o Fechamento da Viagem, se existirem Documentos ainda nao carregados,
			//-- ou seja,  DUD_STATUS igual a "1" ou "2".
			cQuery := ""
			cQuery := " SELECT DUD_FILDOC,DUD_DOC,DUD_SERIE "
			cQuery += "   FROM " + RetSqlName("DUD") + " DUD "
			cQuery += "  WHERE DUD_FILIAL  = '"+ xFilial("DUD")+"' "
			cQuery += "    AND DUD_FILORI  = '"+DTQ->DTQ_FILORI+"' "
			cQuery += "    AND DUD_VIAGEM  = '"+DTQ->DTQ_VIAGEM+"' "
			cQuery += "    AND DUD_STATUS  = '1' "
	   		cQuery += "    AND DUD_SERTMS <> '1' "
			cQuery += "    AND DUD.D_E_L_E_T_ = ' ' "
			cQuery    := ChangeQuery(cQuery)
			cAliasNew := GetNextAlias()
			DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.T.,.T.)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Nao efetuar fechamento se todos os documentos nao forem informado        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			While (cAliasNew)->(!Eof())
				aAdd(aDocCarr,{AllTrim((cAliasNew)->DUD_FILDOC+'-'+(cAliasNew)->DUD_DOC)+'-'+(cAliasNew)->DUD_SERIE,'01','TMSA500(.T.)'})
				(cAliasNew)->(dbSkip())
			EndDo
			If Len(aDocCarr) > 0
				If lFecAuto
					AutoGrLog(STR0036+DTQ->DTQ_FILORI+'-'+DTQ->DTQ_VIAGEM+STR0037)
					For nCnt := 1 To Len(aDocCarr)
						AutoGrLog(aDocCarr[nCnt,1])
					Next nCnt
				Else
					TmsMsgErr(aDocCarr,STR0036+DTQ->DTQ_FILORI+'-'+DTQ->DTQ_VIAGEM+STR0037) //-- Os documentos da viagem XX-XXXXXX relacionados abaixo, ainda não foram carregados
			  	EndIf

		   		(cAliasNew)->(dbCloseArea())
		   		DTQ->(MsUnLock())

				Return(.F.)
			Else
			   (cAliasNew)->(dbCloseArea())
			EndIf

			//-- Verifica se a viagem somente possui solicitações de coleta
			If lVgeMod3
				cAliasNew := GetNextAlias()
				cQuery := " SELECT COUNT(DUD_DOC) QTDDOC "
				cQuery += "   FROM " + RetSqlName("DUD") + " DUD "
				cQuery += "  WHERE DUD_FILIAL = '" + xFilial("DUD") + "' "
				cQuery += "    AND DUD_FILORI = '" + DTQ->DTQ_FILORI + "' "
				cQuery += "    AND DUD_VIAGEM = '" + DTQ->DTQ_VIAGEM + "' "
				cQuery += "    AND DUD_SERIE  <> 'COL' "
				cQuery += "    AND DUD.D_E_L_E_T_ = ' ' "
				cQuery := ChangeQuery(cQuery)
				DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasNew,.T.,.T.)
				If (cAliasNew)->(!Eof()) .And. (cAliasNew)->QTDDOC > 0
					lSoCol := .F.
			  	EndIf
		   		(cAliasNew)->(DbCloseArea())
	
				//-- Nao Fazer o Fechamento da Viagem, se existirem veículos utilizados na viagem sem nenhum documento carregado.
				If DTQ->DTQ_TIPVIA != StrZero(2,Len(DTQ->DTQ_TIPVIA)) .And. DTQ->DTQ_TIPVIA != StrZero(4,Len(DTQ->DTQ_TIPVIA)) .And. !lSoCol	//-- Vazia e Socorro
					aDocCarr  := {}
					cAliasNew := GetNextAlias()
					cQuery := " SELECT DTR_CODVEI "
					cQuery += "   FROM " + RetSqlName("DTR") + " DTR "
					cQuery += "  WHERE DTR_FILIAL = '" + xFilial("DTR") + "' "
					cQuery += "    AND DTR_FILORI = '" + DTQ->DTQ_FILORI + "' "
					cQuery += "    AND DTR_VIAGEM = '" + DTQ->DTQ_VIAGEM + "' "
					cQuery += "    AND DTR.D_E_L_E_T_ = ' ' "
					cQuery += "    AND NOT EXISTS (SELECT 1 "
					cQuery += "                      FROM " + RetSqlName("DTA") + " DTA "
					cQuery += "                     WHERE DTA_FILIAL = '" + xFilial("DTA") + "' "
					cQuery += "                       AND DTA_FILORI = '" + DTQ->DTQ_FILORI + "' "
					cQuery += "                       AND DTA_VIAGEM = '" + DTQ->DTQ_VIAGEM + "' "
					cQuery += "                       AND DTA_CODVEI = DTR_CODVEI "
					cQuery += "                       AND DTA.D_E_L_E_T_ = ' ') "
					cQuery := ChangeQuery(cQuery)
					DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasNew,.T.,.T.)
					While (cAliasNew)->(!Eof())
						Aadd(aDocCarr,{AllTrim((cAliasNew)->DTR_CODVEI),"01",""})
						(cAliasNew)->(DbSkip())
				  	EndDo
					If Len(aDocCarr) > 0
						If lFecAuto
							AutoGrLog(STR0079 + DTQ->DTQ_FILORI + "-" + DTQ->DTQ_VIAGEM + STR0080)
							For nCnt := 1 To Len(aDocCarr)
								AutoGrLog(aDocCarr[nCnt,1])
							Next nCnt
						Else
							TmsMsgErr(aDocCarr,STR0079 + DTQ->DTQ_FILORI + "-" + DTQ->DTQ_VIAGEM + STR0080) //-- Os veículos da viagem XX-XXXXXX relacionados abaixo, ainda não possuem documentos carregados.
						EndIf
		
				   		(cAliasNew)->(DbCloseArea())
				   		DTQ->(MsUnLock())
						Return(.F.)
					Else
				   		(cAliasNew)->(DbCloseArea())
					EndIf
	            EndIf
			EndIf

			//-- Ponto de Entrada
			If lTM310AUT
				lAutRee := ExecBlock('TM310AUT',.F.,.F.,{DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM})
				If ValType(lAutRee) <> "L"
					lAutRee := .F.
				EndIf
			Else
				lAutRee := .T.
			EndIf

			If lAutRee
				DTC->(dbSetOrder(3)) //DTC_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SERIE+DTC_SERVIC+DTC_CODPRO
				SD1->(dbSetOrder(1)) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
				SDA->(dbSetOrder(1)) //DA_FILIAL+DA_PRODUTO+DA_LOCAL+DA_NUMSEQ+DA_DOC+DA_SERIE+DA_CLIFOR+DA_LOJA
				DUA->(dbSetOrder(7)) //DUA_FILIAL+DUA_FILDOC+DUA_DOC+DUA_SERIE+DUA_SEQOCO

				DUD->(MsSeek(xFilial('DUD')+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM))
				Do While !DUD->(Eof()) .And. DUD->(DUD_FILIAL+DUD_FILORI+DUD_VIAGEM) == xFilial('DUD')+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM
					// Verifica se gera documento de reentrega
					lOcorRee := .F.
					If DUA->(dbSeek(xFilial("DUA")+DUD->DUD_FILDOC+DUD->DUD_DOC+DUD->DUD_SERIE))
						While !DUA->(Eof()) .And. DUA->DUA_FILDOC+ DUA->DUA_DOC+DUA->DUA_SERIE == DUD->DUD_FILDOC+DUD->DUD_DOC+DUD->DUD_SERIE
							If AllTrim(DUA->DUA_CODOCO) $ cOcoRee
								If lDt2TIPRDP
									DT2->(dbSetOrder(1)) //DUA_FILIAL+DUA_FILDOC+DUA_DOC+DUA_SERIE+DUA_SEQOCO
									If DT2->(dbSeek(xFilial("DT2")+DUA->DUA_CODOCO)) .And. DT2->DT2_TIPRDP <> StrZero( 2, Len( DT2->DT2_TIPRDP ) )
										lOcorRee := .T.
									EndIf
								Else
									lOcorRee := .T.
								EndIf
								Exit
							EndIf
							DUA->(DbSkip())
						EndDo
						If DTQ->DTQ_SERTMS == StrZero(3,Len(DTQ->DTQ_SERTMS)) .And. lOcorRee //-- Viagem de entrega
							DT6->(dbSetOrder(1))
							If DT6->(MsSeek(xFilial("DT6")+DUD->(DUD_FILDOC+DUD_DOC+DUD_SERIE))) .And. ;
								DT6->DT6_DOCTMS $ cDocTMS // Documento existe, filial de destino igual a filial que está rodando, e tipo de docto esta no parametro?

								aPerfil := TmsPerfil(DT6->DT6_CLIDEV,DT6->DT6_LOJDEV,,,DT6->DT6_CLIREM,DT6->DT6_LOJREM,DT6->DT6_CLIDES,DT6->DT6_LOJDES)
								If DT6->DT6_VALTOT >= aPerfil[33] // Valor do documento maior ou igual ao minimo do original
									If DT6->(FieldPos('DT6_REENTR'))>0 .And. aPerfil[25] == "1" // Cliente paga reentrega?
										If Empty(cOcoRee)
											Help("",1,"TMSA31021") //"Preencha o parametro MV_OCORREE"
											Return ( .F. )
										EndIf
										If Empty(cCmpEnt)
											Help("",1,"TMSA31022") //"Preencha o parametro MV_COMPENT"
											Return ( .F. )
										EndIf
										If (DT6->DT6_REENTR + 1) < aPerfil[32] // Proxima tentativa de entrega menor que a primeira que o cliente paga?
										  	RecLock("DT6",.F.)
											DT6->DT6_REENTR := DT6->DT6_REENTR + 1
											MsUnLock()
										Else // Proxima tentativa de entrega maior ou igual a primeira que o cliente paga?
											aAreaDUD  := DUD->(GetArea())
											aOcorrenc := TMSVerOco(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,StrZero(3,Len(DT6->DT6_SERTMS)),StrZero(4,Len(DT2->DT2_TIPOCO)),StrZero(2,Len(DT2->DT2_RESOCO)))
											aOcoRetNf := TMSVerOco(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE,StrZero(3,Len(DT6->DT6_SERTMS)),StrZero(6,Len(DT2->DT2_TIPOCO)),StrZero(2,Len(DT2->DT2_RESOCO)),StrZero(4,Len(DT2->DT2_TIPPND)))
											aEval(aOcoRetNf,{ |x| aadd(aOcorrenc,x ) })
											nQtdOco   := 0
											For nSeqOco := 1 To Len(aOcorrenc)
												If AllTrim(aOcorrenc[nSeqOco][1]) $ cOcoRee // Compara ocorrencia com parametros
													nQtdOco += aOcorrenc[nSeqOco][2]
												EndIf
											Next
											If DT6->DT6_REENTR < nQtdOco
												If lUsaNfs .And. cCdrOri == AllTrim(DT6->DT6_CDRDES)
													cDocRee := "D" //-- Nota fiscal de reentrega
												Else
													cDocRee := "7" //-- CTRC Reentrega
												EndIf
												nSeek := Ascan(aLoteAut,{|x|x[1]==cDocRee})
												If nSeek == 0
													cLoteAut := TmsA500Lot(StrZero(0,Len(DT6->DT6_LOTNFC)))
													Aadd(aLoteAut,{cDocRee,cLoteAut,1,1})
												Else
													cLoteAut := aLoteAut[nSeek][2]
													aLoteAut[nSeek][3] += 1
													aLoteAut[nSeek][4] += 1
												EndIf
												aRotAnt := aClone(aRotina)
												Tmsa500(.F.,cLoteAut,5)
												aRotina := aClone(aRotAnt)
											EndIf

											RestArea(aAreaDUD)

										EndIf
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf

					DUD->(dbSkip())
				EndDo

				For nA := 1 To Len(aLoteAut)
					DTP->(dbSetOrder(2))
					If DTP->(MsSeek(xFilial("DTP")+cFilAnt+aLoteAut[nA][2]))
						RecLock("DTP",.F.)
						DTP->DTP_QTDLOT := aLoteAut[nA][3]
						DTP->DTP_QTDDIG := aLoteAut[nA][4]
						MsUnlock()
						Aadd(aDocImp,{ STR0022 + DTP->DTP_LOTNFC + ', ' + STR0023 +; //"Favor imprimir os documentos do lote " ### "tipo "
							Iif(aLoteAut[nA][1]==StrZero(5,Len(DT6->DT6_DOCTMS)),STR0017,STR0016) + ".",,}) //Nota Fiscal / Conhecimento
					EndIf
				Next nA
			EndIf

			DA3->(dbSetOrder(1)) //DA3_FILIAL+DA3_COD
			DTY->(dbSetOrder(2)) //DTY_FILIAL+DTY_FILORI+DTY_VIAGEM+DTY_NUMCTC
			DTR->(dbSetOrder(1)) //DTR_FILIAL+DTR_FILORI+DTR_VIAGEM+DTR_ITEM
			// Viagens de transporte em aberto
			If DTQ->DTQ_SERTMS == StrZero(2,Len(DTQ->DTQ_SERTMS)) .And. DTQ->DTQ_STATUS == StrZero(1,Len(DTQ->DTQ_STATUS))
				If DTR->(!MsSeek(xFilial()+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM))
					Help("",1,"TMSA31013") //Complemento de viagem nao encontrado.
					DTQ->( MsUnLock() )
					Return( .F. )
				EndIf
			EndIf
			//-- Verifica se existe Lotes não calculados para a Viagem
			If ExistFunc("VldLoteVge") .And. lContinua
				lContinua := VldLoteVge(DTQ->DTQ_FILORI , DTQ->DTQ_VIAGEM )
				If !lContinua
					Return(.F.)
				EndIf
			EndIf
		EndIf

		If DTQ->DTQ_STATUS <> StrZero(1,Len(DTQ->DTQ_STATUS)) // Se a Viagem nao estiver em aberto
			DTW->(dbSetOrder(3)) //DTW_FILIAL+DTW_FILORI+DTW_VIAGEM+DTW_STATUS+DTW_SEQUEN
			While DTW->(MsSeek( cSeekDTW := xFilial('DTW')+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM+StrZero(1,Len(DTW->DTW_STATUS)) ))
				If ( Empty(DTW->DTW_FILATI) .Or. DTW->DTW_FILATI == cFilAnt ) .And. DTW->DTW_ATIVID <> cAtivSai
					If nPCanOp <> 2
						lCancelaDTW := .T.
						If lPergOp .And. !lFecAuto // Exibe pergunta(Cancela operacoes Sim/Nao)
							If Aviso(STR0021,STR0018,{STR0019,STR0020},,STR0001) <> 1 //'Existem operacoes de transporte em aberto para esta viagem. Estas operacoes serao canceladas.'###'Continua'###'Sair'###'Fechamento de Viagem' //'AVISO'
								lCancelaDTW := .F.
							Else
								lPergOp := .F.
							EndIf
						EndIf
					EndIf
					If lCancelaDTW
						DTW->( RecLock('DTW',.F.) )
						DTW->DTW_DATREA := dDatFec
						DTW->DTW_HORREA := cHorFec
						DTW->DTW_STATUS := StrZero(9,Len(DTW->DTW_STATUS))		//-- Cancelado
						DTW->( MsUnLock() )
					Else
						Help("",1,"TMSA31014") // Existem Operacoes Anteriores em Aberto ...
						DTQ->( MsUnLock() )
					   Return ( .F. )
					EndIf
				Else
					//-- encontrou a atividade de saida
					Exit
				EndIf
			EndDo
		EndIf


		If	DTQ->DTQ_STATUS == StrZero(1,Len(DTQ->DTQ_STATUS)) // Em Aberto.

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Retorna as Filiais / Regioes de Descarga da Rota                      ³
			//³ Elementos contidos por dimensao:                                      ³
			//³ 1. Regiao Origem da Rota                                              ³
			//³ 2. Regioes de Descarga da Rota                                        ³
			//³ 3. Filiais de Descarga da Rota                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aFilDCA := TmsRegDca( DTQ->DTQ_ROTA,,,.F.)

			DA8->( DbSetOrder( 1 ) ) //DA8_FILIAL+DA8_COD
			DC5->( DbSetOrder( 1 ) ) //DC5_FILIAL+DC5_SERVIC+DC5_ORDEM
			DC6->( DbSetOrder( 1 ) ) //DC6_FILIAL+DC6_TAREFA+DC6_ORDEM

			If lRotaAut .And. AliasIndic('DJG')
				//--Efetua a gravação dos DTW de acordo com o roteiro
				//--Chama função que retornará todos os trechos do roteiro da viagem
				aRotGeral 	:= TMF10RtVge(DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, , , ,2 )
				lRotaAut 	:= (nTamRotGer := Len(aRotGeral)) > 0
				If lRotaAut
					lFirstFil := aScan(aSM0,{|x| AllTrim(x[SM0_CGC]) == AllTrim(Posicione('SA1',1,FwxFilial('SA1')+aRotGeral[1,1]+aRotGeral[1,2],"A1_CGC")) }) > 0
					lLastFil  := aScan(aSM0,{|x| AllTrim(x[SM0_CGC]) == AllTrim(Posicione('SA1',1,FwxFilial('SA1')+aTail(aRotGeral)[1]+aTail(aRotGeral)[2],"A1_CGC")) }) > 0
				EndIf
			ElseIf lOperCli
				//Chama funçaõ que retorna os documentos da viagem
				//A partir dos documentos retiramos os clientes da mesma
				//Retorna Todos os clientes da viagem para enviar ao CPL				
				oDadosViag	:= TMSBCADadosTMS():New(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,nOpcx,.F.)
				oDadosViag:AddCustomerTrip(DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM)			
				oDadosViag:AddDocs(DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM)	
				aClientes   := {}
				aTempCli 	:= oDadosViag:GetCustomers()
				For nTempCli := 1 To Len(aTempCli)
					If Empty(aClientes) .Or. AScan( aClientes, {|x| x[1] == aTempCli[nTempCli][1] .And. x[2] == aTempCli[nTempCli][2] .And. x[3] == aTempCli[nTempCli][3] }) == 0
						AAdd( aClientes, AClone(aTempCli[nTempCli]) )
					EndIf
				Next
				aDocs 		:= oDadosViag:GetDocs()
				nTamCliente := Len(aClientes)
			EndIf


			If DA8->( MsSeek( xFilial( 'DA8' ) + DTQ->DTQ_ROTA,.F. ) )
				If	DC5->( MsSeek( cSeekDC5 := xFilial('DC5') + DA8->DA8_SERVIC, .F.) )
					//--Chamada da função que verifica se existe atividade de saída e chegada do cliente
					If lRotaAut
						lRotaAut :=  T310AtvCli(DA8->DA8_SERVIC,cAtvSaiCli,cAtvChgCli,cAtvSaiApo,cAtvChgApo)					
					ElseIf lOperCli
						lOperCli:=  T310AtvCli(DA8->DA8_SERVIC,cAtvSaiCli,cAtvChgCli,cAtvSaiApo,cAtvChgApo)
					EndIf
					While lContinua .And. DC5->( !Eof() .And. (DC5_FILIAL + DC5_SERVIC == cSeekDC5) )
						DC6->( MsSeek( xFilial("DC6") + DC5->DC5_TAREFA, .F.) )
						While lContinua .And. DC6->( !Eof() .And. DC6->DC6_TAREFA == DC5->DC5_TAREFA )
							If lTM310FFL
								lAddServic := ExecBlock("TM310FFL",.F.,.F.,{ DC6->DC6_FILATI, DC6->DC6_ATIVID })
								If ValType(lAddServic) != 'L'
									lAddServic := .T.
								EndIf	 
								If lAddServic
									Aadd(aServic, {DC5->DC5_SERVIC, DC5->DC5_TAREFA, DC6->DC6_ATIVID, DC6->DC6_DURAC, DC6->DC6_FILATI,Space(TamSx3('DT6_CLIDEV')[1]),Space(TamSx3('DT6_LOJDEV')[1]),Space(TamSx3('A1_NOME')[1]),Space(TamSx3('DUL_SEQEND')[1]), "" })
								EndIf 
							ElseIf !lRotaAut .And. !lOperCli
								Aadd(aServic, {DC5->DC5_SERVIC, DC5->DC5_TAREFA, DC6->DC6_ATIVID, DC6->DC6_DURAC, DC6->DC6_FILATI,Space(TamSx3('DT6_CLIDEV')[1]),Space(TamSx3('DT6_LOJDEV')[1]),Space(TamSx3('A1_NOME')[1]),Space(TamSx3('DUL_SEQEND')[1]), "" })
							ElseIf lRotaAut .Or. lOperCli
								If DC6->DC6_ATIVID == cAtivSai
									//-- Se o 1º ponto do roteiro não é uma filial, preenche o cód/loj/nome do 1º cliente do roteiro na saída de viagem
									If !lFirstFil .And. lRotaAut //-- Se o 1º ponto do roteiro não é uma filial, preenche o cód/loj/nome do 1º cliente do roteiro na saída de viagem
										Aadd(aServic, {DC5->DC5_SERVIC, DC5->DC5_TAREFA, DC6->DC6_ATIVID, DC6->DC6_DURAC, DC6->DC6_FILATI,aRotGeral[1,1],aRotGeral[1,2],Posicione('SA1',1,FwxFilial('SA1')+aRotGeral[1,1]+aRotGeral[1,2],"A1_NOME"),aRotGeral[1,3], "" })
									Else
										Aadd(aServic, {DC5->DC5_SERVIC, DC5->DC5_TAREFA, DC6->DC6_ATIVID, DC6->DC6_DURAC, DC6->DC6_FILATI,Space(TamSx3('DT6_CLIDEV')[1]),Space(TamSx3('DT6_LOJDEV')[1]),Space(TamSx3('A1_NOME')[1]),Space(TamSx3('DUL_SEQEND')[1]), "" })
									EndIf
								ElseIf DC6->DC6_ATIVID == cAtivChg
									//-- Se o último ponto do roteiro não é uma filial, preenche o cód/loj/nome do último cliente do roteiro na Chegada de viagem
									If !lFirstFil .And. lRotaAut//-- Se o último ponto do roteiro não é uma filial, preenche o cód/loj/nome do último cliente do roteiro na Chegada de viagem
										Aadd(aServic, {DC5->DC5_SERVIC, DC5->DC5_TAREFA, DC6->DC6_ATIVID, DC6->DC6_DURAC, DC6->DC6_FILATI,aTail(aRotGeral)[1],aTail(aRotGeral)[2],Posicione('SA1',1,FwxFilial('SA1')+aTail(aRotGeral)[1]+aTail(aRotGeral)[2],"A1_NOME"),aTail(aRotGeral)[3], "" })
									Else
										Aadd(aServic, {DC5->DC5_SERVIC, DC5->DC5_TAREFA, DC6->DC6_ATIVID, DC6->DC6_DURAC, DC6->DC6_FILATI,Space(TamSx3('DT6_CLIDEV')[1]),Space(TamSx3('DT6_LOJDEV')[1]),Space(TamSx3('A1_NOME')[1]),Space(TamSx3('DUL_SEQEND')[1]), "" })
									EndIf
								Else
									//-- Se encontrou saída do cliente sem que antes tenha encontrado a chegada, cancela o processo
									If (DC6->DC6_ATIVID == cAtvSaiCli .OR. DC6->DC6_ATIVID == cAtvSaiApo) .And. !lIncSerCli
										AAdd( aMsgErr, { STR0064, , "DLGA080()"}) //A atividade de saída do cliente deve estar confirgurada após a chegada no mesmo.
										lContinua := .F.
										Exit
									EndIf

									//-- Se a atividade é a chegada do cliente, liga a flag
									If DC6->DC6_ATIVID == cAtvChgCli .OR. DC6->DC6_ATIVID == cAtvChgApo
										lIncSerCli := .T.
									EndIf

									//-- Todo o intervalo de atividades entre chegada e saída do cliente será guardado para geração da DTW
									If !lIncSerCli
										Aadd(aServic, {DC5->DC5_SERVIC, DC5->DC5_TAREFA, DC6->DC6_ATIVID, DC6->DC6_DURAC, DC6->DC6_FILATI,Space(TamSx3('DT6_CLIDEV')[1]),Space(TamSx3('DT6_LOJDEV')[1]),Space(TamSx3('A1_NOME')[1]),Space(TamSx3('DUL_SEQEND')[1]),"" })
									Else
										Aadd(aServCli, {DC5->DC5_SERVIC, DC5->DC5_TAREFA, DC6->DC6_ATIVID, DC6->DC6_DURAC, DC6->DC6_FILATI,"CLI","LOJ","NOM","SEQ","" })
									EndIf

									//-- Se a atividade é a Saída do cliente, desliga a flag e preenche o aServic para todos os clientes
									If DC6->DC6_ATIVID == cAtvSaiCli .OR. DC6->DC6_ATIVID == cAtvSaiApo
										lIncSerCli := .F.
										//-- O primeiro e último pontos do roteiro são preenchidos na atividade de saída e chegada de viagem, respectivamente.
										//-- Portanto, não haverá chegada e saída de cliente para o primeiro e o último pontos do roteiro.
										//-- Caso o primeiro e/ou último pontos do roteiro não sejam filiais, terão o cód/loja preenchidos no DTW
										If lRotaAut
											For nCntRot:= 2 To nTamRotGer - 1
												//-- Move os serviços do array de clientes para o array do DTW, prenchendo os dados do cliente 
												aEval(aServCli,{|aLinha| aAdd(aServic,aClone(aLinha)),;
																			aTail(aServic)[6] := aRotGeral[nCntRot][1],;
																			aTail(aServic)[7] := aRotGeral[nCntRot][2],;
																			aTail(aServic)[8] := Posicione('SA1',1,FwxFilial('SA1')+aRotGeral[nCntRot][1]+aRotGeral[nCntRot][2],"A1_NOME"),;
																			aTail(aServic)[9] := aRotGeral[nCntRot][3]})
											Next nCntRot
										Else
											For nCntCli := 1 To nTamCliente
												If (Empty(aClientes[nCntCli][1]) .Or. Empty(aClientes[nCntCli][2])) .AND. DC6->DC6_ATIVID <> cAtvSaiApo
													If lVldOPeCli
														If !MsgYesNo(STR0075 + chr(10)+chr(13)+STR0076) //--Nesta viagem, existem solicitações de coleta sem a informação do Cliente Remetente e estes documentos não serão considerados na geração das Operações de Transporte. //--"Deseja confirmar o Fechamento da Viagem?"
															lContinua := .F.
															Exit
														Else
															lVldOPeCli := .F.													
														EndIf
													EndIf
													
												Else	
													For nCont := 1 to Len(aDocs)
														If  GetInfoArr( aDocs[nCont],"CLIDES",3) == aClientes[nCntCli][1] .And. ;
															GetInfoArr( aDocs[nCont],"LOJDES",3) == aClientes[nCntCli][2] .And.;
															GetInfoArr( aDocs[nCont],"SERIE" ,3) <> "COL

															  nResult := nCont
															  Exit 															
														EndIf
													Next nCont 
																									
													If nResult > 0  .And. DUY->(MsSeek(xFilial("DUY")+ rtRIM( GetInfoArr( aDocs[nCont],"REGCALC",3) ) ))   
														cCodUFCAL := DUY->DUY_EST
													Else
														cCodUFCAL := ''
													EndIf
													nResult := 0
													
													aEval(aServCli,{|aLinha| aAdd(aServic,aClone(aLinha)),;
																		aTail(aServic)[6] := aClientes[nCntCli][1],;
																		aTail(aServic)[7] := aClientes[nCntCli][2],;
																		aTail(aServic)[8] := aClientes[nCntCli][3],,;
																		aTail(aServic)[9] := aClientes[nCntCli][3],,;
																		aTail(aServic)[10]:= cCodUFCAL })
																		
												EndIf
                                                If DC6->DC6_ATIVID == cAtvSaiApo
                                                    Exit
                                                EndIf
											Next nCntCli 	
										EndIf	
										aServCli := {}
									EndIf
								EndIf
							EndIf
							DC6->(dbSkip())
						EndDo
						DC5->(dbSkip())
					EndDo
				Else
					Help(' ', 1, 'TMSA31002',,STR0008 + DA8->DA8_SERVIC,5,11)		//-- Servico nao encontrado (DC5). //'Servico : '
					lContinua := .F.
				EndIf
			Else
				Help(' ', 1, 'TMSA31003',,STR0009 + DTQ->DTQ_ROTA,5,11)		//-- Rota nao encontrada (DA8). //'Rota : '
				lContinua := .F.
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Nao efetuar fechamento se foi informado veiculo generico para a viagem.  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lContinua
				If !Empty(cVeiGen)
					cQuery := ""
					cQuery := " SELECT DTR_FILORI,DTR_VIAGEM "
					cQuery += " 	FROM " + RetSqlName("DTR") + " DTR "
					cQuery += " WHERE	DTR_FILIAL = '" + xFilial("DTR") + "' "
					cQuery += " 		AND DTR_FILORI = '"+DTQ->DTQ_FILORI +"' "
					cQuery += " 		AND DTR_VIAGEM = '"+DTQ->DTQ_VIAGEM +"' "
					cQuery += " 		AND DTR.D_E_L_E_T_ = ' ' "
					cQuery += " 		AND ( DTR_CODVEI = '"+cVeiGen+"' "
					cQuery += " 		   OR DTR_CODRB1 = '"+cVeiGen+"' "
					cQuery += " 		   OR DTR_CODRB2 = '"+cVeiGen+"' "
					If DTT->(ColumnPos('DTT_FRORB3')) > 0
						cQuery += "		OR DTR_CODRB3 = '"+cVeiGen+"') "
					Else
						cQuery += ") "
					EndIf
					cQuery := ChangeQuery(cQuery)

					cAliasNew := GetNextAlias()
					DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.T.,.T.)

					dbSelectArea( cAliasNew )
					( cAliasNew )->( dbGoTop() )

					If ( cAliasNew )->( !Eof() )
						Help("", 1, "TMSA31017") //"Nao e permitido efetuar fechamento da viagem com veiculo generico"
						lContinua := .F.
					EndIf
					( cAliasNew )->( dbCloseArea() )
				EndIf
			EndIf


			If lContinua
				DUP->(dbSetOrder(2)) //DUP_FILIAL+DUP_FILORI+DUP_VIAGEM+DUP_CODMOT
				If !Empty(cMotGen) .And. DUP->(MsSeek(xFilial('DUP') + DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM + cMotGen))
					Help("", 1, "TMSA31018") //"Nao e permitido efetuar fechamento da viagem com motorista generico"
					lContinua := .F.
				EndIf
			EndIf

			//Validação das férias do motorista
			If lContinua
				aAreaDUP  := DUP->(GetArea())
				aAreaDA4  := DA4->(GetArea())
				DUP->(dbSetOrder(2)) //DUP_FILIAL+DUP_FILORI+DUP_VIAGEM+
				If DUP->(MsSeek(xFilial('DUP') + DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM ))
					While DUP->(!EOF()) .AND. DUP->(DUP_FILIAL+DUP_FILORI+DUP_VIAGEM) == xFilial("DUD")+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM
						DA4->(DbSetOrder(1)) //DA4_FILIAL+DA4_COD
						If DA4->(DbSeek(xFilial("DA4") + DUP->DUP_CODMOT ))
							lContinua := TMSVldFunc(DA4->DA4_MAT, DA4->DA4_FILBAS)
						EndIf
						If !lContinua
							Exit
						EndIf
						DUP->(dbSkip())
					EndDo
				EndIf
				RestArea(aAreaDUP)
				RestArea(aAreaDA4)
			EndIf

			If lContinua
				For nA := 1 To Len( aFilDCA )

					lAtivSai	:= .T.	//-- Atividade de Saida
					lAtivChg	:= .T.	//-- Atividade de Chegada
					lAtivOk	:= .T.
					lAtivOk1 	:= .T.
					lAtivOk2	:= .T.
					lAtivDca	:= .T.	//-- Atividade de Descarregamento
					lAtivRta	:= .T.	//-- Atividade de Retorno de Aeroporto
					lAtivRtp	:= .T.	//-- Atividade de Retorno de Porto

					If !lTM310FFL .Or. ExecBlock("TM310FFL",.f.,.f.,{aFilDCA[nA,3],""})
						If nA == 1
							lAtivSai := Ascan( aServic, { | x | x[3] + x[5] == cAtivSai + aFilDCA[nA,3] }) > 0
							lAtivRta := Ascan( aServic, { | x | x[3] + x[5] == cAtivRta + aFilDCA[nA,3] }) > 0
							lAtivRtp := Ascan( aServic, { | x | x[3] + x[5] == cAtivRtp + aFilDCA[nA,3] }) > 0
							If nA == Len( aFilDCA )
								lAtivChg := Ascan( aServic, { | x | x[3] + x[5] == cAtivChg + aFilDCA[nA,3] }) > 0
								lAtivDca := Ascan( aServic, { | x | x[3] + x[5] == cAtivDca + aFilDCA[nA,3] }) > 0
							EndIf
						ElseIf nA == Len( aFilDCA )
							lAtivChg := Ascan( aServic, { | x | x[3] + x[5] == cAtivChg + aFilDCA[nA,3] }) > 0
							
							If DTQ->DTQ_TIPVIA == StrZero(2,Len(DTQ->DTQ_TIPVIA)) .AND. DTQ->DTQ_SERTMS == StrZero(3,Len(DTQ->DTQ_SERTMS)) .AND. DTQ->DTQ_TIPTRA == StrZero(4,Len(DTQ->DTQ_TIPTRA))
								lAtivOk  := Ascan( aServic, { | x | x[3] + x[5] == cAtivSai + aFilDCA[nA,3] }) > 0
							Else
								lAtivOk  := Ascan( aServic, { | x | x[3] + x[5] == cAtivSai + aFilDCA[nA,3] }) == 0
							EndIf

							lAtivOk1 := Ascan( aServic, { | x | x[3] + x[5] == cAtivRta + aFilDCA[nA,3] }) == 0
							lAtivOk2 := Ascan( aServic, { | x | x[3] + x[5] == cAtivRtp + aFilDCA[nA,3] }) == 0
							lAtivDca := Ascan( aServic, { | x | x[3] + x[5] == cAtivDca + aFilDCA[nA,3] }) > 0
						Else
							lAtivChg := Ascan( aServic, { | x | x[3] + x[5] == cAtivChg + aFilDCA[nA,3] }) > 0
							lAtivSai := Ascan( aServic, { | x | x[3] + x[5] == cAtivSai + aFilDCA[nA,3] }) > 0
							lAtivOk1 := Ascan( aServic, { | x | x[3] + x[5] == cAtivRta + aFilDCA[nA,3] }) == 0
							lAtivOk2 := Ascan( aServic, { | x | x[3] + x[5] == cAtivRtp + aFilDCA[nA,3] }) == 0
							lAtivDca := Ascan( aServic, { | x | x[3] + x[5] == cAtivDca + aFilDCA[nA,3] }) > 0
						EndIf
					EndIf

					If !lAtivSai
						AAdd( aMsgErr, { STR0027 + aFilDCA[nA,3], , "DLGA080()"}) //"Nao foi encontrada atividade de saida para filial : "
					EndIf
					If !lAtivChg .And. !lRotaAut
						AAdd( aMsgErr, { STR0028 + aFilDCA[nA,3], , "DLGA080()"}) //"Nao foi encontrada atividade de chegada para filial : "
					EndIf
					If !lAtivOk
						AAdd( aMsgErr, { STR0029 + aFilDCA[nA,3], , "DLGA080()"}) //"Nao deve existir atividade de saida para filial : "
					EndIf

					If	DTQ->DTQ_SERTMS == StrZero(2,Len(DTQ->DTQ_SERTMS))
						If	DTQ->DTQ_TIPTRA == StrZero(2,Len(DTQ->DTQ_TIPTRA)) // Aereo
							If	!lAtivRta
								AAdd( aMsgErr, { STR0030 + aFilDCA[nA,3], , "DLGA080()"}) //"Nao foi encontrada atividade de retorno do aeroporto para filial : "
							EndIf

							If !lAtivOk1
								AAdd( aMsgErr, { STR0031 + aFilDCA[nA,3], , "DLGA080()"}) //"Nao deve existir atividade de retorno de aeroporto para filial : "
							EndIf

							If !lAtivOk2
								AAdd( aMsgErr, { STR0032 + aFilDCA[nA,3], , "DLGA080()"}) //"Nao deve existir atividade de retorno de porto para filial : "
							EndIf

						ElseIf DTQ->DTQ_TIPTRA == StrZero(3,Len(DTQ->DTQ_TIPTRA)) // Fluvial
							If	!lAtivRtp
								AAdd( aMsgErr, { STR0033 + aFilDCA[nA,3], , "DLGA080()"}) //"Nao foi encontrada atividade de retorno do porto para filial : "
							EndIf

						Else
							If !lAtivDca .And. DTQ->DTQ_TIPVIA <> STRZERO(2,Len(DTQ->DTQ_TIPVIA)) //So validar se nao for viagem vazia
								AAdd( aMsgErr, { STR0026 + aFilDCA[nA,3], , "DLGA080()"}) //"Nao foi encontrada atividade de descarregamento para filial : "
							EndIf
						EndIf
					EndIf

				Next nA

				/* Essa validacao nao permite que seja informada atividades para filiais que nao pertencem a rota utilizada. */
				For nC := 1 To Len( aServic )
					Do Case
						Case aServic[ nC, 3 ] == cAtivSai .And. Ascan( aFilDca, { | X | X[ 3 ] == aServic[ nC, 5 ] } ) == 0
							AAdd( aMsgErr, { STR0029 + aServic[ nC, 5 ],, "DLGA080()"}) //"Nao deve existir atividade de saida para filial : "
						Case aServic[ nC, 3 ] == cAtivChg .And. Ascan( aFilDca, { | X | X[ 3 ] == aServic[ nC, 5 ] } ) == 0
							AAdd( aMsgErr, { STR0025 + aServic[ nC, 5 ],, "DLGA080()"}) //"Nao deve existir atividade de chegada para filial : "
						Case aServic[ nC, 3 ] == cAtivDca .And. Ascan( aFilDca, { | X | X[ 3 ] == aServic[ nC, 5 ] } ) == 0
							AAdd( aMsgErr, { STR0024 + aServic[ nC, 5 ],, "DLGA080()"}) //"Nao deve existir atividade de descarregamento para filial : "
						Case aServic[ nC, 3 ] == cAtivRta .And. Ascan( aFilDca, { | X | X[ 3 ] == aServic[ nC, 5 ] } ) == 0
							AAdd( aMsgErr, { STR0031 + aServic[ nC, 5 ],, "DLGA080()"}) //"Nao deve existir atividade de retorno de aeroporto para filial : "
						Case aServic[ nC, 3 ] == cAtivRtp .And. Ascan( aFilDca, { | X | X[ 3 ] == aServic[ nC, 5 ] } ) == 0
							AAdd( aMsgErr, { STR0032 + aServic[ nC, 5 ],, "DLGA080()"}) //"Nao deve existir atividade de retorno de porto para filial : "
					End Case
				Next nC
			EndIf
		EndIf

		If !Empty( aMsgErr )
			If lFecAuto
				For nCnt := 1 To Len(aMsgErr)
					AutoGrLog(aMsgErr[nCnt,1])
				Next nCnt
			Else
				TmsMsgErr( aMsgErr )
			EndIf

			lContinua := .F.
		EndIf

		If lContinua
			//-- Executa Chek List da Viagem RRE
			If lTabRRE .And. "3" $ cMV_TMSRRE
				aAreas:= GetArea()
				lContinua:= TMA310RRE(DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, lFecAuto)
				RestArea(aAreas)
			EndIf

		EndIf

		If lContinua .And. AliasInDic("DL3")
			Pergunte("TMB144",.F.)
			If mv_par06 == 1 .And. (!lFecAuto .And. !IsBlind())
				lContinua		:= A310Rentab(DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM,3 , @nFretePrev)

				If lContinua
					lRentab		:= .T.
				EndIf
            ElseIf Tmsa029Use("TMSA310") //-- Confere a existência de Bloqueios
		        cStReg := Tmsa029Blq( 9 ,'TMSA310', 'RP'  ,DTQ->DTQ_FILORI, 'DTQ' , '1' ,DTQ->(DTQ_FILIAL+DTQ_FILORI+DTQ_VIAGEM), DTQ->DTQ_VIAGEM , "", )

    		    If cStReg <> "L" .And. cStReg <> "N" //Liberado Totalmente ou sem bloqueio
                    Help("", 1, "TMSA31023") // "Existem bloqueios de rentabilidade para essa viagem. Não é possível fechar a viagem."
                    lContinua := .F.
                EndIf
            EndIf

		EndIF

		If lContinua

			//-- Executa ponto de entrada antes de efetuar a atualizacao dos dados
			If	lTma310Grv
				lContinua := ExecBlock('TMA310GRV',.F.,.F.,{3, DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM,lFecAuto} )
				If ValType(lContinua) <> "L"
					lContinua := .T.
				EndIf
			EndIf

			If !lContinua
				If !Empty( aMsgErr )
					If lFecAuto
						For nCnt := 1 To Len(aMsgErr)
							AutoGrLog(aMsgErr[nCnt,1])
						Next nCnt
					Else
						TmsMsgErr( aMsgErr )
					EndIf
				EndIf
			Else
				Begin Transaction

					DTR->(DbSetOrder(1))
					//-- Nao baixar estoque de entrega aerea, pq a mercadoria esta no aeroporto e nao no estoque da filial
					If	! ( DTQ->DTQ_SERTMS == StrZero(3,Len(DTQ->DTQ_SERTMS)) .And. DTQ->DTQ_TIPTRA == StrZero(2,Len(DTQ->DTQ_TIPTRA)) )
						lRet := TMSBxEstoq( DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM ) // Baixa Estoque
					EndIf

					If lRet
						If	DTQ->DTQ_STATUS == StrZero(1,Len(DTQ->DTQ_STATUS)) //Em Aberto

							lRet	:= A310SVCENT( DTQ->DTQ_FILORI ,DTQ->DTQ_VIAGEM , DTQ->DTQ_SERTMS , DTQ->DTQ_TIPTRA )
							
							dDataPre := dDatFec
							cHoraPre := Transform(cHorFec,"@R 99:99")

							For nB := 1 To Len( aServic )
								//-- Calcula a data e hora prevista
								SomaDiaHor( @dDataPre, @cHoraPre, HoraToInt( aServic[nB, 4], 3 ) )
								nSequen += 30
								If lIdDTW .And. ExistFunc("Tm351IdDTW")
									cIdDTW := Tm351IdDTW( DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM	)
								EndIf 
								
								aCab := {}
								Aadd( aCab, { 'DTW_FILORI'	, DTQ->DTQ_FILORI	, Nil } )
								Aadd( aCab, { 'DTW_VIAGEM'	, DTQ->DTQ_VIAGEM	, Nil } )
								Aadd( aCab, { 'DTW_SEQUEN'	, StrZero(nSequen, Len(DTW->DTW_SEQUEN) ), Nil } )
								Aadd( aCab, { 'DTW_DATPRE'	, dDataPre			, Nil } )
								Aadd( aCab, { 'DTW_HORPRE'	, StrTran(Left(cHoraPre,5),':',''), Nil } )
								Aadd( aCab, { 'DTW_DATREA'	, Ctod('')			, Nil } )
								Aadd( aCab, { 'DTW_HORREA'	, ''					, Nil } )
								Aadd( aCab, { 'DTW_SERVIC'	, aServic[nB, 1]	, Nil } )
								Aadd( aCab, { 'DTW_TAREFA'	, aServic[nB, 2]	, Nil } )
								Aadd( aCab, { 'DTW_ATIVID'	, aServic[nB, 3]	, Nil } )
								Aadd( aCab, { 'DTW_FILATI'	, aServic[nB, 5]	, Nil } )
								If aServic[nB, 3] $ cAtvChgCli + "," + cAtvSaiCli
									Aadd( aCab, { 'DTW_CODCLI'	, aServic[nB, 6]	, Nil } )
									Aadd( aCab, { 'DTW_LOJCLI'	, aServic[nB, 7]	, Nil } )
									Aadd( aCab, { 'DTW_NOMCLI'	, aServic[nB, 8]	, Nil } )
									If aServic[nB, 3] == cAtvChgCli .And. TableInDic("DLT")
										lcriaDLT := .T.
									EndIf 
								EndIf
								If DTW->(ColumnPos("DTW_SEQEND")) > 0
									Aadd( aCab, { 'DTW_SEQEND'	, aServic[nB, 9]	, Nil } )
								EndIf
								Aadd( aCab, { 'DTW_SERTMS'	, DTQ->DTQ_SERTMS	, Nil } )
								Aadd( aCab, { 'DTW_TIPTRA'	, DTQ->DTQ_TIPTRA	, Nil } )
								Aadd( aCab, { 'DTW_STATUS'	, StrZero(1,Len(DTW->DTW_STATUS))	, Nil } )
								Aadd( aCab, { 'DTW_TIPOPE'	, StrZero(2,Len(DTW->DTW_STATUS))	, Nil } ) // Tipo de Operacao == "Transporte"
								If lUFAtiv 
									Aadd( aCab, { 'DTW_UFATIV'	, aServic[nB, 10]	, Nil } )
								EndIf
								
								If lIdDTW
									Aadd( aCab, { 'DTW_IDDTW'	, cIdDTW	, Nil } )
								EndIf

								lRet := TMSCriaDTW( aCab )
								 
								//-- Executa Ponto de Entrada apos a geracao de cada DTW.
								If lRet .And. lTMA310DTW
									lRet := ExecBlock('TMA310DTW',.F.,.F.,{3, DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM,lFecAuto} )

									If ValType(lRet) <> "L"
										lRet := .T.
									EndIf
								EndIf

								If lRet .And. TableInDic("DLT") .And. ExistFunc("Tmsa351DLT") .And. lcriaDLT .And. Len(aDocs) > 0
									For nAux := 1 To Len(aDocs)
										If GetInfoArr( aDocs[nAux],"CLIDES",3) + GetInfoArr( aDocs[nAux],"LOJDES",3) ==  aServic[nB][6] + aServic[nB][7] .Or. ;
											( GetInfoArr( aDocs[nAux],"SERIE",3)  == "COL" .And. GetInfoArr( aDocs[nAux],"CLIREM",3)  + GetInfoArr( aDocs[nAux],"LOJREM",3) == aServic[nB][6] + aServic[nB][7] )
											
											If GetInfoArr( aDocs[nAux],"SERIE",3) == "COL"
												cOpeDoc	:= "3"
											Else
												cOpeDoc	:= "1"
											EndIf 

											Aadd( aCabDTW, { 'DTW_FILORI'	, DTQ->DTQ_FILORI	, Nil } )
											Aadd( aCabDTW, { 'DTW_VIAGEM'	, DTQ->DTQ_VIAGEM	, Nil } ) 
											Aadd( aCabDTW, { 'DTW_IDDTW'	, cIdDTW			, Nil } ) 

											Tmsa351DLT(aCabDTW, 4, DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, cIdDTW, GetInfoArr( aDocs[nAux],"FILDOC",3) , GetInfoArr( aDocs[nAux],"DOC",3) , GetInfoArr( aDocs[nAux],"SERIE",3), "1", cOpeDoc)
										EndIf
									Next nAux 
									lcriaDLT := .F. 	
								EndIf 
							Next nB
							If IsInCallSTack('TMSAF76') .And. AliasIndic('DDJ')
								//--Efetua a gravação dos DTW de acordo com o roteiro
								//--Chama função que retornará todos os trechos do roteiro da viagem
								aRotGeral := TMF10RtVge(DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, , , ,2 )
							EndIf
						EndIf

						//+--------------------------------------------------------------------------------
						//| Integração Mensagem Unica EAI - GERA TITULOS CP
						//+--------------------------------------------------------------------------------
						If lRet
							// Este lock foi colocado porque o comando 'End Transaction' executa internamente um MsUnlockAll.
							// A rotina de reentrega executa o TMSA170 automaticamente, a qual executa um 'End Transaction'.
							// Como nem todos os documentos do DUD podem gerar armazenagem, foi conversado com a tecnologia,
							//    a qual informou que se um registro estiver travado, e for executado um Reclock, este ultimo
							//    nao tera efeito.
							RecLock('DTQ',.F.)
							If DTQ->DTQ_STATUS == StrZero(1,Len(DTQ->DTQ_STATUS)) // Em Aberto
								DTQ->DTQ_DATFEC := dDatFec
								DTQ->DTQ_HORFEC := cHorFec
							EndIf

							DTQ->DTQ_STATUS := StrZero(5,Len(DTQ->DTQ_STATUS)) // Fechada
							DTQ->(MsUnLock())
							
							//-- Verifica se gera contrato carreteiro automaticamente
							If ExistFunc("TmsAutViag") .And. ExistFunc("TMSA16GCTC") .And. DTQ->(ColumnPos("DTQ_CODAUT")) > 0
								If TmsAutViag(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,DTQ->DTQ_CODAUT,"TMSA250")
									lContrAut := .T.
								Else
									lContrAut := .F.
								EndIf
							Else
								lContrAut := .F.
							EndIf
							
							If lContrAut
								If ExistFunc("TMSA250Ger")
									lRet    := TMSA250Ger( DTQ->DTQ_FILORI , DTQ->DTQ_VIAGEM )
								Else 
									lRet := TMSA16GCtc( DTQ->DTQ_VIAGEM ,  DTQ->DTQ_FILORI  )
								EndIf 
							EndIf
							//--
							
						EndIf
					EndIf //|[Fecha o If lRet depois do begin transaction]


					If lRet
						If (DTQ->DTQ_TIPVIA <> StrZero(5,Len(DTQ->DTQ_TIPVIA)) .And. lTMS3GFE .And. cTMS3GFE == 'F') .Or.;  //Fechamento da Viagem diferente de redespacho
							(DTQ->DTQ_TIPVIA == StrZero(5,Len(DTQ->DTQ_TIPVIA)) .And. cTMSRDPU == 'F')
							//--- Chama integração TMS x GFE
							aAreas:= GetArea()
							lContinua:= Tms3GfeInt(DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, lFecAuto, .F.)
							RestArea(aAreas)
							If !lContinua
								lRet:= .F.
								DisarmTransaction()
							Else
								lRet:= .T.
							EndIf
						EndIf

						If lRet
							//Se a viagem não for paga pelo GFE, considera o Contas a Pagar (Protheus ou Datasul para gerar títulos financeiros.)
							If DTQ->DTQ_PAGGFE <> StrZero(1,Len(DTQ->DTQ_PAGGFE))
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Gravação de Frete provisório³
								//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
								If DTR->(MsSeek(cChaveViag:=FwxFilial('DTR')+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM))
									While DTR->(!Eof()) .And. DTR->(DTR_FILIAL+DTR_FILORI+DTR_VIAGEM) == cChaveViag

										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³1º SIMULA O VALOR DO FRETE A PAGAR, ATRAVÉS DA CALFREPAG		  								³
										//³2º CACULA O VALOR DO PERCENTUAL DE ADIANTAMENTO				  								³
										//³3º GRAVA CUSTOS DE TRANSPORTE (SDG) PARA CADA ADIANTAMENTO NA DTR							³
										//³4º GRAVA SDG PARA O PEDÁGIO DE CADA DTR E PREPARA O ARRAY PARA GRAVAÇÃO DO TÍTULO DE PEDÁGIO	³
										//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´

										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³Preenche Array com todos os Fornecedores dos veículos da viagem³
										//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
										//³Parametros da aFornec:                                         ³
										//³01- Codigo do Fornecedor                                       ³
										//³02- Loja do fornecedor                                         ³
										//³03- Codigo do Veiculo ou do Reboque                            ³
										//³04- Tipo da frota  1=Própria; 2=Terceiro; 3=Agregado           ³
										//³05- Tipo do Veiculo                                            ³
										//|06- Grupo de Veiculo  0=Veiculo  1=1o Reb.  2=2oReb. 3=3oReb.  ³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										If !lRentab
											aFornec	:= StaticCall(TMSA250,TMA250Forn , 1, "1")

											For nCnt := 1 To Len(aFornec)
												nGrupVei   := aFornec[nCnt,6]
												For nCnt2 := 1 to 2
													If nCnt2 == 1
														cSerOld := DTQ->DTQ_SERTMS
													ElseIf DTQ->DTQ_SERADI == '1'.And. Len(aFrete) < 2
														cSerOld := DTQ->DTQ_SERADI
														aRetBkp := AClone( aRet )
													Else
														Exit
													EndIf

													aRet	:= {}
													aTabPag	:= StaticCall( TMSA250 , TmsTabPag, DTQ->DTQ_FILORI ,DTQ->DTQ_VIAGEM )
													If Len(aTabPag) > 1
														For nTab := 1  to Len(aTabPag)
															cTabFre := aTabPag[nTab][1]
															cTipTab := aTabPag[nTab][2]
															cTabCar := aTabPag[nTab][3]
															nMaxCus := aTabPag[nTab][4]
															aRet := TMSCalFrePag( DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, DTR->DTR_CODVEI, aMsgErr, .T., aFrete, nGrupVei,,,@aDiaHist, cSerOld,cTabFre,cTipTab,cTabCar,.T., nMaxCus, .T. /*lPreview*/)
															If Empty(aMsgErr)
																AAdd(aTabPagCar,{aRet[1,1], aRet[1,2], aRet[1][13], Transform(aRet[1,3],PesqPict('DTY','DTY_VALFRE')), aRet[1,16]})
															Else
																Exit
															EndIf
														Next nTab

														If Len(aRet) > 0
															nSeek := Ascan(aTabPagCar, {|x| x[1] + x[2] + x[3] == aRet[1,1] + aRet[1,2] + aRet[1,13] })
															If nSeek == 0
																AAdd(aTabPagCar,{aRet[1,2], aRet[1,3], aRet[1,13], aRet[1,3]})
															EndIf
														EndIf

														If Len(aTabPagCar) > 1
															nLinha := StaticCall(TMSA250, TmsTabFpg, aTabPagCar)
															If nLinha > 0
																cTabFre := aTabPag[nlinha,1] //-- Tabela de Frete a Pagar
																cTipTab := aTabPag[nlinha,2] //-- Tipo da Tabela de Frete
																cTabCar := aTabPag[nlinha,3] //-- Tabela de Carreteiro
																nMaxCus := aTabPag[nLinha,4] //-- Percentual da Rentabilidade x Custo
																aRet := TMSCalFrePag( DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, DTR->DTR_CODVEI, aMsgErr, .T., aFrete, nGrupVei,,,@aDiaHist, cSerOld, cTabFre, cTipTab, cTabCar, .T., nMaxCus, .T. /*lPreview*/)
															EndIf
														EndIf
													ElseIf Len(aTabpag) == 1
														cTabFre := aTabPag[1][1]
														cTipTab := aTabPag[1][2]
														cTabCar := aTabPag[1][3]
														nMaxCus := aTabPag[1][4]
														aRet := TMSCalFrePag( DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, DTR->DTR_CODVEI, aMsgErr, .T., aFrete, nGrupVei,,,@aDiaHist, cSerOld, cTabFre, cTipTab, cTabCar, .T., nMaxCus, .T. /*lPreview*/)
													Else
														aRet := TMSCalFrePag( DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, DTR->DTR_CODVEI, aMsgErr, .T., aFrete, nGrupVei,,,@aDiaHist, cSerOld,        ,        ,        ,    ,        , .T. /*lPreview*/)
													EndIf

													// Se na segunda vez não realizou o calculo do frete 
													// realizo o backup do array anterior pois não foi 
													// possivel calcular o frete para o Serviço Adicional (DTQ_SERADI).
													// Por isso utilizo o calculo para o Serviço da Viagem (DTQ_SERTMS).
													If nCnt2 == 2 .AND. Len( aRet ) == 0 .AND. Len( aRetBkp ) > 0
														aRet := AClone( aRetBkp )
													EndIf
												Next nCnt2
											Next nCnt
										EndIf
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³GRAVAÇÃO DO PEDÁGIO NO FECHAMENTO DA VIAGEM ³
										//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
										//³A gravação dependerá da configuração do     ³
										//³contrato do fornecedor					   ³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										cCodForn := DTR->DTR_CODFOR
										cLojForn := DTR->DTR_LOJFOR
										cCodOpe	 := DTR->DTR_CODOPE
										cNumIdOpe:= DTR->DTR_PRCTRA
										cCodVeiFor := DTR->DTR_CODVEI
										//--Posiciona no contrato do proprietário do veículo

										//| Obtém o código do tipo do veículo
										cTipVeiFor  := POSICIONE( "DA3", 1, FWxFilial("DA3")+ cCodVeiFor , "DA3_TIPVEI")
										
										//| busca o contrato considerando o tipo de veículo da viagem
										aRetForn := TMSContrFor(cCodForn,cLojForn,,DTQ->DTQ_SERTMS,DTQ->DTQ_TIPTRA,.F.,cTipVeiFor,Iif(lTipOpVg,DTQ->DTQ_TPOPVG,''))

										//| busca o contrato sem considerar o veículo
										If Len(aRetForn) <= 0
											aRetForn := TMSContrFor(cCodForn,cLojForn,,DTQ->DTQ_SERTMS,DTQ->DTQ_TIPTRA,.F.,,Iif(lTipOpVg,DTQ->DTQ_TPOPVG,''))
										EndIf

										If DTR->DTR_VALPDG > 0 .AND. cCodOpe == "03"
											DEK->( DbSetOrder( 2 ) )
											If DEK->( MsSeek( xFilial('DEK') + DTQ->DTQ_ROTA + cCodOpe ) )
												cRoteir := AllTrim( DEK->DEK_ROTEIR )
											EndIf
											nValPdg := PagBemPdg( cRoteir, DTR->DTR_QTDEIX )
											If nValPdg > 0 .AND. DTR->DTR_VALPDG <> nValPdg
												RecLock( "DTR", .F. )
													DTR->DTR_VALPDG  := nValPdg
												DTR->( MsUnlock() )
											EndIf
										EndIf

										If Len(aRetForn) > 0 .And. Len(aRetForn[1]) > 14
											cBxTitPdg:= aRetForn[1,11]
											//--Verifica se o título de pedágio está configurado para ser gerado no fechamento da viagem.
											//--Verifica se existe valor de pedágio para o DTR
											If aRetForn[1,15] == '1' .And. DTR->DTR_VALPDG > 0 .And. DTR->DTR_TITPDG <> '1'

												//--Montar array com os proprietários que terão pedágio gerados...Já que os mesmos fornecedores podem estar em mais de um DTR, com o mesmo veículo ou com veículos diferentes.
												If (nPos := Ascan( aForn, { |x| x[1]+x[2] == DTR->DTR_CODFOR + DTR->DTR_LOJFOR } )) == 0
													Aadd( aForn, { cCodForn, cLojForn, DTR->DTR_FILORI, DTR->DTR_VIAGEM, DTR->DTR_VALPDG, DTR->DTR_CODOPE, 0 ,{DTR->(RECNO())}})
												Else
													aForn[nPos,5] += DTR->DTR_VALPDG
													AADD(aForn[nPos,8],DTR->(RECNO()))
												EndIf

												cDocSDGPDG := NextNumero("SDG",1,"DG_DOC",.T.)
												TMA250GrvSDG("DTR",DTR->DTR_FILORI, DTR->DTR_VIAGEM, cDesPDG, DTR->DTR_VALPDG,nItemSDG,DTR->DTR_CODVEI,cDocSDGPDG,,,,,,,.T.,,,,,,,"TMSA310","2")

												SDG->(dbSetOrder(1))
												If SDG->(MsSeek(FwxFilial('SDG')+cDocSDGPDG))
													FwFreeArray(aCabSDG)
													aCabSDG	:= {} 
													Aadd( aCabSDG , { "DG_TITGER", "1" 			, Nil })
													Aadd( aCabSDG , { "DG_ORITIT", "TMSA310"	, Nil })

													AtuTabSDG( aCabSDG , 4 )
												EndIf
											EndIf

											If Len(aRet) > 0 .Or. nFretePrev > 0

												If !lRentab .AND. Len(aRet) > 0
													nFretePrev	:= aRet[1,3] //-- Valor do frete previsto a pagar
												EndIf

												cFilOri		:= DTQ->DTQ_FILORI
												cViagem		:= DTQ->DTQ_VIAGEM

												//-- Calcula Acréscimos/Decréscimos
												StaticCall( TMSA250 , A250AedVlr , cFilOri , cViagem  ,0,0,0,@nFretePrev)
								
												//-- Calcula o % de Adiantamento
												If DTR->DTR_PERADI > 0 .And. nFretePrev > 0 .And. !Empty(cDesAdf) .And. ;
												( Empty(DTR->DTR_ADIFRE) .Or. !FindAdtSDG( DTR->DTR_FILORI, DTR->DTR_VIAGEM , DTR->DTR_CODVEI , cDesAdf , nVrPerAdi ) )
													nVrPerAdi := Round(nFretePrev*DTR->DTR_PERADI/100,2)
													GeraSDG(DTR->DTR_FILORI, DTR->DTR_VIAGEM, cDesAdf, nVrPerAdi,nItemSDG,DTR->DTR_CODVEI,aRetForn)
												EndIf
												
												If lDTRAbast
													If DTR->DTR_VLABST > 0
														GeraSDG(DTR->DTR_FILORI, DTR->DTR_VIAGEM, cDesABST, DTR->DTR_VLABST,nItemSDG,DTR->DTR_CODVEI,aRetForn)
													EndIf
												EndIf

												//--Montar array com o título valor do adiantamento e provisão de frete por fornecedor
												//--Tendo em vista que o mesmo fornecedor pode estar em linhas de DTR diferentes.
												If (nPos := Ascan( aVlrAdiFrt, { |x| x[1]+x[2] == DTR->DTR_CODFOR + DTR->DTR_LOJFOR } )) == 0
													AADD( aVlrAdiFrt, { cCodForn, cLojForn, nFretePrev , nVrPerAdi, {DTR->(RECNO())},aRetForn, {cDocSDGPDG} } )
												Else
													aVlrAdiFrt[nPos,3] += nFretePrev
													aVlrAdiFrt[nPos,4] += nVrPerAdi
													AADD(aVlrAdiFrt[nPos,5],DTR->(RECNO()))
													AADD(aVlrAdiFrt[nPos,7],cDocSDGPDG)
												EndIf

												If nFretePrev > 0
													If DTR->(ColumnPos("DTR_PRVFRE")) > 0
														RecLock("DTR",.F.)
														DTR->DTR_PRVFRE	:= nFretePrev
														DTR->( MsUnlock() )
													EndIf
												EndIf
												If nVrPerAdi > 0
													RecLock("DTR",.F.)
													DTR->DTR_ADIFRE	+= nVrPerAdi
													DTR->( MsUnlock() )
												EndIf

											EndIf
										EndIf

										DTR->(dbSkip())

									EndDo

								EndIf

								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Gravação Controle diária de motoristas próprios				  ³
								//ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
								// Busca a configuração da Diaria, atraves da Rota
								cCodDia := A310BusDia(DTQ->DTQ_ROTA,DTQ->DTQ_TIPVIA)

								// Busca Parametrização de Diaria
								nRecPar := TMSAB30PARM()

								dbSelectArea("DUP")
								DUP->( dbSetOrder(1) )

								// Busca os Motoristas da Viagem
								If DUP->( dbSeek(FWxFilial("DUP")+DTQ->DTQ_FILORI+ DTQ->DTQ_VIAGEM) ) .AND. !Empty(cCodDia)

									While  DUP->( ! EOF() .AND.	DUP_FILIAL == FWxFilial("DUP") .AND.;
												DUP_FILORI == DTQ->DTQ_FILORI .AND.;
												DUP_VIAGEM == DTQ->DTQ_VIAGEM )

										If  DUP->DUP_PAGDIA == "1"
											If !Empty(nRecPar)

												aItensDia := {}

												// Insere os itens no controle de diarias
												cCodCtrDia := A310IncDia(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,DUP->DUP_CODMOT,cCodDia,DUP->DUP_ITEDTR)
												If 	!Empty(cCodCtrDia)

													dbSelectArea("DYV")
													DYV->( dbSetOrder(1) )

													dbSelectArea("DYX")
													DYX->( dbSetOrder(1) )

													// Busca os itens Inseridos no controle de diarias
													If DYV->( dbSeek(FWxFilial("DYV")+cCodCtrDia ) )
														If DYX->( dbSeek(FWxFilial("DYX")+ cCodCtrDia) )


															While DYX->( ! EOF().AND. DYX_IDCDIA == cCodCtrDia  )

																If	DYX->DYX_ORIGEM == "2" .AND. DYX->DYX_STATUS == "1"
																	AADD(aItensDia,{DYX->DYX_IDCDIA,DYX->DYX_ITEM})
																EndIf

																DYX->( dbSkip() )
															EndDo

															// Aprova os itens do controle de diarias
															TMSAB30API(nRecPar,aItensDia,.T.)
														EndIf
													EndIf
												Else
													DisarmTransaction()
													lContinua := .F.
												EndIf
											Else
												Help('', 1,"HELP",, STR0053,1)//"Não possui uma parametrização Vigente."
												DisarmTransaction()
												lContinua := .F.
											EndIf
										EndIf

										DUP->(dbSkip())
									EndDo
								EndIf

								If lContinua
									//Define qual a ordem de execução das rotinas:
									//MV_TMSERP == '0 OU MV_IMPCTC == '0' (Integra com REPOM, depois faz a geração do título no ERP (PRotheus ou Datasul) )
									//MV_IMPCTC == '1' (Integra com REPOM, depois faz a geração do título no ERP (PRotheus ou Datasul) )
									If cTmsErp == '0' .Or. (cImpCTC == "0" .And. ( cCodOpe == '01' .OR. cCodOpe == '03' ) ) //--ERP
										If lRet := A310IntFin(cTmsErp, aForn, aVlrAdiFrt, nOpcx, cBxTitPdg, lGeraSDG, aRetForn )
											If !A310IntRep( lFecAuto, @aMsgErr, nOpcX, nFretePrev, @cNumIdOpe, , , , @aRegDTR ) .And. cTmsErp == '0'
												//--Se houver falha na INtegração com a REPOM e o ERP for Protheus o fechamento da viagem não será realizado.
												//--Caso não seja ERP Protheu o fechamento da vaigem será concretizado, já que não podemos garantir a exclusão;
												//--do título gerado no financeiro
												lRet := .F.
											EndIF
										EndIf
									Else
										If lRet := A310IntRep(lFecAuto,@aMsgErr, nOpcX, nFretePrev,@cNumIdOpe, @cNumCiot, @cNumIdCli, @cNumIdPdg )
											//--Se houver falha na Integração do Financeiro chama o método da REPOM para solicitar a exclusão do contrato
											lRet := A310IntFin(cTmsErp,aForn, aVlrAdiFrt, nOpcx, cBxTitPdg, lGeraSDG ) 
											//lret:= .T.
											If !lRet
												//| Verifica se existe adapter cadastrado para a rotina e se o mesmo está sincrono...
												//| Caso seja, será solicitado a exclusão do contrato na REPOM
												lEstOk:= .T.
												If cCodOpe == '01'
													lEstOk:= RepContrat(cCodOpe , cFilOri, cViagem,,,,,,5,@aMsgErr)
												ElseIf cCodOpe == '02' 
													A310AtuPam(cFilOri,cViagem,cNumIdOpe, cNumIdCli, cNumIdPdg, cCodVeiFor, cNumCiot)

													lEstOk:= A310EstPam(cCodOpe,DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,DTQ->DTQ_SERTMS,cCodVeiFor,cNumCiot,cNumIdOpe,cNumIdCli,cNumIdPdg)
												EndIf
												If !lEstOk
													Help("",1,"TMSA31029",/*Titulo*/,STR0072 + Space(1) + AllTrim(cNumIdOpe) + Space(1) + ',' + STR0071 , 1, 0 ) //--Devido a falha na Integração do título no financeiro, ocorreu a tentativa de cancelamento do contrato, numero: #"junto a Operadora de Frete, porém a exclusão não foi realizada."
													lGrvIdOpe := .T.
												EndIf
											EndIf
										EndIf
									EndIf

								EndIf

								If !lRet
									DisarmTransaction()

									//AAdd( aRegDTR, { cNumIdOpe, cNumIdPdg, DTR->DTR_ITEM, cNumCIOT, lCiotAgre, lIncCiot, lCancCiot } )
									// Este bloco deve gravar o id em casos onde 
									// o cancelamento da operação na Operadora de Frotas
									// não foi concluido com sucesso.
									DTR->(DbSetOrder(1))//DTR_FILIAL, DTR_FILORI, DTR_VIAGEM, DTR_ITEM
									For nX := 1 To Len(aRegDTR)
										// Por ter ocorrido erro na integração preciso verificar se é CIOT Agregado foi aberto aRegDTR[nX][5] == .T.
										If DTR->( MsSeek( xFilial('DTR') + DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM + aRegDTR[nX][3] ) ) .AND. cCodOpe == "03" .AND. aRegDTR[nX][5]
											// Com CIOT Aberto preciso ver se foi cancelado ou não após 
											// Por este motivo se CIOT Incluido (lIncCiot aRegDTR[nX][6] == .T.) e CIOT Cancelado (lCancCiot aRegDTR[nX][7] == .T.) o ciot foi gerado e cancelado sem problemas não há necessidade de ajustes
											// Se CIOT Incluido (lIncCiot aRegDTR[nX][6] == .T.) e CIOT Não Cancelado  (!lCancCiot aRegDTR[nX][7] == .F.) o ciot foi gerado e não conseguiu cancelar havendo necessidade de ajustes
											// como não conseguiu cancelar o ciot realizo a inclusão do CIOT Agregado na tabela DJL
											// AAdd( aRegDTR, { cNumIdOpe, cNumIdPdg, DTR->DTR_ITEM, cNumCIOT, lCiotAgre, lIncCiot, lCancCiot } )
											If aRegDTR[nX][6] .AND. !aRegDTR[nX][7]
												TMSXJCiot( aRegDTR[nX][6], aRegDTR[nX][4], DTR->DTR_CODVEI, DTR->DTR_DTFMCI, cStatus )
											EndIf
										EndIf
									Next nX

								EndIf
							EndIf
						EndIf
					EndIf
				End Transaction
			EndIf
		EndIf

		If lContinua .And. lRet

			DTR->(DbSetOrder(1))
			If DTR->(MsSeek(xFilial("DTR")+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM))

				//-- Verifica se existe Viagem Interligada "Em Transito"
				If !Empty(DTR->DTR_FILVGE) .And. !Empty(DTR->DTR_NUMVGE)

					aOldAreaDTQ := DTQ->(GetArea())

					If !lFecAuto
						EndFilBrw("DTQ",aIndex)
					EndIf

					DTQ->(DbSetOrder(2))

					If DTQ->(MsSeek(xFilial("DTQ")+DTR->DTR_FILVGE+DTR->DTR_NUMVGE))

				 		If DTQ->DTQ_STATUS == StrZero(2,Len(DTQ->DTQ_STATUS)) // Em Transito.

							//-- Atualizacao dos pesos no registro de entradas/saidas.
							DUV->(DbSetOrder(4))
							If DUV->(MsSeek(xFilial("DUV")+DTR->DTR_FILVGE+DTR->DTR_NUMVGE))
								aPesoVge:= TMSPesoVge(DTR->DTR_FILORI,DTR->DTR_VIAGEM)
								RecLock("DUV",.F.)
								DUV->DUV_PESO   := DUV->DUV_PESO   + aPesoVge[1]
								DUV->DUV_PESOM3 := DUV->DUV_PESOM3 + aPesoVge[2]
								DUV->DUV_PESOST := DUV->DUV_PESOST + aPesoVge[4]
								DUV->DUV_PES3ST := DUV->DUV_PES3ST + aPesoVge[5]
								MsUnlock()
							EndIf

							//-- Armazena Data/Hora das operacoes da viagem interligada.
							DTW->(DbSetOrder(4))
							If DTW->(MsSeek(xFilial("DTW") + DTR->DTR_FILVGE + DTR->DTR_NUMVGE + cAtivSai))
								dDatIni := DTW->DTW_DATINI
								cHorIni := DTW->DTW_HORINI
								dDatRea := DTW->DTW_DATREA
								cHorRea := DTW->DTW_HORREA
							EndIf

							// Atualiza a operacao de saida.
							If DTW->(MsSeek(xFilial("DTW") + DTR->DTR_FILORI + DTR->DTR_VIAGEM + cAtivSai + cFilAnt))
								TMSA350Grv(3, DTR->DTR_FILORI, DTR->DTR_VIAGEM, cAtivSai, dDatIni, cHorIni, dDatRea, cHorRea )
							EndIf
						EndIf
					EndIf
					RestArea( aOldAreaDTQ )

					If !lFecAuto
						CursorWait()
						bFiltraBrw := {|| FilBrowse("DTQ",@aIndex,@cFiltro) }
						Eval(bFiltraBrw)
						CursorArrow()
					EndIf

				EndIf

			EndIf

			Pergunte("TMSA310",.F.)
			
			If lMdfeAut .And. FindFunction("TMA190Srv")  //Verifica o serviço de transporte da viagem
				lMdfeAut:= TMA190Srv(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM)
			EndIf
				
			lCodAut	:= TmsAutViag(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,DTQ->DTQ_CODAUT,"TMSA190")


			If (lMDFEAUT .And. (mv_par01 == 1 .Or. mv_par01 == 2)) .Or.(lMDFEAUT .and. lCodAut) //--  Gera Manifesto ## Gera e Transmite verifica se automacao viagem ativa
								
				RegToMemory("DTQ",.F.)
				If lVgeMod3
					lContinua := TMSAF69GMC( .F., 3, .T.) // Gera o manifesto quando estiver usando a viagem modelo 3
				Else
					lContinua := Tmsa144GMC( .F., 3, .T.) // Gera o manifesto
				EndIf

				Pergunte("TMSA310",.F.)
				
				If lContinua .And. mv_par01 == 2 .Or. (lVgeMod3 .And. lCodAut) //--  Gera e Transmite 
					aMDFe := {}
					DTX->(DbSetOrder(5)) //-- DTX_FILIAL+DTX_FILORI+DTX_VIAGEM+DTX_CODVEI
					DTX->(MsSeek(xFilial("DTX") +  DTQ->(DTQ_FILORI+DTQ_VIAGEM) ))
					Do WHile DTX->(!Eof()) .And. DTX->(DTX_FILIAL+DTX_FILORI+DTX_VIAGEM) == xFilial("DTX")+ DTQ->(DTQ_FILORI+DTQ_VIAGEM)
						If DTX->DTX_TIPMAN  == '2' .And.  DTX->DTX_STIMDF <> '2' //--Eletronico, não autorizado
							Aadd(aMDFe,{DTX->DTX_FILMAN,;
										DTX->DTX_MANIFE,;
										DTX->DTX_MANIFE,;
										DTX->DTX_SERMAN,;
										DTX->DTX_VIAGEM,;
										Iif(lUFAtiv, DTX->DTX_UFATIV, '')})
						EndIf

						DTX->(DbSkip())
					EndDo
					If !Empty(aMDFe)
						TmsMDFeAut(aMDFe, 1) // Envia o Manifesto
					EndIf
				EndIf
			EndIf
					//-- Executa ponto de entrada depois de efetuar a atualizacao dos dados
			If	lTma310GER
				ExecBlock('TMA310GER',.F.,.F.,{3, DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM,lFecAuto} )
			EndIf
		ElseIf lGrvIdOpe
			//--Mesmo que a transação seja desfeita será gravado o número do contrato da REPOM na DTR
			//--Já que o contrato foi incluído na REPOM e não foi possível seu cancelamento.
			If cCodOpe == '01'
				DTR->(DbSetOrder(1))
				If DTR->(MsSeek(xFilial("DTR")+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM))
					RecLock('DTR',.F.)
						DTR->DTR_PRCTRA := cNumIdOpe
					MsUnLock()
				EndIf			
			EndIf
		EndIf
		DTQ->( MsUnLock() )

		If lGrvIdOpe .And. cCodOpe == '02'
			A310AtuPam(cFilOri,cViagem,cNumIdOpe, cNumIdCli, cNumIdPdg)
		EndIf

	Else
		Help( ' ', 1, IIf(nOpcx == 3,"TMSA31019","TMSA31020")) //"O Fechamento(nOpcx == 3) / Estorno do Fechamento(nOpcx <> 3 desta viagem esta sendo efetuado por outro usuario"
	EndIf
EndIf

 If DTQ->DTQ_TIPTRA == StrZero(1,Len(DTQ->DTQ_TIPTRA)) .Or. DTQ->DTQ_TIPTRA == StrZero(4,Len(DTQ->DTQ_TIPTRA)) //-- Rodoviario ou Rodoviario Internacional
	//-- Existe Check List configurado, a integração é no fechamento da viagem e existe a função de busca de documentos
	If (DTQ->DTQ_SERTMS == "1" .Or. DTQ->DTQ_SERTMS == "3") .And. lTMSIntChk .And. lContinua .And. lRet	//-- Somente para viagem de coleta ou entrega

		//-- Busca os documentos da viagem
		aDocsChk := TMSLstChk( DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM )
		
		//-- Envia Check List
		aMsgChk := {}
		aRetEnv := TMSEnvChk( Aclone(aDocsChk), DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, @aMsgChk, @aReenvC )
		
		If !Empty(aMsgChk)
			TmsMsgErr( aMsgChk, , , .T., AClone(aReenvC) )
		EndIf
		FwFreeArray(aMsgChk)
		FwFreeArray(aDocsChk)
		FwFreeArray(aReenvC)
	EndIf
EndIf

If AliasInDic("DN1") .And. ExistFunc( "TM310PrcFe" )
	lOk := TM310PrcFe(nOpcx)
EndIf

If lRet .AND. lMetrica
	// Verifica o Tipo de Frota para realizar o envio da Telemetria
	A310Tele( cFilOri, cViagem )
EndIf

RestArea( aAreaDTR )
RestArea( aAreaDUV )
RestArea( aAreaDT5 )
RestArea( aAreaDT6 )
RestArea( aAreaDC6 )
RestArea( aAreaDC5 )
RestArea( aAreaDA8 )
RestArea( aAreaDA3 )
RestArea( aAreaAnt )

//-- Exibe mensagem de integração realizada com sucesso para o usuário / Integração Datasul.
If cTMSERP == "1"  .And. lRet .And. !Empty(cEAIMsg)
     Aviso(STR0021,cEAIMsg,{STR0004},1) //-- "Atencao","Integração da Viagem: filial + viagem"; "Fechar"
EndIf

If !Empty(aDocImp)
	If lFecAuto
		For nCnt := 1 To Len(aDocImp)
			AutoGrLog(aDocImp[nCnt,1])
		Next nCnt
	Else
		TmsMsgErr(aDocImp)
	EndIf
EndIf

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA310Vge³ Autor ³ Antonio C Ferreira    ³ Data ³06.06.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Visualiza a viagem                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA310Vge()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA310Vge()

Local   aAreaDTQ := DTQ->( GetArea() )
Private INCLUI   := .F.

TmsVisViag(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,DTQ->DTQ_SERTMS,DTQ->DTQ_TIPTRA)

RestArea( aAreaDTQ )

Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuD310  ³ Autor ³ Marco Bianchi         ³ Data ³01/09/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³    1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function MenuD310()

Private aRotina	:= {	{ STR0002 ,'TMSXPesqui',0,1,0,.F.},;	//'Pesquisar'
						{ STR0003 ,'TMSA310Vge',0,2,0,NIL},; 	//'Visualizar'
						{ STR0004 ,'TMSA310Mnt',0,3,0,NIL},; 	//'Fechar'
						{ STR0010 ,'TMSA310Mnt',0,5,0,NIL},; 	//'Estornar'
						{ STR0015 ,'TMSA140Fbr',0,1,0,NIL},; 	//'Status'
						{ STR0005 ,'TMSA140Leg',0,6,0,.F.} } 	//'Legenda'


If ExistBlock("TMA310MNU")
	ExecBlock("TMA310MNU",.F.,.F.)
EndIf

Return(aRotina)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMA310Oper³ Autor ³ Vitor Raspa           ³ Data ³ 15.Nov.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Gera a Viagem na Operadora de Frotas, quando veiculo proprio³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³lRet := TMA310Oper(cExpC1, cExpC2, cExpC3, @aExpA1, nExpN1) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cExpC1 - Codigo da Operadora de Frotas                      ³±±
±±³          ³cExpC2 - Filial de Origem                                   ³±±
±±³          ³cExpC3 - Numero da Viagem                                   ³±±
±±³          ³aExpA1 - Array com as Mensagens de Erro (Por Referencia)    ³±±
±±³          ³nExpN1 - Opcao Selecionada (3-Fechamento / 5-Estorno)       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico - .T. indica sucesso no processamento do metodo      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMA310Oper( cCodOpe, cFilOri, cViagem, aMsgErr, nOpcx, cCodVei, lFechto, nFretePrev, cNumIdOpe, cNumCiot, cNumIdCli, cNumIdPdg)
Local lRet       := .F.
Local lContVei   := GetMV( 'MV_CONTVEI',,.T.) // Verifica se o sistema Controla Motoristas / Veiculos
Local aAreaSIX   := SIX->(GetArea())

Local aArea      := GetArea()
Local nAdiFre    := 0
Local aRetCNPJ   := {}  //Retorna na Primeira posição o CNPJ da Unidade da Empresa Contratante dos servicos do sistema Pamcard, Se a unidade
	                    //da empresa que está utilizando o serviço for igual a unidade que contratou os servicos a Segunda e Terceira posicao
	                    //retornam em branco, se for diferente; a Segunda posicao retornara a informacao que o tipo do documento sera CNPJ e a
	                    //Terceira posição sera o CNPJ da empresa solicitante dos servicos.
Local aConsCard  := {}
Local lFrotaProp := .T.
Local cCodMot    := ''
Local cIdOpe     := ''
Local cCodBan    := ''
Local nTxAdBan   := 0
Local aDadOperad := {}
Local cQuery	 := ""
Local cAliasQry	 := ""
Local aAreaAux   := {}
Local nQtdSaq    := 0
Local nQtdTra    := 0
Local lOk        := .F.
Local lDTRQtdSaq := DTR->(ColumnPos("DTR_QTDSAQ")) > 0
Local cCodFor 	 := ""
Local cLojFor	 := ""
Local aCartoes	 := {}
Local aForPag	 := {}
Local nY		 := 0
Local cInValePdg := '4198'	
Local lLotacao   := .F.
Local lGeraRep   := .F. 
Local lDTRAbast  := DTR->(ColumnPos("DTR_VLABST")) > 0

DEFAULT lFechto  := .F. //indica se a Rotina foi chamada no fechamento da Viagem = .T., ou chamada no apontamento da operacao de saida da Viagem = .F.     - //GILSON - PAMCARD
DEFAULT cNumIdOpe:= ''
DEFAULT cNumCiot := ''
DEFAULT cNumIdCli:= ''
DEFAULT cNumIdPdg:= ''

//-- Configura o tamanho do nome das Variaveis
SetVarNameLen( 255 )

DEG->(DbSetOrder(1))
If DEG->(MsSeek(xFilial('DEG')+cCodOpe))

	If cCodOpe == '01' //-- REPOM Tecnologia
		
		lGeraRep:= T310GerRep()

        //Posiciona na tabela de Complementos da viagem (Veiculo da viagem).
		DTR->(DbSetOrder(1))
		If	DTR->(MsSeek(xFilial('DTR') + cFilOri + cViagem))
			lRet := .T.
			//Posiciona na tabela de veículos.
	     	DA3->(DbSetOrder(1))
			DA3->(MsSeek(xFilial('DA3')+DTR->DTR_CODVEI))
			lFrotaProp := (DA3->DA3_FROVEI == '1')
	    	If !lFrotaProp .And. lGeraRep //!(SuperGetMv("MV_ENREPOM",,"1") $ "1|2")
				If nOpcx == 3
					If lFechto //Se a rotina foi chamada no fechamento da viagem, faz a inclusão do contrato na Repom
						lRet := RepContrat(	DTR->DTR_CODOPE, DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, Iif(!Empty(DTR->DTR_CODFOR+DTR->DTR_LOJFOR),DTR->DTR_CODFOR,DA3->DA3_CODFOR), Iif(!Empty(DTR->DTR_CODFOR+DTR->DTR_LOJFOR),DTR->DTR_LOJFOR,DA3->DA3_LOJFOR),;
						                     Iif(DTR->DTR_VALFRE > 0,DTR->DTR_VALFRE, nFretePrev), DTR->DTR_ADIFRE, @aDadOperad, nOpcx,@aMsgErr, '', DTR->DTR_CODVEI, @cNumIdOpe)

					EndIf
				ElseIf nOpcx == 5 //-- Estorno
					If lFechto //Se a rotina foi chamada no fechamento da viagem, faz a exclusão do contrato na Repom
						lRet := RepContrat(DTR->DTR_CODOPE, DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM,,,,,,nOpcx,@aMsgErr, , , @cNumIdOpe)
					EndIf
				EndIf
	    	ElseIf lContVei .Or. !lFechto   //(lContVei = Integração pelo Fechamento, caso contrario pelo apontamento da Saida da Viagem)
				//-- Bloco de código retirado e movido para o fonte TmsRepom.prw
				lRet := RepCtlVg( @cFilOri, @cViagem, @cCodVei, @cCodOpe, @nOpcx )
			EndIf
		EndIf
   ElseIf cCodOpe == '02' //-- PAMCARD

        //Posiciona na tabela de Complementos da viagem (Veiculo da viagem).
		DTR->(DbSetOrder(1))
		If	DTR->(MsSeek(xFilial('DTR') + cFilOri + cViagem))
			lRet := .T.
			
			//Posiciona na tabela de veículos.
	     	DA3->(DbSetOrder(1))
			DA3->(MsSeek(xFilial('DA3')+DTR->DTR_CODVEI))
	    	lFrotaProp := (DA3->DA3_FROVEI == '1')

			//---- Verifica se a viagem é do Tipo Lotacao (um único CTE na Viagem)
			If lFrotaProp
				If ExistFunc('PamQtDocVg') 
					If PamQtDocVg(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,DTQ->DTQ_SERTMS) == 1
						lLotacao:= .T.						
					EndIf
				EndIf		
			EndIf
			aRetCNPJ   := PamCNPJEmp(cCodOpe, cFilOri) //Função para obter CNPJ da contrante e filial de origem

		   If nOpcx == 3
		   		If !lFrotaProp
					If FindFunction("PamCondut")
				   		lOk := PamCondut (cFilOri, cViagem)  //--Existindo o motorista principal carrega as variaveis com os dados deste. (Posiciona na DUP)
					EndIf

					If lOk
						cCodMot := DUP->DUP_CODMOT
						cIdOpe  := DUP->DUP_IDOPE
					Else
						DUP->(DbSetOrder(1))
						If DUP->(MsSeek(xFilial('DUP')+cFilOri + cViagem))
							//--Carrega as variaveis com o primeiro motorista informado, caso não existir o campo ou não existir um motorista principal será validado o primeiro motorista.
							cCodMot := DUP->DUP_CODMOT
							cIdOpe  := DUP->DUP_IDOPE
						EndIf
					EndIf

					nQtdSaq:= DUP->DUP_QTDSAQ
					nQtdTra:= DUP->DUP_QTDTRA

					If lDTRQtdSaq
						cIdOpe := TMSIDPAM(DTR->DTR_FILORI,DTR->DTR_VIAGEM,'2') //parcela de saldo
						aForPag:= TmsForPag(DTR->DTR_FILORI,DTR->DTR_VIAGEM)
						For nY:=1 to Len(aForPag) //Carrega array com todos os cartões da viagem
							If !Empty(aForPag[nY,4])
								If aForPag[nY,3] == '1' .And. Empty(aForPag[nY,5])
									cCodFor := DTR->DTR_CODFOR
									cLojFor := DTR->DTR_LOJFOR
								Else
									cCodFor := aForPag[nY,5]
									cLojFor := aForPag[nY,6]
								EndIf
								If Ascan(aCartoes,{|x| x[1] == aForPag[nY,4]}) == 0
									Aadd(aCartoes,{aForPag[nY,4],cCodFor,cLojFor})
								EndIf
							EndIf
						Next nY
					EndIf
				EndIf

				If lFechto //Se a rotina foi chamada no fechamento da viagem , faz a inclusão da viagem ou contrato no sistema Pamcard.
					If lFrotaProp //Se frota Propria faz a Inclusao da viagem no sistema Pamcard.
						If lLotacao
							lRet:= PamIncCont( cFilOri, cViagem, aRetCNPJ)  
						Else	
							lRet:= PamIncViag(cFilOri, cViagem, aRetCNPJ)
						EndIf							
					Else //Se Terceiros ou Agregados faz a Inclusao do contrato no sistema Pamcard.
						//Posiciona na tabela de veículos.
						If Len(aCartoes)>0
							DA4->(DbSetOrder(1))
							If DA4->(MsSeek(xFilial('DA4')+cCodMot))
								For nY:= 1 to Len(aCartoes)
									aConsCard := {}
									AAdd(aConsCard,{'viagem.contratante.documento.numero',aRetCNPJ[1]})
									AAdd(aConsCard,{'viagem.unidade.documento.tipo'      ,aRetCNPJ[2]})
									AAdd(aConsCard,{'viagem.unidade.documento.numero'    ,aRetCNPJ[3]})
									AAdd(aConsCard,{'viagem.cartao.numero',AllTrim(aCartoes[nY,1]) } )
									If cInValePdg <> Padr(aCartoes[nY,1],4) 
										lRet := PamFindCar(aConsCard, .T.,.T.,,,aCartoes[nY,2],aCartoes[nY,3])
										If !lRet
											Exit
										Endif
									EndIf	
								Next nY
							EndIf

						ElseIf !Empty(cIdOpe)
							//-- Montagem Array para Integração com PamCard
							AAdd(aConsCard,{'viagem.contratante.documento.numero',aRetCNPJ[1]})
							AAdd(aConsCard,{'viagem.unidade.documento.tipo'      ,aRetCNPJ[2]})
							AAdd(aConsCard,{'viagem.unidade.documento.numero'    ,aRetCNPJ[3]})
							AAdd(aConsCard,{'viagem.cartao.numero',AllTrim(cIdOpe) } )
							DA4->(DbSetOrder(1))
							If DA4->(MsSeek(xFilial('DA4')+cCodMot)) .And. cInValePdg <> PADR(cIdOpe,4)
								lRet := PamFindCar(aConsCard, .T.)
							EndIf

						EndIf
						If lRet
							If AliasInDic("DJL") .And. DTR->(ColumnPos("DTR_TPCIOT")) > 0 .And. DTR->DTR_TPCIOT == "2"
								cQuery := " SELECT DJL_CIOT,"
								cQuery += "        DJL_CODVEI, "
								cQuery += "        DJL_DATINI, "
								cQuery += "        DJL_DATFIM, "
								cQuery += "        DJL_STATUS  "
								cQuery += " FROM " + RetSqlName("DJL")
								cQuery += " WHERE  DJL_CODVEI = '"+DTR->DTR_CODVEI+"'"
								cQuery += " AND    DJL_STATUS = '"+StrZero(1,Len(DJL->DJL_STATUS))+"'"
								cQuery += " AND    DJL_DATINI <= '"+DtoS(dDataBase)+"'"
								cQuery += " AND    DJL_DATFIM >= '"+DtoS(dDataBase)+"'"
								cQuery += " AND    DJL_FILIAL = '" +xFilial("DJL") +"'"
								cQuery += " AND    D_E_L_E_T_ = ' '"

								cQuery := ChangeQuery(cQuery)

								cAliasQry := GetNextAlias()
								aAreaAux := GetArea()
								DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
								If (cAliasQry)->(!Eof() .And. !Empty(DJL_CIOT))
									lRet:= PamAltCont( (cAliasQry)->DJL_CIOT, cFilOri, cViagem, aRetCNPJ)
								Else
									lRet:= PamIncCont( cFilOri, cViagem, aRetCNPJ)
								EndIf
								(cAliasQry)->(DbCloseArea())
								RestArea(aAreaAux)
							Else
								lRet:= PamIncCont( cFilOri, cViagem, aRetCNPJ)
							EndIf
						EndIf
			
					EndIf
					
					If lRet
						cNumIdOpe:= DTQ->DTQ_IDOPE
						cNumCiot := DTR->DTR_CIOT
						cNumIdCli:= DTQ->DTQ_IDCLI
						cNumIdPdg:= DTQ->DTQ_IDPDG
					EndIf

				Else  //Se a rotina foi chamada no apontamento da operacao de saida da viagem, muda o Status da parcela do contrato ou da viagem no sistema Pamcard de pendente para liberada.
					If lFrotaProp //Se Frota Propria, verifica se existe parcela para a viagem no sistema Pamcard e muda o status para Liberada.
						//Modificar o status da parcela de pendente para liberada
						lRet := PamAltPaVg(cFilOri, cViagem, aRetCNPJ)
					Else //Apto da saida viagem terceiros/agregados.

						If lDTRQtdSaq
							If DTR->DTR_QTDSAQ > 0 .And.  DTR->DTR_QTDTRA > 0  //Tratamento caso os campos criados recentemente estejam com conteudo vazio
								nQtdSaq:= DTR->DTR_QTDSAQ
								nQtdTra:= DTR->DTR_QTDTRA
							EndIf
						EndIf

						cCodBan	:= PamCodBan(cCodMot, AllTrim(cIdOpe),cFilOri, cViagem)
						nTxAdBan:= PamTaxTot(cCodBan, nQtdSaq, nQtdTra)

						nAdiFre := PamAdiFre(cFilOri, cViagem, DTR->DTR_CODVEI)

						If nAdiFre > 0  //Se existirem despesas que movimentam banco(Adiantamento).
							nAdiFre += nTxAdBan
							lRet:= PamLibPaAd(cFilOri, cViagem, aRetCNPJ ) //libera a parcela de adiantamento.
						EndIf
						If lDTRAbast
							If DTR->DTR_VLABST > 0
								lRet:= PamLibPaAd(cFilOri, cViagem, aRetCNPJ, .T.) //libera a parcela de abastecimento
							EndIf
						EndIf
					EndIf
				EndIf
			ElseIf nOpcx == 5 // -- Estorno do Fechamento da viagem ou Estorno do Apontamento da operação de saida no TMS

				lRet := ExcVgePam( lFechto, lFrotaProp, lLotacao, cFilOri, cViagem, aRetCNPJ, DTR->DTR_CIOT )

			EndIf
		Else
			Aviso("Atenção", STR0040, {"Continuar"}  ) //Nao existe complemento para a viagem.
			lRet := .F.
		EndIf
    EndIf
Else
	aMsgErr := TMSErrOper(cCodOpe,STR0039, '3') //-- "Codigo Nao Encontrado da Tabela DEG"
	lRet := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ATUALIZA O COMPLEMENTO DE VIAGEM (DTR)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet .And. nOpcx == 5
	RecLock('DTR',.F.)
	DTR->DTR_PRCTRA := CriaVar('DTR_PRCTRA')
	MsUnLock()
	//--- Atualiza DM5_PRCTRA == DTR_PRCTRA
	If FindFunction('TM15AtuDM5') .And. AliasIndic('DM5')
		TM15AtuDM5(DTR->DTR_FILORI,DTR->DTR_VIAGEM,'') 
	EndIf

	 //-- Atualizada dados do Contrato de Carreteiro
	If lRestRepom .And. FindFunction("TM15AtuDTY") 
    	TM15AtuDTY(cFilOri,cViagem,'')
	EndIf
EndIf

//-- Configura o tamanho do nome das Variaveis
SetVarNameLen( 10 )


RestArea( aAreaSIX )
RestArea( aArea )
Return( lRet )

 /*/-----------------------------------------------------------
{Protheus.doc} A310IncDia()
Realiza a inclusão de Diarias

Uso: TMSA310

@sample
//A310IncDia(cFilOrig,cViagem,cCodMot,cCodDia)

@author Paulo Henrique Corrêa Cardoso.
@since 17/01/2014
@version 1.0
-----------------------------------------------------------/*/
Static Function A310IncDia(cFilOrig,cViagem,cCodMot,cCodDia,cItemDTR)
Local aAux			:= {}		// Array auxiliar para a inclusão dos itens
Local aCampPai 	 	:= {}		// Array para armazenar os campos e valores do cabeçalho
Local aCampFilho 	:= {}		// Array para armazenar os campos e valores dos itens
Local aErro			:= {}		// Array para armazenar os detalhes do erro de valiação
Local aItens  		:= {}		// Array para armazenar os campos da estrutura de Itens
Local aMaster 		:= {}		// Array para armazenar os campos da estrutura de cabaçalho
Local lContinua		:= .T.		// Verifica se continua o Processamento
Local cRet 			:= ""		// Recebe o Retorno
Local nItErro 		:= 0 		// Recebe a linha que ocorreu o erro
Local nPos    		:= 0		// recebe a posição dos campos
Local nCount     	:= 0		// Recebe o contador
Local nCount2		:= 0		// Recebe o contador 2 para os itens
Local oModel		:= NIL		// Recebe o Modelo Principal
Local oModelMast	:= NIL 		// Recebe o Modelo do Cabeçalho
Local oModelItem 	:= NIL		// Recebe o Modelo dos Itens
Local oStrucMast	:= NIL		// Recebe a Estrutura do Cabeçalho
Local oStrucItem	:= NIL		// Recebe a Estrutura dos Itens
Local cCondut		:= ""		// Recebe o Tipo de Condutor (Principal/Auxiliar)
Local cTipVia		:= ""		// Recebe o Tipo da Viagem
Local nItem			:= 0		// Recebe o Item do Controle de Viagem
Local cVeiculo		:= ""		// Recebe o Veiculo
Local cTipVei		:= ""		// Recebe o Tipo do veiculo

Default cFilOrig	:= ""		// Filial de Origem
Default cViagem		:= ""		// Viagem
Default cCodMot		:= ""		// Codigo do Motorista
Default cCodDia		:= ""		// Codigo da Diaria


// Cria o array com os valores de cabeçalho
aAdd( aCampPai, { 'DYV_CODMOT', cCodMot } )
aAdd( aCampPai, { 'DYV_FILORI', cFilOrig} )
aAdd( aCampPai, { 'DYV_VIAGEM', cViagem } )

dbSelectArea("DUP")
DUP->(dbSetOrder(2))

dbSelectArea("DYT")
DYT->(dbSetOrder(1))

cTipVia	 := POSICIONE( "DTQ", 2, FWxFilial("DTQ")+ cFilOrig + cViagem , "DTQ_TIPVIA")
cVeiculo := POSICIONE( "DTR", 1, FWxFilial("DTR")+ cFilOrig + cViagem + cItemDTR, "DTR_CODVEI")
cTipVei  := POSICIONE( "DA3", 1, FWxFilial("DA3")+ cVeiculo , "DA3_TIPVEI")
If DUP->( dbSeek(FWxFilial("DUP")+ cFilOrig + cViagem + cCodMot ) )

	If ! Empty(DUP->DUP_CONDUT)
		cCondut := DUP->DUP_CONDUT
	Else
		cCondut := "1"
	EndIf

EndIf

If DYT->( dbSeek(FWxFilial("DYT") + cCodDia) )
	// Cria o array com os valores dos itens
	nItem := 1
	While DYT->( ! EOF() .AND. ALLTRIM(DYT_IDDIA) == ALLTRIM(cCodDia) )
		If  DYT->DYT_CONDUT == cCondut .AND. DYT->DYT_TIPVEI == cTipVei
			aAux := {}
			aAdd( aAux, { 'DYX_ITEM'  , STRZERO(nItem,3)} )
			aAdd( aAux, { 'DYX_DATDIA', dDataBase 		} )
			aAdd( aAux, { 'DYX_TIPVIA', cTipVia			} )
			aAdd( aAux, { 'DYX_CONDUT', cCondut 		} )
			aAdd( aAux, { 'DYX_TIPVAL', DYT->DYT_TIPVAL } )
			aAdd( aAux, { 'DYX_TIPVEI', DYT->DYT_TIPVEI } )
			aAdd( aAux, { 'DYX_QTDE'  , DYT->DYT_QTDE } )
			aAdd( aAux, { 'DYX_VLRUNI', DYT->DYT_VLRUNI } )
			aAdd( aAux, { 'DYX_VLRTOT', DYT->DYT_QTDE * DYT->DYT_VLRUNI } )
			aAdd( aAux, { 'DYX_ORIGEM', '2' } )
			aAdd( aCampFilho, aAux )
			nItem += 1
		EndIf
		DYT->(dbSkip())
	EndDo


	// Carrega o Model
	oModel := FWLoadModel( 'TMSAB30' )
	oModel:SetOperation( 3 ) //3 - Inclusão / 4 - Alteração / 5 - Exclusão

	// Ativa o Model
	oModel:Activate()


	// Carrega o Model Master
	oModelMast := oModel:GetModel( "MdFieldDYV" )
	oStrucMast := oModelMast:GetStruct()
	aMaster := oStrucMast:GetFields()

	// Insere os valores do Cabeçalho
	For nCount := 1 To Len( aCampPai )
		If ( nPos := aScan( aMaster, { |x| AllTrim( x[3] ) == AllTrim( aCampPai[nCount][1] ) } ) ) > 0
			If !(oModel:SetValue( "MdFieldDYV" , aCampPai[nCount][1], aCampPai[nCount][2]))
				lContinua := .F.
				Exit
			EndIf
		EndIf
	Next nCount
Else
	lContinua := .F.
EndIf

If lContinua

	// Carrega o Model de Detalhe
	oModelItem := oModel:GetModel( "MdGridDYX" )
	oStrucItem := oModelItem:GetStruct()
	aItens 	   := oStrucItem:GetFields()

	nCount	:= 0
	nPos 	:= 0
	nItErro := 0

	// Insere os itens de Detalhe
	For nCount := 1 To Len( aCampFilho )

		//Adiciona novas linhas
		If nCount > 1
			If  (nItErro :=oModelItem:AddLine()) <> nCount
				lContinua := .F.
				Exit
			EndIf
		EndIf

		nCount2 := 0

		// Preenche os campos de Item
		For nCount2 := 1 To Len( aCampFilho[nCount] )
			If ( nPos := aScan( aItens, { |x| AllTrim( x[3] ) == AllTrim( aCampFilho[nCount][nCount2][1] ) } ) ) > 0
				If !(oModel:SetValue( "MdGridDYX", aCampFilho[nCount][nCount2][1], aCampFilho[nCount][nCount2][2] ) )
					lContinua := .F.
					nItErro := nCount
					Exit
				EndIf
			EndIf
		Next nCount2

		If !lContinua
			Exit
		EndIf

	Next nCount
EndIf

If lContinua
	// Se o dados foram validados faz-se a gravação efetiva dos dados (commit)
	If ( lContinua := oModel:VldData() )
		oModel:CommitData()
	EndIf
EndIf

If !lContinua
	// Se os dados não foram validados obtemos a descrição do erro para gerar LOG ou mensagem de aviso
	aErro := oModel:GetErrorMessage()

	AutoGrLog( STR0043 + ' [' + AllToChar( aErro[1] ) + ']' ) //"Id do formulário de origem:"
	AutoGrLog( STR0044 + ' [' + AllToChar( aErro[2] ) + ']' ) //"Id do campo de origem: "
	AutoGrLog( STR0045 + ' [' + AllToChar( aErro[3] ) + ']' ) //"Id do formulário de erro: "
	AutoGrLog( STR0046 + ' [' + AllToChar( aErro[4] ) + ']' ) //"Id do campo de erro: "
	AutoGrLog( STR0047 + ' [' + AllToChar( aErro[5] ) + ']' ) //"Id do erro: "
	AutoGrLog( STR0048 + ' [' + AllToChar( aErro[6] ) + ']' ) //"Mensagem do erro: "
	AutoGrLog( STR0049 + ' [' + AllToChar( aErro[7] ) + ']' ) //"Mensagem da solução: "
	AutoGrLog( STR0050 + ' [' + AllToChar( aErro[8] ) + ']' ) //"Valor atribuído: "
	AutoGrLog( STR0051 + ' [' + AllToChar( aErro[9] ) + ']' ) //"Valor anterior: "

	//Se o Erro ocorrer nos itens
	If nItErro > 0
		AutoGrLog( STR0052 + ' [' + AllTrim( AllToChar( nItErro ) ) + ']' ) //"Erro no Item: "
	EndIf

	MostraErro()
Else
	cRet := FwFldGet("DYV_IDCDIA")
EndIf

// Desativamos o Model
oModel:DeActivate()
Return cRet

 /*/-----------------------------------------------------------
{Protheus.doc} A310BusDia()
Busca o codigo da Diaria

Uso: TMSA310

@sample
//A310BusDia(cRota,cTipVia)

@author Paulo Henrique Corrêa Cardoso.
@since 29/01/2014
@version 1.0
-----------------------------------------------------------/*/
Static Function A310BusDia(cRota,cTipVia)
Local cRet 		:= "" 		// Recebe o retorno
Local cQuery	:= ""		// Recebe a Query
Local cAliasQRY := ""		// Recebe o Proximo alias disponivel

cAliasQRY := GetNextAlias()

// Busca a diaria para a Rota/Tipo de Viagem

cQuery += " SELECT DYS_IDDIA 				  												"
cQuery += "  FROM " + RetSqlName( 'DYS' )+ " DYS 											"
cQuery += "  WHERE  DYS.D_E_L_E_T_ = ' '													"
cQuery += " 		AND (																	"
cQuery += " 			    ( DYS_ROTA = '"+ cRota +"'  AND DYS_TIPVIA = '"+ cTipVia +"')	"
cQuery += " 			 	OR (DYS_ROTA = '"+ cRota +"'  AND   DYS_TIPVIA = '')			"
cQuery += " 			 	OR (DYS_TIPVIA = '"+ cTipVia +"' AND DYS_ROTA = '')				"
cQuery += " 			 )																	"
cQuery += " 	 	AND DYS_FILIAL = '"+ FWxFilial("DYS") +"'								"
cQuery += "  ORDER BY DYS_ROTA  DESC ,DYS_TIPVIA  DESC												"

cQuery := ChangeQuery(cQuery)

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAliasQRY, .F., .T. )

If !(cAliasQRY)->(EOF())
	cRet := (cAliasQRY)->DYS_IDDIA
EndIf
(cAliasQRY)->( dbCloseArea() )

Return cRet

/*/-----------------------------------------------------------
{Protheus.doc} A310DiaEst()
Busca os itens do controle de diarias de uma viagem para o estorno.

Uso: TMSA310

@sample
//A310DiaEst(cFilOri, cViagem)

@author Paulo Henrique Corrêa Cardoso.
@since 29/01/2014
@version 1.0
-----------------------------------------------------------/*/
Static Function A310DiaEst(cFilOri, cViagem)
Local aRet := {}			// Recebe o Retorno
Local cQuery	:= ""		// Recebe a Query
Local cAliasQRY := ""		// Recebe o Proximo alias disponivel

cQuery += " SELECT DYV_IDCDIA,DYX_ITEM,DYX_NUMTIT "
cQuery += " FROM " + RetSqlName( 'DYV' )+ " DYV "
cQuery += " INNER JOIN " + RetSqlName( 'DYX' )+ " DYX"
cQuery += " ON DYV_IDCDIA = DYX_IDCDIA"

cQuery += " WHERE   DYV.D_E_L_E_T_ = ' ' "
cQuery += " 		AND DYX.D_E_L_E_T_ = ' ' "
cQuery += " 		AND DYV_FILIAL = '"+ FWxFilial("DYV") +"'"
cQuery += " 		AND DYX_FILIAL = '"+ FWxFilial("DYX") +"'"
cQuery += " 		AND DYX_ORIGEM = '2'"
cQuery += " 		AND DYX_STATUS = '3'"
cQuery += " 		AND DYV_VIAGEM = '"+ cViagem +"'"
cQuery += " 		AND DYV_FILORI = '"+ cFilOri +"'"

cAliasQRY := GetNextAlias()
cQuery := ChangeQuery(cQuery)

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAliasQRY, .F., .T. )

While !(cAliasQRY)->(EOF())
	AADD(aRet,{(cAliasQRY)->DYV_IDCDIA,(cAliasQRY)->DYX_ITEM,(cAliasQRY)->DYX_NUMTIT})

	(cAliasQRY)->( dbSkip() )
EndDo

(cAliasQRY)->( dbCloseArea() )

Return aRet
/*/-----------------------------------------------------------
{Protheus.doc} TMA310RRE()
Executa o Chek-List da Viagem e gera o Bloqueio da Viagem
se necessário

Uso: TMSA310

@sample
//TMA310RRE(cFilOri, cViagem)

@author Katia
@since 08/09/2015
@version 1.0
-----------------------------------------------------------/*/
Function TMA310RRE(cFilOri, cViagem, lFecAuto)

Local lRet      := .T.
Local cQryDJ9   := ""
Local cQuery    := ""
Local cMotBlq   := ""
Local aDiverg   := {}
Local cStReg    := ""
Local aArea     := GetArea()
Local lContinua := .F.
Local lTmsa029  := FindFunction("TMSA029USE")

Default cFilOri   := ""
Default cViagem   := ""
Default lFecAuto  := .F.

If lTmsa029 .And. Tmsa029Use("TMSA310")
	cStReg := Tmsa029Blq( 9  ,'TMSA310', 'RR'  ,DTQ->DTQ_FILORI, 'DTQ' , '1' ,DTQ->(DTQ_FILIAL+DTQ_FILORI+DTQ_VIAGEM), DTQ->DTQ_VIAGEM , "", )

	If cStReg <> "L" //Liberado Totalmente

		TMA310EstR()  //Caso Existam Bloqueios, Limpa Referencia
		//-- Executa Rotina de Validação da RRE para gravar tabela DJ9
		TMSIncoRRE(,,'TMSA310',cFilOri,cViagem)

		cQryDJ9:= GetNextAlias()
		cQuery:= " SELECT COUNT(*) NREG FROM " +  RetSqlName("DJ9") + " DJ9 "
		cQuery+= " WHERE DJ9_FILIAL = '" + xFilial("DJ9") + "' "
		cQuery+= " AND DJ9_FILORI = '" + cFilOri + "' "
		cQuery+= " AND DJ9_VIAGEM = '" + cViagem + "' "
		cQuery+= " AND DJ9.D_E_L_E_T_=' ' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cQryDJ9, .F., .T.)
		If (cQryDJ9)->NREG > 0
			lContinua:= .T.
		EndIf
		(cQryDJ9)->(dbCloseArea())

		If lContinua
			//-- Executa Tela do Chek List para marcação
			FWExecView('RRE', 'TMSA034', 4, , { || .T. } )

			//-- Verifica itens obrigatorios que nao foram marcados
			cQryDJ9:= GetNextAlias()
			cQuery:= " SELECT DJ9_IDMARK, DJ9_IDCHK, DJ9_DATCHK, DJ9_OBRIGA, DJ3_DESCRI FROM " +  RetSqlName("DJ9") + " DJ9 "
			cQuery+= " INNER JOIN " + RetSqlName("DJ3") + " DJ3 "
			cQuery+= " ON DJ3_FILIAL = '" + xFilial("DJ3") + "' "
			cQuery+= " AND DJ3_CODIGO = DJ9_IDCHK "
			cQuery+= " AND DJ3.D_E_L_E_T_= ' ' "
			cQuery+= " WHERE DJ9_FILIAL = '" + xFilial("DJ9") + "' "
			cQuery+= " AND DJ9_FILORI = '" + cFilOri + "' "
			cQuery+= " AND DJ9_VIAGEM = '" + cViagem + "' "
			cQuery+= " AND DJ9_OBRIGA = '1' "   //Sim
			cQuery+= " AND DJ9_CODUSR = ' ' "
			cQuery+= " AND DJ9.D_E_L_E_T_=' ' "
			cQuery := ChangeQuery(cQuery)

			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cQryDJ9, .F., .T.)

			While (cQryDJ9)->(!Eof())

				cMotBlq +=	( 		"CHECK-LIST: # " + (cQryDJ9)->DJ9_IDCHK + " - "  + (cQryDJ9)->DJ3_DESCRI	+"#"+;
									STR0065 + "#" +; //"Descrição:"
									(cQryDJ9)->DJ3_DESCRI  + "|" )

				aAdd(aDiverg,{'CHECK-LIST: ' + (cQryDJ9)->DJ9_IDCHK,'RR',(cQryDJ9)->DJ3_DESCRI})

				(cQryDJ9)->(dbSkip())
			EndDo
			(cQryDJ9)->(dbCloseArea())

			//-- GeraBloqueio RRE
			If !Empty(cMotBlq)
				If !lFecAuto
					SaveInter()
					TmA310LST(aDiverg) //-- Monta Dialog Com RRE
					RestInter()
				Else
					AutoGrLog(STR0057 +cMotBlq)   //-- Tipo de Bloqueio
				EndIf

				If Tmsa029Blq( 3  ,; 			// 01 - nOpc
					'TMSA310',;					// 02 - Rotina
					'RR',;							// 03 - Tipo Bloq
					DTQ->DTQ_FILORI,;				// 04 - Filial Origem
					'DTQ',;						// 05 - Tabela Referencial
					'1',;							// 06 - Indice Da Tabela
					DTQ->(DTQ_FILIAL+DTQ_FILORI+DTQ_VIAGEM),; // 07 - Chave Indexação
					DTQ->DTQ_VIAGEM,;				// 08 - Código Que Será Apresentado Ao Usuário Para Identificação Do Registro
					cMotBlq        ,;				// 09 - Detalhes Adicionais a Respeito Do Bloqueio
					)								// 10 - Opcao Rotina

				EndIf
				lRet:= .F.
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aArea)
Return lRet

/*/{Protheus.doc} A310Rentab
//Calcula rentabilidade prévia
@author caio.y
@since 20/07/2017
@version undefined
@param cFilOri, characters, Filial de Origem
@param cViagem, characters, Viagem
@param nOpcx, numerical, opção de menu
@param nFretePrev,numerical, frete previsto
@type function
/*/
Static Function A310Rentab(cFilOri , cViagem , nOpcx , nFretePrev  )
Local aRet		:= {}
Local aArea		:= GetArea()
Local lRet		:= .F.
Local cStReg	:= ""
Local cMotBlq	:= ""
Local aDiverg	:= {}

Default cFilOri		:= ""
Default cViagem		:= ""
Default nOpcx		:= 5
Default nFretePrev	:= 0

If nOpcx == 3
	If Tmsa029Use("TMSA310")
		cStReg := Tmsa029Blq( 9 ,'TMSA310', 'RP'  ,DTQ->DTQ_FILORI, 'DTQ' , '1' ,DTQ->(DTQ_FILIAL+DTQ_FILORI+DTQ_VIAGEM), DTQ->DTQ_VIAGEM , "", )

		If cStReg <> "L" //Liberado Totalmente

			aRet	:= TMSRentab(3,DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM)

			If Len(aRet) > 0

				If aRet[1,1]
					lRet		:= .T.
					nFretePrev	:= aRet[1,9]

					If aRet[1,13]  < aRet[1,12]
						lRet		:= .F.
						nFretePrev	:= 0

						cMotBlq		:= STR0073 + ": # " + aRet[1,4]  + "#"	//-- RENTABILIDADE PRÉVIA
						cMotBlq		+= RetTitle('DL3_RENTAB' ) + ": # " + cValToChar(aRet[1,13]) + " #| "

						aAdd(aDiverg,{STR0073 + ": " + aRet[1,4] ,'RP', cValToChar(aRet[1,13]) }) //-- RENTABILIDADE PRÉVIA

						//-- Exibe tela
						A310ErrRent(aDiverg)

						/*#DEFINE RETSTATUS 	1
						#DEFINE RETFILORI 	2
						#DEFINE RETVGE 		3
						#DEFINE RETNUMSIM 	4
						#DEFINE RETTABFRE 	5
						#DEFINE RETTIPTAB	6
						#DEFINE RETTABCAR	7
						#DEFINE RETVALRCT	8
						#DEFINE RETVALTMS	9
						#DEFINE RETVALGFE	10
						#DEFINE RETVALTOT	11
						#DEFINE RETPERCUS	12
						#DEFINE RETRENTAB	13*/

						If Tmsa029Blq( 3  ,; 			// 01 - nOpc
							'TMSA310',;					// 02 - Rotina
							'RP',;						// 03 - Tipo Bloq
							DTQ->DTQ_FILORI,;			// 04 - Filial Origem
							'DTQ',;						// 05 - Tabela Referencial
							'1',;						// 06 - Indice Da Tabela
							DTQ->(DTQ_FILIAL+DTQ_FILORI+DTQ_VIAGEM),; // 07 - Chave Indexação
							DTQ->DTQ_VIAGEM,;			// 08 - Código Que Será Apresentado Ao Usuário Para Identificação Do Registro
							cMotBlq        ,;			// 09 - Detalhes Adicionais a Respeito Do Bloqueio
							)							// 10 - Opcao Rotina

						EndIf

					EndIf

				Else
					lRet	:= .F.
				EndIf

			EndIf
		Else
			aRet		:= TMSRentab(3,DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM, .F.)
			nFretePrev	:= aRet[1,9]
			lRet		:= .T.
		EndIf
	Else

		aRet := TMSRentab(3,DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,.T. )

		If Len(aRet) > 0
			If aRet[1,1]
				lRet	:= .T.
			EndIf
			nFretePrev	:= aRet[1,9]
		EndIf

	EndIf

ElseIf nOpcx == 5 //-- Estorno do fechamento

	//-- Exclusão Rentablidade Prévia
	aRet	:= TMSRentab( 5 , DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM , .F. )
	lRet	:= .T.
	//-- Exclusão bloqueios
	Tmsa029Blq( 5  				,;	//-- 01 - nOpc
				'TMSA310'		,;	//-- 02 - cRotina
				'RP'  			,;	//-- 03 - cTipBlq
				DTQ->DTQ_FILORI	,;	//-- 04 - cFilOri
				'DTQ'	 		,;	//-- 05 - cTab
				'1' 			,;	//-- 06 - cInd
				DTQ->DTQ_FILIAL + DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM,; //-- 07 - cChave
				"" 				,;	//-- 08 - cCod
				"" 				,;	//-- 09 - cDetalhe
				5)					//-- 10 - Opcao da Rotina

EndIf

RestArea(aArea)
Return lRet


/*/{Protheus.doc} A310ErrRent
//Lista itens de bloqueio
@author caio.y
@since 24/07/2017
@version undefined
@param aDiverg, array, descricao
@type function
/*/
Static Function A310ErrRent(aDiverg)

Local aArea 		:= GetArea()
Local oDlg 			:= Nil
Local oDiverg  		:= Nil
Local aCoordenadas	:= MsAdvSize(.T.)
Local lOpcClick 	:= .F.
Local aButtons		:= {}
Local cTitulo		:= STR0073 //-- Rentabilidade Previa
Local aCab			:= {STR0056,STR0057,  RetTitle('DL3_RENTAB') } // { "Codigo","Tp.Bloqueio", % Rentabilidade"}

Default aDiverg      := {}

oDlg		:= TDialog():New(000,000,aCoordenadas[6],aCoordenadas[5],OemToAnsi(cTitulo ),,,,,,,,oMainWnd,.T.)				// Tela Inteira
oDiverg		:= TWBrowse():New(030,003,oDlg:nClientWidth/2-5,oDlg:nClientHeight/2-45,,aCab,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)

oDiverg:SetArray(aDiverg)

oDiverg:bLine := {||{;
		aDiverg[oDiverg:nAt][01],;
		aDiverg[oDiverg:nAt][02],;
		aDiverg[oDiverg:nAt][03]}}

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,,{||oDlg:End()},, aButtons,,,,,,.F. )

RestArea(aArea)

Return(lOpcClick)

/*/-----------------------------------------------------------
{Protheus.doc} TMA310LST()
Lista os itens do Chek List que foram bloqueados

Uso: TMSA310

@sample
//TMA310LST(aDiverg)

@author Katia
@since 08/09/2015
@version 1.0
-----------------------------------------------------------/*/
Function TMA310LST(aDiverg)

Local aArea 			:= GetArea()
Local oDlg 			:= Nil
Local oDiverg  		:= Nil
Local aCoordenadas	:= MsAdvSize(.T.)
Local lOpcClick 		:= .F.
Local aButtons		:= {}
Local cTitulo			:= STR0055 //-- Exigências Da Regra De Restrição De Embarque
Local aCab				:= {STR0056,STR0057, STR0058} // { "Codigo","Tp.Bloqueio","Exigencia"}

Default aDiverg      := {}

oDlg		:= TDialog():New(000,000,aCoordenadas[6],aCoordenadas[5],OemToAnsi(cTitulo ),,,,,,,,oMainWnd,.T.)				// Tela Inteira
oDiverg	:= TWBrowse():New(030,003,oDlg:nClientWidth/2-5,oDlg:nClientHeight/2-45,,aCab,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)

oDiverg:SetArray(aDiverg)

oDiverg:bLine := {||{;
aDiverg[oDiverg:nAt][01],;
aDiverg[oDiverg:nAt][02],;
aDiverg[oDiverg:nAt][03]}}

//Activate MsDialog oDlg On Init EnchoiceBar(oDlg, {|| lOpcClick := .F., oDlg:End()} , {|| oDlg:End() },/*lMsgDel*/,aButtons,/*nRecno*/,/*cAlias*/,/*lMashups*/,/*lImpCad*/,/*lPadrao*/,/*lHasOk*/,/*lWalkThru*/,/*cProfileID*/)
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,,{||oDlg:End()},, aButtons,,,,,,.F. )

RestArea(aArea)

Return(lOpcClick)


/*/-----------------------------------------------------------
{Protheus.doc} TMA310EstR()
Estorno do Check List da Viagem

Uso: TMSA310

@sample

@author Katia
@since 08/09/2015
@version 1.0
-----------------------------------------------------------/*/
Function TMA310EstR(nOpcRot)

Local aArea    := GetArea()
Local lRet     := .T.

Default nOpcRot:= 3

Tmsa029Blq( 5  ,;		//-- 01 - nOpc
	'TMSA310',;			//-- 02 - cRotina
	'RR'  ,;				//-- 03 - cTipBlq
	DTQ->DTQ_FILORI,;		//-- 04 - cFilOri
	'DTQ' ,;				//-- 05 - cTab
	'1' ,;					//-- 06 - cInd
	DTQ->DTQ_FILIAL + DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM,; //-- 07 - cChave
	"" ,;					//-- 08 - cCod
	"" ,;					//-- 09 - cDetalhe
	nOpcRot)				//-- 10 - Opcao da Rotina

RestArea(aArea)
Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tmsa310Lot
@autor		: Eduardo Alberti
@descricao	: Gera Lote Na Tabela DTP Para Tratamento De Custeio De Viagens De Coleta
@since		: Jun./2016
/*/
//-------------------------------------------------------------------------------------------------
Function Tmsa310Lot( cFilOri, cViagem, cSerTMS, cTipTra, aLotes )

	Local aArea      := GetArea()
	Local lRet       := .f.
	Local cQuery	   := ""
	Local nTotReg    := 0
	Local cAliasT    := GetNextAlias()
	Local bQuery     := {|| Iif(Select(cAliasT) > 0, (cAliasT)->(dbCloseArea()), Nil) , dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T.), dbSelectArea(cAliasT), (cAliasT)->(dbEval({|| nTotReg++ })), (cAliasT)->(dbGoTop())  }
	Local aReg       := {}
	Local aRetPag    := {}
	Local aRetTela   := {}
	Local lSerAdic   := .f.

	Default cFilOri	:= ""
	Default cViagem	:= ""
	Default cSerTMS	:= ""
	Default cTipTra	:= ""
	Default aLotes	:= {}

	cQuery :=	" SELECT      CASE WHEN DTC.R_E_C_N_O_ IS NULL THEN 'DT5'          ELSE 'DTC'          END TABELA, "
	cQuery +=	" 				CASE WHEN DTC.R_E_C_N_O_ IS NULL THEN DT5.R_E_C_N_O_ ELSE DTC.R_E_C_N_O_ END RECTAB  "
	cQuery +=	" FROM        " + RetSQLName("DUD") + " DUD "

	cQuery +=	" LEFT JOIN   " + RetSQLName("DT5") + " DT5 "
	cQuery +=	" ON          DT5.DT5_FILIAL  =  '" + xFilial("DT5") + "' "
	cQuery +=	" AND         DT5.DT5_FILDOC  =  DUD.DUD_FILDOC "
	cQuery +=	" AND         DT5.DT5_DOC     =  DUD.DUD_DOC "
	cQuery +=	" AND         DT5.DT5_SERIE   =  DUD.DUD_SERIE "
	cQuery +=	" AND         DT5.D_E_L_E_T_  =  ' ' "

	cQuery +=	" LEFT JOIN   " + RetSQLName("DTC") + " DTC "
	cQuery +=	" ON          DTC.DTC_FILIAL  =  '" + xFilial("DTC") + "' "
	cQuery +=	" AND			DTC_FILDOC      =  DUD.DUD_FILDOC "
	cQuery +=	" AND			DTC_DOC         =  DUD.DUD_DOC "
	cQuery +=	" AND			DTC_SERIE       =  DUD.DUD_SERIE "
	cQuery +=	" AND			DTC.D_E_L_E_T_  =  ' ' "

	cQuery +=	" WHERE       DUD.DUD_FILIAL  =  '" + xFilial("DUD") + "' "
	cQuery +=	" AND         DUD.DUD_FILORI  =  '" + cFilOri + "' "
	cQuery +=	" AND         DUD.DUD_VIAGEM  =  '" + cViagem + "' "
	cQuery +=	" AND         DUD.D_E_L_E_T_  =  ' ' "

	cQuery := ChangeQuery(cQuery)

	Eval(bQuery)

	//-- Formata Campo DT5.R_E_C_N_O_
	TcSetField(cAliasT,"RECTAB","N",16,0)

	//-- Carrega Vetor Para Tratamento Da Função TMSF79Cols
	DbSelectArea(cAliasT)
	(cAliasT)->(DbGoTop())
	While (cAliasT)->(!Eof())

		Aadd(aReg,{ (cAliasT)->TABELA , (cAliasT)->RECTAB })

		(cAliasT)->(DbSkip())
	EndDo

	//-- Fecha Arquivo Temporário
	If Select(cAliasT) > 0
		(cAliasT)->(DbCloseArea())
	EndIf

	//-- Ordena Vetor
	aReg := aSort(aReg,,,{|x,y| x[1] < y[1] })

	//-- Determina Serviço Adicional
	lSerAdic := aScan(aReg,{|x| x[1] == 'DTC'}) > 0 .And. aScan(aReg,{|x| x[1] == 'DT5'}) > 0

	//-- Inicializa Controle De Sequence
	Begin Sequence

	//-- Monta aCols aHeader De Pagadores De Frete Para Tratamento De Geração Dos Lotes
	/*
	Parametros³ aExp01 := Vetor com os recnos
	          ³ cExp01 := Serviço do TMS 1-Coleta
	          ³                          2-Transferência
	          ³                          3-Entrega
	          ³ cExp02 := Serviço do TMS 1-Rodoviário
	          ³                          2-Aéreo
	          ³                          3-Internacional
	          ³ cExp03 := Tipo de Montagem 1-Incremental (a cada docto)
	          ³                            2-Geral (todos doctos juntos)
	          ³ cExp04 := Serviço adicional de coleta 1-Sim
	          ³                                       2-Não
	*/
	aRetPag := TMSF79Cols(aReg,cSerTMS,cTipTra,"2",Iif(lSerAdic,"1","2"))

	//-- Valida Retorno Da Função
	If Len( aRetPag ) == 0 .Or. Len(aRetPag[1]) == 0 .Or. Len(aRetPag[2]) == 0
		Break
	EndIf

	/*
	Descri‡„o ³ Exibe tela de pagadores de frete
	Sintaxe   ³ TMSF79Tela(aExp01,aExp02,lExp01,lExp02)
	Parametros³ aExp01 := aHeader
	          ³ aExp02 := aCols
	          ³ lExp01 := Indica se irá exibir tela
	          ³ lExp02 := Indica se vai atualizar o que foi alterado
	Retorno   ³ aRet   :=
	*/
	// Chama a Função de Tela de Pagadores
	aRetTela := TMSF79Tela(Aclone(aRetPag[1]),Aclone(aRetPag[2]),.f.,.f.)

	//-- Valida Retorno Da Função
	If Len( aRetTela ) == 0 .Or. Len(aRetTela[4]) == 0
		Break
	EndIf

	/*
	Fun‡„o    ³ TMSF79Lot  ³ Autor ³ Valdemar Roberto  ³ Data ³ 10.05.2016
	Descri‡„o ³ Criação dos lotes a partir do definido na rotina de
	          ³ pagadores de frete
	Sintaxe   ³ TMSF79Lot(aExp01,cExp01,cExp02,lExp01,cExp03)
	Parametros³ aExp01 := Vetor com os lotes a serem abertos
	          ³ cExp01 := Filial origem da viagem
	          ³ cExp02 := Viagem
	          ³ lExp01 := Indica se exibe help
	          ³ cExp03 := Serviço do TMS do lote que será gerado
	*/
	aLotes := aRetTela[4]	//-- Carrega Vetor Passado Por Parametro
	lRet 	:= TMSF79Lot( aLotes, cFilOri, cViagem, .T.)

	//-- Finaliza Controle De Sequence
	End Sequence

	RestArea(aArea)

Return( lRet )

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tmsa310Vlr
@autor		: Eduardo Alberti
@descricao	: Verifica Se Valorização Da Coleta Ocorreu Com Sucesso
@since		: Apr./2016
@param		: 	cFilOri 	: Filial De Origem Da Viagem
				cViagem	: Número Da Viagem
				lAvisa		: Booleano - Se .t. Mostra Tela Contendo Documentos Com Erro De Processamento
/*/
//-------------------------------------------------------------------------------------------------
Function Tmsa310Vlr( cFilOri , cViagem , lAvisa )

	Local	aArea		:= GetArea()
	Local	aArDUD		:= DUD->(GetArea())
	Local	aArDT6		:= DT6->(GetArea())
	Local	aMsg		:= {}
	Local	lRet		:= .T.
	Local lCmpBlqCol    := .F.	// Verifica se os campos DDA_BLQCOL e DDC_BLQCOL existem no dicionário
	Default cFilOri		:= ""
	Default lAvisa		:= .t.
	Default cViagem		:= ""	
	
	If DDA->(ColumnPos("DDA_BLQCOL")) > 0 .And. DDC->(ColumnPos("DDC_BLQCOL")) > 0
		lCmpBlqCol := .T.
	EndIf

	//-- Posiciona No Movimento Da Viagem
	DbSelectArea("DUD")
	DbSetOrder(2) //-- DUD_FILIAL+DUD_FILORI+DUD_VIAGEM+DUD_SEQUEN+DUD_FILDOC+DUD_DOC+DUD_SERIE
	If MsSeek( FWxFilial("DUD") + cFilOri + cViagem , .F. ) .And. !Empty(cViagem)

		While !DUD->(Eof()) .And. (DUD->(DUD_FILIAL + DUD_FILORI + DUD_VIAGEM) == (FWxFilial("DUD") + cFilOri + cViagem ))

			//-- Se Série = Coleta e Status <> Cancelado
			If DUD->DUD_SERIE == "COL"

				//-- Verifica Existencia da NF e Se Esta é Coleta
				DbSelectArea("DT6")
				DbSetOrder(1) //-- DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE
				If MsSeek( FWxFilial("DT6") + DUD->DUD_FILDOC + DUD->DUD_DOC + DUD->DUD_SERIE , .f. ) .And. DT6->DT6_SERIE == 'COL'

					//-- Posiciona na solicitacao de coleta. (Se Não Hover Lote, o Documento Foi Excluido Do Cálculo - [Valoriza Coleta Não Realizada = Não] )
					DbSelectArea("DT5")
					DT5->( DbSetOrder( 4 ) ) //-- DT5_FILIAL+DT5_FILDOC+DT5_DOC+DT5_SERIE
					If	DT5->( MsSeek( FWxFilial('DT5') + DUD->DUD_FILDOC + DUD->DUD_DOC + DUD->DUD_SERIE , .F. ) )

						//-- Somente Calcula Se Os Campos Forem Informados
						If DT6->DT6_VALFRE <= 0  .And. !Empty(DUD->DUD_LOTE) .And. !Empty(DT5->DT5_CODNEG) .And. !Empty(DT5->DT5_SERVIC)
							//-- Valoriza Coleta Não Realizada = Nao, se houver um Retorna Documento o encerramento poderá ser realizado mesmo com valor do frete zerado
							If DUD->DUD_STATUS <> StrZero(9,Len(DUD->DUD_STATUS)) .Or. (DUD->DUD_STATUS == StrZero(9,Len(DUD->DUD_STATUS)) .And. TmsSobServ('VALCOL',.T.,.T.,DT5->DT5_NCONTR,DT5->DT5_CODNEG,DT5->DT5_SERVIC,"0", Nil ) == '1') //-- 1 = SIM ; 2 = NAO

								If lCmpBlqCol .And. TmsSobServ('BLQCOL',.T.,.T.,DT5->DT5_NCONTR,DT5->DT5_CODNEG,DT5->DT5_SERVIC,"0", Nil ) $ " 1"

									lRet := .f.
									aAdd( aMsg ,{ cViagem        ,;  //-- 01
													DT6->DT6_FILDOC,;  //-- 02
													DT6->DT6_DOC   ,;  //-- 03
													DT6->DT6_SERIE ,;  //-- 04
													DT6->DT6_DATEMI,;  //-- 05
													DT6->DT6_CDRORI,;  //-- 06
													DT6->DT6_CDRDES,;  //-- 07
													DT6->DT6_CLIREM,;  //-- 08
													DT6->DT6_LOJREM,;  //-- 09
													DT6->DT6_CLIDES,;  //-- 10
													DT6->DT6_LOJDES,;  //-- 11
													DT6->DT6_NCONTR,;  //-- 12
													DT6->DT6_SERVIC,;  //-- 13
													DT6->DT6_CODNEG } )//-- 14

								EndIf

							EndIf
						EndIf
					EndIf
				EndIf
			EndIf

			DUD->(DbSkip())
		EndDo
	Else
		lRet := .f.
	EndIf

	//-- Verifica Exibe tela De Aviso
	If !(lRet) .And. lAvisa .And. Len(aMsg) > 0
		TMS310AVg( aMsg, lAvisa, .T. )
	EndIf

	RestArea(aArDT6)
	RestArea(aArDUD)
	RestArea(aArea)

Return( lRet )
//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tmsa310Doc
@autor		: Eduardo Alberti
@descricao	: Visualização Das Solicitações De Coleta
@since		: May./2016
@param		: 	aMsg 		: Vetor Das Mensagens De Erro
				nLin    	: Linha Do Browse
				nCol  		: Coluna Do Browse (Fora De Uso)
/*/
//-------------------------------------------------------------------------------------------------
Static Function Tmsa310Doc( aMsg , nLin , nCol )

	Local aArea := GetArea()
	Local aArDT5:= DT5->(GetArea())

	Default aMsg := {}
	Default nLin := 0
	Default nCol := 0

	//-- Posiciona na solicitacao de coleta.
	DbSelectArea("DT6")
	DT5->( DbSetOrder( 1 ) ) //-- DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE
	If	DT6->( MsSeek( xFilial('DT6') + aMsg[nLin,2] + aMsg[nLin,3] + aMsg[nLin,4] , .F. ) )
		TMSA500Mnt("DT6",DT6->(Recno()),2)
	EndIf

	/*
	//-- Posiciona na solicitacao de coleta.
	DbSelectArea("DT5")
	DT5->( DbSetOrder( 4 ) ) //-- DT5_FILIAL+DT5_FILDOC+DT5_DOC+DT5_SERIE
	If	DT5->( MsSeek( xFilial('DT5') + aMsg[nLin,2] + aMsg[nLin,3] + aMsg[nLin,4] , .F. ) )
		TmsA460Mnt( 'DT5', DT5->( Recno() ), 2 )
	EndIf
	*/

	RestArea(aArDT5)
	RestArea(aArea)

Return(Nil)
//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tmsa310LVC
@autor		: Eduardo Alberti
@descricao	: Limpa Informações Da Valorização Da Coleta ( Para Exclusão Ou Reprocessamento Do Cálculo )
@since		: Jun./2016
@param		: 	cFilOri 	: <Caracter> - Filial Origem
				cViagem   	: <Caracter> - Número Da Viagem
				lDTP    	: <Lógica>   - Define Se Exclui o Lote De Documentos (Tabela DTP)
				lDUD    	: <Lógica>   - Define Se Exclui Número Do Lote Informado Na Tabela DUD (Movimentos Da Viagem)
				aZeraVlr	: <Array>    - Vetor Com Os Documentos Que Devem Ser Zerados No DT8 (Composição de Frete)
				lCanDJI    : <Lógica>   - Define Se Cancela Ultimo Movimento Do DJI
/*/
//-------------------------------------------------------------------------------------------------
Function Tmsa310LVC( cFilOri, cViagem, lDTP, lDUD, aZeraVlr, lCanDJI, aDelDocs )

	Local aAreas     := {DTP->(GetArea()),DUD->(GetArea()),DT5->(GetArea()),GetArea()}
	Local lRet       := .t.
	Local nCnt1      := 0	

	Default cFilOri  := ""
	Default cViagem  := ""
	Default lDTP     := .f.
	Default lDUD     := .f.
	Default aZeraVlr := {}
	Default aDelDocs := {}
	Default lCanDJI  := .t.

	//-- Verifica Se Vai Limpar Todos Os Dados Ou Somente Os Valores Do DT8 Contidos No Vetor aZeraVlr
	If Len(aZeraVlr) == 0 .And. Len(aDelDocs) == 0

		//-- Inicializa Controle De Sequence
		Begin Sequence

			//-- Verifica Conteudo Das Variáveis Obrigatórias
			If Empty(cFilOri) .Or. Empty(cViagem)
				lRet := .f.
				Break
			EndIf

			//-- Posiciona No Movimento Da Viagem
			DbSelectArea("DUD")
			DbSetOrder(2) //-- DUD_FILIAL+DUD_FILORI+DUD_VIAGEM+DUD_SEQUEN+DUD_FILDOC+DUD_DOC+DUD_SERIE
			MsSeek( FWxFilial("DUD") + cFilOri + cViagem , .F. )

			While !DUD->(Eof()) .And. (DUD->(DUD_FILIAL + DUD_FILORI + DUD_VIAGEM) == (FWxFilial("DUD") + cFilOri + cViagem ))

				If DUD->DUD_SERIE == "COL"

					//-- Altera Registros DJI Para Status "Cancelado"
					If lCanDJI

						aInfDJI := {} //-- Inicializa Variável
						aAdd( aInfDJI, {'DJI_FILDOC'	, DUD->DUD_FILDOC })
						aAdd( aInfDJI, {'DJI_DOC'		, DUD->DUD_DOC    })
						aAdd( aInfDJI, {'DJI_SERIE'		, DUD->DUD_SERIE  })

						//-- Altera Status Do Último DJI Para Cancelado
						TmsAtuDJI( cFilOri, cViagem, Nil, '2', aInfDJI, .f. )
					EndIf

					//--Tmsa310Clr( cFilDoc, cDoc, cSerie, lDT6 , cDT8 )
					lRet := Tmsa310Clr( DUD->DUD_FILDOC, DUD->DUD_DOC, DUD->DUD_SERIE, .T., "D" )

					/*
					While DT8->( !Eof() ) .And. DT8->(DT8_FILIAL+DT8_FILDOC+DT8_DOC+DT8_SERIE) == FWxFilial("DT8") + DUD->DUD_FILDOC + DUD->DUD_DOC + DUD->DUD_SERIE

						//-- Verifica Se Deleção é Física Ou Lógica
						If lTmsDCust
							RecLock("DT8",.F.)
							DbDelete()
							DT8->(MsUnlock())
						Else

							//-- Executa Script
							nCodRet:= TcSqlExec("DELETE FROM " + RetSqlName("DT8") + " WHERE R_E_C_N_O_ = " + Alltrim(Str(DT8->(Recno()))) + " ")

							//-- Inclui Log De Erro
							If nCodRet < 0
								Help( ,, ProcName(),, TcSqlError() , 1, 0)
								lRet := .f.
								Break
							EndIf
						EndIf

						DT8->(DbSkip())
					EndDo

					//-- Limpa Valorização Gravada Anteriormente No DT6
					DbSelectArea("DT6")
					DbSetOrder(1) //-- DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE
					If MsSeek( FWxFilial("DT6") + DUD->DUD_FILDOC + DUD->DUD_DOC + DUD->DUD_SERIE , .f. ) .And. DUD->DUD_SERIE == 'COL'

						//-- Zera Valorização Da NF De Coleta
						RecLock("DT6", .F. )

						For nCnt2 := 1 To Len(aCposIni)
							Replace &("DT6->" + Upper(Alltrim(aCposIni[nCnt2]))) With CriaVar(Upper(Alltrim(aCposIni[nCnt2])))
						Next nCnt2

						DT6->(MsUnlock())

					EndIf
					*/

					//-- Tratamento De Exclusãoes Tabelas DT5 e DTP
					DbSelectArea("DT5")
					DT5->(DbSetOrder( 4 )) //-- DT5_FILIAL+DT5_FILDOC+DT5_DOC+DT5_SERIE
					If DT5->(MsSeek(FWxFilial('DT5')+DUD->DUD_FILDOC+DUD->DUD_DOC+DUD->DUD_SERIE))

						//-- Somente Calcula Se Os Campos Forem Informados
						If !Empty(DT5->DT5_CODNEG) .And. !Empty(DT5->DT5_SERVIC)

							DbSelectArea("DTP")
							DbSetOrder(1) //-- DTP_FILIAL+DTP_LOTNFC
							If MsSeek( FWxFilial("DTP") + DUD->DUD_LOTE , .F. )

								RecLock("DTP",.F.)
								If lDTP //-- Exclui o Lote Da Tabela DTP
									DTP->(DbDelete())
								Else    //-- Altera Status Do Lote Para Digitado
									Replace DTP->DTP_STATUS With '2' //-- 'Digitado'
								EndIf
								DTP->(MsUnlock())

							EndIf

							//-- Limpa o Lote Se For Exclusão De DTP ou Se lDUD For Igual a .T.
							If lDUD .Or. lDTP
								RecLock("DUD",.F.)
								Replace DUD->DUD_LOTE With	Space(Len(DUD->DUD_LOTE))
								DUD->(MsUnlock())
							EndIf
						EndIf
					EndIf
				EndIf

				DUD->(DbSkip())
			EndDo

		//-- Finaliza Controle De Sequence
		End Sequence

	//-- Tratamento de Itens Excluidos No aCols Da Viagem
	ElseIf Len(aDelDocs) > 0

		For nCnt1 := 1 To Len(aDelDocs)

			DbSelectArea("DT5")
			DbSetOrder(1)
			If MsSeek( aDelDocs[nCnt1,3] , .f.)

				//-- Altera Registros DJI Para Status "Cancelado"
				If lCanDJI

					aInfDJI := {} //-- Inicializa Variável
					aAdd( aInfDJI, {'DJI_FILDOC'	, DT5->DT5_FILDOC })
					aAdd( aInfDJI, {'DJI_DOC'		, DT5->DT5_DOC    })
					aAdd( aInfDJI, {'DJI_SERIE'		, DT5->DT5_SERIE  })

					//-- Altera Status Do Último DJI Para Cancelado
					TmsAtuDJI( cFilOri, cViagem, Nil, '2', aInfDJI, .f. )
				EndIf

				//--Tmsa310Clr( cFilDoc, cDoc, cSerie, lDT6 , cDT8 )
				Tmsa310Clr( DT5->DT5_FILDOC, DT5->DT5_DOC, DT5->DT5_SERIE, .T., "D" )

				/*
				While DT8->( !Eof() ) .And. DT8->(DT8_FILIAL+DT8_FILDOC+DT8_DOC+DT8_SERIE) == FWxFilial("DT8") + DT5->DT5_FILDOC + DT5->DT5_DOC + DT5->DT5_SERIE

					//-- Verifica Se Deleção é Física Ou Lógica
					If lTmsDCust
						RecLock("DT8",.F.)
						DbDelete()
						DT8->(MsUnlock())
					Else

						//-- Executa Script
						nCodRet:= TcSqlExec("DELETE FROM " + RetSqlName("DT8") + " WHERE R_E_C_N_O_ = " + Alltrim(Str(DT8->(Recno()))) + " ")

						//-- Inclui Log De Erro
						If nCodRet < 0
							Help( ,, ProcName(),, TcSqlError() , 1, 0)
							lRet := .f.
							Break
						EndIf
					EndIf

					DT8->(DbSkip())
				EndDo

				//-- Limpa Valorização Gravada Anteriormente No DT6
				DbSelectArea("DT6")
				DbSetOrder(1) //-- DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE
				If MsSeek( FWxFilial("DT6") + DT5->DT5_FILDOC + DT5->DT5_DOC + DT5->DT5_SERIE , .f. ) .And. DT5->DT5_SERIE == 'COL'

					//-- Zera Valorização Da NF De Coleta
					RecLock("DT6", .F. )

					For nCnt2 := 1 To Len(aCposIni)
						Replace &("DT6->" + Upper(Alltrim(aCposIni[nCnt2]))) With CriaVar(Upper(Alltrim(aCposIni[nCnt2])))
					Next nCnt2

					DT6->(MsUnlock())

				EndIf
				*/

			EndIf
		Next nCnt1

	Else
		//-- Dá Loop No DT8 Zerando Valores De Componentes
		For nCnt1 := 1 To Len(aZeraVlr)

			//--Tmsa310Clr( cFilDoc, cDoc, cSerie, lDT6 , cDT8 )
			Tmsa310Clr( aZeraVlr[nCnt1,1], aZeraVlr[nCnt1,2], aZeraVlr[nCnt1,3], .T., "L" )

			/*
			//-- Composição de Frete
			DbSelectArea("DT8")
			DbSetOrder(2) //-- DT8_FILIAL+DT8_FILDOC+DT8_DOC+DT8_SERIE+DT8_CODPRO+DT8_CODPAS
			If MsSeek( FWxFilial("DT8") + aZeraVlr[nCnt1,1] + aZeraVlr[nCnt1,2] + aZeraVlr[nCnt1,3] , .f. )

				While DT8->(!Eof()) .And. (DT8->(DT8_FILIAL+DT8_FILDOC+DT8_DOC+DT8_SERIE) == (FWxFilial("DT8") + aZeraVlr[nCnt1,1] + aZeraVlr[nCnt1,2] + aZeraVlr[nCnt1,3]))

					RecLock("DT8",.F.)
					Replace DT8_VALPAS With 0
					Replace DT8_VALTOT With 0
		 			DT8->(MsUnlock())

		 			DT8->(DbSkip())
		 		EndDo
			EndIf

			//-- Limpa Valorização Gravada Anteriormente No DT6
			DbSelectArea("DT6")
			DbSetOrder(1) //-- DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE
			If MsSeek( FWxFilial("DT6") + aZeraVlr[nCnt1,1] + aZeraVlr[nCnt1,2] + aZeraVlr[nCnt1,3] , .f. ) .And. aZeraVlr[nCnt1,3] == 'COL'

				//-- Zera Valorização Da NF De Coleta
				RecLock("DT6", .F. )

				For nCnt2 := 1 To Len(aCposIni)
					Replace &("DT6->" + Upper(Alltrim(aCposIni[nCnt2]))) With CriaVar(Upper(Alltrim(aCposIni[nCnt2])))
				Next nCnt2

				DT6->(MsUnlock())

			EndIf
			*/

		Next nCnt1
		aZeraVlr := {} //-- Esvazia Vetor Para Próximo Processamento Do TMSA340
	EndIf

	//-- Restaura Posicionamento Das Tabelas
	AEval(aAreas,{|x,y| RestArea(x) })

Return(lRet)

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tmsa310Clr
@autor		: Eduardo Alberti
@descricao	: Limpa Valorização Da Coleta das Tabelas DT6 e DT8
@since		: Oct./2016
@param		: 	cFilDoc   	: <Caracter> - Filial Do Documento
				cDoc     	: <Caracter> - Número Do Documento
				cSerie     	: <Caracter> - Série Do Documento
				lDT6		: <Lógica>   - Define Se Limpa Informações de Valorização Do DT6
				cDT8		: <Caracter> - "" = Não Processa, "L" = Limpa Campos Valor, "D" = Deleta Linhas DT8

/*/
//-------------------------------------------------------------------------------------------------
Function Tmsa310Clr( cFilDoc, cDoc, cSerie, lDT6 , cDT8 )

	Local aAreas     := {DT8->(GetArea()),DT6->(GetArea()),GetArea()}
	Local aCposIni   := {}
	Local lRet       := .f.
	Local nCnt1      := 0
	Local lTmsDCust  := SuperGetMV("MV_TMSDCUS",.F.,.F.) //-- Define Exclusão Física / Lógica
	Local nCodRet    := 0

	Default cFilDoc  := ""
	Default cDoc     := ""
	Default cSerie   := ""
	Default lDT6     := .f.
	Default cDT8     := ""

	//-- Verifica Se Limpa Campos Do DT6
	If lDT6

		//-- Vetor Contendo Os Campos Que Serão Zerados Para Reprocessamento Conforme Programa Tmsa200Col
		aAdd( aCposIni , "DT6_VALFRE"	)	//-- Valor Frete
		aAdd( aCposIni , "DT6_VALTOT"	)	//-- Valor Total Calculado
		aAdd( aCposIni , "DT6_QTDUNI"	)	//-- Quantidade Unitizadores
		aAdd( aCposIni , "DT6_BASSEG"	)	//-- TDA
		aAdd( aCposIni , "DT6_METRO3"	)	//-- M3


		DbSelectArea("DT6")
		DbSetOrder(1) //-- DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE
		If MsSeek( FWxFilial("DT6") + cFilDoc + cDoc + cSerie , .f. ) .And. DT6->DT6_SERIE == 'COL'

			lRet := .t.

			//-- Zera Valorização Da NF De Coleta
			RecLock("DT6", .F. )

			For nCnt1 := 1 To Len(aCposIni)
				Replace &("DT6->" + Upper(Alltrim(aCposIni[nCnt1]))) With CriaVar(Upper(Alltrim(aCposIni[nCnt1])))
			Next nCnt1

			DT6->(MsUnlock())

		EndIf
	EndIf

	//-- Verifica Se Trata DT8
	If !Empty(cDT8)

		DbSelectArea("DT8")
		DbSetOrder(2) //-- DT8_FILIAL+DT8_FILDOC+DT8_DOC+DT8_SERIE+DT8_CODPRO+DT8_CODPAS
		MsSeek( FWxFilial("DT8") + cFilDoc + cDoc + cSerie , .F. )

		While DT8->( !Eof() ) .And. DT8->(DT8_FILIAL + DT8_FILDOC + DT8_DOC + DT8_SERIE) == FWxFilial("DT8") + cFilDoc + cDoc + cSerie

			If Upper(cDT8) == "D" //-- Deleta

				//-- Verifica Se Deleção é Física Ou Lógica
				If lTmsDCust
					RecLock("DT8",.F.)
					DbDelete()
					DT8->(MsUnlock())
				Else

					//-- Executa Script
					nCodRet:= TcSqlExec("DELETE FROM " + RetSqlName("DT8") + " WHERE R_E_C_N_O_ = " + Alltrim(Str(DT8->(Recno()))) + " ")

					//-- Inclui Log De Erro
					If nCodRet < 0
						Help( ,, ProcName(),, TcSqlError() , 1, 0)
						lRet := .f.
						Break
					EndIf
				EndIf

			ElseIf Upper(cDT8) == "L" //-- Limpa Valores

				RecLock("DT8",.F.)
				Replace DT8_VALPAS With 0
				Replace DT8_VALTOT With 0
				DT8->(MsUnlock())

			EndIf

			DT8->(DbSkip())
		EndDo
	EndIf

	//-- Restaura Posicionamento Das Tabelas
	AEval(aAreas,{|x,y| RestArea(x) })

Return(lRet)

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} T310AtvCli
@autor		: Leandro Paulino
@descricao	: Valida se as atividades de saída e chegada fazem parte do serviço indicado na rota
@since		: Jun./2016
@param		: 	cServic   	: <Caracter> - cServic
				cAtvSaiCli	: <Lógica>   - Atividade de Saida
				cAtvChgCli	: <Lógica>   - Atividade de Chegada

/*/
//-------------------------------------------------------------------------------------------------

Function T310AtvCli(cServic,cAtvSaiCli,cAtvChgCli,cAtvSaiApo,cAtvChgApo)

Local cQuery 		:= ""
Local cAliasDC5 	:= GetNextAlias()
Local aAreaDC5 		:= DC5->(GetArea())
Local aAreaDC6 		:= DC6->(GetArea())
Local lAchouAtvC	:= .T.
Local lAchouAtvS	:= .T.
Local lAchouAtvCA	:= .T.
Local lAchouAtvSA	:= .T.
Local lRet 			:= .F.

Default cServic		:= ''
Default cAtvSaiCli	:= ''
Default cAtvChgCli	:= ''
Default cAtvSaiApo	:= ''
Default cAtvChgApo	:= ''

cQuery:= " SELECT 		DC5_SERVIC, DC5_TAREFA, DC6_ATIVID "
cQuery+= " FROM 	" + RetSqlName('DC5') + " DC5"
cQuery+= "	INNER JOIN	" + RetSqlName('DC6') + " DC6 "
cQuery+= " ON 			DC6_FILIAL = '" + xFilial("DC6") + "' "
cQuery+= " AND			DC6_TAREFA = DC5_TAREFA "
cQuery+= " AND			DC6_ATIVID IN ('"+ cAtvSaiCli + "' ,'" + cAtvChgCli + "', '" + cAtvSaiApo + "', '" + cAtvChgApo + "') "
cQuery+= " AND          DC6.D_E_L_E_T_ = ' ' "
cQuery+= " WHERE  DC5_FILIAL = '" + xFilial("DC5") + "' "
cQuery+= " AND DC5.DC5_SERVIC = '" + cServic + "' "
cQuery+= " AND DC5.D_E_L_E_T_ = ' ' ORDER BY DC6_ORDEM "

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasDC5, .F., .T.)

While (cAliasDC5)->(!Eof())

	If (cAliasDC5)->DC6_ATIVID == cAtvSaiCli .And. lAchouAtvS == .F.
		lAchouAtvS := .T.
	EndIf
	If (cAliasDC5)->DC6_ATIVID == cAtvSaiCli .And. lAchouAtvS == .F.
		lAchouAtvC := .T.
	EndIf

    If (cAliasDC5)->DC6_ATIVID == cAtvSaiApo .And. lAchouAtvSA == .F.
		lAchouAtvSA := .T.
	EndIf
	If (cAliasDC5)->DC6_ATIVID == cAtvSaiApo .And. lAchouAtvSA == .F.
		lAchouAtvCA := .T.
	EndIf
	If (lAchouAtvC .And. lAchouAtvS) .OR. (lAchouAtvCA .AND. lAchouAtvSA)
		lRet := .T.
		Exit
	EndIf
	(cAliasDC5)->(dbSkip())

EndDo
(cAliasDC5)->(DbCloseArea())

RestArea(aAreaDC5)
RestArea(aAreaDC6)


Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A310IntRep
@autor		: Leandro Paulino
@descricao	: Função que prepara chamada para a TMSA310Oper
@since		: Jun./2017
/*/
//-------------------------------------------------------------------------------------------------
Static Function A310IntRep(lFecAuto,aMsgErr, nOpcX, nFretePrev, cNumIdOpe, cNumCiot, cNumIdCli, cNumIdPdg, aRegDtr )

Local lRet			:= .T.
Local nCnt			:= 0
Local cWhile		:= ""
Local lTMSOPdg		:= AliasInDic('DEG') .And. SuperGetMV('MV_TMSOPDG',,'0') == '2' //-- Integracao com Operadoras de Frota
Local lDTRAtu		:= DTR->(FieldPos("DTR_IDPDG")) > 0
Local lCancCiot		:= .F.
Local lIncCiot		:= .F.
Local lCiotAgre		:= .F.
Local lTM310InPGB	:= ExistBlock('TM310IPGB')
Local lIntPgb		:= .T.

Default lFecAuto 	:= .F.
Default aMsgErr  	:= {}
Default nOpcx    	:= 3
Default nFretePrev	:= 0
Default cNumIdOpe	:= ''
Default cNumCiot	:= ''
Default cNumIdCli	:= ''
Default cNumIdPdg	:= ''
Default aRegDtr		:= {}

// REALIZA A INTEGRACAO COM OPERADORAS DE FROTA

// Regras p/operadora REPOM:DTR_CODOPE="01"    
// Quando o controle de veiculos NAO estiver   
// ativo, a abertura do controle de viagem com 
// a Operadora de Frotas ira ocorrer no momento
// do apontamento da Operacao de Saida de via_ 
// gem. Quando o controle de veiculos estiver  
// ativo, a abertura do controle de viagem sera
// realizada atraves do fechamento da viagem.  
 										   
// Regras p/operadora PAMCARD:DTR_CODOPE="02"
// No Fechamento da viagem ocorrera a inclusao 
// da viagem no sistema Pamcard com parcela(s) 
// pendente(s) para veiculos Frota Propria. No 
// apontamento da Operacao de Saida da viagem  
// a parcela sera liberada.                    
// No Fechamento da viagem ocorrera a inclusao 
// do Contrato de Frete no sistema Pamcard     
// com parcela(s) pendente(s) para veiculos    
// Terceiros ou Agregados. No apontamento da   
// Operacao de Saida da viagem(qdo tem adto) ou
// na geracao do contrato do carreteiro(qdo nao
// tem adiantamento) a parcela sera liberada.

// Regras p/operadora PAGBEM:DTR_CODOPE = "03"
// No Fechamento da viagem ocorrera a inclusao 
// do Contrato de Frete e do Pedagio no sistema 
// PagBem para veiculos Terceiros ou Agregados.

DTR->(DbSetOrder(1))
If DTR->(MsSeek(xFilial('DTR')+ DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM)) .And. lTMSOPdg .And. DTR->DTR_CODOPE $ "01;02"
	lFrotaProp := Posicione('DA3',1,xFilial('DA3')+DTR->DTR_CODVEI,'DA3_FROVEI') == '1'
	If lFecAuto
		lRet := TMA310Oper( DTR->DTR_CODOPE, DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, @aMsgErr, nOpcx, DTR->DTR_CODVEI, .T., nFretePrev, @cNumIdOpe, @cNumCiot, @cNumIdCli, @cNumIdPdg )
	Else
		CursorWait()
		MsgRun( STR0034,; //-- 'Realizando comunicacao com a Operadora...'
				STR0035,; //-- 'Aguarde...'
				{|| lRet := TMA310Oper( DTR->DTR_CODOPE, DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, @aMsgErr, nOpcx, DTR->DTR_CODVEI, .T., nFretePrev, @cNumIdOpe,@cNumCiot, @cNumIdCli, @cNumIdPdg )} )
		CursorArrow()
	EndIf
	If !lRet
		If !Empty( aMsgErr )
			If lFecAuto
				For nCnt := 1 To Len(aMsgErr)
					AutoGrLog(aMsgErr[nCnt,1])
				Next nCnt
			Else
				TmsMsgErr( aMsgErr )
			EndIf
		EndIf
	EndIf
ElseIf DTR->(MsSeek(xFilial('DTR')+ DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM)) .And. lTMSOPdg .And. DTR->DTR_CODOPE == "03" .AND. lDTRAtu
	
	cWhile	:= xFilial('DTR')+ DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM
	lRet	:= .T.
	
	If lTM310InPGB
		lIntPgb	:= ExecBlock( 'TM310IPGB', .F., .F., { DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM } )
	EndIf

	If lIntPgb
		While !DTR->(EOF()) .AND. xFilial('DTR') + DTR->( DTR_FILORI + DTR_VIAGEM ) == cWhile .AND. lRet
			
			cNumIdOpe	:= DTR->DTR_PRCTRA
			cNumIdPdg	:= DTR->DTR_IDPDG
			cNumCiot	:= DTR->DTR_CIOT
			lCiotAgre   := DTR->DTR_TPCIOT == '2'
	
			//Posiciona na tabela de veículos.
			DA3->( DbSetOrder(1) )
			DA3->( MsSeek( xFilial('DA3') + DTR->DTR_CODVEI ) )
	
			CursorWait()
			MsgRun( STR0034,; //-- 'Realizando comunicacao com a Operadora...'
					STR0035,; //-- 'Aguarde...'
					{ || lRet := PgBContrat( DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, nOpcx, @aMsgErr, "", @cNumIdOpe, @cNumIdPdg, DTR->DTR_ITEM, @cNumCiot, @lCancCiot, @lIncCiot ) } )
			CursorArrow()
	
			AAdd( aRegDTR, { cNumIdOpe, cNumIdPdg, DTR->DTR_ITEM, cNumCIOT, lCiotAgre, lIncCiot, lCancCiot } )
	
			DTR->( DbSkip() )
		EndDo
	
		If !lRet
			If !Empty( aMsgErr )
				TmsMsgErr( aMsgErr )
			EndIf
		EndIf
	EndIf
EndIf


Return lRet

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} A310IntFin
@autor		: Leandro Paulino
@descricao	: Função que prepara a chamada para o financeiro Protheus ou Datasul
@since		: Jun./2017
@param		: 	cTmsErp   	: <Caracter> - ERP ao qual o TMS está integrado.
/*/
//-------------------------------------------------------------------------------------------------

Static Function A310IntFin(cTmsErp, aForn, aVlrAdiFrt,nOpcx, cBxTitPdg, lGeraSDG, aRetForn)

Local nCntFor		:= 0
Local nCntFor2		:= 0
Local lRet			:= .T.
Local cCodForn		:= ''
Local cLojForn		:= ''
Local aCodFav		:= {}
Local aDadosSDG		:= {}
Local aRetSDG		:= {}
Local nX 			:= 0
Local nY			:= 0
Local nVrPerAdi		:= 0
Local lSeparaMsg	:= .F.
Local lPaMovBco		:= .T.
Local nVALORPDG		:= 0
Local nFretePrev	:= 0
Local aSDGPDG		:= {}
Local aContrat		:= {}
Local nZ			:= 0

Default cTmsErp 	:= '0'
Default aForn   	:= {}
Default aVlrAdiFrt	:= {} 	//--Array com o Recno do DTR, valor do adiantamento e valor do frete previsto. Será utilizado para geração dos títulos financeiros
Default nOpcx		:= 3
Default cBxTitPdg	:= ''
Default lGeraSDG	:= .F. //--Informa se o custo do pedágio será gerado na rotina de geração do título do pedágio
Default aRetForn    := {}

If cTMSERP == '0'
	//-- Gerar Título do Pedágio se o TMS estiver Integrado com ERP Protheus
	If (Len(aRetForn) > 0 .And. aRetForn[1][5] = '1') // Verifica no contrato do fornecedor o campo DVG_TITPDG se gera o titulo SIM/NAO
		For nCntFor:= 1 To Len(aForn)
			lRet := A250TitPdg(aForn[nCntFor,3], aForn[nCntFor,4], , aForn[nCntFor,1], aForn[nCntFor,2], aForn[nCntFor,5], aForn[nCntFor,4], /*nRetINSS*/, aForn[nCntFor,6], nOpcX, /*cDocSDG*/ ,/*nItem*/,cBxTitPdg, lGeraSDG)

			If lRet
				//--Atualiza o DTR informando que o pedágio foi gerado para o DTR
				For nCntFor2 := 1 To Len(aForn[nCntFor,8])
					DTR->(dbGoTo(aForn[nCntFor,8,nCntFor2]))
					RecLock('DTR',.F.)
					DTR->DTR_TITPDG := '1'
					DTR->DTR_ORIPDG := 'TMSA310'
					MsUnLock()
				Next nCntFor2
			EndIf

		Next nCntFor
	EndIf
EndIf


For nX:= 1 To Len(aVlrAdiFrt)
	aDadosSDG  := {}
	nVALORPDG  := 0
	nFretePrev := aVlrAdiFrt[nX][3]
	nVrPerAdi  := aVlrAdiFrt[nX][4]
	For nY:= 1 To Len(aVlrAdiFrt[nX][5])
		//--Verifica se o fornecedor do pedágio é diferente do fornecedor do adiantamento, caso sejam diferentes serão enviadas duas mensagens para o ERP DAtasul
		//--Como o para a Integração com o ERP Datasul não funcionará a opção de comboio só será considerado a primeira linha do DTR.
		//Posiciona no RECNO da DTR
		DTR->(DbGoTo(aVlrAdiFrt[nX][5][nY]))

		//Pesquisa se possui favorecido para o fornecedor do DTR
		aCodFav := T250BscFav(DTR->DTR_CODVEI,cCodForn,cLojForn,DTR->DTR_FILORI,DTR->DTR_VIAGEM)	// retorna o codigo do Favorecido
		If !Empty(aCodFav)
			cCodForn := aCodFav[1][1]
			cLojForn := aCodFav[1][2]
		Else
			If DTR->(DTR_CREADI+DTR_LOJCRE) <> cCodForn+cLojForn			
				cCodForn := DTR->DTR_CREADI
				cLojForn := DTR->DTR_LOJCRE
			EndIf
		EndIf

		//--Verifica se o fornecedor do adiantamento é o proprietário do veículo
		//--Se forem diferentes, o adiantamento será gerado para o fornecedor (Credor Adiantamento ou Favorecido)
		//--E o Pedagio será gerado para o fornecedor
		//--Sendo assim serão enviadas duas mensagens ao Datasul
		If cCodForn + cLojForn <> DTR->(DTR_CODFOR+DTR_LOJFOR)
			lSeparaMsg := .T.
		EndIF

		//--Chama o contrato com o tipo do veículo
		//| busca o contrato considerando o tipo de veículo da viagem
		aContrat := aClone(aVlrAdiFrt[nX][6])
		aSDGPDG	 := aClone(aVlrAdiFrt[nX][7])

		//--Preenche array a DadosSDG
		If Len(aContrat)> 0 .And. Len(aContrat[1]) > 11

			lPaMovBco := aContrat[1,12] <> '2'

			If Len(aContrat[1]) > 12

				If  aContrat[1][13] == '1' //|momento da geração do adiantamento; 0-Geracao da Viagem;1-No Fechamento;2-Na geração do CTC
					aRetSDG := A240BscSDG(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,DTR->DTR_CODVEI)

				ElseIf nVrPerAdi > 0 .And. aContrat[1][13] == '0'
					//| Se existir valor de Adiantamento calculado pelo percentual sobre a provisão, monta array para envio do Adiantamento (Datasul).
					//| Não gera se momento da geração for no contrato.
					aRetSDG := A240BscSDG(,,,nVrPerAdi)
				EndIf


				For nZ := 1 to Len(aRetSDG)
					If (nPosRetSDG := Ascan(aDadosSDG,{|x| x[1]+x[2]+x[3]+x[4]== aRetSDG[nz,1]+aRetSDG[nZ,2]+aRetSDG[nZ,3]+aRetSDG[nZ,4]})) == 0
						AADD(aDadosSDG	, 	;
							{aRetSDG[nz,1] ,;
							 aRetSDG[nz,2] ,;
							 aRetSDG[nz,3] ,;
							 aRetSDG[nz,4] ,;
							 aRetSDG[nz,5] ,;
							 aRetSDG[nz,6] ,;
							 aRetSDG[nz,7] ,;
							 aRetSDG[nz,8] ,;
							 aRetSDG[nz,9] })
					Else
						aDadosSDG[nPosRetSDG,5] += aRetSDG[nZ,5]
					EndIf

				Next nZ
				//--Busca o valor do pedágio se estiver configurado para gerar o pedágio no fechamento
				If DTR->DTR_VALPDG > 0 .And.  aContrat[1][5] == '1' .And. aContrat[1][15] == '1' //--So envia o valor do pedagio para o DATASUL, caso o pedágio esteja conf. para ser gerado do fechamento da viagem.
					nVALORPDG += DTR->DTR_VALPDG
				EndIf
			EndIF

		EndIf
	Next nY

	//--Chama rotina para gerar o título de pedágio e adiantamento
	If Len(aDadosSDG) > 0 .Or. nVALORPDG > 0 .Or. nFretePrev > 0
		lRet := A240GerAdt(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,DTR->DTR_CODVEI,aDadosSDG,DTR->DTR_CODOPE,cCodForn, cLojForn,;
							/*chistory*/,/*cHistory2*/,'TMSA310',lPaMovBco,nVALORPDG,nFretePrev,lSeparaMsg,aSDGPDG, aVlrAdiFrt[nX][5])//-- define a mensagem de OK da integração para ser chamada fora da Transação, evitando que transação fique aberta devido a visualização da mensagem por longos periodos.
		If  cTMSERP == "1" .And. lRet
			cEAIMsg := StrTran(STR0069 + " " + DTQ->(DTQ_FILORI + " / " + DTQ_VIAGEM) + ".", "p1", "Datasul") //-- "Integração com p1 realizada com sucesso para a filial / viagem: "
		EndIf
	EndIf

Next nX

Return lRet

/*
/====================================================================================================================
{Protheus.doc} IntegDef
//         TODO  - Rotina de Integração model Mensagem Única EAI
@author  : tiago.dsantos
@since   : 28/09/2016
@version : 1.000
@param cXml        , characters , XML referente ao XSD da Mensagem TransportDocument
@param nType       , numeric    , tipo de Mensagem 0=Recebimento;1=Envio
@param cMessageType, characters , Tipo do Retorno: EAI_MESSAGE_BUSINESS,EAI_MESSAGE_WHOIS,EAI_MESSAGE_RECEIPT ou EAI_MESSAGE_RESPONSE
@param cVersion    , characters , versão da mensagem cadastrada no Adapter EAI
@type function
/====================================================================================================================
*/
Static Function IntegDef(cXml,nType,cMessageType,cVersion)
Return TMSI310ABP(cXml,nType,cMessageType,cVersion)

/*/-----------------------------------------------------------
{Protheus.doc} EstDocChk()
Estorna documentos do check-list
Uso: TMSA360
@author Caio Murakami
@since 04/05/2020
-----------------------------------------------------------/*/
Static Function EstDocChk( cFilOri , cViagem  )
Local aArea			:= GetArea()
Local cQuery		:= ""
Local cAliasQry		:= ""

Default cFilOri		:= ""
Default cViagem		:= "" 

cAliasQry	:= GetNextAlias()

cQuery	:= " SELECT DM0_IDINTG "
cQuery	+= " FROM " + RetSqlName("DUD") + " DUD "
cQuery	+= " INNER JOIN " + RetSqlName("DM0") + " DM0 "
cQuery	+= " 	ON DM0_FILIAL 		= '" + xFilial("DM0") + "' "
cQuery	+= " 	AND DM0_FILDOC		= DUD_FILDOC  "
cQuery	+= " 	AND DM0_DOC			= DUD_DOC "
cQuery	+= " 	AND DM0_SERIE		= DUD_SERIE "
cQuery	+= " 	AND DM0.D_E_L_E_T_ 	= '' "
cQuery	+= " WHERE DUD_FILIAL		= '" + xFilial("DUD") + "' "
cQuery	+= " 	AND DUD_FILORI		= '" + cFilOri + "' "
cQuery	+= " 	AND DUD_VIAGEM		= '" + cViagem + "' "
cQuery	+= " 	AND DUD.D_E_L_E_T_ 	= '' "

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

While (cAliasQry)->( !Eof() )
	//-- Envia o estorno do Check List
	TMSCanChk( (cAliasQry)->DM0_IDINTG , cFilOri , cViagem  )
			
	(cAliasQry)->( dbSkip() )
EndDo
	
(cAliasQry)->( dbCloseArea() )


RestArea( aArea )
Return

/*/---------------------------------------------------------------
{Protheus.doc} T310GerRep()
Verifica o Momento da geração do Contrato na Repom no Encerramento
Uso: TMSA310
@author Katia
@since 16/11/2020
--------------------------------------------------------------/*/
Static Function T310GerRep()
Local lRet   := .F.

If !lRestRepom
	lRet:= !(SuperGetMv("MV_ENREPOM",,"1") $ "1|2")  
Else
	lRet:= .T.   //Versao 2.2 - Gera o Contrato sempre no Fechamento
EndIf

Return lRet
//-----------------------------------------------------------------
/*/{Protheus.doc} GetInfoArr()
Obtém dados do array

@author Caio Murakami
@since 09/12/2020
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function GetInfoArr( aAux  , cLabel , nPosSeek , nPosRet  )
Local xRet      := nil 
Local nCount    := 0 

Default aAux        := {}
Default cLabel      := ""
Default nPosSeek    := 1
Default nPosRet     := 2

For nCount := 1 To Len(aAux)
    If AllTrim( Upper(aAux[nCount][nPosSeek]) ) == AllTrim( Upper(cLabel) )
        xRet    := aAux[nCount][nPosRet]
        exit
    EndIf
Next nCount

Return xRet

//-----------------------------------------------------------------
/*/{Protheus.doc} TMS310VgTF()
Obtém dados do array

@author Rodrigo Pirolo
@since 09/12/2020
@version 1.0
/*/
//--------------------------------------------------------------------

Function TMS310VgTF( cTabFre, cTipTab )

Local lRet		:= .F.
Local aArea		:= GetArea()
Local aAreaDUD	:= DUD->(GetArea())
Local aAreaDTQ	:= DTQ->(GetArea())
Local aAreaST5	:= DT5->(GetArea())
Local aAreaDT6	:= DT6->(GetArea())

Default cTabFre	:= ""
Default cTipTab	:= ""

DbSelectArea("DTL")
DTL->( DbSetOrder( 1 ) )

If DTL->( DbSeek( xFilial("DTL") + cTabFre + cTipTab ) )
	If ( DTL->DTL_DATDE <= dDataBase .AND. Empty(DTL->DTL_DATATE) ) .OR. ( DTL->DTL_DATDE <= dDataBase .AND. DTL->DTL_DATATE >= dDataBase )
		lRet := .T.
	EndIf	
EndIf

RestArea(aArea)	
RestArea(aAreaDUD)
RestArea(aAreaDTQ)
RestArea(aAreaST5)
RestArea(aAreaDT6)

Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} TMS310AVg()
Obtém dados do array

@author Rodrigo Pirolo
@since 09/12/2020
@version 1.0
/*/
//--------------------------------------------------------------------
Function TMS310AVg( aMsg, lAvisa, l310Vlr )

Local aCab			:= {}
Local oDlgTmp 		:= Nil
Local oListTmp  	:= Nil
Local aCoordenadas	:= MsAdvSize(.T.)
Local aButtons		:= {}
Local cFunction 	:= 'TMSA310'
Local lLGPD		 := ExistFunc('FWPDCanUse') .And. FWPDCanUse(.T.)
Local aCpoAccess := {'DTQ_VIAGEM','DT6_FILDOC','DT6_DOC','DT6_SERIE','DT6_DATEMI','DT6_NCONTR','DT6_SERVIC','DT6_CODNEG','DT6_CDRORI','DUY_DESCRI','DT6_CDRDES','DUY_DESCRI','DT6_CLIREM','DT6_LOJREM','A1_NOME','DT6_CLIDES','DT6_LOJDES','A1_NOME'}
Local aCpoAccNew := {}
Local aUsrAcsPFl := {}
Local nCountCpo	 := 0
Local aColOfusca := {}

Default aMsg	:= {}
Default lAvisa	:= .F.
Default l310Vlr	:= .F.

//-- Verifica Exibe tela De Aviso
If lAvisa

	//-- STR0060 - "Valorização Dos Documentos Da Viagem De Coleta Não Foram Realizados."
	//-- STR0061 - "Verifique a Configuração Do Contrato De Cliente e/ou Tabela De Frete."
	Help("",1,"TMSA31028",/*Titulo*/, STR0060 + Space(1) + STR0061  /*Mensagem*/,1,0)

	SaveInter()

	aAdd( aCab , RetTitle('DTQ_VIAGEM'))	//-- 01
	aAdd( aCab , RetTitle('DT6_FILDOC'))	//-- 02
	aAdd( aCab , RetTitle('DT6_DOC'))		//-- 03
	aAdd( aCab , RetTitle('DT6_SERIE'))	//-- 04
	aAdd( aCab , RetTitle('DT6_DATEMI'))	//-- 05
	aAdd( aCab , RetTitle('DT6_NCONTR'))	//-- 06
	aAdd( aCab , RetTitle('DT6_SERVIC'))	//-- 07
	aAdd( aCab , RetTitle('DT6_CODNEG'))	//-- 08
	aAdd( aCab , RetTitle('DT6_CDRORI'))	//-- 09
	aAdd( aCab , RetTitle('DUY_DESCRI'))	//-- 10
	aAdd( aCab , RetTitle('DT6_CDRDES'))	//-- 11
	aAdd( aCab , RetTitle('DUY_DESCRI'))	//-- 12
	aAdd( aCab , RetTitle('DT6_CLIREM'))	//-- 13
	aAdd( aCab , RetTitle('DT6_LOJREM'))	//-- 14
	aAdd( aCab , RetTitle('A1_NOME'))		//-- 15
	aAdd( aCab , RetTitle('DT6_CLIDES'))	//-- 16
	aAdd( aCab , RetTitle('DT6_LOJDES')) 	//-- 17
	aAdd( aCab , RetTitle('A1_NOME'))		//-- 18

	If llGPD .And. ExistFunc('TMLGPDCpPr')
		aCpoAccNew := TMLGPDCpPr(aCpoAccess,'SA1') //--Campos protegidos e que são apresentados na rotina.
		aUsrAcsPFl := FwProtectedDataUtil():UsrAccessPDField( __CUSERID, aCpoAccNew ) //--Campos protegidos usados na rotina e que o usuário possue acesso

		//--Monta Array com as colunas que nao serao exibidas devido ao acesso do usuario
		If Len(aCpoAccess) > 0
			For nCountCpo := 1 To Len(aCpoAccess)
				If Ascan( aCpoAccNew, { |x|  AllTrim(x) == aCpoAccess[nCountCpo] } ) == 0
					AADD(aColOfusca,.F.)
				Else
					If Ascan( aUsrAcsPFl, { |x|  AllTrim(x) == aCpoAccess[nCountCpo] } ) == 0
						AADD(aColOfusca,.T.)
					Else
						AADD(aColOfusca,.F.)
					EndIf
				EndIf	
			Next nCountCpo
		EndIf	
	EndIf
	
	aAdd(aButtons	,{ STR0063 ,{|| Tmsa310Doc( aMsg , oListTmp:nAT, oListTmp:nColPos ) 	}, STR0063	, STR0063 })	//-- "Visualiza Documento"

	oDlgTmp 			:= TDialog():New(000,000,aCoordenadas[6]/1.5,aCoordenadas[5]/1.5,OemToAnsi( STR0062 ),,,,,,,,oMainWnd,.T.) //-- "Relação Dos Documentos Com Erro De Processamento:"
	oListTmp 			:= TWBrowse():New(030,003,oDlgTmp:nClientWidth/2-5,oDlgTmp:nClientHeight/2-45,,aCab,,oDlgTmp,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
	oListTmp:lHScroll	:= .T. // Indica se habilita(.T.)/desabilita (.F.) a barra de rolagem horizontal.
	oListTmp:lVScroll	:= .T. // Indica se habilita(.T.)/desabilita(.F.) a barra de rolagem vertical.

	//-- Seta Duplo Clique Na Linha
	oListTmp:bLDblClick  := { || Tmsa310Doc( aMsg , oListTmp:nAT, oListTmp:nColPos ) }

	oListTmp:SetArray(aMsg)



	oListTmp:bLine := {||{	aMsg[oListTmp:nAt][01],;				//-- Viagem
								aMsg[oListTmp:nAt][02],;			//-- FilDoc
								aMsg[oListTmp:nAt][03],;			//-- Documento
								aMsg[oListTmp:nAt][04],;			//-- Série
								DtoC(aMsg[oListTmp:nAt][05]),;		//-- Data Emissão
								aMsg[oListTmp:nAt][12],;			//-- Num. Contrato
								aMsg[oListTmp:nAt][13],;			//-- Serviço
								aMsg[oListTmp:nAt][14],;			//-- Cod. Negociação
								aMsg[oListTmp:nAt][06],;			//-- Região Origem
								Alltrim(Posicione("DUY",1,xFilial("DUY") + aMsg[oListTmp:nAt][06],"DUY_DESCRI")),;
								aMsg[oListTmp:nAt][07],;			//-- Região Destino
								Alltrim(Posicione("DUY",1,xFilial("DUY") + aMsg[oListTmp:nAt][07],"DUY_DESCRI")),;
								aMsg[oListTmp:nAt][08],;			//-- Cliente Remetente
								aMsg[oListTmp:nAt][09],;			//-- Loja Remetente
								Alltrim(Posicione("SA1",1,xFilial("SA1") + aMsg[oListTmp:nAt][08] + aMsg[oListTmp:nAt][09] ,"A1_NOME")),;
								aMsg[oListTmp:nAt][10],;			//-- Cliente Destinatário
								aMsg[oListTmp:nAt][11],;			//-- Loja Destinatário
								Alltrim(Posicione("SA1",1,xFilial("SA1") + aMsg[oListTmp:nAt][10] + aMsg[oListTmp:nAt][11] ,"A1_NOME")) }}

	If FindFunction('FWPDCanUse') .And. FWPDCanUse(.T.) .And. Len(aColOfusca) > 0
		oListTmp:aObfuscatedCols=aColOfusca
	EndIf	


	EnchoiceBar(oDlgTmp,{|| lOpcClick := .t., oDlgTmp:End()},{|| oDlgTmp:End() },,aButtons)

	oDlgTmp:Activate(,,,.T.)

	IIf(ExistFunc('FwPDLogUser'),FwPdLogUser(cFunction),)

	RestInter()
	
EndIf

Return Nil

//-----------------------------------------------------------------
/*/{Protheus.doc} ExcVgePam()
Obtém dados do array

@author Fabio Marchiori Sampaio
@since 14/04/2021
@version 1.0
/*/
//--------------------------------------------------------------------

Function ExcVgePam(lFechto, lFrotaProp, lLotacao, cFilOri, cViagem, aRetCNPJ, cDTRCIOT, lPayToll,;
cNumIdOpe,cNumIdCli,cNumIdPdg)

Local lRet   := .F.

Default lFechto    := .F.
Default lFrotaProp := .F.
Default lLotacao   := .F. 
Default cFilOri    := ""
Default cViagem    := ""
Default aRetCNPJ   := {}
Default cDTRCIOT   := ""
Default lPayToll   := .F.
Default cNumIdOpe  := ""
Default cNumIdCli  := ""
Default cNumIdPdg  := ""

	If lFechto  //Faz o Estorno da viagem ou do contrato no sistema Pamcard - Chamada no Fechamento da viagem no TMS
		If lFrotaProp //Faz o estorno da viagem no sistema Pamcard -- Fazer consulta para verificar se ja efetivou algum pagto de parcelas ou pedagio, nao estornar caso tenha efetivado.
			If lLotacao
				lRet := PamExcCtr(cFilOri, cViagem, aRetCNPJ, lPayToll,cDTRCIOT,cNumIdOpe,cNumIdCli,cNumIdPdg) 
			Else
				lRet := PamExcVge(cFilOri, cViagem, aRetCNPJ)
			EndIf	
		Else //Faz o estorno do contrato no sistema Pamcard Fazer consulta para verificar se ja efetivou algum pagto de parcelas ou pedagio, nao estornar caso tenha efetivado.
			If DTR->DTR_TPCIOT == "2"
				lRet := PamAltCont( DTR->DTR_CIOT, cFilOri, cViagem, aRetCNPJ, .T.)
			Else
				lRet := PamExcCtr(cFilOri, cViagem, aRetCNPJ, lPayToll,cDTRCIOT,cNumIdOpe,cNumIdCli,cNumIdPdg)
			EndIf
		EndIf
	Else
		If lFrotaProp //Faz o estorno da viagem no sistema Pamcard -- Fazer consulta para verificar se ja efetivou algum pagto de parcelas ou pedagio, nao estornar caso tenha efetivado.
			//Modifica o status da parcela de liberada para Pendente
			lRet := PamEstPaVg(cFilOri, cViagem, aRetCNPJ)
		ElseIf cFilAnt == cFilOri //indica estorno da primeira Saida da viagem
			//Faz o estorno do contrato no sistema Pamcard Fazer consulta para verificar se ja efetivou algum pagto de parcelas ou pedagio, nao estornar caso tenha efetivado.
			lRet := PamEstPaCt(cFilOri, cViagem, aRetCNPJ) //Modifica o status da parcela do adiantamento  de liberada para Bloqueada
		EndIf
	EndIf

Return lRet
//-----------------------------------------------------------------
/*/{Protheus.doc} TMS310AVg()
Obtém dados do array

@author Caio Murakami
@since 22/04/2021
@type function
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FindAdtSDG( cFilOri , cViagem, cCodVei, cDesAdf , nVrPerAdi )
Local aArea		:= GetArea()
Local aAreaSDG	:= SDG->(GetArea())
Local lRet		:= .F. 
Local cQuery	:= ""
Local cAliasQry	:= GetNextAlias()

Default cFilOri		:= ""
Default cViagem		:= ""
Default cCodVei		:= ""
Default cDesAdf		:= ""
Default nVrPerAdi	:= 0 

cQuery	:= " SELECT * "
cQuery	+= " FROM " + RetSQLName("SDG") + " SDG "
cQuery	+= " WHERE DG_FILIAL	= '" + xFilial("SDG") + "' "
cQuery	+= " AND DG_FILORI		= '" + cFilOri + "' "
cQuery	+= " AND DG_VIAGEM		= '" + cViagem + "' "
cQuery	+= " AND DG_CODVEI 		= '" + cCodVei + "' "
cQuery	+= " AND DG_CODDES 		= '" + cDesAdf + "' "
cQuery	+= " AND DG_TOTAL		= '" + cValToChar(nVrPerAdi) + "' "
cQuery	+= " AND SDG.D_E_L_E_T_ = '' "

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

While (cAliasQry)->( !Eof() )
	lRet	:= .F. 
	(cAliasQry)->(dbSkip())
EndDo

(cAliasQry)->(DbCloseArea())

RestArea(aAreaSDG)
RestArea(aArea)
Return lRet 


//-----------------------------------------------------------------
/*/{Protheus.doc} A310EstPam()
Estorna o Contrato na Pamcard
@author Katia
@since 10/05/2021
@type function
@version 1.0
/*/
//--------------------------------------------------------------------
Function A310EstPam(cCodOpe,cFilOri,cViagem,cSerVge,cCodVeiFor,cNumCiot,cNumIdOpe,cNumIdCli,cNumIdPdg)
Local lRet:= .T.
Local aArea:= GetArea()

Local lFrotaProp:= .F.
Local aRetCNPJ  := {}
Local lLotacao  := .F.

Default cCodOpe   := '02'
Default cFilOri   := ""
Default cViagem   := ""
Default cCodVeiFor:= ""
Default cNumCiot  := ""
Default cNumIdOpe := ""
Default cNumIdCli := ""
Default cNumIdPdg := ""

lFrotaProp := Posicione('DA3',1,xFilial('DA3')+cCodVeiFor,'DA3_FROVEI') == '1'

//---- Verifica se a viagem é do Tipo Lotacao (um único CTE na Viagem)
If lFrotaProp
	If ExistFunc('PamQtDocVg') 
		If PamQtDocVg(cFilOri,cViagem,cSerVge) == 1
			lLotacao:= .T.						
		EndIf
	EndIf		
EndIf

aRetCNPJ:= PamCNPJEmp(cCodOpe, cFilOri) //Função para obter CNPJ da contrante e filial de origem

lRet := ExcVgePam( .T. , lFrotaProp, lLotacao, cFilOri, cViagem, aRetCNPJ, cNumCiot, ,cNumIdOpe,cNumIdCli,cNumIdPdg)

RestArea(aArea)
Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} A310AtuPam()
Atualiza dados referente a Pamcard
@author Katia
@since 10/05/2021
@type function
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function A310AtuPam(cFilOri,cViagem,cNumIdOpe, cNumIdCli, cNumIdPdg, cCodVeiFor, cNumCiot)

DTQ->(DbSetOrder(2))
If DTQ->(dbSeek(xFilial('DTQ') + cFilOri + cViagem))
	RecLock("DTQ",.F.)
	DTQ->DTQ_IDOPE:= cNumIdOpe
	DTQ->DTQ_IDCLI:= cNumIdCli
	DTQ->DTQ_IDPDG:= cNumIdPdg
	MsUnlock()
EndIf

Return Nil

//-------------------------------------------------------------------
/*{Protheus.doc} AtuTabSDG
Atualiza SDG
@type Function
@author CAio Murakami
@since 10/06/2021
@version 12.1.30
@param
@return lRet
*/
//------------------------------------------------------------------
Static Function AtuTabSDG( aCab , nOpc )
Local nCount	:= 1 
Local lExclui	:= .F. 
Local aArea		:= GetArea()

Default aCab	:= {}
Default nOpc	:= 3 

If FindFunction("TMSA070Aut")
	TMSA070Aut( aCab , nOpc )
Else 

	If nOpc == 3 
		RecLock("SDG",.T.)
	ElseIf nOpc == 4 .Or. nOpc == 5 
		RecLock("SDG",.F.)
		If nOpc == 5 
			lExclui	:= .T. 
		EndIf 
	EndIf 

	If lExclui
		SDG->(DbDelete())
	Else	
		For nCount := 1 To Len(aCab )
			SDG->&(aCab[nCount,1])	:= aCab[nCount,2]
		Next nCount 
	EndIf 

	SDG->(MsUnlock())
EndIf 

RestArea(aArea)
Return 


/*/{Protheus.doc}  
	A310SVCENT
	Gera operações para o parâmetro MV_SVCENT
	@type  Function
	@author Caio Murakami
	@since 15/06/2021
	@version 1.0
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/

Static Function A310SVCENT( cFilOri , cViagem  , cSerTMS , cTipTra , nOpc )
Local cQuery		:= ""
Local cAliasNew		:= ""
Local cAtivChg		:= SuperGetMv("MV_ATIVCHG",,"")
Local cAtvSaiCli	:= SuperGetMv('MV_ATVSAIC',,'')//-- Atividade de Saída do cliente
Local cAtvChgCli	:= SuperGetMv('MV_ATVCHGC',,'')//-- Atividade de Chegada em Cliente
Local cAtivOld  	:= ""
Local cServic		:= ''
Local cSequen		:= "0"
Local aSequen		:= {}
Local nSequen		:= 0
Local lTM210Car		:= ExistBlock("TM210CAR")
Local lGeraCar		:= .F. 
Local cHoraPre		:= ""
Local dDataPre		:= dDataBase
Local nA			:= 0 
Local nContr		:= 0
Local lRet			:= .T.
Local lIdDTW		:= DTW->(ColumnPos("DTW_IDDTW")) > 0 
Local cIdDTW		:= ""
Local aArea			:= GetArea()
Local lContinua		:= .T. 
Local aDocs		    := {}
Local lGeraDados	:= .F. 
Local cServEnt   	:= Padr(GetMV("MV_SVCENT",,""),Len(DC5->DC5_SERVIC))
Local lGerOper		:= GetMV('MV_GEROPER',,.T.) //-- Verifica se devera gerar as operacoes
Local lCarreg3   	:= FindFunction("TMSAF90") .And. AliasInDic("DM6")

Static _oDadosViag   

Default cFilOri		:= ""
Default cViagem		:= ""
Default cSerTMS		:= ""
Default cTipTra		:= ""
Default nOpc		:= 3 

DTW->(dbSetOrder(1))
If DTW->(MsSeek(xFilial('DTW')+ cFilOri + cViagem ))
	If(!Empty(DTW->DTW_SEQUEN))	
		While DTW->( DTW_VIAGEM == cViagem )
			If DTW->(DTW_STATUS == "1")
				DTW->(DbSkip(-1))
				cSequen := DTW->DTW_SEQUEN
				DTW->(DbSkip())
				Exit
			EndIf
			DTW->(DbSkip())
		EndDo
		DTW->(DbSkip())
	EndIf
EndIf

If lContinua .And. lGerOper .aND. lCarreg3

	If _oDadosViag == Nil 
		lGeraDados	:= .T. 
	Else
		If RTrim(_oDadosViag:cFilOri) <> RTrim(cFilOri) .oR.  RTrim(_oDadosViag:cViagem) <> RTrim(cViagem) 
			lGeraDados	:= .T. 
			_oDadosViag:Destroy()
			_oDadosViag	:= Nil
		EndIf 
	EndIf 
	

	If lGeraDados 
		_oDadosViag	:= TMSBCADadosTMS():New(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,,.F.)
		_oDadosViag:AddCustomerTrip(DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM)			
		_oDadosViag:AddDocs(DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM)
	EndIf 

    aDocs 		:= _oDadosViag:GetDocs()

    cQuery := "SELECT DC5.DC5_SERVIC, DC5.DC5_TAREFA, DC6.DC6_ATIVID "
    cQuery += "FROM " + RetSqlName("DC5") + " DC5 "
    cQuery += "INNER JOIN " + RetSqlName("DC6") + " DC6 "
    cQuery += "ON DC5.DC5_FILIAL = '" + xFilial("DC5") + "' "
    cQuery += "AND DC6.DC6_FILIAL = '" + xFilial("DC6") + "' "
    cQuery += "AND DC5.DC5_TAREFA = DC6.DC6_TAREFA "
    cQuery += "AND DC5.D_E_L_E_T_ = ' ' "
    cQuery += "AND DC6.D_E_L_E_T_ = ' ' "
    cQuery += "WHERE DC5.DC5_SERVIC = '" + cServEnt + "' "

    If !Empty(cSequen) .AND. Len(cSequen) > 1
        cQuery += "AND DC6.DC6_ATIVID IN ('" + cAtvSaiCli + "', '" + cAtvChgCli + "') "
        DTW->(dbSetOrder(4))
        If DTW->(MsSeek(xFilial('DTW')+ cFilOri + cViagem + cAtivChg))
            nSequen := Val(DTW->DTW_SEQUEN)
            nSequen -= 10
            cSequen := StrZero(nSequen, Len(DTW->DTW_SEQUEN) )
        EndIf
    EndIf

    cQuery += "AND NOT EXISTS ("
    cQuery += 	"SELECT DTW.DTW_VIAGEM "
    cQuery += 	"FROM " + RetSqlName("DTW") + " DTW "
    cQuery += 	"WHERE DTW.DTW_FILIAL = '" + xFilial("DTW") + "' "
    cQuery += 	"AND DTW.DTW_FILORI = '" + cFilOri + "' "
    cQuery += 	"AND DTW.DTW_VIAGEM = '" + cViagem + "' "
    cQuery += 	"AND DTW.DTW_SERVIC = DC5.DC5_SERVIC "
    cQuery += 	"AND DTW.DTW_TAREFA = DC5.DC5_TAREFA "
    cQuery += 	"AND DTW.DTW_ATIVID = DC6.DC6_ATIVID "
    cQuery += 	"AND DTW.DTW_STATUS = '1' "
    cQuery += 	"AND DTW.D_E_L_E_T_ = ' ')"

    cQuery := ChangeQuery(cQuery)

    cAliasNew := GetNextAlias()
    DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasNew,.F.,.T.)

	While (cAliasNew)->(!Eof())

		//-- Como utilizamos o mesmo servico de carregamento para transporte e entrega, este ponto de entrada
		//-- permite ao cliente escolher em qual servico quer gerar a operacao de carregamento.
		If lTM210Car
			lGeraCar := ExecBlock("TM210CAR",.F.,.F.,{cServic})
			If	ValType(lGeraCar) <> "L"
				lGeraCar := .T.
			EndIf
		EndIf

		//-- Nao gera operacoes de "Carregamento" nas "Viagens de Socorro"
		//-- pois o carregamento ja ocorreu na viagem original.
		If DTQ->DTQ_TIPVIA == "4" .And. (cServEnt == cServic .Or. !lGeraCar)
			(cAliasNew)->(dbSkip())
			Loop
		EndIf
		
		cHoraPre := Time()
		cAtivOld := ""
		
		// Viagem criada pelo painel, chama a rotina de carregamento duas vezes
		// Verifica se as operações desta Tarefa x Atividade já foram criadas
		IF IsInCallStack("TMSF76Via") .And. IsInCallStack("TMSF76Crg")
			DTW->(dbSetOrder(2))  // DTW_FILIAL + DTW_SERTMS + DTW_TIPTRA + DTW_FILORI + DTW_VIAGEM + DTW_SEQUEN
			If DTW->(MsSeek(xFilial('DTW') + cSerTms + cTipTra + cFilOri +  cViagem ))
				(cAliasNew)->(dbSkip())
				Loop
			EndIf
		Endif
			
		//-- Calcula a data e hora prevista
		SomaDiaHor( @dDataPre, @cHoraPre, TmsHrToInt(DC6->DC6_DURAC) )
		//-- Verificando se a sequencia obtida pode ser utilizada sem duplicidade.
		cSequen := Soma1(cSequen)
		DTW->(dbSetOrder(1))
		DTW->(MsSeek(xFilial('DTW')+cFilOri + cViagem +cSequen))
		If Empty(aSequen)
			If( cSequen == DTW->DTW_SEQUEN )					//-- Monta o array aSequen com sequencia inicial
				While ( DTW->DTW_VIAGEM == M->DTA_VIAGEM )
					Aadd( aSequen, { Soma1(DTW->DTW_SEQUEN)	, DTW->(RECNO()) } )
					DTW->(DbSkip())
				EndDo
				nContr++
			EndIf
		Else
			For nA := 1 To Len(aSequen)								//-- Adciona no array aSequen a quantidade de ocorrências
				aSequen[nContr][1] := Soma1(aSequen[nContr][1])	//-- que foram incluidas para que elas sejam incluidas 
				DTW->(DbSkip())										//-- entre as ocorrências que já existiam.
				nContr++
			Next nA
			nContr := 1
		EndIf

		If cAtivOld != (cAliasNew)->DC6_ATIVID	
			cAtivOld := (cAliasNew)->DC6_ATIVID	
			//-- Gravando DTW
			aCab := {}
			Aadd( aCab, { 'DTW_FILORI'	, cFilOri										, Nil } )
			Aadd( aCab, { 'DTW_VIAGEM'	, cViagem										, Nil } )
			Aadd( aCab, { 'DTW_SEQUEN'	, PADL(cSequen,TAMSX3("DTW_SEQUEN")[1],"0"), Nil } )
			Aadd( aCab, { 'DTW_DATPRE'	, dDataPre									, Nil } )
			Aadd( aCab, { 'DTW_HORPRE'	, StrTran(Left(cHoraPre,5),':','')			, Nil } )
			Aadd( aCab, { 'DTW_SERVIC'	, (cAliasNew)->DC5_SERVIC					, Nil } )
			Aadd( aCab, { 'DTW_TAREFA'	, (cAliasNew)->DC5_TAREFA					, Nil } )
			Aadd( aCab, { 'DTW_ATIVID'	, (cAliasNew)->DC6_ATIVID					, Nil } )
			Aadd( aCab, { 'DTW_SERTMS'	, cSerTms									, Nil } )
			Aadd( aCab, { 'DTW_TIPTRA'	, cTipTra									, Nil } )
			Aadd( aCab, { 'DTW_TIPOPE'	, StrZero(2,TAMSX3("DTW_STATUS")[1])		, Nil } ) // Tipo de Operacao == "Carregamento"
			Aadd( aCab, { 'DTW_DATREA'	, Ctod('')							, Nil } )
			Aadd( aCab, { 'DTW_HORREA'	, ''										, Nil } )
			Aadd( aCab, { 'DTW_STATUS'	, StrZero(1,TAMSX3("DTW_STATUS")[1])		, Nil } )
			
			If lIdDTW .And. ExistFunc("Tm351IdDTW")
				cIdDTW := Tm351IdDTW( cFilOri , cViagem 	)
				Aadd( aCab, { 'DTW_IDDTW'	, cIdDTW																		, Nil } )
			EndIf

			//--Cria a DTW
			lRet := TMSCriaDTW( aCab )
			
			If lRet 
				AtuSeqDTA( cFilOri , cViagem , cSequen, nOpc )
			EndIf 

		EndIf
			
		(cAliasNew)->(dbSkip())
	EndDo

	(cAliasNew)->(dbCloseArea())

	
    oDadosViag := Nil
    FreeObj(oDadosViag)
    aSize(aDocs, 0)
	aDocs := Nil

EndIf
					
RestArea(aArea)
Return

/*/{Protheus.doc}  
	AtuSeqDTW
	Atualiza DTA_SEQDTW
	@type  Function
	@author Caio Murakami
	@since 15/06/2021
	@version 1.0
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/

Static Function AtuSeqDTA( cFilOri , cViagem , cSeqDTW, nOpc )
Local aArea		:= GetArea() 
Local lRet		:= .T. 

Default cFilOri		:= ""
Default cViagem		:= ""
Default cSeqDTW		:= ""
Default nOpc		:= 3 

DTA->( dbSetOrder(2))
If DTA->( MsSeek( xFilial("DTA") + cFilOri + cViagem )) .And. !Empty(cSeqDTW)

	While DTA->( !Eof() ) .And. DTA->(DTA_FILIAL + DTA_FILORI + DTA_VIAGEM ) ==  xFilial("DTA") + cFilOri + cViagem
		DTA->(RecLock("DTA"), .F. )
		DTA->DTA_SEQDTW		:= cSeqDTW
		DTA->(MsUnLock())
		DTA->( dbSkip() )  
	EndDo

EndIf 

RestArea( aArea )
Return lRet 

/*/{Protheus.doc}  
	AtuSeqDTW
	Atualiza DTA_SEQDTW
	@type  Function
	@author fabio marchiori
	@since 05/07/2021
	@version 1.0
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/

Static Function GeraSDG(cFilOri, cViagem, cDesAdf, nVrAdiABS,nItemSDG,cCodVei,aRetForn)

Local cDocSDG   := ""
Local cBanco    := ""
Local cAgencia  := ""
Local cNumCon   := ""
Local aCabSDG   := {}
	
Default cFilOri   := ""
Default cViagem   := ""
Default cCodVei   := ""
Default cDesAdf   := ""
Default nVrPerAdi := 0
Default nItemSDG  := 1
Default aRetForn  := {}

    cDocSDG := NextNumero("SDG",1,"DG_DOC",.T.)
	DEG->(DbSetOrder(1))
	
	If !Empty(DTR->DTR_CODOPE) .And. DEG->(MsSeek(xFilial('DEG')+DTR->DTR_CODOPE))
		cBanco    := DEG->DEG_BANCO
		cAgencia  := DEG->DEG_AGENCI
		cNumCon   := DEG->DEG_NUMCON
	ElseIf Empty(DTR->DTR_CODOPE)
		cBanco    := CriaVar("DG_BANCO")
		cAgencia  := CriaVar("DG_AGENCIA")
		cNumCon   := CriaVar("DG_NUMCON")
	EndIf

	TMA250GrvSDG("DTR",cFilOri, cViagem, cDesAdf, nVrAdiABS,nItemSDG,cCodVei,cDocSDG,,,,,,,.T.,cBanco, cAgencia, cNumCon,,,,"TMSA310","2")

	If aRetForn[1][13] == '1' //Momento da geração do Adto 
		SDG->(dbSetOrder(1))
		If SDG->(MsSeek(FwxFilial('SDG')+cDocSDG)) 
			
			FwFreeArray(aCabSDG)
			aCabSDG	:= {} 
			Aadd( aCabSDG , { "DG_TITGER", "1" 			, Nil })
			Aadd( aCabSDG , { "DG_ORITIT", "TMSA310"	, Nil })

			AtuTabSDG( aCabSDG , 4 )
		EndIf
	EndIf

Return ()

//-----------------------------------------------------------------
/*/{Protheus.doc} A310Tele
Envia a metrica sigatms-protheus_tipo-de-veiculo-de-transporte_total

@author Rodrigo Pirolo
@since 30/08/2021
@type function
@version 1.0
/*/
//--------------------------------------------------------------------
Function A310Tele( cFilOri, cViagem )

Local aArea       := GetArea()
Local aAreaDTR    := DTR->( GetArea() )
Local aAreaDA3    := DA3->( GetArea() )
Local cSubRot	:= ""

Default cFilOri	:= ""
Default cViagem	:= ""

DA3->( DbSetOrder(1) )
DTR->( DbSetOrder(1) )

If DTR->( DbSeek( xFilial( 'DTR' ) + cFilOri + cViagem ) )

	While xFilial( 'DTR' ) + cFilOri + cViagem == DTR->( DTR_FILIAL + DTR_FILORI + DTR_VIAGEM )
		
		If DA3->( MsSeek( xFilial('DA3') + DTR->DTR_CODVEI ) )
			If DA3->DA3_FROVEI == '1'
				cSubRot := 'Propria'
			ElseIf DA3->DA3_FROVEI == '2'
				cSubRot := 'Terceiro'
			ElseIf DA3->DA3_FROVEI == '3'
				cSubRot := 'Agregado'
			EndIf
			
			lRet:= TMSAddMet( 'TMS310_Frota_' + cSubRot , 'sigatms-protheus_tipo-de-veiculo-de-transporte_total' /*IdMetrica*/, 1/*nValueMet*/, /*nTimeMet*/, 'S', dDataBase, 1, 'TMSA310' )// 1=Propria; 2=Terceiro; 3=Agregado
		EndIf

		DTR->( DbSkip() )
	EndDo

EndIf

RestArea( aAreaDTR )
RestArea( aAreaDA3 )
RestArea( aArea )

Return Nil

/*{Protheus.doc} ExisteDN5
Verifica se existe DN5 em aberto
@author Valdemar Roberto Mognon
@since 04/07/2022
*/

Function ExisteDN5(cCodFon,cCodReg,cProces,aStatus,nRegistro)
Local lRet      := .F.
Local cQuery    := ""
Local cStatus   := ""
Local cAliasDN5 := ""
Local aArea     := GetArea()
Local nCntFor1  := 0

Default cCodFon := ""
Default cCodReg := ""
Default cProces := ""
Default aStatus := {}

For nCntFor1 := 1 To Len(aStatus)
	cStatus := cStatus + "'" + aStatus[nCntFor1] + "',"
Next nCntFor1
cStatus := Iif(!Empty(cStatus),Left(cStatus,Len(cStatus) - 1),cStatus)

cAliasDN5 := GetNextAlias()
cQuery	:= "SELECT DN5.R_E_C_N_O_ REGISTRO "
cQuery	+= "  FROM " + RetSQLName("DN5") + " DN5 "
cQuery	+= " WHERE DN5_FILIAL = '" + xFilial("DN5") + "' "
cQuery	+= "   AND DN5_CODFON = '" + cCodFon + "' "
cQuery	+= "   AND DN5_CODREG = '" + cCodReg + "' "
cQuery	+= "   AND DN5_PROCES = '" + cProces + "' "
cQuery	+= "   AND DN5_STATUS IN(" + cStatus + ") "
cQuery	+= "   AND DN5.D_E_L_E_T_ = ' '"

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasDN5,.F.,.T.)

If (cAliasDN5)->(!Eof())
	nRegistro := (cAliasDN5)->REGISTRO
	lRet      := .T. 
EndIf

(cAliasDN5)->(DbCloseArea())

RestArea(aArea)

Return lRet

/*{Protheus.doc} TM310PrcFe
Processa envio e estorno da integração com coleta/entrega
@type Function
@author Valdemar Roberto Mognon
@since 08/08/2022
@version version
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
*/
Function TM310PrcFe(nOpcx,nFase,lCont,aDocsTra)
Local lOk        := .T.
Local aAreaCol   := {}
Local aStatusVia := {}
Local aLayout    := {}
Local aStruct    := {}
Local aAreaDN5   := {}
Local cSequen    := ""
Local cAliasDN5  := ""
Local cQuery     := ""
Local nCntFor2   := 0
Local oColEnt
Local aViagens   := {}
Local aAreaDTQ   := {}
Local aColigada  := {}
Local nCntFor1   := 0
Local nColFec    := 0
Local nRegistro  := 0
Local lPrimeiro  := .T.
Local cSeekDN5   := ""

Default nOpcx    := 0
Default nFase    := 0
Default aDocsTra := {}

//-- Mapa do vetor aStruct
//-- 01 - Código da fonte
//-- 02 - Código do registro
//-- 03 - Alias do registro
//-- 04 - Indice do registro
//-- 05 - Prioridade de envio
//-- 06 - Registro do qual o alias do registro é dependente
//-- 07 - Comando de posicionamento no alias de dependência
//-- 08 - Condição de repetição (loop) dos registros
//-- 09 - Condição de uso do registro do alias de dependência
//-- 10 - Indica se o registro já foi processado
//-- 11 - Fonte do registro adicional
//-- 12 - Registro adicional

If nOpcx == 5 // Estorno
	If nFase == 1	//-- Valida se pode estornar
		oColEnt    := TMSBCACOLENT():New("DN1")
		If oColEnt:DbGetToken()
			DN1->(DbGoTo(oColEnt:config_recno))
			If DN1->DN1_ENVREG == "1"	//-- Fechamento da viagem
				//-- Define Viagens
				aAreaCol  := DTQ->(GetArea())
				aViagens  := VgaPrincial(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM)
				aColigada := VgaColigada(aViagens[1,1],aViagens[1,2],.F.)
				RestArea(aAreaCol)

				//-- Verifica se nenhuma das viagens coligadas está com status diferente de fechada
				nColFec := 0
				For nCntFor1 := 1 To Len(aColigada)
					If aColigada[nCntFor1,1] + aColigada[nCntFor1,2] != DTQ->(DTQ_FILORI + DTQ_VIAGEM) .And. aColigada[nCntFor1,5] != StrZero(1,Len(DTQ->DTQ_STATUS))
						nColFec ++
					EndIf
				Next nCntFor1

				If nColFec == 0
					//-- Inicializa a estrutura
					aStruct   := TMSMntStru(DN1->DN1_CODFON,.T.)

					//-- Localiza primeiro registro da estrutura
					For nCntFor2 := 1 To Len(aStruct)
						//-- Não é adicional de ninguém, ainda não foi processado e não dependente de ninguém
						If (Ascan(aStruct,{|x| x[11] + x[12] == aStruct[nCntFor2,1] + aStruct[nCntFor2,2]}) == 0) .And. ;
															aStruct[nCntFor2,10] == "2" .And. Empty(aStruct[nCntFor2,6])
							Exit
						EndIf
					Next nCntFor2

					//-- Guarda variáveis estaticas
					cCodFonCol := aStruct[nCntFor2,1]
					cProcesCol := PadR(aViagens[1,1] + aViagens[1,2],Len(DN5->DN5_PROCES))

					If ExisteDN5(aStruct[nCntFor2,1],aStruct[nCntFor2,2],PadR(aViagens[1,1] + aViagens[1,2],Len(DN5->DN5_PROCES)),{"1","2","3","7"},@nRegistro)
						DN5->(DbGoTo(nRegistro))
						lCont := .T.
						If DN5->DN5_STATUS == "1" .And. !Empty(DN5->DN5_IDEXT)
							If (aStatusVia := TMSAC30GDV(DN5->DN5_IDEXT,,.F.))[1]
								If aStatusVia[2] != "AGUARDANDO_DESPACHO"
									Help(" ", , STR0082, , STR0083 + aStatusVia[2], 2, 1)
									lOk := .F.
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
		FwFreeObj(oColEnt)
	ElseIf nFase == 2	//-- Tratamento no histórico de integrações
		If Empty(DN5->DN5_IDEXT) .Or. TMSAC30ExA(AllTrim(DN5->DN5_IDEXT))
			cAliasDN5 := GetNextAlias()
			cQuery := "SELECT DN5.DN5_CODFON DN5_CODFON, DN5.DN5_CODREG DN5_CODREG,DN5.R_E_C_N_O_ REGISTRO "
			cQuery += "  FROM " + RetSqlName("DN5") + " DN5 "
			cQuery += " WHERE DN5.DN5_FILIAL = '" + xFilial("DN5") + "' "
			cQuery += "   AND DN5.DN5_CODFON = '" + cCodFonCol + "' "
			cQuery += "   AND DN5.DN5_PROCES = '" + cProcesCol + "' "
			cQuery += "   AND DN5.DN5_STATUS NOT IN ('5','6') "
			cQuery += "   AND DN5.D_E_L_E_T_ = ' ' "

			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasDN5,.F.,.T.)

			DN4->(DbSetOrder(1))
			DNC->(DbSetOrder(1))

			While (cAliasDN5)->(!Eof())
				//-- Estorna registro na DN5
				DN5->(DbGoTo((cAliasDN5)->REGISTRO))
				RecLock("DN5",.F.)
				DN5->DN5_STATUS := Iif(Empty(DN5->DN5_IDEXT),"6","5")	//-- Estornado Envio ou Estornado
				DN5->DN5_SITUAC := StrZero(3,Len(DN5->DN5_SITUAC))	//-- Estornado
				DN5->(MsUnLock())

				//-- Estorna registro na DN4
				DN4->(MsSeek(xFilial("DN4")+DN5->(DN5_CODFON+DN5_CODREG+DN5_CHAVE)))
				RecLock("DN4",.F.)
                DN4->DN4_IDEXT  := ""
                DN4->DN4_STATUS := '2'
				DN4->(MsUnLock())

				If lPrimeiro
					If DNC->(DbSeek(xFilial("DNC") + DN5->(DN5_CODFON + DN5_PROCES)))
						Reclock("DNC",.F.)
						DNC->DNC_STATUS := DN5->DN5_STATUS	//-- Estornado Envio ou Estornado
						DNC->DNC_SITUAC := DN5->DN5_SITUAC	//-- Estornado
						DNC->DNC_DATULT := dDataBase
						DNC->DNC_HORULT := SubStr(Time(),1,2) + SubStr(Time(),4,2)
						DNC->(MsUnlock())
					EndIf
					lPrimeiro := .F.
				EndIf
				(cAliasDN5)->(DbSkip())

			EndDo
			(cAliasDN5)->(DbCloseArea())

		Else
			DisarmTransaction()

		EndIf
	EndIf
ElseIf nOpcx == 3	//-- Fechamento
	oColEnt  := TMSBCACOLENT():New("DN1")
	If oColEnt:DbGetToken() .And. !Empty(oColEnt:filext)
		DN1->(DbGoTo(oColEnt:config_recno))
		If DN1->DN1_ENVREG == "1" .Or. !Empty(aDocsTra)	//-- Fechamento da viagem
			//-- Define Viagens
			aAreaDTQ  := DTQ->(GetArea())
			aViagens  := VgaPrincial(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM)
			aColigada := VgaColigada(aViagens[1,1],aViagens[1,2],.F.)

			//-- Verifica se todas as viagens coligadas estão fechadas
			nColAbe := 0
			For nCntFor1 := 1 To Len(aColigada)
				If aColigada[nCntFor1,1] + aColigada[nCntFor1,2] != DTQ->(DTQ_FILORI + DTQ_VIAGEM) .And. aColigada[nCntFor1,5] != StrZero(5,Len(DTQ->DTQ_STATUS))
					nColAbe ++
				EndIf
			Next nCntFor1
	
			If nColAbe == 0
				DTQ->(DbSetOrder(2))
				For nCntFor1 := 1 To Len(aColigada)
					//Posiciona na viagem Coligada
					DTQ->(MsSeek(xFilial("DTQ")+aColigada[nCntFor1,1] + aColigada[nCntFor1,2]))
					
					//-- Inicializa a estrutura
					aStruct   := TMSMntStru(DN1->DN1_CODFON,.T.)
					TMSSetVar("aStruct",aStruct)
					
					//-- Define o processo
					TMSSetVar("cProcesso",aViagens[1,1] + aViagens[1,2])

					//-- Inicializa o localizador
					TMSSetVar("aLocaliza",{})

					//-- Define os documentos em transito
					TMSSetVar("aTransito",Aclone(aDocsTra))
		
					DUP->(DbSetOrder(1))
					If DUP->(DbSeek(xFilial("DUP") + aViagens[1,1] + aViagens[1,2] )) .And. !Empty(BscIDMot(DUP->DUP_CODMOT,DN1->DN1_CODFON,))
						aAreaCol := {}
						Aadd(aAreaCol,GetArea())
						Aadd(aAreaCol,DN1->(GetArea()))
						For nCntFor2 := 1 To Len(aStruct)
							Aadd(aAreaCol,(aStruct[nCntFor2,3])->(GetArea()))
							If (Ascan(aStruct,{|x| x[11] + x[12] ==  aStruct[nCntFor2,1] +  aStruct[nCntFor2,2]}) == 0) .And. aStruct[nCntFor2,10] == "2"	//-- Não é adicional de ninguém e ainda não foi processado
								aLayout := BscLayout(aStruct[nCntFor2,1],aStruct[nCntFor2,2])
								If !Empty(aLayout)
									If Empty(aStruct[nCntFor2,6])
										//-- Localiza a sequencia no caso de viagem coligada
										If Len(aColigada) > 1 .Or. !Empty(aDocsTra)
											aAreaDN5 := DN5->(GetArea())
											DN5->(DbSetOrder(3))
											DN5->(DbSeek(cSeekDN5 := xFilial("DN5") + aStruct[nCntFor2,1] + aStruct[nCntFor2,2] + aViagens[1,1] + aViagens[1,2]))
											Do While !DN5->(Eof()) .And. cSeekDN5 == DN5->(DN5_FILIAL+DN5_CODFON+DN5_CODREG+RTrim(DN5_PROCES))
												cSequen := DN5->DN5_SEQUEN
												DN5->(DbSkip())
											EndDo
											RestArea(aAreaDN5)
										EndIf
										//-- Inicia a gravação dos registros
										MontaReg(Aclone(aLayout),nCntFor2,;
											aColigada[nCntFor1,1] + aColigada[nCntFor1,2] == aViagens[1,1] + aViagens[1,2] .And. Empty(aDocsTra),;
											cSequen,.T.)
										TMSCtrLoop(Aclone(aLayout),nCntFor2)
									EndIf
								EndIf
							EndIf
							aStruct := TMSGetVar("aStruct")
						Next nCntFor2
						AEval(aAreaCol,{|x,y| RestArea(x),FwFreeArray(x)})
					EndIf
				Next nCntFor1
            EndIf
            
			RestArea(aAreaDTQ)
			FwFreeArray(aAreaDTQ)
		EndIf
	EndIf
EndIf

Return lOk
