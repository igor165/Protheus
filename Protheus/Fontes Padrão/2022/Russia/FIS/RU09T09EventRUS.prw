#include 'protheus.ch'
#include 'fwmvcdef.ch'
#include 'RU09T02.ch'
#include 'parmtype.ch'


/*{Protheus.doc} RU09T09EventRUS
@type 		class
@author Alexander Ivanov
@since      2/27/2020
@version    1
*/
Class RU09T09EventRUS From FwModelEvent
	Method New() CONSTRUCTOR
    Method ModelPosVld()
EndClass



/*{Protheus.doc} RU09T09EventRUS:New()
@type       method
@author     Alexander Ivanov
@since      2/27/2020
@version    1
@description    Method - constructor of the class RU09T09EventRUS
*/
Method New() Class RU09T09EventRUS
Return Nil

/*{Protheus.doc} RU09T09EventRUS:ModelPosVld()
@type       method
@author     Alexander Ivanov
@since      2/27/2020
@version    1
*/
Method ModelPosVld(oSubModel, cSubModelID) Class RU09T09EventRUS
Local lRet          as Logical

lRet := .T.
If (cSubModelID == "F35MASTER")
    If (Empty(oSubModel:GetValue("F35_ADJDT")) .or. Empty(oSubModel:GetValue("F35_ADJNR")))
        lRet := .F.
        RU99XFUN05_Help(STR0032)
    EndIf
EndIf
Return(lRet)