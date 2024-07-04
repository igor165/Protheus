#INCLUDE "PROTHEUS.CH" 
#INCLUDE "TOPCONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "JURAPAD036.CH"

#DEFINE nSalto    10     // Salto de uma linha a outra

//-------------------------------------------------------------------
/*/{Protheus.doc} JURAPAD036
Relatório de Aviso de Cobrança

@param  oTempTable, objeto   , Objeto da Tabela Temporária (Cobrança)
@param  cTipoSaida, caractere , Tipo de saída do relatório
                               1 - Impressora;
                               2 - Tela;
                               3 - Salvar em disco
@param  cPath     , caractere, Caminho em que o arquivo deve ser salvo
                               Usado somente quando cTipoSaida = 3
@param  cSocio    , caractere, Sócio filtrado para cobrança

@return lRet      , lógico   , Indica se a emissão foi realizada 
                               corretamente

@author Jorge Martins
@since  01/11/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURAPAD036(oTempTable, cTipoSaida, cPath, cSocio, lAutomato, cNomeArq)
Local cNameTbTmp    := oTempTable:GetRealName()
Local cAlsTmp       := oTempTable:GetAlias()
Local cCliente      := ""
Local cLoja         := ""
Local nRecTmp       := ""
Local cReportName   := ""
Local cDestPath     := ""
Local lRet          := .T.
Local aFaturas      := {}
Local aAreas        := { (cAlsTmp)->(GetArea()), GetArea() }

Default lAutomato := .F. 
Default cNomeArq := ""

	If Empty(cPath) // Caso a impressão seja em TELA ou IMPRESSORA usa o StartPath do PROTHEUS
		cDestPath := GetSrvProfString( "StartPath" , "" )
	Else
		cDestPath := cPath
	EndIf

	cCliente := (cAlsTmp)->E1_CLIENTE
	cLoja    := (cAlsTmp)->E1_LOJA
	nRecTmp  := (cAlsTmp)->(Recno())

	// Nome do relatório
	cReportName := STR0001 // "Aviso_de_Cobranca_"

	// Busca Faturas no Banco
	aFaturas := JReportQry( cNameTbTmp, nRecTmp, cSocio )

	PrintReport( cReportName, cDestPath, aFaturas, cAlsTmp, cTipoSaida, lAutomato, cNomeArq )

	aSize(aFaturas, 0)

	Aeval( aAreas , {|aArea| RestArea( aArea ) } )
Return lRet

//=======================================================================
/*/{Protheus.doc} JReportQry
Busca faturas do cliente indicado

@param  cNameTbTmp , caractere, Nome da Tabela Temporária
@param  nRecTmp    , numérico , Recno do registro da tabela temporária que vai ser impresso
@param  cSocio     , caractere, Sócio filtrado para cobrança

@return aFaturas   , array    , Informações sobre as faturas do cliente

