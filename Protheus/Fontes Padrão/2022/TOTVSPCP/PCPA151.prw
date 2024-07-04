#INCLUDE "TOTVS.CH"
#INCLUDE "PCPA151.CH"

//TODO: (definido com PO deixar como esta para clientes analisarem)
//1. Reduzir o número de consultas a SD4 visando otimizar performance. Consulta do metodo processarProduto() gastando muito tempo. Pode-se otimizar para os dados da consulta na master serem reaproveitados.
//2. Otimizar criacao da TRB PCPA151_OPS a partir de ticket do MRP realizando unico insert com todas as OPs
//3. Possibilidade de ganho de performance convertendo UM com dados em memoria

#DEFINE xPOS_aProdutos_PRODUTO     1
#DEFINE xPOS_aProdutos_LOCAL       2

#DEFINE xPOS_aUsados_LOTE          1
#DEFINE xPOS_aUsados_SUBLOTE       2
#DEFINE xPOS_aUsados_LOCALIZACAO   3
#DEFINE xPOS_aUsados_NUM_SERIE     4
#DEFINE xPOS_aUsados_QUANTIDADE    5
#DEFINE xPOS_aUsados_QTD_2UM       6
#DEFINE xPOS_aUsados_LOCAL_        7
#DEFINE xPOS_aUsados_VALIDADE      8

#DEFINE xPOS_aLotes_LOTE           1
#DEFINE xPOS_aLotes_SUBLOTE        2
#DEFINE xPOS_aLotes_LOCALIZACAO    3
#DEFINE xPOS_aLotes_NUM_SERIE      4
#DEFINE xPOS_aLotes_QUANTIDADE     5
#DEFINE xPOS_aLotes_QTD_2UM        6
#DEFINE xPOS_aLotes_VALIDADE       7
#DEFINE xPOS_aLotes_REGISTRO_SB2   8
#DEFINE xPOS_aLotes_REGISTRO_SBF   9
#DEFINE xPOS_aLotes_REGISTRO_SB8   10
#DEFINE xPOS_aLotes_LOCAL_         11
#DEFINE xPOS_aLotes_POTENCIA       12
#DEFINE xPOS_aLotes_BF_PRIOR       13

#DEFINE xPOS_aAddSD4_D4_FILIAL     1
#DEFINE xPOS_aAddSD4_D4_OP_        2
#DEFINE xPOS_aAddSD4_D4_DATA       3
#DEFINE xPOS_aAddSD4_D4_COD        4
#DEFINE xPOS_aAddSD4_D4_LOCAL      5
#DEFINE xPOS_aAddSD4_D4_QUANT      6
#DEFINE xPOS_aAddSD4_D4_QTDEORI    7
#DEFINE xPOS_aAddSD4_D4_TRT        8
#DEFINE xPOS_aAddSD4_D4_QTSEGUM    9
#DEFINE xPOS_aAddSD4_D4_OPORIG     10
#DEFINE xPOS_aAddSD4_D4_PRODUTO    11
#DEFINE xPOS_aAddSD4_D4_ROTEIRO    12
#DEFINE xPOS_aAddSD4_D4_OPERAC     13
#DEFINE xPOS_aAddSD4_D4_PRDORG     14
#DEFINE xPOS_aAddSD4_D4_QTNECES    15
#DEFINE xPOS_aAddSD4_D4_LOTECTL    16
#DEFINE xPOS_aAddSD4_D4_NUMLOTE    17
#DEFINE xPOS_aAddSD4_C2_TPOP       18
#DEFINE xPOS_aAddSD4_D4_DTVALID    19

#DEFINE xPOS_aAddSDC_DC_FILIAL     1
#DEFINE xPOS_aAddSDC_DC_ORIGEM     2
#DEFINE xPOS_aAddSDC_DC_PRODUTO    3
#DEFINE xPOS_aAddSDC_DC_LOCAL_     4
#DEFINE xPOS_aAddSDC_DC_LOTECTL    5
#DEFINE xPOS_aAddSDC_DC_NUMLOTE    6
#DEFINE xPOS_aAddSDC_DC_LOCALIZ    7
#DEFINE xPOS_aAddSDC_DC_NUMSERI    8
#DEFINE xPOS_aAddSDC_DC_QTDORIG    9
#DEFINE xPOS_aAddSDC_DC_QUANT      10
#DEFINE xPOS_aAddSDC_DC_QTSEGUM    11
#DEFINE xPOS_aAddSDC_DC_OP         12
#DEFINE xPOS_aAddSDC_DC_TRT        13
#DEFINE xPOS_aAddSDC_C2_TPOP       14

#DEFINE xPOS_aUpdSD4_RECNO         1
#DEFINE xPOS_aUpdSD4_D4_QUANT      2
#DEFINE xPOS_aUpdSD4_D4_QTDEORI    3
#DEFINE xPOS_aUpdSD4_D4_QTSEGUM    4
#DEFINE xPOS_aUpdSD4_D4_LOTECTL    5
#DEFINE xPOS_aUpdSD4_D4_NUMLOTE    6
#DEFINE xPOS_aUpdSD4_C2_TPOP       7
#DEFINE xPOS_aUpdSD4_D4_DTVALID    8

Static oSelf

/*/{Protheus.doc} PCPA151
Sugere Lotes e Enderecos nos Empenhos
@type  Function
@author brunno.costa
@since 04/06/2020
@version P12.1.27
@param 01 - oOps        , Objeto  , JsonObject com as informações de OPS por filial para processamento
@param 02 - lDeTerceiros, logico  , indica se consome quantidade de terceiros em nosso poder
@param 03 - lEmTerceiros, logico  , indica se consume quantidade nossa em porder de terceiros
@param 04 - cEmpAux     , caracter, codigo da empresa
@param 05 - cFilAux     , caracter, codigo da filial
@param 06 - cTicket     , caracter, número do ticket de processamento do MRP
@return Nil
/*/
Function PCPA151(oOps, lDeTerceiros, lEmTerceiros, cEmpAux, cFilAux, cTicket)

	Local oPCPLock     := PCPLockControl():New()
	Local bError       := ErrorBlock({|e| A151Error(e) })

	/*nEspera, nNumerico, indica o comportamento relacionado a espera e falha na tentativa de reserva: PCPLockControl
	0 - Não aguarda lock e não exibe help
	1 - Não aguarda lock e exibe Help de Falha
	2 - Aguarda para fazer lock e não exibe tela de aguarde;
	3 - Aguarda para fazer lock e exibe tela de aguarde;*/
	Local nEspera      := 3

	If !Empty(cEmpAux)
		RpcSetType(3)
		RpcSetEnv(cEmpAux, cFilAux, Nil, Nil, "PCP", Nil,,,/*9-lShowFinal->lMsFinalAuto*/)
		dbSelectArea("SB1")
		dbSelectArea("SB2")
	EndIf

	If oPCPLock:lock("MRP_MEMORIA", "PCPA151", , .F., {}, nEspera, nEsperaMax)
		If SuperGetMV("MV_CONSEST") == "S"
			PutGlbValue(cTicket+"PCPA151_STATUS","INI")
			If oSelf == Nil
				oSelf := SugestaoLotesEnderecos():New(NIL, lDeTerceiros, lEmTerceiros,,, cTicket)
			EndIf
			oSelf:processar(oOps)
			PutGlbValue(cTicket+"PCPA151_STATUS","END")
			oSelf:destroy()
			oSelf := Nil
		EndIf
	EndIf

	oPCPLock:unlock("MRP_MEMORIA", "PCPA151")
	ErrorBlock(bError)

Return Nil

/*/{Protheus.doc} A151Error
Função para tratativa de erros de execução

@type  Function
@author brunno.costa
@since 18/08/2020
@version P12.1.27
@param e    , Object  , Objeto com os detalhes do erro ocorrido
/*/
Function A151Error(e)
	Local oPCPLock   := PCPLockControl():New()
	LogMsg('PCPA151', 0, 0, 1, '', '', ;
	       Replicate("-",70) + CHR(10) + AllTrim(e:description) + CHR(10) + AllTrim(e:ErrorStack) + CHR(10) + Replicate("-",70))
	oPCPLock:unlock("MRP_MEMORIA", "PCPA151")
	BREAK
Return


/*/{Protheus.doc} PCPA151THR
Sugere Lotes e Enderecos nos Empenhos - Thread por Produto
@type  Function
@author brunno.costa
@since 04/06/2020
@version P12.1.27
@param 01 - cFilProc    , caracter, código da filial para processamento
@param 02 - cUIDExecucao, caracter, codigo do ID de execucao
@param 03 - cProduto    , caracter, codigo do produto
@param 04 - cLocal      , caracter, local do produto
@param 05 - cTicket     , caracter, número do ticket de processamento
@param 06 - nSaldoIni   , numérico, saldo inicial (necessário quando Gera Documentos = Firmes)
@return Nil
/*/
Function PCPA151THR(cFilProc, cUIDExecucao, cProduto, cLocal, cTicket, nSaldoIni)
	Local nParcial := 1

	If oSelf == Nil
		oSelf := SugestaoLotesEnderecos():New(cUIDExecucao,,,,, cTicket)
	EndIf

	If cFilAnt != cFilProc
		cFilAnt := cFilProc
		oSelf:carregaParametros()
	EndIf

	oSelf:processarProduto(cProduto, cLocal, nSaldoIni)
	oSelf:setFlagGlobal("PERCENTUAL_PARCIAL", @nParcial, /*lError*/, .T./*lInc*/)
Return Nil

/*/{Protheus.doc} PCPA151T
Sugere Lotes e Enderecos nos Empenhos - Referente Ticket do PCPA712
@type  Function
@author brunno.costa
@since 04/06/2020
@version P12.1.27
@param 01 - cTicket  , caracter, código do ticket de execucao do MRP
@param 02 - cErrorUID, caracter,  codigo identificador do controle de erros multi-thread
@return Nil
/*/
Function PCPA151T(cTicket, cErrorUID)

	Local aParMRP      := {}
	Local cError       := ""
	Local lDeTerceiros := .F.
	Local lEmTerceiros := .F.
	Local lGeraFirme   := .F.
	Local nPos         := 0
	Local oJsonPar     := JsonObject():New()
	Local oPCPLock     := PCPLockControl():New()
	Local oOps         := Nil

	Default lAutoMacao := .F.

	If SuperGetMV("MV_CONSEST") == "S"
		aParMRP := MrpGetPar(cFilAnt, cTicket, "ticket,parameter,value,list",,,9999,"Parametros")
		cError  := oJsonPar:FromJson(aParMRP[2])
		aParMRP := oJsonPar["items"]
		If Empty(cError)
			//Recupera o parâmetro DE Terceiros
			nPos := aScan(aParMRP, {|x| AllTrim(x["parameter"]) == "consignedIn"}) //lDeTerceiros
			If nPos > 0
				lDeTerceiros := aParMRP[nPos]["value"] == "1"
			EndIf

			//Recupera o parâmetro EM Terceiros
			nPos := aScan(aParMRP, {|x| AllTrim(x["parameter"]) == "consignedOut"}) //lEmTerceiros
			If nPos > 0
				lEmTerceiros := aParMRP[nPos]["value"] == "1"
			EndIf

			//Recupera o parâmetro Gerar Documentos
			nPos := aScan(aParMRP, {|x| AllTrim(x["parameter"]) == "productionOrderType"}) //"Gerar Documentos"
			If nPos > 0
				lGeraFirme := aParMRP[nPos]["value"] == "2"
			EndIf
		EndIf

		dbSelectArea("SB1")
		dbSelectArea("SB2")

		PutGlbValue(cTicket + "PCPA151_STATUS","INI")
		If oSelf == Nil
			oSelf := SugestaoLotesEnderecos():New(NIL, lDeTerceiros, lEmTerceiros, , cErrorUID, cTicket)
		EndIf

		oSelf:lGeraFirme := lGeraFirme
		oOPs := oSelf:getOPsTicketMRP(cTicket)

		IF !lAutoMacao
			oSelf:processar(oOPs)
		ENDIF
		oSelf:destroy()
		oSelf := Nil
		FreeObj(oOPs)
	EndIf

	PutGlbValue(cTicket + "PCPA151_STATUS","END")
	oPCPLock:unlock("MRP_MEMORIA", "PCPA151", cTicket)

