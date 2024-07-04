#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
#INCLUDE "PWSR030.CH"

#DEFINE PAGE_LENGTH 10
/*************************************************************/


/*************************************************************/
/* Agenda do Candidato - Tela de Login			    		 */
/*************************************************************/
Web Function PWSR030()	//RHCurriculum -> GetSchedule

	Local cHtml := ""
	Local oObj   
	Local oObjCfg                                            

	Private	cTtlLogin	:= STR0003 //'Agenda do Candidato'
	Private nCurrentPage

	HttpSession->nPageLength	:= PAGE_LENGTH

	If Empty(HttpSession->GetCurriculum) .OR. Empty(HttpSession->GetCurriculum[1]:cCurriculum)
		WEB EXTENDED INIT cHtml
			oObjCfg := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
			WsChgUrl(@oObjCfg,"CFGDICTIONARY.apw")
			oObjCfg:GETPARAM( "MSALPHA", "MV_PAISLOC" )
			cPaisLoc:=oObjCfg:cGETPARAMRESULT
			
			oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHCURRICULUM"), WSRHCURRICULUM():New())
			WsChgURL(@oObj,"RHCURRICULUM.APW")     
			
			cHtml += ExecInPage("PWSR030")

		WEB EXTENDED END
	Else
		W_PWSR030A()	
	EndIf	

Return cHtml

Web Function PWSR030A()	//RHCurriculum -> GetSchedule

	Local cHtml := ""
	Local oObj
	Local oObjCurr
	Local lLoginOk	:= .F. 	

	HttpSession->nPageLength	:= PAGE_LENGTH
	HttpSession->FiltroVagas	:= ''
	HttpSession->FiltroField	:= ''
	HttpSession->aSchedule		:= {}
	
	HttpCTType("text/html; charset=ISO-8859-1")

	WEB EXTENDED INIT cHtml
			
		oObjCurr := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHCURRICULUM"), WSRHCURRICULUM():New())
		WsChgURL(@oObjCurr,"RHCURRICULUM.APW")
			
		If Empty(HttpSession->GetCurriculum)
			If !Empty(HttpPost->cCurricCpf)

				HttpSession->cCurricCpf 	:= DECODE64(HttpPost->cCurricCpf)
				HttpSession->cCurricPass 	:= DECODE64(HttpPost->cCurricPass)

				If oObjCurr:GetCurriculum( "MSALPHA", HttpSession->cCurricCpf, HttpSession->cCurricPass, 2 )
					HttpSession->GetCurriculum 	:= {oObjCurr:oWSGetCurriculumRESULT:oWSCURRIC1}
					HttpSession->GETTABLES 		:= {oObjCurr:oWSGetCurriculumRESULT:oWSCURRIC2}
					lLoginOk	:= .T.
				Else
					lLoginOk	:= .F.
					HttpSession->cCurricCpf := ""
					Return RHALERT( "", STR0001, STR0008, "W_PWSR020A.APW" ) //"Portal Candidato"###"CPF ou Senha invalido."
				EndIf
			Else
				lLoginOk	:= .F.
				HttpSession->cCurricCpf := ""
				Return RHALERT( " ", STR0001, STR0009, "W_PWSR020A.APW" ) //"Portal Candidato"###"CPF deve ser informado."
			EndIf
		Else
			If oObjCurr:GetCurriculum( "MSALPHA", HttpSession->cCurricCpf, HttpSession->cCurricPass, 3 )
				HttpSession->GetCurriculum	:= {oObjCurr:oWSGetCurriculumRESULT:oWSCURRIC1}
				HttpSession->GETTABLES 		:= {oObjCurr:oWSGetCurriculumRESULT:oWSCURRIC2}
				lLoginOk	:= .T.
			Else
				lLoginOk	:= .F.
				HttpSession->GetCurriculum := {}
				Return RHALERT( " ", STR0001, STR0018, "W_PWSR020A.APW" ) //"Curriculo nao encontrado"
			EndIf
		EndIf
			                      	
		If lLoginOk				
			oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHCURRICULUM"), WSRHCURRICULUM():New())
			WsChgURL(@oObj,"RHCURRICULUM.APW")
		    
			Default HttpSession->aSchedule := {}
			Default HttpGet->Page:= "1"	 	
		 	nCurrentPage:= Val(HttpGet->Page)
						
			oObj:cCurricCode 	:= Alltrim(HttpSession->GetCurriculum[1]:cCurriculum)
			oObj:nCurrentPage 	:= nCurrentPage
			
			If !Empty(HttpPost->cFilterValue)
				oObj:cFilterValue			:= HttpPost->cFilterValue
				oObj:cFilterField			:= HttpPost->cFilterField
				HttpSession->FiltroVagas	:= HttpPost->cFilterValue
				HttpSession->FiltroField	:= HttpPost->cFilterField 
			EndIf
			
			If oObj:GetSchedule()				
				HttpSession->aSchedule	:= oObj:oWsGetScheduleResult:oWsListOfRequest:oWsTSCheduleRequest				
				HttpSession->nPageTotal	:= oObj:oWsGetScheduleResult:nPagesTotal
				
				
				If !Empty(HttpPost->cCurrentPage)
					If Val(HttpPost->cCurrentPage) > 0 .AND. Val(HttpPost->cCurrentPage) <= HttpSession->nPageTotal 
						HttpSession->nCurrentPage	:= Val(HttpPost->cCurrentPage)
						HttpSession->CurrentPage	:= HttpSession->nCurrentPage
					Else
						HttpSession->nCurrentPage	:= HttpSession->CurrentPage
					EndIf
				Else
					HttpSession->nCurrentPage	:= 1	
				EndIf
				
			Else
				HttpSession->_HTMLERRO := { STR0025, PWSGetWSError(), "W_PWSR030.APW" }	//"Erro"
				Return ExecInPage("PWSAMSG" )
			EndIf				
	
			cHtml := ExecInPage( "PWSR030A" )
		Else
			conout( PWSGetWSError() )			
		EndIf

	WEB EXTENDED END			

Return cHtml

Web Function PWSR031()	//RHCurriculum -> GetActivity

	Local cHtml := ""
	Local oObj

	HttpSession->aSchedule	:= {} 

	WEB EXTENDED INIT cHtml
		
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHCURRICULUM"), WSRHCURRICULUM():New())
		WsChgURL(@oObj,"RHCURRICULUM.APW")
		
		oObj:cCurricCode 	:= Alltrim(HttpSession->GetCurriculum[1]:cCurriculum)
		oObj:cVacancyCode 	:= Alltrim(HttpPost->cVacancyCode)
		
		If oObj:GetActivity()
			HttpSession->aSchedule	:= oObj:oWsGetActivityResult:oWsListOfRequest:oWsTSCheduleRequest
		Else
			HttpSession->_HTMLERRO := { STR0025, PWSGetWSError(), "W_PWSR030.APW" }	//"Erro"
			Return ExecInPage("PWSAMSG" )
		EndIf
				
		cHtml := ExecInPage( "PWSR031" )	
	WEB EXTENDED END			

Return cHtml