@author Jorge Martins
@since  05/11/2018
/*/
//=======================================================================
Static Function JReportQry( cNameTbTmp, nRecTmp, cSocio )
Local cQuery     := ""
Local nTamFil    := TamSX3("NXA_FILIAL")[1]
Local nTamEsc    := TamSX3("NXA_CESCR")[1]
Local cTamFilial := cValToChar(nTamFil)
Local cIniEscr   := cValToChar(nTamFil+2)
Local cTamEscr   := cValToChar(nTamEsc)
Local cIniFatur  := cValToChar(nTamFil+1+nTamEsc+2)
Local cTamFatur  := cValToChar(TamSX3("NXA_COD")[1])
Local aFaturas   := {}
Local lExistOHT  := AliasInDic("OHT")
Local lIntPFS    := lExistOHT .And. SuperGetMV("MV_JURXFIN",, .F.) // Integração SIGAPFS x SIGAFIN

	cQuery :=    " SELECT NXA.NXA_COD, NXA.NXA_DTVENC, SUM(SE1.E1_SALDO) TOTAL "
	cQuery +=      " FROM " + cNameTbTmp + " TABTMP "

	// Dados do Título
	cQuery +=     " INNER JOIN " + RetSqlName('SE1') + " SE1 "
	cQuery +=        " ON SE1.E1_FILIAL = '" + xFilial("SE1") + "' "
	cQuery +=       " AND SE1.E1_CLIENTE = TABTMP.E1_CLIENTE "
	cQuery +=       " AND SE1.E1_LOJA = TABTMP.E1_LOJA "
	cQuery +=       " AND SE1.E1_SALDO > 0 "
	cQuery +=       " AND SE1.E1_VENCTO < '" + DtoS(Date()) + "' "
	cQuery +=       " AND SE1.D_E_L_E_T_ = ' ' "
	If lIntPFS

		// Dados da Fatura
		cQuery += " INNER JOIN " + RetSqlName("OHT") + " OHT"
		cQuery +=    " ON OHT.OHT_FILFAT = '" + xFilial("NXA") + "'"
		cQuery +=   " AND OHT.OHT_FILTIT = SE1.E1_FILIAL"
		cQuery +=   " AND OHT.OHT_PREFIX = SE1.E1_PREFIXO "
		cQuery +=   " AND OHT.OHT_TITNUM = SE1.E1_NUM "
		cQuery +=   " AND OHT.OHT_TITPAR = SE1.E1_PARCELA "
		cQuery +=   " AND OHT.OHT_TITTPO = SE1.E1_TIPO "
		cQuery +=   " AND OHT.D_E_L_E_T_ = ' ' "

		cQuery += " INNER JOIN " + RetSqlName("NXA") + " NXA "
        cQuery +=   "  ON NXA.NXA_FILIAL = OHT.OHT_FILFAT"
        cQuery +=   " AND NXA.NXA_CESCR = OHT.OHT_FTESCR"
        cQuery +=   " AND NXA.NXA_COD = OHT.OHT_CFATUR"
	Else
		cQuery += " INNER JOIN " + RetSqlName("NXA") + " NXA "
		cQuery +=    " ON NXA.NXA_FILIAL = SUBSTRING(E1_JURFAT, 1, " + cTamFilial + ") "
		cQuery +=   " AND NXA.NXA_CESCR = SUBSTRING(E1_JURFAT, " + cIniEscr + ", " + cTamEscr + ") "
		cQuery +=   " AND NXA.NXA_COD = SUBSTRING(E1_JURFAT, " + cIniFatur + ", " + cTamFatur + ") "
	EndIf

	cQuery +=       " AND NXA.NXA_CCONT  = TABTMP.U5_CODCONT "
	cQuery +=       " AND NXA.NXA_CMOEDA = TABTMP.CTO_MOEDA "
	cQuery +=       " AND NXA.NXA_SITUAC = '1' "
	
	//Filtra Sócio Responsável
	IIF(!Empty(cSocio),	cQuery += " AND NXA.NXA_CPART = '" + cSocio + "' ", NIL)
	cQuery +=       " AND NXA.D_E_L_E_T_ = ' ' "

	cQuery +=     " WHERE TABTMP.R_E_C_N_O_ = " + cValToChar(nRecTmp) + " "
	cQuery +=     " GROUP BY NXA.NXA_COD, NXA.NXA_DTVENC "
	cQuery +=     " ORDER BY NXA.NXA_COD, NXA.NXA_DTVENC  "
	
	aFaturas := JurSQL(cQuery, {"NXA_COD", "NXA_DTVENC", "TOTAL"})

Return aFaturas

//=======================================================================
/*/{Protheus.doc} PrintReport
Função para gerar PDF do relatório aviso de cobrança.

@param  cReportName , caractere, Nome do relatório
@param  cDestPath   , caractere, Caminho da pasta
@param  aFaturas    , array    , Informações sobre as faturas do cliente
@param  cAlsTmp     , caractere, Alias da tabela temporária (cobrança)
@param  cTipoSaida  , caractere , Tipo de saída do relatório
                                 1 - Impressora;
                                 2 - Tela;
                                 3 - Salvar em disco

