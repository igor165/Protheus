#INCLUDE "pcoa103.ch"
#Include "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA103   บAutor  ณPaulo Carnelossi    บ Data ณ  20/07/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para ratear valores por periodo                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ    
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PCOA103(cPlan, cRev, cCta, cItemOrc, aPeriodo, aValores)
Local oWizard
Local cArquivo
Local aAreaAK1 := AK1->(GetArea())
Local aAreaAK2 := AK2->(GetArea())
Local aAreaAK3 := AK3->(GetArea())
Local aAreaAKE := AKE->(GetArea())
Local lRet 		:= .F.
Local lParam, lBrowse:=.T., lParam2, lParam3, lParam4
Local aParametros := {	{3,STR0001				, 1,{STR0002, STR0003}	,160,,.F.}, ; //"Parametros para o Rateio"###"Todos os Periodos "###"Informar o Periodo"
								{3,STR0004	, 1,{STR0005, STR0006}											,160,,.F.}, ; //"Ratear percentuais diferenciados"###"Sim"###"Nao"
								{4,"",.T.,STR0007,165,.F.,.F.}, ; //"Sugerir percentuais para os periodos"
								{4,"",.F.,STR0008,165,.F.,.F.} } //"Sugerir valor Informado para os periodos"

Local aConfig :=  { 1, 1, .T., .F.}

Local aParam2 := {	{ 1 ,STR0009, CtoD(Space(8)) ,"@D" 	 ,""  ,"" ,"!lAllPeriod" ,65 ,.T. }, ; //"Data inicial"
							{ 1 ,STR0010  , CtoD(Space(8)) ,"@D" 	 ,""  ,"" ,"!lAllPeriod" ,65 ,.T. }, ; //"Data final"
							{ 1 ,STR0011, 0 ,"@E 999,999,999.99" 	 ,""  ,"" ,"" ,65 ,.T. } } //"Valor a ser rateado"
Local aConfig2 := {CtoD(Space(8)), CtoD(Space(8)), 0}

Local aParam3  := {}
Local aConfig3 := {}

Local aParam4  := {}
Local aConfig4 := {}

Private lAllPeriod := .F.
Private lMaxPer	:= .F.
Private nLastPanel := 0

dbSelectArea("AK1")
dbSetOrder(1)
dbSeek(xFilial("AK1")+cPlan)

dbSelectArea("AK3")
dbSetOrder(1)
dbSeek(xFilial("AK3")+cPlan+cRev+cCta)
aPeriodo 	:= PcoRetPer()

mv_par01 := 1
mv_par02 := 1
mv_par03 := .T.
mv_par04 := .F.

oWizard := APWizard():New(STR0033/*<chTitle>*/,; //"Atencao"
									STR0012/*<chMsg>*/, STR0013/*<cTitle>*/, ; //"Este assistente lhe ajudara a ratear um determinado valor para os periodos da planilha atual."###"Rateio de Valores para o Or็amento"
									STR0014+; //"Voce devera escolher a forma do rateio e ao finalizar o assistente, este valor serแ rateado conforme os parametros solicitados."
									CRLF+CRLF+STR0015+Alltrim(AK1->AK1_CODIGO)+" - "+PadR(AK1->AK1_DESCRI,50)+; //"Planilha : "
									CRLF+CRLF+STR0016+cCta+; //"Conta : "
									CRLF+CRLF+STR0017+cItemOrc/*<cText>*/,; //"Item Orc.: "
									{||.T.}/*<bNext>*/, ;
									{|| .T.}/*<bFinish>*/,;
									/*<.lPanel.>*/, , , /*<.lNoFirst.>*/)

oWizard:NewPanel( STR0018/*<chTitle>*/,; //"Rateio de valor"
						 STR0019/*<chMsg>*/, ; //"Neste passo voce deverแ informar a forma do rateio para a planilha orcamentaria."
						 {||.T.}/*<bBack>*/, ;
						 {||lAllPeriod := (aConfig[1]!=2), aConfig2 := {AK1->AK1_INIPER, AK1->AK1_FIMPER, 0},.T.}/*<bNext>*/, ;
						 {||.T.}/*<bFinish>*/,;
						 .T./*<.lPanel.>*/,;
						 {||A103Rat1_Par(oWizard,@lParam, aParametros, aConfig), nLastPanel := 1}/*<bExecute>*/ )
					  
