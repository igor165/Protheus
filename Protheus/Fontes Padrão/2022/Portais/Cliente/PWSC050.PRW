#INCLUDE "PWSC050.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSC050   ºAutor  ³ Vendas Clientes     º Data ³  21/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela de selecao de clientes.                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Portal Protheus                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSC050()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

HttpPost->PWSC020CLI := GetUserCli()

HttpSession->PWSC020APH := { STR0012, ;					//"Pedidos de Venda"
								"W_PWSC051.APW", ;		// Proxima Tela
								""	} 					// Msg de Erro

If Len( HttpPost->PWSC020CLI ) <= 1
	HttpSession->PWSC020APH[3] := STR0002 //"Não há clientes a consultar."

	cHtml += ExecInPage( "PWSC020" )
ElseIf Len(HttpPost->PWSC020CLI) = 2
	//Apenas 1 cliente. Define a navegação para pular a tela de seleção de cliente
	HttpPost->CODCLIERP	:= HttpPost->PWSC020CLI[2][2]

	cHtml += W_PWSC051()
Else
	//Mais de 1 cliente? Chama tela de seleção de CLientes
	cHtml += ExecInPage( "PWSC020" )
EndIf

WEB EXTENDED END

Return cHtml


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSC051   ºAutor  ³ Vendas Clientes     º Data ³  21/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela de apresentacao da busca do pedido.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Portal Protheus                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSC051()

Local cHtml := ""
Local oObj

WEB EXTENDED INIT cHtml START "InSite"

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTCUSTOMERSALESORDER' ), WSMTCUSTOMERSALESORDER():New() )
WsChgURL( @oObj, "MTCUSTOMERSALESORDER.APW" )

If !Empty( HttpPost->CODCLIERP )
	HttpSession->CODCLIERP := HttpPost->CODCLIERP
EndIf

If Empty( HttpSession->PWSC052HEADER )
	HttpSession->PWSC052HEADER := { {}, {} }
	
	If oObj:GETHEADER( "SALESORDERHEADERVIEW" )
		HttpSession->PWSC052HEADER[1] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
	Else
		Return PWSHTMLALERT( "", STR0003, "", "W_PWSC050.APW" )//"Erro"
	EndIf

	If oObj:GETHEADER( "SALESORDERITEMVIEW" )
		HttpSession->PWSC052HEADER[2] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
	Else
		Return PWSHTMLALERT( "", STR0003, "", "W_PWSC050.APW" )//"Erro"
	EndIf
EndIf

HttpSession->PWSC054GRAVA := {}
HttpSession->PWSC051APH := { STR0001, "W_PWSC052.APW", "W_PWSC054.APW" }//"Processamento de Pedidos"

cHtml += ExecInPage( "PWSC051" )

WEB EXTENDED END

Return cHtml


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSC052   ºAutor  ³ Vendas Clientes     º Data ³  21/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela de resultado da busca do pedido.                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Portal Protheus                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSC052()

Local cHtml 	:= ""
Local oObj
Local oObjTotalSO
Local aWebCols 	:= {}

WEB EXTENDED INIT cHtml START "InSite"

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTCUSTOMERSALESORDER' ), WSMTCUSTOMERSALESORDER():New() )
oObjTotalSO :=  IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTCUSTOMERSALESORDER' ), WSMTCUSTOMERSALESORDER():New() )
WsChgURL( @oObj, "MTCUSTOMERSALESORDER.APW" )
WsChgURL( @oObjTotalSO, "MTCUSTOMERSALESORDER.APW" )

HttpSession->PWSC052APH := { STR0013, "W_PWSC053.APW" }//"Resultado Busca"

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
	If HttpPost->cBusca == "1" .OR. HttpPost->cBusca == "2"
		//cUSERCODE,cCUSTOMERID,dREGISTERDATEFROM,dREGISTERDATETO,cBIDNUMBERFROM,cBIDNUMBERTO,cQUERYADDWHERE
		If oObjTotalSO:BRWTOTALSALESORDER()
			HttpSession->nTotalSO := oObjTotalSO:nBRWTOTALSALESORDERRESULT
		Else
			Return PWSHTMLALERT( "", STR0003, "", "W_PWSC050.APW" )//"Erro"
		EndIf
	EndIf
	
	HttpSession->PWSC052RESULT := { oObj:oWSBRWSALESORDERRESULT:oWSSALESORDERHEADERVIEW }
	HttpSession->PWSC052INFO := {}

	If ExistBlock( "PEC052" )
		aWebCols := ExecBlock( "PEC052", .F., .F., {} )
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

	GridHeader(	HttpSession->PWSC052INFO, ;
					HttpSession->PWSC052HEADER[1][1], ;
					aWebCols, ;
					HttpSession->PWSC052RESULT[1], "MTCUSTOMERSALESORDER", "SC5" )

	GridLinesEx( { HttpSession->PWSC052INFO, ;
					HttpSession->PWSC052HEADER[1][1], ;
					HttpSession->PWSC052RESULT[1], ;
					aWebCols, .F., "A",, 0 }, "MTCUSTOMERSALESORDER", "SC5" )
