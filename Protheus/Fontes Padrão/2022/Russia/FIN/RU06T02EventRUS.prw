#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOPCONN.CH"
#include "TOTVS.CH"
#INCLUDE "RU06T02.CH"


Class RU06T02EventRUS From FwModelEvent

	Method New() CONSTRUCTOR
	Method GridPosVld()
	method FieldPreVld()
	method VLdActivate()
	Method Activate()
	Method GridLinePreVld()
    Method ModelPosVld()

EndClass


Method New() Class RU06T02EventRUS
Return Nil

/*{Protheus.doc} Activate
@type method
@author dtereshenko
@version P12 R8
@since 29.07.2019
@description Method that is called by MVC when Model activation occurs.
*/
Method Activate(oModel, lCopy) Class RU06T02EventRUS
    Local nOperation    as Numeric
    Local oView         as Object

    If !Empty(oModel)
        nOperation := oModel:GetOperation()

        If nOperation != 1 .OR. !FwIsInCallStack('RU06T0290_GenPayOrd')
            oView := FWViewActive()

            If !Empty(oView)
                oView:AddUserButton(STR0016, "", {||RU06T0203_AddReqs()})  //Run a selection of applications For payment. Runs through pergunta
            EndIf
        EndIf
    EndIf

Return


/*{Protheus.doc} VLdActivate
@type method
@author afedorova
@version P12 R8
@since 01.07.2019
@description Method that is called by the MVC occur when the Model validation actions .
*/
Method VLdActivate(oModel, cModelId) Class RU06T02EventRUS
	local oStrVirt as Object

	oStrVirt := RU06t0218_DefVirtStr(.T.)

Return .T.

/*{Protheus.doc} GridLinePreVld
@type method
@author dtereshenko
@version P12 R8
@since 30.07.2019
@description Method that is called by the MVC occur when the pre validation shares of the Grid line
*/
Method GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) Class RU06T02EventRUS

local oView as Object

oView := FWViewActive()
If cModelId == "RU06T02_MVIRT" .And. !Empty(oSubModel) .AND. cAction $ "DELETE, UNDELETE"

    //Update totals based at temporary table
    RU06T0223_Write_values(nLine, cAction)
    If ValType(oView) == "O" .And. oView:IsActive() .AND. !isblind()
        oView:Refresh()
    EndIf

EndIf
Return .T.


/*{Protheus.doc} GridPosVld
@description Method that is called by the MVC occur when the post validation actions Grid.
@type method
@author afedorova
@version P12 R8
@since 23.04.2019
*/
Method GridPosVld(oSubModel, cModelId) Class RU06T02EventRUS
Local nX 		as Numeric
Local oModelF5M	as Object
Local oModelF60	as Object
Local cKey 		as Character
local cID60		as character

If cModelId=="RU06T02_MVIRT"
	oModelF5M:=oSubModel:GetModel():GetModel("RU06T02_MLNS")
	oModelF60:=oSubModel:GetModel():GetModel("RU06T02_MHEAD")

	For nX:=1 to oSubModel:Length()
		oSubModel:GoLine(nX)
		cKey:= oSubModel:GetValue("B_IDF47")
		cID60 := oModelF60:GetValue("F60_IDF60")
		If oModelF5M:SeekLine({{"F5M_FILIAL", xFilial("F5M")}, {"F5M_ALIAS", "F60"},{"F5M_IDDOC",cID60},{"F5M_KEY", cKey}, {"F5M_KEYALI", "F47"} },.T.,.T.)
            If oSubModel:IsDeleted()
                oModelF5M:DeleteLine()
            EndIf
        EndIf
	Next nX
EndIf
RU06T0223_Write_values()
Return (.T.)


/*{Protheus.doc} FieldPreVld
@type method
@author afedorova
@version P12 R8
@since 19.06.2019
@description Method that is called by the MVC occur when the pre validation action of the Field.
    the function deletes lines in the grid and clears the fields
    if the user decides to change the currency
*/
Method FieldPreVld(oSubModel, cModelID, cAction, cId, xValue) Class RU06T02EventRUS
Local oModelVirt	as Object
Local oModelF60		as Object
Local cAlias		as Character
Local lGoOn			as Logical
local oModelPR		as Object
Local lRet			as Logical
Local nOperation	as Numeric
Local lSuppExist	as Logical
Local aFldsToClean 	as Array
local dDateToRecalc as date
local nx            as Numeric
local oView         as Object
Local nValue        as Numeric

