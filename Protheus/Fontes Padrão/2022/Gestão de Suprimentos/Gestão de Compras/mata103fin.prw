#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATA103FIN.CH"

/**************************************** FUNCOES RELACIONADAS AO FOLDER DE DUPLICATAS DO DOCUMENTO DE ENTRADA ****************************************/ 
/*********************************************** E TODOS OS TRATAMENTOS REFERENTES AO MODULO FINANCEIRO ***********************************************/
/*
/* FUTURAMENTE TRANSFERIR PARA ESTE FONTE AS SEGUINTES FUNCOES:
/*
/* NfeFldFin   (MATA103X)
/* NfeRFldFin  (MATA103X)
/* NfeLOkSE2   (MATA103X)
/* NfeTOkSE2   (MATA103X)
/* NfeMultNat  (MATA103X)
/* NfeLOkSEV   (MATA103X)
/* NfeTOkSEV   (MATA103X)
/* NfeVldSEV   (MATA103X)
/* NfeRatSEV   (MATA103X)
/* NfeRatImp   (MATA103X)
/* NfeCond     (MATA103X)
/* NfeCond2    (MATA103X)
/* NfeTotFin   (MATA103X)
/* A103CalcRt  (MATA103X)
/* A103Radio   (MATA103X)
/* A103Recal   (MATA103X)
/* A103ValNat  (MATA103X)
/* A103VencSE2 (MATA103X)
/* A103CodR    (MATA103X)
/* A103AtuSE2  (MATA103)
/* NfeCalcRet  (MATA103)
/* A103MNat    (MATA103)
/* A103CCompAd (MATA103)
/* A103CompAdR (MATA103)
*/ 

/*/{Protheus.doc} A103TrbGen()
Criacao do array contendo os valores do motor de tributos genericos por parcela de duplicata
Este array sera passado para a funcao A103ATUSE2 para geracao dos tributos no Financeiro

@param	aVencto    - Array com quantidade de parcelas da duplicata
        aTribGen   - Array com os tributos genericos retornados pelo motor
        aColTrbGen - Array com as colunas que serao adicionadas na aba duplicatas
        aRateio    - Array com as posicoes para controle de rateio de cada coluna da duplicata
        aRatBasTG  - Array com as posicoes para controle de rateio da base de calculo de cada coluna da duplicata
		cIdsTrGen  - String que receberá os ids de impostos calculados pelo Configurador de Tributos.
@return Array
@author Carlos Capeli
@since 21/11/18
@version 12
/*/
Function A103TrbGen(aVencto,aTribGen,aColTrbGen,aRateio,aRatBasTG,cIdsTrGen)

Local aParcTrGen := {}
Local nX         := 0
Local nY         := 0

Default aVencto    := {}
Default aTribGen   := {}
Default aColTrbGen := {}
Default aRateio    := {}
Default aRatBasTG  := {}
Default cIdsTrGen  := ""
// Cada parcela de duplicata tera um array com os tributos gerericos calculados pelo motor
For nX := 1 To Len(aVencto)
	aAdd(aParcTrGen,{})		// Parcela da duplicata
	For nY := 1 To Len(aTribGen)
		aAdd(aParcTrGen[Len(aParcTrGen)],{aTribGen[nY][4],	;			// Cod. Regra Financeira FKK
										 0,					;			// Base de calculo - Este valor sera preenchido na funcao NFERFLDFIN
										 0,					;			// Valor calculado - Este valor sera preenchido na funcao NFERFLDFIN
										 aTribGen[nY][5],	;			// ID da regra fiscal F2B
										 FinParcFKK(aTribGen[nY][4]),;	// Indica se retem integralmente na primeira parcela
										 aTribGen[nY][6],	;			// Codigo da URF
										 aTribGen[nY][7]})				// Percentual aplicavel a URF
		//preenchendo a variável de Ids de tributos genéricos.
		If !(aTribGen[nY][11] $ cIdsTrGen)
			cIdsTrGen += aTribGen[nY][11] + "|"
		EndIf
	Next nY
Next nX

// Adiciona elementos nos arrays de controle de saldo a ratear
For nX := 1 To Len(aColTrbGen)
	aAdd(aRateio,0)		// Array de rateio dos valores da duplicata
	aAdd(aRatBasTG,0)	// Array de rateio da base de calculo
Next nX

Return aParcTrGen

/*/{Protheus.doc} A103AtuTrG()
Atualiza valores do motor de tributos genericos no array aParcTrGen caso tenham sido alterados manualmente

@param	aParcTrGen - Array contendo os valores do motor de tributos genericos por parcela de duplicata
        aColTrbGen - Array com as colunas que serao adicionadas na aba duplicatas
        aTribGen   - Array com os tributos genericos retornados pelo motor
		aColsSE2   - aCols de Duplicatas
        nColsSE2   - Variavel que contem o numero de colunas da tabela SE2 exibidas na aba Duplicatas
@return Array
@author Carlos Capeli
@since 21/11/18
@version 12
/*/
Function A103AtuTrG(aParcTrGen,aColTrbGen,aTribGen,aColsSE2,nColsSE2)

Local nPosValTrb := 0
Local nX         := 0
Local nY         := 0

Default aParcTrGen := {}
Default aColTrbGen := {}
Default aTribGen   := {}
Default aColsSE2   := {}
Default nColsSE2   := 0

For nX := 1 To Len(aParcTrGen)

	For nY := 1 To Len(aTribGen)

		If (nPosValTrb := aScan(aColTrbGen,{|x| x[1] == aTribGen[nY][1]}) ) > 0	// Encontra a coluna da duplicata referente ao tributo generico

			If Len(aParcTrGen[nX]) >= nY

				aParcTrGen[nX][nY][3] := aColsSE2[nX][nColsSE2+nPosValTrb]		// Atualiza array de tributos genericos para que os valores fiquem coerentes com a aba Duplicatas, pois as colunas sao editaveis

			EndIf

		EndIf

	Next nY

Next nX

Return

/*/{Protheus.doc} A103NATREN
Interface para informacao dos valores de natureza de rendimento - Projeto REINF
@author rodrigo.mpontes
@since 28/03/2018
@version 12.1.17
@type function
/*/

Function A103NatRen(aHeadDHR,aColsDHR,lIncNat,lClaNat,aColRotAut)

Local aArea     	:= GetArea()
Local aInDHR		:= {"DHR_NATREN"}
Local aNotDHR		:= {"DHR_FILIAL","DHR_DOC","DHR_SERIE","DHR_FORNEC","DHR_LOJA"}
Local aColNatRend	:= {}
Local nPosItNf		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_ITEM"} )
Local nItemDHR  	:= 0
Local nX			:= 0
Local nY			:= 0
Local nPosCpo		:= 0
Local nItem			:= 0
Local nOpcA    		:= 0
Local oDlgNR      	:= Nil
Local oGetDHP		:= Nil

Default aHeadDHR	:= {}
Default aColsDHR	:= {}
Default aColRotAut	:= {}
Default lIncNat		:= .T.
Default lClaNat		:= .T.

// Montagem do aHeader DHR
If Empty(aHeadDHR)
	aHeadDHR := COMXHDCO("DHR",aInDHR)
EndIf

// Montagem do aHeader DHR - Suspensão
If Empty(aHdSusDHR)
	aHdSusDHR := COMXHDCO("DHR",,aNotDHR)
EndIf

// Montagem do aCols DHR
If !lIncNat .And. Empty(aColsDHR)	// Entra nesta condicao somente quando for Visualizacao, Classificacao ou Exclusao
	DbSelectArea("DHR")
	DHR->(DbSetOrder(1))
	If DHR->(DbSeek(xFilial("DHR")+cNFiscal+cSerie+cA100For+cLoja))
		While DHR->(!Eof()) .And. ; 
				xFilial("DHR") == DHR->DHR_FILIAL .And. ;
				DHR->DHR_DOC == cNFiscal .And. ;
				DHR->DHR_SERIE == cSerie .And. ;
				DHR->DHR_FORNEC == cA100For .And. ;
				DHR->DHR_LOJA == cLoja

			aAdd(aColsDHR,{DHR->DHR_ITEM,{Array(Len(aHeadDHR)+1)}})
			nItemDHR++
			For nX := 1 To Len(aHeadDHR)
				If aHeadDHR[nX][10] <> "V"
					aColsDHR[nItemDHR][2][Len(aColsDHR[nItemDHR][2])][nX] := DHR->(FieldGet(FieldPos(aHeadDHR[nX][2])))
				Else
					aColsDHR[nItemDHR][2][Len(aColsDHR[nItemDHR][2])][nX] := DHR->(CriaVar(aHeadDHR[nX][2]))
				EndIf
			Next nX
			aColsDHR[nItemDHR][2][Len(aColsDHR[nItemDHR][2])][Len(aHeadDHR)+1] := .F.

			DHR->(DbSkip())
		Enddo
	EndIf
	
ElseIf l103Auto .And. Len(aColRotAut) > 0	// Entra nesta condicao somente quando for rotina automatica
	For nX := 1 To Len(aColRotAut)
		aAdd(aColsDHR,{aColRotAut[nX][1],{Array(Len(aHeadDHR)+1)}})
		For nY := 1 To Len(aHeadDHR)
			If ( nPosCpo := aScan(aColRotAut[nX][2][1],{|x| x[1] == aHeadDHR[nY][2]}) ) > 0
				aColsDHR[Len(aColsDHR)][2][1][nY] := aColRotAut[nX][2][1][nPosCpo][2]
			EndIf
		Next nY
		aColsDHR[Len(aColsDHR)][2][1][Len(aHeadDHR)+1] := .F.
	Next nX
EndIf

