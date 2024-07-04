#INCLUDE "PWSF070.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"

#DEFINE FORNECERP_ENTIDADE 1
#DEFINE FORNECERP_CODIGO   2
#DEFINE FORNECERP_NOMEFANT 3
#DEFINE FORNECERP_RAZAOSOC 4
#DEFINE FORNECERP_CPFCNPJ  5

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSF07*   ºAutor  ³ Flavio Luiz Vicco   º Data ³  28/09/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Este fonte possui as funcionalidades relacionado ao         º±±
±±º          ³ Documento de Entrega (Pre-Nota)                             º±±
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
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSF070   ºAutor  ³ Flavio Luiz Vicco   º Data ³  28/09/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Mostra os Fornecedores disponiveis para o usuario logado.   º±±
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
Web Function PWSF070()

Local cHtml := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fornecedores cadastrados para o usuario logado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpPost->PWSF020FOR := GetUserFor()
HttpSession->PWSF020FOR := HttpPost->PWSF020FOR

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Informacoes a serem utilizadas pelo APH³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpSession->PWSF020APH := { 	STR0001,;
								"W_PWSF071.APW"	,;			// Proxima Tela
								""	} 						// Msg de Erro
Do Case
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Nao ha fornecedores cadastrados para o usuario logado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case Empty( HttpPost->PWSF020FOR )
		HttpSession->PWSF020APH[3] := STR0002 //"Não há Fornecedores a consultar."
		cHtml += ExecInPage( "PWSF020" )
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Apenas 1 fornecedor cadastrado.                               ³
	//³ Define a navegação para pular a tela de seleção de Fornecedor³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case Len( HttpPost->PWSF020FOR ) == 2	
		HttpPost->CODFORERP := HttpPost->PWSF020FOR[2][2]
		cHtml += W_PWSF071()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 	//³Mais de 1 fornecedor. Chama tela de seleção de Fornecedores³
  	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Otherwise
		cHtml += ExecInPage( "PWSF020" )

EndCase

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSF071   ºAutor  ³ Flavio Luiz Vicco   º Data ³  28/09/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela de Busca dos Documentos de Entrega do Fornecedor.      º±±
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
Web Function PWSF071()

Local cHtml := ""
Local oObj
Local oObjPedido

WEB EXTENDED INIT cHtml START "InSite"

If !Empty( HttpPost->CODFORERP )
	HttpSession->CODFORERP := HttpPost->CODFORERP
EndIf

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTSUPPLIERINVOICE"), WSMTSUPPLIERINVOICE():New())
WsChgURL( @oObj, "MTSUPPLIERINVOICE.APW" )

oObjPedido := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTSUPPLIERPURCHASEORDER"), WSMTSUPPLIERPURCHASEORDER():New())
WsChgURL( @oObjPedido, "MTSUPPLIERPURCHASEORDER.APW" )

If Empty( HttpSession->PWSF072HEADER )
	HttpSession->PWSF072HEADER := { { }, { }, { }, { } }
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ HEADER Cabecalho - Documento de Entrega ³
	//³ -oWSCARRIER         : Transpotadora     ³
	//³ -dDELIVERYDATE      : Dt. Entrega       ³
	//³ -cDOCUMENTTYPE      : Form. Prop.     03³
	//³ -nEXPENSESVALUE     : Vl. Despesa     07³
	//³ -nFREIGHTVALUE      : Vlr.Frete       09³
	//³ -oWSFROMROLE        :                   ³
	//³ -nINSURANCEVALUE    : Vlr.Seguro      08³
	//³ -dINVOICEDATE       : Dt.Digitacao    06³
	//³ -cINVOICENUMBER     : Numero          02³
	//³ -cINVOICETYPE       : Tipo Nota E/S   04³
	//³ -oWSPACKAGESVOLUMES : Volume            ³
	//³ -oWSPAYMENTPLAN     : Cond. Pagto       ³
	//³ -dREGISTERDATE      : DT Emissao      05³
	//³ -cSERIALNUMBER      : Serie Docto.    01³
	//³ -oWSTAXES           : Impostos          ³
	//³ -oWSTOROLE          :                   ³
	//³ -nTOTALVALUE        : Total           10³
	//³ -oWSUSERFIELDS      : Cpos Usuar.       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oObj:cHEADERTYPE := "INVOICEHEADERVIEW"
	If oObj:GETHEADER()
		HttpSession->PWSF072HEADER[1] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
	Else
		Return PWSHTMLALERT( "", STR0006, "", "W_PWSF070.APW" ) //"Erro"
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ HEADER Itens - Documento de Entrega       ³
	//³ -cDESCRIPTIONPRODUCT     : Descricao     3³
	//³ -nDISCOUNTPERCENT        : Desc.Item     8³
	//³ -nDISCOUNTVALUE          : Desconto      9³
	//³ -nEXPENSESVALUE          : Vlr. Despesa 10³
	//³ -nFREIGHTVALUE           : Vlr. Frete   12³
	//³ -nINSURANCEVALUE         : Vlr. Seguro  11³
	//³ -oWSLOTIDENTIFIER        :                ³
	//³ -cMEASUREUNIT            : Unidade       4³
	//³ -cPRODUCTCODE            : Produto       2³
	//³ -oWSPURCHASEORDER        : Array P.V.     ³
	//³ -cQUALITYCONTROLDOCUMENT : Doc CQ         ³
	//³ -nQUANTITY               : Quantidade    5³
	//³ -oWSSALESORDER           : Array P.C      ³
	//³ -cSEQUENTIALID           : Item	         1³
	//³ -oWSTAXES                : Impostos       ³
	//³ -nTOTALVALUE             : Vlr.Total     7³
	//³ -nUNITPRICE              : Vlr.Unitario  6³
	//³ -oWSUSERFIELDS           : Cpos Usuar.    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oObj:cHEADERTYPE := "INVOICEITEMVIEW"
	If oObj:GETHEADER()
		HttpSession->PWSF072HEADER[2] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
	Else
		Return PWSHTMLALERT( "", STR0006, "", "W_PWSF070.APW" ) //"Erro"
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ HEADER Cabecalho - Pedido de Compra     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oObjPedido:cHEADERTYPE := "PURCHASEORDERHEADERVIEW"

	If oObjPedido:GETHEADER()
		HttpSession->PWSF072HEADER[3] := { oObjPedido:oWSGETHEADERRESULT:oWSBRWHEADER }
	Else
		Return PWSHTMLALERT( "", STR0006, "", "W_PWSF070.APW" ) //"Erro"
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ HEADER Itens - Pedido de Compra         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oObjPedido:cHEADERTYPE := "PURCHASEORDERITEMVIEW"
	If oObjPedido:GETHEADER()
		HttpSession->PWSF072HEADER[4] := { oObjPedido:oWSGETHEADERRESULT:oWSBRWHEADER }
	Else
		Return PWSHTMLALERT( "", STR0006, "", "W_PWSF070.APW" ) //"Erro
	EndIf

EndIf

HttpSession->PWSF074GRAVA 	:= { }
HttpSession->PWSF071APH 	:= { STR0001, "W_PWSF072.APW", "W_PWSF074.APW" }

