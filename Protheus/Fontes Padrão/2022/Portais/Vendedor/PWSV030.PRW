#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
#INCLUDE "PWSV030.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSV03*   ºAutor  ³Luiz Felipe Couto    º Data ³  22/03/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Este fonte possui as funcionalidades relacionado ao         º±±
±±º          ³ catalogo de produtos                                        º±±
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
±±ºPrograma  ³PWSV030   ºAutor  ³Luiz Felipe Couto    º Data ³  22/03/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Mostra os vendedores disponiveis para o usuario logado.     º±±
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
Web Function PWSV030()

Local cHtml := ""					//Pagina WEB
Local aVend	:= {}					//Array de vendedores cadastrados para o usuario logado

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Vendedores cadastrados para o usuario logado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aVend := GetUserVen()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Informacoes a serem utilizadas pelo APH³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpSession->PWSV020APH	:= { 	STR0002				,;      //Catalogo de Produtos
								"W_PWSV031.APW"			,;		//Pagina para onde sera enviado o POST
								"" }							//Mensagem a ser mostrada na tela
	
Do Case
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Nao ha vendedores cadastrados para o usuario logado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case Empty( aVend )
		HttpSession->PWSV020APH[3] := STR0003		//Nao ha vendedores a consultar
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Apenas 1 vendedor cadastrado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case Len( aVend ) == 2
		HttpSession->CODVENERP := aVend[2][2]

		Return W_PWSV031()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Mais de 1 vendedor³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Otherwise
		cHtml += ExecInPage( "PWSV020" )

EndCase

