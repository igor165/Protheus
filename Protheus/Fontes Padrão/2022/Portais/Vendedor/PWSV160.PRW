#INCLUDE "PWSV160.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"

//-------------------------------------------------------------------------------------------------------
// Tela de Seleção de VENDEDOR
Web Function PWSV160()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

HttpPost->PWSV020VEN	:= GetUserVen()

HttpSession->PWSV020APH := { STR0001 ,;		// Titulo  //"Vendedores"
							 "W_PWSV161.APW"	,;			// Proxima Tela
							 ""	} 								// Msg de Erro

If Len( HttpPost->PWSV020VEN ) <= 1   
	HttpSession->PWSV020APH[3] := STR0002 //"Não há VENDEDORES a consultar."

	cHtml += ExecInPage( "PWSV020" )
ElseIf Len( HttpPost->PWSV020VEN ) = 2 
	// Apenas 1 VENDEDOR . Define a navegação para pular a tela de seleção de VENDEDOR
	HttpPost->CODVENERP	:= HttpPost->PWSV020VEN[2][2]

	cHtml += W_PWSV161()
Else
	// Mais de 1 VENDEDOR ? Chama tela de seleção de VENDEDORES
	cHtml += ExecInPage( "PWSV020" )
Endif

WEB EXTENDED END

Return cHtml

//-------------------------------------------------------------------------------------------------------
// Tela de Seleção de VENDEDOR
Web Function PWSV161()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

HttpSession->_CODVEN := HttpPost->CODVENERP

HttpPost->PWSC020CLI	:= GetUserCli()

HttpSession->PWSC020APH := { STR0003 ,;		// Titulo  //"Clientes"
							 "W_PWSV162.APW"	,;			// Proxima Tela
							 ""	} 								// Msg de Erro

If Len( HttpPost->PWSC020CLI ) <= 1   
	HttpSession->PWSC020APH[3] := STR0004 //"Não há CLIENTES a consultar."

	cHtml += ExecInPage( "PWSC020" )
ElseIf Len( HttpPost->PWSC020CLI ) = 2 
	// Apenas 1 CLIENTE
	HttpPost->CODCLIERP	:= HttpPost->PWSC020CLI[2][2]

	cHtml += W_PWSV162()
Else
	// Mais de 1 CLIENTE ? Chama tela de seleção de CLIENTES
	cHtml += ExecInPage( "PWSC020" )
Endif

WEB EXTENDED END

Return cHtml

/**********************************************************************
	Todos os CONTATOS
**********************************************************************/
Web Function PWSV162()

Local oObj
Local cHtml := ""
WEB EXTENDED INIT cHtml START "InSite"

HttpSession->PWSV162APH := { STR0005, ; //"Contatos"
							 "W_PWSV163.APW", ;
							 "" }

HttpSession->PWSV162INFO := { NIL, NIL }

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCRMSELLERCUSTOMERCONTACT"), WSCRMSELLERCUSTOMERCONTACT():NEW() )
WsChgUrl(@oObj,"CRMSELLERCUSTOMERCONTACT.apw")

If oObj:GETHEADER( "CONTACTVIEW" )
	HttpSession->PWSV162INFO[1] := oObj:oWSGETHEADERRESULT:oWSBRWHEADER
EndIf

If oObj:BRWCONTACT( "MSALPHA", HttpSession->_CODVEN, HttpPost->CODCLIERP )
	HttpSession->PWSV162INFO[2] := oObj:oWSBRWCONTACTRESULT:oWSCONTACTVIEW
Else
	HttpSession->PWSV162APH[3] := PWSGetWSError()
EndIf

cHtml := ExecInPage( "PWSV162" )

WEB EXTENDED END

Return cHtml

/**********************************************************************
	Dados Cadastrais dos CONTATOS
**********************************************************************/
Web Function PWSV163()

Local cHtml := ""
Local oObj := Nil, nPosVen, nPosCon
Local aV160Headers := {}
Local n := 0

WEB EXTENDED INIT cHtml START "InSite"

HttpPost->PWSV163VEN := GetUserVen()
HttpSession->_ContactInfo := { { }, { { } }, { { }, { }, { }, { } } }
HttpSession->PWSV163APH := { "", "", "" }
Httpsession->PWSV163TYPES := { NIL, NIL }

