#INCLUDE "PWSC070.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"

/**************************************************************************************************/
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSC070   ºAutor  ³Microsiga           º Data ³  14/03/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina de Acompanhamento de Pedidos (Portal do Cliente)     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PORTAIS                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºCleber M. ³08/11/06³112664³Passagem de parametro com o nome do WS em   º±±
±±º          ³        ³      ³todas as funcoes GridLinesEx() para ser pos-º±±
±±º          ³        ³      ³sivel incluir campos de usuario no aHeader. º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
//Tela de selecao de Clientes
Web Function PWSC070()

Local cHtml := ""		//Pagina HTML

WEB EXTENDED INIT cHtml START "InSite"

HttpPost->PWSC020CLI := GetUserCli()

HttpSession->PWSC020APH := { STR0003 , ;				//"Acompanhamento de Pedidos"
								"W_PWSC071.APW", ;		// Proxima Tela
								""	} 					// Msg de Erro

If Len( HttpPost->PWSC020CLI ) <= 1
	HttpSession->PWSC020APH[3] := STR0002 //"Não há clientes a consultar."

	cHtml += ExecInPage( "PWSC020" )
ElseIf Len(HttpPost->PWSC020CLI) = 2
	//Apenas 1 cliente. Define a navegação para pular a tela de seleção de cliente
	HttpPost->CODCLIERP	:= HttpPost->PWSC020CLI[2][2]

	cHtml += W_PWSC071()
Else
	//Mais de 1 cliente? Chama tela de seleção de CLientes
	cHtml += ExecInPage( "PWSC020" )
EndIf

WEB EXTENDED END

Return cHtml

/**************************************************************************************************/
// Tela para escolha de pedidos
Web Function PWSC071()

Local cHtml := ""	//Pagina HTML
Local oObj			//Objeto WS MTCUSTOMERSALESORDER

WEB EXTENDED INIT cHtml START "InSite"

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTCUSTOMERSALESORDER' ), WSMTCUSTOMERSALESORDER():NEW() )
WsChgURL( @oObj, "MTCUSTOMERSALESORDER.APW" )

If !Empty( HttpPost->CODCLIERP )
	HttpSession->CODCLIERP := HttpPost->CODCLIERP
EndIf

If Empty( HttpSession->PWSC072HEADER )
	HttpSession->PWSC072HEADER := { {}, {}, {}, {}, {} }
	
	If oObj:GETHEADER( "SALESORDERHEADERVIEW" )
		HttpSession->PWSC072HEADER[1] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
	Else
		Return PWSHTMLALERT( "", STR0004 , "", "W_PWSC070.APW" ) //"Erro"
	EndIf

	If oObj:GETHEADER( "SALESORDERITEMVIEW" )
		HttpSession->PWSC072HEADER[2] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
	Else
		Return PWSHTMLALERT( "", STR0004 , "", "W_PWSC070.APW" )//"Erro"
	EndIf
	
	If oObj:GETHEADER( "SALESORDERRELEASE" )
		HttpSession->PWSC072HEADER[3] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
	Else
		Return PWSHTMLALERT( "", STR0004, "", "W_PWSC070.APW" )//"Erro"
	EndIf

	If oObj:GETHEADER( "INVOICEHEADERVIEW" )
		HttpSession->PWSC072HEADER[4] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
	Else
		Return PWSHTMLALERT( "", STR0004, "", "W_PWSC070.APW" )//"Erro"
	EndIf

	If oObj:GETHEADER( "INVOICEITEMVIEW" )
		HttpSession->PWSC072HEADER[5] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
	Else
		Return PWSHTMLALERT( "", STR0004, "", "W_PWSC070.APW" )//"Erro"
	EndIf
EndIf

HttpSession->PWSC071APH := { STR0003, "W_PWSC072.APW", "W_PWSC074.APW" }//"Acompanhamento de Pedidos"

cHtml += ExecInPage( "PWSC071" )

WEB EXTENDED END

Return cHtml

/**************************************************************************************************/
// Tela para escolha de pedidos
Web Function PWSC072()

Local cHtml 	:= ""		//Pagina HTML
Local oObj					//Objeto WS MTCUSTOMERSALESORDER
Local oObjTotalSO			//Objeto WS MTCUSTOMERSALESORDER
Local oObjStat				//Objeto WS MTCUSTOMERSALESORDER
Local aWebCols 	:= {}		//Array com os campos a serem apresentados
Local nI		:= 0		//Usada em lacos For...Next

WEB EXTENDED INIT cHtml START "InSite"

