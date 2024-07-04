#INCLUDE "PWSV110.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"

//-------------------------------------------------------------------------------------------------------
// Tela de Seleção de vendedor - Para agenda
Web Function PWSV110()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

HTTPPOST->PWSV020VEN	:= GetUserVen()

HttpSession->PWSV020APH := {	STR0001 ,;	// Processamento de Pedidos //"Agenda"
										"W_PWSV111.APW"	,;				// Proxima Tela
										"" ,;	 								// Msg de Erro
										"110" }								// Função chamadora
										
HttpSession->FONTES := {"W_PWSV110.APW","W_PWSV112.APW"}
	
If Len(HTTPPOST->PWSV020VEN) <= 1   

	HttpSession->PWSV020APH[3] := STR0002 //"Não há vendedores a consultar."
	cHtml += ExecInPage( "PWSV020" )
	
ElseIF Len(HTTPPOST->PWSV020VEN) = 2

	// Apenas 1 vendedor . Define a navegação para pular a tela de seleção de vendedores
	
	HTTPPOST->CODVENERP	:= HTTPPOST->PWSV020VEN[2][2]
	
	cHtml += W_PWSV111()

Else

	// Mais de 1 vendedores ? Chama tela de seleção
	
	cHtml += ExecInPage( "PWSV020" )

Endif

WEB EXTENDED END

Return cHtml


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSV111   ºAutor  ³Luiz Felipe Couto    º Data ³  23/03/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela para busca/escolha de compromissos (Agenda)			   º±±
±±º          ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Portal Protheus                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºCleber M. ³24/03/06³95260 ³- Corrigida a passagem de parametro para a   º±±
±±º          ³        ³      ³GridLinesEx() e a visualizacao dos registros º±±
±±º          ³        ³      ³da Agenda.                                   º±±
±±ºCleber M. ³29/12/06³116083³- Limpa as variaveis HttpSession para dar um º±±
±±º          ³        ³      ³refresh na tela de busca.                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSV111()

Local cHtml 	:= ""							//Pagina Web
Local aWebCols 	:= {}							//Array contendo os campos a serem mostrados na tela
Local oObj 										//Objeto WS - WSFTSELLERCALENDAR
Local nX 		:= 0							//Variavel auxiliar em For...Next
Private cMsg 	:= ""							//Mensagem

WEB EXTENDED INIT cHtml START "InSite"


oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSFTSELLERCALENDAR' ), WSFTSELLERCALENDAR():NEW() )
WsChgUrl(@oObj,"FTSELLERCALENDAR.apw")

HttpSession->oTmp := NIL

HTTPSession->_BrwComp := {}
HTTPSession->_Comps   := {}

If HttpPost->CODVENERP != Nil
	HttpSession->_CODVEN := HttpPost->CODVENERP
	HttpSession->CODVENERP := HttpPost->CODVENERP
EndIf

HttpSession->HEADV110_1 := {}

If oObj:GETHEADER("CALENDARVIEW")
	HttpSession->HEADV110_1 := oObj:oWSGETHEADERRESULT:OWSBRWHEADER
Else
	Return PWSHTMLALERT( "", STR0003, "", "W_PWSV110.APW" ) //"Erro"
EndIf


If HttpPost->DataDe == Nil .Or. HttpPost->DataAte == Nil

	HttpPost->Busca := ""
	HttpPost->Tipo  := "1"

	Return ExecInPage( "PWSV111" )

Else

	HTTPSession->_BrwComp := {}
	HTTPSession->_Comps   := {}
	
	If ExistBlock( "PEV111" )
		aWebCols := ExecBlock( "PEV111", .F., .F., {} )
	EndIf

	GridHeader(	HTTPSession->_BrwComp ,;
					HttpSession->HEADV110_1 ,;
					aWebCols )

	oObj:dDATEFROM	:= CtoD( HttpPost->DataDe )
	oObj:dDATETO 	:= CtoD( HttpPost->DataAte )
	oObj:cQUERYADDWHERE	 	:= ""
	oObj:cINDEXKEY			:= "AD7_DATA"

	If oObj:BRWCALENDAR( GetUsrCode(), HttpSession->_CODVEN )

		HTTPSession->_Comps := oObj:oWSBRWCALENDARRESULT:oWSCALENDARVIEW
		
		For nX := 1 to Len(HTTPSession->_Comps)
			GridLinesEX( {	HTTPSession->_BrwComp ,;
							HttpSession->HEADV110_1,;
							HTTPSession->_Comps[nX] ,;
							aWebCols,.F.,"A",,0 } )
		Next nX

	Else
		Return PWSHTMLALERT( "", STR0003, "", "W_PWSV110.APW" ) //"Erro"
	EndIf

