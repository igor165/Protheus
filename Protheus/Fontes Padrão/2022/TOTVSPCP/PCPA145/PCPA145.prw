#INCLUDE "TOTVS.CH"
#INCLUDE "PCPA145.ch"
#INCLUDE "PCPA145DEF.ch"

/*/{Protheus.doc} PCPA145
Geração dos documentos (SC2/SC1/SC7/SD4/SB2) de acordo com o
resultado do processamento do MRP.

@type  Function
@author lucas.franca
@since 12/11/2019
@version P12.1.27
@param 01 - cTicket   , Character, Ticket de processamento do MRP para geração dos documentos
@param 02 - aParams   , Array    , Array com os parâmetros utilizados no processamento do MRP.
@param 03 - lAutomacao, Logico   , Indica se a execucao e proveniente de automacao
@param 04 - cErrorUID , character, codigo identificador do controle de erros multi-thread
@param 05 - cCodUsr   , Character, Código do usuário que está executando a rotina
@param 06 - oPeriodsSC, Object   , Objeto com as datas e tipo do documento que devem gerar SCs
@param 07 - oPeriodsOP, Object   , Objeto com as datas e tipo do documento que devem gerar OPs
@param 08 - cOpIniNum , Character, Número inicial da OP
@return Nil
/*/
Function PCPA145(cTicket, aParams, lAutomacao, cErrorUID, cCodUsr, oPeriodsSC, oPeriodsOP, cOpIniNum)
	Local nStart    := MicroSeconds()
	Local nStatus   := 0
	Local oProcesso := Nil
	Local oPCPError := PCPMultiThreadError():New(cErrorUID, .F.)

	Default cCodUsr    := RetCodUsr()
	Default lAutomacao := .F.

	PutGlbValue(cTicket + "UIDPRG_PCPA145","INI")
	oProcesso := ProcessaDocumentos():New(cTicket, /*02*/, aParams, cCodUsr, lAutomacao, cErrorUID, oPeriodsSC, oPeriodsOP, cOpIniNum)
	nStatus   := oProcesso:processar()

	If oPCPError:possuiErro()
		PutGlbValue("P145ERROR", "ERRO")
		If oPCPError:lock("P145ERRORLOCK")
			// Verificação adicional para ver se o log erro já não foi gravado na thread do PCPA712
			If !Empty(GetGlbValue("P145ERROR"))
				GravaCV8("4", GetGlbValue("PCPA145PROCCV8"), /*cMsg*/, oPCPError:getcError(3), "", "", NIL, GetGlbValue("PCPA145PROCIDCV8"), cFilAnt)
				ClearGlbValue("P145ERROR")
				oPCPError:unlock("P145ERRORLOCK")
			EndIf
		EndIf
	EndIf

	oProcesso:Destroy()
	FreeObj(oProcesso)

	//Ao finalizar a geração dos documentos, atualiza o status da tabela HW3 para Gerado.
	P145AtuSta(cTicket, nStatus)

	ProcessaDocumentos():msgLog(STR0005 + cValToChar(MicroSeconds()-nStart), "2")  //"TERMINO DO PROCESSAMENTO DA GERACAO DE DOCUMENTOS. TEMPO TOTAL: "
	PutGlbValue("P145MAIN", "FIM")
	P145EndLog()
Return Nil

/*/{Protheus.doc} ProcessaDocumentos
Classe com as regras para geração dos documentos do MRP.

@author lucas.franca
@since 12/11/2019
@version P12.1.27
/*/
CLASS ProcessaDocumentos FROM LongClassName

	DATA aIntegra     AS Array
	DATA cCodUsr      AS Character
	DATA cErrorUID    AS Character
	DATA cIncOP       AS Character
	DATA cIncSC       AS Character
	DATA cNumIniOP    AS Character
	DATA cTicket      AS Character
	DATA cTipoOP      AS Character
	DATA cUIDGeraAE   AS Character
	DATA cUIDGlobal   AS Character
	DATA cUIDIntEmp   AS Character
	DATA cUIDIntOP    AS Character
	DATA cUIDParams   AS Character
	DATA cUIDRasEntr  AS Character
	DATA cThrGeraAE   AS Character
	DATA cThrJobs     AS Character
	DATA cThrSaldo    AS Character
	DATA cThrSaldoJob AS Character
	DATA cThrTransf   AS Character
	DATA cUIDLockSD4  AS Character
	DATA cUserName    AS Character
	DATA lCopiado     AS Logic
	DATA lOPAglutina  AS Logic
	DATA lDemOPAgl    AS Logic
	DATA lSCAglutina  AS Logic
	DATA lDemSCAgl    AS Logic 
	DATA lIntegraOP   AS Logic
	DATA lSugEmpenho  AS Logic
	DATA lDeTerceiros AS Logic
	DATA lEmTerceiros AS Logic
	DATA lUsaME       AS Logic
	DATA lAutomacao   AS Logic
	DATA lPConvUm     AS Logic
	DATA lFiltraData  AS Logic 
	DATA nGravOP      AS Numeric
	DATA nThrGeraAE   AS Numeric
	DATA nThrTransf   AS Numeric
	DATA nThrJobs     AS Numeric
	DATA nThrSaldo    AS Numeric
	DATA nThrSaldoJob AS Numeric
	DATA nToler1UM    AS Numeric
	DATA nToler2UM    AS Numeric
	DATA oCacheLoc    AS Object
	DATA oDtsGeraSC   AS Object
	DATA oDtsGeraOP   AS Object
	DATA oLocProc     AS Object

	METHOD New(cTicket, lCopia, aParams, cCodUsr, lAutomacao, cErrorUID, oPeriodsSC, oPeriodsOP, cOpIniNum) CONSTRUCTOR
	METHOD Destroy()

	METHOD addEmpenho(aEmpenho, nRecno)
	METHOD aguardaGeraAE()
	METHOD aguardaInicioIntOP(oPCPError)
	METHOD aguardaNivel()
	METHOD aguardaSaldos()
	METHOD aguardaTransferencia(oPCPError)
	METHOD atualizaSaldo(cProduto, cLocal, cNivel, nQtd, nTipo, lPrevisto, cFilProc)
	METHOD atualizaProdutoXNivel(cProduto, cNivel, cFilProc)
	METHOD atualizaDeParaDocumentoProduto(cDocMRP, cDocProt, cFilProc)
	METHOD clearCount(cName)
	METHOD ConvUm(cCod, nQtd1, nQtd2, nUnid)
	METHOD criaSB2(cFilAux, cProduto, cLocal, lPosiciona)
	METHOD criarSecaoGlobal()
	METHOD dataValida(dData, cDoc)
	METHOD delSaldoProd(cNivel, cFilProc)
	METHOD docForaDeData(cFilProc, cDocMRP)
	METHOD executaIntegracoes()
	METHOD existEmpenho(aEmpenho, nRecno)
	METHOD getGeraDocAglutinado(cNivel, lDemanda)
	METHOD getGravOP()
	METHOD getLocProcesso()
	METHOD getProdutoNivel(cNivel, lRet, cFilProc)
	METHOD getSaldosProduto(cProduto, lRet, cFilProc)
	METHOD getDocumentoDePara(cDocMRP, cFilProc)
	METHOD getDocsAglutinados(cDocMRP, cProduto)
	METHOD getTipoDocumento(dData, cDoc)
	METHOD geraDocumentoFirme()
	METHOD getCount(cName)
	METHOD getProgress()
	METHOD getDocUni(cName, cFilProc)
	METHOD getDadosOP(cFilAux, cNumOP)
	METHOD getOperacaoComp(cFilAux, cProdPai, cRoteiro, cComp, cTRT)
	METHOD getUserName()
	METHOD montaJSData(aDataGera)
	METHOD incCount(cName)
	METHOD initCount(cName, nValue)
	METHOD incDocUni(cName, cFilProc)
	METHOD initDocUni(cName, cFilProc)
	METHOD processar()
	METHOD processaPontoDeEntrada()
	METHOD processaSaldos(cNivel, cFilProc)
	METHOD setaUsaNumOpPadrao(cFilAux, lUsaNumPad)
	METHOD setDadosOP(cFilAux, cNumOP, cProduto, cRoteiro, dInicio)
	METHOD totalTransferencias()
	METHOD updStatusRastreio(cStatus, cDocGerado, cTipDocERP, nRecno)
	METHOD usaNumOpPadrao(cFilAux)
	METHOD utilizaMultiEmpresa()

	Static METHOD msgLog(cMsg, cType)

ENDCLASS

