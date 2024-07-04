#INCLUDE "PWSC080.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"

/**************************************************************************************************/
//Tela de selecao de Clientes
Web Function PWSC080()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

HttpPost->PWSC020CLI := GetUserCli()

HttpSession->PWSC020APH := { STR0014, ;					//"Orçamentos e Cotações"
								"W_PWSC081.APW", ;		// Proxima Tela
								""	} 					// Msg de Erro

If Len( HttpPost->PWSC020CLI ) <= 1
	HttpSession->PWSC020APH[3] := STR0002 //"Não há clientes a consultar."

	cHtml += ExecInPage( "PWSC020" )
ElseIf Len(HttpPost->PWSC020CLI) = 2
	//Apenas 1 cliente. Define a navegação para pular a tela de seleção de cliente
	HttpPost->CODCLIERP	:= HttpPost->PWSC020CLI[2][2]

	cHtml += W_PWSC081()
Else
	//Mais de 1 cliente? Chama tela de seleção de CLientes
	cHtml += ExecInPage( "PWSC020" )
EndIf

WEB EXTENDED END

Return cHtml

/**************************************************************************************************/
// Tela para escolha de pedidos
Web Function PWSC081()

Local cHtml := ""
Local oObj

WEB EXTENDED INIT cHtml START "InSite"

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTCUSTOMERBUDGET' ), WSMTCUSTOMERBUDGET():New() )
WsChgURL( @oObj, "MTCUSTOMERBUDGET.APW" )

If !Empty( HttpPost->CODCLIERP )
	HttpSession->CODCLIERP := HttpPost->CODCLIERP
EndIf

If Empty( HttpSession->PWSC082HEADER )
	HttpSession->PWSC082HEADER := { {}, {} }
	
	If oObj:GETHEADER( "BUDGETHEADERVIEW" )
		HttpSession->PWSC082HEADER[1] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
	Else
		Return PWSHTMLALERT( "", STR0015, "", "W_PWSC080.APW" )//"Erro"
	EndIf

	If oObj:GETHEADER( "BUDGETITENSVIEW" )
		HttpSession->PWSC082HEADER[2] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
	Else
		Return PWSHTMLALERT( "", STR0015, "", "W_PWSC080.APW" )//"Erro"
	EndIf
EndIf

HttpSession->PWSC084GRAVA := {}
HttpSession->PWSC081APH := { STR0001, "W_PWSC082.APW", "W_PWSC084.APW" }//"Processamento de Orçamentos"

cHtml += ExecInPage( "PWSC081" )

WEB EXTENDED END

Return cHtml

/**************************************************************************************************/
// Tela para escolha de pedidos
Web Function PWSC082()

Local cHtml 	:= ""
Local oObj
Local oObjTotalSO
Local aWebCols 	:= {}

WEB EXTENDED INIT cHtml START "InSite"

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTCUSTOMERBUDGET' ), WSMTCUSTOMERBUDGET():New() )
oObjTotalSO :=  IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTCUSTOMERBUDGET' ), WSMTCUSTOMERBUDGET():New() )
WsChgURL( @oObj, "MTCUSTOMERBUDGET.APW" )
WsChgURL( @oObjTotalSO, "MTCUSTOMERBUDGET.APW" )

HttpSession->PWSC082APH := { STR0016, "W_PWSC083.APW" }//"Resultado Busca"

If Empty( HttpGet->cPagina )
	HttpGet->cPagina := "0"
EndIf

If ( !Empty( HttpGet->dREGISTERDATEFROM ) .AND. !Empty( HttpGet->dREGISTERDATETO ) ) .OR. ;
	( !Empty( HttpGet->cBIDNUMBERFROM ) .AND. !Empty( HttpGet->cBIDNUMBERFROM ) )
	
	HttpPost->dREGISTERDATEFROM := HttpGet->dREGISTERDATEFROM
	HttpPost->dREGISTERDATETO := HttpGet->dREGISTERDATETO
	HttpPost->cBIDNUMBERFROM := HttpGet->cBIDNUMBERFROM
	HttpPost->cBIDNUMBERFROM := HttpGet->cBIDNUMBERFROM