If !Empty( HttpSession->_CODVEN )
	nPosVen := ascan( HttpPost->PWSV163VEN , { |x| x[2] == HttpSession->_CODVEN } )
EndIf

If !Empty( HttpPost->CODCONTACT )
	nPosCon := ascan( HttpSession->PWSV162INFO[2], { |x| x:cCONTACTID == HttpPost->CODCONTACT } )
EndIf

If HttpPost->ACAO == "I"
	HttpSession->PWSV163APH[1] := STR0005 //"Contatos"

	oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCRMSELLERCUSTOMERCONTACT"), WSCRMSELLERCUSTOMERCONTACT():NEW() )	
	WsChgUrl(@oObj,"CRMSELLERCUSTOMERCONTACT.apw")
	
	// Busca os tipos de Endereços
	If Empty( Httpsession->PWSV163TYPES[1] )
		If oObj:GETTYPEOFADDRESS()
			Httpsession->PWSV163TYPES[1] := oObj:oWSGETTYPEOFADDRESSRESULT:oWSGENERICSTRUCT
		Else
			PWSGetWSError()
		Endif
	Endif
	
	// Busca os tipos de Telefones
	If Empty( Httpsession->PWSV163TYPES[2] )
		If oObj:GETTYPEOFPHONE()
			Httpsession->PWSV163TYPES[2] := oObj:oWSGETTYPEOFPHONERESULT:oWSGENERICSTRUCT
		Else
			PWSGetWSError()
		Endif
	Endif

	// Busca definição de Header de Informações de Cliente
	If oObj:GETHEADER( "CONTACTVIEW" ) //1
		aadd( aV160Headers, oObj:oWSGETHEADERRESULT:OWSBRWHEADER )
	Else
		aadd( aV160Headers, {} )
		PWSGetWSError()		
	Endif
	
	// Busca definição de Header de Endereços
	If oObj:GETHEADER( "ADDRESSVIEW" ) //2
		aadd( aV160Headers, oObj:oWSGETHEADERRESULT:OWSBRWHEADER )
	Else
		aadd( aV160Headers, {} )
		PWSGetWSError()		
	Endif

	// Busca definição de Header de Telefones
	If oObj:GETHEADER( "PHONEVIEW" ) //3
		aadd( aV160Headers, oObj:oWSGETHEADERRESULT:OWSBRWHEADER )
	Else
		aadd( aV160Headers, {} )
		PWSGetWSError()		
	Endif

	GridLinesEX( { HttpSession->_ContactInfo[1], aV160Headers[1], CRMSELLERCUSTOMERCONTACT_CONTACTVIEW():New(), {}, .T., "H",,0 } )
	GridLinesEX( { HttpSession->_ContactInfo[2][1], aV160Headers[2], CRMSELLERCUSTOMERCONTACT_ADDRESSVIEW():New(), {}, .T., "H", AllTrim( Str( n ) ),,0 } )
	
	For n := 1 To 4
		GridLinesEX( { HttpSession->_ContactInfo[3][n], aV160Headers[3], CRMSELLERCUSTOMERCONTACT_PHONEVIEW():New(), {}, .T., "H", AllTrim( Str( n ) ),,0 } )
	Next n
	
	cHtml += ExecInPage( "PWSV163" )
