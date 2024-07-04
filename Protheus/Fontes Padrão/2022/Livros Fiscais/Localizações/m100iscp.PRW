#include "SIGAWIN.CH"
#DEFINE X_IMPOSTO    01 //Nome do imposto
#DEFINE X_NUMIMP     02 //Sufixo do imposto

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M100ISCP ºAutor  ³FELIPE V. NAMBARA   º Data ³ 23/10/2009  º±/±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calcula Imposto ISC para Peru NF Entrada                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³SigaFis - Localizacao Peru                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±± 
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function M100ISCP(cCalculo,nItem,aInfo)

Local aImp 			:= {}
Local aItem 		:= {}                                                        
Local aArea			:= GetArea()
Local aImpRef 		:= {}
Local aImpVal 		:= {}

Local cImp			:= ""
Local cTes   		:= ""
Local cProd			:= ""
Local cImpIncid		:= ""

Local nOrdSFC   	:= 0    
Local nRegSFC   	:= 0
Local nImp   		:= 0
Local nBase			:= 0
Local nAliq 		:= 0
Local nDecs 		:= 0  
Local nPos	 		:= 0
Local nI			:= 0
Local nE			:= 0
Local lXFis			:= .F.
Local xRet                                             
Local nlAliqX       := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Identifica se a chamada da funcao do calculo do imposto esta sendo ³
//³feita pela matxfis ou pelas rotinas manuais do localizado.         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lXFis := (MafisFound() .And. ProcName(1)!="EXECBLOCK")

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Observacao :                                                                  ³
³                                                                               ³
³ A variavel ParamIxb tem como conteudo um Array[2], contendo :                 ³
³ [1,1] > Quantidade Vendida                                                    ³
³ [1,2] > Preco Unitario                                                        ³
³ [1,3] > Valor Total do Item, com Descontos etc...                             ³
³ [1,4] > Valor do Frete rateado para este Item                                 ³
³         Para Portugal, o imposto do frete e calculado em separado do item     ³
³ [1,5] > Valor das Despesas rateado para este Item                             ³
³         Para Portugal, o imposto das despesas e calculado em separado do item ³
³ [1,6] > Array Contendo os Impostos já calculados, no caso de incidência de    ³
³         outros impostos.                                                      ³
³ [2,1] > Array aImposto, contendo as Informações do Imposto que será calculado.³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
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
   cImpIncid	:= ""
Endif           
               

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica a base de calculo do imposto e se ha o cadastro de impostos incidentes nesta base de calculo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lXFis 	 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Base de calculo composta pelo valor da mercadoria + frete + seguro  ³
	//³Observacao Importante: em Angola nao ha a figura de frete e seguro, ³
	//³porem o sistema deve estar preparado para utilizar esses valores no ³
	//³calculo do imposto.                                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nBase := aItem[3]+aItem[4]+aItem[5] 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Reduz os descontos concedidos da base de calculo³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Subs(aImp[5],4,1) == "S" .And. Len(aImp) >= 18 .And. ValType(aImp[18]) == "N"
		nBase -= aImp[18]
	Endif                                              

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Soma na base de calculo todos os demais impostos incidentes.        ³
	//³Observacao Importante: em Angola nao existem impostos que incidem um³
	//³sobre o outro, porem o sistema deve estar preparado para utilizar   ³
	//³esses valores no calculo do imposto.                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nI := At(cImpIncid,";" )
	nI := If(nI==0,Len(AllTrim(cImpIncid))+1,nI)
	While nI>1
		nE := AScan(aItem[6],{|x| x[1]==Left(cImpIncid,nI-1)})
		If nE > 0
			nBase += aItem[6,nE,4]
		Endif
		cImpIncid := Stuff(cImpIncid,1,nI,"")
		nI := At(cImpIncid,";")
		nI := If(nI==0,Len(AllTrim(cImpIncid))+1,nI)
	Enddo

