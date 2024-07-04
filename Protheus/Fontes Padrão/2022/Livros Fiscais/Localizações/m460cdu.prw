#INCLUDE "Protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M460CDU  ³ Autor ³ Luciana Pires³ Data ³ 13.10.11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Calculo do imposto CDU nas notas de saída para Austrália                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Austrália                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
Local nMinCDU	:= SuperGetMV("MV_MINCDU",,1000) //Mínimo Comum
Local nQtdade	:= 0

Local xRet	            

Local lCalcula	:= .T.
Local lxFis			:=	(MafisFound() .And. ProcName(1)!="EXECBLOCK")
// .T. - metodo de calculo utilizando a matxfis
// .F. - metodo antigo de calculo

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Observacao :                                                  ³
³                                                               ³
³ a variavel ParamIxb tem como conteudo um Array[2], contendo : ³
³ [1,1] > Quantidade Vendida                                    ³
³ [1,2] > Preco Unitario                                        ³
³ [1,3] > Valor Total do Item, com Descontos etc...             ³
³ [1,4] > Valor do Frete rateado para este Item ...             ³
³ [1,5] > Valor das Despesas rateado para este Item...          ³
³ [1,6] > Array Contendo os Impostos já calculados, no caso de  ³
³        incidência de outros impostos.                         ³
³ [2,1] > Array aImposto, Contendo as Informações do Imposto que³
³         será calculado (funcao a460TexXIp -> fonte LOCXFUN.prx).                                       ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Dados do cliente/fornecedor
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cModulo$"FAT|LOJA|TMK|FRT"
	cEstado := SA1->A1_EST
Else                                                                                                 
	cEstado := SA2->A2_EST
Endif
                                   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verificando o cadastro do produto movimentado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
                         
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Guardo o conceito do produto³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (SB1->(FieldPos("B1_CONCDU")) > 0 .And. !Empty(SB1->B1_CONCDU))				                                              
	cConcept := SB1->B1_CONCDU
Endif
               
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca a aliquota padrao para o imposto ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SFB")    
SFB->(DbSetOrder(1))
If SFB->(Dbseek(xFilial("SFB")+cImp))
	nAliq := SFB->FB_ALIQ
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca / posiciono a aliquota através da CCR ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("CCR")
CCR->(dbSetOrder(3))	//CCR_FILIAL+CCR_CONCEP+CCR_IMP+CCR_PAIS
If CCR->(dbSeek(xFilial("CCR")+cConcept+cImp))
	If !Empty(CCR->CCR_ALIQ) .Or. !Empty(CCR->CCR_VALOR)
		nAliq 		:= CCR->CCR_ALIQ
		nValFixo 	:= CCR->CCR_VALOR
		cUMCCR	:= CCR->CCR_UNID
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifico se o imposto é free ou não
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nAliq == 0 .And. nValFixo == 0)
	lCalcula := .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica os decimais da moeda para arredondamento do valor  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nDecs := IIf(Type("nMoedaNf") # "U",MsDecimais(nMoedaNf),MsDecimais(1))
        
If Alltrim(cEstado) == "EX"
	If !lXFis
		aImp[02] := nAliq
		aImp[03] := aItem[03]+aItem[04]+aItem[05]
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Reduz os descontos, quando a configuração indica calculo pelo liquido.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Subs(aImp[05],4,1) == "S" .And. Len(aImp) >= 18 .And. ValType(aImp[18])=="N"
			aImp[03]	-= aImp[18]
		Endif
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Efetua o Calculo do Imposto quando a variável lCalcula estiver definida como .T.                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lCalcula
			If nAliq > 0 //a fórmula é pela alíquota
				//Verifico o mínimo
				If nMinCDU < aImp[03]
					aImp[04] 	:= Round(aImp[03] * (aImp[02]/100),nDecs)
				Else 
					aImp[02] := 0
					aImp[03] := 0
					aImp[04] := 0			              			
				Endif
			Else 			//a fórmula é pelo valor fixo
				//Verifico o mínimo
				If nMinCDU < aImp[03]
					If Alltrim(cUMCCR) <> Alltrim(cUMSB1)   // Se a unidade de medida é diferente, eu converto o valor -> formula pela quantidade
						aImp[04] 	:= Round((aItem[01] * nConv) * (nValFixo),nDecs)	                                                             
						aImp[03] 	:= 0 //zero a base de cálculo porque faço o cálculo pela quantidade + valor fixo
						aImp[02]	:= 0
				 	Else
						aImp[04] 	:= Round(aItem[01] * nValFixo,nDecs)		 	
						aImp[03] 	:= 0 //zero a base de cálculo porque faço o cálculo pela quantidade + valor fixo
						aImp[02]	:= 0
				 	Endif
				Else 
					aImp[02] := 0
					aImp[03] := 0
					aImp[04] := 0			              			
				Endif			
			Endif			
		Else	   
			// Neste caso não calculo o CDU 
			aImp[02] := 0
			aImp[03] := 0
			aImp[04] := 0			              
		Endif
	  
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Retorna um array com base [3], aliquota [2] e valor [4]³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		xRet:=aImp   
	Else
		nBase		:=MaFisRet(nItem,"IT_VALMERC")
		nQtdade	:=MaFisRet(nItem,"IT_QUANT")
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Reduz os descontos, quando a configuração indica calculo pelo liquido.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Efetua o Calculo do Imposto quando a variável lCalcula estiver definida como .T.                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lCalcula
			If nAliq > 0 //a fórmula é pela alíquota
				//Verifico o mínimo
				If nMinCDU < nBase
					nImp 	:= Round(nBase * (nAliq/100),nDecs)
				Else 
					nAliq 	:= 0
					nBase 	:= 0
					nImp 	:= 0			              			
				Endif
			Else 			//a fórmula é pelo valor fixo
				//Verifico o mínimo
				If nMinCDU < nBase
					If Alltrim(cUMCCR) <> Alltrim(cUMSB1)   // Se a unidade de medida é diferente, eu converto o valor -> formula pela quantidade
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
			// Neste caso não calculo o CDU 
			nAliq 	:= 0        
			nBase	:= 0
			nImp	 	:= 0			              
		Endif
	  
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Retorna o valor solicitado pela MatxFis (parametro cCalculo):³
		//³A = Aliquota de calculo                                      ³
		//³B = Base de calculo                                          ³
		//³V = Valor do imposto                                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
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
