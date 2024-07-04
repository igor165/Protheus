#include "protheus.CH"
#include "FINRETIBB.CH"

Static lFWCodFil := ExistFunc("FWCodFil")
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRetIBBDeb บAutor  ณ                    บ Data ณ  31/07/2020 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ RetIBBDeb  - Calculo de Ret de IIBB para  NF               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ARGRetIB (FINRETARG)                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ 1. cAgente: Agente de retenci๓n (N = No/ S = Si).          บฑฑ
ฑฑ           ณ 2. nSigno: 1 / (-1)Si SE2->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG.บฑฑ
ฑฑ           ณ 3. nSaldo: Saldo (valor baser o valor a bajar).            บฑฑ
ฑฑ           ณ 4. cCF                                                     บฑฑ
ฑฑ           ณ 5. cProv                                                   บฑฑ
ฑฑ           ณ 6. lPA                                                     บฑฑ
ฑฑ           ณ 7. nPropImp                                                บฑฑ
ฑฑ           ณ 8. aConfProv                                               บฑฑ
ฑฑ           ณ 8. lSUSSPrim                                               บฑฑ
ฑฑ           ณ 10.lIIBBTotal                                              บฑฑ
ฑฑ           ณ 11.aImpCalc: Array con impuesto calculado IB...            บฑฑ
ฑฑ           ณ 12.aSUSS                                                   บฑฑ
ฑฑ           ณ 13.nLinha                                                  บฑฑ
ฑฑ           ณ 14.lLimNRet                                                บฑฑ
ฑฑ           ณ 15.cChavePOP: FJK_PREOP+Proveedor+Loja, usada en ObtReten()บฑฑ
ฑฑ           ณ 16.cNFPOP: Num de documento(E2_NUM), usado en ObtReten().  บฑฑ
ฑฑ           ณ 17.cSeriePOP: Serie(E2_PREFIXO), usada en ObtReten().      บฑฑ
ฑฑ           ณ 18.dEmissao: Fch emisi๓n CXP(E2_EMISSAO), usada ObtReten().บฑฑ
ฑฑ           ณ 19.lOPRotAut: .T. Si es generaci๓n automแtica.             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function RetIBBDeb(cAgente,nSigno,nSaldo,cCF,cProv,lPA,nPropImp,aConfProv,lSUSSPrim,lIIBBTotal,aImpCalc,aSUSS,nLinha,lLimNRet,cChavePOP,cNFPOP,cSeriePOP,dEmissao,lOPRotAut)
Local aZonaIb 	:= {}
Local aSFEIB	:= {}
Local aPerIB	:= {}
Local aProvVerif:= {}
Local aAreaAnt	:= {}
Local aImpInf 	:= {}
Local aCF 		:= {}
Local aFil		:= {}
Local aAreaSFF 	:= {}
Local aRes      := {}
Local lCalcIb	:= .T.
Local lCalImpos	:= .F.
Local lCalcMon 	:= .F.
Local lRet 		:= .F.
Local lIsento	:= .F.
local lGravoPa 	:= .T.
Local lThdezb	:= .F.	
Local lPropIB	:= Iif(GetMV("MV_PROPIB",.F.,1)==2,.T.,.F.)
Local lExisCGF	:= TableInDic("CGF")
Local lNoIns    := .F.
Local lCalNoIns := .F.
Local lSmRMCR   := .F.
Local ltpLimVa  := .F.
Local cProvEnt 	:= ""
Local cChave	:= ""
Local cQuery 	:= ""
Local cTabTemp	:= ""
Local cItem		:= ""	
Local cEmpAct	:= ""
Local cZona		:= ""
Local cSituaca  := ""
Local nRatValImp:= 0
Local nRateio	:= 0
Local nValMerc	:= 0
Local nJ		:= 0
Local nPosIb	:= 0
Local nPosRet	:= 0
Local nRecSM0	:= 0
Local nMoeda	:= 1
Local nAliq     := 0
Local nVlrTotal	:= 0
Local nPos      := 0
Local nI, nA	:= 0
Local aI, aX		:= 0
Local nTotRetSFE:= 0
Local nTotBasSFE:= 0
Local nLimMInRet:= 0
Local nImposto	:= 0
Local nBaseAtual:= 0
Local nImpAtual	:= 0
Local nRetencao	:= 0
Local nTotBase	:= 0
Local nRecSFF 	:= 0
Local nDeduc	:= 0
Local nCofRet	:= 0
Local nMinUnit	:= 0
Local nMinimo	:= 0
Local nItem		:= 0
Local nNumRegs 	:= 0
Local nAliqAux	:= 0
Local nCoefmul	:= 0
Local nPercTot	:= 1   
Local nAliqRet 	:= 0 
Local nAliqAdc 	:= 0 
Local nObtMin 	:= 0
Local nLmRMCR		:= 0
Local cCond		:= 0
Local cZonaSFH := ""
Local cTipoSFH := ""
Local lAgRetCCO := .T.
Local nRecSF1	:= 0 
Local nTamSer := SerieNfId('SF1',6,'F1_SERIE')
Local lTESNoExen := .F.
Local cTipoCalc 	:= ""
Local nValorRet 	:= 0
Local nImpCalc 	:= 0
Local nCRFRET   := 0
Local cOriMin := ""
Local aRetPreO 	:= {}
Local nCOTipMin 	:= 0
Local nTotCCO3 	:= nSaldo
Local lCCOLimRet := Iif(aConfProv[7] <> " ", .T., .F.)
Local cChaveSFE := ""
Local nLimiteSFF := 0
Local lLimPrim := .F.
Local nPrAliqIB := 1
Local lBxParcial := Iif(SE2->E2_SALDO < SE2->E2_VALOR,.T.,.F.)
Local lAjusta	:= .F.
Local lCalcPa	:= .F.
Local lCalPaIns	:= .F.
Local cTabCGF 	:= ""
Local nAliqCGF  := 0
Local lYaAsCGF  := .F.
Local cZonaCGF	:= ""
Local lRN4212   := .F.
Local nPosTes	:= 0
Local aTesNf 	:= {}
Local cMVAgIIBB := GetMv("MV_AGIIBB",,"CF|BA|SF|SE|TU|SA|JU|SL|MI|FO|ME|ER|SJ|LR|CO|CB|CA|NE|LP|TF|CH|RN|CR")

If	type("cFornece")=="U"
	cFornece	:=SE2->E2_FORNECE
	cLoja		:=SE2->E2_LOJA
EndIf

DEFAULT nSigno		:= 1
DEFAULT nPropImp	:= 1
DEFAULT aConfProv	:= {}
DEFAULT lSUSSPrim	:= .T.
DEFAULT lIIBBTotal:= .F.
DEFAULT aImpCalc	:= {}
DEFAULT aSUSS		:= {}
DEFAULT nLinha	:= 1
DEFAULT lLimNRet := .F.
DEFAULT cChavePOP:= ""
DEFAULT cNFPOP	 := ""
DEFAULT cSeriePOP:= ""
DEFAULT dEmissao := CTOD("//")
DEFAULT lOPRotAut:= .F.

If lShowPOrd .and. Funname() == "FINA847" .and. Type("lCtaCte")<>"U" .and. lCtaCte
	Return aSFEIB := ObtReten(cChavePOP,cNFPOP,cSeriePOP,"B",nSaldo,dEmissao,aConfProv)
