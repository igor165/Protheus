#INCLUDE "TOTVS.CH"
#INCLUDE "QIPEnsaiosCalculados.CH"

CLASS QIPEnsaiosCalculados FROM LongNameClass
	
	DATA aAmostrasBanco     as Array
	DATA aAmostrasMemoria   as Array
	DATA aEnsaiosCalculados as Array
	DATA nAmostraAtual      as Numeric
	DATA nCalculados        as Numeric
	DATA nQPS_MEDICA        as Numeric
	DATA nRecnoInspecao     as Numeric
	DATA nTotalAmostras     as Numeric
	DATA oAPIResultados     as Object
	DATA oMapaPosicoes      as Object
	DATA oMedias            as Object
	DATA oSomasAmostras     as Object
	
	Method New(nRecnoInspecao, aAmostrasMemoria, lConsideraDB)
	Method ExcluiMedicoesCalculadas(cUsuario)
	Method PersisteEnsaiosCalculados(oItemAPI, lProcessa)
	Method ProcessaEnsaiosCalculados()

	//Métodos Internos
	Method CalculaFormulaAritmetica(cEnsaio, cForArit, nDecimal, nIndMed)
	Method CalculaMediasEnsaio(cEnsaio, nQtdMed, nDecimal)
	Method ExisteDesvioPadraoEOuMediaAVG(cFormAux, cForArit, nPosDes, nPosAvg)
	Method MapeiaPosicoes()
	Method MedicaoJaCalculada(cEnsaio, nIndMed)
	Method ProcessaDesvioPadrao(cFormAux, cForArit, nPosDes)
	Method ProcessaEnsaio(cEnsaio, cCarta, nQtdMed, cFormula, nDecimal)
	Method RetornaAmostrasBanco(nRecnoInspecao)
	Method RetornaEnsaiosCalculados(nRecnoInspecao)
	Method RetornaResultadoEnsaio(cEnsaio, nIndMed)
	METHOD RetornaStatusAprovacao(cValor, cControle, cMenor, cMaior)
	METHOD RetornaStatusAprovacaoArray(aMedicoes, cControle, cInferior, cSuperior, nMedicoes)
	Method SubstituiEnsaioPorResultado(cForArit, cEnsaio, nIndMed)
	Method SubstituiEnsaiosPorResultados(cFormula, cForArit, nIndMed)
	Method SubstituiMediaPorResultado(cFormAux, cForArit, nDecimal, nPosAvg, nIndMed, nQtdMed)
	METHOD TrataRegistroParaInclusao(oDadosJson, oItemAPI, nIndEnsaio, nIndAmostra, nMedicoes)

EndClass

Method New(nRecnoInspecao, aAmostrasMemoria, lConsideraDB) CLASS QIPEnsaiosCalculados
	Default lConsideraDB    := .T.
	Self:nRecnoInspecao     := nRecnoInspecao
	Self:aAmostrasMemoria   := aAmostrasMemoria
	Self:nCalculados        := 0
	Self:nTotalAmostras     := 0
	Self:nAmostraAtual      := 0
	Self:aAmostrasBanco     := Iif(lConsideraDB, Self:RetornaAmostrasBanco(nRecnoInspecao), {})
	Self:aEnsaiosCalculados := Self:RetornaEnsaiosCalculados(nRecnoInspecao)
	Self:oMapaPosicoes      := Self:MapeiaPosicoes()
	Self:oMedias            := JsonObject():New()
	Self:oSomasAmostras     := JsonObject():New()
	Self:nQPS_MEDICA        := GetSx3Cache("QPS_MEDICA", "X3_TAMANHO")
Return

/*/{Protheus.doc} RetornaAmostrasBanco
Retorna Amostras de Resultados do Banco referente nRenoInspecao
@author brunno.costa
@since  14/09/2022
@param 01 - nRecnoInspecao, numérico, número do recno da inspeção na QPK
@return aAmostrasBanco, array, conforme padrão QualityAPIManager():MontaItensRetorno() com Mapa de Campos da API ResultadosEnsaiosInspecaoDeProcessosAPI
/*/
Method RetornaAmostrasBanco(nRecnoInspecao) CLASS QIPEnsaiosCalculados 

	Local aAmostrasBanco := {}
	Local cAlias         := Nil
	Local cOrdem         := "testID,sampleNumber,recno"
	Local nPagina        := 1
	Local nTamPag        := 99999999999
	
	Self:oAPIResultados                         := ResultadosEnsaiosInspecaoDeProcessosAPI():New()
	Self:oAPIResultados:oAPIManager:aMapaCampos := Self:oAPIResultados:MapeiaCamposAPI("*")
	If (Self:oAPIResultados:CriaAliasResultadosInspecaoPorEnsaio(nRecnoInspecao, cOrdem, Nil, nPagina, nTamPag, Nil, @cAlias, Self:oAPIResultados:oAPIManager))
		aAmostrasBanco := Self:oAPIResultados:oAPIManager:MontaItensRetorno(cAlias, nPagina, nTamPag)
	EndIf

    (cAlias)->(dbCloseArea())
	
Return aAmostrasBanco

