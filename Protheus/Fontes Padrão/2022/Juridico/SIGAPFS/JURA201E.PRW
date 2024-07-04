#INCLUDE "PROTHEUS.CH"
#INCLUDE "JURA201E.CH"

//TIPO EXEC = 1 (EMISSÃO DE PRÉ)
//-------------------------------------------------------------------
/*/{Protheus.doc} JA201ECont()
Rotina para Totalizar os do Contrato.

@param oParams   , Objeto com os parâmetros para emissão da pré-fatura
@param cCodPre   , Código da pré-fatura
@param cCMOEDFT  , Moeda da pré-fatura
@param cNVVCOD   , Código da Fatura Adicional
@param cNW2COD   , Código da Junção de Contratos
@param cNT0COD   , Código do Contrato
@param lAutomato , Indica se a chamada foi feita via automação

@return aRet     , Retorno da Emissão
                   aRet[1] - .T. - Executado com sucesso - .F. - Houve erro
                   aRet[2] - Nome da função

@author David G. Fernandes 
@since 19/07/11
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA201ECont(oParams, cCodPre, cCMOEDFT, cNVVCOD, cNW2COD, cNT0COD, lAutomato)
Local aRet        := {.F., "JA201ECont"}
Local aArea       := GetArea()
Local cQueryCont  := ""
Local cQryRes     := GetNextAlias()
Local cQueryTS    := ""
Local cQryResTS   := GetNextAlias()
Local cQueryFX    := ""
Local cQryResFX   := GetNextAlias()
Local cQueryNX5   := ""
Local cQryResNX5  := GetNextAlias()

Local cCONTR      := ""
Local cCLIEN      := ""
Local cLOJA       := ""
Local dDTVIGI     := ""
Local dDTVIGF     := ""

Local nVDESP      := 0
Local nVTSTAB     := 0
Local nVTAB       := 0
Local nVTS        := 0
Local nVTSVinc    := 0 //Considerar como valor de TSs vinculados, incluindo não cobráveis
Local nVTSFat     := 0
Local nVLDESC     := 0 // Desconto Especial
Local nVDESCO     := 0 // Desconto Linear
Local nPCDESC     := 0 // Percentual de desconto especial
Local nVACRES     := 0
Local nHonFxFat   := 0
Local nNX1VFixo   := 0 // Valor total de Fixo nos Casos do Contrato

Local aConvLanc   := {}
Local nVlFAdTs    := 0
Local nVlFAdTab   := 0
Local nVlFAdDes   := 0
Local nVTAXA1     := 0
Local nVTAXA2     := 0
Local nVTAXA3     := 0
Local nVTAXA4     := 0

Local nTempo      := 0
Local nDespesas   := 0
Local nTab        := 0
Local nVTbVinc    := 0  //Considerar como valor de Tabelado vinculados (pode ser diferente do faturado pela regra do cobra maior)
Local nTSTab      := 0
Local nHon        := 0
Local nHonLim     := 0
Local nDesp       := 0
Local nFixo       := 0

Local nVlLimite   := 0
Local nHonLimFat  := 0
Local nSaldoProx  := 0
Local nSaldoPre   := 0 // Saldo acumulado de pré-faturas e faturas anteriores (Valor excedido de TS anteriores)
Local nSaldoFat   := 0 // Saldo acumulado para próxima fatura (Valor excedido de TS da fatura atual + saldo excedido de faturas anteriores)
Local nUtilFat    := 0

Local nHonPartFx  := 0
Local nHonFxExc   := 0  //Fixo sem desconto ou atualização monetária para cálculo do excedente
Local nHoraMedio  := 0
Local nHonExHora  := 0
Local nHonExFixo  := 0

Local nHonLimite  := 0
Local nSaldoUtil  := 0
Local nDescLimite := 0
Local nVTSFLim    := 0  //Valor de TS que está sendo de fato faturado para cálculo do limite geral
Local nVTSAnt     := 0
Local cNRACOBRAH  := ""
Local cNRACOBRAF  := ""
Local cNRANCOBRA  := ""
Local cNT0TPCEXC  := ""
Local nNT0VLRLIF  := 0
Local cNT0CMOELI  := ""
Local nNT0PERCD   := 0
Local cNT0CMOEF   := ""
Local nNT0VLRBAS  := 0
Local nNT0LIMEXH  := 0
Local nNT0SALDOI  := 0
Local cNT0TPFX    := ""
Local cNT0CasPro  := ""
Local nNT0PERFIX  := 0
Local nNT0PEREX   := 0
Local cNT0CALFX   := ""
Local nNT0VLRLI   := 0
Local cCTBCVL     := ""
Local cCFACVL     := ""
Local cCFXCVL     := ""
Local cNT0CPART1  := ""
Local cCTPHON     := ""
Local cNT0FIXEXC  := ""

Local nNT1VALOR   := 0
Local dNT1DataVe  := CtoD("")
Local cNT0TpCorr  := ""
Local cNT0CIndic  := ""
Local dNT0DTBase  := CtoD("")
Local cNT0Percor  := ""
Local nValorFix   := 0
Local nVlrCorri   := 0

Local cFlagTS     := ""
Local cFlagDP     := ""
Local cFlagLT     := ""
Local cFlagFX     := ""

Local cFatura     := ""
Local cEscr       := ""
Local cSituac     := ""
Local cNT1CMOEF   := ""
Local aLimite     := {}
Local nVlTSFat    := 0
Local nVlTSLim    := 0
Local nVlLTFat    := 0
Local nVlLTLim    := 0
Local nVlFXFat    := 0
Local nVlFXLim    := 0
Local nVTSNCobra  := 0
Local lFaixa      := .F. // Indica se o tipo de honorários do contrato é por faixa de faturamento, seja por Hora, Valor ou Quantidade de Casos
Local lExcede     := .F. // Indica se tem tratamento de excedente (Misto e Mínimo) ou se tem limite. Usado para ajustar o Valor de TS faturado do Caso
Local lTotLimt    := .F. // Indica se todo o limite foi utilizado (parametro para ajustar o valor dos casos na rotina J201EDivCas() )
Local lValLimFT   := .F. // Indica que há saldo a faturar quanto ao limite por fatura
Local nDecHon     := 0
Local nDecTs      := 0
Local nDecTab     := 0
Local nDecDep     := 0
Local nDecTsTab   := 0
Local aFatAdic    := {}
Local lAutomatic  := .F. //Indica se a geração das parcelas é automática ou manual
Local nQtdCasPro  := 0
Local aRecQtdCas  := {}
Local aRetCasMae  := {}
Local cNT1Descri  := ""
Local lCpoCotac   := NT1->(ColumnPos('NT1_COTAC ')) > 0 //Proteção
Local lFSinc      := SuperGetMV("MV_JFSINC", .F., '2') == '1'
Local cCliMae     := ""
Local cLojMae     := ""
Local cCasMae     := ""

Local lDespTrib   := NXC->(ColumnPos('NXC_VLREMB')) > 0
Local nVlDpTrib   := 0
Local nVlDpReemb  := 0

Local nTempoEx    := 0

Local aRetNX8     := {}
Local lReemitePF  := oParams:GetTpExec() $ "2|6" // Refazer
Local lEmitePF    := oParams:GetTpExec() == "1"  // Emissão de Pré
Local lInclui     := .F.
Local lApuraTS    := SuperGetMv( "MV_JTSPEND", .F., .F., ) .And. NX8->(ColumnPos("NX8_VLTSPD")) > 0 // Indica se no momento da emissão da pré-fatura serão calculados os Time Sheets pendentes e em minuta (.T. ou .F.)
Local cCampos     := ""
Local lLimFatGer  := .F.
Local lNX8VSLDAC  :=  NX8->(ColumnPos("NX8_VSLDAC")) > 0
Local nNX5PDesc	  := 0 //Percentual de Desconto
Local nX5DescH	  := 0 //Desconto em Valor
Local aDesctoH	  := 0
Local cTpHonPF    := ""
Local nHnLinUt    := 0 //Valor de Limite utilizado nos honorários
Local lDesLin     := .F. //Existe desconto Linear?
Local lTSNCobra   := SuperGetMV('MV_JTSNCOB',, .F.) // Indica se vincula TimeSheet não cobrável na emissão
Local cQtdCsAut   := SuperGetMV("MV_JQTDAUT",, "1") // Indica se a quantidade de casos / processos será indicada na parcela de forma automática (1) ou manual (2)

Default lAutomato := .F.

If oParams:GetTpExec() $ "3|4|5|MS" //minuta de Pré / Minuta de Fatura / Emissão de Fatura
	cFatura   := oParams:GetMarkFat()
	cEscr     := oParams:GetMarkEsc()
	nDecHon   := TamSX3('NXB_VLFATH')[2]
	nDecTs    := TamSX3('NXB_VTS')[2]
	nDecTab   := TamSX3('NXB_VTAB')[2]
	nDecTsTab := TamSX3('NXB_VTSTAB')[2]
	nDecDep   := TamSX3('NXB_VLFATD')[2]
Else
	cFatura   := oParams:GetCodFatur()
	cEscr     := oParams:GetCodEscr()
	nDecHon   := TamSX3('NX8_VHON')[2]
	nDecTs    := TamSX3('NX8_VTS')[2]
	nDecTab   := TamSX3('NX8_VTAB')[2]
	nDecDep   := TamSX3('NX8_VDESP')[2]
	nDecTsTab := TamSX3('NX8_VTSTAB')[2]
EndIf

//Soma as informações dos casos e traz as condições
cQueryCont :=  "SELECT NT0.NT0_COD, "
cQueryCont +=        " NT0.NT0_CCLIEN, "
cQueryCont +=        " NT0.NT0_CLOJA, "
cQueryCont +=        " SUM(A.VDESP) VDESP, "
cQueryCont +=        " SUM(A.VTSTAB) VTSTAB, "
cQueryCont +=        " SUM(A.VTAB) VTAB, "
cQueryCont +=        " SUM(A.VTBVINC) VTBVINC, "
cQueryCont +=        " SUM(A.VTS) VTS, "
cQueryCont +=        " SUM(A.VTSVINC) VTSVINC, "
If lTSNCobra
	cQueryCont +=    " SUM(A.VTSNC) VTSNC, "
EndIf
If lDespTrib
	cQueryCont +=    " SUM(A.VLDPTRIB) VLDPTRIB, "
	cQueryCont +=    " SUM(A.VLDPREMB) VLDPREMB, "
EndIf
cQueryCont +=        " MIN(A.TEMTS) TEMTS, "
cQueryCont +=        " MIN(A.TEMDP) TEMDP, "
cQueryCont +=        " MIN(A.TEMLT) TEMLT, "
cQueryCont +=        " MIN(A.TEMFX) TEMFX, "
cQueryCont +=        " MIN(A.TEMFA) TEMFA, "
cQueryCont +=        " MIN(A.TEMLM) TEMLM, "
cQueryCont +=        " SUM(A.VDESCO) VDESCO, "
cQueryCont +=        " SUM(A.VLDESC) VLDESC, "
cQueryCont +=        " SUM(A.PCDESC) PCDESC, "
cQueryCont +=        " SUM(A.NX1VFIXO) NX1VFIXO, "
cQueryCont +=        " NRA.NRA_COBRAH, "
cQueryCont +=        " NRA.NRA_COBRAF, "
cQueryCont +=        " NRA.NRA_NCOBRA, "
cQueryCont +=        " NT0.NT0_TPCEXC, "
cQueryCont +=        " NT0.NT0_VLRLIF, "
cQueryCont +=        " NT0.NT0_CMOELI, "
cQueryCont +=        " NT0.NT0_PERCD, "
cQueryCont +=        " NT0.NT0_CMOEF, "
cQueryCont +=        " NT0.NT0_VLRBAS, "
cQueryCont +=        " NT0.NT0_LIMEXH, "
cQueryCont +=        " NT0.NT0_SALDOI, "
cQueryCont +=        " NT0.NT0_TPFX, "
If NT0->(ColumnPos('NT0_CASPRO')) > 0 //Proteção
	cQueryCont +=    " NT0.NT0_CASPRO, "
EndIf
cQueryCont +=        " NT0.NT0_PERFIX, "
cQueryCont +=        " NT0.NT0_PEREX, "
cQueryCont +=        " NT0.NT0_CALFX, "
cQueryCont +=        " NT0.NT0_VLRLI, "
cQueryCont +=        " NT0.NT0_CTBCVL, "
cQueryCont +=        " NT0.NT0_CFACVL, "
cQueryCont +=        " NT0.NT0_CFXCVL, "
cQueryCont +=        " NT0.NT0_CPART1, "
If lReemitePF .Or. (!lEmitePF .And. !Empty(cCodPre))
	cQueryCont +=    " (CASE WHEN NX8.NX8_CTPHON = '" + Space(TamSx3('NX8_CTPHON')[1]) + "' OR NX8.NX8_CTPHON IS NULL "
	cQueryCont +=          " THEN NT0.NT0_CTPHON ELSE NX8.NX8_CTPHON END) CTPHON, "
    cQueryCont +=    " NT0.NT0_CTPHON, "
Else
	cQueryCont +=    " NT0.NT0_CTPHON CTPHON, "
EndIf
cQueryCont +=        " NT0.NT0_FIXEXC "
If lFSinc .And. NT0->(ColumnPos('NT0_CCLICM')) > 0 .And. NT0->(ColumnPos('NT0_CLOJCM')) > 0 .And. NT0->(ColumnPos('NT0_CCASCM')) > 0 //Proteção
	cQueryCont +=    ", NT0.NT0_CCLICM, "
	cQueryCont +=    " NT0.NT0_CLOJCM, "
	cQueryCont +=    " NT0.NT0_CCASCM "
EndIf
If NT0->(ColumnPos("NT0_DTVIGI")) > 0 // Proteção
	cQueryCont +=    ", NT0.NT0_DTVIGI "
	cQueryCont +=    ", NT0.NT0_DTVIGF "
EndIf

If oParams:GetTpExec() $ "1|2|6"
	cQueryCont +=  " FROM ( "
	If NX1->(ColumnPos('NX1_VTBVIN')) > 0  //Proteção
		cQueryCont +=        " SELECT NX1.NX1_CCONTR CCONTR, NX1.NX1_VDESP VDESP, NX1.NX1_VTSTAB VTSTAB, NX1.NX1_VTAB VTAB, NX1.NX1_VTBVIN VTBVINC, NX1.NX1_VTS VTS, "
	Else
		cQueryCont +=        " SELECT NX1.NX1_CCONTR CCONTR, NX1.NX1_VDESP VDESP, NX1.NX1_VTSTAB VTSTAB, NX1.NX1_VTAB VTAB, 0 VTBVINC, NX1.NX1_VTS VTS, "
	EndIf
	If lDespTrib
		cQueryCont +=            " NX1.NX1_VLTRIB VLDPTRIB, NX1.NX1_VLREMB VLDPREMB, "
	EndIf
	If lTSNCobra
		cQueryCont +=            " NX1.NX1_VTSNC VTSNC, "
	EndIf
	cQueryCont +=                " NX1.NX1_VTSVIN VTSVINC, NX1.NX1_VDESCO VDESCO, NX1.NX1_VLDESC VLDESC, NX1.NX1_PCDESC PCDESC, NX1.NX1_VFIXO NX1VFIXO, NX1.NX1_TS TEMTS, NX1.NX1_DESP TEMDP, NX1.NX1_LANTAB TEMLT, '2' TEMFX, '2' TEMFA, "
	cQueryCont +=                " (CASE WHEN NX1.NX1_VUTFAT > 0 THEN '1' ELSE '2' END) TEMLM  "
	cQueryCont +=          " FROM " + RetSqlName("NX1") + " NX1 "
	cQueryCont +=         " WHERE NX1.NX1_FILIAL = '" + xFilial("NX1") +"' "
	cQueryCont +=           " AND NX1.NX1_CPREFT = '" + cCodPre +"' "
	cQueryCont +=           " AND NX1.D_E_L_E_T_ = ' ' "
	cQueryCont +=         " UNION ALL "
	// Se os casos forem incluídos na 201C, não precisa deste bloco para FX e FZ

	If oParams:GetSituac() == "1"  //Conferência
		cQueryCont += " SELECT NT1.NT1_CCONTR CCONTR, 0 VDESP, 0 VTSTAB, 0 VTAB, 0 VTBVINC, 0 VTS, 0 VTSVINC, "
		If lTSNCobra
			cQueryCont +=    " 0 VTSNC, "
		EndIf
		If lDespTrib
			cQueryCont +=    " 0 VLDPTRIB, 0 VLDPREMB, "
		EndIf
		cQueryCont +=        " 0 VDESCO, 0 VLDESC, 0 PCDESC, 0 NX1VFIXO, '2' TEMTS, '2' TEMDP, '2' TEMLT, '1' TEMFX, '2' TEMFA, '2' TEMLM "
		cQueryCont +=   " FROM " + RetSqlName("NT1") + " NT1 , "
		cQueryCont +=        " " + RetSqlName("NWE") + " NWE  "
		cQueryCont +=   " WHERE NT1.NT1_FILIAL = '" + xFilial("NT1") +"' "
		cQueryCont +=     " AND NWE.NWE_FILIAL = '" + xFilial("NWE") +"' "
		cQueryCont +=     " AND NWE.NWE_CFIXO = NT1.NT1_SEQUEN "
		cQueryCont +=     " AND NWE.NWE_PRECNF = '" + cCodPre +"' "
		cQueryCont +=     " AND NT1.D_E_L_E_T_ = ' ' "
		cQueryCont +=     " AND NWE.D_E_L_E_T_ = ' ' "
		cQueryCont += " UNION ALL "
	Else
		cQueryCont += " SELECT NT1.NT1_CCONTR CCONTR, 0 VDESP, 0 VTSTAB, 0 VTAB, 0 VTBVINC, 0 VTS, 0 VTSVINC, "
		If lTSNCobra
			cQueryCont +=    " 0 VTSNC, "
		EndIf
		If lDespTrib
			cQueryCont +=    " 0 VLDPTRIB, 0 VLDPREMB, "
		EndIf
		cQueryCont +=         " 0 VDESCO, 0 VLDESC, 0 PCDESC, 0 NX1VFIXO, '2' TEMTS, '2' TEMDP, '2' TEMLT, '1' TEMFX, '2' TEMFA, '2' TEMLM "
		cQueryCont +=    " FROM " + RetSqlName("NT1") + " NT1  "
		cQueryCont +=   " WHERE NT1.NT1_FILIAL = '" + xFilial("NT1") +"' "
		cQueryCont +=     " AND NT1.NT1_CPREFT = '" + cCodPre +"' "
		cQueryCont +=     " AND NT1.D_E_L_E_T_ = ' ' "
		cQueryCont +=  " UNION ALL "
	EndIf
	//Seleciona os contratos da pré-fatura sem lançamentos para serem removidos
	cQueryCont += " SELECT NX8.NX8_CCONTR CCONTR, 0 VDESP, 0 VTSTAB, 0 VTAB, 0 VTBVINC, 0 VTS, 0 VTSVINC, "
	If lTSNCobra
		cQueryCont +=    " 0 VTSNC, "
	EndIf
	If lDespTrib
		cQueryCont +=    " 0 VLDPTRIB, 0 VLDPREMB, "
	EndIf
	cQueryCont +=        " 0 VDESCO, 0 VLDESC, 0 PCDESC, 0 NX1VFIXO, '2' TEMTS, '2' TEMDP, '2' TEMLT, NX8.NX8_FIXO TEMFX, NX8.NX8_FATADC TEMFA, '2' TEMLM "
	cQueryCont +=        " FROM " + RetSqlName("NX8") + " NX8  "
	cQueryCont +=       " WHERE NX8.NX8_FILIAL = '" + xFilial("NX8") +"' "
	cQueryCont +=         " AND NX8.NX8_CPREFT = '" + cCodPre +"' "
	cQueryCont +=         " AND NOT EXISTS (SELECT NX1.R_E_C_N_O_ "
	cQueryCont +=                         " FROM " + RetSqlName("NX1") + " NX1  "
	cQueryCont +=                         " WHERE NX1.NX1_FILIAL = '" + xFilial("NX1") +"' "
	cQueryCont +=                             " AND NX1.NX1_CCONTR = NX8.NX8_CCONTR "
	cQueryCont +=                             " AND NX1.NX1_CPREFT = '" + cCodPre +"' "
	cQueryCont +=                             " AND NX1.D_E_L_E_T_ = ' ' ) "
	cQueryCont += " AND NX8.D_E_L_E_T_ = ' ' "
	cQueryCont += " UNION ALL "

	cQueryCont +=   " SELECT NVV.NVV_CCONTR CCONTR, 0 VDESP, 0 VTSTAB, 0 VTAB, 0 VTBVINC, 0 VTS, 0 VTSVINC, "
	If lTSNCobra
		cQueryCont +=    " 0 VTSNC, "
	EndIf
	If lDespTrib
		cQueryCont +=    " 0 VLDPTRIB, 0 VLDPREMB, "
	EndIf
	cQueryCont +=          " 0 VDESCO, 0 VLDESC, 0 PCDESC, 0 NX1VFIXO, '2' TEMTS, '2' TEMDP, '2' TEMLT, '2' TEMFX, '1' TEMFA, '2' TEMLM "
	cQueryCont +=     " FROM " + RetSqlName("NVV") + " NVV  "
	cQueryCont +=    " WHERE NVV.NVV_FILIAL = '" + xFilial("NVV") +"' "
	cQueryCont +=      " AND NVV.NVV_CPREFT = '" + cCodPre +"' "
	cQueryCont +=      " AND NVV.D_E_L_E_T_ = ' ' "
	If !oParams:GetFltrFA() .And. oParams:GetTpExec() == "1" // Executa a query de Limite por fatura somente na emissão da pré-fatura
		cQueryCont += " UNION ALL "
		cCampos := " CCONTR, 0 VDESP, 0 VTSTAB, 0 VTAB, 0 VTBVINC, 0 VTS, 0 VTSVINC, "
		If lTSNCobra
			cCampos += " 0 VTSNC, "
		EndIf
		If lDespTrib
			cCampos += " 0 VLDPTRIB, 0 VLDPREMB, "
		EndIf
		cCampos += " 0 VDESCO, 0 VLDESC, 0 PCDESC, 0 NX1VFIXO, TEMTS, TEMDP, TEMLT, TEMFX, TEMFA, TEMLM "
		cQueryCont += JA201ALM(oParams, .T., cCampos, cNT0COD, cNW2COD)
	EndIf
	cQueryCont +=   " ) A, "
Else
	cQueryCont +=   " FROM ( "
	If NXC->(ColumnPos('NXC_VTBVIN')) > 0 //Proteção
		cQueryCont +=            " SELECT NXC.NXC_CCONTR CCONTR, NXC.NXC_VLDESP VDESP, NXC.NXC_VLTSTB VTSTAB, NXC.NXC_VLTAB VTAB, NXC.NXC_VTBVIN VTBVINC, NXC.NXC_VLTS VTS, "
	Else
		cQueryCont +=            " SELECT NXC.NXC_CCONTR CCONTR, NXC.NXC_VLDESP VDESP, NXC.NXC_VLTSTB VTSTAB, NXC.NXC_VLTAB VTAB, 0 VTBVINC, NXC.NXC_VLTS VTS, "
	EndIf
	If lDespTrib
		cQueryCont +=               " NXC.NXC_VLTRIB VLDPTRIB, NXC.NXC_VLREMB VLDPREMB, "
	EndIf
	If lTSNCobra
		cQueryCont +=               " NXC.NXC_VTSNC VTSNC, "
	EndIf
	cQueryCont +=               " NXC.NXC_VTSVIN VTSVINC, NXC.NXC_DRATL VDESCO, NXC.NXC_DRATE VLDESC, 0 PCDESC, 0 NX1VFIXO, "
	cQueryCont +=               " CASE WHEN NXC_VLTS > 0 THEN '1' ELSE '2' END TEMTS, "
	cQueryCont +=               " CASE WHEN NXC_VLDESP > 0 THEN '1' ELSE '2' END TEMDP, "
	cQueryCont +=               " CASE WHEN NXC_VLTAB > 0 THEN '1' ELSE '2' END TEMLT, "
	cQueryCont +=               " '2' TEMFX, "
	cQueryCont +=               " '2' TEMFA, "
	cQueryCont +=               " '2' TEMLM "
	cQueryCont +=          " FROM " + RetSqlName("NXC") + " NXC  "
	cQueryCont +=         " WHERE NXC.NXC_FILIAL = '" + xFilial("NXC") +"' "
	cQueryCont +=           " AND NXC.NXC_CFATUR = '" + cFatura +"' "
	cQueryCont +=           " AND NXC.NXC_CESCR = '" + cEscr +"' "
	cQueryCont +=           " AND NXC.D_E_L_E_T_ = ' ' "
	cQueryCont +=         " UNION ALL "
	cQueryCont +=         " SELECT NT1.NT1_CCONTR CCONTR, 0 VDESP, 0 VTSTAB, 0 VTAB, 0 VTBVINC, 0 VTS, 0 VTSVINC, "
	If lTSNCobra
		cQueryCont +=            " 0 VTSNC, "
	EndIf
	If lDespTrib
		cQueryCont +=             " 0 VLDPTRIB, 0 VLDPREMB, "
	EndIf
	cQueryCont +=                 " 0 VDESCO, 0 VLDESC, 0 PCDESC, 0 NX1VFIXO, '2' TEMTS, '2' TEMDP, '2' TEMLT, '1' TEMFX, '2' TEMFA, '2' TEMLM "
	cQueryCont +=                 " FROM " + RetSqlName("NT1") + " NT1  "
	cQueryCont +=                 " WHERE NT1.NT1_FILIAL = '" + xFilial("NT1") +"' "
	cQueryCont +=                 " AND EXISTS ( SELECT NWE.R_E_C_N_O_ "
	cQueryCont +=                                     " FROM " + RetSqlName("NWE") + " NWE  "
	cQueryCont +=                                    " WHERE NWE.NWE_FILIAL = '" + xFilial("NWE") +"' "
	cQueryCont +=                                      " AND NWE.NWE_CFATUR = '" + cFatura +"' "
	cQueryCont +=                                      " AND NWE.NWE_CESCR = '" + cEscr +"' "
	cQueryCont +=                                      " AND NWE.NWE_CFIXO = NT1.NT1_SEQUEN "
	cQueryCont +=                                      " AND NWE.D_E_L_E_T_ = ' ' "
	cQueryCont +=                                  " ) "
	cQueryCont +=                 " AND NT1.D_E_L_E_T_ = ' ' "
	cQueryCont +=         " UNION ALL  "
	cQueryCont +=         " SELECT NVV.NVV_CCONTR CCONTR, 0 VDESP, 0 VTSTAB, 0 VTAB, 0 VTBVINC, 0 VTS, 0 VTSVINC, "
	If lTSNCobra
		cQueryCont +=             " 0 VTSNC, "
	EndIf
	If lDespTrib
		cQueryCont +=             " 0 VLDPTRIB, 0 VLDPREMB, "
	EndIf
	cQueryCont +=                 " 0 VDESCO, 0 VLDESC, 0 PCDESC, 0 NX1VFIXO, '2' TEMTS, '2' TEMDP, '2' TEMLT, '2' TEMFX, '1' TEMFA, '2' TEMLM "
	cQueryCont +=                 " FROM " + RetSqlName("NVV") + " NVV "
	cQueryCont +=                 " WHERE NVV.NVV_FILIAL = '" + xFilial("NVV") +"' "
	cQueryCont +=                 " AND EXISTS ( SELECT NWD.R_E_C_N_O_ "
	cQueryCont +=                                 " FROM " + RetSqlName("NWD") + " NWD  "
	cQueryCont +=                                " WHERE NWD.NWD_FILIAL = '" + xFilial("NWD") +"' "
	cQueryCont +=                                  " AND NWD.NWD_CFATUR = '" + cFatura +"' "
	cQueryCont +=                                  " AND NWD.NWD_CESCR = '" + cEscr +"' "
	cQueryCont +=                                  " AND NWD.NWD_CFTADC = NVV.NVV_COD "
	cQueryCont +=                                  " AND NWD.D_E_L_E_T_ = ' ' "
	cQueryCont +=                             " ) "
	cQueryCont +=                 " AND NVV.D_E_L_E_T_ = ' '	"
	If !oParams:GetFltrFA() // Executa a query de Limite por fatura
		cQueryCont +=         " UNION ALL "
		cCampos := " CCONTR, 0 VDESP, 0 VTSTAB, 0 VTAB, 0 VTBVINC, 0 VTS, 0 VTSVINC, "
		If lTSNCobra
			cCampos +=    " 0 VTSNC, "
		EndIf
		If lDespTrib
			cCampos += " 0 VLDPTRIB, 0 VLDPREMB, "
		EndIf
		cCampos += " 0 VDESCO, 0 VLDESC, 0 PCDESC, 0 NX1VFIXO, TEMTS, TEMDP, TEMLT, TEMFX, TEMFA, TEMLM "
		cQueryCont += JA201ALM(oParams, .T., cCampos, cNT0COD, cNW2COD)
	EndIf
	cQueryCont +=   " ) A, "

EndIf
cQueryCont +=        " " + RetSqlName("NT0") + " NT0 , "
cQueryCont +=        " " + RetSqlName("NRA") + " NRA  "

If lReemitePF .Or. (!lEmitePF .And. !Empty(cCodPre))
	cQueryCont +=    ", " + RetSqlName("NX8") + " NX8  "
EndIf

cQueryCont +=  " WHERE NT0.NT0_FILIAL = '" + xFilial("NT0") +"' "
cQueryCont +=    " AND NRA.NRA_FILIAL = '" + xFilial("NRA") +"' "

If lReemitePF .Or. (!lEmitePF .And. !Empty(cCodPre))
	cQueryCont +=    " AND NX8.NX8_FILIAL = '" + xFilial("NX8") +"' "
	cQueryCont +=    " AND NX8.NX8_CCONTR = A.CCONTR "
	cQueryCont +=    " AND NX8.NX8_CPREFT = '" + cCodPre + "'"
	cQueryCont +=    " AND NX8.D_E_L_E_T_ = ' ' "
	cQueryCont +=    " AND (CASE WHEN NX8.NX8_CTPHON = '" + Space(TamSx3('NX8_CTPHON')[1]) + "' OR NX8.NX8_CTPHON IS NULL "
	cQueryCont +=              " THEN NT0.NT0_CTPHON ELSE NX8.NX8_CTPHON END) = NRA.NRA_COD "
Else
	cQueryCont +=    " AND NT0.NT0_CTPHON = NRA.NRA_COD "
EndIf

If oParams:GetTpExec() == "1" // Emissão de Pré-Fatura
	cQueryCont +=    " AND NT0.NT0_ATIVO  = '1' "
EndIf
cQueryCont +=    " AND A.CCONTR       = NT0.NT0_COD "
cQueryCont +=    " AND NT0.D_E_L_E_T_ = ' ' "
cQueryCont +=    " AND NRA.D_E_L_E_T_ = ' ' "
cQueryCont +=  " GROUP BY NT0.NT0_COD, "
cQueryCont +=           " NT0.NT0_CCLIEN, "
cQueryCont +=           " NT0.NT0_CLOJA, "
cQueryCont +=           " NRA.NRA_COBRAH, "
cQueryCont +=           " NRA.NRA_COBRAF, "
cQueryCont +=           " NRA.NRA_NCOBRA, "
cQueryCont +=           " NT0.NT0_TPCEXC, "
cQueryCont +=           " NT0.NT0_VLRLIF, "
cQueryCont +=           " NT0.NT0_CMOELI, "
cQueryCont +=           " NT0.NT0_PERCD, "
cQueryCont +=           " NT0.NT0_CMOEF, "
cQueryCont +=           " NT0.NT0_VLRBAS, "
cQueryCont +=           " NT0.NT0_LIMEXH, "
cQueryCont +=           " NT0.NT0_SALDOI, "
cQueryCont +=           " NT0.NT0_TPFX, "
If NT0->(ColumnPos('NT0_CASPRO')) > 0 //Proteção
	cQueryCont +=           " NT0.NT0_CASPRO, "
EndIf
cQueryCont +=           " NT0.NT0_PERFIX, "
cQueryCont +=           " NT0.NT0_PEREX, "
cQueryCont +=           " NT0.NT0_CALFX, "
cQueryCont +=           " NT0.NT0_VLRLI, "
cQueryCont +=           " NT0.NT0_CTBCVL, "
cQueryCont +=           " NT0.NT0_CFACVL, "
cQueryCont +=           " NT0.NT0_CFXCVL, "
cQueryCont +=           " NT0.NT0_CPART1, "
If lReemitePF .Or. (!lEmitePF .And. !Empty(cCodPre))
	cQueryCont +=       " NX8.NX8_CTPHON, "
	cQueryCont +=       " NT0.NT0_CTPHON, "
Else
	cQueryCont +=       " NT0.NT0_CTPHON, "
EndIf
cQueryCont +=           " NT0.NT0_FIXEXC "
If lFSinc .And. NT0->(ColumnPos('NT0_CCLICM')) > 0 .And. NT0->(ColumnPos('NT0_CLOJCM')) > 0 .And. NT0->(ColumnPos('NT0_CCASCM')) > 0 //Proteção
	cQueryCont +=        ", NT0.NT0_CCLICM, "
	cQueryCont +=        " NT0.NT0_CLOJCM, "
	cQueryCont +=        " NT0.NT0_CCASCM "
EndIf
If NT0->(ColumnPos("NT0_DTVIGI")) > 0 // Proteção
	cQueryCont +=    ", NT0.NT0_DTVIGI "
	cQueryCont +=    ", NT0.NT0_DTVIGF "
EndIf

cQueryCont := ChangeQuery(cQueryCont, .F.)
DbCommitAll() // Para efetivar a alteração no banco de dados (não impacta no rollback da trasação)
dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQueryCont ), cQryRes, .T., .F. )

While !(cQryRes)->(EOF())
	//Zera os acumuladores do contrato
	nHon         := 0
	nHonLim      := 0
	nDesp        := 0
	nFixo        := 0
	nDespesas    := 0
	nSaldoProx   := 0
	nUtilFat     := 0
	nSaldoUtil   := 0
	nHonFxFat    := 0
	nHonLimite   := 0
	nHonPartFx   := 0
	nHonFxExc    := 0
	nHonLimFat   := 0
	nHonExFixo   := 0
	nHonExHora   := 0
	nDescLimite  := 0
	nTSTab       := 0
	nTab         := 0
	nVTSFat      := 0
	nVlFXFat     := 0
	nVlLTFat     := 0
	nTempo       := 0
	nTempoEx     := 0
	nVlTSLim     := 0
	nVlFXLim     := 0
	nVlLTLim     := 0
	nVTSNCobra   := 0

	If lFSinc .And. NT0->(ColumnPos('NT0_CCLICM')) > 0 .And. NT0->(ColumnPos('NT0_CLOJCM')) > 0 .And. NT0->(ColumnPos('NT0_CCASCM')) > 0 //Proteção
		cCliMae      := (cQryRes)->NT0_CCLICM
		cLojMae      := (cQryRes)->NT0_CLOJCM
		cCasMae      := (cQryRes)->NT0_CCASCM
	EndIf

	cCONTR       := (cQryRes)->NT0_COD
	aRet         := {.F., "JA201ECont NT0_COD: " + cCONTR}

	cCLIEN       := (cQryRes)->NT0_CCLIEN
	cLOJA        := (cQryRes)->NT0_CLOJA

	If NT0->(ColumnPos("NT0_DTVIGI")) > 0 // Proteção
		dDTVIGI  := StoD((cQryRes)->NT0_DTVIGI)
		dDTVIGF  := StoD((cQryRes)->NT0_DTVIGF)
	EndIf

	If lDespTrib
		nVlDpTrib    := (cQryRes)->VLDPTRIB 
		nVlDpReemb   := (cQryRes)->VLDPREMB
	EndIf

	nVDESP       := Round((cQryRes)->VDESP, nDecDep)
	nVTSTAB      := Round((cQryRes)->VTSTAB, nDecTsTab)
	nVTAB        := Round((cQryRes)->VTAB, nDecTab)
	nVTS         := Round((cQryRes)->VTS, nDecTs)
	nVTSAnt      := nVTS
	nVTSVinc     := (cQryRes)->VTSVINC
	nVTbVinc     := (cQryRes)->VTBVINC
	nVTSNCobra   := IIF(lTSNcobra, (cQryRes)->VTSNC, 0)
	cTemTS       := Alltrim((cQryRes)->TEMTS) //Tratamento para banco POSTGRES
	cTemDP       := Alltrim((cQryRes)->TEMDP)
	cTemLT       := Alltrim((cQryRes)->TEMLT)
	cTemFX       := Alltrim((cQryRes)->TEMFX)
	cTemFA       := Alltrim((cQryRes)->TEMFA)
	cTemLM       := Alltrim((cQryRes)->TEMLM)
	nVDESCO      := (cQryRes)->VDESCO
	nVLDESC      := (cQryRes)->VLDESC
	nPCDESC      := (cQryRes)->PCDESC
	nNX1VFixo    := (cQryRes)->NX1VFIXO

	cNRACOBRAH   := (cQryRes)->NRA_COBRAH
	cNRACOBRAF   := (cQryRes)->NRA_COBRAF
	cNRANCOBRA   := (cQryRes)->NRA_NCOBRA
	
	If lReemitePF .Or. (!lEmitePF .And. !Empty(cCodPre))
		aRetNX8 := J201ENX8Vl(cCodPre, cCONTR)

		If (!lEmitePF .And. !Empty(cCodPre))
			cTpHonPF := aRetNX8[13] //NX8_CTPHON
		EndIf
	EndIf

	If (lReemitePF .Or. (!lEmitePF .And. !Empty(cCodPre) .And. (cTpHonPF <> (cQryRes)->NT0_CTPHON))) .And. Len(aRetNX8) > 0
		cNT0CMOELI := aRetNX8[1]  // NX8_CMOELI
		nNT0VLRLI  := aRetNX8[2]  // NX8_VLRLI
		nNT0VLRLIF := aRetNX8[3]  // NX8_VLRLIF
		cCFACVL    := aRetNX8[4]  // NX8_CFACVL
		cCFXCVL    := aRetNX8[5]  // NX8_CFXCVL
		cCTBCVL    := aRetNX8[6]  // NX8_CTBCVL
		cNT0CMOEF  := aRetNX8[7]  // NX8_CMOEF
		nNT0VLRBAS := aRetNX8[8]  // NX8_VLRBAS
		cNT0TPCEXC := aRetNX8[9]  // NX8_TPCEXC
		nNT0LIMEXH := aRetNX8[10] // NX8_LIMEXH
		nNT0PERCD  := aRetNX8[11] // NX8_PERCD
		nNT0SALDOI := aRetNX8[12] // NX8_SALDOI
	Else
		cNT0CMOELI := (cQryRes)->NT0_CMOELI
		nNT0VLRLI  := (cQryRes)->NT0_VLRLI
		nNT0VLRLIF := (cQryRes)->NT0_VLRLIF
		cCFACVL    := (cQryRes)->NT0_CFACVL
		cCFXCVL    := (cQryRes)->NT0_CFXCVL
		cCTBCVL    := (cQryRes)->NT0_CTBCVL
		cNT0CMOEF  := (cQryRes)->NT0_CMOEF
		nNT0VLRBAS := (cQryRes)->NT0_VLRBAS
		cNT0TPCEXC := (cQryRes)->NT0_TPCEXC	
		nNT0LIMEXH := (cQryRes)->NT0_LIMEXH
		nNT0PERCD  := (cQryRes)->NT0_PERCD
		nNT0SALDOI := (cQryRes)->NT0_SALDOI
	EndIf

	lLimFatGer := nNT0VLRLI > 0 .And. nNT0VLRLIF > 0 // Limite geral e por fatura juntos

	cNT0TPFX     := (cQryRes)->NT0_TPFX
	If NT0->(ColumnPos('NT0_CASPRO')) > 0 //Proteção
		cNT0CasPro   := (cQryRes)->NT0_CASPRO
	Else
		cNT0CasPro   := "1"
	EndIf

	nNT0PERFIX   := (cQryRes)->NT0_PERFIX
	nNT0PEREX    := (cQryRes)->NT0_PEREX
	cNT0CALFX    := (cQryRes)->NT0_CALFX
	cNT0CPART1   := (cQryRes)->NT0_CPART1
	cCTPHON      := (cQryRes)->CTPHON
	cNT0FIXEXC   := (cQryRes)->NT0_FIXEXC

	// Somar o valor de TS dos Casos do contrato - o limite dos TS será acumulado adiante
	If cTemTS == "1" .And. cTemFA == "2"

		If oParams:GetTpExec() $ "1|2|6"
			cQueryTS := " SELECT SUM(NX2.NX2_TEMPOR + NX2.NX2_HFCLI) TEMPOR "
			cQueryTS += " FROM " + RetSqlName("NX2") + " NX2  "
			cQueryTS += " WHERE NX2.NX2_FILIAL = '" + xFilial("NX2") +"' "
			cQueryTS += " AND NX2.NX2_CCONTR = '" + cCONTR +"' "
			cQueryTS += " AND NX2.NX2_CPREFT = '" + cCodPre +"' "
			cQueryTS += " AND NX2.D_E_L_E_T_ = ' ' "
		Else
			cQueryTS := " SELECT SUM(NXD.NXD_HFREV + NXD.NXD_HFCLI) TEMPOR "
			cQueryTS += " FROM " + RetSqlName("NXD") + " NXD  "
			cQueryTS += " WHERE NXD.NXD_FILIAL = '" + xFilial("NXD") +"' "
			cQueryTS += " AND NXD.NXD_CCONTR = '" + cCONTR +"' "
			cQueryTS += " AND NXD.NXD_CFATUR = '" + cFatura +"' "
			cQueryTS += " AND NXD.NXD_CESCR = '" + cEscr +"' "
			cQueryTS += " AND NXD.D_E_L_E_T_ = ' ' "
		EndIf

		cQueryTS := ChangeQuery(cQueryTS, .F.)
		DbCommitAll() // Para efetivar a alteração no banco de dados (não impacta no rollback da trasação)
		dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQueryTS ), cQryResTS, .T., .F. )

		nTempo   := (cQryResTS)->TEMPOR
	
		If (cNRACOBRAH == "1" .And. cTemTS == "1" .And. !Empty(cCodPre) ) .Or. oParams:GetSituac() == "1"
			nHon  := nHon + nVTS
		EndIf

		If cTEMFA == "2" .And. cNRANCOBRA == "1"  // Não Cobrável
			If !oParams:GetSituac() == "1"    // soma se for conferência..
				nHon := 0
			EndIf
		EndIf

		nHonLim := nHonLim + nHon

		(cQryResTS)->(dbCloseArea())

	EndIf

	// Somar o valor de Despesas dos casos
	If cTemDP == "1" .Or. nVDESP != 0
		nDespesas := nVDESP
	EndIf

	// Somar o valor de Tabelado dos casos
	If cTemLT == "1"
		nTab   := nVTAB
		nTSTab := nVTSTAB
	EndIf

	If cTemFA == "1" //
		aFatAdic   := JurGetDados("NVV", 1, xFilial("NVV") + cNVVCOD, {"NVV_CMOE1", "NVV_CMOE2", "NVV_CMOE4"})
		If !Empty(aFatAdic)
			aConvLanc := JA201FConv(cCMOEDFT, aFatAdic[1], 1000, oParams:GetTpExec(), oParams:GetDEmi(), oParams:GetCFilaImpr(), cCodPre )
			nVTAXA1   := aConvLanc[2]  // Moeda da Condição (Honorários)
			nVTAXA2   := aConvLanc[3]  // Moeda da Pré
			nVlFAdTs  := nVTS

			aConvLanc := JA201FConv(cCMOEDFT, aFatAdic[2], 1000, oParams:GetTpExec(), oParams:GetDEmi() , oParams:GetCFilaImpr(), cCodPre )
			nVTAXA3   := aConvLanc[2] // Moeda da Condição (Despesas)
			nVTAXA2   := aConvLanc[3]
			nVlFAdDes := nDespesas

			aConvLanc := JA201FConv(cCMOEDFT, aFatAdic[3], 1000, oParams:GetTpExec(), oParams:GetDEmi(), oParams:GetCFilaImpr(), cCodPre )
			nVTAXA4   := aConvLanc[2]  // Moeda da Condição (Tabelados)
			nVTAXA2   := aConvLanc[3]  // Moeda da Pré
			nVlFAdTab := nVTAB

			If ( oParams:GetTpExec() $ "1" .AND. oParams:GetSituac() != "1" ) // Emissão de pré
				J201DCotac(cCodPre, aFatAdic[1], nVTAXA1 ) //Adiciona a cotação Honorários
				J201DCotac(cCodPre, aFatAdic[2], nVTAXA3 ) //Adiciona a cotação Despesas
				J201DCotac(cCodPre, aFatAdic[3], nVTAXA4 ) //Adiciona a cotação Tabelados
			EndIf
		EndIf

		// Se condição NT0_CFACVL - Acumula valor do limite
		If cCFACVL == "1"
			nHonLim  := nVlFAdTs + IIf(cCTBCVL == "1", nVlFAdTab, 0)
		Else
			nHonLim  := nVlFAdTs + nVlFAdTab // Se não considera Fa no limite o valor de Honorarios é integral
		EndIf

		// Insere na NWD
		//Se for Emissão, insere na NWD, se for conferência, atualiza
		If ( oParams:GetTpExec() $ "1" .AND. oParams:GetSituac() <> "1" )  //   Emissão de pré
			// NWD_SITUAC -> 1=Conferencia;2=Faturado;3=WO;4=Temporario
			RecLock("NWD",.T.)
			NWD->NWD_FILIAL  := xFilial("NWD")
			NWD->NWD_CFTADC  := cNVVCOD
			NWD->NWD_SITUAC  := "1"
			NWD->NWD_PRECNF  := cCodPre
			NWD->NWD_CANC    := "2"
			NWD->NWD_CODUSR  := oParams:GetCodUser()
			NWD->NWD_VALORH  := nVlFAdTs
			NWD->NWD_VALORT  := nVlFAdTab
			NWD->NWD_VALORD  := nVlFAdDes
			NWD->NWD_COTAC1  := nVTAXA1
			NWD->NWD_COTAC2  := nVTAXA2
			NWD->NWD_COTAC3  := nVTAXA3
			NWD->NWD_COTAC4  := nVTAXA4
			NWD->(MsUnlock())
			NWD->(DbCommit())

		Else

			If oParams:GetTpExec() $ "1|5" //Emitir Fatura / pré-fatura
				cSituac := "4"
			Else //Refazer pré
				cSituac := "1"
			EndIf

			NWD->(DbSetOrder(1)) //  NWD_FILIAL+NWD_CTS+NWD_SITUAC+NWD_PRECNF+NWD_CFATUR+NWD_CESCR+NWD_CWO
			If (NWD->(MsSeek( xFilial("NWD") + cNVVCOD + cSituac + cCodPre + cFatura + cEscr ) ))
				RecLock("NWD",.F., .F., .F., .T.)
				NWD->NWD_VALORH := nVlFAdTs
				NWD->NWD_VALORT := nVlFAdTab
				NWD->NWD_VALORD := nVlFAdDes
				NWD->NWD_COTAC1 := nVTAXA1
				NWD->NWD_COTAC2 := nVTAXA2
				NWD->NWD_COTAC3 := nVTAXA3
				NWD->NWD_COTAC4 := nVTAXA4
				NWD->(MsUnlock())
				NWD->(DbCommit())

			EndIf

		EndIf

		nTab  := Round(nVlFAdTab, nDecHon)
		nHon  := Round(nVlFAdTs  + nVlFAdTab, nDecHon)
		nDesp := Round(nVlFAdDes, nDecDep)

	Else

		nHon   := Round(nHon + nTab, nDecHon)
		nDesp  := Round(nDesp + nDespesas, nDecDep)

		If cCTBCVL == "1"
			nHonLim := nHon
		Else
			nHonLim := nHon - nTab
		EndIf

	EndIf

	If oParams:GetSituac() <> "1" .And. nNT0VLRLIF > 0 .And. (lValLimFT := J201ELimFt(oParams, nVTS, cCodPre))
		// Verifica se há valores a faturar (saldo prox fat - de fat anteriores) convertidos na moeda da pré - apenas pré-faturas com a flag de TS marcada
		nSaldoFat := JURA201G( "1", cCMOEDFT, oParams:GetCFilaImpr(), cCONTR, oParams:GetTpExec(), oParams:GetDEmi(), cCodPre,,,,@nSaldoPre)
		nSaldoFat := Round(nSaldoFat, nDecHon)
		nSaldoPre := Round(nSaldoPre, nDecHon)
	EndIf

	// Processa os casos 'Por Hora'
	If (	cNRACOBRAH == "1" .And. ;
			(nNT0VLRLIF > 0 .Or. !Empty(cNT0CALFX)) .And. ;
			(cTemTS == "1" .Or. nSaldoFat > 0 .Or. nHonLim > 0 ) .And.;
			cTemFA == "2" ;
			)

		// Se tiver Limite por Fatura ou Faturamento por Faixas - Hora e Valor
		If nNT0VLRLIF > 0 .Or. !Empty(cNT0CALFX)

			//Processa Faturamento por Faixas  - Hora e Valor
			If !Empty(cNT0CALFX) .And. oParams:GetSituac() <> "1"
				//Rotina para cálculo das faixas por hora e valor, considerando o Tipo de Valor da NTR
				nHon := Round(JFxHrVr(cCodPre, cNT0TPFX, cNT0CALFX, cCONTR, nVTS, nTempo, oParams:GetTpExec()), nDecHon ) + nTab
				nHonLim := nHon - nTab
				nHonFxFat := nHon - nTab  //Para alimentar os campos NX8_VFXFAT e NXB_VLHFV quando for faturamento por faixa
				lFaixa := .T.
			Else
				lFaixa := .F. // Necessário para situações que tem junção, e um dos casos é faixa e outro não
			EndIf

			If nNT0VLRLIF > 0 .And. lValLimFT

				If lLimFatGer // Não considerar o valor de tabelado no limite por fatura quando o contrato também considera limite geral
					nHonLim := nHon - nTab // Limite por fatura considera apenas TSs
				EndIf

				// Calcula o valor de Limite na moeda da pré
				aConvLanc := JA201FConv(cCMOEDFT, cNT0CMOELI, nNT0VLRLIF, oParams:GetTpExec(), oParams:GetDEmi(), oParams:GetCFilaImpr(), cCodPre )
				nVlLimite := Round(aConvLanc[1], nDecHon)
				// aConvLanc[2] - Moeda da Condição (limite)
				// aConvLanc[3] - Moeda da Pré

				//Cotação da pré para a moeda do limite
				If ( oParams:GetTpExec() $ "1" .And. oParams:GetSituac() <> "1" ) // Emissão de pré
					J201DCotac(cCodPre, cNT0CMOELI, aConvLanc[2])
				EndIf

				//Se o valor TS > limite, o excedente ficará para a próxima fatura
				If nHonLim > nVlLimite
					nHonLimFat := nVlLimite
					nSaldoProx := nHonLim - nVlLimite
					If lLimFatGer
						nVTS    := nHonLimFat
					EndIf
				Else
					If nSaldoFat > 0
						If nHonLim + nSaldoFat <= nVlLimite
							nHonLimFat := nHonLim + nSaldoFat
							nUtilFat   := nSaldoFat
						Else
							nHonLimFat := nVlLimite
							nUtilFat   := nVlLimite - nHonLim
						EndIf
						
					Else
						If nHonLim + nSaldoFat > 0
							nHonLimFat := nHonLim + nSaldoFat
							nUtilFat   := nSaldoFat
						Else
							If nVDesp + nVTab + nVlFXFat > 0
								nHonLimFat := 0
								nUtilFat   := nHonLim + nSaldoFat
							Else
								nHonLimFat := nHonLim
							EndIf
						EndIf

					EndIf

				EndIf

				nHon      := nHon - nSaldoProx + nUtilFat
				nSaldoFat := nSaldoFat - nUtilFat + nSaldoProx
			ElseIf oParams:GetSituac() == "1" .And. nNT0VLRLIF > 0
				nNT0VLRLIF := 0
			EndIf

			nHonLim := nHon
		EndIf

 	EndIf

	If cNRACOBRAF == "1"

		If cTemFX == "1"
			If oParams:GetSituac() == "1"  //Conferência
				cQueryFX := " SELECT NT1.NT1_VALORA, NT1.NT1_VALORB, NT1.NT1_SEQUEN, NT1.R_E_C_N_O_ as NT1_RECNO, "
				cQueryFX +=        " NT1.NT1_DATAIN, NT1.NT1_DATAFI, NT1.NT1_PARC "
				cQueryFX +=   " FROM " + RetSqlName("NT1") + " NT1 , "
				cQueryFX +=            + RetSqlName("NWE") + " NWE  "
				cQueryFX +=  " WHERE NT1.NT1_FILIAL = '" + xFilial("NT1") +"' "
				cQueryFX +=    " AND NWE.NWE_FILIAL = '" + xFilial("NWE") +"' "
				cQueryFX +=    " AND NWE.NWE_CFIXO = NT1.NT1_SEQUEN "
				cQueryFX +=    " AND NT1.NT1_CCONTR = '" + cCONTR +"' "
				cQueryFX +=    " AND NT1.NT1_SITUAC = '1' "
				If !Empty(cCodPre)//Se for pré-fatura
					cQueryFX += " AND NWE.NWE_PRECNF = '" + cCodPre +"' "
				Else // Se for Fatura
					cQueryFX += " AND NWE.NWE_CFATUR = '" + cFatura +"' "
					cQueryFX += " AND NWE.NWE_CESCR = '" +cEscr +"' "
				EndIf
				cQueryFX += " AND NT1.D_E_L_E_T_ = ' ' "
				cQueryFX += " AND NWE.D_E_L_E_T_ = ' ' "
			Else
				cQueryFX := " SELECT NT1.NT1_VALORA, NT1.NT1_VALORB, NT1.NT1_SEQUEN, NT1.R_E_C_N_O_ as NT1_RECNO, "
				cQueryFX +=        " NT1.NT1_DATAIN, NT1.NT1_DATAFI, NT1.NT1_PARC "
				cQueryFX +=   " FROM " + RetSqlName("NT1") + " NT1  "
				cQueryFX +=  " WHERE NT1.NT1_FILIAL = '" + xFilial("NT1") +"' "
				cQueryFX +=    " AND NT1.NT1_CCONTR = '" + cCONTR +"' "
				//Se for pré-fatura
				If Empty(cFatura)
					cQueryFX += " AND NT1.NT1_CPREFT = '" + cCodPre +"' "
					cQueryFX += " AND NT1.NT1_SITUAC = '1' "
				Else  // Se for fatura
					cQueryFX += " AND NT1.NT1_SEQUEN IN ( SELECT NWE.NWE_CFIXO  "
					cQueryFX +=                           " FROM " + RetSqlName("NWE") + " NWE  "
					cQueryFX +=                          " WHERE NWE.NWE_FILIAL = '" + xFilial("NWE") +"' "
					cQueryFX +=                            " AND NWE.NWE_CFATUR = '" + cFatura +"' "
					cQueryFX +=                            " AND NWE.NWE_CESCR = '" +cEscr +"' "
					cQueryFX +=                            " AND NWE.D_E_L_E_T_ = ' ' "
					cQueryFX +=                       " ) "
				EndIf
				cQueryFX += " AND NT1.D_E_L_E_T_ = ' ' "
			EndIf

			// Verificar: Vincular os TS se for emissão de fatura de fixo.
			// Vincular TS de todos os casos do contrato
			// Somente se o Tp Honorário do Contrato for Cobra H = '2' e Cob F = '1'

			cQueryFX := ChangeQuery(cQueryFX, .F.)
			DbCommitAll() // Para efetivar a alteração no banco de dados (não impacta no rollback da trasação)
			dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQueryFX ), cQryResFX, .T., .F. )

			TcSetField(cQryResFX, 'NT1_VALORB', 'N', TamSX3('NT1_VALORB')[1], TamSX3('NT1_VALORB')[2])
			TcSetField(cQryResFX, 'NT1_VALORA', 'N', TamSX3('NT1_VALORA')[1], TamSX3('NT1_VALORA')[2])
			TcSetField(cQryResFX, 'NT1_DATAIN', 'D', TamSX3('NT1_DATAIN')[1], TamSX3('NT1_DATAIN')[2])
			TcSetField(cQryResFX, 'NT1_DATAFI', 'D', TamSX3('NT1_DATAFI')[1], TamSX3('NT1_DATAFI')[2])
			TcSetField(cQryResFX, 'NT1_RECNO', 'N', 12, 0)

			lAutomatic := J96TPHPAut(cCTPHON) //Indica se a geração das parcelas é automática ou manual

			If lAutomatic .And. oParams:GetChkCorr()
				J201ECorrF(cCONTR, , lAutomatic)
			EndIf

			While !(cQryResFX)->(EOF())

				nNT1VALOR  := 0
				dNT1DataVe := CtoD("")
				cNT0TpCorr := ""
				cNT0CIndic := ""
				dNT0DTBase := CtoD("")
				cNT0Percor := ""
				nValorFix  := 0
				nVlrCorri  := 0
				nQtdCasPro := 0
				aRecQtdCas := {}
				cNT1Descri := ""

				If !lAutomatic .And. oParams:GetChkCorr()
					J201ECorrF(cCONTR, (cQryResFX)->NT1_PARC, lAutomatic, lAutomato) //Quando é parcela automatica, corrige todas as parcelas
				EndIf

				NT1->( dbGoto((cQryResFX)->NT1_RECNO) )

				If oParams:GetSituac() <> "1" // Não é conferência - Não considera valor de fixo
					nNT1VALOR  := IIf(Empty(NT1->NT1_VALORA), NT1->NT1_VALORB, NT1->NT1_VALORA)
				EndIf

				If !Empty(NT1->NT1_CMOEDA)       // caso a parcela nao tenha moeda e usada como padra a moeda do contrato
					cNT1CMOEF :=  NT1->NT1_CMOEDA
				Else
					cNT1CMOEF :=  cNT0CMOEF
				EndIf

				//Recalcula o valor base do fixo quando for Faixa de Faturamento (Quantidade de Casos) considerando os casos vinculados na pré-fatura.
				If !Empty(cNT0TPFX) .And. JUR96FAIXA(cCTPHON) .And. oParams:GetSituac() <> '1'
					aRecQtdCas := JRecQtdCas(cFatura, cCodPre, cNT0TPFX, cCONTR, DtoS(NT1->NT1_DATAIN), DtoS(NT1->NT1_DATAFI), cNT0CasPro, IIf(cQtdCsAut == "2", NT1->NT1_QTDADE, 0))
					nQtdCasPro := aRecQtdCas[2]
					nNT1VALOR  := Round(aRecQtdCas[1], nDecHon)
					
					lFaixa     := .T.
					NT1->( RecLock("NT1", .F., .F., .F., .T.) )
					NT1->NT1_VALORB := nNT1VALOR
					NT1->NT1_VALORA := nNT1VALOR
					NT1->NT1_QTDADE := nQtdCasPro
					cNT1Descri := Iif(cNT0CasPro == "1", STR0002, STR0003) //"Quantidade de casos: ", "Quantidade de processos:"
					NT1->NT1_DESCRI := NT1->NT1_DESCRI + CRLF + cNT1Descri + Alltrim(STR(nQtdCasPro)) + ". "
					NT1->(MsUnlock())
					NT1->(DbCommit())
					nHonFxFat := nHonFxFat + nNT1VALOR
					//Grava na fila de sincronização
					J170GRAVA("NT0", xFilial("NT0") + cCONTR, "4")
				Else
					lFaixa := .F. // Necessário para situações que tem junção, e um dos casos é faixa e outro não
				EndIf

				If (cQryResFX)->NT1_VALORA == 0

					dNT1DataVe := NT1->NT1_DATAVE

					//Converte a parte fixa na moeda da fatura
					aConvLanc := JA201FConv(cCMOEDFT, cNT1CMOEF, nNT1VALOR, oParams:GetTpExec(), oParams:GetDEmi() , oParams:GetCFilaImpr(), cCodPre )
					nVTAXA1 := aConvLanc[2] // Moeda da Condição (Fixo)
					nVTAXA2 := aConvLanc[3] // Moeda da Pré

					//Cotação da pré para a moeda do Fixo
					If ( oParams:GetTpExec() $ "1" .AND. oParams:GetSituac() <> "1" ) // Emissão de pré
						J201DCotac(cCodPre, cNT1CMOEF, aConvLanc[2]   )
					EndIf

					cNT0TpCorr := JurGetDados("NT0", 1, xFilial("NT0") + (cQryRes)->NT0_COD, "NT0_TPCORR")
					cNT0CIndic := JurGetDados("NT0", 1, xFilial("NT0") + (cQryRes)->NT0_COD, "NT0_CINDIC")
					dNT0DTBase := JurGetDados("NT0", 1, xFilial("NT0") + (cQryRes)->NT0_COD, "NT0_DTBASE")
					cNT0Percor := JurGetDados("NT0", 1, xFilial("NT0") + (cQryRes)->NT0_COD, "NT0_PERCOR")

					If IIf( Empty(cNT0TpCorr), "1", cNT0TpCorr ) == "1"
						nValorFix := NT1->NT1_VALORB

						NT1->( RecLock("NT1", .F., .F., .F., .T.) )
						NT1->NT1_VALORA     := nValorFix
						NT1->NT1_DATAAT     := Date()
						NT1->NT1_COTAC1     := nVTAXA1
						NT1->NT1_COTAC2     := nVTAXA2
						If lCpoCotac
							NT1->NT1_COTAC  := JurCotac(nVTAXA1, nVTAXA2)
						EndIf
						If Empty(NT1->NT1_CMOEDA)
							NT1->NT1_CMOEDA := cNT1CMOEF
						EndIf
						NT1->(MsUnlock())
						NT1->(DbCommit())
						//Grava na fila de sincronização
						J170GRAVA("NT0", xFilial("NT0") + (cQryRes)->NT0_COD, "4")
					Else

						nValorFix := NT1->NT1_VALORA
						If cNT0TpCorr == "2" .And. !Empty(cNT0CIndic)
							nVlrCorri := JCorrIndic(NT1->NT1_VALORB, dNT0DTBase, dNT1DataVe, cNT0Percor, cNT0CIndic, "V",,, lAutomato)

							If !nValorFix == Round(nVlrCorri, TamSX3('NT1_VALORA')[2])
								NT1->( RecLock("NT1", .F., .F., .F., .T.) )
								NT1->NT1_VALORA     := Round(nVlrCorri , TamSX3('NT1_VALORA')[2])
								NT1->NT1_DATAAT     := Date()
								NT1->NT1_COTAC1     := nVTAXA1
								NT1->NT1_COTAC2     := nVTAXA2
								If lCpoCotac
									NT1->NT1_COTAC  := JurCotac(nVTAXA1, nVTAXA2)
								EndIf
								If Empty(NT1->NT1_CMOEDA)
									NT1->NT1_CMOEDA := cNT1CMOEF
								EndIf
								NT1->(MsUnlock())
								NT1->(DbCommit())
								//Grava na fila de sincronização
								J170GRAVA("NT0", xFilial("NT0") + (cQryRes)->NT0_COD, "4")
							EndIf

						EndIf

					EndIf

				Else // grava somente as cotaçoes

					//Converte a parte fixa na moeda da fatura
					aConvLanc := JA201FConv(cCMOEDFT, cNT1CMOEF, nNT1VALOR, oParams:GetTpExec(), oParams:GetDEmi(), oParams:GetCFilaImpr(), cCodPre )
					nVTAXA1   := aConvLanc[2] // Moeda da Condição (Fixo)
					nVTAXA2   := aConvLanc[3] // Moeda da Pré

					//Cotação da pré para a moeda do Fixo
					If ( oParams:GetTpExec() $ "1" .AND. oParams:GetSituac() <> "1" ) // Emissão de pré
						J201DCotac(cCodPre, cNT1CMOEF, aConvLanc[2]   )
					EndIf

					NT1->( RecLock("NT1", .F., .F., .F., .T.) )
					NT1->NT1_COTAC1     := nVTAXA1
					NT1->NT1_COTAC2     := nVTAXA2
					If lCpoCotac
						NT1->NT1_COTAC  := JurCotac(nVTAXA1, nVTAXA2)
					EndIf
					If Empty(NT1->NT1_CMOEDA)
						NT1->NT1_CMOEDA := cNT1CMOEF
					EndIf
					NT1->(MsUnlock())
					NT1->(DbCommit())
					// Grava na fila de sincronização
					If !(oParams:GetTpExec() $ "3|4|MS") // Se for minuta não adiciona a NT0 na fila
						J170GRAVA("NT0", xFilial("NT0") + (cQryRes)->NT0_COD, "4")
					EndIf
				EndIf

				//Converte a parte fixa na moeda da fatura
				aConvLanc  := JA201FConv(cCMOEDFT, cNT1CMOEF, nNT1VALOR, oParams:GetTpExec(), oParams:GetDEmi(), oParams:GetCFilaImpr(), cCodPre )
				nHonPartFx := Round(aConvLanc[1], nDecHon)
				nVTAXA1    := aConvLanc[2]
				nVTAXA2    := aConvLanc[3]

				//Cotação da pré para a moeda do Fixo
				If ( oParams:GetTpExec() $ "1" .AND. oParams:GetSituac() <> "1" ) // Emissão de pré
					J201DCotac(cCodPre, cNT1CMOEF, nVTAXA1   )
				EndIf

				nHon  := nHon + nHonPartFx

				nFixo := nFixo + nHonPartFx

				//Atualizar a Cotação na NWE
				//Se for Emissão, insere na NVZ, se for conferência, atualiza
				If ( oParams:GetTpExec() $ "1" .AND. oParams:GetSituac() <> "1" )   //   Emissão de pré
					// NWD_SITUAC -> 1=Conferencia;2=Faturado;3=WO;4=Temporario
					RecLock("NWE",.T.)
					NWE->NWE_FILIAL    := xFilial("NWE")
					NWE->NWE_CFIXO     := (cQryResFX)->NT1_SEQUEN
					NWE->NWE_SITUAC    := "1"
					NWE->NWE_PRECNF    := cCodPre
					NWE->NWE_CANC      := "2"
					NWE->NWE_CODUSR    := oParams:GetCodUser()
					NWE->NWE_CMOEDA    := cNT1CMOEF
					NWE->NWE_COTAC1    := nVTAXA1
					NWE->NWE_COTAC2    := nVTAXA2
					If lCpoCotac
						NWE->NWE_COTAC := JurCotac(nVTAXA1, nVTAXA2)
					EndIf
					NWE->NWE_VALORB    := NT1->NT1_VALORB
					NWE->NWE_VALORA    := NT1->NT1_VALORA
					NWE->NWE_DATAIN    := (cQryResFX)->NT1_DATAIN
					NWE->NWE_DATAFI    := (cQryResFX)->NT1_DATAFI

					NWE->(MsUnlock())
					NWE->(DbCommit())
					//Grava na fila de sincronização
					J170GRAVA("NT0", xFilial("NT0") + (cQryRes)->NT0_COD, "4")

				Else
					If oParams:GetTpExec() $ "3|4|5|MS" //Minuta de pré fatura / Minuta de Fatura / Fatura
						cSituac := "4"
					Else
						cSituac := "1"
					EndIf
					NWE->(DbSetOrder(1)) //  NWE_FILIAL+NWE_CFIXO+NWE_SITUAC+NWE_PRECNF+NWE_CFATUR+NWE_CESCR+NWE_CWO
					If (NWE->(MsSeek( xFilial("NWE") + (cQryResFX)->NT1_SEQUEN + cSituac + cCodPre + cFatura + cEscr ) ))
						RecLock("NWE",.F., .F., .F., .T.)
						NWE->NWE_COTAC1    := nVTAXA1
						NWE->NWE_COTAC2    := nVTAXA2
						NWE->NWE_VALORB    := NT1->NT1_VALORB
						NWE->NWE_VALORA    := NT1->NT1_VALORA
						If lCpoCotac
							NWE->NWE_COTAC := JurCotac(nVTAXA1, nVTAXA2)
						EndIf
						NWE->NWE_CMOEDA    := cNT1CMOEF
						NWE->(MsUnlock())
						NWE->(DbCommit())
						//Grava na fila de sincronização
						If !(oParams:GetTpExec() $ "3|4|MS") // Se for minuta não adiciona a NT0 na fila
							J170GRAVA("NT0", xFilial("NT0") + (cQryRes)->NT0_COD, "4")
						EndIf
					EndIf
				EndIf

				(cQryResFX)->(DbSkip())

			EndDo
			(cQryResFX)->(dbCloseArea())
		EndIf

		If (cNRACOBRAH == "1" .And. cNRACOBRAF == "1") .And. ;
				cNT0TPCEXC != " " .And. ;
				(cTemFX == "1" .Or. cTEMTS == "1") .And. ;
				cTEMFA == "2" //Casos de Hora e Fixo (Misto / Valor Mínimo)

			If oParams:GetSituac() <> "1" 
				aConvLanc := JA201FConv(cCMOEDFT, cNT0CMOEF, nNT0VLRBAS, oParams:GetTpExec(), oParams:GetDEmi(), oParams:GetCFilaImpr(), cCodPre )

				If (cNT0TPCEXC == "1")  // Excedente por Hora

					If nTempo <= 0
						nHoraMedio := 0
					Else
						nHoraMedio := nVTS / nTempo
					EndIf

					If nTempo > nNT0LIMEXH
						nTempoEx   := nTempo - nNT0LIMEXH
						nHonExHora := Round( nTempoEx * nHoraMedio, nDecHon)
						nHon       := nFixo + nHonExHora + nTab
					Else
						nHon       := nFixo + nTab
					EndIf

				Else //cNT0TPCEXC = "2" // Excedente por Valor

					nHonFxExc := Round(aConvLanc[1], nDecHon)
					If nVTS > nHonFxExc
						nHonExFixo := nVTS - nHonFxExc
					EndIf
					nHon   := nFixo + nHonExFixo + nTab

				EndIf

				If ( oParams:GetTpExec() $ "1" .And. oParams:GetSituac() <> "1" ) // Emissão de pré
					J201DCotac(cCodPre, cNT0CMOEF, aConvLanc[2] )
				EndIf
			Else
				//zera as variáveis de limite para não ser exibido no relatório da pre-fatura
				cNT0TPCEXC := " "
			Endif

		EndIf

	EndIf

	//Processa o limite geral para o contrato:
	If (nNT0VLRLI > 0)

		If oParams:GetSituac() <> "1"
			//Reajuste dos valores para cálculo do limite geral - Fatura Adicional já chega com os valores corretos aqui
			If cTEMFA == "2"
				If cCTBCVL == "1"
					nHonLim := nHon
				Else
					nHonLim := nHon - nTab
				EndIf
				If cCFXCVL == "2"
					nHonLim := nHonLim - nHonPartFx
				EndIf
			EndIf

			//Converte o valor acumulado para Limite na moeda do limite geral:
			aConvLanc  := JA201FConv( cNT0CMOELI, cCMOEDFT, nHonLim, oParams:GetTpExec(), oParams:GetDEmi(), oParams:GetCFilaImpr(), cCodPre )
			nHonLimite := Round( aConvLanc[1], nDecHon)

			//Cotação da pré para a moeda do Limite do contrato
			If ( oParams:GetTpExec() $ "1" .And. oParams:GetSituac() <> "1" ) // Emissão de pré
				J201DCotac(cCodPre, cNT0CMOELI, aConvLanc[3] )
			EndIf

			nSaldoUtil := Round(JURA201G( "2", cNT0CMOELI, oParams:GetCFilaImpr(), cCONTR,  oParams:GetTpExec(), oParams:GetDEmi(), cCodPre), nDecHon)

			// Se o valor Faturado for maior do que o limite total, soma o valor da pré-fatura com o saldo utilizado
			If ( nHonLimite + nSaldoUtil > nNT0VLRLI )

				nDescLimite := nHonLimite - ( nNT0VLRLI - nSaldoUtil )

				If cTEMFA == "1" .And. cCFACVL == "2"
					nDescLimite := 0 //Se a fatura adicional não faz parte do limite o desconto do limite é Zero
				EndIf

				//Converte o excedente para a moeda da Fatura:
				aConvLanc   := JA201FConv( cCMOEDFT, cNT0CMOELI, nDescLimite, oParams:GetTpExec(), oParams:GetDEmi(), oParams:GetCFilaImpr(), cCodPre )
				nDescLimite := Round(aConvLanc[1], nDecHon)

				If oParams:GetSituac() != "1" //se não for conferência...
					nHon       := nHonLim - nDescLimite
					nHonLim    := nHon //Reatribui o valor limite para fazer a distribuição dos valores
					If nNT0VLRLIF > 0  // Somente se possuir LIMITE POR FATURA
						nSaldoProx += nDescLimite // Acumula o desconto do limite do excedente no saldo próximo
						nUtilFat   -= nDescLimite
						nUtilFat   := IIf(nUtilFat < 0, 0, nUtilFat)
					EndIf
				EndIf
				//adicionar os honorários que não foram considerados no limite:

				If cTEMFA == "2"
					If cCTBCVL == "2"
						nHon  := nHon + nTab
					EndIf
					If cCFXCVL == "2"
						nHon  := nHon + nFixo
					EndIf
				Else
					If cCFACVL == "2"
						nHon  := nVlFAdTs + nVlFAdTab //Se a fatura adicional não faz parte do limite o valor é integral
					Else
						nHon  := nHon + IIf(cCTBCVL == "2", nVlFAdTab, 0) //Se faz parte do limite, verifica se o lançamento tabelado faz parte do limite
					EndIf
				EndIf

				If nHon < 0
					nHon := 0
				EndIf

			EndIf

			//Ajuste para que seja considerado o valor de TS que de fato vai ser cobrado, para tratar a questão da faixa e do Misto/Mínimo
			If nHonFxFat > 0
				nVTSFLim := nHonFxFat
			ElseIf nHonExHora > 0
				nVTSFLim := nHonExHora
			ElseIf nHonExFixo > 0
				nVTSFLim := nHonExFixo
			ElseIf (cNRACOBRAH == "1" .And. cTemTS == "1" .And. !Empty(cCodPre)) .Or. oParams:GetSituac() == "1"
				nVTSFLim := nVTS
			EndIf

			//Distribui o valor entre TS, FX, LT nessa ordem
			aLimite := J201EVlLm(nHonLim, nVTSFLim, nVTAB, nFixo, cCTBCVL, cCFXCVL, cTEMFA, cCFACVL)

			If aLimite[1]
				lTotLimt := aLimite[3] //Realizou alguma distribuição de valores
				nVlTSFat := aLimite[4]
				nVlTSLim := aLimite[5]
				nVlFXFat := aLimite[6]
				nVlFXLim := aLimite[7]
				nVlLTFat := aLimite[8]
				nVlLTLim := aLimite[9]
			Else
				aRet := {.F., aLimite[2] }
			EndIf

		Else
			nNT0VLRLI := 0
			nNT0VLRLIF := 0
		EndIf

	Else
		nVlLTFat := nVTAB
	EndIf

	//Ajustes para preenchimento dos campos de TSs Vinculados / TSs Faturados
	If cTEMTS == "1" .And. cNRACOBRAH == "1"
		If nNT0VLRLIF > 0  //Valor limite por fatura
			nVTSFat := nHon - IIF(lLimFatGer, nVlLTFat + nVlFXFat, nTab + nFixo) 
			If nVTSFat != nVTS .Or. nVTSFat != nVTSAnt
				lExcede := .T.
			EndIf
			nVlFXFat := nFixo

		ElseIf !(nNT0VLRLI > 0) //Limite Geral
			If nHonFxFat > 0 .And. nNT0VLRLIF <= 0  //Faixa de Faturamento Hora/Valor
				nVTSFat := nHonFxFat
				lExcede := .T.
			ElseIf cNRACOBRAF == "1" .AND. cNT0TPCEXC != " " //Misto e Mínimo
				If oParams:GetSituac() <> "1" 
					If cNT0FIXEXC == "2" //Misto
						nVTSFat := nHon - nTab
					Else //Mínimo
						nVTSFat := nHon - nTab - nFixo
						nVlFXFat := nFixo
					EndIf
					lExcede := .T.
				EndIf
			ElseIf cNRACOBRAF == "1" // Hora e Fixo
				nVTSFat  := nVTS
				nVlFXFat := nFixo
			Else
				nVTSFat := nVTS
			EndIf
		Else
			nVTSFat := nVlTSFat
			lExcede := .T.
		EndIf
		If oParams:GetSituac() == "1" 
			nNT0VLRLIF := 0
			nNT0VLRLI := 0
		EndIf
	ElseIf cTEMFA == "1" .And. cTEMTS == "1" .And. cNRACOBRAH == "2" .And. cNRACOBRAF == "1"
		nVTSFat  := nVTS
		nVlFXFat := nFixo
	Else
		nVTSFat  := 0
		nVlFXFat := nFixo
	EndIf

	//Calcula o rateio dos Fixo, Excedente e Limite entre os casos
	If (nFixo != 0 .Or. lFaixa .Or. lExcede .Or. lTotLimt .Or. cTemLM == "1" .Or. nFixo != nNX1VFixo)
		nNX5PDesc := 0
		nX5DescH := 0
		If Empty(cCodPre) .AND. !Empty(oParams:GetCFilaImpr())
			aDesctoH := JurGetDados("NX5", 1, xFilial("NX5") + oParams:GetCFilaImpr(), {"NX5_PDESCH", "NX5_DESCH"}) 
			nNX5PDesc := aDesctoH[01]
			nX5DescH  := aDesctoH[02]
		EndIf
		nHnLinUt := IIf(cTemLM == "1", nUtilFat, 0)
		J201EDivCs( cCodPre, cFatura, cEscr, cNVVCOD, cCONTR, nVlFXFat, oParams, lFaixa, nHonFxFat, Iif(lExcede .Or. lLimFatGer, nVTSFat, 0), lTotLimt, nFixo, nVlLTFat, nHnLinUt, nNX1VFixo, nNX5PDesc, nX5DescH, @lDesLin)
		oParams:SetResomaFt(.F.) // Força que não seja feito o recálculo devido a possibilidade de junção de contratos com outros tipos de honorários que entrariam no else abaixo
	Else
		If Empty(cNVVCOD) .And. Empty(oParams:GetResomaFt(.F.)) // Verifica se já foi preenchido na rotina do caso JURA201D
			oParams:SetResomaFt(.T.) // Informa que foi feito o rateio da fatura e não pode ser sumarizada de baixo para cima na rotina 203hConv() - como .T. força a sumarização
		EndIf
	EndIf

	// Ajusta o desconto linear e especial dos Casos
	If (nVDESCO > 0 .Or. nVLDESC > 0 .Or. nPCDESC > 0 .Or. (nHnLinUt > 0 .And. lDesLin)) .And. (nNT0VLRLI > 0 .Or. nNT0VLRLIF > 0 .Or. lExcede .Or. nFixo > 0)
		J201EAjDesc(oParams, cCodPre, cCONTR, cEscr, cFatura, @nVDESCO, @nVLDESC)
	EndIf

	If cTemLM == "1" //Se tem saldo de limite o saldo deve compor o valor do timesheet
		nVTSFat := nVTSFat + IIf(lExcede, 0, nUtilFat)
	EndIf

	If nVTS <= 0 .And. cTemTS == "2"
		cFlagTS := "2"
	Else
		cFlagTS := "1"
	EndIf

	If nDesp <= 0 .And. cTemDP == "2"
		cFlagDP := "2"
	Else
		cFlagDP := "1"
	EndIf

	If nTab <= 0 .And. cTemLT == "2"
		cFlagLT := "2"
	Else
		cFlagLT := "1"
	EndIf

	If nFixo <= 0 .Or. !Empty(cNVVCOD)
		cFlagFX := "2"
	Else
		cFlagFX := "1"
	EndIf

	If Empty(cNVVCOD)
		cFlagFA := "2"
	Else
		cFlagFA := "1"
	EndIf
	
	If !Empty(oParams:GetCFilaImpr())

		//Se for emitida pela fila de impressão, rateia o desconto / acréscimo:
		cQueryNX5 := " SELECT NX5.NX5_DESCH, NX5.NX5_PDESCH, NX5_ACRESH, NX5_PACREH "
		cQueryNX5 +=   " FROM " + RetSqlName("NX5") + " NX5  "
		cQueryNX5 +=  " WHERE NX5.NX5_FILIAL = '" + xFilial("NT1") +"' "
		cQueryNX5 +=    " AND NX5.NX5_CODUSR = '" + oParams:GetCodUser() +"' "
		cQueryNX5 +=    " AND NX5.NX5_COD = '" + oParams:GetCFilaImpr() +"' "
		cQueryNX5 +=    " AND NX5.D_E_L_E_T_ = ' ' "

		cQueryNX5 := ChangeQuery(cQueryNX5, .F.)
		DbCommitAll() // Para efetivar a alteração no banco de dados (não impacta no rollback da trasação)
		dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQueryNX5 ), cQryResNX5, .T., .F. )
		If Empty (cCodPre)
			nVLDESC := (cQryResNX5)->NX5_DESCH
		EndIf
		nVACRES := (cQryResNX5)->NX5_ACRESH

		(cQryResNX5)->(dbCloseArea())
	EndIf

	// Insere o Contrato se tiver algum valor
	If !( (nHon == 0 ) ;
			.And. (nDesp == 0 ) ;
			.And. (nTab == 0 .Or. (nTab > 0 .And. nHon == 0)) ;
			.And. (nVLDESC  == 0 ) ;
			.And. (nVACRES  == 0 ) ;
			.And. (nFixo  == 0 ) ;
			.And. (nVTS == 0 .Or. (nVTS > 0 .And. nHon == 0)) ;
			.And. (nTSTab  == 0 ) ;
			.And. (Iif(nDescLimite > 0, nHon > 0, nHon == 0 ));
			.And. (nHonExFixo  == 0 ) ;
			.And. (nHonExHora == 0 ) ;
			.And. (cFlagFX != '1' ) ;
			.And. ( Empty(cNVVCOD) ) ;
			) .Or. (cTemTS == "1" .Or. cTemDP == "1" .Or. cTemLT == "1" .Or. cTemLM == "1")

		If oParams:GetTpExec() $ "1|2|6"  //Emissão de pré
			NX8->(dbSetOrder(1))  //NX8_FILIAL+NX8_CPREFT+NX8_CCONTR
			lInclui := !(NX8->(DbSeek(xFilial("NX8") + cCodPre + cCONTR)))
			RecLock("NX8", lInclui)
			If lInclui
				NX8->NX8_FILIAL := xFilial("NX8")
				NX8->NX8_CPREFT := cCodPre
				NX8->NX8_CCONTR := cCONTR
				If NT0->(ColumnPos("NT0_DTVIGI")) > 0 // Proteção
					NX8->NX8_DTVIGI := dDTVIGI
					NX8->NX8_DTVIGF := dDTVIGF
				EndIf
				If lFSinc .And. NX8->(ColumnPos('NX8_CCLICM')) > 0 .And. NX8->(ColumnPos('NX8_CLOJCM')) > 0 .And. NX8->(ColumnPos('NX8_CCASCM')) > 0 //Proteção
					NX8->NX8_CCLICM := cCliMae
					NX8->NX8_CLOJCM := cLojMae
					NX8->NX8_CCASCM := cCasMae
				EndIf
				If NX8->(ColumnPos('NX8_CMOELI')) > 0 //Proteção
					NX8->NX8_CMOELI := cNT0CMOELI
					NX8->NX8_VLRLI  := nNT0VLRLI
					NX8->NX8_VLRLIF := nNT0VLRLIF
					NX8->NX8_CFACVL := cCFACVL
					NX8->NX8_CFXCVL := cCFXCVL
					NX8->NX8_CTBCVL := cCTBCVL
					NX8->NX8_SALDOI := nNT0SALDOI
				EndIf
				If NX8->(ColumnPos('NX8_CMOEF')) > 0 //Proteção
					NX8->NX8_CMOEF  := cNT0CMOEF
					NX8->NX8_VLRBAS := nNT0VLRBAS
					NX8->NX8_TPCEXC := cNT0TPCEXC
					NX8->NX8_LIMEXH := nNT0LIMEXH
					NX8->NX8_PERCD  := nNT0PERCD
				EndIf
				If lApuraTS
					NX8->NX8_VLTSPD := J201EApuTS("P", cCONTR, cCMOEDFT, oParams:GetDEmi(), cCodPre)
					NX8->NX8_VLTSMI := J201EApuTS("M", cCONTR, cCMOEDFT, oParams:GetDEmi(), cCodPre)
				EndIf
			EndIf
			// Atualização de dados
			NX8->NX8_CCLIEN := cCLIEN
			NX8->NX8_CLOJA  := cLOJA
			NX8->NX8_CJCONT := cNW2COD
			NX8->NX8_VHON   := nHon
			NX8->NX8_VDESP  := nDesp
			NX8->NX8_VTAB   := nVlLTFat
			If NX8->(ColumnPos('NX8_VTBVIN')) > 0 //Proteção
				NX8->NX8_VTBVIN := nVTbVinc
			EndIf
			NX8->NX8_VLDESC := nVLDESC
			NX8->NX8_VDESCO := nVDESCO
			NX8->NX8_VFIXO  := nVlFXFat
			If NX8->(ColumnPos('NX8_VFXVIN')) > 0 //Proteção
				NX8->NX8_VFXVIN := nFixo
			EndIf
			NX8->NX8_VTS    := nVTSFat
			NX8->NX8_VTSVIN := nVTSVinc
			If lTSNCobra // Vincula TimeSheet não cobrável
				NX8->NX8_VTSNC := nVTSNCobra
			EndIf
			NX8->NX8_VTSTAB := nVTSTAB
			NX8->NX8_VEXLIM := nDescLimite
			NX8->NX8_VEXFX  := nHonExFixo
			NX8->NX8_VEXHR  := nHonExHora
			NX8->NX8_VFXFAT := nHonFxFat
			NX8->NX8_VUTFAT := IIf(nUtilFat < 0, 0, nUtilFat)
			If lNX8VSLDAC
				NX8->NX8_VSLDAC := IIf(nSaldoPre < 0, 0, nSaldoPre)
			EndIf
			NX8->NX8_VSLDPX := nSaldoFat
			NX8->NX8_TSREV  := "2"
			NX8->NX8_DSPREV := "2"
			NX8->NX8_TABREV := "2"
			NX8->NX8_CPARFX := ""
			NX8->NX8_CFTADC := cNVVCOD
			NX8->NX8_FIXO   := cFlagFX
			NX8->NX8_FATADC := cFlagFA
			NX8->NX8_TS     := cFlagTS
			NX8->NX8_DESP   := cFlagDP
			NX8->NX8_LANTAB := cFlagLT
			NX8->NX8_CPART  := cNT0CPART1
			NX8->NX8_VDESCT := nVLDESC + nVDESCO
			NX8->NX8_VLTSLM := nVlTSLim
			NX8->NX8_VLFXLM := nVlFXLim
			NX8->NX8_VLLTLM := nVlLTLim
			If NX8->(ColumnPos('NX8_CTPHON')) > 0 //Proteção
				NX8->NX8_CTPHON := cCTPHON
			EndIf
			If lDespTrib
				NX8->NX8_VLTRIB := nVlDpTrib
				NX8->NX8_VLREMB := nVlDpReemb
			EndIf
			If NX8->(ColumnPos("NX8_UTLIMT")) > 0 //Proteção
				NX8->NX8_UTLIMT := J201GSldLm(cCONTR, "1", {cCTPHON, nNT0VLRLI, nNT0SALDOI, cNT0CMOELI, cCFACVL, cCTBCVL, cCFXCVL}) // Limite geral utilizado
			EndIf
			If NX8->(ColumnPos('NX8_VLTSTP')) > 0 //Proteção
				NX8->NX8_VLTSTP  := nTempo 
				NX8->NX8_TPEXCH  := nTempoEx
			EndIf	

			NX8->(MsUnlock())
			NX8->(DbCommit())
		EndIf

		If oParams:GetTpExec() $ "3|4|5|MS" // Minuta de Pré / Minuta de Fatura / Emissão de Fatura
			NXB->(dbSetOrder(1))  //NXB_FILIAL+NXB_CESCR+NXB_CFATUR+NXB_CCLIEN+NXB_CLOJA+NXB_CCONTR
			If !(NXB->(DbSeek(xFilial("NXB") + cEscr + cFatura + cCLIEN + cLOJA + cCONTR)))
				RecLock("NXB", .T.)
				NXB->NXB_FILIAL := xFilial("NXB")
				NXB->NXB_CESCR  := cEscr
				NXB->NXB_CFATUR := cFatura
				NXB->NXB_CCLIEN := cCLIEN
				NXB->NXB_CLOJA  := cLOJA
				NXB->NXB_CCONTR := cCONTR
				If NT0->(ColumnPos("NT0_DTVIGI")) > 0 // Proteção
					NXB->NXB_DTVIGI := dDTVIGI
					NXB->NXB_DTVIGF := dDTVIGF
				EndIf
				NXB->NXB_VLFATH := nHon
				NXB->NXB_VTS    := nVTSFat
				NXB->NXB_VTSVIN := nVTSVinc
				If lTSNCobra
					NXB->NXB_VTSNC := nVTSNCobra
				EndIf
				NXB->NXB_VTSTAB := nVTSTAB
				NXB->NXB_VLFATD := nDesp
				NXB->NXB_VTAB   := nVlLTFat
				If NXB->(ColumnPos('NXB_VTBVIN')) > 0 //Proteção
					NXB->NXB_VTBVIN := nVTbVinc
				EndIf
				NXB->NXB_SLDANT := nUtilFat
				NXB->NXB_SLDPRO := nSaldoProx
				NXB->NXB_VEXFX  := nHonExFixo
				NXB->NXB_VEXHR  := nHonExHora
				NXB->NXB_VLHFV  := nHonFxFat
				NXB->NXB_SLDLF  := nSaldoFat
				NXB->NXB_DVLLIM := 0
				If NX8->(ColumnPos('NX8_CTPHON')) > 0 .And. !Empty(cCodPre) //Proteção
					NXB->NXB_CTPHON := JurGetDados("NX8", 1, xFilial("NX8") + cCodPre + cCONTR, "NX8_CTPHON") // cCTPHON
				Else
					NXB->NXB_CTPHON := cCTPHON
				EndIf
				NXB->NXB_DRATF  := nVLDESC + nVDESCO
				NXB->NXB_DRATL  := nVDESCO
				NXB->NXB_DRATE  := nVLDESC
				NXB->NXB_DRATP  := 0
				NXB->NXB_ARATF  := 0 ////o acréscimo rateado no contrato é calculado na rotina de rateio (JA203ARat)
				NXB->NXB_VLTSLM := nVlTSLim
				NXB->NXB_VLFXLM := nVlFXLim
				NXB->NXB_VLLTLM := nVlLTLim
				NXB->NXB_VFIXO  := nVlFXFat
				If lDespTrib
					NXB->NXB_VLTRIB := nVlDpTrib
					NXB->NXB_VLREMB := nVlDpReemb
				EndIf
				If NXB->(ColumnPos('NXB_VFXVIN')) > 0 //Proteção
					NXB->NXB_VFXVIN := nFixo
				EndIf
				If lFSinc .And. NX8->(ColumnPos( 'NX8_CLOJCM' )) > 0 .And. ;
				                NXB->(ColumnPos( 'NXB_CCLICM' )) > 0 .And. ;
								NXB->(ColumnPos( 'NXB_CLOJCM' )) > 0 .And. ;
								NXB->(ColumnPos( 'NXB_CCASCM' )) > 0 // Proteção

					If Empty(cCodPre)
						NXB->NXB_CCLICM := cCliMae
						NXB->NXB_CLOJCM := cLojMae
						NXB->NXB_CCASCM := cCasMae
					Else
						aRetCasMae  := JurGetDados("NX8", 1, xFilial("NX8") + cCodPre + cCONTR, {"NX8_CCLICM", "NX8_CLOJCM", "NX8_CCASCM"})

						If Len(aRetCasMae) == 3
							NXB->NXB_CCLICM := aRetCasMae[1]
							NXB->NXB_CLOJCM := aRetCasMae[2]
							NXB->NXB_CCASCM := aRetCasMae[3]
						EndIf
					EndIf
				EndIf
				NXB->(MsUnlock())
				NXB->(DbCommit())
			EndIf
		EndIf
	Else //Remove o caso sem lançamentos da pré-fatura ou sem FA e FX.
		If oParams:GetTpExec() $ "1|2|6"
			If NX8->(DbSeek(xFilial("NX8") + cCodPre + cCONTR))
				RecLock("NX8", .F., .F., .F., .T.)
				NX8->(DbDelete())
				NX8->(MsUnlock())
				NX8->(DbCommit())
			EndIf
		EndIf
	EndIf

	/*Carrega os múltiplos revisores dos Casos deste Contrato*/
	If oParams:GetTpExec() == "1"
		J201EGrvRv(cCodPre, cCONTR)
	EndIf

	(cQryRes)->(DbSkip())
	aRet := {.T., "JA201ECont"}
