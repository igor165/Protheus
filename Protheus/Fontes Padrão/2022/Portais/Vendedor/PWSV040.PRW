#INCLUDE "PWSV040.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
#INCLUDE "FWLIBVERSION.CH"

STATIC __lMetric := Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSV04*   บAutor  ณLuiz Felipe Couto    บ Data ณ  21/06/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Este fonte possui as funcionalidades relacionado ao pedido  บฑฑ
ฑฑบ          ณ de venda.                                                   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSV040   บAutor  ณLuiz Felipe Couto    บ Data ณ  21/06/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Mostra os vendedores disponiveis para o usuario logado.     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Web Function PWSV040()

Local cHtml := ""					//Pagina HTML

//Valida a data da LIB para utiliza็ใo na Telemetria
If FatLibMetric()
	//Telemetria - Se utiliza o Portal do Vendedor
	FwCustomMetrics():setUniqueMetric("PWSV040","faturamento-protheus_utilizacao-portal-vendedor_total","1",/*dDateSend*/,/*nLapTime*/,"PWSV040")
EndIf

WEB EXTENDED INIT cHtml START "InSite"

HttpPost->PWSV020VEN := GetUserVen()

HttpSession->PWSV020APH := { 	STR0012			,;			//"Pedidos de Venda"
								"W_PWSV041.APW"	,;			// Proxima Tela
								""	} 						// Msg de Erro
If Len( HttpPost->PWSV020VEN ) <= 1
	HttpSession->PWSV020APH[3] := STR0002 //"Nใo hแ vendedores a consultar."

	cHtml += ExecInPage( "PWSV020" )
ElseIf Len(HttpPost->PWSV020VEN) = 2
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Apenas 1 cliente. Define a navegacao para pular a tela de selecao de cliente ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	HttpPost->CODVENERP	:= HttpPost->PWSV020VEN[2][2]
	HttpSession->PWSV050ACO := "0"
	cHtml += W_PWSV041()
Else
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Mais de 1 cliente: Chama tela de selecao de clientes ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cHtml += ExecInPage( "PWSV020" )
EndIf

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSV041   บAutor  ณLuiz Felipe Couto    บ Data ณ  21/06/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela de apresentacao da busca do pedido.                    บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Web Function PWSV041()

Local cHtml := ""		// Pagina HTML
Local oObj				// Objeto WS - MTSELLERSALESORDER

WEB EXTENDED INIT cHtml START "InSite"

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTSELLERSALESORDER' ), WSMTSELLERSALESORDER():NEW() )
WsChgURL( @oObj, "MTSELLERSALESORDER.APW" )

If !Empty( HttpPost->CODVENERP )
	HttpSession->CODVENERP := HttpPost->CODVENERP
EndIf

If Empty( HttpSession->PWSV042HEADER )
	HttpSession->PWSV042HEADER := { {}, {} }
	
	If oObj:GETHEADER( "SALESORDERHEADERVIEW" )
		HttpSession->PWSV042HEADER[1] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
	Else
		Return PWSHTMLALERT( "", STR0010, "", "W_PWSV040.APW" )//"Erro"
	EndIf

	If oObj:GETHEADER( "SALESORDERITEMVIEW" )
		HttpSession->PWSV042HEADER[2] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
	Else
		Return PWSHTMLALERT( "", STR0010, "", "W_PWSV040.APW" )//"Erro"
	EndIf
EndIf

HttpSession->PWSV044GRAVA 	:= {}
HttpSession->PWSV041APH 	:= { STR0012	,;		//Pedido de Venda
								 "W_PWSV042.APW", "W_PWSV044.APW" }
HttpSession->cItens 		:= "00"

