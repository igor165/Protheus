#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TOPCONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "JURR201A.CH"

#DEFINE nIniDados  100    // Inicio da impressão do relatorio na folha
#DEFINE nSalto     10    // Inicio da impressão do relatorio na folha
#DEFINE cDateFt    cValToChar(Date()) // Data - Footer
#DEFINE cTimeFt    Time()             // Hora - Footer

Static nPage   := 1    // Contador de páginas
Static __lAuto := .F. // Execução via automação de testes

//-------------------------------------------------------------------
/*/{Protheus.doc} JURR201A
Relatório de Participantes sem valor na tabela de honorários.

@param  cPrefat    Código da Pré-fatura
@param  lPDUserAc  Indica se o usuário possui acesso a dados 
                   sensíveis/pessoais (LGPD)

@Obs O reletório é montado com base na estrutura de uma pré-fatura 
utilizando os mesmos filtros da tela de emissão mas somente com os 
lançamentos dos participantes sem valor na tabela de honorários.

@author Luciano Pereira dos Santos
@since 04/09/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURR201A(cPrefat, lPDUserAc, lAutomato, cNameAuto)
	Local lRet      := .T.

	Default cPrefat   := ''
	Default lPDUserAc := .T.
	Default lAutomato := .F.
	Default cNameAuto := ''

	__lAuto := lAutomato

	lRet := PrintReport(cPrefat, lPDUserAc, lAutomato, cNameAuto)

	If !lRet
		ApMsgInfo( STR0002 ) //"Não foram encontrados dados para impressão!"
	EndIf

Return lRet


//=======================================================================
/*/{Protheus.doc} PrintReport
Função para gerar PDF do relatório de Participantes sem valor na tabela 
de honorário.

@param  cPrefat    Código da Pré-fatura
@param  lPDUserAc  Indica se o usuário possui acesso a dados 
                   sensíveis/pessoais (LGPD)

@author Luciano Pereira dos Santos
@since 04/09/2018
/*/
//=======================================================================
Static Function PrintReport(cPrefat, lPDUserAc, lAutomato, cNameAuto)
	Local lRet            := .T.
	Local oPrinter        := Nil 
	Local cNameFile       := "JU201A_" + FwTimeStamp(1)
	Local nIniH           := 0   // Coordenada horizontal inicial
	Local nFimH           := 560 // Coordenada horizontal final
	Local nMargem         := 60  // Margens da Folha
	Local lAdjustToLegacy := .F.
	Local lDisableSetup   := .T.
	Local cDirectory      := ""
	Local lViewPDF        := IIf(lPDUserAc, .T., .F.)

	If lPDUserAc
		cDirectory := GetSrvProfString("StartPath", "")
	Else
		cDirectory := GetSrvProfString("RootPath" , "") + "\" + JurFixPath((SuperGetMV("MV_JPASPRE",, "")), 2, 1)
	EndIf

	//Configurações do relatório
	If lRet := NX0->(DbSeek(xFilial("NX0") + cPrefat))
		If __lAuto //Alterar o nome do arquivo de impressão para o padrão de impressão automatica
			oPrinter := FWMsPrinter():New(cNameAuto, IMP_SPOOL,,, .T.,,,) // Inicia o relatório
			oPrinter:CFILENAME  := cNameAuto
			oPrinter:CFILEPRINT := oPrinter:CPATHPRINT + oPrinter:CFILENAME
		Else
			oPrinter := FWMsPrinter():New( cNameFile, IMP_PDF, lAdjustToLegacy, cDirectory, lDisableSetup,,,,,,,lViewPDF)
		EndIf
		oPrinter:SetPortrait()
		oPrinter:SetPaperSize(DMPAPER_A4)
		oPrinter:SetMargin(nMargem, nMargem, nMargem, nMargem)
		If !lPDUserAc
			oPrinter:cPathPDF := cDirectory
		EndIf

		//Gera nova folha
		NewPage( @oPrinter , nIniH , nFimH)

		//Imprime seção de escritório	 
		PrintRepData(@oPrinter , nIniH , nFimH, cPrefat)

		oPrinter:EndPage()

		//Gera arquivo relatório
		oPrinter:Print()
	EndIf

Return lRet


//=======================================================================
/*/{Protheus.doc} NewPage
Cria nova página do relatório.

