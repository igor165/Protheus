#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "JURAPAD034.CH"

#DEFINE nTamCarac 5.5    // Tamanho de um caractere no relatório
#DEFINE nSalto    10     // Salto de uma linha a outra

#DEFINE nPColData  0     // Posição vertical do campo Data
#DEFINE nPColFor   40    //   ''       ''    ''  ''   Fornecedor
#DEFINE nPColSol   130   //   ''       ''    ''  ''   Solicitante
#DEFINE nPColHist  160   //   ''       ''    ''  ''   Histórico
#DEFINE nPColLanc  305   //   ''       ''    ''  ''   Lançamento
#DEFINE nPColNat   360   //   ''       ''    ''  ''   Natureza
#DEFINE nPColValCv 450   //   ''       ''    ''  ''   Valor Convertido
#DEFINE nPColVal   480   //   ''       ''    ''  ''   Valor
#DEFINE nPColSaldo 540   //   ''       ''    ''  ''   Saldo

#DEFINE cDateFt    cValToChar( Date() ) // Data - Footer
#DEFINE cTimeFt    Time()               // Hora - Footer

Static cAlsTmp     := ""   // Alias da query de Escritório
Static nPage       := 1    // Contador de páginas
Static nSaldoNat   := 0    // Saldo da Natureza
Static nSubTotEsc  := 0    // Subtotal por natureza
Static nTotEnt     := 0    // Total Geral de Entrada
Static nTotSaida   := 0    // Total Geral de Saida
Static __lAuto     := .F.  // Indica se a chamada foi feita via automação
Static _nDecValor  := 0    // Casas decimais do campo OHB_VALOR

//-------------------------------------------------------------------
/*/{Protheus.doc} JURAPAD034
Relatório de Extrato por Natureza/Centro de Custo

@param lAutomato, Indica se a chamada foi feita via automação
@param cNameAuto, Nome do arquivo de relatório usado na automação

@author Jonatas Martins / Jorge Martins
@since 21/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURAPAD034(lAutomato, cNameAuto)
	Local aArea       := GetArea()
	Local lCanc       := .F.
	Local lPDUserAc   := Iif(FindFunction("JPDUserAc"), JPDUserAc(), .T.) // Indica se o usuário possui acesso a dados sensíveis ou pessoais (LGPD)
	
	Default lAutomato := .F.
	Default cNameAuto := ""

	_nDecValor := TamSx3("OHB_VALOR")[2]

	__lAuto := lAutomato

	If lPDUserAc
		While !lCanc
			If __lAuto .Or. JPergunte()
				If JP034TdOk(MV_PAR01, MV_PAR02, MV_PAR03)
					JP034Relat(DtoS( MV_PAR01 ), DtoS( MV_PAR02 ), MV_PAR03, MV_PAR04, cValToChar(MV_PAR05), MV_PAR06, MV_PAR07, MV_PAR08, MV_PAR09, MV_PAR10, cNameAuto, MV_PAR11, cValToChar(MV_PAR12))
					If __lAuto // Se for automação seta lCanc .T. para sair do while
						lCanc := .T.
					EndIf
				EndIf
			Else
				lCanc := .T.
			Endif
		EndDo
	Else
		MsgInfo(STR0030, STR0031) // "Usuário com restrição de acesso a dados pessoais/sensíveis.", "Acesso restrito"
	EndIf

	RestArea( aArea )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JPergunte
Abre o Pergunte para filtro do relatório

@author Jorge Martins
@since  26/11/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JPergunte()
Local lRet := .T.

	lRet := Pergunte('JURAPAD034')

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JP034TdOk
Rotina validar os dados do pergunte

@param  cDataIni   , caractere, Data inicial dos lançamentos
@param  cDataFim   , caractere, Data final dos lançamentos
@param  cEscritFil , caractere, Escritório da filial dos lançamentos

@author Jonatas Martins / Jorge Martins
@since 30/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JP034TdOk(dDataIni, dDataFim, cEscritFil)
Local lRet := .T.

If Empty(dDataIni) .Or. Empty(dDataFim)
	JurMsgErro(STR0021,, STR0022) // "Data inicial e final são obrigatórias." - "Preencha as datas para filtro."
	lRet := .F.
EndIf

If lRet .And. Empty(cEscritFil)
	JurMsgErro(STR0023,, STR0024) // "É obrigatório o preenchimento do Escritório do Lancamento." - "Preencha o campo para filtro."
	lRet := .F.
EndIf

Return lRet

//=======================================================================
/*/{Protheus.doc} JP034Relat
Relatório de Extrato por Natureza/Centro de Custo

@param  cDataIni   , caractere, Data inicial dos lançamentos
@param  cDataFim   , caractere, Data final dos lançamentos
@param  cEscritFil , caractere, Escritório da filial dos lançamentos
@param  cNatureza  , caractere, Natureza dos lançamentos
@param  cStatusNat , caractere, Status da Natureza 1=Ambas; 2=Bloqueado; 3=Não Bloqueado
@param  cTpconta   , caractere, Tipo da Conta 
@param  cEscritCC  , caractere, Escritório
@param  cCusto     , caractere, Centro de Custo dos lançamentos
@param  cProjeto   , Projeto/finalidade
@param  cItemPrj   , Item do projeto
@param  cNameAuto  , Nome do arquivo de relatório usado na automação
@param  cMultiNat  , Multiplas naturezas para filtro, separadas por ;
@param  cTipoImpr  , Tipo de Impressão do Relatório - PDF ou EXCEL

@author  Jonatas Martins / Jorge Martins
@since   28/03/2018
/*/
//=======================================================================
Static Function JP034Relat( cDataIni, cDataFim, cEscritFil, cNatureza, cStatusNat, cTpConta, cEscritCC, cCusto, cProjeto, cItemPrj, cNameAuto, cMultiNat, cTipoImpr)
Local cReportName   := "Extrato_Natureza_CC_" + FwTimeStamp(1)
Local cDirectory    := GetSrvProfString( "StartPath", "" )
Local bRun          := Nil
Local lRet          := .T.
Local cFilialAtu    := cFilAnt
Local cFilEsct      := JurGetDados( "NS7", 1, xFilial("NS7") + cEscritFil, "NS7_CFILIA" )

Default cProjeto    := ""
Default cItemPrj    := ""
Default cMultiNat   := ""
Default cTipoImpr   := ""

	cFilAnt := cFilEsct

	nSaldoNat := 0

	//----------------------
	// Busca dados no banco
	//----------------------
	JReportQry( cDataIni, cDataFim, cEscritFil, cNatureza, cStatusNat, cTpConta, cEscritCC, cCusto, cProjeto, cItemPrj, cMultiNat )

	//-----------------
	// Gera relatórios 
	//-----------------
	If (cAlsTmp)->( ! Eof() )
		If cTipoImpr == "2"
			If __FWLibVersion() >= '20201009' .And. GetRpoRelease() >= '12.1.023' .And. PrinterVersion():fromServer() >= '2.1.0' .And. SrvDisplay()
				bRun := {|| PrintXLSX(cReportName, cDataIni, cDataFim) }
				FwMsgRun( , bRun, STR0001, "" ) //"Gerando relatório, aguarde..."
			Else
				JurMsgError( STR0034 ) // "O ambiente não está preparado para gerar XLSX, verifique ou selecione outra opção de impressão."
			EndIf
		ElseIf __lAuto
			PrintReport(cReportName, cDirectory, cNameAuto)
		Else
			bRun := {|| PrintReport(cReportName, cDirectory, cNameAuto) }
			FwMsgRun( , bRun, STR0001, "" ) //"Gerando relatório, aguarde..."
		EndIf
	Else
		lRet := .F.
		JurMsgError( STR0002 ) //"Não foram encontrados dados para impressão!"
	EndIf
		
	nPage      := 1 // Contador de páginas
	nSubTotEsc := 0 // Subtotal por escritório
	nTotEnt    := 0 // Total Geral de Entrada
	nTotSaida  := 0 // Total Geral de Saida

	(cAlsTmp)->( DbCloseArea() )

	cFilAnt := cFilialAtu
	
Return lRet

//=======================================================================
/*/{Protheus.doc} JReportQry
Monta alias temporário com dados do relatório

@param  cDataIni   , Data inicial dos lançamentos
@param  cDataFim   , Data final dos lançamentos
@param  cEscritFil , Escritório da filial dos lançamentos
@param  cNatureza  , Natureza dos lançamentos
@param  cStatusNat , Status da Natureza 1=Ambas; 2=Bloqueado; 3=Não Bloqueado
@param  cTpconta   , Tipo da Conta 
@param  cEscritCC  , Escritório
@param  cCusto     , Centro de Custo dos lançamentos
@param  cProjeto   , Projeto/finalidade
@param  cItemPrj   , Item do projeto
@param  cMultiNat  , Código de Multiplas Naturezas

