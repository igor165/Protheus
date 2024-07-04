#INCLUDE "Protheus.ch"

//Posicoes  do terceiro array recebido nos impostos a traves da matxfis...
#DEFINE X_IMPOSTO    01  //Nome do imposto
#DEFINE X_NUMIMP     02  //Sufixo do imposto

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ M460ISC  ³ Autor ³ Ivan Haponczuk      ³ Data ³ 21.10.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Calculo do ISC - Saida                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cPar01 - Solicitacao da MATXFIS, pondendo ser A (aliquota),³±±
±±³          ³          B (base), V (valor).                              ³±±
±±³          ³ nPar02 - Item do documento fiscal.                         ³±±
±±³          ³ aPar03 - Array com as informacoes do imposto.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ xRet - Retorna o valor solicitado pelo paremetro cPar01    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³ Uso      ³ MATXFIS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M460ISC(cCalculo,nItem,aInfo)

	Local xRet
	Local cFunct   := ""
	Local aCountry := {}
	Local lXFis    := .T.
	Local aArea    := GetArea()
	
	lXFis    := ( MafisFound() .And. ProcName(1)!="EXECBLOCK" )
	aCountry := GetCountryList()
	cFunct   := "M460ISC" + aCountry[aScan( aCountry, { |x| x[1] == cPaisLoc } )][3] //monta nome da funcao
	xRet     := &(cFunct)(cCalculo,nItem,aInfo,lXFis) //executa a funcao do pais

	RestArea(aArea)

Return xRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ M460ISCRD ³ Autor ³ Ivan Haponczuk      ³ Data ³ 21.10.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Calculo do ISC - Saida - Republica Domicana                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cPar01 - Solicitacao da MATXFIS, pondendo ser A (aliquota), ³±±
±±³          ³          B (base), V (valor).                               ³±±
±±³          ³ nPar02 - Item do documento fiscal.                          ³±±
±±³          ³ aPar03 - Array com as informacoes do imposto.               ³±±
±±³          ³ lPar04 - Define se e rotina automaticao ou nao.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ xRet - Retorna o valor solicitado pelo paremetro cPar01     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Republica Dominicana                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M460ISCRD(cCalculo,nItem,aInfo)

	Local nBase    := 0
	Local nAliq    := 0 
	Local nValor   := 0
	Local nMargem  := 0
	Local nFatConv := 0
	Local cConcept := ""
	Local cProduto := ""
	Local aItem    := {}
	Local aArea    := GetArea()
	
	If !lXFis
		aItem    := ParamIxb[1]
		xRet     := ParamIxb[2]
		cImp     := xRet[1]
		cProduto := xRet[16]
	Else
		xRet     := 0
		cProduto := MaFisRet(nItem,"IT_PRODUTO")
		cImp     := aInfo[X_IMPOSTO]
	EndIf
	
	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	If SB1->(dbSeek(xFilial("SB1")+cProduto))
		cConcept := SB1->B1_CONISC
		nMargem  := SB1->B1_MARGISC
		If SB1->B1_FATISC == 0
			nFatConv := 1
		Else
			nFatConv := SB1->B1_FATISC
		EndIf
	EndIf
	
	If If(!lXFis,.T.,cCalculo=="A")
		
		// Aliquota padrao
		dbSelectArea("SFB")
		SFB->(dbSetOrder(1))
		If SFB->(dbSeek(xFilial("SFB")+cImp))
			nAliq := SFB->FB_ALIQ
		Endif
		
		dbSelectArea("CCR")
		CCR->(dbSetOrder(1))//CCR_FILIAL+CCR_CONCEP+CCR_PAIS
		If CCR->(dbSeek(xFilial("CCR")+cConcept))
			If !Empty(CCR->CCR_ALIQ)
				nAliq := CCR->CCR_ALIQ
			EndIf
			nValor := CCR->CCR_VALOR
		EndIf
		
	EndIf
	
	If !lXFis
		nMargem := (nMargem * aItem[3])/100
		nBase:=aItem[3]+aItem[4]+aItem[5]+nMargem //valor total + frete + outros impostos
		xRet[02]:=nAliq
		xRet[03]:=nBase
		//Tira os descontos se for pelo liquido .Bruno
		If Subs(xRet[5],4,1) == "S" .And. Len(xRet) >= 18 .And. ValType(xRet[18])=="N"
			xRet[3]-=xRet[18]
			nBase:=xRet[3]
		Endif
		xRet[04]:=(nAliq * nBase)/100
		xRet[04]+=(nValor*(aItem[1]*nFatConv))
	Else
		Do Case
			Case cCalculo=="B"
				nMargem := (nMargem * MaFisRet(nItem,"IT_VALMERC"))/100
				xRet:=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")+nMargem
				If GetNewPar("MV_DESCSAI","1")=="1" .and. FunName() == "MATA410"
					xRet += MaFisRet(nItem,"IT_DESCONTO")
				Endif
				//Tira os descontos se for pelo liquido]
				dbSelectArea("SFC")
				SFC->(DbSetOrder(2))
				If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+aInfo[X_IMPOSTO])))
					If SFC->FC_LIQUIDO=="S"
						xRet-=If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
					Endif
				Endif
			Case cCalculo=="A"
				xRet:=nALiq
			Case cCalculo=="V"
				dbSelectArea("CCR")
				CCR->(dbSetOrder(1))//CCR_FILIAL+CCR_CONCEP+CCR_PAIS
				If CCR->(dbSeek(xFilial("CCR")+cConcept))
					nValor := CCR->CCR_VALOR
				EndIf
				nAliq:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[X_NUMIMP])
				nBase:=MaFisRet(nItem,"IT_BASEIV"+aInfo[X_NUMIMP])
				xRet:=(nAliq * nBase)/100
				xRet+=(nValor*(MaFisRet(nItem,"IT_QUANT")*nFatConv))
		EndCase
	EndIf
	
	RestArea(aArea)
