#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "PRODUCTIONORDERS.CH"

Static _aMapOrd := MapFields()
Static _aTamQtd := TamSX3("C2_QUANT")

Function PrdOrds()
Return

/*/{Protheus.doc} ProductionOrders
API de integração de Ordens de Produção
@type  WSCLASS
@author parffit.silva
@since 26/10/2020
@version P12.1.27
/*/
WSRESTFUL productionorders DESCRIPTION STR0001 FORMAT APPLICATION_JSON //"Ordem de Produção"
	WSDATA Fields             AS STRING  OPTIONAL
	WSDATA Order              AS STRING  OPTIONAL
	WSDATA Page               AS INTEGER OPTIONAL
	WSDATA PageSize           AS INTEGER OPTIONAL
	WSDATA branchId           AS STRING  OPTIONAL
	WSDATA productionOrder    AS STRING  OPTIONAL
	WSDATA documentOrigin     AS STRING  OPTIONAL
	WSDATA documentId         AS STRING  OPTIONAL
	WSDATA product            AS STRING  OPTIONAL
	WSDATA productDescription AS STRING  OPTIONAL

	WSMETHOD GET ALLPORDERS;
		DESCRIPTION STR0002;//"Retorna todas as Ordens de Produção"
		WSSYNTAX "api/pcp/v1/productionorders" ;
		PATH "/api/pcp/v1/productionorders" ;
		TTALK "v1"

	WSMETHOD GET PORDER;
		DESCRIPTION STR0003;//"Retorna uma Ordem de Produção"
		WSSYNTAX "api/pcp/v1/productionorders/{branchId}/{productionOrder}" ;
		PATH "/api/pcp/v1/productionorders/{branchId}/{productionOrder}" ;
		TTALK "v1"

	WSMETHOD GET PEGGING;
		DESCRIPTION STR0006;//"Retorna uma ou mais Ordens de Produção para rastreabilidade"
		WSSYNTAX "api/pcp/v1/productionorders/pegging" ;
		PATH "/api/pcp/v1/productionorders/pegging" ;
		TTALK "v1"

	//WSMETHOD POST PORDER;
	//	DESCRIPTION STR0004;//"Inclui ou atualiza uma ou mais ordens de produção"
	//	WSSYNTAX "api/pcp/v1/productionorders" ;
	//	PATH "/api/pcp/v1/productionorders" ;
	//	TTALK "v1"

	//WSMETHOD DELETE PORDER;
	//	DESCRIPTION STR0005;//"Exclui uma ou mais ordens de produção"
	//	WSSYNTAX "api/pcp/v1/productionorders" ;
	//	PATH "/api/pcp/v1/productionorders" ;
	//	TTALK "v1"

ENDWSRESTFUL

/*/{Protheus.doc} GET ALLPORDERS /api/pcp/v1/productionorders
Retorna todas as Ordens de produção
@type  WSMETHOD
@author parffit.silva
@since 26/10/2020
@version P12.1.27
@param	Order   , caracter, Ordenação da tabela principal
@param	Page    , numérico, Número da página inicial da consulta
@param	PageSize, numérico, Número de registro por páginas
@param	Fields  , caracter, Campos que serão retornados no GET.
@return lRet    , Lógico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET ALLPORDERS QUERYPARAM Order, Page, PageSize, Fields WSSERVICE productionorders
	Local aReturn := {}
	Local lRet    := .T.

	Self:SetContentType("application/json")

	aReturn := GetAllPOrd(Self:aQueryString, Self:Order, Self:Page, Self:PageSize, Self:Fields)
    MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	aReturn := Nil
Return lRet

/*/{Protheus.doc} GET PORDER /api/pcp/v1/productionorders
Retorna um registro de Ordem de Produção
@type  WSMETHOD
@author parffit.silva
@since 26/10/2020
@version P12.1.27
@param	Fields  , caracter, Campos que serão retornados no GET.
@return lRet    , Lógico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET PORDER PATHPARAM branchId, productionOrder QUERYPARAM Fields WSSERVICE productionorders
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a função para retornar os dados.
	aReturn := GetPOrd(Self:branchId, Self:productionOrder, Self:Fields)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	aReturn := Nil
Return lRet

