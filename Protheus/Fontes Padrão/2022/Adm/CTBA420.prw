#Include "PROTHEUS.ch"
#Include "FWMVCDEF.CH"
#Include "CTBA420.CH"

Static __aCTBA420 := {}

// Defines do grupo de perguntas.
#Define POS_DATINI 01 // Data Inicial
#Define POS_DATFIM 02 // Data Final
#Define POS_TIPEXP 03 // Tipo de Exportação
#Define POS_TIPSLD 04 // Tipo de Saldo
#Define POS_FILINI 05 // Finial Inicial
#Define POS_FILFIM 06 // Filial Final
#Define POS_CNTINI 07 // Conta Contábil Inicial
#Define POS_CNTFIM 08 // Conta Contábil Final
#Define POS_CCINI  09 // Centro de Custo Inicial
#Define POS_CCFIM  10 // Centro de Custo Final
#Define POS_ITCINI 11 // Item Contábil Inicial
#Define POS_ITCFIM 12 // Item Contábil Final
#Define POS_CLCINI 13 // Classe de Valor Inicial
#Define POS_CLCFIM 14 // Classe de Valor Final
#Define POS_ARQUIV 15 // Arquivo
#Define POS_CFGLIV 16 // Código config. livro
#Define POS_SLDZER 17 // Saldos zerados
Static __nQtdePerg := 17  // Quantidade de parâmetros (MV_PARxx).



//-------------------------------------------------------------------
/*/{Protheus.doc} CTBA420
Rotina que realiza a exportação de movimentos contábeis ou saldos do período,
em formato txt, para integração com sistemas externos.

@author Jandir Deodato
@since 03/01/2013
@version MP11.80
@param aAutoCab, Vetor com os valores informados no ExecAuto
@return lRet
/*/
//-------------------------------------------------------------------
Function CTBA420(aAutoCab)

Local lRet       := .T.
Local aSays      := {}
Local aSM0       := AdmAbreSM0()
Local aButtons   := {}
Local nOpca      := 0
local lCubo      := CTBisCube()
Local cPerg      := ""
Local cDirTxt    := GetMV("MV_CTBDTXT",.F.,"")
Local nHandle    := 0
Local cPerg2     := "CTBA420E"
Local lGerPlan   := .F.
Local aSelFil    := {}

Private l420Auto	:= (Valtype(aAutoCab) <> "U" .and. !Empty(aAutoCab))
Private cCadastro	:= STR0001 // 'Exportação Txt de Movimentos Contábeis'
Private aEntidades	:= {} // Array de verificação das entidades contábeis adicionais, com 5 posições.
Default aAutocab	:= {} // Posição 01 - boleano indicando se a entidade contábil existe ou não. Posicao 02: texto do pergunte inicial em BRA.

IF Len( aSM0 ) <= 0
	Help(" ",1,"NOFILIAL")
	lRet := .F.
Else
	If !Empty(cDirTxt) .And. !l420Auto
		cPerg := "CTBA420A"
	Else
		cPerg := "CTBA420"
	EndIf
	CTB420CarE(@aEntidades)

	// Se o parametro de cubo estiver acionado e houver uma entidade adicional, cria um pergunte para entidades adicionais
	If aEntidades[1][1]
		If lCubo
			CriaSX1(cPerg2)
		Else
			lRet := .F.
		Endif
	Endif

	If lRet
		If !l420Auto
			AADD(aSays,STR0002)//'Esta rotina realiza a exportação de movimentos contábeis ou'
			AADD(aSays,STR0003)//'a exportação de saldos do período,em formato TXT,
			AADD(aSays,STR0029)//para a integração com sistemas externos.'
			If aEntidades[1][1]
				AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg, .T.) .and. Pergunte(cPerg2, .T.) }} )
			Else
				AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg, .T.) }} )
			Endif
			AADD(aButtons, { 1,.T.,{|| nOpca:= 1, If( CTBOk(), FechaBatch(), nOpca:=0 ) }} )
			AADD(aButtons, { 2,.T.,{|| ( FechaBatch(), lRet := .F. ) }} )

			FormBatch( cCadastro, aSays, aButtons )

			// Preenche o array de parametros, com base nas respostas do pergunte.
			__aCTBA420 := {}
			Pergunte(cPerg, .F.)
			CTBA420Arr(cPerg)
			If aEntidades[1][1]
				// Preenche o array de parametros, com base nas respostas do pergunte de entidades adicionais.
				Pergunte(cPerg2, .F.)
				CTBA420Arr(cPerg2)
			Endif
		Else // Rotina automática. Carrega o pergunte com o array enviado.
			CTB420CarP(aAutoCab)
			nOpca:=1
		Endif

		//Verifica se o livro contábil foi informado e se há uma visão gerencial no mesmo
		If lRet .AND. !Empty(__aCTBA420[POS_CFGLIV])
			//Não processa se o tipo de exportação for "Movimentos" e houver um código de livro informado
			If __aCTBA420[POS_TIPEXP] = 1
				Help(,,'CTB420SETOF',,OemToAnsi(STR0036),1,0) //'Para exportação do tipo "Movimento", o parâmetro "Cod. Config. Livros" deve estar vazio.'
				lRet := .F.
			Else
				//Verifica se o Livro é válido e se há uma visão gerencial informada
				If !VdSetOfBook(__aCTBA420[POS_CFGLIV], .T.)
					lRet := .F.
				Else
					lGerPlan := .T.
				Endif
			Endif
		Endif

		If lRet
			nHandle := FCREATE(__aCTBA420[POS_ARQUIV])

			If nHandle < 0
				Help(,,'CTB420NOFILE',,STR0034,1,0)//"Não foi possível criar o arquivo no diretório informado. Por favor verifique."
				lRet := .F.
			Else
				Fclose(nHandle)
				FERASE(__aCTBA420[POS_ARQUIV])
				lRet := .T.
			EndIf

			If lRet .And. nOpca == 1
				If __aCTBA420[POS_TIPEXP]==1 //movimento contabil
					IF !IsBlind()
						MsgRun(STR0031,STR0030,{||lRet:=Ctb420Mov()})//"Aguarde, processando movimentos contábeis" - 'Exportação TXT Mov'
					Else
						lRet:=Ctb420Mov()
					Endif
				ElseIf __aCTBA420[POS_TIPEXP]==2 //saldo Contabil
					//Se for exportação de saldo com visão gerencial, popula o vetor de filiais para consolidação do saldo, com base no range de filiais definido no pergunte
					If lGerPlan
						aSelFil := CtSelFil(aSM0)
					Endif

					If !IsBlind()
						MsgRun(STR0032,STR0030,{||lRet:=Ctb420Sald(lGerPlan,aSelFil)})//"Aguarde, processando saldos contábeis" - 'Exportação TXT Mov'
					Else
						lRet:=Ctb420Sald(lGerPlan,aSelFil)
					Endif
				Else
					Help(,,'CTB420NOEXP',,STR0004,1,0)//'Não foi informado um tipo de exportação válida.'
				Endif
			Endif
		Endif
	Else
		Help(,,'CTB420NOCUB',,STR0025,1,0)//"Para usar esta rotinas com as Entidades Contábeis adicionais no sistema, é necessário configurar o parametro MV_CTBCUBE e recalcular os saldos."
	Endif

	If lRet .and. nOpca==1 .and. !IsBlind()
		If cPerg == "CTBA420"
			MsgInfo(STR0006+" " + __aCTBA420[POS_ARQUIV],cCadastro)//"Exportação realizada com sucesso! Arquivo gerado:"
		Else
			MsgInfo(STR0035,cCadastro)//"Exportação realizada com sucesso!"
		EndIf
	Endif
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Ctb420Mov
Funcao de processamento das busca a partir dos dados do pergunte ( exportação de movimentos contabeis).

@author Jandir Deodato
@since 03/01/2013
@version MP11.80
/*/
//-------------------------------------------------------------------
Function Ctb420Mov()

Local lRet			:= .T.
Local aArea			:= GetArea()
Local cQuery		:= ''
Local cErro			:= ''
Local cAlias		:= ''
Local aErro			:= {}
Local nX			:= 0
Local lCTB420QRY   	:= ExistBlock("CTB420QRY")

If Empty(__aCTBA420[POS_ARQUIV])//tipo de arquivo
	Aadd(aErro, STR0016)//'Local de gravação do arquivo TXT não informado.'
	lRet := .F.
Else
	cQuery += "SELECT " + CRLF
	cQuery += "CT2_FILIAL FILIAL, CT2_DATA DATA, CT2_LOTE LOTE, CT2_SBLOTE SBLOTE, CT2_DOC DOC, CT2_LINHA LINHA, CT2_MOEDLC MOEDA, CT2_DC, " + CRLF
	cQuery += "CT2_ATIVDE, CT2_ATIVCR, CT2_ORIGEM, CT2_ROTINA, CT2_CODFOR, CT2_CODCLI, CT2_LP, " + CRLF
	//outras entidades
	If aEntidades[1][1]// se nao existir a 05,as outras nao vao existir. Sao criadas em sequencia.
		cQuery += "CT2_EC05DB,CT2_EC05CR," + CRLF
		If  aEntidades[2][1]
			cQuery += "CT2_EC06DB,CT2_EC06CR," + CRLF
			If  aEntidades[3][1]
				cQuery += "CT2_EC07DB,CT2_EC07CR," + CRLF
				If  aEntidades[4][1]
					cQuery += "CT2_EC08DB,CT2_EC08CR," + CRLF
					If  aEntidades[5][1]
						cQuery += "CT2_EC09DB,CT2_EC09CR," + CRLF
					Endif
				Endif
			Endif
		Endif
	Endif
	cQuery += "CT2_TPSALD TPSALDO, CT2_DEBITO, CT2_CREDIT, CT2_CCD, CT2_CCC, CT2_ITEMD, CT2_ITEMC, " + CRLF
	cQuery += "CT2_CLVLDB, CT2_CLVLCR, CT2_VALOR, CT2_HIST, " + CRLF
	cQuery += "CT2_SEQLAN, CT2_EMPORI, CT2_FILORI, CT2_SEQHIS, CT2.R_E_C_N_O_ " + CRLF
	cQuery += "FROM "+ RetSqlName("CT2") + " CT2 " + CRLF
	cQuery += "WHERE CT2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "AND CT2_DC in ('1', '2', '3') "  + CRLF // Somente débito, crédito e partida dobrada.

	If Empty(__aCTBA420[POS_FILFIM]) //filtro da filial
		If !Empty(__aCTBA420[POS_FILINI])
			Aadd(aErro,STR0008)//'Inconsistência na Filial de/até.'
			lRet := .F.
		Endif
	Else
		cQuery += "AND CT2_FILIAL BETWEEN '"
		cQuery += xFilial("CT2",__aCTBA420[POS_FILINI]) + "' AND '" + xFilial("CT2", __aCTBA420[POS_FILFIM]) + " '" + CRLF
	Endif

	// Filtro da data
	If Empty(__aCTBA420[POS_DATFIM])
		If !Empty(__aCTBA420[POS_DATINI])
			Aadd(aErro,STR0009)//'Inconsistencia na Data de/até.'
			lRet := .F.
		Endif
	Else
		cQuery += "AND CT2_DATA BETWEEN '"
		cQuery += DtoS(__aCTBA420[POS_DATINI]) + "' AND '" + DTOS(__aCTBA420[POS_DATFIM]) + "' " + CRLF
	Endif

	// Filtro da conta contabil
	If Empty(__aCTBA420[POS_CNTFIM])
		If !Empty(__aCTBA420[POS_CNTINI])
			Aadd(aErro,STR0010)//'Inconsistência na Conta contábil de/até.'
			lRet := .F.
		Endif
	Else
		cQuery += "AND (" + CRLF
		cQuery += "    (CT2_DEBITO BETWEEN  '"
		cQuery += __aCTBA420[POS_CNTINI] + "' AND '" + __aCTBA420[POS_CNTFIM] + "') OR " + CRLF
		cQuery += "    (CT2_CREDIT BETWEEN '"
		cQuery += __aCTBA420[POS_CNTINI] + "' AND '" + __aCTBA420[POS_CNTFIM] + "') " + CRLF
		cQuery += ") " + CRLF
	Endif

	// Filtro do centro de custo
	If Empty(__aCTBA420[POS_CCFIM])
		If !Empty(__aCTBA420[POS_CCINI])
			Aadd(aErro,STR0011)//'Inconsistência no Centro de Custo de/até.'
			lRet := .F.
		Endif
	Else
		cQuery += "AND (" + CRLF
		cQuery += "    (CT2_CCD BETWEEN  '"
		cQuery += __aCTBA420[POS_CCINI] + "' AND '" + __aCTBA420[POS_CCFIM] + "') OR " + CRLF
		cQuery += "    (CT2_CCC BETWEEN '"
		cQuery += __aCTBA420[POS_CCINI] + "' AND '" + __aCTBA420[POS_CCFIM] + "') " + CRLF
		cQuery += ") " + CRLF
	Endif

	// Filtro do item contabil
	If Empty(__aCTBA420[POS_ITCFIM])
		If !Empty(__aCTBA420[POS_ITCINI])
			Aadd(aErro,STR0012)//'Inconsistência no Item Contábil de/até.'
			lRet := .F.
		Endif
	Else
		cQuery += "AND (" + CRLF
		cQuery += "    (CT2_ITEMD BETWEEN  '"
		cQuery += __aCTBA420[POS_ITCINI] + "' AND '" + __aCTBA420[POS_ITCFIM] + "') OR " + CRLF
		cQuery += "    (CT2_ITEMC BETWEEN '"
		cQuery += __aCTBA420[POS_ITCINI] + "' AND '" + __aCTBA420[POS_ITCFIM] + "') " + CRLF
		cQuery += ") " + CRLF
	Endif

	// Filtro da classe de valor
	If Empty(__aCTBA420[POS_CLCFIM])
		If !Empty(__aCTBA420[POS_CLCINI])
			Aadd(aErro,STR0013)//'Inconsistência na Classe de Valor de/até.'
			lRet := .F.
		Endif
	Else
		cQuery += "AND (" + CRLF
		cQuery += "    (CT2_CLVLDB BETWEEN  '"
		cQuery += __aCTBA420[POS_CLCINI] + "' AND '" + __aCTBA420[POS_CLCFIM] + "') OR " + CRLF
		cQuery += "    (CT2_CLVLCR BETWEEN '"
		cQuery += __aCTBA420[POS_CLCINI] + "' AND '" + __aCTBA420[POS_CLCFIM] + "') " + CRLF
		cQuery += ") " + CRLF
	Endif

	// Filtro tipo de saldo vazio.
	If Empty(__aCTBA420[POS_TIPSLD])
		Aadd(aErro,STR0014) // 'Tipo de Saldo vazio.'
		lRet := .F.
	Else
		cQuery += "AND CT2_TPSALD = '" + __aCTBA420[POS_TIPSLD] + "' " + CRLF
	Endif

	// Filtro de entidades contábeis (de 5 a 9).
	For nX := 1 to Len(aEntidades)
		If aEntidades[nX][1]
			If Empty(aEntidades[nX][5])
				If !Empty(aEntidades[nX][4])
					Aadd(aErro, STR0015 + " " + StrZero(nX + 4, 2) + '.') // 'Inconsistência na Entidade contábil'
					lRet := .F.
					Exit
				Endif
			Else
				cQuery += "AND (" + CRLF
				cQuery += "    (CT2_EC" + StrZero(nX + 4, 2) + "DB BETWEEN  '"
				cQuery += aEntidades[nX][4] + "' AND '" + aEntidades[nX][5] + "') OR " + CRLF
				cQuery += "    (CT2_EC" + StrZero(nX + 4, 2) + "CR BETWEEN  '"
				cQuery += aEntidades[nX][4] + "' AND '" + aEntidades[nX][5] + "') " + CRLF
				cQuery += ") " + CRLF
			Endif
		Else
			Exit
		Endif
	Next nX

	If lCTB420QRY
		cQuery += ExecBlock("CTB420QRY",.F.,.F.) + CRLF
	EndIf
Endif

If !lRet
	cErro := STR0017 + " "
	For nX := 1 to Len(aErro)
		cErro += CRLF + aErro[nX]
	Next
	cErro += CRLF + STR0018//'Verifique as ocorrências e tente novamente.'
	Help(,,'CTB420IN',,cErro,1,0)
Else
	cAlias := MPSysOpenQuery(ChangeQuery(cQuery))
	lRet := Ctb420Txt(cAlias, __aCTBA420[POS_TIPEXP], __aCTBA420[POS_ARQUIV], aEntidades)
	(cAlias)->(dbCloseArea())
Endif

RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Ctb420Hist(cFilCT2,dData,cLote,cSbLote,cDoc,cSeqLan,cTpSaldo,cEmpOri,cFilOri,cMoeda,cSeqHist)
Funcao que agrupa o historico dos lançamentos da tabela CT2

@param cFilCT2  Filial
@param dData  Data do lançamento contabil
@param cLote  Lote do lançamento
@param cSbLote  Sub Lote do lançamento
@param cDoc  Numero do documento do lançamento contábil
@param cSeqLan  Sequencia do lançamento
@param cTpSaldo Tipo do lancamento contábil
@param cEmpOri Empresa original do lançamento
@param cFilOri Filial original do lançamento
@param cMoeda Moeda do lançamento contábil
@param cSeqHist Sequencia do histórico do lançamento contábil
@return cHist Retorna o histórico completo do lançamento contábil

@author Jandir Deodato
@since 03/01/2013
@version MP11.80
/*/
//-------------------------------------------------------------------
Function Ctb420Hist(cFilCT2,dData,cLote,cSbLote,cDoc,cSeqLan,cTpSaldo,cEmpOri,cFilOri,cMoeda,cSeqHist)
Local aArea:=GetArea()
Local aAreaCT2:={}
Local cHist:=''
Default cFilCT2:=CriaVar("CT2_FILIAL")
Default cEmpOri:=CriaVar("CT2_EMPORI")
Default cFilOri:=CriaVar("CT2_FILORI")
Default cMoeda:="01"