/*/{Protheus.doc} New
Método construtor da classe de geração de documentos do MRP

@type  Method
@author lucas.franca
@since 12/11/2019
@version P12.1.27
@param 01 - cTicket   , Character, Ticket de processamento do MRP para geração dos documentos
@param 02 - lCopia    , Lógico   , Identifica que está instanciando este objeto nas threads filhas, apenas para consumir os métodos.
@param 03 - aParams   , Array    , Array com os parâmetros utilizados no processamento do MRP.
@param 04 - cCodUsr   , Character, Código do usuário logado no sistema.
@param 05 - lAutomacao, Logico   , Indica se a execucao e proveniente de automacao
@param 06 - cErrorUID , Character, Código identificador do controle de erros multi-thread
@param 07 - oPeriodsSC, Object   , Objeto com as datas e tipo do documento que devem gerar SCs
@param 08 - oPeriodsOP, Object   , Objeto com as datas e tipo do documento que devem gerar OPs
@param 09 - cOpIniNum , Character, Número inicial da OP
@return Self
/*/
METHOD New(cTicket, lCopia, aParams, cCodUsr, lAutomacao, cErrorUID, oPeriodsSC, oPeriodsOP, cOpIniNum) CLASS ProcessaDocumentos
	Local cIdProcCV8 := ""
	Local lAmbPrep   := .F.
	Local lIntegra   := .F.
	Local nPos       := 0

	Default cCodUsr    := ""
	Default lCopia     := .F.
	Default lAutomacao := .F.

	Self:cCodUsr      := cCodUsr
	Self:cErrorUID    := cErrorUID
	Self:cIncOP       := "2"
	Self:cIncSC       := "2"
	Self:cNumIniOP    := ""
	Self:cTicket      := cTicket
	Self:cTipoOP      := "1"
	Self:cThrGeraAE   := Self:cTicket + "GERAAE"
	Self:cThrJobs     := Self:cTicket + "PROCDOC"
	Self:cThrSaldo    := Self:cTicket + "STOCK"
	Self:cThrSaldoJob := Self:cTicket + "STOCKJOBS"
	Self:cThrTransf   := Self:cTicket + "TRANSF"
	Self:cUIDGeraAE   := Self:cTicket + "PEDCOMP"
	Self:cUIDRasEntr  := Self:cTicket + "RASTRO_DEM"
	Self:cUIDGlobal   := Self:cThrJobs + "DADOS"
	Self:cUIDIntEmp   := Self:cThrJobs + "INTEMP"
	Self:cUIDIntOP    := Self:cThrJobs + "INTOP"
	Self:cUIDParams   := Self:cThrJobs + "PARAMS"
	Self:cUIDLockSD4  := "LOCK_SD4"
	Self:cUserName    := Nil
	Self:lCopiado     := lCopia
	Self:lIntegraOP   := .F.
	Self:lOPAglutina  := .F.
	Self:lDemOPAgl    := .F.
	Self:lSCAglutina  := .F.
	Self:lDemSCAgl    := .F.
	Self:lFiltraData  := .F.
	Self:lAutomacao   := lAutomacao
	Self:lUsaME       := Nil
	Self:aIntegra     := Array(INTEGRA_TAMANHO)
	Self:nGravOP      := Nil

	If Type("cFilAnt") != "U" .And. !Empty(cFilAnt)
		lAmbPrep := .T.
	EndIf

	If Self:lAutomacao
		Self:nThrGeraAE   := 1
		Self:nThrJobs     := 1
		Self:nThrSaldo    := 1
		Self:nThrSaldoJob := 1
	Else
		Self:nThrGeraAE   := 1
		Self:nThrJobs     := 8
		Self:nThrSaldo    := 2
		Self:nThrSaldoJob := 4
	EndIf

	Self:nThrTransf := 1
	Self:nToler1UM := Nil
	Self:nToler2UM := Nil
	Self:lPConvUm  := Nil
	Self:oCacheLoc := JsonObject():New()
	Self:oLocProc  := JsonObject():New()

	If !lCopia
		//Salva o array de parâmetros em uma variável global para recuperar nas threads filhas.
		If aParams != Nil
			//Verifica parâmetro de integração de ordens para adicionar no array aParams
			lIntegra := Nil
			Ma650MrpOn(@lIntegra)
			aAdd(aParams, {0, {"INTEGRAOPONLINE", lIntegra, "INTEGRAOPONLINE", lIntegra}})

			lIntegra := .F.
			lIntegra := PCPIntgPPI()
			aAdd(aParams, {0, {"INTEGRAOPPPI", lIntegra, "INTEGRAOPPPI", lIntegra}})

			lIntegra := ExisteSFC("SC2")
			aAdd(aParams, {0, {"INTEGRAOPSFC", lIntegra, "INTEGRAOPSFC", lIntegra}})

			lIntegra := IntQIP()
			aAdd(aParams, {0, {"INTEGRAOPQIP", lIntegra, "INTEGRAOPQIP", lIntegra}})

			If oPeriodsSC != Nil .And. oPeriodsOP != Nil
				Self:lFiltraData := .T.

				aAdd(aParams, {0, {"DATASGERACAOSC", oPeriodsSC, "DATASGERACAOSC", oPeriodsSC}})
				aAdd(aParams, {0, {"DATASGERACAOOP", oPeriodsOP, "DATASGERACAOOP", oPeriodsOP}})

				//Grava na tabela HW1 os parâmetros de data informados para geração de documentos.
				MrpAddPar(Self:cTicket, "scGenerationDate", oPeriodsSC:ToJson())
				MrpAddPar(Self:cTicket, "opGenerationDate", oPeriodsOP:ToJson())
			EndIf 
			aAdd(aParams, {0, {"FILTRADATAS" , Self:lFiltraData  , "FILTRADATAS" , Self:lFiltraData}})

			//Verifica se foi informado o campo de número inicial da OP
			If cOpIniNum != Nil
				Self:cNumIniOP := Alltrim(cOpIniNum)
				aAdd(aParams, {0, {"NUMEROINICIALOP", Self:cNumIniOP, "NUMEROINICIALOP", Self:cNumIniOP}})
			EndIf

			PutGlbVars(Self:cUIDParams, aParams)
			PutGlbVars(Self:cUIDParams+"AUTO", Self:lAutomacao)
		EndIf

		//Abre as threads que serão utilizadas no processamento (JOBS)
		PCPIPCStart(Self:cThrJobs, Self:nThrJobs, 0, cEmpAnt, cFilAnt, cErrorUID) //Inicializa as Threads

		//Abre as threads que serão utilizadas no processamento (Estoques)
		PCPIPCStart(Self:cThrSaldo   , Self:nThrSaldo   , 0 , , cErrorUID) //Inicializa as Threads (Sem conexão com banco. Thread MASTER do processamento de saldos)
		PCPIPCStart(Self:cThrSaldoJob, Self:nThrSaldoJob, 0, cEmpAnt, cFilAnt, cErrorUID) //Inicializa as Threads filhas para o processamento dos saldos.

		//Inicia a Threads que será utilizada no processamento da geração dos pedidos de compras
		PCPIPCStart(Self:cThrGeraAE, Self:nThrGeraAE, 0, cEmpAnt, cFilAnt, cErrorUID)

		//Inicia a Threads que será utilizada no processamento da geração de transferências
		PCPIPCStart(Self:cThrTransf, Self:nThrTransf, 0, cEmpAnt, cFilAnt, cErrorUID)

		//Ativa a Thread para geração dos pedidos de compra
		PCPIPCGO(Self:cThrGeraAE, .F., "PCPA145PC", Self:cTicket, Self:cCodUsr)

		//Cria as tabelas temporárias em memória para utilização no processamento.
		Self:criarSecaoGlobal()

		PutGlbValue("PCPA145PROCCV8", "PCPA145 - Ticket: " + Self:cTicket)
		ProcLogIni({}, GetGlbValue("PCPA145PROCCV8"), Nil, @cIdProcCV8)
		PutGlbValue("PCPA145PROCIDCV8", cIdProcCV8)
		GravaCV8("1", GetGlbValue("PCPA145PROCCV8"), STR0044, /*cDetalhes*/, "", "", NIL, cIdProcCV8, cFilAnt) // "INICIO DA GERAÇÃO DE DOCUMENTOS"

	Else
		GetGlbVars(Self:cUIDParams, @aParams)
		GetGlbVars(Self:cUIDParams+"AUTO", @Self:lAutomacao)
	EndIf

	If FindFunction("PCPDocUser") 
		If lAmbPrep
			PCPDocUser(Self:cCodUsr)
		EndIf
	EndIf

	If aParams == Nil
		aParams := {}
		Self:msgLog(STR0006)  //"Parametros do MRP nao recebidos. Gerando documentos com parametros default."
	EndIf

	//Recupera o parâmetro para indicar se aplica filtro de datas na geração dos documentos
	nPos := aScan(aParams, {|x| AllTrim(x[PARAM_DATA][PARAM_POS_CODE]) == "FILTRADATAS"})
	If nPos > 0
		Self:lFiltraData := aParams[nPos][PARAM_DATA][PARAM_POS_VALUE]
	EndIf

	//Recupera o parâmetro das datas que devem ser geradas e tipo de documento por data
	If Self:lFiltraData
		nPos := aScan(aParams, {|x| AllTrim(x[PARAM_DATA][PARAM_POS_CODE]) == "DATASGERACAOSC"})
		If nPos > 0
			Self:oDtsGeraSC := aParams[nPos][PARAM_DATA][PARAM_POS_VALUE]
		EndIf
		nPos := aScan(aParams, {|x| AllTrim(x[PARAM_DATA][PARAM_POS_CODE]) == "DATASGERACAOOP"})
		If nPos > 0
			Self:oDtsGeraOP := aParams[nPos][PARAM_DATA][PARAM_POS_VALUE]
		EndIf
	EndIf

	//Recupera o parâmetro de número inicial das OPs
	nPos := aScan(aParams, {|x| AllTrim(x[PARAM_DATA][PARAM_POS_CODE]) == "NUMEROINICIALOP"})
	If nPos > 0
		Self:cNumIniOP := Alltrim(aParams[nPos][PARAM_DATA][PARAM_POS_VALUE])
	EndIf
	If lAmbPrep
		Self:usaNumOpPadrao(cFilAnt)
	EndIf

	//Recupera o parâmetro de aglutinação de ordens de produção
	nPos := aScan(aParams, {|x| AllTrim(x[PARAM_DATA][PARAM_POS_CODE]) == "consolidateProductionOrder"})
	If nPos > 0
		If !Empty(aParams[nPos][PARAM_DATA][PARAM_POS_VALUE]) .And. ;
		   AllTrim(aParams[nPos][PARAM_DATA][PARAM_POS_VALUE]) == "1"
			Self:lOPAglutina := .T.
			Self:lDemOPAgl   := .T.
		EndIf

		If !Empty(aParams[nPos][PARAM_DATA][PARAM_POS_VALUE]) .And. ;
		   AllTrim(aParams[nPos][PARAM_DATA][PARAM_POS_VALUE]) == "3"
			Self:lDemOPAgl   := .T.
		EndIf
	EndIf

	//Recupera o parâmetro de aglutinação de solicitações de compra
	nPos := aScan(aParams, {|x| AllTrim(x[PARAM_DATA][PARAM_POS_CODE]) == "consolidatePurchaseRequest"})
	If nPos > 0 
		If !Empty(aParams[nPos][PARAM_DATA][PARAM_POS_VALUE]) .And. ;
		   AllTrim(aParams[nPos][PARAM_DATA][PARAM_POS_VALUE]) == "1"
			Self:lSCAglutina := .T.
			Self:lDemSCAgl   := .T.
		EndIf

		If !Empty(aParams[nPos][PARAM_DATA][PARAM_POS_VALUE]) .And. ;
		   AllTrim(aParams[nPos][PARAM_DATA][PARAM_POS_VALUE]) == "3"
			Self:lDemSCAgl   := .T.
		EndIf

	EndIf

	//Recupera o parâmetro de incremento da ordem de produção
	nPos := aScan(aParams, {|x| AllTrim(x[PARAM_DATA][PARAM_POS_CODE]) == "productionOrderNumber"})
	If nPos > 0
		If Empty(aParams[nPos][PARAM_DATA][PARAM_POS_VALUE])
			Self:cIncOP := "2"
		Else
			Self:cIncOP := Alltrim(aParams[nPos][PARAM_DATA][PARAM_POS_VALUE])
		EndIf
	EndIf

	//Recupera o parâmetro de incremento da solicitação de compra
	nPos := aScan(aParams, {|x| AllTrim(x[PARAM_DATA][PARAM_POS_CODE]) == "purchaseRequestNumber"})
	If nPos > 0
		If Empty(aParams[nPos][PARAM_DATA][PARAM_POS_VALUE])
			Self:cIncSC := "2"
		Else
			Self:cIncSC := Alltrim(aParams[nPos][PARAM_DATA][PARAM_POS_VALUE])
		EndIf
	EndIf

	//Recupera o parâmetro de tipo do documento
	nPos := aScan(aParams, {|x| AllTrim(x[PARAM_DATA][PARAM_POS_CODE]) == "productionOrderType"})
	If nPos > 0
		If Empty(aParams[nPos][PARAM_DATA][PARAM_POS_VALUE])
			Self:cTipoOP := "1"
		Else
			Self:cTipoOP := Alltrim(aParams[nPos][PARAM_DATA][PARAM_POS_VALUE])
		EndIf
	EndIf

	//Recupera o parâmetro de integração de ordens de produção
	nPos := aScan(aParams, {|x| AllTrim(x[PARAM_DATA][PARAM_POS_CODE]) == "INTEGRAOPONLINE"})
	If nPos > 0 .And. aParams[nPos][PARAM_DATA][PARAM_POS_VALUE] != Nil
		Self:aIntegra[INTEGRA_OP_MRP] := aParams[nPos][PARAM_DATA][PARAM_POS_VALUE]
	EndIf

	//Recupera o parâmetro de integração de ordens de produção
	nPos := aScan(aParams, {|x| AllTrim(x[PARAM_DATA][PARAM_POS_CODE]) == "INTEGRAOPPPI"})
	If nPos > 0 .And. aParams[nPos][PARAM_DATA][PARAM_POS_VALUE] != Nil
		Self:aIntegra[INTEGRA_OP_PPI] := aParams[nPos][PARAM_DATA][PARAM_POS_VALUE]
	EndIf

	//Recupera o parâmetro de integração de ordens de produção
	If Self:geraDocumentoFirme()
		nPos := aScan(aParams, {|x| AllTrim(x[PARAM_DATA][PARAM_POS_CODE]) == "INTEGRAOPSFC"})
		If nPos > 0 .And. aParams[nPos][PARAM_DATA][PARAM_POS_VALUE] != Nil
			Self:aIntegra[INTEGRA_OP_SFC] := aParams[nPos][PARAM_DATA][PARAM_POS_VALUE]
		EndIf
	Else
		Self:aIntegra[INTEGRA_OP_SFC] := .F.
	EndIf

	Self:aIntegra[INTEGRA_OP_QIP] := .F.
	If Self:geraDocumentoFirme()
		nPos := aScan(aParams, {|x| AllTrim(x[PARAM_DATA][PARAM_POS_CODE]) == "INTEGRAOPQIP"})
		If nPos > 0 .And. aParams[nPos][PARAM_DATA][PARAM_POS_VALUE] != Nil
			Self:aIntegra[INTEGRA_OP_QIP] := aParams[nPos][PARAM_DATA][PARAM_POS_VALUE]
		EndIf
	EndIf
	
	If Self:aIntegra[INTEGRA_OP_MRP] .Or. Self:aIntegra[INTEGRA_OP_PPI] .Or. Self:aIntegra[INTEGRA_OP_SFC] .Or. Self:aIntegra[INTEGRA_OP_QIP]
		Self:lIntegraOP := .T.
	EndIf

	//Recupera o parâmetro de sugestao de lote e endereco no empenho
	nPos := aScan(aParams, {|x| AllTrim(x[PARAM_DATA][PARAM_POS_CODE]) == "allocationSuggestion"})
	If nPos > 0
		Self:lSugEmpenho := AllTrim(aParams[nPos][PARAM_DATA][PARAM_POS_VALUE]) == "1"
	Else
		Self:lSugEmpenho := .F.
	EndIf

	//Recupera o parâmetro DE Terceiros
	nPos := aScan(aParams, {|x| AllTrim(x[PARAM_DATA][PARAM_POS_CODE]) == "consignedIn"})
	If nPos > 0
		Self:lDeTerceiros := AllTrim(aParams[nPos][PARAM_DATA][PARAM_POS_VALUE]) == "1"
	Else
		Self:lDeTerceiros := .F.
	EndIf

	//Recupera o parâmetro EM Terceiros
	nPos := aScan(aParams, {|x| AllTrim(x[PARAM_DATA][PARAM_POS_CODE]) == "consignedOut"})
	If nPos > 0
		Self:lEmTerceiros := AllTrim(aParams[nPos][PARAM_DATA][PARAM_POS_VALUE]) == "1"
	Else
		Self:lEmTerceiros := .F.
	EndIf

