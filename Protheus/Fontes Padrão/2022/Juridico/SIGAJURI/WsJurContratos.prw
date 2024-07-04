#INCLUDE "WSJurContratos.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "SHELL.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} WSJurContratos
Métodos WS REST do Jurídico para contratos.

@since 17/12/2021
/*/
//-------------------------------------------------------------------

WSRESTFUL JURCONTRATOS DESCRIPTION "WS Jurídico contratos"

WSDATA filial       AS STRING
WSDATA codContrato  AS STRING
WSDATA pageSize     AS Integer
WSDATA cTipoAditivo AS STRING

WSMETHOD GET DetContrato  DESCRIPTION STR0001 PATH "contract/{filial}/{codContrato}"    PRODUCES APPLICATION_JSON // 'Detalhes de contrato'
WSMETHOD GET aditivos     DESCRIPTION STR0002 PATH "aditivos/{filial}/{codContrato}"    PRODUCES APPLICATION_JSON // 'Aditivos do contrato'

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} GET DetContrato
Detalhes do Contrato

@param filial      - Filial do contrato
@param codContrato - Código do contrato

@since 16/12/21
@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/JURCONTRATOS/contract/{filial}/{codContrato}

/*/
//-------------------------------------------------------------------
WSMETHOD GET DetContrato PATHPARAM filial, codContrato WSREST JURCONTRATOS

Local oResponse  := JsonObject():New()
Local cAlias     := ""
Local cQuery     := ""
Local cForCorre  := ""
Local cTpContr   := ""
Local cDeptSolic := ""
Local cFormPgto  := ""
Local lRet       := .T.
Local cFilCont   := Self:filial
Local cContrato  := Self:codContrato

	If JVldRestri("006", "'14'" /*Processos*/, 2 /*visualizar*/)

		Self:SetContentType("application/json")

		cQuery := WSJDetCon(cFilCont, cContrato)
		cAlias := GetNextAlias()

		DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .F. )

		If !(cAlias)->(Eof())
			oResponse['DetailContract'] := {}
			Aadd(oResponse['DetailContract'], JsonObject():New())

			cForCorre  := IIF( !Empty((cAlias)->NSZ_CFCORR), JurGetDados('NW7', 1, xFilial('NW7') + (cAlias)->NSZ_CFCORR, 'NW7_DESC'), '' )
			cTpContr   := IIF( !Empty((cAlias)->NSZ_CODCON), JurGetDados('NY0', 1, xFilial('NY0') + (cAlias)->NSZ_CODCON, 'NY0_DESC'), '' )
			cDeptSolic := IIF( !Empty((cAlias)->NSZ_CDPSOL), SetaDescX5('JZ', (cAlias)->NSZ_CDPSOL ) , '' )
			cFormPgto  := IIF( !Empty((cAlias)->NSZ_CODCON), JurGetDados('NSZ', 1, cFilCont + cContrato , 'NSZ_FPGTO'), '' )

			oResponse['DetailContract'][1]['nomeCliente']             := JConvUTF8( (cAlias)->A1_NOME )
			oResponse['DetailContract'][1]['poloAtivo']               := JConvUTF8( (cAlias)->NSZ_PATIVO )
			oResponse['DetailContract'][1]['poloPassivo']             := JConvUTF8( (cAlias)->NSZ_PPASSI )
			oResponse['DetailContract'][1]['responsavel']             := JConvUTF8( (cAlias)->RD0_NOME )
			oResponse['DetailContract'][1]['formaPgto']               := JConvUTF8( cFormPgto )
			oResponse['DetailContract'][1]['renovacaoAutomatica']     := (cAlias)->NSZ_RENOVA
			oResponse['DetailContract'][1]['numeroContrato']          := JConvUTF8( (cAlias)->NSZ_NUMCON )
			oResponse['DetailContract'][1]['dataInclusao']            := (cAlias)->NSZ_DTINCL
			oResponse['DetailContract'][1]['solicitante']             := JConvUTF8( (cAlias)->NSZ_SOLICI )
			oResponse['DetailContract'][1]['areaJuridica']            := JConvUTF8( (cAlias)->NRB_DESC )
			oResponse['DetailContract'][1]['situacao']                := (cAlias)->NSZ_SITUAC
			oResponse['DetailContract'][1]['departamentoSolicitante'] := JConvUTF8( cDeptSolic )
			oResponse['DetailContract'][1]['valorContrato']           := (cAlias)->NSZ_VLCONT
			oResponse['DetailContract'][1]['inicioVigencia']          := (cAlias)->NSZ_DTINVI
			oResponse['DetailContract'][1]['fimVigencia']             := (cAlias)->NSZ_DTTMVI
			oResponse['DetailContract'][1]['formaCorrecao']           := JConvUTF8( cForCorre )
			oResponse['DetailContract'][1]['valorContratoAtu']        := (cAlias)->NSZ_VACONT
			oResponse['DetailContract'][1]['codFluig']                := JConvUTF8(  (cAlias)->NSZ_CODWF )
			oResponse['DetailContract'][1]['detalhes']                := JConvUTF8( (cAlias)->NSZ_DETALH )
			oResponse['DetailContract'][1]['observacoes']             := JConvUTF8( (cAlias)->NSZ_OBSERV )
			oResponse['DetailContract'][1]['tipoContrato']            := JConvUTF8( cTpContr )
			oResponse['DetailContract'][1]['tipoAssunto']             := (cAlias)->NSZ_TIPOAS
		EndIf

		(cAlias)->( DbCloseArea() )

		Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
	
	Else
		lRet := .F.
		ConOut(STR0003) // Sem permissão para GET em processos
		SetRestFault(403, STR0004) // 2: Acesso negado

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} WSJDetCon
Realiza a query para busca dos detalhes do contrato

