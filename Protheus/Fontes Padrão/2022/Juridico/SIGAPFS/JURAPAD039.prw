#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TOPCONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "JURAPAD039.CH"

#DEFINE _nSalto       10                  // Salto de uma linha a outra
#DEFINE _nIniVEscrit  40                  // Coordenada vertical do Escrit�rio do Relat�rio
#DEFINE _nIniVTitulo  40                  // Coordenada vertical do T�tulo do Relat�rio
#DEFINE _nIniVCabec   _nIniVTitulo + 49   // Coordenada vertical inicial do cabe�alho do relat�rio (T�tulos das colunas)
#DEFINE _nIniVDados   _nIniVCabec  + 23   // Coordenada vertical inicial dos dados do relat�rio

#DEFINE _nPCol01      0     // Coordenada vertical do campo Escrit�rio / Fatura
#DEFINE _nPCol02      90    //     ''        ''    ''  ''   Nota Fiscal
#DEFINE _nPCol03      160   //     ''        ''    ''  ''   Vencto.
#DEFINE _nPCol04      220   //     ''        ''    ''  ''   Parcela
#DEFINE _nPCol05      280   //     ''        ''    ''  ''   Data Pagto
#DEFINE _nPCol06      -160  //     ''        ''    ''  ''   Descontos
#DEFINE _nPCol07      -80   //     ''        ''    ''  ''   Acr�scimos
#DEFINE _nPCol08      0     //     ''        ''    ''  ''   Vl. Recebido

#DEFINE _nIniH        0     // Coordenada horizontal inicial
#DEFINE _nFimH        560   // Coordenada horizontal final
#DEFINE _nFimV        820   // Coordenada vertical final

#DEFINE _nIniTot      260   // Coordenada horizontal inicial da linha de total do s�cio e total geral

Static _cAlsRpt     := ""
Static _cSimbMoeda  := ""
Static _nPage       := 1  // Contador de p�ginas
Static _aTotalCli   := {0, 0, 0}
Static _aTotalGeral := {0, 0, 0}
Static _cDateFt     := "" // Data - Footer
Static _cTimeFt     := "" // Hora - Footer
Static _cRazSocEsc  := "" // Raz�o Social do Escrit�rio (Utilizado no topo do relat�rio)
Static _cIdEscrit   := "" // C�digo - Raz�o Social do Escrit�rio (Utilizado no cabe�alho - Ex: SP001 - S�o Paulo)
Static __lAuto      := .F.  // Indica se a chamada foi feita via automa��o
Static _oTmpOHI     := Nil // Tabela tempor�ria com os dados do relat�rio

//-------------------------------------------------------------------
/*/{Protheus.doc} JURAPAD039
Relat�rio de Faturas Pagas

@param lAutomato, Indica se a chamada foi feita via automa��o
@param cNameAuto, Nome do arquivo de relat�rio usado na automa��o

@author Jorge Martins / Jonatas Martins / Cristina Cintra
@since  31/07/2019
/*/
//-------------------------------------------------------------------
Function JURAPAD039(lAutomato, cNameAuto)
	Local aArea     := GetArea()
	Local lCanc     := .F.
	Local bConfirma := Nil
	Local lPDUserAc := Iif(FindFunction("JPDUserAc"), JPDUserAc(), .T.) // Indica se o usu�rio possui acesso a dados sens�veis ou pessoais (LGPD)

	Default lAutomato := .F.
	Default cNameAuto := ""

	__lAuto := lAutomato

	If lPDUserAc
		While !lCanc
			If __lAuto .Or. JPergunte()
				If JP039TdOk(MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04, MV_PAR05, MV_PAR06)
					If __lAuto
						JP039Relat(MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04, MV_PAR05, MV_PAR06, cNameAuto)
						lCanc := .T.
					Else
						bConfirma := {|| JP039Relat(MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04, MV_PAR05, MV_PAR06, cNameAuto)}
						FwMsgRun( , bConfirma, STR0012, "" ) // "Gerando relat�rio, aguarde..."
					EndIf
				EndIf
			Else
				lCanc := .T.
			EndIf
		EndDo
	Else
		MsgInfo(STR0025, STR0026) // "Usu�rio com restri��o de acesso a dados pessoais/sens�veis.", "Acesso restrito"
	EndIf

	RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JPergunte
Abre o Pergunte para filtro do relat�rio

@author Jorge Martins / Jonatas Martins / Cristina Cintra
@since  31/07/2019
/*/
//-------------------------------------------------------------------
Static Function JPergunte()
	Local lRet := .T.

	lRet := Pergunte('JURAPAD039')

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JP039TdOk
Rotina para validar os dados do pergunte.

@param  cMoeda   , Moeda do t�tulo
@param  cDataIni , Data inicial de pagamento do T�tulo
@param  cDataFim , Data final de pagamento do T�tulo
@param  cCliente , C�digo do Cliente do t�tulo
@param  cLoja    , C�digo da Loja do Cliente do t�tulo
@param  cEscrit  , Escrit�rio da fatura vinculado ao t�tulo

@return lRet     , Indica se os filtros s�o v�lidos

@author Jorge Martins / Jonatas Martins / Cristina Cintra
@since  31/07/2019
/*/
//-------------------------------------------------------------------
Static Function JP039TdOk(cMoeda, dDataIni, dDataFim, cCliente, cLoja, cEscrit)
	Local lRet := .T.

	If Empty(cMoeda)
		JurMsgErro(STR0014,, STR0015) // "� necess�rio informar a moeda!" ### "Informe a moeda."
		lRet := .F.
	EndIf

	If lRet .And. Empty(dDataIni)
		JurMsgErro(STR0016,, STR0017) // "� necess�rio informar a data inicial!" ### "Informe a data inicial."
		lRet := .F.
	EndIf

	If lRet .And. Empty(dDataFim)
		JurMsgErro(STR0018,, STR0019) // "� necess�rio informar a data inicial!" ### "Informe a data final."
		lRet := .F.
	EndIf

	If lRet .And. Empty(cCliente) .And. !Empty(cLoja)
		JurMsgErro(STR0023,, STR0024) // "Cliente/Loja inv�lido." "Para utilizar o filtro por 'Loja' � necess�rio indicar o 'Cliente'."
		lRet := .F.
	EndIf
	
	If lRet .And. Empty(cEscrit)
		JurMsgErro(STR0020,, STR0021) // "� necess�rio informar o escrit�rio!" "Informe o escrit�rio."
		lRet := .F.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JP039Relat
