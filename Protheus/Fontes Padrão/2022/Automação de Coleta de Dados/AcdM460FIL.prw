#INCLUDE "RWMAKE.CH" 


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±º Funcao   ³  CBM460FIL  º Autor ³ Anderson Rodrigues º Data ³Mon 07/07/03  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Faz Filtro do PV na geracao da Nota - Mata460 				  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAACD                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/   
Function CBM460FIL()
Local cFiltro := ""

If Type("c460Cond") == "U"
	Private c460Cond := ""
EndIf

If !SuperGetMV("MV_CBPE005",.F.,.F.)
	cFiltro := '1==1'
	Return(cFiltro)
EndIf

If __cInternet == "AUTOMATICO" .OR. IsTelnet()
	cFiltro := '1==1'
	Return(cFiltro)
Endif
CB7->(DbSetOrder(1))

If Empty(c460Cond)
	c460Cond := 'Empty(SC9->C9_ORDSEP) .OR. CB7->(DbSeek(xFilial("CB7")+SC9->C9_ORDSEP)) .AND. ! "*03"$CB7->CB7_TIPEXP .AND. CB7->CB7_STATUS>="4" .AND. !"*09" $ CB7->CB7_TIPEXP '
Else
	c460Cond += ' .And. Empty(SC9->C9_ORDSEP) .OR. CB7->(DbSeek(xFilial("CB7")+SC9->C9_ORDSEP)) .AND. ! "*03"$CB7->CB7_TIPEXP .AND. CB7->CB7_STATUS>="4" .AND. !"*09" $ CB7->CB7_TIPEXP '
EndIf

cFiltro := '1==1'

Return(cFiltro)