lRet:=.T.
lGoOn:=.F.
nx := 0

If cModelID=="RU06T02_MHEAD" .or. cModelId=="RU06T02_MVIRT"
    oModelVirt:=oSubModel:GetModel():GetModel("RU06T02_MVIRT")
    oModelF60:=oSubModel:GetModel():GetModel("RU06T02_MHEAD")

    If cId == "F60_CURREN"
        dDateToRecalc := oModelF60:GetValue("F60_DTPLA")
    ElseIF cId == "F60_DTPLA"
        dDateToRecalc := xValue
    EndIf

    If cId == "F60_CURREN" .and. !EMPTY(oModelF60:GetValue('F60_DTPLA'))
        If cAction=="SETVALUE" .AND. cModelID=="RU06T02_MHEAD"
                cAlias:="F60"
                aFldsToClean:={"F60_CURNAM","F60_BNKPAY", "F60_PAYBIK","F60_PAYACC", "F60_BKPNAM","F60_ACPNAM", "F60_PAYNAM", "F60_INIBAL","F60_VALUE","F60_BALANC" }
                lGoOn:=.T.
        EndIf

        If lGoOn .and. cAction == "SETVALUE" .and. !EMPTY(oModelF60:GetValue('F60_BNKPAY')) .AND. IIF(EMPTY(oModelF60:GetValue('F60_CURREN')), xValue != M->F60_CURREN, xValue != oModelF60:GetValue('F60_CURREN'))
            If MsgNoYes(STR0095, STR0094)
                RU06XFUN01_CleanFlds(aFldsToClean) // Load "" (empty) value to each field from the array
                oModelVirt:DelAllLine()
            Else
                lRet:=.F.
            EndIf
        EndIf
    EndIf

    If cId == "F60_DTPLA" .AND. cAction=="SETVALUE" .AND. cModelID=="RU06T02_MHEAD"
        oView := FWViewActive()
        For nX := 1 To oModelVirt:Length()
            oModelVirt:GoLine(nX)
            If F47->(DbSeek(oModelVirt:GetValue('B_FILIAL')+oModelVirt:GetValue('B_CODREQ')))
                oModelPR := FwLoadModel("RU06D04")
                oModelPR:SetOperation(4)
                If oModelF60:GetValue("F60_CURREN")=='01'
                    RU06D0401_RecalcCurrency(.T., @oModelPR, 1, dDateToRecalc )
                EndIf

                oModelPR:Activate()
                nValue := oModelPR:GetModel("RU06D04_MHEAD"):GetValue("F47_VALUE")
                oModelVirt:LoadValue("B_VALUE", nValue)
                oModelVirt:LoadValue("B_DTPLAN", dDateToRecalc)
                oModelPR:DeActivate()
            EndIf
        Next nX
        If ValType(oView) == "O" .And. oView:IsActive() .AND. !isblind()
            oView:Refresh()
        EndIf
    EndIf
EndIf

Return (lRet)

/*{Protheus.doc} ModelPosVld
@type method
@author akharchenko
@version P12 R8
@since 19.06.2020
@description Method that is called by the MVC occur when the pos validation shares of the Model
*/
Method ModelPosVld(oModel, cModelID) Class RU06T02EventRUS
Local lRet          as Logical
Local nOperation    as Numeric
Local oModelDetail  as Object
Local cHeadCurr     as Character
Local cLineCurr     as Character
Local nLines        as Numeric
Local nX            as Numeric

lRet := .T.
nOperation := oModel:GetOperation() 
oModelDetail := oModel:GetModel("RU06T02_MVIRT")
cHeadCurr := oModel:GetModel("RU06T02_MHEAD"):GetVAlue("F60_CURREN")

nLines := oModelDetail:Length()
For nX := 1 To nLines
    oModelDetail:GoLine(nX)
    cLineCurr := oModelDetail:GetValue("B_CURREN", nX)
    If(!oModelDetail:IsDeleted() .AND. cLineCurr != cHeadCurr) .AND. (nOperation == 3 .Or. nOperation == 4)
        lRet := .F.
        nX := nLines
    EndIf
Next nX

If lRet == .F.
    Help(,,STR0096,,STR0097,1,0,,,,,,)
EndIf

Return lRet