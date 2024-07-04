#Include "Protheus.Ch"
#Include "Jura203H.Ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} JA203HFatu
Rotina de emissão de Faturas

@Param  oParams - Parametros da emissão de fatura

@Return aRet    - Indica o resultado da operação [1]: .T. - Concluído com Êxito / .F. - Falha na execução
                                                 [2]: Nome da rotina que originou o erro

@author David G. Fernandes
@since 22/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA203HFatu(oParams, cCPREFT, cMoedaPF, cCFATAD, cCJCONT, cCCONTR, cCFIXO)
Local aRet       := {.T., "JA203HFatu"}
Local aArea      := GetArea()

Local cQueryFat  := ""
Local cQryResFat := GetNextAlias()
Local cQuery     := ""
Local cQryRes    := GetNextAlias()

Local cTipoEmi   := ""

Local nSomaPerc  := 0
Local nCountPerc := 0

Local cFilaImp   := ""
Local cFatura    := ""
Local aFatura    := {}
Local cEscr      := ""
Local cMoeda     := ""
Local cDtVenc    := ""
Local cContato   := ""
Local cContrato  := ""
Local cDtIniH    := ""
Local cDtFinH    := ""
Local cDtIniD    := ""
Local cDtFinD    := ""
Local cDtIniT    := ""
Local cDtFinT    := ""
Local cGrpCli    := ""
Local cClien     := ""
Local cLoja      := ""
Local cNomeCli   := ""
Local cLograd    := ""
Local cPessoa    := ""
Local cCGC       := ""
Local cPais      := ""
Local cEstado    := ""
Local cMiunic    := ""
Local cBairro    := ""
Local cCEP       := ""
Local cInscr     := ""
Local cInscrMun  := ""
Local nVlFixH    := 0
Local nVlFixD    := 0
Local cCalDis    := ""
Local nVlAdia    := 0
Local cEmail     := ""
Local cFPagto    := ""
Local cBanco     := ""
Local cAgenc     := ""
Local cConta     := ""
Local cCliPag    := ""
Local cLojaPag   := ""
Local nPercent   := 0
Local cCondPag   := ""
Local cIdioma    := ""
Local cIdioma2   := ""
Local cTpFat     := "" // Tipo de Faturamento ( 1- LitisConsórcio / 2 - Multipayer )
Local cRelat     := ""
Local cCarta     := ""
Local cPart      := ""
Local cTEMTS     := ""
Local cTEMLT     := ""
Local cTEMDP     := ""
Local cTEMFX     := ""
Local cTEMFA     := ""
Local cESCRNT0   := ""
Local cPoNumber  := ""
Local cServicos  := ""
Local cServReinf := ""

Local nVlFath    := 0
Local nVlFatD    := 0
Local nVlFatT    := 0
Local nVlTS      := 0
Local nVlTSVin   := 0
Local nVlTab     := 0

Local nVlOrigT   := 0

Local nVlDesc    := 0
Local nVlAcres   := 0
Local nVlOrigH   := 0
Local nVlOrigD   := 0

Local cTpPagador := ""

Local NXATEMFXH  := ""
Local NXATEMFXD  := ""
Local cEndInt    := ""
Local cTxtFat    := ""

Local cEscOld    := ""
Local cFatOld    := ""

Local nContFat   := 0
Local cFaturaOld := ""
Local cEscrOld   := ""

Local ni         := 0

Local nDESCPAG   := 0
Local nVlDesLine := 0
Local nVlDesLFat := 0
Local nVlDesLOri := 0
Local nVlDesEspe := 0
Local nVlDesEOri := 0
Local nVlDescPag := 0
Local nPACREH    := 0
Local nACRESH    := 0
Local nDESCH     := 0
Local nPDESCH    := 0
Local cPartEmi   := ""
Local cTipoF     := "" //Tipo de Fatura (definida no contrato ou junção)
Local nCountGrp  := 0
Local cGrpVen    := ""
Local aFaturas   := {}
Local cMsgTpFat  := ""
Local dDtEmiss   := CToD('  /  /  ')
Local cCndPgInt  := SuperGetMv('MV_JCPGINT')
Local cCndPgNac  := SuperGetMv('MV_JCPGNAC')
Local dDtVenc    := CToD('  /  /  ')
Local cParam     := ""
Local nOrigH     := 0
Local nOrigD     := 0
Local nFatHMn    := 0
Local nFatDMn    := 0
Local nDescMn    := 0
Local nAcreMn    := 0
Local cMoedaNac  := SuperGetMv('MV_JMOENAC',, '01')
Local cJuncFA    := ""
Local lPoNumber  := (NXA->( FieldPos( "NXA_PONUMB" )) > 0 )
Local lServicos  := (NXA->( FieldPos( "NXA_SERVIC" )) > 0 )
Local lServReinf := (NXA->( FieldPos( "NXA_TPSERV" )) > 0 )
Local cNFGer     := "2"
Local aRecnosFat := {}
Local nVlDpTrib  := 0
Local nVlDpReemb := 0
Local lDespTrib  := NXC->(ColumnPos('NXC_VLREMB')) > 0 ; // Proteção
					.And. NXB->(ColumnPos('NXB_VLTRIB')) > 0 .And. NXB->(ColumnPos('NXB_VLREMB')) > 0 ; // Proteção
					.And. NXB->(ColumnPos('NXB_VLGROS')) > 0 .And. NXB->(ColumnPos('NXB_VLTXAD')) > 0 ; // Proteção
					.And. NXB->(ColumnPos('NXB_VLTOTD')) > 0 // Proteção 
Local lPoNumbNX5 := lPoNumber .AND. NX5->( ColumnPos( "NX5_PONUMB" )) > 0 
Local cPoNumbNXA := ""
Local lFrmEnvFat := NUH->(ColumnPos("NUH_CORFAT")) > 0 .AND. NXA->(ColumnPos("NXA_CORFAT") > 0)
Local aDadCliPag := {"NUH_ENDI", "NUH_EMFAT"}
Local aRetCliPag := {}
Local nTaxaPerm  := 0
Local nPorcJuros := 0
Local nDescFin   := 0
Local nDiaDesc   := 0
Local cTipoDesc  := ""
Local lProtJuros := NXA->(ColumnPos("NXA_TXPERM")) > 0
Local lEndPSer   := NXA->(ColumnPos("NXA_ESTPS")) > 0
Local aEndPSer   := {}
Local cEstPSer   := ""
Local cMunPSer   := ""
Local nNX5Desc   := 0
Local cCEmail    := ""
Local lcEmail    := NXA->(ColumnPos("NXA_CEMAIL")) > 0
Local lNUHcEmail := NUH->(ColumnPos("NUH_CEMAIL")) > 0
Local lNUHEmlMin := NUH->(ColumnPos("NUH_EMLMIN")) > 0
Local lNXGEmail  := NXG->(ColumnPos("NXG_EMAIL"))  > 0 // @12.1.2310
Local lNXGEmlMin := NXG->(ColumnPos("NXG_EMLMIN")) > 0 // @12.1.2310
Local lProtGrsHn := NXP->(ColumnPos("NXP_GROSHN")) > 0 // @12.1.2310
Local cGrossHon  := ""
Local nPercGrHon := 0
Local nCotacNF   := 0
Local cLogFatNF  := ""
Local cTpNFSCot  := ""

If lFrmEnvFat
	aAdd(aDadCliPag, "NUH_CORFAT")
EndIf

If oParams:GetTpExec() $ "3|4|5|MS" //Minuta de Pré / Minuta de Fatura / Emissão de Fatura
	cFatura  := oParams:GetMarkFat()
	cEscr    := oParams:GetMarkEsc()
EndIf

//lHonor, lDesp
Do Case
	Case oParams:GetTpExec() == "5"
		cTipoEmi  := "FT"
		cMsgTpFat := STR0005
	Case oParams:GetTpExec() == "4"
		cTipoEmi  := "MF"
		cMsgTpFat := STR0006
	Case oParams:GetTpExec() == "3"
		cTipoEmi  := "MP"
		cMsgTpFat := STR0007
		J202CanMin(cCPREFT, STR0015) //"Emissão de fatura"
	Case oParams:GetTpExec() == "MS"
		cTipoEmi  := "MS"
		cMsgTpFat := STR0014 //"Minuta Sócio"
		J202CanMin(cCPREFT, STR0015) //"Emissão de fatura"
EndCase

If !Empty(cCPREFT)
	cPart      := JurGetDados("NX0", 1, xFilial("NX0") + cCPREFT, "NX0_CPART")
	nVlDesLine := JurGetDados("NX0", 1, xFilial("NX0") + cCPREFT, "NX0_DESCON")
	nVlDesEspe := JurGetDados("NX0", 1, xFilial("NX0") + cCPREFT, "NX0_DESCH")
	If lPoNumber 
		cPoNumber := JurGetDados("NX0", 1, xFilial("NX0") + cCPREFT, "NX0_PONUMB")
	EndIf
	If lServicos
		cServicos := JurGetDados("NX0", 1, xFilial("NX0") + cCPREFT, "NX0_SERVIC")
	EndIf
ElseIf !Empty(cCFATAD)
	cPart   := JurGetDados("NVV", 1, xFilial("NVV") + cCFATAD, "NVV_CPART1")
	cJuncFA := JurGetDados("NW3", 2, xFilial("NW3") + cCCONTR, "NW3_CJCONT" ) //Não é preenchida a junção para fatura adicional
	If lPoNumber
		If Empty(cJuncFA)
			cPoNumber := JurGetDados("NT0", 1, xFilial("NT0") + cCCONTR, "NT0_PONUMB")
		Else
			cPoNumber := JurGetDados("NW2", 1, xFilial("NW2") + cJuncFA, "NW2_PONUMB")
		EndIf
	EndIf
	If lServicos
		If Empty(cJuncFA)
			cServicos := JurGetDados("NT0", 1, xFilial("NT0") + cCCONTR, "NT0_SERVIC")
		Else
			cServicos := JurGetDados("NW2", 1, xFilial("NW2") + cJuncFA, "NW2_SERVIC")
		EndIf
	EndIf
Else
	cPart := JurGetDados("NT0", 1, xFilial("NT0") + cCCONTR, "NT0_CPART1")
	If lPoNumber
		cPoNumber := JurGetDados("NT0", 1, xFilial("NT0") + cCCONTR, "NT0_PONUMB")
	EndIf
	If lServicos
		cServicos := JurGetDados("NT0", 1, xFilial("NT0") + cCCONTR, "NT0_SERVIC")
	EndIf
	nVlDesLine := 0
	nVlDesEspe := 0
EndIf

// Verifica o total de pagadores e o percentual total para dividir a fatura proporcionalmente
cQuery := "SELECT CASE WHEN SUM(NXG.NXG_PERCEN) IS NULL THEN 0 ELSE SUM(NXG.NXG_PERCEN) END SUMPERCEN, "
cQuery +=       " COUNT(NXG.NXG_PERCEN) CONTPERC "
cQuery +=       " FROM " + RetSqlName("NXG") + " NXG "
cQuery +=       " WHERE NXG.NXG_FILIAL = '" + xFilial("NXB") + "' "
cQuery +=         " AND NXG.NXG_FILA = '" + oParams:GetCFilaImpr() +"' "
If !Empty(cCPREFT)
	cQuery +=     " AND NXG.NXG_CPREFT = '" + cCPREFT + "' "
EndIf
If !Empty(cCFIXO)
	cQuery +=     " AND NXG.NXG_CFIXO = '" + cCFIXO + "' "
EndIf
If !Empty(cCFATAD)
	cQuery +=     " AND NXG.NXG_CFATAD = '" + cCFATAD + "' "
EndIf
cQuery +=        " AND NXG.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery, .F.)
DbCommitAll() // Para efetivar a alteração no banco de dados (não impacta no rollback da trasação)
dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryRes, .T., .F. )

nSomaPerc   := (cQryRes)->SUMPERCEN
nCountPerc  := (cQryRes)->CONTPERC

(cQryRes)->(dbCloseArea())

If nSomaPerc == 0
	nSomaPerc := 100
EndIf

If nCountPerc > 1 // Há multiplos pagadores
	cQuery := "SELECT SA1.A1_GRPVEN GRPVEN, COUNT(SA1.A1_GRPVEN) CONTA "
	cQuery +=    " FROM " + RetSqlName("SA1") + " SA1, "
	cQuery +=         " " + RetSqlName("NXG") + " NXG  "
	cQuery +=    " WHERE SA1.A1_FILIAL = '" + xFilial("SA1") + "' "
	cQuery +=      " AND NXG.NXG_FILIAL = '" + xFilial("NXG") + "' "
	cQuery +=      " AND SA1.A1_COD  = NXG.NXG_CLIPG "
	cQuery +=      " AND SA1.A1_LOJA = NXG.NXG_LOJAPG "
	cQuery +=      " AND NXG.NXG_FILA = '" + oParams:GetCFilaImpr() + "' "
	If !Empty(cCPREFT)
		cQuery +=  " AND NXG.NXG_CPREFT = '" + cCPREFT + "' "
	Else
		cQuery +=  " AND NXG.NXG_CFIXO  = '" + cCFIXO + "' "
		cQuery +=  " AND NXG.NXG_CFATAD = '" + cCFATAD + "' "
	EndIf
	cQuery +=     " AND NXG.D_E_L_E_T_ = ' ' "
	cQuery +=     " AND SA1.D_E_L_E_T_ = ' ' "
	cQuery +=     " GROUP BY SA1.A1_GRPVEN "

	cQuery := ChangeQuery(cQuery, .F.)
	DbCommitAll() // Para efetivar a alteração no banco de dados (não impacta no rollback da transação)
	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryRes, .T., .F. )

	If Empty((cQryRes)->GRPVEN) .AND. (cQryRes)->CONTA > 1
		cTpFat := "1" // Litis
	Else
		nCountGrp := 0
		cGrpVen   := (cQryRes)->GRPVEN
		cTpFat    := ""
		While (!(cQryRes)->(EOF()) .AND. Empty(cTpFat) )
			If (cQryRes)->GRPVEN <> cGrpVen
				cTpFat := "1"    //Litisconsórcio
			EndIf
			nCountGrp += 1
			(cQryRes)->(DbSkip())
		EndDo
		If Empty(cTpFat)  // Se os grupos forem iguais, é multipayer
			cTpFat := "2"  // MultiPayer
		EndIf
	EndIf

	(cQryRes)->(dbCloseArea())

Else
	cTpFat := ""
EndIf

If !Empty( cCJCONT )

	cQueryFat	:= "SELECT NX5.NX5_COD, "
	cQueryFat	+=        "NW2.NW2_CESCR CESCR, "
	cQueryFat	+=        "NXG.NXG_CMOE, "
	cQueryFat	+=        "NXG.NXG_DTVENC, "
	cQueryFat	+=        "NXG.NXG_CCONT, "
	cQueryFat	+=        "' ' CODCONTR, "
	cQueryFat	+=        "NX5.NX5_DREFIH, "
	cQueryFat	+=        "NX5.NX5_DREFFH, "
	cQueryFat	+=        "NX5.NX5_DREFID, "
	cQueryFat	+=        "NX5.NX5_DREFFD, "
	cQueryFat	+=        "NX5.NX5_DREFIT, "
	cQueryFat	+=        "NX5.NX5_DREFFT, "
	cQueryFat	+=        "NX5.NX5_TS TEMTS, "
	cQueryFat	+=        "NX5.NX5_DES TEMDP, "
	cQueryFat	+=        "NX5.NX5_TAB TEMLT, "
	cQueryFat	+=        "NX5.NX5_FIXO TEMFX, "
	cQueryFat	+=        "NX5.NX5_FATADC TEMFA, "
	cQueryFat	+=        "SA1.A1_COD CCLIEN, "
	cQueryFat	+=        "SA1.A1_LOJA CLOJA, "
	cQueryFat	+=        "SA1NXG.A1_NOME, "
	cQueryFat	+=        "SA1NXG.A1_END, "
	cQueryFat	+=        "SA1NXG.A1_COMPLEM, "
	cQueryFat	+=        "SA1NXG.A1_PESSOA, "
	cQueryFat	+=        "SA1NXG.A1_CGC, "
	cQueryFat	+=        "SA1NXG.A1_PAIS, "
	cQueryFat	+=        "SA1NXG.A1_EST, "
	cQueryFat	+=        "SA1NXG.A1_MUN, "
	cQueryFat	+=        "SA1NXG.A1_BAIRRO, "
	cQueryFat	+=        "SA1NXG.A1_CEP, "
	cQueryFat	+=        "SA1NXG.A1_INSCR, "
	cQueryFat	+=        "SA1NXG.A1_INSCRM, "

	cQueryFat	+=        "NX5.NX5_VLFATH, "
	cQueryFat	+=        "NX5.NX5_VLFATD, "
	cQueryFat	+=        "NX5.NX5_VLFIXH, "
	cQueryFat	+=        "NX5.NX5_VLFIXD, "

	cQueryFat	+=        "NX5.NX5_CALDIS, "
	cQueryFat	+=        "SA1NXG.A1_EMAIL, "
	cQueryFat	+=        "NXG.NXG_COD, "
	cQueryFat	+=        "NXG.NXG_FPAGTO, "
	cQueryFat	+=        "NXG.NXG_CBANCO, "
	cQueryFat	+=        "NXG.NXG_CAGENC, "
	cQueryFat	+=        "NXG.NXG_CCONTA, "
	cQueryFat	+=        "NXG.NXG_CLIPG CLIPG, "
	cQueryFat	+=        "NXG.NXG_LOJAPG LOJAPG, "
	cQueryFat	+=        "NXG.NXG_PERCEN PERCEN, "
	cQueryFat	+=        "NXG.NXG_CCDPGT, "
	cQueryFat	+=        "NX5.NX5_CJCONT, "
	cQueryFat	+=        "NXG.NXG_CIDIO, "
	cQueryFat	+=        "NXG.NXG_CIDIO2, "
	cQueryFat	+=        "NXG.NXG_DESPAD, "
	cQueryFat	+=        "NXG.NXG_CRELAT, "
	cQueryFat	+=        "NXG.NXG_CCARTA, "
	If NXG->(ColumnPos('NXG_VLADIA')) > 0 //Proteção
		cQueryFat	+=    "NXG.NXG_VLADIA VLADIA, "
	EndIf
	If lNXGEmail
		cQueryFat	+=    "NXG.NXG_EMAIL, "
	EndIf
	cQueryFat	+=        "NX5.NX5_PACREH, "
	cQueryFat	+=        "NX5.NX5_ACRESH, "
	cQueryFat	+=        "NX5.NX5_DESCH, "
	cQueryFat	+=        "NX5.NX5_PDESCH, "
	cQueryFat	+=        "NW2.NW2_CTIPOF CTIPOF, "
	cQueryFat	+=        "NXG.NXG_CFATUR, "
	cQueryFat	+=        "NXG.NXG_CESCR "
	If lPoNumbNX5
		cQueryFat	+=  ", NX5.NX5_PONUMB "
	EndIf
	If lProtJuros
		cQueryFat +=    ", NXG.NXG_TXPERM "
		cQueryFat +=    ", NXG.NXG_PJUROS "
		cQueryFat +=    ", NXG.NXG_DESFIN "
		cQueryFat +=    ", NXG.NXG_DIADES "
		cQueryFat +=    ", NXG.NXG_TPDESC "
	EndIf
	If lProtGrsHn
		cQueryFat +=    ", NXG.NXG_GROSHN "
		cQueryFat +=    ", NXG.NXG_PERCGH "
	EndIf
	cQueryFat   +=      ", NX5.NX5_CESCR "
	cQueryFat   +=      IIF(lNUHcEmail, ", NUH.NUH_CEMAIL ", ", ' ' NUH_CEMAIL ")
	cQueryFat   +=      IIF(lNXGEmlMin, ", NXG.NXG_EMLMIN ", "")
	cQueryFat   +=      IIF(lNUHEmlMin, ", NUH.NUH_EMLMIN ", "")
	cQueryFat   += "  FROM " + RetSqlName("NX5") + " NX5, "
	cQueryFat   +=      RetSqlName("NW2") + " NW2, "
	cQueryFat   +=      RetSqlName("NXG") + " NXG, "
	cQueryFat   +=      RetSqlName("SA1") + " SA1, "
	cQueryFat   +=      RetSqlName("SA1") + " SA1NXG, "
	cQueryFat   +=      RetSqlName("NUH") + " NUH "
	cQueryFat   += " WHERE NX5.NX5_FILIAL = '" + xFilial("NX5") + "' "
	cQueryFat   +=   " AND NW2.NW2_FILIAL = '" + xFilial("NW2") + "' "
	cQueryFat   +=   " AND NXG.NXG_FILIAL = '" + xFilial("NXG") + "' "
	cQueryFat   +=   " AND SA1.A1_FILIAL  = '" + xFilial("SA1") + "' "
	cQueryFat   +=   " AND NUH.NUH_FILIAL = '" + xFilial("NUH") + "' "
	cQueryFat   +=   " AND NW2.NW2_COD = NX5.NX5_CJCONT "
	cQueryFat   +=   " AND NW2.NW2_CCLIEN = SA1.A1_COD "
	cQueryFat   +=   " AND NW2.NW2_CLOJA = SA1.A1_LOJA "
	cQueryFat   +=   " AND NXG.NXG_FILA	= NX5.NX5_COD "
	cQueryFat   +=   " AND NX5.NX5_CPREFT = '" + cCPREFT + "' "
	cQueryFat   +=   " AND NX5.NX5_CPREFT = NXG.NXG_CPREFT "
	cQueryFat   +=   " AND NX5.NX5_CODUSR = '" + oParams:GetCodUser() + "' "
	cQueryFat   +=   " AND NX5.NX5_COD = '" + oParams:GetCFilaImpr() + "' "
	cQueryFat   +=   " AND NXG.NXG_CLIPG = SA1NXG.A1_COD "
	cQueryFat   +=   " AND NXG.NXG_LOJAPG = SA1NXG.A1_LOJA "
	cQueryFat   +=   " AND NXG.NXG_CLIPG = NUH.NUH_COD"
	cQueryFat   +=   " AND NXG.NXG_LOJAPG = NUH.NUH_LOJA "
	cQueryFat   +=   " AND NX5.D_E_L_E_T_ = ' ' "
	cQueryFat   +=   " AND NW2.D_E_L_E_T_ = ' ' "
	cQueryFat   +=   " AND NXG.D_E_L_E_T_ = ' ' "
	cQueryFat   +=   " AND SA1.D_E_L_E_T_ = ' ' "
	cQueryFat   +=   " AND SA1NXG.D_E_L_E_T_ = ' ' "
	cQueryFat   +=   " AND NUH.D_E_L_E_T_ = ' ' 

