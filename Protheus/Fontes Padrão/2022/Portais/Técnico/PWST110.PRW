#INCLUDE "PWST110.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"

#DEFINE TECERP_ENTIDADE		1
#DEFINE TECERP_CODIGO		2
#DEFINE TECERP_NOMEFANT		3
#DEFINE TECERP_RAZAOSOC		4
#DEFINE TECERP_CPFCNPJ		5

#DEFINE MYUSERCODE		GetUsrCode()

//**********************************************************************
Web Function PWST110()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

HttpPost->PWST110TEC	:= GetUserTec()

HttpSession->PWST110APH := {	STR0001 ,;		//"Orçamento"
								"W_PWST111.APW"	,;
								""	}

If Len(HttpPost->PWST110TEC) <= 1   
	//Nao ha tecnicos a serem consultados
	HttpSession->PWST110APH[3] := STR0002		//"Não há Técnicos a consultar."
	cHtml += ExecInPage( "PWST020" )
ElseIf len(HttpPost->PWST110TEC) = 2 
	//1 tecnico a ser consultado
	HttpPost->CODTECERP	:= HttpPost->PWST110TEC[2][TECERP_CODIGO]
	cHtml += W_PWST111()
Else
	//2 ou mais tecnicos a serem consultados
	cHtml += ExecInPage( "PWST020" )
EndIf

WEB EXTENDED END

Return cHtml

//**********************************************************************
Web Function PWST111()

Local cHtml := ""
Local aWebCols := {}
Local oObj
Local nTotalOrc:=0

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSFSSERVICEBUDGET():NEW()
WsChgUrl( @oObj, "FSSERVICEBUDGET.APW" )

If HttpPost->CODTECERP != Nil
	HttpSession->CODTECERP := HttpPost->CODTECERP
EndIf

If Empty( HttpSession->HEADER111_1 ) .Or. Empty( HttpSession->HEADER111_2 )
	HttpSession->HEADER111_1 := {}
	HttpSession->HEADER111_2 := {}
	
	If oObj:GETHEADER( "SERVICEBUDGETHEADERVIEW" )
		HttpSession->HEADER111_1 := oObj:oWSGETHEADERRESULT:OWSBRWHEADER
	Else
		Return PWSHTMLALERT( "", STR0003, "", "W_PWST110.APW" )//"Erro"
	EndIf

	If oObj:GETHEADER( "SERVICEBUDGETITEMVIEW" )
		HttpSession->HEADER111_2 := oObj:oWSGETHEADERRESULT:OWSBRWHEADER
	Else
		Return PWSHTMLALERT( "", STR0003, "", "W_PWST110.APW" )//"Erro"
	EndIf
EndIf

HttpSession->PWST110INFO := {}
HttpSession->PWST110RESULT := {}

If HttpGet->DataDe <> Nil .And. HttpGet->DataAte <> Nil
	HttpPost->DataDe  := HttpGet->DataDe
	HttpPost->DataAte := HttpGet->DataAte
EndIf
If HttpPost->DataDe == Nil .Or. HttpPost->DataAte == Nil
	HttpPost->Busca := ""
	HttpPost->Tipo  := "1"

	Return ExecInPage( "PWST111" )
