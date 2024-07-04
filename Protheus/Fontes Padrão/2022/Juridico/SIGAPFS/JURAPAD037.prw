#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TOPCONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "JURAPAD037.CH"

#DEFINE _nSalto       10 // Salto de uma linha a outra

#DEFINE _nIniVTitulo  50                  // Coordenada vertical do Título do Relatório
#DEFINE _nIniVEscrit  50                  // Coordenada vertical do Escritório do Relatório (Topo do relatório - Canto esquerdo)
#DEFINE _nIniVCabec   _nIniVTitulo + 49   // Coordenada vertical inicial do cabeçalho do relatório (Títulos das colunas)
#DEFINE _nIniVDados   _nIniVCabec  + 23   // Coordenada vertical inicial dos dados do relatório

#DEFINE _nPCol2      -560   // Coordenada vertical do campo À vencer
#DEFINE _nPCol3      -480   //     ''        ''    ''  ''   1 a 30
#DEFINE _nPCol4      -400   //     ''        ''    ''  ''   31 a 90
#DEFINE _nPCol5      -320   //     ''        ''    ''  ''   91 a 120
#DEFINE _nPCol6      -240   //     ''        ''    ''  ''   121 a 180
#DEFINE _nPCol7      -160   //     ''        ''    ''  ''   > 180
#DEFINE _nPCol8      -80    //     ''        ''    ''  ''   Total Vencido
#DEFINE _nPCol9       0     //     ''        ''    ''  ''   Total Geral
#DEFINE _nIniH        0     // Coordenada horizontal inicial
#DEFINE _nFimH        807.5 // Coordenada horizontal final
#DEFINE _nFimV        585   // Coordenada vertical final

Static _cAlsRpt     := ""
Static _cIdEscrit   := "" // Código - Razão Social do Escritório (Utilizado no cabeçalho - Ex: SP001 - São Paulo)
Static _cAnoMes     := ""
Static _cSimbMoeda  := ""
Static _nPage       := 1  // Contador de páginas
Static _aSubTotal   := {0,0,0,0,0,0,0,0}
Static _aTotalGeral := {0,0,0,0,0,0,0,0}
Static _cDateFt     := "" // Data - Footer
Static _cTimeFt     := "" // Hora - Footer
Static __lAuto      := .F. // Indica se a chamada foi feita via automação

//-------------------------------------------------------------------
/*/{Protheus.doc} JURAPAD037
Relatório de Aging por Sócio

@param lAutomato, Indica se a chamada foi feita via automação
@param cNameAuto, Nome do arquivo de relatório usado na automação

@author Jorge Martins / Bruno Ritter
@since  24/07/2019
/*/
//-------------------------------------------------------------------
Function JURAPAD037(lAutomato, cNameAuto)
	Local aArea     := GetArea()
	Local lCanc     := .F.
	Local bConfirma := Nil
	Local lPDUserAc := Iif(FindFunction("JPDUserAc"), JPDUserAc(), .T.) // Indica se o usuário possui acesso a dados sensíveis ou pessoais (LGPD)

	Default lAutomato := .F.
	Default cNameAuto := ""

	__lAuto := lAutomato

	If lPDUserAc
		While !lCanc
			If __lAuto .Or. JPergunte()
				If JP037TdOk(MV_PAR01, MV_PAR02, MV_PAR04, MV_PAR05)
					If __lAuto
						JP037Relat(MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04, MV_PAR05, MV_PAR06, cNameAuto)
						lCanc := .T.
					Else
						bConfirma := {|| JP037Relat(MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04, MV_PAR05, MV_PAR06, cNameAuto)}
						FwMsgRun( , bConfirma, STR0001, "" ) // "Gerando relatório, aguarde..."
					EndIf
				EndIf
			Else
				lCanc := .T.
			EndIf
		EndDo
	Else
		MsgInfo(STR0023, STR0024) // "Usuário com restrição de acesso a dados pessoais/sensíveis.", "Acesso restrito"
	EndIf

	RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JPergunte
Abre o Pergunte para filtro do relatório

@author Jorge Martins / Bruno Ritter
@since  25/07/2019
/*/
//-------------------------------------------------------------------
Static Function JPergunte()
	Local lRet := Pergunte('JURAPAD037')

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JP037TdOk
Rotina validar os dados do pergunte

@param  cAnomes  , Ano-mês informado
@param  cMoeda   , Moeda informada
@param  cCliente , Cliente do título
@param  cLoja    , Loja do cliente do título

@author Jorge Martins / Bruno Ritter
@since  26/07/2019
/*/
//-------------------------------------------------------------------
Static Function JP037TdOk(cAnomes, cMoeda, cCliente, cLoja)
	Local lRet := .T.

	If Empty(cAnomes)
		JurMsgErro(STR0003,, STR0004) // "É obrigatório o preenchimento do ano-mês." "Informe o ano-mês."
		lRet := .F.
	EndIf

	If lRet .And. Empty(cCliente) .And. !Empty(cLoja)
		JurMsgErro(STR0021,, STR0022) // "Cliente/Loja inválido." "Para utilizar o filtro por 'Loja' é necessário indicar o 'Cliente'."
		lRet := .F.
	EndIf

	If lRet .And. Empty(cMoeda)
		JurMsgErro(STR0005,, STR0006) // "É obrigatório o preenchimento da moeda." "Informe a moeda."
		lRet := .F.
	EndIf