Return xRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ M460ISCCR ³ Autor ³ Camila Januario     ³ Data ³ 07.10.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Calculo do ISC - Saida - Costa Rica                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cPar01 - Solicitacao da MATXFIS, pondendo ser A (aliquota), ³±±
±±³          ³          B (base), V (valor).                               ³±±
±±³          ³ nPar02 - Item do documento fiscal.                          ³±±
±±³          ³ aPar03 - Array com as informacoes do imposto.               ³±±
±±³          ³ lPar04 - Define se e rotina automaticao ou nao.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ xRet - Retorna o valor solicitado pelo paremetro cPar01     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Costa Rica                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M460ISCCR(cCalculo,nItem,aInfo,lXFis)

	Local nBase    := 0
	Local nAliq    := 0
	Local cConcept := ""
	Local cProduto := ""
	Local aItem    := {}
	Local aArea    := GetArea()
	Local lCalcISC := .F.
	Local nDecs := 0
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica os decimais da moeda para arredondamento do valor  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nDecs := IIf(Type("nMoedaNf") # "U",MsDecimais(nMoedaNf),MsDecimais(1))
	
	If !lXFis
		aItem    := ParamIxb[1]
		xRet     := ParamIxb[2]
		cImp     := xRet[1]
		cProduto := xRet[16]
	Else
		xRet     := 0
		cProduto := MaFisRet(nItem,"IT_PRODUTO")
		cImp     := aInfo[X_IMPOSTO]
	EndIf
	
	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))
  	If SB1->(dbSeek(xFilial("SB1")+cProduto))
		cConcept := SB1->B1_CONISC
		lCalcISC := IIF(SB1->B1_CALCISC=="1",.T.,.F.)
	EndIf
	
	If If(!lXFis,.T.,cCalculo=="A")
		
		// Aliquota padrao
		dbSelectArea("SFB")
		SFB->(dbSetOrder(1))
		If SFB->(dbSeek(xFilial("SFB")+cImp))
			nAliq := SFB->FB_ALIQ
		Endif
		
		dbSelectArea("CCR")
		CCR->(dbSetOrder(1))//CCR_FILIAL+CCR_CONCEP+CCR_PAIS
	 	If CCR->(dbSeek(xFilial("CCR")+cConcept))		
			nAliq := CCR->CCR_ALIQ		
		EndIf
	EndIf
	
	If !lXFis .and. lCalcISC
		nBase:=aItem[3]+aItem[4]+aItem[5] //valor total + frete + outros impostos
		xRet[02]:=nAliq
		xRet[03]:=nBase
		If Subs(xRet[5],4,1) == "S" .And. Len(xRet) >= 18 .And. ValType(xRet[18])=="N"
			xRet[3]-=xRet[18]
			nBase:=xRet[3]
		Endif
		xRet[04]:=(nAliq * nBase)/100      
		xRet[04]:=Round(xRet[04],nDecs)	
	Else
		If lCalcISC
			Do Case
				Case cCalculo=="B"
			   		xRet:=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
					If GetNewPar("MV_DESCSAI","1")=="1" 
						xRet += MaFisRet(nItem,"IT_DESCONTO")
					Endif
					//Tira os descontos se for pelo liquido
					dbSelectArea("SFC")
					SFC->(DbSetOrder(2))
					If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+aInfo[X_IMPOSTO])))
						If SFC->FC_LIQUIDO=="S"
							xRet-=If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
						Endif
					Endif
				Case cCalculo=="A"
					xRet:=nALiq
				Case cCalculo=="V"	
					nAliq:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[X_NUMIMP])
					nBase:=MaFisRet(nItem,"IT_BASEIV"+aInfo[X_NUMIMP])
					xRet:=(nAliq * nBase)/100
					xRet:=Round(xRet,nDecs)
			EndCase
		Endif	
	EndIf
	
	RestArea(aArea)