@author Luciano Pereira dos Santos
@since  28/03/2018
/*/
//=======================================================================
Static Function JReportQry( cDataIni, cDataFim, cEscritFil, cNatureza, cStatusNat, cTpConta, cEscritCC, cCusto, cProjeto, cItemPrj, cMultiNat)
Local oTpConta      := JurTpConta():New()
Local cQuery        := ""
Local cFilEscr      := ""
Local lEscrit       := !Empty(cEscritCC)
Local lCusto        := !Empty(cCusto)
Local cSCPARTO      := Space(TamSx3('OHB_CPARTO')[1])
Local cSCTRATO      := Space(TamSx3('OHB_CTRATO')[1])
Local cSCPARTD      := Space(TamSx3('OHB_CPARTD')[1])
Local cSCTRATD      := Space(TamSx3('OHB_CTRATD')[1])
Local cNUSAMFIM     := Space(TamSx3('NUS_AMFIM')[1])
Local cOH8AMFIM     := Space(TamSx3('OH8_AMFIM')[1])
Local lExitNat      := Iif(Empty(cNatureza), .F., ExistCpo("SED", cNatureza,,, .F.))
Local cTpContTmp    := ""
Local cFilPrjOri    := ""
Local cFilPrjDes    := ""
Local lHasPrjDes    := X3Uso(GetSx3Cache("OHB_CPROJD", 'X3_USADO')) .And. X3Uso(GetSx3Cache("OHB_CITPRD", 'X3_USADO'))

Default cEscritFil  := ''
Default cNatureza   := ''
Default cTpConta    := ''
Default cEscritCC   := ''
Default cCusto      := ''
Default cStatusNat  := ''
Default cMultiNat   := ''

	If !Empty(cProjeto) // Projeto
		cFilPrjOri := " AND OHB.OHB_CPROJE = '" + cProjeto + "' "
		cFilPrjDes := " AND OHB." + Iif(lHasPrjDes,"OHB_CPROJD","OHB_CPROJE") +  " = '" + cProjeto + "' "

		If !Empty(cItemPrj) // Item Projeto
			cFilPrjOri += " AND OHB.OHB_CITPRJ = '" + cItemPrj + "' "
			cFilPrjDes += " AND OHB." + Iif(lHasPrjDes,"OHB_CITPRD","OHB_CITPRJ") + " = '" + cItemPrj + "' "
		EndIf
	EndIf

	If !Empty(cEscritFil)
		cFilEscr := JurGetDados( "NS7", 1, xFilial("NS7") + cEscritFil, "NS7_CFILIA" )
	EndIf

	cAlsTmp := GetNextAlias()

	// TABELA TEMPORÁRIA - Tipo de contas
	oTpConta:GeraTmp()
	cTpContTmp := oTpConta:GetTmpName()

	//--SALDO ANTERIOR
	cQuery := " SELECT TAB.ORDEM, TAB.FILIAL, TAB.DATA, RD0.RD0_SIGLA, TAB.DOCTO, TAB.NATUREZA, SED.ED_DESCRIC, SED.ED_CMOEJUR, TAB.NATUREZA2, CTOCONV.CTO_SIMB MOEDA_CONV, CTO.CTO_SIMB, TAB.ESCRITORIO, NS7.NS7_NOME, TAB.CENTRO_CUSTO, CTT.CTT_DESC01, TAB.VALOR_CONV, TAB.VALOR_LANC, TAB.DOCTOPAG, SA2.A2_NOME, TAB.SALDO, TAB.RECNO "
	cQuery +=   " FROM ( "
	cQuery +=          " SELECT '1' ORDEM, SALDOANT.FILIAL FILIAL, MAX(SALDOANT.DATA) DATA, '' SOLICITANTE, '' DOCTO, SALDOANT.NATUREZA, SALDOANT.MOEDA, ' ' NATUREZA2, ' ' MOEDACONV, SALDOANT.ESCRITORIO, '' CENTRO_CUSTO, 0 VALOR_CONV, SUM(SALDOANT.VALOR_LANC) VALOR_LANC, SUM(SALDOANT.VALOR_LANC) SALDO, 0 RECNO, '' DOCTOPAG "
	cQuery +=            " FROM ( SELECT OHB.OHB_FILIAL FILIAL, OHB.OHB_DTLANC DATA, OHB.OHB_NATORI NATUREZA, SED.ED_CMOEJUR MOEDA, NS7.NS7_COD ESCRITORIO, "
	cQuery +=                            JP034CsVal(cTpContTmp, "O", .F., .T.) + " VALOR_LANC "
	cQuery +=                     " FROM " + RetSqlName("OHB") + " OHB "
	cQuery +=                    " INNER JOIN " + RetSqlName("SED") + " SED "
	cQuery +=                            " ON (SED.ED_FILIAL = '" + xFilial("SED") + "' "
	cQuery +=                           " AND  SED.ED_CODIGO = OHB.OHB_NATORI "
	cQuery +=                           " AND  SED.D_E_L_E_T_  = ' ' ) "
	cQuery +=                     " LEFT JOIN " + RetSqlName("NS7") + " NS7 "
	cQuery +=                            " ON (NS7_FILIAL = '" + xFilial("NS7") + "' "
	cQuery +=                           " AND  NS7.NS7_CFILIA = OHB.OHB_FILIAL "
	cQuery +=                           " AND  NS7.D_E_L_E_T_ = ' ' ) "
	cQuery +=                    " WHERE OHB.OHB_FILIAL = '" + xFilial("OHB") + "' "
	cQuery +=                      " AND OHB.OHB_DTLANC < '" + cDataIni + "' "
	cQuery +=                      " AND OHB.D_E_L_E_T_ = ' ' "

	If !Empty(cFilEscr)
		cQuery +=                  " AND NS7.NS7_COD = '" + cEscritFil + "' "
	EndIf

	cQuery +=                   " UNION ALL "
	cQuery +=                   " SELECT OHB.OHB_FILIAL FILIAL, OHB.OHB_DTLANC DATA, OHB.OHB_NATDES NATUREZA, SED.ED_CMOEJUR MOEDA, NS7.NS7_COD ESCRITORIO, "
	cQuery +=                            JP034CsVal(cTpContTmp, "D", .F., .T.) + " VALOR_LANC "
	cQuery +=                     " FROM " + RetSqlName("OHB") +" OHB "
	cQuery +=                    " INNER JOIN " +RetSqlName("SED")+" SED "
	cQuery +=                            " ON (SED.ED_FILIAL = '"+ xFilial("SED")+ "' "
	cQuery +=                           " AND SED.ED_CODIGO = OHB.OHB_NATDES "
	cQuery +=                           " AND SED.D_E_L_E_T_  = ' ' ) "
	cQuery +=                     " LEFT JOIN " +RetSqlName("NS7")+" NS7 "
	cQuery +=                            " ON (NS7_FILIAL = '"+ xFilial("NS7")+ "' "
	cQuery +=                           " AND NS7.NS7_CFILIA = OHB.OHB_FILIAL "
	cQuery +=                           " AND NS7.D_E_L_E_T_ = ' ' ) "
	cQuery +=                    " WHERE OHB.OHB_FILIAL = '" + xFilial("OHB") + "' "
	cQuery +=                      " AND OHB.OHB_DTLANC < '" + cDataIni + "' "
	cQuery +=                      " AND OHB.D_E_L_E_T_ = ' ' "
	If !Empty(cFilEscr)
		cQuery +=                  " AND NS7.NS7_COD = '" + cEscritFil + "' "
	Endif
	cQuery +=                 " ) SALDOANT "
	cQuery +=           " GROUP BY SALDOANT.FILIAL, SALDOANT.NATUREZA, SALDOANT.MOEDA, SALDOANT.ESCRITORIO "

	cQuery +=      " UNION "

	// LANÇAMENTOS DE ORIGEM QUE NÃO SEJAM CENTRO DE CUSTO: PARTICIPANTE OU TABELA DE RATEIO
	cQuery +=          " SELECT '2' ORDEM, EXT.OHB_FILIAL FILIAL, EXT.OHB_DTLANC DATA, EXT.OHB_CPART SOLICITANTE, EXT.DOCTO, EXT.NATUREZA, EXT.MOEDA, EXT.NATUREZA2, EXT.MOEDACONV, EXT.ESCRITORIO, EXT.CENTRO_CUSTO, EXT.VALOR_CONV VALOR_CONV, EXT.VALOR_LANC, 0 SALDO, EXT.RECNO, DOCTOPAG "
	cQuery +=          "  FROM ( "
	cQuery +=                 " (SELECT OHB.OHB_FILIAL, OHB.OHB_DTLANC, OHB.OHB_CPART, OHB.OHB_CODIGO DOCTO, OHB.OHB_NATORI NATUREZA, SED.ED_CMOEJUR MOEDA, OHB.OHB_NATDES NATUREZA2, OHB.OHB_CMOELC MOEDACONV, OHB.OHB_CESCRO ESCRITORIO, OHB.OHB_CCUSTO CENTRO_CUSTO, OHB.OHB_CPAGTO DOCTOPAG, "
	cQuery +=                           JP034CsVal(cTpContTmp, "O") + " VALOR_CONV, "
	cQuery +=                         " OHB.OHB_VALOR * (SELECT SINAL FROM " + cTpContTmp + " WHERE CODIGO = SED.ED_TPCOJR AND TIPO = 'O') VALOR_LANC,
	cQuery +=                         " OHB.R_E_C_N_O_ RECNO "
	cQuery +=                   " FROM " +RetSqlName("OHB")+" OHB "
	cQuery +=                   " INNER JOIN " +RetSqlName("SED")+" SED "
	cQuery +=                           " ON (SED.ED_FILIAL = '"+ xFilial("SED")+ "' "
	cQuery +=                               " AND SED.ED_CODIGO = OHB.OHB_NATORI "
	cQuery +=                               " AND SED.D_E_L_E_T_  = ' ' ) "
	cQuery +=                   " WHERE OHB.OHB_FILIAL = '"+ xFilial("OHB")+ "' "
	cQuery +=                     " AND OHB.OHB_CPARTO = '"+ cSCPARTO + "' "
	cQuery +=                     " AND OHB.OHB_CTRATO = '"+ cSCTRATO + "' "
	cQuery +=                       cFilPrjOri // Filtro Projeto/item
	cQuery +=                     " AND OHB.D_E_L_E_T_ = ' ') "
	
	cQuery +=                 " UNION "
	
	// LANÇAMENTOS DE DESTINO QUE NÃO SEJAM CENTRO DE CUSTO: PARTICIPANTE OU TABELA DE RATEIO
	cQuery +=                 " (SELECT OHB.OHB_FILIAL, OHB.OHB_DTLANC, OHB.OHB_CPART, OHB.OHB_CODIGO DOCTO, OHB.OHB_NATDES NATUREZA, SED.ED_CMOEJUR MOEDA, OHB.OHB_NATORI NATUREZA2, OHB.OHB_CMOELC MOEDACONV, OHB.OHB_CESCRD ESCRITORIO, OHB.OHB_CCUSTD CENTRO_CUSTO, OHB.OHB_CPAGTO DOCTOPAG, "
	cQuery +=                           JP034CsVal(cTpContTmp, "D") + " VALOR_CONV, "
	cQuery +=                         " OHB.OHB_VALOR * (SELECT SINAL FROM " + cTpContTmp + " WHERE CODIGO = SED.ED_TPCOJR AND TIPO = 'D') VALOR_LANC, "
	cQuery +=                         " OHB.R_E_C_N_O_ RECNO "
	cQuery +=                  " FROM " +RetSqlName("OHB")+" OHB "
	cQuery +=                  " INNER JOIN " +RetSqlName("SED")+" SED "
	cQuery +=                          " ON (SED.ED_FILIAL = '"+ xFilial("SED")+ "' "
	cQuery +=                              " AND SED.ED_CODIGO = OHB.OHB_NATDES
	cQuery +=                              " AND SED.D_E_L_E_T_ = ' ' ) "
	cQuery +=                  " WHERE OHB.OHB_FILIAL = '"+ xFilial("OHB")+ "' "
	cQuery +=                    " AND OHB.OHB_CPARTD = '"+ cSCPARTD + "' "
	cQuery +=                    " AND OHB.OHB_CTRATD = '"+ cSCTRATD + "' "
	cQuery +=                      cFilPrjDes // Filtro Projeto/item
	cQuery +=                    " AND OHB.D_E_L_E_T_ = ' ') "
	
	cQuery +=                 " UNION "
	
	// LANÇAMENTOS DE ORIGEM QUE SEJAM CENTRO DE CUSTO: PARTICIPANTE
	cQuery +=                 " (SELECT OHB.OHB_FILIAL, OHB.OHB_DTLANC, OHB.OHB_CPART, OHB.OHB_CODIGO DOCTO, OHB.OHB_NATORI NATUREZA, SED.ED_CMOEJUR MOEDA, OHB.OHB_NATDES NATUREZA2, OHB.OHB_CMOELC MOEDACONV, NUS.NUS_CESCR ESCRITORIO, NUS.NUS_CC CENTRO_CUSTO, OHB.OHB_CPAGTO DOCTOPAG, "
	cQuery +=                           JP034CsVal(cTpContTmp, "O") + " VALOR_CONV, "
	cQuery +=                         " OHB.OHB_VALOR * (SELECT SINAL FROM " + cTpContTmp + " WHERE CODIGO = SED.ED_TPCOJR AND TIPO = 'O') VALOR_LANC, "
	cQuery +=                         " OHB.R_E_C_N_O_ RECNO "
	cQuery +=                  " FROM " +RetSqlName("OHB")+" OHB "
	cQuery +=                  " INNER JOIN " +RetSqlName("SED")+" SED "
	cQuery +=                          " ON (SED.ED_FILIAL = '"+ xFilial("SED")+ "' "
	cQuery +=                              " AND SED.ED_CODIGO = OHB.OHB_NATORI
	cQuery +=                              " AND SED.D_E_L_E_T_ = ' ' ) "
	cQuery +=                  " INNER JOIN " +RetSqlName("NUS")+" NUS "
	cQuery +=                          " ON (NUS.NUS_FILIAL = '"+ xFilial("NUS")+ "'"
	cQuery +=                              " AND OHB.OHB_CPARTO = NUS.NUS_CPART "
	cQuery +=                              " AND ((SUBSTRING(OHB.OHB_DTLANC,1,6) >= NUS.NUS_AMINI AND NUS.NUS_AMFIM = '"+ cNUSAMFIM + "') "
	cQuery +=                                    "OR (SUBSTRING(OHB.OHB_DTLANC,1,6) BETWEEN NUS.NUS_AMINI AND NUS.NUS_AMFIM)) "
	cQuery +=                              " AND NUS.D_E_L_E_T_ = ' ' ) "
	cQuery +=                  " WHERE OHB.OHB_FILIAL = '"+ xFilial("OHB")+ "' "
	cQuery +=                    " AND OHB.OHB_CPARTO > '"+ cSCPARTO + "' "
	cQuery +=                      cFilPrjOri // Filtro Projeto/item
	cQuery +=                    " AND OHB.D_E_L_E_T_ = ' ') "
	
	cQuery +=                 " UNION "
	
	//LANÇAMENTOS DE destino QUE SEJAM CENTRO DE CUSTO: PARTICIPANTE
	cQuery +=                 " (SELECT OHB.OHB_FILIAL, OHB.OHB_DTLANC, OHB.OHB_CPART, OHB.OHB_CODIGO DOCTO, OHB.OHB_NATDES NATUREZA, SED.ED_CMOEJUR MOEDA, OHB.OHB_NATORI NATUREZA2, OHB.OHB_CMOELC MOEDACONV, NUS.NUS_CESCR ESCRITORIO, NUS.NUS_CC CENTRO_CUSTO, OHB.OHB_CPAGTO DOCTOPAG, "
	cQuery +=                           JP034CsVal(cTpContTmp, "D") + " VALOR_CONV, "
	cQuery +=                         " OHB.OHB_VALOR * (SELECT SINAL FROM " + cTpContTmp + " WHERE CODIGO = SED.ED_TPCOJR AND TIPO = 'D') VALOR_LANC, "
	cQuery +=                         " OHB.R_E_C_N_O_ RECNO "
	cQuery +=                  " FROM " +RetSqlName("OHB")+" OHB "
	cQuery +=                  " INNER JOIN " +RetSqlName("SED")+" SED "
	cQuery +=                          " ON (SED.ED_FILIAL = '"+ xFilial("SED")+ "' "
	cQuery +=                              " AND SED.ED_CODIGO = OHB.OHB_NATDES "
	cQuery +=                              " AND SED.D_E_L_E_T_ = ' ' ) "
	cQuery +=                  " INNER JOIN " +RetSqlName("NUS")+" NUS "
	cQuery +=                          " ON (NUS.NUS_FILIAL = '"+ xFilial("NUS")+ "'"
	cQuery +=                              " AND OHB.OHB_CPARTD = NUS.NUS_CPART "
	cQuery +=                              " AND ((SUBSTRING(OHB.OHB_DTLANC,1,6) >= NUS.NUS_AMINI AND NUS.NUS_AMFIM = '"+ cNUSAMFIM + "') "
	cQuery +=                                   " OR (SUBSTRING(OHB.OHB_DTLANC,1,6) BETWEEN NUS.NUS_AMINI AND NUS.NUS_AMFIM)) "
	cQuery +=                              " AND NUS.D_E_L_E_T_ = ' ') "
	cQuery +=                  " WHERE OHB.OHB_FILIAL = '"+ xFilial("OHB")+ "' "
	cQuery +=                    " AND OHB.OHB_CPARTD > '"+ cSCPARTD + "' "
	cQuery +=                      cFilPrjDes // Filtro Projeto/item
	cQuery +=                    " AND OHB.D_E_L_E_T_ = ' ') "
	
	cQuery +=                 " UNION "
	
	//LANÇAMENTOS DE ORIGEM QUE SEJAM CENTRO DE CUSTO: TABELA de RATEIO (ESCRITORIO ou ESCRITORIO e CENTRO DE CUSTO)
	cQuery +=                 " (SELECT OHB.OHB_FILIAL, OHB.OHB_DTLANC, OHB.OHB_CPART, OHB.OHB_CODIGO DOCTO, OHB.OHB_NATORI NATUREZA, SED.ED_CMOEJUR MOEDA, OHB.OHB_NATDES NATUREZA2, OHB.OHB_CMOELC MOEDACONV, OH8.OH8_CESCRI ESCRITORIO, OH8.OH8_CCCUST CENTRO_CUSTO, OHB.OHB_CPAGTO DOCTOPAG, "
	cQuery +=                           JP034CsVal(cTpContTmp, "O", .T.) + " VALOR_CONV, "
	cQuery +=                         " ( (OHB.OHB_VALOR * OH8.OH8_PERCEN) / 100) * (SELECT SINAL FROM " + cTpContTmp + " WHERE CODIGO = SED.ED_TPCOJR AND TIPO = 'O') VALOR_LANC, "
	cQuery +=                         " OHB.R_E_C_N_O_ RECNO "
	cQuery +=                  " FROM " +RetSqlName("OHB")+" OHB "
	cQuery +=                  " INNER JOIN " +RetSqlName("SED")+" SED "
	cQuery +=                          " ON (SED.ED_FILIAL = '"+ xFilial("SED")+ "' "
	cQuery +=                              " AND SED.ED_CODIGO = OHB.OHB_NATORI "
	cQuery +=                              " AND SED.D_E_L_E_T_ = ' ' ) "
	cQuery +=                  " INNER JOIN " +RetSqlName("OH6")+" OH6 "
	cQuery +=                          " ON (OH6.OH6_FILIAL = '"+ xFilial("OH6")+ "' "
	cQuery +=                              " AND OHB.OHB_CTRATO = OH6.OH6_CODIGO "
	cQuery +=                              " AND OH6.OH6_TIPO IN ('1','2') "
	cQuery +=                              " AND OH6.D_E_L_E_T_ = ' ') "
	cQuery +=                  " INNER JOIN " + RetSqlName("OH8")+" OH8 "
	cQuery +=                          " ON (OH8.OH8_FILIAL = '"+ xFilial("OH8")+ "' "
	cQuery +=                              " AND OH8.OH8_CODRAT = OH6.OH6_CODIGO "
	cQuery +=                              " AND ((SUBSTRING(OHB.OHB_DTLANC,1,6) >= OH8.OH8_AMINI AND OH8.OH8_AMFIM = '"+ cOH8AMFIM + "') "
	cQuery +=                                   " OR (SUBSTRING(OHB.OHB_DTLANC,1,6) BETWEEN OH8.OH8_AMINI AND OH8.OH8_AMFIM)) "
	cQuery +=                              " AND OH8.D_E_L_E_T_ = ' ') "
	cQuery +=                  " WHERE OHB.OHB_FILIAL = '"+ xFilial("OHB")+ "' "
	cQuery +=                    " AND OHB.OHB_CTRATO > '"+ cSCTRATO + "' "
	cQuery +=                      cFilPrjOri // Filtro Projeto/item
	cQuery +=                    " AND OHB.D_E_L_E_T_ = ' ') "
	
	cQuery +=                 " UNION "
	
	// LANÇAMENTOS DE DESTINO QUE SEJAM CENTRO DE CUSTO: TABELA de RATEIO (ESCRITORIO ou ESCRITORIO e CENTRO DE CUSTO)
	cQuery +=                 " (SELECT OHB.OHB_FILIAL, OHB.OHB_DTLANC, OHB.OHB_CPART, OHB.OHB_CODIGO DOCTO, OHB.OHB_NATDES NATUREZA, SED.ED_CMOEJUR MOEDA, OHB.OHB_NATORI NATUREZA2, OHB.OHB_CMOELC MOEDACONV, OH8.OH8_CESCRI ESCRITORIO, OH8.OH8_CCCUST CENTRO_CUSTO, OHB.OHB_CPAGTO DOCTOPAG, "
	cQuery +=                           JP034CsVal(cTpContTmp, "D", .T.) + " VALOR_CONV, "
	cQuery +=                         " ( (OHB.OHB_VALOR * OH8.OH8_PERCEN) / 100) * (SELECT SINAL FROM " + cTpContTmp + " WHERE CODIGO = SED.ED_TPCOJR AND TIPO = 'D') VALOR_LANC, "
	cQuery +=                         " OHB.R_E_C_N_O_ RECNO "
	cQuery +=                  " FROM " +RetSqlName("OHB")+" OHB "
	cQuery +=                  " INNER JOIN " +RetSqlName("SED")+" SED "
	cQuery +=                          " ON (SED.ED_FILIAL = '"+ xFilial("SED")+ "' "
	cQuery +=                              " AND SED.ED_CODIGO = OHB.OHB_NATDES "
	cQuery +=                              " AND SED.D_E_L_E_T_ = ' ' ) "
	cQuery +=                  " INNER JOIN " +RetSqlName("OH6")+" OH6 "
	cQuery +=                          " ON (OH6.OH6_FILIAL = '"+ xFilial("OH6")+ "' "
	cQuery +=                              " AND OHB.OHB_CTRATD = OH6.OH6_CODIGO "
	cQuery +=                              " AND OH6.OH6_TIPO IN ('1','2') "
	cQuery +=                              " AND OH6.D_E_L_E_T_ = ' ' ) "
	cQuery +=                  " INNER JOIN " + RetSqlName("OH8")+" OH8 "
	cQuery +=                          " ON (OH8.OH8_FILIAL = '"+ xFilial("OH8")+ "' "
	cQuery +=                              " AND OH8.OH8_CODRAT = OH6.OH6_CODIGO "
	cQuery +=                              " AND ((SUBSTRING(OHB.OHB_DTLANC,1,6) >= OH8.OH8_AMINI AND OH8.OH8_AMFIM = '"+ cOH8AMFIM + "') "
	cQuery +=                                   " OR (SUBSTRING(OHB.OHB_DTLANC,1,6) BETWEEN OH8.OH8_AMINI AND OH8.OH8_AMFIM)) "
	cQuery +=                              " AND OH8.D_E_L_E_T_ = ' ') "
	cQuery +=                  " WHERE OHB.OHB_FILIAL = '"+ xFilial("OHB")+ "' "
	cQuery +=                    " AND OHB.OHB_CTRATD > '"+ cSCTRATD + "' "
	cQuery +=                      cFilPrjDes // Filtro Projeto/item
	cQuery +=                    " AND OHB.D_E_L_E_T_ = ' ') "
	
	cQuery +=                 " UNION "
	
	// LANÇAMENTOS DE ORIGEM QUE SEJAM CENTRO DE CUSTO: TABELA de RATEIO (PROFISSIONAL)
	cQuery +=                 " (SELECT OHB.OHB_FILIAL, OHB.OHB_DTLANC, OHB.OHB_CPART, OHB.OHB_CODIGO DOCTO, OHB.OHB_NATORI NATUREZA, SED.ED_CMOEJUR MOEDA, OHB.OHB_NATDES NATUREZA2, OHB.OHB_CMOELC MOEDACONV, NUS.NUS_CESCR ESCRITORIO, NUS.NUS_CC CENTRO_CUSTO, OHB.OHB_CPAGTO DOCTOPAG, " 
	cQuery +=                           JP034CsVal(cTpContTmp, "O", .T.) + " VALOR_CONV, "
	cQuery +=                         " ( (OHB.OHB_VALOR * OH8.OH8_PERCEN) / 100 ) * (SELECT SINAL FROM " + cTpContTmp + " WHERE CODIGO = SED.ED_TPCOJR AND TIPO = 'O') VALOR_LANC, "
	cQuery +=                         " OHB.R_E_C_N_O_ RECNO "
	cQuery +=                  " FROM " +RetSqlName("OHB")+" OHB "
	cQuery +=                  " INNER JOIN " +RetSqlName("SED")+" SED "
	cQuery +=                          " ON (SED.ED_FILIAL = '"+ xFilial("SED")+ "' "
	cQuery +=                              " AND SED.ED_CODIGO = OHB.OHB_NATORI "
	cQuery +=                              " AND SED.D_E_L_E_T_ = ' ' ) "
	cQuery +=                  " INNER JOIN " +RetSqlName("OH6")+" OH6 "
	cQuery +=                          " ON (OH6.OH6_FILIAL = '"+ xFilial("OH6")+ "' "
	cQuery +=                              " AND OHB.OHB_CTRATO = OH6.OH6_CODIGO "
	cQuery +=                              " AND OH6.OH6_TIPO = '3' "
	cQuery +=                              " AND OH6.D_E_L_E_T_ = ' ') "
	cQuery +=                  " INNER JOIN " + RetSqlName("OH8")+" OH8 "
	cQuery +=                          " ON (OH8.OH8_FILIAL = '"+ xFilial("OH8")+ "' "
	cQuery +=                              " AND OH8.OH8_CODRAT = OH6.OH6_CODIGO "
	cQuery +=                              " AND ((SUBSTRING(OHB.OHB_DTLANC,1,6) >= OH8.OH8_AMINI AND OH8.OH8_AMFIM = '"+ cOH8AMFIM + "') "
	cQuery +=                                   "OR (SUBSTRING(OHB.OHB_DTLANC,1,6) BETWEEN OH8.OH8_AMINI AND OH8.OH8_AMFIM)) "
	cQuery +=                              " AND OH8.D_E_L_E_T_ = ' ') "
	cQuery +=                  " INNER JOIN " + RetSqlName("NUS")+" NUS "
	cQuery +=                          " ON (NUS.NUS_FILIAL = '"+ xFilial("NUS")+ "' "
	cQuery +=                              " AND OH8.OH8_CPARTI = NUS.NUS_CPART "
	cQuery +=                              " AND ((SUBSTRING(OHB.OHB_DTLANC,1,6) >= NUS.NUS_AMINI AND NUS.NUS_AMFIM = '"+ cNUSAMFIM + "') "
	cQuery +=                                   " OR (SUBSTRING(OHB.OHB_DTLANC,1,6) BETWEEN NUS.NUS_AMINI AND NUS.NUS_AMFIM)) "
	cQuery +=                              " AND NUS.D_E_L_E_T_ = ' ') "
	cQuery +=                  " WHERE OHB.OHB_FILIAL = '"+ xFilial("OHB")+ "' "
	cQuery +=                    " AND OHB.OHB_CTRATO > '"+ cSCTRATO + "' "
	cQuery +=                      cFilPrjOri // Filtro Projeto/item
	cQuery +=                    " AND OHB.D_E_L_E_T_ = ' ') "
	
	cQuery +=                 " UNION "
	
	// LANÇAMENTOS DE DESTINO QUE SEJAM CENTRO DE CUSTO: TABELA de RATEIO (PROFISSIONAL)
	cQuery +=                 " (SELECT OHB.OHB_FILIAL, OHB.OHB_DTLANC, OHB.OHB_CPART, OHB.OHB_CODIGO DOCTO, OHB.OHB_NATDES NATUREZA, SED.ED_CMOEJUR MOEDA, OHB.OHB_NATORI NATUREZA2, OHB.OHB_CMOELC MOEDACONV, NUS.NUS_CESCR ESCRITORIO, NUS.NUS_CC CENTRO_CUSTO, OHB.OHB_CPAGTO DOCTOPAG, " 
	cQuery +=                           JP034CsVal(cTpContTmp, "D", .T.) + " VALOR_CONV, "
	cQuery +=                         " ( (OHB.OHB_VALOR * OH8.OH8_PERCEN) / 100 ) * (SELECT SINAL FROM " + cTpContTmp + " WHERE CODIGO = SED.ED_TPCOJR AND TIPO = 'D') VALOR_LANC, "
	cQuery +=                         " OHB.R_E_C_N_O_ RECNO "
	cQuery +=                  " FROM " +RetSqlName("OHB")+" OHB "
	cQuery +=                  " INNER JOIN " +RetSqlName("SED")+" SED "
	cQuery +=                          " ON (SED.ED_FILIAL = '"+ xFilial("SED")+ "' "
	cQuery +=                              " AND SED.ED_CODIGO = OHB.OHB_NATDES "
	cQuery +=                              " AND SED.D_E_L_E_T_ = ' ' ) "
	cQuery +=                  " INNER JOIN " +RetSqlName("OH6")+" OH6 "
	cQuery +=                          " ON (OH6.OH6_FILIAL = '"+ xFilial("OH6")+ "' "
	cQuery +=                              " AND OHB.OHB_CTRATD = OH6.OH6_CODIGO "
	cQuery +=                              " AND OH6.OH6_TIPO = '3' "
	cQuery +=                              " AND OH6.D_E_L_E_T_ = ' ') "
	cQuery +=                  " INNER JOIN " + RetSqlName("OH8")+" OH8 "
	cQuery +=                          " ON (OH8.OH8_FILIAL = '"+ xFilial("OH8")+ "' "
	cQuery +=                              " AND OH8.OH8_CODRAT = OH6.OH6_CODIGO "
	cQuery +=                              " AND ((SUBSTRING(OHB.OHB_DTLANC,1,6) >= OH8.OH8_AMINI AND OH8.OH8_AMFIM = '"+ cOH8AMFIM + "') "
	cQuery +=                                   " OR (SUBSTRING(OHB.OHB_DTLANC,1,6) BETWEEN OH8.OH8_AMINI AND OH8.OH8_AMFIM)) "
	cQuery +=                              " AND OH8.D_E_L_E_T_ = ' ') "
	cQuery +=                  " INNER JOIN " + RetSqlName("NUS")+" NUS "
	cQuery +=                          " ON (NUS.NUS_FILIAL = '"+ xFilial("NUS")+ "' "
	cQuery +=                              " AND OH8.OH8_CPARTI = NUS.NUS_CPART "
	cQuery +=                              " AND ((SUBSTRING(OHB.OHB_DTLANC,1,6) >= NUS.NUS_AMINI AND NUS.NUS_AMFIM = '"+ cNUSAMFIM + "') "
	cQuery +=                                   " OR (SUBSTRING(OHB.OHB_DTLANC,1,6) BETWEEN NUS.NUS_AMINI AND NUS.NUS_AMFIM)) "
	cQuery +=                              " AND NUS.D_E_L_E_T_ = ' ') "
	cQuery +=                  " WHERE OHB.OHB_FILIAL = '"+ xFilial("OHB")+ "' "
	cQuery +=                    " AND OHB.OHB_CTRATD > '"+ cSCTRATD + "' "
	cQuery +=                      cFilPrjDes // Filtro Projeto/item
	cQuery +=                    " AND OHB.D_E_L_E_T_ = ' ') "
	cQuery +=                  ") EXT "
	cQuery += IIf(lEscrit, " INNER", " LEFT") + " JOIN "+ RetSqlName("NS7")+ " NS7 "
	cQuery +=                                     " ON (NS7_FILIAL = '"+ xFilial("NS7")+ "' "
	cQuery +=                                         " AND NS7.NS7_COD = EXT.ESCRITORIO "
	If lEscrit
		cQuery +=                                      " AND NS7.NS7_COD = '" + cEscritCC + "' " // escritorio (quando o filtro estiver ativo incluir todo o inner, se nao faz left para descrição)
	EndIf
	cQuery +=                                          " AND NS7.D_E_L_E_T_ = ' ') "
	
	cQuery += IIf(lCusto, " INNER ", " LEFT ") + " JOIN "+ RetSqlName("CTT")+ " CTT "
	cQuery +=                                      " ON (CTT_FILIAL = '"+ xFilial("CTT")+ "' "
	cQuery +=                                          " AND CTT.CTT_CUSTO = EXT.CENTRO_CUSTO "
	If lCusto
		cQuery +=                                      " AND CTT.CTT_CUSTO = '" + cCusto + "' " // centro de custo (quando o filtro estiver ativo incluir todo o inner, se nao faz left para descrição)
	EndIf
	cQuery +=                                          " AND CTT.D_E_L_E_T_ = ' ') "
	cQuery +=          " WHERE EXT.OHB_DTLANC BETWEEN '" + cDataIni + "'  AND '" + cDatafim + "' " // Periodo 
	cQuery +=          ") TAB "
	cQuery +=          " LEFT JOIN " +RetSqlName("RD0")+" RD0 "
	cQuery +=                 " ON (RD0.RD0_FILIAL = '"+ xFilial("RD0")+ "' "
	cQuery +=                      " AND RD0.RD0_CODIGO = TAB.SOLICITANTE " // Solicitante
	cQuery +=                      " AND RD0.D_E_L_E_T_ = ' ') "
	
	cQuery +=          " INNER JOIN " +RetSqlName("SED")+" SED "
	cQuery +=                  " ON (SED.ED_FILIAL = '"+ xFilial("SED")+ "' "
	cQuery +=                      " AND SED.ED_CODIGO = TAB.NATUREZA "

	If !Empty(cMultiNat)
		cQuery +=                  " AND SED.ED_CODIGO IN (" + CnvMultNat(cMultiNat) + ") " // Multiplas naturezas
	ElseIf lExitNat
		cQuery +=                  " AND SED.ED_CODIGO = '" + cNatureza + "' " // natureza
	ElseIf !Empty(cNatureza)
		cQuery +=                  " AND SED.ED_CODIGO LIKE '" + AllTrim(cNatureza) + "%' " // natureza
	EndIf

	If !Empty(cTpConta)
		cQuery +=                  " AND SED.ED_TPCOJR = '" + cValToChar( cTpConta ) + "' " // tipo de conta
	EndIf

	If !Empty(cStatusNat) .And. cStatusNat != "1"
		cQuery +=                  " AND SED.ED_MSBLQL " + Iif(cStatusNat == '2', " = '1'", " != '1'") // situação natureza (alterar operador para bloqueado)
	EndIf
	cQuery +=                      " AND SED.D_E_L_E_T_ = ' ') "

	cQuery +=          " INNER JOIN " +RetSqlName("CTO")+" CTO "
	cQuery +=                  " ON (CTO.CTO_FILIAL = '"+ xFilial("CTO")+ "' "
	cQuery +=                      " AND CTO.CTO_MOEDA = TAB.MOEDA "
	cQuery +=                      " AND CTO.D_E_L_E_T_ = ' ') "

	cQuery +=          " LEFT JOIN " +RetSqlName("CTO")+" CTOCONV "
	cQuery +=                  " ON (CTOCONV.CTO_FILIAL = '"+ xFilial("CTO")+ "' "
	cQuery +=                      " AND CTOCONV.CTO_MOEDA = TAB.MOEDACONV "
	cQuery +=                      " AND CTOCONV.D_E_L_E_T_ = ' ') "

	cQuery +=          " LEFT JOIN "+ RetSqlName("NS7")+ " NS7 "
	cQuery +=                  " ON (NS7_FILIAL = '"+ xFilial("NS7")+ "' "
	cQuery +=                      " AND NS7.NS7_COD = TAB.ESCRITORIO "
	cQuery +=                      " AND NS7.D_E_L_E_T_ = ' ') "

	cQuery +=          " LEFT JOIN "+ RetSqlName("CTT")+ " CTT "
	cQuery +=                  " ON (CTT_FILIAL = '"+ xFilial("CTT")+ "' "
	cQuery +=                      " AND CTT.CTT_CUSTO = TAB.CENTRO_CUSTO "
	cQuery +=                      " AND CTT.D_E_L_E_T_ = ' ') "
	cQuery +=          " LEFT JOIN " + RetSqlName("SE2") + " SE2 "
	cQuery +=                  " ON ( SE2.E2_FILIAL " +     "|| '|' || "
	cQuery +=                          " SE2.E2_PREFIXO " + "|| '|' || "
	cQuery +=                          " SE2.E2_NUM " +     "|| '|' || "
	cQuery +=                          " SE2.E2_PARCELA " + "|| '|' || "
	cQuery +=                          " SE2.E2_TIPO " +    "|| '|' || "
	cQuery +=                          " SE2.E2_FORNECE " + "|| '|' || "
	cQuery +=                          " SE2.E2_LOJA = DOCTOPAG "
	cQuery +=                      " AND SE2.E2_FILIAL = TAB.FILIAL  "
	cQuery +=                      " AND SE2.D_E_L_E_T_ = ' ') "
	cQuery +=          " LEFT JOIN " + RetSqlName("SA2") + " SA2 "
	cQuery +=                 " ON ( SA2.A2_COD = SE2.E2_FORNECE "
	cQuery +=                      " AND SA2.A2_LOJA = SE2.E2_LOJA "
	cQuery +=                      JSqlFilCom("SE2", "SA2",,, "E2_FILIAL", "A2_FILIAL") 
	cQuery +=                      " AND SA2.D_E_L_E_T_ = ' ') "

	If !Empty(cFilEscr)
		cQuery +=      " WHERE TAB.FILIAL = '" + cFilEscr + "' " // Filial do lançamento (Escritório)
	Endif

	cQuery +=         " ORDER BY TAB.NATUREZA, TAB.ORDEM, TAB.ESCRITORIO, TAB.CENTRO_CUSTO, TAB.DATA, TAB.DOCTO "

	cQuery := ChangeQuery( cQuery )

	DbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAlsTmp , .T. , .T. )

Return Nil

//=======================================================================
/*/{Protheus.doc} PrintReport
Função para gerar PDF do relatório de Balancete Plano/Empresa.