dbSelectArea("CT2")
aAreaCT2:=CT2->(GetArea())
CT2->(dbSetOrder(10))//CT2_FILIAL+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_SEQLAN+CT2_EMPORI+CT2_FILORI+CT2_MOEDLC+CT2_SEQHIS
If CT2->(dbSeek(cFilCT2+DToS(dData)+cLote+cSbLote+cDoc+cSeqLan+cEmpOri+cFilOri+cMoeda+cSeqHist))
	cHist:=RTrim(CT2->CT2_HIST)
	If CT2->CT2_MOEDLC=="01" //somente o histórico da moeda 01 e concatenado
		CT2->(DbSkip())
		While CT2->(!EOF()) .and. cFilCT2==CT2->CT2_FILIAL .and. dData == CT2->CT2_DATA .AND. cLote == CT2->CT2_LOTE .And. cSbLote == CT2->CT2_SBLOTE;
				.and. cDoc==CT2->CT2_DOC .and. cTpSaldo==CT2->CT2_TPSALD .and. cFilOri==CT2->CT2_FILORI .and. cEmpOri==CT2->CT2_EMPORI .and. CT2->CT2_DC=="4"
			cHist+=" " + RTrim(CT2->CT2_HIST)
			CT2->(DbSkip())
		Enddo
	Endif
Endif

RestArea(aAreaCT2)
RestArea(aArea)
Return cHist

//-------------------------------------------------------------------
/*/{Protheus.doc} CTB420Txt
Funcao de geracao do arquivo txt para exportacao

@param cAlias Alias que sera utilizado para a exportacao txt
@param nOpc  Opcao de geracao - 1 - Movimentos contabeis, 2 - Saldos contabeis
@param cFileTxt - diretorio do arquivo Txt que sera gravado
@param aEntidades - Array com as entidades contabeis
@param lGerPlan, Se é exportação de saldo com visão gerencial
@param cFilSaldo, Filial do saldo contábil para exibir no arquivo de exportação com visão gerencial
@return lRet boleano Determina se a operacao foi realizada com sucesso

@author Jandir Deodato
@since 03/01/2013
@version MP11.80
/*/
//-------------------------------------------------------------------
Function CTB420Txt(cAlias,nOpc,cFilePath,aEntidades,lGerPlan, cFilSaldo)

Local lRet       := .T.
Local aArea      := GetArea()
Local cLinha     := ''
Local cHist      := ''
Local cFilCT2    := ''
Local cDC        := ''
Local dData
Local dDtHistIn
Local dDtHistFi
Local cLote      := ''
Local cSbLote    := ''
Local cDoc       := ''
Local cSeqLan    := ''
Local cSeqHist   := ''
Local cEmpOri    := ''
Local cFileTxt   := ''
Local cMoeda     := ''
Local cTpSaldo   := ''
Local lPDobrada  := .F. // Verifica se é partida dobrada e o lançamento deve ser gerado duas vezes
Local nHandle    := -1
local lCubo      := CTBisCube()
Local cSeparador := If(IsSrvUnix(), "/", "\")
Local lTemSaldo  := .F.
Local lCTB420TRS := ExistBlock("CTB420TRS")
Local lSldZerado := .T.
Local aStruct    := {}
Local xValue
Local nX

Default nOpc      := 1
Default lGerPlan  := .F.
Default cFilSaldo := ""

If Select(cAlias) > 0
	lSldZerado := (__aCTBA420[POS_SLDZER] == 1)

	If Right(cFilePath, 1) == cSeparador
		cFilePath := left(cFilePath, len(cFilePath) - 1)
	EndIf
	nX := AT(cSeparador, cFilePath) //caso venha diretorio arquivo, tento gravar o diretorio
	cFileTxt := cFilePath
	If nX > 0
		While nX > 0
			cFileTxt := SubStr(cFileTxt,nX+1)
			nX:=AT(cSeparador,cFileTxt)
		Enddo
		cFilePath := SubStr(cFilePath, 1, (len(cFilePath) - Len(cFileTxt)) - 1)
		If !ExistDir(cFilePath)
			If MakeDir(cFilePath) == 0
				cFileTxt := cFilePath + cSeparador + cFileTxt
			Else
				Help(,,'CTB420ERRDIR',,STR0020 + STR(FERROR()),1,0)//"O Arquivo não foi criado:"
				lRet := .F.
			Endif
		Else
			cFileTxt:=cFilePath+cSeparador+cFileTxt
		EndIf
	Endif
	If lRet
		nHandle := FCreate(cFileTxt)
		If nHandle > 0
			If (cAlias)->(!EOF())
				aStruct := CTB420X3(.T., nOpc, lGerPlan, lCubo, cFilSaldo)

				If nOpc == 2 // Saldos - chumbando historico.
					dDtHistIn := IIf(Empty(__aCTBA420[POS_DATINI]), FirstDay(dDatabase), __aCTBA420[POS_DATINI])
					dDtHistFi := IIf(Empty(__aCTBA420[POS_DATFIM]), LastDay(dDatabase),  __aCTBA420[POS_DATFIM])
					If lGerPlan
						cHist := STR0023 + " " + StrZero(Day(dDtHistIn),2) + '/' + StrZero(Month(dDtHistIn),2) + '/' + cValToChar(Year(dDtHistIn)) + " " //"Saldo do período de"
						cHist += STR0024 + " " + StrZero(Day(dDtHistFi),2) + '/' + StrZero(Month(dDtHistFi),2) + '/' + cValToChar(Year(dDtHistFi))//'até'
					Else
						cHist += STR0033 + " " + StrZero(Day(dDtHistFi),2) + '/' + StrZero(Month(dDtHistFi),2) + '/' + cValToChar(Year(dDtHistFi))//'Saldo do período até'
					Endif
					cHist := Padr(cHist, 250)
				Endif

				While (cAlias)->(!EOF())
				    If lCTB420TRS
						ExecBlock("CTB420TRS", .F., .F., {(cAlias)->R_E_C_N_O_})
					EndIf

					If nOpc == 1 // Movimentos contábeis.
						If (cAlias)->CT2_DC == "3"
							cDC := If(!lPDobrada, "DB", "CR")
						ElseIf (cAlias)->CT2_DC == "1"
							cDC := "DB"
						Else
							cDC := "CR"
						Endif
						If !lPDobrada
							cHist := (cAlias)->(Ctb420Hist(FILIAL, stod(DATA), LOTE, SBLOTE, DOC, CT2_SEQLAN, TPSALDO, CT2_EMPORI, CT2_FILORI, MOEDA, CT2_SEQHIS))
						Endif
					Else
						If lGerPlan
							If (cAlias)->SALDOATU <= 0
								cDC := "DB"
							Else
								cDC := "CR"
							Endif
						Else
							If (cAlias)->ATUSLD <= 0
								cDC := "DB"
							Else
								cDC := "CR"
							Endif
						Endif
					Endif

					// Retorna a estrutura do arquivo a ser gerado.
					cLinha := ""
					For nX := 1 to len(aStruct)
						xValue := Eval(aStruct[nX, 1], cAlias, cDC, cHist)
						If aStruct[nX, 4] = "C"
							If Len(aStruct[nX]) >= 7
								xValue := Transform(xValue, aStruct[nX, 7] )
							EndIf
							cLinha += PadR(xValue, aStruct[nX, 5])
						ElseIf aStruct[nX, 4] = "N"
							If Len(aStruct[nX]) >= 7
								cLinha += PadL(Transform(xValue, aStruct[nX, 7] ), aStruct[nX, 5])
							Else
								cLinha += Str(xValue, aStruct[nX, 5], aStruct[nX, 6])
							EndIf
						ElseIf aStruct[nX, 4] = "D"
							// Formato DD/MM/AAAA.
							cLinha += StrZero(Day(xValue), 2) + '/' + StrZero(Month(xValue), 2) + '/' + Str(Year(xValue), 4)
						Endif
					Next nX

					lTemSaldo := .T.
					FWrite(nHandle, cLinha + CRLF)

					If nOpc == 1 // Movimentos contábeis.
						If AllTrim((cAlias)->CT2_DC) == "3" // É partida dobrada.
							If lPDobrada // Já passou uma vez, pode mudar o registro.
								lPDobrada := .F.
								(cAlias)->(dbSkip())
							Else // Ainda não passou a perna de crédito. Deve passar novamente.
								lPDobrada := .T.
							Endif
						Else
							(cAlias)->(dbSkip())
						Endif
					Else
						(cAlias)->(dbSkip())
					Endif
				EndDo
				Fclose(nHandle)
			Else
				Help(,,'CTB420TXT1',,STR0019,1,0)//"Não foram encontrados registros com os parâmetros informados."
				lRet := .F.
				Fclose(nHandle)
			Endif
		Else
			Help(,,'CTB420ERRTXT',,STR0020 + STR(FERROR()),1,0)//"O Arquivo não foi criado:"
			lRet := .F.
		Endif
	Endif
Else
	Help(,,'CTB420TXT2',,STR0021,1,0)//"Problemas na abertura da tabela de exportação Txt."
	lRet := .F.
Endif

If !lTemSaldo .AND. lGerPlan .AND. nOpc==2
	Help(,,'CTB420TXT3',,OemToAnsi(STR0040),1,0) //'O saldo das contas informadas está zerado ou não existe.'
	lRet := .F.
Endif

RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CTB420CarE(aEntidades)
Verifica se as entidades contábeis existem no sistema

@param aEntidades Array contendo um campo para boleano se a entidade existe
@return Nil

@author Jandir Deodato
@since 03/01/2013
@version MP11.80
/*/
//-------------------------------------------------------------------
Static Function CTB420CarE(aEntidades)

Local aArea    := {}
Local aAreaCT2 := {}

If len(aEntidades) <> 5
	aArea    := GetArea()
	aAreaCT2 := CT2->(GetArea())

	aEntidades := {}
	aAdd(aEntidades, {CT2->(FieldPos("CT2_EC05DB") > 0 .AND. FieldPos("CT2_EC05CR") > 0 ) , 'Ent Cont 5 de:', 'Ent Cont 5 até:', '', ''})
	aAdd(aEntidades, {CT2->(FieldPos("CT2_EC06DB") > 0 .AND. FieldPos("CT2_EC06CR") > 0 ) , 'Ent Cont 6 de:', 'Ent Cont 6 até:', '', ''})
	aAdd(aEntidades, {CT2->(FieldPos("CT2_EC07DB") > 0 .AND. FieldPos("CT2_EC07CR") > 0 ) , 'Ent Cont 7 de:', 'Ent Cont 7 até:', '', ''})
	aAdd(aEntidades, {CT2->(FieldPos("CT2_EC08DB") > 0 .AND. FieldPos("CT2_EC08CR") > 0 ) , 'Ent Cont 8 de:', 'Ent Cont 8 até:', '', ''})
	aAdd(aEntidades, {CT2->(FieldPos("CT2_EC09DB") > 0 .AND. FieldPos("CT2_EC09CR") > 0 ) , 'Ent Cont 9 de:', 'Ent Cont 9 até:', '', ''})

	RestArea(aAreaCT2)
	RestArea(aArea)
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Ctb420Sald
Funcao de processamento das busca a partir dos dados do pergunte (Exportacao de saldos contabeis).

@author Jandir Deodato
@since 03/01/2013
@version MP11.80
@param lGerPlan, Se é exportação de saldo com Visão Gerencial
/*/
//-------------------------------------------------------------------
Function Ctb420Sald(lGerPlan, aSelFil)
Local cAlias := ""
Local aRet:={}
Local lRet:=.T.
Local lCubo:= CTBisCube()
Local cFilSaldo := ""

//Variáveis para a função CTGerplan
//_________________________________
Local oMeter
Local oText
Local oDlg
Local lEnd
Local cArqTmp := ""
Local aSetOfBook := {}
Local lSldZerado := .T.
Default lGerPlan := .F.
Default aSelFil := {}

//Verifica se é exportação com visão gerencial
If lGerPlan

	aSetOfBook := CTBSetOf(__aCTBA420[POS_CFGLIV])

	lSldZerado := (__aCTBA420[POS_SLDZER] == 1)
	CTGerPlan(	oMeter, oText, oDlg, @lEnd, @cArqTmp,;
				__aCTBA420[POS_DATINI],__aCTBA420[POS_DATFIM],"","",__aCTBA420[POS_CNTINI],__aCTBA420[POS_ITCFIM],;
				__aCTBA420[POS_CCINI],__aCTBA420[POS_CCFIM],__aCTBA420[POS_ITCINI],__aCTBA420[POS_ITCFIM],;
				__aCTBA420[POS_CLCINI],__aCTBA420[POS_CLCFIM], "01",;
				__aCTBA420[POS_TIPSLD],aSetOfBook,Space(2),Space(20),Repl("Z", 20),Space(30);
				,,,,,,,,lSldZerado,,,,,,,,,,,,,,,,,,,,,,.F.,.F.,.F.,"01",,aSelFil)

	//Se for saldo de uma filial especifica, considera a filial informada no arquivo de exportação
	If Len(aSelFil) = 1
		cFilSaldo := aSelFil[1]
	Else
		cFilSaldo := ""
	Endif

	cAlias:="cArqTmp"
	lRet:=Ctb420Txt(cAlias,__aCTBA420[POS_TIPEXP],__aCTBA420[POS_ARQUIV], aEntidades, .T., cFilSaldo)
	(cAlias)->(dbCloseArea())

Else

	If lCubo // se utilizar cubo contábil, os saldos serão gerados pela CVX
		aRet:=C420GetCub()
	Else//caso nao use cubo e nao use as entidades contabeis adicionais, o saldo e resgatado das tabelas do padrao
		aRet:=C420GetSld()
	Endif

	lRet:=aRet[1]
	If lRet
		cAlias:=aRet[2]
		lRet:=Ctb420Txt(cAlias,__aCTBA420[POS_TIPEXP],__aCTBA420[POS_ARQUIV],aEntidades)
		(cAlias)->(dbCloseArea())
	Endif

Endif
Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} C420GetSld
Devolve os saldos e movimentos das entidades contábeis (conta, centro de custo, item contábil e classe de valor)

