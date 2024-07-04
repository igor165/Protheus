#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "PCPALLOCATIONS.CH"

Static _aMapFields := MapFields(1)
Static _aTamQtd := TamSX3("D4_QUANT")

//dummy function
//Function PCPAllocat()
//Return

WSRESTFUL pcpallocations DESCRIPTION STR0001 FORMAT APPLICATION_JSON //"Empenhos"
	WSDATA Fields          AS STRING  OPTIONAL
	WSDATA Order           AS STRING  OPTIONAL
	WSDATA Page            AS INTEGER OPTIONAL
	WSDATA PageSize        AS INTEGER OPTIONAL
	WSDATA productionOrder AS STRING  OPTIONAL
	WSDATA registerNumber  AS INTEGER OPTIONAL

	WSMETHOD GET ALLALLOCAT;
		DESCRIPTION STR0002; //"Retorna todos os empenhos da tabela SD4"
		WSSYNTAX "api/pcp/v1/pcpallocations" ;
		PATH "/api/pcp/v1/pcpallocations" ;
		TTALK "v1"

	WSMETHOD GET ALLOCATION;
		DESCRIPTION STR0003; //"Retorna um empenho do MRP específico"
		WSSYNTAX "api/pcp/v1/pcpallocations/{productionOrder}" ;
		PATH "/api/pcp/v1/pcpallocations/{productionOrder}" ;
		TTALK "v1"

	WSMETHOD GET VIEW;
		DESCRIPTION STR0004; //"Retorna lista de empenhos - Tabelas SD4/SDC"
		WSSYNTAX "api/pcp/v1/pcpallocations/view/list" ;
		PATH "/api/pcp/v1/pcpallocations/view/list" ;
		TTALK "v1"

	WSMETHOD POST ALLOCATION;
		DESCRIPTION STR0006; //"Inclui ou altera um empenho."
		WSSYNTAX "api/pcp/v1/pcpallocations" ;
		PATH "/api/pcp/v1/pcpallocations" ;
		TTALK "v1"

	WSMETHOD DELETE ALLOCATION;
		DESCRIPTION STR0007; //"Deleta informações de um empenho"
		WSSYNTAX "api/pcp/v1/pcpallocations/deleteallocation/{registerNumber}" ;
		PATH "/api/pcp/v1/pcpallocations/deleteallocation/{registerNumber}" ;
		TTALK "v1"

ENDWSRESTFUL

WSMETHOD GET ALLALLOCAT QUERYPARAM Order, Page, PageSize, Fields WSSERVICE pcpallocations
	Local aReturn := {}
	Local lRet    := .T.

	Self:SetContentType("application/json")

	aReturn := PCPEmpGAll(Self:aQueryString, Self:Order, Self:Page, Self:PageSize, Self:Fields)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	aSize(aReturn, 0)
Return lRet

WSMETHOD GET ALLOCATION PATHPARAM productionOrder QUERYPARAM Fields WSSERVICE pcpallocations
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a função para retornar os dados.
	aReturn := PcpEmpGet(Self:productionOrder, Self:Fields)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	aSize(aReturn, 0)
Return lRet

WSMETHOD GET VIEW WSRECEIVE page, pageSize, order WSSERVICE pcpallocations
	Local aReturn := {}
	Local lRet    := .T.

	DEFAULT Self:page     := 1
	DEFAULT Self:pageSize := 20
	DEFAULT Self:order    := 'branchId, product, productionOrder, lot'

	Self:SetContentType("application/json")

	aReturn := PCPEmpGetL(Self:aQueryString, Self:Page, Self:PageSize, Self:Order)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	aSize(aReturn, 0)
Return lRet

/*/{Protheus.doc} POST ALLOCATION /api/pcp/v1/pcpallocations
Inclui ou altera informações dos empenhos

@type WSMETHOD
@author marcelo.neumann
@since 24/03/2021
@version P12
@return lRet, Lógico, Informa se o processo foi executado com sucesso.
/*/
WSMETHOD POST ALLOCATION WSSERVICE pcpallocations
	Local aQuery    := {}
	Local aReturn   := {}
	Local cError    := ""
	Local lRet      := .T.
	Local oBody     := JsonObject():New()

	Self:SetContentType("application/json")

	cError := oBody:FromJson(Self:GetContent())
	If cError == Nil
		aReturn := alteraEmp(oBody, 3)

		If aReturn[1] == 201
			If Empty(oBody["allocationDetails"][1]["registerNumber"])
				aAdd(aQuery, {"branchId"             , IIf(Empty(oBody["branchId"]), xFilial("SD4"), oBody["branchId"])})
				aAdd(aQuery, {"productionOrder"      , oBody["productionOrder"                                        ]})
				aAdd(aQuery, {"product"              , oBody["product"                                                ]})
				aAdd(aQuery, {"warehouse"            , oBody["warehouse"                                              ]})
				aAdd(aQuery, {"lot"                  , oBody["lot"                                                    ]})
				aAdd(aQuery, {"originProductionOrder", oBody["allocationDetails"][1]["originProductionOrder"          ]})
				aAdd(aQuery, {"sequential"           , oBody["allocationDetails"][1]["sequential"                     ]})
				aAdd(aQuery, {"sequence"             , oBody["allocationDetails"][1]["sequence"                       ]})
				aAdd(aQuery, {"subLot"               , oBody["allocationDetails"][1]["sublot"                         ]})
				aAdd(aQuery, {"allocationDate"       , oBody["allocationDetails"][1]["allocationDate"                 ]})
			Else
				aAdd(aQuery, {"registerNumber"       , oBody["allocationDetails"][1]["registerNumber"                 ]})
			EndIf

			aReturn := EmpGetList(aQuery)
			MRPApi():restReturn(Self, aReturn, "GET", @lRet)
		Else
			criaMsgErr(STR0008, aReturn[2]) //"Não foi possível gravar o empenho."
			lRet := .F.
		EndIf
	Else
		//Ocorreu erro ao transformar os dados recebidos em objeto JSON.
		criaMsgErr(STR0009, cError) //"Não foi possível interpretar os dados recebidos."
		lRet := .F.
	EndIf

	FreeObj(oBody)
	oBody := Nil
	aSize(aQuery , 0)
	aSize(aReturn, 0)

Return lRet

/*/{Protheus.doc} DELETE ALLOCATION /api/pcp/v1/pcpallocations/deleteallocation/{registerNumber}
Exclui informações dos empenhos

@type WSMETHOD
@author lucas.franca
@since 24/03/2021
@version P12
@param registerNumber, Numérico, R_E_C_N_O_ do registro da SD4 a ser excluído
@return lRet         , Lógico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD DELETE ALLOCATION PATHPARAM registerNumber WSSERVICE pcpallocations
	Local aReturn := {}
	Local lRet    := .T.
	Local oBody   := JsonObject():New()

	Self:SetContentType("application/json")

	oBody["allocationDetails"] := {JsonObject():New()}
	oBody["allocationDetails"][1]["registerNumber"] := Self:registerNumber

	aReturn := alteraEmp(oBody, 5)

	If aReturn[1] == 204
		HTTPSetStatus(aReturn[1])
		Self:SetResponse("")
	Else
		criaMsgErr(STR0010, aReturn[2]) //"Não foi possível excluir o empenho."
		lRet := .F.
	EndIf

	FreeObj(oBody)
	oBody := Nil
	aSize(aReturn, 0)

Return lRet

/*/{Protheus.doc} PCPEmpGAll
Função para disparar as ações da API de Empenhos do MRP, para o método GET (Consulta) para vários empenhos.

