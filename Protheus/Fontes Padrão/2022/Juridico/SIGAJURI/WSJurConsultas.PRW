#INCLUDE "WSJURCONSULTAS.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "SHELL.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} WSJurConsultas
Métodos WS REST do Jurídico para consultas.

@author SIGAJURI
@since 12/03/2020

/*/
//-------------------------------------------------------------------

WSRESTFUL JURCONSULTAS DESCRIPTION "WS Jurídico Consultas"

	WSDATA page         AS INTEGER
	WSDATA pageSize     AS INTEGER
	WSDATA nOpc         AS INTEGER
	WSDATA nCount       AS INTEGER
	WSDATA searchKey    AS STRING
	WSDATA assJur       AS STRING
	WSDATA filial       AS STRING
	WSDATA cajuri       AS STRING
	WSDATA situac       AS STRING
	WSDATA tpFilter     AS STRING
	WSDATA nomeConfig   AS STRING
	WSDATA codConfig    AS STRING
	WSDATA codRelatorio AS STRING
	WSDATA codWF        AS STRING
	WSDATA filConsulta  AS STRING
	WSDATA tpContrato   AS STRING
	WSDATA areaSolic    AS STRING
	WSDATA dataRef      AS STRING
	WSDATA dtInicial    AS STRING
	WSDATA dtFinal      AS STRING
	WSDATA partic       AS STRING
	WSDATA acaoGrp      AS STRING
	WSDATA usersGrupo   AS STRING
	WSDATA codGrupo     AS STRING
	WSDATA tpAcesso     AS STRING
	WSDATA filtraMod    AS STRING
	WSDATA filter       AS STRING
	WSDATA xbAlias      AS STRING
	WSDATA rotina       AS STRING
	WSDATA ato          AS STRING
	WSDATA tpFUP        AS STRING
	WSDATA codAnd       AS STRING
	WSDATA isValid      AS STRING
	WSDATA lAuto        AS BOOLEAN
	WSDATA filtF3       AS STRING
	WSDATA relaciona    AS STRING // tipo de relacionamento
	WSDATA codUser      AS STRING
	WSDATA showMySelf   AS BOOLEAN

	//Gets
	WSMETHOD GET ListContratos         DESCRIPTION STR0001 PATH "contracts"                            PRODUCES APPLICATION_JSON // 'Listagem de contratos'
	WSMETHOD GET montaURLFluig         DESCRIPTION STR0002 PATH "urlFluig"                             PRODUCES APPLICATION_JSON // 'URL Workflow Fluig'
	WSMETHOD GET anexosFluig           DESCRIPTION STR0003 PATH "anexosFluig/{cajuri}"                 PRODUCES APPLICATION_JSON // 'Abre os anexos da pasta do caso Fluig'
	WSMETHOD GET grafInfoContratos     DESCRIPTION STR0004 PATH "contractChartData"                    PRODUCES APPLICATION_JSON // 'Informações para compor o gráfico valor de contratos em andamento por tipo'
	WSMETHOD GET DownloadFile          DESCRIPTION STR0005 PATH "downloadFile/{codConfig}"             PRODUCES APPLICATION_JSON // 'Download de arquivos'
	WSMETHOD GET getWfSLAJur           DESCRIPTION STR0006 PATH "getHistoryWF"                         PRODUCES APPLICATION_JSON // 'Busca a quantidade de wokflows finalizados que ainda não foram processados, para calculo de SLA'
	WSMETHOD GET procHistWF            DESCRIPTION STR0007 PATH "processHistory"                       PRODUCES APPLICATION_JSON // 'Processa o histórico dos wokflows finalizados para calculo de SLA'
	WSMETHOD GET grafSLA               DESCRIPTION STR0008 PATH "slaChartData"                         PRODUCES APPLICATION_JSON // 'Informações para compor o gráfico de sla dias x meses'
	WSMETHOD GET grafEsforco           DESCRIPTION STR0009 PATH "esforcoChartData"                     PRODUCES APPLICATION_JSON // 'Informações para compor o gráfico de esforço em horas x meses'
	WSMETHOD GET getDiasSLA            DESCRIPTION STR0010 PATH "slaDias"                              PRODUCES APPLICATION_JSON // 'Calcula o SLA em dias'
	WSMETHOD GET tpContrSla            DESCRIPTION STR0011 PATH "slaTpContr"                           PRODUCES APPLICATION_JSON // 'Busca os tipos de Contrato para o Cálculo de SLA'
	WSMETHOD GET procWFIncons          DESCRIPTION STR0012 PATH "procWFInconsis"                       PRODUCES APPLICATION_JSON // 'Grava as consultas que possuem o Workflow inconsistente no Fluig'
	WSMETHOD GET areaSolicSLA          DESCRIPTION STR0013 PATH "slaAreaSolic"                         PRODUCES APPLICATION_JSON // 'Busca as areas solicitante para o criação do gráfico de SLA da Área Solicitante'
	WSMETHOD GET grafFlxJur            DESCRIPTION STR0014 PATH "slaChartFluxo"                        PRODUCES APPLICATION_JSON // 'Busca quantidade de horas dos fluxos do jurídico por tipo de contrato'
	WSMETHOD GET grafAreaSoli          DESCRIPTION STR0015 PATH "slaChartArea"                         PRODUCES APPLICATION_JSON // 'Busca quantidade de horas das áreas solicitantes, nos últimos 6 meses'
	WSMETHOD GET grpAssociado          DESCRIPTION STR0016 PATH "userGroups"                           PRODUCES APPLICATION_JSON // 'Busca os grupos associados a um usuário'
	WSMETHOD GET extFields             DESCRIPTION STR0017 PATH "extraFields"                          PRODUCES APPLICATION_JSON // 'Lista dos campos obigatórios e customizados de uma tabela'
	WSMETHOD GET vldUsuarioAssJur      DESCRIPTION STR0018 PATH "vldUsuxAssJur"                        PRODUCES APPLICATION_JSON // 'Validação de usuário, verificação se tem vinculo com outros assuntos jurídicos ou tipo acesso.'
	WSMETHOD GET equipe                DESCRIPTION STR0020 PATH "teamMembers"                          PRODUCES APPLICATION_JSON // 'Busca os membros da equipe do usuário logado'
	WSMETHOD GET getTemplate           DESCRIPTION STR0019 PATH "getTemplate"                          PRODUCES APPLICATION_JSON // 'Busca o modelo de importação de processos'
	WSMETHOD GET getTipoAssunto        DESCRIPTION STR0022 PATH "getTipoAssunto"                       PRODUCES APPLICATION_JSON // 'Busca os filhos do tipo de assunto '
	WSMETHOD GET getListConsultas      DESCRIPTION STR0023 PATH "getListConsultas"                     PRODUCES APPLICATION_JSON // 'Lista as consultas e pareceres.'
	WSMETHOD GET graphConsultivo       DESCRIPTION STR0024 PATH "graphConsultivo"                      PRODUCES APPLICATION_JSON // 'Informações para compor o gráfico da home Consultivos'
	WSMETHOD GET getF3List             DESCRIPTION STR0028 PATH "getF3/{filtF3}/{xbAlias}"             PRODUCES APPLICATION_JSON // 'Busca a lista de opções de um campo tipo F3'
	WSMETHOD GET getF3                 DESCRIPTION STR0029 PATH "getF3/{filtF3}/{xbAlias}/{searchKey}" PRODUCES APPLICATION_JSON // 'Busca o registro específico de um campo tipo F3'
	WSMETHOD GET basicRegStruct        DESCRIPTION STR0031 PATH 'basicRegStruct/{rotina}'              PRODUCES APPLICATION_JSON // 'Busca a estrutura de campos conforme o modelo'
	WSMETHOD GET getFluxoFollowUp      DESCRIPTION STR0032 PATH 'getFluxoFup'                          PRODUCES APPLICATION_JSON // 'Busca a hierarquia do fluxo de intervenção por meio do ato processual ou tipo de FUP'
	WSMETHOD GET getFlxDelete          DESCRIPTION STR0033 PATH 'getFluxoDel/{codAnd}'                 PRODUCES APPLICATION_JSON // 'Busca dos FUPs e Andamentos gerados por um determinado andamento principal'
	WSMETHOD GET getSugDayBusiness     DESCRIPTION STR0034 PATH 'getDayBusiness'                       PRODUCES APPLICATION_JSON // 'Realiza o cálculo de dias a partir de uma data'
	WSMETHOD GET getLastHistory        DESCRIPTION STR0036 PATH 'lastHistory/{filial}/{cajuri}'        PRODUCES APPLICATION_JSON // 'Realiza a busca do ultimo histórico do assunto jurídico'
	WSMETHOD GET childrenLegalMatter   DESCRIPTION STR0037 PATH 'getChildrenLegalMatter'               PRODUCES APPLICATION_JSON // 'Realiza a busca dos filhos de um determinado tipo assunto jurídico'
	WSMETHOD GET getMyTeam             DESCRIPTION STR0038 PATH 'myTeam'                               PRODUCES APPLICATION_JSON // 'Realiza a busca dos dados da minha equipe'
	//Posts
	WSMETHOD POST uploadDot            DESCRIPTION STR0030 PATH "uploadDot" // 'Upload de arquivo .dot'

	//Put
	WSMETHOD PUT deleteFluxo           DESCRIPTION STR0035 PATH "deleteFluxo/{codAnd}" // 'Deleta FUPs e Andamentos que foram gerados por um fluxo'

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} GET ListContratos
Lista de contratos a vencer

@param page        Numero da página
@param pageSize    Quantidade de itens na página 
@param searchKey   Trecho a ser utilizado no filtro de contratos
@param assJur      Tipo do assunto jurídico 
@param situac      Situação 1 - Em Andamento / 2 - Encerrado 
@param tpFilter    Tipo de filtro para acompanhamento 2 - Cadastrados no mês corrente / 3 - Encerrados no mês corrente
@param relaciona   Tipo de relacionamento (Incidente, Vinculado ou Relacionado)
@param filConsulta Filial do contrato origem
@param cCajuri     Cajuri do contrao origem
@param filter      Filtros extras a serem aplicados na consulta

@author SIGAJURI
@since 12/03/2020

/*/ 
//-------------------------------------------------------------------
WSMETHOD GET ListContratos ;
WSRECEIVE page, pageSize, searchKey, assJur, situac, ;
	tpFilter, relaciona, filConsulta, cajuri, filter ;
WSREST JURCONSULTAS
Local aArea      := GetArea()
Local cAlias     := GetNextAlias()
Local oResponse  := JsonObject():New()
Local nPage      := Self:page
Local nPageSize  := Self:pageSize
Local cSearchKey := Self:searchKey
Local cAssJur    := Self:assJur
Local cSituac    := Self:situac
Local cTpFilter  := Self:tpFilter //filtro de andamentos
Local cRelaciona := Self:relaciona //tipo de relacionamento
Local cFilCon    := Self:filConsulta 
Local cCajuri    := Self:cajuri
Local cExtFilter := Self:filter
Local cQuery     := ""
Local nIndexJSon := 0
Local nQtdReg    := 0
Local nQtdRegIni := 0
Local nQtdRegFim := 0
Local lHasNext   := .F.
Local cCompara   := ""
Local bFiliais   := .F.
Local aFilUsr    := JURFILUSR( __CUSERID, "NSZ" )

Default nPage      := 1
Default nPageSize  := 10
Default cSituac    := ""
Default cTpFilter  := ""

	// Monta a query da NSZ
	cQuery := JListNSZ( cSearchKey, cAssJur, cCajuri, cSituac, cTpFilter, cFilCon, cRelaciona, cExtFilter )

	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

	Self:SetContentType("application/json")
	oResponse['contracts'] := {}
	oResponse['userName'] := cUserName
	
	If "," $ FORMATIN(aFilUsr[1],aFilUsr[2])
		bFiliais := .T.
	EndIf		
	oResponse['hasMoreBranch']  := bFiliais
	
	nQtdRegIni := ((nPage-1) * nPageSize)
	// Define o range para inclusão no JSON
	nQtdRegFim := (nPage * nPageSize)
	nQtdReg    := 0

	While (cAlias)->(!Eof())
		// Verificação de cajuris duplicados
		If !(AllTrim((cAlias)->NSZ_COD) $ cCompara)
			nQtdReg++
			// Verifica se o registro está no range da pagina
			If (nQtdReg > nQtdRegIni .AND. nQtdReg <= nQtdRegFim)
				nIndexJSon++
				// Assunto Juridico
				cCajuri := (cAlias)->NSZ_COD
				Aadd(oResponse['contracts'], JsonObject():New())
				oResponse['contracts'][nIndexJSon]['branch']       := (cAlias)->NSZ_FILIAL
				oResponse['contracts'][nIndexJSon]['id']           := JConvUTF8(cCajuri)
				oResponse['contracts'][nIndexJSon]['value']        := ROUND((cAlias)->NSZ_VLCONT,2)
				oResponse['contracts'][nIndexJSon]['renew']        := JConvUTF8((cAlias)->NSZ_RENOVA)
				oResponse['contracts'][nIndexJSon]['description']  := JConvUTF8((cAlias)->NVE_TITULO)
				oResponse['contracts'][nIndexJSon]['due']          := JConvUTF8((cAlias)->NSZ_DTTMVI)
				oResponse['contracts'][nIndexJSon]['detailing']    := JConvUTF8((cAlias)->NSZ_DETALH)
				
				If !Empty(cTpFilter)
					oResponse['contracts'][nIndexJSon]['moviment'] := JConvUTF8((cAlias)->NRO_DESC)
					oResponse['contracts'][nIndexJSon]['movDate']  := JConvUTF8((cAlias)->NT4_DTANDA)
				EndIf
			ElseIf (nQtdReg == nQtdRegFim + 1)
				lHasNext := .T.
			EndIf
		EndIf
		cCompara := cCompara + AllTrim((cAlias)->NSZ_COD) + "|"
		(cAlias)->(DbSkip())
	End

	// Verifica se há uma proxima pagina
	If (lHasNext)
		oResponse['hasNext'] := "true"
	Else
		oResponse['hasNext'] := "false"
	EndIf
	(cAlias)->( DbCloseArea() )
	oResponse['length'] := nQtdReg

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

	RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JListNSZ(cSearchKey, cAssJur, cCajuri, cSituac, cTpFilter, cFilCon, cRelaciona, cExtFilter)
Query da listagem de contratos

@param searchKey   Trecho a ser utilizado no filtro de contratos
@param cAssJur     Tipo do assunto jurídico 
@param cCajuri     Cajuri do contrao origem
@param cSituac     Situação 1 - Em aberto/ 2 - Encerrado 
@param cTpFilter   Tipo de Filtro (Cadastrado ou encerrado no mês)
@param cFilCon     Filial do contrato origem
@param cRelaciona  Tipo de relacionamento (Incidente, Vinculado ou Relacionado)
@param cExtFilter  Filtros extras a serem aplicados na consulta

@author SIGAJURI
@since 12/03/2020

/*/
//-------------------------------------------------------------------
Static Function JListNSZ(cSearchKey, cAssJur, cCajuri, cSituac, cTpFilter, cFilCon, cRelaciona, cExtFilter)
Local aSQLRest   := Ja162RstUs(,,,.T.)
Local aFilUsr    := JURFILUSR( __CUSERID, "NSZ" )
Local cQrySelect := ""
Local cQryFrom   := ""
Local cQryWhere  := ""
Local cQryOrder  := ""
Local cQuery     := ""
Local cExists    := ""
Local lAndamento := .F.
Local cWhrTpAsJ  := ""
Local aAsJFilhos := {}
Local cTpAsJVinc := ""
Local cTpAsJOrig := ""
Local nX         := 1
Local cAssJurRel := ""
Local lFiltraRel := .F.

Default cSearchKey := ""
Default cAssJur    := "006"
Default cCajuri    := ""
Default cSituac    := ""
Default cTpFilter  := ""
Default cFilCon    := ""
Default cRelaciona := ""
Default cExtFilter := ""

	// Validação relacionamento
	If !Empty(cRelaciona)

		Do Case 
			Case cRelaciona == "incidente"

				// Somente processos de tipos de assuntos juridicos iguais do processo origem 
				cWhrTpAsJ := " AND NSZ.NSZ_TIPOAS = '" + cAssJur + "' "

			Case cRelaciona == "vinculado"
				// Somente processos de tipos de assuntos juridicos iguais do processo origem e tipos filhos
				cSQL := " SELECT NYB_COD FROM " + RetSqlname("NYB")
				cSQL += " WHERE NYB_CORIG = '" + cAssJur + "' AND D_E_L_E_T_ = ' '"
				cSQL := ChangeQuery(cSQL)
				aAsJFilhos := JurSQL(cSQL, "*")

				For nX := 1 To Len(aAsJFilhos)
					cTpAsJVinc += "'"+aAsJFilhos[nX][1]+"',"
				Next nX

				cTpAsJOrig := JurGetDados('NYB', 1, xFilial('NYB') + cAssJur, 'NYB_CORIG')

				If !Empty(AllTrim(cTpAsJOrig))
					cTpAsJVinc += "'"+cTpAsJOrig+"',"
				EndIf

				cTpAsJVinc += "'" + cAssJur + "'"

				cWhrTpAsJ := " AND NSZ.NSZ_TIPOAS IN (" + cTpAsJVinc + ") "

			Case cRelaciona == "relacionado"
				
				cTpAsJOrig := JurGetDados('NYB', 1, xFilial('NYB') + cAssJur, 'NYB_CORIG')
				If Empty(cTpAsJOrig)
					lFiltraRel := cAssJur == "006"	
				Else
					lFiltraRel := cTpAsJOrig == "006"
				EndIf

				// Obtém os assuntos jurídicos filhos do assunto juridico do processo origem.
				cAssJurRel := WsJGetTpAss("'006'", .T.)
				If lFiltraRel
					// Trata a string, para retirar o assunto juridico do processo origem
					If "'"+ cAssJur +"'" == cAssJurRel
						cAssJurRel := "''"
					ElseIf at(",'"+ cAssJur +"',", cAssJurRel) > 0
						cAssJurRel := StrTran(cAssJurRel,",'"+ cAssJur +"',", ",")
					ElseIf at("'"+ cAssJur +"',", cAssJurRel) > 0
						cAssJurRel := StrTran(cAssJurRel,"'"+ cAssJur +"',", "")
					ElseIf at(",'"+ cAssJur +"'", cAssJurRel) > 0
						cAssJurRel := StrTran(cAssJurRel,",'"+ cAssJur +"'", "")
					EndIf
				EndIf

				If !Empty(cAssJurRel)
					// Somente processos de tipos de assuntos juridicos diferentes do processo origem
					cWhrTpAsJ := " AND NSZ.NSZ_TIPOAS IN ("+ cAssJurRel+") "
				EndIf
		EndCase
	Else
		// Filtar Filiais que o usuário possui acesso
		cAssJur := WsJGetTpAss("'"+cAssJur+"'", .T.)
		cWhrTpAsJ := " AND NSZ.NSZ_TIPOAS IN ("+ cAssJur+") "
	EndIf

	If !Empty(cTpFilter)
		lAndamento := .T.
	EndIf


	cQrySelect := " SELECT NSZ.NSZ_FILIAL  NSZ_FILIAL, "
	cQrySelect +=        " NSZ.NSZ_COD     NSZ_COD, "
	cQrySelect +=        " NSZ.NSZ_VLCONT  NSZ_VLCONT, "
	cQrySelect +=        " NSZ.NSZ_RENOVA  NSZ_RENOVA, "
	cQrySelect +=        " NVE.NVE_TITULO  NVE_TITULO, "
	cQrySelect +=        " NSZ.NSZ_DTTMVI  NSZ_DTTMVI, "
	cQrySelect +=        " NSZ.NSZ_NUMCON  NSZ_NUMCON, "
	if (Upper(TcGetDb())) == "ORACLE"
		cQrySelect +=    " TO_CHAR(SUBSTR(NSZ.NSZ_DETALH,1,50))  NSZ_DETALH "
	Else
		cQrySelect +=    " CAST(NSZ.NSZ_DETALH AS VARCHAR(50))  NSZ_DETALH "
	Endif

	If lAndamento
		cQrySelect +=        " ,NRO.NRO_DESC   NRO_DESC, "
		cQrySelect +=        " NT4.NT4_DTANDA  NT4_DTANDA "
	EndIf

	cQryFrom   :=        " FROM " + RetSqlName('NSZ') + " NSZ "
	cQryFrom   +=   " LEFT JOIN " + RetSqlName('NVE') + " NVE "
	cQryFrom   +=          " ON ( NVE.NVE_NUMCAS = NSZ.NSZ_NUMCAS ) "
	cQryFrom   +=         " AND ( NVE.NVE_CCLIEN = NSZ.NSZ_CCLIEN ) "
	cQryFrom   +=         " AND ( NVE.NVE_LCLIEN = NSZ.NSZ_LCLIEN ) "
	cQryFrom   +=         " AND ( NVE.NVE_FILIAL = '" + xFilial('NVE') + "' ) "
	cQryFrom   +=         " AND ( NVE.D_E_L_E_T_ = ' ' ) "

	If lAndamento
		cQryFrom   +=   " LEFT JOIN " + RetSqlName('NT4') + " NT4 "
		cQryFrom   +=          " ON ( NT4.NT4_FILIAL = '" + xFilial('NT4') + "' ) "
		cQryFrom   +=         " AND ( NT4.NT4_CAJURI = NSZ.NSZ_COD ) "
		cQryFrom   +=         " AND ( NT4.D_E_L_E_T_ = ' ' ) "
		cQryFrom   +=   " LEFT JOIN " + RetSqlName('NRO') + " NRO "
		cQryFrom   +=          " ON ( NT4.NT4_CATO = NRO.NRO_COD ) "
		cQryFrom   +=         " AND ( NRO.NRO_FILIAL = '" + xFilial('NR0') + "' ) "
		cQryFrom   +=         " AND ( NRO.D_E_L_E_T_ = ' ' ) "
	EndIf

	//Clausula WHERE
	// Filtar Filiais que o usuário possui acesso
	If ( VerSenha(114) .or. VerSenha(115) )
		cQryWhere := " WHERE NSZ.NSZ_FILIAL IN " + FORMATIN(aFilUsr[1],aFilUsr[2])
	Else
		cQryWhere := " WHERE NSZ.NSZ_FILIAL = '"+xFilial("NSZ")+"' "
	EndIf
	
	// Assuntos jurídicos configurados para o grupo do usuário
	cQryWhere += cWhrTpAsJ

	cQryWhere  +=    " AND NSZ.D_E_L_E_T_ = ' ' "
	 
	 //Restrições do usuário
	cQryWhere  += VerRestricao(,, WsJGetTpAss("'006'" , .T.))
	If !Empty(aSQLRest)
		cQryWhere += " AND ("+Ja162SQLRt(aSQLRest, , , , , , , , , cAssJur)+")"
	EndIf

	// Parâmetros
	If !Empty(cCajuri)
		If !Empty(cRelaciona)
			cQryWhere  +=    " AND NSZ.NSZ_COD <> '"+cCajuri+"' "
			cQryWhere  +=    " AND NSZ.NSZ_FILIAL = '"+cFilCon+"' "
		Else
			cQryWhere  +=    " AND NSZ.NSZ_COD = '"+cCajuri+"' "
		EndIf
	EndIf
	If !Empty(cSituac)		
		cQryWhere  +=    " AND NSZ.NSZ_SITUAC = '"+cSituac+"' "
	EndIf
	// Pesquisa por palavra-chave
	If !Empty(cSearchKey)
		cSearchKey := Lower(StrTran(JurLmpCpo( cSearchKey,.F. ),'#',''))
		//Cajuri
		cExists   := " AND " + JurFormat("NSZ_COD", .T.,.T.) + " LIKE '%" + cSearchKey + "%'"
		cExists   := " AND (" + SUBSTR(JurGtExist(RetSqlName("NSZ"), cExists, "NSZ.NSZ_FILIAL"),5)
		cQryWhere += cExists
		//Número do contrato
		cExists   :=  " AND " + JurFormat("NSZ_NUMCON", .F.,.T.) + " LIKE '%" + cSearchKey + "%'"
		cExists   :=  " OR " + SUBSTR(JurGtExist(RetSqlName("NSZ"), cExists, "NSZ.NSZ_FILIAL"),5)
		cQryWhere += cExists
		//Número do Workflow FLUIG
		cExists   :=  " AND " + JurFormat("NSZ_CODWF", .F.,.T.) + " LIKE '%" + cSearchKey + "%'"
		cExists   :=  " OR " + SUBSTR(JurGtExist(RetSqlName("NSZ"), cExists, "NSZ.NSZ_FILIAL"),5)
		cQryWhere += cExists
		//Caso
		cExists   := " AND " + JurFormat("NT9_NOME", .T.,.T.) + " LIKE '%" + cSearchKey + "%')"
		cExists   := " OR " + SUBSTR(JurGtExist(RetSqlName("NT9"), cExists, "NSZ.NSZ_FILIAL"),5)
		cQryWhere += cExists
	EndIf
	// Define o Filtro aplicado na query
	If cTpFilter == "2" // Cadastrados no mês corrente
		cQryWhere += " AND NSZ.NSZ_DTINCL >= '" + DTOS(FirstDate( Date() )) + "' "
	ElseIf cTpFilter == "3" // Encerrados no mês corrente
		cQryWhere += " AND NSZ.NSZ_DTENCE >= '" + DTOS(FirstDate( Date() )) + "' "
	EndIf

	If !Empty(cExtFilter)
		cQryWhere += " AND " + AddNick(cExtFilter)
	EndIf

	//Clausula ORDER BY
	If lAndamento
		cQryOrder  :=  " ORDER BY NT4_DTANDA DESC "
	Else
		cQryOrder  :=  " ORDER BY NSZ.NSZ_DTTMVI "
	EndIf

	cQuery := ChangeQuery(cQrySelect + cQryFrom + cQryWhere + cQryOrder)

	cQuery := StrTran(cQuery,",' '",",''")

Return cQuery


//-------------------------------------------------------------------
/*/{Protheus.doc} JConvUTF8(cValue)
Formata o valor em UTF8 e retira os espaços

