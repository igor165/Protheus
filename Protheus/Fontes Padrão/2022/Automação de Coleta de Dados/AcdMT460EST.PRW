#include "rwmake.ch" 


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Funcao   ³ CBMT460EST º Autor ³ Anderson Rodrigues º Data ³Thu 10/07/03  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Faz validacao do estorno da liberacao dos PV's      			 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAACD                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CBMT460EST()

Static aPedi := {"",0}

If !SuperGetMV("MV_CBPE013",.F.,.F.)
	Return .t.
EndIf

If __cInternet == "AUTOMATICO" .OR. Istelnet()
	Return .t.
Endif

If ! Empty(SC9->C9_ORDSEP)
   CB7->(DbSetOrder(1))
   If CB7->(DbSeek(xFilial("CB7")+SC9->C9_ORDSEP))
      If Empty(aPedi[1])
      		MsgBox("A liberacao do Pedido "+SC9->C9_PEDIDO+" nao pode ser estornada pois o mesmo encontra-se amarrado a Ordem de Separacao "+SC9->C9_ORDSEP,"Atencao","Stop")
      		aPedi[1]:= ALLTRIM(SC9->C9_PEDIDO)
      		aPedi[2]:= 0
      		Return .f.
      ElseIf !Empty(aPedi[1]) .And. aPedi[1] <> ALLTRIM(SC9->C9_PEDIDO)
      		MsgBox("A liberacao do Pedido "+SC9->C9_PEDIDO+" nao pode ser estornada pois o mesmo encontra-se amarrado a Ordem de Separacao "+SC9->C9_ORDSEP,"Atencao","Stop")
      		aPedi[1]:= ALLTRIM(SC9->C9_PEDIDO)
      		aPedi[2]:= 0
      		Return .f.
      	ElseIf !Empty(aPedi[1]) .And. aPedi[1] == ALLTRIM(SC9->C9_PEDIDO) .And. aPedi[2] > 0
      		MsgBox("A liberacao do Pedido "+SC9->C9_PEDIDO+" nao pode ser estornada pois o mesmo encontra-se amarrado a Ordem de Separacao "+SC9->C9_ORDSEP,"Atencao","Stop")
      		aPedi[1]:= ALLTRIM(SC9->C9_PEDIDO)
      		aPedi[2]:= 0 
      		Return .f.
      	Else
      		aPedi[2]:= 1
      		Return .f.
      	Endif
   Else
      RecLock("SC9",.F.)
      SC9->C9_ORDSEP:= ""
		SC9->(MsUnLock())
   Endif
Endif
Return .t.
