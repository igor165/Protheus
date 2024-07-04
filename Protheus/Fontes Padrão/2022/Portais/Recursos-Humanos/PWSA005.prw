#Include 'Protheus.ch'
#INCLUDE "APWEBEX.CH"
#INCLUDE "PWSA005.CH"

#DEFINE cCodUser "MSALPHA"


Web Function PWSA005()

Local cHtml		:= ""
Local oParam	:= ""
Local oWs

WEB EXTENDED INIT cHtml START "InSite"

oWs := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSRHPERSONALDESENVPLAN"), WSRHPERSONALDESENVPLAN():NEW())
WsChgURL(@oWs,"RHPERSONALDESENVPLAN.APW")

HttpSession->cTitlePage		:= STR0001 //"Definição de Periodo"
HttpSession->cTipo			:= HttpGet->cTipo
HttpSession->cOpc			:= HttpGet->cOpc
HttpSession->cFunc			:= HttpGet->cFunc
HttpSession->aPeriodos		:= {}
If HttpGet->cTipo=='2'
	HttpSession->cTitleH2		:= STR0002 //"Plano de Metas"
Else
	HttpSession->cTitleH2		:= STR0003 //"Plano de Desenvolvimento"
EndIf

oWs:cUserCode		:= cCodUser
oWs:cParticipantId	:= HttpSession->cParticipantID
oWs:cOrdenTipo		:= '3'
oWs:cTipOrdem		:= '1'
oWs:cPlano			:= HttpSession->cTipo
oWs:cOpc			:= HttpSession->cOpc
HttpSession->cErro	:= ""
if oWs:MyPlans()
	HttpSession->aPeriodos:= oWs:oWSMYPLANSRESULT:OWSPERIOD
Else
	HttpSession->cErro:= PWSGetWSError() //"Dados Inválidos"
	
EndIf

cHtml := ExecInPage( "PWSA005" )

WEB EXTENDED END

Return cHtml