Return Self

/*/{Protheus.doc} Destroy
Método destrutor da classe de geração de documentos do MRP

@type  Method
@author lucas.franca
@since 12/11/2019
@version P12.1.27
@return Nil
/*/
METHOD Destroy() CLASS ProcessaDocumentos

	//Somente a instância da thread MASTER deve finalizar as threads e limpar a memória.
	If !Self:lCopiado

		//Finaliza as threads utilizadas no processamento
		PCPIPCFinish(Self:cThrJobs    , 100, Self:nThrJobs)
		PCPIPCFinish(Self:cThrSaldo   , 100, Self:nThrSaldo)
		PCPIPCFinish(Self:cThrSaldoJob, 100, Self:nThrSaldoJob)
		PCPIPCFinish(Self:cThrGeraAE  , 100, Self:nThrGeraAE)
		PCPIPCFinish(Self:cThrTransf  , 100, Self:nThrTransf)

		//Limpa da memória as variáveis globais
		VarClean(Self:cUIDGeraAE)
		VarClean(Self:cUIDGlobal)
		VarClean(Self:cUIDIntEmp)
		VarClean(Self:cUIDIntOP)
		VarClean(Self:cUIDLockSD4)
		VarClean(Self:cUIDRasEntr)
		ClearGlbValue(Self:cUIDParams)
	EndIf

	FreeObj(Self:oCacheLoc)
	FreeObj(Self:oLocProc)

Return Nil

/*/{Protheus.doc} criarSecaoGlobal
Cria a seção de variáveis globais que será utilizada no processamento

@type  Method
@author lucas.franca
@since 12/11/2019
@version P12.1.27
@return Nil
/*/
METHOD criarSecaoGlobal() CLASS ProcessaDocumentos

	If !VarSetUID(Self:cUIDGeraAE)
		Self:msgLog(STR0007 + Self:cUIDGeraAE)  //"Erro na criação da seção de variáveis globais."
	EndIf

	If !VarSetUID(Self:cUIDGlobal)
		Self:msgLog(STR0007 + Self:cUIDGlobal)  //"Erro na criação da seção de variáveis globais."
	EndIf

	If !VarSetUID(Self:cUIDIntEmp)
		Self:msgLog(STR0007 + Self:cUIDIntEmp)  //"Erro na criação da seção de variáveis globais."
	EndIf

	If !VarSetUID(Self:cUIDIntOP)
		Self:msgLog(STR0007 + Self:cUIDIntOP)  //"Erro na criação da seção de variáveis globais."
	EndIf

	If !VarSetUID(Self:cUIDLockSD4)
		Self:msgLog(STR0007 + Self:cUIDLockSD4)  //"Erro na criação da seção de variáveis globais."
	EndIf

	If !VarSetUID(Self:cUIDRasEntr)
		Self:msgLog(STR0007 + Self:cUIDRasEntr)  //"Erro na criação da seção de variáveis globais."
	EndIf

Return Nil

/*/{Protheus.doc} processar
Método que delega os registros para serem processados nas threads filhas.

@type  Method
@author lucas.franca
@since 12/11/2019
@version P12.1.27
@return nStatus, Numeric, Status do processamento. 0=Nenhum documento gerado;
                                                   1=Documentos gerados com sucesso;
                                                   2=Documentos gerados, mas ocorreram erros.
/*/
METHOD processar() CLASS ProcessaDocumentos
	Local aRegistro   := Array(RASTREIO_TAMANHO)
	Local aRegs       := {}
	Local cChavePrd   := ""
	Local cNivAtu     := ""
	Local cFilAtu     := ""
	Local cFilBkp     := cFilAnt
	Local lGerouPC    := .F.
	Local lProcessar  := .T.
	Local lRet        := .T.
	Local lUsaME      := .F.
	Local nDelegados  := 0
	Local nTotal      := 0
	Local nPos        := 1
	Local nTamRegs    := 0
	Local nTamPrd     := GetSX3Cache("B1_COD"   , "X3_TAMANHO")
	Local nTamLoc     := GetSX3Cache("B1_LOCPAD", "X3_TAMANHO")
	Local nTamTrt     := GetSX3Cache("G1_TRT"   , "X3_TAMANHO")
	Local nTamFil     := FwSizeFilial()
	Local nTempoNiv   := 0
	Local nStatus     := 0
	Local oJson       := Nil
	Local oPCPError   := PCPMultiThreadError():New(Self:cErrorUID, .F.)
	Local oPCPLock    := PCPLockControl():New()
	Local oNumOpUni   := JsonObject():New()
	Local oNumScUni   := JsonObject():New()
	Local oInitDocs   := JsonObject():New()
	Local b151Recove := {|| oPCPLock:unlock("MRP_MEMORIA", "PCPA145", Self:cTicket) }

	Self:initCount(Self:cThrJobs + "_Delegados")
	Self:initCount(Self:cThrJobs + "_Concluidos")
	Self:initCount(Self:cThrSaldoJob + "_Delegados")
	Self:initCount(Self:cThrSaldoJob + "_Concluidos")
	Self:initCount(Self:cThrSaldo + "_Delegados")
	Self:initCount(Self:cThrSaldo + "_Concluidos")

	//Inicializa contadores de controle das transferências.
	Self:initCount("TRANSF_FIM"       ) //Indicador de término do processo
	Self:initCount("TRANSF_ERROS"     ) //Contador de registros processados com erro
	Self:initCount("TRANSF_PROCESSADO") //Contador de registros processados (geral)
	Self:initCount("TRANSF_TOTAL", -1 ) //Total de registros para processar.

	// Contadores de contrele dos PC
	Self:initCount("ENTRADAPC")
	Self:initCount("SAIDAPC")

	//Contador de controle de OP - para envio de métrica
	Self:initCount("METRICOP")

	//Ativa a Thread para geração das transferências
	PCPIPCGO(Self:cThrTransf, .F., "PCPA145Trf", Self:cTicket, Self:cCodUsr, Self:cErrorUID)

	While lProcessar
		If oPCPError:possuiErro()
			Exit
		EndIf

		//Aguarda as threads filhas terminarem o processamento
		Self:aguardaNivel()
		Self:aguardaSaldos()

		//Restaura filial original
		If cFilAnt != cFilBkp
			cFilAnt := cFilBkp
		EndIf

		nPos  := 1
		aRegs := MrpGetHWC(Self:cTicket, .T.)

		If aRegs[1] == .F.
			nTamRegs := 0
		Else
			oJson    := aRegs[2]
			nTamRegs := Len(oJson["items"])

			//Carrega flag de utilização do multi-empresas.
			lUsaME := oJson["useMultiBranches"]
			VarSetX(Self:cUIDGlobal, "UTILIZA_MULTI_EMP", lUsaME)

			If nTotal == 0
				If !Self:initCount(TOTAL_PENDENTES, nTamRegs)
					Self:msgLog(STR0020) //"Erro ao Gravar o total de registros pendentes em memória."
				EndIf
				Self:initCount(CONTADOR_GERADOS)
			EndIf
		EndIf

		//Controle de registros marcados para reiniciar.
		nTotal := 0
		Self:initCount(CONTADOR_REINICIADOS)

		//Armazena o primeiro nível
		If nTamRegs > 0
			nStatus := 1

			cNivAtu := oJson["items"][1]["level"]
			cFilAtu := PadR(oJson["items"][1]["branchId"], nTamFil)

			//Atualiza a filial atual para busca das informações no banco de dados.
			If cFilAnt != cFilAtu
				cFilAnt := cFilAtu
			EndIf

			If oInitDocs[cFilAnt] == Nil
				oInitDocs[cFilAnt] := .T.
				Self:initDocUni("C2_NUM", cFilAnt)
			EndIf

			Self:msgLog(STR0023 + cFilAtu)  //"Processando filial: "

			Self:msgLog(STR0008 + cNivAtu)  //"Processando nível: "
			nTempoNiv := MicroSeconds()

			//Pega numeração da OP que será usada para geração de todos os registros
			If Self:cIncOP == "1" .And. Empty(oNumOpUni[cFilAtu]) .And. cNivAtu != "99"
				oNumOpUni[cFilAtu] := Self:incDocUni("C2_NUM", cFilAtu)
			EndIf
			//Pega numeração da SC que será usada para geração de todos os registros
			If Self:cIncSC == "1" .And. Empty(oNumScUni[cFilAtu])
				Self:initDocUni("C1_NUM", cFilAtu)
				oNumScUni[cFilAtu] := Self:incDocUni("C1_NUM", cFilAtu)
			EndIf
		Else
			//Se a query não retornar registros, significa que todos os registros pendentes foram processados.
			//Irá sair do loop.
			lProcessar := .F.
		EndIf

		While nPos <= nTamRegs

			If oPCPError:possuiErro()
				lProcessar := .F.
				Exit
			EndIf

			nTotal++

			//Verifica troca de filial no processamento
			If cFilAtu != PadR(oJson["items"][nPos]["branchId"], nTamFil)
				cFilAtu := PadR(oJson["items"][nPos]["branchId"], nTamFil)
				Self:msgLog(STR0023 + cFilAtu)  //"Processando filial: "

				//Atualiza a filial atual para busca das informações no banco de dados.
				If cFilAnt != cFilAtu
					cFilAnt := cFilAtu
				EndIf

				If oInitDocs[cFilAnt] == Nil
					oInitDocs[cFilAnt] := .T.
					Self:initDocUni("C2_NUM", cFilAnt)
				EndIf

				//Pega numeração da OP que será usada para geração de todos os registros
				If Self:cIncOP == "1" .And. Empty(oNumOpUni[cFilAtu]) .And. cNivAtu != "99"
					oNumOpUni[cFilAtu] := Self:incDocUni("C2_NUM", cFilAtu)
				EndIf
				//Pega numeração da SC que será usada para geração de todos os registros
				If Self:cIncSC == "1" .And. Empty(oNumScUni[cFilAtu])
					Self:initDocUni("C1_NUM", cFilAtu)
					oNumScUni[cFilAtu] := Self:incDocUni("C1_NUM", cFilAtu)
				EndIf
			EndIf

			aRegistro[RASTREIO_POS_FILIAL                  ] := cFilAtu
			aRegistro[RASTREIO_POS_PRODUTO                 ] := PadR(oJson["items"][nPos]["componentCode"], nTamPrd)
			aRegistro[RASTREIO_POS_OPC_ID                  ] := oJson["items"][nPos]["optionalId"]
			aRegistro[RASTREIO_POS_TRT                     ] := PadR(oJson["items"][nPos]["sequenceInStructure"], nTamTrt)
			aRegistro[RASTREIO_POS_DATA_ENTREGA            ] := getDate(oJson["items"][nPos]["necessityDate"])
			aRegistro[RASTREIO_POS_DATA_INICIO             ] := getDate(oJson["items"][nPos]["startDate"])
			aRegistro[RASTREIO_POS_TIPODOC                 ] := oJson["items"][nPos]["parentDocumentType"]
			aRegistro[RASTREIO_POS_DOCPAI                  ] := oJson["items"][nPos]["parentDocument"]
			aRegistro[RASTREIO_POS_DOCFILHO                ] := oJson["items"][nPos]["childDocument"]
			aRegistro[RASTREIO_POS_NECES_ORIG              ] := oJson["items"][nPos]["originalNecessity"]
			aRegistro[RASTREIO_POS_SALDO_EST               ] := oJson["items"][nPos]["stockBalanceQuantity"]
			aRegistro[RASTREIO_POS_BAIXA_EST               ] := oJson["items"][nPos]["quantityStockWriteOff"]
			aRegistro[RASTREIO_POS_QTD_SUBST               ] := oJson["items"][nPos]["quantitySubstitution"]
			aRegistro[RASTREIO_POS_EMPENHO                 ] := oJson["items"][nPos]["alocationQuantity"]
			aRegistro[RASTREIO_POS_NECESSIDADE             ] := oJson["items"][nPos]["quantityNecessity"]
			aRegistro[RASTREIO_POS_REVISAO                 ] := oJson["items"][nPos]["structureReview"]
			aRegistro[RASTREIO_POS_ROTEIRO                 ] := oJson["items"][nPos]["routing"]
			aRegistro[RASTREIO_POS_OPERACAO                ] := oJson["items"][nPos]["operation"]
			aRegistro[RASTREIO_POS_ROTEIRO_DOCUMENTO_FILHO ] := oJson["items"][nPos]["routingChildDocument"]
			aRegistro[RASTREIO_POS_SEQUEN                  ] := oJson["items"][nPos]["breakupSequence"]
			aRegistro[RASTREIO_POS_NIVEL                   ] := oJson["items"][nPos]["level"]
			aRegistro[RASTREIO_POS_LOCAL                   ] := PadR(oJson["items"][nPos]["consumptionLocation"], nTamLoc)
			aRegistro[RASTREIO_POS_CHAVE                   ] := oJson["items"][nPos]["recordKey"]
			aRegistro[RASTREIO_POS_CHAVE_SUBST             ] := oJson["items"][nPos]["substitutionKey"]
			aRegistro[RASTREIO_POS_CONTRATO                ] := oJson["items"][nPos]["purchaseContract"]

			If !Empty(oJson["items"][nPos]["recordNumber"])
				aRegistro[RASTREIO_POS_RECNO               ] := oJson["items"][nPos]["recordNumber"]
			Else
				aRegistro[RASTREIO_POS_RECNO               ] := 0
			EndIf
			//Se for nível 99 e configurado para gerar Pedido de Compra, será feito em uma thread separada.
			//A execução dessa thread será feita na função PCPA145PC
			If aRegistro[RASTREIO_POS_NIVEL] == "99" .And. aRegistro[RASTREIO_POS_CONTRATO] == "1"
				cChavePrd := STRZERO(nTotal, 6, 0)

				//Seta variável indicando que a geração do PV será executada
				lGerouPC := VarSetA(Self:cUIDGeraAE, cChavePrd, @aRegistro)
				Self:incCount("ENTRADAPC")
			EndIf

			nDelegados := Self:incCount(Self:cThrJobs + "_Delegados")
			//Delega o registro para processamento em thread filha
			PCPIPCGO(Self:cThrJobs, .F., "PCPA145JOB", Self:cTicket, aRegistro, Self:cCodUsr, oNumScUni[cFilAtu], lGerouPC)

			//Reseta valor da variável
			lGerouPC := .F.

			nPos++

			//Verifica se mudou de nível ou se passou por todos os registros.
			If nPos > nTamRegs .Or. cNivAtu != oJson["items"][nPos]["level"] .Or. cFilAtu != PadR(oJson["items"][nPos]["branchId"], nTamFil)
				//Aguarda as threads filhas terminarem o processamento
				Self:aguardaNivel()

				//Aguarda término da geração das autorizações de entrega
				If cNivAtu == "99"
					Self:aguardaGeraAE()
				EndIf

				//Dispara a atualização dos saldos
				Self:processaSaldos(cNivAtu, cFilAtu)

				If nPos <= nTamRegs
					Self:msgLog(STR0009 + cNivAtu + ": " + cValToChar(MicroSeconds()-nTempoNiv))  //"Tempo do nível "
					//Se existirem mais níveis para processar, atualiza a variável de controle
					cNivAtu := oJson["items"][nPos]["level"]
					Self:msgLog(STR0008 + cNivAtu)  //"Processando nível: "
					nTempoNiv := MicroSeconds()

					//Ao ocorrer uma mudança de filial, aguarda o término da atualização dos estoques antes de iniciar
					//o processamento da próxima filial.
					If cFilAtu != PadR(oJson["items"][nPos]["branchId"], nTamFil)
						Self:aguardaSaldos()
					EndIf
				Else
					Self:msgLog(STR0009 + cNivAtu + ": " + cValToChar(MicroSeconds()-nTempoNiv))  //"Tempo do nível "
					aSize(oJson["items"], 0)
					FreeObj(oJson)
					Exit
				EndIf
			EndIf
		End

		If lProcessar
			//Aguarda as threads de atualização de estoque finalizarem.
			Self:aguardaSaldos()

			If nTotal == Self:getCount(CONTADOR_REINICIADOS)
				lProcessar := .F.
				Self:msgLog(STR0010)  //"TODOS OS REGISTROS PROCESSADOS FORAM MARCADOS PARA REPROCESSAR. PROCESSAMENTO ENCERRADO PARA NÃO ENTRAR EM LOOP."
			EndIf
		EndIf
		aSize(aRegs, 0)
	End

	If !oPCPError:possuiErro() .And. FindFunction("P145GrvRas")
		P145GrvRas(Self)
	EndIf

	//Envia comando para encerrar thread de Autorização de entrega
	lRet := VarSetA(Self:cUIDGeraAE, "EndPurchaseOrder", {})

	//Dispara Sugestao de Lotes e Enderecos
	If !oPCPError:possuiErro() .AND. Self:lSugEmpenho
		PutGlbValue(Self:cTicket + "PCPA151_STATUS","INI")
		oPCPLock:transfer("MRP_MEMORIA", "PCPA145", "PCPA151", Self:cTicket) //Transfere propriedade do lock para rotina PCPA151
		oPCPError:startJob("PCPA151T", getEnvServer(), .F., cEmpAnt, cFilAnt, Self:cTicket, oPCPError:cErrorUID, , , , , , , , , b151Recove)
		While GetGlbValue(Self:cTicket + "PCPA151_STATUS") != "END" .AND. !oPCPError:possuiErro()
			If Empty(GetGlbValue(Self:cTicket + "PCPA151_STATUS"))
				Exit
			EndIf
			Sleep(1000)
		End
	Else
		oPCPLock:unlock("MRP_MEMORIA", "PCPA145", Self:cTicket)
	EndIf

	If Self:lIntegraOP .And. !oPCPError:possuiErro()
		Self:executaIntegracoes()
		nStatus := 3
	EndIf

	If Self:getCount("METRICOP") > 0 
		//Métricas Adicionais - Qtde OPs Auto - ID:manufatura-protheus_qtde-ops-auto_total
		If Findfunction("PCPMETRIC")
			PCPMETRIC("PCPA712", {{"manufatura-protheus_qtde-ops-auto_total", Self:getCount("METRICOP")}}, .T.)
		EndIf
	EndIf	

	//Aguarda o encerramento da geração das transferências
	Self:aguardaTransferencia(@oPCPError)

	If Self:getCount("TRANSF_ERROS") > 0
		nStatus := 2
	EndIf

	PutGlbValue(Self:cTicket + "UIDPRG_PCPA145","END")

	aSize(aRegistro, 0)
	Self:clearCount(CONTADOR_REINICIADOS)
	Self:clearCount(CONTADOR_GERADOS)
	Self:clearCount("ENTRADAPC")
	Self:clearCount("SAIDAPC")
	Self:clearCount("METRICOP")
	FreeObj(oNumOpUni)
	FreeObj(oNumScUni)
	FreeObj(oInitDocs)

	//Restaura filial original
	If cFilAnt != cFilBkp
		cFilAnt := cFilBkp
	EndIf

	Self:processaPontoDeEntrada()

	If oPCPError:possuiErro()
		nStatus := 2
	EndIf

