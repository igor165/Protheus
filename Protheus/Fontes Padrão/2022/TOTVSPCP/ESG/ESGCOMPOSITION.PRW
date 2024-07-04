#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "ESGCOMPOSITION.CH"

/*/{Protheus.doc} esgcomposition
API da Composição do Produto (ESG TOTVS)

@type API
@author marcelo.neumann
@since 04/04/2022
@version P12.1.37
/*/
WSRESTFUL esgcomposition DESCRIPTION STR0001 FORMAT APPLICATION_JSON //"API da Composição do Produto (ESG TOTVS)"
	WSDATA branchCode          AS STRING  OPTIONAL
	WSDATA filter              AS STRING  OPTIONAL
	WSDATA initialBranchRange  AS STRING  OPTIONAL
	WSDATA finalBranchRange    AS STRING  OPTIONAL
	WSDATA initialProductRange AS STRING  OPTIONAL
	WSDATA finalProductRange   AS STRING  OPTIONAL
	WSDATA idReg               AS STRING  OPTIONAL
	WSDATA materialType        AS STRING  OPTIONAL
	WSDATA page                AS INTEGER OPTIONAL
	WSDATA pageSize            AS INTEGER OPTIONAL
	WSDATA sequence            AS STRING  OPTIONAL
	WSDATA search              AS STRING  OPTIONAL
	WSDATA showInactives       AS BOOLEAN OPTIONAL

    WSMETHOD GET productHeader;
		DESCRIPTION STR0002 ; //"Retorna a lista de Produtos com Composição"
		WSSYNTAX "api/pcp/v1/esgcomposition/productHeader" ;
		PATH "/api/pcp/v1/esgcomposition/productHeader" ;
		TTALK "v1"

	WSMETHOD POST productHeader;
		DESCRIPTION STR0003 ; //"Inclusão de Produto com Composição"
		WSSYNTAX "api/pcp/v1/esgcomposition/productHeader" ;
		PATH "/api/pcp/v1/esgcomposition/productHeader" ;
		TTALK "v1"

	WSMETHOD PUT productHeader;
		DESCRIPTION STR0004 ; //"Alteração de Produto com Composição"
		WSSYNTAX "api/pcp/v1/esgcomposition/productHeader/{idReg}" ;
		PATH "/api/pcp/v1/esgcomposition/productHeader/{idReg}" ;
		TTALK "v1"

	WSMETHOD DELETE productHeader;
		DESCRIPTION STR0005 ; //"Exclusão de Produto com Composição"
		WSSYNTAX "api/pcp/v1/esgcomposition/productHeader/{idReg}" ;
		PATH "/api/pcp/v1/esgcomposition/productHeader/{idReg}" ;
		TTALK "v1"

	WSMETHOD GET allBranches;
	    DESCRIPTION STR0006 ; //"Busca todas as filiais"
		WSSYNTAX "api/pcp/v1/esgcomposition/branches" ;
		PATH "/api/pcp/v1/esgcomposition/branches" ;
		TTALK "v1"

	WSMETHOD GET idBranch;
	    DESCRIPTION STR0007 ; //"Busca uma filial"
		WSSYNTAX "api/pcp/v1/esgcomposition/branches/{idReg}" ;
		PATH "/api/pcp/v1/esgcomposition/branches/{idReg}" ;
		TTALK "v1"

	WSMETHOD GET allProducts;
	    DESCRIPTION STR0008 ; //"Busca todos os produtos"
		WSSYNTAX "api/pcp/v1/esgcomposition/products" ;
		PATH "/api/pcp/v1/esgcomposition/products" ;
		TTALK "v1"

	WSMETHOD GET idProduct;
	    DESCRIPTION STR0009 ; //"Busca um produto"
		WSSYNTAX "api/pcp/v1/esgcomposition/products/{idReg}" ;
		PATH "/api/pcp/v1/esgcomposition/products/{idReg}" ;
		TTALK "v1"

    WSMETHOD GET composition;
		DESCRIPTION STR0010 ; //"Retorna a Composição do produto"
		WSSYNTAX "api/pcp/v1/esgcomposition/composition/{idReg}" ;
		PATH "/api/pcp/v1/esgcomposition/composition/{idReg}" ;
		TTALK "v1"

	WSMETHOD POST composition;
		DESCRIPTION STR0011 ; //"Inclusão de uma Composição do produto"
		WSSYNTAX "api/pcp/v1/esgcomposition/composition" ;
		PATH "/api/pcp/v1/esgcomposition/composition" ;
		TTALK "v1"

	WSMETHOD PUT composition;
		DESCRIPTION STR0012 ; //"Alteração de uma Composição do produto"
		WSSYNTAX "api/pcp/v1/esgcomposition/composition/{idReg}/{materialType}/{sequence}" ;
		PATH "/api/pcp/v1/esgcomposition/composition/{idReg}/{materialType}/{sequence}" ;
		TTALK "v1"

	WSMETHOD DELETE composition;
		DESCRIPTION STR0013 ; //"Exclusão de uma Composição do produto"
		WSSYNTAX "api/pcp/v1/esgcomposition/composition/{idReg}/{materialType}/{sequence}" ;
		PATH "/api/pcp/v1/esgcomposition/composition/{idReg}/{materialType}/{sequence}" ;
		TTALK "v1"

ENDWSRESTFUL

