#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "SHELL.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} WSJurSocietario
Métodos WS REST do Jurídico para Societário.

@author SIGAJURI
@since 19/05/2021

/*/
//-------------------------------------------------------------------

WSRESTFUL JURSOCIETARIO DESCRIPTION STR0001 // "WS Jurídico Societário"

	WSDATA situac      AS STRING
	WSDATA searchKey   AS STRING
	WSDATA page        AS INTEGER
	WSDATA pageSize    AS INTEGER
	WSDATA tpFilter    AS STRING
	WSDATA relaciona   AS STRING
	WSDATA filCajuri   AS STRING
	WSDATA cajuri      AS STRING
	WSDATA assJur      AS STRING

	WSMETHOD GET listSocied         DESCRIPTION STR0002 PATH "listaSociedades"            PRODUCES APPLICATION_JSON // 'Busca a lista de sociedades/empresas'
	WSMETHOD GET docsVenc           DESCRIPTION STR0003 PATH "docsVenc"                   PRODUCES APPLICATION_JSON // Documentos próximos do vencimento

	WSMETHOD POST geraFup           DESCRIPTION STR0004 PATH "generateTask"               PRODUCES APPLICATION_JSON //"Gera uma tarefa de lembrete para a certidão / licença"

END WSRESTFUL

//------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GET listSocied
Método responsável por buscar a lista de empresas.

@param situac    - situação da consulta
@param searchKey - palavra chave para busca
@param tpFilter  - tipo de filtro
@param page      - pagina que será buscada
@param pageSize  - quantidade de registros por pagina
@param relaciona - Indica se é relacionado
@param filCajuri -Filial do cajuri
@param cajuri    - cajuri
@param assJur    - assunto juridico

@since 24/05/2021
@example [getModelos] GET -> http://127.0.0.1:12173/rest/JURSOCIETARIO/listaSociedades

/*/
//------------------------------------------------------------------------------------------------------------------
WSMETHOD GET listSocied WSRECEIVE situac, searchKey, tpFilter, page, pageSize, relaciona, filCajuri, cajuri, assJur WSREST JURSOCIETARIO