cHtml += ExecInPage( "PWSV041" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSV042   บAutor  ณLuiz Felipe Couto    บ Data ณ  21/06/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela de resultado da busca do pedido.                       บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบTatiana C.ณ118250  ณ 8.11 ณInclusao do campo loja na pesquisa de pedidosบฑฑ
ฑฑบCleber M. ณ118250  ณ 8.11 ณCorrecao da busca por Cliente/loja.          บฑฑ
ฑฑบCleber M. ณ18/07/07ณ129271ณ- Passagem dos parametros Nome do WebService บฑฑ
ฑฑบ          ณ        ณ      ณe Alias na GridHeader e GridLinesEx para     บฑฑ
ฑฑบ          ณ        ณ      ณcontemplar os campos de usuario.			   บฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Web Function PWSV042()

Local cHtml 	:= ""		//Pagina HTML
Local oObj					//Objeto WS - WSMTSELLERSALESORDER
Local oObjTotalSO			//Objeto WS - WSMTSELLERSALESORDER
Local aWebCols 	:= {}		//Array com os campos a serem exibidos

WEB EXTENDED INIT cHtml START "InSite"

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTSELLERSALESORDER' ), WSMTSELLERSALESORDER():NEW() )
oObjTotalSO := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTSELLERSALESORDER' ), WSMTSELLERSALESORDER():NEW() )

WsChgURL( @oObj, "MTSELLERSALESORDER.APW" )
WsChgURL( @oObjTotalSO, "MTSELLERSALESORDER.APW" )

HttpSession->PWSV042APH := { STR0013, "W_PWSV043.APW" }//"Resultado Busca"

If Empty( HttpGet->cPagina )
	HttpGet->cPagina := "0"
EndIf

If ( !Empty( HttpGet->dREGISTERDATEFROM ) 	.AND. !Empty( HttpGet->dREGISTERDATETO ) ) .OR.;
	( !Empty( HttpGet->cBIDNUMBERFROM ) 	.AND. !Empty( HttpGet->cBIDNUMBERTO ) ) .OR.;
	( !Empty( HttpGet->cCUSTOMERUNITTO ) .AND. !Empty( HttpGet->cCUSTOMERTO ) )
	
	HttpPost->dREGISTERDATEFROM 	:= HttpGet->dREGISTERDATEFROM
	HttpPost->dREGISTERDATETO 		:= HttpGet->dREGISTERDATETO
	HttpPost->cBIDNUMBERFROM 		:= HttpGet->cBIDNUMBERFROM
	HttpPost->cBIDNUMBERTO 			:= HttpGet->cBIDNUMBERTO
	HttpPost->cCUSTOMERFROM 		:= HttpGet->cCUSTOMERFROM
	HttpPost->cCUSTOMERTO 			:= HttpGet->cCUSTOMERTO	
	HttpPost->cCUSTOMERUNITFROM 	:= HttpGet->cCUSTOMERUNITFROM
	HttpPost->cCUSTOMERUNITTO 		:= HttpGet->cCUSTOMERUNITTO	
EndIf

oObj:cUSERCODE			:= GetUsrCode()
oObj:cSELLERCODE		:= HttpSession->CODVENERP
oObj:dREGISTERDATEFROM	:= CToD( HttpPost->dREGISTERDATEFROM )
oObj:dREGISTERDATETO	:= CToD( HttpPost->dREGISTERDATETO )
oObj:cBIDNUMBERFROM		:= HttpPost->cBIDNUMBERFROM
oObj:cBIDNUMBERTO		:= HttpPost->cBIDNUMBERTO
oObj:nPAGELEN			:= 10
oObj:nPAGEFIRST			:= ( Val( HttpGet->cPagina ) * 10 ) + 1

oObjTotalSO:cUSERCODE			:= GetUsrCode()
oObjTotalSO:cSELLERCODE			:= HttpSession->CODVENERP
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
	If !Empty( HttpPost->cCUSTOMERTO ) .AND. !Empty( HttpPost->cCUSTOMERUNITTO )  	
		oObj:cQUERYADDWHERE			:= "C5_CLIENTE >= '" + HttpPost->cCUSTOMERFROM+ "' AND "+"C5_LOJACLI >= '" + HttpPost->cCUSTOMERUNITFROM+ "' AND "+"C5_CLIENTE <= '" + HttpPost->cCUSTOMERTO+ "' AND "+"C5_LOJACLI <= '" + HttpPost->cCUSTOMERUNITTO+ "'"
		oObjTotalSO:cQUERYADDWHERE	:= "C5_CLIENTE >= '" + HttpPost->cCUSTOMERFROM+ "' AND "+"C5_LOJACLI >= '" + HttpPost->cCUSTOMERUNITFROM+ "' AND "+"C5_CLIENTE <= '" + HttpPost->cCUSTOMERTO+ "' AND "+"C5_LOJACLI <= '" + HttpPost->cCUSTOMERUNITTO+ "'"
	Else
		oObj:cQUERYADDWHERE			:= ""
		oObjTotalSO:cQUERYADDWHERE	:= ""
 	EndIf
EndIf

//cUSERCODE,cSELLERID,dREGISTERDATEFROM,dREGISTERDATETO,cBIDNUMBERFROM,cBIDNUMBERTO,cQUERYADDWHERE,cINDEXKEY,nPAGELEN,nPAGEFIRST
If oObj:BRWSALESORDER()
	If HttpPost->cBusca == "1" .OR. HttpPost->cBusca == "2"
		//cUSERCODE,cSELLERID,dREGISTERDATEFROM,dREGISTERDATETO,cBIDNUMBERFROM,cBIDNUMBERTO,cQUERYADDWHERE
		If oObjTotalSO:BRWTOTALSALESORDER()
			HttpSession->nTotalSO := oObjTotalSO:nBRWTOTALSALESORDERRESULT
		Else
			Return PWSHTMLALERT( "", STR0010, "", "W_PWSV040.APW" )//"Erro"
		EndIf
	EndIf

	HttpSession->PWSV042RESULT := { oObj:oWSBRWSALESORDERRESULT:oWSSALESORDERHEADERVIEW }
	HttpSession->PWSV042INFO := {}

	If ExistBlock( "PEV042" )
		aWebCols := ExecBlock( "PEV042", .F., .F., {} )
	EndIf

	GridHeader(		HttpSession->PWSV042INFO, ;
					HttpSession->PWSV042HEADER[1][1], ;
					aWebCols, ;
					HttpSession->PWSV042RESULT[1], ;
					"MTSELLERSALESORDER", ;
					"SC5" )

	GridLinesEx( {	HttpSession->PWSV042INFO, ;
					HttpSession->PWSV042HEADER[1][1], ;
					HttpSession->PWSV042RESULT[1], ;
					aWebCols, .F., "A",, 0 }, "MTSELLERSALESORDER", "SC5" )
Else
	Return PWSHTMLALERT( "", STR0010, "", "W_PWSV040.APW" )//"Erro"
EndIf

cHtml += ExecInPage( "PWSV042" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSV043   บAutor  ณLuiz Felipe Couto    บ Data ณ  21/06/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela de visualizacao do pedico.                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Web Function PWSV043()

Local cHtml 	:= ""		// Pagina HTML
Local oObj					// Objeto WS - MTSELLERSALESORDER
Local aWebCols 	:= {}		// Array com os campos a serem apresentados

WEB EXTENDED INIT cHtml START "InSite"

HttpSession->PWSV043APH := { STR0008 + HttpGet->cPedido, "W_PWSV042.APW" }//"Pedido N๚mero : "

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTSELLERSALESORDER' ), WSMTSELLERSALESORDER():NEW() )
WsChgUrl(@oObj,"MTSELLERSALESORDER.apw")

oObj:cUSERCODE		:= GetUsrCode()
oObj:cSELLERCODE	:= HttpSession->CODVENERP
oObj:cORDERID		:= HttpGet->cPedido
oObj:cQUERYADDWHERE	:= ""

If oObj:GETSALESORDER()
	HttpSession->PWSV043RESULT := { oObj:oWSGETSALESORDERRESULT }
	HttpSession->PWSV043INFO := { {}, {} }
	
	If ExistBlock( "PEV043" )
		aWebCols := ExecBlock( "PEV043", .F., .F., { 1 } )
	EndIf

	GridLinesEx( { HttpSession->PWSV043INFO[1], ;
					HttpSession->PWSV042HEADER[1][1], ;
					HttpSession->PWSV043RESULT[1]:oWSSOHEADER, ;
					aWebCols, .F., "H",, 0 }, "MTSELLERSALESORDER", "SC5" )
					
	aWebCols := {}

	If ExistBlock( "PEV043" )
		aWebCols := ExecBlock( "PEV043", .F., .F., { 2 } )
	EndIf

	GridHeader(		HttpSession->PWSV043INFO[2], ;
					HttpSession->PWSV042HEADER[2][1], ;
					aWebCols, ;
					HttpSession->PWSV043RESULT[1]:oWSSOITEM:oWSSALESORDERITEMVIEW, ;
					"MTSELLERSALESORDER", ;
					"SC6" )

	GridLinesEx( { HttpSession->PWSV043INFO[2], ;
					HttpSession->PWSV042HEADER[2][1], ;
					HttpSession->PWSV043RESULT[1]:oWSSOITEM:oWSSALESORDERITEMVIEW, ;
					aWebCols, .F., "A",, 0 }, "MTSELLERSALESORDER", "SC6" )
Else
	Return PWSHTMLALERT( "", STR0010, "", "W_PWSV040.APW" )//"Erro"
EndIf

cHtml += ExecInPage( "PWSV043" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSV043A  บAutor  ณLuiz Felipe Couto    บ Data ณ  21/06/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela de visualizacao dos itens do pedido.                   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Web Function PWSV043A()

Local cHtml 	:= ""		// Pagina HTML

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage( "PWSV043A" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSV044   บAutor  ณLuiz Felipe Couto    บ Data ณ  21/06/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela de inclusao e alteracado do pedido.                    บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Web Function PWSV044()

Local cHtml 	:= ""		// Pagina HTML
Local nI		:= 0		// Usada em lacos For...Next
Local nTam		:= 0		// Nr. de itens do Pedido
Local aWebCols 	:= {}		// Array com os campos a serem apresentados
Local oObj					// Objeto WS - MTSELLERSALESORDER

WEB EXTENDED INIT cHtml START "InSite"

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTSELLERSALESORDER' ), WSMTSELLERSALESORDER():NEW() )
WsChgURL( @oObj, "MTSELLERSALESORDER.APW" )

HttpSession->PWSV044APH := { STR0014, "" }//"Inclusใo Pedido de Venda"
HttpSession->PWSV044INFO := { {}, {} }

//Limpa a variแvel de sessใo do Or็amento para nใo interferir na busca de produtos gen้rica do Pedido de Venda  
If !(Empty(HttpSession->PWSV084GRAVA))
	HttpSession->PWSV084GRAVA := {}
EndIf

If HttpPost->cAcao == "A"
	HttpPost->cAcao 		:= "I"
	HttpSession->nTotalPed 	:= 0
	
	oObj:cUSERCODE		:= GetUsrCode()
	oObj:cSELLERCODE	:= HttpSession->CODVENERP
	oObj:cORDERID		:= HttpPost->cPedido
	
	If oObj:GETSALESORDER()
		HttpSession->PWSV044GRAVA 		:= { ,{} }
		HttpSession->PWSV044GRAVA[1] 	:= oObj:oWSGETSALESORDERRESULT:oWSSOHEADER
		nTam 							:= Len( oObj:oWSGETSALESORDERRESULT:oWSSOITEM:oWSSALESORDERITEMVIEW )
		
		For nI := 1 To nTam
			aAdd( HttpSession->PWSV044GRAVA[2], MTSELLERSALESORDER_SALESORDERITEMVIEW():New() )

			HttpSession->PWSV044GRAVA[2][nI] 	:= oObj:oWSGETSALESORDERRESULT:oWSSOITEM:oWSSALESORDERITEMVIEW[nI]
			HttpSession->nTotalPed 				+= HttpSession->PWSV044GRAVA[2][nI]:nNETTOTAL
			
			If HttpSession->cItens < oObj:oWSGETSALESORDERRESULT:oWSSOITEM:oWSSALESORDERITEMVIEW[nI]:cORDERITEM
				HttpSession->cItens := oObj:oWSGETSALESORDERRESULT:oWSSOITEM:oWSSALESORDERITEMVIEW[nI]:cORDERITEM
			EndIf
		Next nI
	Else
		Return PWSHTMLALERT( "", STR0010, "", "W_PWSV040.APW" )//"Erro"
	EndIf
Else
	If Empty( HttpSession->PWSV044GRAVA )
		HttpSession->nTotalPed 						:= 0
		HttpSession->cItens							:= Soma1( HttpSession->cItens, 2 )
		oObj 										:= MTSELLERSALESORDER_SALESORDERHEADERVIEW():New()
		oObj:dREGISTERDATE 							:= Date()
		HttpSession->PWSV044GRAVA 					:= { oObj, { MTSELLERSALESORDER_SALESORDERITEMVIEW():New() } }
		HttpSession->PWSV044GRAVA[2][1]:cORDERITEM := HttpSession->cItens
	EndIf
EndIf

If HttpPost->cAcao == "I" .AND. Empty( HttpSession->cAcao )
	HttpSession->cAcao := "I"
EndIf

If HttpSession->cAcao == "I"
	If ExistBlock( "PEV044" )
		aWebCols := ExecBlock( "PEV044", .F., .F., { 1 } )
	Else
		aAdd( aWebCols, { "ORDERID", "D" } )  
		
		aAdd( aWebCols, { "CUSTOMERCODE", "N", { "BRWCUSTOMER", ;
														{ "CCUSTOMERCODE", "CCODE" }, ;
														{ "CCUSTOMERUNIT", "CUNIT" } ;
													}, ;
													{ "CCODE", "CUNIT", "CDESCRIPTION" } } )
		aAdd( aWebCols, "CUSTOMERUNIT" )
		aAdd( aWebCols, { "DELIVERYCUSTOMER", "N", { "BRWCUSTOMER", ;
														{ "CDELIVERYCUSTOMER", "CCODE" }, ;
														{ "CDELIVERYUNITCODE", "CUNIT" } ;
													}, ;
													{ "CCODE", "CUNIT", "CDESCRIPTION" } } )
		aAdd( aWebCols, "DELIVERYUNITCODE" )
		aAdd( aWebCols, { "CARRIERCODE", "N", { "GETCARRIER", ;
												{ "CCARRIERCODE", "CCODE" } ;
												}, ;
												{ "CCODE", "CDESCRIPTION" } } )
		aAdd( aWebCols, { "PAYMENTPLANCODE", "N", { "BRWPAYMENTPLAN", ;
													{ "CPAYMENTPLANCODE", "CPAYMENTPLANCODE" } ;
													}, ;
													{ "CPAYMENTPLANCODE", "CDESCRIPTIONPAYMENTPLAN" } } )
		aAdd( aWebCols, "PRICELISTCODE" )
		aAdd( aWebCols, { "DISCOUNT1", "N" } )
		aAdd( aWebCols, { "DISCOUNT2", "N" } )
		aAdd( aWebCols, { "DISCOUNT3", "N" } )
		aAdd( aWebCols, { "DISCOUNT4", "N" } )
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
	 	aAdd( aWebCols, { "NETWEIGHT", "D" } )
	 	aAdd( aWebCols, { "GROSSWEIGHT", "D" } )
	 	aAdd( aWebCols, { "REDELIVERYCARRIERCODE", "D" } )
	 	aAdd( aWebCols, { "FINANCIALINCREASE", "D" } )
	 	aAdd( aWebCols, { "INVOICEMESSAGE", "N" } )
	 	aAdd( aWebCols, { "STANDARDMESSAGE1", "D" } )
	 	aAdd( aWebCols, { "INDEMNITYVALUE", "D" } )
	 	aAdd( aWebCols, { "INDEMNITYPERCENTAGE", "D" } )
	EndIf
	
	GridLinesEx( { HttpSession->PWSV044INFO[1], ;
					HttpSession->PWSV042HEADER[1][1], ;
					HttpSession->PWSV044GRAVA[1], ;
					aWebCols, .T., "H",, 1 }, "MTSELLERSALESORDER", "SC5" )
	
	aWebCols := {}
	
	If ExistBlock( "PEV044" )
		aWebCols := ExecBlock( "PEV044", .F., .F., { 2 } )
	Else
		aAdd( aWebCols, { "ORDERITEM", "D", 2 } )
		aAdd( aWebCols, { "PRODUCTID", "N", { "GETCATALOG", ;
														{ "CPRODUCTID", "CPRODUCTCODE" }, ; 
														{ "CPRODUCTDESCRIPTION", "CDESCRIPTION"} ; 
													}, ;   
													{ "CPRODUCTCODE", "CDESCRIPTION" }, 13 } )
		aAdd( aWebCols, { "PRODUCTDESCRIPTION", "N", 30, .T. } )
		aAdd( aWebCols, { "QUANTITY", "N", 3 } )
		aAdd( aWebCols, { "NETUNITPRICE", "N", 9, .T. } )
		aAdd( aWebCols, { "DISCOUNTPERCENTAGE", "N", 3 } )
		aAdd( aWebCols, { "CUSTOMERORDERNUMBER", "N", 5 } )
		aAdd( aWebCols, { "NETTOTAL", "N", 0, .F. } )
	EndIf
	
	GridHeader(		HttpSession->PWSV044INFO[2]			,;
					HttpSession->PWSV042HEADER[2][1]	,;
					aWebCols							,;
					HttpSession->PWSV044GRAVA[2]		,;
					"MTSELLERSALESORDER"				,;
					"SC6" )
	
	For nI := 1 To Len( HttpSession->PWSV044GRAVA[2] )
		GridLinesEx( { 	HttpSession->PWSV044INFO[2], ;
						HttpSession->PWSV042HEADER[2][1], ;
						HttpSession->PWSV044GRAVA[2][nI], ;
						aWebCols, .T., "H", AllTrim( Str( nI ) ), ;
						IIf( nI == Len( HttpSession->PWSV044GRAVA[2] ), 3, 2 ), .T. }, "MTSELLERSALESORDER", "SC6" )
	Next nI
EndIf

cHtml += ExecInPage( "PWSV044" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSV045   บAutor  ณLuiz Felipe Couto    บ Data ณ  21/06/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina para inclusao, exclusao e alterado dos itens do      บฑฑ
ฑฑบ          ณ pedido.                                                     บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Web Function PWSV045()

Local cHtml 	:= ""				//Pagina Html
Local nI		:= 0				//Variavel de apoio
Local nTam		:= 0				//Tamanho do Array de Itens

Local nPos//Serv
Private aProp 	:={} //Serv

WEB EXTENDED INIT cHtml START "InSite"

//For็ar a instancia de campo de usuario no HttpSession
aProp := PWVPutUsrFld( HttpSession->PWSV044GRAVA[1], "SC5", "MTSELLERSALESORDER" )
nPos 	:= aScan( aProp, { |x| x[1] == "OWSUSERFIELDS" } )
HttpSession->PWSV044GRAVA[1]:oWSuserfields := aProp[nPos][2]

PWSSetObjToPost( HttpSession->PWSV044GRAVA[1], HttpSession->PWSV042HEADER[1][1], HttpPost->aPost )

nTam := Len( HttpSession->PWSV044GRAVA[2] )

For nI := 1 To nTam

	//For็ar a instancia de campo de usuario no HttpSession
	aProp := PWVPutUsrFld( HttpSession->PWSV044GRAVA[2][nI], "SC6", "MTSELLERSALESORDER" )
	nPos 	:= aScan( aProp, { |x| x[1] == "OWSUSERFIELDS" } )
	HttpSession->PWSV044GRAVA[2][nI]:oWSuserfields := aProp[nPos][2]
	
	PWSSetObjToPost( HttpSession->PWSV044GRAVA[2][nI], HttpSession->PWSV042HEADER[2][1], HttpPost->aPost, AllTrim( Str( nI ) ) )

Next nI

If !Empty( HttpPost->cItem )
	If Len( HttpSession->PWSV044GRAVA[2] ) > 1
		aDel( HttpSession->PWSV044GRAVA[2], Val( HttpPost->cItem ) )
		aSize( HttpSession->PWSV044GRAVA[2], Len( HttpSession->PWSV044GRAVA[2] ) - 1 )
	EndIf
Else
	aAdd( HttpSession->PWSV044GRAVA[2], MTSELLERSALESORDER_SALESORDERITEMVIEW():New() )

	HttpSession->cItens 							:= Soma1( HttpSession->cItens, 2 )
	nTam 											:= Len( HttpSession->PWSV044GRAVA[2] )
	HttpSession->PWSV044GRAVA[2][nTam]:cORDERITEM 	:= HttpSession->cItens
EndIf

cHtml += W_PWSV044()

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSV046   บAutor  ณLuiz Felipe Couto    บ Data ณ  21/06/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina para simulacao do pedido.                            บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบCleber M. ณ26/04/07ณ126155ณ-Alteracao para limpar o cliente de entrega  บฑฑ
ฑฑบ          ณ        ณ      ณquando ocorrer a troca de cliente no PV. 	   บฑฑ
ฑฑบCleber M. ณ29/05/07ณ126548ณ-Correcao para zerar o valor do item e per-  บฑฑ
ฑฑบ          ณ        ณ      ณmitir que o mesmo seja recalculado quando	   บฑฑ
ฑฑบ          ณ        ณ      ณocorrer alteracao de qtde.                   บฑฑ
ฑฑบCleber M. ณ18/06/07ณ127615ณ-Alteracao para limpar os campos amarrados aoบฑฑ
ฑฑบ          ณ        ณ  9.12ณcliente/loja quando ocorrer a troca do mesmo.บฑฑ
ฑฑบCleber M. ณ17/07/07ณ129044ณ- Atualizacao do campo  Condicao de Pagto	   บฑฑ
ฑฑบ          ณ        ณ      ณquando o campo estiver como Disable.         บฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Web Function PWSV046()

Local cHtml 		:= ""		// Pagina HTML a ser exibida
Local oObj						// Objeto WS - MTSIMULATIONSALESORDER
Local oObjCfg					// Objeto WS - CFGDICTIONARY
Local nI			:= 0		// Usada em lacos For...Next
Local nJ			:= 0		// Usada em lacos For...Next
Local aProp			:= {}		// Array com as propriedades dos campos de usuario
Local cOldCustomer	:= ""		// Guarda o ultimo cliente/loja informado no PV
Local cProxItem		:= "00"

Local nPos//Serv
Private aProp 	:={} //Serv

WEB EXTENDED INIT cHtml START "InSite"

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTSIMULATIONSALESORDER' ), WSMTSIMULATIONSALESORDER():NEW() )
oObjCfg := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSCFGDICTIONARY' ), WSCFGDICTIONARY():NEW() )

WsChgURL( @oObj, "MTSIMULATIONSALESORDER.APW" )
WsChgURL( @oObjCfg, "CFGDICTIONARY.APW" )

//For็ar a instancia de campo de usuario no HttpSession
aProp := PWVPutUsrFld( HttpSession->PWSV044GRAVA[1], "SC5", "MTSELLERSALESORDER" )
nPos 	:= aScan( aProp, { |x| x[1] == "OWSUSERFIELDS" } )
HttpSession->PWSV044GRAVA[1]:oWSuserfields := aProp[nPos][2]

PWSSetObjToPost( HttpSession->PWSV044GRAVA[1], HttpSession->PWSV042HEADER[1][1], HttpPost->aPost )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Guarda o cod. do cliente anterior ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If HttpSession->PWSV044GRAVA[1]:CCUSTOMERCODE <> Nil
	cOldCustomer := HttpSession->PWSV044GRAVA[1]:CCUSTOMERCODE + HttpSession->PWSV044GRAVA[1]:CCUSTOMERUNIT
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica se houve troca de cliente e limpa os campos amarrados  ณ
//ณ ao cliente p/ serem atualizados automaticamente pela Mata410()  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !Empty( cOldCustomer ) .AND.;
	( cOldCustomer <> HttpSession->PWSV044GRAVA[1]:CCUSTOMERCODE + HttpSession->PWSV044GRAVA[1]:CCUSTOMERUNIT )
	
	HttpSession->PWSV044GRAVA[1]:CDELIVERYCUSTOMER	:= ""		//Cliente Entrega
	HttpSession->PWSV044GRAVA[1]:CDELIVERYUNITCODE	:= ""		//Loja Entrega
	HttpSession->PWSV044GRAVA[1]:CCARRIERCODE		:= ""		//Transportadora
	HttpSession->PWSV044GRAVA[1]:CBANKCODE			:= ""		//Banco
	HttpSession->PWSV044GRAVA[1]:NDISCOUNT1			:= 0		//Desconto 1
	If aScan( HttpPost->aPost, "CPAYMENTPLANCODE_H" ) > 0
		HttpSession->PWSV044GRAVA[1]:CPAYMENTPLANCODE	:= ""	//Cond. Pagto
	EndIf
EndIf

nTam := Len( HttpSession->PWSV044GRAVA[2] )

For nI := 1 To nTam
	HttpSession->PWSV044GRAVA[2][nI] := MTSELLERSALESORDER_SALESORDERITEMVIEW():New()
	
	aProp := ClassDataArr( HttpSession->PWSV044GRAVA[2][nI] )
	nPos := aScan( aProp, { |x| x[1] == "OWSUSERFIELDS" } )

	oObjCfg:cUSERCODE 	:= GetUsrCode()
	oObjCfg:cALIAS		:= "SC6"
	
	//cUSERCODE,cALIAS
	If oObjCfg:GETUSERFIELD()
		aProp[nPos][2] := MTSELLERSALESORDER_ARRAYOFUSERFIELD():New()
		
		For nJ := 1 To Len( oObjCfg:oWSGETUSERFIELDRESULT:oWSUSERFIELD )
			aAdd( aProp[nPos][2]:oWSUSERFIELD, MTSELLERSALESORDER_USERFIELD():New() )
			
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
	
	//For็ar a instancia de campo de usuario no HttpSession
	aProp := PWVPutUsrFld( HttpSession->PWSV044GRAVA[2][nI], "SC6", "MTSELLERSALESORDER" )
	nPos 	:= aScan( aProp, { |x| x[1] == "OWSUSERFIELDS" } )
	HttpSession->PWSV044GRAVA[2][nI]:oWSuserfields := aProp[nPos][2]
	
	PWSSetObjToPost( HttpSession->PWSV044GRAVA[2][nI], HttpSession->PWSV042HEADER[2][1], HttpPost->aPost, AllTrim( Str( nI ) ) )
	cProxItem:=Soma1(cProxItem,2)
	If Empty(HttpSession->PWSV044GRAVA[1]:cORDERID)
		HttpSession->PWSV044GRAVA[2][nI]:cORDERITEM := cProxItem
   	EndIf	
	HttpSession->PWSV044GRAVA[2][nI]:nNETTOTAL	:= 0
Next nI

oObj:cUSERCODE			:= GetUsrCode()
oObj:oWSOLDSALESORDER := MTSIMULATIONSALESORDER_SALESORDERVIEW():New()
oObj:oWSOLDSALESORDER:oWSSOHEADER	:= HttpSession->PWSV044GRAVA[1]
oObj:oWSOLDSALESORDER:oWSSOHEADER:cORDERTYPECODE := "N"
oObj:oWSOLDSALESORDER:oWSSOITEM		:= MTSIMULATIONSALESORDER_ARRAYOFSALESORDERITEMVIEW():New()

For nI := 1 To Len( HttpSession->PWSV044GRAVA[2] )
	aAdd( oObj:oWSOLDSALESORDER:oWSSOITEM:oWSSALESORDERITEMVIEW, MTSIMULATIONSALESORDER_SALESORDERITEMVIEW():New() )
	oObj:oWSOLDSALESORDER:oWSSOITEM:oWSSALESORDERITEMVIEW[nI] := HttpSession->PWSV044GRAVA[2][nI]
	oObj:oWSOLDSALESORDER:oWSSOITEM:oWSSALESORDERITEMVIEW[nI]:cPRODUCTID := oObj:oWSOLDSALESORDER:oWSSOITEM:oWSSALESORDERITEMVIEW[nI]:cPRODUCTID
Next nI
If !Empty(HttpSession->PWSV044GRAVA[1]:cORDERID)
	lAltera := .T.
Else
	lAltera := .F.
EndIf
If oObj:PUTSALESORDER()
	If !lAltera
		oObj:oWSPUTSALESORDERRESULT:oWSSOHEADER:cORDERID := ""
	EndIf
	HttpSession->PWSV044GRAVA[1] := oObj:oWSPUTSALESORDERRESULT:oWSSOHEADER
	HttpSession->PWSV044GRAVA[2] := {}
	HttpSession->nTotalPed := 0
	For nI := 1 To Len( oObj:oWSPUTSALESORDERRESULT:oWSSOITEM:oWSSALESORDERITEMVIEW )
		aAdd( HttpSession->PWSV044GRAVA[2], MTSIMULATIONSALESORDER_SALESORDERITEMVIEW():New() )
		HttpSession->PWSV044GRAVA[2][nI] := oObj:oWSPUTSALESORDERRESULT:oWSSOITEM:oWSSALESORDERITEMVIEW[nI]
		HttpSession->nTotalPed += HttpSession->PWSV044GRAVA[2][nI]:nNETTOTAL
	Next nI
Else
	Return PWSHTMLALERT( "", STR0003, "", "W_PWSV044.APW" )//"Erro"
EndIf

cHtml += W_PWSV044()

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSV047   บAutor  ณLuiz Felipe Couto    บ Data ณ  21/06/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina para inclusao, exclusao e alterado do pedido.        บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Web Function PWSV047()

Local cHtml 	:= ""		// Pagina HTML
Local nI		:= 0		// Usada em lacos For...Next
Local oObj					// Objeto WS - MTSELLERSALESORDER

Local nPos 	:= 0//Serv
Private aProp 	:={} //Serv

WEB EXTENDED INIT cHtml START "InSite"

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTSELLERSALESORDER' ), WSMTSELLERSALESORDER():NEW() )
WsChgURL( @oObj, "MTSELLERSALESORDER.APW" )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPreenche a session com os campos de usuarioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//For็ar a instancia de campo de usuario no HttpSession
aProp := PWVPutUsrFld( HttpSession->PWSV044GRAVA[1], "SC5", "MTSELLERSALESORDER" )
nPos 	:= aScan( aProp, { |x| x[1] == "OWSUSERFIELDS" } )
HttpSession->PWSV044GRAVA[1]:oWSuserfields := aProp[nPos][2]

PWSSetObjToPost( HttpSession->PWSV044GRAVA[1], HttpSession->PWSV042HEADER[1][1], HttpPost->aPost )

nTam := Len( HttpSession->PWSV044GRAVA[2] )

For nI := 1 To nTam
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPreenche a session com os campos de usuarioณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//For็ar a instancia de campo de usuario no HttpSession
	aProp := PWVPutUsrFld( HttpSession->PWSV044GRAVA[2][nI], "SC6", "MTSELLERSALESORDER" )
	nPos 	:= aScan( aProp, { |x| x[1] == "OWSUSERFIELDS" } )
	HttpSession->PWSV044GRAVA[2][nI]:oWSuserfields := aProp[nPos][2]
	
	PWSSetObjToPost( HttpSession->PWSV044GRAVA[2][nI], HttpSession->PWSV042HEADER[2][1], HttpPost->aPost, AllTrim( Str( nI ) ) )
Next nI

oObj:cUSERCODE 		:= GetUsrCode()
oObj:cSELLERCODE	:= HttpSession->CODVENERP
oObj:oWSSALESORDER 	:= MTSELLERSALESORDER_SALESORDERVIEW():New()
oObj:oWSSALESORDER:oWSSOHEADER := MTSELLERSALESORDER_SALESORDERHEADERVIEW():New()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPreenche o objeto com os dados da sessionณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
PWSPutHeader( oObj:oWSSALESORDER:oWSSOHEADER, HttpSession->PWSV044GRAVA[1] )

oObj:oWSSALESORDER:oWSSOITEM		:= MTSELLERSALESORDER_ARRAYOFSALESORDERITEMVIEW():New()

nTam := Len( HttpSession->PWSV044GRAVA[2] )

For nI := 1 To nTam
	aAdd( oObj:oWSSALESORDER:oWSSOITEM:oWSSALESORDERITEMVIEW, MTSELLERSALESORDER_SALESORDERITEMVIEW():New() )

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPreenche o objeto com os dados da sessionณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	PWSPutItem( oObj:oWSSALESORDER:oWSSOITEM:oWSSALESORDERITEMVIEW[nI], HttpSession->PWSV044GRAVA[2][nI] )
Next nI

If Empty( oObj:oWSSALESORDER:oWSSOHEADER:cORDERID )
	oObj:oWSSALESORDER:oWSSOHEADER:cORDERID := Nil
EndIf

If oObj:PUTSALESORDER()
	Return PWSHTMLALERT( "", STR0015, STR0008 + oObj:cPUTSALESORDERRESULT + STR0016, "W_PWSV040.APW" )//"Aten็ใo"//"Pedido N๚mero "//" cadastrado com SUCESSO!"
Else
	Return PWSHTMLALERT( "", STR0010, "", "W_PWSV044.APW" )//"Erro"
EndIf

cHtml += W_PWSV044()

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSPutHeadบAutor  ณLuiz Felipe Couto    บ Data ณ  29/09/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Popula as propriedades da session com o objeto.             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PWSPutHeader( oObj, oSession)

oObj:nADDITIONALEXPENSEVALUE	:= oSession:nADDITIONALEXPENSEVALUE
oObj:cADJUSTMENTTYPE			:= oSession:cADJUSTMENTTYPE
oObj:cAPROBATIONTYPE			:= oSession:cAPROBATIONTYPE
oObj:cBANKCODE					:= oSession:cBANKCODE
oObj:cBIDNUMBER					:= oSession:cBIDNUMBER
oObj:cCARRIERCODE				:= oSession:cCARRIERCODE
oObj:cCUSTOMERCODE				:= oSession:cCUSTOMERCODE
oObj:cCUSTOMERTYPE				:= oSession:cCUSTOMERTYPE
oObj:cCUSTOMERUNIT				:= oSession:cCUSTOMERUNIT
oObj:cDELIVERYCUSTOMER			:= oSession:cDELIVERYCUSTOMER
oObj:cDELIVERYUNITCODE			:= oSession:cDELIVERYUNITCODE
oObj:nDISCOUNT1					:= oSession:nDISCOUNT1
oObj:nDISCOUNT2					:= oSession:nDISCOUNT2
oObj:nDISCOUNT3					:= oSession:nDISCOUNT3
oObj:nDISCOUNT4					:= oSession:nDISCOUNT4
oObj:nFINANCIALDISCOUNT			:= oSession:nFINANCIALDISCOUNT
oObj:nFINANCIALINCREASE			:= oSession:nFINANCIALINCREASE
oObj:cFREIGHTTYPE				:= oSession:cFREIGHTTYPE
oObj:nFREIGHTVALUE				:= oSession:nFREIGHTVALUE
oObj:nGROSSWEIGHT				:= oSession:nGROSSWEIGHT
oObj:nINDEMNITYPERCENTAGE		:= oSession:nINDEMNITYPERCENTAGE
oObj:nINDEMNITYVALUE			:= oSession:nINDEMNITYVALUE
oObj:nINDEPENDENTFREIGHT		:= oSession:nINDEPENDENTFREIGHT
oObj:nINSURANCEVALUE			:= oSession:nINSURANCEVALUE
oObj:cINVOICEMESSAGE			:= oSession:cINVOICEMESSAGE
oObj:nNETWEIGHT					:= oSession:nNETWEIGHT
oObj:cORDERID					:= oSession:cORDERID
oObj:cORDERTYPECODE				:= "N"
oObj:cPAYMENTPLANCODE			:= oSession:cPAYMENTPLANCODE
oObj:cPRICELISTCODE				:= oSession:cPRICELISTCODE
oObj:cPRICEWITHSERVICETAX		:= oSession:cPRICEWITHSERVICETAX
oObj:cREDELIVERYCARRIERCODE		:= oSession:cREDELIVERYCARRIERCODE
oObj:dREGISTERDATE				:= oSession:dREGISTERDATE
oObj:nSALESORDERCURRENCY		:= oSession:nSALESORDERCURRENCY
oObj:cSTANDARDMESSAGE1			:= oSession:cSTANDARDMESSAGE1

oObj:oWSSELLERS					:= MTSELLERSALESORDER_ARRAYOFGENERICSTRUCT():New()

AAdd( oObj:oWSSELLERS:oWSGENERICSTRUCT, MTSELLERSALESORDER_GENERICSTRUCT():New() )
oObj:oWSSELLERS:oWSGENERICSTRUCT[1]:cCODE 			:= HttpSession->CODVENERP
oObj:oWSSELLERS:oWSGENERICSTRUCT[1]:cDESCRIPTION 	:= HttpSession->CODVENERP

oObj:oWSUSERFIELDS				:= oSession:oWSUSERFIELDS

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSPutItemบAutor  ณLuiz Felipe Couto    บ Data ณ  29/09/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Popula as propriedades da session com o objeto.             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PWSPutItem( oObj, oSession)

oObj:cCUSTOMERORDERNUMBER		:= oSession:cCUSTOMERORDERNUMBER
oObj:dDELIVERYDATE				:= oSession:dDELIVERYDATE
oObj:nDISCOUNTPERCENTAGE		:= oSession:nDISCOUNTPERCENTAGE
oObj:cFISCALOPERATION			:= oSession:cFISCALOPERATION
oObj:nITEMDISCOUNTVALUE			:= oSession:nITEMDISCOUNTVALUE
oObj:cITEMOUTFLOWTYPE			:= oSession:cITEMOUTFLOWTYPE
oObj:cLOCATION					:= oSession:cLOCATION
oObj:cLOTNUMBER					:= oSession:cLOTNUMBER
oObj:cMANUFACTURERCODE			:= oSession:cMANUFACTURERCODE
oObj:cMANUFACTURERUNIT			:= oSession:cMANUFACTURERUNIT
oObj:nNETUNITPRICE				:= oSession:nNETUNITPRICE
oObj:cOPERATIONTYPE				:= oSession:cOPERATIONTYPE
oObj:cORDERID					:= oSession:cORDERID
oObj:cORDERITEM					:= oSession:cORDERITEM
oObj:cORIGINALINVOICE			:= oSession:cORIGINALINVOICE
oObj:cORIGINALINVOICEITEM		:= oSession:cORIGINALINVOICEITEM
oObj:cORIGINALINVOICESERIALID	:= oSession:cORIGINALINVOICESERIALID
oObj:cPOGRADEITEM				:= oSession:cPOGRADEITEM
oObj:cPOID						:= oSession:cPOID
oObj:cPOITEM					:= oSession:cPOITEM
oObj:cPOSEQUENCE				:= oSession:cPOSEQUENCE
oObj:cPRODUCTDESCRIPTION		:= oSession:cPRODUCTDESCRIPTION
oObj:cPRODUCTID 				:= oSession:cPRODUCTID
oObj:cPRODUCTSERIALNUMBER		:= oSession:cPRODUCTSERIALNUMBER
oObj:nQUANTITY					:= oSession:nQUANTITY
oObj:nQUANTITYAPPROVED			:= oSession:nQUANTITYAPPROVED
oObj:nQUANTITYDELIVERED			:= oSession:nQUANTITYDELIVERED
oObj:nQUANTITYRELEASEDSECONDUNIT:= oSession:nQUANTITYRELEASEDSECONDUNIT
oObj:nSECONDMEASUREUNITQUANTITY	:= oSession:nSECONDMEASUREUNITQUANTITY
oObj:cSECONDUNITOFMEASURE		:= oSession:cSECONDUNITOFMEASURE
oObj:cSUBLOT					:= oSession:cSUBLOT
oObj:nUNITLISTPRICE				:= oSession:nUNITLISTPRICE
oObj:cUNITOFMEASURE				:= oSession:cUNITOFMEASURE
oObj:cWAREHOUSE					:= oSession:cWAREHOUSE
oObj:oWSUSERFIELDS				:= oSession:oWSUSERFIELDS

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSPutHeadบAutor  ณLuiz Felipe Couto    บ Data ณ  29/09/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Popula as propriedades da session com o objeto.             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PWSGetHeader( oObj, oSession)

oSession:nADDITIONALEXPENSEVALUE	:= oObj:nADDITIONALEXPENSEVALUE
oSession:cADJUSTMENTTYPE			:= oObj:cADJUSTMENTTYPE
oSession:cAPROBATIONTYPE			:= oObj:cAPROBATIONTYPE
oSession:cBANKCODE					:= oObj:cBANKCODE
oSession:cBIDNUMBER					:= oObj:cBIDNUMBER
oSession:cCARRIERCODE				:= oObj:cCARRIERCODE
oSession:cCUSTOMERCODE				:= oObj:cCUSTOMERCODE
oSession:cCUSTOMERTYPE				:= oObj:cCUSTOMERTYPE
oSession:cCUSTOMERUNIT				:= oObj:cCUSTOMERUNIT
oSession:cDELIVERYCUSTOMER			:= oObj:cDELIVERYCUSTOMER
oSession:cDELIVERYUNITCODE			:= oObj:cDELIVERYUNITCODE
oSession:nDISCOUNT1					:= oObj:nDISCOUNT1
oSession:nDISCOUNT2					:= oObj:nDISCOUNT2
oSession:nDISCOUNT3					:= oObj:nDISCOUNT3
oSession:nDISCOUNT4					:= oObj:nDISCOUNT4
oSession:nFINANCIALDISCOUNT			:= oObj:nFINANCIALDISCOUNT
oSession:nFINANCIALINCREASE			:= oObj:nFINANCIALINCREASE
oSession:cFREIGHTTYPE				:= oObj:cFREIGHTTYPE
oSession:nFREIGHTVALUE				:= oObj:nFREIGHTVALUE
oSession:nGROSSWEIGHT				:= oObj:nGROSSWEIGHT
oSession:nINDEMNITYPERCENTAGE		:= oObj:nINDEMNITYPERCENTAGE
oSession:nINDEMNITYVALUE			:= oObj:nINDEMNITYVALUE
oSession:nINDEPENDENTFREIGHT		:= oObj:nINDEPENDENTFREIGHT
oSession:nINSURANCEVALUE			:= oObj:nINSURANCEVALUE
oSession:cINVOICEMESSAGE			:= oObj:cINVOICEMESSAGE
oSession:nNETWEIGHT					:= oObj:nNETWEIGHT
oSession:cORDERID					:= oObj:cORDERID
oSession:cORDERTYPECODE				:= oObj:cORDERTYPECODE
oSession:cPAYMENTPLANCODE			:= oObj:cPAYMENTPLANCODE
oSession:cPRICELISTCODE				:= oObj:cPRICELISTCODE
oSession:cPRICEWITHSERVICETAX		:= oObj:cPRICEWITHSERVICETAX
oSession:cREDELIVERYCARRIERCODE		:= oObj:cREDELIVERYCARRIERCODE
oSession:dREGISTERDATE				:= oObj:dREGISTERDATE
oSession:nSALESORDERCURRENCY		:= oObj:nSALESORDERCURRENCY
oSession:cSTANDARDMESSAGE1			:= oObj:cSTANDARDMESSAGE1
oSession:oWSUSERFIELDS              := oObj:oWSUSERFIELDS
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSPutItemบAutor  ณLuiz Felipe Couto    บ Data ณ  29/09/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Popula as propriedades da session com o objeto.             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PWSGetItem( oObj, oSession)

oSession:cCUSTOMERORDERNUMBER		:= oObj:cCUSTOMERORDERNUMBER
oSession:dDELIVERYDATE				:= oObj:dDELIVERYDATE
oSession:nDISCOUNTPERCENTAGE		:= oObj:nDISCOUNTPERCENTAGE
oSession:cFISCALOPERATION			:= oObj:cFISCALOPERATION
oSession:nITEMDISCOUNTVALUE			:= oObj:nITEMDISCOUNTVALUE
oSession:cITEMOUTFLOWTYPE			:= oObj:cITEMOUTFLOWTYPE
oSession:cLOCATION					:= oObj:cLOCATION
oSession:cLOTNUMBER					:= oObj:cLOTNUMBER
oSession:cMANUFACTURERCODE			:= oObj:cMANUFACTURERCODE
oSession:cMANUFACTURERUNIT			:= oObj:cMANUFACTURERUNIT
oSession:nNETTOTAL					:= oObj:nNETTOTAL
oSession:nNETUNITPRICE				:= oObj:nNETUNITPRICE
oSession:cOPERATIONTYPE				:= oObj:cOPERATIONTYPE
oSession:cORDERID					:= oObj:cORDERID
oSession:cORDERITEM					:= oObj:cORDERITEM
oSession:cORIGINALINVOICE			:= oObj:cORIGINALINVOICE
oSession:cORIGINALINVOICEITEM		:= oObj:cORIGINALINVOICEITEM
oSession:cORIGINALINVOICESERIALID	:= oObj:cORIGINALINVOICESERIALID
oSession:cPOGRADEITEM				:= oObj:cPOGRADEITEM
oSession:cPOID						:= oObj:cPOID
oSession:cPOITEM					:= oObj:cPOITEM
oSession:cPOSEQUENCE				:= oObj:cPOSEQUENCE
oSession:cPRODUCTDESCRIPTION		:= oObj:cPRODUCTDESCRIPTION
oSession:cPRODUCTID 				:= oObj:cPRODUCTID
oSession:cPRODUCTSERIALNUMBER		:= oObj:cPRODUCTSERIALNUMBER
oSession:nQUANTITY					:= oObj:nQUANTITY
oSession:nQUANTITYAPPROVED			:= oObj:nQUANTITYAPPROVED
oSession:nQUANTITYDELIVERED			:= oObj:nQUANTITYDELIVERED
oSession:nQUANTITYRELEASEDSECONDUNIT:= oObj:nQUANTITYRELEASEDSECONDUNIT
oSession:nSECONDMEASUREUNITQUANTITY	:= oObj:nSECONDMEASUREUNITQUANTITY
oSession:cSECONDUNITOFMEASURE		:= oObj:cSECONDUNITOFMEASURE
oSession:cSUBLOT					:= oObj:cSUBLOT
oSession:nUNITLISTPRICE				:= oObj:nUNITLISTPRICE
oSession:cUNITOFMEASURE				:= oObj:cUNITOFMEASURE
oSession:cWAREHOUSE					:= oObj:cWAREHOUSE
oSession:oWSUSERFIELDS              := oObj:oWSUSERFIELDS
Return


//-------------------------------------------------------------------
//-------------------------------------------------------------------
/*/{Protheus.doc} PWSQtd044Gat
Gatilho do campo Quantidade do Pedido de venda no Portal do Fornecedor (PWSV044)

@author jose.eulalio

@since 27/07/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Web Function PWSQtd044Gat()
Local oObj			:= IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTPRODUCT' ), WSMTPRODUCT():NEW() )
Local oParam		:= IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSCFGDICTIONARY' ), WSCFGDICTIONARY():NEW() )
Local oCliente		:= IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTCUSTOMER' ), WSMTCUSTOMER():NEW() )
Local ObjCfg 		:= IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSCFGDICTIONARY' ), WSCFGDICTIONARY():NEW() )
Local nPrice		:= 0
Local nX			:= 0
Local nJ			:= 0
Local nI			:= 0
Local nTam			:= 0
Local nVlrUnit	:= 0
Local cPWSUser	:= GetUsrCode()
Local cOldCustomer	:= ""
Local cHtml		:= ""
Local cProxItem	:= ""
Local lAchou		:= .F.
Local aProp		:= {}
Local cTabCabec	:= ""
Local cTabCli	:= ""
Local cTabPv	:= ""
Local lTabPv	:= .F.
Local cTabPad	:= ""
lOCAL lTabPad	:= .F.
Local nY			:= 0
Local nDescont	:= 0
Local cTabWhere := ""

Private aProp 	:={} //Serv

//WEB EXTENDED INIT cHtml START "InSite"

WsChgUrl( @oObj, "MTPRODUCT.apw" )
WsChgUrl( @oParam,"CFGDICTIONARY.APW" )
WsChgUrl( @oCliente, "MTCUSTOMER.APW" )

If oParam:GETPARAM( cPWSUser, "MV_PVTABPV" )
	lTabPv	:= .T.
	cTabPv := oParam:cGETPARAMRESULT
EndIf

If oParam:GETPARAM( cPWSUser, "MV_TABPAD" )
	lTabPad	:= .T.
	cTabPad := oParam:cGETPARAMRESULT
EndIf

//Guarda o cod. do cliente anterior ณ
If HttpSession->PWSV044GRAVA[1]:CCUSTOMERCODE <> Nil
	cOldCustomer := HttpSession->PWSV044GRAVA[1]:CCUSTOMERCODE + HttpSession->PWSV044GRAVA[1]:CCUSTOMERUNIT
EndIf

//For็ar a instancia de campo de usuario no HttpSession
aProp := PWVPutUsrFld( HttpSession->PWSV044GRAVA[1], "SC5", "MTSELLERSALESORDER" )
nPos 	:= aScan( aProp, { |x| x[1] == "OWSUSERFIELDS" } )
HttpSession->PWSV044GRAVA[1]:oWSuserfields := aProp[nPos][2]

//Popula os dados digitados no browse, alimentando o objeto (HttpSession->PWSV044GRAVA[1])
PWSSetObjToPost( HttpSession->PWSV044GRAVA[1], HttpSession->PWSV042HEADER[1][1], HttpPost->aPost )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica se houve troca de cliente e limpa os campos amarrados  ณ
//ณ ao cliente p/ serem atualizados automaticamente pela Mata410()  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !Empty( cOldCustomer ) .AND.;
	( cOldCustomer <> HttpSession->PWSV044GRAVA[1]:CCUSTOMERCODE + HttpSession->PWSV044GRAVA[1]:CCUSTOMERUNIT )
	
	HttpSession->PWSV044GRAVA[1]:CDELIVERYCUSTOMER	:= ""		//Cliente Entrega
	HttpSession->PWSV044GRAVA[1]:CDELIVERYUNITCODE	:= ""		//Loja Entrega
	HttpSession->PWSV044GRAVA[1]:CCARRIERCODE		:= ""		//Transportadora
	HttpSession->PWSV044GRAVA[1]:CBANKCODE			:= ""		//Banco
	HttpSession->PWSV044GRAVA[1]:NDISCOUNT1			:= 0		//Desconto 1
	If aScan( HttpPost->aPost, "CPAYMENTPLANCODE_H" ) > 0
		HttpSession->PWSV044GRAVA[1]:CPAYMENTPLANCODE	:= ""	//Cond. Pagto
	EndIf
EndIf

If ValType(HttpSession->PWSV044GRAVA[1]:CPRICELISTCODE) <> "U"
	cTabCabec := HttpSession->PWSV044GRAVA[1]:CPRICELISTCODE
Else
	cTabCabec := Space(TamSx3("DA1_CODTAB")[1])
EndIf
//Instancia os dados do cliente no Objeto oCliente 
oCliente:GETCUSTOMER( cPwsUser, HttpSession->PWSV044GRAVA[1]:cCustomerCode )
//Pega o codigo da tabela de pre็o informada cadastro do cliente
If ValType(oCliente:oWSGETCUSTOMERRESULT:cPriceTableCode) <> "U"
	cTabCli := oCliente:oWSGETCUSTOMERRESULT:cPriceTableCode
Else
	cTabCli := Space(TamSx3("DA1_CODTAB")[1])
EndIf
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Regra de aplica็ใo do gatilho do pre็o de venda conforme tabela de Pre็o  ณ
//ณ Seguirแ a ordem informada abaixo caso 2 ou mais op็๕es forem preenchidas  ณ
//ณ 1 Tabela informada no cabe็alho do pedido						   		  ณ
//ณ 2 Tabela informada no cadastro do Cliente						   		  ณ
//ณ 3 Tabela informada no parโmetro MV_TABPAD						   		  ณ
//ณ 4 Tabela informada no parโmetro MV_TABPV						   		  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Do Case
	Case !Empty(cTabCabec)
		cTabWhere := " DA1_CODTAB = '"+cTabCabec+"' "
	Case !Empty(cTabCli)	
		cTabWhere := " DA1_CODTAB = '"+cTabCli+"' "
	Case !Empty(cTabPad)
		cTabWhere := " DA1_CODTAB = '"+cTabPad+"' "
	Case !Empty(cTabPv)
		cTabWhere := " DA1_CODTAB = '"+cTabPv+"' "	
	OtherWise
		//Nใo encontrou tabela de pre็os, entใo passa cTabCabec que estแ
		// Vazio, para o m้todo GETPRICE nใo retornar nenhuma tabela
		cTabWhere := " DA1_CODTAB = '"+cTabCabec+"' " 
EndCase

nTam := Len( HttpSession->PWSV044GRAVA[2] )

If !(Empty(HttpSession->PWSV044GRAVA[1]:cCustomerCode))

	For nI := 1 To nTam
	
		lAchou := .F.
		nVlrUnit := 0
	
		HttpSession->PWSV044GRAVA[2][nI] := MTSELLERSALESORDER_SALESORDERITEMVIEW():New()
		
		aProp := ClassDataArr( HttpSession->PWSV044GRAVA[2][nI] )
		nPos := aScan( aProp, { |x| x[1] == "OWSUSERFIELDS" } )
	
		oParam:cUSERCODE 	:= cPWSUser
		oParam:cALIAS		:= "SC6"
		
		//cUSERCODE,cALIAS
		If oParam:GETUSERFIELD()
			aProp[nPos][2] := MTSELLERSALESORDER_ARRAYOFUSERFIELD():New()
			
			For nJ := 1 To Len( oParam:oWSGETUSERFIELDRESULT:oWSUSERFIELD )
				aAdd( aProp[nPos][2]:oWSUSERFIELD, MTSELLERSALESORDER_USERFIELD():New() )
				
				aProp[nPos][2]:oWSUSERFIELD[nJ]:nUSERDEC		:= oParam:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:nUSERDEC
				aProp[nPos][2]:oWSUSERFIELD[nJ]:cUSERNAME		:= oParam:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:cUSERNAME
				aProp[nPos][2]:oWSUSERFIELD[nJ]:lUSEROBLIG	:= oParam:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:lUSEROBLIG
				aProp[nPos][2]:oWSUSERFIELD[nJ]:cUSERPICTURE	:= oParam:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:cUSERPICTURE
				aProp[nPos][2]:oWSUSERFIELD[nJ]:nUSERSIZE		:= oParam:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:nUSERSIZE
				aProp[nPos][2]:oWSUSERFIELD[nJ]:cUSERTAG		:= oParam:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:cUSERTAG
				aProp[nPos][2]:oWSUSERFIELD[nJ]:cUSERTITLE	:= oParam:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:cUSERTITLE
				aProp[nPos][2]:oWSUSERFIELD[nJ]:cUSERTYPE		:= oParam:oWSGETUSERFIELDRESULT:oWSUSERFIELD[nJ]:cUSERTYPE
			Next nJ
		Else
			conout( GetWsCError( 3 ) )
		EndIf
		
		//For็ar a instancia de campo de usuario no HttpSession
		aProp := PWVPutUsrFld( HttpSession->PWSV044GRAVA[2][nI], "SC6", "MTSELLERSALESORDER" )
		nPos 	:= aScan( aProp, { |x| x[1] == "OWSUSERFIELDS" } )
		HttpSession->PWSV044GRAVA[2][nI]:oWSuserfields := aProp[nPos][2]
		
		PWSSetObjToPost( HttpSession->PWSV044GRAVA[2][nI], HttpSession->PWSV042HEADER[2][1], HttpPost->aPost, AllTrim( Str( nI ) ) )
		cProxItem:=Soma1(cProxItem,2)
		If Empty(HttpSession->PWSV044GRAVA[1]:cORDERID)
			HttpSession->PWSV044GRAVA[2][nI]:cORDERITEM := cProxItem
	   	EndIf
		   	
		If !(Empty(HttpSession->PWSV044GRAVA[2][nI]:cProductId))
			//atualiza pre็o da tabela
			HttpSession->PWSV044GRAVA[2][nI]:cOrderItem := StrZero( nI, 2 )
			If oObj:GETPRICE( cPWSUser, HttpSession->PWSV044GRAVA[2][nI]:cProductId, cTabWhere  )
				nTam := Len(oObj:oWSGETPRICERESULT:OWSPRICEVIEW)
				If lTabPv 
					cParam := cTabPv 
					For nX := 1 to nTam
						If oObj:oWSGETPRICERESULT:OWSPRICEVIEW[nX]:cpricetablecode == cParam
							If nI == Len( HttpSession->PWSV044GRAVA[2] )
								For nY := 1 To 4
									nDescont := &("HttpSession->PWSV044GRAVA[1]:NDISCOUNT"+Alltrim(Str(nY)))
									oObj:oWSGETPRICERESULT:OWSPRICEVIEW[nX]:nPrice := oObj:oWSGETPRICERESULT:OWSPRICEVIEW[nX]:nPrice-(oObj:oWSGETPRICERESULT:OWSPRICEVIEW[nX]:nPrice*(nDescont/100))							
								Next nY
								HttpSession->PWSV044GRAVA[2][nI]:nNETUNITPRICE := oObj:oWSGETPRICERESULT:OWSPRICEVIEW[nX]:nPrice
							EndIf	
							lAchou	:= .T.
							Exit
						EndIf
					Next nX
				EndIf
				
				If !lAchou .And. oCliente:GETCUSTOMER( cPwsUser, HttpSession->PWSV044GRAVA[1]:cCustomerCode )
					For nX := 1 to nTam
						If oObj:oWSGETPRICERESULT:OWSPRICEVIEW[nX]:cpricetablecode == oCliente:oWSGETCUSTOMERRESULT:cPriceTableCode
							If nI == Len( HttpSession->PWSV044GRAVA[2] )
								For nY := 1 To 4
									nDescont := &("HttpSession->PWSV044GRAVA[1]:NDISCOUNT"+Alltrim(Str(nY)))
									oObj:oWSGETPRICERESULT:OWSPRICEVIEW[nX]:nPrice := oObj:oWSGETPRICERESULT:OWSPRICEVIEW[nX]:nPrice-(oObj:oWSGETPRICERESULT:OWSPRICEVIEW[nX]:nPrice*(nDescont/100))							
								Next nY
								HttpSession->PWSV044GRAVA[2][nI]:nNETUNITPRICE := oObj:oWSGETPRICERESULT:OWSPRICEVIEW[nX]:nPrice
							EndIf	
							lAchou := .T.
							Exit
						EndIf
					Next nX
				EndIf
				
				If !lAchou 
					If lTabPad 
						cParam := cTabPad 
						For nX := 1 to nTam
							If oObj:oWSGETPRICERESULT:OWSPRICEVIEW[nX]:cpricetablecode == cParam
								If nI == Len( HttpSession->PWSV044GRAVA[2] )
									For nY := 1 To 4
										nDescont := &("HttpSession->PWSV044GRAVA[1]:NDISCOUNT"+Alltrim(Str(nY)))
										oObj:oWSGETPRICERESULT:OWSPRICEVIEW[nX]:nPrice := oObj:oWSGETPRICERESULT:OWSPRICEVIEW[nX]:nPrice-(oObj:oWSGETPRICERESULT:OWSPRICEVIEW[nX]:nPrice*(nDescont/100))							
									Next nY
									HttpSession->PWSV044GRAVA[2][nI]:nNETUNITPRICE := oObj:oWSGETPRICERESULT:OWSPRICEVIEW[nX]:nPrice
								EndIf	
								lAchou	:= .T.
								Exit
							EndIf
						Next nX
					EndIf	
				EndIf
				
				If !lAchou	.And. nTam > 0 .And. !(Empty(oObj:oWSGETPRICERESULT:OWSPRICEVIEW[1]:nPrice))
					If nI == Len( HttpSession->PWSV044GRAVA[2] )
						For nY := 1 To 4
							nDescont := &("HttpSession->PWSV044GRAVA[1]:NDISCOUNT"+Alltrim(Str(nY)))
							oObj:oWSGETPRICERESULT:OWSPRICEVIEW[1]:nPrice := oObj:oWSGETPRICERESULT:OWSPRICEVIEW[1]:nPrice-(oObj:oWSGETPRICERESULT:OWSPRICEVIEW[1]:nPrice*(nDescont/100))							
						Next nY
						HttpSession->PWSV044GRAVA[2][nI]:nNETUNITPRICE  := oObj:oWSGETPRICERESULT:OWSPRICEVIEW[1]:nPrice //B1_PRV1
					EndIf	
					lAchou := .T.
				EndIf
				
				If !lAchou .And. HttpSession->PWSV044GRAVA[2][nI]:nNETUNITPRICE == 0
					HttpSession->PWSV044GRAVA[2][nI]:nNETUNITPRICE  := 0
				ElseIf ValType(HttpSession->PWSV044GRAVA[2][nI]:nDiscountPercentage) <> "U" .And. HttpSession->PWSV044GRAVA[2][nI]:nDiscountPercentage > 0
					nVlrUnit	:= HttpSession->PWSV044GRAVA[2][nI]:nNETUNITPRICE 
					HttpSession->PWSV044GRAVA[2][nI]:nNETUNITPRICE := nVlrUnit - ( nVlrUnit * (HttpSession->PWSV044GRAVA[2][nI]:nDiscountPercentage / 100))  
				EndIf
				
			EndIf
		EndIf
		
	Next nI
EndIf

cHtml += " <script> $(document).ready( function() {"
cHtml += "	 window.location.href='#foo'});"
cHtml += " </script>"

cHtml += W_PWSV044()

Return cHtml

//-------------------------------------------------------------------
/*/{Protheus.doc} PWSCli044
Atribui a uma Se็ใo o cliente e loja selecionados

@author CRM/FAT

@since 24/08/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Web Function PWSCli044()
Local cHtml  := ""
	
WEB EXTENDED INIT cHtml START "InSite"
	
HttpSession->CODCLIERP := Alltrim(HttpPost->cCodCli + HttpPost->cCodLoj)

WEB EXTENDED END
	
Return cHtml

/*/{Protheus.doc} FatLibMetric
Fun็ใo utilizada para validar a data da LIB para ser utilizada na Telemetria
@type       Function
@author     CRM/Faturamento
@since      Outubro/2021
@version    12.1.27
@return     __lMetric, l๓gico, se a LIB pode ser utilizada para Telemetria
/*/
Static Function FatLibMetric()

If __lMetric == Nil 
	__lMetric := FWLibVersion() >= "20210517"
EndIf

Return __lMetric