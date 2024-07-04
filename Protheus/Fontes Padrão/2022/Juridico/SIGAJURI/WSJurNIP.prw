#Include "WSJURNIP.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "SHELL.CH"
#INCLUDE "TRYEXCEPTION.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} WSJurNIP
Métodos WS REST do Jurídico para Notificação de Interdição Preliminar.

@author SIGAJURI
@since 17/06/2021

/*/
//-------------------------------------------------------------------

WSRESTFUL JURNIP DESCRIPTION STR0001 //"WS Jurídico NIP"

	WSDATA page         AS INTEGER
	WSDATA pageSize     AS INTEGER
	WSDATA searchKey    AS STRING
	WSDATA assJur       AS STRING
	WSDATA filial       AS STRING
	WSDATA situac       AS STRING
	WSDATA cajuri       AS STRING
	WSDATA filter       AS STRING
	WSDATA codModelo    AS STRING
	WSDATA nomeModelo   AS STRING
	WSDATA nOpc         AS INTEGER

	//Gets
	WSMETHOD GET Listnips         DESCRIPTION STR0002 PATH "nips"                       PRODUCES APPLICATION_JSON //'Listagem de nips'
	WSMETHOD GET Qtdnips          DESCRIPTION STR0003 PATH "qtdNips"                    PRODUCES APPLICATION_JSON // Busca a quantidade de NIPs por filtro
	WSMETHOD GET GetModelResp     DESCRIPTION STR0004 PATH "getModelResp/{searchKey}"   PRODUCES APPLICATION_JSON // Busca o modelo de resposta
	WSMETHOD GET TpEnvolv         DESCRIPTION STR0013 PATH "tpEnvolv"                   PRODUCES APPLICATION_JSON // Busca o tipo do envolvido
	WSMETHOD GET GetAnswer        DESCRIPTION STR0017 PATH "getAnswer/{cajuri}"         PRODUCES APPLICATION_JSON // Busca os dados da resposta de uma NIP
	WSMETHOD GET QtdEvolution     DESCRIPTION STR0020 PATH "qtdEvolution"               PRODUCES APPLICATION_JSON // Busca a quantidade de NIPs para o gráfico de evolução das NIPS
	WSMETHOD GET QtdGraphFilter   DESCRIPTION STR0021 PATH "qtdGraphFilter"             PRODUCES APPLICATION_JSON // Busca a quantidade de NIPs para os graficos de indicadores das NIPS
	WSMETHOD GET UltAtuNip        DESCRIPTION STR0022 PATH "latestUpdNip"               PRODUCES APPLICATION_JSON // Busca as ultimas atualizações NIP
	WSMETHOD GET QtdAtuNip        DESCRIPTION STR0023 PATH "qtdAtuNip"                  PRODUCES APPLICATION_JSON // Busca a quantidade atualizações

	//Posts
	WSMETHOD POST SetModelResp    DESCRIPTION STR0007 PATH "setModelResp" // Grava o modelo de resposta

	//Puts
	WSMETHOD PUT  RenameDoc       DESCRIPTION STR0011 PATH "renameDoc" // Renomeia o arquivo modelo
	WSMETHOD PUT  SetAnswer       DESCRIPTION STR0018 PATH "setAnswer/{cajuri}" // Seta os dados da resposta de uma NIP

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} GET Listnips
Lista de NIPs 

@param page        Numero da página
@param pageSize    Quantidade de itens na página 
@param searchKey   Trecho a ser utilizado no filtro de NIPs
@param assJur      Tipo do assunto jurídico 
@param situac      Situação 1 - Em Andamento / 2 - Encerrado 
@param cajuri      Cajuri NIP
@param filter      Filtro a ser utilizado na lista de NIPs
                   'aguardando' | 'proxVenc' | 'filaANS' | 'distribuicao' | 'loggedUsr'

@author SIGAJURI
@since 17/06/2021

/*/
//-------------------------------------------------------------------
WSMETHOD GET Listnips WSRECEIVE page, pageSize, searchKey, assJur, situac, cajuri, filter WSREST JURNIP
Local aArea      := GetArea()
Local aAreaNT9   := NT9->(GetArea())
Local cAlias     := GetNextAlias()
Local oResponse  := JsonObject():New()
Local nPage      := Self:page
Local nPageSize  := Self:pageSize
Local cSearchKey := Self:searchKey
Local cAssJur    := Self:assJur
Local cSituac    := Self:situac
Local cCajuri    := Self:cajuri
Local cFilter    := Self:filter
Local cQuery     := ""
Local nIndexJSon := 0
Local nQtdReg    := 0
Local nQtdRegIni := 0
Local nQtdRegFim := 0
Local lHasNext   := .F.
Local cCompara   := ""
Local lFiliais   := .F.
Local aFilUsr    := JURFILUSR( __CUSERID, "NSZ" )
Local cFilNip    := ""
Local cCompNT9   := ""
Local lDocPend   := .F.
Local lBenefic   := .F.

Default nPage      := 1
Default nPageSize  := 10
Default cSituac    := ""
Default cSearchKey := ""
Default cAssJur    := "013"
Default cCajuri    := ""
Default cFilter    := ""

	DbSelectArea("NT9") 
		// Proteção referente DJURDEP-9435 -  (NIP) CRIAÇÃO DO ASSUNTO JURÍDICO
		lBenefic := ColumnPos("NT9_CODBEN") > 0 
	NT9->(DbCloseArea())

	// Monta a query da NSZ
	cQuery := JListNSZ( cSearchKey, cAssJur, cCajuri, cSituac, cFilter)

	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

	Self:SetContentType("application/json")
	oResponse['nips'] := {}
	
	If "," $ FORMATIN(aFilUsr[1],aFilUsr[2])
		lFiliais := .T.
	EndIf		
	oResponse['hasMoreBranch']  := lFiliais
	
	nQtdRegIni := ((nPage-1) * nPageSize)
	// Define o range para inclusão no JSON
	nQtdRegFim := (nPage * nPageSize)
	nQtdReg    := 0

	While (cAlias)->(!Eof())
		// Verificação de chaves duplicadas
		If !(AllTrim((cAlias)->NSZ_COD) $ cCompara)

			lDocPend := AllTrim((cAlias)->O0N_STATUS) == '1'
			nQtdReg++
			// Verifica se o registro está no range da pagina
			If (nQtdReg > nQtdRegIni .AND. nQtdReg <= nQtdRegFim)
				nIndexJSon++
				// Assunto Juridico
				cCajuri := (cAlias)->NSZ_COD
				cFilNip := (cAlias)->NSZ_FILIAL
				Aadd(oResponse['nips'], JsonObject():New())
				oResponse['nips'][nIndexJSon]['filial']          := cFilNip
				oResponse['nips'][nIndexJSon]['cajuri']          := JConvUTF8(cCajuri) //Protocolo Interno
				oResponse['nips'][nIndexJSon]['dataNotificacao'] := (cAlias)->NSZ_DTCERT //Data da Notificação
				oResponse['nips'][nIndexJSon]['dataRVE']         := (cAlias)->NSZ_DTEMIS //Data da RVE
				oResponse['nips'][nIndexJSon]['numDemanda']      := JConvUTF8((cAlias)->NSZ_IDENTI) //Número da Demanda
				oResponse['nips'][nIndexJSon]['protocolo']       := JConvUTF8((cAlias)->NSZ_NIRE) //Protocolo
				oResponse['nips'][nIndexJSon]['prazo']           := JConvUTF8((cAlias)->NSZ_NUMPED) //Prazo
				oResponse['nips'][nIndexJSon]['reclamacao']      := JConvUTF8((cAlias)->NSZ_DETALH) //Reclamação
				oResponse['nips'][nIndexJSon]['assunto']         := JConvUTF8((cAlias)->NSZ_TOMBO) //Assunto
				oResponse['nips'][nIndexJSon]['natureza']        := JConvUTF8((cAlias)->NSZ_OBJSOC) //Natureza
				oResponse['nips'][nIndexJSon]['statusANS']       := JConvUTF8((cAlias)->NSZ_ULTCON) //Status ANS
				oResponse['nips'][nIndexJSon]['aguardaDoc']      := lDocPend //Aguardando documento
				oResponse['nips'][nIndexJSon]['pendenteDistri']  := Empty((cAlias)->NSZ_CPART2) //Pendente de distribuição
				oResponse['nips'][nIndexJSon]['usuResponsavel']  := Alltrim((cAlias)->RD0_USER) == AllTrim(__CUSERID) //Usuário logado é responsavel pelo NIP?
				oResponse['nips'][nIndexJSon]['responsavel']     := JConvUTF8((cAlias)->NSZ_DPART2)//Nome do analista responsável

				If lBenefic
				// Beneficiários
					oResponse['nips'][nIndexJSon]['beneficiarios'] := {}
					Aadd(oResponse['nips'][nIndexJSon]['beneficiarios'], JsonObject():New())
					aTail(oResponse['nips'][nIndexJSon]['beneficiarios'])['codigo'] := JConvUTF8((cAlias)->NT9_CODBEN)  //Código beneficiário
					aTail(oResponse['nips'][nIndexJSon]['beneficiarios'])['nome']   := JConvUTF8((cAlias)->NT9_NOME)  //Nome do beneficiário
				EndIf
				cCompara := cCompara + AllTrim((cAlias)->NSZ_COD) + "|"

			ElseIf (nQtdReg == nQtdRegFim + 1)
				lHasNext := .T.
			EndIf

		ElseIf lBenefic .And. !((AllTrim((cAlias)->NSZ_COD)+"/"+AllTrim((cAlias)->NT9_COD)) $ cCompNT9) 
			//Adiciona o segundo e posteriores Envolvidos da NIP
			Aadd(oResponse['nips'][nIndexJSon]['beneficiarios'], JsonObject():New())
			aTail(oResponse['nips'][nIndexJSon]['beneficiarios'])['codigo'] := JConvUTF8((cAlias)->NT9_CODBEN)  //Código beneficiário
			aTail(oResponse['nips'][nIndexJSon]['beneficiarios'])['nome']   := JConvUTF8((cAlias)->NT9_NOME)  //Nome do beneficiário
			If !lDocPend
				//Atualiza o status de Aguardando documentos
				lDocPend := AllTrim((cAlias)->O0N_STATUS) == '1' //O0N_STATUS = 1 -> Pendente
				oResponse['nips'][nIndexJSon]['aguardaDoc']      := lDocPend
			EndIf
			cCompNT9 := cCompNT9 + AllTrim((cAlias)->NSZ_COD)+"/"+AllTrim((cAlias)->NT9_COD) + "|"

		ElseIf !lDocPend
				//Atualiza o status de Aguardando documentos
				lDocPend := AllTrim((cAlias)->O0N_STATUS) == '1'
				oResponse['nips'][nIndexJSon]['aguardaDoc']      := lDocPend
		EndIf


		(cAlias)->(DbSkip())
	End

	// Verifica se há uma proxima pagina
	If (lHasNext)
		oResponse['hasNext'] := .T.
	Else
		oResponse['hasNext'] := .F.
	EndIf

	(cAlias)->( DbCloseArea() )
	oResponse['length'] := nQtdReg

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

	RestArea( aAreaNT9 )
	RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} JListNSZ(cSearchKey, cAssJur, cCajuri, cSituac, cFilter)