Relat�rio de Faturas Pagas

@param  cMoeda   , Moeda do t�tulo
@param  cDataIni , Data inicial de pagamento do T�tulo
@param  cDataFim , Data final de pagamento do T�tulo
@param  cCliente , C�digo do Cliente do t�tulo
@param  cLoja    , C�digo da Loja do Cliente do t�tulo
@param  cEscrit  , Escrit�rio da fatura vinculado ao t�tulo
@param  cNameAuto, Nome do arquivo de relat�rio usado na automa��o

@return lRet     , Indica se o relat�rio foi impresso

@author Jorge Martins / Jonatas Martins / Cristina Cintra
@since  31/07/2019
/*/
//-------------------------------------------------------------------
Static Function JP039Relat(cMoeda, dDataIni, dDataFim, cCliente, cLoja, cEscrit, cNameAuto)
	Local cReportName   := "faturas_pagas_" + FwTimeStamp(1)
	Local cDirectory    := GetSrvProfString( "StartPath", "" )
	Local cFilEscr      := JurGetDados( "NS7", 1, xFilial("NS7") + cEscrit, "NS7_CFILIA" )
	Local lRet          := .T.

	_cSimbMoeda := AllTrim(JurGetDados('CTO', 1, xFilial('CTO') + cMoeda, 'CTO_SIMB'))
	_cDateFt    := cValToChar( Date() )
	_cTimeFt    := Time()

	// Busca dados no banco
	JReportQry(cMoeda, dDataIni, dDataFim, cCliente, cLoja, cEscrit, cFilEscr)

	// Gera relat�rios 
	If (_cAlsRpt)->( ! Eof() )

		_cRazSocEsc := AllTrim((_cAlsRpt)->RAZAOESC)
		_cIdEscrit  := AllTrim((_cAlsRpt)->ESCRITORIO) + " - " + AllTrim((_cAlsRpt)->RAZAOESC)

		PrintReport(cReportName , cDirectory, cNameAuto)
	Else
		lRet := JurMsgErro( STR0022 ) //"N�o foram encontrados dados para impress�o!"
	EndIf

	_nPage := 1 // Contador de p�ginas

	(_cAlsRpt)->( DbCloseArea() )
	IIf(_oTmpOHI != Nil, _oTmpOHI:Delete(), Nil)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PrintReport
Fun��o para gerar PDF do relat�rio de Faturas Pagas.

@param  cReportName, Nome do relat�rio
@param  cDirectory , Caminho da pasta
@param  cNameAuto  , Nome do arquivo de relat�rio usado na automa��o

@author Jorge Martins / Jonatas Martins / Cristina Cintra
@since  31/07/2019
/*/
//-------------------------------------------------------------------
Static Function PrintReport(cReportName, cDirectory, cNameAuto)
	Local oPrinter        := Nil
	Local cNameFile       := cReportName
	Local lAdjustToLegacy := .F.
	Local lDisableSetup   := .T.

	Default cReportName   := FwTimeStamp(1)
	Default cDirectory    := GetSrvProfString("StartPath", "")

	//Configura��es do relat�rio
	If !__lAuto
		oPrinter := FWMsPrinter():New(cNameFile, IMP_PDF, lAdjustToLegacy, cDirectory, lDisableSetup,,, "PDF" )
	Else
		oPrinter := FWMSPrinter():New(cNameAuto, IMP_SPOOL,,, .T.,,,,.T.) // Inicia o relat�rio
		// Alterar o nome do arquivo de impress�o para o padr�o de impress�o automatica
		oPrinter:CFILENAME  := cNameAuto
		oPrinter:CFILEPRINT := oPrinter:CPATHPRINT + oPrinter:CFILENAME
	EndIf
	oPrinter:SetPortrait()
	oPrinter:SetPaperSize(DMPAPER_A4)
	oPrinter:SetMargin(60, 60, 60, 60)

	//Gera nova folha
	NewPage(@oPrinter)

	//Imprime se��o de escrit�rio
	PrintRepData(@oPrinter)

	//Gera arquivo relat�rio
	oPrinter:Print()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} NewPage
Cria nova p�gina do relat�rio.

@param  oPrinter  , Estrutura do relat�rio
@param  lImpTitCol, Indica se imprime os t�tulos das colunas