/*/{Protheus.doc} GET PEGGING /api/pcp/v1/productionorders/pegging
Retorna as Ordens de Produção para rastreabilidade
@type  WSMETHOD
@author parffit.silva
@since 26/10/2020
@version P12.1.27
@param	Page    , numérico, Número da página inicial da consulta
@param	PageSize, numérico, Número de registro por páginas
@return lRet    , Lógico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET PEGGING WSRECEIVE branchId, productionOrder, documentOrigin, documentId, product, productDescription QUERYPARAM Page, PageSize WSSERVICE productionorders
	Local aReturn   := {}
	Local lRet      := .T.

	Self:SetContentType("application/json")

	//Chama a função para retornar os dados.
	aReturn := GetPOrdPeg(Self:branchId, Self:productionOrder, Self:documentOrigin, Self:documentId, Self:product, Self:productDescription, Self:Page, Self:PageSize)
	MRPApi():restReturn(Self, aReturn, "GET", @lRet)
	aReturn := Nil
Return lRet

/*/{Protheus.doc} POST PORDER /api/pcp/v1/productionorders
Inclui ou atualiza uma ou mais ordens de produção
@type  WSMETHOD
@author parffit.silva
@since 26/10/2020
@version P12.1.27
@return lRet    , Lógico  , Informa se o processo foi executado com sucesso.
/*/
//WSMETHOD POST PORDER WSSERVICE productionorders
//	Local aReturn  := {}
//	Local cBody    := ""
//	Local cError   := ""
//	Local lRet     := .T.
//	Local oBody    := JsonObject():New()
//
//	Self:SetContentType("application/json")
//	cBody := Self:GetContent()
//
//	cError := oBody:FromJson(cBody)
//
//	If cError == Nil
//		aReturn := POrdPost(oBody)
//		MRPApi():restReturn(Self, aReturn, "POST", @lRet)
//	Else
//		//Ocorreu erro ao transformar os dados recebidos em objeto JSON.
//		lRet    := .F.
//		SetRestFault(400, EncodeUtf8(STR0007), .T., , cError ) //"Não foi possível interpretar os dados recebidos."
//	EndIf
//
//	FreeObj(oBody)
//Return lRet

/*/{Protheus.doc} DELETE PORDER /api/pcp/v1/productionorders
Exclui uma ou mais ordens de produção
@type  WSMETHOD
@author parffit.silva
@since 26/10/2020
@version P12.1.27
@return lRet    , Lógico  , Informa se o processo foi executado com sucesso.
/*/
//WSMETHOD DELETE PORDER WSSERVICE productionorders
//	Local aReturn  := {}
//	Local cBody    := ""
//	Local cError   := ""
//	Local lRet     := .T.
//	Local oBody    := JsonObject():New()
//
//	Self:SetContentType("application/json")
//	cBody := Self:GetContent()
//
//	cError := oBody:FromJson(cBody)
//
//	If cError == Nil
//		aReturn := POrdDel(oBody)
//		MRPApi():restReturn(Self, aReturn, "DELETE", @lRet)
//	Else
//		//Ocorreu erro ao transformar os dados recebidos em objeto JSON.
//		lRet    := .F.
//		SetRestFault(400, EncodeUtf8(STR0007), .T., , cError ) //"Não foi possível interpretar os dados recebidos."
//	EndIf
//
//	FreeObj(oBody)
//Return lRet

/*/{Protheus.doc} GetPOrdPeg
Busca as ordens de produção para rastreabilidade
@type  Function
@author parffit.silva
@since 26/10/2020
@version P12.1.27
@param   cBranch , Caracter, Código da filial
@param   cPOrder , Caracter, Número da ordem de produção
@param   cOrigin , Caracter, Tipo do documento
@param    cDocto , Caracter, Número do documento
@param  cProduto , Caracter, Código do produto
@param cProdDesc , Caracter, Descrição do produto
@param     nPage , Numeric , Página dos dados. Se não enviado, considera página 1.
@param nPageSize , Numeric , Quantidade de registros retornados por página. Se não enviado, considera 20 registros por página.
/*/
Function GetPOrdPeg(cBranch, cPOrder, cOrigin, cDocto, cProduto, cProdDesc, nPage, nPageSize)
	Local aPesqMult  := {}
	Local aResult 	 := {.T.,"",200}
	Local cAliasQry  := GetNextAlias()
	Local cBanco     := Upper(TcGetDb())
	Local cPesqMult  := ""
	Local cQuery     := ""
	Local cTxtES     := MrpDGetSTR("ES")
	Local cTxtPP     := MrpDGetSTR("PP")
	Local lPerdInf   := SuperGetMV("MV_PERDINF",.F.,.F.)
	Local lUsaSBZ    := SuperGetMV("MV_ARQPROD", .F., "SB1") == "SBZ"
	Local nDelay     := 0
	Local nIndex     := 0
	Local nPos       := 0
	Local nStart     := 1
	Local nStatus    := 0
	Local nStatusPO  := 0
	Local nTamPesq   := 0
	Local oDados     := JsonObject():New()

	DEFAULT nPage     := 1
	DEFAULT nPageSize := 20

	If Empty(cBranch)
		cBranch := cFilAnt
	Else
		cBranch := PadR(cBranch, FWSizeFilial())
	EndIf

	cQuery := "SELECT SC2.C2_FILIAL AS branchId,"
	cQuery +=       " SVR.VR_TIPO AS documentOrigin,"
	cQuery +=       " (CASE WHEN (SMH.MH_DEMDOC = '" + cTxtES + "' OR SMH.MH_DEMDOC = '" + cTxtPP + "') AND SMH.MH_TPDCSAI LIKE '%OP%' THEN ' ' ELSE SMH.MH_DEMDOC END) AS documentId,"

	If "MSSQL" $ cBanco
		cQuery +=   " SC2.C2_NUM+SC2.C2_ITEM+SC2.C2_SEQUEN+SC2.C2_ITEMGRD AS productionOrder,"
	Else
		cQuery +=   " SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQUEN||SC2.C2_ITEMGRD AS productionOrder,"
	EndIf

	cQuery +=       " SC2.C2_PRODUTO AS product,"
	cQuery +=       " SC2.C2_QUANT AS quantity,"

	If lPerdInf
		cQuery +=   " (SC2.C2_QUANT - SC2.C2_QUJE - SC2.C2_PERDA) AS balance,"
	Else
		cQuery +=   " (SC2.C2_QUANT - SC2.C2_QUJE) AS balance,"
	EndIf

	cQuery +=       " SC2.C2_DATPRI AS startDate,"
	cQuery +=       " SC2.C2_DATPRF AS endDate,"
	cQuery +=       " SB1.B1_DESC AS productDescription,"
	cQuery +=       " (CASE WHEN SMH.MH_TPDCSAI LIKE '%OP%' THEN SMH.MH_NMDCSAI ELSE SMH2.MH_NMDCSAI END) AS sourceDocument,"
	cQuery +=       " SMH.MH_QUANT AS usedQuantity,"
	cQuery +=       " SMH.MH_DATA AS usedDate,"
	cQuery +=       " SC2.C2_OPC AS optional,"
	cQuery +=       " SC2.R_E_C_N_O_ AS recno,"
	cQuery +=       " '1' AS orderSaldo,"
	cQuery +=       " SMH.MH_DEMANDA AS demand,"
	cQuery +=       " SMH.MH_DEMSEQ AS seqDemand"

	cQuery +=  " FROM " + RetSqlName("SC2") + " SC2"             // Ordem de Produção

	cQuery +=  " JOIN " + RetSqlName("SMH") + " SMH"  // Rastreabilidade das Demandas
	cQuery +=    " ON SMH.MH_FILIAL = '" + xFilial("SMH", cBranch) + "'"
	cQuery +=   " AND SMH.MH_TPDCENT = '1'"
	If "MSSQL" $ cBanco
		cQuery += " AND SMH.MH_NMDCENT = SC2.C2_NUM+SC2.C2_ITEM+SC2.C2_SEQUEN+SC2.C2_ITEMGRD"
	ElseIf cBanco == "POSTGRES"
		cQuery += " AND Trim(SMH.MH_NMDCENT) = Trim(CONCAT(SC2.C2_NUM,SC2.C2_ITEM,SC2.C2_SEQUEN,SC2.C2_ITEMGRD))"
	Else
		cQuery += " AND SMH.MH_NMDCENT = SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQUEN||SC2.C2_ITEMGRD"
	EndIf
	cQuery +=   " AND SMH.D_E_L_E_T_ = ' '"

	cQuery +=  " LEFT OUTER JOIN " + RetSqlName("SMH") + " SMH2"  // Rastreabilidade das Demandas - Ponto Pedido
	cQuery +=               " ON SMH2.MH_FILIAL = '" + xFilial("SMH", cBranch) + "'"
	cQuery +=              " AND SMH2.MH_TPDCENT = 'P'"
	cQuery +=              " AND SMH2.MH_NMDCENT = SMH.MH_NMDCSAI"
	cQuery +=              " AND SMH2.MH_TPDCSAI LIKE '%OP%'"
	cQuery +=              " AND SMH2.D_E_L_E_T_ = ' '"

	cQuery +=  " LEFT OUTER JOIN " + RetSqlName("SVR") + " SVR"  // Itens das Demandas
	cQuery +=               " ON SVR.VR_FILIAL = '" + xFilial("SVR", cBranch) + "'"
	cQuery +=              " AND SVR.VR_CODIGO = SMH.MH_DEMANDA"
	cQuery +=              " AND SVR.VR_SEQUEN = SMH.MH_DEMSEQ"
	cQuery +=              " AND SVR.D_E_L_E_T_ = ' '"

	cQuery +=      ", " + RetSqlName("SB1") + " SB1"             // Produto
	cQuery += " WHERE "
	cQuery +=       " SC2.C2_FILIAL = '" + xFilial("SC2", cBranch) + "' AND"
	cQuery +=       " SB1.B1_FILIAL = '" + xFilial("SB1", cBranch) + "' AND"

	If !Empty(cPOrder)
		aPesqMult := STRTOKARR(cPOrder,",")
		nTamPesq  := Len(aPesqMult)

		If nTamPesq > 1
			For nIndex := 1 To nTamPesq
				cPesqMult += "'"+AllTrim(aPesqMult[nIndex])+"'"
				If nIndex < nTamPesq
					cPesqMult += ","
				EndIf
			Next nIndex

			If "MSSQL" $ cBanco
				cQuery += " SC2.C2_NUM+SC2.C2_ITEM+SC2.C2_SEQUEN+SC2.C2_ITEMGRD IN (" + AllTrim(cPesqMult) + ") AND"
			Else
				cQuery += " SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQUEN||SC2.C2_ITEMGRD IN (" + AllTrim(cPesqMult) + ") AND"
			EndIf
		Else
			If "MSSQL" $ cBanco
				cQuery += " SC2.C2_NUM+SC2.C2_ITEM+SC2.C2_SEQUEN+SC2.C2_ITEMGRD = '" + AllTrim(cPOrder) + "' AND"
			Else
				cQuery += " SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQUEN||SC2.C2_ITEMGRD = '" + AllTrim(cPOrder) + "' AND"
			EndIf
		EndIf

		aSize(aPesqMult, 0)
		aPesqMult := Nil
		cPesqMult := ""
	EndIf

	If !Empty(cProduto)
		aPesqMult := STRTOKARR(cProduto,",")
		nTamPesq  := Len(aPesqMult)

		If nTamPesq > 1
			cQuery += " ("
			For nIndex := 1 To nTamPesq
				cQuery += " SC2.C2_PRODUTO LIKE '%" + RTrim(aPesqMult[nIndex]) + "%' "

				If nIndex < nTamPesq
					cQuery += " OR "
				EndIf
			Next nIndex
			cQuery += ") AND "
		Else
			cQuery += " SC2.C2_PRODUTO LIKE '%" + RTrim(cProduto) + "%' AND "
		EndIf

		aSize(aPesqMult, 0)
		aPesqMult := Nil
	EndIf

	If !Empty(cOrigin)
		aPesqMult := STRTOKARR(cOrigin,",")
		nTamPesq  := Len(aPesqMult)

		If nTamPesq > 1
			For nIndex := 1 To nTamPesq
				cPesqMult += "'"+RTrim(aPesqMult[nIndex])+"'"
				If nIndex < nTamPesq
					cPesqMult += ","
				EndIf
			Next nIndex

			cQuery += " SVR.VR_TIPO IN (" + AllTrim(cPesqMult) + ") AND"
		Else
			cQuery += " SVR.VR_TIPO = '" + RTrim(cOrigin) + "' AND"
		EndIf

		aSize(aPesqMult, 0)
		aPesqMult := Nil
		cPesqMult := ""
	EndIf

	If !Empty(cDocto)
		cQuery += " SMH.MH_DEMDOC LIKE '%" + RTrim(cDocto) + "%' AND"
	EndIf

	If !Empty(cProdDesc)
		aPesqMult := STRTOKARR(cProdDesc,",")
		nTamPesq  := Len(aPesqMult)

		If nTamPesq > 1
			cQuery += " ("
			For nIndex := 1 To nTamPesq
				cQuery += " SB1.B1_DESC LIKE '%" + RTrim(aPesqMult[nIndex]) + "%' "

				If nIndex < nTamPesq
					cQuery += " OR "
				EndIf
			Next nIndex
			cQuery += ") AND "
		Else
			cQuery += " SB1.B1_DESC LIKE '%" + RTrim(cProdDesc) + "%' AND "
		EndIf

		aSize(aPesqMult, 0)
		aPesqMult := Nil
	EndIf

	cQuery +=       " SB1.B1_COD = SC2.C2_PRODUTO"
	cQuery +=   " AND SC2.D_E_L_E_T_ = ' '"
	cQuery +=   " AND SB1.D_E_L_E_T_ = ' '"

	// Registros de Saldo Inicial
	cQuery += " UNION"
	cQuery +=" SELECT SMH.MH_FILIAL AS branchId,"
	cQuery +=       " SVR.VR_TIPO AS documentOrigin,"
	cQuery +=       " SMH.MH_DEMDOC AS documentId,"
	cQuery +=       " 'SaldoInicial' AS productionOrder,"
	cQuery +=       " SMH.MH_PRODUTO AS product,"
	cQuery +=       " 0 AS quantity,"
	cQuery +=       " 0 AS balance,"
	cQuery +=       " ' ' AS startDate,"
	cQuery +=       " ' ' AS endDate,"
	cQuery +=       " SB1.B1_DESC AS productDescription,"
	cQuery +=       " ' ' AS sourceDocument,"
	cQuery +=       " SMH.MH_QUANT AS usedQuantity,"
	cQuery +=       " SMH.MH_DATA AS usedDate,"

	If lUsaSBZ
		cQuery +=   " COALESCE(SBZ.BZ_OPC, SB1.B1_OPC, ' ') AS optional,"
	Else
		cQuery +=   " COALESCE(SB1.B1_OPC, ' ') AS optional,"
	EndIf

	cQuery +=       " 0 AS recno,"
	cQuery +=       " '0' AS orderSaldo,"
	cQuery +=       " SMH.MH_DEMANDA AS demand,"
	cQuery +=       " SMH.MH_DEMSEQ AS seqDemand"

	cQuery +=  " FROM " + RetSqlName("SMH") + " SMH"             // Rastreabilidade das Demandas

	cQuery +=  " LEFT OUTER JOIN " + RetSqlName("SVR") + " SVR"  // Itens das Demandas
	cQuery +=    " ON SVR.VR_FILIAL = '" + xFilial("SVR", cBranch) + "'"
	cQuery +=   " AND SVR.VR_CODIGO = SMH.MH_DEMANDA"
	cQuery +=   " AND SVR.VR_SEQUEN = SMH.MH_DEMSEQ"
	cQuery +=   " AND SVR.D_E_L_E_T_ = ' '"

	cQuery +=      ", " + RetSqlName("SB1") + " SB1"             // Produto

	If lUsaSBZ
		cQuery += " LEFT OUTER JOIN " + RetSqlName("SBZ") + " SBZ"
		cQuery +=   " ON SBZ.BZ_FILIAL = '" + xFilial("SBZ", cBranch) + "'"
		cQuery +=  " AND SBZ.BZ_COD = SB1.B1_COD"
		cQuery +=  " AND SBZ.D_E_L_E_T_ = ' '"
	EndIf

	cQuery += " WHERE"
	cQuery +=       " SMH.MH_FILIAL = '" + xFilial("SMH", cBranch) + "' AND"
	cQuery +=       " SB1.B1_FILIAL = '" + xFilial("SB1", cBranch) + "' AND"

	If !Empty(cPOrder)
		aPesqMult := STRTOKARR(cPOrder,",")
		nTamPesq  := Len(aPesqMult)

		If nTamPesq > 1
			For nIndex := 1 To nTamPesq
				cPesqMult += "'"+AllTrim(aPesqMult[nIndex])+"'"
				If nIndex < nTamPesq
					cPesqMult += ","
				EndIf
			Next nIndex

			cQuery += " SMH.MH_NMDCSAI IN (" + AllTrim(cPesqMult) + ") AND"
		Else
			cQuery += " SMH.MH_NMDCSAI = '" + AllTrim(cPOrder) + "' AND"
		EndIf

		aSize(aPesqMult, 0)
		aPesqMult := Nil
		cPesqMult := ""
	EndIf

	If !Empty(cProduto)
		aPesqMult := STRTOKARR(cProduto,",")
		nTamPesq  := Len(aPesqMult)

		If nTamPesq > 1
			cQuery += " ("
			For nIndex := 1 To nTamPesq
				cQuery += " SMH.MH_PRODUTO LIKE '%" + RTrim(aPesqMult[nIndex]) + "%' "

				If nIndex < nTamPesq
					cQuery += " OR "
				EndIf
			Next nIndex
			cQuery += ") AND "
		Else
			cQuery += " SMH.MH_PRODUTO LIKE '%" + RTrim(cProduto) + "%' AND "
		EndIf

		aSize(aPesqMult, 0)
		aPesqMult := Nil
	EndIf

	If !Empty(cOrigin)
		aPesqMult := STRTOKARR(cOrigin,",")
		nTamPesq  := Len(aPesqMult)

		If nTamPesq > 1
			For nIndex := 1 To nTamPesq
				cPesqMult += "'"+RTrim(aPesqMult[nIndex])+"'"
				If nIndex < nTamPesq
					cPesqMult += ","
				EndIf
			Next nIndex

			cQuery += " SVR.VR_TIPO IN (" + AllTrim(cPesqMult) + ") AND"
		Else
			cQuery += " SVR.VR_TIPO = '" + RTrim(cOrigin) + "' AND"
		EndIf

		aSize(aPesqMult, 0)
		aPesqMult := Nil
		cPesqMult := ""
	EndIf

	If !Empty(cDocto)
		aPesqMult := STRTOKARR(cDocto,",")
		nTamPesq  := Len(aPesqMult)

		If nTamPesq > 1
			For nIndex := 1 To nTamPesq
				cPesqMult += "'"+RTrim(aPesqMult[nIndex])+"'"
				If nIndex < nTamPesq
					cPesqMult += ","
				EndIf
			Next nIndex

			cQuery += " SMH.MH_DEMDOC IN (" + AllTrim(cPesqMult) + ") AND"
		Else
			cQuery += " SMH.MH_DEMDOC = '" + RTrim(cDocto) + "' AND"
		EndIf

		aSize(aPesqMult, 0)
		aPesqMult := Nil
		cPesqMult := ""
	EndIf

	If !Empty(cProdDesc)
		aPesqMult := STRTOKARR(cProdDesc,",")
		nTamPesq  := Len(aPesqMult)

		If nTamPesq > 1
			cQuery += " ("
			For nIndex := 1 To nTamPesq
				cQuery += "SB1.B1_DESC LIKE '%" + RTrim(aPesqMult[nIndex]) + "%' "

				If nIndex < nTamPesq
					cQuery += " OR "
				EndIf
			Next nIndex
			cQuery += ") AND "
		Else
			cQuery += " SB1.B1_DESC LIKE '%" + RTrim(cProdDesc) + "%' AND "
		EndIf

		aSize(aPesqMult, 0)
		aPesqMult := Nil
	EndIf

	cQuery +=       " SB1.B1_COD = SMH.MH_PRODUTO"
	cQuery +=   " AND SMH.MH_TPDCENT = '0'"
	cQuery +=   " AND SMH.MH_IDREG LIKE 'PA%'"
	cQuery +=   " AND SMH.D_E_L_E_T_ = ' '"
	cQuery +=   " AND SB1.D_E_L_E_T_ = ' '"

	// Registros de Demandas atendidas pelo Ponto de Pedido
	cQuery += " UNION"
	cQuery +=" SELECT SMH.MH_FILIAL AS branchId,"
	cQuery +=       " SVR.VR_TIPO AS documentOrigin,"
	cQuery +=       " SMH.MH_DEMDOC AS documentId,"
	cQuery +=       " SMH2.MH_NMDCENT AS productionOrder,"
	cQuery +=       " SMH.MH_PRODUTO AS product,"
	cQuery +=       " SMH.MH_QUANT AS quantity,"
	cQuery +=       " SMH.MH_QUANT AS balance,"
	cQuery +=       " SC2.C2_DATPRI AS startDate,"
	cQuery +=       " SC2.C2_DATPRF AS endDate,"
	cQuery +=       " SB1.B1_DESC AS productDescription,"
	cQuery +=       " ' ' AS sourceDocument,"
	cQuery +=       " SMH.MH_QUANT AS usedQuantity,"
	cQuery +=       " SMH.MH_DATA AS usedDate,"
	cQuery +=       " SC2.C2_OPC AS optional,"
	cQuery +=       " SC2.R_E_C_N_O_ AS recno,"
	cQuery +=       " '0.5' AS orderSaldo,"
	cQuery +=       " SMH.MH_DEMANDA AS demand,"
	cQuery +=       " SMH.MH_DEMSEQ AS seqDemand"

	cQuery +=  " FROM " + RetSqlName("SMH") + " SMH"             // Rastreabilidade das Demandas

	cQuery +=  " LEFT OUTER JOIN " + RetSqlName("SVR") + " SVR"  // Itens das Demandas
	cQuery +=               " ON SVR.VR_FILIAL = '" + xFilial("SVR", cBranch) + "'"
	cQuery +=              " AND SVR.VR_CODIGO = SMH.MH_DEMANDA"
	cQuery +=              " AND SVR.VR_SEQUEN = SMH.MH_DEMSEQ"
	cQuery +=              " AND SVR.D_E_L_E_T_ = ' '"

	cQuery +=  " LEFT OUTER JOIN " + RetSqlName("SMH") + " SMH2"  // Rastreabilidade das Demandas - Ponto Pedido
	cQuery +=               " ON SMH2.MH_FILIAL = '" + xFilial("SMH", cBranch) + "'"
	cQuery +=              " AND SMH2.MH_TPDCENT = '1'"
	cQuery +=              " AND SMH2.MH_NMDCSAI = SMH.MH_NMDCENT"
	cQuery +=              " AND SMH2.MH_TPDCSAI = '" + cTxtPP + "'
	cQuery +=              " AND SMH2.D_E_L_E_T_ = ' '"

	cQuery +=  " LEFT OUTER JOIN " + RetSqlName("SC2") + " SC2"  // Ordens de Produção
	cQuery +=               " ON SC2.C2_FILIAL = '" + xFilial("SC2", cBranch) + "'"
	If "MSSQL" $ cBanco
		cQuery +=           " AND SC2.C2_NUM+SC2.C2_ITEM+SC2.C2_SEQUEN+SC2.C2_ITEMGRD = SMH2.MH_NMDCENT"
	ElseIf cBanco == "POSTGRES"
		cQuery +=           " AND Trim(CONCAT(SC2.C2_NUM,SC2.C2_ITEM,SC2.C2_SEQUEN,SC2.C2_ITEMGRD)) = Trim(SMH2.MH_NMDCENT)"
	Else
		cQuery +=           " AND SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQUEN||SC2.C2_ITEMGRD = SMH2.MH_NMDCENT"
	EndIf
	cQuery +=              " AND SC2.C2_PRODUTO = SMH.MH_PRODUTO"
	cQuery +=              " AND SC2.D_E_L_E_T_ = ' '"

	cQuery +=      ", " + RetSqlName("SB1") + " SB1"             // Produto
	cQuery += " WHERE"
	cQuery +=       " SMH.MH_FILIAL = '" + xFilial("SMH", cBranch) + "' AND"
	cQuery +=       " SB1.B1_FILIAL = '" + xFilial("SB1", cBranch) + "' AND"

	If !Empty(cPOrder)
		aPesqMult := STRTOKARR(cPOrder,",")
		nTamPesq  := Len(aPesqMult)

		If nTamPesq > 1
			For nIndex := 1 To nTamPesq
				cPesqMult += "'"+AllTrim(aPesqMult[nIndex])+"'"
				If nIndex < nTamPesq
					cPesqMult += ","
				EndIf
			Next nIndex

			cQuery += " SMH2.MH_NMDCENT IN (" + AllTrim(cPesqMult) + ") AND"
		Else
			cQuery += " SMH2.MH_NMDCENT = '" + AllTrim(cPOrder) + "' AND"
		EndIf

		aSize(aPesqMult, 0)
		aPesqMult := Nil
		cPesqMult := ""
	EndIf

	If !Empty(cProduto)
		aPesqMult := STRTOKARR(cProduto,",")
		nTamPesq  := Len(aPesqMult)

		If nTamPesq > 1
			cQuery += " ("
			For nIndex := 1 To nTamPesq
				cQuery += "SMH.MH_PRODUTO LIKE '%" + RTrim(aPesqMult[nIndex]) + "%' "

				If nIndex < nTamPesq
					cQuery += " OR "
				EndIf
			Next nIndex
			cQuery += ") AND "
		Else
			cQuery += " SMH.MH_PRODUTO LIKE '%" + RTrim(cProduto) + "%' AND "
		EndIf

		aSize(aPesqMult, 0)
		aPesqMult := Nil
	EndIf

	If !Empty(cOrigin)
		aPesqMult := STRTOKARR(cOrigin,",")
		nTamPesq  := Len(aPesqMult)

		If nTamPesq > 1
			For nIndex := 1 To nTamPesq
				cPesqMult += "'"+RTrim(aPesqMult[nIndex])+"'"
				If nIndex < nTamPesq
					cPesqMult += ","
				EndIf
			Next nIndex

			cQuery += " SVR.VR_TIPO IN (" + AllTrim(cPesqMult) + ") AND"
		Else
			cQuery += " SVR.VR_TIPO = '" + RTrim(cOrigin) + "' AND"
		EndIf

		aSize(aPesqMult, 0)
		aPesqMult := Nil
		cPesqMult := ""
	EndIf

	If !Empty(cDocto)
		aPesqMult := STRTOKARR(cDocto,",")
		nTamPesq  := Len(aPesqMult)

		If nTamPesq > 1
			For nIndex := 1 To nTamPesq
				cPesqMult += "'"+RTrim(aPesqMult[nIndex])+"'"
				If nIndex < nTamPesq
					cPesqMult += ","
				EndIf
			Next nIndex

			cQuery += " SMH.MH_DEMDOC IN (" + AllTrim(cPesqMult) + ") AND"
		Else
			cQuery += " SMH.MH_DEMDOC = '" + RTrim(cDocto) + "' AND"
		EndIf

		aSize(aPesqMult, 0)
		aPesqMult := Nil
		cPesqMult := ""
	EndIf

	If !Empty(cProdDesc)
		aPesqMult := STRTOKARR(cProdDesc,",")
		nTamPesq  := Len(aPesqMult)

		If nTamPesq > 1
			cQuery += " ("
			For nIndex := 1 To nTamPesq
				cQuery += "SB1.B1_DESC LIKE '%" + RTrim(aPesqMult[nIndex]) + "%' "

				If nIndex < nTamPesq
					cQuery += " OR "
				EndIf
			Next nIndex
			cQuery += ") AND "
		Else
			cQuery += " SB1.B1_DESC LIKE '%" + RTrim(cProdDesc) + "%' AND "
		EndIf

		aSize(aPesqMult, 0)
		aPesqMult := Nil
	EndIf

	cQuery +=       " SB1.B1_COD = SMH.MH_PRODUTO"
	cQuery +=   " AND SMH.MH_TPDCENT = 'P'"
	cQuery +=   " AND SMH.MH_IDREG LIKE 'PA%'"
	cQuery +=   " AND SMH.MH_TPDCSAI = '9'"
	cQuery +=   " AND SMH.D_E_L_E_T_ = ' '"
	cQuery +=   " AND SB1.D_E_L_E_T_ = ' '"

	cQuery += " ORDER BY 1, 13, 5, 16, 4"

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

	// nStart -> primeiro registro da pagina
	If nPage > 1
		nStart := ((nPage - 1) * nPageSize)
		If nStart > 0
			(cAliasQry)->(DbSkip(nStart))
		EndIf
	EndIf

	//Ajusta o tipo dos campos na query.
	TcSetField(cAliasQry,     'quantity', 'N', _aTamQtd[1], _aTamQtd[2])
	TcSetField(cAliasQry,      'balance', 'N', _aTamQtd[1], _aTamQtd[2])
	TcSetField(cAliasQry, 'usedQuantity', 'N', _aTamQtd[1], _aTamQtd[2])

	oDados["items"] := {}

	nPos := 0
	While (cAliasQry)->(!Eof())
		If AllTrim((cAliasQry)->productionOrder) == 'SaldoInicial'
			nStatus   := 3
			nDelay    := 0
			nStatusPO := "0"
		Else
			nStatusPO := getStatusPO((cAliasQry)->recno)

			If nStatusPO == '5' .Or. nStatusPO == '6'
				nStatus := 0
				nDelay  := 0
			Else
				nDelay := DateDiffDay(DATE(), STOD((cAliasQry)->ENDDATE))
				If DATE() < STOD((cAliasQry)->ENDDATE)
					nDelay := nDelay*-1
				EndIf

				nStatus := IIF(nDelay > 0, 2, 1)
			EndIf
		EndIf

		aAdd(oDados["items"], JsonObject():New())
		nPos++

		oDados["items"][nPos]['branchId'          ] := (cAliasQry)->branchId
		oDados["items"][nPos]['documentOrigin'    ] := (cAliasQry)->documentOrigin
		oDados["items"][nPos]['documentId'        ] := (cAliasQry)->documentId
		oDados["items"][nPos]['productionOrder'   ] := IIF(AllTrim((cAliasQry)->productionOrder) == 'SaldoInicial','',(cAliasQry)->productionOrder)
		oDados["items"][nPos]['product'           ] := (cAliasQry)->product
		oDados["items"][nPos]['productDescription'] := (cAliasQry)->productDescription
		oDados["items"][nPos]['quantity'          ] := (cAliasQry)->quantity
		oDados["items"][nPos]['balance'           ] := (cAliasQry)->balance
		oDados["items"][nPos]['startDate'         ] := getDate((cAliasQry)->startDate)
		oDados["items"][nPos]['endDate'           ] := getDate((cAliasQry)->ENDDATE)
		oDados["items"][nPos]['status'            ] := nStatus
		oDados["items"][nPos]['delay'             ] := nDelay
		oDados["items"][nPos]['sourceDocument'    ] := (cAliasQry)->sourceDocument
		oDados["items"][nPos]['usedQuantity'      ] := (cAliasQry)->usedQuantity
		oDados["items"][nPos]['usedDate'          ] := getDate((cAliasQry)->usedDate)
		oDados["items"][nPos]['optional'          ] := (cAliasQry)->optional
		oDados["items"][nPos]['statusPO'          ] := nStatusPO
		oDados["items"][nPos]['demand'            ] := (cAliasQry)->demand + Iif(!Empty((cAliasQry)->seqDemand), " / " + cValToChar((cAliasQry)->seqDemand), "")

		(cAliasQry)->(dbSkip())

		//Verifica tamanho da página
		If nPos >= nPageSize
			Exit
		EndIf
	End

	oDados["hasNext"] := (cAliasQry)->(!Eof())

	(cAliasQry)->(dbCloseArea())

	aResult[2] := EncodeUTF8(oDados:toJson())

	If nPos > 0
		aResult[1] := .T.
		aResult[3] := 200
	Else
		aResult[1] := .F.
    	aResult[2] := STR0010
		aResult[3] := 204
	EndIf

    aSize(oDados["items"],0)
	FreeObj(oDados)

Return aResult

/*/{Protheus.doc} getStatusPO
Função para retornar o status da OP.
@type    Function
@author parffit.silva
@since 25/05/2021
@version P12.1.27
@param   nPORecno, number, Recno da ordem de produção na SC2
@return  cStatus -> Status da ordem
/*/
// --------------------------------------------------------------------------------------
Static Function getStatusPO(nPORecno)
	Local cAliasTemp := ""
	Local aAreaSC2    := SC2->(GetArea())
	Local cQuery     := ""
	Local cStatus    := ""
	Local dEmissao   := dDataBase
	Local nRegSD3    := 0
	Local nRegSH6    := 0

	SC2->(dbGoTo(nPORecno))

	If SC2->C2_TPOP == "P"
		cStatus := "1" //Prevista
	Else
		If SC2->C2_TPOP == "F" .And. !Empty(SC2->C2_DATRF) .And. SC2->(C2_QUJE < C2_QUANT)  /*Enc.Parcialmente*/
			cStatus := "5" //Encerrada Parcialmente
		Else
			If SC2->C2_TPOP == "F" .And. !Empty(SC2->C2_DATRF) .And. SC2->(C2_QUJE >= C2_QUANT)  /*Enc.Totalmente*/
				cStatus := "6" //Encerrada Totalmente
			Else
				cAliasTemp:= "SD3TMP"
				cQuery     := "  SELECT COUNT(*) AS RegSD3, MAX(D3_EMISSAO) AS EMISSAO "
				cQuery     += "   FROM " + RetSqlName('SD3')
				cQuery     += "   WHERE D3_FILIAL   = '" + xFilial('SD3')+ "'"
				cQuery     += "     AND D3_OP       = '" + SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD) + "'"
				cQuery     += "     AND D3_ESTORNO <> 'S' "
				cQuery     += "     AND D_E_L_E_T_  = ' '"
				cQuery    += "       GROUP BY D3_EMISSAO "
				cQuery    := ChangeQuery(cQuery)
				dbUseArea (.T., "TOPCONN", TCGENQRY(,,cQuery), cAliasTemp, .F., .T.)

				If !SD3TMP->(Eof())
					dEmissao := STOD(SD3TMP->EMISSAO)
					nRegSD3 := SD3TMP->RegSD3
				EndIf
				(cAliasTemp)->(dbCloseArea())
				cAliasTemp:= "SH6TMP"
				cQuery     := "  SELECT COUNT(*) AS RegSH6 "
				cQuery     += "   FROM " + RetSqlName('SH6')
				cQuery     += "   WHERE H6_FILIAL   = '" + xFilial('SH6')+ "'"
				cQuery     += "     AND H6_OP       = '" + SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD) + "'"
				cQuery     += "     AND D_E_L_E_T_  = ' '"
				cQuery    := ChangeQuery(cQuery)
				dbUseArea ( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasTemp, .F., .T.)

				If !SH6TMP->(Eof())
					nRegSH6 := SH6TMP->RegSH6
				EndIf
				(cAliasTemp)->(dbCloseArea())

				If SC2->C2_TPOP == "F" .And. Empty(SC2->C2_DATRF) .And. (nRegSD3 < 1 .And. nRegSH6 < 1) .And. (Max(dDataBase - SC2->C2_DATPRI,0) < If(SC2->C2_DIASOCI == 0,1,SC2->C2_DIASOCI)) //Em aberto
					cStatus := "2" //Em aberto
				Else
					If SC2->C2_TPOP == "F" .And. Empty(SC2->C2_DATRF) .And. (nRegSD3 > 0 .Or. nRegSH6 > 0) .And. (Max((dDatabase - dEmissao),0) > If(SC2->C2_DIASOCI >= 0,-1,SC2->C2_DIASOCI)) //Iniciada
						cStatus := "3" //Iniciada
					Else
						If SC2->C2_TPOP == "F" .And. Empty(SC2->C2_DATRF) .And. (Max((dDatabase - dEmissao),0) > SC2->C2_DIASOCI .Or. Max((dDatabase - SC2->C2_DATPRI),0) >= SC2->C2_DIASOCI)   //Ociosa
							cStatus := "4" //Ociosa
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	RestArea(aAreaSC2)
Return cStatus