oObj 			:= IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTCUSTOMERSALESORDER' ), WSMTCUSTOMERSALESORDER():New() )
oObjTotalSO 	:= IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTCUSTOMERSALESORDER' ), WSMTCUSTOMERSALESORDER():New() )
oObjStat 		:= IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTCUSTOMERSALESORDER' ), WSMTCUSTOMERSALESORDER():New() )
WsChgURL( @oObj, "MTCUSTOMERSALESORDER.APW" )
WsChgURL( @oObjTotalSO, "MTCUSTOMERSALESORDER.APW" )
WsChgURL( @oObjStat, "MTCUSTOMERSALESORDER.APW" )

HttpSession->PWSC072APH := { STR0006 , "W_PWSC073.APW" }//"Resultado Busca"

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
oObj:cBIDNUMBERFROM		:= HttpPost->cBIDNUMBERFROM
oObj:cBIDNUMBERTO		:= HttpPost->cBIDNUMBERTO
oObj:nPAGELEN			:= 10
oObj:nPAGEFIRST			:= ( Val( HttpGet->cPagina ) * 10 ) + 1

oObjTotalSO:cUSERCODE			:= GetUsrCode()
oObjTotalSO:cCUSTOMERID			:= HttpSession->CODCLIERP
oObjTotalSO:dREGISTERDATEFROM	:= CToD( HttpPost->dREGISTERDATEFROM )
oObjTotalSO:dREGISTERDATETO		:= CToD( HttpPost->dREGISTERDATETO )
oObjTotalSO:cBIDNUMBERFROM		:= HttpPost->cBIDNUMBERFROM
oObjTotalSO:cBIDNUMBERTO		:= HttpPost->cBIDNUMBERTO

If !Empty( HttpPost->cBuscaAv )
	Do Case
		Case HttpPost->cComboAv == "1"
			oObj:cQUERYADDWHERE			:= "SC5.C5_NUM='" + HttpPost->cBuscaAv + "'"
			oObjTotalSO:cQUERYADDWHERE	:= "SC5.C5_NUM='" + HttpPost->cBuscaAv + "'"
		Case HttpPost->cComboAv == "2"
			oObj:cQUERYADDWHERE			:= "SC5.C5_OS='" + HttpPost->cBuscaAv + "'"
			oObjTotalSO:cQUERYADDWHERE	:= "SC5.C5_OS='" + HttpPost->cBuscaAv + "'"
	EndCase
Else
	oObj:cQUERYADDWHERE			:= ""
	oObjTotalSO:cQUERYADDWHERE	:= ""
EndIf

//cUSERCODE,cCUSTOMERID,dREGISTERDATEFROM,dREGISTERDATETO,cBIDNUMBERFROM,cBIDNUMBERTO,cQUERYADDWHERE,cINDEXKEY,nPAGELEN,nPAGEFIRST
If oObj:BRWSALESORDER()
	HttpSession->PWSC072RESULT := { oObj:oWSBRWSALESORDERRESULT:oWSSALESORDERHEADERVIEW }
	HttpSession->PWSC072INFO := {}
	HttpSession->PWSC072STATUS := {}

	If HttpPost->cBusca == "1" .OR. HttpPost->cBusca == "2"
		//cUSERCODE,cCUSTOMERID,dREGISTERDATEFROM,dREGISTERDATETO,cBIDNUMBERFROM,cBIDNUMBERTO,cQUERYADDWHERE
		If oObjTotalSO:BRWTOTALSALESORDER()
			HttpSession->nTotalSO := oObjTotalSO:nBRWTOTALSALESORDERRESULT
		Else
			Return PWSHTMLALERT( "", STR0004 , "", "W_PWSC070.APW" )//"Erro"
		EndIf
	EndIf

	aAdd( HttpSession->PWSC072STATUS, "Status" )
	
	For nI := 1 To Len( HttpSession->PWSC072RESULT[1] )
		oObjStat:cUSERCODE			:= GetUsrCode()
		oObjStat:cCUSTOMERID		:= HttpSession->CODCLIERP
		oObjStat:cORDERID			:= HttpSession->PWSC072RESULT[1][nI]:cORDERID
		oObjStat:cQUERYADDWHERE		:= ""
		
		//cUSERCODE,cCUSTOMERID,cORDERID,cQUERYADDWHERE
		If oObjStat:GETSTATUSRELEASE()
			aAdd( HttpSession->PWSC072STATUS, oObjStat:cGETSTATUSRELEASERESULT )
		Else
			Return PWSHTMLALERT( "", STR0004, "", "W_PWS070.APW" )//"Erro"
		EndIf
	Next nI

	If ExistBlock( "PEC072" )
		aWebCols := ExecBlock( "PEC072", .F., .F., {} )
	Else
		aWebCols := {}
		aAdd( aWebCols, "ORDERID" )
		aAdd( aWebCols, "ORDERTYPECODE" )
		aAdd( aWebCols, "CARRIERCODE" )
		aAdd( aWebCols, "FINANCIALDISCOUNT" )
		aAdd( aWebCols, "REGISTERDATE" )
		aAdd( aWebCols, "BIDNUMBER" )
		aAdd( aWebCols, "FREIGHTVALUE" )
		aAdd( aWebCols, "INSURANCEVALUE" )
		aAdd( aWebCols, "ADDITIONALEXPENSEVALUE" )
	EndIf

	GridHeader(	HttpSession->PWSC072INFO, ;
				HttpSession->PWSC072HEADER[1][1], ;
				aWebCols,;
				HttpSession->PWSC072RESULT[1]  )

	GridLinesEx( { HttpSession->PWSC072INFO, ;
					HttpSession->PWSC072HEADER[1][1], ;
					HttpSession->PWSC072RESULT[1], ;
					aWebCols, .F., "A",, 0 }, "MTCUSTOMERSALESORDER", "SC5" )