/*/{Protheus.doc} RetornaEnsaiosCalculados
Retorna Ensaios Calculados
@author brunno.costa
@since  14/09/2022
@param 01 - nRecnoInspecao, numérico, número do recno da inspeção na QPK
@return aEnsCalc, array, array com objetos Json contendo os itens calculados: 
{ [ testID, 
	letter, 
	formula, 
	arithmeticFormula,
	nominalValue, 
	quantity, 
	results], ...}

Sendo results Array com as Medições conforme quantidade de medições do ensaio
/*/
Method RetornaEnsaiosCalculados(nRecnoInspecao) CLASS QIPEnsaiosCalculados 

	Local aEnsCalc := {}
	Local cAlias   := Nil
	Local cQuery   := ""
	Local oExec    := Nil
	Local oItem    := Nil

	cQuery += " SELECT QP7.QP7_ENSAIO, QP1.QP1_CARTA, QP7.QP7_FORMUL, QP7.QP7_NOMINA, QP1.QP1_QTDE, RECNOQP7, QP7_MINMAX, QP7_LIE, QP7_LSE "
	cQuery += " FROM "
	cQuery +=      " (SELECT QPK_PRODUT, QPK_REVI, QPK_OP "
	cQuery +=       " FROM " + RetSQLName("QPK")
	cQuery +=       " WHERE   (D_E_L_E_T_ = ' ') "
	cQuery +=  	        " AND (QPK_FILIAL = '" + xFilial("QPK") + "') "
	cQuery +=  	        " AND (R_E_C_N_O_ = " + cValToChar(nRecnoInspecao) + ")) QPK "
	cQuery += " INNER JOIN "
	cQuery +=      " (SELECT QP7_PRODUT, QP7_REVI, QP7_ENSAIO, QP7_NOMINA, QP7_CODREC, QP7_FORMUL, R_E_C_N_O_ RECNOQP7, QP7_MINMAX, QP7_LIE, QP7_LSE "
	cQuery +=       " FROM " + RetSQLName("QP7")
	cQuery +=       " WHERE   (D_E_L_E_T_ = ' ') "
	cQuery +=  	        " AND (QP7_FILIAL = '" + xFilial("QP7") + "') "
	cQuery +=  	        " AND (QP7_FORMUL <> ' ')) QP7  "
	cQuery += " ON      QP7.QP7_PRODUT = QPK.QPK_PRODUT "
	cQuery +=     " AND QP7.QP7_REVI = QPK.QPK_REVI "
	cQuery += " INNER JOIN "
	cQuery +=  	    " (SELECT C2_NUM + C2_ITEM + C2_SEQUEN AS C2_OP, C2_ROTEIRO "
	cQuery +=        " FROM " + RetSQLName("SC2")
	cQuery +=        " WHERE   (D_E_L_E_T_ = ' ') "
	cQuery +=  	         " AND (C2_FILIAL = '" + xFilial("SC2") + "')) SC2  "
	cQuery += " ON      SC2.C2_OP      = QPK.QPK_OP "
	cQuery +=     " AND SC2.C2_ROTEIRO = QP7.QP7_CODREC "
	cQuery += " LEFT OUTER JOIN "
	cQuery +=       " (SELECT QP1_ENSAIO, QP1_CARTA, "
	cQuery +=                " (CASE QP1_CARTA  "
	cQuery +=                " WHEN 'XBR' THEN QP1_QTDE  "
	cQuery +=                " WHEN 'XBS' THEN QP1_QTDE  "
	cQuery +=                " WHEN 'XMR' THEN QP1_QTDE  "
	cQuery +=                " WHEN 'HIS' THEN QP1_QTDE  "
	cQuery +=                " WHEN 'NP ' THEN 1  "
	cQuery +=                " WHEN 'P  ' THEN 3  "
	cQuery +=                " WHEN 'U  ' THEN 2  "
	cQuery +=                " ELSE 1  "
	cQuery +=                " END) AS QP1_QTDE "
	cQuery +=        " FROM " + RetSQLName("QP1")
	cQuery +=        " WHERE   (D_E_L_E_T_ = ' ') "
	cQuery +=         	 " AND (QP1_FILIAL = '" + xFilial("QP1") + "') "
	cQuery +=        	 " AND (QP1_TIPO   = 'C') "
	cQuery +=  	   " AND RTRIM(QP1_CARTA) IN ('XBR','XBS','IND','XMR','HIS','TMP')) QP1 "
	cQuery += " ON QP7.QP7_ENSAIO = QP1.QP1_ENSAIO "

	oExec := FwExecStatement():New(cQuery)
    cAlias := oExec:OpenAlias()

	While (cAlias)->(!Eof())
		oItem := JsonObject():New()
		oItem["letter"]            := (cAlias)->QP1_CARTA
		oItem["testID"]            := (cAlias)->QP7_ENSAIO
		oItem["formula"]           := (cAlias)->QP7_FORMUL
		oItem["nominalValue"]      := (cAlias)->QP7_NOMINA
		oItem["quantity"]          := (cAlias)->QP1_QTDE
		oItem["recnoTest"]         := (cAlias)->RECNOQP7
		oItem["controlType"]       := (cAlias)->QP7_MINMAX
		oItem["lowerDeviation"]    := (cAlias)->QP7_LIE
		oItem["upperDeviation"]    := (cAlias)->QP7_LSE
		oItem["results"]           := {}
		oItem["arithmeticFormula"] := {}
		aAdd(aEnsCalc, oItem )
		(cAlias)->(DbSkip())
	EndDo


Return aEnsCalc

