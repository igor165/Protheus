#INCLUDE "PWSV050.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSV05*   บAutor  ณLuiz Felipe Couto    บ Data ณ  10/10/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Este fonte possui as funcionalidades relacionado ao         บฑฑ
ฑฑบ          ณ acompanhamento de pedidos de venda                          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบCleber M. ณ07/04/06ณ96290 ณRetirado o instanciamento de obj. da classe  บฑฑ
ฑฑบ          ณ        ณ      ณWSMTSELLERINVOICE devido a nenhum metodo des-บฑฑ
ฑฑบ          ณ        ณ      ณta classe estar sendo chamado no fonte.      บฑฑ
ฑฑบTatiana C.ณ01/02/07ณ118256ณIncluido o campo loja na consulta de pedidos บฑฑ
ฑฑบCleber M. ณ06/08/07ณ129977ณPassagem dos parametros Nome do WS e alias   บฑฑ
ฑฑบ          ณ        ณ      ณna GridLinesEx para contemplar os campos de  บฑฑ
ฑฑบ          ณ        ณ      ณusuario.                                     บฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSV050   บAutor  ณLuiz Felipe Couto    บ Data ณ  10/10/05   บฑฑ
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
Web Function PWSV050()

Local cHtml := ""					//Pagina HTML

WEB EXTENDED INIT cHtml START "InSite"

HttpPost->PWSV020VEN := GetUserVen()

HttpSession->PWSV020APH := { 	STR0001		,;			//Acompanhamento de Pedidos de Venda
								"W_PWSV051.APW"	,;			// Proxima Tela
								""	} 						// Msg de Erro

If Len( HttpPost->PWSV020VEN ) <= 1
	HttpSession->PWSV020APH[3] :=  STR0003					//Nao ha  vendedores a consultar

	cHtml += ExecInPage( "PWSV020" )
ElseIf Len(HttpPost->PWSV020VEN) = 2
	//Apenas 1 cliente. Define a navega็ใo para pular a tela de sele็ใo de cliente
	HttpPost->CODVENERP	:= HttpPost->PWSV020VEN[2][2]
	HttpSession->PWSV050ACO := "0"
	cHtml += W_PWSV051()
Else
	//Mais de 1 cliente? Chama tela de sele็ใo de CLientes
	cHtml += ExecInPage( "PWSV020" )
Endif

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSV051   บAutor  ณLuiz Felipe Couto    บ Data ณ  10/10/05   บฑฑ
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
Web Function PWSV051()

Local cHtml := ""		//Pagina Web
Local oObj				//Objeto WS - WSMTSELLERSALESORDER


WEB EXTENDED INIT cHtml START "InSite"

HttpSession->PWSV051APH 	:= { STR0001							,;	//Acompanhamento de Pedidos de Venda
								 "W_PWSV052.APW", "W_PWSV054.APW" }
HttpSession->cItens 		:= "00"

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTSELLERSALESORDER' ), WSMTSELLERSALESORDER():New() )
WsChgURL( @oObj, "MTSELLERSALESORDER.APW" )


If !Empty( HttpPost->CODVENERP )
	HttpSession->CODVENERP := HttpPost->CODVENERP
Endif

If Empty( HttpSession->PWSV052HEADER )
	HttpSession->PWSV052HEADER := { {}, {}, {} }
	
	If oObj:GETHEADER( "SALESORDERHEADERVIEW" )
		HttpSession->PWSV052HEADER[1] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
	Else
		Return PWSHtmlAlert( "", STR0005		,;	//Erro
							 "", "W_PWSV050.APW" )
	Endif

	If oObj:GETHEADER( "SALESORDERITEMVIEW" )
		HttpSession->PWSV052HEADER[2] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
	Else
		Return PWSHtmlAlert( "", STR0005		,;	//Erro
							 "", "W_PWSV050.APW" )
	Endif

	If oObj:GETHEADER( "SALESORDERRELEASE" )
		HttpSession->PWSV052HEADER[3] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
	Else
		Return PWSHtmlAlert( "", STR0005		,;	//Erro
							 "", "W_PWSV050.APW" )
	Endif
Endif