cHtml += ExecInPage( "PWSF071" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSF072   ºAutor  ³ Flavio Luiz Vicco   º Data ³  28/09/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela de resultado da busca dos Documentos de Entrega.       º±±
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
Web Function PWSF072()

Local cHtml 	:= ""
Local oObj
Local aWebCols 	:= { }

WEB EXTENDED INIT cHtml START "InSite"

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTSUPPLIERINVOICE"), WSMTSUPPLIERINVOICE():New())
WsChgURL( @oObj, "MTSUPPLIERINVOICE.APW" )

HttpSession->PWSF072APH := { STR0001+" - "+STR0016, "W_PWSF073.APW" } //"Resultado da Busca"

//dREGISTERDATEFROM,dREGISTERDATETO,dDELIVERYDATEFROM,dDELIVERYDATETO

If ( !Empty( HttpGet->dREGISTERDATEFROM ) .AND. !Empty( HttpGet->dREGISTERDATETO ) ) .OR. ;
	( !Empty( HttpGet->dDELIVERYDATEFROM ) .AND. !Empty( HttpGet->dDELIVERYDATETO ) )
	HttpPost->dREGISTERDATEFROM 	:= HttpGet->dREGISTERDATEFROM
	HttpPost->dREGISTERDATETO 		:= HttpGet->dREGISTERDATETO
	HttpPost->dDELIVERYDATEFROM 	:= HttpGet->dDELIVERYDATEFROM
	HttpPost->dDELIVERYDATETO	 	:= HttpGet->dDELIVERYDATETO
EndIf

oObj:cUSERCODE				:= GetUsrCode()
oObj:nCUSTOMERORSUPPLIER	:= 2
oObj:cCUSTOMERORSUPPLIERID	:= HttpSession->CODFORERP
oObj:dREGISTERDATEFROM		:= CToD( HttpPost->dREGISTERDATEFROM )
oObj:dREGISTERDATETO		:= CToD( HttpPost->dREGISTERDATETO )
oObj:dDELIVERYDATEFROM		:= CToD( HttpPost->dDELIVERYDATEFROM )
oObj:dDELIVERYDATETO		:= CToD( HttpPost->dDELIVERYDATETO )
oObj:cOperationType  		:= "E"

If !Empty( HttpPost->cBuscaAv )
	Do Case
		Case HttpPost->cComboAv == "1"
			oObj:cQUERYADDWHERENFE := "SF1.F1_DOC='" + HttpPost->cBuscaAv + "'"
	EndCase
Else
	oObj:cQUERYADDWHERENFE := ""
EndIf

//cUSERCODE,nCUSTOMERORSUPPLIER,cCUSTOMERORSUPPLIERID,dREGISTERDATEFROM,dREGISTERDATETO,dDELIVERYDATEFROM,dDELIVERYDATETO,cQUERYADDWHERENFE,cQUERYADDWHERENFS,cINDEXKEYNFE,cINDEXKEYNFS,cPURCHASENUMBER
If oObj:BRWINVOICE()
	HttpSession->PWSF072RESULT	:= { oObj:oWSBRWINVOICERESULT:oWSINVOICEHEADERVIEW }
	HttpSession->PWSF072INFO	:= { }

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³     -  B R O W S E  -     ³
	//³-cpo. Obrig. INVOICESTATUS ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock( "PEF072" )
		aWebCols := ExecBlock( "PEF072", .F., .F., { } )
	Else
		aAdd( aWebCols, "INVOICENUMBER" )
		aAdd( aWebCols, "SERIALNUMBER" )
		aAdd( aWebCols, "DOCUMENTTYPE" )
		aAdd( aWebCols, "INVOICETYPE" )
		aAdd( aWebCols, "REGISTERDATE" )
		aAdd( aWebCols, "INVOICEDATE" )
		aAdd( aWebCols, "TOTALVALUE" )
		aAdd( aWebCols, "INVOICESTATUS" )
	EndIf

	GridHeader(		HttpSession->PWSF072INFO, ;
					HttpSession->PWSF072HEADER[1][1], ;
					aWebCols )

	GridLinesEx( { 	HttpSession->PWSF072INFO, ;
					HttpSession->PWSF072HEADER[1][1], ;
					HttpSession->PWSF072RESULT[1], ;
					aWebCols, .F., "A",, 0 } )
Else
	Return PWSHTMLALERT( "", STR0006, "", "W_PWSF070.APW" ) //"Erro"
EndIf

cHtml += ExecInPage( "PWSF072" )

HttpSession->dDELIVERYDATEFROM := HttpPost->dDELIVERYDATEFROM
HttpSession->dDELIVERYDATETO   := HttpPost->dDELIVERYDATETO

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSF073   ºAutor  ³ Flavio Luiz Vicco   º Data ³  28/09/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela de visualizacao dos Documentos de Entrega.             º±±
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
Web Function PWSF073()

Local cHtml 	:= ""
Local aWebCols 	:= { }
Local oObj

WEB EXTENDED INIT cHtml START "InSite"

HttpSession->PWSF073APH := { STR0001+" : " + HttpSession->PWSF072RESULT[1][Val( HttpGet->cDocumento )]:cINVOICETYPE + "/" + HttpSession->PWSF072RESULT[1][Val( HttpGet->cDocumento )]:cSERIALNUMBER + "/" + HttpSession->PWSF072RESULT[1][Val( HttpGet->cDocumento )]:cINVOICENUMBER + "/" + HttpSession->PWSF072RESULT[1][Val( HttpGet->cDocumento )]:cDOCUMENTTYPE, "W_PWSF072.APW" }

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTSUPPLIERINVOICE"), WSMTSUPPLIERINVOICE():New())
WsChgUrl( @oObj, "MTSUPPLIERINVOICE.APW" )

oObj:cUSERCODE				:= GetUsrCode()
oObj:cINVOICETYPE			:= HttpSession->PWSF072RESULT[1][Val( HttpGet->cDocumento )]:cINVOICETYPE
oObj:cSERIALNUMBER			:= HttpSession->PWSF072RESULT[1][Val( HttpGet->cDocumento )]:cSERIALNUMBER
oObj:cINVOICENUMBER			:= HttpSession->PWSF072RESULT[1][Val( HttpGet->cDocumento )]:cINVOICENUMBER
oObj:cDOCUMENTTYPE			:= HttpSession->PWSF072RESULT[1][Val( HttpGet->cDocumento )]:cDOCUMENTTYPE
oObj:nCUSTOMERORSUPPLIER	:= 2
oObj:cCUSTOMERORSUPPLIERID	:= HttpSession->CODFORERP

//cUSERCODE,cINVOICETYPE,cSERIALNUMBER,cINVOICENUMBER,cDOCUMENTTYPE,nCUSTOMERORSUPPLIER,cCUSTOMERORSUPPLIERID,cQUERYADDWHERENFE,cQUERYADDWHERENFS
If oObj:GETINVOICE()
	HttpSession->PWSF073RESULT 	:= { oObj:oWSGETINVOICERESULT }
	HttpSession->PWSF073INFO 	:= { { }, { } }
	
	If ExistBlock( "PEF073" )
		aWebCols := ExecBlock( "PEF073", .F., .F., { 1 } )
	Else
		aAdd( aWebCols, "INVOICENUMBER" )
		aAdd( aWebCols, "SERIALNUMBER" )
		aAdd( aWebCols, "DOCUMENTTYPE" )
		aAdd( aWebCols, "INVOICETYPE" )
		aAdd( aWebCols, "REGISTERDATE" )
		aAdd( aWebCols, "INVOICEDATE" )
		aAdd( aWebCols, "EXPENSESVALUE" )
		aAdd( aWebCols, "INSURANCEVALUE" )
		aAdd( aWebCols, "FREIGHTVALUE" )
		aAdd( aWebCols, "TOTALVALUE" )
	EndIf

	GridLinesEx( { 	HttpSession->PWSF073INFO[1], ;
					HttpSession->PWSF072HEADER[1][1], ;
					HttpSession->PWSF073RESULT[1]:oWSINVOICEHEADER, ;
					aWebCols, .F., "H",, 0 }, "MTSUPPLIERINVOICE", "SD1" )
					
	aWebCols := { }

	If ExistBlock( "PEF073" )
		aWebCols := ExecBlock( "PEF073", .F., .F., { 2 } )
	EndIf

	GridHeader(		HttpSession->PWSF073INFO[2], ;
					HttpSession->PWSF072HEADER[2][1], ;
					aWebCols, ;
					HttpSession->PWSF073INFO[2], "MTSUPPLIERINVOICE", "SF1" )

	GridLinesEx( {	HttpSession->PWSF073INFO[2], ;
					HttpSession->PWSF072HEADER[2][1], ;
					HttpSession->PWSF073RESULT[1]:oWSINVOICEITEM:oWSINVOICEITEMVIEW, ;
					aWebCols, .F., "A",, 0 }, "MTSUPPLIERINVOICE", "SF1" )
Else
	Return PWSHTMLALERT( "", STR0006, "", "W_PWSF072.APW" ) //"Erro"
EndIf

cHtml += ExecInPage( "PWSF073" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSF073A  ºAutor  ³ Flavio Luiz Vicco   º Data ³  28/09/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela de visualizacao dos detalhes dos itens dos             º±±
±±º          ³ dos Documentos de Entrega.                                  º±±
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
Web Function PWSF073A()

Local cHtml 	:= ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage( "PWSF073A" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSF074   ºAutor  ³ Flavio Luiz Vicco   º Data ³  28/09/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela de inclusao e alteracado dos Documentos de Entrega.    º±±
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
Web Function PWSF074()

Local cHtml 	:= ""
Local nI		:= 0
Local nJ		:= 0
Local nTam		:= 0
Local aWebCols 	:= {}
Local aPedidos	:= {}
Local nQuant	:= 0
Local nQuJE		:= 0
Local nQtdACla	:= 0
Local nSaldo    := 0
Local nPrUn		:= 0
Local lAlt      := .F.
Local oObj
Local oObjPed

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o WS - MTSUPPLIERINVOICE ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTSUPPLIERINVOICE"), WSMTSUPPLIERINVOICE():New())
WsChgURL( @oObj, "MTSUPPLIERINVOICE.APW" )

oObjPed	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTSUPPLIERPURCHASEORDER"), WSMTSUPPLIERPURCHASEORDER():New())
WsChgUrl( @oObjPed, "MTSUPPLIERPURCHASEORDER.apw" )

HttpSession->PWSF074APH			:= { STR0038+" "+STR0001, "" }
HttpSession->PWSF074INFO		:= { { }, { }, { }, { } }

If HttpSession->dDELIVERYDATEFROM == Nil
	HttpSession->dDELIVERYDATEFROM := HttpPost->dDELIVERYDATEFROM
EndIf

If HttpSession->dDELIVERYDATETO == Nil
	HttpSession->dDELIVERYDATETO   := HttpPost->dDELIVERYDATETO
EndIf
                        
If !Empty( HttpPost->cPURCHASEORDERID )
	HttpSession->PWSF074GRAVA[2] 	:= { }
	aPedidos 						:= Separa( HttpPost->cPURCHASEORDERID, "," )
	
	For nI := 1 To Len( aPedidos )
		oObjPed:cUSERCODE			:= GetUsrCode()
		oObjPed:cPURCHASEORDERID	:= AllTrim( aPedidos[nI] )
		oObjPed:cSUPPLIER			:= HttpSession->CODFORERP
	
		//cUSERCODE,cPURCHASEORDERID,cSUPPLIER,cQUERYADDWHERE
		If oObjPed:GETPURCHASEORDER()
			HttpSession->PWSF074RESULTPEDCOM := { oObjPed:oWSGETPURCHASEORDERRESULT:oWSPOITEM:oWSPURCHASEORDERITEMVIEW }
			
			For nJ := 1 To Len( HttpSession->PWSF074RESULTPEDCOM[1] )
				// ( C7_Quant - C7_QuJE           - C7_QtdACla         ) > 0
				// ( Quantity - QuantityDelivered - QuantityToClassify ) > 0
				nQuant		:= HttpSession->PWSF074RESULTPEDCOM[1][nJ]:nQUANTITY
				nQuJE		:= HttpSession->PWSF074RESULTPEDCOM[1][nJ]:nQuantityDelivered
				nQtdACla	:= HttpSession->PWSF074RESULTPEDCOM[1][nJ]:nQuantityToClassify
				nPrun		:= HttpSession->PWSF074RESULTPEDCOM[1][nJ]:nUNITPRICE
				nSaldo		:= ( nQuant - nQuJE - nQtdACla )
				If nSaldo > 0
					aAdd( HttpSession->PWSF074GRAVA[2], MTSUPPLIERINVOICE_INVOICEITEMVIEW():New() )
					nTam := Len( HttpSession->PWSF074GRAVA[2] )

					HttpSession->PWSF074GRAVA[2][nTam]:cDESCRIPTIONPRODUCT	:= HttpSession->PWSF074RESULTPEDCOM[1][nJ]:cDESCRIPTIONPRODUCT
					HttpSession->PWSF074GRAVA[2][nTam]:nDISCOUNTPERCENT		:= HttpSession->PWSF074RESULTPEDCOM[1][nJ]:nDISCOUNTPERCENT
					HttpSession->PWSF074GRAVA[2][nTam]:nDISCOUNTVALUE		:= HttpSession->PWSF074RESULTPEDCOM[1][nJ]:nDISCOUNTVALUE
					HttpSession->PWSF074GRAVA[2][nTam]:nEXPENSESVALUE		:= HttpSession->PWSF074RESULTPEDCOM[1][nJ]:nEXPENSESVALUE
					HttpSession->PWSF074GRAVA[2][nTam]:nFREIGHTVALUE		:= HttpSession->PWSF074RESULTPEDCOM[1][nJ]:nFREIGHTVALUE
					HttpSession->PWSF074GRAVA[2][nTam]:nINSURANCEVALUE		:= HttpSession->PWSF074RESULTPEDCOM[1][nJ]:nINSURANCEVALUE
					HttpSession->PWSF074GRAVA[2][nTam]:cMEASUREUNIT			:= HttpSession->PWSF074RESULTPEDCOM[1][nJ]:cMEASUREUNIT
					HttpSession->PWSF074GRAVA[2][nTam]:cPRODUCTCODE			:= HttpSession->PWSF074RESULTPEDCOM[1][nJ]:cPRODUCTCODE
					HttpSession->PWSF074GRAVA[2][nTam]:oWSPURCHASEORDER		:= HttpSession->PWSF074RESULTPEDCOM[1][nJ]
					HttpSession->PWSF074GRAVA[2][nTam]:nQUANTITY			:= nSaldo
					HttpSession->PWSF074GRAVA[2][nTam]:nTOTALVALUE			:= nSaldo * nPrUn
					HttpSession->PWSF074GRAVA[2][nTam]:nUNITPRICE			:= HttpSession->PWSF074RESULTPEDCOM[1][nJ]:nUNITPRICE
				EndIf
			Next nJ
		Else
			Return PWSHtmlAlert( "", STR0012, "", "W_PWSF073.APW" ) //"Atencao"##
		EndIf
	Next nI
EndIf
 
If HttpPost->cAcao == "A"
    HttpSession->PWSF074APH 	:= { STR0013+STR0001, "" } //"Alteracao "
    HttpPost->cAcao 			:= "I"
	lAlt						:= .T.
	HttpSession->nTotalDoc 		:= 0
	HttpSession->nTotalSeg 		:= 0
	HttpSession->nTotalDes 		:= 0
	HttpSession->nTotalFre 		:= 0
	
	oObj:cUSERCODE				:= GetUsrCode()
	oObj:cINVOICETYPE			:= HttpSession->PWSF072RESULT[1][Val( HttpPost->cDocumento )]:cINVOICETYPE
	oObj:cSERIALNUMBER			:= HttpSession->PWSF072RESULT[1][Val( HttpPost->cDocumento )]:cSERIALNUMBER
	oObj:cINVOICENUMBER			:= HttpSession->PWSF072RESULT[1][Val( HttpPost->cDocumento )]:cINVOICENUMBER
	oObj:cDOCUMENTTYPE			:= HttpSession->PWSF072RESULT[1][Val( HttpPost->cDocumento )]:cDOCUMENTTYPE
	oObj:nCUSTOMERORSUPPLIER	:= 2
	oObj:cCUSTOMERORSUPPLIERID	:= HttpSession->CODFORERP	
	//cUSERCODE,cINVOICETYPE,cSERIALNUMBER,cINVOICENUMBER,cDOCUMENTTYPE,nCUSTOMERORSUPPLIER,cCUSTOMERORSUPPLIERID,cQUERYADDWHERENFE,cQUERYADDWHERENFS
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Metodo GETINVOICE               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If oObj:GETINVOICE()
		HttpSession->PWSF074GRAVA 		:= { , { } }
		HttpSession->PWSF074GRAVA[1] 	:= oObj:oWSGETINVOICERESULT:oWSINVOICEHEADER
		nTam 							:= Len( oObj:oWSGETINVOICERESULT:oWSINVOICEITEM:oWSINVOICEITEMVIEW )
		
		For nI := 1 To nTam
			aAdd( HttpSession->PWSF074GRAVA[2], MTSUPPLIERINVOICE_INVOICEITEMVIEW():New() )

			HttpSession->PWSF074GRAVA[2][nI] 	:= oObj:oWSGETINVOICERESULT:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nI]
		
			HttpSession->nTotalDoc 	:= HttpSession->PWSF074GRAVA[2][nI]:nTOTALVALUE
			HttpSession->nTotalSeg 	:= HttpSession->PWSF074GRAVA[2][nI]:nINSURANCEVALUE
			HttpSession->nTotalDes 	:= HttpSession->PWSF074GRAVA[2][nI]:nEXPENSESVALUE
			HttpSession->nTotalFre 	:= HttpSession->PWSF074GRAVA[2][nI]:nFREIGHTVALUE
		Next nI
	Else
		Return PWSHTMLALERT( "", STR0006, "", "W_PWSF070.APW" ) //"Erro"
	EndIf
Else
	If Empty( HttpSession->PWSF074GRAVA )
		HttpSession->nTotalDoc 		:= 0
		HttpSession->nTotalSeg 		:= 0
		HttpSession->nTotalDes 		:= 0
		HttpSession->nTotalFre 		:= 0
		oObj 						:= MTSUPPLIERINVOICE_INVOICEHEADERVIEW():New()
		oObj:dREGISTERDATE 			:= Date()
		oObj:dINVOICEDATE 			:= Date()
		oObj:dDELIVERYDATE 			:= Date()
		HttpSession->PWSF074GRAVA 	:= { oObj, { MTSUPPLIERINVOICE_INVOICEITEMVIEW():New() } }
	EndIf
EndIf

//If HttpSession->PWSF074GRAVA[1]:cDOCUMENTTYPE == NIL .OR. Empty(HttpSession->PWSF074GRAVA[1]:cDOCUMENTTYPE)
//	HttpSession->PWSF074GRAVA[1]:cDOCUMENTTYPE	:= "N"
//EndIf
HttpSession->PWSF074GRAVA[1]:cINVOICETYPE	:= "N"

If HttpPost->cAcao == "I" .AND. Empty( HttpSession->cAcao )
	HttpSession->cAcao := "I"
EndIf

If HttpSession->cAcao == "I"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³   - C A B E C A L H O -   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    aWebCols := { }
	If ExistBlock( "PEF074" )
		aWebCols := ExecBlock( "PEF074", .F., .F., { 1 } )		
	Else
		If lAlt
			aAdd( aWebCols, { "INVOICENUMBER", "D" } )
			aAdd( aWebCols, { "SERIALNUMBER",  "D" } )
			aAdd( aWebCols, { "DOCUMENTTYPE", "D" } )
			aAdd( aWebCols, { "INVOICETYPE", "D" } )
			aAdd( aWebCols, "REGISTERDATE" )
			aAdd( aWebCols, "INVOICEDATE" )
			aAdd( aWebCols, "DELIVERYDATE" )
		Else
			aAdd( aWebCols, "INVOICENUMBER" )
			aAdd( aWebCols, "SERIALNUMBER" )
			aAdd( aWebCols, { "DOCUMENTTYPE",  "D" } )
			aAdd( aWebCols, { "INVOICETYPE",   "D" } )
			aAdd( aWebCols, "REGISTERDATE" )
			aAdd( aWebCols, "INVOICEDATE" )
			aAdd( aWebCols, "DELIVERYDATE" )
		EndIf
	EndIf
	
	GridLinesEx( { HttpSession->PWSF074INFO[1], ;
					HttpSession->PWSF072HEADER[1][1], ;
					HttpSession->PWSF074GRAVA[1], ;
					aWebCols, .T., "H",, 1 }, "MTSUPPLIERINVOICE", "SD1" )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³   -     I T E N S     -   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aWebCols := { }
	If ExistBlock( "PEF074" )
		aWebCols := ExecBlock( "PEF074", .F., .F., { 4 } )
	Else
		aAdd( aWebCols, { "PRODUCTCODE",		"N", { "GETCATALOG", ;
														{ "CPRODUCTCODE", "CPRODUCTCODE" } ;
													}, ;
													{ "CPRODUCTCODE", "CDESCRIPTION" }, 13 } )
		aAdd( aWebCols, { "DESCRIPTIONPRODUCT",	"N", 0, .F. } )
		aAdd( aWebCols, { "MEASUREUNIT",		"N", 0, .F. } )
		aAdd( aWebCols, { "QUANTITY",			"N", 3 } )
		aAdd( aWebCols, { "UNITPRICE",			"N", 9, .T. } )
		aAdd( aWebCols, { "DISCOUNTPERCENT",	"N", 3, .F. } )
		aAdd( aWebCols, { "TOTALVALUE",			"N", 0, .T. } )
	EndIf
	
	GridHeader(		HttpSession->PWSF074INFO[2], ;
					HttpSession->PWSF072HEADER[2][1], ;
					aWebCols )
	
	For nI := 1 To Len( HttpSession->PWSF074GRAVA[2] )
		GridLinesEx( { 	HttpSession->PWSF074INFO[2], ;
						HttpSession->PWSF072HEADER[2][1], ;
						HttpSession->PWSF074GRAVA[2][nI], ;
						aWebCols, .T., "H", AllTrim( Str( nI ) ), ;
						2, .T. }, "MTSUPPLIERINVOICE", "SF1" )
	Next nI

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³   -    T O T A I S    -   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aWebCols := { }

	If ExistBlock( "PEF074" )
		aWebCols := ExecBlock( "PEF074", .F., .F., { 5 } )
	Else
		aAdd( aWebCols, "TOTALVALUE" )
		aAdd( aWebCols, "INSURANCEVALUE" )
		aAdd( aWebCols, "EXPENSESVALUE" )
		aAdd( aWebCols, "FREIGHTVALUE" )
	EndIf

	GridLinesEx( { HttpSession->PWSF074INFO[3], ;
					HttpSession->PWSF072HEADER[1][1], ;
					HttpSession->PWSF074GRAVA[1], ;
					aWebCols, .F., "H",, 3 } )
EndIf

cHtml += ExecInPage( "PWSF074" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSF075   ºAutor  ³ Flavio Luiz Vicco   º Data ³  28/09/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina para inclusao, exclusao e alterado dos itens dos     º±±
±±º          ³ Documentos de Entrega.                                      º±±
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
Web Function PWSF075()

Local cHtml	:= ""
Local nI	:= 0
Local nTam	:= 0

WEB EXTENDED INIT cHtml START "InSite"

PWSSetObjToPost( HttpSession->PWSF074GRAVA[1], HttpSession->PWSF072HEADER[1][1], HttpPost->aPost )

nTam := Len( HttpSession->PWSF074GRAVA[2] )

For nI := 1 To nTam
	PWSSetObjToPost( HttpSession->PWSF074GRAVA[2][nI], HttpSession->PWSF072HEADER[2][1], HttpPost->aPost, AllTrim( Str( nI ) ) )
Next nI

If !Empty( HttpPost->cItem )
	If Len( HttpSession->PWSF074GRAVA[2] ) > 1
		aDel( HttpSession->PWSF074GRAVA[2], Val( HttpPost->cItem ) )
		aSize( HttpSession->PWSF074GRAVA[2], Len( HttpSession->PWSF074GRAVA[2] ) - 1 )
	EndIf
Else
	aAdd( HttpSession->PWSF074GRAVA[2], MTSUPPLIERINVOICE_INVOICEITEMVIEW():New() )
	nTam := Len( HttpSession->PWSF074GRAVA[2] )
	
	If Empty( HttpSession->PWSF074GRAVA[2][nTam]:cSEQUENTIALID )
		HttpSession->PWSF074GRAVA[2][nTam]:cSEQUENTIALID := StrZero( nTam, 4 )
	EndIf
EndIf

cHtml += W_PWSF074()

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSF076   ºAutor  ³ Flavio Luiz Vicco   º Data ³  28/09/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina para simulacao dos Documentos de Entrega.            º±±
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
Web Function PWSF076()

Local cHtml	:= ""
Local nI	:= 0
Local nJ	:= 0
Local nPos	:= 0
Local nTam	:= 0

Local oObj
Local oObjFor
Local oObjCfg

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o WS - MTSIMULATIONQUOTE ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj 	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTSIMULATIONSUPPLIERINVOICE"), WSMTSIMULATIONSUPPLIERINVOICE():New())
WsChgURL( @oObj, "MTSIMULATIONSUPPLIERINVOICE.APW" )

oObjCfg := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
WsChgURL( @oObjCfg, "CFGDICTIONARY.APW" )

aProp 	:= ClassDataArr( HttpSession->PWSF074GRAVA[1] )
nPos 	:= aScan( aProp, { |x| x[1] == "OWSUSERFIELDS" } )

oObjCfg:cUSERCODE 	:= GetUsrCode()
oObjCfg:cALIAS		:= "SD1"

//cUSERCODE,cALIAS
If oObjCfg:GETUSERFIELD()
	aProp[nPos][2] := MTSIMULATIONSUPPLIERINVOICE_ARRAYOFUSERFIELD():New()
	
	For nJ := 1 To Len( oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD )
		aAdd( aProp[nPos][2]:oWSUSERFIELD, MTSIMULATIONSUPPLIERINVOICE_USERFIELD():New() )
		
		aProp[nPos][2]:oWSUSERFIELD[nJ]:nUSERDEC		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:nUSERDEC
		aProp[nPos][2]:oWSUSERFIELD[nJ]:cUSERNAME		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:cUSERNAME
		aProp[nPos][2]:oWSUSERFIELD[nJ]:lUSEROBLIG		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:lUSEROBLIG
		aProp[nPos][2]:oWSUSERFIELD[nJ]:cUSERPICTURE	:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:cUSERPICTURE
		aProp[nPos][2]:oWSUSERFIELD[nJ]:nUSERSIZE		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:nUSERSIZE
		aProp[nPos][2]:oWSUSERFIELD[nJ]:cUSERTAG		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:cUSERTAG
		aProp[nPos][2]:oWSUSERFIELD[nJ]:cUSERTITLE		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:cUSERTITLE
		aProp[nPos][2]:oWSUSERFIELD[nJ]:cUSERTYPE		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:cUSERTYPE
		aProp[nPos][2]:oWSUSERFIELD[nJ]:cUSERCOMBOBOX	:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:cUSERCOMBOBOX
	Next nJ
Else
	conout( GetWsCError( 3 ) )
EndIf

PWSSetObjToPost( HttpSession->PWSF074GRAVA[1], HttpSession->PWSF072HEADER[1][1], HttpPost->aPost )

nTam := Len( HttpSession->PWSF074GRAVA[2] )
For nI := 1 To nTam
	If Empty( HttpSession->PWSF074GRAVA[2][nI]:cSEQUENTIALID )
		HttpSession->PWSF074GRAVA[2][nI]:cSEQUENTIALID := StrZero( nI, 4 )
	EndIf
Next nI

For nI := 1 To nTam
	aProp 	:= ClassDataArr( HttpSession->PWSF074GRAVA[2][nI] )
	nPos 	:= aScan( aProp, { |x| x[1] == "OWSUSERFIELDS" } )

	oObjCfg:cUSERCODE 	:= GetUsrCode()
	oObjCfg:cALIAS		:= "SF1"
	
	//cUSERCODE,cALIAS
	If oObjCfg:GETUSERFIELD()
		aProp[nPos][2] := MTSIMULATIONSUPPLIERINVOICE_ARRAYOFUSERFIELD():New()
		
		For nJ := 1 To Len( oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD )
			aAdd( aProp[nPos][2]:oWSUSERFIELD, MTSIMULATIONSUPPLIERINVOICE_USERFIELD():New() )
			
			aProp[nPos][2]:oWSUSERFIELD[nJ]:nUSERDEC		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:nUSERDEC
			aProp[nPos][2]:oWSUSERFIELD[nJ]:cUSERNAME		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:cUSERNAME
			aProp[nPos][2]:oWSUSERFIELD[nJ]:lUSEROBLIG		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:lUSEROBLIG
			aProp[nPos][2]:oWSUSERFIELD[nJ]:cUSERPICTURE	:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:cUSERPICTURE
			aProp[nPos][2]:oWSUSERFIELD[nJ]:nUSERSIZE		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:nUSERSIZE
			aProp[nPos][2]:oWSUSERFIELD[nJ]:cUSERTAG		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:cUSERTAG
			aProp[nPos][2]:oWSUSERFIELD[nJ]:cUSERTITLE		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:cUSERTITLE
			aProp[nPos][2]:oWSUSERFIELD[nJ]:cUSERTYPE		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:cUSERTYPE
			aProp[nPos][2]:oWSUSERFIELD[nJ]:cUSERCOMBOBOX	:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:cUSERCOMBOBOX
		Next nJ
	Else
		conout( GetWsCError( 3 ) )
	EndIf

	PWSSetObjToPost( HttpSession->PWSF074GRAVA[2][nI], HttpSession->PWSF072HEADER[2][1], HttpPost->aPost, AllTrim( Str( nI ) ) )
Next nI

oObj:cUSERCODE				:= GetUsrCode()
oObj:nCUSTOMERORSUPPLIER	:= 2
oObj:cCUSTOMERORSUPPLIERID	:= HttpSession->CODFORERP

oObj:oWSOLDINVOICE := MTSIMULATIONSUPPLIERINVOICE_INVOICEVIEW():New()
oObj:oWSOLDINVOICE:oWSINVOICEHEADER := MTSIMULATIONSUPPLIERINVOICE_INVOICEHEADERVIEW():New()

nPos := aScan( HttpSession->PWSF020FOR , {|x| x[FORNECERP_CODIGO] == HttpSession->CODFORERP } )
oObjFor := MTSUPPLIERINVOICE_GENERICSTRUCT():New()
oObjFor:cCODE		 := HttpSession->CODFORERP
oObjFor:cDESCRIPTION := HttpSession->PWSF020FOR[nPos][FORNECERP_RAZAOSOC]

oObj:oWSOLDINVOICE:oWSINVOICEHEADER:oWSFROMROLE	 	:= oObjFor
oObj:oWSOLDINVOICE:oWSINVOICEHEADER:dDELIVERYDATE	:= HttpSession->PWSF074GRAVA[1]:dDELIVERYDATE
oObj:oWSOLDINVOICE:oWSINVOICEHEADER:cDOCUMENTTYPE	:= HttpSession->PWSF074GRAVA[1]:cDOCUMENTTYPE
oObj:oWSOLDINVOICE:oWSINVOICEHEADER:nEXPENSESVALUE	:= HttpSession->PWSF074GRAVA[1]:nEXPENSESVALUE
oObj:oWSOLDINVOICE:oWSINVOICEHEADER:nFREIGHTVALUE	:= HttpSession->PWSF074GRAVA[1]:nFREIGHTVALUE
oObj:oWSOLDINVOICE:oWSINVOICEHEADER:nINSURANCEVALUE	:= HttpSession->PWSF074GRAVA[1]:nINSURANCEVALUE
oObj:oWSOLDINVOICE:oWSINVOICEHEADER:dINVOICEDATE	:= HttpSession->PWSF074GRAVA[1]:dINVOICEDATE
oObj:oWSOLDINVOICE:oWSINVOICEHEADER:cINVOICENUMBER	:= HttpSession->PWSF074GRAVA[1]:cINVOICENUMBER
oObj:oWSOLDINVOICE:oWSINVOICEHEADER:cINVOICETYPE	:= HttpSession->PWSF074GRAVA[1]:cINVOICETYPE
oObj:oWSOLDINVOICE:oWSINVOICEHEADER:dREGISTERDATE	:= HttpSession->PWSF074GRAVA[1]:dREGISTERDATE
oObj:oWSOLDINVOICE:oWSINVOICEHEADER:cSERIALNUMBER	:= HttpSession->PWSF074GRAVA[1]:cSERIALNUMBER
oObj:oWSOLDINVOICE:oWSINVOICEHEADER:nTOTALVALUE		:= HttpSession->PWSF074GRAVA[1]:nTOTALVALUE

oObj:oWSOLDINVOICE:oWSINVOICEITEM := MTSIMULATIONSUPPLIERINVOICE_ARRAYOFINVOICEITEMVIEW():New()

nTam := Len( HttpSession->PWSF074GRAVA[2] )
For nI := 1 To nTam
	aAdd( oObj:oWSOLDINVOICE:oWSINVOICEITEM:oWSINVOICEITEMVIEW, MTSIMULATIONSUPPLIERINVOICE_INVOICEITEMVIEW():New() )

	oObj:oWSOLDINVOICE:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nI]:cDESCRIPTIONPRODUCT		:= HttpSession->PWSF074GRAVA[2][nI]:cDESCRIPTIONPRODUCT
	oObj:oWSOLDINVOICE:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nI]:nDISCOUNTPERCENT			:= HttpSession->PWSF074GRAVA[2][nI]:nDISCOUNTPERCENT
	oObj:oWSOLDINVOICE:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nI]:nDISCOUNTVALUE				:= HttpSession->PWSF074GRAVA[2][nI]:nDISCOUNTVALUE
	oObj:oWSOLDINVOICE:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nI]:nEXPENSESVALUE				:= HttpSession->PWSF074GRAVA[2][nI]:nEXPENSESVALUE
	oObj:oWSOLDINVOICE:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nI]:nFREIGHTVALUE				:= HttpSession->PWSF074GRAVA[2][nI]:nFREIGHTVALUE
	oObj:oWSOLDINVOICE:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nI]:nINSURANCEVALUE			:= HttpSession->PWSF074GRAVA[2][nI]:nINSURANCEVALUE
	oObj:oWSOLDINVOICE:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nI]:oWSLOTIDENTIFIER			:= HttpSession->PWSF074GRAVA[2][nI]:oWSLOTIDENTIFIER
	oObj:oWSOLDINVOICE:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nI]:cMEASUREUNIT				:= HttpSession->PWSF074GRAVA[2][nI]:cMEASUREUNIT
	oObj:oWSOLDINVOICE:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nI]:cPRODUCTCODE				:= HttpSession->PWSF074GRAVA[2][nI]:cPRODUCTCODE
	oObj:oWSOLDINVOICE:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nI]:cQUALITYCONTROLDOCUMENT	:= HttpSession->PWSF074GRAVA[2][nI]:cQUALITYCONTROLDOCUMENT
	oObj:oWSOLDINVOICE:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nI]:nQUANTITY					:= HttpSession->PWSF074GRAVA[2][nI]:nQUANTITY
	oObj:oWSOLDINVOICE:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nI]:cSEQUENTIALID				:= Soma1( StrZero( nI - 1, 4 ), 2 )
	oObj:oWSOLDINVOICE:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nI]:nTOTALVALUE				:= HttpSession->PWSF074GRAVA[2][nI]:nTOTALVALUE
	oObj:oWSOLDINVOICE:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nI]:nUNITPRICE					:= HttpSession->PWSF074GRAVA[2][nI]:nUNITPRICE
	
	If HttpSession->PWSF074GRAVA[2][nI]:oWSPURCHASEORDER != NIL
		oObj:oWSOLDINVOICE:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nI]:oWSPURCHASEORDER 			:= MTSIMULATIONSUPPLIERINVOICE_PURCHASEORDERITEMVIEW():New()
		
		oObj:oWSOLDINVOICE:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nI]:oWSPURCHASEORDER:dDELIVERYDATE		:= HttpSession->PWSF074GRAVA[2][nI]:oWSPURCHASEORDER:dDELIVERYDATE
		oObj:oWSOLDINVOICE:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nI]:oWSPURCHASEORDER:cDESCRIPTIONPRODUCT	:= HttpSession->PWSF074GRAVA[2][nI]:oWSPURCHASEORDER:cDESCRIPTIONPRODUCT
		oObj:oWSOLDINVOICE:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nI]:oWSPURCHASEORDER:nDISCOUNTPERCENT		:= HttpSession->PWSF074GRAVA[2][nI]:oWSPURCHASEORDER:nDISCOUNTPERCENT
		oObj:oWSOLDINVOICE:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nI]:oWSPURCHASEORDER:nDISCOUNTVALUE		:= HttpSession->PWSF074GRAVA[2][nI]:oWSPURCHASEORDER:nDISCOUNTVALUE
		oObj:oWSOLDINVOICE:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nI]:oWSPURCHASEORDER:nEXPENSESVALUE		:= HttpSession->PWSF074GRAVA[2][nI]:oWSPURCHASEORDER:nEXPENSESVALUE
		oObj:oWSOLDINVOICE:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nI]:oWSPURCHASEORDER:nFREIGHTVALUE		:= HttpSession->PWSF074GRAVA[2][nI]:oWSPURCHASEORDER:nFREIGHTVALUE
		oObj:oWSOLDINVOICE:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nI]:oWSPURCHASEORDER:nINSURANCEVALUE		:= HttpSession->PWSF074GRAVA[2][nI]:oWSPURCHASEORDER:nINSURANCEVALUE
		oObj:oWSOLDINVOICE:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nI]:oWSPURCHASEORDER:cMEASUREUNIT			:= HttpSession->PWSF074GRAVA[2][nI]:oWSPURCHASEORDER:cMEASUREUNIT
		oObj:oWSOLDINVOICE:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nI]:oWSPURCHASEORDER:cNOTES				:= HttpSession->PWSF074GRAVA[2][nI]:oWSPURCHASEORDER:cNOTES
		oObj:oWSOLDINVOICE:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nI]:oWSPURCHASEORDER:cPAYMENTPLANCODE		:= HttpSession->PWSF074GRAVA[2][nI]:oWSPURCHASEORDER:cPAYMENTPLANCODE
		oObj:oWSOLDINVOICE:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nI]:oWSPURCHASEORDER:cPRODUCTCODE			:= HttpSession->PWSF074GRAVA[2][nI]:oWSPURCHASEORDER:cPRODUCTCODE
		oObj:oWSOLDINVOICE:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nI]:oWSPURCHASEORDER:cPURCHASEORDERID		:= HttpSession->PWSF074GRAVA[2][nI]:oWSPURCHASEORDER:cPURCHASEORDERID
		oObj:oWSOLDINVOICE:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nI]:oWSPURCHASEORDER:nQUANTITY			:= HttpSession->PWSF074GRAVA[2][nI]:oWSPURCHASEORDER:nQUANTITY
		oObj:oWSOLDINVOICE:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nI]:oWSPURCHASEORDER:nQUANTITYDELIVERED	:= HttpSession->PWSF074GRAVA[2][nI]:oWSPURCHASEORDER:nQUANTITYDELIVERED
		oObj:oWSOLDINVOICE:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nI]:oWSPURCHASEORDER:cQUOTEID				:= HttpSession->PWSF074GRAVA[2][nI]:oWSPURCHASEORDER:cQUOTEID
		oObj:oWSOLDINVOICE:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nI]:oWSPURCHASEORDER:cSEQUENTIALID		:= HttpSession->PWSF074GRAVA[2][nI]:oWSPURCHASEORDER:cSEQUENTIALID
		oObj:oWSOLDINVOICE:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nI]:oWSPURCHASEORDER:nTOTALVALUE			:= HttpSession->PWSF074GRAVA[2][nI]:oWSPURCHASEORDER:nTOTALVALUE
		oObj:oWSOLDINVOICE:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nI]:oWSPURCHASEORDER:nUNITPRICE			:= HttpSession->PWSF074GRAVA[2][nI]:oWSPURCHASEORDER:nUNITPRICE
	Endif
