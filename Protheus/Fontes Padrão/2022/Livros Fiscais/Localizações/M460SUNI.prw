/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³¦¦Funçào    ³M460SUNI  ³ Autor ³ JULIO CESAR            ³ Data ³ 21/10/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³¦¦Descriçào ³ Programa que Calcula o Suntuario Incluido (Mexico)          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		   ³ Generico                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR    ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                ³        ³      ³                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

*/
Function M460SUNI(cCalculo,nItem,aInfo)

Local aImp,aItem,cImp,xRet,nOrdSFC,nRegSFC,nImp,cTes
Local nBase:=0, nAliq:=0, lAliq:=.F., lIsento:=.F., cFil, cAux, cGrp
Local nDecs
Local nAliqAux:=0
Local lImpDep:=.F.,lCalcLiq:=.F.
LOCAL lXFis
LOCAL aArea := GetArea()

dbSelectArea("SFF")     // verificando as excecoes fiscais
dbSetOrder(3)
cFil:=xfilial()
lXFis:=(MafisFound() .And. ProcName(1)<>"EXECBLOCK")

If !lXfis
	aItem:=ParamIxb[1]
	aImp:=ParamIxb[2]
	cImp:=aImp[1]
	cTes:=SF4->F4_CODIGO
Else
	cImp:=aInfo[1]
    If cModulo=="FRT" //Frontloja usa o arquivo SBI para cadastro de produtos
       SBI->(DbSeek(xFilial("SBI")+MaFisRet(nItem,"IT_PRODUTO")))
    Else   
        SB1->(DbSeek(xFilial("SB1")+MaFisRet(nItem,"IT_PRODUTO")))
    Endif    
	cTes:=MaFisRet(nItem,"IT_TES")
Endif            

If cModulo=="FRT" //Frontloja usa o arquivo SBI para cadastro de produtos
   cGrp:=Alltrim(SBI->BI_GRUPO)
Else
    cGrp:=Alltrim(SB1->B1_GRUPO)
Endif

If dbseek(cFil+cImp)
	While FF_IMPOSTO == cImp .and. FF_FILIAL == cFil .and. !lAliq
		cAux:=Alltrim(FF_GRUPO)
		If cAux!=""
			lAliq:=(cAux==cGrp)
		Endif
		cAux:=Alltrim(FF_ATIVIDA)
		If cAux!=""
			lAliq:=(cAux==Alltrim(SA1->A1_ATIVIDA))
		Endif
		If lAliq
			If !(lIsento:=(FF_TIPO=="S"))
				nAliq:=FF_ALIQ
			Endif
		Endif
		dbskip()
	Enddo
Endif

If !lIsento
	If !lAliq
		DbSelectArea("SFB")    // busca a aliquota padrao
		If Dbseek(xfilial()+cImp)
			nAliq:=SFB->FB_ALIQ
		Endif
	Endif
	If !lXFis
		nBase:=aItem[3]+aItem[4]+aItem[5]  //valor total + frete + outros impostos
	Else
		nBase:=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
		If cPaisLoc == "MEX" .AND. SD2->(FieldPos("D2_VALADI")) > 0
			nBase-=MaFisRet(nItem,"IT_ADIANT")
		EndIf		
		If GetNewPar('MV_DESCSAI','1')=='1' 
			nBase	+= MaFisRet(nItem,"IT_DESCONTO")
		Endif
	Endif
Endif