@param  cReportName , caracter , Nome do relatório
@param  cDirectory  , caracter , Caminho da pasta
@param  cNameAuto   , caracter , Nome do arquivo de relatório usado na automação

@author Jonatas Martins / Jorge Martins
@since  28/03/2018
/*/
//=======================================================================
Static Function PrintReport(cReportName , cDirectory, cNameAuto)
Local oPrinter          := Nil
Local cNameFile         := cReportName
Local nIniH             := 0
Local nFimH             := 560
Local lAdjustToLegacy   := .F.
Local lDisableSetup     := .T.
Local aRetNewNat        := {}
Local lNovaNatur        := .F.
Local cCodEscrit        := ""
Local cEscrit           := ""
Local cCodCCusto        := ""
Local cCCusto           := ""
Local cNatNewPag        := ""

Default cReportName := FwTimeStamp(1)
Default cDirectory  := GetSrvProfString( "StartPath" , "" )

	// Configurações do relatório
	If !__lAuto
		oPrinter := FWMsPrinter():New( cNameFile, IMP_PDF, lAdjustToLegacy, cDirectory, lDisableSetup,,, "PDF" )
	Else
		oPrinter := FWMSPrinter():New( cNameAuto, IMP_SPOOL,,, .T.,,,,.T.) // Inicia o relatório
		//Alterar o nome do arquivo de impressão para o padrão de impressão automatica
		oPrinter:CFILENAME  := cNameAuto
		oPrinter:CFILEPRINT := oPrinter:CPATHPRINT + oPrinter:CFILENAME
	EndIf
	
	oPrinter:SetPortrait()
	oPrinter:SetPaperSize(DMPAPER_A4)
	oPrinter:SetMargin(60,60,60,60) 
	
	//Gera nova folha
	aRetNewNat := NewPage( @oPrinter, nIniH, nFimH )

	// IsNewNat está sendo chamada aqui, para evitar erro de recursão "stack depth overflow"
	If !Empty(aRetNewNat) .And. Len(aRetNewNat) >= 6
		lNovaNatur := aRetNewNat[1]
		cCodEscrit := aRetNewNat[2]
		cEscrit    := aRetNewNat[3]
		cCodCCusto := aRetNewNat[4]
		cCCusto    := aRetNewNat[5]
		cNatNewPag := aRetNewNat[6]

		If lNovaNatur
			IsNewNat( oPrinter, nIniH, nFimH, /*nIniV*/, /*nRegPos*/, cCodEscrit, cEscrit, cCodCCusto, cCCusto, cNatNewPag)
		EndIf
	EndIf

	// Imprime seção de escritório
	PrintRepData( @oPrinter, nIniH, nFimH )
	
	//Gera arquivo relatório
	oPrinter:Print()
	