Local oResponse  := JsonObject():New()
Local aEmpresas  := {}
Local aNT9       := {}
Local aNYJ       := {}
Local nI         := 0
Local nCount     := 0
Local nQtdRegIni := 0
Local nQtdRegFim := 0
Local cLocaliz   := ""
Local cResp      := ""
Local cNZ7Link   := ""
Local cCliente   := ""
Local cLoja      := ""
Local cNumCaso   := ""
Local cLinkNZ7   := ""
Local cSituac    := IIF( VALTYPE(Self:situac) <> "U", Self:situac, "1,2" )
Local cSearchKey := IIF( VALTYPE(Self:searchKey) <> "U", Self:searchKey, "" )
Local nPage      := IIF( VALTYPE(Self:page) <> "U", Self:page, 1 )
Local nPageSize  := IIF( VALTYPE(Self:pageSize) <> "U", Self:pageSize, 10 )
Local cTpFilter  := IIF( VALTYPE(Self:tpFilter) <> "U", Self:tpFilter, "" )
Local cAssJur    := IIF( VALTYPE(Self:assJur) <> "U", Self:assJur, "" )
Local cRelaciona := IIF( VALTYPE(Self:relaciona) <> "U", Self:relaciona, "" )
Local cFilCajuri := IIF( VALTYPE(Self:filCajuri) <> "U", Self:filCajuri, xFilial("NSZ") )
Local cCajuri    := IIF( VALTYPE(Self:cajuri) <> "U", Self:cajuri, "" )

	aEmpresas := ListEmpresas( cSituac, cSearchKey, cTpFilter, cAssJur, cRelaciona, cFilCajuri, cCajuri)

	Self:SetContentType("application/json")
	
	oResponse['length'] := Len(aEmpresas)
	oResponse['empresas'] := {}

	nQtdRegIni := ((nPage - 1) * nPageSize) + 1
	nQtdRegFim := (nPage * nPageSize)

	If nQtdRegFim > Len(aEmpresas)
		nQtdRegFim := Len(aEmpresas)
		oResponse['hasNext'] := .F.
	Else 
		oResponse['hasNext'] := .T.
	Endif

	For nI := nQtdRegIni To nQtdRegFim

		cLocaliz   := ALLTRIM(aEmpresas[nI][7]) + ", " + ALLTRIM(aEmpresas[nI][8]) + " - " + ALLTRIM(aEmpresas[nI][11]) + " - " + ALLTRIM(aEmpresas[nI][10])
		cFilCajuri := aEmpresas[nI][1]
		cCajuri    := aEmpresas[nI][2]
		cResp      := JurGetDados('RD0', 1, xFilial('RD0') + ALLTRIM(aEmpresas[nI][18]), 'RD0_NOME')
		cNZ7Link   := aEmpresas[nI][21]
		cCliente   := aEmpresas[nI][22]
		cLoja      := aEmpresas[nI][23]
		cNumCaso   := aEmpresas[nI][24]

		// Detalhes (NSZ)
		Aadd(oResponse['empresas'], JsonObject():New())
		aTail(oResponse['empresas'])['pk']            := encode64(cFilCajuri + cCajuri)
		aTail(oResponse['empresas'])['filial']        := cFilCajuri
		aTail(oResponse['empresas'])['cajuri']        := ALLTRIM(cCajuri)
		aTail(oResponse['empresas'])['area']          := JConvUTF8(aEmpresas[nI][3])
		aTail(oResponse['empresas'])['dataInclusao']  := DTOC(STOD(aEmpresas[nI][4]))
		aTail(oResponse['empresas'])['nire']          := ALLTRIM(aEmpresas[nI][5])
		aTail(oResponse['empresas'])['nomeFantasia']  := JConvUTF8(aEmpresas[nI][6])
		aTail(oResponse['empresas'])['localizacao']   := JConvUTF8( cLocaliz )
		aTail(oResponse['empresas'])['bairro']        := JConvUTF8(aEmpresas[nI][9])
		aTail(oResponse['empresas'])['dataEntrada']   := DTOC(STOD(aEmpresas[nI][12]))
		aTail(oResponse['empresas'])['tipoSociedade'] := SetaDescX5("J4", aEmpresas[nI][13])
		aTail(oResponse['empresas'])['cnae']          := JConvUTF8( aEmpresas[nI][14] + " - " + aEmpresas[nI][15] )
		aTail(oResponse['empresas'])['situacao']      := JConvUTF8(aEmpresas[nI][16])
		aTail(oResponse['empresas'])['razaoSocial']   := JConvUTF8(aEmpresas[nI][17])
		aTail(oResponse['empresas'])['responsavel']   := JConvUTF8( cResp )
		aTail(oResponse['empresas'])['cpfcnpj']       := ALLTRIM(aEmpresas[nI][19])
		aTail(oResponse['empresas'])['titulo']        := JConvUTF8(aEmpresas[nI][20])
		aTail(oResponse['empresas'])['objeto']        := JConvUTF8(ALLTRIM(aEmpresas[nI][25]))
		aTail(oResponse['empresas'])['areaJur']       := JConvUTF8(ALLTRIM(aEmpresas[nI][26]))
		aTail(oResponse['empresas'])['tipoAs']        := JConvUTF8(ALLTRIM(aEmpresas[nI][27]))

		// Pasta Fluig
		oResponse['empresas'][nI]['folderFluig'] := {}
		Aadd(oResponse['empresas'][nI]['folderFluig'], JsonObject():New())

		If ( AllTrim(SuperGetMv('MV_JDOCUME',,'1')) == '3' ) // Se usa Fluig
			If !Empty(cNZ7Link)
				cLinkNZ7 := AllTrim(cNZ7Link)
			Else
				cCriaPasta := J070PFluig( cCliente + cLoja + cNumCaso, "") // Realiza a criação da pasta no Fluig

				If cCriaPasta == "2"
					cLinkNZ7 := AllTrim(JurGetDados("NZ7", 1, xFilial("NZ7") + cCliente + cLoja + cNumCaso, "NZ7_LINK"))
				Endif
			Endif
			oAnexo := WSgetAnexo("NSZ", cCajuri)
			aTail(oResponse['empresas'][nI]['folderFluig'])['link']    := SubStr(cLinkNZ7,1,at(";",cLinkNZ7)-1  )
			aTail(oResponse['empresas'][nI]['folderFluig'])['version'] := SubStr(cLinkNZ7  ,at(";",cLinkNZ7)+1,4)
			aTail(oResponse['empresas'][nI]['folderFluig'])['url']     := oAnexo:Abrir(.F.,cLinkNZ7)
		Endif

		// Envolvidos (NT9)
		aNT9 := JWsLpGtNt9(cCajuri, 0, cFilCajuri)
		oResponse['empresas'][nI]['envolvidos'] := {}
		If Len(aNT9) > 0
			nCount := 0
			For nCount := 1 to Len(aNT9)
				Aadd(oResponse['empresas'][nI]['envolvidos'], JsonObject():New())
				aTail(oResponse['empresas'][nI]['envolvidos'])['cod']           := JConvUTF8(aNT9[nCount][1])
				aTail(oResponse['empresas'][nI]['envolvidos'])['codEntidade']   := JConvUTF8(aNT9[nCount][2])
				aTail(oResponse['empresas'][nI]['envolvidos'])['entidade']      := JConvUTF8(aNT9[nCount][3])
				aTail(oResponse['empresas'][nI]['envolvidos'])['principal']     := JConvUTF8(aNT9[nCount][4])
				aTail(oResponse['empresas'][nI]['envolvidos'])['nome']          := JConvUTF8(aNT9[nCount][5])
				aTail(oResponse['empresas'][nI]['envolvidos'])['codLoja']       := JConvUTF8(aNT9[nCount][6])
				aTail(oResponse['empresas'][nI]['envolvidos'])['codTipoEnvol']  := JConvUTF8(aNT9[nCount][7])
				aTail(oResponse['empresas'][nI]['envolvidos'])['descTipoEnvol'] := JConvUTF8(aNT9[nCount][8])
				aTail(oResponse['empresas'][nI]['envolvidos'])['codCargo']      := JConvUTF8(aNT9[nCount][9])
				aTail(oResponse['empresas'][nI]['envolvidos'])['descCargo']     := JConvUTF8(aNT9[nCount][10])
				aTail(oResponse['empresas'][nI]['envolvidos'])['polo']          := JConvUTF8(aNT9[nCount][11])
				aTail(oResponse['empresas'][nI]['envolvidos'])['participacao']  := aNT9[nCount][12]
				aTail(oResponse['empresas'][nI]['envolvidos'])['cpfcnpj']       := JConvUTF8(JCpfCnpj(aNT9[nCount][13]))
			Next nCount
		EndIf

		// Unidades (NYJ)
		aNYJ := WSJSocUnid(cCajuri, cFilCajuri)
		oResponse['empresas'][nI]['unidades'] := {}
		If Len(aNYJ) > 0
			nCount := 0
			For nCount := 1 to Len(aNYJ)
				cLocaliz := ALLTRIM(aNYJ[nCount][12]) + " - " + ALLTRIM(aNYJ[nCount][11])
				Aadd(oResponse['empresas'][nI]['unidades'], JsonObject():New())
				aTail(oResponse['empresas'][nI]['unidades'])['filial']            := aNYJ[nCount][1]
				aTail(oResponse['empresas'][nI]['unidades'])['cod']               := JConvUTF8(aNYJ[nCount][2])
				aTail(oResponse['empresas'][nI]['unidades'])['cajuri']            := JConvUTF8(aNYJ[nCount][3])
				aTail(oResponse['empresas'][nI]['unidades'])['codCliente']        := JConvUTF8(aNYJ[nCount][4])
				aTail(oResponse['empresas'][nI]['unidades'])['codLoja']           := JConvUTF8(aNYJ[nCount][5])
				aTail(oResponse['empresas'][nI]['unidades'])['nomeFantasia']      := JConvUTF8(aNYJ[nCount][6])
				aTail(oResponse['empresas'][nI]['unidades'])['tipoPessoa']        := JConvUTF8(aNYJ[nCount][7])
				aTail(oResponse['empresas'][nI]['unidades'])['cpfCnpj']           := JConvUTF8(JCpfCnpj(aNYJ[nCount][8]))
				aTail(oResponse['empresas'][nI]['unidades'])['codTipoSociedade']  := JConvUTF8(aNYJ[nCount][9])
				aTail(oResponse['empresas'][nI]['unidades'])['DescTipoSociedade'] := SetaDescX5("J4", aNYJ[nCount][9])
				aTail(oResponse['empresas'][nI]['unidades'])['razaoSocial']       := JConvUTF8(aNYJ[nCount][10])
				aTail(oResponse['empresas'][nI]['unidades'])['localizacao']       := JConvUTF8(cLocaliz)
			Next nCount
		EndIf

	Next nI

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