Return Nil

/*/{Protheus.doc} SugestaoLotesEnderecos
Classe para controle do processo de sugestao de lotes e enderecos
@author brunno.costa
@since 04/06/2020
@version P12.1.27
/*/
CLASS SugestaoLotesEnderecos FROM LongClassName

	DATA aOPs            AS Array
	DATA cBF_NUMLOTE     AS Character
	DATA cBF_NUMSERI     AS Character
	DATA cErrorUID       AS Character
	DATA cFilSB2         AS Character
	DATA cTicket         AS Character
	DATA cUIDExecucao    AS Character
	DATA nThreads        AS Numeric
	DATA lEmpenhaProjeto AS Logical
	DATA lEmTerceiros    AS Logical
	DATA lDeTerceiros    AS Logical
	DATA lNovoWMS		 AS Logical
	DATA lSomaPrevistas  AS Logical
	DATA lGeraFirme      AS Logical
	DATA oSaldos         AS Object

	//Metodos Publicos
	METHOD new(cUIDExecucao, lDeTerceiros, lEmTerceiros, lConsulta, cErrorUID, cTicket, cIdGlobal) CONSTRUCTOR
	METHOD destroy()
	METHOD getProgress(cTicket)
	METHOD processar(oOps)
	METHOD retornaSugestao(cProduto, cLocal, nQtd, cRastro, cLocaliza, cData, cTipoDoc, lBaixaEmp)

	//Metodos Internos - Regra de Negocio
	METHOD atualizaUsados(aSaldo, oJsData)
	METHOD avaliaSaldos(oJsData, cAliasSD4, oJsInfoPrd, lPrepEmpen, lBaixaEmp)
	method converte2UM(cProduto, nQuantidade)
	METHOD getOPsTicketMRP(cTicket)
	METHOD getProdutos()
	METHOD getSB2Saldo(cProduto, cLocal, oJsData)
	METHOD getSBFSaldo(cProduto, cLocal, cEndereco, cLote, cSubLote, cNumSeri)
	METHOD menorSaldo(cRastro, cLocaliz, nSldSB8, nSldSB2, nSldSBF)
	METHOD preparaGravacoes(aSaldo, oJsData, cAliasSD4)
	METHOD preparaSD4(aSaldo, oJsData, cAliasSD4)
	METHOD preparaSDC(aSaldo, oJsData, cAliasSD4)
	METHOD processarProduto(cProduto, cLocal, nSaldoIni)
	METHOD criaTabelaTemporariaOPs()
	METHOD carregaParametros()

	//Metodos de Gravacao
	METHOD gravaAlteracoes(oJsData)
	METHOD addSD4(aAddSD4, lSeek)
	METHOD addSDC(aAddSDC)
	METHOD updSD4(aUpdSD4)
	METHOD updSB8(cNumLote, cLoteCtl, cProduto, cLocal, nQtEmp, cTipo)
	METHOD updSBF(cNumLote, cLoteCtl, cProduto, cLocal, nQtEmp, cEndereco, cNumSeri, cTipo)

	//Controle Transacao Banco
	METHOD travaRegistro(cAlias, nIndice, cChave, aTravas, lPosicionado)
	METHOD destravaRegistros(aTravas)

	//Scripts SQLs
	METHOD scriptC2OP(lNoAlias)
	METHOD scriptJoin(cColuna)
	METHOD scriptFromWhere(cProduto, cLocal)

	//Controle Processamento Multi-Thread
	METHOD abreThreads()
	METHOD aguardaTermino()
	METHOD delegaProduto(cFilProc, cProduto, cLocal)
	METHOD fechaThreads()

	//Controle Variaveis Globais
	METHOD criarSessaoGlobal()
	METHOD destravaGlobal(cChave)
	METHOD getFlagGlobal(cChave, lError, lLog)
	METHOD setFlagGlobal(cChave, oFlag, lError)
	METHOD travaGlobal(cChave)

ENDCLASS

/*/{Protheus.doc} new
Método construtor da classe de sugestao de lotes e enderecos dos empehos
@type  Method
@author brunno.costa
@since 04/06/2020
@version P12.1.27
@param 01 - cUIDExecucao, caracter, codigo do ID de execucao
@param 02 - lDeTerceiros, logico  , indica se consome quantidade de terceiros em nosso poder
@param 03 - lEmTerceiros, logico  , indica se consume quantidade nossa em porder de terceiros
@param 04 - lConsulta   , logico  , indica instanciamento apenas para consulta de progresso
@param 05 - cErrorUID   , caracter, codigo identificador do controle de erros multi-thread
@param 06 - cTicket     , caracter, número do ticket de processamento
@param 07 - cIdGlobal   , caracter, identificador do processo chamador (para controle de globais)
@return Self, objeto, instancia da classe
/*/
METHOD new(cUIDExecucao, lDeTerceiros, lEmTerceiros, lConsulta, cErrorUID, cTicket, cIdGlobal) CLASS SugestaoLotesEnderecos

	Default cUIDExecucao := ""
	Default lDeTerceiros := .F.
	Default lEmTerceiros := .F.
	Default lConsulta    := .F.
	Default cIdGlobal    := "PCPA151_"

	Self:aOPs    := {}
	Self:cTicket := cTicket
	Self:oSaldos := JsonObject():New()

	If Empty(cUIDExecucao) .AND. !lConsulta
		Self:cUIDExecucao := cIdGlobal + Self:cTicket
		Self:criarSessaoGlobal()
		Self:lDeTerceiros := lDeTerceiros
		Self:lEmTerceiros := lEmTerceiros
		Self:cErrorUID    := cErrorUID
		Self:setFlagGlobal("lDeTerceiros", Self:lDeTerceiros)
		Self:setFlagGlobal("lEmTerceiros", Self:lEmTerceiros)
		Self:setFlagGlobal("cErrorUID"   , Self:cErrorUID   )

	Else
		If lConsulta
			Self:cUIDExecucao := cIdGlobal + Self:cTicket
			Self:lDeTerceiros := Self:getFlagGlobal("lDeTerceiros",, .F.)
			Self:lEmTerceiros := Self:getFlagGlobal("lEmTerceiros",, .F.)
			Self:cErrorUID    := Self:getFlagGlobal("cErrorUID"   ,, .F.)
		Else
			Self:cUIDExecucao := cUIDExecucao
			Self:lDeTerceiros := Self:getFlagGlobal("lDeTerceiros")
			Self:lEmTerceiros := Self:getFlagGlobal("lEmTerceiros")
			Self:cErrorUID    := Self:getFlagGlobal("cErrorUID")
		EndIf

	EndIf

	Self:nThreads    := 8
	Self:cBF_NUMLOTE := CriaVar("BF_NUMLOTE")
	Self:cBF_NUMSERI := CriaVar("BF_NUMSERI")
	Self:carregaParametros()

Return Self

/*/{Protheus.doc} processar
Dispara o processamento da sugestao de lotes e enderecos
@type  Method
@author brunno.costa
@since 04/06/2020
@version P12.1.27
@param 01 - oOPs, objeto, JsonObject com as informações das OPs por filial para processamento
/*/
METHOD processar(oOPs) CLASS SugestaoLotesEnderecos

	Local aFiliais   := oOps:GetNames()
	Local cLocal     := ""
	Local cProduto   := ""
	Local cFilBkp    := cFilAnt
	Local cFilProc   := ""
	Local nTamFilial := FwSizeFilial()
	Local nTotFilial := Len(aFiliais)
	Local nIndProd   := 0
	Local nIndex     := 0
	Local nProdutos  := 0
	Local nSeconds   := MicroSeconds()

	LogMsg("PCPA151", 0, 0, 1, "", "", "PCPA151 - " + STR0001 + " - " + Time()) //Inicio do processamento

	Self:abreThreads()

	//Obtém os produtos que serão processados em cada filial
	For nIndex := 1 To nTotFilial
		aSize(Self:aOps, 0)
		Self:aOPs := oOPs[aFiliais[nIndex]]

		//Ajusta a filial de acordo com as ordens que serão processadas.
		If cFilAnt != PadR(aFiliais[nIndex], nTamFilial)
			cFilAnt := PadR(aFiliais[nIndex], nTamFilial)
		EndIf

		oOPs[aFiliais[nIndex] + "PRD"] := Self:getProdutos()
		nProdutos += Len(oOPs[aFiliais[nIndex] + "PRD"])
	Next nIndex

	//Seta o contador total de produtos
	Self:setFlagGlobal("PERCENTUAL_TOTAL", nProdutos)

	For nIndex := 1 To nTotFilial
		nProdutos := Len(oOPs[aFiliais[nIndex] + "PRD"])
		cFilProc  := PadR(aFiliais[nIndex], nTamFilial)
		For nIndProd := 1 to nProdutos
			cProduto := oOPs[aFiliais[nIndex] + "PRD"][nIndProd][xPOS_aProdutos_PRODUTO]
			cLocal   := oOPs[aFiliais[nIndex] + "PRD"][nIndProd][xPOS_aProdutos_LOCAL]
			Self:delegaProduto(cFilProc, cProduto, cLocal)
		Next
	Next nIndex

	Self:aguardaTermino()

	Self:fechaThreads()

	//Retorna filial original se necessário
	If cFilAnt != cFilBkp
		cFilAnt := cFilBkp
	EndIf

	LogMsg("PCPA151", 0, 0, 1, "", "", "PCPA151 - " + STR0002 + " - " + Time() + " - " + STR0003 + ": " + cValToChar(MicroSeconds() - nSeconds) + " " + STR0004) // Termino do processamento + Tempo + segundos

Return

/*/{Protheus.doc} processar
Dispara o processamento da sugestao de lotes e enderecos
@type  Method
@author brunno.costa
@since 04/06/2020
@version P12.1.27
@param 01 - cProduto , caracter, codigo do produto
@param 02 - cLocal   , caracter, codigo do armazem
@param 03 - nSaldoIni, numérico, saldo inicial (necessário quando Gera Documentos = Firmes)
/*/
METHOD processarProduto(cProduto, cLocal, nSaldoIni) CLASS SugestaoLotesEnderecos

	Local aTravas     := {}
	Local cAliasSD4   := GetNextAlias()
	Local cQuerySD4   := ""
	Local oJsData     := JsonObject():New()
	Default nSaldoIni := 0

	oJsData["aTravas"] := aTravas
	oJsData["aAddSD4"] := {}
	oJsData["aAddSDC"] := {}
	oJsData["aUpdSD4"] := {}
	oJsData["aUsados"] := {} //Lotes Usados

	If nSaldoIni == 0
		nSaldoIni := Self:getSB2Saldo(cProduto, cLocal, oJsData)
	EndIf
	oJsData["nSldSB2"] := nSaldoIni

	cQuerySD4 := "SELECT SD4.R_E_C_N_O_ SD4RECNO "
	cQuerySD4 +=      ", SD4.D4_FILIAL "
	cQuerySD4 +=      ", SD4.D4_OP "
	cQuerySD4 +=      ", SD4.D4_DATA "
	cQuerySD4 +=      ", SD4.D4_COD "
	cQuerySD4 +=      ", SD4.D4_LOCAL "
	cQuerySD4 +=      ", SD4.D4_QUANT "
	cQuerySD4 +=      ", SD4.D4_QTDEORI "
	cQuerySD4 +=      ", SD4.D4_TRT "
	cQuerySD4 +=      ", SD4.D4_QTSEGUM "
	cQuerySD4 +=      ", SD4.D4_OPORIG "
	cQuerySD4 +=      ", SD4.D4_PRODUTO "
	cQuerySD4 +=      ", SD4.D4_ROTEIRO "
	cQuerySD4 +=      ", SD4.D4_OPERAC "
	cQuerySD4 +=      ", SD4.D4_PRDORG "
	cQuerySD4 +=      ", SD4.D4_QTNECES "
	cQuerySD4 +=      ", SD4.D4_NUMLOTE "
	cQuerySD4 +=      ", SD4.D4_LOTECTL "
	cQuerySD4 +=      ", SC2.C2_TPOP "
	cQuerySD4 +=      ", SB1.B1_RASTRO "
	cQuerySD4 +=      ", SB1.B1_LOCALIZ "
	cQuerySD4 += Self:scriptFromWhere(cProduto, cLocal)

	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuerySD4), cAliasSD4, .F., .F.)
	While !(cAliasSD4)->(Eof())
		Self:avaliaSaldos(@oJsData, cAliasSD4, /*oJsInfoPrd*/, .T.)
		(cAliasSD4)->(dbSkip())
	EndDo
	(cAliasSD4)->(dbCloseArea())

	Self:gravaAlteracoes(oJsData)
	Self:destravaRegistros(aTravas)

	aSize(oJsData["aAddSD4"], 0 )
	aSize(oJsData["aAddSDC"], 0 )
	aSize(oJsData["aUpdSD4"], 0 )
	aSize(oJsData["aUsados"], 0 )
	FreeObj(oJsData)
	oJsData := Nil