Return lRet

//=======================================================================
/*/{Protheus.doc} JP037Relat
Relatório de Aging por Sócio

@param  cAnoMes  , Ano-mês do histórico de contas a receber
@param  cMoeda   , Moeda do título
@param  cSiglaSoc, Sócio responsável do cliente do título
@param  cCliente , Cliente do título
@param  cLoja    , Loja do cliente do título
@param  cEscrit  , Escritório do título
@param  cNameAuto, Nome do arquivo de relatório usado na automação

@author Jorge Martins / Bruno Ritter
@since  25/07/2019
/*/
//=======================================================================
Static Function JP037Relat(cAnoMes, cMoeda, cSiglaSoc, cCliente, cLoja, cEscrit, cNameAuto)
	Local cReportName   := "Aging_Socio_" + FwTimeStamp(1)
	Local cDirectory    := GetSrvProfString( "StartPath", "" )
	Local lRet          := .T.
	Local aRetEsct      := JurGetDados( "NS7", 1, xFilial("NS7") + cEscrit, {"NS7_CFILIA", "NS7_RAZAO"} )
	Local cFilEscr      := ""

	If !Empty(aRetEsct) .And. Len(aRetEsct) >= 2
		cFilEscr   := aRetEsct[1]
		_cIdEscrit := cEscrit + " - " + AllTrim(aRetEsct[2])
	Else
		_cIdEscrit := STR0007 // "Todos"
	EndIf

	_cAnoMes    := Transform(cAnoMes, "@R XXXX-XX")
	_cSimbMoeda := JurGetDados('CTO', 1, xFilial('CTO') + cMoeda, 'CTO_SIMB')
	_aSubTotal  := {0,0,0,0,0,0,0,0}
	_cDateFt    := cValToChar( Date() )
	_cTimeFt    := Time()

	// Busca dados no banco
	JReportQry(cAnoMes, cMoeda, cSiglaSoc, cCliente, cLoja, cFilEscr)

	// Gera relatórios
	If (_cAlsRpt)->( ! Eof() )
		PrintReport(cReportName, cDirectory, cNameAuto)
	Else
		lRet := .F.
		JurMsgError( STR0002 ) // "Não foram encontrados dados para impressão!"
	EndIf

	_nPage := 1 // Contador de páginas
	(_cAlsRpt)->( DbCloseArea() )

Return lRet

//=======================================================================
/*/{Protheus.doc} PrintReport
Função para gerar PDF do relatório de Balancete Plano/Empresa.

@param  cReportName, Nome do relatório
@param  cDirectory , Caminho da pasta
@param  cNameAuto  , Nome do arquivo de relatório usado na automação

@author Jorge Martins / Bruno Ritter
@since  25/07/2019
/*/
//=======================================================================
Static Function PrintReport(cReportName, cDirectory, cNameAuto)
	Local oPrinter        := Nil
	Local cNameFile       := cReportName
	Local lAdjustToLegacy := .F.
	Local lDisableSetup   := .T.

	Default cReportName   := FwTimeStamp(1)
	Default cDirectory    := GetSrvProfString("StartPath", "")

	// Configurações do relatório
	If !__lAuto
		oPrinter := FWMsPrinter():New(cNameFile, IMP_PDF, lAdjustToLegacy, cDirectory, lDisableSetup,,, "PDF")
	Else
		oPrinter := FWMSPrinter():New(cNameAuto, IMP_SPOOL,,, .T.,,,,.T.) // Inicia o relatório
		// Alterar o nome do arquivo de impressão para o padrão de impressão automatica
		oPrinter:CFILENAME  := cNameAuto
		oPrinter:CFILEPRINT := oPrinter:CPATHPRINT + oPrinter:CFILENAME
	EndIf
	oPrinter:SetLandscape()
	oPrinter:SetPaperSize(DMPAPER_A4)
	oPrinter:SetMargin(60, 60, 60, 60)

	// Gera nova folha
	NewPage(@oPrinter)

	// Imprime seção de escritório
	PrintRepData(@oPrinter)

	// Gera arquivo relatório
	oPrinter:Print()

Return Nil

//=======================================================================
/*/{Protheus.doc} NewPage
Cria nova página do relatório.

@param  oPrinter  , Estrutra do relatório
@param  lImpTitCol, Indica se imprime os títulos das colunas
@param  cSiglaSoc , Sigla do sócio corrente de impressão

@author Jorge Martins / Bruno Ritter
@since  25/07/2019
/*/
//=======================================================================
Static Function NewPage(oPrinter, lImpTitCol, cSiglaSoc)

	Default lImpTitCol := .T.
	Default cSiglaSoc  := (_cAlsRpt)->RD0_SIGLA

	// Inicio Página
	oPrinter:StartPage()

	// Monta cabeçalho
	PrintHead(@oPrinter)

	// Monta títulos das colunas
	If lImpTitCol
		PrintTitCol(@oPrinter, cSiglaSoc)
	EndIf

	// Imprime Rodapé
	PrintFooter(@oPrinter)

Return Nil

