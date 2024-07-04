#include 'protheus.ch'
#include 'parmtype.ch'
#include 'fwmvcdef.ch'
#include 'topconn.ch'



/*/{Protheus.doc} RfrshView
Refreshes the oView object and keeps user's focus
@author Artem Kostin
@since 04/02/2018
@version P12.1.20
@type function
/*/
Function RfrshView(oView)
Local nFocus as Numeric
Default oView := FwViewActive()
If (ValType(oView) != "U")
    // Saves user's focus
    nFocus:= GetFocus()
    oView:Refresh()
    // Retores saved focus
    SetFocus(nFocus)
EndIf
Return(.T.)



/*/{Protheus.doc} CloseTempTable
Handles the closing of the temporary table.
@author Artem Kostin
@since 04/02/2018
@version P12.1.20
@type function
/*/
Function CloseTempTable(cTmpTbl as Character)
// Temporary tables aliases are global.
If !Empty(cTmpTbl) .and. (ValType(cTmpTbl) == "C")
	(cTmpTbl)->(DbCloseArea())
EndIf
Return(.T.)



/*/{Protheus.doc} F37DocFilt
Filter for the Standard Query with the alias "F37DOC"
@author Artem Kostin
@since 04/10/2018
@version P12.1.20
@type function
/*/
Function F37DocFilt()
Local dDateFin as Date
// Variables to operate with Model
Local oModel := FWModelActive()
Local oModelM as Object
// Variables for SQL queries
Local cQuery := ""
Local cTab := ""
// Variable to save result of SQL query
Local lTotal := .F.

cQuery := " SELECT SUM(F32_OPBS) AS OPEN_TOTAL"
cQuery += " FROM " + RetSQLName("F32")
cQuery += " WHERE D_E_L_E_T_ = ' '"
cQuery += " AND F32_FILIAL = '" + xFilial("F32") + "' "
cQuery += " AND F32_KEY = '" + F37->F37_KEY + "'"
cTab := MPSysOpenQuery(ChangeQuery(cQuery))
lTotal := (cTab)->OPEN_TOTAL > 0
CloseTempTable(cTab)

If oModel:GetId() == "RU09T05"
    oModelM := oModel:GetModel("F3BMASTER")
    dDateFin := oModelM:GetValue("F3B_FINAL")

    Return(;
        (YearSum(F37->F37_RDATE, 3) >= dDateFin);
        .and. (F37->F37_RDATE <= dDateFin) .and. (lTotal);
    )

ElseIf oModel:GetId() == "RU09T06"
    oModelM := oModel:GetModel("F3DMASTER")
    dDateFin := oModelM:GetValue("F3D_FINAL")
	
    Return(;
        (F37->F37_RDATE <= dDateFin);
        .and. lTotal;
    )

ElseIf oModel:GetId() == "RU09T08"
    cQuery := " SELECT SUM(F32_INIBS - F32_RESTBS) AS RESTORED_TOTAL"
    cQuery += " FROM " + RetSQLName("F32")
    cQuery += " WHERE D_E_L_E_T_ = ' '"
    cQuery += " AND F32_FILIAL = '" + xFilial("F32") + "' "
    cQuery += " AND F32_KEY = '" + F37->F37_KEY + "'"
    cTab := MPSySOPENQuery(ChangeQuery(cQuery))
    lTotal := (cTab)->RESTORED_TOTAL > 0
    CloseTempTable(cTab)

    Return(lTotal)

Else
    Return(.T.)
EndIf



Function F37DOCRet()
Local oModel := FWModelActive()

If !IsInCallStack("PERGUNTE")
    If (oModel:GetId() == "RU09T05")
        oModel:GetModel("F3CDETAIL"):SetValue("F3C_KEY", F37->F37_KEY)

    ElseIf (oModel:GetId() == "RU09T06")
        oModel:GetModel("F3EDETAIL"):SetValue("F3E_KEY", F37->F37_KEY)

    ElseIf (oModel:GetId() == "RU09T08")
        oModel:GetModel("F53DETAIL"):SetValue("F53_KEY", F37->F37_KEY)
    EndIf
EndIf

Return(F37->F37_DOC)


Function RU09XF35Ret()
Local oModel := FWModelActive()

If !IsInCallStack("PERGUNTE")
    If (oModel:GetId() == "RU09T04")
        oModel:GetModel("F3ADETAIL"):SetValue("F3A_KEY", F35->F35_KEY)
    EndIf
EndIf

Return(F35->F35_DOC)