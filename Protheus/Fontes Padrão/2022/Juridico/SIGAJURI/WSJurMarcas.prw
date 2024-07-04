
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "WSJurMarcas.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} WSJurMarcas
Métodos WS REST do Jurídico para Marcas e Patentes.

@since 20/01/2022
/*/
//-------------------------------------------------------------------
WSRESTFUL JURMARCAS DESCRIPTION STR0001 // "WS Jurídico Marcas e Patentes"

WSDATA filial       AS STRING
WSDATA cajuri       AS STRING
WSDATA searchKey    AS STRING
WSDATA assJur       AS STRING
WSDATA pk           AS STRING
WSDATA listFiliais  AS STRING
WSDATA relaciona    AS STRING
WSDATA pageSize     AS INTEGER

	WSMETHOD GET ListMarcas DESCRIPTION STR0002 PATH "getListMarcas"            PRODUCES APPLICATION_JSON // "Busca as marcas e patentes"
	WSMETHOD GET detMarca   DESCRIPTION STR0003 PATH "brand/{filial}/{cajuri}"  PRODUCES APPLICATION_JSON // "Detalhes da marca / patente"

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} ListMarcas
Metódo responsável por buscar marcas e patentes. Utilizado na pesquisa
rápida e na rotina de relacionados do TOTVS Jurídico Departamentos

@param searchKey   -  texto a ser pesquisado
@param pk          -  chave primária a ser pesquisada
@param pageSize    -  quantidade à ser retornado
@param listFiliais -  lista de filiais pré carregada
@param relaciona   - indica o tipo de relacionamento (vinculados, relacionados)
@param filial      - filial da marca
@param cajuri      - Código de assunto jurídico

@example GET -> http://localhost:12173/rest/JURMARCAS/getListMarcas?searchKey=&assJur=011&cajuri=0000000560&filial=01
@since 14/01/2022
/*/
//-------------------------------------------------------------------
WSMETHOD GET ListMarcas WSRECEIVE searchKey, pk, pageSize, listFiliais, relaciona, filial, cajuri WSREST JURMARCAS

Local lRet        := .T.
Local oResponse   := JsonObject():New()
Local cAlias      := GetNextAlias()
Local cQuery      := ""
Local cPk         := Self:pk
Local cSearchKey  := Self:searchKey
Local cListFil    := Self:listFiliais
Local nPageSize   := Self:pageSize
Local cRelaciona  := Self:relaciona // tipo de relacionamento (Incidente, Vinculado, Relacionado)
Local cAssJur     := Self:assJur
Local cFilMarca   := Self:filial
Local cCajuri     := Self:cajuri
Local nCount      := 1

Default cSearchKey := ""
Default cPk        := ""
Default cListFil   := ""
Default nPageSize  := 10
	
	If JVldRestri("011", "'14'" /*Processos*/, 2 /*visualizar*/)

		cQuery := getListMarcas(cSearchKey, cPk, cListFil, cRelaciona, cAssJur, cFilMarca, cCajuri)
		DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

		oResponse['marcas'] := {}
		While (cAlias)->(!Eof()) .AND. nCount <= nPageSize
			aAdd(oResponse['marcas'],JsonObject():New())
			aTail(oResponse['marcas'])['branch']    := (cAlias)->NSZ_FILIAL
			aTail(oResponse['marcas'])['id']        := (cAlias)->NSZ_COD
			aTail(oResponse['marcas'])['name']      := JConvUTF8((cAlias)->NSZ_NOMEMA)
			aTail(oResponse['marcas'])['detailing'] := JConvUTF8((cAlias)->NSZ_ESPECI)
			nCount++
			(cAlias)->(DbSkip())
		End

		(cAlias)->( DbCloseArea() )

		Self:SetContentType("application/json")
		Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
	Else
		lRet := .F.
		SetRestFault(403, STR0004) // 14: Acesso negado

	Endif

Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} getListMarcas
Busca a lista de marcas conforme os filtros especificados

@param cSearchKey -  texto a ser pesquisado
@param cPk        -  chave primária a ser pesquisada
@param cListFil   - lista de filiais pré carregada
@param cRelaciona - Tipo de relacionamento (Incidentes / Vinculados / Relacionados)
@param cAssJur    - Assunto jurídico
@param cFilMarca  - Filial
@param cCajuri    - Código do assunto jurídico