/*/{Protheus.doc} GET productHeader api/pcp/v1/esgcomposition/productHeader
Retorna a lista de produtos com composição (Mestre)

@type WSMETHOD
@author marcelo.neumann
@since 04/04/2022
@version P12.1.37
@param 01 page               , Numeric , Página de retorno
@param 02 pageSize           , Numeric , Tamanho da página
@param 03 search             , Caracter, Filtro da busca (produto ou descrição)
@param 04 initialBranchRange , Caracter, Filtro da busca por Filial (De)
@param 05 finalBranchRange   , Caracter, Filtro da busca por Filial (Até)
@param 06 initialProductRange, Caracter, Filtro da busca por Produto (De)
@param 07 finalProductRange  , Caracter, Filtro da busca por Produto (Até)
@param 08 showInactives      , Logico  , Filtro da busca por registros inativos
@return   lRet               , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET productHeader WSRECEIVE page, pageSize, search, initialBranchRange, finalBranchRange, initialProductRange, finalProductRange, showInactives WSSERVICE esgcomposition
	Local aReturn := {}
	Local lRet    := .T.

	Self:SetContentType("application/json")

	lRet := validaDic()

	If lRet
		aReturn := getProdHdr(Self:page, Self:pageSize, Self:search, Self:initialBranchRange, Self:finalBranchRange, Self:initialProductRange, Self:finalProductRange, Self:showInactives)
		lRet    := aReturn[1]
		Self:SetResponse(aReturn[2])
	EndIf

	FwFreeArray(aReturn)

Return lRet

/*/{Protheus.doc} getProdHdr
Retorna a lista de produtos com composição (Mestre)

@type Static Function
@author marcelo.neumann
@since 04/04/2022
@version P12.1.37
@param 01 nPage      , Numeric , Página de retorno
@param 02 nPageSize  , Numeric , Tamanho da página
@param 03 cSearch    , Caracter, Filtro da busca (produto ou descrição)
@param 04 cBranchFrom, Caracter, Filtro da busca por Filial (De)
@param 05 cBranchTo  , Caracter, Filtro da busca por Filial (Até)
@param 06 cProdFrom  , Caracter, Filtro da busca por Produto (De)
@param 07 cProdTo    , Caracter, Filtro da busca por Produto (Até)
@param 08 lInactive  , Logico  , Filtro da busca por Ativo
@return   aReturn  , Array   , Array com as informacoes da requisicao:
                                  aReturn[1] - Logico    - Indica se a requisicao foi processada com sucesso ou Nao
                                  aReturn[2] - Character - JSON com o resultado da requisicao, ou com a mensagem de erro
                                  aReturn[3] - Numeric   - Codigo de erro retornado pelo rest
/*/
Static Function getProdHdr(nPage, nPageSize, cSearch, cBranchFro, cBranchTo, cProdFrom, cProdTo, lInactive)
    Local aReturn     := {}
    Local cAliasQry   := GetNextAlias()
    Local cQuery      := ""
	Local nPos        := 0
	Local nStart      := 0
	Local oJson       := JsonObject():New()
	Default nPage     := 1
	Default nPageSize := 20
	Default lInactive := .F.

    cQuery := "SELECT DISTINCT HZ1.HZ1_PRODUT AS productCode,"
    cQuery +=                " HZ1.HZ1_FILCOM AS branchCode,"
    cQuery +=                " HZ1.HZ1_STATUS AS status,"
    cQuery +=                " SB1.B1_DESC    AS productDescription,"
    cQuery +=                " SB1.B1_UM      AS unitMeasure"
    cQuery +=  " FROM " + RetSqlName("HZ1") + " HZ1"
    cQuery +=  " LEFT JOIN " + RetSqlName("SB1") + " SB1"
	cQuery +=    " ON SB1.B1_FILIAL  = '" + xFilial("SB1") + "'" //TODO: Tratar quando a filial SB1 for exclusiva
	cQuery +=   " AND SB1.B1_COD     = HZ1.HZ1_PRODUT"
	cQuery +=   " AND SB1.D_E_L_E_T_ = ' '"
	cQuery += " WHERE HZ1.HZ1_FILIAL = '" + xFilial("HZ1") + "'"
	cQuery +=   " AND HZ1.D_E_L_E_T_ = ' '"

	If !Empty(cSearch)
		cSearch := UPPER(cSearch)
		cQuery  += " AND (UPPER(HZ1.HZ1_PRODUT) LIKE '%" + Upper(cSearch) + "%' OR"
		cQuery  +=      " UPPER(SB1.B1_DESC)    LIKE '%" + Upper(cSearch) + "%')"
	EndIf

	If !Empty(cBranchFro)
		cQuery += " AND HZ1.HZ1_FILCOM >= '" + cBranchFro + "'"
	EndIf

	If !Empty(cBranchTo)
		cQuery += " AND HZ1.HZ1_FILCOM <= '" + cBranchTo  + "'"
	EndIf

	If !Empty(cProdFrom)
		cQuery += " AND HZ1.HZ1_PRODUT >= '" + cProdFrom + "'"
	EndIf

	If !Empty(cProdTo)
		cQuery += " AND HZ1.HZ1_PRODUT <= '" + cProdTo  + "'"
	EndIf

	If !lInactive
		cQuery += " AND HZ1.HZ1_STATUS = 'A'"
	EndIf

	cQuery += " ORDER BY HZ1.HZ1_PRODUT, HZ1.HZ1_FILCOM"

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

	If nPage > 1
		nStart := ( (nPage-1) * nPageSize )
		If nStart > 0
			(cAliasQry)->(dbSkip(nStart))
		EndIf
	EndIf

    oJson["items"] := {}
    While (cAliasQry)->(!Eof())
        aAdd(oJson["items"], JsonObject():New())
        nPos++

       	oJson["items"][nPos]["productCode"       ] := (cAliasQry)->productCode
		oJson["items"][nPos]["branchCode"        ] := (cAliasQry)->branchCode
       	oJson["items"][nPos]["productDescription"] := Trim((cAliasQry)->productDescription)
        oJson["items"][nPos]["unitMeasure"       ] := Trim((cAliasQry)->unitMeasure)
        oJson["items"][nPos]["status"            ] := Trim((cAliasQry)->status)

		(cAliasQry)->(dbSkip())

		//Verifica paginação
		If nPos >= nPageSize
			Exit
		EndIf
    End

	oJson["hasNext"] := (cAliasQry)->(!Eof())
	(cAliasQry)->(dbCloseArea())

	If nPos > 0
		aAdd(aReturn, .T.)
		aAdd(aReturn, EncodeUTF8(oJson:toJSON()))
		aAdd(aReturn, 200)
	Else
		aAdd(aReturn, .T.)
		aAdd(aReturn, oJson:toJSON())
		aAdd(aReturn, 200)
	EndIf

	FwFreeArray(oJson["items"])
	FreeObj(oJson)

Return aReturn

/*/{Protheus.doc} POST productHeader api/pcp/v1/esgcomposition/productHeader
Inclui um Produto com Composição

