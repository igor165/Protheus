#INCLUDE "Protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M460GST  ³ Autor ³ Luciana Pires³ Data ³ 08.09.11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Calculo do imposto GST (destacado) nas notas de saída para Austrália                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Austrália                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
³         será calculado  (funcao a460TexXIp -> fonte LOCXFUN.prx).                                       ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verificando o cadastro do produto movimentado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Frontloja usa o arquivo SBI para cadastro de produtos
If cModulo == "FRT" 
	SBI->(DbSeek(xFilial("SBI")+cProd))
Else   
	SB1->(DbSeek(xFilial("SB1")+cProd))
Endif    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca a aliquota padrao para o imposto ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SFB")    
SFB->(DbSetOrder(1))
If SFB->(Dbseek(xFilial("SFB")+cImp))
	nAliq := SFB->FB_ALIQ
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica os decimais da moeda para arredondamento do valor  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nDecs := IIf(Type("nMoedaNf") # "U",MsDecimais(nMoedaNf),MsDecimais(1))

If !lXFis
	If cGSTReg <> "3" 
		aImp[02] := nAliq
		aImp[03] := aItem[03]+aItem[04]+aItem[05]

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Reduz os descontos, quando a configuração indica calculo pelo liquido.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Subs(aImp[05],4,1) == "S" .And. Len(aImp) >= 18 .And. ValType(aImp[18])=="N"
			aImp[03]	-= aImp[18]
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Soma na Base de Cálculo os Impostos Incidentes            
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nI := aScan( aItem[6],{|x| x[1] == AllTrim(cIncImp) } )
		If nI > 0
			aImp[03] += aItem[6,nI,4]
		Endif
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Efetua o Calculo do Imposto quando o campo no produto (B1_NCGST) estiver definido como "1"³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (SB1->(FieldPos("B1_INCGST")) > 0 .And. SB1->B1_INCGST == "1")				
			aImp[04] 	:= Round(aImp[03] * (aImp[02]/100),nDecs)
		Else	   
			// Neste caso o GST é free, ou seja, gravo somente a base de cálculo, por isso zero a alíquota e o valor do imposto.
			aImp[02] := 0
			aImp[04] := 0			              
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Retorna um array com base [3], aliquota [2] e valor [4]³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		xRet:=aImp   
	Else
	
		// Neste caso o GST não é calculado, pois o parâmetro MV_GSTREG está definido como "3"
		aImp[02] := 0
		aImp[03] := 0			
		aImp[04] := 0			              

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Retorna um array com base [3], aliquota [2] e valor [4]³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		xRet:=aImp   

	Endif
Else
	If cGSTReg <> "3" 		
		nBase:=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Reduz os descontos, quando a configuração indica calculo pelo liquido.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Soma a Base de Cálculo os Impostos Incidentes                 
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Efetua o Calculo do Imposto quando o campo no produto (B1_NCGST) estiver definido como "1"³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (SB1->(FieldPos("B1_INCGST")) > 0 .And. SB1->B1_INCGST == "1")				
			nImp		:= Round(nBase *(nAliq/100),nDecs)
		Else	   
			// Neste caso o GST é free, ou seja, gravo somente a base de cálculo, por isso zero a alíquota e o valor do imposto.
			nALiq := 0
			nImp	 := 0			              
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
	Else
		// Neste caso o GST não é calculado -> MV_GSTREG = "3"
		nALiq 	:= 0
		nImp	 	:= 0			              
		nBase	:= 0	
	
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
