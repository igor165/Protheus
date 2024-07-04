#INCLUDE "M410ACDL.ch" 
#include "rwmake.ch"   

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Funcao   ³ CBM410ACDL  º Autor ³ SigaACD            º Data ³ 30/03/2006   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Faz validacao dos itens dos PV's  		    		          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SigaACD                                                     	  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CBM410ACDL()
Local aAreaSC9 := SC9->(GetArea())
Local aAreaSC6 := SC6->(GetArea())
Local lRet     := .T.
Local nY       := 0
Local cRotina  := Upper(FunName())

If	!SuperGetMV("MV_CBPE023",.F.,.F.)
	Return lRet
EndIf
If	__cInternet == "AUTOMATICO" .OR. Istelnet()
	Return lRet
EndIf 

nY :=aScan(aHeader,{|x| AllTrim(x[2]) == IIf(cRotina == "TMKA271","UB_REC_WT","C6_REC_WT")})
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Para o caso do C6_REC_WT nao seja carregado ³
//³ no aHeader em processos de retorno.         ³
//³ Verifica tambem se conteudo do C6_REC_WT eh ³
//³ numerico e eh maior que zero                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nY > 0 .And. ValType(aCols[n][nY]) == "N" .And. aCols[n][nY] > 0	
	If cRotina == "MATA410"
		SC6->(dbGoTo(Acols[n][nY]))
		SC9->(dbSetOrder(2)) //-- C9_FILIAL+C9_CLIENTE+C9_LOJA+C9_PEDIDO+C9_ITEM
		If	SC9->(dbSeek(xFilial('SC9')+SC6->(C6_CLI+C6_LOJA+C6_NUM+Trim(Acols[n,1])), .F.)) .And. !Empty(SC9->C9_ORDSEP)
			While  !SC9->(EOF())  .And. SC9->(xFilial('SC9')+SC6->(C6_CLI+C6_LOJA+C6_NUM+Trim(Acols[n,1]))) ==; 
				SC9->(C9_FILIAL+C9_CLIENTE+C9_LOJA+C9_PEDIDO+C9_ITEM) .And. !Empty(SC9->C9_ORDSEP)
				CB7->(DbSetOrder(1))
				If	CB7->(DbSeek(xFilial("CB7")+SC9->C9_ORDSEP)) 
					If Empty(SC9->C9_NFISCAL+SC9->C9_SERIENF)
						MsgBox(STR0001+SC9->C9_PEDIDO+STR0002+SC9->C9_ORDSEP+' '+STR0004,STR0003,"Stop") //"A liberacao do Pedido "###" nao pode ser alterada pois o mesmo encontra-se amarrado a Ordem de Separacao "###"Atencao"
						lRet := .F.
					EndIF
				Else
					RecLock("SC9",.F.)
					SC9->C9_ORDSEP := ""
					SC9->(MsUnLock())
				EndIf
				SC9->(dbSkip())
			EndDo
		EndIf
	ElseIf cRotina == "TMKA271" .And. !Inclui
		SC9->(dbSetOrder(2)) //-- C9_FILIAL+C9_CLIENTE+C9_LOJA+C9_PEDIDO+C9_ITEM
		If	SC9->(dbSeek(xFilial('SC9')+SUA->UA_CLIENTE+SUA->UA_LOJA+SUA->UA_NUMSC5+StrZero(n,2),.F.)) .And. !Empty(SC9->C9_ORDSEP)
			CB7->(DbSetOrder(1))
			If	CB7->(DbSeek(xFilial("CB7")+SC9->C9_ORDSEP))
				MsgBox(STR0001+SC9->C9_PEDIDO+STR0002+SC9->C9_ORDSEP,STR0003,"Stop") //"A liberacao do Pedido "###" nao pode ser alterada pois o mesmo encontra-se amarrado a Ordem de Separacao "###"Atencao"
				lRet := .F.
			Else
				RecLock("SC9",.F.)
				SC9->C9_ORDSEP := ""
				SC9->(MsUnLock())
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aAreaSC9)
RestArea(aAreaSC6)
Return lRet