@type WSMETHOD
@author marcelo.neumann
@since 04/04/2022
@version P12.1.37
@return lRet, Logico, Informa se o processo foi executado com sucesso.
/*/
WSMETHOD POST productHeader WSSERVICE esgcomposition
	Local aReturn  := {}
	Local lRet     := .T.
	Local nTamProd := 0
	Local oBody    := JsonObject():New()

	Self:SetContentType("application/json")

	lRet := validaDic() .And. validaBody(Self, oBody) .And. validaChav(oBody)

	If lRet
		nTamProd := GetSX3Cache("HZ1_PRODUT", "X3_TAMANHO")
		oBody["branchCode"] := PadR(oBody["branchCode"], FwSizeFilial())
		HZ1->(dbSetOrder(1))
		If !HZ1->(dbSeek(xFilial("HZ1") + oBody["branchCode"] + PadR(oBody["productCode"], nTamProd)))
			RecLock("HZ1", .T.)
				HZ1->HZ1_FILIAL := xFilial("HZ1")
				HZ1->HZ1_PRODUT := oBody["productCode"]
				HZ1->HZ1_FILCOM := oBody["branchCode"]
				HZ1->HZ1_STATUS := oBody["status"]
			HZ1->(MsUnLock())
		EndIf

		aReturn := getProdHdr(1, 1, /*Search*/, oBody["branchCode"], oBody["branchCode"], oBody["productCode"], oBody["productCode"], .T.)
		Self:SetResponse(EncodeUtf8(aReturn[2]))
	EndIf

	FwFreeArray(aReturn)
	FreeObj(oBody)

Return lRet

/*/{Protheus.doc} PUT productHeader api/pcp/v1/esgcomposition/productHeader
Altera um Produto com Composição

@type WSMETHOD
@author marcelo.neumann
@since 04/04/2022
@version P12.1.37
@param idReg, Caracter, Chave do registro
@return lRet, Logico, Informa se o processo foi executado com sucesso.
/*/
WSMETHOD PUT productHeader PATHPARAM idReg WSSERVICE esgcomposition
	Local aReturn  := {}
	Local cFilCom  := ""
	Local cProduto := ""
	Local lRet     := .T.
	Local oBody    := JsonObject():New()

	Self:SetContentType("application/json")

	lRet := validaDic() .And. extraiChav(Self:idReg, @cFilCom, @cProduto) .And. validaBody(Self, oBody)

	If lRet
		HZ1->(dbSetOrder(1))
		If HZ1->(dbSeek(xFilial("HZ1") + cFilCom + cProduto))
			RecLock("HZ1",.F.)
				HZ1->HZ1_STATUS := oBody["status"]
			HZ1->(MsUnLock())
		End

		aReturn := getProdHdr(1, 1, /*Search*/, cFilCom, cFilCom, cProduto, cProduto, .T.)
		Self:SetResponse(EncodeUtf8(aReturn[2]))
	EndIf

	FwFreeArray(aReturn)
	FreeObj(oBody)

Return lRet

/*/{Protheus.doc} DELETE productHeader api/pcp/v1/esgcomposition/productHeader/{idReg}
Exclui um Produto com Composição

@type WSMETHOD
@author marcelo.neumann
@since 04/04/2022
@version P12.1.37
@param idReg, Caracter, Chave do registro
@return lRet, Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD DELETE productHeader PATHPARAM idReg WSSERVICE esgcomposition
	Local cFilCom  := ""
	Local cProduto := ""
	Local lRet     := .T.

	Self:SetContentType("application/json")

	lRet := validaDic() .And. extraiChav(Self:idReg, @cFilCom, @cProduto)

	If lRet
		BEGIN TRANSACTION
			HZ1->(dbSetOrder(1))
			If HZ1->(dbSeek(xFilial("HZ1") + cFilCom + cProduto))
				RecLock("HZ1",.F.)
					HZ1->(dbDelete())
				HZ1->(MsUnLock())
			End

			HZ2->(dbSetOrder(1))
			If HZ2->(dbSeek(xFilial("HZ2") + cFilCom + cProduto))
				While HZ2->(!Eof())                     .And. ;
				      HZ2->HZ2_FILIAL == xFilial("HZ2") .And. ;
					  HZ2->HZ2_PRODUT == cProduto       .And. ;
					  HZ2->HZ2_FILCOM == cFilCom

					RecLock("HZ2",.F.)
						HZ2->(dbDelete())
					HZ2->(MsUnLock())
					HZ2->(dbSkip())
				End
			EndIf
		END TRANSACTION

		Self:SetResponse("")
	EndIf

Return lRet

/*/{Protheus.doc} extraiChav
Converte a chave enviada via PATHPARAM

