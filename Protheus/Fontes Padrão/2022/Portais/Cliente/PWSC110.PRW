#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
#INCLUDE "PWSC110.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSC11*   บAutor  ณLuiz Felipe Couto    บ Data ณ  27/06/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Este fonte possui as funcionalidades relacionado aos        บฑฑ
ฑฑบ          ณ documentos fiscais.                                         บฑฑ
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
ฑฑบPrograma  ณPWSC110   บAutor  ณLuiz Felipe Couto    บ Data ณ  27/06/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Mostra os clientes disponiveis para o usuario logado.       บฑฑ
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
Web Function PWSC110()

Local cHtml 	:= ""					//Pagina WEB

WEB EXTENDED INIT cHtml START "InSite"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณClientes cadastrados para o usuario logadoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
HttpPost->PWSC020CLI := GetUserCli()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInformacoes a serem utilizadas pelo APHณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
HttpSession->PWSC020APH	:= { 	STR0001 ,;                      //	"Documentos Fiscais"
								"W_PWSC111.APW"		,;			//Pagina para onde sera enviado o POST
								"" }							//Mensagem a ser mostrada na tela
	
Do Case
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณNao ha clientes cadastrados para o usuario logadoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Case Empty( HttpPost->PWSC020CLI )
		HttpSession->PWSC020APH[3] := STR0002					//"Nใo hแ clientes a consultar."
		
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณApenas 1 cliente cadastradoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Case Len( HttpPost->PWSC020CLI ) == 2
		HttpSession->CODCLIERP := HttpPost->PWSC020CLI[2][2]

		Return W_PWSC111()

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณMais de 1 clienteณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Otherwise
		cHtml += ExecInPage( "PWSC020" )

EndCase