Return Nil

//=======================================================================
/*/{Protheus.doc} NewPage
Cria nova página do relatório.

@param  oPrinter   , objeto     , Estrutra do relatório
@param  nIniH      , numerico   , Coordenada horizontal inicial
@param  nFimH      , numerico   , Coordenada horizontal final
@param  lImpTitCol , logico     , Indica se imprime os títulos das colunas
@param  cNatureza  , caractere  , Codigo da natureza corrente de impressão

@return aRetNewNat , Dados para executar a função IsNewNat()

@author Jonatas Martins / Jorge Martins
@since  28/03/2018
/*/
//=======================================================================
Static Function NewPage( oPrinter, nIniH, nFimH, lImpTitCol, cNatureza)
	Local cCodEscrit    := ""
	Local cEscrit       := ""
	Local cCodCCusto    := ""
	Local cCCusto       := ""
	Local lNovaNatur    := .F. // Indica se é uma nova Natureza (Linha de Saldo Anterior)
	Local aRetNewNat    := {}
	
	Default lImpTitCol  := .T.
	Default cNatureza   := (cAlsTmp)->NATUREZA
	
	//Inicio Página
	oPrinter:StartPage()
	
	//Monta cabeçalho
	PrintHead( @oPrinter, nIniH, nFimH, @lNovaNatur, @cCodEscrit, @cEscrit, @cCodCCusto, @cCCusto, cNatureza )
	aRetNewNat := {lNovaNatur, cCodEscrit, cEscrit, cCodCCusto, cCCusto, cNatureza}

	// Monta títulos das colunas
	If lImpTitCol
		PrintTitCol( @oPrinter, nIniH, nFimH, 124, cNatureza )
	EndIf
	
	//Imprime Rodapé
	PrintFooter( @oPrinter, nIniH, nFimH )

Return aRetNewNat

//=======================================================================
/*/{Protheus.doc} PrintHead
Imprime dados do cabeçalho.

@param  oPrinter   , objeto     , Estrutra do relatório
@param  nIniH      , numerico   , Coordenada horizontal inicial
@param  nFimH      , numerico   , Coordenada horizontal final
@param  lNovaNatur , caractere  , Indica se é uma nova natureza
@param  cCodEscrit , caractere  , Código do Escritório
@param  cEscrit    , caractere  , Nome do Escritório
@param  cCodCCusto , caractere  , Código do Centro de Custo
@param  cCCusto    , caractere  , Descrição do Centro de Custo
@param  cNatureza  , caractere  , Codigo da natureza corrente de impressão

@author Jonatas Martins / Jorge Martins
@since  28/03/2018
/*/
//=======================================================================
Static Function PrintHead( oPrinter, nIniH, nFimH, lNovaNatur, cCodEscrit, cEscrit, cCodCCusto, cCCusto, cNatureza )
	Local oFontHead     := Nil
	Local oFontHead2    := Nil
	Local aDadosNat     := {}
	Local cSimb         := ""
	Local cEscritFil    := AllTrim( JurGetDados( "NS7", 1, xFilial("NS7") + AllTrim( MV_PAR03 ), "NS7_NOME" ) )
	Local cSaldoAnt     := FormatNum( 0 )
	Local lImpSaldoAnt  := nSaldoNat == 0
	
	Default cNatureza   := (cAlsTmp)->NATUREZA

	//-------------------------------------------------------------------------
	// Imprime saldo anterior a data inicial do filtro "MV_PAR01" caso existir
	//-------------------------------------------------------------------------
	If lImpSaldoAnt .And. (cAlsTmp)->ORDEM == "1"
		cSaldoAnt := FormatNum( (cAlsTmp)->VALOR_LANC )
		nSaldoNat += (cAlsTmp)->VALOR_LANC
		
		cCodEscrit := AllTrim( (cAlsTmp)->ESCRITORIO   )
		cEscrit    := AllTrim( (cAlsTmp)->NS7_NOME     )
		cCodCCusto := AllTrim( (cAlsTmp)->CENTRO_CUSTO )
		cCCusto    := AllTrim( (cAlsTmp)->CTT_DESC01   )

		(cAlsTmp)->( DbSkip() )

		// Verifica se houve mudança de natureza. 
		// Se houve, significa que não existem movimentações para a natureza anterior.
		lNovaNatur := !Empty(Alltrim((cAlsTmp)->NATUREZA)) .And. (cAlsTmp)->NATUREZA != cNatureza
	EndIf
	
	oFontHead   := TFont():New('Arial',,-16,,.T.,,,,,.F.,.F.)
	oFontHead2  := TFont():New('Arial',,-10,,.F.,,,,,.F.,.F.)
	
	//---------------------
	// Título do relatório
	//---------------------
	oPrinter:SayAlign( 030, nIniH, STR0003, oFontHead, nFimH, 200, CLR_BLACK, 2, 1 ) //"Extrato de Contas (Centro de Custos) 
	
	//---------------------------------
	// Detalhes do filtro do relatório
	//---------------------------------
	oPrinter:Line( 060, nIniH, 060, nFimH, 0, "-8")
	oPrinter:Say( 070, nIniH , I18N( STR0004 , { cValToChar( MV_PAR01 ), cValToChar( MV_PAR02 ) } ), oFontHead2, 1200,/*color*/) //"Período de #1 à #2"
	
	oPrinter:SayAlign( 062, nIniH, I18N( STR0005, { cEscritFil } ), oFontHead2, nFimH, 200, CLR_BLACK, 1, 1 ) //"Escritório: #1"
	oPrinter:Line( 074, nIniH, 074, nFimH, 0, "-8")
	
	//---------------------------------
	// Detalhes da natureza
	//---------------------------------
	aDadosNat := JurGetDados( "SED" , 1 , xFilial("SED") + cNatureza , {"ED_DESCRIC", "ED_CMOEJUR"} )
	cSimb     := JurGetDados( "CTO" , 1 , xFilial("CTO") + aDadosNat[2], "CTO_SIMB" )
	oPrinter:Line( 088, nIniH, 088, nFimH, CLR_HRED, "-8")
	oPrinter:Say( 098, nIniH , I18N( STR0006 , { Alltrim( cNatureza ) , Alltrim( aDadosNat[1] ) , AllTrim( cSimb ) } ), oFontHead2, 1200,/*color*/) //"Natureza: #1 - #2 (Valores em #3)"
	
	If lImpSaldoAnt
		oPrinter:SayAlign( 098 -8, nIniH, STR0019 + ": " + cSaldoAnt, oFontHead2, nFimH, 200, CLR_BLACK, 1, 1 ) //"Saldo Anterior"
	EndIf
	
	oPrinter:Line( 102, nIniH, 102, nFimH, CLR_HRED, "-8")

Return Nil

//=======================================================================
/*/{Protheus.doc} PrintTitCol
Imprime título das colonas do relatório.

@param  oPrinter   , objeto     , Estrutra do relatório
@param  nIniH      , numerico   , Coordenada horizontal inicial
@param  nFimH      , numerico   , Coordenada horizontal final
@param  nIniV      , numerico   , Coordenada vertical inicial
@param  cNatureza  , caractere  , Codigo da natureza corrente de impressão

@author Jonatas Martins / Jorge Martins
@since  28/03/2018
/*/
//=======================================================================
Static Function PrintTitCol( oPrinter, nIniH, nFimH, nIniV, cNatureza )
Local oFontTitCol := Nil
Local cEscrit     := AllTrim( (cAlsTmp)->ESCRITORIO )   + " - " + AllTrim( (cAlsTmp)->NS7_NOME )
Local cCC         := AllTrim( (cAlsTmp)->CENTRO_CUSTO ) + " - " + AllTrim( (cAlsTmp)->CTT_DESC01 )

	oFontTitCol := TFont():New('Arial',,-10,,.F.,,,,,.F.,.F.)

	//-----------------------
	// Avalia fim da página
	//----------------------- 
	EndPage( @oPrinter , nIniH , nFimH , @nIniV , /*nRegPos*/ , (4 * nSalto), /*lImpTitCol*/,  /*lEndForced*/, cNatureza )
	
	oPrinter:Say( nIniV          , nIniH, I18N( STR0005, { cEscrit } ), oFontTitCol, 1200,/*color*/) //"Escritório: #1"
	oPrinter:Say( nIniV += nSalto, nIniH, I18N( STR0007, { cCC     } ), oFontTitCol, 1200,/*color*/) //"Centro de Custo: #1"
	nIniV += nSalto
	
	oPrinter:Line( nIniV, nIniH, nIniV, nFimH, CLR_HRED, "-8")
	oPrinter:Say( nIniV += 9, nIniH + nPColData , STR0008 , oFontTitCol, 1200,/*color*/) //"Data"
	oPrinter:Say( nIniV     , nIniH + nPColFor  , STR0032 , oFontTitCol, 1200,/*color*/) //"Fornecedor"
	oPrinter:Say( nIniV     , nIniH + nPColSol  , STR0009 , oFontTitCol, 1200,/*color*/) //"Solic."
	oPrinter:Say( nIniV     , nIniH + nPColHist , STR0010 , oFontTitCol, 1200,/*color*/) //"Histórico"
	oPrinter:Say( nIniV     , nIniH + nPColNat  , STR0011 , oFontTitCol, 1200,/*color*/) //"Natureza"
	oPrinter:Say( nIniV     , nIniH + nPColLanc , STR0020 , oFontTitCol, 1200,/*color*/) //"Lançamento"
	oPrinter:Say( nIniV     , nIniH + nPColValCv, " "     , oFontTitCol, 1200,/*color*/)
	oPrinter:Say( nIniV     , nIniH + nPColVal  , STR0012 , oFontTitCol, 1200,/*color*/) //"Valor"
	oPrinter:Say( nIniV     , nIniH + nPColSaldo, STR0013 , oFontTitCol, 1200,/*color*/) //"Saldo"
	oPrinter:Line( nIniV += 4, nIniH, nIniV, nFimH, CLR_HRED, "-8")
	nIniV += nSalto