Query da listagem de NIPs

@param searchKey   Trecho a ser utilizado no filtro de NIPs
@param cAssJur     Tipo do assunto jurídico 
@param cCajuri     Cajuri do contrao origem
@param cSituac     Situação 1 - Em aberto/ 2 - Encerrado 
@param filter      Filtro a ser utilizado na lista de NIPs
                   'aguardando' | 'proxVenc' | 'filaANS' | 'distribuicao' | 'loggedUsr'

@author SIGAJURI
@since 17/06/2021

/*/
//-------------------------------------------------------------------
Static Function JListNSZ(cSearchKey, cAssJur, cCajuri, cSituac, cFilter)

Local aArea      := GetArea()
Local aAreaNT9   := NT9->(GetArea())
Local aSQLRest   := Ja162RstUs(,,,.T.)
Local aFilUsr    := JURFILUSR( __CUSERID, "NSZ" )
Local cQrySelect := ""
Local cQryFrom   := ""
Local cQryWhere  := ""
Local cQryOrder  := ""
Local cQuery     := ""
Local cExists    := ""
Local lBenefic   := .F.

	DbSelectArea("NT9") 
		// Proteção referente DJURDEP-9435 -  (NIP) CRIAÇÃO DO ASSUNTO JURÍDICO
		lBenefic := ColumnPos("NT9_CODBEN") > 0 
	NT9->(DbCloseArea())

	cQrySelect := " SELECT NSZ.NSZ_FILIAL  NSZ_FILIAL, "
	cQrySelect +=        " NSZ.NSZ_COD     NSZ_COD, "
	cQrySelect +=        " NSZ.NSZ_DTCERT  NSZ_DTCERT, "
	cQrySelect +=        " NSZ.NSZ_DTEMIS  NSZ_DTEMIS, "
	cQrySelect +=        " NSZ.NSZ_IDENTI  NSZ_IDENTI, "
	cQrySelect +=        " NSZ.NSZ_NIRE    NSZ_NIRE, "
	cQrySelect +=        " NSZ.NSZ_NUMPED  NSZ_NUMPED, "
	cQrySelect +=        " NSZ.NSZ_CPART2  NSZ_CPART2, "
	cQrySelect +=        " RD0.RD0_NOME    NSZ_DPART2, "

	if (Upper(TcGetDb())) == "ORACLE"
		cQrySelect +=       " TO_CHAR(SUBSTR(NSZ.NSZ_DETALH,1,4000))  NSZ_DETALH, "
	Else
		cQrySelect +=       " CAST(NSZ.NSZ_DETALH AS VARCHAR(4000))  NSZ_DETALH, "
	Endif

	cQrySelect +=        " NSZ.NSZ_TOMBO   NSZ_TOMBO, "
	cQrySelect +=        " NSZ.NSZ_OBJSOC  NSZ_OBJSOC, "
	cQrySelect +=        " NSZ.NSZ_ULTCON  NSZ_ULTCON, "
	cQrySelect +=        " RD0.RD0_USER    RD0_USER, "

	If lBenefic
		cQrySelect +=        " NT9.NT9_COD     NT9_COD, "
		cQrySelect +=        " NT9.NT9_CODBEN  NT9_CODBEN, "
		cQrySelect +=        " NT9.NT9_NOME    NT9_NOME, "
	EndIf

	cQrySelect +=        " O0N.O0N_STATUS  O0N_STATUS "
	cQryFrom   :=        " FROM " + RetSqlName('NSZ') + " NSZ "
	cQryFrom   +=   " LEFT JOIN " + RetSqlName('NVE') + " NVE "
	cQryFrom   +=          " ON ( NVE.NVE_NUMCAS = NSZ.NSZ_NUMCAS "
	cQryFrom   +=         " AND NVE.NVE_CCLIEN = NSZ.NSZ_CCLIEN "
	cQryFrom   +=         " AND NVE.NVE_LCLIEN = NSZ.NSZ_LCLIEN "
	cQryFrom   +=         " AND NVE.NVE_FILIAL = '" + xFilial('NVE') + "' "
	cQryFrom   +=         " AND NVE.D_E_L_E_T_ = ' ' ) "
	cQryFrom   +=   " LEFT JOIN " + RetSqlName('RD0') + " RD0 "
	cQryFrom   +=          " ON ( RD0.RD0_CODIGO = NSZ.NSZ_CPART2 "
	cQryFrom   +=         " AND RD0.RD0_FILIAL =  '" + xFilial('RD0') + "' "
	cQryFrom   +=         " AND NSZ.NSZ_CPART2 <> ' ' "
	cQryFrom   +=         " AND RD0.D_E_L_E_T_ = ' ' ) "

	If lBenefic
		cQryFrom += " LEFT JOIN " + RetSqlName('NT9') + " NT9 "
		cQryFrom +=        " ON (NT9.NT9_CAJURI = NSZ.NSZ_COD "
		cQryFrom +=       " AND NT9.NT9_FILIAL = NSZ.NSZ_FILIAL "
		cQryFrom +=       " AND NT9.D_E_L_E_T_ = ' ') "
	EndIf

	cQryFrom   +=   " LEFT JOIN " + RetSqlName('O0M') + " O0M "
	cQryFrom   +=          " ON (O0M.O0M_CAJURI = NSZ.NSZ_COD "
	cQryFrom   +=         " AND O0M.O0M_FILIAL = NSZ.NSZ_FILIAL "
	cQryFrom   +=         " AND O0M.D_E_L_E_T_ = ' ') "
	cQryFrom   +=   " LEFT JOIN " + RetSqlName('O0N') + " O0N "
	cQryFrom   +=          " ON ( O0N_CSLDOC = O0M.O0M_COD  "
	cQryFrom   +=         " AND O0N.O0N_FILIAL = NSZ.NSZ_FILIAL "
	cQryFrom   +=         " AND O0N.D_E_L_E_T_ = ' ') "

	//Clausula WHERE
	// Filtar Filiais que o usuário possui acesso
	If ( VerSenha(114) .or. VerSenha(115) )
		cQryWhere := " WHERE NSZ.NSZ_FILIAL IN " + FORMATIN(aFilUsr[1],aFilUsr[2])
	Else
		cQryWhere := " WHERE NSZ.NSZ_FILIAL = '"+xFilial("NSZ")+"' "
	EndIf

	cQryWhere  +=    " AND NSZ.D_E_L_E_T_ = ' ' "
	 
	 //Restrições do usuário
	cQryWhere  += " AND NSZ.NSZ_TIPOAS IN ('"+ cAssJur+"') "
	cQryWhere  += VerRestricao(,, WsJGetTpAss("'013'" , .T.))

	Do Case
		Case cFilter ==  "aguardando"
			cQryWhere  += " AND O0N.O0N_STATUS = '1' "

		Case cFilter ==  "distribuicao"
			cQryWhere  += " AND NSZ.NSZ_CPART2 = ' ' "	

		Case cFilter == "loggedUsr"
			cQryWhere  += " AND RD0.RD0_USER = '"+AllTrim(__CUSERID)+"' "
		
		Case cFilter ==  "proxVenc"
			cQryWhere  += " AND NSZ.NSZ_DTCONC <= '" + DtoS( DataValida( Date() + 3 )) + "' "

		Case cFilter == "andamento"
			cQryWhere  +=  " AND NSZ.NSZ_CPART2 > '' AND NSZ.NSZ_SITUAC = '1'"
		
		Case cFilter == "filaANS" .AND. FWAliasInDic("O1B")
			cQryFrom += " INNER JOIN " + RetSqlName('O1B') + " O1B "
			cQryFrom +=         " ON ( O1B_FILIAL = NSZ.NSZ_FILIAL "
			cQryFrom +=              " AND O1B_CAJURI = NSZ.NSZ_COD "
			cQryFrom +=              " AND O1B.D_E_L_E_T_ = ' ' "
			cQryFrom +=              " AND (O1B.O1B_RESPOS LIKE '%" + '"status"' + ":" + '"4"' + "%' "
			cQryFrom +=                    " OR O1B.O1B_RESPOS LIKE '%" + '"status"' + ":" + '"5"' + "%' ) "
			cQryFrom +=            " ) "
	EndCase

	If !Empty(aSQLRest)
		cQryWhere += " AND ("+Ja162SQLRt(aSQLRest, , , , , , , , , cAssJur)+")"
	EndIf

	// Parâmetros
	If !Empty(cCajuri)
		cQryWhere  +=    " AND NSZ.NSZ_COD = '"+cCajuri+"' "
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
		//Número do demanda
		cExists   :=  " AND " + JurFormat("NSZ_IDENTI", .F.,.T.) + " LIKE '%" + cSearchKey + "%'"
		cExists   :=  " OR " + SUBSTR(JurGtExist(RetSqlName("NSZ"), cExists, "NSZ.NSZ_FILIAL"),5)
		cQryWhere += cExists

		If lBenefic
			//Código do beneficiário
			cExists   :=  " AND " + JurFormat("NT9_CODBEN", .T.,.T.) + " LIKE '%" + cSearchKey + "%'"
			cExists   :=  " OR " + SUBSTR(JurGtExist(RetSqlName("NT9"), cExists, "NSZ.NSZ_FILIAL"),5)
			cQryWhere += cExists
			//Nome do beneficiário
			cExists   :=  " AND " + JurFormat("NT9_NOME", .T.,.T.) + " LIKE '%" + cSearchKey + "%'"
			cExists   :=  " OR " + SUBSTR(JurGtExist(RetSqlName("NT9"), cExists, "NSZ.NSZ_FILIAL"),5)
			cQryWhere += cExists
		EndIf
		
		//Número do protocolo
		cExists   :=  " AND " + JurFormat("NSZ_NIRE", .F.,.T.) + " LIKE '%" + cSearchKey + "%' )"
		cExists   :=  " OR " + SUBSTR(JurGtExist(RetSqlName("NSZ"), cExists, "NSZ.NSZ_FILIAL"),5)
		cQryWhere += cExists

	EndIf

	//Clausula ORDER BY
	cQryOrder  :=  " ORDER BY NSZ.NSZ_COD "

	cQuery := ChangeQuery(cQrySelect + cQryFrom + cQryWhere + cQryOrder)

	cQuery := StrTran(cQuery,",' '",",''")

	RestArea( aAreaNT9 )
	RestArea( aArea )

Return cQuery


//-------------------------------------------------------------------
/*/{Protheus.doc} GET Qtdnips
Obtém a quantidade de NIPs por filtro