@param  oPrinter   Objeto do relatório
@param  nIniH      Coordenada horizontal inicial
@param  nFimH      Coordenada horizontal final
@param  lImpCabec  Imprime o cabeçalho dos dados

@author Luciano Pereira dos Santos
@since 05/09/2018
/*/
//=======================================================================
Static Function NewPage(oPrinter , nIniH , nFimH, lImpCabec)
	Default lImpCabec := .F.

	//Inicio Página
	oPrinter:StartPage()

	//Monta cabeçalho
	PrintHead( @oPrinter , nIniH , nFimH, lImpCabec)

	//Imprime Rodapé
	PrintFooter( @oPrinter , nIniH , nFimH )

Return Nil


//=======================================================================
/*/{Protheus.doc} PrintHead
Imprime dados do cabeçalho.

@param  oPrinter   , objeto     , Estrutra do relatório
@param  nIniH      , numerico   , Coordenada horizontal inicial
@param  nFimH      , numerico   , Coordenada horizontal final
@param  lImpCabec  , lógico     , Imprime o cabeçalho dos dados

@author Luciano Pereira dos Santos
@since  05/09/2018
/*/
//=======================================================================
Static Function PrintHead(oPrinter , nIniH , nFimH, lImpCabec)
	Local oFontHead  := Nil
	Local oFontBold  := Nil
	Local nIniV      := nIniDados //inicio da impressão do dados

	Default lImpCabec := .F.

	oFontHead  := TFont():New('Arial',,-20,,.T.,,,,,.F.,.F.)
	oFontBold  := TFont():New('Arial',,  9,,.T.,,,,,.F.,.F.)
	
	//---------------------
	// Título do relatório
	//---------------------
	oPrinter:SayAlign( 045, nIniH, STR0003, oFontHead, nFimH, 200, CLR_BLACK, 2, 1 ) //"Participantes com inconsistências no valor de honorários"

	//---------------------
	// Linha separadora
	//---------------------		
	oPrinter:Line( 70, nIniH, 70, nFimH, CLR_BLACK, "-8")

	If lImpCabec
		oPrinter:Say( nIniV     , nIniH + 30  , STR0004 , oFontBold , 1200 ,/*color*/) // 'Sigla - Participante'
		oPrinter:Say( nIniV     , nIniH + 450 , STR0005 , oFontBold , 1200 ,/*color*/) // 'Ano-Mês do Lançamento'
		oPrinter:Line( nIniV + 2, nIniH + 30  , nIniV + 2, nFimH, 0, "-1")
	EndIf

Return Nil


//=======================================================================
/*/{Protheus.doc} PrintFooter
Imprimide rodapé do cabeçalho.

@param  oPrinter, objeto   , Estrutra do relatório
@param  nIniH   , numerico , Coordenada horizontal inicial
@param  nFimH   , numerico , Coordenada horizontal final

@author Luciano Pereira dos Santos
@since  05/09/2018
/*/
//=======================================================================
Static Function PrintFooter(oPrinter , nIniH , nIniF )
	Local oFontRod := Nil
	Local nLinRod  := 830

	oFontRod := TFont():New('Arial',,-10,,.F.,,,,,.F.,.F.)

	oPrinter:Line( nLinRod, nIniH, nLinRod, nIniF, CLR_BLACK, "-8")
	nLinRod += nSalto
	If !__lAuto
		oPrinter:SayAlign( nLinRod, nIniH, cDateFt + " - " + cTimeFt, oFontRod, nIniF, 200, CLR_BLACK, 2, 1 )
		oPrinter:SayAlign( nLinRod, nIniH, cValToChar( nPage )      , oFontRod, nIniF, 200, CLR_BLACK, 1, 1 )
	EndIf

Return Nil


