#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TOPCONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "JURAPAD038.CH"

#DEFINE _nSalto       10   // Salto de uma linha a outra

#DEFINE _nIniVEscrit  50                  // Coordenada vertical do Escritório do Relatório
#DEFINE _nIniVTitulo  50                  // Coordenada vertical do Título do Relatório
#DEFINE _nIniVCabec   _nIniVTitulo + 49   // Coordenada vertical inicial do cabeçalho do relatório (Tìtulos das colunas)
#DEFINE _nIniVDados   _nIniVCabec  + 23   // Coordenada vertical inicial dos dados do relatório

#DEFINE _nPCol02      100   // Coordenada vertical do campo NF
#DEFINE _nPCol03      -590  //     ''        ''    ''  ''   Emissão
#DEFINE _nPCol04      -540  //     ''        ''    ''  ''   Vencto.
#DEFINE _nPCol05      -480  //     ''        ''    ''  ''   Honorários
#DEFINE _nPCol06      -420  //     ''        ''    ''  ''   Desconto
#DEFINE _nPCol07      -360  //     ''        ''    ''  ''   IRRF
#DEFINE _nPCol08      -300  //     ''        ''    ''  ''   PIS
#DEFINE _nPCol09      -240  //     ''        ''    ''  ''   COFINS
#DEFINE _nPCol10      -180  //     ''        ''    ''  ''   CSLL
#DEFINE _nPCol11      -120  //     ''        ''    ''  ''   ISS
#DEFINE _nPCol12      -60   //     ''        ''    ''  ''   Desp
#DEFINE _nPCol13      0     //     ''        ''    ''  ''   Total Líq.

#DEFINE _nIniH        0     // Coordenada horizontal inicial
#DEFINE _nFimH        807.5 // Coordenada horizontal final
#DEFINE _nFimV        580   // Coordenada vertical final

#DEFINE _nIniTot      220   // Coordenada horizontal inicial da linha de total do sócio e total geral

Static _cAlsRpt     := ""
Static _cAnoMes     := ""
Static _cSimbMoeda  := ""
Static _cEscrit     := ""
Static _cHistCob    := ""
Static _nPage       := 1  // Contador de páginas
Static _aTotalCli   := {0,0,0,0,0,0,0,0,0}
Static _aTotalSoc   := {0,0,0,0,0,0,0,0,0}
Static _aTotalGeral := {0,0,0,0,0,0,0,0,0}
Static _cDateFt     := "" // Data - Footer
Static _cTimeFt     := "" // Hora - Footer
Static _cRazSocEsc  := "" // Razão Social do Escritório (Utilizado no topo do relatório)
Static _cIdEscrit   := "" // Código - Razão Social do Escritório (Utilizado no cabeçalho - Ex: SP001 - São Paulo)

//-------------------------------------------------------------------
/*/{Protheus.doc} JURAPAD038
Relatório de Faturas Pendentes

@param lAutomato, Indica se a chamada foi feita via automação
@param cNameFile, Nome do arquivo de relatório usado na automação

@author Jonatas Martins / Abner Fogaça / Jorge Martins
@since  26/07/2019
/*/
//-------------------------------------------------------------------
Function JURAPAD038(lAutomato, cNameFile)
	Local aArea     := GetArea()
	Local lCanc     := .F.
	Local bConfirma := Nil
	Local lPDUserAc := Iif(FindFunction("JPDUserAc"), JPDUserAc(), .T.) // Indica se o usuário possui acesso a dados sensíveis ou pessoais (LGPD)

	Default lAutomato := .F.
	Default cNameFile := "faturas_pend_" + FwTimeStamp(1)
	If lPDUserAc
		If OHH->(ColumnPos("OHH_SALDOD")) > 0 .And. OHH->(ColumnPos("OHH_NFELET")) > 0
			While !lCanc
				If JPergunte(lAutomato)
					If JP038TdOk(MV_PAR01, MV_PAR02, MV_PAR03, lAutomato)
						bConfirma := {|| JP038Relat(MV_PAR01, MV_PAR02, MV_PAR03, cValToChar((MV_PAR04)), cNameFile, lAutomato)}
						
						IIF(!lAutomato, ;
							FwMsgRun( , bConfirma , STR0002 , "" ) , ;
							( Eval(bConfirma), lCanc := .T.) ) //"Gerando relatório, aguarde..."
					EndIf
				Else
					lCanc := .T.
				Endif
			EndDo
		Else
			IIF(!lAutomato, ;
				JurMsgErro(I18N(STR0030, {RetTitle("OHH_SALDOD"), RetTitle("OHH_SALDOH"), RetTitle("OHH_NFELET")}), , STR0031),;
				 NIL) // "Os campos '#1', '#2' ou '#3' não foram encontrados na base!" ### "É necessário atualizar o ambiente."
		EndIf
	Else
		IIF(!lAutomato, ;
		MsgInfo(STR0032, STR0033), ;
		NIL) // "Usuário com restrição de acesso a dados pessoais/sensíveis.", "Acesso restrito"
	EndIf

	RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JPergunte
Abre o Pergunte para filtro do relatório

@param lAutomato, Indica se a chamada foi feita via automação

@author Jonatas Martins / Abner Fogaça / Jorge Martins
@since  26/07/2019
/*/
//-------------------------------------------------------------------
Static Function JPergunte(lAutomato)
	Local lRet := .T.

	If !lAutomato
		lRet := Pergunte('JURAPAD038')
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JP038TdOk
Rotina validar os dados do pergunte

@param  cAnomes  , Ano-mês informado
@param  cMoeda   , Moeda informada
@param  cEscrit  , Escritório informado
@param  lAutomato, Indica se a chamada foi feita via automação

@author Jonatas Martins / Abner Fogaça / Jorge Martins
@since  26/07/2019
/*/
//-------------------------------------------------------------------
Static Function JP038TdOk(cMoeda, cAnomes, cEscrit, lAutomato)
	Local lRet := .T.

	IIF( lRet := !Empty(cAnomes),;
		 NIL, ;
		 !lAutomato .AND. JurMsgErro(STR0003,, STR0004))  // "É necessário informar o ano-mês." "Informe o ano-mês."
		
	IIF( lRet := lRet .AND. !Empty(cMoeda),;
		 NIL,;
		 !lAutomato .AND.  JurMsgErro(STR0005,, STR0006) ) // "É necessário informar a moeda." "Informe a moeda."


	IIF( lRet := lRet .AND. !Empty(cEscrit),;
		 NIL, ;
		 !lAutomato .AND. JurMsgErro(STR0007,, STR0008) ) // "É necessário informar o escritório." "Informe o escritório."

Return lRet