Else
	Return PWSHTMLALERT( "", STR0004, "", "W_PWSC070.APW" )//"Erro"
EndIf

cHtml += ExecInPage( "PWSC072" )

WEB EXTENDED END

Return cHtml

/**************************************************************************************************/
// Tela para detalhes de pedidos
Web Function PWSC073()

Local cHtml 	:= ""		//Pagina HTML
Local oObj					//Objeto WS MTCUSTOMERSALESORDER
Local aWebCols 	:= {}		//Array com os campos a serem apresentados
Local nI 		:= 0		//Usada em lacos For...Next

WEB EXTENDED INIT cHtml START "InSite"

HttpSession->PWSC073APH := { STR0005 + HttpGet->cPedido, "W_PWSC072.APW" }//"Pedido Número : "

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTCUSTOMERSALESORDER' ), WSMTCUSTOMERSALESORDER():New() )
WsChgUrl(@oObj,"MTCUSTOMERSALESORDER.apw")

oObj:cUSERCODE		:= GetUsrCode()
oObj:cCUSTOMERID	:= HttpSession->CODCLIERP
oObj:cORDERID		:= HttpGet->cPedido
oObj:cQUERYADDWHERE	:= ""

If oObj:GETSALESORDER()
	HttpSession->PWSC073RESULT := { oObj:oWSGETSALESORDERRESULT }
	HttpSession->PWSC073INFO := { {}, {}, {} }
	HttpSession->PWSC073OP := {}
	
	If ExistBlock( "PEC073" )
		aWebCols := ExecBlock( "PEC073", .F., .F., { 1 } )
	Else         
		aWebCols := {}
		aAdd( aWebCols, "ORDERID" )
		aAdd( aWebCols, "ORDERTYPECODE" )
		aAdd( aWebCols, "CUSTOMERCODE" )
		aAdd( aWebCols, "CUSTOMERUNIT" )
		aAdd( aWebCols, "DELIVERYCUSTOMER" )
		aAdd( aWebCols, "DELIVERYUNITCODE" )
		aAdd( aWebCols, "CARRIERCODE" )
		aAdd( aWebCols, "CUSTOMERTYPE" )
		aAdd( aWebCols, "PAYMENTPLANCODE" )
		aAdd( aWebCols, "PRICELISTCODE" )
		aAdd( aWebCols, "SELLERS" )
		aAdd( aWebCols, "DISCOUNT1" )
		aAdd( aWebCols, "DISCOUNT2" )
		aAdd( aWebCols, "DISCOUNT3" )
		aAdd( aWebCols, "DISCOUNT4" )
		aAdd( aWebCols, "BANKCODE" )
		aAdd( aWebCols, "FINANCIALDISCOUNT" )
		aAdd( aWebCols, "REGISTERDATE" )
		aAdd( aWebCols, "BIDNUMBER" )
		aAdd( aWebCols, "FREIGHTTYPE" )
		aAdd( aWebCols, "FREIGHTVALUE" )
		aAdd( aWebCols, "INSURANCEVALUE" )
		aAdd( aWebCols, "ADDITIONALEXPENSEVALUE" )
		aAdd( aWebCols, "INDEPENDENTFREIGHT" )
		aAdd( aWebCols, "ADJUSTMENTTYPE" )
		aAdd( aWebCols, "SALESORDERCURRENCY" )
		aAdd( aWebCols, "NETWEIGHT" )
		aAdd( aWebCols, "GROSSWEIGHT" )
		aAdd( aWebCols, "REDELIVERYCARRIERCODE" )
		aAdd( aWebCols, "PACKAGESVOLUMES" )
		aAdd( aWebCols, "FINANCIALINCREASE" )
		aAdd( aWebCols, "INVOICEMESSAGE" )
		aAdd( aWebCols, "STANDARDMESSAGE1" )
		aAdd( aWebCols, "PRICEWITHSERVICETAX" )
		aAdd( aWebCols, "APROBATIONTYPE" )
		aAdd( aWebCols, "INDEMNITYVALUE" )
		aAdd( aWebCols, "INDEMNITYPERCENTAGE" )
	EndIf

	GridLinesEx( { HttpSession->PWSC073INFO[1], ;
					HttpSession->PWSC072HEADER[1][1], ;
					HttpSession->PWSC073RESULT[1]:oWSSOHEADER, ;
					aWebCols, .F., "H",, 0 }, "MTCUSTOMERSALESORDER", "SC5" )
	
	aAdd( HttpSession->PWSC073OP, {} )
	
	For nI := 1 To Len( HttpSession->PWSC073RESULT[1]:oWSSOITEM:oWSSALESORDERITEMVIEW )
		aAdd( HttpSession->PWSC073OP, { HttpSession->PWSC073RESULT[1]:oWSSOITEM:oWSSALESORDERITEMVIEW[nI]:cPOID, ;
			HttpSession->PWSC073RESULT[1]:oWSSOITEM:oWSSALESORDERITEMVIEW[nI]:cPOITEM, ;
			HttpSession->PWSC073RESULT[1]:oWSSOITEM:oWSSALESORDERITEMVIEW[nI]:cPOSEQUENCE, ;
			HttpSession->PWSC073RESULT[1]:oWSSOITEM:oWSSALESORDERITEMVIEW[nI]:cPOGRADEITEM } )
	Next nI

	If ExistBlock( "PEC073" )
		aWebCols := ExecBlock( "PEC073", .F., .F., { 2 } )
	Else
		aWebCols := {}
		aAdd( aWebCols, "ORDERID" )
		aAdd( aWebCols, "ORDERITEM" )
		aAdd( aWebCols, "PRODUCTID" )
		aAdd( aWebCols, "UNITOFMEASURE" )
		aAdd( aWebCols, "QUANTITY" )
		aAdd( aWebCols, "NETUNITPRICE" )
		aAdd( aWebCols, "NETTOTAL" )
		aAdd( aWebCols, "QUANTITYAPPROVED" )
		aAdd( aWebCols, "QUANTITYDELIVERED" )
		aAdd( aWebCols, "QUANTITYRELEASEDSECONDUNIT" )
		aAdd( aWebCols, "SECONDUNITOFMEASURE" )
		aAdd( aWebCols, "ITEMOUTFLOWTYPE" )
		aAdd( aWebCols, "SECONDMEASUREUNITQUANTITY" )
		aAdd( aWebCols, "WAREHOUSE" )
		aAdd( aWebCols, "FISCALOPERATION" )
		aAdd( aWebCols, "DISCOUNTPERCENTAGE" )
		aAdd( aWebCols, "ITEMDISCOUNTVALUE" )
		aAdd( aWebCols, "DELIVERYDATE" )
		aAdd( aWebCols, "COMMISSIONSPERCENTAGE" )
		aAdd( aWebCols, "CUSTOMERORDERNUMBER" )
		aAdd( aWebCols, "PRODUCTDESCRIPTION" )
		aAdd( aWebCols, "UNITLISTPRICE" )
		aAdd( aWebCols, "ORIGINALINVOICE" )
		aAdd( aWebCols, "ORIGINALINVOICESERIALID" )
		aAdd( aWebCols, "ORIGINALINVOICEITEM" )
		aAdd( aWebCols, "LOTNUMBER" )
		aAdd( aWebCols, "SUBLOT" )
		aAdd( aWebCols, "LOCATION" )
		aAdd( aWebCols, "PRODUCTSERIALNUMBER" )
		aAdd( aWebCols, "MANUFACTURERCODE" )
		aAdd( aWebCols, "MANUFACTURERUNIT" )
		aAdd( aWebCols, "OPERATIONTYPE" )
	EndIf

	GridHeader(	HttpSession->PWSC073INFO[2], ;
					HttpSession->PWSC072HEADER[2][1], ;
					aWebCols )

	GridLinesEx( { HttpSession->PWSC073INFO[2], ;
					HttpSession->PWSC072HEADER[2][1], ;
					HttpSession->PWSC073RESULT[1]:oWSSOITEM:oWSSALESORDERITEMVIEW, ;
					aWebCols, .F., "A",, 0 }, "MTCUSTOMERSALESORDER", "SC6" )
