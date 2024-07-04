#INCLUDE "SIGAWIN.CH"

//Posicoes  do terceiro array recebido nos impostos a traves da matxfis...
#DEFINE X_IMPOSTO    1 //Nome do imposto
#DEFINE X_NUMIMP     2 //Sufixo do imposto

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³M460DIG   ¦ Autor ¦ Ivan Haponczuk         ¦ Data ¦ 12.11.09  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Programa que Calcula DIG   (PERU)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³MATA467/MATA468                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.          	    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador³ Data   ³ BOPS ³  Motivo da Alteracao                  	    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³A.Rodriguez³18/06/13³THKMHK³Redondeo a cero decimales cualquier moneda.  ³±±
±±³           ³        ³      ³                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function M100DIG(cCalculo,nItem,aInfo)

Local nDecs     := 0
Local nI	    := 0
Local nBase     := 0
Local cAliasROT := ""
Local cOrdemROT := ""
Local aImpRef   := {}
Local aImpVal   := {}
Local lXFis     := .T.
Local aArea     := GetArea()
Local aAreaSFC	:= SFC->(GetArea())
SetPrvt("AITEMINFO,xRet,CIMPINCID,_ALIQDIG")
SetPrvt("NI,NEE")

lXFis:=(MaFisFound() .And. ProcName(1)<>"EXECBLOCK")
cAliasRot:= Alias()
cOrdemRot:= IndexOrd()
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
³ [2,1] > Array xRet, Contendo as Informações do Imposto que    ³
³         será calculado.                                       ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/

//+---------------------------------------------------------------+
//¦ Caso seja pedido de Venda		         					  ¦
//+---------------------------------------------------------------+	
If !lXFis
	aItemINFO:=ParamIxb[1]
	xRet:=ParamIxb[2]
	cImpIncid:=xRet[10]
Endif 

nMoedaCor := IIf(Type("nMoedaCor")	=="U",1,nMoedaCor)



If Type("M->F1_MOEDA")<>"U" 
	nMoedaCor:= M->F1_MOEDA      
ElseIf Type("M->C7_MOEDA")<>"U"
	nMoedaCor:= M->C7_MOEDA    
ElseIf Type("M->F2_MOEDA")<>"U" 
	nMoedaCor:= M->F2_MOEDA    
ElseIf Type("M->C5_MOEDA")<>"U"
	nMoedaCor:= M->C5_MOEDA      
ElseIf Type("nMoedaPed")<>"U"	 
	nMoedaCor:= nMoedaPed           
ElseIf Type("nMoedaNf")<> "U"
	nMoedaCor:= nMoedaNf    
ElseIf Type("nMoedaCor")<> "U"
	nMoedaCor:= nMoedaCor    		      	
ElseIf lXFis
	nMoedaCor 		:= MAFISRET(,'NF_MOEDA')     
EndIf		

If nMoedaCor<> 1
  nDecs := MsDecimais(nMoedaCor)
Else
	nDecs := 0
EndIf


_AliqDIG:=0

lAliqAnt:=.F.

 aAliasSFB:= SFB->(GetArea())        
 If !lXFis
 	SFB->(Dbseek(xfilial()+xRet[1]))
 Else
 	SFB->(Dbseek(xfilial()+aInfo[X_IMPOSTO]))
 EndIf

If SFB->(FieldPos('FB_DTNALIQ')) >0 .And. ddata<SFB->FB_DTNALIQ   .And. SB1->(FieldPos('B1_ALQDAN')) >0   .And.  SYD->(FieldPos('YD_ALQDAN')) >0
	lAliqAnt:=.T.
EndIf
    
SFB->(Restarea( aAliasSFB))