@author Jorge Martins
@since  01/11/2018
/*/
//=======================================================================
Static Function PrintReport( cReportName, cDestPath, aFaturas, cAlsTmp, cTipoSaida, lAutomato, cNomeArq )
Local oPrinter        := Nil 
Local nIniH           := 30
Local nFimH           := 500
Local lAdjustToLegacy := .F.
Local lDisableSetup   := .T.
Local nLoop           := 0
Local nDevice         := IMP_PDF   // IMP_SPOOL Envia para impressora / IMP_PDF Gera arquivo PDF à partir do relatório
Local cPrinter        := "PDF"  // Impressora destino "forçada".
Local lViewPDF        := .T. // Quando o tipo de impressão for PDF, define se arquivo será exibido após a impressão.
Local aPrinter        := GetImpWindows(.F.) // Impressoras do SmartClient

Default cDestPath  := GetSrvProfString( "StartPath" , "" )

	cPrinter := IIF(cTipoSaida == "1" ,IIf( Empty(aPrinter), Nil, aPrinter[1] ) , cPrinter)
    nDevice := IIF(cTipoSaida == "1",IMP_SPOOL,nDevice )
	lViewPDF := cTipoSaida <> "3"

	If !lAutomato .and. cTipoSaida $ "1|2" // Impressora ou Tela
		// Como os arquivos serão criados na pasta temporária, é necessário diferenciá-los,
		// para que não fiquem com o mesmo nome
		cReportName += "_" + AllTrim((cAlsTmp)->E1_CLIENTE) + "_" + ;
		                     AllTrim((cAlsTmp)->E1_LOJA)    + "_" + ;
		                     AllTrim((cAlsTmp)->U5_CODCONT) + "_" + ;
		                     AllTrim((cAlsTmp)->CTO_MOEDA)  + "_" + FwTimeStamp(1)
	EndIf

	// Configurações do relatório
	If lAutomato
		oPrinter := FWMsPrinter():New( cNomeArq, IMP_SPOOL,,, .T.,,,)
		oPrinter:CFILENAME  := cNomeArq
		oPrinter:CFILEPRINT := oPrinter:CPATHPRINT + oPrinter:CFILENAME
	Else
		oPrinter := FWMsPrinter():New( cReportName, nDevice, lAdjustToLegacy, cDestPath, lDisableSetup, /*lTReport*/, /*oPrintSetup*/, cPrinter, /*lServer*/, /*lPDFAsPNG*/, /*lRaw*/, lViewPDF )
	EndIf
	oPrinter:SetPortrait() // Orientação no momento da impressão
	oPrinter:SetPaperSize(DMPAPER_A4)
	oPrinter:SetMargin(60,60,60,60) 

	If cTipoSaida == "3" // Salvar em disco
		oPrinter:cPathPDF := cDestPath
	EndIf

	// Gera nova página
	oPrinter:StartPage()
	
	// Imprime o relatório
	PrintRepData( @oPrinter , nIniH , nFimH, aFaturas, cAlsTmp, lAutomato )
	
	// Caso for salvar o arquivo e já exista arquivo com o mesmo nome, o sistema irá sobrescrever.
	If cTipoSaida == "3" .And. File(cDestPath + cReportName + ".pdf")
		FErase(cDestPath + cReportName + ".pdf")
	EndIf

	// Gera arquivo relatório
	oPrinter:Print()

	If cTipoSaida == "3" // Salvar em disco
		// Exclui o arquivo .rel da pasta. Faz o Loop para garantir a exclusão, pois o arquivo pode estar em uso.
		If File(cDestPath + cReportName + ".rel")
			While FErase(cDestPath + cReportName + ".rel") != 0 .And. nLoop < 10
				Sleep(500)
				nLoop += 1
			EndDo
		EndIf
	EndIf
	
Return Nil

//=======================================================================
/*/{Protheus.doc} PrintRepData
Imprime registros do relatório.

@param  oPrinter, objeto   , Estrutra do relatório
@param  nIniH	, numérico , Coordenada horizontal inicial
@param  nFimH	, numérico , Coordenada horizontal final
@param  aFaturas, array    , Informações sobre as faturas do cliente
@param  cAlsTmp , caractere, Alias da tabela temporária (cobrança)

@author Jorge Martins
@since  01/11/2018
/*/
//=======================================================================
Static Function PrintRepData( oPrinter , nIniH , nFimH, aFaturas, cAlsTmp, lAutomato )
Local nIniV         := 082 // Posição da linha inicial do relatório
Local dDataAtual    := IIF(!lAutomato, Date(), dDataBase)