@type  Function
@author douglas.heydt
@since 29/10/2020
@version P12.1.27
@param aQuery   , Array    , Array com os dados que devem ser filtrados.
                             Exemplo: Array[1]
                                      Array[1][1] = "PRODUCT"
                                      Array[1][2] = "PRODUTO001"
                                      Array[2]
                                      Array[2][1] = "PRODUCTIONORDER"
                                      Array[2][2] = "00000101001"
@param cOrder   , Character, Ordenação desejada do retorno.
@param nPage    , Numeric  , Página dos dados. Se não enviado, considera página 1.
@param nPageSize, Numeric  , Quantidade de registros retornados por página. Se não enviado, considera 20 registros por página.
@param cFields  , Character, Campos que devem ser retornados. Se não enviado, retorna todos os fields que possuem valor.
@return aReturn , Array    , Array com as informações da requisição.
                             aReturn[1] - Lógico    - Indica se a requisição foi processada com sucesso ou não.
						     aReturn[2] - Character - JSON com o resultado da requisição, ou com a mensagem de erro.
						     aReturn[3] - Numeric   - Código de erro identificado pelo MRPApi.
/*/
Function PCPEmpGAll(aQuery, cOrder, nPage, nPageSize, cFields)
	Local aReturn := {}

	//Processa o GET
	aReturn := EmpGet(.T., aQuery, cOrder, nPage, nPageSize, cFields)
Return aReturn

/*/{Protheus.doc} PcpEmpGet
Função para disparar as ações da API de Empenhos do MRP, para o método GET (Consulta) de um empenho específico.

@type  Function
@author douglas.heydt
@since 29/10/2020
@version P12.1.27
@param cBranch , Caracter, Código da filial
@param cCode   , Caracter, Código único do empenho
@param cFields , Caracter, Campos que devem ser retornados.
@return aReturn, Array, Array com as informações da requisição.
                        aReturn[1] - Lógico    - Indica se a requisição foi processada com sucesso ou não.
						aReturn[2] - Character - JSON com o resultado da requisição, ou com a mensagem de erro.
						aReturn[3] - Numeric   - Código de erro identificado pelo MRPApi.
/*/
Function PcpEmpGet(cOp, cFields)
	Local aReturn   := {}
	Local aQryParam := {}

	//Adiciona os filtros de filial e produto como QueryParam.
	aAdd(aQryParam, {"PRODUCTIONORDER", cOp})

	If !Empty(cFields)
		//Adiciona o FIELDS se for recebido.
		aAdd(aQryParam, {"FIELDS", cFields})
	EndIf

	//Chama a função para retornar os dados.
	aReturn := EmpGet(.T., aQryParam, Nil, Nil, Nil, cFields)
Return aReturn

/*/{Protheus.doc} PCPEmpGetL
Função para disparar as ações da API de Empenhos do MRP, para o método GET (Consulta) endpoint VIEW (Lista de empenhos para o APP Minha Produção).

@type  Function
@author parffit.silva
@since 16/03/2021
@version P12.1.27
@param aQuery   , Array    , Array com os dados que devem ser filtrados.
                             Exemplo: Array[1]
                                      Array[1][1] = "PRODUCT"
                                      Array[1][2] = "PRODUTO001"
                                      Array[2]
                                      Array[2][1] = "PRODUCTIONORDER"
                                      Array[2][2] = "00000101001"
@param nPage    , Numeric  , Página dos dados. Se não enviado, considera página 1.
@param nPageSize, Numeric  , Quantidade de registros retornados por página. Se não enviado, considera 20 registros por página.
@param cOrder   , Character, Ordenação desejada do retorno.
@return aReturn , Array    , Array com as informações da requisição.
                             aReturn[1] - Lógico    - Indica se a requisição foi processada com sucesso ou não.
						     aReturn[2] - Character - JSON com o resultado da requisição, ou com a mensagem de erro.
						     aReturn[3] - Numeric   - Código de erro identificado pelo MRPApi.
/*/
Function PCPEmpGetL(aQuery, nPage, nPageSize, cOrder)
	Local aReturn := {}

	//Processa o GET
	aReturn := EmpGetList(aQuery, nPage, nPageSize, cOrder)
Return aReturn

/*/{Protheus.doc} MapFields
Gera o array com o MAP dos fields da API e os fields da tabela SD4

