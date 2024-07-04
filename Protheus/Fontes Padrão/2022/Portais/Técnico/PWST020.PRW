#INCLUDE "PWST020.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"

#DEFINE TECERP_ENTIDADE		1
#DEFINE TECERP_CODIGO		2
#DEFINE TECERP_NOMEFANT		3
#DEFINE TECERP_RAZAOSOC		4
#DEFINE TECERP_CPFCNPJ		5

#DEFINE MYUSERCODE		GetUsrCode()

//**********************************************************************
Web Function PWST020()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

HttpPost->PWST020TEC	:= GetUserTec()

HttpSession->PWST020APH := {	STR0001 ,;				// Titulo //"Ordem de Serviço"
								"W_PWST021.APW"	,;			// Proxima Tela
								""	} 						// Msg de Erro
	
HttpSession->PWST021APH := {	STR0001 ,;				// Titulo //"Ordem de Serviço"
										"W_PWST022.APW"	,; 		// Action do Post
										"W_PWST020.APW"		}  	// Link p/ Voltar
	
HttpSession->PWST022APH := {	STR0002 ,;				// Titulo //"Detalhes do Título"
										"W_PWST021.APW"	,} 		// Link p/ Voltar


If Len(HttpPost->PWST020TEC) <= 1   
	//Nao ha tecnicos a serem consultados
	HttpSession->PWST020APH[3] := STR0003 	//"Não há Técnicos a consultar."
	cHtml += ExecInPage( "PWST020" )
ElseIf len(HttpPost->PWST020TEC) = 2 
	//1 tecnico a ser consultado
	HttpPost->CODTECERP	:= HttpPost->PWST020TEC[2][TECERP_CODIGO]
	cHtml += W_PWST021()
Else
	//2 ou mais tecnicos a serem consultados
	cHtml += ExecInPage( "PWST020" )
EndIf

WEB EXTENDED END

Return cHtml

//**********************************************************************
// Segunda Tela : Consulta Ordens de Serviço
Web Function PWST021()

Local cHtml := ""
Local aWebCols := {}
Local oObj

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSFSSERVICEORDER():NEW()
WsChgUrl( @oObj, "FSSERVICEORDER.apw" )

If HttpPost->CODTECERP != Nil
	HttpSession->CODTECERP := HttpPost->CODTECERP
EndIf

If Empty( HttpSession->PWST021HEADER )
	HttpSession->PWST021HEADER := { {}, {} }
	
	If oObj:GETHEADER( "SERVICEORDERHEADERVIEW" )
		HttpSession->PWST021HEADER[1] := { oObj:oWSGETHEADERRESULT:OWSBRWHEADER }
	Else
		Return PWSHTMLALERT( "", STR0004, "", "W_PWST020.APW" )//"Erro"
	EndIf

	If oObj:GETHEADER( "SERVICEORDERITEMVIEW" )
		HttpSession->PWST021HEADER[2] := { oObj:oWSGETHEADERRESULT:OWSBRWHEADER }
	Else
		Return PWSHTMLALERT( "", STR0004, "", "W_PWST020.APW" )//"Erro"
	EndIf
EndIf

HttpSession->PWST021INFO := {}
HttpSession->PWST021RESULT := {}

If HttpPost->DataDe == Nil .Or. HttpPost->DataAte == Nil
	HttpPost->Busca := ""
	HttpPost->Tipo  := "1"

	Return ExecInPage( "PWST021" )
