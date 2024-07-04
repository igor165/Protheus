#INCLUDE "PWSC130.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"

#DEFINE CLIERP_ENTIDADE		1
#DEFINE CLIERP_CODIGO		2
#DEFINE CLIERP_NOMEFANT		3
#DEFINE CLIERP_RAZAOSOC		4
#DEFINE CLIERP_CPFCNPJ		5

#DEFINE MYUSERCODE		GetUsrCode()

//**********************************************************************
Web Function PWSC130()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

HttpPost->PWSC130CLI	:= GetUserCLI()

HttpSession->PWSC130APH := {	STR0001 ,;			//"Previsão de Venda"
								"W_PWSC131.APW"	,;
								""	}

If Len(HttpPost->PWSC130CLI) <= 1   
	//Nao ha CLIentes a serem consultados
	HttpSession->PWSC130APH[3] := STR0002 //"Não há Clientes a consultar."
	cHtml += ExecInPage( "PWSC020" )
ElseIf len(HttpPost->PWSC130CLI) = 2 
	//1 Cliente a ser consultado
	HttpPost->CODCLIERP	:= HttpPost->PWSC130CLI[2][CLIERP_CODIGO]
	cHtml += W_PWSC131()
Else
	//2 ou mais Clientes a serem consultados
	cHtml += ExecInPage( "PWSC020" )
EndIf

WEB EXTENDED END

Return cHtml

//**********************************************************************
Web Function PWSC131()

Local cHtml := ""
Local aWebHeader := {}
Local oObj

WEB EXTENDED INIT cHtml START "InSite"

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTSALESFORECAST' ), WSMTSALESFORECAST():New() )
WsChgUrl( @oObj, "MTSALESFORECAST.APW" )

If HttpPost->CODCLIERP != Nil
	HttpSession->CODCLIERP := HttpPost->CODCLIERP
EndIf

If Empty( HttpSession->HEADER131_1 )
	HttpSession->HEADER131_1 := {}
	
	If oObj:GETHEADER( "SALESFORECASTVIEW" )
		HttpSession->HEADER131_1 := oObj:oWSGETHEADERRESULT:OWSBRWHEADER
	Else
		Return PWSHTMLALERT( "", STR0003, "", "W_PWSC130.APW" )//"Erro"
	EndIf
EndIf

HttpSession->PWSC130INFO := {}
HttpSession->PWSC130RESULT := {}

If HttpPost->DataDe == Nil .Or. HttpPost->DataAte == Nil
	HttpPost->Busca := ""
	HttpPost->Tipo  := "1"

	Return ExecInPage( "PWSC131" )
Else
	aWebHeader := {}
	      
	GridHeader(	HttpSession->PWSC130INFO, ;
					HttpSession->HEADER131_1, ;
					aWebHeader )	//{}

	If Empty( HttpGet->cPagina )
		HttpGet->cPagina := "0"
	EndIf

	oObj:cUSERCODE			:= "MSALPHA"
//	oObj:cPRODUCTCODE		:= HttpPost->ERPPROD //perguntar
	oObj:dFORECASTDATEFROM	:= CToD( HttpPost->DataDe )
	oObj:dFORECASTDATETO	:= CToD( HttpPost->DataAte )
	oObj:cQUERYADDWHERE		:= ""
	oObj:cINDEXKEY			:= ""
	oObj:nPAGELEN			:= 10
	oObj:nPAGEFIRST			:= ( Val( HttpGet->cPagina ) * 10 ) + 1

	//UserCode,ProductCode,ForecastDateFrom,ForecastDateTo,PageLen,PageFirst,QueryAddWhere,IndexKey
	If oObj:BrwSalesForecast()
		HttpSession->PWSC130RESULT := oObj:oWSBRWSALESFORECASTRESULT:oWSSALESFORECASTVIEW