Return .T.

//------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GET ListEmpresas
Método responsável por buscar a lista de empresas.

@param situac     - Situação da consulta
@param cSearchKey - palavra chave para busca
@param cTpFilter  - tipo de filtro para retorno
@param cAssJur    - Situação da consulta
@param cRelaciona - palavra chave para busca
@param cFilCajuri - tipo de filtro para retorno
@param cCajuri    - tipo de filtro para retorno

@since 20/05/2021
@return aSql - Array com a lista de consultas 

/*/
//------------------------------------------------------------------------------------------------------------------
Static Function ListEmpresas( cSituac , cSearchKey, cTpFilter, cAssJur, cRelaciona, cFilCajuri, cCajuri )

Local cSQL       := ''
Local aSql       := ''
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
Local cQryOrder  := " ORDER BY A1_NOME "
Local cWhere     := ""
Local nX         := 1
Local aSQLRest   := Ja162RstUs(,,,.T.)

Default cSituac    := "'1'"
Default cSearchKey := ''
Default cTpFilter  := ''
Default cAssJur    := '008'
Default cRelaciona := ''
Default cFilCajuri := ''
Default cCajuri    := ''
	
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
					lFiltraRel := cAssJur == "008"
				Else
					lFiltraRel := cTpAsJOrig == "008"
				EndIf

				If lFiltraRel
					cAssJurRel := WsJGetTpAss("'"+cAssJur+"'", .T.)
					If "'"+ cAssJur +"'" == cAssJurRel
						cAssJurRel := "''"
					ElseIf at(",'"+ cAssJur +"',", cAssJurRel) > 0
						cAssJurRel := StrTran(cAssJurRel,",'"+ cAssJur +"',", ",")
					ElseIf at("'"+ cAssJur +"',", cAssJurRel) > 0
						cAssJurRel := StrTran(cAssJurRel,"'"+ cAssJur +"',", "")
					ElseIf at(",'"+ cAssJur +"'", cAssJurRel) > 0
						cAssJurRel := StrTran(cAssJurRel,",'"+ cAssJur +"'", "")
					EndIf

					// Somente processos de tipos de assuntos juridicos diferentes do processo origem
					cWhrTpAsJ := " AND NSZ.NSZ_TIPOAS IN ("+ cAssJurRel+") "
				Else
					cAssJur := WsJGetTpAss("'008'" , .T.)
					cWhrTpAsJ := " AND NSZ.NSZ_TIPOAS IN ("+ cAssJur+") "
				EndIf
		EndCase
	Else
		cAssJur := WsJGetTpAss("'008'" , .T.)"
		cWhrTpAsJ := " AND NSZ.NSZ_TIPOAS IN ("+ cAssJur+") "
	EndIf
	
	cQrySelect := " SELECT NSZ_FILIAL, "
	cQrySelect +=        " NSZ_COD, "
	cQrySelect +=        " NRB_DESC, "
	cQrySelect +=        " NSZ_DTINCL, "
	cQrySelect +=        " NSZ_NIRE, "
	cQrySelect +=        " NSZ_NOMEFT, "
	cQrySelect +=        " NSZ_LOGRAD, "
	cQrySelect +=        " NSZ_LOGNUM, "
	cQrySelect +=        " NSZ_BAIRRO, "
	cQrySelect +=        " NSZ_ESTADO, "
	cQrySelect +=        " CC2_MUN, "
	cQrySelect +=        " NSZ_DTENTR, "
	cQrySelect +=        " NSZ_CTPSOC, "
	cQrySelect +=        " NSZ_CNAE, "
	cQrySelect +=        " CC3_DESC, "
	cQrySelect +=        " NSZ_SITUAC, "
	cQrySelect +=        " A1_NOME, "
	cQrySelect +=        " NSZ_CPART1, "
	cQrySelect +=        " A1_CGC, "
	cQrySelect +=        " NVE_TITULO, "
	cQrySelect +=        " NZ7_LINK, "
	cQrySelect +=        " NSZ_CCLIEN, "
	cQrySelect +=        " NSZ_LCLIEN, "
	cQrySelect +=        " NSZ_NUMCAS, "
	cQrySelect +=        " NSZ_COBJET, "
	cQrySelect +=        " NSZ_CAREAJ, "
	cQrySelect +=        " NSZ_TIPOAS "
	cQryFrom +=   " FROM " + RetSqlName("NSZ") + " NSZ "
	cQryFrom +=     " INNER JOIN " + RetSqlName("SA1") + " SA1 "
	cQryFrom +=            " ON " + JQryFilial("NSZ","SA1","NSZ","SA1") + " "
	cQryFrom +=                   " AND (SA1.A1_COD = NSZ.NSZ_CCLIEN) "
	cQryFrom +=                   " AND (SA1.A1_LOJA = NSZ.NSZ_LCLIEN) "
	cQryFrom +=                   " AND (SA1.D_E_L_E_T_ = ' ') "
	cQryFrom +=     " LEFT JOIN " + RetSqlName("CC3") + " CC3 "
	cQryFrom +=            " ON " + JQryFilial("NSZ","CC3","NSZ","CC3") + " "
	cQryFrom +=                   " AND (CC3.CC3_COD = NSZ.NSZ_CNAE) "
	cQryFrom +=                   " AND (CC3.D_E_L_E_T_ = ' ') "
	cQryFrom +=     " LEFT JOIN " + RetSqlName("CC2") + " CC2 "
	cQryFrom +=            " ON " + JQryFilial("NSZ","CC2","NSZ","CC2") + " "
	cQryFrom +=                   " AND (CC2.CC2_EST = NSZ.NSZ_ESTADO) "
	cQryFrom +=                   " AND (CC2.CC2_CODMUN = NSZ.NSZ_CMUNIC) "
	cQryFrom +=                   " AND (CC2.D_E_L_E_T_ = ' ') "
	cQryFrom +=     " LEFT JOIN " + RetSqlName("NYJ") + " NYJ "
	cQryFrom +=           " ON (NYJ.NYJ_FILIAL = NSZ.NSZ_FILIAL) "
	cQryFrom +=                  " AND NYJ_CAJURI = NSZ.NSZ_COD "
	cQryFrom +=                  " AND NYJ.NYJ_CCLIEN = NSZ.NSZ_CCLIEN "
	cQryFrom +=                  " AND NYJ.NYJ_LCLIEN = NSZ.NSZ_LCLIEN "
	cQryFrom +=                  " AND NYJ.D_E_L_E_T_ = ' ' "
	cQryFrom +=     " LEFT JOIN " + RetSqlName("RD0") + " RD0 "
	cQryFrom +=           " ON (RD0.RD0_CODIGO = NSZ.NSZ_CPART1)  "
	cQryFrom +=                  " AND (RD0.RD0_FILIAL = '" + xFilial("RD0") + "') "
	cQryFrom +=                  " AND (RD0.D_E_L_E_T_ = ' ') "
	cQryFrom +=     " LEFT JOIN " + RetSqlName("NVE") + " NVE "
	cQryFrom +=           " ON (NVE.NVE_NUMCAS = NSZ.NSZ_NUMCAS) "
	cQryFrom +=                  " AND (NVE.NVE_CCLIEN = NSZ.NSZ_CCLIEN) "
	cQryFrom +=                  " AND (NVE.NVE_LCLIEN = NSZ.NSZ_LCLIEN) "
	cQryFrom +=                  " AND NVE.NVE_FILIAL = '" + xFilial("NVE") + "' "
	cQryFrom +=                  " AND (NVE.D_E_L_E_T_ = ' ') "
	cQryFrom +=     " LEFT JOIN " + RetSqlName("NRB") + " NRB "
	cQryFrom +=           " ON (NSZ.NSZ_CAREAJ = NRB.NRB_COD) "
	cQryFrom +=                  " AND NRB.D_E_L_E_T_ = ' ' "
	cQryFrom   +=   " LEFT JOIN " + RetSqlName('NZ7') + " NZ7"
	cQryFrom   +=         " ON (NZ7.NZ7_NUMCAS = NSZ.NSZ_NUMCAS "
	cQryFrom   +=                "AND NZ7.NZ7_CCLIEN = NSZ.NSZ_CCLIEN "
	cQryFrom   +=                "AND NZ7.NZ7_LCLIEN = NSZ.NSZ_LCLIEN "
	cQryFrom   +=                "AND NZ7.NZ7_FILIAL  = '" + xFilial("NZ7") + "' "
	cQryFrom   +=                "AND NZ7.D_E_L_E_T_ = ' ' ) "

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
	cQryWhere  += VerRestricao(,, WsJGetTpAss("'008'" , .T.))
	If !Empty(aSQLRest)
		cQryWhere += " AND ("+Ja162SQLRt(aSQLRest, , , , , , , , , WsJGetTpAss("'008'" , .T.))+")"
	EndIf

	If !Empty(cCajuri)
		If !Empty(cRelaciona)
			cQryWhere  +=    " AND ( NSZ.NSZ_COD <> '"+cCajuri+"' "
			cQryWhere  +=    " AND NSZ.NSZ_COD <> '"+cFilCajuri+"') "
		Else
			cQryWhere  +=    " AND NSZ.NSZ_COD = '"+cCajuri+"' "
		EndIf
	EndIf

	cQryWhere += cWhrTpAsJ
	
	If !(Empty(cSearchKey))
		cSearchKey := Lower(StrTran(JurLmpCpo( cSearchKey,.F. ),'#',''))

		cQryWhere += " AND ( NSZ_COD Like '%" + cSearchKey + "%' "
		cQryWhere +=        " OR NSZ_NOMEFT Like '%" + cSearchKey + "%' "
		cQryWhere +=        " OR " + JurFormat("A1_NOME", .T.,.T.) + " Like '%" + cSearchKey + "%' "
		cQryWhere +=        " OR " + JurFormat("A1_CGC", .F.,.F.) + " Like '%" + cSearchKey + "%' "
		cQryWhere +=        " OR " + JurFormat("NVE_TITULO", .T.,.T.) + " Like '%" + cSearchKey + "%' "

		cWhere    :=  " AND " + JurFormat("NYJ_NOMEFT", .T.,.T.) + " Like '%" + cSearchKey + "%'"
		cExists   :=  " OR (" + SUBSTR(JurGtExist(RetSqlName("NYJ"), cWhere, "NSZ_FILIAL"),5)
		cQryWhere += cExists + " ) "
		cWhere    :=  " AND " + JurFormat("NYJ_CGC", .T.,.T.) + " Like '%" + cSearchKey + "%'"
		cExists   :=  " OR (" + SUBSTR(JurGtExist(RetSqlName("NYJ"), cWhere, "NSZ_FILIAL"),5)
		cQryWhere += cExists + " ) "

		cWhere    :=  " AND " + JurFormat("NT9_NOME", .T.,.T.) + " Like '%" + cSearchKey + "%'"
		cExists   :=  " OR (" + SUBSTR(JurGtExist(RetSqlName("NT9"), cWhere, "NSZ_FILIAL"),5)
		cQryWhere += cExists + " ) ) "
	EndIf

	cQuery := cQrySelect + cQryFrom + cQryWhere + cQryOrder
	aSql := JurSQL(cQuery, "*")

Return aSql

//-------------------------------------------------------------------
/*/{Protheus.doc} JWGetDadosX5
Busca dados na SX5 de acordo com a tabela