//=======================================================================
/*/{Protheus.doc} PrintHead
Imprime dados do cabeçalho.

@param  oPrinter, Estrutra do relatório

@author Jorge Martins / Bruno Ritter
@since  25/07/2019
/*/
//=======================================================================
Static Function PrintHead(oPrinter)
	Local oFontHead  := TFont():New('Arial',, -18,, .T.,,,,, .F., .F.)
	Local oFontHead2 := TFont():New('Arial',, -10,, .F.,,,,, .F., .F.)
	Local oFontHead3 := TFont():New('Arial',, -12,, .T.,,,,, .F., .F.)

	// Título do relatório
	oPrinter:SayAlign( _nIniVTitulo, _nIniH, STR0008 + " - " + _cSimbMoeda, oFontHead, _nFimH, 200, CLR_BLACK, 2, 1 ) // "Aging por Sócio"

	// Razão Social do Escritório
	oPrinter:Say( _nIniVEscrit, _nIniH, (_cAlsRpt)->NS7_RAZAO, oFontHead3, 1200, /*color*/)

	// Detalhes do filtro do relatório
	oPrinter:Line( _nIniVTitulo + 25, _nIniH, _nIniVTitulo + 25, _nFimH, CLR_HRED, "-8")
	oPrinter:Say( _nIniVTitulo + 35, _nIniH, I18n(STR0009, {_cAnoMes}), oFontHead2, 1200, /*color*/) // "Período: #1"

	oPrinter:SayAlign( _nIniVTitulo + 27, _nIniH, I18N( STR0010, { _cIdEscrit } ), oFontHead2, _nFimH, 200, CLR_BLACK, 1, 1 ) // "Escritório: #1"
	oPrinter:Line( _nIniVTitulo + 39, _nIniH, _nIniVTitulo + 39, _nFimH, CLR_HRED, "-8")

Return Nil

//=======================================================================
/*/{Protheus.doc} PrintTitCol
Imprime título das colonas do relatório.

@param  oPrinter  , Estrutra do relatório
@param  nIniV     , Coordenada vertical inicial
@param  cSiglaSoc , Sigla do sócio corrente de impressão

@author Jorge Martins / Bruno Ritter
@since  25/07/2019
/*/
//=======================================================================
Static Function PrintTitCol(oPrinter, cSiglaSoc)
	Local oFontTitCol := Nil
	Local nIniV       := _nIniVCabec

	oFontTitCol := TFont():New('Arial',, -10,, .T.,,,,, .F., .F.)

	// Avalia fim da página
	EndPage(@oPrinter, @nIniV, /*nRegPos*/, (4 * _nSalto), /*lImpTitCol*/, cSiglaSoc)

	oPrinter:Say( nIniV += _nSalto , _nIniH , STR0011, oFontTitCol, 1200, /*color*/)               // "Cliente"
	oPrinter:SayAlign( nIniV - 8   , _nPCol2, STR0012, oFontTitCol, _nFimH, 200, CLR_BLACK, 1, 1 ) // "À vencer"
	oPrinter:SayAlign( nIniV - 8   , _nPCol3, STR0013, oFontTitCol, _nFimH, 200, CLR_BLACK, 1, 1 ) // "1 a 30"
	oPrinter:SayAlign( nIniV - 8   , _nPCol4, STR0014, oFontTitCol, _nFimH, 200, CLR_BLACK, 1, 1 ) // "31 a 90"
	oPrinter:SayAlign( nIniV - 8   , _nPCol5, STR0015, oFontTitCol, _nFimH, 200, CLR_BLACK, 1, 1 ) // "91 a 120"
	oPrinter:SayAlign( nIniV - 8   , _nPCol6, STR0016, oFontTitCol, _nFimH, 200, CLR_BLACK, 1, 1 ) // "121 a 180"
	oPrinter:SayAlign( nIniV - 8   , _nPCol7, STR0017, oFontTitCol, _nFimH, 200, CLR_BLACK, 1, 1 ) // "> 180"
	oPrinter:SayAlign( nIniV - 8   , _nPCol8, STR0018, oFontTitCol, _nFimH, 200, CLR_BLACK, 1, 1 ) // "Total Vencido"
	oPrinter:SayAlign( nIniV - 8   , _nPCol9, STR0019, oFontTitCol, _nFimH, 200, CLR_BLACK, 1, 1 ) // "Total Geral"

	oPrinter:Line( nIniV += 4, _nIniH, nIniV, _nFimH, 0, "-8")
	nIniV += _nSalto

Return Nil

//=======================================================================
/*/{Protheus.doc} PrintFooter
Imprime rodapé do cabeçalho.

@param  oPrinter, Estrutra do relatório

@author Jorge Martins / Bruno Ritter
@since  25/07/2019
/*/
//=======================================================================
Static Function PrintFooter(oPrinter)
	Local oFontRod := TFont():New('Arial',, -10,, .F.,,,,, .F., .F.)
	Local nLinRod  := _nFimV + 5

	oPrinter:Line( nLinRod, _nIniH, nLinRod, _nFimH, CLR_HRED, "-8")
	nLinRod += _nSalto
	If !__lAuto
		oPrinter:SayAlign( nLinRod, _nIniH, _cDateFt + " - " + _cTimeFt, oFontRod, _nFimH, 200, CLR_BLACK, 2, 1 )
	EndIf
	oPrinter:SayAlign( nLinRod, _nIniH, cValToChar( _nPage )       , oFontRod, _nFimH, 200, CLR_BLACK, 1, 1 )

