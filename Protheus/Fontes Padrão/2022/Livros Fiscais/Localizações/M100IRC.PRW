#include "SIGAWIN.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �M100IRC   �Autor  �Mary C. Hergert     � Data � 21/05/2008  ���
�������������������������������������������������������������������������͹��
���Desc.     �Efetua o calculo do IRC nas entradas para Portugal          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function M100IRC(cCalculo,nItem,aInfo)      

Local aImp 		:= {}
Local aItem 	:= {}
Local aArea		:= GetArea()

Local cImp		:= ""
Local cTes   	:= ""
Local cRegiao	:= ""
Local cProd		:= ""

Local nOrdSFC   := 0
Local nRegSFC   := 0
Local nImp   	:= 0
Local nBase		:= 0
Local nAliq 	:= 0
Local nDecs 	:= 0

Local lAliq 	:= .F.
Local lCalcLiq	:= .F.
Local lXFis 	:= (MafisFound() .And. ProcName(1)!="EXECBLOCK")

Local xRet

/*
�������������������������������������������������������������������������������Ŀ
� Observacao :                                                                  �
�                                                                               �
� A variavel ParamIxb tem como conteudo um Array[2], contendo :                 �
� [1,1] > Quantidade Vendida                                                    �
� [1,2] > Preco Unitario                                                        �
� [1,3] > Valor Total do Item, com Descontos etc...                             �
� [1,4] > Valor do Frete rateado para este Item                                 �
�         Para Portugal, o imposto do frete e calculado em separado do item     �
� [1,5] > Valor das Despesas rateado para este Item                             �
�         Para Portugal, o imposto das despesas e calculado em separado do item �
� [1,6] > Array Contendo os Impostos j� calculados, no caso de incid�ncia de    �
�         outros impostos.                                                      �
� [2,1] > Array aImposto, contendo as Informa��es do Imposto que ser� calculado.�
���������������������������������������������������������������������������������
*/
If !lXfis
   aItem	:= ParamIxb[1]
   aImp		:= ParamIxb[2]
   cImp		:= aImp[1]
   cTes		:= SF4->F4_CODIGO
   cProd 	:= SB1->B1_COD
Else
   cImp		:= aInfo[1]
   cTes		:= MaFisRet(nItem,"IT_TES")  
   cProd	:= MaFisRet(nItem,"IT_PRODUTO")   
Endif                                         

//���������������������������������������������Ŀ
//�Verificando o cadastro do produto movimentado�
//�����������������������������������������������
dbSelectArea("SB1")
SB1->(dbSetOrder(01))
SB1->(dbSeek(xFilial("SB1")+cProd))

//���������������������������������������������������������������������������������������Ŀ
//�Verifica a existencia do Plano IVA para aliquotas diferentes do padrao de 25% para IRC �
//�����������������������������������������������������������������������������������������
dbSelectArea("SFF")
SFF->(dbSetOrder(14))
If SFF->(dbseek(xFilial("SFF")+cImp+cRegiao+SB1->B1_GRTRIB))
	nAliq := SFF->FF_ALIQ	
	lAliq := .T.
Else
	//�����������������������������������������������������������������Ŀ
	//�Busca a aliquota padrao para o imposto quando nao ha o plano IVA �
	//�������������������������������������������������������������������
	If !lAliq   
      	DbSelectArea("SFB")    
      	SFB->(DbSetOrder(1))
      	If SFB->(Dbseek(xFilial("SFB")+cImp))
			nAliq := SFB->FB_ALIQ
		Endif
	Endif
Endif
	
//���������������������������������
//�Monta a base de calculo do IRC.�
//���������������������������������
If !lXFis            
	nBase := aItem[3] + aItem[4] + aItem[5] +  aItem[10] + aItem[11]
Else
	nBase := 	MaFisRet(nItem,"IT_VALMERC") + ;
				MaFisRet(nItem,"IT_FRETE") + ;
				MaFisRet(nItem,"IT_DESPESA") + ;
				MaFisRet(nItem,"IT_SEGURO") + ;
				MaFisRet(nItem,"IT_DESNTRB") + ; 
				MaFisRet(nItem,"IT_TARA")
Endif

//������������������������������������������������������������Ŀ
//�Verifica os decimais da moeda para arredondamento do valor  �
//��������������������������������������������������������������
nDecs := IIf(Type("nMoedaNf") # "U",MsDecimais(nMoedaNf),MsDecimais(1))

If !lXFis

	aImp[02] := nAliq
	aImp[03] := nBase

	//����������������������������������������������������������������������Ŀ
	//�Reduz os descontos, quando a configura��o indica calculo pelo liquido.�
	//������������������������������������������������������������������������
	If Subs(aImp[5],4,1) == "S" .And. Len(aImp) >= 18 .And. ValType(aImp[18])=="N"
		aImp[3]	-= aImp[18]
		nBase	:= aImp[3]
	Endif
	
	//���������������������������Ŀ
	//�Efetua o Calculo do Imposto�
	//�����������������������������
	aImp[4] := Round(aImp[3] * (aImp[02]/100),nDecs)	
	
	//�������������������������������������������������������Ŀ
	//�Retorna um array com base [3], aliquota [2] e valor [4]�
	//���������������������������������������������������������
	xRet := aImp
Else
	//Caso seja um imposto "dependente" o tratamento de desconto ja foi realizado.	
	If !lCalcLiq

		nOrdSFC := (SFC->(IndexOrd()))
		nRegSFC := (SFC->(Recno()))

		//����������������������������������������������������������������������Ŀ
		//�Reduz os descontos, quando a configura��o indica calculo pelo liquido.�
		//������������������������������������������������������������������������
		SFC->(DbSetOrder(2))
		If (SFC->(DbSeek(xFilial("SFC")+cTes+cImp)))
			If SFC->FC_LIQUIDO == "S"
				nBase -= If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
			Endif
		Endif                                              
		
		SFC->(DbSetOrder(nOrdSFC))
		SFC->(DbGoto(nRegSFC))
		
	EndIf
       
	nImp := Round(nBase * (nAliq/100),nDecs)	
	
	//�������������������������������������������������������������Ŀ
	//�Retorna o valor solicitado pela MatxFis (parametro cCalculo):�
	//�A = Aliquota de calculo                                      �
	//�B = Base de calculo                                          �
	//�V = Valor do imposto                                         �
	//���������������������������������������������������������������
	Do Case
		Case cCalculo=="B"
			xRet := nBase
		Case cCalculo=="A"
			xRet := nALiq
		Case cCalculo=="V"
			xRet := nImp
	EndCase
	
Endif

RestArea(aArea)
	
Return(xRet)