Return nStatus

/*/{Protheus.doc} aguardaGeraAE
Aguarda o término do processamento das autorizações de entrega.

@type  Method
@author ricardo.prandi
@since 03/03/2020
@version P12.1.30
@return Nil
/*/
METHOD aguardaGeraAE() CLASS ProcessaDocumentos
	Local aDados     := {}
	Local oPCPError  := PCPMultiThreadError():New(Self:cErrorUID, .F.)

	While .T.
		If VarGetAA(Self:cUIDGeraAE, @aDados)
			If Len(aDados) == 0
				Exit
			EndIf
		Else
			Exit
		EndIf
		If oPCPError:possuiErro()
			Exit
		EndIf
		Sleep(50)
	EndDo
Return

/*/{Protheus.doc} aguardaNivel
Aguarda o término do processamento do nível atual.

@type  Method
@author lucas.franca
@since 12/11/2019
@version P12.1.27
@return Nil
/*/
METHOD aguardaNivel() CLASS ProcessaDocumentos
	Local nDelegados  := 0
	Local nConcluidos := 0
	Local oPCPError   := PCPMultiThreadError():New(Self:cErrorUID, .F.)

	nDelegados  := Self:getCount(Self:cThrJobs + "_Delegados")
	nConcluidos := Self:getCount(Self:cThrJobs + "_Concluidos")

	While nDelegados > nConcluidos
		Sleep(150)
		nDelegados  := Self:getCount(Self:cThrJobs + "_Delegados")
		nConcluidos := Self:getCount(Self:cThrJobs + "_Concluidos")
		If oPCPError:possuiErro()
			Exit
		EndIf
	EndDo
Return

/*/{Protheus.doc} aguardaSaldos
Aguarda o término do processamento das atualizações de saldo

@type  Method
@author lucas.franca
@since 12/11/2019
@version P12.1.27
@return Nil
/*/
METHOD aguardaSaldos() CLASS ProcessaDocumentos
	Local nDelegados  := 0
	Local nConcluidos := 0
	Local oPCPError   := PCPMultiThreadError():New(Self:cErrorUID, .F.)

	//Aguarda o fim das threads de processamento de saldos.
	nDelegados  := Self:getCount(Self:cThrSaldoJob + "_Delegados")
	nConcluidos := Self:getCount(Self:cThrSaldoJob + "_Concluidos")

	While nDelegados > nConcluidos
		Sleep(150)
		nDelegados  := Self:getCount(Self:cThrSaldoJob + "_Delegados")
		nConcluidos := Self:getCount(Self:cThrSaldoJob + "_Concluidos")
		If oPCPError:possuiErro()
			Exit
		EndIf
	EndDo

	//Aguarda o fim das threads de delegação de saldos.
	nDelegados  := Self:getCount(Self:cThrSaldo + "_Delegados")
	nConcluidos := Self:getCount(Self:cThrSaldo + "_Concluidos")
	While nDelegados > nConcluidos
		Sleep(150)
		nDelegados  := Self:getCount(Self:cThrSaldo + "_Delegados")
		nConcluidos := Self:getCount(Self:cThrSaldo + "_Concluidos")
		If oPCPError:possuiErro()
			Exit
		EndIf
	EndDo
Return

/*/{Protheus.doc} processaSaldos
Dispara o processo de atualização de saldos em estoque.
Este processo é executado de forma paralela ao processo principal.

@type  Method
@author lucas.franca
@since 12/11/2019
@version P12.1.27
@param cNivel  , Character, Nível dos produtos que serão atualizados.
@param cFilProc, Character, Código da filial para processamento do MRP
@return Nil
/*/
METHOD processaSaldos(cNivel, cFilProc) CLASS ProcessaDocumentos
	Local nDelegados := 0

	nDelegados := Self:incCount(Self:cThrSaldo + "_Delegados")
	PCPIPCGO(Self:cThrSaldo, .F., "PCPA145SLD", Self:cTicket, cNivel, cFilProc)
Return