Return Nil

//=======================================================================
/*/{Protheus.doc} PrintRepData
Imprime registros do relatório.

@param  oPrinter, Estrutra do relatório

@author Jorge Martins / Bruno Ritter
@since  25/07/2019
/*/
//=======================================================================
Static Function PrintRepData(oPrinter)
	Local oFontSigla := TFont():New('Arial',, -10,, .T.,,,,, .F., .F.)
	Local oFontReg   := TFont():New('Arial',, -7,, .F.,,,,, .F., .F.)
	Local nIniV      := _nIniVDados
	Local nRegPos    := 1
	Local cSiglaSoc  := ""
	Local cNmClient  := ""
	Local cEscrit    := ""
	Local nTotalVenc := 0
	Local nTotal     := 0

	While (_cAlsRpt)->( ! Eof() )

		cNmClient  := AllTrim(i18n("#1/#2 - #3", {(_cAlsRpt)->A1_COD, (_cAlsRpt)->A1_LOJA, (_cAlsRpt)->A1_NOME}))
		cNmClient  := IIf(Len(cNmClient) <= 60, cNmClient, SubStr(cNmClient, 1, 60) + "...")
		nTotalVenc := (_cAlsRpt)->VENCIDO_1_30    + ;
		              (_cAlsRpt)->VENCIDO_31_90   + ;
		              (_cAlsRpt)->VENCIDO_91_120  + ;
		              (_cAlsRpt)->VENCIDO_121_180 + ;
		              (_cAlsRpt)->VENCIDO_181
		nTotal     := nTotalVenc + (_cAlsRpt)->A_VENCER

		// Avalia fim da página
		EndPage(@oPrinter, @nIniV, @nRegPos, /*nNewIniV*/)

		// Insere cor nas linhas
		ColorLine(@oPrinter, nIniV, nRegPos)

		// Verifica se houve mudança de Sócio ou Escritório
		If cSiglaSoc != (_cAlsRpt)->RD0_SIGLA .Or. cEscrit != (_cAlsRpt)->NS7_COD
			
			// Imprime Sigla do Sócio antes da impressão dos registros
			oPrinter:Say( nIniV, _nIniH, (_cAlsRpt)->RD0_SIGLA, oFontSigla, 1200, /*color*/)
			oPrinter:Line( nIniV += 4, _nIniH, nIniV, _nFimH, 0, "-8")
			
			cSiglaSoc := (_cAlsRpt)->RD0_SIGLA
			cEscrit   := (_cAlsRpt)->NS7_COD

			nIniV += _nSalto // Pula linha
		EndIf

		// Imprime registros
		oPrinter:Say( nIniV, _nIniH, cNmClient, oFontReg, 1200, /*color*/)
		oPrinter:SayAlign( nIniV - 6, _nPCol2, FormatNum( (_cAlsRpt)->A_VENCER       ), oFontReg, _nFimH, 200, CLR_BLACK, 1, 1 ) // À vencer
		oPrinter:SayAlign( nIniV - 6, _nPCol3, FormatNum( (_cAlsRpt)->VENCIDO_1_30   ), oFontReg, _nFimH, 200, CLR_BLACK, 1, 1 ) // Vencido de 1 a 30
		oPrinter:SayAlign( nIniV - 6, _nPCol4, FormatNum( (_cAlsRpt)->VENCIDO_31_90  ), oFontReg, _nFimH, 200, CLR_BLACK, 1, 1 ) // Vencido de 31 a 90
		oPrinter:SayAlign( nIniV - 6, _nPCol5, FormatNum( (_cAlsRpt)->VENCIDO_91_120 ), oFontReg, _nFimH, 200, CLR_BLACK, 1, 1 ) // Vencido de 91 a 120
		oPrinter:SayAlign( nIniV - 6, _nPCol6, FormatNum( (_cAlsRpt)->VENCIDO_121_180), oFontReg, _nFimH, 200, CLR_BLACK, 1, 1 ) // Vencido de 121 a 180
		oPrinter:SayAlign( nIniV - 6, _nPCol7, FormatNum( (_cAlsRpt)->VENCIDO_181    ), oFontReg, _nFimH, 200, CLR_BLACK, 1, 1 ) // Vencido de > 180
		oPrinter:SayAlign( nIniV - 6, _nPCol8, FormatNum( nTotalVenc                 ), oFontReg, _nFimH, 200, CLR_BLACK, 1, 1 ) // Total Venc
		oPrinter:SayAlign( nIniV - 6, _nPCol9, FormatNum( nTotal                     ), oFontReg, _nFimH, 200, CLR_BLACK, 1, 1 ) // Total Geral

		_aSubTotal[1] += (_cAlsRpt)->A_VENCER
		_aSubTotal[2] += (_cAlsRpt)->VENCIDO_1_30
		_aSubTotal[3] += (_cAlsRpt)->VENCIDO_31_90
		_aSubTotal[4] += (_cAlsRpt)->VENCIDO_91_120
		_aSubTotal[5] += (_cAlsRpt)->VENCIDO_121_180
		_aSubTotal[6] += (_cAlsRpt)->VENCIDO_181
		_aSubTotal[7] += nTotalVenc
		_aSubTotal[8] += nTotal

		nIniV         += _nSalto // Pula linha

		(_cAlsRpt)->( DbSkip() )
		
		// Avalia quebra de linha
		IsBrokenRep(@oPrinter, @nIniV, @nRegPos, cSiglaSoc, cEscrit)
	EndDo

	// Imprime Subtotal da última sessão
	PrintSubTot(@oPrinter, @nIniV, cSiglaSoc)

	// Imprime Total Geral
	PrintTotGer(@oPrinter, nIniV)