@type  Static Function
@author douglas.heydt
@since 29/10/2020
@version P12.1.27
@param  nType  , Numeric, Objetivo da lista de campos: 1 - Genérico, 2 - Lista de Empenhos APP Minha Produção.
@return aFields, Array, Array contendo o MAP dos fields da API e da tabela
/*/
Static Function MapFields(nType)
	Local aFields := {}

	If nType == 1
		aFields := { ;
					{"branchId"               , "D4_FILIAL" , "C", FWSizeFilial()                        , 0},;
					{"product"                , "D4_COD"    , "C", GetSx3Cache("D4_COD"    ,"X3_TAMANHO"), 0},;
					{"warehouse"              , "D4_LOCAL"  , "C", GetSx3Cache("D4_LOCAL"  ,"X3_TAMANHO"), 0},;
					{"allocationDate"         , "D4_DATA"   , "D", 8                                     , 0},;
					{"quantity"               , "D4_QUANT"  , "N", GetSx3Cache("D4_QUANT"  ,"X3_TAMANHO"), GetSx3Cache("D4_QUANT", "X3_DECIMAL")},;
					{"sequence"               , "D4_TRT"    , "C", GetSx3Cache("D4_TRT"    ,"X3_TAMANHO"), 0},;
					{"lot"                    , "D4_LOTECTL", "C", GetSx3Cache("D4_LOTECTL","X3_TAMANHO"), 0},;
					{"sublot"                 , "D4_NUMLOTE", "C", GetSx3Cache("D4_NUMLOTE","X3_TAMANHO"), 0},;
					{"expirationDate"         , "D4_DTVALID", "D", 8                                     , 0},;
					{"productionOrder"        , "D4_OP"     , "C", GetSx3Cache("D4_OP"     ,"X3_TAMANHO"), 0},;
					{"originalProductionOrder", "D4_OPORIG" , "C", GetSx3Cache("D4_OPORIG" ,"X3_TAMANHO"), 0},;
					{"operation"              , "D4_OPERAC" , "C", GetSx3Cache("D4_OPERAC" ,"X3_TAMANHO"), 0},;
					{"routing"                , "D4_ROTEIRO", "C", GetSx3Cache("D4_ROTEIRO","X3_TAMANHO"), 0};
				}
	ElseIf nType == 2
		aFields := { ;
					{"branchId"                  , "SD4.D4_FILIAL"    , "C", "AH"},;
					{"productionOrder"           , "SD4.D4_OP"        , "C", "AH"},;
					{"product"                   , "SD4.D4_COD"       , "C", "AH"},;
					{"productDescription"        , "SB1.B1_DESC"      , "C", "AH"},;
					{"warehouse"                 , "SD4.D4_LOCAL"     , "C", "AH"},;
					{"lot"                       , "SD4.D4_LOTECTL"   , "C", "AH"},;
					{"quantity"                  , "SUM(SD4.D4_QUANT)", "N", "AH"},;
					{"allocationDate"            , "SD4.D4_DATA"      , "D", "AD"},;
					{"sequence"                  , "SD4.D4_TRT"       , "C", "AD"},;
					{"subLot"                    , "SD4.D4_NUMLOTE"   , "C", "AD"},;
					{"expirationDate"            , "SD4.D4_DTVALID"   , "D", "AD"},;
					{"allocationQuantity"        , "SD4.D4_QUANT"     , "N", "AD"},;
					{"originProductionOrder"     , "SD4.D4_OPORIG"    , "C", "AD"},;
					{"operation"                 , "SD4.D4_OPERAC"    , "C", "AD"},;
					{"quantityInProcess"         , "SD4.D4_EMPROC"    , "N", "AD"},;
					{"potency"                   , "SD4.D4_POTENCI"   , "N", "AD"},;
					{"originProduct"             , "SD4.D4_PRDORG"    , "C", "AD"},;
					{"fatherProduct"             , "SD4.D4_PRODUTO"   , "C", "AD"},;
					{"originQuantity"            , "SD4.D4_QTDEORI"   , "N", "AD"},;
					{"balanceQuantity"           , "SD4.D4_QUANT"     , "N", "AD"},;
					{"secondUnitQuantity"        , "SD4.D4_QTSEGUM"   , "N", "AD"},;
					{"sequential"                , "SD4.D4_SEQ"       , "C", "AD"},;
					{"registerNumber"            , "SD4.R_E_C_N_O_"   , "N", "AD"},;
					{"localization"              , "SDC.DC_LOCALIZ"   , "C", "LD"},;
					{"serialNumber"              , "SDC.DC_NUMSERI"   , "C", "LD"},;
					{"localizationQuantity"      , "SDC.DC_QUANT"     , "N", "LD"},;
					{"localizationOriginQuantity", "SDC.DC_QTDORIG"   , "N", "LD"},;
					{"localizationRegisterNumber", "SDC.R_E_C_N_O_"   , "N", "LD"};
				}
	EndIf
Return aFields

/*/{Protheus.doc} EmpGet
Executa o processamento do método GET de acordo com os parâmetros recebidos.

@type  Static Function
@author douglas.heydt
@since 29/10/2020
@version P12.1.27
@param lLista   , Logic    , Indica se deverá retornar uma lista de registros (.T.), ou apenas um registro (.F.).
@param aQuery   , Array    , Array com os dados que devem ser filtrados.
                             Exemplo: Array[1]
                                      Array[1][1] = "PRODUCT"
                                      Array[1][2] = "PRODUTO001"
                                      Array[2]
                                      Array[2][1] = "PRODUCTIONORDER"
                                      Array[2][2] = "00000101001"
@param cOrder   , Character, Ordenação desejada do retorno.
@param nPage    , Numeric  , Página dos dados. Se não enviado, considera página 1.
@param nPageSize, Numeric  , Quantidade de registros retornados por página. Se não enviado, considera 20 registros por página.
@param cFields  , Character, Campos que devem ser retornados. Se não enviado, retorna todos os fields que possuem valor.
@return aReturn , Array    , Array com as informações da requisição.
                             aReturn[1] - Lógico    - Indica se a requisição foi processada com sucesso ou não.
						     aReturn[2] - Character - JSON com o resultado da requisição, ou com a mensagem de erro.
						     aReturn[3] - Numeric   - Código de erro identificado pelo MRPApi.
/*/
Static Function EmpGet(lLista, aQuery, cOrder, nPage, nPageSize, cFields)
	Local aReturn := {.T.,"",200}
	Local oMRPApi := defMRPApi("GET",cOrder) //Instância da classe MRPApi para o método GET
	Local nIndex  := 0

	For nIndex := 1 To Len(aQuery)
		If aQuery[nIndex][1] == "PRODUCTIONORDER"
			If ',' $ aQuery[nIndex][2]
				//Adiciona a cláusula .IN. no filtro de ordem de produção quando informadas mais de uma OP.
				aQuery[nIndex][2] := ".IN." + AllTrim(aQuery[nIndex][2])
			EndIf
		EndIf
	Next nIndex

	//Seta os parâmetros de paginação, filtros e campos para retorno
	oMRPApi:setFields(cFields)
	oMRPApi:setPage(nPage)
	oMRPApi:setPageSize(nPageSize)
	oMRPApi:setQueryParams(aQuery)
	oMRPApi:setUmRegistro(!lLista)

	//Executa o processamento
	aReturn[1] := oMRPApi:processar("fields")
	//Retorna o status do processamento
	aReturn[3] := oMRPApi:getStatus()
	If aReturn[1]
		//Se processou com sucesso, recupera o JSON com os dados.
		aReturn[2] := oMRPApi:getRetorno(1)
	Else
		//Ocorreu algum erro no processo. Recupera mensagem de erro.
		aReturn[2] := oMRPApi:getMessage()
	EndIf

	//Libera o objeto MRPApi da memória.
	oMRPApi:Destroy()
	FreeObj(oMRPApi)
	oMRPApi := Nil
Return aReturn

/*/{Protheus.doc} StructWC
Estrutura as cláusulas where a partir dos filtros recebidos na chamada do método GET VIEW
@type  Function
@author parffit.silva
@since 16/03/2021
@version P12.1.27
@param aQuery   , Array    , Array com os dados que devem ser filtrados.
                             Exemplo: Array[1]
                                      Array[1][1] = "PRODUCT"
                                      Array[1][2] = "PRODUTO001"
                                      Array[2]
                                      Array[2][1] = "PRODUCTIONORDER"
                                      Array[2][2] = "00000101001"
@return aReturn , Array    , Array com as informações da requisição.
                             aReturn[1] - Character - Where clause do registro mestre dos empenhos.
                             aReturn[2] - Character - Having clause do registro mestre dos empenhos.
						     aReturn[3] - Character - Where clause do registro detalhe dos empenhos.
						     aReturn[4] - Character - Where clause do registro detalhe da localização/endereço dos empenhos.
