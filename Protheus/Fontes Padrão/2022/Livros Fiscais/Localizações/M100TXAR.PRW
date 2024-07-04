#INCLUDE 'protheus.ch'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณ M100TXAR ณ Autor ณ Jesus Pe๑aloza          ณData  ณ11/07/2014ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Calcula los ingresos brutos de los impuestos                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ M100TXAR                                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ                                                              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ Base, Aliquota y valor del impuesto                          ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑณ PROGRAMADOR  ณ DATA   ณ BOPS ณ  MOTIVO DA ALTERACAO                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ              ณ        ณ      ณ                                          ณฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function M100TxAR(cCalculo,nItem,aInfo,cXFisRap) 
Local lXFis,xRet,nOrdSFC,nRegSFC, nBase, _nAliquota
lOCAL cAliasRot  := Alias()
LOCAL cOrdemRot  := IndexOrd()
LOCAL _NmOEDA	:= 1
Local nI
Local aImpRef, aImpVal, cImpIncid
//Local nValFicto	:=	0
Local nRateio		:=	1

Local nValMin := 0 //JGPL
Local cLib    := ""//JGPL
Local nPos    := 0 //JGPL
Local nX      := 0 //JGPL
Local nBaseTot:= 0 //JGPL
Local lItem   :=.F.//JGPL
Local nSuma   := 0 //JGPL
Local nBas := 0    //JGPL
Local nVal := 0    //JGPL
Local nAli := 0    //JGPL
Local lIb:=.f.             

Local nPosQ:=0
Private cBase  := ""
Private cVal   := ""
Private cAliq  := ""
Private cProd  := ""
Private cTes   := ""  
Private cQuant := ""
Private lFo    := .F.
Default cXFisRap := ""

If FunName() == "MATA143"
	cAliq  := "DBC_ALIMP"
	cBase  := "DBC_BSIMP"
	cVal   := "DBC_VLIMP"
	cTes   := "DBC_TES"
	cProd  := "DBC_CODPRO"
	cQuant := "DBC_QUANT"
	cPreco := "DBC_PRECO"
	lFo    := lFob
ElseIf FunName() == "MATA123"
	cAliq  := "C7_ALQIMP"
	cBase  := "C7_BASIMP"
	cVal   := "C7_VALIMP"
	cTes   := "C7_TES"
	cProd  := "C7_PRODUTO"
	cQuant := "C7_QUANT"
	cPreco := "C7_PRECO"
Else
	cAliq  := "D1_ALQIMP"
	cBase  := "D1_BASIMP"
	cVal   := "D1_VALIMP"
	cTes   := "D1_TES"
	cProd  := "D1_COD"
	cQuant := "D1_QUANT"
	cPreco := "D1_PRECO"
EndIf

If Altera .and. !lFo
	If len(Alltrim(aCols[1][GdFieldPos(cProd)])) != 0
		If Type("lValor") == "L" .and. !lValor
			aValor := {}
			dbSelectArea("SFC")
			SFC->(dbSetOrder(2))
			dbSelectArea("SFB")
			SFB->(dbSetOrder(1))
			For nX := 1 to len(aCols)
				If SFC->(dbSeek(xFilial("SFC")+aCols[nX][GdFieldPos(cTes)]))
					While !SFC->(EOF()) .and. SFC->FC_FILIAL == xFilial("SFC") .and. SFC->FC_TES == aCols[nX][GdFieldPos(cTes)]
						If SFB->(dbSeek(xFilial("SFB")+SFC->FC_IMPOSTO))
							While !SFB->(EOF()) .and. SFB->FB_FILIAL == xFilial("SFB") .and. SFB->FB_CODIGO == SFC->FC_IMPOSTO .and. SFB->FB_CLASSIF == "1"
								cLib := Alltrim(SFB->FB_CPOLVRO)
								nBas := GdFieldPos(cBase+cLib)
								nVal := GdFieldPos(cVal+cLib)
								nAli := GdFieldPos(cAliq+cLib)
								aAdd(aValor, {nX, aCols[nX][nVal], cLib, SFB->FB_CODIGO, aCols[nX][nBas], aCols[nX][nAli]})
								SFB->(dbSkip())
							EndDo
						EndIf
						SFC->(dbSkip())
					EndDo
				EndIf
			Next nX
			lValor := .T.
		EndIf
	EndIf
EndIf

lXfis:=(MaFisFound() .And. ProcName(1)<>"EXECBLOCK")     

If !lXfis
	Return