EndIf

oObj:cUSERCODE			:= GetUsrCode()
oObj:cCUSTOMERID		:= HttpSession->CODCLIERP
oObj:dREGISTERDATEFROM	:= CToD( HttpPost->dREGISTERDATEFROM )
oObj:dREGISTERDATETO	:= CToD( HttpPost->dREGISTERDATETO )
oObj:nPAGELEN			:= 10
oObj:nPAGEFIRST			:= ( Val( HttpGet->cPagina ) * 10 ) + 1

oObjTotalSO:cUSERCODE			:= GetUsrCode()
oObjTotalSO:cCUSTOMERID			:= HttpSession->CODCLIERP
oObjTotalSO:dREGISTERDATEFROM	:= CToD( HttpPost->dREGISTERDATEFROM )
oObjTotalSO:dREGISTERDATETO		:= CToD( HttpPost->dREGISTERDATETO )

If !Empty( HttpPost->cBuscaAv )
	Do Case
		Case HttpPost->cComboAv == "1"
			oObj:cQUERYADDWHERE			:= "SCJ.CJ_NUM='" + HttpPost->cBuscaAv + "'"
			oObjTotalSO:cQUERYADDWHERE	:= "SCJ.CJ_NUM='" + HttpPost->cBuscaAv + "'"
		Case HttpPost->cComboAv == "2"
			oObj:cQUERYADDWHERE			:= "SCJ.CJ_COTCLI='" + HttpPost->cBuscaAv + "'"
			oObjTotalSO:cQUERYADDWHERE	:= "SCJ.CJ_COTCLI='" + HttpPost->cBuscaAv + "'"
	EndCase
Else
	oObj:cQUERYADDWHERE			:= ""
	oObjTotalSO:cQUERYADDWHERE	:= ""
EndIf

//cUSERCODE,cCUSTOMERID,dREGISTERDATEFROM,dREGISTERDATETO,cQUOTATIONORORDERIDFROM,cQUOTATIONORORDERIDTO,cQUERYADDWHERE,cINDEXKEY,nPAGELEN,nPAGEFIRST
If oObj:BRWBUDGET()
	If HttpPost->cBusca == "1" .OR. HttpPost->cBusca == "2"
		//cUSERCODE,cCUSTOMERID,dREGISTERDATEFROM,dREGISTERDATETO,cQUOTATIONORORDERIDFROM,cQUOTATIONORORDERIDTO,cQUERYADDWHERE
		If oObjTotalSO:BRWTOTALBUDGET()
			HttpSession->nTotalSO := oObjTotalSO:nBRWTOTALBUDGETRESULT
		Else
			Return PWSHTMLALERT( "", STR0015, "", "W_PWSC080.APW" )//"Erro"
		EndIf
	EndIf

	HttpSession->PWSC082RESULT := { oObj:oWSBRWBUDGETRESULT:oWSBUDGETHEADERVIEW }
	HttpSession->PWSC082INFO := {}

	If ExistBlock( "PEC082" )
		aWebCols := ExecBlock( "PEC082", .F., .F., {} )
	Else
		aWebCols := {}
		aAdd( aWebCols, "BUDGETID" )
		aAdd( aWebCols, "QUOTATIONORORDERID" )
		aAdd( aWebCols, "DESCRIPTIONSTATUS" )
	EndIf

	GridHeader(	HttpSession->PWSC082INFO, ;
					HttpSession->PWSC082HEADER[1][1], ;
					aWebCols )

	GridLinesEx( { HttpSession->PWSC082INFO, ;
					HttpSession->PWSC082HEADER[1][1], ;
					HttpSession->PWSC082RESULT[1], ;
					aWebCols, .F., "A",, 0 } )
Else
	Return PWSHTMLALERT( "", STR0015, "", "W_PWSC080.APW" )//"Erro"
EndIf

cHtml += ExecInPage( "PWSC082" )

WEB EXTENDED END

Return cHtml