Else
	Return PWSHTMLALERT( "", STR0004 , "", "W_PWSC070.APW" )//"Erro"
EndIf

oObj:cUSERCODE			:= GetUsrCode()
oObj:cCUSTOMERID		:= HttpSession->CODCLIERP
oObj:cORDERID			:= HttpGet->cPedido
oObj:cQUERYADDWHERE		:= ""

//cUSERCODE,cCUSTOMERID,cORDERID,cQUERYADDWHERE
If oObj:GETRELEASE()
	HttpSession->PWSC073STATUSRESULT := { oObj:oWSGETRELEASERESULT:oWSSALESORDERRELEASE }
	
	If ExistBlock( "PEC073" )
		aWebCols := ExecBlock( "PEC073", .F., .F., { 3 } )
	Else
		aWebCols := {}
	EndIf

	GridHeader(	HttpSession->PWSC073INFO[3], ;
					HttpSession->PWSC072HEADER[3][1], ;
					aWebCols )

	GridLinesEx( { HttpSession->PWSC073INFO[3], ;
					HttpSession->PWSC072HEADER[3][1], ;
					HttpSession->PWSC073STATUSRESULT[1], ;
					aWebCols, .F., "A",, 0 }, "MTCUSTOMERSALESORDER" )
	
Else
	Return PWSHTMLALERT( "", STR0004 , "", "W_PWSC070.APW" )//"Erro"
