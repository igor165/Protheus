#include "protheus.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RetSLIDeb ºAutor  ³                    º Data ³  05/08/2020 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ RetSLIDeb  - Cálculo de Ret de SLI para NF.                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ARGRetSLI (FINRETARG)                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ 1. cAgente: Agente de retención (N = No/ S = Si).          º±±
±±           ³ 2. nSigno: 1 / (-1)Si SE2->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG º±±
±±           ³ 3. nSaldo: Saldo (valor baser o valor a bajar).            º±±
±±           ³ 4. nA: NO se envia valor desde la rutina FINA850, NO-usado.º±±
±±           ³ 5. cChavePOP: FJK_PREOP+Proveedor+Loja, usada en ObtReten()º±±
±±           ³ 6. cNFPOP: Num de documento(E2_NUM), usado en ObtReten().  º±±
±±           ³ 7. cSeriePOP: Serie(E2_PREFIXO), usada en ObtReten().      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RetSLIDeb(cAgente,nSigno,nSaldo,nA,cChavePOP,cNFPOP,cSeriePOP)
Local aSFESLI	:= {}
Local lCalcLimp	:= .T.
Local cChave	:= ""
Local nRateio	:= 0
Local nValRet	:= 0
Local nVlrBase	:= 0
Local nVlrTotal	:= 0
Local nAliq	    := 0
Local nI		:= 0
Local nRecSF1 := 0 
Local nTamSer := SerieNfId('SF1',6,'F1_SERIE')
Local lTESNoExen := .F.

If type("cFornece")=="U"
	cFornece	:=SE2->E2_FORNECE
	cLoja		:=SE2->E2_LOJA
EndIf      

DEFAULT nSigno	:=	1
DEFAULT cChavePOP:= ""
DEFAULT cNFPOP	 := ""
DEFAULT cSeriePOP:= ""


If lShowPOrd .and. Funname() == "FINA847" .and. Type("lCtaCte")<>"U" .and. lCtaCte
	Return aSFESLI := ObtReten(cChavePOP,cNFPOP,cSeriePOP,"L")
EndIf

//+---------------------------------------------------------------------+
//?Obter Impostos somente qdo a Empresa Usuario for Agente de RetençŽŸo.?
//+---------------------------------------------------------------------+
SA2->( dbSetOrder(1) )
If SA2->(MsSeek(If(lMsFil .And. !Empty(xFilial("SA2")) .And. xFilial("SF1") == xFilial("SE2"),SE2->E2_MSFIL,xFilial("SA2"))+SE2->E2_FORNECE+SE2->E2_LOJA)) .And. SA2->(ColumnPos("A2_DTICALL")) > 0 ;
	.And. SA2->(ColumnPos("A2_DTFCALL")) > 0  .And. !Empty(SA2->A2_DTICALL) .And. !Empty(SA2->A2_DTFCALL)
    If  ( Dtos(dDataBase)>= Dtos(SA2->A2_DTICALL) ) .And. ( Dtos(Ddatabase) <= Dtos(SA2->A2_DTFCALL) )
   		lCalcLimp	:=.F.
    EndIf
EndIf

If ExistBlock("F0851IMP")
	lCalcLimp:=ExecBlock("F0851IMP",.F.,.F.,{"SLI"})