@author Jorge Martins / Jonatas Martins / Cristina Cintra
@since  31/07/2019
/*/
//-------------------------------------------------------------------
Static Function NewPage(oPrinter, lImpTitCol)

	Default lImpTitCol := .T.
	
	//Inicio P�gina
	oPrinter:StartPage()

	//Monta cabe�alho
	PrintHead(@oPrinter)

	// Monta t�tulos das colunas
	If lImpTitCol
		PrintTitCol(@oPrinter)
	EndIf

	//Imprime Rodap�
	PrintFooter(@oPrinter)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PrintHead
Imprime os dados do cabe�alho.

@param  oPrinter  , Estrutura do relat�rio

@author Jorge Martins / Jonatas Martins / Cristina Cintra
@since  31/07/2019
/*/
//-------------------------------------------------------------------
Static Function PrintHead(oPrinter)
	Local oFontHead  := TFont():New('Arial',, -18,, .T.,,,,, .F., .F.)
	Local oFontHead2 := TFont():New('Arial',, -10,, .F.,,,,, .F., .F.)
	Local oFontHead3 := TFont():New('Arial',, -12,, .T.,,,,, .F., .F.)
	
	// T�tulo do relat�rio
	oPrinter:SayAlign( _nIniVTitulo, _nIniH, STR0001 + " - " + _cSimbMoeda, oFontHead, _nFimH, 200, CLR_BLACK, 2, 1 ) // "Faturas Pagas"
	
	// Raz�o Social do Escrit�rio
	oPrinter:Say( _nIniVEscrit, _nIniH , _cRazSocEsc, oFontHead3, 1200, /*color*/ )
	
	// Detalhes do filtro do relat�rio
	oPrinter:Line( _nIniVTitulo + 25, _nIniH, _nIniVTitulo + 25, _nFimH, CLR_HRED, "-8" )
	oPrinter:SayAlign( _nIniVTitulo + 27, _nIniH, I18N( STR0002, { _cIdEscrit } ), oFontHead2, _nFimH, 200, CLR_BLACK, 1, 1 ) // "Escrit�rio: #1"
	oPrinter:Line( _nIniVTitulo + 39, _nIniH, _nIniVTitulo + 39, _nFimH, CLR_HRED, "-8")

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PrintTitCol
Imprime o t�tulo das colonas do relat�rio.

@param  oPrinter  , Estrutura do relat�rio

@author Jorge Martins / Jonatas Martins / Cristina Cintra
@since  31/07/2019
/*/
//-------------------------------------------------------------------
Static Function PrintTitCol(oPrinter)
	Local oFontTitCol := TFont():New('Arial',, -10,, .T.,,,,, .F., .F.)
	Local nIniV       := _nIniVCabec

	oPrinter:Say( nIniV += _nSalto, _nPCol01, STR0004, oFontTitCol, 1200  , /*color*/)              // "Escrit�rio / Fatura"
	oPrinter:Say( nIniV           , _nPCol02, STR0006, oFontTitCol, 1200  , /*color*/)              // "Nota Fiscal"
	oPrinter:Say( nIniV           , _nPCol03, STR0007, oFontTitCol, 1200  , /*color*/)              // "Vencto."
	oPrinter:Say( nIniV           , _nPCol04, STR0008, oFontTitCol, 1200  , /*color*/)              // "Parcela"
	oPrinter:Say( nIniV           , _nPCol05, STR0009, oFontTitCol, 1200  , /*color*/)              // "Data Pagto"
	oPrinter:SayAlign( nIniV - 8  , _nPCol06, STR0010, oFontTitCol, _nFimH, 1200, CLR_BLACK, 1, 1 ) // "Descontos"
	oPrinter:SayAlign( nIniV - 8  , _nPCol07, STR0013, oFontTitCol, _nFimH, 1200, CLR_BLACK, 1, 1 ) // "Acr�scimos"
	oPrinter:SayAlign( nIniV - 8  , _nPCol08, STR0011, oFontTitCol, _nFimH, 1200, CLR_BLACK, 1, 1 ) // "Vl. Recebido"

	oPrinter:Line( nIniV += 4, _nIniH, nIniV, _nFimH, 0, "-8")
	nIniV += _nSalto

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PrintFooter
Imprime o rodap� do relat�rio.

@param  oPrinter, Estrutura do relat�rio