/*/{Protheus.doc} MapeiaPosicoes
Mapeia Posições dos Ensaios dos Arrays aAmostrasMemoria, aEnsaiosCalculados e aAmostrasBanco
@author brunno.costa
@since  14/09/2022
@param 01 - nRecnoInspecao, numérico, número do recno da inspeção na QPK
@return oMapaPosicoes, JsonObject, objeto Json com estrutura:
-> oMapaPosicoes["aAmostrasMemoria"][cEnsaio]   := nPosicao
-> oMapaPosicoes["aEnsaiosCalculados"][cEnsaio] := nPosicao
-> oMapaPosicoes["aAmostrasBanco"][cEnsaio]     := nPosicao
/*/
Method MapeiaPosicoes() CLASS QIPEnsaiosCalculados

	Local cEnsaio       := Nil
	Local lNovaMemoria  := .F.
	Local nInd          := Nil
	Local nTotal        := Nil
	Local oMapaPosicoes := JsonObject():New()

	oMapaPosicoes["aAmostrasBanco"] := JsonObject():New()
	nTotal := Len(Self:aAmostrasBanco)
	For nInd := 1 to nTotal
		If  Self:aAmostrasBanco[nInd]["testType"] == "N"
			cEnsaio := AllTrim(Self:aAmostrasBanco[nInd]["testID"])
			If oMapaPosicoes["aAmostrasBanco"][cEnsaio] == Nil
				oMapaPosicoes["aAmostrasBanco"][cEnsaio] := {}
			EndIf
			aAdd(oMapaPosicoes["aAmostrasBanco"][cEnsaio], nInd)
			nAmostras := Len(oMapaPosicoes["aAmostrasBanco"][cEnsaio])
			If nAmostras > Self:nTotalAmostras
				Self:nTotalAmostras := nAmostras
			EndIf
		EndIf
	Next nInd

	oMapaPosicoes["aAmostrasMemoria"] := JsonObject():New()
	nTotal := Len(Self:aAmostrasMemoria)
	For nInd := 1 to nTotal
		If  Self:aAmostrasMemoria[nInd]["testType"] == "N"      .AND.;
			Self:aAmostrasMemoria[nInd]["measurements"] != Nil  .AND.;
			!Empty(Self:aAmostrasMemoria[nInd]["measurements"]) .AND.;
			!Empty(Self:aAmostrasMemoria[nInd]["testID"])

			cEnsaio := AllTrim(Self:aAmostrasMemoria[nInd]["testID"])
			oMapaPosicoes["aAmostrasMemoria"][cEnsaio] := nInd

			If !lNovaMemoria .AND. (oMapaPosicoes["aAmostrasBanco"][cEnsaio] != Nil .OR. Self:nTotalAmostras == 0)
				Self:nTotalAmostras++
				lNovaMemoria := .T.
			EndIf
		EndIf
	Next nInd

	oMapaPosicoes["aEnsaiosCalculados"] := JsonObject():New()
	nTotal := Len(Self:aEnsaiosCalculados)
	For nInd := 1 to nTotal
		cEnsaio := AllTrim(Self:aEnsaiosCalculados[nInd]["testID"])
		oMapaPosicoes["aEnsaiosCalculados"][cEnsaio] := nInd
	Next nInd

Return oMapaPosicoes

/*/{Protheus.doc} ProcessaEnsaiosCalculados
Realiza o processamento dos ensaios calculados e retorna o array com os dados dos ensaios calculados
@author brunno.costa
@since  14/09/2022
@return Self:aEnsaiosCalculados, array, array com objetos Json contendo os itens calculados: 
{ [ testID, 
	letter, 
	formula, 
	arithmeticFormula,
	nominalValue, 
	quantity, 
	results], ...}

Sendo results Array com as Medições conforme quantidade de medições do ensaio
/*/
Method ProcessaEnsaiosCalculados() CLASS QIPEnsaiosCalculados

	Local cCarta      := Nil
	Local cEnsaio     := Nil
	Local cFormula    := Nil
	Local nCalculados := -1
	Local nInd        := 0
	Local nQtdMed     := 0
	Local nTotal      := Nil

	nTotal                  := Len(Self:aEnsaiosCalculados)
	For nInd                := 1 to nTotal
		nQtdMed             := Self:aEnsaiosCalculados[nInd]["quantity"]
		Self:aEnsaiosCalculados[nInd]["results"]            := {}
		Self:aEnsaiosCalculados[nInd]["arithmeticFormula"]  := {}
		For Self:nAmostraAtual := 1 to Self:nTotalAmostras
			aAdd(Self:aEnsaiosCalculados[nInd]["results"]          , Array(nQtdMed) )
			aAdd(Self:aEnsaiosCalculados[nInd]["arithmeticFormula"], Array(nQtdMed) )
		Next Self:nAmostraAtual
	Next nInd

	For Self:nAmostraAtual := 1 to Self:nTotalAmostras
		nCalculados := -1
		While nCalculados != Self:nCalculados
			nCalculados   := Self:nCalculados
			For nInd      := 1 to nTotal
				cEnsaio   :=            Self:aEnsaiosCalculados[nInd]["testID"]
				cCarta    :=            Self:aEnsaiosCalculados[nInd]["letter"]
				nQtdMed   :=            Self:aEnsaiosCalculados[nInd]["quantity"]
				cFormula  := AllTrim(   Self:aEnsaiosCalculados[nInd]["formula"] )
				nDecimal  := QA_NumDec( Self:aEnsaiosCalculados[nInd]["nominalValue"] )
				Self:ProcessaEnsaio(cEnsaio, cCarta, nQtdMed, cFormula, nDecimal)
			Next nInd
		EndDo
	Next

Return Self:aEnsaiosCalculados

/*/{Protheus.doc} ProcessaEnsaio
Realiza o processamento do ensaio especifico
@author brunno.costa
@since  14/09/2022
@param 01 - cEnsaio , caracter, código do ensaio relacionado
@param 02 - cCarta  , caracter, código da carta relacionada
@param 03 - nQtdMed , numérico, quantidade de medições do ensaio relacionado
@param 04 - cFormula, caracter, fórmula relacionada
@param 05 - nDecimal, numérico, quantidade de decimais relacionada ao valor nominal do ensaio
/*/
Method ProcessaEnsaio(cEnsaio, cCarta, nQtdMed, cFormula, nDecimal) CLASS QIPEnsaiosCalculados 

	Local cForArit := ""
	Local cFormAux := ""
	Local nIndMed  := 0
	Local nPosAvg  := 0
	Local nPosDes  := 0

	For nIndMed  := 1 to nQtdMed

		If !Self:MedicaoJaCalculada(cEnsaio, nIndMed)

			cFormAux := cFormula
			While Len(cFormAux)  > 0
				Self:ExisteDesvioPadraoEOuMediaAVG(cFormAux, @cForArit, @nPosDes, @nPosAvg)

				If At("#", cFormAux) == 0
					cForArit := cForArit + SubStr(cFormAux, 1, len(cFormAux))
					Exit
				Endif

				If nPosDes > 0
					Self:ProcessaDesvioPadrao(@cFormAux, @cForArit, nPosDes)
				ElseIf nPosAvg > 0
					Self:SubstituiMediaPorResultado(@cFormAux, @cForArit, nDecimal, nPosAvg, nIndMed, nQtdMed)
				Else
					Self:SubstituiEnsaiosPorResultados(cFormula, @cForArit, nIndMed)
					cFormAux := ""
					Exit
				EndIf
			EndDo

			If !Empty(cForArit)
				If At("#", cForArit) == 0
					Self:CalculaFormulaAritmetica(cEnsaio, cForArit, nDecimal, nIndMed)
				EndIf
			Endif
			cForArit := ""

		EndIf

	Next nIndMed
