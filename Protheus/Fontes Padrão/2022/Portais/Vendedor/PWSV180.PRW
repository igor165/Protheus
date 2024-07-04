#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
#INCLUDE "PWSV180.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSV18*   ºAutor  ³Luiz Felipe Couto    º Data ³  18/03/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Este fonte possui as funcionalidades relacionado aos        º±±
±±º          ³ contatos do cliente.                                        º±±
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
±±ºPrograma  ³PWSV180   ºAutor  ³Luiz Felipe Couto    º Data ³  18/03/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Mostra os vendedores disponiveis para o usuario logado.     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Portal Protheus                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºCleber M. ³28/06/07³126840³- Alteracao de algumas strings que estavam   º±±
±±º          ³        ³      ³incorretas nos titulos das telas.            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSV180()

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
HttpSession->PWSV020APH	:= { 	STR0001,; 						//"Contatos"
								"W_PWSV181.APW",;				//Pagina para onde sera enviado o POST
								"" }							//Mensagem a ser mostrada na tela
	
Do Case
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Nao ha vendedores cadastrados para o usuario logado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case Empty( aVend )
		HttpSession->PWSC020APH[3] := STR0002 					//"Não há vendedores a consultar."
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Apenas 1 vendedor cadastrado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case Len( aVend ) == 2
		HttpSession->CODVENERP := aVend[2][2]

		Return W_PWSV181()

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
±±ºPrograma  ³PWSV181   ºAutor  ³Luiz Felipe Couto    º Data ³  18/03/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela de apresentacao da busca do cliente.                   º±±
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
Web Function PWSV181()