Next nI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Metodo PUTINVOICE               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//cUSERCODE,nCUSTOMERORSUPPLIER,cCUSTOMERORSUPPLIERID,oWSOLDINVOICE
If oObj:PUTINVOICE()
	HttpSession->PWSF074GRAVA[1] := oObj:oWSPUTINVOICERESULT:oWSINVOICEHEADER
	HttpSession->PWSF074GRAVA[2] := { }

	For nI := 1 To Len( oObj:oWSPUTINVOICERESULT:oWSINVOICEITEM:oWSINVOICEITEMVIEW )
		aAdd( HttpSession->PWSF074GRAVA[2], MTSIMULATIONSUPPLIERINVOICE_INVOICEITEMVIEW():New() )
		HttpSession->PWSF074GRAVA[2][nI] := oObj:oWSPUTINVOICERESULT:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nI]
	Next nI

	HttpSession->nTotalDoc 	:= oObj:oWSPUTINVOICERESULT:oWSINVOICEHEADER:nTOTALVALUE
	HttpSession->nTotalSeg 	:= oObj:oWSPUTINVOICERESULT:oWSINVOICEHEADER:nINSURANCEVALUE
	HttpSession->nTotalDes 	:= oObj:oWSPUTINVOICERESULT:oWSINVOICEHEADER:nEXPENSESVALUE
	HttpSession->nTotalFre 	:= oObj:oWSPUTINVOICERESULT:oWSINVOICEHEADER:nFREIGHTVALUE
