#INCLUDE "JURMODREST.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Static lWSTLegal := .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} JuriRstMd
Publica��o dos modelos que devem ficar dispon�veis no REST.
Classe que herda da FwRestModel
@since 26/06/2019
/*/
//-------------------------------------------------------------------
Class JurModRest From FwRestModel
	Data qryOrder   AS STRING
	Data searchKey  AS STRING
	Data exists     AS STRING
	Data pkAssJur   AS STRING
	Data tipoAssJur AS STRING
	Data cajuri     AS STRING

	Method Activate()
	Method DeActivate()
	Method SetFilter(cFilter)
	Method Seek(cPk)
	Method setExistsQry() 

EndClass

//-------------------------------------------------------------------
/*/{Protheus.doc} Activate()
M�todo para ativar a classe
@since 26/06/2019
/*/
//-------------------------------------------------------------------
Method Activate() Class JurModRest
Local cVerbo     := self:GetHttpHeader("_METHOD_")
local cPath      := self:GetHttpHeader("_PATH_")
Local cCajuri    := ''
Local cRotina    := ''
Local lAcesso    := .T.
Local nOpc       := 2
Local nTamCod    := 0
Local cTpAssJur  := "001"
public cTipoAsJ
public c162TipoAs

	nModulo   := 76
	lWSTLegal := .T.
	lAcesso   := _Super:Activate()

	self:qryOrder  := self:GetHttpHeader("orderBy")
	self:searchKey := self:GetHttpHeader("searchKey")
	self:exists    := self:GetHttpHeader("exists")
	self:pkAssJur  := self:GetHttpHeader("PKASSJUR")

	self:tipoAssJur  := self:GetHttpHeader("tipoAssJur")
	self:cajuri      := self:GetHttpHeader("cajuri")

	If '/FWMODEL/JURA095' $ cPath
		If Empty(self:tipoAssJur)
			If Empty(self:cajuri) .And. (at("JURA095/",cPath)>0)
				cCajuri    := SUBSTR(cPath, at("JURA095/",cPath)+8)
				cCajuri    := SUBSTR(cCajuri, 0, IIf(at("/",cCajuri)>0, at("/",cCajuri)-1,len(cCajuri)))
				cCajuri    := DECODE64( cCajuri )
				cTipoAsJ   := JurGetDados("NSZ",1,cCajuri, "NSZ_TIPOAS")
				c162TipoAs := cTipoAsJ
			Else
				cCajuri    := IIF( VALTYPE(self:cajuri) <> "U", self:cajuri, "" )
				cTipoAsJ   := JurGetDados("NSZ",1,xFilial("NSZ") + cCajuri, "NSZ_TIPOAS")
				c162TipoAs := cTipoAsJ
			EndIf
		Else
			cTipoAsJ   := self:tipoAssJur
			c162TipoAs := cTipoAsJ
		EndIf
	
	ElseIf '/FWMODEL/JURA288' $ cPath
		J288ChkRel() // Filtra relat�rios com erro ou cancelados

	ElseIf '/FWMODEL/JURA106' $ cPath
		J106MetFup() // Valida uso do envio de e-mail de Fups do License server para Metrics
	EndIf

	Do case
		Case cVerbo == 'GET'
			public INCLUI   := .F.
			public ALTERA   := .F.
		Case cVerbo == 'POST'
			public INCLUI   := .T.
			public ALTERA   := .F.
			nOpc := 3
		Case cVerbo == 'PUT'
			public INCLUI   := .F.
			public ALTERA   := .T.
			nOpc := 4
		Case cVerbo == 'DELETE'
			public INCLUI   := .F.
			public ALTERA   := .F.
			nOpc := 5
	End Case

	Do case
		Case IsInPath(cPath, "JURA289")   // Incidedentes, Vinculados e Relacionados 
			cRotina := "'01','02','17'"
		Case IsInPath(cPath, "TJurAnexo") // Anexos
			cRotina := "'03'"
		Case IsInPath(cPath, "JURA100")   // Andamentos
			cRotina := "'04'"
		Case IsInPath(cPath, "JURA106")   // Follow-ups
			cRotina := "'05'"
		Case IsInPath(cPath, "JURA094") .OR. IsInPath(cPath, "JURA270") // Objetos / Pedidos
			cRotina := "'06'"
		Case IsInPath(cPath, "JURA098")   // Garantias
			cRotina := "'07'"
		Case IsInPath(cPath, "JURA099")   // Despesas
			cRotina := "'08'"
		Case IsInPath(cPath, "JURA088")   // Contratos de Correspondente
			cRotina := "'09'"
		Case IsInPath(cPath, "JURA108")   // Exporta��o Personalizada
			cRotina := "'12'"
		Case IsInPath(cPath, "JURA095")   // Processos
			cRotina := "'14'"
		Case IsInPath(cPath, "JURA124")   // Concess�es
			cRotina := "'15'"
		Case IsInPath(cPath, "JURA254")   // Solicita��o de Documento
			cRotina := "'19'"
		Case IsInPath(cPath, "JURA260")   // Liminares
			cRotina := "'20'"
		Case IsInPath(cPath, "JURA233") .OR. IsInPath(cPath, "JURA234")  // e-Social / Log e-Social
			cRotina := "'21'"
		Case IsInPath(cPath, "JURA269")   // Favoritos
			Self:SetFilter("O0V_USER='" + __CUSERID + "' ")
		Case IsInPath(cPath, "JCLIDEP")   // Clientes
			Self:SetFilter("A1_FILIAL='" + xFilial("SA1") + "'")
		Case IsInPath(cPath, "JURA132")   // Escrit�rio Credenciado
			Self:SetFilter("A2_FILIAL='" + xFilial("SA2") + "'")
		Case IsInPath(cPath, "JBANFIN")
			Self:SetFilter("A6_FILIAL='" + xFilial("SA6") + "'")
		Case IsInPath(cPath, "JNATFIN")
			Self:SetFilter("ED_FILIAL='" + xFilial("SED") + "'")
		Case IsInPath(cPath, "JCONPGFIN")
			Self:SetFilter("E4_FILIAL='" + xFilial("SE4") + "'")
		Case IsInPath(cPath, "JPRODUTO")
			Self:SetFilter("B1_FILIAL='" + xFilial("SB1") + "'")
		Case IsInPath(cPath, "JCCUSTO")
			Self:SetFilter("CTT_FILIAL='" + xFilial("CTT") + "'")
		Case IsInPath(cPath, "JPARTIC")   // Participantes
			Self:SetFilter("RD0_FILIAL='" + xFilial("RD0") + "'")
		Case IsInPath(cPath, "JURA276")   // Modelos de Exporta��o
			Self:SetFilter("NQ5_FILIAL='" + xFilial("NQ5") + "'")
		Case IsInPath(cPath, "JURA286")   // Prefer�ncias de usu�rio
			Self:SetFilter("O16_FILIAL='" + xFilial("O16") + "'")
		Case IsInPath(cPath, "JURMOEDA")
			Self:SetFilter("CTO_FILIAL='" + xFilial("CTO") + "'")
		Case IsInPath(cPath, "JCRGS")
			Self:SetFilter("Q3_FILIAL='" + xFilial("SQ3") + "'")
		Case IsInPath(cPath, "JURA287") // Causa raiz do processo
			If !Empty(self:searchKey)
				Self:SetFilter(FilterCausaRaiz(self:searchKey))
			EndIf
			cRotina := "'22'"
			self:searchKey := ''
		Case IsInPath(cPath, "JURA297")   // Ato societ�rio
			If !Empty(self:searchKey)
				Self:SetFilter(JFilPChave(self:searchKey, 'JURA297', self:cFilter))
				self:searchKey := ''
			EndIf
	End Case

	IF !Empty(self:searchKey)
		Self:SetFilter(JModRNormFil(self:searchKey))
	EndIf

	If !Empty(self:exists)
		self:setExistsQry()
	Endif

	If !Empty(cRotina) .AND. (!Empty(self:pkAssJur) .Or. (cRotina == "'14'" .And. nOpc == 3))
		If Empty(self:tipoAssJur)
			nTamCod := GetSx3Cache('NSZ_COD', 'X3_TAMANHO')
			If Len(self:pkAssJur) <= nTamCod
				cTpAssJur := xFilial("NSZ") + self:pkAssJur
			Else
				cTpAssJur := self:pkAssJur
			EndIf
			cTpAssJur := JurGetDados("NSZ", 1, cTpAssJur, "NSZ_TIPOAS")
		else
			cTpAssJur := self:tipoAssJur
		EndIf

		cTipoAsJ := cTpAssJur
		c162TipoAs := cTpAssJur
		lAcesso := JVldRestri(cTpAssJur, cRotina, nOpc)
	EndIf

	If !lAcesso
		SetRestFault(403, STR(nOpc) + STR0001) // ": Acesso negado."
		ConOut(STR0002 + cVerbo + STR0003 + Substr(cPath,Rat("/",cPath)+1)) // "Sem permiss�o para #1 em #2
		self:ClearModel()
	EndIf

	Self:lActivate := lAcesso

Return lAcesso

//-------------------------------------------------------------------
/*/{Protheus.doc} JModRNormFil(cBusca)
Fun��o respons�vel por normalizar o searchKey. Remove caracteres especiais no campo e
a palavra pesquisada.