Return

/*/{Protheus.doc} retornaSugestao
Retorna a sugestão de lote e endereço do produto
@type Method
@author marcelo.neumann
@since 17/02/2022
@version P12
@param 01 - cProduto , caracter, produto a ser avaliado
@param 02 - cLocal   , caracter, local do produto
@param 03 - nQtd     , numérico, quantidade a ser avaliada
@param 04 - cRastro  , caracter, indicador de Rastro
@param 05 - cLocaliza, caracter, indicador de Localização
@param 06 - cData    , caracter, data referência para a avaliação do saldo
@param 07 - cTipoDoc , caracter, tipo do documento (Firme/Previsto)
@param 08 - lBaixaEmp, lógico  , indica se está baixando material empenhado ou não
/*/
METHOD retornaSugestao(cProduto, cLocal, nQtd, cRastro, cLocaliza, cData, cTipoDoc, lBaixaEmp) CLASS SugestaoLotesEnderecos
	Local oJsData    := JsonObject():New()
	Local oJsInfoPrd := JsonObject():New()

	oJsData["aTravas"] := {}
	oJsData["aAddSD4"] := {}
	oJsData["aAddSDC"] := {}
	oJsData["aUpdSD4"] := {}
	oJsData["aUsados"] := {}
	oJsData["nSldSB2"] := Self:getSB2Saldo(cProduto, cLocal, oJsData)

	oJsInfoPrd["cCodPro"]   := cProduto
	oJsInfoPrd["cLocal"]    := cLocal
	oJsInfoPrd["nQtd"]      := nQtd
	oJsInfoPrd["nQtd2UM"]   := Self:converte2UM(cProduto, nQtd)
	oJsInfoPrd["cRastro"]   := cRastro
	oJsInfoPrd["cLocaliza"] := cLocaliza
	oJsInfoPrd["dDataRef"]  := cData
	oJsInfoPrd["cTipoDoc"]  := cTipoDoc

	Self:avaliaSaldos(oJsData, /*cAliasSD4*/, oJsInfoPrd, .F., lBaixaEmp)

	FreeObj(oJsInfoPrd)

Return oJsData["aUsados"]

/*/{Protheus.doc} avaliaSaldos
Avalia e sugere Saldos Lotes e Endereco
@type  Method
@author brunno.costa
@since 04/06/2020
@version P12.1.27
@param 01 - oJsData   , objeto  , objeto Json de controle:
                                  oJsData["aTravas"] - Array de controle de alias e Recnos Bloqueados pela Thread {{cAlias, nRecno},...}
                                  oJsData["aAddSD4"] - Array de controle conforme xPOS_aAddSD4
                                  oJsData["aAddSDC"] - Array de controle conforme xPOS_aAddSDC
                                  oJsData["aUpdSD4"] - Array de controle conforme xPOS_aUpdSD4
                                  oJsData["aUsados"] - Array de controle conforme xPOS_aUsados
                                  oJsData["nSldSB2"] - Saldo do produto na SB2
@param 02 - cAliasSD4 , caracter, alias da SD4 criado em query para consulta dos registros relacionados
@param 03 - oJsInfoPrd, objeto  , objeto Json com as informações do produto a ser avaliado (substitui a consulta cAliasSD4)
@param 04 - lPrepEmpen, lógico  , indica se devem ser preparadas as inclusões/alterações nas tabelas de empenho
@param 05 - lBaixaEmp , lógico  , indica se está baixando material empenhado ou não
/*/
METHOD avaliaSaldos(oJsData, cAliasSD4, oJsInfoPrd, lPrepEmpen, lBaixaEmp) CLASS SugestaoLotesEnderecos
	Local aLotes       := {}
	Local aSaldo       := {}
	Local aTravas      := oJsData["aTravas"]
	Local aUsados      := oJsData["aUsados"]
	Local lConsVenc    := IIf(SuperGetMV("MV_LOTVENC" , .F. ,'S') == "S", .T., .F.)
	Local lEmpPrevisto := .F.
	Local nEmpOrig     := 0
	Local nEmpReal     := 0
	Local nIndLote     := 0
	Local nLotes       := 0
	Local nSldSBF      := 0
	Default lBaixaEmp  := .T.

	If oJsInfoPrd == Nil
		oJsInfoPrd := JsonObject():New()
		oJsInfoPrd["cCodPro"]   := (cAliasSD4)->D4_COD
		oJsInfoPrd["cLocal"]    := (cAliasSD4)->D4_LOCAL
		oJsInfoPrd["nQtd"]      := (cAliasSD4)->D4_QUANT
		oJsInfoPrd["nQtd2UM"]   := (cAliasSD4)->D4_QTSEGUM
		oJsInfoPrd["dDataRef"]  := SToD((cAliasSD4)->D4_DATA)
		oJsInfoPrd["cRastro"]   := (cAliasSD4)->B1_RASTRO
		oJsInfoPrd["cLocaliza"] := (cAliasSD4)->B1_LOCALIZ
		oJsInfoPrd["cTipoDoc"]  := (cAliasSD4)->C2_TPOP
	EndIf

	nEmpOrig := oJsInfoPrd["nQtd"]

	lEmpPrevisto := IIf(oJsInfoPrd["cTipoDoc"] == "F", Self:lSomaPrevistas .And. !PotencLote(oJsInfoPrd["cCodPro"]), .T.)

	aLotes := SldPorLote(oJsInfoPrd["cCodPro"]  /*cCodPro*/     ,;
	                     oJsInfoPrd["cLocal"]   /*cLocal*/      ,;
	                     oJsInfoPrd["nQtd"]     /*nQtd*/        ,;
	                     oJsInfoPrd["nQtd2UM"]  /*nQtd2UM*/     ,;
	                     NIL                    /*cLoteCtl*/    ,;
	                     NIL                    /*cNumLote*/    ,;
	                     NIL                    /*cLocaliza*/   ,;
	                     NIL                    /*cNumSer*/     ,;
	                     aTravas                /*aTravas*/     ,;
	                     lBaixaEmp              /*lBaixaEmp*/   ,;
	                     NIL                    /*cLocalAte*/   ,;
	                     lConsVenc              /*lConsVenc*/   ,;
						 aUsados                /*aLotesFil*/   ,;
	                     lEmpPrevisto           /*lEmpPrevisto*/,;
						 oJsInfoPrd["dDataRef"] /*dDataRef*/     )

	nLotes := Len(aLotes)
	For nIndLote := 1 To nLotes
		aSaldo  := aLotes[nIndLote]
		nSldSBF := Self:getSBFSaldo(oJsInfoPrd["cCodPro"]          ,;
		                            oJsInfoPrd["cLocal"]           ,;
		                            aSaldo[xPOS_aLotes_LOCALIZACAO],;
		                            aSaldo[xPOS_aLotes_LOTE]       ,;
		                            aSaldo[xPOS_aLotes_SUBLOTE]    ,;
									aSaldo[xPOS_aLotes_NUM_SERIE]   )

		aSaldo[xPOS_aLotes_QUANTIDADE] := Self:menorSaldo(oJsInfoPrd["cRastro"], oJsInfoPrd["cLocaliza"], aSaldo[xPOS_aLotes_QUANTIDADE], oJsData["nSldSB2"], nSldSBF)
		nEmpReal                       += aSaldo[xPOS_aLotes_QUANTIDADE]
		aSaldo[xPOS_aLotes_QTD_2UM]    := Self:converte2UM(oJsInfoPrd["cCodPro"] , aSaldo[xPOS_aLotes_QUANTIDADE])
		oJsData["nSldSB2"]             -= aSaldo[xPOS_aLotes_QUANTIDADE]
		Self:atualizaUsados(aSaldo, @oJsData)

		If aSaldo[xPOS_aLotes_QUANTIDADE] != 0
			If lPrepEmpen
				Self:preparaGravacoes(aSaldo, @oJsData, cAliasSD4)
			EndIf
		EndIf
	Next nIndLote

	If nLotes > 0 .AND. nEmpOrig > nEmpReal
		aSaldo := aCLone(aSaldo)
		aSaldo[xPOS_aLotes_LOCALIZACAO] := ""
		aSaldo[xPOS_aLotes_NUM_SERIE  ] := ""
		aSaldo[xPOS_aLotes_LOTE       ] := ""
		aSaldo[xPOS_aLotes_VALIDADE   ] := StoD("")
		aSaldo[xPOS_aLotes_SUBLOTE    ] := ""
		aSaldo[xPOS_aLotes_QUANTIDADE ] := nEmpOrig - nEmpReal
		aSaldo[xPOS_aLotes_QTD_2UM    ] := Self:converte2UM(oJsInfoPrd["cCodPro"] , aSaldo[xPOS_aLotes_QUANTIDADE])

		If lPrepEmpen
			Self:preparaGravacoes(aSaldo, @oJsData, cAliasSD4)
		EndIf
	EndIf

Return

/*/{Protheus.doc} atualizaUsados
Atualiza Controle de Lotes Usados
@type  Method
@author brunno.costa
@since 04/06/2020
@version P12.1.27
@param 01 - aSaldo, array, linha especifica do lote am analise conforme xPOS_aLotes
@param 02 - oJsData, objeto, instancia de objeto Json de controle:
	oJsData["aTravas"] - Array de controle de alias e Recnos Bloqueados pela Thread {{cAlias, nRecno},...}
	oJsData["aAddSD4"] - Array de controle conforme xPOS_aAddSD4
	oJsData["aAddSDC"] - Array de controle conforme xPOS_aAddSDC
	oJsData["aUpdSD4"] - Array de controle conforme xPOS_aUpdSD4
	oJsData["aUsados"] - Array de controle conforme xPOS_aUsados
	oJsData["nSldSB2"] - Saldo do produto na SB2
/*/
METHOD atualizaUsados(aSaldo, oJsData) CLASS SugestaoLotesEnderecos

	Local aUsados  := oJsData["aUsados"] //Lotes Usados
	Local nIndScan := 0

	//Atualiza Controle aUsados
	nIndScan := aScan(aUsados,{|x| x[xPOS_aUsados_LOTE       ] == aSaldo[xPOS_aLotes_LOTE       ];
							 .And. x[xPOS_aUsados_SUBLOTE    ] == aSaldo[xPOS_aLotes_SUBLOTE    ];
							 .And. x[xPOS_aUsados_LOCALIZACAO] == aSaldo[xPOS_aLotes_LOCALIZACAO];
							 .And. x[xPOS_aUsados_NUM_SERIE  ] == aSaldo[xPOS_aLotes_NUM_SERIE  ];
							  })

	If nIndScan == 0
		aAdd(aUsados, {aSaldo[xPOS_aLotes_LOTE                  ],;
					   aSaldo[xPOS_aLotes_SUBLOTE               ],;
					   aSaldo[xPOS_aLotes_LOCALIZACAO           ],;
					   aSaldo[xPOS_aLotes_NUM_SERIE             ],;
					   aSaldo[xPOS_aLotes_QUANTIDADE            ],;
					   aSaldo[xPOS_aLotes_QTD_2UM               ],;
					   aSaldo[xPOS_aLotes_LOCAL_                ],;
					   aSaldo[xPOS_aLotes_VALIDADE              ],;
					   })

	Else
		aUsados[nIndScan, xPOS_aUsados_QUANTIDADE] += aSaldo[xPOS_aLotes_QUANTIDADE]
		aUsados[nIndScan, xPOS_aUsados_QTD_2UM]    += aSaldo[xPOS_aLotes_QTD_2UM]

	EndIf

