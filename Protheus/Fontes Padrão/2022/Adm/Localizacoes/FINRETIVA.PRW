#include "protheus.CH"
#include "FINRETIVA.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RetIVADeb ºAutor  ³                    º Data ³  31/07/2020 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ RetIVADeb   - Calculo de Ret de IVA para NF                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ArgRetIVA (FINRETARG)                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ 1. cAgente: Agente de retención (N = No/ S = Si).          º±±
±±           ³ 2. nSigno: 1 / (-1)Si SE2->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG º±±
±±           ³ 3. nSaldo: Saldo (valor baser o valor a bajar).            º±±
±±           ³ 4. lPa                                                     º±±
±±           ³ 5. cCF                                                     º±±
±±           ³ 6. nValor                                                  º±±
±±           ³ 7. nProp                                                   º±±
±±           ³ 8. cSerieNF                                                º±±
±±           ³ 9. nA                                                      º±±
±±           ³ 10.aPagAux                                                 º±±
±±           ³ 11.naPagar                                                 º±±
±±           ³ 12.cChavePOP: FJK_PREOP+Proveedor+Loja, usada en ObtReten()º±±
±±           ³ 13.cNFPOP:Num de documento(E2_NUM), usado en ObtReten()    º±±
±±           ³ 14.cSeriePOP: Serie(E2_PREFIXO), usada en ObtReten()       º±±
±±           ³ 15.dEmissao: Fch emisión CXP(E2_EMISSAO), usada ObtReten() º±±
±±           ³ 16.lOPRotAut: Es rutina automatica (.T.)                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RetIVADeb(cAgente,nSigno,nSaldo,lPa,cCF,nValor,nProp,cSerieNF,nA,aPagAux,naPagar,cChavePOP,cNFPOP,cSeriePOP,dEmissao,lOPRotAut)
Local oDlg4
Local aConIva  	 := {}
Local aSFEIVA  	 := {}
Local aDocAcm  	 := {}
Local aConfIva 	 := {} 
Local aAreaSFE 	 := {}
Local aSalRet 	 := {}
Local aFIva	:= FilImpto({"3"},{"I"},{},{}) // Retorna todos los impuestos con IVA de SFB
Local lRetSerie	 :=	 .F.
Local lCalRet	 := .F.
Local lCalcImp	 := .T.
Local lCalRep	 := .F.
Local lCalcVen	 := .F.
Local lCalrtexp	 := .F.
Local lRetIVA	 := .F.
Local lAcmIva	 := .F.
Local lCalcAcm	 := .F.
Local lRetSit 	 := .T.
Local lExiste	 := .F.
Local lCalcNew	 := GetNewPar("MV_GRETIVA","N") == "S"
Local lReSaIV	 	:= GetNewPar("MV_RETIVA","N") == "S"
Local cChaveSFE	 := ""
Local cAcmIVA	 := ""
Local cConc		 := ""
Local nPorIva	 := 0 
Local nPosIva	 := 0
Local nCount	 := 0
Local nPercRet	 := 0
Local nBase		 := 0
Local nI 		 := 1
Local nValorBr	 := 0
Local nTotBase	 := 0
Local nRetIva 	 := 0
Local nRetTotal	 := 0
Local nTotRet	 := 0
Local nTotRetSFE := 0
Local nVlrTot 	 := 0
Local nX		 := 1
Local nPosDoc 	 := 0
Local nImporte 	 := 0
Local nVRetIVA := 0
Local nSRetIVA := 0
Local nSRIva	:= 0
Local nSVIva	:= 0
Local nRecSF1	 := 0 
Local nTamSer := SerieNfId('SF1',6,'F1_SERIE')
Local lTESNoExen := .F.
Local aRetPreO	:= {}
Local cCFOIVA 	:= ""
Local cCFOVIVA 	:= ""
Local nValBas	:= 0
Local nRedAliq	:= 0 
Local lCalcCbu :=.F.
Local nPercCF   := 0
Local aAreaSFF  := {}
Local nPosTES	:= 0
Local aTesNf 	:= {}
Local aTesFin   := {}

If type("cFornece")=="U"
	 cFornece	:=SE2->E2_FORNECE
	 cLoja		:=SE2->E2_LOJA
EndIf

DEFAULT lPa		 :=	.F.
DEFAULT cCF 	 := ""
DEFAULT nValor 	 := 0
DEFAULT nSigno	 := 1
DEFAULT naPagar	 := 0
DEFAULT cChavePOP:= ""
DEFAULT cNFPOP	 := ""
DEFAULT cSeriePOP:= ""
DEFAULT dEmissao := CTOD("//")
DEFAULT lOPRotAut:= .F. 

If lPa 
	Return aSFEIVA
Endif

If lShowPOrd .and. Funname() == "FINA847" .and. Type("lCtaCte")<>"U" .and. lCtaCte
	Return aSFEIVA := ObtReten(cChavePOP,cNFPOP,cSeriePOP,"I",nSaldo,dEmissao)
EndIf

//+---------------------------------------------------------------------+
//?Obter Impostos somente qdo a Empresa Usuario for Agente de RetençŽŸo.?
//+---------------------------------------------------------------------+
aArea:=GetArea()
dbSelectArea("SF1")
dbSetOrder(1)

If ValType(lMsFil) == "U"
	lMsFil :=	SE2->( ColumnPos('E2_MSFIL') > 0 ) .And. ; 
				SD1->( ColumnPos('D1_MSFIL') > 0 ) .And. ;
				SD2->( ColumnPos('D2_MSFIL') > 0 ) .And. ;
			  	SF1->( ColumnPos('F1_MSFIL') > 0 ) .And. ;
				SF2->( ColumnPos('F2_MSFIL') > 0 ) 
EndIf

If lMsFil
	nRecSF1 := FINBuscaNF(SE2->E2_MSFIL,SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_FORNECE,SE2->E2_LOJA,"SF1",.T.)
	SF1->(dbGoTo(nRecSF1))
Else
	nRecSF1 := FINBuscaNF(xFilial("SF1", SE2->E2_FILORIG),SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_FORNECE,SE2->E2_LOJA,"SF1",.T.)
	SF1->(dbGoTo(nRecSF1))
EndIf

nVRetIVA	:=	Iif(lReSaIV, SF1->F1_RETIVA, 0)
nSRetIVA	:=	Iif(lReSaIV, SF1->F1_SALIVA, 0)
lCalRet := Iif(Alltrim(PadR(SF1->F1_SERIE,nTamSer)) == "M" .or. (Alltrim(PadR(SF1->F1_SERIE,nTamSer)) == "A" .and. cPaisLoc=="ARG"),.T.,.F.)
lCalcAcm := Subs(cAgente,2,1) == "N"
If(SF1->(ColumnPos("F1_TPNFEXP"))>0 .And.  SFF->(ColumnPos("FF_VLRLEX"))>0 .And. SFF->(ColumnPos("FF_ALIQLEX"))>0  .And.  SF1->F1_TPNFEXP=="1")  //1 - Exportador 2- Normal
	lCalrtexp:=.T.
EndIf

If ExistBlock("F0851IMP")
	lCalcImp:=ExecBlock("F0851IMP",.F.,.F.,{"IVA"})
EndIf

If type("inclui")=="U"
	 inclui:=NIL
EndIf

SA2->( dbSetOrder(1) )
If !lPa
	SA2->( MsSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA) )
Else
	SA2->( MsSeek(xFilial("SA2")+cFornece+cLoja) )
EndIf    
If ((SA2->(ColumnPos("A2_CBUINI"))>0 .and. SA2->(ColumnPos("A2_CBUFIM"))>0) .and. SA2->A2_CBUINI <= SE2->E2_EMISSAO .and. SA2->A2_CBUFIM >= SE2->E2_EMISSAO .and.  Subs(SF1->F1_SERIE,1,1) =="A") .or. Subs(SF1->F1_SERIE,1,1) =="M"
	lCalcCbu:=.T.
