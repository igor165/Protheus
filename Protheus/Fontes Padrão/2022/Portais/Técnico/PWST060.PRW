#INCLUDE "PWST060.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"

#DEFINE TECERP_ENTIDADE		1
#DEFINE TECERP_CODIGO		2
#DEFINE TECERP_NOMEFANT		3
#DEFINE TECERP_RAZAOSOC		4
#DEFINE TECERP_CPFCNPJ		5

#DEFINE MYUSERCODE		GetUsrCode()

//**********************************************************************
Web Function PWST060()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

HttpPost->PWST060TEC	:= GetUserTec()

HttpSession->PWST060APH := {	STR0001 ,;		//"Agenda"
								"W_PWST061.APW"	,;
								""	}

If Len(HttpPost->PWST060TEC) <= 1   
	//Nao ha tecnicos a serem consultados
	HttpSession->PWST060APH[3] := STR0002		//"Não há Técnicos a consultar."
	cHtml += ExecInPage( "PWST020" )
ElseIf len(HttpPost->PWST060TEC) = 2 
	//1 tecnico a ser consultado
	HttpPost->CODTECERP	:= HttpPost->PWST060TEC[2][TECERP_CODIGO]
	cHtml += W_PWST061()
Else
	//2 ou mais tecnicos a serem consultados
	cHtml += ExecInPage( "PWST020" )
EndIf

WEB EXTENDED END

Return cHtml

//**********************************************************************
Web Function PWST061()

Local cHtml := ""
Local aWebCols := {}
Local oObj

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSFSCALENDAR():NEW()
WsChgUrl( @oObj, "FSCALENDAR.APW" )

If HttpPost->CODTECERP != Nil
	HttpSession->CODTECERP := HttpPost->CODTECERP
EndIf

If Empty( HttpSession->HEADER061_1 )
	HttpSession->HEADER061_1 := {}
	HttpSession->HEADER061_2 := {}
	
	If oObj:GETHEADER( "CALENDARTECVIEW" )
		HttpSession->HEADER061_1 := oObj:oWSGETHEADERRESULT:OWSBRWHEADER
	Else
		Return PWSHTMLALERT( "", STR0003, "", "W_PWST060.APW" )//"Erro"
	EndIf
EndIf

HttpSession->PWST060INFO := {}
HttpSession->PWST060RESULT := {}

If HttpPost->DataDe == Nil .Or. HttpPost->DataAte == Nil
	HttpPost->Busca := ""
	HttpPost->Tipo  := "1"

	Return ExecInPage( "PWST061" )
Else
	aWebCols := {}
	
	If ExistBlock( "PET061" )
		aWebCols := ExecBlock( "PET061", .F., .F., {} )
	EndIf

	GridHeader(	HttpSession->PWST060INFO, ;
					HttpSession->HEADER061_1, ;
					aWebCols )

	If Empty( HttpGet->cPagina )
		HttpGet->cPagina := "0"
	EndIf

	oObj:cUSERCODE			:= "MSALPHA"
	oObj:cTECHNICIANCODE	:= HttpSession->CODTECERP
	oObj:dREGISTERDATEFROM	:= CToD( HttpPost->DataDe )
	oObj:dREGISTERDATETO	:= CToD( HttpPost->DataAte )
	oObj:cQUERYADDWHERE		:= ""
	oObj:cINDEXKEY			:= ""
	oObj:nPAGELEN			:= 10
	oObj:nPAGEFIRST			:= ( Val( HttpGet->cPagina ) * 10 ) + 1
	
	//cUSERCODE,cTECHNICIANCODE,dREGISTERDATEFROM,dREGISTERDATETO,cQUERYADDWHERE,cINDEXKEY,nPAGELEN,nPAGEFIRST
	If oObj:BRWCALENDAR()
		HttpSession->PWST060RESULT := oObj:oWSBRWCALENDARRESULT:oWSCALENDARTECVIEW

		GridLinesEX( {	HttpSession->PWST060INFO, ;
						HttpSession->HEADER061_1, ;
						HttpSession->PWST060RESULT, ;
						aWebCols,.F.,"A",,0 } )
	Else
		Return PWSHTMLALERT( "", STR0003, "", "W_PWST060.APW" )//"Erro"
	EndIf