/*/{Protheus.doc} atualizaSaldo
Atualiza a tabela de memória para controle dos saldos, adicionando a quantidade recebida em nQtd.
Será atualizada a quantidade da tabela de memória de acordo com o parâmetro nTipo.

@type  Method
@author lucas.franca
@since 12/11/2019
@version P12.1.27
@param cProduto , Character, Código do produto que será atualizado.
@param cLocal   , Character, Código do local de estoque.
@param cNivel   , Character, Nível do produto.
@param nQtd     , Numeric  , Quantidade que será adicionada.
@param nTipo    , Numeric  , Identifica qual é a quantidade que será atualizada.
                             1 - Entrada (B2_SALPEDI/B2_SALPPRE);
                             2 - Saída   (B2_QEMP/B2_QEMPPRE)
@param lPrevisto, Logic   , Identifica se o saldo é de documentos Previstos ou não.
@param cFilProc , Character, Código da filial para processamento
@return Nil
/*/
METHOD atualizaSaldo(cProduto, cLocal, cNivel, nQtd, nTipo, lPrevisto, cFilProc) CLASS ProcessaDocumentos
	Local aDados    := {}
	Local cChavePrd := AllTrim(cProduto) + CHR(13) + cFilProc + "SLD"
	Local lRet      := .T.
	Local lCriar    := .F.
	Local nPos      := 0
	Local nIndex    := 0
	Local nTotal    := 0

	//Inicia transação
	VarBeginT(Self:cUIDGlobal, cChavePrd)

	//Recupera os estoques deste produto
	aDados := Self:getSaldosProduto(cProduto, @lRet, cFilProc)

	//Se este produto ainda não existir, irá criar a tabela auxiliar de produtos do nível.
	If !lRet
		Self:atualizaProdutoXNivel(cProduto, cNivel, cFilProc)
		//Adiciona no array de dados as informações deste produto.
		aDados := Array(1)
		nPos   := 1
		lCriar := .T.
	Else
		//Produto já existe na tabela de saldos.
		//Verifica se o cLocal já existe.
		nPos := aScan(aDados, {|x| x[SALDOS_POS_LOCAL] == cLocal})
		If nPos == 0
			//Local ainda não existe, irá criar novo elemento no array
			aAdd(aDados, {})
			nPos   := Len(aDados)
			lCriar := .T.
		EndIf
	EndIf

	If lCriar
		//Este produto ou local ainda não existem no array de saldos.
		//Irá criar com as quantidades zeradas.
		aDados[nPos] := Array(SALDOS_TAMANHO)
		aDados[nPos][SALDOS_POS_LOCAL] := cLocal
		aDados[nPos][SALDOS_POS_QTD  ] := Array(SALDOS_QTD_TAMANHO)

		aDados[nPos][SALDOS_POS_QTD][SALDOS_QTD_POS_ENTRADA_FIRME] := 0
		aDados[nPos][SALDOS_POS_QTD][SALDOS_QTD_POS_ENTRADA_PREV ] := 0
		aDados[nPos][SALDOS_POS_QTD][SALDOS_QTD_POS_SAIDA_FIRME  ] := 0
		aDados[nPos][SALDOS_POS_QTD][SALDOS_QTD_POS_SAIDA_PREV   ] := 0
	EndIf

	If nTipo == 1
		If lPrevisto
			aDados[nPos][SALDOS_POS_QTD][SALDOS_QTD_POS_ENTRADA_PREV ] += nQtd
		Else
			aDados[nPos][SALDOS_POS_QTD][SALDOS_QTD_POS_ENTRADA_FIRME] += nQtd
		EndIf
	ElseIf nTipo == 2
		If lPrevisto
			aDados[nPos][SALDOS_POS_QTD][SALDOS_QTD_POS_SAIDA_PREV   ] += nQtd
		Else
			aDados[nPos][SALDOS_POS_QTD][SALDOS_QTD_POS_SAIDA_FIRME  ] += nQtd
		EndIf
	EndIf

	//Seta os dados na tabela de memória
	lRet := VarSetAD(Self:cUIDGlobal, cChavePrd, @aDados )
	//Finaliza a transação
	VarEndT(Self:cUIDGlobal, cChavePrd)

	If !lRet
		Self:msgLog(STR0011 + AllTrim(cProduto) + STR0012 + AllTrim(cLocal) + "'.")  //"Erro ao atualizar a tabela de saldos do produto. Produto: '"  //"'. Local:'"
	EndIf

	//Limpa a memória do array de saldos
	nTotal := Len(aDados)
	For nIndex := 1 To nTotal
		aSize(aDados[nIndex][SALDOS_POS_QTD], 0)
		aSize(aDados[nIndex]                , 0)
	Next nIndex
	aSize(aDados, 0)

Return

/*/{Protheus.doc} atualizaProdutoXNivel
Atualiza a tabela de memória para controle de produtos X nível.

@type  Method
@author lucas.franca
@since 12/11/2019
@version P12.1.27
@param cProduto, Character, Código do produto que será atualizado.
@param cNivel  , Character, Nível do produto.
@param cFilProc, Character, Código da filial para processamento
@return Nil
/*/
METHOD atualizaProdutoXNivel(cProduto, cNivel, cFilProc) CLASS ProcessaDocumentos
	Local aDados    := {}
	Local cChaveNiv := AllTrim(cNivel) + CHR(13) + cFilProc + "NIV"
	Local lRet      := .T.

	//Inicia transação
	VarBeginT(Self:cUIDGlobal, cChaveNiv+"LOCK")

	//Recupera a tabela de produtos X níveis.
	aDados := Self:getProdutoNivel(cNivel, @lRet, cFilProc)

	//Se não existir nenhum produto neste nível, irá criar o array de produtos com o produto atual.
	If !lRet
		aDados := {cProduto}
	Else
		//Já existem produtos neste nível, apenas adiciona o produto atual.
		aAdd(aDados, cProduto)
	EndIf

	//Seta os dados na tabela de memória
	lRet := VarSetAD(Self:cUIDGlobal, cChaveNiv, @aDados )
	If !lRet
		Self:msgLog(STR0013 + AllTrim(cProduto) + STR0014 + AllTrim(cNivel) + "'.")  //"Erro ao atualizar a tabela auxiliar de níveis x produtos. Produto: '"  //"'. Nível:'"
	EndIf

	//Finaliza a transação
	VarEndT(Self:cUIDGlobal, cChaveNiv+"LOCK")

	aSize(aDados, 0)

Return

/*/{Protheus.doc} getProdutoNivel
Recupera os produtos que pertencem ao nível e que possuem pendências de atualização de estoques.

@type  Method
@author lucas.franca
@since 12/11/2019
@version P12.1.27
@param cNivel  , Character, Nível do produto.
@param lRet    , Logico   , Retorna por referência se houve erro ao recuperar os dados.
@param cFilProc, Character, Código da filial para processamento
@return aProdutos, Array  , Array com os códigos dos produtos do nível
/*/
METHOD getProdutoNivel(cNivel, lRet, cFilProc) CLASS ProcessaDocumentos
	Local aProdutos := {}
	Local cChaveNiv := AllTrim(cNivel) + CHR(13) + cFilProc + "NIV"

	//Recupera a tabela de produtos X níveis.
	lRet := VarGetAD(Self:cUIDGlobal, cChaveNiv, @aProdutos )
Return aProdutos

/*/{Protheus.doc} getSaldosProduto
Recupera os saldos de determinado produto

@type  Method
@author lucas.franca
@since 12/11/2019
@version P12.1.27
@param cProduto, Character, Código do produto.
@param lRet    , Logico   , Retorna por referência se houve erro ao recuperar os dados.
@param cFilProc, Character, Código da filial para processamento
@return aSaldos, Array  , Array com os saldos dos produtos. Os elementos deste array são acessados
                          com a utilização das constantes definidas no arquivo PCPA145DEF.CH.
                          A estrutura deste array é:
                          aSaldos[nPos] - Subarray, com o tamanho definido pela constante SALDOS_TAMANHO
                          aSaldos[nPos][SALDOS_POS_LOCAL] - Código do local de estoque deste saldo
                          aSaldos[nPos][SALDOS_POS_QTD  ] - Subarray, com o tamanho definido pela constante SALDOS_QTD_TAMANHO
                          aSaldos[nPos][SALDOS_POS_QTD  ][SALDOS_QTD_POS_ENTRADA_FIRME] - Quantidade de entradas firmes para atualização
                          aSaldos[nPos][SALDOS_POS_QTD  ][SALDOS_QTD_POS_ENTRADA_PREV ] - Quantidade de entradas previstas para atualização
                          aSaldos[nPos][SALDOS_POS_QTD  ][SALDOS_QTD_POS_SAIDA_FIRME  ] - Quantidade de saídas firmes para atualização
                          aSaldos[nPos][SALDOS_POS_QTD  ][SALDOS_QTD_POS_SAIDA_PREV   ] - Quantidade de saídas previstas para atualização
/*/
METHOD getSaldosProduto(cProduto, lRet, cFilProc) CLASS ProcessaDocumentos
	Local aSaldos   := {}
	Local cChavePrd := AllTrim(cProduto) + CHR(13) + cFilProc + "SLD"

	//Recupera a tabela de produtos X níveis.
	lRet := VarGetAD(Self:cUIDGlobal, cChavePrd, @aSaldos )
Return aSaldos

/*/{Protheus.doc} delSaldoProd
Deleta da tabela de memória os registros de saldo do produto
Também elimina o produto da tabela de controle de Produtos x Níveis

@type  Method
@author lucas.franca
@since 12/11/2019
@version P12.1.27
@param cNivel  , Character, Nível do produto.
@param cFilProc, Character, Código da filial para processamento
@return Nil
/*/
METHOD delSaldoProd(cNivel, cFilProc) CLASS ProcessaDocumentos
	Local aProdutos := {}
	Local cChavePrd := ""
	Local cChaveNiv := AllTrim(cNivel) + CHR(13) + cFilProc + "NIV"
	Local lRet      := .T.
	Local nTamanho  := 0
	Local nIndex    := 0

	//Inicia transação
	VarBeginT(Self:cUIDGlobal, cChaveNiv+"LOCK")

	//Limpa a tabela de saldos dos produtos pertencentes ao nível atual
	aProdutos := Self:getProdutoNivel(cNivel, @lRet, cFilProc)
	If lRet
		nTamanho := Len(aProdutos)
		For nIndex := 1 To nTamanho
			cChavePrd := AllTrim(aProdutos[nIndex]) + CHR(13) + cFilProc + "SLD"
			lRet := VarDel(Self:cUIDGlobal, cChavePrd)
			If !lRet
				Self:msgLog(STR0015 + AllTrim(cProduto) + STR0014 + AllTrim(cNivel)+"'.")  //"Erro ao eliminar registro de saldo da memória. Produto: '"  //"'. Nível: '"
			EndIf
		Next nIndex
	EndIf

	//Limpa a tabela de produtos x nível do nível atual
	lRet := VarDel(Self:cUIDGlobal, cChaveNiv)
	If !lRet
		Self:msgLog(STR0016 + AllTrim(cNivel) + "'.")  //"Erro ao eliminar registro de produtos x nível da memória. Nível: '"
	EndIf

	//Finaliza a transação
	VarEndT(Self:cUIDGlobal, cChaveNiv+"LOCK")

	aSize(aProdutos, 0)
Return

/*/{Protheus.doc} atualizaDeParaDocumentoProduto
Faz a atualização na tabela de DE-PARA em memória.
Armazena o número do documento do MRP, e vincula com o número do documento
gerado no Protheus e o Produto desse documento.

@type  Method
@author lucas.franca
@since 12/11/2019
@version P12.1.27
@param cDocMRP , Character, Documento gerado pelo MRP
@param aDocProt, Array    , Índice 1 contendo o documento do Protheus e índice dois contendo o produto
@param cFilProc, Character, Código da filial para processamento
@return lRet   , Lógico   , Identifica se consegiu atualizar o arquivo DE-PARA
/*/
METHOD atualizaDeParaDocumentoProduto(cDocMRP, aDocProt, cFilProc) CLASS ProcessaDocumentos
	Local cChaveDoc := AllTrim(cDocMRP) + CHR(13) + cFilProc + "DOCUM"

	lRet := VarSetA(Self:cUIDGlobal, cChaveDoc, aDocProt)
Return lRet

/*/{Protheus.doc} getDocumentoDePara
Consulta um documento do MRP na tabela DE-PARA de documentos,
e retorna o documento do Protheus que foi gerado.
Se não encontrar o documento na tabela DE-PARA, irá retornar Nil.

@type  Method
@author lucas.franca
@since 12/11/2019
@version P12.1.27
@param cDocMRP  , Character, Documento gerado pelo MRP
@param cFilProc , Character, Código da filial para processamento
@return aRet, Array, Array com duas posições, sendo:
                     [1] - Quando .F. indica que o produto pai não foi gerado devido a filtro de datas, 
                           e o produto filho deve ser processado.
                     [2] - Documento gerado pelo protheus
/*/
METHOD getDocumentoDePara(cDocMRP, cFilProc) CLASS ProcessaDocumentos
	Local aDocProd  := {}
	Local aRet      := {.T., Nil}
	Local cChaveDoc := AllTrim(cDocMRP) + CHR(13) + cFilProc + "DOCUM"

	lRet := VarGetAD(Self:cUIDGlobal, cChaveDoc, @aDocProd)
	If !lRet .Or. Empty(aDocProd)
		//Verifica se esse documento não foi gerado
		//devido a seleção de datas para geração de documentos.
		cChaveDoc := AllTrim(cDocMRP) + CHR(13) + cFilProc + "FORADATA"
		If Self:getCount(cChaveDoc) > 0
			aRet[1] := .F.
		EndIf
	Else
		aRet[1] := .T.
		aRet[2] := aDocProd[1]
	EndIf
Return aRet

