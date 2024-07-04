#Include "GTPR305.ch"
#include 'protheus.ch'
#include 'parmtype.ch'
#Include 'TopConn.ch'

Static cAliasQry := GetNextAlias()

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPR305()
Resumo de Quadro de Linhas
@sample GTPR305()
@author SIGAGTP | Gabriela Naommi Kamimoto
@since 01/12/2017
@version P12
/*/
//-------------------------------------------------------------------
Function GTPR305()
Local oReport
Local cPerg  := 'GTPR308'

Pergunte(cPerg, .T.)
oReport := ReportDef(cPerg)
oReport:PrintDialog()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef()
@sample ReportDef(cPerg)
@param cPerg - caracter - Nome da Pergunta
@return oReport - Objeto - Objeto TREPORT
@author SIGAGTP | Gabriela Naommi Kamimoto
@since 01/12/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function ReportDef(cPerg)
Local cTitle    := STR0001 //"Lançamento de notas por caixa e agencia" //"Quadro de Resumo de Linha"
Local cHelp     := STR0002 //"Gera o relatório lançamento de notas por caixa e agencia" //"Gera Quadro de Resumo de Linha"
Local oReport
Local oSection
Local oSection1

oReport := TReport():New('GTPR305',cTitle,cPerg,{|oReport|ReportPrint(oReport)},cHelp,,,,,,,)
oReport:SetPortrait(.T.)
oReport:SetTotalInLine(.F.)

oSection1 := TRSection():New(oReport, cTitle, cAliasQry)
TRCell():New(oSection1,"TPLINHA", "GYN", , /*Picture*/, 100/*Tamanho*/, /*lPixel*/, /*{|| code-block de impressao }*/)
oSection1:SetHeaderSection(.F.)

oSection := TRSection():New(oReport, cTitle, cAliasQry)

TRCell():New(oSection,"GI2_NUMLIN","GYN","Núm. linha",X3Picture("GI2_NUMLIN"),TamSX3("GI2_NUMLIN")[1]+2  ) //"Código" //"Linha"
TRCell():New(oSection,"GYN_LINCOD","GYN",STR0004,X3Picture("GYN_LINCOD"),TamSX3("GYN_LINCOD")[1]+2  ) //"Código" //"Linha"
TRCell():New(oSection,"LINDESCRI" ,"GYN",STR0005,X3Picture("GI1_DESCRI"),TamSX3("GI1_DESCRI")[1]+40  ) //"Código" //"Descrição"

TRCell():New(oSection,"PREFIXO"   ,"GYG","N DER","@!",       010,,,"LEFT"  )
TRCell():New(oSection,"TMP_PRX"   ,"GYG","PRX",  "@!",       005,,,"LEFT"  )
TRCell():New(oSection,"TMP_PMM"   ,"GYG","PMM",  "@E 999,999,999.99",012,,,"LEFT"  )

TRCell():New(oSection,"VIAGEM",    "GYN","Qtd Viajens","@!",010,,,"RIGHT"  )
TRCell():New(oSection,"FROTA" ,"GYN","Frota Apl.", "@!",010,,,"RIGHT"  )
TRCell():New(oSection,"GYN_KMREAL","GYN",STR0006,X3Picture("GI2_KMIDA"),TamSX3("GI2_KMIDA")[1]+4,,,"RIGHT"  ) //"Descrição" //"Km Linha"
TRCell():New(oSection,"TEMPO"     ,"GYN",STR0008,"@!",TamSX3("GYN_HRINI")[1]+4,,,"LEFT" ) //"Valor" //"Tempo"
TRCell():New(oSection,"VELOCCOM"  ,"GYN",STR0012,X3Picture("GI2_KMMED"),TamSX3("GI2_KMMED")[1]+4,,,"RIGHT" ) //"Valor" //"Veloc Media"
TRCell():New(oSection,"HORASTRAB" ,"GYN",STR0009,"@!",TamSX3("GYN_HRFIM")[1]+10,,,"LEFT" ) //"Valor" //"Horas Trab"

