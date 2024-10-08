#INCLUDE "SIGAWIN.CH"

//Posicoes  do terceiro array recebido nos impostos a traves da matxfis...
#DEFINE X_IMPOSTO    1 //Nome do imposto
#DEFINE X_NUMIMP     2 //Sufixo do imposto

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Funcao    �M460DIG   � Autor � Ivan Haponczuk         � Data � 11.11.09  ���
���������������������������������������������������������������������������Ĵ��
���Descricao �Programa que Calcula DIG   (PERU)                             ���
���������������������������������������������������������������������������Ĵ��
���Uso       �MATA467/MATA468                                               ���
���������������������������������������������������������������������������Ĵ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function M460DIG(cCalculo,nItem,aInfo)

Local nDecs := 0
Local nI	:= 0
Local lXFis
Local nBase := 0
Local cAliasROT, cOrdemROT
Local aImpRef,aImpVal
Local aArea	   		:= GetArea()
Local aAreaSFC	:= SFC->(GetArea())
Local Alias:=""                    
Local ddata:=dDatabase

SetPrvt("AITEMINFO,xRet,CIMPINCID,_ALIQDIG")
SetPrvt("NI,NEE")                                      

If Type("M->F1_EMISSAO")<>"U" 
	ddata:= M->F1_EMISSAO      
ElseIf Type("M->F2_EMISSAO")<>"U"
	ddata:= M->F2_EMISSAO    
EndIf

lXFis:=(MaFisFound() .And. ProcName(1)<>"EXECBLOCK")
cAliasRot:= Alias()
cOrdemRot:= IndexOrd()
/*
���������������������������������������������������������������Ŀ
� Observacao :                                                  �
�                                                               �
� a variavel ParamIxb tem como conteudo um Array[2], contendo : �
� [1,1] > Quantidade Vendida                                    �
� [1,2] > Preco Unitario                                        �
� [1,3] > Valor Total do Item, com Descontos etc...             �
� [1,4] > Valor do Frete Rateado para Este Item ...             �
� [1,5] > Array Contendo os Impostos j� calculados, no caso de  �
�         incid�ncia de outros impostos.                        �
� [2,1] > Array xRet, Contendo as Informa��es do Imposto que�
�         ser� calculado.                                       �
�����������������������������������������������������������������
*/

//+---------------------------------------------------------------+
//� Caso seja pedido de Venda		         					  �
//+---------------------------------------------------------------+	
If !lXFis
	aItemINFO:=ParamIxb[1]              
	xRet:=ParamIxb[2]
	cImpIncid:=xRet[10]
Endif

nMoedaCor := IIf(Type("nMoedaCor")	=="U",1,nMoedaCor)
If nMoedaCor <> 1
	nDecs := MsDecimais(nMoedaCor)
else
	nDecs :=0	
endif

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
//� Caso seja pedido de Venda		         					  �
//+---------------------------------------------------------------+
If !lXFis
	dbSelectArea("SYD")
	dbSetOrder(1)
	If SYD->(dbSeek(xFilial("SYD")+SB1->B1_POSIPI))
		_AliqDIG :=SYD->YD_ALQDIG
		
		If lAliqAnt .And. SYD->YD_ALQDAN<> 0
			_AliqDIG:=SYD->YD_ALQDAN
		EndIf
	EndIf

	If SB1->(FieldPos('B1_ALQPDIG')) >0 .And. SB1->B1_ALQPDIG <> 0 .And. Empty(SB1->B1_POSIPI)
		_AliqDIG:=SB1->B1_ALQPDIG
		If lAliqAnt .And. SB1->B1_ALQDAN<> 0
			_AliqDIG:=SB1->B1_ALQDAN
		EndIf	
	EndIf   
	If _AliqDIG == 0
		DbSelectArea("SFB")
		DbSetOrder(1)		
		If SFB->(Dbseek(xfilial()+xRet[1]))
			_AliqDIG := SFB->FB_ALIQ
		EndIf		     	
	EndIf
	
	xRet[2]  := _aliqDIG                     					// Al�quota da SYD
	xRet[11] := aItemINFO[4]									// Rateio do Frete
	xRet[13] := aIteMINFO[5]     								// Rateio de Despesas
	xRet[3]  := aItemINFO[3]                                   // Base de C�lculo
	xRet[3]:=xRet[3]+xRet[11]+xRet[13]
	//Tira os descontos se for pelo liquido
	If Subs(xRet[5],4,1) == "S"  .And. Len(xRet) == 18 .And. ValType(xRet[18])=="N"
		xRet[3]	-=	xRet[18]
		nBase := xRet[3]
	Endif
	
	//+----------------------------------------------------------+
	//� Soma a Base de C�lculo os Impostos Incidentes            �
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
	//� Efetua o C�lculo do Imposto                              �
	//+----------------------------------------------------------+
	xRet[4] := Round(xRet[2] * (xRet[3]/100),nDecs)
	
	
//+---------------------------------------------------------------+
//� Caso seja Nota Manual    		         					  �
//+---------------------------------------------------------------+

Else

	//��������������������������������������Ŀ
    //�Valor da Base aplicada a Aliquota    �
	//��������������������������������������Ŀ  
	Do Case
		Case cCalculo == "B"
			xRet   := MaFisRet(nItem,"IT_VALMERC")+MaFisRet(nItem,"IT_FRETE")+MaFisRet(nItem,"IT_DESPESA")+MaFisRet(nItem,"IT_SEGURO")
			If GetNewPar('MV_DESCSAI','1')=='1' 
				xRet	+= MaFisRet(nItem,"IT_DESCONTO")
			Endif
			//Tira os descontos se for pelo liquido
			nOrdSFC:=(SFC->(IndexOrd()))
			nRegSFC:=(SFC->(Recno()))
			SFC->(DbSetOrder(2))
			If (SFC->(DbSeek(xFilial("SFC")+MaFisRet(nItem,"IT_TES")+ aInfo[X_IMPOSTO])))
				cImpIncid:=Alltrim(SFC->FC_INCIMP)
				If SFC->FC_LIQUIDO=="S"
					xRet-=MaFisRet(nItem,"IT_DESCONTO")
					If  SF2->(FieldPos("F2_VALADI")) > 0 .and. SD2->(FieldPos("D2_VALADI")) > 0
						xRet-= MaFisRet(nItem,"IT_ADIANT")
					EndIf 
				Endif
			Endif
			SFC->(DbSetOrder(nOrdSFC))
			SFC->(DbGoto(nRegSFC))
			//+---------------------------------------------------------------+
			//� Soma a Base de C�lculo os Impostos Incidentes                 �
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
			DbSetOrder(1)
			If DbSeek(xFilial("SB1") + MaFisRet(nItem,"IT_PRODUTO"))
				cPOSIPI := SB1->B1_POSIPI
			EndIf
			DbSelectArea("SYD")       
			DbSetOrder(1)
			If DbSeek(xFilial("SYD") + cPOSIPI)
					_AliqDIG :=SYD->YD_ALQDIG
					
					 If lAliqAnt .And. SYD->YD_ALQDAN>0
				 		_AliqDIG :=SYD->YD_ALQDAN
				    EndIf
			Endif
			If SB1->(FieldPos('B1_ALQPDIG')) >0 .And. SB1->B1_ALQPDIG <> 0 .And. Empty(cPOSIPI)
					_AliqDIG:=SB1->B1_ALQPDIG
					IF (lAliqAnt .and. SB1->B1_ALQDAN >0)
						_AliqDIG:=SB1->B1_ALQDAN
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

Return( xRet )
