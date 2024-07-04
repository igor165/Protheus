#INCLUDE "PROTHEUS.CH"
#INCLUDE "ACDMSD2460.CH"
#INCLUDE "RWMAKE.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CBMSD2460  ³ Autor ³ Anderson Rodrigues       	 ³ Data ³ 07/08/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gravacao das tabelas de Ordens de Separacao do ACD com os dados     ³±±
±±³			 ³ da Nota Fiscal quando a mesma for gerada pelo Protheus 	           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAACD - MATA460											       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CBMSD2460()
Local lRotAuto:= __cInternet == "AUTOMATICO"

If !SuperGetMV("MV_CBPE007",.F.,.F.)
	Return
EndIf

RecLock("SD2",.F.)
SD2->D2_ORDSEP:= SC9->C9_ORDSEP
SD2->(MsUnlock())
If lRotAuto
   Return
Endif
If Empty(SD2->D2_ORDSEP)
   Return
Endif
CB7->(DbSetOrder(1))
If !CB7->(DBSeek(xFilial('CB7')+SD2->D2_ORDSEP))
   MsgBox(I18N(STR0001,{SD2->D2_ORDSEP}),STR0002,"OK") // "Ordem de Separacao #1 não encontrada na tabela CB7, Verifique !!!" ### "Aviso"
   Return
Endif
CB9->(DbSetOrder(9))
If !CB9->(DBSeek(xFilial('CB9')+CB7->CB7_ORDSEP+SD2->D2_COD))
	MsgBox(I18N(STR0003,{SD2->D2_COD,SD2->D2_ORDSEP}),STR0002,"OK") // "Produto #1 nao encontrado na Ordem de Separacao #2 Verifique !!!" ### "Aviso"
   Return
Endif
While CB9->(!Eof() .and. xFilial('CB9')+CB7->CB7_ORDSEP+SD2->D2_COD == CB9_FILIAL+CB9_ORDSEP+CB9_PROD)	
   If CB6->(DbSeek(xFilial('CB6')+CB9->CB9_VOLUME))
      RecLock('CB6')			
      CB6->CB6_NOTA := SD2->D2_DOC
      //CB6->CB6_SERIE:= SD2->D2_SERIE
 	   SerieNfId ("CB6",1,"CB6_SERIE",,,,SD2->D2_SERIE)
      CB6->(MsUnlock())
   EndIf	
	aRetCB0 := CBRetEti(CB9->CB9_CODETI,'01')
	If Len(aRetCB0) > 0		
	   aRetCB0[13] := SD2->D2_DOC
	   aRetCB0[14] := SD2->D2_SERIE
		CBGrvEti("01",aRetCB0,CB9->CB9_CODETI)
	EndIf
	CB9->(DbSkip())
EndDo	
Return