@param nInsta - Numero da Instância

@Return cDesInsta - Descrição da instância

@since 23/03/2020
/*/
//-------------------------------------------------------------------
Static Function JConvUTF8(cValue)
	Local cReturn := ""
	cReturn := JurEncUTF8(Alltrim(cValue))
Return cReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} montaURLFluig(cCodWf)
Monta a URL de acesso ao Workflow no fluig.

@param 	cCodWf      Código do Workflow

@Return cUrlRet     URL do workflow

@since 14/01/2020
/*/
//-------------------------------------------------------------------
WSMETHOD GET montaURLFluig WSRECEIVE codWf WSREST JURCONSULTAS
Local cUrlRet    := ""
Local cUrl       := StrTran(AllTrim(JFlgUrl()), '/webdesk/', '')
Local cEmpresa   := AllTrim(SuperGetMV('MV_ECMEMP' ,,""))
Local cCodWf     := Self:codWf
Local oResponse  := JsonObject():New()

If Empty(cEmpresa)
	cEmpresa := AllTrim(SuperGetMV('MV_ECMEMP2' ,,""))
EndIf

	If !Empty(cUrl) .And. !Empty(cCodWf) .And. !Empty(cEmpresa)
		cUrlRet := cUrl
		cUrlRet += '/portal/p/'
		cUrlRet += cEmpresa
		cUrlRet += '/pageworkflowview?app_ecm_workflowview_detailsProcessInstanceID='
		cUrlRet += cCodWf
	EndIf

	Self:SetContentType("application/json")
	oResponse['urlFluig'] := cUrlRet

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} anexosFluig()
Monta a URL de acesso ao Workflow no fluig.

@param 	cCodWf      Código do Workflow

@Return cUrlRet     URL do workflow

@since 14/01/2020
/*/
//-------------------------------------------------------------------
WSMETHOD GET anexosFluig PATHPARAM cajuri WSREST JURCONSULTAS

Local aArea      := GetArea()
Local cCajuri    := Self:cajuri
Local oResponse  := JsonObject():New()
Local cCriaPasta := ""
Local cLinkNZ7   := ""
Local cCliente   := ""
Local cLoja      := ""
Local cCaso      := "" 
Local oAnexo     := {}

	Self:SetContentType("application/json")

	If SuperGetMV('MV_JFLUIGA',,'2') == '1'

		If !Empty(cCajuri)
			cCliente := Posicione("NSZ", 1, xFilial("NSZ") + cCajuri, "NSZ_CCLIEN")
			cLoja    := Posicione("NSZ", 1, xFilial("NSZ") + cCajuri, "NSZ_LCLIEN")
			cCaso    := Posicione("NSZ", 1, xFilial("NSZ") + cCajuri, "NSZ_NUMCAS")


			If ( AllTrim(SuperGetMv('MV_JDOCUME',,'1')) == '3' ) // Se a integração com o Fluig estiver ativa
				cLinkNZ7 := AllTrim(Posicione("NZ7", 1, xFilial("NZ7") + cCliente + cLoja + cCaso, "NZ7_LINK"))
				If Empty(cLinkNZ7) 
					// Realiza a criação da pasta no Fluig
					cCriaPasta := J070PFluig( cCliente + cLoja + cCaso, "")
					If cCriaPasta == "2"
						cLinkNZ7 := AllTrim(Posicione("NZ7", 1, xFilial("NZ7") + cCliente + cLoja + cCaso, "NZ7_LINK"))
					Endif
				Endif

				If !Empty(cLinkNZ7)
					oAnexo := getAnexo("NSZ", cCajuri)

					oResponse['link']    := SubStr(cLinkNZ7,1,at(";",cLinkNZ7)-1  )
					oResponse['version'] := SubStr(cLinkNZ7  ,at(";",cLinkNZ7)+1,4)
					oResponse['url']     := oAnexo:Abrir(.F.,cLinkNZ7)					
				EndIf
			Endif

		EndIf
	
	EndIf
	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

	RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} getAnexo
Função responsável por identificar qual anexo está sendo utilizado para instanciar a classe

@param cEntidade    - Alias da entidade
@param cCodEnt      - Codigo da entidade

@author SIGAJURI
@since 24/07/2019

/*/
//-------------------------------------------------------------------
Static Function getAnexo(cEntidade, cCodEnt,cCodProc)
	Local cParam  := AllTrim(SuperGetMv('MV_JDOCUME',,'2'))
	Local oAnexo  := Nil

	Default cEntidade := ""
	Default cCodEnt   := ""
	Default cCodProc  := ""

	Do Case
	Case cParam == '1'
		oAnexo := TJurAnxWork():New("WorkSite", cEntidade, xFilial(cEntidade), cCodEnt, 1,cCodProc) //"WorkSite"
	Case cParam == '2'
		oAnexo := TJurAnxBase():NewTHFInterface(cEntidade, cCodEnt, cCodProc) //"Base de Conhecimento"
	Case cParam == '3'
		oAnexo := TJurAnxFluig():New("Documentos em Destaque - Fluig", cEntidade, xFilial(cEntidade), cCodEnt, 1, .F. ) //"Documentos em Destaque - Fluig"
	EndCase


return oAnexo



//-------------------------------------------------------------------
/*/{Protheus.doc} GET graficoInfo
Consulta as informações de valor de contratos em andamento por tipo

@author SIGAJURI
@since 08/04/2020

/*/
//-------------------------------------------------------------------
WSMETHOD GET grafInfoContratos WSREST JURCONSULTAS

Local aArea      := GetArea()
Local cAlias     := GetNextAlias()
Local oResponse  := JsonObject():New()
Local cQuery     := ""
Local aFilUsr    := JURFILUSR( __CUSERID, "NSZ" )
Local nIndexJSon := 0
Local aSQLRestri := Ja162RstUs(,,,.T.)
Local cTpAJ      := JWsLpGtNyb()

	cQuery := " SELECT NSZ.NSZ_CODCON      NSZ_CODCON, "
	cQuery +=        " SUM(NSZ.NSZ_VLCONT) NSZ_VLCONT, "
	cQuery +=        " NY0.NY0_DESC        NY0_DESC "
	cQuery += " FROM " + RetSqlName('NSZ') + " NSZ "
	cQuery += " INNER JOIN " + RetSqlName('NY0') + " NY0 "
	cQuery += " ON NY0.NY0_COD = NSZ.NSZ_CODCON "
	//Verifica os assunto do tipo consultivo e seus respectivos filhos
	cQuery +=   ' AND NSZ.NSZ_TIPOAS IN (' + JurTpAsJr(__CUSERID) + ')'
	cQuery +=   ' AND NSZ.NSZ_TIPOAS IN (' + WsJGetTpAss("'006'") + ')' 
	// Filtar Filiais que o usuário possui acesso
	If ( VerSenha(114) .or. VerSenha(115) )
		cQuery += " AND NSZ.NSZ_FILIAL IN " + FORMATIN(aFilUsr[1],aFilUsr[2])
	Else
		cQuery += " AND NSZ.NSZ_FILIAL = '"+xFilial("NSZ")+"' "
	EndIf

	//Restrições do usuário
	cQuery  += VerRestricao(,, WsJGetTpAss("'006'" , .T.))
	If !Empty(aSQLRestri)
		cQuery +=   " AND ("+Ja162SQLRt(aSQLRestri, , , , , , , , , cTpAJ)+")"
	EndIf
	cQuery += " AND NSZ.NSZ_SITUAC = '1' "
	cQuery += " AND NSZ.D_E_L_E_T_ = ' ' "
	cQuery += " GROUP BY NSZ.NSZ_CODCON, NY0.NY0_DESC "

	cQuery := ChangeQuery(cQuery)
	cQuery := StrTran(cQuery,",' '",",''")

	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

	Self:SetContentType("application/json")
	oResponse['tipos'] := {}

	While (cAlias)->(!Eof())
		nIndexJSon++
		Aadd(oResponse['tipos'], JsonObject():New())
			oResponse['tipos'][nIndexJSon]['id']      := JConvUTF8((cAlias)->NSZ_CODCON)
			oResponse['tipos'][nIndexJSon]['value']   := Round((cAlias)->NSZ_VLCONT,2)
			oResponse['tipos'][nIndexJSon]['name']    := JConvUTF8(AllTrim((cAlias)->NY0_DESC))
		(cAlias)->(DbSkip())
	End	

	(cAlias)->( DbCloseArea() )

	oResponse['length'] := nIndexJSon	
	
	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

	RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} uploadDot
Faz a leitura das variaveis do arquivo .DOT, grava os registros de
relatório e configuração e salva o arquivo.Dot na pasta 

@param 	nOpc        Operacao
@param 	codConfig   Codigo da Configuração
@param 	nomeConfig  nome da Configuração

@example GET-> http://LOCALHOST:8080/rest/JURCONSULTAS/uploadDot?nomeConfig=teste123&nOpc=3&codConfig=3123
@Return logico

@since 09/04/2020
/*/
//-------------------------------------------------------------------
WSMETHOD POST uploadDot WsReceive nOpc,codConfig,nomeConfig WSREST JURCONSULTAS

Local oRequest  := JsonObject():New()
Local oResponse := JsonObject():New()
Local lRet      := .T.

	//inicializando a configuração basica de retorno
	oResponse["lRet"]       := .t.
	oResponse["nStatus"]    := 0
	oResponse["codConfig"]  := ""
	oResponse["MsgRetorno"] := ""

	//Configuração basica da requisição
	oRequest["nomeConfig"] := Self:nomeConfig
	oRequest["codConfig"]  := Self:codConfig
	oRequest["nOpc"]       := Self:nOpc

	oRequest["File"]       := JurSetFile(Self:GetContent())
	
	If getVariaveis(oResponse,oRequest["File"])
		Begin Transaction

			If !GravaRelDot(oResponse,oRequest)
				oResponse["lRet"] := .F.
			ElseIf !GravaConfig(oResponse,oRequest)
				oResponse["lRet"] := .F.
			ElseIf !GravaArqDot(oResponse,oRequest)
				oResponse["lRet"] := .F.
			Endif

			If !oResponse["lRet"]
				DisarmTransaction()
				Break
			Endif
		End Transaction
	Endif

	lRet := oResponse["lRet"]

	If lRet
		oResponse["nStatus"] := 201
		Self:SetResponse(oResponse:toJson())
	Else
		SetRestFault(oResponse["nStatus"], EncodeUTF8(_NoTags(oResponse["MsgRetorno"])))
	Endif

	oResponse:fromJson("{}")
	oResponse := NIL

	oRequest:fromJson("{}")
	oRequest := NIL

Return lRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} JurSetFile
Função responsavel pela montagem do objeto Json contendo os dados do Arquivo Dot

@type Function
@author SIGAJURI
@since 09/04/2020
@version 1.0
@param cBody, character, (Descrição do parâmetro)
@return oFile, Objeto Json contendo dados do Arquvio .Dot
/*/
//------------------------------------------------------------------------------
Function JurSetFile(cBody)
Local oFile     := JsonObject():New()
Local cContent  := HTTPHeader("content-type")
Local cLimite   := SubStr(cContent,At("boundary=",cContent)+9)
Local cLocalArq := AllTrim( SuperGetMV('MV_MODPET',,"") )

	If Empty(cLocalArq)
		cLocalArq := GetSrvProfString("StartPath", "\undefined")
	EndIf

	oFile["filePath"]       :=  cLocalArq
	oFile["fileOldName"]    :=  decodeUTF8(AllTrim(SubStr(cBody,At('filename="',cBody)+10, ;
								At('"',SubStr(cBody,At('filename="',cBody)+10,200))-1)))
	oFile["fileExtension"]  :=  SubStr(oFile["fileOldName"], rAt(".", oFile["fileOldName"]) )
	oFile["fileNewName"]    :=  ""
	oFile["fileContent"]    :=  SubStr(SubStr(SubStr(cBody,;
								At("Content-Type:",;
								cBody)+12),;
								At(Chr(10),;
								SubStr(cBody,At("Content-Type:",cBody)+12))+3),;
								1,;
								At(cLimite,SubStr(SubStr(cBody,At("Content-Type:",cBody)+12),;
								At(Chr(10),;
								SubStr(cBody,At("Content-Type:",cBody)+12))+3))-5)
	oFile["nTamArquivo"]    :=  Len(oFile["fileContent"])
	oFile["variaveis"]      :=  {}

return oFile

//-------------------------------------------------------------------
/*/{Protheus.doc} getVariaveis
Busca as variaveis encontradas no documento enviado, e verifica na tabela de variaveis(NYN)

@since 08/04/2020
@version 1.0
@param oResponse = objeto Json de resposta do WS
@param oFile = objeto Json contendo os dados do arquivo enviado
@return logico = informa se encontrou todas as variaveis lidas no documento
/*/
//-------------------------------------------------------------------
Static Function getVariaveis(oResponse, oFile)
Local aAreaNYN     := NYN->(GetArea())
Local cFilecontent := oFile['fileContent']
Local nTam         := oFile['nTamArquivo']
Local nTamSx3      := TamSx3('NYN_NOME')[1]
Local cPesq        := "DOCVARIABLE"
Local n1           := 0
Local nPosVar      := 0
Local nPosRef      := 1
Local cVariavel    := ''
Local aVarNotFound := {}

	NYN->(DbSetOrder(1))//NYN_FILIAL+NYN_NOME

	While nPosRef <= nTam
		//Verifica se a palavra chave está no texto
		If (SUBSTR(cFileContent,nPosRef,11)) = cPesq
			nPosRef := nPosRef + 13
			
			//Se encontrou, verifica qual posição o próximo caracter igual a espaço, o que significa que acabou o nome da variavel
			nPosVar := AT( " ", cFileContent, nPosRef )
			
			//pega o valor que está entre o final de 'DOCVARIABLE' e o prox caracter igual a espaço
			//EX: 'DOCVARIABLE  OUTORGANTE ' Retorno = OUTORGANTE
			cVariavel := AllTrim(substr(cFileContent, nPosRef, nPosVar - nPosRef))
			cVariavel := strTran(strTran(cVariavel,"'",""),'"','')
		
			If aScan(oFile["variaveis"], cVariavel) == 0 //verifica se já tem a variavel no array
				aAdd(oFile["variaveis"], cVariavel)
				If !NYN->(DbSeek(xFilial('NYN')+Padr(cVariavel,nTamSx3)))
					aAdd(aVarNotFound,cVariavel)
				Endif
			EndIf
		EndIf
		nPosRef++
	EndDo

	If Len(aVarNotFound) > 0
		oResponse["lRet"] := .F.
		oResponse["nStatus"] := 400
		oResponse["MsgRetorno"] := "O arquivo modelo possui variaveis não cadastradas no sistema."
		oResponse["MsgRetorno"] += " Realize o cadastro das mesmas ou verifique se estão corretas no arquivo modelo."
		oResponse["MsgRetorno"] += " Variaveis não encontradas: "
		For n1 := 1 to Len(aVarNotFound)
			oResponse["MsgRetorno"] +=" "+aVarNotFound[n1]+","
		Next
		oResponse["MsgRetorno"] := SubStr(oResponse["MsgRetorno"],1,Len(oResponse["MsgRetorno"])-1 )
		
	Endif

	RestArea(aAreaNYN)
	
	aSize(aAreaNYN    , 0)
	aSize(aVarNotFound, 0)

	aAreaNYN     := NIL
	aVarNotFound := NIL

Return oResponse["lRet"]


//------------------------------------------------------------------------------
/* /{Protheus.doc} GravaRelDot(oResponse,oRequest)
Função responsavel pela gravação do modelo dot ou encontrado o registro correto
@type Static Function
@author jacomo.fernandes
@since 09/04/2020
@version 1.0
@param oResponse, object, Objeto Json contendo os dados de resposta do WS
@param oRequest, object, Objeto Json contendo os dados da requisição do WS
@return logico, retorno lógico caso tenha gravado com sucesso ou encontrado corretamente
/*/
//------------------------------------------------------------------------------
Static Function GravaRelDot(oResponse,oRequest)
Local aAreaNQR := NQR->(GetArea())
Local aAreaNQY := NQY->(GetArea())
Local nOpc     := oRequest["nOpc"]
Local oModel   := nil
Local oMdlNQR  := nil
Local cCodRel  := ""

	If nOpc <> 3 .and. !Empty(oRequest["codConfig"])
		cCodRel := Posicione('NQY',1,xFilial('NQY')+oRequest["codConfig"],"NQY_CRPT")
		cCodRel := Padr(cCodRel,TamSx3("NQR_COD")[1])
	Else
		nOpc := 3
	Endif

	NQR->(DbSetOrder(1))//NQR_FILIAL+NQR_COD

	//Se Inclusão
	If nOpc == 3 .or. (nOpc <> 3 .and. !NQR->(DbSeek(xFilial('NQR')+cCodRel)) )

		oModel  := FwLoadModel('JURA003')
		oMdlNQR := oModel:GetModel("NQRMASTER")

		oModel:SetOperation(nOpc)

		If oModel:Activate()

			If Empty(oMdlNQR:GetValue('NQR_COD'))
				oMdlNQR:SetValue('NQR_COD',GetSxeNum('NQR','NQR_COD'))
			Endif
			
			oMdlNQR:SetValue('NQR_NOMRPT',"JURDTL"+oMdlNQR:GetValue('NQR_COD'))
			oMdlNQR:SetValue('NQR_EXTENS',"2") //.DOT
			

			If oModel:VldData() .and. oModel:CommitData()
				oRequest["File"]["fileNewName"] := AllTrim(oMdlNQR:GetValue('NQR_NOMRPT'))
				oRequest["codRelatorio"]        := oMdlNQR:GetValue('NQR_COD')
			Else
				oResponse["lRet"]       := .F.
				oResponse["nStatus"]    := 400
				oResponse["MsgRetorno"] := JurModErro(oModel)
				lRet := .F.
			Endif

			oModel:DeActivate()
		Endif

		oModel:Destroy()
		FwFreeObj(oModel)
	Else
		oRequest["codRelatorio"]        := cCodRel
		oRequest["File"]["fileNewName"] := AllTrim(Posicione('NQR',1,xFilial('NQR')+cCodRel,"NQR_NOMRPT"))
	Endif

	RestArea(aAreaNQR)
	RestArea(aAreaNQR)

	aSize(aAreaNQR,0)
	aSize(aAreaNQY,0)

	aAreaNQR := Nil
	aAreaNQY := Nil

Return oResponse['lRet']

//------------------------------------------------------------------------------
/* /{Protheus.doc} GravaConfig(oResponse,oRequest)
Função responsavel pela gravação da configuração de relatório
@type Static Function
@author jacomo.fernandes
@since 09/04/2020
@version 1.0
@param oResponse, object, Objeto Json contendo as informações de resposta do WS
@param oRequest, object, Objeto Json contendo as informações da requisição do WS
@return logico, retorno lógico
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function GravaConfig(oResponse,oRequest)
Local oModel     := nil
Local oMdlNQY    := nil
Local oMdlNVL    := nil
Local oMdlNYO    := nil
Local nOpc       := oRequest["nOpc"]
Local n1         := 0
Local aVariaveis := {}
Local aAreaNQY   := NQY->(GetArea())
Local cCodConfig := oRequest["codConfig"]

	If(empty(cCodConfig))
		cCodConfig = ""
	EndIf

	NQY->(DbSetOrder(1))//NQY_FILIAL+NQY_COD

	If nOpc <> 3 .and. !NQY->(DbSeek(xFilial('NQY')+cCodConfig ))
		nOpc := 3
	Endif

	If oResponse["lRet"]
		oModel     := FwLoadModel('JURA014')
		oMdlNQY    := oModel:GetModel("NQYMASTER")
		oMdlNVL    := oModel:GetModel("NVLDETAIL")
		oMdlNYO    := oModel:GetModel("NYODETAIL")

		oModel:SetOperation(nOpc)

		If oModel:Activate()
			If nOpc == 3 .AND. Empty(oMdlNQY:GetValue('NQY_COD'))
				oMdlNQY:SetValue('NQY_COD', GetSxeNum('NQY','NQY_COD'))
			Endif

			If nOpc == 3
				oMdlNQY:SetValue('NQY_DESC'   , oRequest["nomeConfig"]   )
			EndIf
			
			oMdlNQY:SetValue('NQY_CRPT'   , oRequest["codRelatorio"] )

			If !oMdlNVL:SeekLine({{'NVL_CTIPOA',StrZero(6,TamSx3("NVL_CTIPOA")[1])}})
				If !oMdlNVL:IsEmpty() .and. !Empty(oMdlNVL:GetValue('NVL_CTIPOA'))
					oMdlNVL:AddLine()
				Endif
				oMdlNVL:SetValue('NVL_CTIPOA',StrZero(6,TamSx3("NVL_CTIPOA")[1]))
			Endif

			aVariaveis := oRequest["File"]["variaveis"]
			
			For n1 := 1 to Len(aVariaveis)
				If !oMdlNYO:SeekLine({{'NYO_NOMVAR',aVariaveis[n1]}})
					If !oMdlNYO:IsEmpty() .and. !Empty(oMdlNYO:GetValue('NYO_NOMVAR'))
						oMdlNYO:AddLine()
					Endif
					
					oMdlNYO:SetValue('NYO_NOMVAR',aVariaveis[n1])
					oMdlNYO:SetValue('NYO_FLAG'  ,"1")
					
					If !oMdlNYO:VldLineData()
						oResponse["lRet"]   := .F.
						Exit
					Endif
				Endif
			Next

			If Len(aVariaveis) < oMdlNYO:Length()
				For n1 := 1 to oMdlNYO:Length()
					If !oMdlNYO:IsDeleted(n1) .and. ;
						aScan(aVariaveis,AllTrim(oMdlNYO:GetValue('NYO_NOMVAR',n1))) == 0
						
						oMdlNYO:GoLine(n1)
						oMdlNYO:DeleteLine()
					Endif
				Next
			Endif

			If oResponse["lRet"] .and. oModel:VldData() .and. oModel:CommitData()
				oResponse["codConfig"]  := oMdlNQY:GetValue('NQY_COD')
			Else
				oResponse["lRet"]       := .F.
				oResponse["nStatus"]    := 400
				oResponse["MsgRetorno"] := JurModErro(oModel)
			Endif

			oModel:DeActivate()
		Endif

		oModel:Destroy()
		FwFreeObj(oModel)

	Endif

	RestArea(aAreaNQY)
	aSize(aAreaNQY,0)
	aAreaNQY := nil

Return oResponse["lRet"]


//------------------------------------------------------------------------------
/* /{Protheus.doc} GravaArqDot

Faz a gravação da variàvel buffer em arquivo

@param oResponse  Objeto response da requisição
@param oRequest   Objeto da requisição
@since 09/04/2020
@return oResponse
/*/
//------------------------------------------------------------------------------
Static Function GravaArqDot(oResponse,oRequest)
Local nHandle :=  0
Local oFile   := oRequest["File"]

	IF (nHandle := FCREATE(oFile["filePath"] + oFile["fileNewName"] + oFile["fileExtension"]) ) >= 0
		FWRITE(nHandle, oFile["fileContent"], oFile["nTamArquivo"])
		FCLOSE(nHandle)
	Else
		oResponse["lRet"]       := .F.
		oResponse["nStatus"]    := 400
		oResponse["MsgRetorno"] := "Arquivo não criado, FERROR:"+ cValToChar(FERROR())
	Endif