Else
	//Posiciona impuesto
	SFB->(DbSetOrder(1))
	SFB->(MsSeek(xFilial()+aInfo[1]))
	//Posiciona producto
	SB1->(DbSetOrder(1))
	SB1->(MsSeek(xFilial()+MaFisRet(nItem,"IT_PRODUTO")))
	SFF->(DbSetOrder(7))
	//Busca en la SFF la referencia de clasificaci๓n arancelแria
	If SFF->(DbSeek(xFilial()+ SB1->B1_POSIPI+SB1->B1_EX_NCM+SB1->B1_EX_NBM + aInfo[1] ))
		_nAliquota	:= SFF->FF_ALIQ            
		//Se ้ IIBB rateado, especํfico ARGENTINA
		If 	cPaisLoc == "ARG" .and. SFB->FB_CLASSIF == "1" .AND. SFF->FF_PRALQIB <> 0
			nRateio		:= SFF->FF_PRALQIB/100
			lIb:=.t.
		Endif	
	Else
		_nAliquota	:= SFB->FB_ALIQ
	Endif
	_nMoeda	:=	MaFisRet(,"NF_MOEDA")
	xRet:=0
	//Saca el minimo   
	IF lIb
		If SFF->(dbSeek(xFilial("SFF")+ SB1->B1_POSIPI+SB1->B1_EX_NCM+SB1->B1_EX_NBM + aInfo[1]))
			If SFF->FF_IMPOSTO == SFB->FB_CODIGO .and. SFB->FB_CLASSIF == "1"
				nValMin := SFF->FF_RETENC
			EndIf
		EndIf
	EndIf
	
	If !Empty(cXFisRap)
		nBase:=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")+MaFisRet(nItem,"IT_FRETE")
		//Tira os descontos se for pelo liquido   '
		nOrdSFC:=(SFC->(IndexOrd()))
		nRegSFC:=(SFC->(Recno()))
		SFC->(DbSetOrder(2))
		If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+aInfo[1])))
			If SFC->FC_LIQUIDO=="S"
				nBase -= MaFisRet(nItem,"IT_DESCONTO")
			Endif
			cImpIncid:=Alltrim(SFC->FC_INCIMP)
			//+---------------------------------------------------------------+
			//ฆ Soma a Base de Cแlculo os Impostos Incidentes                 ฆ
			//+---------------------------------------------------------------+
			If !Empty(cImpIncid)
				aImpRef:=MaFisRet(nItem,"IT_DESCIV")
				aImpVal:=MaFisRet(nItem,"IT_VALIMP")
				For nI:=1 to Len(aImpRef)
					If !Empty(aImpRef[nI])
						IF Trim(aImpRef[nI][1])$cImpIncid
							nBase+=aImpVal[nI]
						Endif
					Endif
				Next
			Endif
		Endif
		xRet := {nBase,	_nAliquota,0}
		
		If "V" $ cXFisRap
			xRet[3] := Round(nBase * (_nAliquota / 100),MsDecimais(_nMoeda)) * nRateio
			If SFC->FC_CALCULO=="T"
				nBase := MaRetBasT(aInfo[2],nItem,_nAliquota)
			EndIf
		Endif
		if lIB
			npos:=aScan(aValor,{|x|x[1]==nItem .and. x[3]==aInfo[2]})
			If npos==0
				aadd(aValor,{nItem,Round(nBase * (_nAliquota / 100),MsDecimais(_nMoeda)) * nRateio,aInfo[2],aInfo[1],nbase,_nAliquota})
			Else
				aValor[npos,5]:=nbase
				aValor[npos,6]:=_nAliquota
				aValor[npos,2]:=Round(nBase * (_nAliquota / 100),MsDecimais(_nMoeda)) * nRateio
			Endif
	    Endif
		If "B" $ cXFisRap .AND. lIB
			xRet[3]:=Round(nBase * (_nAliquota / 100),MsDecimais(_nMoeda))*nRateio
			xRet[1]:=nbase
			nSuma:=sumaValor(nItem,aInfo[2])
			If nSuma<=nValMin
				//If !lFo
				xRet[1]:=0
				xRet[3]:=0
				If !lFo
				ReactualizaaCols(nitem,aInfo[2],.T.) 
				EndIf
			Else        
				If !lFo
				ReactualizaaCols(nitem,aInfo[2],.F.)	
				EndIf
			Endif     
		Endif
		SFC->(DbSetOrder(nOrdSFC))
		SFC->(DbGoto(nRegSFC))
	Else
		nBase:=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")+MaFisRet(nItem,"IT_FRETE")
		//Tira os descontos se for pelo liquido
		nOrdSFC:=(SFC->(IndexOrd()))
		nRegSFC:=(SFC->(Recno()))
		SFC->(DbSetOrder(2))
		If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+aInfo[1])))
			cImpIncid:=Alltrim(SFC->FC_INCIMP)
			If SFC->FC_LIQUIDO=="S"
				nBase -= MaFisRet(nItem,"IT_DESCONTO")
			Endif                                               
			//+---------------------------------------------------------------+
			//ฆ Soma a Base de Cแlculo os Impostos Incidentes                 ฆ
			//+---------------------------------------------------------------+
			If !Empty(cImpIncid)
				aImpRef:=MaFisRet(nItem,"IT_DESCIV")
				aImpVal:=MaFisRet(nItem,"IT_VALIMP")
				For nI:=1 to Len(aImpRef)
					If !Empty(aImpRef[nI])
						IF Trim(aImpRef[nI][1])$cImpIncid
							nBase+=aImpVal[nI]
						Endif
					Endif
				Next
			Endif
		Endif
		Do Case
			Case cCalculo=="A"
				xRet := _nAliquota
			Case cCalculo=="B"
				xRet := nBase
			Case cCalculo=="V" 
				If SFC->FC_CALCULO=="T"
					nBase := MaRetBasT(aInfo[2],nItem,_nAliquota)
				EndIf
				xRet := Round(nBase * (_nAliquota / 100),MsDecimais(_nMoeda))*nRateio
				If lIB
					nSuma:=SumaValor(nItem,aInfo[2])
					If nSuma  <=nValMin
						//If !lFo
						xRet := 0
						If !lFo
						ReactualizaaCols(nitem,aInfo[2],.T.)
						EndIf
					Else
						If !lFo
						ReactualizaaCols(nitem,aInfo[2],.F.)
						EndIf
					Endif
				Endif
		Endcase
		SFC->(DbSetOrder(nOrdSFC))
		SFC->(DbGoto(nRegSFC))
	Endif