EndIf

cHtml += ExecInPage( "PWST061" )

WEB EXTENDED END

Return cHtml

//**********************************************************************
Web Function PWST062()

Local cHtml := ""
Local oObj
Local aDadosAgenda := {}
Local aWebCols := {}

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSFSCALENDAR():NEW()
WsChgUrl( @oObj, "FSCALENDAR.APW" )

If !Empty( HttpPost->ERPOSREC )
	aDadosAgenda := Separa( HttpPost->ERPOSREC, "|" )

	HttpSession->PWST062INFO := {}
	HttpSession->PWST062RESULT := NIL
	
	If HttpPost->cAcao == "V"
		HttpSession->_TMPOSBOTOES := "V"
	EndIf
	
	oObj:cUSERCODE					:= "MSALPHA"
	oObj:cTECHNICIANCODE			:= HttpSession->CODTECERP
	oObj:dREGISTERDATE				:= CToD( aDadosAgenda[1] )
	oObj:cREGISTERTIME				:= aDadosAgenda[2]

	//cUSERCODE,cTECHNICIANCODE,dREGISTERDATE,cREGISTERTIME
	If oObj:GETCALENDAR()
		HttpSession->PWST062RESULT := oObj:oWSGETCALENDARRESULT
                    
	If ExistBlock( "PET062" )
		aWebCols := ExecBlock( "PET062", .F., .F., {} )
	EndIf

		GridLinesEX( {	HttpSession->PWST062INFO,;
						HttpSession->HEADER061_1,;
						HttpSession->PWST062RESULT, aWebCols, .F., "H",,0 } )
	Else
		Return PWSHTMLALERT( "", STR0003, "", "W_PWST060.APW" )//"Erro"
	EndIf

	cHtml += ExecInPage( "PWST062" )
Else
	cHtml += ExecInPage( "PWST061" )
EndIf

WEB EXTENDED END

Return cHtml

//**********************************************************************
Web Function PWST063()

Local cHtml := ""
Local oObj
Local aWebCols := {}
Local aDadosAgenda := {}

WEB EXTENDED INIT cHtml START "InSite"

oObj		:= WSFSCALENDAR():New()
oObjView 	:= FSCALENDAR_CALENDARTECVIEW():New()

WsChgURL( @oObj, "FSCALENDAR.APW" )

HttpSession->PWST063INFO := {}

If HttpPost->cAcao == "I"
	HttpSession->_TMPOSBOTOES := "I"

	oObjView:dINITIALDATE		:= Date()
	oObjView:dFINALDATE			:= Date()
	oObjView:cCONFIRMED			:= "S"
	oObjView:cATTENDED			:= "N"
	oObjView:cSERVED			:= "2"
	     
	If ExistBlock( "PET063" )
		aWebCols := ExecBlock( "PET063", .F., .F., {1} )
	EndIf
	
	GridLinesEX( {	HttpSession->PWST063INFO, ;
					HttpSession->HEADER061_1, ;
					oObjView, ;
					aWebCols, .T., "H",,0 } )
ElseIf HttpPost->cAcao == "A"
	HttpSession->_TMPOSBOTOES := "A"
	aDadosAgenda := Separa( HttpPost->ERPOSREC, "|" )
	
	oObj:cUSERCODE			:= "MSALPHA"
	oObj:cTECHNICIANCODE	:= HttpSession->CODTECERP
	oObj:dREGISTERDATE		:= CToD( aDadosAgenda[1] )
	oObj:cREGISTERTIME		:= aDadosAgenda[2]
	
	//cUSERCODE,cTECHNICIANCODE,dREGISTERDATE,cREGISTERTIME
	If oObj:GETCALENDAR()
		HttpSession->PWST063CALENDAR := { oObj:oWSGETCALENDARRESULT }
	Else
		Return PWSHTMLALERT( "", STR0003, "", "W_PWST060.APW" )//"Erro"
	EndIf
        
	If ExistBlock( "PET063" )
		aWebCols := ExecBlock( "PET063", .F., .F., {2} )
	EndIf

	GridLinesEX( {	HttpSession->PWST063INFO, ;
					HttpSession->HEADER061_1, ;
					HttpSession->PWST063CALENDAR[1], ;
					aWebCols, .T., "H",,0 } )