Else
	If nPosCon > 0
		HttpSession->PWSV163APH[1] := STR0006 + HttpSession->PWSV162INFO[2][nPosCon]:cNAME //"Dados Cadastrais : "
		Httpsession->PWSV163TYPES := { NIL , NIL }
		HttpSession->PWSV162INFO := { NIL , NIL , NIL , NIL }
	
		oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCRMSELLERCUSTOMERCONTACT"), WSCRMSELLERCUSTOMERCONTACT():NEW() )			
		WsChgUrl(@oObj,"CRMSELLERCUSTOMERCONTACT.apw")
	
		// Busca os tipos de Endereços
		If Empty( HttpSession->PWSV163APH[3] ) .AND. Httpsession->PWSV163TYPES[1] == NIL 
			If oObj:GETTYPEOFADDRESS()
				Httpsession->PWSV163TYPES[1] := oObj:oWSGETTYPEOFADDRESSRESULT:oWSGENERICSTRUCT
			Else
				HttpSession->PWSV163APH[3] := PWSGetWSError()
			Endif
		Endif
		
		// Busca os tipos de Telefones
		If Empty( HttpSession->PWSV163APH[3] ) .AND. Httpsession->PWSV163TYPES[2] == NIL 
			If oObj:GETTYPEOFPHONE()
				Httpsession->PWSV163TYPES[2] := oObj:oWSGETTYPEOFPHONERESULT:oWSGENERICSTRUCT
			Else
				HttpSession->PWSV163APH[3] := PWSGetWSError()
			Endif
		Endif
	
		// Busca definição de Header de Informações de Cliente
		If Empty( HttpSession->PWSV163APH[3] ) .AND. HttpSession->PWSV162INFO[1] = NIL
			If oObj:GETHEADER( "CONTACTVIEW" ) //1
				HttpSession->PWSV162INFO[1] := oObj:oWSGETHEADERRESULT:OWSBRWHEADER
			Else
				HttpSession->PWSV163APH[3] := PWSGetWSError()
			Endif
		Endif
		
		// Busca definição de Header de Endereços
		If Empty( HttpSession->PWSV163APH[3] ) .AND. HttpSession->PWSV162INFO[2] = NIL
			If oObj:GETHEADER( "ADDRESSVIEW" ) //2
				HttpSession->PWSV162INFO[2] := oObj:oWSGETHEADERRESULT:OWSBRWHEADER
			Else
				HttpSession->PWSV163APH[3] := PWSGetWSError()
			Endif
		Endif
	
		// Busca definição de Header de Telefones
		If Empty( HttpSession->PWSV163APH[3] ) .AND. HttpSession->PWSV162INFO[3] = NIL
			If oObj:GETHEADER( "PHONEVIEW" ) //3
				HttpSession->PWSV162INFO[3] := oObj:oWSGETHEADERRESULT:OWSBRWHEADER
			Else
				HttpSession->PWSV163APH[3] := PWSGetWSError()
			Endif
		Endif
	
		// Busca dados do Contato em si
		If Empty( HttpSession->PWSV163APH[3] )
			If oObj:GETCONTACT( "MSALPHA", HttpSession->_CODVEN, HttpPost->CODCONTACT )
				HttpSession->PWSV162INFO[4] := oObj:oWSGETCONTACTRESULT
			Else
				HttpSession->PWSV163APH[3] := PWSGetWSError()
			Endif
		Endif
	Endif
	
	If !Empty( HttpSession->PWSV163APH[3] )
		cHtml += ExecInPage( "PWSV162" )
	Else
		If HttpPost->ACAO == "A"
			If Len( HttpSession->PWSV162INFO[4]:OWSADDRESSES:OWSADDRESSVIEW ) == 0
				aadd( HttpSession->PWSV162INFO[4]:OWSADDRESSES:OWSADDRESSVIEW, CRMSELLERCUSTOMERCONTACT_ADDRESSVIEW():New() )
			EndIf
		
			If Len( HttpSession->PWSV162INFO[4]:OWSPHONES:OWSPHONEVIEW ) < 4
				If Len( HttpSession->PWSV162INFO[4]:OWSPHONES:OWSPHONEVIEW ) == 1
					aadd( HttpSession->PWSV162INFO[4]:OWSPHONES:OWSPHONEVIEW, CRMSELLERCUSTOMERCONTACT_PHONEVIEW():New() )
					aadd( HttpSession->PWSV162INFO[4]:OWSPHONES:OWSPHONEVIEW, CRMSELLERCUSTOMERCONTACT_PHONEVIEW():New() )
					aadd( HttpSession->PWSV162INFO[4]:OWSPHONES:OWSPHONEVIEW, CRMSELLERCUSTOMERCONTACT_PHONEVIEW():New() )
				ElseIf Len( HttpSession->PWSV162INFO[4]:OWSPHONES:OWSPHONEVIEW ) == 2
					aadd( HttpSession->PWSV162INFO[4]:OWSPHONES:OWSPHONEVIEW, CRMSELLERCUSTOMERCONTACT_PHONEVIEW():New() )
					aadd( HttpSession->PWSV162INFO[4]:OWSPHONES:OWSPHONEVIEW, CRMSELLERCUSTOMERCONTACT_PHONEVIEW():New() )
				ElseIf Len( HttpSession->PWSV162INFO[4]:OWSPHONES:OWSPHONEVIEW ) == 3
					aadd( HttpSession->PWSV162INFO[4]:OWSPHONES:OWSPHONEVIEW, CRMSELLERCUSTOMERCONTACT_PHONEVIEW():New() )
				Else
					aadd( HttpSession->PWSV162INFO[4]:OWSPHONES:OWSPHONEVIEW, CRMSELLERCUSTOMERCONTACT_PHONEVIEW():New() )
					aadd( HttpSession->PWSV162INFO[4]:OWSPHONES:OWSPHONEVIEW, CRMSELLERCUSTOMERCONTACT_PHONEVIEW():New() )
					aadd( HttpSession->PWSV162INFO[4]:OWSPHONES:OWSPHONEVIEW, CRMSELLERCUSTOMERCONTACT_PHONEVIEW():New() )
					aadd( HttpSession->PWSV162INFO[4]:OWSPHONES:OWSPHONEVIEW, CRMSELLERCUSTOMERCONTACT_PHONEVIEW():New() )
				EndIf
			EndIf

			GridLinesEX( { HttpSession->_ContactInfo[1], HttpSession->PWSV162INFO[1], HttpSession->PWSV162INFO[4], {}, .T., "H",,0 } )
			
			For n := 1 To Len( HttpSession->PWSV162INFO[4]:OWSADDRESSES:OWSADDRESSVIEW )
				GridLinesEX( { HttpSession->_ContactInfo[2][n], HttpSession->PWSV162INFO[2], HttpSession->PWSV162INFO[4]:OWSADDRESSES:OWSADDRESSVIEW[n], {}, .T., "H",,0 } )
			Next n
		
			For n := 1 To Len( HttpSession->PWSV162INFO[4]:OWSPHONES:OWSPHONEVIEW )
				GridLinesEX( { HttpSession->_ContactInfo[3][n],	HttpSession->PWSV162INFO[3], HttpSession->PWSV162INFO[4]:OWSPHONES:OWSPHONEVIEW[n], {}, .T., "H",,0 } )
			Next n
		ElseIf HttpPost->ACAO == "V"
			If Len( HttpSession->PWSV162INFO[4]:OWSADDRESSES:OWSADDRESSVIEW ) == 0
				aadd( HttpSession->PWSV162INFO[4]:OWSADDRESSES:OWSADDRESSVIEW, CRMSELLERCUSTOMERCONTACT_ADDRESSVIEW():New() )
			EndIf
		
			If Len( HttpSession->PWSV162INFO[4]:OWSPHONES:OWSPHONEVIEW ) < 4
				If Len( HttpSession->PWSV162INFO[4]:OWSPHONES:OWSPHONEVIEW ) == 1
					aadd( HttpSession->PWSV162INFO[4]:OWSPHONES:OWSPHONEVIEW, CRMSELLERCUSTOMERCONTACT_PHONEVIEW():New() )
					aadd( HttpSession->PWSV162INFO[4]:OWSPHONES:OWSPHONEVIEW, CRMSELLERCUSTOMERCONTACT_PHONEVIEW():New() )
					aadd( HttpSession->PWSV162INFO[4]:OWSPHONES:OWSPHONEVIEW, CRMSELLERCUSTOMERCONTACT_PHONEVIEW():New() )
				ElseIf Len( HttpSession->PWSV162INFO[4]:OWSPHONES:OWSPHONEVIEW ) == 2
					aadd( HttpSession->PWSV162INFO[4]:OWSPHONES:OWSPHONEVIEW, CRMSELLERCUSTOMERCONTACT_PHONEVIEW():New() )
					aadd( HttpSession->PWSV162INFO[4]:OWSPHONES:OWSPHONEVIEW, CRMSELLERCUSTOMERCONTACT_PHONEVIEW():New() )
				ElseIf Len( HttpSession->PWSV162INFO[4]:OWSPHONES:OWSPHONEVIEW ) == 3
					aadd( HttpSession->PWSV162INFO[4]:OWSPHONES:OWSPHONEVIEW, CRMSELLERCUSTOMERCONTACT_PHONEVIEW():New() )
				Else
					aadd( HttpSession->PWSV162INFO[4]:OWSPHONES:OWSPHONEVIEW, CRMSELLERCUSTOMERCONTACT_PHONEVIEW():New() )
					aadd( HttpSession->PWSV162INFO[4]:OWSPHONES:OWSPHONEVIEW, CRMSELLERCUSTOMERCONTACT_PHONEVIEW():New() )
					aadd( HttpSession->PWSV162INFO[4]:OWSPHONES:OWSPHONEVIEW, CRMSELLERCUSTOMERCONTACT_PHONEVIEW():New() )
					aadd( HttpSession->PWSV162INFO[4]:OWSPHONES:OWSPHONEVIEW, CRMSELLERCUSTOMERCONTACT_PHONEVIEW():New() )
				EndIf
			EndIf

			GridLinesEX( { HttpSession->_ContactInfo[1], HttpSession->PWSV162INFO[1], HttpSession->PWSV162INFO[4], {}, .F., "H",,0 } )
			
			For n := 1 To Len( HttpSession->PWSV162INFO[4]:OWSADDRESSES:OWSADDRESSVIEW )
				GridLinesEX( { HttpSession->_ContactInfo[2][n], HttpSession->PWSV162INFO[2], HttpSession->PWSV162INFO[4]:OWSADDRESSES:OWSADDRESSVIEW[n], {}, .F., "H",,0 } )
			Next n
		
			For n := 1 To Len( HttpSession->PWSV162INFO[4]:OWSPHONES:OWSPHONEVIEW )
				GridLinesEX( { HttpSession->_ContactInfo[3][n],	HttpSession->PWSV162INFO[3], HttpSession->PWSV162INFO[4]:OWSPHONES:OWSPHONEVIEW[n], {}, .F., "H",,0 } )
			Next n
		EndIf
		
		cHtml += ExecInPage( "PWSV163" )
	EndIf