//=======================================================================
/*/{Protheus.doc} JP038Relat
Relatório de Faturas Pendentes

@param  cMoeda     , Moeda do título
@param  cAnoMes    , Ano-mês do histórico de contas a receber
@param  cEscrit    , Escritório do título
@param  cHistCob   , Exibe Histórico de cobrança
@param  cReportName, Nome do arquivo de relatório
@param  lAutomato  , Indica se a chamada foi feita via automação

@author Jonatas Martins / Abner Fogaça / Jorge Martins
@since  26/07/2019
/*/
//=======================================================================
Static Function JP038Relat(cMoeda, cAnoMes, cEscrit, cHistCob, cReportName, lAutomato )
	Local cDirectory    := GetSrvProfString( "StartPath" , "" )
	Local cFilEscr      := JurGetDados( "NS7", 1, xFilial("NS7") + cEscrit, "NS7_CFILIA" )
	Local lRet          := .T.

	_cAnoMes    := Transform(cAnoMes, "@R XXXX-XX")
	_cSimbMoeda := JurGetDados('CTO', 1, xFilial('CTO') + cMoeda, 'CTO_SIMB')
	_cEscrit    := cEscrit
	_cHistCob   := cHistCob
	_aTotalSoc  := {0,0,0,0,0,0,0,0,0}
	_cDateFt    := IIF(!lAutomato, cValToChar( Date() ), "")
	_cTimeFt    := IIf(!lAutomato, Time(), "")

	// Busca dados no banco
	JReportQry(cMoeda, cAnoMes, cEscrit, cFilEscr, lAutomato)

	// Gera relatórios 
	If (_cAlsRpt)->( ! Eof() )

		_cRazSocEsc := AllTrim((_cAlsRpt)->NS7_RAZAO)
		_cIdEscrit  := AllTrim((_cAlsRpt)->NS7_COD + " - " + (_cAlsRpt)->NS7_RAZAO)

		PrintReport(cReportName , cDirectory, lAutomato)
	Else
		lRet := .F.
		IIF(!lAutomato, JurMsgError( STR0009 ), ) //"Não foram encontrados dados para impressão!"
	EndIf

	_nPage := 1 // Contador de páginas
	(_cAlsRpt)->( DbCloseArea() )

Return lRet

//=======================================================================
/*/{Protheus.doc} PrintReport
Função para gerar PDF do relatório de Faturas Pendentes

@param  cReportName, Nome do relatório
@param  cDirectory , Caminho da pasta
@param  lAutomato  , Indica se a chamada foi feita via automação

@author Jonatas Martins / Abner Fogaça / Jorge Martins
@since  26/07/2019
/*/
//=======================================================================
Static Function PrintReport(cReportName, cDirectory, lAutomato)
	Local oPrinter        := Nil
	Local cNameFile       := cReportName
	Local lAdjustToLegacy := .F.
	Local lDisableSetup   := .T.

	// Configurações do relatório
	If lAutomato
		oPrinter := FWMsPrinter():New( cNameFile, IMP_SPOOL,,, .T.,,,)
		oPrinter:CFILENAME  := cNameFile
		oPrinter:CFILEPRINT := oPrinter:CPATHPRINT + oPrinter:CFILENAME
	Else
		oPrinter := FWMsPrinter():New(cNameFile, IMP_PDF, lAdjustToLegacy, cDirectory, lDisableSetup,,, "PDF" )
		oPrinter:SetLandscape()
		oPrinter:SetPaperSize(DMPAPER_A4)
		oPrinter:SetMargin(60,60,60,60)
	EndIf

	//Gera nova folha
	NewPage(@oPrinter,,,lAutomato)

	//Imprime seção de escritório
	PrintRepData(@oPrinter, lAutomato)

	//Gera arquivo relatório
	oPrinter:Print()

Return Nil

//=======================================================================
/*/{Protheus.doc} NewPage
Cria nova página do relatório.

@param  oPrinter  , Estrutra do relatório
@param  lImpTitCol, Indica se imprime os títulos das colunas
@param  cSiglaSoc , Sigla do sócio corrente de impressão
@param  lAutomato , Indica se a chamada foi feita via automação

@author Jonatas Martins / Abner Fogaça / Jorge Martins
@since  26/07/2019
/*/
//=======================================================================
Static Function NewPage(oPrinter, lImpTitCol, cSiglaSoc, lAutomato)

	Default lImpTitCol := .T.
	Default cSiglaSoc  := (_cAlsRpt)->RD0_SIGLA

	//Inicio Página
	oPrinter:StartPage()

	//Monta cabeçalho
	PrintHead(@oPrinter)

	// Monta títulos das colunas
	If lImpTitCol
		PrintTitCol(@oPrinter, cSiglaSoc,lAutomato)
	EndIf

	//Imprime Rodapé
	PrintFooter(@oPrinter)

Return Nil

//=======================================================================
/*/{Protheus.doc} PrintHead
Imprime dados do cabeçalho.

@param  oPrinter  , Estrutra do relatório

@author Jonatas Martins / Abner Fogaça / Jorge Martins
@since  26/07/2019
/*/
//=======================================================================
Static Function PrintHead(oPrinter)
	Local oFontHead  := TFont():New('Arial',,-18,,.T.,,,,,.F.,.F.)
	Local oFontHead2 := TFont():New('Arial',,-10,,.F.,,,,,.F.,.F.)
	Local oFontHead3 := TFont():New('Arial',,-12,,.T.,,,,,.F.,.F.)
	
	// Título do relatório
	oPrinter:SayAlign( _nIniVTitulo, _nIniH, STR0010 + " - " + _cSimbMoeda, oFontHead, _nFimH, 200, CLR_BLACK, 2, 1 ) // "Faturas Pendentes"
	
	// Razão Social do Escritório
	oPrinter:Say( _nIniVEscrit, _nIniH , _cRazSocEsc, oFontHead3 )
	
	// Detalhes do filtro do relatório
	oPrinter:Line( _nIniVTitulo + 25, _nIniH, _nIniVTitulo + 25, _nFimH, CLR_HRED, "-8" )
	oPrinter:Say( _nIniVTitulo + 35, _nIniH , I18n( STR0011, { _cAnoMes } ), oFontHead2 ) //"Período: #1"
	oPrinter:SayAlign( _nIniVTitulo + 27, _nIniH, I18N( STR0012, { _cIdEscrit } ), oFontHead2, _nFimH, 200, CLR_BLACK, 1, 1 ) //"Escritório: #1"
	oPrinter:Line( _nIniVTitulo + 39, _nIniH, _nIniVTitulo + 39, _nFimH, CLR_HRED, "-8")

Return Nil

