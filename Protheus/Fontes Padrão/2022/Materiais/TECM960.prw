#include 'protheus.ch'
#INCLUDE "RESTFUL.CH"
#INCLUDE "TECM960.CH"

WSRESTFUL SMApportionmentProgram DESCRIPTION STR0001 //"Gera as programações de Rateio"
	//SM = Service Management
    WSMETHOD POST Main ;
    DESCRIPTION STR0002; //"Gera as programações de rateio da O.S"
    WSSYNTAX "/api/tec/v1/SMApportionmentProgram/" ;
    PATH "/api/tec/v1/SMApportionmentProgram"

ENDWSRESTFUL

/*

{
	"employees": ["D MG 01 000146", "D MG 01 000147"],
	"startDate": "2019-04-01",
	"endDate": "2019-04-30",
	"competence":"2019-05",
	"overwrite":1,
	"operation": 1,
	"log":1
}

OU

{
	"employeeFrom": "D MG 01 000146",
	"employeeTo":"D MG 01 000147",
	"startDate": "2019-04-01",
	"endDate": "2019-04-30",
	"competence":"2019-05",
	"overwrite":1,
	"operation": 1,
	"log":1
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
WSMETHOD POST Main WSSERVICE SMApportionmentProgram

	Local lRet 			:= .T.    
	Local cBody 		:= ""
	Local oOppJson 		:= NIL
	Local nCodTec		:= AA1->(TamSx3("AA1_CODTEC")[1])
	Local cEmployeeFrom := Space(nCodTec)
	Local cEmployeeTo 	:= Replicate("Z", nCodTec)
	Local aEmployees 	:= {}
	Local dStarDate		:= Ctod("")
	Local dEndDate		:= Ctod("")
	Local cCompt 		:=""
	Local nProc 		:= 0
	Local nGerLg 		:= 0
	Local aParams 		:= {}
	Local nStatus		:= 0
	Local nC 			:= 0
	Local cMsg 			:= ""
	Local uVale 		:= NIL
	Local aParGet := { {;	
							"employees", ;
							{|x| ValType(x) == "A" .AND. Len(x) > 0 },;
							"Expecting a list or a range of employees <employees;employeeFrom;employeeTo>", ;
							{|x| aEmployees := x, AADD(aParams, {"MV_PAR01", cEmployeeFrom}), AADD(aParams, {"MV_PAR02", cEmployeeTo})},;
							 {|| .T.} ;
						},;
					   {;	
					   		"employeeFrom", ;
					   		{|x| ValType(x) == "C" },;
					   		"Expecting a list or a range of employees <employees;employeeFrom;employeeTo>", ;
					   		{|x| cEmployeeFrom := x, AADD(aParams, {"MV_PAR01", cEmployeeFrom})} , ;
					   		{|| Len(aEmployees) > 0};
					   	 },;
					   {;
					   		"employeeTo",;
					   		{|x| ValType(x) == "C" },;
					   		"Expecting a list or a range of employees <employees;employeeFrom;employeeTo>",; 
					   		{|x| cEmployeeTo := x, AADD(aParams, {"MV_PAR02", cEmployeeTo})} ,;
					   		 {|| Len(aEmployees) > 0} ;
					   	},;
					   {;
					   		"startDate",;
					   		{|x| ValType(StoD(StrTran(x, "-"))) == "D" .AND. !Empty(StoD(StrTran(x, "-"))) },;
					   		'Expecting <startDate> attribute', ;
					   		{|x| dStarDate := StoD(StrTran(x, "-")), AADD(aParams, {"MV_PAR03", dStarDate}) } , ;
					   		{|| .F.} ;
					   	},;
					   {	;
					   		"endDate",;
					   		{|x| ValType(StoD(StrTran(x, "-"))) == "D" .AND. !Empty(StoD(StrTran(x, "-"))) },;
					   		'Expecting <endDate> attribute',;
					   		{|x| dEndDate := StoD(StrTran(x, "-")) , AADD(aParams, {"MV_PAR04", dEndDate})} ,;
					   		{|| .F.} ;
					   	},;
					   {;
					   		"competence",;
					   		{|x| ValType(StoD(StrTran(x, "-")+"01")) == "D" .AND. !Empty(StoD(StrTran(x, "-")+"01")) },;
					   		'Expecting <competence> attribute',;
					   		{|x| x := StrTran(x, "-"),  cCompt := Right(x,2)+"/"+ Left(x,4),  AADD(aParams, {"MV_PAR05", cCompt})},;
					   		{|| .F.};
					   	},;
					   {;
					   		"overwrite",;
					   		{|x| ValType(x) == "N" .AND. x > 0 .AND. x < 3 },;
					   		'Expecting <overwrite> attribute', ;
					   		{|x| nSobrR := x, AADD(aParams, {"MV_PAR06", nSobrR})} , ;
					   		{|| .F.} ;
					   	},;
					    {;
					    	"operation",;
					    	{|x| ValType(x) == "N" .AND. x > 0 .AND. x < 3 },;
					    	'Expecting <operation> attribute', ;
					    	{|x| nProc := x, AADD(aParams, {"MV_PAR07", nProc})} , ;
					    	{|| .F.} ;
					    },;
					   {;	
					   		"log",;
					   		{|x| ValType(x) == "N" .AND. x > 0 .AND. x < 3 },;
					   		'Expecting <log> attribute', ;
					   		{|x| nGerLg := x, AADD(aParams, {"MV_PAR08", nGerLg})},;
					   		{|| .F.}  ;
					   	};
					 }
	
	Self:SetContentType("application/json")
	cBody := Self:GetContent()

	If !Empty(cBody)
	
		FWJsonDeserialize(cBody,@oOppJson)
		
		For nC := 1 to Len(aParGet)
			If AttIsMemberOf(oOppJson,aParGet[nC, 01])// .AND.  (nPos := aScan(aParJson, {|j| j == aParGet[nC, 01] }) ) > 0 
				uValue := &("oOppJson:"+aParGet[nC, 01])
				If !EVal( aParGet[nC, 02], uValue)
					lRet := .F.
					cMsg += "attribute <" +aParGet[nC, 01] + ">  has not a valid value:" + AllTrim(cValtoChar(uValue)) + CRLF //Aqui o CRLF já vem no formato Json
				Else
					EVal( aParGet[nC, 04], uValue)
				EndIf
			ElseIf !(Eval(aParGet[nC, 05]))

				lRet := .F.
				cMsg += aParGet[nC, 03]+ CRLF //Aqui o CRLF já vem no formato Json
			EndIf
		
		Next nC

		FreeObj(oOppJson)
		
		If !lRet 
			nStatus := 400
			cMsg := Left(cMsg, Len(cMsg)-Len(CRLF)) //Aqui o CRLF já vem no formato Json
			SetRestFault(nStatus, EncodeUTF8(cMsg))
		Else
			aRet := TECA960(.T., aParams, aEmployees)

			If (lRet := aRet[1])
				nStatus := 200
			Else
				nStatus := 400
			EndIf
			
			If !EMPTY(aRet[2])
				For nC := 1 To LEN(aRet[2])
					cMsg := StrTran(StrTran(aRet[2][nC], "\", "\\"), CRLF, "\r\n")
					If nC <> LEN(aRet[2])
						cMsg += "\r\n"
					EndIf
				Next nX
			EndIf
			
			If Empty(cMsg)
				cMsg := "OK"
			EndIf
			
			cMsg := EncodeUTF8(cMsg)

			If lRet
				HTTPSetStatus(nStatus, cMsg)
			Else
				SetRestFault(nStatus, cMsg)
			EndIf
			
		EndIf
	Else
		nStatus := 400
		SetRestFault(nStatus, EncodeUTF8("POST operation without content"))
		lRet := .F.
	EndIf
Return lRet