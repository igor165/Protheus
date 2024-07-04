#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "ESGINVOICE.CH"

#DEFINE PERCENTUAL_DE_COMPENSACAO 0.22

#DEFINE STATUS_HZ3_PENDENTE   "1"
#DEFINE STATUS_HZ3_EM_CALCULO "2"
#DEFINE STATUS_HZ3_CALCULADO  "3"
#DEFINE STATUS_HZ3_ERRO       "4"

/*/{Protheus.doc} esginvoice
API para o módulo ESG TOTVS - cálculo das notas fiscais

@type API
@author lucas.franca
@since 11/04/2022
@version P12
/*/
WSRESTFUL esginvoice DESCRIPTION STR0001 FORMAT APPLICATION_JSON //"API para o módulo ESG TOTVS - cálculo das notas fiscais"

	WSMETHOD POST calculate;
		DESCRIPTION STR0002 ; //"Busca as notas da filial/período e faz o cálculo."
		WSSYNTAX "api/pcp/v1/esginvoice/calculate" ;
		PATH "api/pcp/v1/esginvoice/calculate" ;
		TTALK "v1"

ENDWSRESTFUL

/*/{Protheus.doc} POST calculate api/pcp/v1/esginvoice/calculate
Busca as notas fiscais do período/filial e faz o cálculo.

@type WSMETHOD
@author lucas.franca
@since 11/04/2022
@version P12
@return lRet, Logico, Informa se o processo foi executado com sucesso.
/*/
WSMETHOD POST calculate WSSERVICE esginvoice
	Local cChave     := ""
	Local cValor     := ""
	Local cMsg       := ""
	Local cFil       := ""
	Local cPeriodId  := ""
	Local lRet       := .T.
	Local nTentativa := 0
	Local oBody      := JsonObject():New()

	Self:SetContentType("application/json")
	lRet := validaDic() .And. validaBody(Self, oBody)

	If lRet 
		cFil      := PadR(oBody["branchId"], FwSizeFilial())
		cPeriodId := PadR(oBody["periodId"], GetSX3Cache("HZ3_CODIGO", "X3_TAMANHO"))
	EndIf 

	lRet := lRet .And. validaFil(cFil)
	lRet := lRet .And. iniciaPeri(cFil, cPeriodId)
	If lRet
		//Variável de controle para indicar o início do processo.
		cChave := cFil + cPeriodId
		PutGlbValue(cChave, "INICIAR")

		//Abre outra thread para início do processamento.
		StartJob("ESGINVOICE", GetEnvServer(), .F., cEmpAnt, cFil, cPeriodId, cChave)
		
		//Verifica se a thread iniciou o processamento antes de retornar na API.
		lRet := .F.
		While nTentativa <= 60
			//Enquanto a global tiver o valor "INICIAR", indica que a thread não iniciou o processamento.
			cValor := GetGlbValue(cChave)
			nTentativa++
			If cValor == "INICIAR"
				Sleep(500)
				If nTentativa > 60
					cMsg := STR0013 //"Falha ao iniciar o JOB de processamento. Tempo limite atingido."
				EndIf
			ElseIf cValor == "ERRO"
				cMsg := GetGlbValue(cChave + "ERRO")
				ClearGlbValue(cChave + "ERRO")
				Exit
			Else
				lRet := .T.
				Exit
			EndIf
		End

		//Limpa a variável global da memória
		ClearGlbValue(cChave)

		//Monta o retorno da API
		If lRet
			Self:SetResponse('{"code":"200", "status":"ok"}')
		Else 
			atuPeriodo(cFil, cPeriodId, STATUS_HZ3_ERRO, cMsg)
			criaMsgErr(STR0014, cMsg) //"Processamento não realizado"
		EndIf
	EndIf
	
Return lRet