//=======================================================================
/*/{Protheus.doc} PrintTitCol
Imprime título das colunas do relatório.

@param  oPrinter , Estrutra do relatório
@param  cSiglaSoc, Sigla do sócio corrente de impressão
@param  lAutomato, Indica se a chamada foi feita via automação

@author Jonatas Martins / Abner Fogaça / Jorge Martins
@since  26/07/2019
/*/
//=======================================================================
Static Function PrintTitCol(oPrinter, cSiglaSoc, lAutomato)
	Local oFontTitCol := TFont():New('Arial',,-10,,.T.,,,,,.F.,.F.)
	Local nIniV       := _nIniVCabec

	// Avalia fim da página
	EndPage(@oPrinter, @nIniV, /*nRegPos*/, (4 * _nSalto), /*lImpTitCol*/, cSiglaSoc, , lAutomato)

	oPrinter:Say( nIniV += _nSalto, _nIniH  , STR0013, oFontTitCol )                               // "Fatura"
	oPrinter:Say( nIniV           , _nPCol02, STR0014, oFontTitCol )                               // "NF"
	oPrinter:SayAlign( nIniV - 8  , _nPCol03, STR0015, oFontTitCol, _nFimH, 200, CLR_BLACK, 1, 1 ) // "Emissão"
	oPrinter:SayAlign( nIniV - 8  , _nPCol04, STR0016, oFontTitCol, _nFimH, 200, CLR_BLACK, 1, 1 ) // "Vencto."
	oPrinter:SayAlign( nIniV - 8  , _nPCol05, STR0017, oFontTitCol, _nFimH, 200, CLR_BLACK, 1, 1 ) // "Honorários"
	oPrinter:SayAlign( nIniV - 8  , _nPCol06, STR0018, oFontTitCol, _nFimH, 200, CLR_BLACK, 1, 1 ) // "Desconto"
	oPrinter:SayAlign( nIniV - 8  , _nPCol07, STR0019, oFontTitCol, _nFimH, 200, CLR_BLACK, 1, 1 ) // "IRRF"
	oPrinter:SayAlign( nIniV - 8  , _nPCol08, STR0020, oFontTitCol, _nFimH, 200, CLR_BLACK, 1, 1 ) // "PIS"
	oPrinter:SayAlign( nIniV - 8  , _nPCol09, STR0021, oFontTitCol, _nFimH, 200, CLR_BLACK, 1, 1 ) // "COFINS"
	oPrinter:SayAlign( nIniV - 8  , _nPCol10, STR0022, oFontTitCol, _nFimH, 200, CLR_BLACK, 1, 1 ) // "CSLL"
	oPrinter:SayAlign( nIniV - 8  , _nPCol11, STR0023, oFontTitCol, _nFimH, 200, CLR_BLACK, 1, 1 ) // "ISS"
	oPrinter:SayAlign( nIniV - 8  , _nPCol12, STR0024, oFontTitCol, _nFimH, 200, CLR_BLACK, 1, 1 ) // "Desp." 
	oPrinter:SayAlign( nIniV - 8  , _nPCol13, STR0025, oFontTitCol, _nFimH, 200, CLR_BLACK, 1, 1 ) // "Total Líq."

	oPrinter:Line( nIniV += 4, _nIniH, nIniV, _nFimH, 0, "-8")
	nIniV += _nSalto

Return Nil

//=======================================================================
/*/{Protheus.doc} PrintFooter
Imprime rodapé do relatório.

@param  oPrinter, Estrutra do relatório

@author Jonatas Martins / Abner Fogaça / Jorge Martins
@since  26/07/2019
/*/
//=======================================================================
Static Function PrintFooter(oPrinter)
	Local oFontRod := TFont():New('Arial',,-10,,.F.,,,,,.F.,.F.)
	Local nLinRod  := 590

	oPrinter:Line( nLinRod, _nIniH, nLinRod, _nFimH, CLR_HRED, "-8")
	nLinRod += _nSalto
	oPrinter:SayAlign( nLinRod, _nIniH, _cDateFt + " - " + _cTimeFt, oFontRod, _nFimH, 200, CLR_BLACK, 2, 1 )
	oPrinter:SayAlign( nLinRod, _nIniH, cValToChar( _nPage )       , oFontRod, _nFimH, 200, CLR_BLACK, 1, 1 )

Return Nil

