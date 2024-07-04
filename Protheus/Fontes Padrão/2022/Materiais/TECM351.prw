#include 'protheus.ch'
#INCLUDE "RESTFUL.CH"

WSRESTFUL SMBenefitsToHR DESCRIPTION "Realiza o envio de benefícios ao RH"
	WSMETHOD POST Main ;
	DESCRIPTION "Realiza o envio de benefícios ao RH";
	WSSYNTAX "/api/tec/v1/SMBenefitsToHR/" ;
	PATH "/api/tec/v1/SMBenefitsToHR"

ENDWSRESTFUL


//Exemplo de implementação - INCLUSÃO
/*
{
	"contracts": ["TECC0700CT0025D"],
	"startDate": "2019-05-01",
	"endDate": "2019-06-01",
	"payrollPeriod": "201905",
	"paymentNumber": "01",
	"script" : "FOL",
	"operation": 1
}

OU

{
	"contractFrom": "TECC0700CT0025D",
	"contractTo" : "TECC0700CT0025D",
	"startDate": "2019-05-01",
	"endDate": "2019-06-01",
	"payrollPeriod": "201905",
	"paymentNumber": "1",
	"script" : "FOL"
	"operation": 1
}
*/


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} POST
@description 	Faz uma chamada do TECA351 através de uma requisição POST
@author 		diego.bezerra
@since 			08/05/2019
@return			lRet, bool, indica se a rotina processou algum registro (.T.) ou se a requisição não processou	nenhum registro ou foi invalida (.F.)
/*/
//--------------------------------------------------------------------------------------------------------------------

WSMETHOD POST Main WSSERVICE SMBenefitsToHR

	Local lRet			:= .T.    
	Local cBody
	Local oOppJson
	Local cContrFrom	:= Space(TamSx3("CN9_NUMERO")[1])
	Local cContrTo		:= Replicate("Z", TamSx3("CN9_NUMERO")[1])
	Local aContracts	:= {}
	Local dStartDate
	Local dEndDate
	Local cPayrPeriod	:= ""	//payroll period
	Local cPayNumber			//Payment Number
	Local aParams		:= {}
	Local nStatus
	Local cMsgs			:= ""
	Local nX
	
	cBody := Self:GetContent()
	
	If !Empty(cBody)
		FWJsonDeserialize(cBody,@oOppJson)
		Self:SetContentType("application/json")
		
		If AttIsMemberOf(oOppJson,"contracts") .AND. VALTYPE(oOppJson:contracts) == 'A'
			aContracts 	:= oOppJson:contracts
			AADD(aParams, {"MV_PAR01", cContrFrom})
			AADD(aParams, {"MV_PAR02", cContrTo})
		Else
			If AttIsMemberOf(oOppJson,"contractFrom") .AND. AttIsMemberOf(oOppJson,"contractTo")
				cContrFrom	:= oOppJson:contractfrom
				cContrTo	:= oOppJson:contractto
				AADD(aParams, {"MV_PAR01", cContrFrom})
				AADD(aParams, {"MV_PAR02", cContrTo})
			Else
				SetRestFault(400, EncodeUTF8('Expecting <contractFrom> AND <contractTo> attributes'))
				lRet 		:= .F.
			EndIf
		EndIf
		
		If lRet
			If AttIsMemberOf(oOppJson, "startDate")
				dStartDate	:= STOD(STRTRAN(oOppJson:startDate, '-'))
				AADD(aParams, {'MV_PAR03', dStartDate})
			Else	
				SetRestFault(400, EncodeUTF8('Expecting <startDate> attribute'))
				lRet		:= .F.
			EndIf
		EndIf
		
		If lRet
			If AttIsMemberOf(oOppJson, "endDate")
				dEndDate	:= STOD(STRTRAN(oOppJson:endDate, '-'))
				AADD(aParams, {'MV_PAR04', dEndDate})
			Else	
				SetRestFault(400, EncodeUTF8('Expecting <endDate> attribute'))
				lRet		:= .F.
			EndIf
		EndIf
		
		If lRet
			If AttIsMemberOf(oOppJson, "payrollPeriod")
				cPayrPeriod	:= oOppJson:payrollPeriod
				AADD(aParams, {'MV_PAR05', cPayrPeriod})
			Else	
				SetRestFault(400, EncodeUTF8('Expecting <payrollPeriod> attribute'))
				lRet		:= .F.
			EndIf
		EndIf
		
		If lRet
			If AttIsMemberOf(oOppJson, "paymentNumber")
				cPayNumber	:= oOppJson:paymentNumber
				AADD(aParams, {'MV_PAR06', cPayNumber})
			Else	
				SetRestFault(400, EncodeUTF8('Expecting <paymentNumber> attribute'))
				lRet		:= .F.
			EndIf
		EndIf
		
		If AttIsMemberOf(oOppJson,"script")
			AADD(aParams, {'MV_PAR07', oOppJson:script})
		Else
			AADD(aParams, {'MV_PAR07', Space(TamSx3("RGB_ROTEIR")[1])})
		EndIf
		
		If lRet
			If AttIsMemberOf(oOppJson,"operation")
				AADD(aParams, {"MV_PAR08", oOppJson:operation})
			Else
				SetRestFault(400, EncodeUTF8('Expecting <operation> attribute'))
				lRet := .F.
			EndIf
		EndIf
				
		If lRet
			aRet := TECA351(.T., aParams, aContracts)
			If (lRet := aRet[1])
				nStatus 	:= 200
			Else
				nStatus		:= 400
			EndIf
			
			If !EMPTY(aRet[2])
				For nX	:= 1 To LEN(aRet[2])
					cMsgs += aRet[2][nX]
					If nX < LEN(aRet[2])
						cMsgs += "##"
					EndIf
				Next nX
			EndIf
			
			If Empty(cMsgs)
				If oOppJson:operation == 1
					cMsgs += "Benefits successfully submitted."
				Else
					cMsgs += "Benefits successfully deleted"
				EndIf
			EndIf
			
			cMsgs := EncodeUTF8(StrTran(cMsgs,"####", "##"))
		
			If lRet
				HTTPSetStatus(nStatus, cMsgs)
			Else
				SetRestFault(400, cMsgs)
			EndIf
		EndIf
	Else
		SetRestFault(400, EncodeUTF8("POST operation without content"))
	EndIf
	
Return lRet