@param cFilCont  - Filial do contrato
@param cContrato - Código do contrato
@since 17/12/21
/*/
//-------------------------------------------------------------------
Static Function WSJDetCon( cFilCont, cContrato )

Local cQrySelect := ""
Local cQryFrom   := ""
Local cQryWhere  := ""
Local cQuery     := ""

	cQrySelect := " SELECT SA1.A1_NOME     A1_NOME, "
	cQrySelect +=        " NSZ.NSZ_PATIVO  NSZ_PATIVO, "
	cQrySelect +=        " NSZ.NSZ_PPASSI  NSZ_PPASSI, "
	cQrySelect +=        " RD01.RD0_NOME    RD0_NOME, "
	cQrySelect +=        " NSZ.NSZ_RENOVA  NSZ_RENOVA, "
	cQrySelect +=        " NSZ.NSZ_NUMCON  NSZ_NUMCON, "
	cQrySelect +=        " NSZ.NSZ_DTINCL  NSZ_DTINCL, "
	cQrySelect +=        " NSZ.NSZ_SOLICI  NSZ_SOLICI, "
	cQrySelect +=        " NRB.NRB_DESC    NRB_DESC, "
	cQrySelect +=        " NSZ.NSZ_SITUAC  NSZ_SITUAC, "
	cQrySelect +=        " NSZ.NSZ_CDPSOL  NSZ_CDPSOL, "
	cQrySelect +=        " NSZ.NSZ_VLCONT  NSZ_VLCONT, "
	cQrySelect +=        " NSZ.NSZ_DTINVI  NSZ_DTINVI, "
	cQrySelect +=        " NSZ.NSZ_DTTMVI  NSZ_DTTMVI, "
	cQrySelect +=        " NSZ.NSZ_CFCORR  NSZ_CFCORR, "
	cQrySelect +=        " NSZ.NSZ_VACONT  NSZ_VACONT, "
	cQrySelect +=        " NSZ.NSZ_CODWF   NSZ_CODWF, "
	cQrySelect +=        " NSZ.NSZ_CODCON  NSZ_CODCON, "
	cQrySelect +=        " NSZ.NSZ_TIPOAS  NSZ_TIPOAS, "

	If (Upper(TcGetDb())) == "ORACLE"
		cQrySelect +=    " TO_CHAR(SUBSTR(NSZ.NSZ_DETALH,1,4000))  NSZ_DETALH, "
		cQrySelect +=    " TO_CHAR(SUBSTR(NSZ.NSZ_OBSERV,1,4000))  NSZ_OBSERV "
	Else
		cQrySelect +=    " CAST(NSZ.NSZ_DETALH AS VARCHAR(4000))  NSZ_DETALH, "
		cQrySelect +=    " CAST(NSZ.NSZ_OBSERV AS VARCHAR(4000))  NSZ_OBSERV "
	Endif

	cQryFrom :=        " FROM " + RetSqlName('NSZ') + " NSZ "
	cQryFrom +=   " LEFT JOIN " + RetSqlName('NVE') + " NVE "
	cQryFrom +=          " ON ( NVE.NVE_NUMCAS = NSZ.NSZ_NUMCAS ) "
	cQryFrom +=         " AND ( NVE.NVE_CCLIEN = NSZ.NSZ_CCLIEN ) "
	cQryFrom +=         " AND ( NVE.NVE_LCLIEN = NSZ.NSZ_LCLIEN ) "
	cQryFrom +=         " AND ( NVE.NVE_FILIAL = '" + xFilial('NVE') + "' ) "
	cQryFrom +=         " AND ( NVE.D_E_L_E_T_ = ' ' ) "

	// Cliente
	cQryFrom +=     " INNER JOIN " + RetSqlName("SA1") + " SA1 "
	cQryFrom +=            " ON " + JQryFilial("NSZ","SA1","NSZ","SA1") + " "
	cQryFrom +=                   " AND (SA1.A1_COD = NSZ.NSZ_CCLIEN) "
	cQryFrom +=                   " AND (SA1.A1_LOJA = NSZ.NSZ_LCLIEN) "
	cQryFrom +=                   " AND (SA1.D_E_L_E_T_ = ' ') "

	// Responsavel
	cQryFrom +=     " LEFT JOIN " + RetSqlName('RD0') + " RD01 ON (RD01.RD0_CODIGO = NSZ.NSZ_CPART1) "
	cQryFrom +=                     " AND (RD01.RD0_FILIAL = '" + xFilial("RD0") + "') "
	cQryFrom +=                     " AND (RD01.D_E_L_E_T_ = ' ') "

	// Área juridica
	cQryFrom +=    " LEFT JOIN " + RetSqlName('NRB') + " NRB  ON (NRB.NRB_COD = NSZ.NSZ_CAREAJ) "
	cQryFrom +=                    " AND (NRB.NRB_FILIAL = '" + xFilial("NRB") + "') "
	cQryFrom +=                    " AND (NRB.D_E_L_E_T_ = ' ') "

	cQryWhere  += " WHERE NSZ.NSZ_FILIAL = '" + cFilCont + "' "
	cQryWhere  += " AND NSZ.NSZ_COD = '" + cContrato + "' "
	cQryWhere  += " AND NSZ.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery( cQrySelect + cQryFrom + cQryWhere )
	cQuery := StrTran(cQuery,",' '",",''")

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} GET aditivos
Obtem os aditivos do Contrato

@param filial      - Filial do contrato
@param codContrato - Código do contrato

@since 17/12/21
@example [Sem Opcional] GET -> http://127.0.0.1:9090/rest/JURCONTRATOS/aditivos/{filial}/{codContrato}

/*/
//-------------------------------------------------------------------
WSMETHOD GET aditivos PATHPARAM filial, codContrato,cTipoAditivo,pageSize WSREST JURCONTRATOS