Else
	cQueryFat   := "SELECT NX5.NX5_COD, "
	cQueryFat   +=        "NT0.NT0_CESCR CESCR, "
	cQueryFat   +=        "NXG.NXG_CMOE, "
	cQueryFat   +=        "NXG.NXG_DTVENC, "
	cQueryFat   +=        "NXG.NXG_CCONT, "
	cQueryFat   +=        "NT0.NT0_COD CODCONTR, "
	cQueryFat   +=        "NX5.NX5_DREFIH, "
	cQueryFat   +=        "NX5.NX5_DREFFH, "
	cQueryFat   +=        "NX5.NX5_DREFID, "
	cQueryFat   +=        "NX5.NX5_DREFFD, "
	cQueryFat   +=        "NX5.NX5_DREFIT, "
	cQueryFat   +=        "NX5.NX5_DREFFT, "
	cQueryFat   +=        "NX5.NX5_TS TEMTS, "
	cQueryFat   +=        "NX5.NX5_DES TEMDP, "
	cQueryFat   +=        "NX5.NX5_TAB TEMLT, "
	cQueryFat   +=        "NX5.NX5_FIXO TEMFX, "
	cQueryFat   +=        "NX5.NX5_FATADC TEMFA, "
	cQueryFat   +=        "SA1.A1_COD CCLIEN, "
	cQueryFat   +=        "SA1.A1_LOJA CLOJA, "
	cQueryFat   +=        "SA1NXG.A1_NOME, "
	cQueryFat   +=        "SA1NXG.A1_END, "
	cQueryFat   +=        "SA1NXG.A1_COMPLEM, "
	cQueryFat   +=        "SA1NXG.A1_PESSOA, "
	cQueryFat   +=        "SA1NXG.A1_CGC, "
	cQueryFat   +=        "SA1NXG.A1_PAIS, "
	cQueryFat   +=        "SA1NXG.A1_EST, "
	cQueryFat   +=        "SA1NXG.A1_MUN, "
	cQueryFat   +=        "SA1NXG.A1_BAIRRO, "
	cQueryFat   +=        "SA1NXG.A1_CEP, "
	cQueryFat   +=        "SA1NXG.A1_INSCR, "
	cQueryFat   +=        "SA1NXG.A1_INSCRM, "
	cQueryFat   +=        "NX5.NX5_VLFATH, "
	cQueryFat   +=        "NX5.NX5_VLFATD, "
	cQueryFat   +=        "NX5.NX5_VLFIXH, "
	cQueryFat   +=        "NX5.NX5_VLFIXD, "
	cQueryFat   +=        "NX5.NX5_CALDIS, "
	cQueryFat   +=        "SA1NXG.A1_EMAIL, "
	cQueryFat   +=        "NXG.NXG_COD, "
	cQueryFat   +=        "NXG.NXG_FPAGTO, "
	cQueryFat   +=        "NXG.NXG_CBANCO, "
	cQueryFat   +=        "NXG.NXG_CAGENC, "
	cQueryFat   +=        "NXG.NXG_CCONTA, "
	cQueryFat   +=        "NXG.NXG_CLIPG CLIPG, "
	cQueryFat   +=        "NXG.NXG_LOJAPG LOJAPG, "
	cQueryFat   +=        "NXG.NXG_PERCEN PERCEN, "
	cQueryFat   +=        "NXG.NXG_CCDPGT, "
	cQueryFat   +=        "NX5.NX5_CJCONT, "
	cQueryFat   +=        "NXG.NXG_CIDIO, "
	cQueryFat   +=        "NXG.NXG_CIDIO2, "
	cQueryFat   +=        "NXG.NXG_DESPAD, "
	cQueryFat   +=        "NXG.NXG_CRELAT, "
	cQueryFat   +=        "NXG.NXG_CCARTA, "
	If NXG->(ColumnPos('NXG_VLADIA')) > 0 //Proteção
		cQueryFat +=      "NXG.NXG_VLADIA VLADIA, "
	EndIf
	If lNXGEmail
		cQueryFat	+=    "NXG.NXG_EMAIL, "
	EndIf
	cQueryFat   +=        "NX5.NX5_PACREH, "
	cQueryFat   +=        "NX5.NX5_ACRESH, "
	cQueryFat   +=        "NX5.NX5_DESCH, "
	cQueryFat   +=        "NX5.NX5_PDESCH, "
	cQueryFat   +=        "NT0.NT0_CTIPOF CTIPOF, "
	cQueryFat   +=        "NXG.NXG_CFATUR, "
	cQueryFat   +=        "NXG.NXG_CESCR "
	If lPoNumbNX5
		cQueryFat	+=  ", NX5.NX5_PONUMB "
	EndIf
	If lProtJuros
		cQueryFat +=    ", NXG.NXG_TXPERM "
		cQueryFat +=    ", NXG.NXG_PJUROS "
		cQueryFat +=    ", NXG.NXG_DESFIN "
		cQueryFat +=    ", NXG.NXG_DIADES "
		cQueryFat +=    ", NXG.NXG_TPDESC "
	EndIf
	If lProtGrsHn
		cQueryFat +=    ", NXG.NXG_GROSHN "
		cQueryFat +=    ", NXG.NXG_PERCGH "
	EndIf
	cQueryFat     +=    ", NX5.NX5_CESCR "
	cQueryFat   +=    IIF(lNUHcEmail, ", NUH.NUH_CEMAIL ", ",' ' NUH_CEMAIL ")
	cQueryFat   +=    IIF(lNXGEmlMin, ", NXG.NXG_EMLMIN ", "")
	cQueryFat   +=    IIF(lNUHEmlMin, ", NUH.NUH_EMLMIN ", "")
	cQueryFat	+=  " FROM " + RetSqlName("NXB") + " NXB, "
	cQueryFat	+=      RetSqlName("NT0") + " NT0, "
	cQueryFat	+=      RetSqlName("NX5") + " NX5, "
	cQueryFat	+=      RetSqlName("NXG") + " NXG, "
	cQueryFat	+=      RetSqlName("SA1") + " SA1, "
	cQueryFat	+=      RetSqlName("SA1") + " SA1NXG, "
	cQueryFat	+=      RetSqlName("NUH") + " NUH "
	cQueryFat	+= " WHERE NXB.NXB_FILIAL = '" + xFilial("NXB") + "' "
	cQueryFat	+=   " AND NT0.NT0_FILIAL = '" + xFilial("NT0") + "' "
	cQueryFat	+=   " AND NX5.NX5_FILIAL = '" + xFilial("NX5") + "' "
	cQueryFat	+=   " AND SA1.A1_FILIAL = '" + xFilial("SA1") + "' "
	cQueryFat	+=   " AND SA1NXG.A1_FILIAL = '" + xFilial("SA1") +"' "
	cQueryFat	+=   " AND NXG.NXG_FILIAL = '" + xFilial("NXG") + "' "
	cQueryFat	+=   " AND NXB.NXB_CCONTR = NT0.NT0_COD "
	cQueryFat	+=   " AND NT0.NT0_CCLIEN = SA1.A1_COD "
	cQueryFat	+=   " AND NT0.NT0_CLOJA = SA1.A1_LOJA "
	cQueryFat	+=   " AND NXG.NXG_CLIPG = SA1NXG.A1_COD "
	cQueryFat	+=   " AND NXG.NXG_LOJAPG = SA1NXG.A1_LOJA "
	cQueryFat	+=   " AND NX5.NX5_COD = NXG.NXG_FILA "
	cQueryFat	+=   " AND NXB.NXB_CFATUR = '" + cFatura + "' "
	cQueryFat	+=   " AND NXB.NXB_CESCR = '" + cEscr + "' "

	If !Empty(cCPREFT)
		cQueryFat += " AND NX5.NX5_CPREFT = NXG.NXG_CPREFT "
		cQueryFat += " AND NX5.NX5_CPREFT = '" + cCPREFT +"' "
	Else
		cQueryFat += " AND NX5.NX5_CPREFT = NXG.NXG_CPREFT "
		cQueryFat += " AND NXB.NXB_CCONTR = NX5_CCONTR "
	EndIf
	If !Empty(cCFIXO) .And. Empty(cCPREFT)
		cQueryFat += " AND NX5.NX5_CFIXO = '" + cCFIXO + "' "
	EndIf

	If !Empty(cCFATAD) .And. Empty(cCPREFT)
		cQueryFat += " AND NX5.NX5_CFATAD = '" + cCFATAD + "' "
	EndIf

	cQueryFat	+=   " AND NX5.NX5_CODUSR = '" + oParams:GetCodUser() + "' "
	cQueryFat	+=   " AND NX5.NX5_COD = '" + oParams:GetCFilaImpr() + "' "

	cQueryFat	+=   " AND NXG.NXG_CLIPG = NUH.NUH_COD"
	cQueryFat	+=   " AND NXG.NXG_LOJAPG = NUH.NUH_LOJA "
	cQueryFat	+=   " AND NT0.D_E_L_E_T_ = ' ' "
	cQueryFat	+=   " AND NXB.D_E_L_E_T_ = ' ' "
	cQueryFat	+=   " AND NX5.D_E_L_E_T_ = ' ' "
	cQueryFat	+=   " AND SA1.D_E_L_E_T_ = ' ' "
	cQueryFat	+=   " AND SA1NXG.D_E_L_E_T_ = ' ' "
	cQueryFat	+=   " AND NXG.D_E_L_E_T_ = ' ' "
	cQueryFat	+=   " AND NUH.D_E_L_E_T_ = ' ' 
	cQueryFat   += " GROUP BY "
	cQueryFat	+=        "NX5.NX5_COD, "
	cQueryFat	+=        "NT0.NT0_CESCR, "
	cQueryFat	+=        "NXG.NXG_CMOE, "
	cQueryFat	+=        "NXG.NXG_DTVENC, "
	cQueryFat	+=        "NXG.NXG_CCONT, "
	cQueryFat	+=        "NT0.NT0_COD, "
	cQueryFat	+=        "NX5.NX5_DREFIH, "
	cQueryFat	+=        "NX5.NX5_DREFFH, "
	cQueryFat	+=        "NX5.NX5_DREFID, "
	cQueryFat	+=        "NX5.NX5_DREFFD, "
	cQueryFat	+=        "NX5.NX5_DREFIT, "
	cQueryFat	+=        "NX5.NX5_DREFFT, "
	cQueryFat	+=        "NX5.NX5_TS, "
	cQueryFat	+=        "NX5.NX5_DES, "
	cQueryFat	+=        "NX5.NX5_TAB, "
	cQueryFat	+=        "NX5.NX5_FIXO, "
	cQueryFat	+=        "NX5.NX5_FATADC, "
	cQueryFat	+=        "SA1.A1_COD, "
	cQueryFat	+=        "SA1.A1_LOJA, "
	cQueryFat	+=        "SA1NXG.A1_NOME, "
	cQueryFat	+=        "SA1NXG.A1_END, "
	cQueryFat	+=        "SA1NXG.A1_COMPLEM, "
	cQueryFat	+=        "SA1NXG.A1_PESSOA, "
	cQueryFat	+=        "SA1NXG.A1_CGC, "
	cQueryFat	+=        "SA1NXG.A1_PAIS, "
	cQueryFat	+=        "SA1NXG.A1_EST, "
	cQueryFat	+=        "SA1NXG.A1_MUN, "
	cQueryFat	+=        "SA1NXG.A1_BAIRRO, "
	cQueryFat	+=        "SA1NXG.A1_CEP, "
	cQueryFat	+=        "SA1NXG.A1_INSCR, "
	cQueryFat	+=        "SA1NXG.A1_INSCRM, "
	cQueryFat	+=        "NX5.NX5_VLFATH, "
	cQueryFat	+=        "NX5.NX5_VLFATD, "
	cQueryFat	+=        "NX5.NX5_VLFIXH, "
	cQueryFat	+=        "NX5.NX5_VLFIXD, "
	cQueryFat	+=        "NX5.NX5_CALDIS, "
	cQueryFat	+=        "SA1NXG.A1_EMAIL, "
	cQueryFat	+=        "NXG.NXG_COD, "
	cQueryFat	+=        "NXG.NXG_FPAGTO, "
	cQueryFat	+=        "NXG.NXG_CBANCO, "
	cQueryFat	+=        "NXG.NXG_CAGENC, "
	cQueryFat	+=        "NXG.NXG_CCONTA, "
	cQueryFat	+=        "NXG.NXG_CLIPG, "
	cQueryFat	+=        "NXG.NXG_LOJAPG, "
	cQueryFat	+=        "NXG.NXG_PERCEN, "
	cQueryFat	+=        "NXG.NXG_CCDPGT, "
	cQueryFat	+=        "NX5.NX5_CJCONT, "
	cQueryFat	+=        "NXG.NXG_CIDIO, "
	cQueryFat	+=        "NXG.NXG_CIDIO2, "
	cQueryFat	+=        "NXG.NXG_DESPAD, "
	cQueryFat	+=        "NXG.NXG_CRELAT, "
	cQueryFat	+=        "NXG.NXG_CCARTA, "
	If NXG->(ColumnPos('NXG_VLADIA')) > 0 //Proteção
		cQueryFat	+=    "NXG.NXG_VLADIA, "
	EndIf
	If lNXGEmail
		cQueryFat	+=    "NXG.NXG_EMAIL, "
	EndIf
	cQueryFat	+=        "NX5.NX5_PACREH, "
	cQueryFat	+=        "NX5.NX5_ACRESH, "
	cQueryFat	+=        "NX5.NX5_DESCH, "
	cQueryFat	+=        "NX5.NX5_PDESCH, "
	cQueryFat	+=        "NT0.NT0_CTIPOF, "
	cQueryFat	+=        "NXG.NXG_CFATUR, "
	cQueryFat	+=        "NXG.NXG_CESCR "
	If lPoNumbNX5
		cQueryFat	+=  ", NX5.NX5_PONUMB "
	EndIf
	If lProtJuros
		cQueryFat +=    ", NXG.NXG_TXPERM "
		cQueryFat +=    ", NXG.NXG_PJUROS "
		cQueryFat +=    ", NXG.NXG_DESFIN "
		cQueryFat +=    ", NXG.NXG_DIADES "
		cQueryFat +=    ", NXG.NXG_TPDESC "
	EndIf
	If lProtGrsHn
		cQueryFat +=    ", NXG.NXG_GROSHN "
		cQueryFat +=    ", NXG.NXG_PERCGH "
	EndIf
	cQueryFat   +=      ", NUH.NUH_CEMAIL "
	cQueryFat   +=      IIF(lNXGEmlMin, ", NXG.NXG_EMLMIN ", "")
	cQueryFat   +=      IIF(lNUHEmlMin, ", NUH.NUH_EMLMIN ", "")
	cQueryFat   +=      ", NX5.NX5_CESCR "
EndIf

cQueryFat := ChangeQuery(cQueryFat, .F.)
DbCommitAll() // Para efetivar a alteração no banco de dados (não impacta no rollback da transação)
dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQueryFat ), cQryResFat, .T., .F. )

//Preenche o array aContr
cQuery	:= "SELECT "
cQuery	+=    "NXB.NXB_VLFATH as VLFATH, "
cQuery	+=    "NXB.NXB_VLFATD as VLFATD, "
If lDespTrib
	cQuery += "NXB.NXB_VLTRIB as VLDPTRIB, "
	cQuery += "NXB.NXB_VLREMB as VLDPREMB, "
EndIf
cQuery	+=    "(CASE WHEN NXB.NXB_VLLTLM = 0 THEN NXB.NXB_VTAB ELSE NXB.NXB_VLLTLM END) as VLLTLM, "
cQuery	+=    "NXB.NXB_VTS as VLTS, "
cQuery	+=    "NXB.NXB_VTSVIN as VLTSVIN, "
cQuery	+=    "NXB.NXB_VTAB as VLTAB, "
cQuery	+=    "NXB.NXB_DRATL as DESCL "

cQuery	+= " FROM " + RetSqlName("NXB") + " NXB "
cQuery	+= " WHERE NXB.NXB_FILIAL = '" + xFilial("NXB") +"' "
cQuery	+=   " AND NXB.NXB_CFATUR = '" + cFatura +"' "
cQuery	+=   " AND NXB.NXB_CESCR = '" + cEscr +"' "
cQuery	+=   " AND NXB.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery, .F.)
DbCommitAll() // Para efetivar a alteração no banco de dados (não impacta no rollback da transação)
dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryRes, .T., .F. )

nVlFath  := 0
nVlFatD  := 0
nVlFatT  := 0
nVlTS    := 0
nVlTSVin := 0
nVlTab   := 0

While !( (cQryRes)->(EOF()) )

	nVlFath  := nVlFath  + (cQryRes)->VLFATH //sum da NXB    - a nxb é calculada na moeda da PF (ou ct, ou FA)
	nVlFatD  := nVlFatD  + (cQryRes)->VLFATD //Sum da NXB	- a nxb é calculada na moeda da PF (ou ct, ou FA)
	nVlFatT  := nVlFatT  + (cQryRes)->VLLTLM //Sum da NXB	- calcula o valor do tabelado para não contabilizar no desconto do pagador
	nVlTS    := nVlTS    + (cQryRes)->VLTS
	nVlTSVin := nVlTSVin + (cQryRes)->VLTSVIN
	nVlTab   := nVlTab   + (cQryRes)->VLTAB
	If lDespTrib
		nVlDpTrib  += (cQryRes)->VLDPTRIB
		nVlDpReemb += (cQryRes)->VLDPREMB
	EndIf
	nVlDesLFat := nVlDesLFat + (cQryRes)->DESCL
	(cQryRes)->(DbSkip())
EndDo
(cQryRes)->(dbCloseArea())

While aRet[1] .And. !(cQryResFat)->(EOF())
	nNX5Desc := 0

	If Empty((cQryResFat)->NXG_CFATUR) .And. Empty((cQryResFat)->NXG_CESCR) // verifica se já existe fatura emitida para o cliente pagador
		aRet       := {.F., "JA203HFatu" }
		nContFat   := nContFat + 1
		cPoNumbNXA := ""

		cFilaImp   := (cQryResFat)->NX5_COD
		cESCRNT0   := (cQryResFat)->CESCR
		cMoeda     := (cQryResFat)->NXG_CMOE
		cDtVenc    := (cQryResFat)->NXG_DTVENC
		cContato   := (cQryResFat)->NXG_CCONT
		cContrato  := (cQryResFat)->CODCONTR
		cDtIniH    := (cQryResFat)->NX5_DREFIH
		cDtFinH    := (cQryResFat)->NX5_DREFFH
		cDtIniD    := (cQryResFat)->NX5_DREFID
		cDtFinD    := (cQryResFat)->NX5_DREFFD
		cDtIniT    := (cQryResFat)->NX5_DREFIT
		cDtFinT    := (cQryResFat)->NX5_DREFFT
		cClien     := (cQryResFat)->CCLIEN
		cLoja      := (cQryResFat)->CLOJA
		cNomeCli   := (cQryResFat)->A1_NOME
		cLograd    := Alltrim((cQryResFat)->A1_END) + Iif(!Empty((cQryResFat)->A1_COMPLEM), ' - ' + Alltrim((cQryResFat)->A1_COMPLEM), '')
		cPessoa    := (cQryResFat)->A1_PESSOA
		cCGC       := (cQryResFat)->A1_CGC
		cPais      := JurGetDados("SYA", 1, xFilial("SYA") + (cQryResFat)->A1_PAIS, "YA_DESCR")
		cEstado    := (cQryResFat)->A1_EST
		cMiunic    := (cQryResFat)->A1_MUN
		cBairro    := (cQryResFat)->A1_BAIRRO
		cCEP       := (cQryResFat)->A1_CEP
		cInscr     := (cQryResFat)->A1_INSCR
		cInscrMun  := (cQryResFat)->A1_INSCRM
		nOrigH     := (cQryResFat)->NX5_VLFATH
		nOrigD     := (cQryResFat)->NX5_VLFATD
		nVlFixH    := (cQryResFat)->NX5_VLFIXH
		nVlFixD    := (cQryResFat)->NX5_VLFIXD
		cCalDis    := (cQryResFat)->NX5_CALDIS
		If NXG->(ColumnPos('NXG_VLADIA')) > 0 //Proteção
			nVlAdia := (cQryResFat)->VLADIA
		Else
			nVlAdia := 0
		EndIf
		If oParams:GetTpExec() $ "3|4|MS"
			If lNXGEmlMin .And. !Empty((cQryResFat)->NXG_EMLMIN)
				cEmail := AllTrim((cQryResFat)->NXG_EMLMIN)
			ElseIf lNUHEmlMin .And. !Empty((cQryResFat)->NUH_EMLMIN)
				cEmail := AllTrim((cQryResFat)->NUH_EMLMIN)
			EndIf
		Else
			cEmail := AllTrim(IIF(lNXGEmail .And. !Empty((cQryResFat)->NXG_EMAIL), (cQryResFat)->NXG_EMAIL, (cQryResFat)->A1_EMAIL))
		EndIf
		cFPagto    := (cQryResFat)->NXG_FPAGTO
		cBanco     := (cQryResFat)->NXG_CBANCO
		cAgenc     := (cQryResFat)->NXG_CAGENC
		cConta     := (cQryResFat)->NXG_CCONTA
		cCliPag    := (cQryResFat)->CLIPG
		cLojaPag   := (cQryResFat)->LOJAPG
		nPercent   := (cQryResFat)->PERCEN
		cCondPag   := (cQryResFat)->NXG_CCDPGT
		cIdioma    := (cQryResFat)->NXG_CIDIO
		cIdioma2   := (cQryResFat)->NXG_CIDIO2
		cRelat     := (cQryResFat)->NXG_CRELAT
		cCarta     := (cQryResFat)->NXG_CCARTA
		cTEMFX     := (cQryResFat)->TEMFX
		cTEMFA     := (cQryResFat)->TEMFA
		cTEMTS     := IIF(cTEMFX == "1" .And. Empty(cCPREFT), IIF(nVlTS + nVlTSVin > 0, '1', '2'), (cQryResFat)->TEMTS)
		cTEMLT     := IIF(cTEMFX == "1" .And. Empty(cCPREFT), IIF(nVlTab           > 0, '1', '2'), (cQryResFat)->TEMLT)
		cTEMDP     := IIF(cTEMFX == "1" .And. Empty(cCPREFT), IIF(nVlFatD          > 0, '1', '2'), (cQryResFat)->TEMDP)

		nDESCPAG   := (cQryResFat)->NXG_DESPAD
		nPACREH    := (cQryResFat)->NX5_PACREH
		nACRESH    := (cQryResFat)->NX5_ACRESH
		nDESCH     := (cQryResFat)->NX5_DESCH
		nPDESCH    := (cQryResFat)->NX5_PDESCH
		cTipoF     := (cQryResFat)->CTIPOF

		If lProtJuros
			nTaxaPerm  := (cQryResFat)->NXG_TXPERM
			nPorcJuros := (cQryResFat)->NXG_PJUROS
			nDescFin   := (cQryResFat)->NXG_DESFIN
			nDiaDesc   := (cQryResFat)->NXG_DIADES
			cTipoDesc  := (cQryResFat)->NXG_TPDESC
		EndIf

		If lProtGrsHn
			cGrossHon  := (cQryResFat)->NXG_GROSHN
			nPercGrHon := (cQryResFat)->NXG_PERCGH
		EndIf

		cCEmail    := (cQryResFat)->NUH_CEMAIL
		cNFGer     := "2"

		If cTEMFA == "1" .And. Empty(cTipoF)
			cTipoF := JurGetDados("NVV", 1, xFilial("NVV") + cCFATAD, "NVV_CTPFAT")
		ElseIf cTEMFX == "1" .And. Empty(cTipoF)
			cTipoF := JurGetDados("NT1", 1, xFilial("NT1") + cCFIXO, "NT1_CTPFTU")
		EndIf

		// Ajusta desconto linear conforme fatura
		If nVlDesLine != nVlDesLFat
			nDESCH -= nVlDesLine
			nDESCH += nVlDesLFat
			nVlDesLine := nVlDesLFat
		EndIf

		If nVlOrigH == 0 .And. nVlOrigD == 0
			nVlOrigH   := nVlFath		//Vl original de H - Sum da NXB
			nVlOrigD   := nVlFatD		//Vl Original de D - Sum da NXB
			nVlOrigT   := nVlFatT
			nVlDesLOri := nVlDesLine
			nVlDesEOri := nVlDesEspe
		Else
			nVlFath    := nVlOrigH		//Vl original de H - Sum da NXB
			nVlFatD    := nVlOrigD		//Vl Original de D - Sum da NXB
			nVlFatT    := nVlOrigT
			nVlDesLine := nVlDesLOri
			nVlDesEspe := nVlDesEOri
		EndIf

		nVlDesc   := 0
		nVlAcres  := 0

		// Calcula o desconto/acrescimo na fatura:
		If nPDESCH > 0
			nVlDesc  := Round(( nVlFath * nPDESCH / 100 ), TamSX3('NXA_VLDESC')[2])
		Else
			nVlDesc := nDESCH
		EndIf

		nNX5Desc := nVlDesc

		If nPACREH > 0
			nVlAcres := Round(( nVlFath * nPACREH / 100), TamSX3('NXA_VLACRE')[2])
		Else
			nVlAcres := nACRESH
		EndIf

		//Aplica o Desconto/Acrescimo do pagador sobre o valor da fatura:
		nVlDescPag := Round(( nVlFath - nVlFatT - nVlDesc ) * nDESCPAG / 100.00, TamSX3('NXA_VLDSCP')[2])
		nVlDesc    := nVlDesc  + nVlDescPag

		If nVlFixH == 0
			NXATEMFXH := '2'
		Else
			NXATEMFXH := '1'
		EndIf

		If nVlFixD == 0
			NXATEMFXD := '2'
		Else
			NXATEMFXD := '1'
		EndIf

		If nVlDesc > nVlFixD
			nVlFixD := 0
		EndIf

		If (nVlFath - nVlDesc + nVlAcres + nVlFatD) == 0
			aRet := {.F., "JA203HFatu - " + STR0010 } //### "Não existem valores para emitir a Fatura!"
			Return (aRet)
		EndIf

		If (nVlFath <  0)
			aRet := {.F., "JA203HFatu - " + STR0013 + CRLF + STR0011 } //"Esta fatura não poderá ser emitida:" + "O Valor total de Honorários ficará negativo!"
			Return (aRet)
		EndIf
		If (nVlFatD < 0)
			aRet := {.F., "JA203HFatu - " + STR0013 + CRLF + STR0012 } //"Esta fatura não poderá ser emitida:" + "O Valor total de Despesas ficará negativo!"
			Return (aRet)
		EndIf

		//Grava o valor da moeda nacional conforme o pagador.
		If cMoedaPF == cMoedaNac
			If nOrigH == 0 .AND. nVlFath > 0
				nOrigH := nVlFath
			EndIf
			If nOrigD == 0 .AND. nVlFatD > 0
				nOrigD := nVlFatD
			EndIf
			nFatHMn := nOrigH
			nFatDMn := nOrigD
			nDescMn := nVlDesc
			nAcreMn := nVlAcres
		Else
			nFatHMn := 0
			nFatDMn := 0
			nDescMn := 0
			nAcreMn := 0
		EndIf

		cEscOld := ""
		cFatOld := ""

		aRetCliPag := JurGetDados('NUH', 1, xFilial('NUH') + cCliPag + cLojaPag, aDadCliPag)
		cEndInt := aRetCliPag[01]

		cTxtFat := JurGetDados('NX5', 1, xFilial('NX5') + oParams:GetCFilaImpr(), 'NX5_TEXFAT')
		If lServReinf
			cServReinf := JurGetDados('NX5', 1, xFilial('NX5') + oParams:GetCFilaImpr(), 'NX5_TPSERV')
		EndIf

		If cPessoa == 'F'
			cTpPagador := '2'
		Else
			cTpPagador := '1'
		EndIf

		If nContFat > 1
			cFaturaOld := cFatura
			cEscrOld   := cEscr
		EndIf

		cPartEmi := JurUsuario( oParams:GetCodUser() )
		cGrpCli  := JurGetDados('SA1', 1, xFilial('SA1') + cClien + cLoja, 'A1_GRPVEN' )
		dDtEmiss := JURA203G( 'FT', Date(), 'FATEMI' )[1] //oParams:GetDEmi()

		If Empty(cCondPag)
			If cMoeda == cMoedaNac
				cCondPag := cCndPgNac
				cParam   := "MV_JCPGNAC"
			Else
				cCondPag := cCndPgInt
				cParam   := "MV_JCPGINT"
			EndIf
		EndIf

		//verifica se a condição informada no parametro é válida
		cCondPag := JurGetDados("SE4", 1, Xfilial("SE4") + cCondPag, "E4_CODIGO")
		If Empty(cCondPag)
			aRet := {.F., "JA203HFatu - " + STR0008 + cParam + STR0009 } //### "A condição de pagamento usada no parametro "+ cParam + ### " não é válida!" }
			Return (aRet)
		EndIf

		//Parametro para verificar a opção de Contra Apresentação
		If Len(oParams:GetParams()) > 0 .And. oParams:GetParams()[10] == 'S'
			dDtVenc := dDtEmiss
		Else
			dDtVenc := stoD(cDtVenc)
		EndIf

		cEscr  := PadR(IIf((cQryResFat)->TEMFA == "1", (cQryResFat)->NX5_CESCR, cESCRNT0),Len(NXA->NXA_CESCR))
		lHonor := (nVlFath > 0)
		lDesp  := (nVlFatD > 0)

		Processa({|| aFatura := JURA203I(cTipoEmi, cEscr, cMoeda, lHonor, lDesp, (STR0004 + cMsgTpFat), dDtEmiss ) }, STR0001, STR0004 + cMsgTpFat, .T.) // "Aguarde..." ### "Verificando o próximo número válido da "

		If aFatura[1]
			cFatura := PadR(aFatura[2], Len(NXA->NXA_COD))
		Else
			Return (aFatura)
		EndIf

		//Preenchimento do campo NXA_NFGER
		If nVlFath == 0
			If NUH->(ColumnPos('NUH_EMITNF')) > 0 //Proteção
				If JurGetDados('NUH', 1, xFilial('NUH') + cCliPag + cLojaPag, 'NUH_EMITNF') == "2"
				 	cNFGer := "3" // Não gerar
				EndIf
			EndIf
		ElseIf cMoeda != cMoedaNac
			If NS7->(ColumnPos('NS7_EMINFI')) > 0 //Proteção
				If JurGetDados('NS7', 1, xFilial('NS7') + cEscr, 'NS7_EMINFI') == "2"
					cNFGer := "3" // Não gerar
				EndIf
			EndIf
		Else
			If NS7->(ColumnPos('NS7_EMINFE')) > 0 .And. NS7->(ColumnPos('NS7_EMINFE')) > 0 //Proteção
				If JurGetDados('NS7', 1, xFilial('NS7') + cEscr, 'NS7_EMINFE') == "2" .And. ;
					JurGetDados('NS7', 1, xFilial('NS7') + cEscr, 'NS7_EMINFS') == "2"
					cNFGer := "3"
				EndIf
			EndIf
		EndIf

		If lEndPSer
			aEndPSer := JurGetDados('NS7', 1, xFilial('NS7') + cEscr, {'NS7_ESTADO','NS7_CMUNIC'})
			If Len(aEndPSer) == 2
				cEstPSer := aEndPSer[1]
				cMunPSer := aEndPSer[2]
			EndIf
		EndIf

		//Grava a Fatura
		DbSelectArea("NXA")
		RecLock("NXA", .T.)
		NXA->NXA_FILIAL  := xFilial("NXA")
		NXA->NXA_CESCR   := cEscr
		NXA->NXA_COD     := cFatura
		NXA->NXA_TIPO    := cTipoEmi
		NXA->NXA_DTEMI   := dDtEmiss
		NXA->NXA_USUEMI  := cPartEmi // Participante que emitiu
		NXA->NXA_DTVENC  := dDtVenc
		NXA->NXA_SITUAC  := "1"
		NXA->NXA_DTCANC  := stoD("  /  /    ")
		NXA->NXA_CMOEDA  := cMoeda
		NXA->NXA_VLFATH  := Iif (nVlFath < 0 , 0, nVlFath)
		NXA->NXA_VLFATD  := Iif (nVlFatD < 0 , 0, nVlFatD)
		NXA->NXA_VLDESC  := nVlDesc
		NXA->NXA_VLDSCL  := nVlDesLine
		If  Empty(cCPREFT) .And. !Empty(oParams:GetCFilaImpr())
			NXA->NXA_VLDSCE  := nNX5Desc
		else
			NXA->NXA_VLDSCE  := nVlDesEspe
		EndIf
		NXA->NXA_VLDSCP  := nVlDescPag
		NXA->NXA_VLACRE  := nVlAcres
		NXA->NXA_IRRF    := 0
		NXA->NXA_PIS     := 0
		NXA->NXA_COFINS  := 0
		NXA->NXA_CSLL    := 0
		NXA->NXA_INSS    := 0
		NXA->NXA_ISS     := 0
		NXA->NXA_CGRPCL  := cGrpCli
		NXA->NXA_CCLIEN  := cClien
		NXA->NXA_CLOJA   := cLoja
		NXA->NXA_CCONT   := cContato
		NXA->NXA_CJCONT  := cCJCONT
		NXA->NXA_CCONTR  := cContrato
		NXA->NXA_WO      := "2"
		NXA->NXA_DREFIH  := stoD(cDtIniH)
		NXA->NXA_DREFFH  := stoD(cDtFinH)
		NXA->NXA_DREFID  := stoD(cDtIniD)
		NXA->NXA_DREFFD  := stoD(cDtFinD)
		NXA->NXA_DREFIT  := stoD(cDtIniT)
		NXA->NXA_DREFFT  := stoD(cDtFinT)
		NXA->NXA_TS      := cTEMTS
		NXA->NXA_DES     := cTEMDP
		NXA->NXA_TAB     := cTEMLT
		NXA->NXA_FIXO    := cTEMFX
		NXA->NXA_FATADC  := cTEMFA
		NXA->NXA_CPART   := cPart
		NXA->NXA_OBS     := ""
		NXA->NXA_RAZSOC  := cNomeCli
		NXA->NXA_ENDENT  := cEndInt
		NXA->NXA_TPPAG   := cTpPagador
		NXA->NXA_CGCCPF  := cCGC
		NXA->NXA_PAIS    := cPais
		NXA->NXA_ESTADO  := cEstado
		NXA->NXA_CIDADE  := cMiunic
		NXA->NXA_BAIRRO  := cBairro
		NXA->NXA_CEP     := cCEP
		NXA->NXA_LOGRAD  := cLograd
		NXA->NXA_INSEST  := cInscr
		NXA->NXA_INSMUN  := cInscrMun
		NXA->NXA_VLFIXH  := NXATEMFXH
		NXA->NXA_VLORIH  := nVlOrigH
		NXA->NXA_VLFIXO  := NXATEMFXD
		NXA->NXA_VLORID  := nVlOrigD
		NXA->NXA_CMOTCA  := " "
		NXA->NXA_TXTFAT  := cTxtFat
		NXA->NXA_CALDIS  := cCalDis
		NXA->NXA_VUADIA  := 0
		NXA->NXA_VSADIA  := nVlAdia
		NXA->NXA_EMAIL   := cEmail
		NXA->NXA_CRTENV  := "2"
		NXA->NXA_RELENV  := "2"
		NXA->NXA_RECENV  := "2"
		NXA->NXA_MAILEN  := TratMailEn(aRetCliPag[02], NXA->NXA_VLFATH,  NXA->NXA_VLFATD, "2", "3") 
		NXA->NXA_USRCAN  := " "
		NXA->NXA_CPREFT  := cCPREFT
		NXA->NXA_CFTADC  := cCFATAD
		NXA->NXA_CFIXO   := cCFIXO
		NXA->NXA_FPAGTO  := cFPagto
		NXA->NXA_CBANCO  := cBanco
		NXA->NXA_CAGENC  := cAgenc
		NXA->NXA_CCONTA  := cConta
		NXA->NXA_CESCSU  := cEscOld
		NXA->NXA_CFTSUB  := cFatOld
		NXA->NXA_CFILA   := oParams:GetCFilaImpr()
		NXA->NXA_CLIPG   := cCliPag
		NXA->NXA_LOJPG   := cLojaPag
		NXA->NXA_NFGER   := cNFGer
		NXA->NXA_CCDPGT  := cCondPag
		NXA->NXA_DOC     := " "
		NXA->NXA_SERIE   := " "
		NXA->NXA_TITGER  := "2"
		NXA->NXA_PERFAT  := nPercent
		NXA->NXA_CIDIO   := cIdioma
		NXA->NXA_CIDIO2  := cIdioma2
		NXA->NXA_CTPFAT  := cTpFat
		NXA->NXA_TPREL   := cRelat
		NXA->NXA_CCARTA  := cCarta
		NXA->NXA_CTIPOF  := cTipoF

		NXA->NXA_FATHMN  := nFatHMn
		NXA->NXA_FATDMN  := nFatDMn
		NXA->NXA_DESCMN  := nDescMn
		NXA->NXA_ACREMN  := nAcreMn

		If lProtJuros
			NXA->NXA_TXPERM  := nTaxaPerm
			NXA->NXA_PJUROS  := nPorcJuros
			NXA->NXA_DESFIN  := nDescFin
			NXA->NXA_DIADES  := nDiaDesc
			NXA->NXA_TPDESC  := cTipoDesc
		EndIf

		If lDespTrib
			NXA->NXA_VLTRIB := nVlDpTrib
			NXA->NXA_VLREMB := nVlDpReemb
		EndIf

		If lPoNumber
			If lPoNumbNX5
				cPoNumbNXA := (cQryResFat)->NX5_PONUMB
			Else
				cPoNumbNXA := cPoNumber
			EndIf
			NXA->NXA_PONUMB := cPoNumbNXA 
		EndIf

		If lServicos
			NXA->NXA_SERVIC := cServicos
		EndIf

		If lServReinf
			NXA->NXA_TPSERV := cServReinf
		EndIf

		If lFrmEnvFat
			NXA->NXA_CORFAT  :=  TratMailEn(aRetCliPag[03], NXA->NXA_VLFATH,  NXA->NXA_VLFATD, "1", "2")  
		EndIf

		If lEndPSer
			NXA->NXA_ESTPS  := cEstPSer
			NXA->NXA_CMUNPS := cMunPSer
		EndIf
		
		If lcEmail
			NXA->NXA_CEMAIL := cCEmail
		EndIf

		NXA->(MsUnlock() )
		NXA->(DbCommit())
		//Grava na fila de sincronização
		J170GRAVA("NXA", xFilial("NXA") + cEscr + cFatura, "3")

		// Ajusta os relacionamentos da Fatura
		If nContFat == 1
			// Ajusta a situação da pré
			If !Empty( cCPREFT )
				JA203HPre(cCPREFT, oParams:GetTpExec())
			EndIf
			JA203HAjus( cCPREFT , oParams:GetMarkFat(), oParams:GetCodUser(), cFatura, cEscr, cTipoEmi, oParams:GetMarkEsc() )

		Else
			// Copia os relacionamentos para o pagador atual
			JA203HCpy("NXB", cFaturaOld, cEscrOld, cFatura, cEscr, oParams:GetCodUser())
			JA203HCpy("NXC", cFaturaOld, cEscrOld, cFatura, cEscr, oParams:GetCodUser())
			JA203HCpy("NXD", cFaturaOld, cEscrOld, cFatura, cEscr, oParams:GetCodUser())
			JA203HCpy("NXE", cFaturaOld, cEscrOld, cFatura, cEscr, oParams:GetCodUser())

			JA203HCpyL(cFaturaOld, cEscrOld, cFatura, cEscr, oParams )
		EndIf
		
		If oParams:GetTpExec() == "5"
			J203HGOld(cFatura, cEscr, cCPREFT, cCFATAD, cCFIXO, cCliPag, cLojaPag)  // Grava o número da nova fatura na antiga se existir
		EndIf
		J203CotFat(oParams ,cMoeda, cFatura, cEscr ) //Grava as cotações da Fatura

		aadd(aFaturas, { cMoeda, cMoedaPF, cEscr, cFatura, nVlDesc, nVlAcres, (nPercent/100.00),; //[7]
						cCliPag, cLojaPag, cBanco, cAgenc, cConta, nVlAdia, NXA->(RECNO()), cDtVenc, cGrossHon, nPercGrHon}) //[17]
		aRet := {.T., "JA203HFatu" }
	Else
		If !Empty( cCPREFT )
			JA203HPre(cCPREFT, oParams:GetTpExec())
		EndIf
		If oParams:GetTpExec() == "5"
			J203HGOld(cFatura, cEscr, cCPREFT, cCFATAD, cCFIXO, cCliPag, cLojaPag)  // Grava o número da nova fatura na antiga se existir
		EndIf
		aRet := {.T., "JA203HFatu" } // retorna .T. pois ja existe fatura para esse cliente pagador
	EndIf

	(cQryResFat)->(dbSkip())

