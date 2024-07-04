#INCLUDE "PROTHEUS.CH"
#INCLUDE "JURA201D.CH"

//TIPO EXEC = 1 (EMISSÃO DE PRÉ)

//-------------------------------------------------------------------
/*/{Protheus.doc} JA201DCaso
Rotina para Totalizar os Valores do Caso e Gravar na NX1.

@author David G. Fernandes
@since 19/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA201DCaso(oParams, cCodPre, cMoedPF, cCodFAd, cCodJun, cCodContr, cCodFixo)
Local aRet         := {.T., "JA201DCaso"}
Local cQueryCaso   := ""
Local aArea        := GetArea()
Local cQryRes      := GetNextAlias()
Local lAtivNaoC    := SuperGetMV( 'MV_JURTS4',, .F. ) //Permite zerar o tempo revisado de atividades não cobráveis? .T. - Permite; .F. - Não Permite.

Local cNT0COD      := ""
Local nNT0VLRBAS   := 0

Local cNX1TS       := ""
Local cNX1DESP     := ""
Local cNX1LANTA    := ""
Local CNX1CPART    := ""
Local CNX1CTPREL   := ""

//Comuns
Local dDataConv    := CToD('  /  /  ')
Local nVVALORTEMP  := 0
Local nVTAXA1      := 0
Local nVTAXA2      := 0

/* Variáveis para o cálculo do Time-Sheet */
Local cQueryTS     := ""
Local cQryResTS    := GetNextAlias()
Local cAMRec       := Substr(SuperGetMV( "MV_JRECTS",, "0000-00" ), 0, 4) + Substr(SuperGetMV( "MV_JRECTS",, "0000-00" ), 6, 2)
Local aRecTS       := {}
Local aConvLanc    := {}
Local nNUEVALOR    := 0
Local nNUEVALORH   := 0
Local cNUEMOEDA    := ""
Local nVSOMATS     := 0
Local nVSOMATSTAB  := 0
Local nVSOMATSVINC := 0
Local nNUECATEG    := ""
Local lFatAtiva    := .F.

//Participante
Local cQueryPar    := ""
Local cQryResPar   := GetNextAlias()
Local nUTCli       := 0
Local nHrFracCli   := 0
Local nUTLanc      := 0
Local nHrFracLan   := 0
Local nUTRev       := 0
Local nHrFracRev   := 0
Local cHoraMinC    := '0000:00'
Local cHoraMinL    := '0000:00'
Local cHoraMinR    := '0000:00'

/* Variáveis para o cálculo da Despesa */
Local cQueryDP     := ""
Local cQryResDP    := GetNextAlias()
Local nVSOMADESP   := 0

Local cQueryLT     := ""
Local cQryResLT    := GetNextAlias()
Local nVSOMALTAB   := 0
Local nVSOMALTVINC := 0
Local cFatura      := ""
Local cEscr        := ""
Local cTEMTS       := ""
Local cTEMDP       := ""
Local cTEMLT       := ""
Local cTEMFX       := ""
Local cTEMFA       := ""
Local cTEMLM       := ""
Local nContaTS     := 0
Local nContaDP     := 0
Local nContaTB     := 0
Local cSituac      := ""
Local nNVEDESPAD   := 0
Local nPDescLin    := 0
Local nVDescEsp    := 0
Local nPos         := 0
Local aCaso        := {}
Local aCasosNew    := {}
Local nVDescLin    := 0
Local aTabVinc     := {{"", 0}}
Local nCobMaior    := 0
Local cTSREV       := "2"
Local cDPREV       := "2"
Local cTBREV       := "2"

Local lTSData1    := .F.
Local lDPData1    := .F.
Local lLTData     := .F.
Local nI          := 0
Local cRedac      := ''
Local cTpDesc     := ''
Local nPDescEsp   := 0
Local cTpHon      := ""
Local cCobH       := ""
Local cCobF       := ""
Local lVincTS     := .F.
Local cConvLT     := SuperGetMv( "MV_JCONVLT",, "1" )
Local cConvDS     := SuperGetMv( "MV_JCONVDS",, "1" )
Local cCodFImp    := ''
Local cTpExec     := ''

Local nTempoRev   := 0
Local cHoraRev    := ''
Local nUtTsRev    := 0

Local nDecTsCas   := 0
Local nDecValor   := 0
Local nDecValor1  := 0
Local nDecValHr   := 0
Local nDecParAdv  := 0
Local nDecParVlr  := 0
Local nDecDesp    := 0
Local nDecLTCas   := 0
Local nDecTab     := 0

Local cMoeNac     := SuperGetMv('MV_JMOENAC',, '01' )
Local aTotTpDp    := {}
Local nVlTpDesp   := 0
Local nTSCaso     := 0
Local nMaiorPar   := 0
Local nRecnoPar   := 0
Local nTotalPar   := 0

Local aAtivid     := {}
Local cHoraNaoC   := Transform(PADL("0", TamSX3('NUE_HORAR')[1], '0'), PesqPict("NUE", "NUE_HORAR"))

Local lDespTrib   := NXC->(ColumnPos('NXC_VLREMB')) > 0
Local nVlDpTrib   := 0
Local nVlDpReemb  := 0
Local cEscrit     := ""

Local cMoelim     := ""
Local nVlrLim     := 0
Local nVIniLim    := 0
Local cFaCLim     := ""
Local cTbCLim     := ""
Local nUtLimite   := 0
Local nHonLimite  := 0
Local nSaldoUtil  := 0
Local nDescLimite := 0
Local aLimite     := {}
Local lDataVinc   := (oParams:GetTpExec() $ "3|4|5|MS") .And. NW0->(ColumnPos('NW0_DTVINC')) > 0 //Regra + Proteção
Local cAnoMesVin  := ""
Local aCampos     := {}
Local aPart       := {}
Local lInclui     := .F.
Local lAltHr      := NUE->(ColumnPos('NUE_ALTHR')) > 0
Local aDivTS      := {}
Local nDivTS      := 1
Local cJurUser    := JurUsuario(__CUSERID)
Local cNXDSeq     := ""
Local lAdiHon     := .F.
Local lAdiDsp     := .F.
Local nSldAdi     := 0
Local lSldAdi     := NX1->(ColumnPos('NX1_VSLDAD')) > 0 //Proteção
Local dMenorDt    := Ctod("")
Local dMaiorDt    := Ctod("")
Local cChaveOld   := ""
Local lIncFila    := .F.
Local lEmiPre     := oParams:GetTpExec() == "1" // Emissão de pré
Local lCpoFxNc    := NX0->(ColumnPos('NX0_FXNC')) > 0 // @12.1.2210 - Proteção para campo de contratos fixos ou não cobráveis
Local lTSNCobra   := SuperGetMV( 'MV_JTSNCOB',, .F. ) // Indica se vincula TimeSheet não cobrável na emissão
Local nVTSNCobra  := 0 // Valor de TimeSheet não cobrável na Pré-Fatura quando o parâmetro MV_JTSNCOB está habilitado
Local lTemJunc    := .F.
Local lFxNC       := lCpoFxNc .And. oParams:GetFltrFxNc() // Indica se é uma pré de TS de contratos fixos ou não cobráveis

Default cCodFixo  := ""

If oParams:GetTpExec() $ "3|4|5|MS"    //Minuta / Emissão de Fatura
	cFatura    := oParams:GetMarkFat()
	cEscr      := oParams:GetMarkEsc()
	nDecTsCas  := TamSX3('NXC_VLTS'  )[2]
	nDecDPCas  := TamSX3('NXC_VLDESP')[2]
	nDecLTCas  := TamSX3('NXC_VLTAB' )[2]
	nDecHon    := TamSX3('NXC_VLHFAT')[2]

	nDecParAdv := TamSX3('NXD_VLADVG')[2]
	nDecParVlr := TamSX3('NXD_VLCORR')[2]

Else
	cFatura    := IIf(Empty(oParams:GetCodFatur()), Space(TamSX3('NXA_COD')[1])  , oParams:GetCodFatur() )
	cEscr      := IIf(Empty(oParams:GetCodEscr()) , Space(TamSX3('NXA_CESCR')[1]), oParams:GetCodEscr()  )
	nDecTsCas  := TamSX3('NX1_VTS'  )[2]
	nDecDPCas  := TamSX3('NX1_VDESP')[2]
	nDecLTCas  := TamSX3('NX1_VTAB' )[2]
	nDecHon    := TamSX3('NX1_VHON' )[2]

	nDecParAdv := TamSX3('NX2_VLHTBH')[2]
	nDecParVlr := TamSX3('NX2_VALOR1')[2]
EndIf

nDecValor   := TamSX3('NUE_VALOR' )[2]
nDecValor1  := TamSX3('NUE_VALOR1')[2]
nDecValHr   := TamSX3('NUE_VALORH')[2]
nDecDesp    := TamSX3('NVY_VALOR' )[2]
nDecTab     := TamSX3('NV4_VLHFAT')[2]

If oParams:GetTpExec() $ "2|6"

	oParams:PtInternal(STR0018) // "Emitindo - Totaliza Caso - Se for Reimpressão apaga anteriores"
	//Se for reimpressão apaga os anteriores e inclui novamente.

	NX2->(dbSetOrder(1))  //NX2_FILIAL+NX2_CPREFT+NX2_CPART+NX2_CCLIEN+NX2_CLOJA+NX2_CCONTR+NX2_CCASO+NX2_CODSEQ
	If NX2->(DbSeek( xFilial("NX2") + cCodPre ) )
		While (NX2->(NX2_FILIAL + NX2_CPREFT) == xFilial("NX2") + cCodPre )
			RecLock("NX2", .F., .F., .F., .T.)
			NX2->(DbDelete())
			NX2->(MsUnlock())
			NX2->(DbSkip())
		EndDo
	EndIf

	If oParams:GetTpExec() == "2"
		J201DCotPag(cCodPre, oParams:GetDEmi() )  //Insere as cotações dos pagadores com base na data de emissão
		J201DAtuCot(cCodPre, oParams:GetDEmi() )  //Atualiza as cotações da pré com base na data de emissão
	EndIf

EndIf

If !Empty(cCodJun) .And. Empty(cCodFAd) .And. oParams:GetTpExec() == "1"
	//Verifica a menor data para filtrar as parcelas de fixo:
	If !Empty(oParams:GetDIniH())
		If Empty(dMenorDt) .Or. (dMenorDt < oParams:GetDIniH())
			dMenorDt := oParams:GetDIniH()
		EndIf
	EndIf
	//Verifica a maior data para filtrar as parcelas:
	If !Empty(oParams:GetDFinH())
		If Empty(dMaiorDt) .Or. (dMaiorDt < oParams:GetDFinH())
			dMaiorDt := oParams:GetDFinH()
		EndIf
	EndIf
EndIf

