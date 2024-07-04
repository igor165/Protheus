/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ M100RIV	³ Autor ³ MARCELLO GABRIEL     ³ Data ³ 21.07.2000 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ CALCULO IVA SERVICO (retencao) - MEXICO                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Generico                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Percy Horna  ³19/10/00³xxxxxx³Fue alterada a base de datos de Excep-   ³±±
±±³              ³        ³      ³ciones de SF7->SFF, inicialmente utili-  ³±±
±±³              ³        ³      ³zando los Impuestos de IESPS (mejico).   ³±±
±±³ Jeniffer     ³19/01/01³xxxxxx³Variavel xRet deve ser declarada como    ³±±
±±³              ³        ³      ³array.                                   ³±±
±±³ Jeniffer     ³19/01/01³xxxxxx³Defnicao do array xRet deve ser feita nao³±±
±±³              ³        ³      ³somente para Proveedores "pessoa fisica  ³±±
±±³              ³        ³      ³ou pequeno contribuinte."                ³±±
±±³ Dora Vega    ³09/05/17³  MMI-³Merge de replica de llamado TTLTCF.Calcu-³±±
±±³              ³        ³   306³lo de retencion de IVA, sobre IVA.(MEX)  ³±±
±±³ Oscar G.     ³29/10/19³DMINA-³Se realiza uso de fun. Round() para el   ³±±
±±³              ³        ³ 7586 ³calculo de valor de impuesto. (MEX)      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION M100RIV(cCalculo,nItem,aInfo)
	local cDbf := alias()
	Local nOrd := IndexOrd()
	Local xRet
	Local aItem
	Local lXFis
	Local cImp
	Local cFil
	local cAux
	Local nBase := 0
	Local nAliq := 0
	Local lIsento := .F.
	Local lALIQ := .F.
	Local nColTES
	local nCD
	Local nReg
	Local cImpIn
	Local nOrdSFC
	Local nPos
	Local nMoeda 	:= 0
	Local nTaxaMoed := 0
	Local cImpIncid := ""
	Local cAlias := IIf(Type("M->F1_FORNECE")=="C" ,"SF1",Iif (Type("M->F2_CLIENTE")=="C","SF2",""))
	Local aImpRef := {}
	Local aImpVal := {}
	Local nI := 0
          
	SetPrvt("CALIASROT,CORDEMROT,AITEMINFO,AIMPOSTO,_CPROCNAME,_CZONCLSIGA")
	SetPrvt("_LAGENTE,_LCALCULAR,_LESLEGAL,_NALICUOTA,_NVALORMIN,_NALICDESG")
	SetPrvt("_NREDUCIR,")

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ A variavel ParamIxb tem como conteudo um Array[2,?]:          ³
³                                                               ³
³ [1,1] > Quantidade Vendida                     		        ³
³ [1,2] > Preco Unitario                            	        ³
³ [1,3] > Valor Total do Item, com Descontos etc...             ³
³ [1,4] > Valor do Frete Rateado para Este Item ...             ³
³ [1,5] > Array Contendo os Impostos j  calculados, no caso de  ³
³         incidˆncia de outros impostos.                        ³
³ [2,?] > Array xRetosto, Contendo as Informa‡oes do Imposto que³
³         ser  calculado.                                       ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
	dbselectarea("SFF")
	dbSetOrder(3)
     
	cFil:=xfilial()
	lXFis:=(MafisFound() .And. ProcName(1)<>"EXECBLOCK")

	_cProcName := "M100RIV"
                
	aFiscal    := ExecBlock("IMPGENER",.F.,.F.,{If(lXFis,{cCalculo,nItem,aInfo},ParamIxb), _cProcName, _lAgente,_cZonClSIGA,lXFis,},.T.)
	_nMoeda    :=  aFiscal[7]
	_nAlicDesg :=  aFiscal[11]
	_nReducir  :=  aFiscal[5]

	If !lXfis
		aItem:=ParamIxb[1]
		xRet:=ParamIxb[2]
		cImp:=xRet[1]
   
		If Upper(FunName()) == "MATA121"
			If SC7->(FieldPos("C7_PROVENT")) > 0
				If Type("cA120ProvEnt")=="C" .And. !Empty(cA120ProvEnt)
					_cZonClSIGA := cA120ProvEnt
				Elseif Type("cA120ProvEnt")=="C" .And. Empty(cA120ProvEnt)
					_cZonClSIGA := SA2->A2_EST
				Endif
			Else
				_cZonClSIGA := SA2->A2_EST
			Endif
		Else
		//Factura de Entrada
			If Type("M->F1_PROVENT")=="C" .And. !Empty(M->F1_PROVENT)
				_cZonClSIGA := M->F1_PROVENT
			Elseif Type("M->F1_PROVENT")=="C" .And. Empty(M->F1_PROVENT)
				_cZonClSIGA := SA2->A2_EST
			Else
				_cZonClSIGA:= SM0->M0_ESTENT
			Endif
		Endif
	Else
		cImp:=aInfo[1]
		SB1->(DbGoto(MaFisRet(nItem,"IT_RECNOSB1")))
		xRet:=0
		_cZonClSIGA:= If(cPaisLoc=="ARG", IIF( Upper(FunName()) == "MATA143" , MaFisRet(,"NF_PROVENT") , MaFisRet(nItem,"IT_PROVENT") ) ,SM0->M0_ESTENT) // Zona Fiscal del Cliente SIGA
	Endif
   
	If cPaisloc =="URU" .or. SA2->A2_TIPO$"FP2"  //pessoa fisica ou "pequeno contribuyente"
		If cPaisLoc<>"URU"
			dbselectarea("SFF")     // verificando as excecoes fiscais
			if dbseek(cFil+cImp)
				while FF_IMPOSTO == cImp .and. FF_FILIAL==cFil .and. !lAliq
					cAux:=Alltrim(FF_GRUPO)
					if cAux!=""
						lAliq:=(cAux==alltrim(SB1->B1_GRUPO))
					endif
					cAux:=alltrim(FF_ATIVIDA)
					if cAux!=""
						lAliq:=(cAux==alltrim(SA1->A1_ATIVIDA))
					endif
					if lAliq
						if !(lIsento:=(FF_TIPO=="S"))
							nAliq:=FF_ALIQ
						endif
					endif
					dbskip()
				enddo
			endif
		EndIf
		if !lIsento
			if If(!lXFis,(nColTES:=ascan(aHeader,{|x| "_TES"$x[2]}))!=0,.T.)
				cAux:=If(!lXFis,Trim(aCols[n,nColTes]),MaFisRet(nItem,"IT_TES"))
				If cAux==""
					cAux:="M->"+Trim(aHeader[nColTes][2])
					cAux:=&cAux
				Endif
				dbselectarea("SFC")
				nOrdSFC:=indexord()
				nReg:=recno()
				dbsetorder(2)
				if dbseek(xfilial("SFC")+cAux+cImp)
					cImpIn:= Iif(AllTrim(FC_INCIMP)<> "", FC_INCIMP, FC_IMPOSTO)
					if !lAliq
						if (SFB->(dbseek(xfilial("SFB")+cImp))) // busca a aliquota padrao
							nAliq:=SFB->FB_ALIQ
						endif
					endif
					If !lXfis
						nCD:=ascan(aItem[6],{|x| x[1]==cImpIn})
						If nCD!=0
							nBase:=aItem[6][nCD][4]
						Endif
					Else
						If cCalculo=="B"
							If (SFB->(DbSeek(xFilial("SFB")+cImpIn)))
								aImpRef:=MaFisRelImp("MT100",{"SD1"})
								If (nPos:=Ascan(aImpRef,{|x| x[2]=="D1_VALIMP"+SFB->FB_CPOLVRO}))>0
									cAux:=aImpRef[nPos,3]
									nBase:=MaFisRet(nItem,"IT_BASE"+Right(cAux,3))*(MaFisRet(nItem,"IT_ALIQ"+Right(cAux,3))/100)
								Endif
							Endif
						Endif
					Endif
				endif
				dbsetorder(nOrdSFC)
				dbgoto(nReg)
			endif
		endif
	endif
  
	nCD:=getmv("MV_RNDLOC")
	If !lXfis
		xRet[02]:=nAliq
		xRet[03]:=nBase
		xRet[04]:=nBase*(nAliq/100)
		If cPaisLoc$"MEX"
			xRet[04] := Round(xRet[04], nCD)
		Else
			cImpIn:=str(xRet[04],,nCD+1)
			xRet[04]:=val(left(cImpIn,len(cImpIn)-1))
		EndIf
	Else
		Do Case
		Case cCalculo=="B"
            //Verifica se tem imposto incidente.
			SFC->(DbSetOrder(2))
			If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+aInfo[1])))
				cImpIncid := Alltrim(SFC->FC_INCIMP)
			Endif
				
            //+---------------------------------------------------------------+
            //¦ Soma a Base de Cálculo os Impostos Incidentes                 ¦
            //+---------------------------------------------------------------+            
			If !Empty(cImpIncid)
				nBase := 0
				aImpRef := MaFisRet(nItem,"IT_DESCIV")
				aImpVal := MaFisRet(nItem,"IT_VALIMP")
				For nI := 1 to Len(aImpRef)
					If !Empty(aImpRef[nI])
						IF Trim(aImpRef[nI][1])$cImpIncid
							nBase += aImpVal[nI]
							xRet := nBase
						Endif
					Endif
				Next
			Endif
           
			If cPaisLoc <> "MEX"
				nBase += MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
			EndIf
           
			xRet:=nBase
			DbSelectArea("SFF")
			SFF->(DbSetOrder(9))
			DbSeek(xFilial("SFF") + cImp)
			SFC->(DbSetOrder(2))
			If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+aInfo[1]))) .And. cImp = "RI2"
				If SFC->FC_CALCULO=="I"
					If cPaisLoc=="URU"
						nBaseAtu:=nBase
						If (SFB->(DbSeek(xFilial("SFB")+cImpIn)))
							aImpRef:=MaFisRelImp("MT100",{"SD1"})
							If (nPos:=Ascan(aImpRef,{|x| x[2]=="D1_VALIMP"+SFB->FB_CPOLVRO}))>0
								cAux:=aImpRef[nPos,3]
								nBaseAtu:=MaFisRet(nItem,"IT_BASE"+Right(cAux,3))
							Endif
						Endif
						If nBaseAtu >= xMoeda(SFF->FF_IMPORTE,SFF->FF_MOEDA,1)
							xRet:=nBase
						Else
							xRet:= 0
						Endif
					Else
						If nBase >= xMoeda(SFF->FF_IMPORTE,SFF->FF_MOEDA,1)
							xRet:=nBase
						Else
							xRet:= 0
						Endif
					EndIf
				Endif
			EndIf
       Case cCalculo=="A"
             If (SFB->(DbSeek(xFilial("SFB")+cImp)))
                nAliq:=SFB->FB_ALIQ
             endIf 
             xRet:=nALiq
		Case cCalculo=="V"
			DbSelectArea("SFF")
			SFF->(DbSetOrder(9))
			SFF->(DbGoTop())
			If DbSeek(xFilial("SFF") + cImp)
				nAliq:=SFF->FF_ALIQ
				lRet := .T.
			Endif
			If nAliq == 0
				If (SFB->(DbSeek(xFilial("SFB")+cImp)))
					nAliq:=SFB->FB_ALIQ
				endIf
			EndIf
			nTaxaMoed := 0
			nMoeda := 1
			If Type("M->F1_MOEDA")<>"U"
				nMoeda := M->F1_MOEDA
				nTaxaMoed := M->F1_TXMOEDA
			ElseIf Type("M->C7_MOEDA")<>"U"
				nMoeda := M->C7_MOEDA
				nTaxaMoed := M->C7_TXMOEDA
			ElseIf Type("M->F2_MOEDA")<>"U"
				nMoeda := M->F2_MOEDA
				nTaxaMoed := M->F2_TXMOEDA
			ElseIf Type("M->C5_MOEDA")<>"U"
				nMoeda := M->C5_MOEDA
				nTaxaMoed := M->C5_TXMOEDA
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Converte a base para a moeda 1 para que seja feito  o 
			//a somatória com o acumulado da SFE que é moeda 1	   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SFC->FC_CALCULO=="T"
				nBase:= MaFisRet(,'NF_BASEIV'+aInfo[2])+ nBase
				nBaseAtu := xMoeda(nBase,nMoeda,1,Nil,Nil,nTaxaMoed)
			Else
				nBase:= MaFisRet(nItem,'IT_BASEIV'+aInfo[2])
				nBaseAtu:=nBase
				If cPaisLoc == "MEX"
					cImpIn := aInfo[1]
				EndIf
				If (SFB->(DbSeek(xFilial("SFB")+cImpIn)))
					aImpRef:=MaFisRelImp("MT100",{"SD1"})
					If (nPos:=Ascan(aImpRef,{|x| x[2]=="D1_VALIMP"+SFB->FB_CPOLVRO}))>0
						cAux:=aImpRef[nPos,3]
						nBaseAtu:=MaFisRet(nItem,"IT_BASE"+Right(cAux,3))
					Endif
				Endif
				nBaseAtu := xMoeda(nBaseAtu,nMoeda,1,Nil,Nil,nTaxaMoed)
			EndIf
		     
			If SFF->(FieldPos("FF_IMPORTE")) >0    .And. SFF->(FieldPos("FF_IMPOSTO ")) >0    .And.  SFF->(FieldPos("FF_MOEDA")) >0
				If cPaisLoc=="URU"
					aValRet := RetValIR("RI2")
				Else
					aValRet := {0,0}
				EndIf
				//aValRet[01] = base acumulada
				//aValRet[02] = retencao acumulada 
				nBase:=MaFisRet(nItem,"IT_BASEIV"+aInfo[2])
				nBaseAtu:=nBase
				If (nBaseAtu+aValRet[1]) >= xMoeda(SFF->FF_IMPORTE,SFF->FF_MOEDA,1)
					SFC->(DbSetOrder(2))
					If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+aInfo[1]))) //.And. (SFF->FF_IMPOSTO = 'RI2')
						If SFC->FC_CALCULO=="T"
							If nBase >=  MaFisRet(,"NF_MINIV"+aInfo[2])
								xRet := (( nBase  + aValRet[1])*(nAliq/100))-aValRet[2]
								xRet := IIf(xRet>0,xRet,0)
							Endif
						Else
							xRet := ((nBase+aValRet[01])*(nAliq/100)) - Iif(aValRet[01]>0,aValRet[2],0)
							xRet := IIf(xRet>0,xRet,0)
						Endif
					Endif
				Else
					xRet := 0
				EndIF
			Else
				nBase:=MaFisRet(nItem,"IT_BASEIV"+aInfo[2])
				nAliq:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[2])
				xRet:=(nAliq * nBase)/100
				If cPaisLoc$"MEX"
					xRet:=Round(xRet, nCD)
				Else
					cImpIn:=str(xRet,,nCD+1)
					xRet:=val(left(cImpIn,len(cImpIn)-1))
				EndIf
			EndIf
		EndCase
	Endif

	dbSelectarea(cDbf)
	dbSetOrder(nOrd)