EndDo

(cQryResFat)->(dbCloseArea())

//Ajusta as faturas nas moedas corretas
nI := 1
While aRet[1] .AND. nI <= Len(aFaturas)

	//Faz o rateio do percentual e converção de valores na moeda do pagador
	aRet := JA203HConv(oParams, aFaturas[nI][1], aFaturas[nI][2], aFaturas[nI][3], aFaturas[nI][4], aFaturas[nI][7], aFaturas[nI][16], aFaturas[nI][17])

	//Rateio do Desconto do Pagador entre Contratos / Casos / Participantes
	If aRet[1] .And. !Empty(aFaturas[nI][5]) .and. J203VlDesc(aFaturas[nI][3], aFaturas[nI][4], "2")
		lExibe  := .F.
		lInsSld := .T.
		aRet := JA203ARat(aFaturas[nI][3], aFaturas[nI][4], "3", "", lExibe, lInsSld)
	EndIf
	//-- Não pode fazer rateio do acréscimo - deve ser sempre proporcional
	//Rateio do Acréscimo entre Contratos / Casos / Participantes
	If aRet[1] .And. !Empty(aFaturas[nI][6])
		lExibe  := .F.
		lInsSld := .T.
		aRet := JA203ARat(aFaturas[nI][3], aFaturas[nI][4], "2", "", lExibe, lInsSld)
	EndIf

	If aRet[1]
		If oParams:GetcTipofat() == "1"

			Processa( { || aRet := JA203TIT(aFaturas[nI][3], aFaturas[nI][4] , oParams:GetcTipofat()) }, STR0001, STR0002, .F. )// "Aguarde"###"Gerando Financeiro..."
			J203ImpRet()
			If aRet[1]
				//Se o cliente possuir adiantamento:
				If J203ADIANT( aFaturas[nI][8], aFaturas[nI][9], aFaturas[nI][3] )
					//Abre a tela de utilização de adiantamento para a fatura
					J203UTIADI( aFaturas[nI][3], aFaturas[nI][4], oParams:GetTpExec(), oParams:GetCFilaImpr() )
				EndIf

				If aFaturas[nI][13] > 0 // Se preenchido valor para solicitação de adiantamento no pagador
					J203CtrAdi(aFaturas[nI][8], aFaturas[nI][9], aFaturas[nI][1], ;
								aFaturas[nI][10], aFaturas[nI][11], aFaturas[nI][12], aFaturas[nI][13], aFaturas[nI][3], aFaturas[nI][15], aFaturas[nI][4])
				EndIf
				
				If NXG->(IndexKey(3)) == "NXG_FILIAL+NXG_FILA+NXG_CLIPG+NXG_LOJAPG"  // Proteção
					NXG->(dbSetOrder(3)) //NXG_FILIAL+NXG_FILA+NXG_CLIPG+NXG_LOJAPG
					If (NXG->(DbSeek(xFilial("NXG") + oParams:GetCFilaImpr() + aFaturas[nI][8] + aFaturas[nI][9])))
						RecLock("NXG", .F.)
						NXG->NXG_CESCR  := aFaturas[nI][3]
						NXG->NXG_CFATUR := aFaturas[nI][4]
						NXG->(MsUnLock())
						NXG->(DbCommit())
						J203EncFat(oParams:GetCFilaImpr(), aFaturas[nI][8], aFaturas[nI][9], aFaturas[nI][3], aFaturas[nI][4])
					EndIf
				Else //quando remover a proteção, remover o bloco do else
					NXG->(dbSetOrder(2)) //NXG_FILIAL + NXG_CPREFT + NXG_CLIPG + NXG_LOJAPG + NXG_CFATAD + NXG_CFIXO
					If (NXG->(DbSeek(xFilial("NXG") + cCPREFT + aFaturas[nI][8] + aFaturas[nI][9] + cCFATAD + cCFIXO)))
						RecLock("NXG", .F.)
						NXG->NXG_CESCR  := aFaturas[nI][3]
						NXG->NXG_CFATUR := aFaturas[nI][4]
						NXG->(MsUnLock())
						NXG->(DbCommit())
						J203EncFat(oParams:GetCFilaImpr(), aFaturas[nI][8], aFaturas[nI][9], aFaturas[nI][3], aFaturas[nI][4])
					EndIf
				EndIf

			Else
				Exit
			EndIf

		ElseIf oParams:GetcTipofat() $ "2,3,4" //Minuta de Fatura/Pre Fatura/Minuta de Sócio

			//Simula o calculo de impostos para a minuta
			aRet  := JA203TIT(aFaturas[nI][3], aFaturas[nI][4], oParams:GetcTipofat())

		EndIf
	EndIf

	If aRet[1]
		Aadd(aRecnosFat, aFaturas[nI][14])

		cTpNFSCot := SuperGetMV("MV_JNFSCOT",, "1")

		// Executa a emissão de nota fiscal de saída (SF2 e SD2) após emissão da fatura
		If NXA->NXA_TIPO == "FT" .And. NXA->NXA_NFGER == "2" .And. SuperGetMV("MV_JFATXNF", .F., .F.); // Parâmetro habilita o fluxo de emissão e cancelamento de NF a partir da fatura
		   .And. cTpNFSCot <> "3" // Não emite NF quando considerar a cotação da baixa pois nesse momento a fatura não foi baixada

			If cTpNFSCot == "1"
				nCotacNF := IIF(NXA->NXA_CMOEDA == "01", 1, JurGetDados("NXF", 2, xFilial("NXF") + NXA->NXA_COD + NXA->NXA_CESCR + NXA->NXA_CMOEDA, "NXF_COTAC1"))
			ElseIf cTpNFSCot == "2"
				If SuperGetMv("MV_JTPCONV",, "1") == "2" // Cotação Mensal
					nCotacNF := IIF(NXA->NXA_CMOEDA == "01", 1, JurGetDados("NXQ", 1, xFilial("NXQ") + AnoMes(dDtEmiss) + NXA->NXA_CMOEDA, "NXQ_COTAC")) // NXQ_FILIAL + NXQ_ANOMES + NXQ_CMOEDA
				Else // Cotação diária
					nCotacNF := IIF(NXA->NXA_CMOEDA == "01", 1, JurGetDados("CTP", 1, xFilial("CTP") + DtoS(dDtEmiss) + NXA->NXA_CMOEDA, "CTP_TAXA"))
				EndIf
			EndIf
			J205GERANF(aFaturas[nI][14], .T., "", .F., "", nCotacNF, nCotacNF, .F., .F., .F., Nil, @cLogFatNF)
		EndIf
	EndIf

	nI := nI + 1
EndDo

// Insere log de emissão de NF
IIF(Empty(cLogFatNF), Nil, Aadd(aRet, cLogFatNF))

oParams:SetFatEmite(aRecnosFat)

RestArea(aArea)

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} J203EncFat
Rotina para vincular/desvincular os encaminhamentos de fatura na fatura

@Param cFila     Código da fila de emissão
@Param cCliPag   Código do cliente pagador
@Param cLojaPag  Código da loja do cliente pagador
@Param cEscr     Código do escritório 
@Param cFatura   Código da Fatura 

@author Luciano Pereira dos Santos
@since  03/08/2011
/*/
//-------------------------------------------------------------------
Static Function J203EncFat(cFila, cCliPag, cLojaPag, cEscr, cFatura)
Local aArea    := GetArea()
Local cChave   := ""
Local aEncMail := {}
Local lFila    := NVN->(ColumnPos("NVN_CFILA")) > 0  // Proteção
Local lCpoFlag := NVN->(ColumnPos("NVN_ENVENC")) > 0 // @12.1.2310
Local lCpoAgr  := NXA->(ColumnPos("NXA_EMLAGR")) > 0 // @12.1.2310

	If lFila
		NVN->( DbSetOrder(2) ) //NVN_FILIAL+NVN_CFILA+NVN_CLIPG+NVN_LOJPG+NVN_CCONT
		cChave := xFilial("NVN") + cFila + cCliPag + cLojaPag
		If NVN->(DbSeek(cChave))
			While NVN->(!EOF()) .And. (NVN->NVN_FILIAL + NVN->NVN_CFILA + NVN->NVN_CLIPG + NVN->NVN_LOJPG == cChave)
				RecLock("NVN", .F.)
				NVN->NVN_CESCR  := cEscr
				NVN->NVN_CFATUR := cFatura
				NVN->(MsUnlock())
				NVN->(DbCommit())
				
				// Grava e-mail no campo de agrupamento da fatura
				If lCpoFlag .And. lCpoAgr .And. NVN->NVN_ENVENC == "1" // Considera e-mail para envio
					Aadd(aEncMail, AllTrim(JurGetDados("SU5", 1, xFilial("SU5") + NVN->NVN_CCONT, "U5_EMAIL")))
				EndIf
				
				NVN->(DbSkip())
			EndDo
		EndIf

		If lCpoAgr
			J203HAgrEm(cEscr, cFatura, aEncMail, .T.) // Agrupa os e-mails no campo NXA_EMLAGR (E-mail principal, cópia e encaminhamentos)
		EndIf

		If !Empty(aEncMail)
			JurFreeArr(aEncMail)
		EndIf

		RestArea(aArea)
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J203HAgrEm
Função para gravar e-mails agrupados no campo NXA_EMLAGR. Considera os 
campos A1_EMAIL ou NUH_CEMAIL e NVN onde NVN_ENVENC = '1'
para agrupamento.

@Param cEscr   , Código do escritório
@Param cFatura , Código da Fatura
@Param aEncMail, Array simples com e-mails para envio da Fatura
@Param lSeek   , Se verdadeiro faz o posicionamento da fatura

@author Jonatas Martins
@since  18/05/2022
@obs    Antes de chamar essa rotina necessário sempre validar a existência do campo NXA_EMLAGR
/*/
//-------------------------------------------------------------------
Function J203HAgrEm(cEscr, cFatura, aEncMail, lSeek)
Local aAreaNXA   := GetArea("NXA")
Local cEmailCC   := ""
Local cAllMails  := ""
Local aMailFat   := {}
Local aGrvMail   := {}
Local nTotMail   := 0
Local nMail      := 0
Local lCpoCEmail := NXA->(ColumnPos("NXA_CEMAIL")) > 0 // @12.1.2310
Local lCCMailCpo := NUH->(ColumnPos('NUH_CEMAIL')) > 0 // Proteção

Default cEscr    := ""
Default cFatura  := ""
Default aEncMail := {}
Default lSeek    := .T. // Informa se deve posicionar na fatura

	IIF(lSeek, NXA->(DbSetOrder(1)), Nil) // NXA_CESCR + NXA_COD
	If !lSeek .Or. NXA->(DbSeek(xFilial("NXA") + cEscr + cFatura))
		// Adiciona encaminhamentos
		If !Empty(aEncMail)
			aEval(aEncMail, {|cEmail| IIF(aScan(aGrvMail, AllTrim(cEmail)) == 0, Aadd(aGrvMail, AllTrim(cEmail)), Nil)})
		EndIf
		
		// Obtem e-mail do campo NXA_EMAIL
		If !Empty(AllTrim(NXA->NXA_EMAIL))
			aMailFat := StrTokArr2(NXA->NXA_EMAIL, ";")
			aEval(aMailFat, {|cEmail| IIF(aScan(aGrvMail, AllTrim(cEmail)) == 0, Aadd(aGrvMail, AllTrim(cEmail)), Nil)})
		EndIf

		// Obtem e-mail do campo NXA_CEMAIL
		If lCpoCEmail .And. !Empty(AllTrim(NXA->NXA_CEMAIL))
			aMailFat := StrTokArr2(NXA->NXA_CEMAIL, ";")
			aEval(aMailFat, {|cEmail| IIF(aScan(aGrvMail, AllTrim(cEmail)) == 0, Aadd(aGrvMail, AllTrim(cEmail)), Nil)})
		ElseIf lCCMailCpo // NUH_CEMAIL
			cEmailCC := AllTrim(JurGetDados("NUH", 1, xFilial("NUH") + NXA->NXA_CLIPG + NXA->NXA_LOJPG, "NUH_CEMAIL"))
			If !Empty(cEmailCC)
				aMailFat := StrTokArr2(cEmailCC, ";")
				aEval(aMailFat, {|cEmail| IIF(aScan(aGrvMail, AllTrim(cEmail)) == 0, Aadd(aGrvMail, AllTrim(cEmail)), Nil)})
			EndIf
		EndIf

		aSort(aGrvMail)
	
		nTotMail  := Len(aGrvMail)
		For nMail := 1 To nTotMail
			If !Empty(aGrvMail[nMail])
				cAllMails += aGrvMail[nMail] + IIF(nMail < nTotMail, ";", "")
			EndIf
		Next nMail

		If !Empty(cAllMails)
			RecLock("NXA", .F.)
			NXA->NXA_EMLAGR := cAllMails
			NXA->(MsUnLock())
		EndIf
	EndIf

	RestArea(aAreaNXA)
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JA203HPre(cCPREFT, cTpExec)
Altera a situação da pré-fatura conforme o tipo de emissão da fatura

@Params		cCPREFT		Código da pré-fatura que terá a situação alterada
cTpExec		Tipo de emissão ("5" - Emissão de pré (substituída) / "3" - Emissão de minuta (minuta emitida)

@Return		aRet		[1] - Sucesso? .T. ou .F. /  [2] - Rotina que originou o erro

@author David Fernandes
@since 19/08/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA203HPre(cCPREFT, cTpExec)
Local aRet     := {.T., "JA203HPre"}
Local aArea    := GetArea()
Local cSituac  := "8"

If Empty(cCPREFT)
	aRet := {.F., "JA203HPre - Empty cPreft"}
EndIf

// TpExec:
// 3 - Minuta Pré
// 4 - Minuta Fatura
// 5 - Emissão de Fatura
// 6 - Reemitir Fatura
// 7 - Minuta Sócio

Do Case
	Case cTpExec == "5"
		cSituac := "G"  // Fatura Emitida
	Case cTpExec $ "3"  //Minuta de Pré
		cSituac := "6" // Minuta emitida
	Case cTpExec $ "3"  //Minuta de Fatura (visualizar)
		cSituac := "4" // Definitiva
	Case cTpExec $ "MS"  //Minuta de Fatura (visualizar)
		cSituac := "A" // Minuta Sócio Emitida
	Otherwise
		aRet := {.F., "JA203HPre - Unknown cTpExec"}
EndCase

If aRet[1] .And. cSituac <> "4"

	NX0->( dbSetOrder(1) ) //NX0_FILIAL+NX0_COD
	If NX0->( DbSeek( xFilial("NX0") + cCPREFT ) )
		If RecLock("NX0",.F.)
			NX0->NX0_SITUAC := cSituac
			NX0->NX0_DTALT  := Date()
			If cSituac == "G"
				NX0->NX0_USRCAN := JurUsuario(__CUSERID)
			Else
				NX0->NX0_USRALT := JurUsuario(__CUSERID)
			EndIf
			NX0->(MsUnlock())
			NX0->(DbCommit())
			
			If cSituac $ "6|G|" 
				J170GRAVA("JURA202E", xFilial("NX0") + cCPREFT, "4")
			EndIf 
			
		Else
			aRet := {.F., "JA203HPre - Reclock NX0"}
		EndIf
	Else
		aRet := {.F., "JA203HPre - DdSeek NX0"}
	EndIf

EndIf

RestArea(aArea)

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} JA203HCpy(cAlias, cFaturaOld, cEscrOld, cFaturaNew, cEscrNew)
Copia os Relacionamentos da fatura anterior para o outro pagador

@Params		cAlias		Alias da tabela a copiar
cFaturaOld	Código da fatura gerada para o pagador anterior
cEscrOld	Código do escritório gerado para o pagador anterior
cFaturaNew	Código da Fatura atual
cEscrNew	Código do escritório atual

@Return		aRet		[1] Sucesso? .T. / .F.
[2] Rotina que origionou o erro.

@author Daniel Magalhaes
@since 15/08/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA203HCpy(cAlias, cFaturaOld, cEscrOld, cFaturaNew, cEscrNew, cCodUser)
Local aAlsStruct := {}
Local aRet       := {.F., "JA203HCpy"}
Local aArea      := GetArea()
Local aCampos    := {}
Local aValores   := {}
Local nI         := 0
Local nOrdem     := 0
Local cChave     := ""
Local cSeek      := ""
Local nCpo       := 0
Local nJ         := 0

Do Case
	Case cAlias == "NXB"
		nOrdem  := 2
		cChave  := "NXB_FILIAL+NXB_CESCR+NXB_CFATUR"
		cSeek   := xFilial(cAlias) + cEscrOld + cFaturaOld
		cCpoCod := ""

	Case cAlias == "NXC"
		nOrdem  := 1
		cChave  := "NXC_FILIAL+NXC_CESCR+NXC_CFATUR"
		cSeek   := xFilial(cAlias) + cEscrOld + cFaturaOld
		cCpoCod := ""

	Case cAlias == "NXD"
		nOrdem  := 1
		cChave  := "NXD_FILIAL+NXD_CFATUR+NXD_CESCR"
		cSeek   := xFilial(cAlias) + cFaturaOld + cEscrOld
		cCpoCod := ""

	Case cAlias == "NXE"
		nOrdem  := 1
		cChave  := "NXE_FILIAL+NXE_CFATUR+NXE_CESCR"
		cSeek   := xFilial(cAlias) + cFaturaOld + cEscrOld
		cCpoCod := ""

	Case cAlias == "NXF"
		nOrdem  := 2
		cChave  := "NXF_FILIAL+NXF_CFATUR+NXF_CESCR"
		cSeek   := xFilial(cAlias) + cFaturaOld + cEscrOld
		cCpoCod := "NXF_COD"
EndCase

/************************************************
COPIA OS RELACIONAMENTOS DA FATURA ANTERIOR
************************************************/
aAlsStruct := (cAlias)->(DbStruct()) // Não considera campos virtuais

For nCpo := 1 To Len(aAlsStruct)
	Aadd(aCampos, aAlsStruct[nCpo][1])
Next nCpo

dbSelectArea(cAlias)
(cAlias)->( dbSetOrder(nOrdem) )
(cAlias)->( dbSeek( cSeek ) )

While ((cAlias)->&(cChave) == cSeek)
	nJ :=  nJ + 1
	aAdd( aValores, {} )
	For nI := 1 to LEN(aCampos)
		aAdd( aValores[nJ], {aCampos[ni], (cAlias)->&(aCampos[ni])} )
	Next nI
	(cAlias)->( dbSkip() )
EndDo

For nJ := 1 To Len(aValores)

	RecLock(cAlias, .T.)
	For nI := 1 To Len(aValores[1])
		(cAlias)->&( aValores[nJ][ni][1] ) := aValores[nJ][ni][2]
	Next nI

	(cAlias)->&(cAlias + "_CESCR"  ) := cEscrNew
	(cAlias)->&(cAlias + "_CFATUR" ) := cFaturaNew

	If !Empty(cCpoCod)
		(cAlias)->&(cCpoCod) := JurGetNum(cAlias, cCpoCod)
	EndIf

	(cAlias)->(MsUnlock())
	(cAlias)->(DbCommit())

	(cAlias)->( dbSkip() )

Next nJ

RestArea(aArea)

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} JA203HCpyL()
Copia os lançamentos faturados da fatura anterior para o outro pagador

@Params		cFaturaOld	Código da fatura gerada para o pagador anterior
cEscrOld	Código do escritório gerado para o pagador anterior
cFaturaNew	Código da Fatura atual
cEscrNew	Código do escritório atual

@Return		aRet		[1] Sucesso? .T. / .F.
[2] Rotina que origionou o erro.

@author Daniel Magalhaes
@since 15/08/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA203HCpyL(cFaturaOld, cEscrOld, cFaturaNew, cEscrNew, oParams)
Local aRet      := {.F., "JA203HCpyL"}
Local aArea     := GetArea()
Local cQuery    := ""
Local cQryRes   := GetNextAlias()
Local cMoedaOld := ""
Local cMoedaNew := ""
Local cContr    := ""
Local aConvLanc := {}
Local nVlrTmp   := 0
Local nVlrTmp2  := 0
Local nVlrTmp3  := 0
Local nCotac1   := 0
Local nCotac2   := 0
Local nCotac3   := 0
Local nCotac4   := 0
Local cContrFX  := ""
Local cSpaceDT  := Space(8)
Local lCasoMae  := NW0->(ColumnPos( "NW0_CCLICM" )) > 0 .And. NVZ->(ColumnPos( "NVZ_CCLICM" )) > 0 .And. NW4->(ColumnPos( "NW4_CCLICM" )) > 0
Local lFSinc    := SuperGetMV("MV_JFSINC", .F., '2') == '1'
Local lCpoCotac := NUE->(ColumnPos('NUE_COTAC')) > 0 //Proteção
Local lDataVinc := NW0->(ColumnPos('NW0_DTVINC')) > 0
Local cPreFat    := Space(TamSx3('NW0_PRECNF')[1])

cMoedaOld := JurGetDados("NXA", 1, xFilial("NXA") + cEscrOld + cFaturaOld, "NXA_CMOEDA")
cMoedaNew := JurGetDados("NXA", 1, xFilial("NXA") + cEscrNew + cFaturaNew, "NXA_CMOEDA")
cContr    := JurGetDados("NXA", 1, xFilial("NXA") + cEscrNew + cFaturaNew, "NXA_CCONTR")