/**************************************************************************************************/
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSC083   ºAutor  ³Vendas Clientes      º Data ³  23/03/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Tela para detalhes de orcamentos	  					   º±±
±±º          ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Portal Protheus                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºCleber M. ³07/04/06³95944 ³- Passagem do objeto c/ campos de usuario na º±±
±±º          ³        ³      ³GridHeader para permitir a visualizacao dos  º±±
±±º          ³        ³      ³campos incluidos via Ponto de Entrada.       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSC083()

Local cHtml 	:= ""			//Pagina Web
Local oObj						//Objeto WS - WSMTCUSTOMERBUDGET
Local aWebCols 	:= {}			//Array contendo os campos a serem mostrados na tela

WEB EXTENDED INIT cHtml START "InSite"

HttpSession->PWSC083APH := { STR0008 + HttpGet->cOrcamento, "W_PWSC082.APW" }//"Orçamento Número : "

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTCUSTOMERBUDGET' ), WSMTCUSTOMERBUDGET():New() )
WsChgUrl(@oObj,"MTCUSTOMERBUDGET.apw")

oObj:cUSERCODE		:= GetUsrCode()
oObj:cCUSTOMERID	:= HttpSession->CODCLIERP
oObj:cBUDGETID		:= HttpGet->cOrcamento

If oObj:GETBUDGET()
	HttpSession->PWSC083RESULT := { oObj:oWSGETBUDGETRESULT }
	HttpSession->PWSC083INFO := { {}, {} }
	
	If ExistBlock( "PEC083" )
		aWebCols := ExecBlock( "PEC083", .F., .F., { 1 } )
	Else
		aWebCols := {}
	EndIf

	GridLinesEx( { HttpSession->PWSC083INFO[1], ;
					HttpSession->PWSC082HEADER[1][1], ;
					HttpSession->PWSC083RESULT[1]:oWSHEADER, ;
					aWebCols, .F., "H",, 0 }, "MTCUSTOMERBUDGET", "SCJ" )

	If ExistBlock( "PEC083" )
		aWebCols := ExecBlock( "PEC083", .F., .F., { 2 } )
	Else
		aWebCols := {}
	EndIf

	GridHeader(	HttpSession->PWSC083INFO[2], ;
				HttpSession->PWSC082HEADER[2][1], ;
				aWebCols,;
				HttpSession->PWSC083RESULT[1]:oWSITENS:oWSBUDGETITENSVIEW )

	GridLinesEx( { HttpSession->PWSC083INFO[2], ;
					HttpSession->PWSC082HEADER[2][1], ;
					HttpSession->PWSC083RESULT[1]:oWSITENS:oWSBUDGETITENSVIEW, ;
					aWebCols, .F., "A",, 0 }, "MTCUSTOMERBUDGET", "SCK" )
Else
	Return PWSHTMLALERT( "", STR0015, "", "W_PWSC080.APW" )//"Erro"
EndIf

cHtml += ExecInPage( "PWSC083" )

WEB EXTENDED END

Return cHtml

/**************************************************************************************************/
// Tela para detalhes de pedidos
Web Function PWSC083A()

Local cHtml 	:= ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage( "PWSC083A" )

WEB EXTENDED END

Return cHtml


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSC084   ºAutor  ³ Vendas Clientes     º Data ³  23/03/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela para inclusao e alteracao de orcamentos	  			   º±±
±±º          ³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Portal Protheus                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºCleber M. ³05/06/06³100453³ - Habilitado para edicao na pagina o campo  º±±
±±º          ³        ³      ³ NETUNITPRICE (Preco Unitario).   		   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSC084()

Local cHtml 	:= ""		//Pagina Web
Local aWebCols 	:= {}		//Array contendo os campos a serem mostrados na tela
Local oObj					//Objeto WS - MTCUSTOMERBUDGET
Local nI		:= 0		//Variav. usada em lacos For...Next
Local nPos		:= 0		//Posicao do item no array
Local nTamCodCli:= 6		//Tamanho padrao do campo Cod. de Cliente
Local nTamLoja	:= 2 		//Tamanho padrao do campo Loja Cliente

WEB EXTENDED INIT cHtml START "InSite"

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTCUSTOMERBUDGET' ), WSMTCUSTOMERBUDGET():New() )
WsChgURL( @oObj, "MTCUSTOMERBUDGET.APW" )