Return xRet 


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ M460ISCCO ³ Autor ³ Paulo Pouza     ³ Data ³ 10.03.2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Calculo do ISC - Saida - Colombia                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cPar01 - Solicitacao da MATXFIS, pondendo ser A (aliquota), ³±±
±±³          ³          B (base), V (valor).                               ³±±
±±³          ³ nPar02 - Item do documento fiscal.                          ³±±
±±³          ³ aPar03 - Array com as informacoes do imposto.               ³±±
±±³          ³ lPar04 - Define se e rotina automaticao ou nao.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ xRet - Retorna o valor solicitado pelo paremetro cPar01     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Colombia                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M460ISCCO(cCalculo,nItem,aInfo,lXFis)

Local nBase    := 0
Local nAliq    := 0
Local aItem    := {}
Local aArea    := GetArea()
Local nDecs := 0
Local cCFO := "" 
//ÚÄÄÄÄÄÄÄÄÄÄÄ
ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica os decimais da moeda para arredondamento do valor  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nDecs := IIf(Type("nMoedaNf") # "U",MsDecimais(nMoedaNf),MsDecimais(1))
	
If !lXFis
	aItem    := ParamIxb[1]
	xRet     := ParamIxb[2]
	cImp     := xRet[1]   
	cCFO := SF4->F4_CF
Else
	xRet     := 0
	cImp     := aInfo[X_IMPOSTO]    
	cCFO := MaFisRet(nItem,"IT_CF")
EndIf
	
dbSelectArea("SFB")
SFB->(dbSetOrder(1))
If SFB->(dbSeek(xFilial("SFB")+cImp))
	nAliq := SFB->FB_ALIQ
Endif
	
DbSelectArea("SFF")
SFF->(DbSetOrder(6))
SFF->(DbGoTop())
If dbSeek(xFilial("SFF") +cImp + cCFO) 
	nAliq := SFF->FF_ALIQ
EndIf	
	
	
If !lXFis 
	nBase:=aItem[3]+aItem[4]+aItem[5] //valor total + frete + outros impostos
	xRet[02]:=nAliq
	xRet[03]:=nBase
	If Subs(xRet[5],4,1) == "S" .And. Len(xRet) >= 18 .And. ValType(xRet[18])=="N"
		xRet[3]-=xRet[18]
		nBase:=xRet[3]
	Endif
	xRet[04]:=(nAliq * nBase)/100      
	xRet[04]:=Round(xRet[04],nDecs)	
Else
	Do Case
		Case cCalculo=="B"
	   		xRet:=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
			If GetNewPar("MV_DESCSAI","1")=="1" 
				xRet += MaFisRet(nItem,"IT_DESCONTO")
			Endif
			//Tira os descontos se for pelo liquido
			dbSelectArea("SFC")
			SFC->(DbSetOrder(2))
			If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+aInfo[X_IMPOSTO])))
				If SFC->FC_LIQUIDO=="S"
					xRet-=If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
				Endif
			Endif
		Case cCalculo=="A"
			xRet:=nALiq
		Case cCalculo=="V"	
			nAliq:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[X_NUMIMP])
			nBase:=MaFisRet(nItem,"IT_BASEIV"+aInfo[X_NUMIMP])
			xRet:=(nAliq * nBase)/100
			xRet:=Round(xRet,nDecs)
	EndCase