Else
	aWebCols := {}
	
	If ExistBlock( "PET021" )
		aWebCols := ExecBlock( "PET021", .F., .F., {} )
	EndIf

	GridHeader(	HttpSession->PWST021INFO, ;
					HttpSession->PWST021HEADER[1][1], ;
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
	If oObj:BRWSERVICEORDER()
		HttpSession->PWST021RESULT := { oObj:oWSBRWSERVICEORDERRESULT:oWSSERVICEORDERHEADERVIEW }

		GridLinesEx( {	HttpSession->PWST021INFO, ;
						HttpSession->PWST021HEADER[1][1], ;
						HttpSession->PWST021RESULT[1], ;
						aWebCols, .F., "A",,0 } )
	Else
		Return PWSHTMLALERT( "", STR0004, "", "W_PWST020.APW" )//"Erro"
	EndIf
EndIf

cHtml += ExecInPage( "PWST021" )

WEB EXTENDED END

Return cHtml

//**********************************************************************
// Tela de Zoom de Título a Receber
Web Function PWST022()

Local cHtml := ""
Local oObj := Nil
Local aWebCols := {}

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSFSSERVICEORDER():NEW()
WsChgUrl( @oObj, "FSSERVICEORDER.apw" )

If !Empty( HttpPost->ERPOSREC )
	HttpSession->PWST022INFO := { {}, {} }
	HttpSession->PWST022RESULT := {}
	
	If HttpPost->cAcao == "V"
		HttpSession->_TMPOSBOTOES := "V"
	EndIf
	
	oObj:cUSERCODE			:= "MSALPHA"
	oObj:cSERVICEORDERID	:= HttpPost->ERPOSREC

	//cUSERCODE,cSERVICEORDERID
	If oObj:GETSERVICEORDER()
		HttpSession->PWST022RESULT := { oObj:oWSGETSERVICEORDERRESULT }
		            
		If ExistBlock( "PET022" )
			aWebCols := ExecBlock( "PET022", .F., .F., {1} )
		EndIf
		
		GridLinesEX( {	HttpSession->PWST022INFO[1], ;
						HttpSession->PWST021HEADER[1][1],;
						HttpSession->PWST022RESULT[1]:oWSSERVICEORDERHEADER, aWebCols, .F., "H",,0 } )
         
		If ExistBlock( "PET022" )
			aWebCols := ExecBlock( "PET022", .F., .F., {2} )
		EndIf

		GridHeader(	HttpSession->PWST022INFO[2], ;
						HttpSession->PWST021HEADER[2][1],;
						aWebCols )

		GridLinesEX( {	HttpSession->PWST022INFO[2], ;
						HttpSession->PWST021HEADER[2][1],;
						HttpSession->PWST022RESULT[1]:oWSSERVICEORDERITEM:oWSSERVICEORDERITEMVIEW, aWebCols, .F., "A",,0 } )
	Else
		Return PWSHTMLALERT( "", STR0004, "", "W_PWST020.APW" )//"Erro"
	EndIf

	If HttpPost->cAcao == "A"
		HttpSession->_TMPOSERRO := "A"
		
		Return W_PWST023()
	ElseIf HttpPost->cAcao == "V" .OR. HttpPost->cAcao == "E"
		HttpSession->_TMPOSBOTOES := "V"

		If HttpPost->cAcao == "E"
			HttpSession->_TMPOSEXCLUI := "E"
		Else
			HttpSession->_TMPOSEXCLUI := ""
		EndIf

		cHtml += ExecInPage( "PWST022" )
	EndIf
Else
	cHtml += ExecInPage( "PWST021" )
EndIf

WEB EXTENDED END

Return cHtml

//**********************************************************************
Web Function PWST022A()

Local cHtml := ""
Local aWebCols := {}

WEB EXTENDED INIT cHtml

HttpSession->PWST022AINFO := {}

If HttpSession->_TMPOSBOTOES == "I"
		
	If ExistBlock( "PET022A" )
		aWebCols := ExecBlock( "PET022A", .F., .F., {} )
	EndIf

	GridHeader( HttpSession->PWST022AINFO, HttpSession->PWST023HEADER[2][1], aWebCols )

	GridLinesEX( {	HttpSession->PWST022AINFO, ;
					HttpSession->PWST023HEADER[2][1], ;
					FSSERVICEORDER_SERVICEORDERITEMVIEW():New(), ;
					aWebCols, .F., "A",,0 } )
EndIf

cHtml += ExecInPage( "PWST022A" )

WEB EXTENDED END

Return cHtml

//**********************************************************************
Web Function PWST023()

Local cHtml := ""
Local oObj
Local oObjView
Local aWebCols := {}

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSFSSERVICEORDER():New()
oObjView := FSSERVICEORDER_SERVICEORDERHEADERVIEW():New()

WsChgURL( @oObj, "FSSERVICEORDER.APW" )

HttpSession->PWST023INFO := { {}, {} }

If HttpPost->cAcao == "I" .OR. HttpGet->cAcao == "I" .OR. HttpPost->cAcao == "A" .OR. HttpGet->cAcao == "A"
	If HttpPost->cAcao == "A" .OR. HttpGet->cAcao == "A"
		HttpSession->PWST023GRAVA := { HttpSession->PWST022RESULT[1]:oWSSERVICEORDERHEADER, HttpSession->PWST022RESULT[1]:oWSSERVICEORDERITEM:oWSSERVICEORDERITEMVIEW }
	ElseIf HttpGet->cAcao <> "I"
		HttpSession->PWST023GRAVA := { FSSERVICEORDER_SERVICEORDERHEADERVIEW():New(), {} }
	EndIf
	
	HttpSession->_TMPOSBOTOES := "I"

	If Empty( HttpSession->PWST023HEADER )
		HttpSession->PWST023HEADER := { {}, {} }

		If oObj:GETHEADER( "SERVICEORDERHEADERVIEW" )
			HttpSession->PWST023HEADER[1] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
		Else
			Return PWSHTMLALERT( "", STR0004, "", "W_PWST020.APW" )//"Erro"
		EndIf
	
		If oObj:GETHEADER( "SERVICEORDERITEMVIEW" )
			HttpSession->PWST023HEADER[2] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
		Else
			Return PWSHTMLALERT( "", STR0004, "", "W_PWST020.APW" )//"Erro"
		EndIf
	EndIf
	
	oObjView:dISSUEDATE			:= Date()
	
	If ExistBlock( "PET023" )
		aWebCols := ExecBlock( "PET023", .F., .F., {1} )
	EndIf
	
	If HttpPost->cAcao == "A"
		GridLinesEX( {	HttpSession->PWST023INFO[1], ;
						HttpSession->PWST023HEADER[1][1], ;
						HttpSession->PWST023GRAVA[1], ;
						aWebCols, .T., "H",,0 } )
	Else
		GridLinesEX( {	HttpSession->PWST023INFO[1], ;
						HttpSession->PWST023HEADER[1][1], ;
						IIf( !Empty( HttpGet->cAcao ), HttpSession->PWST023GRAVA[1], oObjView ), ;
						aWebCols, .T., "H",,0 } )
	EndIf
ElseIf HttpPost->cAcao == "AC"
         
	If ExistBlock( "PET023" )
		aWebCols := ExecBlock( "PET023", .F., .F., {2} )
	EndIf

	GridLinesEX( {	HttpSession->PWST023INFO[1], ;
					HttpSession->PWST023HEADER[1][1], ;
					HttpSession->PWST023GRAVA[1], ;
					aWebCols, .T., "H",,0 } )
EndIf

cHtml += ExecInPage( "PWST023" )

WEB EXTENDED END

Return cHtml

//**********************************************************************
Web Function PWST024()

Local cHtml := ""
Local lExclui := .F.
Local oObjView
Local aBI := {}
Local aWebCols := {}

WEB EXTENDED INIT cHtml START "InSite"

oObjView := FSSERVICEORDER_SERVICEORDERITEMVIEW():New()

HttpSession->PWST024INFO := { {}, {} }

If HttpSession->_TMPOSBOTOES == "I"
	If HttpPost->cAcao == "AI"
		nPosOS := aScan( HttpSession->PWST023GRAVA[2], { |x| AllTrim( x:cSERVICEORDERITEM ) == AllTrim( HttpPost->cSelItem ) } )

		If nPosOS > 0
			If ExistBlock( "PET024" )
				aWebCols := ExecBlock( "PET024", .F., .F., {1} )
			EndIf
		
			GridLinesEX( {	HttpSession->PWST024INFO[1], ;
							HttpSession->PWST023HEADER[1][1], ;
							HttpSession->PWST023GRAVA[1], ;
							aWebCols, .F., "H",,0 } )
                   
			
			If ExistBlock( "PET024" )
				aWebCols := ExecBlock( "PET024", .F., .F., {2} )
			EndIf

			GridLinesEX( {	HttpSession->PWST024INFO[2], ;
							HttpSession->PWST023HEADER[2][1], ;
							HttpSession->PWST023GRAVA[2][nPosOS], ;
							aWebCols, .T., "H",,0 } )
		EndIf
	Else
		PWSSetObjToPost( HttpSession->PWST023GRAVA[1], HttpSession->PWST023HEADER[1][1], HttpPost->aPost )
		                                                      
		aWebCols := {}
		
		If ExistBlock( "PET024" )
				aWebCols := ExecBlock( "PET024", .F., .F., {3} )
		EndIf
		
		GridLinesEX( {	HttpSession->PWST024INFO[1], ;
						HttpSession->PWST023HEADER[1][1], ;
						HttpSession->PWST023GRAVA[1], ;
						aWebCols, .F., "H",,0 } )
      
		If ExistBlock( "PET024" )
			aWebCols := ExecBlock( "PET024", .F., .F., {4} )
		EndIf

		GridLinesEX( {	HttpSession->PWST024INFO[2], ;
						HttpSession->PWST023HEADER[2][1], ;
						oObjView, ;
						aWebCols, .T., "H",,0 },"FSREPAIRCENTER","AB7" )
	EndIf
EndIf

ExecInPage( "PWST024" )

WEB EXTENDED END

Return cHtml

//**********************************************************************
Web Function PWST024A()

Local cHtml := ""
Local oObj
Local lExclui := .F.
Local aWebCols := {}

WEB EXTENDED INIT cHtml START "InSite"

HttpSession->PWST024AINFO := {}

If HttpSession->_TMPOSBOTOES == "I"
	If HttpPost->cAcao == "EI"
		nPosOS := aScan( HttpSession->PWST023GRAVA[2], { |x| AllTrim( x:cSERVICEORDERITEM ) == AllTrim( HttpPost->cSelItem ) } )
		
		If nPosOS > 0
			aDel( HttpSession->PWST023GRAVA[2], nPosOS )
			aSize( HttpSession->PWST023GRAVA[2], Len( HttpSession->PWST023GRAVA[2] ) - 1 )
		EndIf
             
		If ExistBlock( "PET024A" )
			aWebCols := ExecBlock( "PET024A", .F., .F., {1} )
		EndIf

		GridHeader( HttpSession->PWST024AINFO, HttpSession->PWST023HEADER[2][1], {} )
	
		GridLinesEX( {	HttpSession->PWST024AINFO, ;
						HttpSession->PWST023HEADER[2][1], ;
						HttpSession->PWST023GRAVA[2], ;
						aWebCols, .F., "A",,0 } )
	Else     
        
		aWebCols := {}
				
		If ExistBlock( "PET024A" )
			aWebCols := ExecBlock( "PET024A", .F., .F., {2} )
		EndIf
	
		GridHeader( HttpSession->PWST024AINFO, HttpSession->PWST023HEADER[2][1], {} )
	
		GridLinesEX( {	HttpSession->PWST024AINFO, ;
						HttpSession->PWST023HEADER[2][1], ;
						HttpSession->PWST023GRAVA[2], ;
						aWebCols, .F., "A",,0 } )
	EndIf
EndIf

ExecInPage( "PWST024A" )

WEB EXTENDED END

Return cHtml

//**********************************************************************
Web Function PWST025()

Local cHtml := ""
Local oObj
Local lExclui := .F.
Local oObjView
Local aWebCols := {}

WEB EXTENDED INIT cHtml START "InSite"

oObjView := FSSERVICEORDER_SERVICEORDERITEMVIEW():New()

If HttpSession->_TMPOSBOTOES == "I"
	If HttpPost->cAcao == "II"
		aAdd( HttpSession->PWST023GRAVA[2], FSSERVICEORDER_SERVICEORDERITEMVIEW():New() )
	   	PWSPutUsrFld( HttpSession->PWST023GRAVA[2][Len( HttpSession->PWST023GRAVA[2] )], "AB7", "FSREPAIRCENTER" )	 	
		PWSSetObjToPost( HttpSession->PWST023GRAVA[2][Len( HttpSession->PWST023GRAVA[2] )], HttpSession->PWST023HEADER[2][1], HttpPost->aPost )
		
		If Len( HttpSession->PWST023GRAVA[2] ) > 1
			HttpSession->PWST023GRAVA[2][Len( HttpSession->PWST023GRAVA[2] )]:cSERVICEORDERITEM := AllTrim( StrZero( Val( HttpSession->PWST023GRAVA[2][Len( HttpSession->PWST023GRAVA[2] ) - 1]:cSERVICEORDERITEM ) + 1, 2 ) )
		Else
			HttpSession->PWST023GRAVA[2][Len( HttpSession->PWST023GRAVA[2] )]:cSERVICEORDERITEM := "01"
		EndIf
	ElseIf HttpPost->cAcao == "AI"
		nPosOS := aScan( HttpSession->PWST023GRAVA[2], { |x| AllTrim( x:cSERVICEORDERITEM ) == AllTrim( HttpPost->cSelItem ) } )
		
		If nPosOS > 0
			PWSSetObjToPost( HttpSession->PWST023GRAVA[2][nPosOS], HttpSession->PWST023HEADER[2][1], HttpPost->aPost )
		EndIf
		
		HttpSession->PWST024INFO := { {}, {} }
             
		If ExistBlock( "PET025" )
			aWebCols := ExecBlock( "PET025", .F., .F., {1} )
		EndIf

		GridLinesEX( {	HttpSession->PWST024INFO[1], ;
						HttpSession->PWST023HEADER[1][1], ;
						HttpSession->PWST023GRAVA[1], ;
						aWebCols, .F., "H",,0 } )

		If ExistBlock( "PET025" )
			aWebCols := ExecBlock( "PET025", .F., .F., {2} )
		EndIf

		GridLinesEX( {	HttpSession->PWST024INFO[2], ;
						HttpSession->PWST023HEADER[2][1], ;
						oObjView, ;
						aWebCols, .T., "H",,0 } )
		
		HttpPost->cAcao := ""
	EndIf
EndIf

cHtml := ExecInPage( "PWST024" )

WEB EXTENDED END

Return cHtml

//**********************************************************************
Web Function PWST026()

Local cHtml := ""
Local oObj
Local nI := 0

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSFSSERVICEORDER():New()
WsChgURL( @oObj, "FSSERVICEORDER.APW" )

If HttpSession->_TMPOSBOTOES == "I"
	oObj:cUSERCODE			:= "MSALPHA"
	oObj:oWSSERVICEORDER	:= FSSERVICEORDER_SERVICEORDERVIEW():New()
	oObj:oWSSERVICEORDER:oWSSERVICEORDERHEADER	:= FSSERVICEORDER_SERVICEORDERHEADERVIEW():New()
	oObj:oWSSERVICEORDER:oWSSERVICEORDERHEADER 	:= HttpSession->PWST023GRAVA[1]
	oObj:oWSSERVICEORDER:oWSSERVICEORDERITEM	:= FSSERVICEORDER_ARRAYOFSERVICEORDERITEMVIEW():New()
	
	For nI := 1 To Len( HttpSession->PWST023GRAVA[2] )
		aAdd( oObj:oWSSERVICEORDER:oWSSERVICEORDERITEM:oWSSERVICEORDERITEMVIEW, FSSERVICEORDER_SERVICEORDERITEMVIEW():New() )
		oObj:oWSSERVICEORDER:oWSSERVICEORDERITEM:oWSSERVICEORDERITEMVIEW[nI] := HttpSession->PWST023GRAVA[2][nI]
	Next nI
	
	WSDLDBGLEVEL( 3 )

	//cUSERCODE,oWSINSTALLBASE
	If oObj:PUTSERVICEORDER()
		Return PWSHTMLALERT( "", STR0005, STR0006, "W_PWST020.APW" )//"Atenção", "Informações cadastradas com SUCESSO!"
	Else
		Return PWSHTMLALERT( "", STR0004, "", "W_PWST023.APW?cAcao=" + IIf( HttpSession->_TMPOSERRO == "A", "A", "I" ) )////"Erro"
	EndIf
EndIf

WEB EXTENDED END

Return cHtml

//**********************************************************************
Web Function PWST027()

Local cHtml := ""
Local oObj
Local nI := 0

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSFSSERVICEORDER():New()
WsChgURL( @oObj, "FSSERVICEORDER.APW" )

If HttpSession->_TMPOSEXCLUI == "E"
	oObj:cUSERCODE			:= "MSALPHA"
	oObj:oWSSERVICEORDER	:= FSSERVICEORDER_SERVICEORDERVIEW():New()
	oObj:oWSSERVICEORDER:oWSSERVICEORDERHEADER	:= HttpSession->PWST022RESULT[1]:oWSSERVICEORDERHEADER
	oObj:oWSSERVICEORDER:oWSSERVICEORDERITEM	:= FSSERVICEORDER_ARRAYOFSERVICEORDERITEMVIEW():New()

	For nI := 1 To Len( HttpSession->PWST022RESULT[1]:oWSSERVICEORDERITEM:oWSSERVICEORDERITEMVIEW )
		aAdd( oObj:oWSSERVICEORDER:oWSSERVICEORDERITEM:oWSSERVICEORDERITEMVIEW, FSSERVICEORDER_SERVICEORDERITEMVIEW():New() )
		oObj:oWSSERVICEORDER:oWSSERVICEORDERITEM:oWSSERVICEORDERITEMVIEW[nI]	:= HttpSession->PWST022RESULT[1]:oWSSERVICEORDERITEM:oWSSERVICEORDERITEMVIEW[nI]
	Next nI
	
	WSDLDBGLEVEL( 3 )
	
	//cUSERCODE,oWSSERVICEORDER
	If oObj:DELSERVICEORDER()
		Return PWSHTMLALERT( "", STR0005, STR0007, "W_PWST020.APW" )//"Atenção","Informações excluídas com SUCESSO!"
	Else
		Return PWSHTMLALERT( "", STR0004, "", "W_PWST020.APW" )//"Erro"
	EndIf
EndIf

WEB EXTENDED END

Return cHtml