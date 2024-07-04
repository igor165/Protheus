#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'


Class NB

	DATA nIncrBarra AS NUMBER 
	DATA p          AS Array
	DATA pontos     AS Array
	DATA pontosa    AS Array
	DATA xa         AS Array
	DATA ya         AS Array

	METHOD New()
	METHOD getNB()
	METHOD normalize()
	METHOD getValues()
	METHOD getDistrib()
	METHOD getValuesList()
	METHOD getDisList()
	METHOD getDesvPad()
	METHOD mediasNB()
	METHOD findPosCol(aMedicoes, aCorte)
	METHOD findPosLim(aMedicoes, aCorte, aLimites)


EndClass


METHOD New(aPontos) CLASS NB
	Local desviopadrao
	Local nI
	Local media  := ::mediasNB(aPontos)[2]
	Local aCopPon := {}
	::pontos   := {}
	/*::pontos := {0.28019, 0.320185, 0.36018, 0.400175, 0.44017, 0.480165, 0.52016, 0.560155, 0.60015,;
			   	 0.640145, 0.68014, 0.720135, 0.76013, 0.800125, 0.84012, 0.880115, 0.92011, 0.960105, 1.0001, 1.040095,;
			   	 1.08009, 1.120085, 1.16008, 1.200075, 1.24007, 1.280065, 1.32006, 1.360055, 1.40005, 1.440045, 1.48004,;
			   	 1.520035, 1.56003, 1.600025, 1.64002, 1.680015, 1.72001, 1.760005, 1.8, 1.839995, 1.87999, 1.919985,;
			   	 1.95998, 1.999975, 2.03997, 2.079965, 2.11996, 2.159955, 2.19995, 2.239945, 2.27994, 2.319935, 2.35993,;
			   	 2.399925, 2.43992, 2.479915, 2.51991, 2.559905, 2.5999, 2.639895, 2.67989, 2.719885, 2.75988, 2.799875,;
			   	 2.83987, 2.879865, 2.91986, 2.959855, 2.99985, 3.039845, 3.07984, 3.119835, 3.15983, 3.199825, 3.23982,;
			   	 3.279815, 3.31981, 3.359805, 3.3998, 3.439795, 3.47979, 3.519785, 3.55978, 3.599775, 3.63977, 3.679765,;
			   	 3.71976, 3.759755, 3.79975, 3.839745, 3.87974, 3.919735, 3.95973, 3.999725, 4.03972, 4.079715, 4.11971,;
			   	 4.159705, 4.1997, 4.239695, 4.27969, 4.319685, 4.35968, 4.399675, 4.43967, 4.479665, 4.51966, 4.559655,;
			   	 4.59965, 4.639645, 4.67964, 4.719635, 4.75963, 4.799625, 4.83962, 4.879615, 4.91961, 4.959605, 4.9996,;
			   	 5.039595, 5.07959, 5.119585, 5.15958, 5.199575, 5.23957, 5.279565, 5.31956, 5.359555, 5.39955, 5.439545,;
			   	 5.47954, 5.519535, 5.55953, 5.599525, 5.63952, 5.679515, 5.71951, 5.759505, 5.7995 }*/
	::xa      := {}
	::ya      := {}
	::pontosa := {}
	::p       := {}
	
	aCopPon := Aclone(aPontos)

    aColAux := ASORT(aCopPon,,, { |x, y| x > y } )
    nMax    := aCopPon[1]
    aColAux := ASORT(aCopPon,,, { |x, y| x < y } )
    nMin    := aCopPon[1]

	desviopadrao := ::getDesvPad(aCopPon)
	mediamaior   := media + (desviopadrao * 4)
	mediamenor   := media - (desviopadrao * 4)
	incremento   := (mediamaior - mediamenor)/(200-1)
	//VERIFICAR COM O IVO SE SERÃ 20 FIXO (ESTIMATIVA CLASSES DA PLANILHA) - PARTE 1/2
	nEstClasses  := 20
	::nIncrBarra   := (nMax - nMin) / nEstClasses

	nPonto := nMin

	For nI := 1 to 30

  		If nI == 1
			nPonto := nMin
		Else
			nPonto += ::nIncrBarra
		EndIf
		

		AADD(::pontos,nPonto)
	Next

Return