EndDo

(cQryRes)->(DbCloseArea())
RestArea(aArea)

Return (aRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} J201ENX8Vl()
Rotina para retorna os valores da NX8 na remissão de pré-fatura

@param   cCodPre, caractere, Código da Pré-Fatura
@param   cContr , caractere, Código do contrato

@return  aRetNX8, array    , Valores do contrato da pré-fatura

@author  Bruno Ritter / Jonatas Martins
@since   24/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static function J201ENX8Vl(cCodPre, cContr)
	Local aCpoNX8 := {}
	Local aRetNX8 := {}

	If NX8->(ColumnPos('NX8_CMOELI')) > 0
		aAdd(aCpoNX8, "NX8_CMOELI")
		aAdd(aCpoNX8, "NX8_VLRLI" )
		aAdd(aCpoNX8, "NX8_VLRLIF")
		aAdd(aCpoNX8, "NX8_CFACVL")
		aAdd(aCpoNX8, "NX8_CFXCVL")
		aAdd(aCpoNX8, "NX8_CTBCVL")
		aAdd(aCpoNX8, "NX8_CMOEF" )
		aAdd(aCpoNX8, "NX8_VLRBAS")
		aAdd(aCpoNX8, "NX8_TPCEXC")
		aAdd(aCpoNX8, "NX8_LIMEXH")
		aAdd(aCpoNX8, "NX8_PERCD" )
		aAdd(aCpoNX8, "NX8_SALDOI" )
        aAdd(aCpoNX8, "NX8_CTPHON" )
	EndIf

	If ! Empty(aCpoNX8)
		aRetNX8 := JurGetDados("NX8", 1, xFilial("NX8") + cCodPre + cContr, aCpoNX8)
	EndIf

