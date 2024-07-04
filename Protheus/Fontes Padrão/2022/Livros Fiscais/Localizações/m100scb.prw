/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o	 � M100SCB	� Autor � MARCELLO GABRIEL     � Data � 16.04.2004 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Seguro para el control de la Brucelosis   (URUGUAI)         ���
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
FUNCTION M100SCB(cCalculo,nItem,aInfo)
Local lXFis,xRet

lXFis:=(MafisFound() .And. ProcName(1)<>"EXECBLOCK")
If lXfis
	xRet:=M100SCBN(cCalculo,nItem,aInfo)
Else
	xRet:=M100SCBA()
Endif
Return(xRet)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �M100SCBA  �Autor  �Marcello Gabriel    �Fecha �  16.04.2004 ���
�������������������������������������������������������������������������͹��
���Desc.     �Calculo SCB (Uruguai)                                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function M100SCBA()
Local aItem,aImp:={},cGrp
Local nBase:=0,nAliq:=0,nDecs:=0
Local cDbf:=alias(),nOrd:=IndexOrd(),aTaxa:={}

aItem:=ParamIxb[1]
aImp:=ParamIxb[2]
If cModulo=="FRT" //Frontloja usa o arquivo SBI para cadastro de produtos
	cGrp:=Alltrim(SBI->BI_GRPSCB)
Else
	cGrp:=Alltrim(SB1->B1_GRPSCB)
Endif

nTaxa:=If(Type("nTaxa")=="N",nTaxa,0)
nBase:=aItem[1]
aTaxa:=SCBTaxa(aImp[1],cGrp)
aImp[02]:=0
aImp[03]:=nBase
If FunName()=="MATA121" .And. Type("nMoedaPed")=="N"
	nMoedaAux:=nMoedaPed
ElseIf FunName()=="MATA150" .And. Type("nMoedaCot")=="N"
	nMoedaAux:=nMoedaCot
Else
	nMoedaAux:=	If(Type("nMoedaNF")	=="N",nMoedaNf,If(Type("nMoedaCor")=="N",nMoedaCor,1))
Endif
nDecs:=MsDecimais(nMoedaAux)
nAliq:=xMoeda(aTaxa[1],aTaxa[2],nMoedaAux,,nDecs+1,,nTaxa)
aImp[04]:=nAliq*nBase
dbSelectarea(cDbf)
dbSetOrder(nOrd)
Return(aImp)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �M100SCBN  �Autor  �Marcello Gabriel    �Fecha �  16.04.2004 ���
�������������������������������������������������������������������������͹��
���Desc.     �Calculo SCB (Uruguai)                                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function M100SCBN(cCalculo,nItem,aInfo)
Local xRet
Local nBase:=0,aTaxa:={},nAliq:=0,cCfo,cGrp
Local cDbf:=alias(),nOrd:=IndexOrd()
Local nTaxa:=0,nMoedaAux:=0,nDecs:=2

If cModulo=="FRT" //Frontloja usa o arquivo SBI para cadastro de produtos
	SBI->(DbSeek(xFilial("SBI")+MaFisRet(nItem,"IT_PRODUTO")))
	cGrp:=SBI->BI_GRPSCB
Else
	SB1->(DbSeek(xFilial("SB1")+MaFisRet(nItem,"IT_PRODUTO")))
	cGrp:=SB1->B1_GRPSCB
Endif
Do Case
	Case cCalculo=="B"
		xRet:=MaFisRet(nItem,"IT_QUANT")
	Case cCalculo=="A"
		xRet:=0
	Case cCalculo=="V"
		nTaxa:=If(Type("nTaxa")=="N",nTaxa,0)
		If FunName()=="MATA121" .And. Type("nMoedaPed")=="N"
			nMoedaAux:=nMoedaPed
		ElseIf FunName()=="MATA150" .And. Type("nMoedaCot")=="N"
			nMoedaAux:=nMoedaCot
		Else
			nMoedaAux:=	If(Type("nMoedaNF")	=="N",nMoedaNf,If(Type("nMoedaCor")=="N",nMoedaCor,1))
		Endif
		nDecs:= MsDecimais(nMoedaAux)
		nBase:=MaFisRet(nItem,"IT_BASEIV"+aInfo[2])
		cCfo:=MaFisRet(nItem,"IT_CF")
		aTaxa:=SCBTaxa(aInfo[1],cGrp)
		nAliq:=xMoeda(aTaxa[1],aTaxa[2],nMoedaAux,,nDecs+1,,nTaxa)
		xRet:=(nAliq * nBase)
EndCase
dbSelectarea(cDbf)
dbSetOrder(nOrd)
Return(xRet)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SCBTAXA   �Autor  �Marcello Gabriel    �Fecha �  16.04.2004 ���
�������������������������������������������������������������������������͹��
���Desc.     �Calculo da taxa para a SCB                                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function SCBTaxa(cImp,cGrp)
Local aArea:=GetArea()
Local aValor:={0,0}  //valor, moeda
Local nRegSFF:=0,nOrdSFF:=0,cCfo:=""


DbSelectArea("SFF")
nOrdSFF:=IndexOrd()
nRegSFF:=Recno()
DbSetOrder(9)
cCfo:=Space(TamSX3("FF_CFO")[1])
If DbSeek(xFilial("SFF")+cImp+cGrp+cCfo)
	aValor[1]:=SFF->FF_IMPORTE
	aValor[2]:=SFF->FF_MOEDA
Endif
DbSetOrder(nOrdSFF)
Dbgoto(nRegSFF)
RestArea(aArea)
Return(aValor)