Return Nil

//=======================================================================
/*/{Protheus.doc} PrintSubTot
Imprime subtotal na quebra por escritório.

@param  oPrinter   , Estrutra do relatório
@param  nIniV      , Coordenada vertical inicial
@param  cSiglaSoc  , Sigla do sócio corrente de impressão

@author Jorge Martins / Bruno Ritter
@since  25/07/2019
/*/
//=======================================================================
Static Function PrintSubTot(oPrinter, nIniV, cSiglaSoc)
	Local oFontSubTot := TFont():New('Arial',, -10,, .T.,,,,, .F., .F.)

	Default cSiglaSoc := (_cAlsRpt)->RD0_SIGLA
	
	// Avalia fim da página
	EndPage(@oPrinter, @nIniV, /*nRegPos*/, (3 * _nSalto), /*lImpTitCol*/, cSiglaSoc)

	oPrinter:Line( nIniV - 4, _nIniH, nIniV - 4, _nFimH, 0, "-8")

	oPrinter:Say( nIniV += 6, _nIniH, STR0020 + " " + cSiglaSoc, oFontSubTot, 1200, /*color*/) // "Total"
	oPrinter:SayAlign( nIniV - 8, _nPCol2, FormatNum(_aSubTotal[1]), oFontSubTot, _nFimH, 200, CLR_BLACK, 1, 1 ) // À vencer
	oPrinter:SayAlign( nIniV - 8, _nPCol3, FormatNum(_aSubTotal[2]), oFontSubTot, _nFimH, 200, CLR_BLACK, 1, 1 ) // Vencido de 1 a 30
	oPrinter:SayAlign( nIniV - 8, _nPCol4, FormatNum(_aSubTotal[3]), oFontSubTot, _nFimH, 200, CLR_BLACK, 1, 1 ) // Vencido de 31 a 90
	oPrinter:SayAlign( nIniV - 8, _nPCol5, FormatNum(_aSubTotal[4]), oFontSubTot, _nFimH, 200, CLR_BLACK, 1, 1 ) // Vencido de 91 a 120
	oPrinter:SayAlign( nIniV - 8, _nPCol6, FormatNum(_aSubTotal[5]), oFontSubTot, _nFimH, 200, CLR_BLACK, 1, 1 ) // Vencido de 121 a 180
	oPrinter:SayAlign( nIniV - 8, _nPCol7, FormatNum(_aSubTotal[6]), oFontSubTot, _nFimH, 200, CLR_BLACK, 1, 1 ) // Vencido de > 180
	oPrinter:SayAlign( nIniV - 8, _nPCol8, FormatNum(_aSubTotal[7]), oFontSubTot, _nFimH, 200, CLR_BLACK, 1, 1 ) // Total Venc
	oPrinter:SayAlign( nIniV - 8, _nPCol9, FormatNum(_aSubTotal[8]), oFontSubTot, _nFimH, 200, CLR_BLACK, 1, 1 ) // Total Geral

	_aTotalGeral[1] += _aSubTotal[1]
	_aTotalGeral[2] += _aSubTotal[2]
	_aTotalGeral[3] += _aSubTotal[3]
	_aTotalGeral[4] += _aSubTotal[4]
	_aTotalGeral[5] += _aSubTotal[5]
	_aTotalGeral[6] += _aSubTotal[6]
	_aTotalGeral[7] += _aSubTotal[7]
	_aTotalGeral[8] += _aSubTotal[8]

	// Limpa o subtotal
	_aSubTotal := {0,0,0,0,0,0,0,0}

	nIniV += _nSalto

Return Nil