//=======================================================================
/*/{Protheus.doc} PrintRepData
Imprime registros do relatório.

@param  oPrinter , Estrutra do relatório
@param  lAutomato, Indica se a chamada foi feita via automação

@author Jonatas Martins / Abner Fogaça / Jorge Martins
@since  26/07/2019
/*/
//=======================================================================
Static Function PrintRepData(oPrinter, lAutomato)
	Local oFontReg    := TFont():New('Arial',,-7,,.F.,,,,,.F.,.F.)  // Fonte usada na impressão dos registros
	Local oFontSigla  := TFont():New('Arial',,-10,,.T.,,,,,.F.,.F.) // Fonte usada para impressão da SIGLA do sócio e cliente
	Local nIniV       := _nIniVDados
	Local nRegPos     := 1
	Local cSiglaSoc   := ""
	Local cNmClient   := ""
	Local cCliente    := ""
	Local cLoja       := ""
	Local cFatura     := ""
	Local cNF         := ""

	While (_cAlsRpt)->( ! Eof() )

		// Avalia fim da página
		EndPage(@oPrinter, @nIniV, @nRegPos, _nSalto,;
				 /*nNewIniV*/, , , lAutomato)

		// Insere cor nas linhas
		ColorLine(@oPrinter, nIniV, nRegPos)

		// Imprime sigla do sócio
		If cSiglaSoc  != (_cAlsRpt)->RD0_SIGLA
			oPrinter:Say( nIniV += 5, _nIniH , AllTrim((_cAlsRpt)->RD0_SIGLA) + " - " + (_cAlsRpt)->RD0_NOME, oFontSigla)
			nIniV += _nSalto
			
			cSiglaSoc := (_cAlsRpt)->RD0_SIGLA
		EndIf

		// Imprime nome do cliente
		If cCliente != (_cAlsRpt)->OHH_CCLIEN .Or. cLoja != (_cAlsRpt)->OHH_CLOJA
			
			EndPage(@oPrinter, @nIniV, @nRegPos, 2 * _nSalto,;
					 /*nNewIniV*/, , , lAutomato)
			
			cNmClient  := AllTrim(I18n(STR0026, {(_cAlsRpt)->OHH_CCLIEN, (_cAlsRpt)->OHH_CLOJA, (_cAlsRpt)->A1_NOME}))
			
			oPrinter:Line( nIniV     , _nIniH, nIniV, _nFimH, 0, "-8")
			oPrinter:Line( nIniV += 2, _nIniH, nIniV, _nFimH, 0, "-8")
			
			oPrinter:Say( nIniV += _nSalto, _nIniH , cNmClient, oFontSigla)
			
			oPrinter:Line( nIniV += 4, _nIniH, nIniV, _nFimH, 0, "-8")
			oPrinter:Line( nIniV += 2, _nIniH, nIniV, _nFimH, 0, "-8")
			nIniV += _nSalto

			cCliente := (_cAlsRpt)->OHH_CCLIEN
			cLoja    := (_cAlsRpt)->OHH_CLOJA
		EndIf

		cFatura := _cEscrit + " / " + (_cAlsRpt)->OHH_NUM
		If Empty(AllTrim((_cAlsRpt)->NXA_DOC) + AllTrim((_cAlsRpt)->NXA_SERIE))
			cNF := ""
		Else
			cNF := AllTrim((_cAlsRpt)->NXA_DOC) + " / " + AllTrim((_cAlsRpt)->NXA_SERIE)
		EndIf

		oPrinter:Say( nIniV, _nIniH  , cFatura , oFontReg)                                                                      // "Fatura"
		oPrinter:Say( nIniV, _nPCol02, cNF     , oFontReg)                                                                      // "NF"
		oPrinter:SayAlign( nIniV - 6, _nPCol03, DtoC(StoD( (_cAlsRpt)->NXA_DTEMI)  ) , oFontReg, _nFimH, 200, CLR_BLACK, 1, 1 ) // "Emissão"
		oPrinter:SayAlign( nIniV - 6, _nPCol04, DtoC(StoD( (_cAlsRpt)->NXA_DTVENC) ) , oFontReg, _nFimH, 200, CLR_BLACK, 1, 1 ) // "Vencto."
		oPrinter:SayAlign( nIniV - 6, _nPCol05, FormatNum( (_cAlsRpt)->HONORARIOS  ) , oFontReg, _nFimH, 200, CLR_BLACK, 1, 1 ) // "Honorários"
		oPrinter:SayAlign( nIniV - 6, _nPCol06, FormatNum( (_cAlsRpt)->DESCONTOS   ) , oFontReg, _nFimH, 200, CLR_BLACK, 1, 1 ) // "Desconto"
		oPrinter:SayAlign( nIniV - 6, _nPCol07, FormatNum( (_cAlsRpt)->IRRF        ) , oFontReg, _nFimH, 200, CLR_BLACK, 1, 1 ) // "IRRF"
		oPrinter:SayAlign( nIniV - 6, _nPCol08, FormatNum( (_cAlsRpt)->PIS         ) , oFontReg, _nFimH, 200, CLR_BLACK, 1, 1 ) // "PIS"
		oPrinter:SayAlign( nIniV - 6, _nPCol09, FormatNum( (_cAlsRpt)->COFINS      ) , oFontReg, _nFimH, 200, CLR_BLACK, 1, 1 ) // "COFINS"
		oPrinter:SayAlign( nIniV - 6, _nPCol10, FormatNum( (_cAlsRpt)->CSLL        ) , oFontReg, _nFimH, 200, CLR_BLACK, 1, 1 ) // "CSLL"
		oPrinter:SayAlign( nIniV - 6, _nPCol11, FormatNum( (_cAlsRpt)->ISS         ) , oFontReg, _nFimH, 200, CLR_BLACK, 1, 1 ) // "ISS"
		oPrinter:SayAlign( nIniV - 6, _nPCol12, FormatNum( (_cAlsRpt)->DESP        ) , oFontReg, _nFimH, 200, CLR_BLACK, 1, 1 ) // "Desp." 
		oPrinter:SayAlign( nIniV - 6, _nPCol13, FormatNum( (_cAlsRpt)->TOTLIQUIDO  ) , oFontReg, _nFimH, 200, CLR_BLACK, 1, 1 ) // "Total Líq."

		If _cHistCob == "1" // Verifica se existe histórico de cobrança
			PrintHist(@oPrinter, @nIniV, @nRegPos, lAutomato)
		EndIf

		_aTotalCli[1] += (_cAlsRpt)->HONORARIOS // "Honorários"
		_aTotalCli[2] += (_cAlsRpt)->DESCONTOS  // "Desconto"
		_aTotalCli[3] += (_cAlsRpt)->IRRF       // "IRRF"
		_aTotalCli[4] += (_cAlsRpt)->PIS        // "PIS"
		_aTotalCli[5] += (_cAlsRpt)->COFINS     // "COFINS"
		_aTotalCli[6] += (_cAlsRpt)->CSLL       // "CSLL"
		_aTotalCli[7] += (_cAlsRpt)->ISS        // "ISS"
		_aTotalCli[8] += (_cAlsRpt)->DESP       // "Desp." 
		_aTotalCli[9] += (_cAlsRpt)->TOTLIQUIDO // "Total Líq."

		nIniV  += _nSalto // Pula linha

		(_cAlsRpt)->( DbSkip() )

		// Avalia quebra de linha
		IsBrokenRep( @oPrinter, @nIniV, @nRegPos, cSiglaSoc, cCliente, cLoja, lAutomato )
		
	EndDo

	// Imprime Total por Sócio
	PrintTotSoc(@oPrinter, @nIniV, cSiglaSoc, lAutomato)

	//Imprime Total Geral
	PrintTotGer(@oPrinter, nIniV, cSiglaSoc, lAutomato)

Return Nil

