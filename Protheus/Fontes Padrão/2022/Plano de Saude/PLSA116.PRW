#Include "Protheus.Ch"
#Include "PLSA116.Ch"  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA116   ºAutor  ³Diogo Ximenes       º Data ³ 10/02/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Fixa o prazo para Liquidar a divida do usuario.			  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PLSA116()  
Private cPerg 		:= "PLSA116"


If Pergunte(cPerg,.T.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Chama a rotina para estorno d status...   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MsAguarde({|| FixPrzUsr() }, STR0001, "", .T.) //"Prazo Liquidação"
Else
	Return(.T.)
Endif  

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³EstUsr    ºAutor  ³Diogo Ximenes       º Data ³ 10/12/2010  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Fixa o prazo para liquidar a divida do usuario.			  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FixPrzUsr()
                     
Local nMesAux	:= 0
Local nMes 		:= 0
Local nAno 		:= 0
Local nTotal	:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciona nos subcontratos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("B81")
B81->(DbSetOrder(1))
If B81->(MsSeek(xFilial("B81")+MV_PAR01+MV_PAR02))
	If B81->B81_PACOOK == "0"
		While 	!B81->(Eof()) .And.; 
				B81->(B81_FILIAL+B81_CODINT+B81_CODEMP) == xFilial("B81")+MV_PAR01+MV_PAR02 
			
			If dDataBase >= B81->B81_VIGPA .And. (dDataBase <= B81_VIGFIM .Or. Empty(B81_VIGFIM))
  	        	B81->(DbSkip())
  	        	Loop
  	    	EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Posiciona nas familias dos usuários.   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("BA3")
			BA3->(DbSetOrder(1))
		 	If BA3->(MsSeek(xFilial("BA3")+MV_PAR01+MV_PAR02))	
		 		While 	!BA3->(Eof()) .And.; 
						BA3->(BA3_FILIAL+BA3_CODINT+BA3_CODEMP) == xFilial("BA3")+MV_PAR01+MV_PAR02
					If BA3->BA3_PACOOK == "0" 	   		
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Posiciona nas vidas.³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						DBSelectArea("BA1")  
						BA1->(DbSetOrder(13)) //BA1_FILIAL, BA1_CODINT, BA1_CODEMP, BA1_CONEMP, BA1_VERCON, BA1_SUBCON, BA1_VERSUB, BA1_MATRIC, BA1_TIPREG
						If BA1->(MsSeek(xFilial("BA1")+MV_PAR01+MV_PAR02))
							While 	!BA1->(Eof()) .And.; 
								BA1->(BA1_FILIAL+BA1_CODINT+BA1_CODEMP) == xFilial("BA1")+MV_PAR01+MV_PAR02 
								If BA1->BA1_PACOOK == "0"
									nMesAux	:= B81->B81_MESCAN + Month(dDataBase)
									nMes 	:= Iif(NOROUND(nMesAux/12,0) > 0,nMesAux-NOROUND(nMesAux/12,0)*12,nMesAux)
									nAno 	:= Iif(NOROUND(nMesAux/12,0) > 0,Year(dDataBase)+NOROUND(nMesAux/12,0),Year(dDataBase))					   	
								   	If 	!Empty(BA1->BA1_DATBLO) .And. ;
								   		Month(BA1->BA1_DATBLO) == nMes .And. ;
								   		Year(BA1->BA1_DATBLO) == nAno
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³Faz a alteracao dos dados.³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								   		BA1->(RecLock("BA1",.F.))
								   			BA1->BA1_TREGRA	:= "1"
								   			BA1->BA1_MESLIQ	:=AllTrim(Str(nMes))
								   			BA1->BA1_ANOLIQ	:= AllTrim(Str(nAno))
								   		BA1->(MsUnLock())
										nTotal ++	
									EndIf 		 
								EndIf	
								BA1->(DbSkip())					
							EndDo	  
						EndIf 
					EndIf
					BA3->(DbSkip())
				EndDo
			EndIf
   			B81->(DbSkip())				 
		EndDo
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exibe a mensagem para o usuario...³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nTotal <= 0
	MsgAlert(STR0002) //"Nenhum Usuário foi Alterado!"
ElseIf nTotal == 1
	MsgAlert(STR0003) //"Foi Alterado um Usuário!"
ElseIf nTotal > 1
	MsgAlert(STR0004+AllTrim(str(nTotal))+STR0005) //"Foram Alterados "###" Usuários!"
EndIf                       

Return(.T.)