EndIf

cHtml += ExecInPage( "PWSV111" )

WEB EXTENDED END

Return cHtml


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSV112   ºAutor  ³Luiz Felipe Couto    º Data ³  23/03/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela para manutenção de compromissos (Agenda)			   º±±
±±º          ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Portal Protheus                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºCleber M. ³17/11/06³111492³Alteracao na montagem do aWebCols p/ permitirº±±
±±º          ³        ³      ³consulta F3 nos campos Cliente e Prospect.   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSV112()

Local cHtml := ""			//Pagina HTML
Local aWebCols := {}		//Array com os campos a serem apresentados

WEB EXTENDED INIT cHtml START "InSite"

If !Empty( HttpGet->cAct )
	HttpPost->cAct := HttpGet->cAct
EndIf

HttpSession->DetalhesComiss := {}

Do Case
	Case HttpPost->cAct == "V"
	
		If ExistBlock( "PEV112" )
			aWebCols := ExecBlock( "PEV112", .F., .F., {1} )
		EndIf
	
		GridLinesEX( {	HttpSession->DetalhesComiss ,;
						HttpSession->HEADV110_1,;
						HTTPSession->_Comps[ val( HttpPost->radio ) ] ,;
						aWebCols, .F., "H",,0 } )

	Case HttpPost->cAct == "I"
		If Empty( HttpSession->oTmp )
			HttpSession->oTmp := { FTSELLERCALENDAR_CALENDARVIEW():NEW() }
		EndIf
		
		HttpSession->oTmp[1]:dEVENTDATE := Date()
		
		If ExistBlock( "PEV112" )
			aWebCols := ExecBlock( "PEV112", .F., .F., {2} )
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Campos a serem apresentados na pagina ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aAdd(aWebCols, "SUBJECT")
			aAdd(aWebCols, "EVENTDATE")
			aAdd(aWebCols, "STARTTIME")
			aAdd(aWebCols, "ENDTIME")
			aAdd(aWebCols, "NOTE")
			aAdd( aWebCols, { "CUSTOMERCODE", "N", { "BRWCUSTOMER", ;
											{ "CCUSTOMERCODE", "CCODE" }, ;
											{ "CUNITCUSTOMERCODE", "CUNIT" } ;
											}, ;
											{ "CCODE", "CUNIT", "CDESCRIPTION" } } )
			aAdd(aWebCols, "UNITCUSTOMERCODE") 
			aAdd(aWebCols, { "PROSPECTCODE", "N", { "BRWPROSPECT", ;
											{ "CPROSPECTCODE", "CPROSPECTCODE" }, ;
											{ "CUNITPROSPECTCODE", "CUNITPROSPECTCODE" } ;
											}, ;
											{ "CPROSPECTCODE", "CUNITPROSPECTCODE", "CNAME" } } )	
											
			aAdd(aWebCols, "UNITPROSPECTCODE") 
			aAdd(aWebCols, "OPORTUNITY")  
			aAdd(aWebCols, "CONTACT")
		EndIf
		
		GridLinesEX( {	HttpSession->DetalhesComiss ,;
						HttpSession->HEADV110_1,;
						HttpSession->oTmp[1] ,;
						aWebCols, .T., "H",,0 },"FTSELLERCALENDAR" )

		
	Case HttpPost->cAct == "A" 
	
		If ExistBlock( "PEV112" )
			aWebCols := ExecBlock( "PEV112", .F., .F., {3} )
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Campos a serem apresentados na pagina ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aAdd(aWebCols, "SUBJECT")
			aAdd(aWebCols, "EVENTDATE")
			aAdd(aWebCols, "STARTTIME")
			aAdd(aWebCols, "ENDTIME")
			aAdd(aWebCols, "NOTE")
			aAdd( aWebCols, { "CUSTOMERCODE", "N", { "BRWCUSTOMER", ;
											{ "CCUSTOMERCODE", "CCODE" }, ;
											{ "CUNITCUSTOMERCODE", "CUNIT" } ;
											}, ;
											{ "CCODE", "CUNIT", "CDESCRIPTION" } } )
			aAdd(aWebCols, "UNITCUSTOMERCODE") 
			aAdd(aWebCols, { "PROSPECTCODE", "N", { "BRWPROSPECT", ;
											{ "CPROSPECTCODE", "CPROSPECTCODE" }, ;
											{ "CUNITPROSPECTCODE", "CUNITPROSPECTCODE" } ;
											}, ;
											{ "CPROSPECTCODE", "CUNITPROSPECTCODE", "CNAME" } } )	
											
			aAdd(aWebCols, "UNITPROSPECTCODE") 
			aAdd(aWebCols, "OPORTUNITY")  
			aAdd(aWebCols, "CONTACT")
		EndIf
	
		GridLinesEX( {	HttpSession->DetalhesComiss ,;
						HttpSession->HEADV110_1,;
						HTTPSession->_Comps[ val( HttpPost->radio ) ] ,;
						aWebCols, .T., "H",,0 } )
	
	Case HttpPost->cAct == "E"
	
		If ExistBlock( "PEV112" )
			aWebCols := ExecBlock( "PEV112", .F., .F., {4} )
		EndIf         
	
		GridLinesEX( {	HttpSession->DetalhesComiss ,;
						HttpSession->HEADV110_1,;
						HTTPSession->_Comps[ val( HttpPost->radio ) ] ,;
						aWebCols, .F., "H",,0 } )
	OtherWise
		// Se não entrou em nada é erro, então volto para a tela de consulta....
		Return W_PWSV111()
