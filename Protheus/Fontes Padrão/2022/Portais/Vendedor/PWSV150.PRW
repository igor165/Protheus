#INCLUDE "PWSV150.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"

//-------------------------------------------------------------------------------------------------------
// Tela de Seleção de vendedor - Oportunidade
Web Function PWSV150()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

HTTPPOST->PWSV020VEN	:= GetUserVen()

HttpSession->PWSV020APH := {	STR0001 ,;		// Oportunidade //"Oportunidade"
								"W_PWSV151.APW"	,;	// Proxima Tela
								"" ,;	 			// Msg de Erro
								"150" }				// Função chamadora
										
HttpSession->FONTES := {"W_PWSV150.APW","W_PWSV152.APW"}
	
If Len(HTTPPOST->PWSV020VEN) <= 1   

	HttpSession->PWSV020APH[3] := STR0002 //"Não há vendedores a consultar."
	cHtml += ExecInPage( "PWSV020" )
	
ElseIF Len(HTTPPOST->PWSV020VEN) = 2

	// Apenas 1 vendedor . Define a navegação para pular a tela de seleção de vendedores
	
	HTTPPOST->CODVENERP	:= HTTPPOST->PWSV020VEN[2][2]
	
	cHtml += W_PWSV151()

Else

	// Mais de 1 vendedores ? Chama tela de seleção
	
	cHtml += ExecInPage( "PWSV020" )

Endif

WEB EXTENDED END

Return cHtml


//-------------------------------------------------------------------------------------------------------
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSV151   ºAutor  ³Microsiga            º Data ³  23/03/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela para escolha de oportunidade						   º±±
±±º          ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Portal Protheus                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºCleber M. ³31/03/06³95206 ³-Corrigida a passagem de parametro para a    º±±
±±º          ³        ³      ³GridLinesEx() e a visualizacao dos registros º±±
±±º          ³        ³      ³na pagina.                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSV151()

Local cHtml 	:= ""		//Pagina WEB
Local oObj					//Objeto WS - WSMTSELLEROPPORTUNITY
Local aWebCols 	:= {}		//Array contendo os campos a serem mostrados na tela
Local nX		:= 0		//variavel auxiliar em lacos for...next
Private cMsg 	:= ""		//Mensagem

WEB EXTENDED INIT cHtml START "InSite"

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTSELLEROPPORTUNITY"), WSMTSELLEROPPORTUNITY():NEW() )
WsChgUrl( @oObj, "MTSELLEROPPORTUNITY.apw" )

HttpSession->_BrwOportunidade := {}

If !Empty( HttpPost->CODVENERP )
	HttpSession->CODVENERP := HttpPost->CODVENERP
EndIf

HttpSession->APONT 						:= { MTSELLEROPPORTUNITY_OPPORTUNITYVIEW():New() }
HttpSession->APONT[1]:oWSCOMPETITOR 	:= MTSELLEROPPORTUNITY_ARRAYOFCOMPETITORVIEW():New()
HttpSession->APONT[1]:oWSHEADER 		:= MTSELLEROPPORTUNITY_OPPORTUNITYSTRUCT():New()
HttpSession->APONT[1]:oWSPARTNERS 		:= MTSELLEROPPORTUNITY_ARRAYOFGENERICVIEW():New()
HttpSession->APONT[1]:oWSSALESTEAM 		:= MTSELLEROPPORTUNITY_ARRAYOFGENERICVIEW():New()
HttpSession->APONT[1]:oWSCONTACTS 		:= MTSELLEROPPORTUNITY_ARRAYOFCONTACTVIEW():New()
HttpSession->ACAO 						:= ""