HttpSession->PWSC084APH := { STR0017, "" }//"Inclusão Orçamento"
HttpSession->PWSC084INFO := { {}, {} }

If HttpPost->cAcao == "A"
	HttpPost->cAcao := "I"
	HttpSession->nTotalOrc := 0
	
	oObj:cUSERCODE		:= GetUsrCode()
	oObj:cCUSTOMERID	:= HttpSession->CODCLIERP
	oObj:cBUDGETID		:= HttpPost->cOrcamento
	
	If oObj:GETBUDGET()
		HttpSession->PWSC084GRAVA := { ,{} }
		HttpSession->PWSC084GRAVA[1] := oObj:oWSGETBUDGETRESULT:oWSHEADER

		For nI := 1 To Len( oObj:oWSGETBUDGETRESULT:oWSITENS:oWSBUDGETITENSVIEW )
			aAdd( HttpSession->PWSC084GRAVA[2], MTSIMULATIONBUDGET_BUDGETITENSVIEW():New() )
			HttpSession->PWSC084GRAVA[2][nI] := oObj:oWSGETBUDGETRESULT:oWSITENS:oWSBUDGETITENSVIEW[nI]
			HttpSession->nTotalOrc += HttpSession->PWSC084GRAVA[2][nI]:nNETTOTAL
		Next nI
	Else
		Return PWSHTMLALERT( "", STR0015, "", "W_PWSC050.APW" )//"Erro"
	EndIf
Else
	If Empty( HttpSession->PWSC084GRAVA )
		HttpSession->nTotalOrc := 0
		
		oObj := MTCUSTOMERBUDGET_BUDGETHEADERVIEW():New()

		nPos := aScan( HttpSession->PWSC082HEADER[1][1], { |x| Alltrim( x:cHEADERFIELD ) == "CUSTOMERCODE" } )
		If nPos > 0
			nTamCodCli := HttpSession->PWSC082HEADER[1][1][nPos]:nHEADERSIZE
		EndIf
		                                          
		nPos := aScan( HttpSession->PWSC082HEADER[1][1], { |x| Alltrim( x:cHEADERFIELD ) == "CUSTOMERUNIT" } )
		If nPos > 0
			nTamLoja := HttpSession->PWSC082HEADER[1][1][nPos]:nHEADERSIZE
		EndIf
				
		oObj:cCUSTOMERCODE 		:= SubStr( HttpSession->CODCLIERP, 1			, nTamCodCli )
		oObj:cCUSTOMERUNIT 		:= SubStr( HttpSession->CODCLIERP, nTamCodCli+1, nTamLoja )
		oObj:cDELIVERYCUSTOMER 	:= SubStr( HttpSession->CODCLIERP, 1			, nTamCodCli )
		oObj:cDELIVERYUNITCODE 	:= SubStr( HttpSession->CODCLIERP, nTamCodCli+1, nTamLoja )
		oObj:dREGISTERDATE	 	:= Date()
		oObj:dEXPIRATIONDATE	:= Date()
	
		HttpSession->PWSC084GRAVA := { oObj, { MTCUSTOMERBUDGET_BUDGETITENSVIEW():New() } }
	EndIf
EndIf

If HttpPost->cAcao == "I" .AND. Empty( HttpSession->cAcao )
	HttpSession->cAcao := "I"
EndIf

