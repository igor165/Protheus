#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

User Function MT103PN()
    Local aParam := ParamIxb
Return .T.

USER FUNCTION MAT103OK() 
    Local lRet := ParamIxb[1]     //Customiza��es do usu�rio.
Return lRet

User Function ADOCVTOK()
    Local lRet:= .T.// Customiza��o desejada para a valida��o conforme a regra de neg�cio praticada 
Return lRet
