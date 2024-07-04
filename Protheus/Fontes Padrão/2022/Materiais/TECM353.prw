#include 'protheus.ch'
#INCLUDE "RESTFUL.CH"

WSRESTFUL SMInsalubrity DESCRIPTION "Envio de adicionais de periculosidade e insalubridade"
	//SM = Service Management
    WSMETHOD POST Main ;
    DESCRIPTION "Envio de adicionais de periculosidade e insalubridade";
    WSSYNTAX "/api/tec/v1/SMInsalubrity/" ;
    PATH "/api/tec/v1/SMInsalubrity"

ENDWSRESTFUL

/*
{
	"employees": ["D MG 01 000001", "D MG 01 000002", "D MG 01 000003"],
	"startDate": "2019-04-01",
	"endDate": "2019-04-30",
	"referenceDate": "2019-04-15",
	"operation": 1,
	"logType": 1
}

OU

{
	"employeeFrom": "              ",
	"employeeTo": "ZZZZZZZZZZZZZZZ"
	"startDate": "2019-04-01",
	"endDate": "2019-04-30",
	"referenceDate": "2019-04-15",
	"operation": 1,
	"logType": 1
}
*/

WSMETHOD POST Main WSSERVICE SMInsalubrity
	Local cEmployeeFrom := Space(TamSx3("AA1_CODTEC")[1])
	Local cEmployeeTo := Replicate("Z", TamSx3("AA1_CODTEC")[1])
	Local cBody
	Local oOppJson
	Local lRet := .T.
	Local dStarDate
	Local dEndDate
	Local dReferenceDate
	Local aParams := {}
	Local aEmployees := {}
	Local aRet := {}
	Local nX
	Local cMsgs := ""
	Local nStatus := 200
	
	cBody := Self:GetContent()
	If !Empty(cBody)
		FWJsonDeserialize(cBody,@oOppJson)
		Self:SetContentType("application/json")
		
		If AttIsMemberOf(oOppJson,"employees") .AND. VALTYPE(oOppJson:employees) == 'A'
			aEmployees := oOppJson:employees
			AADD(aParams, {"MV_PAR01", cEmployeeFrom})
			AADD(aParams, {"MV_PAR02", cEmployeeTo})
		Else
			If AttIsMemberOf(oOppJson,"employeeFrom") .AND. AttIsMemberOf(oOppJson,"employeeTo")
				cEmployeeFrom := oOppJson:employeeFrom
				cEmployeeTo := oOppJson:employeeTo
				AADD(aParams, {"MV_PAR01", cEmployeeFrom})
				AADD(aParams, {"MV_PAR02", cEmployeeTo})
			Else
				SetRestFault( 400, EncodeUTF8("Expecting a list or a range of employees <employees;employeeFrom;employeeTo>") )      
				lRet := .F.
			EndIf
		EndIf
		
		If lRet
			If AttIsMemberOf(oOppJson,"startDate")
				dStarDate := STOD(STRTRAN(oOppJson:startDate,'-'))
				AADD(aParams, {"MV_PAR03", dStarDate})
			Else
				SetRestFault(400, EncodeUTF8('Expecting <startDate> attribute'))
				lRet := .F.
			EndIf
		EndIf
		
		If lRet
			If AttIsMemberOf(oOppJson,"endDate")
				dEndDate := STOD(STRTRAN(oOppJson:endDate,'-'))
				AADD(aParams, {"MV_PAR04", dEndDate})
			Else
				SetRestFault(400, EncodeUTF8('Expecting <endDate> attribute'))
				lRet := .F.
			EndIf
		EndIf
		
		If lRet
			If AttIsMemberOf(oOppJson,"referenceDate")
				dReferenceDate := STOD(STRTRAN(oOppJson:referenceDate,'-'))
				AADD(aParams, {"MV_PAR05", dReferenceDate})
			Else
				SetRestFault(400, EncodeUTF8('Expecting <referenceDate> attribute'))
				lRet := .F.
			EndIf
		EndIf
		
		If lRet
			If AttIsMemberOf(oOppJson,"operation")
				AADD(aParams, {"MV_PAR06", oOppJson:operation})
			Else
				SetRestFault(400, EncodeUTF8('Expecting <operation> attribute'))
				lRet := .F.
			EndIf
		EndIf
		
		If lRet
			If AttIsMemberOf(oOppJson,"logType")
				AADD(aParams, {"MV_PAR07", oOppJson:logType})
			Else
				SetRestFault(400, EncodeUTF8('Expecting <logType> attribute'))
				lRet := .F.
			EndIf
		EndIf
		
		If lRet
			aRet := TECA353(.T., aParams, aEmployees)
			If (lRet := aRet[1])
				nStatus := 200
			Else
				nStatus := 400
			EndIf
			
			If !EMPTY(aRet[2])
				For nX := 1 To LEN(aRet[2])
					cMsgs += aRet[2][nX]
					If nX <> LEN(aRet[2])
						cMsgs += "##"
					EndIf
				Next nX
			EndIf
			
			If Empty(cMsgs)
				cMsgs := "OK"
			EndIf
			cMsgs := EncodeUTF8(StrTran(StrTran(cMsgs, "\", "\\"), "####", "##"))
			If lRet 
				HTTPSetStatus(nStatus, cMsgs)
			Else
				SetRestFault(nStatus, cMsgs)
			EndIf
		EndIf
	Else
		SetRestFault(400, EncodeUTF8("POST operation without content"))
	EndIf
Return lRet