/*/
Static Function StructWC(aQuery)
	Local aReturn    := {"","","",""}
	Local cWhereCl   := ""
	Local cWCAlHead  := ""
	Local cHCAlHead  := ""
	Local cWCAlDet   := ""
	Local cWCLoDet   := ""
	Local nIndexQ    := 0
	Local nIndexWC   := 0
	Local _aWCFields := MapFields(2)

	For nIndexQ := 1 To Len(aQuery)
		If aQuery[nIndexQ][2] == Nil
			Loop
		EndIf

		For nIndexWC := 1 To Len(_aWCFields)
			If Upper(aQuery[nIndexQ][1]) == Upper(_aWCFields[nIndexWC][1])
				If _aWCFields[nIndexWC][4] == 'AH' .And. aQuery[nIndexQ][1] == 'QUANTITY'
					cHCAlHead += " HAVING " + AllTrim(_aWCFields[nIndexWC][2]) + " = " + aQuery[nIndexQ][2]
				Else
					cWhereCl := " AND " + AllTrim(_aWCFields[nIndexWC][2]) + " = "

					If _aWCFields[nIndexWC][3] == 'D'
						cWhereCl += "'" + strToDate(aQuery[nIndexQ][2]) + "'"
					ElseIf _aWCFields[nIndexWC][3] == 'C'
						cWhereCl += "'" + IIf(Empty(aQuery[nIndexQ][2]), " ", aQuery[nIndexQ][2]) + "'"
					ElseIf _aWCFields[nIndexWC][3] == 'N'
						cWhereCl += cValToChar(aQuery[nIndexQ][2])
					Else
						cWhereCl += aQuery[nIndexQ][2]
					EndIf

					If _aWCFields[nIndexWC][4] == 'AH'
						cWCAlHead += cWhereCl
					ElseIf _aWCFields[nIndexWC][4] == 'AD'
						cWCAlDet  += cWhereCl
					ElseIf _aWCFields[nIndexWC][4] == 'LD'
						cWCLoDet  += cWhereCl
					EndIf
				EndIf

				Exit
			EndIf
		Next nIndexWC
	Next nIndexQ

	aReturn[1] := AllTrim(cWCAlHead)
	aReturn[2] := AllTrim(cHCAlHead)
	aReturn[3] := AllTrim(cWCAlDet)
	aReturn[4] := AllTrim(cWCLoDet)

	aSize(_aWCFields, 0)

Return aReturn

/*/{Protheus.doc} EmpGetList
Busca a lista de empenhos para o APP Minha Produção
@type  Function
@author parffit.silva
@since 16/03/2021
@version P12.1.27
@param aQuery   , Array    , Array com os dados que devem ser filtrados.
                             Exemplo: Array[1]
                                      Array[1][1] = "PRODUCT"
                                      Array[1][2] = "PRODUTO001"
                                      Array[2]
                                      Array[2][1] = "PRODUCTIONORDER"
                                      Array[2][2] = "00000101001"
