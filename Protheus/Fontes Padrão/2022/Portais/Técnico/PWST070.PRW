#INCLUDE "PWST070.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWST070   ºAutor  ³Luiz Felipe Couto    º Data ³  22/03/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função para chamar Grid de Produtos com a busca		       º±±
±±º          ³ Catalogo de produtos                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Portal Protheus                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºCleber M. ³19/10/06³102449³-Correcao para exibir na tela de busca so-   º±±
±±º          ³        ³      ³mente os campos necessarios.                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWST070()

Local cHtml 	:= ""
Local oObj 		:= WSMTPRODUCT():New()
Local oIndex 	:= WSCFGDICTIONARY():New()
Local aWebCols 	:= {}

Private cMsg := ""
Private aJsGrid := {}

WEB EXTENDED INIT cHtml START "InSite"

WsChgUrl( @oObj, "MTPRODUCT.APW" )
WsChgUrl( @oIndex, "CFGDICTIONARY.APW" )

If Empty( HttpSession->PWST070HEADER )
	HttpSession->PWST070HEADER := { NIL, NIL }

	If oObj:GETHEADER( "PRODUCTVIEW" )
		HttpSession->PWST070HEADER[1] := oObj:oWSGETHEADERRESULT:OWSBRWHEADER
	Else
		cMsg := PWSGetWSError()
	EndIf
	
	If oIndex:GETHEADER()
		HttpSession->PWST070HEADER[2] := oIndex:oWSGETHEADERRESULT:OWSBRWHEADER
	Else
		cMsg := PWSGetWSError()
	EndIf
EndIf

If Empty( HttpSession->PWST070INDEX )
	HttpSession->PWST070INDEX := {}
	
	If oIndex:GETINDEX( GetUsrCode(), "SB1" )
		HttpSession->PWST070INDEX := oIndex:oWSGETINDEXRESULT:oWSGENERICSTRUCT
	Else
		cMsg := PWSGetWSError()
	EndIf
EndIf

If Empty( HttpSession->PWST070INFO )
	HttpSession->PWST070INFO := { {}, {} }

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de Entrada - Campos do WS WSMTPRODUCT³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock( "PET070" )
		aWebCols := ExecBlock( "PET070", .F., .F., {1} )
	Else
		aAdd( aWebCols, "PRODUCTCODE" )
		aAdd( aWebCols, "DESCRIPTION" )
		aAdd( aWebCols, { "GROUPOFPRODUCT", "N", { "GETGROUPOFPRODUCT", ;
													{ "CGROUPOFPRODUCT", "CGROUPCODE" } }, ;
												{ "CGROUPCODE", "CDESCRIPTION" } } )
		aAdd( aWebCols, { "TYPEOFPRODUCT", "N", { "GETTYPEOFPRODUCT", ;
													{ "CTYPEOFPRODUCT", "CCODE" } }, ;
												{ "CCODE", "CDESCRIPTION" } } )	
	EndIf
	
	//aGrid,aHeader,aWebCols
	GridHeader( HttpSession->PWST070INFO[1], HttpSession->PWST070HEADER[1], aWebCols )
	
	//aGrid, aHeader, aValores, aWebCols, lInputs, cHtmlArray, cSuffixStr, nJsParam
	GridLinesEX( { HttpSession->PWST070INFO[1], ;
				HttpSession->PWST070HEADER[1], ;
				MTPRODUCT_PRODUCTVIEW():New(), ;
				aWebCols, .T., "A",,0 } )
	
	aWebCols := {}
                                             
	If ExistBlock( "PET070" )
		aWebCols := ExecBlock( "PET070", .F., .F., {2} )
	EndIf
	
	//aGrid,aHeader,aWebCols
	GridHeader( HttpSession->PWST070INFO[2], HttpSession->PWST070HEADER[2], aWebCols )
	
	GridLinesEX( { HttpSession->PWST070INFO[2], ;
				HttpSession->PWST070HEADER[2], ;
				HttpSession->PWST070INDEX, ;
				aWebCols, .F., "A",,0 } )
EndIf

HttpSession->PWST070RESULT := {}
HttpSession->PWST070BRW := {}
HttpSession->_030TEMPCTR := "1"

If !Empty( HttpPost->CPRODUCTCODE ) .OR. !Empty( HttpPost->CDESCRIPTION ) .OR. ;
	!Empty( HttpPost->CDESCRIPTION ) .OR. !Empty( HttpPost->CTYPEOFPRODUCT ) .OR. ;
	!Empty( HttpPost->CGROUPOFPRODUCT )
	HttpSession->_030TEMPCTR := ""
	
	//cUSERCODE,cTYPEOFPRODUCTIN,cGROUPOFPRODUCTIN,cPRODUCTCODELIKE,cDESCRIPTIONLIKE,nPAGELEN,nPAGEFIRST,cQUERYADDWHERE,cINDEXKEY
	If oObj:GETCATALOG( GetUsrCode(), HttpPost->CTYPEOFPRODUCT, HttpPost->CGROUPOFPRODUCT, IIf( !Empty( HttpPost->CPRODUCTCODE ), HttpPost->CPRODUCTCODE, "" ), IIf( !Empty( HttpPost->CDESCRIPTION ), HttpPost->CDESCRIPTION, "" ), 50, 0, "", IIf( !Empty( HttpPost->CINDEX ), HttpPost->CINDEX, ) )
		HttpSession->PWST070RESULT := oObj:oWSGETCATALOGRESULT:OWSPRODUCTVIEW
	Else
		Return PWSHTMLALERT( "", STR0001, "", "W_PWST070.APW" )//"Erro"
	EndIf