Return

/*/{Protheus.doc} ExisteDesvioPadraoEOuMediaAVG
Valida existência de Desvio Padrão E/OU Média na fórmula e ajusta cForArit
@author brunno.costa
@since  14/09/2022
@param 01 - cFormAux, caracter, string de fórmula para checagem da existência de Desvio Padrão E/OU Média
@param 02 - cForArit, caracter, retorna por referência atualização da fórmula aritmética de processamento
@param 03 - nPosDes , numérico, retorna posição do Desvio Padrão na fórmula
@param 04 - nPosAvg , numérico, retorna posição da Média na fórmula
/*/
Method ExisteDesvioPadraoEOuMediaAVG(cFormAux, cForArit, nPosDes, nPosAvg) CLASS QIPEnsaiosCalculados

	Local nPosCalc := Nil

	nPosDes := At("DESVPAD", cFormAux) //Posicao do calculo do Desvio Padrao
	nPosAvg := At("AVG", cFormAux)     //Posicao do calculo da Media

	If nPosDes > 0 .And. nPosAvg > 0
		nPosAvg := Iif(nPosDes < nPosAvg, 0, nPosAvg)
		nPosDes := Iif(nPosDes < nPosAvg, nPosDes, 0)
	Endif

	If nPosDes  > 0 .Or. nPosAvg  > 0
		nPosCalc := Iif(nposDes > 0, nPosDes, nPosAvg)
		If nPosCalc > 1
			cForArit := cForArit + SubStr(cFormAux, 1, nPosCalc-2) + SubStr(cFormAux, nPosCalc-1, 1)
		Endif
	Endif

Return

/*/{Protheus.doc} ProcessaDesvioPadrao
Realiza processamento do Desvio Padrão para Ensaios Calculados
@author brunno.costa
@since  14/09/2022
@param 01 - cFormAux, caracter, retorna por referência atualização da fórmula base com as pendências de processamento
@param 02 - cForArit, caracter, retorna por referência atualização da fórmula aritmética de processamento
@param 03 - nPosDes , numérico, posição do Desvio Padrão na fórmula cFormAux
/*/
Method ProcessaDesvioPadrao(cFormAux, cForArit, nPosDes) CLASS QIPEnsaiosCalculados  
	
	//Local aResult := Nil
	//Local cEnsCal := Nil
	Local cDesvio := "1"
	Local cForAux := ""
	Local nPosFor := Nil

	cForAux := cFormAux
	cForAux := Stuff(cForAux, 1, nPosDes + 7, Space(nPosDes + 7))
	nPosFor := At("#", cForAux)
	//cEnsCal := SubStr(cForAux, nPosFor + 1, 8)

	//Realiza o Calcula do Desvio Padrao
	//aResult := QP215DesPad(nPosOper, nPosLab, nPosEnsa, cEnsCal, (cCarta == "TMP"))
	//aResult := Self:CalculaDesvioPadrao()
	//cDesvio := aResult[nIndMed]
	cForArit := cForArit + cDesvio
	cForArit := cForArit + SubStr(cForAux, nPosFor + 11, 1)
	cFormAux := SubStr(cFormAux, nPosFor + 12, len(cFormAux))

Return

/*/{Protheus.doc} SubstituiMediaPorResultado
Realiza processamento da Média para Ensaios Calculados
@author brunno.costa
@since  14/09/2022
@param 01 - cFormAux, caracter, retorna por referência atualização da fórmula base com as pendências de processamento
@param 02 - cForArit, caracter, retorna por referência atualização da fórmula aritmética de processamento
@param 03 - nDecimal, numérico, quantidade de decimais relacionada ao valor nominal do ensaio
@param 04 - nPosAvg , numérico, posição da Média na fórmula cFormAux
@param 05 - nIndMed , numérico, referência da medição relacionada ao ensaio para substituição
@param 06 - nQtdMed , numérico, quantidade de medições do ensaio relacionado
/*/
Method SubstituiMediaPorResultado(cFormAux, cForArit, nDecimal, nPosAvg, nIndMed, nQtdMed) CLASS QIPEnsaiosCalculados

	Local cEnsCal    := Nil
	Local cForAux    := ""
	Local nMedia     := Nil
	Local nPosFor    := Nil

	cForAux := cFormAux
	cForAux := Stuff(cForAux, 1, nPosAvg + 3, Space(nPosAvg + 3))
	nPosFor := At("#", cForAux)
	cEnsCal := SubStr(cForAux, nPosFor + 1, 8)

	nMedia := Iif(Self:oMedias[cEnsCal] != Nil, Self:oMedias[cEnsCal][nIndMed], nMedia)
	If nMedia == NIL
		Self:CalculaMediasEnsaio(cEnsCal, nQtdMed, nDecimal)
		nMedia := Self:oMedias[cEnsCal][nIndMed]
	EndIf
	
	If nMedia <> Nil
		cForArit := cForArit + StrTran(Str(nMedia, Self:nQPS_MEDICA, nDecimal), ".", ", ")
		cForArit := cForArit + SubStr(cForAux, nPosFor + 11, 1)
	EndIf
	cFormAux := SubStr(cFormAux, nPosFor + 12, Len(cFormAux))

Return

