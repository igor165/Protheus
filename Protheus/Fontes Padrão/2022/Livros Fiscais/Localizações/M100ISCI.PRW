#include "SIGAWIN.CH"
#DEFINE _NOMEIMPOS 01
#DEFINE _ALIQUOTA  02
#DEFINE _BASECALC  03
#DEFINE _IMPUESTO  04
#DEFINE _RATEOFRET 11
#DEFINE _IVAFLETE  12
#DEFINE _RATEODESP 13
#DEFINE _IVAGASTOS 14
#DEFINE _VLRTOTAL  3
#DEFINE _FLETE     4
#DEFINE _GASTOS    5

//Posicoes  do terceiro array recebido nos impostos a traves da matxfis...
#DEFINE X_IMPOSTO    06 //Nome do imposto
#DEFINE X_NUMIMP     07 //Sufixo do imposto

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÕÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¸±±
±±³Funcao    ³                   M100ISCI                ³Data  02/04/2013        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Executa a funcao propria a cada pais para o calculo do ISC - Incuido³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function M100ISCI(cCalculo,nItem,aInfo)
local cFunc
Local aRet

cAliasRot	:= Alias()
cOrdemRot	:= IndexOrd()
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Observacao :                                                  ³
³                                                               ³
³ a variavel ParamIxb tem como conteudo um Array[2], contendo : ³
³ [1,1] > Quantidade Vendida                                    ³
³ [1,2] > Preco Unitario                                        ³
³ [1,3] > Valor Total do Item, com Descontos etc...             ³
³ [1,4] > Valor do Frete Rateado para Este Item ...             ³
³ [1,5] > Array Contendo os Impostos já calculados, no caso de  ³
³         incidência de outros impostos.                        ³
³ [2,1] > Array aImposto, Contendo as Informações do Imposto que³
³         será calculado.                                       ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
cFunc	:="M100isi"+left(cPaisLoc,2)
//cFunc:=cFunc+"()"
//aRet:=&(cFunc)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Identifica se a chamada da funcao do calculo do imposto esta sendo ³
//³feita pela matxfis ou pelas rotinas manuais do localizado.         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lXFis 	:= (MafisFound() .And. ProcName(1)!="EXECBLOCK")
aRet  	:= &(cFunc)(cCalculo,nItem,aInfo,lXFis) //executa a funcao do pais

dbSelectArea( cAliasRot )
dbSetOrder( cOrdemRot )
return(aRet)



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ M100iscPA ³ Autor ³ Marcio Nunes        ³ Data ³ 02.04.2013 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Calculo do ISC - Incluido - Entrada - Paraguai              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cPar01 - Solicitacao da MATXFIS, pondendo ser A (aliquota), ³±±
±±³          ³          B (base), V (valor).                               ³±±
±±³          ³ nPar02 - Item do documento fiscal.                          ³±±
±±³          ³ aPar03 - Array com as informacoes do imposto.               ³±±
±±³          ³ lPar04 - Define se e rotina automaticao ou nao.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ xRet - Retorna o valor solicitado pelo paremetro cPar01     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Paraguai                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function M100isiPA(cCalculo,nItem,aInfo)

Local aImp 		:= {}
Local aItem 	:= {}                                                        
Local aArea		:= GetArea()
Local cImp		:= ""
Local cTes   	:= ""
Local cProd		:= ""
Local cImpIncid	:= ""
Local nOrdSFC   := 0    
Local nRegSFC   := 0
Local nBase		:= 0
Local nAliq 	:= 0
Local xRet                                            
Local nValMerc	:= 0
Local nAliqAg	:= 0 
Local nDecs		:= 0			// Decimais
Local nMoeda	:= 1  

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

		DbSelectArea("SFF")
		SFF->(DbSetOrder(15))
		If SFF->(DbSeek(xFilial("SFF")+cImp+cConcProd)) .And. SFF->FF_ALIQ>0
			nAliq:=SFF->FF_ALIQ
		EndIf 
		If SFF->(DbSeek(xFilial("SFF")+cImpIncid+cConcProd)) .And. SFF->FF_ALIQ>0
			nAliqAg:=SFF->FF_ALIQ
		EndIf
		//Calculo por dentro - Incluido
		aImp[03]:= NoRound((nBase/(1+(nAliqAg/100))/(1+nAliq/100)),nDecs)				
		aImp[04]:= NoRound(aImp[03] * (nAliq/100),nDecs)					   
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
			//¦ Soma a Base de Cálculo os Impostos Incidentes                 ¦
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
			
			xRet:= Round(nBase/(1+(nAliqAg/100))/(1+(nAliq/100)),nDecs)
	
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
			xRet:= NoRound(nBase * (nAliq/100),nDecs)

	EndCase  
		SFC->(DbSetOrder(nOrdSFC))
		SFC->(DbGoto(nRegSFC))
EndIf
RestArea(aArea)

Return(xRet) 