Else
	Return PWSHTMLALERT( "", STR0006, "", "W_PWSF074.APW" ) //"Erro"
EndIf

cHtml += W_PWSF074()

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSF077   ºAutor  ³ Flavio Luiz Vicco   º Data ³  28/09/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina para inclusao, exclusao e alterado do Docto.Entrega. º±±
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
Web Function PWSF077()

Local cHtml 	:= ""
Local nI		:= 0
Local nJ		:= 0
Local nPos		:= 0
Local nTam		:= 0

Local oObj
Local oObjFor
Local oObjCfg

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o WS - WSMTSUPPLIERINVOICE ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj 	:= Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTSUPPLIERINVOICE"), WSMTSUPPLIERINVOICE():New())
WsChgURL( @oObj, "MTSUPPLIERINVOICE.APW" )

oObjCfg := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New())
WsChgURL( @oObjCfg, "CFGDICTIONARY.APW" )

aProp 	:= ClassDataArr( HttpSession->PWSF074GRAVA[1] )
nPos 	:= aScan( aProp, { |x| x[1] == "OWSUSERFIELDS" } )

oObjCfg:cUSERCODE 	:= GetUsrCode()
oObjCfg:cALIAS		:= "SD1"

//cUSERCODE,cALIAS
If oObjCfg:GETUSERFIELD()
	aProp[nPos][2] := MTSUPPLIERINVOICE_ARRAYOFUSERFIELD():New()

	For nJ := 1 To Len( oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD )
		aAdd( aProp[nPos][2]:oWSUSERFIELD, MTSUPPLIERINVOICE_USERFIELD():New() )

		aProp[nPos][2]:oWSUSERFIELD[nJ]:nUSERDEC		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:nUSERDEC
		aProp[nPos][2]:oWSUSERFIELD[nJ]:cUSERNAME		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:cUSERNAME
		aProp[nPos][2]:oWSUSERFIELD[nJ]:lUSEROBLIG		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:lUSEROBLIG
		aProp[nPos][2]:oWSUSERFIELD[nJ]:cUSERPICTURE	:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:cUSERPICTURE
		aProp[nPos][2]:oWSUSERFIELD[nJ]:nUSERSIZE		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:nUSERSIZE
		aProp[nPos][2]:oWSUSERFIELD[nJ]:cUSERTAG		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:cUSERTAG
		aProp[nPos][2]:oWSUSERFIELD[nJ]:cUSERTITLE		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:cUSERTITLE
		aProp[nPos][2]:oWSUSERFIELD[nJ]:cUSERTYPE		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:cUSERTYPE
		aProp[nPos][2]:oWSUSERFIELD[nJ]:cUSERCOMBOBOX	:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:cUSERCOMBOBOX
	Next nJ