@param cBusca - Estrutura para realizar o tratamento dos caracteres 
				especiais. Estrutura:
				{
					"fields": [
						{ "NQ4_COD" },
						{ "NQ4_DESC" },
					]
					"searchKey": 'palavra ou frase a ser pesquisada'
				}

@since 07/07/2020
/*/
//-------------------------------------------------------------------
Function JModRNormFil(cBusca)
Local cFilter   := ''
Local cValBusca := ''
Local nI        := 1
Local nFields   := 0
Local oBusca    := JsonObject():New()

	If !Empty(cBusca)
		oBusca:fromJson(cBusca)
		nFields := Len(oBusca['fields'])

		If nFields > 0 .AND. VALTYPE(oBusca['searchKey']) == "C" .And. !Empty(oBusca['searchKey'])
			cValBusca  := Lower( StrTran( JurLmpCpo( DecodeUTF8(oBusca['searchKey'] ), .F. ), '#', '' ) )

			cFilter := ' ( '

			If Empty(cValBusca)
				cValBusca := Lower( StrTran( JurLmpCpo( oBusca['searchKey'], .F. ), '#', '' ) )
			EndIf

			For nI := 1 To nFields
				
				cFilter    += JurFormat(oBusca['fields'][nI], .T./*lAcentua*/,.T./*lPontua*/);
						   + " Like '%" + cValBusca + "%'"

				If nI < nFields
					cFilter += ' OR '
				EndIf
			Next

			cFilter += ') '
		EndIf
	EndIf