//=======================================================================
/*/{Protheus.doc} PrintRepData(oPrinter , nIniH , nFimH , cPrefat)
Imprime registros do relatório.

@param  oPrinter  Objeto do relatório
@param  nIniH     Coordenada horizontal inicial
@param  nFimH     Coordenada horizontal final
@param  cPrefat   Código da Pré-fatura

@author Luciano Pereira dos Santos / Bruno Ritter
@since  28/03/2018
/*/
//=======================================================================
Static Function PrintRepData(oPrinter , nIniH , nFimH , cPrefat)
	Local oFontReg   := Nil
	Local oFontTit   := Nil
	Local oFontBold  := Nil
	Local nIniV      := nIniDados //inicio da impressão do dados
	Local aCasos     := ReportQry(cPrefat)
	Local aTabHon    := {}
	Local aPart      := {}
	Local nCaso      := 0
	Local nTab       := 0
	Local nCat       := 0
	Local nPart      := 0
	Local nPosTit    := 1
	Local nPosSub    := 2
	Local cTitulo    := ''
	Local cAnoMes    := ''
	Local cPicture   := X3Picture('NUE_ANOMES')
	Local nSaltoTit := nSalto + 5 //Espaço adicional entre os
	
	oFontReg  := TFont():New('Arial',,  9,,.F.,,,,,.F.,.F.)
	oFontBold := TFont():New('Arial',,  9,,.T.,,,,,.F.,.F.)
	oFontTit  := TFont():New('Arial',, 12,,.F.,,,,,.F.,.F.)

	For nCaso := 1 to Len(aCasos)

		EndPage( @oPrinter , nIniH , nFimH , @nIniV , (nSaltoTit * 3) + nSalto /*nNewIniV*/)

		cTitulo := aCasos[nCaso][nPosTit]
		oPrinter:Say( nIniV ,   nIniH , cTitulo,  oFontTit , 1200 ,/*color*/) //Titulo do caso
		oPrinter:Line( nIniV + 2, nIniH, nIniV + 2, nFimH, 0, "-1")

		nIniV   += nSaltoTit // Pula linha

		aTabHon := aCasos[nCaso][nPosSub]

		For nTab := 1 to Len(aTabHon)

			EndPage( @oPrinter , nIniH , nFimH , @nIniV , (nSaltoTit * 2) + nSalto /*nNewIniV*/)

			cTitulo := aTabHon[nTab][nPosTit]
			oPrinter:Say( nIniV ,   nIniH + 10 , cTitulo, oFontTit , 1200 ,/*color*/) //Tabela de honorarios
			oPrinter:Line( nIniV + 2, nIniH +10, nIniV + 2, nFimH, 0, "-1")

			nIniV   += nSaltoTit // Pula linha

			aCateg  := aTabHon[nTab][nPosSub]

			For nCat := 1 to Len(aCateg)

				EndPage( @oPrinter , nIniH , nFimH , @nIniV , nSaltoTit + nSalto /*nNewIniV*/)

				cTitulo := aCateg[nCat][nPosTit]
				oPrinter:Say( nIniV     , nIniH + 20, cTitulo  , oFontTit , 1200 ,/*color*/) //Categoria
				oPrinter:Line( nIniV + 2, nIniH + 20, nIniV + 2, nFimH, 0 , "-1")

				nIniV   += nSaltoTit // Pula linha

				aPart   := aCateg[nCat][nPosSub]

				oPrinter:Say( nIniV     , nIniH + 30  , STR0004  , oFontBold , 1200 ,/*color*/) // 'Sigla - Participante'
				oPrinter:Say( nIniV     , nIniH + 450 , STR0005  , oFontBold , 1200 ,/*color*/) // 'Ano-Mês do Lançamento'
				oPrinter:Line( nIniV + 2, nIniH + 30  , nIniV + 2, nFimH, 0  , "-1")

				nIniV   += nSalto // Pula linha

				For nPart := 1 to Len(aPart)
					EndPage( @oPrinter , nIniH , nFimH , @nIniV , 0 /*nNewIniV*/, .T.)

					ColorLine( @oPrinter , nIniH + 30 , nFimH , nIniV , nPart )

					cTitulo := aPart[nPart][nPosTit]
					cAnoMes := Transform(aPart[nPart][2], cPicture)

					oPrinter:Say( nIniV     , nIniH + 30  , cTitulo  , oFontReg , 1200 ,/*color*/) //Participante
					oPrinter:Say( nIniV     , nIniH + 450 , cAnoMes  , oFontReg , 1200 ,/*color*/) 

					nIniV   += Iif(nPart == Len(aPart), nSaltoTit * 2, nSalto)   // Pula linha

				Next nPart
			Next nCAt
		Next nTab
	Next nCaso