Else
	conout( GetWsCError( 3 ) )
EndIf

PWSSetObjToPost( HttpSession->PWSF074GRAVA[1], HttpSession->PWSF072HEADER[1][1], HttpPost->aPost )

nTam := Len( HttpSession->PWSF074GRAVA[2] )
For nI := 1 To nTam
	If Empty( HttpSession->PWSF074GRAVA[2][nI]:cSEQUENTIALID )
		HttpSession->PWSF074GRAVA[2][nI]:cSEQUENTIALID := StrZero( nI, 4 )
	EndIf
Next nI

For nI := 1 To nTam
	aProp 	:= ClassDataArr( HttpSession->PWSF074GRAVA[2][nI] )
	nPos 	:= aScan( aProp, { |x| x[1] == "OWSUSERFIELDS" } )

	oObjCfg:cUSERCODE 	:= GetUsrCode()
	oObjCfg:cALIAS		:= "SF1"
	
	//cUSERCODE,cALIAS
	If oObjCfg:GETUSERFIELD()
		aProp[nPos][2] := MTSUPPLIERINVOICE_ARRAYOFUSERFIELD():New()
		
		For nJ := 1 To Len( oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD )
			aAdd( aProp[nPos][2]:oWSUSERFIELD, MTSUPPLIERINVOICE_USERFIELD():New() )
			
			aProp[nPos][2]:oWSUSERFIELD[nJ]:nUSERDEC		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:nUSERDEC
			aProp[nPos][2]:oWSUSERFIELD[nJ]:cUSERNAME		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:cUSERNAME
			aProp[nPos][2]:oWSUSERFIELD[nJ]:lUSEROBLIG		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:lUSEROBLIG
			aProp[nPos][2]:oWSUSERFIELD[nJ]:cUSERPICTURE	:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:cUSERPICTURE
			aProp[nPos][2]:oWSUSERFIELD[nJ]:nUSERSIZE		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:nUSERSIZE
			aProp[nPos][2]:oWSUSERFIELD[nJ]:cUSERTAG		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:cUSERTAG
			aProp[nPos][2]:oWSUSERFIELD[nJ]:cUSERTITLE		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:cUSERTITLE
			aProp[nPos][2]:oWSUSERFIELD[nJ]:cUSERTYPE		:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:cUSERTYPE
			aProp[nPos][2]:oWSUSERFIELD[nJ]:cUSERCOMBOBOX	:= oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:cUSERCOMBOBOX
		Next nJ
	Else
		conout( GetWsCError( 3 ) )
	EndIf

	PWSSetObjToPost( HttpSession->PWSF074GRAVA[2][nI], HttpSession->PWSF072HEADER[2][1], HttpPost->aPost, AllTrim( Str( nI ) ) )
