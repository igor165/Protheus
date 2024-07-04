#include 'protheus.ch'
#include 'fwmvcdef.ch'
#include 'RU09T05.ch'
#include 'RU09XXX.ch'


/*{Protheus.doc} RU09T05EventRUS
@type 		class
@author Ruslan Burkov
@since 18/01/2019
@description Class to handle business procces of RU09T05
*/
Class RU09T05EventRUS From FwModelEvent
	Method New() CONSTRUCTOR
    Method GridLinePosVld(oSubModel, cSubModelID)
    Method ModelPosVld(oSubModel, cSubModelID)
    Method VldActivate(oModel, cModelID)
EndClass


/*{Protheus.doc} RU09T05EventRUS:New()
@type       method
@author     Ruslan Burkov
@since      18/01/2019
@description    Method - constructor of the class RU09T05EventRUS
*/
Method New() Class RU09T05EventRUS
Return Nil


/*{Protheus.doc} RU09T05EventRUS:GridLinePosVld()
@type       method
@author     Ruslan Burkov
@since      18/01/2019
*/
Method GridLinePosVld(oSubModel, cSubModelID) Class RU09T05EventRUS 
Local lRet := .T.

If lRet .and. (cSubModelID == "F3CDETAIL")
    If (oSubModel:GetValue("F3C_ADSHNR") != 0 .AND. Empty(oSubModel:GetValue("F3C_ADSHDT")))
        lRet := .F.
        Help("",1,"RU09T05:01",,STR0954,1,0)
    ElseIf (oSubModel:GetValue("F3C_ADSHNR") == 0 .AND. !Empty(oSubModel:GetValue("F3C_ADSHDT")))
        lRet := .F.
        Help("",1,"RU09T05:02",,STR0955,1,0)
    EndIf
EndIf

Return(lRet)



/*{Protheus.doc} RU09T05EventRUS:ModelPosVld()
@type       method
@author     Artem Kostin
@since      25/01/2019
*/
Method ModelPosVld(oSubModel, cSubModelID) Class RU09T05EventRUS
    Local lRet As Logical
    Local nLine As Numeric
    Local oModelF3C As Object

    lRet := .T.

    If lRet .And. (cSubModelID == "RU09T05")
        oModelF3C := oSubModel:GetModel("F3CDETAIL")
        For nLine := 1 To oModelF3C:Length()
            oModelF3C:GoLine(nLine)
            If !(oModelF3C:IsDeleted()) .And. Empty(oModelF3C:GetValue("F3C_TG_COD"))
                lRet := .F.
                Help("",1,"RU09T05EventRUS:ModelPosVld:01",,STR0001,1,0,,,,,,{oModelF3C:GetValue("F3C_ITEM")})
                Exit
            EndIf
        Next nLine
        oModelF3C:GoLine(1)
    EndIf

Return lRet


/*{Protheus.doc} RU09T05EventRUS
@type 		method
@author Daria Sergeeva 
@since 06/02/2020
@version 	P12.1.25
*/
Method VldActivate(oModel, cModelID) Class RU09T05EventRUS
Local lRet as Logical
Local nOperation as Numeric

lRet := .T.
nOperation := oModel:GetOperation() 

lRet    := lRet .And. (nOperation != MODEL_OPERATION_UPDATE .Or. F3B->F3B_STATUS != "3" .Or. Empty(F3B_DTLA).Or. FWIsInCallStack('RU09T05001_RETBOOK'))

Return lRet