Return (aRetNX8)

//-------------------------------------------------------------------
/*/{Protheus.doc} J201EVlLm()
Rotina para distribuir o valor do limite e o faturado entre os valores de TS,FX,LT.

@Param    nVLimite    Valor limite da pré-fatura / fatura
@Param    nVTS         Valor do Time Sheet
@Param    nVTAB        Valor do Lançamento tabelado
@Param    nFixo        Valor da parcela de Fixo
@Param    cCTBCVL      "1" Se o Lançamento tabelado entra no calculo de limite
@Param    cCFXCVL      "1" Se a parcela de Fixo entra no calculo de limite

@Return    aReturn[1]  Retorno lógico: Se .T. efetuou a distribuicão correta
		   aReturn[2]  Nome da função
           aReturn[3]  Retorno lógico: Se .T. Ocorreu o rateio em algum dos valores
           aReturn[4]  Valor Faturado de TS
           aReturn[5]  Valor Limite de TS
           aReturn[6]  Valor Faturado de Fixo
           aReturn[7]  Valor Limite de Fixo
           aReturn[8]  Valor Faturado de TB
           aReturn[9]  Valor Limite de TB

@author Luciano Pereira dos Santos
@since 11/03/17
@version 1.0
/*/
//-------------------------------------------------------------------
Function J201EVlLm(nVLimite, nVTS, nVTAB, nFixo, cCTBCVL, cCFXCVL, cTEMFA, cCFACVL)
Local aReturn     := {}
Local nSaldo      := 0
Local lLimite     := .F.
Local nVlFXLim    := 0
Local nVlLTLim    := 0
Local nVlTSLim    := 0