// Fontes do Relatório
Local oFontTitulo   := TFont():New('Times New Roman',,-18,,.T.,,,,,.F.,.F.) // Fonte do Título do relatório
Local oFontData     := TFont():New('Times New Roman',,-13,,.F.,,,,,.F.,.F.) // Fonte da data impressa
Local oFontCliente  := TFont():New('Times New Roman',,-13,,.T.,,,,,.F.,.F.) // Fonte do nome do cliente
Local oFontTexto    := TFont():New('Times New Roman',,-13,,.F.,,,,,.F.,.F.) // Fonte dos textos

Local aDadosCli     := JurGetDados('SA1', 1, xFilial('SA1') + (cAlsTmp)->E1_CLIENTE + (cAlsTmp)->E1_LOJA, {'A1_END','A1_BAIRRO','A1_MUN','A1_CEP','A1_EST'})

Local cEndCli       := AllTrim(Capital(aDadosCli[1])) // Endereço do Cliente
Local cBairroCli    := AllTrim(Capital(aDadosCli[2])) // Bairro do Cliente
Local cMunicCli     := AllTrim(Capital(aDadosCli[3])) // Município do Cliente
Local cCEPCli       := aDadosCli[4]                   // CEP do Cliente
Local cEstadoCli    := aDadosCli[5]                   // Estado do Cliente

// Textos do Relatório
Local cEscrit       := AllTrim(JurGetDados("NS7", 4, xFilial("NS7") + cFilant + cEmpAnt, "NS7_RAZAO")) // "Nome do Escritório"
Local cCliente      := AllTrim(Capital((cAlsTmp)->A1_NOME)) // Nome do Cliente
Local cLogBairro    := cEndCli + " - " + cBairroCli         // Logradouro + Bairro / Layout --> "Rua Vasco Coutinho, 698 - São Mateus"
Local cData         := ""                                   // Trecho de montagem da variável mais abaixo
Local cCEPMunEst    := ""                                   // Trecho de montagem da variável mais abaixo

