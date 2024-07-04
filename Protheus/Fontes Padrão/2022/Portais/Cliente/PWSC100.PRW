#INCLUDE "PWSC100.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"

/*
	Representante Comercial
*/

//-------------------------------------------------------------------------------------------------------------------------
Web Function PWSC100()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

HTTPPOST->PWSC020CLI	:= GetUserCli()

HttpSession->PWSC020APH := {	STR0001 ,;	// Representante Comercial //"Representante Comercial"
										"W_PWSC101.APW"	,;				// Proxima Tela
										"" ,;	 								// Msg de Erro
										"100" }								// Função chamadora
										
If Len(HTTPPOST->PWSC020CLI) <= 1   

	HttpSession->PWSC020APH[3] := STR0002 //"Não há clientes a consultar."
	cHtml += ExecInPage( "PWSC020" )
	
ElseIF Len(HTTPPOST->PWSC020CLI) = 2

	// Apenas 1 cliente . Define a navegação para pular a tela de seleção de cliente
	
	HTTPPOST->CODCLIERP	:= HTTPPOST->PWSC020CLI[2][2]
	
	cHtml += W_PWSC101()

Else

	// Mais de 1 cliente ? Chama tela de seleção de CLientes
	
	cHtml += ExecInPage( "PWSC020" )

Endif

WEB EXTENDED END

Return cHtml


//
Web Function PWSC101()

Local cHtml := ""
Local aWebCols := {}
Local oSeller   := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTCUSTOMERSELLER' ), WSMTCUSTOMERSELLER():NEW() )
Local oCustomer := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTCUSTOMER' ), WSMTCUSTOMER():NEW() )

Private cMsg := ""

WEB EXTENDED INIT cHtml START "InSite"       

WsChgUrl(@oSeller,"MTCUSTOMERSELLER.apw")
WsChgUrl(@oCustomer,"MTCUSTOMER.apw")

HttpPost->TEMPSEL101_1 := {}
HttpPost->TEMPSEL101_2 := {}
HttpPost->TEMPSEL101_3 := {}

If Empty( HttpSession->HEADER101_1 ) .Or. Empty( HttpSession->HEADER101_2 ) .Or. Empty( HttpSession->HEADER101_3 )
	If oSeller:GetHeader("SELLERVIEW")
		HttpSession->HEADER101_1 := oSeller:oWSGETHEADERRESULT:OWSBRWHEADER
	Else
		cMsg := PWSGetWSError()
	EndIf
	If oSeller:GetHeader("ADDRESSVIEW")
		HttpSession->HEADER101_2 := oSeller:oWSGETHEADERRESULT:OWSBRWHEADER
	Else
		cMsg := PWSGetWSError()
	EndIf
	If oSeller:GetHeader("PHONEVIEW")
		HttpSession->HEADER101_3 := oSeller:oWSGETHEADERRESULT:OWSBRWHEADER
	Else
		cMsg := PWSGetWSError()
	EndIf
EndIf

If oCustomer:GETCUSTOMER( GetUsrCode(), HTTPPOST->CODCLIERP )
	If !Empty( oCustomer:oWSGETCUSTOMERRESULT:cSELLERCODE )
		If oSeller:GETSELLER( GetUsrCode(), HTTPPOST->CODCLIERP, oCustomer:oWSGETCUSTOMERRESULT:cSELLERCODE )
                    
		aWebCols := {}    
		
	If ExistBlock( "PEC101" )
		aWebCols := ExecBlock( "PEC101", .F., .F., {} )
	Else
		aWebCols := {}
	EndIf        
		
			GridLinesEx( {	HttpPost->TEMPSEL101_1 ,;
				HttpSession->HEADER101_1,;
				oSeller:oWSGETSELLERRESULT ,;
				aWebCols, .F., "H",, 0 } )
                                               
			GridLinesEx( {	HttpPost->TEMPSEL101_2 ,;
				HttpSession->HEADER101_2,;
				oSeller:oWSGETSELLERRESULT:OWSADDRESSES ,;
				aWebCols, .F., "H",, 0 } )

			GridLinesEx( {	HttpPost->TEMPSEL101_3 ,;
				HttpSession->HEADER101_3,;
				oSeller:oWSGETSELLERRESULT:OWSPHONES:OWSPHONEVIEW ,;
				aWebCols, .F., "H",,0 } )

		Else
			cMsg := PWSGetWSError()
		EndIf
	EndIf
Else
	cMsg := PWSGetWSError()
EndIf

cHtml += ExecInPage( "PWSC101" )

WEB EXTENDED END

Return cHtml