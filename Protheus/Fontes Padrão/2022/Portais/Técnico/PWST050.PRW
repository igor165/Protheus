#INCLUDE "PWST050.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"

#DEFINE TECERP_ENTIDADE		1
#DEFINE TECERP_CODIGO		2
#DEFINE TECERP_NOMEFANT		3
#DEFINE TECERP_RAZAOSOC		4
#DEFINE TECERP_CPFCNPJ		5

#DEFINE MYUSERCODE		GetUsrCode()

//**********************************************************************
Web Function PWST050()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

HttpPost->PWST050TEC	:= GetUserTec()

HttpSession->PWST050APH := {	STR0001 ,;			//"Requisição Ordem de Serviço"
								"W_PWST051.APW"	,;
								""	}

If Len(HttpPost->PWST050TEC) <= 1   
	//Nao ha tecnicos a serem consultados
	HttpSession->PWST050APH[3] := STR0002		//"Não há Técnicos a consultar."
	cHtml += ExecInPage( "PWST020" )
ElseIf len(HttpPost->PWST050TEC) = 2 
	//1 tecnico a ser consultado
	HttpPost->CODTECERP	:= HttpPost->PWST050TEC[2][TECERP_CODIGO]
	cHtml += W_PWST051()
Else
	//2 ou mais tecnicos a serem consultados
	cHtml += ExecInPage( "PWST020" )
EndIf

WEB EXTENDED END

Return cHtml

//**********************************************************************
Web Function PWST051()

Local cHtml := ""
Local aWebCols := {}
Local oObj

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSFSREPAIRCENTER():NEW()
WsChgUrl( @oObj, "FSREPAIRCENTER.APW" )

If HttpPost->CODTECERP != Nil
	HttpSession->CODTECERP := HttpPost->CODTECERP
EndIf

If Empty( HttpSession->PWST051HEADER )
	HttpSession->PWST051HEADER := { {}, {} }
	
	If oObj:GETHEADER( "REQUISITIONSERVICEORDERHEADERVIEW" )
		HttpSession->PWST051HEADER[1] := { oObj:oWSGETHEADERRESULT:OWSBRWHEADER }
	Else
		Return PWSHTMLALERT( "", STR0003, "", "W_PWST050.APW" )//"Erro"
	EndIf

	If oObj:GETHEADER( "REQUISITIONSERVICEORDERITEMVIEW" )
		HttpSession->PWST051HEADER[2] := { oObj:oWSGETHEADERRESULT:OWSBRWHEADER }
	Else
		Return PWSHTMLALERT( "", STR0003, "", "W_PWST050.APW" )//"Erro"
	EndIf
EndIf

HttpSession->PWST050INFO := {}
HttpSession->PWST050RESULT := {}

If HttpPost->DataDe == Nil .Or. HttpPost->DataAte == Nil
	HttpPost->Busca := ""
	HttpPost->Tipo  := "1"

	Return ExecInPage( "PWST051" )