@param filter      Filtro a ser utilizado na lista de NIPs
                   'aguardando' | 'proxVenc' | 'filaANS' | 'distribuicao' | 'loggedUsr'

@author SIGAJURI
@since 17/06/2021

/*/
//-------------------------------------------------------------------
WSMETHOD GET Qtdnips WSRECEIVE filter WSREST JURNIP

Local oResponse  := JsonObject():New()
Local cFilter    := Self:filter
	
	Self:SetContentType("application/json")
	oResponse['nips'] := qtdFilter(cFilter)
	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} qtdFilter
Obtém a quantidade de registros por filtro

@param cFilter     Tipo de filtro
@return nRet       Quantidade de registros
@since 04/07/2021
/*/
//-------------------------------------------------------------------
Static Function qtdFilter(cFilter)
Local aArea      := GetArea()
Local nRet       := 0
Local cSelect    := ""
Local cFrom      := ""
Local cWhere     := ""
Local cQuery     := ""
Local cAlias     := GetNextAlias()

	cSelect := " SELECT COUNT(DISTINCT NSZ.NSZ_COD) QTD "
	cFrom   += " FROM " + RetSqlName('NSZ') + " NSZ "
	cWhere  := " WHERE NSZ.D_E_L_E_T_ = ' ' "
	cWhere  += " AND NSZ.NSZ_TIPOAS = '013' "

	Do Case
		Case cFilter == "aguardando"
			cFrom +=   " LEFT JOIN " + RetSqlName('O0M') + " O0M "
			cFrom +=          " ON (O0M.O0M_CAJURI = NSZ.NSZ_COD "
			cFrom +=         " AND O0M.O0M_FILIAL = NSZ.NSZ_FILIAL "
			cFrom +=         " AND O0M.D_E_L_E_T_ = ' ') "
			cFrom +=   " LEFT JOIN " + RetSqlName('O0N') + " O0N "
			cFrom +=          " ON ( O0N_CSLDOC = O0M.O0M_COD  "
			cFrom +=         " AND O0N.O0N_FILIAL = NSZ.NSZ_FILIAL "
			cFrom +=         " AND O0N.D_E_L_E_T_ = ' ') "

			cWhere   += " AND O0N.O0N_STATUS = '1' "

		Case cFilter ==  "distribuicao"
			cWhere   += " AND NSZ.NSZ_CPART2 = ' ' "

		Case cFilter ==  "proxVenc"
			cWhere  += " AND NSZ.NSZ_DTCONC <= '" + DtoS( DataValida( Date() + 3 ) ) + "' "
		
		Case cFilter == "andamento"
			cWhere  +=  " AND NSZ.NSZ_CPART2 > '' AND NSZ.NSZ_SITUAC = '1'"

		Case cFilter == "filaANS" .AND. FWAliasInDic("O1B")
			cFrom += " INNER JOIN " + RetSqlName('O1B') + " O1B "
			cFrom +=         " ON ( O1B_FILIAL = NSZ.NSZ_FILIAL "
			cFrom +=              " AND O1B_CAJURI = NSZ.NSZ_COD "
			cFrom +=              " AND O1B.D_E_L_E_T_ = ' ' "
			cFrom +=              " AND O1B.O1B_RESPOS LIKE '%" + '"status"' + ":" + '"4"' + "%' "
			cFrom +=            " ) "
	EndCase

	cQuery := ChangeQuery(cSelect + cFrom + cWhere)
	cQuery := StrTran(cQuery,",' '",",''")

	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

	If (cAlias)->(!Eof())
		nRet := (cAlias)->QTD
	EndIf

	(cAlias)->(DbCloseArea())
	
	RestArea(aArea)

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GET ModelResp
Efetua o download do arquivo modelo cadastrado

@param searchKey      Codigo do relatório
@since 21/07/2021

@example GET -> http://127.0.0.1:12173/rest/JURNIP/getModelResp/008