Endif

dbSelectArea( cAliasRot )
dbSetOrder( cOrdemRot )

Return( xRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณSumaValor บAutor  ณ                    บ Data ณ  24/07/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณSuma el valor de la base del impuesto                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณM100TXAR                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function SumaValor(nItem,cLib)
Local nsum:=0     
Local nx:=0    
Local nDeleted:= GdFieldPos("GDDELETED",aHeader)
For nx:=1 to len(aValor)
	If  cLib==avalor[nx,3] .and. !acols[avalor[nx,1],nDeleted]
		nSum+=avalor[nx,5]
	Endif
Next
Return nSum

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณReactualizaaCols ณ                     บ Data ณ  24/07/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณReactualiza el valor del arreglo aCols, si la suma de la    บฑฑ
ฑฑบ          ณbase del impuesto es mayor a la retencion indicada en la    บฑฑ
ฑฑบ          ณtabla SFF, entonces actualiza su base y valor, de lo        บฑฑ
ฑฑบ          ณcontrario, actualizara dichos valores con 0                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณM100TXAR                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ReactualizaaCols (nitem,cLib,lZera)
Local nx:=0
Local npos:=0
Local nDeleted:= GdFieldPos("GDDELETED",aHeader)
Local nPosB:= GdFieldPos(cBase+cLib,aHeader)
Local nPosA:= GdFieldPos(cAliq+cLib,aHeader)
Local nPosV:= GdFieldPos(cVal+cLib,aHeader)
Local nBasT:=0
Local nValT:=0

For nX := 1 to len(aCols)
//if nx<> nitem
	If lzera .or. acols[nx,nDeleted]
		aCols[nx,nPosB]:=0
		aCols[nx,nPosA]:=0
		aCols[nx,nPosV]:=0
	Else
		npos:=aScan(aValor,{|x|x[1]==nx .and. x[3]==cLib})
		If npos>0
			aCols[nx,nPosB]:=aValor[nPOS][5]
			aCols[nx,nPosA]:=aValor[nPOS][6]
			aCols[nx,nPosV]:=aValor[nPOS][2]
		EndIf
 	EndIf
		ActItemNf(nx,val(RETASC(cLib,2,.F.)),{aCols[nx,nPosB],aCols[nx,nPosA],aCols[nx,nPosV]},lzera)
		nBasT+=aCols[nx,nPosB]
		nValT+=aCols[nx,nPosV]
//endif
Next
ActCabNf(val(RETASC(cLib,2,.F.)),aInfo[1],nBasT,nValT)
Return