/*/{Protheus.doc} POrdPost
Função para disparar as ações da API para o método POST (Inclusão/Alteração).
@type    Function
@author parffit.silva
@since 26/10/2020
@version P12.1.27
@oaram   oBody, JsonObject, Objeto JSON com as informações recebidas no corpo da requisição.
@return aReturn, Array, Array contendo o código HTTP que deverá ser retornado pela API, e o JSON formatado com todos os dados de retorno.
                        Array[1] -> Numeric. Código HTTP de retorno (201 - Created; 207 - MultiStatus; 400 - Bad Request; 200 - OK)
                        Array[2] -> Character. JSON no formato definido pela API para ser retornado.
/*/
//Function POrdPost(oBody)
//	Local aReturn := {201, ""}
//	Local oMRPApi := defMRPApi("POST","") //Instância da classe MRPApi para o método POST
//
//	//Adiciona os parâmetros recebidos no corpo da requisição (BODY)
//	oMRPApi:setBody(oBody)
//
//	//Executa o processamento do POST
//	oMRPApi:processar("fields")
//	//Recupera o status do processamento
//	aReturn[1] := oMRPApi:getStatus()
//	//Recupera o JSON com os dados do retorno do processo.
//	aReturn[2] := oMRPApi:getRetorno(1)
//
//	//Libera o objeto MRPApi da memória.
//	oMRPApi:Destroy()
//	FreeObj(oMRPApi)
//	oMRPApi := Nil
//Return aReturn