Return cFilter

//-------------------------------------------------------------------
/*/{Protheus.doc} FilPChave()
Monta o filtro para pesquisar a palavra chave.

@param cPDigitada - Palavra que o usu�rio deseja filtrar.
@param cRotina    - Informa qual rotina ter� a palavra chave

@since 07/07/2020
/*/
//-------------------------------------------------------------------
Function JFilPChave(cPDigitada, cRotina, cFilter)
Local aAux      := {}
Local cPalChave := ''
Local cFiltro   := ''
Local nCont     := 1

Default cPDigitada := ''
Default cRotina    := 'JURA297'

	aAux := StrToKarr( cPDigitada, "|")
	
	//Palavras digitadas
	For nCont := 1 To Len(aAux)

		cPalChave := DecodeUTF8(aAux[nCont])

		If Empty(cPalChave)
			cPalChave := aAux[nCont]
		EndIf

		If !Empty(cPalChave)
			If !Empty(cFiltro)
				cFiltro += ' AND '
			Endif

			If cRotina == 'JURA297'
				cFiltro += J297PChave(cPalChave, cFilter)
			EndIf

		EndIf
	Next nCont

Return cFiltro

//-------------------------------------------------------------------
/*/{Protheus.doc} DeActivate()
M�todo para desativar a classe
@since 26/06/2019
/*/
//-------------------------------------------------------------------
Method DeActivate() Class JurModRest

	Self:cFilter := ""
	If lWSTLegal
		lWSTLegal := .F.
	EndIf

Return _Super:DeActivate()

//-------------------------------------------------------------------
/*/{Protheus.doc} SetFilter(cFilter)
Monta os filtros extra
@since 30/09/2019
/*/
//-------------------------------------------------------------------
Method SetFilter(cFilter)  Class JurModRest
Local cFiltExi := ""
	If (self:cFilter != Nil)
		cFiltExi := Self:cFilter
	EndIf

	If !Empty(cFiltExi) .AND. !Empty(cFilter)
		cFiltExi += " AND "
	Endif
	cFiltExi += cFilter

	Self:cFilter := cFiltExi
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} IsInPath(cPath, cFonte)
Verifica se o Endpoint (cFonte) est� na requisi��o (cPath)

@Param cPath - Path completo da requisi��o
@Param cFonte - Nome do fonte a ser verificado

