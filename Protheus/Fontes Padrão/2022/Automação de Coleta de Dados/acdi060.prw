#INCLUDE "ACDI060.ch" 
#include "rwmake.ch"        

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ ACDI060  ³ Autor ³ Sandro                ³ Data ³ 05/02/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Impressao de etiquetas de usuario                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAACD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function ACDI060


IF ! Pergunte("AII060",.T.) 
   Return
EndIF        
If IsTelNet() 
   VtMsg(STR0001) //'Imprimindo'
   ACDI060US()
Else 
   Processa({|| ACDI060US()})
EndIf   
Return       

Function ACDI060US(nID,cImp)            
Local cIndexCB1,cCondicao
Local cCodOpe,aRet              
Local cRet:=''

If nID # NIL
   aRet := CBRetEti(nID,'04',NIL,.T.)
   If Len(aRet) == 0
      Return .f.
   EndIf
   cCodOpe := aRet[1]   
   cRet:='R'
End
If ! CB5SetImp(If(nID==NIL,MV_PAR03,cImp),IsTelNet() )
   Return .f.
EndIf   
cIndexCB1 := CriaTrab(nil,.f.)
DbSelectArea("CB1")
cCondicao :=""                                                    
cCondicao := cCondicao + "CB1_FILIAL    == '"+ xFilial()+"' .And. "
cCondicao := cCondicao + "CB1_CODOPE     >= '"+IF(nID==NIL,mv_par01,cCodOpe) +"' .And. "
cCondicao := cCondicao + "CB1_CODOPE     <= '"+IF(nID==NIL,mv_par02,cCodOpe) +"'"
IndRegua("CB1",cIndexCB1,"CB1_CODOPE",,cCondicao,,.f.)
DBGoTop()                         
While ! CB1->(Eof())
   If ExistBlock('IMG04')
      ExecBlock("IMG04",,,{nID})
   EndIf
   CB1->(DbSkip())
End

RetIndex("CB1")
Ferase(cIndexCB1+OrdBagExt())
If ExistBlock('IMG00')
   ExecBlock("IMG00",,,{cRet+ProcName(),IF(nID==NIL,mv_par01,cCodOpe),IF(nID==NIL,mv_par02,cCodOpe)})
EndIf
MSCBCLOSEPRINTER()
Return .t.
                                        
