#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"

//-------------------------------------------------------------------------------------------------------------------------
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Funcao Principal ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Web Function PWSC011()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage( "PWSC011" )

WEB EXTENDED END

Return cHtml


//-------------------------------------------------------------------------------------------------------------------------
Web Function PWSC012()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage( "PWSC012" )

WEB EXTENDED END

Return cHtml


//-------------------------------------------------------------------------------------------------------------------------
Web Function PWSC013()

Local cHtml := ""
Local oObj

WEB EXTENDED INIT cHtml START "InSite"

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSUSERPRESENTATION' ), WSUSERPRESENTATION():New() )
WsChgURL( @oObj, "USERPRESENTATION.apw" )

If Empty( HttpSession->PWSC013INFO )
	HttpSession->PWSC013INFO := { Nil, Nil }
EndIf

If ExistBlock('PEGETPRES')
	HttpSession->PWSC013INFO[1] := execBlock('PEGETPRES', .f., .f., {1, GetUsrCode()})
ElseIf oObj:GETPRESENTATION()
	HttpSession->PWSC013INFO[1] := oObj:cGETPRESENTATIONRESULT
EndIf

If oObj:GETDAILYNEWS()
	HttpSession->PWSC013INFO[2] := oObj:oWSGETDAILYNEWSRESULT
EndIf

If oObj:GETPHOTO()
	HttpSession->_IMG_INST := oObj:cGETPHOTORESULT
EndIf

cHtml += ExecInPage( "PWSC013" )

WEB EXTENDED END

Return cHtml