Return

/*/{Protheus.doc} preparaGravacoes
Prepara Dados para Gravacao no Banco de Dados
@type  Method
@author brunno.costa
@since 04/06/2020
@version P12.1.27
@param 01 - aSaldo, array, linha especifica do lote am analise conforme xPOS_aLotes
@param 02 - oJsData, objeto, instancia de objeto Json de controle:
	oJsData["aTravas"] - Array de controle de alias e Recnos Bloqueados pela Thread {{cAlias, nRecno},...}
	oJsData["aAddSD4"] - Array de controle conforme xPOS_aAddSD4
	oJsData["aAddSDC"] - Array de controle conforme xPOS_aAddSDC
	oJsData["aUpdSD4"] - Array de controle conforme xPOS_aUpdSD4
	oJsData["aUsados"] - Array de controle conforme xPOS_aUsados
	oJsData["nSldSB2"] - Saldo do produto na SB2
@param 03 - cAliasSD4, caracter, alias da SD4 criado em query para consulta dos registros relacionados
/*/
METHOD preparaGravacoes(aSaldo, oJsData, cAliasSD4) CLASS SugestaoLotesEnderecos

	If (cAliasSD4)->B1_RASTRO $ "LS" .AND. Empty((cAliasSD4)->D4_LOTECTL)
		Self:preparaSD4(aSaldo, @oJsData, cAliasSD4)
	EndIf

	If (cAliasSD4)->B1_LOCALIZ == "S"
		Self:preparaSDC(aSaldo, @oJsData, cAliasSD4)
	EndIf

Return

/*/{Protheus.doc} preparaSD4
Prepara gravacoes da SD4
@type  Method
@author brunno.costa
@since 04/06/2020
@version P12.1.27
@param 01 - aSaldo, array, linha especifica do lote am analise conforme xPOS_aLotes
@param 02 - oJsData, objeto, instancia de objeto Json de controle:
	oJsData["aTravas"] - Array de controle de alias e Recnos Bloqueados pela Thread {{cAlias, nRecno},...}
	oJsData["aAddSD4"] - Array de controle conforme xPOS_aAddSD4
	oJsData["aAddSDC"] - Array de controle conforme xPOS_aAddSDC
	oJsData["aUpdSD4"] - Array de controle conforme xPOS_aUpdSD4
	oJsData["aUsados"] - Array de controle conforme xPOS_aUsados
	oJsData["nSldSB2"] - Saldo do produto na SB2
@param 03 - cAliasSD4, caracter, alias da SD4 criado em query para consulta dos registros relacionados
/*/
METHOD preparaSD4(aSaldo, oJsData, cAliasSD4) CLASS SugestaoLotesEnderecos

	Local aAddSD4      := oJsData["aAddSD4"]
	Local aUpdSD4      := oJsData["aUpdSD4"]
	Local nIndScan     := 0
	Default lAutoMacao := .F.

	//Atualiza Controles da SD4
	nIndScan := aScan(aUpdSD4,{|x| x[xPOS_aUpdSD4_RECNO] == (cAliasSD4)->SD4RECNO})
	If nIndScan == 0
		aAdd(aUpdSD4, {IIF(!lAutoMacao, (cAliasSD4)->SD4RECNO, 0) ,; //xPOS_aUpdSD4_RECNO
		               aSaldo[xPOS_aLotes_QUANTIDADE]             ,; //xPOS_aUpdSD4_D4_QUANT
		               aSaldo[xPOS_aLotes_QUANTIDADE]             ,; //xPOS_aUpdSD4_D4_QTDEORI
		               aSaldo[xPOS_aLotes_QTD_2UM]                ,; //xPOS_aUpdSD4_D4_QTSEGUM
		               aSaldo[xPOS_aLotes_LOTE   ]                ,; //xPOS_aUpdSD4_D4_LOTECTL
		               aSaldo[xPOS_aLotes_SUBLOTE]                ,; //xPOS_aUpdSD4_D4_NUMLOTE
		               IIF(!lAutoMacao, (cAliasSD4)->C2_TPOP,"1") ,; //xPOS_aUpdSD4_C2_TPOP
		               aSaldo[xPOS_aLotes_VALIDADE]               ,; //xPOS_aUpdSD4_D4_DTVALID
		              })

	Else

		If aSaldo[xPOS_aLotes_LOTE   ] == aUpdSD4[nIndScan][xPOS_aUpdSD4_D4_LOTECTL] .AND.;
		   aSaldo[xPOS_aLotes_SUBLOTE] == aUpdSD4[nIndScan][xPOS_aUpdSD4_D4_NUMLOTE]

			aUpdSD4[nIndScan][xPOS_aUpdSD4_D4_QUANT]   += aSaldo[xPOS_aLotes_QUANTIDADE]
			aUpdSD4[nIndScan][xPOS_aUpdSD4_D4_QTDEORI] += aSaldo[xPOS_aLotes_QUANTIDADE]
			aUpdSD4[nIndScan][xPOS_aUpdSD4_D4_QTSEGUM] += aSaldo[xPOS_aLotes_QTD_2UM]

		Else
			nIndScan := aScan(aAddSD4,{|x|   x[xPOS_aAddSD4_D4_FILIAL ] == (cAliasSD4)->D4_FILIAL     ;
									   .AND. x[xPOS_aAddSD4_D4_OP_    ] == (cAliasSD4)->D4_OP         ;
									   .AND. x[xPOS_aAddSD4_D4_TRT    ] == (cAliasSD4)->D4_TRT        ;
									   .AND. x[xPOS_aAddSD4_D4_OPORIG ] == (cAliasSD4)->D4_OPORIG     ;
									   .AND. x[xPOS_aAddSD4_D4_LOTECTL] == aSaldo[xPOS_aLotes_LOTE]   ;
									   .AND. x[xPOS_aAddSD4_D4_NUMLOTE] == aSaldo[xPOS_aLotes_SUBLOTE];
									   })

			If nIndScan == 0
				aAdd(aAddSD4, { (cAliasSD4)->D4_FILIAL        ,; //xPOS_aAddSD4_D4_FILIAL
								(cAliasSD4)->D4_OP            ,; //xPOS_aAddSD4_D4_OP_
								(cAliasSD4)->D4_DATA          ,; //xPOS_aAddSD4_D4_DATA
								(cAliasSD4)->D4_COD           ,; //xPOS_aAddSD4_D4_COD
								(cAliasSD4)->D4_LOCAL         ,; //xPOS_aAddSD4_D4_LOCAL
								aSaldo[xPOS_aLotes_QUANTIDADE],; //xPOS_aAddSD4_D4_QUANT
								aSaldo[xPOS_aLotes_QUANTIDADE],; //xPOS_aAddSD4_D4_QTDEORI
								(cAliasSD4)->D4_TRT           ,; //xPOS_aAddSD4_D4_TRT
								aSaldo[xPOS_aLotes_QTD_2UM]   ,; //xPOS_aAddSD4_D4_QTSEGUM
								(cAliasSD4)->D4_OPORIG        ,; //xPOS_aAddSD4_D4_OPORIG
								(cAliasSD4)->D4_PRODUTO       ,; //xPOS_aAddSD4_D4_PRODUTO
								(cAliasSD4)->D4_ROTEIRO       ,; //xPOS_aAddSD4_D4_ROTEIRO
								(cAliasSD4)->D4_OPERAC        ,; //xPOS_aAddSD4_D4_OPERAC
								(cAliasSD4)->D4_PRDORG        ,; //xPOS_aAddSD4_D4_PRDORG
								(cAliasSD4)->D4_QTNECES       ,; //xPOS_aAddSD4_D4_QTNECES
								aSaldo[xPOS_aLotes_LOTE   ]   ,; //xPOS_aAddSD4_D4_LOTECTL
								aSaldo[xPOS_aLotes_SUBLOTE]   ,; //xPOS_aAddSD4_D4_NUMLOTE
								(cAliasSD4)->C2_TPOP          ,; //xPOS_aAddSD4_C2_TPOP
								aSaldo[xPOS_aLotes_VALIDADE]  ,; //xPOS_aAddSD4_D4_DTVALID
								})

			Else
				aAddSD4[nIndScan][xPOS_aAddSD4_D4_QUANT]   += aSaldo[xPOS_aLotes_QUANTIDADE]
				aAddSD4[nIndScan][xPOS_aAddSD4_D4_QTDEORI] += aSaldo[xPOS_aLotes_QUANTIDADE]
				aAddSD4[nIndScan][xPOS_aAddSD4_D4_QTSEGUM] += aSaldo[xPOS_aLotes_QTD_2UM]

			EndIf
		EndIf

	EndIf

Return

/*/{Protheus.doc} preparaSDC
Prepara gravacoes da SDC
@type  Method
@author brunno.costa
@since 04/06/2020
@version P12.1.27
@param 01 - aSaldo, array, linha especifica do lote am analise conforme xPOS_aLotes
@param 02 - oJsData, objeto, instancia de objeto Json de controle:
	oJsData["aTravas"] - Array de controle de alias e Recnos Bloqueados pela Thread {{cAlias, nRecno},...}
	oJsData["aAddSD4"] - Array de controle conforme xPOS_aAddSD4
	oJsData["aAddSDC"] - Array de controle conforme xPOS_aAddSDC
	oJsData["aUpdSD4"] - Array de controle conforme xPOS_aUpdSD4
	oJsData["aUsados"] - Array de controle conforme xPOS_aUsados
	oJsData["nSldSB2"] - Saldo do produto na SB2
@param 03 - cAliasSD4, caracter, alias da SD4 criado em query para consulta dos registros relacionados
/*/
METHOD preparaSDC(aSaldo, oJsData, cAliasSD4) CLASS SugestaoLotesEnderecos

	Local aAddSDC      := oJsData["aAddSDC"]

	If (cAliasSD4)->B1_LOCALIZ == "S" .AND. !Empty(aSaldo[xPOS_aLotes_LOCALIZACAO] + aSaldo[xPOS_aLotes_NUM_SERIE]) .AND. aSaldo[xPOS_aLotes_QUANTIDADE] > 0
		aAdd(aAddSDC, {(cAliasSD4)->D4_FILIAL          ,; //xPOS_aAddSDC_DC_FILIAL
		               "SC2"                           ,; //xPOS_aAddSDC_DC_ORIGEM
					   (cAliasSD4)->D4_COD             ,; //xPOS_aAddSDC_DC_PRODUTO
					   (cAliasSD4)->D4_LOCAL           ,; //xPOS_aAddSDC_DC_LOCAL_
					   aSaldo[xPOS_aLotes_LOTE   ]     ,; //xPOS_aAddSDC_DC_LOTECTL
					   aSaldo[xPOS_aLotes_SUBLOTE]     ,; //xPOS_aAddSDC_DC_NUMLOTE
					   aSaldo[xPOS_aLotes_LOCALIZACAO] ,; //xPOS_aAddSDC_DC_LOCALIZ
					   aSaldo[xPOS_aLotes_NUM_SERIE]   ,; //xPOS_aAddSDC_DC_NUMSERI
					   aSaldo[xPOS_aLotes_QUANTIDADE]  ,; //xPOS_aAddSDC_DC_QTDORIG
					   aSaldo[xPOS_aLotes_QUANTIDADE]  ,; //xPOS_aAddSDC_DC_QUANT
					   aSaldo[xPOS_aLotes_QTD_2UM]     ,; //xPOS_aAddSDC_DC_QTSEGUM
					   (cAliasSD4)->D4_OP              ,; //xPOS_aAddSDC_DC_OP
					   (cAliasSD4)->D4_TRT             ,; //xPOS_aAddSDC_DC_TRT
					   (cAliasSD4)->C2_TPOP            ,; //xPOS_aAddSDC_C2_TPOP
				      })

	EndIf

