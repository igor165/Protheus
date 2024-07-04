#INCLUDE "Protheus.ch"

//Posicoes  do terceiro array recebido nos impostos a traves da matxfis...
#DEFINE X_IMPOSTO    01  //Nome do imposto
#DEFINE X_NUMIMP     02  //Sufixo do imposto

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � M460ISC  � Autor � Ivan Haponczuk      � Data � 21.10.2011 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Calculo do ISC - Saida                                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cPar01 - Solicitacao da MATXFIS, pondendo ser A (aliquota),���
���          �          B (base), V (valor).                              ���
���          � nPar02 - Item do documento fiscal.                         ���
���          � aPar03 - Array com as informacoes do imposto.              ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � xRet - Retorna o valor solicitado pelo paremetro cPar01    ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
��� Uso      � MATXFIS                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function M460ISC(cCalculo,nItem,aInfo)

	Local xRet
	Local cFunct   := ""
	Local aCountry := {}
	Local lXFis    := .T.
	Local aArea    := GetArea()
	
	lXFis    := ( MafisFound() .And. ProcName(1)!="EXECBLOCK" )
	aCountry := GetCountryList()
	cFunct   := "M460ISC" + aCountry[aScan( aCountry, { |x| x[1] == cPaisLoc } )][3] //monta nome da funcao
	xRet     := &(cFunct)(cCalculo,nItem,aInfo,lXFis) //executa a funcao do pais

	RestArea(aArea)

Return xRet

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa  � M460ISCRD � Autor � Ivan Haponczuk      � Data � 21.10.2011 ���
��������������������������������������������������������������������������Ĵ��
���Descricao � Calculo do ISC - Saida - Republica Domicana                 ���
��������������������������������������������������������������������������Ĵ��
���Parametros� cPar01 - Solicitacao da MATXFIS, pondendo ser A (aliquota), ���
���          �          B (base), V (valor).                               ���
���          � nPar02 - Item do documento fiscal.                          ���
���          � aPar03 - Array com as informacoes do imposto.               ���
���          � lPar04 - Define se e rotina automaticao ou nao.             ���
��������������������������������������������������������������������������Ĵ��
���Retorno   � xRet - Retorna o valor solicitado pelo paremetro cPar01     ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � Republica Dominicana                                        ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function M460ISCRD(cCalculo,nItem,aInfo)

	Local nBase    := 0
	Local nAliq    := 0 
	Local nValor   := 0
	Local nMargem  := 0
	Local nFatConv := 0
	Local cConcept := ""
	Local cProduto := ""
	Local aItem    := {}
	Local aArea    := GetArea()
	
	If !lXFis
		aItem    := ParamIxb[1]
		xRet     := ParamIxb[2]
		cImp     := xRet[1]
		cProduto := xRet[16]
	Else
		xRet     := 0
		cProduto := MaFisRet(nItem,"IT_PRODUTO")
		cImp     := aInfo[X_IMPOSTO]
	EndIf
	
	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	If SB1->(dbSeek(xFilial("SB1")+cProduto))
		cConcept := SB1->B1_CONISC
		nMargem  := SB1->B1_MARGISC
		If SB1->B1_FATISC == 0
			nFatConv := 1
		Else
			nFatConv := SB1->B1_FATISC
		EndIf
	EndIf
	
	If If(!lXFis,.T.,cCalculo=="A")
		
		// Aliquota padrao
		dbSelectArea("SFB")
		SFB->(dbSetOrder(1))
		If SFB->(dbSeek(xFilial("SFB")+cImp))
			nAliq := SFB->FB_ALIQ
		Endif
		
		dbSelectArea("CCR")
		CCR->(dbSetOrder(1))//CCR_FILIAL+CCR_CONCEP+CCR_PAIS
		If CCR->(dbSeek(xFilial("CCR")+cConcept))
			If !Empty(CCR->CCR_ALIQ)
				nAliq := CCR->CCR_ALIQ
			EndIf
			nValor := CCR->CCR_VALOR
		EndIf
		
	EndIf
	
	If !lXFis
		nMargem := (nMargem * aItem[3])/100
		nBase:=aItem[3]+aItem[4]+aItem[5]+nMargem //valor total + frete + outros impostos
		xRet[02]:=nAliq
		xRet[03]:=nBase
		//Tira os descontos se for pelo liquido .Bruno
		If Subs(xRet[5],4,1) == "S" .And. Len(xRet) >= 18 .And. ValType(xRet[18])=="N"
			xRet[3]-=xRet[18]
			nBase:=xRet[3]
		Endif
		xRet[04]:=(nAliq * nBase)/100
		xRet[04]+=(nValor*(aItem[1]*nFatConv))
	Else
		Do Case
			Case cCalculo=="B"
				nMargem := (nMargem * MaFisRet(nItem,"IT_VALMERC"))/100
				xRet:=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")+nMargem
				If GetNewPar("MV_DESCSAI","1")=="1" .and. FunName() == "MATA410"
					xRet += MaFisRet(nItem,"IT_DESCONTO")
				Endif
				//Tira os descontos se for pelo liquido]
				dbSelectArea("SFC")
				SFC->(DbSetOrder(2))
				If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+aInfo[X_IMPOSTO])))
					If SFC->FC_LIQUIDO=="S"
						xRet-=If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
					Endif
				Endif
			Case cCalculo=="A"
				xRet:=nALiq
			Case cCalculo=="V"
				dbSelectArea("CCR")
				CCR->(dbSetOrder(1))//CCR_FILIAL+CCR_CONCEP+CCR_PAIS
				If CCR->(dbSeek(xFilial("CCR")+cConcept))
					nValor := CCR->CCR_VALOR
				EndIf
				nAliq:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[X_NUMIMP])
				nBase:=MaFisRet(nItem,"IT_BASEIV"+aInfo[X_NUMIMP])
				xRet:=(nAliq * nBase)/100
				xRet+=(nValor*(MaFisRet(nItem,"IT_QUANT")*nFatConv))
		EndCase
	EndIf
	
	RestArea(aArea)
