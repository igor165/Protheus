#INCLUDE "PWST100.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"

#DEFINE TECERP_ENTIDADE		1
#DEFINE TECERP_CODIGO		2
#DEFINE TECERP_NOMEFANT		3
#DEFINE TECERP_RAZAOSOC		4
#DEFINE TECERP_CPFCNPJ		5

#DEFINE MYUSERCODE		GetUsrCode()

//**********************************************************************
Web Function PWST100()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

HttpPost->PWST100TEC	:= GetUserTec()

HttpSession->PWST100APH := {	STR0001 ,;		//"Abertura Chamado Técnico"
								"W_PWST101.APW"	,;
								""	}

If Len(HttpPost->PWST100TEC) <= 1   
	//Nao ha tecnicos a serem consultados
	HttpSession->PWST100APH[3] := STR0002		//"Não há Técnicos a consultar."
	cHtml += ExecInPage( "PWST020" )
ElseIf len(HttpPost->PWST100TEC) = 2 
	//1 tecnico a ser consultado
	HttpPost->CODTECERP	:= HttpPost->PWST100TEC[2][TECERP_CODIGO]
	cHtml += W_PWST101()
Else
	//2 ou mais tecnicos a serem consultados
	cHtml += ExecInPage( "PWST020" )
EndIf

WEB EXTENDED END

Return cHtml

//**********************************************************************
Web Function PWST101()

Local cHtml := ""
Local aWebCols := {}
Local oObj

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSFSSERVICECALL():NEW()
WsChgUrl( @oObj, "FSSERVICECALL.APW" )

If HttpPost->CODTECERP != Nil
	HttpSession->CODTECERP := HttpPost->CODTECERP
EndIf

If Empty( HttpSession->HEADER101_1 ) .Or. Empty( HttpSession->HEADER101_2 )
	HttpSession->HEADER101_1 := {}
	HttpSession->HEADER101_2 := {}
	
	If oObj:GETHEADER( "SERVICECALLHEADERVIEW" )
		HttpSession->HEADER101_1 := oObj:oWSGETHEADERRESULT:OWSBRWHEADER
	Else
		Return PWSHTMLALERT( "", STR0003, "", "W_PWST100.APW" )//"Erro"
	EndIf

	If oObj:GETHEADER( "SERVICECALLITEMVIEW" )
		HttpSession->HEADER101_2 := oObj:oWSGETHEADERRESULT:OWSBRWHEADER
	Else
		Return PWSHTMLALERT( "", STR0003, "", "W_PWST100.APW" )//"Erro"
	EndIf
EndIf

HttpSession->PWST100INFO := {}
HttpSession->PWST100RESULT := {}

If HttpPost->DataDe == Nil .Or. HttpPost->DataAte == Nil
	HttpPost->Busca := ""
	HttpPost->Tipo  := "1"

	Return ExecInPage( "PWST101" )
Else
	aWebCols := {}
	
/*	aAdd( aWebCols, "SERVICEORDERID" )
	aAdd( aWebCols, "TECHNICIANCODE" )
	aAdd( aWebCols, "SEQUENCE" )*/

	If ExistBlock( "PET101" )
		aWebCols := ExecBlock( "PET101", .F., .F., {} )
	EndIf

	GridHeader(	HttpSession->PWST100INFO, ;
					HttpSession->HEADER101_1, ;
					aWebCols )

	If Empty( HttpGet->cPagina )
		HttpGet->cPagina := "0"
	EndIf

	oObj:cUSERCODE			:= "MSALPHA"
	oObj:dREGISTERDATEFROM	:= CToD( HttpPost->DataDe )
	oObj:dREGISTERDATETO	:= CToD( HttpPost->DataAte )
	oObj:cQUERYADDWHERE		:= ""
	oObj:cINDEXKEY			:= ""
	oObj:nPAGELEN			:= 10
	oObj:nPAGEFIRST			:= ( Val( HttpGet->cPagina ) * 10 ) + 1
	
	//cUSERCODE,dREGISTERDATEFROM,dREGISTERDATETO,cQUERYADDWHERE,cINDEXKEY,nPAGELEN,nPAGEFIRST
	If oObj:BRWSERVICECALL()
		HttpSession->PWST100RESULT := oObj:oWSBRWSERVICECALLRESULT:oWSSERVICECALLHEADERVIEW

		GridLinesEX( {	HttpSession->PWST100INFO, ;
						HttpSession->HEADER101_1, ;
						HttpSession->PWST100RESULT, ;
						aWebCols,.F.,"A",,0 } )
	Else
		Return PWSHTMLALERT( "", STR0003, "", "W_PWST100.APW" )//"Erro"
	EndIf
EndIf

cHtml += ExecInPage( "PWST101" )

WEB EXTENDED END

Return cHtml

//**********************************************************************
Web Function PWST102()

Local cHtml := ""
Local oObj := Nil
Local aWebCols := {}

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSFSSERVICECALL():NEW()
WsChgUrl( @oObj, "FSSERVICECALL.APW" )

If !Empty( HttpPost->ERPCTREC )
	HttpSession->PWST102INFO := { {}, {} }
	HttpSession->PWST102RESULT := { NIL, NIL }
	
	If HttpPost->cAcao == "V"
		HttpSession->_TMPCTBOTOES := "V"
	EndIf
	
	oObj:cUSERCODE		:= "MSALPHA"
	oObj:cSERVICECALLID	:= HttpPost->ERPCTREC

	//cUSERCODE,cSERVICECALLID
	If oObj:GETSERVICECALL()
		HttpSession->PWST102RESULT[1] := oObj:oWSGETSERVICECALLRESULT:oWSSERVICECALLHEADER
		HttpSession->PWST102RESULT[2] := oObj:oWSGETSERVICECALLRESULT:oWSSERVICECALLITEM:oWSSERVICECALLITEMVIEW

		If ExistBlock( "PET102" )
			aWebCols := ExecBlock( "PET102", .F., .F., {1} )
		EndIf
		
		GridLinesEX( {	HttpSession->PWST102INFO[1], ;
						HttpSession->HEADER101_1,;
						HttpSession->PWST102RESULT[1], aWebCols, .F., "H",,0 } )

		aWebCols := {}

		If ExistBlock( "PET102" )
			aWebCols := ExecBlock( "PET102", .F., .F., {2} )
		EndIf

		GridHeader(	HttpSession->PWST102INFO[2], ;
						HttpSession->HEADER101_2,;
						aWebCols )

		GridLinesEX( {	HttpSession->PWST102INFO[2], ;
						HttpSession->HEADER101_2,;
						HttpSession->PWST102RESULT[2], aWebCols, .F., "A",,0 } )
	Else
		Return PWSHTMLALERT( "", STR0003, "", "W_PWST100.APW" )//"Erro"
	EndIf

	cHtml += ExecInPage( "PWST102" )
Else
	cHtml += ExecInPage( "PWST101" )
EndIf

WEB EXTENDED END

Return cHtml

//**********************************************************************
Web Function PWST102A()

Local cHtml := ""

WEB EXTENDED INIT cHtml

cHtml += ExecInPage( "PWST102A" )

WEB EXTENDED END

Return cHtml