/*/{Protheus.doc} validaBody
Faz a validação do Accept recebido na requisição

@type Static Function
@author lucas.franca
@since 21/04/2022
@version P12
@param 01 oRest, Objeto, Instância da chamada REST
@param 02 oBody, Objeto, Objeto JSON com o conteúdo do Body (retorna por referência)
@return   lRet , Lógico, Identifica se o Accept está correto
/*/
Static Function validaBody(oRest, oBody)
	Local cAccept := oRest:GetAccept()
	Local cBody   := ""
	Local cError  := ""
	Local cTpBody := ""
	Local lRet    := .T.

	// Identificando o tipo do Body
	If !Empty(cAccept) .And. ValType(cAccept) == "C"
		cTpBody := Upper(Substr(cAccept, At("/",cAccept)+1))
	EndIf

	If Empty(cTpBody) .Or. (cTpBody != "JSON")
		criaMsgErr(STR0018, STR0019) //"Erro ao interpretar os dados recebidos.", "Não foi possível ler o Body, é apenas aceito JsonObject."
		lRet := .F.
	EndIf

	If lRet
		cBody  := oRest:GetContent()
		cError := oBody:FromJson(cBody)
		If !Empty(cError)
			criaMsgErr(STR0018, cError) //"Erro ao interpretar os dados recebidos."
			lRet := .F.
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} ESGINVOICE
JOB para processamento das notas fiscais
Busca e calcula as notas fiscais que devem ser processadas no período.