Return xRet

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa  � M460ISCCR � Autor � Camila Januario     � Data � 07.10.2011 ���
��������������������������������������������������������������������������Ĵ��
���Descricao � Calculo do ISC - Saida - Costa Rica                         ���
��������������������������������������������������������������������������Ĵ��
���Parametros� cPar01 - Solicitacao da MATXFIS, pondendo ser A (aliquota), ���
���          �          B (base), V (valor).                               ���
���          � nPar02 - Item do documento fiscal.                          ���
���          � aPar03 - Array com as informacoes do imposto.               ���
���          � lPar04 - Define se e rotina automaticao ou nao.             ���
��������������������������������������������������������������������������Ĵ��
���Retorno   � xRet - Retorna o valor solicitado pelo paremetro cPar01     ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � Costa Rica                                                  ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function M460ISCCR(cCalculo,nItem,aInfo,lXFis)

	Local nBase    := 0
	Local nAliq    := 0
	Local cConcept := ""
	Local cProduto := ""
	Local aItem    := {}
	Local aArea    := GetArea()
	Local lCalcISC := .F.
	Local nDecs := 0
	
	//������������������������������������������������������������Ŀ
	//�Verifica os decimais da moeda para arredondamento do valor  �
	//��������������������������������������������������������������
	nDecs := IIf(Type("nMoedaNf") # "U",MsDecimais(nMoedaNf),MsDecimais(1))
	
	If !lXFis
		aItem    := ParamIxb[1]
		xRet     := ParamIxb[2]
		cImp     := xRet[1]
		cProduto := xRet[16]
	Else
		xRet     := 0
		cProduto := MaFisRet(nItem,"IT_PRODUTO")
		cImp     := aInfo[X_IMPOSTO]
	EndIf
	
	dbSelectArea("SB1")
	SB1->(dbSetOrder(1))
  	If SB1->(dbSeek(xFilial("SB1")+cProduto))
		cConcept := SB1->B1_CONISC
		lCalcISC := IIF(SB1->B1_CALCISC=="1",.T.,.F.)
	EndIf
	
	If If(!lXFis,.T.,cCalculo=="A")
		
		// Aliquota padrao
		dbSelectArea("SFB")
		SFB->(dbSetOrder(1))
		If SFB->(dbSeek(xFilial("SFB")+cImp))
			nAliq := SFB->FB_ALIQ
		Endif
		
		dbSelectArea("CCR")
		CCR->(dbSetOrder(1))//CCR_FILIAL+CCR_CONCEP+CCR_PAIS
	 	If CCR->(dbSeek(xFilial("CCR")+cConcept))		
			nAliq := CCR->CCR_ALIQ		
		EndIf
	EndIf
	
	If !lXFis .and. lCalcISC
		nBase:=aItem[3]+aItem[4]+aItem[5] //valor total + frete + outros impostos
		xRet[02]:=nAliq
		xRet[03]:=nBase
		If Subs(xRet[5],4,1) == "S" .And. Len(xRet) >= 18 .And. ValType(xRet[18])=="N"
			xRet[3]-=xRet[18]
			nBase:=xRet[3]
		Endif
		xRet[04]:=(nAliq * nBase)/100      
		xRet[04]:=Round(xRet[04],nDecs)	
	Else
		If lCalcISC
			Do Case
				Case cCalculo=="B"
			   		xRet:=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
					If GetNewPar("MV_DESCSAI","1")=="1" 
						xRet += MaFisRet(nItem,"IT_DESCONTO")
					Endif
					//Tira os descontos se for pelo liquido
					dbSelectArea("SFC")
					SFC->(DbSetOrder(2))
					If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+aInfo[X_IMPOSTO])))
						If SFC->FC_LIQUIDO=="S"
							xRet-=If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
						Endif
					Endif
				Case cCalculo=="A"
					xRet:=nALiq
				Case cCalculo=="V"	
					nAliq:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[X_NUMIMP])
					nBase:=MaFisRet(nItem,"IT_BASEIV"+aInfo[X_NUMIMP])
					xRet:=(nAliq * nBase)/100
					xRet:=Round(xRet,nDecs)
			EndCase
		Endif	
	EndIf
	
	RestArea(aArea)