Return oResponse["lRet"]

//-------------------------------------------------------------------
/*/{Protheus.doc} GET DownloadFile
Efetua o download do arquivo .dot cadastrado

@param codConfig      Codigo da Configuração
@author SIGAJURI
@since 15/04/2020

@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/JURCONSULTAS/downloadFile/003

/*/
//-------------------------------------------------------------------
WSMETHOD GET DownloadFile PATHPARAM codConfig WSREST JURCONSULTAS
Local oResponse    := JsonObject():New()
Local lRet         := .T.
Local cCodConfig   := Self:codConfig
Local cCodRelat    := JurGetDados("NQY", 1, xFilial("NQY") + cCodConfig, "NQY_CRPT")
local cNameRel     := AllTrim(JurGetDados("NQR", 1, xFilial("NQR") + cCodRelat, "NQR_NOMRPT"))
Local cLocalArq    := AllTrim( SuperGetMV('MV_MODPET',,"") )

	If Empty(cLocalArq)
		cLocalArq := GetSrvProfString("StartPath", "\undefined")
	EndIf

		//-- Monta Json para o Download
		Self:SetContentType("application/json")
		oResponse['operation']      := "DownloadFiles"
		oResponse['downloadMinuta'] := {}
		Aadd(oResponse['downloadMinuta'], JsonObject():New())

		oResponse['downloadMinuta'][1]['namefile'] := JConvUTF8(cNameRel + ".DOT")
		oResponse['downloadMinuta'][1]['fileurl']          := ""
		oResponse['downloadMinuta'][1]['filedata'] := encode64(DownloadBase(cLocalArq + cNameRel+ ".DOT"))

		Self:SetResponse(oResponse:toJson())
		oResponse:fromJson("{}")
		oResponse := NIL

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GET getWfSLAJur
Busca as consultas finalizados que ainda não foram processadas, para o calculo de SLA.

@param assJur      Tipo de assunto jurídico
@author SIGAJURI
@since 06/05/2020

@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/JURCONSULTAS/getHistoryWF?assJur=006&page=5&pageSize=10

/*/
//-------------------------------------------------------------------
WSMETHOD GET getWfSLAJur PATHPARAM page, pageSize, assJur WSREST JURCONSULTAS
Local aArea      := GetArea()
Local cAlias     := GetNextAlias()
Local cQuery     := ""
Local cAssJur    := Self:assJur
Local nPage      := Self:page
Local nPageSize  := Self:pageSize
Local oResponse  := JsonObject():New()
Local nIndexJSon := 0
Local nQtdRegIni := 0
Local nQtdRegFim := 0
Local nQtdReg    := 0
Local lHasNext   := .F.

Default cAssJur  := "006"
Default nPage      := 1
Default nPageSize  := 10


	Self:SetContentType("application/json")
	oResponse['operation']   := "getWorkflow"
	oResponse['getWorkflow'] := {}

	cQuery := getWfxHist(cAssJur)
	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

	nQtdRegIni := ((nPage-1) * nPageSize)
	// Define o range para inclusão no JSON
	nQtdRegFim := (nPage * nPageSize)
	nQtdReg    := 0

	While (cAlias)->(!Eof()) .And. nQtdReg < nQtdRegFim + 1
		nQtdReg++
		// Verifica se o registro está no range da pagina
		If (nQtdReg > nQtdRegIni .AND. nQtdReg <= nQtdRegFim)
			If J95WFEnd((cAlias)->CODWF) //Verifica se o WF esta encerrado
				nIndexJSon++
				Aadd(oResponse['getWorkflow'], JsonObject():New())

				oResponse['getWorkflow'][nIndexJSon]['filcon'] := (cAlias)->FILIAL
				oResponse['getWorkflow'][nIndexJSon]['codigo'] := (cAlias)->CAJURI
			EndIf
		ElseIf (nQtdReg == nQtdRegFim + 1)
			lHasNext := .T.
		EndIf
		(cAlias)->(DbSkip())
	End

	(cAlias)->( DbCloseArea() )
	// Verifica se há uma proxima pagina
	If (lHasNext)
		oResponse['hasNext'] := "true"
	Else
		oResponse['hasNext'] := "false"
	EndIf
	oResponse['length'] := nQtdReg

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

	RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET procHistWF
Processa o historico, incluindo os andamentos de acordo com as atividades de cada consulta.

@param filConsulta Filial do assunto jurídico
@param cajuri      Código do assunto jurídico
@author SIGAJURI
@since 08/05/2020

@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/JURCONSULTAS/processHistory

/*/
//-------------------------------------------------------------------
WSMETHOD GET procHistWF WSRECEIVE filConsulta, cajuri WSREST JURCONSULTAS
Local aArea      := GetArea()
Local oResponse  := JsonObject():New()
Local cFilCons   := Self:filConsulta
Local cCajuri    := Self:cajuri
local lRet       := .F.
	
	Self:SetContentType("application/json")
	oResponse['operation']   := "historicoWF"
	oResponse['historicoWF'] := {}

	Aadd(oResponse['historicoWF'], JsonObject():New())
	oResponse['historicoWF'][1]['cajuri'] := cCajuri
	oResponse['historicoWF'][1]['filial'] := cFilCons
	lRet :=  J95HisFlu(cFilCons, cCajuri)
	oResponse['lRet']  := lRet
	
	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

	RestArea(aArea)

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} GET getWfxHist
Busca todos os processos que não estejam cancelados, que tenham WF 
e não tenham processado o histórico.

@param cAssJur - Assunto juridico
@return cQuery - retorna a query que busca os registros
@author SIGAJURI
@since 07/05/2020

/*/
//-------------------------------------------------------------------

Static Function getWfxHist(cAssJur)
Local cQuery     := ""
Local aFilUsr    := JURFILUSR( __CUSERID, "NSZ" )

	//Query para buscar todos os processos com workflow que não estejam cancelados
	cQuery := " SELECT NSZ_COD    CAJURI, "
	cQuery +=        " NSZ_FILIAL FILIAL, "
	cQuery +=        " NSZ_CODWF  CODWF "
	cQuery += " FROM " + RetSqlName('NSZ') + " NSZ "
	If cAssJur == '006'
		cQuery += " JOIN " + RetSqlName('NY0') + " NY0 ON "
		cQuery +=        " (NY0_FILIAL = '" + xFilial('NY0') + "' "
		cQuery +=        " AND NY0_COD = NSZ_CODCON "
		cQuery +=        " AND (NY0.NY0_CMOCAN = '   ' or (NY0.NY0_CMOCAN <> '   ' and NY0.NY0_CMOCAN <> NSZ.NSZ_CMOENC)) "
		cQuery +=        " AND NY0.D_E_L_E_T_ = ' ' ) "
	Else
		cQuery += " JOIN " + RetSqlName('NYA') + " NYA ON "
		cQuery +=        " (NYA_FILIAL = '" + xFilial('NYA') + "' "
		cQuery +=        " AND NYA_COD = NSZ_CTPSOL "
		cQuery +=        " AND (NYA.NYA_CMOCAN = '   ' or (NYA.NYA_CMOCAN <> '   ' and NYA.NYA_CMOCAN <> NSZ.NSZ_CMOENC)) "
		cQuery +=        " AND NYA.D_E_L_E_T_ = ' ' ) "
	EndIf
	cQuery += " WHERE NSZ_CODWF != ' ' "
	cQuery +=       " AND NSZ.D_E_L_E_T_ = ' ' "
	cQuery +=       " AND NSZ.NSZ_TIPOAS = '" + cAssJur + "' "

	// Filtar Filiais que o usuário possui acesso
	If ( VerSenha(114) .or. VerSenha(115) )
		cQuery += " AND NSZ_FILIAL IN " + FORMATIN(aFilUsr[1],aFilUsr[2])
	Else
		cQuery += " AND NSZ_FILIAL = '"+xFilial("NSZ")+"' "
	EndIf

	cQuery  +=  " AND NOT EXISTS (SELECT 1 FROM "+RetSqlName("O0Z")+" O0Z "
	cQuery  +=                  " WHERE  O0Z.O0Z_CAJURI = NSZ.NSZ_COD "
	cQuery  +=                         " AND O0Z.O0Z_FILPRO = NSZ.NSZ_FILIAL "
	cQuery  +=                         " AND O0Z.D_E_L_E_T_ = ' ') "

return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} GET getDiasSLA
Busca o SLA em dias do mês corrente

@param assJur    Assunto juridico
@author SIGAJURI
@since 08/05/2020

@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/JURCONSULTAS/slaDias?assJur=006
/*/
//-------------------------------------------------------------------
WSMETHOD GET getDiasSLA PATHPARAM assJur,dataRef WSREST JURCONSULTAS
Local aArea      := GetArea()
Local cAlias     := ""
Local cAssJur    := Self:assJur
Local dDataRef   := If( ValType(Self:dataRef) <> 'U', Stod(Self:dataRef), Date())
Local nDias      := 0
Local oResponse  := JsonObject():New()
Local nQtdProc   := 0
Local nMedia     := 0
Local nHoras     := 0
Local nSegundos  := 0

	cQuery := QrySLA(cAssJur, dDataRef,.F.,.T.)
	
	cAlias := GetNextAlias()
	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )
	While (cAlias)->(!Eof())
		nQtdProc++
		nSegundos += (cAlias)->O0Z_SLASEG
		(cAlias)->(DbSkip())
	End
	(cAlias)->( DbCloseArea() )

	nMedia := nSegundos/nQtdProc       //Média de segundos por mês
	nHoras := Round(nMedia/3600,0)     //Segundos em Horas

	If nHoras >= 7 .and. nHoras < 24 // Se trabalhar pelo menos 7 horas é considado 1 dia.
		nDias := 1
	Else
		nDias := Round(nHoras/24,0)   //Horas em dias de 24 horas úteis
	EndIf

	Self:SetContentType("application/json")
	oResponse['dias'] := nDias

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

	RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} QrySLA()
Calcula o SLA Jurídico em dias.

@param cAssJur    Tipo de assunto jurídico
@param dData      Data do mês/ ano a ser considerado
@param lMesFim    Indica se deve ser considerado o mês fechado
@param lMedia     Indica se a query será extraída para o cálculo da média
@param lTpContra  Indica se deseja saber os tipos de contratos

@since 08/05/2020
/*/
//-------------------------------------------------------------------
Static Function QrySLA(cAssJur, dData, lMesFim, lMedia, lTpContra)
Local aFilUsr    := JURFILUSR( __CUSERID, "NSZ" )
Local cQuery     := ""

Default dData     := Date()
Default lMesFim   := .F.
Default lMedia    := .F.
Default lTpContra := .F.

	If cAssJur == "006"
		If lTpContra
			cQuery := " SELECT DISTINCT  NY0.NY0_DESC "
		Else
			cQuery := " SELECT SUM(O0Z.O0Z_SLASEG)    O0Z_SLASEG, "
			cQuery += "                               NY0.NY0_DESC "
		EndIf
	Else
		If lTpContra
			cQuery := " SELECT DISTINCT  NYA.NYA_DESC "
		Else
			cQuery := " SELECT SUM(O0Z.O0Z_SLASEG)    O0Z_SLASEG, "
			cQuery += "                               NYA.NYA_DESC "
		EndIf
	EndIf	

	cQuery += " FROM " + RetSqlName('O0Z') + " O0Z "
	
	cQuery += " JOIN " + RetSqlName('NSZ') + " NSZ "
	cQuery +=        " ON  NSZ.NSZ_FILIAL  = O0Z.O0Z_FILPRO "
	cQuery +=        " AND NSZ.NSZ_COD     = O0Z.O0Z_CAJURI "
	
	cQuery += " JOIN " + RetSqlName('O10') + " O10 "
	cQuery +=        " ON  O10.O10_FILIAL  = '"+xFilial("O10")+"' "
	cQuery +=        " AND O10.O10_COD     = O0Z.O0Z_CATIVI "
	cQuery +=        " AND O10.D_E_L_E_T_ = ' ' "
	cQuery +=        " AND O10.O10_JURIDI = '1' "

	If cAssJur == "006"
		cQuery += " JOIN " + RetSqlName('NY0') + " NY0 "
		cQuery +=        " ON  NY0.NY0_FILIAL  = '"+xFilial("NY0")+"' "
		cQuery +=        " AND NY0.NY0_COD     = NSZ.NSZ_CODCON "
		cQuery +=        " AND NY0.D_E_L_E_T_ = ' ' "
	Else		
		cQuery += " JOIN " + RetSqlName('NYA') + " NYA "
		cQuery +=        " ON  NYA.NYA_FILIAL  = '"+xFilial("NYA")+"' "
		cQuery +=        " AND NYA.NYA_COD     = NSZ.NSZ_CTPSOL "
		cQuery +=        " AND NYA.D_E_L_E_T_ = ' ' "
	EndIf
		

	cQuery += " WHERE NSZ.NSZ_CODWF <> '' "
	cQuery +=       " AND NSZ.D_E_L_E_T_ = '' "
	cQuery +=       " AND O0Z.D_E_L_E_T_ = '' "
	cQuery +=       " AND NSZ.NSZ_TIPOAS = '" + cAssJur + "' "
	cQuery +=       " AND NSZ.NSZ_DTINCL >= '" + DTOS(FirstDate( dData )) + "' "
	
	If lMesFim
		cQuery +=       " AND NSZ.NSZ_DTINCL <= '" + DTOS(LastDate( dData )) + "' "
	EndIf

	// Filtar Filiais que o usuário possui acesso
	If ( VerSenha(114) .or. VerSenha(115) )
		cQuery += " AND NSZ.NSZ_FILIAL IN " + FORMATIN(aFilUsr[1],aFilUsr[2])
	Else
		cQuery += " AND NSZ.NSZ_FILIAL = '"+xFilial("NSZ")+"' "
	EndIf

	If cAssJur == "006"
		cQuery += " GROUP BY NY0.NY0_DESC "
	Else 
		cQuery += " GROUP BY NYA.NYA_DESC "
	EndIf

	If lMedia
		cQuery += ", NSZ.NSZ_COD "
	EndIf

	cQuery := ChangeQuery(cQuery)
	cQuery := StrTran(cQuery,",' '",",''")
	
Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} GET graficoEsf
Busca o Esforço do juridico em horas do mes (intervalo de 12 meses)

@param assJur    Tipo de assunto jurídico
@author SIGAJURI
@since 08/05/2020

@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/JURCONSULTAS/esforcoChartData?assJur=006
/*/
//-------------------------------------------------------------------
WSMETHOD GET grafEsforco PATHPARAM assJur, dataRef WSREST JURCONSULTAS

Local aArea      := GetArea()
Local cAlias     := ""
Local cAssJur    := Self:assJur
Local dDataRef   := If( Valtype(Self:dataRef) <> 'U', StoD(Self:dataRef), Date())
Local nHoras     := 0
Local nSegundos  := 0
Local nIntervalo := 11
Local dData      := ""
Local cData      := ""
Local oResponse  := JsonObject():New()
Local nIndexJSon := 0
Local cAno       := ""
Local cMes       := ""
Local cQuery     := ""

	
	Self:SetContentType("application/json")
	oResponse['esforco'] := {}

	While nIntervalo >= 0

		dData := SToD( JurDtAdd(  DToS(dDataRef), "M", (nIntervalo * -1) ) )

		cAlias := GetNextAlias()
		cQuery := QrySLA(cAssJur, dData,.T.)
		DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )
		If (cAlias)->(!Eof())
			nSegundos := (cAlias)->O0Z_SLASEG
		EndIf
		(cAlias)->( DbCloseArea() )

		nHoras := Round(nSegundos/3600,1) // Segundos em Horas

		cMes := SubStr(DToS(dData),5,2)
		cAno := SubStr(DToS(dData),1,4)
		nIndexJSon++
		Aadd(oResponse['esforco'], JsonObject():New())
		oResponse['esforco'][nIndexJSon]['horas']  := nHoras
		oResponse['esforco'][nIndexJSon]['ano']    := cAno
		oResponse['esforco'][nIndexJSon]['mes']    := cMes
		
		nHoras := 0
		cData := ""
		nIntervalo--
	End

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

	RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET grafSLA
Busca o SLA juridico em dias do mes (intervalo de 12 meses)

@param assJur    Tipo de assunto jurídico
@param dataRef   Data de referencia para busca 
@param lAuto     Informa se veio da automação
@author SIGAJURI
@since 08/05/2020

@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/JURCONSULTAS/slaChartData?assJur=006
/*/
//-------------------------------------------------------------------
WSMETHOD GET grafSLA PATHPARAM assJur, dataRef, lAuto WSREST JURCONSULTAS
Local aArea      := GetArea()
Local oResponse  := JsonObject():New()
Local cAssJur    := Self:assJur
Local lAuto      := Self:lAuto
Local dDataRef   := If( ValType(Self:dataRef) <> 'U', Stod(Self:dataRef), Date())
Local dData      := ""
Local cAno       := ""
Local cMes       := ""
Local cMesAno    := ""
Local cQuery     := ""
Local cAliasQtd  := ""
Local cSqlQtd    := ""
Local cTpContra  := ""
Local nIndexJSon := 1
Local nHoras     := 0
Local nI         := 0
Local nQtdProc   := 0
Local nDias      := 0
Local nMedia     := 0
Local nPosQtdDia := 0
Local nIntervalo := 11
Local aSLATpCont := {}
Local aQtdDiaPro := {}
Local cCmpTpDesc := ""

Default lAuto:= .F.
	Self:SetContentType("application/json")
	oResponse['sla'] := {}
	
	While nIntervalo >= 0
		Aadd(oResponse['sla'], JsonObject():New())

		dData := SToD( JurDtAdd(  DToS(dDataRef), "M", (nIntervalo * -1) ) )

		cAliasQtd := GetNextAlias()

		If cAssJur == "006"
			cSqlQtd    := "SELECT COUNT(1) QTD, NY0_DESC FROM ( "
			cSqlQtd    +=     QrySLA(cAssJur, dData,.T.,.T.)
			cSqlQtd    += ") QUANTIDADE "
			cSqlQtd    += "GROUP BY NY0_DESC"
			cCmpTpDesc := "NY0_DESC"
		Else 
			cSqlQtd   := "SELECT COUNT(1) QTD, NYA_DESC FROM ( "
			cSqlQtd   +=     QrySLA(cAssJur, dData,.T.,.T.)
			cSqlQtd   += ") QUANTIDADE "
			cSqlQtd   += "GROUP BY NYA_DESC"
			cCmpTpDesc := "NYA_DESC"
		EndIf
		
		DbUseArea( .T., "TOPCONN", TCGenQry(,,cSqlQtd), cAliasQtd, .F., .F. )

		While (cAliasQtd)->(!Eof())
			Aadd(aQtdDiaPro, { &("(cAliasQtd)->"+cCmpTpDesc) , (cAliasQtd)->QTD })
			(cAliasQtd)->( DbSkip() )
		End
		
		(cAliasQtd)->( DbCloseArea() )

		cQuery := QrySLA(cAssJur, dData,.T.,.F.)
		DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAliasQtd, .F., .F. )
		
		While (cAliasQtd)->(!Eof())
			If Len(aQtdDiaPro) > 0
				nPosQtdDia := Ascan( aQtdDiaPro, {|x| x[1] == &("(cAliasQtd)->"+cCmpTpDesc) } )
				nQtdProc   := aQtdDiaPro[nPosQtdDia][2]
			EndIf
			Aadd(aSLATpCont, { &("(cAliasQtd)->"+cCmpTpDesc) , (cAliasQtd)->O0Z_SLASEG , nQtdProc })
			(cAliasQtd)->( DbSkip() )
		End

		(cAliasQtd)->( DbCloseArea() )

		cMesAno := If(lAuto,'mesAno_','')+SubStr(DToS(dData),5,2) + SubStr(DToS(dData),1,4)
		cMes    := SubStr(DToS(dData),5,2)
		cAno    := SubStr(DToS(dData),1,4)

		oResponse['sla'][nIndexJSon][cMesAno] := {}

		If Len(aSLATpCont) > 0
			For nI := 1 to Len(aSLATpCont)
				cTpContra := JConvUTF8(aSLATpCont[nI][1])        // Tipo de contrato
				nMedia    := aSLATpCont[nI][2]/aSLATpCont[nI][3] // Média de segundos por mês
				nHoras    := Round(nMedia/3600,0)                // Segundos em Horas
				
				If nHoras >= 7 .and. nHoras < 24 // Se trabalhar pelo menos 7 horas é considado 1 dia.
					nDias := 1
				Else
					nDias := Round(nHoras/24,0)                 //Horas em dias de 24 horas úteis
				EndIf

				Aadd(oResponse['sla'][nIndexJSon][cMesAno], JsonObject():New())
				aTail(oResponse['sla'][nIndexJSon][cMesAno])['tipoContrato'] := cTpContra
				aTail(oResponse['sla'][nIndexJSon][cMesAno])['dias']         := nDias
			Next
		Else
			Aadd(oResponse['sla'][nIndexJSon][cMesAno], JsonObject():New())
			aTail(oResponse['sla'][nIndexJSon][cMesAno])['tipoContrato'] := ""
			aTail(oResponse['sla'][nIndexJSon][cMesAno])['dias']         := nDias
		EndIf

		nMedia    := 0
		nHoras    := 0
		nDias     := 0

		nIndexJSon++
		nIntervalo--
		Asize( aSLATpCont, 0 )
		Asize( aQtdDiaPro, 0 )
	End

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

	RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET tpContSLA
Busca o tipo de contrato para o cálculo do SLA.

@param assJur    Tipo de assunto jurídico

@since 27/05/2020

@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/JURCONSULTAS/slaTpContr?assJur=006
/*/
//-------------------------------------------------------------------
WSMETHOD GET tpContrSLA PATHPARAM assJur WSREST JURCONSULTAS
Local aArea      := GetArea()
Local oResponse  := JsonObject():New()
Local cAssJur    := Self:assJur
Local dData      := ""
Local cQuery     := ""
Local nI         := 0
Local nIntervalo := 11
Local aRetSQL    := {}

	Self:SetContentType("application/json")
	oResponse['tpContratoSLA'] := {}

	dData := SToD( JurDtAdd(  DToS(Date()), "M", (nIntervalo * -1) ) )
	cQuery := QrySLA(cAssJur, dData,.F.,.F.,.T.)
	aRetSQL := JurSQL(cQuery,'*')
	
	For nI := 1 To Len(aRetSQL)
		Aadd(oResponse['tpContratoSLA'], JsonObject():New())
		oResponse['tpContratoSLA'][nI]['tpContrato'] := JConvUTF8(aRetSQL[nI][1])
	Next

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

	RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET procWFIncons