@author Jorge Martins / Jonatas Martins / Cristina Cintra
@since  31/07/2019
/*/
//-------------------------------------------------------------------
Static Function PrintFooter(oPrinter)
	Local oFontRod := TFont():New('Arial',, -10,, .F.,,,,, .F., .F.)
	Local nLinRod  := 830

	oPrinter:Line( nLinRod, _nIniH, nLinRod, _nFimH, CLR_HRED, "-8")
	nLinRod += _nSalto
	If !__lAuto
		oPrinter:SayAlign( nLinRod, _nIniH, _cDateFt + " - " + _cTimeFt, oFontRod, _nFimH, 200, CLR_BLACK, 2, 1 )
	EndIf
	oPrinter:SayAlign( nLinRod, _nIniH, cValToChar( _nPage )       , oFontRod, _nFimH, 200, CLR_BLACK, 1, 1 )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PrintRepData
Imprime os registros do relat�rio.

@param  oPrinter, Estrutura do relat�rio

@author Jorge Martins / Jonatas Martins / Cristina Cintra
@since  31/07/2019
/*/
//-------------------------------------------------------------------
Static Function PrintRepData(oPrinter)
Local oFontReg    := TFont():New('Arial',, -7 ,, .F.,,,,, .F., .F.)  // Fonte usada na impress�o dos registros
Local oFontSigla  := TFont():New('Arial',, -10,, .T.,,,,, .F., .F.)  // Fonte usada para impress�o da SIGLA do s�cio e cliente
Local nIniV       := _nIniVDados
Local nRegPos     := 1
Local nAbatimento := 0
Local cNmClient   := ""
Local cCliente    := ""
Local cLoja       := ""
Local cNF         := ""
Local cFatAtu     := ""
Local lFatDif     := .F.

	While (_cAlsRpt)->( ! Eof() )

		// Avalia fim da p�gina
		EndPage(@oPrinter, @nIniV, @nRegPos, /*nNewIniV*/)

		// Insere cor nas linhas
		ColorLine(@oPrinter, nIniV, nRegPos)

		// Imprime nome do cliente
		If cCliente != (_cAlsRpt)->CLIENTE .Or. cLoja != (_cAlsRpt)->LOJA

			// Avalia fim da p�gina
			EndPage(@oPrinter, @nIniV, @nRegPos, 3 * _nSalto /*nNewIniV*/)

			cNmClient := AllTrim(I18n("#1/#2 - #3", {(_cAlsRpt)->CLIENTE, (_cAlsRpt)->LOJA, (_cAlsRpt)->NOME}))
			
			oPrinter:Line( nIniV     , _nIniH, nIniV, _nFimH, 0, "-8")
			oPrinter:Line( nIniV += 2, _nIniH, nIniV, _nFimH, 0, "-8")
			
			oPrinter:Say( nIniV += _nSalto, _nIniH, cNmClient, oFontSigla, 1200, /*color*/)
			
			oPrinter:Line( nIniV += 4, _nIniH, nIniV, _nFimH, 0, "-8")
			oPrinter:Line( nIniV += 2, _nIniH, nIniV, _nFimH, 0, "-8")
			nIniV += _nSalto

			cCliente := (_cAlsRpt)->CLIENTE
			cLoja    := (_cAlsRpt)->LOJA
		EndIf
		
		If Empty(AllTrim((_cAlsRpt)->NFISCAL) + AllTrim((_cAlsRpt)->SERIE))
			cNF := ""
		Else
			cNF := AllTrim((_cAlsRpt)->NFISCAL) + " / " + AllTrim((_cAlsRpt)->SERIE)
		EndIf

		nAbatimento := 0

		If (_cAlsRpt)->E1_SALDO == 0
			cFatAtu := (_cAlsRpt)->FATURA

			(_cAlsRpt)->( DbSkip() )
			lFatDif := (_cAlsRpt)->FATURA <> cFatAtu
			(_cAlsRpt)->( DbSkip(-1) )

			If lFatDif
				SE1->(DbGoTo((_cAlsRpt)->RECNOSE1))
				nAbatimento := SomaAbat(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, "R", 1,, SE1->E1_CLIENTE, SE1->E1_LOJA, SE1->E1_FILIAL, SE1->E1_EMISSAO)
			EndIf
		EndIf

		oPrinter:Say( nIniV         , _nPCol01, AllTrim((_cAlsRpt)->ESCRITORIO) + " / " + (_cAlsRpt)->FATURA, oFontReg, 1200  , /*color*/)             // "Escrit�rio / Fatura"
		oPrinter:Say( nIniV         , _nPCol02, cNF                                                , oFontReg, 1200  , /*color*/)             // "Nota Fiscal"
		oPrinter:Say( nIniV         , _nPCol03, DtoC( (_cAlsRpt)->VENCTO)                          , oFontReg, 1200  , /*color*/)             // "Vencto."
		oPrinter:Say( nIniV         , _nPCol04, (_cAlsRpt)->PARCELA                                , oFontReg, 1200  , /*color*/)             // "Parcela"
		oPrinter:Say( nIniV         , _nPCol05, DtoC( (_cAlsRpt)->DATAPAG)                         , oFontReg, 1200  , /*color*/)             // "Data Pagto"
		oPrinter:SayAlign( nIniV - 6, _nPCol06, FormatNum( (_cAlsRpt)->DESCONTOS )                 , oFontReg, _nFimH, 200, CLR_BLACK, 1, 1 ) // "Descontos"
		oPrinter:SayAlign( nIniV - 6, _nPCol07, FormatNum( (_cAlsRpt)->ACRESCIMOS )                , oFontReg, _nFimH, 200, CLR_BLACK, 1, 1 ) // "Acr�scimos"
		oPrinter:SayAlign( nIniV - 6, _nPCol08, FormatNum( (_cAlsRpt)->TOTALRECEB - nAbatimento)   , oFontReg, _nFimH, 200, CLR_BLACK, 1, 1 ) // "Vl. Recebido"

		_aTotalCli[1] += (_cAlsRpt)->DESCONTOS
		_aTotalCli[2] += (_cAlsRpt)->ACRESCIMOS
		_aTotalCli[3] += (_cAlsRpt)->TOTALRECEB - nAbatimento

		nIniV  += _nSalto // Pula linha

		(_cAlsRpt)->( DbSkip() )

		// Avalia quebra de linha
		IsBrokenRep( @oPrinter, @nIniV, @nRegPos, cCliente, cLoja )
		
	EndDo

	//Imprime Total Geral
	PrintTotGer(@oPrinter, nIniV)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PrintTotCli
Imprime subtotal na quebra por Cliente.

@param  oPrinter   , Estrutura do relat�rio
@param  nIniV      , Coordenada vertical inicial
@param  cCliente   , C�digo do Cliente corrente de impress�o
@param  cLoja      , C�digo da Loja do Cliente corrente de impress�o