If Empty( HttpSession->PWSV151HEADER )
	HttpSession->PWSV151HEADER := { NIL, NIL, NIL, NIL }
	
	//Header
	If oObj:GETHEADER( "OPPORTUNITYVIEW" )
		HttpSession->PWSV151HEADER[1] := oObj:oWSGETHEADERRESULT:OWSBRWHEADER
	Else
		Return PWSHTMLALERT( "", STR0003, "", "W_PWSV150.APW" ) //"Erro"
	EndIf

	//Competitor
	If oObj:GETHEADER( "COMPETITORVIEW" )
		HttpSession->PWSV151HEADER[2] := oObj:oWSGETHEADERRESULT:OWSBRWHEADER
	Else
		Return PWSHTMLALERT( "", STR0003, "", "W_PWSV150.APW" ) //"Erro"
	EndIf

	//Sales Team, Partner
	If oObj:GETHEADER( "GENERICSTRUCT" )
		HttpSession->PWSV151HEADER[3] := oObj:oWSGETHEADERRESULT:OWSBRWHEADER
	Else
		Return PWSHTMLALERT( "", STR0003, "", "W_PWSV150.APW" ) //"Erro"
	EndIf

	//Contact
	If oObj:GETHEADER( "CONTACTVIEW" )
		HttpSession->PWSV151HEADER[4] := oObj:oWSGETHEADERRESULT:OWSBRWHEADER
	Else
		Return PWSHTMLALERT( "", STR0003, "", "W_PWSV150.APW" ) //"Erro"
	EndIf
EndIf
	
If HttpPost->DataDe == Nil .Or. HttpPost->DataAte == Nil
	HttpPost->Busca := ""
	HttpPost->Tipo  := "1"

	Return ExecInPage( "PWSV151" )
Else
	HttpSession->_BrwOportunidade := {}
	
	If ExistBlock( "PEV151" )
		aWebCols := ExecBlock( "PEV151", .F., .F., {} )
	EndIf

	GridHeader(	HttpSession->_BrwOportunidade ,;
					HttpSession->PWSV151HEADER[1] ,;
					aWebCols )

	oObj:dSTARTDATEFROM	:= CtoD( HttpPost->DataDe )
	oObj:dSTARTDATETO 	:= CtoD( HttpPost->DataAte )
	oObj:cQUERYADDWHERE := ""
	oObj:cINDEXKEY		:= "AD1_NROPOR"

	If oObj:BRWOPPORTUNITY( GetUsrCode(), HttpSession->CODVENERP )

		For nX := 1 to Len(oObj:oWSBRWOPPORTUNITYRESULT:oWSOPPORTUNITYSTRUCT)
			GridLinesEX( {	HttpSession->_BrwOportunidade ,;
							HttpSession->PWSV151HEADER[1],;
							oObj:oWSBRWOPPORTUNITYRESULT:oWSOPPORTUNITYSTRUCT[nX],;
							aWebCols,.F.,"A",,0 } )
		Next nX

	Else
		Return PWSHTMLALERT( "", STR0003, "", "W_PWSV150.APW" ) //"Erro"
	EndIf

EndIf

cHtml += ExecInPage( "PWSV151" )

WEB EXTENDED END

Return cHtml

//-------------------------------------------------------------------------------------------------------
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSV152   ºAutor  ³Microsiga           º Data ³  03/13/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP8                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAndrea F. ³13/03/06³94291 ³- Passagem do nome do Webservice na rotina  º±±
±±º          ³        ³      ³ que monta a gridline para ser possivel     º±±
±±º          ³        ³      ³ iniciar o metodo que inclui os campos cus- º±±
±±º          ³        ³      ³ tomizados no aheader.                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Web Function PWSV152()

Local cHtml 		:= ""
Local aWebCols 		:= {}
Local oObj
Local cNomeWs		:= "MTSELLEROPPORTUNITY"

WEB EXTENDED INIT cHtml START "InSite"

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTSELLEROPPORTUNITY"), WSMTSELLEROPPORTUNITY():NEW() )
WsChgUrl( @oObj, "MTSELLEROPPORTUNITY.apw" )

HttpSession->PWSV152INFO := {}

If ( !Empty( HttpSession->ACAO ) .AND. HttpSession->ACAO == "I" ) .OR. HttpPost->ACAO == "I"
	HttpSession->ACAO := "I"
	
	If HttpPost->ACAO == "GC"
		PWSSetObjToPost( HttpSession->APONT[1]:oWSHEADER, HttpSession->PWSV151HEADER[1], HttpPost->aPost )
	EndIf
	
	//Header
	
	HttpSession->APONT[1]:oWSHEADER:cSELLERCODE := HttpSession->CODVENERP
	
	If Empty( HttpSession->APONT[1]:oWSHEADER:dISSUEDATE )
		HttpSession->APONT[1]:oWSHEADER:dISSUEDATE := Date()
	EndIf

	If Empty( HttpSession->APONT[1]:oWSHEADER:dSTARTDATE )
		HttpSession->APONT[1]:oWSHEADER:dSTARTDATE := Date()
	EndIf

	If Empty( HttpSession->APONT[1]:oWSHEADER:dGOALDATE )
		HttpSession->APONT[1]:oWSHEADER:dGOALDATE := Date()
	EndIf
	                           
	If ExistBlock( "PEV152" )
		aWebCols := ExecBlock( "PEV152", .F., .F., {1} )
	EndIf
	
	GridLinesEX( { HttpSession->PWSV152INFO, HttpSession->PWSV151HEADER[1], ;
				HttpSession->APONT[1]:oWSHEADER, ;
				aWebCols, .T., "H",,0 }, cNomeWs )
				