Processa os registros que não possuem WF correspondente no Fluig, incluindo o SLA (O0Z) zerado para o cajuri.

@param filConsulta Filial do assunto jurídico
@param cajuri      Código do assunto jurídico

@since 27/05/2020

@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/JURCONSULTAS/procWFInconsis

/*/
//-------------------------------------------------------------------
WSMETHOD GET procWFIncons WSRECEIVE filConsulta, cajuri WSREST JURCONSULTAS
Local aArea      := GetArea()
Local oResponse  := JsonObject():New()
Local cFilCons   := Self:filConsulta
Local cCajuri    := Self:cajuri

	Self:SetContentType("application/json")
	oResponse['operation']   := "wfIgnorados"
	oResponse['WFInconsistente'] := {}

	Aadd(oResponse['WFInconsistente'], JsonObject():New())
	oResponse['WFInconsistente'][1]['cajuri'] := cCajuri
	oResponse['WFInconsistente'][1]['filial'] := cFilCons

	oResponse['lRet']  := GrvSLAJur(cFilCons, cCajuri)

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

	RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvSLAJur(cFilPro, cProcesso)
Grava o SLA Jurídico

@param cFilPro    Filial do processo
@param cProcesso  Cód. do Assunto Jurídico

@Return .T.
@since 27/05/2020
/*/
//-------------------------------------------------------------------
Static Function GrvSLAJur(cFilPro, cProcesso)

Local aArea      := GetArea()
Local aAreaO0Z   := O0Z->( GetArea() )
Local lRet       := .F.

	dbSelectArea("O0Z")
	O0Z->(dbSetOrder( 2 )) //O0Z_FILIAL+O0Z_FILPRO+O0Z_CAJURI+O0Z_CATIVI

	If ! ( O0Z->( dbSeek( xFilial( 'O0Z' )+cFilPro+cProcesso ) ) )

		lRet := Reclock( "O0Z", .T. )
					O0Z->O0Z_COD    := GETSXENUM("O0Z","O0Z_COD",,1)
					O0Z->O0Z_FILPRO := cFilPro
					O0Z->O0Z_CAJURI := cProcesso
					O0Z->O0Z_CATIVI := ""
					O0Z->O0Z_SLASEG := 0
				O0Z->(MsUnLock())

		If __lSX8
			ConfirmSX8()
		EndIf

	EndIf

	O0Z->(dbCloseArea())

	RestArea(aAreaO0Z)
	RestArea(aArea)

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} GET areaSolicSLA
Busca area solicitante dos workflows processados.

@param assJur     - Tipo de assunto jurídico
@param tpContrato - Código do Tipo de contrato

@since 03/06/2020

@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/JURCONSULTAS/slaAreaSolic?assJur=006
/*/
//-------------------------------------------------------------------
WSMETHOD GET areaSolicSLA PATHPARAM assJur, tpContrato WSREST JURCONSULTAS
Local oResponse  := JsonObject():New()
Local cAssJur    := Self:assJur
Local cTpContr   := Self:tpContrato
Local dData      := ""
Local cQuery     := ""
Local nI         := 0
Local nCount     := 1
Local nIntervalo := 5
Local aRetSQL    := {}

	Self:SetContentType("application/json")
	oResponse['areaSolicSLA'] := {}

	dData   := SToD( JurDtAdd(  DToS(Date()), "M", (nIntervalo * -1) ) )
	cQuery  := QryFlxHoras(cAssJur, dData, 2, , , cTpContr)
	aRetSQL := JurSQL(cQuery,'*')
	
	For nI := 1 To Len(aRetSQL)
		If Round(aRetSQL[nI][3]/3600,0) > 0
			Aadd(oResponse['areaSolicSLA'], JsonObject():New())
			oResponse['areaSolicSLA'][nCount]['codAreaSolic'] := JConvUTF8(aRetSQL[nI][1])
			oResponse['areaSolicSLA'][nCount]['desAreaSolic'] := JConvUTF8(aRetSQL[nI][2])
			nCount++
		EndIf
	Next

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET grafFlxJur
Função que apresenta as atividades, tipos de contrato e horas por fluxo do dept. jurídico e
tipo de contrato dos WFs processados.

@param assJur       - Tipo de assunto jurídico
@param tpContrato   - Informe os tipos de contratos
@param areaSolic    - Informe as areas solicitante
@param dtInicial    - Informe o período inicial de busca
@param dtFinal      - Informe o período final de busca

@since 04/06/2020

@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/JURCONSULTAS/slaChartFluxo?assJur=006
/*/
//-------------------------------------------------------------------
WSMETHOD GET grafFlxJur PATHPARAM assJur, tpContrato, areaSolic, dtInicial, dtFinal;
WSREST JURCONSULTAS

Local oResponse  := JsonObject():New()
Local cAssJur    := Self:assJur
Local cTpContr   := Self:tpContrato
Local cAreaSolic := Self:areaSolic
Local dDtInic    := Self:dtInicial
Local dDtFinal   := Self:dtFinal
Local dData      := ''
Local cQuery     := ''
Local nI         := 0
Local nCount     := 1
Local aRetSQL    := {}

	Self:SetContentType("application/json")

	If Empty(dDtFinal) .And. Empty(dDtInic)
		dData := SToD( JurDtAdd(  DToS(Date()), "M", -2 ) )
	EndIf

	cQuery  := QryFlxHoras(cAssJur, dData, 4, dDtInic, dDtFinal, cTpContr, cAreaSolic)
	aRetSQL := JurSQL(cQuery,'*')

	oResponse['atividades'] := {}
	For nI := 1 To Len( aRetSQL )
		
		If Round(aRetSQL[nI][3]/3600,0) > 0
			Aadd(oResponse['atividades'], JsonObject():New())

			oResponse['atividades'][nCount]['codAtividade']  := JConvUTF8(aRetSQL[nI][1])
			oResponse['atividades'][nCount]['descAtividade'] := JConvUTF8(aRetSQL[nI][2])

			nCount++
		EndIf
	Next

	cQuery  := ''
	nCount  := 1
	oResponse['tpContrato'] := {}
	aSize(aRetSQL,0)

	cQuery  := QryFlxHoras(cAssJur, dData, 3, dDtInic, dDtFinal, cTpContr, cAreaSolic)
	aRetSQL := JurSQL(cQuery,'*')

	For nI := 1 To Len( aRetSQL )

		If Round(aRetSQL[nI][3]/3600,0) > 0
			Aadd(oResponse['tpContrato'], JsonObject():New())

			oResponse['tpContrato'][nCount]['codTpCont']  := JConvUTF8(aRetSQL[nI][1])
			oResponse['tpContrato'][nCount]['descTpCont'] := JConvUTF8(aRetSQL[nI][2])
			
			nCount++
		EndIf
	Next

	cQuery  := ''
	oResponse['graphFluxoJur'] := {}
	aSize(aRetSQL,0)

	cQuery  := QryFlxHoras(cAssJur, dData, 0, dDtInic, dDtFinal, cTpContr, cAreaSolic)
	aRetSQL := JurSQL(cQuery,'*')
	
	For nI := 1 To Len( aRetSQL )
		Aadd(oResponse['graphFluxoJur'], JsonObject():New())
		oResponse['graphFluxoJur'][nI]['descTpCont'] := JConvUTF8(aRetSQL[nI][1])
		oResponse['graphFluxoJur'][nI]['descFluxo']  := JConvUTF8(aRetSQL[nI][2])
		oResponse['graphFluxoJur'][nI]['horas']      := Round(aRetSQL[nI][3]/3600,0)
	Next

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET grafAreaSoli
Nos últimos 6 meses, apresenta por mês a quantidade de horas das áreas solicitantes.

@param assJur       - Tipo de assunto jurídico
@param tpContrato   - Informe os tipos de contratos
@param dDataRef     - Informe a data de referncia da busca
@param lAuto        - Informe se veio da automação

@since 05/06/2020

@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/JURCONSULTAS/slaChartArea?assJur=006
/*/
//-------------------------------------------------------------------
WSMETHOD GET grafAreaSoli PATHPARAM assJur, tpContrato, dataRef, lAuto WSREST JURCONSULTAS

Local oResponse  := JsonObject():New()
Local cAssJur    := Self:assJur
Local cTpContr   := Self:tpContrato
Local lAuto      := Self:lAuto
Local dDataRef   := If( ValType(Self:dataRef) <> 'U', Stod(Self:dataRef), Date())
Local nIntervalo := 5
Local dData      := ''
Local cQuery     := ''
Local cMesAno    := ''
Local nI         := 0
Local nIndexJSon := 1
Local aRetSQL    := {}
Default lAuto    := .F.

	Self:SetContentType("application/json")
	oResponse['graphAreaSolic'] := {}
	
	While nIntervalo >= 0
		Aadd(oResponse['graphAreaSolic'], JsonObject():New())

		dData := SToD( JurDtAdd(  DToS(dDataRef), "M", (nIntervalo * -1) ) )
		
		
		cQuery  := QryFlxHoras(cAssJur, dData, 1, , , cTpContr,'',.T.)
		aRetSQL := JurSQL(cQuery,'*')

		cMesAno := If(lAuto,'mesAno_','')+SubStr(DToS(dData),5,2) + SubStr(DToS(dData),1,4)
		
		oResponse['graphAreaSolic'][nIndexJSon][cMesAno] := {}
		
		For nI := 1 To Len( aRetSQL )
			Aadd(oResponse['graphAreaSolic'][nIndexJSon][cMesAno], JsonObject():New())
			aTail(oResponse['graphAreaSolic'][nIndexJSon][cMesAno])['descAreaSolic'] := JConvUTF8(aRetSQL[nI][1])
			aTail(oResponse['graphAreaSolic'][nIndexJSon][cMesAno])['horas']         := Round(aRetSQL[nI][2]/3600,0)
		Next

		nIndexJSon++
		nIntervalo--
		Asize( aRetSQL, 0 )
	End

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} QryFlxHoras(cAssJur, dData, nTpPesq, dDtInic, dDtFinal,
							  cTpContr, cAreaSolic)

Apresenta a quantidade de segundos dos WFs processados por área solicitante,
fluxo do dept. jurídico ou tipo de contrato.

@param cAssJur      - Tipo de assunto jurídico
@param nTpPesq      - Qual tipo de Consulta deseja descobrir os tipos?
					  0 - Busca os segundos por fluxo de trabalho do jurídico
					  1 - Busca os segundos por área solicitante do jurídico
					  2 - Area do Solicitante
					  3 - Tipo Contrato
					  4 - Atividade do Dept. Jurídico
@param dDtInic      - Informe o período inicial de busca
@param dtFinal      - Informe o período final de busca
@param cTpContr     - Informe os tipos de contratos/ solicitações
@param cAreaSolic   - Informe as areas jurídicas
@param lMesFim      - Indica se deve ser considerado o mês fechado

@return cQuery      - Retorna a query que será consulta no banco de dados

@since 03/06/2020
/*/
//-------------------------------------------------------------------
Static Function QryFlxHoras(cAssJur, dData, nTpPesq, dDtInic, dDtFinal,;
							cTpContr, cAreaSolic, lMesFim)

Local aFilUsr    := JURFILUSR( __CUSERID, "NSZ" )
Local cQuery     := ''
Local aTpContr   := ''
Local aAreaSolic := ''
Local nI         := 0

Default dData      := Date()
Default dDtInic    := ""
Default dDtFinal   := ""
Default lMesFim    := .F.

	Do Case
		Case nTpPesq == 0
			If cAssJur == "006"
				cQuery := "SELECT NY0.NY0_DESC, O10.O10_ATIVID, "
			ElseIf cAssJur == "005"
				cQuery := "SELECT NYA.NYA_DESC, O10.O10_ATIVID, "
			EndIf
			cQuery +=     "SUM(O0Z.O0Z_SLASEG) O0Z_SLASEG "

		Case nTpPesq == 1
			cQuery := "SELECT NRB.NRB_DESC, SUM(O0Z.O0Z_SLASEG) O0Z_SLASEG "

		Case nTpPesq == 2
			cQuery := " SELECT DISTINCT NRB.NRB_COD, NRB.NRB_DESC, "
			cQuery +=     "SUM(O0Z.O0Z_SLASEG) O0Z_SLASEG "

		Case nTpPesq == 3
			If cAssJur == "006"
				cQuery := " SELECT DISTINCT NY0.NY0_COD,NY0.NY0_DESC, "
			ElseIf cAssJur == "005"
				cQuery := " SELECT DISTINCT NYA.NYA_COD,NYA.NYA_DESC, "
			EndIf
			cQuery +=     "SUM(O0Z.O0Z_SLASEG) O0Z_SLASEG "

		Case nTpPesq == 4
			cQuery := " SELECT DISTINCT O10.O10_COD,O10.O10_ATIVID, "
			cQuery +=     "SUM(O0Z.O0Z_SLASEG) O0Z_SLASEG "
	EndCase

	cQuery += " FROM " + RetSqlName('O0Z') + " O0Z "
	
	cQuery += " JOIN " + RetSqlName('NSZ') + " NSZ "
	cQuery +=        " ON  NSZ.NSZ_FILIAL  = O0Z.O0Z_FILPRO "
	cQuery +=        " AND NSZ.NSZ_COD     = O0Z.O0Z_CAJURI "
	
	cQuery += " JOIN " + RetSqlName('O10') + " O10 "
	cQuery +=        " ON  O10.O10_FILIAL  = '" + xFilial("O10") + "' "
	cQuery +=        " AND O10.O10_COD     = O0Z.O0Z_CATIVI "
	cQuery +=        " AND O10.D_E_L_E_T_ = ' ' "
	cQuery +=        " AND O10.O10_JURIDI = '1' "

	If !Empty(cAreaSolic) .Or. nTpPesq == 2 .Or. nTpPesq == 1
		cQuery += " JOIN " + RetSqlName('NRB') + " NRB "
		cQuery +=        " ON  NRB.NRB_FILIAL  = '" + xFilial("NRB") + "' "
		cQuery +=        " AND NRB.NRB_COD     = NSZ.NSZ_CAREAJ "
		cQuery +=        " AND NRB.D_E_L_E_T_ = ' ' "
	EndIf

	If cAssJur == "006"
		cQuery += " JOIN " + RetSqlName('NY0') + " NY0 "
		cQuery +=        " ON  NY0.NY0_FILIAL  = '"+xFilial("NY0")+"' "
		cQuery +=        " AND NY0.NY0_COD     = NSZ.NSZ_CODCON "
		cQuery +=        " AND NY0.D_E_L_E_T_ = ' ' "
	Else		
		cQuery += " JOIN " + RetSqlName('NYA') + " NYA "
		cQuery +=        " ON  NYA.NYA_FILIAL  = '"+xFilial("NYA")+"' "
		cQuery +=        " AND NYA.NYA_COD     = NSZ.NSZ_CTPSOL "
		cQuery +=        " AND NYA.D_E_L_E_T_ = ' ' "
	EndIf

	cQuery += " WHERE NSZ.NSZ_CODWF <> '' "
	cQuery +=       " AND NSZ.D_E_L_E_T_ = '' "
	cQuery +=       " AND O0Z.D_E_L_E_T_ = '' "
	cQuery +=       " AND NSZ.NSZ_TIPOAS = '" + cAssJur + "' "

	// Filtar Filiais que o usuário possui acesso
	If ( VerSenha(114) .or. VerSenha(115) )
		cQuery += " AND NSZ.NSZ_FILIAL IN " + FORMATIN(aFilUsr[1],aFilUsr[2])
	Else
		cQuery += " AND NSZ.NSZ_FILIAL = '"+xFilial("NSZ")+"' "
	EndIf

	Do Case
		Case !Empty(dDtInic) .And. Empty(dDtFinal)
			cQuery +=       " AND NSZ.NSZ_DTINCL >= '" + dDtInic + "' "

		Case Empty(dDtInic) .And. !Empty(dDtFinal)
			cQuery +=       " AND NSZ.NSZ_DTINCL <= '" + dDtFinal + "' "
		
		Case !Empty(dDtInic) .And. !Empty(dDtFinal)
			cQuery +=       " AND NSZ.NSZ_DTINCL <= '" + dDtFinal + "' "
			cQuery +=       " AND NSZ.NSZ_DTINCL >= '" + dDtInic + "' "
		
		Otherwise
			cQuery +=       " AND NSZ.NSZ_DTINCL >= '" + DTOS(FirstDate( dData )) + "' "

			If lMesFim
				cQuery +=       " AND NSZ.NSZ_DTINCL <= '" + DTOS(LastDate( dData )) + "' "
			EndIf
	EndCase

	If !Empty(cTpContr)
		aTpContr := STRTOKARR( cTpContr, ',' )
		cTpContr := ''
		
		For nI := 1 to LEN(aTpContr)
			If nI > 1
				cTpContr += ",'"+ aTpContr[nI] + "'"
			Else
				cTpContr += "'"+ aTpContr[nI] + "'"
			EndIf
		Next
		If cAssJur == "006"
			cQuery +=       " AND NSZ.NSZ_CODCON IN (" + cTpContr + ") "
		Else
			cQuery +=       " AND NSZ.NSZ_CTPSOL IN (" + cTpContr + ") "
		EndIf
	EndIf

	If !Empty(cAreaSolic)
		aAreaSolic := STRTOKARR( cAreaSolic, ',' )
		cAreaSolic := ''
		
		For nI := 1 to LEN(aAreaSolic)
			If nI > 1
				cAreaSolic += ",'"+ aAreaSolic[nI] + "'"
			Else
				cAreaSolic += "'"+ aAreaSolic[nI] + "'"
			EndIf
		Next

		cQuery +=       " AND NSZ.NSZ_CAREAJ IN (" + cAreaSolic + ") "
	EndIf

	cQuery += " GROUP BY "
	
	Do Case
		Case nTpPesq == 0
			If cAssJur == '006'
				cQuery += "O10.O10_ATIVID, NY0.NY0_DESC"
			ElseIf cAssJur == '005'
				cQuery += "O10.O10_ATIVID, NYA.NYA_DESC"
			EndIf
		Case nTpPesq == 1
			cQuery += "NRB.NRB_DESC"

		Case nTpPesq == 2
			cQuery += "NRB.NRB_COD, NRB.NRB_DESC "

		Case nTpPesq == 3
			If cAssJur == '006'
				cQuery += "NY0.NY0_COD, NY0.NY0_DESC"
			ElseIf cAssJur == '005'
				cQuery += "NYA.NYA_COD, NYA.NYA_DESC"
			EndIf
		Case nTpPesq == 4
			cQuery += "O10.O10_COD, O10.O10_ATIVID"
	EndCase

	cQuery := ChangeQuery(cQuery)
	cQuery := StrTran(cQuery,",' '",",''")
	
Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} QryGrupoUsu()
Monta a query de consulta dos grupos de usuarios (NZX)

@param cUsuario    Código do participante
@param cAcaoGrp    Ação a ser realizada no grupo de usuário

@return cQuery     Query a ser executada

@since 03/06/2020
/*/
//-------------------------------------------------------------------
Static Function QryGrupoUsu(cUsuario, cAcaoGrp)
Local cQuery     := ""

	cQuery := " SELECT NZX.NZX_FILIAL, "
	cQuery +=        " NZX.NZX_COD, "
	cQuery +=        " NZX.NZX_DESC, "
	cQuery +=        " NZX.NZX_TIPOA, "
	cQuery +=        " COUNT(NZY_CUSER) QTD_USR "
	cQuery += " FROM " + RetSqlName('NZX') + " NZX "
	cQuery += " LEFT JOIN " + RetSqlName('NZY') + " NZY "
	cQuery +=        " ON NZX.NZX_COD = NZY.NZY_CGRUP "
	cQuery +=        " AND NZY.D_E_L_E_T_ = ' ' "

	If !Empty(cUsuario)
		cQuery += " WHERE  NZX_COD "
		If cAcaoGrp == "associar"
			cQuery += " NOT "
		EndIf
		cQuery += " IN ( "
		cQuery +=      " SELECT NZY.NZY_CGRUP "
		cQuery +=      " FROM " + RetSqlName('NZY') + " NZY "
		cQuery +=      " WHERE  NZY_CUSER = '"+ cUsuario +"' "
		cQuery +=        " AND  NZY.D_E_L_E_T_ = ' ' ) "
		cQuery += " AND NZX.D_E_L_E_T_ = ' ' "
	EndIf

	cQuery += " GROUP BY NZX_FILIAL, NZX.NZX_COD, NZX.NZX_DESC, NZX_TIPOA "

	cQuery := ChangeQuery(cQuery)
	cQuery := StrTran(cQuery,",' '",",''")
	
Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} GET grpAssociado
Busca os grupos de associados a um usuário.

@param partic     Código do participante
@param cAcaoGrp   Ação a ser realizada no grupo de usuário
@param codUser    Código do usuário

@since 03/06/2020

@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/JURCONSULTAS/userGroups

/*/
//-------------------------------------------------------------------
WSMETHOD GET grpAssociado WSRECEIVE partic, acaoGrp, codUser WSREST JURCONSULTAS
Local oResponse  := JsonObject():New()
Local cQuery     := ""
Local aRetSQL    := {}
Local cPartic    := self:partic
Local cAcaoGrp   := self:acaoGrp
Local cUsuario   := self:codUser
Local nI         := 1
Local aTpAssJur  := {}

Default cUsuario := ""

	If Empty(cUsuario)
		cUsuario   := Posicione("RD0",1,xFilial("RD0")+cPartic, "RD0_USER")
	Endif
	
	Self:SetContentType("application/json")
	oResponse['grupos'] := {}

	cQuery := QryGrupoUsu(cUsuario, cAcaoGrp)
	
	aRetSQL := JurSQL(cQuery,'*')

	For nI := 1 To Len(aRetSQL)
		// Busca os assuntos jurídicos que o grupo dá acesso
		aTpAssJur := AssJurGrupo(aRetSQL[nI][2])

		Aadd(oResponse['grupos'], JsonObject():New())
		oResponse['grupos'][nI]['filial']    := aRetSQL[nI][1]
		oResponse['grupos'][nI]['codigo']    := JConvUTF8(aRetSQL[nI][2])
		oResponse['grupos'][nI]['descricao'] := JConvUTF8(aRetSQL[nI][3])
		oResponse['grupos'][nI]['acesso']    := JConvUTF8(aRetSQL[nI][4])
		oResponse['grupos'][nI]['qtdUsr']    := aRetSQL[nI][5] 
		oResponse['grupos'][nI]['tpAssJur']  := JConvUTF8(aTpAssJur[1]) // Descrição Tp Ass Juridico
		oResponse['grupos'][nI]['codAssJur'] := JConvUTF8(aTpAssJur[2]) // Código Tp Ass Juridico
	Next nI
	
	oResponse['length'] := Len(aRetSQL)

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} AssJurGrupo()
Busca os assuntos jurídicos que um determinado grupo de usuários dá acesso

@param cGrupo      Código do grupo

@return cTpAssJur  Descrição dos tipos de assuntos jurídicos separados por ","
		cCodTpAsJ  Código dos tipos de assuntos jurídicos separados por "/"