Return Nil

//=======================================================================
/*/{Protheus.doc} PrintFooter
Imprimide rodapé do cabeçalho.

@param  oPrinter, objeto   , Estrutra do relatório
@param  nIniH   , numerico , Coordenada horizontal inicial
@param  nFimH   , numerico , Coordenada horizontal final

@author Jonatas Martins / Jorge Martins
@since	28/03/2018
/*/
//=======================================================================
Static Function PrintFooter( oPrinter, nIniH, nIniF )
	Local oFontRod := Nil
	Local nLinRod  := 830
	
	oFontRod := TFont():New('Arial',,-10,,.F.,,,,,.F.,.F.)
	
	oPrinter:Line( nLinRod, nIniH, nLinRod, nIniF, CLR_HRED, "-8")
	nLinRod += nSalto
	If !__lAuto
		oPrinter:SayAlign( nLinRod, nIniH, cDateFt + " - " + cTimeFt, oFontRod, nIniF, 200, CLR_BLACK, 2, 1 )
		oPrinter:SayAlign( nLinRod, nIniH, cValToChar( nPage )      , oFontRod, nIniF, 200, CLR_BLACK, 1, 1 )
	EndIf

Return Nil

//=======================================================================
/*/{Protheus.doc} PrintSubTot
Imprimide subtotal na quebra por escritório.

@param  oPrinter   , objeto     , Estrutra do relatório
@param  nIniH      , numerico   , Coordenada horizontal inicial
@param  nFimH	   , numerico   , Coordenada horizontal final
@param  nIniV	   , numerico   , Coordenada vertical inicial
@param  cCodEscrit , caractere  , Código do Escritório
@param  cEscrit    , caractere  , Nome do Escritório
@param  cCodCCusto , caractere  , Código do Centro de Custo
@param  cCCusto    , caractere  , Descrição do Centro de Custo
@param  cNatureza  , caractere  , Codigo da natureza corrente de impressão

@author Jonatas Martins / Jorge Martins
@since  28/03/2018
/*/
//=======================================================================
Static Function PrintSubTot( oPrinter, nIniH, nFimH, nIniV, cCodEscrit, cEscrit, cCodCCusto, cCCusto, cNatureza )
	Local oFontSubTot  := Nil
	Local cSubTot      := FormatNum(nSubTotEsc)
	
	Default cCodEscrit := (cAlsTmp)->ESCRITORIO
	Default cEscrit    := (cAlsTmp)->NS7_NOME
	Default cCodCCusto := (cAlsTmp)->CENTRO_CUSTO
	Default cCCusto    := (cAlsTmp)->CTT_DESC01
	Default cNatureza  := (cAlsTmp)->NATUREZA
	
	oFontSubTot := TFont():New('Arial',,-10,,.T.,,,,,.F.,.F.)
	
	//-----------------------
	// Avalia fim da página
	//----------------------- 
	EndPage( @oPrinter, nIniH, nFimH, @nIniV, /*nRegPos*/, (3 * nSalto), .F., /*lEndForced*/, cNatureza )

	oPrinter:SayAlign( nIniV,  -100, I18N( STR0014, { AllTrim(cCodEscrit) + " - " + AllTrim(cEscrit) } ) , oFontSubTot, nFimH, 200, CLR_BLACK, 1, 1 ) //"Total do Escritório #1: "
	oPrinter:SayAlign( nIniV, nIniH, cSubTot , oFontSubTot, nFimH, 200, CLR_BLACK, 1, 1 )
	
	nIniV += nSalto
	
	oPrinter:SayAlign( nIniV, -100 , I18N( STR0015, { AllTrim(cCodCCusto) + " - " + AllTrim(cCCusto) } ) , oFontSubTot, nFimH, 200, CLR_BLACK, 1, 1 ) //"Total do Centro de Custo #1: "
	oPrinter:SayAlign( nIniV, nIniH, cSubTot  , oFontSubTot, nFimH, 200, CLR_BLACK, 1, 1 )
	
	oPrinter:Line( nIniV + 12, 460, nIniV + 12, nFimH, 0, "-8")
	
	nIniV += nSalto

Return Nil

//=======================================================================
/*/{Protheus.doc} PrintTotGer
Imprimide Total Geral

@param  oPrinter   , objeto     , Estrutra do relatório
@param  nIniH      , numerico   , Coordenada horizontal inicial
@param  nFimH	   , numerico   , Coordenada horizontal final
@param  nIniV      , numerico   , Coordenada vertical inicial
@param  cNatureza  , caractere  , Codigo da natureza corrente de impressão

@author Jonatas Martins / Jorge Martins
@since  28/03/2018
/*/
//=======================================================================
Static Function PrintTotGer( oPrinter, nIniH, nFimH, nIniV, cNatureza)
	Local oFontTotGer := TFont():New('Arial',,-10,,.T.,,,,,.F.,.F.)
	
	Default cNatureza := (cAlsTmp)->NATUREZA

	//-----------------------
	// Avalia fim da página
	//----------------------- 
	EndPage( @oPrinter, nIniH, nFimH, @nIniV, /*nRegPos*/, (5 * nSalto), .F., /*lEndForced*/, cNatureza )

	nIniV += nSalto + 5
	
	oPrinter:SayAlign( nIniV,  -100, STR0016              , oFontTotGer, nFimH, 200, CLR_BLACK, 1, 1 ) //"TOTAL DE ENTRADA (+)"
	oPrinter:SayAlign( nIniV, nIniH, FormatNum( nTotEnt ) , oFontTotGer, nFimH, 200, CLR_BLACK, 1, 1 )
	
	nIniV += nSalto + 5
	
	oPrinter:SayAlign( nIniV,  -100, STR0017               , oFontTotGer, nFimH, 200, CLR_BLACK, 1, 1 ) //"TOTAL DE SAIDA (-)"
	oPrinter:SayAlign( nIniV, nIniH, FormatNum( nTotSaida ), oFontTotGer, nFimH, 200, CLR_BLACK, 1, 1 )
	
	nIniV += nSalto + 5
	
	oPrinter:SayAlign( nIniV,  -100, STR0018                          , oFontTotGer, nFimH, 200, CLR_BLACK, 1, 1 ) //"SALDO FINAL ="
	oPrinter:SayAlign( nIniV, nIniH, FormatNum( nSaldoNat ), oFontTotGer, nFimH, 200, CLR_BLACK, 1, 1 )
	
	oPrinter:Line( nIniV + 12, 460, nIniV + 12, nFimH, 0, "-8")
	oPrinter:Line( nIniV + 14, 460, nIniV + 14, nFimH, 0, "-8")
	
Return Nil

//=======================================================================
/*/{Protheus.doc} PrintRepData
Imprime registros do relatório.

@param  oPrinter, objeto   , Estrutra do relatório
@param  nIniH	, numerico , Coordenada horizontal inicial
@param  nFimH	, numerico , Coordenada horizontal final

@author Jonatas Martins / Jorge Martins
@since  28/03/2018
/*/
//=======================================================================
Static Function PrintRepData( oPrinter, nIniH, nFimH )
Local oFontReg   := Nil
Local oFontCv    := Nil
Local cNatureza  := ""
Local cHist      := ""
Local cValorConv := ""
Local cValorLanc := ""
Local cCodEscrit := ""
Local cEscrit    := ""
Local cCodCCusto := ""
Local cCCusto    := ""
Local cFornec    := ""
Local nIniV      := 165
Local nRegPos    := 1
Local nValorLanc := 0
	
	oFontReg := TFont():New('Arial',,-7,,.F.,,,,,.F.,.F.)
	oFontCv  := TFont():New('Arial',,-6,,.F.,,,,,.F.,.F.)
	
	While (cAlsTmp)->( ! Eof() )
		//-----------------------
		// Avalia fim da página
		//----------------------- 
		EndPage( @oPrinter, nIniH, nFimH, @nIniV, @nRegPos, /*nNewIniV*/, /*lImpTitCol*/ )
		//-----------------------
		// Insere cor nas linhas
		//-----------------------
		ColorLine( @oPrinter, nIniH, nFimH, nIniV, nRegPos )
		//-----------------------
		// Imprime registros
		//-----------------------
		cHist := GetHistLanc( (cAlsTmp)->ORDEM , (cAlsTmp)->RECNO, (nIniH + nPColLanc) - (nIniH + nPColHist), oPrinter, oFontReg )
		cFornec := SubStrVRel(oPrinter,  AllTrim( (cAlsTmp)->A2_NOME ), nPColSol - nPColFor, oFontReg)

		oPrinter:Say( nIniV ,   nIniH + nPColData , cValToChar( StoD( (cAlsTmp)->DATA ) )   , oFontReg , 1200 ,/*color*/) //Data
		oPrinter:Say( nIniV ,   nIniH + nPColFor  , cFornec                                 , oFontReg , 1200 ,/*color*/) //Fornecedor		
		oPrinter:Say( nIniV ,   nIniH + nPColSol  , AllTrim( (cAlsTmp)->RD0_SIGLA )         , oFontReg , 1200 ,/*color*/) //Solic
		oPrinter:Say( nIniV ,   nIniH + nPColHist , IIF(__lAuto, "", cHist)                 , oFontReg , 1200 ,/*color*/) //Histórico # Quando for automação não valida texto do histórico
		oPrinter:Say( nIniV ,   nIniH + nPColLanc , (cAlsTmp)->DOCTO                        , oFontReg , 1200 ,/*color*/) //Lançamento
		oPrinter:Say( nIniV ,   nIniH + nPColNat  , (cAlsTmp)->NATUREZA2                    , oFontReg , 1200 ,/*color*/) //Natureza
		
		If (cAlsTmp)->VALOR_CONV <> 0
			nValorLanc := Round((cAlsTmp)->VALOR_CONV, IIf(_nDecValor > 0, _nDecValor, TamSx3("OHB_VALOR")[2]))
			cValorConv := "(" + AllTrim((cAlsTmp)->MOEDA_CONV) + " " + FormatNum( (cAlsTmp)->VALOR_LANC ) + ")" //Valor Convertido
			cValorLanc := FormatNum( nValorLanc ) // Valor na moeda da natureza
			
			oPrinter:SayAlign( nIniV - 7, -105 , cValorConv , oFontCv  , nFimH, 200, CLR_BLACK, 1, 1 )
			oPrinter:SayAlign( nIniV - 8, -60  , cValorLanc , oFontReg , nFimH, 200, CLR_BLACK, 1, 1 )
		Else
			nValorLanc := Round((cAlsTmp)->VALOR_LANC, IIf(_nDecValor > 0, _nDecValor, TamSx3("OHB_VALOR")[2]))
			cValorLanc := FormatNum( nValorLanc ) // Valor na moeda da natureza
			oPrinter:SayAlign( nIniV - 8, -60  , cValorLanc , oFontReg , nFimH, 200, CLR_BLACK, 1, 1 )
		EndIf 
		
		oPrinter:SayAlign( nIniV - 8, nIniH, FormatNum( nSaldoNat += nValorLanc ), oFontReg, nFimH, 200, CLR_BLACK, 1, 1 )  //Saldo
		
		cNatureza  := (cAlsTmp)->NATUREZA
		cCodEscrit := (cAlsTmp)->ESCRITORIO
		cEscrit    := (cAlsTmp)->NS7_NOME
		cCodCCusto := (cAlsTmp)->CENTRO_CUSTO
		cCCusto    := (cAlsTmp)->CTT_DESC01
		
		nSubTotEsc += nValorLanc            // Subtotal do escritório

		If nValorLanc < 0 
			nTotSaida += nValorLanc         // Total Geral de Saida
		Else
			nTotEnt   += nValorLanc         // Total Geral de Entrada
		EndIf
		nIniV      += nSalto                // Pula linha
		
		(cAlsTmp)->( DbSkip() )
		
		//-----------------------------
		// Avalia quebra de linha
		//-----------------------------
		IsBrokenRep( @oPrinter, nIniH, nFimH, @nIniV, @nRegPos, cNatureza, cCodEscrit, cEscrit, cCodCCusto, cCCusto )
	End

	//Imprime Subtotal da última sessão
	PrintSubTot( @oPrinter, nIniH, nFimH, @nIniV, cCodEscrit, cEscrit, cCodCCusto, cCCusto, cNatureza )
	
	//Imprime Total Geral
	PrintTotGer( @oPrinter, nIniH, nFimH, nIniV, cNatureza )

Return Nil

