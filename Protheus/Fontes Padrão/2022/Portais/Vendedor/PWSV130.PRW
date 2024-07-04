#INCLUDE "PWSV130.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSV13*   ºAutor  ³Luiz Felipe Couto    º Data ³  18/03/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Este fonte possui as funcionalidades relacionado aos        º±±
±±º          ³ prospects.                                                  º±±
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
±±ºPrograma  ³PWSV130   ºAutor  ³Luiz Felipe Couto    º Data ³  04/04/05   º±±
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
Web Function PWSV130()

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
HttpSession->PWSV020APH	:= { 	STR0001,; 						//"Prospects"
								"W_PWSV131.APW",;				//Pagina para onde sera enviado o POST
								"" }							//Mensagem a ser mostrada na tela
	
Do Case
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Nao ha vendedores cadastrados para o usuario logado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case Empty( aVend )
		HttpSession->PWSV020APH[3] := STR0002 					//"Não há vendedores a consultar."
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Apenas 1 vendedor cadastrado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case Len( aVend ) == 2
		HttpSession->CODVENERP := aVend[2][2]

		Return W_PWSV131()

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
±±ºPrograma  ³PWSV131   ºAutor  ³Luiz Felipe Couto    º Data ³  18/03/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela de apresentacao da busca do prospect.                  º±±
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
Web Function PWSV131()

