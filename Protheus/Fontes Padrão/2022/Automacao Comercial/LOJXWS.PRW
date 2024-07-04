#INCLUDE "TOTVS.CH"

Static cAuthWS := Nil

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LjWsGetAut
Retorna o Header para Autenticação de Web Services.

@type       Function
@author     Alberto Deviciente
@since      13/09/2021
@version    12.1.27

@param      oWS     , Objeto, Objeto do Web Service

@return     cHeader , Caractere, Header para Autenticação de Web Services.
/*/
//-------------------------------------------------------------------------------------
Function LjWsGetAut(oWS)
Local cHeader	:= ""

If Type("cAuthWS") == "U"
    If Type("cModulo") <> "U" .And. Type("cEmpAnt") <> "U" .And. Type("cFilAnt") <> "U"
        cAuthWS := SuperGetMV("MV_AUTHWS",.F.,"")
    EndIf
EndIf

If !Empty(cAuthWS)
    cHeader := "Authorization: BASIC "+ ENCODE64(rc4crypt( cAuthWS ,"AuthWS#ReceiptID", .F.,.T.))

    //Verifica se existe o atributo "_HEADOUT"
    If ValType(oWS) <> "U" .And. AttIsMemberOf(oWS, "_HEADOUT")
        oWS:_HEADOUT := { cHeader }
    EndIf
EndIf

Return cHeader