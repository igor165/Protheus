#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"

//**********************************************************************
// Função para chamar Grid de Produtos com a busca
Web Function PWST090()

Local cHtml := ""
Local oObjIntBase
Local aWebHeader := {}

Private cMsg := ""
Private aJsGrid := {}

WEB EXTENDED INIT cHtml START "InSite"

oObjIntBase := WSFSINSTALLBASE():New()
WsChgUrl( @oObjIntBase, "FSINSTALLBASE.APW" )

If Empty( HttpSession->HEADER90_1 )
	If oObj:GETHEADER( "PRODUCTVIEW" )
		HttpSession->HEADER90_1[1] := oObj:oWSGETHEADERRESULT:OWSBRWHEADER
	Else
		cMsg := PWSGetWSError()
	EndIf
	
	If oIndex:GETHEADER()
		HttpSession->HEADER90_1[2] := oIndex:oWSGETHEADERRESULT:OWSBRWHEADER
	Else
		cMsg := PWSGetWSError()
	EndIf
EndIf

If Empty( HttpSession->PWST090INDEX )
	HttpSession->PWST090INDEX := {}
	
	If oIndex:GETINDEX( GetUsrCode(), "SB1" )
		HttpSession->PWST090INDEX := oIndex:oWSGETINDEXRESULT:oWSGENERICSTRUCT
	Else
		cMsg := PWSGetWSError()
	EndIf
EndIf

If Empty( HttpSession->PWST090INFO )
	HttpSession->PWST090INFO := { {}, {} }

	aAdd( aWebHeader, "PRODUCTCODE" )
	aAdd( aWebHeader, "DESCRIPTION" )
	aAdd( aWEBHeader, { "GROUPOFPRODUCT", "N", { "GETGROUPOFPRODUCT", ;
														{ "CGROUPOFPRODUCT", "CGROUPCODE" };
													}, ;
													{ "CGROUPCODE", "CDESCRIPTION" } } )
	aAdd( aWebHeader, { "TYPEOFPRODUCT", "N", { "GETTYPEOFPRODUCT", ;
														{ "CTYPEOFPRODUCT", "CCODE" };
													}, ;
													{ "CCODE", "CDESCRIPTION" } } )
	
	//aGrid,aHeader,aWebCols
	GridHeader( HttpSession->PWST090INFO[1], HttpSession->HEADER90_1[1], aWebHeader )
	
	//aGrid, aHeader, aValores, aWebCols, lInputs, cHtmlArray, cSuffixStr, nJsParam
	GridLinesEX( { HttpSession->PWST090INFO[1], ;
				HttpSession->HEADER90_1[1], ;
				MTPRODUCT_PRODUCTVIEW():New(), ;
				aWebHeader, .T., "A",,0 } )
	
	aWebHeader := {}
	
	aAdd( aWebHeader, "CODE" )
	aAdd( aWebHeader, "DESCRIPTION" )
	
	//aGrid,aHeader,aWebCols
	GridHeader( HttpSession->PWST090INFO[2], HttpSession->HEADER90_1[2], aWebHeader )
	
	GridLinesEX( { HttpSession->PWST090INFO[2], ;
				HttpSession->HEADER90_1[2], ;
				HttpSession->PWST090INDEX, ;
				aWebHeader, .F., "A",,0 } )
EndIf

HttpSession->PWST090RESULT := {}
HttpSession->PWST090BRW := {}
HttpSession->_030TEMPCTR := "1"

