#INCLUDE "Protheus.ch"
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Funcao    � M100FUE  � Autor � Luciana Pires� Data � 16.09.11  ���
��������������������������������������������������������������������������Ĵ��
���Descricao � Calculo do imposto FUE nas notas de entrada para Austr�lia                          ���
��������������������������������������������������������������������������Ĵ��
���Uso		 � Austr�lia                                        ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function M100FUE(cCalculo,nItem,aInfo)
Local aImp 		:= {}
Local aItem 		:= {}
Local aArea		:= GetArea()

Local cImp			:= ""
Local cProd		:= ""                                                                                 
Local cConcept 	:= ""
Local cMetodo 	:= ""

Local nImp			:= 0
Local nBase		:= 0
Local nAliq 		:= 0
Local nDecs 		:= 0
Local nVlrFUE	:= 0

Local xRet	            

Local lxFis			:=	(MafisFound() .And. ProcName(1)!="EXECBLOCK")
// .T. - metodo de calculo utilizando a matxfis
// .F. - metodo antigo de calculo

/*
���������������������������������������������������������������Ŀ
� Observacao :                                                  �
�                                                               �
� a variavel ParamIxb tem como conteudo um Array[2], contendo : �
� [1,1] > Quantidade Vendida                                    �
� [1,2] > Preco Unitario                                        �
� [1,3] > Valor Total do Item, com Descontos etc...             �
� [1,4] > Valor do Frete rateado para este Item ...             �
� [1,5] > Valor das Despesas rateado para este Item...          �
� [1,6] > Array Contendo os Impostos j� calculados, no caso de  �
�        incid�ncia de outros impostos.                         �
� [2,1] > Array aImposto, Contendo as Informa��es do Imposto que�
�         ser� calculado (funcao a100TexXIp -> fonte LOCXFUN.prx).                                       �
�����������������������������������������������������������������
*/

If !lXFis
   	aItem		:= ParamIxb[1]
   	aImp			:= ParamIxb[2]
	xRet     		:= ParamIxb[2]
   	cImp			:= aImp[01]
   	cProd 		:= SB1->B1_COD
   	cMetodo	:= SD1->D1_METODO
   	nVlrFUE	:= SD1->D1_VLRFUE
Else
	xRet			:= 0
   	cImp			:= aInfo[01]
   	cProd		:= MaFisRet(nItem,"IT_PRODUTO")   
	cMetodo	:= MaFisRet(nItem,"IT_METODO")   
	nVlrFUE	:= MaFisRet(nItem,"IT_VLRFUE")   
		
	dbSelectArea("SF4")
	SF4->(DbSeek(xFilial("SF4")+MaFisRet(nItem,"IT_TES")))
Endif           
                                   
//���������������������������������������������Ŀ
//�Verificando o cadastro do produto movimentado�
//�����������������������������������������������
//Frontloja usa o arquivo SBI para cadastro de produtos
If cModulo == "FRT" 
	SBI->(DbSeek(xFilial("SBI")+cProd))
Else   
	SB1->(DbSeek(xFilial("SB1")+cProd))
Endif    
                         
//�����������������������������������������������������������������Ŀ
//�Guardo o conceito do produto�
//�������������������������������������������������������������������
If (SB1->(FieldPos("B1_CONFUE")) > 0 .And. !Empty(SB1->B1_CONFUE))				                                              
	cConcept := SB1->B1_CONFUE
Endif
               
//�����������������������������������������������������������������Ŀ
//�Busca a aliquota padrao para o imposto �
//�������������������������������������������������������������������
DbSelectArea("SFB")    
SFB->(DbSetOrder(1))
If SFB->(Dbseek(xFilial("SFB")+cImp))
	nAliq := SFB->FB_ALIQ
Endif

//�����������������������������������������������������������������Ŀ
//�Busca / posiciono a aliquota atrav�s da CCR �
//�������������������������������������������������������������������
dbSelectArea("CCR")
CCR->(dbSetOrder(3))	//CCR_FILIAL+CCR_CONCEP+CCR_IMP+CCR_PAIS
If CCR->(dbSeek(xFilial("CCR")+cConcept+cImp))
	If !Empty(CCR->CCR_ALIQ)
		nAliq := CCR->CCR_ALIQ
	EndIf
EndIf

//������������������������������������������������������������Ŀ
//�Verifica os decimais da moeda para arredondamento do valor  �
//��������������������������������������������������������������
nDecs := IIf(Type("nMoedaNf") # "U",MsDecimais(nMoedaNf),MsDecimais(1))
        
If !lXFis
	aImp[02] := nAliq     
	aImp[03] := aItem[01] //neste momento a Base � a Quantidade

	If cMetodo == "1" //percental
		aImp[03] 	:= Round(aItem[01] * (nVlrFUE/100),nDecs)		 	
	Elseif cMetodo == "2" //Valor
		aImp[03] 	:= Round(nVlrFUE,nDecs)		 	
	Endif

	aImp[04] 	:= Round(aImp[03] * (nAliq/100),nDecs)		 			

	//�������������������������������������������������������Ŀ
	//�Retorna um array com base [3], aliquota [2] e valor [4]�
	//���������������������������������������������������������
	xRet:=aImp   
Else
	nBase:=MaFisRet(nItem,"IT_QUANT")
	
	If cMetodo == "1" //percental
		nBase	:= Round(nBase * (nVlrFUE/100),nDecs)
	Elseif cMetodo == "2" //Valor
		nBase	:= Round(nVlrFUE,nDecs)		
	Endif

	nImp 	:= Round(nBase * (nAliq/100),nDecs)	                                                             

	//�������������������������������������������������������������Ŀ
	//�Retorna o valor solicitado pela MatxFis (parametro cCalculo):�
	//�A = Aliquota de calculo                                      �
	//�B = Base de calculo                                          �
	//�V = Valor do imposto                                         �
	//���������������������������������������������������������������
	
	Do Case
	Case cCalculo=="B"
		xRet:=nBase
	Case cCalculo=="A"
		xRet:=nALiq
	Case cCalculo=="V"
		xRet:=nImp
	EndCase
EndIf

RestArea(aArea)
	
Return(xRet)