/***********************************
COPIA LANÇAMENTOS DA FATURA ANTERIOR
***********************************/
// "NW0" - Time-Sheet
cQuery := " SELECT NW0.NW0_CTS, NW0.NW0_SITUAC, NW0.NW0_CFATUR, NW0.NW0_CESCR, "
cQuery +=        " NW0.NW0_CANC, NW0.NW0_CODUSR, NW0.NW0_COTAC1, NW0.NW0_COTAC2, "
cQuery +=        " NW0.NW0_CCLIEN, NW0.NW0_CLOJA, NW0.NW0_CCASO, NW0.NW0_CPART1, "
cQuery +=        " NW0.NW0_TEMPOL, NW0.NW0_TEMPOR, NW0.NW0_VALORH, NW0.NW0_CMOEDA, NW0_DATATS "
If lFSinc .And. lCasoMae
	cQuery +=        " ,NW0.NW0_CCLICM, NW0.NW0_CLOJCM, NW0.NW0_CCASCM "
EndIf
cQuery += Iif(lDataVinc, ", NW0.NW0_DTVINC ", ", '" + cSpaceDT + "' NW0_DTVINC ")
cQuery += " FROM " + RetSqlName("NW0") + " NW0 "
cQuery += " WHERE NW0.NW0_FILIAL = '" + xFilial("NWD") +"' "
cQuery += " AND NW0.NW0_CFATUR = '" + cFaturaOld +"' "
cQuery += " AND NW0.NW0_CESCR = '" + cEscrOld +"' "
cQuery += " AND NW0.NW0_CODUSR = '" + oParams:GetCodUser() +"' "
cQuery += " AND NW0.D_E_L_E_T_ = ' '  "

cQuery := ChangeQuery(cQuery, .F.)
DbCommitAll() //Para efetivar a alteração no banco de dados (não impacta no rollback da transação)
dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryRes, .T., .F. )

While !(cQryRes)->(EOF())

	// NW0_FILIAL, NW0_CTS, NW0_SITUAC, NW0_PRECNF, NW0_CFATUR, NW0_CESCR, NW0_CWO
	If Empty(JurGetDados("NW0", 1, xFilial("NW0") + (cQryRes)->NW0_CTS + (cQryRes)->NW0_SITUAC + cPreFat + cFaturaNew + cEscrNew, "NW0_CTS"))

		cMoeda := JurGetDados("NUE", 1, xFilial("NUE") + (cQryRes)->NW0_CTS, "NUE_CMOEDA")

		// Verifica cotação dos Time-Sheets
		aConvLanc := JA201FConv(cMoedaNew, cMoeda, 1000, oParams:GetTpExec(), oParams:GetDEmi(), oParams:GetCFilaImpr(), cContr)
		nVlrTmp   := aConvLanc[1]
		nCotac1   := aConvLanc[2]
		nCotac2   := aConvLanc[3]

		RecLock("NW0", .T.)
		NW0->NW0_FILIAL     := xFilial("NW0")
		NW0->NW0_CTS        := (cQryRes)->NW0_CTS
		NW0->NW0_SITUAC     := (cQryRes)->NW0_SITUAC
		NW0->NW0_CFATUR     := cFaturaNew
		NW0->NW0_CESCR      := cEscrNew
		NW0->NW0_CANC       := (cQryRes)->NW0_CANC
		NW0->NW0_CODUSR     := (cQryRes)->NW0_CODUSR
		NW0->NW0_COTAC1     := nCotac1
		NW0->NW0_COTAC2     := nCotac2
		If lCpoCotac
			NW0->NW0_COTAC  := JurCotac(nCotac1, nCotac2)
		EndIf
		NW0->NW0_CCLIEN     := (cQryRes)->NW0_CCLIEN
		NW0->NW0_CLOJA      := (cQryRes)->NW0_CLOJA
		NW0->NW0_CCASO      := (cQryRes)->NW0_CCASO
		NW0->NW0_CPART1     := (cQryRes)->NW0_CPART1
		NW0->NW0_DATATS     := StoD((cQryRes)->NW0_DATATS)
		NW0->NW0_TEMPOL     := (cQryRes)->NW0_TEMPOL
		NW0->NW0_TEMPOR     := (cQryRes)->NW0_TEMPOR
		NW0->NW0_VALORH     := (cQryRes)->NW0_VALORH
		NW0->NW0_CMOEDA     := (cQryRes)->NW0_CMOEDA
		If lFSinc .And. lCasoMae
			NW0->NW0_CCLICM := (cQryRes)->NW0_CCLICM
			NW0->NW0_CLOJCM := (cQryRes)->NW0_CLOJCM
			NW0->NW0_CCASCM := (cQryRes)->NW0_CCASCM
		EndIf
		If lDataVinc
			NW0->NW0_DTVINC  := StoD((cQryRes)->NW0_DTVINC)
		EndIf
		NW0->(MsUnlock())
		NW0->(DbCommit())

	EndIf

	(cQryRes)->(DbSkip())
EndDo
(cQryRes)->(dbCloseArea())

// "NW4" - Tabelado
cQuery := " SELECT NW4.NW4_CLTAB, NW4.NW4_SITUAC, NW4.NW4_CFATUR, NW4.NW4_CESCR, "
cQuery +=        " NW4.NW4_CANC, NW4.NW4_CODUSR, NW4.NW4_COTAC1, NW4.NW4_COTAC2, "
cQuery +=        " NW4.NW4_CANC, NW4.NW4_CODUSR, NW4.NW4_COTAC1, NW4.NW4_COTAC2, "
cQuery +=        " NW4.NW4_CCLIEN, NW4.NW4_CLOJA, NW4.NW4_CCASO, NW4.NW4_CPART1, "
cQuery +=        " NW4.NW4_DTCONC, NW4.NW4_VALORH, NW4.NW4_CMOEDH "
If lFSinc .And. lCasoMae
	cQuery += " ,NW4.NW4_CCLICM, NW4.NW4_CLOJCM, NW4.NW4_CCASCM "
EndIf
cQuery += " FROM " + RetSqlName("NW4") + " NW4 "
cQuery += " WHERE NW4.NW4_FILIAL = '" + xFilial("NW4") + "' "
cQuery += " AND NW4.NW4_CFATUR = '" + cFaturaOld + "' "
cQuery += " AND NW4.NW4_CESCR = '" + cEscrOld + "' "
cQuery += " AND NW4.NW4_CODUSR = '" + oParams:GetCodUser() + "' "
cQuery += " AND NW4.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery, .F.)
DbCommitAll() //Para efetivar a alteração no banco de dados (não impacta no rollback da transação)
dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryRes, .T., .F. )

While !(cQryRes)->(EOF())

	cMoeda := JurGetDados("NV4", 1, xFilial("NV4") + (cQryRes)->NW4_CLTAB, "NV4_CMOEH")

	// Verifica cotação dos Tabelados
	aConvLanc := JA201FConv(cMoedaNew, cMoeda, 1000, oParams:GetTpExec(), oParams:GetDEmi(), oParams:GetCFilaImpr(), cContr)
	nVlrTmp   := aConvLanc[1]
	nCotac1   := aConvLanc[2]
	nCotac2   := aConvLanc[3]

	RecLock("NW4", .T.)
	NW4->NW4_FILIAL      := xFilial("NW4")
	NW4->NW4_CLTAB       := (cQryRes)->NW4_CLTAB
	NW4->NW4_SITUAC      := (cQryRes)->NW4_SITUAC
	NW4->NW4_CFATUR      := cFaturaNew
	NW4->NW4_CESCR       := cEscrNew
	NW4->NW4_CANC        := (cQryRes)->NW4_CANC
	NW4->NW4_CODUSR      := (cQryRes)->NW4_CODUSR
	NW4->NW4_COTAC1      := nCotac1
	NW4->NW4_COTAC2      := nCotac2
	If lCpoCotac
		NW4->NW4_COTAC   := JurCotac(nCotac1, nCotac2)
	EndIf
	NW4->NW4_CCLIEN      := (cQryRes)->NW4_CCLIEN
	NW4->NW4_CLOJA       := (cQryRes)->NW4_CLOJA
	NW4->NW4_CCASO       := (cQryRes)->NW4_CCASO
	NW4->NW4_CPART1      := (cQryRes)->NW4_CPART1
	NW4->NW4_DTCONC      := sToD((cQryRes)->NW4_DTCONC)
	NW4->NW4_VALORH      := (cQryRes)->NW4_VALORH
	NW4->NW4_CMOEDH      := (cQryRes)->NW4_CMOEDH
	If lFSinc .And. lCasoMae
		NW4->NW4_CCLICM  := (cQryRes)->NW4_CCLICM
		NW4->NW4_CLOJCM  := (cQryRes)->NW4_CLOJCM
		NW4->NW4_CCASCM  := (cQryRes)->NW4_CCASCM
	EndIf
	NW4->(MsUnlock())
	NW4->(DbCommit())

	(cQryRes)->(DbSkip())
EndDo
(cQryRes)->(dbCloseArea())

// "NVZ" - Despesa
cQuery := " SELECT NVZ.NVZ_CDESP, NVZ.NVZ_SITUAC, NVZ.NVZ_CFATUR, NVZ.NVZ_CESCR, " + CRLF
cQuery +=        " NVZ.NVZ_CANC, NVZ.NVZ_CODUSR, NVZ.NVZ_COTAC1, NVZ.NVZ_COTAC2, " + CRLF
cQuery +=        " NVZ.NVZ_CCLIEN, NVZ.NVZ_CLOJA, NVZ.NVZ_CCASO, NVZ.NVZ_DTDESP, " + CRLF
If lFSinc .And. lCasoMae
	cQuery +=    " NVZ.NVZ_CCLICM, NVZ.NVZ_CLOJCM, NVZ.NVZ_CCASCM, " + CRLF
EndIf
cQuery +=        " NVZ.NVZ_CTPDSP, NVZ.NVZ_CMOEDA, NVZ.NVZ_VALORD " + CRLF
cQuery += " FROM " + RetSqlName("NVZ") + " NVZ " + CRLF
cQuery += " WHERE NVZ.NVZ_FILIAL = '" + xFilial("NVZ") +"' " + CRLF
cQuery += " AND NVZ.NVZ_CFATUR = '" + cFaturaOld +"' " + CRLF
cQuery += " AND NVZ.NVZ_CESCR = '" + cEscrOld +"' " + CRLF
cQuery += " AND NVZ.NVZ_CODUSR = '" + oParams:GetCodUser() +"' " + CRLF
cQuery += " AND NVZ.D_E_L_E_T_ = ' '  " + CRLF

cQuery := ChangeQuery(cQuery, .F.)
DbCommitAll() //Para efetivar a alteração no banco de dados (não impacta no rollback da transação)
dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryRes, .T., .F. )

While !(cQryRes)->(EOF())
	// NVZ_SITUAC -> 1=Conferencia;2=Faturado;3=WO;4=Temporario

	cMoeda := JurGetDados("NVY", 1, xFilial("NVY") + (cQryRes)->NVZ_CDESP, "NVY_CMOEDA")

	// Verifica cotação das Despesas
	aConvLanc := JA201FConv(cMoedaNew, cMoeda, 1000, oParams:GetTpExec(), oParams:GetDEmi(), oParams:GetCFilaImpr(), cContr )
	nVlrTmp   := aConvLanc[1]
	nCotac1   := aConvLanc[2]
	nCotac2   := aConvLanc[3]

	RecLock("NVZ", .T.)
	NVZ->NVZ_FILIAL     := xFilial("NVZ")
	NVZ->NVZ_CDESP      := (cQryRes)->NVZ_CDESP
	NVZ->NVZ_SITUAC     := (cQryRes)->NVZ_SITUAC
	NVZ->NVZ_CFATUR     := cFaturaNew
	NVZ->NVZ_CESCR      := cEscrNew
	NVZ->NVZ_CANC       := (cQryRes)->NVZ_CANC
	NVZ->NVZ_CODUSR     := (cQryRes)->NVZ_CODUSR
	NVZ->NVZ_COTAC1     := nCotac1
	NVZ->NVZ_COTAC2     := nCotac2
	If lCpoCotac
		NVZ->NVZ_COTAC  := JurCotac(nCotac1, nCotac2)
	EndIf
	NVZ->NVZ_CCLIEN     := (cQryRes)->NVZ_CCLIEN
	NVZ->NVZ_CLOJA      := (cQryRes)->NVZ_CLOJA
	NVZ->NVZ_CCASO      := (cQryRes)->NVZ_CCASO
	NVZ->NVZ_DTDESP     := sToD((cQryRes)->NVZ_DTDESP)
	NVZ->NVZ_CTPDSP     := (cQryRes)->NVZ_CTPDSP
	NVZ->NVZ_CMOEDA     := (cQryRes)->NVZ_CMOEDA
	NVZ->NVZ_VALORD     := (cQryRes)->NVZ_VALORD
	If lFSinc .And. lCasoMae
		NVZ->NVZ_CCLICM := (cQryRes)->NVZ_CCLICM
		NVZ->NVZ_CLOJCM := (cQryRes)->NVZ_CLOJCM
		NVZ->NVZ_CCASCM := (cQryRes)->NVZ_CCASCM
	EndIf
	NVZ->(MsUnlock())
	NVZ->(DbCommit())

	(cQryRes)->(DbSkip())
EndDo
(cQryRes)->(dbCloseArea())

// "NT1" - Fixo
cQuery := " SELECT NWE.NWE_CFIXO, NWE.NWE_SITUAC, NWE.NWE_CFATUR, NWE.NWE_CESCR, " + CRLF
cQuery +=        " NWE.NWE_CANC, NWE.NWE_CODUSR, NWE.NWE_COTAC1, NWE.NWE_COTAC2  " + CRLF
cQuery +=        ",NWE.NWE_VALORB " + CRLF
cQuery +=        ",NWE.NWE_VALORA " + CRLF
cQuery +=        ",NWE.NWE_DATAIN " + CRLF
cQuery +=        ",NWE.NWE_DATAFI " + CRLF
cQuery += " FROM " + RetSqlName("NWE") + " NWE " + CRLF
cQuery += " WHERE NWE.NWE_FILIAL = '" + xFilial("NWE") +"' " + CRLF
cQuery +=   " AND NWE.NWE_CFATUR = '" + cFaturaOld +"' " + CRLF
cQuery +=   " AND NWE.NWE_CESCR = '" + cEscrOld +"' " + CRLF
cQuery +=   " AND NWE.NWE_CODUSR = '" + oParams:GetCodUser() +"' " + CRLF
cQuery +=   " AND NWE.D_E_L_E_T_ = ' ' " + CRLF

cQuery := ChangeQuery(cQuery, .F.)
DbCommitAll() //Para efetivar a alteração no banco de dados (não impacta no rollback da transação)
dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryRes, .T., .F. )

TcSetField(cQryRes, 'NWE_VALORB', 'N', TamSX3('NWE_VALORB')[1], TamSX3('NWE_VALORB')[2])
TcSetField(cQryRes, 'NWE_VALORA', 'N', TamSX3('NWE_VALORA')[1], TamSX3('NWE_VALORA')[2])
TcSetField(cQryRes, 'NWE_DATAIN', 'D', TamSX3('NWE_DATAIN')[1], TamSX3('NWE_DATAIN')[2])
TcSetField(cQryRes, 'NWE_DATAFI', 'D', TamSX3('NWE_DATAFI')[1], TamSX3('NWE_DATAFI')[2])

While !(cQryRes)->(EOF())
	// NWE_SITUAC -> 1=Conferencia;2=Faturado;3=WO;4=Temporario

	cMoeda   := JurGetDados("NT1", 1, xFilial("NT1") + (cQryRes)->NWE_CFIXO, "NT1_CMOEDA")
	cContrFX := JurGetDados("NT1", 1, xFilial("NT1") + (cQryRes)->NWE_CFIXO, "NT1_CCONTR")

	If Empty(cMoeda)
		cMoeda   := JurGetDados("NT0", 1, xFilial("NT0") + cContrFX, "NT0_CMOEF")
	EndIf

	// Verifica cotação das Despesas
	aConvLanc := JA201FConv(cMoedaNew, cMoeda, 1000, oParams:GetTpExec(), oParams:GetDEmi(), oParams:GetCFilaImpr(), cContrFX)
	nVlrTmp   := aConvLanc[1]
	nCotac1   := aConvLanc[2]
	nCotac2   := aConvLanc[3]

	RecLock("NWE", .T.)
	NWE->NWE_FILIAL    := xFilial("NWE")
	NWE->NWE_CFIXO     := (cQryRes)->NWE_CFIXO
	NWE->NWE_SITUAC    := (cQryRes)->NWE_SITUAC
	NWE->NWE_CFATUR    := cFaturaNew
	NWE->NWE_CESCR     := cEscrNew
	NWE->NWE_CANC      := (cQryRes)->NWE_CANC
	NWE->NWE_CODUSR    := (cQryRes)->NWE_CODUSR
	NWE->NWE_CMOEDA    := cMoeda
	NWE->NWE_COTAC1    := nCotac1
	NWE->NWE_COTAC2    := nCotac2
	If lCpoCotac
		NWE->NWE_COTAC := JurCotac(nCotac1, nCotac2)
	EndIf
	NWE->NWE_VALORB    := (cQryRes)->NWE_VALORB
	NWE->NWE_VALORA    := (cQryRes)->NWE_VALORA
	NWE->NWE_DATAIN    := (cQryRes)->NWE_DATAIN
	NWE->NWE_DATAFI    := (cQryRes)->NWE_DATAFI

	NWE->(MsUnlock())
	NWE->(DbCommit())

	//Grava na fila de sincronização
	J170GRAVA("NT0", xFilial("NT0") + cContrFX, "4")

	(cQryRes)->(DbSkip())
EndDo
(cQryRes)->(dbCloseArea())

// "NWD" - Fatura Adicional
cQuery := " SELECT NWD.NWD_CFTADC, NWD.NWD_SITUAC, NWD.NWD_CFATUR, NWD.NWD_CESCR, " + CRLF
cQuery += " NWD.NWD_CANC, NWD.NWD_CODUSR, NVV.NVV_CMOE1, NVV.NVV_VALORH, NVV.NVV_CMOE2, NVV.NVV_VALORD, NVV.NVV_CMOE4, NVV.NVV_VALORT " + CRLF
cQuery += " FROM " + RetSqlName("NWD") + " NWD, " + CRLF
cQuery += " " + RetSqlName("NVV") + " NVV  " + CRLF
cQuery += " WHERE	NWD.NWD_FILIAL = '" + xFilial("NWD") +"' " + CRLF
cQuery +=   " AND NVV.NVV_FILIAL = '" + xFilial("NVV") +"' " + CRLF
cQuery +=   " AND NWD.NWD_CFATUR = '" + cFaturaOld +"' " + CRLF
cQuery +=   " AND NWD.NWD_CESCR	= '" + cEscrOld +"' " + CRLF
cQuery +=   " AND NVV.NVV_COD = NWD.NWD_CFTADC " + CRLF
cQuery +=   " AND NWD.NWD_CODUSR = '" + oParams:GetCodUser() +"' " + CRLF
cQuery +=   " AND NWD.D_E_L_E_T_ = ' '  " + CRLF
cQuery +=   " AND NVV.D_E_L_E_T_ = ' '  " + CRLF

cQuery := ChangeQuery(cQuery, .F.)
DbCommitAll() //Para efetivar a alteração no banco de dados (não impacta no rollback da transação)
dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryRes, .T., .F. )

While !(cQryRes)->(EOF())

	// Verifica cotação dos honorarios
	aConvLanc := JA201FConv(cMoedaNew, (cQryRes)->NVV_CMOE1, (cQryRes)->NVV_VALORH, oParams:GetTpExec(), oParams:GetDEmi(), oParams:GetCFilaImpr(), cContr )
	nVlrTmp   := aConvLanc[1]
	nCotac1   := aConvLanc[2]
	nCotac2   := aConvLanc[3]

	// Verifica cotação das Despesas
	aConvLanc := JA201FConv(cMoedaNew, (cQryRes)->NVV_CMOE4, (cQryRes)->NVV_VALORT, oParams:GetTpExec(), oParams:GetDEmi(), oParams:GetCFilaImpr(), cContr )
	nVlrTmp3  := aConvLanc[1]
	nCotac4   := aConvLanc[3]

	// Verifica cotação das Despesas
	aConvLanc := JA201FConv(cMoedaNew, (cQryRes)->NVV_CMOE1, (cQryRes)->NVV_VALORD, oParams:GetTpExec(), oParams:GetDEmi(), oParams:GetCFilaImpr(), cContr )
	nVlrTmp2  := aConvLanc[1]
	nCotac3   := aConvLanc[3]

	RecLock("NWD", .T.)
	NWD->NWD_FILIAL  := xFilial("NWD")
	NWD->NWD_CFTADC  := (cQryRes)->NWD_CFTADC
	NWD->NWD_SITUAC  := (cQryRes)->NWD_SITUAC
	NWD->NWD_CFATUR  := cFaturaNew
	NWD->NWD_CESCR   := cEscrNew
	NWD->NWD_CANC    := (cQryRes)->NWD_CANC
	NWD->NWD_CODUSR  := (cQryRes)->NWD_CODUSR
	NWD->NWD_COTAC1  := nCotac1
	NWD->NWD_COTAC2  := nCotac2
	NWD->NWD_COTAC3  := nCotac3
	NWD->NWD_COTAC4  := nCotac4
	NWD->NWD_VALORH  := nVlrTmp
	NWD->NWD_VALORD  := nVlrTmp2
	NWD->NWD_VALORT  := nVlrTmp3
	NWD->(MsUnlock())
	NWD->(DbCommit())

	(cQryRes)->(DbSkip())
EndDo
(cQryRes)->(dbCloseArea())

RestArea(aArea)

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} JA203HAjus( cCPREFT , cMarkFat, cUser, cFatura, cEscr, cTipoEmi, cMarkEsc )
Ajusta os relacionamentos da Fatura com a Numeração gerada

@Params
cCPREFT		Código da pré-fatura emitida (altera a situação)
cMarkFat	Marca temporaria para filtro referente ao número da Fatura
cUser		Valor total de Honorarios da Fatura
cFatura		Valor total de Despesas da Fatura
cEscr
cTipoEmi
cMarkEsc	Marca temporaria para filtro referente ao escritório

@Return		Nil

@author Daniel Magalhaes
@since 15/08/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA203HAjus( cCPREFT , cMarkFat, cUser, cFatura, cEscr, cTipoEmi, cMarkEsc )
Local aRet     := {.T., "JA203HAjus"}
Local aArea    := GetArea()
Local cQuery   := ""
Local aSqlRet  := {}
Local nI       := 0
Local lAltHr   := NUE->(ColumnPos('NUE_ALTHR')) > 0

/************************************************
AJUSTA A NUMERAÇÃO DA FATURA NOS RELACIONAMENTOS
************************************************/
cQuery := " SELECT R_E_C_N_O_ RECNO	" + CRLF
cQuery += " FROM " + RetSqlName("NXB") + CRLF
cQuery += " WHERE NXB_FILIAL = '" + xFilial("NXB") +"' "+CRLF
cQuery +=  " AND NXB_CFATUR = '" + cMarkFat +"' "+CRLF
cQuery +=  " AND NXB_CESCR = '" + cMarkEsc +"' "+CRLF
cQuery +=  " AND D_E_L_E_T_ = ' ' " + CRLF

aSqlRet := JurSQL(cQuery, {"RECNO"})

For nI := 1 To Len(aSqlRet)
	NXB->(DbGoto(aSqlRet[nI][1]))
	If RecLock("NXB", .F.)
		NXB->NXB_CFATUR := cFatura
		NXB->NXB_CESCR  := cEscr
		NXB->(MsUnlock())
		NXB->(DbCommit())
	Else
		aRet := {.F., "JA203HAjus - NXB"}
		Exit
	EndIf
Next nI

If aRet[1]
	cQuery := " SELECT R_E_C_N_O_ RECNO " + CRLF
	cQuery += " FROM " + RetSqlName("NXC") + CRLF
	cQuery += " WHERE NXC_FILIAL = '" + xFilial("NXC") +"' "+CRLF
	cQuery +=  " AND NXC_CFATUR = '" + cMarkFat +"' "+CRLF
	cQuery +=  " AND NXC_CESCR = '" + cMarkEsc +"' "+CRLF
	cQuery +=  " AND D_E_L_E_T_ = ' ' " + CRLF

	aSqlRet := JurSQL(cQuery, {"RECNO"})

	For nI := 1  to Len(aSqlRet)
		NXC->(DbGoto(aSqlRet[nI][1]))
		If RecLock("NXC",.F.)
			NXC->NXC_CFATUR := cFatura
			NXC->NXC_CESCR  := cEscr
			NXC->(MsUnlock())
			NXC->(DbCommit())
		Else
			aRet := {.F., "JA203HAjus - NXC"}
			Exit
		EndIf
	Next nI
EndIf

If aRet[1]
	cQuery := " SELECT R_E_C_N_O_ RECNO " + CRLF
	cQuery += " FROM " + RetSqlName("NXD") + CRLF
	cQuery += " WHERE NXD_FILIAL = '" + xFilial("NXD") +"' "+CRLF
	cQuery +=   " AND NXD_CFATUR = '" + cMarkFat +"' "+CRLF
	cQuery +=   " AND NXD_CESCR = '" + cMarkEsc +"' "+CRLF
	cQuery +=   " AND D_E_L_E_T_ = ' ' " + CRLF

	aSqlRet := JurSQL(cQuery, {"RECNO"})

	For nI := 1 To Len(aSqlRet)
		NXD->(DbGoto(aSqlRet[nI][1]))
		If RecLock("NXD",.F.)
			NXD->NXD_CFATUR := cFatura
			NXD->NXD_CESCR  := cEscr
			NXD->(MsUnlock())
			NXD->(DbCommit())
		Else
			aRet := {.F., "JA203HAjus - NXD"}
			Exit
		EndIf
	Next nI
EndIf

If aRet[1]
	cQuery := " SELECT R_E_C_N_O_ RECNO " + CRLF
	cQuery += " FROM " + RetSqlName("NXE") + CRLF
	cQuery += " WHERE NXE_FILIAL = '" + xFilial("NXE") +"' "+CRLF
	cQuery +=   " AND NXE_CFATUR = '" + cMarkFat +"' "+CRLF
	cQuery +=   " AND NXE_CESCR = '" + cMarkEsc +"' "+CRLF
	cQuery +=   " AND D_E_L_E_T_ = ' ' " + CRLF

	aSqlRet := JurSQL(cQuery, {"RECNO"})

	For nI := 1  to Len(aSqlRet)
		NXE->(DbGoto(aSqlRet[nI][1]))
		If RecLock("NXE",.F.)
			NXE->NXE_CFATUR := cFatura
			NXE->NXE_CESCR  := cEscr
			NXE->(MsUnlock())
			NXE->(DbCommit())
		Else
			aRet := {.F., "JA203HAjus - NXE"}
			Exit
		EndIf
	Next nI
EndIf

/***********************************
AJUSTA A SITUAÇÃO DOS LANÇAMENTOS
***********************************/

// TIME-SHEET
If aRet[1]
	cQuery := " SELECT R_E_C_N_O_ RECNO "
	cQuery += " FROM " + RetSqlName("NW0")
	cQuery += " WHERE NW0_FILIAL = '" + xFilial("NW0") +"' "
	cQuery += " AND NW0_CFATUR = '" + cMarkFat +"' "
	cQuery += " AND NW0_CESCR = '" + cMarkEsc +"' "
	cQuery += " AND NW0_SITUAC IN ('1','2','4')"
	cQuery += " AND D_E_L_E_T_ = ' ' "

	aSqlRet := JurSQL(cQuery, {"RECNO"})

	For nI := 1 To Len(aSqlRet)
		NW0->(DbGoto(aSqlRet[nI][1]))
		If RecLock("NW0",.F.)
			NW0->NW0_CFATUR := cFatura
			NW0->NW0_CESCR  := cEscr
			NW0->NW0_PRECNF := " "
			NW0->NW0_SITUAC := "2"
			If cTipoEmi == 'MF'
				NW0->NW0_CANC := '1'
			EndIf
			NW0->(MsUnlock())
			NW0->(DbCommit())
		Else
			aRet := {.F., "JA203HAjus - NW0"}
			Exit
		EndIf
	Next nI
EndIf