@since 30/09/2019
/*/
//-------------------------------------------------------------------
Static Function IsInPath(cPath, cFonte)
Default cPath  := ""
Default cFonte := ""
Return  cFonte $ cPath

//-------------------------------------------------------------------
/*/{Protheus.doc}  GetWhereQryAlias(cTable)
Adiciona a seguran�a padr�o de acesso as filiais do sistema
@since 20/02/2020
/*/
//-------------------------------------------------------------------

Static Function GetWhereQryAlias(cTable)
Local cWhere AS CHARACTER
Local cUsrFilFilter AS CHARACTER

	cWhere := " WHERE D_E_L_E_T_ = ' '"

	//Introduz a seguran�a padr�o de acesso as filiais do sistema
	If (cTable)->(FieldPos(PrefixoCpo(cTable)+"_FILIAL")) > 0
		cUsrFilFilter := FWSQLUsrFilial(cTable)
		If !Empty(cUsrFilFilter)
			cWhere += " AND " + cUsrFilFilter
		EndIf
	EndIf

Return cWhere

//-------------------------------------------------------------------
/*/{Protheus.doc}  Seek(cPK)
Adiciona uma ordena��o
@since 20/02/2020
/*/
//-------------------------------------------------------------------

Method Seek(cPK) Class JurModRest
Local lRet AS LOGICAL
Local cQry AS CHARACTER
Local cPkFilter AS CHARACTER
Local cQuery AS CHARACTER
Local lHasPK AS LOGICAL

	lRet   := .F.
	lHasPK := !Empty(cPK)

	If self:HasAlias()
		cQuery := "SELECT R_E_C_N_O_"

		cQuery += " FROM "+ RetSqlName(self:cAlias)
		cQuery += GetWhereQryAlias(self:cAlias)
		If lHasPK
			cPkFilter := FWAToS(self:oModel:GetPrimaryKey(),"||") + "=?"

			If (self:cAlias)->(FieldPos(PrefixoCpo(self:cAlias)+"_FILIAL")) > 0
				cPkFilter := PrefixoCpo(self:cAlias)+"_FILIAL||" + cPkFilter
			EndIf
			cQuery += " AND " + cPkFilter
		Endif

		If !Empty(self:cFilter)
			cQuery += " AND ( " + self:cFilter + " ) "
		EndIf
		
		If !Empty(self:qryOrder)
			cQuery += self:qryOrder
		EndIf

		oStatement := FWPreparedStatement():New(cQuery)
		If lHasPK
			oStatement:SetString(1, cPK)
		EndIf
		cQuery := oStatement:getFixQuery()
		cQuery := ChangeQuery(cQuery)

		MPSysOpenQuery(cQuery, @self:cQryAlias)

		oStatement:Destroy()
		FwFreeObj(oStatement)

		If self:lDebug .And. self:GetQSValue("showQuery") == "true"
			i18nConOut("[FWRESTMODELOBJECT] Query: #1#2", {CRLF, cQry})
		EndIf

		If !(self:cQryAlias)->(Eof())
			(self:cAlias)->(dbGoTo((self:cQryAlias)->R_E_C_N_O_))
			lRet := !(self:cAlias)->(Eof())
		EndIf
	Endif

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} existsQry
Cria a parte da query onde monta o exists conforme o objeto passado
@since 04/02/2021
@version 1.0
/*/
//------------------------------------------------------------------------------
Method setExistsQry() Class JurModRest
Local cQuery     := ""
Local oJsonExist := JsonObject():New()
Local oStatement := FWPreparedStatement():New()
Local aParams    := {}
Local xValue     := nil
Local n1         := 0
Local cTableRef  := ""
Local cTable     := ""

	oJsonExist:fromJson(self:exists)

	oStatement:setQuery(oJsonExist["query"])

	If ValType(oJsonExist["params"]) == "A"
		aParam := oJsonExist["params"]
		For n1 := 1 To Len(aParam)

			If ValType(aParam[n1]['func']) <> "U"
				xValue := &(aParam[n1]["value"])
			Else
				xValue := aParam[n1]["value"]
			Endif

			If aParam[n1]['type'] == "C"
				oStatement:SetString(n1, xValue)
			ElseIf aParam[n1]['type'] == "N"
				oStatement:setNumeric(n1, xValue)
			ElseIf aParam[n1]['type'] == "D"
				oStatement:setDate(n1, StoD(xValue))
			ElseIf aParam[n1]['type'] == "A"
				oStatement:setIn(n1, xValue)
			Endif

		Next
	Endif
	
	cQuery := ChangeQuery(oStatement:getFixQuery())

	While (nAt := At('%TABLE:',cQuery)) > 0
		cTableRef := SubStr(cQuery, nAt,11)
		cTable    := SubStr(cTableRef, At(':',cTableRef)+1,3)
		cQuery    := StrTran(cQuery,cTableRef,RetSqlName(cTable))
	EndDo

	
	cQuery := "EXISTS(" + cQuery + ")"
		
	
	self:SetFilter(cQuery)

	oStatement:Destroy()
	aSize(aParams,0)
	aParams := nil