EndIf

cHtml += ExecInPage( "PWSC073" )

WEB EXTENDED END

Return cHtml

/**************************************************************************************************/
// Tela para detalhes de pedidos
Web Function PWSC073A()

Local cHtml 	:= ""		//Pagina HTML

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage( "PWSC073A" )

WEB EXTENDED END

Return cHtml

/**************************************************************************************************/
// Tela para detalhes de pedidos
Web Function PWSC073B()

Local cHtml 	:= ""		//Pagina HTML

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage( "PWSC073B" )

WEB EXTENDED END

Return cHtml

/**************************************************************************************************/
// Tela para documentos de saida
Web Function PWSC074()

Local cHtml 	:= ""		//Pagina HTML
Local oObj					//Objeto WS 
Local aWebCols 	:= {}		//Array com os campos a serem apresentados

WEB EXTENDED INIT cHtml START "InSite"

If !Empty( HttpGet->cPedido )
	HttpPost->cPedido := HttpGet->cPedido
EndIf

HttpSession->PWSC074APH := { STR0005 + HttpPost->cPedido, "W_PWSC072.APW" }//"Pedido Número : "

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTCUSTOMERINVOICE' ), WSMTCUSTOMERINVOICE():NEW() )
WsChgUrl(@oObj,"MTCUSTOMERINVOICE.apw")

oObj:cUSERCODE				:= GetUsrCode()
oObj:nCUSTOMERORSUPPLIER	:= 1
oObj:cCUSTOMERORSUPPLIERID	:= HttpSession->CODCLIERP
oObj:cPURCHASENUMBER		:= HttpPost->cPedido

//cUSERCODE,nCUSTOMERORSUPPLIER,cCUSTOMERORSUPPLIERID,dREGISTERDATEFROM,dREGISTERDATETO,dDELIVERYDATEFROM,dDELIVERYDATETO,cQUERYADDWHERENFE,cQUERYADDWHERENFS,cINDEXKEYNFE,cINDEXKEYNFS,cPURCHASENUMBER
If oObj:BRWINVOICE()
	HttpSession->PWSC074RESULT := { oObj:oWSBRWINVOICERESULT:oWSINVOICEHEADERVIEW }
	HttpSession->PWSC074INFO := {}
	
	If ExistBlock( "PEC074" )
		aWebCols := ExecBlock( "PEC074", .F., .F., {} )
	Else
		aWebCols := {}
		aAdd( aWebCols, "INVOICETYPE" )
		aAdd( aWebCols, "SERIALNUMBER" )
		aAdd( aWebCols, "INVOICENUMBER" )
		aAdd( aWebCols, "DOCUMENTTYPE" )
		aAdd( aWebCols, "REGISTERDATE" )
		aAdd( aWebCols, "INVOICEDATE" )
		aAdd( aWebCols, "DELIVERYDATE" )
		aAdd( aWebCols, "EXPENSESVALUE" )
		aAdd( aWebCols, "INSURANCEVALUE" )
		aAdd( aWebCols, "FREIGHTVALUE" )
		aAdd( aWebCols, "TOTALVALUE" )
	EndIf

	GridHeader(	HttpSession->PWSC074INFO, ;
				HttpSession->PWSC072HEADER[4][1], ;
				aWebCols )

	GridLinesEx( { HttpSession->PWSC074INFO, ;
					HttpSession->PWSC072HEADER[4][1], ;
					HttpSession->PWSC074RESULT[1], ;
					aWebCols, .F., "A",, 0 },"MTCUSTOMERINVOICE" )