@param nPage    , Numeric  , Página dos dados. Se não enviado, considera página 1.
@param nPageSize, Numeric  , Quantidade de registros retornados por página. Se não enviado, considera 20 registros por página.
@param cOrder   , Character, Ordenação desejada do retorno.
/*/
Static Function EmpGetList(aQuery, nPage, nPageSize, cOrder)
	Local aResult 	 := {.T.,"",200}
	Local aWhereCl   := {"","","",""}
	Local cAliasSD4  := ""
	Local cAliasAlD  := ""
	Local cAliasLoD  := ""
	Local cQuery     := ""
	Local cQuerySDC  := ""
	Local nPos       := 0
	Local nPosAlD    := 0
	Local nPosLoD    := 0
	Local nStart     := 1
	Local oDados     := JsonObject():New()

	DEFAULT nPage     := 1
	DEFAULT nPageSize := 20
	DEFAULT cOrder    := 'branchId, product, productionOrder, lot'

	aWhereCl := StructWC(aQuery)

	cQuery := "SELECT SD4.D4_FILIAL branchId, "
	cQuery +=       " SD4.D4_OP productionOrder, "
	cQuery +=       " SD4.D4_COD product, "
	cQuery +=       " SB1.B1_DESC productDescription, "
	cQuery +=       " SD4.D4_LOCAL warehouse, "
	cQuery +=       " SD4.D4_LOTECTL lot, "
	cQuery +=       " SUM(SD4.D4_QUANT) quantity "
	cQuery +=  " FROM " + RetSqlName("SD4") + " SD4 "             // Empenhos
	cQuery +=      ", " + RetSqlName("SB1") + " SB1 "             // Produto
	cQuery += " WHERE SD4.D4_FILIAL = '" + xFilial("SD4") + "' "
	cQuery +=   " AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
	cQuery +=   " AND SB1.B1_COD = SD4.D4_COD "
	cQuery +=   " AND SB1.D_E_L_E_T_ = ' ' "
	cQuery +=   " AND SD4.D_E_L_E_T_ = ' ' "
	cQuery += aWhereCl[1] //Where Clause composta dos parâmetros enviados na requisição JSON - Campos Header SD4
	cQuery += aWhereCl[3] //Where Clause composta dos parâmetros enviados na requisição JSON - Campos Detail SD4

	If aWhereCl[4] <> ""
		cQuerySDC := " AND EXISTS ("
		cQuerySDC += "SELECT 1 "
		cQuerySDC +=  " FROM " + RetSqlName("SDC") + " SDC "             // Empenhos por Localização/Endereços
		cQuerySDC += " WHERE SDC.DC_FILIAL = '" + xFilial("SDC") + "' "
		cQuerySDC +=   " AND SDC.DC_PRODUTO = SD4.D4_COD "
		cQuerySDC +=   " AND SDC.DC_LOCAL = SD4.D4_LOCAL "
		cQuerySDC +=   " AND SDC.DC_OP = SD4.D4_OP "
		cQuerySDC +=   " AND SDC.DC_TRT = SD4.D4_TRT "
		cQuerySDC +=   " AND SDC.DC_LOTECTL = SD4.D4_LOTECTL "
		cQuerySDC +=   " AND SDC.DC_NUMLOTE = SD4.D4_NUMLOTE "
		cQuerySDC +=   " AND SDC.D_E_L_E_T_ = ' ' "
		cQuerySDC += aWhereCl[4] //Where Clause composta dos parâmetros enviados na requisição JSON - Campos Detail SDC
		cQuerySDC += ")"

		cQuery += cQuerySDC
	EndIf

	cQuery += " GROUP BY SD4.D4_FILIAL, SD4.D4_OP, SD4.D4_COD, SB1.B1_DESC, SD4.D4_LOCAL, SD4.D4_LOTECTL "
	cQuery += aWhereCl[2] //Having Clause composta dos parâmetros enviados na requisição JSON
	cQuery += " ORDER BY " + cOrder

	cAliasSD4 := GetNextAlias()
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD4,.F.,.F.)

	// nStart -> primeiro registro da pagina
	If nPage > 1
		nStart := ((nPage - 1) * nPageSize)
		If nStart > 0
			(cAliasSD4)->(DbSkip(nStart))
		EndIf
	EndIf

	//Ajusta o tipo dos campos na query.
	TcSetField(cAliasSD4, 'quantity', 'N', _aTamQtd[1], _aTamQtd[2])

	oDados["items"] := {}

	nPos := 0
	While (cAliasSD4)->(!Eof())
		aAdd(oDados["items"], JsonObject():New())
		nPos++

		oDados["items"][nPos]['branchId'          ] := (cAliasSD4)->branchId
		oDados["items"][nPos]['productionOrder'   ] := trim((cAliasSD4)->productionOrder)
		oDados["items"][nPos]['product'           ] := trim((cAliasSD4)->product)
		oDados["items"][nPos]['productDescription'] := trim((cAliasSD4)->productDescription)
		oDados["items"][nPos]['warehouse'         ] := trim((cAliasSD4)->warehouse)
		oDados["items"][nPos]['lot'               ] := trim((cAliasSD4)->lot)
		oDados["items"][nPos]['quantity'          ] := (cAliasSD4)->quantity

		//AllocationDetails
		cQuery := "SELECT SD4.D4_DATA, "
		cQuery +=       " SD4.D4_TRT, "
		cQuery +=       " SD4.D4_NUMLOTE, "
		cQuery +=       " SD4.D4_DTVALID, "
		cQuery +=       " SD4.D4_QUANT, "
		cQuery +=       " SD4.D4_OPORIG, "
		cQuery +=       " SD4.D4_OPERAC, "
		cQuery +=       " SD4.D4_EMPROC, "
		cQuery +=       " SD4.D4_POTENCI, "
		cQuery +=       " SD4.D4_PRDORG, "
		cQuery +=       " SD4.D4_PRODUTO, "
		cQuery +=       " SD4.D4_QTDEORI, "
		cQuery +=       " SD4.D4_QTSEGUM, "
		cQuery +=       " SD4.D4_SEQ, "
		cQuery +=       " SD4.R_E_C_N_O_ "
		cQuery +=  " FROM " + RetSqlName("SD4") + " SD4 "             // Empenhos
		cQuery += " WHERE SD4.D4_FILIAL = '" + (cAliasSD4)->branchId + "' "
		cQuery +=   " AND SD4.D4_COD = '" + (cAliasSD4)->product + "' "
		cQuery +=   " AND SD4.D4_OP = '" + (cAliasSD4)->productionOrder + "' "
		cQuery +=   " AND SD4.D4_LOTECTL = '" + (cAliasSD4)->lot + "' "
		cQuery +=   " AND SD4.D4_LOCAL = '" + (cAliasSD4)->warehouse + "' "
		cQuery +=   " AND SD4.D_E_L_E_T_ = ' ' "
		cQuery += aWhereCl[3] //Where Clause composta dos parâmetros enviados na requisição JSON - Campos Detail SD4

		If aWhereCl[4] <> ""
			cQuery += cQuerySDC
		EndIf

		cAliasAlD := GetNextAlias()
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasAlD,.F.,.F.)

		//Ajusta o tipo dos campos na query.
		TcSetField(cAliasAlD, 'D4_QUANT'  , 'N', _aTamQtd[1], _aTamQtd[2])
		TcSetField(cAliasAlD, 'D4_EMPROC' , 'N', _aTamQtd[1], _aTamQtd[2])
		TcSetField(cAliasAlD, 'D4_QTDEORI', 'N', _aTamQtd[1], _aTamQtd[2])
		TcSetField(cAliasAlD, 'D4_QTSEGUM', 'N', _aTamQtd[1], _aTamQtd[2])

		oDados["items"][nPos]['allocationDetails'] := {}

		nPosAlD := 0
		While (cAliasAlD)->(!Eof())
			aAdd(oDados["items"][nPos]['allocationDetails'], JsonObject():New())
			nPosAlD++

			oDados["items"][nPos]['allocationDetails'][nPosAlD]['allocationDate'       ] := dateToStr((cAliasAlD)->D4_DATA)
			oDados["items"][nPos]['allocationDetails'][nPosAlD]['sequence'             ] := trim((cAliasAlD)->D4_TRT)
			oDados["items"][nPos]['allocationDetails'][nPosAlD]['subLot'               ] := trim((cAliasAlD)->D4_NUMLOTE)
			oDados["items"][nPos]['allocationDetails'][nPosAlD]['expirationDate'       ] := dateToStr((cAliasAlD)->D4_DTVALID)
			oDados["items"][nPos]['allocationDetails'][nPosAlD]['allocationQuantity'   ] := (cAliasAlD)->D4_QUANT
			oDados["items"][nPos]['allocationDetails'][nPosAlD]['originProductionOrder'] := trim((cAliasAlD)->D4_OPORIG)
			oDados["items"][nPos]['allocationDetails'][nPosAlD]['operation'            ] := trim((cAliasAlD)->D4_OPERAC)
			oDados["items"][nPos]['allocationDetails'][nPosAlD]['quantityInProcess'    ] := (cAliasAlD)->D4_EMPROC
			oDados["items"][nPos]['allocationDetails'][nPosAlD]['potency'              ] := (cAliasAlD)->D4_POTENCI
			oDados["items"][nPos]['allocationDetails'][nPosAlD]['originProduct'        ] := trim((cAliasAlD)->D4_PRDORG)
			oDados["items"][nPos]['allocationDetails'][nPosAlD]['fatherProduct'        ] := trim((cAliasAlD)->D4_PRODUTO)
			oDados["items"][nPos]['allocationDetails'][nPosAlD]['originQuantity'       ] := (cAliasAlD)->D4_QTDEORI
			oDados["items"][nPos]['allocationDetails'][nPosAlD]['balanceQuantity'      ] := (cAliasAlD)->D4_QUANT
			oDados["items"][nPos]['allocationDetails'][nPosAlD]['secondUnitQuantity'   ] := (cAliasAlD)->D4_QTSEGUM
			oDados["items"][nPos]['allocationDetails'][nPosAlD]['sequential'           ] := trim((cAliasAlD)->D4_SEQ)
			oDados["items"][nPos]['allocationDetails'][nPosAlD]['registerNumber'       ] := (cAliasAlD)->R_E_C_N_O_

			//LocalizationDetails
			cQuery := "SELECT SDC.DC_LOCALIZ,"
			cQuery +=       " SDC.DC_NUMSERI,"
			cQuery +=       " SDC.DC_QUANT,"
			cQuery +=       " SDC.DC_QTDORIG,"
			cQuery +=       " SDC.R_E_C_N_O_"
			cQuery +=  " FROM " + RetSqlName("SDC") + " SDC "             // Empenhos por Localização/Endereços
			cQuery += " WHERE SDC.DC_FILIAL = '" + xFilial("SDC") + "' "
			cQuery +=   " AND SDC.DC_PRODUTO = '" + (cAliasSD4)->product + "' "
			cQuery +=   " AND SDC.DC_LOCAL = '" + (cAliasSD4)->warehouse + "' "
			cQuery +=   " AND SDC.DC_OP = '" + (cAliasSD4)->productionOrder + "' "
			cQuery +=   " AND SDC.DC_TRT = '" + (cAliasAlD)->D4_TRT + "' "
			cQuery +=   " AND SDC.DC_LOTECTL = '" + (cAliasSD4)->lot + "' "
			cQuery +=   " AND SDC.DC_NUMLOTE = '" + (cAliasAlD)->D4_NUMLOTE + "' "
			cQuery +=   " AND SDC.D_E_L_E_T_ = ' ' "
			cQuery += aWhereCl[4] //Where Clause composta dos parâmetros enviados na requisição JSON - Campos Detail SDC

			cAliasLoD := GetNextAlias()
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasLoD,.F.,.F.)

			//Ajusta o tipo dos campos na query.
			TcSetField(cAliasLoD, 'DC_QUANT'  , 'N', _aTamQtd[1], _aTamQtd[2])
			TcSetField(cAliasLoD, 'DC_QTDORIG', 'N', _aTamQtd[1], _aTamQtd[2])

			oDados["items"][nPos]['allocationDetails'][nPosAlD]['localizationDetails'] := {}

			nPosLoD := 0
			While (cAliasLoD)->(!Eof())
				aAdd(oDados["items"][nPos]['allocationDetails'][nPosAlD]['localizationDetails'], JsonObject():New())
				nPosLoD++

				oDados["items"][nPos]['allocationDetails'][nPosAlD]['localizationDetails'][nPosLoD]['localization'              ] := trim((cAliasLoD)->DC_LOCALIZ)
				oDados["items"][nPos]['allocationDetails'][nPosAlD]['localizationDetails'][nPosLoD]['serialNumber'              ] := trim((cAliasLoD)->DC_NUMSERI)
				oDados["items"][nPos]['allocationDetails'][nPosAlD]['localizationDetails'][nPosLoD]['localizationQuantity'      ] := (cAliasLoD)->DC_QUANT
				oDados["items"][nPos]['allocationDetails'][nPosAlD]['localizationDetails'][nPosLoD]['localizationOriginQuantity'] := (cAliasLoD)->DC_QTDORIG
				oDados["items"][nPos]['allocationDetails'][nPosAlD]['localizationDetails'][nPosLoD]['localizationRegisterNumber'] := (cAliasLoD)->R_E_C_N_O_

				//Próximo registro Detalhes do Empenho
				(cAliasLoD)->(dbSkip())
			End

			(cAliasLoD)->(dbCloseArea())

			//Próximo registro Detalhes do Empenho
			(cAliasAlD)->(dbSkip())
		End

		(cAliasAlD)->(dbCloseArea())

		//Próximo registro Mestre
		(cAliasSD4)->(dbSkip())

		//Verifica tamanho da página
		If nPos >= nPageSize
			Exit
		EndIf
	End

	oDados["hasNext"] := (cAliasSD4)->(!Eof())

	(cAliasSD4)->(dbCloseArea())

	aResult[2] := EncodeUTF8(oDados:toJson())

	If nPos > 0
		aResult[1] := .T.
		aResult[3] := 200
	Else
		aResult[1] := .F.
		aResult[2] := STR0005 //"Nenhum empenho encontrado"
		aResult[3] := 400
	EndIf

	aSize(oDados["items"],0)
	FreeObj(oDados)

	aSize(aWhereCl, 0)

Return aResult

/*/{Protheus.doc} defMRPApi
Faz a instância da classe MRPAPI e seta as propriedades básicas.