Return xRet 


/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa  � M460ISCCO � Autor � Paulo Pouza     � Data � 10.03.2013 ���
��������������������������������������������������������������������������Ĵ��
���Descricao � Calculo do ISC - Saida - Colombia                         ���
��������������������������������������������������������������������������Ĵ��
���Parametros� cPar01 - Solicitacao da MATXFIS, pondendo ser A (aliquota), ���
���          �          B (base), V (valor).                               ���
���          � nPar02 - Item do documento fiscal.                          ���
���          � aPar03 - Array com as informacoes do imposto.               ���
���          � lPar04 - Define se e rotina automaticao ou nao.             ���
��������������������������������������������������������������������������Ĵ��
���Retorno   � xRet - Retorna o valor solicitado pelo paremetro cPar01     ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � Colombia                                                  ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function M460ISCCO(cCalculo,nItem,aInfo,lXFis)

Local nBase    := 0
Local nAliq    := 0
Local aItem    := {}
Local aArea    := GetArea()
Local nDecs := 0
Local cCFO := "" 
//������������
������������������������������������������������Ŀ
//�Verifica os decimais da moeda para arredondamento do valor  �
//��������������������������������������������������������������
nDecs := IIf(Type("nMoedaNf") # "U",MsDecimais(nMoedaNf),MsDecimais(1))
	
If !lXFis
	aItem    := ParamIxb[1]
	xRet     := ParamIxb[2]
	cImp     := xRet[1]   
	cCFO := SF4->F4_CF
Else
	xRet     := 0
	cImp     := aInfo[X_IMPOSTO]    
	cCFO := MaFisRet(nItem,"IT_CF")
EndIf
	
dbSelectArea("SFB")
SFB->(dbSetOrder(1))
If SFB->(dbSeek(xFilial("SFB")+cImp))
	nAliq := SFB->FB_ALIQ
Endif
	
DbSelectArea("SFF")
SFF->(DbSetOrder(6))
SFF->(DbGoTop())
If dbSeek(xFilial("SFF") +cImp + cCFO) 
	nAliq := SFF->FF_ALIQ
EndIf	
	
	
If !lXFis 
	nBase:=aItem[3]+aItem[4]+aItem[5] //valor total + frete + outros impostos
	xRet[02]:=nAliq
	xRet[03]:=nBase
	If Subs(xRet[5],4,1) == "S" .And. Len(xRet) >= 18 .And. ValType(xRet[18])=="N"
		xRet[3]-=xRet[18]
		nBase:=xRet[3]
	Endif
	xRet[04]:=(nAliq * nBase)/100      
	xRet[04]:=Round(xRet[04],nDecs)	
Else
	Do Case
		Case cCalculo=="B"
	   		xRet:=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
			If GetNewPar("MV_DESCSAI","1")=="1" 
				xRet += MaFisRet(nItem,"IT_DESCONTO")
			Endif
			//Tira os descontos se for pelo liquido
			dbSelectArea("SFC")
			SFC->(DbSetOrder(2))
			If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+aInfo[X_IMPOSTO])))
				If SFC->FC_LIQUIDO=="S"
					xRet-=If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
				Endif
			Endif
		Case cCalculo=="A"
			xRet:=nALiq
		Case cCalculo=="V"	
			nAliq:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[X_NUMIMP])
			nBase:=MaFisRet(nItem,"IT_BASEIV"+aInfo[X_NUMIMP])
			xRet:=(nAliq * nBase)/100
			xRet:=Round(xRet,nDecs)
	EndCase