Return

/*/{Protheus.doc} gravaAlteracoes
Grava alteracoes no banco de dados
@type  Method
@author brunno.costa
@since 04/06/2020
@version P12.1.27
@param 01 - oJsData, objeto, instancia de objeto Json de controle:
	oJsData["aTravas"] - Array de controle de alias e Recnos Bloqueados pela Thread {{cAlias, nRecno},...}
	oJsData["aAddSD4"] - Array de controle conforme xPOS_aAddSD4
	oJsData["aAddSDC"] - Array de controle conforme xPOS_aAddSDC
	oJsData["aUpdSD4"] - Array de controle conforme xPOS_aUpdSD4
	oJsData["aUsados"] - Array de controle conforme xPOS_aUsados
	oJsData["nSldSB2"] - Saldo do produto na SB2
/*/
METHOD gravaAlteracoes(oJsData) CLASS SugestaoLotesEnderecos
	BEGIN TRANSACTION
		Self:updSD4(oJsData["aUpdSD4"])
		Self:addSD4(oJsData["aAddSD4"])
		Self:addSDC(oJsData["aAddSDC"])
	END TRANSACTION
Return

/*/{Protheus.doc} addSD4
Grava alteracoes no banco de dados - Inclusao de Registros na SD4 - Empenhos
@type  Method
@author brunno.costa
@since 04/06/2020
@version P12.1.27
@param 01 - aAddSD4, array , Array de controle conforme xPOS_aAddSD4
@param 02 - lSeek  , logico, indica se confirma pre-existencia do registro na SD4 via DbSeek para evitar duplicidade - útil para execução complementar na mesma OP
/*/
METHOD addSD4(aAddSD4, lSeek) CLASS SugestaoLotesEnderecos

	Local cAliasSD4
	Local cQuery
	Local lFoundSD4 := .F.
	Local nIndSD4   := 0
	Local nTotal    := Len(aAddSD4)

	Default lSeek := .T.

	dbSelectArea("SD4")
	SD4->(DbSetOrder(1))
	For nIndSD4 := 1 to nTotal
		If lSeek
			//TODO: validar ganho de performance ao manter como MATA650, testes iniciais sem ganho
			/* .and. SD4->(DbSeek(aAddSD4[nIndSD4, xPOS_aAddSD4_D4_FILIAL ] + ;
		                            aAddSD4[nIndSD4, xPOS_aAddSD4_D4_COD    ] + ;
					                aAddSD4[nIndSD4, xPOS_aAddSD4_D4_OP_    ] + ;
					                aAddSD4[nIndSD4, xPOS_aAddSD4_D4_TRT    ] + ;
					                aAddSD4[nIndSD4, xPOS_aAddSD4_D4_LOTECTL] + ;
					                aAddSD4[nIndSD4, xPOS_aAddSD4_D4_NUMLOTE]))*/

			//Posiciona o empenho correto, considerando OP origem
			cAliasSD4 := GetNextAlias()

			cQuery := "SELECT SD4.R_E_C_N_O_ SD4RECNO "
			cQuery += "FROM " + RetSqlName("SD4") + " SD4 "
			cQuery += "WHERE SD4.D4_FILIAL='"+ aAddSD4[nIndSD4, xPOS_aAddSD4_D4_FILIAL  ] + "' AND "
			cQuery += "SD4.D4_COD = '"       + aAddSD4[nIndSD4, xPOS_aAddSD4_D4_COD     ] + "' AND "
			cQuery += "SD4.D4_OP = '"        + aAddSD4[nIndSD4, xPOS_aAddSD4_D4_OP_     ] + "' AND "
			cQuery += "SD4.D4_TRT = '"       + aAddSD4[nIndSD4, xPOS_aAddSD4_D4_TRT     ] + "' AND "
			cQuery += "SD4.D4_LOTECTL = '"   + aAddSD4[nIndSD4, xPOS_aAddSD4_D4_LOTECTL ] + "' AND "
			cQuery += "SD4.D4_NUMLOTE = '"   + aAddSD4[nIndSD4, xPOS_aAddSD4_D4_NUMLOTE ] + "' AND "
			cQuery += "SD4.D4_OPORIG = '"    + aAddSD4[nIndSD4, xPOS_aAddSD4_D4_OPORIG  ] + "' AND "
			cQuery += "SD4.D4_LOCAL = '"     + aAddSD4[nIndSD4, xPOS_aAddSD4_D4_LOCAL   ] + "' AND "
			cQuery += "SD4.D_E_L_E_T_=' ' "

			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD4,.T.,.T.)

			lFoundSD4 := !(cAliasSD4)->(Eof())

			dbSelectArea("SD4")
			If lFoundSD4
				MsGoTo((cAliasSD4)->SD4RECNO)

				RecLock("SD4", .F.)
				D4_QUANT   += aAddSD4[nIndSD4, xPOS_aAddSD4_D4_QUANT   ]
				D4_QTDEORI += aAddSD4[nIndSD4, xPOS_aAddSD4_D4_QTDEORI ]
				D4_QTSEGUM += aAddSD4[nIndSD4, xPOS_aAddSD4_D4_QTSEGUM ]
				D4_QTNECES += aAddSD4[nIndSD4, xPOS_aAddSD4_D4_QTNECES ]
				SD4->(MsUnlock())

			EndIf
			(cAliasSD4)->( dbCloseArea() )
		EndIf

		If !lFoundSD4
			//Proteção identificação do próximo RECNO da T4R em Trigger
			VarBeginT("LOCK_SD4", "RecLockT")
			RecLock("SD4",.T.)
			VarEndT("LOCK_SD4", "RecLockT")
			D4_FILIAL  := aAddSD4[nIndSD4, xPOS_aAddSD4_D4_FILIAL  ]
			D4_OP      := aAddSD4[nIndSD4, xPOS_aAddSD4_D4_OP_     ]
			D4_DATA    := StoD(aAddSD4[nIndSD4, xPOS_aAddSD4_D4_DATA])
			D4_COD     := aAddSD4[nIndSD4, xPOS_aAddSD4_D4_COD     ]
			D4_LOCAL   := aAddSD4[nIndSD4, xPOS_aAddSD4_D4_LOCAL   ]
			D4_QUANT   := aAddSD4[nIndSD4, xPOS_aAddSD4_D4_QUANT   ]
			D4_QTDEORI := aAddSD4[nIndSD4, xPOS_aAddSD4_D4_QTDEORI ]
			D4_TRT     := aAddSD4[nIndSD4, xPOS_aAddSD4_D4_TRT     ]
			D4_QTSEGUM := aAddSD4[nIndSD4, xPOS_aAddSD4_D4_QTSEGUM ]
			D4_OPORIG  := aAddSD4[nIndSD4, xPOS_aAddSD4_D4_OPORIG  ]
			D4_PRODUTO := aAddSD4[nIndSD4, xPOS_aAddSD4_D4_PRODUTO ]
			D4_ROTEIRO := aAddSD4[nIndSD4, xPOS_aAddSD4_D4_ROTEIRO ]
			D4_OPERAC  := aAddSD4[nIndSD4, xPOS_aAddSD4_D4_OPERAC  ]
			D4_PRDORG  := aAddSD4[nIndSD4, xPOS_aAddSD4_D4_PRDORG  ]
			D4_QTNECES := aAddSD4[nIndSD4, xPOS_aAddSD4_D4_QTNECES ]
			D4_LOTECTL := aAddSD4[nIndSD4, xPOS_aAddSD4_D4_LOTECTL ]
			D4_NUMLOTE := aAddSD4[nIndSD4, xPOS_aAddSD4_D4_NUMLOTE ]
			D4_DTVALID := aAddSD4[nIndSD4, xPOS_aAddSD4_D4_DTVALID ]
			SD4->(MsUnlock())
		EndIf

		Self:updSB8(aAddSD4[nIndSD4, xPOS_aAddSD4_D4_NUMLOTE ],;
		            aAddSD4[nIndSD4, xPOS_aAddSD4_D4_LOTECTL ],;
					aAddSD4[nIndSD4, xPOS_aAddSD4_D4_COD     ],;
					aAddSD4[nIndSD4, xPOS_aAddSD4_D4_LOCAL   ],;
					aAddSD4[nIndSD4, xPOS_aAddSD4_D4_QUANT   ],;
					aAddSD4[nIndSD4, xPOS_aAddSD4_C2_TPOP    ])
	Next

Return

/*/{Protheus.doc} updSD4
Grava alteracoes no banco de dados - Atualizacao de Registros na SD4 - Empenhos
@type  Method
@author brunno.costa
@since 04/06/2020
@version P12.1.27
@param 01 - aUpdSD4, array, Array de controle conforme xPOS_aUpdSD4
/*/
METHOD updSD4(aUpdSD4) CLASS SugestaoLotesEnderecos

	Local nIndSD4  := 0
	Local nTotal   := Len(aUpdSD4)
	Local nEmpOrig := 0

	dbSelectArea("SD4")
	For nIndSD4 := 1 to nTotal
		SD4->(DbGoTo(aUpdSD4[nIndSD4, xPOS_aUpdSD4_RECNO]))

		nEmpOrig := SD4->D4_QUANT

		RecLock("SD4", .F.)
		D4_QUANT   := aUpdSD4[nIndSD4, xPOS_aUpdSD4_D4_QUANT   ]
		D4_QTDEORI := aUpdSD4[nIndSD4, xPOS_aUpdSD4_D4_QTDEORI ]
		D4_QTSEGUM := aUpdSD4[nIndSD4, xPOS_aUpdSD4_D4_QTSEGUM ]
		D4_LOTECTL := aUpdSD4[nIndSD4, xPOS_aUpdSD4_D4_LOTECTL ]
		D4_NUMLOTE := aUpdSD4[nIndSD4, xPOS_aUpdSD4_D4_NUMLOTE ]
		D4_DTVALID := aUpdSD4[nIndSD4, xPOS_aUpdSD4_D4_DTVALID ]
		SD4->(MsUnlock())

		Self:updSB8(D4_NUMLOTE,;
		            D4_LOTECTL,;
					D4_COD    ,;
					D4_LOCAL  ,;
					D4_QUANT  ,;
					aUpdSD4[nIndSD4, xPOS_aUpdSD4_C2_TPOP] )
	Next
Return