@type  Function
@author lucas.franca
@since 20/04/2022
@version P12
@param cEmp   , Character, Código do grupo de empresas
@param cFil   , Character, Código da filial para processamento
@param cPeriod, Character, Código do período para processamento
@param cChave , Character, Chave da variável global de controle do processo.
@return Nil
/*/
Function ESGINVOICE(cEmp, cFil, cPeriod, cChave)
	Local cAlias     := ""
	Local cFilHZ4    := ""
	Local cQuery     := ""
	Local cMsg       := ""
	Local cDtIni     := ""
	Local cDtFim     := ""
	Local lRet       := .T.
	Local lEntrou    := .F.
	Local nPesoGrama := 0
	Local nDecGrama  := 0
	Local oDadosHZ5  := JsonObject():New()
	Local oDadosHZ6  := JsonObject():New()
	Local oBulk      := Nil
	Local oBlkErr    := ErrorBlock({|oErro| ESGINVCERR(oErro, cFil, cPeriod, cChave) })

	BEGIN SEQUENCE

		//Prepara o ambiente
		RpcSetType(3)
		RpcSetEnv(cEmp, cFil)
		
		//Grava global de controle para indicar que o processo foi iniciado e liberar o retorno da API.
		PutGlbValue(cChave, "INICIADO")

		//Busca as informações do período
		HZ3->(dbSeek(xFilial("HZ3") + cPeriod))
		cDtIni := HZ3->HZ3_PERINI
		cDtFim := HZ3->HZ3_PERFIM

		cAlias    := GetNextAlias()
		cFilHZ4   := xFilial("HZ4")
		nDecGrama := GetSX3Cache("HZ4_PESOGR", "X3_DECIMAL")
		oBulk     := FwBulk():New(RetSqlName("HZ4"))

		oBulk:setFields({{"HZ4_FILIAL"},;
						{"HZ4_PERIOD"},;
						{"HZ4_UFDEST"},;
						{"HZ4_PRODUT"},;
						{"HZ4_QTDNOT"},;
						{"HZ4_TIPMAT"},;
						{"HZ4_SEQMAT"},;
						{"HZ4_PEUNGR"},;
						{"HZ4_PRTPRO"},;
						{"HZ4_PESOGR"},;
						{"HZ4_NDOC"  },;
						{"HZ4_NSERIE"},;
						{"HZ4_NCLIEN"},;
						{"HZ4_NLOJA" },;
						{"HZ4_NITEM" },;
						{"HZ4_NEMISS"}})

		//Processamento das informações.
		//Monta a query para buscar os dados das notas fiscais
		cQuery := " SELECT SF2.F2_DOC, SF2.F2_SERIE, SF2.F2_EMISSAO,"
		cQuery +=        " SF2.F2_EST,"
		cQuery +=        " CASE WHEN SF2.F2_CLIENT = ' '"
		cQuery +=             " THEN SF2.F2_CLIENTE"
		cQuery +=             " ELSE SF2.F2_CLIENT"
		cQuery +=        " END AS CLIENTE,"
		cQuery +=        " CASE WHEN SF2.F2_CLIENT = ' '"
		cQuery +=             " THEN SF2.F2_LOJA"
		cQuery +=             " ELSE SF2.F2_LOJENT"
		cQuery +=        " END AS LOJA,"
		cQuery +=        " SD2.D2_COD,"
		cQuery +=        " SD2.D2_QUANT,"
		cQuery +=        " SD2.D2_ITEM,"
		cQuery +=        " HZ2.HZ2_PRTPRO,"
		cQuery +=        " HZ2.HZ2_TIPMAT,"
		cQuery +=        " HZ2.HZ2_PESOGR,"
		cQuery +=        " HZ2.HZ2_SEQMAT"
		cQuery +=   " FROM " + RetSqlName("SF2") + " SF2"
		cQuery +=  " INNER JOIN " + RetSqlName("SD2") + " SD2"
		cQuery +=     " ON SD2.D2_FILIAL = '" + xFilial("SD2") + "'"
		cQuery +=    " AND SD2.D_E_L_E_T_ = ' '"
		cQuery +=    " AND SD2.D2_DOC     = SF2.F2_DOC"
		cQuery +=    " AND SD2.D2_SERIE   = SF2.F2_SERIE"
		cQuery +=    " AND SD2.D2_CLIENTE = SF2.F2_CLIENTE"
		cQuery +=    " AND SD2.D2_LOJA    = SF2.F2_LOJA"
		cQuery +=    " AND (SD2.D2_CF LIKE '5%' OR SD2.D2_CF LIKE '6%')"
		cQuery +=  " INNER JOIN " + RetSqlName("HZ1") + " HZ1"
		cQuery +=     " ON HZ1.HZ1_FILIAL = '" + xFilial("HZ1") + "'"
		cQuery +=    " AND HZ1.D_E_L_E_T_ = ' '"
		cQuery +=    " AND HZ1.HZ1_STATUS = 'A'"
		cQuery +=    " AND HZ1.HZ1_PRODUT = SD2.D2_COD"
		//Pega a composição da filial corrente, e caso não encontre busca pela composição com filial em branco (todas as filiais)
		cQuery +=    " AND (HZ1.HZ1_FILCOM = '" + cFil + "' "
		cQuery +=         " OR (HZ1.HZ1_FILCOM = ' ' "
		cQuery +=        " AND NOT EXISTS(SELECT 1 FROM " + RetSqlName("HZ1") + " HZ1AUX "
		cQuery +=                        " WHERE HZ1AUX.HZ1_FILIAL = '" + xFilial("HZ1") + "'"
		cQuery +=                          " AND HZ1AUX.D_E_L_E_T_ = ' '"
		cQuery +=                          " AND HZ1AUX.HZ1_STATUS = 'A'"
		cQuery +=                          " AND HZ1AUX.HZ1_PRODUT = HZ1.HZ1_PRODUT"
		cQuery +=                          " AND HZ1AUX.HZ1_FILCOM = '" + cFil + "')  ))"
		cQuery +=  " INNER JOIN " + RetSqlName("HZ2") + " HZ2 "
		cQuery +=     " ON HZ2.HZ2_FILIAL = '" + xFilial("HZ2") + "'"
		cQuery +=    " AND HZ2.D_E_L_E_T_ = ' '"
		cQuery +=    " AND HZ2.HZ2_PRODUT = HZ1.HZ1_PRODUT"
		//Pega a composição da filial corrente, e caso não encontre busca pela composição com filial em branco (todas as filiais)
		cQuery +=    " AND (HZ2.HZ2_FILCOM = '" + cFil + "'" 
		cQuery +=         " OR (HZ2.HZ2_FILCOM = ' ' "
		cQuery +=        " AND NOT EXISTS(SELECT 1 FROM " + RetSqlName("HZ2") + " HZ2AUX "
		cQuery +=                        " WHERE HZ2AUX.HZ2_FILIAL = '" + xFilial("HZ2") + "'"
		cQuery +=                          " AND HZ2AUX.D_E_L_E_T_ = ' '"
		cQuery +=                          " AND HZ2AUX.HZ2_PRODUT = HZ2.HZ2_PRODUT"
		cQuery +=                          " AND HZ2AUX.HZ2_FILCOM = '" + cFil + "')  ))"
		cQuery +=  " WHERE SF2.F2_FILIAL  = '" + xFilial("SF2") + "'"
		cQuery +=    " AND SF2.D_E_L_E_T_ = ' '"
		cQuery +=    " AND SF2.F2_EMISSAO BETWEEN '" + cDtIni + "' AND '" + cDtFim + "' "

		dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cAlias, .F., .F.)

		//Abre transação para inclusão dos dados.
		BEGIN TRANSACTION

			lRet := limpaDados(cPeriod, @cMsg)

			While (cAlias)->(!Eof()) .And. lRet
				lEntrou := .T.

				//Calcula o peso em gramas para sumarizar aos dados da HZ4, HZ5 e HZ6
				nPesoGrama := Round((cAlias)->(D2_QUANT) * (cAlias)->(HZ2_PESOGR), nDecGrama)
				agrupaHZ5(@oDadosHZ5, cAlias, nPesoGrama)
				agrupaHZ6(@oDadosHZ6, cAlias, nPesoGrama)
				
				lRet := oBulk:addData({ cFilHZ4                ,; //HZ4_FILIAL
										cPeriod                ,; //HZ4_PERIOD
										(cAlias)->(F2_EST)     ,; //HZ4_UFDEST
										(cAlias)->(D2_COD)     ,; //HZ4_PRODUT
										(cAlias)->(D2_QUANT)   ,; //HZ4_QTDNOT
										(cAlias)->(HZ2_TIPMAT) ,; //HZ4_TIPMAT
										(cAlias)->(HZ2_SEQMAT) ,; //HZ4_SEQMAT
										(cAlias)->(HZ2_PESOGR) ,; //HZ4_PEUNGR
										(cAlias)->(HZ2_PRTPRO) ,; //HZ4_PRTPRO
										nPesoGrama             ,; //HZ4_PESOGR
										(cAlias)->(F2_DOC)     ,; //HZ4_NDOC
										(cAlias)->(F2_SERIE)   ,; //HZ4_NSERIE
										(cAlias)->(CLIENTE)    ,; //HZ4_NCLIEN
										(cAlias)->(LOJA)       ,; //HZ4_NLOJA
										(cAlias)->(D2_ITEM)    ,; //HZ4_NITEM
										(cAlias)->(F2_EMISSAO) }) //HZ4_NEMISS
				
				cMsg := Iif(lRet, "", oBulk:getError())

				(cAlias)->(dbSkip())
			End
			(cAlias)->(dbCloseArea())

			//Se os dados estiverem corretos, faz o Close do FwBulk para inserir possíveis registros não inseridos e finalizar o bulk.
			If lRet 
				lRet := oBulk:Close()
				cMsg := Iif(lRet, "", oBulk:getError())
			EndIf
			
			//Limpa objeto do FwBulk para reutilizar com outra tabela.
			oBulk:Destroy()
			FwFreeObj(oBulk)

			//Processa inclusão da HZ5
			If lRet
				lRet := incluiHZ5(@oDadosHZ5, cPeriod, @cMsg)
			EndIf

			//Processa inclusão da HZ6
			If lRet
				lRet := incluiHZ6(@oDadosHZ6, cPeriod, @cMsg)
			EndIf

			//Faz rollback caso tenha ocorrido algum erro.
			If !lRet
				DisarmTransaction()
			EndIf
		
			If lRet .And. !lEntrou
				lRet := .F.
				cMsg := STR0007 //"Não foram encontradas notas fiscais para o período informado."
			EndIf

			//Atualiza o status de processamento do período
			atuPeriodo(cFil, cPeriod, Iif(lRet, STATUS_HZ3_CALCULADO, STATUS_HZ3_ERRO), cMsg)
		END TRANSACTION

		FwFreeObj(oDadosHZ5)
		FwFreeObj(oDadosHZ6)

	END SEQUENCE

	ErrorBlock(oBlkErr)

Return

/*/{Protheus.doc} ESGINVCERR
Função para tratativa de erros de execução