/*/{Protheus.doc} CalculaMediasEnsaio
Calcula Médias do Ensaio
@author brunno.costa
@since  14/09/2022
@param 01 - cEnsaio , caracter, código do ensaio relacionado
@param 02 - nQtdMed , numérico, quantidade de medições do ensaio relacionado
@param 03 - nDecimal, numérico, quantidade de decimais relacionada ao valor nominal do ensaio
/*/
Method CalculaMediasEnsaio(cEnsaio, nQtdMed, nDecimal) CLASS QIPEnsaiosCalculados

	Local nBkpAmostra := Self:nAmostraAtual
	Local nMedicao    := Nil
	Local xResultado  := Nil

	Default nQtdMed  := 1
	Default nDecimal := 0

	If Self:oMedias[cEnsaio] == Nil
		Self:oMedias[cEnsaio]        := {}
		Self:oSomasAmostras[cEnsaio] := {}
	EndIf

	For nMedicao := 1 to nQtdMed
		aAdd(Self:oMedias[cEnsaio]         , Nil)
		aAdd(Self:oSomasAmostras[cEnsaio], 0  )
	Next nMedicao

	For Self:nAmostraAtual := 1 to Self:nTotalAmostras
		For nMedicao := 1 to nQtdMed
			xResultado := Self:RetornaResultadoEnsaio(cEnsaio, nMedicao)
			If At("#", xResultado)
				Self:oSomasAmostras[cEnsaio][nMedicao] := Nil
			Else
				Self:oSomasAmostras[cEnsaio][nMedicao] := Iif(Self:oSomasAmostras[cEnsaio][nMedicao] == Nil, 0, Self:oSomasAmostras[cEnsaio][nMedicao])
				Self:oSomasAmostras[cEnsaio][nMedicao] += Iif( Valtype(xResultado) == "N"                      ,;
                                                                 Round(xResultado,                      nDecimal),;
                                                                 Round(Val(StrTran(xResultado,",",".")),nDecimal))
			EndIf
		Next nMedicao
	Next Self:nAmostraAtual

	For nMedicao := 1 to nQtdMed
		If Self:oSomasAmostras[cEnsaio][nMedicao] != Nil
			Self:oMedias[cEnsaio][nMedicao] := Round(Self:oSomasAmostras[cEnsaio][nMedicao] / Self:nTotalAmostras, nDecimal)
		EndIf
	Next

	Self:nAmostraAtual := nBkpAmostra

Return

/*/{Protheus.doc} SubstituiEnsaiosPorResultados
Substitui Ensaios por Resultados na Formula Aritmética
@author brunno.costa
@since  14/09/2022
@param 01 - cFormula, caracter, fórmula do ensaio para referência da substituição dos ensaios pelos resultados
@param 02 - cForArit, caracter, retorna por referência atualização da fórmula aritmética de processamento
@param 03 - nIndMed , numérico, referência da medição relacionada ao ensaio para substituição
/*/
Method SubstituiEnsaiosPorResultados(cFormula, cForArit, nIndMed) CLASS QIPEnsaiosCalculados

	Local cEnsaio   := Nil
	Local cForAux   := cFormula
	Local nCaracter := 0
	Local nPosFor   := Nil
	Local nTotal    := Nil

	nTotal  := Len(cForAux)
	For nCaracter := 1 to nTotal
		nPosFor    := At("#", cForAux)
		If nPosFor == 0
			Exit
		EndIF
		cEnsaio   := Padr(SubStr(cForAux, nPosFor + 1, 8), 8)
		If Empty(cForArit)
			cForArit  := Self:SubstituiEnsaioPorResultado(cForAux, cEnsaio, nIndMed)
		Else
			cForArit  := Self:SubstituiEnsaioPorResultado(cForArit, cEnsaio, nIndMed)
		EndIf
		cForAux   := Stuff(cForAux, 1, nPosFor + 10, Space(nPosFor + 10))
		nCaracter := (nPosFor + 10)
	Next nCaracter

Return

/*/{Protheus.doc} SubstituiEnsaioPorResultado
Substitui Ensaio por Resultado na Formula Aritmética
@author brunno.costa
@since  14/09/2022
@param 01 - cForArit, caracter, retorna por referência atualização da fórmula aritmética de processamento
@param 02 - cEnsaio , caracter, código do ensaio para substituição
@param 03 - nIndMed , numérico, referência da medição relacionada ao ensaio para substituição
/*/
Method SubstituiEnsaioPorResultado(cForArit, cEnsaio, nIndMed) CLASS QIPEnsaiosCalculados
Return StrTran(cForArit, "#"+cEnsaio+"#", Self:RetornaResultadoEnsaio(cEnsaio, nIndMed))

/*/{Protheus.doc} RetornaResultadoEnsaio
Retorna resultado do ensaio na medição
@author brunno.costa
@since  14/09/2022
@param 01 - cEnsaio , caracter, código do ensaio para checagem do resultado do resultado
@param 02 - nIndMed , numérico, referência da medição relacionada ao ensaio para checagem do resultado
@return cResultado, string, resultado do cálculo
/*/
Method RetornaResultadoEnsaio(cEnsaio, nIndMed) CLASS QIPEnsaiosCalculados

	Local cEnsAux    := AllTrim(cEnsaio)
	Local cResultado := Nil
	Local nIndEnsaio := Nil
	
	nIndEnsaio := Self:oMapaPosicoes["aEnsaiosCalculados"][cEnsAux]
	cResultado := Iif(cResultado == Nil .AND. nIndEnsaio != Nil,;
	              Self:aEnsaiosCalculados[nIndEnsaio]["results"][Self:nAmostraAtual][nIndMed],;
				  cResultado)

	If Self:nAmostraAtual == Self:nTotalAmostras
		nIndEnsaio := Self:oMapaPosicoes["aAmostrasMemoria"][cEnsAux]
		cResultado := Iif(cResultado == Nil .AND. nIndEnsaio != Nil .AND. Len(Self:aAmostrasMemoria[nIndEnsaio]["measurements"]) >= nIndMed,;
					Self:aAmostrasMemoria[nIndEnsaio]["measurements"][nIndMed],;
					cResultado)
	EndIf

	nIndEnsaio := Iif(Self:oMapaPosicoes["aAmostrasBanco"][cEnsAux] != Nil .AND. Self:nAmostraAtual <= Len(Self:oMapaPosicoes["aAmostrasBanco"][cEnsAux]),;
				  Self:oMapaPosicoes["aAmostrasBanco"][cEnsAux][Self:nAmostraAtual],;
				  Nil)
	
	If cResultado == Nil .AND. nIndEnsaio != Nil .AND. Self:oMapaPosicoes["aEnsaiosCalculados"][cEnsAux] == Nil .AND. Len(Self:aAmostrasBanco[nIndEnsaio]["measurements"]) >= nIndMed
		cResultado := Self:aAmostrasBanco[nIndEnsaio]["measurements"][nIndMed]
	EndIf

	cResultado := Iif(cResultado == Nil, "#"+cEnsaio+"#", cResultado)

