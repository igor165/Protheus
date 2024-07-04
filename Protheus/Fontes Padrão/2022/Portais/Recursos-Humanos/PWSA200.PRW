#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
#INCLUDE "PWSA200.CH"

Web Function PWSA200()
	Local cHtml   	:= ""
	Private cLinkSelf:= "W_PWSA200A.APW"
	Private cLinkTeam:= "W_PWSA200B.APW"
	
	HttpCTType("text/html; charset=ISO-8859-1")	
	
	WEB EXTENDED INIT cHtml START "InSite"
		fGetInfRotina("W_PWSA070TEXTO.APW")
			    
		cHtml := ExecInPage("PWSA200")
	WEB EXTENDED END
Return cHtml

Web Function PWSA200A()
	Local cHtml:= ""
	Local oOrg      
	Private nPageTotal:= 1
	Private cLinkAction		:= "W_PWSA201.APW?ParticipantID="+ HttpSession->cParticipantID
	Private oEmployee := ""
	Private cTitle	  := STR0025 //"Meu curriculo"

	HttpCTType("text/html; charset=ISO-8859-1")
	
	WEB EXTENDED INIT cHtml START "InSite"	              
		oOrg  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSORGSTRUCTURE"), WSORGSTRUCTURE():New())
		WsChgURL(@oOrg,"ORGSTRUCTURE.APW")  	
		If !Empty(HTTPSession->Login)
			oOrg:cParticipantID	:= HTTPSession->Login
		Else
			oOrg:cParticipantID	:= HttpSession->cParticipantID
		EndIf
	  //oOrg:cParticipantID	:= HttpSession->cParticipantID
	  oOrg:cVision		:= HttpSession->aInfRotina:cVisao
	  oOrg:cEmployeeFil	:= HttpSession->aUser[2]
		If ValType(HttpSession->RHMat) != "U" .And. !Empty(HttpSession->RHMat)
			oOrg:cRegistration	:= HttpSession->RHMat
		EndIf	
		
		If oOrg:GetEmployee()
			If len(oOrg:oWSGetEmployeeResult:oWSLISTOFEMPLOYEE:oWSDataEmployee) > 0
				oEmployee := oOrg:oWSGetEmployeeResult:oWSLISTOFEMPLOYEE:oWSDataEmployee[1]
			EndIf
		Else
			HttpSession->_HTMLERRO := {"Erro", PWSGetWSError(), "W_PWSA000.APW" }	//"Erro"
			Return ExecInPage("PWSAMSG" )	
		EndIf
				    
		cHtml := ExecInPage("PWSA200A")	
	WEB EXTENDED END
Return cHtml

