#INCLUDE "PROTHEUS.CH"

Function PCOQtdEntd(cAlias as Character)
Local nQtd as Numeric
Local nQtPco as Numeric
Local nQtdEntid as Numeric
Default cAlias := 'AK2'
nQtdEntid := If(FindFunction("CtbQtdEntd"),CtbQtdEntd(),4)
If nQtdEntid > 4
     For nQtd := 5 To nQtdEntid
          If (cAlias)->(FieldPos("AK2_ENT"+STRZERO(nQtd,2))) > 0
               nQtPco++
          Else
               Exit
          Endif
     Next
     nQtdEntid := 4 + nQtPco
Endif

Return nQtdEntid