/*/{Protheus.doc} getDocsAglutinados
Consulta um documento do MRP na tabela de documentos aglutinados.
Retorna os documentos do Protheus que foram gerados.
Se não encontrar algum dos documentos na tabela DE-PARA, irá retornar um array sem nenhum elemento.

@type  Method
@author lucas.franca
@since 09/12/2019
@version P12.1.27
@param cDocMRP  , Character, Documento gerado pelo MRP
@param cProduto , Character, Código do produto
@param lEmpenho , Logic    , Retorna por referência com valor .F. quando todos os 
                             produtos pais não foram gerados por estarem fora da data
                             de seleção para geração de documentos. Indica que não deve gerar os empenhos.
@return aDocs, Array, Lista dos documentos gerados pelo Protheus
                      Estrutura do array:
                      aDocs[nIndex][1] - Documento gerado no ERP Protheus
                      aDocs[nIndex][2] - Quantidade de empenho necessário para o documento
/*/
METHOD getDocsAglutinados(cDocMRP, cProduto, lEmpenho) CLASS ProcessaDocumentos
	Local aDocs      := {}
	Local aDocDePara := {}
	Local cDocPai    := ""
	Local nIndForaDt := 0
	Local nPos       := 1
	Local nTamRegs   := 0
	Local aRegs      := {}
	Local oJson      := JsonObject():New()

	lEmpenho := .T.

	aRegs := MrpGetHWG(Self:cTicket, cDocMRP, cProduto)
	If aRegs[1]
		oJson:FromJson(aRegs[2])
		nTamRegs := Len(oJson["items"])

		While nPos <= nTamRegs

			aDocDePara := Self:getDocumentoDePara((oJson["items"][nPos]["childDocument"]), cFilAnt)
			cDocPai    := aDocDePara[2]
			/*
				Quando aDocDePara[1] for == .F., indica que o produto pai não foi gerado
				devido ao filtro realizado na seleção de datas para geração dos documentos.
				Neste cenário, não irá gerar empenhos, mas irá gerar OP/SC do filho se existir necessidade.
			*/
			If !Empty(cDocPai)
				aAdd(aDocs, {cDocPai, oJson["items"][nPos]["allocation"]})
			Else
				If aDocDePara[1]
					//Um dos documentos pais deste produto aglutinado ainda não foi processado.
					//Não retorna nenhum documento
					aSize(aDocs, 0)
					Exit
				Else 
					nIndForaDt++
				EndIf
			EndIf
			nPos++
		End
		If nIndForaDt == nTamRegs .And. nIndForaDt > 0
			lEmpenho := .F. //Retorna por referência. Deve processar filho mas não gerar empenho.
		EndIf
		aSize(oJson["items"],0)
	EndIf
	FreeObj(oJson)

Return aDocs

/*/{Protheus.doc} updStatusRastreio
Faz a atualização do status de um registro de rastreio.

@type  Method
@author lucas.franca
@since 12/11/2019
@version P12.1.27
@param cStatus   , Character, Novo status do registro.
@param cDocGerado, Character, Número do documento gerado pelo ERP.
@param cTipDocERP, Character, Tipo do documento gerado pelo ERP (1-OP/2-SC).
@param nRecno    , Numeric  , RECNO do registro para atualização
@return Nil
/*/
METHOD updStatusRastreio(cStatus, cDocGerado, cTipDocERP, nRecno) CLASS ProcessaDocumentos

	Local aResult := {}

	aResult := MrpPostRas( nRecno, cStatus, cDocGerado, cTipDocERP )
	If aResult[1] == 400
		Self:msgLog(aResult[2])
	EndIf

Return

/*/{Protheus.doc} incCount
Faz o incremento de um contador identificado por cName

@type  Method
@author lucas.franca
@since 12/11/2019
@version P12.1.27
@param cName, Character, Nome do contador a ser incrementado.
@return nCount, Numeric, Valor atual do contador.
/*/
METHOD incCount(cName) CLASS ProcessaDocumentos
	Local nCount := 0

	If !VarSetX(Self:cUIDGlobal, cName, @nCount, 1, 1)
		Self:msgLog(STR0017 + cName)  //"Erro ao incrementar o contador "
	EndIf
Return nCount

/*/{Protheus.doc} initCount
Inicializa um contador identificado por cName para 0

@type  Method
@author lucas.franca
@since 12/11/2019
@version P12.1.27
@param cName , Character, Nome do contador a ser incrementado.
@param nValue, Numeric  , Valor para inicialização. Padrão = 0
@return lRet , Logic    , identifica se foi possível inicializar o contador.
/*/
METHOD initCount(cName, nValue) CLASS ProcessaDocumentos
	Local lRet := .T.

	Default nValue := 0
	If !VarSetX(Self:cUIDGlobal, cName, nValue)
		lRet := .F.
		Self:msgLog(STR0017 + cName)  //"Erro ao incrementar o contador "
	EndIf
Return lRet

/*/{Protheus.doc} getCount
Recupera o valor de um contador identificado por cName

@type  Method
@author lucas.franca
@since 12/11/2019
@version P12.1.27
@param cName, Character, Nome do contador a ser incrementado.
@return nCount, Numeric, Valor atual do contador.
/*/
METHOD getCount(cName) CLASS ProcessaDocumentos
	Local lRet   := .T.
	Local nCount := 0

	lRet := VarGetXD(Self:cUIDGlobal, cName, @nCount)
	If !lRet
		nCount := 0
	EndIf
Return nCount

/*/{Protheus.doc} clearCount
Limpa da memória um contador identificado por cName

@type  Method
@author lucas.franca
@since 12/11/2019
@version P12.1.27
@param cName, Character, Nome do contador a ser incrementado.
@return Nil
/*/
METHOD clearCount(cName) CLASS ProcessaDocumentos
	If !VarDel(Self:cUIDGlobal, cName)
		Self:msgLog(STR0018 + cName)  //"Erro ao eliminar da memória o contador "
	EndIf
Return

/*/{Protheus.doc} getGeraDocAglutinado
Identifica se a geração de documentos está parametrizada
para algutinar ou não os documentos.

@type  Method
@author lucas.franca
@since 12/11/2019
@version P12.1.27
@param cNivel  , Character, Nível do produto em processamento
@param lDemanda, Logic    , Identifica se considera como demanda
@return lAglutina, Lógico, Identifica se o documento deve ser aglutinado.
/*/
METHOD getGeraDocAglutinado(cNivel, lDemanda) CLASS ProcessaDocumentos
	Local lAglutina := .F.
	Local lOP       := Self:lOPAglutina
	Local lSC       := Self:lSCAglutina

	Default lDemanda := .F.

	If lDemanda
		lSC := Self:lDemSCAgl
		lOP := Self:lDemOPAgl
	EndIf

	If cNivel == "99"
		lAglutina := lSC
	Else
		lAglutina := lOP
	EndIf
Return lAglutina

/*/{Protheus.doc} getTipoDocumento
Retorna o Tipo do Documento

@type  Method
@author lucas.franca
@since 12/11/2019
@version P12.1.27
@param 01 dData   , Date     , Data para identificar o tipo de documento
@param 02 cTipoDoc, Caractere, Define se buscará o tipo de documento de OP ou SC
@return cTipoDoc, Character, tipo do documento
/*/
METHOD getTipoDocumento(dData, cDoc) CLASS ProcessaDocumentos
    Local cData    := Iif( dData == Nil, "", DtoS(dData) )
	Local cTipoDoc := Iif(Self:cTipoOP == "1","P","F")

	If Self:lFiltraData .And. cData != ""
		If cDoc == "SC" .And. Self:oDtsGeraSC:HasProperty(cData)
			cTipoDoc := Self:oDtsGeraSC[cData]
		EndIf
		If cDoc == "OP" .And. Self:oDtsGeraOP:HasProperty(cData)
			cTipoDoc := Self:oDtsGeraOP[cData]
		EndIf		
	EndIf
Return cTipoDoc

/*/{Protheus.doc} geraDocumentoFirme
Verifica se em algum período será gerado documento FIRME.

@type  Method
@author lucas.franca
@since 07/02/2022
@version P12
@return lRet, Logic, Identifica se irá gerar documento firme em algum período
/*/
METHOD geraDocumentoFirme() CLASS ProcessaDocumentos
	Local aDatas := {}
	Local lRet   := .F.
	Local nIndex := 0
	Local nTotal := 0

	If Self:lFiltraData
		aDatas := Self:oDtsGeraOP:GetNames()
		nTotal := Len(aDatas)

		For nIndex := 1 To nTotal 
			If Self:oDtsGeraOP[aDatas[nIndex]] == "F"
				lRet := .T.
				Exit
			EndIf
		Next nIndex
		aSize(aDatas, 0)
	Else
		lRet := Self:getTipoDocumento() == "F"
	EndIf

Return lRet 

/*/{Protheus.doc} ConvUm
Faz a conversão das quantidades de primeira e segunda unidade de medida.
 - Cópia da função ConvUm. Cópia realizada por questão de performance.

@type  Method
@author lucas.franca
@since 27/12/2019
@version P12.1.28
@param cCod , Character, Código do produto
@param nQtd1, Numeric  , Quantidade da 1° unidade de medida
@param nQtd2, Numeric  , Quantidade da 2° unidade de medida
@param nUnid, Numeric  , Unidade de medida (1° ou 2°)
@return nBack, Numeric , Quantidade convertida de acordo com a unidade de medida.
/*/
METHOD ConvUm(cCod, nQtd1, nQtd2, nUnid) CLASS ProcessaDocumentos
	Local nBack := 0
	Local nValPe:=0

	Self:nToler1UM := Iif(Self:nToler1UM == Nil, QtdComp(GetMV("MV_NTOL1UM")), Self:nToler1UM)
	Self:nToler2UM := Iif(Self:nToler2UM == Nil, QtdComp(GetMV("MV_NTOL2UM")), Self:nToler2UM)
	Self:lPConvUm  := Iif(Self:lPConvUm  == Nil, ExistBlock("CONVUM")        , Self:lPConvUm )

	nBack := If( (nUnid == 1), nQtd1, nQtd2 )

	//Somente posiciona na SB1 se não estiver posicionado no produto correto
	If SB1->B1_COD != cCod .Or. SB1->B1_FILIAL != xFilial("SB1")
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1")+cCod))
	EndIf

	If (SB1->B1_CONV != 0)
		If ( SB1->B1_TIPCONV != "D" )
			If ( nUnid == 1 )
				nBack := (nQtd2 / SB1->B1_CONV)
				If Self:nToler1UM > QtdComp(0) .And. ABS(QtdComp(nBack-nQtd1)) <= Self:nToler1UM
					nBack:=nQtd1
				EndIf
			Else
				nBack := (nQtd1 * SB1->B1_CONV)
				If Self:nToler2UM > QtdComp(0) .And. ABS(QtdComp(nBack-nQtd2)) <= Self:nToler2UM
					nBack:=nQtd2
				EndIf
			EndIf
		Else
			If ( nUnid == 1 )
				nBack := (nQtd2 * SB1->B1_CONV)
				If Self:nToler1UM > QtdComp(0) .And. ABS(QtdComp(nBack-nQtd1)) <= Self:nToler1UM
					nBack:=nQtd1
				EndIf
			Else
				nBack := (nQtd1 / SB1->B1_CONV)
				If Self:nToler2UM > QtdComp(0) .And. ABS(QtdComp(nBack-nQtd2)) <= Self:nToler2UM
					nBack:=nQtd2
				EndIf
			EndIf
		EndIf
	EndIf

	// Ponto de Entrada para calcular qtd nas unidades de medida
	If Self:lPConvUm
		nValPe:=ExecBlock("CONVUM",.F.,.F.,{nQtd1,nQtd2,nUnid,nBack})
		If ValType(nValPe) == "N"
			nBack:=nValPe
		EndIf
	EndIf

Return nBack

/*/{Protheus.doc} executaIntegracoes
Dispara as integrações dos documentos gerados
Este processo é executado de forma paralela, e não impede a finalização da geração dos documentos

@type Method
@author marcelo.neumann
@since 31/12/2021
@version P12.1.28
@return Nil
/*/
METHOD executaIntegracoes() CLASS ProcessaDocumentos
	Local oPCPError  := PCPMultiThreadError():New(Self:cErrorUID, .F.)
	Local b145IRecov := {|| PCPUnlock("PCPA145INT") }

	Self:msgLog(STR0035) //"INICIANDO THREAD PARA INTEGRACAO DAS OPS"

	PutGlbValue("P145JOBINT", " ")

	//Se existir ordens a integrar, abre nova thread para executar a integração de forma paralela.
	oPCPError:startJob("PCPA145INT", getEnvServer(), Self:lAutomacao, cEmpAnt, cFilAnt, Self:aIntegra, Self:cErrorUID, Self:cUIDGlobal, Self:cTicket, Self:cUIDIntOP, Self:cUIDIntEmp, , , , , b145IRecov)

	Self:aguardaInicioIntOP(oPCPError)

Return