Default nVLimite  := 0
Default nVTS      := 0
Default nFixo     := 0
Default nVTAB     := 0
Default cCTBCVL   := "2"
Default cCFXCVL   := "2"
Default cTEMFA    := "2"
Default cCFACVL   := "2"

//          1  ,  2         , 3      , 4   , 5       , 6    , 7       , 8    , 9
aReturn := {.T., "J201EVlLm", lLimite, nVTS, nVlTSLim, nFixo, nVlFXLim, nVTAB, nVlLTLim}

If (cTEMFA == "2" .Or. cCFACVL == "1")

	If nVTS > 0
		If (nVTS - nVLimite ) < 0  // Credita o Time Sheet
			aReturn[4] := nVTS
			nSaldo     := nVLimite - nVTS
		Else
			aReturn[4] := nVLimite
			nSaldo     := 0
		EndIf
		aReturn[5] := aReturn[4]
	Else
		nSaldo     := nVLimite
		aReturn[5] := 0
	EndIf

	If cCFXCVL == "1"  // Credita o Fixo
		If (nFixo - nSaldo) < 0
			aReturn[6] := nFixo
			nSaldo     := nSaldo - nFixo
		Else
			If cCTBCVL == "1" .And. (nFixo < nSaldo)
				aReturn[6] := nFixo
				nSaldo     := nSaldo - nFixo
			Else
				aReturn[6] := nSaldo
				nSaldo     := 0
			EndIf
		EndIf
		aReturn[7] := aReturn[6]
	Else
		aReturn[6] := nFixo
		aReturn[7] := 0
	EndIf

	If cCTBCVL == "1"  // Credita o Tabelado
		If (nVTAB - nSaldo) < 0
			aReturn[8] := nVTAB
			nSaldo     := 0
		Else
			aReturn[8] := nSaldo
			nSaldo     := 0
		EndIf
		aReturn[9] := aReturn[8]
	Else
		aReturn[8] := nVTAB
		aReturn[9] := 0
		nSaldo     := 0
	EndIf

	If (nSaldo != 0)
		aReturn[1] := .F.
	Else
		lLimite    := (aReturn[4] != nVTS .Or. aReturn[6] != nFixo .Or. aReturn[8] != nVTAB)
		aReturn[3] := lLimite
	EndIf

