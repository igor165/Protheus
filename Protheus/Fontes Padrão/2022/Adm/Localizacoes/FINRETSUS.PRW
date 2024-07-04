#include "protheus.CH"
#include "FINRETSUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RetSUSDeb ºAutor  ³                    º Data ³  31/07/2020 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ RetSUSDeb  - Calculo de Ret de SUSS para NF                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ArgRetSUS (FINRETARG)                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ 1. cAgente: Agente de retención (N = No/ S = Si).          º±±
±±           ³ 2. nSigno: 1 / (-1)Si SE2->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG.º±±
±±           ³ 3. nSaldo: Saldo (valor baser o valor a bajar).            º±±
±±           ³ 4. lRetPa: No es enviado ningun valor (default .F.). LIBRE º±±
±±           ³ 5. nProp: Proporcionalización para SUSS.                   º±±
±±           ³ 6. aSUSS: Array calc SUSS cuando se tiene más de un título.º±±
±±           ³ 7. aImpCalc: Array con impuestos calculados - IVA, IB...   º±±
±±           ³ 8. nLinha: Num de línea que se está procesando.            º±±
±±           ³ 9. nControl: No es enviado ningun valor (default 0). LIBRE º±±
±±           ³ 10.aSE2: No es enviado ningun valor.    LIBRE              º±±
±±           ³ 11.cChavePOP:FJK_PREOP+Proveedor+Loja, usada en ObtReten().º±±
±±           ³ 12.cNFPOP:Num de documento(E2_NUM), usado en ObtReten().   º±±
±±           ³ 13.cSeriePOP: Serie(E2_PREFIXO), usada en ObtReten().      º±±
±±           ³ 14.dEmissao: Fch emisión CXP(E2_EMISSAO), usada ObtReten().º±±
±±           ³ 15.lOPRotAut: .T. Si es generación automática.             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RetSUSDeb(cAgente,nSigno,nSaldo,lRetPa,nProp,aSUSS,aImpCalc,nLinha,nControl,aSE2,cChavePOP,cNFPOP,cSeriePOP,dEmissao,lOPRotAut)
Local aSFESUSS  := {}
Local aAreaOld	:= {}
Local aImposto	:= {}
Local lCalcula	:= .F.
Local lCalcSus	:= .T.
Local lReSaSus	:= GetNewPar("MV_RETSUSS","N") == "S" 
Local cCampoBase:= ""
Local cTipoCalc := ""
Local cTitAnt	:= ""
Local cTpObr	:= ""
Local cConceito	:= ""
Local nBaseImp	:= 0
Local nValBase	:= 0
Local nTotSuss 	:= 0
Local nBaseRet 	:= 0
Local nRateio   := 0
Local nValRet  	:= 0
Local nTotRetSFE:= 0
Local nTotBasSFE:= 0
Local nAliqRet 	:= 0
Local nLimMInRet:= 0
Local nI		:= 1
Local nPosSUSS  := 0
Local nImpCalc	:= 0
Local nS		:= 0
Local nAcmSuss	:= 0
Local nRecSF1	:= 0 
Local nTamSer := SerieNfId('SF1',6,'F1_SERIE')
Local lTESNoExen := .F.
Local aRetPreO	:= {}
Local lSuss5 := .F.
Local lTemCuota := .F.
Local lZeraBase := .F.
Local nSaldoM1  := 0
Local nGanAnt   := 0
Local nTtlGan   := 0
Local nLinDoc   := 0
Local nGan      := 0
            
If	type("cFornece")=="U"
	cFornece	:=SE2->E2_FORNECE
	cLoja		:=SE2->E2_LOJA
EndIf

DEFAULT nProp	:= 1
DEFAULT nSigno	:=	1
DEFAULT lRetPa 	:= .F.
DEFAULT aSUSS  	:= {}
DEFAULT aImpCalc:= {}
DEFAULT nLinha	:= 0 
DEFAULT nControl:= 0
DEFAULT cChavePOP:= ""
DEFAULT cNFPOP	 := ""
DEFAULT cSeriePOP:= ""
DEFAULT dEmissao := CTOD("//")
DEFAULT lOPRotAut:= .F.

If lShowPOrd .and. Funname() == "FINA847" .and. Type("lCtaCte")<>"U" .and. lCtaCte
	Return aSFESUSS := ObtReten(cChavePOP,cNFPOP,cSeriePOP,"S",nSaldo,dEmissao,,lReSaSus)
EndIf

aArea:=GetArea()

If  lRetPa 
	Return aSFESUSS
Endif

If type("inclui")=="U"
	 inclui:=NIL
EndIf

//+---------------------------------------------------------------------+
//° Obter Impostos somente qdo a Empresa Usuario for Agente de RetenÜ§Ü¤o.°
//+---------------------------------------------------------------------+
SA2->(DbSetOrder(1))
If !lRetPa
	If lMsFil .And. !Empty(xFilial("SA2")) .And. xFilial("SF1") == xFilial("SE2")
		SA2->(MsSeek(SE2->E2_MSFIL+SE2->E2_FORNECE+SE2->E2_LOJA))
	Else
		SA2->(MsSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA))
	Endif
	If SA2->(Found()) .And. SA2->(ColumnPos("A2_DTICALS")) > 0 ;
		.And. SA2->(ColumnPos("A2_DTFCALS")) > 0  .And. !Empty(SA2->A2_DTICALS) .And. !Empty(SA2->A2_DTFCALS)
   		If  ( Dtos(dDataBase)>= Dtos(SA2->A2_DTICALS) ) .And. ( Dtos(Ddatabase) <= Dtos(SA2->A2_DTFCALS) )
   	 		If  SA2->(ColumnPos("A2_PORSUS"))>0
   	   			lCalcSus	:=.T.
		 	Else
				lCalcSus	:=.F.
			EndIf
 		EndIf
	EndIf
EndIf


If ExistBlock("F0851IMP")
	lCalcSus:=ExecBlock("F0851IMP",.F.,.F.,{"SUSS"})
EndIf

