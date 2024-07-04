#INCLUDE "PROTHEUS.CH"
#INCLUDE "PWSV190.CH"
#INCLUDE "APWEBEX.CH"

//-------------------------------------------------------------------------------------------------------
// Tela de Selecao de vendedor - Para processamento de pedidos
Web Function PWSV190()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

HttpPost->PWSV020VEN := GetUserVen()

HttpSession->PWSV020APH := { STR0001, ; //"Contatos"
								"W_PWSV181.APW", ;
								"" }
	
If Len( HttpPost->PWSV020VEN ) <= 1   
	HttpSession->PWSC020APH[3] := STR0002 //"Nao ha vendedores a consultar."

	cHtml += ExecInPage( "PWSV020" )
ElseIf Len( HttpPost->PWSV020VEN ) == 2
	// Apenas 1 vendedor . Define a navegacao para pular a tela de selecao de vendedores
	HttpPost->CODVENERP	:= HttpPost->PWSV020VEN[2][2]

	cHtml += W_PWSV191()
Else
	// Mais de 1 vendedor ? Chama tela de seleção de vendedores
	cHtml += ExecInPage( "PWSV020" )
EndIf

WEB EXTENDED END

Return cHtml

//-------------------------------------------------------------------------------------------------------
Web Function PWSV191()
Local cHtml := ""
Local oObj
Local aWebCols := {}

WEB EXTENDED INIT cHtml START "InSite"

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSFTSELLERANNOTATIONS' ), WSFTSELLERANNOTATIONS():New() )
WsChgURL( @oObj, "FTSELLERANNOTATIONS.APW" )

HttpSession->APONT := NIL
HttpSession->nItem := 0

HttpSession->PWSV191APH := { STR0003, ; //"Apontamentos de Visita"
								"W_PWSV192.APW", ;
								"" }

If !Empty( HttpPost->CODVENERP )
	HttpSession->CODVENERP := HttpPost->CODVENERP
EndIf

If Empty( HttpSession->PWSV191HEADER )
	HttpSession->PWSV191HEADER := {}
	
	//cHEADERTYPE
	If oObj:GETHEADER( "SELLERANNOTATIONHEADER" )
		HttpSession->PWSV191HEADER := oObj:oWSGETHEADERRESULT:oWSBRWHEADER
	Else
		Return PWSHTMLALERT( "", STR0004, "", "W_PWSV190.APW" ) //"Erro"
	EndIf
EndIf

HttpSession->PWSV191RESULT := {}
HttpSession->PWSV191INFO := {}
HttpSession->ACAO := ""

If !Empty( HttpPost->DataDe ) .AND. !Empty( HttpPost->DataAte )
	//cUSERCODE,cSELLERCODE,dDATEFROM,dDATETO
	If oObj:BRWANNOTATIONS( GetUsrCode(), HttpSession->CODVENERP, CToD( HttpPost->DataDe ), CToD( HttpPost->DataAte ) )
		HttpSession->PWSV191RESULT := oObj:oWSBRWANNOTATIONSRESULT:oWSSELLERANNOTATIONHEADER
	Else
		Return PWSHTMLALERT( "", STR0004, "", "W_PWSV190.APW" ) //"Erro"
	EndIf
EndIf

If !Empty( HttpSession->PWSV191RESULT )

	If ExistBlock( "PEV191" )
		aWebCols := ExecBlock( "PEV191", .F., .F., {} )
	EndIf

	GridHeader( HttpSession->PWSV191INFO, HttpSession->PWSV191HEADER, {} )

	GridLinesEX( { HttpSession->PWSV191INFO, HttpSession->PWSV191HEADER, HttpSession->PWSV191RESULT, ;
				aWebCols, .F., "A",,0 }, "FTSELLERANNOTATIONS" )
EndIf