@Return Query da busca de marcas
@since 14/01/2022
/*/
//-----------------------------------------------------------------
Static Function getListMarcas(cSearchKey, cPk, cListFil, cRelaciona, cAssJur, cFilMarca, cCajuri)

Local cQrySelect := ""
Local cQryFrom   := ""
Local cQryWhere  := ""
Local cOrderBy   := " ORDER BY NSZ_COD "
Local cWhrTpAsJ  := ""
Local cTpAsJOrig := ""
Local cAssJurRel := ""
Local aSQLRest   := Ja162RstUs(,,,.T.)

Default cRelaciona := ""
Default cAssJur    := "011"
Default cFilConsul := ""
Default cCajuri    := ""

	// Validação relacionamento
	If !Empty(cRelaciona)

		Do Case
			// Somente processos de tipos de assuntos juridicos iguais do processo origem e tipos filhos
			Case cRelaciona == "vinculado"

				cWhrTpAsJ := " AND NSZ.NSZ_TIPOAS IN (" + WSJMAssVin(cAssJur) + ") "

			// Todos os assuntos juridicos diferentes do origem
			Case cRelaciona == "relacionado"

				cTpAsJOrig := JurGetDados('NYB', 1, xFilial('NYB') + cAssJur, 'NYB_CORIG')

				// Obtém os assuntos jurídicos filhos do assunto juridico do processo origem.
				cAssJurRel := WsJGetTpAss("'011'", .T.)

				If !Empty(cAssJurRel)
					// Somente processos de tipos de assuntos juridicos diferentes do processo origem
					cWhrTpAsJ := " AND NSZ.NSZ_TIPOAS IN ("+ cAssJurRel + ") "
				EndIf
		EndCase

	Else
		cAssJur := WsJGetTpAss("'" + cAssJur + "'" , .T.)"
		cWhrTpAsJ += " AND NSZ.NSZ_TIPOAS IN (" + cAssJur + ") "
	EndIf

	cQrySelect += " SELECT "
	cQrySelect +=     " NSZ.NSZ_FILIAL, "
	cQrySelect +=     " NSZ.NSZ_COD, "
	cQrySelect +=     " NSZ.NSZ_NOMEMA, "

	If (Upper(TcGetDb())) == "ORACLE"
		cQrySelect +=    " TO_CHAR(SUBSTR(NSZ.NSZ_ESPECI,1,50))  NSZ_ESPECI "
	Else
		cQrySelect +=    " CAST(NSZ.NSZ_ESPECI AS VARCHAR(50))  NSZ_ESPECI "
	EndIf

	cQryFrom += " FROM " + RetSqlName("NSZ") + " NSZ "

	If !Empty(cListFil)
		aFilUsr := { cListFil, ',' }
	Else
		aFilUsr := JURFILUSR( __CUSERID, "NSZ" )
	EndIf

	cQryWhere += " WHERE NSZ.D_E_L_E_T_ = ' ' "

	// Filtar Filiais que o usuário possui acesso
	If ( VerSenha(114) .or. VerSenha(115) )
		cQryWhere += " AND NSZ.NSZ_FILIAL IN " + FORMATIN(aFilUsr[1], aFilUsr[2])
	Else
		cQryWhere += " AND NSZ.NSZ_FILIAL = '" + xFilial("NSZ") + "' "
	EndIf

	// Restrições do usuário
	cQryWhere  += VerRestricao(,, WsJGetTpAss("'011'" , .T.))
	If !Empty(aSQLRest)
		cQryWhere += " AND (" + Ja162SQLRt(aSQLRest, , , , , , , , , WsJGetTpAss("'011'" , .T.)) + ")"
	EndIf

	// Parâmetros
	If !Empty(cCajuri)
		If !Empty(cRelaciona)
			cQryWhere  +=    " AND NSZ.NSZ_COD <> '" + cCajuri + "' "
			cQryWhere  +=    " AND NSZ.NSZ_FILIAL = '" + cFilMarca + "' "
		Else
			cQryWhere  +=    " AND NSZ.NSZ_COD = '" + cCajuri + "' "
		EndIf
	EndIf

	cQryWhere += cWhrTpAsJ

	If !Empty(cSearchKey)
		cSearchKey := Lower(StrTran(JurLmpCpo(cSearchKey,.F. ),'#',''))
		cQryWhere += " AND ( "
		cQryWhere +=     " NSZ.NSZ_COD LIKE '%" + cSearchKey + "%' "
		cQryWhere +=     " OR " + JurFormat("NSZ_NOMEMA", .T.,.T.) + " Like '%" + cSearchKey + "%'"
		cQryWhere +=     " OR " + JurFormat("NSZ_ESPECI", .T.,.T.) + " Like '%" + cSearchKey + "%'"
		cQryWhere += " ) "
	EndIf

	If !Empty(cPk)
		cQryWhere += " AND NSZ.NSZ_FILIAL||NSZ.NSZ_FILIAL = '" + cPk + "' "
	EndIf

Return ChangeQuery( cQrySelect + cQryFrom + cQryWhere + cOrderBy )

//-------------------------------------------------------------------
/*/{Protheus.doc} GET detMarca
Detalhes da marca / patente