@author Jorge Martins / Jonatas Martins / Cristina Cintra
@since  31/07/2019
/*/
//-------------------------------------------------------------------
Static Function PrintTotCli(oPrinter, nIniV, cCliente, cLoja)
	Local oFontSubTot := TFont():New('Arial',, -10,, .T.,,,,, .F., .F.)
	Local nVal        := 0

	// Avalia fim da p�gina
	EndPage(@oPrinter, @nIniV, /*nRegPos*/, (2 * _nSalto), /*lImpTitCol*/)

	oPrinter:Line( nIniV - 4, _nIniH, nIniV - 4, _nFimH, 0, "-8")
	oPrinter:SayAlign( nIniV, _nPCol06, FormatNum(_aTotalCli[1]), oFontSubTot, _nFimH, 200, CLR_BLACK, 1, 1 ) // "Descontos"
	oPrinter:SayAlign( nIniV, _nPCol07, FormatNum(_aTotalCli[2]), oFontSubTot, _nFimH, 200, CLR_BLACK, 1, 1 ) // "Acr�scimos"
	oPrinter:SayAlign( nIniV, _nPCol08, FormatNum(_aTotalCli[3]), oFontSubTot, _nFimH, 200, CLR_BLACK, 1, 1 ) // "Vl. Recebido"

	For nVal := 1 To Len(_aTotalCli)
		_aTotalGeral[nVal] += _aTotalCli[nVal]
	Next nVal

	// Limpa o subtotal de cliente
	_aTotalCli := {0, 0, 0}

	nIniV += 2 * _nSalto 

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} PrintTotGer
Imprime Total Geral

@param  oPrinter  , Estrutura do relat�rio
@param  nIniV     , Coordenada vertical inicial

@author Jorge Martins / Jonatas Martins / Cristina Cintra
@since  31/07/2019
/*/
//-------------------------------------------------------------------
Static Function PrintTotGer(oPrinter, nIniV)
	Local oFontTotGer := TFont():New('Arial',, -11,, .T.,,,,, .F., .F.)

	// Avalia fim da p�gina
	EndPage( @oPrinter, @nIniV, /*nRegPos*/, (3 * _nSalto), .F. /*lImpTitCol*/ )

	nIniV += (2 * _nSalto)

	oPrinter:Line( nIniV - 4, _nIniTot, nIniV - 4, _nFimH, 0, "-8")

	oPrinter:SayAlign( nIniV, _nPCol06 - 90, STR0005                   , oFontTotGer, _nFimH, 200, CLR_BLACK, 1, 1 ) // "Total Geral:"
	oPrinter:SayAlign( nIniV, _nPCol06     , FormatNum(_aTotalGeral[1]), oFontTotGer, _nFimH, 200, CLR_BLACK, 1, 1 ) // "Descontos"
	oPrinter:SayAlign( nIniV, _nPCol07     , FormatNum(_aTotalGeral[2]), oFontTotGer, _nFimH, 200, CLR_BLACK, 1, 1 ) // "Acr�scimos"
	oPrinter:SayAlign( nIniV, _nPCol08     , FormatNum(_aTotalGeral[3]), oFontTotGer, _nFimH, 200, CLR_BLACK, 1, 1 ) // "Vl. Recebido"

	_aTotalGeral := {0, 0, 0}

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} EndPage
Avalia quebra de p�gina.

@param  oPrinter  , Estrutura do relat�rio
@param  nIniV     , Coordenada vertical inicial
@param  nRegPos   , Contador de registros
@param  nNewIniV  , Coordenada vertical que ser� verificada
@param  lImpTitCol, Indica se imprime os t�tulos das colunas
@param  lEndForced, Indica se deve ser for�ada a quebra da p�gina
                    Usado quando existe mudan�a de s�cio ou escrit�rio
                    na impress�o

@author Jorge Martins / Jonatas Martins / Cristina Cintra
@since  31/07/2019
/*/
//-------------------------------------------------------------------
Static Function EndPage(oPrinter, nIniV, nRegPos, nNewIniV, lImpTitCol, lEndForced)

	Default nRegPos    := 1
	Default nNewIniV   := 0
	Default lImpTitCol := .T.
	Default lEndForced := .F.

	If lEndForced .Or. ( nIniV + nNewIniV ) >= _nFimV
		nIniV := _nIniVDados
		_nPage += 1
		oPrinter:EndPage()
		NewPage(@oPrinter, lImpTitCol)
		nRegPos := 1
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ColorLine
Muda a cor da linha impressa.

@param   oPrinter, Estrutura do relat�rio
@param   nIniV   , Coordenada vertical inicial
@param   nRegPos , Contador de registros
@param   lForce  , For�a alterar cor da linha
@param   nColor  , Cor da linha

@author Jorge Martins / Jonatas Martins / Cristina Cintra
@since  31/07/2019
/*/
//-------------------------------------------------------------------
Static Function ColorLine(oPrinter, nIniV, nRegPos, lForce, nColor)
	Local aCoords    := {}
	Local oBrush     := Nil
	Local cPixel     := ""

	Default nRegPos  := 1
	Default lForce   := .F.
	Default nColor   := RGB( 224, 224, 224 )

	// Avalia se a linha � impar
	If Mod( nRegPos, 2 ) == 0 .Or. lForce
		oBrush  := TBrush():New( Nil, nColor )
		aCoords := { nIniV - 7, _nIniH, nIniV + 3, _nFimH }
		cPixel  := "-2"
		oPrinter:FillRect( aCoords, oBrush, cPixel )
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} IsBrokenRep
Avalia a quebra de relat�rio. 
Realiza a quebra quando houver mudan�a de cliente.

@param  oPrinter , Estrutura do relat�rio
@param  nIniV    , Coordenada vertical inicial
@param  nRegPos  , Contador de registros
@param  cCliente , C�digo do Cliente
@param  cLoja    , C�digo da Loja do Cliente