//=======================================================================
/*/{Protheus.doc} PrintHist
Imprime histórico de cobrança.

@param  oPrinter , Estrutra do relatório
@param  nIniV    , Coordenada vertical inicial
@param  nRegPos  , Contador de registros
@param  lAutomato, Indica se a chamada foi feita via automação

@author Jonatas Martins / Abner Fogaça / Jorge Martins
@since  26/07/2019
/*/
//=======================================================================
Static Function PrintHist(oPrinter, nIniV, nRegPos, lAutomato)
	Local aAreaOHD   := OHD->( GetArea() )
	Local cAlsOHD    := GetNextAlias()
	Local oFontReg   := TFont():New('Arial',,-7,,.F.,,,,,.F.,.F.)  // Fonte usada na impressão dos registros
	Local cQueryOHD  := ""
	Local cHistCob   := ""
	Local cHistLin   := ""
	Local cFilTit    := (_cAlsRpt)->OHH_FILIAL
	Local cPrefixo   := (_cAlsRpt)->OHH_PREFIX
	Local cNumTit    := (_cAlsRpt)->OHH_NUM
	Local cTipo      := (_cAlsRpt)->OHH_TIPO
	Local nPalavras  := 0
	Local nRegAtu    := nRegPos // Guarda número do registro atual, para caso houver quebra de página não se perder
	Local aHistCob   := {}

	cQueryOHD := "SELECT OHD.R_E_C_N_O_ RECNO " + CRLF
	cQueryOHD +=   "FROM " + RetSqlName("OHD") + " OHD "
	cQueryOHD +=  "WHERE OHD.OHD_FILIAL = '" + cFilTit + "' "
	cQueryOHD +=    "AND OHD.OHD_PREFIX = '" + cPrefixo + "' "
	cQueryOHD +=    "AND OHD.OHD_NUM = '" + cNumTit + "' "
	cQueryOHD +=    "AND OHD.OHD_TIPO = '" + cTipo + "' "
	cQueryOHD +=    "AND OHD.D_E_L_E_T_ = ' ' "
	cQueryOHD +=  "ORDER BY OHD.OHD_DTACAO "
	
	cQuery   := ChangeQuery(cQueryOHD)
	DbUseArea( .T., "TOPCONN", TcGenQry( , , cQueryOHD ), cAlsOHD, .T., .T. )

	If (cAlsOHD)->( ! EOF() )
		While (cAlsOHD)->( ! EOF() )
			OHD->( DbGoTo( (cAlsOHD)->RECNO ) )
			
			cHistCob := I18N(STR0027, {cValToChar(OHD->OHD_DTACAO)}) + AllTrim(OHD->OHD_ACAO) // "Histórico de #1: "

			cHistCob := StrTran(cHistCob, Chr(13) + Chr(10), " ") // Troca os Retornos de carro + quebras de linhas por espaço
			cHistCob := StrTran(cHistCob, Chr(10), " ") // Troca as quebras de linha por espaço
			cHistCob := StrTran(cHistCob, Chr(9), " ") // Troca as tabulações por espaço
		
			nIniV    += _nSalto // Pula linha

			// Insere cor na linha antes dos históricos
			ColorLine(@oPrinter, nIniV, nRegAtu)

			aHistCob := STRTOKARR(cHistCob, " ") // Quebra palavras do histórico em um array

			For nPalavras := 1 To Len(aHistCob)
				If lAutomato .OR. Len(cHistLin + aHistCob[nPalavras]) <= 270 // Se a palavra atual for impressa e NÃO passar do limite de tamanho da linha
					cHistLin += aHistCob[nPalavras] + " " // Preenche a linha com a palavra atual

					If nPalavras == Len(aHistCob) // Caso esteja na última palavra
						// Avalia fim da página
						EndPage(@oPrinter, @nIniV, @nRegPos, _nSalto,;
						       ,  , , lAutomato)
						
						ColorLine(@oPrinter, nIniV += _nSalto, nRegAtu) // Insere cor na linha
						oPrinter:Say(nIniV, _nIniH, cHistLin, oFontReg)
						cHistLin := ""
					EndIf
				Else
					// Avalia fim da página
					EndPage(@oPrinter, @nIniV, @nRegPos, _nSalto,;
					        , , , lAutomato)

					ColorLine(@oPrinter, nIniV += _nSalto, nRegAtu) // Insere cor na linha
					oPrinter:Say(nIniV, _nIniH, cHistLin, oFontReg)
					cHistLin := aHistCob[nPalavras] + " "
				EndIf
			Next

			(cAlsOHD)->( DbSkip() )
		EndDo

		ColorLine(@oPrinter, nIniV += _nSalto, nRegAtu) // Insere cor na última linha após os históricos

	EndIf

	// Ajusta posição para imprimir o próximo registro com a linha na cor correta
	// É necessário atualizar o nRegPos quando o histórico de um registro ficar dividido em 2 páginas
	If nRegAtu != nRegPos
		If nRegPos == 1 .And. Mod(nRegAtu, 2) == 0
			nRegPos := 2
		EndIf
	EndIf

	(cAlsOHD)->( DbCloseArea() )

	JurFreeArr(@aHistCob)

	RestArea( aAreaOHD )

Return Nil

//=======================================================================
/*/{Protheus.doc} PrintTotCli
Imprime subtotal na quebra por Cliente.

@param  oPrinter   , Estrutra do relatório
@param  nIniV      , Coordenada vertical inicial
@param  cCliente   , Código do Cliente corrente de impressão
@param  cLoja      , Código da Loja do Cliente corrente de impressão
@param  lAutomato  , Indica se a chamada foi feita via automação

@author Jonatas Martins / Abner Fogaça / Jorge Martins
@since  26/07/2019
/*/
//=======================================================================
Static Function PrintTotCli(oPrinter, nIniV, cCliente, cLoja, lAutomato)
	Local oFontSubTot := TFont():New('Arial',,-10,,.T.,,,,,.F.,.F.)
	Local nVal        := 0

	// Avalia fim da página
	EndPage(@oPrinter, @nIniV, /*nRegPos*/, (2 * _nSalto),;
	                      /*lImpTitCol*/, /*cSiglaSoc*/, , lAutomato)

	oPrinter:Line( nIniV - 4, _nIniH, nIniV - 4, _nFimH, 0, "-8")
	oPrinter:SayAlign( nIniV, _nPCol05, FormatNum(_aTotalCli[1]), oFontSubTot, _nFimH, 200, CLR_BLACK, 1, 1 ) // "Honorários"
	oPrinter:SayAlign( nIniV, _nPCol06, FormatNum(_aTotalCli[2]), oFontSubTot, _nFimH, 200, CLR_BLACK, 1, 1 ) // "Desconto"
	oPrinter:SayAlign( nIniV, _nPCol07, FormatNum(_aTotalCli[3]), oFontSubTot, _nFimH, 200, CLR_BLACK, 1, 1 ) // "IRRF"
	oPrinter:SayAlign( nIniV, _nPCol08, FormatNum(_aTotalCli[4]), oFontSubTot, _nFimH, 200, CLR_BLACK, 1, 1 ) // "PIS"
	oPrinter:SayAlign( nIniV, _nPCol09, FormatNum(_aTotalCli[5]), oFontSubTot, _nFimH, 200, CLR_BLACK, 1, 1 ) // "COFINS"
	oPrinter:SayAlign( nIniV, _nPCol10, FormatNum(_aTotalCli[6]), oFontSubTot, _nFimH, 200, CLR_BLACK, 1, 1 ) // "CSLL"
	oPrinter:SayAlign( nIniV, _nPCol11, FormatNum(_aTotalCli[7]), oFontSubTot, _nFimH, 200, CLR_BLACK, 1, 1 ) // "ISS"
	oPrinter:SayAlign( nIniV, _nPCol12, FormatNum(_aTotalCli[8]), oFontSubTot, _nFimH, 200, CLR_BLACK, 1, 1 ) // "Desp." 
	oPrinter:SayAlign( nIniV, _nPCol13, FormatNum(_aTotalCli[9]), oFontSubTot, _nFimH, 200, CLR_BLACK, 1, 1 ) // "Total Líq."

	For nVal := 1 To Len(_aTotalCli)
		_aTotalSoc[nVal] += _aTotalCli[nVal]
	Next nVal

	// Limpa o subtotal de cliente
	_aTotalCli := {0,0,0,0,0,0,0,0,0}

	nIniV += 2 * _nSalto 

