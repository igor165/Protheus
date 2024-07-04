#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"

//-------------------------------------------------------------------------------------------------------
Web Function PWSQ011()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage( "PWSQ011" )

WEB EXTENDED END

Return cHtml


//-------------------------------------------------------------------------------------------------------
Web Function PWSQ012()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage( "PWSQ012" )

WEB EXTENDED END

Return cHtml


//-------------------------------------------------------------------------------------------------------
Web Function PWSQ013()

Local cHtml := ""
Local oObj

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSUSERPRESENTATION():New()

WsChgURL( @oObj, "USERPRESENTATION.apw" )

If Empty( HttpSession->PWSQ013INFO )
	HttpSession->PWSQ013INFO := { Nil, Nil }
EndIf

If oObj:GETPRESENTATION()
	HttpSession->PWSQ013INFO[1] := oObj:cGETPRESENTATIONRESULT
EndIf

If oObj:GETDAILYNEWS()
	HttpSession->PWSQ013INFO[2] := oObj:oWSGETDAILYNEWSRESULT
EndIf

If oObj:GETPHOTO()
	HttpSession->_IMG_INST := oObj:cGETPHOTORESULT
EndIf

cHtml += ExecInPage( "PWSQ013" )

WEB EXTENDED END

Return cHtml