Else
	aWebCols := {}
	
	If ExistBlock( "PET111" )
		aWebCols := ExecBlock( "PET111", .F., .F., {} )
	EndIf

	GridHeader(	HttpSession->PWST110INFO, ;
					HttpSession->HEADER111_1, ;
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
	If oObj:BRWSERVICEBUDGET()
		HttpSession->PWST110RESULT := oObj:oWSBRWSERVICEBUDGETRESULT:oWSSERVICEBUDGETHEADERVIEW
        
	   If oObj:BrwServiceBudgetTotal()
			nTotalOrc:= oObj:nBRWSERVICEBUDGETTOTALRESULT / 10
			HttpSession->BRWSERVICEBUDGETTOTAL := nTotalOrc
		Else
			Return PWSHTMLALERT( "", STR0003, "", "W_PWSC050.APW" )//"Erro"
		EndIf
			GridLinesEX( {	HttpSession->PWST110INFO, ;
						HttpSession->HEADER111_1, ;
						HttpSession->PWST110RESULT, ;
						aWebCols,.F.,"A",,0 } )
	Else
		Return PWSHTMLALERT( "", STR0003, "", "W_PWST110.APW" )//"Erro"
	EndIf
EndIf

cHtml += ExecInPage( "PWST111" )

WEB EXTENDED END

Return cHtml

//**********************************************************************
Web Function PWST112()

Local cHtml := ""
Local oObj := Nil
Local aWebCols := {}

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSFSSERVICEBUDGET():NEW()
WsChgUrl( @oObj, "FSSERVICEBUDGET.APW" )

If !Empty( HttpPost->ERPOMREC )
	HttpSession->PWST112INFO := { {}, {} }
	HttpSession->PWST112RESULT := { NIL, NIL }
	
	oObj:cUSERCODE			:= "MSALPHA"
	oObj:cSERVICEBUDGETID	:= HttpPost->ERPOMREC

	//cUSERCODE,cSERVICEBUDGETID
	If oObj:GETSERVICEBUDGET()
		HttpSession->PWST112RESULT[1] := oObj:oWSGETSERVICEBUDGETRESULT:oWSSERVICEBUDGETHEADER
		HttpSession->PWST112RESULT[2] := oObj:oWSGETSERVICEBUDGETRESULT:oWSSERVICEBUDGETITEM:oWSSERVICEBUDGETITEMVIEW
		            
		If ExistBlock( "PET112" )
			aWebCols := ExecBlock( "PET112", .F., .F., {1} )
		EndIf
		
		GridLinesEX( {	HttpSession->PWST112INFO[1], ;
						HttpSession->HEADER111_1,;
						HttpSession->PWST112RESULT[1], aWebCols, .F., "H",,0 } )
                                                               
	    aWebCols := {}
                                                               
		If ExistBlock( "PET112" )
			aWebCols := ExecBlock( "PET112", .F., .F., {2} )
		EndIf

		GridHeader(	HttpSession->PWST112INFO[2], ;
						HttpSession->HEADER111_2,;
						aWebCols )

		GridLinesEX( {	HttpSession->PWST112INFO[2], ;
						HttpSession->HEADER111_2,;
						HttpSession->PWST112RESULT[2], aWebCols, .F., "A",,0 } )
	Else
		Return PWSHTMLALERT( "", STR0003, "", "W_PWST110.APW" )//"Erro"
	EndIf

	If HttpPost->cAcao == "A"
		Return W_PWST113()
	ElseIf HttpPost->cAcao == "V" .OR. HttpPost->cAcao == "E"
		HttpSession->_TMPOMBOTOES := "V"
		
		If HttpPost->cAcao == "E"
			HttpSession->_TMPOMEXCLUI := "E"
		Else
			HttpSession->_TMPOMEXCLUI := ""
		EndIf

		cHtml += ExecInPage( "PWST112" )
	EndIf
Else
	cHtml += ExecInPage( "PWST111" )
EndIf

WEB EXTENDED END

Return cHtml

//**********************************************************************
Web Function PWST112A()

Local cHtml := ""
Local aWebCols:= {}

WEB EXTENDED INIT cHtml

HttpSession->PWST112AINFO := {}

If HttpSession->_TMPOMBOTOES == "I"

	If ExistBlock( "PET112A" )
		aWebCols := ExecBlock( "PET112A", .F., .F., {} )
	EndIf

	GridHeader( HttpSession->PWST112AINFO, HttpSession->HEADER113_2, aWebCols )

	GridLinesEX( {	HttpSession->PWST112AINFO, ;
					HttpSession->HEADER113_2, ;
					FSINSTALLBASE_ACCESSORYVIEW():New(), ;
					aWebCols, .F., "A",,0 } )
EndIf

cHtml += ExecInPage( "PWST112A" )

WEB EXTENDED END

Return cHtml

//**********************************************************************
Web Function PWST113()

Local cHtml := ""
Local oObj
Local oObjView
Local aWebCols := {}

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSFSSERVICEBUDGET():New()
oObjView := FSSERVICEBUDGET_SERVICEBUDGETHEADERVIEW():New()

WsChgURL( @oObj, "FSSERVICEBUDGET.APW" )

HttpSession->PWST113INFO := { {}, {} }

If HttpPost->cAcao == "I" .OR. HttpGet->cAcao == "I" .OR. HttpPost->cAcao == "A"
	If HttpPost->cAcao == "A"
		HttpSession->PWST113GRAVA := { HttpSession->PWST112RESULT[1], HttpSession->PWST112RESULT[2] }
	ElseIf HttpGet->cAcao <> "I"
		HttpSession->PWST113GRAVA := { FSSERVICEBUDGET_SERVICEBUDGETHEADERVIEW():New(), {} }
	EndIf
	
	HttpSession->_TMPOMBOTOES := "I"

	If Empty( HttpSession->HEADER113_1 ) .OR. Empty( HttpSession->HEADER113_2 )
		If oObj:GETHEADER( "SERVICEBUDGETHEADERVIEW" )
			HttpSession->HEADER113_1 := oObj:oWSGETHEADERRESULT:oWSBRWHEADER
		Else
			Return PWSHTMLALERT( "", STR0003, "", "W_PWST110.APW" )//"Erro"
		EndIf
	
		If oObj:GETHEADER( "SERVICEBUDGETITEMVIEW" )
			HttpSession->HEADER113_2 := oObj:oWSGETHEADERRESULT:oWSBRWHEADER
		Else
			Return PWSHTMLALERT( "", STR0003, "", "W_PWST110.APW" )//"Erro"
		EndIf
	EndIf
                         
	If ExistBlock( "PET113" )
		aWebCols := ExecBlock( "PET113", .F., .F., {1} )
	EndIf
	
	If HttpPost->cAcao == "A"
		GridLinesEX( {	HttpSession->PWST113INFO[1], ;
						HttpSession->HEADER113_1, ;
						HttpSession->PWST113GRAVA[1], ;
						aWebCols, .T., "H",,0 } )
	Else
		oObjView:dISSUEDATE		:= Date()
		oObjView:cBUDGETTIME	:= Substr( Time(), 1, 5 )
	
		GridLinesEX( {	HttpSession->PWST113INFO[1], ;
						HttpSession->HEADER113_1, ;
						IIf( !Empty( HttpGet->cAcao ), HttpSession->PWST113GRAVA[1], oObjView ), ;
						aWebCols, .T., "H",,0 } )
	EndIf
ElseIf HttpPost->cAcao == "AC"
     
	If ExistBlock( "PET113" )
		aWebCols := ExecBlock( "PET113", .F., .F., {2} )
	EndIf

	GridLinesEX( {	HttpSession->PWST113INFO[1], ;
					HttpSession->HEADER113_1, ;
					HttpSession->PWST113GRAVA[1], ;
					aWebCols, .T., "H",,0 } )
EndIf

cHtml += ExecInPage( "PWST113" )

WEB EXTENDED END

Return cHtml

//**********************************************************************
Web Function PWST114()

Local cHtml := ""
Local lExclui := .F.
Local aWebCols := {}
Local oObjView
Local nPosItem := 0

WEB EXTENDED INIT cHtml START "InSite"

oObjView := FSSERVICEBUDGET_SERVICEBUDGETITEMVIEW():New()

HttpSession->PWST114INFO := { {}, {} }

If HttpSession->_TMPOMBOTOES == "I"
	If HttpPost->cAcao == "AI"
		nPosItem := aScan( HttpSession->PWST113GRAVA[2], { |x| AllTrim( x:cSERVICEITEM ) == AllTrim( HttpPost->cSelItem ) } )

		If nPosItem > 0
		
			If ExistBlock( "PET114" )
				aWebCols := ExecBlock( "PET114", .F., .F., {1} )
			EndIf
		
			GridLinesEX( {	HttpSession->PWST114INFO[1], ;
							HttpSession->HEADER113_1, ;
							HttpSession->PWST113GRAVA[1], ;
							aWebCols, .F., "H",,0 } )
            
			If ExistBlock( "PET114" )
				aWebCols := ExecBlock( "PET114", .F., .F., {2} )
			EndIf

			GridLinesEX( {	HttpSession->PWST114INFO[2], ;
							HttpSession->HEADER113_2, ;
							HttpSession->PWST113GRAVA[2][nPosItem], ;
							aWebCols, .T., "H",,0 } )
		EndIf
	Else
		PWSSetObjToPost( HttpSession->PWST113GRAVA[1], HttpSession->HEADER113_1, HttpPost->aPost )

		aWebCols := {}
		 
		If ExistBlock( "PET114" )
			aWebCols := ExecBlock( "PET114", .F., .F., {3} )
		EndIf
		
		GridLinesEX( {	HttpSession->PWST114INFO[1], ;
						HttpSession->HEADER113_1, ;
						HttpSession->PWST113GRAVA[1], ;
						aWebCols, .F., "H",,0 } )

                               
		If ExistBlock( "PET114" )
			aWebCols := ExecBlock( "PET114", .F., .F., {4} )
		EndIf

		GridLinesEX( {	HttpSession->PWST114INFO[2], ;
						HttpSession->HEADER113_2, ;
						oObjView, ;
						aWebCols, .T., "H",,0 } )
	EndIf
EndIf

ExecInPage( "PWST114" )

WEB EXTENDED END

Return cHtml

//**********************************************************************
Web Function PWST114A()

Local cHtml := ""
Local oObj
Local lExclui := .F.
Local nPosItem := 0
Local aWebCols := {}

WEB EXTENDED INIT cHtml START "InSite"

HttpSession->PWST114AINFO := {}

If HttpSession->_TMPOMBOTOES == "I"
	If HttpPost->cAcao == "EI"
		nPosItem := aScan( HttpSession->PWST113GRAVA[2], { |x| AllTrim( x:cSERVICEITEM ) == AllTrim( HttpPost->cSelItem ) } )
		
		If nPosItem > 0
			aDel( HttpSession->PWST113GRAVA[2], nPosItem )
			aSize( HttpSession->PWST113GRAVA[2], Len( HttpSession->PWST113GRAVA[2] ) - 1 )
		EndIf
                    
		If ExistBlock( "PET114A" )
			aWebCols := ExecBlock( "PET114A", .F., .F., {1} )
		EndIf

		GridHeader( HttpSession->PWST114AINFO, HttpSession->HEADER113_2, aWebCols )
	
		GridLinesEX( {	HttpSession->PWST114AINFO, ;
						HttpSession->HEADER113_2, ;
						HttpSession->PWST113GRAVA[2], ;
						aWebCols, .F., "A",,0 } )
	Else
		If ExistBlock( "PET114A" )
			aWebCols := ExecBlock( "PET114A", .F., .F., {2} )
		EndIf

		aWebCols := {}
	
		GridHeader( HttpSession->PWST114AINFO, HttpSession->HEADER113_2, aWebCols )
	
		GridLinesEX( {	HttpSession->PWST114AINFO, ;
						HttpSession->HEADER113_2, ;
						HttpSession->PWST113GRAVA[2], ;
						aWebCols, .F., "A",,0 } )
	EndIf
EndIf

ExecInPage( "PWST114A" )

WEB EXTENDED END

Return cHtml

//**********************************************************************
Web Function PWST115()

Local cHtml := ""
Local oObj
Local lExclui := .F.
Local oObjView
Local nItem := 0
Local nPosItem := 0
Local aWebCols := {}

WEB EXTENDED INIT cHtml START "InSite"

oObjView := FSSERVICEBUDGET_SERVICEBUDGETITEMVIEW():New()

If HttpSession->_TMPOMBOTOES == "I"
	If HttpPost->cAcao == "II"
		If Len( HttpSession->PWST113GRAVA[2] ) > 0
			nItem := Val( HttpSession->PWST113GRAVA[2][Len( HttpSession->PWST113GRAVA[2] )]:cSERVICEITEM )
		EndIf

		aAdd( HttpSession->PWST113GRAVA[2], FSSERVICEBUDGET_SERVICEBUDGETITEMVIEW():New() )
		HttpSession->PWST113GRAVA[2][Len( HttpSession->PWST113GRAVA[2] )]:cSERVICEITEM := StrZero( nItem + 1, 2 )

		PWSSetObjToPost( HttpSession->PWST113GRAVA[2][Len( HttpSession->PWST113GRAVA[2] )], HttpSession->HEADER113_2, HttpPost->aPost )
	ElseIf HttpPost->cAcao == "AI"
		nPosItem := aScan( HttpSession->PWST113GRAVA[2], { |x| AllTrim( x:cSERVICEITEM ) == AllTrim( HttpPost->cSelItem ) } )
		
		If nPosItem > 0
			PWSSetObjToPost( HttpSession->PWST113GRAVA[2][nPosItem], HttpSession->HEADER113_2, HttpPost->aPost )
		EndIf
		
		HttpSession->PWST114INFO := { {}, {} }
                    
		If ExistBlock( "PET115" )
			aWebCols := ExecBlock( "PET115", .F., .F., {} )
		EndIf

		GridLinesEX( {	HttpSession->PWST114INFO[1], ;
						HttpSession->HEADER113_1, ;
						HttpSession->PWST113GRAVA[1], ;
						aWebCols, .F., "H",,0 } )
		
		GridLinesEX( {	HttpSession->PWST114INFO[2], ;
						HttpSession->HEADER113_2, ;
						oObjView, ;
						aWebCols, .T., "H",,0 } )
		
		HttpPost->cAcao := ""
	EndIf
EndIf

cHtml := ExecInPage( "PWST114" )

WEB EXTENDED END

Return cHtml

//**********************************************************************
Web Function PWST116()

Local cHtml := ""
Local oObj
Local nI := 0

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSFSSERVICEBUDGET():New()
WsChgURL( @oObj, "FSSERVICEBUDGET.APW" )

If HttpSession->_TMPOMBOTOES == "I"
	oObj:cUSERCODE			:= "MSALPHA"
	oObj:oWSSERVICEBUDGET	:= FSSERVICEBUDGET_SERVICEBUDGETVIEW():New()
	oObj:oWSSERVICEBUDGET:oWSSERVICEBUDGETHEADER	:= HttpSession->PWST113GRAVA[1]
	oObj:oWSSERVICEBUDGET:oWSSERVICEBUDGETITEM		:= FSSERVICEBUDGET_ARRAYOFSERVICEBUDGETITEMVIEW():New()
	
	For nI := 1 To Len( HttpSession->PWST113GRAVA[2] )
		aAdd( oObj:oWSSERVICEBUDGET:oWSSERVICEBUDGETITEM:oWSSERVICEBUDGETITEMVIEW, FSSERVICEBUDGET_SERVICEBUDGETITEMVIEW():New() )
		oObj:oWSSERVICEBUDGET:oWSSERVICEBUDGETITEM:oWSSERVICEBUDGETITEMVIEW[nI]	:= HttpSession->PWST113GRAVA[2][nI]
	Next nI

	WsdlDbgLevel( 3 )

	//cUSERCODE,oWSSERVICEBUDGET
	If oObj:PUTSERVICEBUDGET()
		Return PWSHTMLALERT( "", STR0004, STR0005, "W_PWST110.APW" )//"Atenção","Informações cadastradas com SUCESSO!"
	Else
		Return PWSHTMLALERT( "", STR0003, "", "W_PWST113.APW?cAcao=I" )//"Erro"
	EndIf
EndIf

WEB EXTENDED END

Return cHtml

//**********************************************************************
Web Function PWST117()

Local cHtml := ""
Local oObj
Local nI := 0

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSFSSERVICEBUDGET():New()
WsChgURL( @oObj, "FSSERVICEBUDGET.APW" )

If HttpSession->_TMPOMEXCLUI == "E"
	oObj:cUSERCODE			:= "MSALPHA"
	oObj:oWSSERVICEBUDGET	:= FSSERVICEBUDGET_SERVICEBUDGETVIEW():New()
	oObj:oWSSERVICEBUDGET:oWSSERVICEBUDGETHEADER	:= HttpSession->PWST112RESULT[1]
	oObj:oWSSERVICEBUDGET:oWSSERVICEBUDGETITEM		:= FSSERVICEBUDGET_ARRAYOFSERVICEBUDGETITEMVIEW():New()

	For nI := 1 To Len( HttpSession->PWST112RESULT[2] )
		aAdd( oObj:oWSSERVICEBUDGET:oWSSERVICEBUDGETITEM:oWSSERVICEBUDGETITEMVIEW, FSSERVICEBUDGET_SERVICEBUDGETITEMVIEW():New() )
		oObj:oWSSERVICEBUDGET:oWSSERVICEBUDGETITEM:oWSSERVICEBUDGETITEMVIEW[nI]	:= HttpSession->PWST112RESULT[2][nI]
	Next nI
	
	//cUSERCODE,oWSSERVICEBUDGET
	If oObj:DELSERVICEBUDGET()
		Return PWSHTMLALERT( "", STR0004, STR0005, "W_PWST110.APW" )//"Atenção","Informações excluídas com SUCESSO!"
	Else
		Return PWSHTMLALERT( "", STR0003, "", "W_PWST113.APW?cAcao=I" )//"Erro"
	EndIf
EndIf

WEB EXTENDED END

Return cHtml