METHOD getNB(aPontos) CLASS NB
Local l     := {}
Local nI    := 0
Local q     := {}
Local SD    := ::getDesvPad(aPontos) //1.6655048244534683
Local x_avg := ::mediasNB(aPontos)[2] //2.555255555555556
Local x_t   := {}

	For nI := 1 to Len(::pontos)
		//AADD(x_t, nI)
		AADD(x_t, ::pontos[nI])
	Next

	xt := aClone(x_t)

	::p := Array(Len(xt)) // density probability of normal distriobution
	l   := Array(Len(xt)) // temporary data
	q   := Array(Len(xt)) // temporary data

	For nI := 1 to Len(x_t)
		l[nI] := (xt[nI] - x_avg) / SD
		q[nI] := -0.5 * (l[nI] ^ 2.0)
		::p[nI] := ((1.0) / ((SD * (         (2.0 * 3.141592653589793) ^ (0.5)))) * (2.718281828459045 ^ q[nI]))
			     //((1.0) / ((SD * (Math.pow((2.0 * Math.PI          ), (0.5))))) * (Math.pow((Math.E), (q[h]))));
		AADD(::pontosa,::p[nI])
	Next

Return

METHOD normalize() CLASS NB
	Local nI    := 0
	Local x_t   := {}
	Local x_avg := 2.555255555555556
	Local SD    := 1.6655048244534683
	
	xt := aClone(x_t)

	::p := Array(Len(xt)) // density probability of normal distribution
	l   := Array(Len(xt)) // temporary data
	q   := Array(Len(xt)) // temporary data

	For nI := 0 to -19 Step -1
		l[nI] := (xt[nI] - x_avg) / SD
		q[nI] := -0.5 * (l[nI] ^ 2.0)
		::p[nI] := ((1.0) / ((SD * ((2.0 * 3.141592653589793) ^ (0.5)))) * ((2.718281828459045) ^ (q[nI])))
		//System.out.println(p[h]);
	Next
Return


METHOD getValues() CLASS NB
Return ::pontos

METHOD getDistrib() CLASS NB
Return ::p

METHOD getValuesList() CLASS NB
	Local nI
	Local d
	
	For nI := 1 to Len(::pontos)
		d := ::pontos[nI]
		AADD(xa,d)
	Next

Return xa


METHOD getDisList() CLASS NB
	Local nI := 0
	Local d
	
	For nI := 1 to Len(::p)
		d := ::p
		AADD(ya,d)
	Next

Return ya

/*/{Protheus.doc} getDesvPad
Retorna o desvio padrão das medições
@author marcos.wagner / rafael.kleestadt
@since 08/07/2020
@version 1.1
@param aPontos, array, medições 
@return nDesvioP, number, desvio padrão das medições
/*/
METHOD getDesvPad(aPontos) CLASS NB
Local nX         := 0
Local nAcumula   := 0
Local nVariancia := 0
Local nDesvioP   := 0
Local nMedia     := 0
Local nQtdPontos := Len(aPontos)
	 
	For nX:=1 to nQtdPontos
		nAcumula:=nAcumula+aPontos[nX]
	next     
	
	nMedia := nAcumula/nQtdPontos
	nAcumula := 0
	
	For nX := 1 to nQtdPontos
		nAcumula := nAcumula + (aPontos[nX]-nMedia)^2
	next
	     
	nVariancia := 1/(nQtdPontos-1) * nAcumula
	nDesvioP := nVariancia^(1/2)
	
Return nDesvioP

/*/{Protheus.doc} mediasNB
Retorna o menor valor, a media e o maior valor de um array de numeros
@author rafael.kleestadt
@since 08/07/2020
@version 1.0
@param aPontos, array, array contendo os valores a serem verificados
@return aRet, array, vetor contendo o menor, a media e o maior valor do array recebido por parametro
/*/
METHOD mediasNB(aPontos) CLASS NB
Local nX      := 0
Local nSoma   := 0
Local nMedia  := 0
Local nMaior  := 0
Local nMenor  := 0
Local aRet    := {}
Local aCopPon := {}

aCopPon := Aclone(aPontos)

ASORT(aCopPon,,, { |x, y| x > y } )
nMaior  := aCopPon[1]
nMenor  := aCopPon[LEN(aCopPon)]

For nX := 1 To Len(aCopPon)
	If aCopPon[nX] <> 0
		nSoma += aCopPon[nX]
	EndIf
Next nX
nMedia := nSoma / LEN(aCopPon)

aRet := {nMenor, nMedia, nMaior}

Return aRet