/*/
//-------------------------------------------------------------------
WSMETHOD GET GetModelResp PATHPARAM searchKey WSREST JURNIP
Local oResponse    := JsonObject():New()
Local lRet         := .T.
Local cCodRelat    := Self:searchKey
Local cNameRel     := AllTrim(JurGetDados("NQR", 1, xFilial("NQR") + cCodRelat, "NQR_NOMRPT")) 
Local cExtensao    := AllTrim(JurGetDados("NQR", 1, xFilial("NQR") + cCodRelat, "NQR_EXTENS"))
Local cLocalArq    := AllTrim( SuperGetMV('MV_MODPET',,"") )
Local cFiledata    := ""
Local aExtensao    := {'.RPT','.DOT', '.PRW', '.DOCX'}

	If Empty(cCodRelat)
		lRet := .F.
		SetRestFault(400,STR0005) // Código do relatório não informado
	Else
		If Empty(cLocalArq)
			cLocalArq := GetSrvProfString("StartPath", "\undefined")
		EndIf

		cExtensao := aExtensao[Val(cExtensao)]

		If File(cLocalArq + cNameRel + '_' + cCodRelat + cExtensao)
			cNameRel += '_' + cCodRelat
		EndIf

		cFiledata := encode64(DownloadBase(cLocalArq + cNameRel + cExtensao))

		If Empty(cFiledata)
			lRet := .F.
			SetRestFault(400, STR0006) // Arquivo não encontrado
		Else
			// Monta Json para o Download
			Self:SetContentType("application/json")
			oResponse['downloadModelo'] := {}
			Aadd(oResponse['downloadModelo'], JsonObject():New())
			oResponse['downloadModelo'][1]['namefile'] := JConvUTF8(cNameRel)
			oResponse['downloadModelo'][1]['filedata'] := cFiledata
			Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SetModelResp
Grava os dados do modelo de resposta da NIP e grava o arquivo na pasta
de acordo com a configuração

@param 	codModelo   Codigo do relatório
@param 	nOpc        Operacao
@param 	nomeModelo  nome do relatório

@example GET-> http://127.0.0.1:12173/rest/JURNIP/setModelResp?nOpc=3&codModelo=011&nomeModelo=xpto
@Return logico

@since 21/07/2021
/*/
//-------------------------------------------------------------------
WSMETHOD POST SetModelResp WsReceive codModelo, nOpc, nomeModelo WSREST JURNIP
Local oRequest  := JsonObject():New()
Local oResponse := JsonObject():New()
Local aRet      := {}
Local cName     := Self:nomeModelo

	//inicializando a configuração basica de retorno
	oResponse["lRet"]       := .T.
	oResponse["nStatus"]    := 0
	oResponse["codRelat"]   := ""
	oResponse["MsgRetorno"] := ""

	//Configuração basica da requisição
	oRequest["codRelat"]    := Self:codModelo
	oRequest["nOpc"]        := Self:nOpc
	oRequest["File"]        := JurSetFile(Self:GetContent())

	If( Empty(cName))
		oRequest["File"]["fileNewName"] := oRequest["File"]["fileOldName"]
	Else
		oRequest["File"]["fileNewName"] := cName
	EndIf

	oRequest["File"]["fileNewName"] := substr(oRequest["File"]["fileNewName"],1,Rat('.',oRequest["File"]["fileNewName"])-1)
	
	Begin Transaction

		aRet := SetNQR(oRequest["File"]["fileNewName"], oRequest["File"]["fileExtension"], Self:codModelo, Self:nOpc) 

		If !aRet[1]
			oResponse["lRet"] := .F.
			oResponse["MsgRetorno"] := aRet[2]
		Else
			oResponse["codRelat"] := aRet[2]

			If ! GravaArqDot(oResponse,oRequest)
				oResponse["lRet"] := .F.
			EndIf
		Endif

		If !oResponse["lRet"]
			DisarmTransaction()
			Break
		Endif

	End Transaction

	If oResponse["lRet"] 
		oResponse["nStatus"] := 201
		
		oResponse["MsgRetorno"] := oRequest["File"]["fileNewName"] 
		If Self:nOpc = 3
			oResponse["MsgRetorno"] += STR0008 // incluido com sucesso!
		else
			oResponse["MsgRetorno"] += STR0009 // alterado com sucesso!
		EndIf

		Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
	Else
		SetRestFault(oResponse["nStatus"], EncodeUTF8(_NoTags(oResponse["MsgRetorno"])))
	Endif

Return oResponse["lRet"] 

//------------------------------------------------------------------------------
/* /{Protheus.doc} SetNQR
Função responsavel pela gravação do modelo dot ou encontrado o registro correto
@type Static Function

@param cName     Nome do arquivo
@param cExtensao Extenção do arquivo (1=RPT;2=DOT;3=PRW;4=DOCX)
@param cCod      Código
@param nOpc      Operação

@since 09/04/2020
@version 1.0

@return aRet    Array de retorno
					aRet[1] Lógico - Sucesso ou Falha
					aRet[2] String - Código em caso de sucesso ou Mensagem de erro
/*/
//------------------------------------------------------------------------------
Static Function SetNQR(cName, cExtensao, cCod, nOpc)
Local aArea     := GetArea()
Local aAreaNQR  := NQR->(GetArea())
Local oModel    := nil
Local oMdlNQR   := nil
Local aExtencao := StrToArray(JurX3cBox('NQR_EXTENS'), ";") 
Local aRet      := {.T.,""}

Default cExtensao := '4' // .docx
Default cCod   := ""
Default nOpc   := 3

	If cExtensao != '4'
		If len(aExtencao) > 0
			cExtensao := cValToChar(aScan(aExtencao, {|x| Upper(StrTran(cExtensao,'.','')) $  Upper(x)} ))
		EndIf
	EndIf

	If nOpc == 3 .Or. nOpc == 4
		NQR->(DbSetOrder(1)) //NQR_FILIAL+NQR_COD

		If !Empty(cCod) .And. nOpc == 4 
			NQR->(DbSeek(xFilial('NQR')+cCod)) 
		EndIf

		oModel  := FwLoadModel('JURA003')
		oMdlNQR := oModel:GetModel("NQRMASTER")
		oModel:SetOperation(nOpc)

		If oModel:Activate()
			If Empty(oMdlNQR:GetValue('NQR_COD'))
				oMdlNQR:SetValue('NQR_COD', GetSxeNum('NQR','NQR_COD'))
			Endif

			aRet[2] := oMdlNQR:GetValue('NQR_COD') 

			oMdlNQR:SetValue('NQR_NOMRPT',cName,)
			oMdlNQR:SetValue('NQR_EXTENS',cExtensao)
			
			If !(oModel:VldData() .and. oModel:CommitData())
				aRet[1] := .F.
				aRet[2] := JurEncUTF8(JurModErro(oModel))
			EndIf

		EndIf
	EndIf

	RestArea(aAreaNQR)
	RestArea(aArea)

Return aRet

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
Local cFile   := ''
Local oFile   := oRequest["File"]

	cFile := oFile["filePath"]
	cFile += oFile["fileNewName"] + '_' + oResponse["codRelat"] 
	cFile += oFile["fileExtension"]

	IF (nHandle := FCREATE(cFile)) >= 0
		FWRITE(nHandle, oFile["fileContent"], oFile["nTamArquivo"])
		FCLOSE(nHandle)
	Else
		oResponse["lRet"]       := .F.
		oResponse["nStatus"]    := 400
		oResponse["MsgRetorno"] := STR0010 + cValToChar(FERROR()) //"Falha ao criar o arquivo, FERROR:"
	Endif

Return oResponse["lRet"]

//------------------------------------------------------------------------------
/* /{Protheus.doc} RenameDoc

Renomeia o arquivo modelo no diretório

@param codModelo  Código do relatório
@param nomeModelo Novo nome do relatório
@since 26/07/2021
@return oResponse

@example GET-> http://127.0.0.1:12173/rest/JURNIP/renameDoc?codModelo=011&nomeModelo=xpto 
/*/
//------------------------------------------------------------------------------
WSMETHOD PUT  RenameDoc WsReceive codModelo, nomeModelo WSREST JURNIP
Local oResponse := JsonObject():New()
Local cLocalArq    := AllTrim( SuperGetMV('MV_MODPET',,"") )
Local cOldName     := AllTrim(JurGetDados("NQR", 1, xFilial("NQR") + Self:codModelo, "NQR_NOMRPT"))
Local cExtensao    := AllTrim(JurGetDados("NQR", 1, xFilial("NQR") + Self:codModelo, "NQR_EXTENS"))
Local cFiledata    := ""
Local nHandle      := 0
Local aExtensao    := {'.RPT','.DOT', '.PRW', '.DOCX'}
Local lRet         := .T.

	If Empty(cLocalArq)
		cLocalArq := GetSrvProfString("StartPath", "\undefined")
	EndIf

	If Empty(cLocalArq)
		lRet := .F.
	Else

		cExtensao := aExtensao[Val(cExtensao)]

		If !(File(cLocalArq + cOldName + cExtensao))
			cOldName += '_' + Self:codModelo
		EndIf

		If File(cLocalArq + cOldName + cExtensao)
			cFiledata := DownloadBase(cLocalArq + cOldName + cExtensao)
			nHandle := FCREATE(cLocalArq + Self:nomeModelo + '_' + Self:codModelo + cExtensao)
			FWRITE(nHandle,cFiledata )
			FCLOSE(nHandle)
			FErase(cLocalArq + cOldName + cExtensao)
			SetNQR(Self:nomeModelo, cExtensao, Self:codModelo, 4)
			oResponse["lRet"] := .T.
			oResponse["nStatus"] := 201
		else
			lRet := .F.
		EndIf

	EndIf

	If lRet
		Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
	Else
		SetRestFault(400, STR0012) // "Falha ao gerar o arquivo"
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GET TpEnvolv
Obtém a quantidade de NIPs por filtro

@param searchKey      Descrição do Tipo de Envolvimento

@author SIGAJURI
@since 17/06/2021