/*/{Protheus.doc} PORDVLD
Função responsável por validar as informações recebidas.
@type  Function
@author parffit.silva
@since 26/10/2020
@version P12.1.27
@param oMRPApi   , Object   , Referência da classe MRPApi que está processando os dados.
@param cMapCode  , Character, Código do mapeamento que será validado
@param oItem     , Object   , Referência do objeto JSON com os dados que devem ser validados.
@return lRet     , Lógico   , Identifica se os dados estão válidos.
/*/
//Function PORDVLD(oMRPApi, cMapCode, oItem)
//	Local lRet := .T.
//	Default cMapCode := "fields"
//
//	lRet := vldPOrdem(oMRPApi, oItem)
//
//Return lRet

/*/{Protheus.doc} vldPOrdem
Faz a validação do item.
@type  Static Function
@author parffit.silva
@since 26/10/2020
@version P12.1.27
@param oMRPApi, Object    , Referência da classe MRPAPI que está executando o processo.
@param oItem  , JsonObject, Objeto JSON do item que será validado
@return lRet  , Logical   , Indica se o item poderá ser processado.
/*/
//Static Function vldPOrdem(oMRPApi, oItem)
//	Local lRet      := .T.
//
//	If lRet .And. Empty(oItem["productionOrder"])
//		lRet     := .F.
//		oMRPApi:SetError(400, STR0008 + " 'productionOrder' " + STR0009) //"Atributo 'XXX' não foi informado."
//	EndIf
//
//	If oMRPApi:cMethod != "DELETE"
//		If lRet .And. Empty(oItem["itemCode"])
//			lRet     := .F.
//			oMRPApi:SetError(400, STR0008 + " 'itemCode' " + STR0009) //"Atributo 'XXX' não foi informado."
//		EndIf
//
//		If lRet .And. (Empty(oItem["quantity"]) .Or. oItem["quantity"] <= 0)
//			lRet     := .F.
//			oMRPApi:SetError(400, STR0008 + " 'quantity' " + STR0009) //"Atributo 'XXX' não foi informado."
//		EndIf
//
//		If lRet .And. Empty(oItem["startOrderDate"])
//			lRet     := .F.
//			oMRPApi:SetError(400, STR0008 + " 'startOrderDate' " + STR0009) //"Atributo 'XXX' não foi informado."
//		EndIf
//
//		If lRet .And. Empty(oItem["endOrderDate"])
//			lRet     := .F.
//			oMRPApi:SetError(400, STR0008 + " 'endOrderDate' " + STR0009) //"Atributo 'XXX' não foi informado."
//		EndIf
//	EndIf
//
//Return lRet