//varinfo('',HttpSession->PWSC130RESULT)
		GridLinesEX( {	HttpSession->PWSC130INFO, ;
						HttpSession->HEADER131_1, ;
						HttpSession->PWSC130RESULT, ;
						aWebHeader,.F.,"A",,0 } )
	Else
		Return PWSHTMLALERT( "", STR0003, "", "W_PWSC130.APW" )//"Erro"
	EndIf
EndIf

cHtml += ExecInPage( "PWSC131" )

WEB EXTENDED END

Return cHtml

//**********************************************************************
Web Function PWSC132()

Local cHtml := ""
Local oObj

WEB EXTENDED INIT cHtml START "InSite"

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTSALESFORECAST' ), WSMTSALESFORECAST():New() )
WsChgUrl( @oObj, "MTSALESFORECAST.APW" )

If !Empty( HttpPost->ERPPROD ) //->>>>>>>>> HttpPost->ERPPROD

	HttpSession->PWSC132INFO := {}
	HttpSession->PWSC132RESULT := NIL
	
	If HttpPost->cAcao == "V"
		HttpSession->_TMPOSBOTOES := "V"
	EndIf
	
	oObj:cUSERCODE						:= "MSALPHA"
	oObj:cProductCode					:= Httppost->ERPPROD
	
	//UserCode,ProductCode
	If oObj:GetSalesForecast()
		HttpSession->PWSC132RESULT := oObj:oWSGETSALESFORECASTRESULT

        varinfo('', HttpSession->PWSC132RESULT)
		GridLinesEX( {	HttpSession->PWSC132INFO,;
						HttpSession->HEADER131_1,;
						HttpSession->PWSC132RESULT, {}, .F., "H",,0 } )
	Else
		Return PWSHTMLALERT( "", STR0003, "", "W_PWSC130.APW" )//"Erro"
	EndIf

	cHtml += ExecInPage( "PWSC132" )
Else
	cHtml += ExecInPage( "PWSC131" )
EndIf

WEB EXTENDED END

Return cHtml

//**********************************************************************
Web Function PWSC133()

Local cHtml := ""
Local oObj
Local aWebHeader := {}


WEB EXTENDED INIT cHtml START "InSite"

oObj 		:= IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTSALESFORECAST' ), WSMTSALESFORECAST():New() )
oObjView 	:= MTSALESFORECAST_SALESFORECASTVIEW():New()

WsChgURL( @oObj, "MTSALESFORECAST.APW" )

HttpSession->PWSC133INFO := {}

If HttpPost->cAcao == "I"
	HttpSession->_TMPOSBOTOES := "I"

	   	aAdd( aWebHeader, "PRODUCTCODE" )
		aAdd( aWebHeader, "WAREHOUSE" )
		aAdd( aWebHeader, "DOCUMENT" )
		aAdd( aWebHeader, "QUANTITY" )
		aAdd( aWebHeader, "VALUE" )
		aAdd( aWebHeader, "FORECASTDATE" )
		aAdd( aWebHeader, "NOTE" )
	     
	oObjView:dFORECASTDATE		:= Date()
	
	GridLinesEX( {	HttpSession->PWSC133INFO, ;
					HttpSession->HEADER131_1, ;
					oObjView, ;
					aWebHeader, .T., "H",,0 } )
ElseIf HttpPost->cAcao == "A"
	HttpSession->_TMPOSBOTOES := "A"
	
	oObj:cUSERCODE			:= "MSALPHA"
	oObj:cProductCode		:= HttpPost->ERPPROD
	
	//UserCode,ProductCode
	If oObj:GetSalesForecast()
		HttpSession->PWSC133SALLES := { oObj:oWSGETSALESFORECASTRESULT }
	Else
		Return PWSHTMLALERT( "", STR0003, "", "W_PWSC130.APW" )//"Erro"
	EndIf
	
	   	aAdd( aWebHeader, "PRODUCTCODE" )
		aAdd( aWebHeader, "WAREHOUSE" )
		aAdd( aWebHeader, "DOCUMENT" )
		aAdd( aWebHeader, "QUANTITY" )
		aAdd( aWebHeader, "VALUE" )
		aAdd( aWebHeader, "FORECASTDATE" )
		aAdd( aWebHeader, "NOTE" )
     