@type  Static Function
@author douglas.heydt
@since 29/10/2020
@version P12.1.27
@param cMethod  , Character, Método que será executado (GET/POST/DELETE)
@param cOrder   , Character, Ordenação para o GET
@return oMRPApi , Object   , Referência da classe MRPApi com as definições já executadas.
/*/
Static Function defMRPApi(cMethod, cOrder)
	Local oMRPApi := MRPApi():New(cMethod)

	//Seta o APIMAP do item principal (cabeçalho)
	oMRPApi:setAPIMap("fields", _aMapFields , "SD4", .F., cOrder)

	//Seta os campos utilizados para busca de registros.
	oMRPApi:setKeySearch("fields",{"D4_OPORIG"})
Return oMRPApi

Function PcpEmpMap()
Return {_aMapFields}

/*/{Protheus.doc} dateToStr
Formata uma string de data no formato AAAAMMDD para o formato AAAA-MM-DD

@type Static Function
@author parffit.silva
@since 16/03/2021
@version P12.1.27
@param cData, Character, Data no formato AAAAMMDD
@return cDataNewF, Character, Data no formato AAAA-MM-DD
/*/
Static Function dateToStr(cData)
Return Left(cData, 4) + "-" + SubStr(cData, 5, 2) + "-" + Right(cData, 2)

/*/{Protheus.doc} strToDate
Formata uma string de data no formato AAAA-MM-DD para o formato AAAAMMDD

@type  Static Function
@author parffit.silva
@since 16/03/2021
@version P12.1.27
@param cData, Character, Data no formato AAAA-MM-DD
@return cData, Character, Data no formato AAAAMMDD
/*/
Static Function strToDate(cData)
Return StrTran(cData,"-","")

/*/{Protheus.doc} alteraEmp
Realiza a alteração (inclusão/alteração/exclusão) do empenho na SD4

@type Static Function
@author marcelo.neumann
@since 24/03/2021
@version P12.1.27
@param 01 oBody    , JsonObject, Objeto JSON com os dados recebidos no corpo da requisição
@param 02 nOperacao, Numeric   , Indica a operação que será realizada: 3- Inclusão
                                                                       4- Alteração
                                                                       5- Exclusão
@return aReturn, Array, Array com as informações do processamento
/*/
Static Function alteraEmp(oBody, nOperacao)
	Local aReturn := Array(2)
	Local cErro   := ""
	Local lRet    := .T.

	lRet := validaBody(oBody, @cErro, @nOperacao)

	If lRet
		cErro := gravaEmpen(oBody, nOperacao)
		If !Empty(cErro)
			lRet := .F.
		EndIf
	EndIf

	If lRet
		aReturn[1] := IIf(nOperacao == 5, 204, 201)
		aReturn[2] := ""
	Else
		aReturn[1] := 400
		aReturn[2] := cErro
	EndIf

Return aReturn

/*/{Protheus.doc} gravaEmpen
Executa o MsExecAuto do MATA381 para gravar o empenho

@type Static Function
@author marcelo.neumann
@since 24/03/2021
@version P12.1.27
@param 01 oBody    , JsonObject, Objeto JSON com os dados recebidos no corpo da requisição
@param 02 nOperacao, Numeric   , Indica a operação que será realizada: 3- Inclusão
                                                                       4- Alteração
                                                                       5- Exclusão