Next nI

oObj:cUSERCODE				:= GetUsrCode()
oObj:nCUSTOMERORSUPPLIER	:= 2
oObj:cCUSTOMERORSUPPLIERID	:= HttpSession->CODFORERP

oObj:oWSINVOICE := MTSUPPLIERINVOICE_INVOICEVIEW():New()
oObj:oWSINVOICE:oWSINVOICEHEADER := MTSUPPLIERINVOICE_INVOICEHEADERVIEW():New()

nPos := aScan( HttpSession->PWSF020FOR , {|x| x[FORNECERP_CODIGO] == HttpSession->CODFORERP } )
oObjFor := MTSUPPLIERINVOICE_GENERICSTRUCT():New()
oObjFor:cCODE		 := HttpSession->CODFORERP
oObjFor:cDESCRIPTION := HttpSession->PWSF020FOR[nPos][FORNECERP_RAZAOSOC]

oObj:oWSINVOICE:oWSINVOICEHEADER:oWSFROMROLE	 	:= oObjFor
oObj:oWSINVOICE:oWSINVOICEHEADER:dDELIVERYDATE		:= HttpSession->PWSF074GRAVA[1]:dDELIVERYDATE
oObj:oWSINVOICE:oWSINVOICEHEADER:cDOCUMENTTYPE		:= HttpSession->PWSF074GRAVA[1]:cDOCUMENTTYPE
oObj:oWSINVOICE:oWSINVOICEHEADER:nEXPENSESVALUE		:= HttpSession->PWSF074GRAVA[1]:nEXPENSESVALUE
oObj:oWSINVOICE:oWSINVOICEHEADER:nFREIGHTVALUE		:= HttpSession->PWSF074GRAVA[1]:nFREIGHTVALUE
oObj:oWSINVOICE:oWSINVOICEHEADER:nINSURANCEVALUE	:= HttpSession->PWSF074GRAVA[1]:nINSURANCEVALUE
oObj:oWSINVOICE:oWSINVOICEHEADER:dINVOICEDATE		:= HttpSession->PWSF074GRAVA[1]:dINVOICEDATE
oObj:oWSINVOICE:oWSINVOICEHEADER:cINVOICENUMBER		:= HttpSession->PWSF074GRAVA[1]:cINVOICENUMBER
oObj:oWSINVOICE:oWSINVOICEHEADER:cINVOICETYPE		:= HttpSession->PWSF074GRAVA[1]:cINVOICETYPE
oObj:oWSINVOICE:oWSINVOICEHEADER:dREGISTERDATE		:= HttpSession->PWSF074GRAVA[1]:dREGISTERDATE
oObj:oWSINVOICE:oWSINVOICEHEADER:cSERIALNUMBER		:= HttpSession->PWSF074GRAVA[1]:cSERIALNUMBER
oObj:oWSINVOICE:oWSINVOICEHEADER:nTOTALVALUE		:= HttpSession->PWSF074GRAVA[1]:nTOTALVALUE