Local cPrezado      := I18N( STR0003, { AllTrim( Capital((cAlsTmp)->U5_CONTAT)) } ) // "Prezado(a) Senhor(a) NOME DO CONTATO,"
Local cTxtPend      := STR0004 // "Informamos que a(s) fatura(s) mencionada(s) abaixo, conforme cópia(s) anexa(s), encontra(m)-se pendente(s) em nosso Departamento Financeiro."
Local cTxtPedido    := STR0005 // "Pedimos a gentileza de sua verificação e um retorno quanto à liquidação desta pendência. Caso o pagamento já tenha sido efetuado, favor nos enviar o(s) respectivo(s) comprovante(s), para atualizarmos nossos registros."
Local cAgradec      := STR0006 // "Agradecemos a atenção e estamos à disposição para quaisquer esclarecimentos adicionais."
Local cAtencio      := STR0007 // "Atenciosamente,"
Local cDepto        := STR0008 // "Departamento Financeiro"
Local cDataText		:= ""
Local cDataText2	:= ""

	// Formatação de Data e CEP para BRASIL
	// Data - Layout --> "São Paulo, 22 de Outubro de 2018" FWRetIdiom() == 'pt-br'
	cDataText := cMunicCli + ", "             // São Paulo,
	cDataText += cValToChar(Day(dDataAtual))  // 22
	cDataText += STR0009                      // de
	cDataText += MesExtenso(dDataAtual)       // Outubro
	cDataText += STR0009                      // de
	cDataText += cValToChar(Year(dDataAtual)) // 2018
	// Formatação de Data para outros países
	// Data - Layout --> "New York, October 22, 2018"
	cDataText2 := cMunicCli + ", "                    // New York,
	cDataText2 += MesExtenso(dDataAtual) + " "        // October
	cDataText2 += cValToChar(Day(dDataAtual)) + ", "  // 22,
	cDataText2 += cValToChar(Year(dDataAtual))        // 2018

	IIf(FWRetIdiom() == 'pt-br', (cData := cDataText, cCEPCli := Transform(cCEPCli, "@R 99999-999")), cData := cDataText2)

	//  CEP + Município + Estado / Layout "03658-999 - São Paulo - SP"
	cCEPMunEst := cCEPCli + " - " + cMunicCli + " - " + cEstadoCli
	
	oPrinter:SayAlign( nIniV                  , nIniH, cEscrit    , oFontTitulo  , nFimH, 200, CLR_BLACK, 2, 1 ) // Escritório
	oPrinter:SayAlign( nIniV += ( 5 * nSalto ), nIniH, cData      , oFontData    , nFimH, 200, CLR_BLACK, 1, 1 ) // Data
	oPrinter:SayAlign( nIniV += ( 5 * nSalto ), nIniH, cCliente   , oFontCliente , nFimH, 200, CLR_BLACK, 0, 1 ) // Cliente

	nIniV += ( 1 * nSalto )

	// Imprime textos já verificando a necessidade de quebras de linhas
	PrintText(oPrinter, @nIniV, nIniH, nFimH, cLogBairro, oFontTexto, 0, 1, lAutomato) // Logradouro + Bairro - Texto
	PrintText(oPrinter, @nIniV, nIniH, nFimH, cCEPMunEst, oFontTexto, 0, 1, lAutomato)// CEP + Município + Estado - Texto
	PrintText(oPrinter, @nIniV, nIniH, nFimH, cPrezado  , oFontTexto, 0, 2, lAutomato) // Prezado - Texto
	PrintText(oPrinter, @nIniV, nIniH, nFimH, cTxtPend  , oFontTexto, 3, 2, lAutomato) // Pendencia - Texto

	// Imprime tabela com as faturas
	PrintTable( @oPrinter, @nIniV, nIniH, nFimH,  aFaturas, lAutomato )

	// Imprime textos já verificando a necessidade de quebras de linhas
	PrintText(oPrinter, @nIniV, nIniH, nFimH, cTxtPedido, oFontTexto, 3, 0, lAutomato) // Pedido - Texto
	PrintText(oPrinter, @nIniV, nIniH, nFimH, cAgradec  , oFontTexto, 3, 3, lAutomato) // Agradecimento - Texto
	PrintText(oPrinter, @nIniV, nIniH, nFimH, cAtencio  , oFontTexto, 3, 4, lAutomato) // Atenciosamente - Texto
	PrintText(oPrinter, @nIniV, nIniH, nFimH, cDepto    , oFontTexto, 3, 6, lAutomato) // Assinatura - Texto

Return Nil

//=======================================================================
/*/{Protheus.doc} PrintText
Imprime tabela com as faturas

@param  oPrinter  , objeto   , Estrutra do relatório
@param  nIniV     , numérico , Coordenada vertical inicial
@param  nIniH     , numérico , Coordenada horizontal inicial
@param  nFimH     , numérico , Coordenada horizontal final
@param  cTexto    , caractere, Texto a ser impresso
@param  nAlignHorz, numérico , Alinhamento horizontal 
                               0 - Alinhamento à esquerda;
                               1 - Alinhamento à direita;
                               2 - Alinhamento centralizado;
                               3 - Alinhamento justificado
@param  nQtdSalto, numérico , Quantidade de Saltos antes de iniciar o texto

@author Jorge Martins
@since  01/11/2018
/*/
//=======================================================================
Static Function PrintText( oPrinter, nIniV, nIniH, nFimH, cTexto, oFont, nAlignHorz, nQtdSalto, lAutomato )
Local nQtdLine := QtdLineTxt(oPrinter, cTexto, oFont)

	EndPage( @oPrinter , nIniH , nFimH , @nIniV , (nQtdLine * nSalto) , lAutomato) // Verifica se é necessário quebrar a página

	nIniV += (nQtdSalto * nSalto) // Realiza os saltos antes da impressão do texto

	oPrinter:SayAlign( nIniV, nIniH, cTexto  , oFont , nFimH, 200, CLR_BLACK, nAlignHorz, 1 ) // Imprime o texto

	nIniV += (nQtdLine  * nSalto) // Realiza os saltos conforme a quantidade de linhas utilizada pelo texto impresso