/*/
//-------------------------------------------------------------------
WSMETHOD GET TpEnvolv WSRECEIVE searchKey WSREST JURNIP

Local oResponse  := JsonObject():New()
Local cDescTp    := Self:searchKey
	
	Self:SetContentType("application/json")
	oResponse['tipoEnvolvido'] := vldTpEnvNip(cDescTp)
	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} vldTpEnvNip
Verifica a o Tipo do envolvido existe na NQA
Caso não exista, faz a inclusão

@param cDescTp    Descrição do Tipo de Envolvimento
@since 05/08/2021
/*/
//-------------------------------------------------------------------
Function vldTpEnvNip(cDescTp)

Local aAreaNQA   := NQA->( GetArea() )
Local aTpEnvDado := {}
Local cRet       := ""
Local xRet       := JA009PLVDE(cDescTp, 'C')

	If VALTYPE(xRet) == 'L'
		aTpEnvDado := {}
		Do case
			Case cDescTp == STR0014 //"Interlocutor"
				aTpEnvDado := {STR0014, "2", "2", "1"}
			Case cDescTp == STR0015 //"Beneficiário"
				aTpEnvDado := {STR0015, "1", "2", "2"}
			Case cDescTp == STR0016 //"Operadora"
				aTpEnvDado := {STR0016, "2", "1", "2"}
		EndCase

		If !Empty(aTpEnvDado)
			cRet := GETSXENUM("NQA","NQA_COD")

			NQA->(Reclock( 'NQA', .T. ))
				NQA->NQA_FILIAL := xFilial('NQA')
				NQA->NQA_COD    := cRet
				NQA->NQA_DESC   := Alltrim(cDescTp)
				NQA->NQA_POLOAT := aTpEnvDado[2]
				NQA->NQA_POLOPA := aTpEnvDado[3]
				NQA->NQA_TERCIN := aTpEnvDado[4]
			NQA->(MsUnlock())

			If __lSX8
				ConfirmSX8()
			EndIf
		EndIf

	Else
		cRet := xRet
	EndIf

	NQA->( RestArea( aAreaNQA ) )

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GET getAnswer
Busca os dados da resposta de uma NIP

@param cajuri      Codigo da NIP
@since 18/08/2021

@example GET -> http://127.0.0.1:12173/rest/JURNIP/getAnswer/0000000008
@Return oResponse: 
	{
		cajuri: 0000000008,
		resposta: { 
					status: "P",  // "P"endende, "R"evisar , "A"provado
					anexos:[
								{
									codDoc: "0000000004",
									nomeEnt: "NTA",
									codEntidade="00000001"
								}
							],
				  }
	}

/*/
//-------------------------------------------------------------------
WSMETHOD GET GetAnswer PATHPARAM cajuri WSREST JURNIP
Local aArea     := GetArea()
Local oResponse := JsonObject():New()
Local cCajuri   := Decode64(Self:cajuri)
Local cResposta := ""
Local lRet      := .T.

	Self:SetContentType("application/json")
	oResponse['cajuri'] := cCajuri
	oResponse['resposta'] := JsonObject():New()

	If FWAliasInDic("O1B") .AND. Chkfile("O1B")
		If !Select("O1B")
			dbSelectArea("O1B")
		EndIf

		O1B->(DbSetOrder(1)) //O1B_FILIAL+O1B_CAJURI

		If O1B->(DbSeek(xFilial('O1B') + cCajuri))

			cResposta := JConvUTF8(O1B->O1B_RESPOS) 
			If !Empty(cResposta)
				oResponse['resposta']:FromJson(O1B->O1B_RESPOS) 
			EndIf
		EndIf

		dbCloseArea() 
	Else
		lRet := .F.
		SetRestFault(400, STR0019) //"Tabela de Respostas 'O1B' não encontrada!" 
	EndIf

	If lRet
		Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
	EndIf

	RestArea( aArea )
 
Return lret 


//-------------------------------------------------------------------
/*/{Protheus.doc} SET SetAnswer
Seta os dados da resposta de uma NIP

@param cajuri      Codigo da NIP
@since 18/08/2021

@example PUT -> http://127.0.0.1:12173/rest/JURNIP/setAnswer/0000000008
@body  {
	"resposta": {
		"status": "A",
		"anexos": [
			{
				"nomeEnt": "NTA",
				"codEntidade": "teste",
				"codDoc": "0000000005"
			}
		]
	},
	"cajuri": "0000000008"
}
@Return oResponse: 
	{
		cajuri: 0000000008,
		resposta: { 
					status: "P",  // "P"endende, "R"evisar , "A"provado
					anexos:[
								{
									codDoc: "0000000004",
									nomeEnt: "NTA",
									codEntidade="00000001"
								}
							],
				  }
	}

/*/
//-------------------------------------------------------------------
WSMETHOD PUT SetAnswer PATHPARAM cajuri WSREST JURNIP
Local aArea     := GetArea()
Local oResponse := JsonObject():New()
Local oError    := Nil
Local cCajuri   := Decode64(Self:cajuri)
Local lRet      := .T.
Local lInsere   := .F.

	Self:SetContentType("application/json")
	oResponse['cajuri'] := cCajuri
	oResponse['resposta'] := JsonObject():New()
	oResponse['resposta']:FromJson(Self:GetContent()) 

	If FWAliasInDic("O1B") .AND. Chkfile("O1B")
		If !Select("O1B")
			dbSelectArea("O1B")
		EndIf

		O1B->(DbSetOrder(1)) //O1B_FILIAL+O1B_CAJURI
		lInsere := !DbSeek( xFilial('O1B') + cCajuri )

		TRY EXCEPTION
			RecLock("O1B", lInsere )
				O1B->O1B_FILIAL := xFilial("O1B")	
				O1B->O1B_CAJURI := cCajuri
				O1B->O1B_RESPOS := Self:GetContent()
			MsUnLock() // Confirma e finaliza a operação
		CATCH EXCEPTION USING oError
			sleep(500)
			lInsere := !DbSeek( xFilial('O1B') + cCajuri )
			RecLock("O1B", lInsere )
				O1B->O1B_FILIAL := xFilial("O1B")	
				O1B->O1B_CAJURI := cCajuri
				O1B->O1B_RESPOS := Self:GetContent()
			MsUnLock() // Confirma e finaliza a operação
		ENDTRY

		dbCloseArea()

	Else
		lRet := .F.
		SetRestFault(400, STR0019) //"Tabela de Respostas 'O1B' não encontrada!"
	EndIf
 
	If lRet
		Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
	EndIf

	RestArea( aArea )

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} GET QtdEvolution
Obtém a quantidade de NIPs em andamento, novos, encerrados (últimos 12 meses)

@example GET -> http://localhost:12173/rest/JURNIP/qtdEvolution
@since 14/10/2021
/*/
//-------------------------------------------------------------------
WSMETHOD GET QtdEvolution WSREST JURNIP

Local oResponse  := JsonObject():New()
	
	Self:SetContentType("application/json")
	oResponse := qtdFilterEvo()
	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} qtdFilterEvo
Obtém a quantidade de NIPs em andamento, novos, encerrados (últimos 12 meses)

@return oResponse  Resposta com quantidade das nips em andamento, novas e encerradas.
	{
		evolution: [{
			mesano: 01/01/2021,
			novos: 0,
			encerrados: 0,
			andamento: 3
		},
		{
			mesano: 01/02/2021,
			novos: 1,
			encerrados: 0,
			andamento: 4
		}]
	}