If Subs(cAgente,6,1) == "S" .And. SF1->(ColumnPos("F1_VALSUSS")) > 0 .And.   SF1->F1_VALSUSS > 0 .And. lCalcSus .And. !lRetPa
	dbSelectArea("SF1")
	dbSetOrder(1)
	If lMsfil
		nRecSF1 := FINBuscaNF(SE2->E2_MSFIL,SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_FORNECE,SE2->E2_LOJA,"SF1",.T.)
		SF1->(dbGoTo(nRecSF1))
	Else
		nRecSF1 := FINBuscaNF(xFilial("SF1",SE2->E2_FILORIG),SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_FORNECE,SE2->E2_LOJA,"SF1",.T.)
		SF1->(dbGoTo(nRecSF1))
	EndIf

	While Alltrim(SF1->F1_ESPECIE)<>AllTrim(SE2->E2_TIPO).And.!EOF()
		SF1->(DbSkip())
		Loop
	Enddo

	If (AllTrim(SF1->F1_ESPECIE) == Alltrim(SE2->E2_TIPO)) .And. ;
	   (Iif(lMsfil,SE2->E2_MSFIL,xFilial("SF1",SE2->E2_FILORIG))+SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE+SE2->E2_LOJA == ;
	   F1_FILIAL+F1_DOC+PadR(F1_SERIE,nTamSer)+F1_FORNECE+F1_LOJA) .And. (SF1->F1_VALSUSS > 0)
	   cTpObr	:=	 SF1->F1_CONCOBR
	   If SFF->(ColumnPos("FF_TPCALC")) > 0
			SA2->(DbSetOrder(1))
			If lMsFil .And. !Empty(xFilial("SA2")) .And. xFilial("SF1",SE2->E2_FILORIG) == xFilial("SE2")
				SA2->(MsSeek(SE2->E2_MSFIL+SE2->E2_FORNECE+SE2->E2_LOJA))
			Else
				SA2->(MsSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA))
			Endif
			If SA2->(Found())
				If  SA2->(ColumnPos("A2_CONCSUS")) > 0  .and. !Empty(SA2->A2_CONCSUS)// .And. (SA2->(ColumnPos("A2_PROVEMP")) > 0 .AND. SA2->A2_PROVEMP <> 1)
					dbSelectArea("SF1")
					dbSetOrder(1)
				  	If lMsFil
						nRecSF1 := FINBuscaNF(SE2->E2_MSFIL,SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_FORNECE,SE2->E2_LOJA,"SF1",.T.)
						SF1->(dbGoTo(nRecSF1))
					Else
						nRecSF1 := FINBuscaNF(xFilial("SF1",SE2->E2_FILORIG),SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_FORNECE,SE2->E2_LOJA,"SF1",.T.)
						SF1->(dbGoTo(nRecSF1))
					Endif
					SFF->(DbSetOrder(9))
					If SFF->(MsSeek(xFilial("SFF")+"SUS"+SF1->F1_CONCOBR+SF1->F1_ZONGEO))
						While  !SFF->(EOF()) .AND.  xFilial("SFF")+SF1->F1_CONCOBR+SF1->F1_ZONGEO == SFF->FF_FILIAL+ SFF->FF_GRUPO
							If Alltrim(SA2->A2_CONCSUS) ==Alltrim(SFF->FF_ITEM)
								cTipoCalc := SFF->FF_TPCALC
								Exit
							EndIf
							SFF->(DbSkip())
						End
					EndIf
				//ColumnPos adicionado pois não foi encontrado a origem da criação deste campo – NÃO RETIRAR
				ElseIf SA2->(ColumnPos("A2_PROVEMP")) > 0 .And.  SA2->A2_PROVEMP == 1
			 		SFF->(DbSetOrder(9))
					If SFF->(MsSeek(xFilial("SFF")+"SUS"+Space(TamSX3("FF_GRUPO")[1])))
						cTipoCalc := SFF->FF_TPCALC				   
					EndIf
	
				Endif
			Endif
		EndIf
		//Solamente si esta configurado para el concepto 5 de SUSS y con el tipo de calculo en 3 puede calcular.
		If cTipoCalc == "3" .And. AllTrim(SFF->FF_ITEM) == "5" .And. AllTrim(SA2->A2_CONCSUS) == "5"
			lSuss5 := .T.
			cConceito 	:= SFF->FF_ITEM
		EndIf
		If cTipoCalc == "2"
			nValRet := Round(xMoeda(SF1->F1_VALSUSS,SF1->F1_MOEDA,1,SF1->F1_DTDIGIT,5),MsDecimais(1))
			SFE->(dbSetOrder(4))
			If SFE->(MsSeek(xFilial("SFE")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE))
				cChaveSFE := SFE->FE_FILIAL+SFE->FE_FORNECE+SFE->FE_LOJA+SFE->FE_NFISCAL+SFE->FE_SERIE
				While !SFE->(Eof()) .And. cChaveSFE == xFilial("SFE")+SFE->FE_FORNECE+SFE->FE_LOJA+SFE->FE_NFISCAL+SFE->FE_SERIE
					If Month(SFE->FE_EMISSAO) != Month(dDataBase) .Or.YEAR(SFE->FE_EMISSAO)!=Year(dDataBase) .Or.;
						!(SFE->FE_TIPO $"U|S")
						SFE->(dbSkip())
						Loop
					EndIf
					nValRet 	-= SFE->FE_RETENC
					SFE->(dbSkip())
				End
    		Endif
			IF SA2->A2_CONDO=='1'
				SFE->(dbSetOrder(5))
				If SFE->(MsSeek(xFilial("SFE")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE))
					cChaveSFE := SFE->FE_FILIAL+SFE->FE_FORCOND+SFE->FE_LOJCOND+SFE->FE_NFISCAL+SFE->FE_SERIE
					While !SFE->(Eof()) .And. cChaveSFE == xFilial("SFE")+SFE->FE_FORCOND+SFE->FE_LOJCOND+SFE->FE_NFISCAL+SFE->FE_SERIE
						If Month(SFE->FE_EMISSAO) != Month(dDataBase) .Or.YEAR(SFE->FE_EMISSAO)!=Year(dDataBase) .Or.;
							!(SFE->FE_TIPO $"U|S")
							SFE->(dbSkip())
							Loop
						EndIf
						nValRet 	-= SFE->FE_RETENC
						SFE->(dbSkip())
					End
	    		Endif
			Endif
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Obter o Valor do Imposto e Base baseando se no rateio do valor ³
			//³ do titulo pelo total da Nota Fiscal.                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nRateio := Round(xMoeda(nSaldo,SE2->E2_MOEDA,1,,5,aTxMoedas[Max(SE2->E2_MOEDA,1)][2]),MsDecimais(1))/Round(xMoeda(SF1->F1_VALBRUT,SF1->F1_MOEDA,1,,5,aTxMoedas[Max(SE2->E2_MOEDA,1)][2]),MsDecimais(1))
		 	nValRet := Round(xMoeda(SF1->F1_VALSUSS,SF1->F1_MOEDA,1,,5,aTxMoedas[Max(SE2->E2_MOEDA,1)][2]),MsDecimais(1)) * nRateio
			nSaldoM1 :=  Round(xMoeda(nSaldo,SF1->F1_MOEDA,1,,5,aTxMoedas[Max(SE2->E2_MOEDA,1)][2]),MsDecimais(1)) * nRateio
		Endif
		If nValRet != 0 .And. lSuss5
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gravar Retenciones.                                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AAdd(aSFESUSS,array(15))
			aSFESUSS[Len(aSFESUSS)][1] := SF1->F1_DOC         		     //FE_NFISCAL
			aSFESUSS[Len(aSFESUSS)][2] := SF1->F1_SERIE       		     //FE_SERIE
			aSFESUSS[Len(aSFESUSS)][3] := nSaldoM1*nProp	                     //FE_VALBASE
			aSFESUSS[Len(aSFESUSS)][4] := nSaldoM1*nProp	                     //FE_VALIMP
			aSFESUSS[Len(aSFESUSS)][5] := Round((nValRet*100)/nSaldoM1,2)//FE_PORCRET
			aSFESUSS[Len(aSFESUSS)][6] := nValRet*nProp
			aSFESUSS[Len(aSFESUSS)][7] := 0     						// FE_ALIQ
			aSFESUSS[Len(aSFESUSS)][8] := cConceito                   	// FE_CONCEPT
			aSFESUSS[Len(aSFESUSS)][9] := cTipoCalc            		// Tipo Calculo - ajuste de retenÜ§Ü£o pot total
			aSFESUSS[Len(aSFESUSS)][10]:= cTpObr
			aSFESUSS[Len(aSFESUSS)][11]:= SE2->E2_FORNECE
			aSFESUSS[Len(aSFESUSS)][12]:= SE2->E2_LOJA
			aSFESUSS[Len(aSFESUSS)][13]:= IIf(lReSaSus ,aSFESUSS[Len(aSFESUSS)][4], 0)
			aSFESUSS[Len(aSFESUSS)][14] := SF1->F1_ESPECIE
			aSFESUSS[Len(aSFESUSS)][15] := nLimMInRet
		Endif
		
		If !lSuss5
			 
			If  lOPRotAut
				cTxtRotAut += OemToAnsi(OemToAnsi(STR0003) + SA2->A2_COD + OemToAnsi(STR0004)) //"El proveedor " ### " no cuenta con la configuración necesaria para calcular la retención de SUSS a partir del documento origen. Indique concepto y/o tipo cálculo correspondiente a valor informado."
				lMsErroAuto := .T.
			Else
				Aviso(OemToAnsi(STR0001),OemToAnsi(STR0003) + SA2->A2_COD + OemToAnsi(STR0004),{OemToAnsi(STR0002)}) //"El proveedor " ### " no cuenta con la configuración necesaria para calcular la retención de SUSS a partir del documento origen. Indique concepto y/o tipo cálculo correspondiente a valor informado."				
			Endif
		EndIf
	EndIf