EndIf

Return aReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} J201ECorrF
Função utilizada para corrigir o valor das parcelas do contrato

@param  cContr     Código do Contrato a ser atualizado
@param  cParcela   Código da parcela do Contrato
@param  lAutomatic Indica se a geração das parcelas é automática ou manual
@param  lAutomato  Indica se a chamada foi feita via automação

@See    J96CorrCDF

@Obs    Ao realizar manutenção da rotina, verificar a rotina original J96CorrCDF

@author Jorge Luis Branco Martins Junior
@since 06/04/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J201ECorrF(cContr, cParcela, lAutomatic, lAutomato)
Local aArea        := GetArea()
Local aAreaNT1     := NT1->(GetArea())
Local cQuery       := ""
Local cQryRes      := ""
Local nValorAtu    := 0
Local cNT1CMOEF    := ""
Local cMoedaNac    := SuperGetMv('MV_JMOENAC',,'01' )
Local nValorBase   := 0

Default cContr     := ""
Default cParcela   := ""
Default lAutomatic := .F.
Default lAutomato  := .F.

// Preenche o valor base atualizado do contrato
NT0->(DbSetOrder(1)) // NT0_FILIAL + NT0_COD
If NT0->(DBSeeK(xFilial('NT0') + cContr)) .And. NT0->NT0_TPCORR == "2"

	cQuery := " SELECT NT1.R_E_C_N_O_ NT1_RECNO "
	cQuery += " FROM " + RetSqlName('NT1') + " NT1 "
	cQuery += " WHERE NT1.NT1_FILIAL = '" + xFilial('NT1') + "' "
	cQuery +=   " AND NT1.NT1_SITUAC = '1' "
	cQuery +=   " AND NT1.NT1_CCONTR = '" + cContr + "' "
	If !lAutomatic
		cQuery += " AND NT1.NT1_PARC = '" + cParcela + "' "
	EndIf
	cQuery += " AND NT1.D_E_L_E_T_ = ' ' "

	cQryRes := GetNextAlias()

	cQuery := ChangeQuery(cQuery, .F.)
	DbCommitAll()
	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryRes, .T., .F. )

	While !(cQryRes)->(Eof())

		NT1->(DbGoto((cQryRes)->NT1_RECNO))

		If !Empty(NT1->NT1_CMOEDA)  // caso a parcela nao tenha moeda e usada como padra a moeda do contrato
			cNT1CMOEF := NT1->NT1_CMOEDA
		Else
			cNT1CMOEF := NT0->NT0_CMOEF
		EndIf

		If !lAutomatic
			nValorBase := NT1->NT1_VALORB
		Else
			nValorBase := NT0->NT0_VLRBAS
		EndIf

		If cNT1CMOEF == cMoedaNac //Só Faz a correção da parcela se o valor for em moeda nacional.
			nValorAtu := JCorrIndic(nValorBase, NT0->NT0_DTBASE, NT1->NT1_DATAVE, NT0->NT0_PERCOR, NT0->NT0_CINDIC, "V",,, lAutomato)
		Else
			nValorAtu := nValorBase
		EndIf

		//Ajusta o valor da parcela quando se tratar de Misto
		If lAutomatic
			If NT0->NT0_FIXEXC == '2' .And. !Empty(NT0->NT0_PEREX) .And. !Empty(NT0->NT0_PERFIX)
				nValorAtu := nValorAtu / (NT0->NT0_PEREX / NT0->NT0_PERFIX)
			EndIf

			If !Empty(NT0->NT0_PERCD)
				nValorAtu := nValorAtu - ( nValorAtu * ( NT0->NT0_PERCD / 100 ) )
			EndIf
		EndIf

		RecLock("NT1", .F., .F., .F., .T.)
		NT1->NT1_VALORA := Round(nValorAtu, TamSX3('NT1_VALORA')[2])
		NT1->NT1_DATAAT := Date()
		NT1->(MsUnlock())
		NT1->(DbCommit())

		(cQryRes)->(DbSkip())

	EndDo

	// Preenche o valor base atualizado do contrato
	nValorAtu := JCorrIndic(nValorBase, NT0->NT0_DTBASE, Nil, NT0->NT0_PERCOR, NT0->NT0_CINDIC, "V",,, lAutomato)

	If Empty(nValorAtu) .And. !lAutomatic
		nValorAtu := JCorrIndic(NT0->NT0_VLRBAS, NT0->NT0_DTBASE, Nil, NT0->NT0_PERCOR, NT0->NT0_CINDIC, "V",,, lAutomato)
	EndIf

	If !Empty(nValorAtu)
		RecLock("NT0", .F., .F., .F., .T.)
		NT0->NT0_VALORA := Round(nValorAtu, TamSX3('NT0_VALORA')[2])
		If NT0->(ColumnPos('NT0_DATAAT')) > 0 //Proteção
			NT0->NT0_DATAAT := Date()
		EndIf
		NT0->(MsUnlock())
		NT0->(DbCommit())
	EndIf

	(cQryRes)->(DbCloseArea())
EndIf

RestArea(aAreaNT1)
RestArea(aArea)

Return nValorAtu

//-------------------------------------------------------------------
/*/{Protheus.doc} J201EDivCs()
Calcula os totais da divisao dos casos para TimeSheet, Fixo e Lançamento tabelado
para pré-fatura e fatura.

@Param cPreft    código da pré-fatura
@Param cFatura   código da Fatura
@Param cEscr     código do Escritório
@Param cCodAdic  código da Fatura Adicional
@Param cContr    código da Fatura Adicional
@Param nTotFX    Valor total de fixo que de fato está sendo faturado
@Param oParams   objeto de paramentros de emissão da pré/fatura
@Param lFaixa    .T. indica se o tipo de honorários do contrato é por faixa de faturamento
@Param nHonFxFat  Valor de honorários referente a faixa do contrato
@Param nVTSFat    Valor total de TS que de fato está sendo faturado, para calcular o valor de TS
                    dos casos quando for Misto/Mínimo, ou seja, para considerar o excedente
@Param lTotLimt  .T. indica se todo o limite foi usado para ajustar o valor dos casos
@Param nFxVinc    Valor total de fixo vinculado ao contrato
@Param nVLTFat    Valor total de TB que de fato está sendo faturado para divisão entre os casos
@Param nHonLim    Valor total de honorários considerando limites por fatura excedidos
@param lDesLin	  Contém desconto linear

@Return Nil

@author Luciano Pereira dos Santos
@since 08/05/2017 
@version 1.0
/*/
//-------------------------------------------------------------------
Function J201EDivCs(cPreft, cFatura, cEscr, cCodAdic, cContr, nTotFX, oParams, lFaixa, nHonFxFat, nVTSFat, lTotLimt, nFxVinc, nVLTFat, nHonLim, nNX1VlFix, nNX5PDesc, nX5DescH, lDesLin)
Local aArea      := GetArea()
Local aGetCas    := {}
Local aCasos     := {}
Local aTotCas    := {}
Local nRec       := 0
Local cTpDiv     := AllTrim(GetMv("MV_JDIVCAS",, "1")) //Padrao "1" - (1=”TS”;2=”Peso do Caso”)
Local nQtdCas    := 0
Local nPesoCas   := 0
Local nVlTSCas   := 0
Local nVlTBCas   := 0
Local nPesoTot   := 0
Local nVlTSTot   := 0
Local nVlTBTot   := 0
Local nPercen    := 0
Local nVlCasoH   := 0
Local nVlCasoD   := 0
Local nVUTFat    := 0
Local cTpHon     := ""
Local lMistMin   := .F.
Local cCobH      := ""
Local cCobF      := ""
Local cAliasTb   := ""

Local lVincTS    := .F.
Local lTemAtivo  := .F.
Local lQtdCas    := .F.
Local lFxaHrVl   := .F. //Indica que é Faixa por Hora ou Valor - usado para nestas situações não preencher o Valor Fixo apesar do nTotxFx > 0
Local lHrFx      := .F. //Indica se é Mínimo ou Misto
Local lPropLT    := .F.
Local nQtdTS     := 0
Local nQtdDes    := 0
Local nQtdTab    := 0

Local nRecVTS    := 0
Local nMaiorVTS  := 0
Local nRecVFx    := 0
Local nMaiorVFx  := 0
Local nRecVFaix  := 0
Local nMaiorFaix := 0
Local nRecVTab   := 0
Local nMaiorTab  := 0

Local nSumFaixa  := 0
Local nSumFixo   := 0
Local nSumFxVin  := 0
Local nSumVTSFat := 0
Local nSumTabFat := 0

Local nDecHon    := 2
Local nDecTab    := 2
Local nDecTs     := 2
Local nDecFxFat  := 2
Local nDecFx     := 2
Local nDecFxVin  := 2

Local nVTS       := 0
Local nVFXFAT    := 0
Local nVfixo     := 0
Local nVfxVin    := 0
Local nVHon      := 0

Local nDifTS     := 0
Local nDifFX     := 0
Local nDifFXvin  := 0
Local nDifFaix   := 0
Local nDiffDsFH	 := 0
Local nDescFxH	 := 0

Default nHonFxFat := 0
Default nVTSFat   := 0
Default lFaixa    := .F.
Default lTotLimt  := .F.
Default nTotFX    := 0
Default nFxVinc   := nTotFX
Default nVLTFat   := 0
Default nHonLim   := 0
Default nNX1VlFix := 0
Default nNX5PDesc := 0
Default nX5DescH  := 0
Default lDesLin   := .F.

If oParams:GetTpExec() == "1" .Or. Empty(cPreft) // Emissão de Pré-fatura ou Emissão de Fatura que não veio de uma Pré-Fatura
	cTpHon   := JurGetDados("NT0", 1, xFilial("NT0",) + cContr, "NT0_CTPHON")
	lMistMin := JurGetDados("NT0", 1, xFilial("NT0",) + cContr, "NT0_TPCEXC") <> "" //Se o campo esta preenchido é Misto ou Mínimo
Else
	cTpHon   := JurGetDados("NX8", 1, xFilial("NX8",) + cPreft + cContr, "NX8_CTPHON")
	lMistMin := JurGetDados("NX8", 1, xFilial("NX8",) + cPreft + cContr, "NX8_TPCEXC") <> "" //Se o campo esta preenchido é Misto ou Mínimo
EndIf

cCobH    := JurGetDados("NRA", 1, xFilial("NRA") + cTpHon, "NRA_COBRAH")
cCobF    := JurGetDados("NRA", 1, xFilial("NRA") + cTpHon, "NRA_COBRAF")

lQtdCas := Iif(lFaixa, JUR96FAIXA(cTpHon), .F.)