@type  Function
@author lucas.franca
@since 20/04/2022
@version P12
@param oErro  , Object, Objeto com os dados do erro
@param cFil   , Character, Código da filial para processamento
@param cPeriod, Character, Código do período para processamento
@param cChave , Character, Chave da variável global de controle do processo.
@return Nil
/*/
Function ESGINVCERR(oErro, cFil, cPeriod, cChave)

	Local cMsgErr := oErro:description + oErro:errorStack

	LogMsg("ESGINVCERR", 0, 0, 1, '', '', AllTrim(oErro:description) + CHR(10) + AllTrim(oErro:ErrorStack) + CHR(10) + oErro:ErrorEnv)

	//Grava global com status de erro para caso tenha ocorrido erro no prepare environment, gravar o erro na thread da API
	PutGlbValue(cChave, "ERRO")
	PutGlbValue(cChave+"ERRO", cMsgErr)

	If InTransact()
		DisarmTransaction()
	EndIf

	If !Empty(cFilAnt)
		//Se conectou ao ambiente, grava mensagem de erro
		atuPeriodo(cFil, cPeriod, STATUS_HZ3_ERRO, cMsgErr)
	EndIf

	BREAK
Return

/*/{Protheus.doc} limpaDados
Faz a limpeza de dados existentes nas tabelas HZ4, HZ5 e HZ6 para o período informado

