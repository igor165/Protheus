/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  |M460ICC   � Autor �Renato Nagib           � Data �15.06.2010���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Definicao da base, aliquota e calculo do ICE para Saidas   ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �.T.                                                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros|cCalculo -> Solicitacao da MATXFIS, podendo ser A (aliquota)���
���          � B (base) ou V (valor)                                      ���
���          �nItem -> Item do documento fiscal                           ���
���          �aInfo -> Array com a seguinte estrutura: {cCodImp,nCpoLVF}  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function M460ICC(cCalculo,nItem,aInfo)

	Local xRet
	
	If cPaisLoc =='EQU'
		xRet:= M460ICCEQU(cCalculo,nItem,aInfo)
	EndIf

Return (xRet)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �M460ICCEQU�Autor  �Renato Nagib        � Data �  15/06/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �  Calcula o imposto ICC para Equador                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                  Equador                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function M460ICCEQU(cCalculo,nItem,aInfo)

	Local lXFis    
	Local lCalc	
	Local nBase	
	Local nAliq	
	Local nValImp
	Local nValMerc
	Local xRet	
	Local aImposto	
	Local aItemSD2
	Local aArea 	:= GetArea()
	Local aAreaSFB	:= SFB->(GetArea())

	If MaFisFound()
		lXFis := .T.
		lCalc := .T.
	ElseIf ProcName(2)=="EXECBLOCK"
		lXFis := .F.
		lCalc := .T.
	Else
		xRet  := 0
		lCalc := .F.
	EndIF
	
	If lCalc
		
		//Calculo para rotina manual
		If lXFis
			
			//Aliquota
			cProd 	:= MaFisRet(nItem,"IT_PRODUTO")
			dbSelectArea('SB1')
			dbSetOrder(1)
			If dbSeek(xFilial('SB1')+cProd)
				If SB1->B1_ALIQICE > 0
					nAliq:=SB1->B1_ALIQICE
				Else	
					dbSelectArea('SFB')
					dbSetOrder(1)
					If dbSeek(xFilial('SFB')+aInfo[1])
						nAliq:=SFB->FB_ALIQ
					EndIf
				EndIf
			EndIf
			
			//Calculo da Base
			nValMerc:= MaFisRet(nItem,"IT_VALMERC") 
			nBase:=nValMerc /(1+(nAliq/100))
			
			//Calculo do Imposto
           	nValImp:=((nBase * nAliq)/100)
			
			//Retorno
			If cCalculo =='B'
				xRet:=nBase
			ElseIf cCalculo =='A'
				xRet:=nAliq
			ElseIf cCalculo =='V'
				xRet:=nValimp
			EndIf
		
			//Calculo para rotina automatica
		Else
			aItemSD2 		:= AClone( ParamIxb[1] )
			aImposto		:= AClone( ParamIxb[2] )
			
			//Aliquota
			cProd:=aImposto[16]
			dbSelectArea('SB1')
			dbSetOrder(1)
			If dbSeek(xFilial('SB1')+cProd)
				If SB1->B1_ALIQICE > 0
					nAliq:=SB1->B1_ALIQICE
				Else	
					dbSelectArea('SFB')
					dbSetOrder(1)
					If dbSeek(xFilial('SFB')+aInfo[1])
						nAliq:=SFB->FB_ALIQ
					EndIf
				EndIf
			EndIf
			
			aImposto[2]		:=nAliq
			aImposto[3]		:=aItemSD2[3] / (1 + (nAliq/100))// Base de Calculo
			aImposto[4]		:=((aImposto[3] * nAliq)/100) //Valor do imposto
			xRet	 	 	:= aImposto
		EndIf
	EndIf		
	
	RestArea(aArea)
	RestArea(aAreaSFB)		

Return (xRet)