If Len(aGetCas := J201EGetCs(cPreft, cFatura, cEscr, cCodAdic, cContr, nTotFX, nFxVinc, oParams, lFaixa)) == 2
	aCasos  := aGetCas[1]
	aTotCas := aGetCas[2]
EndIf

If Len(aTotCas) == 4
	nVlTSTot   := aTotCas[1]
	nVlTBTot   := aTotCas[2]
	nPesoTot   := aTotCas[3]
	lTemAtivo  := aTotCas[4]
EndIf

If oParams:GetTpExec() $ "1|2|6" // Emissão de pré / Reemissão de pré / Reemissão por Cancelamento
	cAliasTb  := "NX1"
	nDecHon   := TamSX3('NX1_VHON')[2]
	nDecTab   := TamSX3('NX1_VTAB')[2]
	nDecTs    := TamSX3('NX1_VTS')[2]
	nDecFxFat := TamSX3('NX1_VFXFAT')[2]
	If NX1->(ColumnPos('NX1_VFIXO')) > 0 //Proteção
		nDecFx    := TamSX3('NX1_VFIXO')[2]
	Else
		nDecFx    := nDecFxFat
	EndIf
	If NX1->(ColumnPos('NX1_VFXVIN')) > 0 //Proteção
		nDecFxVin := TamSX3('NX1_VFXVIN')[2]
	Else
		nDecFxVin := nDecFxFat
	EndIf
Else //Emissão de minuta de pré / minuta de fatura / fatura
	cAliasTb  := "NXC"
	nDecHon   := TamSX3('NXC_VLHFAT')[2]
	nDecTab   := TamSX3('NXC_VLTAB')[2]
	nDecTs    := TamSX3('NXC_VLTS')[2]
	nDecFxFat := TamSX3('NXC_VLHFV')[2]
	nDecFx    := TamSX3('NXC_VFIXO')[2]
	If NXC->(ColumnPos('NXC_VFXVIN')) > 0 //Proteção
		nDecFxVin := TamSX3('NXC_VFXVIN')[2]
	Else
		nDecFxVin := nDecFx
	EndIf
EndIf

//Nas situações de faixa por valor ou hora é necessario efetuar a distribuição do valor de faixa que está no contrato entre os casos,
//igual ao que é feito no Fixo - Quantidade de casos. Sem esta alteração, seria considerado o Valor de TSs vinculados na pré-fatura.
//Foi utilizado o nTotFX pois ele que será multiplicado pelo percentual mais abaixo.
If lFaixa .And. nTotFX == 0
	nTotFX   := nHonFxFat //Valor de faixa de faturamento no contrato (parâmetro vindo da JURA201E).
	lFxaHrVl := .T.
EndIf

lVincTS  := (cCobH == "2" .And. cCobF == "1" .And. SuperGetMv('MV_JVINCTS ',, .T.))
lHrFx    := (cCobH == "1" .And. cCobF == "1" .And. lMistMin ) //Misto ou Mínimo
lPropLT  := nVLTFat <= nVlTBTot // Indica se deve ser calculado o valor proporcional de tabelado faturado no caso

// Calcula o percentual correto e aplica o calculo atualizando a NXC
nQtdCas := Len(aCasos)
For nRec := 1 To nQtdCas
	//Posiciona no registro da NXC
	(cAliasTb)->( DbGoto(aCasos[nRec][4]) )

	nVlTSCas := aCasos[nRec][1]
	nPesoCas := aCasos[nRec][3]
	nVlTBCas := IIF(lPropLT, Round(aCasos[nRec][2] * nVLTFat / nVlTBTot, nDecTab), aCasos[nRec][2]) // Valor proporcional de tabelado faturado no caso
	nPercen  := 0
	nVlCasoH := 0
	nVUTFat  := 0
	nQtdTS   := aCasos[nRec][5]
	nQtdDes  := aCasos[nRec][6]
	nQtdTab  := aCasos[nRec][7]
	nVlCasoD := aCasos[nRec][8]

	If nTotFX > 0 .Or. nFxVinc > 0 .Or. nHonLim != 0 .Or. nTotFX != nNX1VlFix 

		//Verifica o metodo de calculo do percentual
		//Por Valor TS
		If cTpDiv == "1" .And. nVlTSTot > 0 .And. lTemAtivo .And. !lQtdCas
			nPercen  := nVlTSCas / nVlTSTot

		//Por Peso de Caso
		ElseIf cTpDiv == "2" .And. nPesoTot > 0 .And. lTemAtivo .And. !lQtdCas
			nPercen  := nPesoCas / nPesoTot

		//Valor dividido pela quantidade de casos - se nenhum caso possuir TS, peso, nenhum estiver em andamento ou ainda quando for faixa por
		//Quantidade de casos
		Else
			nPercen  := 1 / nQtdCas
			lQtdCas  := .T.
		EndIf

		//Calcula o valor de honorarios do caso
		If (cCobF == "1" .And. lVincTS) .Or. (lFaixa .And. cCobF == "2" .And. nVTSFat == 0)   //Entra se vincula TSs na parcela fixa ou nas situações de Faixa que não são Quantidade de Casos,
			//para que o Valor de TSs não seja somado no valor do caso
			nVlCasoH :=  nVlTBCas + (IIf(Empty(nTotFX), 0, Round(nTotFX * nPercen, nDecHon) ))
			//Usado para o cálculo do valor de horas diferenciado, ou seja, quando é faixa, misto, mínimo, com limite...
		ElseIf nVTSFat > 0
			If lFaixa //Para atender as situações que são Faixa - Hora e Valor - mas que possuem limite geral ou por fatura
				nVlCasoH := nVlTBCas + IIf(Empty(nVTSFat), 0, Round(nVTSFat * nPercen, nDecHon))
			Else      //Misto e Mínimo
				nVlCasoH :=  IIf(Empty(nVTSFat), 0, Round(nVTSFat * nPercen, nDecHon)) + IIf(Empty(nTotFX), 0, Round(nTotFX * nPercen, nDecHon)) +  nVlTBCas
			EndIf
		ElseIf nHonLim != 0 //Rateio do valor de saldo por limite.
			nVlCasoH := Round(nHonLim * nPercen, nDecHon)
		Else //Cobrança do valor da hora simples, TSs vinculados ao caso
			nVlCasoH := nVlTSCas +  nVlTBCas + IIf(Empty(nTotFX), 0, Round(nTotFX * nPercen, nDecHon))
		EndIf

		// Calcula o Valor do TimeSheet do Caso
		If cCobH == "1"
			If lFaixa .And. (nTotFX == nVTSFat) //Faixa de Faturamento
				nVts := IIf(Empty(nTotFX), 0, Round(nTotFX * nPercen, nDecTs ) )
			ElseIf nVTSFat > 0 .And. (lHrFx .Or. (lFaixa .And. nTotFX != nVTSFat)) //Necessário para as situações em que é faixa, mas tem limite.
				nVts := IIf(Empty(nVTSFat), 0, Round(nVTSFat * nPercen, nDecTs ))
			ElseIf nVTSFat > 0
				nVTS := Round(nVTSFat * nPercen, nDecHon)
			ElseIf nHonLim != 0 
				nVTS := nVlTSCas + nVlCasoH //O rateio do saldo do limite compoe o valor de timesheet no caso.
			Else
				nVTS := nVlTSCas
			EndIf
			nSumVTSFat := nSumVTSFat + nVts //Acumula o total de timeSheet faturado por caso.
		Else
			nVTS := 0
		EndIf

		nSumTabFat := nSumTabFat + nVlTBCas //Acumula o total de Tabelado faturado por caso.

		If lFaixa //Para preencher o campo NX1_VFXFAT quando se tratar de Faixa de Faturamento - Quantidade de Casos, Hora ou Valor
			nVFXFAT   := IIf(Empty(nTotFX), 0, Round(nTotFX * nPercen, nDecFxFat ))
			nSumFaixa := nSumFaixa + nVFXFAT
		EndIf

		If (nTotFX > 0 .Or. nFxVinc > 0 .Or. nTotFX != nNX1VlFix) .And. !lFxaHrVl
			nVfixo    := IIf(Empty(nTotFX), 0, Round(nTotFX * nPercen, nDecFx ))
			nSumFixo  := nSumFixo + nVfixo
			nVfxVin   := IIf(Empty(nFxVinc), 0, Round(nFxVinc * nPercen, nDecFxVin ))
			nSumFxVin := nSumFxVin + nVfxVin
		EndIf

		If nHonLim > 0
			nVUTFat  := Round(nHonLim * nPercen, nDecHon)
		EndIf

		If oParams:GetTpExec() $ "1|2|6" // Emissão de pré / Reemissão de pré / Reemissão por Cancelamento
			//Grava no registro da NX1
            RecLock("NX1",.F.)
            If nVlCasoH == 0 .And. NX1->NX1_VDESP == 0 .And. NX1->NX1_VTSVIN == 0
                NX1->(DbDelete())
            Else
                NX1->NX1_VHON   := nVlCasoH
                NX1->NX1_VUTFAT := nVUTFat
                NX1->NX1_VTAB   := nVlTBCas
                NX1->NX1_VTS    := nVTS
                NX1->NX1_VFXFAT := nVFXFAT
                If NX1->(ColumnPos('NX1_VFIXO')) > 0 //Proteção
                    NX1->NX1_VFIXO  := nVfixo
                EndIf
                If NX1->(ColumnPos('NX1_VFXVIN')) > 0 //Proteção
                    NX1->NX1_VFXVIN := nVfxVin
                EndIf
				lDesLin := lDesLin .Or. NX1->NX1_PDESCH > 0
            EndIf
            NX1->(MsUnlock())
            NX1->(DbCommit())
		Else
			RecLock("NXC",.F.)
			If nVlCasoH == 0 .And. nVlCasoD == 0
				NXC->(DbDelete())
			Else
				NXC->NXC_VLHFAT := nVlCasoH
				NXC->NXC_VLDFAT := nVlCasoD
				NXC->NXC_VLTAB  := nVlTBCas
				NXC->NXC_VLTS   := nVTS
				NXC->NXC_VLHFV  := nVFXFAT
				NXC->NXC_VFIXO  := nVfixo
				If NXC->(ColumnPos('NXC_VFXVIN')) > 0 //Proteção
					NXC->NXC_VFXVIN := nVfxVin
				EndIf
				If nNX5PDesc > 0 .AND. Empty(cPreft)	
					nDescFxH	:= Round((nVfixo * nNX5PDesc  / 100.00), TamSX3('NXC_DRATE')[2])	 
					NXC->NXC_DRATF -= NXC->NXC_DRATE
					NXC->NXC_DRATE := nDescFxH
					NXC->NXC_DRATF += NXC->NXC_DRATE
					nDiffDsFH += nDescFxH
				EndIf
				lDesLin := lDesLin .Or. NXC->NXC_PDESCH  > 0
			EndIf
			NXC->(MsUnlock())
			NXC->(DbCommit())
		EndIf

	ElseIf nVTSFat > 0 .Or. lTotLimt //Para ajustar o campo de Valor de TS quando houver excedente e não houver fixo (Misto)
									//Ou ajusta o valor dos casos, se todo o valor do limite for usado.

		nVts       := Round(( nVlTSCas / nVlTSTot ) * nVTSFat, nDecTs )  //Considera apenas o excedente para rateio com base nos TSs do caso
		nSumVTSFat := nSumVTSFat + nVts
		nVHon      := nVts + nVlTBCas
		nSumTabFat := nSumTabFat + nVlTBCas

		If oParams:GetTpExec() $ "1|2|6" // Emissão de pré / Reemissão de pré / Reemissão por Cancelamento
			//Grava no registro da NX1
			RecLock("NX1",.F.)
			NX1->NX1_VUTFAT := nVUTFat
			NX1->NX1_VTS    := nVts
			NX1->NX1_VHON   := nVHon
			NX1->NX1_VTAB   := nVlTBCas
			NX1->(MsUnlock())
			NX1->(DbCommit())

		Else
			//Grava no registro da NXC
			RecLock("NXC",.F.)
			NXC->NXC_VLTS   := nVts
			NXC->NXC_VLHFAT := nVHon
			NXC->NXC_VLDFAT := nVlCasoD
			NXC->NXC_VLTAB  := nVlTBCas
			NXC->(MsUnlock())
			NXC->(DbCommit())

		EndIf

	Else
		//Apenas para gravar os valores para ajuste de arredondamento, mas nesta situação os valores já devem ter sido gravados ok na JURA201D
		If oParams:GetTpExec() $ "1|2|6" // Emissão de pré / Reemissão de pré / Reemissão por Cancelamento
			RecLock("NX1",.F.)
			NX1->NX1_VHON   := nVlTSCas + nVlTBCas
			NX1->NX1_VTAB   := nVlTBCas
			NX1->(MsUnlock())
			NX1->(DbCommit())

		Else //Emissão de minuta de pré / minuta de fatura / fatura
			RecLock("NXC",.F.)
			NXC->NXC_VLHFAT := nVlTSCas + nVlTBCas
			NXC->NXC_VLTAB  := nVlTBCas
			NXC->NXC_VLDFAT := nVlCasoD
			NXC->(MsUnlock())
			NXC->(DbCommit())

		EndIf

		nSumVTSFat := nSumVTSFat + nVlTSCas
		nSumTabFat := nSumTabFat + nVlTBCas
	EndIf

	//Guarda os valores para realizar ajuste de Arredondamento
	//Valor de TS Faturado
	If nVTSFat > 0
		If oParams:GetTpExec() $ "1|2|6"
			If NX1->NX1_VTS > nMaiorVTS
				nMaiorVTS := NX1->NX1_VTS
				nRecVTS   := NX1->(Recno())
			EndIf
		Else
			If NXC->NXC_VLTS > nMaiorVTS
				nRecVTS   := NXC->(Recno())
			EndIf
		EndIf
	EndIf

	//Valor de Fixo
	If (nTotFX > 0 .Or. nFxVinc > 0).And. !lFxaHrVl
		If oParams:GetTpExec() $ "1|2|6"
			If  NX1->(ColumnPos('NX1_VFIXO')) > 0 //Proteção
				If NX1->NX1_VFIXO > nMaiorVFx
					nMaiorVFx := NX1->NX1_VFIXO
					nRecVFx   := NX1->(Recno())
				EndIf
			EndIf
		Else
			If NXC->NXC_VFIXO > nMaiorVFx
				nMaiorVFx := NXC->NXC_VFIXO
				nRecVFx   := NXC->(Recno())
			EndIf
		EndIf
	EndIf

	//Valor de Faixa
	If nHonFxFat > 0
		If oParams:GetTpExec() $ "1|2|6"
			If NX1->NX1_VFXFAT > nMaiorFaix
				nMaiorFaix := NX1->NX1_VFXFAT
				nRecVFaix  := NX1->(Recno())
			EndIf
		Else
			If NXC->NXC_VLHFV > nMaiorFaix
				nMaiorFaix := NXC->NXC_VLHFV
				nRecVFaix  := NXC->(Recno())
			EndIf
		EndIf
	EndIf

	//Valor de Tabeladao
	If nVLTFat > 0
		If oParams:GetTpExec() $ "1|2|6"
			If NX1->NX1_VTAB > nMaiorTab
				nMaiorTab := NX1->NX1_VTAB
				nRecVTab  := NX1->(Recno())
			EndIf
		Else
			If NXC->NXC_VLTAB > nMaiorTab
				nMaiorTab := NXC->NXC_VLTAB
				nRecVTab  := NXC->(Recno())
			EndIf
		EndIf
	EndIf

Next nRec

nDifTS    := nVTSFat - nSumVTSFat
nDifFX    := nTotFX  - nSumFixo
nDifFXvin := nFxVinc - nSumFxVin
nDifFaix  := nHonFxFat - nSumFaixa
nDifTab   := IIf(lPropLT, nVLTFat - nSumTabFat, 0)
nDiffDsFH := nX5DescH - nDiffDsFH

J201EAjust(oParams:GetTpExec(), nRecVTS, nDifTS, nRecVFx, nDifFX, nDifFXvin, nRecVFaix, nDifFaix, nRecVTab, nDifTab, cPreft, nNX5PDesc, nX5DescH, nDiffDsFH)

RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J201EGetCs
Verifica os casos validos para compor o total do contrato na pré-fatura / fatura.

@Param cPreft    Código da pré-fatura
@Param cFatura   Código da Fatura
@Param cEscr     Código do Escritório
@Param cCodAdic  Código da Fatura Adicional
@Param cContr    Código da Fatura Adicional
@Param nTotFX    Valor total de fixo que de fato está sendo faturado
@Param nFxVinc   Valor total de fixo vinculado ao contrato
@Param oParams   Objeto de parâmetros de emissão da pré/fatura
@Param lFaixa    .T. indica se o tipo de honorários do contrato é por faixa de faturamento

@Return Nil