@type  Static Function
@author lucas.franca
@since 13/04/2022
@version P12
@param cPeriod, Character, Código do período para limpeza dos dados
@param cMsg   , Character, Retorna por referência mensagem de erro caso tenha ocorrido.
@return lRet, Logic, Indica se a operação foi realizada corretamente
/*/
Static Function limpaDados(cPeriod, cMsg)
	Local cSql := ""
	Local lRet := .T.

	cSql := " UPDATE " + RetSqlName("HZ4") + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ "
	cSql +=  " WHERE HZ4_FILIAL = '" + xFilial("HZ4") + "' "
	cSql +=    " AND HZ4_PERIOD = '" + cPeriod + "' "
	cSql +=    " AND D_E_L_E_T_ = ' ' "

	lRet := TcSQLExec(cSql) >= 0
	cMsg := Iif(lRet, "", I18N(STR0015, {'HZ4'}) + TcSqlError()) //"Erro ao limpar os dados da tabela '#1[TABELA]#'. Erro: "
	If lRet 
		cSql := " UPDATE " + RetSqlName("HZ5") + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ "
		cSql +=  " WHERE HZ5_FILIAL = '" + xFilial("HZ5") + "' "
		cSql +=    " AND HZ5_PERIOD = '" + cPeriod + "' "
		cSql +=    " AND D_E_L_E_T_ = ' ' "

		lRet := TcSQLExec(cSql) >= 0
		cMsg := Iif(lRet, "", I18N(STR0015, {'HZ5'}) + TcSqlError()) //"Erro ao limpar os dados da tabela '#1[TABELA]#'. Erro: "
	EndIf
	If lRet 
		cSql := " UPDATE " + RetSqlName("HZ6") + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ "
		cSql +=  " WHERE HZ6_FILIAL = '" + xFilial("HZ6") + "' "
		cSql +=    " AND HZ6_PERIOD = '" + cPeriod + "' "
		cSql +=    " AND D_E_L_E_T_ = ' ' "

		lRet := TcSQLExec(cSql) >= 0
		cMsg := Iif(lRet, "", I18N(STR0015, {'HZ6'}) + TcSqlError()) //"Erro ao limpar os dados da tabela '#1[TABELA]#'. Erro: "
	EndIf

Return lRet

/*/{Protheus.doc} agrupaHZ5
Agrupa as informações para gravar na tabela HZ5

@type  Static Function
@author lucas.franca
@since 12/04/2022
@version P12
@param 01 oDadosHZ5 , JsonObject, Recebe o JSON por referência, com todos os dados da HZ5
@param 02 cAlias    , Character , Alias da query com os dados das notas
@param 03 nPesoGrama, Numeric   , Peso calculado para o material
@return Nil
/*/
Static Function agrupaHZ5(oDadosHZ5, cAlias, nPesoGrama)
	Local cChaveHZ5 := ""

	//Chave de controle para sumarização de cada tabela
	cChaveHZ5 := (cAlias)->(F2_EST + D2_COD + HZ2_TIPMAT) //UFDEST + PRODUTO + TIPO DO MATERIAL
	
	//Se ainda não tem a chave no json de dados da HZ5, adiciona os dados para sumarizar.
	If !oDadosHZ5:HasProperty(cChaveHZ5)
		oDadosHZ5[cChaveHZ5] := JsonObject():New() 
		oDadosHZ5[cChaveHZ5]["UF_DEST"] := (cAlias)->(F2_EST)
		oDadosHZ5[cChaveHZ5]["PRODUTO"] := (cAlias)->(D2_COD)
		oDadosHZ5[cChaveHZ5]["TIP_MAT"] := (cAlias)->(HZ2_TIPMAT)
		oDadosHZ5[cChaveHZ5]["PESO_GR"] := 0
		oDadosHZ5[cChaveHZ5]["QTD_PRD"] := 0
	EndIf
	
	//Sumariza os dados da HZ5
	oDadosHZ5[cChaveHZ5]["QTD_PRD"] += (cAlias)->(D2_QUANT)
	oDadosHZ5[cChaveHZ5]["PESO_GR"] += nPesoGrama
Return Nil

/*/{Protheus.doc} incluiHZ5
Faz o processamento da inclusão das informações na tabela HZ5