@type Static Function
@author marcelo.neumann
@since 04/04/2022
@version P12.1.37
@param 01 cChave  , Caracter, Chave do registro
@param 02 cFilCom , Caracter, Filial extraída da chave
@param 03 cProduto, Caracter, Filial extraída da chave
@return   lRet    , Objeto  , Json com a chave extraída
/*/
Static Function extraiChav(cChave, cFilCom, cProduto)
	Local lRet     := .T.
	Local nTamFil  := GetSX3Cache("HZ1_FILCOM", "X3_TAMANHO")
	Local nTamProd := GetSX3Cache("HZ1_PRODUT", "X3_TAMANHO")

	If Empty(cChave)
		criaMsgErr(STR0014, STR0015) //"Erro ao interpretar os dados recebidos.", "Não foi enviada a chave do registro a ser utilizado."
		lRet := .F.
	Else
		cFilCom  := SubStr(cChave, 1, nTamFil)
		cProduto := PadR(SubStr(cChave, nTamFil+1, nTamProd), nTamProd)
	EndIf

Return lRet

/*/{Protheus.doc} validaDic
Valida se o dicionário de dados possui as tabelas necessárias para utilização desta API

@type Static Function
@author marcelo.neumann
@since 04/04/2022
@version P12.1.37
@return lRet, Logic, Indica se o dicionário de dados está correto
/*/
Static Function validaDic()
	Local lRet := FWAliasInDic("HZ1", .F.)

	If !lRet
		criaMsgErr(STR0016, STR0017) //"Dicionário de dados desatualizado.", "As tabelas necessárias para execução deste processo não existem no dicionário de dados."
	EndIf

Return lRet

/*/{Protheus.doc} validaBody
Faz a validação do Accept recebido na requisição

@type Static Function
@author marcelo.neumann
@since 04/04/2022
@version P12.1.37
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
		criaMsgErr(STR0014, STR0018) //"Erro ao interpretar os dados recebidos.", "Não foi possível ler o Body, é apenas aceito JsonObject."
		lRet := .F.
	EndIf

	If lRet
		cBody  := oRest:GetContent()
		cError := oBody:FromJson(cBody)
		If !Empty(cError)
			criaMsgErr(STR0014, cError) //"Erro ao interpretar os dados recebidos."
			lRet := .F.
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} validaChav
Faz a validação se a chave do registro foi recebida na requisição

@type Static Function
@author marcelo.neumann
@since 04/04/2022
@version P12.1.37
@param 01 oBody     , Objeto, Objeto JSON com o conteúdo do Body
@param 02 lTipoMater, Lógico, Indica se deve validar o tipo do material também
@return Lógico, Identifica se a chave foi enviada corretamente
/*/
Static Function validaChav(oBody, lTipoMater)
	Default lTipoMater := .F.

	If oBody["branchCode"] == Nil
		criaMsgErr(I18N(STR0019, {"branchCode"}),; //"Atributo '#1[ATRIBUTO]#' não informado."
		           I18N(STR0020, {"branchCode"}))  //"O atributo '#1[ATRIBUTO]#' pertence a chave do registro e precisa ser informado."
		Return .F.
	EndIf

	If oBody["productCode"] == Nil
		criaMsgErr(I18N(STR0019, {"productCode"}),; //"Atributo '#1[ATRIBUTO]#' não informado."
		           I18N(STR0020, {"productCode"}))  //"O atributo '#1[ATRIBUTO]#' pertence a chave do registro e precisa ser informado."
		Return .F.
	EndIf

	If lTipoMater .And. oBody["materialType"] == Nil
		criaMsgErr(I18N(STR0019, {"materialType"}),; //"Atributo '#1[ATRIBUTO]#' não informado."
		           I18N(STR0020, {"materialType"}))  //"O atributo '#1[ATRIBUTO]#' pertence a chave do registro e precisa ser informado."
		Return .F.
	EndIf

Return .T.

/*/{Protheus.doc} criaMsgErr
Cria o retorno da mensagem de erro

@type Static Function
@author marcelo.neumann
@since 04/04/2022
@version P12.1.37
@param cMensagem, Character, Mensagem de erro
@param cDetalhe , Character, Mensagem detalhada de erro
@return Nil
/*/
Static Function criaMsgErr(cMensagem, cDetalhe)

	SetRestFault(400, EncodeUtf8(cMensagem), .T., 400, EncodeUtf8(cDetalhe))

Return Nil

/*/{Protheus.doc} GET allBranches api/pcp/v1/esgcomposition/branches
Retorna todas as filiais

@type WSMETHOD
@author marcelo.neumann
@since 04/04/2022
@version P12.1.37
@param 01 page    , Caracter, Página de retorno
@param 02 pageSize, Caracter, Tamanho da página
@param 03 filter  , Caracter, Filtro da busca
@return   lRet    , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET allBranches WSRECEIVE page, pageSize, filter WSSERVICE esgcomposition
	Local aReturn := {}
	Local lRet    := .T.

	Self:SetContentType("application/json")

	aReturn := getAllFils(Self:page, Self:pageSize, Self:filter)
	lRet    := aReturn[1]
	If lRet
		Self:SetResponse(aReturn[2])
	Else
		SetRestFault(aReturn[3], aReturn[2])
	EndIf

	FwFreeArray(aReturn)

Return lRet