If Empty(cCodFAd)

	If oParams:GetTpExec() == "1" // Emissão de Pré-Fatura

		// Query dos Casos
		cQueryCaso := " SELECT NT0.NT0_CESCR CCESC, NT0.NT0_COD CCONTR, A.CCLIEN, A.CLOJA, A.CCASO, NT0.NT0_VLRBAS VLRBAS,"
		If oParams:GetSituac() <> "1" // Não é conferência
			cQueryCaso +=    IIF(lFxNC, " '1' TEMTS, ", " MIN(CASE WHEN NRA.NRA_COBRAH = '1' THEN  A.TEMTS ELSE '2' END) TEMTS, ") // Flag de Contrato Fixo ou Não Cobrável só considera TS
			cQueryCaso +=    " MIN(CASE WHEN NT0.NT0_DESPES = '1' THEN  A.TEMDP ELSE '2' END) TEMDP, "
			cQueryCaso +=    " MIN(CASE WHEN NT0.NT0_SERTAB = '1' THEN  A.TEMLT ELSE '2' END) TEMLT, "
		Else
			cQueryCaso +=    " MIN(A.TEMTS) TEMTS, "
			cQueryCaso +=    " MIN(A.TEMDP) TEMDP, "
			cQueryCaso +=    " MIN(A.TEMLT) TEMLT, "
		EndIf
		cQueryCaso +=        " MIN(A.TEMFX) TEMFX, "
		cQueryCaso +=        " MIN(A.TEMFA) TEMFA, "
		cQueryCaso +=        " MIN(A.TEMLM) TEMLM  "
		cQueryCaso +=   " FROM ( SELECT NUE.NUE_CCLIEN CCLIEN, NUE.NUE_CLOJA CLOJA, NUE.NUE_CCASO CCASO, "
		cQueryCaso +=                 " '1' TEMTS, "
		cQueryCaso +=                 " '2' TEMDP, "
		cQueryCaso +=                 " '2' TEMLT, "
		cQueryCaso +=                 " '2' TEMFX, "
		cQueryCaso +=                 " '2' TEMFA, "
		cQueryCaso +=                 " '2' TEMLM  "
		cQueryCaso +=            " FROM " + RetSqlName("NUE") + " NUE "
		cQueryCaso +=           " WHERE NUE.NUE_FILIAL = '" + xFilial("NUE") +"' "
		If oParams:GetSituac() <> "1"
			cQueryCaso +=         " AND NUE.NUE_CPREFT = '" + cCodPre +"' "
		Else // Conferência
			cQueryCaso +=         " AND EXISTS ( SELECT NW0a.R_E_C_N_O_ "
			cQueryCaso +=                        " FROM " + RetSqlName("NW0") + " NW0a "
			cQueryCaso +=                       " WHERE NW0a.NW0_FILIAL = '" + xFilial("NW0") +"' "
			cQueryCaso +=                         " AND NW0a.NW0_PRECNF = '" + cCodPre +"' "
			cQueryCaso +=                         " AND NW0a.NW0_SITUAC = '1' "
			cQueryCaso +=                         " AND NW0a.NW0_CANC = '2' "
			cQueryCaso +=                         " AND NW0a.D_E_L_E_T_ = ' ' "
			cQueryCaso +=                         " AND NW0a.NW0_CTS = NUE.NUE_COD "
			cQueryCaso +=                     ")"
		EndIf
		cQueryCaso +=             " AND NUE.D_E_L_E_T_ = ' ' "
		cQueryCaso +=           " UNION ALL "
		cQueryCaso +=          " SELECT NV4.NV4_CCLIEN CCLIEN, NV4.NV4_CLOJA CLOJA, NV4.NV4_CCASO CCASO, "
		cQueryCaso +=                 " '2' TEMTS, "
		cQueryCaso +=                 " '2' TEMDP, "
		cQueryCaso +=                 " '1' TEMLT, "
		cQueryCaso +=                 " '2' TEMFX, "
		cQueryCaso +=                 " '2' TEMFA, "
		cQueryCaso +=                 " '2' TEMLM  "
		cQueryCaso +=            " FROM " + RetSqlName("NV4") + " NV4 "
		cQueryCaso +=           " WHERE NV4.NV4_FILIAL = '" + xFilial("NV4") +"' "
		If oParams:GetSituac() <> "1"
			cQueryCaso +=         " AND NV4.NV4_CPREFT = '" + cCodPre +"' "
		Else
			cQueryCaso +=         " AND EXISTS ( SELECT NW4a.R_E_C_N_O_ "
			cQueryCaso +=                        " FROM " + RetSqlName("NW4") + " NW4a "
			cQueryCaso +=                       " WHERE NW4a.NW4_FILIAL = '" + xFilial("NW4") +"' "
			cQueryCaso +=                         " AND NW4a.NW4_PRECNF = '" + cCodPre +"' "
			cQueryCaso +=                         " AND NW4a.NW4_SITUAC = '1' "
			cQueryCaso +=                         " AND NW4a.NW4_CANC = '2' "
			cQueryCaso +=                         " AND NW4a.D_E_L_E_T_ = ' ' "
			cQueryCaso +=                         " AND NW4a.NW4_CLTAB  = NV4.NV4_COD "
			cQueryCaso +=                     ")"
		EndIf
		cQueryCaso +=             " AND NV4.D_E_L_E_T_ = ' ' "
		cQueryCaso +=           " UNION ALL "
		cQueryCaso +=          " SELECT NVY.NVY_CCLIEN CCLIEN, NVY.NVY_CLOJA CLOJA, NVY.NVY_CCASO CCASO, "
		cQueryCaso +=                 " '2' TEMTS, "
		cQueryCaso +=                 " '1' TEMDP, "
		cQueryCaso +=                 " '2' TEMLT, "
		cQueryCaso +=                 " '2' TEMFX,  "
		cQueryCaso +=                 " '2' TEMFA, "
		cQueryCaso +=                 " '2' TEMLM  "
		cQueryCaso +=            " FROM " + RetSqlName("NVY") + " NVY "
		cQueryCaso +=           " WHERE NVY.NVY_FILIAL = '" + xFilial("NVY") +"' "
		If oParams:GetSituac() <> "1"
			cQueryCaso +=         " AND NVY.NVY_CPREFT = '" + cCodPre +"' "
		Else
			cQueryCaso +=         " AND EXISTS ( SELECT NVZa.R_E_C_N_O_ "
			cQueryCaso +=                        " FROM " + RetSqlName("NVZ") + " NVZa "
			cQueryCaso +=                       " WHERE NVZa.NVZ_FILIAL = '" + xFilial("NVZ") +"' "
			cQueryCaso +=                         " AND NVZa.NVZ_PRECNF = '" + cCodPre +"' "
			cQueryCaso +=                         " AND NVZa.NVZ_SITUAC = '1' "
			cQueryCaso +=                         " AND NVZa.NVZ_CANC   = '2' "
			cQueryCaso +=                         " AND NVZa.D_E_L_E_T_ = ' ' "
			cQueryCaso +=                         " AND NVZa.NVZ_CDESP  = NVY.NVY_COD "
			cQueryCaso +=                     ")"
			cQueryCaso +=         " AND NVY.D_E_L_E_T_	= ' ' "
		EndIf

		// Incluir os casos dos contratos quando for PF de Fixo
		cQueryCaso +=           " UNION ALL "
		cQueryCaso +=          " SELECT NUT.NUT_CCLIEN CCLIEN, NUT.NUT_CLOJA CLOJA, NUT.NUT_CCASO CCASO, "
		cQueryCaso +=                 " '2' TEMTS, "
		cQueryCaso +=                 " '2' TEMDP, "
		cQueryCaso +=                 " '2' TEMLT, "
		cQueryCaso +=                 " '1' TEMFX, "
		cQueryCaso +=                 " '2' TEMFA, "
		cQueryCaso +=                 " '2' TEMLM  "
		cQueryCaso +=            " FROM " + RetSqlName("NUT") + " NUT "
		cQueryCaso +=           " WHERE NUT.NUT_FILIAL = '" + xFilial("NUT") +"' "
		If !lCpoFxNc .Or. !oParams:GetFltrFxNc() // Flag de TSs de Contrato Fixo ou Não Cobrável só considera TS
			cQueryCaso +=             " AND EXISTS ( SELECT NT1a.R_E_C_N_O_ "
			cQueryCaso +=                            " FROM " + RetSqlName("NT1") + " NT1a "
			cQueryCaso +=                           " INNER JOIN " + RetSqlName("NT0") + " NT0 "
			cQueryCaso +=                              " ON NT0.NT0_FILIAL = '" + xFilial("NT0") + "' "
			cQueryCaso +=                              "AND NT0.D_E_L_E_T_ = ' ' "
			cQueryCaso +=                           " INNER JOIN " + RetSqlName("NTH") + " NTH "
			cQueryCaso +=                              " ON NTH.NTH_FILIAL = '" + xFilial("NTH") + "' "
			cQueryCaso +=                             " AND NTH.NTH_CAMPO = 'NT0_FXABM' "
			cQueryCaso +=                             " AND NTH.D_E_L_E_T_ = ' ' "
			cQueryCaso +=                           " INNER JOIN " + RetSqlName("NVE") + " NVE "
			cQueryCaso +=                              " ON NVE.NVE_FILIAL = '" + xFilial("NVE") + "' "
			cQueryCaso +=                             " AND NVE.NVE_ENCHON = '2' "
			cQueryCaso +=                             " AND NVE.D_E_L_E_T_ = ' ' "
			If oParams:GetSituac() <> "1" // Não é Conferência
				cQueryCaso +=                         " AND NVE.NVE_COBRAV = '1' "
			EndIf
			cQueryCaso +=                           " WHERE NT1a.NT1_FILIAL = '" + xFilial("NT1") +"' "
			cQueryCaso +=                             " AND NTH.NTH_CTPHON = NT0.NT0_CTPHON "
			cQueryCaso +=                             " AND NVE.NVE_CCLIEN = NUT.NUT_CCLIEN "
			cQueryCaso +=                             " AND NVE.NVE_LCLIEN = NUT.NUT_CLOJA "
			cQueryCaso +=                             " AND NVE.NVE_NUMCAS = NUT.NUT_CCASO "
			cQueryCaso +=                             " AND NT1a.NT1_CCONTR = NUT.NUT_CCONTR "
			cQueryCaso +=                             " AND NT0.NT0_COD = NUT.NUT_CCONTR "
			If oParams:GetSituac() <> "1" // Não é Conferência
				cQueryCaso +=                         " AND NT1a.NT1_CPREFT = '" + cCodPre +"' "
			Else
				cQueryCaso +=                         " AND EXISTS ( SELECT NWEa.R_E_C_N_O_ "
				cQueryCaso +=                                        " FROM " + RetSqlName("NWE") + " NWEa "
				cQueryCaso +=                                       " WHERE NWEa.NWE_FILIAL = '" + xFilial("NWE") +"' "
				cQueryCaso +=                                         " AND NWEa.NWE_PRECNF = '" + cCodPre +"' "
				cQueryCaso +=                                         " AND NWEa.NWE_SITUAC = '1' "
				cQueryCaso +=                                         " AND NWEa.NWE_CANC   = '2' "
				cQueryCaso +=                                         " AND NWEa.D_E_L_E_T_ = ' ' "
				cQueryCaso +=                                         " AND NWEa.NWE_CFIXO  = NT1a.NT1_SEQUEN "
				cQueryCaso +=                                     ") "
			EndIf
			cQueryCaso +=                             " AND NT1a.D_E_L_E_T_ = ' ' "
			cQueryCaso +=                             " AND NT1a.NT1_CCONTR = NUT.NUT_CCONTR "
			// Se não for Faixa Qtdade de Casos
			cQueryCaso +=                             " AND (CASE WHEN NTH.NTH_VISIV = '2' THEN "
			cQueryCaso +=                                     " (CASE WHEN NVE.NVE_SITUAC = '1' THEN (CASE WHEN NVE.NVE_DTENTR <= NT1a.NT1_DATAFI THEN '1' ELSE '2' END) ELSE "
			cQueryCaso +=                                        " (CASE WHEN NVE.NVE_DTENCE >= NT1a.NT1_DATAIN AND NVE.NVE_DTENTR <= NT1a.NT1_DATAFI THEN '1' ELSE '2' END) "
			cQueryCaso +=                                     " END) "
			cQueryCaso +=                                  " ELSE "
			// Se for Faixa - Qtdade de Casos - verifica o conteúdo dos campos NT0_FXABM e NT0_FXENCM além da situação do caso
			cQueryCaso +=                                     " (CASE WHEN NTH.NTH_VISIV = '1' THEN "
			cQueryCaso +=                                         " (CASE WHEN NVE.NVE_SITUAC = '1' THEN "
			cQueryCaso +=                                             " (CASE WHEN NT0.NT0_FXABM = '1' THEN  "
			cQueryCaso +=                                                 " (CASE WHEN NVE.NVE_DTENTR <= NT1a.NT1_DATAFI THEN '1' ELSE '2' END) "
			cQueryCaso +=                                              " ELSE "
			cQueryCaso +=                                                  " (CASE WHEN NVE.NVE_DTENTR < NT1a.NT1_DATAIN THEN '1' ELSE '2' END) "
			cQueryCaso +=                                              " END) " 
			cQueryCaso +=                                          " ELSE "  
			cQueryCaso +=                                             " (CASE WHEN NT0.NT0_FXABM = '1' THEN "
			cQueryCaso +=                                                 " (CASE WHEN NT0.NT0_FXENCM = '1' THEN "
			cQueryCaso +=                                                     " (CASE WHEN NVE.NVE_DTENTR <= NT1a.NT1_DATAFI AND NVE.NVE_DTENCE >= NT1a.NT1_DATAIN THEN '1' ELSE '2' END) "
			cQueryCaso +=                                                  " ELSE "
			cQueryCaso +=                                                     " (CASE WHEN NVE.NVE_DTENTR <= NT1a.NT1_DATAFI AND NVE.NVE_DTENCE > NT1a.NT1_DATAFI THEN '1' ELSE '2' END) "
			cQueryCaso +=                                                  " END ) "
			cQueryCaso +=                                              " ELSE "
			cQueryCaso +=                                                 " (CASE WHEN NT0.NT0_FXENCM = '1' THEN "
			cQueryCaso +=                                                     " (CASE WHEN NVE.NVE_DTENTR < NT1a.NT1_DATAIN AND NVE.NVE_DTENCE >= NT1a.NT1_DATAIN THEN '1' ELSE '2' END) "
			cQueryCaso +=                                                  " ELSE  "
			cQueryCaso +=                                                     " (CASE WHEN NVE.NVE_DTENTR < NT1a.NT1_DATAIN AND NVE.NVE_DTENCE > NT1a.NT1_DATAFI THEN '1' ELSE '2' END) " 
			cQueryCaso +=                                                  " END) "
			cQueryCaso +=                                              " END) "
			cQueryCaso +=                                          " END) "
			cQueryCaso +=                                      " END) "
			cQueryCaso +=                                   " END) <> '2' "
			cQueryCaso +=                        " ) "
		EndIf
		cQueryCaso +=             " AND NUT.D_E_L_E_T_ = ' ' "
		// Tratamento para limite
		cQueryCaso +=          " UNION ALL "
		cQueryCaso +=            JA201ALM(oParams, .T., " CCLIEN, CLOJA, CCASO, TEMTS, TEMDP, TEMLT, TEMFX, TEMFA, TEMLM ", cCodContr, cCodJun)
		cQueryCaso +=        " ) A, " + RetSqlName("NT0") + " NT0, " + RetSqlName("NUT") + " NUT, " + RetSqlName("NRA") + " NRA "
		cQueryCaso +=   " WHERE NUT.NUT_FILIAL = '" + xFilial("NUT") +"' "
		cQueryCaso +=     " AND NT0.NT0_FILIAL = '" + xFilial("NT0") +"' "
		cQueryCaso +=     " AND NRA.NRA_FILIAL = '" + xFilial("NRA") +"' "
		cQueryCaso +=     " AND NUT.NUT_CCLIEN = A.CCLIEN "
		cQueryCaso +=     " AND NUT.NUT_CLOJA = A.CLOJA "
		cQueryCaso +=     " AND NUT.NUT_CCASO = A.CCASO "
		cQueryCaso +=     " AND NUT.NUT_CCONTR = NT0.NT0_COD "
		cQueryCaso +=     " AND NRA.NRA_COD = NT0.NT0_CTPHON "
		If !Empty(cCodJun)
			cQueryCaso += " AND EXISTS (SELECT NW3.R_E_C_N_O_ "
			cQueryCaso +=               " FROM " + RetSqlName("NW3") + " NW3 "
			cQueryCaso +=               " LEFT JOIN " + RetSqlName("NT1") + " NT1B "
			cQueryCaso +=                 " ON (NT1B.NT1_FILIAL = '" + xFilial("NT1") +"' "
			cQueryCaso +=                " AND NT1B.NT1_CCONTR = NW3.NW3_CCONTR "
			cQueryCaso +=                " AND NT1B.D_E_L_E_T_ = ' ') "
			cQueryCaso +=              " WHERE NW3.NW3_FILIAL = '" + xFilial("NW3") +"' "
			cQueryCaso +=                " AND NW3.NW3_CCONTR = NUT.NUT_CCONTR "
			cQueryCaso +=                " AND NW3.NW3_CJCONT = '" + cCodJun + "' "
			If !Empty(dMenorDt) .And. !Empty(dMaiorDt)
				cQueryCaso +=            " AND (NRA.NRA_COBRAF <> '1' OR NT1B.NT1_DATAFI BETWEEN '" + DtoS(dMenorDt) + "' AND '" + DtoS(dMaiorDt) + "')"
			EndIf
			cQueryCaso +=                " AND NW3.D_E_L_E_T_ = ' ') "
		ElseIf !Empty(cCodContr)
			cQueryCaso += " AND NUT.NUT_CCONTR = '" + cCodContr + "' "
		EndIf
		If oParams:GetSituac() <> "1" .And. (!lCpoFxNc .Or. !oParams:GetFltrFxNc()) // Não é Conferência e não é Revisão de TS de contratos fixos/Não cobrável
			cQueryCaso +=       " AND ((A.TEMTS = '1' AND A.TEMTS = NRA.NRA_COBRAH) "
		Else
			cQueryCaso +=       " AND ((A.TEMTS = '1') "
		EndIf
		cQueryCaso +=           " OR (A.TEMDP = '1' AND A.TEMDP = NT0.NT0_DESPES) "
		cQueryCaso +=           " OR (A.TEMLT = '1' AND A.TEMLT = NT0.NT0_SERTAB) "
		cQueryCaso +=           " OR (A.TEMFX = '1' AND A.TEMFX = NRA.NRA_COBRAF) "
		cQueryCaso +=           " OR (A.TEMLM = '1' AND A.TEMLM = NRA.NRA_COBRAH))"
		cQueryCaso +=     " AND NT0.NT0_ATIVO = '1' "
		cQueryCaso +=     " AND NT0.D_E_L_E_T_ = ' ' "
		cQueryCaso +=     " AND NUT.D_E_L_E_T_ = ' ' "
		cQueryCaso +=     " AND NRA.D_E_L_E_T_ = ' ' "
		cQueryCaso +=   " GROUP BY NT0.NT0_CESCR, NT0.NT0_COD, A.CCLIEN, A.CLOJA, A.CCASO, NT0.NT0_VLRBAS, "
		cQueryCaso +=            " NT0.NT0_DESPES, NT0.NT0_SERTAB, NRA.NRA_COBRAH, NRA.NRA_COBRAF "

	ElseIf oParams:GetTpExec() $ "2|3|4|5|6|MS" // Refaz a pré-fatura com base na NX1 para conservar os casos da mesma.

		If !Empty(cCodPre)
			cQueryCaso := " SELECT NT0.NT0_CESCR CCESC, NT0.NT0_COD CCONTR, A.CCLIEN, A.CLOJA, A.CCASO, NT0.NT0_VLRBAS VLRBAS, "
			cQueryCaso +=        IIF(lFxNC, " '1' TEMTS, ", " MIN(CASE WHEN NRA.NRA_COBRAH = '1' THEN  A.TEMTS ELSE '2' END) TEMTS, ") // Flag de Contrato Fixo ou Não Cobrável sempre considera TS
			cQueryCaso +=        " MIN(CASE WHEN NT0.NT0_DESPES = '1' THEN A.TEMDP ELSE '2' END) TEMDP, "
			cQueryCaso +=        " MIN(CASE WHEN NT0.NT0_SERTAB = '1' THEN A.TEMLT ELSE '2' END) TEMLT, "
			cQueryCaso +=        " MIN(A.TEMFX) TEMFX, "
			cQueryCaso +=        " MIN(A.TEMFA) TEMFA, "
			cQueryCaso +=        " MIN(A.TEMLM) TEMLM  "
			cQueryCaso +=   " FROM ( SELECT NT0.NT0_CESCR CCESC, NT0.NT0_COD CCONTR, NX1.NX1_CCLIEN CCLIEN, "
			cQueryCaso +=                 " NX1.NX1_CLOJA CLOJA, NX1.NX1_CCASO CCASO, NT0.NT0_VLRBAS VLRBAS, "
			cQueryCaso +=                 " NX1.NX1_TS TEMTS, "
			cQueryCaso +=                 " NX1.NX1_DESP TEMDP, "
			cQueryCaso +=                 " NX1.NX1_LANTAB TEMLT, "
			cQueryCaso +=                 " (CASE WHEN NWEA.R_E_C_N_O_ IS NULL THEN '2' ELSE '1' END) TEMFX,"
			cQueryCaso +=                 " '2' TEMFA,  "
			cQueryCaso +=                 " (CASE WHEN NX1.NX1_VUTFAT > 0 THEN '1' ELSE '2' END) TEMLM, "
			cQueryCaso +=                 " (CASE WHEN NX8A.NX8_CTPHON = '" + Space(TamSx3('NX8_CTPHON')[1]) + "' OR NX8A.NX8_CTPHON IS NULL "
			cQueryCaso +=                       " THEN NT0.NT0_CTPHON ELSE NX8A.NX8_CTPHON END) CTPHON "
			cQueryCaso +=            " FROM " + RetSqlName("NX1") + " NX1, " + RetSqlName("NT0") + " NT0 "
			cQueryCaso +=            " LEFT JOIN " + RetSqlName("NT1") + " NT1a "
			cQueryCaso +=                   " ON NT1a.NT1_FILIAL = '" + xFilial("NT1") +"' "
			cQueryCaso +=                  " AND NT1a.NT1_CCONTR = NT0.NT0_COD "
			cQueryCaso +=                  " AND NT1a.D_E_L_E_T_ = ' ' "
			cQueryCaso +=            " LEFT JOIN " + RetSqlName("NX8") + " NX8A "
			cQueryCaso +=                   " ON NX8A.NX8_FILIAL = '" + xFilial("NX8") +"' "
			cQueryCaso +=                  " AND NX8A.NX8_CCONTR = NT0.NT0_COD "
			cQueryCaso +=                  " AND NX8A.NX8_CPREFT = '" + cCodPre + "' "
			cQueryCaso +=                  " AND NX8A.D_E_L_E_T_ = ' ' "
			cQueryCaso +=            " LEFT JOIN " + RetSqlName("NWE") + " NWEA "
			cQueryCaso +=                   " ON NWEA.NWE_FILIAL = '" + xFilial("NWE") +"' "
			cQueryCaso +=                  " AND NWEa.NWE_CFIXO  = NT1a.NT1_SEQUEN "
			If oParams:GetTpExec() $ "2|6" // Pré
				cQueryCaso +=              " AND NWEa.NWE_PRECNF = '" + cCodPre +"' "
				cQueryCaso +=              " AND NWEa.NWE_SITUAC = '1' "
			Else //Fatura / Minuta Fatura / Minuta Pré
				cQueryCaso +=              " AND NWEa.NWE_CFATUR = '" + cFatura +"' "
				cQueryCaso +=              " AND NWEa.NWE_CESCR  = '" + cEscr +"' "
				cQueryCaso +=              " AND NWEa.NWE_SITUAC = '4' "
			EndIf
			cQueryCaso +=                  " AND NWEa.NWE_CANC   = '2' "
			cQueryCaso +=                  " AND NWEa.D_E_L_E_T_ = ' ' "
			cQueryCaso +=           " WHERE NX1.NX1_FILIAL = '" + xFilial("NX1") +"' "
			cQueryCaso +=             " AND NT0.NT0_FILIAL = '" + xFilial("NT0") +"' "
			cQueryCaso +=             " AND NX1.NX1_CCONTR = NT0.NT0_COD "
			If !Empty(cCodContr) .And. Empty(cCodJun)
				cQueryCaso +=         " AND NT0.NT0_COD = '" + cCodContr +"' "
			EndIf
			cQueryCaso +=             " AND NX1.NX1_CPREFT = '" + cCodPre +"' "
			cQueryCaso +=             " AND NT0.D_E_L_E_T_ = ' ' "
			cQueryCaso +=             " AND NX1.D_E_L_E_T_ = ' ' "
			cQueryCaso +=        " ) A," + RetSqlName("NT0") + " NT0," + RetSqlName("NRA") + " NRA, " + RetSqlName("NX8") + " NX8 "
			cQueryCaso +=   " WHERE NT0.NT0_FILIAL = '" + xFilial("NT0") +"' "
			cQueryCaso +=     " AND NRA.NRA_FILIAL = '" + xFilial("NRA") +"' "
			cQueryCaso +=     " AND NX8.NX8_FILIAL = '" + xFilial("NX8") +"' "
			cQueryCaso +=     " AND NRA.NRA_COD    = A.CTPHON"
			cQueryCaso +=     " AND NT0.NT0_COD    = A.CCONTR "
			cQueryCaso +=     " AND NX8.NX8_CCONTR = NT0.NT0_COD "
			cQueryCaso +=     " AND NX8.NX8_CPREFT = '" + cCodPre +"' "
			If !Empty(cCodJun)
				cQueryCaso += " AND EXISTS (SELECT NW3.R_E_C_N_O_ "
				cQueryCaso +=               " FROM " + RetSqlName("NW3") + " NW3 "
				cQueryCaso +=              " WHERE NW3.NW3_FILIAL = '" + xFilial("NW3") +"' "
				cQueryCaso +=                " AND NW3.NW3_CCONTR = NT0.NT0_COD "
				cQueryCaso +=                " AND NW3.NW3_CJCONT = '" + cCodJun + "' "
				cQueryCaso +=                " AND NW3.D_E_L_E_T_ = ' ' ) "
			ElseIf !Empty(cCodContr)
				cQueryCaso += " AND NT0.NT0_COD = '" + cCodContr +"' "
			EndIf
			cQueryCaso +=     " AND NT0.D_E_L_E_T_ = ' ' "
			cQueryCaso +=     " AND NRA.D_E_L_E_T_ = ' ' "
			cQueryCaso +=     " AND NX8.D_E_L_E_T_ = ' ' "
			cQueryCaso +=   " GROUP BY NT0.NT0_CESCR , NT0.NT0_COD, A.CCLIEN, A.CLOJA, A.CCASO, NT0.NT0_VLRBAS "

		Else // Fatura de Fixo

			cQueryCaso := " SELECT NT0.NT0_CESCR CCESC, NT0.NT0_COD CCONTR, NUT.NUT_CCLIEN CCLIEN, NUT.NUT_CLOJA CLOJA, NUT.NUT_CCASO CCASO, NT0.NT0_VLRBAS VLRBAS,"
			cQueryCaso +=                " '2' TEMTS, "
			cQueryCaso +=                " '2' TEMDP, "
			cQueryCaso +=                " '2' TEMLT, "
			cQueryCaso +=                " '1' TEMFX, "
			cQueryCaso +=                " '2' TEMFA, "
			cQueryCaso +=                " '2' TEMLM "
			cQueryCaso +=      " FROM " + RetSqlName("NT0") + " NT0, "
			cQueryCaso +=            " " + RetSqlName("NUT") + " NUT, "
			cQueryCaso +=            " " + RetSqlName("NRA") + " NRA "
			cQueryCaso +=         " WHERE NT0.NT0_FILIAL = '" + xFilial("NT0") +"' "
			cQueryCaso +=           " AND NUT.NUT_FILIAL = '" + xFilial("NUT") +"' "
			cQueryCaso +=           " AND NRA.NRA_FILIAL = '" + xFilial("NRA") +"' "
			cQueryCaso +=           " AND NUT.NUT_CCONTR = NT0.NT0_COD "
			cQueryCaso +=           " AND NRA.NRA_COD  = NT0.NT0_CTPHON "
			cQueryCaso +=           " AND NRA.NRA_COBRAF = '1' "
			cQueryCaso +=           " AND EXISTS ( SELECT NT1a.R_E_C_N_O_ "
			cQueryCaso +=                          " FROM " + RetSqlName("NT1") + " NT1a, "
			cQueryCaso +=                               " " + RetSqlName("NWE") + " NWEa "
			cQueryCaso +=                         " INNER JOIN " + RetSqlName("NTH") + " NTH "
			cQueryCaso +=                            " ON NTH.NTH_FILIAL = '" + xFilial("NTH") + "' "
			cQueryCaso +=                           " AND NTH.NTH_CAMPO = 'NT0_FXABM' "
			cQueryCaso +=                           " AND NTH.D_E_L_E_T_ = ' ' "
			cQueryCaso +=                         " INNER JOIN " + RetSqlName("NVE") + " NVE "
			cQueryCaso +=                            " ON NVE.NVE_FILIAL = '" + xFilial("NVE") + "' "
			cQueryCaso +=                           " AND NVE.NVE_ENCHON = '2' "
			If oParams:GetSituac() <> "1" // Não é Conferência
				cQueryCaso +=                       " AND NVE.NVE_COBRAV = '1' "
			EndIf
			cQueryCaso +=                           " AND NVE.D_E_L_E_T_ = ' ' "
			cQueryCaso +=                         " WHERE NT1a.NT1_FILIAL = '" + xFilial("NT1") +"' "
			cQueryCaso +=                           " AND NTH.NTH_CTPHON = NT0.NT0_CTPHON "
			cQueryCaso +=                           " AND NWEa.NWE_FILIAL = '" + xFilial("NWE") +"' "
			cQueryCaso +=                           " AND NWEa.NWE_CFATUR = '" + cFatura +"' "
			cQueryCaso +=                           " AND NWEa.NWE_CESCR  = '" + cEscr +"' "
			cQueryCaso +=                           " AND NT1a.NT1_CCONTR = NUT.NUT_CCONTR "
			cQueryCaso +=                           " AND NVE.NVE_CCLIEN = NUT.NUT_CCLIEN "
			cQueryCaso +=                           " AND NVE.NVE_LCLIEN = NUT.NUT_CLOJA "
			cQueryCaso +=                           " AND NVE.NVE_NUMCAS = NUT.NUT_CCASO "
			cQueryCaso +=                           " AND NWEa.NWE_CFIXO  = NT1a.NT1_SEQUEN "
			cQueryCaso +=                           " AND NWEa.NWE_SITUAC = '4' "
			cQueryCaso +=                           " AND NWEa.NWE_CANC   = '2' "
			cQueryCaso +=                           " AND NWEa.D_E_L_E_T_ = ' ' "
			cQueryCaso +=                           " AND NT1a.D_E_L_E_T_ = ' ' "
			// Se não for Faixa Qtdade de Casos
			cQueryCaso +=                           " AND (CASE WHEN NTH.NTH_VISIV = '2' THEN "
			cQueryCaso +=                                   " (CASE WHEN NVE.NVE_SITUAC = '1' THEN (CASE WHEN NVE.NVE_DTENTR <= NT1a.NT1_DATAFI THEN '1' ELSE '2' END) ELSE "
			cQueryCaso +=                                      " (CASE WHEN NVE.NVE_DTENCE >= NT1a.NT1_DATAIN AND NVE.NVE_DTENTR <= NT1a.NT1_DATAFI THEN '1' ELSE '2' END) "
			cQueryCaso +=                                   " END) "
			cQueryCaso +=                                " ELSE "
			// Se for Faixa - Qtdade de Casos - verifica o conteúdo dos campos NT0_FXABM e NT0_FXENCM além da situação do caso
			cQueryCaso +=                                   " (CASE WHEN NTH.NTH_VISIV = '1' THEN "
			cQueryCaso +=                                       " (CASE WHEN NVE.NVE_SITUAC = '1' THEN "
			cQueryCaso +=                                           " (CASE WHEN NT0.NT0_FXABM = '1' THEN  "
			cQueryCaso +=                                               " (CASE WHEN NVE.NVE_DTENTR <= NT1a.NT1_DATAFI THEN '1' ELSE '2' END) "
			cQueryCaso +=                                            " ELSE "
			cQueryCaso +=                                                " (CASE WHEN NVE.NVE_DTENTR < NT1a.NT1_DATAIN THEN '1' ELSE '2' END) "
			cQueryCaso +=                                            " END) " 
			cQueryCaso +=                                        " ELSE "  
			cQueryCaso +=                                           " (CASE WHEN NT0.NT0_FXABM = '1' THEN "
			cQueryCaso +=                                               " (CASE WHEN NT0.NT0_FXENCM = '1' THEN "
			cQueryCaso +=                                                   " (CASE WHEN NVE.NVE_DTENTR <= NT1a.NT1_DATAFI AND NVE.NVE_DTENCE >= NT1a.NT1_DATAIN THEN '1' ELSE '2' END) "
			cQueryCaso +=                                                " ELSE "
			cQueryCaso +=                                                   " (CASE WHEN NVE.NVE_DTENTR <= NT1a.NT1_DATAFI AND NVE.NVE_DTENCE > NT1a.NT1_DATAFI THEN '1' ELSE '2' END) "
			cQueryCaso +=                                                " END ) "
			cQueryCaso +=                                            " ELSE "
			cQueryCaso +=                                               " (CASE WHEN NT0.NT0_FXENCM = '1' THEN "
			cQueryCaso +=                                                   " (CASE WHEN NVE.NVE_DTENTR < NT1a.NT1_DATAIN AND NVE.NVE_DTENCE >= NT1a.NT1_DATAIN THEN '1' ELSE '2' END) "
			cQueryCaso +=                                                " ELSE  "
			cQueryCaso +=                                                   " (CASE WHEN NVE.NVE_DTENTR < NT1a.NT1_DATAIN AND NVE.NVE_DTENCE > NT1a.NT1_DATAFI THEN '1' ELSE '2' END) " 
			cQueryCaso +=                                                " END) "
			cQueryCaso +=                                            " END) "
			cQueryCaso +=                                        " END) "
			cQueryCaso +=                                    " END) "
			cQueryCaso +=                                 " END) <> '2' "
			cQueryCaso +=                      " ) "
			If (Empty(cCodFAd) .And. !Empty(cCodContr)) .And. Empty(cCodJun)
				cQueryCaso +=   " AND NT0.NT0_COD = '" + cCodContr +"' "
			EndIf
			cQueryCaso +=           " AND NT0.D_E_L_E_T_ = ' ' "
			cQueryCaso +=           " AND NUT.D_E_L_E_T_ = ' ' "
			cQueryCaso +=           " AND NRA.D_E_L_E_T_ = ' ' "
			cQueryCaso += " GROUP BY NT0.NT0_CESCR, NT0.NT0_COD, NUT.NUT_CCLIEN, NUT.NUT_CLOJA, NUT.NUT_CCASO, NT0.NT0_VLRBAS,"
			cQueryCaso +=          " NT0.NT0_DESPES, NT0.NT0_SERTAB, NRA.NRA_COBRAH, NRA.NRA_COBRAF "

		EndIf
	EndIf