cHtml += ExecInPage( "PWSC020" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSC111   บAutor  ณLuiz Felipe Couto    บ Data ณ  27/06/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela de busca de documentos fiscais para o cliente selecio- บฑฑ
ฑฑบ          ณ nado.                                                       บฑฑ
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
Web Function PWSC111()

Local cHtml 	:= ""						//Pagina WEB
Local aWebCols	:= {}						//Campos a serem mostrados na tela
Local oObj									//Objeto WS - WSMTCUSTOMERINVOICE
Local oObjCustomer							//Objeto WS - WSMTCUSTOMER
Local oObjSupplier							//Objeto WS - WSMTSUPPLIER
Local oObjIndex								//Obejto WS - WSCFGDICTIONARY

WEB EXTENDED INIT cHtml START "InSite"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPreenche a Session do Codigo do Cliente com o Post da selecao de Clientesณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If !Empty( HttpPost->CODCLIERP )
	HttpSession->CODCLIERP := HttpPost->CODCLIERP
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInformacoes a serem utilizadas pelo APHณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
HttpSession->PWSC111APH := { STR0001 , "W_PWSC112.APW" }      	//"Documentos Fiscais"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInicializa o objeto WS - WSMTCUSTOMERINVOICEณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTCUSTOMERINVOICE' ), WSMTCUSTOMERINVOICE():New() )
WsChgUrl( @oObj, "MTCUSTOMERINVOICE.APW" )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInicializa o objeto WS - WSMTCUSTOMERณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oObjCustomer := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTCUSTOMER' ), WSMTCUSTOMER():New() )
WsChgUrl( @oObjCustomer, "MTCUSTOMER.APW" )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInicializa o objeto WS - WSMTSUPPLIERณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oObjSupplier := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTSUPPLIER' ), WSMTSUPPLIER():New() )
WsChgUrl( @oObjSupplier, "MTSUPPLIER.APW" )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInicializa o objeto WS - WSCFGDICTIONARYณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oObjIndex := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSCFGDICTIONARY' ), WSCFGDICTIONARY():New() )
WsChgUrl( @oObjIndex, "CFGDICTIONARY.APW" )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณArray contendo os headers dos WS utilizados nesta paginaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Empty( HttpSession->PWSC111HEADER )
	HttpSession->PWSC111HEADER := { 	NIL, NIL, NIL, NIL,;
										NIL, NIL, NIL, NIL,;
										NIL, NIL, NIL, NIL }

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณHeader da estrutura INVOICEHEADERVIEW - Cabecalho da Notaณ
	//ณ- SERIALNUMBER   : Serie                                 ณ
	//ณ- INVOICENUMBER  : Numero                                ณ
	//ณ- DOCUMENTTYPE   : Tipo do Documento                     ณ
	//ณ- INVOICETYPE    : Tipo da Nota                          ณ
	//ณ- REGISTERDATE   : Data de Emissao                       ณ
	//ณ- INVOICEDATE    : Data da Nota                          ณ
	//ณ- EXPENSESVALUE  : Valor                                 ณ
	//ณ- INSURANCEVALUE : Valor do Seguro                       ณ
	//ณ- FREIGHTVALUE   : Valor do Frete                        ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณParametros do metodo GETHEADERณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oObj:cHEADERTYPE := "INVOICEHEADERVIEW"

	//cHEADERTYPE
	If oObj:GETHEADER()
		HttpSession->PWSC111HEADER[1] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
	Else
		Return PWSHTMLALERT( "", STR0007, "", "PWSC110.APW" )      	//Atencao
	Endif
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณHeader da estrutura INVOICEITEMVIEW - Item da Notaณ
	//ณ- SEQUENTIALID       : Item                       ณ
	//ณ- PRODUCTCODE        : Codigo do Produto          ณ
	//ณ- DESCRIPTIONPRODUCT : Descricao do Produto       ณ
	//ณ- MEASUREUNIT        : Unidade de Medida          ณ
	//ณ- QUANTITY           : Quantidade                 ณ
	//ณ- UNITPRICE          : Preco unitario             ณ
	//ณ- TOTALVALUE         : Valor Total                ณ
	//ณ- DISCOUNTPERCENT    : Porcentagem de Desconto    ณ
	//ณ- DISCOUNTVALUE      : Valor de Desconto          ณ
	//ณ- EXPENSESVALUE      : Valor de Despesas          ณ
	//ณ- INSURANCEVALUE     : Valor de Seguro            ณ
	//ณ- FREIGHTVALUE       : Valor do Frete             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oObj:cHEADERTYPE := "INVOICEITEMVIEW"

	//cHEADERTYPE
	If oObj:GETHEADER()
		HttpSession->PWSC111HEADER[2] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
	Else
		Return PWSHTMLALERT( "", STR0007, "", "PWSC110.APW" )     		//Atencao
	Endif

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณHeader da estrutura GENERICSTRUCT - Estrutura Genericaณ
	//ณ- CODE        : Codigo                                ณ
	//ณ- DESCRIPTION : Descricao                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oObj:cHEADERTYPE := "GENERICSTRUCT"

	//cHEADERTYPE
	If oObj:GETHEADER()
		HttpSession->PWSC111HEADER[3] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
	Else
		Return PWSHTMLALERT( "", STR0007, "", "PWSC110.APW" )        //Atencao
	Endif

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณHeader da estrutura TAXESVIEW - Impostoณ
	//ณ- TAXCODE   : Codigo                   ณ
	//ณ- TAXBASE   : Base                     ณ
	//ณ- TAXRATE   : Aliquota                 ณ
	//ณ- TAXAMOUNT : Valor                    ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oObj:cHEADERTYPE := "TAXESVIEW"

	//cHEADERTYPE
	If oObj:GETHEADER()
		HttpSession->PWSC111HEADER[4] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
	Else
		Return PWSHTMLALERT( "", STR0007, "", "PWSC110.APW" )           //Atencao
	Endif

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณHeader da estrutura BILLVIEW - Titulo        ณ
	//|- PREFIX                : Prefixo            |
	//|- BILLNUMBER	           : Numero             |
	//|- INSTALLMENT           : Parcela            |
	//|- BILLTYPE              : Tipo               |
	//|- CLASSCODE             : Natureza           |
	//|- ISSUEDATE             : Data de Emissao    |
	//|- ORIGINALDUEDATE       : Data Original      |
	//|- REALDUEDATE           : Data Real          |
	//|- CURRENCY              : Moeda              |
	//|- CURRENCYSIMBOL        : Simbolo da Moeda   |
	//|- ORIGINALVALUE         : Valor Original     |
	//|- ORIGINALCURRENCYVALUE : VlCruz             |
	//|- DEDUCTIONSVALUE       : Abatimento         |
	//|- INCREASEVALUE         : Saldo do Decrescimo|
	//|- BALANCEVALUE          : Saldo              |
	//|- BALANCECURRENCYVALUE  : Saldo              |
	//|- BANK                  : Banco              |
	//|- HISTORY               : Historico          |
	//|- DELAYINDAYS           : Atraso             |
	//|- DAYLYINTERESTRATE     : Porcentagem Juros  |
	//|- DAYLYINTERESTVALUE    : Valor Juros        |
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณParametros do metodo GETHEADERณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oObj:cHEADERTYPE := "BILLVIEW"

	//cHEADERTYPE
	If oObj:GETHEADER()
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณRetorno do Metodo GETHEADERณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		HttpSession->PWSC111HEADER[5] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
	Else
		Return PWSHtmlAlert( "", STR0007, "", "W_PWSC110.APW" )     			//Atencao
	Endif

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณHeader da estrutura SALESORDERITEMVIEW - Item do Pedido de Vendaณ
	//ณ- ORDERID                    : Numero do Pedido                 ณ
	//ณ- ORDERITEM                  : Item                             ณ
	//ณ- PRODUCTID                  : Codigo do Produto                ณ
	//ณ- UNITOFMEASURE              : Unidade de Medida                ณ
	//ณ- QUANTITY                   : Quantidade                       ณ
	//ณ- NETUNITPRICE               : Valor Unitario                   ณ
	//ณ- NETTOTAL                   : Valor Total                      ณ
	//ณ- QUANTITYAPPROVED           : Qtd. Liberada                    ณ
	//ณ- QUANTITYRELEASEDSECONDUNIT : Seg. Unid. de Medida Qtde. Lib.  ณ
	//ณ- SECONDUNITOFMEASURE        : Segunda Unid. de Medida          ณ
	//ณ- ITEMOUTFLOWTYPE            : TES                              ณ
	//ณ- SECONDMEASUREUNITQUANTITY  : Segunda Unid. de Medida Qtde.    ณ
	//ณ- WAREHOUSE                  : Armazem                          ณ
	//ณ- FISCALOPERATION            : CF                               ณ
	//ณ- DISCOUNTPERCENTAGE         : Porcentagem de Desconto          ณ
	//ณ- ITEMDISCOUNTVALUE          : Valor do Desconto no Item        ณ
	//ณ- DELIVERYDATE               : Data de Entreda                  ณ
	//ณ- CUSTOMERORDERNUMBER        : Pedido do Cliente                ณ
	//ณ- PRODUCTDESCRIPTION         : Descricao do Produto             ณ
	//ณ- UNITLISTPRICE              : Preco de Lista                   ณ
	//ณ- ORIGINALINVOICE            : Nota Original                    ณ
	//ณ- ORIGINALINVOICESERIALID    : Serie Original                   ณ
	//ณ- ORIGINALINVOICEITEM        : Item da Nota                     ณ
	//ณ- LOTNUMBER                  : Lote                             ณ
	//ณ- SUBLOT                     : Sub-Lote                         ณ
	//ณ- LOCATION                   : Localizacao                      ณ
	//ณ- PRODUCTSERIALNUMBER        : Cod. De Barras                   ณ
	//ณ- MANUFACTURERCODE           : Cod. do Fabricante               ณ
	//ณ- MANUFACTURERUNIT           : Loja do Fabricante               ณ
	//ณ- OPERATIONTYPE              : Tipo de Operacao                 ณ
	//ณ- POID                       : ID PO                            ณ
	//ณ- POITEM                     : Item do PO                       ณ
	//ณ- POSEQUENCE                 : Sequencia do PO                  ณ
	//ณ- POGRADEITEM                : Item de Grade do PO              ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณParametros do metodo GETHEADERณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oObj:cHEADERTYPE := "SALESORDERITEMVIEW"

	//cHEADERTYPE
	If oObj:GETHEADER()
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณRetorno do Metodo GETHEADERณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		HttpSession->PWSC111HEADER[6] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
	Else
		Return PWSHtmlAlert( "", STR0007, "", "W_PWSC110.APW" )             //Atencao
	Endif

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณHeader da estrutura LOTVIEW - Loteณ
	//ณ- LOTNUMBER    : Numero           ณ
	//ณ- POTENCYLOT   : Lote em Potencialณ
	//ณ- VALIDITYDATE : Data de Validade ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณParametros do metodo GETHEADERณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oObj:cHEADERTYPE := "LOTVIEW"

	//cHEADERTYPE
	If oObj:GETHEADER()
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณRetorno do Metodo GETHEADERณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		HttpSession->PWSC111HEADER[7] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
	Else
		Return PWSHtmlAlert( "", STR0007, "", "W_PWSC110.APW" )             //atencao
	Endif

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณHeader da estrutura CUSTOMERVIEW - Clienteณ
	//ณ- CUSTOMERCODE     : Codigo               ณ
	//ณ- UNITCUSTOMERCODE : Loja                 ณ
	//ณ- NAME             : Nome                 ณ
	//ณ- NICKNAME         : Nome Reduzido        ณ
	//ณ- FEDERALID        : CPF/CGC              ณ
	//ณ- STATEID          : Inscr. Estadual      ณ
	//ณ- DISTRICTID       : Inscr. Municipal     ณ
	//ณ- HOMEPAGE         : Home-Page            ณ
	//ณ- EMAIL            : E-mail               ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณParametros do metodo GETHEADERณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oObjCustomer:cHEADERTYPE := "CUSTOMERVIEW"

	//cHEADERTYPE
	If oObjCustomer:GETHEADER()
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณRetorno do Metodo GETHEADERณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		HttpSession->PWSC111HEADER[8] := { oObjCustomer:oWSGETHEADERRESULT:oWSBRWHEADER }
	Else
		Return PWSHtmlAlert( "", STR0007, "", "W_PWSC110.APW" )             //atencao
	Endif

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณHeader da estrutura SUPPLIERVIEW - Vendedorณ
	//ณ- SUPPLIERCODE     : Codigo                ณ
	//ณ- UNITSUPPLIERCODE : Loja                  ณ
	//ณ- NAME             : Nome                  ณ
	//ณ- NICKNAME         : Nome Reduzido         ณ
	//ณ- FEDERALID        : CPF/CGC               ณ
	//ณ- STATEID          : Inscr. Estadual       ณ
	//ณ- DISTRICTID       : Inscr. Municipal      ณ
	//ณ- HOMEPAGE         : Home-Page             ณ
	//ณ- EMAIL            : E-mail                ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณParametros do metodo GETHEADERณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oObjSupplier:cHEADERTYPE := "SUPPLIERVIEW"

	//cHEADERTYPE
	If oObjSupplier:GETHEADER()
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณRetorno do Metodo GETHEADERณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		HttpSession->PWSC111HEADER[9] := { oObjSupplier:oWSGETHEADERRESULT:oWSBRWHEADER }
	Else
		Return PWSHtmlAlert( "", STR0007, "", "W_PWSC110.APW" )               //atencao
	Endif

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณHeader da estrutura ADDRESSVIEW - Enderecoณ
	//ณ- ADDRESS       : Endereco                ณ
	//ณ- ADDRESSNUMBER : Numero                  ณ
	//ณ- DISTRICT      : Municipio               ณ
	//ณ- STATE         : Estado                  ณ
	//ณ- ZIPCODE       : CEP                     ณ
	//ณ- ZONE          : Bairro                  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณParametros do metodo GETHEADERณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oObjCustomer:cHEADERTYPE := "ADDRESSVIEW"

	//cHEADERTYPE
	If oObjCustomer:GETHEADER()
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณRetorno do Metodo GETHEADERณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		HttpSession->PWSC111HEADER[10] := { oObjCustomer:oWSGETHEADERRESULT:oWSBRWHEADER }
	Else
		Return PWSHtmlAlert( "", STR0007, "", "W_PWSC110.APW" )                  //atencao
	Endif

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณHeader da estrutura PHONEVIEW - Telefoneณ
	//ณ- COUNTRYAREACODE : DDI                 ณ
	//ณ- LOCALAREACODE   : DDD                 ณ
	//ณ- PHONENUMBER     : Telefone            ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณParametros do metodo GETHEADERณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oObjCustomer:cHEADERTYPE := "PHONEVIEW"

	//cHEADERTYPE
	If oObjCustomer:GETHEADER()
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณRetorno do Metodo GETHEADERณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		HttpSession->PWSC111HEADER[11] := { oObjCustomer:oWSGETHEADERRESULT:oWSBRWHEADER }
	Else
		Return PWSHtmlAlert( "", STR0007, "", "W_PWSC110.APW" )                 // atencao
	Endif

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณHeader da estrutura do WS CFGDICTIONARYณ
	//|- CODE        : Ordem                  |
	//|- DESCRIPTION : Chave                  |
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If oObjIndex:GETHEADER()
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณRetorno do Metodo GETHEADERณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		HttpSession->PWSC111HEADER[12] := { oObjIndex:oWSGETHEADERRESULT:oWSBRWHEADER }
	Else
		Return PWSHtmlAlert( "", STR0007, "", "W_PWSC110.APW" )                 //atencao
	Endif
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณIndices da Tabela SF2ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Empty( HttpSession->PWSC111INDEX )
	HttpSession->PWSC111INDEX := {}
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณParametros do metodo GETINDEXณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oObjIndex:cUSERCODE 	:= GetUsrCode()
	oObjIndex:cTABLE 		:= "SF2"
	
	//cUSERCODE,cTABLE
	If oObjIndex:GETINDEX()
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณResultado do Metodo GETINDEXณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		HttpSession->PWSC111INDEX := { oObjIndex:oWSGETINDEXRESULT:oWSGENERICSTRUCT }
	Else
		Return PWSHTMLALERT( "", STR0007, "", "W_PWSC110.APW" )             //atencao
	EndIf
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDados para montagem do campo de Ordemณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If Empty( HttpSession->PWSC111INFO )
	HttpSession->PWSC111INFO := {}

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPonto de Entrada - Campos do WS WSCFGDICTIONARYณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If ExistBlock( "PEC111" )
		aWebCols := ExecBlock( "PEC111", .F., .F., {} )
	Else
		aAdd( aWebCols, "CODE" )
		aAdd( aWebCols, "DESCRIPTION" )
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณFuncao de montagem da descricao dos campos da telaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
   	GridHeader( HttpSession->PWSC111INFO, HttpSession->PWSC111HEADER[12][1], aWebCols )
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณFuncao de montagem dos campos da telaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	GridLinesEx( { 	HttpSession->PWSC111INFO		, HttpSession->PWSC111HEADER[12][1],;
					HttpSession->PWSC111INDEX[1]	, aWebCols							,;
					.F., "A",, 0 } )
EndIf

cHtml += ExecInPage( "PWSC111" )

WEB EXTENDED END

Return cHtml 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSC112   บAutor  ณLuiz Felipe Couto    บ Data ณ  27/06/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela com o retorno da busca dos documentos fiscais para o   บฑฑ
ฑฑบ          ณ cliente selecionado.                                        บฑฑ
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
Web Function PWSC112()

Local cHtml 	:= ""						//Pagina WEB
Local aWebCols 	:= {}						//Campos a serem mostrados na tela
Local oObj									//Objeto WS - WSMTCUSTOMERINVOICE

WEB EXTENDED INIT cHtml START "InSite"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInformacoes a serem mostradas na telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
HttpSession->PWSC112APH := { STR0021	, ;                     //"Documentos Fiscais - Resultado da Busca DOCUMENTOS FISCAIS"
								"W_PWSC113.APW", ;				//Pagina para onde sera enviado o POST
								"W_PWSC111.APW" }				//Pagina de Volta

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณArray para montagem da telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
HttpSession->PWSC112INFO := {}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInicializa o objeto WS - WSMTCUSTOMERINVOICEณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTCUSTOMERINVOICE' ), WSMTCUSTOMERINVOICE():New() )
WsChgURL( @oObj, "MTCUSTOMERINVOICE.APW" )

If ExistBlock( "PEC112" )
	aWebCols := ExecBlock( "PEC112", .F., .F., {} )
Else
	aAdd( aWebCols, "INVOICENUMBER" ) 
	aAdd( aWebCols, "SERIALNUMBER" )  
	aAdd( aWebCols, "INVOICETYPE" )   
	aAdd( aWebCols, "DOCUMENTTYPE" )
	aAdd( aWebCols, "INVOICEDATE" )
	aAdd( aWebCols, "EXPENSESVALUE" )
	aAdd( aWebCols, "FREIGHTVALUE" )
	aAdd( aWebCols, "INSURANCEVALUE" )
	aAdd( aWebCols, "TOTALVALUE" )
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณParametros do metodo BRWINVOICEณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oObj:cUSERCODE				:= GetUsrCode()
oObj:nCUSTOMERORSUPPLIER	:= 1
oObj:cCUSTOMERORSUPPLIERID	:= HttpSession->CODCLIERP
oObj:dREGISTERDATEFROM 		:= CToD( HttpPost->dREGISTERDATEFROM )
oObj:dREGISTERDATETO 		:= CToD( HttpPost->dREGISTERDATETO )
oObj:dDELIVERYDATEFROM 		:= CToD( HttpPost->dDELIVERYDATEFROM )
oObj:dDELIVERYDATETO 		:= CToD( HttpPost->dDELIVERYDATETO )

//cUSERCODE,nCUSTOMERORSUPPLIER,cCUSTOMERORSUPPLIERID,dREGISTERDATEFROM,dREGISTERDATETO,dDELIVERYDATEFROM,dDELIVERYDATETO,cQUERYADDWHERENFE,cQUERYADDWHERENFS,cINDEXKEYNFE,cINDEXKEYNFS,cPURCHASENUMBER
If oObj:BRWINVOICE()
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณRetorno do metodo BRWINVOICEณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	HttpSession->PWSC112RESULT := { oObj:oWSBRWINVOICERESULT:oWSINVOICEHEADERVIEW }

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณFuncao de montagem da descricao dos campos da telaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
   	GridHeader( HttpSession->PWSC112INFO, HttpSession->PWSC111HEADER[1][1], aWebCols )

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณFuncao de montagem dos campos da telaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	GridLinesEx( {	HttpSession->PWSC112INFO		, HttpSession->PWSC111HEADER[1]	[1]	,;
					HttpSession->PWSC112RESULT[1] 	, aWebCols							,;
					.F., "A",, 0 },	"MTCUSTOMERINVOICE", "SF2" )
Else
	Return PWSHTMLALERT( "", STR0007, "", "W_PWSC111.APW" )                   //atencao
EndIf  

cHtml += ExecInPage( "PWSC112" )

WEB EXTENDED END

Return cHtml     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSC113   บAutor  ณLuiz Felipe Couto    บ Data ณ  27/06/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela com o cabecalho e o item da nota.                      บฑฑ
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
Web Function PWSC113()

Local cHtml 	:= ""						//Pagina WEB
Local nPosNota	:= 0						//Posicao da Nota no array de notas
Local aWebCols 	:= {}						//Campos a serem mostrados na tela
Local oObj									//Objeto WS - WSMTCUSTOMERINVOICE

WEB EXTENDED INIT cHtml START "InSite"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPosicao da nota no array de notasณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nPosNota := Val( HttpGet->cNota )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInformacoes a serem mostradas na telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
HttpSession->PWSC113APH := { 	STR0001 + 	HttpSession->PWSC112RESULT[1][nPosNota]:cSERIALNUMBER +;                     //"Documentos Fiscais - Documento Fiscal : "
																				HttpSession->PWSC112RESULT[1][nPosNota]:cINVOICENUMBER +;
																				HttpSession->PWSC112RESULT[1][nPosNota]:cINVOICETYPE, ;
								STR0031, ;
								"W_PWSC114.APW?cNota=" + HttpGet->cNota,;				//Pagina de Origem/Destino
								"W_PWSC115.APW?cNota=" + HttpGet->cNota,;				//Pagina de Tranportadora
								"W_PWSC116.APW?cNota=" + HttpGet->cNota,;				//Pagina de Impostos
								"W_PWSC117.APW?cNota=" + HttpGet->cNota,;				//Pagaina de Volumes
								"W_PWSC118.APW?cNota=" + HttpGet->cNota,;				//Pagaina de Pagamentos
								"W_PWSC111.APW" }										//Pagina de Volta

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInformacoes dos campos que seram mostrados na telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
HttpSession->PWSC113INFO := { {}, {} }

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInicializa o objeto WS - WSMTCUSTOMERINVOICEณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTCUSTOMERINVOICE' ), WSMTCUSTOMERINVOICE():New() )
WsChgURL( @oObj, "MTCUSTOMERINVOICE.APW" )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณParametros do metodo GETINVOICEณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oObj:cUSERCODE				:= GetUsrCode()
oObj:cINVOICETYPE			:= HttpSession->PWSC112RESULT[1][nPosNota]:cINVOICETYPE
oObj:cSERIALNUMBER			:= HttpSession->PWSC112RESULT[1][nPosNota]:cSERIALNUMBER
oObj:cINVOICENUMBER			:= HttpSession->PWSC112RESULT[1][nPosNota]:cINVOICENUMBER
oObj:cDOCUMENTTYPE			:= HttpSession->PWSC112RESULT[1][nPosNota]:cDOCUMENTTYPE
oObj:nCUSTOMERORSUPPLIER	:= 1
oObj:cCUSTOMERORSUPPLIERID	:= HttpSession->CODCLIERP

//cUSERCODE,cINVOICETYPE,cSERIALNUMBER,cINVOICENUMBER,cDOCUMENTTYPE,nCUSTOMERORSUPPLIER,cCUSTOMERORSUPPLIERID,cQUERYADDWHERENFE,cQUERYADDWHERENFS
If oObj:GETINVOICE()
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณRetorno do Metodo GETINVOICEณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	HttpSession->PWSC113RESULT := { oObj:oWSGETINVOICERESULT }

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPonto de Entrada - Cabecalho da Notaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If ExistBlock( "PEC113" )
		aWebCols := ExecBlock( "PEC113", .F., .F., { 1 } )
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณFuncao de montagem da descricao dos campos da telaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	GridLinesEx( { 	HttpSession->PWSC113INFO[1]						, HttpSession->PWSC111HEADER[1][1]	,;
					HttpSession->PWSC113RESULT[1]:oWSINVOICEHEADER	, aWebCols							,;
					.F., "H",, 0 },	"MTCUSTOMERINVOICE", "SF2" )

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPonto de Entrada - Item da Notaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If ExistBlock( "PEC113" )
		aWebCols := ExecBlock( "PEC113", .F., .F., { 2 } )
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณFuncao de montagem da descricao dos campos da telaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	GridHeader(	HttpSession->PWSC113INFO[2], HttpSession->PWSC111HEADER[2][1] )
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณFuncao de montagem da descricao dos campos da telaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	GridLinesEx( { 	HttpSession->PWSC113INFO[2]										, HttpSession->PWSC111HEADER[2][1]	,;
					HttpSession->PWSC113RESULT[1]:oWSINVOICEITEM:oWSINVOICEITEMVIEW	, aWebCols							,;
					.F., "A",, 0 },	"MTCUSTOMERINVOICE", "SD2" )
	
Else
	Return PWSHTMLALERT( "", STR0007, "", "PWSC112.APW" )      			//atencao
Endif


cHtml += ExecInPage( "PWSC113" )

WEB EXTENDED END

Return cHtml     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSC113A  บAutor  ณLuiz Felipe Couto    บ Data ณ  27/06/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela com o item da nota.                                    บฑฑ
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
Web Function PWSC113A()

Local cHtml 	:= ""						//Pagina WEB

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage( "PWSC113A" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSC113B  บAutor  ณLuiz Felipe Couto    บ Data ณ  01/07/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela com o imposto do item do documento fiscal.             บฑฑ
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
Web Function PWSC113B()

Local cHtml 	:= ""				//Pagina WEB
Local nItem		:= 0				//Item do documento fiscal

WEB EXTENDED INIT cHtml START "InSite"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPosicao do item no array de de itens do documento fiscalณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nItem := Val( HttpGet->cItem )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInformacoes a serem mostradas na telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
HttpSession->PWSC113BAPH := { 	STR0015 + HttpSession->PWSC113RESULT[1]:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nItem]:cSEQUENTIALID,;       //"Documentos Fiscais - Impostos do Item : "
								"W_PWSC113C.APW?cNota=" + HttpGet->cNota + "&cItem=" + HttpGet->cItem,;
								"W_PWSC113.APW?cNota=" + HttpGet->cNota }

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInformacoes dos campos a serem mostrados na telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
HttpSession->PWSC113BINFO := {}

If Len( HttpSession->PWSC113RESULT[1]:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nItem]:oWSTAXES:oWSTAXESVIEW ) == 0
	Return PWSHtmlAlert( "", STR0007, STR0016, "W_PWSC113.APW?cNota=" + HttpGet->cNota )     //"Aten็ใo"  /"Nใo hแ impostos para este item deste documento fiscal."