É devolvido um arquivo temporário com os campos:
FILIAL		Filial da Conta
CONTA		Código da conta
CUSTO		Código do centro de custos
ITEM		Código do item contábil
CLVL		Código da classe de valor
ANTSLD		Saldo anterior
CRD			Crédito no período
DEB			Débito no período
MOV			Movimento no período
ATUSLD		Saldo no fim do período
MOEDA		Moeda
TPSALDO	Tipo de Saldo

@return lRet Sucesso ou não
@return cRetAlias	Nome do arquivo temporário
@author Jandir Deodato
@since 03/01/2013
@version MP11.80
/*/
//-------------------------------------------------------------------------------------
Function C420GetSld()
Local cTabCTI	:= ""
Local cTabCT4	:= ""
Local cTabCT3	:= ""
Local cTabCT7	:= ""
Local cQuery	:= ""
Local cRetAlias	:= getNextAlias()

aRet := CTB420CQ7()
If aRet[1]//caso os parametros estejam corretos, segue com as outras queries
	cTabCTI := aRet[2]
	cTabCT4 := CTB420CQ5(cTabCTI)
	cTabCT3 := CTB420CQ3(cTabCTI, cTabCT4)
	cTabCT7 := CTB420CQ1(cTabCTI, cTabCT4, cTabCT3)
Endif

If aRet[1]
	cQuery:=" SELECT FILIAL, CONTA, CUSTO, ITEM, CLVL, SUM(ATUSLD) ATUSLD, MOEDA, TPSALDO " + CRLF
	cQuery += " FROM ( " + CRLF
	cQuery += " SELECT CQ7.FILIAL, CQ7.CONTA, CQ7.CUSTO, CQ7.ITEM, CQ7.CLVL, CQ7.ANTSLD, CQ7.CRD, CQ7.DEB, CQ7.MOV, CQ7.ATUSLD, CQ7.MOEDA, CQ7.TPSALDO FROM " + cTabCTI + " CQ7" + CRLF
	cQuery += " UNION " + CRLF
	cQuery += " SELECT CQ5.FILIAL, CQ5.CONTA, CQ5.CUSTO, CQ5.ITEM, CQ5.CLVL, CQ5.ANTSLD, CQ5.CRD, CQ5.DEB, CQ5.MOV, CQ5.ATUSLD, CQ5.MOEDA, CQ5.TPSALDO FROM " + cTabCT4 + " CQ5" + CRLF
	cQuery += " UNION " + CRLF
	cQuery += " SELECT CQ3.FILIAL, CQ3.CONTA, CQ3.CUSTO, CQ3.ITEM, CQ3.CLVL, CQ3.ANTSLD, CQ3.CRD, CQ3.DEB, CQ3.MOV, CQ3.ATUSLD, CQ3.MOEDA, CQ3.TPSALDO FROM " + cTabCT3 + " CQ3" + CRLF
	cQuery += " UNION " + CRLF
	cQuery += " SELECT CQ1.FILIAL, CQ1.CONTA, CQ1.CUSTO, CQ1.ITEM, CQ1.CLVL, CQ1.ANTSLD, CQ1.CRD, CQ1.DEB, CQ1.MOV, CQ1.ATUSLD, CQ1.MOEDA, CQ1.TPSALDO FROM " + cTabCT7 + " CQ1" + CRLF
	cQuery += " ) TMP WHERE " + CRLF

	// Filtro da conta contábil.
	If !Empty(__aCTBA420[POS_CNTFIM])
		cQuery += " CONTA >= '" + __aCTBA420[POS_CNTINI] + "' " + CRLF
		cQuery += "AND CONTA <= '" + __aCTBA420[POS_CNTFIM] + "' AND " + CRLF
	Endif

	// Filtro do centro de custo.
	If !Empty(__aCTBA420[POS_CCFIM])
		cQuery += " CUSTO >= '" + __aCTBA420[POS_CCINI] + "' " + CRLF
		cQuery += "AND CUSTO <= '" + __aCTBA420[POS_CCFIM] + "' AND " + CRLF
	Endif

	// Filtro do item contábil
	If !Empty(__aCTBA420[POS_ITCFIM])
		cQuery += " ITEM >= '" + __aCTBA420[POS_ITCINI] + "' " + CRLF
		cQuery += "AND ITEM <= '" + __aCTBA420[POS_ITCFIM] + "' AND " + CRLF
	Endif

	// Filtro da classe de valor
	If !Empty(__aCTBA420[POS_CLCFIM])
		cQuery += " CLVL >= '" + __aCTBA420[POS_CLCINI] + "' " + CRLF
		cQuery += "AND CLVL <= '" + __aCTBA420[POS_CLCFIM] + "' AND " + CRLF
	Endif

	cQuery += " TPSALDO = '" + __aCTBA420[POS_TIPSLD] + "' " + CRLF
	cQuery += " GROUP BY FILIAL, CONTA, CUSTO, ITEM, CLVL, MOEDA, TPSALDO "

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cRetAlias, .T., .F.)

	dbSelectArea(cRetAlias)

	If InTransact()//vindo do EAI, transacao ligada, é necessaria a gravacao/delecao do top por job
		StartJob( "CTBA420Cop" , GetEnvServer() , .T. , cEmpAnt, cFilAnt,.T.,{cTabCTI,cTabCT4,cTabCT3,cTabCT7},,.T.)
	Else
		CTBA420Cop(,,.F.,{cTabCTI,cTabCT4,cTabCT3,cTabCT7},,.T.)
	Endif
Endif

Return {aRet[1],cRetAlias}

/*/{Protheus.doc} CTB420CQ7
Devolve os saldos e movimentos das classes de valor

É devolvido um arquivo temporário com os campos:
FILIAL		Filial da Conta
MOEDA 		Moeda do lançamento
TPSALDO		Tipo do Saldo
CONTA		Código da conta
CUSTO		Código do centro de custo
ITEM		Código do item contábil
CLVL		Código da classe de valor
ANTSLD		Saldo anterior
CRD			Crédito no período
DEB			Débito no período
MOV			Movimento no período
ATUSLD		Saldo no fim do período
MOEDA 		Moeda do Movimento

@return cTabCTI	Nome do arquivo temporário
@author Jandir Deodato
@since 03/01/2013
@version MP11.80
/*/
Function CTB420CQ7()
Local cQuery	:= ""
Local cTabCTI	:= CriaTrab(,.F.)
Local dDataIni	:= Iif(!Empty(__aCTBA420[POS_DATINI]),__aCTBA420[POS_DATINI],FirstDay(dDataBase))
Local dDataFim	:= Iif(!Empty(__aCTBA420[POS_DATFIM]),__aCTBA420[POS_DATFIM],LastDay(dDataBase))
Local lRet:=.T.
Local nX:=0
Local aErro:={}
Local cErro:=''

cQuery := " SELECT	SQ7.CONTA," + CRLF
cQuery += "			SQ7.CUSTO," + CRLF
cQuery += "			SQ7.ITEM," + CRLF
cQuery += "			SQ7.CLVL," + CRLF
cQuery += "			SQ7.FILIAL," + CRLF
cQuery += "			SQ7.MOEDA," + CRLF
cQuery += "			SQ7.TPSALDO," + CRLF
cQuery += "			COALESCE(ANTCRD - ANTDEB, 0)  ANTSLD," + CRLF
cQuery += "			COALESCE(ATUCRD,0) - COALESCE(ANTCRD, 0)  CRD," + CRLF
cQuery += "			COALESCE(ATUDEB,0) - COALESCE(ANTDEB, 0)  DEB," + CRLF
cQuery += "			COALESCE(ATUCRD,0) - COALESCE(ATUDEB,0) - COALESCE(ANTCRD - ANTDEB, 0)  MOV," + CRLF
cQuery += "			COALESCE(ATUCRD,0) - COALESCE(ATUDEB,0)  ATUSLD " + CRLF

cQuery += " FROM ( " + CRLF
cQuery += "	SELECT	CQ7.CQ7_CONTA  CONTA," + CRLF
cQuery += "			CQ7.CQ7_CCUSTO  CUSTO," + CRLF
cQuery += "			CQ7.CQ7_ITEM  ITEM," + CRLF
cQuery += "			CQ7.CQ7_CLVL  CLVL," + CRLF
cQuery += "			CQ7.CQ7_FILIAL FILIAL," + CRLF
cQuery += " 			CQ7.CQ7_MOEDA  MOEDA,"+ CRLF
cQuery += "			CQ7.CQ7_TPSALD  TPSALDO," + CRLF
cQuery += "			SUM(CQ7.CQ7_DEBITO)  ANTDEB," + CRLF
cQuery += "			SUM(CQ7.CQ7_CREDIT)  ANTCRD," + CRLF
cQuery += "			0 ATUDEB,"
cQuery += "			0 ATUCRD "
cQuery += "	FROM " + retSqlName("CQ7") + " CQ7					" + CRLF
cQuery += "	WHERE	" + CRLF
If Empty(__aCTBA420[POS_TIPSLD])
	Aadd(aErro,STR0014)//'Tipo de Saldo vazio.'
	lRet := .F.
Else
	cQuery += " CQ7.CQ7_TPSALD ='"+__aCTBA420[POS_TIPSLD]+"' AND " + CRLF
Endif

If Empty(__aCTBA420[POS_FILFIM])//filtro de filial
	If !Empty(__aCTBA420[POS_FILINI])
		Aadd(aErro,STR0008)//'Inconsistência na Filial de/até.'
		lRet := .F.
	Endif
Else
	cQuery += "			CQ7.CQ7_FILIAL >= '" + xFilial("CQ7",__aCTBA420[POS_FILINI]) + "' and" + CRLF
	cQuery += "			CQ7.CQ7_FILIAL <= '" + xFilial("CQ7",__aCTBA420[POS_FILFIM]) + "' and" + CRLF
Endif
If Empty(__aCTBA420[POS_CNTFIM])//filtro da conta contabil
	If !Empty(__aCTBA420[POS_CNTINI])
		Aadd(aErro,STR0010)//'Inconsistência na Conta contábil de/até.'
		lRet := .F.
	Endif
Endif
//--
If Empty(__aCTBA420[POS_CCFIM])//filtro do centro de custo
	If !Empty(__aCTBA420[POS_CCINI])
		Aadd(aErro,STR0011)//'Inconsistência no Centro de Custo de/até.'
		lRet := .F.
	Endif
Endif
//---
If Empty(__aCTBA420[POS_ITCFIM])//filtro do Item Contabil
	If !Empty(__aCTBA420[POS_ITCINI])
		Aadd(aErro,STR0012)//'Inconsistência no Item Contábil de/até.'
		lRet := .F.
	Endif
Endif
//-----
If Empty(__aCTBA420[POS_CLCFIM])//filtro da Classe de Valor
	If !Empty(__aCTBA420[POS_CLCINI])
		Aadd(aErro,STR0013)//'Inconsistência na Classe de Valor de/até.'
		lRet := .F.
	Endif
Endif
//--
cQuery += "			CQ7.D_E_L_E_T_ = ' ' and" + CRLF
cQuery += "			CQ7.CQ7_DATA < (" + CRLF
cQuery += "								SELECT	MAX(CQ72.CQ7_DATA)" + CRLF
cQuery += "										FROM	" + retSqlName("CQ7") + " CQ72" + CRLF
cQuery += "										WHERE	CQ72.CQ7_CONTA = CQ7.CQ7_CONTA and" + CRLF
cQuery += "												CQ72.CQ7_CCUSTO = CQ7.CQ7_CCUSTO and" + CRLF
cQuery += "												CQ72.CQ7_ITEM = CQ7.CQ7_ITEM and" + CRLF
cQuery += "												CQ72.CQ7_CLVL = CQ7.CQ7_CLVL and" + CRLF
cQuery += "												CQ72.CQ7_TPSALD = CQ7.CQ7_TPSALD and" + CRLF
cQuery += "												CQ72.CQ7_FILIAL = CQ7.CQ7_FILIAL and" + CRLF
cQuery += "												CQ72.CQ7_MOEDA = CQ7.CQ7_MOEDA and" + CRLF
cQuery += "												CQ72.D_E_L_E_T_ = ' ' and" + CRLF
cQuery += "												CQ72.CQ7_DATA <= '" + dToS(dDataIni) + "'" + CRLF
cQuery += "							)" + CRLF
cQuery += " GROUP BY CQ7.CQ7_CONTA, " + CRLF
cQuery += "			CQ7.CQ7_CCUSTO," + CRLF
cQuery += "			CQ7.CQ7_ITEM  ," + CRLF
cQuery += "			CQ7.CQ7_FILIAL," + CRLF
cQuery += "			CQ7.CQ7_CLVL  ," + CRLF
cQuery += "			CQ7.CQ7_TPSALD," + CRLF
cQuery += "			CQ7.CQ7_MOEDA " + CRLF

cQuery += " UNION ALL "

cQuery += "	SELECT	CQ7.CQ7_CONTA  CONTA," + CRLF
cQuery += "			CQ7.CQ7_CCUSTO  CUSTO," + CRLF
cQuery += "			CQ7.CQ7_ITEM  ITEM," + CRLF
cQuery += "			CQ7.CQ7_CLVL  CLVL," + CRLF
cQuery += "			CQ7.CQ7_FILIAL FILIAL," + CRLF
cQuery += " 			CQ7.CQ7_MOEDA  MOEDA,"+ CRLF
cQuery += "			CQ7.CQ7_TPSALD  TPSALDO," + CRLF
cQuery += "			0  ANTDEB," + CRLF
cQuery += "			0  ANTCRD," + CRLF
cQuery += "			SUM(CQ7.CQ7_DEBITO)  ATUDEB,"+ CRLF
cQuery += "			SUM(CQ7.CQ7_CREDIT)  ATUCRD"+ CRLF
cQuery += "	FROM " + retSqlName("CQ7") + " CQ7					" + CRLF
cQuery += "	WHERE	" + CRLF
If Empty(__aCTBA420[POS_TIPSLD])
	Aadd(aErro,STR0014)//'Tipo de Saldo vazio.'
	lRet := .F.
Else
	cQuery += " CQ7.CQ7_TPSALD ='"+__aCTBA420[POS_TIPSLD]+"' AND " + CRLF
Endif

If !Empty(__aCTBA420[POS_FILFIM])//filtro de filial
	cQuery += "			CQ7.CQ7_FILIAL >= '" + xFilial("CQ7",__aCTBA420[POS_FILINI]) + "' and" + CRLF
	cQuery += "			CQ7.CQ7_FILIAL <= '" + xFilial("CQ7",__aCTBA420[POS_FILFIM]) + "' and" + CRLF
Endif
//--
cQuery += "			CQ7.D_E_L_E_T_ = ' ' and" + CRLF
cQuery += "			CQ7.CQ7_DATA <= (" + CRLF
cQuery += "								SELECT	MAX(CQ72.CQ7_DATA)" + CRLF
cQuery += "										FROM	" + retSqlName("CQ7") + " CQ72" + CRLF
cQuery += "										WHERE	CQ72.CQ7_CONTA = CQ7.CQ7_CONTA and" + CRLF
cQuery += "												CQ72.CQ7_CCUSTO = CQ7.CQ7_CCUSTO and" + CRLF
cQuery += "												CQ72.CQ7_ITEM = CQ7.CQ7_ITEM and" + CRLF
cQuery += "												CQ72.CQ7_CLVL = CQ7.CQ7_CLVL and" + CRLF
cQuery += "												CQ72.CQ7_TPSALD = CQ7.CQ7_TPSALD and" + CRLF
cQuery += "												CQ72.CQ7_FILIAL = CQ7.CQ7_FILIAL and" + CRLF
cQuery += "												CQ72.CQ7_MOEDA = CQ7.CQ7_MOEDA and" + CRLF
cQuery += "												CQ72.D_E_L_E_T_ = ' ' and" + CRLF
cQuery += "												CQ72.CQ7_DATA <= '" + dToS(dDataFim) + "'" + CRLF
cQuery += "							)" + CRLF
cQuery += " GROUP BY CQ7.CQ7_CONTA, " + CRLF
cQuery += "			CQ7.CQ7_CCUSTO," + CRLF
cQuery += "			CQ7.CQ7_ITEM  ," + CRLF
cQuery += "			CQ7.CQ7_FILIAL," + CRLF
cQuery += "			CQ7.CQ7_CLVL  ," + CRLF
cQuery += "			CQ7.CQ7_TPSALD," + CRLF
cQuery += "			CQ7.CQ7_MOEDA " + CRLF
cQuery += " ) SQ7 "

If Empty(__aCTBA420[POS_ARQUIV])//tipo de arquivo
	Aadd(aErro,STR0016)//'Local de gravação do arquivo TXT não informado.'
	lRet := .F.
Endif
If !lRet
	cErro:=STR0017+" "
	For nX:=1 to Len(aErro)
		cErro+=CRLF+aErro[nX]
	Next
	cErro+=CRLF+STR0018//'Verifique as ocorrências e tente novamente.'
	Help(,,'CTB420CTI',,cErro,1,0)
Else
	cQuery := ChangeQuery(cQuery)
	If InTransact()//vindo pelo EAI, e necessario gravar por job
		StartJob( "CTBA420Cop" , GetEnvServer() , .T. , cEmpAnt, cFilAnt,.T.,{cTabCTI},cquery)
	Else
		CTBA420Cop(, ,.F.,{cTabCTI},cquery)
	Endif

Endif

Return {lRet,cTabCTI}

/*/{Protheus.doc} CTB420CQ5
Devolve os saldos e movimentos dos itens contábeis