oSection:SetHeaderPage(.F.)
oSection:SetHeaderSection(.T.)
TRFunction():New(oSection:Cell("GYN_LINCOD"),,"COUNT"  ,,,,,.T.,.T.,.T.)
TRFunction():New(oSection:Cell("TMP_PMM"   ),,"SUM"    ,,,,,.T.,.T.,.T.)
TRFunction():New(oSection:Cell("GYN_KMREAL"),,"SUM"    ,,,,,.T.,.T.,.T.)
TRFunction():New(oSection:Cell("TEMPO")     ,,"TIMESUM",,,,,.T.,.T.,.T.)
TRFunction():New(oSection:Cell("VELOCCOM")  ,,"SUM"    ,,,,,.T.,.T.,.T.)
TRFunction():New(oSection:Cell("HORASTRAB") ,,"TIMESUM",,,,,.T.,.T.,.T.)
	
Return oReport


//-------------------------------------------------------------------
/*/{Protheus.doc} MontQuery()
description
@author  Gabriela Naommi Kamimoto
@since   01/12/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function MontQuery()
Local cTpLinDe		:= MV_PAR01
Local cTpLinAte		:= MV_PAR02
Local dDataDe		:= MV_PAR03
Local dDataAte		:= MV_PAR04
Local cNumLinDe		:= MV_PAR05
Local cNumLinAte	:= MV_PAR06
Local aArray        := {}

BeginSql Alias cAliasQry
	
	SELECT 
		GI2.GI2_NUMLIN
		, GYN.GYN_LINCOD
		, GYN.GYN_CODIGO
		, GYN.GYN_DTINI
		, GYN.GYN_HRINI
		, GYN.GYN_DTFIM
		, GYN.GYN_HRFIM
		, GYN.GYN_LINSEN
		, GYN.GYN_CODGID
		, GI2.GI2_KMIDA KMTOTA
		, GI2.GI2_KMMED
		, GI2.GI2_PREFIX
		, GQC.GQC_CODIGO
		, GQC.GQC_DESCRI
		, GI2.GI2_FRTAPL
	FROM %Table:GI2% GI2
		INNER JOIN %Table:GYN% GYN ON
			GYN.GYN_FILIAL = GI2.GI2_FILIAL
			AND GYN.GYN_LINCOD = GI2.GI2_COD
			AND GYN.GYN_DTINI BETWEEN %Exp:dDataDe% AND %Exp:dDataAte%
			AND GYN.%NotDel%
		INNER JOIN %Table:GI4% GI4 ON
			GI4.GI4_FILIAL = GI2.GI2_FILIAL
			AND GI4.GI4_LINHA = GI2.GI2_COD
			AND GI4.GI4_HIST = '2'
			AND GI4.GI4_LOCORI = GI2_LOCINI
			AND GI4.GI4_LOCDES = GI2_LOCFIM
			AND GI4.%NotDel%
		INNER JOIN %Table:GI1% GI1ORI ON
			GI1ORI.GI1_FILIAL = %xFilial:GI1%
			AND GI1ORI.GI1_COD = (CASE 
									WHEN GI2.GI2_KMIDA > 0 THEN GI2.GI2_LOCINI
									WHEN GI2.GI2_KMVOLT > 0 THEN GI2.GI2_LOCFIM
									ELSE GI2.GI2_LOCINI
								END)
			AND GI1ORI.%NotDel% 
		INNER JOIN %Table:GI1% GI1DES ON
			GI1DES.GI1_FILIAL = %xFilial:GI1%
			AND GI1DES.GI1_COD = (CASE 
									WHEN GI2.GI2_KMIDA > 0 THEN GI2.GI2_LOCFIM
									WHEN GI2.GI2_KMVOLT > 0 THEN GI2.GI2_LOCINI
									ELSE GI2.GI2_LOCFIM
								END)
			AND GI1DES.%NotDel%
		INNER JOIN %Table:GQC% GQC ON
			GQC.GQC_FILIAL = %xFilial:GQC%
			AND GQC.GQC_CODIGO = GI2.GI2_TIPLIN 
			AND GQC.%NotDel%
	WHERE 
		GI2.GI2_FILIAL = %xFilial:GI2%
		AND GI2.GI2_NUMLIN BETWEEN %Exp:cNumLinDe% AND %Exp:cNumLinAte%
		AND GI2.GI2_TIPLIN BETWEEN %Exp:cTpLinDe% AND %Exp:cTpLinAte%
		AND GI2.GI2_HIST = '2'
		AND GI2.%NotDel%
	GROUP BY
		GI2.GI2_NUMLIN
		, GI2.GI2_TIPLIN
		, GYN.GYN_LINCOD
		, GYN.GYN_CODIGO
		, GYN.GYN_DTINI
		, GYN.GYN_HRINI
		, GYN.GYN_DTFIM
		, GYN.GYN_HRFIM
		, GYN.GYN_LINSEN
		, GYN.GYN_CODGID
		, GI2.GI2_KMIDA 
		, GI2.GI2_KMMED
		, GI2.GI2_PREFIX
		, GQC.GQC_CODIGO
		, GQC.GQC_DESCRI
		, GI2.GI2_FRTAPL
	ORDER BY
		GI2.GI2_TIPLIN
		, GI2_NUMLIN
			
EndSql

While (cAliasQry)->(!Eof())
	AADD(;
		aArray,{;
		(cAliasQry)->GI2_NUMLIN,;//01
		(cAliasQry)->GYN_CODIGO,;//02
		(cAliasQry)->GYN_DTINI ,;//03
		(cAliasQry)->GYN_HRINI ,;//04
		(cAliasQry)->GYN_DTFIM ,;//05
		(cAliasQry)->GYN_HRFIM ,;//06
		(cAliasQry)->GYN_LINSEN,;//07
		(cAliasQry)->GYN_CODGID,;//08
		(cAliasQry)->KMTOTA    ,;//09
		(cAliasQry)->GI2_KMMED ,;//10
		(cAliasQry)->GI2_PREFIX,;//11
		"",;//12
		(cAliasQry)->GQC_CODIGO,;//13
		(cAliasQry)->GQC_DESCRI,;//14
		"",;//15
		"",;//16
		(cAliasQry)->GYN_LINCOD,;//17
		(cAliasQry)->GI2_FRTAPL;
		};
	)
	
	(cAliasQry)->(DbSkip())
End 

(cAliasQry)->(dbclosearea())

Return aArray


//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint()
@sample ReportPrint(oReport)
@param oReport - Objeto - Objeto TREPORT
@author SIGAGTP | Gabriela Naommi Kamimoto
@since 01/12/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport)
Local oSection1		:= oReport:Section(1)
Local oSection		:= oReport:Section(2)
Local nHoras		:= 0 
Local nHrsTrab		:= 0
Local nQtdViagens	:= 0
Local nValPmm       := 0
Local nCnt          := 0
Local nProx         := 0
Local nTotalHrs     := 0 
Local nHoraAux      := 0 
Local cHrsTotal     := "00:00"  
Local nValAtu       := "00:00" 
Local cTpLinha		:= ""
Local cHoraFinal	:= ""
Local cHoraInicial	:= ""
Local cCodViagemOld	:= ""
Local cMotorista	:= ""
Local cCdLinha      := ""
Local aArray        := {}
Local aAux          := {}

aArray := MontQuery()

oReport:SetMeter(Len(aArray))

For nCnt := 1 To Len (aArray)
	If oReport:Cancel()
		Exit
	EndIf
	
	oReport:IncMeter()
	
	//Cálculo do tempo da Viagem
	cHoraFinal := SUBSTR(aArray[nCnt,06],1,2) // 0850
	cHoraFinal := cHoraFinal + ":" + SUBSTR(aArray[nCnt,06],3,2) 

	cHoraInicial := SUBSTR(aArray[nCnt,04],1,2)
	cHoraInicial := cHoraInicial + ":" + SUBSTR(aArray[nCnt,04],3,2)		
	
	If aArray[nCnt,05] == aArray[nCnt,03]
		nHoras := SubHoras(cHoraFinal,cHoraInicial)
	Else
		If aArray[nCnt,05] > aArray[nCnt,03]
			nHoras := SubHoras("24:00",cHoraInicial)
			nTotalHrs := IIF(At(".",cValToChar(nHoras)) > 0, StrTran(cValToChar(nHoras),".",":"),cValToChar(nHoras) + ":00")
			nTotalHrs := PADL(IIF(LEN(SubStr( nTotalHrs, At(":",nTotalHrs)+1, Len(nTotalHrs) )) < 2,nTotalHrs + "0",nTotalHrs),5,"0")
			nHoraAux := nTotalHrs
			nHoras := SubHoras(cHoraFinal,"00:00")
			nTotalHrs := IIF(At(".",cValToChar(nHoras)) > 0, StrTran(cValToChar(nHoras),".",":"),cValToChar(nHoras) + ":00")
			nTotalHrs := PADL(IIF(LEN(SubStr( nTotalHrs, At(":",nTotalHrs)+1, Len(nTotalHrs) )) < 2,nTotalHrs + "0",nTotalHrs),5,"0")
			nHoras := SomaHoras(nHoraAux,nTotalHrs)
		Else
			nHoras := SubHoras("24:00",cHoraFinal)
			nTotalHrs := IIF(At(".",cValToChar(nHoras)) > 0, StrTran(cValToChar(nHoras),".",":"),cValToChar(nHoras) + ":00")
			nTotalHrs := PADL(IIF(LEN(SubStr( nTotalHrs, At(":",nTotalHrs)+1, Len(nTotalHrs) )) < 2,nTotalHrs + "0",nTotalHrs),5,"0")
			nHoraAux := nTotalHrs
			nHoras := SubHoras(cHoraInicial,"00:00")
			nTotalHrs := IIF(At(".",cValToChar(nHoras)) > 0, StrTran(cValToChar(nHoras),".",":"),cValToChar(nHoras) + ":00")
			nTotalHrs := PADL(IIF(LEN(SubStr( nTotalHrs, At(":",nTotalHrs)+1, Len(nTotalHrs) )) < 2,nTotalHrs + "0",nTotalHrs),5,"0")
			nHoras := SomaHoras(nHoraAux,nTotalHrs)
		EndIf
	EndIf
	
	nTotalHrs := IIF(At(".",cValToChar(nHoras)) > 0, StrTran(cValToChar(nHoras),".",":"),cValToChar(nHoras) + ":00")
	nTotalHrs := PADL(IIF(LEN(SubStr( nTotalHrs, At(":",nTotalHrs)+1, Len(nTotalHrs) )) < 2,nTotalHrs + "0",nTotalHrs),5,"0")
	
	If VAL(StrTran(nTotalHrs,":",".")) > VAL(StrTran(nValAtu,":","."))
		nValAtu := nTotalHrs
	EndIf
		
	cMotorista := aArray[nCnt,16]		
	cDescri  := TPNomeLinh(aArray[nCnt,17])
	
	nQtdViagens++
	//GRUPO TIPO DE LINHA
	cTpLinha := aArray[nCnt,01]//GI2_NUMLIN

	If cCdLinha != aArray[nCnt,13]
		AADD(aAux,{{0,STR0011 + aArray[nCnt,14]}}) // Procura a celula GYN_CODIGO na Osection1, escreve e eta o valor //"Tipo de Linha : "
		
		cCdLinha   := aArray[nCnt,13]//GQC_CODIGO
		nHrsTotal  := 0
		cHrsTotal  := ""
		nTotalHrs  := 0
	EndIf

	If ALLTRIM(cTpLinha) != ALLTRIM(aArray[IIF(nCnt == Len(aArray), Len(aArray),nCnt+1),01]) .OR. nCnt == Len(aArray)
		
		//Calculo das Horas Trabalhadas
		nHrsTrab := nQtdViagens * HORATOINT(nValAtu)
		
		nHrsTrab := IIF(At(".",cValToChar(nHrsTrab)) > 0, StrTran(cValToChar(nHrsTrab),".",":"),cValToChar(nHrsTrab) + ":00")
		nHrsTrab := PADL(IIF(LEN(SubStr( nHrsTrab, At(":",nHrsTrab)+1, Len(nHrsTrab) )) < 2,nHrsTrab + "0",nHrsTrab),5,"0")

		If aArray[nCnt,05] == aArray[nCnt,03]
			cHrsTotal := SomaHoras(cHrsTotal,nHrsTrab)
		Else
			If aArray[nCnt,05] > aArray[nCnt,03]
				cHrsTotal := SomaHoras("24:00",nHrsTrab)
				cHrsTotal := SomaHoras(cHrsTotal,"00:00")
			Else
				cHrsTotal := SomaHoras("24:00",cHrsTotal)
				cHrsTotal := SomaHoras(nHrsTrab,"00:00")
			EndIf
		EndIf
		
		cHrsTotal := IIF(At(".",cValToChar(cHrsTotal)) > 0, StrTran(cValToChar(cHrsTotal),".",":"),cValToChar(cHrsTotal) + ":00")
		cHrsTotal := PADL(IIF(LEN(SubStr( cHrsTotal, At(":",cHrsTotal)+1, Len(cHrsTotal) )) < 2,cHrsTotal + "0",cHrsTotal),6,"0")
		
		AADD(aAux[LEN(aAux)],{;
								VAL(aArray[nCnt,01]),;      //01
								alltrim(aArray[nCnt,01]),;  //02
								aArray[nCnt,17],;           //03
								cDescri      ,;             //04
								aArray[nCnt,09],;           //05
								nValAtu      ,;             //06
								aArray[nCnt,10],;           //07
								cHrsTotal    ,;             //08
								aArray[nCnt,11],;           //09
								LEFT(aArray[nCnt,11], 3),;  //10
								0,;                         //11
								nQtdViagens,;               //12
								aArray[nCnt,18];            //13
		})
	
		cTpLinha := aArray[nCnt,01]
		cCodViagemOld := aArray[nCnt,02]
		nHrsTotal  := 0
		cHrsTotal  := ""
		nValPmm    := 0
		nTotalHrs  := 0
		nQtdViagens := 0
		nValAtu := ""
	EndIf	
Next nCnt

For nCnt := 1 To Len(aAux)
	aSort(aAux[nCnt],,,{|x,y| x[1] < y[1]})
Next nCnt
	
For nCnt := 1 To Len(aAux)
	If oReport:Cancel()
		Exit
	EndIf
	
	oSection:Finish()
	oSection1:Init()
	oSection1:Cell("TPLINHA"):SetValue(aAux[nCnt,1,2]) // Procura a celula GYN_CODIGO na Osection1, escreve e eta o valor //"Tipo de Linha : "
	
	oSection1:PrintLine()
	oSection1:Finish()
	oSection:Init()
	
	For nProx := 1 To Len(aAux[nCnt])
		If Len(aAux[nCnt, nProx]) = 13
			If aAux[nCnt,nProx,13] != 0
				nValPmm := (aAux[nCnt,nProx,05] / aAux[nCnt,nProx,13]) * aAux[nCnt,nProx,12]
			EndIf

			If aAux[nCnt,nProx,05] == 0
				aAux[nCnt,nProx,05] := aAux[nCnt,nProx,05]
			EndIf
		
			oSection:Cell("GI2_NUMLIN"):SetValue(aAux[nCnt,nProx,02])
			oSection:Cell("GYN_LINCOD"):SetValue(aAux[nCnt,nProx,03])
			oSection:Cell("LINDESCRI" ):SetValue(aAux[nCnt,nProx,04])
			oSection:Cell("GYN_KMREAL"):SetValue(aAux[nCnt,nProx,05])
			oSection:Cell("TEMPO"     ):SetValue(aAux[nCnt,nProx,06])
			oSection:Cell("VELOCCOM"  ):SetValue(aAux[nCnt,nProx,07])	
			oSection:Cell("HORASTRAB" ):SetValue(aAux[nCnt,nProx,08])
			oSection:Cell("PREFIXO"   ):SetValue(aAux[nCnt,nProx,09])
			oSection:Cell("TMP_PRX"   ):SetValue(aAux[nCnt,nProx,10])
			oSection:Cell("TMP_PMM"   ):SetValue(nValPmm            )
			oSection:Cell("VIAGEM"    ):SetValue(aAux[nCnt,nProx,12])
			oSection:Cell("FROTA"     ):SetValue(aAux[nCnt,nProx,13])
		
			oSection:PrintLine()
			nValPmm := 0
		EndIf
	Next nProx
Next nCnt

oSection:Finish()

Return