Return Nil

//=======================================================================
/*/{Protheus.doc} PrintTotSoc
Imprime subtotal na quebra por sócio.

@param  oPrinter   , Estrutra do relatório
@param  nIniV      , Coordenada vertical inicial
@param  cSiglaSoc  , Sigla do sócio corrente de impressão
@param  lAutomato  , Indica se a chamada foi feita via automação

@author Jonatas Martins / Abner Fogaça / Jorge Martins
@since  26/07/2019
/*/
//=======================================================================
Static Function PrintTotSoc(oPrinter, nIniV, cSiglaSoc, lAutomato)
	Local oFontSubTot := TFont():New('Arial',,-10,,.T.,,,,,.F.,.F.)
	Local nVal        := 0
	
	// Avalia fim da página
	EndPage(@oPrinter, @nIniV, /*nRegPos*/, (3 * _nSalto), ;
	                  /*lImpTitCol*/, cSiglaSoc, , lAutomato)

	nIniV += _nSalto + 5

	oPrinter:Line( nIniV - 4, _nIniTot, nIniV - 4, _nFimH, 0, "-8")
	oPrinter:SayAlign( nIniV, _nPCol04, I18N( STR0028, { AllTrim( cSiglaSoc ) } ), oFontSubTot, _nFimH, 200, CLR_BLACK, 1, 1 ) // "Total #1"
	oPrinter:SayAlign( nIniV, _nPCol05, FormatNum(_aTotalSoc[1]),  oFontSubTot, _nFimH, 200, CLR_BLACK, 1, 1 ) // "Honorários"
	oPrinter:SayAlign( nIniV, _nPCol06, FormatNum(_aTotalSoc[2]),  oFontSubTot, _nFimH, 200, CLR_BLACK, 1, 1 ) // "Desconto"
	oPrinter:SayAlign( nIniV, _nPCol07, FormatNum(_aTotalSoc[3]),  oFontSubTot, _nFimH, 200, CLR_BLACK, 1, 1 ) // "IRRF"
	oPrinter:SayAlign( nIniV, _nPCol08, FormatNum(_aTotalSoc[4]),  oFontSubTot, _nFimH, 200, CLR_BLACK, 1, 1 ) // "PIS"
	oPrinter:SayAlign( nIniV, _nPCol09, FormatNum(_aTotalSoc[5]),  oFontSubTot, _nFimH, 200, CLR_BLACK, 1, 1 ) // "COFINS"
	oPrinter:SayAlign( nIniV, _nPCol10, FormatNum(_aTotalSoc[6]),  oFontSubTot, _nFimH, 200, CLR_BLACK, 1, 1 ) // "CSLL"
	oPrinter:SayAlign( nIniV, _nPCol11, FormatNum(_aTotalSoc[7]),  oFontSubTot, _nFimH, 200, CLR_BLACK, 1, 1 ) // "ISS"
	oPrinter:SayAlign( nIniV, _nPCol12, FormatNum(_aTotalSoc[8]),  oFontSubTot, _nFimH, 200, CLR_BLACK, 1, 1 ) // "Desp." 
	oPrinter:SayAlign( nIniV, _nPCol13, FormatNum(_aTotalSoc[9]),  oFontSubTot, _nFimH, 200, CLR_BLACK, 1, 1 ) // "Total Líq."

	For nVal := 1 To Len(_aTotalSoc)
		_aTotalGeral[nVal] += _aTotalSoc[nVal]
	Next nVal

	// Limpa o subtotal
	_aTotalSoc := {0,0,0,0,0,0,0,0,0}

	nIniV += _nSalto

Return Nil

//=======================================================================
/*/{Protheus.doc} PrintTotGer
Imprime Total Geral

@param  oPrinter  , Estrutra do relatório
@param  nIniV     , Coordenada vertical inicial
@param  cSiglaSoc , Sigla do sócio corrente de impressão
@param  lAutomato , Indica se a chamada foi feita via automação

@author Jonatas Martins / Abner Fogaça / Jorge Martins
@since  26/07/2019
/*/
//=======================================================================
Static Function PrintTotGer(oPrinter, nIniV, cSiglaSoc, lAutomato)
	Local oFontTotGer := TFont():New('Arial',,-11,,.T.,,,,,.F.,.F.)

	// Avalia fim da página
	EndPage( @oPrinter, @nIniV , /*nRegPos*/ , (3 * _nSalto),;
			 .F. /*lImpTitCol*/, cSiglaSoc, , lAutomato)

	nIniV += (2 * _nSalto)

	oPrinter:Box( nIniV-5, _nIniTot, (nIniV+15), _nFimH + 5, "-4" )

	oPrinter:SayAlign( nIniV, _nPCol04, STR0029, oFontTotGer, _nFimH, 200, CLR_BLACK, 1, 1 ) // "Total Geral"
	oPrinter:SayAlign( nIniV, _nPCol05, FormatNum(_aTotalGeral[1]), oFontTotGer, _nFimH, 200, CLR_BLACK, 1, 1 ) // "Honorários"
	oPrinter:SayAlign( nIniV, _nPCol06, FormatNum(_aTotalGeral[2]), oFontTotGer, _nFimH, 200, CLR_BLACK, 1, 1 ) // "Desconto"
	oPrinter:SayAlign( nIniV, _nPCol07, FormatNum(_aTotalGeral[3]), oFontTotGer, _nFimH, 200, CLR_BLACK, 1, 1 ) // "IRRF"
	oPrinter:SayAlign( nIniV, _nPCol08, FormatNum(_aTotalGeral[4]), oFontTotGer, _nFimH, 200, CLR_BLACK, 1, 1 ) // "PIS"
	oPrinter:SayAlign( nIniV, _nPCol09, FormatNum(_aTotalGeral[5]), oFontTotGer, _nFimH, 200, CLR_BLACK, 1, 1 ) // "COFINS"
	oPrinter:SayAlign( nIniV, _nPCol10, FormatNum(_aTotalGeral[6]), oFontTotGer, _nFimH, 200, CLR_BLACK, 1, 1 ) // "CSLL"
	oPrinter:SayAlign( nIniV, _nPCol11, FormatNum(_aTotalGeral[7]), oFontTotGer, _nFimH, 200, CLR_BLACK, 1, 1 ) // "ISS"
	oPrinter:SayAlign( nIniV, _nPCol12, FormatNum(_aTotalGeral[8]), oFontTotGer, _nFimH, 200, CLR_BLACK, 1, 1 ) // "Desp." 
	oPrinter:SayAlign( nIniV, _nPCol13, FormatNum(_aTotalGeral[9]), oFontTotGer, _nFimH, 200, CLR_BLACK, 1, 1 ) // "Total Líq."

	_aTotalGeral := {0,0,0,0,0,0,0,0,0}