Return 


//-------------------------------------------------------------------
/*/{Protheus.doc} JModRst
Realiza o filtro dos campos virtuais da causa raiz do processo
@param searchKey palavra chave a ser buscada
@since 04/01/2021
/*/
//-------------------------------------------------------------------
Static Function FilterCausaRaiz(searchKey)
Local cRetQry:= ''

	cRetQry += "EXISTS("
	cRetQry +=    " SELECT 1 "
	cRetQry +=    " FROM "+RetSqlName('O04')+" O04 "
	cRetQry +=    " INNER JOIN "+RetSqlName('O0A')+" O0A ON "
	cRetQry +=        " O0A_FILIAL = O04_FILIAL "
	cRetQry +=        " AND O0A_CCAUSA = O04_COD "
	cRetQry +=        " AND O0A.D_E_L_E_T_ = ' ' "
	cRetQry +=    " WHERE "
	cRetQry +=        " O04_FILIAL = '"+xFilial('O04')+"' "
	cRetQry +=        " AND O04_COD = O05_CCAUSA "
	cRetQry +=        " AND O0A_COD = O05_CCLACA "
	cRetQry +=        " AND " + JModRNormFil(searchKey)
	cRetQry += " ) "

return cRetQry



//-------------------------------------------------------------------
/*/{Protheus.doc} TrataOper
Retorna a oper��o de acordo com o body

@param cBody - Body da requisi��o
@return nOperacao - numero da opera��o
@since 08/03/2021
/*/
//-------------------------------------------------------------------
Static Function TrataOper(cBody)

Local oReqBody  := Nil
Local nOperacao := 0

	FWJsonDeserialize(cBody,@oReqBody)
	nOperacao := oReqBody:operation

Return nOperacao

//-------------------------------------------------------------------
/*/{Protheus.doc} JModRst
Publica��o dos modelos que s�o disponibilizados no REST
@since 26/06/2019
/*/
//-------------------------------------------------------------------
Function JModRst()