@author Jorge Martins / Jonatas Martins / Cristina Cintra
@since  31/07/2019
/*/
//-------------------------------------------------------------------
Static Function IsBrokenRep(oPrinter, nIniV, nRegPos, cCliente, cLoja)
	Local cNovoCli   := (_cAlsRpt)->CLIENTE
	Local cNovaLoja  := (_cAlsRpt)->LOJA

	If (!Empty(cNovoCli) .And. cNovoCli != cCliente) .Or. (!Empty(cLoja) .And. cNovaLoja != cLoja)
		PrintTotCli(@oPrinter, @nIniV, cCliente, cLoja)
		nRegPos := 1
	Else
		nRegPos += 1 // Incrementa contador de registros
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} FormatNum
Coloca a separa��o decimal nos valores num�ricos.

@param  nValue, Numero a ser formatado

@author Jorge Martins / Jonatas Martins / Cristina Cintra
@since  31/07/2019
/*/
//-------------------------------------------------------------------
Static Function FormatNum( nValue )
	Local cNumber  := ""

	Default nValue := 0

	cNumber := AllTrim( TransForm( nValue, PesqPict( "OHH", "OHH_SALDO" ) ) )

Return cNumber

//-------------------------------------------------------------------
/*/{Protheus.doc} JReportQry
Executa a query do relat�rio

@param  cMoeda   , Moeda do t�tulo
@param  cDataIni , Data inicial de pagamento do T�tulo
@param  cDataFim , Data final de pagamento do T�tulo
@param  cCliente , C�digo do Cliente do t�tulo
@param  cLoja    , C�digo da Loja do Cliente do t�tulo
@param  cEscrit  , Escrit�rio da fatura vinculado ao t�tulo
@param  cFilEscr , Filial do Escrit�rio

@author Jonatas Martins
@since  31/07/2019
/*/
//-------------------------------------------------------------------
Static Function JReportQry(cMoeda, dDataIni, dDataFim, cCliente, cLoja, cEscrit, cFilEscr)
	Local cQuery     := ""
	Local nTamFil    := TamSX3("E1_FILIAL")[1]
	Local nTamPrefix := TamSX3("E1_PREFIXO")[1]
	Local nTamNum    := TamSX3("E1_NUM")[1]
	Local nTamParc   := TamSX3("E1_PARCELA")[1]
	Local nTamTipo   := TamSX3("E1_TIPO")[1]
	Local nPosIniPre := nTamFil + 1
	Local nPosIniNum := nTamFil + nTamPrefix + 1
	Local nPosIniPar := nTamFil + nTamPrefix + nTamNum + 1
	Local nPosIniTip := nTamFil + nTamPrefix + nTamNum +  nTamParc + 1
	Local cValMoeda  := cValToChar(Val(cMoeda))
	Local aIndice    := {}
	Local aStruAdic  := J039StruAdc() // Estrutura adicional da tabela tempor�ria
	
	Default cCliente := ""
	Default cLoja    := ""

	cQuery := "SELECT OHI.OHI_CCLIEN CLIENTE, "
	cQuery +=         "OHI.OHI_CLOJA LOJA, "
	cQuery +=         "SA1.A1_NOME NOME, "
	cQuery +=         "OHI.OHI_CESCR ESCRITORIO, "
	cQuery +=         "NS7.NS7_RAZAO RAZAOESC, "
	cQuery +=         "OHI.OHI_CFATUR FATURA, "
	cQuery +=         "NXA.NXA_SERIE SERIE, "
	cQuery +=         "NXA.NXA_DOC NFISCAL, "
	cQuery +=         "SE1.E1_VENCTO VENCTO, "
	cQuery +=         "SE1.E1_PARCELA PARCELA, "
	cQuery +=         "MAX(OHI.OHI_DTAREC) DATAPAG, "
	cQuery +=         "SUM(OHI.OHI_VLDESH + OHI.OHI_VLDESD) DESCONTOS, "
	cQuery +=         "SUM(OHI.OHI_VLACRH + OHI.OHI_VLACRD) ACRESCIMOS, "
	cQuery +=         "SUM(OHI_VLHCAS - OHI_VLDESH + OHI_VLACRH + OHI_VLDCAS - OHI_VLDESD + OHI_VLACRD) TOTALRECEB, "
	cQuery +=         "SE1.E1_PREFIXO PREFIXO, "
	cQuery +=         "SE1.E1_NUM NUMERO, "
	cQuery +=         "SE1.E1_FILIAL E1_FILIAL, "
	cQuery +=         "SE1.E1_SALDO E1_SALDO, "
	cQuery +=         "SE1.E1_EMISSAO EMISSAO, "
	cQuery +=         "SE1.R_E_C_N_O_ RECNOSE1 "
	cQuery +=  "FROM " + RetSqlName("OHI") + " OHI "
	cQuery += "INNER JOIN " + RetSqlName("SA1") + " SA1 "
	cQuery +=    "ON SA1.A1_FILIAL = '" + xFilial("SA1") + "' "
	cQuery +=   "AND SA1.A1_COD = OHI.OHI_CCLIEN "
	cQuery +=   "AND SA1.A1_LOJA = OHI.OHI_CLOJA "
	cQuery +=   "AND SA1.D_E_L_E_T_ = ' ' "
	cQuery += "INNER JOIN " + RetSqlName("NS7") + " NS7 "
	cQuery +=    "ON NS7.NS7_FILIAL = '" + xFilial("NS7") + "' "
	cQuery +=   "AND NS7.NS7_COD = OHI.OHI_CESCR "
	cQuery +=   "AND NS7.D_E_L_E_T_ = ' ' "
	cQuery += "INNER JOIN " + RetSqlName("NXA") + " NXA "
	cQuery +=    "ON NXA.NXA_FILIAL = '" + xFilial("NXA") + "' "
	cQuery +=   "AND NXA.NXA_CESCR = OHI.OHI_CESCR "
	cQuery +=   "AND NXA.NXA_COD = OHI.OHI_CFATUR "
	cQuery +=   "AND NXA.D_E_L_E_T_ = ' ' "
	cQuery += "INNER JOIN " + RetSqlName("SE1") + " SE1 "
	cQuery +=    "ON SE1.E1_FILIAL  = SUBSTRING(OHI.OHI_CHVTIT, 1, " + Str(nTamFil) + ") "
	cQuery +=   "AND SE1.E1_PREFIXO = SUBSTRING(OHI.OHI_CHVTIT, " + Str(nPosIniPre) + ", " + Str(nTamPrefix) + ") "
	cQuery +=   "AND SE1.E1_NUM     = SUBSTRING(OHI.OHI_CHVTIT, " + Str(nPosIniNum) + ", " + Str(nTamNum) + ") "
	cQuery +=   "AND SE1.E1_PARCELA = SUBSTRING(OHI.OHI_CHVTIT, " + Str(nPosIniPar) + ", " + Str(nTamParc) + ") "
	cQuery +=   "AND SE1.E1_TIPO    = SUBSTRING(OHI.OHI_CHVTIT, " + Str(nPosIniTip) + ", " + Str(nTamTipo) + ") "
	cQuery +=   "AND SE1.E1_MOEDA   = " + cValMoeda + " "
	cQuery +=   "AND SE1.D_E_L_E_T_ = ' ' "
	cQuery += "WHERE OHI.OHI_FILIAL = '" + xFilial("OHI", cFilEscr) + "' "
	cQuery +=   "AND OHI.OHI_CESCR  = '" + cEscrit + "' "
	If !Empty(cCliente)
		cQuery += "AND OHI.OHI_CCLIEN = '" + cCliente + "' "
		If !Empty(cLoja)
			cQuery += "AND OHI.OHI_CLOJA  = '" + cLoja + "' "
		EndIf
	EndIf
	cQuery +=   "AND OHI.OHI_DTAREC BETWEEN '" + DtoS(dDataIni) + "' AND '" + DtoS(dDataFim) + "' "
	cQuery +=   "AND OHI.D_E_L_E_T_ = ' ' "
	cQuery += "GROUP BY OHI.OHI_CCLIEN, "
	cQuery +=          "OHI.OHI_CLOJA, "
	cQuery +=          "SA1.A1_NOME, "
	cQuery +=          "OHI.OHI_CESCR, "
	cQuery +=          "NS7.NS7_RAZAO, "
	cQuery +=          "OHI.OHI_CFATUR, "
	cQuery +=          "NXA.NXA_SERIE, "
	cQuery +=          "NXA.NXA_DOC, "
	cQuery +=          "SE1.E1_VENCTO, "
	cQuery +=          "SE1.E1_PARCELA, "
	cQuery +=          "OHI.OHI_DTAREC, "
	cQuery +=          "SE1.E1_PREFIXO, "
	cQuery +=          "SE1.E1_NUM, "
	cQuery +=          "SE1.E1_FILIAL, "
	cQuery +=          "SE1.E1_SALDO, "
	cQuery +=          "SE1.E1_EMISSAO, "
	cQuery +=          "SE1.R_E_C_N_O_ "
	cQuery += "ORDER BY OHI.OHI_CCLIEN, OHI.OHI_CLOJA, OHI.OHI_CESCR, OHI.OHI_CFATUR, SE1.E1_PARCELA "

	cQuery := ChangeQuery(cQuery)

	Aadd(aIndice, {"INDICE", "CLIENTE+LOJA", TAMSX3("OHI_CCLIEN")[1] + TAMSX3("OHI_CLOJA")[1]}) // C�digo + Loja do cliente

	_oTmpOHI := JurCriaTmp(GetNextAlias(), cQuery,, aIndice, aStruAdic,,, .T.,,)[1]
	_cAlsRpt := _oTmpOHI:GetAlias()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JP039Vld