EndCase

cHtml += ExecInPage( "PWSV112" )

WEB EXTENDED END

Return cHtml


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSV113   ºAutor  ³Luiz Felipe Couto    º Data ³  27/04/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela para manutenção de compromissos (Agenda)			   º±±
±±º          ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Portal Protheus                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºCleber M. ³11/05/06³98456 ³- Inicializada a variavel de objeto oTmp que º±±
±±º          ³        ³      ³sera usada na alteracao da agenda.           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSV113()

Local cHtml := ""										//Pagina Web
Local oObj												//Objeto WS - WSFTSELLERCALENDAR
Local oTmp	:= FTSELLERCALENDAR_CALENDARVIEW():NEW()	//Objeto WS - FTSELLERCALENDAR_CALENDARVIEW

Private cMsg := ""

WEB EXTENDED INIT cHtml START "InSite"

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSFTSELLERCALENDAR' ), WSFTSELLERCALENDAR():NEW() )
WsChgUrl(@oObj,"FTSELLERCALENDAR.apw")

Do Case
	Case HttpPost->cAct == "I"
		PWSSetObjToPost( HttpSession->oTmp[1], HttpSession->HEADV110_1, HttpPost->aPost )
		If oObj:PUTCALENDAR( GetUsrCode(), HttpSession->_CODVEN, HttpSession->oTmp[1] )
			Return PWSHTMLALERT( "", STR0004, STR0005 + oObj:cPUTCALENDARRESULT + STR0006, "W_PWSV110.APW" ) //"Aviso"###"Compromisso número: "###" incluido com sucesso."
		Else
			Return PWSHTMLALERT( "", STR0003, "", "W_PWSV112.APW?cAct=I" ) //"Erro"
		EndIf
		
	Case HttpPost->cAct == "A"
		PWSSetObjToPost( oTmp, HttpSession->HEADV110_1, HttpPost->aPost )
		If oObj:PUTCALENDAR( GetUsrCode(), HttpSession->_CODVEN, oTmp )
			cMsg := STR0005 + oObj:cPUTCALENDARRESULT + STR0007 //"Compromisso número: "###" alterado com sucesso."
			Return PWSHTMLALERT( "", STR0004, cMsg, "W_PWSV110.APW" ) //"Aviso"
		Else
			Return PWSHTMLALERT( "", STR0003, "", "W_PWSV111.APW" ) //"Erro"
		EndIf
	
	Case HttpPost->cAct == "E"
		If oObj:DELCALENDAR( GetUsrCode(), HttpSession->_CODVEN, HTTPSession->_Comps[ val( HttpPost->cPos ) ] )
			cMsg := STR0005 + oObj:cDELCALENDARRESULT + STR0008 //"Compromisso número: "###" excluido com sucesso."
			Return PWSHTMLALERT( "", STR0004, cMsg, "W_PWSV110.APW" ) //"Aviso"
		Else
			Return PWSHTMLALERT( "", STR0003, "", "W_PWSV111.APW" ) //"Erro"
		EndIf
	
	OtherWise
		// Se não entrou em nada é erro, então volto para a tela de consulta....
		Return W_PWSV111()
EndCase

cHtml += ExecInPage( "PWSV113" )

WEB EXTENDED END

Return cHtml