ElseIf ( !Empty( HttpSession->ACAO ) .AND. ( HttpSession->ACAO == "A" .OR. HttpSession->ACAO == "V" ) ) .OR. ( HttpPost->ACAO == "A" .OR. HttpPost->ACAO == "V" )
	If HttpPost->ACAO == "A"
		HttpSession->ACAO := "A"
	ElseIf HttpPost->ACAO == "V"
		HttpSession->ACAO := "V"
	EndIf
	
	HttpPost->_TMPPEDBOTOES := HttpPost->ACAO
	
	If HttpPost->ACAO == "GC"
		PWSSetObjToPost( HttpSession->APONT[1]:oWSHEADER, HttpSession->PWSV151HEADER[1], HttpPost->aPost )
	EndIf
	
	If !Empty( HttpPost->CODOPP )
		HttpSession->CODOPP := HttpPost->CODOPP
	EndIf
	
	//Header

	If HttpPost->ACAO <> "GC"
		//cUSERCODE,cSELLERCODE,cOPPORTUNITYID
		If oObj:GETOPPORTUNITY( GetUsrCode(), HttpSession->CODVENERP, HttpSession->CODOPP )
			HttpSession->APONT[1] := oObj:oWSGETOPPORTUNITYRESULT
		Else
			Return PWSHTMLALERT( "", STR0003, "", "W_PWSV151.APW" ) //"Erro"
		EndIf
	EndIf                      
	
	If ExistBlock( "PEV152" )
		aWebCols := ExecBlock( "PEV152", .F., .F., {2} )
	EndIf

	GridLinesEX( { HttpSession->PWSV152INFO, HttpSession->PWSV151HEADER[1], ;
				HttpSession->APONT[1]:oWSHEADER, ;
				aWebCols, IIf( HttpSession->ACAO == "V" .OR. HttpPost->ACAO == "V", .F., .T. ), "H",,3 },cNomeWs )
EndIf

cHtml += ExecInPage( "PWSV152" )

WEB EXTENDED END

Return cHtml

//-------------------------------------------------------------------------------------------------------
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSV153   ºAutor  ³Microsiga           º Data ³  03/05/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao p/ pagina de Concorrentes.                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Portal do Vendedor                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºCleber M. ³03/05/06³97030 ³- Efetuado tratamento para quando a pagina  º±±
±±º          ³        ³      ³ for chamada a partir de uma alteracao da   º±±
±±º          ³        ³      ³ Oportunidade.                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSV153()

Local cHtml := ""
Local aWebCols := {}

WEB EXTENDED INIT cHtml START "InSite"

HttpSession->PWSV153INFO := {}

