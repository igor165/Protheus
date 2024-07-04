#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"


User Function MT150OK()
    Local lRet := .T.
    Local cChave := FWxFilial("SC8") + SC8->C8_NUM + SC8->C8_FORNECE+SC8->C8_LOJA + SC8->C8_NUMPRO
    Private aCotacao := ParamIXB[2]

    
Return cChave
