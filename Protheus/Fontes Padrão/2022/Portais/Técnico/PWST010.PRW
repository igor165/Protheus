#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"

//**********************************************************************
Web Function PWST011()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage( "PWST011" )

WEB EXTENDED END

Return cHtml


//**********************************************************************
Web Function PWST012()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage( "PWST012" )

WEB EXTENDED END

Return cHtml


//**********************************************************************
Web Function PWST013()

Local cHtml := ""
Local oObj

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSUSERPRESENTATION():New()

WsChgURL( @oObj, "USERPRESENTATION.apw" )

If Empty( HttpSession->PWST013INFO )
	HttpSession->PWST013INFO := { Nil, Nil }
EndIf

If ExistBlock('PEGETPRES')
	HttpSession->PWST013INFO[1] := execBlock('PEGETPRES', .f., .f., {4, GetUsrCode()})
ElseIf oObj:GETPRESENTATION()
	HttpSession->PWST013INFO[1] := oObj:cGETPRESENTATIONRESULT
EndIf

If oObj:GETDAILYNEWS()
	HttpSession->PWST013INFO[2] := oObj:oWSGETDAILYNEWSRESULT
EndIf

If oObj:GETPHOTO()
	HttpSession->_IMG_INST := oObj:cGETPHOTORESULT
EndIf

cHtml += ExecInPage( "PWST013" )

WEB EXTENDED END

Return cHtml