If HttpSession->ACAO == "I" .OR. HttpSession->ACAO == "A"
	If HttpPost->ACAO == "IC"
		aAdd( HttpSession->APONT[1]:oWSCOMPETITOR:oWSCOMPETITORVIEW, MTSELLEROPPORTUNITY_COMPETITORVIEW():New() )
		PWSSetObjToPost( HttpSession->APONT[1]:oWSCOMPETITOR:oWSCOMPETITORVIEW[Len( HttpSession->APONT[1]:oWSCOMPETITOR:oWSCOMPETITORVIEW )], HttpSession->PWSV151HEADER[2], HttpPost->aPost )
	ElseIf HttpPost->ACAO == "AICC"
		nPosConc := aScan( HttpSession->APONT[1]:oWSCOMPETITOR:oWSCOMPETITORVIEW, { |x| x:cCOMPETITORCODE == HttpPost->SelItem } )
		
		If nPosConc > 0
			PWSSetObjToPost( HttpSession->APONT[1]:oWSCOMPETITOR:oWSCOMPETITORVIEW[nPosConc], HttpSession->PWSV151HEADER[2], HttpPost->aPost )
		EndIf
	EndIf

	//Competitor

	If HttpPost->ACAO == "AIC"
		nPosConc := aScan( HttpSession->APONT[1]:oWSCOMPETITOR:oWSCOMPETITORVIEW, { |x| x:cCOMPETITORCODE == HttpPost->SelItem } )
		
		If nPosConc > 0

			If ExistBlock( "PEV153" )
				aWebCols := ExecBlock( "PEV153", .F., .F., {1} )
			EndIf

			GridLinesEX( { HttpSession->PWSV153INFO, HttpSession->PWSV151HEADER[2], ;
						HttpSession->APONT[1]:oWSCOMPETITOR:oWSCOMPETITORVIEW[nPosConc], ;
						aWebCols, .T., "H",,0 } )
			
			HttpPost->_TMPPEDBOTOES := "A"
		EndIf
	Else
	
		If ExistBlock( "PEV153" )
			aWebCols := ExecBlock( "PEV153", .F., .F., {2} )
		EndIf
	
		GridLinesEX( {  HttpSession->PWSV153INFO, HttpSession->PWSV151HEADER[2], ;
						MTSELLEROPPORTUNITY_COMPETITORVIEW():New(), ;
						aWebCols, .T., "H",,0 },"MTSELLEROPPORTUNITY" )
	
		HttpPost->_TMPPEDBOTOES := "I"
		
	EndIf
EndIf

cHtml += ExecInPage( "PWSV153" )

WEB EXTENDED END

Return cHtml

//-------------------------------------------------------------------------------------------------------
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSV153A  ºAutor  ³Microsiga           º Data ³  03/05/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao p/ pagina de Concorrentes.                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Portal do Vendedor                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºCleber M. ³03/05/06³97030 ³- Efetuado tratamento para quando a pagina  º±±
±±º          ³        ³      ³ for chamada a partir de uma alteracao da   º±±
±±º          ³        ³      ³ Oportunidade.                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSV153A()

Local cHtml := ""
Local aWebCols := {}

WEB EXTENDED INIT cHtml START "InSite"

HttpSession->PWSV153AINFO := {}

If HttpSession->ACAO == "I" .OR. HttpSession->ACAO == "A"
	If HttpPost->ACAO == "EIC"
		nPosConc := aScan( HttpSession->APONT[1]:oWSCOMPETITOR:oWSCOMPETITORVIEW, { |x| x:cCOMPETITORCODE == HttpPost->SelItem } )
		
		If nPosConc > 0
			aDel( HttpSession->APONT[1]:oWSCOMPETITOR:oWSCOMPETITORVIEW, nPosConc )
			aSize( HttpSession->APONT[1]:oWSCOMPETITOR:oWSCOMPETITORVIEW, Len( HttpSession->APONT[1]:oWSCOMPETITOR:oWSCOMPETITORVIEW ) - 1 )
		EndIf
	EndIf

	//Competitor
	
	If ExistBlock( "PEV153A" )
		aWebCols := ExecBlock( "PEV153A", .F., .F., {} )
	EndIf
	
	GridHeader( HttpSession->PWSV153AINFO, HttpSession->PWSV151HEADER[2], aWebCols )
	            
	If !Empty( HttpSession->APONT[1]:oWSCOMPETITOR:oWSCOMPETITORVIEW )
		GridLinesEX( { HttpSession->PWSV153AINFO, HttpSession->PWSV151HEADER[2], ;
					HttpSession->APONT[1]:oWSCOMPETITOR:oWSCOMPETITORVIEW, ;
					aWebCols, .F., "A",,0 },"MTSELLEROPPORTUNITY" )
	EndIf
	
	HttpPost->_TMPPEDBOTOES := "I"
EndIf

cHtml += ExecInPage( "PWSV153A" )

WEB EXTENDED END

Return cHtml

//-------------------------------------------------------------------------------------------------------
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSV154   ºAutor  ³Microsiga           º Data ³  03/05/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao p/ pagina de cadastro de Time de Vendas             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Portal do Vendedor                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºCleber M. ³03/05/06³97030 ³- Efetuado tratamento para quando a pagina  º±±
±±º          ³        ³      ³ for chamada a partir de uma alteracao da   º±±
±±º          ³        ³      ³ Oportunidade.                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSV154()