/*/{Protheus.doc} getAllFils
Busca todas as filiais do sistema

@type Static Function
@author marcelo.neumann
@since 04/04/2022
@version P12.1.37
@param 01 nPage    , Caracter, Página de retorno
@param 02 nPageSize, Caracter, Tamanho da página
@param 03 cFilter  , Caracter, Filtro da busca das filiais
@return   aReturn  , Array   , Array com as informacoes da requisicao:
                                  aReturn[1] - Logico    - Indica se a requisicao foi processada com sucesso ou Nao
                                  aReturn[2] - Character - JSON com o resultado da requisicao, ou com a mensagem de erro
                                  aReturn[3] - Numeric   - Codigo de erro retornado pelo rest
/*/
Static Function getAllFils(nPage, nPageSize, cFilter)
	Local aReturn     := {.T.,"",200}
	Local aSM0        := {}
	Local nIndFil     := 0
	Local nPosFiltra  := 0
	Local nPosRet     := 0
	Local nStart      := 0
	Local nTotFil     := 0
	Local oJson       := JsonObject():New()
	Default nPage     := 1
	Default nPageSize := 20
	Default cFilter   := " "

	aSM0    := FwLoadSM0()
	nTotFil := Len(aSM0)
	cFilter := Trim(cFilter)
	nStart  := ( (nPage-1) * nPageSize )

	oJson["items"] := {}

	For nIndFil := 1 To nTotFil
		If !Empty(cFilter)
			If !(cFilter $ aSM0[nIndFil][2]) .And. !(cFilter $ aSM0[nIndFil][7])
				Loop
			EndIf
		EndIf

		nPosFiltra++
		If nPosFiltra > nStart
			nPosRet++
			aAdd(oJson["items"], JsonObject():New())
			oJson["items"][nPosRet]["branchCode"       ] := aSM0[nIndFil][2]
			oJson["items"][nPosRet]["branchDescription"] := Trim(aSM0[nIndFil][7])
		EndIf

		If nPosRet >= nPageSize
			Exit
		EndIf
	Next nIndFil

	oJson["hasNext"] := (nPosFiltra < nTotFil)

	If nPosFiltra > 0
		aReturn[1] := .T.
		aReturn[2] := EncodeUTF8(oJson:toJson())
		aReturn[3] := 200
	Else
		aReturn[1] := .F.
    	aReturn[2] := STR0022 //"Nenhum registro encontrado"
		aReturn[3] := 400
	EndIf

    aSize(oJson["items"],0)
	FreeObj(oJson)
	FwFreeArray(aSM0)

Return aReturn

/*/{Protheus.doc} GET idBranch api/pcp/v1/esgcomposition/branches/{idReg}
Retorna informações de uma filial específica

@type WSMETHOD
@author marcelo.neumann
@since 04/04/2022
@version P12.1.37
@param idReg, Caracter, identificador do registro
@return lRet, Logico  , Informa se o processo foi executado com sucesso
/*/
WSMETHOD GET idBranch PATHPARAM idReg WSSERVICE esgcomposition
	Local aReturn := {}
	Local lRet    := .T.

	Self:SetContentType("application/json")

	aReturn := getIdBranch(Self:idReg)
	lRet    := aReturn[1]
	If lRet
		Self:SetResponse(aReturn[2])
	Else
		SetRestFault(aReturn[3], aReturn[2])
	EndIf

	FwFreeArray(aReturn)

Return lRet

/*/{Protheus.doc} getIdBranch
Retorna informações de uma filial específica

@type Static Function
@author marcelo.neumann
@since 04/04/2022
@version P12.1.37
@param idReg   , Caracter, identificador do registro
@return aReturn, Array   , Array com as informacoes da requisicao:
                                  aReturn[1] - Logico    - Indica se a requisicao foi processada com sucesso ou Nao
                                  aReturn[2] - Character - JSON com o resultado da requisicao, ou com a mensagem de erro
                                  aReturn[3] - Numeric   - Codigo de erro retornado pelo rest
/*/
Static Function getIdBranch(cIdReg)
	Local aReturn := {.T.,"",200}
	Local aSM0    := {}
	Local nIndFil := 0
	Local nPosRet := 0
	Local nTotFil := 0
	Local oJson   := JsonObject():New()

	aSM0    := FwLoadSM0()
	nTotFil := Len(aSM0)
	For nIndFil := 1 To nTotFil
		If cIdReg $ aSM0[nIndFil][2]
			nPosRet++
			oJson["branchCode"       ] := aSM0[nIndFil][2]
			oJson["branchDescription"] := Trim(aSM0[nIndFil][7])
		EndIf
	Next nIndFil

	If nPosRet > 0
		aReturn[1] := .T.
		aReturn[2] := EncodeUTF8(oJson:toJson())
		aReturn[3] := 200
	Else
		aReturn[1] := .F.
    	aReturn[2] := STR0022 //"Nenhum registro encontrado"
		aReturn[3] := 400
	EndIf

	FreeObj(oJson)
	FwFreeArray(aSM0)

Return aReturn

/*/{Protheus.doc} GET allProducts api/pcp/v1/esgcomposition/products
Retorna todas os produtos

@type WSMETHOD
@author marcelo.neumann
@since 04/04/2022
@version P12.1.37
@param 01 page      , Caracter, Página de retorno
@param 02 pageSize  , Caracter, Tamanho da página
@param 03 filter    , Caracter, Filtro da busca de produtos
@param 04 branchCode, Caracter, Filtro da filial
@return   lRet      , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET allProducts WSRECEIVE page, pageSize, filter, branchCode WSSERVICE esgcomposition
	Local aReturn := {}
	Local lRet    := .T.

	Self:SetContentType("application/json")

	aReturn := getAllProd(Self:page, Self:pageSize, Self:filter, Self:branchCode)
	lRet    := aReturn[1]
	If lRet
		Self:SetResponse(aReturn[2])
	Else
		SetRestFault(aReturn[3], aReturn[2])
	EndIf

	FwFreeArray(aReturn)

Return lRet

/*/{Protheus.doc} getAllProd
Busca todos os produtos do sistema

