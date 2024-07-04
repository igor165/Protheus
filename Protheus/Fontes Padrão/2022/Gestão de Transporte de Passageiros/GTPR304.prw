#INCLUDE "rwmake.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "protheus.ch"
#INCLUDE "TOTVS.ch"
#INCLUDE "GTPR304.ch"

/*/{Protheus.doc} GTPR304
Relatorio Coeficiente de Aproveitamento Médio de Linhas
@type function
@author jacomo.fernandes
@since 16/11/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GTPR304()
	
	Local cPerg		:= "GTPR423"//"GTPR304"
	Local oReport	:= nil
	
	If Pergunte(cPerg,.T.)
		oReport := ReportDef()
		oReport:PrintDialog()
	EndIf
		
Return

/*/{Protheus.doc} ReportDef
(long_description)
@type function
@author jacomo.fernandes
@since 16/11/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function ReportDef()
	
	Local oReport
	Local oSection1
	Local oSection2
	Local oBreak
	Local cTitulo := STR0001 //"[GTPR304] - Rel. Coeficiente de Aproveitamento Médio de Linhas"
	
		SX3->(DBSETORDER(1))
		 
		oReport := TReport():New('GTPR304', cTitulo,'GTPR423' , {|oReport| PrintReport(oReport)}, STR0002 ) //"Este relatório ira imprimir o Aproveitamento Médio das Linhas"
		oReport:lParamPage := .T. //Exibe a Primeira Pagina Rosto.
	
		oReport:SetTotalInLine(.F.)
		oReport:SetLeftMargin(05)
						
		oSection1:= TRSection():New(oReport, "Tipos de Linha", {"GI2","GQC"}) //"Tipos de Linha"
		
		TRCell():New(oSection1,"GI2_TIPLIN"	,"GI2", "Código"	,"@!"	,TamSX3("GI2_TIPLIN")[1]) //"Código"
		TRCell():New(oSection1,"GQC_DESCRI"	,"GQC", "Descrição"	,"@!"	,TamSX3("GQC_DESCRI")[1]) //"Descrição"
		
		oSection2 	:= TRSection():New(oSection1, "LINE1"	, 	{'GI2'}  , , .F., .T.)
		
		TRCell():New(oSection2	, "CODIGO"		, 'GI2'	, STR0003		, "@!"			, TamSx3('GI2_NUMLIN')[1]+3	) // "Código"
	    TRCell():New(oSection2	, "LINHA"		, 'GI2'	, STR0004		, "@!"			, TamSX3("GI3_NLIN")[1]+10	) //"Linha"
	    TRCell():New(oSection2	, "ORDIN"		, 'GI2'	, STR0005		, "@E 999.99%"	, 7							) //"Ordin."
	    TRCell():New(oSection2	, "MULTIP"		, 'GI2'	, STR0006		, "@E 999.99%"	, 7							) //"Multip"
	    TRCell():New(oSection2	, "RFTOTAL"		, 'GI2'	, STR0007		, "@E 999.99%"	, 7							) //"Ref. Total"
	    TRCell():New(oSection2	, "RFPARCIAL"	, 'GI2'	, STR0008		, "@E 999.99%"	, 7							) //"Ref. Parcial"
	    TRCell():New(oSection2	, "TOTAL"		, 'GI2'	, STR0009		, "@E 999.99%"	, 7							) //"Total"
	    TRCell():New(oSection2	, "GI2_PREFIX"	, 'GI2'	, "Prefixo"		, "@!"			, TamSx3('GI2_PREFIX')[1]	) //"Prefixo"
		
		
		oBreak:= TRBreak():New(oSection2,{||oSection1:Cell("GI2_TIPLIN") },"",.T.)
	 
		oBreak:SetPageBreak(.T.)
		            
Return (oReport)