oWizard:NewPanel( STR0020/*<chTitle>*/,;  //"Periodo para o rateio"
						STR0021/*<chMsg>*/,;  //"Neste momento deverแ ser informado o periodo a ser considerado e o valor a ser rateado."
						{||.T.}/*<bBack>*/, ;
						{||If(!lAllPeriod, aPeriodo:=PcoRetPer(aConfig2[1],aConfig2[2]), NIL),A103ValPer(aConfig2, aPeriodo).And.aConfig2[3]>0}/*<bNext>*/, ;
						{||.T.}/*<bFinish>*/,;
						.T./*<.lPanel.>*/, ;
						{||A103Rat2_Par(oWizard, lParam2, aParam2, aConfig2, nLastPanel := 2)}/*<bExecute>*/ )

oWizard:NewPanel( STR0022/*<chTitle>*/,; //"Percentuais para os periodos "
 						STR0023/*<chMsg>*/, ; //"Neste passo voce deverแ informar os percentuais referente ao valor a serem considerado para o rateio."
 						{||.T.}/*<bBack>*/, ;
 						{||!ValMaxPer() .And. A103PercentVal(aConfig, aConfig3, aPeriodo)}/*<bNext>*/, ;
 						{||.T.}/*<bFinish>*/, ;
 						.T./*<.lPanel.>*/, ;
 						{||A103Rat3_Par(oWizard, lParam3, aParam3, aConfig3, aPeriodo, aConfig, aConfig2), nLastPanel := 3}/*<bExecute>*/ )

oWizard:NewPanel( STR0024/*<chTitle>*/,; //"Confirme os valores que serao rateados para os periodos. "
 						STR0025/*<chMsg>*/, ; //"Observacao: os Valores zerados nao serao repassados para os periodos."
 						{||.T.}/*<bBack>*/, ;
 						{||.T.}/*<bNext>*/, ;
 						{||aValores := aClone(aConfig4) ,lRet := .T.}/*<bFinish>*/, ;
 						.T./*<.lPanel.>*/, ;
 						{||A103Rat4_Par(oWizard, lParam4, aParam4, aConfig4, aPeriodo, aConfig, aConfig2, aConfig3), nLastPanel := 4}/*<bExecute>*/ )

oWizard:Activate( .T./*<.lCenter.>*/,;
						 {||.T.}/*<bValid>*/, ;
						 {||.T.}/*<bInit>*/, ;
						 {||.T.}/*<bWhen>*/ )

RestArea(aAreaAK1)
RestArea(aAreaAK2)
RestArea(aAreaAK3)
RestArea(aAreaAKE)

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณA103Rat1_Par บAutor  ณPaulo Carnelossi  บ Data ณ 20/07/05   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para escolha da forma do rateio                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A103Rat1_Par(oWizard, lParam, aParametros, aConfig)

If lParam == NIL
	ParamBox(aParametros ,STR0026, aConfig,,,.F.,120,3, oWizard:oMPanel[oWizard:nPanel])  //"Parametros"
	lParam := .T.
Else
	a103Rest_Par(aConfig)
EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณA103Rat2_Par  บAutor  ณPaulo Carnelossi  บ Data ณ 20/07/05  บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para parametrizar o periodo e o valor a ser rateado  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A103Rat2_Par(oWizard, lParam2, aParam2, aConfig2)

If lParam2 == NIL
	ParamBox(aParam2 ,STR0026, aConfig2,,,.F.,120,3, oWizard:oMPanel[oWizard:nPanel])  //"Parametros"
  	lParam2 := .T.
Else
	a103Rest_Par(aConfig2)
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณA103Rat3_Par  บAutor  ณPaulo Carnelossi  บ Data ณ 20/07/05  บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para parametrizar os percentuais nos periodos        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A103Rat3_Par(oWizard, lParam3, aParam3, aConfig3, aPeriodo, aConfig, aConfig2)
Local nX, nPercDef, aRetPer, dAuxIni, dAuxFim
Local lPeriodo
Local nDif := 0

oWizard:oMPanel[oWizard:nPanel]:freechildren()