Endif


cHtml += ExecInPage( "PWSC113B" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSC113C  บAutor  ณLuiz Felipe Couto    บ Data ณ  01/07/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela de visualizacao dos impostos do item da nota.          บฑฑ
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
Web Function PWSC113C()

Local cHtml 	:= ""				//Pagina WEB
Local nItem		:= ""				//Item do documento fiscal
Local aWebCols 	:= {}				//Campos a serem mostrados na tela

WEB EXTENDED INIT cHtml START "InSite"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPosical do item no array de itens do documento fiscalณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nItem := Val( HttpGet->cItem )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ<ฟ
//ณInformacoes dos campos a serem mostrados na telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ<ู
HttpSession->PWSC113CINFO := {}

If ExistBlock( "PEC113C" )
	aWebCols := ExecBlock( "PEC113C", .F., .F. )
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDescricao dos campos a serem mostrados na telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
GridHeader( HttpSession->PWSC113CINFO, HttpSession->PWSC111HEADER[4][1], aWebCols )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCampos a serem mostrados na telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
GridLinesEx( { 	HttpSession->PWSC113CINFO																		, HttpSession->PWSC111HEADER[4][1]	,;
				HttpSession->PWSC113RESULT[1]:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nItem]:oWSTAXES:oWSTAXESVIEW	, aWebCols							,;
				.F., "A",, 0 } )

