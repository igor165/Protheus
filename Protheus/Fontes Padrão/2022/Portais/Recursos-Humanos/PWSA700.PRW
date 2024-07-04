#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
#INCLUDE "PWSA700.CH"

#DEFINE CODUSUARIO		"MSALPHA"

/*
{Protheus.doc} PWSA700
Cnosulta de Avalição Finalizada.
@author	Leandro Drumond
@since 19/06/2016
*/
Web Function PWSA700()

Local cHtml   		:= ""

HttpCTType("text/html; charset=ISO-8859-1")

WEB EXTENDED INIT cHtml START "InSite"

	oParam	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
	WsChgURL(@oParam,"CFGDICTIONARY.APW")
	HttpSession->cCposCabec := ""
	If oParam:GETPARAM( CODUSUARIO, "MV_CPOSCAB" )
		If !Empty(oParam:cGETPARAMRESULT)  .AND. oParam:cGETPARAMRESULT != ".F."
			HttpSession->cCposCabec := oParam:cGETPARAMRESULT
		EndIf
	EndIf                                      
	//Se não existir o parâmetro ou não foi informado nenhum campo, 
	// assumir todos os campos para apresentação
	If Empty(HttpSession->cCposCabec)
		HttpSession->cCposCabec := "123456789A"
	EndIf

	HttpSession->RdAvaliador 	:= "N"
	HttpSession->RdAvaliado  	:= "S"
	HttpSession->FilterCodAva	:= ""
	HttpSession->FilterCodDor	:= ""
	HttpSession->Consulta		:= "N"
	HttpSession->OpenWindow 	:= "N"
		 
	cHtml := ExecInPage("PWSA700")

WEB EXTENDED END

Return cHtml

Web Function PWSA700A()

Local cHtml := "" 
Local oObj

Private aConsulta 	:= {}
Private aSelAva		:= {}
Private aSelDor		:= {}

HttpCTType("text/html; charset=ISO-8859-1")