Local cHtml := ""
Local aWebCols := {}

WEB EXTENDED INIT cHtml START "InSite"

HttpSession->PWSV154INFO := {}

If HttpSession->ACAO == "I" .OR. HttpSession->ACAO == "A"
	If HttpPost->ACAO == "ITV"
		aAdd( HttpSession->APONT[1]:oWSSALESTEAM:oWSGENERICVIEW, MTSELLEROPPORTUNITY_GENERICVIEW():New() )
		PWSSetObjToPost( HttpSession->APONT[1]:oWSSALESTEAM:oWSGENERICVIEW[Len( HttpSession->APONT[1]:oWSSALESTEAM:oWSGENERICVIEW )], HttpSession->PWSV151HEADER[3], HttpPost->aPost )
	ElseIf HttpPost->ACAO == "ATVV"
		nPosTV := aScan( HttpSession->APONT[1]:oWSSALESTEAM:oWSGENERICVIEW, { |x| x:cCODE == HttpPost->SelItem } )
		
		If nPosTV > 0
			PWSSetObjToPost( HttpSession->APONT[1]:oWSSALESTEAM:oWSGENERICVIEW[nPosTV], HttpSession->PWSV151HEADER[3], HttpPost->aPost )
		EndIf
	EndIf

	//Sales Team

	If HttpPost->ACAO == "ATV"
		nPosTV := aScan( HttpSession->APONT[1]:oWSSALESTEAM:oWSGENERICVIEW, { |x| x:cCODE == HttpPost->SelItem } )
		
		If nPosTV > 0 
		
			If ExistBlock( "PEV154" )
				aWebCols := ExecBlock( "PEV154", .F., .F., {1} )
			EndIf
		
			GridLinesEX( { HttpSession->PWSV154INFO, HttpSession->PWSV151HEADER[3], ;
						HttpSession->APONT[1]:oWSSALESTEAM:oWSGENERICVIEW[nPosTV], ;
						aWebCols, .T., "H",,0 } )
			
			HttpPost->_TMPPEDBOTOES := "A"
		EndIf
	Else                                      
		If ExistBlock( "PEV154" )
			aWebCols := ExecBlock( "PEV154", .F., .F., {2} )
		EndIf
			
		GridLinesEX( { HttpSession->PWSV154INFO, HttpSession->PWSV151HEADER[3], ;
					MTSELLEROPPORTUNITY_GENERICVIEW():New(), ;
					aWebCols, .T., "H",,0 },"MTSELLEROPPORTUNITY" )
		
		HttpPost->_TMPPEDBOTOES := "I"
	EndIf
EndIf

cHtml += ExecInPage( "PWSV154" )

WEB EXTENDED END

Return cHtml

//-------------------------------------------------------------------------------------------------------
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSV154A  ºAutor  ³Microsiga           º Data ³  03/05/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao p/ pagina de cadastro de Time de Vendas             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Portal do Vendedor                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºCleber M. ³03/05/06³97030 ³- Efetuado tratamento para quando a pagina  º±±
±±º          ³        ³      ³ for chamada a partir de uma alteracao da   º±±
±±º          ³        ³      ³ Oportunidade.                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSV154A()

Local cHtml := ""
Local aWebCols := {}

WEB EXTENDED INIT cHtml START "InSite"

HttpSession->PWSV154AINFO := {}

If HttpSession->ACAO == "I" .OR. HttpSession->ACAO == "A"
	If HttpPost->ACAO == "ETV"
		nPosPart := aScan( HttpSession->APONT[1]:oWSSALESTEAM:oWSGENERICVIEW, { |x| x:cCODE == HttpPost->SelItem } )
		
		If nPosPart > 0
			aDel( HttpSession->APONT[1]:oWSSALESTEAM:oWSGENERICVIEW, nPosPart )
			aSize( HttpSession->APONT[1]:oWSSALESTEAM:oWSGENERICVIEW, Len( HttpSession->APONT[1]:oWSSALESTEAM:oWSGENERICVIEW ) - 1 )
		EndIf
	EndIf

	//Sales Team
	
	If ExistBlock( "PEV154A" )
		aWebCols := ExecBlock( "PEV154A", .F., .F., {} )
	EndIf
	
	GridHeader( HttpSession->PWSV154AINFO, HttpSession->PWSV151HEADER[3], aWebCols )
	            
	If !Empty(HttpSession->APONT[1]:oWSSALESTEAM:oWSGENERICVIEW)
		GridLinesEX( { HttpSession->PWSV154AINFO, HttpSession->PWSV151HEADER[3], ;
					HttpSession->APONT[1]:oWSSALESTEAM:oWSGENERICVIEW, ;
					aWebCols, .F., "A",,0 },"MTSELLEROPPORTUNITY" )
	EndIf
	
	HttpPost->_TMPPEDBOTOES := "I"