Local oResponse     := JsonObject():New()
Local cAlias        := GetNextAlias()
Local cQuery        := ""
Local cFilCont      := Self:filial
Local cContrato     := Self:codContrato
Local cTipoAditivo  := Self:cTipoAditivo
Local nPageSize     := iIF (Empty(Self:pageSize),3,Self:pageSize)
Local nCount        := 0
Local nPageIni      := 0
Local nPageFim      := 0
Local nPage         := 1


	Self:SetContentType("application/json")

	cQuery := WSJAditivos(cFilCont, cContrato,cTipoAditivo)

	DbUseArea( .T., "TOPCONN", TCGenQry(,,cQuery ), cAlias, .F., .F. )

	// Paginação
	nPageFim := nPageSize

	If nPage > 1
		nPageIni := (nPage-1) * nPageSize + 1  
		nPageFim := nPageIni  + nPageSize - 1
	EndIf

	If !(cAlias)->(Eof())
		oResponse['aditivos'] := {}
		While !(cAlias)->(Eof())
			nCount++
			If ( nCount >= nPageIni ) .AND. ( nCount <= nPageFim )
				Aadd(oResponse['aditivos'], JsonObject():New())

				Atail(oResponse['aditivos'])['codigo']         := (cAlias)->NXY_COD
				Atail(oResponse['aditivos'])['codTipo']        := Alltrim( (cAlias)->NXY_CTIPO )
				Atail(oResponse['aditivos'])['descTipo']       := JConvUTF8( (cAlias)->NXZ_DESC )
				Atail(oResponse['aditivos'])['inicioVigencia'] := Alltrim( (cAlias)->NXY_DTINVI )
				Atail(oResponse['aditivos'])['fimVigencia']    := Alltrim( (cAlias)->NXY_DTTMVI )
				Atail(oResponse['aditivos'])['valor']          := (cAlias)->NXY_VLADIT

				(cAlias)->(DbSkip())
			Else
				Exit
			EndIf
		End
		oResponse["total"]   := Len(oResponse['aditivos'])
	EndIf

	(cAlias)->( DbCloseArea())
	oResponse["hasmore"] := nCount > nPageFim
	Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} WSJAditivos