//=======================================================================
/*/{Protheus.doc} EndPage
Avalia quebra de página.

@param  oPrinter   , objeto     , Estrutra do relatório
@param  nIniH      , numerico   , Coordenada horizontal inicial
@param  nFimH      , numerico   , Coordenada horizontal final
@param  nIniV      , numerico   , Coordenada vertical inicial
@param  nRegPos    , numerico   , Contador de registros
@param  nNewIniV   , numerico   , Coordenada vertical que será verificada
@param  lImpTitCol , logico     , Indica se imprime os títulos das colunas
@param  lEndForced , logico     , Indica se deve ser forçada a quebra da página
                                  Usado quando existe mudança de natureza na impressão
@param  cNatureza  , caractere  , Codigo da natureza corrente de impressão

@author Jonatas Martins / Jorge Martins
@since  28/03/2018
/*/
//=======================================================================
Static Function EndPage( oPrinter, nIniH, nFimH, nIniV, nRegPos, nNewIniV, lImpTitCol, lEndForced, cNatureza )
	Local nIFimV       := 825  // Coordenada vertical final
	Local aRetNewNat   := {}
	Local lNovaNatur   := .F.
	Local cCodEscrit   := ""
	Local cEscrit      := ""
	Local cCodCCusto   := ""
	Local cCCusto      := ""
	Local cNatNewPag   := ""

	Default nRegPos    := 1
	Default nNewIniV   := 0
	Default lImpTitCol := .T.
	Default lEndForced := .F.
	Default cNatureza  := (cAlsTmp)->NATUREZA

	If lEndForced .Or. ( nIniV + nNewIniV ) >= nIFimV
		nIniV   := IIf(lImpTitCol, 165, 124 )
		nPage += 1
		oPrinter:EndPage()
		aRetNewNat := NewPage( @oPrinter, nIniH , nFimH, lImpTitCol, cNatureza )

		// IsNewNat está sendo chamada aqui, para evitar erro de recursão "stack depth overflow"
		If !Empty(aRetNewNat) .And. Len(aRetNewNat) >= 6
			lNovaNatur := aRetNewNat[1]
			cCodEscrit := aRetNewNat[2]
			cEscrit    := aRetNewNat[3]
			cCodCCusto := aRetNewNat[4]
			cCCusto    := aRetNewNat[5]
			cNatNewPag := aRetNewNat[6]

			If lNovaNatur
				IsNewNat( oPrinter, nIniH, nFimH, /*nIniV*/, /*nRegPos*/, cCodEscrit, cEscrit, cCodCCusto, cCCusto, cNatNewPag)
			EndIf
		EndIf
		nRegPos := 1
	EndIf

Return Nil

//=======================================================================
/*/{Protheus.doc} ColorLine
Muda cor da linha impressa.

@param   oPrinter, objeto   , Estrutra do relatório
@param   nIniH   , numerico , Coordenada horizontal inicial
@param   nFimH   , numerico , Coordenada horizontal final
@param   nIniV   , numerico , Coordenada vertical inicial
@param   nRegPos , numerico , Contador de registros
@param   lForce  , logico   , Força alterar cor da linha
@param   nColor  , numerico , Cor da linha

@author  Jonatas Martins / Jorge Martins
@since   28/03/2018
/*/
//=======================================================================
Static Function ColorLine( oPrinter, nIniH, nFimH, nIniV, nRegPos, lForce, nColor )
	Local aCoords   := {}
	Local oBrush    := Nil
	Local cPixel    := ""
	
	Default nRegPos := 1
	Default lForce  := .F.
	Default nColor  := RGB( 220, 220, 220 )
	
	//-----------------------------
	// Avalia se a linha é impar
	//-----------------------------
	If Mod( nRegPos, 2 ) == 0 .Or. lForce
		oBrush  := TBrush():New( Nil, nColor )
		aCoords := { nIniV - 8, nIniH, nIniV + 2, nFimH }
		cPixel  := "-2"
		oPrinter:FillRect( aCoords, oBrush, cPixel )
	EndIf
Return Nil

//=======================================================================
/*/{Protheus.doc} GetHistLanc
Pega histórico do lançamento - Utilizado no Modelo PDF

@param  nTpLanc   , Tipo do lançamento 1=Saldo Anterior; 2=Histórico Atual
@param  nRecno    , Recno do registro
@param  nTamCol   , Tamanho da Coluna
@param  oPrinter  , Classe do Printer
@param  oFontReg  , Classe da Fonte

@return cHistorico, Parte do histórico que poderá ser exibida no relatório

@author Jonatas Martins / Jorge Martins
@since  28/03/2018
/*/
//=======================================================================
Static Function GetHistLanc( nTpLanc, nRecno, nTamCol, oPrinter, oFontReg )
Local cHistorico := ""

	If nTpLanc == "1"
		cHistorico := STR0019 //"Saldo Anterior"
	Else
		cHistorico := SubStrVRel(oPrinter, HistLanc(nRecno), nTamCol, oFontReg)
	EndIf
Return ( cHistorico )


//=======================================================================
/*/{Protheus.doc} IsBrokenRep
Avalia quebra de relatório.

@param  oPrinter   , objeto     , Estrutra do relatório
@param  nIniH      , numerico   , Coordenada horizontal inicial
@param  nFimH      , numerico   , Coordenada horizontal final
@param  nIniV      , numerico   , Coordenada vertical inicial
@param  nRegPos    , numerico   , Contador de registros
@param  cNatureza  , caractere  , Natureza
@param  cCodEscrit , caractere  , Código do Escritório
@param  cEscrit    , caractere  , Nome do Escritório
@param  cCodCCusto , caractere  , Código do Centro de Custo
@param  cCCusto    , caractere  , Descrição do Centro de Custo

@author Jonatas Martins / Jorge Martins
@since  28/03/2018
/*/
//=======================================================================
Static Function IsBrokenRep( oPrinter, nIniH, nFimH, nIniV, nRegPos, cNatureza, cCodEscrit, cEscrit, cCodCCusto, cCCusto )
	Local cNovaNatur  := (cAlsTmp)->NATUREZA
	Local cNovoEscrit := (cAlsTmp)->ESCRITORIO
	Local cNovoCCusto := (cAlsTmp)->CENTRO_CUSTO

	//-----------------------------------------
	// Avalia quebra de página (Nova natureza)
	//-----------------------------------------
	If !Empty(cNovaNatur) .And. (cNatureza != cNovaNatur)
	
		// Imprime os totalizadores e quebra página para impressão da nova natureza
		IsNewNat( @oPrinter, nIniH, nFimH, @nIniV, nRegPos, cCodEscrit, cEscrit, cCodCCusto, cCCusto, cNatureza)

	//-------------------------------------------------------------
	// Avalia quebra de sessão (Novo Escritório / Centro de Custo)
	//-------------------------------------------------------------
	ElseIf (!Empty(cNovoEscrit) .Or. !Empty(cNovoCCusto)) .And. (cCodEscrit != cNovoEscrit .Or. cCodCCusto != cNovoCCusto)
		//------------------
		// Imprime subtotal
		//------------------
		PrintSubTot( @oPrinter, nIniH, nFimH, @nIniV, cCodEscrit, cEscrit, cCodCCusto, cCCusto, cNatureza )
		nRegPos    := 1 // Zera contador de registros
		nSubTotEsc := 0 // Zera subtotal por escritório
		nIniV      += ( 2 * nSalto )
		//---------------------------------------------------------------------
		// Avalia se existem mais registros a ser impressos e imprime colunas
		//---------------------------------------------------------------------
		If (cAlsTmp)->( ! Eof() )
			PrintTitCol( @oPrinter, nIniH, nFimH, @nIniV )
		EndIf
	Else
		nRegPos ++      // Incrementa contador de registros
	EndIf
	
Return Nil

//=======================================================================
/*/{Protheus.doc} FormatNum
Coloca separação decimal nos valores numéricos

@param  nValue  , numerico , Numero a ser formatado

@author Jonatas Martins / Jorge Martins
@since  28/03/2018
/*/
//=======================================================================
Static Function FormatNum( nValue )
	Local cNumber  := ""
	
	Default nValue := 0

	nValue := Round(nValue, IIf(_nDecValor > 0, _nDecValor, TamSx3("OHB_VALOR")[2]))
	
	cNumber := AllTrim( TransForm( nValue, PesqPict( "OHB", "OHB_VALOR" ) ) )

Return ( cNumber )

//=======================================================================
/*/{Protheus.doc} IsNewNat
Quebra página do relatório quando existe mudança de natureza.

@param  oPrinter   , objeto     , Estrutra do relatório
@param  nIniH      , numerico   , Coordenada horizontal inicial
@param  nFimH      , numerico   , Coordenada horizontal final
@param  nIniV      , numerico   , Coordenada vertical inicial
@param  nRegPos    , numerico   , Contador de registros
@param  cCodEscrit , caractere  , Código do Escritório
@param  cEscrit    , caractere  , Nome do Escritório
@param  cCodCCusto , caractere  , Código do Centro de Custo
@param  cCCusto    , caractere  , Descrição do Centro de Custo
@param  cNatureza  , caractere  , Codigo da natureza corrente de impressão

@author Jonatas Martins / Jorge Martins
@since  31/03/2018
/*/
//=======================================================================
Static Function IsNewNat( oPrinter, nIniH, nFimH, nIniV, nRegPos, cCodEscrit, cEscrit, cCodCCusto, cCCusto, cNatureza)

	Default nIniV   := 165
	Default nRegPos := 1

	//Imprime Subtotal da última sessão
	PrintSubTot( @oPrinter, nIniH, nFimH, @nIniV, cCodEscrit, cEscrit, cCodCCusto, cCCusto, cNatureza )

	//Imprime Total Geral
	PrintTotGer( @oPrinter, nIniH, nFimH, nIniV, cNatureza )
	
	// É necessário zerar os valores de totais, pois são totalizadores por natureza e houve mudança de natureza
	nSaldoNat  := 0 // Saldo da natureza
	nSubTotEsc := 0 // Subtotal por escritório
	nTotEnt    := 0 // Total Geral de Entrada
	nTotSaida  := 0 // Total Geral de Saida
	nRegPos    := 1 // Contador de registros

	If (cAlsTmp)->( !Eof() )
		cNatureza := Nil
	EndIf
	// Finaliza a página para troca de natureza
	EndPage( @oPrinter, nIniH, nFimH, @nIniV, nRegPos, /*nNewIniV*/, /*lImpTitCol*/, .T., cNatureza )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JP034VlDt
Valida data inicial e final

@param dDataIni , data, Data inicial do filtro
@param dDataFim , data, Data final do filtro

@return lRet, logico, T./.F. As informações são válidas ou não

@author Jonatas Martins / Jorge Martins
@since 30/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JP034VlDt(dDataIni, dDataFim)
Local lRet := .T.

If !Empty(dDataIni) .And. !Empty(dDataFim)

	If dDataIni > Date()
		JurMsgErro(STR0029,, STR0026) // "Data Final deve ser maior que a inicial." - "Informe uma data valida."
		lRet := .F.
	EndIf

	If dDataIni > dDataFim
		JurMsgErro(STR0025,, STR0026) // "Data Final deve ser maior que a inicial." - "Informe uma data valida."
		lRet := .F.
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JP034VlTpC
Validação do Tipo de conta - ED_TPCOJR

@param cTpConta, caractere, Valor informado no campo

@return lRet, logico, T./.F. As informações são válidas ou não

@author Jonatas Martins / Jorge Martins
@since 30/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JP034VlTpC(cTpConta)
Local lRet := .T.

If !Empty(cTpConta)
	lRet := JVldTpCont(cTpConta)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JP034VlNat
Validação do campo de natureza

@param cNatureza, Código da Natureza

@return lRet, logico, T./.F. As informações são válidas ou não

@author Bruno Ritter / Abner Fogaça
@since 19/07/2019
/*/
//-------------------------------------------------------------------
Function JP034VlNat(cNatureza, lShowMsg)
Local lRet := .T.
Default lShowMsg := .T.

	SED->( DbSetOrder( 1 ) )
	If !Empty(cNatureza) .And. !SED->(DbSeek(xFilial("SED") + AllTrim(cNatureza)))
		If (lShowMsg)
			JurMsgErro(I18N(STR0027, {cNatureza}), , STR0028) //"A natureza '#1' não foi localizada." //"Selecione uma natureza válida."
		EndIf
		lRet := .F.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JP034CsVal
Pedaço da query para retornar o valor correspodente do lançamento
na moeda da natureza.

@param cTpContTmp, GetTmpName da tabela temporária referente ao Tipo de contas
@param cOriNat   , Onde a natureza está no lançamento na query: O=Origem, D=Destino
@param lPerOH8   , Retorna o valor conforme o percentual na OH8 (Tabela de Rateio)
@param lVlMoeLanc, Retorna o valor do lançamento quando a moeda do lançamento é o
                   mesmo que a da natureza, se informar .F. retorna 0 nessa situação

@Return cQuery, Case para retorna o valor do lançamento na moeda da natureza

@author  Bruno Ritter
@since   17/10/2019
/*/
//-------------------------------------------------------------------
Static Function JP034CsVal(cTpContTmp, cOriNat, lPerOH8, lVlMoeLanc)
Local cQuery       := ""

Default lPerOH8    := .F.
Default lVlMoeLanc := .F.

	cQuery := " CASE WHEN OHB.OHB_CMOELC = SED.ED_CMOEJUR "
	If lVlMoeLanc
		If lPerOH8
			cQuery +=  " THEN ( (OHB.OHB_VALOR * OH8.OH8_PERCEN) / 100) "
		Else
			cQuery +=  " THEN OHB.OHB_VALOR "
		EndIf
		cQuery +=                         " * (SELECT SINAL FROM " + cTpContTmp + " "
		cQuery +=                             " WHERE CODIGO = SED.ED_TPCOJR AND TIPO = '" + cOriNat + "') "
	Else
		cQuery +=      " THEN 0 "
	EndIf

	cQuery +=      " WHEN OHB.OHB_CMOEC = SED.ED_CMOEJUR"
	If lPerOH8
		cQuery +=       " THEN ( (OHB.OHB_VALORC * OH8.OH8_PERCEN) / 100) "
	Else
		cQuery +=       " THEN  OHB.OHB_VALORC "
	EndIf
	cQuery +=                                 " * (SELECT SINAL FROM " + cTpContTmp + " "
	cQuery +=                                    "  WHERE CODIGO = SED.ED_TPCOJR AND TIPO = '" + cOriNat + "') "

	If lPerOH8
		cQuery +=  " ELSE ( (OHB.OHB_VLNAC * OH8.OH8_PERCEN) / 100) "
	Else
		cQuery +=  " ELSE  OHB.OHB_VLNAC "
	EndIf
	cQuery +=                         " * (SELECT SINAL FROM " + cTpContTmp + " "
	cQuery +=                             " WHERE CODIGO = SED.ED_TPCOJR AND TIPO = '" + cOriNat + "') "
	cQuery +=                         " * (SELECT CTP_TAXA FROM " + RetSqlName("CTP") + " CTP "
	cQuery +=                              " WHERE CTP_FILIAL = '" + xFilial("CTP") + "' "
	cQuery +=                                " AND CTP_DATA = OHB.OHB_DTLANC "
	cQuery +=                                " AND CTP_MOEDA = SED.ED_CMOEJUR) "
	cQuery += " END "

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} JP034VlPro()
Validação do campo do pergunte MV_PAR09 - Projeto/finalidade

@Return lRet, se o campo é válido