If aRet[1] .AND. cTipoEmi == "FT"
	cQuery := " SELECT R_E_C_N_O_ RECNO "
	cQuery += " FROM " +  RetSqlName("NUE")
	cQuery += " WHERE NUE_FILIAL = '" + xFilial("NUE") + "' "
	cQuery +=   " AND NUE_COD IN ( SELECT NW0_CTS "
	cQuery +=                      " FROM " + RetSqlName("NW0") + " NW0 "
	cQuery +=                     " WHERE NW0.NW0_FILIAL = '" + xFilial("NW0") + "' "
	cQuery +=                      " AND NW0.NW0_CFATUR = '" + cFatura + "' "
	cQuery +=                      " AND NW0.NW0_CESCR = '" + cEscr + "' "
	cQuery +=                      " AND NW0.NW0_CODUSR = '" + cUser + "' "
	cQuery +=                      " AND NW0.D_E_L_E_T_ = ' ' "
	cQuery +=                   " ) "
	cQuery += " AND D_E_L_E_T_ = ' ' "

	aSqlRet := JurSQL(cQuery, {"RECNO"})

	For nI := 1 To Len(aSqlRet)
		NUE->(DbGoto(aSqlRet[nI][1]))
		If RecLock("NUE", .F.)
			NUE->NUE_CPREFT := ""
			NUE->NUE_SITUAC := "2"
			NUE->NUE_CUSERA := JurUsuario(__CUSERID)
			NUE->NUE_ALTDT  := Date()
			If lAltHr
				NUE->NUE_ALTHR  := Time()
			EndIf
			NUE->(MsUnlock())
			NUE->(DbCommit())
		Else
			aRet := {.F., "JA203HAjus - NUE"}
			Exit
		EndIf
	Next nI
EndIf

If aRet[1] .AND. !Empty(cCPREFT) .AND. cTipoEmi == "FT"
	cQuery := " SELECT R_E_C_N_O_ RECNO "
	cQuery += " FROM " + RetSqlName("NW0")
	cQuery += " WHERE NW0_FILIAL = '" + xFilial("NW0") + "' "
	cQuery +=   " AND NW0_PRECNF = '" + cCPREFT + "' "
	cQuery +=   " AND NW0_SITUAC in ('1', '2', '4') "
	cQuery +=   " AND D_E_L_E_T_ = ' ' "

	aSqlRet := JurSQL(cQuery, {"RECNO"})

	For nI := 1 To Len(aSqlRet)
		NW0->(DbGoto(aSqlRet[nI][1]))
		If RecLock("NW0", .F.)
			NW0->NW0_CANC  := "1"
			NW0->(MsUnlock())
			NW0->(DbCommit())
		Else
			aRet := {.F., "JA203HAjus - NW0 - cPreft"}
			Exit
		EndIf
	Next nI
EndIf

// TABELADO
If aRet[1]
	cQuery := " SELECT R_E_C_N_O_ RECNO " + CRLF
	cQuery += " FROM " + RetSqlName("NW4") + CRLF
	cQuery += " WHERE NW4_FILIAL = '" + xFilial("NW4") +"' "+CRLF
	cQuery +=   " AND NW4_CFATUR  = '" + cMarkFat +"' "+CRLF
	cQuery +=   " AND NW4_CESCR = '" + cMarkEsc +"' "+CRLF
	cQuery +=   " AND NW4_CODUSR = '" + cUser +"' "+CRLF
	cQuery +=   " AND D_E_L_E_T_ = ' ' " + CRLF

	aSqlRet := JurSQL(cQuery, {"RECNO"})

	For nI := 1 To Len(aSqlRet)
		NW4->(DbGoto(aSqlRet[nI][1]))
		If RecLock("NW4", .F.)
			NW4->NW4_CFATUR := cFatura
			NW4->NW4_CESCR  := cEscr
			NW4->NW4_PRECNF := " "
			NW4->NW4_SITUAC := "2"
			If cTipoEmi == 'MF'
				NW4->NW4_CANC := '1'
			EndIf
			NW4->(MsUnlock())
			NW4->(DbCommit())
		Else
			aRet := {.F., "JA203HAjus - NW4"}
			Exit
		EndIf
	Next nI
EndIf

If aRet[1] .AND. cTipoEmi == "FT"
	cQuery := " SELECT R_E_C_N_O_ RECNO "
	cQuery += " FROM " + RetSqlName("NV4")
	cQuery += " WHERE NV4_FILIAL = '" + xFilial("NV4") + "' "
	cQuery += " AND NV4_COD IN ( SELECT NW4_CLTAB "
	cQuery +=                         " FROM " + RetSqlName("NW4") + " NW4 "
	cQuery +=                         " WHERE NW4.NW4_FILIAL = '" + xFilial("NW4") + "' "
	cQuery +=                         " AND NW4.NW4_CFATUR = '" + cFatura + "' "
	cQuery +=                         " AND NW4.NW4_CESCR = '" + cEscr + "' "
	cQuery +=                         " AND NW4.NW4_CODUSR = '" + cUser + "' "
	cQuery +=                         " AND NW4.D_E_L_E_T_ = ' ' "
	cQuery +=                 " ) "
	cQuery += " AND D_E_L_E_T_ = ' ' "

	aSqlRet := JurSQL(cQuery, {"RECNO"})

	For nI := 1 To Len(aSqlRet)
		NV4->(DbGoto(aSqlRet[nI][1]))
		If RecLock("NV4",.F.)
			NV4->NV4_CPREFT := " "
			NV4->NV4_SITUAC := "2"
			NV4->(MsUnlock())
			NV4->(DbCommit())
		Else
			aRet := {.F., "JA203HAjus - NV4"}
			Exit
		EndIf
	Next nI
EndIf

If aRet[1] .AND. !Empty(cCPREFT) .AND. cTipoEmi == "FT"
	cQuery := " SELECT R_E_C_N_O_ RECNO " + CRLF
	cQuery += " FROM " + RetSqlName("NW4") + CRLF
	cQuery += " WHERE	NW4_FILIAL = '" + xFilial("NW4") +"' "+CRLF
	cQuery += " AND NW4_PRECNF = '" + cCPREFT +"' "+CRLF
	cQuery += " AND D_E_L_E_T_ = ' ' " + CRLF

	aSqlRet := JurSQL(cQuery, {"RECNO"})

	For nI := 1 To Len(aSqlRet)
		NW4->(DbGoto(aSqlRet[nI][1]))
		If RecLock("NW4", .F.)
			NW4->NW4_CANC  := "1"
			NW4->(MsUnlock())
			NW4->(DbCommit())
		Else
			aRet := {.F., "JA203HAjus - NW4 - cPreft"}
			Exit
		EndIf
	Next nI
EndIf

// DESPESAS
If aRet[1]
	cQuery := " SELECT R_E_C_N_O_ RECNO " + CRLF
	cQuery += " FROM " + RetSqlName("NVZ") + CRLF
	cQuery += " WHERE NVZ_FILIAL = '" + xFilial("NVZ") +"' "+CRLF
	cQuery +=   " AND NVZ_CFATUR  = '" + cMarkFat +"' "+CRLF
	cQuery +=   " AND NVZ_CESCR = '" + cMarkEsc +"' "+CRLF
	cQuery +=   " AND NVZ_CODUSR = '" + cUser +"' "+CRLF
	cQuery +=   " AND D_E_L_E_T_ = ' ' " + CRLF

	aSqlRet := JurSQL(cQuery, {"RECNO"})

	For nI := 1 To Len(aSqlRet)
		NVZ->(DbGoto(aSqlRet[nI][1]))
		If RecLock("NVZ", .F.)
			NVZ->NVZ_CFATUR := cFatura
			NVZ->NVZ_CESCR  := cEscr
			NVZ->NVZ_PRECNF := " "
			NVZ->NVZ_SITUAC := "2"
			If cTipoEmi == 'MF'
				NVZ->NVZ_CANC := '1'
			EndIf
			NVZ->(MsUnlock())
			NVZ->(DbCommit())
		Else
			aRet := {.F., "JA203HAjus - NVZ"}
			Exit
		EndIf
	Next nI
EndIf

If aRet[1] .AND. cTipoEmi == "FT"
	cQuery := " SELECT R_E_C_N_O_ RECNO "
	cQuery += " FROM " + RetSqlName("NVY")
	cQuery += " WHERE NVY_FILIAL = '" + xFilial("NVY") +"' "
	cQuery +=   " AND NVY_COD IN ( SELECT NVZ_CDESP "
	cQuery +=                         " FROM " + RetSqlName("NVZ") + " NVZ "
	cQuery +=                         " WHERE NVZ.NVZ_FILIAL = '" + xFilial("NVZ") +"' "
	cQuery +=                         " AND NVZ.NVZ_CFATUR = '" + cFatura +"' "
	cQuery +=                         " AND NVZ.NVZ_CESCR = '" + cEscr +"' "
	cQuery +=                         " AND NVZ.NVZ_CODUSR = '" + cUser +"' "
	cQuery +=                    " ) "
	cQuery +=  " AND D_E_L_E_T_ = ' ' "

	aSqlRet := JurSQL(cQuery, {"RECNO"})

	For nI := 1 To Len(aSqlRet)
		NVY->(DbGoto(aSqlRet[nI][1]))
		If RecLock("NVY", .F.)
			NVY->NVY_CPREFT := " "
			NVY->NVY_SITUAC := "2"
			NVY->(MsUnlock())
			NVY->(DbCommit())
		Else
			aRet := {.F., "JA203HAjus - NVY"}
			Exit
		EndIf
	Next nI
EndIf

If aRet[1] .AND. !Empty(cCPREFT) .AND. cTipoEmi == "FT"
	cQuery := " SELECT R_E_C_N_O_ RECNO "
	cQuery += " FROM " + RetSqlName("NVZ")
	cQuery += " WHERE NVZ_FILIAL = '" + xFilial("NVZ") + "' "
	cQuery += " AND NVZ_PRECNF = '" + cCPREFT + "' "
	cQuery += " AND D_E_L_E_T_ = ' ' "

	aSqlRet := JurSQL(cQuery, {"RECNO"})

	For nI := 1 To Len(aSqlRet)
		NVZ->(DbGoto(aSqlRet[nI][1]))
		If RecLock("NVZ", .F.)
			NVZ->NVZ_CANC  := "1"
			NVZ->(MsUnlock())
			NVZ->(DbCommit())
		Else
			aRet := {.F., "JA203HAjus - NVZ - cPreft"}
			Exit
		EndIf
	Next nI
EndIf

// FIXO
If aRet[1]
	cQuery := " SELECT R_E_C_N_O_ RECNO "
	cQuery += " FROM " + RetSqlName("NWE")
	cQuery += " WHERE NWE_FILIAL = '" + xFilial("NWE") + "' "
	cQuery +=   " AND NWE_CFATUR = '" + cMarkFat +"' "
	cQuery +=   " AND NWE_CESCR = '" + cMarkEsc +"' "
	cQuery +=   " AND NWE_CODUSR = '" + cUser +"' "
	cQuery +=   " AND D_E_L_E_T_ = ' ' "

	aSqlRet := JurSQL(cQuery, {"RECNO"})

	For nI := 1 To Len(aSqlRet)
		NWE->(DbGoto(aSqlRet[nI][1]))
		If RecLock("NWE", .F.)
			NWE->NWE_CFATUR := cFatura
			NWE->NWE_CESCR  := cEscr
			NWE->NWE_PRECNF := ""
			NWE->NWE_SITUAC := "2"
			If cTipoEmi == 'MF'
				NWE->NWE_CANC := '1'
			EndIf
			NWE->(MsUnlock())
			NWE->(DbCommit())
			// Grava na fila de sincronização
			If !(cTipoEmi $ "MP|MF|MS") // Se for minuta não adiciona a NT0 na fila
				J170GRAVA("NT0", xFilial("NT0") + JurGetDados("NT1", 1, xFilial("NT1") + NWE->NWE_CFIXO, "NT1_CCONTR"), "4")
			EndIF
		Else
			aRet := {.F., "JA203HAjus - NWE"}
			Exit
		EndIf
	Next nI
EndIf

If aRet[1] .AND. cTipoEmi == "FT"
	cQuery := " SELECT R_E_C_N_O_ RECNO "
	cQuery += " FROM " + RetSqlName("NT1")
	cQuery += " WHERE NT1_FILIAL = '" + xFilial("NT1") +"' "
	cQuery +=   " AND NT1_SEQUEN IN ( SELECT NWE_CFIXO "
	cQuery +=                        " FROM " + RetSqlName("NWE") + " NWE "
	cQuery +=                        " WHERE NWE.NWE_FILIAL = '" + xFilial("NWE") +"' "
	cQuery +=                        " AND NWE.NWE_CFATUR = '" + cFatura +"' "
	cQuery +=                        " AND NWE.NWE_CESCR = '" + cEscr +"' "
	cQuery +=                        " AND NWE.NWE_CODUSR = '" + cUser +"' "
	cQuery +=                        " AND NWE.D_E_L_E_T_ = ' ' "
	cQuery +=                      " ) "
	cQuery +=   " AND D_E_L_E_T_ = ' ' "

	aSqlRet := JurSQL(cQuery, {"RECNO"})

	For nI := 1 To Len(aSqlRet)
		NT1->(DbGoto(aSqlRet[nI][1]))
		If RecLock("NT1", .F.)
			NT1->NT1_CPREFT := " "
			NT1->NT1_SITUAC := "2"
			NT1->(MsUnlock())
			NT1->(DbCommit())
			//Grava na fila de sincronização
			J170GRAVA("NT0", xFilial("NT0") + NT1->NT1_CCONTR, "4")
		Else
			aRet := {.F., "JA203HAjus - NT1"}
			Exit
		EndIf
	Next nI
EndIf

If aRet[1] .AND. !Empty(cCPREFT)  .AND. cTipoEmi == "FT"
	cQuery := " SELECT R_E_C_N_O_ RECNO "
	cQuery += " FROM " + RetSqlName("NWE")
	cQuery += " WHERE NWE_FILIAL = '" + xFilial("NWE") +"' "
	cQuery +=   " AND NWE_PRECNF = '" + cCPREFT +"' "
	cQuery +=   " AND D_E_L_E_T_ = ' ' "

	aSqlRet := JurSQL(cQuery, {"RECNO"})

	For nI := 1 To Len(aSqlRet)
		NWE->(DbGoto(aSqlRet[nI][1]))
		If RecLock("NWE", .F.)
			NWE->NWE_CANC  := "1"
			NWE->(MsUnlock())
			NWE->(DbCommit())
			//Grava na fila de sincronização
			J170GRAVA("NT0", xFilial("NT0") + JurGetDados("NT1", 1, xFilial("NT1") + NWE->NWE_CFIXO, "NT1_CCONTR"), "4")
		Else
			aRet := {.F., "JA203HAjus - NWE - cPreft"}
			Exit
		EndIf
	Next nI
EndIf

// FAT. ADICIONAL
If aRet[1]
	cQuery := " SELECT R_E_C_N_O_ RECNO "
	cQuery += " FROM " + RetSqlName("NWD")
	cQuery += " WHERE NWD_FILIAL = '" + xFilial("NWD") + "' "
	cQuery += " AND NWD_CFATUR = '" + cMarkFat +"' "
	cQuery += " AND NWD_CESCR = '" + cMarkEsc +"' "
	cQuery += " AND NWD_CODUSR = '" + cUser +"' "
	cQuery += " AND D_E_L_E_T_ = ' ' "

	aSqlRet := JurSQL(cQuery, {"RECNO"})

	For nI := 1 To Len(aSqlRet)
		NWD->(DbGoto(aSqlRet[nI][1]))
		If RecLock("NWD",.F.)
			NWD->NWD_CFATUR := cFatura
			NWD->NWD_CESCR  := cEscr
			NWD->NWD_PRECNF := " "
			NWD->NWD_SITUAC := "2"
			If cTipoEmi == 'MF'
				NWD->NWD_CANC := '1'
			EndIf
			NWD->(MsUnlock())
			NWD->(DbCommit())
		Else
			aRet := {.F., "JA203HAjus - NWE"}
			Exit
		EndIf
	Next nI
EndIf

If aRet[1] .AND. cTipoEmi == "FT"
	cQuery := " SELECT R_E_C_N_O_ RECNO "
	cQuery += " FROM " + RetSqlName("NVV")
	cQuery += " WHERE NVV_FILIAL = '" + xFilial("NVV") + "' "
	cQuery += " AND NVV_COD IN ( SELECT NWD_CFTADC "
	cQuery +=                    " FROM " + RetSqlName("NWD") + " NWD "
	cQuery +=                    " WHERE NWD.NWD_FILIAL = '" + xFilial("NWD") + "' "
	cQuery +=                    " AND NWD.NWD_CFATUR = '" + cFatura +"' "
	cQuery +=                    " AND NWD.NWD_CESCR = '" + cEscr +"' "
	cQuery +=                    " AND NWD.NWD_CODUSR = '" + cUser +"' "
	cQuery +=                    " AND NWD.D_E_L_E_T_ = ' ' "
	cQuery +=                 " ) "
	cQuery += " AND D_E_L_E_T_ = ' ' "

	aSqlRet := JurSQL(cQuery, {"RECNO"})

	For nI := 1 To Len(aSqlRet)
		NVV->(DbGoto(aSqlRet[nI][1]))
		If RecLock("NVV", .F.)
			NVV->NVV_CPREFT := " "
			NVV->NVV_SITUAC := "2"
			NVV->(MsUnlock())
			NVV->(DbCommit())
		Else
			aRet := {.F., "JA203HAjus - NVV"}
			Exit
		EndIf
	Next nI
EndIf

If aRet[1] .AND. !Empty(cCPREFT) .AND. cTipoEmi == "FT"
	cQuery := " SELECT R_E_C_N_O_ RECNO "
	cQuery += " FROM " + RetSqlName("NWD")
	cQuery += " WHERE NWD_FILIAL = '" + xFilial("NWD") + "' "
	cQuery +=   " AND NWD_PRECNF = '" + cCPREFT + "' "
	cQuery +=   " AND D_E_L_E_T_ = ' ' "

	aSqlRet := JurSQL(cQuery, {"RECNO"})

	For nI := 1 To Len(aSqlRet)
		NWD->(DbGoto(aSqlRet[nI][1]))
		If RecLock("NWD", .F.)
			NWD->NWD_CANC  := "1"
			NWD->(MsUnlock())
			NWD->(DbCommit())
		Else
			aRet := {.F., "JA203HAjus - NWD - cPreft"}
			Exit
		EndIf
	Next nI
EndIf

RestArea(aArea)

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} JA203HConv
Converte a fatura na moeda do pagador.

@Param   oParams     Objeto de parâmetros de emissão
@Param   cMoedaFat   Moeda da Fatura
@Param   cMoedaPre   Moeda da pré - utilizada para gerar a 1a fatura
@Param   cEscr       Código do Escritório
@Param   cFatura     Código da Fatura
@Param   nPercPag    Percentual do pagador
@Param   cGrossHon   Tipo de Gross up de honorários - 1 = Não se Aplica - 2 = Impostos - 3 = % Fixo
@Param   nPercGrHon  Percentual de Gross up de honorários

@Return		Nil

@author David Fernandes
@since 20/09/2011
@version 1.0

@Obs Foi realizada a mudança para que toda conversão seja realizada pela JA201FConv(),
pois a rotina agora trabalha com decimal de ponto fixo para aumentar a precisão da conversão.