Endif	
	
RestArea(aArea)
Return xRet        


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ M460iscPA ³ Autor ³ Marcio Nunes        ³ Data ³ 22.03.2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Calculo do ISC - Destacado - Saida - Paraguai               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cPar01 - Solicitacao da MATXFIS, pondendo ser A (aliquota), ³±±
±±³          ³          B (base), V (valor).                               ³±±
±±³          ³ nPar02 - Item do documento fiscal.                          ³±±
±±³          ³ aPar03 - Array com as informacoes do imposto.               ³±±
±±³          ³ lPar04 - Define se e rotina automaticao ou nao.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ xRet - Retorna o valor solicitado pelo paremetro cPar01     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Paraguai                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function M460iscPA(cCalculo,nItem,aInfo)

Local aImp 			:= {}
Local aItem 		:= {}                                                        
Local aArea			:= GetArea()
Local cImp			:= ""
Local cTes   		:= ""
Local cProd			:= ""
Local cImpIncid		:= ""
Local nOrdSFC   	:= 0    
Local nRegSFC   	:= 0
Local nBase			:= 0
Local nAliq 		:= 0
Local xRet                                              
Local nValMerc		:= 0
Local nAliqAg		:= 0
Local nDecs 		:= 0
Local nMoeda 		:= 1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Identifica se a chamada da funcao do calculo do imposto esta sendo ³
//³feita pela matxfis ou pelas rotinas manuais do localizado.         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lXFis := (MafisFound() .And. ProcName(1)!="EXECBLOCK")

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Observacao :                                                                  ³
³                                                                               ³
³ A variavel ParamIxb tem como conteudo um Array[2], contendo :                 ³
³ [1,1] > Quantidade Vendida                                                    ³
³ [1,2] > Preco Unitario                                                        ³
³ [1,3] > Valor Total do Item, com Descontos etc...                             ³
³ [1,4] > Valor do Frete rateado para este Item                                 ³
³         Para Portugal, o imposto do frete e calculado em separado do item     ³
³ [1,5] > Valor das Despesas rateado para este Item                             ³
³         Para Portugal, o imposto das despesas e calculado em separado do item ³
³ [1,6] > Array Contendo os Impostos já calculados, no caso de incidência de    ³
³         outros impostos.                                                      ³
³ [2,1] > Array aImposto, contendo as Informações do Imposto que será calculado.³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
If !lXfis
	aItem		:= ParamIxb[1]
	aImp		:= ParamIxb[2]
	cImp		:= aImp[1]
	cImpIncid	:= aImp[10]
	cTes		:= SF4->F4_CODIGO
	cProd 		:= SB1->B1_COD
Else
   cImp			:= aInfo[1]
   cTes			:= MaFisRet(nItem,"IT_TES")
   cProd		:= MaFisRet(nItem,"IT_PRODUTO")
   nValMerc		:= MaFisRet(nItem,"IT_VALMERC")   
Endif     

	If Type("M->F1_MOEDA")<>"U" 
		nMoeda:= M->F1_MOEDA      
	ElseIf Type("M->C7_MOEDA")<>"U"
		nMoeda:= M->C7_MOEDA    
	ElseIf Type("M->F2_MOEDA")<>"U" 
		nMoeda:= M->F2_MOEDA    
	ElseIf Type("M->C5_MOEDA")<>"U"
		nMoeda:= M->C5_MOEDA      
	ElseIf Type("nMoedaPed")<>"U"	 
		nMoeda:= nMoedaPed           
	ElseIf Type("nMoedaNf")<> "U"
		nMoeda:= nMoedaNf    
	ElseIf Type("nMoedaCor")<> "U"
		nMoeda:= nMoedaCor    		      	
   	ElseIf lXFis
		nMoeda 		:= MAFISRET(,'NF_MOEDA')   
	EndIf		
	
	If Type("nTipoGer")<> "U" .And.	Type("nMoedSel")<> "U"	
		nMoeda:= If(nTipoGer==2,nMoedSel,SC5->C5_MOEDA)	    
	EndIf
	
	nDecs := MsDecimais(nMoeda)      
               
If SB1->(FieldPos("B1_CONISC"))>0 .And. SB1->(dbseek(xfilial("SB1")+Alltrim(cProd)))
	cConcProd := SB1->B1_CONISC