EndIf

If !Empty( HttpSession->PWST070RESULT )
                                                      
	If ExistBlock( "PET070" )
		aWebCols := ExecBlock( "PET070", .F., .F., {3} )
	EndIf

	GridHeader( HttpSession->PWST070BRW, HttpSession->PWST070HEADER[1], aWebCols )
	
	GridLinesEX( { HttpSession->PWST070BRW, ;
				HttpSession->PWST070HEADER[1], ;
				HttpSession->PWST070RESULT, ;
				aWebCols,.F.,"A",,0 } )
EndIf

cHtml += ExecInPage( "PWST070" )

WEB EXTENDED END

Return cHtml


//**********************************************************************
// Função para chamar os detalhes do produto selecionado
Web Function PWST071()

Local cHtml := ""
Local oObj := WSMTPRODUCT():New()
Local aWebCols := {}

WEB EXTENDED INIT cHtml START "InSite"

WsChgUrl( @oObj, "MTPRODUCT.apw" )

If Val(HttpPost->radio) <= 0
	cHtml += W_PWST071()
Else
	If Empty( HttpSession->PWST071HEADER )
		HttpSession->PWST071HEADER := { {}, {}, {} }
	EndIf

	If Empty( HttpSession->PWST071HEADER[1] )
		If oObj:GETHEADER( "PRODUCTVIEW" )
			HttpSession->PWST071HEADER[1] := oObj:oWSGETHEADERRESULT:OWSBRWHEADER
		Else
			cMsg := PWSGetWSError()
		EndIf
	EndIf

	If Empty( HttpSession->PWST071HEADER[2] )
		If oObj:GETHEADER( "PRICEVIEW" )
			HttpSession->PWST071HEADER[2] := oObj:oWSGETHEADERRESULT:OWSBRWHEADER
		Else
			cMsg := PWSGetWSError()
		EndIf
	EndIf

	If Empty( HttpSession->PWST071HEADER[3] )
		If oObj:GETHEADER( "INVENTORYVIEW" )
			HttpSession->PWST071HEADER[3] := oObj:oWSGETHEADERRESULT:OWSBRWHEADER
		Else
			cMsg := PWSGetWSError()
		EndIf
	EndIf
	
	HttpSession->PWST071INFO := { {}, {}, {} }
         
	If ExistBlock( "PET071" )
		aWebCols := ExecBlock( "PET071", .F., .F., {1} )
	EndIf

	GridLinesEX( { HttpSession->PWST071INFO[1], ;
				HttpSession->PWST071HEADER[1], ;
				HttpSession->PWST070RESULT[ Val( HttpPost->radio ) ], ;
				aWebCols, .F., "H",,0 } )
		
	If oObj:GETPRICE( GetUsrCode(), HttpSession->PWST070RESULT[ Val( HttpPost->radio ) ]:cPRODUCTCODE )
		
		aWebCols := {}
		
		If ExistBlock( "PET071" )
			aWebCols := ExecBlock( "PET071", .F., .F., {2} )
		EndIf
		
		GridHeader(	HttpSession->PWST071INFO[2], HttpSession->PWST071HEADER[2], aWebCols )

		GridLinesEX( { HttpSession->PWST071INFO[2], ;
					HttpSession->PWST071HEADER[2], ;
					oObj:oWSGETPRICERESULT:OWSPRICEVIEW, aWebCols,.F.,"A",,0 } )
	Else
		Return PWSHTMLALERT( "", STR0001, "", "W_PWST070.APW" )//"Erro"
	EndIf
	
	If oObj:GETIMAGE( GetUsrCode(), HttpSession->PWST070RESULT[ Val( HttpPost->radio ) ]:cPRODUCTCODE )
		HttpSession->_IMG_PROD := oObj:cGETIMAGERESULT
	Else
		Return PWSHTMLALERT( "", STR0001, "", "W_PWST070.APW" )//"Erro"
	EndIf
	
	If oObj:GETSTOCK( GetUsrCode(), HttpSession->PWST070RESULT[ Val( HttpPost->radio ) ]:cPRODUCTCODE, HttpSession->PWST070RESULT[ Val( HttpPost->radio ) ]:cSTANDARDWAREHOUSE )
		aWebCols := {}
                                                              
		If ExistBlock( "PET071" )
			aWebCols := ExecBlock( "PET071", .F., .F., {3} )
		EndIf

		GridHeader(	HttpSession->PWST071INFO[3], HttpSession->PWST071HEADER[3], aWebCols )

		GridLinesEX( { HttpSession->PWST071INFO[3], ;
					HttpSession->PWST071HEADER[3], oObj:oWSGETSTOCKRESULT:OWSINVENTORYVIEW,;
					aWebCols,.F.,"A",,0 } )
	Else
		Return PWSHTMLALERT( "", STR0001, "", "W_PWST070.APW" )//"Erro"
	EndIf

	cHtml += ExecInPage( "PWST071" )

EndIf

WEB EXTENDED END

Return cHtml

//**********************************************************************
Web Function PWST071A()

Local cHtml := "'

WEB EXTENDED INIT cHtml START "InSite"

cHtml := ExecInPage( "PWST071A" )

WEB EXTENDED END

Return cHtml