@since 14/10/2021
/*/
//-------------------------------------------------------------------
Static Function qtdFilterEvo()
Local dData      := Date()
Local dDataIni   := DToS(FirstDate( MonthSub( dData , 11 ) ))
Local aArea      := GetArea()
Local aFilUsr    := JURFILUSR( __CUSERID, "NSZ" )
Local aMov       := {}
Local oResponse  := JsonObject():New()
Local cNSZName   := Alltrim(RetSqlName("NSZ"))
Local cAlias     := GetNextAlias()
Local cSelect    := ""
Local cQry       := ""
Local cFrom      := ""
Local cWhere     := ""
Local cQuery     := ""
Local nQtdAnd    := 0
Local nJ         := 0
Local nI         := 0

	cSelect := " SELECT COUNT(1) AS QTD "
	cFrom   += " FROM " + RetSqlName('NSZ') + " NSZ "
	cWhere  := " WHERE NSZ.D_E_L_E_T_ = ' ' "
	cWhere  += " AND NSZ.NSZ_TIPOAS = '013' "
	cWhere  += " AND (NSZ.NSZ_DTINCL < '" + dDataIni + "'"
	cWhere  += " AND (NSZ.NSZ_SITUAC = '1' OR NSZ.NSZ_DTENCE > '" + dDataIni + "'))"

	// Filtar Filiais que o usuário possui acesso
	If ( VerSenha(114) .or. VerSenha(115) )
		cWhere += " AND NSZ.NSZ_FILIAL IN " + FORMATIN(aFilUsr[1],aFilUsr[2])
	Else
		cWhere += " AND NSZ.NSZ_FILIAL = '"+xFilial("NSZ")+"'"
	Endif

	cQuery := ChangeQuery(cSelect + cFrom + cWhere)
	cQuery := StrTran(cQuery,",' '",",''")

	dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .T., .F. )

	While !(cAlias)->(Eof())
		nQtdAnd := (cAlias)->QTD
		(cAlias)->( dbSkip() )
	End
	
	(cAlias)->( dbcloseArea() )
	cAlias     := GetNextAlias()

	// Busca o consolidado mês a mês dos casos novos e encerrados
	cQry   := "SELECT COALESCE(NOVOS.ANOMES, ENCERRADOS.ANOMES) MES, "
	cQry   +=        "COALESCE(NOVOS.QTD,0) AS NOVO, "
	cQry   +=        "COALESCE(ENCERRADOS.QTD,0) AS ENCERRADO "

	cFrom  :=   "FROM (SELECT COUNT(1) AS QTD , "
	cFrom  +=               " CONCAT(SUBSTRING(NSZA.NSZ_DTINCL,1,6),'01') AS ANOMES "
	cFrom  +=          " FROM "+ cNSZName + " NSZA"
	cFrom  +=         " WHERE NSZA.D_E_L_E_T_ = ' ' "

	// Filtar Filiais que o usuário possui acesso
	If ( VerSenha(114) .or. VerSenha(115) )
		cFrom += " AND NSZA.NSZ_FILIAL IN " + FORMATIN(aFilUsr[1],aFilUsr[2])
	Else
		cFrom += " AND NSZA.NSZ_FILIAL = '"+xFilial("NSZ")+"'"
	Endif

	cFrom += " AND NSZ_TIPOAS = '013' "
	cFrom  +=        " GROUP BY CONCAT(SUBSTRING(NSZA.NSZ_DTINCL,1,6),'01')) NOVOS "
	cFrom  += " FULL JOIN (SELECT COUNT(1) AS QTD , "
	cFrom  +=                   " CONCAT(SUBSTRING(NSZB.NSZ_DTENCE,1,6),'01') AS ANOMES "
	cFrom  +=               "FROM "+ cNSZName + " NSZB "
	cFrom  +=             " WHERE NSZB.NSZ_SITUAC = '2' "
	cFrom  +=               " AND NSZB.D_E_L_E_T_ = ' ' "

	// Filtar Filiais que o usuário possui acesso
	If ( VerSenha(114) .or. VerSenha(115) )
		cFrom += " AND NSZB.NSZ_FILIAL IN " + FORMATIN(aFilUsr[1],aFilUsr[2])
	Else
		cFrom += " AND NSZB.NSZ_FILIAL = '"+xFilial("NSZ")+"'"
	Endif

	cFrom += " AND NSZ_TIPOAS = '013' "
	cFrom  +=              "GROUP BY CONCAT(SUBSTRING(NSZB.NSZ_DTENCE,1,6),'01')) ENCERRADOS "
	cFrom  +=    " ON NOVOS.ANOMES = ENCERRADOS.ANOMES "
	cWhere := " WHERE COALESCE(NOVOS.ANOMES, ENCERRADOS.ANOMES) <= '" + DTOS(dData) + "' "
	cWhere +=   " AND COALESCE(NOVOS.ANOMES, ENCERRADOS.ANOMES) >= '" + dDataIni + "' "
	cWhere += " ORDER BY MES ASC"

	cQry := ChangeQuery(cQry+cFrom+cWhere)
	dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cQry ) , cAlias, .T., .F.)

	If !(cAlias)->(Eof())
		dfirstMonth := (cAlias)->MES
	EndIf

	// Inclui as movimentações somando a quantidade de andamentos
	While !(cAlias)->(Eof())
		nQtdAnd := (nQtdAnd + (cAlias)->NOVO - (cAlias)->ENCERRADO)
		aAdd( aMov, {AllTrim((cAlias)->MES), (cAlias)->NOVO, (cAlias)->ENCERRADO, nQtdAnd})
		(cAlias)->( dbSkip() )
	End

	(cAlias)->( dbcloseArea() )

	//Monta o Json com os valores para os 12 mêses
	dData := FirstDate( MonthSub( dData , 11 ) )
	nJ := Len(aMov)
	
	//Verifica se a primeira data é diferente do primeiro dia
	If Stod(dfirstMonth) != dData
		nQtdAnd := 0
	EndIf

	oResponse['evolution'] := {}
	oResponse['operation'] := "StockEvolution"
	
	// Loop do Mês a Mês
	For nI := 1 to 12
		Aadd(oResponse['evolution'], JsonObject():New())
		oResponse['evolution'][nI]['mesano']      := AllTrim(DToS(dData))
		oResponse['evolution'][nI]['novos']       := 0
		oResponse['evolution'][nI]['encerrados']  := 0
		oResponse['evolution'][nI]['andamento']   := nQtdAnd

		// Verifica se houve geração de NIPs e qual a posição no Array
		nJ := aScan(aMov,{|x| AllTrim(x[1]) == AllTrim(DToS(dData))})

		If (nJ > 0)
			// Atualiza a Quantidade de Andamentos
			nQtdAnd := aMov[nJ][4]

			// Inclui os valores
			oResponse['evolution'][nI]['novos']      := aMov[nJ][2]
			oResponse['evolution'][nI]['encerrados'] := aMov[nJ][3]
			oResponse['evolution'][nI]['andamento']  := nQtdAnd
		EndIf

		// Adiciona 1 mês
		dData := MonthSum( dData , 1 )
	Next nI

	RestArea(aArea)

Return oResponse


//-------------------------------------------------------------------
/*/{Protheus.doc} GET QtdGraphFilter
Obtém a quantidade e descrição da natureza, status, assunto e índice de sucesso das NIPs

@example GET -> http://localhost:12173/rest/JURNIP/qtdGraphFilter
@param filter  Filtro por período
@return .T.    True
@author SIGAJURI
@since 17/06/2021

/*/
//-------------------------------------------------------------------
WSMETHOD GET QtdGraphFilter WSRECEIVE filter WSREST JURNIP

Local oResponse  := JsonObject():New()
Local cFilter    := Self:filter
	
	Self:SetContentType("application/json")
	oResponse := qtdFilt(cFilter)
	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} qtdFilter
Obtém a quantidade de NIPs agrupadas por natureza, status, assunto
e índice de sucesso.

@param cFilter     Filtro por período
@return oResponse  Dados agrupados por quantidades com sua respectiva descrição
	{
		natureza: [
			[8, "Assistencial],
			[5, "Aguardando resposta]
		]
		,
		status: [
			[8, "FINALIZADAS],
			[2, "Cadastrada]
		],
		assunto: [
			[8, "Contratação/Adesão,Vigência", "Contratação/Adesão,Vigência, Manutenção e Renovação"],
			[1, "Suspensão e Rescisão", "Suspensão e Rescisão Contratuais"]
		],
		indSucesso: [
			[8, "Decisão Favorável"],
			[3, "Outro"]
		]
	}
@since 14/10/2021
/*/
//-------------------------------------------------------------------
Static Function qtdFilt(cFilter)
Local oResponse  := JsonObject():New()
Local dDataIni   := FirstDate( MonthSub( Date() , 11 ) )

Default cFilter  := " NSZ_DTINCL >= '" + DToS(dDataIni) + "' AND NSZ_DTINCL <= '" + DToS(LastDay(Date())) + "' "

	oResponse['natureza']   := indNatureza(cFilter)
	oResponse['status']     := indStatusANS(cFilter)
	oResponse['assunto']    := indAssunto(cFilter)
	oResponse['indSucesso'] := indSucess(cFilter)

Return oResponse

//-------------------------------------------------------------------
/*/{Protheus.doc} indNatureza
Obtém a quantidade de NIPs agrupadas por Natureza com suas descrições

@param cFilter     Filtro por data
@return aMov       Array com a quantidade, descrição - Natureza NIPS
Exemplo: [[8, "Assistencial]]
@since 14/10/2021
/*/
//-------------------------------------------------------------------
Static Function indNatureza(cFilter)
Local aArea      := GetArea()
Local aMov       := {}
Local cAlias     := GetNextAlias()
Local cQuery     := ""
Local cDesc      := ""
Local nI         := 0

	cQuery := " SELECT COUNT(1) QTD, "
	cQuery +=        " NSZ_OBJSOC DESCRICAO "
	cQuery += " FROM " + RetSQLName("NSZ") + " NSZ "
	cQuery += " WHERE NSZ_TIPOAS = '013' "
	cQuery +=        " AND " + cFilter
	cQuery +=        " AND NSZ.D_E_L_E_T_ = ' ' "
	cQuery += " GROUP BY NSZ.NSZ_OBJSOC "
	cQuery += " ORDER BY QTD DESC "

	cQuery := ChangeQuery(cQuery)
	cQuery := StrTran(cQuery,",' '",",''")

	dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .T., .F. )

	//Busca apenas os 5 primeiros da requisição
	While !(cAlias)->(Eof()) .AND. nI < 5

		cDesc := AllTrim((cAlias)->DESCRICAO)
		cDesc := IIF( VALTYPE(EncodeUtf8( cDesc )) <> "U", EncodeUtf8( cDesc ), cDesc )

		aAdd( aMov, {(cAlias)->QTD, ;
					cDesc ;
					} )
		(cAlias)->( dbSkip() )
		nI++
	End

	(cAlias)->( dbcloseArea() )

	RestArea(aArea)

