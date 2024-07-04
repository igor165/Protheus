#include 'TOTVS.ch'
#include 'FWMVCDef.ch'
#include "FWEVENTVIEWCONSTS.CH"

CLASS VEIA150EVDEF FROM FWModelEvent

	METHOD New() CONSTRUCTOR
	METHOD GridLinePreVld()
	METHOD After()

ENDCLASS


METHOD New() CLASS VEIA150EVDEF
RETURN .T.


METHOD GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) CLASS VEIA150EVDEF
Local lRet    := .t.
Local cMotCan := ""
If cModelId == "VQWFILHO"
	Do Case
		Case cAction == "SETVALUE" // Valid do campo
			lRet := VA1500031_Valid(oSubModel,cId,xValue,xCurrentValue)
	EndCase
EndIf
RETURN lRet


METHOD After(oSubModel, cModelId, cAlias, lNewRecord) CLASS VEIA150EVDEF
If cModelId == "VQWFILHO"
	If lNewRecord
		VA1500051_BatizaNumeracaoVQW()
	EndIf
EndIf
RETURN