@param filial - Filial da marca / patente
@param cajuri - Código da marca / patente

@since 20/01/2022
@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/JURMARCAS/brand/{filial}/{cajuri}

/*/
//-------------------------------------------------------------------
WSMETHOD GET detMarca PATHPARAM filial, cajuri WSREST JURMARCAS

Local oResponse  := JsonObject():New()
Local oAnexo     := Nil
Local cAlias     := ""
Local cQuery     := ""
Local cCriaPasta := ""
Local cLinkNZ7   := ""
Local cFilMarc   := Self:filial
Local cCajuri    := Self:cajuri
Local lRet       := JVldRestri("011", "'14'" /*Processos*/, 2 /*visualizar*/)

	If lRet
		Self:SetContentType("application/json")

		cQuery := WSJDetMarc(cFilMarc, cCajuri)
		cAlias := GetNextAlias()

		DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

		If !(cAlias)->(Eof())
			oResponse['detalhes'] := {}
			Aadd(oResponse['detalhes'], JsonObject():New())

			oResponse['detalhes'][1]['nomeMarca']         := JConvUTF8( (cAlias)->NSZ_NOMEMA )
			oResponse['detalhes'][1]['numPedido']         := JConvUTF8( (cAlias)->NSZ_NUMPED )
			oResponse['detalhes'][1]['poloAtivo']         := JConvUTF8( (cAlias)->NSZ_PATIVO )
			oResponse['detalhes'][1]['situacao']          := (cAlias)->NSZ_SITUAC
			oResponse['detalhes'][1]['assunto']           := (cAlias)->NSZ_TIPOAS
			oResponse['detalhes'][1]['nomeCliente']       := JConvUTF8( (cAlias)->A1_NOME )
			oResponse['detalhes'][1]['poloPassivo']       := JConvUTF8( (cAlias)->NSZ_PPASSI )
			oResponse['detalhes'][1]['solicitante']       := JConvUTF8( (cAlias)->NSZ_SOLICI )
			oResponse['detalhes'][1]['responsavel']       := JConvUTF8( (cAlias)->RD0_NOME )
			oResponse['detalhes'][1]['dataInclusao']      := (cAlias)->NSZ_DTINCL
			oResponse['detalhes'][1]['envolvidos']        := JConvUTF8( (cAlias)->NVE_TITULO )
			oResponse['detalhes'][1]['especificacao']     := JConvUTF8( (cAlias)->NSZ_ESPECI )
			oResponse['detalhes'][1]['descClasse']        := JConvUTF8( (cAlias)->NSV_DESC )
			oResponse['detalhes'][1]['descTipoMarca']     := JConvUTF8( (cAlias)->NY6_DESC )
			oResponse['detalhes'][1]['descSituacaoMarca'] := JConvUTF8( (cAlias)->NY7_DESC )
			oResponse['detalhes'][1]['descNaturezaMarca'] := JConvUTF8( (cAlias)->NY8_DESC )

			// Pasta Fluig
			oResponse['detalhes'][1]['folderFluig'] := {}
			Aadd(oResponse['detalhes'][1]['folderFluig'], JsonObject():New())

			If (AllTrim(SuperGetMv('MV_JDOCUME',,'1'))) == '3' // Se usa Fluig
				If !Empty(Alltrim((cAlias)->NZ7_LINK)) // Verifica se há conteúdo no campo NZ7_LINK
					cLinkNZ7 := AllTrim((cAlias)->NZ7_LINK)
				Else
					cCriaPasta := J070PFluig( (cAlias)->NSZ_CCLIEN + (cAlias)->NSZ_LCLIEN + (cAlias)->NSZ_NUMCAS, "") // Realiza a criação da pasta no Fluig

					If cCriaPasta == "2"
						cLinkNZ7 := AllTrim(JurGetDados("NZ7", 1, xFilial("NZ7") + (cAlias)->NSZ_CCLIEN + (cAlias)->NSZ_LCLIEN + (cAlias)->NSZ_NUMCAS, "NZ7_LINK"))
					EndIf
				EndIf
				oAnexo := WSgetAnexo("NSZ", cCajuri)
				aTail(oResponse['detalhes'][1]['folderFluig'])['link']    := SubStr(cLinkNZ7,1,at(";",cLinkNZ7)-1  )
				aTail(oResponse['detalhes'][1]['folderFluig'])['version'] := SubStr(cLinkNZ7  ,at(";",cLinkNZ7)+1,4)
				aTail(oResponse['detalhes'][1]['folderFluig'])['url']     := oAnexo:Abrir(.F.,cLinkNZ7)
			EndIf
			
		EndIf

		(cAlias)->( DbCloseArea() )
		Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
	
	Else
		ConOut(STR0005) // Sem permissão para GET em processos
		SetRestFault(403, STR0006) // 2: Acesso negado
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} WSJDetMarc
Realiza a query para busca dos detalhes da marca / patente