@since 08/06/2020
/*/
//-------------------------------------------------------------------
Static Function AssJurGrupo(cGrupo)
Local aArea     := GetArea()
Local cAlias    := GetNextAlias()
Local cQuery    := ""
Local cTipo     := ""
Local nTam      := 0
Local cTpAssJur      := ""
Local lNVKNvCmp := .F.
Local cCodTpAsJ := ""

	//Verifica se o campo NVK_CASJUR existe no dicionário
	If Select("NVK") > 0
		lNVKNvCmp := (NVK->(FieldPos('NVK_CASJUR')) > 0)
	Else
		DBSelectArea("NVK")
			lNVKNvCmp := (NVK->(FieldPos('NVK_CASJUR')) > 0)
		NVK->( DBCloseArea() )
	EndIf

	cQuery := " SELECT DISTINCT(NVJ.NVJ_CASJUR) CASJUR, "
	cQuery +=        " NYB.NYB_DESC             NYB_DESC "
	cQuery += " FROM " + RetSqlName("NVJ") + " NVJ , "
	cQuery +=            RetSqlName("NVK") + " NVK , "
	cQuery +=            RetSqlName("NZY") + " NZY , "
	cQuery +=            RetSqlName("NYB") + " NYB   "
	cQuery += "WHERE NVJ.NVJ_FILIAL = " + ValToSQL(xFilial("NVJ"))
	cQuery +=  " AND NVK.NVK_FILIAL = " + ValToSQL(xFilial("NVK"))
	cQuery +=  " AND NZY.NZY_FILIAL = " + ValToSQL(xFilial("NZY"))
	cQuery +=  " AND NYB.NYB_FILIAL = " + ValToSQL(xFilial("NYB"))
	cQuery +=  " AND NVK.NVK_CPESQ = NVJ.NVJ_CPESQ "
	cQuery +=  " AND NVK.NVK_CGRUP = '"+cGrupo+"' "
	cQuery +=  " AND NYB.NYB_COD = NVJ.NVJ_CASJUR "
	cQuery +=  " AND NVK.D_E_L_E_T_ = ' '"
	cQuery +=  " AND NVJ.D_E_L_E_T_ = ' '"
	cQuery +=  " AND NZY.D_E_L_E_T_ = ' '"
	cQuery +=  " AND NYB.D_E_L_E_T_ = ' '"

	If lNVKNvCmp

		cQuery += " UNION "

		cQuery += " SELECT DISTINCT( NVK.NVK_CASJUR ) CASJUR, "
		cQuery += "        NYB.NYB_DESC               NYB_DESC "
		cQuery += " FROM " + RetSqlName("NVK") + " NVK , "
		cQuery +=            RetSqlName("NYB") + " NYB   "
		cQuery += " WHERE NYB.NYB_FILIAL = " + ValToSQL(xFilial("NYB"))
		cQuery +=   " AND NYB.NYB_COD = NVK.NVK_CASJUR "
		cQuery +=   " AND NYB.D_E_L_E_T_ = ' ' "
		cQuery +=   " AND NVK.NVK_FILIAL = " + ValToSQL(xFilial("NVK"))
		cQuery +=   " AND NVK.NVK_CGRUP  = " + ValToSQL(cGrupo)
		cQuery +=   " AND NVK.D_E_L_E_T_ = ' ' "

	EndIf

	cQuery := ChangeQuery(cQuery)
	cQuery := StrTran(cQuery,",' '",",''")

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

	If !(cAlias)->( EOF() )
 		While !(cAlias)->( EOF() )
			cTipo += " " + AllTrim((cAlias)->NYB_DESC) + ","
			cCodTpAsJ += (cAlias)->CASJUR+"/"
			
			(cAlias)->( dbSkip() )
		End
	EndIf

	nTam := Len(AllTrim(cTipo))

	If nTam > 0
		cTpAssJur := SubStr(AllTrim(cTipo),1,nTam-1)
	EndIf

	(cAlias)->( dbcloseArea() )
	RestArea( aArea )
	
Return {cTpAssJur, cCodTpAsJ}

//-------------------------------------------------------------------
/*/{Protheus.doc} GET extFields
Retorna a lista de campos customizados e campos obrigatorios de um modelo.

@param searchKey   Tabela que se deseja estrutura
@param assJur      Tipo de assunto jurídico

@since 17/06/2020

@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/JURCONSULTAS/extraFields

/*/
//-------------------------------------------------------------------
WSMETHOD GET extFields WSRECEIVE searchKey, assJur, isValid WSREST JURCONSULTAS
Local oResponse  := JsonObject():New()
Local oStruct    := Nil
Local alCampos   := {}
Local alObrigat  := {}
Local aAux       := {}
Local aTables    := {}
Local aAssuntos  := {}
Local aCustomFds := {}
Local csearchKey := self:searchKey
Local cTpAssJur  := self:assJur
Local nQtd       := 0
Local nI         := 1
Local nX         := 1
Local nY         := 1
Local cTpAssPai  := cTpAssJur
Local lValid     := Self:isValid == 'true' .Or. Self:isValid == Nil

	If Empty( csearchKey )
		csearchKey := 'NSZ'
	EndIf

	If Empty(cTpAssJur)
		cTpAssJur := '001'
	EndIf

	aTables    := StrToKArr(csearchKey, "|")
	aAssuntos  := StrToKArr(cTpAssJur, "|")

	// Se o tipo de assunto for filho, busca o código do assunto pai, se não possuir um pai, utiliza ele mesmo
	If cTpAssJur > '050' 
		cTpAssPai := JurGetDados('NYB', 1, xFilial('NYB') + cTpAssJur, 'NYB_CORIG')
		If Empty(cTpAssPai)
			cTpAssPai := cTpAssJur
		Endif
	Endif

	// Busca campos da NUZ
	For nI := 1 To Len(aTables)
		For nX := 1 To Len(aAssuntos)
			alCampos := aClone( J95NuzCpo(aAssuntos[nX], aTables[nI], .F., .F.) )
			aAdd(alObrigat, aClone( J95NuzCpo(aAssuntos[nX],aTables[nI],.F., .T.) )) 
			aAdd( aCustomFds, { aTables[nI], aClone(alCampos) } ) // Tabela e campos
		Next nX
	Next nI

	aSize(alCampos, 0)

	// Monta a estrutura do modelo, para campos que são obrigatórios ou custom.
	For nI := 1 To Len(aCustomFds)
		If lValid
			oStruct  := FWFormStruct(2, aCustomFds[nI][1], ;
				{ | cCampo | ;
					getSx3Cache(cCampo, 'X3_VISUAL') != 'V'; // É editável
					.And. ( x3Obrigat( cCampo ); // É obrigatório no dicionário
							.Or. (aScan(alObrigat[nI], cCampo) > 0); // É obrigatório no perfil
							.Or. ( (aScan(aCustomFds[nI][2], cCampo) > 0 ); // Está na NUZ
									.And. ( ( aCustomFds[nI][1] == 'NSZ' ); // É da NSZ
											.Or. ('_X' $ cCampo ) .Or. ( '__' $ cCampo ); // É um campo customizado
										  );
								 );
						  );
				};
			)
		Else
			oStruct  := FWFormStruct( 2, aCustomFds[nI][1],;
				{ | cCampo |;
					x3Obrigat(cCampo); // É um campo obrigatório
					.Or. aScan(aCustomFds[nI][2],cCampo) > 0 } ) // Está na NUZ
		EndIf

		JGetNmFld(oStruct, cTpAssJur, cTpAssPai)
		aAdd(alCampos, aClone(oStruct:aFields))
	Next nI
	
	Self:SetContentType("application/json")
	oResponse['custom'] := {}

	// Pega os campos que são obrigatórios ou customizados
	For nI := 1 To Len(alCampos)

		Aadd(oResponse['custom'], JsonObject():New())
		oResponse['custom'][nI]['campos']  := {}

		// Obtem os campos de cada tabela
		For nX := 1 To Len(alCampos[nI])
			
			Aadd(oResponse['custom'][nI]['campos'], JsonObject():New())
			oResponse['custom'][nI]['campos'][nX]['tabela']      := getSx3Cache(alCampos[nI][nX][1] ,'X3_ARQUIVO')
			oResponse['custom'][nI]['campos'][nX]['campo']       := alCampos[nI][nX][1]
			oResponse['custom'][nI]['campos'][nX]['tamanho']     := getSx3Cache(alCampos[nI][nX][1] ,'X3_TAMANHO')
			oResponse['custom'][nI]['campos'][nX]['titulo']      := JConvUTF8(alCampos[nI][nX][3])
			oResponse['custom'][nI]['campos'][nX]['agrupamento'] := alCampos[nI][nX][12]
			oResponse['custom'][nI]['campos'][nX]['isCustom']    := ('_X' $ alCampos[nI][nX][1] ) .Or. ( '__' $ alCampos[nI][nX][1] )
			oResponse['custom'][nI]['campos'][nX]['required']    := JVlObrigat( cTpAssJur, alCampos[nI][nX][1] , cTpAssPai )
			oResponse['custom'][nI]['campos'][nX]['isVirtual']   := alCampos[nI][nX][16]

			// Campos combobox
			If !Empty(getSx3Cache(alCampos[nI][nX][1] ,'X3_CBOX'))
				oResponse['custom'][nI]['campos'][nX]['tipo']    := 'CB'
				oResponse['custom'][nI]['campos'][nX]['opcoes']  := {}

				// Guarda as opções dos combobox
				For nY := 1 To Len(alCampos[nI][nX][13])
					If Empty(alCampos[nI][nX][13][nY])
						loop
					EndIf
					
					
					If Len(alCampos[nI][nX][13]) > 0
						aAux := StrToKArr(alCampos[nI][nX][13][nY], '=')
					EndIf

					Aadd(oResponse['custom'][nI]['campos'][nX]['opcoes'], JsonObject():New())
					aTail(oResponse['custom'][nI]['campos'][nX]['opcoes'])['label'] := IIF( Len(aAux) > 1, JConvUTF8(aAux[2]), "")
					aTail(oResponse['custom'][nI]['campos'][nX]['opcoes'])['value'] := IIF( Len(aAux) > 0, aAux[1], "")
				Next nY

			// Campos F3
			ElseIf !Empty(getSx3Cache(alCampos[nI][nX][1] ,'X3_F3'))
				oResponse['custom'][nI]['campos'][nX]['tipo']     := 'F3'
				oResponse['custom'][nI]['campos'][nX]['XB_ALIAS'] := AllTrim(getSx3Cache(alCampos[nI][nX][1],'X3_F3'))

			// Demais campos
			Else
				oResponse['custom'][nI]['campos'][nX]['tipo']    := getSx3Cache(alCampos[nI][nX][1] ,'X3_TIPO')
			EndIf

			nQtd++
		Next nX
	Next nI
	
	oResponse['length'] := nQtd

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

	aSize(alCampos, 0)
	aSize(aCustomFds[1], 0)

Return .T.

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} GET vldUsuarioAssJur
Método responsável por validar se o usuário possui vínculo com assuntos jurídicos
ou tipo de acesso.

@param usersGrupo - Usuários do Grupo de assunto jurídico
@param assJur     - Assuntos jurídicos
@param codGrupo   - Código do Grupo de usuário
@param tpAcesso   - Tipo de acesso do grupo

@since 23/07/2020

@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/JURCONSULTAS/vldUsuxAssJur

/*/
//-----------------------------------------------------------------------------------
WSMETHOD GET vldUsuarioAssJur WSRECEIVE usersGrupo, assJur, codGrupo, tpAcesso WSREST JURCONSULTAS
Local oResponse  := JsonObject():New()
Local cUsrGrp    := Self:usersGrupo
Local cAssJur    := Self:assJur
Local cCodGrp    := Self:codGrupo
Local cTpAcesso  := Self:tpAcesso
Local cQuery     := ''
Local cNomeUsr   := ''
Local cNomeGrupo := ''
Local cDesAssJur := ''
Local cMsgTLegal := ''
Local nI         := 1
Local nCont      := 0
Local aRetSQL    := {}
Local aUsrsGrp   := {}
Local aAssJur    := {}
Local lValida    := .F.

	aUsrsGrp := If(!Empty(cUsrGrp), StrToKArr( cUsrGrp, ','), {})
	aAssJur  := If(!Empty(cAssJur), StrToKArr( cAssJur, ','), {})

	cUsrGrp := ''
	If Len(aUsrsGrp) > 0
		For nI := 1 to Len(aUsrsGrp)
			If nI > 1
				cUsrGrp += ",'"+ aUsrsGrp[nI] + "'"
			Else
				cUsrGrp += "'"+ aUsrsGrp[nI] + "'"
			EndIf
		Next
	EndIf

	cAssJur := ''
	If Len(aAssJur) > 0
		For nI := 1 to Len(aAssJur)
			If nI > 1
				cAssJur += ",'"+ aAssJur[nI] + "'"
			Else
				cAssJur += "'"+ aAssJur[nI] + "'"
			EndIf
		Next
	EndIf
	
	Self:SetContentType("application/json")
	oResponse['UserxAssJur'] := {}
	oResponse['length']      := 0

	J218VldUsr( cUsrGrp, cCodGrp, .F., .T., cTpAcesso, @cMsgTLegal) //Valida se o usuário tem tipo de acesso diferente do grupo.

	If Empty(cMsgTLegal)
		If !Empty(cAssJur)
			cQuery    := VldUserGrp( cUsrGrp, cAssJur )
			aRetSQL   := JurSQL(cQuery,'*')

			For nI := 1 to Len(aRetSQL)

				If Empty(cCodGrp)
					lValida := (aRetSQL[nI][2] == 0 .AND. aRetSQL[nI][3] == 1)
				Else
					lValida := (aRetSQL[nI][2] == 0 .AND. aRetSQL[nI][3] == 1 .AND. !(aRetSQL[nI][5] == cCodGrp))
				EndIf

				If lValida
					cNomeUsr   := JConvUTF8(UsrRetName(aRetSQL[nI][4]))
					cDesAssJur := JurGetDados('NYB', 1, xFilial('NYB') + aRetSQL[nI][1], 'NYB_DESC' )
					cNomeGrupo := JurGetDados('NZX', 1, xFilial('NZX') + aRetSQL[nI][5], 'NZX_DESC' )
					nCont := nCont + 1
					Aadd(oResponse['UserxAssJur'], JsonObject():New())
					oResponse['UserxAssJur'][nCont]['tipoAcessOk'] := .T.
					oResponse['UserxAssJur'][nCont]['assJuridico'] := JConvUTF8(cDesAssJur)
					oResponse['UserxAssJur'][nCont]['codUser']     := aRetSQL[nI][2]
					oResponse['UserxAssJur'][nCont]['nomeUser']    := cNomeUsr
					oResponse['UserxAssJur'][nCont]['nomeGrupo']   := JConvUTF8(cNomeGrupo)
					oResponse['length'] := nCont
				EndIf
			Next
		EndIf
	Else
		Aadd(oResponse['UserxAssJur'], JsonObject():New())
		oResponse['UserxAssJur'][1]['tipoAcessOk'] := .F.
		oResponse['UserxAssJur'][1]['msgTpAcesso'] := cMsgTLegal
		
		oResponse['length'] := 1
	EndIf

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} VldUserGrp()
Monta a query para consultar se os usuários do grupo já tem vinculo
com os assuntos jurídicos

@param cUsrGrp      Usuários do grupo
@param cAssJur      Assuntos jurídicos

@return cRet       Query 
@since 30/07/2020
/*/
//-------------------------------------------------------------------
Static Function VldUserGrp( cUsrGrp, cAssJur )

Local aArea      := GetArea()
Local cQuery     := ""
Local lNVKCasJur := .F.

	// Verifica se o campo NVK_CASJUR existe no dicionário
	If Select("NVK") > 0
		lNVKCasJur := (NVK->(FieldPos('NVK_CASJUR')) > 0)
	Else
		DBSelectArea("NVK")
			lNVKCasJur := (NVK->(FieldPos('NVK_CASJUR')) > 0)
		NVK->( DBCloseArea() )
	EndIf

	If lNVKCasJur
		cQuery += " SELECT * "
		cQuery += " FROM   ( "

		cQuery += " SELECT NVK.NVK_CASJUR CASJUR, "
		cQuery +=        " 1 NVK_CASJUR, "
		cQuery +=        " 0 CPESQ, "
		cQuery +=        " NZY.NZY_CUSER  CUSER, "
		cQuery +=        " NZY.NZY_CGRUP  CGRUP "
		cQuery += " FROM   " + RetSqlName("NVK") + " NVK "
		cQuery +=        " JOIN " + RetSqlName("NZY") + " NZY "
		cQuery +=          " ON NZY.NZY_CGRUP = NVK.NVK_CGRUP "
		cQuery +=             " AND NZY.NZY_CUSER IN ( " + cUsrGrp + " ) 
		cQuery +=             " AND NVK.NVK_CASJUR IN ( " + cAssJur + " ) 
		cQuery +=             " AND NVK.NVK_CPESQ = '' "
		cQuery +=             " AND NVK.D_E_L_E_T_ = ' ' "
		cQuery +=             " AND NZY.D_E_L_E_T_ = ' ' "
		cQuery +=             " AND NVK.NVK_FILIAL = '" + xFilial("NVK") + "' "
		cQuery +=             " AND NZY.NZY_FILIAL = '" + xFilial("NZY") + "' "
		cQuery += " UNION "
		cQuery += " SELECT NVJ.NVJ_CASJUR CASJUR, "
		cQuery +=        " 0 NVK_CASJUR, "
		cQuery +=        " 1 CPESQ, "
		cQuery +=        " NZY.NZY_CUSER  CUSER, "
		cQuery +=        " NZY_CGRUP      CGRUP "
		cQuery += " FROM   " + RetSqlName("NVK") + " NVK "
		cQuery +=        " JOIN " + RetSqlName("NZY") + " NZY "
		cQuery +=          " ON NZY.NZY_CGRUP = NVK.NVK_CGRUP "
		cQuery +=             " AND NZY_CUSER IN ( " + cUsrGrp + " ) "
		cQuery +=             " AND NZY.D_E_L_E_T_ = ' ' "
		cQuery +=             " AND NVK.D_E_L_E_T_ = ' ' "
		cQuery +=             " AND NZY.NZY_FILIAL = '" + xFilial("NZY") + "' "
		cQuery +=             " AND NVK.NVK_FILIAL = '" + xFilial("NVK") + "' "
		cQuery +=        " JOIN " + RetSqlName("NVJ") + " NVJ "
		cQuery +=          " ON NVJ.NVJ_CPESQ = NVK_CPESQ "
		cQuery +=             " AND NVJ.NVJ_CASJUR IN ( " + cAssJur + " ) "
		cQuery +=             " AND NVJ.D_E_L_E_T_ = ' ' "
		cQuery +=             " AND NVJ.NVJ_FILIAL = '" + xFilial("NVJ") + "' " 
		cQuery += " GROUP  BY NVJ.NVJ_CASJUR, "
		cQuery +=           " NZY.NZY_CUSER, "
		cQuery +=           " NZY_CGRUP "
		cQuery += " UNION "
		cQuery += " SELECT NVJ.NVJ_CASJUR CASJUR, "
		cQuery +=        " 0 NVK_CASJUR, "
		cQuery +=        " 0 CPESQ, "
		cQuery +=        " NVK.NVK_CUSER  CUSER, "
		cQuery +=        " NVK.NVK_CGRUP  CGRUP "
		cQuery += " FROM   " + RetSqlName("NVK") + " NVK "
		cQuery +=        " JOIN " + RetSqlName("NVJ") + " NVJ "
		cQuery +=          " ON NVJ.NVJ_CPESQ IN (SELECT NVK_CPESQ "
		cQuery +=                               " FROM   " + RetSqlName("NVK")
		cQuery +=                               " WHERE  NVK_CUSER IN ( " + cUsrGrp + " ) "
		cQuery +=                               " AND    D_E_L_E_T_ = ' '  "
		cQuery +=                               " AND    NVK_FILIAL = '" + xFilial("NVK") + "' ) "
		cQuery +=             " AND NVJ.NVJ_CASJUR IN ( " + cAssJur + " ) "
		cQuery +=             " AND NVK.NVK_CUSER IN ( " + cUsrGrp + " ) "
		cQuery +=             " AND NVJ.D_E_L_E_T_ = ' ' "
		cQuery +=             " AND NVK.D_E_L_E_T_ = ' ' "
		cQuery +=             " AND NVJ.NVJ_FILIAL = '" + xFilial("NVJ") + "' "
		cQuery +=             " AND NVK.NVK_FILIAL = '" + xFilial("NVK") + "' "
		cQuery += " ) A "

		cQuery += " ORDER  BY CUSER "
	EndIf

	RestArea( aArea )

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} WsJurCWhrAtv(cFiltro, cMembros)
Monta a clausula WHERE de acordo com o filtro a ser aplicado no painel de atividades

@param cFiltro      Nome do filtro 
@param cMembros     Código do participante a ser filtrado

@return cWhere      Clausula WHERE
@since 14/08/2020
/*/
//-------------------------------------------------------------------

Function WsJurCWhrAtv(cFiltro, cMembros)

Local cWhere     := ""

	If !Empty(cFiltro)
		cWhere += " EXISTS ( "

		Do Case
		Case cFiltro == "MINHAS TAREFAS"
			cWhere += " SELECT 1 "
			cWhere += " FROM   " + RetSqlName("NTA") + " NTAM "
			cWhere +=        " JOIN " + RetSqlName("NTE") + " NTEM "
			cWhere +=          " ON ( NTEM.NTE_CFLWP = NTAM.NTA_COD "
			cWhere +=               " AND NTEM.NTE_FILIAL = '" + xFilial("NTE") + "' "
			cWhere +=               " AND NTEM.D_E_L_E_T_ = ' ' ) "
			cWhere +=        " JOIN " + RetSqlName("RD0") + " RD0M "
			cWhere +=          " ON ( RD0M.RD0_CODIGO = NTEM.NTE_CPART "
			cWhere +=               " AND RD0M.RD0_USER = '" + __CUSERID + "' "
			cWhere +=               " AND RD0M.RD0_FILIAL = '" + xFilial("RD0") + "' "
			cWhere +=               " AND RD0M.D_E_L_E_T_ = ' ' ) "
			cWhere += " WHERE  NTAM.NTA_COD = NTA.NTA_COD "
			cWhere +=        " AND NTAM.NTA_FILIAL = NTA.NTA_FILIAL "
			cWhere +=        " AND NTEM.NTE_CPART = NTE.NTE_CPART "

		Case cFiltro == "FAVORITOS"
			cWhere += " SELECT 1 "
			cWhere += " FROM   " + RetSqlName("NTA") + " NTAF "
			cWhere +=        " JOIN " + RetSqlName("O0V") + " O0V "
			cWhere +=          " ON ( O0V.O0V_USER = '" + __CUSERID + "' "
			cWhere +=               " AND O0V.O0V_CAJURI = NTAF.NTA_CAJURI "
			cWhere +=               " AND O0V.O0V_FILCAJ = NTAF.NTA_FILIAL "
			cWhere +=               " AND O0V.D_E_L_E_T_ = ' ' ) "
			cWhere += " WHERE  NTAF.NTA_COD = NTA.NTA_COD "
			cWhere +=        " AND NTAF.NTA_FILIAL = NTA.NTA_FILIAL "

		Case cFiltro == "MINHA EQUIPE"
			cWhere += QryMinhaEquipe(cFiltro)

		Case cFiltro == "PROCESSOS QUE CUIDO"
			cWhere += " SELECT 1 "
			cWhere += " FROM   " + RetSqlName("NTA") + " NTAA "
			cWhere +=        " JOIN " + RetSqlName("NSZ") + " NSZA "
			cWhere +=          " ON ( NSZA.NSZ_COD = NTAA.NTA_CAJURI "
			cWhere +=               " AND NSZA.NSZ_FILIAL = NTAA.NTA_FILIAL "
			cWhere +=               " AND NSZA.D_E_L_E_T_ = ' ' ) "
			cWhere +=        " JOIN " + RetSqlName("RD0") + " RD01 "
			cWhere +=          " ON ( RD01.RD0_USER = '" + __CUSERID + "' "
			cWhere +=               " AND RD01.RD0_FILIAL = '" + xFilial("RD0") + "' "
			cWhere +=               " AND RD01.D_E_L_E_T_ = ' ' ) "
			cWhere += " WHERE  ( NSZA.NSZ_CPART1 = RD01.RD0_CODIGO "
			cWhere +=           " OR NSZA.NSZ_CPART2 = RD01.RD0_CODIGO "
			cWhere +=           " OR NSZA.NSZ_CPART3 = RD01.RD0_CODIGO ) "
			cWhere +=        " AND NTAA.NTA_COD = NTA.NTA_COD "
			cWhere +=        " AND NTAA.NTA_FILIAL = NTA.NTA_FILIAL "

		Otherwise
			cWhere += QryMinhaEquipe(cFiltro)
		End Case

		cWhere += "	) "
	EndIf

