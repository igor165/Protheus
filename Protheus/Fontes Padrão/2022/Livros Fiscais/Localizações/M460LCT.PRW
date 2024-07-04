#INCLUDE "Protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M460LCT  ³ Autor ³ Luciana Pires³ Data ³ 06.09.11  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Calculo do imposto LCT nas notas de saída para Austrália                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ Austrália                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M460LCT(cCalculo,nItem,aInfo)
Local aImp 		:= {}
Local aItem 		:= {}
Local aArea		:= GetArea()
Local	 aImpRef	:= {}
Local	 aImpAliq	:= {}
Local aImpVal	:= {}

Local cImp			:= ""
Local cProd		:= ""
Local cTipo		:= ""

Local nMinLCT1	:= SuperGetMV("MV_LCTMIN1",,57466) //Mínimo Comum
Local nMinLCT2	:= SuperGetMV("MV_LCTMIN2",,75375)	//Mínimo Baixo consumo
Local nOrdSFC	:= 0
Local nRegSFC	:= 0
Local nImp			:= 0
Local nBase		:= 0
Local nAliq 		:= 0
Local nDecs 		:= 0
Local nAliqGST	:= 0
Local nValGST	:= 0
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
   aItem		:= ParamIxb[1]
   aImp		:= ParamIxb[2]
   cImp		:= aImp[01]
   cProd 	:= SB1->B1_COD
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
	If  (SBI->(FieldPos("BI_TPLCT")) > 0) 
		cTipo := SBI->BI_TPLCT
	Endif
Else   
	SB1->(DbSeek(xFilial("SB1")+cProd))
	If  (SB1->(FieldPos("B1_TPLCT")) > 0) 
		cTipo := SB1->B1_TPLCT
	Endif
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
	aImp[02] := nAliq
	aImp[03] := aItem[03]+aItem[04]+aItem[05]

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Reduz os descontos, quando a configuração indica calculo pelo liquido.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Subs(aImp[05],4,1) == "S" .And. Len(aImp) >= 18 .And. ValType(aImp[18])=="N"
		aImp[03]	-= aImp[18]
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Localiza a alíquota e o valor do GST. 
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPos  := aScan(aItem[6],{|x| SubStr(x[1],1,2) $ "GS" })
	If nPos > 0
		nAliqGST 	:= aItem[6,nPos,2]   	//Aliquota
		nValGST 	:= aItem[6,nPos,4]		//Valor
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se pelo mínimo (e se tiver GST), o LCT deverá ser calculado ou não                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nValGST > 0 .And. cTipo <> "3" 
        If cTipo == "1" .And. aImp[03] > nMinLCT1    								//Tipo Comum
			aImp[03]	-= nMinLCT1															//Tenho que excluir o mínimo da base
			aImp[03]	:= Round(aImp[03] /(1+(nAliqGST/100)),nDecs) 		//Tenho que excluir o GST da base para aplicar a alíquota do LCT				
			aImp[04]	:= Round(aImp[03] * aImp[02]/100,nDecs)
		ElseIf  cTipo == "2" .And. aImp[03] > nMinLCT2   							//Tipo Baixo Consumo
			aImp[03]	-= nMinLCT2															//Tenho que excluir o mínimo da base
			aImp[03]	:= Round(aImp[03] /(1+(nAliqGST/100)),nDecs) 		//Tenho que excluir o GST da base para aplicar a alíquota do LCT				
			aImp[04]	:= Round(aImp[03] * aImp[02]/100,nDecs)					
		Else
			// Se não atingir o mínimo o LCT não é calculado
			aImp[02]	:= 0	//Aliquota
			aImp[03] 	:= 0	//Base
			aImp[04] 	:= 0	//Imposto			              
		Endif
	Else	   
		// Neste caso o LCT não é calculado
		aImp[02]	:= 0	//Aliquota
		aImp[03] 	:= 0	//Base
		aImp[04] 	:= 0	//Imposto			              
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Retorna um array com base [3], aliquota [2] e valor [4]³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	xRet:=aImp   
Else
	nBase:=MaFisRet(nItem,"IT_VALMERC")
	
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

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Localiza a liquota e o valor do imposto do GST            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aImpRef		:= MaFisRet(nItem,"IT_DESCIV")
	aImpAliq	:= MaFisRet(nItem,"IT_ALIQIMP")   
	aImpVal		:= MaFisRet(nItem,"IT_VALIMP")
	For nI:=1 to Len(aImpRef)
		If !Empty(aImpRef[nI])
			If "GS"$Alltrim(aImpRef[nI][1])
				nAliqGST	:= aImpAliq[nI]  
				nValGST	:= aImpVal[nI]
			Endif
		Endif
	Next

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se pelo mínimo (e se tiver GST), o LCT deverá ser calculado ou não                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nValGST > 0 .And. cTipo <> "3"
        If cTipo == "1" .And. nBase > nMinLCT1    							//Tipo Comum
			nBase	-= nMinLCT1														//Tenho que excluir o mínimo da base
			nBase	:= Round(nBase /(1+(nAliqGST/100)),nDecs) 		//Tenho que excluir o GST da base para aplicar a alíquota do LCT				
			nImp		:= Round(nBase * nAliq/100,nDecs)
		ElseIf  cTipo == "2" .And. nBase > nMinLCT2   					//Tipo Baixo Consumo
			nBase	-= nMinLCT2														//Tenho que excluir o mínimo da base
			nBase	:= Round(nBase /(1+(nAliqGST/100)),nDecs) 		//Tenho que excluir o GST da base para aplicar a alíquota do LCT				
			nImp		:= Round(nBase * nAliq/100,nDecs)
		Else
			// Se não atingir o mínimo o LCT não é calculado
			nBase	:= 0
			nALiq 	:= 0
			nImp	 	:= 0
		Endif			              
	Else	   
		// Neste caso o LCT não é calculado
		nBase	:= 0
		nALiq 	:= 0
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

RestArea(aArea)
	
Return(xRet)