Return Nil


//=======================================================================
/*/{Protheus.doc} ReportQry(cPrefat)
Monta alias com os dados para gerar o relatório de Participantes para sem valor

@param  cPrefat      Código da Pré-fatura

@Obs O reletório é montado com base na estrutura de uma pré-fatura 
utilizando os mesmos filtros da tela de emissão mas somente com os 
lançamentos dos participantes sem valor na tabela de honorários.

@author Luciano Pereira dos Santos / Bruno Ritter
@since  10/09/2018
/*/
//=======================================================================
Static Function ReportQry(cPrefat)
	Local aRet       := {}
	Local cQuery     := ''
	Local cQryRes    := GetNextAlias()
	Local cSpaceAM   := Criavar('NUE_ANOMES', .F.)
	Local nSubArray  := 2
	Local cKeyCaso   := ''
	Local nPosCaso   := 0
	Local cTitCaso   := ''
	Local cKeyTabH   := CriaVar('NRF_COD', .F.)
	Local nPosTabH   := 0
	Local cTitTabH   := ''
	Local cKeyCat    := CriaVar('NRN_COD', .F.)
	Local nPosCat    := 0
	Local cTitCat    := ''
	Local cTitPart   := ''
	
	cQuery := " SELECT DISTINCT NVE.NVE_CCLIEN, NVE.NVE_LCLIEN, NVE.NVE_NUMCAS, NVE.NVE_TITULO, NRF.NRF_COD, NRF.NRF_DESC, "
	cQuery +=                 " NRN.NRN_COD, NRN.NRN_DESC, RD0.RD0_SIGLA, RD0.RD0_NOME, NUE.NUE_ANOMES "
	cQuery +=   " FROM " + RetSqlName("NW0") + " NW0 "
	cQuery +=  " INNER JOIN " + RetSqlName("NUE") + " NUE "
	cQuery +=          " ON NUE.NUE_FILIAL = '" + xFilial("NUE") + "' "
	cQuery +=         " AND NUE.NUE_COD = NW0.NW0_CTS "
	cQuery +=         " AND NUE.D_E_L_E_T_ = ' ' "
	cQuery +=  " INNER JOIN " + RetSqlName("NVE") + " NVE " 
	cQuery +=          " ON NVE.NVE_FILIAL = '" + xFilial("NVE") + "' "
	cQuery +=         " AND NVE.NVE_CCLIEN = NUE.NUE_CCLIEN "
	cQuery +=         " AND NVE.NVE_LCLIEN = NUE.NUE_CLOJA "
	cQuery +=         " AND NVE.NVE_NUMCAS = NUE.NUE_CCASO "
	cQuery +=         " AND NVE.D_E_L_E_T_ = ' ' "
	cQuery +=   " LEFT JOIN " + RetSqlName("NUU") + " NUU " // Histórico do Caso
	cQuery +=          " ON NUU.NUU_FILIAL = '" + xFilial("NUU") + "' "
	cQuery +=         " AND NUU.NUU_CCLIEN = NVE.NVE_CCLIEN "
	cQuery +=         " AND NUU.NUU_CLOJA = NVE.NVE_LCLIEN "
	cQuery +=         " AND NUU.NUU_CCASO = NVE.NVE_NUMCAS "
	cQuery +=         " AND (( NUU.NUU_AMINI <= NUE.NUE_ANOMES AND NUU.NUU_AMFIM = '" + cSpaceAM + "') "
	cQuery +=              " OR ( NUU.NUU_AMINI <= NUE.NUE_ANOMES AND NUU.NUU_AMFIM >= NUE.NUE_ANOMES)) "
	cQuery +=         " AND NUU.D_E_L_E_T_ = ' ' "
	cQuery +=   " LEFT JOIN " + RetSqlName("NRF") + " NRF " // Tabela de Honorários
	cQuery +=          " ON NRF.NRF_FILIAL = '" + xFilial("NRF") + "' "
	cQuery +=         " AND NRF.NRF_COD = NUU.NUU_CTABH "
	cQuery +=         " AND NRF.D_E_L_E_T_ = ' ' "
	cQuery +=  " INNER JOIN " + RetSqlName("RD0") + " RD0 "
	cQuery +=          " ON RD0.RD0_FILIAL = '" + xFilial("RD0") + "' "
	cQuery +=         " AND RD0.RD0_CODIGO = NUE.NUE_CPART2 "
	cQuery +=         " AND RD0.D_E_L_E_T_ = ' ' "
	cQuery +=   " LEFT JOIN " + RetSqlName("NUS") + " NUS " // Histórico da Categoria
	cQuery +=          " ON NUS.NUS_FILIAL = '" + xFilial("NUS") + "' "
	cQuery +=         " AND NUS.NUS_CPART = RD0.RD0_CODIGO "
	cQuery +=         " AND (( NUS.NUS_AMINI <= NUE.NUE_ANOMES AND NUS.NUS_AMFIM = '" + cSpaceAM + "') "
	cQuery +=              " OR ( NUS.NUS_AMINI <= NUE.NUE_ANOMES AND NUS.NUS_AMFIM >= NUE.NUE_ANOMES)) "
	cQuery +=         " AND NUS.D_E_L_E_T_ = ' ' "
	cQuery +=   " LEFT JOIN " + RetSqlName("NRN") + " NRN "
	cQuery +=          " ON NRN.NRN_FILIAL = '" + xFilial("NRN") + "' "
	cQuery +=         " AND NRN.NRN_COD = NUS.NUS_CCAT "
	cQuery +=         " AND NRN.D_E_L_E_T_ = ' ' "
	cQuery +=   " WHERE NW0.NW0_FILIAL = '" + xFilial("NW0") + "' " 
	cQuery +=     " AND NW0.NW0_PRECNF = '" + cPrefat + "' "
	cQuery +=     " AND NW0.D_E_L_E_T_ = ' ' "
	cQuery +=   " ORDER BY NVE.NVE_CCLIEN, NVE.NVE_LCLIEN, NVE.NVE_NUMCAS, NRF.NRF_COD, NRN.NRN_COD, RD0.RD0_SIGLA, NUE.NUE_ANOMES"

	cQuery := ChangeQuery( cQuery )

	DbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cQryRes , .T. , .T. )

	While !(cQryRes)->(EOF())

		If cKeyCaso != (cQryRes)->NVE_CCLIEN + (cQryRes)->NVE_LCLIEN + (cQryRes)->NVE_NUMCAS  // Quebra por Caso
			cKeyCaso := (cQryRes)->NVE_CCLIEN + (cQryRes)->NVE_LCLIEN + (cQryRes)->NVE_NUMCAS
			cTitCaso := TituloCaso(cQryRes)
			nPosCaso += 1
			Aadd(aRet, { Alltrim(cTitCaso), {} })
			cKeyTabH := ''
			nPosTabH := 0
			cKeyCat  := ''
			nPosCat  := 0
		EndIf

		If cKeyTabH != (cQryRes)->NRF_COD .Or. nPosTabH == 0 // Quebra por Tabela de honorários
			cKeyTabH := (cQryRes)->NRF_COD

			If Empty( (cQryRes)->NRF_COD )
				cTitTabH := STR0006 // 'Tabela de honorários não identificada'
			Else
				cTitTabH := STR0007 + (cQryRes)->NRF_COD + ' - ' + (cQryRes)->NRF_DESC // 'Tabela de honorários: '
			EndIf

			nPosTabH += 1
			Aadd(aRet[nPosCaso][nSubArray], { Alltrim(cTitTabH), {} })
			cKeyCat  := ''
			nPosCat  := 0
		EndIf

		If cKeyCat != (cQryRes)->NRN_COD .Or. nPosCat == 0 // Quebra por categoria
			cKeyCat  := (cQryRes)->NRN_COD

			If Empty( (cQryRes)->NRN_COD )
				cTitCat := STR0008 // 'Categoria não identificada'
			Else
				cTitCat := STR0009 + (cQryRes)->NRN_COD + ' - ' + (cQryRes)->NRN_DESC // 'Categoria: '
			EndIf

			nPosCat  += 1
			Aadd(aRet[nPosCaso][nSubArray][nPosTabH][nSubArray], { Alltrim(cTitCat), {} })
		EndIf

		cTitPart := AllTrim((cQryRes)->RD0_SIGLA) + " - " + AllTrim((cQryRes)->RD0_NOME)

		Aadd(aRet[nPosCaso][nSubArray][nPosTabH][nSubArray][nPosCat][nSubArray], { Alltrim(cTitPart), (cQryRes)->NUE_ANOMES} )

		(cQryRes)->(dbSkip())
	EndDo

	(cQryRes)->( dbcloseArea())