Return cWhere

//-------------------------------------------------------------------
/*/{Protheus.doc} QryMinhaEquipe(cFiltro)
Monta a clausula Where de Equipes

@param cFiltro      Nome do filtro 

@return cWhere      Clausula WHERE
@since 14/08/2020
/*/
//-------------------------------------------------------------------
Static Function QryMinhaEquipe(cFiltro)

Local cQuery    := ""

	cQuery += " SELECT 1 "
	cQuery += " FROM   " + RetSqlName("NTA") + " NTAE "
	cQuery +=        " JOIN " + RetSqlName("NTE") + " NTEE "
	cQuery +=          " ON ( NTEE.NTE_CFLWP = NTAE.NTA_COD "
	cQuery +=             " AND NTEE.NTE_FILIAL = NTAE.NTA_FILIAL " 
	cQuery +=             " AND NTEE.D_E_L_E_T_ = ' ' )"
	cQuery += " WHERE  NTEE.NTE_CPART IN ( "
	If cFiltro == "MINHA EQUIPE"
		cQuery += JQryEquipe(.T.)
	Else
		cQuery += "'"+cFiltro+"'"
	EndIf
	cQuery +=                                  " ) "
	cQuery +=        " AND NTAE.NTA_COD = NTA.NTA_COD "
	cQuery +=        " AND NTAE.NTA_FILIAL = NTA.NTA_FILIAL "
	cQuery +=        " AND NTEE.NTE_CPART = NTE.NTE_CPART "


Return cQuery

//------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GET equipe
Busca os membros da equipe do usuário logado

@since 03/06/2020

@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/JURCONSULTAS/teamMembers
/*/
//------------------------------------------------------------------------------------------------------------------
WSMETHOD GET equipe WSRECEIVE showMySelf WSREST JURCONSULTAS
Local oResponse  := JsonObject():New()
Local cQuery     := ""
Local nI         := 0
Local aRetSQL    := 0
Local lMySelf    := Self:showMyself
Default lMySelf  := .F.

	Self:SetContentType("application/json")
	oResponse['membros'] := {}

	cQuery  := JQryEquipe(,,lMySelf)
	aRetSQL := JurSQL(cQuery,'*')

	oResponse['length'] := Len(aRetSQL)

	For nI := 1 To Len(aRetSQL)
		Aadd(oResponse['membros'], JsonObject():New())
		oResponse['membros'][nI]['codigo'] := JConvUTF8(aRetSQL[nI][1])
		oResponse['membros'][nI]['nome'] := JConvUTF8(aRetSQL[nI][2])
		oResponse['membros'][nI]['codUser'] := JConvUTF8(aRetSQL[nI][3])
	Next

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.


//------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} JQryEquipe()
Monta a query para obter os membros da equipe de um usuário

@param WhrEquipe      Indica se retorna somente a clausula WHERE da consulta
@param lLider         Indica se retorna também o lider
@param lMySelf        Indica se retorna também o usuário logado

@return cQuery       Query 
@since 15/08/2020
/*/
//------------------------------------------------------------------------------------------------------------------
Function JQryEquipe(lWhrEquipe, lLider, lMySelf)
Local cQuery       := ""
Default lWhrEquipe := .F.
Default lLider     := .F.
Default lMySelf    := .F.

	If !lWhrEquipe
		cQuery += " SELECT RD0_CODIGO, RD0_NOME, RD0_USER FROM " + RetSqlName("RD0")
		cQuery += " WHERE RD0_CODIGO IN ( "
	EndIf

	// Retorna também o líder da equipe
	If lLider
		cQuery += "SELECT NZ8_CPARTL "
		cQuery += "  FROM " + RetSqlName("NZ8") + " NZ8_L "
		cQuery +=  " JOIN " + RetSqlName("NZ9") + " NZ9_L "
		cQuery +=    " ON ( NZ8_L.NZ8_FILIAL = '" + xFilial("NZ8") + "' "
		cQuery +=        " AND NZ8_COD = NZ9_CEQUIP "
		cQuery +=        " AND NZ9_L.D_E_L_E_T_ = ' ' ) "
		cQuery +=  " JOIN " + RetSqlName("RD0") + " RD0_L "
		cQuery +=    " ON ( NZ9_CPART = RD0_L.RD0_CODIGO "
		cQuery +=        " AND RD0_L.RD0_FILIAL = '" + xFilial("NZ8") + "' "
		cQuery +=        " AND NZ8_L.D_E_L_E_T_ = ' ' ) "
		cQuery += "WHERE NZ8_L.D_E_L_E_T_ = ' ' "
		cQuery +=  " AND NZ8_L.NZ8_FILIAL = '" + xFilial("NZ8") + "' "
		cQuery +=  " AND RD0_L.RD0_USER = '" + __CUSERID + "' "

		cQuery += " UNION "
	EndIf

	// Abaixo hierarquicamente do usuário logado
	cQuery += " SELECT NZ9_CPART "
	cQuery += " FROM " + RetSqlName("NZ9") + " NZ9A "
	cQuery +=        " JOIN " + RetSqlName("NZ8") + " NZ8 "
	cQuery +=          " ON ( NZ8.NZ8_COD = NZ9A.NZ9_CEQUIP "
	cQuery +=               " AND NZ8.NZ8_FILIAL = '" + xFilial("NZ8") + "' "
	cQuery +=               " AND NZ8.D_E_L_E_T_ = ' ' ) "
	cQuery +=        " JOIN " + RetSqlName("RD0") + " RD0A "
	cQuery +=          " ON ( RD0A.RD0_CODIGO = NZ8.NZ8_CPARTL "
	cQuery +=               " AND RD0A.RD0_USER = '" + __CUSERID + "' "
	cQuery +=               " AND RD0A.RD0_FILIAL = '" + xFilial("RD0") + "' "
	cQuery +=               " AND RD0A.D_E_L_E_T_ = ' ' ) "
	cQuery += " WHERE  NZ9A.NZ9_FILIAL = '" + xFilial("NZ9") + "' "
	cQuery +=        " AND NZ9A.D_E_L_E_T_ = ' ' "

	cQuery += " UNION "
	// Mesmo nível hierarquico que o usuário logada "
	cQuery += " SELECT DISTINCT NZ9_CPART "
	cQuery += " FROM   " + RetSqlName("NZ9") + " NZ9 "
	cQuery +=        " JOIN " + RetSqlName("RD0") + " RD0 "
	cQuery +=          " ON ( RD0.RD0_CODIGO = NZ9.NZ9_CPART "
	If !lMySelf
		cQuery +=               " AND RD0.RD0_USER <> '" + __CUSERID + "' "
	Endif
	cQuery +=               " AND RD0.RD0_FILIAL = '" + xFilial("RD0") + "' "
	cQuery +=               " AND RD0.D_E_L_E_T_ = ' ' ) "
	cQuery += " WHERE  EXISTS ("
	cQuery +=              " SELECT 1 "
	cQuery +=                " FROM   " + RetSqlName("NZ9") + " NZ9B "
	cQuery +=                       " JOIN " + RetSqlName("RD0") + " RD0B "
	cQuery +=                         " ON ( RD0B.RD0_CODIGO = NZ9B.NZ9_CPART "
	cQuery +=                              " AND RD0B.RD0_USER = '" + __CUSERID + "' "
	cQuery +=                              " AND RD0B.RD0_FILIAL = '" + xFilial("RD0") + "' "
	cQuery +=                              " AND RD0B.D_E_L_E_T_ = ' ' ) "
	cQuery +=                " WHERE  NZ9B.NZ9_FILIAL = '" + xFilial("NZ9") + "' "
	cQuery +=                       " AND NZ9B.D_E_L_E_T_ = ' ' "
	cQuery +=                       " AND NZ9.NZ9_CEQUIP = NZ9B.NZ9_CEQUIP"
	cQuery +=                    " ) "
	cQuery +=        " AND NZ9.NZ9_FILIAL = '" + xFilial("NZ9") + "' "
	cQuery +=        " AND NZ9.D_E_L_E_T_ = ' ' "

	If lMySelf
		cQuery += " UNION "
		cQuery +=  " SELECT RD0_CODIGO FROM " + RetSqlName("RD0") + " RD0 "
		cQuery +=  " WHERE RD0.RD0_FILIAL = '" + xFilial("RD0") + "' "		
		cQuery +=        " AND RD0.RD0_USER = '" + __CUSERID + "' "
		cQuery +=        " AND RD0.D_E_L_E_T_ = ' ' "
	EndIf

	If !lWhrEquipe
		cQuery += " ) "
	EndIf

Return cQuery

//------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GET getTemplate
Método responsável por buscar os modelos para cadastro de processos.

@param searchKey - Código do modelo 
@param assJur    - Assunto jurídico
@param filtraMod - string para filtrar o modelo pela descrição

Quando o searchKey é informado, o método retorna a lista de campos, valores e tipos.
Quando é informado apenas o assJur, o método retorna a lista de templates

@since 30/07/2020

@example [getModelos] GET -> http://127.0.0.1:12173/rest/JURCONSULTAS/getTemplate?assJur=001
@example [getDetMod] GET -> http://127.0.0.1:12173/rest/JURCONSULTAS/getTemplate?searchKey=000005

/*/
//------------------------------------------------------------------------------------------------------------------
WSMETHOD GET getTemplate WSRECEIVE searchKey, assJur, filtraMod WSREST JURCONSULTAS
Local oResponse    := JsonObject():New()
Local cAssJur      := Self:assJur
Local cCodModelo   := Self:searchKey
Local cFiltraMod   := Self:filtraMod

	Self:SetContentType("application/json")
	
	If Empty(cCodModelo)
		getModelos(cAssJur,@oResponse, cFiltraMod)
	Else
		getDetMod(cCodModelo,@oResponse)
	EndIf

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GET graphConsultivo
Método responsável por buscar os dados do grafico de consultivo.

@param dataRef - Informa a data de referencia que será buscada

@since 30/07/2020

@example [getModelos] GET -> http://127.0.0.1:12173/rest/JURCONSULTAS/graphConsultivo
@example [getModelos] GET -> http://127.0.0.1:12173/rest/JURCONSULTAS/graphConsultivo?dataRef=20171201

/*/
//------------------------------------------------------------------------------------------------------------------
WSMETHOD GET graphConsultivo WSRECEIVE dataRef WSREST JURCONSULTAS
Local oResponse    := getGraphConsultivo(Self:dataRef)

	Self:SetContentType("application/json")

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

return .T.

//------------------------------------------------------------------------------
/* /{Protheus.doc} getGraphConsultivo

@param dDtRef - data de referencia para busca
(examples)
@since 01/09/2020
/*/
//------------------------------------------------------------------------------
Static Function getGraphConsultivo(dDtRef)
Local oResponse := JsonObject():New()
Local cQuery    := ""
Local cAlias    := GetNextAlias()
Local aFilUsr   := JURFILUSR( __CUSERID, "NSZ" )
Local aSQLRest  := Ja162RstUs(,,,.T.)
Local cDtIni    := ""
Local cDtFim    := ""
Local nPosData  := 0
Local nPosTipo  := 0
Local aAnoMes   := {0,0,0,0,0,0,0,0,0,0,0,0}
Local n1        := 0
Default dDtRef  := Date()

	If ValType(dDtRef) == "C"
		dDtRef := StoD(dDtRef)
	Endif

	cDtIni := DtoS( FirstDate( MonthSub( dDtRef, 11 ) ) )
	cDtFim := DtoS( LastDay( dDtRef ) )

	oResponse["dataset"] := {}
	/*--------------------------------------------------------*\
	* Monta a estrutura da linha de evolução em aberto        *
	\*--------------------------------------------------------*/
	aAdd(oResponse["dataset"],JsonObject():new())
		aTail(oResponse["dataset"])["data"]                      := aClone(aAnoMes)
		aTail(oResponse["dataset"])["label"]                     := JConvUTF8(STR0025) //STR0025 "Total de abertura no mês"
		aTail(oResponse["dataset"])["type"]                      := 'line'
		aTail(oResponse["dataset"])["tpSolic"]                   := 'TOTAL'
		aTail(oResponse["dataset"])["backgroundColor"]           := 'rgba(13, 114, 156, 0)'
		aTail(oResponse["dataset"])["borderColor"]               := 'rgba(13, 114, 156, 1)'
		aTail(oResponse["dataset"])["pointBackgroundColor"]      := 'rgba(255, 255, 255, 1)'
		aTail(oResponse["dataset"])["pointBorderColor"]          := 'rgba(13, 114, 156, 1)'
		aTail(oResponse["dataset"])["pointHoverBackgroundColor"] := 'rgba(13, 114, 156, 1)'
		aTail(oResponse["dataset"])["pointHoverBorderColor"]     := 'rgba(148,159,177,0.8)'

	/*--------------------------------------------------------*\
	* Monta a estrutura da barra de encerrado                 *
	\*--------------------------------------------------------*/
	aAdd(oResponse["dataset"],JsonObject():new())
		aTail(oResponse["dataset"])["data"]                 := aClone(aAnoMes)
		aTail(oResponse["dataset"])["label"]                := JConvUTF8(STR0027) //"Total de encerradas no mês"
		aTail(oResponse["dataset"])["type"]                 := 'bar'
		aTail(oResponse["dataset"])["tpSolic"]              := 'BAR_ENCERRADO'
		aTail(oResponse["dataset"])["stack"]                := .F.
		aTail(oResponse["dataset"])["order"]                := 2
		aTail(oResponse["dataset"])["backgroundColor"]      := 'rgba(178,34,34, 0.8)'
		aTail(oResponse["dataset"])["borderColor"]          := 'rgba(178,34,34, 1)'
		aTail(oResponse["dataset"])["pointBorderColor"]     := 'rgba(178,34,34, 1)'
		aTail(oResponse["dataset"])["hoverBackgroundColor"] := 'rgba(178,34,34, 1)'
		aTail(oResponse["dataset"])["hoverBorderColor"]     := 'rgba(139,0,0,0.8)'
	oResponse["labels"] := {}

	For n1 := 11 to 0 step -1
		aAdd(oResponse["labels"], Substr( DtoS( MonthSub( dDtRef, n1) ), 1, 6) )
	Next

	/*--------------------------------------------------------*\
	* Query para buscar as informações por tipo de solicitação *
	\*--------------------------------------------------------*/
	cQuery += "Select "
	cQuery +=     " NSZ.NSZ_CTPSOL TIPO,"
	cQuery +=     " COALESCE(NYA.NYA_DESC,'"+STR0026+"') DESCRI," //Não definido
	cQuery +=     " SUBSTRING(NSZ.NSZ_DTINCL,1,6) ANOMES, "
	cQuery +=     " COUNT(NSZ.NSZ_COD) QTD "
	cQuery += " From "+RetSqlName('NSZ')+" NSZ"
	cQuery +=     " LEFT JOIN "+RetSqlName('NYA')+" NYA ON"
	cQuery +=         " NYA.NYA_FILIAL = '"+xFilial('NYA')+"' "
	cQuery +=         " AND NYA.NYA_COD = NSZ.NSZ_CTPSOL"
	cQuery +=         " AND NYA.D_E_L_E_T_ = ' '"
	cQuery += " Where "
	cQuery +=     " NSZ.D_E_L_E_T_ = ' ' "

	//Busca os processos incluidos nos ultimos 12 meses
	cQuery += " AND NSZ.NSZ_DTINCL BETWEEN '"+cDtIni+"' AND '"+cDtFim+"' "
	
	// Filtar Filiais que o usuário possui acesso
	If ( VerSenha(114) .or. VerSenha(115) )
		cQryWhere := " NSZ.NSZ_FILIAL IN " + FORMATIN(aFilUsr[1],aFilUsr[2])
	Else
		cQryWhere := " NSZ.NSZ_FILIAL = '"+xFilial("NSZ")+"' "
	EndIf

	//VERIFICA OS ASSUNTO DO TIPO CONSULTIVO E SEUS RESPECTIVOS FILHOS
	cQuery +=   ' AND NSZ_TIPOAS IN (' + JurTpAsJr(__CUSERID) + ')'
	cQuery +=   ' AND NSZ_TIPOAS IN (' + WsJGetTpAss("'005'") + ')' 

	//Restrições do usuário
	cQuery  += VerRestricao(,, WsJGetTpAss("'005'" , .T.))
	If !Empty(aSQLRest)
		cQuery += " AND ("+Ja162SQLRt(aSQLRest, , , , , , , , , WsJGetTpAss("'005'" , .T.))+")"
	EndIf
	
	cQuery += " GROUP BY NSZ.NSZ_CTPSOL, NYA.NYA_DESC, SUBSTRING(NSZ_DTINCL,1,6) "

	cQuery += " UNION "
	
	/*----------------------------------------------------*\
	* Query para buscar as informações de encerrados
	\*----------------------------------------------------*/
	cQuery += "Select "
	cQuery +=     " 'BAR_ENCERRADO' TIPO,"
	cQuery +=     " '' DESCRI," //Não definido
	cQuery +=     " SUBSTRING(NSZ.NSZ_DTENCE,1,6) ANOMES, "
	cQuery +=     " COUNT(NSZ.NSZ_COD) QTD "
	cQuery += " From "+RetSqlName('NSZ')+" NSZ"
	cQuery +=     " LEFT JOIN "+RetSqlName('NYA')+" NYA ON"
	cQuery +=         " NYA.NYA_FILIAL = '"+xFilial('NYA')+"' "
	cQuery +=         " AND NYA.NYA_COD = NSZ.NSZ_CTPSOL"
	cQuery +=         " AND NYA.D_E_L_E_T_ = ' '"
	cQuery += " Where "
	cQuery +=     " NSZ.D_E_L_E_T_ = ' ' "

	//Busca os processos incluidos nos ultimos 12 meses
	cQuery += " AND NSZ.NSZ_DTENCE BETWEEN '"+cDtIni+"' AND '"+cDtFim+"' "
	
	// Filtar Filiais que o usuário possui acesso
	If ( VerSenha(114) .or. VerSenha(115) )
		cQryWhere := " NSZ.NSZ_FILIAL IN " + FORMATIN(aFilUsr[1],aFilUsr[2])
	Else
		cQryWhere := " NSZ.NSZ_FILIAL = '"+xFilial("NSZ")+"' "
	EndIf

	//VERIFICA OS ASSUNTO DO TIPO CONSULTIVO E SEUS RESPECTIVOS FILHOS
	cQuery +=   " AND NSZ_TIPOAS IN (" + JurTpAsJr(__CUSERID) + ")"
	cQuery +=   " AND NSZ_TIPOAS IN (" + WsJGetTpAss("'005'") + ")"
	cQuery +=   " AND NSZ_SITUAC = '2' "
	cQuery += " GROUP BY SUBSTRING(NSZ_DTENCE,1,6) "

	cQuery += " ORDER BY 3"

	cQuery := ChangeQuery(cQuery)
	cQuery := StrTran(cQuery,",' '",",''")

	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

	While (cAlias)->(!Eof())
		nPosData := aScan(oResponse["labels"],(cAlias)->ANOMES)

		nPosTipo := aScan(oResponse["dataset"],{|x| x["tpSolic"] == (cAlias)->TIPO })

		//Soma a quantidade na linha de totais ignorando os encerrados
		If (cAlias)->TIPO <> 'BAR_ENCERRADO'
			oResponse["dataset"][1]["data"][nPosData] += (cAlias)->QTD
		Endif

		If nPosTipo > 0
			oResponse["dataset"][nPosTipo]["data"][nPosData] := (cAlias)->QTD
		Else
			aAdd(oResponse["dataset"],JsonObject():new())
			aTail(oResponse["dataset"])["data"]           := aClone(aAnoMes)
			aTail(oResponse["dataset"])["tpSolic"]        := (cAlias)->TIPO
			aTail(oResponse["dataset"])["label"]          := JConvUTF8( (cAlias)->DESCRI )
			aTail(oResponse["dataset"])["data"][nPosData] := (cAlias)->QTD
		Endif
		(cAlias)->(DbSkip())
	End

	(cAlias)->(DbCloseArea())

	aSize(aAnoMes,0)
	aAnoMes := nil

Return oResponse

/*/{Protheus.doc} getModelos(cTipoAssun, oResponse)
Função responsável por buscar a lista de templates

@param oResponse  - Objeto JSON para retorno do método 
@param cTipoAssun - Assunto jurídico
@param cFiltraMod - string para filtrar o modelo pela descrição

@since 30/07/2020
/*/
//------------------------------------------------------------------------------------------------------------------
Static Function getModelos(cTipoAssun, oResponse, cFiltraMod)
Local cQuery       := ""
Local aRetSQL      := {}
Local nI           := 1

Default cTipoAssun := ""
	Default cFiltraMod := ""
	Default oResponse  := Nil

	cQuery := "select NZ3_COD,"
	cQuery +=       " NZ3_NOME "
	cQuery +=  " from " + RetSqlName('NZ3') 
 	cQuery += " where NZ3_TIPO = '2'"
	cQuery +=   " and D_E_L_E_T_ = ' ' " 
	cQuery +=   " and NZ3_FILIAL = '" + xFilial('NZ3')+ "'"
	cQuery +=   " and NZ3_TIPOAS = '" + cTipoAssun + "'"  
	
	If !Empty(cFiltraMod)
		cQuery += " AND UPPER(NZ3_NOME) LIKE '%" + Upper(cFiltraMod) + "%'"
	EndIf
	aRetSQL   := JurSQL(cQuery,'*')

	oResponse['listModels'] := {}
	oResponse['length']     := 0

		For nI := 1 to Len(aRetSQL)
			Aadd(oResponse['listModels'], JsonObject():New())
			oResponse['listModels'][nI]['codModel']   := aRetSQL[nI][1]
			oResponse['listModels'][nI]['descModel']  := JConvUTF8(aRetSQL[nI][2])
		Next

		oResponse['length'] := Len(aRetSQL)


Return oResponse

/*/{Protheus.doc} getDetMod(cCodModelo, oResponse)
Função responsável por buscar a lista de campos, valores e tipos do template indicado

@param oResponse  - Objeto JSON para retorno do método 
@param cCodModelo - Código do template desejado

@since 30/07/2020
/*/
Static Function getDetMod(cCodModelo, oResponse)
Local aArea    := GetArea()
Local aAreaNZ4 := NZ4->( GetArea() )
Local aRet     := {}
Local cModel   := ""
Local cField   := ""
Local cValue   := ""
Local cType    := ""

	DbSelectArea("NZ4")
		NZ4->(DbSetOrder(1))
		NZ4->(dbSeek(xFilial('NZ4')+cCodModelo))

		While NZ4->(!Eof()) .And. NZ4->NZ4_CMOD == cCodModelo .And. NZ4->NZ4_FILIAL == xFilial('NZ4')

			cField := Alltrim(NZ4->NZ4_NOMEC)
			cType  := Alltrim(NZ4->NZ4_TIPO)
			cValue := JConvUTF8(NZ4->NZ4_VALORC)
			cModel := Alltrim(NZ4->NZ4_NOMEMD)

			If cType == "D"
					cValue := DTOS(CTOD(cValue))
			EndIf

			Aadd(aRet,{cField, cType, cValue, cModel})

			NZ4->(dbSkip())
		EndDo

	NZ4->(DbCloseArea())	

	oResponse['length'] := Len(aRet)
	oResponse['detModel'] := {}
	Aadd(oResponse['detModel'], JsonObject():New())
	oResponse['detModel'] := aRet

	RestArea( aArea )
	RestArea( aAreaNZ4 )

Return oResponse

//------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GET getTipoAssunto
Método responsável por buscar os filhos do tipo de assunto .

@param assJur    - Assunto jurídico pai

@since 31/08/2020

@example [getModelos] GET -> http://127.0.0.1:12173/rest/JURCONSULTAS/getTipoAssunto?assJur=005

