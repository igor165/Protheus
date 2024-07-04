/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o	 � M100FIS	� Autor � MARCELLO GABRIEL     � Data � 24.09.2003 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � FONDO DE INSPECCION SANITARIA (URUGUAI)                     ���
��������������������������������������������������������������������������Ĵ��
���Uso		 � Generico 												   ���
��������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                      ���
��������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                    ���
��������������������������������������������������������������������������Ĵ��
���              �        �      �                                         ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
FUNCTION M100FIS(cCalculo,nItem,aInfo)
Local lXFis,xRet

lXFis:=(MafisFound() .And. ProcName(1)<>"EXECBLOCK")
If lXfis
	xRet:=M100FISN(cCalculo,nItem,aInfo)
Else
	xRet:=M100FISA()
Endif
Return(xRet)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �M100FISA  �Autor  �Marcello Gabriel    �Fecha �  24/09/2003 ���
�������������������������������������������������������������������������͹��
���Desc.     �Calculo FIS (Uruguai)                                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function M100FISA()
Local aItem,aImp:={},nOrdSFC,nRegSFC,cGrp
Local nBase:=0,nAliq:=0,cTes,cImpIncid,nAliqI:=0
Local cDbf:=alias(),nOrd:=IndexOrd()

aItem:=ParamIxb[1]
aImp:=ParamIxb[2]
cImpIncid:=aImp[10]
If cModulo=="FRT" //Frontloja usa o arquivo SBI para cadastro de produtos
	cGrp:=Alltrim(SBI->BI_GRPFIS)
Else
	cGrp:=Alltrim(SB1->B1_GRPFIS)
Endif

dbselectarea("SFB")    // busca a aliquota padrao
if dbseek(xfilial()+aImp[1])
	nAliq:=SFB->FB_ALIQ
endif
If (cEspecie$"NCC|NDC" .and. SA1->A1_TIPO=="1") .Or. SA2->A2_TIPO=="1" //cliente tipo 1 (distribuidor) - calcular usando o "ficto"
	nBase:=aItem[1]
	If cEspecie$"NCC|NDC"
		nBase:=nBase*FISFicto(aImp[1],cGrp,SA1->A1_COD,SA1->A1_LOJA)
	Else
		nBase:=nBase*FISFicto(aImp[1],cGrp)
	Endif
Else
	nBase:=aItem[3]+aItem[4]  //valor total + frete 
	//Tira os descontos se for pelo liquido .Bruno
	If Subs(aImp[5],4,1) == "S" .And. Len(aImp) >= 18 .And. ValType(aImp[18])=="N"
		nBase-=aImp[18]
	Endif
	//+---------------------------------------------------------------+
	//� Soma a Base de C�lculo os Impostos Incidentes                 �
	//+---------------------------------------------------------Lucas-+
	nI:=At(";",cImpIncid)
	nI:=If(nI==0,Len(AllTrim(cImpIncid))+1,nI)
	While nI>1
		nE:=AScan(aItem[6],{|x| x[1]==Left(cImpIncid,nI-1)})
		If nE>0
			nBase-=aItem[6,nE,4]
		End
		cImpIncid:=Stuff(cImpIncid,1,nI,"")
		nI:=At(";",cImpIncid)
		nI:=If(nI==0,Len(AllTrim(cImpIncid))+1,nI)
	Enddo
	nBase:=nBase/(1+(nAliq/100))
Endif
aImp[02]:=nAliq
aImp[03]:=nBase
aImp[04]:=(nAliq * nBase)/100
dbSelectarea(cDbf)
dbSetOrder(nOrd)
Return(aImp)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �M100FISN  �Autor  �Marcello Gabriel    �Fecha �  24/09/2003 ���
�������������������������������������������������������������������������͹��
���Desc.     �Calculo FIS (Uruguai)                                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function M100FISN(cCalculo,nItem,aInfo)
Local xRet,nOrdSFC,nRegSFC
Local nBase:=0,nAliq:=0,cFil,cTes,cGrp,cImpIncid,cAgrBase,nAliqI:=0,nI:=0
Local cDbf:=alias(),nOrd:=IndexOrd()

If cModulo=="FRT" //Frontloja usa o arquivo SBI para cadastro de produtos
	SBI->(DbSeek(xFilial("SBI")+MaFisRet(nItem,"IT_PRODUTO")))
	cGrp:=SBI->BI_GRPFIS
Else
	SB1->(DbSeek(xFilial("SB1")+MaFisRet(nItem,"IT_PRODUTO")))
	cGrp:=SB1->B1_GRPFIS