Else
	// Query dos Casos - Fatura Adicional
	cQueryCaso :=  " SELECT NVV.NVV_CESCR CCESC, NVV.NVV_CCONTR CCONTR, NVW.NVW_CCLIEN CCLIEN, NVW.NVW_CLOJA CLOJA, NVW.NVW_CCASO CCASO, 0 VLRBAS,"
	cQueryCaso +=         " MIN(NVV.NVV_TRATS) TEMTS, "
	cQueryCaso +=         " MIN(NVV.NVV_TRALT) TEMLT, "

	cQueryCaso +=         " CASE WHEN NVW.NVW_VALORD > 0 THEN '1' ELSE "
	cQueryCaso +=         " (CASE WHEN NVV.NVV_TRADSP = '1' AND (SELECT COUNT(NVY.R_E_C_N_O_) " //Verifica se existe despesa para emitir no caso da FA
	cQueryCaso +=                      " FROM " + RetSqlName("NVY") + " NVY "
	cQueryCaso +=                      " WHERE NVY.NVY_FILIAL = '" + xFilial("NVY") +"' "

	If ( oParams:GetTpExec() $ "1|2|6" .And. oParams:GetSituac() != "1" ) // Emissão de Pré / Reemissão de Pré
		cQueryCaso +=                  " AND NVY.NVY_CPREFT = '" + cCodPre +"' "
	Else
		cQueryCaso +=                  " AND EXISTS ( SELECT NVY.R_E_C_N_O_ "
		cQueryCaso +=                                " FROM " + RetSqlName("NVZ") + " NVZ  "
		cQueryCaso +=                                " WHERE NVZ.NVZ_FILIAL = '" + xFilial("NVZ") +"' "
		cQueryCaso +=                                  " AND NVZ.NVZ_CDESP = NVY.NVY_COD "
		cQueryCaso +=                                  " AND NVZ.NVZ_CANC = '2' "
		If oParams:GetTpExec() $ "1" .And. oParams:GetSituac() == "1" //Conferência de Pré
			cQueryCaso +=                               " AND NVZ.NVZ_PRECNF = '" + cCodPre +"' "
			cQueryCaso +=                               " AND NVZ.NVZ_SITUAC = '1' "
		Else //Fatura / Minuta Fatura / Minuta Pré
			cQueryCaso +=                               " AND NVZ.NVZ_CFATUR = '" + cFatura +"' "
			cQueryCaso +=                               " AND NVZ.NVZ_CESCR = '" + cEscr +"' "
			cQueryCaso +=                               " AND NVZ.NVZ_SITUAC = '4' "
		EndIf
		cQueryCaso +=                                  " AND NVZ.D_E_L_E_T_ = ' ' )"
	EndIf
	cQueryCaso +=                     " AND NVY.NVY_CCLIEN = NVW.NVW_CCLIEN "
	cQueryCaso +=                     " AND NVY.NVY_CLOJA = NVW.NVW_CLOJA "
	cQueryCaso +=                     " AND NVY.NVY_CCASO = NVW.NVW_CCASO "
	cQueryCaso +=                     " AND NVY.D_E_L_E_T_ = ' ' "
	cQueryCaso +=                     " ) > 0 THEN '1' ELSE '2' END) "
	cQueryCaso +=    " END TEMDP, "
	cQueryCaso +=       " '2' TEMFX,"
	cQueryCaso +=       " '1' TEMFA, "
	cQueryCaso +=       " '2' TEMLM, "

	cQueryCaso +=       " NVW.NVW_VALORH,"
	cQueryCaso +=       " NVW.NVW_VALORD,"

	If lDespTrib
		cQueryCaso +=       " NVW.NVW_VALDTR,"
	EndIf

	cQueryCaso +=       " NVW.NVW_VALORT,"
	cQueryCaso +=       " NVV.NVV_CMOE1,"
	cQueryCaso +=       " NVV.NVV_CMOE2,"
	cQueryCaso +=       " NVV.NVV_CMOE4,"
	cQueryCaso +=       " NVV.NVV_VALORH,"
	cQueryCaso +=       " NVV.NVV_VALORD,"
	If lDespTrib
		cQueryCaso +=       " NVV.NVV_VALDTR,"
	EndIf
	cQueryCaso +=       " NVV.NVV_VALORT,"
	cQueryCaso +=       " NVV.NVV_DSPCAS,"
	cQueryCaso +=       " NVV.NVV_TPRAT "

	cQueryCaso +=     " FROM " + RetSqlName("NVV") + " NVV "
	cQueryCaso +=     "INNER JOIN " + RetSqlName("NVW") + " NVW "
	cQueryCaso +=       " ON NVV.NVV_COD = NVW.NVW_CODFAD "
	cQueryCaso +=      " AND NVW.NVW_FILIAL = '" + xFilial("NVW") + "' "
	cQueryCaso +=      " AND NVW.D_E_L_E_T_ = ' ' "			
	If oParams:GetSituac() <> "1" // Não é Conferência
		cQueryCaso += "INNER JOIN " + RetSqlName("NVE") + " NVE "
		cQueryCaso +=   " ON NVE.NVE_NUMCAS = NVW.NVW_CCASO "
		cQueryCaso +=  " AND NVE.NVE_CCLIEN = NVW.NVW_CCLIEN "
		cQueryCaso +=  " AND NVE.NVE_LCLIEN = NVW_CLOJA"
		cQueryCaso +=  " AND NVE.NVE_COBRAV = '1' "
		cQueryCaso +=  " AND NVE.NVE_FILIAL = '" + xFilial("NVE") + "' "
		cQueryCaso +=  " AND NVE.D_E_L_E_T_ = ' ' "
	EndIf
	cQueryCaso +=    " WHERE NVV.NVV_FILIAL = '" + xFilial("NVV") +"' "
	If ( oParams:GetTpExec() $ "1|6" .And. oParams:GetSituac() != "1" )// Emissão de Pré / Reemissão de Pré
		cQueryCaso +=  " AND NVV.NVV_CPREFT = '" + cCodPre + "' "
	Else
		cQueryCaso +=  " AND EXISTS ( SELECT NWD.R_E_C_N_O_ "
		cQueryCaso +=                 " FROM " + RetSqlName("NWD") + " NWD "
		cQueryCaso +=                " WHERE NWD.NWD_FILIAL = '" + xFilial("NWD") + "' "
		If oParams:GetTpExec() $ "1|2" //Conferência de Pré
			cQueryCaso +=              " AND NWD.NWD_PRECNF = '" + cCodPre + "' "
			cQueryCaso +=              " AND NWD.NWD_SITUAC = '1' "
		Else //Fatura / Minuta Fatura / Minuta Pré
			cQueryCaso +=              " AND NWD.NWD_CFATUR = '" + cFatura + "' "
			cQueryCaso +=              " AND NWD.NWD_CESCR = '" + cEscr + "' "
			cQueryCaso +=              " AND NWD.NWD_SITUAC = '4' "
		EndIf
		cQueryCaso +=                  " AND NWD.NWD_CANC = '2' "
		cQueryCaso +=                  " AND NWD.D_E_L_E_T_ = ' ' "
		cQueryCaso +=                  " AND NWD.NWD_CFTADC = NVV.NVV_COD "
		cQueryCaso +=              " ) "
	EndIf
	cQueryCaso +=     " AND NVV.D_E_L_E_T_ = ' ' "
	cQueryCaso +=   " GROUP BY NVV.NVV_CESCR, NVV.NVV_CCONTR, NVW.NVW_CCLIEN, NVW.NVW_CLOJA, NVW.NVW_CCASO, "
	cQueryCaso +=            " NVV.NVV_DSPCAS, NVV.NVV_TRADSP, NVW.NVW_VALORD, NVW.NVW_VALORH, NVW.NVW_VALORT, "
	cQueryCaso +=            " NVV.NVV_CMOE1, NVV.NVV_CMOE2, NVV.NVV_CMOE4, NVV.NVV_VALORH, NVV.NVV_VALORD, "
	If lDespTrib
		cQueryCaso +=        " NVW.NVW_VALDTR, NVV.NVV_VALDTR, "
	EndIf
	cQueryCaso +=            " NVV.NVV_VALORT, NVV.NVV_TPRAT "
EndIf

oParams:PtInternal(STR0019) // "Emitindo - Totaliza Caso - Abrir Query"
cQueryCaso := ChangeQuery(cQueryCaso, .F.)
DbCommitAll() // Para efetivar a alteração no banco de dados (não impacta no rollback da trasação)
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQueryCaso ), cQryRes, .T., .F. )