nDecs := IIf(Type("nMoedaNf") # "U",MsDecimais(nMoedaNf),MsDecimais(1))

//Verifica se eh um imposto "dependente" de outro, pois caso seja eh necessario
//acertar o valor da base para que os impostos da amarracao possuam a mesma
//base de calculo.
If cImp $ GetMV("MV_IMPSDEP",,"")
	nOrdSFC:=(SFC->(IndexOrd()))
	nRegSFC:=(SFC->(Recno()))
	SFC->(DbSetOrder(2))
	If (SFC->(DbSeek(xFilial("SFC")+cTes)))
		While !Eof() .And. (xFilial("SFC")+cTes == SFC->FC_FILIAL+SFC->FC_TES)
			If (SFC->FC_IMPOSTO <> cImp) .And. (SFC->FC_IMPOSTO $ GetMV("MV_IMPSDEP",,"")) .And.;
			   (SFC->FC_INCNOTA == "3")
				lImpDep := .T.
				dbSelectArea("SFB")    // busca a aliquota padrao
   				dbSetOrder(1)
				If dbSeek(xFilial("SFB")+SFC->FC_IMPOSTO)
					nAliqAux += SFB->FB_ALIQ
				Endif	   
			ElseIf (SFC->FC_IMPOSTO == cImp)
				lCalcLiq := .T.
				//Tira os descontos se for pelo liquido
				If !lXFis .And. Subs(aImp[5],4,1) == "S" .And. Len(aImp) >= 18 .And. ValType(aImp[18])=="N"
					nBase -= aImp[18]
				ElseIf lXFis .And. SFC->FC_LIQUIDO=="S"
					nBase -= If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
				EndIf
			EndIf
			SFC->(dbSkip())
		End
	EndIf                     
	SFC->(DbSetOrder(nOrdSFC))
	SFC->(DbGoto(nRegSFC))
            
	If lImpDep
		nAliqAux += nAliq
    	nBase    := Round(nBase /(1+(nAliqAux/100)),nDecs)		
  	EndIf
EndIf

If !lXFis
	aImp[02]:=nAliq
	aImp[03]:=nBase

	//Caso seja um imposto "dependente" o tratamento de desconto ja foi realizado.	
	If !lCalcLiq
		//Tira os descontos se for pelo liquido .Bruno
		If Subs(aImp[5],4,1) == "S" .And. Len(aImp) >= 18 .And. ValType(aImp[18])=="N"
			aImp[3]	-= aImp[18]
			nBase	:= aImp[3]
		Endif
	EndIf
	
	//+---------------------------------------------------------------+
	//¦ Efetua o Calculo do Imposto                                   ¦
	//+---------------------------------------------------------------+
	If !lImpDep
		aImp[4]:= aImp[3] - Round(aImp[3] /(1+(aImp[2]/100)),nDecs)
		aImp[3]:= aImp[3] - aImp[4]
	Else 
		//Caso seja um imposto "dependente" a forma de calculo eh diferente, nao sendo
		//feita pela diferenca...
		aImp[4]:=Round(aImp[3] * (aImp[02]/100),nDecs)	
	EndIf
	xRet:=aImp
Else           
	//Caso seja um imposto "dependente" o tratamento de desconto ja foi realizado.
	If !lCalcLiq
		nOrdSFC:=(SFC->(IndexOrd()))
		nRegSFC:=(SFC->(Recno()))

		//Tira os descontos se for pelo liquido
		SFC->(DbSetOrder(2))
		If (SFC->(DbSeek(xFilial("SFC")+cTes+cImp)))
			If SFC->FC_LIQUIDO=="S"
				nBase-=If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
			Endif
		Endif
		SFC->(DbSetOrder(nOrdSFC))
		SFC->(DbGoto(nRegSFC))
	EndIf

	//Caso seja um imposto "dependente" a forma de calculo eh diferente, nao sendo
	//feita pela diferenca...
	If !lImpDep
		nImp:=nBase-Round(nBase /(1+(nAliq/100)),nDecs)
		nBase-=nImp
	Else
		nImp:=Round(nBase * (nAliq/100),nDecs)	
	EndIf
	
	Do Case
		Case cCalculo=="B"
			xRet:=nBase
		Case cCalculo=="A"
			xRet:=nALiq
		Case cCalculo=="V"
			xRet:=nImp
	EndCase
Endif

RestArea( aArea )

Return( xRet )
