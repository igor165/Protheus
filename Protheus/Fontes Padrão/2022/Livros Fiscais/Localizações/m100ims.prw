#DEFINE X_IMPOSTO    01 //Nome do imposto
#DEFINE X_NUMIMP     02 //Sufixo do imposto
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ M100IMS	³ Autor ³ Percy A Horna        ³ Data ³ 29.12.1999 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ CALCULO IMPOSTO IMESI - ENTRADA                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ URUGUAY                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION M100IMS(cCalculo,nItem,aInfo)

Local aItem, lXFis, cImp, xRet, nOrdSFC, nRegSFC
Local nBase := 0, nAliq := 0, lAliq := .F., lIsento := .F., cFil, cAux
Local cDbf := Alias(), nOrd := IndexOrd()
Local cGrp
Local nVlFicto	:=	0
Private clTipo	:= ""
If cPaisLoc=="URU"     
	xRet:= 0
	If cModulo$'FAT|TMK|LOJA|FRT'
		clTipo	 	:= Alltrim(SA1->A1_TIPO)	
    Else
		clTipo		:= Alltrim(SA2->A2_TIPO)	
	Endif	
	If clTipo=="2" .And. Alltrim(aInfo[X_IMPOSTO])$"IMS"
		xRet:=CalcRetFis(cCalculo,nItem,aInfo)	
	Endif	
Else
	If SB1->(FieldPos("B1_GRTRIB")) <= 0
		Help("",1,"FIELDPOS")
		Return
	EndIf
	
	
	dbSelectArea("SFF")     // verificando as excecoes fiscais
	dbSetOrder(3)
	cFil  := xfilial()
	lXFis := (MafisFound() .And. ProcName(1)<>"EXECBLOCK")
	
	If !lXfis
		aItem := ParamIxb[1]
		xRet  := ParamIxb[2]
		cImp  := xRet[1]
	Else
		cImp := aInfo[1]
		If cModulo == "FRT" //Frontloja usa o arquivo SBI para cadastro de produtos
			SBI->(DbSeek(xFilial("SBI")+MaFisRet(nItem,"IT_PRODUTO")))
		Else
			SB1->(DbSeek(xFilial("SB1")+MaFisRet(nItem,"IT_PRODUTO")))
		Endif
		xRet := 0
	EndIf
	
	If cModulo == "FRT" //Frontloja usa o arquivo SBI para cadastro de produtos
		cGrp := Alltrim(SBI->BI_GRTRIB)
	Else
		cGrp := Alltrim(SB1->B1_GRTRIB)
	Endif
	
	If dbSeek(cFil+cImp)
		While FF_IMPOSTO == cImp .And. FF_FILIAL == cFil .And. !lAliq
			cAux := Alltrim(FF_GRUPO)
			If cAux != ""
				lAliq := (cAux==cGrp)
			EndIf
			If lAliq
				If !( lIsento := (FF_TIPO=="S") )
					nAliq := FF_ALIQ
					EXIT
				EndIf
			EndIf
			dbSkip()
		Enddo
	EndIf
	//Verifica se existe o campo com valor ficto.
	If SB1->(FieldPos("B1_VLFICTO")) >0
		nVlFicto	:=	SB1->B1_VLFICTO
	Endif
	
	If !lIsento
		
		If !lXFis
			If nVlFicto > 0
				nBase := aItem[1] * nVlFicto
			Else
				nBase := aItem[3] + aItem[4] + aItem[5]  //valor total + frete + outros impostos
				//Tira os descontos se for pelo liquido .Bruno
				If Subs(xRet[5],4,1) == "S" .And. Len(xRet) >= 18 .And. ValType(xRet[18])=="N"
					nBase -= xRet[18]
				Endif
			EndIf
		Else
			If cCalculo == "B"
				If nVlFicto > 0
					nBase := MaFisRet(nItem,"IT_QUANT") * nVlFicto
				Else
					nBase := MaFisRet(nItem,"IT_VALMERC") + MaFisRet(nItem,"IT_FRETE") + MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
					//Tira os descontos se for pelo liquido
					nOrdSFC := (SFC->(IndexOrd()))
					nRegSFC := (SFC->(Recno()))
					SFC->(DbSetOrder(2))
					If (SFC->(DbSeek(xFilial("SFC") + MaFisRet(nItem,"IT_TES") + cImp)))
						If SFC->FC_LIQUIDO == "S"
							nBase -= If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
						EndIf
					EndIf
					SFC->(DbSetOrder(nOrdSFC))
					SFC->(DbGoto(nRegSFC))
				EndIf
			EndIf
		EndIf
	EndIf
	If !lXFis
		xRet[02] := nAliq
		xRet[03] := nBase
		xRet[04] := (nAliq * nBase)/100
	Else
		Do Case
			Case cCalculo == "B"
				xRet := nBase
			Case cCalculo == "A"
				xRet := nALiq
			Case cCalculo == "V"
				nBase := MaFisRet(nItem,"IT_BASEIV"+aInfo[2])
				nAliq := MaFisRet(nItem,"IT_ALIQIV"+aInfo[2])
				xRet  := (nAliq * nBase)/100
		EndCase
	EndIf