If !l103Auto
	If (nItem := aScan(aColsDHR,{|x| x[1] == aCols[n][nPosItNf]})) > 0
		aColNatRend := aClone(aColsDHR[nItem][2])
	Else
		aAdd(aColNatRend,Array(Len(aHeadDHR)+1))
		For nX := 1 To Len(aHeadDHR)
			aColNatRend[1,nX] := CriaVar(aHeadDHR[nX,2])
		Next nX
		aColNatRend[1,Len(aHeadDHR)+1] := .F.
	EndIf

	DEFINE MSDIALOG oDlgNR FROM 100,100 TO 280,550 TITLE STR0002 Of oMainWnd PIXEL //"Natureza de Rendimento"

	oGetDHR := MsNewGetDados():New(20,3,65,215,IIF((lIncNat.Or.lClaNat),GD_INSERT+GD_UPDATE+GD_DELETE,0),,,,,,1,,,,oDlgNR,aHeadDHR,aColNatRend)

	@ 6 ,4 SAY AllTrim(RetTitle("F1_DOC"))+":" OF oDlgNR PIXEL SIZE 20,09
	@ 6 ,26 SAY cNFiscal +"-"+ Substr(cSerie,1,3) OF oDlgNR PIXEL SIZE 50,09
	@ 6 ,80 SAY AllTrim(RetTitle("D1_ITEM"))+":" OF oDlgNR PIXEL SIZE 20,09
	@ 6 ,102 SAY aCols[n][nPosItNf] OF oDlgNR PIXEL SIZE 20,09

	Define SButton From 73,195 Type 1 Of oDlgNR Enable Action ( nOpcA := 1, oDlgNR:End() )
	Define SButton From 73,160 Type 2 Of oDlgNR Enable Action oDlgNR:End()

	ACTIVATE MSDIALOG oDlgNR CENTERED

	If nOpcA == 1 .And. (lIncNat .Or. lClaNat)
		If nItem > 0
			aColsDHR[nItem][2] := aClone(oGetDHR:aCols)
		Else
			aAdd(aColsDHR,{aCols[n][nPosItNf],aClone(oGetDHR:aCols)})
		EndIf
	EndIf

EndIf

RestArea(aArea)

Return

/*/{Protheus.doc} A103FKW
Tabela intermediaria FKW Natureza de Rendimentos - Projeto REINF

@param cOpc		I-Inclusão/E-Exclusão
@param aITD1	aCols dos itens da NF
@param aITE2	Recno dos titulos a pagar gerados

@author rodrigo.mpontes
@since 28/03/2018
@version 12.1.17
@type function
/*/

Function A103FKW(cOpc,aITD1,aITE2)

Local aArea		:= GetArea()
Local aNatPerc	:= {}
Local aNatDoc	:= {}
Local aAux		:= {}
Local aDados	:= {}
Local aImp		:= {"IRF","PIS","COF","CSL"}
Local aSusp		:= {}
Local cChvFK7	:= ""
Local cChave	:= ""
Local cChaveTit	:= ""
Local nTDHRDoc	:= TamSX3("DHR_DOC")[1]
Local nTDHRSer	:= TamSX3("DHR_SERIE")[1]
Local nTDHRFor	:= TamSX3("DHR_FORNEC")[1]
Local nTDHRLoj	:= TamSX3("DHR_LOJA")[1]
Local nTDHRIte	:= TamSX3("DHR_ITEM")[1]
Local nTamDoc	:= TamSX3("D1_DOC")[1]
Local nTamSer	:= TamSX3("D1_SERIE")[1]
Local nTamFor	:= TamSX3("D1_FORNECE")[1]
Local nTamLoj	:= TamSX3("D1_LOJA")[1]
Local nTamIte	:= TamSX3("D1_ITEM")[1]
Local nPDOC		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_DOC"})
Local nPSER		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_SERIE"})
Local nPFOR		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_FORNECE"})
Local nPLOJ		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_LOJA"})
Local nPITE		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_ITEM"})
Local nPIRR		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_VALIRR"})
Local nPPIS		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_VALPIS"})
Local nPCOF		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_VALCOF"})
Local nPCSL		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_VALCSL"})
Local nTotIRR	:= 0
Local nTotPIS	:= 0
Local nTotCOF	:= 0
Local nTotCSL	:= 0
Local nTotNRIRR	:= 0
Local nTotNRPIS	:= 0
Local nTotNRCOF	:= 0
Local nTotNRCSL	:= 0
Local nI		:= 0
Local nX		:= 0
Local nPos		:= 0
Local nPerc		:= 0
Local nTotPerc	:= 0
Local nValor	:= 0
Local nBase		:= 0

DbSelectArea("DHR")
DHR->(DbSetOrder(1))

DbSelectArea("SD1")
SD1->(DbSetOrder(1))

If cOpc == "I" //Inclusão
	For nI := 1 To Len(aITD1)
		If nPIRR > 0 //Total de IRRF
			nTotIRR += aITD1[nI,nPIRR]
		Endif
		
		If nPPIS > 0 //Total de PIS
			nTotPIS += aITD1[nI,nPPIS]
		Endif
		
		If nPCOF > 0 //Total de COFINS
			nTotCOF += aITD1[nI,nPCOF]
		Endif
		
		If nPCSL > 0 //Total de CSLL
			nTotCSL += aITD1[nI,nPCSL]
		Endif
		
		//Naturezas de Rendimentos e Itens da NF
		cChave := xFilial("DHR") + Padr(cNFiscal,nTDHRDoc) + Padr(cSerie,nTDHRSer) + Padr(cA100For,nTDHRFor) + Padr(cLoja,nTDHRLoj) + Padr(aITD1[nI,nPITE],nTDHRIte)
		If DHR->(DbSeek(cChave))
			nPos := aScan(aNatDoc,{|x| x[1] == DHR->DHR_NATREN})
			If nPos == 0
				aAdd(aNatDoc,{DHR->DHR_NATREN,DHR->DHR_ITEM})
			Else
				aNatDoc[nPos,2] += "|" + DHR->DHR_ITEM
			Endif
		Endif
	Next nI
	
	For nI := 1 To Len(aNatDoc)
		aAux := Separa(aNatDoc[nI,2],"|")
		
		nTotNRIRR := 0
		nTotNRPIS := 0
		nTotNRCOF := 0
		nTotNRCSL := 0
		
		//Total de IR/PCC por Natureza de Rendimento
		For nX := 1 To Len(aAux)
			nPos := aScan(aITD1,{|x| AllTrim(x[nPITE]) == AllTrim(aAux[nX])})
			If nPos > 0
				If aITD1[nPos,nPIRR] > 0 //Total de IRRF
					nTotNRIRR += aITD1[nPos,nPIRR]
				Endif
				
				If aITD1[nPos,nPPIS] > 0 //Total de PIS
					nTotNRPIS += aITD1[nPos,nPPIS]
				Endif
				
				If aITD1[nPos,nPCOF] > 0 //Total de COFINS
					nTotNRCOF += aITD1[nPos,nPCOF]
				Endif
				
				If aITD1[nPos,nPCSL] > 0 //Total de CSLL
					nTotNRCSL += aITD1[nPos,nPCSL]
				Endif
			Endif
		Next nX
		
		//Proporcionamento de imposto x natureza de rendimento
		//IRRF
		If nTotIRR > 0
			nPerc := nTotNRIRR * 100 / nTotIRR
			
			aAdd(aNatPerc,{aNatDoc[nI,1],"IRF",nPerc})
		Endif
		
		//PIS
		If nTotPIS > 0
			nPerc := nTotNRPIS * 100 / nTotPIS
			
			aAdd(aNatPerc,{aNatDoc[nI,1],"PIS",nPerc})
		Endif
		
		//COFINS
		If nTotCOF > 0
			nPerc := nTotNRCOF * 100 / nTotCOF
			
			aAdd(aNatPerc,{aNatDoc[nI,1],"COF",nPerc})
		Endif
		
		//CSLL
		If nTotCSL > 0
			nPerc := nTotNRCSL * 100 / nTotCSL
			
			aAdd(aNatPerc,{aNatDoc[nI,1],"CSL",nPerc})
		Endif
	Next nI
	
	DbSelectArea("SE2")
	
	//Gera dados para a tabela intermediaria a partir dos titulos (SE2) x Natureza de rendimentos
	For nI := 1 To Len(aITE2)
		SE2->(DbGoTo(aITE2[nI]))
		
		cChaveTit := FINGRVFK7("SE2", xFilial("SE2")+"|"+SE2->E2_PREFIXO+"|"+SE2->E2_NUM+"|"+SE2->E2_PARCELA+"|"+SE2->E2_TIPO+"|"+SE2->E2_FORNECE+"|"+SE2->E2_LOJA)
		
		For nX := 1 To Len(aNatDoc)
			nPos := aScan(aNatPerc,{|x| x[1] == aNatDoc[nX,1] .And. x[2] == "IRF"})
			If nPos > 0
				nPerc	:= aNatPerc[nPos,3]
				nValor	:= (SE2->E2_IRRF * nPerc) / 100
				nBase	:= (SE2->E2_BASEIRF * nPerc ) / 100
				aSusp	:= A103SUSPDHR("IRF",aNatDoc[nX,1],Len(aITE2))
				
				If Len(aSusp) == 0
					aadd(aDados,{xFilial("FKW"),;
								 cChaveTit,;
								 "IRF",;
								 aNatDoc[nX,1],;
								 nPerc,;
								 nBase,;
								 nValor,;
								 0,;
								 0,;
								 "",;
								 "",;
								 "",;
								 0})
				Elseif Len(aSusp) > 0
					aadd(aDados,{xFilial("FKW"),;
								 cChaveTit,;
								 "IRF",;
								 aNatDoc[nX,1],;
								 nPerc,;
								 nBase,;
								 nValor,;
								 aSusp[1],;
								 aSusp[2],;
								 aSusp[3],;
								 aSusp[4],;
								 aSusp[5],;
								 aSusp[6]})
				Endif
			Endif
		
			nPos := aScan(aNatPerc,{|x| x[1] == aNatDoc[nX,1] .And. x[2] == "PIS"})
			If nPos > 0
				nPerc	:= aNatPerc[nPos,3]
				nValor	:= (SE2->E2_PIS * nPerc) / 100
				nBase	:= (SE2->E2_BASEPIS * nPerc ) / 100
				aSusp	:= A103SUSPDHR("PIS",aNatDoc[nX,1],Len(aITE2))
				
				If Len(aSusp) == 0
					aadd(aDados,{xFilial("FKW"),;
								 cChaveTit,;
								 "PIS",;
								 aNatDoc[nX,1],;
								 nPerc,;
								 nBase,;
								 nValor,;
								 0,;
								 0,;
								 "",;
								 "",;
								 "",;
								 0})
				Elseif Len(aSusp) > 0
					aadd(aDados,{xFilial("FKW"),;
								 cChaveTit,;
								 "PIS",;
								 aNatDoc[nX,1],;
								 nPerc,;
								 nBase,;
								 nValor,;
								 aSusp[1],;
								 aSusp[2],;
								 aSusp[3],;
								 aSusp[4],;
								 aSusp[5],;
								 aSusp[6]})
				Endif
			Endif
		
			nPos := aScan(aNatPerc,{|x| x[1] == aNatDoc[nX,1] .And. x[2] == "COF"})
			If nPos > 0
				nPerc	:= aNatPerc[nPos,3]
				nValor	:= (SE2->E2_COFINS * nPerc) / 100
				nBase	:= (SE2->E2_BASECOF * nPerc ) / 100
				aSusp	:= A103SUSPDHR("COF",aNatDoc[nX,1],Len(aITE2))
				
				If Len(aSusp) == 0
					aadd(aDados,{xFilial("FKW"),;
								 cChaveTit,;
								 "COF",;
								 aNatDoc[nX,1],;
								 nPerc,;
								 nBase,;
								 nValor,;
								 0,;
								 0,;
								 "",;
								 "",;
								 "",;
								 0})
				Elseif Len(aSusp) > 0
					aadd(aDados,{xFilial("FKW"),;
								 cChaveTit,;
								 "COF",;
								 aNatDoc[nX,1],;
								 nPerc,;
								 nBase,;
								 nValor,;
								 aSusp[1],;
								 aSusp[2],;
								 aSusp[3],;
								 aSusp[4],;
								 aSusp[5],;
								 aSusp[6]})
				Endif
			Endif

			nPos := aScan(aNatPerc,{|x| x[1] == aNatDoc[nX,1] .And. x[2] == "CSL"})
			If nPos > 0
				nPerc	:= aNatPerc[nPos,3]
				nValor	:= (SE2->E2_CSLL * nPerc) / 100
				nBase	:= (SE2->E2_BASECSL * nPerc ) / 100
				aSusp	:= A103SUSPDHR("CSL",aNatDoc[nX,1],Len(aITE2))
				
				If Len(aSusp) == 0
					aadd(aDados,{xFilial("FKW"),;
								 cChaveTit,;
								 "CSL",;
								 aNatDoc[nX,1],;
								 nPerc,;
								 nBase,;
								 nValor,;
								 0,;
								 0,;
								 "",;
								 "",;
								 "",;
								 0})
				Elseif Len(aSusp) > 0
					aadd(aDados,{xFilial("FKW"),;
								 cChaveTit,;
								 "CSL",;
								 aNatDoc[nX,1],;
								 nPerc,;
								 nBase,;
								 nValor,;
								 aSusp[1],;
								 aSusp[2],;
								 aSusp[3],;
								 aSusp[4],;
								 aSusp[5],;
								 aSusp[6]})
				Endif
			Endif
		Next nX
	Next nI
		