Return lWSTLegal

	PUBLISH MODEL REST NAME JPRODUTO     SOURCE MATA010 RESOURCE OBJECT JurModRest //-- Produto - MATA010
	PUBLISH MODEL REST NAME JRATEIO      SOURCE CTBA120 RESOURCE OBJECT JurModRest //-- Rateio - CTBA120
	PUBLISH MODEL REST NAME JCRGS        SOURCE GPEA370 RESOURCE OBJECT JurModRest //-- Cargo de Funcion�rios - GPEA370
	PUBLISH MODEL REST NAME JCLIDEP      SOURCE JURA148 RESOURCE OBJECT JurModRest //-- Clientes - JURA148
	PUBLISH MODEL REST NAME JPARTIC      SOURCE JURA159 RESOURCE OBJECT JurModRest //-- Participantes FUP - JURA159
	PUBLISH MODEL REST NAME JBANFIN      SOURCE MATA070 RESOURCE OBJECT JurModRest //-- Banco - MATA070
	PUBLISH MODEL REST NAME JNATFIN      SOURCE FINA010 RESOURCE OBJECT JurModRest //-- Natureza - FINA010
	PUBLISH MODEL REST NAME JCONPGFIN    SOURCE MATA360 RESOURCE OBJECT JurModRest //-- Condi��o de Pagamento - MATA360 (SE4)
	PUBLISH MODEL REST NAME JCCUSTO      SOURCE CTBA030 RESOURCE OBJECT JurModRest //-- Centro de custo - CTBA030
	PUBLISH MODEL REST NAME JURMOEDA     SOURCE CTBA140 RESOURCE OBJECT JurModRest //-- Moedas Cont�beis - CTBA140
	PUBLISH MODEL REST NAME JURMUNIC     SOURCE FISA010 RESOURCE OBJECT JurModRest //-- Munic�pios - FISA010
	PUBLISH MODEL REST NAME JURAREAJ     SOURCE JURA038 RESOURCE OBJECT JurModRest //-- �rea Jur�dica - JURA038
	PUBLISH MODEL REST NAME JURSUBAREAJ  SOURCE JURA048 RESOURCE OBJECT JurModRest //-- SUB �rea Jur�dica
	PUBLISH MODEL REST NAME JURCONTAT    SOURCE JURA232 RESOURCE OBJECT JurModRest //-- Contatos - JURA232
	PUBLISH MODEL REST NAME JURESCR      SOURCE JURA068 RESOURCE OBJECT JurModRest //-- Escritorio (Departamento jur�dico) - JURA068

	/* Publica��o dos modelos que s�o disponibilizados no REST */
	PUBLISH MODEL REST NAME JURA001 SOURCE JURA001 RESOURCE OBJECT JurModRest //-- Natureza - JURA001
	PUBLISH MODEL REST NAME JURA003 SOURCE JURA003 RESOURCE OBJECT JurModRest //-- Cadastro de relat�rios - JURA003
	PUBLISH MODEL REST NAME JURA004 SOURCE JURA004 RESOURCE OBJECT JurModRest //-- Objeto/ Assunto - JURA004
	PUBLISH MODEL REST NAME JURA005 SOURCE JURA005 RESOURCE OBJECT JurModRest //-- Comarcas - JURA005
	PUBLISH MODEL REST NAME JURA006 SOURCE JURA006 RESOURCE OBJECT JurModRest //-- Comarcas - JURA005
	PUBLISH MODEL REST NAME JURA009 SOURCE JURA009 RESOURCE OBJECT JurModRest //-- tipo de envolvimento - JURA009
	PUBLISH MODEL REST NAME JURA011 SOURCE JURA011 RESOURCE OBJECT JurModRest //-- Fase processual - JURA011
	PUBLISH MODEL REST NAME JURA012 SOURCE JURA012 RESOURCE OBJECT JurModRest //-- Cadastro de Juiz
	PUBLISH MODEL REST NAME JURA013 SOURCE JURA013 RESOURCE OBJECT JurModRest //-- Motivo de encerramento - JURA013
	PUBLISH MODEL REST NAME JURA014 SOURCE JURA014 RESOURCE OBJECT JurModRest //-- Configura��o de Relat�rio - JURA014
	PUBLISH MODEL REST NAME JURA015 SOURCE JURA015 RESOURCE OBJECT JurModRest //-- Configura��o de Relat�rio 
	PUBLISH MODEL REST NAME JURA016 SOURCE JURA016 RESOURCE OBJECT JurModRest //-- Prepostos - JURA016
	PUBLISH MODEL REST NAME JURA017 SOURCE JURA017 RESOURCE OBJECT JurModRest //-- Resultados de Follow-ups
	PUBLISH MODEL REST NAME JURA019 SOURCE JURA019 RESOURCE OBJECT JurModRest //-- Resultados de cadastro de decis�o
	PUBLISH MODEL REST NAME JURA021 SOURCE JURA021 RESOURCE OBJECT JurModRest //-- Tipos de Follow-ups - JURA021
	PUBLISH MODEL REST NAME JURA022 SOURCE JURA022 RESOURCE OBJECT JurModRest //-- Tipo de A��o - JURA022
	PUBLISH MODEL REST NAME JURA024 SOURCE JURA024 RESOURCE OBJECT JurModRest //-- Tipos de Garantia - JURA024
	PUBLISH MODEL REST NAME JURA025 SOURCE JURA025 RESOURCE OBJECT JurModRest //-- Motivo de altera��o - JURA025
	PUBLISH MODEL REST NAME JURA051 SOURCE JURA051 RESOURCE OBJECT JurModRest //-- Ato processual - JURA051
	PUBLISH MODEL REST NAME JURA052 SOURCE JURA052 RESOURCE OBJECT JurModRest //-- Cargo - JURA052
	PUBLISH MODEL REST NAME JURA054 SOURCE JURA054 RESOURCE OBJECT JurModRest //-- Cadastro de Advogado da Parte Contr�ria
	PUBLISH MODEL REST NAME JURA061 SOURCE JURA061 RESOURCE OBJECT JurModRest //-- Formas de Corre��o - JURA061
	PUBLISH MODEL REST NAME JURA067 SOURCE JURA067 RESOURCE OBJECT JurModRest //-- Cadastro de Fun��o
	PUBLISH MODEL REST NAME JURA085 SOURCE JURA085 RESOURCE OBJECT JurModRest //-- Tipo de Objeto - JURA085
	PUBLISH MODEL REST NAME JURA089 SOURCE JURA089 RESOURCE OBJECT JurModRest //-- Cadastro de Classe
	PUBLISH MODEL REST NAME JURA087 SOURCE JURA087 RESOURCE OBJECT JurModRest //-- Tipo de Despesa - JURA087
	PUBLISH MODEL REST NAME JURA093 SOURCE JURA093 RESOURCE OBJECT JurModRest //-- Justificativa de altera��o de correspondente - JURA093
	PUBLISH MODEL REST NAME JURA094 SOURCE JURA094 RESOURCE OBJECT JurModRest //-- Objetos/Pedidos - JURA094
	PUBLISH MODEL REST NAME JURA095 SOURCE JURA095 RESOURCE OBJECT JurModRest //-- Processo - JURA095
	PUBLISH MODEL REST NAME JURA098 SOURCE JURA098 RESOURCE OBJECT JurModRest //-- Garantias - JURA098
	PUBLISH MODEL REST NAME JURA099 SOURCE JURA099 RESOURCE OBJECT JurModRest //-- Despesas - JURA099
	PUBLISH MODEL REST NAME JURA100 SOURCE JURA100 RESOURCE OBJECT JurModRest //-- Andamentos - JURA100
	PUBLISH MODEL REST NAME JURA106 SOURCE JURA106 RESOURCE OBJECT JurModRest //-- Follow-ups - JURA106
	PUBLISH MODEL REST NAME JURA107 SOURCE JURA107 RESOURCE OBJECT JurModRest //-- Local de trabalho - JURA107
	PUBLISH MODEL REST NAME JURA124 SOURCE JURA124 RESOURCE OBJECT JurModRest //--Cadastro de Concess�es
	PUBLISH MODEL REST NAME JURA130 SOURCE JURA130 RESOURCE OBJECT JurModRest //-- Cadastro de Classe
	PUBLISH MODEL REST NAME JURA138 SOURCE JURA138 RESOURCE OBJECT JurModRest //-- Cadastro de Modalidades de Licita��es
	PUBLISH MODEL REST NAME JURA139 SOURCE JURA139 RESOURCE OBJECT JurModRest //-- Cadastro de Crit�rio de Julgamento
	PUBLISH MODEL REST NAME JURA131 SOURCE JURA131 RESOURCE OBJECT JurModRest //-- Cadastro da itua��odo Envolvido
	PUBLISH MODEL REST NAME JURA132 SOURCE JURA132 RESOURCE OBJECT JurModRest //-- Escrit�rio Correspondente/ Fornecedor (SA2) - JURA132
	PUBLISH MODEL REST NAME JURA133 SOURCE JURA133 RESOURCE OBJECT JurModRest //-- Tipos de Aditivos de Contratos (NXZ) - JURA133
	PUBLISH MODEL REST NAME JURA134 SOURCE JURA134 RESOURCE OBJECT JurModRest //-- Tipo de Contrato - JURA134
	PUBLISH MODEL REST NAME JURA149 SOURCE JURA149 RESOURCE OBJECT JurModRest //-- Tipo de Marcas
	PUBLISH MODEL REST NAME JURA150 SOURCE JURA150 RESOURCE OBJECT JurModRest //--  Situa��o das Marcas
	PUBLISH MODEL REST NAME JURA151 SOURCE JURA151 RESOURCE OBJECT JurModRest //--  Natureza das Marcas
	PUBLISH MODEL REST NAME JURA155 SOURCE JURA155 RESOURCE OBJECT JurModRest //--  �reas de Neg�cios
	PUBLISH MODEL REST NAME JURA156 SOURCE JURA156 RESOURCE OBJECT JurModRest //-- Tipos de solicita��o - JURA156
	PUBLISH MODEL REST NAME JURA158 SOURCE JURA158 RESOURCE OBJECT JurModRest //-- Assuntos jur�dicos - JURA158
	PUBLISH MODEL REST NAME JURA163 SOURCE JURA163 RESOURCE OBJECT JurModRest //-- Relaciona Pesquisa / Assunto jur�dico x Usu�rio - JURA163
	PUBLISH MODEL REST NAME JURA166 SOURCE JURA166 RESOURCE OBJECT JurModRest //-- Justificativa - JURA166
	PUBLISH MODEL REST NAME JURA167 SOURCE JURA167 RESOURCE OBJECT JurModRest //-- Vari�veis de Texto
	PUBLISH MODEL REST NAME JURA184 SOURCE JURA184 RESOURCE OBJECT JurModRest //-- Parte Contr�ria - JURA184
	PUBLISH MODEL REST NAME JURA185 SOURCE JURA185 RESOURCE OBJECT JurModRest //-- Cadastro de equipe Jur�dico
	PUBLISH MODEL REST NAME JURA199 SOURCE JURA199 RESOURCE OBJECT JurModRest //-- Cadastro de Base de decis�o
	PUBLISH MODEL REST NAME JURA187 SOURCE JURA187 RESOURCE OBJECT JurModRest //-- Cadastro de Divulga��o
	PUBLISH MODEL REST NAME JURA218 SOURCE JURA218 RESOURCE OBJECT JurModRest //-- Usu�rios x Grupo - JURA218
	PUBLISH MODEL REST NAME JURA233 SOURCE JURA233 RESOURCE OBJECT JurModRest //-- E-social - JURA233
	PUBLISH MODEL REST NAME JURA251 SOURCE JURA251 RESOURCE OBJECT JurModRest //-- Tipo de Documentos (O0L) - JURA251
	PUBLISH MODEL REST NAME JURA254 SOURCE JURA254 RESOURCE OBJECT JurModRest //-- Solicita��o de Documentos (O0M / O0N) - JURA254
	PUBLISH MODEL REST NAME JURA257 SOURCE JURA257 RESOURCE OBJECT JurModRest //-- Ato Processual Autom�tico /Classif. Auto. (O0O) - JURA257
	PUBLISH MODEL REST NAME JURA258 SOURCE JURA258 RESOURCE OBJECT JurModRest //-- Redutores - JURA258
	PUBLISH MODEL REST NAME JURA259 SOURCE JURA259 RESOURCE OBJECT JurModRest //-- Tipo de Liminares - JURA259
	PUBLISH MODEL REST NAME JURA260 SOURCE JURA260 RESOURCE OBJECT JurModRest //-- Liminares - JURA260
	PUBLISH MODEL REST NAME JURA269 SOURCE JURA269 RESOURCE OBJECT JurModRest //-- Favoritos - JURA269
	PUBLISH MODEL REST NAME JURA270 SOURCE JURA270 RESOURCE OBJECT JurModRest //-- Verbas Por Pedidos - JURA270
	PUBLISH MODEL REST NAME JURA276 SOURCE JURA276 RESOURCE OBJECT JurModRest //-- Modelos de Configura��o para Exporta��o - JURA276
	PUBLISH MODEL REST NAME JURA018 SOURCE JURA018 RESOURCE OBJECT JurModRest //-- Rito - JURA018
	PUBLISH MODEL REST NAME JURA279 SOURCE JURA279 RESOURCE OBJECT JurModRest //-- Distribui��o - JURA279
	PUBLISH MODEL REST NAME JURA280 SOURCE JURA280 RESOURCE OBJECT JurModRest //-- Notifica��es - JURA280
	PUBLISH MODEL REST NAME JURA282 SOURCE JURA282 RESOURCE OBJECT JurModRest //-- Hist�rico de Altera��es de Pedidos - JURA282
	PUBLISH MODEL REST NAME JURA283 SOURCE JURA283 RESOURCE OBJECT JurModRest //-- Publica��es - JURA283
	PUBLISH MODEL REST NAME JURA285 SOURCE JURA285 RESOURCE OBJECT JurModRest //-- Rotinas Customizadas - JURA285
	PUBLISH MODEL REST NAME JURA286 SOURCE JURA286 RESOURCE OBJECT JurModRest //-- Prefer�ncia de usu�rio - JURA286
	PUBLISH MODEL REST NAME JURA287 SOURCE JURA287 RESOURCE OBJECT JurModRest //-- Causa ra�z do processo - JURA287
	PUBLISH MODEL REST NAME JURA288 SOURCE JURA288 RESOURCE OBJECT JurModRest //-- Gest�o de relat�rio Totvs Legal - JURA288
	PUBLISH MODEL REST NAME JURA289 SOURCE JURA289 RESOURCE OBJECT JurModRest //-- Relacionamentos Totvs Legal - JURA289
	PUBLISH MODEL REST NAME JURA293 SOURCE JURA293 RESOURCE OBJECT JurModRest //-- Configura��o do produto TOTVS Jur�dico Dept. - JURA293
	PUBLISH MODEL REST NAME JURA294 SOURCE JURA294 RESOURCE OBJECT JurModRest //-- Cadastro de Tipo de Certid�es e Licen�as - O19
	PUBLISH MODEL REST NAME JURA295 SOURCE JURA295 RESOURCE OBJECT JurModRest //-- Cadastro de Certid�es e Licen�as - O1A
	PUBLISH MODEL REST NAME JURA296 SOURCE JURA296 RESOURCE OBJECT JurModRest //-- Cadastro de Tipos de Atos societ�rios - O1C
	PUBLISH MODEL REST NAME JURA297 SOURCE JURA297 RESOURCE OBJECT JurModRest //-- Cadastro de Atos societ�rios - O1D
	PUBLISH MODEL REST NAME JURA299 SOURCE JURA299 RESOURCE OBJECT JurModRest //-- Solicita��es de cadastro de usu�rios - O1E
	PUBLISH MODEL REST NAME JURA183 SOURCE JURA183 RESOURCE OBJECT JurModRest //-- Inst�ncias - NUQ