/*/{Protheus.doc} findBin
Encontra a posição de nValMed no vetor do eixo x tamanho nTamanho
@type Static Function
@author ivomar.rech / rafael.kleestadt
@since 10/08/2022
@version 1.0
@param nValMed, float, valor da medição a ser posicioanda em x
@param nMenorMed, float, valor da menor medição para calculo de incremento
@param nMaiorMed, float, valor da menor medição para calculo de incremento
@param nMenorCort, float, menor valor de x
@param nMaiorCort, float, maior valor de x
@param nTamanho, numeric, quantidade de subdivisões de x
@return nIndice, numeric, posição em x onde deverá ser criada a coluna da frequencia de nValMed
@example
(examples)
@see (links_or_references)
/*/
Static Function findBin(nValMed, nMenorMed, nMaiorMed, nMenorCort, nMaiorCort, nTamanho )
Local lMedAbaixo := .F.
Local lMedAcima  := .F.
Local nHighEdge  := 0
Local nI         := 1
Local nIncrBarra := (nMaiorMed - nMenorMed) / (SQRT(nTamanho) + 1)
Local nIndice    := 0

	// first check if x is outside the range of the normal histogram bins
	If (nValMed < nMenorCort)
		lMedAbaixo := .T.
    ELSEIF (nValMed > nMaiorCort)
		lMedAcima := .T. 
	ENDIF

    IF !lMedAbaixo .AND. !lMedAcima
	    DO While nI <= nTamanho
			nHighEdge := nMenorCort + (nI * nIncrBarra)
            nI := nI + 1
			If (nValMed <= nHighEdge)
				nIndice := nI
				EXIT
            ENDIf
        END
	ENDIF
Return nIndice


/*/{Protheus.doc} findPosCol
Gera o array com a posição em x das colunas de frequancia para histograma
@author rafael.kleestadt
@since 10/08/2022
@version 1.0
@param aMedicoes, array, vetor das medições coletadas
@param aCorte, array, vetor de dados com base no menor ponto qtd de pontos e incremnto
@return aFrequenci, array, vetor domesmo tamanho de aCorte contendo a frequencia de cada medição posicionada em x
/*/
METHOD findPosCol(aMedicoes, aCorte) CLASS NB
Local aFrequenci := Nil
Local nIndice    := 0 
Local nIndx      := 0 
Local nMaxCorte  := ASORT(aClone(aCorte),,, { |x, y| x > y } )[1]
Local nMaxMed    := ASORT(aClone(aMedicoes),,, { |x, y| x > y } )[1]
Local nMinCorte  := ASORT(aClone(aCorte),,, { |x, y| x < y } )[1]
Local nMinMed    := ASORT(aClone(aMedicoes),,, { |x, y| x < y } )[1]
Local nTamanho   := LEN(aCorte)

aFrequenci := ARRAY( nTamanho )
AFILL(aFrequenci, 0)

For nIndx := 1 To Len(aMedicoes)
	nIndice := findBin(aMedicoes[nIndx], nMinMed, nMaxMed, nMinCorte, nMaxCorte, nTamanho )
	If nIndice > 0
		aFrequenci[nIndice] ++
	EndIf
Next nIndx
 
Return aFrequenci


/*/{Protheus.doc} findPosLim
Gera o array com a posição em x das linhas de limites para histograma
@author rafael.kleestadt
@since 12/08/2022
@version 1.0
@param aMedicoes, array, vetor das medições coletadas
@param aCorte, array, vetor de dados com base no menor ponto qtd de pontos e incremnto
@param aLimites, array, vetor de dados dos limites na ordem 1-Referency, 2-LSL, 3-USL
@return aLimNew, array, vetor contendo a posição dos limites na mesma ordem recebida de aLimites.
/*/
METHOD findPosLim(aMedicoes, aCorte, aLimites) CLASS NB
Local aLimNew   := {}
Local nIndice   := 0 
Local nIndx     := 0 
Local nMaxCorte := ASORT(aClone(aCorte),,, { |x, y| x > y } )[1]
Local nMaxMed   := ASORT(aClone(aMedicoes),,, { |x, y| x > y } )[1]
Local nMinCorte := ASORT(aClone(aCorte),,, { |x, y| x < y } )[1]
Local nMinMed   := ASORT(aClone(aMedicoes),,, { |x, y| x < y } )[1]
Local nTamanho  := LEN(aCorte)

For nIndx := 1 To Len(aLimites)
	nIndice := findBin(aLimites[nIndx], nMinMed, nMaxMed, nMinCorte, nMaxCorte, nTamanho )
	Aadd(aLimNew, nIndice)
Next nIndx
 
Return aLimNew