EndIf
//?Obter Impostos somente qdo a Empresa Usuario for Agente de Retenๅญo.?
lEsRetAdc := .F.
aArea:=GetArea()
If !Empty(cMVAgIIBB) .And. nSigno > 0
	SA2->( dbSetOrder(1) )
	If !lPA
		If lMsFil .And. !Empty(xFilial("SA2")) .And. xFilial("SF1") == xFilial("SA2")
			SA2->( MsSeek(SE2->E2_MSFIL+SE2->E2_FORNECE+SE2->E2_LOJA) )
		Else
			SA2->( MsSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA) )
		Endif
	Else
		SA2->( MsSeek(xFilial("SA2")+CFORNECE+CLOJA) )
	Endif
	
	//?Generar las Retenci๎•” de Ingresos Brutos                       ?
	//?Reter Ingressos Brutos somente se valor total da Orden de Pago ?
	//?for igual ou maior que $400,00.                                ?

	If SA2->(ColumnPos("A2_DTICALB")) > 0 .And. SA2->(ColumnPos("A2_DTFCALB")) > 0 ;
	   .And. !Empty(SA2->A2_DTICALB) .And. !Empty(SA2->A2_DTFCALB)
	    If  ( Dtos(dDataBase)>= Dtos(SA2->A2_DTICALB) ) .And. ( Dtos(Ddatabase) <= Dtos(SA2->A2_DTFCALB) )
	   		lCalcIb:=.F.
	    EndIf
	EndIf

	If ExistBlock("F0851IMP")
		lCalcIb:=ExecBlock("F0851IMP",.F.,.F.,{"IB"})
	EndIf

	If lCalcIb .And. SA2->A2_RETIB == "S"
    	If lRetPa .and. lPA
    		nMoeda := nMoedaCor
			nPosIb := Ascan(aZonaIb,{|X| X[1]==cCF .And. X[2]==cProv})

			//Por Entrega
			If aConfProv[2] == "1" .And. aConfProv[3] == "1" .And. aConfProv[1] == cProv
				cProvEnt := cProv
				lCalcPa := .T.
			//Por Pago
			ElseIf aConfProv[2] == "1" .And. aConfProv[3] == "2"
				SX5->(MsSeek(xFilial()+"74"))
				cSucur := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )

				nRecSM0 := SM0->(RecNo())
				cEmpAct := SM0->(M0_CODIGO)
				
				SM0->(MsSeek(cEmpAct+cSucur))
				If SM0->(FOUND()) .And. aConfProv[1] == SM0->M0_ESTENT
					cProvEnt := SM0->M0_ESTENT
					lCalcPa := .T.
				EndIf
				SM0->(DbGoto(nRecSM0))
			//Por Inscri็ขo
			ElseIf aConfProv[2] == "1" .And. aConfProv[3] == "3"
				cProvEnt := aConfProv[1]
				lCalPaIns	:= .T.
			Endif					
			
			If CCO->(ColumnPos("CCO_TPRET")) > 0 .and. CCO->(ColumnPos("CCO_TPRENI")) > 0  
				If NoInsSFH(SA2->A2_COD,SA2->A2_LOJA,"IBR", aConfProv[1]) //Identifica tratamiento Retencion sujeto No inscripto
					aRes:= NoInsCCORet( aConfProv[1],cProv)
					lCalNoIns := aRes[1][2]
					lNoIns := IIf(!Empty(aRes[1][1]),.T.,.F.)  
				EndIf 	
			EndIf
			
			AAdd(aZonaIb,{cProvEnt,cCF,nSaldo,aConfProv[4],.F.,""})

		Else

			dbSelectArea("SF1")
			SF1->(dbSetOrder(1))
			If lMsfil
				nRecSF1 := FINBuscaNF(SE2->E2_MSFIL,SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_FORNECE,SE2->E2_LOJA,"SF1",.T.)
				SF1->(dbGoTo(nRecSF1))
			Else
				nRecSF1 := FINBuscaNF(xFilial("SF1",SE2->E2_FILORIG),SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_FORNECE,SE2->E2_LOJA,"SF1",.T.)
				SF1->(dbGoTo(nRecSF1))
			EndIf
			
			If nRecSF1 > 0
				cChave := SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA

				nRateio     := SF1->F1_VALMERC / SF1->F1_VALBRUT

				nRatValImp  := Iif(aConfProv[4] == "M" .And. !lPropIB,1,( Round(xMoeda(nSaldo,SE2->E2_MOEDA,1,,5,aTxMoedas[Max(SE2->E2_MOEDA,1)][2]),MsDecimais(1)) / Round(xMoeda(SF1->F1_VALBRUT,SF1->F1_MOEDA,1,,5,aTxMoedas[Max(SF1->F1_MOEDA,1)][2]),MsDecimais(1)) ) )
				nValMerc    := ( Round(xMoeda(nSaldo,SE2->E2_MOEDA,1,,5,aTxMoedas[Max(SE2->E2_MOEDA,1)][2]),MsDecimais(1)) * nRateio )
			   	nMoeda   := Max(nMoeda,SF1->F1_MOEDA)

				SD1->(DbSetOrder(1))
				If lMsfil
					SD1->(MsSeek(SF1->F1_MSFIL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
				Else
					SD1->(MsSeek(xFilial("SD1",SF1->F1_FILIAL)+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
				EndIf
				If SD1->(Found())
					nObtMin := 0
					Do While IIf(lMsfil,SD1->D1_MSFIL,xFilial("SD1",SF1->F1_FILIAL))==SD1->D1_FILIAL .And. SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA == cChave
						If AllTrim(SD1->D1_ESPECIE) <> Alltrim(SF1->F1_ESPECIE)
							SD1->(DbSkip())
							Loop
						Endif

						If NoInsSFH(SA2->A2_COD,SA2->A2_LOJA,"IBR", aConfProv[1]) //Identifica tratamiento Retencion sujeto No inscripto : NoInsSFH(SA2->A2_COD,SA2->A2_LOJA,"IBR", SA2->A2_EST)
							aRes:= NoInsCCORet( aConfProv[1],SD1->D1_PROVENT)  //NoInsCCORet( SA2->A2_EST,SD1->D1_PROVENT)
							If (aRes[1][1] == "2" .and. SD1->D1_PROVENT <> aConfProv[1]) .Or. (aConfProv[1] == "TU" .and. SA2->A2_EST <> "TU")
								SD1->(DbSkip())
								Loop
							Endif
							aRes := {}
						Else 
							aRes := {}
						Endif 

						cProvEnt := ""

						//Por Entrega
						If aConfProv[2] == "1" .And. aConfProv[3] == "1"
							If SD1->(ColumnPos("D1_PROVENT")) >0 .And. !Empty(SD1->D1_PROVENT) .And. aConfProv[1] == SD1->D1_PROVENT
								cProvEnt := SD1->D1_PROVENT
							ElseIf  SF1->(ColumnPos("F1_PROVENT")) >0 .And.  !Empty(SF1->F1_PROVENT) .And. aConfProv[1] == SF1->F1_PROVENT .And. Empty(SD1->D1_PROVENT)
								cProvEnt := SF1->F1_PROVENT
							Endif
						//Por Pago
						ElseIf aConfProv[2] == "1" .And. aConfProv[3] == "2"
							SX5->(MsSeek(xFilial()+"74"))
							cSucur := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
							While !SX5->(EOF())  .And. SX5->X5_TABELA=="74"
								If SD1->D1_LOCAL  $ SX5->(X5DESCRI())
									cSucur := SUBS(SX5->X5_CHAVE,3,2)
									Exit
								Endif
								SX5->(DbSkip())
							EndDo

							cEmpAct := SM0->(M0_CODIGO)

							If SM0->(MsSeek(cEmpAct+cSucur))
									If SM0->(FOUND()) .And. aConfProv[1] == SM0->M0_ESTENT
									cProvEnt := SM0->M0_ESTENT
								EndIf
							ElseIf SM0->(MsSeek(cEmpAct+cFilAnt))
								cSucur := cFilAnt
								If SM0->(FOUND()) .And. aConfProv[1] == SM0->M0_ESTENT
									cProvEnt := SM0->M0_ESTENT
								EndIf							
							EndIf
						//Por Inscri็ขo
						ElseIf aConfProv[2] == "1" .And. aConfProv[3] == "3"
							If aConfProv[1] =="MI"
								If CCO->(MsSeek(xFilial("CCO") + aConfProv[1]))
									If CCO->CCO_TPRENI == "2" .And. aConfProv[4] == "N" .And. aConfProv[1] != SD1->D1_PROVENT
										SD1->(DbSkip())
										Loop
									Else
										cProvEnt := aConfProv[1]	
									EndIf
								EndIf
							Else
								cProvEnt := aConfProv[1]
							EndIf
						Endif

						//homologado pelo depto. de localizacoes...
						If cProvEnt $ cMVAgIIBB .And. !(cProvEnt$"CF|BA|SJ|TU|SF|SE|SA|JU|SL|MI|FO|ME|ER|SC|LR|CO|CB|CA|NE|LP|TF|CH|RN|CR")
							If aScan(aProvVerif,cProvEnt) == 0								
								If  lOPRotAut
									cTxtRotAut += OemToAnsi(STR0003+cProvEnt+STR0004) //"El proveedor " ### " no cuenta con la configuraci๓n necesaria para calcular la retenci๓n de SUSS a partir del documento origen. Indique concepto y/o tipo cแlculo correspondiente a valor informado."
									lMsErroAuto := .T.
								Else
									Aviso(OemToAnsi(STR0001),OemToAnsi(STR0003+cProvEnt+STR0004),{OemToAnsi(STR0002)}) //"Para la provincia o ciudad de "#" es necesario que el departamento de ubicaciones de Microsiga desarrolle la rutina de calculo. Por favor entre en contacto, con el administrador del sistema."
								Endif
								AAdd(aProvVerif,cProvEnt)
							EndIf

							SD1->(DbSkip())
							Loop
						EndIf
						If !(cProvEnt $ cMVAgIIBB)
							SD1->(DbSkip())
							Loop
						EndIf	
						
						nVlrTotal := (SD1->D1_TOTAL+SD1->D1_BAIVAGA+SD1->D1_BAIVAFR)
			            nProp:=(nVlrTotal/SF1->F1_Valmerc)
			            nVlrTotal:=nVlrTotal-(SF1->F1_DESCONT*nProp)
						
						//Verifica as caracteristicas do TES para verificar se houve
						//a incidencia de Percepcao de IIBB...
						If Len(aTesNf) > 0
							nPosTes := aScan(aTesNf,{|x| x[1] == SD1->D1_TES})
						EndIf
						If nPosTes == 0
							aImpInf := TesImpInf(SD1->D1_TES)
							aAdd(aTesNf, {SD1->D1_TES, aImpInf})
						Else
							aImpInf := aClone(aTesNf[nPosTes][2])
						EndIf

						lTESNoExen := aScan(aImpInf,{|x| "IV" $ AllTrim(x[1])}) <> 0
						If !lTESNoExen
							SD1->(DbSkip())
							Loop
						EndIf
						aArea:=GetArea()
						aReaSFF:=SFF->(GetArea())
						SFF->(dbSetOrder(10)) //10
						SFF->(MsSeek(xFilial("SFF")+"IBR" +SD1->D1_CF+cProvEnt+aConfProv[4]))
				  		lCalImpos:=.F.
				  		nTotBase:=0
						If  SFF->(Found())
						    lCalImpos:= .F.
							aAreaAtu := GetArea()
							If SFF->(ColumnPos("FF_INCIMP")) > 0
								For nI := 1 To Len(aImpInf)
									If(Trim(aImpInf[nI][01])$ SFF->FF_INCIMP)
										lCalImpos:=.T.
									 	nTotBase+=SD1->(FieldGet(ColumnPos(aImpInf[nI][02])))
									Endif
			      				Next
			        	 	EndIf
								//Se cambian validaciones para obtener el tipo de retenci๓n, independientemente de si SFF tiene un importe diferente de 0.
							If (CCO->(ColumnPos("CCO_IMMINR")) > 0 .and. CCO->(ColumnPos("CCO_TPMINR")) > 0)
								If SFF->FF_IMPORTE == 0 .Or. Empty(SFF->FF_IMPORTE)
									nAliq  := SFF->FF_ALIQ
									cZona  := SFF->FF_ZONFIS
									If  SFF->FF_PRALQIB <> 0
										nPrAliqIB := SFF->FF_PRALQIB
									EndIf
								EndIf
								CCO->(dbSetOrder(1))	//CCO_FILIAL+CCO_CODPRO
								If CCO->(MsSeek(xFilial("CCO") + cProvEnt))
									If SFF->FF_IMPORTE == 0 .Or. Empty(SFF->FF_IMPORTE)
										If CCO->CCO_IMMINR <> 0
											nObtMin := IIF(!Empty(CCO->CCO_TPMINR),Val(CCO->CCO_TPMINR),0)
											nLimMInRet := CCO->CCO_IMMINR
											cOriMin := "CCO"
										Endif
									Else
										nCOTipMin := IIF(!Empty(CCO->CCO_TPMINR),Val(CCO->CCO_TPMINR),0) 
									EndIf
								Endif
							Else 
								nObtMin = 0
							Endif
							
							CCO->(dbSetOrder(1))	//CCO_FILIAL+CCO_CODPRO
							If CCO->(MsSeek(xFilial("CCO") + cProvEnt)) .And. CCO->(ColumnPos("CCO_TPCALC")) > 0 .And. cPaisLoc == "ARG"
								cTipoCalc := Iif(CCO->CCO_TPCALC == "2", "2", "1")
								If cTipoCalc == "2"
									nRatValImp := 1
									lIIBBTotal := .T.
								EndIf
							Endif
							
							RestArea(aAreaAtu)
						EndIf

						RestArea(aArea)
						SFF->(RestArea(aReaSFF))

						If !lCalImpos
							For nI:=1 to Len(aImpInf)
								If "IB"$Trim(aImpInf[nI][01]) .And. Trim(aImpInf[nI][01])<>"IBR"
									If !Empty(SD1->(FieldGet(ColumnPos(aImpInf[nI][10]))))
										nPos := aScan(aPerIB,{|x| x[1]==cProvent .And.	x[2]==SD1->D1_CF .And. x[3]==aImpInf[nI][01]})
										If (nPos) == 0
											AAdd(aPerIB,{cProvEnt,SD1->D1_CF,aImpInf[nI][01],aImpInf[nI][09]})
										Else
											If aImpInf[nI][09] > aPerIB[nPos][04]
												aPerIB[nPos][04] := aImpInf[nI][09]
											EndIf
										EndIf
									EndIf
								EndIf

							Next nI
						EndIf
						
						nPosIb := Ascan(aZonaIb,{|X| X[1]==cProvEnt .And. X[2]=SD1->D1_CF})
						If CCO->(ColumnPos("CCO_TPRET")) > 0 .and. CCO->(ColumnPos("CCO_TPRENI")) > 0  
							If NoInsSFH(SA2->A2_COD,SA2->A2_LOJA,"IBR", aConfProv[1]) //Identifica tratamiento Retencion sujeto No inscripto
								aRes:= NoInsCCORet( aConfProv[1],SD1->D1_PROVENT)
								lCalNoIns := aRes[1][2]
								lNoIns := IIf(!Empty(aRes[1][1]),.T.,.F.)
								nPosIb := Iif(lNoIns == .T.,Ascan(aZonaIb,{|X| X[1]==SD1->D1_PROVENT .And. X[2]=SD1->D1_CF}),nPosIb)  
								If nPosIb == 0 .and. lNoIns == .T. 
									If (lCalNoIns == .T.) .or. (Len(aRes)>0 .and. aRes[1][1] == "2")  
										AAdd(aZonaIb,{cProvEnt,SD1->D1_CF,((nVlrTotal+nTotBase )* nRatValImp),aConfProv[4],,SD1->D1_PROVENT})
									Endif
								ElseIf nPosIb <> 0 .and. lNoIns == .T. 
									If lCalNoIns == .T. .or. (Len(aRes)>0 .and. aRes[1][1] == "2")
										aZonaIb[nPosIb][3] := aZonaIb[nPosIb][3]+((nVlrTotal+nTotBase )* nRatValImp)
									Endif 
								EndIf
							Else
								If nPosIb == 0
									AAdd(aZonaIb,{cProvEnt,SD1->D1_CF,((nVlrTotal+nTotBase )* nRatValImp),aConfProv[4],.f.,SD1->D1_PROVENT})
								Else
									aZonaIb[nPosIb][3] := aZonaIb[nPosIb][3]+((nVlrTotal+nTotBase )* nRatValImp)
								Endif
							EndIf 	
						EndIf
						nVlrTotal := 0
						SD1->(DbSkip())
					Enddo
				Else
					nPosIb := Ascan(aZonaIb,{|X| X[1]==cProvEnt .And. X[2]==SD1->D1_CF})
					AAdd(aZonaIb,{cProvEnt,SD1->D1_CF,nValMerc,aConfProv[4],,SD1->D1_PROVENT})
				Endif
			Else
				nPosIb := Ascan(aZonaIb,{|X| X[1]==cProvEnt .And. X[2]==SD1->D1_CF})
				AAdd(aZonaIb,{cProvEnt,SD1->D1_CF,nSaldo/1.21,aConfProv[4],,SD1->D1_PROVENT})
			Endif
		EndIf
		For nJ := 1 To Len(aZonaIb)
			lRet := .F.
			nBaseAtual	:= 0
			nAliqCGF	:= 0
			lYaAsCGF 	:= .F.
			cZonaCGF 	:= aZonaIb[nJ][1]
			If  cPaisLoc == "ARG" .And. lExisCGF == .T. .And. cZonaCGF == "BA" .And. CGF->(ColumnPos("CGF_ALIQ")) > 0 
				lRN4212 := .T.
			Endif
			//Converter a base para moeda 1
			aZonaIb[nJ][3] := Round(xMoeda(aZonaIb[nJ][3],nMoeda,1,,5,aTxMoedas[nMoeda][2]),MsDecimais(1))

			cZona := IIF(nObtMin == 0,"",cZona)
			SFF->(dbSetOrder(10))
			SFF->(MsSeek(xFilial()+"IBR"+aZonaIb[nJ][2]+aZonaIb[nJ][1]+aZonaIb[nJ][4]))
			
			//Si CCO_TPLIMR == 5, valida si FF_TPLIM es diferente de 0 para no considerar el calculo de limite mensual
			If SFF->(Found()) .And. cPaisLoc == "ARG" .And. SFF->(ColumnPos("FF_TPLIM")) > 0 .And. lCCOLimRet
				If !Empty(SFF->FF_TPLIM) .And. SFF->FF_TPLIM != "0" .and. aZonaIb[nJ][1]<> "ER"  
					lCCOLimRet := .F.
				EndIf
			EndIf
			
			If aZonaIb[nJ][4] == "V" .and. SFF->(Eof())  
				SFF->(MsSeek( xFilial() + "IBR" + aZonaIb[nJ][2] + aZonaIb[nJ][1] + "*" ) )
			Endif 
            
			//Verificar si tiene retencion adicional
			If  SFF->(Found()) .And. SFF->(ColumnPos("FF_CFORA")) > 0  
				nAliqRet  := SFF->FF_ALIQ
				lEsRetAdc :=ObtDesgl("IBR",SFF->FF_CFO_C,SFF->FF_ZONFIS,SFF->FF_TIPO,SFF->FF_CFORA,@nAliqAdc) //Obtener registro adicional                   
			Endif

			If aZonaIb[nJ][4] <> "M" .Or. (aZonaIb[nJ][4] == "M" .And. aZonaIb[nJ][1] <> "CF")
				If SFF->(Found())
					cZona := SFF->FF_ZONFIS //aZonaIb[nJ][1]
					If aZonaIb[nJ][1] == "TU" .and. aZonaIb[nJ][4] == "N" .and. aZonaIb[nJ][6] <> "TU"
						nAliq := SFF->FF_ALQNOINS
					Else
						nAliq := SFF->FF_ALIQ
					EndIf
					nLimMInRet:= IIF(nObtMin == 0,SFF->FF_IMPORTE,nLimMInRet)
					cOriMin := Iif(nObtMin == 0, "SFF", cOriMin)
					If lCCOLimRet
						nLimiteSFF := SFF->FF_LIMITE
					EndIf
					If SFF->FF_PRALQIB <> 0
						nPrAliqIB := SFF->FF_PRALQIB
					EndIf
				Else
					SFF->(dbSetOrder(11))
					If aZonaIb[nJ][1] == "CF" .And. aZonaIb[nJ][4] == "I"
						If SFF->(MsSeek(xFilial()+"IBR"+aZonaIb[nJ][1]+aZonaIb[nJ][4]+Replicate("*",TamSX3("FF_CFO_C")[1]) ))
							cZona := aZonaIb[nJ][1]
							nAliq := SFF->FF_ALIQ
							nLimMInRet:= IIF(nObtMin == 0,SFF->FF_IMPORTE,nLimMInRet)
							cOriMin := Iif(nObtMin == 0, "SFF", cOriMin)
							If lCCOLimRet
								nLimiteSFF := SFF->FF_LIMITE
							EndIf
							If SFF->FF_PRALQIB <> 0
								nPrAliqIB := SFF->FF_PRALQIB
							EndIf
						EndIf
					Else
						If SFF->(MsSeek(xFilial()+"IBR"+aZonaIb[nJ][1]+Replicate("*",TamSx3("FF_TIPO")[1])+Replicate("*",TamSX3("FF_CFO_C")[1]) ))
							cZona := aZonaIb[nJ][1]
							If aZonaIb[nJ][1] == "TU" .and. aZonaIb[nJ][4] == "N" .and. aZonaIb[nJ][6] <> "TU"
								nAliq := SFF->FF_ALQNOINS
							Else
								nAliq := SFF->FF_ALIQ
							EndIf
							nLimMInRet:= IIF(nObtMin == 0,SFF->FF_IMPORTE,nLimMInRet)
							cOriMin := Iif(nObtMin == 0, "SFF", cOriMin)
							If lCCOLimRet
								nLimiteSFF := SFF->FF_LIMITE
							EndIf
							If SFF->FF_PRALQIB <> 0
								nPrAliqIB := SFF->FF_PRALQIB
							EndIf
						EndIf
					EndIf
				EndIf
			Elseif aZonaIb[nJ][1] =="CF" .And. aZonaIb[nJ][4] == "M"

				If SFF->FF_TIPO == 'M'

					cItem := SFF->FF_ITEM
					cZona := SFF->FF_ZONFIS
					nAliq := SFF->FF_ALIQ
					nLimMInRet:=  IIF(nObtMin == 0,SFF->FF_IMPORTE,nLimMInRet)
					cOriMin := Iif(nObtMin == 0, "SFF", cOriMin)
					If lCCOLimRet
						nLimiteSFF := SFF->FF_LIMITE
					EndIf
					If SFF->FF_PRALQIB <> 0
						nPrAliqIB := SFF->FF_PRALQIB
					EndIf

					nMinimo  	:= Iif(SFF->(ColumnPos("FF_LIMITE"))>0,SFF->FF_LIMITE,0)
					nMinUnit 	:= Iif(SFF->(ColumnPos("FF_MINUNIT"))>0,SFF->FF_MINUNIT,0)

					aAreaSFF := SFF->(GetArea())

					SFF->(dbSetOrder(11))
					SFF->(MsSeek(xFilial()+"IBR"+aZonaIb[nJ][1]))

					//Array contendo todos os CFOs com a mesma classifica็ขo
					While SFF->(!Eof()) .And. SFF->FF_IMPOSTO == "IBR"
						If SFF->FF_TIPO == 'M' .And. SFF->FF_ITEM == cItem .And. SFF->FF_ZONFIS == cZona
							If aScan(aCf,{|x| x[1] == SFF->FF_CFO_C}) == 0
								aAdd(aCf,{SFF->FF_CFO_C,SFF->FF_CFO_V})
							Endif
						Endif
						SFF->(dbSkip())
					Enddo

			 		SFF->(RestArea(aAreaSFF))
					SFH->(DbSetOrder(1))
					SFH->(MsSeek(xFilial()+SA2->A2_COD+SA2->A2_LOJA+"IBR"+cZona))
					If SFH->(FOUND()) .And. (SFH->FH_ISENTO == "N" .And. A085aVigSFH())
				 		lCalcMon:= .T.
					Else
						//Verifica se deve calcular IB
						lCalcMon := F850CheckLim(cItem,aCf,SF1->F1_FORNECE,nMinimo,SF1->F1_DOC,PadR(SF1->F1_SERIE,nTamSer),nMinUnit,"IB",,1,Iif(lMsFil,SF1->F1_MSFIL,""))
					EndIf

				Endif
  			Endif
  			If aZonaIb[nJ][1] $ "CR|ME|"
				nTotRetSFE:=0
				nTotBasSFE:=0
				ltpLimVa := ( ( SFF->(ColumnPos("FF_TPLIM")) > 0 .and. SFF->FF_ZONFIS $ "ME") .and. ;
							   (EMPTY(SFF->FF_TPLIM) .OR. SFF->FF_TPLIM == " " .or. SFF->FF_TPLIM == "0") )

  				If aZonaIb[nJ][1] == "CR" .Or. ( SFF->(ColumnPos("FF_TPLIM")) > 0 .and. SFF->FF_TPLIM == "5" .and. SFF->FF_ZONFIS $ "ME" )
  					lSmRMCR := .T.
  					nLmRMCR := IIF(SFF->(ColumnPos("FF_LIMITE")) > 0,SFF->FF_LIMITE,0)
					
					AcumRetIBB(SF1->F1_FORNECE, SF1->F1_LOJA, aConfProv[1], @nTotRetSFE, @nTotBasSFE) //Acumulado de retenci๓n de IIBB
				Endif 

				If aZonaIb[nJ][1] == "CR"				
					nBaseAtual:= (nTotBasSFE + (aZonaIb[nJ][3]*nPropImp)*nSigno)
				ElseIf aZonaIb[nJ][1] == "ME" .and. lExisCGF == .T.
					aAreaAnt := GetArea()										
					dbSelectArea("CGF")
					dbSetOrder(2) // CGF_FILIAL+CGF_COD+CGF_LOJA+CGF_ZONFIS+CGF_IMPOST+CGF_CFO+CGF_CODACT
					If CGF->(MsSeek(XFILIAL("CGF") + SA2->A2_COD + SA2->A2_LOJA + aZonaIb[nJ][1]+"IBR"+aZonaIb[nJ][2]))
						If (EMPTY(CGF->CGF_FIMVIGE) .or. CGF->CGF_FIMVIGE > SE2->E2_EMISSAO)
							aZonaIb[nJ][5] := .T. // Parametro para indicar que este excenta retencion 
						Endif
					Endif
					Restarea(aAreaAnt)						
				Endif 
			EndIf
			
			If lCCOLimRet
				AcumRetIBB(SF1->F1_FORNECE, SF1->F1_LOJA, aConfProv[1], @nTotRetSFE, @nTotBasSFE) //Acumulado de retenci๓n de IIBB
			EndIf

			If aZonaIb[nJ][1] == "ME"
				nBaseAtual:= (nTotBasSFE + (aZonaIb[nJ][3]*nPropImp))*nSigno
			Endif 

			nDeduc := 0
			nCofRet := 0
				
			If  lRN4212
				DbSelectArea("CCP")
				CCP->(DbSetOrder(1))//CCP_FILIAL+CCP_COD+CCP_VORIGE
				CCP->(DbGoTop())
				If  CCP->(MsSeek(xFilial("CCP")+"RN42"+aZonaIb[nJ][2]))//Tabla RN42- CFO
					// SE obtienen los registros de la CGF para el proveedor
					cTabCGF := GetNextAlias()
					cQuery := "SELECT * "
					cQuery += "FROM " + RetSqlName("CGF")+ " CGF "
					cQuery += "WHERE CGF_FORNEC='" + SA2->A2_COD + "' AND "
					cQuery += "CGF_LOJA		='" + SA2->A2_LOJA + "'   AND "
					cquery += "CGF_ZONFIS 	='" + cZonaCGF +"' 		  AND "
					cQuery += "CGF_FILIAL	='" +XFILIAL("CGF") + "'  AND "
					cQuery += "CGF_IMPOST 	='IBR' 	AND "
					cQuery += "CGF_ALIQ 	<> 0 	AND "
					
					cquery += "((CGF_FIMVIG>='"+Dtos(dDataBase)+"' AND "									      
					cquery += "CGF_INIVIG<='"+Dtos(dDataBase)+"')  OR "                                            
					
					cquery += "(CGF_FIMVIG=' ' AND "									      
					cquery += "CGF_INIVIG=' ') OR "
					
					cquery += "(CGF_FIMVIG=' ' AND "									      
					cquery += "CGF_INIVIG<='"+Dtos(dDataBase)+"') OR "      
					
					cquery += "(CGF_FIMVIG>='"+Dtos(dDataBase)+"' AND "									      
					cquery += "CGF_INIVIG=' '))"      
					
					cQuery += " AND "
					cQuery += "D_E_L_E_T_<>'*'"
					cQuery += "ORDER BY CGF_INIVIG,CGF_FIMVIG"
	
					cQuery := ChangeQuery(cQuery)
	
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTabCGF,.T.,.T.)
					TCSetField(cTabCGF,"CGF_INIVIG","D")
	 				TCSetField(cTabCGF,"CGF_FIMVIG","D")
	
					Count to nNumRegs

					If nNumRegs > 0 // Se verifica que existan registros para el proveedor en CGF
						(cTabCGF)->(dbGoTop())
						WHILE (cTabCGF)->(!eof()) .And. !lRet
	
							If !((dDatabase >=(cTabCGF)->CGF_INIVIG .Or. Empty((cTabCGF)->CGF_INIVIG) ) .And. ;
								(dDatabase <= (cTabCGF)->CGF_FIMVIG .Or. Empty((cTabCGF)->CGF_FIMVIG))) 
								(cTabCGF)->(dbskip())
								Loop
							EndIf
	
							If !Empty((cTabCGF)->CGF_INIVIG) .And. !Empty((cTabCGF)->CGF_FIMVIG)
								IF (dDatabase >=(cTabCGF)->CGF_INIVIG ) .AND. dDatabase <= (cTabCGF)->CGF_FIMVIG
									nAliqCGF := (cTabCGF)->CGF_ALIQ
									lRet := .T.
								EndIF
							Else
								If Empty((cTabCGF)->CGF_INIVIG) .and. Empty((cTabCGF)->CGF_FIMVIG)
									nAliqCGF := (cTabCGF)->CGF_ALIQ								
								Else
									If (dDatabase >= (cTabCGF)->CGF_INIVIG .and. !Empty((cTabCGF)->CGF_INIVIG)) .or. (dDatabase <= (cTabCGF)->CGF_FIMVIG .and.  !Empty((cTabCGF)->CGF_FIMVIG))
										nAliqCGF := (cTabCGF)->CGF_ALIQ
										lRet := .T.
									EndIf
								EndIf
							Endif						
							(cTabCGF)->(dbskip())
						EndDo
					Endif
					(cTabCGF)->(dbCloseArea())
				Endif
			Endif
			lRet := .F.
			
			If IIF(nObtMin = 0,IIf(lRN4212,.T.,!Empty(cZona)),.T.) .And. (aZonaIb[nJ][4] <> "M" .Or. (aZonaIb[nJ][4] == "M" .And. lCalcMon) .Or. (aZonaIb[nJ][4] == "M" .And. aZonaIb[nJ][1] <> "CF") .or. (lCalNoIns))

				//****************************************************
				// SE obtienen los registros de la SFH para el proveedor
				cTabTemp := criatrab(nil,.F.)
				cQuery := "SELECT * "
				cQuery += "FROM " + RetSqlName("SFH")+ " SFH "
				cQuery += "WHERE FH_FORNECE='" + SA2->A2_COD + "' AND "
				cQuery += "FH_LOJA='"  + SA2->A2_LOJA + "' AND "
				cQuery += "FH_IMPOSTO='IBR' AND "
				cquery += "FH_ZONFIS='" + cZona +"' AND "
				If cPaisLoc == "ARG"
					cQuery += "FH_FILIAL='" +XFILIAL("SFH") + "' AND "
				Else
					If !Empty(xFilial("SFH"))  .and. !Empty(xFilial("SA2"))
						cQuery += "FH_FILIAL='" +XFILIAL("SA2") + "' AND "
					ElseIf !Empty(xFilial("SFH")) .and. !Empty(xFilial("SE2"))
						cQuery += "FH_FILIAL='" +XFILIAL("SE2") + "' AND "
					Endif
				EndIf                                                            
				
				cquery += "((FH_FIMVIGE>='"+Dtos(dDataBase)+"' AND "									      
				cquery += "FH_INIVIGE<='"+Dtos(dDataBase)+"') OR "                                            
				
				cquery += "(FH_FIMVIGE=' ' AND "									      
				cquery += "FH_INIVIGE=' ') OR "
				
				cquery += "(FH_FIMVIGE=' ' AND "									      
				cquery += "FH_INIVIGE<='"+Dtos(dDataBase)+"') OR "      
				
				cquery += "(FH_FIMVIGE>='"+Dtos(dDataBase)+"' AND "									      
				cquery += "FH_INIVIGE=' '))"      
				
				cQuery += " AND "
				cQuery += "D_E_L_E_T_<>'*'"
				cQuery += "ORDER BY FH_INIVIGE,FH_FIMVIGE"

				cQuery := ChangeQuery(cQuery)

				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTabTemp,.T.,.T.)
				TCSetField(cTabTemp,"FH_INIVIGE","D")
 				TCSetField(cTabTemp,"FH_FIMVIGE","D")

				Count to nNumRegs

				If nNumRegs > 0 // Se verifica que existan registros para el proveedor en SFH
					(cTabTemp)->(dbGoTop())
					WHILE (cTabTemp)->(!eof())   .And. ;
						(cTabTemp)->FH_FORNECE==SA2->A2_COD .AND. (cTabTemp)->FH_LOJA == SA2->A2_LOJA .And. (cTabTemp)->FH_ZONFIS == cZona .And. !lRet

						If lNoIns .Or. !((dDatabase >=(cTabTemp)->FH_INIVIGE .Or. Empty((cTabTemp)->FH_INIVIGE) ) .And. ;
							(dDatabase <= (cTabTemp)->FH_FIMVIGE .Or. Empty((cTabTemp)->FH_FIMVIGE))) 
							(cTabTemp)->(dbskip())
							Loop
						Else
							nAliqAux := nAliq 
						EndIf

						If (cTabTemp)->FH_ZONFIS=="ME"
							lThdezb:=.f.
							nBaseAtual := 0
							If aZonaIb[nJ][5] == .T. // Verificamos si es excento
								nCoefmul := (cTabTemp)->FH_COEFMUL
								nAliqAux := 0
								nPercTot :=(100 - (cTabTemp)->FH_PERCENT) /100	 // % de Exencion del Impuesto	
								lIsento  := .t.
								lThdezb := .t.
								cSituaca := (cTabTemp)->FH_SITUACA
							ElseIf (cTabTemp)-> FH_SITUACA="2" .and. (EMPTY((cTabTemp)->FH_FIMVIGE) .or. SE2->E2_EMISSAO <= (cTabTemp)->FH_FIMVIGE)	
								nAliqAux  := ((cTabTemp)->FH_ALIQ ) // (SFF->FF_ALIQ * 2)
								nBaseAtual:= (nTotBasSFE + (aZonaIb[nJ][3]*nPropImp))*nSigno
								nCoefmul := (cTabTemp)->FH_COEFMUL
								nPercTot :=(100 - (cTabTemp)->FH_PERCENT) /100	 // % de Exencion del Impuesto	
								lIsento  := IIF((cTabTemp)->FH_ISENTO=="S" .OR. (cTabTemp)->FH_PERCENT == 100 ,.T.,.F.)
								lThdezb := .t.
								cSituaca := (cTabTemp)->FH_SITUACA
							Else
								nBaseAtual:= (nTotBasSFE + (aZonaIb[nJ][3]*nPropImp))*nSigno
							Endif
						Endif 
						
						If lThdezb == .f.
						If !Empty((cTabTemp)->FH_INIVIGE) .And. !Empty((cTabTemp)->FH_FIMVIGE)
							IF(dDatabase >=(cTabTemp)->FH_INIVIGE ) .AND. dDatabase <= (cTabTemp)->FH_FIMVIGE
								nCoefmul := (cTabTemp)->FH_COEFMUL
								nAliqaux := (cTabTemp)->FH_ALIQ
								lIsento  := IIF((cTabTemp)->FH_ISENTO=="S" .OR. (cTabTemp)->FH_PERCENT == 100,.T.,.F.)
								nPercTot :=(100 - (cTabTemp)->FH_PERCENT) /100	 // % de Exencion del Impuesto								
								lRet := .T.
								cSituaca := (cTabTemp)->FH_SITUACA
								cZonaSFH := (cTabTemp)->FH_ZONFIS
								cTipoSFH := (cTabTemp)->FH_TIPO
							EndIF
						Else
							If Empty((cTabTemp)->FH_INIVIGE) .and. Empty((cTabTemp)->FH_FIMVIGE)
								nCoefmul := (cTabTemp)->FH_COEFMUL 
								nAliqaux := (cTabTemp)->FH_ALIQ
								lIsento  := IIF((cTabTemp)->FH_ISENTO=="S" .OR. (cTabTemp)->FH_PERCENT == 100,.T.,.F.)
								nPercTot :=(100 - (cTabTemp)->FH_PERCENT) /100	 // % de Exencion del Impuesto
								cSituaca := (cTabTemp)->FH_SITUACA
								cZonaSFH := (cTabTemp)->FH_ZONFIS
								cTipoSFH := (cTabTemp)->FH_TIPO								
							Else
								If (dDatabase >= (cTabTemp)->FH_INIVIGE .and. !Empty((cTabTemp)->FH_INIVIGE)) .or. (dDatabase <= (cTabTemp)->FH_FIMVIGE .and.  !Empty((cTabTemp)->FH_FIMVIGE))
									nAliqaux := (cTabTemp)->FH_ALIQ
									lIsento  := IIF((cTabTemp)->FH_ISENTO=="S"  .OR. (cTabTemp)->FH_PERCENT == 100,.T.,.F.)
									nPercTot :=(100 - (cTabTemp)->FH_PERCENT) /100	 // % de Exencion del Impuesto										
									nCoefmul := (cTabTemp)->FH_COEFMUL
									lRet := .T.
									cSituaca := (cTabTemp)->FH_SITUACA
									cZonaSFH := (cTabTemp)->FH_ZONFIS
									cTipoSFH := (cTabTemp)->FH_TIPO
								EndIf
							EndIf
						Endif
						Endif	
						
						If CCO->(ColumnPos("CCO_RPROAG")) > 0 .And. (cTabTemp)->FH_IMPOSTO ==  "IBR" .And. cPaisLoc == "ARG"
							If CCO->(MsSeek(xFilial("CCO")+(cTabTemp)->FH_ZONFIS))
 								If CCO->CCO_CODPRO == (cTabTemp)->FH_ZONFIS .And. CCO->CCO_AGRET == "1" .And. CCO->CCO_RPROAG == "N" .And. (cTabTemp)->FH_AGENTE == "S"
									lAgRetCCO := .F.
								EndIf
							EndIf
						EndIf
						
						(cTabTemp)->(dbskip())
					EndDo

					If  lRN4212 .And. nAliqCGF <> 0
						nAliqAux := nAliqCGF
						lYaAsCGF := .T.
					Endif
					
					IF nAliqAux <> 0
						lRet := .T.
					EndIF

					If lRet .and. !lIsento .AND. nAliqAux <> 0	// Si se encontr?un registro y no es excento, se toma el valor de al้–uota.
						If cSituaca == "2" .and. CCO->(ColumnPos("CCO_CRFRET")) > 0
							nAliq := nAliqAux * (1+(POSICIONE("CCO",1,xFilial("CCO")+cZOna,"CCO_CRFRET"))/100)
						ElseIf  cZonaSFH == "TU" .and. cTipoSFH == "V" .and. nAliqAux <> 0 
							If  SA2->A2_EST <> "TU" .and. nCoefMul <> 0
								aZonaIb[nJ][3] := aZonaIb[nJ][3] * (nCoefmul) 
								nAliq := (nAliqAux * Iif (nPrAliqIB<>1,1-(nPrAliqIB/100),nPrAliqIB))
							ElseIf SA2->A2_EST == "TU" .and. nPrAliqIB <> 0
								nAliq := (nAliqAux * Iif (nPrAliqIB<>1,1-(nPrAliqIB/100),nPrAliqIB))
							Else
								nAliq := nAliqAux
							EndIf
						ElseIf cZonaSFH == "TU" .and. cTipoSFH == "N"
							nAliq := 0
						Else
							nAliq := nAliqAux * Iif (nPrAliqIB<>1,1-(nPrAliqIB/100),nPrAliqIB)
						Endif 
					ElseIf lRet .and. !lIsento .AND. nAliqAux == 0
						If cZonaSFH == "TU" .and. aZonaIb[nJ][6] <> "TU" .and. cTipoSFH == "V" .and. SA2->A2_EST <> "TU"
							If CCO->(ColumnPos("CCO_CRFRET")) > 0
								nCRFRET := POSICIONE("CCO",1,xFilial("CCO")+cZOna,"CCO_CRFRET")
							EndIf
							If nCRFRET <> 0
								nAliq :=  (nAliq * nCRFRET) 
							EndIf
						ElseIf nPrAliqIB<>1
							nAliq := nAliq * (1-(nPrAliqIB/100))
						EndIf
					EndIf
					//Aplica % de Reducao para Convenio Multilateral...     
	  				If  cZonaSFH <> "TU"
						nDeduc := aZonaIb[nJ][3]
						nCofRet := nCoefMul	
						aZonaIb[nJ][3] := aZonaIb[nJ][3] * nPercTot
						If  nCoefmul <> 0
							aZonaIb[nJ][3] := aZonaIb[nJ][3] * (nCoefmul/100) 
						EndIf                                                           
	  					nDeduc -= aZonaIb[nJ][3]
	  				Else
	  					aZonaIb[nJ][3] := aZonaIb[nJ][3] * nPercTot
					EndIf


				EndIf
				(cTabTemp)->(dbCloseArea())
                
				//Verificar si es necesario desglosar la aliquiota
                If  lEsRetAdc
                	nAliq := nAliqAdc + nAliqRet
                Endif

				If !Empty(lPA) .and. lPA
					lGravoPa:= Iif(lCalcPa .or. (lCalPaIns .and. (nNumRegs > 0 .or. lCalNoIns)),.T.,.F.)
				EndIf
				
				//****************************************************
				If !lIsento .and. lGravoPa
					//No existe registro en SFH, verificar para asignar CGF.
					If !lYaAsCGF .And. lRN4212 .And. nAliqCGF <> 0
						nAliq := nAliqCGF
					Endif
					IF TYPE ("aProvLim") == "A"
						nPsLmPv := Ascan(aProvLim, {|xT| xT[1] == aZonaIb[nJ][1]})
					Else
						nPsLmPv:=0
					EndIf
					If nPsLmPv > 0
						lLimPrim := aProvLim[nPsLmPv][2]
					EndIf

					If  SFF->FF_REDBASE <> 0 .and. aZonaIb[nJ][3] <> 0
						aZonaIb[nJ][3] := (aZonaIb[nJ][3] * (( 100 - SFF->FF_REDBASE ) / 100 ) )
					Endif
					
					//Si el IIBB se controla por tipo 2 (total) 
					If cTipoCalc == "2" .And. cPaisLoc == "ARG"
						SFE->(dbSetOrder(4))
						nRetSFE:=0
						If lShowPOrd .and. TableInDic("FVC") .and. Funname() == "FINA855"
							DBSELECTAREA("FVC")
							FVC->(DBSETORDER(3)) //FVC_FILIAL+FVC_FORNEC+FVC_LOJA+FVC_NFISC+FVC_SERIE+FVC_TIPO+FVC_CONCEP
							If FVC->(MsSeek(xFilial("FVC")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC))
								While FVC->(!Eof()) .and. FVC->(FVC_FORNEC+FVC_LOJA+FVC_NFISC) == SF1->(F1_FORNECE+F1_LOJA+F1_DOC)
									If AllTrim(FVC->FVC_TIPO) $ "B" .and. FVC->FVC_RETENC > 0 .and. FVC->FVC_SERIE == SF1->F1_SERIE .and. cZona == FVC->FVC_EST
										AADD(aRetPreO,FVC->(FVC_FORNEC+FVC_LOJA+FVC_NFISC+FVC->FVC_SERIE+FVC_PARCEL))
										nRetSFE +=  FVC->FVC_RETENC
									EndIf
									FVC->(dbSkip())
								Enddo
							EndIf	
						EndIf
						//Cuenta el total de registros en SFE, correspondiente a ๓rdenes de pago anteriores.
						If SFE->(MsSeek(xFilial("SFE")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE+"B")) 
							cChaveSFE := SFE->FE_FILIAL+SFE->FE_FORNECE+SFE->FE_LOJA+SF1->F1_DOC+SF1->F1_SERIE+"B"
							While !SFE->(Eof()) .And. cChaveSFE == xFilial("SFE")+SFE->FE_FORNECE+SFE->FE_LOJA+SFE->FE_NFISCAL+SFE->FE_SERIE+SFE->FE_TIPO
								If Month(SFE->FE_EMISSAO) != Month(dDataBase) .Or.YEAR(SFE->FE_EMISSAO)!=Year(dDataBase) .Or.;
									!(SFE->FE_TIPO $ "B") .Or. cZona != SFE->FE_EST .Or. Iif(!Empty(SFE->FE_DTRETOR), Month(SFE->FE_DTRETOR) != Month(dDataBase),.F.)
									SFE->(dbSkip())
									Loop
								EndIf
								If lShowPOrd .and. TableInDic("FVC") .and. Funname() == "FINA855"
									If Ascan(aRetPreO,{|x| x == SFE->(SFE->FE_FORNECE+SFE->FE_LOJA+SFE->FE_NFISCAL+SFE->FE_SERIE+SFE->FE_PARCELA) }) == 0
										nRetSFE += SFE->FE_RETENC
									EndIf
								Else
									nRetSFE += SFE->FE_RETENC
								EndIf
								SFE->(dbSkip())
							End
						EndIf
						
						//Impostos recalculados na tela - Modificar OP
						//Impostos calculados - IVA, IB...
						nImpCalc := 0
						If Len(aImpCalc) > 0
							For aX := 1 to Len(aImpCalc[nLinha])
								If ValType(aImpCalc[nLinha][aX]) == "A"
									nImpCalc += aImpCalc[nLinha][aX][2]
								EndIf
							Next
							
							For aX := 1 to Len(aSFEIb)
								If ValType(aSFEIb[aX]) == "A"
									nImpCalc += aSFEIb[aX][6]
								EndIf
							Next
							
							//Ganancia
							If Len(aImpCalc[Len(aImpCalc)]) > 0 .And. valtype(aImpCalc[Len(aImpCalc)][1]) <> "A"  .And. aImpCalc[Len(aImpCalc)][1] == "GAN"
								nImpCalc += aImpCalc[Len(aImpCalc)][2]
							Endif
						End
						
						//Se calcula si la diferencia entre los pagos y el total a pagar. Se considera limites con calculo en CCO
						If lCCOLimRet .And. nLimiteSFF > 0 .And. lLimPrim
							//FE_VALIMP
							nValorRet := Round(((nTotBasSFE + aZonaIb[nJ][3]) * (nAliq / 100)) - nTotRetSFE,TamSX3("FE_VALIMP")[2])
							aProvLim[nPsLmPv][2] := .F.
						Else
							nValorRet := Round((((aZonaIb[nJ][3] * nPropImp ) * nSigno) * (nAliq / 100)) - nRetSFE, TamSX3("FE_VALIMP")[2])
						EndIf

						If aZonaIb[nJ][1] $ "CR|ME|"
							nValorRet := Round((nBaseAtual  * (nAliq/100)) - nRetSFE,TamSX3("FE_VALIMP")[2])  //FE_VALIMP
						EndIf 
						
						//Si a๚n existe un monto a pagar, se valida que el saldo sea suficiente para cubrir el monto, de lo contario se calcula solo lo que es posible cubrir o no se cubre en lo absoluto.
						If nValorRet != 0
							If (nSaldo-nImpCalc) < Round(xMoeda(nValorRet,1,nMoeda,,5,aTxMoedas[nMoeda][2]),MsDecimais(1)) 
								nValorRet := (nSaldo-nImpCalc)
								lAjusta := .T. 
							EndIf 
						EndIf 
						
						//Se valida que no se envi้ un monto menos que cero.
						If nValorRet < 0
							nValorRet	:= 0
						Endif
					EndIf
					
					If cTipoCalc == "2" .And. nValorRet != 0 .And. cPaisLoc == "ARG"
						nRetencao := nValorRet //FE_VALIMP
					ElseIf cTipoCalc == "2" .And. nValorRet == 0 .And. cPaisLoc == "ARG"
						lAgRetCCO := .F.
						nRetencao := 0
					Else
						nRetencao := Round((((aZonaIb[nJ][3]*nPropImp)*nSigno)*(nAliq/100)),TamSX3("FE_VALIMP")[2])  //FE_VALIMP
						If aZonaIb[nJ][1] $ "CR|ME|"
							nRetencao := Round((nBaseAtual * (nAliq/100)) - nTotRetSFE,TamSX3("FE_VALIMP")[2])  //FE_VALIMP
						EndIf
						If lCCOLimRet .And. nLimiteSFF > 0 .And. lLimPrim
							//FE_VALIMP
							nRetencao := Round((((nTotBasSFE) + aZonaIb[nJ][3]) * (nAliq / 100)) - nTotRetSFE,TamSX3("FE_VALIMP")[2])
							aProvLim[nPsLmPv][2] := .F.  
						EndIf
					EndIf
					
					If aZonaIb[nJ][1] $ "ER"
						nRetencao := Round((((nTotBasSFE) + aZonaIb[nJ][3]) * (nAliq / 100)) - nTotRetSFE,TamSX3("FE_VALIMP")[2])
					EndIf 

					If (SFF->FF_PRALQIB <> 0) .And. (Len(aPerIB) > 0) .and. !(aZonaIb[nJ][1] == "TU" .and. aZonaIb[nJ][4] == "V")

						If aScan(aPerIB,{|x| X[1]==aZonaIb[nJ][1] .And. X[2]==aZonaIb[nJ][2] .And. x[4]<nAliq}) > 0
							nAliq := nAliq * (SFF->FF_PRALQIB/100)
						EndIf
					EndIf
					If !lAjusta
						nRetencao := Round((((aZonaIb[nJ][3]*nPropImp)*nSigno)*(nAliq/100)),TamSX3("FE_VALIMP")[2])//FE_VALIMP  
					Endif
					
					If nSaldo == 0
						lAgRetCCO := .F.
					EndIf
					
					Aadd(aSFEIb,Array(33))
					aSFEIb[Len(aSFEIb)][1] := SE2->E2_NUM                   //FE_NFISCAL
					aSFEIb[Len(aSFEIb)][2] := SE2->E2_PREFIXO               //FE_SERIE
					aSFEIb[Len(aSFEIb)][3] := (aZonaIb[nJ][3]*nPropImp)*nSigno        //FE_VALBASE
					aSFEIb[Len(aSFEIb)][4] := nAliq
					
					
					If aZonaIb[nJ][1] $ "CR|ME|"
						If aZonaIb[nJ][1] == "ME" .and. ltpLimVa
							aSFEIb[Len(aSFEIb)][5] := nRetencao
						ElseIf aZonaIb[nJ][1] == "CR" .or. lSmRMCR = .F.
							aSFEIb[Len(aSFEIb)][5] := nRetencao
						Else 
							aSFEIb[Len(aSFEIb)][5] := IIf((nLmRMCR > nTotBasSFE) .and. lSmRMCR,0,nRetencao)
						Endif
					ElseIf lLimNRet
						nRetencao := 0
						aSFEIb[Len(aSFEIb)][5] := nRetencao 
					Else
						aSFEIb[Len(aSFEIb)][5] := nRetencao
					Endif
					
					aSFEIb[Len(aSFEIb)][6] := aSFEIb[Len(aSFEIb)][5]        //FE_RETENC
					aSFEIb[Len(aSFEIb)][7] := nSaldo //SE2->E2_VALOR
					aSFEIb[Len(aSFEIb)][8] := SE2->E2_EMISSAO
					aSFEIb[Len(aSFEIb)][9] := cZona
					aSFEIb[Len(aSFEIb)][10]:= SE2->E2_MOEDA
					aSFEIb[Len(aSFEIb)][11]:= SFF->FF_CFO_C   //CFO - Compra
					aSFEIb[Len(aSFEIb)][12]:= SFF->FF_CFO_V   //CFO - Venda
					aSFEIb[Len(aSFEIb)][13]:= SE2->E2_TIPO
					aSFEIb[Len(aSFEIb)][14]:= SFF->FF_CONCEPT
					aSFEIb[Len(aSFEIb)][15]:= nDeduc
					aSFEIb[Len(aSFEIb)][16]:= nCofRet  
					aSFEIb[Len(aSFEIb)][17]:= lEsRetAdc
					aSFEIb[Len(aSFEIb)][18]:= Iif(lEsRetAdc,SFF->FF_CFORA,"")   
					aSFEIb[Len(aSFEIb)][19]:= nAliqRet    
					aSFEIb[Len(aSFEIb)][20]:= nAliqAdc
					aSFEIb[Len(aSFEIb)][21]:= nLimMInRet
					aSFEIb[Len(aSFEIb)][22]:= nObtMin // De donde se obtuvo el minimo (CCO->CCO_TPMINR)
					aSFEIb[Len(aSFEIb)][23]:= Iif(aZonaIb[nJ][1] $ "CR|ME|",nBaseAtual,0) // Caso Mendoza
					aSFEIb[Len(aSFEIb)][24]:= 0
					aSFEIb[Len(aSFEIb)][25]:= cOriMin
					aSFEIb[Len(aSFEIb)][26]:= nLimMInRet // Monto del mํnimo, para calculo de mํnimos por OP
					aSFEIb[Len(aSFEIb)][27]:= Iif(cOriMin == "SFF", nCOTipMin, nObtMin) // De donde se obtuvo el mํnimo, para calculo de mํnimos por OP.
					aSFEIb[Len(aSFEIb)][28]:= Iif(!(aConfProv[1] $ ("SF|BA|CO")), 0, nTotCCO3) //Base imponible + impuestos solamente cuando es para SF.
					aSFEIb[Len(aSFEIb)][29]:= aConfProv[6]
					aSFEIb[Len(aSFEIb)][30]:= lCCOLimRet .And. nLimiteSFF > 0 //Si se considerara el limite por CCO.
					aSFEIb[Len(aSFEIb)][31]:= nLimiteSFF //Monto del limite a considerarse
					aSFEIb[Len(aSFEIb)][32]:= nTotRetSFE //Monto retencion limite
					aSFEIb[Len(aSFEIb)][33]:= nTotBasSFE //Monto base imponible limite.
				Endif
			Endif	
		Next nJ
	EndIf
EndIf
RestArea(aArea)

If !lAgRetCCO .And. cPaisLoc == "ARG" .Or. (cTipoCalc == "2" .And. !lSUSSPrim .And. cPaisLoc == "ARG") 
	aSFEIB := {}
	If TYPE ("aProvLim") == "A" .And.  Len(aProvLim) > 0 .And. nPsLmPv > 0
		aProvLim[nPsLmPv][2] := lLimPrim
	EndIf
EndIf

Return aSFEIB



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRetIBBCre บAutor  ณ                    บ Data ณ  31/07/2020 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ RetIBBCre  - Calculo de Ret de IIBB para NC                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ARGRetIB2 (FINRETARG)                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ 1. cAgente: Agente de retenci๓n (N = No/ S = Si).          บฑฑ
ฑฑ           ณ 2. nSigno: 1 / (-1)Si SE2->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG บฑฑ
ฑฑ           ณ 3. nSaldo: Saldo (valor baser o valor a bajar).            บฑฑ
ฑฑ           ณ 4. nPropImp                                                บฑฑ
ฑฑ           ณ 5. aConfProv                                               บฑฑ
ฑฑ           ณ 6. lSUSSPrim                                               บฑฑ
ฑฑ           ณ 7. lIIBBTotal                                              บฑฑ
ฑฑ           ณ 8. aImpCalc: Array con impuesto calculado IB...            บฑฑ
ฑฑ           ณ 9. aSUSS                                                   บฑฑ
ฑฑ           ณ 10.nLinha                                                  บฑฑ
ฑฑ           ณ 11.lLimNRet                                                บฑฑ
ฑฑ           ณ 12.cChavePOP: FJK_PREOP+Proveedor+Loja, usada en ObtReten()บฑฑ
ฑฑ           ณ 13.cNFPOP:Num de documento(E2_NUM), usado en ObtReten().   บฑฑ
ฑฑ           ณ 14.cSeriePOP: Serie(E2_PREFIXO), usada en ObtReten().      บฑฑ
ฑฑ           ณ 15.dEmissao: Fch emisi๓n CXP(E2_EMISSAO), usada ObtReten().บฑฑ
ฑฑ           ณ 16.lOPRotAut: .T. Si es generaci๓n automแtica.             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function RetIBBCre(cAgente,nSigno,nSaldo,nPropImp,aConfProv,lSUSSPrim,lIIBBTotal,aImpCalc,aSUSS,nLinha,lLimNRet,cChavePOP,cNFPOP,cSeriePOP,dEmissao,lOPRotAut)

Local nRatValImp,nRateio,nValMerc,cZona,nJ,nPosIb,cEmpAct
Local nPosRet,nRecSM0
Local aZonaIb  	:= {}
Local aSFEIB    := {}
Local aPerIB    := {}
Local aProvVerif:= {}
Local aImpInf 	:= {}
Local aCF 		:= {}
Local aAreaSFF 	:= {}
Local aFil		:= {}
Local aRes      := {}
Local lRet 		:= .F.
Local lIsento 	:= .F.
Local lFoundFh 	:= .F.
Local lCalcIb	:= .T.
Local lCalcImp 	:= .T.
Local lCalcMon	:= .F.
Local lCalImpos	:= .F.
Local lPropIB	:= Iif(GetMV("MV_PROPIB",.F.,1)==2,.T.,.F.)
Local lNoIns    := .F.
Local lCalNoIns := .F.
Local ltpLimVa  := .F.
Local cProvEnt  := ""
Local cChave    := ""
Local cCpoCFO   := ""
Local cItem		:= ""
Local cSituaca  := ""
Local nI		:= 0
Local aI, aX		:= 0
Local nTotRetSFE:= 0
Local nTotBasSFE:= 0
Local nLimMInRet:= 0
Local nImposto	:= 0
Local nBaseAtual:= 0
Local nImpAtual	:= 0
Local nRetencao	:= 0
Local nMoeda    := 1
Local nAliq     := 0
Local nVlrTotal := 0
Local nPos      := 0
Local nAliqaux	:= 0
Local nCoefmul	:= 0
Local nPercTot	:= 0
Local nTotBase	:= 0
Local nMinimo 	:= 0
Local nMinunit 	:= 0
Local nParcela	:= 0
Local nDeduc	:= 0
Local nCofRet	:= 0
Local nAliqRet 	:= 0 
Local nAliqAdc 	:= 0 
Local nObtMin 	:= 0
Local cZonaSFH := ""
Local cTipoSFH := ""
Local lAgRetCCO := .T.
Local nRecSF2	:= 0 
Local nTamSer := SerieNfId('SF2',6,'F2_SERIE')
Local lTESNoExen := .F.
Local cTipoCalc 		:= ""
Local nValorRet 		:= 0
Local nImpCalc 		:= 0
Local nCRFRET   		:= 0
Local cOriMin 		:= ""
Local aRetPreO		:= {} 
Local nCOTipMin 		:= 0
Local nTotCCO3 		:= nSaldo
Local lIsPA 			:= .F.
Local nRecSM0 		:= 0
Local lCCOLimRet := Iif(aConfProv[7] <> " ", .T., .F.)
Local cChaveSFE := ""
Local nLimiteSFF := 0
Local lLimPrim := .F.
Local nPrAliqIB := 1
Local lBxParcial := Iif(SE2->E2_SALDO < SE2->E2_VALOR,.T.,.F.)
Local cTabTemp	:= ""
Local cQuery 		:= ""
Local nRecnoSFH	:= 0
Local lYaGerado := .F. 
Local cTabCGF 	:= ""
Local nAliqCGF  := 0
Local cZonaCGF	:= ""
Local lRN4212   := .F.
Local lExisCGF	:= TableInDic("CGF")
Local nPosTes	:= 0
Local aTesNf 	:= {}
Local cMVAgIIBB := GetMv("MV_AGIIBB",,"CF|BA|SF|SE|TU|SA|JU|SL|MI|FO|ME|ER|SJ|LR|CO|CB|CA|NE|LP|TF|CH|RN|CR")

If	type("cFornece")=="U"
	cFornece :=SE2->E2_FORNECE
	cLoja:=SE2->E2_LOJA
EndIf

DEFAULT nSigno		:= -1
DEFAULT nPropImp	:= 1
DEFAULT aConfProv	:= {}
DEFAULT lSUSSPrim		:= .T.
DEFAULT lIIBBTotal 	:= .F.
DEFAULT aImpCalc 		:= {}
DEFAULT aSUSS 		:= {}
DEFAULT nLinha		:= 0
DEFAULT lLimNRet := .F.     
DEFAULT cChavePOP:= ""
DEFAULT cNFPOP	 := ""
DEFAULT cSeriePOP:= ""
DEFAULT dEmissao := CTOD("//")
DEFAULT lOPRotAut	:= .F.

If lShowPOrd .and. Funname() == "FINA847" .and. Type("lCtaCte")<>"U" .and. lCtaCte
	Return aSFEIB := ObtReten(cChavePOP,cNFPOP,cSeriePOP,"B",nSaldo,dEmissao,aConfProv)
EndIf                                        

lEsRetAdc := .F.

//?Obter Impostos somente qdo a Empresa Usuario for Agente de Retenๅญo.?

If !Empty(cMVAgIIBB) //.And. nSigno > 0
	SA2->( dbSetOrder(1) )
	If lMsFil .And. !Empty(xFilial("SA2")) .And. xFilial("SF1") == xFilial("SA2")
		SA2->( MsSeek(SE2->E2_MSFIL+SE2->E2_FORNECE+SE2->E2_LOJA) )
	Else
		SA2->( MsSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA) )
	Endif
	
	//?Generar las Retenci๎•” de Ingresos Brutos                       ?
	//?Reter Ingressos Brutos somente se valor total da Orden de Pago ?
	//?for igual ou maior que $400,00.                                ?
	

	If SA2->(ColumnPos("A2_DTICALB")) > 0 .And. SA2->(ColumnPos("A2_DTFCALB")) > 0 ;
	   .And. !Empty(SA2->A2_DTICALB) .And. !Empty(SA2->A2_DTFCALB)
	    If  ( Dtos(dDataBase)>= Dtos(SA2->A2_DTICALB) ) .And. ( Dtos(Ddatabase) <= Dtos(SA2->A2_DTFCALB) )
	   		lCalcIb:=.F.
	    EndIf
	EndIf

	If ExistBlock("F0851IMP")
		lCalcIb:=ExecBlock("F0851IMP",.F.,.F.,{"IB2"})
	EndIf
	If lCalcIb .And. SA2->A2_RETIB == "S"

		dbSelectArea("SF2")
		dbSetOrder(1)
		If lMsFil
			nRecSF2 := FINBuscaNF(SE2->E2_MSFIL,SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_FORNECE,SE2->E2_LOJA,"SF2",.T.)
			SF2->(dbGoTo(nRecSF2))
		Else
			nRecSF2 := FINBuscaNF(xFilial("SF2",SE2->E2_FILORIG),SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_FORNECE,SE2->E2_LOJA,"SF2",.T.)
			SF2->(dbGoTo(nRecSF2))
		EndIf
		If nRecSF2 > 0
			cChave := SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA
			If cPaisLoc<>"ARG"
				nRateio := 1
			else
				nRateio     := SF2->F2_VALMERC / SF2->F2_VALBRUT
			EndIf

			nRatValImp  := Iif(aConfProv[4] == "M" .And. !lPropIB,1,( Round(xMoeda(nSaldo,SE2->E2_MOEDA,1,,5,aTxMoedas[Max(SE2->E2_MOEDA,1)][2]),MsDecimais(1)) / Round(xMoeda(SF2->F2_VALBRUT,SF2->F2_MOEDA,1,,5,aTxMoedas[Max(SF2->F2_MOEDA,1)][2]),MsDecimais(1)) ) )
			nValMerc    := ( Round(xMoeda(nSaldo,SE2->E2_MOEDA,1,,5,aTxMoedas[Max(SE2->E2_MOEDA,1)][2]),MsDecimais(1)) * nRateio )
			nMoeda   := Max(nMoeda,SF2->F2_MOEDA)

			SD2->(DbSetOrder(3))
			If lMsFil
				SD2->(MsSeek(SF2->F2_MSFIL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
			Else
				SD2->(MsSeek(xFilial("SD2",SF2->F2_FILIAL)+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
			EndIf
			If SD2->(Found())
				nObtMin := 0
				Do while Iif(lMsFil,SF2->F2_MSFIL,xFilial("SD2",SF2->F2_FILIAL))==SD2->D2_FILIAL .And. SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA == cChave
				 
					If Alltrim(SD2->D2_ESPECIE) <> Alltrim(SF2->F2_ESPECIE) // .or. SD2->D2_PROVENT <> aConfProv[1]
						SD2->(DbSkip())
						Loop
					Endif

					If NoInsSFH(SA2->A2_COD,SA2->A2_LOJA,"IBR", aConfProv[1]) //Identifica tratamiento Retencion sujeto No inscripto
						aRes:= NoInsCCORet( aConfProv[1],SD2->D2_PROVENT)
						If (aRes[1][1] = "2" .and. SD2->D2_PROVENT <> aConfProv[1]) .Or. (aConfProv[1] == "TU" .and. SA2->A2_EST <> "TU")
							SD2->(DbSkip())
							Loop
						Endif
						aRes := {}
					Else 
						aRes := {}
					Endif 

					cProvEnt := ""

					//Por Entrega
					If aConfProv[2] == "1" .And. aConfProv[3] == "1"
						If SD2->(ColumnPos("D2_PROVENT")) >0 .And. !Empty(SD2->D2_PROVENT) .And. aConfProv[1] == SD2->D2_PROVENT
							cProvEnt := SD2->D2_PROVENT
						ElseIf  SF2->(ColumnPos("F2_PROVENT")) >0 .And.  !Empty(SF2->F2_PROVENT) .And. aConfProv[1] == SF2->F2_PROVENT .And. Empty(SD2->D2_PROVENT)
							cProvEnt := SF2->F2_PROVENT
						Endif
					//Por Pago
					ElseIf aConfProv[2] == "1" .And. aConfProv[3] == "2"
						SX5->(MsSeek(xFilial()+"74"))
						cSucur := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
						While !SX5->(EOF())  .And. SX5->X5_TABELA=="74"
							If SD2->D2_LOCAL  $ SX5->(X5DESCRI())
								cSucur := SUBS(SX5->X5_CHAVE,3,2)
								Exit
							Endif
							SX5->(DbSkip())
						EndDo

						nRecSM0 := SM0->(RecNo())
						cEmpAct := SM0->(M0_CODIGO)

						If SM0->(MsSeek(cEmpAct+cSucur))
							If SM0->(FOUND()) .And. aConfProv[1] == SM0->M0_ESTENT
								cProvEnt := SM0->M0_ESTENT
							EndIf
						ElseIf SM0->(MsSeek(cEmpAct+cFilAnt))
							cSucur := cFilAnt
							If SM0->(FOUND()) .And. aConfProv[1] == SM0->M0_ESTENT
								cProvEnt := SM0->M0_ESTENT
							EndIf							
						EndIf
						SM0->(DbGoto(nRecSM0))
					//Por Inscri็ขo
					ElseIf aConfProv[2] == "1" .And. aConfProv[3] == "3"
						If aConfProv[1] =="MI"
							If CCO->(MsSeek(xFilial("CCO") + aConfProv[1]))
								If CCO->CCO_TPRENI == "2" .And. aConfProv[4] == "N" .And. aConfProv[1] != SD2->D2_PROVENT
									SD2->(DbSkip())
									Loop
								Else
									cProvEnt := aConfProv[1]	
								EndIf
							EndIf
						Else
							cProvEnt := aConfProv[1]
						EndIf
					Endif

					//Verifica se a cidade ou provincia ja possui calculo de IIBB
					//homologado pelo depto. de localizacoes...
					If cProvEnt $ cMVAgIIBB .And. !(cProvEnt$"CF|BA|SF|SE|TU|SA|JU|SL|MI|FO|ME|ER|SJ|LR|CO|CB|CA|NE|LP|TF|CH|RN|CR|SC")
						If aScan(aProvVerif,cProvEnt) == 0
							If  lOPRotAut
								cTxtRotAut += OemToAnsi(STR0003+cProvEnt+STR0004) //"El proveedor " ### " no cuenta con la configuraci๓n necesaria para calcular la retenci๓n de SUSS a partir del documento origen. Indique concepto y/o tipo cแlculo correspondiente a valor informado."
								lMsErroAuto := .T.
							Else
								Aviso(OemToAnsi(STR0001),OemToAnsi(STR0003+cProvEnt+STR0004),{OemToAnsi(STR0002)}) //"Para la provincia o ciudad de "#" es necesario que el departamento de ubicaciones de Microsiga desarrolle la rutina de calculo. Por favor entre en contacto, con el administrador del sistema." 
							Endif
							AAdd(aProvVerif,cProvEnt)
						EndIf

						SD2->(DbSkip())
						Loop
					EndIf

					If !(cProvEnt $ cMVAgIIBB)
						SD2->(DbSkip())
						Loop
					EndIf
					
					nVlrTotal := SD2->D2_TOTAL
					//Verifica as caracteristicas do TES para verificar se houve
					//a incidencia de Percepcao de IIBB...
					If Len(aTesNf) > 0
						nPosTes := aScan(aTesNf,{|x| x[1] == SD2->D2_TES})
					EndIf
					If nPosTes == 0
						aImpInf := TesImpInf(SD2->D2_TES)
						aAdd(aTesNf, {SD2->D2_TES, aImpInf})
					Else
						aImpInf := aClone(aTesNf[nPosTes][2])
					EndIf
					lTESNoExen := aScan(aImpInf,{|x| "IV" $ AllTrim(x[1])}) <> 0
					If !lTESNoExen
						SD2->(DbSkip())
						Loop
					EndIf
					aArea:=GetArea()
					aReaSFF:=SFF->(GetArea())
					SFF->(dbSetOrder(12)) //FF_FILIAL+FF_IMPOSTO+FF_CFO_V+FF_ZONFIS+FF_TIPO
					SFF->(MsSeek(xFilial("SFF")+"IBR" +SD2->D2_CF+cProvEnt+aConfProv[4]))
		  			nTotBase:=0
	  				lCalImpos:=.F.
					If SFF->(Found())
  						aAreaAtu:=GetArea()
  						If SFF->(ColumnPos("FF_INCIMP")) > 0
							For nI := 1 To Len(aImpInf)
								If(Trim(aImpInf[nI][01])$ SFF->FF_INCIMP)
									lCalImpos:=.T.
								   	nTotBase+=SD2->(FieldGet(ColumnPos(aImpInf[nI][02])))
								Endif
							Next
						EndIf
						//Se cambian validaciones para obtener el tipo de retenci๓n, independientemente de si SFF tiene un importe diferente de 0.
						If (CCO->(ColumnPos("CCO_IMMINR")) > 0 .and. CCO->(ColumnPos("CCO_TPMINR")) > 0)
							If SFF->FF_IMPORTE == 0 .Or. Empty(SFF->FF_IMPORTE)
								nAliq  := SFF->FF_ALIQ
								cZona  := SFF->FF_ZONFIS
							EndIf
							CCO->(dbSetOrder(1))	//CCO_FILIAL+CCO_CODPRO
							If CCO->(MsSeek(xFilial("CCO") + cProvEnt))
								If SFF->FF_IMPORTE == 0 .Or. Empty(SFF->FF_IMPORTE)
									If CCO->CCO_IMMINR <> 0
										nObtMin := IIF(!Empty(CCO->CCO_TPMINR),Val(CCO->CCO_TPMINR),0)
										nLimMInRet := CCO->CCO_IMMINR
										cOriMin := "CCO"
									Endif
								Else
									nCOTipMin := IIF(!Empty(CCO->CCO_TPMINR),Val(CCO->CCO_TPMINR),0)
								EndIf
							Endif
						Else 
							nObtMin = 0
						Endif
						
						CCO->(dbSetOrder(1))	//CCO_FILIAL+CCO_CODPRO
						If CCO->(MsSeek(xFilial("CCO") + cProvEnt)) .And. CCO->(ColumnPos("CCO_TPCALC")) > 0 .And. cPaisLoc == "ARG"
							cTipoCalc := Iif(CCO->CCO_TPCALC == "2", "2", "1")
							If cTipoCalc == "2"
								nRatValImp := 1
								lIIBBTotal := .T.
							EndIf
						Endif
						
						If CCO->(MsSeek(xFilial("CCO") + cProvEnt)) .And. CCO->(ColumnPos("CCO_TPLIMR")) > 0 .And. cPaisLoc == "ARG" //.And. cProvEnt == "ER"
							If CCO->CCO_TPLIMR == "5"
								lCCOLimRet := .T.
							EndIf
						EndIf
						
					    RestArea(aAreaAtu)
					EndIf

						RestArea(aArea)
						SFF->(RestArea(aReaSFF))

						If !lCalImpos

							For nI := 1 To Len(aImpInf)
								If "IB"$Trim(aImpInf[nI][01]) .And. Trim(aImpInf[nI][01])<>"IBR"
									If !Empty(SD2->(FieldGet(ColumnPos(aImpInf[nI][10]))))
										nPos := aScan(aPerIB,{|x| x[1]==cProvent .And.	x[2]==SD2->D2_CF .And. x[3]==aImpInf[nI][01]})
										If (nPos) == 0
											AAdd(aPerIB,{cProvEnt,SD2->D2_CF,aImpInf[nI][01],aImpInf[nI][09]})
										Else
											If aImpInf[nI][09] > aPerIB[nPos][04]
												aPerIB[nPos][04] := aImpInf[nI][09]
											EndIf
										EndIf
									EndIf
								EndIf

							Next
						EndIf
						nPosIb := Ascan(aZonaIb,{|X| X[1]==cProvEnt .And. X[2]=SD2->D2_CF})
						If CCO->(ColumnPos("CCO_TPRET")) > 0 .and. CCO->(ColumnPos("CCO_TPRENI")) > 0  
							If NoInsSFH(SA2->A2_COD,SA2->A2_LOJA,"IBR", aConfProv[1]) // Identifica tratamiento Retencion sujeto No inscripto
								aRes:= NoInsCCORet( aConfProv[1],SD2->D2_PROVENT)
								lCalNoIns := aRes[1][2]
								lNoIns := IIf(!Empty(aRes[1][1]),.T.,.F.)
								nPosIb := Iif(lNoIns == .T.,Ascan(aZonaIb,{|X| X[1]==SD2->D2_PROVENT .And. X[2]=SD2->D2_CF}),nPosIb)  
								If nPosIb == 0 .and. lNoIns == .T. 
									If (lCalNoIns == .T. .and. aConfProv[1] = SD2->D2_PROVENT) .or. (Len(aRes)>0 .and. aRes[1][1] == "2")
										AAdd(aZonaIb,{SD2->D2_PROVENT,SD2->D2_CF,((nVlrTotal+nTotBase )* nRatValImp),0,aConfProv[4],SD2->D2_PROVENT})
									Endif 
								ElseIf nPosIb <> 0 .and. lNoIns == .T. 
									If lCalNoIns == .T. .or. (Len(aRes)>0 .and. aRes[1][1] == "2")
										aZonaIb[nPosIb][3] := aZonaIb[nPosIb][3]+((nVlrTotal+nTotBase )* nRatValImp)
									Endif 
								EndIf
							Else
								If nPosIb == 0 
									AAdd(aZonaIb,{cProvEnt,SD2->D2_CF,((nVlrTotal+nTotBase) * nRatValImp),0,aConfProv[4],SD2->D2_PROVENT})
								Else
									aZonaIb[nPosIb][3] := aZonaIb[nPosIb][3]+((nVlrTotal+nTotBase) * nRatValImp)
								Endif
							EndIf 	
						EndIf
						nVlrTotal := 0
						SD2->(DbSkip())
					Enddo
				Else
					nPosIb := Ascan(aZonaIb,{|X| X[1]==cProvEnt .And. X[2]==SD2->D2_CF})
					AAdd(aZonaIb,{cProvEnt,SD2->D2_CF,nValMerc,0,aConfProv[4],SD2->D2_PROVENT})
				Endif
			ElseIf SE2->E2_TIPO $ MVPAGANT .And. lRetPA .And. Alltrim(SE2->E2_ORIGEM)$"FINA085A|FINA850"
				lIsPA := .T.
				cTipoCalc := aConfProv[5]
				If cTipoCalc == "2"
					nRatPa := 1
					lIIBBTotal := .T.
				Else
					nRatPa := nSaldo/SE2->E2_VALOR
				EndIf 
				
				//Buscar el registro que se gener๓ en la creaci๓n del PA en la SFE y carga la inforamci๓n correspondiente.
				aArea:=GetArea()
				SFE->(DbSelectArea("SFE"))
	   			SFE->(DbSetOrder(2)) //2
				SFE->(MsSeek(xFilial("SFE")+ Substr(SE2->E2_NUM,1,Len(SFE->FE_ORDPAGO))+"B"))
				While SFE->(!EOF()) .And. Substr(SE2->E2_NUM,1,Len(SFE->FE_ORDPAGO))+"B" = SFE->FE_ORDPAGO + SFE->FE_TIPO
					If  SFE->FE_EST == aConfProv[1] .And. ( ( AllTrim(SFE->FE_ESPECIE) == "PA" ) .OR. ; 
						                                    ( AllTrim(SE2->E2_TIPO) $ "PA" .And. lRetPA .And. Empty(SFE->FE_NFISCAL) ) ) 
						If  !(Alltrim(SE2->E2_TIPO) == "PA" .And. Alltrim(SE2->E2_PARCELA) != '1' .And. SE2->E2_MOEDA != 1 ) 
							AAdd(aZonaIb, {aConfProv[1], PadR(SFE->FE_CFO, TamSX3("FF_CFO_C")[1], " "), SFE->FE_VALBASE * nRatPa, SFE->FE_VALIMP * nRatPa, aConfProv[4], SFE->FE_EST})
						Endif
						lYaGerado := .T.
					EndIf
					SFE->(DbSkip())
				EndDo
				RestArea(aArea)
			Endif

		For nJ   := 1  To Len(aZonaIb)
			lRet := .F.
			nBaseAtual := 0
			nAliqCGF	:= 0
			cZonaCGF 	:= aZonaIb[nJ][1]
			If  cPaisLoc == "ARG" .And. lExisCGF == .T. .And. cZonaCGF == "BA" .And. CGF->(ColumnPos("CGF_ALIQ")) > 0 
				lRN4212 := .T.
			Endif
			//Converter a base para moeda 1
			aZonaIb[nJ][3] := Round(xMoeda(aZonaIb[nJ][3],nMoeda,1,,5,aTxMoedas[nMoeda][2]),MsDecimais(1))

			cZona := ""
			SFF->( Iif(aZonaIb[nJ][2] < "500",dbSetOrder(10),dbSetOrder(12)) )
			
			SFF->(MsSeek( xFilial() + "IBR" + aZonaIb[nJ][2] + aZonaIb[nJ][1] +Iif(aZonaIb[nJ][5]<>Nil,aZonaIb[nJ][5],"") ))
			
			//Si CCO_TPLIMR == 5, valida si FF_TPLIM es diferente de 0 para no considerar el calculo de limite mensual
			If SFF->(Found()) .And. cPaisLoc == "ARG" .And. SFF->(ColumnPos("FF_TPLIM")) > 0 .And. lCCOLimRet
				If !Empty(SFF->FF_TPLIM) .And. SFF->FF_TPLIM != "0"
					lCCOLimRet := .F.
				EndIf
			EndIf
			
			If (aZonaIb[nJ][5]<>Nil .and. aZonaIb[nJ][5] == "V") .and. SFF->(Eof())
				SFF->(MsSeek(xFilial()+"IBR"+aZonaIb[nJ][2]+aZonaIb[nJ][1]+Iif(aZonaIb[nJ][5]<>Nil,"*","")))
			Endif 
			
			If  SFF->(Found()) .And. SFF->(ColumnPos("FF_CFORA")) > 0  
				nAliqRet  := SFF->FF_ALIQ
				lEsRetAdc :=ObtDesgl("IBR",SFF->FF_CFO_V,SFF->FF_ZONFIS,SFF->FF_TIPO,SFF->FF_CFORA,@nAliqAdc) //Obtener registro adicional                   
			Endif
			

			If aZonaIb[nJ][5] <> "M" .Or. (aZonaIb[nJ][5] == "M" .And. aZonaIb[nJ][1] <> "CF")
				If SFF->(Found())
					cZona := SFF->FF_ZONFIS //aZonaIb[nJ][1]
					If aZonaIb[nJ][1] == "TU" .and. aZonaIb[nJ][5] == "N" .and. aZonaIb[nJ][6] <> "TU"
						nAliq := SFF->FF_ALQNOINS
					Else
						nAliq := SFF->FF_ALIQ
					EndIf
					nLimMInRet := Iif(nObtMin == 0, SFF->FF_IMPORTE, nLimMInRet)
					cOriMin := Iif(nObtMin == 0, "SFF", cOriMin)
					If lCCOLimRet
						nLimiteSFF := SFF->FF_LIMITE
					EndIf
					If SFF->FF_PRALQIB <> 0
						nPrAliqIB := SFF->FF_PRALQIB
					EndIf
				Else
					cCpoCFO := Iif(aZonaIb[nJ][2] < "500","FF_CFO_C","FF_CFO_V")
					SFF->( Iif(aZonaIb[nJ][2] < "500",dbSetOrder(11),dbSetOrder(13)) )
					If aZonaIb[nJ][1] == "CF" .And. aZonaIb[nJ][5] == "I"
						If SFF->(MsSeek(xFilial()+"IBR"+aZonaIb[nJ][1]+aZonaIb[nJ][5]+Replicate("*",TamSX3(cCpoCFO)[1]) ))
							cZona := aZonaIb[nJ][1]
							nAliq := SFF->FF_ALIQ
							nLimMInRet := Iif(nObtMin == 0, SFF->FF_IMPORTE, nLimMInRet)
							cOriMin := Iif(nObtMin == 0, "SFF", cOriMin)
							If lCCOLimRet
								nLimiteSFF := SFF->FF_LIMITE
							EndIf
							If SFF->FF_PRALQIB <> 0
								nPrAliqIB := SFF->FF_PRALQIB
							EndIf
						EndIf
					Else
						If SFF->(MsSeek(xFilial()+"IBR"+aZonaIb[nJ][1]+Replicate("*",TamSx3("FF_TIPO")[1])+Replicate("*",TamSX3(cCpoCFO)[1]) ))
							cZona := aZonaIb[nJ][1]
							If aZonaIb[nJ][1] == "TU" .and. aZonaIb[nJ][5] == "N" .and. aZonaIb[nJ][6] <> "TU"
								nAliq := SFF->FF_ALQNOINS
							Else
								nAliq := SFF->FF_ALIQ
							EndIf
							nLimMInRet := Iif(nObtMin == 0, SFF->FF_IMPORTE, nLimMInRet)
							cOriMin := Iif(nObtMin == 0, "SFF", cOriMin)
							If lCCOLimRet
								nLimiteSFF := SFF->FF_LIMITE
							EndIf
							If SFF->FF_PRALQIB <> 0
								nPrAliqIB := SFF->FF_PRALQIB
							EndIf
						EndIf
					EndIf
				EndIf
			Elseif aZonaIb[nJ][1] =="CF" .And. aZonaIb[nJ][5] == "M"

				If SFF->FF_TIPO == 'M'

					cItem := SFF->FF_ITEM
					cZona := SFF->FF_ZONFIS
					nAliq := SFF->FF_ALIQ
					nLimMInRet := Iif(nObtMin == 0, SFF->FF_IMPORTE, nLimMInRet)
					cOriMin := Iif(nObtMin == 0, "SFF", cOriMin)
					If lCCOLimRet
						nLimiteSFF := SFF->FF_LIMITE
					EndIf
					If SFF->FF_PRALQIB <> 0
						nPrAliqIB := SFF->FF_PRALQIB
					EndIf

					nMinimo  	:= Iif(SFF->(ColumnPos("FF_LIMITE"))>0,SFF->FF_LIMITE,0)
					nMinUnit 	:= Iif(SFF->(ColumnPos("FF_MINUNIT"))>0,SFF->FF_MINUNIT,0)

					aAreaSFF := SFF->(GetArea())

					SFF->(dbSetOrder(11))
					SFF->(MsSeek(xFilial()+"IBR"+aZonaIb[nJ][1]))

					//Array contendo todos os CFOs com a mesma classifica็ขo
					While SFF->(!Eof()) .And. SFF->FF_IMPOSTO == "IBR"
						If SFF->FF_TIPO == 'M' .And. SFF->FF_ITEM == cItem .And. SFF->FF_ZONFIS == cZona
							If aScan(aCf,{|x| x[1] == SFF->FF_CFO_C}) == 0
								aAdd(aCf,{SFF->FF_CFO_C,SFF->FF_CFO_V})
							Endif
						Endif
						SFF->(dbSkip())
					Enddo

			 		SFF->(RestArea(aAreaSFF))

					//Verifica se deve calcular IB
					lCalcMon := F850CheckLim(cItem,aCf,SF2->F2_CLIENTE,nMinimo,SF2->F2_DOC,PadR(SF2->F2_SERIE,nTamSer),nMinUnit,"IB",,2,Iif(lMsFil,SF2->F2_MSFIL,""))
				Endif
  			Endif
			If aZonaIb[nJ][1] =="CR"
				nTotRetSFE:=0
				nTotBasSFE:=0
				
				AcumRetIBB(SF2->F2_CLIENTE, SF2->F2_LOJA, aConfProv[1], @nTotRetSFE, @nTotBasSFE) //Acumulado de retenci๓n de IIBB
				nBaseAtual:= (nTotBasSFE + (aZonaIb[nJ][3]*nPropImp)*nSigno)
			EndIf

			If lCCOLimRet
				AcumRetIBB(SF2->F2_CLIENTE, SF2->F2_LOJA, aConfProv[1], @nTotRetSFE, @nTotBasSFE) //Acumulado de retenci๓n de IIBB
			EndIf

			If aZonaIb[nJ][1] == "ME"
				nBaseAtual:= (nTotBasSFE + (aZonaIb[nJ][3]*nPropImp)*nSigno)
			Endif 
			
			If  lRN4212
				DbSelectArea("CCP")
				CCP->(DbSetOrder(1))//CCP_FILIAL+CCP_COD+CCP_VORIGE
				CCP->(DbGoTop())
				If  CCP->(MsSeek(xFilial("CCP")+"RN42"+aZonaIb[nJ][2]))//Tabla RN42- CFO
					// SE obtienen los registros de la CGF para el proveedor
					cTabCGF := GetNextAlias()
					cQuery := "SELECT * "
					cQuery += "FROM " + RetSqlName("CGF")+ " CGF "
					cQuery += "WHERE CGF_FORNEC='" + SA2->A2_COD + "' AND "
					cQuery += "CGF_LOJA		='" + SA2->A2_LOJA + "'   AND "
					cquery += "CGF_ZONFIS 	='" + cZonaCGF +"' 		  AND "
					cQuery += "CGF_FILIAL	='" +XFILIAL("CGF") + "'  AND "
					cQuery += "CGF_IMPOST 	='IBR' 	AND "
					cQuery += "CGF_ALIQ 	<> 0 	AND "
					
					cquery += "((CGF_FIMVIG>='"+Dtos(dDataBase)+"' AND "									      
					cquery += "CGF_INIVIG<='"+Dtos(dDataBase)+"')  OR "                                            
					
					cquery += "(CGF_FIMVIG=' ' AND "									      
					cquery += "CGF_INIVIG=' ') OR "
					
					cquery += "(CGF_FIMVIG=' ' AND "									      
					cquery += "CGF_INIVIG<='"+Dtos(dDataBase)+"') OR "      
					
					cquery += "(CGF_FIMVIG>='"+Dtos(dDataBase)+"' AND "									      
					cquery += "CGF_INIVIG=' '))"      
					
					cQuery += " AND "
					cQuery += "D_E_L_E_T_<>'*'"
					cQuery += "ORDER BY CGF_INIVIG,CGF_FIMVIG"
	
					cQuery := ChangeQuery(cQuery)
	
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTabCGF,.T.,.T.)
					TCSetField(cTabCGF,"CGF_INIVIG","D")
	 				TCSetField(cTabCGF,"CGF_FIMVIG","D")
	
					Count to nNumRegs

					If nNumRegs > 0 // Se verifica que existan registros para el proveedor en CGF
						(cTabCGF)->(dbGoTop())
						WHILE (cTabCGF)->(!eof()) .And. !lRet
	
							If !((dDatabase >=(cTabCGF)->CGF_INIVIG .Or. Empty((cTabCGF)->CGF_INIVIG) ) .And. ;
								(dDatabase <= (cTabCGF)->CGF_FIMVIG .Or. Empty((cTabCGF)->CGF_FIMVIG))) 
								(cTabCGF)->(dbskip())
								Loop
							EndIf
	
							If !Empty((cTabCGF)->CGF_INIVIG) .And. !Empty((cTabCGF)->CGF_FIMVIG)
								IF (dDatabase >=(cTabCGF)->CGF_INIVIG ) .AND. dDatabase <= (cTabCGF)->CGF_FIMVIG
									nAliqCGF := (cTabCGF)->CGF_ALIQ
									lRet := .T.
								EndIF
							Else
								If Empty((cTabCGF)->CGF_INIVIG) .and. Empty((cTabCGF)->CGF_FIMVIG)
									nAliqCGF := (cTabCGF)->CGF_ALIQ								
								Else
									If (dDatabase >= (cTabCGF)->CGF_INIVIG .and. !Empty((cTabCGF)->CGF_INIVIG)) .or. (dDatabase <= (cTabCGF)->CGF_FIMVIG .and.  !Empty((cTabCGF)->CGF_FIMVIG))
										nAliqCGF := (cTabCGF)->CGF_ALIQ
										lRet := .T.
									EndIf
								EndIf
							Endif						
							(cTabCGF)->(dbskip())
						EndDo
					Endif
					(cTabCGF)->(dbCloseArea())
				Endif
			Endif
			lRet := .F.
			
			If IIf(lRN4212,.T.,!Empty(cZona)) .And. (aZonaIb[nJ][5] <> "M" .Or. (aZonaIb[nJ][5] == "M" .And. lCalcMon) .Or. (aZonaIb[nJ][5] == "M" .And.aZonaIb[nJ][1] <> "CF") .or. (lCalNoIns))
				// SE obtienen los registros de la SFH para el proveedor
				cTabTemp := criatrab(nil,.F.)
				cQuery := "SELECT * "
				cQuery += "FROM " + RetSqlName("SFH")+ " SFH "
				cQuery += "WHERE FH_FORNECE='" + SA2->A2_COD + "' AND "
				cQuery += "FH_LOJA='"  + SA2->A2_LOJA + "' AND "
				cQuery += "FH_IMPOSTO='IBR' AND "
				cquery += "FH_ZONFIS='" + cZona +"' AND "
				If cPaisLoc == "ARG"
					cQuery += "FH_FILIAL='" +XFILIAL("SFH") + "' AND "
				Else
					If !Empty(xFilial("SFH"))  .and. !Empty(xFilial("SA2"))
						cQuery += "FH_FILIAL='" +XFILIAL("SA2") + "' AND "
					ElseIf !Empty(xFilial("SFH")) .and. !Empty(xFilial("SE2"))
						cQuery += "FH_FILIAL='" +XFILIAL("SE2") + "' AND "
					Endif
				EndIf                                                            
				
				cquery += "((FH_FIMVIGE>='"+Dtos(dDataBase)+"' AND "									      
				cquery += "FH_INIVIGE<='"+Dtos(dDataBase)+"') OR "                                            
				
				cquery += "(FH_FIMVIGE=' ' AND "									      
				cquery += "FH_INIVIGE=' ') OR "
				
				cquery += "(FH_FIMVIGE=' ' AND "									      
				cquery += "FH_INIVIGE<='"+Dtos(dDataBase)+"') OR "      
				
				cquery += "(FH_FIMVIGE>='"+Dtos(dDataBase)+"' AND "									      
				cquery += "FH_INIVIGE=' '))"      
				
				cQuery += " AND "
				cQuery += "D_E_L_E_T_<>'*'" 
				cQuery += "ORDER BY FH_INIVIGE,FH_FIMVIGE"

				cQuery := ChangeQuery(cQuery)

				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTabTemp,.T.,.T.)
				TCSetField(cTabTemp,"FH_INIVIGE","D")
 				TCSetField(cTabTemp,"FH_FIMVIGE","D")

				Count to nNumRegs
				
				If nNumRegs > 0 // Se verifica que existan registros para el proveedor en SFH
					(cTabTemp)->(dbGoTop())
					WHILE (cTabTemp)->(!eof())   .And. ;
						(cTabTemp)->FH_FORNECE==SA2->A2_COD .AND. (cTabTemp)->FH_LOJA == SA2->A2_LOJA .And. (cTabTemp)->FH_ZONFIS == cZona .And. !lRet

						If lNoIns .Or. !((dDatabase >=(cTabTemp)->FH_INIVIGE .Or. Empty((cTabTemp)->FH_INIVIGE) ) .And. ;
							(dDatabase <= (cTabTemp)->FH_FIMVIGE .Or. Empty((cTabTemp)->FH_FIMVIGE))) 
							(cTabTemp)->(dbskip())
							Loop
						Else
							nAliqAux := nAliq 
							nRecnoSFH := (cTabTemp)->R_E_C_N_O_
						EndIf
						
						(cTabTemp)->(dbskip())
					EndDo
				EndIf
				(cTabTemp)->(dbCloseArea())
				
				//?Validar en el archivos de exepciones fiscales si el Proveedor  ?
				//?es exento en la zona fiscal actual.                            ?
				
  				SFH->(DbSetOrder(1))
				SFH->(dbGoTo(nRecnoSFH))
				
				lIsento := SFH->FH_ISENTO == "S"
				
				If SFH->(Found()) .and. !lNoIns
					If SFH->FH_ISENTO=="S" .OR. SFH->FH_PERCENT == 100
						lIsento := .T.
					Else
						If !Empty(SFH->FH_DTINI) .And. !Empty(SFH->FH_DTFIM)
							If dDataBase>=(SFH->FH_DTINI) .And. dDataBase<=(SFH->FH_DTFIM)
								lIsento := .T.
							Else
								lIsento := .F.
							Endif
						Else
							lIsento := .F.
						Endif
					Endif

				EndIf
				While !lNoIns .and. !SFH->(EOF()).And. (SFH->FH_ISENTO <> "S" .And. (dDataBase < SFH->FH_DTINI .Or. dDataBase > SFH->FH_DTFIM)).And.;
										 SFH->FH_FORNECE==SE2->E2_FORNECE .AND. SFH->FH_LOJA == SE2->E2_LOJA .And. SFH->FH_ZONFIS == cZona .And. !lRet
					lFoundFh:= .T.										 		
					If !Empty(SFH->FH_INIVIGE) .And. !Empty(SFH->FH_FIMVIGE)
						IF(dDatabase >= SFH->FH_INIVIGE ) .AND. dDatabase <= SFH->FH_FIMVIGE					
							nCoefmul := SFH->FH_COEFMUL
							nAliqaux := SFH->FH_ALIQ
							lIsento  := IIF(SFH->FH_ISENTO=="S" .OR. SFH->FH_PERCENT == 100 ,.T.,.F.)
							nPercTot :=(100 - SFH->FH_PERCENT) /100	 // % de Exencion del Impuesto								
							lRet := .T.
							cSituaca := SFH->FH_SITUACA
							cZonaSFH := SFH->FH_ZONFIS
							cTipoSFH := SFH->FH_TIPO
						EndIF
					Else
						If Empty(SFH->FH_INIVIGE) .and. Empty(SFH->FH_FIMVIGE)
							nCoefmul := SFH->FH_COEFMUL
							nAliqaux := SFH->FH_ALIQ
							lIsento  := IIF(SFH->FH_ISENTO=="S"  .OR. SFH->FH_PERCENT == 100,.T.,.F.)
							nPercTot :=(100 - SFH->FH_PERCENT) /100	 // % de Exencion del Impuesto
							cSituaca := SFH->FH_SITUACA								
							cZonaSFH := SFH->FH_ZONFIS
							cTipoSFH := SFH->FH_TIPO								
						Else
							If (dDatabase >= SFH->FH_INIVIGE .and. !Empty(SFH->FH_INIVIGE)) .or. (dDatabase <= SFH->FH_FIMVIGE .and.  !Empty(SFH->FH_FIMVIGE))
								nAliqaux := SFH->FH_ALIQ
								lIsento  := IIF(SFH->FH_ISENTO=="S"  .OR. SFH->FH_PERCENT == 100,.T.,.F.)
								nPercTot :=(100 - SFH->FH_PERCENT) /100	 // % de Exencion del Impuesto										
								nCoefmul := SFH->FH_COEFMUL
								lRet := .T.
								cSituaca := SFH->FH_SITUACA
								cZonaSFH := SFH->FH_ZONFIS
								cTipoSFH := SFH->FH_TIPO
							EndIf
						EndIf
					Endif							
					
					If CCO->(ColumnPos("CCO_RPROAG")) > 0 .And. SFH->FH_IMPOSTO ==  "IBR" .And. cPaisLoc == "ARG"
						If CCO->(MsSeek(xFilial("CCO")+SFH->FH_ZONFIS))
							If CCO->CCO_CODPRO == SFH->FH_ZONFIS .And. CCO->CCO_AGRET == "1" .And. CCO->CCO_RPROAG == "N" .And. SFH->FH_AGENTE == "S"
								lAgRetCCO := .F.
							EndIf
						EndIf
					EndIf
						
					SFH->(DbSkip())
				EndDo  
				If  lRN4212 .And. nAliqCGF <> 0
					nAliqAux := nAliqCGF
				Endif
				If  lYaGerado 
					nCoefmul := 0 //No considerar la reducci๓n
				Endif        
				IF lFoundFh
					IF nAliqAux <> 0
						lRet := .T.
					EndIF
					If lRet .and. !lIsento .AND. nAliqAux <> 0	// Si se encontr?un registro y no es excento, se toma el valor de al้–uota.
						//Aplica % de Reducao para Convenio Multilateral...
						If  cZonaSFH <> "TU"						     
							nDeduc := aZonaIb[nJ][3]
							nCofRet := nCoefMul		
							aZonaIb[nJ][3] := aZonaIb[nJ][3] * nPercTot
							If nCoefmul <> 0
								aZonaIb[nJ][3] := aZonaIb[nJ][3] * (nCoefmul/100) 
							EndIf                                                           
		  					nDeduc -= aZonaIb[nJ][3]
		  				Else
		  					aZonaIb[nJ][3] := aZonaIb[nJ][3] * nPercTot
		  				EndIf
						If cSituaca == "2" 
							nAliq := nAliqAux * (1+(POSICIONE("CCO",1,xFilial("CCO")+cZOna,"CCO_CRFRET"))/100)
						ElseIf cZonaSFH == "TU" .and. cTipoSFH == "V" .and. nAliqAux <> 0 
							If SA2->A2_EST <> "TU" .and. nCoefMul <> 0
								aZonaIb[nJ][3] := aZonaIb[nJ][3] * (nCoefmul) 
								nAliq := (nAliqAux * Iif (nPrAliqIB<>1,1-(nPrAliqIB/100),nPrAliqIB))
							ElseIf SA2->A2_EST == "TU" .and. nPrAliqIB <> 0
								nAliq := (nAliqAux * Iif (nPrAliqIB<>1,1-(nPrAliqIB/100),nPrAliqIB))
							Else
								nAliq := nAliqAux
							EndIf	
						ElseIf cZonaSFH == "TU" .and. cTipoSFH == "N"
							nAliq := 0
						Else
							nAliq := nAliqAux * Iif (nPrAliqIB<>1,1-(nPrAliqIB/100),nPrAliqIB)
						Endif
					ElseIf lRet .and. !lIsento .AND. nAliqAux == 0
						If cZonaSFH == "TU" .and. aZonaIb[nJ][6] <> "TU" .and. cTipoSFH == "V" .and. SA2->A2_EST <> "TU"
							If CCO->(ColumnPos("CCO_CRFRET")) > 0
								nCRFRET := POSICIONE("CCO",1,xFilial("CCO")+cZOna,"CCO_CRFRET")
							EndIf
							If nCRFRET <> 0
								nAliq :=  (nAliq * nCRFRET) 
							EndIf
						ElseIf nPrAliqIB<>1
							nAliq := nAliq * (1-(nPrAliqIB/100))
						EndIf
					EndIf			
				EndIF					
				If !lIsento

					If SFF->FF_REDBASE <> 0 .and. aZonaIb[nJ][3] <> 0 .And. !lYaGerado
						aZonaIb[nJ][3] := (aZonaIb[nJ][3] * (( 100 - SFF->FF_REDBASE ) / 100 ) )
					Endif
					
					If TYPE ("aProvLim") == "A"  
						nPsLmPv := Ascan(aProvLim, {|xT| xT[1] == aZonaIb[nJ][1]})
					Else
						nPsLmPv := 0
					EndIf
					
					If nPsLmPv > 0
						lLimPrim := aProvLim[nPsLmPv][2]
					EndIf 
					
					//Si el IIBB se controla por tipo 2 (total) 
					If cTipoCalc == "2" .And. cPaisLoc == "ARG"
						SFE->(dbSetOrder(4))
						nRetSFE:=0
						If lShowPOrd .and. TableInDic("FVC") .and. Funname() == "FINA855"
							DBSELECTAREA("FVC")
							FVC->(DBSETORDER(3)) //FVC_FILIAL+FVC_FORNEC+FVC_LOJA+FVC_NFISC+FVC_SERIE+FVC_TIPO+FVC_CONCEP
							If FVC->(MsSeek(xFilial("FVC")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC))
								While FVC->(!Eof()) .and. FVC->(FVC_FORNEC+FVC_LOJA+FVC_NFISC) == SF2->(F2_CLIENTE+F2_LOJA+F2_DOC)
									If AllTrim(FVC->FVC_TIPO) $ "B" .and. ABS(FVC->FVC_RETENC) > 0 .and. FVC->FVC_SERIE == SF2->F2_SERIE .and. cZona == FVC->FVC_EST
										AADD(aRetPreO,FVC->(FVC_FORNEC+FVC_LOJA+FVC_NFISC+FVC->FVC_SERIE+FVC_PARCEL))
										nRetSFE +=  FVC->FVC_RETENC
									EndIf
									FVC->(dbSkip())
								Enddo
							EndIf	
						EndIf
						//Si es para un PA 
						If lIsPA
							SFE->(dbSetOrder(4)) //4
							//Cuenta el total de registros en SFE, correspondiente a ๓rdenes de pago anteriores.
							cChaveSFE := xFilial("SFE") + SE2->E2_FORNECE + SE2->E2_LOJA + SE2->E2_NUM + SE2->E2_PREFIXO + "B"
							If SFE->(MsSeek(cChaveSFE))
								While !SFE->(Eof()) .And. cChaveSFE == xFilial("SFE") + SFE->FE_FORNECE + SFE->FE_LOJA + SFE->FE_NFISCAL + SFE->FE_SERIE + SFE->FE_TIPO .And. cZona == SFE->FE_EST
									nRetSFE += SFE->FE_RETENC
									SFE->(dbSkip())
								Enddo
							EndIf
						Else 
							If SFE->(MsSeek(xFilial("SFE") + SF2->F2_CLIENTE + SF2->F2_LOJA + SF2->F2_DOC + SF2->F2_SERIE + "B"))  //Cuenta el total de registros en SFE, correspondiente a ๓rdenes de pago anteriores.
								cChaveSFE := SFE->FE_FILIAL + SFE->FE_FORNECE + SFE->FE_LOJA + SF2->F2_DOC + SF2->F2_SERIE + "B"
								While !SFE->(Eof()) .And. cChaveSFE == xFilial("SFE") + SFE->FE_FORNECE + SFE->FE_LOJA + SFE->FE_NFISCAL + SFE->FE_SERIE + SFE->FE_TIPO
									If Month(SFE->FE_EMISSAO) != Month(dDataBase) .Or. YEAR(SFE->FE_EMISSAO) != Year(dDataBase) .Or. !(SFE->FE_TIPO $ "B") .Or. cZona != SFE->FE_EST 
										SFE->(dbSkip())
										Loop
									EndIf
									If lShowPOrd .and. TableInDic("FVC") .and. Funname() == "FINA855"
										If Ascan(aRetPreO,{|x| x == SFE->(SFE->FE_FORNECE + SFE->FE_LOJA + SFE->FE_NFISCAL + SFE->FE_SERIE + SFE->FE_PARCELA)}) == 0
											nRetSFE += SFE->FE_RETENC
										EndIf
									Else
										nRetSFE += SFE->FE_RETENC
									EndIf
									SFE->(dbSkip())
								EndDo
							EndIf
						EndIf
						
						//Impostos recalculados na tela - Modificar OP
						//Impostos calculados - IVA, IB...
						nImpCalc := 0
						If Len(aImpCalc) > 0
							For aX := 1 to Len(aImpCalc[nLinha])
								If ValType(aImpCalc[nLinha][aX]) == "A"
									nImpCalc += aImpCalc[nLinha][aX][2]
								EndIf
							Next
							
							For aX := 1 to Len(aSFEIb)
								If ValType(aSFEIb[aX]) == "A"
									nImpCalc += aSFEIb[aX][6]
								EndIf
							Next
							
							//Ganancia
							If Len(aImpCalc[Len(aImpCalc)]) > 0 .And. valtype(aImpCalc[Len(aImpCalc)][1]) <> "A"  .And. aImpCalc[Len(aImpCalc)][1] == "GAN"
								nImpCalc += aImpCalc[Len(aImpCalc)][2]
							Endif
						End
						
						If lCCOLimRet .And. nLimiteSFF > 0 .And. lLimPrim
							//FE_VALIMP
							nValorRet := Round((((nTotBasSFE + aZonaIb[nJ][3]) * (nAliq/100)) - nTotRetSFE) * nSigno,TamSX3("FE_VALIMP")[2])
						Else
							//Se calcula si la diferencia entre los pagos y el total a pagar.
							nValorRet := Iif(aZonaIb[nJ][4]<>0,Round(aZonaIb[nJ][4]*nPropImp,TamSX3("FE_VALIMP")[2])*nSigno,Round((((aZonaIb[nJ][3]* nPropImp)*nSigno)*(nAliq/100)),TamSX3("FE_VALIMP")[2])) - nRetSFE ////FE_VALIMP
						EndIf
						
						If aZonaIb[nJ][1] $ "CR|ME|"
							nValorRet := Iif(aZonaIb[nJ][4]<>0,Round(aZonaIb[nJ][4]*nPropImp,TamSX3("FE_VALIMP")[2])*nSigno,Round(((nBaseAtual*(nAliq/100))-nRetSFE),TamSX3("FE_VALIMP")[2]))  //FE_VALIMP
						EndIf 
						
						//Si a๚n existe un monto a pagar, se valida que el saldo sea suficiente para cubrir el monto, de lo contario se calcula solo lo que es posible cubrir o no se cubre en lo absoluto.
						If nValorRet != 0
							If (nSaldo - ABS(nImpCalc)) < ABS(nValorRet)
								nValorRet := (nSaldo - ABS(nImpCalc))
								If nValorRet > 0
									nValorRet := nValorRet * nSigno
								Else
									nValorRet := 0
								EndIf
							EndIf 
						EndIf 
						
					EndIf
					
					If cTipoCalc == "2" .And. nValorRet != 0 .And. cPaisLoc == "ARG"
						nRetencao := nValorRet //FE_VALIMP
					ElseIf cTipoCalc == "2" .And. nValorRet == 0 .And. cPaisLoc == "ARG"
						lAgRetCCO := .F.
						nRetencao := 0
					Else
						nRetencao := Iif(aZonaIb[nJ][4]<>0,Round(aZonaIb[nJ][4]*nPropImp,TamSX3("FE_VALIMP")[2])*nSigno,Round((((aZonaIb[nJ][3]* nPropImp)*nSigno)*(nAliq/100)),TamSX3("FE_VALIMP")[2]))  //FE_VALIMP
						If aZonaIb[nJ][1] $ "CR|ME|"
							nRetencao := Iif(aZonaIb[nJ][4]<>0,Round(aZonaIb[nJ][4]*nPropImp,TamSX3("FE_VALIMP")[2])*nSigno,Round(((nBaseAtual*(nAliq/100))-nTotRetSFE),TamSX3("FE_VALIMP")[2]))  //FE_VALIMP
						EndIf
						If lCCOLimRet .And. nLimiteSFF > 0 .And. lLimPrim
							//FE_VALIMP
							nRetencao := Round((((nTotBasSFE + aZonaIb[nJ][3]) * (nAliq/100)) - nTotRetSFE) * nSigno,TamSX3("FE_VALIMP")[2])
						EndIf
					EndIf 

					If (SFF->FF_PRALQIB <> 0) .And. (Len(aPerIB) > 0) .and. !(aZonaIb[nJ][1] == "TU" .and. aZonaIb[nJ][5] == "V")

						If aScan(aPerIB,{|x| X[1]==aZonaIb[nJ][1] .And. X[2]==aZonaIb[nJ][2] .And. x[4]<nAliq}) > 0
							nAliq := nAliq * (SFF->FF_PRALQIB/100)
						EndIf
					EndIf
					
					If nSaldo == 0
						lAgRetCCO := .F.
					EndIf
					
					Aadd(aSFEIb,Array(33))
					aSFEIb[Len(aSFEIb)][1] := SE2->E2_NUM                   //FE_NFISCAL
					aSFEIb[Len(aSFEIb)][2] := SE2->E2_PREFIXO               //FE_SERIE
					aSFEIb[Len(aSFEIb)][3] := (aZonaIb[nJ][3]* nPropImp)*nSigno        //FE_VALBASE
					aSFEIb[Len(aSFEIb)][4] := nAliq
					If aZonaIb[nJ][1] == "CR"
						aSFEIb[Len(aSFEIb)][5] := nRetencao
					ElseIf lLimNRet
						nRetencao := 0
						aSFEIb[Len(aSFEIb)][5] := nRetencao
					Else
						aSFEIb[Len(aSFEIb)][5] := nRetencao
					EndIf
					
					aSFEIb[Len(aSFEIb)][6] := aSFEIb[Len(aSFEIb)][5]        //FE_RETENC
					aSFEIb[Len(aSFEIb)][7] := nSaldo//SE2->E2_VALOR
					aSFEIb[Len(aSFEIb)][8] := SE2->E2_EMISSAO
					aSFEIb[Len(aSFEIb)][9] := cZona
					aSFEIb[Len(aSFEIb)][10]:= SE2->E2_MOEDA
					aSFEIb[Len(aSFEIb)][11]:= SFF->FF_CFO_C  //CFO - COMPRA
					aSFEIb[Len(aSFEIb)][12]:= SFF->FF_CFO_V  //CFO - VENDA
					aSFEIb[Len(aSFEIb)][13]:= SE2->E2_TIPO
					aSFEIb[Len(aSFEIb)][14]:= SFF->FF_CONCEPT
					aSFEIb[Len(aSFEIb)][15]:= nDeduc
					aSFEIb[Len(aSFEIb)][16]:= nCofRet
					aSFEIb[Len(aSFEIb)][17]:= lEsRetAdc
					aSFEIb[Len(aSFEIb)][18]:= Iif(lEsRetAdc,SFF->FF_CFORA,"")   
					aSFEIb[Len(aSFEIb)][19]:= nAliqRet    
					aSFEIb[Len(aSFEIb)][20]:= nAliqAdc	
					aSFEIb[Len(aSFEIb)][21]:= 1
					aSFEIb[Len(aSFEIb)][22]:= 0
					aSFEIb[Len(aSFEIb)][23]:= 0
					aSFEIb[Len(aSFEIb)][24]:= 0
					aSFEIb[Len(aSFEIb)][25]:= cOriMin
					aSFEIb[Len(aSFEIb)][26]:= nLimMInRet // Monto del mํnimo, para calculo de mํnimos por OP
					aSFEIb[Len(aSFEIb)][27]:= Iif(cOriMin == "SFF", nCOTipMin, nObtMin) // De donde se obtuvo el mํnimo, para calculo de mํnimos por OP
					aSFEIb[Len(aSFEIb)][28]:= Iif(!(aConfProv[1] $ ("SF|BA|CO")), 0, nTotCCO3) //Base imponible + impuestos solamente cuando es para SF.
					aSFEIb[Len(aSFEIb)][29]:= aConfProv[6]
					aSFEIb[Len(aSFEIb)][30]:= lCCOLimRet .And. nLimiteSFF > 0
					aSFEIb[Len(aSFEIb)][31]:= nLimiteSFF
					aSFEIb[Len(aSFEIb)][32]:= nTotRetSFE //Monto retencion limite
					aSFEIb[Len(aSFEIb)][33]:= nTotBasSFE //Monto base imponible limite.				
				EndIf

			Endif
		Next
	EndIf
EndIf

If !lAgRetCCO .And. cPaisLoc == "ARG" .Or. (cTipoCalc == "2" .And. !lSUSSPrim .And. cPaisLoc == "ARG")
	aSFEIB := {}
	If TYPE ("aProvLim") == "A" .And. Len(aProvLim) > 0 .And. nPsLmPv > 0
		aProvLim[nPsLmPv][2] := lLimPrim
	EndIf
EndIf

Return aSFEIB



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ObtDesgl บ Autor บ  Luis Samaniego    บ Data บ  19/05/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Obtener informacion de SFF y SFH                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funcao auxiliar                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/ 
Function ObtDesgl(cImpsto,cCodC,cZona,cTipo,cCodAdc,nAliqAdc) 
Local lRet		:= .F.  
Local cTabTemp	:= criatrab(nil,.F.)   
Local cQuery  	:= ""  
Local nNumRegs	:= 0 

If cPaisLoc $ "ANG|ARG|BOL|COL|COS|DOM|EQU|EUA|HAI|MEX|PAD|PAN|PAR|PER|POR|PTG|RUS|SAL|URU|VEN"

	cQuery := "SELECT * "
	cQuery += "FROM " + RetSqlName("SFF")+ " SFF "
	cQuery += "WHERE FF_TIPO ='"+ cTipo +"' AND "
	cQuery += "FF_CFO_C   ='" + cCodAdc + "' AND "
	cQuery += "FF_IMPOSTO ='" + cImpsto +"' AND "
	cquery += "FF_ZONFIS  ='" + cZona +"' AND "
	cQuery += "FF_FILIAL='" +XFILIAL("SFF") + "' AND "
	cQuery += "D_E_L_E_T_<>'*'"
	
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTabTemp,.T.,.T.)
	
	Count to nNumRegs
	
	If  nNumRegs > 0	//Verificar que exista un registro adicional
		(cTabTemp)->(dbGoTop())
		If (cTabTemp)->(!eof())
			nAliqAdc:= (cTabTemp)->FF_ALIQ  
			lRet    := .T.
		Endif   
	Endif 
	(cTabTemp)->(dbCloseArea())

EndIf

Return lRet     




/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออหออออออออออออออออออหออออออหออออออออออออปฑฑ
ฑฑบPrograma  ณ NoInsSFH    บ Autor บEmanuel Villica๑a บ Data บ  21/08/14  บฑฑ
ฑฑบออออออออออุอออออออออออออสอออออออสออออออออออออออออออสออออออสออออออออออออนฑฑ
ฑฑบDescricao ณ Identifica No inscripto en SFH                             บฑฑ
ฑฑบออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA085A, FINA850                                          บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function NoInsSFH(cProv,cLoja,cImposto,cZona)
Local aArea      := {}
Local aAreaSFH   := {}
Local lCalNoIns  := .T. 
Local nPosSFH	 := 0

If Type("aSFHNoIns") <> "U" .And. Len(aSFHNoIns) > 0
	nPosSFH := aScan(aSFHNoIns, {|x| x[1] == cProv .and. x[2] == cLoja .and. x[3] == cImposto .and. x[4] == cZona})
Endif

If nPosSFH == 0
	If 	cPaisLoc $ "ANG|ARG|BOL|COL|COS|DOM|EQU|EUA|HAI|MEX|PAD|PAN|PAR|PER|POR|PTG|RUS|SAL|URU|VEN"
		aArea      := GetArea()
		aAreaSFH   := SFH->(GetArea())
		SFH->(DbSetOrder(1))
		If SFH->(MsSeek(xFilial()+cProv + cLoja + cImposto + cZona))
			While !SFH->(EOF()) .and. (xFilial("SFH")+cProv + cLoja + cImposto + cZona == SFH->FH_FILIAL + SFH->FH_FORNECE + SFH->FH_LOJA + SFH->FH_IMPOSTO + SFH->FH_ZONFIS)
				If (SFH->FH_TIPO == "N" .and. A085aVigSFH())
					lCalNoIns := .T.
					Exit
				ElseIf A085aVigSFH() .and. SFH->FH_TIPO <> "N"
					lCalNoIns := .F.
					Exit 
				Endif
				SFH->(DbSkip())
			EndDo 
		Else
			lCalNoIns := .T.
		Endif
		If Type("aSFHNoIns") <> "U"
			aAdd(aSFHNoIns, {cProv, cLoja, cImposto, cZona, lCalNoIns})
		EndIf
		RestArea(aAreaSFH)
		RestArea(aArea)
	Endif
Else
	lCalNoIns := aSFHNoIns[nPosSFH][5]
Endif
Return lCalNoIns



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออหออออออออออออออออออหออออออหออออออออออออปฑฑ
ฑฑบPrograma  ณ NoInsCCORet บ Autor บEmanuel Villica๑a บ Data บ  21/08/14  บฑฑ
ฑฑบออออออออออุอออออออออออออสอออออออสออออออออออออออออออสออออออสออออออออออออนฑฑ
ฑฑบDescricao ณ Identifica que proceso se realizara para prov. No inscriptoบฑฑ
ฑฑบDescricao ณ en retencion de IB                                         บฑฑ
ฑฑบออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ FINA085A, FINA850                                          บฑฑ
ฑฑบออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function NoInsCCORet(cZonCCO,cProvProc)
Local aArea      := {}
Local aAreaCCO   := {}
Local cTppeni    := ""
Local lCalNoIns  := .F.
Local aRes       := {}
Local cRadica	 := SA2->A2_EST
Local nPosProv   := 0
Local cTpRet     := ""

Default cZonCCO   := ""
Default cProvProc := ""

If Type("aCCORetNoIns") <> "U" .And. Len(aCCORetNoIns) > 0
	nPosProv := aScan(aCCORetNoIns, {|x| x[1] == cZonCCO})
Endif
If nPosProv == 0
	aArea      := GetArea()
	aAreaCCO   := CCO->(GetArea())
	If CCO->(ColumnPos("CCO_TPRET")) > 0 .and. CCO->(ColumnPos("CCO_TPRENI")) > 0;
			.and. cPaisLoc == "ARG"	.and. !Empty(cZonCCO)
		CCO->(DbSetOrder(1))
		If CCO->(MsSeek(xFilial("CCO") + cZonCCO))
			cTppeni	:= CCO->CCO_TPRENI 
			cTpRet  := CCO->CCO_TPRET
			If !Empty(cTppeni) .and. cTpRet == "3"
				If	( cTppeni == "1" .and. (cZonCCO == cProvProc  .or. cZonCCO == cRadica) ) .or.;
					( cTppeni == "2" .and. cZonCCO == cProvProc ) .or.;
					( cTppeni == "3" .and. cZonCCO == cRadica )
					lCalNoIns := .T.
				Else 
					lCalNoIns := .F.
				Endif 
			Else
				lCalNoIns := .F.
			Endif
			If Type("aCCORetNoIns") <> "U"
				aAdd(aCCORetNoIns, {cZonCCO, cTppeni, cTpRet, lCalNoIns})
			EndIf
		Endif  
	Endif
	RestArea(aAreaCCO)
	RestArea(aArea) 
Else
	cTppeni := aCCORetNoIns[nPosProv][2]
	cTpRet := aCCORetNoIns[nPosProv][3]
	lCalNoIns := aCCORetNoIns[nPosProv][4]

	If !Empty(cTppeni) .and. cTpRet == "3" .And. !lCalNoIns
		If	( cTppeni == "1" .and. (cZonCCO == cProvProc  .or. cZonCCO == cRadica) ) .or.;
			( cTppeni == "2" .and. cZonCCO == cProvProc ) .or.;
			( cTppeni == "3" .and. cZonCCO == cRadica )
			lCalNoIns := .T.
		Endif 
	Endif
Endif
AAdd(aRes,{cTppeni,lCalNoIns})
Return aRes

/*/{Protheus.doc} AcumRetIBB
	(Obtener el acumulado de retenci๓n de IIBB)
	@type  Function
	@author Arturo Samaniego
	@since 19/07/2021
	@param 
		cCodProv (C): C๓digo de Proveedor
		cLojProv (C): Tienda del Proveedor
		cProvIB (C): C๓digo de Provinicia
		nTotRetSFE (N): Valor FE_RETENC
		nTotBasSFE (N): Valor FE_VALBASE
	@return Nil
/*/
Static Function AcumRetIBB(cCodProv, cLojProv, cProvIB, nTotRetSFE, nTotBasSFE)
Local cTempSFE := Criatrab(nil,.F.)
Local cMes     := StrZero(Month(dDataBase),2)
Local cAno     := StrZero(Year(dDataBase),4)
Local cQrySFE  := ""
Local nNumRegs := 0

Default cCodProv   := ""
Default cLojProv   := ""
Default cProvIB    := ""
Default nTotRetSFE := 0
Default nTotBasSFE := 0

	cQrySFE := " SELECT SUM(FE_RETENC) FE_RETENC, SUM(FE_VALBASE) FE_VALBASE"
	cQrySFE += " FROM " + RetSqlName("SFE") + " SFE "
	cQrySFE += " WHERE FE_FILIAL = '" + xFilial('SFE') + "' "
	cQrySFE += " AND Substring(FE_EMISSAO,5,2) ='" + cMes + "' "
	cQrySFE += " AND Substring(FE_EMISSAO,1,4)  ='" + cAno +"' "
	cQrySFE += " AND FE_FORNECE = '" + cCodProv + "' "
	cQrySFE += " AND FE_LOJA = '" + cLojProv + "' "
	cQrySFE += " AND FE_EST = '" + cProvIB + "' "
	cQrySFE += " AND FE_TIPO = 'B' "
	cQrySFE += " AND D_E_L_E_T_ <> '*' "

	cQrySFE := ChangeQuery(cQrySFE)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySFE),cTempSFE,.T.,.T.)
	
	Count to nNumRegs
	
	If  nNumRegs > 0
		(cTempSFE)->(dbGoTop())
		If (cTempSFE)->(!eof())
			nTotRetSFE += (cTempSFE)->FE_RETENC
			nTotBasSFE += (cTempSFE)->FE_VALBASE
		Endif   
	Endif 
	(cTempSFE)->(dbCloseArea())

Return Nil