@author Luciano Pereira dos Santos
@since  09/05/2017
/*/
//-------------------------------------------------------------------
Static Function J201EGetCs(cPreft, cFatura, cEscr, cCodAdic, cContr, nTotFX, nFxVinc, oParams, lFaixa)
Local aRet       := {}
Local aArea      := GetArea()
Local cQuery     := ""
Local cAlQry     := GetNextAlias()
Local nRec       := 0
Local aCasRec    := {}
Local aCasDel    := {}
Local lCasoAtiv  := .F.
Local lTemAtivo  := .F.
Local lFxAber    := JurGetDados("NT0", 1, xFilial("NT0") + cContr, "NT0_FXABM") == '1'   //Considera casos abertos no mês de referência
Local lFxEnce    := JurGetDados("NT0", 1, xFilial("NT0") + cContr, "NT0_FXENCM") == '1'  //Considera casos encerrados no mês de referência
Local aSqlRet    := {}
Local cDtIni     := ""
Local cDtFin     := ""
Local nPesoTot   := 0
Local nVlTSTot   := 0
Local nVlTBTot   := 0
Local cAliasTb   := ""

If nTotFX > 0 .Or. nFxVinc > 0

	//Verifica as referências das parcelas para tratar os encerramentos dos casos de contrato fixo
	cQuery :=   "SELECT NT1.NT1_CCONTR, "
	cQuery +=         " MIN(NT1.NT1_DATAIN) MINDATAIN, "
	cQuery +=         " MAX(NT1.NT1_DATAFI) MAXDATAFI "
	cQuery +=    " FROM " + RetSqlName("NT1") + " NT1 "
	cQuery +=   " INNER JOIN " + RetSqlName("NWE") + " NWE "
	cQuery +=      " ON NWE.NWE_FILIAL = '" + xFilial("NT1") + "' "
	cQuery +=     " AND NWE.NWE_CFIXO = NT1.NT1_SEQUEN "
	If oParams:GetTpExec() $ "1|2" // Emissão de pré / Reemissão de pré
		cQuery += " AND NWE.NWE_PRECNF = '" + cPreft + "'"
	Else
		cQuery += " AND NWE.NWE_CFATUR = '" + cFatura + "'"
		cQuery += " AND NWE.NWE_CESCR = '" + cEscr + "'"
	EndIf
	If oParams:GetTpExec() == "6" // Reemitir a pré de Fatura Cancelada
		cQuery += " AND NWE.NWE_CANC = '1' " // Nesse momento o faturamento da parcela já está cancelado
	Else
		cQuery += " AND NWE.NWE_CANC = '2' "
	EndIf
	cQuery +=     " AND NWE.D_E_L_E_T_ = ' ' "
	cQuery +=     " AND NT1.NT1_CCONTR = '" + cContr + "'"
	cQuery +=     " AND NT1.D_E_L_E_T_ = ' ' "
	cQuery +=   " GROUP BY NT1.NT1_CCONTR "

	aSqlRet := JurSQL(cQuery, {"MINDATAIN", "MAXDATAFI"} )
	If !Empty(aSqlRet)
		cDtIni := aSqlRet[1][1]
		cDtFin := aSqlRet[1][2]
	EndIf
EndIf

If oParams:GetTpExec() $ "1|2|6" // Emissão de pré / Reemissão de pré / Reemissão por Cancelamento

	// Seleciona os registros da NX1 relacionando com o cadastro de casos (NVE)
	cAliasTb := "NX1"
	cQuery := " SELECT "
	cQuery +=    " NX1.NX1_VTS VTS, "
	cQuery +=    " NX1.NX1_VTAB VTAB, "
	cQuery +=    " NX1.NX1_VDESP VDESP, "
	cQuery +=    " NVE.NVE_PESO PESO, "
	cQuery +=    " NVE.NVE_ENCHON ENCHON, "
	cQuery +=    " NVE.NVE_SITUAC SITUAC, "
	cQuery +=    " NVE.NVE_DTENCE DTENCE, "
	cQuery +=    " NVE.NVE_DTENTR DTENTR, "
	cQuery +=    " NX1.R_E_C_N_O_ RECNO, "
	cQuery +=    " CASE WHEN TS.NTS IS NULL THEN 0 ELSE TS.NTS END NTS, "
	cQuery +=    " CASE WHEN DESP.NDESP IS NULL THEN 0 ELSE DESP.NDESP END NDESP, "
	cQuery +=    " CASE WHEN TAB.NTAB IS NULL THEN 0 ELSE TAB.NTAB END NTAB "
	cQuery +=    " FROM "
	cQuery +=    " " + RetSqlName("NX1") + " NX1 "
	cQuery +=    " INNER JOIN " + RetSqlName("NVE") + " NVE  "
	cQuery +=          " ON NVE.NVE_FILIAL = '" + xFilial("NVE") + "' "
	cQuery +=          " AND NVE.NVE_CCLIEN = NX1.NX1_CCLIEN "
	cQuery +=          " AND NVE.NVE_LCLIEN = NX1.NX1_CLOJA "
	cQuery +=          " AND NVE.NVE_NUMCAS = NX1.NX1_CCASO "
	cQuery +=          " AND NVE.D_E_L_E_T_ = ' ' "

	cQuery += " LEFT OUTER JOIN ( "
	cQuery +=                    " SELECT NUE.NUE_FILIAL, NUE.NUE_CPREFT, NUE.NUE_CCLIEN, NUE.NUE_CLOJA, NUE.NUE_CCASO, COUNT(NUE.NUE_COD) NTS "
	cQuery +=                    " FROM " + RetSqlName("NUE") + " NUE "
	cQuery +=                    " WHERE NUE.NUE_FILIAL = '" + xFilial("NUE") + "' "
	cQuery +=                    " AND NUE.D_E_L_E_T_ = ' ' "
	cQuery +=                    " GROUP BY NUE.NUE_FILIAL, NUE.NUE_CPREFT, NUE.NUE_CCLIEN, NUE.NUE_CLOJA, NUE.NUE_CCASO "
	cQuery +=                   " ) TS ON TS.NUE_CCLIEN = NX1.NX1_CCLIEN "
	cQuery +=                    " AND TS.NUE_CLOJA = NX1.NX1_CLOJA "
	cQuery +=                    " AND TS.NUE_CCASO = NX1.NX1_CCASO "
	cQuery +=                    " AND TS.NUE_CPREFT = NX1.NX1_CPREFT "
	cQuery += " LEFT OUTER JOIN ( "
	cQuery +=                    " SELECT NVY.NVY_FILIAL, NVY.NVY_CPREFT, NVY.NVY_CCLIEN, NVY.NVY_CLOJA, NVY.NVY_CCASO, COUNT(NVY.NVY_COD) NDESP "
	cQuery +=                     " FROM " + RetSqlName("NVY") + " NVY "
	cQuery +=                     " WHERE NVY.NVY_FILIAL = '" + xFilial("NVY") + "' "
	cQuery +=                     " AND NVY.D_E_L_E_T_ = ' ' "
	cQuery +=                    " GROUP BY NVY.NVY_FILIAL, NVY.NVY_CPREFT, NVY.NVY_CCLIEN, NVY.NVY_CLOJA, NVY.NVY_CCASO "
	cQuery +=                    " ) DESP ON DESP.NVY_CCLIEN = NX1.NX1_CCLIEN "
	cQuery +=                     " AND DESP.NVY_CLOJA = NX1.NX1_CLOJA "
	cQuery +=                     " AND DESP.NVY_CCASO = NX1.NX1_CCASO "
	cQuery +=                     " AND DESP.NVY_CPREFT = NX1.NX1_CPREFT "
	cQuery += " LEFT OUTER JOIN ( "
	cQuery +=                     " SELECT NV4.NV4_FILIAL, NV4.NV4_CPREFT, NV4.NV4_CCLIEN, NV4.NV4_CLOJA, NV4.NV4_CCASO, COUNT(NV4.NV4_COD) NTAB "
	cQuery +=                     " FROM " + RetSqlName("NV4") + " NV4 "
	cQuery +=                     " WHERE NV4.NV4_FILIAL = '" + xFilial("NV4") + "' "
	cQuery +=                     " AND NV4.D_E_L_E_T_ = ' ' "
	cQuery +=                     " GROUP BY NV4.NV4_FILIAL, NV4.NV4_CPREFT, NV4.NV4_CCLIEN, NV4.NV4_CLOJA, NV4.NV4_CCASO "
	cQuery +=                   " ) TAB ON TAB.NV4_CCLIEN = NX1.NX1_CCLIEN   "
	cQuery +=                    " AND TAB.NV4_CLOJA = NX1.NX1_CLOJA "
	cQuery +=                    " AND TAB.NV4_CCASO = NX1.NX1_CCASO "
	cQuery +=                    " AND TAB.NV4_CPREFT = NX1.NX1_CPREFT "

	cQuery += " WHERE "
	cQuery += " NX1.NX1_FILIAL = '" + xFilial("NX1") + "'"
	cQuery += " AND NX1.NX1_CCONTR = '" + cContr + "'"
	cQuery += " AND NX1.NX1_CPREFT = '" + cPreft + "'"
	cQuery += " AND NX1.D_E_L_E_T_ = ' '"

Else //Emissão de minuta de pré / minuta de fatura / fatura

	// Seleciona os registros da NXC relacionando com o cadastro de casos (NVE)
	cAliasTb := "NXC"
	cQuery := " SELECT "
	cQuery += " NXC.NXC_VLTS VTS,"
	cQuery += " NXC.NXC_VLTAB VTAB,"
	cQuery += " NXC.NXC_VLDESP VDESP,"
	cQuery += " NVE.NVE_PESO PESO,"
	cQuery += " NVE.NVE_ENCHON ENCHON, "
	cQuery += " NVE.NVE_SITUAC SITUAC, "
	cQuery += " NVE.NVE_DTENCE DTENCE, "
	cQuery += " NVE.NVE_DTENTR DTENTR, "
	cQuery += " NXC.R_E_C_N_O_ RECNO, "
	cQuery += " CASE WHEN TS.NTS IS NULL THEN 0 ELSE TS.NTS END NTS, "
	cQuery += " CASE WHEN DESP.NDESP IS NULL THEN 0 ELSE DESP.NDESP END NDESP, "
	cQuery += " CASE WHEN TAB.NTAB IS NULL THEN 0 ELSE TAB.NTAB END NTAB "
	cQuery += " FROM"
	cQuery += " " + RetSqlName("NXC") + " NXC  "
	cQuery += " INNER JOIN " + RetSqlName("NVE") + " NVE "
	cQuery +=               " ON  NVE.NVE_FILIAL = '" + xFilial("NVE") + "'"
	cQuery +=              " AND NVE.NVE_CCLIEN = NXC.NXC_CCLIEN"
	cQuery +=              " AND NVE.NVE_LCLIEN = NXC.NXC_CLOJA"
	cQuery +=              " AND NVE.NVE_NUMCAS = NXC.NXC_CCASO"
	cQuery +=              " AND NVE.D_E_L_E_T_ = ' ' "
	cQuery +=  " LEFT OUTER JOIN ( "
	cQuery +=                      " SELECT NUE.NUE_FILIAL, NW0.NW0_CFATUR, NW0_CESCR, NUE.NUE_CCLIEN, NUE.NUE_CLOJA, NUE.NUE_CCASO, COUNT(NUE.NUE_COD) NTS  "
	cQuery +=                       " FROM " + RetSqlName("NUE") + " NUE  "
	cQuery +=                      " INNER JOIN " + RetSqlName("NW0") + " NW0  "
	cQuery +=                                  " ON NUE.NUE_FILIAL = '" + xFilial("NUE") + "' "
	cQuery +=                                  " AND NUE.NUE_COD = NW0.NW0_CTS "
	cQuery +=                                  " AND NUE.D_E_L_E_T_ = ' ' "
	cQuery +=                                " WHERE NW0.NW0_FILIAL = '" + xFilial("NW0") + "' "
	cQuery +=                                  " AND NW0.NW0_CANC = '2' "
	cQuery +=                                  " AND NW0.D_E_L_E_T_ = ' ' "
	cQuery +=                                " GROUP BY NUE.NUE_FILIAL, NW0.NW0_CFATUR, NW0_CESCR, NUE.NUE_CCLIEN, NUE.NUE_CLOJA, NUE.NUE_CCASO "
	cQuery +=                   " ) TS ON TS.NUE_CCLIEN = NXC.NXC_CCLIEN "
	cQuery +=                       " AND TS.NUE_CLOJA = NXC.NXC_CLOJA "
	cQuery +=                       " AND TS.NUE_CCASO = NXC.NXC_CCASO "
	cQuery +=                       " AND TS.NW0_CESCR = NXC.NXC_CESCR "
	cQuery +=                       " AND TS.NW0_CFATUR = NXC.NXC_CFATUR "
	cQuery +=  " LEFT OUTER JOIN ( "
	cQuery +=                     " SELECT	NVY.NVY_FILIAL, NVZ.NVZ_CFATUR, NVZ_CESCR, NVY.NVY_CCLIEN, NVY.NVY_CLOJA, NVY.NVY_CCASO, COUNT(NVY.NVY_COD) NDESP "
	cQuery +=                     " FROM " + RetSqlName("NVY") + " NVY "
	cQuery +=                     " INNER JOIN " + RetSqlName("NVZ") + " NVZ  "
	cQuery +=                                  " ON NVY.NVY_FILIAL = '" + xFilial("NVY") + "' "
	cQuery +=                                 " AND NVY.NVY_COD = NVZ.NVZ_CDESP "
	cQuery +=                                 " AND NVY.D_E_L_E_T_ = ' ' "
	cQuery +=                    " WHERE NVZ.NVZ_FILIAL = '" + xFilial("NVZ") + "' "
	cQuery +=                      " AND NVZ.NVZ_CANC = '2' "
	cQuery +=                      " AND NVZ.D_E_L_E_T_ = ' ' "
	cQuery +=                    " GROUP BY NVY.NVY_FILIAL, NVZ.NVZ_CFATUR, NVZ_CESCR, NVY.NVY_CCLIEN, NVY.NVY_CLOJA, NVY.NVY_CCASO "
	cQuery +=                  " ) DESP ON DESP.NVY_CCLIEN = NXC.NXC_CCLIEN "
	cQuery +=                        " AND DESP.NVY_CLOJA = NXC.NXC_CLOJA "
	cQuery +=                        " AND DESP.NVY_CCASO = NXC.NXC_CCASO "
	cQuery +=                        " AND DESP.NVZ_CESCR = NXC.NXC_CESCR "
	cQuery +=                        " AND DESP.NVZ_CFATUR = NXC.NXC_CFATUR "
	cQuery +=  " LEFT OUTER JOIN ( "
	cQuery +=                      " SELECT NV4.NV4_FILIAL, NW4.NW4_CFATUR, NW4_CESCR, NV4.NV4_CCLIEN, NV4.NV4_CLOJA, NV4.NV4_CCASO, COUNT(NV4.NV4_COD) NTAB  "
	cQuery +=                        " FROM " + RetSqlName("NV4") + " NV4  "
	cQuery +=                      " INNER JOIN " + RetSqlName("NW4") + " NW4  "
	cQuery +=                                  " ON NV4.NV4_FILIAL = '" + xFilial("NV4") + "' "
	cQuery +=                                 " AND NV4.NV4_COD = NW4.NW4_CLTAB "
	cQuery +=                                 " AND NV4.D_E_L_E_T_ = ' ' "
	cQuery +=                      " WHERE NW4.NW4_FILIAL = '" + xFilial("NW4") + "' "
	cQuery +=                        " AND NW4.NW4_CANC = '2' "
	cQuery +=                        " AND NW4.D_E_L_E_T_ = ' ' "
	cQuery +=                      " GROUP BY NV4.NV4_FILIAL, NW4.NW4_CFATUR, NW4_CESCR, NV4.NV4_CCLIEN, NV4.NV4_CLOJA, NV4.NV4_CCASO "
	cQuery +=                  " ) TAB ON TAB.NV4_CCLIEN = NXC.NXC_CCLIEN "
	cQuery +=                       " AND TAB.NV4_CLOJA = NXC.NXC_CLOJA "
	cQuery +=                       " AND TAB.NV4_CCASO = NXC.NXC_CCASO "
	cQuery +=                       " AND TAB.NW4_CESCR = NXC.NXC_CESCR "
	cQuery +=                       " AND TAB.NW4_CFATUR = NXC.NXC_CFATUR "
	cQuery +=  " WHERE"
	cQuery +=     " NXC.NXC_FILIAL = '" + xFilial("NXC") + "'"
	cQuery +=     " AND NXC.NXC_CCONTR = '" + cContr + "'"
	cQuery +=     " AND NXC.NXC_CFATUR = '" + cFatura + "'"
	cQuery +=     " AND NXC.NXC_CESCR  = '" + cEscr + "'"
	cQuery +=     " AND NXC.D_E_L_E_T_ = ' '"

EndIf

cQuery := ChangeQuery(cQuery, .F.)

DbCommitAll() //Para efetivar a alteração no banco de dados (não impacta no rollback da transação)
dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cAlQry, .T., .F. )

// Gera o array aNXCRecs
While !(cAlQry)->(Eof())

	If !Empty(cDtIni) .AND. !Empty(cDtFin)

		If (cAlQry)->ENCHON == "1"
			lCasoAtiv := .F.
		Else
			//Quando se tratar de Faixa de Faturamento - Quantidade de Casos, deverá verificar o conteúdo dos campos Casos Enc e Casos Abert
			//para vincular ou não casos de acordo com sua abertura / encerramento e verificar se o caso não está com encerramento de honorários
			If !lFaixa
				lCasoAtiv := ((cAlQry)->SITUAC == "1" .AND. (cAlQry)->DTENTR <= cDtFin ) .OR. ;
							((cAlQry)->SITUAC == "2" .AND. (cAlQry)->DTENCE >= cDtIni .AND. (cAlQry)->DTENTR  <= cDtFin )
			Else

				If (cAlQry)->SITUAC == "1" //Andamento
					If lFxAber
						lCasoAtiv := (cAlQry)->DTENTR <= cDtFin
					Else
						lCasoAtiv := (cAlQry)->DTENTR < cDtIni
					EndIf
				Else   //Encerrado
					If lFxAber
						If lFxEnce
							lCasoAtiv := (cAlQry)->DTENTR <= cDtFin .AND. (cAlQry)->DTENCE >= cDtIni
						Else
							lCasoAtiv := (cAlQry)->DTENTR <= cDtFin .AND. (cAlQry)->DTENCE > cDtFin
						EndIf
					Else
						If lFxEnce
							lCasoAtiv := (cAlQry)->DTENTR < cDtIni .AND. (cAlQry)->DTENCE >= cDtIni
						Else
							lCasoAtiv := (cAlQry)->DTENTR < cDtIni .AND. (cAlQry)->DTENCE > cDtFin
						EndIf
					EndIf

				EndIf

			EndIf

		EndIf

	Else
		lCasoAtiv := .T.
	EndIf

	If lCasoAtiv // Verifica se há algum caso ativo
		nVlTSTot += (cAlQry)->VTS
		nVlTBTot += (cAlQry)->VTAB
		nPesoTot += (cAlQry)->PESO

		AAdd(aCasRec, {(cAlQry)->VTS, (cAlQry)->VTAB, (cAlQry)->PESO, (cAlQry)->RECNO, (cAlQry)->NTS , (cAlQry)->NDESP , (cAlQry)->NTAB , (cAlQry)->VDESP} )
	Else
		AAdd(aCasDel, {(cAlQry)->VTS, (cAlQry)->VTAB, (cAlQry)->PESO, (cAlQry)->RECNO, (cAlQry)->NTS , (cAlQry)->NDESP , (cAlQry)->NTAB , (cAlQry)->VDESP} )
	EndIf

	lTemAtivo := lTemAtivo .OR. lCasoAtiv

	(cAlQry)->(DbSkip())

EndDo

(cAlQry)->(DbCloseArea())

If lTemAtivo
	For nRec := 1 To Len( aCasDel )
		If  aCasDel[nRec][5] == 0 .And. aCasDel[nRec][6] == 0 .And. aCasDel[nRec][7] == 0 // 1- NTS / 2 - NDES / 5 -NTAB
			(cAliasTb)->( DbGoto( aCasDel[nRec][4] ) ) //RECNO
			RecLock(cAliasTb,.F.)
			(cAliasTb)->(DbDelete())
			(cAliasTb)->(MsUnlock())
			(cAliasTb)->(DbCommit())
		EndIf
	Next nRec
Else
	aCasRec := aClone( aCasDel )
EndIf

aRet := {aCasRec, {nVlTSTot, nVlTBTot, nPesoTot, lTemAtivo}}

RestArea(aArea)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J201EAjust()
Efetua os ajustes de arredondamento dos valores de TimeSheet, Fixo e tabelado nos casos
da pré-fatura/fatura.

@Param cTpExec    Tipo de execução de pré-fatura / fatura
@Param nRecVTS    Recno do Caso do contrato da (pré-)fatura com maior valor de TS
@Param nDifTS     Diferença entre o valor total de TS e a soma da divisão entre os casos
@Param nRecVFx    Recno do Caso do contrato da (pré-)fatura com maior valor de FX
@Param nDifFX     Diferença entre o valor total de FX e a soma da divisão entre os casos
@Param nDifFXVin  Diferença entre o valor total de FX vinculado e a soma da divisão entre os casos
@Param nRecVFaix  Recno do Caso na (pré-)fatura de maior valor
@Param nDifFaix   Diferença entre o valor total da Faixa de valor e a soma da divisão entre os casos
@Param nRecVTab   Recno do Caso na (pré-)fatura de maior valor
@Param nDifTab    Diferença entre o valor total de LT e a soma da divisão entre os casos
@Param cPreft     Código da Pré-Fatura
@Param nNX5PDesc  Percentual de Desconto
@Param nX5DescH   Desconto em Valor
@Param nDiffDsFH  Diferença entre o valor total de desconto e a soma da divisão entre os casos

@Return Nil

@author Luciano Pereira dos Santos
@since 05/05/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J201EAjust(cTpExec, nRecVTS, nDifTS, nRecVFx, nDifFX, nDifFXVin, nRecVFaix, nDifFaix, nRecVTab, nDifTab, cPreft, nNX5PDesc, nX5DescH, nDiffDsFH)
Local aArea       := GetArea()
Local nValDscH    := 0

Default cTpExec   := ""
Default nRecVTS   := 0
Default nDifTS    := 0
Default nRecVFx   := 0
Default nDifFX    := 0
Default nDifFXvin := 0
Default nRecVFaix := 0
Default nDifFaix  := 0
Default nRecVTab  := 0
Default nDifTab   := 0
Default cPreft    := 0
Default nNX5PDesc := 0
Default nX5DescH  := 0
Default nDiffDsFH := 0

//Ajuste de arredondamento de TimeSheet
If nDifTS != 0 .And. nRecVTS > 0
	If cTpExec $ "1|2|6" // Emissão de pré / Reemissão de pré / Reemissão por Cancelamento
		NX1->( DbGoto(nRecVTS) )
		RecLock("NX1", .F.)
		NX1->NX1_VTS  := NX1->NX1_VTS  + nDifTS
		NX1->NX1_VHON := NX1->NX1_VHON + nDifTS
		NX1->(MsUnlock())
		NX1->(DbCommit())
	ElseIf cTpExec $ "3|4|5|MS"
		NXC->( DbGoto(nRecVTS) )
		RecLock("NXC", .F.)
		NXC->NXC_VLTS   := NXC->NXC_VLTS   + nDifTS
		NXC->NXC_VLHFAT := NXC->NXC_VLHFAT + nDifTS
		NXC->(MsUnlock())
		NXC->(DbCommit())
	EndIf
EndIf

//Ajuste de arredondamento de fixo
If nRecVFx > 0 .And. (nDifFX != 0 .Or. nDifFXvin != 0)  
	If cTpExec $ "1|2|6"
		NX1->( DbGoto(nRecVFx) )
		RecLock("NX1", .F.)
		If NX1->(ColumnPos('NX1_VFIXO')) > 0 //Proteção
			NX1->NX1_VFIXO  := NX1->NX1_VFIXO  + nDifFX
		EndIf
		NX1->NX1_VHON   := NX1->NX1_VHON   + nDifFX
		If NX1->(ColumnPos('NX1_VFXVIN')) > 0 //Proteção
			NX1->NX1_VFXVIN := NX1->NX1_VFXVIN + nDifFxVin
		EndIf
		NX1->(MsUnlock())
		NX1->(DbCommit())
	ElseIf cTpExec $ "3|4|5|MS"
		NXC->( DbGoto(nRecVFx) )
		RecLock("NXC", .F.)
		NXC->NXC_VFIXO  := NXC->NXC_VFIXO  + nDifFX
		NXC->NXC_VLHFAT := NXC->NXC_VLHFAT + nDifFX

		If Empty(cPreft) .AND. nNX5PDesc > 0
			nValDscH := Round((nDifFX * nNX5PDesc  / 100.00), TamSX3('NXC_DRATE')[2])	
			NXC->NXC_DRATE += nValDscH
			NXC->NXC_DRATF += nValDscH	
			nDiffDsFH -= nValDscH
		EndIf
		If NXC->(ColumnPos('NXC_VFXVIN')) > 0 //Proteção
			NXC->NXC_VFXVIN := NXC->NXC_VFXVIN + nDifFxVin
		EndIf

		NXC->(MsUnlock())
		NXC->(DbCommit())
	EndIf
EndIf

//Ajuste de arredondamento do desconto de fixo
If nRecVFx > 0  .AND.  Empty(cPreft) .AND. nNX5PDesc > 0 .AND. nDiffDsFH != 0  .and. cTpExec $ "3|4|5|MS"
	NXC->( DbGoto(nRecVFx) )
	RecLock("NXC", .F.)
	If nDiffDsFH != 0 //Ajuste do valor total do desconto
		NXC->NXC_DRATE += nDiffDsFH
		NXC->NXC_DRATF += nDiffDsFH	
	EndIf 
	NXC->(MsUnlock())
	NXC->(DbCommit())
EndIf

//Ajuste de arredondamento de Faixa de Valor
If nDifFaix != 0 .And. nRecVFaix > 0
	If cTpExec $ "1|2|6"
		NX1->( DbGoto(nRecVFaix) )
		RecLock("NX1", .F.)
		NX1->NX1_VFXFAT := NX1->NX1_VFXFAT + nDifFaix
		NX1->(MsUnlock())
		NX1->(DbCommit())
	ElseIf cTpExec $ "3|4|5|MS"
		NXC->( DbGoto(nRecVFaix) )
		RecLock("NXC", .F.)
		NXC->NXC_VLHFV  := NXC->NXC_VLHFV + nDifFaix
		NXC->(MsUnlock())
		NXC->(DbCommit())
	EndIf
EndIf

//Ajuste de arredondamento de Tabelado
If nDifTab != 0 .And. nRecVTab > 0
	If cTpExec $ "1|2|6"
		NX1->( DbGoto(nRecVTab) )
		RecLock("NX1", .F.)
		NX1->NX1_VTAB  := NX1->NX1_VTAB  + nDifTab
		NX1->(MsUnlock())
		NX1->(DbCommit())
	ElseIf cTpExec $ "3|4|5|MS"
		NXC->( DbGoto(nRecVTab) )
		RecLock("NXC", .F.)
		NXC->NXC_VLTAB := NXC->NXC_VLTAB + nDifTab
		NXC->(MsUnlock())
		NXC->(DbCommit())
	EndIf
EndIf

RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J201EGrvRv
Função para fazer a carga dos múltiplos sócios / revisores cadastrados
no Caso, no momento da emissão da pré-fatura.
Regra para carga descrita abaixo:

                                              Ambos	 Honorários	 Despesas
Caso na pré-fatura somente com Honorários	   Sim	    Sim	      Não
Caso na pré-fatura somente com Despesas	       Sim	    Não	      Sim
Caso na pré-fatura com honorários e Despesas   Sim	    Sim	      Não

@Param cCodPre    Código da Pré-fatura
@Param cCodContr  Código do COntrato
@Param lLoopNX1   Define se executa para todos os casos da pré-fatura

@Return Nil

@author Cristina Cintra
@since 24/08/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J201EGrvRv(cCodPre, cCodContr, lLoopNX1)
Local aArea      := GetArea()
Local aAreaNX1   := {}
Local aAreaNX8   := {}
Local aAreaOHN   := {}
Local cVarPreft  := ""
Local lContrOHN  := .F.
Local cVarContr  := ""
Local cKeyOHN    := ""
Local lHon       := .F.
Local lDesp      := .F.
Local nLnOHN     := 0
Local nI         := 0
Local aOHN       := {}
Local lMultRevis := ( SuperGetMV("MV_JMULTRV",, .F.) .And. (SuperGetMV("MV_JREVILD",, '2') == '1') .And. FWAliasInDic("OHN") ) // Indica se é utilizado o conceito de múltiplos revisores e a revisão de pré-fatura do LD. 
Local cKeyNX1    := ""
Local cSql 		 := ""
Local aSql		 := {}
Local lIndContr	 := .F.

Default cCodPre   := ""
Default cCodContr := ""
Default lLoopNX1  := .T.

If lMultRevis
	aAreaNX1  := NX1->(GetArea())
	aAreaNX8  := NX8->(GetArea())
	aAreaOHN  := OHN->(GetArea())
	cVarPreft := CriaVar('NX0_COD', .F.)
	lContrOHN := OHN->(ColumnPos("OHN_CCONTR")) > 0 // Proteção
	
	NX1->(DbSetOrder(3)) // NX1_FILIAL+NX1_CPREFT+NX1_CCONTR
	OHN->(DbSetOrder(1)) // OHN_FILIAL+OHN_CPREFT+[OHN_CCONTR]+OHN_CCLIEN+OHN_CLOJA+OHN_CCASO ## OHN_FILIAL+OHN_CPREFT+OHN_CCONTR+OHN_CCLIEN+OHN_CLOJA+OHN_CCASO
	
	cVarContr := IIF(lContrOHN, CriaVar('OHN_CCONTR', .F.), "")
	lIndContr := lContrOHN .AND. ("OHN_CCONTR" $  RTrim(OHN->(IndexKey())))

	If lLoopNX1
		cKeyNX1 := xFilial('NX1') + cCodPre + cCodContr
	Else
		cKeyNX1 := xFilial('NX1') + cCodPre + cCodContr + NX1->NX1_CCLIEN + NX1->NX1_CLOJA + NX1->NX1_CCASO
	EndIf

	If NX1->(DbSeek( cKeyNX1 ) )
		While (lLoopNX1 .And. NX1->(NX1_FILIAL + NX1_CPREFT + NX1_CCONTR) == xFilial('NX1') + cCodPre + cCodContr) .Or. ;
		      (!lLoopNX1 .And. NX1->(NX1_FILIAL + NX1_CPREFT + NX1_CCONTR + NX1->NX1_CCLIEN + NX1->NX1_CLOJA + NX1->NX1_CCASO) == cKeyNX1 )
			
			lHon    := NX1->NX1_VHON > 0 .Or. NX1->NX1_VFXVIN > 0 .Or. NX1->NX1_TS == "1" .Or. NX1->NX1_LANTAB == "1"
			lDesp   := NX1->NX1_DESP == "1" .Or. NX1->NX1_VDESP > 0
			cKeyOHN := xFilial('OHN') + cVarPreft + IIF(lIndContr, cVarContr, "") + NX1->NX1_CCLIEN + NX1->NX1_CLOJA + NX1->NX1_CCASO // Utiliza o contrato na chave

			If OHN->(DbSeek( cKeyOHN ) ) 
				While OHN->(!Eof()) .And. OHN->OHN_FILIAL == xFilial('OHN') .And.  OHN->OHN_CPREFT == cVarPreft .And. ;
					(!lIndContr .OR. OHN->OHN_CCONTR == cVarContr ) .And. OHN->OHN_CCLIEN == NX1->NX1_CCLIEN .And. ;
					OHN->OHN_CLOJA == NX1->NX1_CLOJA .And. OHN->OHN_CCASO == NX1->NX1_CCASO
					
					If (!lContrOHN  .Or. OHN->OHN_CCONTR == cVarContr) .And. ;
						(( lHon .And. OHN->OHN_REVISA != "2" ) .Or. ;
						 ( lDesp .And. !lHon .And. OHN->OHN_REVISA != "1"))
					
						aAdd(aOHN, {OHN->OHN_CCLIEN, OHN->OHN_CLOJA, OHN->OHN_CCASO, OHN->OHN_TIPO, OHN->OHN_CPART, OHN->OHN_ORDEM, OHN->OHN_REVISA} )
					EndIf
					
					OHN->(DbSkip())
				EndDo
			EndIf
			
			NX1->(DbSkip())
		EndDo
	EndIf

	If ( nLnOHN := Len(aOHN) ) > 0

		For nI := 1 To nLnOHN
			//Verifica se não exitem mais de um contato/caso  vinculado a fatura
			cSql := " SELECT COUNT(1) AS CONTA "
			cSql += " FROM " + RetSqlName("OHN") + " OHN "
			cSql += " WHERE "
			cSql += " OHN.OHN_FILIAL = '" +xFilial('OHN')  + "'"
			cSql += " AND OHN.OHN_CPREFT = '" + cCodPre +  "'"
			cSql += " AND OHN.OHN_CCLIEN = '" + aOHN[nI][1] +  "'"
			cSql += " AND OHN.OHN_CLOJA = '" + aOHN[nI][2] +  "'"
			cSql += " AND OHN.OHN_CCASO = '" + aOHN[nI][3] +  "'"
			cSql += " AND OHN.OHN_CPART = '" + aOHN[nI][5] +  "'"
			cSql += " AND OHN.OHN_REVISA = '" + aOHN[nI][7] +  "'"

			If ("OHN_CCONTR" $ FWX2Unico( 'OHN')) // Proteção
				cSql += " AND OHN_CCONTR = '" + cCodContr +  "'"
			EndIf	

			aSQL := JurSQL(cSQL, {"CONTA"})

			If Len(aSql) = 0 .Or. aSql[01,01] = 0
				RecLock('OHN', .T.)
				OHN->OHN_FILIAL := xFilial('OHN')
				OHN->OHN_CPREFT := cCodPre
				OHN->OHN_CCLIEN := aOHN[nI][1]
				OHN->OHN_CLOJA  := aOHN[nI][2]
				OHN->OHN_CCASO  := aOHN[nI][3]
				OHN->OHN_TIPO   := aOHN[nI][4]
				OHN->OHN_CPART  := aOHN[nI][5]
				OHN->OHN_ORDEM  := aOHN[nI][6]
				OHN->OHN_REVISA := aOHN[nI][7]
				If lContrOHN // Proteção
					OHN->OHN_CCONTR := cCodContr
				EndIf
				OHN->(MsUnLock())
				OHN->(DbCommit())
			EndIf
		Next nI
	EndIf

	RestArea( aAreaOHN )
	RestArea( aAreaNX1 )
	RestArea( aAreaNX8 )
EndIf

RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J201EDelRv
Remove vínculo de sócios/revisores ao remover o caso da Pré-Fatura

@Param cCodPre  , Código da Pré-fatura
@Param cCodContr, Código do Contrato
@Param cCliente , Código do cliente
@Param cLoja    , Código do loja
@Param cCaso    , Código do caso

@Return Nil

@author  Jonatas Martins / Bruno Ritter
@since   24/08/2018
/*/
//-------------------------------------------------------------------
Function J201EDelRv(cCodPre, cCodContr, cCliente, cLoja, cCaso)
	Local aArea       := GetArea()
	Local aAreaOHN    := {}
	Local lMultRevis  := ( SuperGetMV("MV_JMULTRV",, .F.) .And. (SuperGetMV("MV_JREVILD",, '2') == '1') .And. FWAliasInDic("OHN") ) // Indica se é utilizado o conceito de múltiplos revisores e a revisão de pré-fatura do LD. 
	Local lContrOHN   := .F.

	Default cCodPre   := ""
	Default cCodContr := ""
	Default cCliente  := ""
	Default cLoja     := ""
	Default cCaso     := ""

	If lMultRevis
		aAreaOHN  := OHN->(GetArea())
		lContrOHN := OHN->(ColumnPos("OHN_CCONTR")) > 0 // Proteção
		cCodContr := IIF(lContrOHN, cCodContr, "")

		OHN->(DbSetOrder(1)) // OHN_FILIAL+OHN_CPREFT+OHN_CCLIEN+OHN_CLOJA+OHN_CCASO ## OHN_FILIAL+OHN_CPREFT+OHN_CCONTR+OHN_CCLIEN+OHN_CLOJA+OHN_CCASO 
		If OHN->(DbSeek(xFilial("OHN") + cCodPre + cCodContr + cCliente + cLoja + cCaso))
			While OHN->(!Eof()) .And. OHN->OHN_FILIAL == xFilial('OHN') .And.  OHN->OHN_CPREFT == cCodPre .And. IIF(lContrOHN, OHN->OHN_CCONTR == cCodContr, .T.) .And. ;
				OHN->OHN_CCLIEN == cCliente .And. OHN->OHN_CLOJA == cLoja .And. OHN->OHN_CCASO == cCaso

				RecLock("OHN", .F.)
				OHN->(DbDelete())
				OHN->(MsUnLock())
				OHN->(DbSkip())
			EndDo
		EndIf

		RestArea( aAreaOHN )
	EndIf

	RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J201EApuTS()