/*/{Protheus.doc} addSDC
Grava alteracoes no banco de dados - Inclusao de Registros na SDC - Empenhos por Endereco
@type  Method
@author brunno.costa
@since 04/06/2020
@version P12.1.27
@param 01 - aAddSDC, array, Array de controle conforme xPOS_aAddSDC
/*/
METHOD addSDC(aAddSDC) CLASS SugestaoLotesEnderecos

	Local nIndSDC := 0
	Local nTotal  := Len(aAddSDC)

	dbSelectArea("SDC")
	For nIndSDC := 1 to nTotal
		RecLock("SDC", .T.)
		DC_FILIAL  := aAddSDC[nIndSDC, xPOS_aAddSDC_DC_FILIAL  ]
		DC_ORIGEM  := aAddSDC[nIndSDC, xPOS_aAddSDC_DC_ORIGEM  ]
		DC_PRODUTO := aAddSDC[nIndSDC, xPOS_aAddSDC_DC_PRODUTO ]
		DC_LOCAL   := aAddSDC[nIndSDC, xPOS_aAddSDC_DC_LOCAL_  ]
		DC_LOTECTL := aAddSDC[nIndSDC, xPOS_aAddSDC_DC_LOTECTL ]
		DC_NUMLOTE := aAddSDC[nIndSDC, xPOS_aAddSDC_DC_NUMLOTE ]
		DC_LOCALIZ := aAddSDC[nIndSDC, xPOS_aAddSDC_DC_LOCALIZ ]
		DC_NUMSERI := aAddSDC[nIndSDC, xPOS_aAddSDC_DC_NUMSERI ]
		DC_QTDORIG := aAddSDC[nIndSDC, xPOS_aAddSDC_DC_QTDORIG ]
		DC_QUANT   := aAddSDC[nIndSDC, xPOS_aAddSDC_DC_QUANT   ]
		DC_QTSEGUM := aAddSDC[nIndSDC, xPOS_aAddSDC_DC_QTSEGUM ]
		DC_OP      := aAddSDC[nIndSDC, xPOS_aAddSDC_DC_OP      ]
		DC_TRT     := aAddSDC[nIndSDC, xPOS_aAddSDC_DC_TRT     ]
		SDC->(MsUnlock())

		Self:updSBF(aAddSDC[nIndSDC, xPOS_aAddSDC_DC_NUMLOTE ],;
		            aAddSDC[nIndSDC, xPOS_aAddSDC_DC_LOTECTL ],;
					aAddSDC[nIndSDC, xPOS_aAddSDC_DC_PRODUTO ],;
					aAddSDC[nIndSDC, xPOS_aAddSDC_DC_LOCAL_  ],;
					aAddSDC[nIndSDC, xPOS_aAddSDC_DC_QUANT   ],;
					aAddSDC[nIndSDC, xPOS_aAddSDC_DC_LOCALIZ ],;
					aAddSDC[nIndSDC, xPOS_aAddSDC_DC_NUMSERI ],;
					aAddSDC[nIndSDC, xPOS_aAddSDC_C2_TPOP    ])
	Next

Return


/*/{Protheus.doc} updSB8
Atualiza Empenho na SB8 - Saldos por Lote
@type  Method
@author brunno.costa
@since 04/06/2020
@version P12.1.27
@param 01 - cNumLote, caracter, lote que sera atualizado
@param 02 - cLoteCtl, caracter, sublote que sera atualizado
@param 03 - cProduto, caracter, produto que sera atualizado
@param 04 - cLocal  , caracter, local que sera atualizado
@param 05 - nQtEmp  , numero  , quantidade para atualizacao
@param 06 - cTipo   , caracter, tipo do documento F-Firme ou P-Previsto
/*/
METHOD updSB8(cNumLote, cLoteCtl, cProduto, cLocal, nQtEmp, cTipo) CLASS SugestaoLotesEnderecos

	Local nQtdSegUM := 0

	Default cTipo := "P"

	dbSelectArea("SB8")
	dbSetOrder(2)
	If dbSeek(xFilial("SB8") + cNumLote + cLoteCtl + cProduto + cLocal)
		nQtdSegUM := Self:converte2UM(cProduto, nQtEmp)

		If nQtEmp > 0
			GravaB8Emp("+", nQtEmp, cTipo, .F., nQtdSegUM)

		Else
			GravaB8Emp("-", -nQtEmp, cTipo, .F., -nQtdSegUM)
		EndIf
	EndIf

Return

/*/{Protheus.doc} updSBF
Atualiza Empenho na SBF - Saldos por Endereco/Lote
@type  Method
@author brunno.costa
@since 04/06/2020
@version P12.1.27
@param 01 - cNumLote , caracter, lote que sera atualizado
@param 02 - cLoteCtl , caracter, sublote que sera atualizado
@param 03 - cProduto , caracter, produto que sera atualizado
@param 04 - cLocal   , caracter, local que sera atualizado
@param 05 - nQtEmp   , numero  , quantidade para atualizacao
@param 06 - cEndereco, caracter, endereco que sera atualizado
@param 07 - cNumSeri , caracter, numero de serie que sera atualizado
@param 08 - cTipo    , caracter, tipo do documento F-Firme ou P-Previsto
/*/
METHOD updSBF(cNumLote, cLoteCtl, cProduto, cLocal, nQtEmp, cEndereco, cNumSeri, cTipo) CLASS SugestaoLotesEnderecos

	Local nQtdSegUM := 0

	Default cTipo := "P"

	dbSelectArea("SBF")
	dbSetOrder(1)
	If dbSeek(xFilial("SBF") + cLocal + cEndereco + cProduto + cNumSeri + cLoteCtl + cNumLote)
		nQtdSegUM := Self:converte2UM(cProduto, nQtEmp)

		If nQtEmp > 0
			GravaBFEmp("+", nQtEmp, cTipo, .F., nQtdSegUM)

		Else
			GravaBFEmp("-", nQtEmp, cTipo, .F., nQtdSegUM)
		EndIf
	else
		CtESTE := ""
	EndIf

Return

/*/{Protheus.doc} getSB2Saldo
Retorna Saldo do Produto na SB2 - Saldos Fisicos e Financeiros
@type  Method
@author brunno.costa
@since 04/06/2020
@version P12.1.27
@param 01 - cProduto, caracter, codigo do produto
@param 02 - cLocal  , caracter, local do produto
@param 03 - oJsData, objeto, instancia de objeto Json de controle:
	oJsData["aTravas"] - Array de controle de alias e Recnos Bloqueados pela Thread {{cAlias, nRecno},...}
	oJsData["aAddSD4"] - Array de controle conforme xPOS_aAddSD4
	oJsData["aAddSDC"] - Array de controle conforme xPOS_aAddSDC
	oJsData["aUpdSD4"] - Array de controle conforme xPOS_aUpdSD4
	oJsData["aUsados"] - Array de controle conforme xPOS_aUsados
	oJsData["nSldSB2"] - Saldo do produto na SB2
@return nSldSB2, numero, saldo do produto na SB2
/*/
METHOD getSB2Saldo(cProduto, cLocal, oJsData) CLASS SugestaoLotesEnderecos

	Local nQtdPrj := 0
	Local nSldSB2 := 0
	Local aTravas := oJsData["aTravas"]
	Local nRecno  := 0

	If SB2->(MsSeek(Self:cFilSB2 + cProduto + cLocal))
		nRecno := SB2->(Recno())
		Self:travaRegistro("SB2", 1, Self:cFilSB2 + cProduto + cLocal, @aTravas, .T.)
		While    SB2->(!Eof());
		   .And. SB2->(B2_FILIAL+B2_COD) == Self:cFilSB2+cProduto;
		   .And. SB2->B2_LOCAL           == cLocal

			If !Self:lEmpenhaProjeto
				nQtdPrj := SB2->B2_QEMPPRJ
			EndIf

			nSldSB2 += SaldoSB2(.T. /*lNecessidade*/,;
			                    /*lEmpenho*/        ,;
								/*dDataFim*/        ,;
								Self:lDeTerceiros   ,;
								Self:lEmTerceiros   ,;
								/*cAliasSB2*/       ,;
								/*nQtdEmp*/         ,;
								nQtdPrj             ;
								/*,lSaldoSemR,dDtRefSld,*/)

			nSldSB2 += SB2->B2_SALPEDI
			nSldSB2 -= SB2->B2_QEMPN
			nSldSB2 += AvalQtdPre("SB2",2)

			SB2->(DbSkip())
		EndDo
	EndIf

	If nRecno > 0
		SB2->(DbGoTo(nRecno))
	EndIf

Return nSldSB2

/*/{Protheus.doc} getSBFSaldo
Retorna Saldo do Produto na SBF - Saldo por Endereco
@type  Method
@author brunno.costa
@since 04/06/2020
@version P12.1.27
@param 01 - cProduto , caracter, codigo do produto
@param 02 - cLocal   , caracter, codigo do local
@param 03 - cEndereco, caracter, codigo do endereco
@param 04 - cLote    , caracter, codigo do lote
@param 05 - cSubLote , caracter, codigo do sub-lote
@param 06 - cNumSeri , caracter, número de série
@return nSldSBF, numero, saldo do produto no endereco
/*/
METHOD getSBFSaldo(cProduto, cLocal, cEndereco, cLote, cSubLote, cNumSeri) CLASS SugestaoLotesEnderecos

	Local nSldSBF := 0

	//Verifica se o endereco possui quantidade suficiente para atender o empenho.
	If Self:lNovoWMS .And. IntWMS(cProduto)
		// Quando integrado ao WMS a funcao saldo por lote nao retorna o endereco - Deve validar apenas Lote/SubLote
		nSldSBF := WmsSldD14(cLocal, /*cEndereco*/, cProduto, /*cNumSerie*/, cLote, cSubLote)
	Else
		nSldSBF := SaldoSBF(cLocal, cEndereco, cProduto, cNumSeri, cLote, cSubLote)
		//SaldoSBF(cAlmox,cLocaliza,cCod,cNumSerie,cLoteCtl,cLote,lBaixaEmp,cEstFis,lPotMax,cOP)
	EndIf

Return nSldSBF

/*/{Protheus.doc} menorSaldo
Identifica o Menor Saldo Entre nSaldo (aSaldo), nSldSB2 e nSldSBF
@type  Method
@author brunno.costa
@since 04/06/2020
@version P12.1.27
@param 01 - cRastro , caracter, campo B1_RASTRO
@param 02 - cLocaliz, caracter, campo B1_LOCALIZ
@param 03 - nSldSB8 , numero  , saldo do produto no lote
@param 04 - nSldSB2 , numero  , saldo do produto na SB2 - Saldo Fisico ou Financeiro
@param 05 - nSldSBF , numero  , saldo do produto na SBF - Saldo por Endereco
@return nMenor, numero, menor saldo
/*/
METHOD menorSaldo(cRastro, cLocaliz, nSldSB8, nSldSB2, nSldSBF) CLASS SugestaoLotesEnderecos

	Local nMenor := nSldSB2

	If cRastro $ "LS"
		nMenor := Min(nSldSB8, nSldSB2)
	EndIf

	If cLocaliz $ "S"
		nMenor := Min(nSldSB8, nMenor)
		nMenor := Min(nSldSBF, nMenor)
	EndIf

Return nMenor

/*/{Protheus.doc} converte2UM
Identifica o Menor Saldo Entre nSaldo (aSaldo), nSldSB2 e nSldSBF
@type  Method
@author brunno.costa
@since 04/06/2020
@version P12.1.27
@param 01 - cProduto   , caracter, codigo do produto
@param 02 - nQUantidade, numero  , quantidade do produto na primeira unidade de medida
@return ConvUM(), numero, quantidade do produto na segunda unidade de medida
/*/
METHOD converte2UM(cProduto, nQuantidade) CLASS SugestaoLotesEnderecos
Return ConvUM(cProduto, nQuantidade, 0, 2)

/*/{Protheus.doc} getProdutos
Retorna a Relacao de Produtos para Processamento
@type  Method
@author brunno.costa
@since 04/06/2020
@version P12.1.27
@return aProdutos, array, array de produtos {{cProduto, cLocal},{cProduto, cLocal}}..}
/*/
METHOD getProdutos() CLASS SugestaoLotesEnderecos

	Local aProdutos := {}
	Local cAliasSD4 := GetNextAlias()
	Local cQuerySD4 := ""

	cQuerySD4 := "SELECT DISTINCT SD4.D4_COD, SD4.D4_LOCAL "
	cQuerySD4 += Self:scriptFromWhere()

	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuerySD4), cAliasSD4, .F., .F.)
	While !(cAliasSD4)->(Eof())
		aAdd(aProdutos, {(cAliasSD4)->D4_COD, (cAliasSD4)->D4_LOCAL})
		(cAliasSD4)->(dbSkip())
	EndDo
	(cAliasSD4)->(dbCloseArea())

Return aProdutos