//+---------------------------------------------------------------+
//¦ Caso seja pedido de Venda		         					  ¦
//+---------------------------------------------------------------+
If !lXFis
	dbSelectArea("SYD")
	dbSetOrder(1)
	If SYD->(dbSeek(xFilial("SYD")+SB1->B1_POSIPI))
		_AliqDIG := SYD->YD_ALQDIG
	EndIf

	If SB1->(FieldPos('B1_ALQPDIG')) >0 .And. SB1->B1_ALQPDIG <> 0 .And. Empty(SB1->B1_POSIPI)
		_AliqDIG:=SB1->B1_ALQPDIG	
	EndIf                        

	If _AliqDIG == 0
		DbSelectArea("SFB")
		DbSetOrder(1)		
		If SFB->(Dbseek(xfilial()+xRet[1]))
			_AliqDIG := SFB->FB_ALIQ
		EndIf		     	
	EndIf
	
	xRet[2]  := _aliqDig                     					// Alíquota da SYD
	xRet[11] := aItemINFO[4]									// Rateio do Frete
	xRet[13] := aIteMINFO[5]     								// Rateio de Despesas
	xRet[3]  := aItemINFO[3]                                   // Base de Cálculo
	
	//Tira os descontos se for pelo liquido
	If Subs(xRet[5],4,1) == "S"  .And. Len(xRet) == 18 .And. ValType(xRet[18])=="N"
		xRet[3]	-=	xRet[18]
		nBase := xRet[3]
	Endif
	
	//+----------------------------------------------------------+
	//¦ Soma a Base de Cálculo os Impostos Incidentes            ¦
	//+----------------------------------------------------------+
	nI := At( cImpIncid,";" )
	nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
	
	While nI > 1
		nEE:= AScan( aItemINFO[6],{|x| x[1] == Left(cImpIncid,nI-1) } )
		If nEE> 0
			xRet[3] := xRet[3]+aItemINFO[6,nEE,4]
		Endif
		cImpIncid := Stuff( cImpIncid,1,nI,"" )
		nI := At( cImpIncid,";" )
		nI := If( nI==0,Len( AllTrim( cImpIncid ) )+1,nI )
	End
	
	//+----------------------------------------------------------+
	//¦ Efetua o Cálculo do Imposto                              ¦
	//+----------------------------------------------------------+
	xRet[4] := Round(xRet[2] * (xRet[3]/100),nDecs)
	
	
//+---------------------------------------------------------------+
//¦ Caso seja Nota Manual    		         					  ¦
//+---------------------------------------------------------------+

Else

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³Valor da Base aplicada a Aliquota    ³
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿  
	Do Case
		Case cCalculo == "B"
		   	xRet:=MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")

			//Tira os descontos se for pelo liquido
			nOrdSFC:=(SFC->(IndexOrd()))
			nRegSFC:=(SFC->(Recno()))
			SFC->(DbSetOrder(2))
			If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+ aInfo[X_IMPOSTO])))
				cImpIncid:=Alltrim(SFC->FC_INCIMP)
				If SFC->FC_LIQUIDO=="S"
					xRet-=MaFisRet(nItem,"IT_DESCONTO")
					If  SF1->(FieldPos("F1_ADIANT")) > 0 .and. SF1->(FieldPos("F1_VALADI")) > 0 .and.SD1->(FieldPos("D1_VALADI")) > 0 
						xRet-=MaFisRet(nItem,"IT_ADIANT")
					EndIf 
				Endif
			Endif
			SFC->(DbSetOrder(nOrdSFC))
			SFC->(DbGoto(nRegSFC))
			//+---------------------------------------------------------------+
			//¦ Soma a Base de Cálculo os Impostos Incidentes                 ¦
			//+---------------------------------------------------------------+
			If !Empty(cImpIncid)
				aImpRef:=MaFisRet(nItem,"IT_DESCIV")
				aImpVal:=MaFisRet(nItem,"IT_VALIMP")
				For nI:=1 to Len(aImpRef)
					If !Empty(aImpRef[nI])
						IF Trim(aImpRef[nI][1])$cImpIncid
							xRet+=aImpVal[nI]
						Endif
					Endif
				Next
			Endif
			
		Case cCalculo == "A"
				
			DbSelectArea("SB1")
			SB1->(DbSetOrder(1))
			If SB1->(DbSeek(xFilial("SB1") + MaFisRet(nItem,"IT_PRODUTO")))
				DbSelectArea("SYD")
				DbSetOrder(1)
				If SYD->(DbSeek(xFilial("SYD")+SB1->B1_POSIPI))
					_AliqDIG := SYD->YD_ALQDIG
				Endif
				
				If SB1->(FieldPos('B1_ALQPDIG')) > 0 .And. SB1->B1_ALQPDIG <> 0 .And. Empty(SB1->B1_POSIPI)
					_AliqDIG:=SB1->B1_ALQPDIG
				EndIf
			EndIf
			
			If _AliqDIG == 0
				DbSelectArea("SFB")
				DbSetOrder(1)		
				If SFB->(Dbseek(xfilial()+aInfo[X_IMPOSTO]))
					_AliqDIG := SFB->FB_ALIQ
				EndIf		     	
			EndIf                 
			xRet:=_AliqDIG
			
		Case cCalculo == "V"
			SFC->(DbSetOrder(2)) 
		
			SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+ aInfo[X_IMPOSTO]))
			If SFC->FC_CALCULO=="T"
				nBase := MaRetBasT(aInfo[2],nItem,MaFisRet(nItem,'IT_ALIQIV'+aInfo[2])) 
			Else
				nBase := MaFisRet(nItem,"IT_BASEIV"+aInfo[2])
			EndIf
			
			_AliqDIG:=MaFisRet(nItem,"IT_ALIQIV"+aInfo[2])
			xRet := Round(((_aliqDIG * nBase)/100),nDecs)		
	EndCase

Endif

RestArea(aArea)
SFC->(RestArea(aAreaSFC))   

Return(xRet)
