#include "Protheus.ch" 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CBMSD2520  ³ Autor ³ Anderson Rodrigues Pereira          ³ Data ³ 17/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Estorno das informacoes da nota na Ordem de Separacao					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAACD - MATA520														  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Descri‡…o ³ PLANO DE MELHORIA CONTINUA                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ITEM PMC  ³ Responsavel              ³ Data         |BOPS:             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³      01  ³Flavio Luiz Vicco         ³25/05/2006    |00000098409       ³±±
±±³      02  ³Erike Yuri da Silva       ³17/03/2006    |00000094644       ³±±
±±³      03  ³                          ³              |                  ³±±
±±³      04  ³                          ³              |                  ³±±
±±³      05  ³                          ³              |                  ³±±
±±³      06  ³                          ³              |                  ³±±
±±³      07  ³Flavio Luiz Vicco         ³25/05/2006    |00000098409       ³±±
±±³      08  ³                          ³              |                  ³±±
±±³      09  ³                          ³              |                  ³±±
±±³      10  ³Erike Yuri da Silva       ³17/03/2006    |00000094644       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/   
Function CBMSD2520( lRmOrdSep )
Local aArea   := GetArea()
Local aCB7    := CB7->(GetArea())
Local aCB6    := CB6->(GetArea())
Local aCB0    := CB0->(GetArea())
Local aSF2    := SF2->(GetArea())
Local aRetCB0 := {}
Local cRet    := ""
Local lEtqVazia := Empty( SuperGetMv( "MV_ACDCB0" ) )

Default lRmOrdSep := .F.

If !SuperGetMV("MV_CBPE008",.F.,.F.)
	Return
EndIf

If Type("l520AUTO") =="L" .and. l520AUTO
	Return
EndIf

If (AllTrim(FunName()) $ "ACDV168|ACDV170|ACDV177|")// --> Nao executa se chamado pela rotina de geracao de Nota da expedicao
	Return
EndIf

dbSelectArea("CB7")
CB7->(DbSetOrder(1))
If !CB7->(dbSeek(xFilial("CB7")+SD2->D2_ORDSEP))
	Return
EndIf

dbSelectArea("CB6")
CB6->(DBSetOrder(1))

dbSelectArea("CB9")
CB9->(DbSetOrder(1))
If !CB9->(DBSeek(xFilial("CB9")+CB7->CB7_ORDSEP))
	Return
EndIf

cComSQL := "UPDATE " +RetSQLName("CB6") +" SET CB6_NOTA = ' ', CB6_SERIE = ' ' WHERE D_E_L_E_T_ = ' ' AND "
cComSQL += "CB6_FILIAL = '" +xFilial("CB6") +"' AND CB6_NOTA = '" +SD2->D2_DOC +"' AND CB6_SERIE = '" +SD2->D2_SERIE +"'"
TCSQLExec(cComSQL)

cComSQL := "UPDATE " +RetSQLName("CB0") +" SET CB0_NFSAI = ' ', CB0_SERIES = ' ' WHERE D_E_L_E_T_ = ' ' AND "
cComSQL += "CB0_FILIAL = '" +xFilial("CB0") +"' AND CB0_NFSAI = '" +SD2->D2_DOC +"' AND CB0_SERIES = '" +SD2->D2_SERIE +"'"
TCSQLExec(cComSQL)

cComSQL := "UPDATE " +RetSQLName("CB9") +" SET CB9_QTEEBQ = 0, CB9_STATUS = '"
If "01*" $ CB7->CB7_TIPEXP .Or. "02*" $ CB7->CB7_TIPEXP // Separacao com Embalagem
	cComSQL += "2"  // EMBALAGEM FINALIZADA	
Else
	cComSQL += "1"  // EM ABERTO
EndIf
cComSQL += "' WHERE D_E_L_E_T_ = ' ' AND CB9_FILIAL = '" +xFilial("CB9") +"' AND CB9_ORDSEP = '" +SD2->D2_ORDSEP +"'"
TCSQLExec(cComSQL)

RecLock('CB7',.F.)
If "03*" $ CB7->CB7_TIPEXP 
	CB7->CB7_STATUS := CBAntProc(CB7->CB7_TIPEXP,"03*")
	CB7->CB7_STATPA := "1"
EndIf	
CB7->CB7_NOTA   := " "
CB7->CB7_SERIE  := " "
CB7->CB7_VOLEMI := " "
CB7->CB7_NFEMIT := " "
CB7->(MsUnlock())

cRet := IIf( ( lRmOrdSep .And. lEtqVazia ), ",SC9->C9_ORDSEP := CriaVar( 'C9_ORDSEP', .F. ) ", ", SC9->C9_ORDSEP := SD2->D2_ORDSEP " )

RestArea(aCB7)
RestArea(aSF2)
RestArea(aCB0)
RestArea(aCB6)
RestArea(aArea)
Return cRet