Else
	Return PWSHTMLALERT( "", STR0003, "", "W_PWSC050.APW" )//"Erro"
EndIf

cHtml += ExecInPage( "PWSC052" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSC053   ºAutor  ³ Vendas Clientes     º Data ³  21/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela de visualizacao do pedido.                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Portal Protheus                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSC053()

Local cHtml 	:= ""
Local oObj
Local aWebCols 	:= {}

WEB EXTENDED INIT cHtml START "InSite"

HttpSession->PWSC053APH := { STR0008 + HttpGet->cPedido, "W_PWSC052.APW" }//"Pedido Número : "

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTCUSTOMERSALESORDER' ), WSMTCUSTOMERSALESORDER():New() )
WsChgUrl(@oObj,"MTCUSTOMERSALESORDER.apw")

oObj:cUSERCODE		:= GetUsrCode()
oObj:cCUSTOMERID	:= HttpSession->CODCLIERP
oObj:cORDERID		:= HttpGet->cPedido
oObj:cQUERYADDWHERE	:= ""

If oObj:GETSALESORDER()
	HttpSession->PWSC053RESULT := { oObj:oWSGETSALESORDERRESULT }
	HttpSession->PWSC053INFO := { {}, {} }
	
	If ExistBlock( "PEC053" )
		aWebCols := ExecBlock( "PEC053", .F., .F., { 1 } )
	Else
		aWebCols := {}
		aAdd( aWebCols, "ORDERID" )
		aAdd( aWebCols, "ORDERTYPECODE" )
		aAdd( aWebCols, "CUSTOMERCODE" )
		aAdd( aWebCols, "CUSTOMERUNIT" )
		aAdd( aWebCols, "C5_TESTE1" )
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
		aAdd( aWebCols, "C5_TESTE2" )
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

	GridLinesEx( { HttpSession->PWSC053INFO[1], ;
					HttpSession->PWSC052HEADER[1][1], ;
					HttpSession->PWSC053RESULT[1]:oWSSOHEADER, ;
					aWebCols, .F., "H",, 0 },"MTCUSTOMERSALESORDER", "SC5" )
					
	aWebCols := {}

	If ExistBlock( "PEC053" )
		aWebCols := ExecBlock( "PEC053", .F., .F., { 2 } )
	Else
		aWebCols := {}
		aAdd( aWebCols, "ORDERID" )
		aAdd( aWebCols, "ORDERITEM" )
		aAdd( aWebCols, "PRODUCTID" )
		aAdd( aWebCols, "UNITOFMEASURE" )
		aAdd( aWebCols, "QUANTITY" )
		aAdd( aWebCols, "NETUNITPRICE" )
		aAdd( aWebCols, "C6_TESTE1" )
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
		aAdd( aWebCols, "C6_TESTE2" )
		aAdd( aWebCols, "ORIGINALINVOICEITEM" )
		aAdd( aWebCols, "LOTNUMBER" )
		aAdd( aWebCols, "SUBLOT" )
		aAdd( aWebCols, "LOCATION" )
		aAdd( aWebCols, "PRODUCTSERIALNUMBER" )
		aAdd( aWebCols, "MANUFACTURERCODE" )
		aAdd( aWebCols, "MANUFACTURERUNIT" )
		aAdd( aWebCols, "OPERATIONTYPE" )
	EndIf

	GridHeader(	HttpSession->PWSC053INFO[2], ;
					HttpSession->PWSC052HEADER[2][1], ;
					aWebCols, ;
					HttpSession->PWSC053RESULT[1]:oWSSOITEM:oWSSALESORDERITEMVIEW, "MTCUSTOMERSALESORDER", "SC6" )

	GridLinesEx( { HttpSession->PWSC053INFO[2], ;
					HttpSession->PWSC052HEADER[2][1], ;
					HttpSession->PWSC053RESULT[1]:oWSSOITEM:oWSSALESORDERITEMVIEW, ;
					aWebCols, .F., "A",, 0 },"MTCUSTOMERSALESORDER", "SC6" )
Else
	Return PWSHTMLALERT( "", STR0003, "", "W_PWSC050.APW" )//"Erro"
EndIf

cHtml += ExecInPage( "PWSC053" )

WEB EXTENDED END

Return cHtml


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSC053A  ºAutor  ³ Vendas Clientes     º Data ³  21/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela para detalhes de pedidos.                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Portal Protheus                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSC053A()

Local cHtml 	:= ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage( "PWSC053A" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSC054   ºAutor  ³ Vendas Clientes     º Data ³  21/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela de inclusao e alteracado do pedido.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Portal do Cliente                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºCleber M. ³12/06/07³125201³-Implementada a verificacao de permissao paraº±±
±±º          ³        ³      ³alterar pedido ja faturado.				   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSC054()

Local cHtml 	:= ""		//Pagina HTML
Local aWebCols 	:= {}		//Array com os campos a serem apresentados
Local oObj					//Objeto WS - MTCUSTOMERSALESORDER 
Local oObjCli				//Objeto WS - MTCUSTOMER 
Local oObjCfg				//Objeto WS - CFGDICTIONARY
Local nI		:= 0		//Usada em lacos For...Next
Local cMV_ALTPED:= ""		//Retorno do parametro que indica se pode alterar pedido faturado 
Local nPos		:= 0		//Posicao do item no array
Local nTamCodCli:= 6		//Tamanho padrao do campo Cod. de Cliente
Local nTamLoja	:= 2 		//Tamanho padrao do campo Loja Cliente

WEB EXTENDED INIT cHtml START "InSite"

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTCUSTOMERSALESORDER' ), WSMTCUSTOMERSALESORDER():New() )
oObjCli := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTCUSTOMER' ), WSMTCUSTOMER():New() )
oObjCfg := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSCFGDICTIONARY' ), WSCFGDICTIONARY():New() )

WsChgURL( @oObj, "MTCUSTOMERSALESORDER.APW" )
WsChgURL( @oObjCli, "MTCUSTOMER.APW" )
WsChgUrl( @oObjCfg,	"CFGDICTIONARY.APW" )

HttpSession->PWSC054APH := { STR0014, "" }//"Inclusão Pedido de Venda"
HttpSession->PWSC054INFO := { {}, {} }

If HttpPost->cAcao == "A"
	HttpPost->cAcao := "I"
	HttpSession->nTotalPed := 0
	
	oObj:cUSERCODE		:= GetUsrCode()
	oObj:cCUSTOMERID	:= HttpSession->CODCLIERP
	oObj:cORDERID		:= HttpPost->cPedido

	If oObjCfg:GETPARAM(oObj:cUSERCODE, "MV_ALTPED" )
		cMV_ALTPED := oObjCfg:cGETPARAMRESULT
	Else
		Return PWSHTMLALERT( "", STR0003, "", "W_PWSC050.APW" ) //"Erro"
	EndIf
	
	If oObj:GETSALESORDER()
		HttpSession->PWSC054GRAVA := { ,{} }
		HttpSession->PWSC054GRAVA[1] := oObj:oWSGETSALESORDERRESULT:oWSSOHEADER

		For nI := 1 To Len( oObj:oWSGETSALESORDERRESULT:oWSSOITEM:oWSSALESORDERITEMVIEW )
			aAdd( HttpSession->PWSC054GRAVA[2], MTCUSTOMERSALESORDER_SALESORDERITEMVIEW():New() )
			HttpSession->PWSC054GRAVA[2][nI] := oObj:oWSGETSALESORDERRESULT:oWSSOITEM:oWSSALESORDERITEMVIEW[nI]
			HttpSession->nTotalPed += HttpSession->PWSC054GRAVA[2][nI]:nNETTOTAL
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Faz a verificacao de permissao p/ alterar pedido faturado ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Upper(cMV_ALTPED) == "N" .AND. HttpSession->PWSC054GRAVA[2][nI]:nQUANTITYDELIVERED >= HttpSession->PWSC054GRAVA[2][nI]:nQUANTITY
				Return PWSHTMLALERT( "", STR0015, STR0017, "W_PWSC050.APW" )//Atencao - Não será possível alterar pedido faturado (conforme definido no parâmetro MV_ALTPED)
			EndIf
		Next nI
	Else
		Return PWSHTMLALERT( "", STR0003, "", "W_PWSC050.APW" )//"Erro"
	EndIf
Else
	If Empty( HttpSession->PWSC054GRAVA )
		HttpSession->nTotalPed := 0
		
		oObj := MTCUSTOMERSALESORDER_SALESORDERHEADERVIEW():New()
		
		nPos := aScan( HttpSession->PWSC052HEADER[1][1], { |x| Alltrim( x:cHEADERFIELD ) == "CUSTOMERCODE" } )
		If nPos > 0
			nTamCodCli := HttpSession->PWSC052HEADER[1][1][nPos]:nHEADERSIZE
		EndIf
		                                          
		nPos := aScan( HttpSession->PWSC052HEADER[1][1], { |x| Alltrim( x:cHEADERFIELD ) == "CUSTOMERUNIT" } )
		If nPos > 0
			nTamLoja := HttpSession->PWSC052HEADER[1][1][nPos]:nHEADERSIZE
		EndIf
		
		oObj:cCUSTOMERCODE 		:= SubStr( HttpSession->CODCLIERP, 1			, nTamCodCli )
		oObj:cCUSTOMERUNIT 		:= SubStr( HttpSession->CODCLIERP, nTamCodCli+1, nTamLoja )
		oObj:cDELIVERYCUSTOMER 	:= SubStr( HttpSession->CODCLIERP, 1			, nTamCodCli )
		oObj:cDELIVERYUNITCODE 	:= SubStr( HttpSession->CODCLIERP, nTamCodCli+1, nTamLoja )
		
		oObjCli:cUSERCODE		:= GetUsrCode()
		oObjCli:cCUSTOMERID		:= HttpSession->CODCLIERP
		
		//cUSERCODE,cCUSTOMERID
		If oObjCli:GETCUSTOMER()
			oObj:cPAYMENTPLANCODE 	:= oObjCli:oWSGETCUSTOMERRESULT:cPAYMENTPLANCODE
			oObj:cPRICELISTCODE 	:= oObjCli:oWSGETCUSTOMERRESULT:cPRICETABLECODE
		Else
			Return PWSHTMLALERT( "", STR0003, "", "W_PWSC050.APW" )//"Erro"
		EndIf
		
		oObj:dREGISTERDATE 		:= Date()
	
		HttpSession->PWSC054GRAVA := { oObj, { MTCUSTOMERSALESORDER_SALESORDERITEMVIEW():New() } }
	EndIf
EndIf

If HttpPost->cAcao == "I" .AND. Empty( HttpSession->cAcao )
	HttpSession->cAcao := "I"
EndIf

If HttpSession->cAcao == "I"
	If ExistBlock( "PEC054" )
		aWebCols := ExecBlock( "PEC054", .F., .F., { 1 } )
	Else
		aWebCols := {}
		aAdd( aWebCols, { "ORDERID", "D" } )
		aAdd( aWebCols, { "CUSTOMERCODE", "D" } )
		aAdd( aWebCols, { "CUSTOMERUNIT", "D" } )
		aAdd( aWebCols, { "DELIVERYCUSTOMER", "D" } )
		aAdd( aWebCols, "C5_TESTE1" )
		aAdd( aWebCols, { "DELIVERYUNITCODE", "D" } )
		aAdd( aWebCols, { "CARRIERCODE", "N", { "GETCARRIER", ;
												{ "CCARRIERCODE", "CCODE" } ;
												}, ;
												{ "CCODE", "CDESCRIPTION" } } )
		aAdd( aWebCols, { "PAYMENTPLANCODE", "D"  } )
		aAdd( aWebCols, { "PRICELISTCODE", "D" } )
		aAdd( aWebCols, { "DISCOUNT1", "D" } )
		aAdd( aWebCols, { "DISCOUNT2", "D" } )
		aAdd( aWebCols, { "DISCOUNT3", "D" } )
		aAdd( aWebCols, { "DISCOUNT4", "D" } )
		aAdd( aWebCols, "BANKCODE" )
		aAdd( aWebCols, { "FINANCIALDISCOUNT", "D" } )
		aAdd( aWebCols, { "REGISTERDATE", "D" } )
		aAdd( aWebCols, "BIDNUMBER" )
		aAdd( aWebCols, { "FREIGHTVALUE", "D" } )
		aAdd( aWebCols, { "INSURANCEVALUE", "D" } )
		aAdd( aWebCols, { "ADDITIONALEXPENSEVALUE", "D" } )
		aAdd( aWebCols, { "INDEPENDENTFREIGHT", "D" } )
		aAdd( aWebCols, { "ADJUSTMENTTYPE", "D" } )
		aAdd( aWebCols, { "SALESORDERCURRENCY", "N" } )
		aAdd( aWebCols, "C5_TESTE2" )
		aAdd( aWebCols, { "NETWEIGHT", "D" } )
		aAdd( aWebCols, { "GROSSWEIGHT", "D" } )
		aAdd( aWebCols, { "REDELIVERYCARRIERCODE", "D" } )
		aAdd( aWebCols, { "FINANCIALINCREASE", "D" } )
		aAdd( aWebCols, { "INVOICEMESSAGE", "N" } )
		aAdd( aWebCols, { "STANDARDMESSAGE1", "N" } )
		aAdd( aWebCols, { "INDEMNITYVALUE", "D" } )
		aAdd( aWebCols, { "INDEMNITYPERCENTAGE", "D" } )
	EndIf
	
	GridLinesEx( { HttpSession->PWSC054INFO[1], ;
					HttpSession->PWSC052HEADER[1][1], ;
					HttpSession->PWSC054GRAVA[1], ;
					aWebCols, .T., "H",, 1 }, "MTCUSTOMERSALESORDER", "SC5" )
	
	If ExistBlock( "PEC054" )
		aWebCols := ExecBlock( "PEC054", .F., .F., { 2 } )
	Else
		aWebCols := {}
		aAdd( aWebCols, { "PRODUCTID", "N", { "GETCATALOG", ;
														{ "CPRODUCTID", "CPRODUCTCODE" }, ;
														{ "CPRODUCTDESCRIPTION", "CDESCRIPTION"} ; 
													}, ;
													{ "CPRODUCTCODE", "CDESCRIPTION" }, 13 } )
		aAdd( aWebCols, { "PRODUCTDESCRIPTION", "N", 30, .T. } )
		aAdd( aWebCols, { "QUANTITY", "N", 10 } ) 
		aAdd( aWebCols, { "NETUNITPRICE", "N", 15, .F. } ) 
		aAdd( aWebCols, "C6_TESTE1" )
		aAdd( aWebCols, { "CUSTOMERORDERNUMBER", "N", 15 } )
		aAdd( aWebCols, { "NETTOTAL", "N", 15, .F. } )   
		aAdd( aWebCols, "C6_TESTE2" )
	EndIf
	
	For nI := 1 To Len( HttpSession->PWSC054GRAVA[2] )
		If nI == 1
			GridHeader(	HttpSession->PWSC054INFO[2], ;
							HttpSession->PWSC052HEADER[2][1], ;
							aWebCols, ;
							HttpSession->PWSC054GRAVA[2][nI], "MTCUSTOMERSALESORDER", "SC6" )
		EndIf

		GridLinesEx( { HttpSession->PWSC054INFO[2], ;
						HttpSession->PWSC052HEADER[2][1], ;
						HttpSession->PWSC054GRAVA[2][nI], ;
						aWebCols, .T., "H", AllTrim( Str( nI ) ), ;
						IIf( nI == Len( HttpSession->PWSC054GRAVA[2] ), 3, 2 ), .T. }, "MTCUSTOMERSALESORDER", "SC6" )
	Next nI
EndIf

cHtml += ExecInPage( "PWSC054" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PWSC055  ºAutor  ³ Vendas Clientes     º Data ³  21/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina para inclusao, exclusao e alteracao dos itens do     º±±
±±º          ³ pedido.                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Portal Protheus                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSC055()

Local cHtml 	:= ""
Local nPos		:= 0

Private aProp 	:= {}

WEB EXTENDED INIT cHtml START "InSite"

If !Empty( HttpPost->cItem )
	If Len( HttpSession->PWSC054GRAVA[2] ) > 1
		aDel( HttpSession->PWSC054GRAVA[2], Val( HttpPost->cItem ) )
		aSize( HttpSession->PWSC054GRAVA[2], Len( HttpSession->PWSC054GRAVA[2] ) - 1 )
	EndIf
Else
	//Forçar a instancia de campo de usuario no HttpSession
	aProp := PWVPutUsrFld( HttpSession->PWSC054GRAVA[1], "SC5", "MTCUSTOMERSALESORDER" )
	nPos  := aScan( aProp, { |x| x[1] == "OWSUSERFIELDS" } )
	HttpSession->PWSC054GRAVA[1]:oWSuserfields := aProp[nPos][2]
	
	PWSSetObjToPost( HttpSession->PWSC054GRAVA[1], HttpSession->PWSC052HEADER[1][1], HttpPost->aPost )

	//Forçar a instancia de campo de usuario no HttpSession
	aProp := PWVPutUsrFld( HttpSession->PWSC054GRAVA[2][nI], "SC6", "MTCUSTOMERSALESORDER" )
	nPos  := aScan( aProp, { |x| x[1] == "OWSUSERFIELDS" } )
	HttpSession->PWSC054GRAVA[2][nI]:oWSuserfields := aProp[nPos][2]

	nTam := Len( HttpSession->PWSC054GRAVA[2] )	
	PWSSetObjToPost( HttpSession->PWSC054GRAVA[2][nTam], HttpSession->PWSC052HEADER[2][1], HttpPost->aPost, AllTrim( Str( nTam ) ) )
	aAdd( HttpSession->PWSC054GRAVA[2], MTCUSTOMERSALESORDER_SALESORDERITEMVIEW():New() )
EndIf

cHtml += W_PWSC054()

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSC056   ºAutor  ³ Vendas Clientes     º Data ³  21/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina para simulacao do pedido.                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Portal Protheus                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSC056()

Local cHtml 		:= ""
Local oObj          := Nil
Local oObjCfg		:= Nil
Local nI			:= 0
Local nJ			:= 0
Local nSizeProductID:= 15
Local lInclusao		:= Empty(HttpSession->PWSC054GRAVA[1]:CORDERID)
Local nPos			:= 0

Private aProp 		:= {}

WEB EXTENDED INIT cHtml START "InSite"

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTSIMULATIONSALESORDER' ), WSMTSIMULATIONSALESORDER():New() )
oObjCfg := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSCFGDICTIONARY' ), WSCFGDICTIONARY():New() )
WsChgURL( @oObj, "MTSIMULATIONSALESORDER.APW" )
WsChgURL( @oObjCfg, "CFGDICTIONARY.APW" )
oObj:lPortCli := .T.

//Forçar a instancia de campo de usuario no HttpSession
aProp := PWVPutUsrFld( HttpSession->PWSC054GRAVA[1], "SC5", "MTSIMULATIONSALESORDER" )
nPos  := aScan( aProp, { |x| x[1] == "OWSUSERFIELDS" } )
HttpSession->PWSC054GRAVA[1]:oWSuserfields := aProp[nPos][2]

PWSSetObjToPost( HttpSession->PWSC054GRAVA[1], HttpSession->PWSC052HEADER[1][1], HttpPost->aPost )

nTam := Len( HttpSession->PWSC054GRAVA[2] )

For nI := 1 To nTam
	HttpSession->PWSC054GRAVA[2][nI] := MTCUSTOMERSALESORDER_SALESORDERITEMVIEW():New()
	
	aProp := ClassDataArr( HttpSession->PWSC054GRAVA[2][nI] )
	nPos := aScan( aProp, { |x| x[1] == "OWSUSERFIELDS" } )

	oObjCfg:cUSERCODE 	:= GetUsrCode()
	oObjCfg:cALIAS		:= "SC6"
	
	//cUSERCODE,cALIAS
	If oObjCfg:GETUSERFIELD()
		aProp[nPos][2] := MTCUSTOMERSALESORDER_ARRAYOFUSERFIELD():New()
		
		For nJ := 1 To Len( oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD )
			aAdd( aProp[nPos][2]:oWSUSERFIELD, MTCUSTOMERSALESORDER_USERFIELD():New() )
			
			aProp[nPos][2]:oWSUSERFIELD[nJ]:nUSERDEC		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:nUSERDEC
			aProp[nPos][2]:oWSUSERFIELD[nJ]:cUSERNAME		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:cUSERNAME
			aProp[nPos][2]:oWSUSERFIELD[nJ]:lUSEROBLIG		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:lUSEROBLIG
			aProp[nPos][2]:oWSUSERFIELD[nJ]:cUSERPICTURE	:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:cUSERPICTURE
			aProp[nPos][2]:oWSUSERFIELD[nJ]:nUSERSIZE		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:nUSERSIZE
			aProp[nPos][2]:oWSUSERFIELD[nJ]:cUSERTAG		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:cUSERTAG
			aProp[nPos][2]:oWSUSERFIELD[nJ]:cUSERTITLE		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:cUSERTITLE
			aProp[nPos][2]:oWSUSERFIELD[nJ]:cUSERTYPE		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:cUSERTYPE
		Next nJ
	Else
		conout( GetWsCError( 3 ) )
	EndIf

	//Forçar a instancia de campo de usuario no HttpSession
	aProp := PWVPutUsrFld( HttpSession->PWSC054GRAVA[2][nI], "SC6", "MTSIMULATIONSALESORDER" )
	nPos  := aScan( aProp, { |x| x[1] == "OWSUSERFIELDS" } )
	HttpSession->PWSC054GRAVA[2][nI]:oWSuserfields := aProp[nPos][2]
	
	PWSSetObjToPost( HttpSession->PWSC054GRAVA[2][nI], HttpSession->PWSC052HEADER[2][1], HttpPost->aPost, AllTrim( Str( nI ) ) )
	HttpSession->PWSC054GRAVA[2][nI]:cORDERITEM := StrZero( nI, 2 )
	HttpSession->PWSC054GRAVA[2][nI]:nNETTOTAL	:= 0
Next nI

oObj:cUSERCODE			:= GetUsrCode()
oObj:oWSOLDSALESORDER := MTSIMULATIONSALESORDER_SALESORDERVIEW():New()
oObj:oWSOLDSALESORDER:oWSSOHEADER	:= HttpSession->PWSC054GRAVA[1]
oObj:oWSOLDSALESORDER:oWSSOHEADER:cORDERTYPECODE := "N"
oObj:oWSOLDSALESORDER:oWSSOITEM		:= MTSIMULATIONSALESORDER_ARRAYOFSALESORDERITEMVIEW():New()

For nI := 1 To Len( HttpSession->PWSC054GRAVA[2] )
	aAdd( oObj:oWSOLDSALESORDER:oWSSOITEM:oWSSALESORDERITEMVIEW, MTSIMULATIONSALESORDER_SALESORDERITEMVIEW():New() )
	oObj:oWSOLDSALESORDER:oWSSOITEM:oWSSALESORDERITEMVIEW[nI] := HttpSession->PWSC054GRAVA[2][nI]
	oObj:oWSOLDSALESORDER:oWSSOITEM:oWSSALESORDERITEMVIEW[nI]:cPRODUCTID := PadR( oObj:oWSOLDSALESORDER:oWSSOITEM:oWSSALESORDERITEMVIEW[nI]:cPRODUCTID, nSizeProductID )
Next nI                       



If oObj:PUTSALESORDER()
	HttpSession->PWSC054GRAVA[1] := oObj:oWSPUTSALESORDERRESULT:oWSSOHEADER
	If lInclusao
		oObj:OWSPUTSALESORDERRESULT:OWSSOHEADER:CORDERID := ""
		HttpSession->PWSC054GRAVA[1]:CORDERID := ""		
	EndIf
	HttpSession->PWSC054GRAVA[2] := {}
	HttpSession->nTotalPed := 0
	For nI := 1 To Len( oObj:oWSPUTSALESORDERRESULT:oWSSOITEM:oWSSALESORDERITEMVIEW )
		aAdd( HttpSession->PWSC054GRAVA[2], MTSIMULATIONSALESORDER_SALESORDERITEMVIEW():New() )
		HttpSession->PWSC054GRAVA[2][nI] := oObj:oWSPUTSALESORDERRESULT:oWSSOITEM:oWSSALESORDERITEMVIEW[nI]
		HttpSession->nTotalPed += HttpSession->PWSC054GRAVA[2][nI]:nNETTOTAL
	Next nI
Else
	Return PWSHTMLALERT( "", STR0003, "", "W_PWSC054.APW" )//"Erro"
EndIf

cHtml += W_PWSC054()

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSC057   ºAutor  ³ Vendas Clientes     º Data ³  21/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina para inclusao, exclusao e alteracao do pedido        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Portal Protheus                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSC057()

Local cHtml 			:= ""
Local oObj				:= Nil
Local oObjCfg           := Nil
Local nI				:= 0
Local nJ				:= 0
Local nSizeProductID	:= 15
Local lInclusao			:= Empty(HttpSession->PWSC054GRAVA[1]:CORDERID)
Local nPos 				:= 0

Private aProp 			:= {}

WEB EXTENDED INIT cHtml START "InSite"

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTCUSTOMERSALESORDER' ), WSMTCUSTOMERSALESORDER():New() )
oObjCfg := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSCFGDICTIONARY' ), WSCFGDICTIONARY():New() )
WsChgURL( @oObj, "MTCUSTOMERSALESORDER.APW" )
WsChgURL( @oObjCfg, "CFGDICTIONARY.APW" )

//Forçar a instancia de campo de usuario no HttpSession
aProp := PWVPutUsrFld( HttpSession->PWSC054GRAVA[1], "SC5", "MTCUSTOMERSALESORDER" )
nPos  := aScan( aProp, { |x| x[1] == "OWSUSERFIELDS" } )
HttpSession->PWSC054GRAVA[1]:oWSuserfields := aProp[nPos][2]

PWSSetObjToPost( HttpSession->PWSC054GRAVA[1], HttpSession->PWSC052HEADER[1][1], HttpPost->aPost )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Pega o tamanho do código do produto.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("HttpSession->PWSC054GRAVA[2]") == "A" .And. Len(HttpSession->PWSC054GRAVA[2]) > 0  .And. HttpSession->PWSC054GRAVA[2][1]:cPRODUCTID != NIL
	nSizeProductID := Len(HttpSession->PWSC054GRAVA[2][1]:cPRODUCTID)
EndIf

nTam := Len( HttpSession->PWSC054GRAVA[2] )

For nI := 1 To nTam
	HttpSession->PWSC054GRAVA[2][nI] := MTCUSTOMERSALESORDER_SALESORDERITEMVIEW():New()

	aProp := ClassDataArr( HttpSession->PWSC054GRAVA[2][nI] )
	nPos := aScan( aProp, { |x| x[1] == "OWSUSERFIELDS" } )

	oObjCfg:cUSERCODE 	:= GetUsrCode()
	oObjCfg:cALIAS		:= "SC6"
	
	//cUSERCODE,cALIAS
	If oObjCfg:GETUSERFIELD()
		aProp[nPos][2] := MTCUSTOMERSALESORDER_ARRAYOFUSERFIELD():New()
		
		For nJ := 1 To Len( oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD )
			aAdd( aProp[nPos][2]:oWSUSERFIELD, MTCUSTOMERSALESORDER_USERFIELD():New() )
			
			aProp[nPos][2]:oWSUSERFIELD[nJ]:nUSERDEC		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:nUSERDEC
			aProp[nPos][2]:oWSUSERFIELD[nJ]:cUSERNAME		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:cUSERNAME
			aProp[nPos][2]:oWSUSERFIELD[nJ]:lUSEROBLIG		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:lUSEROBLIG
			aProp[nPos][2]:oWSUSERFIELD[nJ]:cUSERPICTURE	:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:cUSERPICTURE
			aProp[nPos][2]:oWSUSERFIELD[nJ]:nUSERSIZE		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:nUSERSIZE
			aProp[nPos][2]:oWSUSERFIELD[nJ]:cUSERTAG		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:cUSERTAG
			aProp[nPos][2]:oWSUSERFIELD[nJ]:cUSERTITLE		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:cUSERTITLE
			aProp[nPos][2]:oWSUSERFIELD[nJ]:cUSERTYPE		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:cUSERTYPE
		Next nJ
	Else
		conout( GetWsCError( 3 ) )
	EndIf

	//Forçar a instancia de campo de usuario no HttpSession
	aProp := PWVPutUsrFld( HttpSession->PWSC054GRAVA[2][nI], "SC6", "MTCUSTOMERSALESORDER" )
	nPos  := aScan( aProp, { |x| x[1] == "OWSUSERFIELDS" } )
	HttpSession->PWSC054GRAVA[2][nI]:oWSuserfields := aProp[nPos][2]
	
	PWSSetObjToPost( HttpSession->PWSC054GRAVA[2][nI], HttpSession->PWSC052HEADER[2][1], HttpPost->aPost, AllTrim( Str( nI ) ) )
	HttpSession->PWSC054GRAVA[2][nI]:cORDERITEM := StrZero( nI, 2 )
Next nI

oObj:cUSERCODE			:= GetUsrCode()
oObj:cCUSTOMERID		:= HttpSession->CODCLIERP
oObj:oWSSALESORDER := MTCUSTOMERSALESORDER_SALESORDERVIEW():New()
oObj:oWSSALESORDER:oWSSOHEADER	:= HttpSession->PWSC054GRAVA[1]
oObj:oWSSALESORDER:oWSSOHEADER:cORDERTYPECODE := "N"
oObj:oWSSALESORDER:oWSSOITEM	:= MTCUSTOMERSALESORDER_ARRAYOFSALESORDERITEMVIEW():New()

For nI := 1 To Len( HttpSession->PWSC054GRAVA[2] )
	aAdd( oObj:oWSSALESORDER:oWSSOITEM:oWSSALESORDERITEMVIEW, MTCUSTOMERSALESORDER_SALESORDERITEMVIEW():New() )
	oObj:oWSSALESORDER:oWSSOITEM:oWSSALESORDERITEMVIEW[nI] := HttpSession->PWSC054GRAVA[2][nI]
	oObj:oWSSALESORDER:oWSSOITEM:oWSSALESORDERITEMVIEW[nI]:cPRODUCTID := PadR( oObj:oWSSALESORDER:oWSSOITEM:oWSSALESORDERITEMVIEW[nI]:cPRODUCTID, nSizeProductID )
Next nI

If lInclusao	
	oObj:OWSSALESORDER:OWSSOHEADER:CBIDNUMBER:=""	
	HttpSession->PWSC054GRAVA[1]:CBIDNUMBER := ""			
EndIf
//cUSERCODE,cCUSTOMERID,oWSSALESORDER
If oObj:PUTSALESORDER()
	Return PWSHTMLALERT( "", STR0015, STR0008 + oObj:cPUTSALESORDERRESULT + STR0016, "W_PWSC050.APW" )//"Atenção","Pedido Número "," cadastrado com SUCESSO!"
Else
	Return PWSHTMLALERT( "", STR0003, "", "W_PWSC054.APW" )//"Erro"
EndIf

cHtml += W_PWSC054()

WEB EXTENDED END

Return cHtml
