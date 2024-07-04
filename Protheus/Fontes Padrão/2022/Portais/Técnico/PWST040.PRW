#INCLUDE "PWST040.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"

#DEFINE TECERP_ENTIDADE		1
#DEFINE TECERP_CODIGO		2
#DEFINE TECERP_NOMEFANT		3
#DEFINE TECERP_RAZAOSOC		4
#DEFINE TECERP_CPFCNPJ		5

#DEFINE MYUSERCODE		GetUsrCode()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWST040   ºAutor  ³Luiz Felipe Couto    º Data ³  22/03/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina de Atendimento da OS (Portal do Tecnico)             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Portal Protheus                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºCleber M. ³21/11/06³113375³-Passagem do nome do WebService na GridLines º±±
±±º          ³        ³      ³p/ permitir a inclusao de campos de usuario. º±±
±±º          ³        ³      ³-Incluida a funcao PWSPutUsrFld() p/ preen-  º±±
±±º          ³        ³      ³cher a session com os campos de usuario.     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWST040()

Local cHtml := ""		//Pagina HTML

WEB EXTENDED INIT cHtml START "InSite"

HttpPost->PWST040TEC	:= GetUserTec()

HttpSession->PWST040APH := {	STR0001 ,;			//"Atendimento Ordem de Serviço"
								"W_PWST041.APW"	,;
								""	}

If Len(HttpPost->PWST040TEC) <= 1   
	//Nao ha tecnicos a serem consultados
	HttpSession->PWST040APH[3] := STR0002		//"Não há Técnicos a consultar."
	cHtml += ExecInPage( "PWST020" )
ElseIf len(HttpPost->PWST040TEC) = 2 
	//1 tecnico a ser consultado
	HttpPost->CODTECERP	:= HttpPost->PWST040TEC[2][TECERP_CODIGO]
	cHtml += W_PWST041()
Else
	//2 ou mais tecnicos a serem consultados
	cHtml += ExecInPage( "PWST020" )
EndIf

WEB EXTENDED END

Return cHtml

//**********************************************************************
Web Function PWST041()

Local cHtml := ""
Local aWebCols := {}
Local oObj

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSFSREPAIRCENTER():NEW()
WsChgUrl( @oObj, "FSREPAIRCENTER.APW" )

If HttpPost->CODTECERP != Nil
	HttpSession->CODTECERP := HttpPost->CODTECERP
EndIf

If Empty( HttpSession->PWST041HEADER )
	HttpSession->PWST041HEADER := { {}, {} }
	
	If oObj:GETHEADER( "ANNOTATIONSERVICEORDERHEADERVIEW" )
		HttpSession->PWST041HEADER[1] := { oObj:oWSGETHEADERRESULT:OWSBRWHEADER }
	Else
		Return PWSHTMLALERT( "", STR0003, "", "W_PWST040.APW" )//"Erro"
	EndIf

	If oObj:GETHEADER( "ANNOTATIONSERVICEORDERITEMVIEW" )
		HttpSession->PWST041HEADER[2] := { oObj:oWSGETHEADERRESULT:OWSBRWHEADER }
	Else
		Return PWSHTMLALERT( "", STR0003, "", "W_PWST040.APW" )//"Erro"
	EndIf
EndIf

HttpSession->PWST040INFO := {}
HttpSession->PWST040RESULT := {}

If HttpPost->DataDe == Nil .Or. HttpPost->DataAte == Nil
	HttpPost->Busca := ""
	HttpPost->Tipo  := "1"

	Return ExecInPage( "PWST041" )
