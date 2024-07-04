#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"

//--------------------------------------------------------------------------------------------------------------------
Web Function PWSF011()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage( "PWSF011" )

WEB EXTENDED END

Return cHtml


//--------------------------------------------------------------------------------------------------------------------
Web Function PWSF012()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage( "PWSF012" )

WEB EXTENDED END

Return cHtml


//--------------------------------------------------------------------------------------------------------------------
Web Function PWSF013()

Local cHtml := ""
Local oObj

WEB EXTENDED INIT cHtml START "InSite"

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSUSERPRESENTATION"), WSUSERPRESENTATION():New())

WsChgURL( @oObj, "USERPRESENTATION.apw" )

If Empty( HttpSession->PWSF013INFO )
	HttpSession->PWSF013INFO := { Nil, Nil }
EndIf

If ExistBlock('PEGETPRES')
	HttpSession->PWSF013INFO[1] := execBlock('PEGETPRES', .f., .f., {2, GetUsrCode()})
ElseIf oObj:GETPRESENTATION()
	HttpSession->PWSF013INFO[1] := oObj:cGETPRESENTATIONRESULT
EndIf

If oObj:GETDAILYNEWS()
	HttpSession->PWSF013INFO[2] := oObj:oWSGETDAILYNEWSRESULT
EndIf

If oObj:GETPHOTO()
	HttpSession->_IMG_INST := oObj:cGETPHOTORESULT
EndIf

cHtml += ExecInPage( "PWSF013" )

WEB EXTENDED END

Return cHtml