Return Nil

//=======================================================================
/*/{Protheus.doc} EndPage
Avalia quebra de página.

@param  oPrinter  , Estrutra do relatório
@param  nIniV     , Coordenada vertical inicial
@param  nRegPos   , Contador de registros
@param  nNewIniV  , Coordenada vertical que será verificada
@param  lImpTitCol, Indica se imprime os títulos das colunas
@param  cSiglaSoc , Sigla do sócio corrente de impressão
@param  lEndForced, Indica se deve ser forçada a quebra da página
                    Usado quando existe mudança de sócio ou escritório
                    na impressão
@param  lAutomato , Indica se a chamada foi feita via automação

@author Jonatas Martins / Abner Fogaça / Jorge Martins
@since  26/07/2019
/*/
//=======================================================================
Static Function EndPage(oPrinter, nIniV, nRegPos, nNewIniV, ;
						lImpTitCol, cSiglaSoc, lEndForced, lAutomato)

	Default nRegPos    := 1
	Default nNewIniV   := 0
	Default lImpTitCol := .T.
	Default lEndForced := .F.
	Default cSiglaSoc  := (_cAlsRpt)->RD0_SIGLA

	If lEndForced .Or. (!lAutomato .AND.  ( nIniV + nNewIniV ) >= _nFimV)
		nIniV := _nIniVDados
		_nPage += 1
		oPrinter:EndPage()
		NewPage(@oPrinter, lImpTitCol, cSiglaSoc)
		nRegPos := 1
	EndIf

Return Nil

//=======================================================================
/*/{Protheus.doc} ColorLine
Muda cor da linha impressa.

@param   oPrinter, Estrutra do relatório
@param   nIniV   , Coordenada vertical inicial
@param   nRegPos , Contador de registros
@param   lForce  , Força alterar cor da linha
@param   nColor  , Cor da linha

@author  Jonatas Martins / Jorge Martins
@since   28/03/2018
/*/
//=======================================================================
Static Function ColorLine(oPrinter, nIniV, nRegPos, lForce, nColor)
	Local aCoords    := {}
	Local oBrush     := Nil
	Local cPixel     := ""

	Default nRegPos  := 1
	Default lForce   := .F.
	Default nColor   := RGB( 224, 224, 224 )
	Default nQtdLine := 0

	// Avalia se a linha é impar
	If Mod( nRegPos , 2 ) == 0 .Or. lForce
		oBrush  :=  TBrush():New( Nil , nColor )
		aCoords := { nIniV - 7, _nIniH , nIniV + 3, _nFimH }
		cPixel  := "-2"
		oPrinter:FillRect( aCoords , oBrush , cPixel )
	EndIf

Return Nil

//=======================================================================
/*/{Protheus.doc} IsBrokenRep
Avalia quebra de relatório.
Realiza quebra quando houver mudança no sócio ou escritório

@param  oPrinter , Estrutra do relatório
@param  nIniV    , Coordenada vertical inicial
@param  nRegPos  , Contador de registros
@param  cSiglaSoc, Sigla do sócio
@param  cCliente , Código do Cliente
@param  cLoja    , Código da Loja do Cliente
@param  lAutomato, Indica se a chamada foi feita via automação

@author Jonatas Martins / Abner Fogaça / Jorge Martins
@since  26/07/2019
/*/
//=======================================================================
Static Function IsBrokenRep(oPrinter, nIniV, nRegPos, cSiglaSoc, cCliente, cLoja, lAutomato)
	Local cNovaSigla := (_cAlsRpt)->RD0_SIGLA
	Local cNovoCli   := (_cAlsRpt)->OHH_CCLIEN
	Local cNovaLoja  := (_cAlsRpt)->OHH_CLOJA

	If (!Empty(cNovoCli) .And. cNovoCli != cCliente) .Or. (!Empty(cLoja) .And. cNovaLoja != cLoja)
		PrintTotCli(@oPrinter, @nIniV, cCliente, cLoja, lAutomato)
		nRegPos := 0
	EndIf

	// Avalia quebra de página (Novo Sócio ou Escritório)
	If !Empty(cNovaSigla) .And. cSiglaSoc != cNovaSigla
		// Imprime os totalizadores e quebra página para impressão do novo Sócio
		IsNewPage(@oPrinter, @nIniV, @nRegPos, cSiglaSoc, lAutomato)
	Else
		nRegPos += 1 // Incrementa contador de registros
	EndIf

Return Nil

//=======================================================================
/*/{Protheus.doc} FormatNum
Coloca separação decimal nos valores numéricos

@param  nValue, Numero a ser formatado

@author Jonatas Martins / Abner Fogaça / Jorge Martins
@since  26/07/2019
/*/
//=======================================================================
Static Function FormatNum( nValue )
	Local cNumber  := ""

	Default nValue := 0

	cNumber := AllTrim( TransForm( nValue, PesqPict( "OHH", "OHH_SALDO" ) ) )

Return cNumber

//=======================================================================
/*/{Protheus.doc} IsNewPage
Quebra página do relatório quando existe mudança de sócio ou escritório.

@param  oPrinter , Estrutra do relatório
@param  nIniV    , Coordenada vertical inicial
@param  nRegPos  , Contador de registros
@param  cSiglaSoc, Sigla do sócio corrente de impressão
@param  lAutomato, Indica se a chamada foi feita via automação

@author Jonatas Martins / Abner Fogaça / Jorge Martins
@since  26/07/2019
/*/
//=======================================================================
Static Function IsNewPage(oPrinter, nIniV, nRegPos, cSiglaSoc, lAutomato)

	// Imprime Subtotal do Sócio
	PrintTotSoc(@oPrinter, @nIniV, cSiglaSoc, lAutomato)

	// É necessário zerar os valores de totais, pois são totalizadores por sócio e houve mudança de sócio
	nRegPos := 1 // Contador de registros

	If (_cAlsRpt)->( !Eof() )
		cSiglaSoc := Nil
	EndIf

	// Finaliza a página para troca de sócio ou escritório
	EndPage(@oPrinter, @nIniV, @nRegPos, /*nNewIniV*/,;
			 /*lImpTitCol*/, cSiglaSoc, .T. /*lEndForced*/,lAutomato)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JReportQry
Executar a query do relatório

@Param cMoeda   , Moeda filtrado no pergunte (Obrigatório)
@Param cAnoMes  , AnoMês filtrado no pergunte (Obrigatório)
@Param cEscrit  , Escritório filtrado no pergunte (Obrigatório)
@param cFilEscr , Filial do Escritório
@param lAutomato, Indica se a chamada foi feita via automação

