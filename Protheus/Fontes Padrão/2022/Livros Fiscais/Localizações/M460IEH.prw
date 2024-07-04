/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  |M460IEH   � Autor �Alejandro Parrales     � Data �05.01.2022���
�������������������������������������������������������������������������Ĵ��
���Descripcion� Definicion de base, alicuota y calculo de IEHD            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � xRet                                                       ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/


Function M460IEH(cCalculo,nItem,aInfo)
	
	Local aImposto
	Local xRet
	Local lCalc		:= .F.
	Local aItemINFO := {}
	Local aArea 	:= GetArea()
	Local aAreaSFC 	:= GetArea("SFC")
	Local dDataMov	:= dDataBase
	Local cCfo		:= ""
	Local cModo		:= ""
	Local cUnid		:= ""
	Local nOrdSFF	:= 1
	Local nBase   	:= 0
	Local nAliq		:= 0
	Local nValIEH	:= 0
	Local nMerm		:= 0
	Local nQtd 		:= 0

	If SB1->(FieldPos("B1_PARTAR")) == 0
		Return 0
	EndIf	
	If MaFisFound()
		lXFis := .T.
		lCalc := .T.
	ElseIf ProcName(1)=="EXECBLOCK"
		lXFis := .F.
		lCalc := .T.
	EndIF
	If lCalc
		If lXFis
			nBase	:= MaFisRet(nItem,"IT_VALMERC")
			cCfo	:= MaFisRet(nItem,"IT_CF")
			nQtd 	:= MaFisRet(nItem,"IT_QUANT")
			If Type('dDEmissao') == "D" .AND. !Empty(dDEmissao)
				dDataMov	:=	dDEmissao
			Endif
			cTes 	:= MaFisRet(nItem,"IT_TES")
			cProd 	:= MaFisRet(nItem,"IT_PRODUTO")
			cInfo	:= aInfo[1]
		Else
			aItemINFO 		:= AClone( ParamIxb[1] )
			aImposto		:= AClone( ParamIxb[2] )
			aImposto[11]	:= aItemINFO[4]      // Rateio do Frete
			aImposto[4]		:= aItemINFO[5]      // Rateio de Despesas
			aImposto[3]		:= aItemINFO[3]+aItemINFO[4]+aItemINFO[5] // Base de Calculo
			xRet	 	 	:= aImposto
			nBase	 	 	:= aImposto[3]
			If Subs(aImposto[5],4,1) == "S"  .And. Len(aImposto) >= 18 .And. ValType(aImposto[18])=="N"
				nBase -= aImposto[18]
			EndIf
			nQtd 	 := aItemINFO[1]
			cInfo	 := aImposto[1]
			cProd 	 := aImposto[16]
			cTes 	 := SF4->F4_CODIGO
			cCfo 	 := SF4->F4_CF
		EndIf
		nOrdSFF	:= IIF(Substr(cCfo,1,1)>="5",16,15)
		//�����������������������Ŀ
		//� Calculo do imposto    �
		//�������������������������
		dbSelectArea("SFC")
		SFC->(DbSetOrder(2))
		dbSelectArea("SFF")
		SFF->(DbSetOrder(nOrdSFF))
		dbSelectArea("SB1")
		SB1->(DbSetOrder(1))
		If	(SFC->(DbSeek(xFilial("SFC")+cTes+cInfo))) .And.;
			(SB1->(DbSeek(xFilial("SB1")+cProd))) .And. !Empty(SB1->B1_PARTAR)
			If !(SFF->(DbSeek(xFilial("SFF")+SB1->B1_PARTAR+cCfo)))
				(SFF->(DbSeek(xFilial("SFF")+SB1->B1_PARTAR)))
				cCfo := "*"
			EndIf
			If (SFC->(MsSeek(xFilial("SFC")+cTes+cInfo)))
				If SFC->FC_BASE > 0
					nBase  := nBase  * (1 - SFC->FC_BASE / 100)
				Endif
			EndIf
			If SFF->(Found())
				lCalc := .F.
				While !SFF->(EOF()) .And. xFilial("SFF") == SFF->FF_FILIAL .And. SB1->B1_PARTAR == SFF->FF_PARTAR
					If	(dDataMov >= SFF->FF_DTDE .And. ( dDataMov <= SFF->FF_DTATE .Or. Empty(SFF->FF_DTATE) )) .And.;
						(cCfo $ "*/"+SFF->FF_CFO_C+"/"+SFF->FF_CFO_V) .And. cInfo == SFF->FF_IMPOSTO
						cModo := SFF->FF_MODO
						nAliq := SFF->FF_ALIQ
						nMerm := SFF->FF_MERMA
						cUnid := SFF->FF_UNIDAD
						lCalc := .T.
					EndIf
					SFF->(dbSkip())
				EndDo
				If lCalc
					If cModo == "V"
						If nMerm > 0
							nAliq := nAliq * (1-nMerm)
						EndIf
						If cUnid == "2" .And. !Empty(SB1->B1_SEGUM)
							//Obtem a relacao com a unidade de medida
							nQtd := ConvUm(SB1->B1_COD,nQtd,0,2)
						EndIf	
						nValIEH := nQtd * nAliq
					Else
						nValIEH := nBase * (nAliq / 100)
					EndIf
					//�����������������������Ŀ
					//� Definicao do retorno  �
					//�������������������������
					If lXFis
						If cCalculo == "B"
							xRet := nBase
						ElseIf cCalculo == "A"
							xRet := nAliq
						ElseIf cCalculo == "V"
							xRet := nValIEH
						EndIf
					Else
						aImposto[3]	:= nBase
						aImposto[2]	:= nAliq
						aImposto[4]	:= nValIEH
						xRet:=aImposto
					EndIf
				EndIf
			EndIf
		Else
			nValIEH := nBase * (nAliq / 100)
			If lXFis
				If cCalculo == "B"
					xRet := nBase
				ElseIf cCalculo == "A"
					xRet := nAliq
				ElseIf cCalculo == "V"
					xRet := nValIEH
				EndIf
			Else
				aImposto[3]	:= nBase
				aImposto[2]	:= nAliq
				aImposto[4]	:= nValIEH
				xRet:=aImposto
			EndIf
		EndIf
	EndIf
	RestArea(aArea)
	RestArea(aAreaSFC)
Return(xRet)