If !(cQryRes)->(EOF())
	oParams:PtInternal(STR0020) // "Emitindo - Totaliza Caso - Abrir Query (Abriu)"
	
	// Monta query com para obter os contratos que o mesmo cliente, loja e caso se repetem quando for junção
	If !Empty(cCodJun)
		aDivTS := J201QryDiv(cQueryCaso)
	EndIf

	While !(cQryRes)->(EOF())
		aRet         := {.F., "JA201DCaso"}
		//comuns
		nVVALORTEMP  := 0
		//Time-Sheet
		nVSOMATS     := 0
		nVSOMATSTAB  := 0
		nVSOMATSVINC := 0
		nVTSNCobra   := 0

		//Acerto no Participante
		nTSCaso      := 0
		nMaiorPar    := 0
		nRecnoPar    := 0
		nTotalPar    := 0

		//Despesas
		nVSOMADESP   := 0
		nVlDpTrib    := 0
		nVlDpReemb   := 0

		//Tabelado
		nVSOMALTAB   := 0
		nVSOMALTVINC := 0

		cNT0COD      := (cQryRes)->CCONTR
		cEscrit      := (cQryRes)->CCESC
		nNT0VLRBAS   := (cQryRes)->VLRBAS

		cCCLIEN      := (cQryRes)->CCLIEN
		cCLOJA       := (cQryRes)->CLOJA
		cCCASO       := (cQryRes)->CCASO

		cTEMTS       := AllTrim((cQryRes)->TEMTS) //Tratamento para banco POSTGRES
		cTEMDP       := AllTrim((cQryRes)->TEMDP)
		cTEMLT       := AllTrim((cQryRes)->TEMLT)

		cTEMFX       := AllTrim((cQryRes)->TEMFX)
		cTEMFA       := AllTrim((cQryRes)->TEMFA)
		cTEMLM       := AllTrim((cQryRes)->TEMLM)

		lTSData1     := .F.
		lDPData1     := .F.
		lLTData      := .F.
		lTemJunc     := .F.

		nPos         := 0

		nDescLimite  := 0
		cMoelim      := ""

		// Tratamento para mesmo cliente, loja e caso em mais de um contrato quando for junção
		If !Empty(cCodJun)
			nDivTS   := J201DDivTs(cCodJun, cNT0COD, cCCLIEN, cCLOJA, cCCASO, aDivTS)
		EndIf

		//NRA_COBRAF, NRA_COBRAH, NRA_NCOBRA
		cTpHon  := JurGetDados("NT0", 1, xFilial("NT0") + cNT0COD, "NT0_CTPHON")
		cCobH   := JurGetDados("NRA", 1, xFilial("NRA") + cTpHon, "NRA_COBRAH")
		cCobF   := JurGetDados("NRA", 1, xFilial("NRA") + cTpHon, "NRA_COBRAF")

		// J201DVinc - Verifica se o caso está vinculado a um contrato de hora.
		// Caso esteja, os timesheets serão vinculados somente no contrato que cobre hora.
		lVincTS := J201DVinc(cCCLIEN, cCLOJA, cCCASO, cNT0COD)

		If lVincTS
			lFatAtiva := JA201TemFt(,,, cCodFixo)
		EndIf

		If cTEMTS == "1" .Or. lVincTS
			// Seleciona Time-Sheets
			cQueryTS := "	SELECT NUE.R_E_C_N_O_ RECNONUE, NUE.NUE_COD, NUE.NUE_TEMPOR, NUE.NUE_VALORH, NUE.NUE_VALOR,  "
			cQueryTS +=        " NUE.NUE_CMOEDA, NUE.NUE_CLTAB, NUE.NUE_DATATS, NUE.NUE_ANOMES, NRC.NRC_TEMPOZ, NUE.NUE_CATIVI, "
			cQueryTS +=        " NUE.NUE_CCATEG, NUE.NUE_TEMPOL, NUE.NUE_CPART1, NUE.NUE_DATATS, NUE.NUE_HORAR, NUE.NUE_UTR, "
			cQueryTS +=        " NUE.NUE_CPART2, NUE.NUE_CCLIEN, NUE.NUE_CLOJA, NUE.NUE_CCASO, NUE.NUE_ANOMES, NUE.NUE_COBRAR "
			cQueryTS +=   " FROM " + RetSqlName("NUE") + " NUE  "
			cQueryTS +=        " INNER JOIN " + RetSqlName("NRC") + " NRC  ON (NRC.NRC_FILIAL = '" + xFilial("NRC") +"' AND "
			cQueryTS +=                                                              " NRC.NRC_COD = NUE.NUE_CATIVI AND "
			cQueryTS +=                                                              " NRC.D_E_L_E_T_ = ' ') "

			If ( oParams:GetTpExec() $ "1|2|6" .And. oParams:GetSituac() <> "1" )  // Emissão de Pré / Reemissão de Pré
				//
			Else
				cQueryTS +=       " INNER JOIN " + RetSqlName("NW0") + " NW0A ON (NW0A.NW0_FILIAL = '" + xFilial("NW0") + "' AND "
				cQueryTS +=                                           " NW0A.NW0_CTS = NUE.NUE_COD AND "
				If oParams:GetTpExec() $ "1" .And. oParams:GetSituac() == "1"  //Conferência de Pré
					cQueryTS +=                                           " NW0A.NW0_PRECNF = '" + cCodPre +"' AND "
					cQueryTS +=                                           " NW0A.NW0_SITUAC = '1' AND "
				Else //Fatura / Minuta Fatura / Minuta Pré
					cQueryTS +=                                           " NW0A.NW0_CFATUR = '" + cFatura +"' AND "
					cQueryTS +=                                           " NW0A.NW0_CESCR  = '" + cEscr +"' AND "
					cQueryTS +=                                           " NW0A.NW0_SITUAC = '4' AND "
				EndIf
				cQueryTS +=                                           " NW0A.NW0_CANC = '2' AND "
				cQueryTS +=                                           " NW0A.D_E_L_E_T_ = ' ') "
			EndIf
			If !Empty(oParams:GetDIniH()) .And. !Empty(oParams:GetDFinH())
				cQueryTS += J201DVigCtr("NUE", "NUE_DATATS", cNT0COD, DtoS(oParams:GetDIniH()), DtoS(oParams:GetDFinH()), lFatAtiva,, oParams:GetTpExec(), cCodPre)
			EndIf
			cQueryTS += " WHERE NUE.NUE_FILIAL = '" + xFilial("NUE") +"' "
			If !lAtivNaoC .And. (oParams:GetSituac() <> "1" .And. !lTSNCobra) // Se não zera a atividade e não é cobravel nem esta entrando na pré-validar regra junto com paramentro MV_JURTS8 e MV_JTSNCOB
				cQueryTS += " AND NRC.NRC_TEMPOZ = '1' "
			EndIf
			If ( oParams:GetTpExec() $ "1|2|6" .And. oParams:GetSituac() <> "1" )  // Emissão de Pré / Reemissão de Pré
				cQueryTS += " AND NUE.NUE_CPREFT = '" + cCodPre +"' "
			EndIf
			cQueryTS +=     " AND NUE.NUE_CCLIEN = '" + cCCLIEN +"' "
			cQueryTS +=     " AND NUE.NUE_CLOJA = '" + cCLOJA  +"' "
			cQueryTS +=     " AND NUE.NUE_CCASO = '" + cCCASO  +"' "
			cQueryTS +=     " AND NUE.D_E_L_E_T_ = ' ' "
			cQueryTS += " ORDER BY NUE.NUE_CPART2, NUE.NUE_CCLIEN, NUE.NUE_CLOJA, NUE.NUE_CCASO, NUE.NUE_ANOMES, NUE.NUE_CATIVI"

			oParams:PtInternal(STR0021) // "Emitindo - Totaliza Caso - Abrir Query TS"
			cQueryTS := ChangeQuery(cQueryTS, .F.)
			DbCommitAll() // Para efetivar a alteração no banco de dados (não impacta no rollback da trasação)
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQueryTS ), cQryResTS, .T., .F. )

			oParams:PtInternal(STR0004) // "Emitindo - Totaliza Caso - Abrir Query TS(Abriu)"

			lTSData1 := !(cQryResTS)->(EOF())
			nContaTS := 0
			
			While !(cQryResTS)->(EOF())
				nContaTS += 1

				oParams:PtInternal(STR0004 + AllTrim(Str(nContaTS))) // "Emitindo - Totaliza Caso - Abrir Query TS(Abriu) "

				If lAtivNaoC

					If !J201DAtivC((cQryResTS)->NUE_CATIVI, cNT0COD, aAtivid)
						nTempoRev := 0
						cHoraRev  := cHoraNaoC
						nUtTsRev  := 0
					Else
						nTempoRev := (cQryResTS)->NUE_TEMPOR
						cHoraRev  := (cQryResTS)->NUE_HORAR
						nUtTsRev  := (cQryResTS)->NUE_UTR
					EndIf
				Else
					nTempoRev := (cQryResTS)->NUE_TEMPOR
					cHoraRev  := (cQryResTS)->NUE_HORAR
					nUtTsRev  := (cQryResTS)->NUE_UTR
				EndIf

				oParams:PtInternal(STR0004 + AllTrim(Str(nContaTS)) + STR0005) // "Emitindo - Totaliza Caso - Abrir Query TS(Abriu) " # " - Recalcula"
				//Recalcula o Time-Sheet
				If (oParams:GetTpExec() == "1" .And. (cQryResTS)->NUE_ANOMES >= cAMRec)
					If cChaveOld <> ((cQryResTS)->NUE_CPART2 + (cQryResTS)->NUE_CCLIEN + (cQryResTS)->NUE_CLOJA + (cQryResTS)->NUE_CCASO + (cQryResTS)->NUE_ANOMES + (cQryResTS)->NUE_CATIVI)
						aRecTS := JURA200((cQryResTS)->NUE_COD, (cQryResTS)->NUE_CPART2, (cQryResTS)->NUE_CCLIEN, (cQryResTS)->NUE_CLOJA, (cQryResTS)->NUE_CCASO, (cQryResTS)->NUE_ANOMES,, (cQryResTS)->NUE_CATIVI)
					EndIf
					cChaveOld  := (cQryResTS)->NUE_CPART2 + (cQryResTS)->NUE_CCLIEN + (cQryResTS)->NUE_CLOJA + (cQryResTS)->NUE_CCASO + (cQryResTS)->NUE_ANOMES + (cQryResTS)->NUE_CATIVI
					nNUEVALORH := Round(aRecTS[2], nDecValHr)
					cNUEMOEDA  := aRecTS[1]
					nNUECATEG  := aRecTS[3]
					nNUEVALOR  := Round(nNUEVALORH * nTempoRev, nDecValor)
				Else
					nNUEVALORH := (cQryResTS)->NUE_VALORH
					cNUEMOEDA  := (cQryResTS)->NUE_CMOEDA
					nNUEVALOR  := Iif(nUtTsRev > 0, (cQryResTS)->NUE_VALOR, 0)
					nNUECATEG  := (cQryResTS)->NUE_CCATEG

					If Empty(nNUECATEG)
						If cChaveOld <> ((cQryResTS)->NUE_CPART2 + (cQryResTS)->NUE_CCLIEN + (cQryResTS)->NUE_CLOJA + (cQryResTS)->NUE_CCASO + (cQryResTS)->NUE_ANOMES + (cQryResTS)->NUE_CATIVI)
							aRecTS := JURA200((cQryResTS)->NUE_COD, (cQryResTS)->NUE_CPART2, (cQryResTS)->NUE_CCLIEN, (cQryResTS)->NUE_CLOJA, (cQryResTS)->NUE_CCASO, (cQryResTS)->NUE_ANOMES,, (cQryResTS)->NUE_CATIVI)
						EndIf
						cChaveOld := (cQryResTS)->NUE_CPART2 + (cQryResTS)->NUE_CCLIEN + (cQryResTS)->NUE_CLOJA + (cQryResTS)->NUE_CCASO + (cQryResTS)->NUE_ANOMES + (cQryResTS)->NUE_CATIVI
						nNUECATEG := aRecTS[3]
					EndIf
				EndIf

				oParams:PtInternal(STR0004 + AllTrim(Str(nContaTS)) + STR0006) // "Emitindo - Totaliza Caso - Abrir Query TS(Abriu) " # " - Verif. Cotação"

				// Verifica cotação do Time-Sheets
				aConvLanc   := JA201FConv(cMoedPF, cNUEMOEDA, nNUEVALOR, oParams:GetTpExec(), oParams:GetDEmi(), oParams:GetCFilaImpr(), cCodPre )
				nVVALORTEMP := Round(aConvLanc[1], nDecValor1)
				nVTAXA1     := aConvLanc[2] // Moeda da condição (TS)
				nVTAXA2     := aConvLanc[3] // Moeda da pré

				oParams:PtInternal(STR0004 + AllTrim(Str(nContaTS)) + STR0007) // "Emitindo - Totaliza Caso - Abrir Query TS(Abriu) " # " - Separa valor á Serv. Tab Vinc"
				// Separar o valor correspondente à Serviços Tabelados Vinculados
				If JurTSCob((cQryResTS)->NUE_COD, (cQryResTS)->NUE_CCLIEN, (cQryResTS)->NUE_CLOJA, (cQryResTS)->NUE_CCASO, (cQryResTS)->NUE_CATIVI, lFxNC)
					If Empty((cQryResTS)->NUE_CLTAB)
						nVSOMATS    := nVSOMATS + nVVALORTEMP //Não arredonda para nao perder a precisão das 8 casas decimais
					Else
						nVSOMATSTAB := nVSOMATSTAB + nVVALORTEMP

						nPos := aScan( aTabVinc, { | ax | ax[1] == (cQryResTS)->NUE_CLTAB } )

						If nPos > 0
							aTabVinc[nPos][2] := aTabVinc[nPos][2] + nVVALORTEMP
						Else
							aAdd(aTabVinc, {(cQryResTS)->NUE_CLTAB, nVVALORTEMP})   //guarda os valores do TS para verificar com o seu respectivo tabelado
						EndIf
					EndIf
				ElseIf lTSNCobra // Considera TimeSheet não cobrável
					nVTSNCobra += nVVALORTEMP
				EndIf

				oParams:PtInternal(STR0004 + AllTrim(Str(nContaTS)) + STR0008) // "Emitindo - Totaliza Caso - Abrir Query TS(Abriu) " # " - Atualizar o Valor do TS / Moeda da Pré (NUE_VALOR1 / NUE_CMOED1)"

				//Atualizar o Valor do TS / Moeda da Pré (NUE_VALOR1 / NUE_CMOED1)
				NUE->(DbGoto((cQryResTS)->RECNONUE))

				lIncFila := !lEmiPre .And. ;
				            (NUE->NUE_TEMPOR <> nTempoRev .Or. NUE->NUE_HORAR <> cHoraRev .Or. NUE->NUE_UTR <> nUtTsRev .Or. NUE->NUE_CMOEDA <> cNUEMOEDA .Or.;
				             NUE->NUE_VALOR <> nNUEVALOR .Or. NUE->NUE_VALORH <> nNUEVALORH .Or. NUE->NUE_VALOR1 <> nVVALORTEMP .Or. NUE->NUE_CMOED1 <> cMoedPF .Or.;
				             NUE->NUE_COTAC1 <> nVTAXA1 .Or. NUE->NUE_COTAC2 <> nVTAXA2)

				If RecLock("NUE", .F., .F., .F., .T.)
					NUE->NUE_TEMPOR    := nTempoRev
					NUE->NUE_HORAR     := cHoraRev
					NUE->NUE_UTR       := nUtTsRev
					NUE->NUE_CMOEDA    := cNUEMOEDA
					NUE->NUE_VALOR     := nNUEVALOR
					NUE->NUE_VALORH    := nNUEVALORH
					NUE->NUE_VALOR1    := nVVALORTEMP
					NUE->NUE_CMOED1    := cMoedPF
					NUE->NUE_COTAC1    := nVTAXA1
					NUE->NUE_COTAC2    := nVTAXA2
					NUE->NUE_COTAC     := JurCotac(nVTAXA1, nVTAXA2)
					NUE->NUE_CCATEG    := nNUECATEG
					NUE->NUE_ANOMES    := SubSTR((cQryResTS)->NUE_DATATS , 1, 6)
					If !(oParams:GetTpExec() $ "3|4|MS") // Minutas
						NUE->NUE_CUSERA    := cJurUser
						NUE->NUE_ALTDT     := Date()
						If lAltHr
							NUE->NUE_ALTHR := Time()
						EndIf
					EndIf
					NUE->(MsUnlock())
					NUE->(DbCommit())
				EndIf

				oParams:PtInternal(STR0004 + AllTrim(Str(nContaTS)) + STR0009) // "Emitindo - Totaliza Caso - Abrir Query TS(Abriu) " # " - Atualizar a Cotação na NW0"
				//Atualizar a Cotação na NW0
				//Se for Emissão, insere na NW0, se for conferência, atualiza
				If ( oParams:GetTpExec() $ "1" .And. oParams:GetSituac() <> "1" )   //   Emissão de pré
					If Empty(JurGetDados("NW0", 1, xFilial("NW0") + (cQryResTS)->NUE_COD + "1" + cCodPre, "NW0_CTS"))
						RecLock("NW0",.T.)
						NW0->NW0_FILIAL    := xFilial("NW0")
						NW0->NW0_CTS       := (cQryResTS)->NUE_COD
						NW0->NW0_SITUAC    := "1"
						NW0->NW0_PRECNF    := cCodPre
						NW0->NW0_CANC      := "2"
						NW0->NW0_CODUSR    := oParams:GetCodUser()
						NW0->NW0_COTAC1    := nVTAXA1
						NW0->NW0_COTAC2    := nVTAXA2
						NW0->NW0_COTAC     := JurCotac(nVTAXA1, nVTAXA2)
						NW0->NW0_CCLIEN    := cCCLIEN
						NW0->NW0_CLOJA     := cCLOJA
						NW0->NW0_CCASO     := cCCASO
						NW0->NW0_CPART1    := (cQryResTS)->NUE_CPART1
						NW0->NW0_TEMPOL    := (cQryResTS)->NUE_TEMPOL
						NW0->NW0_TEMPOR    := (cQryResTS)->NUE_TEMPOR
						NW0->NW0_VALORH    := (cQryResTS)->NUE_VALORH
						NW0->NW0_CMOEDA    := (cQryResTS)->NUE_CMOEDA
						NW0->NW0_DATATS    := StoD((cQryResTS)->NUE_DATATS)
						NW0->(MsUnlock())
						NW0->(DbCommit())
					EndIf
				Else  //Emissão de Conferência de pré / Reemissão de pré / Emissão de Fatura / Minuta de Fatura / Minuta de pré
					If oParams:GetTpExec() $ "3|4|5|MS"// Minutas / Fatura
						cSituac := "4"
					Else
						cSituac := "1"
					EndIf
					NW0->(DbSetOrder(1)) //  NW0_FILIAL+NW0_CTS+NW0_SITUAC+NW0_PRECNF+NW0_CFATUR+NW0_CESCR+NW0_CWO
					If (NW0->(MsSeek( xFilial("NW0") + (cQryResTS)->NUE_COD + cSituac + cCodPre + cFatura + cEscr ) ))
						RecLock("NW0",.F., .F., .F., .T.)
						NW0->NW0_COTAC1    := nVTAXA1
						NW0->NW0_COTAC2    := nVTAXA2
						NW0->NW0_COTAC     := JurCotac(nVTAXA1, nVTAXA2)
						NW0->NW0_CCLIEN    := cCCLIEN
						NW0->NW0_CLOJA     := cCLOJA
						NW0->NW0_CCASO     := cCCASO
						NW0->NW0_CPART1    := (cQryResTS)->NUE_CPART1
						NW0->NW0_TEMPOL    := (cQryResTS)->NUE_TEMPOL
						NW0->NW0_TEMPOR    := (cQryResTS)->NUE_TEMPOR
						NW0->NW0_VALORH    := (cQryResTS)->NUE_VALORH
						NW0->NW0_CMOEDA    := (cQryResTS)->NUE_CMOEDA
						NW0->NW0_DATATS    := StoD((cQryResTS)->NUE_DATATS)
						NW0->(MsUnlock())
						NW0->(DbCommit())

					EndIf
				EndIf

				// Grava na fila de sincronização
				If lIncFila .And. !(oParams:GetTpExec() $ "3|4|MS") // Se for minuta não adiciona a NUE na fila
					J170GRAVA("NUE", xFilial("NUE") + (cQryResTS)->NUE_COD, "4")
				EndIf

				If ( oParams:GetTpExec() $ "1" .And. oParams:GetSituac() <> "1" ) // Emissão de pré
					oParams:PtInternal(STR0010) // "Emitindo - Totaliza Caso - Abrir Query TS(Abriu) - Atualizar a Cotação na NXR"
				EndIf

				J201DCotac(cCodPre, cNUEMOEDA, nVTAXA1)

				(cQryResTS)->(DbSkip())

			EndDo
			(cQryResTS)->(DbCloseArea())

			// Totaliza Advg -- se tiver TS vinculado, totaliza.
			If (nContaTS > 0) .Or. oParams:GetTsZero()

				cQueryPar := " SELECT NUE.NUE_CPART2, NUE.NUE_CCATEG, "
				cQueryPar +=        " SUM(CASE WHEN NUE.NUE_COBRAR = '2' THEN 0 ELSE NUE_UTL END) NUE_UTL, "
				cQueryPar +=        " SUM(CASE WHEN NRC.NRC_PART = '1' THEN 0 ELSE NUE_UTR END) NUE_UTR, "
				cQueryPar +=        " SUM(CASE WHEN NRC.NRC_PART = '2' THEN 0 ELSE NUE_UTR END) NUE_UTC, "
				cQueryPar +=        " SUM(NUE.NUE_VALOR) NUE_VALOR, "
				cQueryPar +=        " SUM(NUE.NUE_VALOR1) NUE_VALOR1, "
				cQueryPar +=        Iif(lDataVinc, " NW0.NW0_DTVINC, ", " '        ' NW0_DTVINC, " )  
				cQueryPar +=        " NUE.NUE_VALORH, NUE.NUE_CLTAB, NUE.NUE_CMOEDA, "

				// Se considera TimeSheet não cobrável avalia se o TS é não cobrável
				// no próprio TS (NUE), na atividade (NRC), ou na atividade não cobrável do contrato (NTJ)
				If lTSNCobra .And. oParams:GetSituac() <> '1' .And. !Empty(cCodContr)
					cQueryPar +=     " CASE WHEN NUE.NUE_COBRAR = '2' THEN '2' "
					cQueryPar +=          " ELSE CASE WHEN NRC.NRC_TEMPOZ = '2' THEN '2' "
					cQueryPar +=                    " ELSE CASE WHEN ISNULL(NTJ.NTJ_CCONTR, '') = '' THEN '1' "
					cQueryPar +=                              " ELSE '2' "
					cQueryPar +=                          " END "
					cQueryPar +=                " END "
					cQueryPar +=     " END NUE_COBRAR"
				Else
					cQueryPar += "NUE.NUE_COBRAR "
				EndIf

				cQueryPar +=  " FROM " + RetSqlName("NRC") + " NRC   "
				cQueryPar +=       " INNER JOIN "+ RetSqlName("NUE") + " NUE  ON (NUE.NUE_FILIAL = '" + xFilial("NUE") +"' AND "
				cQueryPar +=                                                            " NUE.NUE_CATIVI = NRC.NRC_COD AND "
				cQueryPar +=                                                            " NUE.NUE_CCLIEN = '" + cCCLIEN +"' AND "
				cQueryPar +=                                                            " NUE.NUE_CLOJA = '" + cCLOJA  +"' AND "
				cQueryPar +=                                                            " NUE.NUE_CCASO = '" + cCCASO  +"' AND "
				If !oParams:GetTsZero()
					cQueryPar +=                                                        " NUE.NUE_CMOEDA > '" + Space(TamSx3('NUE_CMOEDA')[1]) +"' AND "
				EndIf
				cQueryPar +=                                                            " NUE.D_E_L_E_T_ = ' ') "
				If !Empty(oParams:GetDIniH()) .And. !Empty(oParams:GetDFinH())
					If lTSNCobra .And. oParams:GetSituac() <> '1' .And. !Empty(cCodJun)
						cQueryPar +=" INNER JOIN " + RetSqlName("NW3") + " NW3 "
						cQueryPar +=   " ON NW3.NW3_FILIAL = '" + xFilial("NW3") + "' "
						cQueryPar +=  " AND NW3.NW3_CJCONT = '" + cCodJun + "' "
						cQueryPar +=  " AND NW3.D_E_L_E_T_ = ' ' "

						lTemJunc := .T.
					EndIf
					
					cQueryPar += J201DVigCtr("NUE", "NUE_DATATS", cNT0COD, DtoS(oParams:GetDIniH()), DtoS(oParams:GetDFinH()), lFatAtiva, lTemJunc, oParams:GetTpExec(), cCodPre)
				EndIf
				If ( oParams:GetTpExec() $ "1|2|6" .And. oParams:GetSituac() <> "1" )  // Emissão de Pré / Reemissão de Pré
					//
				Else
					cQueryPar +=   " INNER JOIN "+ RetSqlName("NW0") + " NW0  ON (NW0.NW0_FILIAL = '" + xFilial("NW0") +"' AND "
					cQueryPar +=                                                              " NW0.NW0_CTS = NUE.NUE_COD AND "
					cQueryPar +=                                                              " NW0.NW0_CANC = '2' AND "
					If oParams:GetTpExec() $ "1" .And. oParams:GetSituac() = "1"  //Conferência de Pré
						cQueryPar +=                                                              " NW0.NW0_PRECNF	= '" + cCodPre +"' AND "
						cQueryPar +=                                                              " NW0.NW0_SITUAC = '1' AND "
					Else //Fatura / Minuta Fatura / Minuta Pré
						cQueryPar +=                                                              " NW0.NW0_CFATUR = '" + cFatura +"' AND "
						cQueryPar +=                                                              " NW0.NW0_CESCR = '" + cEscr +"' AND "
						cQueryPar +=                                                              " NW0.NW0_SITUAC = '4' AND "
					EndIf
					cQueryPar +=                                                              " NW0.D_E_L_E_T_ = ' ' )"
				EndIf
				If !oParams:GetTsZero()
					cQueryPar +=       " LEFT OUTER JOIN "+ RetSqlName("NV0") + " NV0 ON (NV0.NV0_FILIAL = '" + xFilial("NV0") +"' AND "
					cQueryPar +=                                                             " NV0.NV0_CCLIEN = NUE.NUE_CCLIEN AND "
					cQueryPar +=                                                             " NV0.NV0_CLOJA = NUE.NUE_CLOJA AND "
					cQueryPar +=                                                             " NV0.NV0_CCASO = NUE.NUE_CCASO AND "
					cQueryPar +=                                                             " NV0.NV0_CPART = NUE.NUE_CPART2 AND "
					cQueryPar +=                                                             " NUE.NUE_ANOMES BETWEEN NV0.NV0_AMINI AND  "
					cQueryPar +=                                                                           " (CASE WHEN NV0.NV0_AMFIM = '"+ Space(TamSx3('NV0_AMFIM')[1])+"' THEN  "
					cQueryPar +=                                                                                 " '"+ SubString(DtoS(Date()),1,6) +"' ELSE  "
					cQueryPar +=                                                                                 " NV0.NV0_AMFIM END) AND "
					cQueryPar +=                                                             " NV0.D_E_L_E_T_ = ' ') "
				EndIf

				If lTSNCobra .And. oParams:GetSituac() <> '1' // Se considera TimeSheet não cobrável e não é conferência faz o join com a atividade não cobrável do contrato
					cQueryPar +=    " LEFT JOIN " + RetSqlName("NTJ") + " NTJ "
					cQueryPar +=      " ON NTJ.NTJ_FILIAL = '" + xFilial("NTJ") + "' "
					If !Empty(cCodJun)
						cQueryPar += " AND NTJ.NTJ_CCONTR = NW3.NW3_CCONTR "
					Else
						cQueryPar += " AND NTJ.NTJ_CCONTR =  '" + cCodContr + "' "
					EndIf
					cQueryPar +=     " AND NTJ.NTJ_CTPATV = NUE.NUE_CATIVI "
					cQueryPar +=     " AND NTJ.D_E_L_E_T_ = ' ' "
				EndIf

				cQueryPar += " WHERE NRC.NRC_FILIAL = '" + xFilial("NRC") +"' "
				If !lAtivNaoC .And. !lTSNCobra .And. oParams:GetSituac() <> '1'
					cQueryPar += " AND NRC.NRC_TEMPOZ = '1' "
				EndIf
				If ( oParams:GetTpExec() $ "1|2|6" .And. oParams:GetSituac() <> "1" )  // Emissão de Pré / Reemissão de Pré
					cQueryPar += " AND NUE.NUE_CPREFT = '" + cCodPre +"' "
				EndIf

				cQueryPar +=     " AND NRC.D_E_L_E_T_ = ' ' "
				cQueryPar +=   " GROUP BY " + Iif(lDataVinc, " NW0.NW0_DTVINC, ", "") + " NUE.NUE_CPART2, NUE.NUE_CCATEG, NUE.NUE_VALORH, NUE.NUE_CLTAB, NUE.NUE_CMOEDA, NUE.NUE_COBRAR " + IIf(lTSNCobra .And. oParams:GetSituac() <> '1', ", NRC.NRC_TEMPOZ,  NTJ.NTJ_CCONTR", "")
				cQueryPar +=   " ORDER BY " + Iif(lDataVinc, " NW0.NW0_DTVINC, ", "") + " NUE.NUE_CPART2, NUE.NUE_CCATEG, NUE.NUE_VALORH, NUE.NUE_CLTAB, NUE.NUE_CMOEDA, NUE.NUE_COBRAR " + IIf(lTSNCobra .And. oParams:GetSituac() <> '1', ", NRC.NRC_TEMPOZ,  NTJ.NTJ_CCONTR", "")

				oParams:PtInternal(STR0004 + AllTrim(Str(nContaTS)) + STR0011) // "Emitindo - Totaliza Caso - Abrir Query TS(Abriu)" # " - Totaliza Advg"

				aCampos := {"NUE_COBRAR","NUE_CPART2","NUE_CCATEG","NUE_UTL","NUE_UTR", "NUE_UTC",;      //6
				            "NUE_VALORH","NUE_VALOR1","NUE_CMOEDA","NUE_VALOR","NUE_CLTAB","NW0_DTVINC"} //12

				aPart := JurSql(cQueryPar, aCampos, .T.)

				For nI := 1 To Len(aPart)
					
					If aPart[nI][1] == '1' .Or. oParams:GetSituac() == '1' // Cobrar Sim ou Conferência
						nUTCli     := 0
						nHrFracCli := 0
						cHoraMinC  := PADL('0000:00', TamSX3('NX2_HRCLI')[1], '0')
						nUTRev     := 0
						nHrFracRev := 0
						cHoraMinR  := PADL('0000:00', TamSX3('NX2_HORAR')[1], '0')

						nUTLanc    := aPart[nI][4] * nDivTS
						nHrFracLan := Val(JURA144C1(1, 2, Str(nUTLanc)))
						cHoraMinL  := PADL(JURA144C1(1, 3, Str(nUTLanc), 4), TamSX3('NX2_HRLANC')[1], '0')

						If aPart[nI][5] > 0 // Sem participação do cliente
							nUTRev     := aPart[nI][5] * nDivTS
							nHrFracRev := Val(JURA144C1(1, 2, Str(nUTRev)))
							cHoraMinR  := PADL(JURA144C1(1, 3, Str(nUTRev), 4), TamSX3('NX2_HORAR')[1],  '0')
						EndIf

						If aPart[nI][6] > 0 // Com participação do cliente
							nUTCli     := aPart[nI][6] * nDivTS
							nHrFracCli := Val(JURA144C1(1, 2, Str(nUTCli)))
							cHoraMinC  := PADL(JURA144C1(1, 3, Str(nUTCli), 4), TamSX3('NX2_HORAR')[1],  '0')
						EndIf

						If Empty(aPart[nI][11])
							nTSCaso := nTSCaso + aPart[nI][8] //Acumula o total do valor de TimeSheet Cobrável para verificão de arredondanemnto
						EndIf
						cAnoMesVin  := AnoMes(SToD(aPart[nI][12]))

						If oParams:GetTpExec() $ "1|2|6" //Emissão / Reemissão de pré-Fatura ou conferência
							RecLock("NX2",.T.)
							NX2->NX2_FILIAL  := xFilial("NX2")
							NX2->NX2_CPREFT  := cCodPre
							NX2->NX2_CPART   := aPart[nI][2]
							NX2->NX2_CCATEG  := aPart[nI][3]
							NX2->NX2_CCLIEN  := cCCLIEN
							NX2->NX2_CLOJA   := cCLOJA
							NX2->NX2_CCONTR  := cNT0COD
							NX2->NX2_CCASO   := cCCASO
							NX2->NX2_UTCLI   := nUTCli
							NX2->NX2_HRCLI   := cHoraMinC
							NX2->NX2_HFCLI   := nHrFracCli
							NX2->NX2_UTLANC  := nUTLanc
							NX2->NX2_HRLANC  := cHoraMinL
							NX2->NX2_HFLANC  := nHrFracLan
							NX2->NX2_UTR     := nUTRev
							NX2->NX2_HORAR   := cHoraMinR
							NX2->NX2_TEMPOR  := nHrFracRev
							NX2->NX2_VALORH  := aPart[nI][7]
							NX2->NX2_VALOR1  := Round(aPart[nI][8] * nDivTS, nDecParVlr) // Quando for conferência e o TS for não cobrável grava 0
							NX2->NX2_CMOTBH  := aPart[nI][9]
							NX2->NX2_VLHTBH  := Round(aPart[nI][10] * nDivTS, nDecParAdv)
							NX2->NX2_CLTAB   := aPart[nI][11]
							NX2->NX2_CMOPRE  := cMoedPF
							NX2->NX2_CODSEQ  := PADL(AllTrim(str(nI)), tamSX3('NX2_CODSEQ')[1], '0')
							NX2->(MsUnlock())
							NX2->(DbCommit())

							If NX2->NX2_VALOR1 > nMaiorPar
								nMaiorPar := NX2->NX2_VALOR1
								nRecnoPar := NX2->(Recno())
							EndIf
						Else
							cNXDSeq := PADL(AllTrim(str(nI)), tamSX3('NXD_CSEQ')[1], '0')
							If !Empty(cCodJun) .And. !Empty(JurGetDados("NXD", 3, xFilial("NXD") + cFatura + cEscr + cNT0COD + cCCLIEN + cCLOJA + cCCASO + aPart[nI][2] + cNXDSeq, "NXD_CFATUR"))
								Loop
							EndIf
							RecLock("NXD",.T.)
							NXD->NXD_FILIAL  := xFilial("NXD")
							NXD->NXD_CFATUR  := cFatura
							NXD->NXD_CESCR   := cEscr
							NXD->NXD_CPART   := aPart[nI][2]
							NXD->NXD_CCATEG  := aPart[nI][3]
							NXD->NXD_CCLIEN  := cCCLIEN
							NXD->NXD_CLOJA   := cCLOJA
							NXD->NXD_CCONTR  := cNT0COD
							NXD->NXD_CCASO   := cCCASO
							NXD->NXD_UTCLI   := nUTCli
							NXD->NXD_HRCLI   := cHoraMinC
							NXD->NXD_HFCLI   := nHrFracCli
							NXD->NXD_UTLANC  := nUTLanc
							NXD->NXD_HRLANC  := cHoraMinL
							NXD->NXD_HFLANC  := nHrFracLan
							NXD->NXD_UTREV   := nUTRev
							NXD->NXD_HRREV   := cHoraMinR
							NXD->NXD_HFREV   := nHrFracRev
							NXD->NXD_VLHORA  := aPart[nI][7]
							NXD->NXD_VLCORR  := Round(aPart[nI][8] * nDivTS, nDecParVlr)
							NXD->NXD_CMOEDT  := aPart[nI][9]
							NXD->NXD_VLADVG  := Round(aPart[nI][10] * nDivTS, nDecParAdv)
							NXD->NXD_CODTAB  := aPart[nI][11]
							NXD->NXD_CMOEDF  := cMoedPF
							NXD->NXD_CSEQ    := cNXDSeq
							If lDataVinc
								NXD->NXD_ANOMES := cAnoMesVin
							EndIf
							NXD->(MsUnlock())
							NXD->(DbCommit())

							If NXD->NXD_VLCORR > nMaiorPar
								nMaiorPar := NXD->NXD_VLCORR
								nRecnoPar := NXD->(Recno())
							EndIf
						EndIf

					EndIf

					//Variável para possibilitar a somatória de todos os TSs vinculados, inclusive não cobráveis
					nVSOMATSVINC := nVSOMATSVINC + IIF(oParams:GetSituac() == "1", aPart[nI][10], aPart[nI][8]) // Tratamento para conferência
				Next nI
				JurFreeArr(aPart)
			EndIf
		Else
			nContaTS := 0
		EndIf

		If cTEMDP == "1" .Or. (cTEMFX == "1" .And. Empty(cCodPre))
			nDecDesp := TamSX3('NVY_VALOR')[2]

			// Seleciona Despesas
			cQueryDP := " SELECT NVY.R_E_C_N_O_ RECNONVY, NVY.NVY_COD, NVY.NVY_VALOR, NVY.NVY_CMOEDA, NVY.NVY_DATA, NVY.NVY_CTPDSP, NVY.NVY_COBRAR "
			cQueryDP +=   " FROM " + RetSqlName("NVY") + " NVY  "
			If ( oParams:GetTpExec() $ "1|2|6" .And. oParams:GetSituac() <> "1" ) // Emissão de Pré / Reemissão de Pré
				//
			Else
				cQueryDP +=     " INNER JOIN " + RetSqlName("NVZ") + " NVZa  ON (NVZa.NVZ_FILIAL = '" + xFilial("NVZ") +"' AND "
				cQueryDP +=                                                            " NVZa.NVZ_CDESP  = NVY.NVY_COD AND "
				cQueryDP +=                                                            " NVZa.NVZ_CANC   = '2' AND "
				If oParams:GetTpExec() $ "1" .And. oParams:GetSituac() = "1" //Conferência de Pré
					cQueryDP +=                                                            " NVZa.NVZ_PRECNF = '" + cCodPre +"' AND "
					cQueryDP +=                                                            " NVZa.NVZ_SITUAC = '1' AND "
				Else //Fatura / Minuta Fatura / Minuta Pré
					cQueryDP +=                                                            " NVZa.NVZ_CFATUR = '" + cFatura +"' AND "
					cQueryDP +=                                                            " NVZa.NVZ_CESCR  = '" + cEscr +"' AND "
					cQueryDP +=                                                            " NVZa.NVZ_SITUAC = '4' AND "
				EndIf
				cQueryDP +=                                                            " NVZa.D_E_L_E_T_ = ' ' )"
			EndIf
			If !Empty(oParams:GetDIniD()) .And. !Empty(oParams:GetDFinD())
				cQueryDP += J201DVigCtr("NVY", "NVY_DATA", cNT0COD, DtoS(oParams:GetDIniD()), DtoS(oParams:GetDFinD()),,, oParams:GetTpExec(), cCodPre)
			EndIf
			cQueryDP +=   " WHERE NVY.NVY_FILIAL = '" + xFilial("NVY") + "' "
			If ( oParams:GetTpExec() $ "1|2|6" .And. oParams:GetSituac() <> "1" ) // Emissão de Pré / Reemissão de Pré
				cQueryDP += " AND NVY.NVY_CPREFT = '" + cCodPre + "' "
			EndIf
			cQueryDP +=     " AND NVY.NVY_CCLIEN = '" + cCCLIEN + "' "
			cQueryDP +=     " AND NVY.NVY_CLOJA = '" + cCLOJA + "' "
			cQueryDP +=     " AND NVY.NVY_CCASO = '" + cCCASO + "' "
			cQueryDP +=     " AND NVY.D_E_L_E_T_ = ' ' "
			If oParams:GetTpExec() $ "3|4|5|MS"
				cQueryDP +=  " ORDER BY NVY.NVY_CTPDSP "
			EndIf

			oParams:PtInternal(STR0012) // "Emitindo - Totaliza Caso - Abrir Query Despesa"

			cQueryDP := ChangeQuery(cQueryDP, .F.)
			DbCommitAll() // Para efetivar a alteração no banco de dados (não impacta no rollback da trasação)
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQueryDP ), cQryResDP, .T., .F. )

			oParams:PtInternal(STR0012) // "Emitindo - Totaliza Caso - Abrir Query Despesa"

			lDPData1 := !(cQryResDP)->(EOF())
			nContaDP := 0
			If lDPData1
				aTotTpDp := {{(cQryResDP)->NVY_CTPDSP, 0}}
			EndIf
			While !(cQryResDP)->(EOF())
				nContaDP := nContaDP + 1

				// Verifica a cotação da Despesa (data pelo MV_JCONVDS )
				If cConvDS == "1"
					dDataConv := oParams:GetDEmi()
					cCodFImp  := oParams:GetCFilaImpr()
					cTpExec   := oParams:GetTpExec()
				ElseIf cConvDS == "2"
					dDataConv := StoD((cQryResDP)->NVY_DATA)
					cCodFImp  := ""
					cTpExec   := "1"
				EndIf

				// Atualizar a cotação na NVZ
				// Verifica cotação do Time-Sheets (data do TS)
				aConvLanc    := JA201FConv(cMoedPF, (cQryResDP)->NVY_CMOEDA, (cQryResDP)->NVY_VALOR, cTpExec, dDataConv, cCodFImp, cCodPre )
				nVVALORTEMP  := Round(aConvLanc[1], nDecDesp)
				nVTAXA1      := aConvLanc[2] // Moeda da Condição (DP)
				nVTAXA2      := aConvLanc[3] // Moeda da Pré

				If (cQryResDP)->NVY_COBRAR == "1" .OR. oParams:GetSituac() == "1"
					nVSOMADESP   := nVSOMADESP + nVVALORTEMP

					If lDespTrib
						If JurDspTrib((cQryResDP)->NVY_CTPDSP, cEscrit)
							nVlDpTrib   += nVVALORTEMP
						Else
							nVlDpReemb  += nVVALORTEMP
						EndIf
					EndIf
				EndIf

				NVY->(DbGoto((cQryResDP)->RECNONVY))

				lIncFila := !lEmiPre .And. (NVY->NVY_COTAC1 <> nVTAXA1 .Or. NVY->NVY_COTAC2 <> nVTAXA2)

				If RecLock("NVY", .F., .F., .F., .T.)
					NVY->NVY_COTAC1    := nVTAXA1
					NVY->NVY_COTAC2    := nVTAXA2
					NVY->NVY_COTAC     := JurCotac(nVTAXA1, nVTAXA2)
					NVY->(MsUnlock())
					NVY->(DbCommit())
				EndIf

				//Atualizar a Cotação na NVZ
				//Se for Emissão, insere na NVZ, se for conferência, atualiza
				If ( oParams:GetTpExec() $ "1" .And. oParams:GetSituac() <> "1" )   //   Emissão de pré
					RecLock("NVZ", .T.)
					NVZ->NVZ_FILIAL    := xFilial("NVY")
					NVZ->NVZ_CDESP     := (cQryResDP)->NVY_COD
					NVZ->NVZ_SITUAC    := "1"
					NVZ->NVZ_PRECNF    := cCodPre
					NVZ->NVZ_CANC      := "2"
					NVZ->NVZ_CODUSR    := oParams:GetCodUser()
					NVZ->NVZ_COTAC1    := nVTAXA1
					NVZ->NVZ_COTAC2    := nVTAXA2
					NVZ->NVZ_COTAC     := JurCotac(nVTAXA1, nVTAXA2)
					NVZ->NVZ_CCLIEN    := cCCLIEN
					NVZ->NVZ_CLOJA     := cCLOJA
					NVZ->NVZ_CCASO     := cCCASO
					NVZ->NVZ_DTDESP    := sToD((cQryResDP)->NVY_DATA)
					NVZ->NVZ_CTPDSP    := (cQryResDP)->NVY_CTPDSP
					NVZ->NVZ_CMOEDA    := (cQryResDP)->NVY_CMOEDA
					NVZ->NVZ_VALORD    := (cQryResDP)->NVY_VALOR
					NVZ->(MsUnlock())
					NVZ->(DbCommit())
				Else  //Emissão de Conferência de pré / Reemissão de pré / Emissão de Fatura / Minuta de Fatura / Minuta de pré
					If oParams:GetTpExec()  $ "3|4|5|MS"// Minutas
						cSituac := "4"
					Else
						cSituac := "1"
					EndIf
					NVZ->(DbSetOrder(1)) //  NVZ_FILIAL+NVZ_CDESP+NVZ_SITUAC+NVZ_PRECNF+NVZ_CFATUR+NVZ_CESCR+NVZ_CWO
					If (NVZ->(MsSeek( xFilial("NVZ") + (cQryResDP)->NVY_COD + cSituac + cCodPre ) ))
						RecLock("NVZ", .F., .F., .F., .T.)
						NVZ->NVZ_COTAC1    := nVTAXA1
						NVZ->NVZ_COTAC2    := nVTAXA2
						NVZ->NVZ_COTAC     := JurCotac(nVTAXA1, nVTAXA2)
						NVZ->NVZ_CCLIEN    := cCCLIEN
						NVZ->NVZ_CLOJA     := cCLOJA
						NVZ->NVZ_CCASO     := cCCASO
						NVZ->NVZ_DTDESP    := sToD((cQryResDP)->NVY_DATA)
						NVZ->NVZ_CTPDSP    := (cQryResDP)->NVY_CTPDSP
						NVZ->NVZ_CMOEDA    := (cQryResDP)->NVY_CMOEDA
						NVZ->NVZ_VALORD    := (cQryResDP)->NVY_VALOR
						NVZ->(MsUnlock())
						NVZ->(DbCommit())
					EndIf
				EndIf

				// Grava na fila de sincronização
				If lIncFila .And. !(oParams:GetTpExec() $ "3|4|MS") // Se for minuta não adiciona a NVY na fila
					J170GRAVA("NVY", xFilial("NVY") + (cQryResDP)->NVY_COD, "4")
				EndIf

				If ( oParams:GetTpExec() $ "1" .And. oParams:GetSituac() <> "1" ) // Emissão de pré
					oParams:PtInternal(STR0013) // "Emitindo - Totaliza Caso - Abrir Query Despesa - Atualizar a Cotação na NXR"
				EndIf

				If cConvDS == "1" //Só grava a cotação se ela não vir da data do lançamento
					J201DCotac(cCodPre, (cQryResDP)->NVY_CMOEDA, nVTAXA1 )
				EndIf

				If oParams:GetTpExec()  $ "3|4|5|MS" // Totaliza Despesas por tipo (somente para fatura )
					nVlTpDesp := Round(JA201FConv(cMoeNac, (cQryResDP)->NVY_CMOEDA, (cQryResDP)->NVY_VALOR, oParams:GetTpExec(), dDataConv , oParams:GetCFilaImpr(), cCodPre )[1], nDecDesp)
					If nVlTpDesp > 0
						If (nPos := aScan( aTotTpDp, { |aX| aX[1] == (cQryResDP)->NVY_CTPDSP} )) > 0
							aTotTpDp[nPos,2] := aTotTpDp[nPos, 2] + nVlTpDesp
						Else
							Aadd(aTotTpDp, {(cQryResDP)->NVY_CTPDSP, nVlTpDesp})
						EndIf
					EndIf
				EndIf

				(cQryResDP)->(DbSkip())

			EndDo
			(cQryResDP)->(DbCloseArea())

			If oParams:GetTpExec() $ "3|4|5|MS"
				For nI := 1 To Len(aTotTpDp)
					If Empty(cCodJun) .Or. !J201DExNXE(cFatura, cEscr, cCCLIEN, cCLOJA, cCCASO, aTotTpDp[nI, 1])
						RecLock("NXE", .T.)
						NXE->NXE_FILIAL := xFilial("NXE")
						NXE->NXE_CFATUR := cFatura
						NXE->NXE_CESCR  := cEscr
						NXE->NXE_FILIAD := xFilial("NVY")
						NXE->NXE_CCLIEN := cCCLIEN
						NXE->NXE_CLOJA  := cCLOJA
						NXE->NXE_CCASO  := cCCASO
						NXE->NXE_CTPDSP := aTotTpDp[nI, 1]
						NXE->NXE_CMOEDE := cMoeNac
						NXE->NXE_VLDESP := aTotTpDp[nI, 2]
						NXE->(MsUnlock())
						NXE->(DbCommit())
					EndIf
				Next nI
			EndIf

		Else
			nContaDP := 0
		EndIf

		If cTEMLT == "1"
			// Seleciona Tabelados
			nDecTab      := TamSX3('NV4_VLHFAT')[2]

			cQueryLT := " SELECT NV4.R_E_C_N_O_ RECNONV4, NV4.NV4_COD, NV4.NV4_VLHFAT, NV4.NV4_CMOEH, "
			cQueryLT +=        " NV4.NV4_DTLANC, NV4.NV4_DTCONC, NRD.NRD_COBMAI, NV4.NV4_CPART, NV4.NV4_COBRAR "
			cQueryLT +=   " FROM " + RetSqlName("NV4") + " NV4 "
			cQueryLT +=        " INNER JOIN " + RetSqlName("NRD") + " NRD ON (NRD.NRD_FILIAL = '" + xFilial("NRD") +"' AND "
			cQueryLT +=                                                     " NRD.NRD_COD = NV4.NV4_CTPSRV AND "
			cQueryLT +=                                                     " NRD.D_E_L_E_T_ = ' ') "
			If oParams:GetSituac() == "1"  // Se for conferência, traz os Lanctos da temp
				cQueryLT +=        " INNER JOIN " + RetSqlName("NW4") + " NW4a ON (NW4a.NW4_FILIAL = '" + xFilial("NW4") +"' AND "
				cQueryLT +=                                                      " NW4a.NW4_CLTAB = NV4.NV4_COD AND "
				cQueryLT +=                                                      " NW4a.NW4_PRECNF = '" + cCodPre +"' AND "
				cQueryLT +=                                                      " NW4a.NW4_SITUAC = '1' AND "
				cQueryLT +=                                                      " NW4a.NW4_CANC = '2' AND "
				cQueryLT +=                                                      " NW4a.D_E_L_E_T_ = ' ') "
			EndIf
			If !Empty(oParams:GetDIniT()) .And. !Empty(oParams:GetDFinT())
				cQueryLT += J201DVigCtr("NV4", "NV4_DTCONC", cNT0COD, DtoS(oParams:GetDIniT()), DtoS(oParams:GetDFinT()),,, oParams:GetTpExec(), cCodPre)
			EndIf
			cQueryLT += " WHERE NV4.NV4_FILIAL = '" + xFilial("NV4") +"' "
			If !oParams:GetSituac() == "1"  // Se não for emissão, tras os separados para a pré
				cQueryLT += " AND NV4.NV4_CPREFT = '" + cCodPre +"' "
			EndIf
			cQueryLT +=     " AND NV4.NV4_CCLIEN = '" + cCCLIEN +"' "
			cQueryLT +=     " AND NV4.NV4_CLOJA = '" + cCLOJA +"' "
			cQueryLT +=     " AND NV4.NV4_CCASO = '" + cCCASO +"' "
			cQueryLT +=     " AND NV4.D_E_L_E_T_ = ' ' "

			oParams:PtInternal(STR0014) // "Emitindo - Totaliza Caso - Abrir Query Tabelado"

			cQueryLT := ChangeQuery(cQueryLT, .F.)
			DbCommitAll() // Para efetivar a alteração no banco de dados (não impacta no rollback da trasação)
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQueryLT ), cQryResLT, .T., .F. )

			oParams:PtInternal(STR0015) // "Emitindo - Totaliza Caso - Abrir Query Tabelado (Abriu)"

			lLTData := !(cQryResLT)->(EOF())
			nContaTB := 0
			While !(cQryResLT)->(EOF())
				nContaTB := nContaTB + 1
				// Verifica a cotação do Serviço (data pelo MV_JCONVLT )
				// Atualizar a cotação na NW4
				If cConvLT == "1" // Data Emissão
					dDataConv := oParams:GetDEmi()
					cCodFImp  := oParams:GetCFilaImpr()
					cTpExec   := oParams:GetTpExec()
				ElseIf cConvLT == "2" //Data de inclusão
					dDataConv := StoD((cQryResLT)->NV4_DTLANC)
					cCodFImp  := ""
					cTpExec   := "1"
				ElseIf cConvLT == "3" //Data de Conclusão
					dDataConv := StoD((cQryResLT)->NV4_DTCONC)
					cCodFImp  := ""
					cTpExec   := "1"
				EndIf

				// Atualizar a cotação na NW4
				// Verifica cotação dos Tabelados
				aConvLanc   := JA201FConv(cMoedPF, (cQryResLT)->NV4_CMOEH, (cQryResLT)->NV4_VLHFAT, cTpExec, dDataConv, cCodFImp, cCodPre)
				nVVALORTEMP := Round(aConvLanc[1], nDecTab)
				nVTAXA1     := aConvLanc[2] // Moeda da Condição (TB)
				nVTAXA2     := aConvLanc[3] // Moeda da Pré
				nCobMaior   := nVVALORTEMP

				If (cQryResLT)->NRD_COBMAI == "1"   // verifica a regra do cobra maior entre Lançamento Tabelado e Time Sheet
					If (nPos := aScan( aTabVinc, { |ax| ax[1] == (cQryResLT)->NV4_COD } )) > 0
						If aTabVinc[nPos][2] > nVVALORTEMP
							nCobMaior := aTabVinc[nPos][2]
						EndIf
					EndIf
				EndIf

				If (cQryResLT)->NV4_COBRAR == "1" .OR. oParams:GetSituac() == "1"
					nVSOMALTAB := nVSOMALTAB + nCobMaior
				EndIf
				
				nVSOMALTVINC := nVSOMALTVINC + nVVALORTEMP

				NV4->(DbGoto((cQryResLT)->RECNONV4))

				lIncFila := !lEmiPre .And. (NV4->NV4_COTAC1 <> nVTAXA1 .Or. NV4->NV4_COTAC2 <> nVTAXA2)

				If RecLock("NV4", .F., .F., .F., .T.)
					NV4->NV4_COTAC1 := nVTAXA1
					NV4->NV4_COTAC2 := nVTAXA2
					NV4->NV4_COTAC  := JurCotac(nVTAXA1, nVTAXA2)
					NV4->(MsUnlock())
				EndIf

				//Atualizar a Cotação na NW4
				//Se for Emissão, insere na NW4, se for conferência, atualiza
				If ( oParams:GetTpExec() $ "1" .And. oParams:GetSituac() <> "1" )  //   Emissão de pré
					RecLock("NW4",.T.)
					NW4->NW4_FILIAL    := xFilial("NW4")
					NW4->NW4_CLTAB     := (cQryResLT)->NV4_COD
					NW4->NW4_SITUAC    := "1"
					NW4->NW4_PRECNF    := cCodPre
					NW4->NW4_CANC      := "2"
					NW4->NW4_CODUSR    := oParams:GetCodUser()
					NW4->NW4_COTAC1    := nVTAXA1
					NW4->NW4_COTAC2    := nVTAXA2
					NW4->NW4_COTAC     := JurCotac(nVTAXA1, nVTAXA2)
					NW4->NW4_CCLIEN    := cCCLIEN
					NW4->NW4_CLOJA     := cCLOJA
					NW4->NW4_CCASO     := cCCASO
					NW4->NW4_CPART1    := (cQryResLT)->NV4_CPART
					NW4->NW4_DTCONC    := SToD((cQryResLT)->NV4_DTCONC)
					NW4->NW4_VALORH    := (cQryResLT)->NV4_VLHFAT
					NW4->NW4_CMOEDH    := (cQryResLT)->NV4_CMOEH
					NW4->(MsUnlock())
					NW4->(DbCommit())
					// Grava na fila de sincronização
					If lIncFila .And. !(oParams:GetTpExec() $ "3|4|MS") // Se for minuta não adiciona a NV4 na fila
						J170GRAVA("NV4", xFilial("NV4") + (cQryResLT)->NV4_COD, "4")
					EndIf
				Else  //Emissão de Conferência de pré / Reemissão de pré / Emissão de Fatura / Minuta de Fatura / Minuta de pré
					If oParams:GetTpExec() $ "3|4|5|MS"// Minutas
						cSituac := "4"
					Else
						cSituac := "1"
					EndIf
					NW4->(DbSetOrder(1))  // NW4_FILIAL+NW4_CLTAB+NW4_CWO+NW4_CFATUR+NW4_CESCR+NW4_PRECNF+NW4_SITUAC
					If (NW4->(MsSeek( xFilial("NW4") + (cQryResLT)->NV4_COD + Space(TamSX3('NW4_CWO')[1]) + cFatura + cEscr + cCodPre + cSituac ) ))
						RecLock("NW4", .F., .F., .F., .T.)
						NW4->NW4_COTAC1    := nVTAXA1
						NW4->NW4_COTAC2    := nVTAXA2
						NW4->NW4_COTAC     := JurCotac(nVTAXA1, nVTAXA2)
						NW4->NW4_CCLIEN    := cCCLIEN
						NW4->NW4_CLOJA     := cCLOJA
						NW4->NW4_CCASO     := cCCASO
						NW4->NW4_CPART1    := (cQryResLT)->NV4_CPART
						NW4->NW4_DTCONC    := SToD((cQryResLT)->NV4_DTCONC)
						NW4->NW4_VALORH    := (cQryResLT)->NV4_VLHFAT
						NW4->NW4_CMOEDH    := (cQryResLT)->NV4_CMOEH
						NW4->(MsUnlock())
						NW4->(DbCommit())
						// Grava na fila de sincronização
						If lIncFila .And. !(oParams:GetTpExec() $ "3|4|MS") // Se for minuta não adiciona a NV4 na fila
							J170GRAVA("NV4", xFilial("NV4") + (cQryResLT)->NV4_COD, "4")
						EndIf
					EndIf
				EndIf

				If ( oParams:GetTpExec() $ "1" .And. oParams:GetSituac() <> "1" ) // Emissão de pré
					oParams:PtInternal(STR0016) // "Emitindo - Totaliza Caso - Abrir Query Tabelado - Atualizar a Cotação na NXR"
				EndIf

				If cConvLT == "1" //Só grava a cotação se ela não vir da data do lançamento
					J201DCotac(cCodPre, (cQryResLT)->NV4_CMOEH, nVTAXA1 )
				EndIf

				(cQryResLT)->(DbSkip())

			EndDo
			(cQryResLT)->(DbCloseArea())

		Else
			nContaTB := 0
		EndIf

		If oParams:GetTpExec() $ "1|2|6"  // Emissão de Pré / Reemissão de Pré / Cancelamento de Fatura e Reemisão de Pré
			cQueryPar := " select SUM(NX2.NX2_VALOR1) as VTS "
			cQueryPar += " from " + RetSqlName("NX2") + " NX2  "
			cQueryPar +=  " where NX2.NX2_FILIAL = '" + xFilial("NX2") +"'"
			cQueryPar +=    " and NX2.NX2_CPREFT = '" + cCodPre +"'"
			cQueryPar +=    " and NX2.NX2_CCONTR = '"+ cNT0COD +"'"
			cQueryPar +=    " and NX2.NX2_CCLIEN = '" + cCCLIEN +"'"
			cQueryPar +=    " and NX2.NX2_CLOJA = '" + cCLOJA +"'"
			cQueryPar +=    " and NX2.NX2_CCASO = '" + cCCASO +"'"
			cQueryPar +=    " and NX2.NX2_CLTAB = '"+ Space(TamSX3("NX2_CLTAB")[1])+"' "
			cQueryPar +=    " and NX2.D_E_L_E_T_ = ' ' "
		Else //Fatura / Minuta Fatura / Minuta Pré
			cQueryPar := " select SUM(NXD.NXD_VLCORR) as VTS "
			cQueryPar += " from " + RetSqlName("NXD") + " NXD "
			cQueryPar +=  " where NXD.NXD_FILIAL = '" + xFilial("NXD") +"' "
			cQueryPar +=    " and NXD.NXD_CFATUR = '" + cFatura +"' "
			cQueryPar +=    " and NXD.NXD_CESCR = '" + cEscr +"' "
			cQueryPar +=    " and NXD.NXD_CCONTR = '"+ cNT0COD +"'"
			cQueryPar +=    " and NXD.NXD_CCLIEN = '" + cCCLIEN +"' "
			cQueryPar +=    " and NXD.NXD_CLOJA = '" + cCLOJA  +"' "
			cQueryPar +=    " and NXD.NXD_CCASO = '" + cCCASO  +"' "
			cQueryPar +=    " and NXD.NXD_CODTAB = '"+ Space(TamSX3("NXD_CODTAB")[1]) + "' "
			cQueryPar +=    " and NXD.D_E_L_E_T_ = ' ' "
		EndIf

		cQueryPar := ChangeQuery(cQueryPar, .F.)
		DbCommitAll() // Para efetivar a alteração no banco de dados (não impacta no rollback da trasação)
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQueryPar ), cQryResPar, .T., .F. )

		nTotalPar := (cQryResPar)->VTS

		If (nTSCaso != nTotalPar) .And. nRecnoPar > 0  //Ajusta o saldo da mudança de casas decimais
			nVSOMATS   := nTSCaso * nDivTS
			nSaldoPart := nVSOMATS - nTotalPar

			If oParams:GetTpExec() $ "1|2|6"
				NX2->(DbGoTo(nRecnoPar))
				If !NX2->(EOF())
					RecLock("NX2", .F.)
					NX2->NX2_VALOR1 := Round(NX2->NX2_VALOR1 + nSaldoPart, nDecParVlr)
					NX2->(MsUnlock())
					NX2->(DbCommit())
				EndIf
			Else
				NXD->(DbGoTo(nRecnoPar))
				If !NXD->(EOF())
					RecLock("NXD", .F.)
					NXD->NXD_VLCORR := Round(NXD->NXD_VLCORR + nSaldoPart, nDecParVlr)
					NXD->(MsUnlock())
					NXD->(DbCommit())
				EndIf
			EndIf
		Else
			nVSOMATS := nTotalPar
		EndIf

		(cQryResPar)->(DbCloseArea())

		If cTEMFA == "1"

			// Honorários
			nVSOMATSVINC := nVSOMATS + nVTSNCobra
			If (cQryRes)->NVV_TPRAT == "2" //Faz o reteio por percentual
				aConvLanc := JA201FConv(cMoedPF, (cQryRes)->NVV_CMOE1, (cQryRes)->NVV_VALORH, oParams:GetTpExec(), oParams:GetDEmi(), oParams:GetCFilaImpr(), cCodPre )
				nVSOMATS  := Round(aConvLanc[1] * ((cQryRes)->NVW_VALORH/100.00), TamSX3('NVW_VALORH')[2])
			Else
				aConvLanc := JA201FConv(cMoedPF, (cQryRes)->NVV_CMOE1, (cQryRes)->NVW_VALORH, oParams:GetTpExec(), oParams:GetDEmi(), oParams:GetCFilaImpr(), cCodPre )
				nVSOMATS  := Round(aConvLanc[1], TamSX3('NVW_VALORH')[2])
			EndIf

			// Despesas
			If (cQryRes)->NVV_DSPCAS == "2" //Não utiliza o valor de despesas do caso
				If (cQryRes)->NVV_TPRAT == "2"
					aConvLanc  := JA201FConv(cMoedPF, (cQryRes)->NVV_CMOE2, (cQryRes)->NVV_VALORD, oParams:GetTpExec(), oParams:GetDEmi(), oParams:GetCFilaImpr(), cCodPre)
					nVlDpReemb := Round(aConvLanc[1]*((cQryRes)->NVW_VALORD/100.00), TamSX3('NVW_VALORD')[2])

					If lDespTrib
						aConvLanc  := JA201FConv(cMoedPF, (cQryRes)->NVV_CMOE2, (cQryRes)->NVV_VALDTR, oParams:GetTpExec(), oParams:GetDEmi(), oParams:GetCFilaImpr(), cCodPre)
						nVlDpTrib  := Round(aConvLanc[1]*((cQryRes)->NVW_VALDTR/100.00), TamSX3('NVW_VALDTR')[2])
					EndIf

					nVSOMADESP := nVlDpReemb + nVlDpTrib
				Else
					aConvLanc  := JA201FConv(cMoedPF, (cQryRes)->NVV_CMOE2, (cQryRes)->NVW_VALORD, oParams:GetTpExec(), oParams:GetDEmi(), oParams:GetCFilaImpr(), cCodPre)
					nVlDpReemb := Round(aConvLanc[1], TamSX3('NVW_VALORD')[2])

					If lDespTrib
						aConvLanc  := JA201FConv(cMoedPF, (cQryRes)->NVV_CMOE2, (cQryRes)->NVW_VALDTR, oParams:GetTpExec(), oParams:GetDEmi(), oParams:GetCFilaImpr(), cCodPre)
						nVlDpTrib  := Round(aConvLanc[1], TamSX3('NVW_VALDTR')[2])
					EndIf

					nVSOMADESP := nVlDpReemb + nVlDpTrib
				EndIf
			EndIf

			//Tabelado
			nVSOMALTVINC := nVSOMALTAB
			If (cQryRes)->NVV_TPRAT == "2"
				aConvLanc  := JA201FConv(cMoedPF, (cQryRes)->NVV_CMOE4, (cQryRes)->NVV_VALORT, oParams:GetTpExec(), oParams:GetDEmi(), oParams:GetCFilaImpr(), cCodPre)
				nVSOMALTAB  := Round(aConvLanc[1]*((cQryRes)->NVW_VALORT/100.00), TamSX3('NVW_VALORT')[2])
			Else
				aConvLanc  := JA201FConv(cMoedPF, (cQryRes)->NVV_CMOE4, (cQryRes)->NVW_VALORT, oParams:GetTpExec(), oParams:GetDEmi(), oParams:GetCFilaImpr(), cCodPre)
				nVSOMALTAB  := Round(aConvLanc[1], TamSX3('NVW_VALORT')[2])
			EndIf

			nNVEDESPAD := 0
		Else
			nNVEDESPAD := JurGetDados("NVE", 1, xFilial("NVE") + cCCLIEN + cCLOJA + cCCASO, "NVE_DESPAD")
		EndIf

		If oParams:GetTpExec() == "1" .Or. (oParams:GetTpExec() == "5" .And. Empty(cCodPre)) // 1- Emissão da pré; 5 - Emissão de Fatura Fixo ou Fatura Adicional;
			aCaso     := J201DNVE(cCCLIEN, cCLOJA, cCCASO)
			cRedac    := aCaso[1]
			CNX1CPART := aCaso[2]
			If Len(aCaso) > 3 //Proteção
				cMoelim   := aCaso[4]
				nVlrLim   := aCaso[5]
				nVIniLim  := aCaso[6]
				cFaCLim   := aCaso[7]
				cTbCLim   := aCaso[8]
			EndIf

		ElseIf oParams:GetTpExec() $ "2|6|3|4|5|MS"  //2 - Reemissão Pré-fatura; 3 - Minuta Pré; 4 - Minuta Fatura; 5 - Emissão de Fatura; 6 - Reemissão de Fatura; MS - Minuta de sócio
			aCaso := J201DNX1(cCodPre, cNT0COD, cCCLIEN, cCLOJA, cCCASO)
			If Len(aCaso) > 3 //Proteção
				cRedac    := aCaso[3]
				cTSREV    := aCaso[5]
				cDPREV    := aCaso[6]
				cTBREV    := aCaso[7]
				CNX1CPART := aCaso[8]
				If Len(aCaso) > 9 //Proteção
					cMoelim   := aCaso[10]
					nVlrLim   := aCaso[11]
					nVIniLim  := aCaso[12]
					cFaCLim   := aCaso[13]
					cTbCLim   := aCaso[14]
				EndIf
			EndIf
		EndIf

		If !Empty(cMoelim)

			nHonLimite :=  nVSOMATS + IIf(cTbCLim == "1", nVSOMALTAB, 0)

			If cTEMFA == "1" .And. cFaCLim == "2" // A fatura adicional não faz parte do limite
				nHonLimite := 0
			EndIf

			aConvLanc  := JA201FConv( cMoelim, cMoedPF, nHonLimite, oParams:GetTpExec(), oParams:GetDEmi(), oParams:GetCFilaImpr(), cCodPre ) //Converte o valor acumulado para Limite na moeda do limite geral
			nHonLmConv := Round( aConvLanc[1], nDecHon)

			//Cotação da pré para a moeda do limite
			If ( oParams:GetTpExec() $ "1" .And. oParams:GetSituac() <> "1" ) // Emissão de pré
				J201DCotac(cCodPre, cMoelim, aConvLanc[3])
			EndIf

			nSaldoUtil := J201GSldCs(cCCLIEN, cCLOJA, cCCASO, '1', .F., IIf(Len(aCaso) > 9, aCaso, Nil))

			If nHonLmConv + nSaldoUtil > nVlrLim
				nDescLimite := nHonLmConv - (nVlrLim - nSaldoUtil)

				aConvLanc   := JA201FConv( cMoedPF, cMoelim, nDescLimite, oParams:GetTpExec(), oParams:GetDEmi(), oParams:GetCFilaImpr(), cCodPre ) //Converte o excedente para a moeda da pré-Fatura
				nDescLimite := Round(aConvLanc[1], nDecHon)

				nHonLimite  := nHonLimite - nDescLimite
			EndIf

			aLimite := J201EVlLm(nHonLimite, nVSOMATS, nVSOMALTAB, 0, cTbCLim, '2', cTEMFA, cFaCLim) //Distribui o valor entre TS, FX, LT nessa ordem

			If aLimite[1]
				nVSOMATS   := aLimite[4] //Valor Faturado de TS
				nVSOMALTAB := aLimite[8] //Valor Faturado de TB
			EndIf

			If aLimite[3] .And. Empty(cCodFAd)
				oParams:SetResomaFt(.F.) //Informa que foi feito o rateio a fatura não pode ser sumarizada por de baixo para cima na rotina 203hConv()
			EndIf

		EndIf

		If oParams:GetTpExec() $ "1" // Emissão da pré:

			If nNVEDESPAD > 0 .And. nVSOMATS > 0
				nVDescLin := Round((nVSOMATS * nNVEDESPAD / 100.00), TamSX3('NX1_VDESCO')[2])
			Else
				nVDescLin := 0
			EndIf
			If cCobH == "1"
				nPDescLin := nNVEDESPAD
			Else
				nPDescLin := 0
				nVDescLin := 0
			EndIf

		ElseIf oParams:GetTpExec() $ "2|6"  //Reemissão da pré:

			cTpDesc   := JurGetDados("NX0", 1, xFilial("NX0") + cCodPre, "NX0_TPDESC")  //Tipo de Desconto na Pré-fatura (1=Valor / 2=Percentual)

			nPDescLin := aCaso[1]
			nVDescLin := Round((nVSOMATS * nPDescLin / 100.00), TamSX3('NX1_VDESCO')[2])

			//Se for reemissão, usa os valores desconto especial que estão na pré
			If !Empty(cTpDesc)
				If cTpDesc == "1" // desconto por Valor (atualiza o percentual)
					nVDescEsp := aCaso[2]
					nPDescEsp := nVDescEsp * 100.00 / (nVSOMATS - nVDescLin)
				Else
					nPDescEsp := aCaso[9] //% Desc. Especial
					nVDescEsp := Round(((nVSOMATS - nVDescLin) * nPDescEsp / 100.00), TamSX3('NX1_VLDESC')[2])
				EndIf

			Else
				nVDescEsp   := 0
				nPDescEsp   := 0
			EndIf

		ElseIf oParams:GetTpExec() $ "3|4|5|MS"

			If Empty(cCodPre)
				aCaso     := J201DNVE(cCCLIEN, cCLOJA, cCCASO)
				cRedac    := aCaso[1]
				cNX1CPART := aCaso[3]
			Else
				cTpDesc   := JurGetDados("NX0", 1, xFilial("NX0") + cCodPre, "NX0_TPDESC")  //Tipo de Desconto na Pré-fatura (1=Valor / 2=Percentual )
				aCaso     := J201DNX1(cCodPre, cNT0COD, cCCLIEN, cCLOJA, cCCASO)

				nPDescLin := aCaso[1]  //% Desc. Linear
				nVDescLin := Round((nVSOMATS * nPDescLin / 100.00), TamSX3('NX1_VDESCO')[2])
				
				If cTpDesc == "1" // desconto por Valor (atualiza o percentual)
					nVDescEsp := aCaso[2] //Valor de desconto Especial
					nPDescEsp := nVDescEsp * 100.00 / (nVSOMATS - nVDescLin)
				Else
					nPDescEsp := aCaso[9] //% Desc. Especial
					nVDescEsp := Round(((nVSOMATS - nVDescLin) * nPDescEsp / 100.00), TamSX3('NX1_VLDESC')[2])
				EndIf

				cRedac    := aCaso[3]
				CNX1CPART := aCaso[8]

			EndIf

		EndIf

		If (cTEMTS == "1" .Or. cTEMFX == "1") .And. (nVSOMATS > 0 .Or. nContaTS > 0)
			cNX1TS := "1"
		Else
			cNX1TS := "2"
		EndIf

		If (cTEMDP == "1" ) .And. (nVSOMADESP > 0 .Or. nContaDP > 0)
			cNX1DESP := "1"
		Else
			cNX1DESP := "2"
		EndIf

		If (cTEMLT == "1" ) .And. (nVSOMALTAB > 0 .Or. nContaTB > 0 )
			cNX1LANTA := "1"
		Else
			cNX1LANTA := "2"
		EndIf

		If (nVSOMADESP + nVSOMATS + nVSOMATSTAB + nVSOMALTAB) > 0 .Or.; //Se tiver algum valor à faturar ou
			(nContaTS + nContaDP + nContaTB) > 0 .Or.; // Se tiver algum lançamento vinculado ou
			(cTEMFX == "1") .Or.;  //Se for parcela de fixo (O contrato pode ter apenas a parcelas de fixo)
			(cTEMLM == "1") //Se for Limite sem lançamentos

			//Buscar o Revisor e tipo de Relatório:
			CNX1CTPREL := JurGetDados("NT0", 1, xFilial("NT0") + cNT0COD, "NT0_CRELAT")
			If !Empty(cMoelim)
				nUtLimite  := J201GSldCs(cCCLIEN, cCLOJA, cCCASO, '1', .F., IIf(Len(aCaso) > 9, aCaso, Nil))
			EndIf

			If lSldAdi
				lAdiHon := ((nVSOMATS + nVSOMALTAB) > 0 .Or. cTEMFX == "1")
				lAdiDsp := nVSOMADESP > 0
				nSldAdi := J201DSldAd(cCCLIEN, cCLOJA, cCCASO, cMoedPF, oParams:GetTpExec(), oParams:GetDEmi(), cCodPre, lAdiHon, lAdiDsp)
			EndIf	

			oParams:PtInternal(STR0017) // "Emitindo - Totaliza Caso - Gravando o Caso (NX1)"

			//Se for emissão de Pré-Fatura, Grava na NX1
			If oParams:GetTpExec() $ "1|2|6" // Emissão de Pré / Reemissão de Pré

				NX1->(dbSetOrder(1))  //NX1_FILIAL+NX1_CPREFT+NX1_CCLIEN+NX1_CLOJA+NX1_CCONTR+NX1_CCASO

				lInclui := !(NX1->(DbSeek(xFilial("NX1") + cCodPre + cCCLIEN + cCLOJA + cNT0COD + cCCASO)))
				RecLock("NX1", lInclui)
				If lInclui
					NX1->NX1_FILIAL := xFilial("NX1")
					NX1->NX1_CPREFT := cCodPre
					NX1->NX1_CCLIEN := cCCLIEN
					NX1->NX1_CLOJA  := cCLOJA
					NX1->NX1_CCONTR := cNT0COD
					NX1->NX1_CCASO  := cCCASO
					If NX1->(ColumnPos('NX1_SITREV')) > 0 //Proteção
						NX1->NX1_SITREV := "2"
					EndIf
					If NX1->(ColumnPos('NX1_DESCEX')) > 0 //Proteção
						NX1->NX1_DESCEX := "2"
					EndIf
				EndIf
				NX1->NX1_CJCONT     := cCodJun
				NX1->NX1_VDESP      := Round(nVSOMADESP, nDecDPCas)
				If lDespTrib //Proteção
					NX1->NX1_VLTRIB := Round(nVlDpTrib, TamSX3('NX1_VLTRIB')[2])
					NX1->NX1_VLREMB := Round(nVlDpReemb, TamSX3('NX1_VLREMB')[2])
				EndIf
				NX1->NX1_VTAB       := Round(nVSOMALTAB, nDecLTCas)
				If NX1->(ColumnPos("NX1_VTBVIN")) > 0 //Proteção
					NX1->NX1_VTBVIN := Round(nVSOMALTVINC, nDecLTCas)
				EndIf
				NX1->NX1_PDESCH     := nPDescLin
				NX1->NX1_VLDESC     := nVDescEsp
				NX1->NX1_PCDESC     := nPDescEsp
				NX1->NX1_VDESCO     := nVDescLin
				NX1->NX1_VDESCT     := nVDescEsp + nVDescLin
				NX1->NX1_VTS        := IIF(lFxNC, 0, Round(nVSOMATS * nDivTS, nDecTsCas)) // Zera o valor de TS quando for revisão de TS de contratos fixos/não cobráveis
				NX1->NX1_VTSVIN     := Round(nVSOMATSVINC * nDivTS, nDecTsCas)
				If lTSNCobra // Vincula TimeSheet não cobrável
					NX1->NX1_VTSNC  := Round(nVTSNCobra * nDivTS, nDecTsCas)
				EndIf
				NX1->NX1_VHON       := NX1->(NX1_VTS+NX1_VTAB)
				NX1->NX1_VTSTAB     := nVSOMATSTAB
				NX1->NX1_CMOETH     := cNUEMOEDA
				NX1->NX1_REDAC      := cRedac
				NX1->NX1_TSREV      := Iif(cNX1TS    == "2", "1", cTSREV)
				NX1->NX1_DSPREV     := Iif(cNX1DESP  == "2", "1", cDPREV)
				NX1->NX1_TABREV     := Iif(cNX1LANTA == "2", "1", cTBREV)
				NX1->NX1_TS         := cNX1TS
				NX1->NX1_DESP       := cNX1DESP
				NX1->NX1_LANTAB     := cNX1LANTA
				NX1->NX1_CPART      := CNX1CPART
				NX1->NX1_CTPREL     := CNX1CTPREL
				If NX1->(ColumnPos('NX1_CMOELI')) > 0 //Proteção
					NX1->NX1_CMOELI := cMoelim
					NX1->NX1_VLRLI  := nVlrLim
					NX1->NX1_SALDOI := nVIniLim
					NX1->NX1_CFACVL := cFaCLim
					NX1->NX1_CTBCVL := cTbCLim
					NX1->NX1_UTLIMT := nUtLimite
					NX1->NX1_VEXLIM := nDescLimite
				EndIf
				If lSldAdi
					NX1->NX1_VSLDAD := nSldAdi
				EndIf
				NX1->(MsUnlock())
				NX1->(DbCommit())

				aAdd(aCasosNew, NX1->(NX1_FILIAL + NX1_CPREFT + NX1_CCLIEN + NX1_CLOJA + NX1_CCONTR + NX1_CCASO) ) //Guarda os casos válidos na pré para a remoção dos inválidos
			Else

				NXC->(dbSetOrder(1))  //NXC_FILIAL+NXC_CESCR+NXC_CFATUR+NXC_CCLIEN+NXC_CLOJA+NXC_CCONTR+NXC_CCASO
				If !NXC->(MsSeek(xFilial("NXC") + cEscr + cFatura + cCCLIEN + cCLOJA + cNT0COD + cCCASO))
					RecLock("NXC", .T.)
					NXC->NXC_FILIAL := xFilial("NXC")
					NXC->NXC_CFATUR := cFatura
					NXC->NXC_CESCR  := cEscr
					NXC->NXC_CCLIEN := cCCLIEN
					NXC->NXC_CLOJA  := cCLOJA
					NXC->NXC_CCONTR := cNT0COD
					NXC->NXC_CCASO  := cCCASO
					NXC->NXC_VLTS   := Round(nVSOMATS * nDivTS, nDecTsCas)
					NXC->NXC_VTSVIN := Round(nVSOMATSVINC * nDivTS, nDecTsCas) 
					If lTSNCobra // Vincula TimeSheet não cobrável
						NXC->NXC_VTSNC := Round(nVTSNCobra * nDivTS, nDecTsCas)
					EndIf
					NXC->NXC_VLDESP := Round(nVSOMADESP, nDecDPCas)
					If lDespTrib
						NXC->NXC_VLTRIB := Round(nVlDpTrib, TamSX3('NXC_VLTRIB')[2])
						NXC->NXC_VLREMB := Round(nVlDpReemb, TamSX3('NXC_VLREMB')[2])
					EndIf
					NXC->NXC_VLTAB  := Round(nVSOMALTAB, nDecLTCas)
					If NXC->(ColumnPos("NXC_VTBVIN")) > 0 //Proteção
						NXC->NXC_VTBVIN := Round(nVSOMALTVINC, nDecLTCas)
					EndIf
					NXC->NXC_VLDFAT := NXC->NXC_VLDESP
					NXC->NXC_VLHFAT := NXC->(NXC_VLTS + NXC_VLTAB)
					NXC->NXC_DRATF  := nVDescEsp + nVDescLin
					NXC->NXC_DRATL  := nVDescLin
					NXC->NXC_DRATE  := nVDescEsp
					NXC->NXC_DRATP  := 0
					NXC->NXC_REDAC  := cRedac
					NXC->NXC_VLTSTB := nVSOMATSTAB
					NXC->NXC_PDESCH := nPDescLin
					//o acréscimo rateado no caso é calculado na rotina de rateio (JA203ARat)
					NXC->(MsUnlock())
					NXC->(DbCommit())
				EndIf
			EndIf

			aRet := {.T., "JA201DCaso"}

		Else //Remove o caso sem lançamentos da pré-fatura ou sem FA e FX.
			If oParams:GetTpExec() $ "1|2|6"
				If NX1->(DbSeek(xFilial("NX1") + cCodPre + cCCLIEN + cCLOJA + cNT0COD + cCCASO))
					If FindFunction("J201EDelRv")
						J201EDelRv(NX1->NX1_CPREFT, NX1->NX1_CCONTR, NX1->NX1_CCLIEN, NX1->NX1_CLOJA, NX1->NX1_CCASO) // Remove vínculo de sócios/revisores
					EndIf
					RecLock("NX1", .F., .F., .F., .T.)
					NX1->(DbDelete())
					NX1->(MsUnlock())
					NX1->(DbCommit())
				EndIf
			EndIf
			aRet := {.T., "JA201DCaso"}
		EndIf

		(cQryRes)->(DbSkip())
	EndDo

	If oParams:GetTpExec() $ "2|6"
		J201DVldCs(aCasosNew, cCodPre) //Remove os casos que não tiveram processamento na reemissão
	EndIf