cHtml += ExecInPage( "PWSV051" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSV052   บAutor  ณLuiz Felipe Couto    บ Data ณ  10/10/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela de resultado da busca do pedido.                       บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบCleber M. ณ09/05/07ณ118256ณ- Correcao da busca por cliente/loja.        บฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Web Function PWSV052()

Local cHtml 	:= ""		//Pagina Web
Local oObj					//Objeto WS - WSMTSELLERSALESORDER
Local oObjTotalSO			//Objeto WS - WSMTSELLERSALESORDER
Local aWebCols 	:= {}		//Array com os campos a serem mostrados na tela

WEB EXTENDED INIT cHtml START "InSite"

oObj 		:= IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTSELLERSALESORDER' ), WSMTSELLERSALESORDER():New() )
oObjTotalSO := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTSELLERSALESORDER' ), WSMTSELLERSALESORDER():New() )

WsChgURL( @oObj, "MTSELLERSALESORDER.APW" )
WsChgURL( @oObjTotalSO, "MTSELLERSALESORDER.APW" )

HttpSession->PWSV052APH := { STR0006		,;	//Resultado da Busca
							 "W_PWSV053.APW" }

If Empty( HttpGet->cPagina )
	HttpGet->cPagina := "0"
Endif

If ( !Empty( HttpGet->dREGISTERDATEFROM ) .AND. !Empty( HttpGet->dREGISTERDATETO ) ) .OR. ;
	( !Empty( HttpGet->cBIDNUMBERFROM ) .AND. !Empty( HttpGet->cBIDNUMBERTO ) ) .OR.;
	( !Empty( HttpGet->cCUSTOMERTO ) .AND. !Empty( HttpGet->cCUSTOMERUNITTO ) ) 
	
	HttpPost->dREGISTERDATEFROM 	:= HttpGet->dREGISTERDATEFROM
	HttpPost->dREGISTERDATETO 		:= HttpGet->dREGISTERDATETO
	HttpPost->cBIDNUMBERFROM 		:= HttpGet->cBIDNUMBERFROM
	HttpPost->cBIDNUMBERTO 			:= HttpGet->cBIDNUMBERTO
	HttpPost->cCUSTOMERFROM 		:= HttpGet->cCUSTOMERFROM                      
	HttpPost->cCUSTOMERUNITFROM 	:= HttpGet->cCUSTOMERUNITFROM                      	
	HttpPost->cCUSTOMERTO 			:= HttpGet->cCUSTOMERTO	                       
	HttpPost->cCUSTOMERUNITTO 		:= HttpGet->cCUSTOMERUNITTO	  
	                     	
Endif

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
		oObj:cQUERYADDWHERE			:= "C5_CLIENTE >= '" + HttpPost->cCUSTOMERFROM+ "' AND "+"C5_CLIENTE <= '" + HttpPost->cCUSTOMERTO+ "' AND "+"C5_LOJACLI >= '" + HttpPost->cCUSTOMERUNITFROM+ "' AND "+"C5_LOJACLI <= '" + HttpPost->cCUSTOMERUNITTO+ "'"
		oObjTotalSO:cQUERYADDWHERE	:= "C5_CLIENTE >= '" + HttpPost->cCUSTOMERFROM+ "' AND "+"C5_CLIENTE <= '" + HttpPost->cCUSTOMERTO+ "' AND "+"C5_LOJACLI >= '" + HttpPost->cCUSTOMERUNITFROM+ "' AND "+"C5_LOJACLI <= '" + HttpPost->cCUSTOMERUNITTO+ "'"
	Else
		oObj:cQUERYADDWHERE			:= ""
		oObjTotalSO:cQUERYADDWHERE	:= ""
	Endif 
Endif

//cUSERCODE,cSELLERID,dREGISTERDATEFROM,dREGISTERDATETO,cBIDNUMBERFROM,cBIDNUMBERTO,cQUERYADDWHERE,cINDEXKEY,nPAGELEN,nPAGEFIRST
If oObj:BRWSALESORDER()
	If HttpPost->cBusca == "1" .OR. HttpPost->cBusca == "2"
		//cUSERCODE,cSELLERID,dREGISTERDATEFROM,dREGISTERDATETO,cBIDNUMBERFROM,cBIDNUMBERTO,cQUERYADDWHERE
		If oObjTotalSO:BRWTOTALSALESORDER()
			HttpSession->nTotalSO := oObjTotalSO:nBRWTOTALSALESORDERRESULT
		Else
			Return PWSHtmlAlert( "", STR0005		,;		//Erro
								 "", "W_PWSV050.APW" )
		Endif
	Endif

	HttpSession->PWSV052RESULT := { oObj:oWSBRWSALESORDERRESULT:oWSSALESORDERHEADERVIEW }
	HttpSession->PWSV052INFO := {}

	If ExistBlock( "PEV052" )
		aWebCols := ExecBlock( "PEV052", .F., .F., {} )
	Endif

	GridHeader(	HttpSession->PWSV052INFO, ;
				HttpSession->PWSV052HEADER[1][1], ;
				aWebCols, ;
				HttpSession->PWSV052RESULT[1] )

	GridLinesEx( {	HttpSession->PWSV052INFO, ;
					HttpSession->PWSV052HEADER[1][1], ;
					HttpSession->PWSV052RESULT[1], ;
					aWebCols, .F., "A",, 0 },;
					"MTSELLERSALESORDER", "SC5"  )
Else
	Return PWSHtmlAlert( "", STR0005		,;	//Erro
						 "", "W_PWSV050.APW" )
Endif

cHtml += ExecInPage( "PWSV052" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSV053   บAutor  ณLuiz Felipe Couto    บ Data ณ  10/10/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela de visualizacao do pedido.                             บฑฑ
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
Web Function PWSV053()

Local cHtml 	:= ""		//Pagina Web
Local oObj					//Objeto WS - WSMTSELLERSALESORDER
Local aWebCols 	:= {}		//Array com os campos a serem mostrados na tela

WEB EXTENDED INIT cHtml START "InSite"

HttpSession->PWSV053APH 	:= { STR0007				,;	//Pedido N๚mero :
							 + HttpGet->cPedido, "W_PWSV052.APW" }
HttpSession->PWSV053INFO 	:= { {}, {}, {} }

oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTSELLERSALESORDER' ), WSMTSELLERSALESORDER():New() )
WsChgUrl( @oObj, "MTSELLERSALESORDER.APW" )


oObj:cUSERCODE		:= GetUsrCode()
oObj:cSELLERCODE	:= HttpSession->CODVENERP
oObj:cORDERID		:= HttpGet->cPedido
oObj:cQUERYADDWHERE	:= ""

//cUSERCODE,cSELLERCODE,cORDERID,cQUERYADDWHERE
If oObj:GETSALESORDER()
	HttpSession->PWSV053RESULTSALESORDER := { oObj:oWSGETSALESORDERRESULT }
	
	aWebCols := {}

	If ExistBlock( "PEV053" )
		aWebCols := ExecBlock( "PEV053", .F., .F., { 1 } )
	Endif

	GridLinesEx( { HttpSession->PWSV053INFO[1]			,;
					HttpSession->PWSV052HEADER[1][1]	,;
					HttpSession->PWSV053RESULTSALESORDER[1]:oWSSOHEADER	,;
					aWebCols, .F., "H",, 0 }, "MTSELLERSALESORDER", "SC5" )
					
	aWebCols := {}

	If ExistBlock( "PEV053" )
		aWebCols := ExecBlock( "PEV053", .F., .F., { 2 } )
	Endif

	GridHeader(		HttpSession->PWSV053INFO[2]			,;
					HttpSession->PWSV052HEADER[2][1]	,;
					aWebCols							,;
					HttpSession->PWSV053RESULTSALESORDER[1]:oWSSOITEM:oWSSALESORDERITEMVIEW, "MTSELLERSALESORDER", "SC6" )

	GridLinesEx( { HttpSession->PWSV053INFO[2]			,;
					HttpSession->PWSV052HEADER[2][1]	,;
					HttpSession->PWSV053RESULTSALESORDER[1]:oWSSOITEM:oWSSALESORDERITEMVIEW, ;
					aWebCols							,;
					.F.									,;
					"A"									,;
					NIL									,;
					0 }, "MTSELLERSALESORDER", "SC6" )
Else
	Return PWSHtmlAlert( "", STR0005		,;	//Erro
						 "", "W_PWSV050.APW" )
Endif

oObj:cUSERCODE		:= GetUsrCode()
oObj:cSELLERCODE	:= HttpSession->CODVENERP
oObj:cORDERID		:= HttpGet->cPedido

//cUSERCODE,cSELLERCODE,cORDERID,cQUERYADDWHERE
If oObj:GETRELEASE()
	HttpSession->PWSV053RESULTRELEASE := { oObj:oWSGETRELEASERESULT:oWSSALESORDERRELEASE }
	
	aWebCols := {}

	If ExistBlock( "PEV053" )
		aWebCols := ExecBlock( "PEV053", .F., .F., { 3 } )
	Endif

	GridHeader(		HttpSession->PWSV053INFO[3]			,;
					HttpSession->PWSV052HEADER[3][1]	,;
					aWebCols							,;
					HttpSession->PWSV053RESULTRELEASE[1] )

	GridLinesEx( { HttpSession->PWSV053INFO[3]				,;
					HttpSession->PWSV052HEADER[3][1]		,;
					HttpSession->PWSV053RESULTRELEASE[1]	,;
					aWebCols								,;
					.F.										,;
					"A"										,;
					NIL										,;
					0 }, "MTSELLERSALESORDER", "SC9"  )
Else
	Return PWSHtmlAlert( "", STR0005		,;		//Erro
						 "", "W_PWSV050.APW" )
Endif

cHtml += ExecInPage( "PWSV053" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSV053A  บAutor  ณLuiz Felipe Couto    บ Data ณ  10/10/05   บฑฑ
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
Web Function PWSV053A()

Local cHtml 	:= ""		//Pagina WEB

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage( "PWSV053A" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSV053B  บAutor  ณLuiz Felipe Couto    บ Data ณ  10/10/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela de visualizacao das liberacoes do pedido de venda      บฑฑ
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
Web Function PWSV053B()

Local cHtml 	:= ""		//Pagina WEB

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage( "PWSV053B" )

WEB EXTENDED END

Return cHtml