Elseif cOpc == "E"

	//Exclusão da tabela intermediaria a partir dos titulos (SE2)
	For nI := 1 To Len(aITE2)
		SE2->(DbGoTo(aITE2[nI]))
		
		If Empty(SE2->E2_TITPAI) //Somente Titulos da NF
			cChaveTit := FINGRVFK7("SE2", xFilial("SE2")+"|"+SE2->E2_PREFIXO+"|"+SE2->E2_NUM+"|"+SE2->E2_PARCELA+"|"+SE2->E2_TIPO+"|"+SE2->E2_FORNECE+"|"+SE2->E2_LOJA)
			
			aadd(aDados,{xFilial("FKW"),;
					 	 cChaveTit})
		Endif
	Next nI
	
Endif

RestArea(aArea)

Return

/*/{Protheus.doc} A103NATVLD
Valid do campo DHR_NATREN - Natureza de Rendimento

@author rodrigo.mpontes
@since 28/03/2018
@version 12.1.17
@type function
/*/

Function A103NATVLD()

Local lRet	:= .T.
Local aRet	:= {}

//Verifica se existe natureza de rendimento
lRet := ExistCpo("FKX",M->DHR_NATREN,1)

Return lRet

/*/{Protheus.doc} A103VldSusp
Verifica se podera haver alguma suspensão dos impostos IR/PIS/COFINS/CSLL

@param aHdD1	aHeader da SD1 (Itens da NF)
@param aLinD1	aCols da SD1 (Itens da NF)

@author rodrigo.mpontes
@since 30/08/2019
@version P12.1.17
 /*/
 
Function A103VldSusp(aHdD1,aLinD1)

Local lRet		:= .T.
Local lIrPcc	:= .F.
Local nI		:= 0
Local nPIRR		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_BASEIRR"})
Local nPPIS		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_BASEPIS"})
Local nPCOF		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_BASECOF"})
Local nPCSL		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_BASECSL"})

//Verifica existencia das tabelas do REINF, se tem imposto IR e/ou PCC, se tem natureza de rendimento
//e se fornecedor possuir amarração com algum processo referenciado.
If ChkFile("DHS") .And. ChkFile("DHT") .And. ChkFile("DHR") .And. ChkFile("FKW") .And. nPIRR > 0 .And. nPPIS > 0 .And. ;
   nPCOF > 0 .And. nPCSL > 0 .And. Len(aColsDHR) > 0
   
	For nI := 1 To Len(aLinD1)
		If aCols[nI,nPIRR] > 0 .Or. aCols[nI,nPPIS] > 0 .Or. aCols[nI,nPCOF] > 0 .Or. aCols[nI,nPCSL] > 0
			lIrPCC := .T.
			Exit
		Endif
	Next nI
	
	If lIrPCC
		DbSelectArea("DHS")
		DHS->(DbSetOrder(1))
		If DHS->(DbSeek(xFilial("DHS") + cA100For + cLoja))
			If MsgYesNo(STR0003)//"Deseja aplicar alguma suspensão DE TRIBUTOS neste documento?"
				lRet := A103TelaSusp(aHdD1,aLinD1)
			Endif
		Endif
	Endif
Endif

Return lRet

/*/{Protheus.doc} A103TelaSusp
Tela para informar as suspensões dos impostos IR/PIS/COFINS/CSLL

@param aHdD1	aHeader da SD1 (Itens da NF)
@param aLinD1	aCols da SD1 (Itens da NF)

@author rodrigo.mpontes
@since 30/08/2019
@version P12.1.17
 /*/

Static Function A103TelaSusp(aHdD1,aLinD1)

Local lRet		:= .T.
Local nPITE		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_ITEM"})
Local nPBIRR	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_BASEIRR"})
Local nPVIRR	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_VALIRR"})
Local nPBPIS	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_BASEPIS"})
Local nPVPIS	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_VALPIS"})
Local nPBCOF	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_BASECOF"})
Local nPVCOF	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_VALCOF"})
Local nPBCSL	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_BASECSL"})
Local nPVCSL	:= aScan(aHeader,{|x| AllTrim(x[2]) == "D1_VALCSL"})
Local nPNAT		:= aScan(aHeadDHR,{|x| AllTrim(x[2]) == "DHR_NATREN"})
Local nI		:= 0
Local nPos		:= 0
Local nOpca		:= 0
Local nTamProc	:= TamSx3("DHR_PSIR")[1]
Local nTamTp	:= TamSx3("DHR_TSIR")[1]
Local nTamInd	:= TamSx3("DHR_ISIR")[1]
Local aItemNat	:= {}
Local oSize		:= Nil
Local aAlterDHR	:= {"DHR_PSIR","DHR_TSIR","DHR_ISIR","DHR_PSPIS","DHR_TSPIS","DHR_ISPIS","DHR_PSCOF","DHR_TSCOF","DHR_ISCOF","DHR_PSCSL","DHR_TSCSL","DHR_ISCSL",;
					"DHR_BASUIR","DHR_VLRSIR","DHR_BSUPIS","DHR_VLSPIS","DHR_BSUCOF","DHR_VLSCOF","DHR_BSUCSL","DHR_VLSCSL"}

Private oDHRGet	:= Nil

For nI := 1 To Len(aColsDHR)
	nPos := aScan(aLinD1,{|x| x[nPITE] == aColsDHR[nI,1]})
	If nPos > 0 .And. !aLinD1[nPos,Len(aHeader)+1]
		If !Empty(aColsDHR[nI,1]) .And. !Empty(aColsDHR[nI,2])
			aAdd(aItemNat,{aColsDHR[nI,1],aColsDHR[nI,2,1,nPNAT],Space(nTamProc),Space(nTamTp),Space(nTamInd),Space(nTamProc),Space(nTamTp),Space(nTamInd),;
							Space(nTamProc),Space(nTamTp),Space(nTamInd),Space(nTamProc),Space(nTamTp),Space(nTamInd),;
							0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,.F.})
		Endif
	Endif
Next nI

For nI := 1 To Len(aItemNat)
	nPos := aScan(aLinD1,{|x| x[nPITE] == aItemNat[nI,1]})
	If nPos > 0
		aItemNat[nI,15] := aLinD1[nPos,nPBIRR] //Base IR
		aItemNat[nI,16] := aLinD1[nPos,nPVIRR] //Valor IR
		aItemNat[nI,19] := aLinD1[nPos,nPBIRR] //Base NF IR
		aItemNat[nI,20] := aLinD1[nPos,nPVIRR] //Valor NF IR
		
		aItemNat[nI,21] := aLinD1[nPos,nPBPIS] //Base PIS
		aItemNat[nI,22] := aLinD1[nPos,nPVPIS] //Valor PIS
		aItemNat[nI,25] := aLinD1[nPos,nPBPIS] //Base NF PIS
		aItemNat[nI,26] := aLinD1[nPos,nPVPIS] //Valor NF PIS
		
		aItemNat[nI,27] := aLinD1[nPos,nPBCOF] //Base COF
		aItemNat[nI,28] := aLinD1[nPos,nPVCOF] //Valor COF
		aItemNat[nI,31] := aLinD1[nPos,nPBCOF] //Base NF COF
		aItemNat[nI,32] := aLinD1[nPos,nPVCOF] //Valor NF COF
		
		aItemNat[nI,33] := aLinD1[nPos,nPBCSL] //Base CSL
		aItemNat[nI,34] := aLinD1[nPos,nPVCSL] //Valor CSL
		aItemNat[nI,37] := aLinD1[nPos,nPBCSL] //Base NF CSL
		aItemNat[nI,38] := aLinD1[nPos,nPVCSL] //Valor NF CSL
	Endif
Next nI

oSize := FwDefSize():New()
oSize:AddObject( "DHR" ,  100, 100, .T., .T. )	// Totalmente dimensionavel
oSize:lProp 	:= .T.							// Proporcional
oSize:aMargins 	:= { 3, 3, 3, 3 }				// Espaco ao lado dos objetos 0, entre eles 3
oSize:Process()									// Dispara os calculos