ElseIf  Subs(cAgente,6,1) == "S" .And. lCalcSus .And.( ( SA2->(ColumnPos("A2_PROVEMP")) > 0  .or.  SA2->(ColumnPos("A2_CONCSUS")) > 0)) ;
	.And. SIX->(MsSeek('SFF9'))
	If !lRetPa
		SA2->(DbSetOrder(1))
		If lMsFil .And. !Empty(xFilial("SA2")) .And. xFilial("SF1") == xFilial("SE2")
			SA2->(MsSeek(SE2->E2_MSFIL+SE2->E2_FORNECE+SE2->E2_LOJA))
		Else
			SA2->(MsSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA))
		Endif
		If SA2->(Found())
			If SA2->(ColumnPos("A2_CONCSUS")) > 0 .and. !Empty(SA2->A2_CONCSUS)
				dbSelectArea("SF1")
				dbSetOrder(1)
				If lMsfil
			 		nRecSF1 := FINBuscaNF(SE2->E2_MSFIL,SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_FORNECE,SE2->E2_LOJA,"SF1",.T.)
					SF1->(dbGoTo(nRecSF1))
		  		Else
			  		nRecSF1 := FINBuscaNF(xFilial("SF1",SE2->E2_FILORIG),SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_FORNECE,SE2->E2_LOJA,"SF1",.T.)
					SF1->(dbGoTo(nRecSF1))
		  		EndIf
				nVRetSUSS	:= Iif( lReSaSus, SF1->F1_RETSUSS, 0 ) 
				nSRetSUSS	:= Iif( lReSaSus, SF1->F1_SALSUSS, 0 )
	   			cTpObr	:=	 SF1->F1_CONCOBR
	   			SFF->(DbSetOrder(9))
				If SFF->(MsSeek(xFilial("SFF")+"SUS"+SF1->F1_CONCOBR+SF1->F1_ZONGEO))
					While  !SFF->(EOF()) .AND.  xFilial("SFF")+SF1->F1_CONCOBR+SF1->F1_ZONGEO == SFF->FF_FILIAL+ SFF->FF_GRUPO
						If Alltrim(SA2->A2_CONCSUS) ==Alltrim(SFF->FF_ITEM)
							nAliqRet := SFF->FF_ALIQ   / 100
							nLimMInRet:=SFF->FF_IMPORTE
							lCalcula:=.T.
							cConceito 	:= SFF->FF_ITEM
							If SFF->(ColumnPos("FF_TPCALC")) > 0
								cTipoCalc := SFF->FF_TPCALC
							Endif
							Exit
						EndIf
						SFF->(DbSkip())
					End
				EndIf
		 	ElseIf SA2->(ColumnPos("A2_PROVEMP")) > 0 .And.  SA2->A2_PROVEMP == 1
		 		SFF->(DbSetOrder(9))
				If SFF->(MsSeek(xFilial("SFF")+"SUS"+Space(TamSX3("FF_GRUPO")[1])))
					nAliqRet := SFF->FF_ALIQ   / 100
					nLimMInRet:=SFF->FF_IMPORTE
					If SFF->(ColumnPos("FF_TPCALC")) > 0
						cTipoCalc := SFF->FF_TPCALC
					Endif
				Else
					aAreaOld:= GetArea()
					DbSelectArea("SFF")
					RecLock("SFF",.T.)
					Replace FF_FILIAL with xFilial("SFF")
					Replace FF_ALIQ 	with 2
					Replace FF_IMPORTE	with 39.99
					Replace FF_IMPOSTO	with "SUS"
					Replace FF_CONCEPT	with "SISTEMA UNICO DE LA SEGURIDAD SOCIAL (SUSS). RESOLUCION GENERAL 1784"
					MsUnlock()
					RestArea(aAreaOld)
					nAliqRet := SFF->FF_ALIQ   / 100
					nLimMInRet:=SFF->FF_IMPORTE
				EndIf
				lCalcula:=.T.
			EndIf
	        
	       //Si el concepto es 5, no debe de calcular SUSS.
			If AllTrim(SA2->A2_CONCSUS) == "5"
				lCalcula := .F.
			EndIf
		EndIf
		If lCalcula
   		cTpObr	:=	 SF1->F1_CONCOBR
			SD1->(DbSetOrder(1))
			If lMsfil
				SD1->(MsSeek(SF1->F1_MSFIL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
			Else
				SD1->(MsSeek(xFilial("SD1",SE2->E2_FILORIG)+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
			EndIf
			If SD1->(Found())
				Do while Iif(lMsfil, SD1->D1_MSFIL, xFilial("SD1",SE2->E2_FILORIG)) == SD1->D1_FILIAL .And. SF1->F1_DOC == SD1->D1_DOC .AND. ;
					SF1->F1_SERIE == SD1->D1_SERIE .AND. SF1->F1_FORNECE == SD1->D1_FORNECE ;
					.AND. SF1->F1_LOJA == SD1->D1_LOJA .AND. !SD1->(EOF())
					If AllTrim(SD1->D1_ESPECIE)<>AllTrim(SF1->F1_ESPECIE)
						SD1->(DbSkip())
						Loop
					Endif
					aImposto:=DefImposto(SD1->D1_TES)
					lTESNoExen := aScan(aImposto,{|x| "IV" $ AllTrim(x[1])}) <> 0
					If !lTESNoExen
						SD1->(DbSkip())
						Loop
					EndIf

					For nI:=1 to Len(aImposto)
						If Subs(aImposto[nI][1],1,2)="IV"
							aAreaSD1:=SD1->(GetArea())
							dbSelectArea("SFB")
							SFB->(DbSetOrder(1))
							If SFB->(MsSeek(xFilial("SFB")+aImposto[nI][1])) .And. SFB->FB_CLASSE=="I"
								RestArea(aAreaSD1)
								cCampoBase:="SD1->D1_"+ aImposto[nI][7]
								nBaseImp:=nBaseImp+ &cCampoBase
							EndIf

						EndIf
					Next
			            // Verificar se o Item tem IVA, caso contrario abate da base de calculo do SUSS

					SD1->(DbSkip())
			    EndDo
			EndIf
			 //Levanta quanto ja foi retido para a factura corrente, para em seguida
						//abater do total calculado para retencao.
			SFE->(dbSetOrder(4))

			If SA2->(ColumnPos("A2_CONCSUS")) > 0 .And. SA2->A2_CONCSUS =="1"
				If SFE->(MsSeek(xFilial("SFE")+SF1->F1_FORNECE+SF1->F1_LOJA))
					cChaveSFE := SFE->FE_FILIAL+SFE->FE_FORNECE+SFE->FE_LOJA
					While !SFE->(Eof()) .And. cChaveSFE == xFilial("SFE")+SFE->FE_FORNECE+SFE->FE_LOJA
						If Month(SFE->FE_EMISSAO) != Month(dDataBase) .Or.YEAR(SFE->FE_EMISSAO)!=Year(dDataBase) .Or.;
							!(SFE->FE_TIPO $"U|S")
							SFE->(dbSkip())
							Loop
						EndIf
						If SFE->FE_NFISCAL+SFE->FE_SERIE == SF1->F1_DOC+SF1->F1_SERIE
							nTotRetSFE += SFE->FE_RETENC
							nTotBasSFE += SFE->FE_VALBASE					
							nBaseRet += SFE->FE_VALBASE
						Endif
						SFE->(dbSkip())
					End
				EndIf

				IF SA2->A2_CONDO=='1'
					If lShowPOrd .and. TableInDic("FVC") .and. Funname() == "FINA855"
						DBSELECTAREA("FVC")
						FVC->(DBSETORDER(3)) //FVC_FILIAL+FVC_FORNEC+FVC_LOJA+FVC_NFISC+FVC_SERIE+FVC_TIPO+FVC_CONCEP
						If FVC->(MsSeek(xFilial("FVC")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC))
							While FVC->(!Eof()) .and. FVC->(FVC_FORNEC+FVC_LOJA+FVC_NFISC) == SF1->(F1_FORNECE+F1_LOJA+F1_DOC)
								If  Iif(Inclui,.T.,FJK->FJK_PREOP != FVC->FVC_PREOP)
									If AllTrim(FVC->FVC_TIPO) $ "U|S" .and. FVC->FVC_RETENC > 0 .and. FVC->FVC_SERIE == SF1->F1_SERIE
										AADD(aRetPreO,FVC->(FVC_FORNEC+FVC_LOJA+FVC_NFISC+FVC->FVC_SERIE+FVC_PARCEL))
										nTotRetSFE += FVC->FVC_RETENC
										nTotBasSFE += FVC->FVC_VALBAS
										nBaseRet += FVC->FVC_VALBAS
									EndIf
								Endif
								FVC->(dbSkip())
							Enddo
						EndIf	
					EndIf
					SFE->(dbSetOrder(5))
					If SFE->(MsSeek(xFilial("SFE")+SA2->A2_COD+SA2->A2_LOJA))
						While !SFE->(Eof()) .And. SFE->FE_FILIAL  == xFilial("SFE");
							.And. SFE->FE_FORCOND == SA2->A2_COD;
							.And. SFE->FE_LOJCOND == SA2->A2_LOJA
							If Month(SFE->FE_EMISSAO) != Month(dDataBase) .Or.YEAR(SFE->FE_EMISSAO)!=Year(dDataBase) .Or.;
								!(SFE->FE_TIPO $"U|S")
								SFE->(dbSkip())
								Loop
							EndIf

							//Base retida para o tÜ­tulo
							If SFE->FE_NFISCAL+SFE->FE_SERIE == SF1->F1_DOC+SF1->F1_SERIE
								If lShowPOrd .and. TableInDic("FVC") .and. Funname() == "FINA855"
									If Ascan(aRetPreO,{|x| x == SFE->(SFE->FE_FORNECE+SFE->FE_LOJA+SFE->FE_NFISCAL+SFE->FE_SERIE+SFE->FE_PARCELA) }) == 0
										nTotRetSFE += SFE->FE_RETENC
										nTotBasSFE += SFE->FE_VALBASE
										nBaseRet += SFE->FE_VALBASE
									EndIf
								Else
									nTotRetSFE += SFE->FE_RETENC
									nTotBasSFE += SFE->FE_VALBASE					
									nBaseRet += SFE->FE_VALBASE
								EndIf
							Endif
							SFE->(dbSkip())
						End
		            Endif
				Endif

			ElseIf SA2->(ColumnPos("A2_CONCSUS")) > 0 .And. SA2->A2_CONCSUS == "4"
				If lShowPOrd .and. TableInDic("FVC") .and. Funname() == "FINA855"
					DBSELECTAREA("FVC")
					FVC->(DBSETORDER(3)) //FVC_FILIAL+FVC_FORNEC+FVC_LOJA+FVC_NFISC+FVC_SERIE+FVC_TIPO+FVC_CONCEP
					If  FVC->(MsSeek(xFilial("FVC")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC))
						While FVC->(!Eof()) .and. FVC->(FVC_FORNEC+FVC_LOJA+FVC_NFISC) == SF1->(F1_FORNECE+F1_LOJA+F1_DOC)
							If  Iif(Inclui,.T.,FJK->FJK_PREOP != FVC->FVC_PREOP)
								If AllTrim(FVC->FVC_TIPO) $ "U|S" .and. FVC->FVC_RETENC > 0 .and. FVC->FVC_SERIE == SF1->F1_SERIE
									AADD(aRetPreO,FVC->(FVC_FORNEC+FVC_LOJA+FVC_NFISC+FVC->FVC_SERIE+FVC_PARCEL))
									nTotRetSFE += FVC->FVC_RETENC
									nTotBasSFE += FVC->FVC_VALBAS
									nBaseRet += FVC->FVC_VALBAS
								EndIf
							Endif
							FVC->(dbSkip())
						Enddo
					EndIf	
				EndIf
				If SFE->(MsSeek(xFilial("SFE")+SF1->F1_FORNECE+SF1->F1_LOJA))
					cChaveSFE := SFE->FE_FILIAL+SFE->FE_FORNECE+SFE->FE_LOJA
					While !SFE->(Eof()) .And. cChaveSFE == xFilial("SFE")+SFE->FE_FORNECE+SFE->FE_LOJA
						If Year(SFE->FE_EMISSAO) != Year(dDataBase) .Or. !(SFE->FE_TIPO $"U|S")
							SFE->(dbSkip())
							Loop
						EndIf
						If SFE->FE_NFISCAL+SFE->FE_SERIE == SF1->F1_DOC+SF1->F1_SERIE
							If lShowPOrd .and. TableInDic("FVC") .and. Funname() == "FINA855"
								If Ascan(aRetPreO,{|x| x == SFE->(SFE->FE_FORNECE+SFE->FE_LOJA+SFE->FE_NFISCAL+SFE->FE_SERIE+SFE->FE_PARCELA) }) == 0
									nTotRetSFE += SFE->FE_RETENC
									nTotBasSFE += SFE->FE_VALBASE
									nBaseRet += SFE->FE_VALBASE
								EndIf
							Else
								nTotRetSFE += SFE->FE_RETENC
								nTotBasSFE += SFE->FE_VALBASE
								nBaseRet += SFE->FE_VALBASE
							EndIf
						Endif
						SFE->(dbSkip())
					End
				EndIf
				IF SA2->A2_CONDO=='1'

					SFE->(dbSetOrder(5))
					If SFE->(MsSeek(xFilial("SFE")+SA2->A2_COD+SA2->A2_LOJA))
						While !SFE->(Eof()) .And. SFE->FE_FILIAL  == xFilial("SFE");
							.And. SFE->FE_FORCOND == SA2->A2_COD;
							.And. SFE->FE_LOJCOND == SA2->A2_LOJA
							If Year(SFE->FE_EMISSAO) != Year(dDataBase) .Or. !(SFE->FE_TIPO $"U|S")
								SFE->(dbSkip())
								Loop
							EndIf
							If SFE->FE_NFISCAL+SFE->FE_SERIE == SF1->F1_DOC+SF1->F1_SERIE
							nTotRetSFE += SFE->FE_RETENC
							nTotBasSFE += SFE->FE_VALBASE
							nBaseRet = SFE->FE_VALBASE
							Endif
							
							SFE->(dbSkip())
						End
					Endif
	            Endif


			Else
				If lShowPOrd .and. TableInDic("FVC") .and. Funname() == "FINA855"
					DBSELECTAREA("FVC")
					FVC->(DBSETORDER(3)) //FVC_FILIAL+FVC_FORNEC+FVC_LOJA+FVC_NFISC+FVC_SERIE+FVC_TIPO+FVC_CONCEP
					If FVC->(MsSeek(xFilial("FVC")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC))
						While FVC->(!Eof()) .and. FVC->(FVC_FORNEC+FVC_LOJA+FVC_NFISC) == SF1->(F1_FORNECE+F1_LOJA+F1_DOC)
							If  Iif(Inclui,.T.,FJK->FJK_PREOP != FVC->FVC_PREOP)
								If AllTrim(FVC->FVC_TIPO) $ "U|S" .and. FVC->FVC_RETENC > 0 .and. FVC->FVC_SERIE == SF1->F1_SERIE
									AADD(aRetPreO,FVC->(FVC_FORNEC+FVC_LOJA+FVC_NFISC+FVC->FVC_SERIE+FVC_PARCEL))
									nTotRetSFE += FVC->FVC_RETENC
									nTotBasSFE += FVC->FVC_VALBAS
									nBaseRet := nTotBasSFE
								EndIf
							Endif
							FVC->(dbSkip())
						Enddo
					EndIf	
				EndIf
				SFE->(dbSetOrder(4))
				If SFE->(MsSeek(xFilial("SFE")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE))
					cChaveSFE := SFE->FE_FILIAL+SFE->FE_FORNECE+SFE->FE_LOJA+SFE->FE_NFISCAL+SFE->FE_SERIE
					While !SFE->(Eof()) .And. cChaveSFE == xFilial("SFE")+SFE->FE_FORNECE+SFE->FE_LOJA+SFE->FE_NFISCAL+SFE->FE_SERIE
						If Month(SFE->FE_EMISSAO) != Month(dDataBase) .Or.YEAR(SFE->FE_EMISSAO)!=Year(dDataBase) .Or.;
							!(SFE->FE_TIPO $"U|S")
							SFE->(dbSkip())
							Loop
						EndIf
						If lShowPOrd .and. TableInDic("FVC") .and. Funname() == "FINA855"
							If Ascan(aRetPreO,{|x| x == SFE->(SFE->FE_FORNECE+SFE->FE_LOJA+SFE->FE_NFISCAL+SFE->FE_SERIE+SFE->FE_PARCELA) }) == 0
								nTotRetSFE += SFE->FE_RETENC
								nTotBasSFE += SFE->FE_VALBASE
								nBaseRet := nTotBasSFE
							EndIf
						Else
							nTotRetSFE += SFE->FE_RETENC
							nTotBasSFE += SFE->FE_VALBASE
							nBaseRet := nTotBasSFE
						EndIf
						SFE->(dbSkip())
					End

				EndIf
			EndIf

		    If SA2->(ColumnPos("A2_CONCSUS")) > 0 .And. SA2->A2_CONCSUS $ "1|4"
		    	nTotBSUSS:= nTotBasSFE
		    	nLimiteSUSS:= nLimMInRet
		    	If SA2->A2_CONCSUS $ "1|4"
				 	For nI:= 1 to Len(aSUSS)
					   If len(aSuss[nI]) >10 .and. SE2->E2_FORNECE==aSuss[nI][11] .And. SE2->E2_LOJA==aSuss[nI][12]
						nTotRetSFE += Iif( aSUSS[nI][6] == 0,0,aSUSS[nI][4])
						nTotBasSFE += aSUSS[nI][3]
	
						If aSUSS[nI][1]+aSUSS[nI][2]+aSUSS[nI][14] == SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_ESPECIE
							nBaseRet += aSUSS[nI][3]
						Endif
	
						cTitAnt := aSUSS[nI][1]+aSUSS[nI][2]
					   EndIf
					Next
				EndIf
			Endif
			nLimiteSUSS:= nLimMInRet
			DbselectArea("SF1")
			While Alltrim(SF1->F1_ESPECIE)<>AllTrim(SE2->E2_TIPO).And.!EOF()
				SF1->(DbSkip())
				Loop
			Enddo

			If (AllTrim(SF1->F1_ESPECIE) == Alltrim(SE2->E2_TIPO)) .And. ;
				(Iif(lMsfil,SF1->F1_MSFIL,xFilial("SF1",SE2->E2_FILORIG))+SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE+SE2->E2_LOJA == ;
				F1_FILIAL+F1_DOC+PadR(F1_SERIE,nTamSer)+F1_FORNECE+F1_LOJA)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Obter o Valor do Imposto e Base baseando se no rateio do valor ³
				//³ do titulo pelo total da Nota Fiscal.                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      			cTpObr	:=	 SF1->F1_CONCOBR

				nRateio := xMoeda(nSaldo,SE2->E2_MOEDA,1,SF1->F1_DTDIGIT,5)/xMoeda(SF1->F1_VALBRUT,SF1->F1_MOEDA,1,SF1->F1_DTDIGIT,5)

				If cTipoCalc == "2"
					nPosSUSS := aScan(aSUSS,{|x| x[1] == SF1->F1_DOC .And. x[2] == SF1->F1_SERIE})
				Endif
				If cPaisLoc == "ARG" .AND. cTipoCalc == "1" // Zero a base caso o campo FF_TPCALC esteja com 1, RG1784
					nValBase 	:= 0
				Else
					nValBase 	:= xMoeda((nBaseImp*Iif(cTipoCalc == "2",1,nRateio)),SF1->F1_MOEDA,1,dDatabase,,aTxMoedas[Max(SF1->F1_MOEDA,1)][2])
				EndIf
				nValtotBas	:= nValBase
			    If  ( Dtos(dDataBase)>= Dtos(SA2->A2_DTICALS) .and.  Dtos(Ddatabase) <= Dtos(SA2->A2_DTFCALS) ) .Or. (Empty(SA2->A2_DTICALS).and.Dtos(Ddatabase) <= Dtos(SA2->A2_DTFCALS)) .Or.(Empty(SA2->A2_DTFCALS) .and. Dtos(dDataBase)>= Dtos(SA2->A2_DTICALS) )
					nValRetCac	:= (nValtotBas * nAliqRet)*(SA2->A2_PORSUS/100)
					nValorRet	:= ABs(nValRetCac) 
				Else
					nValRetCac	:= nValtotBas * nAliqRet
					nValorRet	:= ABs(nValRetCac)
				EndIf 
				If cTipoCalc == "2" 
					IF cPaisLoc == "ARG"
						For nI:= 1 to Len(aSUSS) //Verifica se tem retenção existente para a mesma fatura nos itens selecionados para quitar o valor.
							If len(aSuss[nI]) >10 .and. SE2->E2_FORNECE==aSuss[nI][11] .And. SE2->E2_LOJA==aSuss[nI][12] .and. SE2->E2_PREFIXO==aSuss[nI][2] .And. SE2->E2_NUM==aSuss[nI][1] .And. Alltrim(SE2->E2_TIPO) == Alltrim(aSuss[nI][14])
								nValorRet -= aSuss[nI][4]
								IF nValorRet <= 0 
									lTemCuota := .T.
								Else 
									lZeraBase := .T.
								EndIF
							EndIf
						Next
						SFE->(dbSetOrder(4)) // Verifico se existe retenção na tabela SFE para quitar o valor.
						If SFE->(MsSeek(xFilial("SFE")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE+"S"+cConceito))
							cChaveSFE := SFE->FE_FILIAL+SFE->FE_FORNECE+SFE->FE_LOJA+SFE->FE_NFISCAL+SFE->FE_SERIE+"S"+cConceito
							While !SFE->(Eof()) .And. cChaveSFE == xFilial("SFE")+SFE->FE_FORNECE+SFE->FE_LOJA+SFE->FE_NFISCAL+SFE->FE_SERIE+SFE->FE_TIPO+SFE->FE_CONCEPT
								If !Empty(SFE->FE_DTESTOR) .Or. SFE->FE_RETENC < 0
									SFE->(dbSkip())
									Loop
								EndIf
								If lShowPOrd .and. TableInDic("FVC") .and. Funname() == "FINA855"
									If Ascan(aRetPreO,{|x| x == SFE->(SFE->FE_FORNECE+SFE->FE_LOJA+SFE->FE_NFISCAL+SFE->FE_SERIE+SFE->FE_PARCELA) }) <> 0
										nValorRet -= SFE->FE_RETENC
										IF nValorRet <= 0
											lTemCuota := .T.
										Else 
											lZeraBase := .T.
										EndIF
									EndIf
								Else
									nValorRet -= SFE->FE_RETENC
									IF nValorRet <= 0
										lTemCuota := .T.
									EndIF
								EndIf
								SFE->(dbSkip())
							End
						EndIf
					else
						nValorRet -= nTotRetSFE
					EndIF
				EndIf	
				//Impostos recalculados na tela - Modificar OP
				If nLinha > 0

					//Impostos calculados - IVA, IB...
					For nI := 1 to Len(aImpCalc[nLinha])
						If ValType(aImpCalc[nLinha][nI]) == "A"
							nImpCalc += aImpCalc[nLinha][nI][2]
						EndIf
					Next

					//Ganancia
					For nGan := 1 To Len(aImpCalc)
						If Len(aImpCalc[nGan]) > 0 .And. ValType(aImpCalc[nGan][1]) <> "A"
							If aImpCalc[nGan][1] == "GAN"
								nTtlGan := aImpCalc[nGan][2] - nGanAnt
								nGanAnt := aImpCalc[nGan][2]
								nLinDoc ++
								If nLinha == nLinDoc
									Exit
								EndIf
							EndIf
						EndIf
					Next
					nImpCalc += nTtlGan
				Endif

				nSaldoM1 := (Round(xMoeda(nSaldo,SE2->E2_MOEDA,1,,5,aTxMoedas[Max(SE2->E2_MOEDA,1)][2]),MsDecimais(1)) * Iif(cTipoCalc == "2",1,nRateio))

				If nValorRet+nImpCalc >= nSaldoM1 .And. cTipoCalc == "2"

					nValorRet := nSaldoM1 - nImpCalc

					//Zera o calculo caso a retencao seja negativa
					If nValorRet < 0
						nValBase 	:= 0
						nValtotBas 	:= 0
						nValRetCac	:= 0
						nValorRet	:= 0
					Endif

				Endif
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Gravar Retenciones.                                            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

				If !lTemCuota // Somente a primeira parcela da fatura grava o array as demais não gravam.
					nValorRet := Round(nValorRet,TamSX3("FE_VALIMP")[2])
					AAdd(aSFESUSS,array(15))
					aSFESUSS[Len(aSFESUSS)][1] := SF1->F1_DOC         		    //FE_NFISCAL
					aSFESUSS[Len(aSFESUSS)][2] := SF1->F1_SERIE       		    //FE_SERIE
					aSFESUSS[Len(aSFESUSS)][3] := IIF(lZeraBase,0,nValBase)	    //FE_VALBASE - Validação para
					aSFESUSS[Len(aSFESUSS)][4] := nValorRet 	                //FE_VALIMP
					aSFESUSS[Len(aSFESUSS)][5] := 100  						//FE_PORCRET
					aSFESUSS[Len(aSFESUSS)][6] := nValorRet
					aSFESUSS[Len(aSFESUSS)][7] := nAliqRet * 100		//FE_ALIQ
					aSFESUSS[Len(aSFESUSS)][8] := cConceito            // FE_CONCEPT
					aSFESUSS[Len(aSFESUSS)][9] := cTipoCalc            // Tipo Calculo - ajuste de retenÜ§Ü£o pot total
					aSFESUSS[Len(aSFESUSS)][10] := cTpObr
					aSFESUSS[Len(aSFESUSS)][11] := SE2->E2_FORNECE
					aSFESUSS[Len(aSFESUSS)][12] := SE2->E2_LOJA
					aSFESUSS[Len(aSFESUSS)][13] := IIf(lReSaSus, aSFESUSS[Len(aSFESUSS)][4],0)  
					aSFESUSS[Len(aSFESUSS)][14] := SF1->F1_ESPECIE
					aSFESUSS[Len(aSFESUSS)][15] := nLimiteSUSS
				elseIF cTipoCalc == "1" // Caso o FF_TPCALC esteja com 1 gero um array zerado e apresento mensagem que opção foi removida.
					AAdd(aSFESUSS,array(15))
					aSFESUSS[Len(aSFESUSS)][1] := SF1->F1_DOC         		    //FE_NFISCAL
					aSFESUSS[Len(aSFESUSS)][2] := SF1->F1_SERIE       		    //FE_SERIE
					aSFESUSS[Len(aSFESUSS)][3] := nValBase	                    //FE_VALBASE
					aSFESUSS[Len(aSFESUSS)][4] := nValorRet 	                //FE_VALIMP
					aSFESUSS[Len(aSFESUSS)][5] := 100  						//FE_PORCRET
					aSFESUSS[Len(aSFESUSS)][6] :=  0
					aSFESUSS[Len(aSFESUSS)][7] := 0						//FE_ALIQ
					aSFESUSS[Len(aSFESUSS)][8] := cConceito            // FE_CONCEPT
					aSFESUSS[Len(aSFESUSS)][9] := cTipoCalc            // Tipo Calculo - ajuste de retenÜ§Ü£o pot total
					aSFESUSS[Len(aSFESUSS)][10] := cTpObr
					aSFESUSS[Len(aSFESUSS)][11] := SE2->E2_FORNECE
					aSFESUSS[Len(aSFESUSS)][12] := SE2->E2_LOJA
					aSFESUSS[Len(aSFESUSS)][13] := IIf(lReSaSus, aSFESUSS[Len(aSFESUSS)][4],0)  
					aSFESUSS[Len(aSFESUSS)][14] := SF1->F1_ESPECIE
					aSFESUSS[Len(aSFESUSS)][15] := nLimiteSUSS
				EndIf
			EndIf
	 	EndIf
	EndIf
EndIf
RestArea(aArea)
Return aSFESUSS


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RetSUSCre ºAutor  ³                    º Data ³  31/07/2020 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ RetSUSCre  - Calculo de Ret de SUSS para NF                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ArgRetSU2 (FINRETARG)                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ 1. cAgente: Agente de retención (N = No/ S = Si).          º±±
±±           ³ 2. nSigno: 1 / (-1)Si SE2->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG º±±
±±           ³ 3. nSaldo: Saldo (valor baser o valor a bajar).            º±±
±±           ³ 4. nProp: Proporcionalización para SUSS.                   º±±
±±           ³ 5. aSUSS: Array calc SUSS cuando se tiene más de un título.º±±
±±           ³ 6. aImpCalc: Array con impuestos calculados - IVA, IB...   º±±
±±           ³ 7. nLinha: Num de línea que se está procesando.            º±±
±±           ³ 8. cChavePOP: FJK_PREOP+Proveedor+Loja, usada en ObtReten()º±±
±±           ³ 9. cNFPOP: Num de documento(E2_NUM), usado en ObtReten().  º±±
±±           ³ 10.cSeriePOP: Serie(E2_PREFIXO), usada en ObtReten().      º±±
±±           ³ 11.dEmissao: Fch emisión CXP(E2_EMISSAO), usada ObtReten().º±±
±±           ³ 12.lOPRotAut: .T. Si es generación automática.             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RetSUSCre(cAgente,nSigno,nSaldo,nProp,aSUSS,aImpCalc,nLinha,cChavePOP,cNFPOP,cSeriePOP,dEmissao,lOPRotAut)
LOCAL aArea	:= {}
Local aAreaSEK	:= {}
Local aAreaSF4	:= {}
Local aAreaSFE	:= {}
Local aRetTotal	:= {}
Local aRetAplic	:= {}
Local aSFESUSS  := {}
Local aAreaOld	:= {}
Local aImposto	:= {}
Local lImposto 	:= .F.
Local lCalcSus	:= .T.
Local lCalcula	:= .F.
Local lReSaSU		:= GetNewPar("MV_RETSUSS","N") == "S"
Local cConceito	:= ""
Local cTpOBR	:= ""
Local cCampoBase:= ""
Local cTipoCalc	:= ""
Local cCF	:= ""
Local cCalPA	:= .F.
Local nRateio  	:= 0
Local nValRet   := 0
Local nTotRetSFE:= 0
Local nTotBasSFE:= 0
Local nAliqRet 	:= 0
Local nLimMInRet:= 0
Local nI		:= 1
Local nBaseImp	:= 0
Local nBaseRet	:= 0
Local nPosSUSS 	:= 0
Local nVRetSUSS	:= 0
Local nSRetSUSS	:= 0
Local nAlqIVA	:= 0
Local nRecSF2	:= 0 
Local nTamSer := SerieNfId('SF2',6,'F2_SERIE')
Local lTESNoExen := .F.
Local nImpCalc 	:= 0
Local cChaveSFE2	:= ""
Local cTitAnt		:= ""
Local aRetPreO	:= {} 
Local lSuss5 := .F.
Local lReSaSus := GetNewPar("MV_RETSUSS","N") == "S" 
Local nValBase	:= 0
Local lTemCuota := .F.
Local lZeraBase := .F.
Local cBuscRef := ""
Local nSaldoM1 := 0
Local nGanAnt   := 0
Local nTtlGan   := 0
Local nLinDoc   := 0
Local nGan      := 0

If type("cFornece")=="U"
	cFornece	:=SE2->E2_FORNECE
	cLoja		:=SE2->E2_LOJA
EndIf


DEFAULT nSigno	:=	-1
DEFAULT aSUSS  	:= {}
DEFAULT aImpCalc	:= {}
DEFAULT nLinha	:= 0
DEFAULT cChavePOP:= ""
DEFAULT cNFPOP	 := ""
DEFAULT cSeriePOP:= ""
DEFAULT dEmissao := CTOD("//")
DEFAULT lOPRotAut:= .F.

If lShowPOrd .and. Funname() == "FINA847" .and. Type("lCtaCte")<>"U" .and. lCtaCte
	Return aSFESUSS := ObtReten(cChavePOP,cNFPOP,cSeriePOP,"S",nSaldo,dEmissao,,lReSaSus)
EndIf

SA2->(DbSetOrder(1))
If SA2->(MsSeek(If(lMsFil .And. !Empty(xFilial("SA2")) .And. xFilial("SF1") == xFilial("SE2"),SE2->E2_MSFIL,xFilial("SA2"))+SE2->E2_FORNECE+SE2->E2_LOJA)) .And. SA2->(ColumnPos("A2_DTICALS")) > 0 ;
	.And. SA2->(ColumnPos("A2_DTFCALS")) > 0  .And. !Empty(SA2->A2_DTICALS) .And. !Empty(SA2->A2_DTFCALS)
    If  ( Dtos(dDataBase)<= Dtos(SA2->A2_DTICALS) ) .And. ( Dtos(Ddatabase) >= Dtos(SA2->A2_DTFCALS) )
   		lCalcSus	:=.F.
    EndIf
EndIf

If ExistBlock("F0851IMP")
	lCalcSus:=ExecBlock("F0851IMP",.F.,.F.,{"SU2"})
EndIf

If Alltrim(SE2->E2_TIPO) == "PA" //.and. lReSaSU
	Return aSFESUSS
Endif

If type("inclui")=="U"
	 inclui:=NIL
EndIf

//+---------------------------------------------------------------------+
//° Obter Impostos somente qdo a Empresa Usuario for Agente de RetenÜ§Ü¤o.°
//+---------------------------------------------------------------------+
If Subs(cAgente,6,1) == "S" .And. SF2->(ColumnPos("F2_VALSUSS")) > 0 .And. SF2->F2_VALSUSS > 0   .And. lCalcSus
	dbSelectArea("SF2")
	dbSetOrder(1)
	If lMsFil
		nRecSF2 := FINBuscaNF(SE2->E2_MSFIL,SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_FORNECE,SE2->E2_LOJA,"SF2",.T.)
		SF2->(dbGoTo(nRecSF2))
	Else
		nRecSF2 := FINBuscaNF(xFilial("SF2",SE2->E2_FILORIG),SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_FORNECE,SE2->E2_LOJA,"SF2",.T.)
		SF2->(dbGoTo(nRecSF2))
	EndIf

	nVRetSUSS	:= Iif( cPaisLoc == "ARG" .and. lReSaSU, SF2->F2_RETSUSS, 0 ) 
	nSRetSUSS	:= Iif( cPaisLoc == "ARG" .and. lReSaSU, SF2->F2_SALSUSS, 0 )

	While AllTrim(SF2->F2_ESPECIE) != AllTrim(SE2->E2_TIPO) .And. !EOF()
		SF2->(DbSkip())
		Loop
	EndDo

	If (AllTrim(SF2->F2_ESPECIE) == Alltrim(SE2->E2_TIPO)) .And. ;
	   (Iif(lMsFil,SF2->F2_MSFIL,xFilial("SF2",SE2->E2_FILORIG))+SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE+SE2->E2_LOJA == ;
	   F2_FILIAL+F2_DOC+PadR(F2_SERIE,nTamSer)+F2_CLIENTE+F2_LOJA) .And. (SF2->F2_VALSUSS > 0)
	   
	   If SFF->(ColumnPos("FF_TPCALC")) > 0
			SA2->(DbSetOrder(1))
			If lMsFil .And. !Empty(xFilial("SA2")) .And. xFilial("SF2") == xFilial("SE2")
				SA2->(MsSeek(SE2->E2_MSFIL + SE2->E2_FORNECE + SE2->E2_LOJA))
			Else
				SA2->(MsSeek(xFilial("SA2") + SE2->E2_FORNECE + SE2->E2_LOJA))
			Endif
			
			If SA2->(Found())
				If  SA2->(ColumnPos("A2_CONCSUS")) > 0 .And. !Empty(SA2->A2_CONCSUS)
					DbSelectArea("SF2")
					SF2->(DbSetOrder(1))
			  		If lMsFil
				  		SF2->(MsSeek(SE2->E2_MSFIL + SE2->E2_NUM + SE2->E2_PREFIXO + SE2->E2_FORNECE + SE2->E2_LOJA))
					Else
				  		SF2->(MsSeek(xFilial("SF2") + SE2->E2_NUM + SE2->E2_PREFIXO + SE2->E2_FORNECE + SE2->E2_LOJA))
				 	EndIf
					SFF->(DbSetOrder(9))
					If SFF->(MsSeek(xFilial("SFF") + "SUS" + SF2->F2_CONCOBR + SF2->F2_ZONGEO))
						While !SFF->(EOF()) .And. xFilial("SFF") + SF2->F2_CONCOBR + SF2->F2_ZONGEO == SFF->FF_FILIAL + SFF->FF_GRUPO
							If AllTrim(SA2->A2_CONCSUS) == AllTrim(SFF->FF_ITEM)
								cTipoCalc := SFF->FF_TPCALC
								Exit
							EndIf
							SFF->(DbSkip())
						End
				    EndIf
			 	ElseIf SA2->(ColumnPos("A2_PROVEMP")) > 0 .And. SA2->A2_PROVEMP == 1
			 		SFF->(DbSetOrder(9))
					If SFF->(MsSeek(xFilial("SFF") + "SUS" + Space(TamSX3("FF_GRUPO")[1])))
						cTipoCalc := SFF->FF_TPCALC
					EndIf
				EndIf
			EndIf
		EndIf
		
		//Solamente si esta configurado para el concepto 5 de SUSS y con el tipo de calculo en 3 puede calcular.
		If cTipoCalc == "3" .And. AllTrim(SFF->FF_ITEM) == "5" .And. AllTrim(SA2->A2_CONCSUS) == "5"
			lSuss5 := .T.
			cConceito := SFF->FF_ITEM
		EndIf

		//Obtener el valor del impuesto con base al prorateo del valor del titulo por el total de la nota fiscal.
		nRateio := Round(xMoeda(nSaldo, SE2->E2_MOEDA, 1,, 5, aTxMoedas[Max(SE2->E2_MOEDA,1)][2]), MsDecimais(1)) / Round(xMoeda(SF2->F2_VALBRUT, SF2->F2_MOEDA, 1, , 5, aTxMoedas[Max(SE2->E2_MOEDA,1)][2]), MsDecimais(1))
		nValRet := Round(xMoeda(SF2->F2_VALSUSS, SF2->F2_MOEDA, 1, , 5, aTxMoedas[Max(SE2->E2_MOEDA,1)][2]), MsDecimais(1)) * nRateio * nSigno
		nSaldoM1 :=  Round(xMoeda(nSaldo, SF2->F2_MOEDA, 1, ,5, aTxMoedas[Max(SE2->E2_MOEDA,1)][2]),MsDecimais(1)) * nRateio

		If nValRet != 0 .And. lSuss5
			//Gravar Retenciones.
			AAdd(aSFESUSS,array(15))
			aSFESUSS[Len(aSFESUSS)][1] := SF2->F2_DOC         		     //FE_NFISCAL
			aSFESUSS[Len(aSFESUSS)][2] := SF2->F2_SERIE       		     //FE_SERIE
			aSFESUSS[Len(aSFESUSS)][3] := nSaldoM1*nSigno	             //FE_VALBASE
			aSFESUSS[Len(aSFESUSS)][4] := nSaldoM1*nSigno	             //FE_VALIMP
			aSFESUSS[Len(aSFESUSS)][5] := Round((nValRet*100)/nSaldoM1,2)//FE_PORCRET
			aSFESUSS[Len(aSFESUSS)][6] := nValRet
			aSFESUSS[Len(aSFESUSS)][7] := 0  							//FE_ALIQ
			aSFESUSS[Len(aSFESUSS)][8] := cConceito                   	// FE_CONCEPT
			aSFESUSS[Len(aSFESUSS)][9] := cTipoCalc            // Tipo Calculo - ajuste de retenÜ§Ü£o pot total
			aSFESUSS[Len(aSFESUSS)][10] := SF2->F2_CONCOBR
			aSFESUSS[Len(aSFESUSS)][11] := SE2->E2_FORNECE
			aSFESUSS[Len(aSFESUSS)][12] := SE2->E2_LOJA
			aSFESUSS[Len(aSFESUSS)][13] := IIf(lReSaSus ,aSFESUSS[Len(aSFESUSS)][4], 0)
			aSFESUSS[Len(aSFESUSS)][14] := SF2->F2_ESPECIE
			aSFESUSS[Len(aSFESUSS)][15] := nLimMInRet
		EndIf
	EndIf
ElseIf  Subs(cAgente,6,1) == "S" .And. lCalcSus .And.( ( SA2->(ColumnPos("A2_PROVEMP")) > 0 .or. cPaisLoc == "ARG" )) ;
	.And. SIX->(MsSeek('SFF9'))
	SA2->(DbSetOrder(1))
	If SA2->(MsSeek(If(lMsFil .And. !Empty(xFilial("SA2")) .And. xFilial("SF1") == xFilial("SE2"),SE2->E2_MSFIL,xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA)))
		If  SA2->(ColumnPos("A2_CONCSUS")) > 0 .and. !Empty(SA2->A2_CONCSUS)// .And. (SA2->(ColumnPos("A2_PROVEMP")) > 0 .AND. SA2->A2_PROVEMP <> 1)
			dbSelectArea("SF2")
			dbSetOrder(1)
	  		If lMsFil
		  		nRecSF2 := FINBuscaNF(SE2->E2_MSFIL,SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_FORNECE,SE2->E2_LOJA,"SF2",.T.)
				SF2->(dbGoTo(nRecSF2))
	  		Else
				nRecSF2 := FINBuscaNF(xFilial("SF2",SE2->E2_FILORIG),SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_FORNECE,SE2->E2_LOJA,"SF2",.T.)
				SF2->(dbGoTo(nRecSF2))
	  		EndIf
			SFF->(DbSetOrder(9))
			If SFF->(MsSeek(xFilial("SFF")+"SUS"+SF2->F2_CONCOBR+SF2->F2_ZONGEO))
				While  !SFF->(EOF()) .AND.  xFilial("SFF")+SF2->F2_CONCOBR+SF2->F2_ZONGEO == SFF->FF_FILIAL+ SFF->FF_GRUPO
					If Alltrim(SA2->A2_CONCSUS) ==Alltrim(SFF->FF_ITEM)
						nAliqRet := SFF->FF_ALIQ   / 100
						nLimMInRet:=SFF->FF_IMPORTE
						lCalcula:=.T.
						cConceito := SFF->FF_ITEM
						cTpObr 		:= Substr(SFF->FF_GRUPO,1,1)
						If SFF->(ColumnPos("FF_TPCALC")) > 0
							cTipoCalc := SFF->FF_TPCALC
						Endif
						Exit
					EndIf
					SFF->(DbSkip())
				End
		    EndIf
	 	ElseIf SA2->(ColumnPos("A2_PROVEMP")) > 0 .And.  SA2->A2_PROVEMP == 1
	 		SFF->(DbSetOrder(9))
			If SFF->(MsSeek(xFilial("SFF")+"SUS"+Space(TamSX3("FF_GRUPO")[1])))
				nAliqRet := SFF->FF_ALIQ   / 100
				nLimMInRet:=SFF->FF_IMPORTE
				If SFF->(ColumnPos("FF_TPCALC")) > 0
					cTipoCalc := SFF->FF_TPCALC
				Endif
			Else
				aAreaOld:= GetArea()
				DbSelectArea("SFF")
				RecLock("SFF",.T.)
				Replace FF_FILIAL with xFilial("SFF")
				Replace FF_ALIQ 	with 2
				Replace FF_IMPORTE	with 39.99
				Replace FF_IMPOSTO	with "SUS"
				Replace FF_CONCEPT	with "SISTEMA UNICO DE LA SEGURIDAD SOCIAL (SUSS). RESOLUCION GENERAL 1784"
				MsUnlock()
				RestArea(aAreaOld)
				nAliqRet := SFF->FF_ALIQ   / 100
				nLimMInRet:=SFF->FF_IMPORTE
			EndIf
			lCalcula:=.T.
        EndIf
		
		//Si el concepto es 5, no debe de calcular SUSS.
		If AllTrim(SA2->A2_CONCSUS) == "5"
			lCalcula := .F.
		EndIf
	EndIf
	
	If lCalcula
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
		       aImposto:=DefImposto(SD2->D2_TES)
				lTESNoExen := aScan(aImposto,{|x| "IV" $ AllTrim(x[1])}) <> 0
				If !lTESNoExen
					SD2->(DbSkip())
					Loop
				EndIf
				 
				For nI:=1 to Len(aImposto)
					If Subs(aImposto[nI][1],1,2)="IV"
						aAreaSD2:=SD2->(GetArea())
						dbSelectArea("SFB")
						SFB->(DbSetOrder(1))
						If SFB->(MsSeek(xFilial("SFB")+aImposto[nI][1])) .And. SFB->FB_CLASSE=="I"
							RestArea(aAreaSD2)
							cCampoBase:="SD2->D2_"+ aImposto[nI][7]
							nBaseImp:=nBaseImp+ &cCampoBase
						EndIf
					EndIf
				Next
				SD2->(DbSkip())
		    EndDo
		EndIf
		
		SFE->(dbSetOrder(4))

		If SA2->(ColumnPos("A2_CONCSUS")) > 0 .And. SA2->A2_CONCSUS =="1"
			If lShowPOrd .and. TableInDic("FVC") .and. Funname() == "FINA855"
				DBSELECTAREA("FVC")
				FVC->(DBSETORDER(3)) //FVC_FILIAL+FVC_FORNEC+FVC_LOJA+FVC_NFISC+FVC_SERIE+FVC_TIPO+FVC_CONCEP
				If FVC->(MsSeek(xFilial("FVC")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC))
					While FVC->(!Eof()) .and. FVC->(FVC_FORNEC+FVC_LOJA+FVC_NFISC) == SF2->(F2_CLIENTE+F2_LOJA+F2_DOC)
						If  Iif(Inclui,.T.,FJK->FJK_PREOP != FVC->FVC_PREOP)
							If AllTrim(FVC->FVC_TIPO) $ "U|S" .and. ABS(FVC->FVC_RETENC) > 0 .and. FVC->FVC_SERIE == SF2->F2_SERIE
								AADD(aRetPreO,FVC->(FVC_FORNEC+FVC_LOJA+FVC_NFISC+FVC->FVC_SERIE+FVC_PARCEL))
								nTotRetSFE += FVC->FVC_RETENC
								nTotBasSFE += FVC->FVC_VALBAS
								nBaseRet += FVC->FVC_VALBAS
							EndIf
						Endif
						FVC->(dbSkip())
					Enddo
				EndIf	
			EndIf
			If SFE->(MsSeek(xFilial("SFE")+SF2->F2_CLIENTE+SF2->F2_LOJA))
				cChaveSFE2 := SFE->FE_FILIAL+SFE->FE_FORNECE+SFE->FE_LOJA
				While !SFE->(Eof()) .And. cChaveSFE2 == xFilial("SFE")+SFE->FE_FORNECE+SFE->FE_LOJA
					If Month(SFE->FE_EMISSAO) != Month(dDataBase) .Or.YEAR(SFE->FE_EMISSAO)!=Year(dDataBase) .Or.;
						!(SFE->FE_TIPO $"U|S")
						SFE->(dbSkip())
						Loop
					EndIf
					If SFE->FE_NFISCAL+SFE->FE_SERIE == SF2->F2_DOC+SF2->F2_SERIE
						If lShowPOrd .and. TableInDic("FVC") .and. Funname() == "FINA855"
							If Ascan(aRetPreO,{|x| x == SFE->(SFE->FE_FORNECE+SFE->FE_LOJA+SFE->FE_NFISCAL+SFE->FE_SERIE+SFE->FE_PARCELA) }) == 0
								nTotRetSFE += SFE->FE_RETENC
								nTotBasSFE += SFE->FE_VALBASE
								nBaseRet += SFE->FE_VALBASE
							EndIf
						Else
							nTotRetSFE += SFE->FE_RETENC
							nTotBasSFE += SFE->FE_VALBASE					
							nBaseRet += SFE->FE_VALBASE
						EndIf
					Endif
					SFE->(dbSkip())
				End
			EndIf

			IF SA2->A2_CONDO=='1'
				SFE->(dbSetOrder(5))
				If SFE->(MsSeek(xFilial("SFE")+SA2->A2_COD+SA2->A2_LOJA))
					While !SFE->(Eof()) .And. SFE->FE_FILIAL  == xFilial("SFE");
						.And. SFE->FE_FORCOND == SA2->A2_COD;
						.And. SFE->FE_LOJCOND == SA2->A2_LOJA
						If Month(SFE->FE_EMISSAO) != Month(dDataBase) .Or.YEAR(SFE->FE_EMISSAO)!=Year(dDataBase) .Or.;
							!(SFE->FE_TIPO $"U|S")
							SFE->(dbSkip())
							Loop
						EndIf

						//Base retida para o tÜ­tulo
						If SFE->FE_NFISCAL+SFE->FE_SERIE == SF2->F2_DOC+SF2->F2_SERIE
							nTotRetSFE += SFE->FE_RETENC
							nTotBasSFE += SFE->FE_VALBASE
							nBaseRet += SFE->FE_VALBASE
						Endif
						SFE->(dbSkip())
					End
	            Endif
			Endif

		ElseIf SA2->(ColumnPos("A2_CONCSUS")) > 0 .And. SA2->A2_CONCSUS == "4"
			If lShowPOrd .and. TableInDic("FVC") .and. Funname() == "FINA855"
				DBSELECTAREA("FVC")
				FVC->(DBSETORDER(3)) //FVC_FILIAL+FVC_FORNEC+FVC_LOJA+FVC_NFISC+FVC_SERIE+FVC_TIPO+FVC_CONCEP
				If FVC->(MsSeek(xFilial("FVC")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC))
					While FVC->(!Eof()) .and. FVC->(FVC_FORNEC+FVC_LOJA+FVC_NFISC) == SF2->(F2_CLIENTE+F2_LOJA+F2_DOC)
						If  Iif(Inclui,.T.,FJK->FJK_PREOP != FVC->FVC_PREOP)
							If AllTrim(FVC->FVC_TIPO) $ "U|S" .and. ABS(FVC->FVC_RETENC) > 0 .and. FVC->FVC_SERIE == SF2->F2_SERIE
								AADD(aRetPreO,FVC->(FVC_FORNEC+FVC_LOJA+FVC_NFISC+FVC->FVC_SERIE+FVC_PARCEL))
								nTotRetSFE += FVC->FVC_RETENC
								nTotBasSFE += FVC->FVC_VALBAS
								nBaseRet += FVC->FVC_VALBAS
							EndIf
						Endif
						FVC->(dbSkip())
					Enddo
				EndIf	
			EndIf
			If SFE->(MsSeek(xFilial("SFE")+SF2->F2_CLIENTE+SF2->F2_LOJA))
				cChaveSFE2 := SFE->FE_FILIAL+SFE->FE_FORNECE+SFE->FE_LOJA
				While !SFE->(Eof()) .And. cChaveSFE2 == xFilial("SFE")+SFE->FE_FORNECE+SFE->FE_LOJA
					If Year(SFE->FE_EMISSAO) != Year(dDataBase) .Or. !(SFE->FE_TIPO $"U|S")
						SFE->(dbSkip())
						Loop
					EndIf
					If SFE->FE_NFISCAL+SFE->FE_SERIE == SF2->F2_DOC+SF2->F2_SERIE
						If lShowPOrd .and. TableInDic("FVC") .and. Funname() == "FINA855"
							If Ascan(aRetPreO,{|x| x == SFE->(SFE->FE_FORNECE+SFE->FE_LOJA+SFE->FE_NFISCAL+SFE->FE_SERIE+SFE->FE_PARCELA) }) == 0
								nTotRetSFE += SFE->FE_RETENC
								nTotBasSFE += SFE->FE_VALBASE
								nBaseRet += SFE->FE_VALBASE
							EndIf
						Else
							nTotRetSFE += SFE->FE_RETENC
							nTotBasSFE += SFE->FE_VALBASE
							nBaseRet += SFE->FE_VALBASE
						EndIf
					Endif
					SFE->(dbSkip())
				End
			EndIf
			IF SA2->A2_CONDO=='1'

				SFE->(dbSetOrder(5))
				If SFE->(MsSeek(xFilial("SFE")+SA2->A2_COD+SA2->A2_LOJA))
					While !SFE->(Eof()) .And. SFE->FE_FILIAL  == xFilial("SFE");
						.And. SFE->FE_FORCOND == SA2->A2_COD;
						.And. SFE->FE_LOJCOND == SA2->A2_LOJA
						If Year(SFE->FE_EMISSAO) != Year(dDataBase) .Or. !(SFE->FE_TIPO $"U|S")
							SFE->(dbSkip())
							Loop
						EndIf
						If SFE->FE_NFISCAL+SFE->FE_SERIE == SF2->F2_DOC+SF2->F2_SERIE
						nTotRetSFE += SFE->FE_RETENC
						nTotBasSFE += SFE->FE_VALBASE
						nBaseRet = SFE->FE_VALBASE
						Endif
						
						SFE->(dbSkip())
					End
				Endif
            Endif


		Else
			If lShowPOrd .and. TableInDic("FVC") .and. Funname() == "FINA855"
				DBSELECTAREA("FVC")
				FVC->(DBSETORDER(3)) //FVC_FILIAL+FVC_FORNEC+FVC_LOJA+FVC_NFISC+FVC_SERIE+FVC_TIPO+FVC_CONCEP
				If FVC->(MsSeek(xFilial("FVC")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC))
					While FVC->(!Eof()) .and. FVC->(FVC_FORNEC+FVC_LOJA+FVC_NFISC) == SF2->(F2_CLIENTE+F2_LOJA+F2_DOC)
						If  Iif(Inclui,.T.,FJK->FJK_PREOP != FVC->FVC_PREOP)
							If AllTrim(FVC->FVC_TIPO) $ "U|S" .and. ABS(FVC->FVC_RETENC) > 0 .and. FVC->FVC_SERIE == SF2->F2_SERIE
								AADD(aRetPreO,FVC->(FVC_FORNEC+FVC_LOJA+FVC_NFISC+FVC->FVC_SERIE+FVC_PARCEL))
								nTotRetSFE += FVC->FVC_RETENC
								nTotBasSFE += FVC->FVC_VALBAS
								nBaseRet := nTotBasSFE
							EndIf
						Endif
						FVC->(dbSkip())
					Enddo
				EndIf	
			EndIf
			SFE->(dbSetOrder(4))
			If SFE->(MsSeek(xFilial("SFE")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC+SF2->F2_SERIE))
				cChaveSFE2 := SFE->FE_FILIAL+SFE->FE_FORNECE+SFE->FE_LOJA+SFE->FE_NFISCAL+SFE->FE_SERIE
				While !SFE->(Eof()) .And. cChaveSFE2 == xFilial("SFE")+SFE->FE_FORNECE+SFE->FE_LOJA+SFE->FE_NFISCAL+SFE->FE_SERIE
					If Month(SFE->FE_EMISSAO) != Month(dDataBase) .Or.YEAR(SFE->FE_EMISSAO)!=Year(dDataBase) .Or.;
						!(SFE->FE_TIPO $"U|S")
						SFE->(dbSkip())
						Loop
					EndIf
					If lShowPOrd .and. TableInDic("FVC") .and. Funname() == "FINA855"
						If Ascan(aRetPreO,{|x| x == SFE->(SFE->FE_FORNECE+SFE->FE_LOJA+SFE->FE_NFISCAL+SFE->FE_SERIE+SFE->FE_PARCELA) }) == 0
							nTotRetSFE += SFE->FE_RETENC
							nTotBasSFE += SFE->FE_VALBASE
							nBaseRet := nTotBasSFE
						EndIf
					Else
						nTotRetSFE += SFE->FE_RETENC
						nTotBasSFE += SFE->FE_VALBASE
						nBaseRet := nTotBasSFE
					EndIf
					SFE->(dbSkip())
				End

			EndIf
		EndIf

	    If SA2->(ColumnPos("A2_CONCSUS")) > 0 .And. SA2->A2_CONCSUS $ "1|4"
	    	nTotBSUSS:= nTotBasSFE
	    	nLimiteSUSS:= nLimMInRet
	    	If SA2->A2_CONCSUS $ "1|4"
			 	For nI:= 1 to Len(aSUSS)
				   If len(aSuss[nI]) >10 .and. SE2->E2_FORNECE==aSuss[nI][11] .And. SE2->E2_LOJA==aSuss[nI][12]
					nTotRetSFE += Iif( aSUSS[nI][6] == 0,0,aSUSS[nI][4])
					nTotBasSFE += aSUSS[nI][3]
	
					If aSUSS[nI][1]+aSUSS[nI][2]+aSUSS[nI][14] == SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_ESPECIE
						nBaseRet += aSUSS[nI][3]
					Endif
	
					cTitAnt := aSUSS[nI][1]+aSUSS[nI][2]
				   EndIf
				Next
			EndIf
		Endif
		nLimiteSUSS:= nLimMInRet
		While Alltrim(SF2->F2_ESPECIE)<>AllTrim(SE2->E2_TIPO).And.!EOF()
			SF2->(DbSkip())
			Loop
		Enddo

		If (AllTrim(SF2->F2_ESPECIE) == Alltrim(SE2->E2_TIPO)) .And. ;
			(Iif(lMsFil,SE2->E2_MSFIL,xFilial("SF2",SE2->E2_FILORIG))+SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE+SE2->E2_LOJA == ;
			SF2->F2_FILIAL+SF2->F2_DOC+PadR(SF2->F2_SERIE,nTamSer)+SF2->F2_CLIENTE+SF2->F2_LOJA)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Obter o Valor do Imposto e Base baseando se no rateio do valor ³
			//³ do titulo pelo total da Nota Fiscal.                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
			nRateio := Round(xMoeda(nSaldo,SE2->E2_MOEDA,1,SF2->F2_DTDIGIT,5),MsDecimais(1))/Round(xMoeda(SF2->F2_VALBRUT,SF2->F2_MOEDA,1,SF2->F2_DTDIGIT,5),MsDecimais(1))
			
			If cTipoCalc == "2"
				nPosSUSS := aScan(aSUSS,{|x| x[1] == SF2->F2_DOC .And. x[2] == SF2->F2_SERIE})
			Endif
			If cPaisLoc == "ARG" .AND. cTipoCalc == "1" // Zero a base caso o campo FF_TPCALC esteja com 1, RG1784
					nValBase 	:= 0 
			Else
	  			nValBase 	:= Round(xMoeda((nBaseImp*Iif(cTipoCalc == "2",1,nRateio)),SF2->F2_MOEDA,1,dDatabase,,aTxMoedas[Max(SF2->F2_MOEDA,1)][2]),MsDecimais(1))
	  		EndIF
			nValtotBas	:= nValBase 
	   	 	If  ( Dtos(dDataBase)>= Dtos(SA2->A2_DTICALS) .and.  Dtos(Ddatabase) <= Dtos(SA2->A2_DTFCALS) ) .Or. (Empty(SA2->A2_DTICALS).and.Dtos(Ddatabase) <= Dtos(SA2->A2_DTFCALS)) .Or.(Empty(SA2->A2_DTFCALS) .and. Dtos(dDataBase)>= Dtos(SA2->A2_DTICALS) )	  			
				nValRetCac:= nValtotBas * nAliqRet *(SA2->A2_PORSUS/100)
				nValorRet	:= ABs(nValRetCac)    	 	
			Else
				nValRetCac:= nValtotBas * nAliqRet
				nValorRet := ABs(nValRetCac)
			Endif 	
				
			If cTipoCalc == "2"
				IF cPaisLoc == "ARG"
					For nI:= 1 to Len(aSUSS) //Verifica se tem retenção existente para a mesma fatura nos itens selecionados para quitar o valor.
						If len(aSuss[nI]) >10 .and. SE2->E2_FORNECE==aSuss[nI][11] .And. SE2->E2_LOJA==aSuss[nI][12] .and. SE2->E2_PREFIXO==aSuss[nI][2] .And. SE2->E2_NUM==aSuss[nI][1] .And. Alltrim(SE2->E2_TIPO) == Alltrim(aSuss[nI][14])
							nValorRet -= IIF(SE2->E2_TIPO == "NCP",aSuss[nI][4] * nSigno,aSuss[nI][4]) 
							IF nValorRet <= 0 
								lTemCuota := .T.
							Else 
								lZeraBase := .T.
							EndIF
						EndIf
					Next
					SFE->(dbSetOrder(4)) // Verifico se existe retenção na tabela SFE para quitar o valor.
					IF SE2->E2_TIPO == "NCP"
						cBuscRef := xFilial("SFE")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC+SF2->F2_SERIE+"S"+cConceito
					else
						cBuscRef := xFilial("SFE")+SF1->F1_FORNECE+SF1->F1_LOJA+SF1->F1_DOC+SF1->F1_SERIE+"S"+cConceito
					EndIF
					If SFE->(MsSeek(cBuscRef))
						cChaveSFE := SFE->FE_FILIAL+SFE->FE_FORNECE+SFE->FE_LOJA+SFE->FE_NFISCAL+SFE->FE_SERIE+"S"+cConceito
						While !SFE->(Eof()) .And. cChaveSFE == xFilial("SFE")+SFE->FE_FORNECE+SFE->FE_LOJA+SFE->FE_NFISCAL+SFE->FE_SERIE+SFE->FE_TIPO+SFE->FE_CONCEPT
							If !Empty(SFE->FE_DTESTOR) .Or. SFE->FE_RETENC > 0
								SFE->(dbSkip())
								Loop
							EndIf
							If lShowPOrd .and. TableInDic("FVC") .and. Funname() == "FINA855"
								If Ascan(aRetPreO,{|x| x == SFE->(SFE->FE_FORNECE+SFE->FE_LOJA+SFE->FE_NFISCAL+SFE->FE_SERIE+SFE->FE_PARCELA) }) <> 0
									nValorRet -= IIF(SE2->E2_TIPO == "NCP",SFE->FE_RETENC * nSigno,SFE->FE_RETENC) 
									IF nValorRet <= 0
										lTemCuota := .T.
									EndIF
								EndIf
							Else
								nValorRet -= IIF(SE2->E2_TIPO == "NCP",SFE->FE_RETENC * nSigno,SFE->FE_RETENC) 
								IF nValorRet <= 0
									lTemCuota := .T.
								EndIF
							EndIf
							SFE->(dbSkip())
						End
					EndIf
				else
					nValorRet -= nTotRetSFE
				EndIF
			EndIf			
			//Impostos recalculados na tela - Modificar OP
			If nLinha > 0

				//Impostos calculados - IVA, IB...
				For nI := 1 to Len(aImpCalc[nLinha])
					If ValType(aImpCalc[nLinha][nI]) == "A"
						nImpCalc += aImpCalc[nLinha][nI][2]
					EndIf
				Next

				//Ganancia
				For nGan := 1 To Len(aImpCalc)
					If Len(aImpCalc[nGan]) > 0 .And. ValType(aImpCalc[nGan][1]) <> "A"
						If aImpCalc[nGan][1] == "GAN"
							nTtlGan := aImpCalc[nGan][2] - nGanAnt
							nGanAnt := aImpCalc[nGan][2]
							nLinDoc ++
							If nLinha == nLinDoc
								Exit
							EndIf
						EndIf
					EndIf
				Next
				nImpCalc += nTtlGan
			Endif
			
			If nImpCalc <> 0
				nImpCalc := nImpCalc * nSigno
			EndIf
			
			nSaldoM1 := (Round(xMoeda(nSaldo,SE2->E2_MOEDA,1,,5,aTxMoedas[Max(SE2->E2_MOEDA,1)][2]),MsDecimais(1)) * Iif(cTipoCalc == "2",1,nRateio))

			If nValorRet + nImpCalc >= nSaldoM1 .And. cTipoCalc == "2"
				nValorRet := nSaldoM1 - nImpCalc
				
				//Zera o calculo caso a retencao seja negativa
				If nValorRet < 0
					nValBase 	:= 0
					nValtotBas 	:= 0
					nValRetCac	:= 0
					nValorRet	:= 0
				Endif
				
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Gravar Retenciones.                                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !lTemCuota // Somente a primeira parcela da fatura grava o array as demais não gravam.
				nValorRet := Round(nValorRet,TamSX3("FE_VALIMP")[2])
				AAdd(aSFESUSS,Array(15))
				aSFESUSS[Len(aSFESUSS)][1] := SF2->F2_DOC         		     //FE_NFISCAL
				aSFESUSS[Len(aSFESUSS)][2] := SF2->F2_SERIE       		     //FE_SERIE
				aSFESUSS[Len(aSFESUSS)][3] := IIF(lZeraBase,0,nValBase * nSigno) //(nValtotBas *nSigno)	                     //FE_VALBASE
				aSFESUSS[Len(aSFESUSS)][4] := (nValorRet *nSigno )	                     //FE_VALIMP
				aSFESUSS[Len(aSFESUSS)][5] := 100  						//FE_PORCRET
			   	If Alltrim(cConceito)=="1"
			   		aSFESUSS[Len(aSFESUSS)][6] := + nValorRet *nSigno
		  		ElseIf  Alltrim(cConceito)=="4"
		  			aSFESUSS[Len(aSFESUSS)][6] := + nValorRet *nSigno
		  		Else
					aSFESUSS[Len(aSFESUSS)][6] := (nValorRet*nSigno)
		    	EndIf
		    	aSFESUSS[Len(aSFESUSS)][7] := nAliqRet * 100		//FE_ALIQ
	
		    	aSFESUSS[Len(aSFESUSS)][8] := cConceito            // FE_CONCEPT
		    	aSFESUSS[Len(aSFESUSS)][9] := cTipoCalc            // Tipo Calculo - ajuste de retenÜ§Ü£o pot total
		    	aSFESUSS[Len(aSFESUSS)][10] := cTpObr
				aSFESUSS[Len(aSFESUSS)][11] := SE2->E2_FORNECE
				aSFESUSS[Len(aSFESUSS)][12] := SE2->E2_LOJA
	
				If	nVRetSUSS = 0
					aSFESUSS[Len(aSFESUSS)][13] := IIf(lReSaSU,nValRetCac,0)
				Endif 
				aSFESUSS[Len(aSFESUSS)][14] := SF2->F2_ESPECIE
				aSFESUSS[Len(aSFESUSS)][15] := nLimiteSUSS
			ElseIF cTipoCalc == "1" // Caso o FF_TPCALC esteja com 1 gero um array zerado e apresento mensagem que opção foi removida.
				nValorRet := Round(nValorRet,TamSX3("FE_VALIMP")[2])
				AAdd(aSFESUSS,Array(15))
				aSFESUSS[Len(aSFESUSS)][1] := SF2->F2_DOC         		     //FE_NFISCAL
				aSFESUSS[Len(aSFESUSS)][2] := SF2->F2_SERIE       		     //FE_SERIE
				aSFESUSS[Len(aSFESUSS)][3] := 0	//(nValtotBas *nSigno)	                     //FE_VALBASE
				aSFESUSS[Len(aSFESUSS)][4] := 0                     //FE_VALIMP
				aSFESUSS[Len(aSFESUSS)][5] := 100  						//FE_PORCRET
	  			aSFESUSS[Len(aSFESUSS)][6] := 0
		     	aSFESUSS[Len(aSFESUSS)][7] := 0		//FE_ALIQ
		    	aSFESUSS[Len(aSFESUSS)][8] := cConceito            // FE_CONCEPT
		    	aSFESUSS[Len(aSFESUSS)][9] := cTipoCalc            // Tipo Calculo - ajuste de retenÜ§Ü£o pot total
		    	aSFESUSS[Len(aSFESUSS)][10] := cTpObr
				aSFESUSS[Len(aSFESUSS)][11] := SE2->E2_FORNECE
				aSFESUSS[Len(aSFESUSS)][12] := SE2->E2_LOJA
	
				If	nVRetSUSS = 0
					aSFESUSS[Len(aSFESUSS)][13] := IIf(lReSaSU,nValRetCac,0)
				Endif 
				aSFESUSS[Len(aSFESUSS)][14] := SF2->F2_ESPECIE
				aSFESUSS[Len(aSFESUSS)][15] := nLimiteSUSS
			EndIf 
	    EndIf
	EndIf
EndIf

Return aSFESUSS 