EndIf
	
WEB EXTENDED END

Return cHtml

/**********************************************************************
	Acao dos CONTATOS
**********************************************************************/
Web Function PWSV164()

Local cHtml := ""
Local oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCRMSELLERCUSTOMERCONTACT"), WSCRMSELLERCUSTOMERCONTACT():NEW() )
Local n := 0

WEB EXTENDED INIT cHtml START "InSite"

WsChgUrl(@oObj,"CRMSELLERCUSTOMERCONTACT.apw")

PWSSetObjToPost( HttpSession->PWSV162INFO[4], HttpSession->PWSV162INFO[1], HttpPost->aPost )

For n := 1 To Len( HttpSession->PWSV162INFO[4]:OWSADDRESSES:OWSADDRESSVIEW )
	PWSSetObjToPost( HttpSession->PWSV162INFO[4]:OWSADDRESSES:OWSADDRESSVIEW[n], HttpSession->PWSV162INFO[2], HttpPost->aPost, AllTrim( Str( n ) ) )
Next n

For n := 1 To Len( HttpSession->PWSV162INFO[4]:OWSPHONES:OWSPHONEVIEW )
	PWSSetObjToPost( HttpSession->PWSV162INFO[4]:OWSPHONES:OWSPHONEVIEW[n], HttpSession->PWSV162INFO[3], HttpPost->aPost, AllTrim( Str( n ) ) )