@Obs Para fatura que nao sofreram rateio
/*/
//-------------------------------------------------------------------
Static function JA203HConv(oParams, cMoedaFat, cMoedaPre, cEscr, cFatura, nPercPag, cGrossHon, nPercGrHon)
Local aRet       := {.F., "JA203HConv" }
Local aArea      := GetArea()
Local cFilialEsc := JurGetDados("NS7", 1, xFilial("NS7") + cEscr, "NS7_CFILIA")
Local cMoedaNac  := SuperGetMv('MV_JMOENAC',, '01' )
Local cTipoExec  := oParams:GetTpExec()
Local dDataEmit  := oParams:GetDEmi()
Local cFilaImpr  := oParams:GetCFilaImpr()

Local aConvFat   := {}
Local aSomaTS    := {}
Local aSomaDP    := {}
Local aSomaTB    := {}

Local nVLHonFat  := 0
Local nVLDespFat := 0

Local nDesEspCon := 0
Local nDesEspFat := 0
Local nDesLinCon := 0
Local nDesLinFat := 0

Local nDesPagCon := 0
Local nDesPagFat := 0

Local nAcressCon := 0
Local nAcressFat := 0
Local nAcressNac := 0

Local nTotEsp    := 0
Local nTotLin    := 0

Local nMaiorE    := 0
Local nMaiorL    := 0
Local nRecCaE    := 0
Local nRecCoE    := 0
Local nRecCaL    := 0
Local nRecCoL    := 0

Local nVLHonCon  := 0
Local nVLDespCon := 0

Local nVLTSCon   := 0
Local nVLTSVCon  := 0
Local nVLTSTBCon := 0
Local nVLTBCon   := 0
Local nVLTbVCon  := 0
Local nVLFXCon   := 0
Local nVLFXVCon  := 0

Local nVLDpNac   := 0
Local nVLTbNac   := 0
Local nVLTSNac   := 0

Local nVlDpTrib   := 0
Local nVlDpReemb  := 0
Local aVlTxTrib   := {0,0}

Local nVlNXBTrib  := 0
Local nVlNXBReemb := 0
Local nVlNXBGros  := 0
Local nVlNXBTxAd  := 0
Local nVlNXBTotD  := 0

Local nVlNXATrib  := 0
Local nVlNXAReemb := 0
Local nVlNXAGros  := 0
Local nVlNXATxAd  := 0
Local nVlNXATotD  := 0
Local lTabVinc    := NXC->(ColumnPos('NXC_VTBVIN')) > 0 // Proteção
Local lDespTrib   := NXC->(ColumnPos('NXC_VLREMB')) > 0 ; // Proteção
					.And. NXB->(ColumnPos('NXB_VLTRIB')) > 0 .And. NXB->(ColumnPos('NXB_VLREMB')) > 0 ; // Proteção
					.And. NXB->(ColumnPos('NXB_VLGROS')) > 0 .And. NXB->(ColumnPos('NXB_VLTXAD')) > 0 ; // Proteção
					.And. NXB->(ColumnPos('NXB_VLTOTD')) > 0 // Proteção
Local lGrosHonNac := NXA->(ColumnPos("NXA_GRSHMN")) > 0 // @12.1.2310

Local nSomaFxCon  := 0
Local nSomaFxVCon := 0
Local nSaldoFx    := 0
Local nSaldoFxV   := 0
Local nRecFx      := 0
Local nMaiorFx    := 0

If (cMoedaFat != cMoedaNac) .OR. (cMoedaFat != cMoedaPre) .OR. (nPercPag != 1.00)

	NXA->( dbSetOrder(1) )
	If NXA->( MsSeek( xFilial("NXA") + cEscr + cFatura  ) )

		aConvFat := JA201FConv(cMoedaFat, cMoedaPre, (NXA->NXA_VLDSCE * nPercPag), cTipoExec, dDataEmit, cFilaImpr, "", cFilialEsc)
		nTotEsp    := Round(aConvFat[1], TamSX3('NXA_VLDSCE')[2]) //Desconto Especial, é calculado top down

		aConvFat := JA201FConv(cMoedaFat, cMoedaPre, (NXA->NXA_VLDSCL * nPercPag), cTipoExec, dDataEmit, cFilaImpr, "", cFilialEsc)
		nTotLin    := Round(aConvFat[1], TamSX3('NXA_VLDSCL')[2]) //Desconto Linear, é calculado top down

		aConvFat := JA201FConv(cMoedaFat, cMoedaPre, (NXA->NXA_VLDSCP * nPercPag), cTipoExec, dDataEmit, cFilaImpr, "", cFilialEsc)
		nDesPagFat := Round(aConvFat[1], TamSX3('NXA_VLDSCP')[2]) //Desconto pagador, é calculado top down pela JA203ARat

		aConvFat := JA201FConv(cMoedaFat, cMoedaPre, (NXA->NXA_VLACRE * nPercPag), cTipoExec, dDataEmit, cFilaImpr, "", cFilialEsc)
		nAcressFat := Round(aConvFat[1], TamSX3('NXA_VLACRE')[2]) //Acréscimo da Fatura, é calculado top down pela JA203ARat

		aConvFat := JA201FConv(cMoedaNac, cMoedaPre, (NXA->NXA_VLACRE * nPercPag), cTipoExec, dDataEmit, cFilaImpr, "", cFilialEsc)
		nAcressNac := Round(aConvFat[1], TamSX3('NXA_ACREMN')[2]) //Calcula o valor de acrescimos para evitar perda de precisão com duas conversões

		NXB->( dbSetOrder(3) )   // NXB_FILIAL+NXB_CESCR+NXB_CFATUR+NXB_CCONTR
		If NXB->( MsSeek( xFilial("NXB") + cEscr + cFatura  ) )

			nVLHonFat  := 0.00
			nVLDespFat := 0.00
			nDesEspFat := 0.00 //Desconto Especial da Fatura
			nDesLinFat := 0.00 //Desconto Linear da Fatura

			While ( NXB->(NXB_FILIAL + NXB_CESCR + NXB_CFATUR) == xFilial("NXB") + cEscr + cFatura)

				nDesEspCon  := 0.00 //Desconto Especial do Contrato
				nDesLinCon  := 0.00 //Desconto Linear do Contrato
				nDesPagCon  := 0.00 //Acumulador de Desconto Pagador do Contrato
				nAcressCon  := 0.00 //Acumulador de Acressimo do Contrato
				nVLHonCon   := 0.00 //Acumulador de Honorarios do Contrato
				nVLDespCon  := 0.00 //Acumulador de Despesas do Contrato
				nVLTSCon    := 0.00 //Acumulador de TimeSheets
				nVLTBCon    := 0.00 //Acumulador de Serviço Tabelado
				nVLFXCon    := 0.00 //Acumulador de Fixo
				nVLTSVCon   := 0.00 //Acumulador de Ts Vinculado
				nVLTbVCon   := 0.00 //Acumulador de Serviço Tabelado Vinculado
				nVLFXVCon   := 0.00 //Acumulador de Fixo Vinculado
				nVLTSTBCon  := 0.00 //Acumulador de TimeSheets com tabelado
				nSomaFxCon  := 0.00 //Acumulador de Valor de fixo para ajuste de saldo
				nSomaFxVCon := 0.00 //Acumulador de Valor de fixo vinculado para ajuste de saldo

				NXC->( dbSetOrder(3) )  //NXC_FILIAL+NXC_CESCR+NXC_CFATUR+NXC_CCONTR+NXC_CCLIEN+NXC_CLOJA+NXC_CCASO
				If NXC->( MsSeek( xFilial("NXC") + NXB->(NXB_CESCR + NXB_CFATUR + NXB_CCONTR) ) )

					While ( NXC->(NXC_FILIAL + NXC_CESCR + NXC_CFATUR + NXC_CCONTR) == xFilial("NXC") + NXB->(NXB_CESCR + NXB_CFATUR + NXB_CCONTR) )

						If lDespTrib
							nVlDpTrib  := NXC->NXC_VLTRIB
							nVlDpReemb := NXC->NXC_VLREMB
						EndIf

						aSomaTS := J203HSumTS(oParams, cMoedaPre, cMoedaFat, cEscr, cFatura, NXC->NXC_CCLIEN, NXC->NXC_CLOJA, NXC->NXC_CCASO, NXC->NXC_VLTS  , nPercPag, NXB->NXB_CCONTR)
						aSomaDP := J203HSumDP(oParams, cMoedaPre, cMoedaFat, cEscr, cFatura, NXC->NXC_CCLIEN, NXC->NXC_CLOJA, NXC->NXC_CCASO, NXC->NXC_VLDESP, nVlDpTrib, nVlDpReemb, nPercPag, NXA->NXA_CFTADC)
						aSomaTB := J203HSumTB(oParams, cMoedaPre, cMoedaFat, cEscr, cFatura, NXC->NXC_CCLIEN, NXC->NXC_CLOJA, NXC->NXC_CCASO, NXC->NXC_VLTAB , nPercPag )

						RecLock("NXC", .F.)

						If lDespTrib
							aVlTxTrib := JurTxTrib(aSomaDP[3], cEscr, cFatura)

							NXC->NXC_VLTRIB := Round( ( aSomaDP[3]           ), TamSX3('NXC_VLTRIB')[2])
							NXC->NXC_VLREMB := Round( ( aSomaDP[4]           ), TamSX3('NXC_VLREMB')[2])
							NXC->NXC_VLGROS := Round( ( aVlTxTrib[1]         ), TamSX3('NXC_VLGROS')[2])
							NXC->NXC_VLTXAD := Round( ( aVlTxTrib[2]         ), TamSX3('NXC_VLTXAD')[2])
							NXC->NXC_VLTOTD := NXC->NXC_VLTRIB + NXC->NXC_VLGROS + NXC->NXC_VLTXAD

							aSomaDP[1] += NXC->NXC_VLGROS + NXC->NXC_VLTXAD // Soma as taxas
							aSomaDP[2] += Round(JA201FConv(cMoedaNac, cMoedaFat, NXC->NXC_VLGROS + NXC->NXC_VLTXAD, cTipoExec, dDataEmit, cFilaImpr, "" , cFilialEsc)[1] , TamSX3('NXA_FATDMN')[2])
						EndIf

						NXC->NXC_VLTS   := Round( ( aSomaTS[1]               ), TamSX3('NXC_VLTS')[2] )
						NXC->NXC_VLDESP := Round( ( aSomaDP[1]               ), TamSX3('NXC_VLDESP')[2])
						NXC->NXC_VLDFAT := Round( ( aSomaDP[1]               ), TamSX3('NXC_VLDFAT')[2])
						NXC->NXC_VLTAB  := Round( ( aSomaTB[1]               ), TamSX3('NXC_VLTAB' )[2])

						aConvFat := JA201FConv(cMoedaFat, cMoedaPre, (NXC->NXC_VTSVIN * nPercPag), cTipoExec, dDataEmit, cFilaImpr, "" , cFilialEsc)
						NXC->NXC_VTSVIN := Round( ( aConvFat[1]              ), TamSX3('NXC_VTSVIN')[2])
						If lTabVinc
							aConvFat := JA201FConv(cMoedaFat, cMoedaPre, (NXC->NXC_VTBVIN * nPercPag), cTipoExec, dDataEmit, cFilaImpr, "" , cFilialEsc)
							NXC->NXC_VTBVIN := Round( ( aConvFat[1]              ), TamSX3('NXC_VTBVIN')[2])
						EndIf

						aConvFat := JA201FConv(cMoedaFat, cMoedaPre, (NXC->NXC_VFIXO * nPercPag), cTipoExec, dDataEmit, cFilaImpr, "" , cFilialEsc)
						nSomaFxCon += NXC->NXC_VFIXO
						NXC->NXC_VFIXO  := Round( ( aConvFat[1]              ), TamSX3('NXC_VFIXO')[2])

						If NXC->(ColumnPos('NXC_VFXVIN')) > 0 //Proteção
							aConvFat := JA201FConv(cMoedaFat, cMoedaPre, (NXC->NXC_VFXVIN * nPercPag), cTipoExec, dDataEmit, cFilaImpr, "" , cFilialEsc)
							nSomaFxVCon += NXC->NXC_VFXVIN
							NXC->NXC_VFXVIN  := Round( ( aConvFat[1]              ), TamSX3('NXC_VFXVIN')[2])
						EndIf

						aConvFat := JA201FConv(cMoedaFat, cMoedaPre, (NXC->NXC_DRATF * nPercPag), cTipoExec, dDataEmit, cFilaImpr, "" , cFilialEsc)
						NXC->NXC_DRATF  := Round( ( aConvFat[1]              ), TamSX3('NXC_DRATF' )[2])

						aConvFat := JA201FConv(cMoedaFat, cMoedaPre, (NXC->NXC_DRATL * nPercPag), cTipoExec, dDataEmit, cFilaImpr, "" , cFilialEsc)
						NXC->NXC_DRATL  := Round( ( aConvFat[1]              ), TamSX3('NXC_DRATL' )[2])

						aConvFat := JA201FConv(cMoedaFat, cMoedaPre, (NXC->NXC_VLTSTB * nPercPag), cTipoExec, dDataEmit, cFilaImpr, "" , cFilialEsc)
						NXC->NXC_VLTSTB := Round( ( aConvFat[1]              ), TamSX3('NXC_VLTSTB')[2])

						aConvFat := JA201FConv(cMoedaFat, cMoedaPre, (NXC->NXC_DRATE * nPercPag), cTipoExec, dDataEmit, cFilaImpr, "" , cFilialEsc)
						NXC->NXC_DRATE  := Round( ( aConvFat[1]               ), TamSX3('NXC_DRATE' )[2])

						NXC->NXC_VLHFAT := Round( ( NXC->(NXC_VLTS+NXC_VLTAB+NXC_VFIXO)) , TamSX3('NXC_VLHFAT')[2])

						NXC->(MsUnlock())
						NXC->( DbCommit() )

						nDesEspCon := nDesEspCon + NXC->NXC_DRATE
						nDesLinCon := nDesLinCon + NXC->NXC_DRATL

						nVLHonCon  := nVLHonCon  + NXC->NXC_VLHFAT
						nVLDespCon := nVLDespCon + NXC->NXC_VLDFAT
						nVLDpNac   := nVLDpNac   + aSomaDP[2]

						If lDespTrib
							nVlNXBTrib  += NXC->NXC_VLTRIB
							nVlNXBReemb += NXC->NXC_VLREMB
							nVlNXBGros  += NXC->NXC_VLGROS
							nVlNXBTxAd  += NXC->NXC_VLTXAD
							nVlNXBTotD  += NXC->NXC_VLTOTD
						EndIf

						nVLTSCon   := nVLTSCon   + NXC->NXC_VLTS
						nVLTSNac   := nVLTSNac   + aSomaTS[2]
						nVLTBCon   := nVLTBCon   + NXC->NXC_VLTAB
						nVLTbNac   := nVLTbNac   + aSomaTB[2]

						nVLTSTBCon := nVLTSTBCon + NXC->NXC_VLTSTB
						nVLTSVCon  := nVLTSVCon  + NXC->NXC_VTSVIN
						If lTabVinc
							nVLTbVCon  := nVLTbVCon  + NXC->NXC_VTBVIN
						EndIf
						nVLFXCon   := nVLFXCon   + NXC->NXC_VFIXO
						If NXC->(ColumnPos('NXC_VFXVIN')) > 0 //Proteção
							nVLFXVCon  := nVLFXVCon  + NXC->NXC_VFXVIN
						EndIf

						If NXC->NXC_DRATE >= nMaiorE
							nMaiorE := NXC->NXC_DRATE
							nRecCaE := NXC->(Recno())
							nRecCoE := NXB->(Recno())
						EndIf

						If NXC->NXC_DRATL >= nMaiorL
							nMaiorL := NXC->NXC_DRATL
							nRecCaL := NXC->(Recno())
							nRecCoL := NXB->(Recno())
						EndIf

						If NXC->NXC_VFIXO >= nMaiorFx
							nMaiorFx := NXC->NXC_VFIXO
							nRecFx   := NXC->(Recno())
						EndIf

						NXC->( dbSkip() )
					EndDo

					aConvFat   := JA201FConv(cMoedaFat, cMoedaPre, (nSomaFxCon * nPercPag), cTipoExec, dDataEmit, cFilaImpr, "" , cFilialEsc)
					nSomaFxCon := Round( ( aConvFat[1]              ), TamSX3('NXC_VFIXO')[2])

					If NXC->(ColumnPos('NXC_VFXVIN')) > 0 //Proteção
						aConvFat    := JA201FConv(cMoedaFat, cMoedaPre, (nSomaFxVCon * nPercPag), cTipoExec, dDataEmit, cFilaImpr, "" , cFilialEsc)
						nSomaFxVCon := Round( ( aConvFat[1]              ), TamSX3('NXC_VFXVIN')[2])
					EndIf

					//Ajusta arredondamentos dos saldos de rateio de fixo e fixo vinculado nos casos:
					nSaldoFx  := nSomaFxCon - nVLFXCon
					nSaldoFxV := nSomaFxVCon - nVLFXVCon
					If nSaldoFx != 0 .Or. nSaldoFxV != 0
						NXC->(DbGoTo(nRecFx))
						If !NXC->(EOF())
							RecLock("NXC", .F.)
							NXC->NXC_VFIXO  := Round( NXC->NXC_VFIXO + nSaldoFx, TamSX3('NXC_VFIXO')[2])
							NXC->NXC_VLHFAT := Round( NXC->NXC_VLHFAT + nSaldoFx, TamSX3('NXC_VLHFAT')[2])
							If NXC->(ColumnPos('NXC_VFXVIN')) > 0 //Proteção
								NXC->NXC_VFXVIN := Round( NXC->NXC_VFXVIN + nSaldoFxV, TamSX3('NXC_VFXVIN')[2])
							EndIf
							NXC->(MsUnlock())
							NXC->(DbCommit())
						EndIf
						nVLFXCon  := nVLFXCon + nSaldoFx
						nVLFXVCon := nVLFXVCon + nSaldoFxV
						nVLHonCon := nVLHonCon + nSaldoFx
					EndIf

				EndIf

				RecLock("NXB", .F.)
				
				If NXB->NXB_SLDANT == 0
					NXB->NXB_VLFATH := Round( ( nVLHonCon ), TamSX3('NXB_VLFATH')[2])
				Else
					aConvFat := JA201FConv(cMoedaFat, cMoedaPre, (NXB->NXB_VLFATH * nPercPag), cTipoExec, dDataEmit, cFilaImpr, "" , cFilialEsc)
					NXB->NXB_VLFATH := Round( ( aConvFat[1] ), TamSX3('NXB_VLFATH')[2])
				EndIf

				NXB->NXB_VLFATD := Round( ( nVLDespCon ), TamSX3('NXB_VLFATD')[2])

				If lDespTrib
					NXB->NXB_VLTRIB := Round( ( nVlNXBTrib ), TamSx3('NXB_VLTRIB')[2])
					NXB->NXB_VLREMB := Round( ( nVlNXBReem ), TamSx3('NXB_VLREMB')[2])
					NXB->NXB_VLGROS := Round( ( nVlNXBGros ), TamSx3('NXB_VLGROS')[2])
					NXB->NXB_VLTXAD := Round( ( nVlNXBTxAd ), TamSx3('NXB_VLTXAD')[2])
					NXB->NXB_VLTOTD := Round( ( nVlNXBTotD ), TamSx3('NXB_VLTOTD')[2])

					nVlNXBTrib := 0
					nVlNXBReem := 0
					nVlNXBGros := 0
					nVlNXBTxAd := 0
					nVlNXBTotD := 0
				EndIf

				aConvFat := JA201FConv(cMoedaFat, cMoedaPre, (NXB->NXB_SLDANT * nPercPag), cTipoExec, dDataEmit, cFilaImpr, "" , cFilialEsc)
				NXB->NXB_SLDANT := Round( ( aConvFat[1]               ), TamSX3('NXB_SLDANT')[2])

				aConvFat := JA201FConv(cMoedaFat, cMoedaPre, (NXB->NXB_SLDPRO * nPercPag), cTipoExec, dDataEmit, cFilaImpr, "" , cFilialEsc)
				NXB->NXB_SLDPRO := Round( ( aConvFat[1]               ), TamSX3('NXB_SLDPRO')[2])

				aConvFat := JA201FConv(cMoedaFat, cMoedaPre, (NXB->NXB_VLHFV  * nPercPag), cTipoExec, dDataEmit, cFilaImpr, "" , cFilialEsc)
				NXB->NXB_VLHFV  := Round( ( aConvFat[1]               ), TamSX3('NXB_VLHFV' )[2])

				aConvFat := JA201FConv(cMoedaFat, cMoedaPre, (NXB->NXB_SLDLF  * nPercPag), cTipoExec, dDataEmit, cFilaImpr, "" , cFilialEsc)
				NXB->NXB_SLDLF  := Round( ( aConvFat[1]               ), TamSX3('NXB_SLDLF' )[2])

				aConvFat := JA201FConv(cMoedaFat, cMoedaPre, (NXB->NXB_DVLLIM * nPercPag), cTipoExec, dDataEmit, cFilaImpr, "" , cFilialEsc)
				NXB->NXB_DVLLIM := Round( ( aConvFat[1]               ), TamSX3('NXB_DVLLIM')[2])

				aConvFat := JA201FConv(cMoedaFat, cMoedaPre, (NXB->NXB_VLTSLM * nPercPag), cTipoExec, dDataEmit, cFilaImpr, "" , cFilialEsc)
				NXB->NXB_VLTSLM := Round( ( aConvFat[1]               ), TamSX3('NXB_VLTSLM')[2])

				aConvFat := JA201FConv(cMoedaFat, cMoedaPre, (NXB->NXB_VLLTLM * nPercPag), cTipoExec, dDataEmit, cFilaImpr, "" , cFilialEsc)
				NXB->NXB_VLLTLM := Round( ( aConvFat[1]               ), TamSX3('NXB_VLLTLM')[2])

				aConvFat := JA201FConv(cMoedaFat, cMoedaPre, (NXB->NXB_VLFXLM * nPercPag), cTipoExec, dDataEmit, cFilaImpr, "" , cFilialEsc)
				NXB->NXB_VLFXLM := Round( ( aConvFat[1]               ), TamSX3('NXB_VLFXLM')[2])

				aConvFat := JA201FConv(cMoedaFat, cMoedaPre, (NXB->NXB_VLFALM * nPercPag), cTipoExec, dDataEmit, cFilaImpr, "" , cFilialEsc)
				NXB->NXB_VLFALM := Round( ( aConvFat[1]               ), TamSX3('NXB_VLFALM')[2])

				NXB->NXB_VTSVIN := Round( ( nVLTSVCon                 ), TamSX3('NXB_VTSVIN')[2])

				NXB->NXB_VTAB   := Round( ( nVLTBCon                  ), TamSX3('NXB_VTAB'  )[2])
				NXB->NXB_VTS    := Round( ( nVLTSCon                  ), TamSX3('NXB_VTS'   )[2])
				NXB->NXB_VTSTAB := Round( ( nVLTSTBCon                ), TamSX3('NXB_VTSTAB')[2])
				If NXB->(ColumnPos('NXB_VTBVIN')) > 0 //Proteção
					NXB->NXB_VTBVIN := Round( ( nVLTbVCon                 ), TamSX3('NXB_VTBVIN')[2])
				EndIf
				aConvFat := JA201FConv(cMoedaFat, cMoedaPre, (NXB->NXB_VEXFX * nPercPag), cTipoExec, dDataEmit, cFilaImpr, "" , cFilialEsc)
				NXB->NXB_VEXFX  := Round( (aConvFat[1]                ), TamSX3('NXB_VEXFX' )[2])

				aConvFat := JA201FConv(cMoedaFat, cMoedaPre, (NXB->NXB_VEXHR * nPercPag), cTipoExec, dDataEmit, cFilaImpr, "" , cFilialEsc)
				NXB->NXB_VEXHR  := Round( (aConvFat[1]                ), TamSX3('NXB_VEXHR' )[2])

				NXB->NXB_DRATL  := Round( ( nDesLinCon                       ), TamSX3('NXB_DRATL' )[2])
				NXB->NXB_DRATE  := Round( ( nDesEspCon                       ), TamSX3('NXB_DRATE' )[2])
				NXB->NXB_DRATF  := Round( nDesEspCon + nDesLinCon + nDesPagFat, TamSX3('NXB_DRATF' )[2])
				NXB->NXB_VFIXO  := Round( ( nVLFXCon                         ), TamSX3('NXB_VFIXO' )[2])
				If NXB->(ColumnPos('NXB_VFXVIN')) > 0 //Proteção
					NXB->NXB_VFXVIN := Round( ( nVLFXVCon                 ), TamSX3('NXB_VFXVIN')[2])
				EndIf
				NXB->(MsUnlock())
				NXB->(DbCommit())

				nVLHonFat   := nVLHonFat  + NXB->NXB_VLFATH
				nVLDespFat  := nVLDespFat + NXB->NXB_VLFATD

				If lDespTrib
					nVlNXATrib  += NXB->NXB_VLTRIB
					nVlNXAReemb += NXB->NXB_VLREMB
					nVlNXAGros  += NXB->NXB_VLGROS
					nVlNXATxAd  += NXB->NXB_VLTXAD
					nVlNXATotD  += NXB->NXB_VLTOTD
				EndIf

				nDesEspFat  := nDesEspFat + NXB->NXB_DRATE
				nDesLinFat  := nDesLinFat + NXB->NXB_DRATL

				If !Empty(NXA->NXA_CFTADC)
					J203HAjuFA(oParams, cMoedaFat, cEscr, cFatura, NXB->NXB_CCONTR, NXB->NXB_VTS, NXB->NXB_VTAB, NXB->NXB_VLFATD) //Ajusta o histórico de faturamento da fatura Adicional
				EndIf

				If !Empty(NXB->NXB_VFIXO)
					J203HAjuFX(oParams, cMoedaFat, cEscr, cFatura, NXB->NXB_CCONTR) //Ajusta o histórico de faturamento da parcela de Fixo
				EndIf

				NXB->( dbSkip() )

			EndDo

		EndIf

		//Ajuste o saldo da conversão Desconto especial:
		nSaldoE := nTotEsp - nDesEspFat
		If !(nSaldoE == 0)
			NXC->(DbGoTo(nRecCaE))
			If !NXC->(EOF())
				RecLock("NXC", .F.)
				NXC->NXC_DRATE := Round( NXC->NXC_DRATE + nSaldoE, TamSX3('NXC_DRATE')[2])
				NXC->(MsUnlock())
				NXC->(DbCommit())
			EndIf

			NXB->(DbGoTo(nRecCoE))
			If !NXB->(EOF())
				RecLock("NXB", .F.)
				NXB->NXB_DRATE := Round( NXB->NXB_DRATE + nSaldoE, TamSX3('NXB_DRATE')[2])
				NXB->(MsUnlock())
				NXB->(DbCommit())
			EndIf
		EndIf

		//Ajuste o saldo da conversão Desconto linear:
		nSaldoL := nTotLin - nDesLinFat
		If !(nSaldoL == 0)
			NXC->(DbGoTo(nRecCaL))
			If !NXC->(EOF())
				RecLock("NXC", .F.)
				NXC->NXC_DRATL := Round( NXC->NXC_DRATL + nSaldoL, TamSX3('NXC_DRATL')[2])
				NXC->(MsUnlock())
				NXC->(DbCommit())
			EndIf

			NXB->(DbGoTo(nRecCoL))
			If !NXB->(EOF())
				RecLock("NXB", .F.)
				NXB->NXB_DRATL := Round( NXB->NXB_DRATL + nSaldoL, TamSX3('NXB_DRATL')[2])
				NXB->(MsUnlock())
				NXB->(DbCommit())
			EndIf
		EndIf

		RecLock("NXA", .F.)
		NXA->NXA_VLDSCE     := Round(nTotEsp                                 , TamSX3('NXA_VLDSCE')[2]) //Desconto Especial
		NXA->NXA_VLDSCL     := Round(nTotLin                                 , TamSX3('NXA_VLDSCL')[2]) //Desconto Linear
		NXA->NXA_VLDSCP     := Round(nDesPagFat                              , TamSX3('NXA_VLDSCP')[2]) //Desconto pagador
		NXA->NXA_VLDESC     := Round(NXA->(NXA_VLDSCE+NXA_VLDSCL+NXA_VLDSCP) , TamSX3('NXA_VLDESC')[2])
		NXA->NXA_VLACRE     := Round(nAcressFat                              , TamSX3('NXA_VLACRE')[2]) //O valor do acréscimo
		NXA->NXA_VLFATH     := Round(nVLHonFat                               , TamSX3('NXA_VLFATH')[2])
		NXA->NXA_VLFATD     := Round(nVLDespFat                              , TamSX3('NXA_VLFATD')[2])

		If lDespTrib
			NXA->NXA_VLTRIB := Round( ( nVlNXATrib ), TamSx3('NXA_VLTRIB')[2])
			NXA->NXA_VLREMB := Round( ( nVlNXAReem ), TamSx3('NXA_VLREMB')[2])
			NXA->NXA_VLGROS := Round( ( nVlNXAGros ), TamSx3('NXA_VLGROS')[2])
			NXA->NXA_VLTXAD := Round( ( nVlNXATxAd ), TamSx3('NXA_VLTXAD')[2])
			NXA->NXA_VLTOTD := Round( ( nVlNXATotD ), TamSx3('NXA_VLTOTD')[2])
		EndIf

		//Aplica o gross up de honorários
		If cGrossHon $ "2|3"
			NXA->NXA_VGROSH := J203HGrsHon(cGrossHon, nPercGrHon)
		EndIf

		If (cMoedaFat != cMoedaNac)
			aConvFat := JA201FConv(cMoedaNac, cMoedaFat, NXA->NXA_VLFATH  , cTipoExec, dDataEmit, cFilaImpr, "" , cFilialEsc)
			NXA->NXA_FATHMN  := Round(aConvFat[1]                         , TamSX3('NXA_FATHMN')[2])
			aConvFat := JA201FConv(cMoedaNac, cMoedaFat, NXA->NXA_VLFATD  , cTipoExec, dDataEmit, cFilaImpr, "" , cFilialEsc)
			NXA->NXA_FATDMN  := Round(aConvFat[1]                         , TamSX3('NXA_FATDMN')[2])
			aConvFat := JA201FConv(cMoedaNac, cMoedaFat, NXA->NXA_VLDESC , cTipoExec, dDataEmit, cFilaImpr, "" , cFilialEsc)
			NXA->NXA_DESCMN  := Round(aConvFat[1]                             , TamSX3('NXA_DESCMN')[2])
			NXA->NXA_ACREMN  := Round(nAcressNac                              , TamSX3('NXA_ACREMN')[2])
			If lDespTrib
				aConvFat := JA201FConv(cMoedaNac, cMoedaFat, NXA->NXA_VLTXAD  , cTipoExec, dDataEmit, cFilaImpr, "" , cFilialEsc)
				NXA->NXA_TXADMN := Round(aConvFat[1]                          , TamSX3('NXA_TXADMN')[2])
				aConvFat := JA201FConv(cMoedaNac, cMoedaFat, NXA->NXA_VLGROS  , cTipoExec, dDataEmit, cFilaImpr, "" , cFilialEsc)
				NXA->NXA_GROSMN := Round(aConvFat[1]                          , TamSX3('NXA_GROSMN')[2])
				aConvFat := JA201FConv(cMoedaNac, cMoedaFat, NXA->NXA_VLREMB  , cTipoExec, dDataEmit, cFilaImpr, "" , cFilialEsc)
				NXA->NXA_REMBMN := Round(aConvFat[1]                          , TamSX3('NXA_REMBMN')[2])
				aConvFat := JA201FConv(cMoedaNac, cMoedaFat, NXA->NXA_VLTRIB  , cTipoExec, dDataEmit, cFilaImpr, "" , cFilialEsc)
				NXA->NXA_TRIBMN := Round(aConvFat[1]                          , TamSX3('NXA_TRIBMN')[2])
			EndIf

			If cGrossHon == "3" .And. NXA->NXA_VGROSH > 0 .And. lGrosHonNac //gross up de honorários percentual fixo
				aConvFat := JA201FConv(cMoedaNac, cMoedaFat, NXA->NXA_VGROSH  , cTipoExec, dDataEmit, cFilaImpr, "" , cFilialEsc)
				NXA->NXA_GRSHMN := Round(aConvFat[1]                          , TamSX3('NXA_GRSHMN')[2])
			EndIf
		Else
			NXA->NXA_FATHMN  := NXA->NXA_VLFATH
			NXA->NXA_FATDMN  := NXA->NXA_VLFATD
			NXA->NXA_DESCMN  := NXA->NXA_VLDESC
			NXA->NXA_ACREMN  := NXA->NXA_VLACRE
			If lDespTrib
				NXA->NXA_TXADMN := NXA->NXA_VLTXAD
				NXA->NXA_GROSMN := NXA->NXA_VLGROS
				NXA->NXA_REMBMN := NXA->NXA_VLREMB
				NXA->NXA_TRIBMN := NXA->NXA_VLTRIB
			EndIf
			
			If lGrosHonNac //gross up de honorários percentual fixo
				NXA->NXA_GRSHMN := NXA->NXA_VGROSH
			EndIf
		EndIf

		NXA->(DbCommit())
		NXA->(MsUnlock())

		J203HGrsCas(cEscr, cFatura) // Aplica o gross up de honorários por contrato e caso 

		//Grava na fila de sincronização
		J170GRAVA("NXA", xFilial("NXA") + NXA->NXA_CESCR + NXA->NXA_COD, "4")

	EndIf

Else //Moeda da Fatura igual a Moeda Nacional

	NXA->( dbSetOrder(1) )
	If (NXA->( MsSeek( xFilial("NXA") + cEscr + cFatura  ) ))

		J203TxDP(cEscr, cFatura) //Aplica as taxas nas depesas tributáveis

		RecLock("NXA", .F.)
		NXA->NXA_FATHMN  := NXA->NXA_VLFATH
		NXA->NXA_FATDMN  := NXA->NXA_VLFATD
		NXA->NXA_DESCMN  := NXA->NXA_VLDESC
		NXA->NXA_ACREMN  := NXA->NXA_VLACRE
		If lDespTrib
			NXA->NXA_TXADMN := NXA->NXA_VLTXAD
			NXA->NXA_GROSMN := NXA->NXA_VLGROS
			NXA->NXA_REMBMN := NXA->NXA_VLREMB
			NXA->NXA_TRIBMN := NXA->NXA_VLTRIB
		EndIf

		//Aplica o gross up de honorários
		If cGrossHon $ "2|3"
			NXA->NXA_VGROSH := J203HGrsHon(cGrossHon, nPercGrHon)
			If lGrosHonNac
				NXA->NXA_GRSHMN := NXA->NXA_VGROSH
			EndIf
		EndIf

		NXA->(MsUnlock())
		NXA->(DbCommit())

		J203HGrsCas(cEscr, cFatura) // Aplica o gross up de honorários por contrato e caso 

		// Grava na fila de sincronização
		J170GRAVA("NXA", xFilial("NXA") + NXA->NXA_CESCR + NXA->NXA_COD, "4")

	EndIf

EndIf

aRet := {.T., "JA203HConv" }

RestArea(aArea)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc}  J203VlDesc()
Função para verificar se o valor dos descontos nos caso é igual ao valor
de desconto na Fatura para fazer o rateio.

@author Luciano Pereira dos Santos
@since 20/02/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J203VlDesc(cEscr,cFatura, cTipoDesc)
Local lRet      := .T.
Local aArea     := GetArea()
Local cQuery    := ""
Local cQryRes   := GetNextAlias()
Local nDescFat  := 0
Local cCpoDesc  := ""

If cTipoDesc == "1" //Desconto Especial
	nDescFat := JurGetDados("NXA", 1, xFilial("NXA") + cEscr + cFatura, "NXA_VLDSCE")
	cCpoDesc := "NXC_DRATE"
ElseIf cTipoDesc =="2" //Desconto do Pagador
	nDescFat := JurGetDados("NXA", 1, xFilial("NXA") + cEscr + cFatura, "NXA_VLDSCP")
	cCpoDesc := "NXC_DRATP"
EndIf

cQuery := " select SUM(NXC." + cCpoDesc + ") AS DESCCASO "
cQuery += " from " + RetSqlName("NXC") + " NXC "
cQuery += " where NXC.NXC_FILIAL = '" + xFilial("NXC") + "'"
cQuery += " and   NXC.NXC_CFATUR = '" + cFatura + "'"
cQuery += " and   NXC.NXC_CESCR  = '" + cEscr + "'"
cQuery += " and   NXC.D_E_L_E_T_ = ' '"

cQuery := ChangeQuery(cQuery, .F.)
DbCommitAll() //Para efetivar a alteração no banco de dados (não impacta no rollback da transação)
dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryRes, .T., .F. )

If !Empty((cQryRes)->DESCCASO)
	nDescCas := Round(((cQryRes)->DESCCASO), 2)
Else
	nDescCas := 0
EndIf

lRet := ABS(nDescCas - nDescFat) > 0.01

(cQryRes)->(DbCloseArea())

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}  J203HGOld()
Rotina para gravar o número da fatura atual na fatura antiga e vice versa

@Params		cCliPg		Cliente Pagador da Fatura
@Params		cLojaPg		Loja do Cliente Pagador da Fatura
@Params		cPreft	   	Código da Pré-fatura da Fatura
@Params		cFatAdic	Código da Fatura Adicional
@Params		cFixo		Código da Parcela de Fixo
@Params		cEscr		Código do Escritório
@Params		cFatura		Código da Fatura

@Return		Nil

@author Luciano Pereira dos Santos
@since 07/05/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function	J203HGOld(cFatura, cEscr, cPreft, cFatAdic, cFixo, cCliPg, cLojaPg)
Local cQuery    := ''
Local aSqlRet   := {}
Local aArea     := GetArea()
Local aAreaNXA  := NXA->(GetArea())
Local cFatSub   := ''
Local cEscSub   := ''

cQuery := "SELECT NXA.R_E_C_N_O_ NXARECNO "
cQuery +=		" FROM " + RetSqlName( 'NXA' ) + " NXA "
cQuery +=			" WHERE NXA.NXA_FILIAL = '" + xFilial("NXA") + "'"
cQuery +=			" AND NXA.NXA_SITUAC = '2' "
cQuery +=			" AND NXA.NXA_TIPO = 'FT' "
Do Case
	Case !Empty(cPreft)
		cQuery +=	" AND NXA.NXA_CPREFT = '" + cPreft + "' "
	Case !Empty(cFatAdic)
		cQuery +=	" AND NXA.NXA_CFTADC = '" + cFatAdic + "' "
	Case !Empty(cFixo)
		cQuery +=	" AND NXA.NXA_CFIXO = '" + cFixo + "' "
	OtherWise
		cQuery +=	" AND '1' = '2' "
EndCase
cQuery +=			" AND NXA.NXA_CLIPG = '" + cCliPg + "' "
cQuery +=			" AND NXA.NXA_LOJPG = '" + cLojaPg + "' "
cQuery +=			" AND NXA.NXA_FATATU = '" +Space(TamSX3('NXA_FATATU')[1]) + "' "
cQuery +=			" AND NXA.NXA_ESCATU = '" +Space(TamSX3('NXA_ESCATU')[1]) + "' "
cQuery +=			" AND NXA.D_E_L_E_T_ = ' ' "

aSqlRet := JurSQL(cQuery, {"NXARECNO"})

If !Empty(aSqlRet)
	NXA->(DBGoTo(aSqlRet[1][1])) //Grava o numero da fatura atual na fatura antiga
	cFatSub := NXA->NXA_COD
	cEscSub := NXA->NXA_CESCR
	RecLock('NXA', .F.)
	NXA->NXA_FATATU := cFatura
	NXA->NXA_ESCATU := cEscr
	NXA->(MsUnLock())
	NXA->(DbCommit())
	//Grava na fila de sincronização
	J170GRAVA("NXA", xFilial("NXA") + NXA->NXA_CESCR + NXA->NXA_COD, "4")
EndIf

If !Empty(cFatSub) .And. !Empty(cFatSub)
	NXA->(dbSetOrder(1)) //NXA_FILIAL+NXA_CESCR+NXA_COD  //Grava o numero da fatura antiga na fatura atual
	If (NXA->(DbSeek(xFilial("NXA") + cEscr + cFatura)))
		RecLock('NXA', .F.)
		NXA->NXA_CFTSUB := cFatSub
		NXA->NXA_CESCSU := cEscSub
		NXA->(MsUnLock())
		NXA->(DbCommit())
		//Grava na fila de sincronização
		J170GRAVA("NXA", xFilial("NXA") + NXA->NXA_CESCR + NXA->NXA_COD, "4")
	EndIf
EndIf

RestArea(aAreaNXA)
RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}  J203CotFat()
Rotina para gravas as cotaçoes de fatura

@Params		oParams			Objeto de parâmetros de emissão
@Params		cMoeda			Moeda da Fatura
@Params		cFatura			Código da Fatura
@Params		cEscr			Código do Escritório

@author Luciano Pereira dos Santos
@since 14/10/13
@version 1.0
/*/
//-------------------------------------------------------------------
Static function J203CotFat(oParams ,cMoeda, cFatura, cEscr)
Local cQuery  := ""
Local cQryRes := GetNextAlias()
Local aArea   := GetArea()