Valida os campos do pergunte JURAPAD039

@param  cCampo, Campo do pergunte
@param  xValor, Valor do campo

@return lRet  , Se o valor est� valido

@author Jorge Martins / Jonatas Martins / Cristina Cintra
@since  31/07/2019
/*/
//-------------------------------------------------------------------
Function JP039Vld(cCampo, xValor)
	Local lRet := .T.
		
	If !Empty(xValor)
		Do Case
			Case cCampo == "1" // Moeda
			lRet := ExistCpo("CTO", xValor, 1, , .T., .F.)

			Case cCampo == "2" // Data Inicial
				lRet := Empty(xValor) .Or. Empty(MV_PAR03) .Or. xValor <= MV_PAR03

			Case cCampo == "3" // Data Final
				lRet := Empty(xValor) .Or. Empty(MV_PAR02) .Or. xValor >= MV_PAR02
			
			Case cCampo == "4" // Cliente
				lRet := Empty(xValor) .Or. JurVldCli("", xValor, "",,, "CLI")
			
			Case cCampo == "5" // Loja
				lRet := Empty(xValor) .Or. JurVldCli("", MV_PAR04, xValor,,, "LOJ")

			Case cCampo == "6" // Loja
				lRet := ExistCpo("NS7", xValor, 1, , .T., .F.)
		EndCase
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J039StruAdc
Estrutura adicional para a tabela tempor�ria

@return aStruAdic, Estrutura adicional do Browse

@author Jorge Martins
@since  11/09/2017
/*/
//-------------------------------------------------------------------
Static Function J039StruAdc()
Local aStruAdic  := {} // Estrutura adicional

	Aadd(aStruAdic, { "CLIENTE"   , "", GetSx3Cache("OHI_CCLIEN", 'X3_TIPO'), TamSX3("OHI_CCLIEN")[1], TamSX3("OHI_CCLIEN")[2], GetSx3Cache("OHI_CCLIEN", 'X3_PICTURE'), "OHI_CCLIEN" } )
	Aadd(aStruAdic, { "LOJA"      , "", GetSx3Cache("OHI_CLOJA" , 'X3_TIPO'), TamSX3("OHI_CLOJA" )[1], TamSX3("OHI_CLOJA" )[2], GetSx3Cache("OHI_CLOJA" , 'X3_PICTURE'), "OHI_CLOJA"  } )
	Aadd(aStruAdic, { "NOME"      , "", GetSx3Cache("A1_NOME"   , 'X3_TIPO'), TamSX3("A1_NOME"   )[1], TamSX3("A1_NOME"   )[2], GetSx3Cache("A1_NOME"   , 'X3_PICTURE'), "A1_NOME"    } )
	Aadd(aStruAdic, { "ESCRITORIO", "", GetSx3Cache("OHI_CESCR" , 'X3_TIPO'), TamSX3("OHI_CESCR" )[1], TamSX3("OHI_CESCR" )[2], GetSx3Cache("OHI_CESCR" , 'X3_PICTURE'), "OHI_CESCR"  } )
	Aadd(aStruAdic, { "RAZAOESC"  , "", GetSx3Cache("NS7_RAZAO" , 'X3_TIPO'), TamSX3("NS7_RAZAO" )[1], TamSX3("NS7_RAZAO" )[2], GetSx3Cache("NS7_RAZAO" , 'X3_PICTURE'), "NS7_RAZAO"  } )
	Aadd(aStruAdic, { "FATURA"    , "", GetSx3Cache("OHI_CFATUR", 'X3_TIPO'), TamSX3("OHI_CFATUR")[1], TamSX3("OHI_CFATUR")[2], GetSx3Cache("OHI_CFATUR", 'X3_PICTURE'), "OHI_CFATUR" } )
	Aadd(aStruAdic, { "SERIE"     , "", GetSx3Cache("NXA_SERIE" , 'X3_TIPO'), TamSX3("NXA_SERIE" )[1], TamSX3("NXA_SERIE" )[2], GetSx3Cache("NXA_SERIE" , 'X3_PICTURE'), "NXA_SERIE"  } )
	Aadd(aStruAdic, { "NFISCAL"   , "", GetSx3Cache("NXA_DOC"   , 'X3_TIPO'), TamSX3("NXA_DOC"   )[1], TamSX3("NXA_DOC"   )[2], GetSx3Cache("NXA_DOC"   , 'X3_PICTURE'), "NXA_DOC"    } )
	Aadd(aStruAdic, { "VENCTO"    , "", GetSx3Cache("E1_VENCTO" , 'X3_TIPO'), TamSX3("E1_VENCTO" )[1], TamSX3("E1_VENCTO" )[2], GetSx3Cache("E1_VENCTO" , 'X3_PICTURE'), "E1_VENCTO"  } )
	Aadd(aStruAdic, { "PARCELA"   , "", GetSx3Cache("E1_PARCELA", 'X3_TIPO'), TamSX3("E1_PARCELA")[1], TamSX3("E1_PARCELA")[2], GetSx3Cache("E1_PARCELA", 'X3_PICTURE'), "E1_PARCELA" } )
	Aadd(aStruAdic, { "DATAPAG"   , "", GetSx3Cache("OHI_DTAREC", 'X3_TIPO'), TamSX3("OHI_DTAREC")[1], TamSX3("OHI_DTAREC")[2], GetSx3Cache("OHI_DTAREC", 'X3_PICTURE'), "OHI_DTAREC" } )
	Aadd(aStruAdic, { "DESCONTOS" , "", GetSx3Cache("OHI_VLDESH", 'X3_TIPO'), TamSX3("OHI_VLDESH")[1], TamSX3("OHI_VLDESH")[2], GetSx3Cache("OHI_VLDESH", 'X3_PICTURE'), "OHI_VLDESH" } )
	Aadd(aStruAdic, { "ACRESCIMOS", "", GetSx3Cache("OHI_VLACRH", 'X3_TIPO'), TamSX3("OHI_VLACRH")[1], TamSX3("OHI_VLACRH")[2], GetSx3Cache("OHI_VLACRH", 'X3_PICTURE'), "OHI_VLACRH" } )
	Aadd(aStruAdic, { "TOTALRECEB", "", GetSx3Cache("OHI_VLHCAS", 'X3_TIPO'), TamSX3("OHI_VLHCAS")[1], TamSX3("OHI_VLHCAS")[2], GetSx3Cache("OHI_VLHCAS", 'X3_PICTURE'), "OHI_VLHCAS" } )
	Aadd(aStruAdic, { "PREFIXO"   , "", GetSx3Cache("E1_PREFIXO", 'X3_TIPO'), TamSX3("E1_PREFIXO")[1], TamSX3("E1_PREFIXO")[2], GetSx3Cache("E1_PREFIXO", 'X3_PICTURE'), "E1_PREFIXO" } )
	Aadd(aStruAdic, { "NUMERO"    , "", GetSx3Cache("E1_NUM"    , 'X3_TIPO'), TamSX3("E1_NUM"    )[1], TamSX3("E1_NUM"    )[2], GetSx3Cache("E1_NUM"    , 'X3_PICTURE'), "E1_NUM"     } )
	Aadd(aStruAdic, { "EMISSAO"   , "", GetSx3Cache("E1_EMISSAO", 'X3_TIPO'), TamSX3("E1_EMISSAO")[1], TamSX3("E1_EMISSAO")[2], GetSx3Cache("E1_EMISSAO", 'X3_PICTURE'), "E1_EMISSAO" } )
	Aadd(aStruAdic, { "RECNOSE1"  , "", "N", 16                   ,  0, "", "" } ) // "Recno"

Return aStruAdic