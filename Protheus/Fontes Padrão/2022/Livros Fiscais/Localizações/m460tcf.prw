
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o	 � M460TCF	� Autor � MARCELLO GABRIEL     � Data � 17.10.2003 ���
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
FUNCTION M460TCF(cCalculo,nItem,aInfo)
Local lXFis,xRet

lXFis:=(MafisFound() .And. ProcName(1)<>"EXECBLOCK")
If lXfis
	xRet:=M460TCFN(cCalculo,nItem,aInfo)
Else
	xRet:=M460TCFA()
Endif
Return(xRet)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �M460TCFA  �Autor  �Marcello Gabriel    �Fecha �  13/10/2003 ���
�������������������������������������������������������������������������͹��
���Desc.     �Calculo TCF (Uruguai)                                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function M460TCFA()
Local aItem,aImp:={},nOrdSFC,nRegSFC,cGrp
Local nBase:=0,nAliq:=0,cTes,cImpIncid,nAliqI:=0
Local cDbf:=alias(),nOrd:=IndexOrd()

aItem:=ParamIxb[1]
aImp:=ParamIxb[2]
cImpIncid:=aImp[10]
If cModulo=="FRT" //Frontloja usa o arquivo SBI para cadastro de produtos
	cGrp:=Alltrim(SBI->BI_GRPTCF)
Else
	cGrp:=Alltrim(SB1->B1_GRPTCF)
Endif

dbselectarea("SFB")    // busca a aliquota padrao
if dbseek(xfilial()+aImp[1])
	nAliq:=SFB->FB_ALIQ
endif
If SA1->A1_TIPO=="1" //cliente tipo 1 (distribuidor) - calcular usando o "ficto"
	nBase:=aItem[1]
	nBase:=nBase * StaticCall( M100FIS, FISFicto,aImp[1],cGrp,SF4->F4_CODIGO)
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
���Programa  �M460TCFN  �Autor  �Marcello Gabriel    �Fecha �  13/10/2003 ���
�������������������������������������������������������������������������͹��
���Desc.     �Calculo TCF (Uruguai)                                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function M460TCFN(cCalculo,nItem,aInfo)
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