Endif	
	
RestArea(aArea)
Return xRet        


/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa  � M460iscPA � Autor � Marcio Nunes        � Data � 22.03.2013 ���
��������������������������������������������������������������������������Ĵ��
���Descricao � Calculo do ISC - Destacado - Saida - Paraguai               ���
��������������������������������������������������������������������������Ĵ��
���Parametros� cPar01 - Solicitacao da MATXFIS, pondendo ser A (aliquota), ���
���          �          B (base), V (valor).                               ���
���          � nPar02 - Item do documento fiscal.                          ���
���          � aPar03 - Array com as informacoes do imposto.               ���
���          � lPar04 - Define se e rotina automaticao ou nao.             ���
��������������������������������������������������������������������������Ĵ��
���Retorno   � xRet - Retorna o valor solicitado pelo paremetro cPar01     ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � Paraguai                                                    ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/

Function M460iscPA(cCalculo,nItem,aInfo)

Local aImp 			:= {}
Local aItem 		:= {}                                                        
Local aArea			:= GetArea()
Local cImp			:= ""
Local cTes   		:= ""
Local cProd			:= ""
Local cImpIncid		:= ""
Local nOrdSFC   	:= 0    
Local nRegSFC   	:= 0
Local nBase			:= 0
Local nAliq 		:= 0
Local xRet                                              
Local nValMerc		:= 0
Local nAliqAg		:= 0
Local nDecs 		:= 0
Local nMoeda 		:= 1

//�������������������������������������������������������������������Ŀ
//�Identifica se a chamada da funcao do calculo do imposto esta sendo �
//�feita pela matxfis ou pelas rotinas manuais do localizado.         �
//���������������������������������������������������������������������
lXFis := (MafisFound() .And. ProcName(1)!="EXECBLOCK")

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
	aItem		:= ParamIxb[1]
	aImp		:= ParamIxb[2]
	cImp		:= aImp[1]
	cImpIncid	:= aImp[10]
	cTes		:= SF4->F4_CODIGO
	cProd 		:= SB1->B1_COD
Else
   cImp			:= aInfo[1]
   cTes			:= MaFisRet(nItem,"IT_TES")
   cProd		:= MaFisRet(nItem,"IT_PRODUTO")
   nValMerc		:= MaFisRet(nItem,"IT_VALMERC")   
Endif     

	If Type("M->F1_MOEDA")<>"U" 
		nMoeda:= M->F1_MOEDA      
	ElseIf Type("M->C7_MOEDA")<>"U"
		nMoeda:= M->C7_MOEDA    
	ElseIf Type("M->F2_MOEDA")<>"U" 
		nMoeda:= M->F2_MOEDA    
	ElseIf Type("M->C5_MOEDA")<>"U"
		nMoeda:= M->C5_MOEDA      
	ElseIf Type("nMoedaPed")<>"U"	 
		nMoeda:= nMoedaPed           
	ElseIf Type("nMoedaNf")<> "U"
		nMoeda:= nMoedaNf    
	ElseIf Type("nMoedaCor")<> "U"
		nMoeda:= nMoedaCor    		      	
   	ElseIf lXFis
		nMoeda 		:= MAFISRET(,'NF_MOEDA')   
	EndIf		
	
	If Type("nTipoGer")<> "U" .And.	Type("nMoedSel")<> "U"	
		nMoeda:= If(nTipoGer==2,nMoedSel,SC5->C5_MOEDA)	    
	EndIf
	
	nDecs := MsDecimais(nMoeda)      
               
If SB1->(FieldPos("B1_CONISC"))>0 .And. SB1->(dbseek(xfilial("SB1")+Alltrim(cProd)))
	cConcProd := SB1->B1_CONISC
EndIf  

DbSelectArea("SFB")    
   	SFB->(DbSetOrder(1))
   	If SFB->(Dbseek(xFilial("SFB")+cImp))
	nAliq := SFB->FB_ALIQ
Endif 

