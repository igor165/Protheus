#INCLUDE "Protheus.ch"
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Funcao    � M460GST  � Autor � Luciana Pires� Data � 08.09.11  ���
��������������������������������������������������������������������������Ĵ��
���Descricao � Calculo do imposto GST (destacado) nas notas de sa�da para Austr�lia                          ���
��������������������������������������������������������������������������Ĵ��
���Uso		 � Austr�lia                                        ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function M460GST(cCalculo,nItem,aInfo)
Local aImp      	:= {}
Local aItem 		:= {}
Local aArea		:= GetArea()
Local	 aImpRef	:= {}
Local aImpVal	:= {}

Local cImp			:= ""
Local cProd		:= ""
Local cIncImp	:= ""	
Local cGSTReg	:= SuperGetMv("MV_GSTREG",,"1")

Local nOrdSFC	:= 0    
Local nRegSFC	:= 0
Local nImp			:= 0
Local nBase		:= 0
Local nAliq 		:= 0
Local nDecs 		:= 0  
Local nI				:= 0

Local xRet	

Local lxFis	:=	(MafisFound() .And. ProcName(1)!="EXECBLOCK")
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
�         ser� calculado  (funcao a460TexXIp -> fonte LOCXFUN.prx).                                       �
�����������������������������������������������������������������
*/

If !lXFis
   	aItem	:= ParamIxb[1]
   	aImp		:= ParamIxb[2]
   	cImp		:= aImp[01]
   	cProd 	:= SB1->B1_COD
	cIncImp	:=aImp[10] // Impostos que incidem
Else
   cImp		:= aInfo[01]
   cProd		:= MaFisRet(nItem,"IT_PRODUTO")   
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
//�Busca a aliquota padrao para o imposto �
//�������������������������������������������������������������������
DbSelectArea("SFB")    
SFB->(DbSetOrder(1))
If SFB->(Dbseek(xFilial("SFB")+cImp))
	nAliq := SFB->FB_ALIQ
Endif

//������������������������������������������������������������Ŀ
//�Verifica os decimais da moeda para arredondamento do valor  �
//��������������������������������������������������������������
nDecs := IIf(Type("nMoedaNf") # "U",MsDecimais(nMoedaNf),MsDecimais(1))

If !lXFis
	If cGSTReg <> "3" 
		aImp[02] := nAliq
		aImp[03] := aItem[03]+aItem[04]+aItem[05]

		//����������������������������������������������������������������������Ŀ
		//�Reduz os descontos, quando a configura��o indica calculo pelo liquido.�
		//������������������������������������������������������������������������
		If Subs(aImp[05],4,1) == "S" .And. Len(aImp) >= 18 .And. ValType(aImp[18])=="N"
			aImp[03]	-= aImp[18]
		Endif

		//����������������������������������������������������������Ŀ
		//� Soma na Base de C�lculo os Impostos Incidentes            
		//������������������������������������������������������������
		nI := aScan( aItem[6],{|x| x[1] == AllTrim(cIncImp) } )
		If nI > 0
			aImp[03] += aItem[6,nI,4]
		Endif
	
		//�������������������������������������������������������������Ŀ
		//�Efetua o Calculo do Imposto quando o campo no produto (B1_NCGST) estiver definido como "1"�
		//���������������������������������������������������������������
		If (SB1->(FieldPos("B1_INCGST")) > 0 .And. SB1->B1_INCGST == "1")				
			aImp[04] 	:= Round(aImp[03] * (aImp[02]/100),nDecs)
		Else	   
			// Neste caso o GST � free, ou seja, gravo somente a base de c�lculo, por isso zero a al�quota e o valor do imposto.
			aImp[02] := 0
			aImp[04] := 0			              
		Endif

		//�������������������������������������������������������Ŀ
		//�Retorna um array com base [3], aliquota [2] e valor [4]�
		//���������������������������������������������������������
		xRet:=aImp   
	Else
	
		// Neste caso o GST n�o � calculado, pois o par�metro MV_GSTREG est� definido como "3"
		aImp[02] := 0
		aImp[03] := 0			
		aImp[04] := 0			              

		//�������������������������������������������������������Ŀ
		//�Retorna um array com base [3], aliquota [2] e valor [4]�
		//���������������������������������������������������������
		xRet:=aImp   

	Endif
Else
	If cGSTReg <> "3" 		
		nBase:=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
		
		//����������������������������������������������������������������������Ŀ
		//�Reduz os descontos, quando a configura��o indica calculo pelo liquido.�
		//������������������������������������������������������������������������
		nOrdSFC:=(SFC->(IndexOrd()))
		nRegSFC:=(SFC->(Recno()))
		
		SFC->(DbSetOrder(2))
		If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+cImp)))
			If SFC->FC_LIQUIDO=="S"
				nBase -= If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
				cIncImp := SFC-> FC_INCIMP
			Endif
		Endif
		
		SFC->(DbSetOrder(nOrdSFC))
		SFC->(DbGoto(nRegSFC))

		//�������������������������������������������������������������Ŀ
		//�Soma a Base de C�lculo os Impostos Incidentes                 
		//���������������������������������������������������������������
		If !Empty(cIncImp)
			aImpRef:=MaFisRet(nItem,"IT_DESCIV")
			aImpVal:=MaFisRet(nItem,"IT_VALIMP")
			For nI:=1 to Len(aImpRef)
				If !Empty(aImpRef[nI])
					IF Trim(aImpRef[nI][1])$cIncImp
						nBase+=aImpVal[nI]
					Endif
				Endif
			Next
		Endif
		
		//�������������������������������������������������������������Ŀ
		//�Efetua o Calculo do Imposto quando o campo no produto (B1_NCGST) estiver definido como "1"�
		//���������������������������������������������������������������
		If (SB1->(FieldPos("B1_INCGST")) > 0 .And. SB1->B1_INCGST == "1")				
			nImp		:= Round(nBase *(nAliq/100),nDecs)
		Else	   
			// Neste caso o GST � free, ou seja, gravo somente a base de c�lculo, por isso zero a al�quota e o valor do imposto.
			nALiq := 0
			nImp	 := 0			              
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
	Else
		// Neste caso o GST n�o � calculado -> MV_GSTREG = "3"
		nALiq 	:= 0
		nImp	 	:= 0			              
		nBase	:= 0	
	
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