Return cResultado

/*/{Protheus.doc} CalculaFormulaAritmetica
Realiza processamento do cálculo da fórmula aritmética
@author brunno.costa
@since  14/09/2022
@param 01 - cEnsaio , caracter, código do ensaio relacionado
@param 02 - cForArit, caracter, fórmula aritmética para cálculo
@param 03 - nDecimal, numérico, quantidade de decimais relacionada ao valor nominal do ensaio
@param 04 - nIndMed , numérico, referência da medição relacionada ao ensaio
/*/
METHOD CalculaFormulaAritmetica(cEnsaio, cForArit, nDecimal, nIndMed) CLASS QIPEnsaiosCalculados

	Local cEnsErro   := Nil
	Local cError     := Nil
	Local cFormuErro := Nil
	Local cTitHelp   := Nil
	Local nCalc      := 0
	Local nIndEnsaio := Self:oMapaPosicoes["aEnsaiosCalculados"][AllTrim(cEnsaio)]
	Local oLastError := ErrorBlock({|e| cError := (e:Description)} )

	nCalc          := &(StrTran(StrTran(cForArit, ",", "."), ", ", "."))
	ErrorBlock(oLastError)
	If Empty(cError)
		Self:nCalculados++
	Else
		cEnsErro   := AllTrim(cEnsaio)                                                //Código do Ensaio
		cFormuErro := AllTrim(cForArit)                                               //Fórmula com erro
		cTitHelp   := AllTrim(ProcName()  + " - " + cValToChar(ProcLine()))           //Nome da função - Linha do erro
		//"Erro no processamento da fórmula do ensaio " ### "Verifique a fórmula: " ### ", do ensaio: " ### "Erro: "
		//STR0001 ### STR0002 ### STR0003 ### STR0004
		Help(NIL, NIL, cTitHelp, NIL, STR0001 + cEnsErro + ".", 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0002 + cFormuErro + STR0003 + cEnsaio + "." + CHR(13) + CHR(10) +  STR0004 + cError})
		Break
	EndIf
	
	Self:aEnsaiosCalculados[nIndEnsaio]["results"][Self:nAmostraAtual][nIndMed]           := StrTran(Str(nCalc, Self:nQPS_MEDICA, nDecimal), ".", ",")
	Self:aEnsaiosCalculados[nIndEnsaio]["arithmeticFormula"][Self:nAmostraAtual][nIndMed] := cForArit

Return

/*/{Protheus.doc} MedicaoJaCalculada
Indica se a Medição Já Foi Calculada
@author brunno.costa
@since  14/09/2022
@param 01 - cEnsaio , caracter, código do ensaio relacionado
@param 02 - nIndMed , numérico, referência da medição relacionada ao ensaio
/*/
Method MedicaoJaCalculada(cEnsaio, nIndMed) CLASS QIPEnsaiosCalculados
	Local cResultado := Self:RetornaResultadoEnsaio(cEnsaio, nIndMed)
	Local lCalculado := At("#", cResultado) == 0
Return lCalculado

/*/{Protheus.doc} PersisteEnsaiosCalculados
Reprocessa Ensaios Calculados e Salva no Banco de Dados
@author brunno.costa
@since  26/09/2022
@param 01 - oItemAPI , objeto, referência de item da API de ResultadosEnsaiosInspecaoDeProcessosAPI
@param 02 - lProcessa, objeto, indica se deve executar o método ProcessaEnsaiosCalculados()
@return lSucesso, lógico, indica se obteve sucesso na persistência dos resultados:
                        .T. = gravou ensaios calculados
                        .F. = não gravou ensaios calculados
/*/
Method PersisteEnsaiosCalculados(oItemAPI, lProcessa) CLASS QIPEnsaiosCalculados

	Local aRecnosQPR  := {}
	Local cFormula    := Nil
	Local lSucesso    := .F.
	Local nAmostras   := Nil
	Local nEnsaios    := Nil
	Local nIndAmostra := Nil
	Local nIndEnsaio  := Nil
	Local nMedicoes   := Nil
	Local nPosAvg     := 0
	Local nPosDes     := 0
	Local oDadosJson  := JsonObject():New()

	Default lProcessa := .T.

	If lProcessa
		Self:ProcessaEnsaiosCalculados()
	EndIf
	nEnsaios    := Len(Self:aEnsaiosCalculados)
	If nEnsaios > 0
		oDadosJson['items'] := {}
		nAmostras      := Len(Self:aEnsaiosCalculados[1]['results'])
		For nIndEnsaio := 1 to nEnsaios
			For nIndAmostra := 1 to nAmostras
				cFormula := Self:aEnsaiosCalculados[nIndEnsaio]["formula"]
				Self:ExisteDesvioPadraoEOuMediaAVG(cFormula, cFormula, @nPosDes, @nPosAvg)
				If (nPosDes + nPosAvg) == 0 .OR. nIndAmostra == 1	
					nMedicoes := Len(Self:aEnsaiosCalculados[nIndEnsaio]['results'][nIndAmostra])
					Self:TrataRegistroParaInclusao(@oDadosJson, oItemAPI, nIndEnsaio, nIndAmostra, nMedicoes)
				EndIf
			Next nIndAmostra
		Next nIndEnsaio

		If Len(oDadosJson['items']) > 0
			lSucesso := Self:oAPIResultados:ProcessaItensRecebidos(@oDadosJson, @aRecnosQPR)
		EndIf
	EndIf

Return lSucesso