cQuery := " select NX6.NX6_CMOEDA, NX6.NX6_COTAC1 "
cQuery +=   " from " + RetSqlName("NX6") + " NX6 "
cQuery +=   " where NX6.NX6_FILIAL = '" + xFilial("NX6") +"'"
cQuery +=   " and NX6.NX6_CFILA = '" + oParams:GetCFilaImpr() + "' "
cQuery +=   " and ( NX6.NX6_ORIGEM = '2' " // Grava somente cotação dos lançamentos e a do pagador por fatura
cQuery +=         " or NX6.NX6_CMOEDA = '" +cMoeda+ "' )"
cQuery +=   " and NX6.D_E_L_E_T_ = ' '"

cQuery := ChangeQuery(cQuery, .F.)
DbCommitAll() // Para efetivar a alteração no banco de dados (não impacta no rollback da trasação)
dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryRes, .T., .F. )

While !( (cQryRes)->(EOF()) )

	RecLock("NXF", .T.)
	NXF->NXF_COD    := JurGetNum("NXF", "NXF_COD")
	NXF->NXF_FILIAL := xFilial("NXF")
	NXF->NXF_CFATUR := cFatura
	NXF->NXF_CESCR  := cEscr
	NXF->NXF_CMOEDA := (cQryRes)->NX6_CMOEDA
	NXF->NXF_COTAC1 := (cQryRes)->NX6_COTAC1
	NXF->(MsUnlock())
	NXF->(DbCommit())

	//Grava na fila de sincronização
	J170GRAVA("NXA", xFilial("NXA") + cEscr + cFatura, "4")
	(cQryRes)->(DbSkip())
EndDo

(cQryRes)->(dbCloseArea())

RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}J203HSumDP()
Rotina para fazer a soma das despesas na moeda do pagador, se a fatura a não sofreu rateio
ou for de fatura adicional com transferencia de despesas. Em caso de rateio converte o valor
rateado da tabela NXC

@Param   oParams    Objeto de parâmetros de emissão
@Param   cMoedaPre  Moeda da Pré-Fatura
@Param   cMoedaFat  Moeda da Fatura
@Param   cEscr      Código do Escritório
@Param   cFatura    Código da Fatura
@param   cClient    Código do cliente do caso
@param   cLoja      Código da loja do caso
@param   cCaso      Código do caso
@param   nVDpCaso   Valor da Despesa no caso
@param   nPercPag   Percentual do Pagador
@param   cFatAdic   Código da Fatura Adicional.

@author Luciano Pereira dos Santos
@since 14/10/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J203HSumDP(oParams, cMoedaPre, cMoedaFat, cEscrit, cFatura, cClient, cLoja, cCaso, nVDpCaso, nVDpTrip, nVDpReemb, nPercPag, cFatAdic)
Local aArea      := GetArea()
Local aAreaNVY   := NVY->(GetArea())
Local aAreaNVZ   := NVZ->(GetArea())
Local lDespCaso  := JurGetDados("NVV", 1, xFilial("NVV") + cFatAdic, "NVV_DSPCAS") == '1' //Vrifica se é FA e se Transf as despesas do caso.
Local lResomaFt  := oParams:GetResomaFt() .Or. lDespCaso
Local cTipoExec  := oParams:GetTpExec()
Local dDataEmit  := oParams:GetDEmi()
Local cFilaImpr  := oParams:GetCFilaImpr()
Local cQuery     := ''
Local cQryRes    := GetNextAlias()
Local aConvLanc  := {}
Local nDecimal   := TamSX3('NVY_VALOR')[2]
Local dDataConv  := CToD('  /  /    ')
Local lJConvDep  := SuperGetMv('MV_JCONVDS',, '1' ) == '1'
Local cMoedaNac  := SuperGetMv('MV_JMOENAC',, '01' )
Local cFilEsc    := JurGetDados("NS7", 1, xFilial("NS7") + cEscrit, "NS7_CFILIA")
Local nValor     := 0
Local nValorNac  := 0
Local aRet       := {0,0,0,0}
Local nVlDpTrib  := 0
Local nVlDpReemb := 0

cQuery := "SELECT NVZ.R_E_C_N_O_ NVZRECNO, NVY.R_E_C_N_O_ NVYRECNO "
cQuery += " FROM " + RetSqlName("NVZ") + " NVZ, "
cQuery +=      " " + RetSqlName("NVY") + " NVY "
cQuery += " WHERE NVZ.NVZ_FILIAL = '" + xFilial("NVZ") +"' "
cQuery +=   " AND NVY.NVY_FILIAL = '" + xFilial("NVY") +"' "
cQuery +=   " AND NVZ.NVZ_CDESP = NVY.NVY_COD "
cQuery +=   " AND NVZ.NVZ_CESCR = '" + cEscrit +"' "
cQuery +=   " AND NVZ.NVZ_CFATUR = '" + cFatura +"' "
cQuery +=   " AND NVY.NVY_COBRAR  = '1' "
cQuery +=   " AND NVY.NVY_CCLIEN = '" + cClient +"' "
cQuery +=   " AND NVY.NVY_CLOJA = '" + cLoja +"' "
cQuery +=   " AND NVY.NVY_CCASO = '" + cCaso +"' "
cQuery +=   " AND NVZ.D_E_L_E_T_ = ' ' "
cQuery +=   " AND NVY.D_E_L_E_T_ = ' '"

cQuery := ChangeQuery(cQuery, .F.)
DbCommitAll() //Para efetivar a alteração no banco de dados (não impacta no rollback da transação)
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryRes, .T., .F. )

While !(cQryRes)->(EOF())

	NVY->(Dbgoto((cQryRes)->NVYRECNO))

	If lJConvDep // Verifica a cotação é da Despesa
		dDataConv := oParams:GetDEmi()
	Else
		dDataConv := NVY->NVY_DATA
	EndIf

	aConvLanc := JA201FConv(cMoedaFat, NVY->NVY_CMOEDA, NVY->NVY_VALOR, cTipoExec, dDataConv, cFilaImpr, "", cFilEsc)
	nValor    := nValor + Round(aConvLanc[1], nDecimal)
	nVTAXA1   := aConvLanc[2]
	nVTAXA2   := aConvLanc[3]

	If JurDspTrib(NVY->NVY_CTPDSP, cEscrit)
		nVlDpTrib   += Round(aConvLanc[1], nDecimal)
	Else
		nVlDpReemb  += Round(aConvLanc[1], nDecimal)
	EndIf

	NVZ->(Dbgoto((cQryRes)->NVZRECNO))
	RecLock("NVZ", .F.)
	NVZ->NVZ_COTAC1    := nVTAXA1
	NVZ->NVZ_COTAC2    := nVTAXA2
	If NVZ->(ColumnPos('NVZ_COTAC')) > 0 //Proteção
		NVZ->NVZ_COTAC := JurCotac(nVTAXA1, nVTAXA2)
	EndIf
	NVZ->(MsUnlock())
	NVZ->(DbCommit())

	If lResomaFt
		aConvLanc := JA201FConv(cMoedaNac, NVY->NVY_CMOEDA, NVY->NVY_VALOR, cTipoExec, dDataConv, cFilaImpr, "", cFilEsc)
		nValorNac := nValorNac + Round(aConvLanc[1], nDecimal)
	EndIf

	(cQryRes)->(DbSkip())
EndDo
(cQryRes)->(DbCloseArea())

If lResomaFt
	nValor     := Round(nValor    * nPercPag, TamSX3('NXC_VLDESP')[2])
	nValorNac  := Round(nValorNac * nPercPag, TamSX3('NXC_VLDESP')[2])
	nVlDpTrib  := Round(nVlDpTrib  * nPercPag, TamSX3('NXC_VLDESP')[2])
	nVlDpReemb := Round(nVlDpReemb * nPercPag, TamSX3('NXC_VLDESP')[2])
Else
	aConvLanc := JA201FConv(cMoedaNac, cMoedaPre, (nVDpCaso * nPercPag ), cTipoExec, dDataEmit, cFilaImpr, "", cFilEsc)
	nValorNac := Round(aConvLanc[1], TamSX3('NXC_VLDESP')[2])

	aConvLanc := JA201FConv(cMoedaFat, cMoedaPre, (nVDpCaso * nPercPag ), cTipoExec, dDataEmit, cFilaImpr, "", cFilEsc)
	nValor    := Round(aConvLanc[1], TamSX3('NXC_VLDESP')[2])

	aConvLanc  := JA201FConv(cMoedaFat, cMoedaPre, (nVDpTrip * nPercPag ), cTipoExec, dDataEmit, cFilaImpr, "", cFilEsc)
	nVlDpTrib  := Round(aConvLanc[1], TamSX3('NXC_VLDESP')[2])

	aConvLanc  := JA201FConv(cMoedaFat, cMoedaPre, (nVDpReemb * nPercPag ), cTipoExec, dDataEmit, cFilaImpr, "", cFilEsc)
	nVlDpReemb := Round(aConvLanc[1], TamSX3('NXC_VLDESP')[2])
EndIf

aRet := {nValor, nValorNac, nVlDpTrib, nVlDpReemb}

RestArea(aAreaNVY)
RestArea(aAreaNVZ)
RestArea(aArea)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc}J203HSumTB()
Rotina para fazer a soma dos tabelados na moeda do pagador e moeda nacional, se a fatura a não sofreu rateio
Se for rateio, converte o valor rateado da tabela de casos NXC.

@Param   oParams    Objeto de parâmetros de emissão
@Param   cMoedaPre  Moeda da Pré-Fatura
@Param   cMoedaFat  Moeda da Fatura
@Param   cEscr      Código do Escritório
@Param   cFatura    Código da Fatura
@param   cClient    Código do cliente do caso
@param   cLoja      Código da loja do caso
@param   cCaso      Código do caso
@param   nVTbCaso   Valor do Tabelado no caso
@param   nPercPag   Percentual do Pagador

@author Luciano Pereira dos Santos
@since 14/10/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J203HSumTB(oParams, cMoedaPre, cMoedaFat, cEscrit, cFatura, cClient, cLoja, cCaso, nVTbCaso, nPercPag)
Local aArea      := GetArea()
Local aAreaNV4   := NV4->(GetArea())
Local aAreaNW4   := NW4->(GetArea())
Local lResomaFt  := oParams:GetResomaFt()
Local cTipoExec  := oParams:GetTpExec()
Local dDataEmit  := oParams:GetDEmi()
Local cFilaImpr  := oParams:GetCFilaImpr()
Local cQuery     := ''
Local cQryRes    := GetNextAlias()
Local nDecimal   := TamSX3('NV4_VLHFAT')[2]
Local dDataConv  := CToD('  /  /    ')
Local aConvLanc  := {}
Local cJConvTab  := SuperGetMv('MV_JCONVLT',, '1')
Local cMoedaNac  := SuperGetMv('MV_JMOENAC',, '01')
Local cFilEsc    := JurGetDados("NS7", 1, xFilial("NS7") + cEscrit, "NS7_CFILIA")
Local nValor     := 0
Local nValorNac  := 0
Local aRet       := {0,0}

cQuery := " SELECT NV4.R_E_C_N_O_ NV4RECNO, NW4.R_E_C_N_O_ NW4RECNO "
cQuery += " FROM " + RetSqlName("NW4") + " NW4, "
cQuery +=      " " + RetSqlName("NV4") + " NV4 "
cQuery += " WHERE NW4.NW4_FILIAL = '" + xFilial("NW4") +"' "
cQuery +=   " AND NV4.NV4_FILIAL = '" + xFilial("NV4") +"' "
cQuery +=   " AND NW4.NW4_CLTAB = NV4.NV4_COD "
cQuery +=   " AND NW4.NW4_CESCR = '" + cEscrit +"' "
cQuery +=   " AND NW4.NW4_CFATUR = '" + cFatura +"' "
cQuery +=   " AND NV4.NV4_CCLIEN = '" + cClient +"' "
cQuery +=   " AND NV4.NV4_CLOJA = '" + cLoja +"' "
cQuery +=   " AND NV4.NV4_CCASO = '" + cCaso +"' "
cQuery +=   " AND NW4.D_E_L_E_T_ = ' ' "
cQuery +=   " AND NV4.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery, .F.)
DbCommitAll() //Para efetivar a alteração no banco de dados (não impacta no rollback da transação)
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryRes, .T., .F. )

While !(cQryRes)->(EOF())

	NV4->(Dbgoto((cQryRes)->NV4RECNO))

	If cJConvTab == "1"
		dDataConv := oParams:GetDEmi()
	Else
		If cJConvTab == "2"
			dDataConv := NV4->NV4_DTLANC
		Else
			dDataConv := NV4->NV4_DTCONC
		EndIf
	EndIf

	aConvLanc := JA201FConv(cMoedaFat, NV4->NV4_CMOEH, NV4->NV4_VLHFAT, cTipoExec, dDataConv, cFilaImpr, "", cFilEsc)
	nValor    := nValor + Round(aConvLanc[1], nDecimal)
	nVTAXA1   := aConvLanc[2]
	nVTAXA2   := aConvLanc[3]

	NW4->(Dbgoto((cQryRes)->NW4RECNO))
	RecLock("NW4", .F.)
	NW4->NW4_COTAC1    := nVTAXA1
	NW4->NW4_COTAC2    := nVTAXA2
	If NW4->(ColumnPos('NW4_COTAC')) > 0 //Proteção
		NW4->NW4_COTAC := JurCotac(nVTAXA1, nVTAXA2)
	EndIf
	NW4->(MsUnlock())
	NW4->(DbCommit())

	If lResomaFt
		aConvLanc := JA201FConv(cMoedaNac, NV4->NV4_CMOEH, NV4->NV4_VLHFAT, cTipoExec, dDataConv, cFilaImpr, "", cFilEsc)
		nValorNac := nValorNac + Round(aConvLanc[1], nDecimal)
	EndIf

	(cQryRes)->(DbSkip())
EndDo
(cQryRes)->(DbCloseArea())

If lResomaFt
	nValor    := Round(nValor    * nPercPag, TamSX3('NXC_VLTAB')[2])
	nValorNac := Round(nValorNac * nPercPag, TamSX3('NXC_VLTAB')[2])
Else
	aConvLanc := JA201FConv(cMoedaNac, cMoedaPre, (nVTbCaso * nPercPag), cTipoExec, dDataEmit, cFilaImpr, "" , cFilEsc)
	nValorNac := Round(aConvLanc[1], TamSX3('NXC_VLTAB')[2])

	aConvLanc := JA201FConv(cMoedaFat, cMoedaPre, (nVTbCaso * nPercPag), cTipoExec, dDataEmit, cFilaImpr, "" , cFilEsc)
	nValor    := Round(aConvLanc[1], TamSX3('NXC_VLTAB')[2])
EndIf

aRet := {nValor, nValorNac}

RestArea(aAreaNV4)
RestArea(aAreaNW4)
RestArea(aArea)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc}J203HSumTS
Rotina para fazer a soma os valores dos honoraios na moeda do pagador e moeda nacional, se a fatura a não sofreu rateio.
Se for rateio, converte o valor rateado da tabela de casos NXC.

@Param   oParams    Objeto de parâmetros de emissão
@Param   cMoedaPre  Moeda da Pré-Fatura
@Param   cMoedaFat  Moeda da Fatura
@Param   cEscr      Código do Escritório
@Param   cFatura    Código da Fatura
@param   cClient    Código do cliente do caso
@param   cLoja      Código da loja do caso
@param   cCaso      Código do caso
@param   nVDpCaso   Valor da Despesa no caso
@param   nPercPag   Percentual do Pagador
@param   cContr     Código do contrato

@author Luciano Pereira dos Santos
@since 14/10/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J203HSumTS(oParams, cMoedaPre, cMoedaFat, cEscrit, cFatura, cClient, cLoja, cCaso, nVTSCaso, nPercPag, cContr)
Local aArea      := GetArea()
Local aAreaNXD   := NXD->(GetArea())
Local aAreaNW0   := NW0->(GetArea())
Local lResomaFt  := oParams:GetResomaFt()
Local cTipoExec  := oParams:GetTpExec()
Local dDataEmit  := oParams:GetDEmi()
Local cFilaImpr  := oParams:GetCFilaImpr()
Local cQuery     := ''
Local cQryRes    := GetNextAlias()
Local aConvLanc  := {}
Local nDecimal   := TamSX3('NXD_VLCORR')[2]
Local cMoedaNac  := SuperGetMv('MV_JMOENAC',, '01' )
Local cFilEsc    := JurGetDados("NS7", 1, xFilial("NS7") + cEscrit, "NS7_CFILIA")
Local nValor     := 0
Local nSomaTs    := 0
Local nValorNac  := 0
Local aRet       := {0,0}
Local nMaiorPar  := 0
Local nRecnoPar  := 0
Local nSaldoPart := 0
Local aAtivid    := {}
Local lAtivCobra := .T.

cQuery := " SELECT NUE.NUE_CMOEDA, NUE.NUE_VALOR, NUE_CATIVI, NW0.R_E_C_N_O_ NW0RECNO "
cQuery += " FROM " + RetSqlName("NW0") + " NW0, "
cQuery +=      " " + RetSqlName("NUE") + " NUE "
cQuery += " WHERE NW0.NW0_FILIAL = '" + xFilial("NW0") +"' "
cQuery +=   " AND NUE.NUE_FILIAL = '" + xFilial("NUE") +"' "
cQuery +=   " AND NW0.NW0_CTS = NUE.NUE_COD "
cQuery +=   " AND NW0.NW0_CESCR = '" + cEscrit +"' "
cQuery +=   " AND NW0.NW0_CFATUR = '" + cFatura +"' "
cQuery +=   " AND NUE.NUE_CCLIEN = '" + cClient +"' "
cQuery +=   " AND NUE.NUE_CLOJA = '" + cLoja +"' "
cQuery +=   " AND NUE.NUE_CCASO = '" + cCaso +"' "
cQuery +=   " AND NUE.NUE_COBRAR = '1' "
cQuery +=   " AND NW0.D_E_L_E_T_ = ' ' "
cQuery +=   " AND NUE.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery, .F.)
DbCommitAll() //Para efetivar a alteração no banco de dados (não impacta no rollback da transação)
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryRes, .T., .F. )

While !(cQryRes)->(EOF())
	// Valida se a atividade do TS é cobrável
	lAtivCobra := J201DAtivC((cQryRes)->NUE_CATIVI, cContr, aAtivid)
	
	If lAtivCobra
		If cMoedaFat != (cQryRes)->NUE_CMOEDA .Or. cMoedaFat != cMoedaPre
			aConvLanc := JA201FConv(cMoedaFat, (cQryRes)->NUE_CMOEDA, (cQryRes)->NUE_VALOR, cTipoExec, dDataEmit, cFilaImpr, "")
			NW0->(Dbgoto((cQryRes)->NW0RECNO))
			RecLock("NW0", .F.)
			NW0->NW0_COTAC1    := aConvLanc[2]
			NW0->NW0_COTAC2    := aConvLanc[3]
			If NW0->(ColumnPos('NW0_COTAC')) > 0 //Proteção
				NW0->NW0_COTAC := JurCotac(aConvLanc[2], aConvLanc[3])
			EndIf
			NW0->(MsUnlock())
			NW0->(DbCommit())
			nSomaTs += aConvLanc[1]
		Else
			nSomaTs += (cQryRes)->NUE_VALOR
		EndIf
	EndIf

	(cQryRes)->(DbSkip())
EndDo
(cQryRes)->(DbCloseArea())

NXD->( DbSetOrder(2) ) //NXD_FILIAL, NXD_CFATUR, NXD_CESCR, NXD_CCLIEN, NXD_CLOJA, NXD_CCASO, NXD_CPART, NXD_CSEQ
If NXD->( MsSeek( xFilial("NXD") + cFatura + cEscrit + cClient + cLoja + cCaso ) )

	While ( NXD->(NXD_FILIAL + NXD_CFATUR + NXD_CESCR + NXD_CCLIEN + NXD_CLOJA + NXD_CCASO) == xFilial("NXD") + cFatura + cEscrit + cClient + cLoja + cCaso )

		If cMoedaFat != NXD->NXD_CMOEDT
			aConvLanc := JA201FConv(cMoedaFat, NXD->NXD_CMOEDT, NXD->NXD_VLADVG, cTipoExec, dDataEmit, cFilaImpr, "", cFilEsc)

			RecLock("NXD", .F.)
			NXD->NXD_CMOEDF  := cMoedaFat
			NXD->NXD_VLCORR  := Round(aConvLanc[1], nDecimal )
			NXD->(MsUnlock())
			NXD->( DbCommit() )
		Else
			RecLock("NXD", .F.)
			NXD->NXD_CMOEDF  := cMoedaFat
			NXD->NXD_VLCORR  := NXD->NXD_VLADVG
			NXD->(MsUnlock())
			NXD->( DbCommit() )
		EndIf

		nValor    := nValor + NXD->NXD_VLCORR

		If lResomaFt
			aConvLanc := JA201FConv(cMoedaNac, NXD->NXD_CMOEDT, NXD->NXD_VLADVG, cTipoExec, dDataEmit, cFilaImpr, "", cFilEsc)
			nValorNac := nValorNac + Round(aConvLanc[1], nDecimal)
		EndIf

		If NXD->NXD_VLCORR > nMaiorPar
			nMaiorPar := NXD->NXD_VLCORR
			nRecnoPar := NXD->(Recno())
		EndIf

		NXD->( DbSkip() )

	EndDo

EndIf

If lResomaFt

	nSomaTs := Round(nSomaTs, TamSX3('NXC_VLTS')[2])

	If (nSomaTs != nValor) .And. nRecnoPar > 0  //Ajusta o saldo da mudança de casas decimais
		nSaldoPart := nSomaTs - nValor
		nValor := nSomaTs
		NXD->(DbGoTo(nRecnoPar))
		If !NXD->(EOF())
			RecLock("NXD", .F.)
			NXD->NXD_VLCORR := Round( NXD->NXD_VLCORR + nSaldoPart, TamSX3('NXD_VLCORR')[2])
			NXD->(MsUnlock())
			NXD->(DbCommit())
		EndIf
	EndIf

	nValor    := Round(nValor    * nPercPag , TamSX3('NXC_VLTS')[2])
	nValorNac := Round(nValorNac * nPercPag , TamSX3('NXC_VLTS')[2])
Else
	aConvLanc := JA201FConv(cMoedaNac, cMoedaPre, (nVTSCaso * nPercPag), cTipoExec, dDataEmit, cFilaImpr, "", cFilEsc)
	nValorNac := Round(aConvLanc[1], TamSX3('NXC_VLTS')[2])

	aConvLanc := JA201FConv(cMoedaFat, cMoedaPre, (nVTSCaso * nPercPag), cTipoExec, dDataEmit, cFilaImpr, "", cFilEsc)
	nValor    := Round(aConvLanc[1], TamSX3('NXC_VLTS')[2])
EndIf

aRet := {nValor, nValorNac}

RestArea(aAreaNXD)
RestArea(aAreaNW0)
RestArea(aArea)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc}J203HAjuFX()
Rotina para o faturamento da Fatura adiconal com os valores e cotações da Fatura
@Param   oParams    Objeto de parâmetros de emissão
@Param   cMoedaFat  Moeda da Fatura
@Param   cEscr      Código do Escritório
@Param   cFatura    Código da Fatura
@Param   cContr     Código do contrato da Fatura Adicional
@param   nValorTs   Valor do TimeSheet na Fatura Adicional
@param   nValorTb   Valor do Tabelado na Fatura Adicional
@param   nValorDp   Valor da Despesa na Fatura Adicional

@author Luciano Pereira dos Santos
@since 14/10/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J203HAjuFX(oParams, cMoedaFat, cEscr, cFatura, cContr)
Local aArea     := GetArea()
Local aAreaNWE  := NWE->(GetArea())
Local cTipoExec := oParams:GetTpExec()
Local dDataEmit := oParams:GetDEmi()
Local cFilaImpr := oParams:GetCFilaImpr()
Local cFilEsc   := JurGetDados("NS7", 1, xFilial("NS7") + cEscr, "NS7_CFILIA")
Local cQuery    := ''
Local cQryRes   := GetNextAlias()
Local aConvLanc := {}
Local cMoedaFX  := ''