@author  Bruno Ritter
@since   30/10/2019
/*/
//-------------------------------------------------------------------
Function JP034VlPro(cProjeto)
	Local lRet := Empty(cProjeto) .Or. ExistCpo('OHL', cProjeto , 1)
	MV_PAR10 := Space(TamSx3("OHM_ITEM")[1]) // Limpa o campo de item do projeto
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JP034VlItm()
Validação do campo do pergunte MV_PAR10 - Item do projeto

@Return lRet, se o campo é válido

@author  Bruno Ritter
@since   30/10/2019
/*/
//-------------------------------------------------------------------
Function JP034VlItm(cProjeto, cItemPrj)
	Local lRet := ExistCpo('OHM', cProjeto + cItemPrj, 1)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CnvMultNat(cMultNat)
Converte a string de Multiplas Naturezas para a clausula IN das naturezas

@param cMultiNat - Naturezas Concatenadas divididas por ;

@Return cRet, Retorno da Clausula IN da Natureza 

@author  Willian Kazahaya
@since   27/06/2022
/*/
//-------------------------------------------------------------------
Static Function CnvMultNat(cMultiNat)
Local cRet      := ""
Local aMultiNat := JStrArrDst(cMultiNat, ";")
Local nI        := 0

	For nI := 1 to Len(aMultiNat)
		cRet += ",'" + aMultiNat[nI] + "'"
	Next nI

	If Len(cRet) > 0
		cRet := SubStr(cRet,2)
	EndIf
Return cRet

//=======================================================================
/*/{Protheus.doc} SubStrVRel(oPrinter, cValor, nTamCol, oFontReg)
Ajusta a descrição do campo para o Tamanho do campo no Relatório - Modelo PDF

@param oPrinter , Classe de Printer do Relatório PDF
@param cValor   , Valor a ser inputado no relatório
@param nTamCol  , Tamanho maximo da coluna 
@param oFontReg , Classe da Fonte para comparação do tamanho de fonte 

@return cRet , Parte do histórico que poderá ser exibida no relatório

@author Willian Kazahaya
@since  06/07/2022
/*/
//=======================================================================
Static Function SubStrVRel(oPrinter, cValor, nTamCol, oFontReg)
Local cRet     := cValor
Local nLength  := 58 // Necessário manter esse tamanho para garantir que não haja sobreposição quando o texto estiver em maiúsculo
Local nTamText := 0

	nTamText := oPrinter:GetTextWidth(cRet , oFontReg, 2)

	If nTamText > nTamCol
		//Vai retirando o caractere até retornar o tamanho da coluna
		Do While nTamText > nTamCol
			cRet := Left(cRet, nLength)
			nTamText := oPrinter:GetTextWidth(cRet + "..." , oFontReg, 2)
			nLength--
		EndDo

		cRet += "..."
	EndIf
Return cRet

//=======================================================================
/*/{Protheus.doc} HistLanc(nRecno)
Pega histórico do lançamento

@param  nRecno  , Recno do registro

@return cRet    , Histórico do Lançamento 

@author Willian Kazahaya
@since  06/07/2022
/*/
//=======================================================================
Static Function HistLanc(nRecno)
Local aArea      := GetArea()
Local aAreaOHB   := OHB->( GetArea() )
Local cRet := ""
	OHB->( DbGoTo( nRecno ) )

	cRet := StrTran(OHB->OHB_HISTOR, Chr(13) + Chr(10), " ") // Substitui a quebra de linhas dos textos por em espaço simples
	RestArea( aAreaOHB )
	RestArea( aArea )
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PrintXLSX(cNomeRel, cDataIni, cDataFim)
Cria o relatório de Extrato de Contas em XLSX

@param cNomeRel  - Nome do Relatório
@param cDataIni  - Data inicial 
@param cDataFim  - Data final

@Return lRet, Retorna o sucesso da operação

@author  Willian Kazahaya
@since   27/06/2022
/*/
//-------------------------------------------------------------------
Function PrintXLSX(cNomeRel, cDataIni, cDataFim)
Local lRet       := .T.
Local cDirectory := "\spool\"

	XLSXCreate(cDirectory + cNomeRel, cDataIni, cDataFim, cNomeRel)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} XLSXCreate(cCaminho, cDataIni, cDataFim, cNomeRel)
Cria o Relatório de Extrato de Contas por Centro de Custo no XLSX

@param cCaminho - Caminho para gerar o Excel
@param cDataIni - Data inicial 
@param cDataFim - Data final
@param cNomeRel - Nome do arquivo

@author  Willian Kazahaya
@since   27/06/2022
/*/
//-------------------------------------------------------------------
Static Function XLSXCreate(cCaminho, cDataIni, cDataFim, cNomeRel)
Local oPrtXlsx     := FwPrinterXlsx():New(.T.)
Local lRet         := .T.
Local cEDCodAtu    := ""
Local cValue       := ""
Local cValorConv   := ""
Local cCodEscri    := ""
Local cNomEscri    := ""
Local cCodCCusto   := ""
Local cNomCCusto   := ""
Local nIndexRow    := 1
Local nIndexCol    := 0
Local nSaldo       := 0
Local nValorLanc   := 0
Local nValTotEsc   := 0
Local nValTotCc    := 0
Local nValTotSai   := 0
Local nValTotEnt   := 0
Local nQtdLanCc    := 0
Local aEscCCVal    := {}
Local aCabCols     := {{STR0008, 13}, {STR0032, 40},; // Data       // Fornecedor
                       {STR0009, 14}, {STR0010, 75},; // Solic.     // Histórico
                       {STR0020, 15}, {STR0011, 25},; // Lançamento // Natureza
                       {STR0035, 15}, {STR0036, 20},; // Escritório // Centro de Custo
                       {STR0012, 15}, {STR0013, 15} } // Valor      // Saldo
                       // [1] - Descrição  [2] - Largura da Coluna

	//cAlsTmp -> Alias da variável estática com a query executada
	oPrtXlsx:Activate(cCaminho)

	While((cAlsTmp)->(!Eof()))
		nIndexCol := 1

		If (cEDCodAtu != (cAlsTmp)->NATUREZA) // Quando trocar a Natureza, cria um novo Worksheet e o cabeçalho
			If !Empty(cEDCodAtu) // Caso não seja a primeira pagina, inclui o footer antes de criar o novo Worksheet
				aAdd(aEscCCVal, {;
					cCodEscri,;
					cNomEscri,;
					nValTotEsc,;
					cCodCCusto,;
					cNomCCusto,;
					nValTotEsc,;
					nQtdLanCc;
				})

				// Inclui os Totalizadores por Escritório e Centro de Custo
				nIndexRow := xlsxFotEsc(@oPrtXlsx, nIndexRow, aEscCCVal)
				xlsxFooter(@oPrtXlsx, nIndexRow, nValTotEsc, nValTotEnt, nValTotSai, nSaldo, cCodEscri, cNomEscri, cCodCCusto, cNomCCusto)
				aSize(aEscCCVal,0)
				nQtdLanCc := 0
			EndIf

			nIndexRow  := 1
			nValTotEsc := 0
			nValTotCc  := 0
			nValTotSai := 0
			nValTotEnt := 0

			oPrtXlsx:AddSheet((cAlsTmp)->NATUREZA)
			nIndexRow := xlsMainCab(@oPrtXlsx, nIndexRow, cDataIni, cDataFim)
			nIndexRow++

			stFontStyle(@oPrtXlsx, "CAB_TABELA")
			xlsxTabCol(@oPrtXlsx, aCabCols, nIndexRow)

			nIndexRow++
			cEDCodAtu := (cAlsTmp)->NATUREZA
			nSaldo := (cAlsTmp)->SALDO

			stFontStyle(@oPrtXlsx)
			If ((cAlsTmp)->ORDEM == "1")
				(cAlsTmp)->( DbSkip() )
			EndIf
		Else
			// Inclui os dados do Escritório e Centro de Custo
			If (cCodEscri <> Trim((cAlsTmp)->ESCRITORIO)) .Or. (cCodCCusto <> Trim((cAlsTmp)->CENTRO_CUSTO))
				aAdd(aEscCCVal, {;
					cCodEscri,;
					cNomEscri,;
					nValTotEsc,;
					cCodCCusto,;
					cNomCCusto,;
					nValTotEsc,;
					nQtdLanCc;
				})

				nValTotEsc := 0
				nValTotCc  := 0

				cCodEscri  := Trim((cAlsTmp)->ESCRITORIO)
				cNomEscri  := Trim((cAlsTmp)->NS7_NOME)
				cCodCCusto := Trim((cAlsTmp)->CENTRO_CUSTO)
				cNomCCusto := Trim((cAlsTmp)->CTT_DESC01)
				nQtdLanCc  := 0
			EndIf
		
			// Data
			cValue := SToD((cAlsTmp)->DATA)
			stCellForm(@oPrtXlsx, ValType(cValue))
			oPrtXlsx:setValue(nIndexRow, nIndexCol++, DToC(cValue))

			// Fornecedor
			stCellForm(@oPrtXlsx, ValType((cAlsTmp)->A2_NOME))
			oPrtXlsx:setText(nIndexRow, nIndexCol++, (cAlsTmp)->A2_NOME )

			// Solic.
			stCellForm(@oPrtXlsx, ValType((cAlsTmp)->RD0_SIGLA))
			oPrtXlsx:setText(nIndexRow, nIndexCol++, (cAlsTmp)->RD0_SIGLA )

			// Histórico
			stCellForm(@oPrtXlsx, ValType(HistLanc((cAlsTmp)->RECNO )))
			oPrtXlsx:setText(nIndexRow, nIndexCol++, HistLanc((cAlsTmp)->RECNO ) )

			// Lançamento
			stCellForm(@oPrtXlsx, ValType((cAlsTmp)->DOCTO))
			oPrtXlsx:setText(nIndexRow, nIndexCol++, (cAlsTmp)->DOCTO )

			// Natureza e Valor
			If (cAlsTmp)->VALOR_CONV <> 0
				// O valor convertido esteja diferente significa que a moeda é diferente da moeda da natureza
				nValorLanc := Round((cAlsTmp)->VALOR_CONV, IIf(_nDecValor > 0, _nDecValor, TamSx3("OHB_VALOR")[2]))
				cValorConv := " (" + AllTrim((cAlsTmp)->MOEDA_CONV) + " " + FormatNum( (cAlsTmp)->VALOR_LANC ) + ")" //Valor Convertido

				// Natureza
				stCellForm(@oPrtXlsx, ValType((cAlsTmp)->NATUREZA2))
				oPrtXlsx:setText(nIndexRow, nIndexCol++, (cAlsTmp)->NATUREZA2 + cValorConv )
			Else
				// Natureza
				nValorLanc := (cAlsTmp)->VALOR_LANC
				stCellForm(@oPrtXlsx, ValType((cAlsTmp)->NATUREZA2))
				oPrtXlsx:setText(nIndexRow, nIndexCol++, (cAlsTmp)->NATUREZA2 )
			EndIf

			// Escritório
			stCellForm(@oPrtXlsx, ValType((cAlsTmp)->NS7_NOME))
			oPrtXlsx:setText(nIndexRow, nIndexCol++, (cAlsTmp)->NS7_NOME )

			// Centro de Custo
			stCellForm(@oPrtXlsx, ValType((cAlsTmp)->CTT_DESC01))
			oPrtXlsx:setText(nIndexRow, nIndexCol++, (cAlsTmp)->CTT_DESC01 )

			// Valor do Lançamento
			stCellForm(@oPrtXlsx, ValType((cAlsTmp)->VALOR_LANC))
			oPrtXlsx:SetNumber(nIndexRow, nIndexCol++, nValorLanc )

			// Saldo atual ( Soma do Saldo anterior + O valor do lançamento atual)
			nSaldo += (cAlsTmp)->VALOR_LANC
			stCellForm(@oPrtXlsx, ValType(nSaldo))
			oPrtXlsx:SetNumber(nIndexRow, nIndexCol++, nSaldo)

			// Sumariza os totalizadores
			nValTotEsc += nValorLanc            // Subtotal do escritório
			nValTotCc  += nValorLanc            // Subtotal do Centro de Custo

			If nValorLanc < 0 
				nValTotSai += nValorLanc         // Total Geral de Saida
			Else
				nValTotEnt   += nValorLanc         // Total Geral de Entrada
			EndIf
			
			nQtdLanCc++
			nIndexRow++
			(cAlsTmp)->( DbSkip() )
		EndIf
	EndDo

	// Inclui o Footer na ultima Worksheet
	If (nIndexRow > 0 )
		// Inclui os dados do Escritório e Centro de Custo
		aAdd(aEscCCVal, {;
			cCodEscri,;
			cNomEscri,;
			nValTotEsc,;
			cCodCCusto,;
			cNomCCusto,;
			nValTotEsc,;
			nQtdLanCc;
		})

		nIndexRow := xlsxFotEsc(@oPrtXlsx, nIndexRow, aEscCCVal)
		xlsxFooter(@oPrtXlsx, nIndexRow, nValTotEsc, nValTotEnt, nValTotSai, nSaldo, cCodEscri, cNomEscri, cCodCCusto, cNomCCusto)
		aSize(aEscCCVal,0)
	EndIf

	// Gera o XLSX
	oPrtXlsx:toXlsx()
	oPrtXlsx:DeActivate()

	oPrtXlsx := Nil

	openFile(cCaminho, ".xlsx",  cNomeRel)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} openFile(cCaminho, cFormato, cNomeRel)
Copia o arquivo gerado para abertura no Client

@param cCaminho  - Caminho original do arquivo
@param cNomeRel  - Nome do arquivo
@param cFormato  - Indica o formato / extensão do arquivo

@author  Willian Kazahaya
@since   27/06/2022
/*/
//-------------------------------------------------------------------
Static Function openFile(cCaminho, cFormato, cNomeRel)

Local nRet       := 0
Local cFunction  := "CpyS2TW"
Local lHtml      := (GetRemoteType() == 5) //Valida se o ambiente é SmartClientHtml
Local cTempPath  := GetTempPath() + 'totvsprinter\'

Default cFormato := ".xlsx"
Default cNomeRel := ""

	// Tratamento para S.O. Linux
	cCaminho  := JRepDirSO( cCaminho )
	cTempPath := JRepDirSO( cTempPath )

	If File( cCaminho + cFormato )

		FErase(cCaminho + ".rel") // Deleta o arquivo .rel da spool
		cCaminho := cCaminho + cFormato

		// Copia o arquivo da pasta onde esta o server para a pasta na máquina do usuário
		If !lHtml

			If (cCaminho) <> ( cTempPath )
				// Verifica se existe a pasta totvsprinter
				If !ExistDir( cTempPath )
					Makedir( cTempPath )
				EndIf

				CpyS2T( cCaminho, cTempPath)
			EndIf

		ElseIf FindFunction(cFunction)
			//Executa o download no navegador do cliente
			&(cFunction + '("' + cCaminho + '")')
		Endif
		
		//<------------------- Verifica se o usuário quer abrir o arquivo -------------->//
		If !lHtml .AND. ApMsgYesNo(STR0033) // "O relatório foi gerado com sucesso. Deseja abri-lo agora?"
			If !File( cTempPath + cNomeRel + cFormato )
				JurMsgErro(STR0048 + cTempPath + STR0039)  // "O arquivo " // " não pode ser aberto"
				Return
			Else
				nRet := ShellExecute( 'open', cTempPath + cNomeRel + cFormato , '', "C:\", 1 )
				If nRet <= 32
					JurMsgErro(STR0048 + StrTran(cCaminho, ".rel", ".xlsx") + STR0047)  // "O arquivo " #1 " não pode ser criado"
				EndIf
			EndIf
		EndIf
	Else
		JurMsgErro(STR0048 + StrTran(cCaminho, ".rel", ".xlsx") + STR0047)  // "O arquivo " #1 " não pode ser criado"
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} xlsxTabCol(oPrtXlsx, aCabCols, nIndexCab)
Cria o Header das colunas da tabela