oObj:oWSINVOICE:oWSINVOICEITEM := MTSUPPLIERINVOICE_ARRAYOFINVOICEITEMVIEW():New()

nTam := Len( HttpSession->PWSF074GRAVA[2] )
For nI := 1 To nTam
	aAdd( oObj:oWSINVOICE:oWSINVOICEITEM:oWSINVOICEITEMVIEW, MTSUPPLIERINVOICE_INVOICEITEMVIEW():New() )

	oObj:oWSINVOICE:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nI]:cDESCRIPTIONPRODUCT		:= HttpSession->PWSF074GRAVA[2][nI]:cDESCRIPTIONPRODUCT
	oObj:oWSINVOICE:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nI]:nDISCOUNTPERCENT			:= HttpSession->PWSF074GRAVA[2][nI]:nDISCOUNTPERCENT
	oObj:oWSINVOICE:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nI]:nDISCOUNTVALUE			:= HttpSession->PWSF074GRAVA[2][nI]:nDISCOUNTVALUE
	oObj:oWSINVOICE:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nI]:nEXPENSESVALUE			:= HttpSession->PWSF074GRAVA[2][nI]:nEXPENSESVALUE
	oObj:oWSINVOICE:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nI]:nFREIGHTVALUE				:= HttpSession->PWSF074GRAVA[2][nI]:nFREIGHTVALUE
	oObj:oWSINVOICE:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nI]:nINSURANCEVALUE			:= HttpSession->PWSF074GRAVA[2][nI]:nINSURANCEVALUE
	oObj:oWSINVOICE:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nI]:oWSLOTIDENTIFIER			:= HttpSession->PWSF074GRAVA[2][nI]:oWSLOTIDENTIFIER
	oObj:oWSINVOICE:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nI]:cMEASUREUNIT				:= HttpSession->PWSF074GRAVA[2][nI]:cMEASUREUNIT
	oObj:oWSINVOICE:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nI]:cPRODUCTCODE				:= HttpSession->PWSF074GRAVA[2][nI]:cPRODUCTCODE
	oObj:oWSINVOICE:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nI]:cQUALITYCONTROLDOCUMENT	:= HttpSession->PWSF074GRAVA[2][nI]:cQUALITYCONTROLDOCUMENT
	oObj:oWSINVOICE:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nI]:nQUANTITY					:= HttpSession->PWSF074GRAVA[2][nI]:nQUANTITY
	oObj:oWSINVOICE:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nI]:cSEQUENTIALID				:= Soma1( StrZero( nI - 1, 4 ), 2 )
	oObj:oWSINVOICE:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nI]:nTOTALVALUE				:= HttpSession->PWSF074GRAVA[2][nI]:nTOTALVALUE
	oObj:oWSINVOICE:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nI]:nUNITPRICE				:= HttpSession->PWSF074GRAVA[2][nI]:nUNITPRICE
    oObj:oWSINVOICE:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nI]:nDISCOUNTVALUE			:= 0
    oObj:oWSINVOICE:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nI]:nEXPENSESVALUE			:= 0
    oObj:oWSINVOICE:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nI]:nINSURANCEVALUE			:= 0
    oObj:oWSINVOICE:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nI]:nFREIGHTVALUE				:= 0
	If HttpSession->PWSF074GRAVA[2][nI]:oWSPURCHASEORDER != NIL
		oObj:oWSINVOICE:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nI]:oWSPURCHASEORDER		:= HttpSession->PWSF074GRAVA[2][nI]:oWSPURCHASEORDER
	EndIf
