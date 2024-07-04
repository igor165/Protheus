#INCLUDE "APWEBEX.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PWSANONI.CH"
#INCLUDE "FILEIO.CH"

Web Function PWSANONI()

Local cHtml := ""
Local oObj

WEB EXTENDED INIT cHtml

	oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHCURRICULUM"), WSRHCURRICULUM():New()) // WSRHCURRICULUM():New()
	IF oObj <> NIL
		WsChgURL(@oObj,"RHCURRICULUM.APW")

		If !Empty(HttpPost->cCurricCpf)
			HttpSession->cCurricCpf 	:= HttpPost->cCurricCpf
			HttpSession->cCurricPass 	:= HttpPost->cCurricPass
		EndIf

		If !Empty( HttpSession->cCurricCpf )
			If oObj:GetCurriculum( "MSALPHA", HttpSession->cCurricCpf, HttpSession->cCurricPass, 2 )

				HttpSession->GetCurriculum 	:= {oObj:oWSGetCurriculumRESULT:oWSCURRIC1}
				HttpSession->GETTABLES 		:= {oObj:oWSGetCurriculumRESULT:oWSCURRIC2}

				if empty(HttpPost->cNome) .and. empty(HttpPost->cEmail) .and. empty(HttpPost->cObsAnoni)
					cHtml += ExecInPage( "PWSANONI" ) // pagina de solicitacao
				else
					//Web Service
					oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSANONIMIZA"), WSANONIMIZA():New())
					IF oObj <> NIL 
						WsChgURL( @oObj, "ANONIMIZA.APW" )
			
						//Parametros
						oObj:cNome			:= HttpPost->cNome
						oObj:cEmail			:= HttpPost->cEmail
						oObj:cObservacao	:= HttpPost->cObsAnoni
						oObj:cCPF			:= HttpSession->cCurricCpf

						HttpSession->cTitulo := STR0001
						HttpSession->cMensagem := ""

						if oObj:PutSolic()
							HttpSession->cMensagem := STR0016
						else
							HttpSession->cMensagem := STR0017
						endif

						cHtml += ExecInPage( "ANONIMSG" )
					else
						cHtml += ExecInPage( "PWSXERRO" )
					EndIf
				endif
			Else
				HttpSession->cCurricCpf := ""
				cHtml += ExecInPage( "PWSLOGIN" )
			EndIf
		Else
			HttpSession->cCurricCpf := ""
			cHtml += ExecInPage( "PWSLOGIN" )
		EndIf
	else
		cHtml += ExecInPage( "PWSXERRO" )
	EndIf
WEB EXTENDED END

Return cHtml



Web Function PWSLOGIN()
	Local cHtml := ""
	Local oObj
	Local oObjCfg
	Public	cPaisLoc

	WEB EXTENDED INIT cHtml

		If Empty(HttpSession->GetCurriculum)
			oObjCfg := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
			IF oObjCfg <> NIL
				WsChgUrl(@oObjCfg,"CFGDICTIONARY.apw")
				oObjCfg:GETPARAM( "MSALPHA", "MV_PAISLOC" )
				cPaisLoc:=oObjCfg:cGETPARAMRESULT

				oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHCURRICULUM"), WSRHCURRICULUM():New())
				IF oObj <> NIL
					WsChgURL(@oObj,"RHCURRICULUM.APW")

					cHtml += ExecInPage( "PWSLOGIN" )
				EndIf
			else
				cHtml += ExecInPage( "PWSXERRO" )
			EndIf
		Else
			W_PWSANONI()
		EndIf
	WEB EXTENDED END
Return cHtml