@param oPrtXlsx  - Classe do Printer
@param aCabCols  - Colunas da tabela principal
@param nIndexCab - Indice da linha atual 

@author  Willian Kazahaya
@since   27/06/2022
/*/
//-------------------------------------------------------------------
Static Function xlsxTabCol(oPrtXlsx, aCabCols, nIndexCab)
Local nI   := 0
Local lRet := .T.

Default nIndexCab := 1

	oPrtXlsx:ApplyFormat(nIndexCab, Len(aCabCols))

	For nI := 1 to Len(aCabCols)
		oPrtXlsx:SetColumnsWidth(nI, nI, aCabCols[nI][2])
		oPrtXlsx:setText(nIndexCab, nI, aCabCols[nI][1])
	Next nI
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} xlsMainCab(oPrtXlsx, nIndexRow, cDataIni, cDataFim)
Inicia o Cabeçalho de Natureza da Planilha

@param oPrtXlsx  - Classe do Printer
@param nIndexRow - Indice da linha atual
@param cDataIni  - Data inicial 
@param cDataFim  - Data final 

@return nIndexRow - Retorna o Numero da linha atual

@author  Willian Kazahaya
@since   27/06/2022
/*/
//-------------------------------------------------------------------
Static Function xlsMainCab(oPrtXlsx, nIndexRow, cDataIni, cDataFim)
Local cMoeSED := JurGetDados( "SED" , 1 , xFilial("SED") + (cAlsTmp)->NATUREZA , {"ED_CMOEJUR"} )
Local cSimb     := JurGetDados( "CTO" , 1 , xFilial("CTO") + cMoeSED, "CTO_SIMB" )

	stFontStyle(@oPrtXlsx, "TITULO")
	oPrtXlsx:MergeCells(nIndexRow, 1, nIndexRow, 10)
	oPrtXlsx:setText(nIndexRow, 1, STR0003) //"Extrato de Contas (Centro de Custos) 
	nIndexRow++

	stFontStyle(@oPrtXlsx, "CAB_NATUREZA")
	oPrtXlsx:MergeCells(nIndexRow, 1, nIndexRow, 5)
	oPrtXlsx:setText(nIndexRow, 1, I18N(STR0004,  { SToD(cDataIni), SToD(cDataFim) })) //"Período de #1 à #2"

	oPrtXlsx:MergeCells(nIndexRow, 6, nIndexRow, 10)
	oPrtXlsx:setText(nIndexRow, 6,  I18N( STR0005, {  (cAlsTmp)->NS7_NOME } )) //"Escritório: #1"
	nIndexRow++

	stFontStyle(@oPrtXlsx, "CAB_NATUREZA")
	oPrtXlsx:MergeCells(nIndexRow, 1, nIndexRow,5)
	oPrtXlsx:setText(nIndexRow, 1, I18N( STR0006 , { Alltrim( (cAlsTmp)->NATUREZA ) , Alltrim( (cAlsTmp)->ED_DESCRIC ) , AllTrim( cSimb ) } )) //"Natureza: #1 - #2 (Valores em #3)"

	oPrtXlsx:setText(nIndexRow, 6, STR0019 + ": ")  //"Saldo Anterior"

	stCellForm(@oPrtXlsx, "N")
	oPrtXlsx:MergeCells(nIndexRow, 7, nIndexRow, 10)
	oPrtXlsx:setValue(nIndexRow, 7, (cAlsTmp)->SALDO)
	nIndexRow++

	oPrtXlsx:MergeCells(nIndexRow, 1, nIndexRow, 10)
Return nIndexRow

//-------------------------------------------------------------------
/*/{Protheus.doc} stFontStyle(oPrtXlsx, cTipo, aBorders)
Define as regras de estilo da Planilha

@param oPrtXlsx - Classe do Printer
@param cTipo    - Tipo de Estilo a ser utilizado
@param aBorders - Regra se deve colocar borda. Somente utilizado no Footer
		[1] Left
		[2] Top
		[3] Right
		[4] Bottom

@author  Willian Kazahaya
@since   27/06/2022
/*/
//-------------------------------------------------------------------
Static Function stFontStyle(oPrtXlsx, cTipo, aBorders)
Local lRet := .T.
Default cTipo    := "DETALHE"
Default aBorders := {} // [1] Left [2] Top [3] Right [4] Bottom

	Do Case

		Case cTipo == "TITULO"
			stCellForm(@oPrtXlsx, "C", cTipo)
			oPrtXlsx:SetBorder(.F./*lLeft*/, .T./*lTop*/, .F./*lRight*/, .T./*lBottom*/, FwXlsxBorderStyle():Medium()/*cStyle*/, "000000"/*cColor*/)
			oPrtXlsx:SetFont(FwPrinterFont():Arial(), 18, .F., .T., .F.)

		Case cTipo == "CAB_NATUREZA"
			stCellForm(@oPrtXlsx, "C", cTipo)
			oPrtXlsx:SetBorder(.F./*lLeft*/, .T./*lTop*/, .F./*lRight*/, .T./*lBottom*/, FwXlsxBorderStyle():Medium()/*cStyle*/, "FF0000"/*cColor*/)
			oPrtXlsx:SetFont(FwPrinterFont():Arial(), 12, .F., .T., .F.)

		Case cTipo == "CAB_TABELA"
			stCellForm(@oPrtXlsx, "C", cTipo)
			oPrtXlsx:SetBorder(.F./*lLeft*/, .T./*lTop*/, .F./*lRight*/, .T./*lBottom*/, FwXlsxBorderStyle():Medium()/*cStyle*/, "FF0000"/*cColor*/)
			oPrtXlsx:SetFont(FwPrinterFont():Arial(), 12, .F., .T., .F.)

		Case cTipo == "FOOTER"
			stCellForm(@oPrtXlsx, "", cTipo)
			oPrtXlsx:SetFont(FwPrinterFont():Arial(), 12, .F., .F., .F.)
			If Len(aBorders) > 0
				oPrtXlsx:SetBorder(aBorders[1]/*lLeft*/, aBorders[2]/*lTop*/, aBorders[3]/*lRight*/, aBorders[4]/*lBottom*/, FwXlsxBorderStyle():Medium()/*cStyle*/, "000000"/*cColor*/)
			Else
				oPrtXlsx:SetBorder(.F./*lLeft*/, .F./*lTop*/, .F./*lRight*/, .F./*lBottom*/, FwXlsxBorderStyle():None()/*cStyle*/, "FF0000"/*cColor*/)
			EndIf
		Otherwise
			stCellForm(@oPrtXlsx, "C", cTipo)
			oPrtXlsx:SetBorder(.T./*lLeft*/, .F./*lTop*/, .T./*lRight*/, .F./*lBottom*/, FwXlsxBorderStyle():Medium()/*cStyle*/, "FFFFFF"/*cColor*/)
			oPrtXlsx:SetFont(FwPrinterFont():Arial(), 10, .F., .F., .F.)

	EndCase
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} stCellForm(oPrtXlsx, cTpConteud, cRowTipo)
Estilização por Celula da Planilha

@param oPrtXlsx   - Classe do Printer
@param cTpConteud - Tipo do Conteudo. Utilizado para definir mascara
@param cRowTipo   - Tipo da Linha 

@author  Willian Kazahaya
@since   27/06/2022
/*/
//-------------------------------------------------------------------
Static Function stCellForm(oPrtXlsx, cTpConteud, cRowTipo)
Local lRet := .T.
Local cFormat      := ""
Local oCellHorAl   := FwXlsxCellAlignment():Horizontal()
Local oCellVerAl   := FwXlsxCellAlignment():Vertical()
Local cHorAlign    := oCellHorAl:Left()
Local cVertAlign   := oCellVerAl:Center()
Local cTextColor   := "000000" /*preto*/
Local cBgColor     := "FFFFFF"/*branco*/
Local lTextWrap    := .F.

Default cTpConteud := ""
Default cRowTipo   := ""

	Do Case
		Case cTpConteud == "D"
			cFormat := "dd/mm/yyyy"
		Case cTpConteud == "N"
			cFormat := "#,##0.00"
			cHorAlign := oCellHorAl:Right()
		Otherwise
			cFormat := ""
	EndCase

	Do Case 
		Case cRowTipo == "TITULO"
			cTextColor := "000000"/*branco*/
			cBgColor   := "FFFFFF"/*azul*/
			cHorAlign  := oCellHorAl:Center()
		Case cRowTipo == "FOOTER"
			cHorAlign  := oCellHorAl:Right()
		Otherwise
	EndCase

	lRet := oPrtXlsx:SetCellsFormat(cHorAlign, cVertAlign, lTextWrap, 0, cTextColor, cBgColor, cFormat)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} xlsxFooter(oPrtXlsx, nIndexRow, nValTotEsc, nValTotEnt, 
                             nValTotSai, nSaldo, cCodEscri, cNomEscri, 
                             cCodCCusto, cNomCCusto)
Implementa o Rodapé de cada Worksheet

@param oPrtXlsx   - Classe do Printer
@param nIndexRow  - Numero da Linha atual
@param nValTotEsc - Valor total do Escritório
@param nValTotEnt - Valor total de entrada
@param nValTotSai - Valor total de saida
@param nSaldo     - Valor total de saldo da natureza
@param cCodEscri  - Código do escritório
@param cNumEscri  - Nome do escritório
@param cCodCusto  - Código do Centro de Custo
@param cNomCCusto - Nome do Centro de Custo

@return lRet - Retorna se a operação ocorreu com sucesso

@author  Willian Kazahaya
@since   27/06/2022
/*/
//-------------------------------------------------------------------
Static Function xlsxFooter(oPrtXlsx, nIndexRow, nValTotEsc, nValTotEnt,;
                           nValTotSai, nSaldo, cCodEscri, cNomEscri,;
                           cCodCCusto, cNomCCusto)
Local lRet := .T.
	nIndexRow++

	// Total do Entrada [Label]
	stFontStyle(@oPrtXlsx, "FOOTER")
	oPrtXlsx:MergeCells(nIndexRow, 1, nIndexRow, 9)
	oPrtXlsx:setText(nIndexRow, 1, STR0016) //"TOTAL DE ENTRADA (+)"

	// Total do Entrada [Valor]
	stCellForm(@oPrtXlsx, "N")
	oPrtXlsx:setValue(nIndexRow, 10, nValTotEnt)
	nIndexRow++

	// Total do Saida [Label]
	stFontStyle(@oPrtXlsx, "FOOTER")
	oPrtXlsx:MergeCells(nIndexRow, 1, nIndexRow, 9)
	oPrtXlsx:setText(nIndexRow, 1, STR0017)  //"TOTAL DE SAIDA (-)"

	// Total do Saida [Valor]
	stCellForm(@oPrtXlsx, "N")
	oPrtXlsx:setValue(nIndexRow, 10, nValTotSai)
	nIndexRow++

	// Saldo Final[Label]
	stFontStyle(@oPrtXlsx, "FOOTER", { .F., .F., .F., .T.})
	oPrtXlsx:MergeCells(nIndexRow, 1, nIndexRow, 9)
	oPrtXlsx:setText(nIndexRow, 1, STR0018)  //"SALDO FINAL ="

	// Saldo Final [Valor]
	stCellForm(@oPrtXlsx, "N")
	oPrtXlsx:setValue(nIndexRow, 10, nSaldo)
	nIndexRow++
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} xlsxFotEsc(oPrtXlsx, nIndexRow, aEscCCVal)
Implementa os Totalizadores por Escritório e Centro de Custo

@param oPrtXlsx   - Classe do Printer
@param nIndexRow  - Numero da Linha atual
@param aEscCCVal  - Array dos Valores de Escritório e Centro de Custo
			[1] - Código Escritório
			[2] - Nome do Escritório
			[3] - Valor de Escritório
			[4] - Código do Centro de Custo
			[5] - Descrição do Centro de Custo
			[6] - Valor de Centro de Custo
			[7] - Quantidade de lançamentos

@return nIndexRow - Indice da ultima linha gerada

@author  Willian Kazahaya
@since   27/06/2022
/*/
//-------------------------------------------------------------------
Static Function xlsxFotEsc(oPrtXlsx, nIndexRow, aEscCCVal)
Local nI   := 0

	For nI := 1 To Len(aEscCCVal)
		// Linha em branco
		If (aEscCCVal[nI][7] > 0) .Or. (nI == Len(aEscCCVal))
			stFontStyle(@oPrtXlsx, "FOOTER", { .F., .T., .F., .T.})
			oPrtXlsx:MergeCells(nIndexRow, 1, nIndexRow, 10)
			nIndexRow++

			// Total do Escritório [Label]
			stFontStyle(@oPrtXlsx, "FOOTER")
			oPrtXlsx:MergeCells(nIndexRow, 1, nIndexRow, 9)
			oPrtXlsx:setText(nIndexRow, 1, I18N( STR0014, { "[" + aEscCCVal[nI][1] + "] - " + aEscCCVal[nI][2]  } )) //"Total do Escritório #1: "

			// Total do Escritório [Valor]
			stCellForm(@oPrtXlsx, "N")
			oPrtXlsx:setValue(nIndexRow, 10, aEscCCVal[nI][3])
			nIndexRow++

			// Total do Centro de Custo [Label]
			stFontStyle(@oPrtXlsx, "FOOTER", { .F., .F., .F., .T.})
			oPrtXlsx:MergeCells(nIndexRow, 1, nIndexRow, 9)
			oPrtXlsx:setText(nIndexRow, 1, I18N( STR0015, { " [" + aEscCCVal[nI][4] + "] - " + aEscCCVal[nI][5] } )) //"Total do Centro de Custo #1: "

			// Total do Escritório [Valor]
			stCellForm(@oPrtXlsx, "N")
			oPrtXlsx:setValue(nIndexRow, 10, aEscCCVal[nI][6])
			nIndexRow++
		EndIf
	Next nI
Return nIndexRow