DEFINE MSDIALOG oDlgSusp TITLE "Suspensão - REINF" FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] PIXEL

oDHRGet := MsNewGetDados():New(	oSize:GetDimension("DHR","LININI"),oSize:GetDimension("DHR","COLINI"),oSize:GetDimension("DHR","LINEND"),;
								oSize:GetDimension("DHR","COLEND"),3,"AllwaysTrue","AllwaysTrue",/*cIniCpos*/,aAlterDHR,,Len(aItemNat),;
								"A103CALCSUS()","","AllwaysTrue", oDlgSusp, aHdSusDHR, aItemNat)

ACTIVATE MSDIALOG oDlgSusp CENTERED ON INIT EnchoiceBar(oDlgSusp,{|| Iif(A103TOKDHR(),(nOpca := 1,oDlgSusp:End()),.F.)},{||(nOpca := 0,oDlgSusp:End())},,)

If nOpca == 1
	For nI := 1 To Len(oDHRGet:aCols)
		nPos:= aScan(aCoSusDHR,{|x| x[1] == oDHRGet:aCols[nI,1]})
		If nPos > 0
			aCoSusDHR[nPos][2] := aClone(oDHRGet:aCols)
		Else
			aAdd(aCoSusDHR,{oDHRGet:aCols[nI,1],aClone(oDHRGet:aCols)})
		Endif
	Next nI
	MaFisToCols(aHeader,aCols,,"MT100")
	Eval(bRefresh,5)
	Eval(bRefresh,6)
	Eval(bGdRefresh)
Else
	aCols := aClone(aLinD1)
	MaColsToFis(aHeader,aCols,,"MT100")
	For nI := 1 To Len(aCols)
		n := nI
		NfeDelItem()
	Next nI
	n := 1
	Eval(bRefresh,5)
	Eval(bRefresh,6)
	Eval(bGdRefresh)
	lRet := .F.
Endif

Return lRet

/*/{Protheus.doc} A103TOKDHR
Tudo OK - DHR

@author rodrigo.mpontes
@since 30/08/2019
@version P12.1.17
 /*/

Function A103TOKDHR()

Local lRet		:= .T.

Local nPSIR		:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_PSIR"})
Local nBASUIR	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_BASUIR"})
Local nVLRSIR	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_VLRSIR"})
Local nPSPIS	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_PSPIS"})
Local nBSUPIS	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_BSUPIS"})
Local nVLSPIS	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_VLSPIS"})
Local nPSCOF	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_PSCOF"})
Local nBSUCOF	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_BSUCOF"})
Local nVLSCOF	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_VLSCOF"})
Local nPSCSL	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_PSCSL"})
Local nBSUCSL	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_BSUCSL"})
Local nVLSCSL	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_VLSCSL"})
Local nI		:= 0

For nI := 1 To Len(oDHRGet:aCols)
	If !oDHRGet:aCols[nI,Len(oDHRGet:aHeader)+1]
		If !Empty(oDHRGet:aCols[nI,nPSIR]) .And. oDHRGet:aCols[nI,nBASUIR] == 0 .And. oDHRGet:aCols[nI,nVLRSIR] == 0
			lRet := .F.
			Help( ,, 'A103SUSPENSAO',,STR0004 + " (IRRF)",1,0) //"Processo informado, mas sem base/valor de suspensão" 
		Elseif !Empty(oDHRGet:aCols[nI,nPSPIS]) .And. oDHRGet:aCols[nI,nBSUPIS] == 0 .And. oDHRGet:aCols[nI,nVLSPIS] == 0
			lRet := .F.
			Help( ,, 'A103SUSPENSAO',,STR0004 + " (PIS)",1,0) //"Processo informado, mas sem base/valor de suspensão" 
		Elseif !Empty(oDHRGet:aCols[nI,nPSCOF]) .And. oDHRGet:aCols[nI,nBSUCOF] == 0 .And. oDHRGet:aCols[nI,nVLSCOF] == 0
			lRet := .F.
			Help( ,, 'A103SUSPENSAO',,STR0004 + " (COFINS)",1,0) //"Processo informado, mas sem base/valor de suspensão" 
		Elseif !Empty(oDHRGet:aCols[nI,nPSCSL]) .And. oDHRGet:aCols[nI,nBSUCSL] == 0 .And. oDHRGet:aCols[nI,nVLSCSL] == 0
			lRet := .F.
			Help( ,, 'A103SUSPENSAO',,STR0004 + " (CSLL)",1,0) //"Processo informado, mas sem base/valor de suspensão" 
		ElseIf Empty(oDHRGet:aCols[nI,nPSIR]) .And. (oDHRGet:aCols[nI,nBASUIR] > 0 .Or. oDHRGet:aCols[nI,nVLRSIR] > 0)
			lRet := .F.
			Help( ,, 'A103SUSPENSAO',,STR0009 + " (IRRF)",1,0) //"Processo não informado, mas base/valor de suspensão informado" 
		Elseif Empty(oDHRGet:aCols[nI,nPSPIS]) .And. (oDHRGet:aCols[nI,nBSUPIS] > 0 .Or. oDHRGet:aCols[nI,nVLSPIS] > 0)
			lRet := .F.
			Help( ,, 'A103SUSPENSAO',,STR0009 + " (PIS)",1,0) //"Processo não informado, mas base/valor de suspensão informado"
		Elseif Empty(oDHRGet:aCols[nI,nPSCOF]) .And. (oDHRGet:aCols[nI,nBSUCOF] > 0 .Or. oDHRGet:aCols[nI,nVLSCOF] > 0)
			lRet := .F.
			Help( ,, 'A103SUSPENSAO',,STR0009 + " (COFINS)",1,0) //"Processo não informado, mas base/valor de suspensão informado"
		Elseif Empty(oDHRGet:aCols[nI,nPSCSL]) .And. (oDHRGet:aCols[nI,nBSUCSL] > 0 .Or. oDHRGet:aCols[nI,nVLSCSL] > 0)
			lRet := .F.
			Help( ,, 'A103SUSPENSAO',,STR0009 + " (CSLL)",1,0) //"Processo não informado, mas base/valor de suspensão informado"
		Endif
	Endif
	
	If !lRet
		Exit
	Endif
Next nI

Return lRet

/*/{Protheus.doc} A103CALCSUS
Calculo da suspensão dos impostos IR/PIS/COFINS/CSLL

@author rodrigo.mpontes
@since 30/08/2019
@version P12.1.17
 /*/

Function A103CALCSUS()

Local lRet		:= .T.
Local cCpo		:= StrTran(AllTrim(ReadVar()),"M->","")
Local cPrTpInd	:= ""
Local nPos		:= 0
Local nBaseVlr	:= 0
Local nPItNat	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_ITEM"})
Local nPSIR		:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_PSIR"})
Local nTSIR		:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_TSIR"})
Local nISIR		:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_ISIR"})
Local nPSPIS	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_PSPIS"})
Local nTSPIS	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_TSPIS"})
Local nISPIS	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_ISPIS"})
Local nPSCOF	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_PSCOF"})
Local nTSCOF	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_TSCOF"})
Local nISCOF	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_ISCOF"})
Local nPSCSL	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_PSCSL"})
Local nTSCSL	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_TSCSL"})
Local nISCSL	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_ISCSL"})
Local nBASEIR	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_BASEIR"})
Local nVLRIR	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_VLRIR"})
Local nBASUIR	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_BASUIR"})
Local nVLRSIR	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_VLRSIR"})
Local nBANFIR	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_BANFIR"})
Local nVLNFIR	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_VLNFIR"})
Local nBASPIS	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_BASPIS"})
Local nVLRPIS	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_VLRPIS"})
Local nBSUPIS	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_BSUPIS"})
Local nVLSPIS	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_VLSPIS"})
Local nBNFPIS	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_BNFPIS"})
Local nVNFPIS	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_VNFPIS"})
Local nBASCOF	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_BASCOF"})
Local nVLRCOF	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_VLRCOF"})
Local nBSUCOF	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_BSUCOF"})
Local nVLSCOF	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_VLSCOF"})
Local nBNFCOF	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_BNFCOF"})
Local nVNFCOF	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_VNFCOF"})
Local nBASCSL	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_BASCSL"})
Local nVLRCSL	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_VLRCSL"})
Local nBSUCSL	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_BSUCSL"})
Local nVLSCSL	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_VLSCSL"})
Local nBNFCSL	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_BNFCSL"})
Local nVNFCSL	:= aScan(oDHRGet:aHeader,{|x| AllTrim(x[2]) == "DHR_VNFCSL"})
Local nNatRenIT	:= Val(oDHRGet:aCols[oDHRGet:nAt,nPItNat]) //Para correto calculo na MATXFIS