cHtml += ExecInPage( "PWSC113C" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSC113D  บAutor  ณLuiz Felipe Couto    บ Data ณ  01/07/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela com o lote do item do documento fiscal.                บฑฑ
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
Web Function PWSC113D()

Local cHtml 	:= ""				//Pagina WEB
Local nItem		:= 0				//Item do documento fiscal
Local aWebCols	:= {}				//Campos a serem mostrados na tela

WEB EXTENDED INIT cHtml START "InSite"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPosicao do item no array de itens do documento fiscalณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nItem := Val( HttpGet->cItem )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInformacoes a serem mostrados na telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
HttpSession->PWSC113DAPH := { 	STR0022 + HttpSession->PWSC113RESULT[1]:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nItem]:cSEQUENTIALID,;            //"Documentos Fiscais - Lote do Item : "
								"W_PWSC113.APW?cNota=" + HttpGet->cNota }

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInformacoes dos campos a serem mostrados na telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
HttpSession->PWSC113DINFO := {}

If ExistBlock( "PEC113D" )
	aWebCols := ExecBlock( "PEC113D", .F., .F. )
EndIf

If HttpSession->PWSC113RESULT[1]:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nItem]:oWSLOTIDENTIFIER <> NIL
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCampos a serem mostrados na telaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	GridLinesEx( { 	HttpSession->PWSC113DINFO																	, HttpSession->PWSC111HEADER[7][1]	,;
					HttpSession->PWSC113RESULT[1]:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nItem]:oWSLOTIDENTIFIER	, aWebCols							,;
					.F., "H",, 0 } )