cHtml += ExecInPage( "PWSV020" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSV031   ºAutor  ³Luiz Felipe Couto    º Data ³  22/03/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela de apresentacao da busca dos produtos.                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Portal Protheus                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºCleber M. ³18/05/06³98717 ³Passagem de parametro com o nome do WS na    º±±
±±º          ³        ³      ³funcao GridLinesEx() para que seja possivel  º±±
±±º          ³        ³      ³iniciar o metodo que inclui os campos de     º±±
±±º          ³        ³      ³usuario no aHeader.                      	   º±±
±±ºCleber M. ³01/06/07³126843³Alteracao no aWebCols para permitir consulta º±±
±±º          ³        ³      ³F3 no campo Produto (PRODUCTCODE).           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSV031()

Local cHtml 	:= ""				//Pagina WEB
Local aWebCols	:= {}				//Array contendo os campos que serao apresentados na tela
Local oObjProd						//Objeto WS - WSMTPRODUCT
Local oObjIndex						//Objeto WS - WSCFGDICTIONARY
Local cNomeWS	:= "MTPRODUCT"		//Nome do WS

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Informacoes a serem mostradas na tela³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpSession->PWSV031APH := { 	STR0004		,;				//Catalogo de Produtos - Busca"
								"W_PWSV032.APW" } 				//Pagina para onde sera enviado o POST

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa Objeto WS - WSMTPRODUCT³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObjProd := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTPRODUCT"), WSMTPRODUCT():New() )
WsChgUrl( @oObjProd, "MTPRODUCT.APW" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa Objeto WS - WSCFGDICTIONARY³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 oObjIndex := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGDICTIONARY"), WSCFGDICTIONARY():New() )
WsChgUrl( @oObjIndex, "CFGDICTIONARY.APW" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Array contendo os headers dos WS utilizados nesta pagina³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty( HttpSession->PWSV031HEADER )
	HttpSession->PWSV031HEADER := { NIL, NIL, NIL, NIL }

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Header da estrutura PRODUCTVIEW - Produto                              ³
	//|- PRODUCTCODE                  : Codigo                                |
	//|- DESCRIPTION                  : Descricao                             |
	//|- SCIENCEDESCRIPTION           : Descricao Cientifica                  |
	//|- MEASUREUNIT                  : Unidade de Medida                     |
	//|- DESCRIPTIONMEASUREUNIT       : Descricao da Unidade de Medida        |
	//|- SECONDMEASUREUNIT            : Segunda Unidade de Medida             |
	//|- DESCRIPTIONSECONDMEASUREUNIT : Descricao da Segunda Unidade de Medida|
	//|- TYPEOFPRODUCT                : Tipo                                  |
	//|- DESCRIPTIONTYPEOFPRODUCT     : Descricao do Tipo                     |
	//|- GROUPOFPRODUCT               : Grupo                                 |
	//|- DESCRIPTIONGROUPOFPRODUCT    : Descricao do Grupo                    |
	//|- NCM                          : Nomenclatura Ext. Mercosul            |
	//|- QUANTITYPERPACKAGE           : Quntidade por Embalagem               |
	//|- ORDERPOINT                   : Ponto de Pedido                       |
	//|- NETWEIGHT                    : Peso Liquido                          |
	//|- GROSSWEIGHT                  : Peso Bruto                            |
	//|- LEADTIME                     : Prazo de Entrega                      |
	//|- TYPEOFLEADTIME               : Tipo de Prazo de Entrega              |
	//|- ECONOMICLOT                  : Lote Economico                        |
	//|- MINIMUMLOT                   : Lote Minimo                           |
	//|- MINIMUMGRADE                 : Nota Minima                           |
	//|- TERMOFVALIDATY               : Termo de Validade                     |
	//|- BARCODE                      : Codigo de Barra                       |
	//|- STORAGELENGHT                : Comprimento da Armazenagem            |
	//|- STORAGEWIDTH                 : Largura da Armazenagem                |
	//|- STORAGEHEIGHT                : Altura da Armazenagem                 |
	//|- STORAGEMAXIMUMPILING         : Fator de Armazenamento                |
	//|- STANDARDWAREHOUSE            : Armazem                               |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty( HttpSession->PWSV031HEADER[1] )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Parametros do metodo GETHEADER³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oObjProd:cHEADERTYPE := "PRODUCTVIEW"

		If oObjProd:GETHEADER()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Retorno do Metodo GETHEADER³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			HttpSession->PWSV031HEADER[1] := { oObjProd:oWSGETHEADERRESULT:oWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0005		,;	//Atencao
								 "", "W_PWSV030.APW" )
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Header da estrutura do GENERICVIEW2 - Consulta Generica³
	//|- CODE        : Ordem                                  |
	//|- DESCRIPTION : Chave                                  |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty( HttpSession->PWSV031HEADER[2] )
		If oObjIndex:GETHEADER()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Retorno do Metodo GETHEADER³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			HttpSession->PWSV031HEADER[2] := { oObjIndex:oWSGETHEADERRESULT:oWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0005		,;		//Atencao
								 "", "W_PWSV030.APW" )
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Header da estrutura do PRICEVIEW         ³
	//|- PRODUCTCODE     : Codigo do Produto    |
	//|- PAYMENTPLANCODE : Condicao de Pagamento|
	//|- PRICETABLECODE  : Tabela de Preco      |
	//|- PRICE           : Preco                |
	//|- QUANTITYLIMIT   : Quantidade Limite    |
	//|- CURRENCY        : Moeda                |
	//|- CURRENCYSIMBOL  : Simbolo da Moeda     |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty( HttpSession->PWSV031HEADER[3] )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Parametros do metodo GETHEADER³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oObjProd:cHEADERTYPE := "PRICEVIEW"
		
		If oObjProd:GETHEADER()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Retorno do Metodo GETHEADER³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			HttpSession->PWSV031HEADER[3] := { oObjProd:oWSGETHEADERRESULT:oWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0005		,;		//Atencao
								 "", "W_PWSV030.APW" )
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Header da estrutura do INVENTORYVIEW                      ³
	//|- PRODUCTCODE              : Codigo do Produto            |
	//|- QUANTITY                 : Quantidade                   |
	//|- COST                     : Custo                        |
	//|- CURRENCY                 : Moeda                        |
	//|- CURRENCYSIMBOL           : Simbolo da Moeda             |
	//|- TYPEOFBALANCE            : Tipo de Situacao             |
	//|- DESCRIPTIONTYPEOFBALANCE : Descricao do Tipo de Situacao|
	//|- WAREHOUSE                : Armazem                      |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty( HttpSession->PWSV031HEADER[4] )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Parametros do metodo GETHEADER³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oObjProd:cHEADERTYPE := "INVENTORYVIEW"

		If oObjProd:GETHEADER()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Retorno do Metodo GETHEADER³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			HttpSession->PWSV031HEADER[4] := { oObjProd:oWSGETHEADERRESULT:oWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0005		,;		//Atencao
								 "", "W_PWSV030.APW" )
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Indices da Tabela SB1³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty( HttpSession->PWSV031INDEX )
	HttpSession->PWSV031INDEX := { NIL }
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Parametros do metodo GETINDEX³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oObjIndex:cUSERCODE 	:= GetUsrCode()
	oObjIndex:cTABLE 		:= "SB1"
	
	//cUSERCODE,cTABLE
	If oObjIndex:GETINDEX()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Resultado do Metodo GETINDEX³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		HttpSession->PWSV031INDEX := { oObjIndex:oWSGETINDEXRESULT:oWSGENERICSTRUCT }
	Else
		Return PWSHtmlAlert( "", STR0005		,;	//Atencao
							 "", "W_PWSV030.APW" )
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Dados para montagem da Tela de Busca³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty( HttpSession->PWSV031BUSCA )
	HttpSession->PWSV031BUSCA := { {}, {} }
											
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de Entrada - Campos do WS WSMTPRODUCT³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock( "PEV031" )
		aWebCols := ExecBlock( "PEV031", .F., .F., { 1 } )
	Else
		aAdd( aWebCols, { "PRODUCTCODE", "N", { "GETCATALOG", ;
												{ "CPRODUCTCODE", "CPRODUCTCODE" } }, ;
												{ "CPRODUCTCODE", "CDESCRIPTION" } } )
		aAdd( aWebCols, "DESCRIPTION" )
		aAdd( aWebCols, { "GROUPOFPRODUCT", "N", { "GETGROUPOFPRODUCT", ;
												{ "CGROUPOFPRODUCT", "CGROUPCODE" } }, ;
												{ "CGROUPCODE", "CDESCRIPTION" } } )
		aAdd( aWebCols, { "TYPEOFPRODUCT", "N", { "GETTYPEOFPRODUCT", ;
												{ "CTYPEOFPRODUCT", "CCODE" } }, ;
												{ "CCODE", "CDESCRIPTION" } } )
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Funcao de montagem da descricao dos campos da tela³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	GridHeader( HttpSession->PWSV031BUSCA[1], HttpSession->PWSV031HEADER[1][1], aWebCols )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Funcao de montagem dos campos da tela³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	GridLinesEx( { 	HttpSession->PWSV031BUSCA[1]	, HttpSession->PWSV031HEADER[1][1]	,;
					MTPRODUCT_PRODUCTVIEW():New()	, 	aWebCols						,;
					.T., "A",, 0 }, cNomeWS )
	
	aWebCols := {}
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de Entrada - Campos do WS WSCFGDICTIONARY³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock( "PEV031" )
		aWebCols := ExecBlock( "PEV031", .F., .F., { 2 } )
	Else
		aAdd( aWebCols, "CODE" )
		aAdd( aWebCols, "DESCRIPTION" )
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Funcao de montagem da descricao dos campos da tela³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	GridHeader( HttpSession->PWSV031BUSCA[2], HttpSession->PWSV031HEADER[2][1], aWebCols )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Funcao de montagem dos campos da tela³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	GridLinesEx( { 	HttpSession->PWSV031BUSCA[2], HttpSession->PWSV031HEADER[2][1]	,;
					HttpSession->PWSV031INDEX[1], aWebCols							,;
					.F., "A",, 0 }, cNomeWS )
EndIf

cHtml += ExecInPage( "PWSV031" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSV032   ºAutor  ³Luiz Felipe Couto    º Data ³  22/03/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela de retorno da Busca por Produtos.                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Portal Protheus                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºCleber M. ³18/05/06³98717 ³Passagem de parametro com o nome do WS na    º±±
±±º          ³        ³      ³funcao GridLinesEx() para que seja possivel  º±±
±±º          ³        ³      ³iniciar o metodo que inclui os campos de     º±±
±±º          ³        ³      ³usuario no aHeader.                      	   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSV032()

Local cHtml 	:= ""					//Pagina WEB
Local aWebCols 	:= {}					//Array de campos a serem mostrados na tela
Local oObj								//Objeto WS - WSMTPRODUCT
Local cNomeWS	:= "MTPRODUCT"      	//Nome do WS a ser passado na GridLinesEx

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Informacoes a serem mostradas na tela³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpSession->PWSV032APH := { 	STR0006		,;		//Catalogo de Produtos - Resultado da Busca 
								"W_PWSV031.APW" }		//Pagina de volta do Resultado da Busca

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Array para montagem da tela³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpSession->PWSV032INFO := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa o objeto WS - WSMTPRODUCT³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTPRODUCT"), WSMTPRODUCT():New() )
WsChgURL( @oObj, "MTPRODUCT.APW" )

If !Empty( HttpPost->CPRODUCTCODE ) .OR. !Empty( HttpPost->CDESCRIPTION ) .OR. ;
	!Empty( HttpPost->CDESCRIPTION ) .OR. !Empty( HttpPost->CTYPEOFPRODUCT ) .OR. ;
	!Empty( HttpPost->CGROUPOFPRODUCT )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Parametros do metodo GETCATALOG³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oObj:cUSERCODE			:= GetUsrCode()
	oObj:cTYPEOFPRODUCTIN	:= HttpPost->CTYPEOFPRODUCT
	oObj:cGROUPOFPRODUCTIN	:= HttpPost->CGROUPOFPRODUCT
	oObj:cPRODUCTCODELIKE	:= IIf( !Empty( HttpPost->CPRODUCTCODE ), HttpPost->CPRODUCTCODE, "" )
	oObj:cDESCRIPTIONLIKE	:= IIf( !Empty( HttpPost->CDESCRIPTION ), HttpPost->CDESCRIPTION, "" )
	oObj:nPAGELEN			:= 0
	oObj:nPAGEFIRST			:= 0
	oObj:cQUERYADDWHERE		:= ""
	oObj:cINDEXKEY			:= IIf( !Empty( HttpPost->CINDEX ), HttpPost->CINDEX, )

	//cUSERCODE,cTYPEOFPRODUCTIN,cGROUPOFPRODUCTIN,cPRODUCTCODELIKE,cDESCRIPTIONLIKE,nPAGELEN,nPAGEFIRST,cQUERYADDWHERE,cINDEXKEY
	If oObj:GETCATALOG()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Retorno do Metodo GETCATALOG³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		HttpSession->PWSV032RESULT := { oObj:oWSGETCATALOGRESULT:oWSPRODUCTVIEW }
	Else
		Return PWSHtmlAlert( "", STR0005		,;	//Atencao
							 "", "W_PWSV031.APW" )
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica Resultado da Busca³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty( HttpSession->PWSV032RESULT ) .AND. Len( HttpSession->PWSV032RESULT[1] ) > 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de Entrada - Campos do WS WSMTPRODUCT³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock( "PEV032" )
		aWebCols := ExecBlock( "PEV032", .F., .F., {} )
	Else
		aAdd( aWebCols, "PRODUCTCODE" )
		aAdd( aWebCols, "DESCRIPTION" )
		aAdd( aWebCols, "MEASUREUNIT" )
		aAdd( aWebCols, "TYPEOFPRODUCT" )
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Funcao de montagem da descricao dos campos da tela³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	GridHeader( HttpSession->PWSV032INFO,;			//Array p/ disponibilizacao HTML
				HttpSession->PWSV031HEADER[1][1],;	//Header dos campos a serem mostrados
				aWebCols,;							//Array com os campos a serem mostrados
				HttpSession->PWSV032RESULT[1] )		//Obj. para uso dos campos de usuario
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Funcao de montagem dos campos da tela³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	GridLinesEx( { 	HttpSession->PWSV032INFO		, HttpSession->PWSV031HEADER[1][1]	,;
					HttpSession->PWSV032RESULT[1]	, aWebCols							,;
					.F., "A",, 0 }, cNomeWS )
Else
	Return PWSHtmlAlert( "", STR0005	,;		//Atencao
						STR0007		,;      //A busca nao retornou nenhum produto.
						"W_PWSV031.APW" )
EndIf

cHtml += ExecInPage( "PWSV032" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSV032   ºAutor  ³Luiz Felipe Couto    º Data ³  22/03/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela de retorno da Busca por Produtos.                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Portal Protheus                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºCleber M. ³18/05/06³98717 ³Passagem de parametro com o nome do WS na    º±±
±±º          ³        ³      ³funcao GridLinesEx() para que seja possivel  º±±
±±º          ³        ³      ³iniciar o metodo que inclui os campos de     º±±
±±º          ³        ³      ³usuario no aHeader.                      	   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSV033()

Local cHtml 	:= ""						//Pagina WEB
Local nPosProd	:= 0						//Posicao do Produto dentro do array de Retorno do Metodo GETCATALOG
Local aWebCols 	:= {}						//Array contendo os campos a serem mostrados na tela
Local oObj									//Objeto WS - WSMTPRODUCT
Local cNomeWS	:= "MTPRODUCT"				//Nome do WS

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Informacoes a serem mostradas na tela³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpSession->PWSV033APH := { 	STR0008	,; 		//Catalogo de Produtos - Detalhes do Produto
								STR0009	,;      //Tabelas de Preco
								STR0010	,;		//Posicao de Estoque
								"W_PWSV031.APW" }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Array para montagem da tela³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpSession->PWSV033INFO := { {}, {}, {} }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa Objeto WS - WSMTPRODUCT³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTPRODUCT"), WSMTPRODUCT():New() )
WsChgUrl( @oObj, "MTPRODUCT.APW" )

nPosProd := aScan( HttpSession->PWSV032RESULT[1], { |x| AllTrim( x:cPRODUCTCODE ) == AllTrim( HttpGet->CPRODUCTCODE ) } )

If nPosProd > 0
	aWebCols := {}
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de Entrada - Campos do WS WSMTPRODUCT³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock( "PEV033" )
		aWebCols := ExecBlock( "PEV033", .F., .F., { 1 } )
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Funcao de montagem dos campos da tela³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	GridLinesEx( { 	HttpSession->PWSV033INFO[1]				, HttpSession->PWSV031HEADER[1][1]	,;
					HttpSession->PWSV032RESULT[1][nPosProd]	, aWebCols							,;
					.F., "H",, 0 }, cNomeWS )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Parametros do metodo GETPRICE³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oObj:cUSERCODE		:= GetUsrCode()
	oObj:cPRODUCTCODE	:= HttpGet->CPRODUCTCODE

	//cUSERCODE,cPRODUCTCODE,cQUERYADDWHERE
	If oObj:GETPRICE()
		aWebCols := {}	            
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de Entrada - Campos do WS WSMTPRODUCT³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock( "PEV033" )
			aWebCols := ExecBlock( "PEV033", .F., .F., { 2 } )
		EndIf
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Funcao de montagem da descricao dos campos da tela³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		GridHeader(	HttpSession->PWSV033INFO[2], HttpSession->PWSV031HEADER[3][1], aWebCols, oObj:oWSGETPRICERESULT:oWSPRICEVIEW )
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Funcao de montagem dos campos da tela³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		GridLinesEx( { 	HttpSession->PWSV033INFO[2]			, HttpSession->PWSV031HEADER[3][1]	,;
						oObj:oWSGETPRICERESULT:oWSPRICEVIEW	, aWebCols							,;
						.F., "A",, 0 }, cNomeWS )
	Else
		Return PWSHtmlAlert( "", STR0005		,;		//Atencao
							 "", "PWSV032.APW" )
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Parametros do metodo GETIMAGE³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oObj:cUSERCODE		:= GetUsrCode()
	oObj:cPRODUCTCODE	:= HttpGet->CPRODUCTCODE

	//cUSERCODE,cPRODUCTCODE
	If oObj:GETIMAGE()
		HttpSession->_IMG_PROD := oObj:cGETIMAGERESULT
	Else
		Return PWSHtmlAlert( "", STR0005		,;		//Atencao
							 "", "PWSV032.APW" )
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Parametros do metodo GETSTOCK³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oObj:cUSERCODE		:= GetUsrCode()
	oObj:cPRODUCTCODE	:= HttpGet->CPRODUCTCODE
	oObj:cWAREHOUSE		:= HttpSession->PWSV032RESULT[1][nPosProd]:cSTANDARDWAREHOUSE
	
	//cUSERCODE,cPRODUCTCODE,cWAREHOUSE
	If oObj:GETSTOCK()
		aWebCols := {}
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de Entrada - Campos do WS WSMTPRODUCT³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock( "PEV033" )
			aWebCols := ExecBlock( "PEV033", .F., .F., { 3 } )
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Funcao de montagem da descricao dos campos da tela³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		GridHeader(	HttpSession->PWSV033INFO[3], HttpSession->PWSV031HEADER[4][1], aWebCols, oObj:oWSGETSTOCKRESULT:oWSINVENTORYVIEW )
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Funcao de montagem dos campos da tela³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		GridLinesEx( { 	HttpSession->PWSV033INFO[3]				, HttpSession->PWSV031HEADER[4][1]	,;
						oObj:oWSGETSTOCKRESULT:oWSINVENTORYVIEW	, aWebCols							,;
						.F., "A",, 0 }, cNomeWS )
	Else
		Return PWSHtmlAlert( "", STR0005		,;		//Atencao
							 "", "PWSV032.APW" )
	EndIf
EndIf

cHtml += ExecInPage( "PWSV033" )

WEB EXTENDED END

Return cHtml