Rotina para apuração do valor total de Time Sheets pendentes ou em minuta
quanto aos casos do contrato da pré-fatura.

@Params	cTipo   Indica o tipo de cálculo, se será dos lançamentos em 
                Minuta ("M") ou Pendentes ("P")
@Params	cContr  Indica o código do Contrato  
@Params	cMoeda  Moeda da pré-fatura para avaliar conversão de lançamento 
@Params dData   Data da emissão da pré-fatura para conversão de lançamento 
@Params cCodPre Código da pré-fatura

@Return	nValor	Valor calculado.

@author Cristina Cintra / Jorge Martins
@since 25/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J201EApuTS(cTipo, cContr, cMoeda, dData, cCodPre)
Local aArea     := GetArea()
Local cQuery    := ""
Local nValor    := 0
Local cQryRes   := Nil

Default cTipo   := ""
Default cContr  := ""
Default cMoeda  := ""
Default dData   := Date()
Default cCodPre := ""

If !Empty(cTipo) .And. !Empty(cContr) .And. !Empty(cMoeda)

	cQuery := " SELECT SUM(NUE.NUE_VALOR) VALOR, NUE.NUE_CMOEDA CMOEDA "
	cQuery +=   " FROM " + RetSqlName("NUE") + " NUE "
	If cTipo == "M" // Minuta
		cQuery +=    " INNER JOIN " + RetSqlName("NX0") + " NX0 "
		cQuery +=       " ON ( NX0.NX0_FILIAL = '" + xFilial("NX0") + "' AND "
		cQuery +=            " NX0.NX0_COD = NUE.NUE_CPREFT AND "
		cQuery +=            " NX0.NX0_SITUAC IN ('5','6') AND " // Emitir Minuta | Minuta Emitida
		cQuery +=            " NX0.D_E_L_E_T_ = ' ') "
	EndIf
	cQuery +=        " INNER JOIN " + RetSqlName("NRC") + " NRC "
	cQuery +=           " ON ( NRC.NRC_FILIAL = '" + xFilial("NRC") + "' AND "
	cQuery +=                " NRC.NRC_COD    = NUE.NUE_CATIVI AND "
	cQuery +=                " NRC.NRC_TEMPOZ = '1' AND "
	cQuery +=                " NRC.D_E_L_E_T_ = ' ' ) "
	cQuery +=        " INNER JOIN " + RetSqlName("NUT") + " NUT "
	cQuery +=           " ON ( NUT.NUT_FILIAL = '" + xFilial("NUT") + "' AND "
	cQuery +=                " NUT.NUT_CCONTR = '" + cContr + "' AND "
	cQuery +=                " NUT.NUT_CCLIEN = NUE.NUE_CCLIEN AND "
	cQuery +=                " NUT.NUT_CLOJA  = NUE.NUE_CLOJA AND "
	cQuery +=                " NUT.NUT_CCASO  = NUE.NUE_CCASO AND "
	cQuery +=                " NUT.D_E_L_E_T_ = ' ' ) "
	cQuery +=  " WHERE NUE.NUE_FILIAL = '" + xFilial("NUE") + "' "
	cQuery +=    " AND NUE.NUE_SITUAC = '1' "
	cQuery +=    " AND NUE.NUE_COBRAR = '1' "
	cQuery +=    " AND NUE.NUE_CLTAB  = ' ' "
	If cTipo == "P" .And. !Empty(cCodPre) // Pendentes
		cQuery +=" AND NUE.NUE_CPREFT <> '" + cCodPre + "' "
	EndIf
	cQuery +=    " AND NOT EXISTS ( SELECT NTJ.R_E_C_N_O_ "
	cQuery +=                       " FROM " + RetSqlName("NTJ") + " NTJ "
	cQuery +=                      " WHERE NTJ.NTJ_FILIAL = '" + xFilial("NTJ") + "' "
	cQuery +=                        " AND NTJ.NTJ_CTPATV = NUE.NUE_CATIVI "
	cQuery +=                        " AND NTJ.NTJ_CCONTR = '" + cContr + "' "
	cQuery +=                        " AND NTJ.D_E_L_E_T_ = ' ') "
	cQuery +=    " AND NUE.D_E_L_E_T_ = ' ' "
	cQuery +=  " GROUP BY NUE.NUE_CMOEDA "

	cQryRes := GetNextAlias()
	cQuery  := ChangeQuery(cQuery, .F.)
	dbUseArea( .T., 'TOPCONN', TcGenQry( ,, cQuery ), cQryRes, .T., .F. )

	While !(cQryRes)->(EOF())
		If (cQryRes)->CMOEDA != cMoeda
			nValor := nValor + JA201FConv(cMoeda, (cQryRes)->CMOEDA, (cQryRes)->VALOR, "1", dData)[1]
		Else
			nValor := nValor + (cQryRes)->VALOR
		EndIf
		(cQryRes)->(DbSkip())
	EndDo
	(cQryRes)->(DbCloseArea())

EndIf

RestArea(aArea)

Return nValor

//-------------------------------------------------------------------
/*/{Protheus.doc} J201EAjDesc()
Ajusta o valor de Desconto Linear e Especial nos Casos e no Contrato 
quando houver limite ou excedente - valor de TS diferente do vinculado.

@Param  oParams    Objeto de parâmetros de emissão da pré/fatura
@Param  cPreft     Código da Pré-fatura
@Param  cContr     Código do Contrato
@Param  cEscr      Código do Escritório
@Param  cFatura    Código da Fatura
@Param  nVDESCO    Valor do desconto linear
@Param  nVLDESC    Valor do desconto especial

@author Cristina Cintra / Abner Fogaça
@since 24/10/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J201EAjDesc(oParams, cPreft, cContr, cEscr, cFatura, nVDESCO, nVLDESC)
Local aArea       := GetArea()
Local cTpDescEsp  := "" 
Local nVDescCas   := 0 // Valor de Desc Linear
Local nPDescEsp   := 0 // % Desc Especial
Local nvDescEsp   := 0 // Valor de Desc Especial
Local nDesLinTot  := 0 // Desc Linear Total
Local nDesEspTot  := 0 // Desc Especial Total

If oParams:GetTpExec() $ "1|2|6" // Emissão de pré / Reemissão de pré / Reemissão por Cancelamento 
	cTpDescEsp := JurGetDados("NX0", 1, xFilial("NX0") + cPreft, "NX0_TPDESC") //Tipo de Desconto na Pré-fatura (1=Valor / 2=Percentual )

	NX1->(DbSetOrder(3)) // NX1_FILIAL+NX1_CPREFT+NX1_CCONTR
	If NX1->(DbSeek( xFilial('NX1') + cPreft + cContr) )
		While !NX1->(Eof()) .And. NX1->(NX1_FILIAL + NX1_CPREFT + NX1_CCONTR) == xFilial('NX1') + cPreft + cContr
			
			If NX1->NX1_PDESCH > 0 .And. ( NX1->NX1_VDESCO <> ( nVDescCas := NX1->NX1_VTS * NX1->NX1_PDESCH / 100.00 ) )
				RecLock("NX1", .F.)
				NX1->NX1_VDESCO := nVDescCas
				NX1->NX1_VDESCT := nVDescCas
				NX1->(MsUnlock())
				NX1->(DbCommit())
			EndIf

			If NX1->NX1_PCDESC > 0 .And. ( NX1->NX1_VLDESC <> ( nvDescEsp := (NX1->NX1_VTS + NX1->NX1_VFIXO - NX1->NX1_VDESCO) * NX1->NX1_PCDESC / 100.00 ) )
				RecLock("NX1", .F.)
				NX1->NX1_VLDESC := nvDescEsp
				NX1->NX1_VDESCT := nVDescCas + nvDescEsp
				NX1->NX1_PCDESC := nvDescEsp / (NX1->NX1_VTS + NX1->NX1_VFIXO - NX1->NX1_VDESCO) * 100.00
				NX1->(MsUnlock())
				NX1->(DbCommit())
			EndIf

			nDesLinTot += NX1->NX1_VDESCO
			nDesEspTot += NX1->NX1_VLDESC

			nVDescCas := 0 
			nvDescEsp := 0

			NX1->(DbSkip())
		EndDo
	EndIf
Else
	NXC->(DbSetOrder(3)) // NXC_FILIAL+NXC_CESCR+NXC_CFATUR+NXC_CCONTR+NXC_CCLIEN+NXC_CLOJA+NXC_CCASO
	If NXC->( DbSeek( xFilial('NXC') + cEscr + cFatura + cContr ) )
		While !NXC->(Eof()) .And. NXC->( NXC_FILIAL + NXC_CESCR + NXC_CFATUR + NXC_CCONTR ) == xFilial('NXC') + cEscr + cFatura + cContr
			
			If NXC->NXC_PDESCH > 0 .And. ( NXC->NXC_DRATL <> ( nVDescCas := NXC->NXC_VLTS * NXC->NXC_PDESCH / 100.00 ) )
				RecLock("NXC", .F.)
				NXC->NXC_DRATL := nVDescCas
				NXC->NXC_DRATF := nVDescCas
				NXC->(MsUnlock())
				NXC->(DbCommit())
			EndIf

			If NXC->NXC_DRATE > 0
				cTpDescEsp := JurGetDados("NX0", 1, xFilial("NX0") + cPreft, "NX0_TPDESC") //Tipo de Desconto na Pré-fatura (1=Valor / 2=Percentual )
				nPDescEsp  := JurGetDados("NX1", 1, xFilial("NX1") + cPreft + NXC->NXC_CCLIEN + NXC->NXC_CLOJA + cContr + NXC->NXC_CCASO, "NX1_PCDESC")

				If cTpDescEsp == "2" .And. ( NXC->NXC_DRATE <> ( nvDescEsp := (NXC->NXC_VLHFAT - NXC->NXC_VLTAB - NXC->NXC_DRATL) * nPDescEsp / 100.00 ) )
					RecLock("NXC", .F.)
					NXC->NXC_DRATE := nvDescEsp
					NXC->NXC_DRATF := nvDescEsp + nVDescCas
					NXC->(MsUnlock())
					NXC->(DbCommit())
				EndIf
			EndIf

			nDesLinTot += NXC->NXC_DRATL
			nDesEspTot += NXC->NXC_DRATE

			nVDescCas := 0
			nvDescEsp := 0

			NXC->(DbSkip())
		EndDo
	EndIf
EndIf

nVDESCO := nDesLinTot
nVLDESC := nDesEspTot

RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J201ELimFt()
Indica se deve ser executado o cálculo dos valores de limite por fatura

@Param  oParams    Objeto de parâmetros de emissão da pré/fatura
@Param  nVTS       Valor de TS a ser faturado
@Param  cCodPre    Código da pré-fatura (Usado em situações de emissão de fatura)

@author Cristina Cintra / Jorge Martins
@since 11/04/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J201ELimFt(oParams, nVTS, cCodPre)
	Local lRet    := .F.
	Local aDataTS := {}

	If oParams:GetTpExec() $ "1" .And. oParams:GetFltrHH() // Emissão de Pré-fatura com TS
		lRet := .T.
	ElseIf oParams:GetTpExec() $ "2|3|4|5|6|MS" // Reemissão de Pré, Emissão e reemissão de Fatura
		
		aDataTS := JurGetDados("NX0", 1, xFilial("NX0") + cCodPre, {"NX0_DINITS", "NX0_DFIMTS"}) // Indica que a emissão de pré-fatura tinha flag de TS selecionada
		If Len(aDataTS) == 2 .And. !Empty(aDataTS[1])
			lRet := .T. // Se a flag de TS foi marcada na emissão da Pré deverá considerar saldo de limite, mesmo não tendo TS na Pré
		EndIf
	EndIf

Return lRet