/*/
//------------------------------------------------------------------------------------------------------------------
WSMETHOD GET getTipoAssunto WSRECEIVE assJur WSREST JURCONSULTAS
Local oResponse    := JsonObject():New()
Local cAssJur      := Self:assJur

	cAssJur := WsJGetTpAss(cAssJur)

	Self:SetContentType("application/json")
	
	oResponse['Assuntos'] := cAssJur

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Function WsJGetTpAss
Função responsável por buscar os tipos de assunto conforme o pai informado.

@param cAssJur    - Assunto jurídico pai
@param lAssJurGrp - Considera as permissões de usuário?

@since 31/08/2020
/*/
//------------------------------------------------------------------------------------------------------------------
Function WsJGetTpAss(cAssJur, lAssJurGrp)
Local cRet       := ""
Local cSql       := ""
Local cAlias     := GetNextAlias()
Local cAssJurGrp := ""

Default cAssJur    := "'001'"
Default lAssJurGrp := .F.

	cAssJurGrp := JurTpAsJr(__CUSERID)

	cSql := " SELECT NYB_COD"
	cSql += " FROM " + RetSqlName('NYB')
	cSql += " where "
	cSql += 	" (NYB_COD IN (" + cAssJur + ")"
	cSql += 	" OR NYB_CORIG IN (" + cAssJur + ") )"
	cSql += 	" and D_E_L_E_T_ = ' '"
	
	cSql  := ChangeQuery(cSql)
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSql ), cAlias, .T., .F. )
	
	While (cAlias)->(!EoF())
		If lAssJurGrp
			If (cAlias)->NYB_COD $ cAssJurGrp
				If !Empty(cRet)
					cRet += ","
				EndIf
				cRet += "'"+(cAlias)->NYB_COD+"'"
			EndIf
		Else
			If !Empty(cRet)
				cRet += ","
			EndIf
			cRet += "'"+(cAlias)->NYB_COD+"'"
		EndIf
		(cAlias)->(DbSkip())
	End
	
	(cAlias)->(DbCloseArea())

	If Empty(cRet)
		cRet := "''"
	EndIf
Return cRet

//------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GET getListConsultas
Método responsável por buscar a lista de consultas.

@param situac    - situação da consulta
@param searchKey - palavra chave para busca
@param tpFilter  - tipo de filtro
@param page      - pagina que será buscada
@param pageSize  - quantidade de registros por pagina

@since 03/09/2020
@example [getModelos] GET -> http://127.0.0.1:12173/rest/JURCONSULTAS/getListConsultas?situac=1

/*/
//------------------------------------------------------------------------------------------------------------------
WSMETHOD GET getListConsultas WSRECEIVE situac, searchKey, tpFilter, page, pageSize, relaciona, filConsulta, cajuri, assJur WSREST JURCONSULTAS
Local oResponse  := JsonObject():New()
Local cQuery     := ""
Local cAlias     := GetNextAlias()
Local nQtdReg    := 0
Local nQtdRegIni := 0
Local nQtdRegFim := 0
Local nIndexJSon := 0
Local lHasNext   := .F.
Local lTotal     := .F.
Local cAt        := " FROM "+RetSqlName("NSZ")+" NSZ "

Local cSituac    := Self:situac
Local cSearchKey := Self:searchKey
Local nPage      := Self:page
Local nPageSize  := Self:pageSize
Local cTpFilter  := Self:tpFilter
Local cAssJur    := Self:assJur
Local cRelaciona := Self:relaciona //tipo de relacionamento
Local cFilConsul := Self:filConsulta 
Local cCajuri    := Self:cajuri

Default cSituac    := "1,2"
Default cSearchKey := ""
Default cTpFilter  := ""
Default nPage      := 1
Default nPageSize  := 10


	Self:SetContentType("application/json")
	
	oResponse['length']    := 0
	oResponse['consultas'] := {}

	nQtdRegIni := ((nPage-1) * nPageSize)
	nQtdRegFim := (nPage * nPageSize)

	cQuery := qryConsultas( cSituac, cSearchKey, cTpFilter, cAssJur, cRelaciona, cFilConsul, cCajuri)
	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

	While (cAlias)->(!Eof()) .AND. nIndexJSon <= nPageSize .AND. !lTotal

		nQtdReg++
		// Verifica se o registro está no range da pagina
		if (nQtdReg > nQtdRegIni .AND. nQtdReg <= nQtdRegFim)
			nIndexJSon++
			Aadd(oResponse['consultas'], JsonObject():New())
			aTail(oResponse['consultas'])['pk']              := encode64((cAlias)->NSZ_FILIAL+(cAlias)->NSZ_COD)
			aTail(oResponse['consultas'])['filial']          := (cAlias)->NSZ_FILIAL
			aTail(oResponse['consultas'])['cajuri']          := (cAlias)->NSZ_COD
			aTail(oResponse['consultas'])['solicitante']     := JConvUTF8((cAlias)->NSZ_SOLICI)
			aTail(oResponse['consultas'])['area']            := JConvUTF8((cAlias)->NRB_DESC) // Área solicitante
			aTail(oResponse['consultas'])['dataInclusao']    := (cAlias)->NSZ_DTINCL
			aTail(oResponse['consultas'])['tipoSolicitacao'] := JConvUTF8((cAlias)->NYA_DESC) // Tipo de Solicitação
			aTail(oResponse['consultas'])['codigoFluig']     := AllTrim((cAlias)->NSZ_CODWF)

		Elseif (nQtdReg == nQtdRegFim + 1)
			lHasNext := .T.
			lTotal   := .T.
		Endif

		(cAlias)->(DbSkip())

	End
	(cAlias)->( DbCloseArea() )

	cQuery := qryConsultas( '1', cSearchKey, '1', cAssJur, cRelaciona, cFilConsul, cCajuri)
	oResponse['qtdAndamento']  := WSLPQtdReg(SUBSTR(cQuery,At( cAt,cQuery),at("ORDER BY",cQuery)-At( cAt,cQuery)))
	cQuery := qryConsultas( '1,2', cSearchKey, '2', cAssJur, cRelaciona, cFilConsul, cCajuri)
	oResponse['qtdNovos']      := WSLPQtdReg(SUBSTR(cQuery,At( cAt,cQuery),at("ORDER BY",cQuery)-At( cAt,cQuery)))
	cQuery := qryConsultas( '2', cSearchKey, '3', cAssJur, cRelaciona, cFilConsul, cCajuri)
	oResponse['qtdEncerrados'] := WSLPQtdReg(SUBSTR(cQuery,At( cAt,cQuery),at("ORDER BY",cQuery)-At( cAt,cQuery)))

	oResponse['hasNext'] := lHasNext

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ListConsultas
Função responsável por retornar a query da lista de consultas e pareceres em aberto .

@param situac     - Situação da consulta
@param cSearchKey - palavra chave para busca
@param cTpFilter  - tipo de filtro para retorno

@since 03/09/2020
@return aSql - Array com a lista de consultas 

/*/
//------------------------------------------------------------------------------------------------------------------
Static Function qryConsultas( cSituac , cSearchKey, cTpFilter, cAssJur, cRelaciona, cFilConsul, cCajuri)
Local cSQL       := ''
Local cFilCons   := ''
Local aFilUsr    := {}
Local cQrySelect := ""
Local cQryFrom   := ""
Local cQryWhere  := ""
Local cWhrTpAsJ  := ""
Local aAsJFilhos := {}
Local cTpAsJVinc := ""
Local cTpAsJOrig := ""
Local cAssJurRel := ""
Local lFiltraRel := .F.
Local cQuery     := ""
Local cQryOrder  := ""
Local nX         := 1
Local aSQLRest   := Ja162RstUs(,,,.T.)

Default cSituac    := "'1'"
Default cSearchKey := ''
Default cTpFilter  := ''
Default cAssJur    := '005'
Default cRelaciona := ''
Default cFilConsul := ''
Default cCajuri    := ''
	
	// Validação relacionamento
	If !Empty(cRelaciona)

		Do Case 
			Case cRelaciona == "incidente"

				// Somente processos de tipos de assuntos juridicos iguais do processo origem 
				cWhrTpAsJ := " AND NSZ.NSZ_TIPOAS = '" + cAssJur + "' "
			
			Case cRelaciona == "vinculado"
				// Somente processos de tipos de assuntos juridicos iguais do processo origem e tipos filhos
				cSQL := " SELECT NYB_COD FROM " + RetSqlname("NYB")
				cSQL += " WHERE NYB_CORIG = '" + cAssJur + "' AND D_E_L_E_T_ = ' '"
				cSQL := ChangeQuery(cSQL)
				aAsJFilhos := JurSQL(cSQL, "*")

				For nX := 1 To Len(aAsJFilhos)
					cTpAsJVinc += "'"+aAsJFilhos[nX][1]+"',"
				Next nX

				cTpAsJOrig := JurGetDados('NYB', 1, xFilial('NYB') + cAssJur, 'NYB_CORIG')

				If !Empty(AllTrim(cTpAsJOrig))
					cTpAsJVinc += "'"+cTpAsJOrig+"',"
				EndIf

				cTpAsJVinc += "'" + cAssJur + "'"

				cWhrTpAsJ := " AND NSZ.NSZ_TIPOAS IN (" + cTpAsJVinc + ") "

			Case cRelaciona == "relacionado"
				//Todos os assuntos juridicos diferentes do origem
				cTpAsJOrig := JurGetDados('NYB', 1, xFilial('NYB') + cAssJur, 'NYB_CORIG')
				If Empty(cTpAsJOrig)
					lFiltraRel := cAssJur == "005"
				Else
					lFiltraRel := cTpAsJOrig == "005"
				EndIf
				// Obtém os assuntos jurídicos filhos do assunto juridico do processo origem.
				cAssJurRel := WsJGetTpAss("'005'", .T.)
				If lFiltraRel
					// Trata a string, para retirar o assunto juridico do processo origem
					If "'"+ cAssJur +"'" == cAssJurRel
						cAssJurRel := "''"
					ElseIf at(",'"+ cAssJur +"',", cAssJurRel) > 0
						cAssJurRel := StrTran(cAssJurRel,",'"+ cAssJur +"',", ",")
					ElseIf at("'"+ cAssJur +"',", cAssJurRel) > 0
						cAssJurRel := StrTran(cAssJurRel,"'"+ cAssJur +"',", "")
					ElseIf at(",'"+ cAssJur +"'", cAssJurRel) > 0
						cAssJurRel := StrTran(cAssJurRel,",'"+ cAssJur +"'", "")
					EndIf
				EndIf

				If !Empty(cAssJurRel)
					// Somente processos de tipos de assuntos juridicos diferentes do processo origem
					cWhrTpAsJ := " AND NSZ.NSZ_TIPOAS IN ("+ cAssJurRel+") "
				EndIf
		EndCase
	Else
		cAssJur := WsJGetTpAss("'005'" , .T.)"
		cWhrTpAsJ := " AND NSZ.NSZ_TIPOAS IN ("+ cAssJur+") "
	EndIf
	
	cQrySelect := "SELECT "
	cQrySelect +=      "NSZ_FILIAL,"
	cQrySelect +=      "NSZ_COD,"
	cQrySelect +=      "NSZ_SOLICI,"
	cQrySelect +=      "NRB_DESC,"
	cQrySelect +=      "NSZ_DTINCL,"
	cQrySelect +=      "COALESCE(NYA.NYA_DESC,'"+STR0026+"') NYA_DESC," //Não definido
	cQrySelect +=      "NSZ_CODWF"
	cQryFrom += " FROM "+RetSqlName("NSZ")+" NSZ "
	cQryFrom +=     " LEFT JOIN "+RetSqlName("NRB")+" NRB ON "
	cQryFrom +=           "(NSZ.NSZ_CAREAJ = NRB.NRB_COD) "
	cQryFrom +=           "and NRB.D_E_L_E_T_ = ' ' "
	cQryFrom +=     " LEFT JOIN "+RetSqlName("NYA")+" NYA ON "
	cQryFrom +=           "(NSZ.NSZ_CTPSOL = NYA.NYA_COD) "
	cQryFrom +=           "and NYA.D_E_L_E_T_ = ' ' "

	// Filiais que o usuário possui acesso
	If ( VerSenha(114) .or. VerSenha(115) )
		aFilUsr    := JURFILUSR( __CUSERID, "NSZ" )
		cFilCons :=  FORMATIN(aFilUsr[1],aFilUsr[2])
	Else
		cFilCons := FORMATIN(xFilial("NSZ"),',')
	EndIf

	cQryWhere += " WHERE NSZ.D_E_L_E_T_ = ' ' "
	cQryWhere +=     " AND NSZ_FILIAL IN " + cFilCons
	cQryWhere +=     " AND NSZ_TIPOAS IN (" + JurTpAsJr(__CUSERID) + ")" // Assuntos jurídicos configurados para o grupo do usuário
	cQryWhere +=     " AND NSZ_SITUAC IN " +  FORMATIN(cSituac,",") 

	//Restrições do usuário
	cQryWhere  += VerRestricao(,, WsJGetTpAss("'005'" , .T.))
	If !Empty(aSQLRest)
		cQryWhere += " AND ("+Ja162SQLRt(aSQLRest, , , , , , , , , WsJGetTpAss("'005'" , .T.))+")"
	EndIf

	// Parâmetros
	If !Empty(cCajuri)
		If !Empty(cRelaciona)
			cQryWhere  +=    " AND NSZ.NSZ_COD <> '"+cCajuri+"' "
			cQryWhere  +=    " AND NSZ.NSZ_FILIAL = '"+cFilConsul+"' "
		Else
			cQryWhere  +=    " AND NSZ.NSZ_COD = '"+cCajuri+"' "
		EndIf
	EndIf
	
	cQryWhere += cWhrTpAsJ
	
	If !(Empty(cSearchKey))
		
		cSearchKey := Lower(StrTran(JurLmpCpo( cSearchKey,.F. ),'#',''))

		cQryWhere += " AND ( NSZ_COD Like '%" + cSearchKey + "%'"
		cQryWhere +=        " OR " + JurFormat("NSZ_DETALH", .T.,.T.) + " Like '%" + cSearchKey + "%'"
		cQryWhere +=        " OR " + JurFormat("NYA_DESC", .T.,.T.) + " Like '%" + cSearchKey + "%'"
		cQryWhere +=        " OR " + JurFormat("NSZ_DETENC", .T.,.T.) + " Like '%" + cSearchKey + "%'"
		cQryWhere +=        " OR " + JurFormat("NSZ_SOLICI", .T.,.T.) + " Like '%" + cSearchKey + "%' )"

	EndIf

	// Define o Filtro aplicado na query
	If !Empty(cTpFilter)
		If cTpFilter == "2" // Cadastrados no mês corrente
			cQryWhere += " AND NSZ.NSZ_DTINCL >= '" + DTOS(FirstDate( Date() )) + "' "
		ElseIf cTpFilter == "3" // Encerrados no mês corrente
			cQryWhere += " AND NSZ.NSZ_DTENCE >= '" + DTOS(FirstDate( Date() )) + "' "
		EndIf
	Endif
	cQryOrder += ' ORDER BY NSZ_DTINCL'
	cQuery := cQrySelect + cQryFrom + cQryWhere + cQryOrder

	cQuery := ChangeQuery(cQuery)

	cQuery := StrTran(cQuery,",' '",",''")

Return cQuery
//-------------------------------------------------------------------
/*/{Protheus.doc} BuscaF3
Retorna a lista de dados do F3 de campos customizados.

@param cF3:        Nome do XB_ALIAS que foi cadastrado para o campo customizado
@param cSearchKey: Conteúdo de busca
@param cFiltro:    Adiciona uma condição na busca dos dados
@return aRet - Lista com os dados de retorno do F3
@since 02/09/2020
/*/
//-------------------------------------------------------------------
Static Function BuscaF3( cF3, cSearchKey, cfiltro )
Local aArea      := GetArea()
Local cAlias     := ''
Local cQuery     := ''
Local cTabela    := ''
Local cChave     := ''
Local cLabel     := ''
Local cChvAuxSX5 := ''
Local cChaveSX5  := ''
Local nIndex     := 0
Local nPosCp     := 0
Local lContinua  := .F.
Local lSX5       := .F.
Local aRet       := {}
Local aStructF3  := {}
Local aLabel	 := {}
Local cSeq	     := ''
Local sxbContem  := ''
Local aCmpsDisp  := {}

Default cFiltro = ""

	//-- Busca as informações da consulta no SXB
	If !Empty(cF3)

		DbSelectArea("SXB")
		DbSetOrder(1) // XB_ALIAS + XB_TIPO + XB_SEQ + XB_COLUNA

		cF3:= PadR( cF3, 6 )
		If DbSeek( cF3  + '1' + '01' )
			cTabela := ALLTRIM(SXB->XB_CONTEM)
				If cF3 == "NQUCNJ"
					cTabela := "NQU"
				EndIf
		EndIf

		lSX5 := cTabela == 'SX5' .Or. Len(AllTrim(cF3)) == 2
		aStructF3 := FWSX3Util():GetAllFields(cTabela, .F.)

		While (SXB->XB_ALIAS == cF3)

			sxbContem := ALLTRIM(SXB->XB_CONTEM)

			If ! lSX5 .And. SXB->XB_TIPO == '4' .And. (aScan( aStructF3, { |x| sxbContem $ x } ) > 0)
				
				If Empty(cSeq) .Or. cSeq == SXB->XB_SEQ
					cSeq := SXB->XB_SEQ
					Aadd(aLabel, sxbContem)
				EndIf

			ElseIf SXB->XB_TIPO == '2'
				cLabel :=  SetLabel(sxbContem)
				If lSX5
					nIndex := At('jursxb(', Lower(SXB->XB_CONTEM))

					If nIndex > 0
						cChvAuxSX5 := SubStr(SXB->XB_CONTEM, nIndex + 8) 
						cChaveSX5 += SubStr(cChvAuxSX5 , 0, At(',', Lower(cChvAuxSX5)) - 2)
					EndIf
				EndIf
			ElseIf SXB->XB_TIPO == '5'
				cChave += " + " + sxbContem
			EndIf
			SXB->(DbSkip())
		End

		cChave := SubStr(cChave, 4)

		SXB->(DbCloseArea())

		If (!Empty(cTabela) .AND. !Empty(cChave)) .Or. Len(AllTrim(cF3)) == 2
			If !lSX5
				aStructF3 := FWSX3Util():GetAllFields(cTabela, .F.)

				aCmpsDisp := JCmpDispPD(aStructF3)
				
				If Empty(cLabel) .And. (Len(aLabel) > 0)
					cLabel :=  SetLabel("",aLabel)
				EndIf

				If Empty(cLabel)
					//-- Busca campos que possuem _NOME ou _DESC, senão usa terceira coluna da tabela
					nPosCp := aScan( aStructF3, { |x| '_NOME' $ x } )
					If nPosCp <= 0
						nPosCp := aScan( aStructF3, { |x| '_DESC' $ x } )
					EndIf

					If nPosCp > 0
						cLabel := aStructF3[nPosCp]
					Else
						cLabel := aStructF3[3]
					EndIf

					If len(aCmpsDisp) > 0 .And. AScan(aCmpsDisp[1], cLabel) == 0
						cLabel := "'*****'"
					EndIf
				EndIf
			Else
				If Empty(cTabela) .And. Len(AllTrim(cF3)) == 2
					cTabela = 'SX5'
					cChave := 'X5_CHAVE'
					lContinua := .T.
				EndIf

				Do Case
					Case __Language == 'PORTUGUESE'
						cLabel := 'X5_DESCRI'

					Case __Language == 'ENGLISH'
						cLabel := 'X5_DESCENG'

					Case __Language == 'SPANISH'
						cLabel := 'X5_DESCSPA'
				EndCase
			EndIf

			//-- Tratamento para retorno da consulta
			cChave := STRTRAN(cChave, cTabela + "->")

			If Substr(cTabela, 1, 1) == "S"
				cFilS := Substr(cTabela, 2) + "_FILIAL"
				If Substr(cTabela, 2) == SubStr(cChave, 1, 2)
					lContinua := .T.
				EndIf

			Else
				cFilS := cTabela + "_FILIAL"
				If Substr(cTabela, 1, 3) == SubStr(cChave, 1, 3)
					lContinua := .T.
				EndIf
			EndIf

			cChave := STRTRAN(cChave, " + ", " || ")

			//-- Busca os dados
			If lContinua

				cQuery := " SELECT " + cChave + " CHAVE, "
				cQuery +=        " " + cLabel + " LABEL  "
				cQuery += " FROM " + RetSqlName(cTabela) + " "
				cQuery += " WHERE D_E_L_E_T_ = ' ' "
				cQuery +=     " AND " + cFilS + " = '" + xFilial(cTabela) + "' "

				If !Empty(cSearchKey)
					cSearchKey := StrTran(cSearchKey,'-',' ')
					cSearchKey := Lower(StrTran(JurLmpCpo( cSearchKey, .F.), '#', ''))
					cQuery +=     " AND " + JurFormat(cLabel, .T., .T.) + " LIKE '%" + cSearchKey + "%' "
				EndIf

				If !Empty(cFiltro) .AND. cFiltro != '0'
					cQuery += " AND " + cFiltro
				EndIf

				If lSX5
					cQuery += " AND X5_TABELA = '" + IIF(!Empty(cChaveSX5), cChaveSX5, cF3) + "'"
				EndIf

				cQuery := ChangeQuery(cQuery)

				cQuery := StrTran(cQuery, '#', '')

				cAlias := GetNextAlias()
				DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

				While !(cAlias)->(Eof())
					aAdd( aRet, { ;
						If(ValType((cAlias)->(CHAVE)) == "C",RTrim((cAlias)->(CHAVE)),(cAlias)->(CHAVE)), ; //VALUE
						(cAlias)->(LABEL); //LABEL
					} )
					(cAlias)->(DbSkip())
				End

				(cAlias)->(DbCloseArea())
			EndIf

		EndIf

	EndIf
	restArea(aArea)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GET getF3
Busca a lista de dados da consulta do F3

@param  filtF3    Filtro adicional a ser aplicado, 
					'0' para não aplicar filtro
					'O0A_CCAUSA='001'condição sql para aplicar filtro
@param  xbAlias   Alias do campo procurado na SXB
@param  searchKey Código do registro a ser buscado
@return .T.        Lógico

@since 09/09/2020

@example GET -> http://127.0.0.1:12173/rest/JURCONSULTAS/getF3/0/NRBJUR
@example GET -> http://127.0.0.1:12173/rest/JURCONSULTAS/getF3/O0A_CCAUSA=%27005%27/O0A
/*/
//-------------------------------------------------------------------
WSMETHOD GET getF3 PATHPARAM xbAlias, searchKey, filtF3  WSREST JURCONSULTAS
Local oResponse := JsonObject():New()
Local cXBAlias  := Self:xbAlias
Local cIdReg    := Self:searchKey
Local cFilter   := self:filtF3
Local aOptions  := {}
Local nPos      := 0

	If Empty(cXBAlias)
		cXBAlias := ''
	EndIf

	If 'NRT' $ cXBAlias
		aOptions := VldCpoDesc('NRT', 'NRT_COD', 'NRT_CTIPOF', 'NQS', 'NQS_COD', 'NQS_DESC', cFilter)
	Else
		aOptions := BuscaF3( cXBAlias ,,cFilter)
	EndIf


	Self:SetContentType("application/json")

	// Busca por código
	If !Empty(cIdReg)
		nPos := aScan(aOptions,{|x|  Lower(JurLmpCpo(cIdReg)) == Lower(JurLmpCpo(x[1])) })

		If(nPos > 0 ) 
			oResponse['value'] := aOptions[nPos][1]
			oResponse['label'] := jConvUTF8(aOptions[nPos][2])
		EndIf
	EndIf

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET getF3List
Busca um determinado registro da lista do F3.
@param  filtF3    Filtro adicional a ser aplicado, 
					'0' para não aplicar filtro
					'O0A_CCAUSA='001'condição sql para aplicar filtro
@param  xbAlias    Alias do campo procurado na SXB
@param  filter     Filtro da busca de dados da lista F3.
@return .T.        Lógico
@since 09/09/2020

@example GET -> http://127.0.0.1:12173/rest/JURCONSULTAS/getF3/NRBJUR
@example GET -> http://127.0.0.1:12173/rest/JURCONSULTAS/getF3/O0A_CCAUSA=%27005%27/O0A
/*/
//-------------------------------------------------------------------
WSMETHOD GET getF3List PATHPARAM xbAlias, filtF3 WSRECEIVE filter  WSREST JURCONSULTAS
Local oResponse := JsonObject():New()
Local cXBAlias  := Self:xbAlias
Local cFilter   := Self:filter
Local aOptions  := {}
Local nI        := 0

	If Empty(cXBAlias)
		cXBAlias := ''
	EndIf

	If 'NRT' $ cXBAlias
		aOptions := VldCpoDesc('NRT', 'NRT_COD', 'NRT_CTIPOF', 'NQS', 'NQS_COD', 'NQS_DESC', cFilter)
	Else
		aOptions := BuscaF3( cXBAlias, cFilter, self:filtF3 )
	EndIf

	Self:SetContentType("application/json")
	oResponse['items'] := {} 

	For nI := 1 To Len(aOptions)
		Aadd(oResponse['items'], JsonObject():New())
		aTail(oResponse['items'])['value'] := aOptions[nI][1]
		aTail(oResponse['items'])['label'] := jConvUTF8(aOptions[nI][2])
		
		If(nI = 10)
			Exit
		EndIf

	Next nI

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} GET basicRegStruct
Busca da estrutura de uma determinada rotina.