/*/{Protheus.doc} POrdDel
Função para disparar as ações da API para o método DELETE (Exclusão)
@type  Function
@author parffit.silva
@since 26/10/2020
@version P12.1.27
@param oBody, JsonObject, Objeto JSON com as informações recebidas no corpo da requisição.
@return aReturn, Array, Array contendo o código HTTP que deverá ser retornado pela API, e o JSON formatado com todos os dados de retorno.
                        Array[1] -> Numeric. Código HTTP de retorno (201 - Created; 207 - MultiStatus; 400 - Bad Request; 200 - OK)
                        Array[2] -> Character. JSON no formato definido pela API para ser retornado.
/*/
//Function POrdDel(oBody)
//	Local aReturn  := {201, ""}
//	Local oMRPApi  := defMRPApi("DELETE","") //Instância da classe MRPApi para o método DELETE
//
//	//Seta as funções de validação de cada mapeamento.
//	oMRPApi:setValidData("fields", "PORDVLD")
//
//	//Adiciona os parâmetros recebidos no corpo da requisição (BODY)
//	oMRPApi:setBody(oBody)
//	oMRPApi:setMapDelete("fields")
//
//	//Executa o processamento do POST
//	oMRPApi:processar("fields")
//	//Recupera o status do processamento
//	aReturn[1] := oMRPApi:getStatus()
//	//Recupera o JSON com os dados do retorno do processo.
//	aReturn[2] := oMRPApi:getRetorno(1)
//
//	//Libera o objeto MRPApi da memória.
//	oMRPApi:Destroy()
//	FreeObj(oMRPApi)
//	oMRPApi := Nil
//Return aReturn