@param cFilMarc  - Filial da marca / patente
@param cCajuri   - Código da marca / patente
@return cQuery   - Query de busca dos dados
@since 20/01/2022
/*/
//-------------------------------------------------------------------
Static Function WSJDetMarc(cFilMarc, cCajuri)

Local cQrySelect := ""
Local cQryFrom   := ""
Local cQryWhere  := ""
Local cQuery     := ""
Local cBanco     := Upper( AllTrim( TcGetDb() ) )

	cQrySelect := " SELECT SA1.A1_NOME     A1_NOME,    "
	cQrySelect +=        " NSZ.NSZ_PATIVO  NSZ_PATIVO, "
	cQrySelect +=        " NSZ.NSZ_PPASSI  NSZ_PPASSI, "
	cQrySelect +=        " NSZ.NSZ_NUMPED  NSZ_NUMPED, "
	cQrySelect +=        " NSZ.NSZ_DTINCL  NSZ_DTINCL, "
	cQrySelect +=        " NSZ.NSZ_SOLICI  NSZ_SOLICI, "
	cQrySelect +=        " NSZ.NSZ_SITUAC  NSZ_SITUAC, "
	cQrySelect +=        " NSZ.NSZ_NOMEMA  NSZ_NOMEMA, "
	cQrySelect +=        " NSZ.NSZ_TIPOAS  NSZ_TIPOAS, "
	cQrySelect +=        " NSZ.NSZ_CCLIEN  NSZ_CCLIEN, "
	cQrySelect +=        " NSZ.NSZ_LCLIEN  NSZ_LCLIEN, "
	cQrySelect +=        " NSZ.NSZ_NUMCAS  NSZ_NUMCAS, "
	cQrySelect +=        " RD01.RD0_NOME   RD0_NOME,   "
	cQrySelect +=        " NVE.NVE_TITULO  NVE_TITULO, "
	cQrySelect +=        " NZ7.NZ7_LINK  NZ7_LINK, "
	cQrySelect +=        " COALESCE(NSV.NSV_DESC, '') NSV_DESC, "
	cQrySelect +=        " COALESCE(NY6.NY6_DESC, '') NY6_DESC, "
	cQrySelect +=        " COALESCE(NY7.NY7_DESC, '') NY7_DESC, "
	cQrySelect +=        " COALESCE(NY8.NY8_DESC, '') NY8_DESC, "

	If cBanco == "ORACLE"
		cQrySelect +=    " TO_CHAR(SUBSTR(NSZ.NSZ_ESPECI,1,4000))  NSZ_ESPECI "
	Else
		cQrySelect +=    " CAST(NSZ.NSZ_ESPECI AS VARCHAR(4000))  NSZ_ESPECI "
	Endif

	cQryFrom := " FROM " + RetSqlName('NSZ') + " NSZ "

	// Caso
	cQryFrom +=    " LEFT JOIN " + RetSqlName('NVE') + " NVE "
	cQryFrom +=          " ON ( NVE.NVE_NUMCAS = NSZ.NSZ_NUMCAS ) "
	cQryFrom +=          " AND ( NVE.NVE_CCLIEN = NSZ.NSZ_CCLIEN ) "
	cQryFrom +=          " AND ( NVE.NVE_LCLIEN = NSZ.NSZ_LCLIEN ) "
	cQryFrom +=          " AND ( NVE.NVE_FILIAL = '" + xFilial('NVE') + "' ) "
	cQryFrom +=          " AND ( NVE.D_E_L_E_T_ = ' ' ) "

	// Cliente
	cQryFrom +=     " INNER JOIN " + RetSqlName("SA1") + " SA1 "
	cQryFrom +=          " ON " + JQryFilial("NSZ","SA1","NSZ","SA1") + " "
	cQryFrom +=          " AND (SA1.A1_COD = NSZ.NSZ_CCLIEN) "
	cQryFrom +=          " AND (SA1.A1_LOJA = NSZ.NSZ_LCLIEN) "
	cQryFrom +=          " AND (SA1.D_E_L_E_T_ = ' ') "

	// Responsável
	cQryFrom +=     " LEFT JOIN " + RetSqlName('RD0') + " RD01 "
	cQryFrom +=          " ON (RD01.RD0_CODIGO = NSZ.NSZ_CPART1) "
	cQryFrom +=          " AND (RD01.RD0_FILIAL = '" + xFilial("RD0") + "') "
	cQryFrom +=          " AND (RD01.D_E_L_E_T_ = ' ') "

	// Classe
	cQryFrom +=     " LEFT JOIN " + RetSqlName('NSV') + " NSV "
	cQryFrom +=          " ON NSV.NSV_FILIAL = '" + xFilial("NSV") + "' "
	cQryFrom +=          " AND NSZ.NSZ_CCLASS = NSV.NSV_COD "
	cQryFrom +=          " AND NSV.D_E_L_E_T_ = ' ' "

	// Tipo de marca
	cQryFrom +=     " LEFT JOIN " + RetSqlName('NY6') + " NY6 "
	cQryFrom +=          " ON NY6.NY6_FILIAL = '" + xFilial("NY6") + "' "
	cQryFrom +=          " AND NSZ.NSZ_CTIPMA = NY6_COD "
	cQryFrom +=          " AND NY6.D_E_L_E_T_ = ' ' "

	// Situação
	cQryFrom +=     " LEFT JOIN " + RetSqlName('NY7') + " NY7 "
	cQryFrom +=         " ON NY7.NY7_FILIAL = '" + xFilial("NY7") + "' "
	cQryFrom +=         " AND NSZ.NSZ_CSITMA = NY7.NY7_COD "
	cQryFrom +=         " AND NY7.D_E_L_E_T_ = ' ' "

	// Natureza
	cQryFrom +=     " LEFT JOIN " + RetSqlName('NY8') + " NY8 "
	cQryFrom +=         " ON NY8.NY8_FILIAL = '" + xFilial("NY8") + "' "
	cQryFrom +=         " AND NSZ.NSZ_CNATMA = NY8.NY8_COD "
	cQryFrom +=         " AND NY8.D_E_L_E_T_ = ' ' "

	// Pasta do FLUIG
	cQryFrom   +=   " LEFT JOIN " + RetSqlName('NZ7') + " NZ7 "
	cQryFrom   +=       " ON (NZ7.NZ7_NUMCAS = NSZ.NSZ_NUMCAS "
	cQryFrom   +=       "AND NZ7.NZ7_CCLIEN = NSZ.NSZ_CCLIEN "
	cQryFrom   +=       "AND NZ7.NZ7_LCLIEN = NSZ.NSZ_LCLIEN "
	cQryFrom   +=       "AND NZ7.NZ7_FILIAL  = '" + xFilial("NZ7") + "' "
	cQryFrom   +=       "AND NZ7.D_E_L_E_T_ = ' ' ) "

	cQryWhere  += " WHERE NSZ.NSZ_FILIAL = '" + cFilMarc + "' "
	cQryWhere  +=       " AND NSZ.NSZ_COD = '" + cCajuri + "' "
	cQryWhere  +=       " AND NSZ.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery( cQrySelect + cQryFrom + cQryWhere )
	cQuery := StrTran(cQuery,",' '",",''")

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} WSJMAssVin
Realiza a busca dops assuntos filhos para vinculados

@param cAssJur - Código do assunto jurídico
@return 
@since 20/01/2022
/*/
//-------------------------------------------------------------------
Static Function WSJMAssVin( cAssJur )

Local cSQL       := ""
Local cTpAsJOrig := ""
Local cTpAsJVinc := ""
Local aAsJFilhos := {}
Local nX         := 0

Default cAssJur := ""

	cSQL := " SELECT NYB_COD FROM " + RetSqlname("NYB") + " "
	cSQL += " WHERE NYB_CORIG = '" + cAssJur + "' AND D_E_L_E_T_ = ' ' "
	cSQL := ChangeQuery(cSQL)
	aAsJFilhos := JurSQL(cSQL, "*")

	For nX := 1 To Len(aAsJFilhos)
		cTpAsJVinc += "'" + aAsJFilhos[nX][1] + "',"
	Next nX

	cTpAsJOrig := JurGetDados('NYB', 1, xFilial('NYB') + cAssJur, 'NYB_CORIG')

	If !Empty(AllTrim(cTpAsJOrig))
		cTpAsJVinc += "'" + cTpAsJOrig + "',"
	EndIf

	cTpAsJVinc += "'" + cAssJur + "'"

Return cTpAsJVinc