@type  Static Function
@author lucas.franca
@since 12/04/2022
@version P12
@param 01 oDadosHZ5, JsonObject, Recebe o JSON por referência, com todos os dados da HZ5
@param 02 cPeriod  , Character , Código do período em processamento
@param 03 cMsg     , Character , Retorna por referência mensagem de erro
@return lRet, Logic, Identifica se os dados foram processados corretamente.
/*/
Static Function incluiHZ5(oDadosHZ5, cPeriod, cMsg)
	Local aNames   := oDadosHZ5:GetNames()
	Local cFilHZ5  := xFilial("HZ5")
	Local cChave   := ""
	Local lRet     := .T.
	Local nIndex   := 0
	Local nTotal   := Len(aNames)
	Local nDecimal := GetSX3Cache("HZ5_MTPEKG", "X3_DECIMAL")
	Local oBulk    := FwBulk():New(RetSqlName("HZ5"))

	oBulk:setFields({ {"HZ5_FILIAL"} ,;
	                  {"HZ5_PERIOD"} ,;
	                  {"HZ5_UFDEST"} ,;
	                  {"HZ5_PRODUT"} ,;
	                  {"HZ5_QTPROD"} ,;
	                  {"HZ5_TIPMAT"} ,;
	                  {"HZ5_MTPEKG"} })

	While nIndex < nTotal .And. lRet 
		nIndex++
		cChave := aNames[nIndex]

		//Converte o peso em gramas para peso em quilos
		oDadosHZ5[cChave]["PESO_GR"] := Round(oDadosHZ5[cChave]["PESO_GR"] / 1000, nDecimal)

		lRet := oBulk:addData({ cFilHZ5                     , ; //HZ5_FILIAL
		                        cPeriod                     , ; //HZ5_PERIOD
		                        oDadosHZ5[cChave]["UF_DEST"], ; //HZ5_UFDEST
		                        oDadosHZ5[cChave]["PRODUTO"], ; //HZ5_PRODUT
		                        oDadosHZ5[cChave]["QTD_PRD"], ; //HZ5_QTPROD
		                        oDadosHZ5[cChave]["TIP_MAT"], ; //HZ5_TIPMAT
		                        oDadosHZ5[cChave]["PESO_GR"]} ) //HZ5_MTPEKG
		
		cMsg := Iif(lRet, "", oBulk:getError())
	End
	
	//Se os dados estiverem corretos, faz o Close do FwBulk para inserir possíveis registros não inseridos e finalizar o bulk.
	If lRet 
		lRet := oBulk:Close()
		cMsg := Iif(lRet, "", oBulk:getError())
	EndIf
	
	//Limpa objeto do FwBulk para reutilizar com outra tabela.
	oBulk:Destroy()
	FwFreeObj(oBulk)

	aSize(aNames, 0)

Return lRet

/*/{Protheus.doc} agrupaHZ6
Agrupa as informações para gravar na tabela HZ6

