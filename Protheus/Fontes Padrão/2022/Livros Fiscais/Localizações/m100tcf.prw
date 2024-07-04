/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o	 � M100TCF	� Autor � MARCELLO GABRIEL     � Data � 13.10.2003 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � TASA DE CONTROL DE FAENAS     (URUGUAI)                     ���
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
FUNCTION M100TCF(cCalculo,nItem,aInfo)
Local lXFis,xRet

lXFis:=(MafisFound() .And. ProcName(1)<>"EXECBLOCK")
If lXfis
	xRet:=M100TCFN(cCalculo,nItem,aInfo)
Else
	xRet:=M100TCFA()
Endif
Return(xRet)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �M100TCFA  �Autor  �Marcello Gabriel    �Fecha �  13/10/2003 ���
�������������������������������������������������������������������������͹��
���Desc.     �Calculo TCF (Uruguai)                                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function M100TCFA()
Local aItem,aImp:={},cGrp
Local nBase:=0,nAliq:=0,nDecs:=0
Local cDbf:=alias(),nOrd:=IndexOrd(),aTaxa:={}

aItem:=ParamIxb[1]
aImp:=ParamIxb[2]
If cModulo=="FRT" //Frontloja usa o arquivo SBI para cadastro de produtos
	cGrp:=Alltrim(SBI->BI_GRPTCF)
Else
	cGrp:=Alltrim(SB1->B1_GRPTCF)
Endif

nMoedaAux:=IIf(Type("nMoedaNf")=="N",nMoedaNf,nMoedaCor)
nDecs:=MsDecimais(nMoedaAux)
nTaxa:=If(Type("nTaxa")=="N",nTaxa,0)
nBase:=aItem[1]
aTaxa:=TCFTaxa(aInfo[1],cGrp,SF4->F4_CF)
aImp[02]:=0
aImp[03]:=nBase
nAliq:=xMoeda(aTaxa[1],aTaxa[2],nMoedaAux,,nDecs+1,,nTaxa)
aImp[04]:=nAliq*nBase
dbSelectarea(cDbf)
dbSetOrder(nOrd)
Return(aImp)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �M100TCFN  �Autor  �Marcello Gabriel    �Fecha �  13/10/2003 ���
�������������������������������������������������������������������������͹��
���Desc.     �Calculo FIS (Uruguai)                                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function M100TCFN(cCalculo,nItem,aInfo)
Local xRet
Local nBase:=0,aTaxa:={},nAliq:=0,cCfo,cGrp
Local cDbf:=alias(),nOrd:=IndexOrd()
Local nTaxa:=0,nMoedaAux:=0,nDecs:=2

If cModulo=="FRT" //Frontloja usa o arquivo SBI para cadastro de produtos
	SBI->(DbSeek(xFilial("SBI")+MaFisRet(nItem,"IT_PRODUTO")))
	cGrp:=SBI->BI_GRPTCF
Else
	SB1->(DbSeek(xFilial("SB1")+MaFisRet(nItem,"IT_PRODUTO")))
	cGrp:=SB1->B1_GRPTCF
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
		aTaxa:=TCFTaxa(aInfo[1],cGrp,cCFO)
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
���Programa  �TCFTAXA   �Autor  �Marcello Gabriel    �Fecha �  13/19/2003 ���
�������������������������������������������������������������������������͹��
���Desc.     �Calculo da taxa para a TCF                                  ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function TCFTaxa(cImp,cGrp,cCfo)
Local aArea:=GetArea()
Local aValor:={0,0}  //valor, moeda
Local nRegSFF:=0,nOrdSFF:=0

DbSelectArea("SFF")
nOrdSFF:=IndexOrd()
nRegSFF:=Recno()
DbSetOrder(9)
If DbSeek(xFilial("SFF")+cImp+cGrp+cCfo)  //procura pela cfo solicitada
	aValor[1]:=SFF->FF_IMPORTE
	aValor[2]:=SFF->FF_MOEDA
Else
	If !Empty(cCfo)   //se nao encontrada procura pelo "importe" geral - cfo em branco
		cCfo:=Space(TamSX3("FF_CFO")[1])
		If DbSeek(xFilial("SFF")+cImp+cGrp+cCfo)
			aValor[1]:=SFF->FF_IMPORTE
			aValor[2]:=SFF->FF_MOEDA
		Endif
	Endif
Endif
DbSetOrder(nOrdSFF)
Dbgoto(nRegSFF)
RestArea(aArea)
Return(aValor)