@param cCodTab    - Tabela
@param cChaveTab  - Código
@param cSearchKey - Palavra chave de busca

@since 20/05/2021
/*/
//-------------------------------------------------------------------
Function JWGetDadosX5(cCodTab, cChaveTab, cSearchKey)

Local cQuery := ""

Default cChaveTab  := ""
Default cSearchKey := ""

	cQuery := " SELECT SX5.X5_FILIAL, "
	cQuery +=        " SX5.X5_TABELA, "
	cQuery +=        " SX5.X5_CHAVE, "
	cQuery +=        " SX5.X5_DESCRI, "
	cQuery +=        " SX5.X5_DESCSPA, "
	cQuery +=        " SX5.X5_DESCENG, "
	cQuery +=        " SX5.R_E_C_N_O_ REC "
	cQuery += " FROM " + RetSqlName("SX5") + " SX5 "
	cQuery += " WHERE SX5.X5_TABELA = '" + Alltrim(cCodTab) + "' "

	If !Empty(cSearchKey)
		cQuery += " AND "+ JurFormat('X5_DESCRI', .T./*lAcentua*/,.T./*lPontua*/);
			   + " Like '%" + Lower(StrTran(JurLmpCpo( cSearchKey, .F.), '#', '')) + "%'"

	ElseIf !Empty(cChaveTab)
		cQuery += " AND SX5.X5_CHAVE = '" + AllTrim(cChaveTab) + "'"
	Endif

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} SetaDescX5
Busca a descrição de acordo com o código na SX5

