#include "SIGAWIN.CH"

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁM460EMP  ╨Autor  ЁRicardo Borges      ╨ Data Ё 25/06/2009  ╨╠/╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     ЁCalcula Imposto de Empreitada para Angola                   ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       ЁSigaFis - Localizacao Angola                                ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function M460EMP(cCalculo,nItem,aInfo) 

Local aImp 		:= {}
Local aItem 	:= {}
Local aArea		:= GetArea()
Local aImpRef 	:= {}
Local aImpVal 	:= {}

Local cImp		:= ""
Local cTes   	:= ""
Local cRegiao	:= ""
Local cGrupo	:= ""                      
Local cProd		:= ""
Local cImpIncid	:= ""

Local nOrdSFC   := 0    
Local nRegSFC   := 0
Local nImp   	:= 0
Local nBase		:= 0
Local nAliq 	:= 0
Local nDecs 	:= 0  
Local nPos	 	:= 0
Local nI		:= 0
Local nE		:= 0

Local lIsento	:= .F.
Local lImpDep	:= .F.
Local lCalcLiq	:= .F.
Local lAliqEmp   := .F. 
Local lArredBase := GetNewPar("MV_ARBSEMP",.T.) 
Local lArredEmp  := GetNewPar("MV_ARVLEMP",.T.) 
Local nDecAlq    := 0.00
Local nDecBase   := 0.00	
Local nPerEmp 	 := 0.00
Local nArreBase  := 0.00
Local nArreImp	 := 0.00  
Local cGrpAces	:= GetNewPar("MV_GRPACES","FR=004;SE=005;DT=006;DN=007;TA=008")
Local cImpDesp	:= "IFD|IDD|ISD|ITD"
Local xRet                  
Local lXFis		:= .F.

lXFis:=(MafisFound() .And. ProcName(1)!="EXECBLOCK")
                               

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
               
//зддддддддддддддддддддддддддддLддддддддддддддддд©
//ЁVerificando o cadastro do produto movimentadoЁ
//юддддддддддддддддддддддддддддддддддддддддддддды
//Frontloja usa o arquivo SBI para cadastro de produtos
If cModulo == "FRT" 
	SBI->(DbSeek(xFilial("SBI")+cProd))
Else   
	SB1->(DbSeek(xFilial("SB1")+cProd))
	lAliqEmp:=IF(!EMPTY(SB1->B1_ALQEMP),.T.,.F.)
	nAliq := SB1->B1_ALQEMP
Endif    
    
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁBusca a aliquota do Cadastro Impostos Variaveis quando nao tiver no Cad. Produto = B1_ALQCON Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If !lAliqEmp
	   	DbSelectArea("SFB")    
	   	SFB->(DbSetOrder(1))                
	   	If SFB->(Dbseek(xFilial("SFB")+cImp))
			nAliq := SFB->FB_ALIQ
		Endif
	Endif	
	
	If !lXFis 

		nBase := aItem[3] 
		cImpIncid:= aImp[10]


	Else           

		nBase := MaFisRet(nItem,"IT_VALMERC")
		If GetNewPar('MV_DESCSAI','1')=='1' 
			//зддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//ЁSomente quando for IVA de mercadorias aplica o descontoЁ
			//юддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			nBase += MaFisRet(nItem,"IT_DESCONTO")
		Endif
		cImpIncid:=""
	Endif

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁVerifica os decimais da moeda para arredondamento do valor  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nDecs := IIf(Type("nMoedaNf") # "U",MsDecimais(nMoedaNf),MsDecimais(1))

//здддддддддддддддддддддддддддддддддддддддддддддд©
//ЁVerifica os descontos e os impostos incidentesЁ
//юдддддддддддддддддддддддддддддддддддддддддддддды
If !lXFis

	//здддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁSoma a Base de Calculo os Impostos Incidentes Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддды
	nI := At(cImpIncid,";" )
	nI := Iif(nI==0,Len(AllTrim(cImpIncid))+1,nI)
	While nI > 1
		nE := AScan(aItem[6],{|x| x[1]==Left(cImpIncid,nI-1)})
		If nE > 0
			nBase += aItem[6,nE,4]
		Endif
		cImpIncid := Stuff(cImpIncid,1,nI,"")
		nI := At(cImpIncid,";")
		nI := Iif(nI==0,Len(AllTrim(cImpIncid))+1,nI)
	Enddo

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁReduz os descontos, quando a configuraГЦo indica calculo pelo liquido.Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If Subs(aImp[5],4,1) == "S" .And. Len(aImp) >= 18 .And. ValType(aImp[18])=="N"
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁSomente quando for IVA de mercadorias aplica o descontoЁ
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If !(cImp $ cImpDesp)
			nBase -= aImp[18]
		Endif
	Endif

Else
           
	If cCalculo == "B"
		//зддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁSomente quando for IVA de mercadorias aplica o descontoЁ
		//юддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If !(cImp $ cImpDesp)
			nOrdSFC := (SFC->(IndexOrd()))
			nRegSFC := (SFC->(Recno()))
			SFC->(DbSetOrder(2))
			If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+cImp)))
				cImpIncid := Alltrim(SFC->FC_INCIMP)
				If SFC->FC_LIQUIDO == "S"
					nBase -= If(SFC->FC_CALCULO=="T",MaFisRet(nItem,"NF_DESCONTO"),MaFisRet(nItem,"IT_DESCONTO"))
				Endif   
			Endif   
			SFC->(DbSetOrder(nOrdSFC))
			SFC->(DbGoto(nRegSFC))
		Endif
		
		//здддддддддддддддддддддддддддддддддддддддддддддд©
		//ЁSoma a Base de Calculo os Impostos Incidentes Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддды
		If !Empty(cImpIncid)
			aImpRef := MaFisRet(nItem,"IT_DESCIV")
			aImpVal := MaFisRet(nItem,"IT_VALIMP")
			For nI := 1 to Len(aImpRef)
				If !Empty(aImpRef[nI])
					If Trim(aImpRef[nI][1]) $ cImpIncid
						nBase += aImpVal[nI]
					Endif
				Endif
			Next
		Endif
	Endif