É devolvido um arquivo temporário com os campos:
FILIAL		Filial
MOEDA		Moeda
TPSALDO	Tipo do Saldo
CONTA		Código da conta
CUSTO		Código do centro de custo
ITEM		Código do item contábil
CLVL		Em branco
ANTSLD		Saldo anterior
CRD			Crédito no período
DEB			Débito no período
MOV			Movimento no período
ATUSLD		Saldo no fim do período

@param cTabCTI	Arquivo temporário com os saldos das entidades contábeis até o nível de classe de valor
@return cTabCT4	Nome do arquivo temporário
@author Jandir Deodato
@since 03/01/2013
@version MP11.80
/*/
Function CTB420CQ5(cTabCTI)
local cQuery	:= ""
Local cTabCT4	:= CriaTrab(,.F.)
Local dDataIni	:= Iif(!Empty(__aCTBA420[POS_DATINI]),__aCTBA420[POS_DATINI],FirstDay(dDataBase))
Local dDataFim	:= Iif(!Empty(__aCTBA420[POS_DATFIM]),__aCTBA420[POS_DATFIM],LastDay(dDataBase))

cQuery := " SELECT	SQ5.CONTA," + CRLF
cQuery += " 			SQ5.CUSTO," + CRLF
cQuery += " 			SQ5.ITEM ," + CRLF
cQuery += "			SQ5.FILIAL," + CRLF
cQuery += "			SQ5.MOEDA," + CRLF
cQuery += "			SQ5.TPSALDO," + CRLF
cQuery += " 		'" + space( TamSX3("CTI_CLVL")[1] ) + "'  CLVL," + CRLF
cQuery += " 		COALESCE(ANTCRD - ANTDEB, 0) - COALESCE(tCTI.ANTSLD,0)  ANTSLD," + CRLF
cQuery += " 		COALESCE(ATUCRD - ANTCRD, 0) - COALESCE(tCTI.CRD,0)  CRD," + CRLF
cQuery += " 		COALESCE(ATUDEB - ANTDEB, 0) - COALESCE(tCTI.DEB,0)  DEB," + CRLF
cQuery += " 		COALESCE(ATUCRD - ATUDEB, 0) - COALESCE(ANTCRD - ANTDEB, 0) - COALESCE(tCTI.MOV,0)  MOV," + CRLF
cQuery += " 		COALESCE(ATUCRD - ATUDEB, 0) - COALESCE(tCTI.ATUSLD,0)  ATUSLD" + CRLF
cQuery += " FROM ("+ CRLF

cQuery += " SELECT CQ5.CQ5_CONTA  CONTA," + CRLF
cQuery += " 		 CQ5.CQ5_CCUSTO  CUSTO,"+ CRLF
cQuery += " 		 CQ5.CQ5_ITEM   ITEM,"+ CRLF
cQuery += " 		 CQ5.CQ5_FILIAL FILIAL,"+ CRLF
cQuery += " 		 CQ5.CQ5_MOEDA  MOEDA,"+ CRLF
cQuery += " 		 CQ5.CQ5_TPSALD  TPSALDO,"+ CRLF
cQuery += "		0 ATUCRD,"+ CRLF
cQuery += "		0 ATUDEB,"+ CRLF
cQuery += "		SUM(CQ5.CQ5_CREDIT) ANTCRD,"+ CRLF
cQuery += "		SUM(CQ5.CQ5_DEBITO) ANTDEB,"+ CRLF
cQuery += "		0 MOV,"+ CRLF
cQuery += "		0 ATUSLD"+ CRLF
cQuery += "	FROM " + retSqlName("CQ5") + " CQ5" + CRLF
cQuery += " 	WHERE	" + CRLF
//--
If !Empty(__aCTBA420[POS_TIPSLD])
	cQuery += " CQ5.CQ5_TPSALD ='"+__aCTBA420[POS_TIPSLD]+"' AND " + CRLF
EndIf

If !Empty(__aCTBA420[POS_FILFIM])//filtro de filial
	cQuery += "			CQ5.CQ5_FILIAL >= '" + xFilial("CQ5",__aCTBA420[POS_FILINI]) + "' and" + CRLF
	cQuery += "			CQ5.CQ5_FILIAL <= '" + xFilial("CQ5",__aCTBA420[POS_FILFIM]) + "' and" + CRLF
Endif

cQuery += " 			CQ5.D_E_L_E_T_ = ' ' and" + CRLF
cQuery += " 			CQ5.CQ5_DATA < (" + CRLF
cQuery += " 								SELECT	MAX(CQ52.CQ5_DATA)" + CRLF
cQuery += " 										FROM	" + retSqlName("CQ5") + " CQ52" + CRLF
cQuery += " 										WHERE	CQ52.CQ5_CONTA = CQ5.CQ5_CONTA and" + CRLF
cQuery += " 												CQ52.CQ5_CCUSTO = CQ5.CQ5_CCUSTO and" + CRLF
cQuery += " 												CQ52.CQ5_ITEM = CQ5.CQ5_ITEM and" + CRLF
cQuery += " 												CQ52.CQ5_TPSALD = CQ5.CQ5_TPSALD and" + CRLF
cQuery += " 												CQ52.CQ5_MOEDA = CQ5.CQ5_MOEDA and" + CRLF
cQuery += " 												CQ52.CQ5_FILIAL = CQ5.CQ5_FILIAL and" + CRLF
cQuery += " 												CQ52.D_E_L_E_T_ = ' ' and" + CRLF
cQuery += " 												CQ52.CQ5_DATA <= '" + dTos(dDataIni) + "'" + CRLF
cQuery += " 							)" + CRLF

cQuery += " GROUP BY CQ5.CQ5_CONTA,"+ CRLF
cQuery += " 			CQ5.CQ5_CCUSTO,"+ CRLF
cQuery += " 			CQ5.CQ5_ITEM,"+ CRLF
cQuery += " 			CQ5.CQ5_FILIAL,"+ CRLF
cQuery += " 			CQ5.CQ5_TPSALD,"+ CRLF
cQuery += "			CQ5.CQ5_MOEDA"+ CRLF

cQuery += " UNION ALL "+ CRLF

cQuery += " SELECT CQ5.CQ5_CONTA  CONTA," + CRLF
cQuery += " 		 CQ5.CQ5_CCUSTO  CUSTO,"+ CRLF
cQuery += " 		 CQ5.CQ5_ITEM   ITEM,"+ CRLF
cQuery += " 		 CQ5.CQ5_FILIAL FILIAL,"+ CRLF
cQuery += " 		 CQ5.CQ5_MOEDA  MOEDA,"+ CRLF
cQuery += " 		 CQ5.CQ5_TPSALD  TPSALDO,"+ CRLF
cQuery += "		 SUM(CQ5.CQ5_CREDIT) ATUCRD,"+ CRLF
cQuery += "		 SUM(CQ5.CQ5_DEBITO) ATUDEB,"+ CRLF
cQuery += "		0 ANTCRD,"+ CRLF
cQuery += "		0 ANTDEB,"+ CRLF
cQuery += "		0 MOV,"+ CRLF
 cQuery +="		0 ATUSLD"+ CRLF
cQuery += "	FROM " + RetSqlName("CQ5") + " CQ5" + CRLF
cQuery += " 	WHERE	" + CRLF
//--
If !Empty(__aCTBA420[POS_TIPSLD])
	cQuery += " CQ5.CQ5_TPSALD ='"+__aCTBA420[POS_TIPSLD]+"' AND " + CRLF
EndIf

If !Empty(__aCTBA420[POS_FILFIM])//filtro de filial
	cQuery += "			CQ5.CQ5_FILIAL >= '" + xFilial("CQ5",__aCTBA420[POS_FILINI]) + "' and" + CRLF
	cQuery += "			CQ5.CQ5_FILIAL <= '" + xFilial("CQ5",__aCTBA420[POS_FILFIM]) + "' and" + CRLF
Endif

cQuery += " 			CQ5.D_E_L_E_T_ = ' ' and" + CRLF
cQuery += " 			CQ5.CQ5_DATA <= (" + CRLF
cQuery += " 								SELECT	MAX(CQ52.CQ5_DATA)" + CRLF
cQuery += " 										FROM	" + retSqlName("CQ5") + " CQ52" + CRLF
cQuery += " 										WHERE	CQ52.CQ5_CONTA = CQ5.CQ5_CONTA and" + CRLF
cQuery += " 												CQ52.CQ5_CCUSTO = CQ5.CQ5_CCUSTO and" + CRLF
cQuery += " 												CQ52.CQ5_ITEM = CQ5.CQ5_ITEM and" + CRLF
cQuery += " 												CQ52.CQ5_TPSALD = CQ5.CQ5_TPSALD and" + CRLF
cQuery += " 												CQ52.CQ5_MOEDA = CQ5.CQ5_MOEDA and" + CRLF
cQuery += " 												CQ52.CQ5_FILIAL = CQ5.CQ5_FILIAL and" + CRLF
cQuery += " 												CQ52.D_E_L_E_T_ = ' ' and" + CRLF
cQuery += " 												CQ52.CQ5_DATA <= '" + dTos(dDataFim) + "'" + CRLF
cQuery += " 							)" + CRLF

cQuery += " GROUP BY CQ5.CQ5_CONTA,"+ CRLF
cQuery += " 			CQ5.CQ5_CCUSTO,"+ CRLF
cQuery += " 			CQ5.CQ5_ITEM,"+ CRLF
cQuery += " 			CQ5.CQ5_FILIAL,"+ CRLF
cQuery += " 			CQ5.CQ5_TPSALD,"+ CRLF
cQuery += " 			CQ5.CQ5_MOEDA"+ CRLF

cQuery += " ) SQ5 " + CRLF

cQuery += " LEFT JOIN (" + CRLF
cQuery += " 	SELECT	TMPAUX.CONTA," + CRLF
cQuery += " 			TMPAUX.CUSTO," + CRLF
cQuery += " 			TMPAUX.ITEM," + CRLF
cQuery += " 			TMPAUX.MOEDA," + CRLF
cQuery += " 			TMPAUX.FILIAL," + CRLF
cQuery += " 			TMPAUX.TPSALDO," + CRLF
cQuery += " 			SUM(TMPAUX.ANTSLD)  ANTSLD," + CRLF
cQuery += " 			SUM(TMPAUX.CRD)  CRD," + CRLF
cQuery += " 			SUM(TMPAUX.DEB)  DEB," + CRLF
cQuery += " 			SUM(TMPAUX.MOV)  MOV," + CRLF
cQuery += " 			SUM(TMPAUX.ATUSLD)  ATUSLD" + CRLF
cQuery += " 	FROM " + cTabCTI + " TMPAUX" + CRLF
cQuery += " 	GROUP BY	TMPAUX.FILIAL," + CRLF
cQuery += " 				TMPAUX.CONTA," + CRLF
cQuery += " 				TMPAUX.CUSTO," + CRLF
cQuery += " 				TMPAUX.ITEM," + CRLF
cQuery += " 				TMPAUX.MOEDA," + CRLF
cQuery += " 				TMPAUX.TPSALDO" + CRLF
cQuery += " ) tCTI on tCTI.CONTA = SQ5.CONTA and" + CRLF
cQuery += " 			tCTI.CUSTO = SQ5.CUSTO and" + CRLF
cQuery += " 			tCTI.MOEDA = SQ5.MOEDA and" + CRLF
cQuery += " 			tCTI.FILIAL = SQ5.FILIAL and" + CRLF
cQuery += " 			tCTI.MOEDA = SQ5.MOEDA and" + CRLF
cQuery += " 			tCTI.TPSALDO = SQ5.TPSALDO " + CRLF

cQuery += " ORDER BY SQ5.CONTA, SQ5.CUSTO, SQ5.ITEM "
//--
cQuery := ChangeQuery(cQuery)

If InTransact()//vindo do EAI, é preciso gravar via job
	StartJob( "CTBA420Cop" , GetEnvServer() , .T. , cEmpAnt, cFilAnt,.T.,{cTabCT4},cquery)
Else
	CTBA420Cop(, ,.F.,{cTabCT4},cquery)
EndIf

Return cTabCT4

/*/{Protheus.doc} CTB420CQ3
Devolve os saldos e movimentos dos centros de custos

É devolvido um arquivo temporário com os campos:
FILIAL		Filial
MOEDA		Moeda
TPSALDO	Tipo de Saldo
CONTA		Código da conta
CUSTO		Código do centro de custo
ITEM		Em branco
CLVL		Em branco
ANTSLD		Saldo anterior
CRD			Crédito no período
DEB			Débito no período
MOV			Movimento no período
ATUSLD		Saldo no fim do período