EndIf

cHtml += ExecInPage( "PWSV154A" )

WEB EXTENDED END

Return cHtml

//-------------------------------------------------------------------------------------------------------
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSV155   ºAutor  ³Microsiga           º Data ³  03/05/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao p/ pagina de cadastro de Parceiros                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Portal do Vendedor                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºCleber M. ³03/05/06³97030 ³- Efetuado tratamento para quando a pagina  º±±
±±º          ³        ³      ³ for chamada a partir de uma alteracao da   º±±
±±º          ³        ³      ³ Oportunidade.                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSV155()

Local cHtml := ""
Local aWebCols := {}

WEB EXTENDED INIT cHtml START "InSite"

HttpSession->PWSV155INFO := {}

If HttpSession->ACAO == "I" .OR. HttpSession->ACAO == "A"
	If HttpPost->ACAO == "IP"
		aAdd( HttpSession->APONT[1]:oWSPARTNERS:oWSGENERICVIEW, MTSELLEROPPORTUNITY_GENERICVIEW():New() )
		PWSSetObjToPost( HttpSession->APONT[1]:oWSPARTNERS:oWSGENERICVIEW[Len( HttpSession->APONT[1]:oWSPARTNERS:oWSGENERICVIEW )], HttpSession->PWSV151HEADER[3], HttpPost->aPost )
	ElseIf HttpPost->ACAO == "APP"
		nPosTV := aScan( HttpSession->APONT[1]:oWSPARTNERS:oWSGENERICVIEW, { |x| x:cCODE == HttpPost->SelItem } )
		
		If nPosTV > 0
			PWSSetObjToPost( HttpSession->APONT[1]:oWSPARTNERS:oWSGENERICVIEW[nPosTV], HttpSession->PWSV151HEADER[3], HttpPost->aPost )
		EndIf
	EndIf

	//Partners

	If HttpPost->ACAO == "AP"
		nPosPart := aScan( HttpSession->APONT[1]:oWSPARTNERS:oWSGENERICVIEW, { |x| x:cCODE == HttpPost->SelItem } )
		
		If nPosPart > 0             
		
			If ExistBlock( "PEV155" )
				aWebCols := ExecBlock( "PEV155", .F., .F., {1} )
			EndIf
		
			GridLinesEX( { HttpSession->PWSV155INFO, HttpSession->PWSV151HEADER[3], ;
						HttpSession->APONT[1]:oWSPARTNERS:oWSGENERICVIEW[nPosPart], ;
						aWebCols, .T., "H",,0 } )
			
			HttpPost->_TMPPEDBOTOES := "A"
		EndIf
	Else         
		If ExistBlock( "PEV155" )
			aWebCols := ExecBlock( "PEV155", .F., .F., {2} )
		EndIf
		
		GridLinesEX( { HttpSession->PWSV155INFO, HttpSession->PWSV151HEADER[3], ;
					MTSELLEROPPORTUNITY_GENERICVIEW():New(), ;
					aWebCols, .T., "H",,0 },"MTSELLEROPPORTUNITY" )
		
		HttpPost->_TMPPEDBOTOES := "I"
	EndIf
EndIf

cHtml += ExecInPage( "PWSV155" )

WEB EXTENDED END

Return cHtml

//-------------------------------------------------------------------------------------------------------
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSV155A  ºAutor  ³Microsiga           º Data ³  03/05/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao p/ pagina de cadastro de Parceiros                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Portal do Vendedor                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºCleber M. ³03/05/06³97030 ³- Efetuado tratamento para quando a pagina  º±±
±±º          ³        ³      ³ for chamada a partir de uma alteracao da   º±±
±±º          ³        ³      ³ Oportunidade.                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSV155A()