@type  Static Function
@author lucas.franca
@since 12/04/2022
@version P12
@param 01 oDadosHZ6 , JsonObject, Recebe o JSON por referência, com todos os dados da HZ6
@param 02 cAlias    , Character , Alias da query com os dados das notas
@param 03 nPesoGrama, Numeric   , Peso calculado para o material
@return Nil
/*/
Static Function agrupaHZ6(oDadosHZ6, cAlias, nPesoGrama)
	Local cChaveHZ6 := ""

	//Chave de controle para sumarização de cada tabela
	cChaveHZ6 := (cAlias)->(F2_EST + HZ2_TIPMAT) //UFDEST + TIPO DO MATERIAL
	
	//Se ainda não tem a chave no json de dados da HZ6, adiciona os dados para sumarizar.
	If !oDadosHZ6:HasProperty(cChaveHZ6)
		oDadosHZ6[cChaveHZ6] := JsonObject():New()
		oDadosHZ6[cChaveHZ6]["UF_DEST"] := (cAlias)->(F2_EST)
		oDadosHZ6[cChaveHZ6]["TIP_MAT"] := (cAlias)->(HZ2_TIPMAT)
		oDadosHZ6[cChaveHZ6]["PESO_GR"] := 0
		oDadosHZ6[cChaveHZ6]["PER_COM"] := PERCENTUAL_DE_COMPENSACAO
	EndIf

	//Sumariza os dados da HZ6
	oDadosHZ6[cChaveHZ6]["PESO_GR"] += nPesoGrama
Return Nil

/*/{Protheus.doc} incluiHZ6
Faz o processamento da inclusão das informações na tabela HZ6

@type  Static Function
@author lucas.franca
@since 12/04/2022
@version P12
@param 01 oDadosHZ6, JsonObject, Recebe o JSON por referência, com todos os dados da HZ6
@param 02 cPeriod  , Character , Código do período em processamento
@param 03 cMsg     , Character , Retorna por referência mensagem de erro
@return lRet, Logic, Identifica se os dados foram processados corretamente.
/*/
Static Function incluiHZ6(oDadosHZ6, cPeriod, cMsg)
	Local aNames   := oDadosHZ6:GetNames()
	Local cFilHZ6  := xFilial("HZ6")
	Local cChave   := ""
	Local lRet     := .T.
	Local nIndex   := 0
	Local nQtdComp := 0
	Local nDecKG   := GetSX3Cache("HZ6_PESOKG", "X3_DECIMAL")
	Local nTamCod  := GetSX3Cache("HZ6_CODIGO", "X3_TAMANHO")
	Local nTotal   := Len(aNames)
	Local oBulk    := FwBulk():New(RetSqlName("HZ6"))

	oBulk:setFields({ {"HZ6_FILIAL"} , ;
	                  {"HZ6_CODIGO"} , ;
	                  {"HZ6_PERIOD"} , ;
	                  {"HZ6_UFDEST"} , ;
	                  {"HZ6_TIPMAT"} , ;
	                  {"HZ6_PESOKG"} , ;
	                  {"HZ6_PERCOM"} , ;
	                  {"HZ6_QTCMPR"} , ;
	                  {"HZ6_QTCMPD"} , ;
	                  {"HZ6_AGRTID"} , ;
	                  {"HZ6_STATUS"} } )

	While nIndex < nTotal .And. lRet 
		nIndex++
		cChave := aNames[nIndex]
		
		//Converte o peso em gramas para peso em quilos
		oDadosHZ6[cChave]["PESO_GR"] := Round(oDadosHZ6[cChave]["PESO_GR"] / 1000, nDecKG)
		
		//Calcula a qtd a compensar
		nQtdComp := Ceiling(oDadosHZ6[cChave]["PESO_GR"] * oDadosHZ6[cChave]["PER_COM"])

		lRet := oBulk:addData({ cFilHZ6                     , ; //HZ6_FILIAL
		                        StrZero(nIndex, nTamCod)    , ; //HZ6_CODIGO
		                        cPeriod                     , ; //HZ6_PERIOD
		                        oDadosHZ6[cChave]["UF_DEST"], ; //HZ6_UFDEST
		                        oDadosHZ6[cChave]["TIP_MAT"], ; //HZ6_TIPMAT
		                        oDadosHZ6[cChave]["PESO_GR"], ; //HZ6_PESOKG
		                        oDadosHZ6[cChave]["PER_COM"], ; //HZ6_PERCOM
		                        nQtdComp                    , ; //HZ6_QTCMPR
		                        0                           , ; //HZ6_QTCMPD
		                        ""                          , ; //HZ6_AGRTID
		                        ""                          } ) //HZ6_STATUS
		
		cMsg := Iif(lRet, "", oBulk:getError())
	End
	
	//Se os dados estiverem corretos, faz o Close do FwBulk para inserir possíveis registros não inseridos e finalizar o bulk.
	If lRet 
		lRet := oBulk:Close()
		cMsg := Iif(lRet, "", oBulk:getError())
	EndIf
	
	//Limpa objeto do FwBulk para reutilizar com outra tabela.
	oBulk:Destroy()
	FwFreeObj(oBulk)

	aSize(aNames, 0)

Return lRet

/*/{Protheus.doc} criaMsgErr
Cria o retorno da mensagem de erro