Return aMov


//-------------------------------------------------------------------
/*/{Protheus.doc} indStatusANS
Obtém a quantidade de NIPs agrupadas por Status ANS com suas descrições

@param cFilter     Filtro por data
@return aMov       Array com a quantidade, descrição - Status ANS
Exemplo: [[8, "FINALIZADAS]]
@since 14/10/2021
/*/
//-------------------------------------------------------------------
Static Function indStatusANS(cFilter)
Local aArea      := GetArea()
Local aMov       := {}
Local cAlias     := GetNextAlias()
Local cQuery     := ""
Local cDesc      := ""
Local nI         := 0

	cQuery := " SELECT COUNT(1) QTD, "
	cQuery +=        " NSZ_ULTCON DESCRICAO "
	cQuery += " FROM " + RetSQLName("NSZ") + " NSZ "
	cQuery += " WHERE NSZ_TIPOAS = '013' "
	cQuery +=        " AND " + cFilter
	cQuery +=        " AND NSZ.D_E_L_E_T_ = ' ' "
	cQuery += " GROUP BY NSZ.NSZ_ULTCON "
	cQuery += " ORDER BY QTD DESC "

	cQuery := ChangeQuery(cQuery)
	cQuery := StrTran(cQuery,",' '",",''")

	dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .T., .F. )

	//Busca apenas os 5 primeiros da requisição
	While !(cAlias)->(Eof()) .AND. nI < 5
		
		cDesc := AllTrim((cAlias)->DESCRICAO)
		cDesc := IIF( VALTYPE(EncodeUtf8( cDesc )) <> "U", EncodeUtf8( cDesc ), cDesc )

		aAdd( aMov, {(cAlias)->QTD, ;
					cDesc ;
					} )
		(cAlias)->( dbSkip() )
		nI++
	End

	(cAlias)->( dbcloseArea() )

	RestArea(aArea)

Return aMov

//-------------------------------------------------------------------
/*/{Protheus.doc} indAssunto
Obtém a quantidade de NIPs agrupadas por assuntos com suas descrições

@param cFilter     Filtro por data
@return aMov       Array com a quantidade, descrição penquena e grande - Assunto NIP 
Exemplo: [[8, "Contratação/Adesão,Vigência", "Contratação/Adesão,Vigência, Manutenção e Renovação"]]
@since 14/10/2021
/*/
//-------------------------------------------------------------------
Static Function indAssunto(cFilter)
Local aArea      := GetArea()
Local aMov       := {}
Local cAlias     := GetNextAlias()
Local cQuery     := ""
Local cDesc      := ""
Local cDescLonga := ""
Local nI         := 0
Local nPos       := 0

	cQuery := " SELECT COUNT(1) QTD, "
	cQuery +=        " NSZ_TOMBO DESCRICAO "
	cQuery += " FROM " + RetSQLName("NSZ") + " NSZ "
	cQuery += " WHERE NSZ_TIPOAS = '013' "
	cQuery +=        " AND " + cFilter
	cQuery +=        " AND NSZ.D_E_L_E_T_ = ' ' "
	cQuery += " GROUP BY NSZ.NSZ_TOMBO "
	cQuery += " ORDER BY QTD DESC "

	cQuery := ChangeQuery(cQuery)
	cQuery := StrTran(cQuery,",' '",",''")

	dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .T., .F. )

	//Busca apenas os 5 primeiros da requisição
	While !(cAlias)->(Eof()) .AND. nI < 5

		cDescLonga := AllTrim((cAlias)->DESCRICAO)
		cDescLonga := IIF( VALTYPE(EncodeUtf8( cDescLonga )) <> "U", EncodeUtf8( cDescLonga ), cDescLonga )

		//Busca a posição do segundo item: ">>"
		nPos :=  At( '>>', cDescLonga, 21 )

		If nPos > 0
			//Guarda apenas as 30 palavras após o segundo ">>"
			cDesc := Substr(cDescLonga, nPos + 3, nPos + 30)
		Else
			cDesc := cDescLonga
		EndIf

		aAdd( aMov, {(cAlias)->QTD, ;
					cDesc, ;
					cDescLonga ;
					} )
		(cAlias)->( dbSkip() )
		nI++
	End

	(cAlias)->( dbcloseArea() )

	RestArea(aArea)

Return aMov

//-------------------------------------------------------------------
/*/{Protheus.doc} indSucess
Obtém a quantidade de NIPs agrupadas por índice de sucesso, a partir
do motivo de encerramento

@param cFilter     Filtro data
@return aMov       Array com a quantidade e a descrição - Índice de sucesso
Exemplo: [[8, "Decisão Favorável"]]
@since 14/10/2021
/*/
//-------------------------------------------------------------------
Static Function indSucess(cFilter)
Local aArea      := GetArea()
Local aMov       := {}
Local cAlias     := GetNextAlias()
Local cQuery     := ""
Local cDesc      := ""
Local nI         := 0

	cQuery := " SELECT COUNT(1) QTD, "
	cQuery +=        " NQI_DESC DESCRICAO "
	cQuery += " FROM " + RetSQLName("NSZ") + " NSZ "
	cQuery +=         " INNER JOIN " + RetSQLName("NQI") + " NQI "
	cQuery +=              " ON NQI.NQI_FILIAL = '" + xFilial("NQI") + "' "
	cQuery +=                   " AND NQI.NQI_COD = NSZ.NSZ_CMOENC "
	cQuery +=                   " AND NQI.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE NSZ_TIPOAS = '013' "
	cQuery +=       " AND NSZ_DTENCE > ' ' "
	cQuery +=       " AND NSZ_SITUAC = '2' "
	cQuery +=       " AND " + StrTran(cFilter, "NSZ_DTINCL", "NSZ_DTENCE")
	cQuery +=       " AND NSZ.D_E_L_E_T_ = ' ' "
	cQuery += " GROUP BY NQI.NQI_DESC "
	cQuery += " ORDER BY QTD DESC "

	cQuery := ChangeQuery(cQuery)
	cQuery := StrTran(cQuery,",' '",",''")

	dbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .T., .F. )

	//Busca apenas os 5 primeiros da requisição
	While !(cAlias)->(Eof()) .AND. nI < 5

		cDesc := AllTrim((cAlias)->DESCRICAO)
		cDesc := IIF( VALTYPE(EncodeUtf8( cDesc )) <> "U", EncodeUtf8( cDesc ), cDesc )

		aAdd( aMov, {(cAlias)->QTD, ;
					cDesc ;
					} )
		(cAlias)->( dbSkip() )
		nI++
	End

	(cAlias)->( dbcloseArea() )

	RestArea(aArea)

Return aMov


//-------------------------------------------------------------------
/*/{Protheus.doc} GET UltAtuNip
Busca informações para o histórico da NIP

@param pageSize   quantidade de datas de atualização a serem adicionadas ao response

@example GET -> http://localhost:12173/rest/JURNIP/latestUpdNip
@return .T.    True
@author SIGAJURI
@since 09/11/2021

/*/
//-------------------------------------------------------------------
WSMETHOD GET UltAtuNip WSRECEIVE pageSize, filter WSREST JURNIP

Local oResponse  := JsonObject():New()
Local nPageSize  := Self:pageSize
Local cFilter    := Self:filter
	
	Self:SetContentType("application/json")
	oResponse := LastUpdNIP(nPageSize, cFilter)
	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} LastUpdNIP()
Obtém o Json com as informações das atualizações de NIPs (NT4_ANDAUT = '1')

@param nPageSize  quantidade de datas de atualização a serem adicionadas ao response
@param cFilter    data a ser filtrada
@return oResponse  Json com a data da inclusão e informações
	[{
	"lengthDate" : "10", //Quantidade de datas
	"lengthHist" : "60", //Quantidade de andamentos
	"dataInc" : "20211109",
	"histInfo" : [
		{
			"demanda":"x",
			"beneficiario":"x",
			"status":"x",
			"resumo":"x",
			"documentos": {
				"nameDocument":"x",
				"number":"x",
				"codeEntity":"x",
				"extension":"x",
				"nameEntity":"x",
				"codeDocument":"x",
				"entity":"x",
				"dateInsert":"x",
			}
		},
		]
	},]
