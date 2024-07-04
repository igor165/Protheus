#INCLUDE "Protheus.ch"
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Funcao    � M460CDU  � Autor � Luciana Pires� Data � 13.10.11  ���
��������������������������������������������������������������������������Ĵ��
���Descricao � Calculo do imposto CDU nas notas de sa�da para Austr�lia                          ���
��������������������������������������������������������������������������Ĵ��
���Uso		 � Austr�lia                                        ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/  
Function M460CDU(cCalculo,nItem,aInfo)
Local aImp 		:= {}
Local aItem 		:= {}
Local aArea		:= GetArea()

Local cImp			:= ""
Local cProd		:= ""                                                                                 
Local cConcept := ""
Local cUMCCR	:= ""
Local cUMSB1 	:= ""
Local cEstado	:= ""

Local nOrdSFC	:= 0    
Local nRegSFC	:= 0                                                                                       	
Local nImp			:= 0
Local nBase		:= 0                                                                                                                                                                                                                                
Local nAliq 		:= 0
Local nDecs 		:= 0  
Local nValFixo 	:= 0
Local nConv		:= 0
Local nMinCDU	:= SuperGetMV("MV_MINCDU",,1000) //M�nimo Comum
Local nQtdade	:= 0

Local xRet	            

Local lCalcula	:= .T.
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
�         ser� calculado (funcao a460TexXIp -> fonte LOCXFUN.prx).                                       �
�����������������������������������������������������������������
*/

If !lXFis
   	aItem	:= ParamIxb[1]
   	aImp		:= ParamIxb[2]
	xRet     := ParamIxb[2]
   	cImp		:= aImp[01]
   	cProd 	:= SB1->B1_COD
Else
	xRet		:= 0
   	cImp		:= aInfo[01]
   	cProd	:= MaFisRet(nItem,"IT_PRODUTO")   
	
	dbSelectArea("SF4")
	SF4->(DbSeek(xFilial("SF4")+MaFisRet(nItem,"IT_TES")))
Endif           

//���������������������������������������������Ŀ
//� Dados do cliente/fornecedor
//�����������������������������������������������
If cModulo$"FAT|LOJA|TMK|FRT"
	cEstado := SA1->A1_EST
Else                                                                                                 
	cEstado := SA2->A2_EST
Endif
                                   
//���������������������������������������������Ŀ
//�Verificando o cadastro do produto movimentado�
//�����������������������������������������������
//Frontloja usa o arquivo SBI para cadastro de produtos
If cModulo == "FRT" 
	SBI->(DbSeek(xFilial("SBI")+cProd))
	cUMSB1 	:= SBI->BI_UM
	nConv		:=	SBI->BI_CONV
Else   
	SB1->(DbSeek(xFilial("SB1")+cProd))
	cUMSB1 	:= SB1->B1_UM
	nConv		:=	SB1->B1_CONV
Endif    
                         
//�����������������������������������������������������������������Ŀ
//�Guardo o conceito do produto�
//�������������������������������������������������������������������
If (SB1->(FieldPos("B1_CONCDU")) > 0 .And. !Empty(SB1->B1_CONCDU))				                                              
	cConcept := SB1->B1_CONCDU
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
	If !Empty(CCR->CCR_ALIQ) .Or. !Empty(CCR->CCR_VALOR)
		nAliq 		:= CCR->CCR_ALIQ
		nValFixo 	:= CCR->CCR_VALOR
		cUMCCR	:= CCR->CCR_UNID
	EndIf
EndIf

//�����������������������������������������������������������������Ŀ
//�Verifico se o imposto � free ou n�o
//�������������������������������������������������������������������
If (nAliq == 0 .And. nValFixo == 0)
	lCalcula := .F.
Endif