Else
	Return PWSHTMLALERT( "", STR0004 , "", "W_PWSC070.APW" )//"Erro"
EndIf

cHtml += ExecInPage( "PWSC074" )

WEB EXTENDED END

Return cHtml

/**************************************************************************************************/
// Tela para visualizacao documento de saida
Web Function PWSC075()

Local cHtml 	:= ""			//Pagina HTML
Local oObj						//Objeto WS MTCUSTOMERINVOICE
Local aWebCols 	:= {}			//Array com os campos a serem apresentados
Local aNota		:= {}			//Array das Notas Fiscais

WEB EXTENDED INIT cHtml START "InSite"

aNota := Separa( HttpGet->cNota, "|" )

HttpSession->PWSC075APH := { STR0007 + aNota[1] + "/" + aNota[2] + "/" + aNota[3] + "/" +;
								aNota[4], "W_PWSC072.APW" }  //"Documento de Saída Número : "

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTCUSTOMERINVOICE' ), WSMTCUSTOMERINVOICE():NEW() )
WsChgUrl(@oObj,"MTCUSTOMERINVOICE.apw")

oObj:cUSERCODE				:= GetUsrCode()
oObj:cINVOICETYPE			:= aNota[1]
oObj:cSERIALNUMBER			:= aNota[2]
oObj:cINVOICENUMBER			:= aNota[3]
oObj:cDOCUMENTTYPE			:= aNota[4]
oObj:nCUSTOMERORSUPPLIER	:= 1
oObj:cCUSTOMERORSUPPLIERID	:= HttpSession->CODCLIERP

//cUSERCODE,cINVOICETYPE,cSERIALNUMBER,cINVOICENUMBER,cDOCUMENTTYPE,nCUSTOMERORSUPPLIER,cCUSTOMERORSUPPLIERID,cQUERYADDWHERENFE,cQUERYADDWHERENFS
If oObj:GETINVOICE()
	HttpSession->PWSC075RESULT := { oObj:oWSGETINVOICERESULT }
	HttpSession->PWSC075INFO := { {}, {} }
	
	If ExistBlock( "PEC075" )
		aWebCols := ExecBlock( "PEC075", .F., .F., { 1 } )
	Else
		aWebCols := {}
	EndIf
	
	GridLinesEx( { HttpSession->PWSC075INFO[1], ;
					HttpSession->PWSC072HEADER[4][1], ;
					HttpSession->PWSC075RESULT[1]:oWSINVOICEHEADER, ;
					aWebCols, .F., "H",, 0 }, "MTCUSTOMERINVOICE" )
	
	If ExistBlock( "PEC075" )
		aWebCols := ExecBlock( "PEC075", .F., .F., { 2 } )
	Else
		aWebCols := {}
	EndIf

	GridHeader(	HttpSession->PWSC075INFO[2], ;
				HttpSession->PWSC072HEADER[5][1], ;
				aWebCols )

	GridLinesEx( { HttpSession->PWSC075INFO[2], ;
					HttpSession->PWSC072HEADER[5][1], ;
					HttpSession->PWSC075RESULT[1]:oWSINVOICEITEM:oWSINVOICEITEMVIEW, ;
					aWebCols, .F., "A",, 0 }, "MTCUSTOMERINVOICE" )
Else
	Return PWSHTMLALERT( "", STR0004 , "", "W_PWSC070.APW" )//"Erro"
EndIf

cHtml += ExecInPage( "PWSC075" )

WEB EXTENDED END

Return cHtml

/**************************************************************************************************/
// Tela para detalhes de documentos de saida
Web Function PWSC075A()

Local cHtml 	:= ""			//Pagina HTML

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage( "PWSC075A" )

WEB EXTENDED END

Return cHtml

/**************************************************************************************************/
// Tela para detalhes da ordem de producao
Web Function PWSC076()

Local cHtml 	:= ""			//Pagina HTML
Local oObj						//Objeto WS MTPRODUCTIONORDER
Local aWebCols 	:= {}			//Array com os campos a serem apresentados
Local aOP		:= {}			//Array das Ordens de Prod.

WEB EXTENDED INIT cHtml START "InSite"

aOP := Separa( HttpGet->cOP, "|" )

HttpSession->PWSC076APH := { STR0008 + aOP[1] + "/" + aOP[2] + "/" + aOP[3], "W_PWSC074.APW" }//"Ordem de Produção Número : "

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTPRODUCTIONORDER' ), WSMTPRODUCTIONORDER():NEW() )
WsChgUrl( @oObj, "MTPRODUCTIONORDER.apw" )

