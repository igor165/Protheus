/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o	 � M100IVS	� Autor � MARCELLO GABRIEL     � Data � 08.12.1999 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � CALCULO IVA SERVICO  (entrada)                              ���
��������������������������������������������������������������������������Ĵ��
���Uso		 � Generico                                                    ���
��������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                      ���
��������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                    ���
��������������������������������������������������������������������������Ĵ��
��� Percy Horna  �19/10/00�xxxxxx�Fue alterada a base de datos de Excep-   ���
���              �        �      �ciones de SF7->SFF, inicialmente utili-  ���
���              �        �      �zando los Impuestos de IESPS (mejico).   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
FUNCTION M100IVS(cCalculo,nItem,aInfo)
local cDbf:=alias(),nOrd:=IndexOrd(),aItem,aAux,nOrdSFC,nRegSFC
local nAux:=0,nBase:=0,nAliq:=0,lIsento:=.f.,lALIQ:=.f.,cFil,cAux,nColCFO,nColTES,TipOP
local cImp,lXfis
local cImpIncid,nE,nI

lXfis:=(MafisFound() .And. ProcName(1)<>"EXECBLOCK")
/*
���������������������������������������������������������������Ŀ
� A variavel ParamIxb tem como conteudo um Array[2,?]:          �
�                                                               �
� [1,1] > Quantidade Vendida                     		        �
� [1,2] > Preco Unitario                            	        �
� [1,3] > Valor Total do Item, com Descontos etc...             �
� [1,4] > Valor do Frete Rateado para Este Item ...             �
� [1,5] > Array Contendo os Impostos j� calculados, no caso de  �
�         incid�ncia de outros impostos.                        �
� [2,?] > Array xRetosto, Contendo as Informa�oes do Imposto que�
�         ser� calculado.                                       �
�����������������������������������������������������������������
*/
If !lXfis
	aItem:=ParamIxb[1]
	xRet:=ParamIxb[2]
	cImp:=xRet[1]
	cImpIncid:=xRet[10]
Else
	cImp:=aInfo[1]
	SB1->(DbGoto(MaFisRet(nItem,"IT_RECNOSB1")))
	xRet:=0
	cImpIncid:=""
Endif

dbselectarea("SFF")     // verificando as excecoes fiscais
dbSetOrder(3)

cFil:=xfilial()
if dbseek(cFil+cImp)
	while FF_IMPOSTO == cImp .and. FF_FILIAL == cFil .and. !lAliq
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

if !lIsento
	if !lAliq .And. If(!lXFis,.T.,cCalculo="A")
		dbselectarea("SFB")    // busca a aliquota padrao
		if dbseek(xfilial()+cImp)
			nAliq:=SFB->FB_ALIQ
		endif
	endif
	If !lXfis
		nBase:=aItem[3]+aItem[5] // total + outros impostos
		//Tira os descontos se for pelo liquido .Bruno
		If Subs(xRet[5],4,1) == "S" .And. Len(xRet) >= 18 .And. ValType(xRet[18])=="N"
			nBase-=xRet[18]
		Endif
		//+---------------------------------------------------------------+
		//� Soma a Base de C�lculo os Impostos Incidentes                 �
		//+---------------------------------------------------------Lucas-+
		nI:=At(cImpIncid,";" )
		nI:=If(nI==0,Len(AllTrim(cImpIncid))+1,nI)
		While nI>1
			nE:=AScan(aItem[6],{|x| x[1]==Left(cImpIncid,nI-1)})
			If nE>0
				nBase+=aItem[6,nE,4]
			End
			cImpIncid:=Stuff(cImpIncid,1,nI,"")
			nI:=At(cImpIncid,";")
			nI:=If(nI==0,Len(AllTrim(cImpIncid))+1,nI)
		Enddo
	Else
		If cCalculo=="B"
			nBase:=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
			//Tira os descontos se for pelo liquido
			nOrdSFC:=(SFC->(IndexOrd()))
			nRegSFC:=(SFC->(Recno()))
			SFC->(DbSetOrder(2))
			If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+cImp)))
				cImpIncid:=Alltrim(SFC->FC_INCIMP)
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
							nBase+=aImpVal[nI]
						Endif
					Endif
				Next
			Endif
		Endif
	Endif
endif

If !lXfis
	xRet[02]:=nAliq
	xRet[03]:=nBase
	xRet[04]:=(nAliq*nBase)/100
Else
	Do Case
		Case cCalculo=="B"
			xRet:=nBase
		Case cCalculo=="A"
			xRet:=nALiq
		Case cCalculo=="V"
			nBase:=MaFisRet(nItem,"IT_BASEIV"+aInfo[2])
			nAliq:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[2])
			xRet:=(nAliq * nBase)/100
	EndCase
Endif

dbSelectarea(cDbf)
dbSetOrder(nOrd)
Return(xRet)