//Validação Processo referenciado IRRF
If cCpo == "DHR_PSIR" .Or. cCpo == "DHR_TSIR" .Or. cCpo == "DHR_ISIR" .Or. ; //IRRF
   cCpo == "DHR_PSPIS" .Or. cCpo == "DHR_TSPIS" .Or. cCpo == "DHR_ISPIS" .Or. ; //PIS
   cCpo == "DHR_PSCOF" .Or. cCpo == "DHR_TSCOF" .Or. cCpo == "DHR_ISCOF" .Or. ; //COF
   cCpo == "DHR_PSCSL" .Or. cCpo == "DHR_TSCSL" .Or. cCpo == "DHR_ISCSL" //CSLL
    
	cPrTpInd := &cCpo
	
	//IRRF
	If cCpo == "DHR_PSIR"
		If !Empty(cPrTpInd) .And. !Empty(oDHRGet:aCols[oDHRGet:nAt,nTSIR]) .And. !Empty(oDHRGet:aCols[oDHRGet:nAt,nISIR])
			lRet := A103VLDPRO(cPrTpInd,oDHRGet:aCols[oDHRGet:nAt,nTSIR],oDHRGet:aCols[oDHRGet:nAt,nISIR])
		Endif
	Elseif cCpo == "DHR_TSIR"
		If !Empty(oDHRGet:aCols[oDHRGet:nAt,nPSIR]) .And. !Empty(cPrTpInd) .And. !Empty(oDHRGet:aCols[oDHRGet:nAt,nISIR])
			lRet := A103VLDPRO(oDHRGet:aCols[oDHRGet:nAt,nPSIR],cPrTpInd,oDHRGet:aCols[oDHRGet:nAt,nISIR])
		Endif		
	Elseif cCpo == "DHR_ISIR"
		If !Empty(oDHRGet:aCols[oDHRGet:nAt,nPSIR]) .And. !Empty(oDHRGet:aCols[oDHRGet:nAt,nTSIR]) .And. !Empty(cPrTpInd)
			lRet := A103VLDPRO(oDHRGet:aCols[oDHRGet:nAt,nPSIR],oDHRGet:aCols[oDHRGet:nAt,nTSIR],cPrTpInd)
		Endif
		
	//PIS
	Elseif cCpo == "DHR_PSPIS"
		If !Empty(cPrTpInd) .And. !Empty(oDHRGet:aCols[oDHRGet:nAt,nTSPIS]) .And. !Empty(oDHRGet:aCols[oDHRGet:nAt,nISPIS])
			lRet := A103VLDPRO(cPrTpInd,oDHRGet:aCols[oDHRGet:nAt,nTSPIS],oDHRGet:aCols[oDHRGet:nAt,nISPIS])
		Endif
	Elseif cCpo == "DHR_TSPIS"
		If !Empty(oDHRGet:aCols[oDHRGet:nAt,nPSPIS]) .And. !Empty(cPrTpInd) .And. !Empty(oDHRGet:aCols[oDHRGet:nAt,nISPIS])
			lRet := A103VLDPRO(oDHRGet:aCols[oDHRGet:nAt,nPSPIS],cPrTpInd,oDHRGet:aCols[oDHRGet:nAt,nISPIS])
		Endif		
	Elseif cCpo == "DHR_ISPIS"
		If !Empty(oDHRGet:aCols[oDHRGet:nAt,nPSPIS]) .And. !Empty(oDHRGet:aCols[oDHRGet:nAt,nTSPIS]) .And. !Empty(cPrTpInd)
			lRet := A103VLDPRO(oDHRGet:aCols[oDHRGet:nAt,nPSPIS],oDHRGet:aCols[oDHRGet:nAt,nTSPIS],cPrTpInd)
		Endif
		
	//COFINS
	Elseif cCpo == "DHR_PSCOF"
		If !Empty(cPrTpInd) .And. !Empty(oDHRGet:aCols[oDHRGet:nAt,nTSCOF]) .And. !Empty(oDHRGet:aCols[oDHRGet:nAt,nISCOF])
			lRet := A103VLDPRO(cPrTpInd,oDHRGet:aCols[oDHRGet:nAt,nTSCOF],oDHRGet:aCols[oDHRGet:nAt,nISCOF])
		Endif
	Elseif cCpo == "DHR_TSCOF"
		If !Empty(oDHRGet:aCols[oDHRGet:nAt,nPSCOF]) .And. !Empty(cPrTpInd) .And. !Empty(oDHRGet:aCols[oDHRGet:nAt,nISCOF])
			lRet := A103VLDPRO(oDHRGet:aCols[oDHRGet:nAt,nPSCOF],cPrTpInd,oDHRGet:aCols[oDHRGet:nAt,nISCOF])
		Endif		
	Elseif cCpo == "DHR_ISCOF"
		If !Empty(oDHRGet:aCols[oDHRGet:nAt,nPSCOF]) .And. !Empty(oDHRGet:aCols[oDHRGet:nAt,nTSCOF]) .And. !Empty(cPrTpInd)
			lRet := A103VLDPRO(oDHRGet:aCols[oDHRGet:nAt,nPSCOF],oDHRGet:aCols[oDHRGet:nAt,nTSCOF],cPrTpInd)
		Endif
		
	//CSLL
	Elseif cCpo == "DHR_PSCSL"
		If !Empty(cPrTpInd) .And. !Empty(oDHRGet:aCols[oDHRGet:nAt,nTSCSL]) .And. !Empty(oDHRGet:aCols[oDHRGet:nAt,nISCSL])
			lRet := A103VLDPRO(cPrTpInd,oDHRGet:aCols[oDHRGet:nAt,nTSCSL],oDHRGet:aCols[oDHRGet:nAt,nISCSL])
		Endif
	Elseif cCpo == "DHR_TSCSL"
		If !Empty(oDHRGet:aCols[oDHRGet:nAt,nPSCSL]) .And. !Empty(cPrTpInd) .And. !Empty(oDHRGet:aCols[oDHRGet:nAt,nISCSL])
			lRet := A103VLDPRO(oDHRGet:aCols[oDHRGet:nAt,nPSCSL],cPrTpInd,oDHRGet:aCols[oDHRGet:nAt,nISCSL])
		Endif		
	Elseif cCpo == "DHR_ISCSL"
		If !Empty(oDHRGet:aCols[oDHRGet:nAt,nPSCSL]) .And. !Empty(oDHRGet:aCols[oDHRGet:nAt,nTSCSL]) .And. !Empty(cPrTpInd)
			lRet := A103VLDPRO(oDHRGet:aCols[oDHRGet:nAt,nPSCSL],oDHRGet:aCols[oDHRGet:nAt,nTSCSL],cPrTpInd)
		Endif
	Endif
		
	If !lRet
		Help( ,, 'A103SUSPENSAO',,STR0005,1,0) //"Processo não existe no cadastro de processos referenciados (CCF)"
	Endif
Endif

//Preenchimento da Base ou Valor de suspensão do IRRF
If lRet .And. cCpo == "DHR_BASUIR" .Or. cCpo == "DHR_VLRSIR"
	nBaseVlr := &cCpo
	If nPSIR > 0 .And. nBaseVlr > 0
		If Empty(oDHRGet:aCols[oDHRGet:nAt,nPSIR]) //Processo IR em branco
			Help(" ",1,'A103SUSPENSAO',,STR0006,1,0) //"Não é possivel informar uma suspensão, sem informar o processo referente ao imposto"
			lRet := .F.
		Endif
	Endif
	
	If lRet
		If cCpo == "DHR_BASUIR" .And. nBaseVlr > 0
			If nBaseVlr > oDHRGet:aCols[oDHRGet:nAt,nBASEIR]
				Help(" ",1,'A103SUSPENSAO',,STR0007,1,0) //"Valor da base suspensa é maior que a base do imposto."
				lRet := .F.
			Else
				MaFisAlt("IT_BASEIRR",nBaseVlr,nNatRenIT)
				
				oDHRGet:aCols[oDHRGet:nAt,nBASUIR] := MaFisRet(nNatRenIT,"IT_BASEIRR")	//Base Suspensa
				oDHRGet:aCols[oDHRGet:nAt,nVLRSIR] := MaFisRet(nNatRenIT,"IT_VALIRR")		//Valor Suspenso
				
				oDHRGet:aCols[oDHRGet:nAt,nBANFIR] := oDHRGet:aCols[oDHRGet:nAt,nBASEIR] - MaFisRet(nNatRenIT,"IT_BASEIRR") 	//Base IR NF
				oDHRGet:aCols[oDHRGet:nAt,nVLNFIR] := oDHRGet:aCols[oDHRGet:nAt,nVLRIR] - MaFisRet(nNatRenIT,"IT_VALIRR")		//Valor IR NF
				
				MaFisAlt("IT_BASEIRR",oDHRGet:aCols[oDHRGet:nAt,nBANFIR],nNatRenIT)
			Endif
			
		Elseif cCpo == "DHR_VLRSIR" .And. nBaseVlr > 0
			If nBaseVlr > oDHRGet:aCols[oDHRGet:nAt,nVLRIR]
				Help(" ",1,'A103SUSPENSAO',,STR0008,1,0) //"Valor da suspensão é maior que valor do imposto."
				lRet := .F.
			Else
				If nBaseVlr == oDHRGet:aCols[oDHRGet:nAt,nVLRIR]
					oDHRGet:aCols[oDHRGet:nAt,nBASUIR] := oDHRGet:aCols[oDHRGet:nAt,nBASEIR]	//Base Suspensa
				Else
					oDHRGet:aCols[oDHRGet:nAt,nBASUIR] := 0	//Base Suspensa
				Endif
				oDHRGet:aCols[oDHRGet:nAt,nVLRSIR] := nBaseVlr								//Valor Suspenso
				
				oDHRGet:aCols[oDHRGet:nAt,nBANFIR] := oDHRGet:aCols[oDHRGet:nAt,nBASEIR]		//Base IR NF
				oDHRGet:aCols[oDHRGet:nAt,nVLNFIR] := oDHRGet:aCols[oDHRGet:nAt,nVLRIR] - oDHRGet:aCols[oDHRGet:nAt,nVLRSIR]		//Valor IR NF
				
				MaFisAlt("IT_BASEIRR",oDHRGet:aCols[oDHRGet:nAt,nBANFIR],nNatRenIT)
				MaFisAlt("IT_VALIRR",oDHRGet:aCols[oDHRGet:nAt,nVLNFIR],nNatRenIT)
			Endif
		Elseif nBaseVlr == 0
			oDHRGet:aCols[oDHRGet:nAt,nBANFIR] := oDHRGet:aCols[oDHRGet:nAt,nBASEIR]
			oDHRGet:aCols[oDHRGet:nAt,nVLNFIR] := oDHRGet:aCols[oDHRGet:nAt,nVLRIR]
			
			oDHRGet:aCols[oDHRGet:nAt,nBASUIR] := 0
			oDHRGet:aCols[oDHRGet:nAt,nVLRSIR] := 0
		Endif
	Endif
Endif