Else

	If oParams:GetTpExec() $ "3|4|5|MS" //Minuta / Emissão de Fatura
		aRet := {.F., "JA201DCaso - " + STR0002 }  //"Não foram encontrados lançamentos para os casos da fatura/minuta!"
	Else
		aRet := {.F., "JA201DCaso - " + STR0003 + cCodPre } //"Não foram encontrados lançamentos para os casos da pré-fatura: "
	EndIf

EndIf

(cQryRes)->(DbCloseArea())

RestArea(aArea)

Return(aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} J201DNX1()
Rotina para retornar os valores da NX1 na reemissão de pré-fatura

@param   cCodPre  Código da Pré-Fatura
@param   cContr   Código do Contrato
@param   cClient  Código do Cliente
@param   cCloja   Código da Loja
@param   cCaso    Código do Caso

@return  aRetNX1  Valores do caso da pré-fatura

@author  Luciano Pereira / Anderson Carvalho / Queizy Nascimento
@since   03/10/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static function J201DNX1(cCodPre, cContr, cClient, cCloja, cCaso)
Local aCpoNX1 := {}
Local aRetNX1 := {}

aAdd(aCpoNX1, "NX1_PDESCH")
aAdd(aCpoNX1, "NX1_VLDESC")
aAdd(aCpoNX1, "NX1_REDAC")
aAdd(aCpoNX1, "NX1_VDESCO")
aAdd(aCpoNX1, "NX1_TSREV")
aAdd(aCpoNX1, "NX1_DSPREV")
aAdd(aCpoNX1, "NX1_TABREV")
aAdd(aCpoNX1, "NX1_CPART")
aAdd(aCpoNX1, "NX1_PCDESC")