If !Empty( HttpPost->CPRODUCTCODE ) .OR. !Empty( HttpPost->CDESCRIPTION ) .OR. ;
	!Empty( HttpPost->CDESCRIPTION ) .OR. !Empty( HttpPost->CTYPEOFPRODUCT ) .OR. ;
	!Empty( HttpPost->CGROUPOFPRODUCT )
	HttpSession->_030TEMPCTR := ""
	
	//cUSERCODE,cTYPEOFPRODUCTIN,cGROUPOFPRODUCTIN,cPRODUCTCODELIKE,cDESCRIPTIONLIKE,nPAGELEN,nPAGEFIRST,cQUERYADDWHERE,cINDEXKEY
	If oObj:GETCATALOG( GetUsrCode(), HttpPost->CTYPEOFPRODUCT, HttpPost->CGROUPOFPRODUCT, IIf( !Empty( HttpPost->CPRODUCTCODE ), HttpPost->CPRODUCTCODE, "" ), IIf( !Empty( HttpPost->CDESCRIPTION ), HttpPost->CDESCRIPTION, "" ), 50, 0, "", IIf( !Empty( HttpPost->CINDEX ), HttpPost->CINDEX, ) )
		HttpSession->PWST090RESULT := oObj:oWSGETCATALOGRESULT:OWSPRODUCTVIEW
	Else
		Return PWSHTMLALERT( "", "Erro", "", "W_PWST090.APW" )
	EndIf
EndIf

If !Empty( HttpSession->PWST090RESULT )
	aadd( aWebHeader, "PRODUCTCODE" )
	aadd( aWebHeader, "DESCRIPTION" )

	GridHeader( HttpSession->PWST090BRW, HttpSession->HEADER90_1[1], aWebHeader )
	
	GridLinesEX( { HttpSession->PWST090BRW, ;
				HttpSession->HEADER90_1[1], ;
				HttpSession->PWST090RESULT, ;
				aWEBHeader,.F.,"A",,0 } )
EndIf

cHtml += ExecInPage( "PWST090" )

WEB EXTENDED END

Return cHtml


//**********************************************************************
// Função para chamar os detalhes do produto selecionado
Web Function PWST091()

Local cHtml := ""
Local oObj := WSMTPRODUCT():New()
Local aWebHeader := {}

WEB EXTENDED INIT cHtml START "InSite"

WsChgUrl( @oObj, "MTPRODUCT.apw" )

If Val(HttpPost->radio) <= 0
	cHtml += W_PWST091()
