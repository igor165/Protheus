#include 'protheus.ch'
#INCLUDE "RESTFUL.CH"

WSRESTFUL SMTimeTrack DESCRIPTION "Gera as marcações atraves do atendimento da O.S"
	//SM = Service Management
    WSMETHOD POST Main ;
    DESCRIPTION "Gera as marcações atraves do atendimento da O.S";
    WSSYNTAX "/api/tec/v1/SMTimeTrack/" ;
    PATH "/api/tec/v1/SMTimeTrack"

ENDWSRESTFUL
/*
{
	"employees": ["TEC01900000135"],
	"startDate": "2019-05-07",
	"endDate": "2019-05-08",
	"operation": 1,
	"keepShiftBreak": 1,
	"randomMinutes": 5
}

OU

{
	"employeeFrom": "TEC01900000135",
	"employeeTo": "TEC01900000135",
	"startDate": "2019-05-07",
	"endDate": "2019-05-08",
	"operation": 1,
	"keepShiftBreak": 1
}
*/

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} POST
@description 	Faz uma chamada do TECA910 através de uma requisição POST
@author 		boiani
@since 			07/05/2019
@return			lRet, bool, indica se a rotina processou algum registro (.T.) ou se a requisição não processou
				nenhum registro ou foi invalida (.F.)
/*/
//--------------------------------------------------------------------------------------------------------------------
WSMETHOD POST Main WSSERVICE SMTimeTrack

	Local lRet := .T.    
	Local cBody
	Local oOppJson
	Local cEmployeeFrom := Space(TamSx3("AA1_CODTEC")[1])
	Local cEmployeeTo := Replicate("Z", TamSx3("AA1_CODTEC")[1])
	Local aEmployees := {}
	Local dStarDate
	Local dEndDate
	Local aParams := {}
	Local nStatus
	Local cMsgs := ""
	Local nX
	
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
			If AttIsMemberOf(oOppJson,"operation")
				AADD(aParams, {"MV_PAR05", oOppJson:operation})
			Else
				SetRestFault(400, EncodeUTF8('Expecting <operation> attribute'))
				lRet := .F.
			EndIf
		EndIf
		
		If lRet
			If AttIsMemberOf(oOppJson,"keepShiftBreak")
				AADD(aParams, {"MV_PAR06", oOppJson:keepShiftBreak})
			Else
				SetRestFault(400, EncodeUTF8('Expecting <keepShiftBreak> attribute'))
				lRet := .F.
			EndIf
		EndIf
		
		If lRet .AND. TecHasPerg("MV_PAR07","TEC910") 
			If AttIsMemberOf(oOppJson,"randomMinutes")
				AADD(aParams, {"MV_PAR07", oOppJson:randomMinutes})
			EndIf
		EndIf
		
		If lRet
			aRet := TECA910(.T., aParams, aEmployees)
			If (lRet := aRet[1])
				nStatus := 200
			Else
				nStatus := 400
			EndIf
			
			If !EMPTY(aRet[2])
				For nX := 1 To LEN(aRet[2])
					cMsgs += StrTran(StrTran(aRet[2][nX], "\", "\\"), CRLF, "\r\n")
					If nX <> LEN(aRet[2])
						cMsgs += "\r\n"
					EndIf
				Next nX
			EndIf
			
			If Empty(cMsgs)
				cMsgs := "OK"
			EndIf
			
			If lRet 
				HTTPSetStatus(nStatus, EncodeUTF8(cMsgs))
			Else
				SetRestFault(nStatus, EncodeUTF8(cMsgs))
			EndIf
		EndIf
	Else
		SetRestFault(400, EncodeUTF8("POST operation without content"))
		lRet := .F.
	EndIf
Return lRet