/*/{Protheus.doc} PrintReport
(long_description)
@type function
@author jacomo.fernandes
@since 16/11/2018
@version 1.0
@param oReport, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function PrintReport( oReport )
 
	Local cTmpGI2       := GetNextAlias()
	Local oSection1 	:= oReport:Section(1)
	Local oSection2 	:= oSection1:Section(1)
	Local cTpLinha		:= ""
	Local lFistPage		:= .T.
	Local cNomeLinha	:= ""
	Local nCnt          := 1
	Local aArrayTst     := {}
	Local aCoeficien    := {}
	
	aArrayTst := GeraInf( )
	
	oReport:SetMeter(LEN(aArrayTst))

	oReport:StartPage()
	oReport:SkipLine()
	
	//Seta o valor do relatório
	For nCnt := 1 To Len(aArrayTst)
		If oReport:Cancel()
			Exit
		EndIf
		oReport:IncMeter()
		
		If cTpLinha <> aArrayTst[nCnt,16]
			
			oSection1:Cell("GI2_TIPLIN"):SetValue(aArrayTst[nCnt,16])
			oSection1:Cell("GQC_DESCRI"):SetValue(AllTrim(Posicione('GQC',1, xFilial('GQC')+aArrayTst[nCnt,16] ,"GQC_DESCRI")))
			
			If !lFistPage
				oSection2:Finish()
				oSection1:Finish()
			Endif
			
			oSection1:Init()
			oSection1:Printline()
			
			oSection2:Init()
			
			cTpLinha := aArrayTst[nCnt,16] 
			lFistPage:= .F.
			
		Endif
		
		cNomeLinha	:= aArrayTst[nCnt,02]
		//nReceita,nLugares,nTarifa,nQtdViagem, ida ordinaria, volta ordinaria, km
		aCoeficien	:= CalculaCoef(aArrayTst[nCnt])
		
		oSection2:Cell("CODIGO"		):SetValue(aArrayTst[nCnt,05])
		oSection2:Cell("LINHA"		):SetValue(cNomeLinha)
		oSection2:Cell("ORDIN"		):SetValue(aCoeficien[1])
		oSection2:Cell("MULTIP"		):SetValue(0)
		oSection2:Cell("RFTOTAL"	):SetValue(aCoeficien[2])
		oSection2:Cell("RFPARCIAL"	):SetValue(0)
		oSection2:Cell("TOTAL"		):SetValue(aCoeficien[3])
		oSection2:Cell("GI2_PREFIX"	):SetValue(aArrayTst[nCnt,01])
		
		oSection2:Printline()
	Next
	
	oSection2:Finish()
	oSection1:Finish()
	
Return

/*/{Protheus.doc} CalculaCoef
Função responsavel para calcular o coeficiente médio
@type function
@author jacomo.fernandes
@since 16/11/2018                                                           
@version 1.0
@param aCoeficien, array, (Dados para calculo)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function CalculaCoef(aCoeficien)
Local nValOrd    := 0
Local nValRef    := 0
Local nValTotal  := 0

//Ordinaria
nValOrd := (((aCoeficien[17] + aCoeficien[18]) * aCoeficien[26])/((VAL(aCoeficien[03]) * VAL(aCoeficien[06])) * aCoeficien[26])) * 100

//Reforço total
nValRef := (((aCoeficien[19] + aCoeficien[20]) * aCoeficien[26])/((VAL(aCoeficien[03]) * VAL(aCoeficien[12])) * aCoeficien[26])) * 100

//Total linha
nValTotal := (((aCoeficien[17] + aCoeficien[18]) * aCoeficien[26]) + ((aCoeficien[19] + aCoeficien[20]) * aCoeficien[26]) )
nValTotal := ((nValTotal) / ( (((VAL(aCoeficien[03]) * VAL(aCoeficien[06])) * aCoeficien[26])) + (((VAL(aCoeficien[03]) * VAL(aCoeficien[12])) * aCoeficien[26]))) ) * 100


Return {nValOrd,nValRef, nValTotal}


