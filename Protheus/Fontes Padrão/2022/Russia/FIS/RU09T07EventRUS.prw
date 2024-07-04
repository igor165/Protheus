#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RU09T07.CH"

/*{Protheus.doc} RU09T07EventRUS
@type		class
@author		Artem Kostin
@since		23.03.2020
@version	P12.1.30
@description Class to support model RU09T07
*/
Class RU09T07EventRUS From FwModelEvent
	Method New() CONSTRUCTOR
	Method InTTS(oModel, cModelId)
EndClass

/*{Protheus.doc} RU09T07EventRUS:New()
@type		method
@author		Artem Kostin
@since		23.03.2020
@version	P12.1.30
@description	Method - constructor of the class RU09T07EventRUS
*/
Method New() Class RU09T07EventRUS
Return Nil

/*{Protheus.doc} RU09T07EventRUS:New()
@type		method
@author		Artem Kostin
@since		23.03.2020
@version	P12.1.30
@description	Method saves model in transaction
*/
Method InTTS(oModel, cModelId) Class RU09T07EventRUS
Local lRet	as Logical

lRet := RU05XFN010_CheckModel(oModel, cModelId)
If (lRet)
	If (oModel:GetOperation() == MODEL_OPERATION_INSERT)

	ElseIf (oModel:GetOperation() == MODEL_OPERATION_UPDATE)

	ElseIf (oModel:GetOperation() == MODEL_OPERATION_DELETE)

	EndIf
EndIf

lRet := lRet .and. RU09D05Edt(oModel)
Return lRet