cQuery := "SELECT NT1.NT1_CMOEDA, NWE.R_E_C_N_O_ NWERECNO "
cQuery += " FROM " + RetSqlName("NWE") + " NWE, "
cQuery +=      " " + RetSqlName("NT1") + " NT1 "
cQuery += " WHERE NWE.NWE_FILIAL = '" + xFilial("NWE") +"' "
cQuery +=   " AND NT1.NT1_FILIAL = '" + xFilial("NT1") +"' "
cQuery +=   " AND NWE.NWE_CFIXO = NT1.NT1_SEQUEN "
cQuery +=   " AND NWE.NWE_CESCR = '" + cEscr +"' "
cQuery +=   " AND NWE.NWE_CFATUR = '" + cFatura +"' "
cQuery +=   " AND NT1.NT1_CCONTR = '" + cContr +"' "
cQuery +=   " AND NWE.D_E_L_E_T_ = ' ' "
cQuery +=   " AND NT1.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery, .F.)
DbCommitAll() //Para efetivar a alteração no banco de dados (não impacta no rollback da transação)
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryRes, .T., .F. )

While !(cQryRes)->(EOF())

	cMoedaFX := (cQryRes)->NT1_CMOEDA

	If Empty(cMoedaFX)
		cMoedaFX := JurGetDados("NT0", 1 , xFilial("NT0") + cContr, "NT0_CMOEF")
	EndIf

	// Atualizar a cotação na NT1
	aConvLanc := JA201FConv(cMoedaFat, cMoedaFX, 1000, cTipoExec, dDataEmit, cFilaImpr, "", cFilEsc)

	NWE->(Dbgoto((cQryRes)->NWERECNO))
	RecLock("NWE", .F.)
	NWE->NWE_CMOEDA    := cMoedaFX
	NWE->NWE_COTAC1    := aConvLanc[2]
	NWE->NWE_COTAC2    := aConvLanc[3]
	If NWE->(ColumnPos('NWE_COTAC')) > 0 //Proteção
		NWE->NWE_COTAC := JurCotac(aConvLanc[2], aConvLanc[3])
	EndIf
	NWE->(MsUnlock())
	NWE->(DbCommit())

	//Grava na fila de sincronização
	J170GRAVA("NT0", xFilial("NT0") + cContr, "4")

	(cQryRes)->(DbSkip())
EndDo
(cQryRes)->(DbCloseArea())

RestArea(aAreaNWE)
RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}J203HAjuFA()
Rotina para o faturamento da Fatura adiconal com os valores e cotações da Fatura

@Param   oParams    Objeto de parâmetros de emissão
@Param   cMoedaFat  Moeda da Fatura
@Param   cEscr      Código do Escritório
@Param   cFatura    Código da Fatura
@Param   cContr     Código do contrato da Fatura Adicional
@param   nValorTs   Valor do TimeSheet na Fatura Adicional
@param   nValorTb   Valor do Tabelado na Fatura Adicional
@param   nValorDp   Valor da Despesa na Fatura Adicional

@author Luciano Pereira dos Santos
@since 14/10/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J203HAjuFA(oParams, cMoedaFat, cEscr, cFatura, cContr, nValorTs, nValorTb, nValorDp)
Local aArea     := GetArea()
Local aAreaNWD  := NWD->(GetArea())
Local cTipoExec := oParams:GetTpExec()
Local dDataEmit := oParams:GetDEmi()
Local cFilaImpr := oParams:GetCFilaImpr()
Local cQuery    := ''
Local cQryRes   := GetNextAlias()
Local cFilEsc   := JurGetDados("NS7", 1, xFilial("NS7") + cEscr, "NS7_CFILIA")
Local aConvLanc := {}
Local nVTAXA1   := 0
Local nVTAXA2   := 0
Local nVTAXA3   := 0
Local nVTAXA4   := 0

cQuery := " SELECT NVV.NVV_CMOE1, NVV.NVV_CMOE2, NVV.NVV_CMOE4, NVV.NVV_DSPCAS, NWD.R_E_C_N_O_ NWDRECNO "
cQuery += " FROM " + RetSqlName("NWD") + " NWD, "
cQuery +=      " " + RetSqlName("NVV") + " NVV "
cQuery += " WHERE NWD.NWD_FILIAL = '" + xFilial("NWD") +"' "
cQuery +=   " AND NVV.NVV_FILIAL = '" + xFilial("NVV") +"' "
cQuery +=   " AND NWD.NWD_CESCR = '" + cEscr +"' "
cQuery +=   " AND NWD.NWD_CFATUR = '" + cFatura +"' "
cQuery +=   " AND NVV.NVV_COD = NWD.NWD_CFTADC "
cQuery +=   " AND NVV.NVV_CCONTR = '" + cContr + "' "
cQuery +=   " AND NWD.D_E_L_E_T_ = ' '"
cQuery +=   " AND NVV.D_E_L_E_T_ = ' '"

cQuery := ChangeQuery(cQuery, .F.)
DbCommitAll() //Para efetivar a alteração no banco de dados (não impacta no rollback da transação)
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryRes, .T., .F. )

While !(cQryRes)->(EOF())

	// Atualizar a cotação na NWD despesas
	If (nValorDp > 0.00) .OR. ((cQryRes)->NVV_DSPCAS == "1")
		aConvLanc := JA201FConv(cMoedaFat, (cQryRes)->NVV_CMOE2, 1000, cTipoExec, dDataEmit, cFilaImpr, "", cFilEsc)
		nVTAXA3   := aConvLanc[2]
		nVTAXA2   := aConvLanc[3]
	Else
		nVTAXA3   := 1.00
	EndIf

	// Atualizar a cotação na NWD Time-Sheets
	If nValorTs > 0.00
		aConvLanc := JA201FConv(cMoedaFat, (cQryRes)->NVV_CMOE1, 1000, cTipoExec, dDataEmit, cFilaImpr, "", cFilEsc)
		nVTAXA1   := aConvLanc[2]
		nVTAXA2   := aConvLanc[3]
	Else
		nVTAXA1   := 1.00
	EndIf

	// Atualizar a cotação na NWD TABELADOS
	If nValorTb > 0.00
		aConvLanc := JA201FConv(cMoedaFat, (cQryRes)->NVV_CMOE4, 1000, cTipoExec, dDataEmit, cFilaImpr, "", cFilEsc)
		nVTAXA4   := aConvLanc[2]
		nVTAXA2   := aConvLanc[3]
	Else
		nVTAXA4   := 1.00
	EndIf

	NWD->(Dbgoto((cQryRes)->NWDRECNO))
	RecLock("NWD", .F.)
	NWD->NWD_COTAC1 := nVTAXA1
	NWD->NWD_COTAC2 := nVTAXA2
	NWD->NWD_COTAC3 := nVTAXA3
	NWD->NWD_COTAC4 := nVTAXA4
	NWD->NWD_VALORH := nValorTs
	NWD->NWD_VALORT := nValorTb
	NWD->NWD_VALORD := nValorDp
	NWD->(MsUnlock())
	NWD->(DbCommit())

	(cQryRes)->(DbSkip())
EndDo

(cQryRes)->(dbCloseArea())

RestArea(aAreaNWD)
RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}J203TxDP()
Rotina para aplicar as taxas / gross up da despesa tributária.

@Param   cEscr      Código do Escritório
@Param   cFatura    Código da Fatura

@author Bruno Ritter / Cris Cintra
@since 20/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J203TxDP(cEscr, cFatura)
Local lDespTrib   := NXC->(ColumnPos('NXC_VLREMB')) > 0
Local aVlTxTrib   := {0,0}

Local nVlNXBGros  := 0
Local nVlNXBTxAd  := 0
Local nVlNXBTotD  := 0
Local nVlNXBDesp  := 0

Local nVlNXAGros  := 0
Local nVlNXATxAd  := 0
Local nVlNXATotD  := 0
Local nVlNXADesp  := 0

If lDespTrib
	NXB->( dbSetOrder(3) ) // NXB_FILIAL+NXB_CESCR+NXB_CFATUR+NXB_CCONTR
	NXB->( MsSeek( xFilial("NXB") + cEscr + cFatura ) )
	While ( NXB->(NXB_FILIAL + NXB_CESCR + NXB_CFATUR) == xFilial("NXB") + cEscr + cFatura)

		NXC->( dbSetOrder(3) ) //NXC_FILIAL+NXC_CESCR+NXC_CFATUR+NXC_CCONTR+NXC_CCLIEN+NXC_CLOJA+NXC_CCASO
		NXC->( MsSeek( xFilial("NXC") + NXB->(NXB_CESCR + NXB_CFATUR + NXB_CCONTR) ) )
		While ( NXC->(NXC_FILIAL + NXC_CESCR + NXC_CFATUR + NXC_CCONTR) == xFilial("NXC") + NXB->(NXB_CESCR + NXB_CFATUR + NXB_CCONTR) )
			RecLock("NXC", .F.)
			aVlTxTrib := JurTxTrib(NXC->NXC_VLTRIB, cEscr, cFatura)
			NXC->NXC_VLGROS := Round( ( aVlTxTrib[1] ), TamSX3('NXC_VLGROS')[2])
			NXC->NXC_VLTXAD := Round( ( aVlTxTrib[2] ), TamSX3('NXC_VLTXAD')[2])
			NXC->NXC_VLTOTD := NXC->NXC_VLTRIB + NXC->NXC_VLGROS + NXC->NXC_VLTXAD
			NXC->NXC_VLDESP := NXC->NXC_VLTOTD + NXC->NXC_VLREMB
			NXC->NXC_VLDFAT := NXC->NXC_VLTOTD + NXC->NXC_VLREMB

			NXC->(MsUnlock())
			NXC->(DbCommit())

			nVlNXBGros += NXC->NXC_VLGROS
			nVlNXBTxAd += NXC->NXC_VLTXAD
			nVlNXBTotD += NXC->NXC_VLTOTD
			nVlNXBDesp += NXC->NXC_VLDESP

			NXC->(DbSkip())
		EndDo //NXC

		RecLock("NXB", .F.)
		NXB->NXB_VLGROS := nVlNXBGros
		NXB->NXB_VLTXAD := nVlNXBTxAd
		NXB->NXB_VLTOTD := nVlNXBTotD
		NXB->NXB_VLFATD := nVlNXBDesp
		NXB->(MsUnlock())
		NXB->(DbCommit())

		nVlNXAGros += nVlNXBGros
		nVlNXATxAd += nVlNXBTxAd
		nVlNXATotD += nVlNXBTotD
		nVlNXADesp += nVlNXBDesp

		nVlNXBGros := 0
		nVlNXBTxAd := 0
		nVlNXBTotD := 0
		nVlNXBDesp := 0

		NXB->(DbSkip())
	EndDo //NXB

	RecLock("NXA", .F.)
	NXA->NXA_VLGROS := nVlNXAGros
	NXA->NXA_VLTXAD := nVlNXATxAd
	NXA->NXA_VLTOTD := nVlNXATotD
	NXA->NXA_VLFATD := nVlNXADesp
	NXA->NXA_VLORID := nVlNXADesp
	NXA->(MsUnlock())
	NXA->( DbCommit() )
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc}TratMailEn()
Verifica se deve realizar o envio da fatura ou não.

@Param   cTpEnv   Tipo de Envio 
		"1" - Sim todas as faturas
		"2" - Não envia
		"3" - Somente se tiver valor de honorarios
		"4" - Somente se tiver valor de despesas
@Param   nVlHonor    Valor dos Honorarios
@Param   nVlDesp     Valor das Despesas
@Param   cEnvia      Valor do campo envia 
@Param   cNaoEnvia    Valor do campo não envia 
@author fabiana.silva
@since 15/04/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TratMailEn(cTpEnv, nVlHonor, nVlDesp, cEnvia, cNaoEnvia) 
Local cRet := cEnvia //Envia e-mail

If Empty(cTpEnv) .OR. cTpEnv == "2" .OR. ;
		(cTpEnv == "3" .AND. nVlHonor == 0) .OR. ;
		(cTpEnv == "4" .AND. nVlDesp == 0)
		cRet := cNaoEnvia
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J203ImpRet
Relação de Titulos a Receber com Retenção IR / PIS / COFINS e CSLL que
serão considerados na regra de cumulatividade.

@author Abner Fogaça de Oliveira
@since  08/04/2022
/*/
//-------------------------------------------------------------------
Static Function J203ImpRet()
Local lRetImp    := NXA->(ColumnPos("NXA_FATACU")) > 0 // @12.1.2210
Local lAcumIRF   := SuperGetMV("MV_ACMIRCR", .F., "1") == "1" // Define se acumula o valor minimo do imposto IRRF. 1 = Acumula (Default) ou 2 = Não Acumula          
Local lAcumPCC   := SuperGetMV("MV_VL13137", .F., 10) > 0      // Define o valor mínimo para retenção do PIS, COFINS e CSLL
Local lRetIR     := .F.
Local lRetPCC    := .F.
Local cLog       := ""
Local cAliasQry  := ""
Local cSufixoImp := ""

	If	lRetImp .And. NXA->(NXA_IRRF + NXA_PIS + NXA_COFINS + NXA_CSLL) > 0 .And. (lAcumIRF .Or. lAcumPCC)
		cAliasQry := GetNextAlias()
		cAliasQry := QryFatAcu(cAliasQry, cFilAnt) // Query que retorna os títulos que estão dentro do mesmo período de retenção.
		While !(cAliasQry)->(Eof())
			lRetIR  := (cAliasQry)->E1_VRETIRF > 0
			lRetPCC := (cAliasQry)->(CALCPCC) == 'S'
			If lRetIR .And. !lRetPCC
				cSufixoImp := " - IR"
			ElseIf lRetPCC .And. !lRetIR
				cSufixoImp := " - PCC"
			ElseIf lRetPCC .And. lRetIR
				cSufixoImp := " - IR + PCC"
			EndIf
			If lRetIR .Or. lRetPCC
				cLog += Alltrim((cAliasQry)->NXA_CESCR) + "/" + (cAliasQry)->E1_NUM + cSufixoImp + CRLF
			EndIf
			(cAliasQry)->(DbSkip())
		Enddo
		If !Empty(cLog)
			RecLock("NXA", .F.)
			NXA->NXA_FATACU := cLog
			NXA->(MsUnlock())
		EndIf
		(cAliasQry)->(DbCloseArea())
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} QryFatAcu
Relação de Titulos a Receber com Retenção PIS / COFINS e CSLL

@author Abner Fogaça de Oliveira
@since  08/04/2022
/*/
//-------------------------------------------------------------------
Static Function QryFatAcu(cAliasQry, cFilQry)
Local nTamFil   := TamSX3("NXA_FILIAL")[1]
Local nTamEsc   := TamSX3("NXA_CESCR")[1]
Local nIniEscr  := nTamFil + 2
Local cDtCorte  := ""
Local cAux      := ""
Local cAuxPcc   := ""
Local cDtEmiFat := DtoS(NXA->NXA_DTEMI)
Local cDtVencto := DtoS(DataValida(NXA->NXA_DTVENC, .T.))
Local cTipoTit  := MVTAXA + "|" + MVPROVIS + "|" + MVABATIM + "|" + "PR|PRE" + MVRECANT
Local cDataPCC  := cValToChar(SuperGetMV("MV_VCPCCR", .F., "1")) // Data que será considerada para a cumulatividade do PCC (1 = Emissão / 2 = Vencto Real / 3 = Data Contab)
Local cDataIRF  := SuperGetMV("MV_ACMIRPF", .F., "1")            // Data que será considerada para a cumulatividade do IRPF (1 = Emissão / 2 = Vencto Real / 3 = Data Contab)
Local cDataIRJ  := SuperGetMV("MV_ACMIRPJ", .F., "1")            // Data que será considerada para a cumulatividade do IRPJ (1 = Emissão / 2 = Vencto Real / 3 = Data Contab)

	cTipoTit := Alltrim(Formatin(cTipoTit, Iif("|" $ cTipoTit, "|", ",")))
	cTipoTit := SubStr(cTipoTit, At("'", cTipoTit, 1) + 1,  Len(cTipoTit))
	cTipoTit := SubStr(cTipoTit, 1, Rat("'", cTipoTit) - 1)

	If (NXA->(NXA_PIS + NXA_COFINS + NXA_CSLL) > 0 .And. cDataPCC == "1") .Or. (NXA->NXA_IRRF > 0 .And.  cDataIRF == "1") .Or. (NXA->NXA_IRRF > 0 .And. cDataIRJ == "1") // 1=Emissao
		cDtCorte += " AND (SE1.E1_EMISSAO = '" + cDtEmiFat + "'
		cAuxPcc  := " AND SE1.E1_EMISSAO = '" + cDtEmiFat + "'
	EndIf
	If (NXA->(NXA_PIS + NXA_COFINS + NXA_CSLL) > 0 .And. cDataPCC == "2") .Or. (NXA->NXA_IRRF > 0 .And.  cDataIRF == "2") .Or. (NXA->NXA_IRRF > 0 .And. cDataIRJ == "2") // 2=Venc.Real
		cDtCorte += IIf(Empty(cDtCorte), " AND (", " OR")
		cDtCorte += " SE1.E1_VENCREA = '" + cDtVencto + "'
		cAuxPcc  := " AND SE1.E1_VENCREA = '" + cDtVencto + "'
	EndIf
	If (NXA->(NXA_PIS + NXA_COFINS + NXA_CSLL) > 0 .And. cDataPCC == "3") .Or. (NXA->NXA_IRRF > 0 .And.  cDataIRF == "3") .Or. (NXA->NXA_IRRF > 0 .And. cDataIRJ == "3") // 3=Dt Contab.
		cDtCorte += IIf(Empty(cDtCorte), " AND (", " OR")
		cDtCorte += " (SE1.E1_EMIS1 = '" + cDtEmiFat + "' AND SE1.E1_LA = 'S')"
		cAuxPcc  := " AND SE1.E1_EMIS1 = '" + cDtEmiFat + "'
	EndIf

	cDtCorte += IIf(Empty(cDtCorte), "", ")")
	cAux    := '%' + cDtCorte + '%'
	cAuxPcc := '%' + cAuxPcc  + '%'

	BEGINSQL ALIAS cAliasQry
        COLUMN E1_EMISSAO AS DATE
        COLUMN E1_VENCREA AS DATE

        SELECT SE1.E1_NUM, NXA.NXA_CESCR, SUM(SE1.E1_VRETIRF) E1_VRETIRF, 
               CASE WHEN (SA1.A1_RECPIS  IN ('S','P') AND SED.ED_CALCPIS = 'S' %Exp:cAuxPcc%)
                      OR (SA1.A1_RECCOFI IN ('S','P') AND SED.ED_CALCCOF = 'S' %Exp:cAuxPcc%)
                      OR (SA1.A1_RECCSLL IN ('S','P') AND SED.ED_CALCCSL = 'S' %Exp:cAuxPcc%)
                    THEN 'S'
                    ELSE 'N'
                END CALCPCC
          FROM %table:SE1% SE1
         INNER JOIN %Table:NXA% NXA
            ON (NXA.NXA_FILIAL = SUBSTRING(SE1.E1_JURFAT, 1, %Exp:nTamFil%)
           AND NXA.NXA_CESCR = SUBSTRING(SE1.E1_JURFAT, %Exp:nIniEscr%, %Exp:nTamEsc%)
           AND NXA.NXA_COD = SE1.E1_NUM
           AND NXA.NXA_SITUAC = 1
           AND (NXA.NXA_VLFATH > 0 OR NXA.NXA_VLTRIB > 0)
           AND NXA.D_E_L_E_T_ = ' ')
         INNER JOIN %Table:SA1% SA1
            ON (SA1.A1_FILIAL = %xFilial:SA1%
           AND SA1.A1_COD = SE1.E1_CLIENTE
           AND SA1.A1_LOJA = SE1.E1_LOJA
           AND SA1.%NotDel%)
         INNER JOIN %Table:SED% SED
            ON (SED.ED_FILIAL = %xFilial:SED%
           AND SED.ED_CODIGO = SE1.E1_NATUREZ
           AND SED.%NotDel%)
         WHERE SE1.E1_FILORIG = %Exp:cFilQry%
           AND SE1.E1_CLIENTE = %Exp:NXA->NXA_CLIPG%
           AND SE1.E1_LOJA = %Exp:NXA->NXA_LOJPG%
           AND SE1.E1_NUM NOT IN (%Exp:NXA->NXA_COD%)
           AND SE1.E1_TIPO NOT IN (%Exp:cTipoTit%)
           %Exp:cAux%
           AND SE1.%NotDel%
         GROUP BY SE1.E1_NUM, NXA.NXA_CESCR,
               CASE WHEN (SA1.A1_RECPIS  IN ('S','P') AND SED.ED_CALCPIS = 'S' %Exp:cAuxPcc%)
                      OR (SA1.A1_RECCOFI IN ('S','P') AND SED.ED_CALCCOF = 'S' %Exp:cAuxPcc%)
                      OR (SA1.A1_RECCSLL IN ('S','P') AND SED.ED_CALCCSL = 'S' %Exp:cAuxPcc%)
                       THEN 'S'
                       ELSE 'N'
                   END
         ORDER BY SE1.E1_NUM, NXA.NXA_CESCR
	ENDSQL

	DbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())

Return (cAliasQry)

//-------------------------------------------------------------------
/*/{Protheus.doc}J203HGrsHon
Calcula o valor de Gross Up de honorários.

@param  cGrossHon , Tipo do Gross Up de honorários
                    1 - Não se aplicar
                    2 - Impostos
                    3 - Percentual Fixo
@param  nPercGrHon, Quando a opção do tipo de Gross Up for
                    igual a 3 entao considera o percentual fixo cadastrado

@return nValGrsHon, Valor do Gross Up de honorários

@author Jonatas Martins / Jorge Martins
@since  27/07/2022
/*/
//-------------------------------------------------------------------
Static Function J203HGrsHon(cGrossHon, nPercGrHon)
Local nValGross := 0
Local cMoeNac   := SuperGetMv("MV_JMOENAC",, "01")

	If cGrossHon == "2" // Gross Up de Honorários cosiderando o valor de Impostos
		nValGross := IIF(NXA->NXA_CMOEDA == cMoeNac, J203HGrsImp(), 0) // Não tem imposto para fatura com moeda estrangeira
	ElseIf cGrossHon == "3" .And. nPercGrHon > 0 // Gross Up Honorários com percentual fixo
		nValGross := Round(((NXA->NXA_VLFATH + NXA->NXA_VLACRE - NXA->NXA_VLDESC) * nPercGrHon / 100), TamSX3('NXA_VGROSH')[2])
	EndIf

Return (nValGross)

//-------------------------------------------------------------------
/*/{Protheus.doc}J203HGrsImp
Calcula o valor de Gross Up de honorários considerando os impostos,
simulando a geração do título a receber.

@return nValGrsImp, Valor do Gross Up de honorários considerando impostos

@author Jonatas Martins
@since  02/08/2022
/*/
//-------------------------------------------------------------------
Static Function J203HGrsImp()
Local aValImp     := {0, 0, 0, 0, 0, 0}
Local aAliquotas  := {}
Local nValHon     := 0
Local nValHonAcum := 0
Local nTotImp     := 0
Local nTotAliq    := 0
Local nValGrsImp  := 0
Local cFilEscr    := ""
Local cCondPag    := ""

	cFilEscr   := JurGetDados("NS7", 1, xFilial("NS7") + NXA->NXA_CESCR, "NS7_CFILIA")
	cCondPag   := JurGetDados("NXG", 3, xFilial("NXG") + NXA->NXA_CFILA + NXA->NXA_CLIPG + NXA->NXA_LOJPG, "NXG_CCDPGT")
	nValHon    := NXA->NXA_VLFATH + NXA->NXA_VLTOTD + NXA->NXA_VLACRE - NXA->NXA_VLDESC
	aAliquotas := JA201CPerc(NXA->NXA_CLIPG, NXA->NXA_LOJPG, NXA->NXA_CMOEDA, NXA->NXA_DTEMI, nValHon, cCondPag, cFilEscr, @aValImp)
	
	AEVal(aValImp, {|nImp| nTotImp += nImp})

	If nTotImp > 0
		AEVal(aAliquotas, {|nAliq| nTotAliq += nAliq})

		// Calculo para obter valor de honorários de faturas com impostos acumulados
		nValHonAcum := nTotImp / (nTotAliq / 100)
		nValGrsImp  := Round(nValHonAcum / (1 - (nTotImp / nValHonAcum)) - nValHonAcum, GetSX3Cache("NXA_VGROSH", "X3_DECIMAL"))

		// Refaz a simulação acrescentando o valor de Gross Up
		JurFreeArr(aValImp)
		aValImp := {0, 0, 0, 0, 0, 0}

		JA201CPerc(NXA->NXA_CLIPG, NXA->NXA_LOJPG, NXA->NXA_CMOEDA, NXA->NXA_DTEMI, nValHon + nValGrsImp, cCondPag, cFilEscr, @aValImp)
		
		nValGrsImp := 0
		AEVal(aValImp, {|nImp| nValGrsImp += nImp})
	EndIf

	JurFreeArr(aAliquotas)
	JurFreeArr(aValImp)

Return (nValGrsImp)

//-------------------------------------------------------------------
/*/{Protheus.doc} J203HGrsCas()
Rotina para aplicar percentual de Gross Up de Honorários por Caso.

@Param  cEscr  , Código do Escritório
@Param  cFatura, Código da Fatura

@author Reginaldo Borges / Jorge Martins
@since  26/08/2022
/*/
//-------------------------------------------------------------------
Static Function J203HGrsCas(cEscr, cFatura)
Local lGrosHonCas := NXC->(ColumnPos('NXC_VGROSH')) > 0 // @12.1.2310
Local nVlNXBGros  := 0
Local nTamVGrosh  := 0
Local nRecnoNXC   := 0
Local nRecnoNXB   := 0
Local nVlGrosAcu  := 0

	If lGrosHonCas
		nTamVGrosh := TamSX3("NXC_VGROSH")[2]
		NXB->(dbSetOrder(3)) // NXB_FILIAL+NXB_CESCR+NXB_CFATUR+NXB_CCONTR
		NXB->(MsSeek( xFilial("NXB") + cEscr + cFatura ) )
		While (NXB->(NXB_FILIAL + NXB_CESCR + NXB_CFATUR) == xFilial("NXB") + cEscr + cFatura)
			nVlNXBGros := 0

			NXC->(dbSetOrder(3)) // NXC_FILIAL+NXC_CESCR+NXC_CFATUR+NXC_CCONTR+NXC_CCLIEN+NXC_CLOJA+NXC_CCASO
			NXC->(MsSeek( xFilial("NXC") + NXB->(NXB_CESCR + NXB_CFATUR + NXB_CCONTR)))
			While (NXC->(NXC_FILIAL + NXC_CESCR + NXC_CFATUR + NXC_CCONTR) == xFilial("NXC") + NXB->(NXB_CESCR + NXB_CFATUR + NXB_CCONTR))
				RecLock("NXC", .F.)
				NXC->NXC_VGROSH := Round((NXC->(NXC_VLTS + NXC_VFIXO + NXC_VLTAB + NXC_VLTOTD) / NXA->(NXA_VLFATH + NXA_VLTOTD)) * NXA->NXA_VGROSH, nTamVGrosh)
				NXC->(MsUnlock())
				NXC->(DbCommit())

				nVlNXBGros += NXC->NXC_VGROSH
				nVlGrosAcu += NXC->NXC_VGROSH // Valor de gross up acumulado

				nRecnoNXC := NXC->(Recno())
				NXC->(DbSkip())
			EndDo // NXC

			RecLock("NXB", .F.)
			NXB->NXB_VGROSH := nVlNXBGros
			NXB->(MsUnlock())
			NXB->(DbCommit())

			nRecnoNXB := NXB->(Recno())
			NXB->(DbSkip())
		EndDo // NXB

		If nVlGrosAcu <> NXA->NXA_VGROSH
			NXC->(DbGoto(nRecnoNXC))
			RecLock("NXC", .F.)
			NXC->NXC_VGROSH += (NXA->NXA_VGROSH - nVlGrosAcu)
			NXC->(MsUnlock())
			NXC->(DbCommit())

			NXB->(DbGoto(nRecnoNXB))
			RecLock("NXB", .F.)
			NXB->NXB_VGROSH += (NXA->NXA_VGROSH - nVlGrosAcu)
			NXB->(MsUnlock())
			NXB->(DbCommit())
		EndIf
	EndIf

Return Nil