//=======================================================================
/*/{Protheus.doc} PrintTotGer
Imprime Total Geral

@param  oPrinter  , Estrutra do relatório
@param  nIniV     , Coordenada vertical inicial
@param  cSiglaSoc , Sigla do sócio corrente de impressão

@author Jorge Martins / Bruno Ritter
@since  25/07/2019
/*/
//=======================================================================
Static Function PrintTotGer(oPrinter, nIniV, cSiglaSoc)
	Local oFontTotGer := TFont():New('Arial',, -10,, .T.,,,,, .F., .F.)

	// Avalia fim da página
	EndPage( @oPrinter, @nIniV, /*nRegPos*/, (3 * _nSalto), .F. /*lImpTitCol*/, cSiglaSoc )

	oPrinter:Line( nIniV += _nSalto, _nIniH, nIniV, _nFimH, 0, "-8")

	oPrinter:Say( nIniV += _nSalto, _nIniH, STR0019, oFontTotGer, 1200,/*color*/) // "Total Geral"
	oPrinter:SayAlign( nIniV - 8, _nPCol2, FormatNum(_aTotalGeral[1]), oFontTotGer, _nFimH, 200, CLR_BLACK, 1, 1 ) // À vencer
	oPrinter:SayAlign( nIniV - 8, _nPCol3, FormatNum(_aTotalGeral[2]), oFontTotGer, _nFimH, 200, CLR_BLACK, 1, 1 ) // Vencido de 1 a 30
	oPrinter:SayAlign( nIniV - 8, _nPCol4, FormatNum(_aTotalGeral[3]), oFontTotGer, _nFimH, 200, CLR_BLACK, 1, 1 ) // Vencido de 31 a 90
	oPrinter:SayAlign( nIniV - 8, _nPCol5, FormatNum(_aTotalGeral[4]), oFontTotGer, _nFimH, 200, CLR_BLACK, 1, 1 ) // Vencido de 91 a 120
	oPrinter:SayAlign( nIniV - 8, _nPCol6, FormatNum(_aTotalGeral[5]), oFontTotGer, _nFimH, 200, CLR_BLACK, 1, 1 ) // Vencido de 121 a 180
	oPrinter:SayAlign( nIniV - 8, _nPCol7, FormatNum(_aTotalGeral[6]), oFontTotGer, _nFimH, 200, CLR_BLACK, 1, 1 ) // Vencido de > 180
	oPrinter:SayAlign( nIniV - 8, _nPCol8, FormatNum(_aTotalGeral[7]), oFontTotGer, _nFimH, 200, CLR_BLACK, 1, 1 ) // Total Venc
	oPrinter:SayAlign( nIniV - 8, _nPCol9, FormatNum(_aTotalGeral[8]), oFontTotGer, _nFimH, 200, CLR_BLACK, 1, 1 ) // Total Geral

	// Limpa Total Geral
	_aTotalGeral := {0,0,0,0,0,0,0,0}

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

@author Jorge Martins / Bruno Ritter
@since  25/07/2019
/*/
//=======================================================================
Static Function EndPage(oPrinter, nIniV, nRegPos, nNewIniV, lImpTitCol, cSiglaSoc, lEndForced)

	Default nRegPos    := 1
	Default nNewIniV   := 0
	Default lImpTitCol := .T.
	Default cSiglaSoc  := (_cAlsRpt)->RD0_SIGLA
	Default lEndForced := .F.

	If lEndForced .Or. ( nIniV + nNewIniV ) >= _nFimV
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
	Local aCoords   := {}
	Local oBrush    := Nil
	Local cPixel    := ""

	Default nRegPos := 1
	Default lForce  := .F.
	Default nColor  := RGB( 224, 224, 224 )

	// Avalia se a linha é impar
	If Mod( nRegPos, 2 ) == 0 .Or. lForce
		oBrush  :=  TBrush():New( Nil, nColor )
		aCoords := { nIniV - 7, _nIniH , nIniV + 3, _nFimH }
		cPixel  := "-2"
		oPrinter:FillRect( aCoords, oBrush, cPixel )
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
@param  cEscrit  , Código do Escritório

@author Jorge Martins / Bruno Ritter
@since  25/07/2019
/*/
//=======================================================================
Static Function IsBrokenRep(oPrinter, nIniV, nRegPos, cSiglaSoc, cEscrit)
	Local cNovaSigla  := (_cAlsRpt)->RD0_SIGLA
	Local cNovoEscr   := (_cAlsRpt)->NS7_COD

	// Avalia quebra de página (Novo Sócio ou Escritório)
	If (!Empty(cNovaSigla) .And. (cSiglaSoc != cNovaSigla)) .Or. ;
	   (!Empty(cNovoEscr) .And. (cEscrit != cNovoEscr)) 

		// Imprime os totalizadores e quebra página para impressão do novo Sócio
		IsNewPage(@oPrinter, @nIniV , @nRegPos, cSiglaSoc)
	Else
		nRegPos += 1 // Incrementa contador de registros
	EndIf

Return Nil

//=======================================================================
/*/{Protheus.doc} FormatNum
Coloca separação decimal nos valores numéricos.

@param  nValue, Número a ser formatado

@author Jorge Martins / Bruno Ritter
@since  25/07/2019
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

@author Jorge Martins / Bruno Ritter
@since  25/07/2019
/*/
//=======================================================================
Static Function IsNewPage(oPrinter, nIniV, nRegPos, cSiglaSoc)

	// Imprime Subtotal da última sessão
	PrintSubTot(@oPrinter, @nIniV, cSiglaSoc)

	// É necessário zerar os valores de totais, pois são totalizadores por sócio e houve mudança de sócio
	nRegPos := 1 // Contador de registros

	If (_cAlsRpt)->( !Eof() )
		cSiglaSoc := Nil
	EndIf

	// Finaliza a página para troca de sócio ou escritório
	EndPage(@oPrinter, @nIniV, @nRegPos, /*nNewIniV*/, /*lImpTitCol*/, cSiglaSoc, .T. /*lEndForced*/)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JReportQry
Executa a query do relatório