@param  rotina     Nome do fonte MVC a ser buscado
@return lRet       Lógico
@since 04/11/2020

@example GET -> http://127.0.0.1:12173/rest/JURCONSULTAS/basicRegStruct/JURA022
/*/
//-------------------------------------------------------------------
WSMETHOD GET basicRegStruct PATHPARAM rotina WSREST JURCONSULTAS
Local lRet       := .T.
Local oResponse  := nil
Local cRotina    := Self:rotina

Default cRotina := ''

	If !Empty(cRotina)
		oResponse := JGetStrMdl(cRotina)
		If ValType(oResponse) == "J"
			Self:SetContentType("application/json")
			Self:SetResponse(oResponse:toJson())
			oResponse:fromJson("{}")
			oResponse := NIL
		Else
			lRet := .F.
		EndIf
	Else
		lRet := .F.
		SetRestFault(404,'Bad Request')
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JGetStrMdl
Busca da estrutura de uma determinada rotina. 

@param  cRotina: Nome da rotina em mvc para buscar a estrutura

@return oResponse - Objeto json com a estrutura da rotina
@since 26/11/2020
/*/
//-------------------------------------------------------------------
Function JGetStrMdl(cRotina)
Local oResponse  := nil
Local oView      := nil
Local oModel     := nil
Local aModels    := nil
Local aMdlFields := nil
Local aViewField := nil
Local aAuxFlds   := nil
Local aAuxCbox   := nil
Local aOptions   := nil
Local cF3        := ''
Local lCanChange := .T.
Local lHasXENum  := .F.
Local nPos       := 1
local nI         := 1
local nX         := 1
local nZ         := 1

Default cRotina := ''

	If !Empty(cRotina)
		oView  := FwLoadView(cRotina)
		If ValType(oView) == "O"
			oModel := oView:GetModel()

			oResponse := JsonObject():New()
			oResponse['title']   := JConvUTF8(oView:GetDescription())
			oResponse['struct']  := {}
			oResponse['modelId'] := oModel:GetId()

			aModels := oModel:GetAllSubModels()

			For nI := 1 to Len(aModels)
				aViewField := {}

				aAdd(oResponse['struct'],JsonObject():New())
				aTail(oResponse['struct'])['id']   := aModels[nI]:GetId() //nome modelo
				aTail(oResponse['struct'])['type'] := aModels[nI]:ClassName() //Field/Grid
				aTail(oResponse['struct'])['fields'] = {}

				aAuxFlds   := aTail(oResponse['struct'])['fields']

				aMdlFields := aModels[nI]:GetStruct():GetFields()

				If aScan(oView:GetModelsId(),aModels[nI]:GetId()) > 0
					aViewField := aClone(oView:GetViewStruct(aModels[nI]:GetId()):GetFields())
				Endif
				
				For nX := 1 to Len(aMdlFields)
					cF3         := ''
					aOptions    := nil
					lCanChange  := .T.
					nPos        := 0
					If !Empty(aMdlFields[nX][11])
						lHasXENum   := AT('GETSXENUM',UPPER(GetCbSource(aMdlFields[nX][11]))) > 0
					Else
						lHasXENum := .F.
					Endif

					If Len(aViewField) > 0
						nPos        := aScan(aViewField,{|x| x[1] == aMdlFields[nX][3] })
					Endif
					
					If nPos > 0
						cF3        := aViewField[nPos][9]
						lCanChange := aViewField[nPos][10]
						If Len(aViewField[nPos][13]) > 0
							aOptions := {}
							For nZ := 1 to Len(aViewField[nPos][13])
								If Empty(aViewField[nPos][13][nZ]) .or. At('=',aViewField[nPos][13][nZ]) == 0
									loop
								Endif
								aAdd(aOptions,JsonObject():New())
								aAuxCbox := Separa(aViewField[nPos][13][nZ],'=')
								aTail(aOptions)['value'] := aAuxCbox[1]
								aTail(aOptions)['label'] := JConvUTF8(aAuxCbox[2])
							Next
						Endif
					Endif

					aAdd(aAuxFlds,JsonObject():New())
					aTail(aAuxFlds)['field']         := aMdlFields[nX][3]
					aTail(aAuxFlds)['description']   := JConvUTF8(aMdlFields[nX][1])
					aTail(aAuxFlds)['type']          := aMdlFields[nX][4]
					aTail(aAuxFlds)['size']          := aMdlFields[nX][5]
					aTail(aAuxFlds)['decimal']       := aMdlFields[nX][6]
					aTail(aAuxFlds)['filter']        := AllTrim(cF3)
					aTail(aAuxFlds)['options']       := aOptions
					aTail(aAuxFlds)['isBrowse']      := getSx3Cache(aMdlFields[nX][3],'X3_BROWSE') == 'S'
					aTail(aAuxFlds)['isRequired']    := aMdlFields[nX][10]
					aTail(aAuxFlds)['isView']        := nPos > 0
					aTail(aAuxFlds)['isVirtual']     := getSx3Cache(aMdlFields[nX][3],'X3_CONTEXT') == 'V'
					aTail(aAuxFlds)['hasSequencial'] := lHasXENum
					aTail(aAuxFlds)['canChange']     := lCanChange

				Next

			Next
				
			oView:Destroy()
			FwFreeObj(oView)
		Else
			SetRestFault(404, JConvUTF8(STR0039))// 'O modelo informado não foi encontrado ou não contem view! Favor verificar.'
		Endif

		oView := Nil
	Endif
Return oResponse

//-------------------------------------------------------------------
/*/{Protheus.doc} GET getFluxoFollowUp
Responsável por descobrir o fluxo de geração de FUP e Andamento
para apresenta-lo no TOTVS JURÍDICO.

@param  tpFilter Tipo da busca, 1 - Andamento / 2 - FUP
@param  ato      cód do ato processual
@param  tpFUP    cód do tipo do fup

@since 19/11/2020

@example GET -> http://localhost:12173/rest/JURCONSULTAS/getFluxoFup/1/008
/*/
//-------------------------------------------------------------------
WSMETHOD GET getFluxoFollowUp WSRECEIVE tpFilter, ato, tpFUP WSREST JURCONSULTAS
Local cTpFilter := Self:tpFilter
Local cAto      := Self:ato
Local cTpFUP    := Self:tpFUP
Local oResponse := JsonObject():New()

	Self:SetContentType("application/json")

	If !Empty(cTpFilter) .And. (!Empty(cTpFUP) .Or. !Empty(cAto))
		oResponse := J106SetFlx(oResponse, cAto, cTpFUP, cTpFilter)
	EndIf

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET getFlxDelete
Obtém os fups e andamentos do fluxo para que sejam excluídos

@param  codAnd     Código do andamento

@since 26/11/2020

@example GET -> http://localhost:12173/rest/JURCONSULTAS/getFluxoDel/codAnd
/*/
//-------------------------------------------------------------------
WSMETHOD GET getFlxDelete PATHPARAM codAnd WSREST JURCONSULTAS
Local cCodAnd   := Self:codAnd
Local cCodFw    := ""
Local aFwAnLst  := {}
Local nX        := 1
Local oResponse := JsonObject():New()

	cCodFw := Posicione('NTA', 5 , xFilial('NTA') + cCodAnd, 'NTA_COD')
	JA106SELX(cCodFw, @aFwAnLst, .F.)

	Self:SetContentType("application/json")
	oResponse := JsonObject():New()
	oResponse['length'] := Len(aFwAnLst)
	
	oResponse['items'] := {}

	For nX := 1 To Len(aFwAnLst)
		aAdd(oResponse['items'], JsonObject():New())
		oResponse['items'][nX]['entityId']   := JConvUTF8(AllTrim(aFwAnLst[nX][2]))
		oResponse['items'][nX]['fupIdPai']   := JConvUTF8(AllTrim(aFwAnLst[nX][3]))
		oResponse['items'][nX]['entityDesc'] := JConvUTF8(AllTrim(aFwAnLst[nX][4]))
		oResponse['items'][nX]['entity']     := JConvUTF8(AllTrim(aFwAnLst[nX][6]))
		oResponse['items'][nX]['entityDate'] := JConvUTF8(AllTrim(dToS(aFwAnLst[nX][7])))
	Next nX

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} PUT deleteFluxo
Realiza a ação de exclusão do fluxo de um andamento

@param  codAndc Código do andamento

@since 26/11/2020

@example PUT -> http://localhost:12173/rest/JURCONSULTAS/deleteFluxo/codAnd
/*/
//-------------------------------------------------------------------
WSMETHOD PUT deleteFluxo PATHPARAM codAnd WSREST JURCONSULTAS
Local cCodAnd   := Self:codAnd
Local cCodFw    := ""
Local oResponse := JsonObject():New()

	cCodFw := Posicione('NTA', 5 , xFilial('NTA') + cCodAnd, 'NTA_COD')

	Self:SetContentType("application/json")
	oResponse['deleted'] := JA106EXCL(cCodFw,.T.)

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GET getSugDayBusiness
Realiza a busca da data do FUP automático

@param  tpFilter Tipo da busca da data, 1 - Retroativa ou 2 - Futura
@param  dataRef  Data inicio do calculo da sugestão.
@param  nCount   Quantidade de dias que será cálculado

@since 01/12/2020

@example GET -> http://localhost:12173/rest/JURCONSULTAS/getDayBusiness
/*/
//-------------------------------------------------------------------
WSMETHOD GET getSugDayBusiness WSRECEIVE tpFilter, dataRef, nCount, isValid WSREST JURCONSULTAS
Local cTpFilter := Self:tpFilter
Local nQtdDay   := Self:nCount
Local lValid    := Self:isValid == 'true'
Local dDate     := IIf( !Empty(Self:dataRef), SToD(Self:dataRef), StoD(Date()) )
Local oResponse := JsonObject():New()

	Self:SetContentType("application/json")

	oResponse := JsonObject():New()
	If !lValid
		oResponse['date'] := DToS(JUR106DTFU(cTpFilter, dDate, nQtdDay))
	Else
		oResponse['dateValid'] := JURA106FDS(dDate)
	EndIf
	
	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} getLastHistory()
Busca o último histórico do assunto jurídico

@param filial: Filial do assunto jurídico
@param cajuri: Código do assunto jurídico

@since 23/02/2021

@example GET -> http://127.0.0.1:12173/rest/JURCONSULTAS/lastHistory/{filial}/{cajuri}
/*/
//-------------------------------------------------------------------
WSMETHOD GET getLastHistory PATHPARAM filial, cajuri WSREST JURCONSULTAS
Local oResponse  := JsonObject():New()
Local cFilNT4    := Self:filial
Local cCajuri    := Self:cajuri
Local aRet       := {}

	Self:SetContentType("application/json")
	oResponse['lastHistory'] := {}

	aRet := JUltAnd(cCajuri, cFilNT4, .F.)

	If Len(aRet) > 0
		Aadd(oResponse['lastHistory'], JsonObject():New())
		oResponse['lastHistory'][1]['date']  := JConvUTF8(aRet[1][4])
		oResponse['lastHistory'][1]['title'] := JConvUTF8(aRet[1][6])
	EndIf

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} GET childrenLegalMatter
Responsável por retornar os assuntos jurídicos filhos de um determinado tipo de assunto

@param assJur: Assuntos jurídicos

@since 12/05/2021

@example [Sem Opcional] GET -> http://127.0.0.1:12173/rest/JURCONSULTAS/getChildrenLegalMatter
/*/
//-----------------------------------------------------------------------------------
WSMETHOD GET childrenLegalMatter WSRECEIVE assJur WSREST JURCONSULTAS
Local oResponse := JsonObject():New()
Local cAssJur   := Self:assJur
Local aRetSQL   := {}
Local nCont     := 0
Local nI        := 0
	
	Self:SetContentType("application/json")
	oResponse['childrenLegalMatter'] := {}
	oResponse['length']      := 0

	If !Empty(cAssJur)
		aRetSQL := JChildTpAss(cAssJur)

		For nI := 1 to Len(aRetSQL)
			nCont := nCont + 1
			Aadd(oResponse['childrenLegalMatter'], JsonObject():New())
			oResponse['childrenLegalMatter'][nCont]['value'] := aRetSQL[nI][1]
			oResponse['childrenLegalMatter'][nCont]['label'] := JConvUTF8(aRetSQL[nI][2])
		Next
	EndIf

	oResponse['length'] := nCont

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} JChildTpAss( cAssJur )
Função que faz a busca do assuntos jurídicos filhos

@param cAssJur: Assuntos jurídicos

@return aRetSQL: Retorno da query

@since 12/05/2021
/*/
//-------------------------------------------------------------------
Static Function JChildTpAss( cAssJur )
Local cQuery  := ""
Local aRetSQL := {}

	cQuery := " SELECT NYB.NYB_COD   VALUE, "
	cQuery +=        " NYB.NYB_DESC  LABEL, "
	cQuery +=        " NYB.NYB_CORIG ORIGEM"
	cQuery += "   FROM " + RetSqlName("NYB") + " NYB "
	cQuery +=  " WHERE NYB.NYB_CORIG IN " + FormatIn(cAssJur, ",")
	cQuery +=    " AND NYB.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND NYB.NYB_FILIAL = '" + xFilial("NYB") + "' "
	cQuery +=    " AND NYB.NYB_COD  IN (" + JurTpAsJr(__CUSERID) +  ") "

	aRetSQL := JurSQL(cQuery, '*')

Return aRetSQL

//-------------------------------------------------------------------
/*/{Protheus.doc} VldCpoDesc(cTableA, cCpoChaveA, cCpoBuscaA, cTableB, cCpoChaveB, cCpoDescB, cFiltro)
Função que faz filtro especifico em outra tabela para o campo de descrição

@param cTableA    - Tabela principal da busca da chave
@param cCpoChaveA - Campo principal da busca da chave (código)
@param cCpoBuscaA - Campo utilizado para fazer relacionamento com a tabela no inner
@param cTableB    - Tabela secundária que possui a descrição
@param cCpoChaveB - Campo utilizado para fazer relacionamento com a tabela principal
@param cCpoDescB  - Campo de descrição
@param cFiltro    - valor que será filtrado no campo de descrição 

@return aRet - Lista de opções
		aRet[1] - Código
		aRet[2] - Label

@since 07/07/2021
/*/
//-------------------------------------------------------------------
Static Function VldCpoDesc(cTableA, cCpoChaveA, cCpoBuscaA, cTableB, cCpoChaveB, cCpoDescB, cFiltro)

Local cAlias   := GetNextAlias()
Local cQuery   := ""
Local aRet     := {}

Default cFiltro := ""

	cQuery := " SELECT " + cCpoChaveA + " CHAVE, "
	cQuery +=        " " + cCpoDescB + " LABEL "
	cQuery += " FROM " + RetSqlName(cTableA) + " " + cTableA + " "
	cQuery +=        " INNER JOIN " + RetSqlName(cTableB) + " " + cTableB + " "
	cQuery +=                " ON " + cTableB + "." + cTableB + "_FILIAL = " + cTableA + "." + cTableA + "_FILIAL "
	cQuery +=                     " AND " + cTableA + "." + cCpoBuscaA + " = " + cTableB + "." + cCpoChaveB + " "
	cQuery +=                     " AND " + cTableB + "." + "D_E_L_E_T_ = ' ' "

	// Filtra só modelos que possuam responsáveis cadastrados
	If cTableA == 'NRT'
		cQuery +=        " INNER JOIN " + RetSqlName('NRR') + " NRR "
		cQuery +=                " ON NRR.NRR_FILIAL = NRT.NRT_FILIAL "
		cQuery +=                     " AND NRR.NRR_CFOLWP = NRT.NRT_COD "
		cQuery +=                     " AND NRR.NRR_CPART <> ' ' "
		cQuery +=                     " AND NRR.D_E_L_E_T_ = ' ' "
	EndIf

	cQuery += " WHERE " + cTableA + "." + "D_E_L_E_T_ = ' ' "
	cQuery +=     " AND " + cTableA + "." + cTableA + "_FILIAL" + " = '" + xFilial(cTableA) + "' "

	If !Empty(cFiltro) .AND. cFiltro != '0'
		cQuery += " AND UPPER(" + cTableB + "." + cCpoDescB + ") LIKE UPPER('%" + cFiltro + "%') "
	EndIf

	// Filtra só modelos automáticos (sem intervenção)
	If cTableA == 'NRT'
		cQuery += " AND NRT.NRT_TIPOGF = '1' "
	EndIf

	cQuery := ChangeQuery(cQuery)
	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

	While !(cAlias)->(Eof())
		aAdd( aRet, { (cAlias)->(CHAVE), (cAlias)->(LABEL) } )
		(cAlias)->(DbSkip())
	End

	(cAlias)->(DbCloseArea())

Return aRet

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} GET getMyTeam
Responsável por retornar da equipe conforme o código do usuário

@param codUser - Código do usuário

@example [Sem Opcional] GET -> http://127.0.0.1:12173/rest/JURCONSULTAS/myTeam?codUser=000000
/*/
//-----------------------------------------------------------------------------------
WSMETHOD GET getMyTeam WSRECEIVE codUser WSREST JURCONSULTAS

Local cCodUser   := Self:codUser
Local oResponse  := JsonObject():New()
Local cQuery     := ""
Local cTmpAlias  := GetNextAlias()
Local aAreaNZ8   := NZ8->(GetArea())

Default cCodUser := __CUSERID

	oResponse['lenght']   := 0

	cQuery += " SELECT NZ8.R_E_C_N_O_ NZ8RECNO"
	cQuery += " FROM "+RetSqlName("NZ8")+" NZ8 "
	cQuery +=     " INNER JOIN "+RetSqlName("RD0")+" RD0 ON "
	cQuery +=         " RD0.RD0_FILIAL = '" + xFilial('RD0') + "' "
	cQuery +=         " AND RD0.D_E_L_E_T_ = ' ' "
	cQuery +=         " AND RD0_USER = '"+cCodUser+"' "
	cQuery +=         " AND RD0.RD0_CODIGO = NZ8.NZ8_CPARTL "
	cQuery += " WHERE "
	cQuery +=     " NZ8.NZ8_FILIAL = '" + xFilial('NZ8') + "' "
	cQuery +=     " AND NZ8.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)

	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cTmpAlias, .F., .F. )

	If (cTmpAlias)->(!Eof())
		oResponse['listTeam'] := {}
		DbSelectArea('NZ8')
		While (cTmpAlias)->(!Eof())
			NZ8->(DbGoTo((cTmpAlias)->NZ8RECNO))

			aAdd(oResponse['listTeam'],JsonObject():New())
			Atail(oResponse['listTeam'])['pk']         := Encode64(NZ8->&(FwX2Unico('NZ8')))
			Atail(oResponse['listTeam'])['branch']     := NZ8->NZ8_FILIAL
			Atail(oResponse['listTeam'])['teamId']     := NZ8->NZ8_COD
			Atail(oResponse['listTeam'])['name']       := JConvUTF8(NZ8->NZ8_DESC)
			Atail(oResponse['listTeam'])['teamLeader'] := NZ8->NZ8_CPARTL
			

			(cTmpAlias)->(DbSkip())
		End
		NZ8->(DbCloseArea())
		oResponse['lenght']   := LEN(oResponse['listTeam'])
	Endif

	(cTmpAlias)->(DbCloseArea())
	
	Self:SetContentType("application/json")

	Self:SetResponse(oResponse:toJson())
	oResponse:fromJson("{}")
	oResponse := NIL

	RestArea(aAreaNZ8)

Return .T.

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} JVlObrigat( cTipoAss, cCampo, cTpAssPai )
	Valida se o campo é obrigatório no X3 ou na NUZ

@param  cTipoAss  - Indica o assunto jurídico
@param  cCampo    - Indica o campo
@param  cTpAssPai - Indica o assunto jurídico pai

@return lObrigat - Indica se o campo é obrigatório
/*/
//-----------------------------------------------------------------------------------
Static Function JVlObrigat( cTipoAss, cCampo , cTpAssPai )
Default cTipoAss  := '001'
Default cTpAssPai := cTipoAss

Return	( X3Obrigat(cCampo);
			.Or. Posicione('NUZ', 1, xFilial('NUZ') + cTpAssPai + cCampo, 'NUZ_OBRIGA');
			.Or. Posicione('NUZ', 1, xFilial('NUZ') + cTipoAss  + cCampo, 'NUZ_OBRIGA') )

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} SetLabel
	Retorna o Label do F3 de acordo com as colunas do grid 

@param  cDesc   - Lista de campos do grid
@param  aLabel  - Array com os campos do grid

@return cDesc - Label do F3
/*/
//-----------------------------------------------------------------------------------
Static Function SetLabel(cDesc, aLabel)
Local nI := At('jursxb(', Lower(cDesc))
Local aFields := {}
Default aLabel := {}

	// Valida de usa a JurSXB
	If(nI > 0) .Or. Len(aLabel) > 0
		// Pega os campos do grid de exibição
		If (nI > 0)
			cDesc := SubStr(SXB->XB_CONTEM, nI)
			cDesc := SubStr(cDesc , At('{', cDesc )+1)
			cDesc := SubStr(cDesc , 0, At('}', cDesc )-1)

			// Trata os valores
			cDesc := strtran(cDesc,'"',"")
			cDesc := strtran(cDesc,"'","")
			aFields := StrToKarr( cDesc, ',' )
		else
			aFields := aLabel
		End
		
		cDesc := ""

		For nI := 1 To Len(aFields)
			If TamSx3(aFields[nI])[3] $ "C|M"
				cDesc += " || ' - ' || REPLACE(" + aFields[nI] + ",'  ','#')"
			EndIf
		Next nI

		cDesc := SubStr(cDesc , 13)
	Else 
		cDesc := ""
	EndIf

Return cDesc

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} AddNick
	Adiciona o apelido das tabelas

@param  cStatement - Condição do filtro
@param  cSuffix    - Sufixo das tabelas

@return cStatement - Condição do filtro
@since 18/08/2022
/*/
//-----------------------------------------------------------------------------------
Static Function AddNick(cStatement, cSuffix)
Local aStatement := StrToKArr(cStatement,"_")
Local cNick      := ""
Local nI         := 0
Default cSuffix  := ""

	cStatement := ""

	For nI := 1 To Len(aStatement)
		If Mod(nI, 2) > 0
			cNick := aStatement[nI] + cSuffix + "."
			aStatement[nI] += "_" 
		EndIf

		cStatement += cNick + aStatement[nI]
		cNick := ""
	Next nI

Return cStatement