Else
	Return PWSHtmlAlert( "", STR0007, STR0005, "W_PWSC113.APW?cNota=" + HttpGet->cNota )         //atencao   /"Nใo hแ lote para este item deste documento fiscal."
Endif


cHtml += ExecInPage( "PWSC113D" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSC113E  บAutor  ณLuiz Felipe Couto    บ Data ณ  01/07/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela com o pedido de venda do item do documento fiscal.     บฑฑ
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
Web Function PWSC113E()

Local cHtml 	:= ""				//Pagina WEB
Local nItem		:= 0				//Item do documento fiscal
Local aWebCols	:= {}				//Campos a serem mostrados na tela

WEB EXTENDED INIT cHtml START "InSite"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPosicao do item no array de itens do documento fiscalณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nItem := Val( HttpGet->cItem )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInformacoes a serem mostrados na telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
HttpSession->PWSC113EAPH := { 	STR0023 + HttpSession->PWSC113RESULT[1]:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nItem]:cSEQUENTIALID,;             //Documentos Fiscais - Pedido de Venda do Item :
								STR0024,;            //"Comiss๕es"
								"W_PWSC113F.APW?cNota=" + HttpGet->cNota + "&cItem=" + HttpGet->cItem,;
								"W_PWSC113.APW?cNota=" + HttpGet->cNota }

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInformacoes dos campos a serem mostrados na telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
HttpSession->PWSC113EINFO := {}

If ExistBlock( "PEC113E" )
	aWebCols := ExecBlock( "PEC113E", .F., .F. )
EndIf

If HttpSession->PWSC113RESULT[1]:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nItem]:oWSSALESORDER <> NIL
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCampos a serem mostrados na telaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	GridLinesEx( { 	HttpSession->PWSC113EINFO																, HttpSession->PWSC111HEADER[6][1]	,;
					HttpSession->PWSC113RESULT[1]:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nItem]:oWSSALESORDER	, aWebCols							,;
					.F., "H",, 0 } )
Else
	Return PWSHtmlAlert( "", STR0007, STR0004, "W_PWSC113.APW?cNota=" + HttpGet->cNota )      //"Aten็ใo"   /"Nใo hแ pedido de venda para este item deste documento fiscal."
Endif