DbSelectArea("SFB")    
   	SFB->(DbSetOrder(1))
   	If SFB->(Dbseek(xFilial("SFB")+cImpIncid))
	nAliqAg := SFB->FB_ALIQ
Endif
	
//�����������������������������������������������������������������������������������������������������Ŀ
//�Verifica a base de calculo do imposto e se ha o cadastro de impostos incidentes nesta base de calculo�
//�������������������������������������������������������������������������������������������������������
If !lXFis 	 
	//��������������������������������������������������������������������Ŀ
	//�Base de calculo composta pelo valor da mercadoria + frete + seguro  �
	//�Observacao Importante: em Angola nao ha a figura de frete e seguro, �
	//�porem o sistema deve estar preparado para utilizar esses valores no �
	//�calculo do imposto.                                                 �
	//����������������������������������������������������������������������
	nBase := aItem[3]+aItem[4]+aItem[5] 

	//������������������������������������������������Ŀ
	//�Reduz os descontos concedidos da base de calculo�
	//��������������������������������������������������
	If Subs(aImp[5],4,1) == "S" .And. Len(aImp) >= 18 .And. ValType(aImp[18]) == "N"
		nBase -= aImp[18]
	Endif                                              

	//��������������������������������������������������������������������Ŀ
	//�Soma na base de calculo todos os demais impostos incidentes.        �
	//�Observacao Importante: em Angola nao existem impostos que incidem um�
	//�sobre o outro, porem o sistema deve estar preparado para utilizar   �
	//�esses valores no calculo do imposto.                                �
	//����������������������������������������������������������������������

		DbSelectArea("SFF")
		SFF->(DbSetOrder(15))
		If SFF->(DbSeek(xFilial("SFF")+cImp+cConcProd)) .And. SFF->FF_ALIQ>0
			nAliq:=SFF->FF_ALIQ
		EndIf 
		If SFF->(DbSeek(xFilial("SFF")+cImpIncid+cConcProd)) .And. SFF->FF_ALIQ>0
			nAliqAg:=SFF->FF_ALIQ
		EndIf
		//Calculo por fora - Destacado
		aImp[03]:= nBase
		aImp[04]:= (nBase * nAliq/100)   
		xRet:=aImp

Else 
	Do Case
		Case cCalculo=="B"
	    	nBase:=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")	                 			
			//Tira os descontos se for pelo liquido
			nOrdSFC:=(SFC->(IndexOrd()))
			nRegSFC:=(SFC->(Recno()))
			SFC->(DbSetOrder(2))
			If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+aInfo[1])))
				cImpIncid:=Alltrim(SFC->FC_INCIMP)
				If SFC->FC_LIQUIDO=="S"
					nBase-=If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
				Endif
			Endif
						
   		     //+---------------------------------------------------------------+
			//� Soma a Base de C�lculo os Impostos Incidentes                 �
			//+---------------------------------------------------------------+
	   		nAliqAg:=0
	   		If !Empty(cImpIncid)
		   		DbSelectArea("SFB")
            	If DbSeek(xFilial() + cImpIncid )
  			    	nAliqAg := FB_ALIQ
     			Endif
		    EndIf
		    dbSelectArea("SFF")
			SFF->(DbSetOrder(15))
			If SFF->(DbSeek(xFilial("SFF")+cImpIncid+cConcProd)) .And. SFF->FF_ALIQ>0
				nAliqAg	:=SFF->FF_ALIQ
			EndIf
			If SFF->(DbSeek(xFilial("SFF")+cImp+cConcProd)) .And. SFF->FF_ALIQ>0
				nAliq	:=SFF->FF_ALIQ
			EndIf

			xRet:= nBase
	
		Case cCalculo=="A" 
			dbSelectArea("SFF")
			SFF->(DbSetOrder(15))
			If SFF->(DbSeek(xFilial("SFF")+cImp+cConcProd)) .And. SFF->FF_ALIQ>0
			   	xRet:=SFF->FF_ALIQ
			Else
				xRet:=nAliq 
			EndIf  			
		Case cCalculo=="V"
			nBase:=MaFisRet(nItem,"IT_BASEIV"+aInfo[2]) 
			nAliq:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[2])
			
			xRet:= (nBase * (nAliq/100))
	EndCase  
	SFC->(DbSetOrder(nOrdSFC))
	SFC->(DbGoto(nRegSFC))
	
EndIf
RestArea(aArea)

Return(xRet) 