Else
	If Empty( HttpSession->PWST091HEADER )
		HttpSession->PWST091HEADER := { {}, {}, {} }
	EndIf

	If Empty( HttpSession->PWST091HEADER[1] )
		If oObj:GETHEADER( "PRODUCTVIEW" )
			HttpSession->PWST091HEADER[1] := oObj:oWSGETHEADERRESULT:OWSBRWHEADER
		Else
			cMsg := PWSGetWSError()
		EndIf
	EndIf

	If Empty( HttpSession->PWST091HEADER[2] )
		If oObj:GETHEADER( "PRICEVIEW" )
			HttpSession->PWST091HEADER[2] := oObj:oWSGETHEADERRESULT:OWSBRWHEADER
		Else
			cMsg := PWSGetWSError()
		EndIf
	EndIf

	If Empty( HttpSession->PWST091HEADER[3] )
		If oObj:GETHEADER( "INVENTORYVIEW" )
			HttpSession->PWST091HEADER[3] := oObj:oWSGETHEADERRESULT:OWSBRWHEADER
		Else
			cMsg := PWSGetWSError()
		EndIf
	EndIf
	
	aadd( aWebHeader, "PRODUCTCODE" )
	aadd( aWebHeader, "DESCRIPTION" )
	aadd( aWebHeader, "SCIENCEDESCRIPTION" )
	aadd( aWebHeader, "DESCRIPTIONMEASUREUNIT" )
	aadd( aWebHeader, "DESCRIPTIONSECONDMEASUREUNIT" )
	aadd( aWebHeader, "DESCRIPTIONTYPEOFPRODUCT" )
	aadd( aWebHeader, "DESCRIPTIONGROUPOFPRODUCT" )
	aadd( aWebHeader, "NCM" )
	aadd( aWebHeader, "QUANTITYPERPACKAGE" )
	aadd( aWebHeader, "ORDERPOINT" )
	aadd( aWebHeader, "NETWEIGHT" )
	aadd( aWebHeader, "GROSSWEIGHT" )
	aadd( aWebHeader, "LEADTIME" )
	aadd( aWebHeader, "TYPEOFLEADTIME" )
	aadd( aWebHeader, "ECONOMICLOT" )
	aadd( aWebHeader, "MINIMUMLOT" )
	aadd( aWebHeader, "MINIMUMGRADE" )
	aadd( aWebHeader, "TERMOFVALIDATY" )
	aadd( aWebHeader, "BARCODE" )
	aadd( aWebHeader, "STORAGELENGHT" )
	aadd( aWebHeader, "STORAGEWIDTH" )
	aadd( aWebHeader, "STORAGEHEIGHT" )
	aadd( aWebHeader, "STORAGEMAXIMUMPILING" )
	aadd( aWebHeader, "STANDARDWAREHOUSE" )
	
	HttpSession->PWST091INFO := { {}, {}, {} }

	GridLinesEX( { HttpSession->PWST091INFO[1], ;
				HttpSession->PWST091HEADER[1], ;
				HttpSession->PWST090RESULT[ Val( HttpPost->radio ) ], ;
				aWebHeader, .F., "H",,0 } )
		
	If oObj:GETPRICE( GetUsrCode(), HttpSession->PWST090RESULT[ Val( HttpPost->radio ) ]:cPRODUCTCODE )
		GridHeader(	HttpSession->PWST091INFO[2], HttpSession->PWST091HEADER[2], {} )

		GridLinesEX( { HttpSession->PWST091INFO[2], ;
					HttpSession->PWST091HEADER[2], ;
					oObj:oWSGETPRICERESULT:OWSPRICEVIEW, {},.F.,"A",,0 } )
	Else
		Return PWSHTMLALERT( "", "Erro", "", "W_PWST090.APW" )
	EndIf
	
	If oObj:GETIMAGE( GetUsrCode(), HttpSession->PWST090RESULT[ Val( HttpPost->radio ) ]:cPRODUCTCODE )
		HttpSession->_IMG_PROD := oObj:cGETIMAGERESULT
	Else
		Return PWSHTMLALERT( "", "Erro", "", "W_PWST090.APW" )
	EndIf
	
	If oObj:GETSTOCK( GetUsrCode(), HttpSession->PWST090RESULT[ Val( HttpPost->radio ) ]:cPRODUCTCODE, HttpSession->PWST090RESULT[ Val( HttpPost->radio ) ]:cSTANDARDWAREHOUSE )
		aWebHeader := {}
		
		aadd( aWebHeader, "PRODUCTCODE" )
		aadd( aWebHeader, "QUANTITY" )
		aadd( aWebHeader, "CURRENCY" )
		aadd( aWebHeader, "CURRENCYSIMBOL" )
		aadd( aWebHeader, "TYPEOFBALANCE" )
		aadd( aWebHeader, "DESCRIPTIONTYPEOFBALANCE" )
		aadd( aWebHeader, "WAREHOUSE" )

		GridHeader(	HttpSession->PWST091INFO[3], HttpSession->PWST091HEADER[3], aWebHeader )

		GridLinesEX( { HttpSession->PWST091INFO[3], ;
					HttpSession->PWST091HEADER[3], oObj:oWSGETSTOCKRESULT:OWSINVENTORYVIEW,;
					aWebHeader,.F.,"A",,0 } )
	Else
		Return PWSHTMLALERT( "", "Erro", "", "W_PWST090.APW" )
	EndIf

	cHtml += ExecInPage( "PWST091" )

EndIf

WEB EXTENDED END

Return cHtml

//**********************************************************************
Web Function PWST091A()

Local cHtml := "'

WEB EXTENDED INIT cHtml START "InSite"

cHtml := ExecInPage( "PWST091A" )

WEB EXTENDED END

Return cHtml