/*/{Protheus.doc} GetAllPOrd
Função para disparar as ações da API para o método GET (Consulta) de uma lista de ordens de produção
@type  Function
@author parffit.silva
@since 26/10/2020
@version P12.1.27
@param aQuery   , Array    , Array com os dados que devem ser filtrados.
@param cOrder   , Character, Ordenação desejada do retorno.
@param nPage    , Numeric  , Página dos dados. Se não enviado, considera página 1.
@param nPageSize, Numeric  , Quantidade de registros retornados por página. Se não enviado, considera 20 registros por página.
@param cFields  , Character, Campos que devem ser retornados. Se não enviado, retorna todos os fields que possuem valor.
@return aReturn , Array    , Array com as informações da requisição.
                             aReturn[1] - Lógico    - Indica se a requisição foi processada com sucesso ou não.
						     aReturn[2] - Character - JSON com o resultado da requisição, ou com a mensagem de erro.
						     aReturn[3] - Numeric   - Código de erro identificado pelo FwApiManager.
*/
Function GetAllPOrd(aQuery, cOrder, nPage, nPageSize, cFields)
	Local aReturn := {}

	//Processa o GET
	aReturn := PORDERGet(.T., aQuery, cOrder, nPage, nPageSize, cFields)
Return aReturn

/*/{Protheus.doc} GetPOrd
Função para disparar as ações da API para o método GET (Consulta) de uma ordem de produção específica
@type  Function
@author parffit.silva
@since 26/10/2020
@version P12.1.27
@param cBranch , Caracter, Código da filial
@param cPOrder, Caracter, Número da ordem de produção
@param cFields , Caracter, Campos que devem ser retornados.
@return aReturn, Array, Array com as informações da requisição.
                        aReturn[1] - Lógico    - Indica se a requisição foi processada com sucesso ou não.
						aReturn[2] - Character - JSON com o resultado da requisição, ou com a mensagem de erro.
						aReturn[3] - Numeric   - Código de erro identificado pelo FwApiManager.
/*/
Function GetPOrd(cBranch, cPOrder, cFields)
	Local aReturn   := {}
	Local aQryParam := {}
    Local nTamNumOp := GetSx3Cache("C2_NUM","X3_TAMANHO")
    Local nTamItmOp := GetSx3Cache("C2_ITEM","X3_TAMANHO")
    Local nTamSeqOp := GetSx3Cache("C2_SEQUEN","X3_TAMANHO")
    Local nTamGrdOp := GetSx3Cache("C2_ITEMGRD","X3_TAMANHO")

    cPOrder := PadR(cPOrder,GetSx3Cache("D4_OP", "X3_TAMANHO"))

	//Adiciona os filtros de filial e produto como QueryParam.
	aAdd(aQryParam, {"BRANCHID", cBranch})
	aAdd(aQryParam, {"NUMBER"  , Left(cPOrder,nTamNumOp)})
	aAdd(aQryParam, {"ITEM"    , SubStr(cPOrder,nTamNumOP + 1,nTamItmOP)})
	aAdd(aQryParam, {"SEQUENCE", SubStr(cPOrder,nTamNumOP + nTamItmOP + 1,nTamSeqOP)})
	aAdd(aQryParam, {"GRID"    , SubStr(cPOrder,nTamNumOP + nTamItmOP + nTamSeqOP + 1,nTamGrdOP)})

	If !Empty(cFields)
		//Adiciona o FIELDS se for recebido.
		aAdd(aQryParam, {"FIELDS", cFields})
	EndIf

	//Chama a função para retornar os dados.
	aReturn := PORDERGet(.F., aQryParam, Nil, Nil, Nil, cFields)