@param cTabela - Tabela
@param cCodigo - Código

@since 20/05/2021
/*/
//-------------------------------------------------------------------
Function SetaDescX5(cTabela, cCodigo)

Local cAlias := GetNextAlias()
Local cDesc  := ""
Local cQuery := ""

	cQuery := JWGetDadosX5(cTabela, cCodigo)
	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

	If !(cAlias)->(Eof())
		cDesc := JConvUTF8((cAlias)->X5_DESCRI)
	EndIf

	(cAlias)->( DbCloseArea() )

Return cDesc

//-------------------------------------------------------------------
/*/{Protheus.doc} WSJSocUnid
Busca dados das unidades da empresa (NYJ)

@param cCajuri    - Código do processo
@param cFilCajuri - filial do cajuri

@since 20/05/2021
/*/
//-------------------------------------------------------------------
Static Function WSJSocUnid( cCajuri, cFilCajuri )

Local cAlias   := GetNextAlias()
Local cQuery   := ""
Local cDescMun := ""
Local aRetorno := {}

	cQuery := " SELECT NYJ_FILIAL, "
	cQuery += "        NYJ_COD, "
	cQuery += "        NYJ_CAJURI, "
	cQuery += "        NYJ_CCLIEN, "
	cQuery += "        NYJ_LCLIEN, "
	cQuery += "        NYJ_NOMEFT, "
	cQuery += "        NYJ_TIPOP, "
	cQuery += "        NYJ_CGC, "
	cQuery += "        NYJ_CTPSOC, "
	cQuery += "        A1_NOME, "
	cQuery += "        NYJ_ESTADO, "
	cQuery += "        NYJ_CMUNIC "
	cQuery += " FROM " + RetSqlname("NYJ") + " NYJ "
	cQuery +=     " INNER JOIN " + RetSqlName("SA1") + " SA1 "
	cQuery +=            " ON " + JQryFilial("NYJ","SA1","NYJ","SA1") + " "
	cQuery +=                   " AND (A1_COD = NYJ_CCLIEN) "
	cQuery +=                   " AND (A1_LOJA = NYJ_LCLIEN) "
	cQuery +=                   " AND (SA1.D_E_L_E_T_ = ' ') "
	cQuery += " WHERE NYJ_FILIAL = '" + cFilCajuri + "' "
	cQuery += "       AND NYJ_CAJURI = '" + cCajuri + "' "
	cQuery += "       AND NYJ.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cQuery ) , cAlias, .T., .F.)

	While !(cAlias)->(Eof())

		If !Empty((cAlias)->NYJ_ESTADO) .AND. !Empty((cAlias)->NYJ_CMUNIC)
			cDescMun := JurGetDados("CC2", 1, xFilial("CC2") + (cAlias)->NYJ_ESTADO + (cAlias)->NYJ_CMUNIC, 'CC2_MUN')
		EndIf

		aAdd( aRetorno, {	(cAlias)->NYJ_FILIAL, ;
							(cAlias)->NYJ_COD,    ;
							(cAlias)->NYJ_CAJURI, ;
							(cAlias)->NYJ_CCLIEN, ;
							(cAlias)->NYJ_LCLIEN, ;
							(cAlias)->NYJ_NOMEFT, ;
							(cAlias)->NYJ_TIPOP,  ;
							(cAlias)->NYJ_CGC,    ;
							(cAlias)->NYJ_CTPSOC, ;
							(cAlias)->A1_NOME,    ;
							(cAlias)->NYJ_ESTADO, ;
							cDescMun } )

		(cAlias)->( dbSkip() )
	End

	(cAlias)->( DbCloseArea() )

Return aRetorno

//------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GET docsVenc
Método responsável por buscar os documntos próximos do vencimento

@param pageSize  - quantidade de registros por pagina

@since 07/07/2021
@example GET -> http://127.0.0.1:12173/rest/JURSOCIETARIO/docsVenc
/*/
//------------------------------------------------------------------------------------------------------------------
WSMETHOD GET docsVenc WSRECEIVE pageSize WSREST JURSOCIETARIO