EndIf   
If (Subs(cAgente,2,1) == "S"  .Or. lCalRet .Or. lCalcAcm .or. lCalcCbu) .And. lCalcImp  .And.  lRetSit
	SA2->( dbSetOrder(1) )
	If !lPa
		If !Empty(xFilial("SA2")) .And. lMsFil .And. xFilial("SF1") == xFilial("SA2")
			SA2->( MsSeek(SE2->E2_MSFIL+SE2->E2_FORNECE+SE2->E2_LOJA) )
		Else
			SA2->( MsSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA) )
		Endif
	Else
		SA2->( MsSeek(xFilial("SA2")+cFornece+cLoja))
	EndIf
	
	//Si el proveedor es Agente de Ret., independientemente si la emp es o no agente, no se debe retener
	If SA2->A2_AGENRET == "S" .And. Alltrim(PadR(SF1->F1_SERIE,nTamSer)) <> "M"
		Return aSFEIVA
	Endif

	lCalRep := Iif(SA2->(ColumnPos("A2_SITU")>0) .and. Alltrim(SA2->A2_SITU)$("2/4"),.T.,.F.)
	If SA2->A2_AGENRET == "N"   .Or. lCalRet

		If !lPA //Se estou em um PA
			While Alltrim(SF1->F1_ESPECIE)<>AllTrim(SE2->E2_TIPO).And.!EOF()
				SF1->(DbSkip())
				Loop
			Enddo
			
			If AllTrim(SF1->F1_ESPECIE)==Alltrim(SE2->E2_TIPO).And.;
				Iif(lMsFil,SF1->F1_MSFIL,xFilial("SF1", SE2->E2_FILORIG))+SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE+SE2->E2_LOJA==;
				SF1->F1_FILIAL+SF1->F1_DOC+PadR(SF1->F1_SERIE,nTamSer)+SF1->F1_FORNECE+SF1->F1_LOJA

				//?Se esta definida uma retencao para uma serie especial, verifico?
				//?antes de procurar no SD1.(Serie 'M' foi o primeiro caso).      ?

				SFF->(DbSetOrder(3))

				If SFF->(MsSeek(xFilial("SFF")+"IVR"+PadR(SF1->F1_SERIE,nTamSer)+"SER")) .And.  !lCalrtexp .And. !lCalcAcm

					SD1->(DbSetOrder(1))
	              	If lMsFil
						SD1->(MsSeek(SF1->F1_MSFIL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
					Else
						SD1->(MsSeek(xFilial("SD1", SE2->E2_FILORIG)+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
					EndIf
					If SD1->(Found())
						Do while Iif(lMsFil,SF1->F1_MSFIL,xFilial("SD1", SE2->E2_FILORIG))==SD1->D1_FILIAL.And.SF1->F1_DOC==SD1->D1_DOC.AND.;
							SF1->F1_SERIE==SD1->D1_SERIE.AND.SF1->F1_FORNECE==SD1->D1_FORNECE;
							.AND.SF1->F1_LOJA==SD1->D1_LOJA.AND.!SD1->(EOF())

							aImpInf := TesImpInf(SD1->D1_TES)
							lTESNoExen := aScan(aImpInf,{|x| "IV" $ AllTrim(x[1])}) <> 0
							If !lTESNoExen
								SD1->(DbSkip())
								Loop
							EndIf

							For nI := 1 To Len(aImpInf)
								If  "IV"$Trim(aImpInf[nI][01]) .And. aImpInf[nI][14] == "N";
										.And. aImpInf[nI][15] == "I" .And. aImpInf[nI][16] == "3"
									nPosIva:=ASCAN(aConIva,{|x| x[1]==SF1->F1_SERIE})
									If nPosIva<>0
										aConIva[nPosIva][2]:=aConIva[nPosIva][2]+(SD1->(FieldGet(ColumnPos(aImpInf[nI][02]))))
										aConIva[nPosIva][3]:=aConIva[nPosIva][3]+(SD1->(FieldGet(ColumnPos(aImpInf[nI][07]))))
									Else										
									   	nVlrTot := SD1->(FieldGet(ColumnPos(aImpInf[nI][02])))
										Aadd(aConIva,{SD1->D1_CF,nVlrTot,SD1->(FieldGet(ColumnPos(aImpInf[nI][07]))), (SD1->(FieldGet(ColumnPos(aImpInf[nI][10]))) /100),,,nPercCF})
									Endif

									If SD1->(FieldGet(ColumnPos(aImpInf[nI][07]))) < SFF->FF_IMPORTE
										aConIVA[1][2]:= ((SFF->FF_ALIQ/100 ) * (SD1->(FieldGet(ColumnPos(aImpInf[nI][07])))))
									Endif
								Endif
							Next
							SD1->(DbSkip())
						Enddo
					Endif

					lRetSerie	:=	.T.

				Else
				
					//?Obter o Valor do Imposto e Base baseando se no rateio do valor ?
					//?do titulo pelo total da Nota Fiscal.                           ?
					
					SD1->(DbSetOrder(1))
					If lMsFil
						SD1->(MsSeek(SF1->F1_MSFIL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
					Else
						SD1->(MsSeek(xFilial("SD1", SE2->E2_FILORIG)+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
					EndIf
					If SD1->(Found())
						Do while Iif(lMsFil,SF1->F1_MSFIL,xFilial("SD1", SE2->E2_FILORIG))==SD1->D1_FILIAL.And.SF1->F1_DOC==SD1->D1_DOC.AND.;
							SF1->F1_SERIE==SD1->D1_SERIE.AND.SF1->F1_FORNECE==SD1->D1_FORNECE;
							.AND.SF1->F1_LOJA==SD1->D1_LOJA.AND.!SD1->(EOF())

							If AllTrim(SD1->D1_ESPECIE)<>AllTrim(SF1->F1_ESPECIE)
								SD1->(DbSkip())
								Loop
							Endif
							
							If Len(aTesNf) > 0
								nPosTES := aScan(aTesNf,{|x| x[1] == SD1->D1_TES})
							EndIf
							If nPosTES == 0
								aImpInf := TesImpInf(SD1->D1_TES)
								aAdd(aTesNf, {SD1->D1_TES, aImpInf})
							Else
								aImpInf := aClone(aTesNf[nPosTES][2])
							EndIf

							lTESNoExen := aScan(aImpInf,{|x| "IV" $ AllTrim(x[1])}) <> 0
							If !lTESNoExen
								SD1->(DbSkip())
								Loop
							EndIf
							
							//Variable aTES se utiliza en las funciones ValImpto y ValBasImp
							If Len(aTesFin) > 0
								nPosTES := aScan(aTesFin,{|x| x[1] == SD1->D1_TES})
							EndIf
							If nPosTES == 0
								aTes := TesImpFin(SD1->D1_TES)
								aAdd(aTesFin, {SD1->D1_TES, aTes})
							Else
								aTes := AClone(aTesFin[nPosTES][2])
							EndIf

							nPercCF := 0
							SB1->(DbSetOrder(1))
							If !Empty(SD1->D1_CF)
							
								nRateio := 1
								If  lCalcCbu  								
									For nI := 1 To Len(aImpInf)
										If  "IV"$Trim(aImpInf[nI][01]) .And. aImpInf[nI][14] == "N";
										.And. aImpInf[nI][15] == "I" .And. aImpInf[nI][16] == "3"
											nPercCF := SD1->(FieldGet(ColumnPos(aImpInf[nI][10])))
										EndIf
									Next
									If   Len(aConIva)>0 
										 nPosIva:=ASCAN(aConIva,{|x| x[7]==nPercCF})
									Endif
								Else
									nPosIva:=ASCAN(aConIva,{|x| x[1]==SD1->D1_CF})
								Endif
								If lCalcNew  .Or.  lCalrtexp // Calcula IVA metodo Novo
									If  nPosIva<>0
										If Len(aConIVA[nPosIVA]) >= 6  .And. Valtype(aConIva[nPosIva][6])=="C"
											cAcmIVA := aConIva[nPosIva][6]
										EndIF 
										If (SB1->B1_RG2849 <> 0 .Or. cAcmIVA == "2")
											nValor := SD1->D1_TOTAL-SD1->D1_VALDESC
											aConIva[nPosIva][2]+= ( (aConIva[nPosIva][4] * nValor )  - (SD1->D1_IVAFRET+SD1->D1_IVAGAST) ) * nRateio
											aConIva[nPosIva][3]+= nValor - (SD1->D1_BaIVAFR+SD1->D1_BaIVAGA) * nRateio
										Else
											nValor :=  ValImpto(aFIva,SD1->D1_TES, aTes)
											If  lCalcCbu .Or. lCalRep
												nValBas:=  ValBasImp(aFIva,SD1->D1_TES, aTes)
											Endif
											aConIva[nPosIva][2]+= ( (aConIva[nPosIva][4] * Iif(lCalcCbu .Or. lCalRep,nValBas,nValor)  )  - (SD1->D1_IVAFRET+SD1->D1_IVAGAST) ) * nRateio
											aConIva[nPosIva][3]+=  Iif(lCalcCbu .Or. lCalRep,nValBas,nValor) - (SD1->D1_BaIVAFR+SD1->D1_BaIVAGA) * nRateio
										EndIf
									Else
										cAcmIVA := ""
										If lCalRep .or. lCalcVen
											For nI := 1 To Len(aImpInf)
												If  "IV"$Trim(aImpInf[nI][01]) .And. aImpInf[nI][14] == "N";
													.And. aImpInf[nI][15] == "I" .And. aImpInf[nI][16] == "3"
													Aadd(aConIva,{SD1->D1_CF,SD1->(FieldGet(ColumnPos(aImpInf[nI][02]))),SD1->(FieldGet(ColumnPos(aImpInf[nI][07]))), (SD1->(FieldGet(ColumnPos(aImpInf[nI][10]))) /100),cAcmIVA,,nPercCF})
												EndIf
											Next
										Else
											SFF->(DbSetOrder(5))
											SFF->(DbGotop())
											If SFF->(MsSeek(xFilial("SFF")+"IVR"))
												nPerc:=0
												lAchou:=.F.
												While SFF->(!EOF() ).and. (xFilial("SFF")+"IVR") ==(SFF->FF_FILIAL+SFF->FF_IMPOSTO) .And.  !lAchou
													If (Alltrim(SFF->FF_SERIENF)== SubStr(Alltrim(PadR(SD1->D1_SERIE,nTamSer)),1,1) .And. SD1->D1_CF==  SFF->FF_CFO_C )
														lExistSFF:=.T.
														If GetNewPar("MV_SEGMEN","") $ "1|2|4"
															If   SA2->(ColumnPos("A2_TIPROVM"))>0 .AND.  ((SA2->A2_TIPROVM $ "0|1|2|3" .AND. SFF->FF_REGIST=="1") .OR. ( SA2->A2_TIPROVM $ "4" .AND. SFF->FF_REGIST=="2" ))
																lExistSFF:=.T.
															Else
																lExistSFF:=.F.
															EndIf
														Endif
														If lExistSFF
															lAchou:=.T.
															nPerc := SFF->FF_ALIQ
															cCFOIVA	:= SFF->FF_CFO_C
															cCFOVIVA := SFF->FF_CFO_V
															nRedAliq:= SFF->FF_REDALIQ 
															If SFF->(ColumnPos("FF_TPLIM")) > 0
																cAcmIVA := SFF->FF_TPLIM
																nLimite := SFF->FF_LIMITE
															EndIf  
															If SFF->(ColumnPos("FF_IMPORTE")) > 0
																nImporte := SFF->FF_IMPORTE
															EndIf															
														EndIf														
													EndIf
													SFF->(DbSkip())
												EndDO

												If cAcmIva != "2" .And. Subs(cAgente,2,1) == "N" .And. SA2->A2_AGENRET == "N" .And. Alltrim(PadR(SF1->F1_SERIE,nTamSer)) <> "M" .And. !lCalcCbu
													Return aSFEIVA
												EndIf

												/************************************************
												Verifica o acumulado para o cé† culo do imposto
												************************************************/

												//caso seja branco ou né‰¶ foi selecionado nenhum mé– odo de acumulo
												If Type("aRetIvAcm") <> "A"
													aRetIvAcm := Array(3)
												EndIf

												If !Empty(cAcmIVA) .And. cAcmIVA <> "0" .And. lCalcAcm
													aDadosIVA 	:= F850AcmIVA(cAcmIVA,SF1->F1_EMISSAO,SF1->F1_FORNECE,SF1->F1_LOJA,Iif(lMsFil,SF2->F2_MSFIL,""),cCFOIVA,cCFOVIVA)


													nBase := aDadosIVA[1]

													If aDadosIVA[4]
														If nBase >= nLimite 
															lRetIva := .T.
															lAcmIva := .T.
																
															For nX := 1 to Len(aDadosIVA[3])
																aAdd(aDocAcm, {aDadosIVA[3][nX][3], aDadosIVA[3][nX][4], Iif(aDadosIVA[3][nX][1],.F.,.T.),aDadosIVA[3][nX][6],aDadosIVA[3][nX][5],aDadosIVA[3][nX][7]})
																
																//Proporção do valor dos títulos parcelados
																If aDadosIVA[3][nX][5] = SE2->(Recno())
																	nRateio := aDadosIVA[3][nX][6]/100	
																EndIf
																
															Next nX
															
															If Len(aDocAcm) > 0
																aAdd(aConfIVA,nPerc)
																
																aRetIvAcm[1] :=  aConfIVA
																
																If aRetIvAcm[2] == Nil
																	aRetIvAcm[2] := {}
																EndIf
																
																For nX := 1 to Len(aDocAcm)
																	If aDocAcm[nX][2] == "SF1"
																		nPosDoc := aScan(aRetIvAcm[2],{|x| x[1]==aDocAcm[nX][1] .And. x[5]==aDocAcm[nX][5] .And. x[2]=="SF1"})
																	Else
																		nPosDoc := aScan(aRetIvAcm[2],{|x| x[1]==aDocAcm[nX][1] .And. x[5]==aDocAcm[nX][5] .And. x[2]=="SF2"})
																	EndIf
																	If nPosDoc == 0
																		If aDocAcm[nX][6]
																			Aadd(aRetIvAcm[2],aDocAcm[nX])
																		EndIf
																	EndIf
																Next nX
																
															EndIf
															
														EndIf
													Else
														lRetIva := .T.
													EndIf
												Else
													//Se né‰¶ usa cumulatividade de IVA, calcula no mé– odo antigo
													lRetIva := .T.
												EndIf

												If  lCalrtexp .And.	lAchou
													If Alltrim(PadR(SD1->D1_SERIE,nTamSer)) == "B" .and. SA2->A2_TIPO == "I" 
														nPerc := POSICIONE("SFB",1,xFilial("SFC")  + POSICIONE("SFC", 2, xFilial("SFC") + SD1->D1_TES + "IV", "FC_IMPOSTO" ),"FB_ALIQ")
														nValorBr:=Round(xmoeda(SF1->F1_VALBRUT,SF1->F1_MOEDA,1,,5,aTxMoedas[Max(SF1->F1_MOEDA,1)][2]),MsDecimais(1)) / (1+ (nPerc/100))
													Else
														nValorBr:=Round(xmoeda(SF1->F1_VALBRUT,SF1->F1_MOEDA,1,,5,aTxMoedas[Max(SF1->F1_MOEDA,1)][2]),MsDecimais(1))
														nPerc:=Iif(nValorBr>SFF->FF_VLRLEX,SFF->FF_ALIQ,SFF->FF_ALIQLEX)
													EndIf
												EndIf
							
												If lRetIva
													If cPaisLoc == "ARG" .And. ( (SB1->(ColumnPos("B1_RG2849"))>0 .AND. SB1->B1_RG2849 <> 0) .Or. cAcmIVA == "2")
														nValor := SD1->D1_TOTAL-SD1->D1_VALDESC 
														Aadd(aConIva,{SD1->D1_CF,(((nPerc/100 ) * nValor )  - (SD1->D1_IVAFRET+SD1->D1_IVAGAST)),(nValor - (SD1->D1_BaIVAFR +SD1->D1_BaIVAGA)),(nPerc /100),nImporte,cAcmIVA,nPercCF})
													Else
														nValor :=  ValImpto(aFIva,SD1->D1_TES, aTes)
														nValBas :=  ValBasImp(aFIva,SD1->D1_TES, aTes)
														If  lCalcCbu 
															Aadd(aConIva,{SD1->D1_CF,(((nPercCF/100*(1-nRedAliq/100) ) * nValBas )  - (SD1->D1_IVAFRET+SD1->D1_IVAGAST)),(nValBas - (SD1->D1_BaIVAFR +SD1->D1_BaIVAGA)),(nPercCF /100*(1-nRedAliq/100)),nImporte,cAcmIVA,nPercCF})														
														Else    
															Aadd(aConIva,{SD1->D1_CF,(((nPerc/100 ) * nValor )  - (SD1->D1_IVAFRET+SD1->D1_IVAGAST)),(nValor - (SD1->D1_BaIVAFR +SD1->D1_BaIVAGA)),(nPerc /100),nImporte,cAcmIVA,nPercCF})
														EndIf	
													EndIf													    
												EndIf
											EndIf
										EndIf
									EndIF						
								Endif								
							ElseIf SB1->(MsSeek(Iif(lMsFil .And. !Empty(xFilial("SB1")),SD1->D1_MSFIL,xFilial("SB1")) + SD1->D1_COD))
								nPosIva:=ASCAN(aConIva,{|x| x[1]==SB1->B1_CONCIVA})
								If nPosIva<>0
									aConIva[nPosIva][2]:=aConIva[nPosIva][2]+(SD1->D1_VALIMP1-SD1->D1_IVAFRET+SD1->D1_IVAGAST)
							 		aConIva[nPosIva][3]:=aConIva[nPosIva][3]+(SD1->D1_BASIMP1-SD1->D1_BaIVAFR+SD1->D1_BaIVAGA)
								Else
									Aadd(aConIva,{SB1->B1_CONCIVA,(SD1->D1_VALIMP1-SD1->D1_IVAFRET+SD1->D1_IVAGAST),(SD1->D1_BASIMP1-SD1->D1_BaIVAFR +SD1->D1_BaIVAGA),0,,,nPercCF})
								Endif
							ElseIf !lCalcAcm
								nPosIva:=ASCAN(aConIva,{|x| x[1]==SA2->A2_ACTRET})
								If nPosIva<>0
									aConIva[nPosIva][2]:=aConIva[nPosIva][2]+(SD1->D1_VALIMP1)
									aConIva[nPosIva][3]:=aConIva[nPosIva][3]+(SD1->D1_BASIMP1)
								Else
									Aadd(aConIva,{SA2->A2_ACTRET,SD1->D1_VALIMP1,SD1->D1_BASIMP1,0,,,nPercCF})
								Endif	
							Endif
							If SD1->D1_IVAFRET > 0
								MV_FRETLOC  := GetNewPar("MV_FRETLOC","IVA162GAN06")
								cConc   := Alltrim(Subs( MV_FRETLOC, 4,At("G",MV_FRETLOC)-4))
								nPosIva := ASCAN(aConIva,{|x| x[1]==cConc})
								If nPosIva<>0
									aConIva[nPosIva][2]:=aConIva[nPosIva][2]+ SD1->D1_IVAFRET
									aConIva[nPosIva][3]:=aConIva[nPosIva][3]+ SD1->D1_BaIVAFR
								Else
									Aadd(aConIva,{cConc,SD1->D1_IVAFRET,SD1->D1_BaIVAFR,0,,,nPercCF})
								Endif
							EndIf
							If SD1->D1_IVAGAST > 0
								MV_GASTLOC  := GetNewPar("MV_GASTLOC","IVA112GAN06")
								cConc   := Alltrim(Subs( MV_GASTLOC, 4,At("G",MV_GASTLOC)-4))
								nPosIva := ASCAN(aConIva,{|x| x[1]==cConc})
								If nPosIva<>0
									aConIva[nPosIva][2]:=aConIva[nPosIva][2]+ (SD1->D1_IVAGAST)
									aConIva[nPosIva][3]:=aConIva[nPosIva][3]+ (SD1->D1_BaIVAGA)
								Else
									Aadd(aConIva,{cConc,SD1->D1_IVAGAST,SD1->D1_BaIVAGA,0,,,nPercCF})
								Endif
							EndIf
							SD1->(DbSkip())
						EndDo
					Endif
				Endif
				
				//Verificar a porcetagem correteado do Iva conforme informada nas datas

				If SA2->(ColumnPos("A2_IVPDCOB")) > 0 .and. SA2->(ColumnPos("A2_IVPCCOB")) > 0 .and. (dDataBase >= SA2->A2_IVPDCOB .and. dDataBase <= SA2->A2_IVPCCOB)
					nPorIva := SA2->A2_PORIVA
				ElseIf SA2->(ColumnPos("A2_IVPDCOB")) > 0 .and. SA2->(ColumnPos("A2_IVPCCOB")) > 0 .and. (Empty(SA2->A2_IVPDCOB) .and. dDataBase <= SA2->A2_IVPCCOB)
					nPorIva := SA2->A2_PORIVA
				ElseIf SA2->(ColumnPos("A2_IVPDCOB")) > 0 .and. SA2->(ColumnPos("A2_IVPCCOB")) > 0 .and. (Empty(SA2->A2_IVPCCOB) .and. dDataBase >= SA2->A2_IVPDCOB)
					nPorIva := SA2->A2_PORIVA
				ElseIf !SA2->(ColumnPos("A2_IVPDCOB")) > 0 .and. !SA2->(ColumnPos("A2_IVPCCOB")) > 0 
					nPorIva := SA2->A2_PORIVA
				Else
					nPorIva := 100
				EndIf
				
				// Exenciones 
				SFH->(dbSetOrder(1))
				SFH->(dbGoTop())
				If SFH->(MsSeek(xFilial()+SA2->A2_COD+SA2->A2_LOJA+"IVR")) .and. SFH->(ColumnPos("FH_PERCENT"))>0
					If  (SFH->FH_ISENTO == "S" .OR. SFH->FH_PERCENT == 100)
						nPorIva := 0
					ElseIf A085aVigSFH() 
						If SFH->FH_ISENTO == "S"   .OR. SFH->FH_PERCENT == 100
							nPorIva := 0
						Else
							nPorIva := SFH->FH_PERCENT
						EndIf
					Endif 
				Endif 
				
				//?Gravar Retenciones.
				
				For nCount:=1  to Len(aConIva)
					aConIva[nCount][2]   := Round(xMoeda(aConIva[nCount][2],SF1->F1_MOEDA,1,,5,aTxMoedas[Max(SF1->F1_MOEDA,1)][2]),MsDecimais(1))
					aConIva[nCount][3]   := Round(xMoeda(aConIva[nCount][3],SF1->F1_MOEDA,1,,5,aTxMoedas[Max(SF1->F1_MOEDA,1)][2]),MsDecimais(1))

					AAdd(aSFEIVA,array(12))
					aSFEIVA[Len(aSFEIVA)][1] := SF1->F1_DOC         									//FE_NFISCAL
					aSFEIVA[Len(aSFEIVA)][2] := SF1->F1_SERIE       									//FE_SERIE
					If lReSaIV .and. !lCalcCbu 
						aSFEIVA[Len(aSFEIVA)][3] := IIf (Alltrim(PadR(SF1->F1_SERIE,nTamSer)) == "B" .and. SA2->A2_TIPO == "I",(aConIva[nCount][3]*nProp)*nSigno+(aConIva[nCount][2]*nProp)*nSigno,(aConIva[nCount][3])*nSigno)	//FE_VALBASE
						aSFEIVA[Len(aSFEIVA)][4] := (aConIva[nCount][2])*nSigno	//FE_VALIMP					
					Else 
						aSFEIVA[Len(aSFEIVA)][3] := IIf (Alltrim(PadR(SF1->F1_SERIE,nTamSer)) == "B" .and. SA2->A2_TIPO == "I" .and. cPaisLoc == "ARG",(aConIva[nCount][3]*nProp)*nSigno + (aConIva[nCount][2]*nProp)*nSigno, (aConIva[nCount][3]*nProp)*nSigno	)						//FE_VALBASE
						aSFEIVA[Len(aSFEIVA)][4] := (aConIva[nCount][2]*nProp)*nSigno						//FE_VALIMP
					Endif 

					aSFEIVA[Len(aSFEIVA)][5] := Iif(Alltrim(SF1->F1_SERIE)=="M", 100, nPorIva)		//FE_PORCRET
					aSFEIVA[Len(aSFEIVA)][6] := (aSFEIVA[Len(aSFEIVA)][4]) *(Iif(Alltrim(SF1->F1_SERIE)=="M", 1, Iif(lCalRep .Or. lCalcVen, 1, nPorIva/100)))
					aSFEIVA[Len(aSFEIVA)][9] := aConIva[nCount][1] 										// Gravar CFOP da operaçŽ¢o
					aSFEIVA[Len(aSFEIVA)][10]:= aConIva[nCount][4]*100 									// Gravar A PORCENTAGEM DA ALIQUOTA
					aSFEIVA[Len(aSFEIVA)][11]:= " "
					aSFEIVA[Len(aSFEIVA)][12] := IIf(lReSaIV,aSFEIVA[Len(aSFEIVA)][4],0) 
					
					If LEN(aConIva[1])==4 	//pROVISORIO, PARA QUE NO DE ERROR EN BASES DESACTUALIZADAS						
						If !lRetSerie
							lExiste:=.F.
							SFF->(DbSetOrder(5))
							SFF->(MsSeek(xFilial("SFF")+"IVR"+aConIva[nCount][1]))
							While SFF->(!EOF() ).and. (xFilial("SFF")+"IVR") ==(SFF->FF_FILIAL+SFF->FF_IMPOSTO) .And.  !lExiste
								If Alltrim(PadR(aSFEIVA[Len(aSFEIVA)][2],nTamSer)) == Alltrim(SFF->FF_SERIENF)
									lExiste:=.T.
								Else
									SFF->(DbSkip())
								EndIf
							EndDO
						EndIf
						
						If SFF->FF_IMPOSTO == "IVR"
							If !Empty(SFF->FF_CFO)
								aSFEIVA[Len(aSFEIVA)][11] := SFF->FF_CFO // Gravar CFOP da operaå ™åŸ½o de compra (para o caso de NCP)
							Else	
								If  lOPRotAut
									cTxtRotAut += OemToAnsi(STR0003) //"Rutina de cálculo de Retención de IVA desactualizada, solicite paquete con actualizaciones."
							 		lMsErroAuto := .T.
							 	Else
							 		MsgAlert(STR0003)
							 	Endif
								aSFEIVA[Len(aSFEIVA)][11]:= " "
							EndIf
						EndIf
						
						If lExiste
							If SA2->(ColumnPos("A2_IVPCCOB")) > 0

								nPercRet:=SFF->FF_ALIQ/100

								If	lCalRep .or. lCalcVen
									nPercRet:= 1
								EndIf
								If lCalcNew
									If lCalRep .or. lCalcVen
										aSFEIVA[Len(aSFEIVA)][6] := (aSFEIVA[Len(aSFEIVA)][4])
									Else

										//çŸ¯é† culo del % de Exencié«‡ del IVA									   ?
										
										///Se verifica si la fecha de generacié«‡ de la OP sea >= A2_IVPDCOB Y <= A2_IVPCCOB
										IF SA2->(ColumnPos("A2_IVPDCOB")) > 0 .AND. (ddatabase >= SA2->A2_IVPDCOB .and. ddatabase <= SA2->A2_IVPCCOB)
											// Se descuenta el porcentaje de A2_PORIVA
											aSFEIVA[Len(aSFEIVA)][6] := aSFEIVA[Len(aSFEIVA)][6]//aSFEIVA[Len(aSFEIVA)][4]- aSFEIVA[Len(aSFEIVA)][6]
										Else
											// Se realiza el cé† culo normal
											aSFEIVA[Len(aSFEIVA)][6] := aSFEIVA[Len(aSFEIVA)][4]
										End IF																			
										
									EndIf
								ElseIf cPaisLoc<>"ARG" .And. Dtos(SA2->A2_IVRVCOB) < Dtos(dDataBase)
									If  lOPRotAut
										cTxtRotAut += OemToAnsi(STR0004)+SA2->A2_COD+OemToAnsi(STR0005)
								 		lMsErroAuto := .T.
								 	Else
								 		MsgAlert(OemToAnsi(STR0004)+SA2->A2_COD+OemToAnsi(STR0005)) //	"Ha vencido el perido de observacion del proveedor  "+SA2->A2_COD+". Ingrese una fecha valida para el proveedor en el archivo de proveedores."
								 	Endif									
									//Zera o array das retencoes de IVA...
									aSFEIVA := {}
									//Sai do loop...
									Exit
								Else									
									///Se verifica si la fecha de generacié«‡ de la OP sea >= A2_IVPDCOB Y <= A2_IVPCCOB
									IF SA2->(ColumnPos("A2_IVPDCOB")) > 0 .and. (SA2-> A2_IVPDCOB <= ddatabase .and. SA2->A2_IVPCCOB >= ddatabase)
										// Se descuenta el porcentaje de A2_PORIVA
										aSFEIVA[Len(aSFEIVA)][6] := aSFEIVA[Len(aSFEIVA)][6]
									Else
										// Se realiza el cé† culo normal
										aSFEIVA[Len(aSFEIVA)][6] := aSFEIVA[Len(aSFEIVA)][4]
									End IF
								EndIf
							Else
								nPercRet:=SFF->FF_ALIQ/100

								If  lCalRep .or. lCalcVen
									nPercRet:= 1
								EndIf
								If lCalcNew
									If lCalRep .or. lCalcVen
										aSFEIVA[Len(aSFEIVA)][6] := (aSFEIVA[Len(aSFEIVA)][4])
									Else
										aSFEIVA[Len(aSFEIVA)][6] := (aSFEIVA[Len(aSFEIVA)][4]) *(SA2->A2_PORIVA/100)
									EndIf

								Else
									aSFEIVA[Len(aSFEIVA)][6] := (aSFEIVA[Len(aSFEIVA)][4]*(nPercRet))*(Iif(Alltrim(PadR(SF1->F1_SERIE,nTamSer))=="M" .or. (Alltrim(PadR(SF1->F1_SERIE,nTamSer))=="A" .and. cPaisLoc == "ARG"),100,SA2->A2_PORIVA)/100)
								EndIf
							EndIf

							nTotRet += aSFEIVA[Len(aSFEIVA)][6]
						ELSE
							DEFINE MSDIALOG oDlg4 FROM 65,0 To 218,366 Title OemToAnsi(STR0006) Pixel //"Inconsistencia"
							@ 2,3 To 51,180 Pixel of oDlg4
							//"La actividad ", " de IVA no esta registrada en la Tabla SFF"
							//"por lo tanto no se generara retenciî•” de IVA. Si desea Continuar con la "
							//"Orden de Pago acepte, sino cancele. "
							@ 10,004 SAY OemToAnsi(STR0007)+ Alltrim(aConIva[nCount][1]) +OemToAnsi(STR0008) PIXEL Of oDlg4
							@ 23,004 SAY OemToAnsi(STR0009)	PIXEL Of oDlg4
							@ 36,004 SAY OemToAnsi(STR0010) 	PIXEL	Of oDlg4
							DEFINE SBUTTON FROM 57,064  Type 1 Action (lRetOk	:=	.T.,oDlg4:End())    Pixel ENABLE Of oDlg4
							DEFINE SBUTTON FROM 57,104  Type 2 Action (lRetOk	:=	.F.,oDlg4:End())  Pixel ENABLE Of oDlg4
							Activate Dialog oDlg4 CENTERED
							aSFEIVA[Len(aSFEIVA)][6] := 0
						Endif
					Else
						lExiste := .F.
						aAreaSFF := SFF->(GetArea())

						SFF->(DbSetOrder(5))
						If SFF->(MsSeek(xFilial("SFF")+"IVR"))
							lAchou:=.F.
							While SFF->(!EOF() ).and. (xFilial("SFF")+"IVR") ==(SFF->FF_FILIAL+SFF->FF_IMPOSTO) .And.  !lAchou
								If (Alltrim(SFF->FF_SERIENF)==SubStr(Alltrim(PadR(SF1->F1_SERIE,nTamSer)),1,1)  .And.  aConIva[nCount][1]==  SFF->FF_CFO_C)
									lAchou:=.T.
								Else
									SFF->(DbSkip())
								EndIf
							EndDO
						EndIf

						If SFF->FF_IMPOSTO == "IVR"
							If !Empty(SFF->FF_CFO)
								aSFEIVA[Len(aSFEIVA)][11] := SFF->FF_CFO // Gravar CFOP da operaå ™åŸ½o de compra (para o caso de NCP)
							Else
								If  lOPRotAut
									cTxtRotAut += OemToAnsi(STR0003) 
								 	lMsErroAuto := .T.
								Else
									MsgAlert(STR0003)
								Endif
								aSFEIVA[Len(aSFEIVA)][11]:= " " 
							EndIf
						EndIf

						RestArea(aAreaSFF)
						nTotRet += aSFEIVA[Len(aSFEIVA)][6]
					Endif	
									
					//?Generar Titulo de Impuesto no Contas a Pagar. 					
					If  lCalcNew
						aSFEIVA[Len(aSFEIVA)][7] := nSaldo
					Else
						aSFEIVA[Len(aSFEIVA)][7] := SE2->E2_VALOR
					EndIf
					aSFEIVA[Len(aSFEIVA)][8] := SE2->E2_EMISSAO

					If lReSaIV .and. ((nSaldo < SE2->E2_VALOR) .or. (naPagar > 0 .or. nVRetIVA > 0))     
				
						aSFEIVA[Len(aSFEIVA)][3] := aSFEIVA[Len(aSFEIVA)][3] * Round((Int((100 * nSaldo) / SE2->E2_VALOR) / 100),1)
						aSFEIVA[Len(aSFEIVA)][4] := aSFEIVA[Len(aSFEIVA)][4] * Round((Int((100 * nSaldo) / SE2->E2_VALOR) / 100),1)
						aSFEIVA[Len(aSFEIVA)][5] := Int((100 * nSaldo) / SE2->E2_VALOR)
						aSFEIVA[Len(aSFEIVA)][6] := aSFEIVA[Len(aSFEIVA)][4]
						
						nSRIva	+= Round(aSFEIVA[Len(aSFEIVA)][3],MsDecimais(1))	//FE_VALBASE
						nSVIva	+= Round(aSFEIVA[Len(aSFEIVA)][6],MsDecimais(1))	//FE_VALBASE

					Endif 
					
				Next
					If lShowPOrd .and. TableInDic("FVC") .and. Funname() == "FINA855"
						DBSELECTAREA("FVC")
						FVC->(DBSETORDER(3)) //FVC_FILIAL+FVC_FORNEC+FVC_LOJA+FVC_NFISC+FVC_SERIE+FVC_TIPO+FVC_CONCEP
						If FVC->(MsSeek(xFilial("FVC")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC))
							While FVC->(!Eof()) .and. FVC->(FVC_FORNEC+FVC_LOJA+FVC_NFISC) == SF1->(F1_FORNECE+F1_LOJA+F1_DOC)
								If  Iif(Inclui,.T.,FJK->FJK_PREOP != FVC->FVC_PREOP)
									If AllTrim(FVC->FVC_TIPO) == "I" .and. FVC->FVC_RETENC > 0 .and. FVC->FVC_SERIE == SF1->F1_SERIE
										nTotRetSFE += FVC->FVC_RETENC
										AADD(aRetPreO,FVC->(FVC_FORNEC+FVC_LOJA+FVC_NFISC+FVC->FVC_SERIE+FVC_PARCEL))
									EndIf
								Endif
								FVC->(dbSkip())
							Enddo
						EndIf	
					EndIf
					SFE->(dbSetOrder(4))
					If SFE->(MsSeek(xFilial("SFE")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE+"I"))
						cChaveSFE := xFilial("SFE")+SFE->FE_FORNECE+SFE->FE_LOJA+SFE->FE_NFISCAL+SFE->FE_SERIE 
						While !SFE->(Eof()) .And. cChaveSFE == SFE->FE_FILIAL+SFE->FE_FORNECE+SFE->FE_LOJA+SFE->FE_NFISCAL+SFE->FE_SERIE 
							If SFE->FE_TIPO =="I" .and. SFE->FE_RETENC > 0 .and. EMPTY(SFE->FE_DTESTOR)
								If lShowPOrd .and. TableInDic("FVC") .and. Funname() == "FINA855"
									If Ascan(aRetPreO,{|x| x == SFE->(SFE->FE_FORNECE+SFE->FE_LOJA+SFE->FE_NFISCAL+SFE->FE_SERIE+SFE->FE_PARCELA) }) == 0
										nTotRetSFE += SFE->FE_RETENC
									EndIf
								Else
									nTotRetSFE += SFE->FE_RETENC
								EndIf
							EndIf
							SFE->(dbSkip())
						End
					EndIf
					If nTotRetSFE > 0
						//Proporcionaliza o que ja foi retido e abate da retencao que
						//foi calculada.
						IF !(nSaldo < SE2->E2_VALOR) .or. !lReSaIV .Or. (nSaldo < SE2->E2_VALOR .And. !Empty(cAcmIVA) .And. cAcmIVA == "2" .And. lCalcAcm .And. Subs(cAgente,2,1) == "N" .And. SA2->A2_AGENRET == "N")   
							IF !(nSaldo == SE2->E2_VALOR)
								For nCount:= 1 To Len(aSFEIVA)
									If !(aSFEIVA[nCount][6] == (nTotRetSFE * (aSFEIVA[nCount][6] / nTotRet)) .and. Funname() <> "FINA850") 
										aSFEIVA[nCount][6] -= (nTotRetSFE * (aSFEIVA[nCount][6] / nTotRet))
									ElseIf (aSFEIVA[nCount][6] == (nTotRetSFE * (aSFEIVA[nCount][6] / nTotRet)) .and. Funname() <> "FINA850") 
										aSFEIVA[nCount][6] -= nTotRetSFE
									EndIf
								Next nCount   
							ElseIf (nSaldo == SE2->E2_VALOR) 
									For nCount:= 1 To Len(aSFEIVA)
										If		aSFEIVA[nCount][6] == nTotRetSFE
												aSFEIVA[nCount][6] := 0
										ElseIf !(aSFEIVA[nCount][6] == (nTotRetSFE * (aSFEIVA[nCount][6] / nTotRet)) .and. Funname() <> "FINA850") 
												aSFEIVA[nCount][6] -= (nTotRetSFE * (aSFEIVA[nCount][6] / nTotRet))
										ElseIf (aSFEIVA[nCount][6] == (nTotRetSFE * (aSFEIVA[nCount][6] / nTotRet)) .and. Funname() <> "FINA850") 
												aSFEIVA[nCount][6] -= nTotRetSFE
										EndIf
									Next nCount
							Endif
						ElseIf (nSaldo == SE2->E2_VALOR) .Or. lReSaIV
							For nCount:= 1 To Len(aSFEIVA)
								If !(aSFEIVA[nCount][6] == (nTotRetSFE * (aSFEIVA[nCount][6] / nTotRet)) .and. Funname() <> "FINA850") 
									aSFEIVA[nCount][6] -= (nTotRetSFE * (aSFEIVA[nCount][6] / nTotRet))
								ElseIf (aSFEIVA[nCount][6] == (nTotRetSFE * (aSFEIVA[nCount][6] / nTotRet)) .and. Funname() <> "FINA850") 
									aSFEIVA[nCount][6] -= nTotRetSFE
								EndIf
							Next nCount 
						Endif			
					EndIf
					//Verifica se o valor de retencao calculado supera o valor
					//minimo a ser retido, caso seja inferior nao eh realizada
					//a retencao.
					If !lCalcAcm
						If Alltrim(PadR(SF1->F1_SERIE,nTamSer)) == "M" .and. cPaisLoc <> "ARG"
							nTotBase := 0
							nTotRet := 0
							aEval(aSFEIVA,{|x| nTotRet += (x[4] * x[5]/100), nTotBase +=x[3]})
								If  (nTotBase < SFF->FF_IMPORTE) .Or. (nTotRet < SFF->FF_VALMIN)
									aEval(aSFEIVA,{|x| x[6] := 0})
								EndIf
						Else
							nTotRet := 0
							aEval(aSFEIVA,{|x| nTotRet += x[6]})
								If  nTotRet <= nImporte
									aEval(aSFEIVA,{|x| x[6] := 0})
								EndIf
						EndIf
					EndIf				
			EndIf
		Elseif lRetPa

			SFF->(DbSetOrder(5))
			SFF->(MsSeek(xFilial("SFF")+"IVR"+cCF)) //cConceito pegar do TES (CFO)
			If SFF->(FOUND())
				While !SFF->(Eof()) .And. xFilial("SFF")+"IVR"+cCF == SFF->(FF_FILIAL+FF_IMPOSTO+FF_CFO_C)
					If !Empty(cSerieNF) .And. PadR(cSerieNF,Len(SFF->FF_SERIENF)) != SFF->FF_SERIENF
						SFF->(dbSkip())
						Loop
					EndIf
					nPercRet:=SFF->FF_ALIQ/100					
					AAdd(aSFEIVA,array(12))
					aSFEIVA[Len(aSFEIVA)][1] := ""         		//FE_NFISCAL
					aSFEIVA[Len(aSFEIVA)][2] := ""       		//FE_SERIE
					aSFEIVA[Len(aSFEIVA)][3] := Round(xMoeda((nSaldo * nSigno),nMoedaCor,1,,5,aTxMoedas[Max(nMoedaCor,1)][2]),MsDecimais(1))	//FE_VALBASE
					aSFEIVA[Len(aSFEIVA)][4] := 0	//FE_VALIMP
					aSFEIVA[Len(aSFEIVA)][5] := SA2->A2_PORIVA   		//FE_PORCRET
					aSFEIVA[Len(aSFEIVA)][6] := (aSFEIVA[Len(aSFEIVA)][3]) *(Iif(lCalRep .or. lCalcVen ,1, SA2->A2_PORIVA/100))
					aSFEIVA[Len(aSFEIVA)][9] := cCF // Gravar CFOP da operaçŽ¢o
					aSFEIVA[Len(aSFEIVA)][10]:= nPercRet
					aSFEIVA[Len(aSFEIVA)][11]:= SFF->FF_CFO // Gravar CFOP da operaå ™åŸ½o de compra (para o caso de NCP)
					aSFEIVA[Len(aSFEIVA)][12] := 0 
					
			   		If SA2->A2_PORIVA < 100.00 .And. (Empty(SA2->A2_IVPCCOB) .Or. Dtos(SA2->A2_IVPCCOB) < Dtos(dDataBase))
						If SA2->A2_PORIVA < 100.00 .And. (Empty(SA2->A2_IVPCCOB) .Or. Dtos(SA2->A2_IVPCCOB) < Dtos(dDataBase))
							nPercRet:=SFF->FF_ALIQ/100							
						EndIf
	
						If	lCalRep .or. lCalcVen
							nPercRet:= 1
						EndIf
	
						If lCalRep .or. lCalcVen
							nRetIva:=(aSFEIVA[Len(aSFEIVA)][3])*nPercRet
						Else
							nRetIva:= ((aSFEIVA[Len(aSFEIVA)][3]) *(SA2->A2_PORIVA/100))*nPercRet
						EndIf	
					Else
						nPercRet:=SFF->FF_ALIQ/100
	
						If  lCalRep .or. lCalcVen
							nPercRet:= 1
						EndIf
						If lCalRep .or. lCalcVen
							nRetIva:= (aSFEIVA[Len(aSFEIVA)][3])*nPercRet
						Else
							nRetIva:= ((aSFEIVA[Len(aSFEIVA)][3]) *(SA2->A2_PORIVA/100))*nPercRet
						EndIf
					EndIf
	
					aArea:=GetArea()
					DbSelectArea("SFE")
					SFE->(dbSetOrder(4))
					If SFE->(MsSeek(xFilial("SFE")+cFornece+cLoja))
						cChaveSFE := xFilial("SFE")+SFE->FE_FORNECE+SFE->FE_LOJA
						While !SFE->(Eof()) .And. cChaveSFE == SFE->FE_FILIAL+SFE->FE_FORNECE+SFE->FE_LOJA
							If SFE->FE_TIPO =="I" .And. !Empty(cNumOp) .And. SFE->FE_NUMOPER == cNumOp
								nRetTotal += SFE->FE_RETENC
							EndIf
							SFE->(dbSkip())
						End
					EndIf
	
					RestArea(aArea)
	
					aSFEIVA[Len(aSFEIVA)][6]:=Iif(nRetTotal>0,((nRetTotal-nRetIva)*-1),nRetIva)
	
					//Verifica se o valor a ser retido ?maior que o valor do PA
					If nValor < aSFEIVA[Len(aSFEIVA)][6]
						aSFEIVA[Len(aSFEIVA)][6]:= nValor
					EndIF
	
	
					//Verifica se o valor de retencao calculado supera o valor
					//minimo a ser retido, caso seja inferior nao eh realizada
					//a retencao.
					nTotRet := 0
					aEval(aSFEIVA,{|x| nTotRet += x[6]})

					If  nTotRet < SFF->FF_IMPORTE
						aEval(aSFEIVA,{|x| x[6] := 0})
					EndIf
						
					If !Empty(cSerieNF)
						SFF->(dbSkip())
					Else
						Exit
					EndIf
				EndDo
			EndIf
		EndIF

	EndIf
EndIf

If lReSaIV .and. (naPagar > 0 .or. nVRetIVA > 0) .and. (nSaldo < SE2->E2_VALOR) .and. nSaldo == SE2->E2_SALDO 

	aAreaSFE := GetArea()
	DbSelectArea("SFE")
	SFE->(dbSetOrder(4))

	If SFE->(MsSeek(xFilial("SFE") + SE2->E2_FORNECE + SE2->E2_LOJA + SF1->F1_doc + SF1->F1_SERIE + "I"))
		aSalRet := FilImpRet(xFilial("SFE"),SE2->E2_FORNECE,SE2->E2_LOJA,SF1->F1_doc,SF1->F1_SERIE,"I") // SALDO RETENIDO
	Endif 
	RestArea(aAreaSFE)
						
	IF Len(aSalRet)> 0 .and. ((nVRetIVA - (aSalRet[1] + nSVIva)) <> 0)
		For nX:=1  to Len(aSFEIVA)
			aSFEIVA[nX][4] := aSFEIVA[nX][4] - ((aSalRet[1] + nSVIva) - nVRetIVA ) / LEN(aSFEIVA) 
			aSFEIVA[nX][6] := aSFEIVA[nX][6] - ((aSalRet[1] + nSVIva) - nVRetIVA ) / LEN(aSFEIVA) 
		Next
	ElseIf Len(aSalRet)> 0 .and. nVRetIVA == aSalRet[1]
		For nX:=1  to Len(aSFEIVA)						  
			aSFEIVA[nX][4] := 0 
			aSFEIVA[nX][6] := 0
		Next 
	Endif
Endif

RestArea(aArea)
Return aSFEIVA


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RetIVACre ºAutor  ³                    º Data ³  03/08/2020 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ RetIVACre   - Calculo de Ret de IVA para NCP               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ARGRetIV2 (FINRETARG)                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ 1. cAgente: Agente de retención (N = No/ S = Si).          º±±
±±           ³ 2. nSigno: 1 / (-1)Si SE2->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG º±±
±±           ³ 3. nSaldo: Saldo (valor baser o valor a bajar).            º±±
±±           ³ 4. nProp: Proporcionalización para IVA.                    º±±
±±           ³ 5. nA                                                      º±±
±±           ³ 6. cChavePOP: FJK_PREOP+Proveedor+Loja, usada en ObtReten()º±±
±±           ³ 7. cNFPOP:Num de documento(E2_NUM), usado en ObtReten()    º±±
±±           ³ 8. cSeriePOP: Serie(E2_PREFIXO), usada en ObtReten()       º±±
±±           ³ 9. dEmissao: Fch emisión CXP(E2_EMISSAO), usada ObtReten() º±±
±±           ³ 10.lOPRotAut: Es rutina automatica (.T.)                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */
Function RetIVACre(cAgente,nSigno,nSaldo,nProp,nA,cChavePOP,cNFPOP,cSeriePOP,dEmissao,lOPRotAut)
Local oDlg4
Local aConIva	:= {}
Local aSFEIVA	:= {}
Local aDadosIVA	:= {}
Local aDocAcm 	:= {}
Local aConfIVA 	:= {}
Local aFIva		:= FilImpto({"3"},{"I"},{},{}) // Retorna todos los impuestos con IVA de SFB 
Local lAcmIVA	:= .F.
Local lCalRet	:= .F.
Local lCalcImp	:= .T.
Local lCalRep	:= .F.
Local lCalcVen	:= .F.
Local lCalrtexp	:= .F.
Local lRetIva  	:= .F.
Local lCalcAcm 	:= .F.
Local lRetSit	:= .T.
Local lCalcNew	:= GetNewPar("MV_GRETIVA","N") == "S"
Local cChaveSFE	:= ""
Local cAcmIVA	:= ""
Local nPorIva	:= 0
Local nPosIva	:= 0
Local nCount	:= 0
Local nTotRet	:= 0
Local nTotRetSFE:= 0
Local nI	 	:= 1
Local nX 		:= 0
Local nValorBr	:= 0
Local nPerc	:= 0
Local nValor	:= 0  
Local nRecSF2	:= 0 
Local nTamSer := SerieNfId('SF2',6,'F2_SERIE')
Local lTESNoExen := .F.
Local nValBas := 0
Local nRedAliq	:= 0
Local lCalcCbu:=.F.
Local nPercCF   := 0
Local nPosTES	:= 0
Local aTesNf 	:= {}
Local aTesFin   := {}

If type("cFornece")=="U"
	 cFornece	:=SE2->E2_FORNECE
	 cLoja		:=SE2->E2_LOJA
EndIf

DEFAULT nSigno	:= -1
DEFAULT nProp 	:= 1
DEFAULT cChavePOP:= ""
DEFAULT cNFPOP	 := ""
DEFAULT cSeriePOP:= ""
DEFAULT dEmissao := CTOD("//")
DEFAULT lOPRotAut:= .F. 

If lShowPOrd .and. Funname() == "FINA847" .and. Type("lCtaCte")<>"U" .and. lCtaCte
	Return aSFEIVA := ObtReten(cChavePOP,cNFPOP,cSeriePOP,"I",nSaldo,dEmissao)
EndIf

//+---------------------------------------------------------------------+
//?Obter Impostos somente qdo a Empresa Usuario for Agente de RetençŽŸo.?
//+---------------------------------------------------------------------+


dbSelectArea("SF2")
dbSetOrder(1)
If lMsfil
	nRecSF2 := FINBuscaNF(SE2->E2_MSFIL,SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_FORNECE,SE2->E2_LOJA,"SF2",.T.)
	SF2->(dbGoTo(nRecSF2))
Else
	nRecSF2 := FINBuscaNF(xFilial("SF2", SE2->E2_FILORIG),SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_FORNECE,SE2->E2_LOJA,"SF2",.T.)
	SF2->(dbGoTo(nRecSF2))
EndIf

If cPaisLoc == "ARG" .and. Alltrim(SE2->E2_TIPO) == "PA"
	Return aSFEIVA
Endif 

lCalRet := Iif(SubStr(Alltrim(PadR(SF2->F2_SERIE,nTamSer)),1,1) == "M" .or. (Alltrim(PadR(SF2->F2_SERIE,nTamSer))=="A" .and. cPaisLoc == "ARG"),.T.,.F.)
lCalcAcm := Subs(cAgente,2,1) == "N"
If(SF2->(ColumnPos("F2_TPNFEXP"))>0 .And. SFF->(ColumnPos("FF_VLRLEX"))>0 .And. SFF->(ColumnPos("FF_ALIQLEX"))>0 .And.  SF2->F2_TPNFEXP=="1")  //1 - Exportador 2- Normal
	lCalrtexp:=.T.
EndIf
If ExistBlock("F0851IMP")
	lCalcImp:=ExecBlock("F0851IMP",.F.,.F.,{"IV2"})
EndIf
// Tratamento do Reproweb - SituaçŽ¢o igual a 0 né‰¶ deve reter Resolucié«‡ General ( AFIP) 2226/07

If type("inclui")=="U"
	 inclui:=NIL
EndIf

SA2->( dbSetOrder(1) )
If lMsFil .And. !Empty(xFilial("SA2")) .And. xFilial("SF1") == xFilial("SE2")
	SA2->(MsSeek(SE2->E2_MSFIL+SE2->E2_FORNECE+SE2->E2_LOJA) )
Else
	SA2->( MsSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA) )
Endif
If ((SA2->(ColumnPos("A2_CBUINI"))>0 .and. SA2->(ColumnPos("A2_CBUFIM"))>0) .and. SA2->A2_CBUINI <= SE2->E2_EMISSAO .and. SA2->A2_CBUFIM >= SE2->E2_EMISSAO .and.  Subs(SF2->F2_SERIE,1,1) =="A").or. Subs(SF2->F2_SERIE,1,1) =="M"
	lCalcCbu:=.T.
EndIf
If (Subs(cAgente,2,1) == "S" .Or. lCalRet .Or. lCalcAcm .or.lCalcCbu )  .And.  lCalcImp  .And.  lRetSit
	SA2->( dbSetOrder(1) )
	If lMsFil .And. !Empty(xFilial("SA2")) .And. xFilial("SF1") == xFilial("SE2")
		SA2->( MsSeek(SE2->E2_MSFIL+SE2->E2_FORNECE+SE2->E2_LOJA) )
	Else
		SA2->( MsSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA) )
	Endif
	
	If  Subs(cAgente,2,1) == "S"       
		If  SA2->A2_AGENRET == "S" .And. SubStr(Alltrim(PadR(SF2->F2_SERIE,nTamSer)),1,1) <> "M"//Si el proveedor es Agente de Ret. al igual que al emp, no se debe retener   //Return aSFEIVA
			Return aSFEIVA
		Endif
	Endif
	
	If SA2->A2_AGENRET == "N" .Or. lCalRet

		lCalRep := Iif(SA2->(ColumnPos("A2_SITU")>0) .and. Alltrim(SA2->A2_SITU)$("2/4"),.T.,.F.)

		While Alltrim(SF2->F2_ESPECIE)<>AllTrim(SE2->E2_TIPO).And.!EOF()
			SF2->(DbSkip())
			Loop
		Enddo

		If AllTrim(SF2->F2_ESPECIE)==Alltrim(SE2->E2_TIPO).And.;
			Iif(lMsFil,SF2->F2_MSFIL,xFilial("SF2", SE2->E2_FILORIG))+SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE+SE2->E2_LOJA==;
			F2_FILIAL+F2_DOC+PadR(F2_SERIE,nTamSer)+F2_CLIENTE+F2_LOJA
			
			//?Obter o Valor do Imposto e Base baseando se no rateio do valor ?
			//?do titulo pelo total da Nota Fiscal.                           ?
			
			SD2->(DbSetOrder(3))
			If lMsFil
				SD2->(MsSeek(SF2->F2_MSFIL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
			Else
				SD2->(MsSeek(xFilial("SD2", SE2->E2_FILORIG)+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
			EndIf
			If SD2->(Found())
				Do while Iif(lMsFil,SD2->D2_MSFIL,xFilial("SD2", SE2->E2_FILORIG))==SD2->D2_FILIAL.And.SF2->F2_DOC==SD2->D2_DOC.AND.;
					SF2->F2_SERIE==SD2->D2_SERIE.AND.SF2->F2_CLIENTE==SD2->D2_CLIENTE;
					.AND.SF2->F2_LOJA==SD2->D2_LOJA.AND.!SD2->(EOF())

					If AllTrim(SD2->D2_ESPECIE)<>AllTrim(SF2->F2_ESPECIE)
						SD2->(DbSkip())
						Loop
					Endif
					
					If Len(aTesNf) > 0
						nPosTES := aScan(aTesNf,{|x| x[1] == SD2->D2_TES})
					EndIf
					If nPosTES == 0
						aImpInf := TesImpInf(SD2->D2_TES)
						aAdd(aTesNf, {SD2->D2_TES, aImpInf})
					Else
						aImpInf := aClone(aTesNf[nPosTES][2])
					EndIf

					lTESNoExen := aScan(aImpInf,{|x| "IV" $ AllTrim(x[1])}) <> 0
					If !lTESNoExen
						SD2->(DbSkip())
						Loop
					EndIf
					
					//Variable aTES se utiliza en las funciones ValImpto y ValBasImp
					If Len(aTesFin) > 0
						nPosTES := aScan(aTesFin,{|x| x[1] == SD2->D2_TES})
					EndIf
					If nPosTES == 0
						aTes := TesImpFin(SD2->D2_TES)
						aAdd(aTesFin, {SD2->D2_TES, aTes})
					Else
						aTes := AClone(aTesFin[nPosTES][2])
					EndIf

					nPercCF := 0
					SB1->(DbSetOrder(1))
					If !Empty(SD2->D2_CF)
						nRateio := 1
						If  lCalcCbu 	
							For nI := 1 To Len(aImpInf)
								If  "IV"$Trim(aImpInf[nI][01]) .And. aImpInf[nI][14] == "N";
										.And. aImpInf[nI][15] == "I" .And. aImpInf[nI][16] == "3"			
									nPercCF := SD2->(FieldGet(ColumnPos(aImpInf[nI][10])))
								EndIf
							Next
							If  Len(aConIva)>0
								nPosIva:=ASCAN(aConIva,{|x| x[7]==nPercCF})
							Endif
						Else
							nPosIva:=ASCAN(aConIva,{|x| x[1]==SD2->D2_CF})
						Endif
						If lCalcNew    // Calcula IVA metodo Novo
							If nPosIva<>0
								If Len(aConIVA[nPosIVA]) >= 6  .And. Valtype(aConIVA[nPosIVA]) == "C"  
									cAcmIVA := aConIva[nPosIva][6]
								EndIF 
								If ( (SB1->(ColumnPos("B1_RG2849"))>0 .AND. SB1->B1_RG2849 <> 0) .Or. cAcmIVA == "2" )
									nValor := SD2->D2_TOTAL-SD2->D2_DESCON 
									If SD2->(ColumnPos("D2_IVAFRET"))>0  .And.  SD2->(ColumnPos("D2_IVAGAST"))>0  .And. SD2->(ColumnPos("D2_BAIVAGA"))>0   .And.  SD2->(ColumnPos("D2_BAIVAFR"))>0
										aConIva[nPosIva][2]+= ((aConIva[nPosIva][4] * nValor )- ((SD2->D2_IVAFRET+SD2->D2_IVAGAST))) * nRateio
										aConIva[nPosIva][3]+= ( nValor - ((SD2->D2_BaIVAFR+SD2->D2_BaIVAGA)) )  * nRateio
									Else
										aConIva[nPosIva][2]+= (aConIva[nPosIva][4] * nValor )  * nRateio
										aConIva[nPosIva][3]+= nValor  * nRateio
									EndIf
								Else
									nValor :=  ValImpto(aFIva,SD2->D2_TES, aTes)	
									If  lCalcCbu .Or. lCalRep
										nValBas:=  ValBasImp(aFIva,SD2->D2_TES, aTes)
									Endif	
									//ColumnPos adicionado pois não foi encontrado a origem da criação deste campo – NÃO RETIRAR
									If SD2->(ColumnPos("D2_IVAFRET"))>0  .And.  SD2->(ColumnPos("D2_IVAGAST"))>0  .And. SD2->(ColumnPos("D2_BAIVAGA"))>0   .And.  SD2->(ColumnPos("D2_BAIVAFR"))>0
										aConIva[nPosIva][2]+= ((aConIva[nPosIva][4] * Iif(lCalcCbu .Or. lCalRep,nValBas,nValor) )- ((SD2->D2_IVAFRET+SD2->D2_IVAGAST))) * nRateio
										aConIva[nPosIva][3]+= ( Iif(lCalcCbu .Or. lCalRep,nValBas,nValor) - ((SD2->D2_BaIVAFR+SD2->D2_BaIVAGA)) )  * nRateio
									Else
										aConIva[nPosIva][2]+= (aConIva[nPosIva][4] * Iif(lCalcCbu .Or. lCalRep,nValBas,nValor) )  * nRateio
										aConIva[nPosIva][3]+= (Iif(lCalcCbu .Or. lCalRep,nValBas,nValor)  * nRateio)
									EndIf
								EndIf
							
							Else
								cAcmIVA := ""
								If  lCalRep .Or. lCalcVen
									For nI := 1 To Len(aImpInf)
										If  "IV"$Trim(aImpInf[nI][01]) .And. aImpInf[nI][14] == "N";
											.And. aImpInf[nI][15] == "I" .And. aImpInf[nI][16] == "3"
											Aadd(aConIva,{SD2->D2_CF,SD2->(FieldGet(ColumnPos(aImpInf[nI][02]))),SD2->(FieldGet(ColumnPos(aImpInf[nI][07]))), (SD2->(FieldGet(ColumnPos(aImpInf[nI][10]))) /100),,,nPercCF})
										EndIf
									Next
								Else
									SFF->(DbSetOrder(5))
									If SFF->(MsSeek(xFilial("SFF")+"IVR"))
										nPerc:=0
										lAchou:=.F.
										While SFF->(!EOF() ).and. (xFilial("SFF")+"IVR") ==(SFF->FF_FILIAL+SFF->FF_IMPOSTO) .And.  !lAchou
											If (Alltrim(SFF->FF_SERIENF)==SubStr(Alltrim(PadR(SD2->D2_SERIE,nTamSer)),1,1)  .And.  SD2->D2_CF==  SFF->FF_CFO_V)
												lExistSFF:=.T.
												If GetNewPar("MV_SEGMEN","") $ "1|2|4"
													If SA2->(ColumnPos("A2_TIPROVM"))>0 .AND. ((SA2->A2_TIPROVM $ "0|1|2|3" .AND. SFF->FF_REGIST=="1" ) .OR. ( SA2->A2_TIPROVM $ "4" .AND. SFF->FF_REGIST=="2" ))
														lExistSFF:=.T.
													Else
														lExistSFF:=.F.
													EndIf
												Endif
												
												
												If lExistSFF
													lAchou:=.T.
													nPerc:=SFF->FF_ALIQ
													cCFOIVA	:= SFF->FF_CFO_C
													cCFOVIVA := SFF->FF_CFO_V
													nRedAliq:= SFF->FF_REDALIQ 
													If SFF->(ColumnPos("FF_TPLIM")) > 0
														cAcmIVA := SFF->FF_TPLIM
														nLimite := SFF->FF_LIMITE
													EndIf													
												EndIf
											EndIf
											SFF->(DbSkip())
										EndDo
										
										If cAcmIva != "2" .And. Subs(cAgente,2,1) == "N" .And. SA2->A2_AGENRET == "N" .And. SubStr(Alltrim(PadR(SF1->F1_SERIE,nTamSer)),1,1) <> "M" .And. !lCalcCbu
											Return aSFEIVA
										EndIf
										
										/*************************************************
										//Verifica o acumulado para o cé† culo do imposto
										//************************************************/

										//caso seja branco ou né‰¶ foi selecionado nenhum mé– odo de acumulo
										If Type("aRetIvAcm") <> "A"
											aRetIvAcm := Array(3)
										EndIf
										If !Empty(cAcmIVA) .And. cAcmIVA <> "0" .And. lCalcAcm
											aDadosIVA 	:= F850AcmIVA(cAcmIVA,SF2->F2_EMISSAO,SF2->F2_CLIENTE,SF2->F2_LOJA,,cCFOIVA,cCFOVIVA)
											If aDadosIVA[4]
												nBase := aDadosIVA[1]

												If nBase >= nLimite
													lRetIva := .T.
													lAcmIVA := .T.

													For nX := 1 to Len(aDadosIVA[3])
														aAdd(aDocAcm, {aDadosIVA[3][nX][3], aDadosIVA[3][nX][4], Iif(aDadosIVA[3][nX][1],.F.,.T.),aDadosIVA[3][nX][6],aDadosIVA[3][nX][5],aDadosIVA[3][nX][7]})
													
														//Proporção do valor dos títulos parcelados
														If aDadosIVA[3][nX][5] = SE2->(Recno())
															nRateio := aDadosIVA[3][nX][6]/100	
														EndIf
													
													Next nX

													If Len(aDocAcm) > 0
														aAdd(aConfIVA,nPerc)

														aRetIvAcm[1] :=  aConfIVA

														If aRetIvAcm[2] == Nil
															aRetIvAcm[2] := {}
														EndIf

														For nX := 1 to Len(aDocAcm)
															If aDocAcm[nX][2] == "SF1"
																nPosDoc := aScan(aRetIvAcm[2],{|x| x[1]==aDocAcm[nX][1] .And. x[2]=="SF1"})
															Else
																nPosDoc := aScan(aRetIvAcm[2],{|x| x[1]==aDocAcm[nX][1] .And. x[2]=="SF2"})
															EndIf
															If nPosDoc == 0
																If aDocAcm[nX][6]
																	Aadd(aRetIvAcm[2],aDocAcm[nX])
																Endif
															EndIf
														Next nX

													EndIf

												EndIf
											Else
												lRetIva := .T.
											EndIf

										Else
											//Se né‰¶ usa cumulatividade de IVA, calcula no mé– odo antigo
											lRetIva := .T.
										EndIf
										If  lCalrtexp  .And. lAchou
											If Alltrim(PadR(SD2->D2_SERIE,nTamSer)) == "B" .and. SA2->A2_TIPO == "I" .and. cPaisLoc == "ARG"
												nPerc := POSICIONE("SFB",1,xFilial("SFC")  + POSICIONE("SFC", 2, xFilial("SFC") + SD2->D2_TES + "IV", "FC_IMPOSTO" ),"FB_ALIQ")
												nValorBr:=Round(xmoeda(SF2->F2_VALBRUT,SF2->F2_MOEDA,1,,5,aTxMoedas[Max(SF2->F2_MOEDA,1)][2]),MsDecimais(1)) / (1+ (nPerc/100))
											Else
												nValorBr:=Round(xmoeda(SF2->F2_VALBRUT,SF2->F2_MOEDA,1,,5,aTxMoedas[Max(SF2->F2_MOEDA,1)][2]),MsDecimais(1))
												nPerc:=Iif(nValorBr>SFF->FF_VLRLEX,SFF->FF_ALIQ,SFF->FF_ALIQLEX)
											EndIf
										EndIf

										If lRetIva
											nValor :=  ValImpto(aFIva,SD2->D2_TES, aTes)
											nValBas :=  ValBasImp(aFIva,SD2->D2_TES, aTes)
											If cPaisLoc == "ARG" .And. ( (SB1->(ColumnPos("B1_RG2849"))>0 .AND. SB1->B1_RG2849 <> 0 ) .Or. cAcmIVA == "2")
												nValor := SD2->D2_TOTAL-SD2->D2_DESCON 
											EndIf
											If SD2->(ColumnPos("D2_IVAFRET"))>0  .And.  SD2->(ColumnPos("D2_IVAGAST"))>0  .And. SD2->(ColumnPos("D2_BAIVAGA"))>0   .And.  SD2->(ColumnPos("D2_BAIVAFR"))>0 .and. !lCalcCbu
												Aadd(aConIva,{SD2->D2_CF,(((nPerc /100) * (nValor ))  - (SD2->D2_IVAFRET+SD2->D2_IVAGAST)),((nValor )- (SD2->D2_BaIVAFR +SD2->D2_BaIVAGA)), (nPerc /100),,cAcmIVA,nPercCF})
											Elseif lCalcCbu 							
												Aadd(aConIva,{SD2->D2_CF, (nPercCF/100*(1-nRedAliq/100) * nValBas ),nValBas,(nPercCF /100*(1-nRedAliq/100)),,cAcmIVA,nPercCF})											
											Else
												Aadd(aConIva, {SD2->D2_CF, ((nPerc / 100) * (nValor)), nValor, (nPerc / 100), , cAcmIVA,nPercCF})
											EndIf
										EndIf

									EndIf
								EndIf
							EndIF
						Else
							If nPosIva<>0
								If SD2->(ColumnPos("D2_IVAFRET"))>0  .And.  SD2->(ColumnPos("D2_IVAGAST"))>0  .And. SD2->(ColumnPos("D2_BaIVAGA"))>0   .And.  SD2->(ColumnPos("D2_BAIVAFR"))>0
									aConIva[nPosIva][2]:=aConIva[nPosIva][2]+(SD2->D2_VALIMP1-SD2->D2_IVAFRET+SD2->D2_IVAGAST)
									aConIva[nPosIva][3]:=aConIva[nPosIva][3]+(SD2->D2_BASIMP1-SD2->D2_BaIVAFR+SD2->D2_BaIVAGA)
								Else
									aConIva[nPosIva][2]:=aConIva[nPosIva][2]+(SD2->D2_VALIMP1)
									aConIva[nPosIva][3]:=aConIva[nPosIva][3]+(SD2->D2_BASIMP1)
								EndIf

							Else
								Aadd(aConIva,{SD2->D2_CF,SD2->D2_VALIMP1,SD2->D2_BASIMP1,0,,,nPercCF})
							Endif
						Endif
					ElseIf SB1->(MsSeek(Iif(lMsFil .And. !Empty(xFilial("SB1")),SD2->D2_MSFIL,xFilial("SB1")) + SD2->D2_COD)) .And. !lCalcAcm
						nPosIva:=ASCAN(aConIva,{|x| x[1]==SB1->B1_CONCIVA})
						If nPosIva<>0
							aConIva[nPosIva][2]:=aConIva[nPosIva][2]+SD2->D2_VALIMP1
							aConIva[nPosIva][3]:=aConIva[nPosIva][3]+SD2->D2_BASIMP1
						Else
							Aadd(aConIva,{SB1->B1_CONCIVA,SD2->D2_VALIMP1,SD2->D2_BASIMP1,,,,nPercCF})
						Endif
					ElseIf !lCalcAcm
						nPosIva:=ASCAN(aConIva,{|x| x[1]==SA2->A2_ACTRET})
						If nPosIva<>0
							aConIva[nPosIva][2]:=aConIva[nPosIva][2]+(SD2->D2_VALIMP1)
							aConIva[nPosIva][3]:=aConIva[nPosIva][3]+(SD2->D2_BASIMP1)
						Else
							Aadd(aConIva,{SA2->A2_ACTRET,SD2->D2_VALIMP1,SD2->D2_BASIMP1,,,,nPercCF})
						Endif
					Endif
					SD2->(DbSkip())
				EndDo
			Endif
		Endif
		
		//Verificar a porcetagem correteado do Iva conforme informada nas datas
		If SA2->(ColumnPos("A2_IVPDCOB")) > 0 .and. SA2->(ColumnPos("A2_IVPCCOB")) > 0
			If (dDataBase >= SA2->A2_IVPDCOB .and. dDataBase <= SA2->A2_IVPCCOB)
				nPorIva := SA2->A2_PORIVA
			ElseIf (Empty(SA2->A2_IVPDCOB) .and. dDataBase <= SA2->A2_IVPCCOB)
				nPorIva := SA2->A2_PORIVA
			ElseIf (Empty(SA2->A2_IVPCCOB) .and. dDataBase >= SA2->A2_IVPDCOB)
				nPorIva := SA2->A2_PORIVA
			ElseIf !Empty(cAcmIVA) .And. cAcmIVA <> "0" .And. lCalcAcm .And. Subs(cAgente,2,1) == "N" .And. SA2->A2_AGENRET == "N"
				nPorIva := 100
			EndIf
		ElseIf !SA2->(ColumnPos("A2_IVPDCOB")) > 0 .and. !SA2->(ColumnPos("A2_IVPCCOB")) > 0 
			nPorIva := SA2->A2_PORIVA
		Else
			nPorIva := 100
		EndIf

		// Exenciones 
		SFH->(dbSetOrder(1))
		SFH->(dbGoTop())
		If SFH->(MsSeek(xFilial()+SA2->A2_COD+SA2->A2_LOJA+"IVR")) .and. SFH->(ColumnPos("FH_PERCENT"))>0
			If  (SFH->FH_ISENTO == "S" .OR. SFH->FH_PERCENT == 100)
				nPorIva := 0
			ElseIf A085aVigSFH()     
				If SFH->FH_ISENTO == "S" .OR. SFH->FH_PERCENT == 100
					nPorIva := 0				
				Else
					nPorIva := SFH->FH_PERCENT
				EndIf
			Endif 
		Endif 

		//?Gravar Retenciones. 
		
		For nCount:=1  to Len(aConIva)
			aConIva[nCount][2]   := Round(xMoeda(aConIva[nCount][2],SF2->F2_MOEDA,1,,5,aTxMoedas[Max(SF2->F2_MOEDA,1)][2]),MsDecimais(1))
			aConIva[nCount][3]   := Round(xMoeda(aConIva[nCount][3],SF2->F2_MOEDA,1,,5,aTxMoedas[Max(SF2->F2_MOEDA,1)][2]),MsDecimais(1))


			AAdd(aSFEIVA,array(12))
			aSFEIVA[Len(aSFEIVA)][1] := SF2->F2_DOC         								//FE_NFISCAL
			aSFEIVA[Len(aSFEIVA)][2] := SF2->F2_SERIE       								//FE_SERIE
			IF  lCalcCbu .Or. lCalRep
				aSFEIVA[Len(aSFEIVA)][3] := aConIva[nCount][3]*nSigno 
				aSFEIVA[Len(aSFEIVA)][4] := (aConIva[nCount][2]*nProp)*nSigno
			Else 
				aSFEIVA[Len(aSFEIVA)][3] := IIf (Alltrim(PadR(SF2->F2_SERIE,nTamSer)) == "B" .and. SA2->A2_TIPO == "I" .and. cPaisLoc == "ARG",(aConIva[nCount][3]*nProp)*nSigno+(aConIva[nCount][2]*nProp)*nSigno,(aConIva[nCount][3]*nProp)*nSigno)					//FE_VALBASE
				aSFEIVA[Len(aSFEIVA)][4] := (aConIva[nCount][2]*nProp)*nSigno					//FE_VALIMP
			Endif	
			aSFEIVA[Len(aSFEIVA)][5] := Iif((lCalRet .and. Alltrim(SF2->F2_SERIE) <> "A") .or.  lCalcVen,100,nPorIva)	//FE_PORCRET
			aSFEIVA[Len(aSFEIVA)][6] := 0
			aSFEIVA[Len(aSFEIVA)][9] := aConIva[nCount][1]  									// Gravar CFOP da operaçŽ¢o
			aSFEIVA[Len(aSFEIVA)][10]:= aConIva[nCount][4]*100								// Gravar A PORCENTAGEM DA ALIQUOTA
			aSFEIVA[Len(aSFEIVA)][11]:= " "
			aSFEIVA[Len(aSFEIVA)][12]:= aConIva[nCount][2]  
						
			If LEN(aConIva[1])==3 //pROVISORIO, PARA QUE NO DE ERROR EN BASES DESACTUALIZADAS
				If SFF->(FOUND())
						If (cPaisLoc=="ARG" .or. SA2->(ColumnPos("A2_IVRVCOB")) > 0) .And. SA2->(ColumnPos("A2_IVPCCOB")) > 0
						If SA2->A2_PORIVA < 100.00 .And. (Empty(SA2->A2_IVPCCOB) .Or. Dtos(SA2->A2_IVPCCOB) < Dtos(dDataBase))
							If  lOPRotAut
								cTxtRotAut += OemToAnsi(STR0011)+SA2->A2_COD+OemToAnsi(STR0005)
							 	lMsErroAuto := .T.
							Else
								MsgAlert(OemToAnsi(STR0011)+SA2->A2_COD+OemToAnsi(STR0005)) //"La fecha de validad para la reduccié«‡ del porcentaje de la retencié«‡ del IVA del proveedor ya se ha vencido. ". Ingrese una fecha valida para el proveedor en el archivo de proveedores."
							Endif
							//Zera o array das retencoes de IVA...
							aSFEIVA := {}
							//Sai do loop...
							Exit
						EndIf

						If cPaisLoc=="ARG" .Or. Empty(SA2->A2_IVRVCOB)
							aSFEIVA[Len(aSFEIVA)][6] := (aSFEIVA[Len(aSFEIVA)][4]*(SFF->FF_ALIQ/100))*(nPorIva/100)
						ElseIf Dtos(SA2->A2_IVRVCOB) < Dtos(dDataBase)
							If  lOPRotAut
								cTxtRotAut += OemToAnsi(STR0004)+SA2->A2_COD+OemToAnsi(STR0005)
							 	lMsErroAuto := .T.
							Else
								MsgAlert(OemToAnsi(STR0004)+SA2->A2_COD+OemToAnsi(STR0005)) //	"Ha vencido el perido de observacion del proveedor  "+SA2->A2_COD+". Ingrese una fecha valida para el proveedor en el archivo de proveedores."
							Endif
							//Zera o array das retencoes de IVA...
							aSFEIVA := {}
							//Sai do loop...
							Exit
						Else
							aSFEIVA[Len(aSFEIVA)][6] := aSFEIVA[Len(aSFEIVA)][4]
						EndIf
					Else
						aSFEIVA[Len(aSFEIVA)][6] := (aSFEIVA[Len(aSFEIVA)][4]*(SFF->FF_ALIQ/100))*(Iif((lCalRet .and. Alltrim(SF2->F2_SERIE) <> "A"),100,nPorIva)/100)
					EndIf
						
						SFF->(DbSetOrder(5))
						If SFF->(MsSeek(xFilial("SFF")+"IVR"))
							lAchou:=.F.
							While SFF->(!EOF() ).and. (xFilial("SFF")+"IVR") ==(SFF->FF_FILIAL+SFF->FF_IMPOSTO) .And.  !lAchou
								If (Alltrim(SFF->FF_SERIENF)==SubStr(Alltrim(PadR(SD2->D2_SERIE,nTamSer)),1,1)  .And.  aConIva[nCount][1] ==  SFF->FF_CFO_V)
									lAchou:=.T.
								Else
							   		SFF->(DbSkip())
								EndIf
								
							EndDO
                   EndiF
						
					If SFF->FF_IMPOSTO == "IVR"
						If !Empty(SFF->FF_CFO)
							aSFEIVA[Len(aSFEIVA)][11] := SFF->FF_CFO // Gravar CFOP da operaå ™åŸ½o de compra (para o caso de NCP)
						Else
							If  lOPRotAut
								cTxtRotAut += OemToAnsi(STR0003)
							 	lMsErroAuto := .T.
							Else
								MsgAlert(STR0003)
							Endif
							aSFEIVA[Len(aSFEIVA)][11] := " "
						EndIf
					EndIf
					
					
					nTotRet += aSFEIVA[Len(aSFEIVA)][6]
				ELSE
					DEFINE MSDIALOG oDlg4 FROM 65,0 To 218,312 Title OemToAnsi(STR0006) Pixel //"Inconsistencia"
					@ 2,3 To 51,150 Pixel of oDlg4
					//"La actividad ", " de IVA no esta registrada en la Tabla SFF"
					//"por lo tanto no se generara retenciî•” de IVA. Si desea Continuar con la "
					//"Orden de Pago acepte, sino cancele. "
					@ 10,004 SAY OemToAnsi(STR0007)+ aConIva[nCount][1] +OemToAnsi(STR0008) PIXEL Of oDlg4
					@ 23,004 SAY OemToAnsi(STR0009)	PIXEL Of oDlg4
					@ 36,004 SAY OemToAnsi(STR0010) 	PIXEL	Of oDlg4
					DEFINE SBUTTON FROM 57,064  Type 1 Action (lRetOk	:=	.T.,oDlg4:End())    Pixel ENABLE Of oDlg4
					DEFINE SBUTTON FROM 57,104  Type 2 Action (lRetOk	:=	.F.,oDlg4:End())  Pixel ENABLE Of oDlg4
					Activate Dialog oDlg4 CENTERED
				Endif
			Else

				SFF->(DbSetOrder(5))
				If SFF->(MsSeek(xFilial("SFF")+"IVR"))
					lAchou:=.F.
					While SFF->(!EOF() ).and. (xFilial("SFF")+"IVR") ==(SFF->FF_FILIAL+SFF->FF_IMPOSTO) .And.  !lAchou
						If (Alltrim(SFF->FF_SERIENF)==SubStr(Alltrim(PadR(SF2->F2_SERIE,nTamSer)),1,1)  .And.  aConIva[nCount][1]==  SFF->FF_CFO_V)
							lAchou:=.T.
						Else
							SFF->(DbSkip())
						EndIf
					EndDO
                End
			
				If SFF->FF_IMPOSTO == "IVR"
					If !Empty(SFF->FF_CFO)
						aSFEIVA[Len(aSFEIVA)][11] := SFF->FF_CFO // Gravar CFOP da operaå ™åŸ½o de compra (para o caso de NCP)
					Else
						If  lOPRotAut
							cTxtRotAut += OemToAnsi(STR0003)
						 	lMsErroAuto := .T.
						Else
							MsgAlert(STR0003)
						Endif
						aSFEIVA[Len(aSFEIVA)][11] := " "
					EndIf
				EndIf
				
				If  SA2->(ColumnPos("A2_IVPCCOB")) > 0 .And. SA2->(ColumnPos("A2_IVPDCOB")) > 0

					If lCalcNew
						If lCalRep .or. lCalcVen
							aSFEIVA[Len(aSFEIVA)][6] := (aSFEIVA[Len(aSFEIVA)][4])
						Else
							aSFEIVA[Len(aSFEIVA)][6] := (aSFEIVA[Len(aSFEIVA)][4]) *(nPorIva/100)
						EndIf
					Else
						aSFEIVA[Len(aSFEIVA)][6] := aSFEIVA[Len(aSFEIVA)][4]
					EndIf

				EndIf

				nTotRet += aSFEIVA[Len(aSFEIVA)][6]
			
			Endif
			
			//?Generar Titulo de Impuesto no Contas a Pagar.   
			
			aSFEIVA[Len(aSFEIVA)][7] := SE2->E2_VALOR
			aSFEIVA[Len(aSFEIVA)][8] := SE2->E2_EMISSAO
		Next
			If lShowPOrd .and. TableInDic("FVC") .and. Funname() == "FINA855"
				DBSELECTAREA("FVC")
				FVC->(DBSETORDER(3)) //FVC_FILIAL+FVC_FORNEC+FVC_LOJA+FVC_NFISC+FVC_SERIE+FVC_TIPO+FVC_CONCEP
				If FVC->(MsSeek(xFilial("FVC")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC))
					While FVC->(!Eof()) .and. FVC->(FVC_FORNEC+FVC_LOJA+FVC_NFISC) == SF2->(F2_CLIENTE+F2_LOJA+F2_DOC)
						If  Iif(Inclui,.T.,FJK->FJK_PREOP != FVC->FVC_PREOP)
							If AllTrim(FVC->FVC_TIPO) == "I" .and. ABS(FVC->FVC_RETENC) > 0 .and. FVC->FVC_SERIE == SF2->F2_SERIE
								nTotRetSFE += FVC->FVC_RETENC
							EndIf
						Endif
						FVC->(dbSkip())
					Enddo
				EndIf	
			EndIf
			//Levanta quanto ja foi retido para a factura corrente, para em seguida
			//abater do total calculado para retencao.
			SFE->(dbSetOrder(4))
			If SFE->(MsSeek(xFilial("SFE")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC+SF2->F2_SERIE+"I"))
				cChaveSFE := SFE->FE_FILIAL+SFE->FE_FORNECE+SFE->FE_LOJA+SFE->FE_NFISCAL+SFE->FE_SERIE+"I"
				While !SFE->(Eof())
					If cChaveSFE == xFilial("SFE")+SFE->FE_FORNECE+SFE->FE_LOJA+SFE->FE_NFISCAL+SFE->FE_SERIE+SFE->FE_TIPO .and. EMPTY(SFE->FE_DTESTOR)  .And.;
					 (SFE->FE_RETENC<0 )
						nTotRetSFE += SFE->FE_RETENC
					EndIf
					SFE->(dbSkip())
				End
			EndIf
			
			If ABS(nTotRetSFE) > 0	
				//Proporcionaliza o que ja foi retido e abate da retencao que
				//foi calculada.
				IF !(nSaldo < SE2->E2_VALOR) .Or. (nSaldo < SE2->E2_VALOR .And. !Empty(cAcmIVA) .And. cAcmIVA == "2" .And. lCalcAcm .And. Subs(cAgente,2,1) == "N" .And. SA2->A2_AGENRET == "N")
					IF !(nSaldo == SE2->E2_VALOR)
						For nCount:= 1 To Len(aSFEIVA)
							If !(aSFEIVA[nCount][6] == (nTotRetSFE * (aSFEIVA[nCount][6] / nTotRet)) .and. Funname() <> "FINA850") 
								aSFEIVA[nCount][6] -= (nTotRetSFE * (aSFEIVA[nCount][6] / nTotRet))
							ElseIf (aSFEIVA[nCount][6] == (nTotRetSFE * (aSFEIVA[nCount][6] / nTotRet)) .and. Funname() <> "FINA850") 
								aSFEIVA[nCount][6] -= nTotRetSFE
							EndIf
						Next nCount   
					ElseIf (nSaldo == SE2->E2_VALOR)
						For nCount:= 1 To Len(aSFEIVA)
							If		aSFEIVA[nCount][6] == nTotRetSFE
									aSFEIVA[nCount][6] := 0
							ElseIf !(aSFEIVA[nCount][6] == (nTotRetSFE * (aSFEIVA[nCount][6] / nTotRet)) .and. Funname() <> "FINA850") 
									aSFEIVA[nCount][6] -= (nTotRetSFE * (aSFEIVA[nCount][6] / nTotRet))
							ElseIf (aSFEIVA[nCount][6] == (nTotRetSFE * (aSFEIVA[nCount][6] / nTotRet)) .and. Funname() <> "FINA850") 
									aSFEIVA[nCount][6] -= nTotRetSFE
							EndIf
						Next nCount
					EndIf
				ElseIf (nSaldo == SE2->E2_VALOR)
					For nCount:= 1 To Len(aSFEIVA)
						If !(aSFEIVA[nCount][6] == (nTotRetSFE * (aSFEIVA[nCount][6] / nTotRet)) .and. Funname() <> "FINA850") 
							aSFEIVA[nCount][6] -= (nTotRetSFE * (aSFEIVA[nCount][6] / nTotRet))
						ElseIf (aSFEIVA[nCount][6] == (nTotRetSFE * (aSFEIVA[nCount][6] / nTotRet)) .and. Funname() <> "FINA850") 
							aSFEIVA[nCount][6] -= nTotRetSFE
						EndIf
					Next nCount 	
				Endif
			EndIf
		//Verifica se o valor de retencao calculado supera o valor
		//minimo a ser retido, caso seja inferior nao eh realizada
		//a retencao.
		
		If !lCalcAcm
			nTotRet := 0
			aEval(aSFEIVA,{|x| nTotRet += (x[6]*-1)})
			If  nTotRet <= SFF->FF_IMPORTE
				aEval(aSFEIVA,{|x| x[6] := 0})
			EndIf
		EndIf
			
	EndIf
EndIf

Return aSFEIVA


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RetIVAMDb ºAutor  ³                    º Data ³  31/07/2020 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ RetIVAMDb   - Calculo de Ret de IVA para NF                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ARGRetIM (FINRETARG)                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ 1. cAgente: Agente de retención (N = No/ S = Si).          º±±
±±           ³ 2. nSigno: 1 / (-1)Si SE2->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG º±±
±±           ³ 3. nSaldo: Saldo (valor baser o valor a bajar).            º±±
±±           ³ 4. lPa                                                     º±±
±±           ³ 5. cCF                                                     º±±
±±           ³ 6. nValor                                                  º±±
±±           ³ 7. nProp: Proporcionalización para IVA.                    º±±
±±           ³ 8. lNNF                                                    º±±
±±           ³ 9. cSerieNF                                                º±±
±±           ³ 10.cChavePOP: FJK_PREOP+Proveedor+Loja, usada en ObtReten()º±±
±±           ³ 11.cNFPOP: Num de documento(E2_NUM), usado en ObtReten()   º±±
±±           ³ 12.cSeriePOP: Serie(E2_PREFIXO), usada en ObtReten()       º±±
±±           ³ 13.dEmissao: Fch emisión CXP(E2_EMISSAO), usada ObtReten() º±±
±±           ³ 14.lOPRotAut: Es rutina automatica (.T.)                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RetIVAMDb(cAgente,nSigno,nSaldo,lPa,cCF,nValor,nProp,lNNF,cSerieNF,cChavePOP,cNFPOP,cSeriePOP,dEmissao,lOPRotAut)
Local aConIva  	:= {}
Local aSFEIVA  	:= {}
Local aCF 		:= {}
Local lCalcMon 	:= .F.
Local lCalRet	:= .F.
Local lCalcImp	:= .T.
Local lCalRep	:= .F.
Local lRetSit	:= .T.
Local lPropIVA	:= Iif(GetMV("MV_PROPIVA",.F.,2)==2,.T.,.F.)
Local cChaveSFE	:= ""
Local cCodFis 	:= ""
Local cItem 	:= ""
Local nPosIva	:= 0
Local nCount	:= 0
Local nPercRet	:= 0
Local nI		:= 1
Local nRetIva	:= 0
Local nRetTotal	:= 0
Local nTotRet 	:= 0
Local nMinimo 	:= 0
Local nMinUnit 	:= 0
Local nParcela 	:= 0
Local nRecSF1 := 0 
Local nTamSer := SerieNfId('SF1',6,'F1_SERIE')
Local lTESNoExen := .F.

DEFAULT lNNF 	:= .F.
DEFAULT lPa		:= .F.
DEFAULT cCF 	:= ""
DEFAULT nValor 	:= 0
DEFAULT nSigno	:= 1
DEFAULT cChavePOP:= ""
DEFAULT cNFPOP	 := ""
DEFAULT cSeriePOP:= ""
DEFAULT dEmissao := CTOD("//")
DEFAULT lOPRotAut:= .F.

If lShowPOrd .and. Funname() == "FINA847" .and. Type("lCtaCte")<>"U" .and. lCtaCte
	Return aSFEIVA := ObtReten(cChavePOP,cNFPOP,cSeriePOP,"I",nSaldo,dEmissao)
EndIf

//+---------------------------------------------------------------------+
//° Obter Impostos somente qdo a Empresa Usuario for Agente de Retençäo.°
//+---------------------------------------------------------------------+
aArea:=GetArea()

dbSelectArea("SF1")
dbSetOrder(1)
If lMsFil
	nRecSF1 := FINBuscaNF(SE2->E2_MSFIL,SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_FORNECE,SE2->E2_LOJA,"SF1",.T.)
	SF1->(dbGoTo(nRecSF1))
Else
	nRecSF1 := FINBuscaNF(xFilial("SF1",SE2->E2_FILORIG),SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_FORNECE,SE2->E2_LOJA,"SF1",.T.)
	SF1->(dbGoTo(nRecSF1))
EndIf

If lNNF
	lCalRet := .T. //Força calculo de IVA para monotributista sem nota (PA pela orden de pago)
Else
	lCalRet := Iif(Alltrim(PadR(SF1->F1_SERIE,nTamSer)) == "M",.T.,.F.)
EndIf

If ExistBlock("F0851IMP")
	lCalcImp:=ExecBlock("F0851IMP",.F.,.F.,{"IVA"})
EndIf

If lNNF
	SA2->(dbSetOrder(1))
	SA2->(MsSeek(xFilial("SA2")+cFornece+cLoja))
Else
	SA2->( dbSetOrder(1) )
	If lMsFil .And. !Empty(xFilial("SA2")) .And. xFilial("SF1") == xFilial("SE2")
		SA2->( MsSeek(SE2->E2_MSFIL+SE2->E2_FORNECE+SE2->E2_LOJA) )
	Else
		SA2->( MsSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA) )
	Endif
EndIf

// Tratamento do Reproweb - Situação igual a 0 não deve reter Resolución General ( AFIP) 2226/07
If SA2->(ColumnPos("A2_SITU")>0) .and. Alltrim(SA2->A2_SITU)$("0")
	lRetSit:=.F.
EndIf

If lCalcImp .And. lRetSit

	If !lNNF
		SA2->( dbSetOrder(1) )
		If lMsFil .And. !Empty(xFilial("SA2")) .And. xFilial("SF1") == xFilial("SE2")
			SA2->( MsSeek(SE2->E2_MSFIL+SE2->E2_FORNECE+SE2->E2_LOJA) )
		Else
			SA2->( MsSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA) )
		Endif
	EndIf

	lCalRep := Iif(SA2->(ColumnPos("A2_SITU")>0) .and. Alltrim(SA2->A2_SITU)$("2/4"),.T.,.F.)

	If SA2->A2_AGENRET == "N" .Or. lCalRet

		If !lPA
			While Alltrim(SF1->F1_ESPECIE)<>AllTrim(SE2->E2_TIPO).And.!EOF()
				SF1->(DbSkip())
				Loop
			Enddo

			//Caso o valor da fatura seja parcelado, atribui o valor da parcela.
			If !Empty(SE2->E2_PARCELA) .And. lPropIVA
				nParcela := SE2->E2_VALOR
			Endif

			If AllTrim(SF1->F1_ESPECIE)==Alltrim(SE2->E2_TIPO).And.;
				Iif(lMsFil,SF1->F1_MSFIL,xFilial("SF1",SE2->E2_FILORIG))+SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE+SE2->E2_LOJA==;
				F1_FILIAL+F1_DOC+PadR(F1_SERIE,nTamSer)+F1_FORNECE+F1_LOJA

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Obter o Valor do Imposto e Base baseando se no rateio do valor ³
					//³ do titulo pelo total da Nota Fiscal.                           ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				SD1->(DbSetOrder(1))
				If lMsFil
					SD1->(MsSeek(SF1->F1_MSFIL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
				Else
					SD1->(MsSeek(xFilial("SD1",SE2->E2_FILORIG)+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
				EndIf
				If SD1->(Found())
					Do while Iif(lMsFil,SD1->D1_MSFIL,xFilial("SD1",SE2->E2_FILORIG))==SD1->D1_FILIAL.And.SF1->F1_DOC==SD1->D1_DOC.AND.;
						SF1->F1_SERIE==SD1->D1_SERIE.AND.SF1->F1_FORNECE==SD1->D1_FORNECE;
						.AND.SF1->F1_LOJA==SD1->D1_LOJA.AND.!SD1->(EOF())

						If AllTrim(SD1->D1_ESPECIE)<>AllTrim(SF1->F1_ESPECIE)
							SD1->(DbSkip())
							Loop
						Endif
						aImpInf := TesImpInf(SD1->D1_TES)
						lTESNoExen := aScan(aImpInf,{|x| "IV" $ AllTrim(x[1])}) <> 0
						If !lTESNoExen
							SD1->(DbSkip())
							Loop
						EndIf
						SB1->(DbSetOrder(1))
						If !Empty(SD1->D1_CF)
							nPosIva:=ASCAN(aConIva,{|x| x[1]==SD1->D1_CF})
								If nPosIva<>0
									aConIva[nPosIva][2]:=aConIva[nPosIva][2]+((aConIva[nPosIva][4] * (SD1->D1_TOTAL ) )- ((SD1->D1_IVAFRET+SD1->D1_IVAGAST)))
									aConIva[nPosIva][3]:=aConIva[nPosIva][3]+((SD1->D1_TOTAL ) - ((SD1->D1_BaIVAFR+SD1->D1_BaIVAGA)) )
								Else

									If lCalRep 
										aImpInf := TesImpInf(SD1->D1_TES)

										For nI := 1 To Len(aImpInf)
											If  "IV"$Trim(aImpInf[nI][01]) .And. aImpInf[nI][14] == "N";
												.And. aImpInf[nI][15] == "I" .And. aImpInf[nI][16] == "3"
												Aadd(aConIva,{SD1->D1_CF,SD1->(FieldGet(ColumnPos(aImpInf[nI][02]))),SD1->(FieldGet(ColumnPos(aImpInf[nI][07]))), (SD1->(FieldGet(ColumnPos(aImpInf[nI][10]))) /100)})
											 EndIf
										Next

									Else
										SFF->(DbSetOrder(5))
										SFF->(DbGotop())
										If SFF->(MsSeek(xFilial("SFF")+"IVR"))
											nPerc:=0
											lAchou:=.F.
											While SFF->(!EOF() ).and. (xFilial("SFF")+"IVR") ==(SFF->FF_FILIAL+SFF->FF_IMPOSTO) .And.  !lAchou
												If (Alltrim(SFF->FF_SERIENF)== SubStr(Alltrim(PadR(SD1->D1_SERIE,nTamSer)),1,1) .And. SD1->D1_CF==  SFF->FF_CFO_C )
													lAchou:=.T.
													nPerc:=SFF->FF_ALIQ
												Else
													SFF->(DbSkip())
												EndIf
											EndDo

											If lAchou
													nValorBr:=Round(xmoeda(SF1->F1_VALBRUT,SF1->F1_MOEDA,1,,5,aTxMoedas[Max(SF1->F1_MOEDA,1)][2]),MsDecimais(1))
													nPerc:=SFF->FF_ALIQ
											EndIf

											Aadd(aConIva,{SD1->D1_CF,(((nPerc/100 ) * Iif(nParcela == 0,(SD1->D1_TOTAL),nParcela)) - (SD1->D1_IVAFRET+SD1->D1_IVAGAST)),(Iif(nParcela == 0,SD1->D1_TOTAL,nParcela)- (SD1->D1_BaIVAFR +SD1->D1_BaIVAGA)), (nPerc /100),SFF->FF_CFO})
										EndIf
									EndIf
								EndIF

						ElseIf SB1->(MsSeek(Iif(lMsFil .And. !Empty(xFilial("SB1")),SD1->D1_MSFIL,xFilial("SB1")) + SD1->D1_COD))
							nPosIva:=ASCAN(aConIva,{|x| x[1]==SB1->B1_CONCIVA})
							If nPosIva<>0
								aConIva[nPosIva][2]:=aConIva[nPosIva][2]+(SD1->D1_VALIMP1-SD1->D1_IVAFRET+SD1->D1_IVAGAST)
								aConIva[nPosIva][3]:=aConIva[nPosIva][3]+(SD1->D1_BASIMP1-SD1->D1_BaIVAFR+SD1->D1_BaIVAGA)
							Else
								Aadd(aConIva,{SB1->B1_CONCIVA,(SD1->D1_VALIMP1-SD1->D1_IVAFRET+SD1->D1_IVAGAST),(SD1->D1_BASIMP1-SD1->D1_BaIVAFR +SD1->D1_BaIVAGA),0})
							Endif
						Else
							nPosIva:=ASCAN(aConIva,{|x| x[1]==SA2->A2_ACTRET})
							If nPosIva<>0
								aConIva[nPosIva][2]:=aConIva[nPosIva][2]+(SD1->D1_VALIMP1)
								aConIva[nPosIva][3]:=aConIva[nPosIva][3]+(SD1->D1_BASIMP1)
							Else
								Aadd(aConIva,{SA2->A2_ACTRET,SD1->D1_VALIMP1,SD1->D1_BASIMP1,0})
							Endif
						Endif

						SD1->(DbSkip())
					EndDo
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Gravar Retenciones.                                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nCount:=1  to Len(aConIva)

	 				//Verifica se fara o calculo de IVA para fornecedores monotributistas
					dbSelectArea("SFF")
					dbGoTop()
					dbSetOrder(5)

					If MsSeek(xFilial("SFF")+"IVR"+aConIva[nCount][1])
						While SFF->(!Eof()) .And. SFF->FF_CFO_C == aConIva[nCount][1]

							If SFF->FF_ITEM $	"I1|I2" .And. SFF->FF_TIPO == 'M';
							   .And. AllTrim(SFF->FF_SERIENF) == SubStr(AllTrim(PadR(SF1->F1_SERIE,nTamSer)),1,1)

								cItem		:= SFF->FF_ITEM
								nMinimo  	:= Iif(SFF->(ColumnPos("FF_LIMITE"))>0,SFF->FF_LIMITE,0)
								nMinUnit 	:= Iif(SFF->(ColumnPos("FF_MINUNIT"))>0,SFF->FF_MINUNIT,0)

								nRecSFF := Recno()

								dbGoTop()
								MsSeek(xFilial("SFF")+"IVR")

								//Array contendo todos os CFOs com a mesma classificação
								While SFF->(!Eof())
									If SFF->FF_ITEM == cItem
										If aScan(aCf,{|x| x[1] == SFF->FF_CFO_C}) == 0
											aAdd(aCf,{SFF->FF_CFO_C,SFF->FF_CFO_V})
										Endif
									Endif
									SFF->(dbSkip())
								Enddo

								dbGoTo(nRecSFF)

								//Verifica se deve calcular IVA
								lCalcMon := F850CheckLim(cItem,aCf,cFornece,nMinimo,SF1->F1_DOC,SF1->F1_SERIE,nMinUnit,"IVA",,1,Iif(lMsFil,SF1->F1_MSFIL,""))
								Exit
							Endif
							SFF->(dbSkip())
						Enddo
					Endif

					If lCalcMon

						aConIva[nCount][2]   := Round(xMoeda(aConIva[nCount][2],SF1->F1_MOEDA,1,,5,aTxMoedas[Max(SF1->F1_MOEDA,1)][2]),MsDecimais(1))
						aConIva[nCount][3]   := Round(xMoeda(aConIva[nCount][3],SF1->F1_MOEDA,1,,5,aTxMoedas[Max(SF1->F1_MOEDA,1)][2]),MsDecimais(1))

						AAdd(aSFEIVA,array(11))

						aSFEIVA[Len(aSFEIVA)][1] := SF1->F1_DOC         		//FE_NFISCAL
						aSFEIVA[Len(aSFEIVA)][2] := SF1->F1_SERIE       		//FE_SERIE
						aSFEIVA[Len(aSFEIVA)][3] := (aConIva[nCount][3]*nProp)*nSigno	//FE_VALBASE
						aSFEIVA[Len(aSFEIVA)][4] := (aConIva[nCount][2]*nProp)*nSigno	//FE_VALIMP
						aSFEIVA[Len(aSFEIVA)][5] := Iif(Alltrim(PadR(SF1->F1_SERIE,nTamSer))=="M",100,SA2->A2_PORIVA)      		//FE_PORCRET
						aSFEIVA[Len(aSFEIVA)][6] := (aSFEIVA[Len(aSFEIVA)][4]) *(Iif(Alltrim(PadR(SF1->F1_SERIE,nTamSer))=="M",1,Iif(lCalRep /*.or. lCalcVen*/ ,1, SA2->A2_PORIVA/100) ))
						aSFEIVA[Len(aSFEIVA)][7] := nSaldo
						aSFEIVA[Len(aSFEIVA)][8] := SE2->E2_EMISSAO
						If Len(aConIva[nCount]) >4 .And. !Empty(aConIva[nCount][5])
							aSFEIVA[Len(aSFEIVA)][9] := aConIva[nCount][5] // Gravar CFOP da operação
						Else
						 	aSFEIVA[Len(aSFEIVA)][9] := aConIva[nCount][1] // Gravar CFOP da operação
						EndIf                
						aSFEIVA[Len(aSFEIVA)][10] := aConIva[nCount][4]*100 // Gravar A PORCENTAGEM DA ALIQUOTA
						aSFEIVA[Len(aSFEIVA)][11] := " "						

						If SA2->(ColumnPos("A2_IVRVCOB")) > 0 .And. SA2->(ColumnPos("A2_IVPCCOB")) > 0
							If Dtos(SA2->A2_IVRVCOB) < Dtos(dDataBase)								
								If  lOPRotAut
									cTxtRotAut += OemToAnsi(STR0004)+SA2->A2_COD+OemToAnsi(STR0005) //	"Ha vencido el perido de observacion del proveedor  "+SA2->A2_COD+". Ingrese una fecha valida para el proveedor en el archivo de proveedores."
							 		lMsErroAuto := .T.
							 	Else
							 		MsgAlert(OemToAnsi(STR0004)+SA2->A2_COD+OemToAnsi(STR0005)) //	"Ha vencido el perido de observacion del proveedor  "+SA2->A2_COD+". Ingrese una fecha valida para el proveedor en el archivo de proveedores."
							 	Endif
								//Zera o array das retencoes de IVA...
								aSFEIVA := {}
								//Sai do loop...
								Exit
							EndIf
						Endif
					Endif
				Next nCount
			EndIf
		//Calculo do PA
		Elseif lRetPa

			lCalRep := Iif(SA2->(ColumnPos("A2_SITU")>0) .and. Alltrim(SA2->A2_SITU)$("2/4"),.T.,.F.)
			SFF->(DbSetOrder(5))
			SFF->(MsSeek(xFilial("SFF")+"IVR"+cCF)) //cConceito pegar do TES (CFO)
			If SFF->(FOUND())
				While !SFF->(Eof()) .And. xFilial("SFF")+"IVR"+cCF == SFF->(FF_FILIAL+FF_IMPOSTO+FF_CFO_C)
					If !Empty(cSerieNF) .And. PadR(cSerieNF,Len(SFF->FF_SERIENF)) != SFF->FF_SERIENF
						SFF->(dbSkip())
						Loop
					EndIf

		            cCodFis:= SFF->FF_CFO
					If SFF->(ColumnPos("FF_VLRLEX"))>0 .And. SFF->(ColumnPos("FF_ALIQLEX"))>0
						nPercRet:=Iif(nSaldo>SFF->FF_VLRLEX,SFF->FF_ALIQ/100,SFF->FF_ALIQLEX/100)
		            Else
			            nPercRet:=SFF->FF_ALIQ/100
					EndIf

					AAdd(aSFEIVA,array(9))
					aSFEIVA[Len(aSFEIVA)][1] := ""         		//FE_NFISCAL
					aSFEIVA[Len(aSFEIVA)][2] := ""       		//FE_SERIE
					aSFEIVA[Len(aSFEIVA)][3] := nSaldo * nSigno	//FE_VALBASE
					aSFEIVA[Len(aSFEIVA)][4] := 0	//FE_VALIMP
					aSFEIVA[Len(aSFEIVA)][5] := SA2->A2_PORIVA   		//FE_PORCRET
					aSFEIVA[Len(aSFEIVA)][6] := (aSFEIVA[Len(aSFEIVA)][3]) *(Iif(lCalRep ,1, SA2->A2_PORIVA/100))
					aSFEIVA[Len(aSFEIVA)][9] := cCodFis // Gravar CFOP da operação

					If SA2->(ColumnPos("A2_IVRVCOB")) > 0 .And. SA2->(ColumnPos("A2_IVPCCOB")) > 0
					 	If lCalRep
					 		nRetIva:=(aSFEIVA[Len(aSFEIVA)][3])*nPercRet
						Else
							nRetIva:= ((aSFEIVA[Len(aSFEIVA)][3]) *(SA2->A2_PORIVA/100))*nPercRet
						EndIf
					Else
						If lCalRep
					 		nRetIva:= (aSFEIVA[Len(aSFEIVA)][3])*nPercRet
					   	Else
							nRetIva:= ((aSFEIVA[Len(aSFEIVA)][3]) *(SA2->A2_PORIVA/100))*nPercRet
					   	EndIf
					EndIf
	
					aArea:=GetArea()
					DbSelectArea("SFE")
					SFE->(dbSetOrder(4))
					If SFE->(MsSeek(xFilial("SFE")+cFornece+cLoja))
				  	   	cChaveSFE := xFilial("SFE")+SFE->FE_FORNECE+SFE->FE_LOJA
						While !SFE->(Eof()) .And. cChaveSFE == SFE->FE_FILIAL+SFE->FE_FORNECE+SFE->FE_LOJA
							If SFE->FE_TIPO =="I" .And. !Empty(cNumOp) .And. SFE->FE_NUMOPER == cNumOp
								nRetTotal += SFE->FE_RETENC
							EndIf
							SFE->(dbSkip())
						End
				    EndIf
	
					RestArea(aArea)
	
					aSFEIVA[Len(aSFEIVA)][6]:=Iif(nRetTotal>0,((nRetTotal-nRetIva)*-1),nRetIva)
	
	   				//Verifica se o valor a ser retido é maior que o valor do PA
					If nValor < aSFEIVA[Len(aSFEIVA)][6]
						aSFEIVA[Len(aSFEIVA)][6]:= nValor
					EndIF
	
	
					//Verifica se o valor de retencao calculado supera o valor
					//minimo a ser retido, caso seja inferior nao eh realizada
					//a retencao.
					nTotRet := 0
					aEval(aSFEIVA,{|x| nTotRet += x[6]})
					If SA2->(ColumnPos("A2_IVRVCOB")) > 0
						If  nTotRet < SFF->FF_IMPORTE .And. Empty(SA2->A2_IVRVCOB)
							  aEval(aSFEIVA,{|x| x[6] := 0})
						EndIf
					Else
						If  nTotRet < SFF->FF_IMPORTE
							  aEval(aSFEIVA,{|x| x[6] := 0})
						EndIf
					Endif
					
					If !Empty(cSerieNF)
						SFF->(dbSkip())
					Else
						Exit
					EndIf
				EndDo
            EndIf
		EndIF
	EndIf
EndIf
RestArea(aArea)

Return aSFEIVA


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RetIVAMCr ºAutor  ³                    º Data ³  31/07/2020 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ RetIVAMCr   - Calculo de Ret de IVA para NF                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ARGRetIM2 (FINRETARG)                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ 1. cAgente: Agente de retención (N = No/ S = Si).          º±±
±±           ³ 2. nSigno: 1 / (-1)Si SE2->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG º±±
±±           ³ 3. nSaldo                                                  º±±
±±           ³ 4. nProp                                                   º±±
±±           ³ 5. cChavePOP: FJK_PREOP+Proveedor+Loja, usada en ObtReten()º±±
±±           ³ 6. cNFPOP: Num de documento(E2_NUM), usado en ObtReten()   º±±
±±           ³ 7. cSeriePOP: Serie(E2_PREFIXO), usada en ObtReten()       º±±
±±           ³ 8. dEmissao: Fch emisión CXP(E2_EMISSAO), usada ObtReten() º±±
±±           ³ 9. lOPRotAut: Es rutina automatica (.T.)                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RetIVAMCr(cAgente,nSigno,nSaldo,nProp,cChavePOP,cNFPOP,cSeriePOP,dEmissao,lOPRotAut)
Local aCf		:= {}
Local aConIva	:= {}
Local aSFEIVA	:= {}
Local lRetSerie	:= .F.
Local lCalRet	:= .F.
Local lCalcImp	:= .T.
Local lCalRep	:= .F.
Local lCalcMon	:= .F.
Local lRetSit	:= .T.
Local lPropIVA	:= Iif(GetMV("MV_PROPIVA",.F.,2)==2,.T.,.F.)
Local nMinimo	:= 0
Local nMinUnit	:= 0
Local nPosIva	:= 0
Local nCount	:= 0
Local nI		:= 1
Local nParcela	:= 0
Local nPosCF	:= 0
Local nRecSF2	:= 0 
Local nTamSer := SerieNfId('SF2',6,'F2_SERIE')
Local lTESNoExen := .F.  

DEFAULT nSigno	:= -1
DEFAULT nProp 	:= 1
DEFAULT cChavePOP:= ""
DEFAULT cNFPOP	 := ""
DEFAULT cSeriePOP:= ""
DEFAULT dEmissao := CTOD("//")
DEFAULT lOPRotAut:= .F.
//+---------------------------------------------------------------------+
//° Obter Impostos somente qdo a Empresa Usuario for Agente de Retençäo.°
//+---------------------------------------------------------------------+

If lShowPOrd .and. Funname() == "FINA847" .and. Type("lCtaCte")<>"U" .and. lCtaCte
	Return aSFEIVA := ObtReten(cChavePOP,cNFPOP,cSeriePOP,"I",nSaldo,dEmissao)
EndIf

dbSelectArea("SF2")
dbSetOrder(1)
If lMsFil
	nRecSF2 := FINBuscaNF(SE2->E2_MSFIL,SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_FORNECE,SE2->E2_LOJA,"SF2",.T.)
	SF2->(dbGoTo(nRecSF2))
Else
	nRecSF2 := FINBuscaNF(xFilial("SF2", SE2->E2_FILORIG),SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_FORNECE,SE2->E2_LOJA,"SF2",.T.)
	SF2->(dbGoTo(nRecSF2))
EndIf

lCalRet := Iif(Alltrim(PadR(SF2->F2_SERIE,nTamSer)) == "M",.T.,.F.)

If ExistBlock("F0851IMP")
	lCalcImp:=ExecBlock("F0851IMP",.F.,.F.,{"IV2"})
EndIf

// Tratamento do Reproweb - Situação igual a 0 não deve reter Resolución General ( AFIP) 2226/07

SA2->( dbSetOrder(1) )
If lMsFil .And. !Empty(xFilial("SA2")) .And. xFilial("SF1") == xFilial("SE2")
	SA2->( MsSeek(SE2->E2_MSFIL+SE2->E2_FORNECE+SE2->E2_LOJA) )
Else
	SA2->( MsSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA) )
Endif


 If SA2->(ColumnPos("A2_SITU")>0) .and. Alltrim(SA2->A2_SITU)$("0")
	 lRetSit:=.F.
 EndIf

If lCalcImp  .And.  lRetSit
	SA2->( dbSetOrder(1) )
	If lMsFil .And. !Empty(xFilial("SA2")) .And. xFilial("SF1") == xFilial("SE2")
		SA2->( MsSeek(SE2->E2_MSFIL+SE2->E2_FORNECE+SE2->E2_LOJA) )
	Else
		SA2->( MsSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA) )
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Fornecedor ‚ Agente de Reten‡„o n„o Retem IVA.                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SA2->A2_AGENRET == "N" .Or. lCalRet

		lCalRep := Iif(SA2->(ColumnPos("A2_SITU")>0) .and. Alltrim(SA2->A2_SITU)$("2/4"),.T.,.F.)

		While Alltrim(SF2->F2_ESPECIE)<>AllTrim(SE2->E2_TIPO).And.!EOF()
			SF2->(DbSkip())
			Loop
		Enddo

		//Caso o valor da nota seja parcelado, atribui o valor da parcela.
		If !Empty(SE2->E2_PARCELA) .And. lPropIVA
			nParcela := SE2->E2_VALOR
		Endif

		If AllTrim(SF2->F2_ESPECIE)==Alltrim(SE2->E2_TIPO).And.;
			Iif(lMsFil,SF2->F2_MSFIL,xFilial("SF2",SE2->E2_FILORIG))+SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE+SE2->E2_LOJA==;
			F2_FILIAL+F2_DOC+PadR(F2_SERIE,nTamSer)+F2_CLIENTE+F2_LOJA

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se esta definida uma retencao para uma serie especial, verifico³
			//³ antes de procurar no SD1.(Serie 'M' foi o primeiro caso).      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SFF->(DbSetOrder(3))

			If SFF->(MsSeek(xFilial("SFF")+"IVR"+PadR(SF2->F2_SERIE,nTamSer)+"SER"))
				nPosIva:=ASCAN(aConIva,{|x| x[1]==SF2->F2_SERIE})
				If nPosIva<>0
					aConIva[nPosIva][2]:=aConIva[nPosIva][2]+(SF2->F2_VALIMP1)
					aConIva[nPosIva][3]:=aConIva[nPosIva][3]+(SF2->F2_BASIMP1)
				Else
					Aadd(aConIva,{SF2->F2_SERIE,SF2->F2_VALIMP1,SF2->F2_BASIMP1})
				Endif
				lRetSerie	:=	.T.
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Obter o Valor do Imposto e Base baseando se no rateio do valor ³
				//³ do titulo pelo total da Nota Fiscal.                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				SD2->(DbSetOrder(3))
				If lMsFil
					SD2->(MsSeek(SF2->F2_MSFIL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
				Else
					SD2->(MsSeek(xFilial("SD2",SE2->E2_FILORIG)+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
				EndIf
				If SD2->(Found())
					Do while Iif(lMsFil,SD2->D2_MSFIL,xFilial("SD2",SE2->E2_FILORIG))==SD2->D2_FILIAL.And.SF2->F2_DOC==SD2->D2_DOC.AND.;
						SF2->F2_SERIE==SD2->D2_SERIE.AND.SF2->F2_CLIENTE==SD2->D2_CLIENTE;
						.AND.SF2->F2_LOJA==SD2->D2_LOJA.AND.!SD2->(EOF())

						If AllTrim(SD2->D2_ESPECIE)<>AllTrim(SF2->F2_ESPECIE)
							SD2->(DbSkip())
							Loop
						Endif
						aImpInf := TesImpInf(SD2->D2_TES)
						lTESNoExen := aScan(aImpInf,{|x| "IV" $ AllTrim(x[1])}) <> 0
						If !lTESNoExen
							SD2->(DbSkip())
							Loop
						EndIf
						SB1->(DbSetOrder(1))
						If !Empty(SD2->D2_CF)
							nPosIva:=ASCAN(aConIva,{|x| x[1]==SD2->D2_CF})
							If nPosIva<>0
								If SD2->(ColumnPos("D2_IVAFRET"))>0  .And.  SD2->(ColumnPos("D2_IVAGAST"))>0  .And. SD2->(ColumnPos("D2_BAIVAGA"))>0   .And.  SD2->(ColumnPos("D2_BAIVAFR"))>0
									aConIva[nPosIva][2]:=aConIva[nPosIva][2]+((aConIva[nPosIva][4] * (SD2->D2_TOTAL ) )- ((SD2->D2_IVAFRET+SD2->D2_IVAGAST)))
									aConIva[nPosIva][3]:=aConIva[nPosIva][3]+((SD2->D2_TOTAL ) - ((SD2->D2_BaIVAFR+SD2->D2_BaIVAGA)) )
								Else
									aConIva[nPosIva][2]:=aConIva[nPosIva][2]+(aConIva[nPosIva][4] * (SD2->D2_TOTAL ) )
									aConIva[nPosIva][3]:=aConIva[nPosIva][3]+(SD2->D2_TOTAL )
								EndIf
							Else
								If  lCalRep
									aImpInf := TesImpInf(SD2->D2_TES)
									For nI := 1 To Len(aImpInf)
										If  "IV"$Trim(aImpInf[nI][01]) .And. aImpInf[nI][14] == "N";
											.And. aImpInf[nI][15] == "I" .And. aImpInf[nI][16] == "3"
											Aadd(aConIva,{SD2->D2_CF,SD2->(FieldGet(ColumnPos(aImpInf[nI][02]))),SD2->(FieldGet(ColumnPos(aImpInf[nI][07]))), (SD2->(FieldGet(ColumnPos(aImpInf[nI][10]))) /100)})
										 EndIf
									Next
								Else
									SFF->(DbSetOrder(5))
									If SFF->(MsSeek(xFilial("SFF")+"IVR"))
										nPerc:=0
										lAchou:=.F.
										While SFF->(!EOF() ).and. (xFilial("SFF")+"IVR") ==(SFF->FF_FILIAL+SFF->FF_IMPOSTO) .And.  !lAchou
											If (Alltrim(SFF->FF_SERIENF)==SubStr(Alltrim(PadR(SD2->D2_SERIE,nTamSer)),1,1)  .And.  SD2->D2_CF==  SFF->FF_CFO_V)
												lAchou:=.T.
												nPerc:=SFF->FF_ALIQ
											Else
												SFF->(DbSkip())
											EndIf
										EndDo

										If SD2->(ColumnPos("D2_IVAFRET"))>0  .And.  SD2->(ColumnPos("D2_IVAGAST"))>0  .And. SD2->(ColumnPos("D2_BAIVAGA"))>0   .And.  SD2->(ColumnPos("D2_BAIVAFR"))>0
											Aadd(aConIva,{SD2->D2_CF,(((nPerc /100) * Iif(nParcela == 0,(SD2->D2_TOTAL ),nParcela))- (SD2->D2_IVAFRET+SD2->D2_IVAGAST)),((SD2->D2_TOTAL )- (SD2->D2_BaIVAFR +SD2->D2_BaIVAGA)), (nPerc /100)})
										Else
											Aadd(aConIva,{SD2->D2_CF,((nPerc /100) * Iif(nParcela == 0,(SD2->D2_TOTAL ),nParcela)) ,(SD2->D2_TOTAL ), (nPerc /100)})
										EndIf
									EndIf
								EndIf
							EndIF
						ElseIf SB1->(MsSeek(Iif(lMsFil .And. !Empty(xFilial("SB1")),SD2->D2_MSFIL,xFilial("SB1")) + SD2->D2_COD))
							nPosIva:=ASCAN(aConIva,{|x| x[1]==SB1->B1_CONCIVA})
							If nPosIva<>0
								aConIva[nPosIva][2]:=aConIva[nPosIva][2]+SD2->D2_VALIMP1
								aConIva[nPosIva][3]:=aConIva[nPosIva][3]+SD2->D2_BASIMP1
							Else
								Aadd(aConIva,{SB1->B1_CONCIVA,SD2->D2_VALIMP1,SD2->D2_BASIMP1})
							Endif
						Else
							nPosIva:=ASCAN(aConIva,{|x| x[1]==SA2->A2_ACTRET})
							If nPosIva<>0
								aConIva[nPosIva][2]:=aConIva[nPosIva][2]+(SD2->D2_VALIMP1)
								aConIva[nPosIva][3]:=aConIva[nPosIva][3]+(SD2->D2_BASIMP1)
							Else
								Aadd(aConIva,{SA2->A2_ACTRET,SD2->D2_VALIMP1,SD2->D2_BASIMP1})
							Endif
						Endif
						SD2->(DbSkip())
					EndDo
				Endif
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gravar Retenciones.                                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nCount:=1  to Len(aConIva)

				//Verifica se fara o calculo de IVA para fornecedores monotributistas
				dbSelectArea("SFF")
				dbGoTop()
				dbSetOrder(6)

				If MsSeek(xFilial("SFF")+"IVR"+aConIva[nCount][1])
					While SFF->(!Eof()) .And. SFF->FF_CFO_V == aConIva[nCount][1]

						If SFF->FF_ITEM $	"I1|I2" .And. SFF->FF_TIPO == 'M';
						   .And. AllTrim(SFF->FF_SERIENF) == SubStr(AllTrim(PadR(SF2->F2_SERIE,nTamSer)),1,1)

							cItem		:= SFF->FF_ITEM
							nMinimo  	:= Iif(SFF->(ColumnPos("FF_LIMITE"))>0,SFF->FF_LIMITE,0)
							nMinUnit 	:= Iif(SFF->(ColumnPos("FF_MINUNIT"))>0,SFF->FF_MINUNIT,0)

							nRecSFF := Recno()

							dbGoTop()
							MsSeek(xFilial("SFF")+"IVR")

							//Array contendo todos os CFOs com a mesma classificação
							While SFF->(!Eof())
								If SFF->FF_ITEM == cItem
									If aScan(aCf,{|x| x[2] == SFF->FF_CFO_V}) == 0
										aAdd(aCf,{SFF->FF_CFO_C,SFF->FF_CFO_V})
									Endif
								Endif
								SFF->(dbSkip())
							Enddo

							dbGoTo(nRecSFF)

							//Verifica se deve calcular IVA
							lCalcMon := F850CheckLim(cItem,aCf,cFornece,nMinimo,SF2->F2_DOC,SF2->F2_SERIE,nMinUnit,"IVA",,2,Iif(lMsFil,SF2->F2_MSFIL,""))
							Exit
						Endif
						SFF->(dbSkip())
					Enddo
				Endif

				If lCalcMon

					aConIva[nCount][2]   := Round(xMoeda(aConIva[nCount][2],SF2->F2_MOEDA,1,,5,aTxMoedas[Max(SF2->F2_MOEDA,1)][2]),MsDecimais(1))
					aConIva[nCount][3]   := Round(xMoeda(aConIva[nCount][3],SF2->F2_MOEDA,1,,5,aTxMoedas[Max(SF2->F2_MOEDA,1)][2]),MsDecimais(1))

					AAdd(aSFEIVA,array(11))
					aSFEIVA[Len(aSFEIVA)][1] := SF2->F2_DOC         		//FE_NFISCAL
					aSFEIVA[Len(aSFEIVA)][2] := SF2->F2_SERIE       		//FE_SERIE
					aSFEIVA[Len(aSFEIVA)][3] := (aConIva[nCount][3]*nProp)*nSigno	//FE_VALBASE
					aSFEIVA[Len(aSFEIVA)][4] := (aConIva[nCount][2]*nProp)*nSigno	//FE_VALIMP
					aSFEIVA[Len(aSFEIVA)][5] := Iif(lCalRet,100,SA2->A2_PORIVA)//FE_PORCRET
					aSFEIVA[Len(aSFEIVA)][6] := 0
					aSFEIVA[Len(aSFEIVA)][9] := aConIva[nCount][1]  // Gravar CFOP da operação
					If nPosCF	:=	aScan(aCf,{|x| x[2] == aConIva[nCount][1] }) == 0
						aSFEIVA[Len(aSFEIVA)][9] := aCF[nPosCF,1] //Gravar CFOP de compras
					Endif
					aSFEIVA[Len(aSFEIVA)][10] := aConIva[nCount][4]*100
					aSFEIVA[Len(aSFEIVA)][11] := " "
					If SA2->(ColumnPos("A2_IVRVCOB")) > 0 .And. SA2->(ColumnPos("A2_IVPCCOB")) > 0
						If SA2->A2_PORIVA < 100.00 .And. (Empty(SA2->A2_IVPCCOB) .Or. Dtos(SA2->A2_IVPCCOB) < Dtos(dDataBase))							
							If  lOPRotAut
								cTxtRotAut += OemToAnsi(STR0011)+SA2->A2_COD+OemToAnsi(STR0005) //"La fecha de validad para la reducción del porcentaje de la retención del IVA del proveedor ya se ha vencido. ". Ingrese una fecha valida para el proveedor en el archivo de proveedores."
								lMsErroAuto := .T.
							Else
								MsgAlert(OemToAnsi(STR0011)+SA2->A2_COD+OemToAnsi(STR0005)) //"La fecha de validad para la reducción del porcentaje de la retención del IVA del proveedor ya se ha vencido. ". Ingrese una fecha valida para el proveedor en el archivo de proveedores."
							Endif
							//Zera o array das retencoes de IVA...
							aSFEIVA := {}
							//Sai do loop...
							Exit
						EndIf

						If Dtos(SA2->A2_IVRVCOB) < Dtos(dDataBase)
							If  lOPRotAut
								cTxtRotAut += OemToAnsi(STR0004)+SA2->A2_COD+OemToAnsi(STR0005) //"Rutina de cálculo de Retención de IVA desactualizada, solicite paquete con actualizaciones."
								lMsErroAuto := .T.
							Else
								MsgAlert(OemToAnsi(STR0004)+SA2->A2_COD+OemToAnsi(STR0005)) //	"Ha vencido el perido de observacion del proveedor  "+SA2->A2_COD+". Ingrese una fecha valida para el proveedor en el archivo de proveedores."
							Endif
							//Zera o array das retencoes de IVA...
							aSFEIVA := {}
							//Sai do loop...
							Exit
						Else
							aSFEIVA[Len(aSFEIVA)][6] := aSFEIVA[Len(aSFEIVA)][4]
						EndIf

		      		EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Generar Titulo de Impuesto no Contas a Pagar.                  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aSFEIVA[Len(aSFEIVA)][7] := SE2->E2_VALOR
					aSFEIVA[Len(aSFEIVA)][8] := SE2->E2_EMISSAO

				Endif
			Next
		EndIf
	EndIf
EndIf
Return aSFEIVA


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FilImpto    º Autor ºEmanuel Villicana º Data º  11/09/15  º±±
±±ºÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Extrae de SFB informacion filtrando                        º±±
±±º          ³ FB_CLASSIF, FB_CLASSE,FB_TIPO , FB_ESTADO                  º±±
±±ºÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ General                                                    º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FilImpto(aClasif,aClase,aTipo,aEdo)
Local aRetorno	:= {}
Local cQryNLvro	:= ""
Local cTRBLVRO	:= "" 

Local cClasif	:= ""
Local cClase	:= ""
Local cEdo	:= ""
Local cTipo	:= ""
Local nI	:= 0

DEFAULT aClasif	:= {}
DEFAULT aClase	:= {}
DEFAULT aEdo	:= {}
DEFAULT aTipo	:= {}

If 	cPaisLoc == "ARG"
	//=============================================================================================
	//SFB - IMPUESTOS VARIABLES
	//=============================================================================================
	
	cQryNLvro := " SELECT DISTINCT FB_CLASSIF ,FB_CLASSE ,FB_CODIGO ,FB_DESCR , FB_CPOLVRO ,FB_TIPO TIPO, FB_ESTADO "
	cQryNLvro += " FROM "+RetsqlName("SFB")+" SFB "
	cQryNLvro += " WHERE D_E_L_E_T_='' "
	
	If Len(aClasif) > 0
		For nI := 1 to Len(aClasif)
			cClasif += Iif(Empty(cClasif),"",",") + "'" + aClasif[nI] + "'"
		Next nI
		cQryNLvro += " AND FB_CLASSIF IN ( " + cClasif +  " ) "
	Endif 
	
	If Len(aClase) > 0
		For nI := 1 to Len(aClase)
			cClase += Iif(Empty(cClase),"",",") + "'" + aClase[nI] + "'"
		Next nI
	
		cQryNLvro += " AND FB_CLASSE IN ( " + cClase +  " ) "
	Endif 
	
	If Len(aTipo) > 0
		For nI := 1 to Len(aTipo)
			cTipo += Iif(Empty(cTipo),"",",") + "'" + aTipo[nI] + "'"
		Next nI
	
		cQryNLvro += " AND FB_TIPO IN ( " + cTipo +  " ) "
	Endif 
	
	If Len(aEdo) > 0
		For nI := 1 to Len(aEdo)
			cEdo += Iif(Empty(cEdo),"",",") + "'" + aEdo[nI] + "'"
		Next nI
	
		cQryNLvro += " AND FB_ESTADO IN ( " + cEdo +  " ) "
	Endif 
	
	If Select("TRBLVRO")>0
		DbSelectArea("TRBLVRO")
		TRBLVRO->(DbCloseArea())
	Endif
	
	cTRBLVRO := ChangeQuery(cQryNLvro)
	dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cTRBLVRO ) ,"TRBLVRO", .T., .F.)
	
	DbSelectArea("TRBLVRO")
	TRBLVRO->(dbGoTop())
	If TRBLVRO->(!Eof())
		Do While TRBLVRO->(!Eof())
			aAdd(aRetorno,{TRBLVRO->FB_CODIGO,TRBLVRO->FB_DESCR,TRBLVRO->FB_CPOLVRO,TRBLVRO->FB_ESTADO,;
							 TRBLVRO->FB_CLASSIF ,TRBLVRO->FB_CLASSE })
			TRBLVRO->(DbSkip())
		End
	Endif
	
	TRBLVRO->(DbCloseArea())

EndIf

Return aRetorno


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ValImpto    º Autor ºEmanuel Villicana º Data º  11/09/15  º±±
±±ºÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Extrae el valor del impuesto generado en la factura        º±±
±±º          ³                                                            º±±
±±ºÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINRETARG - FINA085A                                       º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function ValImpto(aNrLvIVA,cTes, aTes)
Local nRetorno	:= 0
Local cAliasSD	:= Iif(cTES > "500","SD2","SD1")
Local cAliasSF	:= Iif(cTES > "500","SF2","SF1")
Local aPos	:= {} 
Local nbusca	:= 0
Local cLib	:= ""
Local nlI := 0

Default aTes := {}

For nlI:=1 To Len(aNrLvIVA)
	If aScan(aTes,{|x| x[1] == aNrLvIVA[nlI][1]}) > 0 .and. ;
		&((cAliasSD) +"->" + SubStr(cAliasSD,2,2)+"_BASIMP" + aNrLvIVA[nlI][3]) > 0
		
		cLib := "0" + aNrLvIVA[nlI][3]
		nbusca := aScan(aPos,{|x| x[1] == cLib })
		If nbusca == 0
			
			IF 	&((cAliasSF) +"->" + SubStr(cAliasSF,2,2)+"_TCOMP") = '033'  //COMERCIALIZACIÓN DE GRANOS
				nRetorno += &((cAliasSD) +"->" + SubStr(cAliasSD,2,2)+"_BASIMP" + aNrLvIVA[nlI][3])
			Else
				nRetorno += &((cAliasSD) +"->" + SubStr(cAliasSD,2,2)+"_VALIMP" + aNrLvIVA[nlI][3])
			EndIf
		
			aAdd(aPos,{cLib})
		Endif 
		
	Endif 
Next nlI

Return nRetorno


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ValBasImp    º Autor ºMarivaldo        º Data º     02/20  º±±
±±ºÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Extrae el valor del base del impuesto generado en la facturaº±±
±±º          ³                                                            º±±
±±ºÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINRETARG - FINA085A                                       º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function ValBasImp(aNrLvIVA,cTes, aTes)
Local nRetorno	:= 0
Local cAliasSD	:= Iif(cTES > "500","SD2","SD1")
Local aPos	:= {} 
Local nbusca	:= 0
Local cLib	:= ""
Local nlI := 0

Default aTes := {}

For nlI:=1 To Len(aNrLvIVA)
	If aScan(aTes,{|x| x[1] == aNrLvIVA[nlI][1]}) > 0 .and. ;
		&((cAliasSD) +"->" + SubStr(cAliasSD,2,2)+"_BASIMP" + aNrLvIVA[nlI][3]) > 0
		
		cLib := "0" + aNrLvIVA[nlI][3]
		nbusca := aScan(aPos,{|x| x[1] == cLib })
		If nbusca == 0		
			nRetorno += &((cAliasSD) +"->" + SubStr(cAliasSD,2,2)+"_BASIMP" + aNrLvIVA[nlI][3])		
			aAdd(aPos,{cLib})
		Endif 
		
	Endif 
Next nlI

Return nRetorno


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TesImpFin ³ Autor ³ Bruno Sobieski        ³ Data ³ 17.11.98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nota      ³ Se  hace copia de la funcion TesImpInf para uso modulo Fin.³±±
±±³          ³ llamado TUNJNS                                             ³±±
±±³Descri‡…o ³ Retorna um array com os dados dos impostos relacionados com³±±
±±³          ³ o tes que ‚ pasado como parametro. Usado para Impostos nas |±±
±±³          ³ Localizacoes no Exterior.                                  ³±±
±±³          ³ aImpFlag[n][1]-> Codigo do Imposto                         ³±±
±±³          ³         [n][2]-> Campo no SD1 ou SD2 onde ‚ gravado o valor|±±
±±³          ³                  imposto.                                  ³±±
±±³          ³         [n][3]-> Se o valor do imposto incide na Nota      ³±±
±±³          ³         [n][4]-> Se o valor do imposto incide na Duplicata ³±±
±±³          ³         [n][5]-> Se o valor do imposto deve ser Creditado  ³±±
±±³          ³         [n][6]-> Campo no SF1 ou SF2 onde ‚ gravado o valor|±±
±±³          ³                  imposto.                                  ³±±
±±³          ³         [n][7]-> Campo no SD1 ou SD2 onde ‚ gravada a base |±±
±±³          ³                  do imposto.                               ³±±
±±³          ³         [n][8]-> Campo no SF1 ou SF2 onde ‚ gravada a base |±±
±±³          ³                  do imposto.                               ³±±
±±³          ³         [n][9]-> Aliquota do imposto                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Parametro³ cTes -> Codigo de Entrada-Saida                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico Localizacoes.                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TesImpFin(cTes)
Local aImpFlag :={}
Local aArea	:= GetArea()
Local aAreaSFB	:= SFB->(GetArea())
Local aAreaSFC	:= SFC->(GetArea())

SFB->(DbSetOrder(1))

DbSelectArea("SFC")
DbSetOrder(1)
MsSeek(xFilial("SFC") + cTes)

While SFC->(!eof()) .and. xFilial("SFC")== FC_FILIAL .and. cTes== FC_TES
	If SFB->(MsSeek(xFilial("SFB")+SFC->FC_IMPOSTO))
		If (cTes<="500" )
			If SD1->(ColumnPos("D1_ALQIMP"+SFB->FB_CPOLVRO))  > 0
				Aadd(aImpFlag,{SFB->FB_CODIGO,"D1_VALIMP"+SFB->FB_CPOLVRO,SFC->FC_INCNOTA,SFC->FC_INCDUPL,SFC->FC_CREDITA,"F1_VALIMP"+SFB->FB_CPOLVRO,"D1_BASIMP"+SFB->FB_CPOLVRO,"F1_BASIMP"+SFB->FB_CPOLVRO,SFB->FB_ALIQ,"D1_ALQIMP"+SFB->FB_CPOLVRO,SFC->FC_PROV,SFC->FC_INCIMP})
			EndIf
		Else
			Aadd(aImpFlag,{SFB->FB_CODIGO,"D2_VALIMP"+SFB->FB_CPOLVRO,SFC->FC_INCNOTA,SFC->FC_INCDUPL,SFC->FC_CREDITA,"F2_VALIMP"+SFB->FB_CPOLVRO,"D2_BASIMP"+SFB->FB_CPOLVRO,"F2_BASIMP"+SFB->FB_CPOLVRO,SFB->FB_ALIQ,"D2_ALQIMP"+SFB->FB_CPOLVRO,SFC->FC_PROV,SFC->FC_INCIMP})
		EndIf                                               
	EndIf
	SFC->(DbSkip())
End

RestArea(aAreaSFB)
RestArea(aAreaSFC)
RestArea(aArea)

Return(aImpFlag)



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FilImpRet   º Autor ºEmanuel Villicana º Data º  02/10/15  º±±
±±ºÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Extrae importe retenido                                    º±±
±±ºÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINA085A, FINA850                                          º±±
±±ºÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FilImpRet(cFil,cProv,cLoj,cNFis,cSerie,cTipo,cOrdPag)

Local aRetorno	:= {}
Local cQryNLvro	:= ""
Local cTRBLVRO	:= ""
 
Default cOrdPag	:= ""

//=============================================================================================
//SFE - RETENCIONES IMPUESTOS
//=============================================================================================
cQryNLvro := " SELECT SUM(FE_RETENC) RETEN,"
cQryNLvro += " SUM(FE_VALBASE) BASE"
cQryNLvro += " FROM "+RetsqlName("SFE")+" SFE "
cQryNLvro += " WHERE D_E_L_E_T_='' "
cQryNLvro += " AND FE_FILIAL =  '" + cFil + "'"
cQryNLvro += " AND FE_FORNECE = '" + cProv + "'" 
cQryNLvro += " AND FE_LOJA = '" + cLoj + "'"

If Empty(cOrdPag)
	cQryNLvro += " AND FE_NFISCAL = '" + cNFis + "'"
	cQryNLvro += " AND FE_SERIE = '" + cSerie + "'"
Else
	cQryNLvro += " AND FE_ORDPAGO = '" + cOrdPag + "'"
Endif 

cQryNLvro += " AND FE_TIPO = '" + cTipo + "'"

If Select("TRBLVRO")>0
	DbSelectArea("TRBLVRO")
	TRBLVRO->(DbCloseArea())
Endif

cTRBLVRO := ChangeQuery(cQryNLvro)
dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cTRBLVRO ) ,"TRBLVRO", .T., .F.)

DbSelectArea("TRBLVRO")
TRBLVRO->(dbGoTop())
If TRBLVRO->(!Eof())
	aAdd(aRetorno,TRBLVRO->RETEN)
	aAdd(aRetorno,TRBLVRO->BASE)
Endif
TRBLVRO->(DbCloseArea())

Return aRetorno