Static Function GeraInf()
Local cNumLin     := ''
Local nVlTotal    := 0
Local aTotais     := {0,0,0,0,0,0,0,0,0}//Convencional:Ida,Volta|Multipla:Ida,Volta|Total:Ida,Voltta|Parcial:Ida,Volta|TOTAIS
Local aInfs       := {}
Local lLim        := .F.
Local nX          := 0
Local cMedLot     := ''
Local aTotViag    := {}
Local cTmpGI2     := GetNextAlias()
Local aArGtpF     := {}
Local aAux        := {}
Local nOrdIda     := 0
Local nOrdVolta   := 0
Local nRefToIda   := 0
Local nRefToVolta := 0
Local nTarVal     := 0
Local nTotOrd     := 0
Local nTotRef     := 0
Local nKMVal      := 0
Local nTotRT      := 0
Local nX          := 0

	G423RetLin(@cTmpGI2 )
	
	(cTmpGI2)->(dbGotop())
	
	While !(cTmpGI2)->(Eof())
		
		cNumLin	:= (cTmpGI2)->GI2_NUMLIN
		
		cMedLot	:= G423MedLot((cTmpGI2)->GI2_COD, MV_PAR06, MV_PAR07, 2 )
		
		G423TViag((cTmpGI2)->GI2_NUMLIN, MV_PAR06, MV_PAR07, @nTotOrd, @nTotRT)

		G423RetTrc(cNumLin, @aInfs,nTotOrd,nTotRT)
			
		nTotOrd := 0
		nTotRT  := 0
		
		lLim     := .F.
		
		aTotais 	:= {{0,0,0,0,0,0,0,0,0,0,0}}
		nVlTotal	:= 0
		
		For nX := 1 to Len(aInfs)
		
			nOrdIda += aInfs[nX][9] //ordinaria ida
			nOrdVolta +=  aInfs[nX][10] //ordinaria volta
			// '0'//multipla ida
			// '0'//multipla volta
			nRefToIda += aInfs[nX][11]//reforço total ida
			nRefToVolta += aInfs[nX][12]//reforço total volta
			// '0' //reforço total ida
			// '0' //reforço total volta
			nKMVal := IIF(nKMVal < aInfs[nX][14],aInfs[nX][14],nKMVal)
			nTarVal := IIF(nKMVal < aInfs[nX][14],aInfs[nX][07],nTarVal)
			nTotOrd += ((aInfs[nX][9]+aInfs[nX][10]) * aInfs[nX][7])
			nTotRef += ((aInfs[nX][11]+aInfs[nX][12]) * aInfs[nX][7])
			                                                                       
			nVlTotal += ((aInfs[nX][9]+aInfs[nX][10]+aInfs[nX][11]+aInfs[nX][12]) * aInfs[nX][7])
			
		Next nX
		
		aAux := ImprCabec(@cTmpGI2, cMedLot, @aTotViag)
		AADD(aArGtpF, {aAux[01],;   // 01
						aAux[02],;  // 02
						aAux[03],;  // 03
						aAux[04],;  // 04
						aAux[05],;  // 05
						aAux[06],;  // 06
						aAux[07],;  // 07
						aAux[08],;  // 08
						aAux[09],;  // 09
						aAux[10],;  // 10
						aAux[11],;  // 11
						aAux[12],;  // 12
						aAux[13],;  // 13
						aAux[14],;  // 14
						aAux[15],;  // 15
						(cTmpGI2)->GI2_TIPLIN,; //16
						nOrdIda,;    // 17
						nOrdVolta,;  // 18
						nRefToIda,;  // 19
						nRefToVolta,;// 20
						nTarVal,;    // 21
						nTotOrd,;    // 22
						nTotRef,;    // 23
						nVlTotal,;   // 24
						PADL(alltrim(aAux[05]),6,"0"),;//25
						nKMVal}) //26
		
		nOrdIda     := 0
		nOrdVolta   := 0
		nRefToIda   := 0
		nRefToVolta := 0
		nTarVal     := 0
		nTotOrd     := 0
		nTotRef     := 0
		nKMVal      := 0
		
		ASORT(aArGtpF, , , { | x,y | (x[16]+x[25]) < (y[16]+y[25]) } )
		
		(cTmpGI2)->(dbSkip())
	
	EndDo	

	(cTmpGI2)->(dbCloseArea())
	
Return aArGtpF
//------------------------------------------------------------------------------------------

Static Function ImprCabec( cTmpGI2, cMedLot, aTotViag)

Local aTotais   := {0,0,0,0,0,0,0,0,0} // Ordinaria:Ida,Volta|Multipla:Ida,Volta|Total:Ida,Voltta|Parcial:Ida,Volta|TOTAIS
Local cNumLin   := (cTmpGI2)->GI2_NUMLIN
Local nTotOrd   := 0
Local nTotRT    := 0
Local nX        := 0
Local cTotViag := ""
Local aAux      := {}

	For nX := 1 to Len(aTotViag)
		If aTotViag[nX][1] == 'F'
			nTotOrd += aTotViag[nX][2]
		Else
			nTotRT += aTotViag[nX][2]
		Endif
	Next
	
	AADD(aAux,AllTrim((cTmpGI2)->GI2_PREFIX))
    AADD(aAux,AllTrim((cTmpGI2)->DESCORI) + ' x ' + AllTrim((cTmpGI2)->DESCDES)) //'LINHA'
    AADD(aAux,cMedLot)   //'Lotação'
    AADD(aAux,cTotViag ) //Total de Viagens
    AADD(aAux,cNumLin)//'LINHA'
	
	AADD(aAux,PadL(nTotOrd, 5))//'ORDINÁRIAS'
	AADD(aAux,PadL(nTotOrd * Val(cMedLot), 6))//'ORDINÁRIAS'
	
	AADD(aAux,PadL(0,5))//'MULTIPAS'
	AADD(aAux,PadL(0,6))//'MULTIPLAS'
	
	AADD(aAux,PadL(0,5))//'REFORÇO PARCIAL'
	AADD(aAux,PadL(0,6))//'REFORÇO PARCIAL'
	
	AADD(aAux,PadL(nTotRT, 5))//'REFORÇO TOTAL'
	AADD(aAux,PadL(nTotRT * Val(cMedLot), 6))//'ORDINÁRIAS'
    
	AADD(aAux,PadL(nTotOrd + nTotRT,5))//'T O T A L'
	AADD(aAux,PadL((nTotOrd + nTotRT)* Val(cMedLot),6))//'T O T A L'
	
Return aAux