If Empty( HttpSession->PWSC076HEADER )
	If oObj:GETHEADER( "PRODUCTIONORDERVIEW" )
		HttpSession->PWSC076HEADER := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
	Else
		Return PWSHTMLALERT( "", STR0004 , "", "W_PWSC070.APW" )//"Erro"
	EndIf
EndIf

oObj:cUSERCODE		:= GetUsrCode()
oObj:cPOID			:= aOP[1]
oObj:cPOITEM		:= aOP[2]
oObj:cPOSEQUENCE	:= aOP[3]

//cUSERCODE,cPOID,cPOITEM,cPOSEQUENCE
If oObj:GETPRODUCTIONORDER()
	HttpSession->PWSC076RESULT := { oObj:oWSGETPRODUCTIONORDERRESULT }
	HttpSession->PWSC076INFO := {}
	
	If ExistBlock( "PEC076" )
		aWebCols := ExecBlock( "PEC076", .F., .F., {} )
	Else
		aWebCols := {}
		aAdd( aWebCols, "BILLNUMBER" )
		aAdd( aWebCols, "BILLTYPE" )
		aAdd( aWebCols, "ISSUEDATE" )
		aAdd( aWebCols, "ORIGINALVALUE" )
	EndIf

	GridLinesEx( { HttpSession->PWSC076INFO, ;
					HttpSession->PWSC076HEADER[1], ;
					HttpSession->PWSC076RESULT[1], ;
					aWebCols, .F., "H",, 0 }, "MTPRODUCTIONORDER" )
Else
	Return PWSHTMLALERT( "", STR0004 , "", "W_PWSC070.APW" )//"Erro"
EndIf

cHtml += ExecInPage( "PWSC076" )

WEB EXTENDED END

Return cHtml

/**************************************************************************************************/
// Tela para visualizaco grafico de gantt
Web Function PWSC077()

Local cHtml 		:= ""		//Pagina HTML
Local oObj						//Objeto WS MTPRODUCTIONORDER
Local aOP			:= {}		//Array das Ordens de Prod.
Local nI 			:= 0		//Usada em lacos For..Next
Local nJ 			:= 0		//Usada em lacos For..Next
Local cPOID	 		:= ""		//Id da Ordem de Prod.
Local cPOITEM		:= ""		//Item da Ordem de Prod.
Local cPOSEQUENCE	:= ""		//Sequencia da Ordem de Prod.
Local lRetorno 		:= .F.		//Retorno da funcao

WEB EXTENDED INIT cHtml START "InSite"

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTPRODUCTIONORDER' ), WSMTPRODUCTIONORDER():NEW() )
WsChgUrl( @oObj, "MTPRODUCTIONORDER.apw" )

HttpSession->aSemanas := {}
HttpSession->aDatas := {}

aOP := Separa( HttpPost->cOP, "|" )

HttpSession->PWSC077APH := { STR0009 + aOP[1] + "/" + aOP[2] + "/" + aOP[3] }//"Gráfico de Gantt - OP: "

cPOID := HttpSession->PWSC076RESULT[1]:cPOID + HttpSession->PWSC076RESULT[1]:cPOITEM +;
			HttpSession->PWSC076RESULT[1]:cPOSEQUENCE

oObj:cUSERCODE		:= GetUsrCode()
oObj:cPOID			:= aOP[1]
oObj:cPOITEM		:= aOP[2]
oObj:cPOSEQUENCE	:= aOP[3]

//cUSERCODE,cPOID,cPOITEM,cPOSEQUENCE
If oObj:BRWPOREQUIREMENTS()
	HttpSession->PWSC077RESULT := { oObj:oWSBRWPOREQUIREMENTSRESULT:oWSPOREQUIREMENTSVIEW }
	
	HttpSession->aSemanas := {}
	HttpSession->aDatas := {}
	
	SetDatas( cPOID, .F., @lRetorno )
	
	For nI := 1 To Len( HttpSession->PWSC077RESULT[1] )
		If !Empty( HttpSession->PWSC077RESULT[1][nI]:cPOORIGIN )
			SetDatas( HttpSession->PWSC077RESULT[1][nI]:cPOORIGIN, .F., @lRetorno )

			If !lRetorno
				Exit
			EndIf
		EndIf
	Next nI
Else
	SetDatas( cPOID, .F., @lRetorno )
EndIf

aSort( HttpSession->aSemanas,,, { |x, y| x < y } )
InsSemana( HttpSession->aSemanas )
	
If lRetorno
	cHtml += ExecInPage( "PWSC077" )
EndIf