Endif

If !lXFis                
    
   //здддддддддддддддддддддддддддддддддддддддддддддддд©
   //ЁPega Percentual para Base de Calculo do Imposto Ё
   //здддддддддддддддддддддддддддддддддддддддддддддддд©   
   aArea:=GetArea()
   DbSelectArea("SF4")    
   SF4->(DbSetOrder(1))                
   If SF4->(Dbseek(xFilial("SF4")+cTes))
      nPerEmp := SF4->F4_PERCEMP   
   Endif   
   RestArea(aArea)

   //здддддддддддддддддддддддддддддддддддддддддддддддд©
   //ЁAplica Percentual na Base de Calculo do Imposto Ё
   //здддддддддддддддддддддддддддддддддддддддддддддддд©
   nBase	:= Round(( nBase * ( nPerEmp / 100) ),2)

   //зддддддддддддддддддддддддддддддддддддддддддддд©
   //ЁPega Decimais da Base de Calculo do Imposto  Ё
   //зддддддддддддддддддддддддддддддддддддддддддддд©   
   nDecBase := (nBase - int(nBase))
   nArreBase := IF(nDecBase >= 0.01, 1.0, 0.0)

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//ЁArredonda a Base de Calculo de Imposto, caso o parБmetro MV_ARBSEMP seja .T..Ё
	//юдддддддддддддддддддддддддддддддддддддддддддюдддддддддддддддддддддддддддддддддд
	If lArredBase
		nBase := int(nBase) + nArreBase
	EndIf
      
   aImp[03] := nBase
   
   aImp[04] := Round((( nAliq * nBase) /100 ),2)

	nImp := aImp[04]
	
   //зддддддддддддддддддддддддддддддддддд©
   //ЁPega Decimais do Valor do Imposto  Ё
   //здддддддддддддддддддддддддддддддддддд©   
   nDecAlq  := (nImp - int(nImp))
   nArreImp := IF(nDecAlq >= 0.01, 1.0, 0.0)
     
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//ЁArredonda o Valor do Imposto, caso o parБmetro MV_ARVLEMP seja .T..Ё
	//юдддддддддддддддддддддддддддддддддддддддддддюдддддддддддддддддддддддд	
	If lArredEmp
		aImp[04] := int(nImp) + nArreImp
	EndIf
	
    aImp[02] := nAliq
 
   xRet := aImp     
   
Else 

   //здддддддддддддддддддддддддддддддддддддддддддддддд©
   //ЁPega Percentual para Base de Calculo do Imposto Ё
   //здддддддддддддддддддддддддддддддддддддддддддддддд©   
   aArea:=GetArea()
   DbSelectArea("SF4")    
   SF4->(DbSetOrder(1))                
   If SF4->(Dbseek(xFilial("SF4")+cTes))
      nPerEmp := SF4->F4_PERCEMP   
   Endif   
   RestArea(aArea)

   //здддддддддддддддддддддддддддддддддддддддддддддддд©
   //ЁAplica Percentual na Base de Calculo do Imposto Ё
   //здддддддддддддддддддддддддддддддддддддддддддддддд©
   nBase	:= Round(( nBase * ( nPerEmp / 100)),2)
   
   //зддддддддддддддддддддддддддддддддддддддддддддд©
   //ЁPega Decimais da Base de Calculo do Imposto  Ё
   //зддддддддддддддддддддддддддддддддддддддддддддд©   
   nDecBase := (nBase - int(nBase))
   nArreBase := IF(nDecBase >= 0.01, 1.0, 0.0)		

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
	//ЁArredonda a Base de Calculo de Imposto, caso o parБmetro MV_ARBSEMP seja .T..Ё
	//юдддддддддддддддддддддддддддддддддддддддддддюдддддддддддддддддддддддддддддддддд
	If lArredBase				   		   
		nBase    := int(nBase) + nArreBase       
	EndIf

    Do Case

       Case cCalculo=="B"            
					
           xRet := nBase

       Case cCalculo=="A"

            xRet := nALiq

       Case cCalculo=="V"
       
		   nImp := Round((( nAliq * nBase) /100 ),2)
   
		   //зддддддддддддддддддддддддддддддддддд©
		   //ЁPega Decimais do Valor do Imposto  Ё
		   //здддддддддддддддддддддддддддддддддддд©   
		   nDecAlq  := ( nImp - int(nImp) )
		   nArreImp := IF(nDecAlq >= 0.01, 1.0, 0.0)
		   
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд
			//ЁArredonda o Valor do Imposto, caso o parБmetro MV_ARVLEMP seja .T..Ё
			//юдддддддддддддддддддддддддддддддддддддддддддюдддддддддддддддддддддддд	
			If lArredEmp
				nImp := int( nImp ) + nArreImp 	       
			EndIf

           xRet := nImp

    EndCase   

Endif                   


Return(xRet)