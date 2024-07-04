#INCLUDE "TOTVS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.ch"
#INCLUDE "QIEMGRAFIC.CH"

/*/{Protheus.doc} GraficosQualidadeX
Classe responsável pelos métodos de criação e manipulação dos gráficos do CEP - Controle Estatístico de Processos
@author brunno.costa / rafael.kleestadt
@since 10/05/2022
@version 1.0
/*/
CLASS GraficosQualidadeX FROM LongNameClass
    
	//Método Construtor da classe
	METHOD new() CONSTRUCTOR

	//Métodos Exclusivos de Exibição e Tela
	METHOD calculaDimensionamentoDaTela(nTamDatPar, nTipo)
	METHOD criaColunaMedicoesDinamicamente(aCols)
	METHOD criaImagemBase64EmDiretorioFisico(oKendoChart, cCodeContent, cPathPng)
	METHOD exibeBrowseMedicoes(aMedicoes)
	METHOD exibeTelaEstatisticas(aItensExcel, aCabExcel, nCp, nCg, nPp, nCr,nCpl, nCpu, nSigma, nMean, nN, nCpk, nCgk, nPpk, nPr, cEstSigma )
	METHOD exportaValoresParaCSV(aCabExcel, aItensExcel)
	METHOD imprimirGrafico(aDataPar, nTipo, aMedicoes, aTitCarCon, aLimites, cDirPng, cArqPNG, lXbXbr, lReport, cTpCarEns, cTpCarEsc, nTamAmostr)
	METHOD retornaCorAleatoria()
	METHOD retornaTituloDialog(nTipo)

	//Métodos Tratamentos de Arrays e Matrizes
	METHOD converteArrayEmArrayNumerico(aOrigem)
	METHOD converteArrayOuMatrizEmArrayNumerico(aOrigem)
	METHOD converteArrayOuMatrizEmArrayOuMatrizNumerico(aOrigem)
	METHOD converteMatrizEmMatrizNumerica(aMatriz)
	METHOD criaArrayPorMatriz(aMatriz)
	METHOD criaArrayPorMatrizEAjustaOrigem(aMatriz)
	METHOD criaMatrizNumerica(aMatriz)
	METHOD criaArrayNumericoPorArrayOuMatriz(aOrigem)

	//Mainipulações de Arrays Com Posições X/Y em JsonObject para Gráficos
	METHOD criaArrayJsonXYDiagramaDePareto(aParDP, nCasasDec)
	METHOD criaArrayJsonXYELimitesAmplitudeParaGrafico(aMedicoes)
	METHOD criaArrayJsonXYHistograma(aCol1, aCol2, nPrimeiro, nIncremento)
	METHOD criaArrayJsonXYHistogramaMetrologia(aValores, aNormPad, aFrequen)
	METHOD criaArrayJsonXYIndexCoordenadas(aDataPar)
	METHOD criaArrayJsonXYPorArray(aDataPar)

	//Métodos com Regras de Negócio e Exibição de Tela
	METHOD calculaExibeExportaEstatisticasCartaIndividual(aMedicoes, aAmplit, aLimites, nMediaEst)
	METHOD calculaExibeExportaEstatisticasCartasDeControleOuHistograma(aMedicoes, aMedAux, aLimites, cTpCarEsc, cTpCarEns, nTamAmostr)
	METHOD calculaExibeExportaEstatisticasPPAP(aMedicoes, aMedAux, aLimites, nTamAmostr)

	//Métodos com Regras de Negócio
	METHOD calculaCPK(nMediaEst, aLimites, nDesvPad)
	METHOD calculaCPU(aLimites, aMedias)
	METHOD calculaEstSigma(aMedicoes, nDesvPad, aMedias, cTpCarEsc, cTpCarEns, nTamAmostr, nMedAmpl)
	METHOD calculaMediaDoArray(aAmpl)
	METHOD calculaMediasDaMatriz(aDataPar)
	METHOD calculaPPK(nMediaEst, aLimites, nDesvPad)
	METHOD criaArrayAmostrasComQuebra(xAmostra, nQuebra)
	METHOD criaArrayAmplitudeMovelPorArray(aOrigem)
	METHOD criaArrayAmplitudesPorArrayOuMatriz(aMedicao)
	METHOD criaArrayBaseEmInicioIncrementoEQtdPontos(nMedMenor, nIncrement, nQtdPontos)
	METHOD criaArrayDesvioPadrao(aMedicoes)
	METHOD criaArrayDistribuicaoNormalPadrao(aPontos, nDesvPad, nMedia)
	METHOD retornaConstante(aMedicoes, cType, nTamAmostr)

	//Retorna Array com Limites
	METHOD criaArrayLimites_nUCL_nAmpMed_nLCL(aDataAM, nNum)
	METHOD criaArrayLimites_nUcl_nCl_nLcl(aMedicoes, aMedAux, aLimites, cTpCarEsc, cTpCarEns, nTamAmostr)
	METHOD criaArrayLimites_nUcl_nCl_nLcl__PontosDesvioPadrao_HIS(aMedicoes)
	METHOD criaArrayLimites_nUcl_nCl_nLcl__PontosDesvioPadrao_IND(aMedicoes)
	METHOD criaArrayLimites_nUcl_nCl_nLcl__PontosDesvioPadrao_XBR(aMedicoes)
	METHOD criaArrayLimites_nUcl_nCl_nLcl__PontosDesvioPadrao_XBS(aMedicoes)
	METHOD criaArrayLimites_nUCL_nMedAmos_nLCL_aAmplMovel(aDataPar, cTpCarEns, cTpCarEsc)
	METHOD criaArrayLimites_nUcl_nMedia_nLcl(nMedia)
	METHOD criaArrayLimites_nUcl_nMedia_nLcl__ComMediasNbCalculada(aDataAM)

ENDCLASS

/*/{Protheus.doc} new
Método Construtor da Classe
@author brunno.costa / rafael.kleestadt
@since 06/05/2022
@return Self, objeto, instancia da Classe GraficosQualidadeX
/*/
METHOD new() CLASS GraficosQualidadeX
Return Self

/*/{Protheus.doc} criaArrayPorMatrizEAjustaOrigem
Converte os dados caracter de uma matriz e cria um array de dados em formato numérico.
@author brunno.costa / rafael.kleestadt
@since 06/05/2022
@return aArray, array, array simples com dados numéricos
/*/
METHOD criaArrayPorMatrizEAjustaOrigem(aMatriz) CLASS GraficosQualidadeX
	
	Local aArray := {}
	Local lChar  := .F.
	Local nInd1  := 1
	Local nInd2  := 1

	If Len(aMatriz) > 0 .AND. Len(aMatriz[1]) > 0
		lChar := ValType(aMatriz[1][1]) == "C"
	EndIf

    For nInd1 := 1 To Len(aMatriz)
		For nInd2 := 1 To len(aMatriz[nInd1]) 
			If lChar
				aMatriz[nInd1][nInd2] := SuperVal(aMatriz[nInd1][nInd2])
			EndIf
			aADD(aArray, aMatriz[nInd1][nInd2])
		Next
	Next

Return aArray

/*/{Protheus.doc} criaArrayPorMatriz
Cria um array com dados numéricos baseados numa matriz de dados caracter.
@author brunno.costa / rafael.kleestadt
@since 06/05/2022
@return aArray, array, array simples com dados numéricos
/*/
METHOD criaArrayPorMatriz(aMatriz) CLASS GraficosQualidadeX
	
	Local aArray := {}
	Local lChar  := .F.
	Local nInd1  := 1
	Local nInd2  := 1

	If Len(aMatriz) > 0 .AND. Len(aMatriz[1]) > 0
		lChar := ValType(aMatriz[1][1]) == "C"
	EndIf

    For nInd1 := 1 To Len(aMatriz)
		For nInd2 := 1 To len(aMatriz[nInd1]) 
			If lChar
				aADD(aArray, SuperVal(aMatriz[nInd1][nInd2]))
			Else
				aADD(aArray, aMatriz[nInd1][nInd2])
			EndIf
		Next
	Next

Return aArray

/*/{Protheus.doc} criaMatrizNumerica
Cria uma nova matriz com dados numéricos com base em uma matriz de caracteres
@author brunno.costa / rafael.kleestadt
@since 06/05/2022
@return aMatriz, array, matriz com dois níveis de arrays numéricos
/*/
METHOD criaMatrizNumerica(aMatriz) CLASS GraficosQualidadeX
	Local aNova := aClone(aMatriz)
	aNova := Self:converteMatrizEmMatrizNumerica(aNova)
Return aNova

/*/{Protheus.doc} converteMatrizEmMatrizNumerica
Converte una natriz com dados caracter em uma mtriz de dados numéricos
@author brunno.costa / rafael.kleestadt
@since 06/05/2022
@return aMatriz, array, matriz com dois níveis de arrays numéricos
/*/
METHOD converteMatrizEmMatrizNumerica(aMatriz) CLASS GraficosQualidadeX
	
	Local lChar := .F.
	Local nInd1 := 1
	Local nInd2 := 2

	If Len(aMatriz) > 0 .AND. Len(aMatriz[1]) > 0
		lChar := ValType(aMatriz[1][1]) == "C"
	EndIf

	If lChar
		For nInd1 := 1 To Len(aMatriz)
			For nInd2 := 1 To len(aMatriz[nInd1]) 
				If lChar
					aMatriz[nInd1][nInd2] := SuperVal(aMatriz[nInd1][nInd2])
				EndIf
			Next
		Next
	EndIf

Return aMatriz

/*/{Protheus.doc} criaArrayPorMatriz
Converte um array de dados caracter em array de dados numéricos.
@author brunno.costa / rafael.kleestadt
@since 06/05/2022
@return aArray, array, array simples com dados numéricos
/*/
METHOD converteArrayEmArrayNumerico(aOrigem) CLASS GraficosQualidadeX
	
	Local aArray := Nil
	Local lChar  := .F.
	Local nInd1  := 1

	If Len(aOrigem) > 0
		lChar := ValType(aOrigem[1]) == "C"
	EndIf

	If lChar
		aArray := {}
		For nInd1 := 1 To Len(aOrigem)
			aADD(aArray, SuperVal(aOrigem[nInd1]))
		Next
	Else
		aArray := aClone(aOrigem)
	EndIf

Return aArray

/*/{Protheus.doc} criaArrayPorMatriz
Converte um array ou matriz de dados caracter em array de dados numéricos
@author brunno.costa / rafael.kleestadt
@since 06/05/2022
@return aArray, array, array simples com dados numéricos
/*/
METHOD converteArrayOuMatrizEmArrayNumerico(aOrigem) CLASS GraficosQualidadeX
	Local aArray  := {}
	IF ValType(aOrigem[1]) <> "A" 
		aArray := Self:converteArrayEmArrayNumerico(aOrigem)
	Else
		aArray := Self:criaArrayPorMatriz(aOrigem)
	Endif
Return aArray

/*/{Protheus.doc} criaArrayNumericoPorArrayOuMatriz
Cria um array de dados numéricos através de um array ou matriz
@author brunno.costa / rafael.kleestadt
@since 11/05/2022
@return aNovo, array, array simples com dados numéricos
/*/
METHOD criaArrayNumericoPorArrayOuMatriz(aOrigem) CLASS GraficosQualidadeX
	Local aNovo := aClone(aOrigem)
Return Self:converteArrayOuMatrizEmArrayNumerico(aNovo)

/*/{Protheus.doc} converteArrayOuMatrizEmArrayOuMatrizNumerico
Converte array ou matriz de dados caracter em array ou matriz de dados numéricos.
@author brunno.costa / rafael.kleestadt
@since 06/05/2022
@return aArray ou aMatriz, array ou Matriz, array simples ou matriz (array duplo) de acordo com aOrigem
/*/
METHOD converteArrayOuMatrizEmArrayOuMatrizNumerico(aOrigem) CLASS GraficosQualidadeX
	Local aRetorno  := {}
	IF ValType(aOrigem[1]) <> "A" 
		aRetorno := Self:converteArrayEmArrayNumerico(aOrigem)
	Else
		aRetorno := Self:converteMatrizEmMatrizNumerica(aOrigem)
	Endif
Return aRetorno


