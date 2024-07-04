#include "SIGAWIN.CH"

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁM100SELO  ╨Autor  ЁFelipe V. Nambara   ╨ Data Ё 27/08/2009  ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     ЁCalcula do Imposto de Selo para Angola                      ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       ЁSigaFis - Localizacao Angola                                ╨╠╠
╠╠                                                                        ╨╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠           
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function M100SELO(cCalculo,nItem,aInfo)

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
Local nDecAlq    	:= 0.00
Local nDecBase   	:= 0.00
Local nArreBase  	:= 0.00
Local nArreAlq	 	:= 0.00  

Local lAliqSel   	:= .F. 
Local lArredBase	:= GetNewPar("MV_ARBSSEL",.T.) 
Local lArredSelo 	:= GetNewPar("MV_ARVLSEL",.T.) 
Local lXFis			:= .F.

Local xRet                                             

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁIdentifica se a chamada da funcao do calculo do imposto esta sendo Ё
//Ёfeita pela matxfis ou pelas rotinas manuais do localizado.         Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
lXFis := (MafisFound() .And. ProcName(1)!="EXECBLOCK")

/*
зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
Ё Observacao :                                                                  Ё
Ё                                                                               Ё
Ё A variavel ParamIxb tem como conteudo um Array[2], contendo :                 Ё
Ё [1,1] > Quantidade Vendida                                                    Ё
Ё [1,2] > Preco Unitario                                                        Ё
Ё [1,3] > Valor Total do Item, com Descontos etc...                             Ё
Ё [1,4] > Valor do Frete rateado para este Item                                 Ё
Ё         Para Portugal, o imposto do frete e calculado em separado do item     Ё
Ё [1,5] > Valor das Despesas rateado para este Item                             Ё
Ё         Para Portugal, o imposto das despesas e calculado em separado do item Ё
Ё [1,6] > Array Contendo os Impostos jА calculados, no caso de incidЙncia de    Ё
Ё         outros impostos.                                                      Ё
Ё [2,1] > Array aImposto, contendo as InformaГУes do Imposto que serА calculado.Ё
юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
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
               
//зддддддддддддддддддддддддддддддддддддддддддддд©
//ЁVerificando o cadastro do produto movimentadoЁ
//юддддддддддддддддддддддддддддддддддддддддддддды
//Frontloja usa o arquivo SBI para cadastro de produtos
If cModulo == "FRT" 
	SBI->(DbSeek(xFilial("SBI")+cProd))
	lAliqSel	:= IF(!EMPTY(SBI->BI_ALQSEL),.T.,.F.)
	nAliq 		:= SBI->BI_ALQSEL
Else   
	SB1->(DbSeek(xFilial("SB1")+cProd))
	lAliqSel	:= IF(!EMPTY(SB1->B1_ALQSEL),.T.,.F.)
	nAliq 		:= SB1->B1_ALQSEL
Endif    

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁBusca a aliquota do Cadastro Impostos Variaveis quando nao tiver no Cad. Produto = B1_ALIQSEL Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lAliqSel
   	DbSelectArea("SFB")    
   	SFB->(DbSetOrder(1))                
   	If SFB->(Dbseek(xFilial("SFB")+cImp))
		nAliq := SFB->FB_ALIQ
	Endif
Endif	

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁVerifica a base de calculo do imposto e se ha o cadastro de impostos incidentes nesta base de calculoЁ
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lXFis 	 
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁBase de calculo composta pelo valor da mercadoria + frete + seguro  Ё
	//ЁObservacao Importante: em Angola nao ha a figura de frete e seguro, Ё
	//Ёporem o sistema deve estar preparado para utilizar esses valores no Ё
	//Ёcalculo do imposto.                                                 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	nBase := aItem[3]+aItem[4]+aItem[5] 

	//здддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁReduz os descontos concedidos da base de calculoЁ
	//юдддддддддддддддддддддддддддддддддддддддддддддддды
	If Subs(aImp[5],4,1) == "S" .And. Len(aImp) >= 18 .And. ValType(aImp[18]) == "N"
		nBase -= aImp[18]
	Endif                                              

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁSoma na base de calculo todos os demais impostos incidentes.        Ё
	//ЁObservacao Importante: em Angola nao existem impostos que incidem umЁ
	//Ёsobre o outro, porem o sistema deve estar preparado para utilizar   Ё
	//Ёesses valores no calculo do imposto.                                Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
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

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁSomente efetua esse processamento se a chamada da funcao estiver sendo        Ё
	//Ёfeita para montagem da base de calculo do imposto. Como a matxfis chama       Ё
	//Ёsempre 3 vezes as funcoes de impostos, esse filtro eh importante para diminuirЁ
	//Ёa lentidao do processamento.                                                  Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If cCalculo == "B" .Or. cCalculo == "V"  // Necessita entrar aqui para calcular a base quando for V, pois por algum 
										     // motivo ele nЦo carrega o valor da base para calcular o valor do imposto (cCalculo == "V").
										     // No caso do imposto de Consumo e empreitada ele carrega.
	
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁBase de calculo composta pelo valor da mercadoria + frete + seguro  Ё
		//ЁObservacao Importante: em Angola nao ha a figura de frete e seguro, Ё
		//Ёporem o sistema deve estar preparado para utilizar esses valores no Ё
		//Ёcalculo do imposto.                                                 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		nBase:=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
				
		//здддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁReduz os descontos concedidos da base de calculoЁ
		//юдддддддддддддддддддддддддддддддддддддддддддддддды
		If GetNewPar('MV_DESCSAI','1')=='1' 
			nBase	+= MaFisRet(nItem,"IT_DESCONTO")
		Endif
	
		//здддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁEfetua o desconto tambem nos impostos incidentesЁ
		//юдддддддддддддддддддддддддддддддддддддддддддддддды
		nOrdSFC := (SFC->(IndexOrd()))
		nRegSFC := (SFC->(Recno()))	
		SFC->(DbSetOrder(2))
		If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+cImp)))
			cImpIncid := Alltrim(SFC->FC_INCIMP)
			If SFC->FC_LIQUIDO == "S"
				nBase -= If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
			Endif   
		Endif   
	
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁSoma na base de calculo todos os demais impostos incidentes.        Ё
		//ЁObservacao Importante: em Angola nao existem impostos que incidem umЁ
		//Ёsobre o outro, porem o sistema deve estar preparado para utilizar   Ё
		//Ёesses valores no calculo do imposto.                                Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
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

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁVerifica os decimais da moeda para arredondamento do valor  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nDecs := IIf(Type("nMoedaNf") # "U",MsDecimais(nMoedaNf),MsDecimais(1))

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁEfetua o calculo do imposto com base na base de calculo encontradaЁ
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lXFis
       
	//зддддддддддддддддддддддддддддддддддддддддддд©
	//ЁPega Decimais da Base de Calculo do ImpostoЁ
	//юддддддддддддддддддддддддддддддддддддддддддды  
	nBase := Round(nBase,2)
	nDecBase := (nBase - int(nBase))   
	nArreBase := IF(nDecBase >= 0.01, 1.0, 0.0)    
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//ЁArredonda a Base de Calculo de Imposto, caso o parБmetro MV_ARBSSEL seja .T..Ё
	//юдддддддддддддддддддддддддддддддддддддддддддюдддддддддддддддддддддддддддддддддд
    If lArredBase
		nBase    := Int(nBase) + nArreBase
	EndIf
	
	aImp[03] := nBase		    
      
	//зддддддддддддддддддддддддддддддддддддддд©
	//ЁCalcula Imposto com a Base Arredondada Ё
	//юддддддддддддддддддддддддддддддддддддддды
	nImp := Round( ((nAliq * nBase) /100 ),2)
   
	//здддддддддддддддддддддддддддддддддд©
	//ЁPega Decimais do Valor do Imposto Ё
	//юдддддддддддддддддддддддддддддддддды
	nDecAlq  	:= (nImp - int(nImp))
	nArreAlq  	:= IF(nDecAlq >= 0.01, 1.0, 0.0) 
                                                                           

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//ЁArredonda o Valor do Imposto, caso o parБmetro MV_ARVLSEL seja .T..Ё
	//юдддддддддддддддддддддддддддддддддддддддддддюдддддддддддддддддддддддд	
	If lArredSelo   
		nImp := Int(nImp) + nArreAlq	   
	EndIf
		
	aImp[02] 	:= nAliq
	aImp[04] 	:= nImp                   
	xRet 		:= aImp

Else 

	//зддддддддддддддддддддддддддддддддддддддддддд©
	//ЁPega Decimais da Base de Calculo do ImpostoЁ
	//юддддддддддддддддддддддддддддддддддддддддддды   
	nBase := Round(nBase,2)
    nDecBase := (nBase - int(nBase))   
    nArreBase := IF(nDecBase >= 0.01, 1.0, 0.0)
            
            
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//ЁArredonda a Base de Calculo de Imposto, caso o parБmetro MV_ARBSSEL seja .T..Ё
	//юдддддддддддддддддддддддддддддддддддддддддддюдддддддддддддддддддддддддддддддддд
    If lArredBase
	    nBase    := Int(nBase) + nArreBase                                                            
	EndIf

    Do Case
		//зддддддддддддддддддддддддддддддддддддддддддд©
		//ЁPara verificar a base de calculo do impostoЁ
		//юддддддддддддддддддддддддддддддддддддддддддды
		Case cCalculo == "B"
            


			//здддддддддддддддддддддддддддддддддддд©
			//ЁRetorna a base de calculo do impostoЁ
			//юдддддддддддддддддддддддддддддддддддды
            xRet := nBase                         
            
		//зддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁPara verificar a aliquota de calculo do impostoЁ
		//юддддддддддддддддддддддддддддддддддддддддддддддды
		Case cCalculo == "A"
       
            xRet := nALiq
       
		//зддддддддддддддддддддддд©
		//ЁPara calcular o impostoЁ
		//юддддддддддддддддддддддды
		Case cCalculo == "V"

			//здддддддддддддддддддддддддддддддддддддд©
			//ЁCalcula Imposto com a Base ArredondadaЁ
			//юдддддддддддддддддддддддддддддддддддддды
			nImp    := Round((( nAliq * nBase) /100 ),2)
				        
			//зддддддддддддддддддддддддддддддддд©
			//ЁPega Decimais do Valor do ImpostoЁ
			//юддддддддддддддддддддддддддддддддды
		    nDecAlq		:= (nImp - int(nImp))
		    nArreAlq	:= IF(nDecAlq >= 0.01, 1.0, 0.0) 
	        
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//ЁArredonda o Valor do Imposto, caso o parБmetro MV_ARVLSEL seja .T..Ё
			//юдддддддддддддддддддддддддддддддддддддддддддюдддддддддддддддддддддддд	
			If lArredSelo   
			    nImp    := Int(nImp) + nArreAlq	   
			EndIF

			//здддддддддддддддддддддддддд©
			//ЁRetorna o valor do impostoЁ
			//юдддддддддддддддддддддддддды
	        xRet 	:= nImp

    EndCase   

Endif                   

RestArea(aArea)

Return(xRet)