Local oResponse  := JsonObject():New()
Local nPageSize  := IIF( VALTYPE(self:pageSize) <> "U", self:pageSize, 10 )
Local aDocs      := {}
Local lTabelas   := FWAliasInDic('O19') .AND. FWAliasInDic('O1A')
Local nX         := 0
Local nIndexJSon := 0

	oResponse['documento'] := {}

	If lTabelas
		aDocs := getDocVenc(nPageSize)
		If Len(aDocs) > 0
			For nX := 1 To Len(aDocs)
				nIndexJSon++
				Aadd(oResponse['documento'], JsonObject():New())
				oResponse['documento'][nIndexJSon]['pk']         := encode64(aDocs[nX][1] + aDocs[nX][2] )
				oResponse['documento'][nIndexJSon]['filial']     := aDocs[nX][1]
				oResponse['documento'][nIndexJSon]['cajuri']     := aDocs[nX][2]
				oResponse['documento'][nIndexJSon]['codigo']     := aDocs[nX][3]
				oResponse['documento'][nIndexJSon]['empresa']    := JConvUTF8(aDocs[nX][4])
				oResponse['documento'][nIndexJSon]['documento']  := JConvUTF8(aDocs[nX][5])
				oResponse['documento'][nIndexJSon]['vencimento'] := DTOC(STOD(aDocs[nX][6]))

			Next nX
		EndIf
	EndIf

	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