cHtml := ExecInPage( "PWSV191" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSV192   ºAutor  ³Luiz Felipe Couto    º Data ³  22/03/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela com o cabecalho do Apontamento de visita.              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Portal Protheus                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºCleber M. ³13/11/06³111491³Implementado F3 para consulta de cliente na  º±±
±±º          ³        ³      ³inclusao do cabecalho do Apontamento.        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSV192()

Local cHtml := ""
Local oObj, oTemp
Local aWebCols := {}

Private aJsGrid := {}

WEB EXTENDED INIT cHtml START "InSite"

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSFTSELLERANNOTATIONS' ), WSFTSELLERANNOTATIONS():New() )
WsChgURL( @oObj, "FTSELLERANNOTATIONS.APW" )

If Empty( HttpSession->PWSV192HEADER )
	HttpSession->PWSV192HEADER := { NIL, NIL }
	
	If oObj:GETHEADER( "SELLERANNOTATIONHEADER" )
		HttpSession->PWSV192HEADER[1] := oObj:oWSGETHEADERRESULT:oWSBRWHEADER
	Else
		Return PWSHTMLALERT( "", STR0004, "", "W_PWSV191.APW" ) //"Erro"
	EndIf

	If oObj:GETHEADER( "SELLERANNOTATIONITEM" )
		HttpSession->PWSV192HEADER[2] := oObj:oWSGETHEADERRESULT:oWSBRWHEADER
	Else
		Return PWSHTMLALERT( "", STR0004, "", "W_PWSV191.APW" ) //"Erro"
	EndIf
EndIf

If ( !Empty( HttpSession->ACAO ) .AND. HttpSession->ACAO == "I" ) .OR. HttpPost->ACAO == "I"
	HttpSession->ACAO := "I"

	HttpSession->PWSV192INFO := { {}, {} }
	
	//Cabecalho
	oTemp 									:= FTSELLERANNOTATIONS_SELLERANNOTATIONVIEW():New()
	oTemp:oWSHEADER							:= FTSELLERANNOTATIONS_SELLERANNOTATIONHEADER():New()
	oTemp:oWSITEM 							:= FTSELLERANNOTATIONS_ARRAYOFSELLERANNOTATIONITEM():New()

	If Empty( HttpSession->APONT )
		HttpSession->APONT := { oTemp }
	EndIf

	HttpSession->APONT[1]:oWSHEADER:cSELLERCODE := HttpSession->CODVENERP
	HttpSession->APONT[1]:oWSHEADER:dREGISTERDATE := Date()
	                                   
	If ExistBlock( "PEV192" )
		aWebCols := ExecBlock( "PEV192", .F., .F., {1} )
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inclui os campos padroes com consulta F3 p/ cliente ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAdd( aWebCols, "SELLERCODE" )
		aAdd( aWebCols, "REGISTERDATE" )
		aAdd( aWebCols, "CONTACTSEQUENCE" )
		aAdd( aWebCols, { "CUSTOMERCODE", "N", { "BRWCUSTOMER", ;
												{ "CCUSTOMERCODE", "CCODE" }, ;
												{ "CCUSTOMERUNIT", "CUNIT" } ;
												}, ;
												{ "CCODE", "CUNIT", "CDESCRIPTION" } } )
		aAdd( aWebCols, "CUSTOMERUNIT" )
		aAdd( aWebCols, "EVENTCODE" )
		aAdd( aWebCols, "OPPORTUNITYID" )
	EndIf
	
	//aGrid, aHeader, aValores, aWebCols, lInputs, cHtmlArray, cSuffixStr, nJsParam
	GridLinesEX( { HttpSession->PWSV192INFO[1], HttpSession->PWSV192HEADER[1], ;
				HttpSession->APONT[1]:oWSHEADER, ;
				aWebCols, .T., "H",,0 }, "FTSELLERANNOTATIONS","AD5" )
				
ElseIf ( !Empty( HttpSession->ACAO ) .AND. HttpSession->ACAO == "V" ) .OR. HttpPost->ACAO == "V"
	HttpSession->ACAO := "V"
	HttpPost->_TMPPEDBOTOES := "V"

	Return W_PWSV193()
ElseIf ( !Empty( HttpSession->ACAO ) .AND. HttpSession->ACAO == "A" ) .OR. HttpPost->ACAO == "A"
	HttpSession->ACAO := "A"
	HttpPost->_TMPPEDBOTOES := "A"
	
	If !Empty( HttpPost->radio )
		aTemp := Separa( HttpPost->radio, "|" )

		//cUSERCODE,cSELLERCODE,dREGISTERDATE,cCONTACTSEQUENCE
		If oObj:GETANNOTATIONS( GetUsrCode(), HttpSession->CODVENERP, CToD( aTemp[1] ), aTemp[2] )
			HttpSession->APONT := { oObj:oWSGETANNOTATIONSRESULT }
		Else
			Return PWSHTMLALERT( "", STR0004, "", "W_PWSV190.APW" ) //"Erro"
		EndIf
	EndIf

	HttpSession->PWSV192INFO := { {}, {} }
	
	//Cabecalho
	If ExistBlock( "PEV192" )
		aWebCols := ExecBlock( "PEV192", .F., .F., {2} )
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inclui os campos padroes com consulta F3 p/ cliente ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
		aAdd( aWebCols, "SELLERCODE" )
		aAdd( aWebCols, "REGISTERDATE" )
		aAdd( aWebCols, "CONTACTSEQUENCE" )
		aAdd( aWebCols, { "CUSTOMERCODE", "N", { "BRWCUSTOMER", ;
												{ "CCUSTOMERCODE", "CCODE" }, ;
												{ "CCUSTOMERUNIT", "CUNIT" } ;
												}, ;
												{ "CCODE", "CUNIT", "CDESCRIPTION" } } )
		aAdd( aWebCols, "CUSTOMERUNIT" )
		aAdd( aWebCols, "EVENTCODE" )
		aAdd( aWebCols, "OPPORTUNITYID" )	
	EndIf
	
	//aGrid, aHeader, aValores, aWebCols, lInputs, cHtmlArray, cSuffixStr, nJsParam
	GridLinesEX( { HttpSession->PWSV192INFO[1], HttpSession->PWSV192HEADER[1], ;
				HttpSession->APONT[1]:oWSHEADER, ;
				aWebCols, .T., "H",,0 }, "FTSELLERANNOTATIONS" )
EndIf

cHtml += ExecInPage( "PWSV192" )

WEB EXTENDED END

Return cHtml


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSV193   ºAutor  ³Luiz Felipe Couto    º Data ³  22/03/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela para preenchimento dos itens do Apontamento            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Portal Protheus                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºCleber M. ³13/11/06³111491³Implementado F3 para consulta de produto na  º±±
±±º          ³        ³      ³inclusao dos itens do Apontamento.           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSV193()

Local cHtml := ""
Local oObj
Local aWebCols := {}
Local aTemp := {}
Local oITEM
Local nPos 	:= 0//Serv

Private aJsGrid := {}
Private aProp 	:={} //Serv

WEB EXTENDED INIT cHtml START "InSite"

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSFTSELLERANNOTATIONS' ), WSFTSELLERANNOTATIONS():New() )
WsChgURL( @oObj, "FTSELLERANNOTATIONS.APW" )

HttpSession->PWSV192INFO := { {}, {} }

If HttpSession->ACAO == "I" .OR. HttpSession->ACAO == "A"
	If HttpPost->cAct == "IC"
		//Forçar a instancia de campo de usuario no HttpSession
		aProp := PWVPutUsrFld( HttpSession->APONT[1]:oWSHEADER, "AD5", "FTSELLERANNOTATIONS" )
		nPos 	:= aScan( aProp, { |x| x[1] == "OWSUSERFIELDS" } )
		HttpSession->APONT[1]:oWSHEADER:oWSuserfields := aProp[nPos][2]
	
		//oObj, aHeader, aPosts, cSuffix
		PWSSetObjToPost( HttpSession->APONT[1]:oWSHEADER, HttpSession->PWSV192HEADER[1], HttpPost->aPost )
	ElseIf HttpPost->cAct == "IT"
		HttpSession->nItem := HttpSession->nItem + 1
		aadd( HttpSession->APONT[1]:oWSITEM:oWSSELLERANNOTATIONITEM, FTSELLERANNOTATIONS_SELLERANNOTATIONITEM():New() )
		
		//Forçar a instancia de campo de usuario no HttpSession
		aProp := PWVPutUsrFld(HttpSession->APONT[1]:oWSITEM:oWSSELLERANNOTATIONITEM[Len( HttpSession->APONT[1]:oWSITEM:oWSSELLERANNOTATIONITEM )], "AD6", "FTSELLERANNOTATIONS" )
		nPos 	:= aScan( aProp, { |x| x[1] == "OWSUSERFIELDS" } )
		HttpSession->APONT[1]:oWSITEM:oWSSELLERANNOTATIONITEM[Len( HttpSession->APONT[1]:oWSITEM:oWSSELLERANNOTATIONITEM )]:oWSuserfields := aProp[nPos][2]
		
		PWSSetObjToPost( HttpSession->APONT[1]:oWSITEM:oWSSELLERANNOTATIONITEM[Len( HttpSession->APONT[1]:oWSITEM:oWSSELLERANNOTATIONITEM )], HttpSession->PWSV192HEADER[2], HttpPost->aPost )
		CalcTotalItem( HttpSession->APONT[1] )
	ElseIf HttpPost->cAct == "AII"
		nPosItem := aScan( HttpSession->APONT[1]:oWSITEM:oWSSELLERANNOTATIONITEM, { |x| AllTrim( x:cITEM ) == AllTrim( HttpPost->SelItem ) } )
		
		If nPosItem > 0
			PWSSetObjToPost( HttpSession->APONT[1]:oWSITEM:oWSSELLERANNOTATIONITEM[nPosItem], HttpSession->PWSV192HEADER[2], HttpPost->aPost )
			CalcTotalItem( HttpSession->APONT[1] )
		EndIf
	EndIf
	
	//Cabecalho
	If ExistBlock( "PEV193" )
		aWebCols := ExecBlock( "PEV193", .F., .F., {1} )
	EndIf

	GridLinesEX( { 	HttpSession->PWSV192INFO[1],;
					HttpSession->PWSV192HEADER[1],;
					HttpSession->APONT[1]:oWSHEADER, ;
					aWebCols, .F., "H",,0 },"FTSELLERANNOTATIONS" , "AD5")

	//Itens
	If ExistBlock( "PEV193" )
		aWebCols := ExecBlock( "PEV193", .F., .F., {2} )
	Else                                 
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inclui os campos padroes com consulta F3 p/ produto ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAdd( aWebCols, "ITEM" )
		aAdd( aWebCols, { "PRODUCTCODE", "N", { "GETCATALOG", ;
													{ "CPRODUCTCODE", "CPRODUCTCODE" } ;
												}, ;
												{ "CPRODUCTCODE", "CDESCRIPTION" } } )
		aAdd( aWebCols, "QUANTITY" )
		aAdd( aWebCols, "UNITVALUE" )
		aAdd( aWebCols, "TOTALVALUE" )	
	EndIf
	
	If HttpPost->cAct == "AI"
		nPosItem := aScan( HttpSession->APONT[1]:oWSITEM:oWSSELLERANNOTATIONITEM, { |x| AllTrim( x:cITEM ) == AllTrim( HttpPost->SelItem ) } )
		
		If nPosItem > 0
			//aGrid, aHeader, aValores, aWebCols, lInputs, cHtmlArray, cSuffixStr, nJsParam
			GridLinesEX( { 	HttpSession->PWSV192INFO[2],;
							HttpSession->PWSV192HEADER[2], ;
							HttpSession->APONT[1]:oWSITEM:oWSSELLERANNOTATIONITEM[nPosItem], ;
							aWebCols, .T., "H",,0 },"FTSELLERANNOTATIONS","AD6" )
			
			HttpPost->_TMPPEDBOTOES := "A"
		EndIf
	Else
	oITEM:=FTSELLERANNOTATIONS_SELLERANNOTATIONITEM():New()
	If Len(HttpSession->APONT[1]:OWSITEM:OWSSELLERANNOTATIONITEM) > 0
	   oITEM:cITEM:=Val(HttpSession->APONT[1]:OWSITEM:OWSSELLERANNOTATIONITEM[Len(HttpSession->APONT[1]:OWSITEM:OWSSELLERANNOTATIONITEM)]:cItem)+1 
	Else
	   oITEM:cITEM:=1
	EndIf
		GridLinesEX( { 	HttpSession->PWSV192INFO[2],;
						HttpSession->PWSV192HEADER[2], ;
					    oITEM, ;
						aWebCols, .T., "H",,0 }, "FTSELLERANNOTATIONS","AD6" )
		
		HttpPost->_TMPPEDBOTOES := "I"
	EndIf
ElseIf HttpSession->ACAO == "V"
	aTemp := Separa( HttpPost->radio, "|" )

	//cUSERCODE,cSELLERCODE,dREGISTERDATE,cCONTACTSEQUENCE
	If oObj:GETANNOTATIONS( GetUsrCode(), HttpSession->CODVENERP, CToD( aTemp[1] ), aTemp[2] )
		HttpSession->PWSV193RESULT := oObj:oWSGETANNOTATIONSRESULT
	Else
		Return PWSHTMLALERT( "", STR0004, "", "W_PWSV190.APW" ) //"Erro"
	EndIf

	//Cabecalho
	If ExistBlock( "PEV193" )
		aWebCols := ExecBlock( "PEV193", .F., .F., {3} )
	EndIf

	GridLinesEX( { 	HttpSession->PWSV192INFO[1],;
					HttpSession->PWSV192HEADER[1],;
					HttpSession->PWSV193RESULT:oWSHEADER, ;
					aWebCols, .F., "H",,0 }, "FTSELLERANNOTATIONS" ,"AD5" )
EndIf

cHtml += ExecInPage( "PWSV193" )

WEB EXTENDED END

Return cHtml

//-------------------------------------------------------------------------------------------------------
Web Function PWSV193A()

Local cHtml := ""
Local aWebCols := {}
Local nPosItem := 0

WEB EXTENDED INIT cHtml START "InSite"

HttpSession->PWSV193AITEM := {}

If HttpSession->ACAO == "I" .OR. HttpSession->ACAO == "A"
	If HttpPost->cAct == "EI"
		nPosItem := aScan( HttpSession->APONT[1]:oWSITEM:oWSSELLERANNOTATIONITEM, { |x| AllTrim( x:cITEM ) == AllTrim( HttpPost->SelItem ) } )
		
		If nPosItem > 0
			aDel( HttpSession->APONT[1]:oWSITEM:oWSSELLERANNOTATIONITEM, nPosItem )
			aSize( HttpSession->APONT[1]:oWSITEM:oWSSELLERANNOTATIONITEM, Len( HttpSession->APONT[1]:oWSITEM:oWSSELLERANNOTATIONITEM ) - 1 )
		EndIf
	EndIf
	
	//Itens
	If ExistBlock( "PEV193A" )
		aWebCols := ExecBlock( "PEV193A", .F., .F., {1} )
	EndIf

	GridHeader( HttpSession->PWSV193AITEM, HttpSession->PWSV192HEADER[2], aWebCols )
	
	If !Empty( HttpSession->APONT[1]:oWSITEM:oWSSELLERANNOTATIONITEM )
		GridLinesEX( { 	HttpSession->PWSV193AITEM,;
						HttpSession->PWSV192HEADER[2],;
						HttpSession->APONT[1]:oWSITEM:oWSSELLERANNOTATIONITEM, ;
						aWebCols, .F., "A",,0 }, "FTSELLERANNOTATIONS","AD6" )
	EndIf
ElseIf HttpSession->ACAO == "V"
	HttpPost->_TMPPEDBOTOES := "V"

	//Itens
                             
	If ExistBlock( "PEV193A" )
		aWebCols := ExecBlock( "PEV193A", .F., .F., {2} )
	EndIf

	GridHeader( HttpSession->PWSV193AITEM, HttpSession->PWSV192HEADER[2], aWebCols )

	GridLinesEX( { 	HttpSession->PWSV193AITEM,;
					HttpSession->PWSV192HEADER[2], ;
					HttpSession->PWSV193RESULT:oWSITEM:oWSSELLERANNOTATIONITEM, ;
					aWebCols, .F., "A",,0 },"FTSELLERANNOTATIONS" , "AD6")
EndIf

cHtml += ExecInPage( "PWSV193A" )

WEB EXTENDED END

Return cHtml

//-------------------------------------------------------------------------------------------------------
Web Function PWSV194()

Local cHtml := ""
Local oObj

WEB EXTENDED INIT cHtml START "InSite"

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSFTSELLERANNOTATIONS' ), WSFTSELLERANNOTATIONS():New() )
WsChgURL( @oObj, "FTSELLERANNOTATIONS.APW" )

CalcTotalItem( HttpSession->APONT[1] )

//cUSERCODE,cSELLERCODE,oWSANNOTATION
If oObj:PUTANNOTATIONS( GetUsrCode(), HttpSession->CODVENERP, HttpSession->APONT[1] )
	Return PWSHTMLALERT( "", STR0005, STR0006, "W_PWSV190.APW" ) //"Aviso"###"Informações cadastradas com SUCESSO!"
Else
	Return PWSHTMLALERT( "", STR0004, "", "W_PWSV193.APW" ) //"Erro"
EndIf

WEB EXTENDED END

Return cHtml

//-------------------------------------------------------------------------------------------------------
Web Function PWSV195()

Local cHtml := ""
Local oObj
Local aTemp := {}

WEB EXTENDED INIT cHtml START "InSite"

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSFTSELLERANNOTATIONS' ), WSFTSELLERANNOTATIONS():New() )
WsChgURL( @oObj, "FTSELLERANNOTATIONS.APW" )

aTemp := Separa( HttpPost->radio, "|" )

//cUSERCODE,cSELLERCODE,dREGISTERDATE,cCONTACTSEQUENCE
If oObj:DELANNOTATIONS( GetUsrCode(), HttpSession->CODVENERP, CToD( aTemp[1] ), aTemp[2] )
	Return PWSHTMLALERT( "", STR0005, STR0007, "W_PWSV190.APW" ) //"Aviso"###"Apontamento excluído com SUCESSO!"
Else
	Return PWSHTMLALERT( "", STR0004, "", "W_PWSV190.APW" ) //"Erro"
EndIf

WEB EXTENDED END

Return cHtml

//-------------------------------------------------------------------------------------------------------
Function CalcTotalItem( oObjeto )

Local nI := 0

For nI := 1 To Len( oObjeto:oWSITEM:oWSSELLERANNOTATIONITEM )
	oObjeto:oWSITEM:oWSSELLERANNOTATIONITEM[nI]:nTOTALVALUE := oObjeto:oWSITEM:oWSSELLERANNOTATIONITEM[nI]:nUNITVALUE * oObjeto:oWSITEM:oWSSELLERANNOTATIONITEM[nI]:nQUANTITY
Next nI

Return
