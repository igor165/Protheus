#include 'TOTVS.ch'
#include 'FWMVCDef.ch'
#include "FWEVENTVIEWCONSTS.CH"

CLASS VEIA260EVDEF FROM FWModelEvent

	METHOD New() CONSTRUCTOR
	METHOD FieldPreVld()
	METHOD ModelPosVld()

ENDCLASS


METHOD New() CLASS VEIA260EVDEF
RETURN .T.


METHOD FieldPreVld(oSubModel, cModelID, cAction, cId, xValue) CLASS VEIA260EVDEF
Local lRet := .t.
If cModelId == "VQFMASTER"
	IF cAction == "SETVALUE" // Valid do campo
		lRet := VA260011_ValidacaoCampos("VQF",oSubModel,cId,xValue)
	Endif
EndIf
RETURN lRet

METHOD ModelPosVld(oModel, cModelId) CLASS VEIA260EVDEF
Local lRet := .t.

If cModelId == "VEIA260"
	lRet := VA260021_TudoOk(oModel)
EndIf

Return lRet