Return aReturn

/*/{Protheus.doc} PORDERGet
Executa o processamento do método GET de acordo com os parâmetros recebidos.

@type  Static Function
@author parffit.silva
@since 26/10/2020
@version P12.1.27
@param lLista   , Logic    , Indica se deverá retornar uma lista de registros (.T.), ou apenas um registro (.F.).
@param aQuery   , Array    , Array com os dados que devem ser filtrados.
@param cOrder   , Character, Ordenação desejada do retorno.
@param nPage    , Numeric  , Página dos dados. Se não enviado, considera página 1.
@param nPageSize, Numeric  , Quantidade de registros retornados por página. Se não enviado, considera 20 registros por página.
@param cFields  , Character, Campos que devem ser retornados. Se não enviado, retorna todos os fields que possuem valor.
@return aReturn , Array    , Array com as informações da requisição.
                             aReturn[1] - Lógico    - Indica se a requisição foi processada com sucesso ou não.
						     aReturn[2] - Character - JSON com o resultado da requisição, ou com a mensagem de erro.
						     aReturn[3] - Numeric   - Código de erro identificado pelo FwApiManager.
/*/
Static Function PORDERGet(lLista, aQuery, cOrder, nPage, nPageSize, cFields)
	Local aReturn := {.T.,"",200}
	Local oMRPApi := defMRPApi("GET",cOrder) //Instância da classe MRPApi para o método GET

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