/*/{Protheus.doc} QIEMGRAFIC
@author carlos.augusto
@since 21/05/2019
@version 1.0
@return ${return}, ${return_description}
@param aDataPar, array, descricao
@param nTipo, characters, descricao 1=Valores Individuais e Amplitude Movel, 2=Pareto
@type  function
/*/
Function QIEMGRAFIC(aDataPar, nTipo, aMedAnt, aTitCarCon, aLimites, cDirPng, cArqPNG, lXbXbr, lReport, cTpCarEns, cTpCarEsc, nTamAmostr)
	Local aCategories := {}
	Local aComments   := {}
	Local aConfTela   := Nil
	Local aData       := {}
	Local aDataParBkp := {}
	Local aDesvPd     := {}
	Local aFrequeLim  := {}
	Local aFrequenci  := {}
	Local aLimits     := {}
	Local aMedAux     := {}
	Local aMedEstat   := Nil
	Local aMedia      := {}
	Local aMyAxis     := {}
	Local aResult     := {}
	Local aRetAux     := {}
	Local aValueAxis  := {}
	Local cFontLabel  := "15px sans-serif"
	Local cFontTitle  := "13px sans-serif"
	Local cNameDlg    := Nil
	Local cTitLinear  := ""
	Local nEstClasse  := 0
	Local nHeight     := 0
	Local nIncrBarra  := 0
	Local nMaior      := 0
	Local nMedia      := 0
	Local nMenor      := 999999999
	Local nTamanho    := 0
	Local nWidth      := 0
	Local nX          := 0
	Local nY          := 0
	Local oKendo      := Nil
	Local oQLGrafico  := GraficosQualidadeX():New()
    Local aJsData     := {}
    Local aLim        := {}
    Local aSeries     := {}
    Local nI          := 0
    Local oDlgM       := Nil
	Local aArrayAux   := {}

	PRIVATE aAllMed     := {}
	PRIVATE aArrayMed   := {}
	PRIVATE aMedicoes   := aMedAnt
	PRIVATE cDirePng    := cDirPng
	PRIVATE cNamePng    := cArqPNG
	PRIVATE oKendoIMP   := Nil

	DEFAULT aTitCarCon  := {STR0002, STR0003} //{"Valores Individuais", "Amplitude Movel"}
	DEFAULT cTpCarEns   := ""
	DEFAULT cTpCarEsc   := ""
	DEFAULT lMV_QCALLIM := GetMV("MV_QCALLIM")
	DEFAULT nMediaEst   := 0
	DEFAULT nTamAmostr  := Nil
    DEFAULT lReport     := .F.
    DEFAULT lXbXbr      := .F.

	aConfTela  := oQLGrafico:calculaDimensionamentoDaTela(LEN(aDataPar),nTipo)
	nWidth     := aConfTela[2]
	nHeight    := aConfTela[1]
	cFontLabel := aConfTela[3]

	If aMedicoes <> NIL .AND. Len(aMedicoes) > 60
		MessageDlg(STR0001,,3) //Os filtros preenchidos retornaram um número superior a 60 medições. A visualização do gráfico pode ficar comprometida.
	Endif
	
 	cNameDlg   := oQLGrafico:retornaTituloDialog(nTipo)
	oDlgM      := TDialog():New(0,0,nHeight,nWidth,cNameDlg,,,,,CLR_BLACK,CLR_WHITE,,,.T.)
	
	oFwLayer   := FwLayer():New()
	oFwLayer:Init( oDlgM, .f., .t. )
	oFWLayer:AddLine( 'INDIV', 5, .F. )
	oFWLayer:AddLine( 'MOV', 95, .F. )
	oFWLayer:AddCollumn( 'INDIVCOL' , 100, .T., 'INDIV' )
	oFWLayer:AddCollumn( 'MOVCOL' , 100, .T., 'MOV' )
	oPnInd := oFWLayer:GetColPanel( 'INDIVCOL', 'INDIV' )
	oPnMov := oFWLayer:GetColPanel( 'MOVCOL', 'MOV' )

	//Cartas de Controle SIGAPPAP (Tela)
	IF (cValToChar(nTipo) $ "1|2|7") .And. (IsInCallStack("QPPA170") .Or. IsInCallStack("QPPR170")) //Cartas de Controle

 		aArrayMed   := aClone(aDataPar)  //Array auxiliar
		aDataParAux := aClone(aDataPar)  //Array auxiliar
		aDataParBkp := aClone(aDataPar)  //Array auxiliar

        IF lXbXbr
			aMedEstat := oQLGrafico:criaArrayPorMatriz(aMedicoes)
		ELSE
			aMedEstat := aDataParAux
		ENDIF

		// Calculo da Média		
		aMedAux := oQLGrafico:criaMatrizNumerica(aMedicoes)

		If Len(aDataParAux) > 1
			aMedia := oQLGrafico:calculaMediasDaMatriz(oQLGrafico:criaMatrizNumerica(aDataParAux))
		Else
			aArrayAux    := aClone(aDataParAux[Len(aDataParAux)])
			aDataParAux  := aClone(aArrayAux)
		Endif
		
		If !Empty(aMedia)
			aDataParAux := aClone(aMedia)
		Endif

	    //Range or Xbar / Range--------
		aJsData := oQLGrafico:criaArrayJsonXYPorArray(aDataParAux)	
		If (nTipo == 1 .Or. nTipo == 7)
			aLim := oQLGrafico:criaArrayLimites_nUcl_nCl_nLcl(oQLGrafico:criaArrayNumericoPorArrayOuMatriz(aMedicoes), aMedAux, aLimites, , , nTamAmostr)
		EndIf
		//---------------------------

		oKendo := KendoChart():New(oPnMov, nHeight, nWidth)
		If nTipo == 7 .And. !lReport //Xbar/Range Tela SIGAPPAP
			TButton():New( 005, 005, STR0004, oPnInd, {|| oQLGrafico:imprimirGrafico(aDataParBkp, 97, aMedAux, aTitCarCon, aLimites, cDirPng, cArqPNG, lXbXbr, .T., cTpCarEns, cTpCarEsc, nTamAmostr) },40,010,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Imprimir"
		Endif
		If (nTipo == 1 .Or. nTipo == 2 .Or. nTipo == 7) .And. !lReport 
			TButton():New( 005, 055, STR0005, oPnInd, {|| oQLGrafico:exibeBrowseMedicoes(aArrayMed) },40,010,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Medições"
			IF !EMPTY(aLimites)
				TButton():New( 005, 105, STR0006, oPnInd, {|| oQLGrafico:calculaExibeExportaEstatisticasPPAP(oQLGrafico:criaArrayNumericoPorArrayOuMatriz(aMedicoes), aMedAux, aLimites, nTamAmostr) },40,010,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Estatísticas"
			ENDIF
		EndIf

		IF nTipo == 7 .Or. nTipo == 1 // Xbar / Range or xBar

			If nTipo == 1 .And. !lReport //XBar Tela SIGAPPAP
				TButton():New( 005, 005, STR0004, oPnInd, {|| oQLGrafico:imprimirGrafico(aDataParBkp, 91, aMedAux, aTitCarCon, aLimites, cDirPng, cArqPNG, lXbXbr, .T., cTpCarEns, cTpCarEsc, nTamAmostr) },40,010,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Imprimir"
			EndIf
			oKendo:AddChart('chart1',aTitCarCon[1], "bottom", .F., .F., nWidth - 20/* 650 */, 275, !lReport, cFontTitle)
			Aadd(aSeries, KendoSeries():New(STR0010,"y1", "x1", "cat1",, "line","normal",,,,,,)) //"Valor"
			Aadd(aCategories, KendoCategory():New("cat1",,.F., .T., 0,,,"{0:N0}",cFontLabel))
			Aadd(aLimits, KendoLimit():New("UCL", aLim[1], "red"))
			Aadd(aLimits, KendoLimit():New("CL", aLim[2], "blue"))
			Aadd(aLimits, KendoLimit():New("LCL", aLim[3], "green"))
			oKendo:SetCategories('chart1', aCategories)
			oKendo:SetLimits('chart1', aLimits)
			If Empty(aMedia)
				aSeries := {}
			Endif
			Aadd(aValueAxis, KendoValueAxis():New('y1',,,,,,cFontLabel))
			oKendo:SetValueAxis('chart1', aValueAxis)
			oKendo:SetSeries('chart1', aSeries)
			oKendo:SetData('chart1', aJsData)
		
		EndIf

		IF (nTipo == 7 .Or. nTipo == 2) // Xbar/Range or Range

			aRetAux := oQLGrafico:criaArrayJsonXYELimitesAmplitudeParaGrafico(aMedAux)
			aJsData := aRetAux[1]
			aLim    := aRetAux[2]

			aSeries     := {}
			aLimits     := {}
			aCategories := {}
			aValueAxis  := {}

			If nTipo == 2 .And. !lReport //Range Tela SIGAPPAP
				TButton():New( 005, 005, STR0004, oPnInd, {|| oQLGrafico:imprimirGrafico(aDataParBkp, 92, aMedAux, aTitCarCon, aLimites, cDirPng, cArqPNG, lXbXbr, .T., cTpCarEns, cTpCarEsc, nTamAmostr) },40,010,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Imprimir"
			EndIf
			oKendo:AddChart('chart2',aTitCarCon[2], "bottom", .F., .F., nWidth - 20/* 650 */, 275, !lReport, cFontTitle)
			Aadd(aSeries, KendoSeries():New(STR0010,"y1", "x1", "cat1",, "line","normal",,,,,,)) //"Valor"
			Aadd(aCategories, KendoCategory():New("cat1",,.F., .T., 0,,,"{0:N0}",cFontLabel))
			Aadd(aLimits, KendoLimit():New("UCL", aLim[1], "red"))
			Aadd(aLimits, KendoLimit():New("CL", aLim[2], "blue"))
			Aadd(aLimits, KendoLimit():New("LCL", aLim[3], "green"))
			oKendo:SetCategories('chart2', aCategories)
			oKendo:SetLimits('chart2', aLimits)
			Aadd(aValueAxis, KendoValueAxis():New('y1',,,,,,cFontLabel))
			oKendo:SetValueAxis('chart2', aValueAxis)
			oKendo:SetSeries('chart2', aSeries)
			oKendo:SetData('chart2', aJsData)
		EndIf

		IF lReport
			oKendo:lReport := .T.
		ENDIF

		aDataPar := aClone(aDataParBkp)

	ELSEIF nTipo == 1 .Or. nTipo == 9 .Or. nTipo == 91 .Or. nTipo = 92 .Or. nTipo == 97 //Cartas de Controle QIP/QIE/QMTC ou (Botão Imprimir *PDF)
		aDataParAux := aClone(aDataPar)  //Array auxiliar
		aDataParBkp := aClone(aDataPar)  //Array auxiliar

		aDataPar  := oQLGrafico:converteArrayOuMatrizEmArrayOuMatrizNumerico(aDataPar)
		
		aMedEstat := oQLGrafico:converteArrayOuMatrizEmArrayNumerico(aDataPar)

		oKendo := KendoChart():New(oPnMov, nHeight, nWidth)

		IF nTipo == 1 .Or. nTipo == 9 .Or. nTipo == 91 .Or. nTipo == 97 //Cartas de Controle
			
			// Calculo da Média
			If IsInCallStack("QMTC010")
				If Len(aMedicoes) > 1 .And. (MV_PAR01 == 1 .Or. MV_PAR01 == 3)
					aMedia := oQLGrafico:calculaMediasDaMatriz(aMedicoes)
				Else
					aArrayAux := IIF(ValType(aDataParAux[Len(aDataParAux)]) == "A",aClone(aDataParAux[Len(aDataParAux)]),aClone(aDataParAux))    
					aDataParAux  := aClone(aArrayAux)
				Endif
			
				If !Empty(aMedia)
					aDataParAux := aClone(aMedia)
				Endif

				aJsData := oQLGrafico:criaArrayJsonXYPorArray(aDataParAux)	
				aLim    := oQLGrafico:criaArrayLimites_nUCL_nMedAmos_nLCL_aAmplMovel(aDataParAux)
			Else
				If nTipo == 91 .Or. nTipo == 97 //Impressão PDF
					If Len(aDataPar) > 1
						aMedia    := oQLGrafico:calculaMediasDaMatriz(aDataPar)
					Else
						aArray    := aClone(aDataPar[Len(aDataPar)])
						aDataPar  := aClone(aArray)
					Endif
					
					If !Empty(aMedia)
						aDataPar := aClone(aMedia)
					Endif
				Else
					//------- Faz uma cópia das medições para Calculo da Média -------//
					aMedAux := oQLGrafico:criaMatrizNumerica(aMedicoes)
				EndIf
				
				aJsData := oQLGrafico:criaArrayJsonXYPorArray(aDataPar) //Converte a media das medições das amostras para Json

				//Função que gerencia o calculo dos limites de acordo com o Tipo de Carta
				IF IsInCallStack("QIPA215") .Or. IsInCallStack("QIPM020")
					If cTpCarEsc $ 'XBR | XBS' .Or. (Empty(cTpCarEsc) .And. cTpCarEns $ 'XBR | XBS') 
						aLim := oQLGrafico:criaArrayLimites_nUcl_nCl_nLcl(aMedEstat, aMedAux, aLimites, cTpCarEsc, cTpCarEns, nTamAmostr) //Calcula os limites de acordo com os pontos da media para carta de controle ensaio carta XBR e XBS
					Else
						aLim := oQLGrafico:criaArrayLimites_nUCL_nMedAmos_nLCL_aAmplMovel(aDataPar, cTpCarEns, cTpCarEsc)
					EndIf
				Else
					aLim := oQLGrafico:criaArrayLimites_nUCL_nMedAmos_nLCL_aAmplMovel(aDataPar)
				Endif
				//---------------------------

				IF lMV_QCALLIM .AND. (IsInCallStack("QIPM020") .Or. IsInCallStack("QIPA215"))
					aLim[1] := aLimites[3] //UCL - (upper control limit) 
					aLim[2] := aLimites[1] //REFERENCIA		
					aLim[3] := aLimites[2] //LCL - (lower control limit)		
				ENDIF
				
			EndIf
			
			IF nTipo == 1 //Cartas de controle
				TButton():New( 005, 005, STR0004, oPnInd, {|| oQLGrafico:imprimirGrafico(aDataPar, 9, aMedicoes, aTitCarCon, aLimites, cDirPng, cArqPNG, lXbXbr, .T., cTpCarEns, cTpCarEsc, nTamAmostr) },40,010,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Imprimir"
				TButton():New( 005, 055, STR0005, oPnInd, {|| oQLGrafico:exibeBrowseMedicoes(aMedicoes) },40,010,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Medições"
				IF !EMPTY(aLimites)
					IF !(IsInCallStack("QIPA215") .Or. IsInCallStack("QIPM020"))
						TButton():New( 005, 105, STR0006, oPnInd, {|| oQLGrafico:calculaExibeExportaEstatisticasCartasDeControleOuHistograma(aMedEstat, oQLGrafico:converteArrayOuMatrizEmArrayOuMatrizNumerico(aMedicoes), aLimites) },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )//"Estatísticas"
					Else
						TButton():New( 005, 105, STR0006, oPnInd, {|| oQLGrafico:calculaExibeExportaEstatisticasCartasDeControleOuHistograma(oQLGrafico:criaArrayNumericoPorArrayOuMatriz(aMedAux), aMedAux, aLimites, cTpCarEsc, cTpCarEns, nTamAmostr) },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )//"Estatísticas"
					Endif
				ENDIF
			ENDIF
		
			oKendo:AddChart('chart1',aTitCarCon[1], "bottom", .T., .F., nWidth - 20/* 650 */, 250, !lReport)
			Aadd(aSeries, KendoSeries():New(STR0010,"y1", "x1", "cat1",, "line","normal",,,,,,"{0:N2}")) //"Valor"
			Aadd(aCategories, KendoCategory():New("cat1",,.F., .T., 0,,,"{0:N0}",cFontLabel))
			Aadd(aLimits, KendoLimit():New("UCL", aLim[1], "red"))
			Aadd(aLimits, KendoLimit():New("CL", aLim[2], "blue"))
			Aadd(aLimits, KendoLimit():New("LCL", aLim[3], "green"))
			oKendo:SetCategories('chart1', aCategories)
			oKendo:SetLimits('chart1', aLimits)
			oKendo:SetSeries('chart1', aSeries)
			oKendo:SetData('chart1', aJsData)

		ENDIF

		IF nTipo == 1 .Or. nTipo == 9 .Or. nTipo == 92 .Or. nTipo == 97 //Cartas de Controle

			IF cValToChar(nTipo) $ '92|97' .Or. (((IsInCallStack("QIPA215") .Or. IsInCallStack("QIPM020")) .And. !Empty(cTpCarEsc)) .Or. IsInCallStack("QMTC010") .Or. IIF(IsInCallStack("QIPM020"), .T., IIF( Type("MV_PAR01") == "N", IIF(MV_PAR01 <> 2, .T., .F.) , .T.) ) )
				
				// Trecho criado exclusivamente para a rotina QIP215 e QIPM020
				If IsInCallStack("QIPA215") .Or. IsInCallStack("QIPM020")

					If cTpCarEsc == "XBR" .Or. cTpCarEsc == "XBRXBS"
						If cTpCarEns == "XBS" .Or. (cTpCarEns == "HIS" .And. cTpCarEsc == "XBR")
							aMedicoes := oQLGrafico:converteArrayOuMatrizEmArrayOuMatrizNumerico(aMedicoes) 
							aRetorno  := oQLGrafico:criaArrayJsonXYELimitesAmplitudeParaGrafico(aMedicoes)

							// Amplitude Movel
							aJsData := aRetorno[1]
							aLim    := aRetorno[2]
						Else
							aRetorno := oQLGrafico:criaArrayJsonXYELimitesAmplitudeParaGrafico(aMedEstat)
						
							// Amplitude Movel
							aJsData := aRetorno[1]
							aLim    := oQLGrafico:criaArrayLimites_nUcl_nCl_nLcl__PontosDesvioPadrao_XBR(aMedEstat)
						Endif
					Elseif cTpCarEsc == "XBS"
						If cTpCarEns == "XBR"
							// Função que calcula o desvio padrão
							aDesvPd := oQLGrafico:criaArrayDesvioPadrao(aMedicoes)

							// Desvio Padrão
							aJsData := oQLGrafico:criaArrayJsonXYPorArray(aDesvPd)
							aLim    := oQLGrafico:criaArrayLimites_nUcl_nCl_nLcl__PontosDesvioPadrao_XBS(aDesvPd) //Calcula os limites de acordo com os pontos de desvio padrão.
						Else //IND
                         	aDesvPd  := oQLGrafico:criaArrayDesvioPadrao(aMedicoes)
							aRetorno := oQLGrafico:criaArrayLimites_nUCL_nMedAmos_nLCL_aAmplMovel(aDataPar,cTpCarEns,cTpCarEsc) //Busco a Amplitude Móvel (Moving Range )	
							aLim     := oQLGrafico:criaArrayLimites_nUcl_nCl_nLcl__PontosDesvioPadrao_XBS(aRetorno[4])
							
							// Desvio Padrão
							aJsData  := oQLGrafico:criaArrayJsonXYPorArray(aDesvPd)
						Endif
					ElseIf (cTpCarEns == "HIS" .Or. cTpCarEns == "XBR" .Or. cTpCarEns == "XBS" ) .AND. cTpCarEsc == "IND"
					
						// Amplitude Movel
						aJsData := oQLGrafico:criaArrayJsonXYPorArray(aLim[4])
						aLim    := oQLGrafico:criaArrayLimites_nUCL_nAmpMed_nLCL(aLim[4], 1)
					Else
						If cTpCarEns == "XBS" //Carta de Controle Ensaio Carta XBS
							// Função que calcula o desvio padrão
							aDesvPd := oQLGrafico:criaArrayDesvioPadrao(aMedicoes)

							// Desvio Padrão
							aJsData := oQLGrafico:criaArrayJsonXYPorArray(aDesvPd)
							aLim    := oQLGrafico:criaArrayLimites_nUcl_nCl_nLcl__PontosDesvioPadrao_XBS(aDesvPd) //Calcula os limites de acordo com os pontos de desvio padrão.
						ElseIf cTpCarEns == "XBR"  //Carta de Controle Ensaio Carta XBR							
							
							aMedicoes := oQLGrafico:converteArrayOuMatrizEmArrayOuMatrizNumerico(aMedicoes) 
							aRetorno  := oQLGrafico:criaArrayJsonXYELimitesAmplitudeParaGrafico(aMedicoes)
							
							// Amplitude Movel
							aJsData := aRetorno[1]
							aLim    := aRetorno[2]
						ElseIf cTpCarEns == "IND"   //Carta de Controle Ensaio Carta IND
							// Calculo da Amplitude Móvel
							aRetorno := oQLGrafico:criaArrayLimites_nUCL_nMedAmos_nLCL_aAmplMovel(aDataPar, cTpCarEns, cTpCarEsc)

							// Amplitude Móvel
							aJsData := oQLGrafico:criaArrayJsonXYPorArray(aRetorno[4])
							aLim    := oQLGrafico:criaArrayLimites_nUcl_nCl_nLcl__PontosDesvioPadrao_IND(aRetorno[4]) //Calcula os limites de acordo com os pontos de amplitude movel.
						ElseIf cTpCarEns == "HIS"   //Carta de Controle Ensaio Carta HIS
							// Calculo da Amplitude Móvel
							aRetorno := oQLGrafico:criaArrayLimites_nUCL_nMedAmos_nLCL_aAmplMovel(aDataPar, cTpCarEns, cTpCarEsc)

							// Amplitude Móvel
							aJsData := oQLGrafico:criaArrayJsonXYPorArray(aRetorno[4])
							aLim    := oQLGrafico:criaArrayLimites_nUcl_nCl_nLcl__PontosDesvioPadrao_HIS(aRetorno[4])
						EndIf
					Endif
				Else 
					// Trecho segue similar para as demais rotinas
					If !IsInCallStack("QMTC010")
						aRetorno := oQLGrafico:criaArrayJsonXYELimitesAmplitudeParaGrafico(aMedEstat)
					Else
						aRetorno := oQLGrafico:criaArrayJsonXYELimitesAmplitudeParaGrafico(aMedicoes)
					Endif

					// Amplitude Movel
					aJsData := aRetorno[1]
					aLim    := aRetorno[2]
				Endif
			ELSE
				If (IsInCallStack("QIPA215") .Or. IsInCallStack("QIPM020")) .And. cTpCarEns == "XBR"
					aMedicoes := oQLGrafico:converteArrayOuMatrizEmArrayOuMatrizNumerico(aMedicoes) 
					aRetorno  := oQLGrafico:criaArrayJsonXYELimitesAmplitudeParaGrafico(aMedicoes)

					// Amplitude Movel
					aJsData := aRetorno[1]
					aLim    := aRetorno[2]
				ElseIF (IsInCallStack("QIPA215") .Or. IsInCallStack("QIPM020")) .And. cTpCarEns == "XBS"
					// Função que calcula o desvio padrão
					aDesvPd := oQLGrafico:criaArrayDesvioPadrao(aMedicoes)

					// Desvio Padrão
					aJsData := oQLGrafico:criaArrayJsonXYPorArray(aDesvPd)
					aLim    := oQLGrafico:criaArrayLimites_nUcl_nCl_nLcl__PontosDesvioPadrao_XBS(aDesvPd) //Calcula os limites de acordo com os pontos de desvio padrão.
				ElseIf (IsInCallStack("QIPA215") .Or. IsInCallStack("QIPM020")) .And. cTpCarEns == "HIS"
					// Calculo da Amplitude Móvel
					aRetorno := oQLGrafico:criaArrayLimites_nUCL_nMedAmos_nLCL_aAmplMovel(aDataPar, cTpCarEns, cTpCarEsc)

					// Amplitude Móvel
					aJsData := oQLGrafico:criaArrayJsonXYPorArray(aRetorno[4])
					aLim    := oQLGrafico:criaArrayLimites_nUcl_nCl_nLcl__PontosDesvioPadrao_HIS(aRetorno[4])
				ElseIf (IsInCallStack("QIPA215") .Or. IsInCallStack("QIPM020")) .And. cTpCarEns == "IND"
						// Calculo da Amplitude Móvel
						aRetorno := oQLGrafico:criaArrayLimites_nUCL_nMedAmos_nLCL_aAmplMovel(aDataPar, cTpCarEns, cTpCarEsc)
						
						// Amplitude Móvel
						aJsData := oQLGrafico:criaArrayJsonXYPorArray(aRetorno[4])
						aLim    := oQLGrafico:criaArrayLimites_nUcl_nCl_nLcl__PontosDesvioPadrao_IND(aRetorno[4]) //Calcula os limites de acordo com os pontos de amplitude movel.
				Else
					If !Empty(aLim[4])
						// Amplitude Movel
						aJsData := oQLGrafico:criaArrayJsonXYPorArray(aLim[4])
						aLim    := oQLGrafico:criaArrayLimites_nUCL_nAmpMed_nLCL(aLim[4], 1)
					Endif
				Endif
			ENDIF
			
			aSeries     := {}
			aLimits     := {}
			aCategories := {}
			
			oKendo:AddChart('chart2',aTitCarCon[2], "bottom", .T., .F., nWidth - 20/* 650 */, 250, !lReport)
			Aadd(aSeries, KendoSeries():New(STR0010,"y1", "x1", "cat1",, "line","normal",,,,,,"{0:N2}")) //"Valor"
			Aadd(aCategories, KendoCategory():New("cat1",,.F., .T., 0,,,"{0:N0}",cFontLabel))
			Aadd(aLimits, KendoLimit():New("UCL", aLim[1], "red"))
			Aadd(aLimits, KendoLimit():New("CL", aLim[2], "blue"))
			Aadd(aLimits, KendoLimit():New("LCL", aLim[3], "green"))
			oKendo:SetCategories('chart2', aCategories)
			oKendo:SetLimits('chart2', aLimits)
			If IsInCallStack("QIPA215") .Or. IsInCallStack("QIPM020")
				If cTpCarEns == "IND" .And. (cTpCarEsc == "XBR" .Or. cTpCarEsc == "XBS")
					aSeries     := {}
				Endif
			Endif
			oKendo:SetSeries('chart2', aSeries)
			oKendo:SetData('chart2', aJsData)
		ENDIF //Amostras na imressão PDF

		IF nTipo == 9 .Or. nTipo == 91 .Or. nTipo == 92 .Or. nTipo == 97
			Aadd(aComments, KendoComments():New(STR0007)) //"Amostras"

			FOR nX := 1 TO LEN(aMedicoes)
				IF lXbXbr
					aAmostra := {ArrTokStr(aMedicoes[nX], ";")}
				ELSE
					aAmostra := aMedicoes[nX]
				ENDIF
				aAmostra := oQLGrafico:criaArrayAmostrasComQuebra(aAmostra, 50)
				For nY := 1 To Len(aAmostra)
					Aadd(aComments, KendoComments():New(aAmostra[nY]))
				Next nY
			NEXT nX

			Aadd(aComments, KendoComments():New("--"))
			oKendo:SetComments(IIF(nTipo == 9 .Or. nTipo == 91 .Or. nTipo == 97, 'chart1', 'chart2'), aComments)
		ENDIF

		IF lReport
			oKendo:lReport := .T.
		ENDIF

		aDataPar := aClone(aDataParBkp)
	
    ElseIf nTipo == 2 //Diagrama de Pareto

		aDataParAux := aClone(aDataPar)  //Array auxiliar

		ASORT(aDataPar,,, { |x, y| x[1] > y[1] } )

		aResult := oQLGrafico:criaArrayJsonXYDiagramaDePareto(aDataPar, 4)
		aJsData := aResult[1]

		aMedicoes := {}

		FOR nX := 1 TO LEN(aDataPar)
			AADD(aMedicoes, {CVALTOCHAR(aDataPar[nX, 1])})
		NEXT nX

	    oKendo := KendoChart():New(oPnMov, 350, 742)
	    oKendo:AddChart('chart1',STR0009, "bottom", .F., .F., 650, 275, !lReport) //"Diagrama de Pareto"
	    TButton():New( 005, 005, STR0004, oPnInd, {|| oQLGrafico:imprimirGrafico(aDataPar, 2, aMedicoes, aTitCarCon, aLimites, cDirPng, cArqPNG, lXbXbr, .T.) },40,010,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Imprimir"
	    TButton():New( 005, 055, STR0005, oPnInd, {|| oQLGrafico:exibeBrowseMedicoes(aMedicoes) },40,010,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Medições"
		Aadd(aSeries, KendoSeries():New(STR0010,"y1", "x1", "cat1", 'y1', "column",,,.T.)) //"Valor"
	    Aadd(aSeries, KendoSeries():New(STR0011,"y2", "x2", "cat2", 'y2', "line",,,.T.)) //"Pareto Acumulado"
	    Aadd(aCategories, KendoCategory():New("cat1",,.F., .T., 0))
	    Aadd(aCategories, KendoCategory():New("cat2",,.F., .T., 0))
		Aadd(aValueAxis, KendoValueAxis():New('y1', STR0012,0, aResult[2])) //"Valores"
		Aadd(aValueAxis, KendoValueAxis():New('y2', STR0013 +" %" ,0, 100, 10)) //"Acumulado"
		oKendo:SetValueAxis('chart1', aValueAxis)
	    oKendo:SetCategories('chart1', aCategories)
	    oKendo:SetSeries('chart1', aSeries)
	    oKendo:SetData('chart1', aJsData)

		//TODO TESTAR TRECHO AO IMPRIMIR
		IF IsInCallStack(Upper("imprimirGrafico"))

			Aadd(aComments, KendoComments():New(STR0007)) //"Amostras"

			FOR nX := 1 TO LEN(aMedicoes)
				IF lXbXbr
					aAmostra := ArrTokStr(aMedicoes[nX], ";")
				ELSE
					aAmostra := aMedicoes[nX]
				ENDIF
				aAmostra := oQLGrafico:criaArrayAmostrasComQuebra(aAmostra, 50)
				Aadd(aComments, KendoComments():New(aAmostra))
			NEXT nX

			Aadd(aComments, KendoComments():New("--"))
			oKendo:SetComments('chart1', aComments)
		
		ENDIF

		IF lReport
			oKendo:lReport := .T.
		ENDIF

		aDataPar := aClone(aDataParAux)

	ElseIf nTipo == 3 .And. (IsInCallStack("QPPA170") .Or. IsInCallStack("QPPR170")) //Histrograma QPPA170 / QPPR170

		aDataParAux := aClone(aDataPar)  //Array auxiliar

		aAllMed := aClone(oQLGrafico:converteArrayEmArrayNumerico(aDataPar))
		aMedAux := oQLGrafico:criaMatrizNumerica(aMedicoes)
	    
        IF lXbXbr
			aMedEstat := oQLGrafico:criaArrayPorMatriz(aMedicoes)
		ELSE
			aMedEstat := aDataPar
		ENDIF

		histArry := Histograma():New("Teste", oQLGrafico:criaArrayNumericoPorArrayOuMatriz(aDataPar))

		aCol1       := histArry:nb:p
		aCol2       := histArry:frequencia
		aCol3       := aDataPar
		aCortes     := histArry:Cortes
		nPrimeiro   := histArry:nb:pontos[1]
		nIncremento := histArry:nb:nIncrBarra
		nMenor      := histArry:menor
		nMedia      := histArry:media
		nMaior      := histArry:maior

		aadd(aCol2, 0)
		AIns( aCol2, 1 )
		aCol2[1] := 0

		aJsData := oQLGrafico:criaArrayJsonXYHistograma(aCol1, aCol2, nPrimeiro, nIncremento)

		aCol1 := ASORT(aCol1,,, { |x, y| x > y } )
		nMaxDist := aCol1[1]
		aCol2 := ASORT(aCol2,,, { |x, y| x > y } )
		nMaxFreq := aCol2[1]

		aSeries     := {}
		aCategories := {}
		aValueAxis  := {}

		aadd(aSeries, KendoSeries():New("" ,"yDist", "xDist", "cDist", 'yDist', "line",,'red'))
		aadd(aSeries, KendoSeries():New("" ,"yFreq", "xFreq", "cFreq", 'yFreq', "bar",,'#0000FF'))

		aSeries[Len(aSeries)]:RemoveMarkers()
		aSeries[Len(aSeries)]:SetWidth(6)

		Aadd(aCategories, KendoCategory():New("cDist",,.F., .F., 000, .t.))
		Aadd(aCategories, KendoCategory():New("cFreq",,.F., .T., -90, .f.))

		nMenor := (nPrimeiro - nMenor) * nIncremento
		nMedia := (nMedia - nPrimeiro) / nIncremento 
		nMaior := (nMaior - nPrimeiro) / nIncremento

		aCategories[Len(aCategories)]:AddNote(nMenor, '', '#FF0000', "longDashDotDot", 180)
		aCategories[Len(aCategories)]:AddNote(nMedia, '', '#FF0000', "solid",          180)
		aCategories[Len(aCategories)]:AddNote(nMaior, '', '#FF0000', "longDashDotDot", 180)

		aCategories[Len(aCategories)]:SetNoteLength(290) //Altura calculada em pixels

		Aadd(aValueAxis, KendoValueAxis():New('yDist', '' ,0, nMaxDist*1.05)) //5 % a mais para não ficar grudado em cima
		Aadd(aValueAxis, KendoValueAxis():New('yFreq', '' ,0, nMaxFreq*1.05))

		oKendo := KendoChart():New(oPnMov, 495, 742)
	    oKendo:AddChart('chart1',STR0014, "bottom", .T., .F., 650, 275, !lReport) //"Histograma"
	    TButton():New( 005, 005, STR0004, oPnInd, {|| oQLGrafico:imprimirGrafico(aDataPar, 3, aMedicoes, aTitCarCon, aLimites, cDirPng, cArqPNG, lXbXbr, .T.)/* ,oKendoIMP:Print() */ },40,010,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Imprimir"
		TButton():New( 005, 55, STR0005, oPnInd, {|| oQLGrafico:exibeBrowseMedicoes(aMedicoes) },40,010,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Medições"
		If IsInCallStack("QPPA170")
			TButton():New( 005, 105, STR0006, oPnInd, {|| oQLGrafico:calculaExibeExportaEstatisticasPPAP(aAllMed, aMedAux, aLimites, nTamAmostr) },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )//"Estatísticas"
		Else
			TButton():New( 005, 105, STR0006, oPnInd, {|| oQLGrafico:calculaExibeExportaEstatisticasCartasDeControleOuHistograma(aMedEstat, aMedAux, aLimites) },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )//"Estatísticas"
		Endif
		oKendo:SetValueAxis('chart1', aValueAxis)
		oKendo:SetCategories('chart1', aCategories)
		oKendo:SetAxisCrossingValue(aCategories, Len(aCol2))
		oKendo:SetSeries('chart1', aSeries)
		oKendo:SetData('chart1', aJsData)

		IF IsInCallStack(Upper("imprimirGrafico"))

			Aadd(aComments, KendoComments():New(STR0007)) //"Amostras"

			FOR nX := 1 TO LEN(aMedicoes)
				IF lXbXbr
					cAmostra := ArrTokStr(aMedicoes[nX], ";")
				ELSE
					cAmostra := aMedicoes[nX]
				ENDIF
				Aadd(aComments, KendoComments():New(cAmostra))
			NEXT nX
		
		ENDIF
		
		Aadd(aComments, KendoComments():New("--"))
		oKendo:SetComments('chart1', aComments)
	
		IF lReport
			oKendo:lReport := .T.
		ENDIF

		aDataPar := aClone(aDataParAux)
	
	ElseIf nTipo == 3 //Histrograma

		aDataPar := oQLGrafico:converteArrayOuMatrizEmArrayOuMatrizNumerico(aDataPar)

        IF lXbXbr
			aMedEstat := oQLGrafico:criaArrayPorMatriz(aMedicoes)
		ELSE
			aMedEstat := aDataPar
		ENDIF

		aMedAux   := aClone(aMedicoes)
		aMedAux   := oQLGrafico:converteMatrizEmMatrizNumerica(aMedAux)

		histArry := Histograma():New("Teste", aMedEstat)

		aCol1       := histArry:nb:p
		aCol2       := histArry:frequencia
		aCol3       := aDataPar
		aCortes     := histArry:Cortes
		nPrimeiro   := histArry:nb:pontos[1]
		nIncremento := histArry:nb:nIncrBarra
		nMenor      := histArry:menor
		nMedia      := histArry:media
		nMaior      := histArry:maior

		aadd(aCol2, 0)
		AIns( aCol2, 1 )
		aCol2[1] := 0

		aJsData := oQLGrafico:criaArrayJsonXYHistograma(aCol1, aCol2, nPrimeiro, nIncremento)

		aCol1 := ASORT(aCol1,,, { |x, y| x > y } )
		nMaxDist := aCol1[1]
		aCol2 := ASORT(aCol2,,, { |x, y| x > y } )
		nMaxFreq := aCol2[1]

		aSeries     := {}
		aCategories := {}
		aValueAxis  := {}

		aadd(aSeries, KendoSeries():New("" ,"yDist", "xDist", "cDist", 'yDist', "line",,'red'))
		aadd(aSeries, KendoSeries():New("" ,"yFreq", "xFreq", "cFreq", 'yFreq', "bar",,'#0000FF'))

		aSeries[Len(aSeries)]:RemoveMarkers()
		aSeries[Len(aSeries)]:SetWidth(6)

		Aadd(aCategories, KendoCategory():New("cDist",,.F., .F., 000, .t.))
		Aadd(aCategories, KendoCategory():New("cFreq",,.F., .T., -90, .f.))

		IF lMV_QCALLIM .Or. (IsInCallStack("QIPM020") .AND. !Empty(cLIE) .AND. !Empty(cLSE))
			nMenor := aLimites[2]
			nMedia := aLimites[1]
			nMaior := aLimites[3]
		ENDIF
		
		nMenor := (nMenor - nPrimeiro) / nIncremento
		nMedia := (nMedia - nPrimeiro) / nIncremento
		nMaior := (nMaior - nPrimeiro) / nIncremento
		
		aCategories[Len(aCategories)]:AddNote(nMenor, '', '#FF0000', "longDashDotDot", 180) //LSL - (lower specification limit)		
		aCategories[Len(aCategories)]:AddNote(nMedia, '', '#FF0000', "solid",          180) //REFERENCIA		
		aCategories[Len(aCategories)]:AddNote(nMaior, '', '#FF0000', "longDashDotDot", 180) //USL - (upper specification limit) 

		aCategories[Len(aCategories)]:SetNoteLength(290) //Altura calculada em pixels

		Aadd(aValueAxis, KendoValueAxis():New('yDist', '' ,0, nMaxDist*1.05)) //5 % a mais para não ficar grudado em cima
		Aadd(aValueAxis, KendoValueAxis():New('yFreq', '' ,0, nMaxFreq*1.05))

		oKendo := KendoChart():New(oPnMov, 495, 742)
	    oKendo:AddChart('chart1',STR0014, "bottom", .T., .F., 650, 275, !lReport) //"Histograma"
	    TButton():New( 005, 005, STR0004, oPnInd, {|| oQLGrafico:imprimirGrafico(aDataPar, 3, aMedicoes, aTitCarCon, aLimites, cDirPng, cArqPNG, lXbXbr, .T.)/* ,oKendoIMP:Print() */ },40,010,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Imprimir"
		TButton():New( 005, 55, STR0005, oPnInd, {|| oQLGrafico:exibeBrowseMedicoes(aMedicoes) },40,010,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Medições"
		TButton():New( 005, 105, STR0006, oPnInd, {|| oQLGrafico:calculaExibeExportaEstatisticasCartasDeControleOuHistograma(aMedEstat, aMedAux, aLimites, cTpCarEsc, cTpCarEns, nTamAmostr) },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )//"Estatísticas"
		oKendo:SetValueAxis('chart1', aValueAxis)                       
		oKendo:SetCategories('chart1', aCategories)
		oKendo:SetAxisCrossingValue(aCategories, Len(aCol2))
		oKendo:SetSeries('chart1', aSeries)
		oKendo:SetData('chart1', aJsData)

		IF IsInCallStack(Upper("imprimirGrafico"))

			Aadd(aComments, KendoComments():New(STR0007)) //"Amostras"

			FOR nX := 1 TO LEN(aMedicoes)
				IF lXbXbr
					cAmostra := ArrTokStr(aMedicoes[nX], ";")
				ELSE
					cAmostra := aMedicoes[nX]
				ENDIF
				Aadd(aComments, KendoComments():New(cAmostra))
			NEXT nX
		
		ENDIF
		
		Aadd(aComments, KendoComments():New("--"))
		oKendo:SetComments('chart1', aComments)
	
		IF lReport
			oKendo:lReport := .T.
		ENDIF
	
	ElseIf nTipo == 4 //Linearidade MSA

		aSeries := {}
		aData   := {}
		aData   := oQLGrafico:criaArrayJsonXYIndexCoordenadas(aDataPar)
		cTitLinear := STR0015 + " " + aDataPar[1] //"Gráfico de Linearidade"

		oKendo := KendoChart():New(oPnMov, 350, 742)
	    oKendo:AddChart('chart1', cTitLinear, "bottom", .F.,,,,!lReport)
		IF !lReport
			TButton():New( 005, 005, STR0004, oPnInd, {|| oQLGrafico:imprimirGrafico(aDataPar, 4, aData[4], cTitLinear, , cDirPng, cArqPNG, , .T.)/* ,oKendoIMP:Print() */ },40,010,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Imprimir"
			IF !EMPTY(aData[4])
				TButton():New( 005, 55, STR0005, oPnInd, {|| oQLGrafico:exibeBrowseMedicoes(aData[4]) },40,010,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Medições"
			ENDIF
		ENDIF
		//Regressão
		Aadd(aSeries, KendoSeries():New(STR0033,"y1", "x1", , , "scatterLine","normal","#000000",.F.)) //"Regressão"
		//Médias das Têndencias
		Aadd(aSeries, KendoSeries():New(STR0034,"y2", "x2", , , "scatter","normal","#FFE135",.F.,,"cross")) //"Médias das Tendências"
		//Resultados Intermediários
		Aadd(aSeries, KendoSeries():New(STR0035,"y3", "x3", , , "scatter","normal",,.F.)) //"Resultados Intermediários"
		//Intervalo de Confiança Superior
		Aadd(aSeries, KendoSeries():New(STR0036,"y4", "x4", , , "scatterLine","normal","#ff2800",.F.,"dot")) //"Intervalo de Confianca Superior"
		//Intervalo de Confiança Inferior
		Aadd(aSeries, KendoSeries():New(STR0037,"y5", "x5", , , "scatterLine","normal","#ff2800",.F.,"dot")) //"Intervalo de Confianca Inferior"
		//cName, cField, cCategoryField, cCategoryAxis, cValueAxis, cType, cStyle, cColor, lLabels, cDashType, cMakerType, lVsbleLeg
		
 		aSeries[1]:RemoveMarkers()
		aSeries[4]:RemoveMarkers()
		aSeries[5]:RemoveMarkers()
		oKendo:SetSeries('chart1', aSeries)
		nYMin := aData[2]
		nXMin := aData[3] 

		//cEixo, nMin, nMax, nStep, nAxsCrosVal
 		Aadd(aMyAxis, KendoAxis():New("y",nYMin,,,nYMin))
 		Aadd(aMyAxis, KendoAxis():New("x",nXMin,,,nXMin))
		oKendo:SetKendoAxis('chart1', aMyAxis)

		//oKendo:SetSeries('chart1', aSeries)
	    oKendo:SetData('chart1', aData[1])

		IF EMPTY(aDataPar[4])
			Aadd(aComments, KendoComments():New(STR0038 + STR0039 +aDataPar[3]+ STR0040 + aDataPar[2])) //"Valor de Referência: " "" Tendência = " " " Grau de Ajuste(R2) = "
		ELSE
			Aadd(aComments, KendoComments():New(STR0038 + STR0040 + aDataPar[2]+ STR0041 + aDataPar[3] + STR0039 + aDataPar[4] + STR0042 + aDataPar[5])) //"Valor de Referência: " " Grau de Ajuste(R2) = " " %Linearidade = "" Tendência = "" Linearidade = "
		ENDIF

		IF IsInCallStack(Upper("imprimirGrafico"))
			Aadd(aComments, KendoComments():New('')) //Linha em branco
			Aadd(aComments, KendoComments():New(STR0007 + ":")) //Amostras

			aAmostras := {}
			cAmostra  := ''
			aAmostras := oQLGrafico:criaArrayAmostrasComQuebra(aData[4], 15)
			FOR nX := 1 TO LEN(aAmostras)

				FOR nY := 1 TO LEN(aAmostras[nX])
					aAmostras[nX,nY][1] := CValToChar(aAmostras[nX,nY][1])
					aAmostras[nX,nY][2] := CValToChar(aAmostras[nX,nY][2])
					aAmostras[nX,nY] := aAmostras[nX,nY][1] + "," + aAmostras[nX,nY][2]
				NEXT nY

				cAmostra := ArrTokStr(aAmostras[nX], "; ")
				
				Aadd(aComments, KendoComments():New(cAmostra))
				
			NEXT nX
		ENDIF

		Aadd(aComments, KendoComments():New('--'))
		oKendo:SetComments('chart1', aComments)

		IF lReport
			oKendo:lReport := .T.
		ENDIF
	
	ElseIf nTipo == 5 //Histrograma Metrologia

		aDados    := {}
		aMedicoes := {}
		aMyAxis   := {}
		aMedias   := {}

		//TODO REVISAR HISTOGRAMA METROLOGIA - ESTRANHO
		For nI := 2 To len(aDataPar)
	    	If ValType(aDataPar[nI]) == "C"
	    		AADD( aDados, SuperVal(aDataPar[nI]) )
			Else
				AADD( aDados, aDataPar[nI] )
	    	EndIf
	    	AADD( aMedicoes, {aDados[LEN(aDados)]} )
	    Next

		oDesvPad   := NB():New(aDados)
		aMedias    := oDesvPad:mediasNB(aDados)
		nDesvPad   := oDesvPad:getDesvPad(aDados)
		nMedMaior  := aMedias[2] + (nDesvPad * 3)
		nMedMenor  := aMedias[1] - (nDesvPad * 3)
		nTamanho   := Max(Len(aDados), 30)
		nEstClasse := SQRT(nTamanho) + 1
		nIncrBarra := (aMedias[3] - aMedias[1]) / nEstClasse
		aValores   := oQLGrafico:criaArrayBaseEmInicioIncrementoEQtdPontos(nMedMenor, nIncrBarra, nTamanho)
		aNormPad   := oQLGrafico:criaArrayDistribuicaoNormalPadrao(aValores, nDesvPad, aMedias[2], oDesvPad)
		aFrequenci := oDesvPad:findPosCol(aDados, aValores)
		aFrequeLim := oDesvPad:findPosLim(aDados, aValores, aLimites)

		//Remove os zeros da curva e equaliza os dados para eixos do gráfico
 		For nX := Len(aNormPad) To 1 Step -1
			If aNormPad[nX] == 0		
				aDel(aNormPad,nX)
				aSize(aNormPad, len(aNormPad)-1)

				aDel(aValores,nX)
				aSize(aValores, len(aValores)-1)

				aDel(aFrequenci,nX)
				aSize(aFrequenci, len(aFrequenci)-1)
			EndIf
		Next

		aJsData := oQLGrafico:criaArrayJsonXYHistogramaMetrologia(aValores, aNormPad, aFrequenci)

 		nMaxDist := ASORT(aClone(aNormPad),,, { |x, y| x > y } )[1]*1.10
		nMaxFreq := ASORT(aClone(aFrequenci),,, { |x, y| x > y } )[1]*1.10

		aadd(aSeries, KendoSeries():New("" ,"yDist", "xDist", "cDist", 'yDist', "line",,'red'))
		aadd(aSeries, KendoSeries():New("" ,"yFreq", "xFreq", "cFreq", 'yFreq', "column",,'#0000FF'))

		Aadd(aCategories, KendoCategory():New("cDist",,.F., .F., 000, .T.))
		Aadd(aCategories, KendoCategory():New("cFreq",,.F., .T., -90, .F.))

 		Aadd(aValueAxis, KendoValueAxis():New('yDist', '' ,0, nMaxDist)) //5 % a mais para não ficar grudado em cima
		Aadd(aValueAxis, KendoValueAxis():New('yFreq', '' ,0, nMaxFreq))

		TButton():New( 005, 005, STR0004, oPnInd, {|| oQLGrafico:imprimirGrafico(aDataPar, 5, aMedicoes, aTitCarCon, aLimites, cDirPng, cArqPNG, lXbXbr, .T.)/* ,oKendoIMP:Print() */ },40,010,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Imprimir"

		aCategories[Len(aCategories)]:AddNote(aFrequeLim[2] - 1, '', '#FF0000', "longDashDotDot", 165) //LSL - (lower specification limit)		
		aCategories[Len(aCategories)]:AddNote(aFrequeLim[1] - 1, '', '#FF0000', "solid",          165) //REFERENCIA		
		aCategories[Len(aCategories)]:AddNote(aFrequeLim[3] - 1, '', '#FF0000', "longDashDotDot", 165) //USL - (upper specification limit) 
		
		oKendo := KendoChart():New(oPnMov, 495, 742)
	    oKendo:AddChart('chart1', ALLTRIM(aDataPar[1]), "bottom", .F.,,,,.F.)
	    TButton():New( 005, 55, STR0005, oPnInd, {|| oQLGrafico:exibeBrowseMedicoes(aMedicoes) },40,010,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Medições"

		aSeries[1]:RemoveMarkers()

		oKendo:SetValueAxis('chart1', aValueAxis)                       
		oKendo:SetCategories('chart1', aCategories)
		oKendo:SetAxisCrossingValue(aCategories, nTamanho)
		oKendo:SetSeries('chart1', aSeries)
		oKendo:SetData('chart1', aJsData)

		IF IsInCallStack(Upper("imprimirGrafico"))

			Aadd(aComments, KendoComments():New(STR0007)) //"Amostras"

			FOR nX := 1 TO LEN(aMedicoes)
				IF lXbXbr
					cAmostra := ArrTokStr(aMedicoes[nX], ";")
				ELSE
					cAmostra := aMedicoes[nX][1]
				ENDIF
				Aadd(aComments, KendoComments():New(cAmostra))
			NEXT nX

			Aadd(aComments, KendoComments():New("--"))
			oKendo:SetComments('chart1', aComments)
		
		ENDIF

		IF lReport
			oKendo:lReport := .T.
		ENDIF

	ElseIf nTipo == 6 //Relatório Índice Qualidade

		aResult := oQLGrafico:criaArrayJsonXYDiagramaDePareto(aDataPar, 4)
		aJsData := aResult[1]

		aMedicoes := {}
		FOR nX := 1 TO LEN(aDataPar)
			AADD(aMedicoes, {CVALTOCHAR(aDataPar[nX, 1])})
		NEXT nX

		oKendo := KendoChart():New(oPnMov, 350, 742)
	    oKendo:AddChart('chart1', aTitCarCon[1], "bottom", .F.,,,,.F.)
	    TButton():New( 005, 005, STR0004, oPnInd, {|| oKendo:Print() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Imprimir"
	    TButton():New( 005, 55, STR0005, oPnInd, {|| oQLGrafico:exibeBrowseMedicoes(aMedicoes) },40,010,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Medições"
		Aadd(aSeries, KendoSeries():New(STR0032,"y1", "x1", "cat1", 'y1', "column",,,.T.)) //"Produto"
	    Aadd(aCategories, KendoCategory():New("cat1",,.F., .T., 0))
		Aadd(aValueAxis, KendoValueAxis():New('y1', 'IQF' ,0, aResult[2]))
		oKendo:SetValueAxis('chart1', aValueAxis)
	    oKendo:SetCategories('chart1', aCategories)
	    oKendo:SetSeries('chart1', aSeries)
	    oKendo:SetData('chart1', aJsData)

		oKendo:lReport := .T.

	ElseIf nTipo == 7 //Relatorio de Performance de Sistemas de Medição 

		aDadosTmp1 := {}
		aDadosSer1 := {}
		aDadosTmp2 := {}
		aDadosSer2 := {}

		nIni := ASCAN( aDataPar, "[INICIO DE DADOS]" )
		nFim := ASCAN( aDataPar, "[FIM DE DADOS]" ) - 1
		nFator := (nFim - nIni) / SUPERVAL(aDataPar[9])

		For nI := 1 To (nFim - nIni)

			nPosVazio := AT(" ", aDataPar[nI + nIni])

			cTempValue := LTRIM(SUBSTR(aDataPar[nI + nIni], nPosVazio, LEN(aDataPar[nI + nIni])))

			nPosVazio := AT(" ", cTempValue)

			cValue1 := (ALLTRIM(SUBSTR(cTempValue, 1, nPosVazio)))
			cValue2 := (ALLTRIM(SUBSTR(cTempValue, nPosVazio, LEN(cTempValue))))

	    	IF Mod( nI, nFator ) == 0 //https://tdn.totvs.com/display/tec/Mod
				AADD( aDadosTmp1, SUPERVAL(cValue1) )
				AADD( aDadosTmp2, SUPERVAL(cValue2) )
				AADD( aDadosSer1, aDadosTmp1 )
				AADD( aDadosSer2, aDadosTmp2 )
				aDadosTmp1 := {}
				aDadosTmp2 := {}
			ELSE
				AADD(aDadosTmp1, SUPERVAL(cValue1))
				AADD(aDadosTmp2, SUPERVAL(cValue2))
			ENDIF

	    Next nI

		nCont := 1

		FOR nX := 1 TO LEN(aDadosSer1)

			For nY := 1 To len(aDadosSer1[nX])
				oData := JsonObject():New()
				oData['y' + CVALTOCHAR( nX )] := aDadosSer1[nX, nY]
				oData['x' + CVALTOCHAR( nX )] := nCont
				oData['z' + CVALTOCHAR( nX )] := aDadosSer2[nX, nY]
				oData['w' + CVALTOCHAR( nX )] := nCont
				nCont ++
				Aadd(aData, oData)
			Next

			IF nX == 1
				cContador := "A"
			ELSE
				cContador := UPPER( __SOMA1( cContador ) )
			ENDIF

			cCor := oQLGrafico:retornaCorAleatoria()

			Aadd(aSeries, KendoSeries():New(STR0031 + " " + cContador,'y' + CVALTOCHAR( nX ), 'x' + CVALTOCHAR( nX ), "cat1",, "line","normal",cCor,,,,,)) //"Operador"
			Aadd(aSeries, KendoSeries():New("",                     'z' + CVALTOCHAR( nX ), 'w' + CVALTOCHAR( nX ), "cat1",, "line","normal",cCor,,,,,))

		NEXT nX

		oKendo := KendoChart():New(oPnMov, 495, 742)
	    oKendo:AddChart('chart1', aTitCarCon[1], "bottom", .F., .T., 650, 275, .F.)
	    TButton():New( 005, 005, STR0004, oPnInd, {|| oKendo:Print() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Imprimir"
	    Aadd(aCategories, KendoCategory():New("cat1",,.F., .T., 0,,.F.))
	    Aadd(aLimits, KendoLimit():New(STR0029, SUPERVAL(aDataPar[3]), "#000000","solid")) //Black //"Valor Medido"
	    Aadd(aLimits, KendoLimit():New(STR0030, SUPERVAL(aDataPar[5]), "#7fff00","dash")) //Verde Paris //"Valor Real"
	   	Aadd(aValueAxis, KendoValueAxis():New('y1', 'MEDIA(U.M)' ,0,))
		oKendo:SetValueAxis('chart1', aValueAxis)
	    oKendo:SetCategories('chart1', aCategories)
	    oKendo:SetLimits('chart1', aLimits)
	    oKendo:SetSeries('chart1', aSeries)
	    oKendo:SetData('chart1', aData)
	    
		nIni := ASCAN( aDataPar, "[INICIO AMPLITUDE]" )
		nFim := ASCAN( aDataPar, "[FIM AMPLITUDE]" ) - 1

		aDadosTmp1 := {}
		aDadosSer1 := {}

		For nI := 1 To (nFim - nIni)

			nPosVazio := AT(" ", aDataPar[nI + nIni])

			cTempValue := LTRIM(SUBSTR(aDataPar[nI + nIni], nPosVazio, LEN(aDataPar[nI + nIni])))

			nPosVazio := AT(" ", cTempValue)

			cValue1 := (ALLTRIM(SUBSTR(cTempValue, 1, nPosVazio)))

	    	IF Mod( nI, nFator ) == 0 //https://tdn.totvs.com/display/tec/Mod
				AADD( aDadosTmp1, SUPERVAL(cValue1) )
				AADD( aDadosSer1, aDadosTmp1 )
				aDadosTmp1 := {}
			ELSE
				AADD(aDadosTmp1, SUPERVAL(cValue1))
			ENDIF

	    Next nI

		aSeries     := {}
		aLimits     := {}
		aCategories := {}
		aData       := {}
		aValueAxis  := {}
		nCont       := 1

		FOR nX := 1 TO LEN(aDadosSer1)

			For nY := 1 To len(aDadosSer1[nX])
				oData := JsonObject():New()
				oData['y' + CVALTOCHAR( nX )] := aDadosSer1[nX, nY]
				oData['x' + CVALTOCHAR( nX )] := nCont
				nCont ++
				Aadd(aData, oData)
			Next

			IF nX == 1
				cContador := "A"
			ELSE
				cContador := UPPER( __SOMA1( cContador ) )
			ENDIF

			Aadd(aSeries, KendoSeries():New(STR0031 + " " + cContador,'y' + CVALTOCHAR( nX ), 'x' + CVALTOCHAR( nX ), "cat1",, "line","normal",oQLGrafico:retornaCorAleatoria(),,,,,)) //"Operador"

		NEXT nX
	    
		oKendo:AddChart('chart2', aTitCarCon[2], "bottom", .F., .T., 650, 275, .F.)
	    Aadd(aCategories, KendoCategory():New("cat1",,.F., .T., 0,,.F.))
	    Aadd(aLimits, KendoLimit():New(STR0027, SUPERVAL(aDataPar[7]), "#000000","solid")) //Black //"Média Amplit."
		Aadd(aValueAxis, KendoValueAxis():New('y1', STR0028,0,)) //"AMPLITUDE(U.M)"
		oKendo:SetValueAxis('chart2', aValueAxis)
	    oKendo:SetCategories('chart2', aCategories)
	    oKendo:SetLimits('chart2', aLimits)
	    oKendo:SetSeries('chart2', aSeries)
	    oKendo:SetData('chart2', aData)

		oKendo:lReport := .T.
	ElseIf nTipo == 8 //Carta Individual  - QMTM420

		aDataPar := oQLGrafico:converteArrayEmArrayNumerico(aDataPar)

		aMedEstat := oQLGrafico:criaArrayPorMatriz(aMedicoes)
		nMediaEst := 0 
		aEval(aMedEstat, {|n| nMediaEst += n})

		nMediaEst := (nMediaEst / LEN(aMedEstat))

		//Valores Individuais--------
	    aJsData := oQLGrafico:criaArrayJsonXYPorArray(aDataPar)
		aLim    := oQLGrafico:criaArrayLimites_nUcl_nMedia_nLcl__ComMediasNbCalculada(aDataPar)
	    //---------------------------
	
	    oKendo := KendoChart():New(oPnMov, 495, 742)
	    oKendo:AddChart('chart1',aTitCarCon[1], "bottom", .F., .F., 650, 275, !lReport)
	    TButton():New( 005, 005, STR0004, oPnInd, {|| oQLGrafico:imprimirGrafico(aDataPar, 8, aMedicoes, aTitCarCon, aLimites, cDirPng, cArqPNG, lXbXbr, .T.)/* ,oKendoIMP:Print() */ },40,010,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Imprimir"
	    TButton():New( 005, 055, STR0005, oPnInd, {|| oQLGrafico:exibeBrowseMedicoes(aMedicoes) },40,010,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Medições"
		TButton():New( 005, 105, STR0006, oPnInd, {|| oQLGrafico:calculaExibeExportaEstatisticasCartaIndividual(aMedEstat, aDataPar, aLimites, nMediaEst) },40,010,,,.F.,.T.,.F.,,.F.,,,.F. )//"Estatísticas"
	    Aadd(aSeries, KendoSeries():New(STR0010,"y1", "x1", "cat1",, "line","normal")) //"Valor"
	    Aadd(aCategories, KendoCategory():New("cat1",,.F., .T., 0))
	    Aadd(aLimits, KendoLimit():New("UCL", aLim[1], "red"))
	    Aadd(aLimits, KendoLimit():New("CL", aLim[2], "blue"))
	    Aadd(aLimits, KendoLimit():New("LCL", aLim[3], "green"))
		oKendo:SetCategories('chart1', aCategories)
	    oKendo:SetLimits('chart1', aLimits)
	    oKendo:SetSeries('chart1', aSeries)
		oKendo:SetData('chart1', aJsData)

		IF IsInCallStack(Upper("imprimirGrafico"))

			Aadd(aComments, KendoComments():New(STR0007)) //"Amostras"

			FOR nX := 1 TO LEN(aMedicoes)
				IF lXbXbr
					cAmostra := ArrTokStr(aMedicoes[nX], ";")
				ELSE
					cAmostra := aMedicoes[nX]
				ENDIF
				Aadd(aComments, KendoComments():New(cAmostra))
			NEXT nX

			Aadd(aComments, KendoComments():New("--"))
			oKendo:SetComments('chart1', aComments)
		
		ENDIF

		IF lReport
			oKendo:lReport := .T.
		ENDIF
		
	EndIf
    oDlgM:Activate()
Return

/*/{Protheus.doc} criaArrayLimites_nUcl_nMedia_nLcl
//De acordo com o array informado, retorna UCL,Media,LCL da Amplitude Movel
@author brunno.costa / rafael.kleestadt
@since 06/05/2022
@version 1.0
@return ${return}, ${return_description}
@param aDataAM, array, descricao
@type METHOD
/*/
METHOD criaArrayLimites_nUcl_nMedia_nLcl__ComMediasNbCalculada(aDataAM) CLASS GraficosQualidadeX //Antiga Function CalLim
	Local oDesvPad   := NB():New(aDataAM)
	Local aMedias    := oDesvPad:mediasNB(aDataAM)
	Local oQLGrafico := GraficosQualidadeX():New()
Return oQLGrafico:criaArrayLimites_nUcl_nMedia_nLcl(aMedias[2])

/*/{Protheus.doc} criaArrayLimites_nUcl_nMedia_nLcl
//De acordo com o array informado, retorna UCL,Media,LCL da Amplitude Movel
@author brunno.costa / rafael.kleestadt
@since 06/05/2022
@version 1.0
@return ${return}, ${return_description}
@param aDataAM, array, descricao
@type METHOD
/*/
METHOD criaArrayLimites_nUcl_nMedia_nLcl(nMedia) CLASS GraficosQualidadeX //Antiga Function CalcAM2
	
	Local nDesvPad := 0
	Local nLCL     := 0
	Local nUCL     := 0

	// Cálculo Desvio Padrão
	// Desvio Padrão = Média Amplitude / Constante D2
	nDesvPad := (nMedia / Self:retornaConstante({}, "d2", 5) ) //2.326

	// Cálculo Limite Superior   
	// Limite Superior = (Média Amplitude + (3 * Constante d3 * Desvio padrão))
	nUCL  := (nMedia) + (3 * nDesvPad * Self:retornaConstante({}, "d3", 5) ) //0.8641
	
	// Cálculo Limite Inferior   
	// Limite Inferior = (Média Amplitude - (3 * Constante d3 * Desvio padrão))
	nLCL  := (nMedia) - (3 * nDesvPad * Self:retornaConstante({}, "d3", 5) ) //0.8641
	
Return { nUCL, nMedia, nLCL }

/*/{Protheus.doc} criaArrayLimites_nUCL_nMedAmos_nLCL_aAmplMovel
//De acordo com o array informado, retorna UCL,Media,LCL dos Valores Individuais
@author brunno.costa / rafael.kleestadt
@since 06/05/2022
@version 1.0
@return ${return}, ${return_description}
@param aDataPar, array, descricao
@type METHOD
/*/
METHOD criaArrayLimites_nUCL_nMedAmos_nLCL_aAmplMovel(aDataPar, cTpCarEns, cTpCarEsc) CLASS GraficosQualidadeX //Antiga Function CalcVI
	
	Local aAmplMovel := {}
	Local aAuxMed    := {}
	Local nAmostras  := 0
	Local nAmpMed    := 0
	Local nI         := 0
	Local nLCL       := 0
	Local nMedMRK    := 0
	Local nSoma      := 0
	Local nUCL       := 0
    Local nMedAmos   := 0 //Média de Amostras

	Default cTpCarEns := ""
	Default cTpCarEsc := ""

	aAuxMed    := aClone(aDataPar)
	aAuxMed    := Self:converteArrayOuMatrizEmArrayNumerico(aAuxMed)

	//------------ Amplitude Móvel (Moving Range) ------------//
	aAmplMovel := Self:criaArrayAmplitudeMovelPorArray(aAuxMed, @nSoma)

	//Media Amostra
	nAmostras  := len(aAuxMed) //Numero de amostras
	nMedAmos   := nSoma / nAmostras
	
	nSoma := 0
    
	//TODO ESTRANHO
	//Amplitude Media
	For nI := 1 To (nAmostras-1)
   		nSoma += ABS(aAmplMovel[nI])
	Next
	
	nAmpMed := nSoma / (nAmostras-1)
	
	//Media MR/2
	If (cTpCarEns == "XBS" .And. Empty(cTpCarEsc))   .Or.;
	   (cTpCarEns == "XBR" .And. Empty(cTpCarEsc))   .Or.;
	   (cTpCarEns == "HIS" .And. cTpCarEsc == "XBR") .Or.;
	   (cTpCarEns == "XBR" .And. cTpCarEsc == "XBS") .Or.;
	   (cTpCarEns == "XBS" .And. cTpCarEsc == "XBR")

		nMedMR := nAmpMed / Self:retornaConstante(aAmplMovel, "1/d2", 3) //1/d2
	Else
		nMedMR := nAmpMed / Self:retornaConstante(aAmplMovel, "d2", 2)   //d2
	Endif

	IF ((Empty(cTpCarEns) .Or. Empty(cTpCarEsc))      .Or.;
		(cTpCarEns == "XBS" .And. cTpCarEsc == 'XBR') .Or.; //Média + Amplitude
		((cTpCarEns == "XBR" .Or. cTpCarEns == "XBS") .And. cTpCarEsc == "IND") .Or.; //Valores Individuais + Amplitude Móvel
		(cTpCarEns == "XBR" .And. cTpCarEsc == "XBS" ).Or.; //Média + Desvio Padrão
		(cTpCarEns == "HIS" .And. (cTpCarEsc == "XBR" .Or. cTpCarEsc == "IND"))) .And.;
		(IsInCallStack("QIPA215") .Or. IsInCallStack("QIPM020")) //TODO - Revisar tratamento de cartas no QIE
		nMedMRK := nMedMR * 3
	Else
		nMedMRK := nMedMR
	Endif

	nUCL := nMedAmos + nMedMRK 
	nLCL := nMedAmos - nMedMRK
	
Return {nUCL, nMedAmos, nLCL, aAmplMovel}

/*/{Protheus.doc} criaArrayLimites_nUCL_nAmpMed_nLCL
//De acordo com o array informado, retorna UCL,Media,LCL da Amplitude Movel
@author brunno.costa / rafael.kleestadt
@since 06/05/2022
@version 1.0
@return ${return}, ${return_description}
@param aDataAM, array, descricao
@type METHOD
/*/
METHOD criaArrayLimites_nUCL_nAmpMed_nLCL(aDataAM, nNum) CLASS GraficosQualidadeX
	
	Local nAmostras := 0
	Local nAmpMed   := 0
	Local nI        := 0
	Local nLCL      := 0
	Local nSoma     := 0
	Local nUCL      := 0

	Default nNum    := 0
		
	nAmostras := len(aDataAM)
	   
	//Amplitude Media
	For nI := 1 To nAmostras
   		nSoma += ABS(aDataAM[nI])
	Next
	
	nAmpMed := nSoma / nAmostras
    
	//Limite superior
	nUCL	 := Self:retornaConstante({}, "D4", 2) * nAmpMed //3.267
	
	//Limite inferior
	nLCL	 := Self:retornaConstante({}, "D3", 2) * nAmpMed //0.000
	
Return {nUCL,nAmpMed,nLCL}


/*/{Protheus.doc} criaArrayJsonXYPorArray
//Transforma o array XY em objeto json para oKendo:SetData
//Valores Indivisuais

QIEMJsVI ou QIEMJsAM
@author carlos.augusto
@since 20/05/2019

@author brunno.costa / rafael.kleestadt
@since 06/05/2022

@version 1.0
@return ${return}, ${return_description}
@param aDataPar, array, descricao
@type METHOD
/*/
METHOD criaArrayJsonXYPorArray(aDataPar) CLASS GraficosQualidadeX //Antiga Static Function QIEMJsVI ou QIEMJsAM
	
	Local aData as array
	Local nI    := 0
	Local nX    := 0
	Local oData as array

	aData := {}
	
	If Len(aDataPar) > 0 .AND. ValType(aDataPar[1]) <> "A"
		For nI := 1 To len(aDataPar)
			oData := JsonObject():New()
			oData['y1'] := aDataPar[nI]
			oData['x1'] := nI
			Aadd(aData, oData)
		Next nI
	Else
		For nX := 1 To len(aDataPar)
			For nI := 1 To len(aDataPar[nX])
				oData := JsonObject():New()
				oData['y1'] := aDataPar[nX][nI]
				oData['x1'] := nI
				Aadd(aData, oData)
			Next nI
		Next nX		
	EndIf
    
Return aData

/*/{Protheus.doc} criaArrayJsonXYDiagramaDePareto
//Transforma o array XY em objeto json para oKendo:SetData
//Valores Indivisuais
@author brunno.costa / rafael.kleestadt
@since 06/05/2022
@version 1.0
@return ${return}, ${return_description}
@param aDataPar, array, descricao
@type class
/*/
METHOD criaArrayJsonXYDiagramaDePareto(aParDP, nCasasDec) CLASS GraficosQualidadeX //Antiga Static Function QIEMJsDP
	
	Local aData      as array
	Local nI         := 0
	Local nSomaAtual := 0
	Local nSomaTot   := 0
	Local oData      as array

	aData := {}
	
	For nI := 1 To len(aParDP)
		IF EMPTY(nCasasDec)
			nSomaTot += SuperVal(aParDP[nI][1])
			aParDP[nI][1] := SuperVal(aParDP[nI][1])
		ELSE
			nSomaTot += NOROUND(SuperVal(aParDP[nI][1]), nCasasDec)
			aParDP[nI][1] := NOROUND(SuperVal(aParDP[nI][1]), nCasasDec)
		ENDIF
	Next nI
	
    For nI := 1 To len(aParDP)
        oData := JsonObject():New()
        oData['y1'] := aParDP[nI][1]
        oData['x1'] := aParDP[nI][2]
        nSomaAtual  += (aParDP[nI][1] / nSomaTot) * 100 
        oData['y2'] := nSomaAtual
        oData['x2'] := nI
        Aadd(aData, oData)
    Next nI
    
Return {aData, nSomaTot}

/*/{Protheus.doc} criaArrayJsonXYHistograma
//Transforma o array XY em objeto json para oKendo:SetData
//Valores Indivisuais
@author brunno.costa / rafael.kleestadt
@since 06/05/2022
@version 1.0
@return ${return}, ${return_description}
@param aDataPar, array, descricao
@type class
/*/
METHOD criaArrayJsonXYHistograma(aCol1, aCol2, nPrimeiro, nIncremento) CLASS GraficosQualidadeX 
	
	Local aJsData := {}
	Local nInd    := Nil
	Local oData   := JsonObject():New()

	oData['yDist'] := aCol1[1]
	oData['xDist'] := nPrimeiro
	oData['yFreq'] := aCol2[2]
	oData['xFreq'] := nPrimeiro
	Aadd(aJsData, oData)

	For nInd := 2 To Len(aCol2)
		If nInd <= Len(aCol1)
			oData := JsonObject():New()

			oData['yDist'] := aCol1[nInd]
			oData['xDist'] := (nPrimeiro + ((nInd) * nIncremento)) - nIncremento

			If nInd > 2
				oData['yFreq'] := aCol2[nInd]
			EndIf
			oData['xFreq'] := (nPrimeiro + ((nInd) * nIncremento)) - nIncremento		

			Aadd(aJsData, oData) 
		EndIf
	Next nInd

Return aJsData

/*/{Protheus.doc} criaArrayJsonXYHistograma
//Transforma o array XY em objeto json para oKendo:SetData
//Valores Indivisuais
@author brunno.costa / rafael.kleestadt
@since 06/05/2022
@version 1.0
@return ${return}, ${return_description}
@param aValores, array, vetor de valores para eixo X
@param aNormPad, array, vetor de valores para sino
@param aFrequen, array, vetor de valores para colunas
@type class
/*/
METHOD criaArrayJsonXYHistogramaMetrologia(aValores, aNormPad, aFrequen) CLASS GraficosQualidadeX
	
	Local aJsData := {}
	Local nInd    := Nil
	Local oData   := Nil

	FOR nInd := 1 TO LEN(aValores)

		oData := JsonObject():New()

		oData['yDist'] := aNormPad[nInd]
		oData['xDist'] := aValores[nInd]

		oData['yFreq'] := aFrequen[nInd]
		oData['xFreq'] := aValores[nInd]
		AADD(aJsData, oData)

	NEXT nInd

Return aJsData

/*/{Protheus.doc} criaArrayJsonXYIndexCoordenadas
Converte o array com as coordenadas no formato caractere em coordenadas json
@type  METHOD
@author rafael.kleestadt / lucas.briesemeister
@since 30/04/2020
@version 1.0
@param aDataPar, array, array com as coordenadas no formato {{cPontox, cPontoy}}
@return aData, array, array com as coordenadas no formato json {[x1:nPontox, y1:nPontoy]}
@example
(examples)
@see (links_or_references)
/*/
METHOD criaArrayJsonXYIndexCoordenadas(aDataPar) CLASS GraficosQualidadeX //Antiga Function fGetPontos
	
	Local aData      := {}
	Local aMedicao   := {} 
	Local aRet       := {}
	Local cIndex     := ""
	Local nMenorX    := 0
	Local nMenorY    := 0
	Local nPosPtVigr := 0
	Local nX         := 0
	Local nXValue    := 0
	Local nY         := 0
	Local nYValue    := 0
	Local oData      := {}

	FOR nX := 6 TO LEN(aDataPar)
		cIndex := cValToChar(nX - 5)
		FOR nY := 1 TO LEN(aDataPar[nX])
			IF VALTYPE(aDataPar[nX, nY]) = "C"

				nPosPtVigr := 0 
				nXValue    := 0 
				nYValue    := 0 

				nPosPtVigr := AT(";", aDataPar[nX,nY])
				nXValue    := SUPERVAL(ALLTRIM(SUBSTR(aDataPar[nX,nY], 1, AT(";", aDataPar[nX,nY]) - 1)))
				nYValue    := SUPERVAL(ALLTRIM(SUBSTR(aDataPar[nX,nY], nPosPtVigr + 1, LEN(aDataPar[nX,nY]))))

				//Guarda o menor ponto do eixo y
				IF nYValue < nMenorY .OR. nX == 1
					nMenorY := nYValue
				ENDIF

				//Guarda o menor ponto do eixo x
				IF nXValue < nMenorX .OR. nX == 4
					nMenorX := nXValue
				ENDIF

				oData := JsonObject():New()
				oData['x' + cIndex] := nXValue
				oData['y' + cIndex] := nYValue
				Aadd(aData, oData)
				Aadd(aMedicao,{nXValue,nYValue})	
				
			ENDIF
		NEXT nY
	NEXT nX

	aRet := {aData, nMenorY, nMenorX, aMedicao}

RETURN aRet

/*/{Protheus.doc} exibeBrowseMedicoes()
Cria browse das medições
@type  METHOD
@author rafael.kleestadt
@since 24/06/2020
@version 1.0
@param aMedicoes, array, matriz de medições
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
METHOD exibeBrowseMedicoes(aMedicoes) CLASS GraficosQualidadeX //Antiga Function QIEMEDICOE

	Local aSize       := FWGetDialogSize(oMainWnd) // Obtém a a área de trabalho e tamanho da dialog
	Local oDlgMed     := NIL

	Private oBrwMed   := NIL	
	Default aMedicoes := {{""}}

	oDlgMed := TDialog():New(0,0,(aSize[3] / 2),(aSize[4] / 3),STR0007,,,,,CLR_BLACK,CLR_WHITE,,,.T.) //"Amostras"
	oBrwMed := FWBrowse():New(oDlgMed)
	oBrwMed:SetDataArray()
	oBrwMed:SetDescription(STR0007) //"Amostras"
    oBrwMed:DisableFilter()
    oBrwMed:DisableConfig()
	oBrwMed:SetArray( aMedicoes ) // Define Fwbrowse para receber um Array.
	
    Self:criaColunaMedicoesDinamicamente(aMedicoes) //Adiciona as colunas no Browse
    oBrwMed:Activate()
 	oBrwMed:Enable()
    oBrwMed:Refresh(.T.)
	oDlgMed:Activate()
	
Return NIL

/*/{Protheus.doc} MBColumn
Cria as colunas de medições dinamicamente
@type  METHOD
@author rafael.kleestadt
@since 24/06/2020
@version 1.0
@param aCols, array, matriz de medições
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/

METHOD criaColunaMedicoesDinamicamente(aCols) CLASS GraficosQualidadeX //Antiga Static Function MBColumn
	Local nX := 0

	For nX := 1 To Len(aCols[1])
		oColumn := FWBrwColumn():New()
		oColumn:SetData( &(" { || aCols[oBrwMed:At(),"+STransType(nX)+"]}") )
		If IsInCallStack("QPPA170")
			oColumn:SetTitle(CVALTOCHAR(nX))
		Else
			oColumn:SetTitle(STR0008 + " " + CVALTOCHAR(nX)) //"Amostra"
		Endif	
		oColumn:SetSize(TamSx3("QPS_MEDICA")[1]) 
		oColumn:SetDecimal(TamSx3("QPS_MEDICA")[2]) 
		oBrwMed:SetColumns({oColumn})
	Next nX 

Return NIL

/*/{Protheus.doc} criaArrayBaseEmInicioIncrementoEQtdPontos
Gera um vetor de dados com base no menor ponto qtd de pontos e incremnto
@type  METHOD
@author rafael.kleestadt
@since 08/07/2020
@version 1.0
@param nMedMenor, numerico, media das medições menos quatro vezes o desvio padrão das medições
@param nIncrement, numerico, media das medições mais quatro vezes o desvio padrão das medições menos a media menor dividida pela quantidade de pontos menos 1
@param nQtdPontos, numerico, qtd de pontos que se deja para gerar o sino
@return aValores, array, vetor de pontos distribuidos entre a media menor e maior
/*/
METHOD criaArrayBaseEmInicioIncrementoEQtdPontos(nMedMenor, nIncrement, nQtdPontos) CLASS GraficosQualidadeX //Antiga Static Function getValores
	
	Local aValores := ARRAY(nQtdPontos)
	Local nX       := 0

	For nX := 1 To nQtdPontos

		If nX == 1
			aValores[nX] := nMedMenor
		Else
			aValores[nX] := aValores[nX - 1] + nIncrement
		EndIf

	Next nX

Return aValores

/*/{Protheus.doc} getNorPad
Retorna um array com os valores da distribuição normal de cada ponto(aPontos)
@type  METHOD
@author rafael.kleestadt / marcos.wagner
@since 06/07/2020
@version 1.1
@param aPontos, array, pontos calculados com base no desvio padrão das medições
@param nDesvPad, number, desvio padrão das medições
@param nMedia, number, média das medições
@return aFPM, array, array com os valores da distribuição normal de cada ponto(aPontos)
@example
(examples)
@see https://pt.wikipedia.org/wiki/Distribui%C3%A7%C3%A3o_normal
/*/
METHOD criaArrayDistribuicaoNormalPadrao(aPontos, nDesvPad, nMedia, oDesvPad) CLASS GraficosQualidadeX //Antiga Function getNorPad
	
	Local aFPM       := {}
	Local aPadroes   := {}
	Local nEuler     := 2.718281828459045235360287 //Constante de Euler
	Local nI         := 0
	Local nPi        := 3.141592653589793238462643 //Número pi
	Local p          := {}
	Local q          := {}
	Local x_t        := {}

	Default nDesvPad := oDesvPad:getDesvPad(aPontos)
	Default nMedia   := oDesvPad:mediasNB(aPontos)[2]

	For nI := 1 to Len(aPontos)
		AADD(x_t, aPontos[nI])
	Next

	xt := aClone(x_t)

	p        := Array(Len(xt)) // density probability of normal distriobution
	aPadroes := Array(Len(xt)) // temporary data
	q        := Array(Len(xt)) // temporary data

	For nI := 1 to Len(x_t)
		aPadroes[nI] := (xt[nI] - nMedia) / nDesvPad //Padronização (Z)
		q[nI]        := -0.5 * (aPadroes[nI] ^ 2.0) // -Z ao quadrado / 2
		p[nI]        := ((1.0) / ((nDesvPad * ( (2.0 * nPi) ^ (0.5)))) * (nEuler ^ q[nI]))
		AADD(aFPM,p[nI])
	Next

Return aFPM

/*/{Protheus.doc} QIEMIMGGRAF()
Gera a imagem png recebida do JS e copia para a pasta temp com o nome recebido da função
@type  Function
@author rafael.kleestadt
@since 17/07/2020
@version 1.0
@param self, object, objeto twebengine
@param cCodeContent, caracter, imagen png do grafico no formato base64
@param cPathPng, caracter, locl temporario da imagen o grafico
@return return_var, return_type, return_description
@example
(examples)
@see https://pt.wikipedia.org/wiki/Base64
/*/
Function QIEMIMGGRAF(oKendoChart, cCodeContent, cPathPng)
	Local oQLGrafico := GraficosQualidadeX():New()
	oQLGrafico:criaImagemBase64EmDiretorioFisico(oKendoChart, cCodeContent, cPathPng)
Return Nil

METHOD criaImagemBase64EmDiretorioFisico(oKendoChart, cCodeContent, cPathPng) CLASS GraficosQualidadeX //Antiga Function QIEMIMGGRAF
	
	Local cPngRet    := ""
	Local cPngRetAdi := ""
	Local cTempDir   := IIF(GetRemoteType() == 5, GetTempPath(.T., .T.), GetTempPath(.T., .F.))

	Default cNamePng := oKendoChart:aOptions[1]["chartId"] + ".png"

	cPngRet    := cTempDir + SUBSTR(cNamePng, 1, AT(".", cNamePng)) + SUBSTR(cNamePng, AT(".", cNamePng) + 1, LEN(cNamePng))
	nPosPtVigr := AT(",", cCodeContent)
	cData      := SUBSTR(cCodeContent, nPosPtVigr + 1, LEN(cCodeContent))

	nHandle := fcreate(cPngRet)
	FWrite(nHandle, Decode64(cData))
	fclose(nHandle)

	IF (GetRemoteType() == 5)
		DO CASE
			CASE FWIsInCallStack("QIER120")
				cPngRetAdi  := cTempDir + "QIER120_" + SUBSTR(cNamePng, 1, AT(".", cNamePng)) + "png"
			CASE FWIsInCallStack("QIER130")
				cPngRetAdi  := cTempDir + "QIER130_" + SUBSTR(cNamePng, 1, AT(".", cNamePng)) + "png"
			CASE FWIsInCallStack("QIER300")
				cPngRetAdi  := cTempDir + "QIER300_" + SUBSTR(cNamePng, 1, AT(".", cNamePng)) + "png"
			CASE FWIsInCallStack("QMTR190")
				cPngRetAdi  := cTempDir + "QMTR190_" + SUBSTR(cNamePng, 1, AT(".", cNamePng)) + "bmp"
		ENDCASE

		nHandle := fcreate(IIF(EMPTY(cPngRetAdi), cPngRet, cPngRetAdi))
		FWrite(nHandle, Decode64(cData))
		fclose(nHandle)
	ENDIF

	//Fecha a dialog após 1 segundo
	oTimer := TTimer():New(1000, {|| oKendoChart:OWEBENGINE:OWND:End() }, oKendoChart:OWEBENGINE:OWND )
	oTimer:Activate()
	
Return NIL

/*/{Protheus.doc} retornaCorAleatoria
Retorna uma cor aleatória gerada com base numa paleta de 190 cores nomeadas que variam de "Alizarina" até " Índigo" passando por " Verde Paris" e " Rosa brilhante".
@type  Class
@author rafael.kleestadt
@since 22/07/2020
@version 1.0
@param param_name, param_type, param_descr
@return cCor, caracter, cor hexadecimal aleatória
@example
(examples)
@see https://encycolorpedia.pt/named
/*/
METHOD retornaCorAleatoria() CLASS GraficosQualidadeX //Antiga Function fRetCorAle

	LOCAL cCor   := "" 
	LOCAL aCores := {"#e32636",;//Alizarina
					 "#ffff00",;//Amarelo
					 "#ffffe0",;//Amarelo claro
					 "#adff2f",;//Amarelo esverdeado
					 "#fafad2",;//Amarelo ouro claro
					 "#eead2d",;//Amarelo queimado
					 "#dda0dd",;//Ameixa
					 "#9966cc",;//Ametista
					 "#ffebcd",;//Amêndoa
					 "#7ba05b",;//Aspargo
					 "#0000ff",;//Azul
					 "#f0f8ff",;//Azul alice
					 "#6a5acd",;//Azul ardósia
					 "#8470ff",;//Azul ardósia claro
					 "#483d8b",;//Azul ardósia escuro
					 "#7b68ee",;//Azul ardósia médio
					 "#b8cad4",;//Azul areado
					 "#4682b4",;//Azul aço
					 "#b0c4de",;//Azul aço claro
					 "#5f9ea0",;//Azul cadete
					 "#054f77",;//Azul camarada
					 "#f0ffff",;//Azul celeste
					 "#007fff",;//Azul celeste brilhante
					 "#add8e6",;//Azul claro
					 "#0047ab",;//Azul cobalto
					 "#87ceeb",;//Azul céu
					 "#87cefa",;//Azul céu claro
					 "#00bfff",;//Azul céu profundo
					 "#00008b",;//Azul escuro
					 "#6495ed",;//Azul flor de milho
					 "#5d8aa8",;//Azul força aérea
					 "#1e90ff",;//Azul furtivo
					 "#a6aa3e",;//Azul manteiga
					 "#120a8f",;//Azul marinho
					 "#191970",;//Azul meia-noite
					 "#0000cd",;//Azul médio
					 "#084d6e",;//Azul petróleo
					 "#b0e0e6",;//Azul pólvora
					 "#4169e1",;//Azul real
					 "#248eff",;//Azul taparuere
					 "#8a2be2",;//Azul violeta
					 "#f4c430",;//Açafrão
					 "#f5f5dc",;//Bege
					 "#800000",;//Bordô
					 "#900020",;//Borgonha
					 "#ffffff",;//Branco
					 "#faebd7",;//Branco antigo
					 "#f8f8ff",;//Branco fantasma
					 "#fffaf0",;//Branco floral
					 "#f5f5f5",;//Branco fumaça
					 "#ffdead",;//Branco navajo
					 "#cd7f32",;//Bronze
					 "#f0e68c",;//Caqui
					 "#bdb76b",;//Caqui escuro
					 "#8b5742",;//Caramelo
					 "#d8bfd8",;//Cardo
					 "#dc143c",;//Carmesim
					 "#712f26",;//Carmim
					 "#f5fffb",;//Carmim carnáceo
					 "#8b0000",;//Castanho avermelhado / Vermelho escuro
					 "#d2b48c",;//Castanho claro
					 "#ed9121",;//Cenoura
					 "#de3163",;//Cereja
					 "#f400a1",;//Cereja Hollywood
					 "#d2691e",;//Chocolate
					 "#e0ffff",;//Ciano claro
					 "#008b8b",;//Ciano escuro
					 "#808080",;//Cinza
					 "#708090",;//Cinza ardósia
					 "#778899",;//Cinza ardósia claro / Dainise
					 "#2f4f4f",;//Cinza ardósia escuro
					 "#d3d3d3",;//Cinza claro
					 "#a9a9a9",;//Cinza escuro
					 "#696969",;//Cinza fosco
					 "#dcdcdc",;//Cinza médio
					 "#b87333",;//Cobre
					 "#fff5ee",;//Concha
					 "#ff7f50",;//Coral
					 "#f08080",;//Coral claro
					 "#f0dc82",;//Couro
					 "#fffdd0",;//Creme
					 "#ffe4c4",;//Creme de marisco
					 "#f5fffa",;//Creme de menta
					 "#daa520",;//Dourado
					 "#b8860b",;//Dourado escuro
					 "#eee8aa",;//Dourado pálido
					 "#ff2400",;//Escarlate
					 "#50c878",;//Esmeralda
					 "#d19275",;//Feldspato
					 "#b7410e",;//Ferrugem
					 "#3d2b1f",;//Fuligem
					 "#ff00ff",;//Fúchsia / Magenta
					 "#831d1c",;//Grená
					 "#2e8b57",;//Herbal
					 "#000000",;//Jabuti preto / Preto
					 "#00a86b",;//Jade
					 "#ff4500",;//Jambo
					 "#ffa500",;//Laranja
					 "#ff8c00",;//Laranja escuro
					 "#e6e6fa",;//Lavanda
					 "#fff0f5",;//Lavanda avermelhada
					 "#c8a2c8",;//Lilás
					 "#fde910",;//Lima
					 "#00ff00",;//Limão (cor) / Verde espectro
					 "#faf0e6",;//Linho
					 "#deb887",;//Madeira
					 "#8b008b",;//Magenta escuro
					 "#e0b0ff",;//Malva
					 "#ffefd5",;//Mamão batido
					 "#f0fff0",;//Maná
					 "#fffff0",;//Marfim
					 "#964b00",;//Marrom
					 "#f4a460",;//Marrom amarelado
					 "#a52a2a",;//Marrom claro
					 "#bc8f8f",;//Marrom rosado
					 "#8b4513",;//Marrom sela
					 "#fbec5d",;//Milho
					 "#fff8dc",;//Milho Claro
					 "#ffe4b5",;//Mocassim
					 "#ffdb58",;//Mostarda
					 "#000080",;//Naval
					 "#fffafa",;//Neve
					 "#cc7722",;//Ocre
					 "#808000",;//Oliva
					 "#556b2f",;//Oliva escura
					 "#6b8e23",;//Oliva parda
					 "#da70d6",;//Orquídea
					 "#9932cc",;//Orquídea escura
					 "#ba55d3",;//Orquídea média
					 "#ffd700",;//Ouro
					 "#cd853f",;//Pele
					 "#c0c0c0",;//Prata
					 "#ffdab9",;//Pêssego
					 "#800080",;//Púrpura
					 "#9370db",;//Púrpura média
					 "#111111",;//Quantum
					 "#fdf5e6",;//Renda antiga
					 "#ffcbdb",;//Rosa
					 "#ff007f",;//Rosa brilhante
					 "#fc0fc0",;//Rosa chocante
					 "#ffb6c1",;//Rosa claro
					 "#ffe4e1",;//Rosa embaçado
					 "#ff69b4",;//Rosa forte
					 "#ff1493",;//Rosa profundo
					 "#993399",;//Roxo
					 "#6d351a",;//Rútilo
					 "#fa7f72",;//Salmão
					 "#ffa07a",;//Salmão claro
					 "#e9967a",;//Salmão escuro
					 "#ff8247",;//Siena
					 "#705714",;//Sépia
					 "#e2725b",;//Terracota
					 "#b22222",;//Tijolo refratário
					 "#ff6347",;//Tomate
					 "#f5deb3",;//Trigo
					 "#ff2401",;//Triássico
					 "#40e0d0",;//Turquesa
					 "#00ced1",;//Turquesa escura
					 "#48d1cc",;//Turquesa média
					 "#afeeee",;//Turquesa pálida
					 "#ec2300",;//Urucum
					 "#008000",;//Verde
					 "#9acd32",;//Verde amarelado
					 "#90ee90",;//Verde claro
					 "#006400",;//Verde escuro
					 "#228b22",;//Verde floresta
					 "#ccff33",;//Verde fluorescente
					 "#7cfc00",;//Verde grama
					 "#32cd32",;//Verde lima
					 "#20b2aa",;//Verde mar claro
					 "#8fbc8f",;//Verde mar escuro
					 "#3cb371",;//Verde mar médio
					 "#78866b",;//Verde militar
					 "#7fff00",;//Verde Paris
					 "#00ff7f",;//Verde primavera
					 "#00fa9a",;//Verde primavera médio
					 "#98fb98",;//Verde pálido
					 "#008080",;//Verde-azulado
					 "#ff0000",;//Vermelho
					 "#cd5c5c",;//Vermelho indiano
					 "#d02090",;//Vermelho violeta
					 "#c71585",;//Vermelho violeta médio
					 "#db7093",;//Vermelho violeta pálido
					 "#ee82ee",;//Violeta
					 "#9400d3",;//Violeta escuro
					 "#00ffff",;//Água / Ciano
					 "#7fffd4",;//Água-marinha
					 "#66cdaa",;//Água-marinha média
					 "#ffbf00",;//Âmbar
					 "#4b0082"} //Índigo

	cCor := aCores[Randomize( 1, LEN(aCores) )]
	
Return cCor

/*/{Protheus.doc} calculaExibeExportaEstatisticasCartaIndividual
Função especifica para Calcula, exibe e exporta os dados estatisticos do gráfico QMT
@type  Class
@author thiago.rover
@since 24/08/2020
@version 1.0
@param aMedicoes, array, array com as medições
@param aLimites, array, "[TARGET]", "[LSL]", "[USL]"
@param nMediaEst, numérico, media estatistica
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
METHOD calculaExibeExportaEstatisticasCartaIndividual(aMedicoes, aAmplit, aLimites, nMediaEst) CLASS GraficosQualidadeX //Antiga Function QMTESTATI

	LOCAL oDesvPad    := NB():New(aAmplit)
	LOCAL aMedias     := oDesvPad:mediasNB(aAmplit)
	LOCAL nDesvPad    := Round(oDesvPad:getDesvPad(aMedicoes), 10)
	LOCAL nEstSigma   := Round((aMedias[2] / Self:retornaConstante({}, "d2", 5)), 10)            //Est. Sigma = (Process Mean / constant for calculating the control limit)
	LOCAL nCp         := TRANSFORM(Round((aLimites[3] - aLimites[2]) / (6 * nEstSigma),10),"@E 9999.9999999999")                  //Cp = (USL – LSL) / (6*  Estig. Deviation)
	LOCAL nCpk        := Self:calculaCPK(nMediaEst, aLimites, nEstSigma)                    	                                          //Cpk = Min (Cpl, Cpu)
	LOCAL nCg         := TRANSFORM(Round((2 * (aLimites[3] - aLimites[2])) / (6 * nDesvPad),10),"@E 9999.9999999999")             //Cg = (2* (USL – LSL)) / (6* Standard Deviation)
	LOCAL nCgk        := TRANSFORM(Round(((aLimites[3] - nMediaEst) / (3 * nDesvPad)),10),"@E 9999.9999999999")                   //Cgk = (USL - Process Mean) / (3* Standard Deviation)
	LOCAL nPp         := TRANSFORM(Round((aLimites[3] - aLimites[2]) / (6 * nDesvPad),10),"@E 9999.9999999999")                   //Pp = (USL – LSL) / (6* Standard Deviation)
	LOCAL nPpk        := Self:calculaPPK(nMediaEst, aLimites, nDesvPad)                                                           //Ppk = min( (Process Mean - LSL) / (3* Standard Deviation), (USL - Process Mean) / (3* Standard Deviation))
	LOCAL nCr         := TRANSFORM(Round((1 / SUPERVAL((aLimites[3] - aLimites[2]) / (6 * nEstSigma))),10),"@E 9999.9999999999")  //Cr = 1/ Cp =  (6*  Estig. Deviation)   /  (USL – LSL)
	LOCAL nPr         := TRANSFORM(Round((1 / SUPERVAL((aLimites[3] - aLimites[2]) / (6 * nDesvPad))),10),"@E 9999.9999999999")   //Pr = 1/ Cp =  (6*  Standard Deviation) /  (USL – LSL)
	LOCAL nCpl		  := TRANSFORM(Round(((aMedias[2] - aLimites[2]) / (3 * nDesvPad)),10),"@E 9999.9999999999")                  //Cpl = (Process Mean – LSL)/(3*Standard Deviation)
	LOCAL nCpu        := TRANSFORM(Round(((aLimites[3] - nMediaEst)  / (3 * nDesvPad)),10),"@E 9999.9999999999")                  //Cpu = (USL – Process Mean)/(3*Standard Deviation)
	LOCAL nSigma      := TRANSFORM(Round(nDesvPad,10),"@E 9999.9999999999")                                                       //Sigma = Standard Deviation 
	LOCAL cEstSigma   := TRANSFORM(Round(nEstSigma,10) ,"@E 9999.9999999999")   				                     			  //Cp = (USL – LSL) / (6*  Standard Deviation)
	LOCAL nMean       := TRANSFORM(Round(nMediaEst,10),"@E 9999.9999999999")                                                      //Mean = Process Mean
	LOCAL nKurtosis   := TRANSFORM(Round(0,10),"@E 9999.9999999999")
	LOCAL nN          := TRANSFORM(Round(LEN(aMedicoes),10),"@E 9999.9999999999")                                                 //N = Number of samples
	LOCAL nSkew       := TRANSFORM(Round(0,10),"@E 9999.9999999999")
	LOCAL aCabExcel   := {"Cp", "Cg", "Pp", "Cr", "Cpl", "Cpu", "Sigma", "Mean", "N", "Cpk", "Cgk", "Ppk", "Pr", "Est. Sigma", "Kurtosis", "Skew"}
	LOCAL aItensExcel := {nCp, nCg, nPp, nCr,nCpl, nCpu, nSigma, nMean, nN, nCpk, nCgk, nPpk, nPr, cEstSigma, nKurtosis, nSkew }

	Self:exibeTelaEstatisticas(aItensExcel, aCabExcel, nCp, nCg, nPp, nCr,nCpl, nCpu, nSigma, nMean, nN, nCpk, nCgk, nPpk, nPr, cEstSigma )

Return NIL

/*/{Protheus.doc} calculaExibeExportaEstatisticasPPAP
Calcula, exibe e exporta os dados estatisticos do grafico PPAP
@type METHOD
@author thiago.rover
@since 17/02/2021
@version 1.0
@param aMedicoes, array, array com as medições
@param aMedAux, array, array com as medições em formato numérico
@param aLimites, array, "[TARGET]", "[LSL]", "[USL]"
@param nTamAmostr, numérico, tamanho da amostra
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
METHOD calculaExibeExportaEstatisticasPPAP(aMedicoes, aMedAux, aLimites, nTamAmostr) CLASS GraficosQualidadeX //Antiga Function QPPAPMESTATI
	
	LOCAL oDesvPad    := NB():New(aMedicoes)
	LOCAL aMedias     := oDesvPad:mediasNB(aMedicoes)
	LOCAL nDesvPad    := Round(oDesvPad:getDesvPad(aMedicoes),10)
	LOCAL nMedAmpl    := Self:calculaMediaDoArray(Self:criaArrayAmplitudesPorArrayOuMatriz(aMedAux)) //Amplitude - R ou R Medio
	LOCAL nEstSigma   := Round((nMedAmpl / Self:retornaConstante(aMedicoes, "d2", nTamAmostr)),10)          							    //Est. Sigma = (Process Mean / constant for calculating the control limit)
	LOCAL nCp         := TRANSFORM(Round( (aLimites[3] - aLimites[2]) / (6 * nEstSigma), 10 ),"@E 9999.9999999999")      //Cp = (USL – LSL) / (6*  Standard Deviation)
	LOCAL nCpk        := Self:calculaCPK(aMedias[2], aLimites, nEstSigma)                                                          //Cpk = Min (Cpl, Cpu)
	LOCAL nCg         := TRANSFORM(Round((2 * (aLimites[3] - aLimites[2])) / (6 * nDesvPad), 10 ),"@E 9999.9999999999") //Cg = (2* (USL – LSL)) / (6* Standard Deviation)
	LOCAL nCgk        := TRANSFORM(Round(((aLimites[3] - aMedias[2]) / (3 * nDesvPad)), 10 ),"@E 9999.9999999999")      //Cgk = (USL - Process Mean) / (3* Standard Deviation)
	LOCAL nPp         := TRANSFORM(Round((aLimites[3] - aLimites[2]) / (6 * nDesvPad), 10 ),"@E 9999.9999999999")       //Pp = (USL – LSL) / (6* Standard Deviation)
	LOCAL nPpk        := Self:calculaPPK(aMedias[2], aLimites, nDesvPad)                                                          //Ppk = min( (Process Mean - LSL) / (3* Standard Deviation), (USL - Process Mean) / (3* Standard Deviation))
	LOCAL nCr         := TRANSFORM(Round((1 / SUPERVAL(nCp)),10),"@E 9999.9999999999")                                  //Cr = 1/ Cp =  (6*  Standard Deviation) /  (USL – LSL)
	LOCAL nPr         := TRANSFORM(Round((1 / SUPERVAL(nPp)),10),"@E 9999.9999999999")                                  //Pr = 1/ Cp =  (6*  Standard Deviation) /  (USL – LSL)
	LOCAL nCpl		  := TRANSFORM(Round(((aMedias[2] - aLimites[2]) / (3 * nDesvPad)),10),"@E 9999.9999999999")        //Cpl = (Process Mean – LSL)/(3*Standard Deviation)
	LOCAL nCpu        := TRANSFORM(Round(SUPERVAL(Self:calculaCPU(aLimites, aMedias)),10),"@E 9999.9999999999")        //Cpu = (USL – Process Mean)/(3*Standard Deviation)
	LOCAL nSigma      := TRANSFORM(Round(nDesvPad,10),"@E 9999.9999999999")                                             //Sigma = Standard Deviation 
	LOCAL cEstSigma   := TRANSFORM(Round(nEstSigma,10) ,"@E 9999.9999999999")   				                     	//Cp = (USL – LSL) / (6*  Media Amplitude)
	LOCAL nMean       := TRANSFORM(Round(aMedias[2], 10 ),"@E 9999.9999999999")                                         //Mean = Process Mean
	LOCAL nKurtosis   := TRANSFORM(0,"@E 9999.9999999999")
	LOCAL nN          := TRANSFORM(Round(LEN(aMedicoes), 10 ),"@E 9999.9999999999")                                     //N = Number of samples
	LOCAL nSkew       := TRANSFORM(0,"@E 9999.9999999999")
	LOCAL aCabExcel   := {"Cp", "Cg", "Pp", "Cr", "Cpl", "Cpu", "Sigma", "Mean", "N", "Cpk", "Cgk", "Ppk", "Pr", "Est. Sigma", "Kurtosis", "Skew"}
	LOCAL aItensExcel := {nCp, nCg, nPp, nCr,nCpl, nCpu, nSigma, nMean, nN, nCpk, nCgk, nPpk, nPr, cEstSigma, nKurtosis, nSkew }

	Self:exibeTelaEstatisticas(aItensExcel, aCabExcel, nCp, nCg, nPp, nCr,nCpl, nCpu, nSigma, nMean, nN, nCpk, nCgk, nPpk, nPr, cEstSigma )

Return NIL

/*/{Protheus.doc} calculaExibeExportaEstatisticasCartasDeControleOuHistograma
Calcula, exibe e exporta os dados estatisticos do grafico
@type  Class
@author rafael.kleestadt
@since 23/07/2020
@version 1.0
@param aMedicoes, array, array com as medições
@param aMedAux, array, array com as medições em formato numérico
@param aLimites, array, "[TARGET]", "[LSL]", "[USL]"
@param cTpCarEsc, caractere, Carta escolhida - "XBR", "XBS", "IND" ou "HIS"
@param cTpCarEns, caractere, Carta do ensaio - "XBR", "XBS", "IND" ou "HIS"
@param nTamAmostr, numérico, tamanho da amostra
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
METHOD calculaExibeExportaEstatisticasCartasDeControleOuHistograma(aMedicoes, aMedAux, aLimites, cTpCarEsc, cTpCarEns, nTamAmostr) CLASS GraficosQualidadeX //Antiga Function QIEMESTATI

	Local oDesvPad    := NB():New(aMedicoes)
	Local aMedias     := oDesvPad:mediasNB(aMedicoes)
	Local nDesvPad    := Round(oDesvPad:getDesvPad(aMedicoes),10)
	Local nDesvPadC   := 0
 	Local aAmp        := Self:criaArrayAmplitudesPorArrayOuMatriz(aMedAux)
	Local nMedAmpl    := Self:calculaMediaDoArray(aAmp)
	Local nCp         := 0 //Cp = (USL – LSL) / (6* Est. Standard Deviation)
	Local nCpk        := 0 //Cpk = Min (Cpl, Cpu)
	Local nCg         := TRANSFORM(Round((2 * (aLimites[3] - aLimites[2])) / (6 * nDesvPad), 10 ),"@E 9999.9999999999") //Cg = (2* (USL – LSL)) / (6* Standard Deviation)
	Local nCgk        := TRANSFORM(Round(((aLimites[3] - aMedias[2]) / (3 * nDesvPad)), 10 ),"@E 9999.9999999999")      //Cgk = (USL - Process Mean) / (3* Standard Deviation)
	Local nPp         := TRANSFORM(Round((aLimites[3] - aLimites[2]) / (6 * nDesvPad), 10 ),"@E 9999.9999999999")       //Pp = (USL – LSL) / (6* Standard Deviation)
	Local nPpk        := Self:calculaPPK(aMedias[2], aLimites, nDesvPad)                                                         //Ppk = min( (Process Mean - LSL) / (3* Standard Deviation), (USL - Process Mean) / (3* Standard Deviation))
	Local nCr         := 0 //Cr = 1/ Cp =  (6*  Est. Standard Deviation) /  (USL – LSL)
	Local nPr         := TRANSFORM(Round((1 / SUPERVAL(nPp)),10),"@E 9999.9999999999")                                  //Pr = 1/ Cp =  (6*  Standard Deviation) /  (USL – LSL)
	Local nCpl		  := TRANSFORM(Round(((aMedias[2] - aLimites[2]) / (3 * nDesvPad)),10),"@E 9999.9999999999")        //Cpl = (Process Mean – LSL)/(3*Standard Deviation)
	Local nSigma      := TRANSFORM(Round(nDesvPad,10),"@E 9999.9999999999")                                             //Sigma = Standard Deviation 
	Local nMean       := TRANSFORM(Round(aMedias[2], 10 ),"@E 9999.9999999999")                                         //Mean = Process Mean
	Local nKurtosis   := TRANSFORM(0,"@E 9999.9999999999")
	Local nN          := TRANSFORM(Round(LEN(aMedicoes), 10 ),"@E 9999.9999999999")                                     //N = Number of samples
	Local nSkew       := TRANSFORM(0,"@E 9999.9999999999")
	Local aCabExcel   := {"Cp", "Cg", "Pp", "Cr", "Cpl", "Cpu", "Sigma", "Mean", "N", "Cpk", "Cgk", "Ppk", "Pr", "Est. Sigma", "Kurtosis", "Skew"}
	Local nCpu		  := 0
	Local nEstSigma   := NIL																						           //Est. Sigma = (Process Mean / constant for calculating the control limit)
	Local aItensExcel := {}

	DEFAULT cTpCarEns   := ""
	DEFAULT cTpCarEsc   := ""
	DEFAULT nTamAmostr  := NIL

	If IsInCallStack("QIPA215") .Or. IsInCallStack("QIPM020")
		nEstSigma := Self:calculaEstSigma(aMedicoes, nDesvPad, aMedias, cTpCarEsc, cTpCarEns, nTamAmostr, nMedAmpl)
		nCpu  := Self:calculaCPU(aLimites, aMedias)
	Else
		nCpu      := TRANSFORM(Round(((aLimites[3] - aMedias[2]) / (3 * nDesvPad)),10),"@E 9999.9999999999")          //Cpu = (USL – Process Mean)/(3*Standard Deviation)
		nEstSigma := TRANSFORM(Round((aMedias[2] / Self:retornaConstante(aMedicoes, "d2", nTamAmostr)),10),"@E 9999.9999999999") //Est. Sigma = (Process Mean / constant for calculating the control limit)
	Endif

	If (cTpCarEsc $ 'XBR | XBS' .Or. (Empty(cTpCarEsc) .And. cTpCarEns $ 'XBR | XBS')) .Or.;
	    !(IsInCallStack("QIPA215") .Or. IsInCallStack("QIPM020"))
		nDesvPadC := IIF(EMPTY(SUPERVAL(nEstSigma)), nDesvPad, SUPERVAL(nEstSigma))
	Else
		nDesvPadC := nDesvPad //Somente SIGAQIP cartas ensaios ou escolhidas IND ou HIS
	EndIf

	nCp  := TRANSFORM(Round( (aLimites[3] - aLimites[2]) / (6 * nDesvPadC), 10 ),"@E 9999.9999999999") //Cp = (USL – LSL) / (6*  Est. Standard Deviation)
	nCpk := Self:calculaCPK(aMedias[2], aLimites, nDesvPadC)                                                       //Cpk = Min (Cpl, Cpu)
	nCr  := TRANSFORM(Round((1 / SUPERVAL(nCp)),10),"@E 9999.9999999999")                                //Cr = 1/ Cp =  (6*  Est. Standard Deviation) /  (USL – LSL)

	aItensExcel := {nCp, nCg, nPp, nCr,nCpl, nCpu, nSigma, nMean, nN, nCpk, nCgk, nPpk, nPr, nEstSigma, nKurtosis, nSkew }

	Self:exibeTelaEstatisticas(aItensExcel, aCabExcel, nCp, nCg, nPp, nCr,nCpl, nCpu, nSigma, nMean, nN, nCpk, nCgk, nPpk, nPr, nEstSigma )

Return NIL

/*/{Protheus.doc} criaArrayAmplitudesPorArrayOuMatriz
Funcao genérica para calcular as amplitudes das medições
@type  Class
@author thiago.rover
@since 17/02/2021
@version 1.0
@param aMedicao, array, array ou matriz de medições
@return aAmpl, array, array contendo a aplitude de cada amostra
@example
(examples)
@see (links_or_references)
/*/
METHOD criaArrayAmplitudesPorArrayOuMatriz(aMedicao) CLASS GraficosQualidadeX //Antiga Static Function fCalcAmpl
	
	Local aAmpl      := {}
	Local aMedCopy   := aClone(aMedicao)
	Local aPontosMed := {}
	Local nMaior     := 0
	Local nMenor     := 0
	Local nX         := 0
	Local nY         := 0

	//{1,2,3,4,5,6}
	If ValType(aMedCopy[1]) <> "A"
		
		For nX:=1 To Len(aMedCopy)
			ASORT(aMedCopy,,, { |x, y| x > y } )
			nMaior  := aMedCopy[nX]	                // Maior Medição
			nMenor  := aMedCopy[LEN(aMedCopy)]		// Menor Medição
			aADD(aAmpl, nMaior - nMenor)            // Amplitude
			Exit
		Next nX	

	//{{1,2,3,4}, {1,2,3,4}}
	//{{1}      , {2}}
	Else

		//{{1,2,3,4}, {1,2,3,4}}
		If Len(aMedCopy[1]) > 1
			For nX:=1 To Len(aMedCopy)
				For nY:= 1 To Len(aMedCopy[nX])
					ASORT(aMedCopy[nX],,, { |x, y| x > y } )
					nMaior  := SuperVal(aMedCopy[nX][1])                  // Maior Medição
					nMenor  := SuperVal(aMedCopy[nX][LEN(aMedCopy[nX])])  // Menor Medição
					aADD(aAmpl, nMaior - nMenor)                          // Amplitude
					Exit
				Next nY
			Next nX
		
		//{{1}, {2}}
		Else
			Aeval(aMedCopy, {|x| AADD(aPontosMed, x[1])})
			//Converte {{1}, {2}} em {1, 2}

			//Recursividade após tratamento do array
			aAmpl := Self:criaArrayAmplitudesPorArrayOuMatriz(aPontosMed)
		Endif
	Endif

	FWFreeArray(aMedCopy)
	FWFreeArray(aPontosMed)

Return aAmpl

/*/{Protheus.doc} criaArrayAmplitudeMovelPorArray
Funcao genérica para calcular as amplitudes das medições
@type  Class
@author thiago.rover
@since 17/02/2021
@version 1.0
@param aOrigem, array, array ou matriz de medições
@return aAmplMov, array, array contendo as amplitudes
@example
(examples)
@see (links_or_references)
A amplitude de um conjunto, em Estatística, é a diferença entre o maior elemento desse conjunto e o menor. 
Em outras palavras, para encontrar a amplitude de uma lista de números, basta subtrair o menor elemento do maior.
Exemplo: a amplitude de {10, 11, 12} é 12(maior) - 10(menor) = 2
/*/
METHOD criaArrayAmplitudeMovelPorArray(aOrigem, nSoma) CLASS GraficosQualidadeX //Antiga Static Function fCalcAmpl
	
	Local aAmplMov := {}
	Local nInd     := 0
	Local nValor   := 0

	Default nSoma := 0

	For nInd := 1 To len(aOrigem)
   		nSoma += aOrigem[nInd]
   		If nInd != 1
			nValor := ABS(aOrigem[nInd] - aOrigem[nInd-1])
			aAdd(aAmplMov, nValor)
   		EndIf
	Next

Return aAmplMov

/*/{Protheus.doc} calculaMediaDoArray
Calcula a média dos valores de um array
@author brunno.costa / rafael.kleestadt
@since 10/05/2022
@version 1.0
@param aAmpl, array, array com valores núméricos
@return nRangeBar, numérico, média dos valores
/*/
METHOD calculaMediaDoArray(aAmpl) CLASS GraficosQualidadeX //Antiga Static Function fCalcMdAmp
	
	Local nRangeBar := 0
	Local nValor    := 0
	Local nX        := 0

	// Cálculo Range Barra(Media das Amplitudes)
	For nX := 1 To Len(aAmpl)
		nValor := nValor + aAmpl[nX]
	Next
	
	nRangeBar := nValor / Len(aAmpl)

//Retorna as Médias das Amplitudes em Array
Return nRangeBar

/*/{Protheus.doc} calculaMediaDoArray
Calcula a média dos valores dos conjuntos de uma matriz
@author brunno.costa / rafael.kleestadt
@since 10/05/2022
@version 1.0
@param aDataPar, array, matriz com valores núméricos
@return aMedia, array, array com a média dos valores de cada conjunto
/*/
METHOD calculaMediasDaMatriz(aDataPar) CLASS GraficosQualidadeX //Antiga Static Function fCalcMdAmp
	
	Local aMedia := {}
	Local nInd1  := 0
	Local nValor := 0

	For nInd1 := 1 to Len(aDataPar)
		AADD(aMedia, Self:calculaMediaDoArray(aDataPar[nInd1]))
		nValor := 0
	Next nInd1

Return aMedia

/*/{Protheus.doc} exportaValoresParaCSV
Método que exporta os valores da tela para o Microsoft Excel no formato .CSV
@type  METHOD
@author rafael.kleestadt
@since 23/07/2020
@version 1.0
@param aCabExcel, array, array contendo os campos para o cabeçalho
@return aItensExcel, array, array de dados
@example
(examples)
@see https://tdn.totvs.com/x/LoJdAg
/*/
METHOD exportaValoresParaCSV(aCabExcel, aItensExcel) CLASS GraficosQualidadeX //Antiga Static Function fExport
	MsgRun(STR0024, STR0025,; //"Favor Aguardar.....", "Exportando os Registros para o Excel"
	{||DlgToExcel({{"CABECALHO", STR0026,; //"Dados estatísticos do gráfico"
	aCabExcel,aItensExcel}})})
Return NIL

/*/{Protheus.doc} calculaCPK(nMediaEst, aLimites, nDesvPad)
Calcula o Cpk
@type  METHOD
@author rafael.kleestadt
@since 23/07/2020
@version 1.0
@param nMediaEst, array, array com as medias da medição
@param aLimites, array, "[TARGET]", "[LSL]", "[USL]"
@param nDesvPad, float, desvio padrão
@return nCpk, float, Cpk
@example
(examples)
@see (links_or_references)
/*/
METHOD calculaCPK(nMediaEst, aLimites, nDesvPad) CLASS GraficosQualidadeX //Antiga Static Function fCalcCpk ou fCalCpk
	Local nCpkInf := (nMediaEst - aLimites[2]) / (3 * nDesvPad)
	Local nCpkSup := (aLimites[3] - nMediaEst) / (3 * nDesvPad)
	Local nCpk    := TRANSFORM(Round(IIF(nCpkInf < nCpkSup, nCpkInf, nCpkSup),10),"@E 9999.9999999999")
Return nCpk

/*/{Protheus.doc} calculaPPK(nMediaEst, aLimites, nDesvPad)
Calcula o Ppk
@type  METHOD
@author rafael.kleestadt
@since 23/07/2020
@version 1.0
@param nMediaEst, array, array com as medias da medição
@param aLimites, array, "[TARGET]", "[LSL]", "[USL]"
@param nDesvPad, float, desvio padrão
@return nCpk, float, Ppk
(examples)
@see (links_or_references)
/*/
METHOD calculaPPK(nMediaEst, aLimites, nDesvPad) CLASS GraficosQualidadeX //Antiga Static Function fCalcPpk ou fCalPpk
	Local nPpkInf := (nMediaEst - aLimites[2]) / (3 * nDesvPad)
	Local nPpkSup := (aLimites[3] - nMediaEst) / (3 * nDesvPad)
	Local nPpk    := TRANSFORM(Round( IIF(nPpkInf < nPpkSup, nPpkInf, nPpkSup), 10 ),"@E 9999.9999999999")
Return nPpk

/*/{Protheus.doc} retornaConstante
Retorna a constante conforme a tabela de valores das constantes para cálculo dos limites de controle
@type  METHOD
@author rafael.kleestadt
@since 24/07/2020
@version 1.1
@param aMedicoes, array, array de medições
@param cType, caracere, tipo da constantea ser retornada
@param nTamAmostr, numérico, numero de amostras para consulta de constante fixa
@return nValor, float, constante para cálculo do limite de controle
@example
(examples)
@see https://www.iso.org/standard/15366.html
/*/
METHOD retornaConstante(aMedicoes, cType, nTamAmostr) CLASS GraficosQualidadeX //Antiga Static Function fRetValTab

	Local aTabela   := {}
	Local aTipos    := {"A", "A2", "A3", "B3", "B4", "B5", "B6", "D1", "D2", "D3", "D4", "c4", "c5", "1/c4", "d2", "d3", "1/d2", "d4"}
	Local nCol      := ASCAN( aTipos, cType )
	Local nLin      := IIF(LEN(aMedicoes) <= 25, LEN(aMedicoes), 24)
	Local nLinArray := 0
	Local nValor    := 0

	Default nTamAmostr := nLin

	nLinArray := IIF(nTamAmostr <= 1, 1, nTamAmostr - 1)

	//                   Fatores para Limites de Controle                                             Fatores para Linha Central
	// n                 A      A2     A3     B3     B4     B5     B6     D1     D2     D3     D4     c4      c5     1/c4    d2     d3      1/d2    d4
	/*02*/AADD(aTabela, {2.121, 1.880, 2.659, 0.000, 3.267, 0.000, 2.606, 0.000, 3.686, 0.000, 3.267, 0.7979, 0.603, 1.2533, 1.128, 0.8525, 0.8865, 0.954} )
	/*03*/AADD(aTabela, {1.732, 1.023, 1.954, 0.000, 2.568, 0.000, 2.276, 0.000, 4.358, 0.000, 2.574, 0.8862, 0.463, 1.1284, 1.693, 0.8884, 0.5907, 1.588} )
	/*04*/AADD(aTabela, {1.500, 0.729, 1.628, 0.000, 2.266, 0.000, 2.088, 0.000, 4.698, 0.000, 2.282, 0.9213, 0.389, 1.0854, 2.059, 0.8794, 0.4857, 1.978} )
	/*05*/AADD(aTabela, {1.342, 0.577, 1.427, 0.000, 2.089, 0.000, 1.964, 0.000, 4.918, 0.000, 2.114, 0.9400, 0.341, 1.0638, 2.326, 0.8641, 0.4299, 2.257} )
	/*06*/AADD(aTabela, {1.225, 0.483, 1.287, 0.030, 1.970, 0.029, 1.874, 0.000, 5.078, 0.000, 2.004, 0.9515, 0.308, 1.0510, 2.534, 0.8480, 0.3946, 2.472} )
	/*07*/AADD(aTabela, {1.134, 0.419, 1.182, 0.118, 1.882, 0.113, 1.806, 0.204, 5.204, 0.076, 1.924, 0.9594, 0.282, 1.0423, 2.704, 0.8332, 0.3698, 2.645} )
	/*08*/AADD(aTabela, {1.061, 0.373, 1.099, 0.185, 1.815, 0.179, 1.751, 0.388, 5.306, 0.136, 1.864, 0.9650, 0.262, 1.0363, 2.847, 0.8198, 0.3512, 2.791} )
	/*09*/AADD(aTabela, {1.000, 0.337, 1.032, 0.239, 1.761, 0.232, 1.707, 0.547, 5.393, 0.184, 1.816, 0.9693, 0.246, 1.0317, 2.970, 0.8078, 0.3367, 2.915} )
	/*10*/AADD(aTabela, {0.949, 0.308, 0.975, 0.284, 1.716, 0.276, 1.669, 0.687, 5.469, 0.223, 1.777, 0.9727, 0.232, 1.0281, 3.078, 0.7971, 0.3249, 3.024} )
	/*11*/AADD(aTabela, {0.905, 0.285, 0.927, 0.321, 1.679, 0.313, 1.637, 0.811, 5.535, 0.256, 1.744, 0.9754, 0.220, 1.0252, 3.173, 0.7873, 0.3152, 3.121} )
	/*12*/AADD(aTabela, {0.866, 0.266, 0.886, 0.354, 1.646, 0.346, 1.610, 0.922, 5.594, 0.283, 1.717, 0.9776, 0.210, 1.0229, 3.258, 0.7785, 0.3069, 3.207} )
	/*13*/AADD(aTabela, {0.832, 0.249, 0.850, 0.382, 1.618, 0.374, 1.585, 1.025, 5.647, 0.307, 1.693, 0.9794, 0.202, 1.0210, 3.336, 0.7704, 0.2998, 3.285} )
	/*14*/AADD(aTabela, {0.802, 0.235, 0.817, 0.406, 1.594, 0.399, 1.563, 1.118, 5.696, 0.328, 1.672, 0.9810, 0.194, 1.0194, 3.407, 0.7630, 0.2935, 3.356} )
	/*15*/AADD(aTabela, {0.775, 0.223, 0.789, 0.428, 1.572, 0.421, 1.544, 1.203, 5.741, 0.347, 1.653, 0.9823, 0.187, 1.0180, 3.472, 0.7562, 0.2880, 3.422} )
	/*16*/AADD(aTabela, {0.750, 0.212, 0.763, 0.448, 1.552, 0.440, 1.526, 1.282, 5.782, 0.363, 1.637, 0.9835, 0.181, 1.0168, 3.532, 0.7499, 0.2831, 3.482} )
	/*17*/AADD(aTabela, {0.728, 0.203, 0.739, 0.466, 1.534, 0.458, 1.511, 1.356, 5.820, 0.378, 1.622, 0.9845, 0.175, 1.0157, 3.588, 0.7441, 0.2787, 3.538} )
	/*18*/AADD(aTabela, {0.707, 0.194, 0.718, 0.482, 1.518, 0.475, 1.496, 1.424, 5.856, 0.391, 1.608, 0.9854, 0.170, 1.0148, 3.640, 0.7386, 0.2747, 3.591} )
	/*19*/AADD(aTabela, {0.688, 0.187, 0.698, 0.497, 1.503, 0.490, 1.483, 1.487, 5.891, 0.403, 1.597, 0.9862, 0.166, 1.0140, 3.689, 0.7335, 0.2711, 3.640} )
	/*20*/AADD(aTabela, {0.671, 0.180, 0.680, 0.510, 1.490, 0.504, 1.470, 1.549, 5.921, 0.415, 1.585, 0.9869, 0.161, 1.0133, 3.735, 0.7287, 0.2677, 3.686} )
	/*21*/AADD(aTabela, {0.655, 0.173, 0.663, 0.523, 1.477, 0.516, 1.459, 1.605, 5.951, 0.425, 1.575, 0.9876, 0.157, 1.0126, 3.778, 0.7242, 0.2647, 3.730} )
	/*22*/AADD(aTabela, {0.640, 0.167, 0.647, 0.534, 1.466, 0.528, 1.448, 1.659, 5.979, 0.434, 1.566, 0.9882, 0.153, 1.0119, 3.819, 0.7199, 0.2618, 3.771} )
	/*23*/AADD(aTabela, {0.626, 0.162, 0.633, 0.545, 1.455, 0.539, 1.438, 1.710, 6.006, 0.443, 1.557, 0.9887, 0.150, 1.0114, 3.858, 0.7159, 0.2592, 3.811} )
	/*24*/AADD(aTabela, {0.612, 0.157, 0.619, 0.555, 1.445, 0.549, 1.429, 1.759, 6.031, 0.451, 1.548, 0.9892, 0.147, 1.0109, 3.895, 0.7121, 0.2567, 3.847} )
	/*25*/AADD(aTabela, {0.600, 0.153, 0.606, 0.565, 1.435, 0.559, 1.420, 1.806, 6.056, 0.459, 1.541, 0.9896, 0.144, 1.0105, 3.931, 0.7084, 0.2544, 3.883} )
	/* n = número de replicatas */

	nValor := aTabela[nLinArray, nCol]
	
Return nValor

/*/{Protheus.doc} exibeTelaEstatisticas
Função especifica para apresentar a tela de Estatisticas.
@type  METHOD
@author thiago.rover
@since 24/08/2020
@version version
@param  aItensExcel, aCabExcel, nCp, nCg, nPp, nCr,nCpl, nCpu, nSigma, nMean, nN, nCpk, nCgk, nPpk, nPr, cEstSigma 
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
METHOD exibeTelaEstatisticas(aItensExcel, aCabExcel, nCp, nCg, nPp, nCr,nCpl, nCpu, nSigma, nMean, nN, nCpk, nCgk, nPpk, nPr, cEstSigma ) CLASS GraficosQualidadeX //Antiga Function fEstDial
	
	DEFINE DIALOG oDlg TITLE STR0006 FROM 10, 0 TO 400,440 PIXEL //"Estatísticas"
		@ 0.3 ,0008 SAY STR0022 //"Índices do gráfico"
		@ 125 ,0003 BUTTON oBtnExpot PROMPT STR0023 SIZE 60, 14 ACTION Self:exportaValoresParaCSV(aCabExcel, aItensExcel) OF oDlg PIXEL //"Exportar"

		@ 1.3 ,00.5 SAY "Cp"
		@ 1.3 ,0003	MSGET nCp 	WHEN .F.
		@ 1.3 ,0014	SAY "Cpk"
		@ 1.3 ,17.0	MSGET nCpk 	WHEN .F.

		@ 2.3 ,00.5 SAY "Cg"
		@ 2.3 ,0003	MSGET nCg  	WHEN .F.
		@ 2.3 ,0014 SAY "Cgk"
		@ 2.3 ,17.0	MSGET nCgk  WHEN .F.

		@ 3.3 ,00.5 SAY "Pp"
		@ 3.3 ,0003	MSGET nPp  	WHEN .F.
		@ 3.3 ,0014 SAY "Ppk"
		@ 3.3 ,17.0	MSGET nPpk 	WHEN .F.

		@ 4.3 ,00.5 SAY "Cr"
		@ 4.3 ,0003	MSGET nCr  	WHEN .F.
		@ 4.3 ,0014 SAY "Pr"
		@ 4.3 ,17.0	MSGET nPr  	WHEN .F.
		
		@ 5.3 ,00.5 SAY "Cpu"
		@ 5.3 ,0003 MSGET nCpu 	WHEN .F.
		@ 5.3 ,0014 SAY "Est.Sigma"
		@ 5.3 ,17.0	MSGET cEstSigma	WHEN .F.

		@ 6.3 ,00.5 SAY "Sigma"    
		@ 6.3 ,0003	MSGET nSigma 	WHEN .F.
		@ 6.3 ,0014 SAY "N"   
		@ 6.3 ,17.0 MSGET nN    WHEN .F.

		@ 7.3 ,00.5 SAY "Mean"        
		@ 7.3 ,0003	MSGET nMean  	WHEN .F.

	ACTIVATE MSDIALOG oDlg CENTERED 
	
Return NIL

/*/{Protheus.doc} IMPRELCART
Gera o grafico dentro de uma tela de relatório FWMSPrinter
@type METHOD
@author Rafael Kleestadt da Cruz
@since 08/09/2020
@version 1.0
@param aDataPar, array, array com os pontos
@param nTipo, numeric, tipo do grafico
@param aMedicoes, array, array com todas as amostras
@param aTitCarCon, array, array com os titulos(carta de controle)
@param aLimites, array, array com o limite superior, valor esperado e limite inferior
@param cDirPng, caractere, diretório onde deve ser guardada a foto do grafico para impressão
@param cArqPNG, caractere, nome da foto do grafico para impressão
@param lXbXbr, logical, se o tipo da carta é XBR/XBS .T. or .F.
@param lReport, logical, se o grafico será gerado apenas para impressão da foto
@param cTpCarEsc, caractere, Carta escolhida - "XBR", "XBS", "IND" ou "HIS"
@param cTpCarEns, caractere, Carta do ensaio - "XBR", "XBS", "IND" ou "HIS"
@param nTamAmostr, numérico, tamanho da amostra
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
METHOD imprimirGrafico(aDataPar, nTipo, aMedicoes, aTitCarCon, aLimites, cDirPng, cArqPNG, lXbXbr, lReport, cTpCarEns, cTpCarEsc, nTamAmostr) CLASS GraficosQualidadeX //Antiga Static Function IMPRELCART
	
	Local cArqBMP := ""
	Local nHeight := 2000
	Local nLenPar := LEN(aDataPar)
	Local nWidth  := 2000
	Local nX      := 0

	DEFAULT cDirPng := IIF(GetRemoteType() == 5, GetTempPath(.T., .T.), GetTempPath(.T., .F.))

	For nX := 1 to 99999
		cArqBMP := "QIEMGRAFIC" + StrZero(nX,4) + ".bmp"
		If !File(cDirPng+cArqBMP)
			Exit
		EndIf
	Next nX

	QIEMGRAFIC(aDataPar, nTipo, aMedicoes, aTitCarCon, aLimites, cDirPng, cArqBMP, lXbXbr, lReport, cTpCarEns, cTpCarEsc, nTamAmostr)

	oPrint:= FWMSPrinter():New(cArqBMP,6,.t.,cDirPng,.T.,,,,,,,.F.,)
	IF nTipo == 9 .Or. nTipo == 91 .Or. nTipo == 92 .Or. nTipo == 97
		IF nLenPar <= 10
			nWidth  := 2000
			nHeight := 1000
		ELSEIF nLenPar > 30 .And. nLenPar < 50
			oPrint:SetLandscape()
			nWidth  := 2700
			nHeight := 1000
		ELSEIF nLenPar >= 50 .And. nLenPar < 100
			oPrint:SetLandscape()
			nWidth  := 2500
			IF nTipo == 9 .Or. nTipo == 91 .Or. nTipo == 92 .Or. nTipo == 97
				nHeight := 2200
			ELSE
				nHeight := 1700
			ENDIF
		ENDIF
	ELSEIF nTipo == 4 .or. nTipo == 2 .or. nTipo == 3
		nWidth  := 2100
		nHeight := 950

	ENDIF

	oPrint:StartPage()
	oPrint:SetResolution(72)
	oPrint:SetPaperSize(DMPAPER_A4)
	oPrint:SayBitmap( 100, 200, cDirPng + cArqBMP, nWidth, nHeight )
	oPrint:cPathPDF := cDirPng		
	oPrint:SetViewPDF(.t.)
	oPrint:EndPage() 
	oPrint:Preview()
	
Return nil


/*/{Protheus.doc} criaArrayAmostrasComQuebra
Quebra o array de amostras em arrays de 50 medições
@type  METHOD
@author rafael.kleestadt
@since 15/07/2021
@version 1.0
@param xAmostra, array, array contendo as medições
@param nQuebra, number, qtd de amostras por linha
@return aReturn, array, array de array com 50 posições contendo as amostras
@example
(examples)
@see (links_or_references)
/*/
METHOD criaArrayAmostrasComQuebra(xAmostra, nQuebra) CLASS GraficosQualidadeX //Antiga Static Function fBrakeAmos

	Local aAmostBkp := {}
	Local aReturn   := {}
	Local nX        := 0
	Local xBkp      := aClone(xAmostra)

	If ValType(xAmostra) = "A"
		For nX := 1 To Len(xAmostra)
			If Len(aAmostBkp) == nQuebra
				AADD(aReturn, aAmostBkp)
				aAmostBkp := {}
			Endif
			
			AADD(aAmostBkp, xAmostra[nX])
		Next nX
	EndIf

	If Len(aAmostBkp) > 0
		AADD(aReturn, aAmostBkp)
	Endif

	xAmostra := aClone(xBkp)
	
Return aReturn

/*/{Protheus.doc} calculaDimensionamentoDaTela
Calcula o dimencionamento da tela conforme a quantidade de dados a serem exibidos
@type  METHOD
@author rafael.kleestadt
@since 04/08/2021
@version 1.0
@param nTamDatPar, numeric, quantidade de registros a serem usados para a geração do grafico
@param nTipo, numeric, tipo do grafico
@return array, array, array cntendo a altura, largura e tamanho da fonte
@example
(examples)
@see (links_or_references)
/*/
METHOD calculaDimensionamentoDaTela(nTamDatPar, nTipo) CLASS GraficosQualidadeX //Antiga Static Function fTamanGraf

	Local aCoors 	 := FWGetDialogSize(oMainWnd) //Tamanho tela
	Local cFontLabel := "15px sans-serif"
	Local nFatLarg   := 2
	Local nHeight	 := 0
	Local nWidth	 := 0

	IF cValToChar(nTipo) $ "1 | 2 | 7 | 9 | 91 | 92 | 97"
		IF nTamDatPar >= 20 .And. nTamDatPar < 50
			cFontLabel := "8px sans-serif"
		ELSEIF nTamDatPar >= 50 .AND. nTamDatPar < 100
			cFontLabel := "7.5px sans-serif"
		ELSEIF nTamDatPar > 100
			cFontLabel := "7px sans-serif"
		ENDIF

		IF nTamDatPar > 20 .AND. nTamDatPar < 30
			IF aCoors[4] > 1000 .AND. aCoors[4] < 1100
				nFatLarg := 2
			ELSE
				nFatLarg := 1.6
			ENDIF
		ELSEIF nTamDatPar >= 30 .AND. nTamDatPar <= 50
			nFatLarg := 1.6
		ELSEIF nTamDatPar > 50
			nFatLarg := 1
		ENDIF
	ENDIF

	nWidth  := aCoors[4] / nFatLarg
	nHeight := aCoors[3]
	
Return {nHeight, nWidth, cFontLabel}

/*/{Protheus.doc} retornaTituloDialog(nTipo)
Retorna o titulo da dialog
@type  METHOD
@author rafael.kleestadt
@since 05/08/2021
@version 1.0
@param nTipo, numeric, tipo do grafico 
@return cNameDlg, caracter, titulo a ser exibido na dialog
@example
(examples)
@see (links_or_references)
/*/
METHOD retornaTituloDialog(nTipo) CLASS GraficosQualidadeX //Antiga Static Function fGetTitDlg

	Local cNameDlg := ""

	If nTipo == 1 .Or. (IsInCallStack("QPPA170") .And. nTipo <> 3) .Or. (IsInCallStack("QPPR170") .And. (nTipo == 2 .Or. nTipo == 3 .Or. nTipo == 7))
		cNameDlg := STR0016 //"Cartas de Controle"
	elseif nTipo == 2
		cNameDlg := STR0009 //"Diagrama de Pareto"
	ElseIf nTipo == 3
		cNameDlg := STR0014 //"Histograma"
	ElseIf nTipo == 4
		cNameDlg := STR0017 //"Estudo de Linearidade MSA 4ª Edição"
	ElseIf nTipo == 5
		cNameDlg := STR0018 //"Tendências"
	ElseIf nTipo == 6 
		cNameDlg := STR0019 //"Relatório Índice Qualidade"
	ElseIf nTipo == 7
		cNameDlg := STR0020 //"Relatório de Performance de Sistemas de Medição"
	ElseIf nTipo == 8
		cNameDlg := STR0021 //"Carta Individual"
	EndIf
		
Return cNameDlg

/*/{Protheus.doc} criaArrayJsonXYELimitesAmplitudeParaGrafico
Metodo que monta o Json com a linha "Valor" e os limites para graficos Range(Amplitude)
@type  METHOD
@author thiago.rover / rafael.kleestadt / brunno.costa
@since 16/09/2021
@version version
@param aMedicoes, array, matriz numerica com os dados das medições 
@return aRet, array, matriz com Jason de valores e limites.
@example
(examples)
@see (links_or_references)
/*/
METHOD criaArrayJsonXYELimitesAmplitudeParaGrafico(aMedicoes) CLASS GraficosQualidadeX //Antiga Static Function fCalAmplMv

	Local aAmpl    := {}
	Local aJsData  := {}
	Local aLim     := {}
	Local aRet     := {}
	Local nMedAmpl := Nil

	// Função genérica que calcula as Amplitudes
	aAmpl := Self:criaArrayAmplitudesPorArrayOuMatriz(aMedicoes)

	// Cálculo Range Barra (Media das Amplitudes)
	nMedAmpl := Self:calculaMediaDoArray(aAmpl)

	If !Len(aAmpl) > 1
		aAmpl  := aClone(aMedicoes)
	Endif

	// Amplitude Movel
	aJsData := Self:criaArrayJsonXYPorArray(aAmpl)
	aLim    := Self:criaArrayLimites_nUcl_nMedia_nLcl(nMedAmpl)

	Aadd(aRet,aJsData)
	Aadd(aRet,aLim)
	
Return aRet

/*/{Protheus.doc} criaArrayDesvioPadrao
Função que calcula o desvio padrão, esta função é vital para o funcionamento do tipo de Carta XBS no QIPA215.
@type  METHOD
@author thiago.rover / rafael.kleestadt / brunno.costa
@since 16/09/2021
@version 1.1
@param aMedicoes, array, matriz contendo as medições
@return aDevPdr, array, array coom os desvio padrãod e cada amostra
@example
(examples)
@see (links_or_references)
/*/
METHOD criaArrayDesvioPadrao(aMedicoes) CLASS GraficosQualidadeX //Antiga Static Function fCalDesv

	Local aDevPdr  := {}
	Local aMed     := {} 
	Local aVarianc := {}
	Local nRaiz    := 0
	Local nSoma    := 0
	Local nSomaVar := 0
	Local nX       := 0
	Local nY       := 0

	//Calculo da média 
	For nX := 1 To Len(aMedicoes)
		For nY := 1 To Len(aMedicoes[nX])
			nSoma := nSoma + SuperVal(aMedicoes[nX][nY])
		Next nY
		Aadd(aMed,nSoma/Len(aMedicoes[nX]))
		nSoma := 0 
	Next nX

	//Calculo da variância
	For nX := 1 To Len(aMedicoes) 
		For nY := 1 To Len(aMedicoes[nX])
			nSomaVar := nSomaVar + (SuperVal(aMedicoes[nX][nY]) - aMed[nX])^2
		Next nY
		Aadd(aVarianc,nSomaVar/(Len(aMedicoes[nX])-1))
		nSomaVar := 0
	Next nX

	//Calculo da raiz quadrada da variância // Desvio Padrão
	For nX := 1 To Len(aVarianc)
		nRaiz := SQRT(aVarianc[nX])
		Aadd(aDevPdr, nRaiz)
	Next nX
	
Return aDevPdr			

/*/{Protheus.doc} calculaCPU
Função especialista que calcula o cpu de acordo com o tipo de ensaio e o tipo de gráfico.
@type  METHOD
@author thiago.rover / rafael.kleestadt / brunno.costa
@since 15/10/2021
@version 1.1
@param aLimites, array, nLSL, Referencia e nUSL
@param aMedias, array, array com a média da amostras
@return nCpu, numérico, variação superior da tolerância dividida por 3 vezes o desvio padrão estimado pela capabilidade do processo.
@see (links_or_references)
Cpu = (USL – Process Mean)/(3*Standard Deviation)
/*/
METHOD calculaCPU(aLimites, aMedias) CLASS GraficosQualidadeX //Antiga Function fRelCalc
Return TRANSFORM(Round((aLimites[3] - aMedias[2]),10),"@E 9999.9999999999")

/*/{Protheus.doc} calculaEstSigma
Função especialista que calcula o est. sigma de acordo com o tipo de ensaio e o tipo de gráfico.
@type  METHOD
@author thiago.rover / rafael.kleestadt / brunno.costa
@since 15/10/2021
@version 1.1
@param aMedicoes, array, array com todas as amostras
@param nDesvPad, numérico, desvio padrão
@param aMedias, array, array com o maior o menor e a média da amostra.
@param cTpCarEsc, caractere, Carta escolhida - "XBR", "XBS", "IND" ou "HIS"
@param cTpCarEns, caractere, Carta do ensaio - "XBR", "XBS", "IND" ou "HIS"
@param nTamAmostr, numérico, tamanho da amostra
@param nMedAmpl, numérico, amplitude da amostra
@see (links_or_references)
/*/
METHOD calculaEstSigma(aMedicoes, nDesvPad, aMedias, cTpCarEsc, cTpCarEns, nTamAmostr, nMedAmpl) CLASS GraficosQualidadeX //Antiga Function fRelCalc

	LOCAL nEstSigma    := 0

	DEFAULT cTpCarEns  := ""
	DEFAULT cTpCarEsc  := ""
	DEFAULT nTamAmostr := NIL

	IF cTpCarEns == "IND" .And. cTpCarEsc == "XBR"

		//Est. Sigma = (Process Mean / constant for calculating the control limit) 
		nEstSigma := (nMedAmpl / Self:retornaConstante(aMedicoes, "d2"))
			
		IF nEstSigma <= 0 
			nEstSigma := nDesvPad		
		EndIf

		nEstSigma := TRANSFORM(Round((nEstSigma),10),"@E 9999.9999999999")     									

	ElseIF (cTpCarEns == "HIS" .And. cTpCarEsc == "XBR") .Or. (cTpCarEns == "XBR" .Or. cTpCarEns == "XBS")

		//Est. Sigma = (Process Mean / constant for calculating the control limit) 
		nEstSigma := (nMedAmpl / Self:retornaConstante(aMedicoes, "d2", nTamAmostr))
			
		IF nEstSigma <= 0 
			nEstSigma := nDesvPad		
		EndIf

		nEstSigma := TRANSFORM(Round((nEstSigma),10),"@E 9999.9999999999")     									

	Else      

		//Apesar de setada a quantdade de amostras, o calculo deve ser feito com a quantidade de medições *Ivo - 05/05/2022
		IF (cTpCarEns == "IND" .And. cTpCarEsc == "XBS")
			nTamAmostr := NIL
		ENDIF

		//Est. Sigma = (Media das amplitudes / constant for calculating the control limit)
		If VALTYPE(nMedAmpl) == 'N'
			nEstSigma := TRANSFORM(Round((nMedAmpl / Self:retornaConstante(aMedicoes, "d2", nTamAmostr)),10),"@E 9999.9999999999")
		Else
			nEstSigma := TRANSFORM(Round((aMedias[2] / Self:retornaConstante(aMedicoes, "d2", nTamAmostr)),10),"@E 9999.9999999999")
		EndIf

	EndIf
	
Return nEstSigma

/*/{Protheus.doc} criaArrayLimites_nUcl_nCl_nLcl
Calcula os limites de acordo com os pontos da media para carta de controle ensaio carta XBR e XBS
Obs. Este método serve geralmente para calcular os limites de graficos de Xbar(Média)
@type  METHOD
@author rafael.kleestadt
@since 26/04/2022
@version 1.0
@param aMedicoes, Array, pontos das medições.
@param aMedAux, Array, pontos das medições no formato matriz.
@param aLimites, Array, Limites calculados com base nos cadastros.
@param cTpCarEsc, caracter, tipo da carta escolhida.
@param cTpCarEns, caracter, tipo da carta do ensaio
@param nTamAmostr, numeric, tamanho da amostra.
@return nUcl, numeric, limite de controle superior 
@return ncl, numeric, média das médias
@return nLcl, numeric, limite ide controle nferior
@example
(examples)
@see https://tdn.totvs.com/x/hOSWJw
/*/
METHOD criaArrayLimites_nUcl_nCl_nLcl(aMedicoes, aMedAux, aLimites, cTpCarEsc, cTpCarEns, nTamAmostr) CLASS GraficosQualidadeX //Antiga Function fLimMedQIP

	LOCAL oDesvPad     := NB():New(aMedicoes)
	LOCAL aMedias      := oDesvPad:mediasNB(aMedicoes)
	LOCAL nCl          := Round(aMedias[2], 10 )
	LOCAL nConstant    := 0
	LOCAL nDesvPad     := Round(oDesvPad:getDesvPad(aMedicoes), 10)
	LOCAL nMedAmpl     := Self:calculaMediaDoArray(Self:criaArrayAmplitudesPorArrayOuMatriz(aMedAux))
	LOCAL nUcl         := 0
	LOCAL nLcl         := 0
	DEFAULT nTamAmostr := Len(aMedAux)

	nConstant := Self:retornaConstante(aMedicoes, "d2", nTamAmostr)

	// Função especialista que calcula e retorna o Cpu e Est. Sigma de acordo com o Tipo de Gráfico
	nEstSigma := Self:calculaEstSigma(aMedicoes, nDesvPad, aMedias, cTpCarEsc, cTpCarEns, nTamAmostr, nMedAmpl)
	
	nUcl := nCl  + ( (3 * nMedAmpl) / (nConstant * SQRT(nTamAmostr) ))
	nLcl := nCl  - ( (3 * nMedAmpl) / (nConstant * SQRT(nTamAmostr) ))
	
Return {nUcl, nCl, nLcl}


/*/{Protheus.doc} criaArrayLimites_nUcl_nCl_nLcl__PontosDesvioPadrao
Retorna os limites do grafico quando a carta do ensaio é XBS e o grafico é de desvio padrão
@type  METHOD
@author rafael.kleestadt
@since 26/04/2022
@version 1.0
@param aMedicoes, array, array com as medições.
@return nUcl, numeric, limite de controle superior 
@return ncl, numeric, média das médias
@return nLcl, numeric, limite ide controle nferior
@example
(examples)
@see https://tdn.totvs.com/x/hOSWJw
/*/
METHOD criaArrayLimites_nUcl_nCl_nLcl__PontosDesvioPadrao_XBS(aMedicoes) CLASS GraficosQualidadeX //Antiga Function fLimDesvQIP

	LOCAL oDesvPad := NB():New(aMedicoes)
	LOCAL aMedias  := oDesvPad:mediasNB(aMedicoes)
	LOCAL nCl      := Round(aMedias[2], 10 )
	LOCAL nConsB3  := Self:retornaConstante(aMedicoes, "B3", 4) //B3
	LOCAL nConsB4  := Self:retornaConstante(aMedicoes, "B4", 5) //B4
	LOCAL nLcl     := 0
	LOCAL nUcl     := 0

	nUcl := nCl  * nConsB4
	nLcl := nCl  * nConsB3
	
Return {nUcl, nCl, nLcl}

/*/{Protheus.doc} criaArrayLimites_nUcl_nCl_nLcl__PontosDesvioPadrao_IND
Retorna os limites quando a carta do ensaio é do tipo IND
@type  METHOD
@author rafael.kleestadt
@since 29/04/2022
@version 1.0
@param aMedicoes, array, array com as medições.
@return nUcl, numeric, limite de controle superior 
@return ncl, numeric, média das médias
@return nLcl, numeric, limite ide controle nferior
@example
(examples)
@see https://tdn.totvs.com/x/hOSWJw
/*/
METHOD criaArrayLimites_nUcl_nCl_nLcl__PontosDesvioPadrao_IND(aMedicoes) CLASS GraficosQualidadeX //Antiga Function fLimAmMIND

	LOCAL oDesvPad := NB():New(aMedicoes)
	LOCAL aMedias  := oDesvPad:mediasNB(aMedicoes)
	LOCAL nCl      := Round(aMedias[2], 10 )
	LOCAL nd3      := Self:retornaConstante({}, "d3", 2) //0.8525
	LOCAL nDesvPad := Round(oDesvPad:getDesvPad(aMedicoes), 10)
	LOCAL nLcl     := 0
	LOCAL nUcl     := 0

	nUcl := nCl + (3 * nd3 * nDesvPad)
	nLcl := nCl - (3 * nd3 * nDesvPad)
	nLcl := MAX(0, nLcl) //Maior entra calculo e 0 *Ivo

Return {nUcl, nCl, nLcl}

/*/{Protheus.doc} criaArrayLimites_nUcl_nCl_nLcl__PontosDesvioPadrao_HIS
Retorna os limites quando a carta do ensaio é do tipo HIS
@type  METHOD
@author rafael.kleestadt
@since 02/05/2022
@version 1.0
@param aMedicoes, array, array com as medições.
@return nUcl, numeric, limite de controle superior 
@return ncl, numeric, média das médias
@return nLcl, numeric, limite ide controle nferior
@example
(examples)
@see https://tdn.totvs.com/x/hOSWJw
/*/
METHOD criaArrayLimites_nUcl_nCl_nLcl__PontosDesvioPadrao_HIS(aMedicoes) CLASS GraficosQualidadeX //Antiga Function fLimAmMHIS

	LOCAL oDesvPad  := NB():New(aMedicoes)
	LOCAL aMedias   := oDesvPad:mediasNB(aMedicoes)
	LOCAL nCl       := Round(aMedias[2], 10 )
	Local nConstant := Self:retornaConstante({}, "d3", 5) //0.864
	LOCAL nDesvPad  := nCl / Self:retornaConstante(aMedicoes, "d2", 1) // Desvio Parão(Range Barra / D2)
	LOCAL nLcl      := 0 // Limite Inferior
	LOCAL nUcl      := 0 // Limite Superior

	//Média das médias + ( 3 * Est. Sigma )
	nUCL := nCl + ( 3 * nConstant * nDesvPad)

	//Média das médias - ( 3 * Est. Sigma )
	nLCL := nCl - ( 3 * nConstant * nDesvPad )

Return {nUcl, nCl, nLcl}

/*/{Protheus.doc} criaArrayLimites_nUcl_nCl_nLcl__PontosDesvioPadrao_XBR
Calcula os limites do grafico de Amplitude quando ensaio IND e carta escolhida XBR
@type  METHOD
@author rafael.kleestadt
@since 04/05/2022
@version 1.0
@param aMedicoes, array, array contendo as medições
@return nUcl, number, limite superior
@return nCl, number, media das medias
@return nLcl, number, limite inferior
@example
(examples)
@see https://tdn.totvs.com/x/hOSWJw
/*/
METHOD criaArrayLimites_nUcl_nCl_nLcl__PontosDesvioPadrao_XBR(aMedicoes) CLASS GraficosQualidadeX //Antiga Function fLimINDXBR

	LOCAL nCl       := Self:calculaMediaDoArray(Self:criaArrayAmplitudesPorArrayOuMatriz(aMedicoes))
	LOCAL nd3       := Self:retornaConstante({}, "d3", 2) //0.8525
	LOCAL nEstSigma := nCl / Self:retornaConstante(aMedicoes, "d2") // Desvio Parão(Range Barra / D2)
	LOCAL nLcl      := 0
	LOCAL nUcl      := 0

	nUcl := nCl + (3 * nd3 * nEstSigma)
	nLcl := nCl - (3 * nd3 * nEstSigma)

Return {nUcl, nCl, nLcl}