cHtml += ExecInPage( "PWSC113E" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSC113F  บAutor  ณLuiz Felipe Couto    บ Data ณ  04/07/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela de visualizacao das comissoes do pedido de venda do    บฑฑ
ฑฑบ          ณ item do documento fiscal.                                   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณPortal Protheus                                              บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAnalista  ณ Data/Bops/Ver ณManutencao Efetuada                      	   บฑฑ
ฑฑฬออออออออออุออออออออัออออออุอออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบCleber M. ณ03/09/07ณ131104ณ- Troca do Header p/ utilizar a estrutura    บฑฑ
ฑฑบ          ณ        ณ      ณGenericStruct que contem os 3 campos necessa-บฑฑ
ฑฑบ          ณ        ณ      ณrios para a exibicao das Comissoes.          บฑฑ
ฑฑศออออออออออฯออออออออฯออออออฯอออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Web Function PWSC113F()

Local cHtml 	:= ""				//Pagina WEB
Local nItem		:= ""				//Item do documento fiscal
Local aWebCols 	:= {}				//Campos a serem mostrados na tela
Local oObjSum						//Objeto WS - WSFTSELLERSALESSUMMARY

WEB EXTENDED INIT cHtml START "InSite"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInicializa o objeto WS - WSFTSELLERSALESSUMMARYณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oObjSum := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSFTSELLERSALESSUMMARY' ), WSFTSELLERSALESSUMMARY():New() )
WsChgUrl( @oObjSum, "FTSELLERSALESSUMMARY.APW" )
                              
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณParametros do metodo GETHEADSUM ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oObjSum:cHEADERTYPE := "GENERICSTRUCT"

//cHEADERTYPE
If oObjSum:GETHEADSUM()
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณRetorno do Metodo GetHeadSumณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	HttpSession->PWSC113FHEADER := { oObjSum:oWSGETHEADSUMRESULT:oWSBRWHEADER }
Else
	Return PWSHtmlAlert( "", STR0007		,;	//Atencao
						 "", "W_PWSC112.APW" )
EndIf
		
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณPosicao do item no array de itens do documento fiscalณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nItem := Val( HttpGet->cItem )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInformacoes dos campos a serem mostrados na telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
HttpSession->PWSC113FINFO := {}

If ExistBlock( "PEC113F" )
	aWebCols := ExecBlock( "PEC113F", .F., .F. )
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDescricao dos campos a serem mostrados na telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
GridHeader( HttpSession->PWSC113FINFO, HttpSession->PWSC113FHEADER[1], aWebCols )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCampos a serem mostrados na telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
GridLinesEx( { 	HttpSession->PWSC113FINFO															  											, HttpSession->PWSC113FHEADER[1]	,;
				HttpSession->PWSC113RESULT[1]:oWSINVOICEITEM:oWSINVOICEITEMVIEW[nItem]:oWSSALESORDER:oWSCOMMISSIONSPERCENTAGE:oWSGENERICSTRUCT	, aWebCols							,;
				.F., "A",, 0 } )

cHtml += ExecInPage( "PWSC113F" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSC114   บAutor  ณLuiz Felipe Couto    บ Data ณ  30/06/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela de origem e destinatario.                              บฑฑ
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
Web Function PWSC114()

Local cHtml 	:= ""				//Pagina WEB
Local cTipoCons	:= ""				//Tipo de Consulta do Destinatario: Cliente ou Fornecedor
Local aWebCols	:= {}				//Campos a serem mostrados na tela

WEB EXTENDED INIT cHtml START "InSite"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInformacoes a serem mostrados na telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
HttpSession->PWSC114APH := { 	STR0008,STR0009	,STR0010	,;         //"Documentos Fiscais - Origem / Destino"  /Origem  / "Destino"
								"W_PWSC114A.APW?cNota=" + HttpGet->cNota,;		//Consulta Origem/Destino
								"W_PWSC113.APW?cNota=" + HttpGet->cNota }		//Pagina de Volta

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDocumento de Entradaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If SubStr( HttpSession->PWSC113RESULT[1]:oWSINVOICEHEADER:cINVOICETYPE, 1, 1 ) == "E"
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณBeneficiamento ou Devolucaoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If SubStr( HttpSession->PWSC113RESULT[1]:oWSINVOICEHEADER:cINVOICETYPE, 3, 1 ) $ "B|D"
		HttpSession->PWSC114APH[4] += "&cTipoCons=C&cCUSTOMERID=" + HttpSession->PWSC113RESULT[1]:oWSINVOICEHEADER:oWSFROMROLE:cCODE
	Else
		cTipoCons := "F"
		HttpSession->PWSC114APH[4] += "&cTipoCons=F&cSUPPLIERID=" + HttpSession->PWSC113RESULT[1]:oWSINVOICEHEADER:oWSFROMROLE:cCODE
	Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDocumento de Saidaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Else
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณBeneficiamento ou Devolucaoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If SubStr( HttpSession->PWSC113RESULT[1]:oWSINVOICEHEADER:cINVOICETYPE, 3, 1 ) $ "B|D"
		cTipoCons := "F"
		HttpSession->PWSC114APH[4] += "&cTipoCons=F&cSUPPLIERID=" + HttpSession->PWSC113RESULT[1]:oWSINVOICEHEADER:oWSTOROLE:cCODE
	Else
		cTipoCons := "C"
		HttpSession->PWSC114APH[4] += "&cTipoCons=C&cCUSTOMERID=" + HttpSession->PWSC113RESULT[1]:oWSINVOICEHEADER:oWSTOROLE:cCODE
	Endif
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInformacoes dos campos a serem mostrados na telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
HttpSession->PWSC114INFO := { {}, {} }

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDados do Remetenteณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If ExistBlock( "PEC112" )
	aWebCols := ExecBlock( "PEC112", .F., .F., { 1 } )
Else
	aAdd( aWebCols, "CODE" )
	aAdd( aWebCols, "DESCRIPTION" )
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCampos a serem mostrados na telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
GridLinesEx( { 	HttpSession->PWSC114INFO[1]									, HttpSession->PWSC111HEADER[3][1]	,;
				HttpSession->PWSC113RESULT[1]:oWSINVOICEHEADER:oWSFROMROLE	, aWebCols							,;
				.F., "H",, 0 } )

aWebCols := {}
         
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDados do Destinatarioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If ExistBlock( "PEC112" )
	aWebCols := ExecBlock( "PEC112", .F., .F., { 2 } )
Else
	aAdd( aWebCols, "CODE" )
	aAdd( aWebCols, "DESCRIPTION" )
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCampos a serem mostrados na telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
GridLinesEx( { 	HttpSession->PWSC114INFO[2]									, HttpSession->PWSC111HEADER[3][1]	,;
				HttpSession->PWSC113RESULT[1]:oWSINVOICEHEADER:oWSTOROLE	, aWebCols							,;
				.F., "H",, 0 } )

cHtml += ExecInPage( "PWSC114" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSC114A  บAutor  ณLuiz Felipe Couto    บ Data ณ  30/06/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela de consulta de origem ou destinatario.                 บฑฑ
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
Web Function PWSC114A()

Local cHtml 	:= ""				//Pagina WEB
Local nI		:= 0				//Variavel de apoio
Local aWebCols	:= {}				//Campos a serem mostrados na tela
Local oObj							//Objeto WS - MTCUSTOMER / MTSUPPLIER

WEB EXTENDED INIT cHtml START "InSite"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInformacoes a serem mostrados na telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
HttpSession->PWSC114AAPH := { STR0011 + HttpGet->cCUSTOMERID	,;                         //"Documentos Fiscais - Cliente : "
							   STR0012 , STR0013				,;        //"Endere็o"  /"Telefone"
								"W_PWSC114.APW?cNota=" + HttpGet->cNota + "&cTipoCons=" + HttpGet->cTipoCons }

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInformacoes dos campos a serem mostrados na telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
HttpSession->PWSC114AINFO := { {}, {}, {} }

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณConsulta clienteณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If HttpGet->cTipoCons == "C"
	oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTCUSTOMER' ), WSMTCUSTOMER():New() )
	WsChgUrl( @oObj, "MTCUSTOMER.apw" )
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณTipos de Enderecoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If Empty( HttpSession->PWSC114ATYPEOFADDRESS )
		If oObj:GETTYPEOFADDRESS()
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณRetorno do metodo GETTYPEOFADDRESSณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			HttpSession->PWSC114ATYPEOFADDRESS := { oObj:oWSGETTYPEOFADDRESSRESULT:oWSGENERICSTRUCT }
		Else
			Return PWSHtmlAlert( "",STR0007 , "", "PWSC114.APW" )        //"Aten็ใo"
		Endif
	Endif
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณTipos de Telefoneณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If Empty( HttpSession->PWSC114ATYPEOFPHONE )
		If oObj:GETTYPEOFPHONE()
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณRetorno do metodo GETTYPEOFPHONEณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			HttpSession->PWSC114ATYPEOFPHONE := { oObj:oWSGETTYPEOFPHONERESULT:oWSGENERICSTRUCT }
		Else
			Return PWSHtmlAlert( "", STR0007, "", "PWSC114.APW" )         //"Aten็ใo"
		Endif
	Endif

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณParametros do metodo GETCUSTOMERณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oObj:cUSERCODE		:= "MSALPHA"
	oObj:cCUSTOMERID	:= HttpGet->cCUSTOMERID

	//cUSERCODE,cCUSTOMERID
	If oObj:GETCUSTOMER()
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณRetorno do metodo GETCUSTOMERณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		HttpSession->PWSC114ARESULT := { oObj:oWSGETCUSTOMERRESULT }
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณDados Cadastraisณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If ExistBlock( "PEC114A" )
			aWebCols := ExecBlock( "PEC114A", .F., .F., { 1 } )
		Else
			aAdd( aWebCols, "CUSTOMERCODE" )
			aAdd( aWebCols, "UNITCUSTOMERCODE" )
			aAdd( aWebCols, "NAME" )
			aAdd( aWebCols, "NICKNAME" )
			aAdd( aWebCols, "FEDERALID" )
			aAdd( aWebCols, "STATEID" )
			aAdd( aWebCols, "DISTRICTID" )
			aAdd( aWebCols, "HOMEPAGE" )
			aAdd( aWebCols, "EMAIL" )
		EndIf

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณCampos a serem mostrados na telaณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		GridLinesEx( { 	HttpSession->PWSC114AINFO[1]	, HttpSession->PWSC111HEADER[8][1]	,;
						HttpSession->PWSC114ARESULT[1]	, aWebCols							,;
						.F., "H",, 0 } )
		
		If Len( HttpSession->PWSC114ARESULT[1]:oWSADDRESSES:oWSADDRESSVIEW ) > 0
			//ฺฤฤฤฤฤฤฤฤฟ
			//ณEnderecoณ
			//ภฤฤฤฤฤฤฤฤู
			aWebCols := {}
			
			If ExistBlock( "PEC114A" )
				aWebCols := ExecBlock( "PEC114A", .F., .F., { 2 } )
			Else
				aAdd( aWebCols, "ADDRESS" )
				aAdd( aWebCols, "ADDRESSNUMBER" )
				aAdd( aWebCols, "DISTRICT" )
				aAdd( aWebCols, "STATE" )
				aAdd( aWebCols, "ZIPCODE" )
				aAdd( aWebCols, "ZONE" )
			EndIf
	
			aAdd( HttpSession->PWSC114AINFO[2], {} )
	
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณCampos a serem mostrados na telaณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			GridLinesEx( { 	HttpSession->PWSC114AINFO[2][1]									, HttpSession->PWSC111HEADER[10][1]	,;
							HttpSession->PWSC114ARESULT[1]:oWSADDRESSES:oWSADDRESSVIEW[1]	, aWebCols								,;
							.F., "H",, 0 } )
	
			aWebCols := {}
			
			If ExistBlock( "PEC114A" )
				aWebCols := ExecBlock( "PEC114A", .F., .F., { 3 } )
			Else
				aAdd( aWebCols, "ADDRESS" )
				aAdd( aWebCols, "ADDRESSNUMBER" )
			EndIf
	
			For nI := 2 To Len( HttpSession->PWSC114ARESULT[1]:oWSADDRESSES:oWSADDRESSVIEW )
				aAdd( HttpSession->PWSC114AINFO[2], {} )
	
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณCampos a serem mostrados na telaณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				GridLinesEx( { 	HttpSession->PWSC114AINFO[2][nI]								, HttpSession->PWSC111HEADER[10][1]	,;
								HttpSession->PWSC114ARESULT[1]:oWSADDRESSES:oWSADDRESSVIEW[nI]	, aWebCols								,;
								.F., "H",, 0 } )
			Next nI
		EndIf
		
		If Len( HttpSession->PWSC114ARESULT[1]:oWSPHONES:oWSPHONEVIEW ) > 0
			//ฺฤฤฤฤฤฤฤฤฟ
			//ณTelefoneณ
			//ภฤฤฤฤฤฤฤฤู
			aWebCols := {}
			
			If ExistBlock( "PEC114A" )
				aWebCols := ExecBlock( "PEC114A", .F., .F., { 4 } )
			Else
				aAdd( aWebCols, "COUNTRYAREACODE" )
				aAdd( aWebCols, "LOCALAREACODE" )
				aAdd( aWebCols, "PHONENUMBER" )    
			EndIf                   
	
			aAdd( HttpSession->PWSC114AINFO[3], {} )
	
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณCampos a serem mostrados na telaณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			GridLinesEx( { 	HttpSession->PWSC114AINFO[3][1]								, HttpSession->PWSC111HEADER[11][1]	,;
							HttpSession->PWSC114ARESULT[1]:oWSPHONES:oWSPHONEVIEW[1]	, aWebCols								,;
							.F., "H",, 0 } )
	
			aWebCols := {}
			
			If ExistBlock( "PEC114A" )
				aWebCols := ExecBlock( "PEC114A", .F., .F., { 5 } )
			Else
				aAdd( aWebCols, "PHONENUMBER" )    
			EndIf                   
	
			For nI := 2 To Len( HttpSession->PWSC114ARESULT[1]:oWSPHONES:oWSPHONEVIEW )
				aAdd( HttpSession->PWSC114AINFO[3], {} )
	
				//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
				//ณCampos a serem mostrados na telaณ
				//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
				GridLinesEx( { 	HttpSession->PWSC114AINFO[3][nI]							, HttpSession->PWSC111HEADER[11][1]	,;
								HttpSession->PWSC114ARESULT[1]:oWSPHONES:oWSPHONEVIEW[nI]	, aWebCols								,;
								.F., "H",, 0 } )
			Next nI
		EndIf
	Else
		Return PWSHtmlAlert( "", STR0007, "", "W_PWSC114.APW?cNota=" + HttpGet->cNota )     //"Aten็ใo"
	Endif
Else
	oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTSUPPLIER' ), WSMTSUPPLIER():New() )
	WsChgUrl( @oObj, "MTSUPPLIER.apw" )
Endif

cHtml += ExecInPage( "PWSC114A" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSC115   บAutor  ณLuiz Felipe Couto    บ Data ณ  01/07/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela de visualizacao da transportadora.                     บฑฑ
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
Web Function PWSC115()

Local cHtml 	:= ""				//Pagina WEB
Local aWebCols	:= {}				//Campos a serem mostrados na tela

WEB EXTENDED INIT cHtml START "InSite"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInformacoes a serem mostrados na telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
HttpSession->PWSC115APH := { 	STR0014,;             //"Documentos Fiscais - Transportadora"
								"W_PWSC113.APW?cNota=" + HttpGet->cNota }

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInformacoes dos campos a serem mostrados na telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
HttpSession->PWSC115INFO := {}

If HttpSession->PWSC113RESULT[1]:oWSINVOICEHEADER:oWSCARRIER <> NIL
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCampos a serem mostrados na telaณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	GridLinesEx( { 	HttpSession->PWSC115INFO									, HttpSession->PWSC111HEADER[3][1]	,;
					HttpSession->PWSC113RESULT[1]:oWSINVOICEHEADER:oWSCARRIER	, aWebCols							,;
					.F., "H",, 0 } )
Else
	Return PWSHtmlAlert( "", STR0007, STR0003, "W_PWSC113.APW?cNota=" + HttpGet->cNota )    //"Aten็ใo"  /"Nใo hแ transportadora cadastrada para este documento fiscal."
Endif

cHtml += ExecInPage( "PWSC115" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSC116   บAutor  ณLuiz Felipe Couto    บ Data ณ  01/07/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela de visualizacao dos impostos do documento fiscal.      บฑฑ
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
Web Function PWSC116()

Local cHtml 	:= ""				//Pagina WEB

WEB EXTENDED INIT cHtml START "InSite"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInformacoes a serem mostrados na telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
HttpSession->PWSC116APH := { 	STR0015,;              //"Documentos Fiscais - Impostos"
								"W_PWSC113.APW?cNota=" + HttpGet->cNota }

If Len( HttpSession->PWSC113RESULT[1]:oWSINVOICEHEADER:oWSTAXES:oWSTAXESVIEW ) == 0
	Return PWSHtmlAlert( "", STR0007, STR0016, "W_PWSC113.APW?cNota=" + HttpGet->cNota )       //"Aten็ใo"  /"Nใo hแ impostos para este documento fiscal."
Endif

cHtml += ExecInPage( "PWSC116" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSC116A  บAutor  ณLuiz Felipe Couto    บ Data ณ  01/07/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela de visualizacao dos impostos do documento fiscal.      บฑฑ
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
Web Function PWSC116A()

Local cHtml 	:= ""				//Pagina WEB
Local aWebCols 	:= {}				//Campos a serem mostrados na tela

WEB EXTENDED INIT cHtml START "InSite"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInformacoes dos campos a serem mostrados na telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
HttpSession->PWSC116AINFO := {}

If ExistBlock( "PEC116A" )
	aWebCols := ExecBlock( "PEC116A", .F., .F. )
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDescricao dos campos a serem mostrados na telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
GridHeader( HttpSession->PWSC116AINFO, HttpSession->PWSC111HEADER[4][1], aWebCols )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCampos a serem mostrados na telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
GridLinesEx( { 	HttpSession->PWSC116AINFO												, HttpSession->PWSC111HEADER[4][1]	,;
				HttpSession->PWSC113RESULT[1]:oWSINVOICEHEADER:oWSTAXES:oWSTAXESVIEW	, aWebCols							,;
				.F., "A",, 0 } )

cHtml += ExecInPage( "PWSC116A" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSC117   บAutor  ณLuiz Felipe Couto    บ Data ณ  01/07/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela de visualizacao dos volumes do documento fiscal.       บฑฑ
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
Web Function PWSC117()

Local cHtml 	:= ""				//Pagina WEB

WEB EXTENDED INIT cHtml START "InSite"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInformacoes a serem mostrados na telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
HttpSession->PWSC117APH := { 	STR0017,;            //"Documentos Fiscais - Volumes"
								"W_PWSC113.APW?cNota=" + HttpGet->cNota }

If Len( HttpSession->PWSC113RESULT[1]:oWSINVOICEHEADER:oWSPACKAGESVOLUMES:oWSGENERICSTRUCT ) == 0
	Return PWSHtmlAlert( "", STR0007, STR0018, "W_PWSC113.APW?cNota=" + HttpGet->cNota )     //"Aten็ใo"  /"Nใo hแ volumes para este documento fiscal."
Endif

cHtml += ExecInPage( "PWSC117" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSC117A  บAutor  ณLuiz Felipe Couto    บ Data ณ  01/07/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela de visualizacao dos volumes do documento fiscal.       บฑฑ
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
Web Function PWSC117A()

Local cHtml 	:= ""				//Pagina WEB
Local aWebCols 	:= {}				//Campos a serem mostrados na tela

WEB EXTENDED INIT cHtml START "InSite"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInformacoes dos campos a serem mostrados na telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
HttpSession->PWSC117AINFO := {}

If ExistBlock( "PEC117A" )
	aWebCols := ExecBlock( "PEC117A", .F., .F. )
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDescricao dos campos a serem mostrados na telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
GridHeader( HttpSession->PWSC117AINFO, HttpSession->PWSC111HEADER[3][1], aWebCols )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCampos a serem mostrados na telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
GridLinesEx( { 	HttpSession->PWSC117AINFO															, HttpSession->PWSC111HEADER[3][1]	,;
				HttpSession->PWSC113RESULT[1]:oWSINVOICEHEADER:oWSPACKAGESVOLUMES:oWSGENERICSTRUCT	, aWebCols							,;
				.F., "A",, 0 } )

cHtml += ExecInPage( "PWSC117A" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSC118   บAutor  ณLuiz Felipe Couto    บ Data ณ  01/07/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela de visualizacao dos pagamentos do documento fiscal.    บฑฑ
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
Web Function PWSC118()

Local cHtml 	:= ""				//Pagina WEB

WEB EXTENDED INIT cHtml START "InSite"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInformacoes a serem mostrados na telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
HttpSession->PWSC118APH := { 	STR0019,;            //"Documentos Fiscais - Pagamentos"
								"W_PWSC113.APW?cNota=" + HttpGet->cNota }

If Len( HttpSession->PWSC113RESULT[1]:oWSINVOICEHEADER:oWSPAYMENTPLAN:oWSBILLVIEW ) == 0
	Return PWSHtmlAlert( "", STR0007, STR0020, "W_PWSC113.APW?cNota=" + HttpGet->cNota )     //"Aten็ใo"  /"Nใo hแ pagamentos para este documento fiscal."
Endif

cHtml += ExecInPage( "PWSC118" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPWSC118A  บAutor  ณLuiz Felipe Couto    บ Data ณ  01/07/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela de visualizacao dos pagamentos do documento fiscal.    บฑฑ
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
Web Function PWSC118A()

Local cHtml 	:= ""				//Pagina WEB
Local aWebCols 	:= {}				//Campos a serem mostrados na tela

WEB EXTENDED INIT cHtml START "InSite"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณInformacoes dos campos a serem mostrados na telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
HttpSession->PWSC118AINFO := {}

If ExistBlock( "PEC118A" )
	aWebCols := ExecBlock( "PEC118A", .F., .F. )
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDescricao dos campos a serem mostrados na telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
GridHeader( HttpSession->PWSC118AINFO, HttpSession->PWSC111HEADER[5][1], aWebCols )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCampos a serem mostrados na telaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
GridLinesEx( { 	HttpSession->PWSC118AINFO													, HttpSession->PWSC111HEADER[5][1]	,;
				HttpSession->PWSC113RESULT[1]:oWSINVOICEHEADER:oWSPAYMENTPLAN:oWSBILLVIEW	, aWebCols							,;
				.F., "A",, 0 } )

cHtml += ExecInPage( "PWSC118A" )

WEB EXTENDED END

Return cHtml