/*/{Protheus.doc} scriptFromWhere
Retorna a Relacao de Produtos para Processamento
@type  Method
@author brunno.costa
@since 04/06/2020
@version P12.1.27
@param 01 - cProduto, caracter, codigo do produto
@param 02 - cLocal  , caracter, codigo do armazem
@return cQuery, caracter, script From + Where para consulta na SD4 dos registros pendentes
/*/
METHOD scriptFromWhere(cProduto, cLocal) CLASS SugestaoLotesEnderecos

	Local cBanco   := TCGetDB()
	Local cQuery   := ""
	Local cSqlC2OP := Self:scriptC2OP()

	Default cProduto := ""
	Default cLocal   := ""

	cQuery +=  " FROM " + RetSqlName("SD4") + " AS SD4 "
	cQuery +=    Self:scriptJoin("SD4.D4_OP")
	cQuery +=       " INNER JOIN "
	cQuery +=       " (  SELECT B1_COD, B1_RASTRO, B1_LOCALIZ "
	cQuery +=          " FROM " + RetSqlName("SB1") + " "
	cQuery +=          " WHERE (D_E_L_E_T_ = ' ') "
	cQuery +=                " AND ( (B1_RASTRO IN ('L', 'S')) OR (B1_LOCALIZ = 'S') ) "

	If !Empty(cProduto)
		cQuery += " AND (B1_COD = '" + cProduto + "') "
	EndIf

	cQuery +=       " ) AS SB1 "
	cQuery +=       " ON SD4.D4_COD = SB1.B1_COD "

	cQuery +=  	 " INNER JOIN "
	cQuery +=       " (  SELECT C2_PRODUTO, " + cSqlC2OP + " xC2_OP, C2_TPOP "
	cQuery +=          " FROM " + RetSqlName("SC2")
	cQuery +=            Self:scriptJoin(cSqlC2OP)
	cQuery +=          " WHERE (D_E_L_E_T_ = ' ') "
	cQuery +=            " AND (C2_QUJE  = 0  ) "
	cQuery +=            " AND (C2_PERDA = 0  ) "
	cQuery +=            " AND (C2_DATRF = ' ') "
	cQuery +=       " ) AS SC2 "
	cQuery +=       " ON    SD4.D4_OP  = SC2.xC2_OP "

	cQuery +=  	 " LEFT JOIN "
	cQuery +=       " (  SELECT DC_PRODUTO, DC_OP, DC_LOCALIZ, DC_NUMSERI "
	cQuery +=          " FROM " + RetSqlName("SDC") + " "
	cQuery +=            Self:scriptJoin("DC_OP")
	cQuery +=          " WHERE (D_E_L_E_T_ = ' ') "

	If !Empty(cProduto)
		cQuery += " AND (DC_PRODUTO = '" + cProduto + "') "
	EndIf

	cQuery +=       " ) AS SDC "
	cQuery +=       " ON    SD4.D4_COD = SDC.DC_PRODUTO "
	cQuery +=  	      " AND SD4.D4_OP  = SDC.DC_OP "

	cQuery +=  " WHERE (SD4.D_E_L_E_T_ = ' ') "
	cQuery +=    " AND ( "
	cQuery +=         " ( (SB1.B1_RASTRO IN ('L', 'S')) AND (SD4.D4_LOTECTL = ' ') ) "
	cQuery +=          " OR "
	cQuery +=         " ( (SB1.B1_LOCALIZ = 'S') AND (SDC.DC_PRODUTO IS NULL OR SDC.DC_LOCALIZ || SDC.DC_NUMSERI = ' ')  ) "
	cQuery +=        " ) "

	If !Empty(cProduto)
		cQuery += " AND (SD4.D4_COD = '" + cProduto + "') "
	EndIf

	If !Empty(cLocal)
		cQuery += " AND (SD4.D4_LOCAL = '" + cLocal + "') "
	EndIf

	//Realiza ajustes da Query para cada banco
	If cBanco == "POSTGRES"
		//Corrige Falhas internas de Binário - POSTGRES
		cQuery := StrTran(cQuery, CHR(13), " ")
		cQuery := StrTran(cQuery, CHR(10), " ")
		cQuery := StrTran(cQuery, CHR(09), " ")

	ElseIf cBanco == "ORACLE"
		cQuery := StrTran(cQuery, ' AS ', ' ')

	Else
		//Substitui concatenacao || por +
		cQuery := StrTran(cQuery, '||', '+')

	EndIf

Return cQuery

/*/{Protheus.doc} getOPsTicketMRP
Retorna OPs referente execucao cTicket do MRP
@type  Method
@author brunno.costa
@since 04/06/2020
@version P12.1.27
@param 01 - cTicket, caracter, codigo do ticket de execucao do MRP - PCPA712
@return oOps, JsonObject, Objeto JSON com as informações de OP por filial para processamento.
/*/
METHOD getOPsTicketMRP(cTicket) CLASS SugestaoLotesEnderecos

	Local cAliasHWC := GetNextAlias()
	Local cChaveSal := ""
	Local cQuery    := ""
	Local oOps      := JsonObject():New()

	cQuery := "SELECT DISTINCT HWC_FILIAL, HWC_DOCERP"
	cQuery +=  " FROM " + RetSqlName("HWC")
	cQuery += " WHERE D_E_L_E_T_ = ' '"
	cQuery +=   " AND HWC_TICKET = '" + cTicket + "'"
	cQuery +=   " AND HWC_DOCERP <> ' '"
	cQuery +=   " AND HWC_TDCERP = '1'"
	cQuery += " ORDER BY HWC_FILIAL"

	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasHWC, .F., .F.)
	While !(cAliasHWC)->(Eof())
		If oOps[(cAliasHWC)->HWC_FILIAL] == Nil
			oOps[(cAliasHWC)->HWC_FILIAL] := {}
		EndIf

		aAdd(oOps[(cAliasHWC)->HWC_FILIAL], (cAliasHWC)->HWC_DOCERP)
		(cAliasHWC)->(dbSkip())
	EndDo
	(cAliasHWC)->(dbCloseArea())

	//Carrega o objeto Self:oSaldos com os saldos iniciais (na execução do MRP) de cada Filial + Produto + Local
	If Self:lGeraFirme
		cQuery := "SELECT HWC_A.HWC_FILIAL, HWC_A.HWC_PRODUT, HWC_A.HWC_LOCAL, HWC_A.HWC_QTSLES"
		cQuery +=  " FROM " + RetSqlName("HWC") + " HWC_A"
		cQuery += " WHERE HWC_A.HWC_TICKET = '" + cTicket + "'"
		cQuery +=   " AND HWC_A.D_E_L_E_T_ = ' '"
		cQuery +=   " AND HWC_A.HWC_DATA IN (SELECT DISTINCT min(HWC_B.HWC_DATA)"
		cQuery +=                            " FROM " + RetSqlName("HWC") + " HWC_B"
		cQuery +=                           " WHERE HWC_B.HWC_TICKET = '" + cTicket + "'"
		cQuery +=                             " AND HWC_B.HWC_FILIAL = HWC_A.HWC_FILIAL"
		cQuery +=                             " AND HWC_B.HWC_PRODUT = HWC_A.HWC_PRODUT"
		cQuery +=                             " AND HWC_B.HWC_LOCAL  = HWC_A.HWC_LOCAL"
		cQuery +=                             " AND HWC_B.D_E_L_E_T_ = ' '"
		cQuery +=                           " GROUP BY HWC_FILIAL, HWC_B.HWC_PRODUT, HWC_B.HWC_LOCAL)"

		dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAliasHWC, .F., .F.)
		While !(cAliasHWC)->(Eof())
			cChaveSal := Trim((cAliasHWC)->HWC_FILIAL) + "|" + Trim((cAliasHWC)->HWC_PRODUT) + "|" + Trim((cAliasHWC)->HWC_LOCAL)
			If Self:oSaldos[cChaveSal] == Nil
				Self:oSaldos[cChaveSal] := (cAliasHWC)->HWC_QTSLES
			EndIf

			(cAliasHWC)->(dbSkip())
		EndDo
		(cAliasHWC)->(dbCloseArea())
	EndIf

Return oOps

/*/{Protheus.doc} scriptJoin
Retorna Script JOIN com as OPs
@type  Method
@author brunno.costa
@since 04/06/2020
@version P12.1.27
@param 01 - cColuna, caracter, coluna referencia para comparacao no script IN
@return cQuery, caracter, script IN referente OPs para consulta na SD4 dos registros pendentes
/*/
METHOD scriptJoin(cColuna) CLASS SugestaoLotesEnderecos

	Local cArqTrab   := ""
	Local cColOrig   := cColuna
	Local cParametro := "RelationOPs" + cFilAnt
	Local cQuery     := ""
	Local nIndexIN   := 0
	Local nLenLista  := 0

	cColuna := "COLUNA_DEFAULT"

	cQuery := Self:getFlagGlobal(cParametro, , .F.)
	If Empty(cQuery)
		Self:travaGlobal(cParametro)
		cQuery := Self:getFlagGlobal(cParametro, , .F.)
		If !Empty(cQuery)
			Self:destravaGlobal(cParametro)
		EndIf
	EndIf
	If Empty(cQuery)
		cQuery  := ""
		nLenLista := Len(Self:aOPs)

		cArqTrab  := Self:criaTabelaTemporariaOPs()
		For nIndexIN := 1 To nLenLista
			RecLock(cArqTrab, .T.)
				(cArqTrab)->(C2_FIL) := cFilAnt
				(cArqTrab)->(C2_OP)  := Self:aOPs[nIndexIN]
			(cArqTrab)->(MsUnLock())
		Next nIndexIN

		cQuery += " INNER JOIN (SELECT C2_OP OP FROM " + cArqTrab + " WHERE C2_FIL = '" + cFilAnt + "' ) TRB ON TRB.OP = " + cColuna
		Self:setFlagGlobal(cParametro, cQuery)

		Self:destravaGlobal(cParametro)

	EndIf

	cQuery := StrTran(cQuery, cColuna, cColOrig)

Return cQuery

/*/{Protheus.doc} criaTabelaTemporariaOPs
Cria a tabela temporária para armazenar os possíveis códigos de OPs
@author brunno.costa
@since 02/07/2020
@version P12.1.30
@return cArqTrab, caracter, nome do arquivo de trabalho criado
/*/
METHOD criaTabelaTemporariaOPs() CLASS SugestaoLotesEnderecos

	Local aFields    := {}
	Local cArqTrab   := ""
	Local lOk        := .T.

	Self:travaGlobal("PCPA151_OPS")

	cArqTrab := Self:getFlagGlobal("PCPA151_OPS",,.F.)
	If Empty(cArqTrab)
		cArqTrab   := "PCPA151_OPS" + Self:cTicket

		//Adiciona Campos
		aAdd(aFields, {"C2_FIL", "C", FwSizeFilial()                    , 0})
		aAdd(aFields, {"C2_OP" , "C", GetSX3Cache("C2_OP", "X3_TAMANHO"), 0})

		//Deleta Tabela no Banco, caso exista
		lOk := TCDelFile(cArqTrab)

		//Cria Tabela no Banco
		dbCreate(cArqTrab, aFields, "TOPCONN")

		DBUseArea(.F., 'TOPCONN', cArqTrab, (cArqTrab), .F., .F.)

		(cArqTrab)->(DBCreateIndex(cArqTrab+"1","C2_FIL+C2_OP",{|| "C2_FIL+C2_OP"}))

		Self:setFlagGlobal("PCPA151_OPS", cArqTrab)
	EndIf

	Self:destravaGlobal("PCPA151_OPS")

Return cArqTrab

/*/{Protheus.doc} scriptC2OP
Monta o SQL retornando o código da OP, podendo ser
C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD ou o C2_OP.
@type  Method
@author brunno.costa
@since 04/06/2020
@version P12.1.27
@param 01 - lNoAlias, logico, indica necessidade de remover o alias do script
@return cQryC2OP, Character, Query montando o retorno do campo C2_OP
/*/
METHOD scriptC2OP(lNoAlias) CLASS SugestaoLotesEnderecos

	Local cQryC2OP := ""

	Default lNoAlias := .T.

	cQryC2OP := "("
	cQryC2OP += " CASE SC2.C2_OP "
	cQryC2OP +=      " WHEN ' ' THEN "
	If "MSSQL" $ TCGetDB()
		cQryC2OP +=       " SC2.C2_NUM+SC2.C2_ITEM+SC2.C2_SEQUEN+SC2.C2_ITEMGRD "
	Else
		cQryC2OP +=       " SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQUEN||SC2.C2_ITEMGRD "
	EndIf
	cQryC2OP +=      " ELSE "
	cQryC2OP +=           " SC2.C2_OP "
	cQryC2OP +=      " END "
	cQryC2OP += ")"

	If lNoAlias
		cQryC2OP := StrTran(cQryC2OP, "SC2.", "")
	EndIf