@return cErro, Character, Mensagem com o erro ocorrido
/*/
Static Function gravaEmpen(oBody, nOperacao)
	Local aCab     := {}
	Local aItens   := {}
	Local aLine    := {}
	Local cErro    := ""
	Local lDelete  := .F.
	Local lRastroL := .F.
	Local lRastroS := .F.
	Local nIndex   := 1
	Local nTotal   := 0
	Local xValue   := Nil

	Private lAutoErrNoFile := .T.
	Private lMsErroAuto    := .F.

	Default lAutomacao := .F. 

	//Monta o cabeçalho com o número da OP que será utilizada para inclusão dos empenhos.
	aCab := {{"D4_OP", oBody["productionOrder"], NIL}, ;
	         {"INDEX", 2                       , Nil}}

	If nOperacao == 3
		lRastroL := Rastro(oBody["product"])
		lRastroS := Rastro(oBody["product"], "S")

		aAdd(aLine, {"D4_OP"     , oBody["productionOrder"]                                        , NIL})
		aAdd(aLine, {"D4_COD"    , oBody["product"]                                                , NIL})
		aAdd(aLine, {"D4_LOCAL"  , oBody["warehouse"]                                              , NIL})
		aAdd(aLine, {"D4_QUANT"  , oBody["allocationDetails"][1]["allocationQuantity"]             , NIL})
		If !lAutomacao 
			aAdd(aLine, {"D4_DATA"   , SToD(strToDate(oBody["allocationDetails"][1]["allocationDate"])), NIL})
		EndIf
		aAdd(aLine, {"D4_QTDEORI", oBody["allocationDetails"][1]["originQuantity"]                 , NIL})
		aAdd(aLine, {"D4_TRT"    , oBody["allocationDetails"][1]["sequence"]                       , NIL})
		aAdd(aLine, {"D4_EMPROC" , oBody["allocationDetails"][1]["quantityInProcess"]              , NIL})
		aAdd(aLine, {"D4_PRDORG" , oBody["allocationDetails"][1]["originProduct"]                  , NIL})
		aAdd(aLine, {"D4_QTSEGUM", oBody["allocationDetails"][1]["secondUnitQuantity"]             , NIL})
		aAdd(aLine, {"D4_SEQ"    , oBody["allocationDetails"][1]["sequential"]                     , NIL})
		aAdd(aLine, {"D4_OPERAC" , oBody["allocationDetails"][1]["operation"]                      , NIL})

		If lRastroL
			aAdd(aLine, {"D4_LOTECTL", oBody["lot"], NIL})
		EndIf
		If lRastroS
			aAdd(aLine, {"D4_NUMLOTE", oBody["allocationDetails"][1]["subLot"], NIL})
		EndIf

		If CountSD4(oBody["branchId"], oBody["productionOrder"]) > 0
			nOperacao := 4
		EndIf
	Else
		If nOperacao == 5
			lDelete := .T.
			If CountSD4(oBody["branchId"], oBody["productionOrder"]) > 1
				nOperacao := 4
			EndIf
		EndIf

		If nOperacao == 4
			lRastroL := Rastro(SD4->D4_COD)
			lRastroS := Rastro(SD4->D4_COD, "S")

			//Adiciona as informações do empenho, conforme estão na tabela SD4.
			nTotal := SD4->(FCount())
			For nIndex := 1 To nTotal
				xValue := Nil
				If lDelete
					xValue := SD4->(FieldGet(nIndex))
				Else
					Do Case
						Case SD4->(Field(nIndex)) == "D4_COD"
							xValue := oBody["product"]
						Case SD4->(Field(nIndex)) == "D4_LOCAL"
							xValue := oBody["warehouse"]
						Case SD4->(Field(nIndex)) == "D4_LOTECTL" .And. lRastroL
							xValue := oBody["lot"]
						Case SD4->(Field(nIndex)) == "D4_QUANT"
							xValue := oBody["allocationDetails"][1]["allocationQuantity"]
						Case SD4->(Field(nIndex)) == "D4_DATA"
							xValue := SToD(strToDate(oBody["allocationDetails"][1]["allocationDate"]))
						Case SD4->(Field(nIndex)) == "D4_QTDEORI"
							xValue := oBody["allocationDetails"][1]["originQuantity"]
						Case SD4->(Field(nIndex)) == "D4_TRT"
							xValue := oBody["allocationDetails"][1]["sequence"]
						Case SD4->(Field(nIndex)) == "D4_EMPROC"
							xValue := oBody["allocationDetails"][1]["quantityInProcess"]
						Case SD4->(Field(nIndex)) == "D4_NUMLOTE" .And. lRastroS
							xValue := oBody["allocationDetails"][1]["subLot"]
						Case SD4->(Field(nIndex)) == "D4_PRDORG"
							xValue := oBody["allocationDetails"][1]["originProduct"]
						Case SD4->(Field(nIndex)) == "D4_QTSEGUM"
							xValue := oBody["allocationDetails"][1]["secondUnitQuantity"]
						Case SD4->(Field(nIndex)) == "D4_SEQ"
							xValue := oBody["allocationDetails"][1]["sequential"]
						Case SD4->(Field(nIndex)) == "D4_OPERAC"
							xValue := oBody["allocationDetails"][1]["operation"]
					EndCase

					If xValue == Nil
						xValue := SD4->(FieldGet(nIndex))
					EndIf
				EndIf

				aAdd(aLine, {SD4->(Field(nIndex)), xValue, Nil})
			Next nIndex

			//Adiciona o identificador LINPOS para identificar que o registro já existe na SD4
			aAdd(aLine,{"LINPOS", ;
						"D4_COD+D4_TRT+D4_LOTECTL+D4_NUMLOTE+D4_LOCAL+D4_OPORIG+D4_SEQ",;
						SD4->D4_COD,;
						SD4->D4_TRT,;
						SD4->D4_LOTECTL,;
						SD4->D4_NUMLOTE,;
						SD4->D4_LOCAL,;
						SD4->D4_OPORIG,;
						SD4->D4_SEQ})

			If lDelete
				//Marca como linha deletada
				aAdd(aLine, {"AUTDELETA", "S", Nil})
			EndIf
		EndIf
	EndIf

	aAdd(aItens, aLine)

	MSExecAuto({|x,y,z| mata381(x,y,z)}, aCab, aItens, nOperacao)

	If lMsErroAuto
		cErro := FormatErro()
	EndIf

	aSize(aCab  , 0)
	aSize(aItens, 0)
	aSize(aLine , 0)

Return cErro

/*/{Protheus.doc} criaMsgErr
Cria o retorno da mensagem de erro

@type Static Function
@author marcelo.neumann
@since 24/03/2021
@version P12.1.27
@param 01 cMensagem, Character, Mensagem de erro
@param 02 cDetalhe , Character, Mensagem detalhada de erro
@return Nil
/*/
Static Function criaMsgErr(cMensagem, cDetalhe)

	SetRestFault(400, EncodeUtf8(cMensagem), .T., 400, EncodeUtf8(cDetalhe))

Return Nil

/*/{Protheus.doc} validaBody
Faz a validação das informações recebidas no Body do empenho