@param cTabCTI Arquivo temporário  com os saldos das entidades contábeis até o nível de classe de valor
@param cTabCT4	 Arquivo temporário  com os saldos das entidades contábeis até o nível de item cotábil
@return cTabCT3 Nome do arquivo temporário
@author Jandir Deodato
@since 03/01/2013
@version MP11.80
/*/
Function CTB420CQ3(cTabCTI, cTabCT4)
Local cQuery	:= ""
Local cTabCT3	:= CriaTrab(,.F.)
Local dDataIni	:= Iif(!Empty(__aCTBA420[POS_DATINI]),__aCTBA420[POS_DATINI],FirstDay(dDataBase))
Local dDataFim	:= Iif(!Empty(__aCTBA420[POS_DATFIM]),__aCTBA420[POS_DATFIM],LastDay(dDataBase))

cQuery := " SELECT SQ3.CONTA  CONTA," + CRLF
cQuery += " 		 SQ3.CUSTO  CUSTO," + CRLF
cQuery += " 		'" + space( TamSX3("CTI_ITEM")[1] ) + "'  ITEM," + CRLF
cQuery += " 		'" + space( TamSX3("CTI_CLVL")[1] ) + "'  CLVL," + CRLF
cQuery += "		SQ3.FILIAL  FILIAL," + CRLF
cQuery += "		SQ3.MOEDA  MOEDA," + CRLF
cQuery += "		SQ3.TPSALDO  TPSALDO," + CRLF
cQuery += " 		COALESCE(ANTCRD - ANTDEB, 0) - COALESCE(tCT4.ANTSLD,0) - COALESCE(tCTI.ANTSLD,0)  ANTSLD," + CRLF
cQuery += " 		COALESCE(ATUCRD,0) - COALESCE(ANTCRD, 0) - COALESCE(tCT4.CRD,0) - COALESCE(tCTI.CRD,0)  CRD," + CRLF
cQuery += " 		COALESCE(ATUDEB,0) - COALESCE(ANTDEB, 0) - COALESCE(tCT4.DEB,0) - COALESCE(tCTI.DEB,0)  DEB," + CRLF
cQuery += " 		COALESCE(ATUCRD,0) - COALESCE(ATUDEB,0) - COALESCE(ANTCRD - ANTDEB, 0) - COALESCE(tCT4.MOV,0) - COALESCE(tCTI.MOV,0)  MOV," + CRLF
cQuery += " 		COALESCE(ATUCRD,0) - COALESCE(ATUDEB,0) - COALESCE(tCT4.ATUSLD,0) - COALESCE(tCTI.ATUSLD,0)  ATUSLD" + CRLF

cQuery += " FROM ( "+ CRLF

cQuery += " SELECT CQ3.CQ3_CONTA  CONTA, "+ CRLF
cQuery += " CQ3.CQ3_CCUSTO  CUSTO, "+ CRLF
cQuery += " CQ3.CQ3_FILIAL  FILIAL, "+ CRLF
cQuery += " CQ3.CQ3_TPSALD  TPSALDO,"+ CRLF
cQuery += " CQ3.CQ3_MOEDA  MOEDA, "+ CRLF
cQuery += " 0 ATUCRD,"+ CRLF
cQuery += " 0 ATUDEB,"+ CRLF
cQuery += " SUM(CQ3.CQ3_CREDIT)  ANTCRD,"+ CRLF
cQuery += " SUM(CQ3.CQ3_DEBITO)  ANTDEB,"+ CRLF
cQuery += " 0 MOV,"+ CRLF
cQuery += " 0 ATUSLD	"+ CRLF
cQuery += " FROM " + RetSqlName("CQ3") + " CQ3				" + CRLF
cQuery += " 	WHERE	" + CRLF
If !Empty(__aCTBA420[POS_TIPSLD])
	cQuery += " CQ3.CQ3_TPSALD ='"+__aCTBA420[POS_TIPSLD]+"' AND " + CRLF
Endif
If !Empty(__aCTBA420[POS_FILFIM])//filtro de filial
	cQuery += "			CQ3.CQ3_FILIAL >= '" + xFilial("CQ3",__aCTBA420[POS_FILINI]) + "' and" + CRLF
	cQuery += "			CQ3.CQ3_FILIAL <= '" + xFilial("CQ3",__aCTBA420[POS_FILFIM]) + "' and" + CRLF
Endif

// REALIZA BUSCA NO SALDO ANTERIOR

cQuery += " 			CQ3.D_E_L_E_T_ = ' ' and" + CRLF
cQuery += " 			CQ3.CQ3_DATA < (" + CRLF
cQuery += " 								SELECT	MAX(CQ32.CQ3_DATA)" + CRLF
cQuery += " 										FROM	" + retSqlName("CQ3") + " CQ32" + CRLF
cQuery += " 										WHERE	CQ32.CQ3_CONTA = CQ3.CQ3_CONTA and" + CRLF
cQuery += " 												CQ32.CQ3_CCUSTO = CQ3.CQ3_CCUSTO and" + CRLF
cQuery += " 												CQ32.CQ3_TPSALD = CQ3.CQ3_TPSALD and" + CRLF
cQuery += " 												CQ32.CQ3_MOEDA = CQ3.CQ3_MOEDA and" + CRLF
cQuery += " 												CQ32.CQ3_FILIAL = CQ3.CQ3_FILIAL and" + CRLF
cQuery += " 												CQ32.D_E_L_E_T_ = ' ' and" + CRLF
cQuery += " 												CQ32.CQ3_DATA <= '" + dTos(dDataIni) + "')" + CRLF
cQuery += " GROUP BY CQ3.CQ3_CONTA,"+ CRLF
cQuery += " CQ3.CQ3_CCUSTO,"+ CRLF
cQuery += " CQ3.CQ3_FILIAL,"+ CRLF
cQuery += " CQ3.CQ3_TPSALD,"+ CRLF
cQuery += " CQ3.CQ3_MOEDA"+ CRLF

cQuery += " UNION ALL "+ CRLF


cQuery += " SELECT CQ3.CQ3_CONTA  CONTA, "+ CRLF
cQuery += " CQ3.CQ3_CCUSTO  CUSTO, "+ CRLF
cQuery += " CQ3.CQ3_FILIAL  FILIAL, "+ CRLF
cQuery += " CQ3.CQ3_TPSALD  TPSALDO,"+ CRLF
cQuery += " CQ3.CQ3_MOEDA  MOEDA, "+ CRLF
cQuery += " SUM(CQ3.CQ3_CREDIT) ATUCRD,"+ CRLF
cQuery += " SUM(CQ3.CQ3_DEBITO) ATUDEB,"+ CRLF
cQuery += " 0 ANTCRD,"+ CRLF
cQuery += " 0 ANTDEB,"+ CRLF
cQuery += " 0 MOV,"+ CRLF
cQuery += " 0 ATUSLD	"+ CRLF
cQuery += " FROM " + RetSqlName("CQ3") + " CQ3				" + CRLF
cQuery += " 	WHERE	" + CRLF
If !Empty(__aCTBA420[POS_TIPSLD])
	cQuery += " CQ3.CQ3_TPSALD ='"+__aCTBA420[POS_TIPSLD]+"' AND " + CRLF
Endif
If !Empty(__aCTBA420[POS_FILFIM])//filtro de filial
	cQuery += "			CQ3.CQ3_FILIAL >= '" + xFilial("CQ3",__aCTBA420[POS_FILINI]) + "' and" + CRLF
	cQuery += "			CQ3.CQ3_FILIAL <= '" + xFilial("CQ3",__aCTBA420[POS_FILFIM]) + "' and" + CRLF
Endif

// REALIZA BUSCA NO SALDO ATUAL.

cQuery += " 			CQ3.D_E_L_E_T_ = ' ' and" + CRLF
cQuery += " 			CQ3.CQ3_DATA <= (" + CRLF
cQuery += " 								SELECT	MAX(CQ32.CQ3_DATA)" + CRLF
cQuery += " 										FROM	" + retSqlName("CQ3") + " CQ32" + CRLF
cQuery += " 										WHERE	CQ32.CQ3_CONTA = CQ3.CQ3_CONTA and" + CRLF
cQuery += " 												CQ32.CQ3_CCUSTO = CQ3.CQ3_CCUSTO and" + CRLF
cQuery += " 												CQ32.CQ3_TPSALD = CQ3.CQ3_TPSALD and" + CRLF
cQuery += " 												CQ32.CQ3_MOEDA = CQ3.CQ3_MOEDA and" + CRLF
cQuery += " 												CQ32.CQ3_FILIAL = CQ3.CQ3_FILIAL and" + CRLF
cQuery += " 												CQ32.D_E_L_E_T_ = ' ' and" + CRLF
cQuery += " 												CQ32.CQ3_DATA <= '" + dTos(dDataFim) + "')" + CRLF
cQuery += " GROUP BY CQ3.CQ3_CONTA,"+ CRLF
cQuery += " CQ3.CQ3_CCUSTO,"+ CRLF
cQuery += " CQ3.CQ3_FILIAL,"+ CRLF
cQuery += " CQ3.CQ3_TPSALD,"+ CRLF
cQuery += " CQ3.CQ3_MOEDA"+ CRLF
cQuery += " ) SQ3 "+ CRLF
cQuery += " LEFT JOIN (" + CRLF
cQuery += " 	SELECT	TMPAUX.CONTA," + CRLF
cQuery += " 			TMPAUX.CUSTO," + CRLF
cQuery += " 			TMPAUX.FILIAL," + CRLF
cQuery += " 			TMPAUX.TPSALDO," + CRLF
cQuery += " 			TMPAUX.MOEDA," + CRLF
cQuery += " 			SUM(TMPAUX.ANTSLD)  ANTSLD," + CRLF
cQuery += " 			SUM(TMPAUX.CRD)  CRD," + CRLF
cQuery += " 			SUM(TMPAUX.DEB)  DEB," + CRLF
cQuery += " 			SUM(TMPAUX.MOV)  MOV," + CRLF
cQuery += " 			SUM(TMPAUX.ATUSLD)  ATUSLD" + CRLF
cQuery += " 	FROM " + cTabCTI + " TMPAUX" + CRLF
cQuery += " 	GROUP BY	TMPAUX.FILIAL," + CRLF
cQuery += " 				TMPAUX.CONTA," + CRLF
cQuery += " 				TMPAUX.CUSTO," + CRLF
cQuery += " 				TMPAUX.MOEDA," + CRLF
cQuery += " 				TMPAUX.TPSALDO" + CRLF
cQuery += " ) tCTI on	tCTI.CONTA = SQ3.CONTA and " + CRLF
cQuery += " 			tCTI.CUSTO = SQ3.CUSTO AND " + CRLF
cQuery += " 			tCTI.FILIAL = SQ3.FILIAL AND " + CRLF
cQuery += " 			tCTI.MOEDA = SQ3.MOEDA AND " + CRLF
cQuery += " 			tCTI.TPSALDO = SQ3.TPSALDO " + CRLF
cQuery += " LEFT JOIN (" + CRLF
cQuery += " 	SELECT	TMPAUX.CONTA," + CRLF
cQuery += " 			TMPAUX.CUSTO," + CRLF
cQuery += " 			TMPAUX.FILIAL," + CRLF
cQuery += " 			TMPAUX.TPSALDO," + CRLF
cQuery += " 			TMPAUX.MOEDA," + CRLF
cQuery += " 			SUM(TMPAUX.ANTSLD)  ANTSLD," + CRLF
cQuery += " 			SUM(TMPAUX.CRD)  CRD," + CRLF
cQuery += " 			SUM(TMPAUX.DEB)  DEB," + CRLF
cQuery += " 			SUM(TMPAUX.MOV)  MOV," + CRLF
cQuery += " 			SUM(TMPAUX.ATUSLD)  ATUSLD" + CRLF
cQuery += " 	FROM " + cTabCT4 + " TMPAUX" + CRLF
cQuery += " 	GROUP BY	TMPAUX.FILIAL," + CRLF
cQuery += " 				TMPAUX.CONTA," + CRLF
cQuery += " 				TMPAUX.CUSTO," + CRLF
cQuery += " 				TMPAUX.TPSALDO," + CRLF
cQuery += " 				TMPAUX.MOEDA" + CRLF
cQuery += " ) tCT4 on	tCT4.CONTA = SQ3.CONTA AND" + CRLF
cQuery += " 			tCT4.CUSTO = SQ3.CUSTO AND " + CRLF
cQuery += " 			tCT4.FILIAL = SQ3.FILIAL AND " + CRLF
cQuery += " 			tCT4.TPSALDO = SQ3.TPSALDO AND " + CRLF
cQuery += " 			tCT4.MOEDA = SQ3.MOEDA " + CRLF

cQuery := ChangeQuery(cQuery)
If InTransact()//vindo do EAI, é preciso gravar por job
	StartJob( "CTBA420Cop" , GetEnvServer() , .T. , cEmpAnt, cFilAnt,.T.,{cTabCT3},cquery)
Else
	CTBA420Cop(, ,.F.,{cTabCT3},cquery)
Endif

Return cTabCT3

/*/{Protheus.doc} CTB420CQ1
Devolve os saldos e movimentos das contas contábeis

É devolvido um arquivo temporário com os campos:
FILIAL		Filial
MOEDA		Moeda
TPSALDO	Tipo de Saldo
CONTA		Código da conta
CUSTO		Em branco
ITEM		Em branco
CLVL		Em branco
ANTSLD		Saldo anterior
CRD			Crédito no período
DEB			Débito no período
MOV			Movimento no período
ATUSLD		Saldo no fim do período