If HttpSession->cAcao == "I"
	If ExistBlock( "PEC084" )
		aWebCols := ExecBlock( "PEC084", .F., .F., { 1 } )
	Else
		aWebCols := {}
		aAdd( aWebCols, { "BUDGETID", "D" } )
		aAdd( aWebCols, { "REGISTERDATE", "D" } )
		aAdd( aWebCols, { "CUSTOMERCODE", "D" } )
		aAdd( aWebCols, { "CUSTOMERUNIT", "D" } )
		aAdd( aWebCols, { "DELIVERYCUSTOMER", "D" } )
		aAdd( aWebCols, { "DELIVERYUNITCODE", "D" } )
		aAdd( aWebCols, { "PAYMENTPLANCODE", "N", { "BRWPAYMENTPLAN", ;
																{ "CPAYMENTPLANCODE", "CPAYMENTPLANCODE" } ;
															}, ;
															{ "CPAYMENTPLANCODE", "CDESCRIPTIONPAYMENTPLAN" } } )
		aAdd( aWebCols, { "PRICELISTCODE", "D" } )
		aAdd( aWebCols, { "DISCOUNT1", "D" } )
		aAdd( aWebCols, { "DISCOUNT2", "D" } )
		aAdd( aWebCols, { "DISCOUNT3", "D" } )
		aAdd( aWebCols, { "DISCOUNT4", "D" } )
		aAdd( aWebCols, "QUOTATIONORORDERID" )
		aAdd( aWebCols, { "FREIGHTVALUE", "D" } )
		aAdd( aWebCols, { "INSURANCEVALUE", "D" } )
		aAdd( aWebCols, { "ADDITIONALEXPENSEVALUE", "D" } )
		aAdd( aWebCols, { "INDEPENDENTFREIGHT", "D" } )
		aAdd( aWebCols, { "EXPIRATIONDATE", "D" } )
		aAdd( aWebCols, { "INDEMNITYVALUE", "D" } )
		aAdd( aWebCols, { "INDEMNITYPERCENTAGE", "D" } )
		aAdd( aWebCols, { "DESCRIPTIONSTATUS", "D" } )
	EndIf
	
	GridLinesEx( { HttpSession->PWSC084INFO[1], ;
					HttpSession->PWSC082HEADER[1][1], ;
					HttpSession->PWSC084GRAVA[1], ;
					aWebCols, .T., "H",, 1 }, "MTCUSTOMERBUDGET", "SCJ" )
	
	If ExistBlock( "PEC084" )
		aWebCols := ExecBlock( "PEC084", .F., .F., { 2 } )
	Else
		aWebCols := {}
		aAdd( aWebCols, { "PRODUCTID", "N", { "GETCATALOG", ;
														{ "CPRODUCTID", "CPRODUCTCODE" } ;
													}, ;
													{ "CPRODUCTCODE", "CDESCRIPTION" }, 13 } )
		aAdd( aWebCols, { "PRODUCTDESCRIPTION", "N", 0, .F. } )
		aAdd( aWebCols, { "QUANTITY", "N", 10 } )  
		aAdd( aWebCols, { "NETUNITPRICE", "N", 15, .T. } )  
		aAdd( aWebCols, { "CUSTOMERBUDGETID", "N", 15 } )  
		aAdd( aWebCols, { "NETTOTAL", "N", 15, .F. } ) 
	EndIf


	For nI := 1 To Len( HttpSession->PWSC084GRAVA[2] )	
		If nI == 1
			GridHeader(	HttpSession->PWSC084INFO[2], ;
					HttpSession->PWSC082HEADER[2][1], ;
					aWebCols, HttpSession->PWSC084GRAVA[2][nI], "MTCUSTOMERBUDGET", "SCK" )
	
        EndIf
        
		GridLinesEx( { HttpSession->PWSC084INFO[2], ;
						HttpSession->PWSC082HEADER[2][1], ;
						HttpSession->PWSC084GRAVA[2][nI], ;
						aWebCols, .T., "H", AllTrim( Str( nI ) ), ;
						IIf( nI == Len( HttpSession->PWSC084GRAVA[2] ), 3, 2 ), .T. }, "MTCUSTOMERBUDGET", "SCK" )
	Next nI
EndIf

cHtml += ExecInPage( "PWSC084" )

WEB EXTENDED END

Return cHtml

/**************************************************************************************************/
// Tela para inclusao e alteracao de pedidos
Web Function PWSC085()

Local cHtml 	:= ""

WEB EXTENDED INIT cHtml START "InSite"

If !Empty( HttpPost->cItem )
	If Len( HttpSession->PWSC084GRAVA[2] ) > 1
		aDel( HttpSession->PWSC084GRAVA[2], Val( HttpPost->cItem ) )
		aSize( HttpSession->PWSC084GRAVA[2], Len( HttpSession->PWSC084GRAVA[2] ) - 1 )
	EndIf