@type Static Function
@author marcelo.neumann
@since 04/04/2022
@version P12.1.37
@param 01 nPage    , Numerico, Página de retorno
@param 02 nPageSize, Numerico, Tamanho da página
@param 03 cFilter  , Caracter, Filtro da busca de produtos
@param 04 cBranchId, Caracter, Filial que está sendo considerada
@return   aReturn  , Array   , Array com as informacoes da requisicao:
                                  aReturn[1] - Logico    - Indica se a requisicao foi processada com sucesso ou Nao
                                  aReturn[2] - Character - JSON com o resultado da requisicao, ou com a mensagem de erro
                                  aReturn[3] - Numeric   - Codigo de erro retornado pelo rest
/*/
Static Function getAllProd(nPage, nPageSize, cFilter, cBranchId)
	Local aReturn     := {.T.,"",200}
	Local cAliasQry   := GetNextAlias()
	Local cQuery      := ""
	Local nStart      := 0
	Local nPos        := 0
	Local oJson       := JsonObject():New()
	Default nPage     := 1
	Default nPageSize := 20
	Default cFilter   := " "

	cQuery := "SELECT B1_FILIAL, B1_COD, B1_DESC, B1_UM"
	cQuery +=  " FROM " + RetSqlName("SB1")
	cQuery += " WHERE D_E_L_E_T_ = ' '"

	If !Empty(cBranchId)
		cQuery += " AND B1_FILIAL = '" + xFilial("SB1", cBranchId) + "'"
	EndIf

	cFilter := Trim(cFilter)
	If !Empty(cFilter)
		cQuery += " AND (B1_COD like '%" + cFilter + "%'"
		cQuery +=  " OR B1_DESC like '%" + cFilter + "%')"
	EndIf

	cQuery += " ORDER BY B1_FILIAL, B1_COD"

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

	If nPage > 1
		nStart := ( (nPage-1) * nPageSize )
		If nStart > 0
			(cAliasQry)->(DbSkip(nStart))
		EndIf
	EndIf

	oJson["items"] := {}

	While (cAliasQry)->(!Eof())
		aAdd(oJson["items"], JsonObject():New())
        nPos++
		oJson["items"][nPos]["branchCode"        ] := (cAliasQry)->B1_FILIAL
		oJson["items"][nPos]["productCode"       ] := (cAliasQry)->B1_COD
		oJson["items"][nPos]["productDescription"] := Trim((cAliasQry)->B1_DESC)
		oJson["items"][nPos]["unitMeasure"       ] := Trim((cAliasQry)->B1_UM)

		(cAliasQry)->(dbSkip())

		//Verifica tamanho da página
		If nPos >= nPageSize
			Exit
		EndIf
	End

	oJson["hasNext"] := (cAliasQry)->(!Eof())

	(cAliasQry)->(dbCloseArea())

	If nPos > 0
		aReturn[1] := .T.
		aReturn[2] := EncodeUTF8(oJson:toJson())
		aReturn[3] := 200
	Else
		aReturn[1] := .F.
    	aReturn[2] := STR0022 //"Nenhum registro encontrado"
		aReturn[3] := 400
	EndIf

    aSize(oJson["items"],0)
	FreeObj(oJson)

Return aReturn

/*/{Protheus.doc} GET idProduct api/pcp/v1/esgcomposition/products/{idReg}
Retorna as informações de um produto específico

@type WSMETHOD
@author marcelo.neumann
@since 04/04/2022
@version P12.1.37
@param 01 idReg     , Caracter, Identificador do registro
@param 02 branchCode, Caracter, Filial que está sendo considerada
@return   lRet      , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET idProduct PATHPARAM idReg WSRECEIVE branchCode WSSERVICE esgcomposition
	Local aReturn := {}
	Local lRet    := .T.

	Self:SetContentType("application/json")

	aReturn := getIdProd(Self:idReg, Self:branchCode)
	lRet    := aReturn[1]
	If lRet
		Self:SetResponse(aReturn[2])
	Else
		SetRestFault(aReturn[3], aReturn[2])
	EndIf

	FwFreeArray(aReturn)

Return lRet

/*/{Protheus.doc} getAllProd
Busca todos os produtos do sistema

@type Static Function
@author marcelo.neumann
@since 04/04/2022
@version P12.1.37
@param 01 cIdReg   , Caracter, Identificador do registro
@param 02 cBranchId, Caracter, Filial que está sendo considerada
@return   aReturn  , Array   , Array com as informacoes da requisicao:
                                  aReturn[1] - Logico    - Indica se a requisicao foi processada com sucesso ou Nao
                                  aReturn[2] - Character - JSON com o resultado da requisicao, ou com a mensagem de erro
                                  aReturn[3] - Numeric   - Codigo de erro retornado pelo rest
/*/
Static Function getIdProd(cIdReg, cBranchId)
	Local aReturn   := {.T.,"",200}
	Local cAliasQry := GetNextAlias()
	Local cQuery    := ""
	Local nPos      := 0
	Local oJson     := JsonObject():New()

	cQuery := "SELECT B1_FILIAL, B1_COD, B1_DESC, B1_UM"
	cQuery +=  " FROM " + RetSqlName("SB1")
	cQuery += " WHERE D_E_L_E_T_ = ' '"

	If !Empty(cBranchId)
		cQuery += " AND B1_FILIAL = '" + xFilial("SB1", cBranchId) + "'"
	EndIf
	cQuery +=   " AND B1_COD = '" + cIdReg + "'"
	cQuery += " ORDER BY B1_FILIAL, B1_COD"

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

	If (cAliasQry)->(!Eof())
		nPos++
		oJson["branchCode"        ] := (cAliasQry)->B1_FILIAL
		oJson["productCode"       ] := (cAliasQry)->B1_COD
		oJson["productDescription"] := Trim((cAliasQry)->B1_DESC)
		oJson["unitMeasure"       ] := Trim((cAliasQry)->B1_UM)
	End

	(cAliasQry)->(dbCloseArea())

	If nPos > 0
		aReturn[1] := .T.
		aReturn[2] := EncodeUTF8(oJson:toJson())
		aReturn[3] := 200
	Else
		aReturn[1] := .F.
    	aReturn[2] := STR0022 //"Nenhum registro encontrado"
		aReturn[3] := 400
	EndIf

	FreeObj(oJson)