Local cHtml 	:= ""					//Pagina WEB
Local aWebCols 	:= {}					//Array de campos a serem mostrados na tela
Local oObjSeller						//Objeto WS - WSMTSELLERCUSTOMER
Local oObjIndex							//Objeto WS - WSCFGDICTIONARY
Local oObjCRMSeller						//Objeto WS - WSCRMSELLERCUSTOMERCONTACT

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Informacoes a serem utilizadas pelo APH³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpSession->PWSV181APH := { 	STR0001+" - "+;    	//Contatos
								STR0009,; 			//Busca CLIENTES
								"W_PWSV182.APW" }	//Pagina para onde sera enviado o POST


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa o objeto WS - WSMTSELLERCUSTOMER³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObjSeller 	:= IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTSELLERCUSTOMER' ), WSMTSELLERCUSTOMER():New() )
WsChgUrl( @oObjSeller, "MTSELLERCUSTOMER.apw" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa o objeto WS - WSCFGDICTIONARY³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObjIndex 	:= IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSCFGDICTIONARY' ), WSCFGDICTIONARY():New() )
WsChgUrl( @oObjIndex, "CFGDICTIONARY.APW" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa Objeto WS - WSCRMSELLERCUSTOMERCONTACT³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObjCRMSeller := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSCRMSELLERCUSTOMERCONTACT' ), WSCRMSELLERCUSTOMERCONTACT():New() )
WsChgUrl( @oObjCRMSeller, "CRMSELLERCUSTOMERCONTACT.APW" )


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Array contendo os headers dos WS utilizados nesta pagina³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty( HttpSession->PWSV181HEADER )
	HttpSession->PWSV181HEADER := { NIL, NIL, NIL, NIL, NIL, NIL }
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Header da estrutura CUSTOMERVIEW - Cliente³
	//³- CUSTOMERCODE     : Codigo               ³
	//³- UNITCUSTOMERCODE : Loja                 ³
	//³- NAME             : Nome                 ³
	//³- NICKNAME         : Nome Fantasia        ³
	//³- FEDERALID        : CNPJ                 ³
	//³- STATEID          : IE                   ³
	//³- DISTRICTID       : Municipio            ³
	//³- HOMEPAGE         : HomePage             ³
	//³- EMAIL            : E-mail               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty( HttpSession->PWSV181HEADER[1] )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Parametros do metodo GETHEADER³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oObjSeller:cHEADERTYPE := "CUSTOMERVIEW"

		//cHEADERTYPE
		If oObjSeller:GETHEADER()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Retorno do Metodo GETHEADER³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			HttpSession->PWSV181HEADER[1] := { oObjSeller:oWSGETHEADERRESULT:oWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0003		,; //Atencao
								 "", "W_PWSV180.APW" )
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Header da estrutura do WS CFGDICTIONARY³
	//|- CODE        : Ordem                  |
	//|- DESCRIPTION : Chave                  |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty( HttpSession->PWSV181HEADER[2] )
		If oObjIndex:GETHEADER()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Retorno do Metodo GETHEADER³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			HttpSession->PWSV181HEADER[2] := { oObjIndex:oWSGETHEADERRESULT:oWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0003		,;	//Atencao
								 "", "W_PWSV180.APW" )
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Header da estrutura GENERICVIEW2 ³
	//|- CODE        : Codigo do Cliente|
	//|- UNIT        : Loja do Cliente  |
	//|- DESCRIPTION : Nome do Cliente  |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty( HttpSession->PWSV181HEADER[3] )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Parametros do metodo GETHEADER³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oObjSeller:cHEADERTYPE := "GENERICVIEW2"

		//cHEADERTYPE
		If oObjSeller:GETHEADER()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Retorno do Metodo GETHEADER³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			HttpSession->PWSV181HEADER[3] := { oObjSeller:oWSGETHEADERRESULT:oWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0003		,; //Atencao
								"", "W_PWSV180.APW" )
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Header da estrutura CONTACTVIEW - Contato          ³
	//|- CONTACTID             : Codigo                   |
	//|- NAME                  : Nome                     |
	//|- FEDERALID             : CNPJ                     |
	//|- EMAIL                 : E-mail                   |
	//|- HOMEPAGE              : HomePage                 |
	//|- POSITION              : Cargo                    |
	//|- POSITIONDESCRIPTION   : Descricao do Cargo       |
	//|- GROUP                 : Grupo                    |
	//|- GROUPDESCRIPTION      : Descricao do Grupo       |
	//|- DEPARTMENT            : Departamento             |
	//|- DEPARTMENTDESCRIPTION : Descricao do Departamento|
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty( HttpSession->PWSV181HEADER[4] )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Parametros do metodo GETHEADER³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oObjCRMSeller:cHEADERTYPE := "CONTACTVIEW"

		//cHEADERTYPE
		If oObjCRMSeller:GETHEADER()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Retorno do Metodo GETHEADER³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			HttpSession->PWSV181HEADER[4] := { oObjCRMSeller:oWSGETHEADERRESULT:oWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0003		,;	//Atencao
								 "", "W_PWSV180.APW" )
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
	If Empty( HttpSession->PWSV181HEADER[5] )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Parametros do metodo GETHEADER³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oObjCRMSeller:cHEADERTYPE := "ADDRESSVIEW"

		//cHEADERTYPE
		If oObjCRMSeller:GETHEADER()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Retorno do Metodo GETHEADER³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			HttpSession->PWSV181HEADER[5] := { oObjCRMSeller:oWSGETHEADERRESULT:OWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0003		,;		//Atencao
								 "", "W_PWSV180.APW" )
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Header da estrutura PHONEVIEW - Telefone³
	//|- COUNTRYAREACODE : DDI                 |
	//|- LOCALAREACODE   : DDD                 |
	//|- PHONENUMBER     : Numero              |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty( HttpSession->PWSV181HEADER[6] )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Parametros do metodo GETHEADER³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oObjCRMSeller:cHEADERTYPE := "PHONEVIEW"

		//cHEADERTYPE
		If oObjCRMSeller:GETHEADER()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Retorno do Metodo GETHEADER³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			HttpSession->PWSV181HEADER[6] := { oObjCRMSeller:oWSGETHEADERRESULT:OWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0003		,;		//Atencao
								 "", "W_PWSV180.APW" )
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Indices da Tabela SA1³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty( HttpSession->PWSV181INDEX )
	HttpSession->PWSV181INDEX := {}
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Parametros do metodo GETINDEX³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oObjIndex:cUSERCODE 	:= GetUsrCode()
	oObjIndex:cTABLE 		:= "SA1"
	
	//cUSERCODE,cTABLE
	If oObjIndex:GETINDEX()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Resultado do Metodo GETINDEX³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		HttpSession->PWSV181INDEX := { oObjIndex:oWSGETINDEXRESULT:oWSGENERICSTRUCT }
	Else
		Return PWSHtmlAlert( "", STR0003		,; //Atencao
							 "", "W_PWSV180.APW" )
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Dados para montagem da Tela de Busca³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty( HttpSession->PWSV181BUSCA )
	HttpSession->PWSV181BUSCA := { {}, {} }
                          
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de Entrada - Campos do WS WSMTSELLERCUSTOMER³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock( "PEV181" )
		aWebCols := ExecBlock( "PEV181", .F., .F., { 1 } )
	Else
		aAdd( aWebCols, "NAME" )
		aAdd( aWebCols, "NICKNAME" )
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Funcao de montagem da descricao dos campos da tela³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	GridHeader( HttpSession->PWSV181BUSCA[1], HttpSession->PWSV181HEADER[1][1], aWebCols )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Funcao de montagem dos campos da tela³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	GridLinesEX( { 	HttpSession->PWSV181BUSCA[1]			, HttpSession->PWSV181HEADER[1][1]	,;
					MTSELLERCUSTOMER_CUSTOMERVIEW():New()	, 	aWebCols						,;
					.T.										, "A",, 0 },"MTSELLERCUSTOMER")
	
	aWebCols := {}
                                 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de Entrada - Campos do WS WSCFGDICTIONARY³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock( "PEV181" )
		aWebCols := ExecBlock( "PEV181", .F., .F., { 2 } )
	Else
		aAdd( aWebCols, "CODE" )
		aAdd( aWebCols, "DESCRIPTION" )
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Funcao de montagem da descricao dos campos da tela³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   	GridHeader( HttpSession->PWSV181BUSCA[2], HttpSession->PWSV181HEADER[2][1], aWebCols )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Funcao de montagem dos campos da tela³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	GridLinesEX( { HttpSession->PWSV181BUSCA[2]		, HttpSession->PWSV181HEADER[2][1]	,;
					HttpSession->PWSV181INDEX[1]	, aWebCols							,;
					.F.								, "A",, 0 } )
EndIf

cHtml += ExecInPage( "PWSV181" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSV182   ºAutor  ³Luiz Felipe Couto    º Data ³  18/03/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela de retorno da busca de clientes.                       º±±
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
Web Function PWSV182()

Local cHtml 	:= ""					//Pagina WEB
Local aWebCols 	:= {}					//Array de campos a serem mostrados na tela
Local oObj

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Informacoes a serem mostradas na tela³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpSession->PWSV182APH := { 	STR0001 + " - " + STR0010	,; 	//Contatos - Resultado da Busca CLIENTES
								"W_PWSV183.APW"				,;	//Pagina para onde sera enviado o POST
								"W_PWSV181.APW" }				//Pagina de volta do Resultado da Busca

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Array para montagem da tela³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpSession->PWSV182INFO := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa o objeto WS - WSMTSELLERCUSTOMER³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSMTSELLERCUSTOMER' ), WSMTSELLERCUSTOMER():New() )
WsChgURL( @oObj, "MTSELLERCUSTOMER.APW" )

If !Empty( HttpPost->CNAME ) .OR. !Empty( HttpPost->CNICKNAME )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Parametros do metodo BRWCUSTOMER³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oObj:cUSERCODE		:= GetUsrCode()
	oObj:cSELLERCODE	:= HttpSession->CODVENERP
	oObj:nPAGELEN		:= 0
	oObj:nPAGEFIRST		:= 0
	oObj:cNAMELIKE		:= IIf( !Empty( HttpPost->CNAME ), Upper( HttpPost->CNAME ), "" )
	oObj:cNICKNAMELIKE	:= IIf( !Empty( HttpPost->CNICKNAME ), Upper( HttpPost->CNICKNAME ), "" )
	oObj:cQUERYADDWHERE	:= ""
	oObj:cINDEXKEY		:= HttpPost->CINDEX

	//cUSERCODE,cSELLERCODE,nPAGELEN,nPAGEFIRST,cNAMELIKE,cNICKNAMELIKE,cQUERYADDWHERE,cINDEXKEY
	If oObj:BRWCUSTOMER()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Retorno do metodo BRWCUSTOMER³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		HttpSession->PWSV182RESULT := { oObj:oWSBRWCUSTOMERRESULT:oWSGENERICVIEW2 }
	Else
		Return PWSHtmlAlert( "", STR0003		,;		//Atencao
							 "", "W_PWSV180.APW" )
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica Resultado da Busca³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty( HttpSession->PWSV182RESULT ) .AND. Len( HttpSession->PWSV182RESULT[1] ) > 0
	aWebCols := {}
	                                    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de Entrada - Dados do Cliente³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock( "PEV182" )
		aWebCols := ExecBlock( "PEV182", .F., .F., {} )
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Funcao de montagem da descricao dos campos da tela³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	GridHeader( HttpSession->PWSV182INFO, HttpSession->PWSV181HEADER[3][1], aWebCols )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Funcao de montagem dos campos da tela³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	GridLinesEX( { 	HttpSession->PWSV182INFO		, HttpSession->PWSV181HEADER[3][1]	,;
					HttpSession->PWSV182RESULT[1]	, aWebCols							,;
					.F.								, "A",, 0 } )
Else
	Return PWSHtmlAlert( "",STR0003	,;		//Atencao
							STR0005	,; 		//A busca nao retornou nenhum cliente cadastrado para este vendedor.
						 "W_PWSV181.APW" )
EndIf

cHtml += ExecInPage( "PWSV182" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSV183   ºAutor  ³Luiz Felipe Couto    º Data ³  18/03/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela com os contatos para o cliente selecionado.            º±±
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
Web Function PWSV183()

Local cHtml 	:= ""				//Pagina WEB
Local aWebCols 	:= {}				//Array com os campos a serem mostrados na tela
Local oObj							//Objeto WS - WSCRMSELLERCUSTOMERCONTACT

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Array com as informacoes a serem mostradas na tela³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpSession->PWSV183APH := { 	STR0001			,;			//"Contatos"
							  	"W_PWSV183.APW"	,;			//Pagina para onde sera enviado o POST
							  	"W_PWSV184.APW"	,;			//Pagina de Inclusao do Contato
							  	"W_PWSV181.APW" }			//Pagina de Volta

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa Objeto WS - WSCRMSELLERCUSTOMERCONTACT³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSCRMSELLERCUSTOMERCONTACT' ), WSCRMSELLERCUSTOMERCONTACT():New() )
WsChgUrl( @oObj, "CRMSELLERCUSTOMERCONTACT.APW" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametros do metodo BRWCONTACT³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cUSERCODE 		:= GetUsrCode()
oObj:cSELLERCODE 	:= HttpSession->CODVENERP
oObj:cCUSTOMERID 	:= HttpGet->cCUSTOMERID

//cUSERCODE,cSELLERCODE,cCUSTOMERID,cQUERYADDWHERE
If oObj:BRWCONTACT()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Informacoes dos campos que seram mostrados na tela³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	HttpSession->PWSV183INFO := {}
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Retorno do metodo WS³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	HttpSession->PWSV183RESULT := {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Retorno do metodo BRWCONTACT³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	HttpSession->PWSV183RESULT := { oObj:oWSBRWCONTACTRESULT:oWSCONTACTVIEW }

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Ponto de Entrada WS - WSCRMSELLERCUSTOMERCONTACT³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock( "PEV183" )
		aWebCols := ExecBlock( "PEV183", .F., .F., {} )
	Else
		aAdd( aWebCols, "CONTACTID" )
		aAdd( aWebCols, "NAME" )
		aAdd( aWebCols, "FEDERALID" )
		aAdd( aWebCols, "EMAIL" )
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Funcao de montagem da descricao dos campos da tela³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	GridHeader( HttpSession->PWSV183INFO, HttpSession->PWSV181HEADER[4][1], aWebCols )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Funcao de montagem dos campos da tela³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	GridLinesEX( { 	HttpSession->PWSV183INFO		, HttpSession->PWSV181HEADER[4][1]	,;
					HttpSession->PWSV183RESULT[1]	, aWebCols							,;
					.F.								, "A",, 0 } )
Else
	Return PWSHtmlAlert( "", STR0003		,;	//Atencao
						 "", "W_PWSV181.APW" )
EndIf

cHtml := ExecInPage( "PWSV183" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSV184   ºAutor  ³Luiz Felipe Couto    º Data ³  18/03/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela com os dados do contato selecionado.                   º±±
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
Web Function PWSV184()

Local cHtml 		:= ""						//Pagina WEB
Local nI 			:= 0						//Variavel de apoio
Local nPosCli		:= 0						//Posicao do cliente no array de Clientes
Local nPosCon		:= 0						//Posicao do contato no array de Contatos
Local nPosEnd		:= 0						//Posicao do tipo do endereco dentro do array de Enderecos do Contato
Local nPosTel		:= 0						//Posicao do tipo do telefone dentro do array de Telefones do Contato
Local aWebCols 		:= {}						//Array contendo os campos que serao utilizados na tela
Local oObj										//Objeto WS - WSCRMSELLERCUSTOMERCONTACT

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Array com as informacoes a serem mostradas na tela³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpSession->PWSV184APH := { 	""				,;			//Titulo da pagina
								"W_PWSV185.APW"	,;			//Pagina para onde sera enviado o POST
								"W_PWSV181.APW" }			//Pagina de Volta

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Session de armazenagem do objeto WS³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpSession->PWSV184RESULT := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Informacoes dos campos que seram mostrados na tela³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpSession->PWSV184INFO := { {}, {}, {} }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa Objeto WS - WSCRMSELLERCUSTOMERCONTACT³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSCRMSELLERCUSTOMERCONTACT' ), WSCRMSELLERCUSTOMERCONTACT():New() )
WsChgUrl( @oObj, "CRMSELLERCUSTOMERCONTACT.APW" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Array com os tipos de informacoes que serao apresentados na tela³
//³Ex: Tipo de Telefone, Tipos de Endereco, etc.                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty( Httpsession->PWSV184TYPES )
	Httpsession->PWSV184TYPES := { NIL, NIL }
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tipos de Endereco³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty( Httpsession->PWSV184TYPES[1] )
		If oObj:GETTYPEOFADDRESS()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Retorno do metodo GETTYPEOFADDRESS³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Httpsession->PWSV184TYPES[1] := { oObj:oWSGETTYPEOFADDRESSRESULT:oWSGENERICSTRUCT }
		Else
			Return PWSHtmlAlert( "", STR0003		,;	//Atencao
								 "", "W_PWSV184.APW" )
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tipos de Telefone³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty( Httpsession->PWSV184TYPES[2] )
		If oObj:GETTYPEOFPHONE()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Retorno do metodo GETTYPEOFPHONE³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Httpsession->PWSV184TYPES[2] := { oObj:oWSGETTYPEOFPHONERESULT:oWSGENERICSTRUCT }
		Else
			Return PWSHtmlAlert( "", STR0003		,;	//Atencao
								 "", "W_PWSV184.APW" )
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Alteracao de Contatos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If HttpGet->cAcao == "A"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posicao do contato dentro do array de retorno do metodo BRWCONTACT³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nPosCon := ascan( HttpSession->PWSV183RESULT[1], { |x| x:cCONTACTID == HttpGet->cCONTACTID } )

	If nPosCon > 0
		HttpSession->PWSV184APH[1] :=	STR0001+" - "+;		//Contatos
										STR0008+" "+;		//Dados Cadastrais
										HttpSession->PWSV183RESULT[1][nPosCon]:cNAME 
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Parametros do metodo GETCONTACT³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oObj:cUSERCODE		:= GetUsrCode()
		oObj:cSELLERCODE	:= HttpSession->CODVENERP
		oObj:cCONTACTID		:= HttpGet->cCONTACTID
		
		//cUSERCODE,cSELLERCODE,cCONTACTID
		If oObj:GETCONTACT()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Retorno do metodo GETCONTACT³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			HttpSession->PWSV184RESULT := { oObj:oWSGETCONTACTRESULT }
		Else
			Return PWSHtmlAlert( "", STR0003		,;	//Atencao
								 "", "W_PWSV183.APW" )
		EndIf
	EndIf
Else
	HttpSession->PWSV184APH[1] := STR0006		//Inclusao - Dados cadastrais

	aAdd( HttpSession->PWSV184RESULT, CRMSELLERCUSTOMERCONTACT_CONTACTVIEW():New() )

	HttpSession->PWSV184RESULT[1]:oWSADDRESSES 	:= CRMSELLERCUSTOMERCONTACT_ARRAYOFADDRESSVIEW():New()
	HttpSession->PWSV184RESULT[1]:oWSPHONES 	:= CRMSELLERCUSTOMERCONTACT_ARRAYOFPHONEVIEW():New()
EndIf
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Endereco do Contato³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 To Len( Httpsession->PWSV184TYPES[1][1] )
	If Empty( HttpSession->PWSV184RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW )
		nPosEnd := 0
	Else
		nPosEnd := aScan( HttpSession->PWSV184RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW, { |x| x:cTYPEOFADDRESS == Str( nI, 1 ) } )
	EndIf
	
	If nPosEnd == 0
		aAdd( HttpSession->PWSV184RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW, CRMSELLERCUSTOMERCONTACT_ADDRESSVIEW():New() )
		aTail( HttpSession->PWSV184RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW ):cTYPEOFADDRESS := Str( nI, 1 )
	EndIf
Next nI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Telefones :         ³
//³Comercial   - Tipo 1³
//³FAX         - Tipo 2³
//³Celular     - Tipo 3³
//|Residencial - Tipo 4|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 To Len( Httpsession->PWSV184TYPES[2][1] )
	If Empty( HttpSession->PWSV184RESULT[1]:oWSPHONES:oWSPHONEVIEW )
		nPosTel := 0
	Else
		nPosTel := aScan( HttpSession->PWSV184RESULT[1]:oWSPHONES:oWSPHONEVIEW, { |x| x:cTYPEOFPHONE == Str( nI, 1 ) } )
	EndIf

	If nPosTel == 0
		aAdd( HttpSession->PWSV184RESULT[1]:oWSPHONES:oWSPHONEVIEW, CRMSELLERCUSTOMERCONTACT_PHONEVIEW():New() )
		aTail( HttpSession->PWSV184RESULT[1]:oWSPHONES:oWSPHONEVIEW ):cTYPEOFPHONE := Str( nI, 1 )
	EndIf
Next nI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Telefones ordenado pelo Tipo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpSession->PWSV184RESULT[1]:oWSPHONES:oWSPHONEVIEW := aSort( HttpSession->PWSV184RESULT[1]:oWSPHONES:oWSPHONEVIEW,,, { |x, y| x:cTYPEOFPHONE < y:cTYPEOFPHONE } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada - Dados do Contato³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "PEV184" )
	aWebCols := ExecBlock( "PEV184", .F., .F., { 1 } )
Else
	If HttpGet->cAcao == "A"
		aAdd( aWebCols, { "CONTACTID", "D" } )
	EndIf
	
	aAdd( aWebCols, "NAME" )
	aAdd( aWebCols, "FEDERALID" )
	aAdd( aWebCols, "EMAIL" )
	aAdd( aWebCols, "HOMEPAGE" )
	aAdd( aWebCols, { "POSITION", "N", { "GETPOSITION",;
											{ "CPOSITION"			, "CCODE" }				,;
											{ "CPOSITIONDESCRIPTION", "CDESCRIPTION" } }	,;
										{ "CCODE", "CDESCRIPTION" } } )
	aAdd( aWebCols, { "POSITIONDESCRIPTION", "D" } )
	aAdd( aWebCols, { "GROUP", "N", { "GETGROUP",;
										{ "CGROUP"				, "CCODE" },;
										{ "CGROUPDESCRIPTION"	, "CDESCRIPTION" } },;
									{ "CCODE", "CDESCRIPTION" } } )
	aAdd( aWebCols, { "GROUPDESCRIPTION", "D" } )
	aAdd( aWebCols, { "DEPARTMENT", "N", { "GETDEPARTMENT",;
											{ "CDEPARTMENT"				, "CCODE" },;
											{ "CDEPARTMENTDESCRIPTION"	, "CDESCRIPTION" } },;
										{ "CCODE", "CDESCRIPTION" } } )
	aAdd( aWebCols, { "DEPARTMENTDESCRIPTION", "D" } )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Funcao de montagem da descricao dos campos da tela³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
GridLinesEx( { 	HttpSession->PWSV184INFO[1]		, HttpSession->PWSV181HEADER[4][1]	,;
				HttpSession->PWSV184RESULT[1]	, aWebCols							,;
				.T.								, "H",, 1 } )

aWebCols := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada - Endereco do Contato³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "PEV184" )
	aWebCols := ExecBlock( "PEV184", .F., .F., { 2 } )
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

For nI := 1 To Len( HttpSession->PWSV184RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW )
	aAdd( HttpSession->PWSV184INFO[2], {} )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Funcao de montagem da descricao dos campos da tela³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	GridLinesEx( { 	HttpSession->PWSV184INFO[2][nI]									, HttpSession->PWSV181HEADER[5][1]	,;
					HttpSession->PWSV184RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW[nI]	, aWebCols							,;
					.T.																, "H", Str( nI, 1 ), 2 } )
Next nI

aWebCols := {}
     
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada - Telefone do Contato³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "PEV184" )
	aWebCols := ExecBlock( "PEV184", .F., .F., { 3 } )
Else
	aAdd( aWebCols, "COUNTRYAREACODE" )
	aAdd( aWebCols, "LOCALAREACODE" )
	aAdd( aWebCols, "PHONENUMBER" )
EndIf

aAdd( HttpSession->PWSV184INFO[3], {} )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Funcao de montagem da descricao dos campos da tela³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
GridLinesEx( { 	HttpSession->PWSV184INFO[3][1]							, HttpSession->PWSV181HEADER[6][1]	,;
				HttpSession->PWSV184RESULT[1]:oWSPHONES:oWSPHONEVIEW[1], aWebCols							,;
				.T.														, "H", "1", 2 } )

aWebCols := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada - Telefone do Contato³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "PEV184" )
	aWebCols := ExecBlock( "PEV184", .F., .F., { 4 } )
Else
	aAdd( aWebCols, "PHONENUMBER" )
EndIf

For nI := 2 To Len( HttpSession->PWSV184RESULT[1]:oWSPHONES:oWSPHONEVIEW )
	aAdd( HttpSession->PWSV184INFO[3], {} )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Funcao de montagem da descricao dos campos da tela³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	GridLinesEx( { 	HttpSession->PWSV184INFO[3][nI]								, HttpSession->PWSV181HEADER[6][1]	,;
					HttpSession->PWSV184RESULT[1]:oWSPHONES:oWSPHONEVIEW[nI]	, aWebCols							,;
					.T.															, "H", Str( nI, 1 ), IIf( nI <> Len( HttpSession->PWSV184RESULT[1]:oWSPHONES:oWSPHONEVIEW ), 2, 3 ) } )
Next nI

cHtml += ExecInPage( "PWSV184" )
	
WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSV185   ºAutor  ³Luiz Felipe Couto    º Data ³  21/03/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Inclusao ou alteracao do contato.                           º±±
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
Web Function PWSV185()

Local cHtml := ""						//Pagina WEB
Local nI	:= 0						//Variavel de apoio
Local oObjCRMSeller						//Objeto WS - WSCRMSELLERCUSTOMERCONTACT
Local oCFGVal							//Objeto WS - WSCFGVALIDATION
Local oObjClone							//Objeto WS - Clone

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa Objeto WS - WSCRMSELLERCUSTOMERCONTACT³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObjCRMSeller := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSCRMSELLERCUSTOMERCONTACT' ), WSCRMSELLERCUSTOMERCONTACT():New() )
WsChgUrl( @oObjCRMSeller, "CRMSELLERCUSTOMERCONTACT.APW" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa Objeto WS - WSCFGVALIDATION³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oCFGVal := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSCFGVALIDATION' ), WSCFGVALIDATION():New() )
WsChgUrl( @oCFGVal, "CFGVALIDATION.APW" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica CNPJ / CGC³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty( HttpSession->PWSV184RESULT[1]:cFEDERALID )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Parametros do metodo CHECKFEDERALID³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oCFGVal:cUSERCODE	:= GetUsrCode()
	oCFGVal:cCOUNTRY	:= "BRA"
	oCFGVal:cFEDERALID	:= HttpSession->PWSV184RESULT[1]:cFEDERALID
	
	//cUSERCODE,cCOUNTRY,cFEDERALID
	If !oCFGVal:CHECKFEDERALID()
		Return PWSHtmlAlert( "", STR0003		,;	//Atencao
							 "", "W_PWSV184.APW?cCUSTOMERID=" + HttpPost->cCUSTOMERID + "&cCONTACTID=" + HttpPost->cCONTACTID + "&cAcao=" + HttpPost->cAcao )
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Armazena Informacoes do Contato - CONTACTVIEW³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PWSSetObjToPost( HttpSession->PWSV184RESULT[1], HttpSession->PWSV181HEADER[4][1], HttpPost->aPost )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Armazena Informacoes do Endereco do Contato - ADDRESSVIEW³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 To Len( HttpSession->PWSV184RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW )
	PWSSetObjToPost( 	HttpSession->PWSV184RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW[nI]	,;
						HttpSession->PWSV181HEADER[5][1]								,;
						HttpPost->aPost, Str( nI, 1 ) )
Next nI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Armazena Informacoes do Telefone do Contato - PHONEVIEW³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 To Len( HttpSession->PWSV184RESULT[1]:oWSPHONES:oWSPHONEVIEW )
	PWSSetObjToPost( 	HttpSession->PWSV184RESULT[1]:oWSPHONES:oWSPHONEVIEW[nI]	,;
						HttpSession->PWSV181HEADER[6][1]							,;
						HttpPost->aPost, Str( nI, 1 ) )
Next nI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Clone do Objeto WS                                           |
//³Utilizado para a armazenagem da Session no Objeto de Gravacao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObjClone := HttpSession->PWSV184RESULT[1]:CLONE()

If HttpPost->cAcao == "A" .OR. HttpPost->cAcao == "I"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Parametros do metodo PUTCONTACT³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oObjCRMSeller:cUSERCODE		:= GetUsrCode()
	oObjCRMSeller:cSELLERCODE	:= HttpSession->CODVENERP
	oObjCRMSeller:cCUSTOMERID	:= HttpPost->cCUSTOMERID
	oObjCRMSeller:oWSCONTACT 	:= oObjClone
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Endereco do Contato³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oObjCRMSeller:oWSCONTACT:oWSADDRESSES := CRMSELLERCUSTOMERCONTACT_ARRAYOFADDRESSVIEW():New()
	
	For nI := 1 To Len( HttpSession->PWSV184RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW )
		aAdd( oObjCRMSeller:oWSCONTACT:oWSADDRESSES:oWSADDRESSVIEW, CRMSELLERCUSTOMERCONTACT_ADDRESSVIEW():New() )

		oObjCRMSeller:oWSCONTACT:oWSADDRESSES:oWSADDRESSVIEW[nI]:cADDRESS			:= HttpSession->PWSV184RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW[nI]:cADDRESS
		oObjCRMSeller:oWSCONTACT:oWSADDRESSES:oWSADDRESSVIEW[nI]:cADDRESSNUMBER		:= HttpSession->PWSV184RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW[nI]:cADDRESSNUMBER
		oObjCRMSeller:oWSCONTACT:oWSADDRESSES:oWSADDRESSVIEW[nI]:cDISTRICT			:= HttpSession->PWSV184RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW[nI]:cDISTRICT
		oObjCRMSeller:oWSCONTACT:oWSADDRESSES:oWSADDRESSVIEW[nI]:cSTATE				:= HttpSession->PWSV184RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW[nI]:cSTATE
		oObjCRMSeller:oWSCONTACT:oWSADDRESSES:oWSADDRESSVIEW[nI]:cTYPEOFADDRESS		:= HttpSession->PWSV184RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW[nI]:cTYPEOFADDRESS
		oObjCRMSeller:oWSCONTACT:oWSADDRESSES:oWSADDRESSVIEW[nI]:cZIPCODE			:= HttpSession->PWSV184RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW[nI]:cZIPCODE
		oObjCRMSeller:oWSCONTACT:oWSADDRESSES:oWSADDRESSVIEW[nI]:cZONE				:= HttpSession->PWSV184RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW[nI]:cZONE
	Next nI
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Telefone do Contato³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oObjCRMSeller:oWSCONTACT:oWSPHONES := CRMSELLERCUSTOMERCONTACT_ARRAYOFPHONEVIEW():New()
	
	For nI := 1 To Len( HttpSession->PWSV184RESULT[1]:oWSPHONES:oWSPHONEVIEW )
		aAdd( oObjCRMSeller:oWSCONTACT:oWSPHONES:oWSPHONEVIEW, CRMSELLERCUSTOMERCONTACT_PHONEVIEW():New() )

		oObjCRMSeller:oWSCONTACT:oWSPHONES:oWSPHONEVIEW[nI]:cCOUNTRYAREACODE 	:= HttpSession->PWSV184RESULT[1]:oWSPHONES:oWSPHONEVIEW[nI]:cCOUNTRYAREACODE
		oObjCRMSeller:oWSCONTACT:oWSPHONES:oWSPHONEVIEW[nI]:cLOCALAREACODE 		:= HttpSession->PWSV184RESULT[1]:oWSPHONES:oWSPHONEVIEW[nI]:cLOCALAREACODE
		oObjCRMSeller:oWSCONTACT:oWSPHONES:oWSPHONEVIEW[nI]:cPHONENUMBER 		:= HttpSession->PWSV184RESULT[1]:oWSPHONES:oWSPHONEVIEW[nI]:cPHONENUMBER
		oObjCRMSeller:oWSCONTACT:oWSPHONES:oWSPHONEVIEW[nI]:cTYPEOFPHONE		:= HttpSession->PWSV184RESULT[1]:oWSPHONES:oWSPHONEVIEW[nI]:cTYPEOFPHONE
	Next nI

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Grava Informacoes do Contato³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//cUSERCODE,cSELLERCODE,cCUSTOMERID,oWSCONTACT 
	If oObjCRMSeller:PUTCONTACT()
		HttpGet->cCONTACTID := oObjCRMSeller:cPUTCONTACTRESULT

		Return PWSHtmlAlert( "", STR0001,;		//Contato
								 STR0007,;  	//Informacoes cadastradas com sucesso!
							"W_PWSV181.APW" ) 
	Else
		Return PWSHtmlAlert( "", STR0003	,;  //Atencao
							 "", "W_PWSV184.APW?cCUSTOMERID=" + HttpPost->cCUSTOMERID + "&cCONTACTID=" + HttpPost->cCONTACTID + "&cAcao=" + HttpPost->cAcao )
	EndIf
EndIf

WEB EXTENDED END

Return cHtml