/*/{Protheus.doc} ExcluiMedicoesCalculadas
Exclui Medições Calculadas Quando Não Existir Amostra Referência Válida
@author brunno.costa
@since  26/09/2022
@param 01 - cUsuario, caracter, indica o usuário que realiza e exclusão
/*/
Method ExcluiMedicoesCalculadas(cUsuario) CLASS QIPEnsaiosCalculados

	Local cEnsAux     := Nil
	Local nAmostras   := Nil
	Local nEnsaios    := Nil
	Local nIndAmostra := Nil
	Local nIndEnsaio  := Nil
	Local nIndEnsBco  := Nil
	Local oItemAPI    := JsonObject():New()

	Self:ProcessaEnsaiosCalculados()
	nEnsaios    := Len(Self:aEnsaiosCalculados)
	If nEnsaios > 0
		nAmostras      := Len(Self:aEnsaiosCalculados[1]['results'])
		For nIndEnsaio := 1 to nEnsaios
			For nIndAmostra := 1 to nAmostras
				cEnsAux        := AllTrim(Self:aEnsaiosCalculados[nIndEnsaio][ 'testID' ])
				If Self:oMapaPosicoes["aAmostrasBanco"][cEnsAux] != Nil .And. nIndAmostra <= Len(Self:oMapaPosicoes["aAmostrasBanco"][cEnsAux])
					nIndEnsBco := Self:oMapaPosicoes["aAmostrasBanco"][cEnsAux][nIndAmostra]
					If nIndEnsBco != Nil .AND. Self:aEnsaiosCalculados[nIndEnsaio]['results'][nIndAmostra][1] == Nil
						Self:oAPIResultados:DeletaAmostraSemResponse(Self:aAmostrasBanco[nIndEnsBco]["recno"])
					EndIf
				EndIf
			Next nIndAmostra
		Next nIndEnsaio
	EndIf

	oItemAPI['protheusLogin'] := cUsuario
	oItemAPI['rehearser']     := cUsuario //Não precisa recuperar o nome do usuário, basta passar conteúdo para não validar na API
	oItemAPI['testType']      := "N"
	Self:PersisteEnsaiosCalculados(oItemAPI, .F.)

Return

/*/{Protheus.doc} TrataRegistroParaInclusao
Trata Registro Calculado para Inclusão / Atualização no Banco de Dados
@author brunno.costa
@since  26/09/2022
@param 01 - oDadosJson , objeto  , retorna por referência objeto JSON com os dados dos ensaios calculados
@param 02 - oItemAPIX  , objeto  , referência de item da API de ResultadosEnsaiosInspecaoDeProcessosAPI
@param 03 - nIndEnsaio , numérico, indicador do ensaio atual
@param 04 - nIndAmostra, numérico, indicador da amostra atual
@param 05 - nMedicoes  , numérico, indicador da quantidade de medições do ensaio
/*/
METHOD TrataRegistroParaInclusao(oDadosJson, oItemAPIX, nIndEnsaio, nIndAmostra, nMedicoes) CLASS QIPEnsaiosCalculados

	Local cEnsAux        := AllTrim(Self:aEnsaiosCalculados[nIndEnsaio][ 'testID' ])
	Local lTodasMedicoes := .T.
	Local nIndEnsBco     := Nil
	Local nIndMedicao    := Nil
	Local oItemAPI       := JsonObject():New()

	oItemAPI:fromJson(oItemAPIX:toJson())
	oItemAPI["measurements"] := {}
	For nIndMedicao := 1 to nMedicoes
		nIndEnsBco := Iif(Self:oMapaPosicoes["aAmostrasBanco"][cEnsAux] != Nil .AND. nIndAmostra <= Len(Self:oMapaPosicoes["aAmostrasBanco"][cEnsAux]),;
				          Self:oMapaPosicoes["aAmostrasBanco"][cEnsAux][nIndAmostra],;
				          Nil)
		If Self:aEnsaiosCalculados[nIndEnsaio]['results'][nIndAmostra][nIndMedicao] != Nil
			aAdd(oItemAPI["measurements"], Self:aEnsaiosCalculados[nIndEnsaio]['results'][nIndAmostra][nIndMedicao])
		ElseIf nIndEnsBco != Nil .AND. Len(Self:aAmostrasBanco[nIndEnsBco]["measurements"]) >= nIndMedicao
			aAdd(oItemAPI["measurements"], Self:aAmostrasBanco[nIndEnsBco]["measurements"][nIndMedicao])
		Else
			lTodasMedicoes := .F.
		EndIf
	Next nIndMedicao

	If lTodasMedicoes
		oItemAPI["recnoInspection"] := Self:nRecnoInspecao
		oItemAPI["recnoTest"]       := Self:aEnsaiosCalculados[nIndEnsaio]['recnoTest']
		oItemAPI["testID"]          := cEnsAux
		oItemAPI["measurementDate"] := Self:oAPIResultados:oAPIManager:formataDado("D", dDataBase, "2", 8, 0)
		oItemAPI["measurementTime"] := Substr(Time(), 1, 5)
		oItemAPI["protheusLogin"]   := Iif(oItemAPI["protheusLogin"] == Nil, "ADMINISTRADOR", oItemAPI["protheusLogin"])
		oItemAPI["textStatus"]      := Self:RetornaStatusAprovacaoArray(oItemAPI["measurements"],;
                                                                        Self:aEnsaiosCalculados[nIndEnsaio]['controlType'],;
                                                                        Self:aEnsaiosCalculados[nIndEnsaio]['lowerDeviation'],;
                                                                        Self:aEnsaiosCalculados[nIndEnsaio]['upperDeviation'],;
																		nMedicoes)
		oItemAPI["QPR_CHAVE"]       := Nil
		oItemAPI["recno"]           := 0

		If Self:oMapaPosicoes["aAmostrasBanco"][cEnsAux] != Nil .AND. nIndAmostra <= Len(Self:oMapaPosicoes["aAmostrasBanco"][cEnsAux])
			nIndEnsBco := Self:oMapaPosicoes["aAmostrasBanco"][cEnsAux][nIndAmostra]
			If nIndEnsBco != Nil
				oItemAPI["recno"]   := Self:aAmostrasBanco[nIndEnsBco]["recno"]
			EndIf
		EndIf

		aAdd(oDadosJson['items'], oItemAPI)
	EndIf

Return