Else
	PWSSetObjToPost( HttpSession->PWSC084GRAVA[1], HttpSession->PWSC082HEADER[1][1], HttpPost->aPost )
	
	nTam := Len( HttpSession->PWSC084GRAVA[2] )
	PWSSetObjToPost( HttpSession->PWSC084GRAVA[2][nTam], HttpSession->PWSC082HEADER[2][1], HttpPost->aPost, AllTrim( Str( nTam ) ) )
	aAdd( HttpSession->PWSC084GRAVA[2], MTCUSTOMERBUDGET_BUDGETITENSVIEW():New() )
EndIf

cHtml += W_PWSC084()

WEB EXTENDED END

Return cHtml

/**************************************************************************************************/
// Tela para inclusao e alteracao de pedidos
Web Function PWSC086()

Local cHtml 	:= ""
Local oObj
Local nI		:= 0
Local nPos
Private aProp 	:={}
WEB EXTENDED INIT cHtml START "InSite"

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTSIMULATIONBUDGET' ), WSMTSIMULATIONBUDGET():New() )
WsChgURL( @oObj, "MTSIMULATIONBUDGET.APW" )

// Forçar a instancia de campo de usuario no HttpSession
PWSPutUsrFld( HttpSession->PWSC084GRAVA[1], "SCJ", "MTSIMULATIONBUDGET" )
nPos 	:= aScan( aProp, { |x| x[1] == "OWSUSERFIELDS" } )
HttpSession->PWSC084GRAVA[1]:oWSuserfields := aProp[nPos][2]
PWSSetObjToPost( HttpSession->PWSC084GRAVA[1], HttpSession->PWSC082HEADER[1][1], HttpPost->aPost )

nTam := Len( HttpSession->PWSC084GRAVA[2] )
For nI := 1 To nTam
	PWSSetObjToPost( HttpSession->PWSC084GRAVA[2][nI], HttpSession->PWSC082HEADER[2][1], HttpPost->aPost, AllTrim( Str( nI ) ) )
	HttpSession->PWSC084GRAVA[2][nI]:cBUDGETITEM := StrZero( nI, 2 )
Next nI

oObj:cUSERCODE			:= "MSALPHA"
oObj:oWSOLDBUDGET := MTSIMULATIONBUDGET_BUDGETVIEW():New()
oObj:oWSOLDBUDGET:oWSHEADER	:= HttpSession->PWSC084GRAVA[1]
oObj:oWSOLDBUDGET:oWSITENS	:= MTSIMULATIONBUDGET_ARRAYOFBUDGETITENSVIEW():New()

For nI := 1 To Len( HttpSession->PWSC084GRAVA[2] )
	aAdd( oObj:oWSOLDBUDGET:oWSITENS:oWSBUDGETITENSVIEW, MTSIMULATIONBUDGET_BUDGETITENSVIEW():New() )
	oObj:oWSOLDBUDGET:oWSITENS:oWSBUDGETITENSVIEW[nI] := HttpSession->PWSC084GRAVA[2][nI]
Next nI

If oObj:PUTBUDGET()
	
	//tratamento para manter valores dos campos customizado
	PWSSetObjToPost( HttpSession->PWSC084GRAVA[1], HttpSession->PWSC082HEADER[1][1], HttpPost->aPost )
	oObj:oWSPUTBUDGETRESULT:oWSHEADER:oWSUSERFIELDS := aProp[nPos][2]
	HttpSession->PWSC084GRAVA[1] := oObj:oWSPUTBUDGETRESULT:oWSHEADER//retorno do valor devera conter aqui
	
	HttpSession->PWSC084GRAVA[2] := {}
	HttpSession->nTotalOrc := 0
	For nI := 1 To Len( oObj:oWSPUTBUDGETRESULT:oWSITENS:oWSBUDGETITENSVIEW )
		aAdd( HttpSession->PWSC084GRAVA[2], MTSIMULATIONBUDGET_BUDGETITENSVIEW():New() )
		HttpSession->PWSC084GRAVA[2][nI] := oObj:oWSPUTBUDGETRESULT:oWSITENS:oWSBUDGETITENSVIEW[nI]
		HttpSession->nTotalOrc += HttpSession->PWSC084GRAVA[2][nI]:nNETTOTAL
	Next nI