ElseIf HttpPost->cAcao == "E"
	HttpSession->_TMPOSBOTOES := "E"
	aDadosAgenda := Separa( HttpPost->ERPOSREC, "|" )
	
	oObj:cUSERCODE			:= "MSALPHA"
	oObj:cTECHNICIANCODE	:= HttpSession->CODTECERP
	oObj:dREGISTERDATE		:= CToD( aDadosAgenda[1] )
	oObj:cREGISTERTIME		:= aDadosAgenda[2]
	
	//cUSERCODE,cTECHNICIANCODE,dREGISTERDATE,cREGISTERTIME
	If oObj:GETCALENDAR()
		HttpSession->PWST063CALENDAR := { oObj:oWSGETCALENDARRESULT }
	Else
		Return PWSHTMLALERT( "", STR0003, "", "W_PWST060.APW" )//"Erro"
	EndIf
	
	aWebCols := {}
	     
	If ExistBlock( "PET063" )
		aWebCols := ExecBlock( "PET063", .F., .F., {3} )
	EndIf
	
	GridLinesEX( {	HttpSession->PWST063INFO, ;
					HttpSession->HEADER061_1, ;
					HttpSession->PWST063CALENDAR[1], ;
					aWebCols, .F., "H",,0 } )
EndIf

cHtml += ExecInPage( "PWST062" )

WEB EXTENDED END

Return cHtml

//**********************************************************************
Web Function PWST064()

Local cHtml := ""
Local oObj
Local lExclui := .F.

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSFSCALENDAR():New()
WsChgUrl( @oObj, "FSCALENDAR.APW" )

If HttpSession->_TMPOSBOTOES == "I"
	oObj:cUSERCODE			:= "MSALPHA"
	oObj:cTECHNICIANCODE	:= HttpSession->CODTECERP
	oObj:oWSCALENDAR		:= FSCALENDAR_CALENDARTECVIEW():New()
ElseIf HttpSession->_TMPOSBOTOES == "A"
	oObj:cUSERCODE			:= "MSALPHA"
	oObj:cTECHNICIANCODE	:= HttpSession->CODTECERP
	oObj:dPRIORINITIALDATE	:= HttpSession->PWST063CALENDAR[1]:dINITIALDATE
	oObj:cPRIORINITIALTIME	:= HttpSession->PWST063CALENDAR[1]:cINITIALTIME
	oObj:dPRIORFINALDATE	:= HttpSession->PWST063CALENDAR[1]:dFINALDATE
	oObj:cPRIORFINALTIME	:= HttpSession->PWST063CALENDAR[1]:cFINALTIME
	oObj:oWSCALENDAR		:= FSCALENDAR_CALENDARTECVIEW():New()
ElseIf HttpSession->_TMPOSBOTOES == "E"
	lExclui := .T.
	oObj:cUSERCODE			:= "MSALPHA"
	oObj:cTECHNICIANCODE	:= HttpSession->CODTECERP
	oObj:oWSCALENDAR		:= HttpSession->PWST063CALENDAR[1]
EndIf

If !lExclui
	PWSSetObjToPost( oObj:oWSCALENDAR, HttpSession->HEADER061_1, HttpPost->aPost )
	
	//cUSERCODE,cTECHNICIANCODE,oWSCALENDAR
	If oObj:PUTCALENDAR()
		Return PWSHTMLALERT( "", STR0004, STR0005, "W_PWST060.APW" )//"Aviso","Informações cadastradas com SUCESSO!"
	Else
		Return PWSHTMLALERT( "", STR0003, "", "W_PWST060.APW" )//"Erro"
	EndIf
Else
	//cUSERCODE,cTECHNICIANCODE,oWSCALENDAR
	If oObj:DELCALENDAR()
		Return PWSHTMLALERT( "", STR0004, STR0005, "W_PWST060.APW" )//"Aviso","Informações excluídas com SUCESSO!"
	Else
		Return PWSHTMLALERT( "", STR0003, "", "W_PWST060.APW" )//"Erro"
	EndIf
EndIf

WEB EXTENDED END

Return cHtml