If NX1->(ColumnPos('NX1_CMOELI')) > 0 //Proteção
	aAdd(aCpoNX1, "NX1_CMOELI")
	aAdd(aCpoNX1, "NX1_VLRLI" )
	aAdd(aCpoNX1, "NX1_SALDOI")
	aAdd(aCpoNX1, "NX1_CFACVL")
	aAdd(aCpoNX1, "NX1_CTBCVL")
EndIf

If !Empty(aCpoNX1)
	aRetNX1 := JurGetDados("NX1", 1, xFilial("NX1") + cCodPre + cClient + cCloja + cContr + cCaso, aCpoNX1)
EndIf

Return (aRetNX1)

//-------------------------------------------------------------------
/*/{Protheus.doc} J201DNVE()
Rotina para retornar os valores da NX1 na remissão de pré-fatura

@param   cClient Código do Cliente
@param   cCloja  Código da Loja
@param   cCaso   Código do Caso

@return  aRetNX1 Valores do caso da pré-fatura

@author  Luciano Pereira / Anderson Carvalho / Queizy Nascimento
@since   03/10/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static function J201DNVE(cClient, cCloja, cCaso)
Local aCpoNVE := {}
Local aRetNVE := {}

aAdd(aCpoNVE, "NVE_REDFAT")
aAdd(aCpoNVE, "NVE_CPART1")
aAdd(aCpoNVE, "NVE_DESPAD")

If NVE->(ColumnPos('NVE_CMOELI')) > 0 //Proteção
	aAdd(aCpoNVE, "NVE_CMOELI")
	aAdd(aCpoNVE, "NVE_VLRLI")
	aAdd(aCpoNVE, "NVE_SALDOI")
	aAdd(aCpoNVE, "NVE_CFACVL")
	aAdd(aCpoNVE, "NVE_CTBCVL")
EndIf

If !Empty(aCpoNVE)
	aRetNVE := JurGetDados("NVE", 1, xFilial("NVE") + cClient + cCloja + cCaso, aCpoNVE)
EndIf

Return (aRetNVE)

//-------------------------------------------------------------------
/*/{Protheus.doc} J201DCotac()
Rotina para inserir as cotações das moedas.