lMaxPer	:= .F.
if nLastPanel <> 4
	aParam3 := ASize(aParam3,0)
	aConfig3 := {}
	If aConfig[1] == 1 //todos os periodos
		If aConfig[3] .OR. aConfig[4]
   			If aConfig[4]
				nPercDef := 100
			Else
				nPercDef := Round(100/Len(aPeriodo),8) //"@E 999.99999999 %"
			EndIf	
		Else
			nPercDef := 0
		EndIf		
		aAdd(aParam3, {4,STR0027,aConfig[3],"  ",165,.F.,.F.}) //"Informar Percentuais"
		aAdd(aConfig3, aConfig[3])
		For nX := 1 TO Len(aPeriodo)
			aAdd(aParam3,{ 1 ,aPeriodo[nX], nPercDef ,"@E 999.99999999 %" 	 ,""  ,"" ,"",65 ,.T. }) 
			aAdd(aConfig3, nPercDef)
		Next
	Else
		dAuxIni := aConfig2[1]
		dAuxFim := aConfig2[2]
   
		aRetPer := A103DetPeriodo(dAuxIni, dAuxFim, aPeriodo)
		nPeriodo := (aRetPer[2]-aRetPer[1])+1
   
		If aConfig[3] .OR. aConfig[4]
			If aConfig[4]
				nPercDef := 100
			Else
				nPercDef := Round(100/nPeriodo,8) //"@E 999.99999999 %"
			EndIf	
		Else
			nPercDef := 0
		EndIf		

		aAdd(aParam3, {4,STR0027,(aConfig[2]==1),"  ",165,.F.,.T.}) //"Informar Percentuais"
		aAdd(aConfig3, (aConfig[2]==1))
		For nX := 1 TO Len(aPeriodo)
		   lPeriodo := (nX >=aRetPer[1].And.nX<=aRetPer[2])
			If lPeriodo
				aAdd(aParam3,{ 1 ,aPeriodo[nX], If(lPeriodo, nPercDef, 0) ,"@E 999.99999999 %" 	 ,""  ,"" ,If(lPeriodo.And.aConfig[2]==1 , "", ".F.") ,65 ,.T. }) 
				aAdd(aConfig3, If(lPeriodo, nPercDef, 0))
			EndIf
		Next
	EndIf		

	nDif := 100 - (nPercDef * (Len(aParam3)-1))

	If nDif <> 0 .and. Abs(nDif) < 100 //Tem diferenca de valor e eh menor que 100.
		aParam3[Len(aParam3)][3] += nDif
		aConfig3[Len(aConfig3)] += nDif
	EndIf

Endif

If lParam3 == NIL
	If Len(aParam3) <= 60 	
		ParamBox(aParam3 ,STR0026, aConfig3,,,.F.,120,3, oWizard:oMPanel[oWizard:nPanel])  //"Parametros"
  		lParam3 := .T.
  	Else
		lMaxPer := .T.
		ValMaxPer()
	EndIf
Else
	a103Rest_Par(aConfig3)
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณA103Rat4_Par  บAutor  ณPaulo Carnelossi  บ Data ณ 29/07/05  บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para informar os valores a ser rateado para os       บฑฑ
ฑฑบ          ณperiodos                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A103Rat4_Par(oWizard, lParam4, aParam4, aConfig4, aPeriodo, aConfig, aConfig2, aConfig3)
Local nX  
Local nUltArray := 0
Local nTotVal	:= 0

aParam4 := {}
aConfig4 := {}

For nX := 2 TO Len(aPeriodo)+1
	If aConfig3[nX] > 0
		nValorRat := Round(aConfig2[3]*(aConfig3[nX]/100),TamSX3("AK2_VALOR")[2])
		aAdd(aParam4,{ 1 ,aPeriodo[nX-1], nValorRat ,"@E 999,999,999.99" 	 ,""  ,"" , ".F.",65 ,.T. }) 
		aAdd(aConfig4, nValorRat)
		nTotVal += nValorRat
		nUltArray := nX
	Else
		aAdd(aParam4,{ 1 ,aPeriodo[nX-1], 0 ,"@E 999,999,999.99" 	 ,""  ,"" , ".F.",65 ,.T. }) 
		aAdd(aConfig4, 0)
	EndIf	
Next

If nUltArray == Len(aPeriodo)+1 //O tamanho da variแvel estแ maior que o tamanho total do array?
	nUltArray--
EndIf

If (aConfig2[3] - nTotVal) > 0 //Tem diferenca de valor
	aConfig4[nUltArray] += (aConfig2[3] - nTotVal)
	aParam4[nUltArray][3] += (aConfig2[3] - nTotVal)
EndIf

If lParam4 == NIL
	ParamBox(aParam4 ,STR0026, aConfig4,,,.F.,120,3, oWizard:oMPanel[oWizard:nPanel])  //"Parametros"
  	lParam4 := .T.