EndIf
If Subs(cAgente,7,1) == "S" .And. lCalcLimp
	dbSelectArea("SF1")
	dbSetOrder(1)
	If lMsfil
		nRecSF1 := FINBuscaNF(SE2->E2_MSFIL,SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_FORNECE,SE2->E2_LOJA,"SF1",.T.)
		SF1->(dbGoTo(nRecSF1))
	Else
		nRecSF1 := FINBuscaNF(xFilial("SF1",SE2->E2_FILORIG),SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_FORNECE,SE2->E2_LOJA,"SF1",.T.)
		SF1->(dbGoTo(nRecSF1))
	EndIf
	While !Eof() .And. (Alltrim(SF1->F1_ESPECIE) <> AllTrim(SE2->E2_TIPO))
		dbSkip()
		Loop
	End

	If (AllTrim(SF1->F1_ESPECIE) == Alltrim(SE2->E2_TIPO)) .And. ;
		(Iif(lMsFil,SF1->F1_MSFIL,xFilial("SF1",SE2->E2_FILORIG))+SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE+SE2->E2_LOJA == ;
		F1_FILIAL+F1_DOC+PadR(F1_SERIE,nTamSer)+F1_FORNECE+F1_LOJA)

		nRateio := ( Round(xMoeda(nSaldo,SE2->E2_MOEDA,1,,5,aTxMoedas[Max(SE2->E2_MOEDA,1)][2]),MsDecimais(1)) / ROund(xMoeda(SF1->F1_VALBRUT,SF1->F1_MOEDA,1,,5,aTxMoedas[Max(SF1->F1_MOEDA,1)][2]),MsDecimais(1)) )

		cChave := SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA
		SD1->(DbSetOrder(1))
		If lMsFil
			SD1->(MsSeek(SF1->F1_MSFIL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
		Else
			SD1->(MsSeek(xFilial("SD1",SE2->E2_FILORIG)+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
		EndIf
		While !SD1->(Eof()) .And. Iif(lMsFil,SD1->D1_MSFIL,xFilial("SD1",SE2->E2_FILORIG))==SD1->D1_FILIAL .And. SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA == cChave
			If AllTrim(SD1->D1_ESPECIE) <> Alltrim(SF1->F1_ESPECIE)
				SD1->(DbSkip())
				Loop
			Endif

			SFF->(dbSetOrder(10))
			SFF->(MsSeek(xFilial()+"SLI"+SD1->D1_CF))


			If SFF->(Found())

				//Verifica as caracteristicas do TES para que os impostos
				//possam ser somados ao valor da base de calculo da retencao...
				aImpInf := TesImpInf(SD1->D1_TES)
				lTESNoExen := aScan(aImpInf,{|x| "IV" $ AllTrim(x[1])}) <> 0
				If !lTESNoExen
					SD1->(DbSkip())
					Loop
				EndIf
				
				nAliq     := SFF->FF_ALIQ
				nVlrTotal += SD1->D1_TOTAL

				For nI := 1 To Len(aImpInf)
					//Caso o fornecedor seja "Responsable Inscripto" o IVA
					//nao eh considerado na soma dos impostos...
					If (SA2->A2_TIPO == "I")
						If !("IVA"$Trim(aImpInf[nI][01])) .And. (aImpInf[nI][03] <> "3")
							nVlrTotal += (SD1->(FieldGet(ColumnPos(aImpInf[nI][02]))) * Iif(aImpInf[nI][03]=="1",1,-1))
						ElseIf ("IVA"$Trim(aImpInf[nI][01])) .And. (aImpInf[nI][03] == "3")
							nVlrTotal -= SD1->(FieldGet(ColumnPos(aImpInf[nI][02])))
						EndIf
					Else
						If aImpInf[nI][03] <> "3"
							nVlrTotal += (SD1->(FieldGet(ColumnPos(aImpInf[nI][02]))) * Iif(aImpInf[nI][03]=="1",1,-1))
						EndIf
					EndIf
				Next
			EndIf
			SD1->(dbSkip())
		End

		If nVlrTotal > 0
			nVlrBase := (nVlrTotal * nRateio)
			nValRet  := Round((nVlrBase*(nAliq/100))*nSigno,TamSX3("FE_VALIMP")[2])
			
			//?Gravar Retenciones.   			
			AAdd(aSFESLI,array(6))
			aSFESLI[Len(aSFESLI)][1] := SF1->F1_DOC   //FE_NFISCAL
			aSFESLI[Len(aSFESLI)][2] := SF1->F1_SERIE //FE_SERIE
			aSFESLI[Len(aSFESLI)][3] := nSaldo	       //FE_VALBASE
			aSFESLI[Len(aSFESLI)][4] := nSaldo	       //FE_VALIMP
			aSFESLI[Len(aSFESLI)][5] := Round((nValRet*100)/nSaldo,2)//FE_PORCRET
			aSFESLI[Len(aSFESLI)][6] := nValRet
		EndIf
	EndIf
EndIf

Return aSFESLI



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RetSLICre ºAutor  ³                    º Data ³  05/08/2020 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ RetSLICre  - Cálculo de Ret de SLI para NC.                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ARGRetSL2 (FINRETARG)                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ 1. cAgente: Agente de retención (N = No/ S = Si).          º±±
±±           ³ 2. nSigno: 1 / (-1)Si SE2->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG º±±
±±           ³ 3. nSaldo: (valor baser o valor a bajar).                  º±±
±±           ³ 4. nA: NO se envia valor desde la rutina FINA850, NO-usado.º±±
±±           ³ 5. cChavePOP: FJK_PREOP+Proveedor+Loja, usada en ObtReten()º±±
±±           ³ 6. cNFPOP: Num de documento(E2_NUM), usado en ObtReten().  º±±
±±           ³ 7. cSeriePOP: Serie(E2_PREFIXO), usada en ObtReten().      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function RetSLICre(cAgente,nSigno,nSaldo,nA,cChavePOP,cNFPOP,cSeriePOP)
Local aSFESLI 	:= {}
Local lCalcLimp	:= .T.
Local cChave  	:= ""
Local nRateio 	:= 0
Local nValRet 	:= 0
Local nVlrBase	:= 0
Local nVlrTotal	:= 0
Local nAliq   	:= 0
Local nI	  	:= 0
Local nRecSF2	:= 0 
Local nTamSer := SerieNfId('SF2',6,'F2_SERIE') 
Local lTESNoExen := .F. 
       
If	type("cFornece")=="U"
	cFornece	:=SE2->E2_FORNECE
	cLoja		:=SE2->E2_LOJA
EndIf

DEFAULT nSigno	:= -1
DEFAULT cChavePOP:= ""
DEFAULT cNFPOP	 := ""
DEFAULT cSeriePOP:= ""

If lShowPOrd .and. Funname() == "FINA847" .and. Type("lCtaCte")<>"U" .and. lCtaCte
	Return aSFESLI := ObtReten(cChavePOP,cNFPOP,cSeriePOP,"L")
EndIf

SA2->( dbSetOrder(1)) 
If SA2->(MsSeek(If(lMsFil .And. !Empty(xFilial("SA2")) .And. xFilial("SF1") == xFilial("SE2"),SE2->E2_MSFIL,xFilial("SA2"))+SE2->E2_FORNECE+SE2->E2_LOJA)) .And. SA2->(ColumnPos("A2_DTICALL")) > 0 ;
	.And. SA2->(ColumnPos("A2_DTFCALL")) > 0  .And. !Empty(SA2->A2_DTICALL) .And. !Empty(SA2->A2_DTFCALL)
    If  ( Dtos(dDataBase)>= Dtos(SA2->A2_DTICALL) ) .And. ( Dtos(Ddatabase) <= Dtos(SA2->A2_DTFCALL) )
   		lCalcLimp	:=.F.
    EndIf
EndIf

If ExistBlock("F0851IMP")
	lCalcLimp:=ExecBlock("F0851IMP",.F.,.F.,{"SL2"})
EndIf

//+---------------------------------------------------------------------+
//?Obter Impostos somente qdo a Empresa Usuario for Agente de RetençŽŸo.?
//+---------------------------------------------------------------------+
If Subs(cAgente,7,1) == "S"   .And. lCalcLimp
	dbSelectArea("SF2")
	dbSetOrder(1)
	If lMsFil
		nRecSF2 := FINBuscaNF(SE2->E2_MSFIL,SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_FORNECE,SE2->E2_LOJA,"SF2",.T.)
		SF2->(dbGoTo(nRecSF2))
	Else
		nRecSF2 := FINBuscaNF(xFilial("SF2",SE2->E2_FILORIG),SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_FORNECE,SE2->E2_LOJA,"SF2",.T.)
		SF2->(dbGoTo(nRecSF2))
	EndIf
	While !Eof() .And. (Alltrim(SF2->F2_ESPECIE) <> AllTrim(SE2->E2_TIPO))
		DbSkip()
		Loop
	Enddo

	If (AllTrim(SF2->F2_ESPECIE) == Alltrim(SE2->E2_TIPO)) .And. ;
		(Iif(lMsFil,SF2->F2_MSFIL,xFilial("SF2",SE2->E2_FILORIG))+SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE+SE2->E2_LOJA == ;
		F2_FILIAL+F2_DOC+PadR(F2_SERIE,nTamSer)+F2_CLIENTE+F2_LOJA)

		nRateio := ( Round(xMoeda(nSaldo,SE2->E2_MOEDA,1,,5,aTxMoedas[Max(SE2->E2_MOEDA,1)][2]),MsDecimais(1)) / Round(xMoeda(SF2->F2_VALBRUT,SF2->F2_MOEDA,1,,5,aTxMoedas[Max(SF2->F2_MOEDA,1)][2]),MsDecimais(1)) )

		cChave := SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA
		SD2->(DbSetOrder(3))
		If lMsFil
			SD2->(MsSeek(SF2->F2_MSFIL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
		Else
			SD2->(MsSeek(xFilial("SD2",SE2->E2_FILORIG)+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
		EndIf

		While !SD2->(Eof()) .And. Iif(lMsfil,SD2->D2_MSFIL,xFilial("SD2",SE2->E2_FILORIG))==SD2->D2_FILIAL .And. SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA == cChave
			If AllTrim(SD2->D2_ESPECIE) <> Alltrim(SF2->F2_ESPECIE)
				SD2->(DbSkip())
				Loop
			Endif

			SFF->( Iif(SD2->D2_CF < "500",dbSetOrder(10),dbSetOrder(12)) )
			SFF->(MsSeek(xFilial()+"SLI"+SD2->D2_CF))

			Do Case
				Case IsInCallStack("Fa085Alt") .and. n == nA 
					nSaldo:= &(ReadVar())
				case IsInCallStack("Fa085Alt").and. !Empty(Acols) .and. Acols[nA][4] == SF2->F2_DOC .and. aCols [nA][1] <> SF2->F2_VALBRUT .and. n <> 0	
				   	nSaldo:= Acols[nA][1]
				Otherwise													
					nSaldo:= nSaldo
			EndCase

			If SFF->(Found())

				//Verifica ascaracteristicas do TES para que os impostos
				//possam ser somados ao valor da base de calculo da retencao...
				aImpInf := TesImpInf(SD2->D2_TES)
				lTESNoExen := aScan(aImpInf,{|x| "IV" $ AllTrim(x[1])}) <> 0
				If !lTESNoExen
					SD2->(DbSkip())
					Loop
				EndIf
				
				nAliq     := SFF->FF_ALIQ
				nVlrTotal += SD2->D2_TOTAL

				For nI := 1 To Len(aImpInf)
					//Caso o fornecedor seja "Responsable Inscripto" o IVA
					//nao eh considerado na soma dos impostos...
					If (SA2->A2_TIPO == "I")
						If !("IVA"$Trim(aImpInf[nI][01])) .And. (aImpInf[nI][03] <> "3")
							nVlrTotal += (SD2->(FieldGet(ColumnPos(aImpInf[nI][02]))) * Iif(aImpInf[nI][03]=="1",1,-1))
						ElseIf ("IVA"$Trim(aImpInf[nI][01])) .And. (aImpInf[nI][03] == "3")
							nVlrTotal -= SD2->(FieldGet(ColumnPos(aImpInf[nI][02])))
						EndIf
					Else
						If aImpInf[nI][03] <> "3"
							nVlrTotal += (SD2->(FieldGet(ColumnPos(aImpInf[nI][02]))) * Iif(aImpInf[nI][03]=="1",1,-1))
						EndIf
					EndIf
				Next
			EndIf
			SD2->(dbSkip())
		End

		If nVlrTotal > 0
			nVlrBase := (nVlrTotal * nRateio)
			nValRet  := Round((nVlrBase*(nAliq/100))*nSigno,TamSX3("FE_VALIMP")[2])
		
			//?Gravar Retenciones.			
			AAdd(aSFESLI,array(6))
			aSFESLI[Len(aSFESLI)][1] := SF2->F2_DOC   				 //FE_NFISCAL
			aSFESLI[Len(aSFESLI)][2] := SF2->F2_SERIE 				 //FE_SERIE
			aSFESLI[Len(aSFESLI)][3] := nSaldo	      					 //FE_VALBASE
			aSFESLI[Len(aSFESLI)][4] := nSaldo	       				 //FE_VALIMP
			aSFESLI[Len(aSFESLI)][5] := Round((nValRet*100)/nSaldo,2)//FE_PORCRET
			aSFESLI[Len(aSFESLI)][6] := nValRet
		EndIf
	EndIf
EndIf

Return aSFESLI