Next nI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Metodo PUTINVOICE               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//cUSERCODE,nCUSTOMERORSUPPLIER,cCUSTOMERORSUPPLIERID,oWSINVOICE
If oObj:PUTINVOICE()
	Return PWSHTMLALERT( "", STR0012, STR0001+" : " + oObj:cPUTINVOICERESULT + STR0014, "W_PWSF070.APW" )  //"Atencao"##" cadastrado com SUCESSO!"
Else
	Return PWSHTMLALERT( "", STR0012, "", "W_PWSF074.APW" ) //"Atencao"
EndIf

cHtml += W_PWSF074()

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSF078   ºAutor  ³ Flavio Luiz Vicco   º Data ³  28/09/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina de busca de Pedidos de Compra.                       º±±
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
Web Function PWSF078()
Local cHtml 	:= ""
Local aWebCols 	:= {}
Local oObj
Local oObjTotalPO

WEB EXTENDED INIT cHtml START "InSite"

oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTSUPPLIERPURCHASEORDER"), WSMTSUPPLIERPURCHASEORDER():New())
WsChgUrl( @oObj, "MTSUPPLIERPURCHASEORDER.apw" )

oObjTotalPO := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTSUPPLIERPURCHASEORDER"), WSMTSUPPLIERPURCHASEORDER():New())
WsChgUrl( @oObjTotalPO, "MTSUPPLIERPURCHASEORDER.apw" )

HttpSession->PWSF078APH 	:= { STR0001+" - "+STR0015, "W_PWSF074.APW", "W_PWSF074.APW" } //"PEDIDOS DE COMPRA"
HttpSession->PWSF078INFO 	:= {}
HttpSession->PWSF078RESULT 	:= {}
PWSSetObjToPost( HttpSession->PWSF074GRAVA[1], HttpSession->PWSF072HEADER[1][1], HttpPost->aPost )

If Empty( HttpGet->cPagina )
	HttpGet->cPagina := "0"
EndIf

oObj:cUSERCODE 		  	:= GetUsrCode()
oObj:cSUPPLIER		  	:= HttpSession->CODFORERP
oObj:cQUERYADDWHERE	  	:= "(C7_QUANT-C7_QUJE-C7_QTDACLA)>0 "
oObj:dDeliveryDateFrom	:= CToD( HttpSession->dDELIVERYDATEFROM )
oObj:dDeliveryDateTo	:= CToD( HttpSession->dDELIVERYDATETO )
oObj:nPAGELEN			:= 10
oObj:nPAGEFIRST			:= ( Val( HttpGet->cPagina ) * 10 ) + 1

oObjTotalPO:cUSERCODE 			:= GetUsrCode()
oObjTotalPO:cSUPPLIER			:= HttpSession->CODFORERP
oObjTotalPO:cQUERYADDWHERE		:= "(C7_QUANT-C7_QUJE-C7_QTDACLA)>0 "
oObjTotalPO:dDeliveryDateFrom	:= CToD( HttpSession->dDELIVERYDATEFROM )
oObjTotalPO:dDeliveryDateTo		:= CToD( HttpSession->dDELIVERYDATETO )

//cUSERCODE,cSUPPLIER,dDELIVERYDATEFROM,dDELIVERYDATETO,cQUERYADDWHERE,nPAGELEN,nPAGEFIRST
If oObj:BRWPURCHASEORDER()
	//cUSERCODE,cSELLERID,dREGISTERDATEFROM,dREGISTERDATETO,cBIDNUMBERFROM,cBIDNUMBERTO,cQUERYADDWHERE
	If oObjTotalPO:BRWTOTALPURCHASEORDER()
		HttpSession->nTotalPO := oObjTotalPO:nBRWTOTALPURCHASEORDERRESULT
	Else
		Return PWSHTMLALERT( "", STR0006, "", "W_PWSV074.APW" )//"Erro"
	EndIf
	HttpSession->PWSF078RESULT := { oObj:oWSBRWPURCHASEORDERRESULT:oWSPURCHASEORDERHEADERVIEW }

	If ExistBlock( "PEF078" )
		aWebCols := ExecBlock( "PEF078", .F., .F., { } )
	EndIf
	
	GridHeader( HttpSession->PWSF078INFO			,;
				HttpSession->PWSF072HEADER[3][1]	,;
				aWebCols )
	
	GridLinesEx( { 	HttpSession->PWSF078INFO			,;
					HttpSession->PWSF072HEADER[3][1]	,;
					HttpSession->PWSF078RESULT[1]		,;
					aWebCols							,;
					.F.									,;
					"A"									,;
					NIL									,;
					0 } )
Else
	Return PWSHTMLALERT( "", STR0006, "", "W_PWSF074.APW" ) //"Erro"
EndIf

cHtml += ExecInPage( "PWSF078" )

WEB EXTENDED END

Return cHtml