//������������������������������������������������������������Ŀ
//�Verifica os decimais da moeda para arredondamento do valor  �
//��������������������������������������������������������������
nDecs := IIf(Type("nMoedaNf") # "U",MsDecimais(nMoedaNf),MsDecimais(1))
        
If Alltrim(cEstado) == "EX"
	If !lXFis
		aImp[02] := nAliq
		aImp[03] := aItem[03]+aItem[04]+aItem[05]
	
		//����������������������������������������������������������������������Ŀ
		//�Reduz os descontos, quando a configura��o indica calculo pelo liquido.�
		//������������������������������������������������������������������������
		If Subs(aImp[05],4,1) == "S" .And. Len(aImp) >= 18 .And. ValType(aImp[18])=="N"
			aImp[03]	-= aImp[18]
		Endif
	
		//�������������������������������������������������������������Ŀ
		//�Efetua o Calculo do Imposto quando a vari�vel lCalcula estiver definida como .T.                        �
		//���������������������������������������������������������������
		If lCalcula
			If nAliq > 0 //a f�rmula � pela al�quota
				//Verifico o m�nimo
				If nMinCDU < aImp[03]
					aImp[04] 	:= Round(aImp[03] * (aImp[02]/100),nDecs)
				Else 
					aImp[02] := 0
					aImp[03] := 0
					aImp[04] := 0			              			
				Endif
			Else 			//a f�rmula � pelo valor fixo
				//Verifico o m�nimo
				If nMinCDU < aImp[03]
					If Alltrim(cUMCCR) <> Alltrim(cUMSB1)   // Se a unidade de medida � diferente, eu converto o valor -> formula pela quantidade
						aImp[04] 	:= Round((aItem[01] * nConv) * (nValFixo),nDecs)	                                                             
						aImp[03] 	:= 0 //zero a base de c�lculo porque fa�o o c�lculo pela quantidade + valor fixo
						aImp[02]	:= 0
				 	Else
						aImp[04] 	:= Round(aItem[01] * nValFixo,nDecs)		 	
						aImp[03] 	:= 0 //zero a base de c�lculo porque fa�o o c�lculo pela quantidade + valor fixo
						aImp[02]	:= 0
				 	Endif
				Else 
					aImp[02] := 0
					aImp[03] := 0
					aImp[04] := 0			              			
				Endif			
			Endif			
		Else	   
			// Neste caso n�o calculo o CDU 
			aImp[02] := 0
			aImp[03] := 0
			aImp[04] := 0			              
		Endif
	  
		//�������������������������������������������������������Ŀ
		//�Retorna um array com base [3], aliquota [2] e valor [4]�
		//���������������������������������������������������������
		xRet:=aImp   
	Else
		nBase		:=MaFisRet(nItem,"IT_VALMERC")
		nQtdade	:=MaFisRet(nItem,"IT_QUANT")
		
		//����������������������������������������������������������������������Ŀ
		//�Reduz os descontos, quando a configura��o indica calculo pelo liquido.�
		//������������������������������������������������������������������������
		nOrdSFC:=(SFC->(IndexOrd()))
		nRegSFC:=(SFC->(Recno()))
		
		SFC->(DbSetOrder(2))
		If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+cImp)))
			If SFC->FC_LIQUIDO=="S"
				nBase -= If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
			Endif
		Endif
		
		SFC->(DbSetOrder(nOrdSFC))
		SFC->(DbGoto(nRegSFC))
	
		//�������������������������������������������������������������Ŀ
		//�Efetua o Calculo do Imposto quando a vari�vel lCalcula estiver definida como .T.                        �
		//���������������������������������������������������������������
		If lCalcula
			If nAliq > 0 //a f�rmula � pela al�quota
				//Verifico o m�nimo
				If nMinCDU < nBase
					nImp 	:= Round(nBase * (nAliq/100),nDecs)
				Else 
					nAliq 	:= 0
					nBase 	:= 0
					nImp 	:= 0			              			
				Endif
			Else 			//a f�rmula � pelo valor fixo
				//Verifico o m�nimo
				If nMinCDU < nBase
					If Alltrim(cUMCCR) <> Alltrim(cUMSB1)   // Se a unidade de medida � diferente, eu converto o valor -> formula pela quantidade
						nImp 	:= Round((nQtdade * nConv) * (nValFixo),nDecs)	                                                             
				 	Else
						nImp 	:= Round(nQtdade * nValFixo,nDecs)		 	
				 	Endif
				Else 
					nAliq 	:= 0
					nBase 	:= 0
					nImp 	:= 0			              			
				Endif			
			Endif			
		Else	   
			// Neste caso n�o calculo o CDU 
			nAliq 	:= 0        
			nBase	:= 0
			nImp	 	:= 0			              
		Endif
	  
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
Endif	
RestArea(aArea)
	
Return(xRet)