//Preenchimento da Base ou Valor de suspensão do PIS
If lRet .And. cCpo == "DHR_BSUPIS" .Or. cCpo == "DHR_VLSPIS"
	nBaseVlr := &cCpo
	If nPSPIS > 0 .And. nBaseVlr > 0
		If Empty(oDHRGet:aCols[oDHRGet:nAt,nPSPIS]) //Processo PIS em branco
			Help(" ",1,'A103SUSPENSAO',,STR0006,1,0) //"Não é possivel informar uma suspensão, sem informar o processo referente ao imposto"
			lRet := .F.
		Endif
	Endif
	
	If lRet
		If cCpo == "DHR_BSUPIS" .And. nBaseVlr > 0
			If nBaseVlr > oDHRGet:aCols[oDHRGet:nAt,nBASPIS]
				Help(" ",1,'A103SUSPENSAO',,STR0007,1,0) //"Valor da base suspensa é maior que a base do imposto."
				lRet := .F.
			Else
				MaFisAlt("IT_BASEPIS",nBaseVlr,nNatRenIT)
				
				oDHRGet:aCols[oDHRGet:nAt,nBSUPIS] := MaFisRet(nNatRenIT,"IT_BASEPIS")	//Base Suspensa
				oDHRGet:aCols[oDHRGet:nAt,nVLSPIS] := MaFisRet(nNatRenIT,"IT_VALPIS")		//Valor Suspenso
				
				oDHRGet:aCols[oDHRGet:nAt,nBNFPIS] := oDHRGet:aCols[oDHRGet:nAt,nBASPIS] - MaFisRet(nNatRenIT,"IT_BASEPIS") 	//Base PIS NF
				oDHRGet:aCols[oDHRGet:nAt,nVNFPIS] := oDHRGet:aCols[oDHRGet:nAt,nVLRPIS] - MaFisRet(nNatRenIT,"IT_VALPIS")		//Valor PIS NF
				
				MaFisAlt("IT_BASEPIS",oDHRGet:aCols[oDHRGet:nAt,nBNFPIS],nNatRenIT)
			Endif
		Elseif cCpo == "DHR_VLSPIS" .And. nBaseVlr > 0
			If nBaseVlr > oDHRGet:aCols[oDHRGet:nAt,nVLRPIS]
				Help(" ",1,'A103SUSPENSAO',,STR0008,1,0) //"Valor da suspensão é maior que valor do imposto."
				lRet := .F.
			Else
				If nBaseVlr == oDHRGet:aCols[oDHRGet:nAt,nVLRPIS]
					oDHRGet:aCols[oDHRGet:nAt,nBSUPIS] := oDHRGet:aCols[oDHRGet:nAt,nBASPIS]	//Base Suspensa
				Else
					oDHRGet:aCols[oDHRGet:nAt,nBSUPIS] := 0	//Base Suspensa
				Endif
				oDHRGet:aCols[oDHRGet:nAt,nVLSPIS] := nBaseVlr								//Valor Suspenso
				
				oDHRGet:aCols[oDHRGet:nAt,nBNFPIS] := oDHRGet:aCols[oDHRGet:nAt,nBASPIS]		//Base PIS NF
				oDHRGet:aCols[oDHRGet:nAt,nVNFPIS] := oDHRGet:aCols[oDHRGet:nAt,nVLRPIS] - oDHRGet:aCols[oDHRGet:nAt,nVLSPIS]		//Valor PIS NF
				
				MaFisAlt("IT_BASEPIS",oDHRGet:aCols[oDHRGet:nAt,nBNFPIS],nNatRenIT)
				MaFisAlt("IT_VALPIS",oDHRGet:aCols[oDHRGet:nAt,nVNFPIS],nNatRenIT)
			Endif
		Elseif nBaseVlr == 0
			oDHRGet:aCols[oDHRGet:nAt,nBNFPIS] := oDHRGet:aCols[oDHRGet:nAt,nBASPIS]
			oDHRGet:aCols[oDHRGet:nAt,nVNFPIS] := oDHRGet:aCols[oDHRGet:nAt,nVLRPIS]
			
			oDHRGet:aCols[oDHRGet:nAt,nBSUPIS] := 0
			oDHRGet:aCols[oDHRGet:nAt,nVLSPIS] := 0
		Endif
	Endif
Endif

//Preenchimento da Base ou Valor de suspensão do COFINS
If lRet .And. cCpo == "DHR_BSUCOF" .Or. cCpo == "DHR_VLSCOF"
	nBaseVlr := &cCpo
	If nPSCOF > 0 .And. nBaseVlr > 0
		If Empty(oDHRGet:aCols[oDHRGet:nAt,nPSCOF]) //Processo COFINS em branco
			Help(" ",1,'A103SUSPENSAO',,STR0006,1,0) //"Não é possivel informar uma suspensão, sem informar o processo referente ao imposto"
			lRet := .F.
		Endif
	Endif
	
	If lRet
		If cCpo == "DHR_BSUCOF" .And. nBaseVlr > 0
			If nBaseVlr > oDHRGet:aCols[oDHRGet:nAt,nBASCOF]
				Help(" ",1,'A103SUSPENSAO',,STR0007,1,0) //"Valor da base suspensa é maior que a base do imposto."
				lRet := .F.
			Else
				MaFisAlt("IT_BASECOF",nBaseVlr,nNatRenIT)
				
				oDHRGet:aCols[oDHRGet:nAt,nBSUCOF] := MaFisRet(nNatRenIT,"IT_BASECOF")	//Base Suspensa
				oDHRGet:aCols[oDHRGet:nAt,nVLSCOF] := MaFisRet(nNatRenIT,"IT_VALCOF")		//Valor Suspenso
				
				oDHRGet:aCols[oDHRGet:nAt,nBNFCOF] := oDHRGet:aCols[oDHRGet:nAt,nBASCOF] - MaFisRet(nNatRenIT,"IT_BASECOF") 	//Base COF NF
				oDHRGet:aCols[oDHRGet:nAt,nVNFCOF] := oDHRGet:aCols[oDHRGet:nAt,nVLRCOF] - MaFisRet(nNatRenIT,"IT_VALCOF")	//Valor COF NF
				
				MaFisAlt("IT_BASECOF",oDHRGet:aCols[oDHRGet:nAt,nBNFCOF],nNatRenIT)
			Endif
		Elseif cCpo == "DHR_VLSCOF" .And. nBaseVlr > 0
			If nBaseVlr > oDHRGet:aCols[oDHRGet:nAt,nVLRCOF]
				Help(" ",1,'A103SUSPENSAO',,STR0008,1,0) //"Valor da suspensão é maior que valor do imposto."
				lRet := .F.
			Else
				If nBaseVlr == oDHRGet:aCols[oDHRGet:nAt,nVLRCOF]
					oDHRGet:aCols[oDHRGet:nAt,nBSUCOF] := oDHRGet:aCols[oDHRGet:nAt,nBASCOF]	//Base Suspensa
				Else
					oDHRGet:aCols[oDHRGet:nAt,nBSUCOF] := 0	//Base Suspensa
				Endif
				oDHRGet:aCols[oDHRGet:nAt,nVLSCOF] := nBaseVlr								//Valor Suspenso
				
				oDHRGet:aCols[oDHRGet:nAt,nBNFCOF] := oDHRGet:aCols[oDHRGet:nAt,nBASCOF]		//Base COF NF
				oDHRGet:aCols[oDHRGet:nAt,nVNFCOF] := oDHRGet:aCols[oDHRGet:nAt,nVLRCOF] - oDHRGet:aCols[oDHRGet:nAt,nVLSCOF]		//Valor COF NF
				
				MaFisAlt("IT_BASECOF",oDHRGet:aCols[oDHRGet:nAt,nBNFCOF],nNatRenIT)
				MaFisAlt("IT_VALCOF",oDHRGet:aCols[oDHRGet:nAt,nVNFCOF],nNatRenIT)
			Endif
		Elseif nBaseVlr == 0
			oDHRGet:aCols[oDHRGet:nAt,nBNFCOF] := oDHRGet:aCols[oDHRGet:nAt,nBASCOF]
			oDHRGet:aCols[oDHRGet:nAt,nVNFCOF] := oDHRGet:aCols[oDHRGet:nAt,nVLRCOF]
			
			oDHRGet:aCols[oDHRGet:nAt,nBSUCOF] := 0
			oDHRGet:aCols[oDHRGet:nAt,nVLSCOF] := 0
		Endif
	Endif
Endif

//Preenchimento da Base ou Valor de suspensão do CSLL
If lRet .And. cCpo == "DHR_BSUCSL" .Or. cCpo == "DHR_VLSCSL"
	nBaseVlr := &cCpo
	If nPSCSL > 0 .And. nBaseVlr > 0
		If Empty(oDHRGet:aCols[oDHRGet:nAt,nPSCSL]) //Processo COFINS em branco
			Help(" ",1,'A103SUSPENSAO',,STR0006,1,0) //"Não é possivel informar uma suspensão, sem informar o processo referente ao imposto"
			lRet := .F.
		Endif
	Endif
	
	If lRet
		If cCpo == "DHR_BSUCSL" .And. nBaseVlr > 0
			If nBaseVlr > oDHRGet:aCols[oDHRGet:nAt,nBASCSL]
				Help(" ",1,'A103SUSPENSAO',,STR0007,1,0) //"Valor da base suspensa é maior que a base do imposto."
				lRet := .F.
			Else
				MaFisAlt("IT_BASECSL",nBaseVlr,nNatRenIT)
				
				oDHRGet:aCols[oDHRGet:nAt,nBSUCSL] := MaFisRet(nNatRenIT,"IT_BASECSL")	//Base Suspensa
				oDHRGet:aCols[oDHRGet:nAt,nVLSCSL] := MaFisRet(nNatRenIT,"IT_VALCSL")		//Valor Suspenso
				
				oDHRGet:aCols[oDHRGet:nAt,nBNFCSL] := oDHRGet:aCols[oDHRGet:nAt,nBASCSL] - MaFisRet(nNatRenIT,"IT_BASECSL") 	//Base CSL NF
				oDHRGet:aCols[oDHRGet:nAt,nVNFCSL] := oDHRGet:aCols[oDHRGet:nAt,nVLRCSL] - MaFisRet(nNatRenIT,"IT_VALCSL")	//Valor CSL NF
				
				MaFisAlt("IT_BASECSL",oDHRGet:aCols[oDHRGet:nAt,nBNFCSL],nNatRenIT)
			Endif
		Elseif cCpo == "DHR_VLSCSL" .And. nBaseVlr > 0
			If nBaseVlr > oDHRGet:aCols[oDHRGet:nAt,nVLRCSL]
				Help(" ",1,'A103SUSPENSAO',,STR0008,1,0) //"Valor da suspensão é maior que valor do imposto."
				lRet := .F.
			Else
				If nBaseVlr == oDHRGet:aCols[oDHRGet:nAt,nVLRCSL]
					oDHRGet:aCols[oDHRGet:nAt,nBSUCSL] := oDHRGet:aCols[oDHRGet:nAt,nBASCSL]	//Base Suspensa
				Else
					oDHRGet:aCols[oDHRGet:nAt,nBSUCSL] := 0	//Base Suspensa
				Endif
				oDHRGet:aCols[oDHRGet:nAt,nVLSCSL] := nBaseVlr								//Valor Suspenso
				
				oDHRGet:aCols[oDHRGet:nAt,nBNFCSL] := oDHRGet:aCols[oDHRGet:nAt,nBASCSL]		//Base CSL NF
				oDHRGet:aCols[oDHRGet:nAt,nVNFCSL] := oDHRGet:aCols[oDHRGet:nAt,nVLRCSL] - oDHRGet:aCols[oDHRGet:nAt,nVLSCSL]		//Valor CSL NF
				
				MaFisAlt("IT_BASECSL",oDHRGet:aCols[oDHRGet:nAt,nBNFCSL],nNatRenIT)
				MaFisAlt("IT_VALCSL",oDHRGet:aCols[oDHRGet:nAt,nVNFCSL],nNatRenIT)
			Endif
		Elseif nBaseVlr == 0
			oDHRGet:aCols[oDHRGet:nAt,nBNFCSL] := oDHRGet:aCols[oDHRGet:nAt,nBASCSL]
			oDHRGet:aCols[oDHRGet:nAt,nVNFCSL] := oDHRGet:aCols[oDHRGet:nAt,nVLRCSL]
			
			oDHRGet:aCols[oDHRGet:nAt,nBSUCSL] := 0
			oDHRGet:aCols[oDHRGet:nAt,nVLSCSL] := 0
		Endif
	Endif