Else
	If ExistBlock( "PET051" )
		aWebCols := ExecBlock( "PET051", .F., .F., {} )
	EndIf

	GridHeader(	HttpSession->PWST050INFO, ;
					HttpSession->PWST051HEADER[1][1], ;
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
	If oObj:BRWREQUISITIONSERVICEORDER()
		HttpSession->PWST050RESULT := oObj:oWSBRWREQUISITIONSERVICEORDERRESULT:oWSREQUISITIONSERVICEORDERHEADERVIEW

		GridLinesEX( {	HttpSession->PWST050INFO, ;
						HttpSession->PWST051HEADER[1][1], ;
						HttpSession->PWST050RESULT, ;
						aWebCols, .F., "A", , 0 } )
	Else
		Return PWSHTMLALERT( "", STR0003, "", "W_PWST050.APW" )//"Erro"
	EndIf
EndIf

cHtml += ExecInPage( "PWST051" )

WEB EXTENDED END

Return cHtml

//**********************************************************************
Web Function PWST052()

Local cHtml := ""
Local oObj := Nil
Local aWebCols := {}

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSFSREPAIRCENTER():NEW()
WsChgUrl( @oObj, "FSREPAIRCENTER.APW" )

If !Empty( HttpPost->ERPOSREC )
	HttpSession->PWST052INFO := { {}, {} }
	HttpSession->PWST052RESULT := { NIL, NIL }
	
	If HttpPost->cAcao == "V"
		HttpSession->_TMPOSBOTOES := "V"
	EndIf
	
	oObj:cUSERCODE					:= "MSALPHA"
	oObj:cREQUISITIONSERVICEORDERID	:= HttpPost->ERPOSREC

	//cUSERCODE,cREQUISITIONSERVICEORDERID
	If oObj:GETREQUISITIONSERVICEORDER()
		HttpSession->PWST052RESULT[1] := oObj:oWSGETREQUISITIONSERVICEORDERRESULT:oWSREQUISITIONSERVICEORDERHEADER
		HttpSession->PWST052RESULT[2] := oObj:oWSGETREQUISITIONSERVICEORDERRESULT:oWSREQUISITIONSERVICEORDERITEM:oWSREQUISITIONSERVICEORDERITEMVIEW
	  	 
		If ExistBlock( "PET052" )
			aWebCols := ExecBlock( "PET052", .F., .F., {1} )
		EndIf		
		
		GridLinesEX( {	HttpSession->PWST052INFO[1], ;
						HttpSession->PWST051HEADER[1][1],;
						HttpSession->PWST052RESULT[1], aWebCols, .F., "H",,0 } )
	
		If ExistBlock( "PET052" )
			aWebCols := ExecBlock( "PET052", .F., .F., {2} )
		EndIf

		GridHeader(	HttpSession->PWST052INFO[2], ;
						HttpSession->PWST051HEADER[2][1],;
						aWebCols )

		GridLinesEX( {	HttpSession->PWST052INFO[2], ;
						HttpSession->PWST051HEADER[2][1],;
						HttpSession->PWST052RESULT[2], aWebCols, .F., "A",,0 } )
	Else
		Return PWSHTMLALERT( "", STR0003, "", "W_PWST050.APW" )//"Erro"
	EndIf
	
	If HttpPost->cAcao == "A"
		Return W_PWST053()
	EndIf

	cHtml += ExecInPage( "PWST052" )
Else
	cHtml += ExecInPage( "PWST051" )
EndIf

WEB EXTENDED END

Return cHtml

//**********************************************************************
//mexi aqui........leo

Web Function PWST052A()

Local cHtml := ""
Local aWebCols := {}

WEB EXTENDED INIT cHtml

HttpSession->PWST052AINFO := {}

If HttpSession->_TMPBIBOTOES == "I"

	If ExistBlock( "PET052A" )
		aWebCols := ExecBlock( "PET052A", .F., .F., {} )
	EndIf

	GridHeader( HttpSession->PWST052AINFO, HttpSession->PWST051HEADER[2][1], aWebCols )

	GridLinesEX( {	HttpSession->PWST052AINFO, ;
					HttpSession->PWST051HEADER[2][1], ;
					FSREPAIRCENTER_REQUISITIONSERVICEORDERITEMVIEW():New(), ;
					aWebCols, .F., "A",,0 } )
EndIf

cHtml += ExecInPage( "PWST052A" )

WEB EXTENDED END

Return cHtml

//**********************************************************************
Web Function PWST053()

Local cHtml := ""
Local oObj
Local oObjView
Local aWebCols := {}

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSFSREPAIRCENTER():New()
oObjView := FSREPAIRCENTER_REQUISITIONSERVICEORDERHEADERVIEW():New()

WsChgURL( @oObj, "FSREPAIRCENTER.APW" )

HttpSession->PWST053INFO := { {}, {} }

If HttpPost->cAcao == "I" .OR. HttpGet->cAcao == "I" .OR. HttpPost->cAcao == "A" .OR. HttpGet->cAcao == "A"
	If HttpPost->cAcao == "A"
		HttpSession->PWST053GRAVA := { HttpSession->PWST052RESULT[1], HttpSession->PWST052RESULT[2] }
	ElseIf HttpGet->cAcao <> "I"
		HttpSession->PWST053GRAVA := { FSREPAIRCENTER_REQUISITIONSERVICEORDERHEADERVIEW():New(), {} }
	EndIf
	
	If HttpGet->cAcao == "I"
		HttpPost->cAcao := "A"
	EndIf

	HttpSession->_TMPBIBOTOES := "I"
	
	If HttpPost->cAcao == "A"
		If ExistBlock( "PET053" )
			aWebCols := ExecBlock( "PET053", .F., .F., {1} )
		EndIf	
	
		GridLinesEX( {	HttpSession->PWST053INFO[1], ;
						HttpSession->PWST051HEADER[1][1], ;
						HttpSession->PWST053GRAVA[1], ;
						aWebCols, .T., "H",,0 } )
	Else
		oObjView:dISSUEDATE	:= Date()

		GridLinesEX( {	HttpSession->PWST053INFO[1], ;
						HttpSession->PWST051HEADER[1][1], ;
						oObjView, ;
						aWebCols, .T., "H",,0 } )
	EndIf
ElseIf HttpPost->cAcao == "AC"
	If ExistBlock( "PET053" )
		aWebCols := ExecBlock( "PET053", .F., .F., {2} )
	EndIf

	GridLinesEX( {	HttpSession->PWST053INFO[1], ;
					HttpSession->PWST051HEADER[1][1], ;
					HttpSession->PWST053GRAVA[1], ;
					aWebCols, .T., "H", , 0 } )
EndIf

cHtml += ExecInPage( "PWST053" )

WEB EXTENDED END

Return cHtml

//**********************************************************************
Web Function PWST054()

Local cHtml := ""
Local lExclui := .F.
Local oObjView
Local aBI := {}
local aWebCols := {}

WEB EXTENDED INIT cHtml START "InSite"

oObjView := FSREPAIRCENTER_REQUISITIONSERVICEORDERITEMVIEW():New()

HttpSession->PWST054INFO := { {}, {} }

If HttpSession->_TMPBIBOTOES == "I"
	If HttpPost->cAcao == "AI"
		nPosProd := aScan( HttpSession->PWST053GRAVA[2], { |x| AllTrim( x:cREQUISITIONSERVICEORDERITEM ) == AllTrim( HttpPost->cSelItem ) } )

		If nPosProd > 0
		
			If ExistBlock( "PET054" )
				aWebCols := ExecBlock( "PET054", .F., .F., {1} )
			EndIf
		
			GridLinesEX( {	HttpSession->PWST054INFO[1], ;
							HttpSession->PWST051HEADER[1][1], ;
							HttpSession->PWST053GRAVA[1], ;
							aWebCols, .F., "H",,0 } )
	
			If ExistBlock( "PET054" )
				aWebCols := ExecBlock( "PET054", .F., .F., {2} )
			EndIf

			GridLinesEX( {	HttpSession->PWST054INFO[2], ;
							HttpSession->PWST051HEADER[2][1], ;
							HttpSession->PWST053GRAVA[2][nPosProd], ;
							aWebCols, .T., "H",,0 } )
		EndIf
	Else
		PWSSetObjToPost( HttpSession->PWST053GRAVA[1], HttpSession->PWST051HEADER[1][1], HttpPost->aPost )

		If ExistBlock( "PET054" )
			aWebCols := ExecBlock( "PET054", .F., .F., {3} )
		EndIf
		
		GridLinesEX( {	HttpSession->PWST054INFO[1], ;
						HttpSession->PWST051HEADER[1][1], ;
						HttpSession->PWST053GRAVA[1], ;
						aWebCols, .F., "H",,0 } )
		
		If ExistBlock( "PET054" )
			aWebCols := ExecBlock( "PET054", .F., .F., {4} )
		EndIf
			    
		GridLinesEX( {	HttpSession->PWST054INFO[2], ;
						HttpSession->PWST051HEADER[2][1], ;
						oObjView, ;
						aWebCols, .T., "H",,0 } )
	EndIf
EndIf

ExecInPage( "PWST054" )

WEB EXTENDED END

Return cHtml

//**********************************************************************
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWST054A  ºAutor  ³Microsiga            º Data ³  31/05/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela de alteracao/exclusao do item da Requisicao.           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Portal Protheus                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºCleber M. ³30/10/06³102364³Corrigida a comparacao do item selecionado   º±±
±±º          ³        ³      ³com a variavel cREQUISITIONSERVICEORDERITEM  º±±
±±º          ³        ³      ³nos casos de alteracao e exclusao do item.   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWST054A()

Local cHtml		:= ""	//Pagina HTML a ser usada
Local oObj				//Objeto WS
Local aWebCols 	:= {}	//Array com os campos a serem apresentados

WEB EXTENDED INIT cHtml START "InSite"

HttpSession->PWST054AINFO := {}

If HttpSession->_TMPBIBOTOES == "I"
	If HttpPost->cAcao == "EI"
		nPosProd := aScan( HttpSession->PWST053GRAVA[2], { |x| AllTrim( x:cREQUISITIONSERVICEORDERITEM ) == AllTrim( HttpPost->cSelItem ) } )
		
		If nPosProd > 0
			aDel( HttpSession->PWST053GRAVA[2], nPosProd )
			aSize( HttpSession->PWST053GRAVA[2], Len( HttpSession->PWST053GRAVA[2] ) - 1 )
		EndIf

		If ExistBlock( "PET054A" )
			aWebCols := ExecBlock( "PET054A", .F., .F., {1} )
		EndIf

		GridHeader( HttpSession->PWST054AINFO, HttpSession->PWST051HEADER[2][1], aWebCols )
	
		GridLinesEX( {	HttpSession->PWST054AINFO, ;
						HttpSession->PWST051HEADER[2][1], ;
						HttpSession->PWST053GRAVA[2], ;
						aWebCols, .F., "A",,0 } )
	Else                        
		If ExistBlock( "PET054A" )
			aWebCols := ExecBlock( "PET054A", .F., .F., {2} )
		EndIf	
	
		GridHeader( HttpSession->PWST054AINFO, HttpSession->PWST051HEADER[2][1], aWebCols )
	
		GridLinesEX( {	HttpSession->PWST054AINFO, ;
						HttpSession->PWST051HEADER[2][1], ;
						HttpSession->PWST053GRAVA[2], ;
						aWebCols, .F., "A",,0 } )
	EndIf
EndIf

ExecInPage( "PWST054A" )

WEB EXTENDED END

Return cHtml

//**********************************************************************
Web Function PWST055()

Local cHtml := ""
Local oObj
Local lExclui := .F.
Local oObjView
Local aBI := {}
Local aWebCols := {}

WEB EXTENDED INIT cHtml START "InSite"

oObjView := FSREPAIRCENTER_REQUISITIONSERVICEORDERITEMVIEW():New()

If HttpSession->_TMPBIBOTOES == "I"
	If HttpPost->cAcao == "II"
		aAdd( HttpSession->PWST053GRAVA[2], FSREPAIRCENTER_REQUISITIONSERVICEORDERITEMVIEW():New() )
		PWSSetObjToPost( HttpSession->PWST053GRAVA[2][Len( HttpSession->PWST053GRAVA[2] )],  HttpSession->PWST051HEADER[2][1], HttpPost->aPost )
		If Len( HttpSession->PWST053GRAVA[2] ) == 1
			HttpSession->PWST053GRAVA[2][Len( HttpSession->PWST053GRAVA[2] )]:cREQUISITIONSERVICEORDERITEM := "01"
		Else
			HttpSession->PWST053GRAVA[2][Len( HttpSession->PWST053GRAVA[2] )]:cREQUISITIONSERVICEORDERITEM := StrZero( Val( HttpSession->PWST053GRAVA[2][Len( HttpSession->PWST053GRAVA[2] ) - 1]:cREQUISITIONSERVICEORDERITEM ) + 1, 2 )
		EndIf
	ElseIf HttpPost->cAcao == "AI"
		nPosProd := aScan( HttpSession->PWST053GRAVA[2], { |x| AllTrim( x:cREQUISITIONSERVICEORDERITEM ) == AllTrim( HttpPost->cSelItem ) } )
		
		If nPosProd > 0
			PWSSetObjToPost( HttpSession->PWST053GRAVA[2][nPosProd], HttpSession->PWST051HEADER[2][1], HttpPost->aPost )
		EndIf
		
		HttpSession->PWST054INFO := { {}, {} }
                    
		If ExistBlock( "PET055" )
			aWebCols := ExecBlock( "PET055", .F., .F., {1} )
		EndIf

		GridLinesEX( {	HttpSession->PWST054INFO[1], ;
						HttpSession->PWST051HEADER[1][1], ;
						HttpSession->PWST053GRAVA[1], ;
						aWebCols, .F., "H",,0 } )

		If ExistBlock( "PET055" )
			aWebCols := ExecBlock( "PET055", .F., .F., {2} )
		EndIf

		GridLinesEX( {	HttpSession->PWST054INFO[2], ;
						HttpSession->PWST051HEADER[2][1], ;
						oObjView, ;
						aWebCols, .T., "H",,0 } )
		
		HttpPost->cAcao := ""
	EndIf
EndIf

cHtml := ExecInPage( "PWST054" )

WEB EXTENDED END

Return cHtml

//**********************************************************************
Web Function PWST056()    

Local cHtml := ""
Local oObj
Local nI := 0

WEB EXTENDED INIT cHtml START "InSite"

oObj := WSFSREPAIRCENTER():New()
WsChgURL( @oObj, "FSREPAIRCENTER.APW" )
If HttpSession->_TMPBIBOTOES == "I"
	oObj:cUSERCODE		:= "MSALPHA"
	oObj:oWSREQUISITIONSERVICEORDER	:= FSREPAIRCENTER_REQUISITIONSERVICEORDERVIEW():New()
	oObj:oWSREQUISITIONSERVICEORDER:oWSREQUISITIONSERVICEORDERHEADER := HttpSession->PWST053GRAVA[1]
	oObj:oWSREQUISITIONSERVICEORDER:oWSREQUISITIONSERVICEORDERITEM := FSREPAIRCENTER_ARRAYOFREQUISITIONSERVICEORDERITEMVIEW():New()
		
	For nI := 1 To Len( HttpSession->PWST053GRAVA[2] )
		aAdd( oObj:oWSREQUISITIONSERVICEORDER:oWSREQUISITIONSERVICEORDERITEM:oWSREQUISITIONSERVICEORDERITEMVIEW, FSREPAIRCENTER_REQUISITIONSERVICEORDERITEMVIEW():New() )
		oObj:oWSREQUISITIONSERVICEORDER:oWSREQUISITIONSERVICEORDERITEM:oWSREQUISITIONSERVICEORDERITEMVIEW[nI] := HttpSession->PWST053GRAVA[2][nI]
	Next nI

	//cUSERCODE,oWSREQUISITIONSERVICEORDER
	If oObj:PUTREQUISITIONSERVICEORDER()
		Return PWSHTMLALERT( "", STR0004, STR0005, "W_PWST050.APW" )//"Atenção","Informações cadastradas com SUCESSO!"
	Else
		Return PWSHTMLALERT( "", STR0003, "", "W_PWST053.APW?cAcao=I" )//"Erro"
	EndIf
EndIf

WEB EXTENDED END

Return cHtml