@param cTabCTI	 Arquivo temporário com os saldos das entidades contábeis até o nível de classe de valor
@param cTabCT4 Arquivo temporário com os saldos das entidades contábeis até o nível de item cotábil
@param cTabCT3	 Arquivo temporário com os saldos das entidades contábeis até o nível de centro de custo
@return cTabCT7 Nome do arquivo temporário
@author Jandir Deodato
@since 03/01/2013
@version MP11.80
/*/
Function CTB420CQ1(cTabCTI, cTabCT4, cTabCT3)
Local cQuery	:= ""
Local cTabCT7	:= CriaTrab(,.F.)
Local dDataIni	:= Iif(!Empty(__aCTBA420[POS_DATINI]),__aCTBA420[POS_DATINI],FirstDay(dDataBase))
Local dDataFim	:= Iif(!Empty(__aCTBA420[POS_DATFIM]),__aCTBA420[POS_DATFIM],LastDay(dDataBase))

cQuery := " SELECT	SQ.CONTA  CONTA," + CRLF
cQuery += " 		'" + space( TamSX3("CTI_CUSTO")[1] ) + "'  CUSTO," + CRLF
cQuery += " 		'" + space( TamSX3("CTI_ITEM")[1] ) + "'  ITEM," + CRLF
cQuery += " 		'" + space( TamSX3("CTI_CLVL")[1] ) + "'  CLVL," + CRLF
cQuery += "			SQ.FILIAL  FILIAL," + CRLF
cQuery += "			SQ.MOEDA  MOEDA," + CRLF
cQuery += "			SQ.TPSALDO  TPSALDO," + CRLF
cQuery += " 		COALESCE(ANTCRD - ANTDEB, 0) - COALESCE(tCT3.ANTSLD,0) - COALESCE(tCT4.ANTSLD,0) - COALESCE(tCTI.ANTSLD,0)  ANTSLD," + CRLF
cQuery += " 		COALESCE(SQ.ATUCRD,0) - COALESCE(SQ.ANTCRD, 0) - COALESCE(tCT3.CRD,0) - COALESCE(tCT4.CRD,0) - COALESCE(tCTI.CRD,0)  CRD," + CRLF
cQuery += " 		COALESCE(SQ.ATUDEB,0) - COALESCE(ANTDEB, 0) - COALESCE(tCT3.DEB,0) - COALESCE(tCT4.DEB,0) - COALESCE(tCTI.DEB,0)  DEB," + CRLF
cQuery += " 		COALESCE(SQ.ATUCRD,0) - COALESCE(SQ.ATUDEB,0) - COALESCE(ANTCRD - ANTDEB, 0) - COALESCE(tCT3.MOV,0) - COALESCE(tCT4.MOV,0) - COALESCE(tCTI.MOV,0)  MOV," + CRLF
cQuery += " 		COALESCE(SQ.ATUCRD - SQ.ATUDEB,0) - COALESCE(tCT3.ATUSLD,0) - COALESCE(tCT4.ATUSLD,0) - COALESCE(tCTI.ATUSLD,0)  ATUSLD" + CRLF
cQuery += " FROM ("
cQuery += " 		SELECT CQ1.CQ1_CONTA  CONTA," + CRLF
cQuery += " 				CQ1.CQ1_FILIAL  FILIAL," + CRLF
cQuery += " 				CQ1.CQ1_TPSALD  TPSALDO," + CRLF
cQuery += " 				CQ1.CQ1_MOEDA  MOEDA," + CRLF
cQuery += "				0 ATUCRD," + CRLF
cQuery += "				0 ATUDEB," + CRLF
cQuery += "				SUM(CQ1.CQ1_CREDIT)  ANTCRD," + CRLF
cQuery += "				SUM(CQ1.CQ1_DEBITO)  ANTDEB," + CRLF
cQuery += "				0 MOV," + CRLF
cQuery += "				0 ATUSLD " + CRLF
cQuery += "FROM " + RetSqlName('CQ1') + " CQ1 "
cQuery += " WHERE	" + CRLF
If !Empty(__aCTBA420[POS_TIPSLD])
	cQuery += " CQ1.CQ1_TPSALD ='"+__aCTBA420[POS_TIPSLD]+"' AND " + CRLF
Endif
If !Empty(__aCTBA420[POS_FILFIM])//filtro de filial
	cQuery += "			CQ1.CQ1_FILIAL >= '" + xFilial("CQ1",__aCTBA420[POS_FILINI]) + "' and" + CRLF
	cQuery += "			CQ1.CQ1_FILIAL <= '" + xFilial("CQ1",__aCTBA420[POS_FILFIM]) + "' and" + CRLF
Endif

// BUSCA SALDO ANTERIOR

cQuery += " 		CQ1.D_E_L_E_T_ = ' ' and" + CRLF
cQuery += " 		CQ1.CQ1_DATA < (" + CRLF
cQuery += " 							SELECT	MAX(CQ12.CQ1_DATA)" + CRLF
cQuery += " 									FROM	" + retSqlName("CQ1") + " CQ12" + CRLF
cQuery += " 									WHERE	CQ12.CQ1_CONTA = CQ1.CQ1_CONTA and" + CRLF
cQuery += " 											CQ12.CQ1_TPSALD = CQ1.CQ1_TPSALD and" + CRLF
cQuery += " 											CQ12.CQ1_MOEDA = CQ1.CQ1_MOEDA and" + CRLF
cQuery += " 											CQ12.CQ1_FILIAL = CQ1.CQ1_FILIAL and" + CRLF
cQuery += " 											CQ12.D_E_L_E_T_ = ' ' and" + CRLF
cQuery += " 											CQ12.CQ1_DATA <= '" + dTos(dDataIni) + "'" + CRLF
cQuery += " 						)" + CRLF
cQuery += "		GROUP BY CQ1.CQ1_CONTA,"+ CRLF
cQuery += "				  CQ1.CQ1_FILIAL,"+ CRLF
cQuery += "				  CQ1.CQ1_MOEDA,"+ CRLF
cQuery += "				  CQ1.CQ1_TPSALD"+ CRLF
cQuery += " UNION ALL "+ CRLF
cQuery += " SELECT CQ1.CQ1_CONTA  CONTA,"+ CRLF
cQuery += "		 CQ1.CQ1_FILIAL  FILIAL,"+ CRLF
cQuery += "		 CQ1.CQ1_TPSALD  TPSALDO,"+ CRLF
cQuery += " 	    CQ1.CQ1_MOEDA  MOEDA,"+ CRLF
cQuery += "		 SUM(CQ1.CQ1_CREDIT)  ATUCRD,"+ CRLF
cQuery += "		 SUM(CQ1.CQ1_DEBITO)  ATUDEB,"+ CRLF
cQuery += " 		0 ANTCRD,"+ CRLF
cQuery += "		0 ANTDEB,"+ CRLF
cQuery += " 		0 MOV,"+ CRLF
cQuery += " 		0 ATUSLD"+ CRLF

cQuery += "FROM " + RetSqlName('CQ1') + " CQ1 "
cQuery += " WHERE	" + CRLF
If !Empty(__aCTBA420[POS_TIPSLD])
	cQuery += " CQ1.CQ1_TPSALD ='"+__aCTBA420[POS_TIPSLD]+"' AND " + CRLF
Endif
If !Empty(__aCTBA420[POS_FILFIM])//filtro de filial
	cQuery += "			CQ1.CQ1_FILIAL >= '" + xFilial("CQ1",__aCTBA420[POS_FILINI]) + "' and" + CRLF
	cQuery += "			CQ1.CQ1_FILIAL <= '" + xFilial("CQ1",__aCTBA420[POS_FILFIM]) + "' and" + CRLF
Endif

// BUSCA SALDO ATUAL.

cQuery += " 		CQ1.D_E_L_E_T_ = ' ' and" + CRLF
cQuery += " 		CQ1.CQ1_DATA <= (" + CRLF
cQuery += " 							SELECT	MAX(CQ12.CQ1_DATA)" + CRLF
cQuery += " 									FROM	" + retSqlName("CQ1") + " CQ12" + CRLF
cQuery += " 									WHERE	CQ12.CQ1_CONTA = CQ1.CQ1_CONTA and" + CRLF
cQuery += " 											CQ12.CQ1_TPSALD = CQ1.CQ1_TPSALD and" + CRLF
cQuery += " 											CQ12.CQ1_MOEDA = CQ1.CQ1_MOEDA and" + CRLF
cQuery += " 											CQ12.CQ1_FILIAL = CQ1.CQ1_FILIAL and" + CRLF
cQuery += " 											CQ12.D_E_L_E_T_ = ' ' and" + CRLF
cQuery += " 											CQ12.CQ1_DATA <= '" + dTos(dDataFim) + "'" + CRLF
cQuery += " 						)" + CRLF
cQuery += "		GROUP BY CQ1.CQ1_CONTA,"+ CRLF
cQuery += "				  CQ1.CQ1_FILIAL,"+ CRLF
cQuery += "				  CQ1.CQ1_MOEDA,"+ CRLF
cQuery += "				  CQ1.CQ1_TPSALD ) "+ CRLF
cQuery += " SQ "
cQuery += " LEFT JOIN (" + CRLF
cQuery += " 	SELECT	TMPAUX.FILIAL," + CRLF
cQuery += " 			TMPAUX.CONTA," + CRLF
cQuery += " 			TMPAUX.TPSALDO," + CRLF
cQuery += " 			TMPAUX.MOEDA," + CRLF
cQuery += " 			SUM(TMPAUX.ANTSLD)  ANTSLD," + CRLF
cQuery += " 			SUM(TMPAUX.CRD)  CRD," + CRLF
cQuery += " 			SUM(TMPAUX.DEB)  DEB," + CRLF
cQuery += " 			SUM(TMPAUX.MOV)  MOV," + CRLF
cQuery += " 			SUM(TMPAUX.ATUSLD)  ATUSLD" + CRLF
cQuery += " 	FROM " + cTabCTI + " TMPAUX" + CRLF
cQuery += " 	GROUP BY	TMPAUX.FILIAL," + CRLF
cQuery += " 	        	TMPAUX.CONTA," + CRLF
cQuery += " 	        	TMPAUX.TPSALDO," + CRLF
cQuery += " 	        	TMPAUX.MOEDA" + CRLF
cQuery += " ) tCTI on	tCTI.CONTA = SQ.CONTA AND " + CRLF
cQuery += "	  tCTI.FILIAL = SQ.FILIAL AND " + CRLF
cQuery += "	  tCTI.MOEDA = SQ.MOEDA AND " + CRLF
cQuery += "	  tCTI.TPSALDO = SQ.TPSALDO " + CRLF
cQuery += " LEFT JOIN (" + CRLF
cQuery += " 	SELECT	TMPAUX.CONTA," + CRLF
cQuery += " 	     	TMPAUX.FILIAL," + CRLF
cQuery += " 	     	TMPAUX.MOEDA," + CRLF
cQuery += " 	     	TMPAUX.TPSALDO," + CRLF
cQuery += " 			SUM(TMPAUX.ANTSLD)  ANTSLD," + CRLF
cQuery += " 			SUM(TMPAUX.CRD)  CRD," + CRLF
cQuery += " 			SUM(TMPAUX.DEB)  DEB," + CRLF
cQuery += " 			SUM(TMPAUX.MOV)  MOV," + CRLF
cQuery += " 			SUM(TMPAUX.ATUSLD)  ATUSLD" + CRLF
cQuery += " 	FROM " + cTabCT4 + " TMPAUX" + CRLF
cQuery += " 	GROUP BY	TMPAUX.FILIAL," + CRLF
cQuery += " 	        	TMPAUX.CONTA," + CRLF
cQuery += " 	        	TMPAUX.TPSALDO," + CRLF
cQuery += " 	        	TMPAUX.MOEDA" + CRLF
cQuery += " ) tCT4 on	tCT4.CONTA = SQ.CONTA AND " + CRLF
cQuery += "         	tCT4.FILIAL = SQ.FILIAL AND " + CRLF
cQuery += "         	tCT4.MOEDA = SQ.MOEDA AND " + CRLF
cQuery += "         	tCT4.TPSALDO = SQ.TPSALDO " + CRLF
cQuery += " LEFT JOIN (" + CRLF
cQuery += " 	SELECT	TMPAUX.CONTA," + CRLF
cQuery += " 	     	TMPAUX.FILIAL," + CRLF
cQuery += " 	     	TMPAUX.MOEDA," + CRLF
cQuery += " 	     	TMPAUX.TPSALDO," + CRLF
cQuery += " 			SUM(TMPAUX.ANTSLD)  ANTSLD," + CRLF
cQuery += " 			SUM(TMPAUX.CRD)  CRD," + CRLF
cQuery += " 			SUM(TMPAUX.DEB)  DEB," + CRLF
cQuery += " 			SUM(TMPAUX.MOV)  MOV," + CRLF
cQuery += " 			SUM(TMPAUX.ATUSLD)  ATUSLD" + CRLF
cQuery += " 	FROM " + cTabCT3 + " TMPAUX" + CRLF
cQuery += " 	GROUP BY	TMPAUX.FILIAL," + CRLF
cQuery += " 	         	TMPAUX.CONTA," + CRLF
cQuery += " 	         	TMPAUX.TPSALDO," + CRLF
cQuery += " 	         	TMPAUX.MOEDA" + CRLF
cQuery += " ) tCT3 on	tCT3.CONTA = SQ.CONTA AND " + CRLF
cQuery += "             tCT3.FILIAL = SQ.FILIAL AND " + CRLF
cQuery += "             tCT3.MOEDA = SQ.MOEDA AND " + CRLF
cQuery += "             tCT3.TPSALDO = SQ.TPSALDO " + CRLF
cQuery := ChangeQuery(cQuery)

If InTransact()//vindo do EAI, e preciso gravar por job
	StartJob( "CTBA420Cop" , GetEnvServer() , .T. , cEmpAnt, cFilAnt,.T.,{cTabCT7},cquery)
Else
	CTBA420Cop(, ,.F.,{cTabCT7},cquery)
Endif

Return cTabCT7

//-------------------------------------------------------------------
/*/{Protheus.doc} CTB420CarP(aAutoCab)
Carrega o pergunte com o array da rotina automatica.

@param aAutocab, Array contendo os valores para o pergunte da rotina
@return Nil

@author Jandir Deodato
@since 03/01/2013
@version MP11.80
/*/
//-------------------------------------------------------------------
Static Function CTB420CarP(aAutoCab)
Local nX   := 0
Local nPos := 0

For nX := 1 to __nQtdePerg
	nPos := aScan( aAutoCab, { |x| UPPER(AllTrim(x[1])) == "MV_PAR"+StrZero(nX,2) } )
	IF nPos>0
		&( "MV_PAR"+StrZero(nX,2) ) := aAutoCab[nPos][2]
	Else
		If nX==3
			&( "MV_PAR"+StrZero(nX,2) ) := 1
		ElseIf nX == POS_SLDZER // Se não foi informada a tag de saldos zerados, define 2 (não mostrar) por padrão.
			&( "MV_PAR"+StrZero(nX,2) ) := 2
		Else
			&( "MV_PAR"+StrZero(nX,2) ) := ''
		Endif
	Endif
Next
CTBA420Arr("CTBA420")

// Monta a variável aEntidades com as entidades gerenciais (de 5 a 9).
For nX := 1 to len (aEntidades)
	If aEntidades[nX][1]
		nPos := AScan(aAutoCab, { |x| UPPER(AllTrim(x[1])) == "ENTCONT" + StrZero(nX + 4, 2) + "DE" })
		If nPos > 0
			aEntidades[nX][4] := aAutoCab[nPos][2]
		Endif

		nPos := AScan(aAutoCab, { |x|  UPPER(AllTrim(x[1])) == "ENTCONT" + StrZero(nX + 4, 2) + "ATE" })
		If nPos > 0
			aEntidades[nX][5] := aAutoCab[nPos][2]
		Endif
	Endif
Next

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} IntegDef
Função para integração via Mensagem Única Totvs.

@param  cXml          Variável com conteúdo XML para envio/recebimento.
@param  cTypeTrans    Tipo de transação (Envio / Recebimento).
@param  cTypeMsg      Tipo de mensagem (Business Type, WhoIs, etc).
@param  cVersion      Versão da mensagem.
@param  cTransac      Nome da transação.

@return  aRet   - (array)   Contém o resultado da execução e a mensagem XML de retorno.
       aRet[1] - (boolean)  Indica o resultado da execução da função
       aRet[2] - (caracter) Mensagem XML para envio
       aRet[3] - (caracter) Nome da mensagem

@author Jandir Deodato
@since 03/01/2013
@version MP11.80
/*/
//-------------------------------------------------------------------
Static Function IntegDef(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
Return CTBI420(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)

//-------------------------------------------------------------------
/*/{Protheus.doc} CTBA420Cop(cEmp,cFil,lRpc,cTabela,cQuery,lExclui)
Rotina que cria ou apaga as tabelas do TOP

@param cEmp empresa do Protheus que caso necessario, ira iniciar a thread
@param cFil Filial do Protheus caso necessario, ira iniciar a thread
@param lRPC Indica se veio via o job ou nao
@param aTabela Indica as tabelas que serao incluidas/excluidas
@param cQuery Caso seja inclusao, tras a query que sera usada no banco, ja passada pelo change query
@param lExclui Indica se é ou não exclusão de tabela
@return nil

@author Jandir Deodato
@since 03/01/2013
@version MP11.80
/*/
//-------------------------------------------------------------------
Function CTBA420Cop(cEmp,cFil,lRpc,aTabelas,cQuery,lExclui)
Local cAlias
Local nX:=0
Default lRPC :=.F.
Default lExclui:=.F.
Default aTabelas:={}

If lRPC
	RpcSetType(3)
	RpcSetEnv(cEmp,cFil,,,"CTB",, , /*lShowFinal*/, /*lAbend*/, .F. /*lOpenSX*/, /*lConnect*/)
Endif
If lExclui
	For nX:=1 to Len (aTabelas)
		TcDelFile(aTabelas[nX])
	Next
Else
	cAlias:=GetNextAlias()
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .T., .F.)
	If Len(aTabelas)>0
		COPY  TO &aTabelas[1] VIA "TOPCONN"
	Endif
	(cAlias)->(dbCloseArea())

