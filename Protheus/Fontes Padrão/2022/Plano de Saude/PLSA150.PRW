#include "PLSA150.CH"
#include "PLSMGER.CH"
#include "PROTHEUS.CH"
#include "COLORS.CH"

Function PLSA150()
Return

Function PLSSAYESP(nLin,nCol,cDado,nAte,nSize,oDlg,oFonte,oCor,cObj)

If ValType(cObj) <> "C"
   @ nLin, nCol          Say oObSay01 PROMPT Eval(cDado) SIZE nAte, nSize OF oDlg PIXEL COLOR oCor
   @ nLin+0.6, nCol+0.45 Say oObSay02 PROMPT Eval(cDado) SIZE nAte, nSize OF oDlg PIXEL 
Else
   // Feita verificação se a chamada vem do PLSA260VCB ou A260Mov, se sim, não faz o reposicionamento da segunda linha impressa, ocasiona problemas em algumas resoluções
   If IsInCallStack("PLSA260VCB") .OR. IsInCallStack("A260Mov")
      @ nLin, nCol          Say &cObj PROMPT Eval(cDado) SIZE nAte, nSize OF oDlg PIXEL COLOR oCor
      _cObj := StrTran(cObj,"01","02")
      @ nLin, nCol Say &_cObj PROMPT Eval(cDado) SIZE nAte, nSize OF oDlg PIXEL
   Else
      @ nLin, nCol          Say &cObj PROMPT Eval(cDado) SIZE nAte, nSize OF oDlg PIXEL COLOR oCor
      _cObj := StrTran(cObj,"01","02")
      @ nLin+0.6, nCol+0.45 Say &_cObj PROMPT Eval(cDado) SIZE nAte, nSize OF oDlg PIXEL
   EndIf   
Endif   

Return