@since 09/11/2021
/*/
//-------------------------------------------------------------------
Static Function LastUpdNIP(nPageSize, cFilter)
Local oResponse  := JsonObject():New()
Local oDoc       := JsonObject():New()
Local aArea      := GetArea()
Local cQuery     := ""
Local cDataAtual := ""
Local cAlias     := GetNextAlias()
Local nDate      := 0
Local nHist      := 0
Local nTotHist   := 0

	// Monta a query da NSZ
	cQuery := QryUltAtu(nPageSize, cFilter)
	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )
	
	oResponse["atualizacoes"] := {}

	While !(cAlias)->(Eof())

		If cDataAtual != (cAlias)->(DATE)
			nDate++
			nHist := 1 // reinicia a contagem de historicos (andamentos)
			Aadd(oResponse['atualizacoes'], JsonObject():New())
			oResponse["atualizacoes"][nDate]["dataInc"]  := (cAlias)->(DATE)
			oResponse["atualizacoes"][nDate]["histInfo"] := {}
		EndIf
		
		Aadd(oResponse["atualizacoes"][nDate]["histInfo"], JsonObject():New())
		oResponse["atualizacoes"][nDate]["histInfo"][nHist]["demanda"]      := JConvUTF8((cAlias)->(DEMANDA))
		oResponse["atualizacoes"][nDate]["histInfo"][nHist]["beneficiario"] := JConvUTF8((cAlias)->(BENEFICIARIO))
		oResponse["atualizacoes"][nDate]["histInfo"][nHist]["status"]       := JConvUTF8((cAlias)->(STATUS))
		oResponse["atualizacoes"][nDate]["histInfo"][nHist]["resumo"]       := JConvUTF8((cAlias)->(RESUMO))
		oResponse["atualizacoes"][nDate]["histInfo"][nHist]["cajuri"]       := JConvUTF8((cAlias)->(NT4_CAJURI))
		oResponse["atualizacoes"][nDate]["histInfo"][nHist]["codigo"]       := JConvUTF8((cAlias)->(NT4_COD))
		oResponse["atualizacoes"][nDate]["histInfo"][nHist]["filial"]       := (cAlias)->(NT4_FILIAL)
		
		//Documentos (NUM)
		oDoc := JsonObject():New()
		oDoc['nameDocument'] := JConvUTF8((cAlias)->NUM_DOC)
		oDoc['number']       := JConvUTF8((cAlias)->NUM_NUMERO)
		oDoc['codeEntity']   := JConvUTF8((cAlias)->NUM_CENTID)
		oDoc['extension']    := JConvUTF8((cAlias)->NUM_EXTEN)
		oDoc['nameEntity']   := JConvUTF8((cAlias)->NUM_ENTIDA)
		oDoc['codeDocument'] := JConvUTF8((cAlias)->NUM_COD)
		oDoc['entity']       := JConvUTF8((cAlias)->NUM_ENTIDA)
		oDoc['dateInsert']   := JConvUTF8((cAlias)->NUM_DTINCL)

		oResponse["atualizacoes"][nDate]["histInfo"][nHist]["documentos"] := oDoc			
		nHist++

		nTotHist++

		cDataAtual := (cAlias)->(DATE)
		
		(cAlias)->(DbSkip())
	End

	(cAlias)->(DbCloseArea())

	oResponse['lengthDate']  := nDate
	oResponse['lengthHist']  := nTotHist

	RestArea(aArea)

Return oResponse

//-------------------------------------------------------------------
/*/{Protheus.doc} QryUltAtu
Monta a query de ultimas atualizaçãoes NIP ou apenas a quantidade

@param nPageSize   Quantidade de dias para trás do Filter
@param cFilter     Filtro por data
@param lOnlyQtd    Query apenas para quantidade
@return aMov       Array com a quantidade, descrição penquena e grande - Assunto NIP 
Exemplo: [[8, "Contratação/Adesão,Vigência", "Contratação/Adesão,Vigência, Manutenção e Renovação"]]
@since 14/10/2021
/*/
//-------------------------------------------------------------------
Static Function QryUltAtu(nPageSize, cFilter, lOnlyQtd)

Local cQuery     := ""
Local cSelect    := ""
Local cFrom      := ""
Local cWhere     := ""
Local aFilUsr    := JURFILUSR( __CUSERID, "NSZ" )

Default lOnlyQtd := .F.

	If lOnlyQtd
		cSelect += " SELECT COUNT(1) QTD"
	Else
		cSelect += " SELECT NT4_RESUMO  RESUMO,"
		cSelect +=         " NSZ_IDENTI  DEMANDA, "
		cSelect +=         " NSZ_ULTCON  STATUS, "
		cSelect +=         " NT9_NOME    BENEFICIARIO, "
		cSelect +=         " NT4_DTINCL  DATE, "
		cSelect +=         " NT4_CAJURI, "
		cSelect +=         " NT4_COD, "
		cSelect +=         " NT4_FILIAL, "
		//NUM
		cSelect +=         " NUM_DOC, "
		cSelect +=         " NUM_NUMERO, "
		cSelect +=         " NUM_COD, "
		cSelect +=         " NUM_CENTID, "
		cSelect +=         " NUM_EXTEN, "
		cSelect +=         " NUM_ENTIDA, "
		cSelect +=         " NUM_DESC, "
		cSelect +=         " NUM_DTINCL "
	EndIf

	cFrom += 		" FROM " + RetSqlName('NSZ') + " NSZ "
	cFrom +=   " JOIN " + RetSqlName('NT4') + " NT4 "
	cFrom += 		" ON ( NT4.NT4_ANDAUT = '1' "
	cFrom += 		" AND  NT4.NT4_CAJURI = NSZ.NSZ_COD "
	cFrom += 		" AND  NT4.NT4_FILIAL = NSZ.NSZ_FILIAL "
	cFrom += 		" AND  NT4.D_E_L_E_T_ = ' ' ) "

	cFrom +=  " LEFT JOIN " + RetSqlName('NUM') + " NUM "
	cFrom +=  		" ON  ( NT4.NT4_COD = NUM.NUM_CENTID "
	cFrom += 		" AND   NUM.NUM_DESC = NT4.NT4_RESUMO "
	cFrom +=  		" AND   NUM.NUM_ENTIDA = 'NT4' "
	cFrom += 		" AND   NUM.D_E_L_E_T_ = ' ' ) "

	cFrom +=  " LEFT JOIN " + RetSqlName('NT9') + " NT9 "
	cFrom +=  		" ON  ( NT9.NT9_CAJURI = NSZ.NSZ_COD "
	cFrom += 		" AND   NT9.NT9_FILIAL = NSZ.NSZ_FILIAL "
	cFrom += 		" AND   NT9.NT9_TIPOEN = '1' "
	cFrom += 		" AND   NT9.NT9_ENTIDA = 'NZ2' "
	cFrom +=  		" AND   NT9.D_E_L_E_T_ = ' ' ) "

	// Filtar Filiais que o usuário possui acesso
	If ( VerSenha(114) .or. VerSenha(115) )
		cWhere := " WHERE NSZ.NSZ_FILIAL IN " + FORMATIN(aFilUsr[1],aFilUsr[2])
	Else
		cWhere := " WHERE NSZ.NSZ_FILIAL = '"+xFilial("NSZ")+"'"
	Endif

	cWhere +=  " AND NT4.NT4_DTINCL >  '" + JurDtAdd( cFilter, "D", nPageSize * -1 ) + "'"
	cWhere +=  " AND NT4.NT4_DTINCL <=  '" + cFilter + "'"

	cWhere += " AND NSZ.NSZ_TIPOAS = '013' "
	cWhere += " AND NSZ.D_E_L_E_T_ = ' ' "

	If !lOnlyQtd
		cWhere += " ORDER BY NT4.NT4_DTINCL DESC "
	Endif

	cQuery := ChangeQuery(cSelect + cFrom + cWhere)
	cQuery := StrTran(cQuery,",' '",",''")

Return cQuery


//-------------------------------------------------------------------
/*/{Protheus.doc} GET QtdAtuNip
Busca a quantidade de NIPs

@param nPageSize  quantidade de datas de atualização a serem adicionadas ao response
@param cFilter    data a ser filtrada
@example GET -> http://localhost:12173/rest/JURNIP/qtdAtuNip
@return .T.    True
@author SIGAJURI
@since 09/11/2021

/*/
//-------------------------------------------------------------------
WSMETHOD GET QtdAtuNip WSRECEIVE pageSize, filter WSREST JURNIP
Local oResponse  := JsonObject():New()
Local nPageSize  := Self:pageSize
Local cFilter    := Self:filter
	
	Self:SetContentType("application/json")
	oResponse := GetQtdAtu(nPageSize, cFilter)
	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} GetQtdAtu()
Retorna a quantidade de andamentos pelo filtro

@param cFilter    Data desejada
@param nPageSize  Quantidade de dias anteriores ao cFilter

@return oResponse  Json com a quantidade de andamentos em um período
	[{
	"lengthHist" : 20,
	}]
@since 12/11/2021
/*/
//-------------------------------------------------------------------
Static Function GetQtdAtu(nPageSize, cFilter)
Local oResponse  := JsonObject():New()
Local aArea      := GetArea()
Local cQuery     := ""
Local cAlias     := GetNextAlias()

	// Monta a query da quantidade
	cQuery := QryUltAtu(nPageSize, cFilter, .T.)
	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

	While !(cAlias)->(Eof())

		oResponse['lengthHist'] := (cAlias)->(QTD)
		
		(cAlias)->(DbSkip())
	End

	(cAlias)->(DbCloseArea())

	RestArea(aArea)

Return oResponse