Endif

Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} C420GetCub
Devolve os saldos e movimentos das entidades contábeis (conta, centro de custo, item contábil e classe de valor,)
e das entidades contabeis adicionais, quando existentes no sistema e o parametro MV_CTBCUBE estiver ligado

É devolvido um arquivo temporário com os campos:
FILIAL		Filial da Conta
CONTA		Código da conta
CUSTO		Código do centro de custos
ITEM		Código do item contábil
CLVL		Código da classe de valor
ENT05		Codigo da entidade contábil 05
ENT06		Código da entidade contábil 06
ENT07 		Código da entidade Contábil 07
ENT08		Código da Entidade Contábil 08
ENT09		Código da Entidde Contábil 09
ATUSLD		Saldo no fim do período
MOEDA		Moeda
TPSALDO	Tipo de Saldo

@return lRet	Sucesso ou não
@return cRetAlias	Nome do arquivo temporário
@author Jandir Deodato
@since 03/01/2013
@version MP11.80
/*/
//-------------------------------------------------------------------------------------
Function C420GetCub()
Local cAlias
Local cQuery
Local dDataIni	:= Iif(!Empty(__aCTBA420[POS_DATINI]),__aCTBA420[POS_DATINI],FirstDay(dDataBase))
Local dDataFim	:= Iif(!Empty(__aCTBA420[POS_DATFIM]),__aCTBA420[POS_DATFIM],LastDay(dDataBase))
Local nX:=0
Local cPrefix
Local lRet:=.T.
Local aErro:={}
Local cErro:=''
Local aArea:=GetArea()

cQuery := "SELECT CVX_FILIAL FILIAL, " + CRLF
cQuery += "       CVX_CONFIG TIPO, " + CRLF
cQuery += "       CVX_TPSALD TPSALDO, " + CRLF
cQuery += "       CVX_NIV01  CONTA, " + CRLF
cQuery += "       CVX_MOEDA  MOEDA, " + CRLF
cQuery += "       CVX_NIV02  CUSTO, " + CRLF
cQuery += "       CVX_NIV03  ITEM, " + CRLF
cQuery += "       CVX_NIV04  CLVL, " + CRLF

For nX:=1 to len (aEntidades)
	cPrefix:=StrZero(nX+4,2)
	If aEntidades[nX][1] //verificando se usa as entidades adicionais
		cQuery += " CVX_NIV"+cPrefix+ "  ENT" + cPrefix + ", " + CRLF
	Else
		cQuery += "'"+Space(20)+"'  ENT" + cPrefix + ", " + CRLF
	Endif
Next
cQuery += " SUM(COALESCE(CVX_SLDCRD,0)-COALESCE(CVX_SLDDEB,0)) ATUSLD" + CRLF
cQuery += " FROM " + RetSqlName("CVX") + CRLF
cQuery += " WHERE  CVX_CONFIG = " + CRLF
cQuery += " (SELECT MAX(AUX.CVX_CONFIG) FROM " +RetSqlName("CVX")+ " AUX WHERE D_E_L_E_T_ = ' ' )" + CRLF
// ultimo nivel a ser encontrado

If Empty(__aCTBA420[POS_TIPSLD])
	Aadd(aErro,STR0014)//'Tipo de Saldo vazio.'
	lRet := .F.
Else
	cQuery += " AND CVX_TPSALD ='"+__aCTBA420[POS_TIPSLD]+"' " + CRLF
Endif

If Empty(__aCTBA420[POS_FILFIM])//filtro de filial
	If !Empty(__aCTBA420[POS_FILINI])
		Aadd(aErro,STR0008)//'Inconsistência na Filial de/até.'
		lRet := .F.
	Endif
Else
	cQuery += "	AND	CVX_FILIAL >= '" + xFilial("CVX",__aCTBA420[POS_FILINI]) + "'" + CRLF
	cQuery += "	AND	CVX_FILIAL <= '" + xFilial("CVX",__aCTBA420[POS_FILFIM]) + "'" + CRLF
Endif
If Empty(__aCTBA420[POS_CNTFIM])//filtro da conta contabil
	If !Empty(__aCTBA420[POS_CNTINI])
		Aadd(aErro,STR0010)//'Inconsistência na Conta contábil de/até.'
		lRet := .F.
	Endif
Else
	cQuery += " AND CVX_NIV01 >= '" + __aCTBA420[POS_CNTINI] + "'" + CRLF
	cQuery += " AND CVX_NIV01 <= '" + __aCTBA420[POS_CNTFIM] + "'" + CRLF
Endif

//--
If Empty(__aCTBA420[POS_CCFIM])//filtro do centro de custo
	If !Empty(__aCTBA420[POS_CCINI])
		Aadd(aErro,STR0011)//'Inconsistência no Centro de Custo de/até.'
		lRet := .F.
	Endif
Else
	cQuery += " AND CVX_NIV02 >= '" + __aCTBA420[POS_CCINI] + "'" + CRLF
	cQuery += " AND CVX_NIV02 <= '" + __aCTBA420[POS_CCFIM] + "'" + CRLF
Endif

//---
If Empty(__aCTBA420[POS_ITCFIM])//filtro do Item Contabil
	If !Empty(__aCTBA420[POS_ITCINI])
		Aadd(aErro,STR0012)//'Inconsistência no Item Contábil de/até.'
		lRet := .F.
	Endif
Else
	cQuery += " AND CVX_NIV03 >= '" + __aCTBA420[POS_ITCINI] + "'" + CRLF
	cQuery += " AND CVX_NIV03 <= '" + __aCTBA420[POS_ITCFIM] + "'" + CRLF
Endif

//-----
If Empty(__aCTBA420[POS_CLCFIM])//filtro da Classe de Valor
	If !Empty(__aCTBA420[POS_CLCINI])
		Aadd(aErro,STR0013)//'Inconsistência na Classe de Valor de/até.'
		lRet := .F.
	Endif
Else
	cQuery += " AND CVX_NIV04 >= '" + __aCTBA420[POS_CLCINI] + "'" + CRLF
	cQuery += " AND CVX_NIV04 <= '" + __aCTBA420[POS_CLCFIM] + "'" + CRLF
Endif
For nX:=1 to Len (aEntidades)
	If aEntidades[nX][1]
		cPrefix:=StrZero(nX+4,2)
		If Empty(aEntidades[nX][5])
			If !Empty(aEntidades[nX][4])
				Aadd(aErro,STR0015+" "+cPrefix+'.')//'Inconsistência na Entidade contábil'
				lRet := .F.
				Exit
			Endif
		Else
			cQuery += " AND CVX_NIV" + cPrefix + " >= '" + aEntidades[nX][4] + "'" + CRLF
			cQuery += " AND CVX_NIV" + cPrefix + " <= '" + aEntidades[nX][5] + "'" + CRLF
		Endif
	Else
		Exit//
	Endif
Next
cQuery += " AND CVX_DATA <= '" + DtoS(dDataFim) + "' AND CVX_DATA >= '" + DtoS(dDataIni) + "'" + CRLF
cQuery += " AND D_E_L_E_T_ = ' '" + CRLF
cQuery += " GROUP BY CVX_FILIAL,CVX_CONFIG,CVX_TPSALD,CVX_NIV01,CVX_NIV02,CVX_NIV03,CVX_NIV04" + CRLF

For nX:=1 to Len (aEntidades)
	If aEntidades[nX][1]
		cPrefix:=StrZero(nX+4,2)
		cQuery += " ,CVX_NIV"+cPrefix + CRLF
	Else
		Exit
	Endif
Next
cQuery += " ,CVX_MOEDA " + CRLF
If Empty(__aCTBA420[POS_ARQUIV])//tipo de arquivo
	Aadd(aErro,STR0016)//'Local de gravação do arquivo TXT não informado.'
	lRet := .F.
Endif
If !lRet
	cErro:=STR0017+" "
	For nX:=1 to Len(aErro)
		cErro+=CRLF+aErro[nX]
	Next
	cErro+=CRLF+STR0018//'Verifique as ocorrências e tente novamente.'
	Help(,,'CTB420IN',,cErro,1,0)
Else
	cAlias:=GetNextAlias()
	If Select(cAlias)>0
		(cAlias)->(dbCloseArea())
	Endif
	cQuery:=ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN" , TCGenQry(,,cQuery), cAlias, .T., .T.)
Endif

RestArea(aArea)

Return {lRet,cAlias}

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} CTBA420Arr
Função que carrega a variavel de parametros com os perguntes da rotina

@author Alvaro Camillo Neto
@since 22/08/2013
@version MP11.80
/*/
//-------------------------------------------------------------------------------------
Static Function CTBA420Arr(cPerg)
	Local cArq       := "CTBMOV" + "_" + DTOS(dDataBase) +"_"+ cValtochar(Seconds())
	Local cDirTxt    := Alltrim(GetMV("MV_CTBDTXT",.F.,""))
	Local nOrdem     := 0
	Local nCont      := 0
	Local cSeparador := If(IsSrvUnix(), "/", "\")

	cArq := STRTRAN ( cArq , "." , "" ) + ".txt"

	If cPerg == "CTBA420" .OR. cPerg == "CTBA420A"
		__aCTBA420 := {}
		aAdd(__aCTBA420,MV_PAR01)
		aAdd(__aCTBA420,MV_PAR02)
		aAdd(__aCTBA420,MV_PAR03)
		aAdd(__aCTBA420,MV_PAR04)
		aAdd(__aCTBA420,MV_PAR05)
		aAdd(__aCTBA420,MV_PAR06)
		aAdd(__aCTBA420,MV_PAR07)
		aAdd(__aCTBA420,MV_PAR08)
		aAdd(__aCTBA420,MV_PAR09)
		aAdd(__aCTBA420,MV_PAR10)
		aAdd(__aCTBA420,MV_PAR11)
		aAdd(__aCTBA420,MV_PAR12)
		aAdd(__aCTBA420,MV_PAR13)
		aAdd(__aCTBA420,MV_PAR14)

		If cPerg == "CTBA420"
			aAdd(__aCTBA420,MV_PAR15)
			aAdd(__aCTBA420,MV_PAR16)
			aAdd(__aCTBA420,MV_PAR17)
		Else
			cDirTxt := IIf(Right(cDirTxt,1) !=cSeparador,cDirTxt+cSeparador,cDirTxt)
			aAdd(__aCTBA420,cDirTxt+cArq)
			aAdd(__aCTBA420,MV_PAR15)
			aAdd(__aCTBA420,MV_PAR16)
		EndIf

	ElseIf cPerg == "CTBA420E"
		nOrdem := 1
		For nCont := 1 To Len(aEntidades)
			If aEntidades[nCont][1]
				aEntidades[nCont][4] := &("MV_PAR" + StrZero(nOrdem,2))
				nOrdem += 1
				aEntidades[nCont][5] := &("MV_PAR" + StrZero(nOrdem,2))
				nOrdem += 1
			Endif
		Next nCont
	Endif

Return Nil

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} CriaSX1
Cria as perguntas da rotina

@author Alvaro Camillo Neto
@since 22/08/2013
@version MP11.80
@param cPerg, nome do pergunte a ser criado
@return nRet, Quantidade de perguntas criadas
/*/
//-------------------------------------------------------------------------------------
Static Function CriaSX1(cPerg)
Local nRet := 0
Local aArea    := GetArea()
Local aAreaDic := SX1->( GetArea() )
Local aEstrut  := {}
Local aStruDic := SX1->( dbStruct() )
Local aDados   := {}
Local nI       := 0
Local nJ       := 0
Local nX       := 0
Local nTam1    := Len( SX1->X1_GRUPO )
Local nTam2    := Len( SX1->X1_ORDEM )
Local cPrefix := ""
Local nOrdem := 0

aEstrut := { "X1_GRUPO"  , "X1_ORDEM"  , "X1_PERGUNT", "X1_PERSPA" , "X1_PERENG" , "X1_VARIAVL", "X1_TIPO"   , ;
             "X1_TAMANHO", "X1_DECIMAL", "X1_PRESEL" , "X1_GSC"    , "X1_VALID"  , "X1_VAR01"  , "X1_DEF01"  , ;
             "X1_DEFSPA1", "X1_DEFENG1", "X1_CNT01"  , "X1_VAR02"  , "X1_DEF02"  , "X1_DEFSPA2", "X1_DEFENG2", ;
             "X1_CNT02"  , "X1_VAR03"  , "X1_DEF03"  , "X1_DEFSPA3", "X1_DEFENG3", "X1_CNT03"  , "X1_VAR04"  , ;
             "X1_DEF04"  , "X1_DEFSPA4", "X1_DEFENG4", "X1_CNT04"  , "X1_VAR05"  , "X1_DEF05"  , "X1_DEFSPA5", ;
             "X1_DEFENG5", "X1_CNT05"  , "X1_F3"     , "X1_PYME"   , "X1_GRPSXG" , "X1_HELP"   , "X1_PICTURE", ;
             "X1_IDFIL"   }

If Alltrim(cPerg) == "CTBA420E"
	nOrdem := 1
	For nX :=1 To Len (aEntidades)
		If !aEntidades[nX][1]
			Exit
		Endif

		cPrefix:=StrZero(nX+4,2)

		aAdd( aDados, {cPerg,StrZero(nOrdem,2),'Ent Cont ' + cPrefix + ' de: ?','¿De Ent Cont ' + cPrefix + ' ?','From Acc. Ent. ' + cPrefix + ': ?','MV_CH'+AllTrim(cValToChar(nOrdem + 15)),'C',9,0,0,'G','','MV_PAR'+AllTrim(cValToChar(nOrdem + 15)),'','','','','','','','','','','','','','','','','','','','','','','','','CV0','S','040','','',''} )
		aHlpPor := {"Entidade Contábil " + cPrefix, "inicial de exportação."}
		aHlpSpa := {"Entidad Contable " + cPrefix, "inicial de exportacion."}
		aHlpEng := {"Accounting Entity " + cPrefix, "Export Initial Accounting Entity"}
		PutHelp( "P."+cPerg+StrZero(nOrdem,2)+".", aHlpPor, aHlpEng, aHlpSpa, .T. )
		nOrdem += 1

		aAdd( aDados, {cPerg,StrZero(nOrdem,2),'Ent Cont ' + cPrefix + ' até: ?','¿A Ent Cont ' + cPrefix + ': ?','To Acc. Ent. ' + cPrefix + ': ?','MV_CH'+AllTrim(cValToChar(nOrdem + 15)),'C',9,0,0,'G','','MV_PAR'+AllTrim(cValToChar(nOrdem + 15)),'','','','','','','','','','','','','','','','','','','','','','','','','CV0','S','040','','',''} )
		aHlpPor := {"Entidade Contábil " + cPrefix, "final de exportação."}
		aHlpSpa := {"Entidad Contable " + cPrefix, "final de exportacion."}
		aHlpEng := {"Accounting Entity " + cPrefix, "Export Final Accounting Entity"}
		PutHelp( "P."+cPerg+StrZero(nOrdem,2)+".", aHlpPor, aHlpEng, aHlpSpa, .T. )
		nOrdem += 1
	Next
Endif

//
// Atualizando dicionário
//
dbSelectArea("SX1")
SX1->(dbSetOrder(1))

For nI := 1 To Len( aDados )
	If !SX1->( msSeek( PadR( aDados[nI][1], nTam1 ) + PadR( aDados[nI][2], nTam2 ) ) )
		RecLock( "SX1", .T. )
		For nJ := 1 To Len( aDados[nI] )
			If aScan( aStruDic, { |aX| PadR( aX[1], 10 ) == PadR( aEstrut[nJ], 10 ) } ) > 0
				SX1->( FieldPut( FieldPos( aEstrut[nJ] ), aDados[nI][nJ] ) )
			EndIf
		Next nJ
		MsUnLock()
	EndIf
Next nI

nRet := Len( aDados )

SX1->(RestArea( aAreaDic ))
RestArea( aArea )

Return nRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} CTB420VldE
Validação das perguntas de entidades adicionais

@author Pedro Alencar
@since 14/01/2014
@version P12
@return lRet, Válido ou não
/*/
//-------------------------------------------------------------------------------------
Function CTB420VldE ()
	Local lRet := .T.
	Local cIdEntid := ""
	Local cValor := ""
	Local aAreaCV0 := CV0->(GetArea())
	Local nTamCod := TamSX3("CV0_CODIGO" )[ 1 ]
	Local cParam := ""

	cParam := ReadVar()
	If cParam $ "MV_PAR01#MV_PAR02"
		cIdEntid := "05"
	ElseIf cParam $ "MV_PAR03#MV_PAR04"
		cIdEntid := "06"
	ElseIf cParam $ "MV_PAR05#MV_PAR06"
		cIdEntid := "07"
	ElseIf cParam $ "MV_PAR07#MV_PAR08"
		cIdEntid := "08"
	ElseIf cParam $ "MV_PAR09#MV_PAR10"
		cIdEntid := "09"
	EndIf

	cValor := AllTrim(&(cParam))

	DbSelectArea("CV0")
	DbSetOrder(1)
	If !Empty(cValor) .AND. !MsSeek(xFilial("CV0")+cIdEntid+PadR(cValor,nTamCod))
		lRet := .F.
		Help(,,'CTB420VldE',,OemToAnsi(STR0038),1,0) //'Entidade inválida!'
	Endif

	CV0->(RestArea(aAreaCV0))
Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} CTB420VldL
Validação da pergunta de livro contábil