/*/{Protheus.doc} RetornaStatusAprovacao
Retorna Status de Aprovação do Valor da Medição com Base no Controle e Limites Inferior e Superior
@author brunno.costa
@since  28/09/2022
@param 01 - cValor   , caracter, valor de referência para análise do status
@param 02 - cControle, caracter, tipo de controle (QP7_MINMAX)
@param 03 - cInferior, caracter, valor de limite inferior (QP7_LIE)
@param 04 - cSuperior, caracter, valor de limite superior (QP7_LSE)
@return cStatus, caracter, status de controle de aprovação da medição:
                           A = Aprovado  - Dentro dos Limites de Controle
                           R = Reprovado - Fora dos Limites de Controle
/*/
METHOD RetornaStatusAprovacao(cValor, cControle, cInferior, cSuperior) CLASS QIPEnsaiosCalculados

	Local cError     := Nil
	Local cStatus    := "R"
	Local cTitHelp   := Nil
	Local nInferior  := Nil
	Local nSuperior  := Nil
	Local nValor     := Nil
	Local oLastError := ErrorBlock({|e| cError := (e:Description)} )

	If     cControle == "1" //Controle Inferior e Superior
		nValor     := Val(StrTran(cValor, ",", "."))
		nInferior  := Val(StrTran(cInferior, ",", "."))
		nSuperior  := Val(StrTran(cSuperior, ",", "."))
		cStatus    := IIf( nInferior <= nValor .And. nValor <= nSuperior, "A", "R")
	ElseIf cControle == "2" //Controle Inferior
		nValor     := Val(StrTran(cValor, ",", "."))
		nInferior  := Val(StrTran(cInferior, ",", "."))
		cStatus    := IIf( nInferior <= nValor, "A", "R")
	ElseIf cControle == "3" //Controle Superior
		nValor     := Val(StrTran(cValor, ",", "."))
		nSuperior  := Val(StrTran(cSuperior, ",", "."))
		cStatus    := IIf( nValor <= nSuperior, "A", "R")
	EndIf
	ErrorBlock(oLastError)

	If !Empty(cError)
		cTitHelp   := AllTrim(ProcName()  + " - " + cValToChar(ProcLine()))           //Nome da função - Linha do erro
		//STR0005 - "Falha na avaliação do Status de Aprovação."
		//STR0006 - "Verifique os valores e parâmetros de controle."
		//STR0004 - "Erro: "
		Help(NIL, NIL, cTitHelp, NIL, STR0005, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0006 + CHR(13) + CHR(10) +  STR0004 + cError})
		Break
	EndIf

Return cStatus

/*/{Protheus.doc} RetornaStatusAprovacaoArray
Retorna Status de Aprovação dos Valores de Medições com Base no Controle e Limites Inferior e Superior
@author brunno.costa
@since  28/09/2022
@param 01 - aMedicoes, array   , array de valores de referência para análise do status
@param 02 - cControle, caracter, tipo de controle (QP7_MINMAX)
@param 03 - cInferior, caracter, valor de limite inferior (QP7_LIE)
@param 04 - cSuperior, caracter, valor de limite superior (QP7_LSE)
@param 04 - nMedicoes, numérico, quantidade de medições para checagem no array
@return cStatus, caracter, status de controle de aprovação da medição:
                           A = Aprovado  - Dentro dos Limites de Controle
                           R = Reprovado - Fora dos Limites de Controle
/*/
METHOD RetornaStatusAprovacaoArray(aMedicoes, cControle, cInferior, cSuperior, nMedicoes) CLASS QIPEnsaiosCalculados

	Local cAux    := Nil
	Local cStatus := "A"
	Local nIndMed := Nil

	Default nMedicoes := Len(aMedicoes)

	For nIndMed := 1 to nMedicoes
		cAux    := Self:RetornaStatusAprovacao(aMedicoes[nIndMed], cControle, cInferior, cSuperior)
		cStatus := Iif(cStatus == "A", cAux, cStatus)
	Next nIndMed

Return cStatus

/*/{Protheus.doc} QIPENSCALP
Processa Persistência de Ensaios Calculados
@author brunno.costa
@since  28/09/2022
@param 01 - cEmpAux  , caracter  , grupo de empresa para abertura do ambiente
@param 02 - cFilAux  , caracter  , filial para abertura do ambiente
@param 03 - nRecnoQPK, número    , recno do registro na QPK para processamento dos ensaios calculados
@param 04 - cItemJson, jsonString, string Json com o Item da API referência para atualização dos Ensaios Calculados
/*/
Function QIPENSCALP(cEmpAux, cFilAux, nRecnoQPK, cItemJson)
	Local lAmbiente             := .F.
	Local oQIPEnsaiosCalculados := Nil
	Local oItemAPI              := Nil
    RPCSetType(3)
    lAmbiente := RpcSetEnv(cEmpAux, cFilAux)
	If lAmbiente
		oItemAPI := JsonObject():New()
		oItemAPI:fromJson(cItemJson)
		oQIPEnsaiosCalculados := QIPEnsaiosCalculados():New(nRecnoQPK, {})
		oQIPEnsaiosCalculados:PersisteEnsaiosCalculados(oItemAPI)
	EndIf
	RpcClearEnv()
Return 


/*/{Protheus.doc} QIPENSCALE
Processa Exclusão de Medições Calculadas
@author brunno.costa
@since  28/09/2022
@param 01 - cEmpAux  , caracter, grupo de empresa para abertura do ambiente
@param 02 - cFilAux  , caracter, filial para abertura do ambiente
@param 03 - cChaveQPK, caracter, chave do registro na QPK
@param 04 - cUsuario , caracter, usuário que realizou a exclusão para atualização dos ensaios calculados
/*/
Function QIPENSCALE(cEmpAux, cFilAux, cChaveQPK, cUsuario)
	Local lAmbiente             := .F.
	Local nRecnoQPK             := 0
	Local oQIPEnsaiosCalculados := Nil
    RPCSetType(3)
    lAmbiente := RpcSetEnv(cEmpAux, cFilAux)
	If lAmbiente
		QPK->(DbSetOrder(1))
		If QPK->(DbSeek(xFilial("QPK")+cChaveQPK))
			nRecnoQPK := QPK->(Recno())
		EndIf
		oQIPEnsaiosCalculados := QIPEnsaiosCalculados():New(nRecnoQPK, {})
		oQIPEnsaiosCalculados:ExcluiMedicoesCalculadas(cUsuario)
	EndIf
	RpcClearEnv()
Return 