Endif

If lRet
	oDHRGet:Refresh()
Endif

Return lRet

/*/{Protheus.doc} A103VLDPRO
validação da existencia do processo referenciado

@param cProcesso	Numero do processo
@param cTipo		Tipo do processo
@param cIndSusp		Codigo indicativo da suspensão

@author rodrigo.mpontes
@since 30/08/2019
@version P12.1.17
 /*/

Static Function A103VLDPRO(cProcesso,cTipo,cIndSusp)

Local lRet 		:= .F.
Local cQry 		:= ""
Local cAliasTmp	:= GetNextAlias()

cQry := " SELECT R_E_C_N_O_ AS RECNO"
cQry += " FROM " + RetSqlName("CCF")
cQry += " WHERE D_E_L_E_T_ = ''"
cQry += " AND CCF_FILIAL = '" + xFilial("CCF") + "'"
cQry += " AND CCF_NUMERO = '" + cProcesso + "'"   
cQry += " AND CCF_TIPO = '" + cTipo + "'"
cQry += " AND CCF_INDSUS = '" + cIndSusp + "'"
cQry := ChangeQuery(cQry)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasTmp,.T.,.T.)

DbSelectArea(cAliasTmp)
If (cAliasTmp)->(!EOF())
	lRet := .T.
Endif

(cAliasTmp)->(DbCloseArea())

Return lRet

/*/{Protheus.doc} A103SUSPDHR
Busca base ou valor de suspensão do imposto

@param cImposto		Imposto
@param cNatRen		Natureza de Rendimento
@param nQtdParc		Quantidade de Parcelas

@author rodrigo.mpontes
@since 30/08/2019
@version P12.1.17
 /*/

Static Function A103SUSPDHR(cImposto,cNatRen,nQtdParc)

Local nI		:= 0
Local nX		:= 0
Local nBSusNF	:= 0
Local nVSusNF	:= 0
Local nBSusImp	:= 0
Local nVSusImp	:= 0
Local nPercNat	:= 0
Local nPercPar	:= 0
Local aCpo		:= {}
Local aRet		:= {}
Local cQry		:= ""
Local cAliasTmp	:= GetNextAlias()
Local cAliasNat	:= GetNextAlias()
Local cAliasPro	:= GetNextAlias()

If cImposto	== "IRF"
	aCpo := {"DHR_BASUIR","DHR_VLRSIR","DHR_PSIR","DHR_TSIR","DHR_ISIR"}
Elseif cImposto == "PIS"
	aCpo := {"DHR_BSUPIS","DHR_VLSPIS","DHR_PSPIS","DHR_TSPIS","DHR_ISPIS"}
Elseif cImposto == "COF"
	aCpo := {"DHR_BSUCOF","DHR_VLSCOF","DHR_PSCOF","DHR_TSCOF","DHR_ISCOF"}
Elseif cImposto == "CSL"
	aCpo := {"DHR_BSUCSL","DHR_VLSCSL","DHR_PSCSL","DHR_TSCSL","DHR_ISCSL"}
Endif

//Base / Valor Suspensão NF
cQry := " SELECT "

For nI := 1 To 2
	If nI == 1
		cQry += " SUM(" + aCpo[nI] + ") AS BASESUS"
	Elseif nI == 2
		cQry += ", SUM(" + aCpo[nI] + ") AS VALORSUS"
	Endif
Next nI

cQry += " FROM " + RetSqlName("DHR")
cQry += " WHERE D_E_L_E_T_ = ''"
cQry += " AND DHR_FILIAL = '" + xFilial("DHR") + "'"
cQry += " AND DHR_DOC = '" + cNFiscal + "'"
cQry += " AND DHR_SERIE = '" + cSerie + "'"
cQry += " AND DHR_FORNEC = '" + cA100For + "'"
cQry += " AND DHR_LOJA = '" + cLoja + "'"

cQry := ChangeQuery(cQry)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasTmp,.T.,.T.)

DbSelectArea(cAliasTmp)

If (cAliasTmp)->(!EOF())
	nBSusNF := (cAliasTmp)->BASESUS
	nVSusNF := (cAliasTmp)->VALORSUS
Endif

(cAliasTmp)->(DbCloseArea())

//Base / Valor Suspensão - Natureza Rendimento
cQry := " SELECT "

For nI := 1 To 2
	If nI == 1
		cQry += " SUM(" + aCpo[nI] + ") AS BASESUS"
	Elseif nI == 2
		cQry += ", SUM(" + aCpo[nI] + ") AS VALORSUS"
	Endif
Next nI

cQry += " FROM " + RetSqlName("DHR")
cQry += " WHERE D_E_L_E_T_ = ''"
cQry += " AND DHR_FILIAL = '" + xFilial("DHR") + "'"
cQry += " AND DHR_DOC = '" + cNFiscal + "'"
cQry += " AND DHR_SERIE = '" + cSerie + "'"
cQry += " AND DHR_FORNEC = '" + cA100For + "'"
cQry += " AND DHR_LOJA = '" + cLoja + "'"
cQry += " AND DHR_NATREN = '" + cNatRen + "'"

cQry := ChangeQuery(cQry)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasNat,.T.,.T.)

DbSelectArea(cAliasNat)

If (cAliasNat)->(!EOF())
	nBSusImp := (cAliasNat)->BASESUS
	nVSusImp := (cAliasNat)->VALORSUS
Endif

//Percentual de Suspensão do Imposto
nPercNat := nBSusImp * 100 / nBSusNF

//Percentual de Suspensão do Imposto por Titulo
nPercPar := nPercNat / nQtdParc

aAdd(aRet, nBSusNF*nPercPar/100 )
aAdd(aRet, nVSusNF*nPercPar/100 )

(cAliasNat)->(DbCloseArea())

//Processo / Tipo / Ind Suspensão - Natureza Rendimento
cQry := " SELECT "

For nI := 3 To Len(aCpo)
	If nI == 3
		cQry += aCpo[nI] + " AS PROCESSO"
	Elseif nI == 4
		cQry += ", " + aCpo[nI] + " AS TIPO"
	Elseif nI == 5
		cQry += ", " + aCpo[nI] + " AS INDSUS"
	Endif
Next nI

cQry += " FROM " + RetSqlName("DHR")
cQry += " WHERE D_E_L_E_T_ = ''"
cQry += " AND DHR_FILIAL = '" + xFilial("DHR") + "'"
cQry += " AND DHR_DOC = '" + cNFiscal + "'"
cQry += " AND DHR_SERIE = '" + cSerie + "'"
cQry += " AND DHR_FORNEC = '" + cA100For + "'"
cQry += " AND DHR_LOJA = '" + cLoja + "'"
cQry += " AND DHR_NATREN = '" + cNatRen + "'"
cQry += " AND " + aCpo[3] + " <> ''"

cQry := ChangeQuery(cQry)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasPro,.T.,.T.)

DbSelectArea(cAliasPro)

If (cAliasPro)->(!EOF())
	aAdd(aRet, (cAliasPro)->PROCESSO )
	aAdd(aRet, (cAliasPro)->TIPO )
	aAdd(aRet, (cAliasPro)->INDSUS )
Else
	aAdd(aRet, "" )
	aAdd(aRet, "" )
	aAdd(aRet, "" )
Endif

aAdd(aRet,nPercNat)

(cAliasPro)->(DbCloseArea())

Return aRet

/*/{Protheus.doc} A103INCDHR
Gravação da DHR - Naturezade Rendimento (Com ou Sem Suspensão)

@param aCabDHR		aHeader DHR
@param aLinDHR		aCols DHR
@param nPosItem		Item posicionado
@param lSuspensao	Indica se houve ou não suspensão

@author rodrigo.mpontes
@since 30/08/2019
@version P12.1.17
 /*/

Function A103INCDHR(aCabDHR,aLinDHR,nPosItem,lSuspensao)

Local lAchou 	:= .F.
Local nZ		:= 0
Local nW		:= 0
Local nDHRIT	:= 0

If !lSuspensao
	If !Empty(aLinDHR[nPosItem][2])
		DHR->(DbSetOrder(1))
		If !aLinDHR[nPosItem][2][1][Len(aCabDHR)+1]
			lAchou := DHR->(MsSeek(xFilial("DHR")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+SD1->D1_ITEM))
			If RecLock("DHR",!lAchou)
				For nZ := 1 To Len(aCabDHR)
					If aCabDHR[nZ][10] <> "V" .And. aLinDHR[nPosItem][2][1][nZ] <> Nil
						DHR->(FieldPut(FieldPos(aCabDHR[nZ][2]),aLinDHR[nPosItem][2][1][nZ]))
					EndIf
				Next nZ
				DHR->DHR_FILIAL := xFilial("DHR")
				DHR->DHR_DOC    := SD1->D1_DOC
				DHR->DHR_SERIE  := SD1->D1_SERIE
				DHR->DHR_FORNEC := SD1->D1_FORNECE
				DHR->DHR_LOJA   := SD1->D1_LOJA
				DHR->DHR_ITEM	:= SD1->D1_ITEM
				DHR->(MsUnlock())
			Endif
		Else // Deleta DHR caso item tenha sido excluido pela interface
			If DHR->(MsSeek(xFilial("DHR")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+SD1->D1_ITEM))
				If RecLock("DHR",.F.)
					DHR->(dbDelete())
					DHR->(MsUnlock())
				Endif
			EndIf
		EndIf
	EndIf
	DHR->(FkCommit())