@type Static Function
@author marcelo.neumann
@since 24/03/2021
@version P12.1.27
@param 01 oBody    , JsonObject, Objeto JSON com os dados recebidos no corpo da requisição
@param 02 cErro    , Character , Retorna por referência a mensagem de erro
@param 03 nOperacao, Numeric   , Indica a operação que será realizada: 3- Inclusão
                                                                       4- Alteração
                                                                       5- Exclusão
@return   lRet     , Logic     , Identifica se os dados estão válidos
/*/
Static Function validaBody(oBody, cErro, nOperacao)
	Local nTamFil := GetSx3Cache("D4_FILIAL", "X3_TAMANHO")
	Local nTamOP  := GetSx3Cache("D4_OP"    , "X3_TAMANHO")
	Local nTamPrd := GetSx3Cache("D4_COD"   , "X3_TAMANHO")

	oBody["branchId"       ] := PadR(oBody["branchId"       ], nTamFil)
	oBody["productionOrder"] := PadR(oBody["productionOrder"], nTamOP)
	oBody["product"        ] := PadR(oBody["product"        ], nTamPrd)

	If oBody["allocationDetails"] == Nil .Or. ValType(oBody["allocationDetails"]) != "A" .Or. Len(oBody["allocationDetails"]) < 1
		cErro := STR0013 //"Detalhes do empenho não foram recebidos."
		Return .F.
	EndIf

	If Len(oBody["allocationDetails"]) > 1
		cErro := STR0014 //"Não é permitida a manipulação de mais de um empenho em uma única execução."
		Return .F.
	EndIf

	If oBody["allocationDetails"][1]["localizationDetails"] != Nil .And. !Empty(oBody["allocationDetails"][1]["localizationDetails"])
		cErro := STR0015 //"Não é permitida a manipulação de empenhos que possuem controle de endereçamento."
		Return .F.
	EndIf

	//Se foi enviado o RECNO na post, altera para alteração
	If nOperacao == 3 .And. oBody["allocationDetails"][1]["registerNumber"] > 0
		nOperacao := 4
	EndIf

	If nOperacao <> 5
		If !Rastro(oBody["product"]) .And. !Empty(oBody["lot"])
			cErro := STR0017 //"Produto não possui controle de lote. Não informe o lote para este produto."
			Return .F.
		EndIf

		If !Rastro(oBody["product"], "S") .And. !Empty(oBody["allocationDetails"][1]["subLot"])
			cErro := STR0018 //"Produto não possui controle de sub-lote. Não informe o sub-lote para este produto."
			Return .F.
		EndIf
	EndIf

	If nOperacao <> 3 .And. !validRecno(oBody, @cErro, nOperacao)
		Return .F.
	EndIf

Return .T.

/*/{Protheus.doc} validRecno
Faz a validação das informações recebidas no Body do empenho.

@type Static Function
@author marcelo.neumann
@since 24/03/2021
@version P12.1.27
@param 01 oBody    , JsonObject, Objeto JSON com os dados recebidos no corpo da requisição
@param 02 cErro    , Character , Retorna por referência a mensagem de erro
@param 03 nOperacao, Numeric   , Indica a operação que será realizada: 3- Inclusão
                                                                       4- Alteração
                                                                       5- Exclusão
@return   lRet     , Logic     , Identifica se os dados estão válidos
/*/
Static Function validRecno(oBody, cErro, nOperacao)
	Local cAlias := ""
	Local cD4Fil := ""
	Local cD4Cod := ""
	Local cD4OP  := ""
	Local nRecno := 0

	If Empty(oBody["allocationDetails"][1]["registerNumber"])
		cErro := STR0016 //"Número de registro do empenho não foi recebido."
		Return .F.
	EndIf

	cAlias := GetNextAlias()
	nRecno := oBody["allocationDetails"][1]["registerNumber"]

	BeginSql Alias cAlias
		SELECT D4_FILIAL,
		       D4_OP,
		       D4_COD
	   FROM %Table:SD4%
	  WHERE R_E_C_N_O_ = %Exp:nRecno%
	    AND %NotDel%
	EndSql

	cD4Fil := (cAlias)->(D4_FILIAL)
	cD4OP  := (cAlias)->(D4_OP)
	cD4Cod := (cAlias)->(D4_COD)
	(cAlias)->(dbCloseArea())

	If Empty(cD4Fil+cD4OP+cD4Cod)
		cErro := STR0011 //"Número do registro do empenho não existe."
		Return .F.
	EndIf

	If nOperacao == 5
		oBody["branchId"       ] := cD4Fil
		oBody["productionOrder"] := cD4OP

	ElseIf oBody["branchId"] != cD4Fil .Or. oBody["productionOrder"] != cD4OP
		cErro := STR0012 //"Número de registro do empenho não corresponde ao empenho recebido no cabeçalho da requisição."
		Return .F.

	EndIf

	SD4->(dbGoTo(nRecno))

Return .T.

/*/{Protheus.doc} CountSD4
Indica quantos registros existem na tabela SD4 para a OP informada.

@type  Static Function
@author lucas.franca
@since 24/03/2021
@version P12.1.27
@param 01 cFil , Character, Código da filial
@param 02 cOP  , Character, Número da ordem de produção
@return nQtdSD4, Numeric  , Quantidade de registros na SD4 para a OP
/*/
Static Function CountSD4(cFil, cOP)
	Local cAlias  := GetNextAlias()
	Local nQtdSD4 := 0

	BeginSql Alias cAlias
		SELECT COUNT(*) AS TOTAL
		  FROM %Table:SD4%
		 WHERE D4_FILIAL = %Exp:cFil%
		   AND D4_OP     = %Exp:cOP%
		   AND %NotDel%
	EndSql

	nQtdSD4 := (cAlias)->(TOTAL)

	(cAlias)->(dbCloseArea())

Return nQtdSD4

/*/{Protheus.doc} FormatErro
Função para reunir e formatar as mensagens de erro para exibir no APP

@type Static Function
@author lucas.franca
@since 25/03/2021
@version P12.1.27
@return cLogErro, Character, Texto de erro
/*/
Static Function FormatErro()

	Local aErroAuto := {}
	Local cLogErro  := ""
	Local nIndex    := 0
	Local nTotal    := 0

	aErroAuto := GetAutoGRLog()
	nTotal    := Len(aErroAuto)
	For nIndex := 1 To nTotal
		//Retorna somente a mensagem de erro (Help) e o valor que está inválido, sem quebras de linha e sem tags '<>'
		cLogErro += StrTran( StrTran( StrTran( StrTran( StrTran( aErroAuto[nIndex], "/", "" ), "<", "" ), ">", "" ), CHR(10), " "), CHR(13), "") + ("|")
	Next nIndex

	aSize(aErroAuto, 0)

Return cLogErro