Return aRet


//=======================================================================
/*/{Protheus.doc} TituloCaso(cQuery)
Monta o Titulo do caso para o relatorio de Participantes sem valor de honorarios

@param  cQuery    Area da query do relatório

@Return cTitulo   Titulo do caso conforme os paramentos MV_JCASO1 e MV_JLOJAUT

@author Luciano pereira dos Santos
@since  06/09/2018
/*/
//=======================================================================
Static Function TituloCaso(cQryRes)
Local cMVJcaso1 := SuperGetMV('MV_JCASO1',,'1') //Defina a sequência da numeração do Caso. (1- Por cliente;2- Independente do cliente.)
Local cLojaAuto := SuperGetMV('MV_JLOJAUT', .F., '2', ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local cTitulo   := STR0010 //'Caso : '

If cMVJcaso1 == '1'
	If cLojaAuto == '1'
		cTitulo  += (cQryRes)->NVE_CCLIEN + ' - ' + (cQryRes)->NVE_NUMCAS + ' - ' + (cQryRes)->NVE_TITULO
	Else
		cTitulo  += (cQryRes)->NVE_CCLIEN + '/' + (cQryRes)->NVE_LCLIEN  + ' - ' + (cQryRes)->NVE_NUMCAS + ' - ' + (cQryRes)->NVE_TITULO
	Endif
Else
	cTitulo  += (cQryRes)->NVE_NUMCAS + ' - ' + (cQryRes)->NVE_TITULO
EndIf

Return cTitulo


//=======================================================================
/*/{Protheus.doc} EndPage()
Avalia quebra de página.

@param  oPrinter   , objeto     , Estrutra do relatório
@param  nIniH      , numerico   , Coordenada horizontal inicial
@param  nFimH      , numerico   , Coordenada horizontal final
@param  nIniV      , numerico   , Coordenada vertical inicial
@param  nNewIniV   , numerico   , Coordenada vertical que será verificada

@author  Luciano Pereira dos Santos / Bruno Ritter
@since  28/03/2018
/*/
//=======================================================================
Static Function EndPage( oPrinter , nIniH , nFimH , nIniV, nNewIniV, lImpCabec)
	Local nIFimV       := 825  // Coordenada vertical final

	Default nNewIniV   := 0
	Default lImpCabec  := .F.

	If ( nIniV + nNewIniV ) >= nIFimV
		nIniV  := Iif(lImpCabec, nSalto, 0) + nIniDados //inicio da impressão do dados
		nPage  += 1
		oPrinter:EndPage()
		NewPage( @oPrinter , nIniH , nFimH, lImpCabec)
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

@author  Luciano Pereira dos Santos / Bruno Ritter
@since   28/03/2018
/*/
//=======================================================================
Static Function ColorLine( oPrinter , nIniH , nFimH , nIniV , nRegPos )
	Local aCoords := {}
	Local oBrush  := Nil
	Local cPixel  := ""
	Local nColor  := RGB( 220 , 220 , 220 )

	Default nRegPos := 1

	//-----------------------------
	// Avalia se a linha é impar
	//-----------------------------
	If Mod( nRegPos , 2 ) == 0
		oBrush  :=  TBrush():New( Nil , nColor )
		aCoords := { nIniV - 8 , nIniH , nIniV + 2 , nFimH }
		cPixel  := "-2"
		oPrinter:FillRect( aCoords , oBrush , cPixel )
	EndIf
Return Nil