RETURN(xRet)


Static Function M100VLNC(cTipo,cAlias,cProv)
	Local nBaseAbt:=0
	Local nx:= 1
	Local aNFEDev:={}
	Local nPos:=0
	Local lVeriPrv:= .F.
	Local aAreaAtu:={}
	Local cTipCalc:="0"
	Local lDesc:= .T.
	Local nBasDev:=0
	Local aAliasSF1:=SF1->(GetArea())
	Local aAliasSF2:=SF2->(GetArea())

	If AliasInDic("CCO") .And. CCO->(FieldPos("CCO_CPERNC")) > 0
		aAreaAtu:=GetArea()
		CCO->(DbSetOrder(1))
		If CCO->(DbSeek(xFilial("CCO") + cProv) )  .And. !(CCO->CCO_CPERNC $ " 1")
			lVeriPrv:=.T.
			cTipCalc := CCO->CCO_CPERNC
		EndIf
		RestArea(aAreaAtu)
	EndIf
		    

	If Type("aCols")=="A" .And. lVeriPrv
		For nx:= 1 to n
			If !(aCols[nx][Len(aCols[nx])])
				nPos:=aScan(aNFEDev,{|x|x[1]==MaFisRet(nx,"IT_NFORI")+MaFisRet(nx,"IT_SERORI")} )
				nBasDev:=MaFisRet(nX,"IT_VALMERC")
				If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nX,"IT_TES")+aInfo[1])))
					cImpIncid:=Alltrim(SFC->FC_INCIMP)
					If SFC->FC_LIQUIDO=="S"
						nBasDev-= MaFisRet(nX,"IT_DESCONTO")
					Endif
				Endif
				If nPos >0
					aNFEDev[nPos][2]:= aNFEDev[nPos][2]+nBasDev
				Else
					Aadd(aNFEDev,{MaFisRet(nX,"IT_NFORI")+MaFisRet(nX,"IT_SERORI"),nBasDev})
				EndIf
			EndIf
		Next
					
		For nX:=1 to Len(aNFEDev)
			If cAlias== "SF2
				cColLiv:="SF1->F1_BASIMP"+aInfo[2]
				If SF1->(DbSeek(xFilial("SF1")+ aNFEDev[nX][1] +M->F2_CLIENTE+M->F2_LOJA,.F.))
					If cTipCalc== "2" .And. aNFEDev[nX][2] == &(cColLiv)
						lDesc:=.F.
					                                               
					ElseIf cTipCalc== "3" .And. Month(M->F2_EMISSAO) == Month(SF1->F1_EMISSAO) .And. Year(M->F2_EMISSAO)== Year(SF1->F1_EMISSAO)
						lDesc:=.F.
				
					ElseIF cTipCalc== "4" .And. Month(M->F2_EMISSAO) == Month(SF1->F1_EMISSAO) .And. Year(M->F2_EMISSAO) == Year(SF1->F1_EMISSAO) ;
							.And.  aNFEDev[nX][2] == &(cColLiv)
						lDesc:=.F.
					EndIf
				
					If lDesc
						nBaseAbt:= nBaseAbt +aNFEDev[nX][2]
					EndIf
				
				EndIf
			ElseIf cAlias== "SF1
				cColLiv:="SF2->F2_BASIMP"+aInfo[2]
				If SF2->(DbSeek(xFilial("SF2")+ aNFEDev[nX][1] +M->F1_FORNECE+M->F1_LOJA,.F.))
					If cTipCalc== "2" .And. aNFEDev[nX][2] == &(cColLiv)
						lDesc:=.F.
					                                               
					ElseIf cTipCalc== "3" .And. Month(M->F1_EMISSAO) == Month(SF2->F2_EMISSAO) .And. Year(M->F1_EMISSAO)== Year(SF2->F2_EMISSAO)
						lDesc:=.F.
				
					ElseIF cTipCalc== "4" .And. Month(M->F1_EMISSAO) == Month(SF2->F2_EMISSAO) .And. Year(M->F1_EMISSAO) == Year(SF2->F2_EMISSAO);
							.And.  aNFEDev[nX][2] == &(cColLiv)
						lDesc:=.F.
					EndIf
				
					If lDesc
						nBaseAbt:= nBaseAbt +aNFEDev[nX][2]
					EndIf
				EndIf
			EndIf
		Next
	EndIf
	SF1->(RestArea(aAliasSF1))
	SF2->(RestArea(aAliasSF2))
Return(nBaseAbt)            	