/*/{Protheus.doc} defMRPApi
Faz a instância da classe MRPAPI e seta as propriedades básicas.

@type  Static Function
@author parffit.silva
@since 26/10/2020
@version P12.1.27
@param cMethod  , Character, Método que será executado (GET/POST/DELETE)
@param cOrder   , Character, Ordenação para o GET
@return oMRPApi , Object   , Referência da classe MRPApi com as definições já executadas.
/*/
Static Function defMRPApi(cMethod, cOrder)
	Local oMRPApi := MRPApi():New(cMethod)

	//Seta o APIMAP do item principal (cabeçalho)
	oMRPApi:setAPIMap("fields", _aMapOrd , "SC2", .F., cOrder)

	//Seta os campos utilizados para busca de registros.
	oMRPApi:setKeySearch("fields", {"C2_FILIAL","C2_NUM","C2_ITEM","C2_SEQUEN","C2_ITEMGRD"})

	//If cMethod == "POST"
	//	//Seta as funções de validação de cada mapeamento.
	//	oMRPApi:setValidData("fields", "PORDVLD")
	//EndIf

Return oMRPApi

/*/{Protheus.doc} MapFields
Gera o array com o MAP dos fields da tabela SC2
@type  Static Function
@author parffit.silva
@since 26/10/2020
@version P12.1.27
@return aFields, Array, Array contendo o MAP dos fields da API e da tabela
/*/
Static Function MapFields()

	Local aFields := {}
    aFields := {;
                {"branchId"         , "C2_FILIAL" , "C", FWSizeFilial()                        , 0 },;
                {"number"           , "C2_NUM"    , "C", GetSx3Cache("C2_NUM","X3_TAMANHO")    , 0 },;
                {"item"             , "C2_ITEM"   , "C", GetSx3Cache("C2_ITEM","X3_TAMANHO")   , 0 },;
                {"sequence"         , "C2_SEQUEN" , "C", GetSx3Cache("C2_SEQUEN","X3_TAMANHO") , 0 },;
                {"grid"             , "C2_ITEMGRD", "C", GetSx3Cache("C2_ITEMGRD","X3_TAMANHO"), 0 },;
                {"productionOrder"  , "C2_OP"     , "C", GetSx3Cache("C2_OP","X3_TAMANHO")     , 0 },;
				{"itemCode"         , "C2_PRODUTO", "C", GetSx3Cache("C2_PRODUTO","X3_TAMANHO"), 0 },;
                {"quantity"         , "C2_QUANT"  , "N", GetSx3Cache("C2_QUANT","X3_TAMANHO")  , GetSx3Cache("C2_QUANT","X3_DECIMAL") },;
                {"reportQuantity"   , "C2_QUJE"   , "N", GetSx3Cache("C2_QUJE","X3_TAMANHO")   , GetSx3Cache("C2_QUJE","X3_DECIMAL") } ,;
				{"unitOfMeasureCode", "C2_UM"     , "C", GetSx3Cache("C2_UM","X3_TAMANHO")     , 0 },;
				{"requestOrderCode" , "C2_PEDIDO" , "C", GetSx3Cache("C2_PEDIDO","X3_TAMANHO") , 0 },;
				{"warehouseCode"    , "C2_LOCAL"  , "C", GetSx3Cache("C2_LOCAL","X3_TAMANHO")  , 0 },;
                {"startOrderDate"   , "C2_DATPRI" , "D", 8                                     , 0 },;
                {"endOrderDate"     , "C2_DATPRF" , "D", 8                                     , 0 },;
                {"scriptCode"       , "C2_ROTEIRO", "C", GetSx3Cache("C2_ROTEIRO","X3_TAMANHO"), 0 };
			   }
Return aFields

/*/{Protheus.doc} getDate
Formata uma string de data no formato AAAAMMDD para o formato AAAA-MM-DD

@type  Static Function
@author douglas.heydt
@since 17/12/2019
@version P12.1.27
@param cData, Character, Data no formato AAAAMMDD
@return cData, Character, Data no formato AAAA-MM-DD
/*/
Static Function getDate(dData)
	Local cData := ""
	If !Empty(dData)
		cData := Left(dData, 4) + "-" + SubStr(dData, 5, 2) + "-" + Right(dData, 2)
	EndIf
Return cData

/*/{Protheus.doc} POrdMap
Retorna um array com todos os MapFields utilizados na API

@type    Function
@author  parffit.silva
@since   26/10/2020
@version P12.1.27
@return  Array, array com os arrays de MapFields
/*/
Function POrdMap()
Return {_aMapOrd}
