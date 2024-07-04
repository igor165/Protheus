#INCLUDE "rwmake.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} MT240EST
validação de estoque negativo apos estono do movimento interno

@author taniel.silva
@return _lRet
@since 24/09/2014
@version P11
/*/
//-------------------------------------------------------------------
Function DCLMT240ES()
Local _aArea        := GetArea()
Local _aAreaSD3     := SD3->(GetArea())
Local _lRet			:= .T.

// Verifica se o saldo em estoque ficara negativo
If _lRet .And. ((SD3->D3_TM > "500" .And. IsInCallStack("A240Inclui")) .Or. (SD3->D3_TM < "501" .And. IsInCallStack("A240Estorn")))
	_lRet := ValEstDcl(SD3->D3_COD,SD3->D3_LOCAL,SD3->D3_QUANT,SD3->D3_EMISSAO,3)
EndIf	

SD3->(RestArea(_aAreaSD3))
RestArea(_aArea)

Return(_lRet)
