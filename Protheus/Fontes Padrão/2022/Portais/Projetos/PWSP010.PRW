#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"

Web Function PWSP010()//

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage( "PWSP010" )

WEB EXTENDED END

Return cHtml

//-------------------------------------------------------------------------------------------------------------------------
Web Function PWSP011()//

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage( "PWSP011" )

WEB EXTENDED END

Return cHtml


//-------------------------------------------------------------------------------------------------------------------------
Web Function PWSP012()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage( "PWSP012" )

WEB EXTENDED END

Return cHtml


//-------------------------------------------------------------------------------------------------------------------------
Web Function PWSP013()

Local cHtml := ""
Local oObj

WEB EXTENDED INIT cHtml START "InSite"

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSUSERPRESENTATION' ), WSUSERPRESENTATION():New() )
WsChgURL( @oObj, "USERPRESENTATION.apw" )

If Empty( HttpSession->PWSP013INFO )
	HttpSession->PWSP013INFO := { Nil, Nil }
EndIf

If oObj:GETPRESENTATION()
	HttpSession->PWSP013INFO[1] := oObj:cGETPRESENTATIONRESULT
EndIf

If oObj:GETDAILYNEWS()
	HttpSession->PWSP013INFO[2] := oObj:oWSGETDAILYNEWSRESULT
EndIf

If oObj:GETPHOTO()
	HttpSession->_IMG_INST := oObj:cGETPHOTORESULT
EndIf

cHtml += ExecInPage( "PWSP013" )

WEB EXTENDED END

Return cHtml