/*/{Protheus.doc} addEmpenho
Adiciona chave do registro do empenho em memória global
para identificar os empenhos já criados.

@type  Method
@author lucas.franca
@since 27/12/2019
@version P12.1.28
@param aEmpenho, Array  , Array com os dados do empenho que foi criado
                          Dados do array acessados pelas constantes iniciadas em "EMPENHO_POS"
@param nRecno  , Numeric, RECNO do registro que foi criado na tabela SD4
@return Nil
/*/
METHOD addEmpenho(aEmpenho, nRecno) CLASS ProcessaDocumentos
	Local cChaveEmp := aEmpenho[EMPENHO_POS_FILIAL] +;
	                   aEmpenho[EMPENHO_POS_PRODUTO] +;
	                   aEmpenho[EMPENHO_POS_ORDEM_PRODUCAO]+;
	                   aEmpenho[EMPENHO_POS_TRT]+;
	                   aEmpenho[EMPENHO_POS_LOCAL]+;
	                   aEmpenho[EMPENHO_POS_OP_ORIGEM]

	//Apenas adiciona a chave do empenho com o recno correspondente.
	VarSetX(Self:cUIDGlobal, "EMP"+cChaveEmp, nRecno)
Return

/*/{Protheus.doc} existEmpenho
Verifica se determinado empenho já foi criado, e retorna o RECNO correspondente.

@type  Method
@author lucas.franca
@since 27/12/2019
@version P12.1.28
@param aEmpenho, Array  , Array com os dados do empenho que será verificado.
                          Dados do array acessados pelas constantes iniciadas em "EMPENHO_POS"
@param nRecno  , Numeric, Retorna por referência o RECNO do registro do empenho, caso exista.
@return lRet   , Logic  , Identifica se o empenho já foi criado ou não.
/*/
METHOD existEmpenho(aEmpenho, nRecno) CLASS ProcessaDocumentos
	Local cChaveEmp := aEmpenho[EMPENHO_POS_FILIAL] +;
	                   aEmpenho[EMPENHO_POS_PRODUTO] +;
	                   aEmpenho[EMPENHO_POS_ORDEM_PRODUCAO]+;
	                   aEmpenho[EMPENHO_POS_TRT]+;
	                   aEmpenho[EMPENHO_POS_LOCAL]+;
	                   aEmpenho[EMPENHO_POS_OP_ORIGEM]
	Local lRet := .F.

	lRet := VarGetXD(Self:cUIDGlobal, "EMP"+cChaveEmp, @nRecno)
	If !lRet
		nRecno := 0
	EndIf
Return lRet

/*/{Protheus.doc} msgLog
Faz o print de uma mensagem de log no console.

@type Method
@author lucas.franca
@since 13/12/2019
@version P12.1.28
@param cMsg, Character, Mensagem que será adicionada no log
@param cType, Character, cType que será informado na gravação dos logs. 
						1=INICIO; 2=FIM; 3=ALERTA; 4=ERRO; 5=CANCEL; 6=MENSAGEM (Default: 6=Mensagem)
@return Nil
/*/
METHOD msgLog(cMsg, cType) CLASS ProcessaDocumentos
	Default cType := "6"

	LogMsg('PCPA145', 14, 4, 1, '', '', cMsg)

	If !Empty(GetGlbValue("PCPA145PROCCV8")) .and. !Empty(GetGlbValue("PCPA145PROCIDCV8"))
		GravaCV8(cType, GetGlbValue("PCPA145PROCCV8"), cMsg, /*cDetalhes*/, "", "", NIL, GetGlbValue("PCPA145PROCIDCV8"), cFilAnt)
	EndIf
Return Nil

/*/{Protheus.doc} getProgress
Retorna a porcentagem do total de documentos a serem gerados.

@type  Method
@author renan.roeder
@since 27/03/2020
@version P12.1.30
@return nProgress, Numeric, Número relacionado a porcentagem da execução.
/*/
METHOD getProgress() CLASS ProcessaDocumentos
	Local nCount    := 0
	Local nCountPCs := 0
	Local nProgress := 0
	Local nTotal    := 0

	nCountPCs := Self:GetCount("ENTRADAPC") - Self:GetCount("SAIDAPC")

	lRet := VarGetXD(Self:cUIDGlobal, TOTAL_PENDENTES, @nTotal)
	If lRet
		lRet := VarGetXD(Self:cUIDGlobal, CONTADOR_GERADOS, @nCount)
		nCount := nCount - nCountPCs
		If lRet
			nCount += Self:getCount("TRANSF_PROCESSADO")
			nTotal += Self:totalTransferencias()
			nProgress := Round( (nCount/nTotal) * 100, 2)
		EndIf
	EndIf
	If !lRet
		If GetGlbValue(Self:cTicket + "UIDPRG_PCPA145") != "END"
			nProgress := 0
		Else
			nProgress := 100
		EndIf
	EndIF
Return nProgress


/*/{Protheus.doc} incDocUni
Grava o próximo número do documento.

@type  Method
@author renan.roeder
@since 27/07/2020
@version P12.1.31
@param cName   , Character, Nome do documento a ser incrementado.
@param cFilProc, Character, Código da filial de processamento.
@return cNumDoc, Numeric, Valor atual do número do documento.
/*/
METHOD incDocUni(cName, cFilProc) CLASS ProcessaDocumentos
	Local cNumDoc := ""
	Local cChave  := ""
	Local lUsaNumPad := .F.

	Default cFilProc := ""

	cChave := cName + cFilProc

	VarBeginT(Self:cUIDGlobal, cChave)

	If cName == "C2_NUM"
		lUsaNumPad := Self:usaNumOpPadrao(cFilProc)
		If !lUsaNumPad
			cNumDoc := Self:getDocUni(cName, cFilProc)
			If Empty(cNumDoc)
				cNumDoc := Self:cNumIniOP
			Else
				cNumDoc := Soma1(cNumDoc)
			EndIf

			If existeOP(cFilProc, cNumDoc)
				lUsaNumPad := .T.
				Self:setaUsaNumOpPadrao(cFilProc, lUsaNumPad)
			EndIf
		EndIf

		If lUsaNumPad
			cNumDoc := GetNumSC2(.T.)
		EndIf
	Else
		cNumDoc := GetNumSC1(.T.)
	EndIf


	If !VarSetXD(Self:cUIDGlobal, cChave, cNumDoc )
		Self:msgLog(STR0022 + cName)  //"Erro ao atualizar o número do documento "
	EndIf
	VarEndT(Self:cUIDGlobal, cChave)

Return cNumDoc

/*/{Protheus.doc} initDocUni
Inicia a numeração única dos documentos em memória.

@type  Method
@author renan.roeder
@since 27/07/2020
@version P12.1.31
@param cName   , Character, Nome do documento a ser incrementado.
@param cFilProc, Character, Código da filial para processamento
@return Nil
/*/
METHOD initDocUni(cName, cFilProc) CLASS ProcessaDocumentos
	Local cChave := ""

	Default cFilProc := ""

	cChave := cName + cFilProc

	If !VarSetX(Self:cUIDGlobal, cChave, "")
		Self:msgLog(STR0022 + cName)  //"Erro ao atualizar o número do documento "
	EndIf
Return

/*/{Protheus.doc} getDocUni
Recupera o valor de um contador identificado por cName

@type  Method
@author renan.roeder
@since 27/07/2020
@version P12.1.31
@param cName, Character, Nome do documento a ser incrementado.
@param cFilProc, Character, Código da filial para processamento
@return cNumDoc, Character, Valor atual do contador.
/*/
METHOD getDocUni(cName, cFilProc) CLASS ProcessaDocumentos
	Local lRet    := .T.
	Local cNumDoc := ""
	Local cChave  := ""

	Default cFilProc := ""

	cChave := cName + cFilProc

	lRet := VarGetXD(Self:cUIDGlobal, cChave, @cNumDoc)
	If !lRet
		cNumDoc := ""
	EndIf
Return cNumDoc

/*/{Protheus.doc} utilizaMultiEmpresa
Verifica se utiliza multi-empresas.

@type  Method
@author lucas.franca
@since 18/11/2020
@version P12
@return lUsaME, Logic, Indicador se utiliza multi-empresas
/*/
METHOD utilizaMultiEmpresa() CLASS ProcessaDocumentos
	Local lRet := .T.

	If Self:lUsaME == Nil
		lRet := VarGetXD(Self:cUIDGlobal, "UTILIZA_MULTI_EMP", @Self:lUsaME)
		If !lRet
			Self:lUsaME := .F.
		EndIf
	EndIf

Return Self:lUsaME

/*/{Protheus.doc} aguardaTransferencia
Aguarda o término do processamento das transferências.

@type  Method
@author lucas.franca
@since 18/11/2020
@version P12
@param oPCPError, Object, Objeto da instância de controle de erros.
@return Nil
/*/
METHOD aguardaTransferencia(oPCPError) CLASS ProcessaDocumentos
	//Quando a thread de transferências for finalizada,
	//o contador "TRANSF_FIM" é atualizado para 1.
	While Self:getCount("TRANSF_FIM") == 0
		Sleep(1000)
		If oPCPError:possuiErro()
			Exit
		EndIf
	End
Return

/*/{Protheus.doc} totalTransferencias
Retorna a quantidade total de registro de transferências.

@type  Method
@author lucas.franca
@since 18/11/2020
@version P12
@return nTotTrans, Numeric, Quantidade de registros de transferências.
/*/
METHOD totalTransferencias() CLASS ProcessaDocumentos
	Local nTotTrans := 0
	Local nTry      := 0

	While (nTotTrans := Self:getCount("TRANSF_TOTAL")) < 0 .And. nTry < 100 .And. Self:getCount("TRANSF_FIM") < 1
		Sleep(500)
		nTry++
	End
	If nTotTrans < 0
		nTotTrans := 0
	EndIf
Return nTotTrans

/*/{Protheus.doc} getDate
Formata uma string de data no formato AAAA-MM-DD para o formato DATE Advpl

@type  Static Function
@author lucas.franca
@since 26/12/2019
@version P12.1.27
@param cData, Character, Data no formato AAAA-MM-DD
@return dData, Character, Data no formato Date
/*/
Static Function getDate(cData)
	Local dData := Nil

	cData := StrTran(cData,'-','')
	dData := StoD(cData)
Return dData

/*/{Protheus.doc} P145AtuSta
Atualiza o status do ticket do MRP.

@type  Static Function
@author lucas.franca
@since 20/11/2020
@version P12
@param cTicket, Character, Número do ticket de processamento
@param nStatus, Numeric  , Retorno do processamento da geração de documentos (ProcessaDocumentos:processar())
                           0=Nenhum documento gerado;
                           1=Documentos gerados com sucesso;
                           2=Documentos gerados, mas ocorreram erros.
						   3=Documentos gerados, e as integrações estão pendêntes de execução.
@return Nil
/*/
Function P145AtuSta(cTicket, nStatus)
	Local cStatus := "6"

	//Se tiver integração, marca o ticket como "Documentos gerados com pendências de integração".
	If nStatus == 3
		cStatus := "9"
	EndIf

	//Se ocorreram erros na geração, marca o ticket como "Documentos gerados com pendências".
	If nStatus == 2
		cStatus := "7"
	EndIf

	//Ao finalizar a geração dos documentos, atualiza o status da tabela HW3 para Gerado.
	HW3->(dbSetOrder(1))
	If HW3->(dbSeek(xFilial("HW3")+cTicket))
		//Somente atualiza o status se o ticket ainda não tiver sido
		//marcado como documentos gerados (HW3_STATUS == "6") ou gerado com pendências (HW3_STATUS == "7")
		If HW3->HW3_STATUS <> "7" .And. HW3->HW3_STATUS <> "6"
			RecLock("HW3", .F.)
				HW3->HW3_STATUS := cStatus
			HW3->(MsUnLock())
		EndIf
	EndIf
Return Nil

/*/{Protheus.doc} criaSB2
Atualiza o status do ticket do MRP.

@type  Method
@author ricardo.prandi
@since 10/02/2021
@version P12
@param 01 cFilAux   , Character, Código da filial do produto
@param 02 cProduto  , Character, Código do produto irá criar a SB2
@param 03 cLocal    , Character, Código do local
@param 04 lPosiciona, Logic    , Indica se deve posicionar no registro na tabela SB2
@return Nil
/*/
METHOD criaSB2(cFilAux, cProduto, cLocal, lPosiciona) CLASS ProcessaDocumentos

	Local cChavePrd := xFilial("SB2", cFilAux) + cProduto + cLocal
	Local cFilBkp   := cFilAnt

	If Self:oCacheLoc[cChavePrd] == Nil
		dbSelectArea("SB2")
		dbSetOrder(1)

		//Verifica se existe registro para o produto na SB2, e caso não exista, é necessário criar
		//um registro com quantidade zerada para chamar as funções de estoque.
		//A função GravaB2Pre e GravaB2Emp exige que a SB2 já esteja posicionada no registro que será feita a atualização.
		VarBeginT(Self:cUIDGlobal, cChavePrd)

		If !dbSeek(cChavePrd)
			cFilAnt := cFilAux
			CriaSB2(cProduto,cLocal)
			MsUnlock()
			cFilAnt := cFilBkp
		EndIf

		VarEndT(Self:cUIDGlobal, cChavePrd)

		Self:oCacheLoc[cChavePrd] := SB2->(Recno())

	ElseIf lPosiciona
		dbSelectArea("SB2")
		dbSetOrder(1)

		SB2->(DBGoTo(Self:oCacheLoc[cChavePrd]))
	EndIf

