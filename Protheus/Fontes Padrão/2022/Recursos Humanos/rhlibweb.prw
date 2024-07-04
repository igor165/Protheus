#INCLUDE "PROTHEUS.CH"

Function HtmlBlank(xValue)
	Local cRet:= "&nbsp;"

	If xValue == NIL .OR.;
		(ValType(xValue) == "C" .AND. Empty(xValue))			
		cRet:= "&nbsp;"
	Else
		cRet:= xValue
	EndIf
	
Return cRet