Return Nil

//=======================================================================
/*/{Protheus.doc} PrintTable
Imprime tabela com as faturas

@param  oPrinter, objeto   , Estrutra do relatório
@param  nIniV   , numérico , Coordenada vertical inicial
@param  nIniH   , numérico , Coordenada horizontal inicial
@param  nFimH   , numérico , Coordenada horizontal final
@param  aFaturas, array    , Informações sobre as faturas do cliente

@author Jorge Martins
@since  01/11/2018
/*/
//=======================================================================
Static Function PrintTable( oPrinter, nIniV, nIniH, nFimH, aFaturas, lAutomato )
Local nTotal     := 0
Local nFaturas   := 0
Local nColIni1   := nIniH           // Posição Inicial da caixa com as "Faturas"
Local nColFim1   := nColIni1 + 164  // Posição Final   da caixa com as "Faturas"
Local nColIni2   := nColFim1 + 3    // Posição Inicial da caixa com os "Vencimentos"
Local nColFim2   := nColIni2 + 164  // Posição Final   da caixa com as "Vencimentos"
Local nColIni3   := nColFim2 + 3    // Posição Inicial da caixa com os "Valores"
Local nColFim3   := nColIni3 + 164  // Posição Final   da caixa com os "Valores"

Local oFontTabTit   := TFont():New('Times New Roman',,-13,,.T.,,,,,.F.,.F.)  // Fonte dos títulos da tabela de valores
Local oFontTabVal   := TFont():New('Times New Roman',,-13,,.F.,,,,,.F.,.F.)  // Fonte dos valores da tabela de valores

	nIniV += ( 5 * nSalto ) // Realiza um salto entre o último texto impresso e a tabela com as informações das faturas

	// Cabeçalho - Caixas
	oPrinter:Box( nIniV, nColIni1, (nIniV+15), nColFim1, "-9" )
	oPrinter:Box( nIniV, nColIni2, (nIniV+15), nColFim2, "-9" )
	oPrinter:Box( nIniV, nColIni3, (nIniV+15), nColFim3, "-9" )

	// Cabeçalho - Textos
	oPrinter:SayAlign( nIniV , 30  , STR0010, oFontTabTit, 164, 200, CLR_BLACK, 2, 1 ) // "Fatura"
	oPrinter:SayAlign( nIniV , 164 , STR0011, oFontTabTit, 229, 200, CLR_BLACK, 2, 1 ) // "Vencimento"
	oPrinter:SayAlign( nIniV , 229 , STR0012, oFontTabTit, 432, 200, CLR_BLACK, 2, 1 ) // "Saldo"
	
	// Faturas
	For nFaturas := 1 To Len(aFaturas)

		EndPage( @oPrinter , nIniH , nFimH , @nIniV , (4 * nSalto), lAutomato ) // Verifica se é necessário quebrar a página

		nIniV += ( 2 * nSalto ) // Realiza um salto entre as caixas da tabela conforme a impressão das faturas
		
		// Fatura - Caixas
		oPrinter:Box( nIniV, nColIni1, (nIniV+15), nColFim1, "-9" )
		oPrinter:Box( nIniV, nColIni2, (nIniV+15), nColFim2, "-9" )
		oPrinter:Box( nIniV, nColIni3, (nIniV+15), nColFim3, "-9" )

		// Fatura - Textos e Valores
		oPrinter:SayAlign( nIniV , 30    , aFaturas[nFaturas][1]            , oFontTabVal, 164    , 200, CLR_BLACK, 2, 1 ) 
		oPrinter:SayAlign( nIniV , 164   , DToC(SToD(aFaturas[nFaturas][2])), oFontTabVal, 229    , 200, CLR_BLACK, 2, 1 ) 
		oPrinter:SayAlign( nIniV , nIniH , FormatNum(aFaturas[nFaturas][3]) , oFontTabVal, nFimH-5, 200, CLR_BLACK, 1, 1 ) 

		nTotal += aFaturas[nFaturas][3]

	Next
	
	EndPage( @oPrinter , nIniH , nFimH , @nIniV , (4 * nSalto), lAutomato ) // Verifica se é necessário quebrar a página

	nIniV += ( 2 * nSalto ) // Realiza um salto entre as caixas da tabela antes da impressão do totalizador

	// Total - Caixas
	oPrinter:Box( nIniV, nColIni1, (nIniV+15), nColFim2, "-9" )
	oPrinter:Box( nIniV, nColIni3, (nIniV+15), nColFim3, "-9" )

	// Total - Textos e Valores
	oPrinter:SayAlign( nIniV , 30    , STR0013           , oFontTabTit, 329    , 200, CLR_BLACK, 2, 1 ) // "Valor Total:"
	oPrinter:SayAlign( nIniV , nIniH , FormatNum(nTotal) , oFontTabTit, nFimH-7, 200, CLR_BLACK, 1, 1 )

	nIniV += ( 4 * nSalto ) // Realiza um salto após a impressão da tabela de faturas para continuar com os textos