@Params		cCodPre - Codigo da pré-fatura
@Params		cMoeda	- Codido da moeda
@Params		nCotac	- Cotação da moeda
@Params		cOrigem	- Origem da cotaçao

@author Luciano Pereira dos Santos
@since 19/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function J201DCotac(cCodPre, cMoeda, nCotac, cOrigem)
Local lRet       := .T.
Local aArea      := GetArea()
Local cMoedaNac  := SuperGetMv('MV_JMOENAC',, '01' )

Default cOrigem  := "2"

NXR->(DBSetOrder(1)) //NXR_FILIAL + NXR_CPREFT + NXR_CMOEDA
If !Empty(cCodPre) .And. !Empty(cMoeda) .And. cMoeda != cMoedaNac
	If !NXR->(DbSeek( xFilial("NXR") + cCodPre + cMoeda) )
		RecLock("NXR", .T.)
		NXR->NXR_FILIAL := xFilial("NXR")
		NXR->NXR_CPREFT := cCodPre
		NXR->NXR_CMOEDA := cMoeda
		NXR->NXR_COTAC  := nCotac
		NXR->NXR_ORIGEM := cOrigem
		NXR->NXR_ALTCOT := "2"
		NXR->(MsUnlock())
		NXR->(DbCommit())
	EndIf
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J201DAtuCot(cCodPre)
Rotina para atualizar as cotações na NXR com base na data de Reemissão da Pré

@Params cCodPre - Codigo da pré-fatura
@Params dDtEmi  - Data de emissão da Pré

@author Luciano Pereira dos Santos
@since 19/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function J201DAtuCot(cCodPre, dDtEmi)
Local lRet       := .T.
Local aArea      := GetArea()
Local cMoedaNac  := SuperGetMv('MV_JMOENAC',, '01' )
Local nCotac     := 0

NXR->(DbSetOrder(1))

If NXR->(DbSeek( xFilial("NXR") + cCodPre))
	While !NXR->(Eof()) .And. NXR->NXR_FILIAL + NXR->NXR_CPREFT == xFilial('NXR') + cCodPre
		If NXR->NXR_ALTCOT == '2' // Se a cotação não foi alterada pelo usário na pré-fatura, é atualizada para a data de emissão da fatura com base nas regars de abertura de período.
			nCotac := JA201FConv(cMoedaNac, NXR->NXR_CMOEDA, 1000, '1', dDtEmi)[2]

			RecLock("NXR", .F.)
			NXR->NXR_COTAC := nCotac
			NXR->(MsUnlock())
			NXR->(DbCommit())
		EndIf

		NXR->(DbSkip())
	EndDo
Else
	lRet := .F.
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J201DCotPag()
Rotina para inserir as cotações do pagador na NXR com base na data de Reemissão da Pré.

@Params cCodPre - Codigo da pré-fatura
@Params dDtEmi  - Data de emissão da Pré

@author Luciano Pereira dos Santos
@since 26/11/12
@version 1.0
/*/
//-------------------------------------------------------------------
Function J201DCotPag(cCodPre, dDtEmi)
Local lRet      := .T.
Local cMoedaNac := SuperGetMv('MV_JMOENAC',, '01')
Local aArea     := GetArea()
Local nCotac    := 0

NXG->(DbSetOrder(2)) // NXG_FILIAL+NXG_CPREFT
If NXG->( DbSeek( xFilial('NXG') + cCodPre ) )
	While !NXG->(Eof()) .And. NXG->NXG_FILIAL + NXG->NXG_CPREFT  == xFilial('NXG') + cCodPre
		nCotac := JA201FConv(cMoedaNac, NXG->NXG_CMOE, 1000, '2', dDtEmi,, cCodPre)[2]
		J201DCotac(cCodPre, NXG->NXG_CMOE, nCotac, "1" )
		NXG->(DbSkip())
	EndDo
Else
	lRet := .F.
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J201DVinc()
Rotina para verificar se o caso está vinculado a um contrato de hora.
Caso esteja, os timesheets serão vinculados somente no contrato que cobre hora.

@Params cClien - Cliente do Caso
@Params cloja  - Loja do Caso
@Params cCaso  - Número do Caso
@Params cContr - Contrato vinculado ao Caso

@author Luciano Pereira dos Santos
@since 28/04/14
@version 1.0
/*/
//-------------------------------------------------------------------
Function J201DVinc(cClien, cloja, cCaso, cContr)
Local lRet      := .F.
Local aArea	    := GetArea()
Local cTpHon    := ""
Local cCobH     := ""
Local cCobF     := ""
Local lVincTS   := SuperGetMv('MV_JVINCTS',, .T.)
Local cQuery    := ""
Local cQryRes   := ""
Local aVigencia := {}

If lVincTS
	cTpHon := JurGetDados("NT0", 1, xFilial("NT0") + cContr, "NT0_CTPHON")
	cCobH  := JurGetDados("NRA", 1, xFilial("NRA") + cTpHon, "NRA_COBRAH")
	cCobF  := JurGetDados("NRA", 1, xFilial("NRA") + cTpHon, "NRA_COBRAF")

	If (cCobH == "2" .And. cCobF == "1") // é um contrato de fixo

		//Verifica se o caso esta em um outro contrato cobre hora e pertencente a mesma junção
		cQuery := "SELECT NUT.R_E_C_N_O_ "
		cQuery +=     " FROM " + RetSqlName("NUT") + " NUT, "
		cQuery +=          " " + RetSqlName("NT0") + " NT0, "
		cQuery +=          " " + RetSqlName("NRA") + " NRA, "
		cQuery +=    " WHERE NUT.NUT_FILIAL = '" + xFilial("NUT") + "' "
		cQuery +=      " AND NT0.NT0_FILIAL = '" + xFilial("NT0") + "' "
		cQuery +=      " AND NRA.NRA_FILIAL = '" + xFilial("NRA") + "' "
		cQuery +=      " AND NUT.NUT_CCLIEN = '" + cClien + "' "
		cQuery +=      " AND NUT.NUT_CLOJA  = '" + cloja + "' "
		cQuery +=      " AND NUT.NUT_CCASO  = '" + cCaso + "' "
		cQuery +=      " AND NUT.NUT_CCONTR = NT0.NT0_COD "
		cQuery +=      " AND NT0.NT0_ATIVO  = '1' "
		cQuery +=      " AND NT0.NT0_SIT    = '2' "
		cQuery +=      " AND NT0.NT0_ENCH   = '2' "
		If NT0->(ColumnPos("NT0_DTVIGI")) > 0 // Proteção
			aVigencia := JurGetDados("NT0", 1, xFilial("NT0") + cContr, {"NT0_DTVIGI", "NT0_DTVIGF"})
			If !Empty(aVigencia[1]) .And. !Empty(aVigencia[2])
				cQuery +=   " AND NT0.NT0_DTVIGI >= '" + DtoS(aVigencia[1]) + "'"
				cQuery +=   " AND NT0.NT0_DTVIGF <= '" + DtoS(aVigencia[2]) + "'"
			EndIf
		EndIf
		cQuery +=      " AND NT0.NT0_ENCH   = '2' "
		cQuery +=      " AND NRA.NRA_COD    = NT0.NT0_CTPHON "
		cQuery +=      " AND NRA.NRA_COBRAH = '1' "
		cQuery +=      " AND NUT.D_E_L_E_T_ = ' ' "
		cQuery +=      " AND NT0.D_E_L_E_T_ = ' ' "
		cQuery +=      " AND NRA.D_E_L_E_T_ = ' ' "

		cQuery  := ChangeQuery(cQuery, .F.)
		cQryRes := GetNextAlias()

		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryRes, .T., .F. )

		lRet := (cQryRes)->(EOF())

		(cQryRes)->(DbCloseArea())

	EndIf
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J201DVldCs(aCasosNew,cCodPre)
Rotina para verificar e remover casos que estavam vinculados à pré-fatura
que não foram processados na reemissão.