Return cQryC2OP

/*/{Protheus.doc} abreThreads
Abre as Threads de Processamento
@type  Method
@author brunno.costa
@since 04/06/2020
@version P12.1.27
/*/
METHOD abreThreads() CLASS SugestaoLotesEnderecos
	PCPIPCStart(Self:cUIDExecucao, Self:nThreads, 0, cEmpAnt, cFilAnt, Self:cErrorUID)
Return

/*/{Protheus.doc} fechaThreads
Fecha as Threads de Processamento
@type  Method
@author brunno.costa
@since 04/06/2020
@version P12.1.27
/*/
METHOD fechaThreads() CLASS SugestaoLotesEnderecos
	PCPIPCFinish(Self:cUIDExecucao, Self:nThreads, Self:nThreads)
Return

/*/{Protheus.doc} delegaProduto
Delega Processamento Multi-Thread para o Produto
@type  Method
@author brunno.costa
@since 04/06/2020
@version P12.1.27
@param 01 - cFilProc, caracter, código da filial de processamento
@param 02 - cProduto, caracter, codigo do produto
@param 03 - cLocal  , caracter, codigo do armazem
@return lRet, logico, Retorna .T. caso a requisição foi enviada a um IpcWaitEx() em espera.
/*/
METHOD delegaProduto(cFilProc, cProduto, cLocal) CLASS SugestaoLotesEnderecos
Return PCPIPCGO(Self:cUIDExecucao, .F. /*lClose*/, "PCPA151THR", cFilProc, Self:cUIDExecucao, cProduto, cLocal, Self:cTicket, Self:oSaldos[Trim(cFilProc) + "|" + Trim(cProduto) + "|" + Trim(cLocal)])

/*/{Protheus.doc} aguardaTermino
Aguarda Termino do Processamento
@type  Method
@author brunno.costa
@since 04/06/2020
@version P12.1.27
/*/
METHOD aguardaTermino() CLASS SugestaoLotesEnderecos
	While IPCCount(Self:cUIDExecucao) < Self:nThreads
		Sleep(250)
	EndDo
Return

/*/{Protheus.doc} criarSessaoGlobal
Cria sessao de variaveis globais
@type  Method
@author brunno.costa
@since 04/06/2020
@version P12.1.27
/*/
METHOD criarSessaoGlobal() CLASS SugestaoLotesEnderecos
	If !VarSetUID(Self:cUIDExecucao)
		LogMsg("PCPA151", 0, 0, 1, "", "", STR0005) //"Erro na criacao da secao de variáveis globais de saldo."
	EndIf
	VarSetUID("LOCK_SD4")
Return

/*/{Protheus.doc} travaGlobal
Trava chave de registro global
@type  Method
@author brunno.costa
@since 04/06/2020
@version P12.1.27
@param 01 - cChave, caracter, string para travar em sessao global
@return lRet, logico, Indica se conseguiu iniciar a transação na chave <cChave> da sessão <cUID>
/*/
METHOD travaGlobal(cChave) CLASS SugestaoLotesEnderecos
Return VarBeginT( Self:cUIDExecucao, cChave )

/*/{Protheus.doc} destravaGlobal
Destrava chave de registro global
@type  Method
@author brunno.costa
@since 04/06/2020
@version P12.1.27
@param 01 - cChave, caracter, string para destravar em sessao global
@return lRet, logico, Indica se conseguiu finalizar a transação na chave <cChave> da sessão <cUID>
/*/
METHOD destravaGlobal(cChave) CLASS SugestaoLotesEnderecos
Return VarEndT( Self:cUIDExecucao, cChave )

/*/{Protheus.doc} getFlagGlobal
Retorna conteudo de chave global
@type  Method
@author brunno.costa
@since 04/06/2020
@version P12.1.27
@param 01 - cChave, caracter, chave do registro global
@param 02 - lError, logico  , retorna por referencia ocorrencia de erro
@param 03 - lLog  , logico  , indica se deve gerar log
@return oFlag, *, conteudo armazenado na variavel global
/*/
METHOD getFlagGlobal(cChave, lError, lLog) CLASS SugestaoLotesEnderecos
	Local oFlag
	Local cGlobalKey := Self:cUIDExecucao
	Default cChave := "flag"
	Default lError := .F.
	Default lLog   := .T.
	lError := !VarGetXD( cGlobalKey, cChave, @oFlag )
	If lError .and. lLog
		LogMsg("PCPA151", 0, 0, 1, "", "", "PCPA151 - Error getFlagGlobal cChave '" + cChave + "'")
	EndIf
	If lError
		oFlag := NIL
	EndIf
Return oFlag

/*/{Protheus.doc} setFlagGlobal
Seta conteudo de chave global
@type  Method
@author brunno.costa
@since 04/06/2020
@version P12.1.27
@param 01 - cChave, caracter, chave do registro global
@param 02 - oFlag , *       , conteudo para gravacao na variavel global
@param 03 - lError, logico  , retorna por referencia ocorrencia de erro
@param 04 - lInc  , lógico  , indica se deve realizar incremento atomico global
@return lRet, logico, indica sucesso na operacao
/*/
METHOD setFlagGlobal(cChave, oFlag, lError, lInc) CLASS SugestaoLotesEnderecos
	Local cGlobalKey := Self:cUIDExecucao
	Default lError := .F.
	Default cChave := "flag"
	Default lInc   := .F.
	If lInc
		lError := !VarSetX( cGlobalKey, cChave, @oFlag, 1, 1)
	Else
		lError := !VarSetXD( cGlobalKey, cChave , oFlag )
	EndIf
	If lError
		LogMsg("PCPA151", 0, 0, 1, "", "", "PCPA151 - Error setFlagGlobal cChave '" + cChave + "'")
	EndIf
Return (!lError)

/*/{Protheus.doc} travaRegistro
Trava Registro no Banco
@type  Method
@author brunno.costa
@since 04/06/2020
@version P12.1.27
@param 01 - cAlias      , caracter, alias do registro no banco
@param 02 - nIndice     , numero  , indice do registro para posicionamento no banco
@param 03 - cChave      , caracter, chave de posicionamento do registro no nIndice e cAlias
@param 04 - aTravas     , array   , array de controle das travas retornados por referencia {{cAlias, nRecno},{cAlias, nRecno},...}
@param 05 - lPosicionado, logico  , indica se o registro esta posicionado
/*/
METHOD travaRegistro(cAlias, nIndice, cChave, aTravas, lPosicionado) CLASS SugestaoLotesEnderecos
	Default lPosicionado := .F.
	If lPosicionado
		SoftLock(cAlias)
		aAdd(aTravas,{ cAlias , (cAlias)->(Recno()) })
	Else
		(cAlias)->(DbSetOrder(nIndice))
		IF (cAlias)->(MsSeek(cChave))
			SoftLock(cAlias)
			aAdd(aTravas,{ cAlias , (cAlias)->(Recno()) })
		EndIf
	EndIf
Return

/*/{Protheus.doc} destravaRegistros
Destrava Registros no Banco
@type  Method
@author brunno.costa
@since 04/06/2020
@version P12.1.27
@param 01 - aTravas, array, array de controle das travas {{cAlias, nRecno},{cAlias, nRecno},...}
/*/
METHOD destravaRegistros(aTravas) CLASS SugestaoLotesEnderecos
	Local aArea     := GetArea()
	Local nCntFor   := 0
	If ( aTravas != Nil )
		For nCntFor := 1 To Len(aTravas)
			dbSelectArea(aTravas[nCntFor,1])
			dbGoto(aTravas[nCntFor,2])
			MsUnLock()
		Next nCntFor
	EndIf
	RestArea(aArea)
Return

/*/{Protheus.doc} destroy
Destroy a classe
@type  Method
@author brunno.costa
@since 04/06/2020
@version P12.1.27
/*/
METHOD destroy() CLASS SugestaoLotesEnderecos
	Local cArqTrab := Self:getFlagGlobal("PCPA151_OPS",,.F.)

	VarClean(Self:cUIDExecucao)
	VarClean("LOCK_SD4")

	//Exclui tabela de produtos do banco
	If !Empty(cArqTrab)
		(cArqTrab)->(dbCloseArea())
		TCDelFile(cArqTrab)
	EndIf

	FreeObj(Self:oSaldos)
	Self:oSaldos := Nil
Return

/*/{Protheus.doc} getProgress
Retorna a porcentagem de execucao da sugestao de enderecos

@type  Method
@author brunno.costa
@since 11/08/2020
@version P12.1.27
@param cTicket, caracter, Número do ticket de processamento do MRP
@return nProgress, Numeric, Número relacionado a porcentagem da execução.
/*/
METHOD getProgress(cTicket) CLASS SugestaoLotesEnderecos
	Local nCount    := 0
	Local nTotal    := 0
	Local nProgress := 0
	Local lError    := .F.

	nTotal := Self:getFlagGlobal("PERCENTUAL_TOTAL", @lError, .F. /*lLog*/)
	If lError
		If GetGlbValue(cTicket+"PCPA151_STATUS") != "INI"
			nProgress := 100
		EndIf
	Else
		If GetGlbValue(cTicket+"PCPA151_STATUS") != "INI"
			nProgress := 100
		Else
			nCount := Self:getFlagGlobal("PERCENTUAL_PARCIAL", @lError, .F. /*lLog*/)
			If !lError
				nProgress := Round( (nCount/nTotal) * 100, 2)
			EndIf
		EndIf
	EndIF
Return nProgress

/*/{Protheus.doc} carregaParametros
Faz a carga das propriedades com os parâmetros necessários.

@type  Method
@author lucas.franca
@since 18/11/2020
@version P12
@return Nil
/*/
METHOD carregaParametros() CLASS SugestaoLotesEnderecos
	Self:lNovoWMS        := SuperGetMV("MV_WMSNEW" , .F. ,.F.)
	Self:lSomaPrevistas  := SuperGetMV("MV_QTDPREV", .F. ,"N") == "S"
	Self:cFilSB2         := xFilial("SB2")
	Self:lEmpenhaProjeto := SuperGetMV("MV_EMPPRJ",.F.,.T.)
Return Nil

/*/{Protheus.doc} PCPA151Cnt
Recupera o valor das constantes utilizadas para auxiliar na montagem do array

@type Function
@author marcelo.neumann
@since 11/02/2022
@version P12.1.33
@param cInfo, Caracter, Define qual constante se deseja recuperar o valor.
@return nValue, Numeric, Valor da constante
/*/
Function PCPA151Cnt(cInfo)
	Local nValue := xPOS_aUsados_LOTE
	Do Case
		Case cInfo == "xPOS_aUsados_LOTE"
			nValue := xPOS_aUsados_LOTE
		Case cInfo == "xPOS_aUsados_SUBLOTE"
			nValue := xPOS_aUsados_SUBLOTE
		Case cInfo == "xPOS_aUsados_LOCALIZACAO"
			nValue := xPOS_aUsados_LOCALIZACAO
		Case cInfo == "xPOS_aUsados_NUM_SERIE"
			nValue := xPOS_aUsados_NUM_SERIE
		Case cInfo == "xPOS_aUsados_QUANTIDADE"
			nValue := xPOS_aUsados_QUANTIDADE
		Case cInfo == "xPOS_aUsados_QTD_2UM"
			nValue := xPOS_aUsados_QTD_2UM
		Case cInfo == "xPOS_aUsados_LOCAL_"
			nValue := xPOS_aUsados_LOCAL_
		Case cInfo == "xPOS_aUsados_VALIDADE"
			nValue := xPOS_aUsados_VALIDADE
		Otherwise
			nValue := xPOS_aUsados_LOTE
	EndCase
Return nValue