Local cHtml 	:= ""					//Pagina WEB
Local aWebCols 	:= {}					//Array de campos a serem mostrados na tela
Local oObjCRM							//Objeto WS - WSCRMPROSPECT
Local oObjIndex							//Objeto WS - WSCFGDICTIONARY

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Informacoes a serem utilizadas pelo APH³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpSession->PWSV131APH := { 	STR0001 + STR0002,; 		//Prospects - Busca 
								"W_PWSV132.APW",;			//Pagina para onde sera enviado o POST para Alteracao
								"W_PWSV133.APW" }			//Pagina para onde sera enviado o POST para Inclusao



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa o objeto WS - WSCRMPROSPECT³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObjCRM := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSCRMPROSPECT' ), WSCRMPROSPECT():New() )
WsChgUrl( @oObjCRM, "CRMPROSPECT.apw" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa o objeto WS - WSCFGDICTIONARY³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObjIndex := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSCFGDICTIONARY' ), WSCFGDICTIONARY():New() )
WsChgUrl( @oObjIndex, "CFGDICTIONARY.APW" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Array contendo os headers dos WS utilizados nesta pagina³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty( HttpSession->PWSV131HEADER )
	HttpSession->PWSV131HEADER := { NIL, NIL, NIL, NIL }
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Header da estrutura PROSPECTVIEW - Prospect³
	//|- PROSPECTCODE      : Codigo               |
	//|- UNITPROSPECTCODE  : Loja                 |
	//|- NAME              : Nome                 |
	//|- NICKNAME          : Nome Fantasia        |
	//|- FEDERALID         : CNPJ                 |
	//|- EMAIL             : E-mail               |
	//|- HOMEPAGE          : Homepage             |
	//|- CUSTOMERCODE      : Codigo do Cliente    |
	//|- UNITCUSTOMERCODE  : Loja do Cliente      |
	//|- LASTVISIT         : Ultima Visita        |
	//|- SELLERCODE        : Codigo do Vendedor   |
	//|- STATUSCODE        : Status               |
	//|- STATUSDESCRIPTION : Descricao            |
	//|- ORIGINCODE        : Origem               |
	//|- ORIGINDESCRIPTION : Descricao            |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty( HttpSession->PWSV131HEADER[1] )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Parametros do metodo GETHEADER³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oObjCRM:cHEADERTYPE := "PROSPECTVIEW"

		//cHEADERTYPE
		If oObjCRM:GETHEADER()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Retorno do Metodo GETHEADER³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			HttpSession->PWSV131HEADER[1] := { oObjCRM:oWSGETHEADERRESULT:oWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0003,;		//Atencao
								 "", "W_PWSV130.APW" )
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Header da estrutura ADDRESSVIEW - Endereco³
	//|- ADDRESS       : Endereco                |
	//|- ADDRESSNUMBER : Numero                  |
	//|- DISTRICT      : Cidade                  |
	//|- STATE         : Estado                  |
	//|- ZIPCODE       : CEP                     |
	//|- ZONE          : Bairro                  |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty( HttpSession->PWSV131HEADER[2] )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Parametros do metodo GETHEADER³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oObjCRM:cHEADERTYPE := "ADDRESSVIEW"

		//cHEADERTYPE
		If oObjCRM:GETHEADER()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Retorno do Metodo GETHEADER³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			HttpSession->PWSV131HEADER[2] := { oObjCRM:oWSGETHEADERRESULT:OWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0003,; 	//Atencao
								 "", "W_PWSV130.APW" )
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Header da estrutura PHONEVIEW - Telefone³
	//|- COUNTRYAREACODE : DDI                 |
	//|- LOCALAREACODE   : DDD                 |
	//|- PHONENUMBER     : Numero              |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty( HttpSession->PWSV131HEADER[3] )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Parametros do metodo GETHEADER³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oObjCRM:cHEADERTYPE := "PHONEVIEW"

		//cHEADERTYPE
		If oObjCRM:GETHEADER()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Retorno do Metodo GETHEADER³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			HttpSession->PWSV131HEADER[3] := { oObjCRM:oWSGETHEADERRESULT:OWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0003,;		//Atencao
								 "", "W_PWSV130.APW" )
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Header da estrutura do WS CFGDICTIONARY³
	//|- CODE        : Ordem                  |
	//|- DESCRIPTION : Chave                  |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty( HttpSession->PWSV131HEADER[4] )
		If oObjIndex:GETHEADER()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Retorno do Metodo GETHEADER³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			HttpSession->PWSV131HEADER[4] := { oObjIndex:oWSGETHEADERRESULT:oWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0003,; 	//Atencao
								 "", "W_PWSV180.APW" )
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Indices da Tabela SA1³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty( HttpSession->PWSV131INDEX )
	HttpSession->PWSV131INDEX := {}
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Parametros do metodo GETINDEX³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oObjIndex:cUSERCODE 	:= GetUsrCode()
	oObjIndex:cTABLE 		:= "SUS"
	
	//cUSERCODE,cTABLE
	If oObjIndex:GETINDEX()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Resultado do Metodo GETINDEX³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		HttpSession->PWSV131INDEX := { oObjIndex:oWSGETINDEXRESULT:oWSGENERICSTRUCT }
	Else
		Return PWSHtmlAlert( "", STR0003,;  //Atencao
							 "", "W_PWSV130.APW" )
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Dados para montagem da Tela de Busca³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty( HttpSession->PWSV131BUSCA )
	HttpSession->PWSV131BUSCA := { {}, {} }
                          
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de Entrada - Campos do WS WSCRMPROSPECT³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock( "PEV131" )
		aWebCols := ExecBlock( "PEV131", .F., .F., { 1 } )
	Else
		aAdd( aWebCols, "NAME" )
		aAdd( aWebCols, "NICKNAME" )
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Funcao de montagem da descricao dos campos da tela³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	GridHeader( HttpSession->PWSV131BUSCA[1], HttpSession->PWSV131HEADER[1][1], aWebCols )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Funcao de montagem dos campos da tela³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	GridLinesEx( { 	HttpSession->PWSV131BUSCA[1]			, HttpSession->PWSV131HEADER[1][1]	,;
					CRMPROSPECT_PROSPECTVIEW():New()		, aWebCols							,;
					.T.										, "A",, 0 },"CRMPROSPECT")
	
	aWebCols := {}
                                 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de Entrada - Campos do WS WSCFGDICTIONARY³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock( "PEV131" )
		aWebCols := ExecBlock( "PEV131", .F., .F., { 2 } )
	Else
		aAdd( aWebCols, "CODE" )
		aAdd( aWebCols, "DESCRIPTION" )
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Funcao de montagem da descricao dos campos da tela³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   	GridHeader( HttpSession->PWSV131BUSCA[2], HttpSession->PWSV131HEADER[4][1], aWebCols )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Funcao de montagem dos campos da tela³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	GridLinesEx( { HttpSession->PWSV131BUSCA[2]		, HttpSession->PWSV131HEADER[4][1]	,;
					HttpSession->PWSV131INDEX[1]	, aWebCols							,;
					.F.								, "A",, 0 } )
EndIf

cHtml += ExecInPage( "PWSV131" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSV132   ºAutor  ³Luiz Felipe Couto    º Data ³  04/04/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela com o retorno da busca do prospect.                    º±±
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
Web Function PWSV132()

Local cHtml 	:= ""					//Pagina WEB
Local aWebCols 	:= {}					//Array com os campos a serem mostrados na tela
Local oObj								//Objeto WS - WSCRMPROSPECT

Private cMsg := ""

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Informacoes a serem mostradas na tela³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpSession->PWSV132APH := {	STR0001 + STR0004 ,;	//Prospects - Resultado da Busca 
								"W_PWSV133.APW"	,;
								"W_PWSV131.APW" }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Array para montagem da tela³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpSession->PWSV132INFO := {}


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa o objeto WS - WSCRMPROSPECT³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSCRMPROSPECT' ), WSCRMPROSPECT():New() )
WsChgUrl( @oObj, "CRMPROSPECT.APW" )

If !Empty( HttpPost->CNAME ) .OR. !Empty( HttpPost->CNICKNAME )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Parametros do metodo BRWPROSPECT³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oObj:cUSERCODE		:= "MSALPHA"
	oObj:cSELLERCODE	:= HttpSession->CODVENERP
	oObj:cQUERYADDWHERE	:= ""
	oObj:cINDEXKEY		:= "US_COD"
	
	//cUSERCODE,cSELLERCODE,cQUERYADDWHERE,cINDEXKEY
	If oObj:BRWPROSPECT()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Retorno do metodo BRWCONTACT³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		HttpSession->PWSV132RESULT := { oObj:oWSBRWPROSPECTRESULT:oWSPROSPECTVIEW }
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Ponto de Entrada - Prospect³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock( "PEV132" )
			aWebCols := ExecBlock( "PEV132", .F., .F., {} )
		Else
			aAdd( aWebCols, "PROSPECTCODE" )
			aAdd( aWebCols, "UNITPROSPECTCODE" )
			aAdd( aWebCols, "NAME" )
			aAdd( aWebCols, "FEDERALID" )
			aAdd( aWebCols, "EMAIL" )
			aAdd( aWebCols, "CUSTOMERCODE" )
			aAdd( aWebCols, "UNITCUSTOMERCODE" )
			aAdd( aWebCols, "LASTVISIT" )
			aAdd( aWebCols, "SELLERCODE" )
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Funcao de montagem da descricao dos campos da tela³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		GridHeader( HttpSession->PWSV132INFO, HttpSession->PWSV131HEADER[1][1], aWebCols )
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Funcao de montagem dos campos da tela³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		GridLinesEx( { 	HttpSession->PWSV132INFO		, HttpSession->PWSV131HEADER[1][1]	,;
						HttpSession->PWSV132RESULT[1]	, aWebCols							,;
						.F.								, "A",, 0 } )
	Else
		Return PWSHtmlAlert( "", STR0003,; //Atencao
							 "", "W_PWSV131.APW" )
	EndIf
Else
	Return PWSHtmlAlert( "", STR0003	,;   	//Atencao
						 STR0007		,;		//Favor digitar um dado para busca
						 "W_PWSV131.APW" )
EndIf

cHtml += ExecInPage( "PWSV132" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSV133   ºAutor  ³Luiz Felipe Couto    º Data ³  04/04/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela com os dados do Prospect selecionado.                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Portal Protheus                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±³Cleber M. ³22/03/06³ 90349³- Desabilitados os campos Codigo/Loja na in- ³±±
±±³          ³        ³  8.11³clusao do Prospect. A MsExecAuto determinara ³±±
±±³          ³        ³      ³o proximo codigo automaticamente.            ³±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSV133()

Local cHtml 		:= ""						//Pagina WEB
Local nI 			:= 0						//Variavel de apoio
Local nPosEnd		:= 0						//Posicao do tipo do endereco dentro do array de Enderecos do Contato
Local nPosTel		:= 0						//Posicao do tipo do telefone dentro do array de Telefones do Contato
Local aWebCols 		:= {}						//Array contendo os campos que serao utilizados na tela
Local oObj										//Objeto WS - WSCRMPROSPECT


WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Array com as informacoes a serem mostradas na tela³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpSession->PWSV133APH := { 	""				,;			//Titulo da pagina
								"W_PWSV134.APW"	,;			//Pagina para onde sera enviado o POST
								"W_PWSV131.APW" }			//Pagina de Volta

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Informacoes dos campos que seram mostrados na tela³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpSession->PWSV133INFO := { {}, {}, {} }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Session de armazenagem do objeto WS³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpSession->PWSV133RESULT := {}


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa Objeto WS - WSCRMSELLERCUSTOMERCONTACT³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSCRMPROSPECT' ), WSCRMPROSPECT():New() )
WsChgUrl( @oObj, "CRMPROSPECT.APW" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Array com os tipos de informacoes que serao apresentados na tela³
//³Ex: Tipo de Telefone, Tipos de Endereco, etc.                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty( Httpsession->PWSV133TYPES )
	Httpsession->PWSV133TYPES := { NIL, NIL }
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tipos de Endereco³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty( Httpsession->PWSV133TYPES[1] )
		If oObj:GETTYPEOFADDRESS()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Retorno do metodo GETTYPEOFADDRESS³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Httpsession->PWSV133TYPES[1] := { oObj:oWSGETTYPEOFADDRESSRESULT:oWSGENERICSTRUCT }
		Else
			Return PWSHtmlAlert( "", STR0003,;	//Atencao
								 "", "W_PWSV132.APW" )
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tipos de Telefone³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty( Httpsession->PWSV133TYPES[2] )
		If oObj:GETTYPEOFPHONE()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Retorno do metodo GETTYPEOFPHONE³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Httpsession->PWSV133TYPES[2] := { oObj:oWSGETTYPEOFPHONERESULT:oWSGENERICSTRUCT }
		Else
			Return PWSHtmlAlert( "", STR0003,;  //Atencao
								 "", "W_PWSV132.APW" )
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Alteracao de Prospect³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If HttpGet->cAcao == "A"
	HttpSession->PWSV133APH[1] := 	STR0001+;	//Prospects
									STR0006+;  	//Alteracao - Dados Cadastrais
									HttpSession->PWSV132RESULT[1][Val( HttpGet->cProspect )]:cNAME 
	HttpSession->cProspect	:= HttpGet->cProspect 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Parametros do metodo GETPROSPECT³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oObj:cUSERCODE		:= GetUsrCode() 
	oObj:cSELLERCODE	:= HttpSession->CODVENERP 
	oObj:cPROSPECTID	:= HttpSession->PWSV132RESULT[1][Val( HttpGet->cProspect )]:cPROSPECTCODE
	
	//cUSERCODE,cSELLERCODE,cPROSPECTID
	If oObj:GETPROSPECT()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Retorno do metodo GETPROSPECT³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		HttpSession->PWSV133RESULT := { oObj:oWSGETPROSPECTRESULT }
	Else
		Return PWSHtmlAlert( "", STR0003,;	//Atencao
							 "", "W_PWSV131.APW" )
	EndIf
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inclusao de novo prospect   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	HttpSession->PWSV133APH[1] := STR0001 + STR0005		// Inclusao - Dados Cadastrais

	aAdd( HttpSession->PWSV133RESULT, CRMPROSPECT_PROSPECTVIEW():New() )

	HttpSession->PWSV133RESULT[1]:oWSADDRESSES 		:= CRMPROSPECT_ARRAYOFADDRESSVIEW():New()
	HttpSession->PWSV133RESULT[1]:oWSPHONES 		:= CRMPROSPECT_ARRAYOFPHONEVIEW():New()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializador Padrao: Loja do Prospect = 01   		³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	HttpSession->PWSV133RESULT[1]:cUNITPROSPECTCODE	:= "01"	
EndIf
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Endereco do Prospect³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 To Len( Httpsession->PWSV133TYPES[1][1] )
	If Empty( HttpSession->PWSV133RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW )
		nPosEnd := 0
	Else
		nPosEnd := aScan( HttpSession->PWSV133RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW, { |x| x:cTYPEOFADDRESS == Str( nI, 1 ) } )
	EndIf
	
	If nPosEnd == 0
		aAdd( HttpSession->PWSV133RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW, CRMPROSPECT_ADDRESSVIEW():New() )
		aTail( HttpSession->PWSV133RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW ):cTYPEOFADDRESS := Str( nI, 1 )
	EndIf
Next nI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Telefones :         ³
//³Comercial   - Tipo 1³
//³FAX         - Tipo 2³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 To Len( Httpsession->PWSV133TYPES[2][1] )
	If Empty( HttpSession->PWSV133RESULT[1]:oWSPHONES:oWSPHONEVIEW )
		nPosTel := 0
	Else
		nPosTel := aScan( HttpSession->PWSV133RESULT[1]:oWSPHONES:oWSPHONEVIEW, { |x| x:cTYPEOFPHONE == Str( nI, 1 ) } )
	EndIf

	If nPosTel == 0
		aAdd( HttpSession->PWSV133RESULT[1]:oWSPHONES:oWSPHONEVIEW, CRMPROSPECT_PHONEVIEW():New() )
		aTail( HttpSession->PWSV133RESULT[1]:oWSPHONES:oWSPHONEVIEW ):cTYPEOFPHONE := Str( nI, 1 )
	EndIf
Next nI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Enderecos ordenado pelo Tipo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpSession->PWSV133RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW := aSort( HttpSession->PWSV133RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW,,, { |x, y| x:cTYPEOFADDRESS < y:cTYPEOFADDRESS } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Telefones ordenado pelo Tipo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpSession->PWSV133RESULT[1]:oWSPHONES:oWSPHONEVIEW := aSort( HttpSession->PWSV133RESULT[1]:oWSPHONES:oWSPHONEVIEW,,, { |x, y| x:cTYPEOFPHONE < y:cTYPEOFPHONE } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada - Dados do Prospect³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "PEV133" )
	aWebCols := ExecBlock( "PEV133", .F., .F., { 1 } )
Else
	If HttpGet->cAcao == "A"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Alteracao do prospect ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAdd( aWebCols, { "PROSPECTCODE", "D" } )
		aAdd( aWebCols, { "UNITPROSPECTCODE", "D" } )
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inclusao do Prospect ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAdd( aWebCols, { "PROSPECTCODE", "D" } )	
		aAdd( aWebCols, { "UNITPROSPECTCODE", "D" } )
	EndIf

	aAdd( aWebCols, "NAME" )
	aAdd( aWebCols, "NICKNAME" )
	aAdd( aWebCols, "TYPE" )
	aAdd( aWebCols, "FEDERALID" )
	aAdd( aWebCols, "EMAIL" )
	aAdd( aWebCols, "HOMEPAGE" )
	aAdd( aWebCols, { "CUSTOMERCODE", "D" } )
	aAdd( aWebCols, { "UNITCUSTOMERCODE", "D" } )
	aAdd( aWebCols, "LASTVISIT" )
	aAdd( aWebCols, "SELLERCODE" )
	aAdd( aWebCols, "STATUSCODE" )
	aAdd( aWebCols, "ORIGINCODE" )
	aAdd( aWebCols, "SUPPLIERCODE")

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Funcao de montagem da descricao dos campos da tela³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
GridLinesEx( { 	HttpSession->PWSV133INFO[1]		, HttpSession->PWSV131HEADER[1][1]	,;
				HttpSession->PWSV133RESULT[1]	, aWebCols							,;
				.T.								, "H",, 1 }, "CRMPROSPECT", "SUS" )

aWebCols := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada - Endereco do Prospect³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "PEV133" )
	aWebCols := ExecBlock( "PEV133", .F., .F., { 2 } )
Else
	aAdd( aWebCols, "ADDRESS" )
	aAdd( aWebCols, "ADDRESSNUMBER" )
	aAdd( aWebCols, "DISTRICT" )
	aAdd( aWebCols, { "STATE", "N", { "GETUF", ;
										{ "CSTATE", "CCODE" };
									}, ;
									{ "CCODE", "CDESCRIPTION" } } )
	aAdd( aWebCols, "ZIPCODE" )
	aAdd( aWebCols, "ZONE" )
EndIf

For nI := 1 To Len( HttpSession->PWSV133RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW )
	aAdd( HttpSession->PWSV133INFO[2], {} )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Funcao de montagem da descricao dos campos da tela³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	GridLinesEx( { 	HttpSession->PWSV133INFO[2][nI]									, HttpSession->PWSV131HEADER[2][1]	,;
					HttpSession->PWSV133RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW[nI]	, aWebCols							,;
					.T.																, "H", Str( nI, 1 ), 2 } )
Next nI
     
aWebCols := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada - Telefone do Prospect³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "PEV133" )
	aWebCols := ExecBlock( "PEV133", .F., .F., { 3 } )
Else
	aAdd( aWebCols, "COUNTRYAREACODE" )
	aAdd( aWebCols, "LOCALAREACODE" )
	aAdd( aWebCols, "PHONENUMBER" )
EndIf

aAdd( HttpSession->PWSV133INFO[3], {} )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Funcao de montagem da descricao dos campos da tela³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
GridLinesEx( { 	HttpSession->PWSV133INFO[3][1]							, HttpSession->PWSV131HEADER[3][1]	,;
				HttpSession->PWSV133RESULT[1]:oWSPHONES:oWSPHONEVIEW[1], aWebCols							,;
				.T.														, "H", "1", 2 } )

aWebCols := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada - Telefone do Prospect³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "PEV133" )
	aWebCols := ExecBlock( "PEV133", .F., .F., { 4 } )
Else
	aAdd( aWebCols, "PHONENUMBER" )
EndIf

For nI := 2 To Len( HttpSession->PWSV133RESULT[1]:oWSPHONES:oWSPHONEVIEW )
	aAdd( HttpSession->PWSV133INFO[3], {} )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Funcao de montagem da descricao dos campos da tela³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	GridLinesEx( { 	HttpSession->PWSV133INFO[3][nI]								, HttpSession->PWSV131HEADER[3][1]	,;
					HttpSession->PWSV133RESULT[1]:oWSPHONES:oWSPHONEVIEW[nI]	, aWebCols							,;
					.T.															, "H", Str( nI, 1 ), IIf( nI <> Len( HttpSession->PWSV133RESULT[1]:oWSPHONES:oWSPHONEVIEW ), 2, 3 ) } )
Next nI

cHtml += ExecInPage( "PWSV133" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSV134   ºAutor  ³Luiz Felipe Couto    º Data ³  21/03/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Inclusao ou alteracao do prospect.                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Portal Protheus                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºCleber M. ³27/03/06³95776 ³- Corrigido o conteudo da variavel           º±±
±±º			 ³		  ³		 ³	HttpPost->cProspect						   º±±
±±ºCleber M. ³26/12/06³116041³- Tratamento do conteudo a ser enviado no    º±±
±±º			 ³		  ³		 ³	botao Voltar.							   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSV134()

Local cHtml := ""						//Pagina WEB
Local nI	:= 0						//Variavel de apoio
Local oObjCRM							//Objeto WS - WSCRMPROSPECT
Local oCFGVal							//Objeto WS - WSCFGVALIDATION
Local oObjClone							//Objeto WS - Clone


WEB EXTENDED INIT cHtml START "InSite"


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa Objeto WS - WSCRMSELLERCUSTOMERCONTACT³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObjCRM := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSCRMPROSPECT' ), WSCRMPROSPECT():New() )
WsChgUrl( @oObjCRM, "CRMPROSPECT.APW" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa Objeto WS - WSCFGVALIDATION³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oCFGVal := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSCFGVALIDATION' ), WSCFGVALIDATION():NEW() )
WsChgUrl( @oCFGVal, "CFGVALIDATION.APW" )

//Forçar a instancia de campo de usuario no HttpSession
aProp := PWVPutUsrFld( HttpSession->PWSV133RESULT[1], "SUS", "CRMPROSPECT" )
nPos 	:= aScan( aProp, { |x| x[1] == "OWSUSERFIELDS" } )
HttpSession->PWSV133RESULT[1]:oWSuserfields := aProp[nPos][2]

PWSSetObjToPost( HttpSession->PWSV133RESULT[1], HttpSession->PWSV131HEADER[1][1], HttpPost->aPost )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica CNPJ / CGC³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty( HttpSession->PWSV133RESULT[1]:cFEDERALID )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Parametros do metodo CHECKFEDERALID³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oCFGVal:cUSERCODE	:= GetUsrCode()
	oCFGVal:cCOUNTRY	:= "BRA"
	oCFGVal:cFEDERALID	:= HttpSession->PWSV133RESULT[1]:cFEDERALID
	
	//cUSERCODE,cCOUNTRY,cFEDERALID
	If !oCFGVal:CHECKFEDERALID()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Trata o conteudo a ser enviado no botao Voltar ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If HttpPost->cAcao == "A"
			HttpPost->cProspect := HttpSession->cProspect
		Else
			HttpPost->cProspect := oObjCRM:oWSPROSPECT:cORIGINCODE
		EndIf
		Return PWSHtmlAlert( "", STR0003,;	//Atencao
							 "", "W_PWSV133.APW?cProspect=" + HttpPost->cProspect + "&cAcao=" + HttpPost->cAcao )
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Armazena Informacoes do Contato - PROSPECTVIEW³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PWSSetObjToPost( HttpSession->PWSV133RESULT[1], HttpSession->PWSV131HEADER[1][1], HttpPost->aPost )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Armazena Informacoes do Endereco do Prospect - ADDRESSVIEW³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 To Len( HttpSession->PWSV133RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW )
	PWSSetObjToPost( 	HttpSession->PWSV133RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW[nI]	,;
						HttpSession->PWSV131HEADER[2][1]								,;
						HttpPost->aPost, Str( nI, 1 ) )
Next nI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Armazena Informacoes do Telefone do Prospect - PHONEVIEW³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 To Len( HttpSession->PWSV133RESULT[1]:oWSPHONES:oWSPHONEVIEW )
	PWSSetObjToPost( 	HttpSession->PWSV133RESULT[1]:oWSPHONES:oWSPHONEVIEW[nI]	,;
						HttpSession->PWSV131HEADER[3][1]							,;
						HttpPost->aPost, Str( nI, 1 ) )
Next nI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Clone do Objeto WS                                           |
//³Utilizado para a armazenagem da Session no Objeto de Gravacao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObjClone := HttpSession->PWSV133RESULT[1]:CLONE()

If HttpPost->cAcao == "A" .OR. HttpPost->cAcao == "I"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Parametros do metodo PUTPROSPECT³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oObjCRM:cUSERCODE		:= GetUsrCode()
	oObjCRM:cSELLERCODE		:= HttpSession->CODVENERP
	oObjCRM:oWSPROSPECT 	:= oObjClone
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Endereco do Prospect³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oObjCRM:oWSPROSPECT:oWSADDRESSES := CRMPROSPECT_ARRAYOFADDRESSVIEW():New()
	
	For nI := 1 To Len( HttpSession->PWSV133RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW )
		aAdd( oObjCRM:oWSPROSPECT:oWSADDRESSES:oWSADDRESSVIEW, CRMPROSPECT_ADDRESSVIEW():New() )

		oObjCRM:oWSPROSPECT:oWSADDRESSES:oWSADDRESSVIEW[nI]:cADDRESS		:= HttpSession->PWSV133RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW[nI]:cADDRESS
		oObjCRM:oWSPROSPECT:oWSADDRESSES:oWSADDRESSVIEW[nI]:cADDRESSNUMBER	:= HttpSession->PWSV133RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW[nI]:cADDRESSNUMBER
		oObjCRM:oWSPROSPECT:oWSADDRESSES:oWSADDRESSVIEW[nI]:cDISTRICT		:= HttpSession->PWSV133RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW[nI]:cDISTRICT
		oObjCRM:oWSPROSPECT:oWSADDRESSES:oWSADDRESSVIEW[nI]:cSTATE			:= HttpSession->PWSV133RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW[nI]:cSTATE
		oObjCRM:oWSPROSPECT:oWSADDRESSES:oWSADDRESSVIEW[nI]:cTYPEOFADDRESS	:= HttpSession->PWSV133RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW[nI]:cTYPEOFADDRESS
		oObjCRM:oWSPROSPECT:oWSADDRESSES:oWSADDRESSVIEW[nI]:cZIPCODE		:= HttpSession->PWSV133RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW[nI]:cZIPCODE
		oObjCRM:oWSPROSPECT:oWSADDRESSES:oWSADDRESSVIEW[nI]:cZONE			:= HttpSession->PWSV133RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW[nI]:cZONE
	Next nI
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Telefone do Prospect³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oObjCRM:oWSPROSPECT:oWSPHONES := CRMPROSPECT_ARRAYOFPHONEVIEW():New()
	
	For nI := 1 To Len( HttpSession->PWSV133RESULT[1]:oWSPHONES:oWSPHONEVIEW )
		aAdd( oObjCRM:oWSPROSPECT:oWSPHONES:oWSPHONEVIEW, CRMPROSPECT_PHONEVIEW():New() )

		oObjCRM:oWSPROSPECT:oWSPHONES:oWSPHONEVIEW[nI]:cCOUNTRYAREACODE 	:= HttpSession->PWSV133RESULT[1]:oWSPHONES:oWSPHONEVIEW[nI]:cCOUNTRYAREACODE
		oObjCRM:oWSPROSPECT:oWSPHONES:oWSPHONEVIEW[nI]:cLOCALAREACODE 		:= HttpSession->PWSV133RESULT[1]:oWSPHONES:oWSPHONEVIEW[nI]:cLOCALAREACODE
		oObjCRM:oWSPROSPECT:oWSPHONES:oWSPHONEVIEW[nI]:cPHONENUMBER 		:= HttpSession->PWSV133RESULT[1]:oWSPHONES:oWSPHONEVIEW[nI]:cPHONENUMBER
		oObjCRM:oWSPROSPECT:oWSPHONES:oWSPHONEVIEW[nI]:cTYPEOFPHONE			:= HttpSession->PWSV133RESULT[1]:oWSPHONES:oWSPHONEVIEW[nI]:cTYPEOFPHONE
	Next nI

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Grava Informacoes do Prospect³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//cUSERCODE,cSELLERCODE,oWSPROSPECT
	If oObjCRM:PUTPROSPECT()
		HttpGet->cProspect := oObjCRM:cPUTPROSPECTRESULT

		Return PWSHtmlAlert( "",STR0003,;		//Atencao
							 	STR0008,;		//Informacoes cadastradas com SUCESSO!
							  	"W_PWSV130.APW" )
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Trata o conteudo a ser enviado no botao Voltar ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If HttpPost->cAcao == "A"
			HttpPost->cProspect := HttpSession->cProspect
		Else
			HttpPost->cProspect := oObjCRM:oWSPROSPECT:cORIGINCODE
		EndIf
		Return PWSHtmlAlert( "", STR0003,;		//Atencao
							 "", "W_PWSV133.APW?cProspect=" + HttpPost->cProspect + "&cAcao=" + HttpPost->cAcao )
	EndIf
EndIf

WEB EXTENDED END

Return cHtml