Else 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Somente efetua esse processamento se a chamada da funcao estiver sendo        ³
	//³feita para montagem da base de calculo do imposto. Como a matxfis chama       ³
	//³sempre 3 vezes as funcoes de impostos, esse filtro eh importante para diminuir³
	//³a lentidao do processamento.                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cCalculo == "B" .Or. cCalculo == "V"  
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Base de calculo composta pelo valor da mercadoria + frete + seguro  ³
		//³Observacao Importante: em Angola nao ha a figura de frete e seguro, ³
		//³porem o sistema deve estar preparado para utilizar esses valores no ³
		//³calculo do imposto.                                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                        
		
		If FunName() $ "MATA121" 
			If cTpFrete == "C-CIF"
				nBase:=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
			Else
				nBase:=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
			EndIf
		Else
			nBase:=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
		EndIf		
						
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Efetua o desconto tambem nos impostos incidentes³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nOrdSFC := (SFC->(IndexOrd()))
		nRegSFC := (SFC->(Recno()))	
		SFC->(DbSetOrder(2))
		If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+cImp)))
			cImpIncid := Alltrim(SFC->FC_INCIMP)
			If SFC->FC_LIQUIDO == "S"
				nBase -= If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
				If	SF1->(FieldPos("F1_ADIANT")) > 0 
					nBase -= If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_ADIANTTOT"),MaFisRet(nItem,"IT_ADIANTTOT"))
				EndIf	
				
			Endif   
		Endif   
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Soma na base de calculo todos os demais impostos incidentes.        ³
		//³Observacao Importante: em Angola nao existem impostos que incidem um³
		//³sobre o outro, porem o sistema deve estar preparado para utilizar   ³
		//³esses valores no calculo do imposto.                                ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SFC->(DbSetOrder(nOrdSFC))
		SFC->(DbGoto(nRegSFC))
		If !Empty(cImpIncid)
			aImpRef:=MaFisRet(nItem,"IT_DESCIV")
			aImpVal:=MaFisRet(nItem,"IT_VALIMP")
			For nI:=1 to Len(aImpRef)
				If !Empty(aImpRef[nI])
					If Trim(aImpRef[nI][1])$cImpIncid
						nBase += aImpVal[nI]
					Endif
				Endif
			Next
		Endif 
		
	Endif

Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica os decimais da moeda para arredondamento do valor  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nDecs := IIf(Type("nMoedaNf") # "U",MsDecimais(nMoedaNf),MsDecimais(1))
                     
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Incio de cálculo do imposto ISC para entrada  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
                                                
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abaixo é a condição caso o imposto seja calculado para notas fiscais ³
//³ de saida com pedido de venda                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If !lXFis

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se houver alguma exceção fiscal o valor da aliquota por uni-  ³ 
	//³ dade é utilizado para cálcularo imposto e o valor da aliquota ³
	//³ fica zerada		                                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    
	
	DbSelectArea("SFF")
	DbSetOrder(3)
	If DbSeek(xFilial("SFF")+aImp[1])
	    If SFF->FF_VLRISC > 0
			nlAliqX := SFF->FF_VLRISC 
			
			aImp[2] := 0
			aImp[3] := aItem[3]+aItem[4]+aItem[5]
			aImp[4] := aItem[1]*nlAliqX
			
			xRet:=aImp						
		EndIf		                
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso não haja nenhuma exceção fiscal é verificado se há valor ³
	//³ no campo B1_VLRISC. Se houver o cálculo é feito por unidade   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
	If nlAliqX <= 0 .And. SB1->B1_VLRISC > 0
		nlAliqX := SB1->B1_VLRISC  
	
		aImp[2] := 0
		aImp[3] := aItem[3]+aItem[4]+aItem[5]
		aImp[4] := aItem[1]*nlAliqX		

		xRet:=aImp 
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso não haja nenhuma exceção fiscal e o valor do campo     ³ 
	//³ B1_VLRISC esteja zerado, é verificado se o vampo B1_ALQISC  ³
	//³ possui valor. Se houver, o imposto é calculado por taxa uti-³
	//³ lizando a aliquota do campo B1_VLRISC	                    ³ 
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If nlAliqX <= 0 .And. SB1->B1_ALQISC > 0
			nlAliqX := SB1->B1_ALQISC
			nBase:=aItem[3]+aItem[4]+aItem[5]  //valor total + frete + outros impostos
	
			aImp[02]:=nlAliqX
			aImp[03]:=nBase
	
			If Subs(aImp[5],4,1) == "S" .And. Len(aImp) >= 18 .And. ValType(aImp[18])=="N"
				aImp[3]	-=aImp[18]
			Endif
			
			aImp[4] := Round(aImp[3]*aImp[2]/100,2)
			xRet:=aImp				
	EndIf
			

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso não haja nenhuma exceção fisca, o valor do campo       ³ 
	//³ B1_VLRISC esteja zerado e o valor do campo B1_ALQISC esteja ³
	//³ zerado o imposto é calculado pela taxa utilizando como ali- ³ 
	//³ quota o valor do campo FB_ALIQ (Aliquota padrão) 	        ³ 
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			

				
	If nlAliqX <= 0 
		DbSelectArea("SFB")
		DbSetOrder(1)		
		If SFB->(Dbseek(xfilial()+aImp[1]))
			nlAliqX := SFB->FB_ALIQ
			nBase:=aItem[3]+aItem[4]+aItem[5]  //valor total + frete + outros impostos
	
			aImp[02]:=nlAliqX
			aImp[03]:=nBase
			
			If Subs(aImp[5],4,1) == "S" .And. Len(aImp) >= 18 .And. ValType(aImp[18])=="N"
				aImp[3]	-=aImp[18]
			Endif                                                                         
			
			aImp[4] := Round(aImp[3]*aImp[2]/100,2)
			xRet:=aImp						
		EndIf
	EndIf
               
Else 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Abaixo é a condição caso o imposto seja calculado para notas fiscais ³
	//³ de saida manual e notas de deb/créd.                                 ³  
	//³ O cálculo do imposto respeita a mesma regra utilizada acima          ³	
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	Do Case

		Case cCalculo=="B"
 					
			xRet := nBase

		Case cCalculo=="A"

			DbSelectArea("SFF")
			DbSetOrder(3)
			If DbSeek(xFilial("SFF")+cImp)
			    If SFF->FF_VLRISC > 0
					nlAliqX := SFF->FF_VLRISC
					xRet    := 0
				EndIf
			EndIf
			
			If nlAliqX <= 0 
				DbSelectArea("SB1")
				DbSetOrder(1)
				If DbSeek(xFilial("SB1")+cProd)
					If SB1->B1_VLRISC > 0
						nlAliqX := SB1->B1_VLRISC
						xRet    := 0
					EndIf
				EndIf	  
			EndIf
			
			If nlAliqX <= 0 .And. SB1->B1_ALQISC > 0
				nlAliqX := SB1->B1_ALQISC
				xRet    := nlAliqX
			EndIf
			
			If nlAliqX <= 0
				DbSelectArea("SFB")
				DbSetOrder(1)
				If Dbseek(xfilial()+cImp)
					nlAliqX := SFB->FB_ALIQ
					xRet    := nlAliqX
				EndIf
			EndIf
			
       Case cCalculo=="V"

			DbSelectArea("SFF")
			DbSetOrder(3)
			If DbSeek(xFilial("SFF")+cImp)
			    If SFF->FF_VLRISC > 0
					nlAliqX := SFF->FF_VLRISC
					xRet := Round(SFF->FF_VLRISC*MaFisRet(nItem,"IT_QUANT"),2)
				EndIf
			EndIf
							
			If nlAliqX <= 0
				DbSelectArea("SB1")
				DbSetOrder(1)
				If DbSeek(xFilial("SB1")+cProd)
					If SB1->B1_VLRISC > 0
						nlAliqX := SB1->B1_VLRISC
						xRet := Round(SB1->B1_VLRISC*MaFisRet(nItem,"IT_QUANT"),2)
					EndIf
				EndIf					
			EndIf
					
			If nlAliqX <= 0 .And. SB1->B1_ALQISC > 0
				nlAliqX := SB1->B1_ALQISC
				nBase:=MaFisRet(nItem,"IT_BASEIV"+aInfo[X_NUMIMP])
				nAliq:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[X_NUMIMP])
            	            
				xRet := Round((( nAliq * nBase) /100 ),2)
			EndIf
			
			If nlAliqX <= 0 
				DbSelectArea("SFB")
				DbSetOrder(1)		
				If SFB->(Dbseek(xfilial()+cImp))
					nlAliqX := SFB->FB_ALIQ
					
					nBase:=MaFisRet(nItem,"IT_BASEIV"+aInfo[X_NUMIMP])
					nAliq:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[X_NUMIMP])
	            	            
					xRet := Round((( nAliq * nBase) /100 ),2)										
				EndIf
			EndIf   
	EndCase   

Endif

RestArea(aArea)

Return(xRet)  