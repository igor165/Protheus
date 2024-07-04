#Include "Protheus.ch"
#Include "rwmake.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLA100DEL()
Validar se prossegue ou nao com a exclusao do Documento de Entrada  

@author Bruno.Schmidt
@since 06/02/2017
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Static Function DCLA100DEL()

Local lRet		:= .T.
Local aAreaSD1	:= SD1->(GetArea())
Local aAreaSF4	:= SF4->(GetArea())
Local cChave		:= SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)

SD1->(DbSetOrder(1))
If SD1->(MsSeek(xFilial("SD1")+cChave))
	While cChave == SD1->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA)
		If SF4->(MsSeek(xFilial("SF4")+SD1->D1_TES)) .And. SF4->F4_ESTOQUE == "S"
			lRet := ValEstDcl(SD1->D1_COD,SD1->D1_LOCAL,SD1->D1_QUANT,SD1->D1_DTDIGIT,1)
		EndIf
		SD1->(dbSkip())
	EndDo
Else
	lRet := .F.
EndIf


RestArea(aAreaSD1)
RestArea(aAreaSF4)

Return lRet