Realiza a query para busca dos aditivos do contrato

@param cFilCont  - Filial do contrato
@param cContrato - Código do contrato
@since 17/12/21
/*/
//-------------------------------------------------------------------
Static Function WSJAditivos( cFilCont, cContrato, cTipoAditivo )
Local cQrySelect := ""
Local cQryFrom   := ""
Local cQryWhere  := ""
Local cQuery     := ""
Local cOrder     := " ORDER BY NSZ_DTADIT DESC "

Default cTipoAditivo := ''

	cQrySelect := " SELECT NXY_CTIPO,  "
	cQrySelect +=        " NXZ_DESC,   "
	cQrySelect +=        " NXY_DTINVI, "
	cQrySelect +=        " NXY_DTTMVI, "
	cQrySelect +=        " NXY_VLADIT, "
	cQrySelect +=        " NXY_COD "

	cQryFrom :=  " FROM " + RetSqlName('NSZ') + " NSZ "

	// Aditivos
	cQryFrom +=         " INNER JOIN " + RetSqlName('NXY') + " NXY "
	cQryFrom +=                  " ON NXY.NXY_CAJURI = NSZ.NSZ_COD "
	cQryFrom +=                  " AND NXY.D_E_L_E_T_ = ' ' "

	// Tipos de aditivos
	cQryFrom +=         " INNER JOIN " + RetSqlName('NXZ') + " NXZ "
	cQryFrom +=                  " ON NXZ.NXZ_COD = NXY.NXY_CTIPO "
	cQryFrom +=                  " AND NXZ.D_E_L_E_T_ = ' ' "	

	cQryWhere  += " WHERE NSZ.NSZ_FILIAL = '" + cFilCont + "' "
	cQryWhere  += " AND NSZ.NSZ_COD = '" + cContrato + "' "
	cQryWhere  += " AND NSZ.D_E_L_E_T_ = ' ' "

	If(!Empty(cTipoAditivo))
       cQryWhere  += " AND NXY.NXY_CTIPO= '" + cTipoAditivo + "' "
    EndIf
	
	cQuery := ChangeQuery( cQrySelect + cQryFrom + cQryWhere + cOrder )
	cQuery := StrTran(cQuery,",' '",",''")

Return cQuery