Return Nil

//=======================================================================
/*/{Protheus.doc} EndPage
Avalia quebra de página.

@param  oPrinter   , objeto     , Estrutra do relatório
@param  nIniH      , numérico   , Coordenada horizontal inicial
@param  nFimH      , numérico   , Coordenada horizontal final
@param  nIniV      , numérico   , Coordenada vertical inicial
@param  nNewIniV   , numérico   , Coordenada vertical que será verificada

@author Jorge Martins
@since  01/11/2018
/*/
//=======================================================================
Static Function EndPage( oPrinter , nIniH , nFimH , nIniV , nNewIniV, lAutomato )
Local nIFimV := 825  // Coordenada vertical final

Default nNewIniV := 0

	If !lAutomato .AND. ( nIniV + nNewIniV ) >= nIFimV
		nIniV   := 082 // Posição da linha inicial do relatório
		oPrinter:EndPage()   // Encerra página atual
		oPrinter:StartPage() // Inicia nova página
	EndIf

Return Nil

//=======================================================================
/*/{Protheus.doc} FormatNum
Coloca separação decimal nos valores numéricos

@param  nValue  , numérico , Numero a ser formatado

@return cNumber , caractere , Numero formatado com tipo de caractere

@author Jorge Martins
@since  01/11/2018
/*/
//=======================================================================
Static Function FormatNum( nValue )
Local cNumber := ""

Default nValue := 0

	cNumber := AllTrim( TransForm( nValue , "@E 99,999,999,999.99" ) )

Return ( cNumber )

//=======================================================================
/*/{Protheus.doc} QtdLineTxt
Avalia quantas linhas serão necessárias para impressão do texto

@param  oPrinter  , objeto   , Estrutra do relatório
@param  cTexto    , caractere, Texto a ser avaliado
@param  oFont     , objeto   , Fonte para impressão dos dados

@return nQtdLinha , numérico , Quantidade de linhas necessárias para impressão do texto

@author Jorge Martins
@since  01/11/2018
/*/
//=======================================================================
Static Function QtdLineTxt(oPrinter, cTexto, oFont)
Local cTextoBase := "Informamos que a(s) fatura(s) mencionada(s) abaixo, conforme cópia(s) anexa(s), encontra(m)-se pendente(s) em nosso" // Texto BASE para avaliar quebra de linha
Local nRazaoBase := oPrinter:GetTextWidth( cTextoBase , oFont )
Local nQtdLinha  := oPrinter:GetTextWidth( cTexto     , oFont ) / nRazaoBase

	If Round(nQtdLinha , 2) > 1.20
		nQtdLinha := Ceiling(nQtdLinha)
	Else
		nQtdLinha := Round(nQtdLinha,0)
	EndIf

	If nQtdLinha == 0
		nQtdLinha := 1
	EndIf

Return nQtdLinha