WEB EXTENDED INIT cHtml START "InSite"

 	DEFAULT HttpGet->FilterDor		:= "N"
 	DEFAULT HttpGet->FilterAdo		:= "S"
	DEFAULT HttpGet->Consulta 		:= "N"
	DEFAULT HttpGet->Carrega 		:= "S"
	DEFAULT HttpGet->FilterCodAva	:= ""
	DEFAULT HttpGet->FilterCodAdo	:= ""
	DEFAULT HttpGet->FilterCodDor	:= ""
	DEFAULT HttpGet->DateFrom		:= ""
	DEFAULT HttpGet->Project		:= ""
	DEFAULT HttpGet->TipoAv			:= ""
	DEFAULT HttpGet->Link			:= ""	
	
	HttpSession->OpenWindow := "N"
	HttpSession->Consulta := HttpGet->Consulta
	
	If !Empty(HttpGet->Link)
		HttpSession->Consulta := "S"
		HttpSession->Consulta := "S"
		HttpSession->cTpAval  := HttpGet->TipoAv
		HttpSession->cStatus  := "2"
		aConsulta 	:= HttpSession->aConsulta
		aSelAva		:= HttpSession->aSelAva
		aSelDor		:= HttpSession->aSelDor
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERFORMANCEEVALUATE"), WSRHPERFORMANCEEVALUATE():New())
		WsChgURL(@oObj,"RHPERFORMANCEEVALUATE.APW")
	
		If oObj:GETPEVALUATE(CODUSUARIO, HttpGet->FilterCodAdo, HttpGet->FilterCodAva, HttpGet->FilterCodDor, HttpGet->TipoAv,,,,, CToD(HttpGet->DateFrom), HttpGet->Project )
			HttpSession->GETPEVALUATE := oObj:oWSGETPEVALUATERESULT:oWSEVALUATELIST
			If len(HttpSession->GETPEVALUATE[1]:oWsListOfCompetence:oWsCompetences) == 0
				HttpSession->_HTMLERRO := { STR0001, STR0002, "W_PWSA700.APW" } //"eRRO ### Não existem questões cadastradas para a avaliação atual."
				Return ExecInPage("PWSAMSG" )
			EndIf
		Else
			HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA700.APW" }			//"Erro"
			Return ExecInPage("PWSAMSG" )
		EndIf
		HttpSession->OpenWindow := "S"
		HttpSession->Link := HttpGet->Link
		
		nPos := aScan(aConsulta,{|x| x:cCodAdo == HttpGet->FilterCodAdo .and. x:cCodDor == HttpGet->FilterCodDor .and. x:cCodAva == HttpGet->FilterCodAva})
		If Empty(aConsulta[nPos]:cNome)
			aConsulta[nPos]:cNome := STR0003 //"Nome não disponível"
			If HttpSession->GetPEvaluate[1]:cCoachName == HttpSession->GetPEvaluate[1]:cEvaluatorName
				HttpSession->GetPEvaluate[1]:cCoachName := HttpSession->GetPEvaluate[1]:cEvaluatorName :=  aConsulta[nPos]:cNome //Altera o nome do avaliador e mentor
			Else
				HttpSession->GetPEvaluate[1]:cEvaluatorName :=  aConsulta[nPos]:cNome //Altera o nome do avaliador
			EndIf
		EndIf
		Return ExecInPage("PWSA700B")		
	EndIf

	If HttpGet->Carrega == "N"
		Return ExecInPage("PWSA700B")
	EndIf

	oWSEvaluate := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHEvaluate"), WSRHEvaluate():New())
	WsChgURL(@oWSEvaluate, "RHEvaluate.APW")
	oWSEvaluate:cBranch			:= HttpSession->AUSER[2] //Filial
	oWSEvaluate:cParticipant	:= HttpSession->CPARTICIPANTID //Participante
	
	If HttpGet->Consulta == "N"
		oWSEvaluate:cEvaluator		:= HttpGet->FilterDor
		
		//Busca margem de crédito
		If !oWSEvaluate:ViewEvaluate()
			HttpSession->_HTMLERRO := { "Erro", PWSGetWSError(), "W_PWSA700.APW" }
			Return ExecInPage("PWSAMSG" )
		Else
			HttpSession->aSelAva := aSelAva := oWSEvaluate:oWSViewEvaluateResult:oWSItens:oWSTEvaluateList
			
			If Empty(HttpGet->FilterCodAva)
				HttpSession->FilterCodAva := aSelAva[1]:cCod
			Else
				HttpSession->FilterCodAva := HttpGet->FilterCodAva 
			EndIf
			
			If HttpGet->FilterDor == "S" .and. !Empty(HttpSession->FilterCodAva)
				oWSEvaluate:cEvaluation := HttpSession->FilterCodAva
				If !oWSEvaluate:ViewEvaluator()
					HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA700.APW" } //Erro:
					Return ExecInPage("PWSAMSG" )
				Else
					HttpSession->aSelDor := aSelDor := oWSEvaluate:oWSViewEvaluatorResult:oWSItens:oWSTEvaluateList
					If Empty(HttpGet->FilterCodAdo)	
						HttpSession->FilterCodAdo := aSelDor[1]:cCod
					Else
						HttpSession->FilterCodAdo := HttpGet->FilterCodAdo
					EndIf
					HttpSession->RdAvaliador := "S"
					HttpSession->RdAvaliado  := "N"
				EndIf
			Else
				HttpSession->RdAvaliador := "N"
				HttpSession->RdAvaliado  := "S"		
				aSelDor := {}
			EndIf
			
			If HttpGet->Consulta  == "N"
				cHtml := ExecInPage("PWSA700A")
			Else
				cHtml := ExecInPage("PWSA700B")
			EndIf
		EndIf
	Else
		oWSEvaluate:cEvaluator		:= HttpGet->FilterCodAdo
		oWSEvaluate:cEvaluation 	:= HttpGet->FilterCodAva

		If !oWSEvaluate:AllEvaluate()
			HttpSession->_HTMLERRO := { STR0001, PWSGetWSError(), "W_PWSA700.APW" } //"Erro"
			Return ExecInPage("PWSAMSG" )
		Else
			HttpSession->aConsulta := aConsulta := oWSEvaluate:oWSAllEvaluateResult:oWSItens:oWSTEvaluateAllList
			cHtml := ExecInPage("PWSA700B")
		EndIf		
	EndIf

WEB EXTENDED END

Return cHtml