Web Function PWSA200B()
	Local cHtml   	:= ""
	Local oOrg
	Local nCountX
	Private nPageTotal:= 1
	Private cLinkAction		:= "W_PWSA201.APW"
	Private aEmployees		:= {}
	Private oCurrentEmployee
	Private bParams			:= { |oEmployee| "?ParticipantID="+ oEmployee:cParticipantID }
	
	HttpCTType("text/html; charset=ISO-8859-1")
	
	WEB EXTENDED INIT cHtml START "InSite"	              
	 	Default HttpGet->Page:= "1"
	 	Default HttpGet->FilterField:= ""
		Default HttpGet->FilterValue:= ""
		Default HttpGet->ParticipantID:= HttpSession->cParticipantID

	 	nCurrentPage:= Val(HttpGet->Page)

		oOrg  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSORGSTRUCTURE"), WSORGSTRUCTURE():New())
		WsChgURL(@oOrg,"ORGSTRUCTURE.APW")  	

	   	oOrg:cParticipantID	:= HttpGet->ParticipantID
	   	oOrg:cVision			:= HttpSession->aInfRotina:cVisao
		oOrg:cFilterField   	:= HttpGet->FilterField
		oOrg:cFilterValue		:= HttpGet->FilterValue	
		oOrg:nPage		 	:= nCurrentPage
		If ValType(HttpSession->RHMat) != "U" .And. !Empty(HttpSession->RHMat)
			oOrg:cRegistration	:= HttpSession->RHMat
		EndIf	
		
		If oOrg:GetStructure()		
			nPageTotal := oOrg:oWSGetStructureResult:nPagesTotal
			For nCountX:= 1 To Len(oOrg:oWSGetStructureResult:oWSLISTOFEMPLOYEE:oWSDataEmployee)
				IF oOrg:oWSGetStructureResult:oWSLISTOFEMPLOYEE:oWSDataEmployee[nCountX]:cParticipantID != HttpGet->ParticipantID
					AAdd(aEmployees, oOrg:oWSGetStructureResult:oWSLISTOFEMPLOYEE:oWSDataEmployee[nCountX])
				Else
					If oOrg:oWSGetStructureResult:oWSLISTOFEMPLOYEE:oWSDataEmployee[nCountX]:cParticipantID != HttpSession->cParticipantID
						oCurrentEmployee:= oOrg:oWSGetStructureResult:oWSLISTOFEMPLOYEE:oWSDataEmployee[nCountX]
					EndIf
				EndIf
			Next
		Else
			HttpSession->_HTMLERRO := {"Erro", PWSGetWSError(), "W_PWSA000.APW" }	//"Erro"
			Return ExecInPage("PWSAMSG" )	
		EndIf
				    
		cHtml := ExecInPage("PWSA200B")	
	WEB EXTENDED END
Return cHtml

Web Function PWSA201()
	Local cHtml 	:= ""
	Local oParam	:= ""
	Local oObj		:= ""
	Local cCodVis	:= ""

	Private cLinkBack := "W_PWSA200.APW"
	
	WEB EXTENDED INIT cHtml START "InSite"
		oParam  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
		WsChgURL(@oParam, "CFGDICTIONARY.APW")
		
		If oParam:GetParam("MSALPHA", "MV_APDVIS")
			cCodVis := oParam:cGETPARAMRESULT
		EndIf
		
		oObj  := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHEmployedCurriculum"), WSRHEmployedCurriculum():New())
		WsChgURL(@oObj, "RHEMPLOYEDCURRICULUM.APW")	

		oObj:cUserCode		:= "MSALPHA"
		oObj:cParticipantID	:= HttpGet->ParticipantID
		oObj:cVision		:= cCodVis
	
		If oObj:GetParticipant()
		    HttpSession->aUsuario := {	oObj:oWSGETPARTICIPANTRESULT:CREGISTRATION,;
										oObj:oWSGETPARTICIPANTRESULT:CNAME,;
										oObj:oWSGETPARTICIPANTRESULT:CFILIAL,;
										oObj:oWSGETPARTICIPANTRESULT:CEVALUATORNAME,;
										oObj:oWSGETPARTICIPANTRESULT:DLASTUPDATE,;
										oObj:oWSGETPARTICIPANTRESULT:CCODMENTOR,;
										oObj:oWSGETPARTICIPANTRESULT:CMENTORNAME,;
										oObj:oWSGETPARTICIPANTRESULT:CHIERARQLEVEL,;
										oObj:oWSGETPARTICIPANTRESULT:CAREA}
		Else
			HttpSession->_HTMLERRO := {"Erro", PWSGetWSError(), cLinkBack}
	 		Return ExecInPage("PWSAMSG")
		EndIf
	
		If oObj:BrwItemTypes("MSALPHA", HttpGet->ParticipantID)
			HttpSession->aMenu := oObj:oWSBRWITEMTYPESRESULT:oWSITENSMENU
		Else
			HttpSession->_HTMLERRO := {"Erro", PWSGetWSError(), cLinkBack}
	 		Return ExecInPage("PWSAMSG" )
		EndIf
		
		HttpSession->cPartAcesso := {HttpGet->ParticipantID, IIF(HttpGet->ParticipantID == HttpSession->cParticipantID, "1", "2")}
	
		cHtml += ExecInPage("PWSA073")
	WEB EXTENDED END	
Return cHtml
