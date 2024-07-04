#include "protheus.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRetMunDeb บAutor  ณ                    บ Data ณ  06/08/2020 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ RetMunDeb  - Cแlculo de Ret de Seguridad para NF.          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ARGSegF1 (FINRETARG)                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ 1. cAgente: Agente de retenci๓n (N = No/ S = Si).          บฑฑ
ฑฑ           ณ 2. nSigno: 1 / (-1)Si SE2->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG บฑฑ
ฑฑ           ณ 3. nSaldo: Saldo (valor baser o valor a bajar).            บฑฑ
ฑฑ           ณ 4. cChavePOP: FJK_PREOP+Proveedor+Loja, usada en ObtReten()บฑฑ
ฑฑ           ณ 5. cNFPOP: Num de documento(E2_NUM), usado en ObtReten().  บฑฑ
ฑฑ           ณ 6. cSeriePOP: Serie(E2_PREFIXO), usada en ObtReten().      บฑฑ
ฑฑ           ณ 7. aSLIMIN: Arreglo de SFF para municipalidades (es inicia-บฑฑ
ฑฑ           ณ            lizado en estแ funci๓n y usado en FINA850().    บฑฑ
ฑฑ           ณ    [1] = FF_IMPOSTO.                                       บฑฑ
ฑฑ           ณ    [2] = FF_RET_MUN.                                       บฑฑ
ฑฑ           ณ    [3] = FF_IMPORTE.                                       บฑฑ
ฑฑ           ณ    [4] = Cero.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function RetMunDeb(cAgente,nSigno,nSaldo,cChavePOP,cNFPOP,cSeriePOP,aSLIMIN)
Local aSFEISI  	:= {}
Local aSFF 		:= {}
Local aSFH 		:= {}
Local aCF	   	:= {}
Local aImps 	:= {}
Local lFin85Zar	:= .T.
Local lCalcLimp	:= .F.
Local cChave   	:= ""
Local nRateio  	:= 0
Local nValRet  	:= 0
Local nValTot  	:= 0
Local nVlrBase 	:= 0
Local nVlrTotal	:= 0
Local nAliq    	:= 0
Local nVlrFF   	:= 0
Local nRecFF   	:= 0
Local nPercTot 	:= 1
Local nValBasTot:= 0
Local nK 		:= 0
Local nL 		:= 0
Local nM		:= 0
Local nN 		:= 0
Local nI		:= 0
Local nJ		:= 0
Local nRecSF1 := 0 
Local nTamSer := SerieNfId('SF1',6,'F1_SERIE')
Local lTESNoExen := .F.
Local nValCoef := SuperGetMv("MV_CRFRET",.F.,0)
Local lCalcCEI := .F.
Local nValMCO := 0
Local nPosMin	:= 0
Local lEsCEI_CO := .F.
Private lNoIsento := .T.
Private lSFH := .F.
Private lCero := .F.

DEFAULT nSigno	:=	1
DEFAULT cChavePOP:= ""
DEFAULT cNFPOP	 := ""
DEFAULT cSeriePOP:= ""
DEFAULT aSLIMIN := {}

If lShowPOrd .and. Funname() == "FINA847" .and. Type("lCtaCte")<>"U" .and. lCtaCte .and. FVC->(ColumnPos("FVC_RET_MN")) > 0
	Return aSFEISI := ObtReten(cChavePOP,cNFPOP,cSeriePOP,"M",nSaldo)
EndIf


//+---------------------------------------------------------------------+
//ฐ Obter Impostos somente qdo a Empresa Usuario for Agente de RetenÜงÜคo.ฐ
//+---------------------------------------------------------------------+
SA2->( dbSetOrder(1) )
If lMsFil .And. !Empty(xFilial("SA2")) .And. xFilial("SF1") == xFilial("SE2")
	SA2->(MsSeek(SE2->E2_MSFIL+SE2->E2_FORNECE+SE2->E2_LOJA))
Else
	SA2->(MsSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA))
Endif

dbSelectArea("SFF")
dbSetOrder(1)
If SA2->(Found()) .And. SA2->(ColumnPos("A2_RET_MUN")) >0 .And. SFF->(ColumnPos("FF_RET_MUN")) > 0 .And. SFE->(ColumnPos("FE_RET_MUN")) > 0 
	If !Empty(SA2->A2_RET_MUN)
		lCalcLimp	:=.T. 
	EndIf
EndIf

If  lCalcLimp
	If ExistBlock("F0851IMP")
		lCalcLimp:=ExecBlock("F0851IMP",.F.,.F.,{"M"})
	EndIf  