Return .T.
//------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GET docsVenc
Método responsável por buscar os documntos próximos do vencimento

@param nPageSize  - quantidade de registros por pagina
@return aRetorno - lista com documentos próximos ao vencimento
        aRetorno[1] - Filial
        aRetorno[2] - Cajuri
        aRetorno[3] - Empresa
        aRetorno[4] - Documento
        aRetorno[5] - Data de Vencimento

@since 07/07/2021
/*/
//------------------------------------------------------------------------------------------------------------------
Static Function getDocVenc(nPageSize)

Local cAlias   := GetNextAlias()
Local cBanco   := Upper( AllTrim( TcGetDb() ) )
Local cQuery   := ""
Local aRetorno := {}

	cQuery := " SELECT "

	If ( cBanco == "MSSQL")
		cQuery += " TOP " + AllTrim(Str(nPageSize)) + " "
	EndIf

	cQuery +=        " O1A.O1A_FILIAL FILIAL, "
	cQuery +=        " O1A.O1A_CAJURI CAJURI, "
	cQuery +=        " O1A.O1A_CODIGO CODIGO, "
	cQuery +=        " SA1.A1_NOME EMPRESA,  "
	cQuery +=        " O19.O19_NOME DOCUMENTO, "
	cQuery +=        " O1A.O1A_DTVENC VENCIMENTO "
	cQuery += "  FROM " + RetSqlName("O1A") + " O1A "
	cQuery +=      " INNER JOIN " + RetSqlName("O19") + " O19 "
	cQuery +=          " ON O19.O19_CODIGO = O1A.O1A_TIPODC "
	cQuery +=              " AND O19.D_E_L_E_T_ = ' ' "
	cQuery +=      " INNER JOIN " + RetSqlName("NSZ") + " NSZ "
	cQuery +=          " ON NSZ.NSZ_FILIAL = O1A.O1A_FILIAL "
	cQuery +=              " AND NSZ.NSZ_COD = O1A.O1A_CAJURI "
	cQuery +=              " AND NSZ.NSZ_TIPOAS = '008' "
	cQuery +=              " AND NSZ.D_E_L_E_T_ = ' ' "
	cQuery +=      " INNER JOIN " + RetSqlName("SA1") + " SA1 "
	cQuery +=           " ON " + JQryFilial("NSZ","SA1","NSZ","SA1") + " "
	cQuery +=              " AND SA1.A1_COD = NSZ.NSZ_CCLIEN "
	cQuery +=              " AND SA1.A1_LOJA = NSZ.NSZ_LCLIEN "
	cQuery +=              " AND SA1.D_E_L_E_T_ = ' ' "
	cQuery += "  WHERE O1A.D_E_L_E_T_ = ' ' "
	cQuery +=          " AND O1A_DTVENC >= '" + DTOS(DATE()) + "' "
	cQuery +=          " AND O1A_DTVENC <= '" +  DTOS(MonthSum( DATE(), 3)) + "' " // +- dos próximos 3 meses

	If cBanco == "ORACLE"
		cQuery += " AND ROWNUM <= " + AllTrim(Str(nPageSize)) + " "
	EndIf

	cQuery += "  ORDER BY O1A_DTVENC "

	If cBanco == "DB2"
		cQuery += " FETCH FIRST " + AllTrim(Str(nPageSize)) + " ROWS ONLY "
	ElseIf cBanco $ "POSTGRES|MYSQL"
		cQuery += " LIMIT " + AllTrim(Str(nPageSize)) + " "
	EndIf

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cQuery ) , cAlias, .T., .F.)

	While !(cAlias)->(Eof())
		aAdd( aRetorno, {	(cAlias)->FILIAL, ;
							(cAlias)->CAJURI,    ;
							(cAlias)->CODIGO,    ;
							(cAlias)->EMPRESA, ;
							(cAlias)->DOCUMENTO, ;
							(cAlias)->VENCIMENTO } )
		(cAlias)->( dbSkip() )
	End

	(cAlias)->( DbCloseArea() )

Return aRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} POST geraFup
Faz a inclusão do fup automártico a partir do modelo cadastrado para o Tipo de certidão/ licença

@param body - Json com os dados para a inclusão do fup
@return .T.

@since 08/07/2021
@example [Sem Opcional] POST -> http://localhost:12173/rest/JURSOCIETARIO/generateTask
	body - {"filial": "02", "cajuri": "0000000041", "taskModel": "00004"}
/*/
//-------------------------------------------------------------------
WSMETHOD POST geraFup WSREST JURSOCIETARIO

Local oResponse  := JsonObject():New()
Local oRequest   := JsonObject():New()
Local cBody      := Self:GetContent()
Local cFilEmp    := ""
Local cCajuri    := ""
Local cModelo    := ""
Local lRet       := .F.
Local oModel106  := FWLoadModel("JURA106")
Local aRetorno   := {}

	oRequest:FromJson(cBody)
	cFilEmp = oRequest['filial']
	cCajuri = oRequest['cajuri']
	cModelo = oRequest['taskModel']

	aRetorno := J106aFwMod(cFilEmp, cCajuri, cModelo, oModel106)

	// Grava fups automáticos
	If Len(aRetorno) > 4 .AND. !Empty(aRetorno[5])
		lRet := .F.
		SetRestFault(404, EncodeUtf8(aRetorno[5]) )
	Else
		lRet := .T.
		oResponse['err'] := {}
		Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
	EndIf

Return lRet