@type Static Function
@author lucas.franca
@since 11/04/2022
@version P12
@param cMensagem, Character, Mensagem de erro
@param cDetalhe , Character, Mensagem detalhada de erro
@return Nil
/*/
Static Function criaMsgErr(cMensagem, cDetalhe)
	SetRestFault(400, EncodeUtf8(cMensagem), .T., 400, EncodeUtf8(cDetalhe))
Return Nil

/*/{Protheus.doc} validaDic
Valida se o dicionário de dados possui as tabelas necessárias para utilização desta API

@type Static Function
@author lucas.franca
@since 11/04/2022
@version P12
@return lRet, Logic, Indica se o dicionário de dados está correto
/*/
Static Function validaDic()
	Local lRet := FWAliasInDic("HZ1", .F.)

	If !lRet
		criaMsgErr(STR0009, STR0010) //"Dicionário de dados desatualizado." # "As tabelas necessárias para execução deste processo não existem no dicionário de dados."
	EndIf

Return lRet

/*/{Protheus.doc} validaFil
Valida se a filial informada é válida

@type Static Function
@author lucas.franca
@since 11/04/2022
@version P12
@param cFilProc, Character, Código da filial
@return lRet, Logic, Indica se a filial recebida é válida.
/*/
Static Function validaFil(cFilProc)
	Local lRet := .T.

	If cFilProc != cFilAnt
		lRet := FWFilExist(cEmpAnt, cFilProc)
		If !lRet 
			criaMsgErr(STR0011, I18N(STR0012, {cFilProc})) //"Filial inválida." # "A filial '#1[CODFILIAL]#' não existe no ambiente."
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} iniciaPeri
Verifica se um período pode iniciar o processamento, e atualiza a tabela HZ3 para iniciar o processamento

@type  Static Function
@author lucas.franca
@since 20/04/2022
@version P12
@param cFilProc, Character, Código da filial para processamento
@param cPeriod , Character, Número do período de processamento
@return lRet, Logic, Identifica se o período pode iniciar o processamento
/*/
Static Function iniciaPeri(cFilProc, cPeriod)
	Local lRet := .T.

	If !HZ3->(dbSeek(xFilial("HZ3", cFilProc) + cPeriod))
		lRet := .F.
		criaMsgErr(STR0020, STR0021) //"Período inexistente." # "Este período não existe. Utilize um período previamente cadastrado para efetuar o cálculo."
	ElseIf HZ3->HZ3_STCALC == STATUS_HZ3_EM_CALCULO
		lRet := .F.
		criaMsgErr(STR0016, STR0017) //"Período já está em processamento." # "Aguarde o término do processamento atual do período para reprocessá-lo."
	EndIf

	If lRet
		atuPeriodo(cFilProc, cPeriod, STATUS_HZ3_EM_CALCULO, "")
	EndIf

Return lRet 

/*/{Protheus.doc} atuPeriod
Atualiza período na tabela HZ3

@type  Static Function
@author lucas.franca
@since 11/04/2022
@version P12
@param cFilProc, Character, Código da filial para processamento
@param cPeriod , Character, Código do período de processamento
@param cStatus , Character, Status a ser salvo na tabela de período (HZ3_STCALC)
                             1 - Cadastrado e pendente de cálculo
                             2 - Em cálculo
                             3 - Calculado com sucesso
                             4 - Erro de processamento
@param cMsg    , Character, Mensagem a ser gravada na coluna HZ3_MSG
@return Nil
/*/
Static Function atuPeriodo(cFilProc, cPeriod, cStatus, cMsg)
	
	If HZ3->(dbSeek(xFilial("HZ3", cFilProc) + cPeriod))
		RecLock("HZ3", .F.)
			//Atualiza data, hora e status.
			HZ3->HZ3_DTCALC := DtoS(Date())
			HZ3->HZ3_HRCALC := SubStr(Time(), 1, 5)
			HZ3->HZ3_STCALC := cStatus
			HZ3->HZ3_MSG    := cMsg
		HZ3->(MsUnLock())
	EndIf
Return Nil