Endif

If  lCalcLimp
	lEsCEI_CO := (SA2->(A2_RET_MUN) == "00004")
	dbSelectArea("SF1")
	dbSetOrder(1)
	If lMsFil
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
		While !SD1->(Eof()) .And. Iif(lMsFil,SF1->F1_MSFIL,xFilial("SD1",SE2->E2_FILORIG))==SD1->D1_FILIAL .And. SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA == cChave
			If AllTrim(SD1->D1_ESPECIE) <> Alltrim(SF1->F1_ESPECIE)
				SD1->(DbSkip())
				Loop
			Endif
			
			//Verifica as caracteristicas do TES para que os impostos
			//possam ser somados ao valor da base de calculo da retencao..
			aImpInf := TesImpInf(SD1->D1_TES)
			lTESNoExen := aScan(aImpInf,{|x| "IV" $ AllTrim(x[1])}) <> 0
			If !lTESNoExen
				SD1->(DbSkip())
				Loop
			EndIf

			If  lEsCEI_CO  //lEsCEI_CO:= (SA2->(A2_RET_MUN) == "00004") ->Es C๓rdoba
		   		aSFF := ObtRegSF("CEI", "SFF") //Obtiene tabla generica SFF por codigo de municipalidad 
		   		nValMCO += Round(xmoeda((SD1->D1_TOTAL-SD1->D1_VALDESC),SF1->F1_MOEDA,1,,5,aTxMoedas[Max(SF1->F1_MOEDA,1)][2]),MsDecimais(1))
		   		If  Len(aSFF) > 0 .AND. !lCalcCEI
		   			lCalcCEI := .T.
		   		Endif
		   	Else
		   		aSFF := ObtRegSF("", "SFF") //Obtiene tabla generica SFF por codigo de municipalidad
		   		If (nJ := aScan(aCF, {|x| x[1]==SD1->D1_CF}))==0
					aAdd( aCF , {SD1->D1_CF,0,{}} ) // CF , Total , Aliq
					nJ := Len(aCF)
				EndIf
				aCF[nJ,2]	+=  Round(xmoeda((SD1->D1_TOTAL-SD1->D1_VALDESC),SF1->F1_MOEDA,1,,5,aTxMoedas[Max(SF1->F1_MOEDA,1)][2]),MsDecimais(1))
		   	Endif
		   	
		   	If  ( (!lEsCEI_CO) .OR. (lEsCEI_CO .And. lCalcCEI) ) //lEsCEI_CO:= (SA2->(A2_RET_MUN) == "00004")
		   		For nK := 1 To Len(aSFF)
					For nI := 1 To Len(aImpInf)
						If(Trim(aImpInf[nI][01])$ aSFF[nK][7])
							If  !lEsCEI_CO .And. aSFF[nK][1] == aCF[nJ,1]
								aCF[nJ,2] += Round(xmoeda(SD1->(FieldGet(ColumnPos(aImpInf[nI][02]))),SF1->F1_MOEDA,1,,5,aTxMoedas[Max(SF1->F1_MOEDA,1)][2]),MsDecimais(1))
							Else  
								nValMCO	  += Round(xmoeda(SD1->(FieldGet(ColumnPos(aImpInf[nI][02]))),SF1->F1_MOEDA,1,,5,aTxMoedas[Max(SF1->F1_MOEDA,1)][2]),MsDecimais(1))
						 	Endif
						Endif
					Next
				Next		   	
		   	Endif  		   	
			
			SD1->(dbSkip())
		End
		If  lCalcCEI  //CEI no considera CFO
			aAdd( aCF , {"",nValMCO,{}} )
		Endif	
		// Loacaliza CF para totalizar
		For nJ:=1 To Len(aCF)	
			For nK := 1 To Len(aSFF)
				If (aSFF[nK][1] == aCF[nJ,1] .And. SA2->(A2_RET_MUN) == aSFF[nK][6]) .OR. (lCalcCEI .And. SA2->(A2_RET_MUN) == aSFF[nK][6])
					If nVlrFF < aSFF[nK][3]
						nVlrFF := aSFF[nK][3]
						If  lEsCEI_CO //lEsCEI_CO:= (SA2->(A2_RET_MUN) == "00004") ->Es C๓rdoba
							nPosMin := ascan(aSLIMIN,{|x|, x[2] == SA2->(A2_RET_MUN)})
							If nPosMin == 0
								AADD(aSLIMIN,{aSFF[nK][5],aSFF[nK][6],aSFF[nK][3],0})
							EndIf
						Endif              
						nRecFF := SFF->(Recno())
					EndIf
				EndIf
			Next
			// Verrica se encotrou SFF para o valor total e se o valor Üฉ > 0
			If  Iif(lEsCEI_CO,.T.,aCF[nJ,2] > nVlrFF) 	//lEsCEI_CO:= (SA2->(A2_RET_MUN) == "00004") ->Es C๓rdoba
				For nK := 1 To Len(aSFF)
					If (aSFF[nK][1] == aCF[nJ,1] .And. SA2->(A2_RET_MUN) == aSFF[nK][6]) .OR. (lCalcCEI .And. SA2->(A2_RET_MUN) == aSFF[nK][6])
						aSFH := ObtRegSF(aSFF[nK][5], "SFH") //Obtiene tabla generica SFF por codigo de municipalidad
						If Len(aSFH) > 0 	
							For nL := 1 To Len(aSFH)
								If aSFH[nL][5] == "3"
									If aSFH[nL][3] == "CEI" .AND. aSFH[nL][6] == "CO"
										If aSFH[nL][1] == SA2->A2_COD .And. aSFH[nL][2] == SA2->A2_LOJA .And. aSFH[nL][3] == aSFF[nK][5] .and. lNoIsento .AND. lSFH .AND. !lCero
											aAdd(aCF[nJ,3], {aSFH[nL][4], aSFH[nL][3]} ) 
										ElseIf (lNoIsento .AND. !lSFH) .OR. (!lNoIsento .AND. !lSFH) .OR. (lCero .AND. lSFH .AND. lNoIsento) .OR. (lNoIsento .AND. lCero)
											aAdd(aCF[nJ,3], {aSFF[nK][8], aSFF[nK][5]} ) 				
										Endif
									Endif
								ElseIf aSFH[nL][5] <>  "3"	
									If aSFH[nL][1] == SA2->A2_COD .And. aSFH[nL][2] == SA2->A2_LOJA .And. aSFH[nL][3] == aSFF[nK][5] .and. lNoIsento .AND. lSFH .AND. !lCero
											aAdd(aCF[nJ,3], {aSFH[nL][4], aSFH[nL][3]} ) 
									ElseIf (lNoIsento .AND. !lSFH) .OR. (!lNoIsento .AND. !lSFH) .OR. (lCero .AND. lSFH .AND. lNoIsento) .OR. (lNoIsento .AND. lCero)
											aAdd(aCF[nJ,3], {aSFF[nK][8], aSFF[nK][5]} ) 				
									Endif
								Endif	
							Next
							Else
									aAdd(aCF[nJ,3], {aSFF[nK][8], aSFF[nK][5]} ) 			
							EndIf
				    EndIf
				Next
			Else
				aCF[nJ,2]	:= 0 // Zera base de calculo quando nao tem CFOP no SFF
			EndIf
			nRecFF := 0
			nVlrFF := 0
			
		Next

		If lCalcLimp

			// Totaliza Base de calculo por CFOP
				For nJ:=1 To Len(aCF)
					For nM := 1 To Len(aCF[nJ,3])
						nVlrBase := (aCF[nJ,2] * nRateio)
						nAliq	 :=  aCF[nJ,3,nM,1] // Aliquota
						nValRet  := Round((nVlrBase*(nAliq/100))*nSigno,TamSX3("FE_VALIMP")[2])
		
						nValRet	 := (nValRet * nPercTot) // ReduÜงÜฃo de imposto
						If (Len(aSFF) > 0 .And.aSFF[1][5] == "CEI") .And. (Len(aSFH)>0 .And. aSFH[1][5] == "2") .And. nValCoef <> 0
							nValRet := nValRet * nValCoef
						Endif
						nValTot	 += nValRet
						If (nN := aScan(aImps, {|x| x[2]== aCF[nJ,3,nM,2]}))==0
							aAdd( aImps , {aCF[nJ,3,nM,1], aCF[nJ,3,nM,2], nValRet, aCF[nJ,1]} ) // CF , Total , Aliq
						Else
							aImps[nN][3] += nValRet
						EndIf
					Next
					nValBasTot += nVlrBase
					nVlrBase := 0
				Next
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Gravar Retenciones.                                            ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			AAdd(aSFEISI,array(10))
			aSFEISI[Len(aSFEISI)][1] := SF1->F1_DOC   				 //FE_NFISCAL
			aSFEISI[Len(aSFEISI)][2] := SF1->F1_SERIE 				 //FE_SERIE
			aSFEISI[Len(aSFEISI)][3] := nValBasTot	      				 //FE_VALBASE
			aSFEISI[Len(aSFEISI)][4] := nValTot	       			 //FE_VALIMP
			aSFEISI[Len(aSFEISI)][5] := Round((nValTot*100)/nSaldo,2)//FE_PORCRET
			aSFEISI[Len(aSFEISI)][6] := nValTot 						 // FE_RETENC
			aSFEISI[Len(aSFEISI)][7] := nPercTot 						 //FE_DEDUC
			aSFEISI[Len(aSFEISI)][8] := aImps 							 // {Aliq, Impuesto, Vlr Ret, Cod Fiscal}
			aSFEISI[Len(aSFEISI)][9] := SA2->A2_EST 					 // Cod Provincia
			aSFEISI[Len(aSFEISI)][10]:= SA2->A2_RET_MUN 				 // Cod Provincia

		EndIf
	EndIf