varinfo('', aWebHeader)
	GridLinesEX( {	HttpSession->PWSC133INFO, ;
					HttpSession->HEADER131_1, ;
					HttpSession->PWSC133SALLES[1], ;
					aWebHeader, .T., "H",,0 } ) //aWebHeader
ElseIf HttpPost->cAcao == "E"
	HttpSession->_TMPOSBOTOES := "E"
	
	oObj:cUSERCODE			:= "MSALPHA"
	oObj:cProductCode		:= HttpPost->ERPPROD
	
	//UserCode,ProductCode
	If oObj:GetSalesForecast()
		HttpSession->PWSC133SALLES := { oObj:oWSGETSALESFORECASTRESULT }
		varinfo('', HttpSession->PWSC133SALLES)
	Else
		Return PWSHTMLALERT( "", STR0003, "", "W_PWSC130.APW" )//"Erro"
	EndIf
	
	GridLinesEX( {	HttpSession->PWSC133INFO, ;
					HttpSession->HEADER131_1, ;
					HttpSession->PWSC133SALLES[1], ;
					{}, .F., "H",,0 } )//aWebHeader
EndIf

cHtml += ExecInPage( "PWSC132" )

WEB EXTENDED END

Return cHtml

//**********************************************************************
Web Function PWSC134()

Local cHtml := ""
Local oObj
Local lExclui := .F.
Local oObjInclui := MTSALESFORECAST_SALESFORECASTVIEW():NEW()

WEB EXTENDED INIT cHtml START "InSite"

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTSALESFORECAST' ), WSMTSALESFORECAST():New() )
WsChgUrl( @oObj, "MTSALESFORECAST.APW" )

If HttpSession->_TMPOSBOTOES == "I"
	PWSSetObjtoPost(oObjInclui, httpsession->Header131_1, httppost->aPost)
	oObj:cUSERCODE				:= "MSALPHA"
	oObj:cPRODUCTCODE			:= HttpSession->CODCLIERP
	oObj:oWSSALESFORECAST		:= oObjInclui
ElseIf HttpSession->_TMPOSBOTOES == "A"
	oObj:cUSERCODE				:= "MSALPHA"
	oObj:cPRODUCTCODE			:= HttpPost->ERPPROD
	oObj:oWSSALESFORECAST		:= MTSALESFORECAST_SALESFORECASTVIEW():New()
ElseIf HttpSession->_TMPOSBOTOES == "E"
	lExclui := .T.
	oObj:cUSERCODE				:= "MSALPHA"
	oObj:cPRODUCTCODE			:= HttpPost->ERPPROD
	oObj:oWSSALESFORECAST		:= HttpSession->PWSC133SALLES[1]
	varinfo('', HttpSession->PWSC133SALLES[1])
EndIf

If !lExclui
	PWSSetObjToPost( oObj:oWSSALESFORECAST, HttpSession->HEADER131_1, HttpPost->aPost )
	
	//cUSERCODE,oWSSALESFORECAST
	If oObj:PUTSALESFORECAST()
		Return PWSHTMLALERT( "", STR0004, STR0005, "W_PWSC130.APW" )//"Aviso","Informações cadastradas com SUCESSO!"
	Else
		Return PWSHTMLALERT( "", STR0003, "", "W_PWSC130.APW" )//"Erro"
	EndIf
Else
	//cUSERCODE,cPRODUCTCODE
	If oObj:DELSALESFORECAST()
		Return PWSHTMLALERT( "", STR0004, STR0005, "W_PWSC130.APW" )//"Aviso","Informações excluídas com SUCESSO!"
	Else
		Return PWSHTMLALERT( "", STR0003, "", "W_PWSC130.APW" )//"Erro"
	EndIf
EndIf

WEB EXTENDED END

Return cHtml