@param cAnoMes   , AnoMês filtrado no pergunte (Obrigatório)
@param cMoeda    , Moeda filtrado no pergunte (Obrigatório)
@param cSiglaSoc , Sigla do Sócio filtrado no pergunte (Opcional)
@param cCliente  , Código do Cliente filtrado no pergunte (Opcional)
@param cLoja     , Loja do Cliente filtrado no pergunte (Opcional)
@param cFilEscr  , Filial do Escritório filtrado no pergunte (Opcional)

@author Jorge Martins / Bruno Ritter
@since  25/07/2019
/*/
//-------------------------------------------------------------------
Static Function JReportQry(cAnoMes, cMoeda, cSiglaSoc, cCliente, cLoja, cFilEscr)
	Local dDtInicial    := CtoD("  /  /  ")
	Local dDtFinal      := CtoD("  /  /  ")
	Local dDateRef      := Date()
	Local cAnoMesAtu    := AnoMes(dDateRef)
	Local cValMoeda     := cValToChar(Val(cMoeda))

	Default cSiglaSoc   := ""
	Default cCliente    := ""
	Default cLoja       := ""
	Default cFilEscr    := ""

	If cAnoMesAtu != cAnoMes
		dDateRef := LastDate(SToD(cAnoMes + "01"))
	EndIf

	cQuery     := " SELECT * FROM ( "
	cQuery     += " SELECT "
	cQuery     +=     " NS7.NS7_COD, "
	cQuery     +=     " NS7.NS7_RAZAO, "
	cQuery     +=     " NS7.NS7_CFILIA, "
	cQuery     +=     " RD0.RD0_SIGLA, "
	cQuery     +=     " SA1.A1_COD, "
	cQuery     +=     " SA1.A1_LOJA, "
	cQuery     +=     " SA1.A1_NOME, "

	dDtInicial := dDateRef
	cQuery     += " ( " + JGetQryMes(cAnoMes, cValMoeda, dDtInicial, Nil)      + " ) A_VENCER, "

	dDtFinal   := DaySub(dDateRef, 1)
	dDtInicial := DaySub(dDateRef, 30)
	cQuery     += " ( " + JGetQryMes(cAnoMes, cValMoeda, dDtInicial, dDtFinal) + " ) VENCIDO_1_30, "

	dDtFinal   := DaySub(dDateRef, 31)
	dDtInicial := DaySub(dDateRef, 90)
	cQuery     += " ( " + JGetQryMes(cAnoMes, cValMoeda, dDtInicial, dDtFinal) + " ) VENCIDO_31_90, "

	dDtFinal   := DaySub(dDateRef, 91)
	dDtInicial := DaySub(dDateRef, 120)
	cQuery     += " ( " + JGetQryMes(cAnoMes, cValMoeda, dDtInicial, dDtFinal) + " ) VENCIDO_91_120, "

	dDtFinal   := DaySub(dDateRef, 121)
	dDtInicial := DaySub(dDateRef, 180)
	cQuery     += " ( " + JGetQryMes(cAnoMes, cValMoeda, dDtInicial, dDtFinal) + " ) VENCIDO_121_180, "

	dDtFinal   := DaySub(dDateRef, 181)
	cQuery     += " ( " + JGetQryMes(cAnoMes, cValMoeda, Nil, dDtFinal)        + " ) VENCIDO_181, "

	cQuery     += " CASE "
	cQuery     +=      " WHEN EXISTS ( SELECT 1 "
	cQuery     +=                      " FROM " + RetSqlName("OHH") + " OHH "
	cQuery     +=                     " WHERE OHH.OHH_ANOMES = '" + cAnoMes + "' "
	cQuery     +=                       " AND OHH.OHH_CMOEDA = '" + cValMoeda + "' "
	cQuery     +=                       " AND OHH.OHH_FILIAL = NS7.NS7_CFILIA "
	cQuery     +=                       " AND OHH.OHH_CCLIEN = SA1.A1_COD "
	cQuery     +=                       " AND OHH.OHH_CLOJA = SA1.A1_LOJA "
	cQuery     +=                       " AND OHH.OHH_SALDO > 0 "
	cQuery     +=                       " AND OHH.D_E_L_E_T_ = ' ' ) "
	cQuery     +=      " THEN 1 "
	cQuery     +=      " ELSE 0 "
	cQuery     += " END TEM_DADOS "

	cQuery     += " FROM " + RetSqlName("NS7") + " NS7 "
	cQuery     +=     ", " + RetSqlName("SA1") + " SA1 "
	cQuery     +=     " LEFT JOIN " + RetSqlName("NUH") + " NUH "
	cQuery     +=            " ON NUH.NUH_FILIAL = SA1.A1_FILIAL "
	cQuery     +=           " AND NUH.NUH_COD  = SA1.A1_COD "
	cQuery     +=           " AND NUH.NUH_LOJA = SA1.A1_LOJA "
	cQuery     +=           " AND NUH.D_E_L_E_T_ = ' ' "
	cQuery     +=     " LEFT JOIN " + RetSqlName("RD0") + " RD0 "
	cQuery     +=            " ON RD0.RD0_FILIAL = SA1.A1_FILIAL "
	cQuery     +=           " AND RD0.RD0_CODIGO = NUH.NUH_CPART "
	cQuery     +=           " AND RD0.D_E_L_E_T_ = ' ' "
	cQuery     += " WHERE SA1.D_E_L_E_T_ = ' ' "
	cQuery     +=   " AND NS7.D_E_L_E_T_ = ' ' "

	If !Empty(cFilEscr)
		cQuery +=   " AND NS7.NS7_CFILIA = '" + cFilEscr + "' "
		cQuery +=   " AND SA1.A1_FILIAL = '" + xFilial("SA1", cFilEscr) + "' "
	EndIf

	If !Empty(cCliente)
		cQuery +=       " AND SA1.A1_COD = '" + cCliente + "' "
		If !Empty(cLoja)
			cQuery +=   " AND SA1.A1_LOJA = '" + cLoja + "' "
		EndIf
	EndIf
	
	If !Empty(cSiglaSoc)
		cQuery +=   " AND RD0.RD0_SIGLA = '" + cSiglaSoc + "' "
	EndIf
	cQuery +=   " ) TMP "
	cQuery +=     " WHERE TMP.TEM_DADOS = 1 "
	cQuery +=     " ORDER BY TMP.NS7_CFILIA, TMP.RD0_SIGLA, TMP.A1_COD, TMP.A1_LOJA"

	_cAlsRpt := GetNextAlias()
	cQuery   := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), _cAlsRpt, .T., .T.)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JGetQryMes
Retorna a query referente a data de vencimento do título olhando na OHH

@param cAnoMes    , AnoMês filtrado no pergunte (Obrigatório)
@param cMoeda     , Moeda filtrado no pergunte (Obrigatório)
@param dDtInicial , Data Inicial para o filtro (Opcional)
@param dDtFinal   , Data Final para o filtro (Opcional)

@return cQuery    , SubQuery dos dados da OHH

@author Jorge Martins / Bruno Ritter
@since  25/07/2019
/*/
//-------------------------------------------------------------------
Static Function JGetQryMes(cAnoMes, cMoeda, dDtInicial, dDtFinal)
	Local cQuery := ""
	Local lAbat  := .F.

	dbSelectArea( 'OHH' )
	lAbat := OHH->(ColumnPos( "OHH_ABATIM" )) > 0 .And. !__lAuto

	cQuery :=   " SELECT "
	If lAbat
		cQuery += " SUM(OHH.OHH_SALDO) - SUM(OHH.OHH_ABATIM)"
	Else
		cQuery += " SUM(OHH.OHH_SALDO) - SUM(OHH.OHH_VLIRRF) - SUM(OHH.OHH_VLPIS) - SUM(OHH.OHH_VLCOFI) - SUM(OHH.OHH_VLCSLL) - SUM(OHH.OHH_VLISS) - SUM(OHH.OHH_VLINSS)"
	EndIf
	cQuery +=   " FROM " + RetSqlName("OHH") + " OHH "
	cQuery +=   " WHERE OHH.OHH_FILIAL = NS7.NS7_CFILIA "
	cQuery +=     " AND OHH.OHH_ANOMES = '" + cAnoMes + "' "
	If !Empty(dDtInicial)
		cQuery += " AND OHH.OHH_VENCRE >= '" + DtoS(dDtInicial) + "' "
	EndIf
	If !Empty(dDtFinal)
		cQuery += " AND OHH.OHH_VENCRE <= '" + DtoS(dDtFinal) + "' "
	EndIf
	cQuery +=     " AND OHH.OHH_CMOEDA = '" + cValToChar(Val(cMoeda)) + "' "
	cQuery +=     " AND OHH.OHH_CCLIEN = SA1.A1_COD "
	cQuery +=     " AND OHH.OHH_CLOJA = SA1.A1_LOJA "
	cQuery +=     " AND OHH.D_E_L_E_T_ = ' ' "