@Param   aCasosNew - Casos processados pela reemissão da pré-fatura
@Param   cCodPre   - Código da pré-fatura

@Example Um caso que foi removido de uma fatura adicional e não tem mais ligação
com a pré-fatura.

@author Luciano Pereira dos Santos
@since 28/04/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J201DVldCs(aCasosNew, cCodPre)
Local aArea := GetArea()

NX1->(dbSetOrder(1))  //NX1_FILIAL+NX1_CPREFT+NX1_CCLIEN+NX1_CLOJA+NX1_CCONTR+NX1_CCASO
If NX1->(DbSeek( xFilial("NX1") + cCodPre ) )
	While ( NX1->NX1_FILIAL + NX1->NX1_CPREFT == xFilial("NX1") + cCodPre )

		If aScan( aCasosNew, {|aNew| aNew == NX1->NX1_FILIAL + NX1->NX1_CPREFT + NX1->NX1_CCLIEN + NX1->NX1_CLOJA + NX1->NX1_CCONTR + NX1->NX1_CCASO} ) == 0
			If FindFunction("J201EDelRv")
				J201EDelRv(NX1->NX1_CPREFT, NX1->NX1_CCONTR, NX1->NX1_CCLIEN, NX1->NX1_CLOJA, NX1->NX1_CCASO) // Remove vínculo de sócios/revisores
			EndIf
			RecLock("NX1", .F., .F., .F., .T.)
			NX1->(DbDelete())
			NX1->(MsUnlock())
			NX1->(DbCommit())
		EndIf
		NX1->(DbSkip())

	EndDo
EndIf

RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J201DAtivC(cCodAtiv, aAtivid)
Rotina pra retornar se a atividadde do timeSheet é não cobravel fazendo
cache no array aAtivid.
Melhoria de performance para emissão de pré-fatura.

@Param cCodAtiv Codigo da atividade
@Param cContr   Código do contrato
@Param aAtivid  Array com o cache da tabela

@Return lCobra .T. atividade cobrável

@author Luciano Pereira dos Santos
@since 30/01/17
@version 1.0
/*/
//-------------------------------------------------------------------
Function J201DAtivC(cCodAtiv, cContr, aAtivid)
Local lCobra     := .T.
Local nPos       := 0
Local cQuery     := ""

Default cCodAtiv := ""
Default cContr   := ""
Default aAtivid  := {}

If !Empty(cCodAtiv)
	If Len(aAtivid) > 0 .And. ( ( nPos := aScan(aAtivid, {|aX| aX[1] == cCodAtiv}) ) > 0 )
		lCobra := aAtivid[nPos][2]
	Else
		cQuery += " SELECT R_E_C_N_O_ RECNO "
		cQuery +=                   " FROM " + RetSqlName("NRC") + " NRC "
		cQuery +=                   " WHERE NRC.NRC_FILIAL = '" + xFilial("NRC") + "' "
		cQuery +=                     " AND NRC.NRC_COD = '" + cCodAtiv + "' "
		cQuery +=                     " AND NRC.NRC_TEMPOZ = '1' " //Tipo de atividade cobrável
		If Type("oParams") <> "O" .Or. oParams:GetSituac() <> "1"  // Conferencia
			cQuery +=                 " AND NOT EXISTS (SELECT NTJ.R_E_C_N_O_ " //Exceção de atividade não cobrável no contrato
			cQuery +=                                   " FROM " + RetSqlName("NTJ") + " NTJ "
			cQuery +=                                  " WHERE NTJ.NTJ_FILIAL = '" + xFilial("NTJ") + "' "
			cQuery +=                                    " AND NTJ.NTJ_CCONTR = '" + cContr + "' "
			cQuery +=                                    " AND NTJ.NTJ_CTPATV = NRC.NRC_COD "
			cQuery +=                                    " AND NTJ.D_E_L_E_T_ = ' ') "
		EndIf
		cQuery +=                     " AND NRC.D_E_L_E_T_  = ' ' "

		lCobra := !Empty(JurSql(cQuery, {"RECNO"}))

		aAdd(aAtivid, {cCodAtiv, lCobra})
	EndIf
EndIf

Return lCobra

//-------------------------------------------------------------------
/*/{Protheus.doc} J201DVigCtr
Query para considerar vigência do contratos

@Param  cAliasTab, Alias do lançamento
@Param  cCampo   , Campo de filtro de data
@Param  cCodContr, Código do contrato
@Param  cDataIni , Data inicial do filtro
@Param  cDataFim , Data final do filtro
@Param  lFatAtiva, Verifica se existem faturas ativas contrato fixo
@Param  cCodJun  , Código da junção de contratos
@Param  lTemJunc , Se verdadeiro indica que é junção de contratos
@Param  cTpEmiss , Tipo de Emissão
@Param  cCodPre  , Código da Pré-Fatura

@Return  cQryVig, Query considerando vigência do contrato

@author  Luciano Pereira / Jonatas Martins
@since   13/11/2018
/*/
//-------------------------------------------------------------------
Static Function J201DVigCtr(cAliasTab, cCampo, cCodContr, cDataIni, cDataFim, lFatAtiva, lTemJunc, cTpEmiss, cCodPre)
Local cQryVig := ""

Default lFatAtiva := .F.
Default lTemJunc  := .F.
Default cTpEmiss  := ""
Default cCodPre   := ""

	If cTpEmiss $ "2|5|6" .And. !Empty(cCodPre) // Refazer de Pré-Fatura, Emissão da Fatura de Pré ou Reemissão de Pré-fatura após cancelamento da fatura
		cQryVig +=     " INNER JOIN " + RetSqlName("NX1") + " NX1 ON (NX1.NX1_FILIAL = '" + xFilial("NX1") + "' "
		cQryVig +=                                                  " AND NX1.NX1_CPREFT = '" + cCodPre + "' "
		If lTemJunc
			cQryVig +=                                              " AND NX1.NX1_CCONTR = NW3.NW3_CCONTR "
		Else
			cQryVig +=                                              " AND NX1.NX1_CCONTR = '" + cCodContr + "' "
		EndIf
		cQryVig +=                                                  " AND NX1.NX1_CCLIEN = " + cAliasTab + "." + cAliasTab + "_CCLIEN "
		cQryVig +=                                                  " AND NX1.NX1_CLOJA = " + cAliasTab + "." + cAliasTab + "_CLOJA "
		cQryVig +=                                                  " AND NX1.NX1_CCASO = " + cAliasTab + "." + cAliasTab + "_CCASO "
		cQryVig +=                                                  " AND NX1.D_E_L_E_T_ = ' ') "
		cQryVig +=     " INNER JOIN " + RetSqlName("NX8") + " NX8 ON (NX8.NX8_FILIAL = '" + xFilial("NX8") + "' "
		cQryVig +=                                                  " AND NX8.NX8_CPREFT = '" + cCodPre + "' "
		cQryVig +=                                                  " AND NX8.NX8_CCONTR = NX1.NX1_CCONTR "
		cQryVig +=                                                  " AND NX8.D_E_L_E_T_ = ' ') "
	Else
		cQryVig +=     " INNER JOIN " + RetSqlName("NUT") + " NUT ON (NUT.NUT_FILIAL = '" + xFilial("NUT") + "' "
		If lTemJunc
			cQryVig +=                                              " AND NUT.NUT_CCONTR = NW3.NW3_CCONTR "
		Else
			cQryVig +=                                              " AND NUT.NUT_CCONTR = '" + cCodContr + "' "
		EndIf
		cQryVig +=                                                  " AND NUT.NUT_CCLIEN = " + cAliasTab + "." + cAliasTab + "_CCLIEN "
		cQryVig +=                                                  " AND NUT.NUT_CLOJA = " + cAliasTab + "." + cAliasTab + "_CLOJA "
		cQryVig +=                                                  " AND NUT.NUT_CCASO = " + cAliasTab + "." + cAliasTab + "_CCASO "
		cQryVig +=                                                  " AND NUT.D_E_L_E_T_ = ' ') "
		cQryVig +=     " INNER JOIN " + RetSqlName("NT0") + " NT0 ON (NT0.NT0_FILIAL = '" + xFilial("NT0") + "' "
		cQryVig +=                                                  " AND NT0.NT0_COD = NUT.NUT_CCONTR "
		cQryVig +=                                                  " AND NT0.D_E_L_E_T_ = ' ') "
	EndIf

	If !lFatAtiva
		cQryVig += J201BVigCtr(cDataIni, cDataFim, cAliasTab + "." + cCampo, cCodContr, cTpEmiss, cCodPre)
	EndIf

Return (cQryVig)

//-------------------------------------------------------------------
/*/{Protheus.doc} J201DDivTs
Função que avalia a existência do mesmo cliente, loja e caso para mais
de um contrato e calcula o fator de divisão do Time Sheet.

@Param  cCodJun  , caracatere, Código da junção de coontratos
@Param  cCodContr, caracatere, Código do contrato atual
@Param  cCliente , caracatere, Código do cliente
@Param  cLoja    , caracatere, Loja do cliente
@Param  aDivTS   , array     , Contratos para cálculo do fator
		aDivTS[n][1] Cliente
		aDivTS[n][2] Loja
		aDivTS[n][3] Caso
		aDivTS[n][4] Contrato
		aDivTS[n][5] TEMTS (Contrato por hora)
		aDivTS[n][6] NT0_DTVIGI (Vigência inicial do contrato)
		aDivTS[n][7] NT0_DTVIGF (Vigência final do contrato)

@Return  nFator, numerico, Fator de divisão do Time Sheet

@author  Jonatas Martins / Jorge Martins
@since   28/08/2019
/*/
//-------------------------------------------------------------------
Function J201DDivTs(cCodJun, cCodContr, cCliente, cLoja, cCaso, aDivTS)
	Local nPosHora  := 0
	Local nFator    := 1
	Local nQtdContr := 1
	Local nTotCtr   := 1
	Local nCtr      := 0

	// Tratamento para mesmo cliente, loja e caso em mais de um contrato (Junção)
	If !Empty(cCodJun) .And. !Empty(aDivTS) .And. Len(aDivTS[1]) >= 5
		nPosHora := aScan(aDivTS, {|aVal| aVal[1] + aVal[2] + aVal[3] == cCliente + cLoja + cCaso .And. aVal[5] == "1"}) 
		If nPosHora == 0
			nTotCtr := Len(aDivTS)
			For nCtr := 1 To nTotCtr
				If aDivTS[nCtr][1] + aDivTS[nCtr][2] + aDivTS[nCtr][3] == cCliente + cLoja + cCaso .And. aDivTS[nCtr][4] != cCodContr .And. Empty(aDivTS[nCtr][6])
					nQtdContr += 1
				EndIf
			Next nCtr
			nFator := 1 / Min(nQtdContr, nTotCtr)
		EndIf
	EndIf

Return (nFator)

//-------------------------------------------------------------------
/*/{Protheus.doc} J201DExNXE
Função que avalia a existência do resumo de despesa para o mesmo cliente, loja e caso 
para mais de um contrato.

@param  cFatura  , caracatere, Código da Fatura
@param  cEscr    , caracatere, Código do escritório
@param  cCCLIEN  , caracatere, Código do cliente
@param  cCLOJA   , caracatere, Loja do cliente
@param  cCCASO   , caracatere, Código do caso
@param  cCTPDSP  , caracatere, Tipo da despesa

@return lExistNXE, logico    , Se verdadeiro já existe o registro

@author  Jonatas Martins
@since   11/03/2020
/*/
//-------------------------------------------------------------------
Static Function J201DExNXE(cFatura, cEscr, cCCLIEN, cCLOJA, cCCASO, cCTPDSP)
	Local cTmpNXE   := GetNextAlias()
	Local lExistNXE := .F.

	BeginSql Alias cTmpNXE
		%noparser%
		SELECT NXE_CFATUR
		FROM %Table:NXE% NXE
		WHERE NXE.NXE_FILIAL = %xFilial:NXE%
		  AND NXE.NXE_CFATUR = %Exp:cFatura%
		  AND NXE.NXE_CESCR  = %Exp:cEscr%
		  AND NXE.NXE_FILIAD = %xFilial:NVY%
		  AND NXE.NXE_CCLIEN = %Exp:cCCLIEN%
		  AND NXE.NXE_CLOJA  = %Exp:cCLOJA%
		  AND NXE.NXE_CCASO  = %Exp:cCCASO%
		  AND NXE.NXE_CTPDSP = %Exp:cCTPDSP%
		  AND NXE.%NotDel%
	EndSql

	lExistNXE := (cTmpNXE)->(! EOF())

	(cTmpNXE)->(DbCloseArea())

Return (lExistNXE)

//----------------------------------------------------------------------
/*/ { Protheus.doc } J201DSldAd
Função que retorna o saldo de adiantamento por Cliente/Loja/Caso convertendo para a moeda da pré-fatura.

@param cCliente, Código do cliente do adiantamento
@param cLoja   , Endereço do cliente do adiantamento
@param cCaso   , Caso do cliente do adiantamento
@param cMoedaPF, Moeda a pré-fatura
@param cTpExec , Tipo de execução
@param dCotacao, Data da cotação para conversão de moedas
@param cPreFt  , Código da pré-fatura
@param lTemHon , Indica se existe valor de honorários para o caso
@param lTemDsp , Indica se existe valor de despesas para o caso

@return nSaldo   Saldo dos adiantamentos do caso, conforme tipo 

@author Jacques Alves Xavier/Jorge Martins
@since  22/04/2020
/*/
//----------------------------------------------------------------------
Static Function J201DSldAd(cCliente, cLoja, cCaso, cMoedaPF, cTpExec, dCotacao, cPreFt, lTemHon, lTemDsp)
Local cPrefixo  := SuperGetMv("MV_JADTPRF",, "")   // Defina o conteúdo do parâmetro com o prefixo do título criado como adiantamento.
Local cParcela  := SuperGetMv("MV_JADTPAR",, "")   // Parâmetro utilizado para informar a parcela na geração de título de adiantamento.
Local cTipo     := SuperGetMv("MV_JADTTP" ,, "RA") // Informe qual tipo de título será criado no adiantamento. Exemplo: RA (Recebimento Antecipado)
Local lDataAd   := SuperGetMv('MV_JDTCVAD',, "1") == "1" // 1 - Data de inclusão do Adiantamento / 2 - Data de emissão da Fatura
Local nSaldo    := 0
Local cQuery    := ""
Local aSaldos   := {}
Local nI        := 0
Local lSoma     := .F.
Local lCpoCota 	:= NWF->(ColumnPos("NWF_COTACA")) > 0
Local cMoedNac  := SuperGetMV( 'MV_JMOENAC',, '01' )
Local nTaxaPF	:= 1 //Taxa da Moeda da Pré-Fatura

	cQuery := " SELECT NWF.NWF_CCLIEN CLIENTE, NWF.NWF_CLOJA LOJA, NWF.NWF_CCASO CASO, NWF.NWF_CMOE MOEDA, "
	cQuery +=        " NWF.NWF_TPADI TPADI, NWF.NWF_EXCLUS EXCLUS, NWF.NWF_DATAIN DATAIN,"+IIF(lCpoCota," NWF.NWF_COTACA COTACA, ", "")+" SUM(SE1.E1_SALDO) SALDO "
	cQuery +=   " FROM " + RetSqlName("NWF") + " NWF "
	cQuery +=  " INNER JOIN " + RetSqlName("NS7") + " NS7 "
	cQuery +=     " ON NS7.NS7_FILIAL = '" + xFilial( "NS7" ) + "'"
	cQuery +=    " AND NS7.NS7_COD = NWF.NWF_CESCR "
	cQuery +=    " AND NS7.D_E_L_E_T_ = ' ' "
	cQuery +=  " INNER JOIN " + RetSqlName("SE1") + " SE1 "
	cQuery +=     " ON SE1.E1_FILIAL = NS7.NS7_CFILIA "
	cQuery +=    " AND SE1.E1_PREFIXO = '" + cPrefixo + "'"
	cQuery +=    " AND SE1.E1_NUM = NWF.NWF_TITULO "
	cQuery +=    " AND SE1.E1_PARCELA = '" + cParcela + "'"
	cQuery +=    " AND SE1.E1_TIPO = '" + cTipo + "'"
	cQuery +=    " AND SE1.E1_CLIENTE = NWF.NWF_CCLIAD "
	cQuery +=    " AND SE1.E1_LOJA = NWF.NWF_CLOJAD "
	cQuery +=    " AND SE1.E1_ORIGEM = 'JURA069' "
	cQuery +=    " AND SE1.E1_SALDO > 0 "
	cQuery +=    " AND SE1.D_E_L_E_T_ = ' ' "
	cQuery +=  " WHERE NWF.NWF_FILIAL = '" + xFilial( "NWF" ) + "'"
	cQuery +=    " AND NWF.NWF_CCLIEN = '" + cCliente + "'"
	cQuery +=    " AND NWF.NWF_CLOJA = '" + cLoja + "'"
	cQuery +=    " AND NWF.NWF_CCASO = '" + cCaso + "'"
	cQuery +=    " AND NWF.NWF_SITUAC = '1' "
	cQuery +=    " AND NWF.NWF_TITGER = '1' "
	cQuery +=    " AND NWF.D_E_L_E_T_ = ' ' "
	cQuery +=  " GROUP BY NWF.NWF_CCLIEN, NWF.NWF_CLOJA, NWF.NWF_CCASO, NWF.NWF_CMOE, NWF.NWF_TPADI, NWF.NWF_EXCLUS, NWF.NWF_DATAIN "+IIF(lCpoCota,", NWF.NWF_COTACA", "")

	If lCpoCota
		aSaldos := JurSQL(cQuery, {"MOEDA", "TPADI", "EXCLUS", "SALDO", "DATAIN", "COTACA"})
	Else
		aSaldos := JurSQL(cQuery, {"MOEDA", "TPADI", "EXCLUS", "SALDO", "DATAIN"})
	EndIf
	If !Empty(aSaldos)
		For nI := 1 To Len(aSaldos)
			lSoma := .F.
			If aSaldos[nI][3] == "2" .Or. aSaldos[nI][2] == "3" // Adiantamento não exclusivo ou do Tipo Ambos
				lSoma := .T.
			Else
				// Tipo Adiantamento é de despesas e tem despesas ou o tipo de adiantamento é de honorários e tem honorários
				If (aSaldos[nI][2] == "1" .And. lTemDsp) .Or. (aSaldos[nI][2] == "2" .And. lTemHon)
					lSoma := .T.
				EndIf
			EndIf
			If lSoma
				
				If lDataAd .And. lCpoCota .And. aSaldos[nI][6] > 0
					dCotacao := SToD(aSaldos[nI][5])
					//Conversão da Moeda da Pré-Fatura
					If cMoedaPF != cMoedNac
						nTaxaPF :=  JA201FConv(cMoedNac, cMoedaPF, 1, cTpExec, dCotacao, , cPreFt)[2]
					EndIf
					nSaldo += JA201FConv(cMoedaPF, aSaldos[nI][1], aSaldos[nI][4], "A", ;
										 dCotacao,               , cPreFt,            , ;
										 		,                ,       ,            , ;
										 aSaldos[nI][6]		,  nTaxaPF )[1]
				Else

					If lDataAd
						dCotacao := SToD(aSaldos[nI][5]) // Altera cotação para data do adiantamento
					EndIf
					nSaldo += JA201FConv(cMoedaPF, aSaldos[nI][1], aSaldos[nI][4], cTpExec, dCotacao, , cPreFt)[1]
				EndIf
			EndIf
		Next nI
	Endif

Return nSaldo

//----------------------------------------------------------------------
/*/ { Protheus.doc } J201QryDiv
Função que monta query para obter dados dos contratos em que o mesmo 
cliente, loja e caso se repetem quando for junção

@param  cQueryCaso, caractere, Query do caso

@return aCtrDiv   , array    , Contratos do caso

@author Jonatas Martins
@since  30/05/2020
/*/
//----------------------------------------------------------------------
Static Function J201QryDiv(cQueryCaso)
	Local cQueryDiv := ""
	Local aCtrDiv   := {}

	If NT0->(ColumnPos("NT0_DTVIGI")) > 0 // Proteção
		cQueryDiv += "SELECT CASO.CCLIEN, CASO.CLOJA, CASO.CCASO, CASO.CCONTR, CASO.TEMTS, CTR.NT0_DTVIGI, CTR.NT0_DTVIGF "
		cQueryDiv += "FROM (" + cQueryCaso + ") CASO, " + RetSqlName("NT0") + " CTR "
		cQueryDiv += "WHERE CTR.NT0_COD = CCONTR "
	Else
		cQueryDiv := "SELECT CASO.CCLIEN, CASO.CLOJA, CASO.CCASO, CASO.CCONTR, CASO.TEMTS, ' ' NT0_DTVIGI, '' NT0_DTVIGF "
		cQueryDiv := "FROM (" + cQueryCaso + ") CASO"
	EndIf

	aCtrDiv := JurSql(cQueryDiv, "*")

Return (aCtrDiv)