Else
	If ExistBlock( "PET041" )
		aWebCols := ExecBlock( "PET041", .F., .F., {} )
	EndIf

	GridHeader(	HttpSession->PWST040INFO, ;
					HttpSession->PWST041HEADER[1][1], ;
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
	If oObj:BRWANNOTATIONSERVICEORDER()
		HttpSession->PWST040RESULT := oObj:oWSBRWANNOTATIONSERVICEORDERRESULT:oWSANNOTATIONSERVICEORDERHEADERVIEW

		GridLinesEX( {	HttpSession->PWST040INFO, ;
						HttpSession->PWST041HEADER[1][1], ;
						HttpSession->PWST040RESULT, ;
						aWebCols, .F., "A", , 0 },"FSREPAIRCENTER", "AB9" )
	Else
		Return PWSHTMLALERT( "", STR0003, "", "W_PWST040.APW" )//"Erro"
	EndIf
EndIf

cHtml += ExecInPage( "PWST041" )

WEB EXTENDED END

Return cHtml

//**********************************************************************
Web Function PWST042()

Local cHtml := ""
Local oObj := Nil
Local aWebCols := {}

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSFSREPAIRCENTER():NEW()
WsChgUrl( @oObj, "FSREPAIRCENTER.APW" )

If !Empty( HttpPost->ERPOSREC )
	HttpSession->PWST042INFO := { {}, {} }
	HttpSession->PWST042RESULT := { NIL, NIL }
	
	If HttpPost->cAcao == "V"
		HttpSession->_TMPOSBOTOES := "V"
	EndIf
	
	oObj:cUSERCODE			:= "MSALPHA"
	oObj:cSERVICEORDERID	:= HttpPost->ERPOSREC

	//cUSERCODE,cANNOTATIONSERVICEORDERID
	If oObj:GETANNOTATIONSERVICEORDER()
		HttpSession->PWST042RESULT[1] := oObj:oWSGETANNOTATIONSERVICEORDERRESULT:oWSANNOTATIONSERVICEORDERHEADER
		HttpSession->PWST042RESULT[2] := oObj:oWSGETANNOTATIONSERVICEORDERRESULT:oWSANNOTATIONSERVICEORDERITEM:oWSANNOTATIONSERVICEORDERITEMVIEW
	  	 
		If ExistBlock( "PET042" )
			aWebCols := ExecBlock( "PET042", .F., .F., {1} )
		EndIf		
		
		GridLinesEX( {	HttpSession->PWST042INFO[1], ;
						HttpSession->PWST041HEADER[1][1],;
						HttpSession->PWST042RESULT[1], aWebCols, .F., "H",,0 },"FSREPAIRCENTER", "AB9" )
	
		aWebCols := {}
	
		If ExistBlock( "PET042" )
			aWebCols := ExecBlock( "PET042", .F., .F., {2} )
		EndIf

		GridHeader(	HttpSession->PWST042INFO[2], ;
						HttpSession->PWST041HEADER[2][1],;
						aWebCols )

		GridLinesEX( {	HttpSession->PWST042INFO[2], ;
						HttpSession->PWST041HEADER[2][1],;
						HttpSession->PWST042RESULT[2], aWebCols, .F., "A",,0 },"FSREPAIRCENTER", "ABA" )
	Else
		Return PWSHTMLALERT( "", STR0003, "", "W_PWST040.APW" )//"Erro"
	EndIf
	
	If HttpPost->cAcao == "A"
		Return W_PWST043()
	EndIf

	cHtml += ExecInPage( "PWST042" )
Else
	cHtml += ExecInPage( "PWST041" )
EndIf

WEB EXTENDED END

Return cHtml

//**********************************************************************

Web Function PWST042A()

Local cHtml := ""
Local aWebCols := {}

WEB EXTENDED INIT cHtml

HttpSession->PWST042AINFO := {}

If HttpSession->_TMPBIBOTOES == "I"

	If ExistBlock( "PET042A" )
		aWebCols := ExecBlock( "PET042A", .F., .F., {} )
	EndIf

	GridHeader( HttpSession->PWST042AINFO, HttpSession->PWST041HEADER[2][1], aWebCols )

	GridLinesEX( {	HttpSession->PWST042AINFO, ;
					HttpSession->PWST041HEADER[2][1], ;
					FSREPAIRCENTER_ANNOTATIONSERVICEORDERITEMVIEW():New(), ;
					aWebCols, .F., "A",,0 },"FSREPAIRCENTER", "ABA" )
EndIf

cHtml += ExecInPage( "PWST042A" )

WEB EXTENDED END

Return cHtml

//**********************************************************************
Web Function PWST043()

Local cHtml := ""
Local oObj
Local oObjView
Local aWebCols := {}

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSFSREPAIRCENTER():New()
oObjView := FSREPAIRCENTER_ANNOTATIONSERVICEORDERHEADERVIEW():New()

WsChgURL( @oObj, "FSREPAIRCENTER.APW" )

HttpSession->PWST043INFO := { {}, {} }

If HttpPost->cAcao == "I" .OR. HttpGet->cAcao == "I" .OR. HttpPost->cAcao == "A" .OR. HttpGet->cAcao == "A"
	If HttpPost->cAcao == "A"
		HttpSession->PWST043GRAVA := { HttpSession->PWST042RESULT[1], HttpSession->PWST042RESULT[2] }
	ElseIf HttpGet->cAcao <> "I"
		HttpSession->PWST043GRAVA := { FSREPAIRCENTER_ANNOTATIONSERVICEORDERHEADERVIEW():New(), {} }
	EndIf
	
	If HttpGet->cAcao == "I"
		HttpPost->cAcao := "A"
	EndIf

	HttpSession->_TMPBIBOTOES := "I"
	
	If HttpPost->cAcao == "A"
		If ExistBlock( "PET043" )
			aWebCols := ExecBlock( "PET043", .F., .F., {1} )
		EndIf	
	
		GridLinesEX( {	HttpSession->PWST043INFO[1], ;
						HttpSession->PWST041HEADER[1][1], ;
						HttpSession->PWST043GRAVA[1], ;
						aWebCols, .T., "H",,0 }, "FSREPAIRCENTER", "AB9" )
	Else
		If ExistBlock( "PET043" )
			aWebCols := ExecBlock( "PET043", .F., .F., {1} )
		EndIf	
		oObjView:dARRIVALDATE	:= Date()
		oObjView:cARRIVALTIME	:= SubStr(Time(), 1,5)
		oObjView:dEXITDATE		:= Date()
		oObjView:cEXITTIME		:= SubStr(Time(), 1,5)
		oObjView:dBEGINDATE		:= Date()
		oObjView:cBEGINTIME		:= SubStr(Time(), 1,5)
		oObjView:dFINISHDATE	:= Date()         
		oObjView:cFINISHTIME	:= SubStr(Time(), 1,5)
		oObjView:cINVOICEDHOURS	:= SubStr(Time(), 1,5)

		GridLinesEX( {	HttpSession->PWST043INFO[1], ;
						HttpSession->PWST041HEADER[1][1], ;
						oObjView, ;
						aWebCols, .T., "H",,0 }, "FSREPAIRCENTER", "AB9" )
	EndIf
ElseIf HttpPost->cAcao == "AC"
	If ExistBlock( "PET043" )
		aWebCols := ExecBlock( "PET043", .F., .F., {2} )
	EndIf

	GridLinesEX( {	HttpSession->PWST043INFO[1], ;
					HttpSession->PWST041HEADER[1][1], ;
					HttpSession->PWST043GRAVA[1], ;
					aWebCols, .T., "H", , 0 }, "FSREPAIRCENTER", "AB9" )
EndIf

cHtml += ExecInPage( "PWST043" )

WEB EXTENDED END

Return cHtml

//**********************************************************************
Web Function PWST044()

Local cHtml := ""
Local lExclui := .F.
Local oObjView
Local aBI := {}
local aWebCols := {}

WEB EXTENDED INIT cHtml START "InSite"

oObjView := FSREPAIRCENTER_ANNOTATIONSERVICEORDERITEMVIEW():New()

HttpSession->PWST044INFO := { {}, {} }

If HttpSession->_TMPBIBOTOES == "I"
	If HttpPost->cAcao == "AI"
		nPosProd := aScan( HttpSession->PWST043GRAVA[2], { |x| AllTrim( x:cPRODUCTID ) == AllTrim( HttpPost->cSelItem ) } )

		If nPosProd > 0
		
			If ExistBlock( "PET044" )
				aWebCols := ExecBlock( "PET044", .F., .F., {1} )
			EndIf
		
			GridLinesEX( {	HttpSession->PWST044INFO[1], ;
							HttpSession->PWST041HEADER[1][1], ;
							HttpSession->PWST043GRAVA[1], ;
							aWebCols, .F., "H",,0 },"FSREPAIRCENTER", "AB9" )
	
			aWebCols := {}
	
			If ExistBlock( "PET044" )
				aWebCols := ExecBlock( "PET044", .F., .F., {2} )
			EndIf

			GridLinesEX( {	HttpSession->PWST044INFO[2], ;
							HttpSession->PWST041HEADER[2][1], ;
							HttpSession->PWST043GRAVA[2][nPosProd], ;
							aWebCols, .T., "H",,0 },"FSREPAIRCENTER","ABA" )
		EndIf
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Preenche a session com os campos de usuario³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		PWSPutUsrFld( HttpSession->PWST043GRAVA[1], "AB9", "FSREPAIRCENTER" )
		PWSSetObjToPost( HttpSession->PWST043GRAVA[1], HttpSession->PWST041HEADER[1][1], HttpPost->aPost )

		If ExistBlock( "PET044" )
			aWebCols := ExecBlock( "PET044", .F., .F., {3} )
		EndIf
		
		GridLinesEX( {	HttpSession->PWST044INFO[1], ;
						HttpSession->PWST041HEADER[1][1], ;
						HttpSession->PWST043GRAVA[1], ;
						aWebCols, .F., "H",,0 },"FSREPAIRCENTER","AB9" )
		
		aWebCols := {}
		
		If ExistBlock( "PET044" )
			aWebCols := ExecBlock( "PET044", .F., .F., {4} )
		EndIf
			    
		GridLinesEX( {	HttpSession->PWST044INFO[2], ;
						HttpSession->PWST041HEADER[2][1], ;
						oObjView, ;
						aWebCols, .T., "H",,0 },"FSREPAIRCENTER","ABA" )
	EndIf
EndIf

ExecInPage( "PWST044" )

WEB EXTENDED END

Return cHtml

//**********************************************************************
Web Function PWST044A()

Local cHtml := ""
Local oObj
Local lExclui := .F.
Local aBI := {}
Local aWebCols := {}

WEB EXTENDED INIT cHtml START "InSite"

HttpSession->PWST044AINFO := {}

If HttpSession->_TMPBIBOTOES == "I"
	If HttpPost->cAcao == "EI"
		nPosProd := aScan( HttpSession->PWST043GRAVA[2], { |x| AllTrim( x:cPRODUCTID ) == AllTrim( HttpPost->cSelItem ) } )
		
		If nPosProd > 0
			aDel( HttpSession->PWST043GRAVA[2], nPosProd )
			aSize( HttpSession->PWST043GRAVA[2], Len( HttpSession->PWST043GRAVA[2] ) - 1 )
		EndIf

		If ExistBlock( "PET044A" )
			aWebCols := ExecBlock( "PET044A", .F., .F., {1} )
		EndIf

		GridHeader( HttpSession->PWST044AINFO, HttpSession->PWST041HEADER[2][1], aWebCols )
	
		GridLinesEX( {	HttpSession->PWST044AINFO, ;
						HttpSession->PWST041HEADER[2][1], ;
						HttpSession->PWST043GRAVA[2], ;
						aWebCols, .F., "A",,0 },"FSREPAIRCENTER", "ABA" )
	Else                        
		If ExistBlock( "PET044A" )
			aWebCols := ExecBlock( "PET044A", .F., .F., {2} )
		EndIf	
	
		GridHeader( HttpSession->PWST044AINFO, HttpSession->PWST041HEADER[2][1], aWebCols )
	
		GridLinesEX( {	HttpSession->PWST044AINFO, ;
						HttpSession->PWST041HEADER[2][1], ;
						HttpSession->PWST043GRAVA[2], ;
						aWebCols, .F., "A",,0 },"FSREPAIRCENTER", "ABA" )
	EndIf
EndIf

ExecInPage( "PWST044A" )

WEB EXTENDED END

Return cHtml

//**********************************************************************
Web Function PWST045()

Local cHtml := ""
Local oObj
Local lExclui := .F.
Local oObjView
Local aBI := {}
Local aWebCols := {}

WEB EXTENDED INIT cHtml START "InSite"

oObjView := FSREPAIRCENTER_ANNOTATIONSERVICEORDERITEMVIEW():New()

If HttpSession->_TMPBIBOTOES == "I"
	If HttpPost->cAcao == "II"
		aAdd( HttpSession->PWST043GRAVA[2], FSREPAIRCENTER_ANNOTATIONSERVICEORDERITEMVIEW():New() )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Preenche a session com os campos de usuario³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		PWSPutUsrFld( HttpSession->PWST043GRAVA[2][Len( HttpSession->PWST043GRAVA[2] )], "ABA", "FSREPAIRCENTER" )
		PWSSetObjToPost( HttpSession->PWST043GRAVA[2][Len( HttpSession->PWST043GRAVA[2] )],  HttpSession->PWST041HEADER[2][1], HttpPost->aPost )
		If Len( HttpSession->PWST043GRAVA[2] ) == 1
			HttpSession->PWST043GRAVA[2][Len( HttpSession->PWST043GRAVA[2] )]:cSERVICEORDERITEM := "01"
		Else
			HttpSession->PWST043GRAVA[2][Len( HttpSession->PWST043GRAVA[2] )]:cSERVICEORDERITEM := StrZero( Val( HttpSession->PWST043GRAVA[2][Len( HttpSession->PWST043GRAVA[2] ) - 1]:cSERVICEORDERITEM ) + 1, 2 )
		EndIf
	ElseIf HttpPost->cAcao == "AI"
		nPosProd := aScan( HttpSession->PWST043GRAVA[2], { |x| AllTrim( x:cPRODUCTID ) == AllTrim( HttpPost->cSelItem ) } )
		
		If nPosProd > 0
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Preenche a session com os campos de usuario³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			PWSPutUsrFld( HttpSession->PWST043GRAVA[2][nPosProd], "ABA", "FSREPAIRCENTER" )
			PWSSetObjToPost( HttpSession->PWST043GRAVA[2][nPosProd], HttpSession->PWST041HEADER[2][1], HttpPost->aPost )
		EndIf
		
		HttpSession->PWST044INFO := { {}, {} }
                    
		If ExistBlock( "PET045" )
			aWebCols := ExecBlock( "PET045", .F., .F., {1} )
		EndIf

		GridLinesEX( {	HttpSession->PWST044INFO[1], ;
						HttpSession->PWST041HEADER[1][1], ;
						HttpSession->PWST043GRAVA[1], ;
						aWebCols, .F., "H",,0 }, "FSREPAIRCENTER","AB9" )

		aWebCols := {}

		If ExistBlock( "PET045" )
			aWebCols := ExecBlock( "PET045", .F., .F., {2} )
		EndIf

		GridLinesEX( {	HttpSession->PWST044INFO[2], ;
						HttpSession->PWST041HEADER[2][1], ;
						oObjView, ;                                    
						aWebCols, .T., "H",,0 }, "FSREPAIRCENTER", "ABA" )
		
		HttpPost->cAcao := ""
	EndIf
EndIf

cHtml := ExecInPage( "PWST044" )

WEB EXTENDED END

Return cHtml

//**********************************************************************
Web Function PWST046()    

Local cHtml := ""
Local oObj
Local nI := 0

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSFSREPAIRCENTER():New()
WsChgURL( @oObj, "FSREPAIRCENTER.APW" )
If HttpSession->_TMPBIBOTOES == "I"
	oObj:cUSERCODE		:= "MSALPHA"
	oObj:oWSANNOTATIONSERVICEORDER	:= FSREPAIRCENTER_ANNOTATIONSERVICEORDERVIEW():New()
	oObj:oWSANNOTATIONSERVICEORDER:oWSANNOTATIONSERVICEORDERHEADER := HttpSession->PWST043GRAVA[1]
	oObj:oWSANNOTATIONSERVICEORDER:oWSANNOTATIONSERVICEORDERITEM := FSREPAIRCENTER_ARRAYOFANNOTATIONSERVICEORDERITEMVIEW():New()
		
	For nI := 1 To Len( HttpSession->PWST043GRAVA[2] )
		aAdd( oObj:oWSANNOTATIONSERVICEORDER:oWSANNOTATIONSERVICEORDERITEM:oWSANNOTATIONSERVICEORDERITEMVIEW, FSREPAIRCENTER_ANNOTATIONSERVICEORDERITEMVIEW():New() )
		oObj:oWSANNOTATIONSERVICEORDER:oWSANNOTATIONSERVICEORDERITEM:oWSANNOTATIONSERVICEORDERITEMVIEW[nI] := HttpSession->PWST043GRAVA[2][nI]
	Next nI

	//cUSERCODE,oWSANNOTATIONSERVICEORDER
	If oObj:PUTANNOTATIONSERVICEORDER()
		Return PWSHTMLALERT( "", STR0004, STR0005, "W_PWST040.APW" )//"Atenção","Informações cadastradas com SUCESSO!"
	Else
		Return PWSHTMLALERT( "", STR0003, "", "W_PWST043.APW?cAcao=I" )//"Erro"
	EndIf
EndIf

WEB EXTENDED END

Return cHtml