Else
	Return PWSHTMLALERT( "", STR0015, "", "W_PWSC084.APW" )//"Erro"
EndIf

cHtml += W_PWSC084()

WEB EXTENDED END

Return cHtml

/**************************************************************************************************/
// Tela para inclusao e alteracao de pedidos
Web Function PWSC087()

Local cHtml 	:= ""
Local oObj
Local nI		:= 0

WEB EXTENDED INIT cHtml START "InSite"

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTCUSTOMERBUDGET' ), WSMTCUSTOMERBUDGET():New() )
WsChgURL( @oObj, "MTCUSTOMERBUDGET.APW" )

PWSSetObjToPost( HttpSession->PWSC084GRAVA[1], HttpSession->PWSC082HEADER[1][1], HttpPost->aPost )

nTam := Len( HttpSession->PWSC084GRAVA[2] )
For nI := 1 To nTam
	PWSSetObjToPost( HttpSession->PWSC084GRAVA[2][nI], HttpSession->PWSC082HEADER[2][1], HttpPost->aPost, AllTrim( Str( nI ) ) )
	HttpSession->PWSC084GRAVA[2][nI]:cBUDGETITEM := StrZero( nI, 2 )
Next nI

oObj:cUSERCODE			:= "MSALPHA"
oObj:cCUSTOMERID		:= HttpSession->CODCLIERP
oObj:oWSBUDGET := MTCUSTOMERBUDGET_BUDGETVIEW():New()
oObj:oWSBUDGET:oWSHEADER	:= HttpSession->PWSC084GRAVA[1]
oObj:oWSBUDGET:oWSITENS		:= MTCUSTOMERBUDGET_ARRAYOFBUDGETITENSVIEW():New()

SetObj( oObj:oWSBUDGET:oWSHEADER, HttpSession->PWSC082HEADER[1][1], HttpSession->PWSC084GRAVA[1] )

For nI := 1 To Len( HttpSession->PWSC084GRAVA[2] )
	aAdd( oObj:oWSBUDGET:oWSITENS:oWSBUDGETITENSVIEW, MTCUSTOMERBUDGET_BUDGETITENSVIEW():New() )
	oObj:oWSBUDGET:oWSITENS:oWSBUDGETITENSVIEW[nI] := HttpSession->PWSC084GRAVA[2][nI]
	SetObj( oObj:oWSBUDGET:oWSITENS:oWSBUDGETITENSVIEW[nI], HttpSession->PWSC082HEADER[2][1], ;
		HttpSession->PWSC084GRAVA[2][nI] )
Next nI

//cUSERCODE,cCUSTOMERID,oWSBUDGET
If oObj:PUTBUDGET()
	Return PWSHTMLALERT( "", STR0018, STR0008 + oObj:cPUTBUDGETRESULT + STR0019, "W_PWSC080.APW" )//"Atenção","Orçamento Número "," cadastrado com SUCESSO!"
Else
	Return PWSHTMLALERT( "", STR0015, "", "W_PWSC084.APW" )//"Erro"
EndIf

cHtml += W_PWSC084()

WEB EXTENDED END

Return cHtml

/**************************************************************************************************/
Function SetObj( oObj, oObjHeader, oObjResult )

Local nI := 0

Private __oObjResult := oObjResult
Private __oObj := oObj

For nI := 1 To Len( oObjHeader )
	
	If substr(oObjHeader[nI]:cHEADERFIELD,1,1) != "U"
		//Campos Padrao do Sistema
		cResultTemp := &( "__oObjResult:" + oObjHeader[nI]:cHEADERTYPE + oObjHeader[nI]:cHEADERFIELD )
	
		If !Empty( cResultTemp )
			&( "__oObj:" + oObjHeader[nI]:cHEADERTYPE + oObjHeader[nI]:cHEADERFIELD ) := cResultTemp
		Else
			&( "__oObj:" + oObjHeader[nI]:cHEADERTYPE + oObjHeader[nI]:cHEADERFIELD ) := NIL
		EndIf
	Endif
Next nI

oObj := __oObj

Return