EndIf

Return aSFEISI



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRetMunCre บAutor  ณ                    บ Data ณ  06/08/2020 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ RetMunCre  - Cแlculoo de Ret de Seguridad e Hig para NCP.  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ARGSegF2 (FINRETARG)                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ 1. cAgente: Agente de retenci๓n (N = No/ S = Si).          บฑฑ
ฑฑ           ณ 2. nSigno: 1 / (-1)Si SE2->E2_TIPO $ MVPAGANT+"/"+MV_CPNEG บฑฑ
ฑฑ           ณ 3. nSaldo: Saldo (valor baser o valor a bajar).            บฑฑ
ฑฑ           ณ 4. cChavePOP: FJK_PREOP+Proveedor+Loja, usada en ObtReten()บฑฑ
ฑฑ           ณ 5. cNFPOP: Num de documento(E2_NUM), usado en ObtReten().  บฑฑ
ฑฑ           ณ 6. cSeriePOP: Serie(E2_PREFIXO), usada en ObtReten().      บฑฑ
ฑฑ           ณ 7. aSLIMIN: Arreglo de SFF para municipalidades (es inicia-บฑฑ
ฑฑ           ณ            lizado en estแ funci๓n y usado en FINA850().    บฑฑ
ฑฑ           ณ    [1] = FF_IMPOSTO.                                       บฑฑ
ฑฑ           ณ    [2] = FF_RET_MUN.                                       บฑฑ
ฑฑ           ณ    [3] = FF_IMPORTE.                                       บฑฑ
ฑฑ           ณ    [4] = Cero.                                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function RetMunCre(cAgente,nSigno,nSaldo,cChavePOP,cNFPOP,cSeriePOP,aSLIMIN)
Local aSFEISI  	:= {}
Local aCF	   	:= {}
Local aImps 	:= {}
Local aSFF 		:= {}
Local aSFH 		:= {}
Local lCalcLimp := .F.
Local cChave   	:= ""
Local nRateio  	:= 0
Local nValRet  	:= 0
Local nValTot  	:= 0
Local nVlrBase 	:= 0
Local nVlrTotal	:= 0
Local nAliq    	:= 0
Local nVlrFF   	:= 0
Local nRecFF   	:= 0
Local nPercTot 	:= 1
Local nValBasTot:= 0
Local nI		:= 0
Local nJ		:= 0
Local nK 		:= 0
Local nL 		:= 0
Local nM 		:= 0
Local nN 		:= 0
Local nRecSF2	:= 0 
Local nTamSer := SerieNfId('SF2',6,'F2_SERIE')
Local lTESNoExen := .F.
Local nValCoef := SuperGetMv("MV_CRFRET",.F.,0) 
Local lCalcCEI := .F.
Local nValMCO := 0
Local nPosMin	:= 0
Local lEsCEI_CO := .F.
Private lNoIsento := .T.
Private lSFH := .F.
Private lCero := .F.

DEFAULT nSigno:= -1
DEFAULT cChavePOP:= ""
DEFAULT cNFPOP	 := ""
DEFAULT cSeriePOP:= ""
DEFAULT aSLIMIN := {}

If lShowPOrd .and. Funname() == "FINA847" .and. Type("lCtaCte")<>"U" .and. lCtaCte .and. FVC->(ColumnPos("FVC_RET_MN")) > 0
	Return aSFEISI := ObtReten(cChavePOP,cNFPOP,cSeriePOP,"M",nSaldo)
EndIf


dbSelectArea("SFF")
dbSetOrder(1)
If SA2->(Found()) .And. SA2->(ColumnPos("A2_RET_MUN")) >0 .And. SFF->(ColumnPos("FF_RET_MUN")) > 0 .And. SFE->(ColumnPos("FE_RET_MUN")) > 0//.and.;
	If !Empty(SA2->A2_RET_MUN)
		lCalcLimp	:=.T.
	EndIf
EndIf


If  lCalcLimp
	If ExistBlock("F0851IMP")
		lCalcLimp:=ExecBlock("F0851IMP",.F.,.F.,{"M"})
	EndIf      
Endif

//+---------------------------------------------------------------------+
//ฐ Obter Impostos somente qdo a Empresa Usuario for Agente de RetenÜงÜคo.ฐ
//+---------------------------------------------------------------------+
If  lCalcLimp
	lEsCEI_CO := (SA2->(A2_RET_MUN) == "00004")
	dbSelectArea("SF2")
	dbSetOrder(1)
	If lMsFil
		nRecSF2 := FINBuscaNF(SE2->E2_MSFIL,SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_FORNECE,SE2->E2_LOJA,"SF2",.T.)
		SF2->(dbGoTo(nRecSF2))
	Else
		nRecSF2 := FINBuscaNF(xFilial("SF2", SE2->E2_FILORIG),SE2->E2_NUM,SE2->E2_PREFIXO,SE2->E2_FORNECE,SE2->E2_LOJA,"SF2",.T.)
		SF2->(dbGoTo(nRecSF2))
	EndIf
	While !Eof() .And. (Alltrim(SF2->F2_ESPECIE) <> AllTrim(SE2->E2_TIPO))
		DbSkip()
		Loop
	Enddo

	If (AllTrim(SF2->F2_ESPECIE) == Alltrim(SE2->E2_TIPO)) .And. ;
		(Iif(lMsFil,SF2->F2_MSFIL,xFilial("SF2",SE2->E2_FILORIG))+SE2->E2_NUM+SE2->E2_PREFIXO+SE2->E2_FORNECE+SE2->E2_LOJA == ;
		F2_FILIAL+F2_DOC+PadR(SF2->F2_SERIE,nTamSer)+F2_CLIENTE+F2_LOJA)

		nRateio := ( Round(xMoeda(nSaldo,SE2->E2_MOEDA,1,,5,aTxMoedas[Max(SE2->E2_MOEDA,1)][2]),MsDecimais(1)) / Round(xMoeda(SF2->F2_VALBRUT,SF2->F2_MOEDA,1,,5,aTxMoedas[Max(SF2->F2_MOEDA,1)][2]),MsDecimais(1)) )

		cChave := SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA
		SD2->(DbSetOrder(3))
		If lMsFil
			SD2->(MsSeek(SF2->F2_MSFIL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
		Else
			SD2->(MsSeek(xFilial("SD2",SE2->E2_FILORIG)+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
		EndIf
		While !SD2->(Eof()) .And. Iif(lMsFil,SF2->F2_MSFIL,xFilial("SD2",SE2->E2_FILORIG))==SD2->D2_FILIAL .And. SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA == cChave
			If AllTrim(SD2->D2_ESPECIE) <> Alltrim(SF2->F2_ESPECIE)
				SD2->(DbSkip())
				Loop
			Endif
			
			//Verifica as caracteristicas do TES para que os impostos
			//possam ser somados ao valor da base de calculo da retencao...
			aImpInf := TesImpInf(SD2->D2_TES)
			lTESNoExen := aScan(aImpInf,{|x| "IV" $ AllTrim(x[1])}) <> 0
			If !lTESNoExen
				SD2->(DbSkip())
				Loop
			EndIf


			If  lEsCEI_CO  //lEsCEI_CO:= (SA2->(A2_RET_MUN) == "00004") ->Es C?rdoba
				aSFF := ObtRegSF("CEI", "SFF") //Obtiene tabla generica SFF por codigo de municipalidad 
				nValMCO += Round(xmoeda(SD2->D2_TOTAL,SF2->F2_MOEDA,1,,5,aTxMoedas[Max(SF2->F2_MOEDA,1)][2]),MsDecimais(1))
				If Len(aSFF) > 0 .AND. !lCalcCEI
					lCalcCEI := .T.
				Endif
			Else
				aSFF := ObtRegSF("", "SFF") //Obtiene tabla generica SFF por codigo de municipalidad
				If (nJ := aScan(aCF, {|x| x[1]==SD2->D2_CF}))==0
					aAdd( aCF , {SD2->D2_CF,0,{}} ) // CF , Total , Aliq
					nJ := Len(aCF)
				EndIf
				aCF[nJ,2]	+=  Round(xmoeda((SD2->D2_TOTAL),SF2->F2_MOEDA,1,,5,aTxMoedas[Max(SF2->F2_MOEDA,1)][2]),MsDecimais(1))
			Endif               

			If  ( (!lEsCEI_CO) .OR. (lEsCEI_CO .And. lCalcCEI) ) //lEsCEI_CO:= (SA2->(A2_RET_MUN) == "00004")
		   		For nK := 1 To Len(aSFF)
					For nI := 1 To Len(aImpInf)
						If(Trim(aImpInf[nI][01])$ aSFF[nK][7])
							If  !lEsCEI_CO .And. aSFF[nK][2] == aCF[nJ,1]
								aCF[nJ,2] += Round(xmoeda(SD2->(FieldGet(ColumnPos(aImpInf[nI][02]))),SF2->F2_MOEDA,1,,5,aTxMoedas[Max(SF2->F2_MOEDA,1)][2]),MsDecimais(1))
							Else  
								nValMCO	  += Round(xmoeda(SD2->(FieldGet(ColumnPos(aImpInf[nI][02]))),SF2->F2_MOEDA,1,,5,aTxMoedas[Max(SF2->F2_MOEDA,1)][2]),MsDecimais(1))   
						 	Endif
						Endif
					Next
				Next		   	
		   	Endif  
		   
		   SD2->(dbSkip())
		End
		If lCalcCEI
			aAdd( aCF , {"",nValMCO,{}} )
		Endif	
		// Loacaliza CF para totalizar
		For nJ:=1 To Len(aCF)
			For nK := 1 To Len(aSFF)
				If (aSFF[nK][2] == aCF[nJ,1] .And. aSFF[nK][6] == Alltrim(SA2->A2_RET_MUN)) .OR. (lCalcCEI .And. SA2->(A2_RET_MUN) == aSFF[nK][6])
					If nVlrFF < aSFF[nK][3]
						nVlrFF := aSFF[nK][3]
						If  lEsCEI_CO //lEsCEI_CO:= (SA2->(A2_RET_MUN) == "00004") ->Es C?rdoba
							nPosMin := ascan(aSLIMIN,{|x|, x[2] == SA2->(A2_RET_MUN)})
							If nPosMin == 0
								AADD(aSLIMIN,{aSFF[nK][5],aSFF[nK][6],aSFF[nK][3],0})
							EndIf
						Endif             
					EndIf
				EndIf
			Next
			// Verrica se encotrou SFF para o valor total e se o valor Üฉ > 0
			If Iif(lEsCEI_CO,.T.,aCF[nJ,2] > nVlrFF) 		
				For nK := 1 To Len(aSFF)
					If (aSFF[nK][2] == aCF[nJ,1] .And. SA2->(A2_RET_MUN) == aSFF[nK][6]) .OR. (lCalcCEI .And. SA2->(A2_RET_MUN) == aSFF[nK][6])
						aSFH := ObtRegSF(aSFF[nK][5], "SFH") //Obtiene tabla generica SFF por codigo de municipalidad
						If Len(aSFH) > 0 	
							For nL := 1 To Len(aSFH)
								If aSFH[nL][5] == "3"
									If aSFH[nL][3] == "CEI" .AND. aSFH[nL][6] == "CO"
										If aSFH[nL][1] == SA2->A2_COD .And. aSFH[nL][2] == SA2->A2_LOJA .And. aSFH[nL][3] == aSFF[nK][5] .and. lNoIsento .AND. lSFH .AND. !lCero
											aAdd(aCF[nJ,3], {aSFH[nL][4], aSFH[nL][3]} ) 
										ElseIf (lNoIsento .AND. !lSFH) .OR. (!lNoIsento .AND. !lSFH) .OR. (lCero .AND. lSFH .AND. lNoIsento) .OR. (lNoIsento .AND. lCero)
											aAdd(aCF[nJ,3], {aSFF[nK][8], aSFF[nK][5]} )			
										Endif
									Endif
								ElseIf aSFH[nL][5] <>  "3"	
									If aSFH[nL][1] == SA2->A2_COD .And. aSFH[nL][2] == SA2->A2_LOJA .And. aSFH[nL][3] == aSFF[nK][5] .and. lNoIsento .AND. lSFH .AND. !lCero
											aAdd(aCF[nJ,3], {aSFH[nL][4], aSFH[nL][3]} )
										ElseIf (lNoIsento .AND. !lSFH) .OR. (!lNoIsento .AND. !lSFH) .OR. (lCero .AND. lSFH .AND. lNoIsento) .OR. (lNoIsento .AND. lCero)
											aAdd(aCF[nJ,3], {aSFF[nK][8], aSFF[nK][5]} ) 				
									Endif
								Endif	
							Next
							Else
								aAdd(aCF[nJ,3], {aSFF[nK][8], aSFF[nK][5]} ) 			
							EndIf
				    EndIf
				Next
			Else
				aCF[nJ,2]	:= 0 // Zera base de calculo quando nao tem CFOP no SFF
			EndIf
			nRecFF := 0
			nVlrFF := 0
		Next

		If lCalcLimp

			// Totaliza Base de calculo por CFOP
				For nJ:=1 To Len(aCF)
					For nM := 1 To Len(aCF[nJ,3])
						nVlrBase := (aCF[nJ,2] * nRateio) 
						nAliq	 :=  aCF[nJ,3,nM,1] // Aliquota
						nValRet  := Round((nVlrBase*(nAliq/100))*nSigno,TamSX3("FE_VALIMP")[2])
		
						nValRet	 := (nValRet * nPercTot) // ReduÜงÜฃo de imposto
						If (Len(aSFF) > 0 .And.aSFF[1][5] == "CEI") .And. (Len(aSFH)>0 .And. aSFH[1][5] == "2") .And. nValCoef <> 0
							nValRet := nValRet * nValCoef
						Endif
						nValTot	 += nValRet
						If (nN := aScan(aImps, {|x| x[2]== aCF[nJ,3,nM,2]}))==0
							aAdd( aImps , {aCF[nJ,3,nM,1], aCF[nJ,3,nM,2], nValRet, aCF[nJ,1]} ) // CF , Total , Aliq
						Else
							aImps[nN][3] += nValRet
						EndIf
					Next
					nValBasTot += nVlrBase*nSigno
					nVlrBase := 0
				Next
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณ Gravar Retenciones.                                            ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			AAdd(aSFEISI,array(10))
			aSFEISI[Len(aSFEISI)][1] := SF2->F2_DOC  					 //FE_NFISCAL
			aSFEISI[Len(aSFEISI)][2] := SF2->F2_SERIE 				 //FE_SERIE
			aSFEISI[Len(aSFEISI)][3] := nValBasTot	      				 //FE_VALBASE
			aSFEISI[Len(aSFEISI)][4] := nValTot		       		 //FE_VALIMP
			aSFEISI[Len(aSFEISI)][5] := Abs(Round((nValTot*100)/nSaldo,2))//FE_PORCRET
			aSFEISI[Len(aSFEISI)][6] := nValTot 						 // FE_RETENC
			aSFEISI[Len(aSFEISI)][7] := nPercTot 						 //FE_DEDUC
			aSFEISI[Len(aSFEISI)][8] := aImps							 // {Aliq, Impuesto, Vlr Ret, Cod Fiscal}
			aSFEISI[Len(aSFEISI)][9] := SA2->A2_EST					 // Cod Provincia
			aSFEISI[Len(aSFEISI)][10] := SA2->A2_RET_MUN 				 // Cod Provincia

		EndIf
	EndIf
EndIf

Return aSFEISI


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ObtRegSF บ Autor บ  Luis Samaniego    บ Data บ  19/05/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Obtener informacion de SFF y SFH                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Funcao auxiliar                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
function ObtRegSF(cImpuesto, cTabla)
Local aDatosSFF	:= {}
Local cQuery	:= "" 
Local cAlias	:= CriaTrab(Nil,.F.)
Local lData := .F.

Private aTmpArea := {}

Default cImpuesto := ""
                     
If cTabla == "SFF" .And. cPaisLoc == "ARG"
	cQuery := " SELECT FF_CFO_C, FF_CFO_V, FF_IMPORTE, FF_CONCEPT, FF_IMPOSTO, FF_RET_MUN, FF_INCIMP, FF_ALIQ "
	cQuery += " FROM " + RetSQLName("SFF")
	cQuery += " WHERE "
	cQuery += " FF_FILIAL = '" + xFilial("SFF") + "' AND "
	cQuery += " FF_RET_MUN ='" + SA2->A2_RET_MUN + "' AND "
	cQuery += " D_E_L_E_T_<>'*'" 

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.) 
	
	(cAlias)->( dbGoTop() ) 
	IF  !(cAlias)->(Eof())  
		While !(cAlias)->(Eof())
			If ( (cAlias)->FF_IMPOSTO == "CEI" .AND. (cAlias)->FF_RET_MUN == "00004") .AND. aScan(aDatosSFF,{|x|x[5]== "CEI"}) == 0
				If Empty((cAlias)->FF_CFO_C) .And.Empty((cAlias)->FF_CFO_V)
					aAdd( aDatosSFF, {(cAlias)->FF_CFO_C, (cAlias)->FF_CFO_V, (cAlias)->FF_IMPORTE, (cAlias)->FF_CONCEPT,; 
						(cAlias)->FF_IMPOSTO, (cAlias)->FF_RET_MUN, (cAlias)->FF_INCIMP,(cAlias)->FF_ALIQ } )
				EndIf
			ElseIf (cAlias)->FF_IMPOSTO <> "CEI"
				aAdd( aDatosSFF, {(cAlias)->FF_CFO_C, (cAlias)->FF_CFO_V, (cAlias)->FF_IMPORTE, (cAlias)->FF_CONCEPT,; 
					(cAlias)->FF_IMPOSTO, (cAlias)->FF_RET_MUN, (cAlias)->FF_INCIMP,(cAlias)->FF_ALIQ } )
			Endif
			(cAlias)->(dbSkip())
		Enddo
	Endif
	
ElseIf cTabla == "SFH" .And. cPaisLoc $ "ANG|ARG|BOL|COL|COS|DOM|EQU|EUA|HAI|MEX|PAD|PAN|PAR|PER|POR|PTG|RUS|SAL|URU|VEN"
	cQuery := " SELECT FH_FORNECE, FH_LOJA, FH_IMPOSTO, FH_ALIQ, FH_SITUACA, FH_INIVIGE, FH_FIMVIGE, FH_ISENTO, FH_PERCENT, FH_ZONFIS "
	cQuery += " FROM " + RetSQLName("SFH")
	cQuery += " WHERE "
	cQuery += " FH_FILIAL = '" + xFilial("SFH") + "' AND "
	cQuery += " FH_FORNECE ='" + SA2->A2_COD + "' AND " 
	cQuery += " FH_LOJA ='" + SA2->A2_LOJA + "' AND " 
	If cPaisLoc <> "ARG" .Or. (cPaisLoc == "ARG" .And. !(cImpuesto $ "CEI|RMT"))
		cQuery += " FH_IMPOSTO ='" + cImpuesto + "' AND "
	Endif
	cQuery += " FH_PERCIBI = 'S' AND "
	If cPaisLoc == "ARG" .And. cImpuesto == "CEI"
		cQuery += " ((FH_INIVIGE = '' AND FH_FIMVIGE = '')"
		cQuery += " OR "
		cQuery += " ('" + Dtos(dDatabase) + "' >= FH_INIVIGE  AND '" + Dtos(dDatabase) + "' <= FH_FIMVIGE)"    
		cQuery += " OR "
		cQuery += " ('" + Dtos(dDatabase) + "' >= FH_INIVIGE  AND  FH_FIMVIGE = '')) AND " + " FH_IMPOSTO ='" + cImpuesto + "' "
		cQuery += " AND "
	Endif
	If cPaisLoc == "ARG" .And. cImpuesto == "RMT"
		cQuery += " FH_ZONFIS = 'TU' AND "
		cQuery += " FH_IMPOSTO ='" + cImpuesto + "' AND "
	Endif
	cQuery += " D_E_L_E_T_<>'*'" 
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.) 
	
	(cAlias)->( dbGoTop() )
	
	While !(cAlias)->(Eof())  
		If ((cAlias)->FH_ISENTO = 'S') .OR. ((cAlias)->FH_PERCENT = 100) 
			lNoIsento := .F.
		Endif
		If 	(cAlias)->FH_ALIQ = 0
			lCero := .T.
		Endif  
		If ((Dtos(dDatabase) >= (cAlias)->FH_INIVIGE  .AND.  Dtos(dDatabase) <= (cAlias)->FH_FIMVIGE);
			.OR. (Dtos(dDatabase) >= (cAlias)->FH_INIVIGE  .AND.  (cAlias)->FH_FIMVIGE = ''); 
				.OR. (EMPTY((cAlias)->FH_INIVIGE)  .AND.  EMPTY((cAlias)->FH_FIMVIGE)) )
		lSFH := .T.
		Else
			(cAlias)->(dbSkip())
			LOOP
		Endif
			aAdd( aDatosSFF, {(cAlias)->FH_FORNECE, (cAlias)->FH_LOJA, (cAlias)->FH_IMPOSTO, (cAlias)->FH_ALIQ, (cAlias)->FH_SITUACA ,;
			FH_ZONFIS } )	
			(cAlias)->(dbSkip())
	Enddo
 
		
EndIf
(cAlias)->(dbCloseArea())  
 Return aDatosSFF
