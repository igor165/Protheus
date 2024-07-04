#INCLUDE "PROTHEUS.CH"
/*
Fonte desenvolvido para receber funções de validação para o documento de entrada
*/

/*/{Protheus.doc} MatEst175
//
@author andre. Maximo 
@since 23/09/2019
@version 1.0
@return logico
@param item posicionado na SD1 de origem da nota
@type function
/*/

Function MatEst175(cTabSd1)
Local aAreaSD1 := (cTabSd1)->(GetArea())
Local aQtd := {}
Local lRet := .F.
Local cCq      := SuperGetMV("MV_CQ")

dbSelectArea("SD1")
dbSetOrder(1)
If MsSeek(xFilial("SD1")+(cTabSd1)->D1_NFORI+(cTabSd1)->D1_SERIORI+(cTabSd1)->D1_FORNECE+(cTabSd1)->D1_LOJA+(cTabSd1)->D1_COD+(cTabSd1)->D1_ITEMORI,.F.)
    If alltrim((cTabSd1)->D1_LOCAL) == alltrim(cCq)
        SD7->(DbSetorder(1))
        If SD7->(dbSeek(xfilial("SD7")+(cTabSd1)->(D1_NUMCQ+D1_COD) ))
            aQtd := A175CalcQt((cTabSd1)->D1_NUMCQ, (cTabSd1)->D1_COD, (cTabSd1)->D1_LOCAL)
            If len(aQtd) > 0 .And. (QtdComp(aQtd[6])==QtdComp(0) .Or. !Empty(SD7->D7_LIBERA))
                lRet:=.F.
            else
                lRet:= .T.
            EndIf
        EndIf
    EndIf
EndIf
RestArea(aAreaSD1)

return(lRet)