Else
	If !Empty(aLinDHR[nPosItem][2])
		DHR->(DbSetOrder(1))
		For nW := 1 To Len(aLinDHR[nPosItem][2])
			nDHRIT := aScan(aCabDHR,{|x| AllTrim(x[2]) == "DHR_ITEM"})
			If !aLinDHR[nPosItem][2][nW][Len(aCabDHR)+1]
				lAchou := DHR->(MsSeek(xFilial("DHR")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+aLinDHR[nPosItem][2][nW][nDHRIT]))
				RecLock("DHR",!lAchou)
				For nZ := 1 To Len(aCabDHR)
					If aCabDHR[nZ][10] <> "V" .And. aLinDHR[nPosItem][2][nW][nZ] <> Nil
						DHR->(FieldPut(FieldPos(aCabDHR[nZ][2]),aLinDHR[nPosItem][2][nW][nZ]))
					EndIf
				Next nZ
				DHR->DHR_FILIAL := xFilial("DHR")
				DHR->DHR_DOC    := SD1->D1_DOC
				DHR->DHR_SERIE  := SD1->D1_SERIE
				DHR->DHR_FORNEC := SD1->D1_FORNECE
				DHR->DHR_LOJA   := SD1->D1_LOJA
				DHR->(MsUnlock())
			EndIf
		Next nZ
	EndIf
	DHR->(FkCommit())
Endif

Return

/*/{Protheus.doc} A103EXCDHR
Exclusão da DHR - Naturezade Rendimento (Com ou Sem Suspensão)

@author rodrigo.mpontes
@since 30/08/2019
@version P12.1.17
 /*/

Function A103EXCDHR()

DbSelectArea("DHR")
DHR->(dbSetOrder(1))
If DHR->(DbSeek(xFilial("DHR")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
	While DHR->(!Eof()) .And. xFilial("DHR") == DHR->DHR_FILIAL .And. ;
			DHR->DHR_DOC == SF1->F1_DOC .And. ;
			DHR->DHR_SERIE == SF1->F1_SERIE .And. ;
			DHR->DHR_FORNEC == SF1->F1_FORNECE .And. ;
			DHR->DHR_LOJA == SF1->F1_LOJA

		RecLock("DHR",.F.)
		DHR->(dbDelete())
		DHR->(MsUnlock())
		DHR->(DbSkip())
	Enddo
	// Tratamento da gravacao do SDE na Integridade Referencial
	DHR->(FkCommit())
EndIf	

Return			

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} FxCtbPAdt
Contabilização das compensações entre titulos e adiantamentos
Emissão da NF - MAtA103

@param aRecSE5, vetor com duas posições.
				[1] - Recno da SE5 ref a baixa da contabilização da compensação
				[2] - Recno da SE2 ref a baixa da contabilização da compensação
				[3] - Recno da FK2 ref a baixa da contabilização da compensação

@author Mauricio Pequim Jr
@since  18/11/2019
@version 12
@type function
/*/
//------------------------------------------------------------------------------------------
Function FxCtbPAdt(aRecSE5)

	Local lContabil	:= .F.
	Local lDigita	:= .F.
	Local lAglutina	:= .F.
	Local lUsaFlag	:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/)
	Local cArqCtb	:= ""
	Local cPadrao	:= "597" 
	Local nValor	:= 0
	Local nRecSe2	:= 0
	Local nRecSe5	:= 0
	Local nRecFK2	:= 0
	Local nX		:= 0
	Local nTotCtbil := 0
	Local lPCCBaixa := SuperGetMv("MV_BX10925",.T.,"2") == "1"
	Local lIssBaixa := SuperGetMv("MV_MRETISS",.F.,"1") == "2"	
	Local lIRPFBaixa:= .F.
	Local lImpComp  := SuperGetMV("MV_IMPCOM", .T., .F.)

	Private nHdlPrv		:= 0
	Private ABATIMENTO	:= 0
	Private aFlagCTB	:= {}
	Private cLote		:= ""
	Private NPIS340     := 0
	Private NCOF340     := 0
	Private NCSL340     := 0
	Private NIRF340     := 0
	Private NISS340     := 0
	
	Default aRecSE5 := {}

	If Len(aRecSE5) > 0

		//Carrega o pergunte da rotina de compensação financeira
		Pergunte("AFI340",.F.)

		lContabil	 	:= MV_PAR11 == 1
		lDigita			:= MV_PAR09 == 1
		lAglutina		:= MV_PAR08 == 1
		lPadrao			:= VerPadrao(cPadrao)

		If lContabil
			LoteCont("FIN")
			If nHdlPrv <= 0
				nHdlPrv := HeadProva(cLote, "FINA340", Substr(cUsuario, 7, 6), @cArqCtb)
			EndIf
		
			If nHdlPrv > 0

				For nX := 1 to Len(aRecSE5)
					
					SE5->(dbGoTo(aRecSe5[nX,1]))
					SE2->(dbGoTo(aRecSe5[nX,2]))
					FK2->(dbGoTo(aRecSe5[nX,3]))

					If lPadrao .And. lContabil .and. nHdlPrv > 0
						STRLCTPAD := SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)
						VALOR     := If(Val(SE5->E5_MOEDA) == 1, SE5->E5_VALOR, SE5->E5_VLMOED2)
						VALOR2    := SE5->E5_VLCORRE
						nTotCtbil += VALOR

						If lImpComp .and. SE5->(E5_VRETPIS+E5_VRETCOF+E5_VRETCSL+E5_VRETIRF+E5_VRETISS) > 0
							//PCC
							If lPCCBaixa .And. SE5->(E5_VRETPIS+E5_VRETCOF+E5_VRETCSL) > 0
								//Alimenta variáveis de contabilização
								NPIS340 := SE5->E5_VRETPIS 
								NCOF340 := SE5->E5_VRETCOF
								NCSL340 := SE5->E5_VRETCSL
							Endif
							//Irf
							lIRPFBaixa := If(cPaisLoc = "BRA" , SA2->A2_CALCIRF == "2", .F.) .And. Posicione("SED",1,xfilial("SED",SE2->E2_FILORIG) + SE2->(E2_NATUREZ),"ED_CALCIRF") = "S"
							If lIRPFBaixa .And. SE5->E5_VRETIRF > 0
								//Alimenta variável de contabilização
								NIRF340 := If(SE5->E5_PRETIRF == "1",0,SE5->E5_VRETIRF)
							Endif
							//Iss
							If lIssBaixa .And. SE5->E5_VRETISS > 0
								//contabilização do imposto
								NISS340 := SE5->E5_VRETISS
							Endif
						Endif

						If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
							aAdd( aFlagCTB, {"E5_LA" , "S", "SE5", SE5->( Recno() ), 0, 0, 0} )
							aAdd( aFlagCTB, {"FK2_LA", "S", "FK2", FK2->( Recno() ), 0, 0, 0} )
						Endif

						nValor 	  += DetProva(nHdlPrv, cPadrao, "FINA340", cLote,/*nLinha*/,/*lExecuta*/,/*cCriterio*/,/*lRateio*/,/*cChaveBusca*/,/*aCT5*/,/*lPosiciona*/,@aFlagCTB,/*aTabRecOri*/,/*aDadosProva*/)

						If !lUsaFlag
							RecLock("SE5",.F.)
							SE5->E5_LA := "S "
							MsUnLock()

							RecLock("FK2",.F.)
							FK2->FK2_LA := "S"
							MsUnlock()
						Endif

						VALOR   := 0
						VALOR2  := 0
						NPIS340 := 0
						NCOF340 := 0
						NCSL340 := 0
						NIRF340	:= 0
						NISS340	:= 0
					EndIf
				Next

				//Contabilização
				If lPadrao .And. nValor > 0
					VALOR := nValor
					nRecSe2 := SE2->(Recno())
					nRecSe5 := SE2->(Recno())
					nRecFK2 := FK2->(Recno())

					SE2->(DBGoBottom())
					SE2->(dbSkip())
					SE5->(DBGoBottom())
					SE5->(dbSkip())
					FK2->(DBGoBottom())
					FK2->(dbSkip())

					RodaProva(nHdlPrv, nValor)
					cA100Incl(cArqCtb, nHdlPrv, 1, cLote, lDigita, lAglutina, Nil, Nil, Nil, @aFlagCTB)			
					aFlagCTB := {}

					SE2->(dbGoTo(nRecSE2))
					SE5->(dbGoTo(nRecSE5))
					FK2->(dbGoTo(nRecFK2))

				EndIf
			Endif
		Endif

		Pergunte("MTA103",.F.)

	Endif	

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} A103IdGen
Verifica se os impostos são calculados pelo configurador e atribue .T. as variáveis para não ser gerado os títulos pelo legado

@param 
	cIdsTrbGen - Ids de tributos genéricos
	lPccMR - Retenção de Pis Cofins e CSL	- id do Imposto CSLL       "000026", COFRET     "000043", PISRET     "000045", 
	lIrfMR - Retenção de IR					- id do Imposto IR         "000018"
	lInsMR - Retenção de INSS				- id do Imposto INSS       "000019"
	lIssMR - Retenção de ISS				- id do Imposto ISS        "000020"
	lCidMR - Retenção de CID				- id do Imposto CIDE       "000023"
	lSestMR - Retenção Sest					- id do Imposto SEST       "000013"

@author r.cavalcante
@since  08/09/2022
@version 12
@type function
/*/
//------------------------------------------------------------------------------------------
 
Function A103IdGen(cIdsTrbGen,lPccMR,lIrfMR,lInsMR,lIssMR,lCidMR,lSestMR)
	Default cIdsTrbGen := ""
	
	If "000026"$ cIdsTrbGen .OR. "000043" $ cIdsTrbGen .OR. "000045"$ cIdsTrbGen
		lPccMR := .T.
	EndIf
	If "000018" $ cIdsTrbGen
		lIrfMR := .T.
	EndIf
	If "000019" $ cIdsTrbGen
		lInsMR := .T.
	EndIf
	If "000020" $ cIdsTrbGen
		lIssMR := .T.
	EndIf
	If "000023" $ cIdsTrbGen
		lCidMR := .T.
	EndIf
	If "000013" $ cIdsTrbGen
		lSestMR := .T.
	EndIf

Return