Local cHtml := ""
Local aWebCols := {}

WEB EXTENDED INIT cHtml START "InSite"

HttpSession->PWSV155AINFO := {}

If HttpSession->ACAO == "I" .OR. HttpSession->ACAO == "A"
	If HttpPost->ACAO == "EP"
		nPosTV := aScan( HttpSession->APONT[1]:oWSPARTNERS:oWSGENERICVIEW, { |x| x:cCODE == HttpPost->SelItem } )
		
		If nPosTV > 0
			aDel( HttpSession->APONT[1]:oWSPARTNERS:oWSGENERICVIEW, nPosTV )
			aSize( HttpSession->APONT[1]:oWSPARTNERS:oWSGENERICVIEW, Len( HttpSession->APONT[1]:oWSPARTNERS:oWSGENERICVIEW ) - 1 )
		EndIf
	EndIf

	//Partner
	
	If ExistBlock( "PEV155A" )
		aWebCols := ExecBlock( "PEV155A", .F., .F., {} )
	EndIf	
	
	GridHeader( HttpSession->PWSV155AINFO, HttpSession->PWSV151HEADER[3], aWebCols )
	            
	If !Empty(HttpSession->APONT[1]:oWSPARTNERS:oWSGENERICVIEW)
		GridLinesEX( { HttpSession->PWSV155AINFO, HttpSession->PWSV151HEADER[3], ;
					HttpSession->APONT[1]:oWSPARTNERS:oWSGENERICVIEW, ;
					aWebCols, .F., "A",,0 },"MTSELLEROPPORTUNITY" )
	EndIf
	
	HttpPost->_TMPPEDBOTOES := "I"
EndIf

cHtml += ExecInPage( "PWSV155A" )

WEB EXTENDED END

Return cHtml

//-------------------------------------------------------------------------------------------------------
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSV156   ºAutor  ³Microsiga           º Data ³  03/05/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao p/ pagina de cadastro de Contatos                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Portal do Vendedor                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºCleber M. ³03/05/06³97030 ³- Efetuado tratamento para quando a pagina  º±±
±±º          ³        ³      ³ for chamada a partir de uma alteracao da   º±±
±±º          ³        ³      ³ Oportunidade.                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSV156()

Local cHtml := ""
Local aWebCols := {}

WEB EXTENDED INIT cHtml START "InSite"

HttpSession->PWSV156INFO := {}

If HttpSession->ACAO == "I" .OR. HttpSession->ACAO == "A"
	If HttpPost->ACAO == "ICONT"
		aAdd( HttpSession->APONT[1]:oWSCONTACTS:oWSCONTACTVIEW, MTSELLEROPPORTUNITY_CONTACTVIEW():New() )
		PWSSetObjToPost( HttpSession->APONT[1]:oWSCONTACTS:oWSCONTACTVIEW[Len( HttpSession->APONT[1]:oWSCONTACTS:oWSCONTACTVIEW )], HttpSession->PWSV151HEADER[4], HttpPost->aPost )
	ElseIf HttpPost->ACAO == "ACONTT"
		nPosCont := aScan( HttpSession->APONT[1]:oWSCONTACTS:oWSCONTACTVIEW, { |x| x:cCONTACTID == HttpPost->SelItem } )
		
		If nPosCont > 0
			PWSSetObjToPost( HttpSession->APONT[1]:oWSCONTACTS:oWSCONTACTVIEW[nPosCont], HttpSession->PWSV151HEADER[4], HttpPost->aPost )
		EndIf
	EndIf

	//Contact
      
	If HttpPost->ACAO == "ACONT"
		nPosCont := aScan( HttpSession->APONT[1]:oWSCONTACTS:oWSCONTACTVIEW, { |x| x:cCONTACTID == HttpPost->SelItem } )
		
		If nPosCont > 0      
		
			If ExistBlock( "PEV156" )
				aWebCols := ExecBlock( "PEV156", .F., .F., {1} )
			EndIf
		
			GridLinesEX( { HttpSession->PWSV156INFO, HttpSession->PWSV151HEADER[4], ;
						HttpSession->APONT[1]:oWSCONTACTS:oWSCONTACTVIEW[nPosCont], ;
						aWebCols, .T., "H",,0 } )
			
			HttpPost->_TMPPEDBOTOES := "A"
		EndIf
	Else         
		If ExistBlock( "PEV156" )
			aWebCols := ExecBlock( "PEV156", .F., .F., {2} )
		EndIf
	
		GridLinesEX( { HttpSession->PWSV156INFO, HttpSession->PWSV151HEADER[4], ;
					MTSELLEROPPORTUNITY_CONTACTVIEW():New(), ;
					aWebCols, .T., "H",,0 },"MTSELLEROPPORTUNITY" )
	
		HttpPost->_TMPPEDBOTOES := "I"
	EndIf