Return cQuery

//-------------------------------------------------------------------
/*/{Protheus.doc} JP037Vld
Valida os campos do pergunte JURAPAD037

@param cCampo, Campo do pergunte
@param cValor, Valor do campo

@return lRet , Se o valor está valido

@author Jorge Martins / Bruno Ritter
@since  26/07/2019
/*/
//-------------------------------------------------------------------
Function JP037Vld(cCampo, cValor)
	Local lRet := .T.

	If !Empty(cValor)
		Do Case
			Case cCampo == "1" // Ano-Mês ?
				lRet := JVldAnoMes(cValor)

			Case cCampo == "2" // Moeda ?
				lRet := ExistCpo("CTO", cValor, 1, , .T., .F.)

			Case cCampo == "3" // Sócio Resp. ?
				lRet := ExistCpo("RD0", cValor, 9, , .T., .F.)

			Case cCampo == "4" // Cliente ?
				lRet := Empty(cValor) .Or. ExistCpo("SA1", cValor, 1, , .T., .F.)

			Case cCampo == "5" // Loja ?
				lRet := Empty(cValor) .Or. ExistCpo("SA1", MV_PAR04 + cValor, 1, , .T., .F.)

			Case cCampo == "6" // Escritório ?
				lRet := ExistCpo("NS7", cValor, 1, , .T., .F.)
		EndCase
	EndIf

Return lRet