Return aReturn

/*/{Protheus.doc} GET composition api/pcp/v1/esgcomposition/composition
Retorna a composição do produto

@type WSMETHOD
@author marcelo.neumann
@since 04/04/2022
@version P12.1.37
@param 01 idReg , Caracter, Chave do registro
@param 02 search, Caracter, Filtro da busca rápida
@return   lRet  , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD GET composition PATHPARAM idReg WSRECEIVE search WSSERVICE esgcomposition
	Local aReturn  := {}
	Local cFilCom  := ""
	Local cProduto := ""
	Local lRet     := .T.

	Self:SetContentType("application/json")

	lRet := validaDic() .And. extraiChav(Self:idReg, @cFilCom, @cProduto)

	If lRet
		aReturn := getComposi(Self:search, cFilCom, cProduto)
		lRet    := aReturn[1]
		Self:SetResponse(aReturn[2])
	EndIf

	FwFreeArray(aReturn)

Return lRet

/*/{Protheus.doc} getComposi
Retorna a lista de produtos com composição (Mestre)

@type Static Function
@author marcelo.neumann
@since 04/04/2022
@version P12.1.37
@param 01 cSearch  , Caracter, Filtro da busca (produto ou descrição)
@param 02 cFilCom  , Caracter, Filtro da busca por Filial
@param 03 cProduto , Caracter, Filtro da busca por Produto
@return   aReturn  , Array   , Array com as informacoes da requisicao:
                                  aReturn[1] - Logico    - Indica se a requisicao foi processada com sucesso ou Nao
                                  aReturn[2] - Character - JSON com o resultado da requisicao, ou com a mensagem de erro
                                  aReturn[3] - Numeric   - Codigo de erro retornado pelo rest
/*/
Static Function getComposi(cSearch, cFilCom, cProduto)
    Local aReturn   := {}
    Local cAliasQry := GetNextAlias()
    Local cQuery    := ""
	Local nPos      := 0
	Local oJsHeader := JsonObject():New()
	Local oJson     := JsonObject():New()

    cQuery := "SELECT DISTINCT HZ2.HZ2_PRTPRO AS productPart,"
    cQuery +=                " HZ2.HZ2_TIPMAT AS materialType,"
    cQuery +=                " HZ2.HZ2_PESOGR AS gramsWeight,"
    cQuery +=                " HZ2.HZ2_SEQMAT AS sequence"
    cQuery +=  " FROM " + RetSqlName("HZ2") + " HZ2"
	cQuery += " WHERE HZ2.HZ2_FILIAL = '" + xFilial("HZ2") + "'"
	cQuery +=   " AND HZ2.D_E_L_E_T_ = ' '"
	cQuery +=   " AND HZ2.HZ2_FILCOM = '" + cFilCom  + "'"
	cQuery +=   " AND HZ2.HZ2_PRODUT = '" + cProduto + "'"
	cQuery += " ORDER BY HZ2.HZ2_TIPMAT, HZ2.HZ2_SEQMAT, HZ2.HZ2_PRTPRO"

    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.F.,.F.)

	aReturn := getProdHdr(1, 1, /*Search*/, cFilCom, cFilCom, cProduto, cProduto, .T.)
	cError  := oJsHeader:FromJson(aReturn[2])
	aSize(aReturn, 0)

    oJson["productCode"       ] := oJsHeader["items"][1]["productCode"]
    oJson["branchCode"        ] := oJsHeader["items"][1]["branchCode"]
    oJson["productDescription"] := oJsHeader["items"][1]["productDescription"]
    oJson["status"            ] := oJsHeader["items"][1]["status"]
    oJson["items"             ] := {}

	If !Empty(oJson["branchCode"])
    	oJson["branchDescription"] := Trim(FWFilialName(cEmpAnt, oJson["branchCode"]))
	Else
		oJson["branchDescription"] := ""
	EndIf

    While (cAliasQry)->(!Eof())
        aAdd(oJson["items"], JsonObject():New())
        nPos++

		oJson["items"][nPos]["productCode" ] := oJsHeader["items"][1]["productCode"]
		oJson["items"][nPos]["branchCode"  ] := oJsHeader["items"][1]["branchCode"]
       	oJson["items"][nPos]["productPart" ] := Trim((cAliasQry)->productPart)
        oJson["items"][nPos]["materialType"] := (cAliasQry)->materialType
        oJson["items"][nPos]["gramsWeight" ] := (cAliasQry)->gramsWeight
        oJson["items"][nPos]["sequence"    ] := (cAliasQry)->sequence

		(cAliasQry)->(dbSkip())
    End

	oJson["hasNext"] := (cAliasQry)->(!Eof())
	(cAliasQry)->(dbCloseArea())

	If nPos > 0
		aAdd(aReturn, .T.)
		aAdd(aReturn, EncodeUTF8(oJson:toJSON()))
		aAdd(aReturn, 200)
	Else
		aAdd(aReturn, .T.)
		aAdd(aReturn, oJson:toJSON())
		aAdd(aReturn, 200)
	EndIf

	FreeObj(oJsHeader["items"][1])
	FwFreeArray(oJsHeader["items"])
	FreeObj(oJsHeader)
	FwFreeArray(oJson["items"])
	FreeObj(oJson)