Return

/*/{Protheus.doc} setDadosOP
Armazena em memória o roteiro da ordem de produção

@type  Method
@author lucas.franca
@since 06/04/2021
@version P12
@param 01 cFilAux , Character, Código da filial
@param 02 cNumOP  , Character, Numeração da ordem de produção
@param 03 cProduto, Character, Código do produto da ordem de produção
@param 04 cRoteiro, Character, Código do roteiro
@param 05 cTpOp   , Character, Tipo da OP (Firme/Prevista)
@param 06 dInicio , Date     , Data de início da ordem de produção
@return Nil
/*/
METHOD setDadosOP(cFilAux, cNumOP, cProduto, cRoteiro, cTpOp, dInicio) CLASS ProcessaDocumentos
	//Armazena na variável global o roteiro utilizado na OP.
	VarSetA(Self:cUIDGlobal, "ROT_OP_"+cFilAux+cNumOP, {cProduto, cRoteiro, cTpOp, dInicio})
Return

/*/{Protheus.doc} getDadosOP
Recupera da memória informações da ordem de produção

@type  Method
@author lucas.franca
@since 06/04/2021
@version P12
@param 01 cFilAux , Character, Código da filial
@param 02 cNumOP  , Character, Numeração da ordem de produção
@return aDadosOP, Array, Array contendo as informações da OP.
                         [1] - Produto da OP
                         [2] - Roteiro da OP
						 [3] - Tipo da OP
						 [4] - Data de inicio da OP
/*/
METHOD getDadosOP(cFilAux, cNumOP) CLASS ProcessaDocumentos
	Local aDadosOP := {}
	Local lRet     := .T.

	lRet := VarGetAD(Self:cUIDGlobal, "ROT_OP_"+cFilAux+cNumOP, @aDadosOP)
	If !lRet
		aDadosOP := {"","", Self:getTipoDocumento(), Nil}
	EndIf

Return aDadosOP

/*/{Protheus.doc} getOperacaoComp
Verifica se o componente possui relacionamento de operação x componentes, e retorna a operação se existir.

@type  Method
@author lucas.franca
@since 06/04/2021
@version P12
@param 01 cFilAux , Character, Código da filial
@param 02 cProdPai, Character, Código do produto pai (produto da OP)
@param 03 cRoteiro, Character, Roteiro da ordem de produção
@param 04 cComp   , Character, Código do componente
@param 05 cTRT    , Character, Sequência do componente
@return cOperacao , Character, Código da operação
/*/
METHOD getOperacaoComp(cFilAux, cProdPai, cRoteiro, cComp, cTRT) CLASS ProcessaDocumentos
	Local cOperacao := ""
	Local lRet      := .T.

	//Primeiro verifica na global se já foi carregado operação por componente deste componente.
	lRet := VarGetXD(Self:cUIDGlobal, "OPERAC_CMP_"+cFilAux+cProdPai+cRoteiro+cComp+cTRT, @cOperacao)

	If !lRet
		//Ainda não foi carregado, faz a busca na tabela SGF.
		SGF->(dbSetOrder(2))
		If SGF->(dbSeek(xFilial("SGF", cFilAux) + cProdPai + cRoteiro + cComp + cTRT))
			cOperacao := SGF->GF_OPERAC
		Else
			cOperacao := ""
		EndIf

		//Armazena na global de memória a operação encontrada.
		VarSetX(Self:cUIDGlobal, "OPERAC_CMP_"+cFilAux+cProdPai+cRoteiro+cComp+cTRT, cOperacao)
	EndIf

Return cOperacao

/*/{Protheus.doc} processaPontoDeEntrada
Verifica a existência do ponto de entrada da geração de documentos e o executa em uma nova thread

@type Method
@author marcelo.neumann
@since 26/04/2021
@version P12
@return Nil
/*/
METHOD processaPontoDeEntrada() CLASS ProcessaDocumentos

	Local cThread := Self:cTicket + "PONTO_ENTRADA"

	If ExistBlock("PA145GER")
		LogMsg("PCPA145", 14, 4, 1, '', '', "PA145GER-" + STR0028) //"Encontrado o Ponto de Entrada. Abrindo thread para a execucao."

		//Abre a thread que fará as execuções específicas (ponto de entrada)
		PCPIPCStart(cThread, 1, 0, cEmpAnt, cFilAnt, Self:cErrorUID)

		//Ativa a Thread para geração dos pedidos de compra
		PCPIPCGO(cThread, .F., "P145PonEnt", Self:cTicket)
	EndIf

Return

/*/{Protheus.doc} P145PonEnt
Executa o ponto de entrada PA145GER

@type Function
@author marcelo.neumann
@since 26/04/2021
@version P12
@param cTicket, Character, Número do ticket de processamento
@return Nil
/*/
Function P145PonEnt(cTicket)
	Local nTempoIni := MicroSeconds()

	LogMsg("PCPA145", 14, 4, 1, "", "", "PA145GER-" + STR0029) //"INICIO"

	ExecBlock("PA145GER", .F., .F., {cTicket})

	LogMsg("PCPA145", 14, 4, 1, "", "", "PA145GER-" + STR0030 + cValToChar(MicroSeconds() - nTempoIni)) //"FIM. Duracao da execucao:"

Return

/*/{Protheus.doc} aguardaInicioIntOP
Aguarda o término do processamento das transferências.

@type Method
@author marcelo.neumann
@since 26/04/2021
@version P12
@param oPCPError, Object, Objeto da instância de controle de erros.
@return Nil
/*/
METHOD aguardaInicioIntOP(oPCPError) CLASS ProcessaDocumentos
	While !GetGlbValue("P145JOBINT") $ "INI|FIM"
		Sleep(1000)
		If oPCPError:possuiErro()
			Exit
		EndIf
	End
Return

/*/{Protheus.doc} getUserName
Retorna o usuário (cUserName) que está executando o processo.

@type Method
@author lucas.franca
@since 01/10/2021
@version P12
@return Self:cUserName, Character, Usuário que está executando o processo.
/*/
METHOD getUserName() CLASS ProcessaDocumentos
	
	If Self:cUserName == Nil
		If Empty(Self:cCodUsr)
			Self:cUserName := ""
		Else
			Self:cUserName := UsrRetName(Self:cCodUsr)
		EndIf
	EndIf

Return Self:cUserName

/*/{Protheus.doc} montaJSData
Converte o Array com as datas para geração de documentos em JSON para uso no processamento

@author lucas.franca
@since 03/02/2022
@version P12
@param aDataGera, Array, Array com as datas para geração de documentos
@return Nil
/*/
METHOD montaJSData(aDataGera) Class ProcessaDocumentos
	Local nIndex := 0
	Local nTotal := Len(aDataGera)

	Self:oDatasGera := JsonObject():New()

	For nIndex := 1 To nTotal 

		Self:oDatasGera[ StrTran(aDataGera[nIndex][1], "-", "") ] := aDataGera[nIndex][2]

	Next nIndex 
Return Nil

/*/{Protheus.doc} dataValida
Verifica se uma data está válida de acordo com a seleção de datas para geração de documentos

@author lucas.franca
@since 03/02/2022
@version P12
@param 01 dData, Date     , Data para avaliação
@param 02 cDoc , Caractere, Define busca de data valida na lista de Ops ou SCs
@return lRet, Logic, .T. se a data foi selecionada para geração.
/*/
METHOD dataValida(dData, cDoc) Class ProcessaDocumentos
	Local lRet := .T.

	If Self:lFiltraData
		If cDoc == "SC"
			lRet := Self:oDtsGeraSC:HasProperty( DtoS(dData) )
		ElseIf cDoc == "OP"
			lRet := Self:oDtsGeraOP:HasProperty( DtoS(dData) )
		EndIf
	EndIf
Return lRet 

/*/{Protheus.doc} getLocProcesso
Recupera o local de processo para produtos com apropriação indireta.

@author lucas.franca
@since 05/04/2022
@version P12
@param Nil
@return cLocProc
/*/
METHOD getLocProcesso() Class ProcessaDocumentos
	If !Self:oLocProc:HasProperty(cFilAnt)
		Self:oLocProc[cFilAnt] := GetMvNNR("MV_LOCPROC", "99")
	EndIf
Return Self:oLocProc[cFilAnt]

/*/{Protheus.doc} P145EndLog
Encerra as variaveis globais utilizadas para a gravação de logs
@type  Function
@author Lucas Fagundes
@since 21/03/2022
@version P12
@return Nil
/*/
Function P145EndLog()

	If GetGlbValue("P145MAIN") == "FIM" .and. GetGlbValue("P145JOBINT") == "FIM"
		ClearGlbValue("PCPA145PROCCV8")
		ClearGlbValue("PCPA145PROCIDCV8")
		ClearGlbValue("P145MAIN")
	EndIf

Return Nil

/*/{Protheus.doc} getGravOP
Retorna o valor do parâmetro MV_GRAVOP
@author Lucas Fagundes
@since 07/04/2022
@version P12
@return nGravOP, number, Valor do parâmetro MV_GRAVOP
/*/
METHOD getGravOP() Class ProcessaDocumentos
	Local nGravOP

	If Self:nGravOP == Nil
		Self:nGravOP := SuperGetMV("MV_GRAVOP", .F., 1)
		//Verifica se o parâmetro está com os valores válidos, caso contrário assume o valor padrão.
		If Empty(Self:nGravOP) .Or. Self:nGravOP > 4 .Or. Self:nGravOP < 1 
			Self:nGravOP := 1
		EndIf
	EndIf
	nGravOP := Self:nGravOP

Return nGravOP


/*/{Protheus.doc} usaNumOpPadrao
Retorna se deverá ser usado o número da OP seguindo a numeração padrão ou o campo informado em tela
@author Marcelo Neumann
@since 08/06/2022
@version P12
@param cFilAux, Character, Filial a ser verificada
@return lUsaNumPad, Logic, Indica se usa a numeração padrão ou a informada na tela
/*/
METHOD usaNumOpPadrao(cFilAux) Class ProcessaDocumentos
	Local lUsaNumPad := .T.

	If !VarGetXD(Self:cUIDGlobal, cFilAux + "USA_NUM_OP_PADRAO", lUsaNumPad)
		lUsaNumPad := (Empty(Self:cNumIniOP))
		Self:setaUsaNumOpPadrao(cFilAux, lUsaNumPad)
	EndIf

Return lUsaNumPad

/*/{Protheus.doc} setaUsaNumOpPadrao
Altera a flag que indica se usa o número da OPpadrão ou o campo informado em tela
@author Marcelo Neumann
@since 08/06/2022
@version P12
@param 01 cFilAux   , Character, Filial do processamento
@param 02 lUsaNumPad, Logic    , Indica se usa a numeração padrão ou a informada na tela
@return Nil
/*/
METHOD setaUsaNumOpPadrao(cFilAux, lUsaNumPad) Class ProcessaDocumentos

	VarSetXD(Self:cUIDGlobal, cFilAux + "USA_NUM_OP_PADRAO", lUsaNumPad)

Return

/*/{Protheus.doc} existeOP
Verifica se o número da OP passada já existe na SC2 (para evitar o erro de chave duplicada)
@author Marcelo Neumann
@since 08/06/2022
@version P12
@param 01 cFilOP, Character, Filial a ser verificada
@param 02 cNumOp, Character, Número da OP a ser verificada
@return lExiste , Logical  , Indica se a OP passada já existe na SC2
/*/
Static Function existeOP(cFilOP, cNumOp)
	Local lExiste := .F.
	Local nTamNumOP := GetSx3Cache("C2_NUM", "X3_TAMANHO")

	cNumOP := PadR(cNumOp, nTamNumOP)

	dbSelectArea("SC2")
	dbSetOrder(1)
	If SC2->(dbSeek(xFilial("SC2", cFilOP) + cNumOp)) .And. ;
	   SC2->C2_FILIAL == xFilial("SC2", cFilOP)       .And. ;
	   SC2->C2_NUM    == cNumOp

		lExiste := .T.
	EndIf

Return lExiste