Endif
Do Case
	Case cCalculo=="B"
		If MaFisRet(,"NF_TPCLIFOR")=="1" //cliente tipo 1 (distribuidor) - calcular usando o "ficto"
			nBase:=MaFisRet(nItem,"IT_QUANT")
			If cEspecie$"NCC|NDC"
				nAliq:=FISFicto(aInfo[1],cGrp,MaFisRet(,"NF_CODCLIFOR"),MaFisRet(,"NF_LOJA"))
			Else
				nAliq:=FISFicto(aInfo[1],cGrp)
			Endif
			xRet:=nBase*nAliq
		Else
			nBase:=MaFisRet(nItem,"IT_VALMERC")
			nOrdSFC:=(SFC->(IndexOrd()))
			nRegSFC:=(SFC->(Recno()))
			SFC->(DbSetOrder(2))
			cImpIncid:=""
			cAgrBase:=""
			If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+aInfo[1])))
				cImpIncid:=Alltrim(SFC->FC_INCIMP)
				cAgrBase:=Alltrim(SFC->FC_AGRBASE)
				If SFC->FC_LIQUIDO=="S"
					nBase-=If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
				Endif
			Endif
			SFC->(DbSetOrder(nOrdSFC))
			SFC->(DbGoto(nRegSFC))
			//+---------------------------------------------------------------+
			//� Soma a Base de C�lculo os Impostos Incidentes                 �
			//+---------------------------------------------------------------+
			If !Empty(cImpIncid)
				aImpRef:=MaFisRet(nItem,"IT_DESCIV")
				aImpVal:=MaFisRet(nItem,"IT_VALIMP")
				For nI:=1 to Len(aImpRef)
					If !Empty(aImpRef[nI])
						If Trim(aImpRef[nI][1])$cImpIncid
							nBase-=aImpVal[nI]
						Endif
					Endif
				Next
			Endif
			If !Empty(cAgrBase)
				cFil:=xFilial("SFC")
				nAliqI:=0
				cTes:=MaFisRet(nItem,"IT_TES")
				If (SFC->(DbSeek(xFilial("SFC")+cTes)))
					While SFC->FC_FILIAL==cFil .and. SFC->FC_TES=cTES
						If SFC->FC_IMPOSTO<>aInfo[1] .and. SFC->FC_AGRBASE==cAgrBase
							If SFB->(DbSeek(xFilial("SFB")+SFC->FC_IMPOSTO))
								nAliqI+=SFB->FB_ALIQ
							Endif
						Endif
						SFC->(DbSkip())
					Enddo
				Endif
				nBase:=nBase/(1+(nAliqI/100))
			Endif
			If SFB->(DbSeek(xFilial("SFB")+aInfo[1]))
				nAliq:=SFB->FB_ALIQ
			Endif
			nAliq:=1+(nAliq/100)
			xRet:=nBase/nAliq
		Endif
	Case cCalculo=="A"
		dbselectarea("SFB")    // busca a aliquota padrao
		If dbseek(xfilial()+aInfo[1])
			nAliq:=SFB->FB_ALIQ
		Endif
		xRet:=nALiq
	Case cCalculo=="V"
		nBase:=MaFisRet(nItem,"IT_BASEIV"+aInfo[2])
		nAliq:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[2])
		xRet:=(nAliq * nBase)/100
EndCase
dbSelectarea(cDbf)
dbSetOrder(nOrd)
Return(xRet)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FISFicto  �Autor  �Marcello Gabriel    �Fecha �  24/09/2003 ���
�������������������������������������������������������������������������͹��
���Desc.     �Calculo do "Ficto" para o FIS                               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FISFicto(cImp,cGrp,cClie,cLoj)
Local aArea:=GetArea()
Local nValor:=0,lOk
Local nRegSFF:=0,nOrdSFF:=0,cAtiv:="",cFilSFF

DbSelectArea("SFF")
cFilSFF:=xFilial("SFF")
nOrdSFF:=IndexOrd()
nRegSFF:=Recno()
DbSetOrder(9)
If cEspecie$"NCC|NDC"
	If (SA1->(DbSeek(xFilial("SA1")+cClie+cLoj)))
		cAtiv:=Alltrim(SA1->A1_ATIVIDA)
	Endif
Else
	cAtiv:=Alltrim(SM0->M0_COD_ATV)
Endif
lOk:=.F.
If DbSeek(xFilial("SFF")+cImp+cGrp)
	While FF_FILIAL==cFilSFF .And. FF_IMPOSTO==cImp .And. FF_GRUPO==cGrp .And. !lOk
		If !Empty(cAtiv)
			If Alltrim(FF_ATIVIDA)==cAtiv
				nValor:=SFF->FF_IMPORTE
				lOk:=.T.
			Endif
		Endif
		If !lOk
			If Empty(FF_ATIVIDAD)
				nValor:=SFF->FF_IMPORTE
			Endif
		Endif
		DbSkip()
	Enddo
Endif
DbSetOrder(nOrdSFF)
Dbgoto(nRegSFF)
RestArea(aArea)
Return(nValor)