EndIf  

DbSelectArea("SFB")    
   	SFB->(DbSetOrder(1))
   	If SFB->(Dbseek(xFilial("SFB")+cImp))
	nAliq := SFB->FB_ALIQ
Endif 

DbSelectArea("SFB")    
   	SFB->(DbSetOrder(1))
   	If SFB->(Dbseek(xFilial("SFB")+cImpIncid))
	nAliqAg := SFB->FB_ALIQ
Endif
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica a base de calculo do imposto e se ha o cadastro de impostos incidentes nesta base de calculo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lXFis 	 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Base de calculo composta pelo valor da mercadoria + frete + seguro  ³
	//³Observacao Importante: em Angola nao ha a figura de frete e seguro, ³
	//³porem o sistema deve estar preparado para utilizar esses valores no ³
	//³calculo do imposto.                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nBase := aItem[3]+aItem[4]+aItem[5] 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Reduz os descontos concedidos da base de calculo³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Subs(aImp[5],4,1) == "S" .And. Len(aImp) >= 18 .And. ValType(aImp[18]) == "N"
		nBase -= aImp[18]
	Endif                                              

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Soma na base de calculo todos os demais impostos incidentes.        ³
	//³Observacao Importante: em Angola nao existem impostos que incidem um³
	//³sobre o outro, porem o sistema deve estar preparado para utilizar   ³
	//³esses valores no calculo do imposto.                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		DbSelectArea("SFF")
		SFF->(DbSetOrder(15))
		If SFF->(DbSeek(xFilial("SFF")+cImp+cConcProd)) .And. SFF->FF_ALIQ>0
			nAliq:=SFF->FF_ALIQ
		EndIf 
		If SFF->(DbSeek(xFilial("SFF")+cImpIncid+cConcProd)) .And. SFF->FF_ALIQ>0
			nAliqAg:=SFF->FF_ALIQ
		EndIf
		//Calculo por fora - Destacado
		aImp[03]:= nBase
		aImp[04]:= (nBase * nAliq/100)   
		xRet:=aImp

Else 
	Do Case
		Case cCalculo=="B"
	    	nBase:=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")	                 			
			//Tira os descontos se for pelo liquido
			nOrdSFC:=(SFC->(IndexOrd()))
			nRegSFC:=(SFC->(Recno()))
			SFC->(DbSetOrder(2))
			If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+aInfo[1])))
				cImpIncid:=Alltrim(SFC->FC_INCIMP)
				If SFC->FC_LIQUIDO=="S"
					nBase-=If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
				Endif
			Endif
						
   		     //+---------------------------------------------------------------+
			//¦ Soma a Base de Cálculo os Impostos Incidentes                 ¦
			//+---------------------------------------------------------------+
	   		nAliqAg:=0
	   		If !Empty(cImpIncid)
		   		DbSelectArea("SFB")
            	If DbSeek(xFilial() + cImpIncid )
  			    	nAliqAg := FB_ALIQ
     			Endif
		    EndIf
		    dbSelectArea("SFF")
			SFF->(DbSetOrder(15))
			If SFF->(DbSeek(xFilial("SFF")+cImpIncid+cConcProd)) .And. SFF->FF_ALIQ>0
				nAliqAg	:=SFF->FF_ALIQ
			EndIf
			If SFF->(DbSeek(xFilial("SFF")+cImp+cConcProd)) .And. SFF->FF_ALIQ>0
				nAliq	:=SFF->FF_ALIQ
			EndIf

			xRet:= nBase
	
		Case cCalculo=="A" 
			dbSelectArea("SFF")
			SFF->(DbSetOrder(15))
			If SFF->(DbSeek(xFilial("SFF")+cImp+cConcProd)) .And. SFF->FF_ALIQ>0
			   	xRet:=SFF->FF_ALIQ
			Else
				xRet:=nAliq 
			EndIf  			
		Case cCalculo=="V"
			nBase:=MaFisRet(nItem,"IT_BASEIV"+aInfo[2]) 
			nAliq:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[2])
			
			xRet:= (nBase * (nAliq/100))
	EndCase  
	SFC->(DbSetOrder(nOrdSFC))
	SFC->(DbGoto(nRegSFC))
	
EndIf
RestArea(aArea)

Return(xRet) 