Endif
DbSelectarea(cDbf)
DbSetOrder(nOrd)
Return(xRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CALCRETFISºAutor  ³Denis Martins       º Data ³ 11/12/1999  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calculo da Retencao do Imposto X Tes - Entrada              º±±
±±º          ³Alterado para o uso da funcao MATXFIS (Marcello)            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA460,MATA100                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CalcRetFis(cCalculo,nItem,aInfo)
Local nDesconto,nBase,nAliq,nOrdSFC,nRegSFC,nVal,nTotBase,nVRet
Local nFaxDe,lRet, cGrpIMS
Local cMvAgente	 := Alltrim(SuperGetMv("MV_AGENTE",.F.,"NNNNNNNNNN"))

nBase:=0
nAliq:=0
nDesconto:=0
nVRet:=0
cGrpIMS:=""
lRet:=.F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³           Busca o CFO do Tes Correspondente - SF4                   ³
//³                                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCFO := MaFisRet(nItem,"IT_CF")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifico no SFB existe SFB->ALIQ e nao apresenta tabela SFB->TABELA³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SFB")
dbSetOrder(1)
If DbSeek(xFilial("SFB")+aInfo[X_IMPOSTO])
	lRet:=.T.	
	nAliq:=SFB->FB_ALIQ
	If cCalculo$"AB"
		//Tira os descontos se for pelo liquido
		nOrdSFC:=(SFC->(IndexOrd()))
		nRegSFC:=(SFC->(Recno()))
		SFC->(DbSetOrder(2))
		If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+aInfo[X_IMPOSTO])))
			If SFC->FC_LIQUIDO=="S"
				nDesconto:=If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
			Endif
		Endif
		SFC->(DbSetOrder(nOrdSFC))
		SFC->(DbGoto(nRegSFC))
		nVal:=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
		nVal-=nDesconto
		
		If SubStr(cMvAgente,8,1) == "N" .And. Alltrim(aInfo[X_IMPOSTO])=="IMS"
			nAliq:=0
		Else
			//Verifica na SFF se existe Imposto e Grupo correspondente para realizacao do calculo
			DbSelectArea("SB1")
			SB1->(DbSetOrder(1))
			SB1->(DbGoTop())
			If FieldPos("B1_GRPIMS")>0
				If DbSeek(xFilial("SB1") + AvKey(MaFisRet(nItem,"IT_PRODUTO"),"B1_COD") )
					cGrpIMS:=SB1->B1_GRPIMS
					DbSelectArea("SFF")
					SFF->(DbSetOrder(9))
					SFF->(DbGoTop())
					If DbSeek(xFilial("SFF") + AvKey(aInfo[X_IMPOSTO],"FF_IMPOSTO") + AvKey(cGrpIMS,"FF_GRUPO"))
						nAliq:=SFF->FF_ALIQ
					Endif
				Endif    
			Else
				//Verifica na SFF se existe Imposto e CFO correspondente para realizacao do calculo
				DbSelectArea("SFF")
				SFF->(DbSetOrder(5))
				SFF->(DbGoTop())
				If dbSeek(xFilial("SFF") + aInfo[X_IMPOSTO] + cCFO )
					If FF_FLAG != "1"
						RecLock("SFF",.F.)
						Replace FF_FLAG With "1"
						SFF->(MsUnlock())
					Endif
					nFaxde  := SFF->FF_FXDE
					nTotBase := nVal //* nBase
					If nTotBase >= nFaxde
						nAliq:=SFF->FF_ALIQ
						DbGoBottom()
					Endif
				Endif
			Endif
		Endif	
	Endif
Endif
If lRet
	Do Case
		Case cCalculo=="B"
			nVRet:=nVal//*nBase
		Case cCalculo=="A"
			nVRet:=nAliq
		Case cCalculo=="V"
			nBase:=MaFisRet(nItem,"IT_BASEIV"+aInfo[X_NUMIMP])
			nAliq:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[X_NUMIMP])
			nVRet:=nBase * (nAliq/100)
	EndCase
Endif
Return(nVRet)