Next n

HttpSession->PWSV162INFO[4]:OWSADDRESSES:OWSADDRESSVIEW[1]:cTYPEOFADDRESS := "1"

HttpSession->PWSV162INFO[4]:OWSPHONES:OWSPHONEVIEW[1]:cTYPEOFPHONE := "1"
HttpSession->PWSV162INFO[4]:OWSPHONES:OWSPHONEVIEW[2]:cTYPEOFPHONE := "2"
HttpSession->PWSV162INFO[4]:OWSPHONES:OWSPHONEVIEW[3]:cTYPEOFPHONE := "3"
HttpSession->PWSV162INFO[4]:OWSPHONES:OWSPHONEVIEW[4]:cTYPEOFPHONE := "4"

If HttpPost->ACAO == "A" .OR. HttpPost->ACAO == "I"
	//cUSERCODE,cCUSTOMERID,oWSCONTACTVIEW
	oObj:cUSERCODE := MYUSERCODE
	oObj:cCUSTOMERID := HttpPost->CODVENERP
	oObj:oWSCONTACTVIEW := HttpSession->PWSV162INFO[4]
	
	If oObj:PUTCONTACT()
		conout( "PUTCONTACT" )
	EndIf
EndIf

cHtml := W_PWSV160()

WEB EXTENDED END

Return cHtml