@author Pedro Alencar
@since 14/01/2014
@version P12
@return lRet, Válido ou não
/*/
//-------------------------------------------------------------------------------------
Function CTB420VldL ()
	Local lRet := .T.
	Local cParam := ""
	Local cValor := ""
	Local aAreaCTN := CTN->(GetArea())
	Local nTamCod := TamSX3("CTN_CODIGO" )[ 1 ]

	cParam := ReadVar()
	cValor := AllTrim(&(cParam))

	DbSelectArea("CTN")
	CTN->(DbSetOrder(1))
	If !Empty(cValor) .AND. !MsSeek(xFilial("CTN")+PadR(cValor,nTamCod))
		lRet := .F.
		Help(,,'CTB420VldL',,OemToAnsi(STR0039),1,0) //'Código de Livro inválido!'
	Endif

	CTN->(RestArea(aAreaCTN))
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CtSelFil
Função que retorna um vetor com todas as filiais dentro do range definido
no de/até do pergunte, considerando a empresa corrente. Usado para popular
o vetor aSelFil, na exportação de saldos contábeis com visão gerencial.

@author Pedro Alencar
@since 29/01/2014
@version P11.80
@param aSM0, Relação de filiais retornadas da função AdmAbreSM0()
@return aRet, Filiais dentro do range definido no de/até do pergunte
/*/
//-------------------------------------------------------------------
Static Function CtSelFil(aSM0)
	Local aRet := {}
	Local nCont := 0

	For nCont := 1 To Len(aSM0)
		If Upper(AllTrim(aSM0[nCont][1])) == Upper(AllTrim(cEmpAnt))
			If aSM0[nCont][2] >= __aCTBA420[POS_FILINI] .AND. aSM0[nCont][2] <= __aCTBA420[POS_FILFIM]
				aAdd(aRet, aSM0[nCont][2])
			Endif
		Endif
	Next nCont

Return aRet

/*/{Protheus.doc} CTB420X3
Retorna a estrutura dos campos gerados por essa função.

@author 	Felipe Raposo
@version	P12.1.23
@since 		02/07/2019
/*/
Function CTB420X3(lGeraStr, nOpc, lGerPlan, lCubo, cFilSaldo)

Local aArea      := {}
Local aSX3Area   := {}
Local aEntidades := {}
Local cField     := ""
Local nX, cX 
Local aPEStruct := {}
Local lPEValid := .T.
Local cPEError := ""

Static aSX3Struct := {}
If lGeraStr
	aArea    := GetArea()
	aSX3Area := SX3->(GetArea())

	// Popula a variável aEntidades, se necessário.
	CTB420CarE(aEntidades)

	// Monta a variável aSX3Struct com a estrutura.
	// Estrutura da variável -> {bCampo, cCampo, cDescrição, cTipo, nTamanho, nDecimal}
	aSX3Struct := {}
	aAdd(aSX3Struct, {{|cAlias, cDC| cEmpAnt}, "Company", "Company", "C", len(cEmpAnt), 0})

	If lGerPlan
		If Empty(cFilSaldo)
			aAdd(aSX3Struct, {{|cAlias, cDC| cFilAnt}, "CT2_FILIAL"})
		Else
			aAdd(aSX3Struct, {{|cAlias, cDC| cFilSaldo}, "CT2_FILIAL"})
		Endif
	Else
		aAdd(aSX3Struct, {{|cAlias, cDC| (cAlias)->FILIAL}, "CT2_FILIAL"})
	Endif

	If nOpc == 1 // Movimentos contábeis.
		aAdd(aSX3Struct, {{|cAlias, cDC| stod((cAlias)->DATA)}, "CT2_DATA"})
		aAdd(aSX3Struct, {{|cAlias, cDC| (cAlias)->LOTE},       "CT2_LOTE"})
		aAdd(aSX3Struct, {{|cAlias, cDC| (cAlias)->SBLOTE},     "CT2_SBLOTE"})
		aAdd(aSX3Struct, {{|cAlias, cDC| (cAlias)->DOC},        "CT2_DOC"})
		aAdd(aSX3Struct, {{|cAlias, cDC| If(lGerPlan, "01", (cAlias)->(MOEDA))}, "CT2_MOEDLC"})

		aAdd(aSX3Struct, {{|cAlias, cDC| cDC}, "CT2_DC", FWX3Titulo("CT2_DC"), "C", 2, 0})
		aAdd(aSX3Struct, {{|cAlias, cDC| (cAlias)->TPSALDO},    "CT2_TPSALD"})
		aAdd(aSX3Struct, {{|cAlias, cDC| (cAlias)->(If(cDC = "DB", CT2_DEBITO, CT2_CREDIT))}, "CT1_CONTA"})
		aAdd(aSX3Struct, {{|cAlias, cDC| (cAlias)->(If(cDC = "DB", CT2_CCD,    CT2_CCC))},    "CTT_CUSTO"})
		aAdd(aSX3Struct, {{|cAlias, cDC| (cAlias)->(If(cDC = "DB", CT2_ITEMD,  CT2_ITEMC))},  "CTD_ITEM"})
		aAdd(aSX3Struct, {{|cAlias, cDC| (cAlias)->(If(cDC = "DB", CT2_CLVLDB, CT2_CLVLCR))}, "CTH_CLVL"})
		aAdd(aSX3Struct, {{|cAlias, cDC| (cAlias)->CT2_VALOR},  "CT2_VALOR"})
		For nX := 1 to Len(aEntidades)
			If aEntidades[nX][1]
				cX := StrZero(nX + 4, 2)
				aTamSX3 := TamSX3("CT2_EC" + cX + "DB")
				aAdd(aSX3Struct, {&("{|cAlias, cDC| (cAlias)->&('CT2_EC" + cX + "' + cDC)}"), "CT2_EC" + cX + "DB/CT2_EC" + cX + "CR", RTrim(FWX3Titulo("CT2_EC" + cX + "DB")) + "/ " + FWX3Titulo("CT2_EC" + cX + "CR"), aTamSX3[3], aTamSX3[1], aTamSX3[2]})
			Else
				aAdd(aSX3Struct, {{|cAlias, cDC| ""}, "FILLER", "FILLER", "C", 20, 0})
			Endif
		Next nX
		aAdd(aSX3Struct, {{|cAlias, cDC, cHist| cHist},         "CT2_HIST", FWX3Titulo("CT2_HIST"), "C", 250, 0})
		aAdd(aSX3Struct, {{|cAlias, cDC| (cAlias)->CT2_ATIVDE}, "CT2_ATIVDE"})
		aAdd(aSX3Struct, {{|cAlias, cDC| (cAlias)->CT2_ATIVCR}, "CT2_ATIVCR"})
		aAdd(aSX3Struct, {{|cAlias, cDC| (cAlias)->CT2_FILORI}, "CT2_FILORI"})
		aAdd(aSX3Struct, {{|cAlias, cDC| (cAlias)->CT2_ORIGEM}, "CT2_ORIGEM"})
		aAdd(aSX3Struct, {{|cAlias, cDC| (cAlias)->CT2_ROTINA}, "CT2_ROTINA"})
		aAdd(aSX3Struct, {{|cAlias, cDC| (cAlias)->CT2_LP},     "CT2_LP"})
		aAdd(aSX3Struct, {{|cAlias, cDC| (cAlias)->CT2_CODCLI}, "CT2_CODCLI"})
		aAdd(aSX3Struct, {{|cAlias, cDC| (cAlias)->CT2_CODFOR}, "CT2_CODFOR"})
	Else // Exportação de saldos contábeis.
		aAdd(aSX3Struct, {{|cAlias, cDC| If(Empty(__aCTBA420[POS_DATFIM]), LastDay(dDataBase), __aCTBA420[POS_DATFIM])}, "CT2_DATA"})
		aAdd(aSX3Struct, {{|cAlias, cDC| '000001'},                               "CT2_LOTE"})
		aAdd(aSX3Struct, {{|cAlias, cDC| '001'},                                  "CT2_SBLOTE"})
		aAdd(aSX3Struct, {{|cAlias, cDC| If(Empty(cDoc), '000001', Soma1(cDoc))}, "CT2_DOC"})
		aAdd(aSX3Struct, {{|cAlias, cDC| If(lGerPlan, "01", (cAlias)->(MOEDA))},  "CT2_MOEDLC"})

		aAdd(aSX3Struct, {{|cAlias, cDC| cDC}, "CT2_DC", FWX3Titulo("CT2_DC"), "C", 2, 0})
		If lGerPlan
			aAdd(aSX3Struct, {{|cAlias, cDC| __aCTBA420[POS_TIPSLD]},  "CVX_TPSALD"})
			aAdd(aSX3Struct, {{|cAlias, cDC| (cAlias)->CONTA},         "CVX_NIV01"})
			aAdd(aSX3Struct, {{|cAlias, cDC| ""}, "FILLER", "FILLER", "C", 20, 0})
			aAdd(aSX3Struct, {{|cAlias, cDC| ""}, "FILLER", "FILLER", "C", 20, 0})
			aAdd(aSX3Struct, {{|cAlias, cDC| ""}, "FILLER", "FILLER", "C", 20, 0})
			aAdd(aSX3Struct, {{|cAlias, cDC| abs((cAlias)->SALDOATU)}, "CVX_SLDDEB"})
		Else
			aAdd(aSX3Struct, {{|cAlias, cDC| (cAlias)->TPSALDO},       "CVX_TPSALD"})
			aAdd(aSX3Struct, {{|cAlias, cDC| (cAlias)->CONTA},         "CVX_NIV01"})
			aAdd(aSX3Struct, {{|cAlias, cDC| (cAlias)->CUSTO},         "CVX_NIV02"})
			aAdd(aSX3Struct, {{|cAlias, cDC| (cAlias)->ITEM},          "CVX_NIV03"})
			aAdd(aSX3Struct, {{|cAlias, cDC| (cAlias)->CLVL},          "CVX_NIV04"})
			aAdd(aSX3Struct, {{|cAlias, cDC| abs((cAlias)->ATUSLD)},   "CVX_SLDCRD"})
		Endif

		// Se o cubo não estiver ligado, não irá gerar informações das contas adicionais.
		If lCubo .AND. !lGerPlan
			For nX := 1 to Len(aEntidades)
				If aEntidades[nX][1]
					cX := StrZero(nX + 4, 2)
					aAdd(aSX3Struct, {&("{|cAlias, cDC| (cAlias)->ENT" + cX + "}"), "CVX_NIV" + cX})
				Else
					aAdd(aSX3Struct, {{|cAlias, cDC| ""}, "FILLER", "FILLER", "C", 20, 0})
				Endif
			Next nX
		Else
			aAdd(aSX3Struct, {{|cAlias, cDC| ""}, "FILLER", "FILLER", "C", 20, 0})
			aAdd(aSX3Struct, {{|cAlias, cDC| ""}, "FILLER", "FILLER", "C", 20, 0})
			aAdd(aSX3Struct, {{|cAlias, cDC| ""}, "FILLER", "FILLER", "C", 20, 0})
			aAdd(aSX3Struct, {{|cAlias, cDC| ""}, "FILLER", "FILLER", "C", 20, 0})
			aAdd(aSX3Struct, {{|cAlias, cDC| ""}, "FILLER", "FILLER", "C", 20, 0})
		Endif
		aAdd(aSX3Struct, {{|cAlias, cDC, cHist| cHist}, "CT2_HIST", FWX3Titulo("CT2_HIST"), "C", 250, 0})
	Endif

	For nX := 1 to Len(aSX3Struct)
		If len(aSX3Struct[nX]) = 2
			cField  := aSX3Struct[nX, 2]
			aTamSX3 := TamSX3(cField)
			If aTamSX3[3] = "D"
				aTamSX3[1] := 10  // A rotina retorna data no formato DD/MM/AAAA (10 caracteres).
			Endif
			aSX3Struct[nX] := {aSX3Struct[nX, 1], cField, FWX3Titulo(cField), aTamSX3[3], aTamSX3[1], aTamSX3[2]}
		Endif
	Next nX

	RestArea(aSX3Area)
	RestArea(aArea)
Endif

If ExistBlock("CTB420SX3")
	aPEStruct := ExecBlock("CTB420SX3",.F.,.F.,{aClone(aSX3Struct)})
	If ValType(aPEStruct) == "A"
		If Len(aPEStruct) != Len(aSX3Struct)
			lPEValid := .F.
			cPEError += CRLF + "Estrutura Original: "+Alltrim(Str(Len(aSX3Struct)))+" colunas "+CRLF+"Estrutura PE: "+Alltrim(Str(Len(aPEStruct)))+" colunas"
		Else
			For nX := 1 to Len(aPEStruct)
				If aPEStruct[nX][5] < aSX3Struct[nX][5]
					lPEValid := .F.
					cPEError += CRLF + aPEStruct[nX][2] + " => tamanho mínimo "+Alltrim(Str(aSX3Struct[nX][5]))+" / tamanho PE "+Alltrim(Str(aPEStruct[nX][5]))
				EndIf
			Next nX
		EndIf
		If lPEValid
			aSX3Struct := aPEStruct
		Else
			Help(,,'CTB420STRUCT',,STR0041+cPEError,1,0)
		EndIf
	Endif
Endif

Return aClone(aSX3Struct)