Else
	a103Rest_Par(aConfig4)	
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัอออออออออออออออออออหออออออัออออออออออออปฑฑ
ฑฑบPrograma  ณa103Rest_ParบAutor  ณPaulo Carnelossi   บ Data ณ 30/07/05   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯอออออออออออออออออออสออออออฯออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para restauracao dos conteudos das variaveis MV_PAR  บฑฑ
ฑฑบ          ณna navegacao entre os paineis do assistente de copia        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function a103Rest_Par(aParam)
Local nX
Local cVarMem

For nX := 1 TO Len(aParam)
	cVarMem := "MV_PAR"+AllTrim(STRZERO(nX,2,0))
	&(cVarMem) := aParam[nX]	
Next

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA103DetPeriodoบAutor  ณPaulo Carnelossiบ Data ณ  01/08/05   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDetermina o periodo de acordo com os parametros informados  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A103DetPeriodo(dAvalIni, dAvalFim, aPeriodo)
Local aRetPer := { CtoD(Space(8)), CtoD(Space(8)) }
Local nX, dIni, dFim

For nX := 1 TO Len(aPeriodo)
	dIni := CTOD(Subs(aPeriodo[nX], 1, 10))
	dFim := CTOD(Alltrim(Subs(aPeriodo[nX], 14)))
	If dAvalIni >= dIni .And. dAvalIni <= dFim
		aRetPer[1] := nX
		Exit
	EndIf
Next

For nX := 1 TO Len(aPeriodo)
	dIni := CTOD(Subs(aPeriodo[nX], 1, 10))
	dFim := CTOD(Alltrim(Subs(aPeriodo[nX], 14)))
	If dAvalFim >= dIni .And. dAvalFim <= dFim
		aRetPer[2] := nX
		Exit
	EndIf
Next

Return aRetPer

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA103ValPerบAutor  ณPaulo Carnelossi    บ Data ณ  01/08/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida o periodo informado no Wizard                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A103ValPer(aConfig2, aPeriodo)
Local lRet 
Local nPosDtFim

If Len(aPeriodo) == 0
	lRet := .F.
Else
	lRet := .T.
	nPosDtFim := At("-", aPeriodo[Len(aPeriodo)]) + 1
EndIf

If lRet		
	lRet := ( aConfig2[1] >= CtoD( Subs(aPeriodo[1], 1, 10) ))
EndIf

If lRet
	lRet := ( aConfig2[2] >= CtoD(Subs(aPeriodo[1], 1, 10) ))
EndIf

If lRet
	lRet := ( aConfig2[2] <= CtoD(Alltrim( Subs( aPeriodo[Len(aPeriodo)], nPosDtFim ) )))
EndIf

If !lRet
	Aviso(STR0028,STR0029,{"Ok"}) //"Data Invalida"###"As datas informadas nao sao validas para o periodo da planilha. Verifique."
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA103PercentValบAutor  ณPaulo Carnelossiบ Data ณ  01/08/05   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida percentuais informados para atingir 100% (exceto em  บฑฑ
ฑฑบ          ณcaso de sugestao de valor para o periodo)                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A103PercentVal(aConfig, aConfig3, aPeriodo)
Local nX, lRet := .F.
Local nSum := 0
Local nDif := 0

For nX := 2 TO Len(aPeriodo)+1
    nSum += aConfig3[nX]
Next

If aConfig[4]
	lRet := .T.   //nao valida se valor fixo para os periodos
Else	
	If aConfig[2]==2
		nDif := 100.00-Round(nSum,4)
		If nDif != 0
			aConfig3[Len(aConfig3)] := aConfig3[Len(aConfig3)]+nDif
		EndIf
		lRet := .T.
	Else
		lRet := (Round(nSum,4)==100.00)
		If !lRet
			Aviso(STR0030,STR0031+CRLF+CRLF+STR0032+Str(nSum,12,4)+" %",{"Ok"}) //"Percentual Invalido"###"Os percentuais informados devem atingir somente 100%. Verifique."###"Percentual Atingido: "
		EndIf
	EndIf
EndIf
	
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณValMaxPer     บAutor  ณMicrosiga       บ Data ณ  01/08/05   บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo para apresenta็ใo de mensagem de valida็ใo           บฑฑ
ฑฑบ          ณ                 											  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function ValMaxPer()

If lMaxPer
	MsgAlert(STR0034)
EndIf

Return lMaxPer