Return aReturn

/*/{Protheus.doc} POST composition api/pcp/v1/esgcomposition/composition
Inclui uma Composição de um produto

@type WSMETHOD
@author marcelo.neumann
@since 04/04/2022
@version P12.1.37
@return lRet, Logico, Informa se o processo foi executado com sucesso.
/*/
WSMETHOD POST composition WSSERVICE esgcomposition
	Local aReturn   := {}
	Local cAliasQry := GetNextAlias()
	Local cFilCom   := ""
	Local cProduto  := ""
	Local cTipoMat  := ""
	Local lRet      := .T.
	Local nTamProd  := 0
	Local oBody     := JsonObject():New()

	Self:SetContentType("application/json")

	lRet := validaDic() .And. validaBody(Self, oBody) .And. validaChav(oBody, .T.)
	If lRet
		nTamProd := GetSX3Cache("HZ2_PRODUT", "X3_TAMANHO")
		cProduto := PadR(oBody["productCode"], nTamProd)
		cFilCom  := oBody["branchCode"]
		cTipoMat := oBody["materialType"]

		BeginSQL Alias cAliasQry
		  SELECT MAX(HZ2_SEQMAT) MAXSEQ
		    FROM %Table:HZ2%
		   WHERE %NotDel%
		     AND HZ2_FILIAL = %xFilial:HZ2%
		     AND HZ2_PRODUT = %Exp:cProduto%
		     AND HZ2_FILCOM = %Exp:cFilCom%
		     AND HZ2_TIPMAT = %Exp:cTipoMat%
		EndSQL

		oBody["sequence"] := Soma1((cAliasQry)->MAXSEQ)

		RecLock("HZ2", .T.)
			HZ2->HZ2_FILIAL := xFilial("HZ2")
			HZ2->HZ2_PRODUT := oBody["productCode"]
			HZ2->HZ2_FILCOM := oBody["branchCode"]
			HZ2->HZ2_PRTPRO := DecodeUtf8(oBody["productPart"])
			HZ2->HZ2_TIPMAT := oBody["materialType"]
			HZ2->HZ2_PESOGR := oBody["gramsWeight"]
			HZ2->HZ2_SEQMAT := oBody["sequence"]
		HZ2->(MsUnLock())

		aAdd(aReturn, 200)
		aAdd(aReturn, '{"code":"200"}')
		HTTPSetStatus(aReturn[1])
		Self:SetResponse(EncodeUtf8(aReturn[2]))
	EndIf

	FwFreeArray(aReturn)
	FreeObj(oBody)

Return lRet

/*/{Protheus.doc} PUT composition api/pcp/v1/esgcomposition/composition
Altera uma Composição de um produto

@type WSMETHOD
@author marcelo.neumann
@since 04/04/2022
@version P12.1.37
@param 01 idReg       , Caracter, Chave do registro
@param 02 materialType, Caracter, Tipo de material
@param 03 sequence    , Caracter, Sequência do registro
@return   lRet        , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD PUT composition PATHPARAM idReg, materialType, sequence WSSERVICE esgcomposition
	Local aReturn  := {}
	Local cFilCom  := ""
	Local cProduto := ""
	Local lRet     := .T.
	Local oBody    := JsonObject():New()

	Self:SetContentType("application/json")

	lRet := validaDic() .And. extraiChav(Self:idReg, @cFilCom, @cProduto) .And. validaBody(Self, oBody)

	If lRet
		HZ2->(dbSetOrder(1))
		If HZ2->(dbSeek(xFilial("HZ2") + cFilCom + cProduto + Self:materialType + Self:sequence))
			RecLock("HZ2",.F.)
				If !Empty(oBody["productPart"])
					HZ2->HZ2_PRTPRO := DecodeUtf8(oBody["productPart"])
				EndIf
				If !Empty(oBody["gramsWeight"])
					HZ2->HZ2_PESOGR := oBody["gramsWeight"]
				EndIf
			HZ2->(MsUnLock())
		End

		aAdd(aReturn, 200)
		aAdd(aReturn, '{"code":"200"}')
		HTTPSetStatus(aReturn[1])
		Self:SetResponse(EncodeUtf8(aReturn[2]))
	EndIf

	FwFreeArray(aReturn)
	FreeObj(oBody)

Return lRet

/*/{Protheus.doc} DELETE composition api/pcp/v1/esgcomposition/composition/{idReg}/{materialType}/{sequence}
Exclui uma Composição de um produto

@type WSMETHOD
@author marcelo.neumann
@since 04/04/2022
@version P12.1.37
@param 01 idReg       , Caracter, Chave do registro
@param 02 materialType, Caracter, Tipo de material
@param 03 sequence    , Caracter, Sequência do registro
@return   lRet        , Logico  , Informa se o processo foi executado com sucesso.
/*/
WSMETHOD DELETE composition PATHPARAM idReg, materialType, sequence WSSERVICE esgcomposition
	Local cFilCom  := ""
	Local cProduto := ""
	Local lRet     := .T.

	Self:SetContentType("application/json")

	lRet := validaDic() .And. extraiChav(Self:idReg, @cFilCom, @cProduto)

	If lRet
		HZ2->(dbSetOrder(1))
		If HZ2->(dbSeek(xFilial("HZ2") + cFilCom + cProduto + Self:materialType + Self:sequence))
			RecLock("HZ2",.F.)
				HZ2->(dbDelete())
			HZ2->(MsUnLock())
		EndIf

		Self:SetResponse("")
	EndIf

Return lRet