@author Jonatas Martins / Abner Fogaça / Jorge Martins
@since  26/07/2019
/*/
//-------------------------------------------------------------------
Static Function JReportQry(cMoeda, cAnoMes, cEscrit, cFilEscr, lAutomato)
	Local cQuery      := ""
	Local lAbat       := .F.

	Default cMoeda    := ""
	Default cAnoMes   := ""
	Default cEscrit   := ""
	Default cFilEscr  := ""
	Default lAutomato := .F.

	dbSelectArea( 'OHH' )
	lAbat := OHH->(ColumnPos( "OHH_ABATIM" )) > 0 .And. !lAutomato

	cQuery := "SELECT RD0.RD0_SIGLA, RD0.RD0_NOME, SA1.A1_NOME, OHH.OHH_FILIAL, OHH.OHH_CCLIEN, OHH.OHH_CLOJA, NS7.NS7_COD, NS7.NS7_RAZAO, "
	cQuery +=        "OHH.OHH_PREFIX, OHH.OHH_NUM, OHH.OHH_TIPO, OHH.OHH_NFELET, NXA.NXA_DTEMI, NXA.NXA_DTVENC, NXA.NXA_DOC, NXA.NXA_SERIE, "
	cQuery +=        "(NXA.NXA_VLDSCP + NXA.NXA_VLDSCE + NXA.NXA_VLDSCL) DESCONTOS, "
	cQuery +=        "SUM(OHH.OHH_SALDOH) HONORARIOS, "
	cQuery +=        "SUM(OHH.OHH_VLIRRF) IRRF, " 
	cQuery +=        "SUM(OHH.OHH_VLPIS)  PIS, "
	cQuery +=        "SUM(OHH.OHH_VLCOFI) COFINS, "
	cQuery +=        "SUM(OHH.OHH_VLCSLL) CSLL, "
	cQuery +=        "SUM(OHH.OHH_VLISS)  ISS, "
	cQuery +=        "SUM(OHH.OHH_SALDOD) DESP, "
	IIF( lAbat,;
		cQuery +=    "SUM(OHH.OHH_SALDOH - OHH.OHH_ABATIM + OHH.OHH_SALDOD) TOTLIQUIDO ",;
		cQuery +=    "SUM(OHH.OHH_SALDOH - OHH.OHH_VLIRRF - OHH.OHH_VLPIS - OHH.OHH_VLCOFI - OHH.OHH_VLCSLL - OHH.OHH_VLISS + OHH.OHH_SALDOD) TOTLIQUIDO ";
		)
	cQuery +=  "FROM " + RetSqlName("OHH") + " OHH "
	cQuery += "INNER JOIN " + RetSqlName("NS7") + " NS7 "
	cQuery +=    "ON NS7.NS7_FILIAL = '" + xFilial("NS7") + "' "
	cQuery +=   "AND NS7.NS7_COD    = '" + cEscrit + "' "
	cQuery +=   "AND NS7.NS7_CFILIA = OHH.OHH_FILIAL "
	cQuery +=   "AND NS7.D_E_L_E_T_ = ' ' "
	cQuery += "INNER JOIN " + RetSqlName("NXA") + " NXA "
	cQuery +=    "ON NXA.NXA_FILIAL = '" + xFilial("NXA") + "' "
	cQuery +=   "AND NXA.NXA_CESCR  = NS7.NS7_COD "
	cQuery +=   "AND NXA.NXA_COD    = OHH.OHH_NUM "
	cQuery +=   "AND NXA.NXA_TIPO   = OHH.OHH_TIPO "
	cQuery +=   "AND NXA.D_E_L_E_T_ = ' ' "
	cQuery += "INNER JOIN " + RetSqlName("RD0") + " RD0 "
	cQuery +=    "ON RD0.RD0_FILIAL = '" + xFilial("RD0") + "' "
	cQuery +=   "AND RD0.RD0_CODIGO = NXA.NXA_CPART "
	cQuery +=   "AND RD0.D_E_L_E_T_ = ' ' "
	cQuery += "INNER JOIN " + RetSqlName("SA1") + " SA1 "
	cQuery +=    "ON SA1.A1_FILIAL = '" + xFilial("SA1") + "' "
	cQuery +=   "AND SA1.A1_COD = OHH.OHH_CCLIEN "
	cQuery +=   "AND SA1.A1_LOJA = OHH.OHH_CLOJA "
	cQuery +=   "AND SA1.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE OHH.OHH_FILIAL = '" + xFilial("OHH", cFilEscr) + "' "
	cQuery +=   "AND OHH.OHH_ANOMES  = '" + cAnoMes + "' "
	cQuery +=   "AND OHH.OHH_CMOEDA  = '" + cMoeda + "' "
	cQuery +=   "AND OHH.D_E_L_E_T_ = ' ' "
	cQuery += "GROUP BY RD0.RD0_SIGLA, RD0.RD0_NOME, SA1.A1_NOME, OHH.OHH_FILIAL, OHH.OHH_CCLIEN, OHH.OHH_CLOJA, NS7.NS7_COD, NS7.NS7_RAZAO, "
	cQuery +=         " OHH.OHH_PREFIX, OHH.OHH_NUM, OHH.OHH_TIPO, OHH.OHH_NFELET, NXA.NXA_DTEMI, NXA.NXA_DTVENC, NXA.NXA_DOC, NXA.NXA_SERIE, "
	cQuery +=         " NXA.NXA_VLDSCP, NXA.NXA_VLDSCE, NXA.NXA_VLDSCL "
	cQuery += "ORDER BY RD0.RD0_SIGLA, OHH.OHH_CCLIEN, OHH.OHH_CLOJA, OHH.OHH_NUM "

	_cAlsRpt := GetNextAlias()
	cQuery   := ChangeQuery(cQuery)
	DbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), _cAlsRpt, .T., .T. )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JP038Vld
Valida os campos do pergunte JURAPAD038

@Param cCampo, Campo do pergunte
@Param xValor, Valor do campo

@Return lRet, Se o valor está valido

@author Jonatas Martins / Abner Fogaça / Jorge Martins
@since  26/07/2019
/*/
//-------------------------------------------------------------------
Function JP038Vld(cCampo, xValor)
	Local lRet := .T.
		
	If !Empty(xValor)
		Do Case
			Case cCampo == "1" // Moeda ?
			lRet := ExistCpo("CTO", xValor, 1, , .T., .F.)

			Case cCampo == "2" // Ano-Mês ?
				lRet := JVldAnoMes(xValor)

			Case cCampo == "3" // Escritório ?
				lRet := ExistCpo("NS7", xValor , 1, , .T., .F.)
			
			Case cCampo == "4" // His. Cobrança ?
				lRet := xValor == 1 .Or. xValor == 2
		EndCase
	EndIf

Return lRet