EndIf

cHtml += ExecInPage( "PWSV156" )

WEB EXTENDED END

Return cHtml

//-------------------------------------------------------------------------------------------------------
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSV156A  ºAutor  ³Microsiga           º Data ³  03/05/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao p/ pagina de cadastro de Contatos                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Portal do Vendedor                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºCleber M. ³03/05/06³97030 ³- Efetuado tratamento para quando a pagina  º±±
±±º          ³        ³      ³ for chamada a partir de uma alteracao da   º±±
±±º          ³        ³      ³ Oportunidade.                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSV156A()

Local cHtml := ""
Local aWebCols := {}

WEB EXTENDED INIT cHtml START "InSite"

HttpSession->PWSV156AINFO := {}

If HttpSession->ACAO == "I" .OR. HttpSession->ACAO == "A"
	If HttpPost->ACAO == "ECONT"
		nPosCont := aScan( HttpSession->APONT[1]:oWSCONTACTS:oWSCONTACTVIEW, { |x| x:cCONTACTID == HttpPost->SelItem } )
		
		If nPosCont > 0
			aDel( HttpSession->APONT[1]:oWSCONTACTS:oWSCONTACTVIEW, nPosCont )
			aSize( HttpSession->APONT[1]:oWSCONTACTS:oWSCONTACTVIEW, Len( HttpSession->APONT[1]:oWSCONTACTS:oWSCONTACTVIEW ) - 1 )
		EndIf
	EndIf

	//Contact
	
	If ExistBlock( "PEV156A" )
		aWebCols := ExecBlock( "PEV156A", .F., .F., {} )
	EndIf
	
	GridHeader( HttpSession->PWSV156AINFO, HttpSession->PWSV151HEADER[4], aWebCols )
	            
	If !Empty(HttpSession->APONT[1]:oWSCONTACTS:oWSCONTACTVIEW)
		GridLinesEX( { HttpSession->PWSV156AINFO, HttpSession->PWSV151HEADER[4], ;
					HttpSession->APONT[1]:oWSCONTACTS:oWSCONTACTVIEW, ;
					aWebCols, .F., "A",,0 }, "MTSELLEROPPORTUNITY" )
	EndIf
	
	HttpPost->_TMPPEDBOTOES := "I"
EndIf

cHtml += ExecInPage( "PWSV156A" )

WEB EXTENDED END

Return cHtml

//-------------------------------------------------------------------------------------------------------
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSV157   ºAutor  ³Microsiga           º Data ³  03/05/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao que chama o Metodo de gravacao da Oportunidade      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Portal do Vendedor                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSV157()

Local cHtml := ""
Local oObj

WEB EXTENDED INIT cHtml START "InSite"

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTSELLEROPPORTUNITY"), WSMTSELLEROPPORTUNITY():NEW() )
WsChgUrl( @oObj, "MTSELLEROPPORTUNITY.apw" )

PWSSetObjToPost( HttpSession->APONT[1]:oWSHEADER, HttpSession->PWSV151HEADER[1], HttpPost->aPost )

//cUSERCODE,cSELLERCODE,oWSOPPORTUNITY
If oObj:PUTOPPORTUNITY( GetUsrCode(), HttpSession->CODVENERP, HttpSession->APONT[1] )
	Return PWSHTMLALERT( "", STR0005, STR0004, "W_PWSV150.APW" ) //"Informações cadastradas com SUCESSO!"//"Aviso"
Else
	Return PWSHTMLALERT( "", STR0003, "", "W_PWSV152.APW" ) //"Erro"
EndIf

cHtml += ExecInPage( "PWSV156A" )

WEB EXTENDED END

Return cHtml