WEB EXTENDED END

Return cHtml

/**************************************************************************************************/
// Tela para visualizaco apontamentos
Web Function PWSC078()

Local cHtml 		:= ""			//Pagina HTML
Local oObj							//Objeto WS 
Local aWebCols		:= {}			//Array com os campos a serem apresentados

WEB EXTENDED INIT cHtml START "InSite"

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTPRODUCTIONORDER' ), WSMTPRODUCTIONORDER():NEW() )
WsChgUrl( @oObj, "MTPRODUCTIONORDER.apw" )

If Empty( HttpSession->PWSC078HEADER )
	If oObj:GETHEADER( "GOODSMOVEMENTSVIEW" )
		HttpSession->PWSC078HEADER := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
	Else
		Return PWSHTMLALERT( "", STR0004 , "", "W_PWSC070.APW" )//"Erro"
	EndIf
EndIf

HttpSession->PWSC078APH := { STR0010 }//"Apontamentos"
HttpSession->PWSC078INFO := {}

aOP := Separa( HttpPost->cOP, "|" )

oObj:cUSERCODE		:= GetUsrCode()
oObj:cPOID			:= aOP[1]
oObj:cPOITEM		:= aOP[2]
oObj:cPOSEQUENCE	:= aOP[3]

//cUSERCODE,cPOID,cPOITEM,cPOSEQUENCE
If oObj:BRWPOAPPOINTMENT()
	HttpSession->PWSC078RESULT := { oObj:oWSBRWPOAPPOINTMENTRESULT:oWSGOODSMOVEMENTSVIEW }
	
	If ExistBlock( "PEC078" )
		aWebCols := ExecBlock( "PEC078", .F., .F., {} )
	Else
		aWebCols := {}
	EndIf

	GridHeader(	HttpSession->PWSC078INFO, ;
					HttpSession->PWSC078HEADER[1], ;
					aWebCols )

	GridLinesEx( { HttpSession->PWSC078INFO, ;
					HttpSession->PWSC078HEADER[1], ;
					HttpSession->PWSC078RESULT[1], ;
					aWebCols, .F., "A",, 0 }, "MTPRODUCTIONORDER" )
Else
	Return PWSHTMLALERT( "", STR0004 , "", "W_PWSC070.APW" )//"Erro"
EndIf

cHtml += ExecInPage( "PWSC078" )

WEB EXTENDED END

Return cHtml

/**************************************************************************************************/
// Tela para visualizaco perdas
Web Function PWSC079()

Local cHtml 		:= ""		//Pagina HTML
Local oObj						//Objeto WS MTPRODUCTIONORDER
Local aWebCols		:= {}		//Array com os campos a serem apresentados

WEB EXTENDED INIT cHtml START "InSite"

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTPRODUCTIONORDER' ), WSMTPRODUCTIONORDER():NEW() )
WsChgUrl( @oObj, "MTPRODUCTIONORDER.apw" )

If Empty( HttpSession->PWSC079HEADER )
	If oObj:GETHEADER( "POLOSSVIEW" )
		HttpSession->PWSC079HEADER := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
	Else
		Return PWSHTMLALERT( "", STR0004 , "", "W_PWSC070.APW" )//"Erro"
	EndIf
EndIf

HttpSession->PWSC079APH := { STR0011 }//"Perdas"
HttpSession->PWSC079INFO := {}

aOP := Separa( HttpPost->cOP, "|" )

oObj:cUSERCODE		:= GetUsrCode()
oObj:cPOID			:= aOP[1]
oObj:cPOITEM		:= aOP[2]
oObj:cPOSEQUENCE	:= aOP[3]

//cUSERCODE,cPOID,cPOITEM,cPOSEQUENCE
If oObj:BRWPOLOSS()
	HttpSession->PWSC079RESULT := { oObj:oWSBRWPOLOSSRESULT:oWSPOLOSSVIEW }

	If ExistBlock( "PEC079" )
		aWebCols := ExecBlock( "PEC079", .F., .F., {} )
	Else
		aWebCols := {}
	EndIf

	GridHeader(	HttpSession->PWSC079INFO, ;
				HttpSession->PWSC079HEADER[1], ;
				aWebCols )

	GridLinesEx( { HttpSession->PWSC079INFO, ;
					HttpSession->PWSC079HEADER[1], ;
					HttpSession->PWSC079RESULT[1], ;
					aWebCols, .F., "A",, 0 }, "MTPRODUCTIONORDER" )
Else
	Return PWSHTMLALERT( "", STR0004, "", "W_PWSC070.APW" )//"Erro"
EndIf

cHtml += ExecInPage( "PWSC079" )

WEB EXTENDED END

Return cHtml
