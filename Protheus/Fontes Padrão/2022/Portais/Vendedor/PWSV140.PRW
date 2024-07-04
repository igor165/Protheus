#INCLUDE "PROTHEUS.CH"
#INCLUDE "PWSV140.CH"
#INCLUDE "APWEBEX.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSV14*   ºAutor  ³Luiz Felipe Couto    º Data ³  19/04/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Este fonte possui as funcionalidades relacionado aos        º±±
±±º          ³ dados do vendedor.                                          º±±
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
±±ºPrograma  ³PWSV140   ºAutor  ³Luiz Felipe Couto    º Data ³  19/04/05   º±±
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
Web Function PWSV140()

Local cHtml := ""					//Pagina WEB

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Vendedores cadastrados para o usuario logado³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpPost->PWSV020VEN := GetUserVen()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Informacoes a serem utilizadas pelo APH³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpSession->PWSV020APH	:= { 	STR0001		,;				//Dados Cadastrais
								"W_PWSV141.APW" ,;				//Pagina para onde sera enviado o POST
								"" }							//Mensagem a ser mostrada na tela
	
Do Case
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Nao ha vendedores cadastrados para o usuario logado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case Empty( HttpPost->PWSV020VEN )
		HttpSession->PWSC020APH[3] := STR0002		//Nao ha vendedores a consultar
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Apenas 1 vendedor cadastrado³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Case Len( HttpPost->PWSV020VEN ) == 2
		HttpSession->CODVENERP := HttpPost->PWSV020VEN[2][2]

		Return W_PWSV141()

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
±±ºPrograma  ³PWSV141   ºAutor  ³Luiz Felipe Couto    º Data ³  19/04/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela de alteracao dos dados do vendedor                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Portal Protheus                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAnalista  ³ Data/Bops/Ver ³Manutencao Efetuada                      	   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºCleber M. ³17/05/06³98641 ³Passagem de parametro com o nome do WS na    º±±
±±º          ³        ³      ³funcao GridLineEx() para que seja possivel   º±±
±±º          ³        ³      ³iniciar o metodo que inclui os campos de     º±±
±±º          ³        ³      ³usuario no aheader.                      	   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Web Function PWSV141()

Local cHtml 		:= ""				//Pagina WEB
Local nI 			:= 0				//Variavel de apoio
Local nPosCli		:= 0				//Posicao do cliente no array de Clientes
Local nPosCon		:= 0				//Posicao do contato no array de Contatos
Local nPosEnd		:= 0				//Posicao do tipo do endereco dentro do array de Enderecos do Contato
Local nPosTel		:= 0				//Posicao do tipo do telefone dentro do array de Telefones do Contato
Local aWebCols 		:= {}				//Array de campos a serem mostrados na tela
Local cNomeWs		:= "MTSELLER"		//Nome do WebService utilizado
Local oObj								//Objeto WS - WSMTSELLER

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Informacoes a serem utilizadas pelo APH³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpSession->PWSV141APH := { 	STR0001	,;							//Dados Cadastrais
								"W_PWSV142.APW" }						//Pagina para onde sera enviado o POST

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Informacoes dos campos que seram mostrados na tela³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpSession->PWSV141INFO := { {}, {}, {} }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa o objeto WS - WSMTSELLER³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTSELLER"), WSMTSELLER():New() )
WsChgUrl( @oObj, "MTSELLER.apw" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Array contendo os headers dos WS utilizados nesta pagina³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty( HttpSession->PWSV141HEADER )
	HttpSession->PWSV141HEADER := { NIL, NIL, NIL, NIL, NIL, NIL }
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Header da estrutura SELLERVIEW - Vendedor   ³
	//|- SELLERCODE          : Codigo              |
	//|- NAME                : Nome                |
	//|- NICKNAME            : Nome Fantasia       |
	//|- FEDERALID           : CGC                 |
	//|- STATEID             : Inscr. Estadual     |
	//|- DISTRICTID          : Insrcr. Municipal   |
	//|- HOMEPAGE            : Homepage            |
	//|- EMAIL               : E-mail              |
	//|- SALESSUPERVISORCODE : Codigo do Supervisor|
	//|- SALESMANAGERCODE    : Codigo do Gerente   |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty( HttpSession->PWSV141HEADER[1] )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Parametros do metodo GETHEADER³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oObj:cHEADERTYPE := "SELLERVIEW"

		//cHEADERTYPE
		If oObj:GETHEADER()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Retorno do Metodo GETHEADER³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			HttpSession->PWSV141HEADER[1] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0006, "", "W_PWSV140.APW" )	//Atencao
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
	If Empty( HttpSession->PWSV141HEADER[2] )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Parametros do metodo GETHEADER³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oObj:cHEADERTYPE := "ADDRESSVIEW"

		//cHEADERTYPE
		If oObj:GETHEADER()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Retorno do Metodo GETHEADER³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			HttpSession->PWSV141HEADER[2] := { oObj:oWSGETHEADERRESULT:OWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0006, "", "W_PWSV140.APW" )  //Atencao
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Header da estrutura PHONEVIEW - Telefone³
	//|- COUNTRYAREACODE : DDI                 |
	//|- LOCALAREACODE   : DDD                 |
	//|- PHONENUMBER     : Numero              |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty( HttpSession->PWSV141HEADER[3] )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Parametros do metodo GETHEADER³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oObj:cHEADERTYPE := "PHONEVIEW"

		//cHEADERTYPE
		If oObj:GETHEADER()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Retorno do Metodo GETHEADER³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			HttpSession->PWSV141HEADER[3] := { oObj:oWSGETHEADERRESULT:OWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0006, "", "W_PWSV140.APW" ) //Atencao
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Array com os tipos de informacoes que serao apresentados na tela³
//³Ex: Tipo de Telefone, Tipos de Endereco, etc.                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty( Httpsession->PWSV141TYPES )
	Httpsession->PWSV141TYPES := { NIL }
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tipos de Telefone³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty( Httpsession->PWSV141TYPES[1] )
		If oObj:GETTYPEOFPHONE()
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Retorno do metodo GETTYPEOFPHONE³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			Httpsession->PWSV141TYPES[1] := { oObj:oWSGETTYPEOFPHONERESULT:oWSGENERICSTRUCT }
		Else
			Return PWSHtmlAlert( "", STR0006, "", "W_PWSV140.APW" )   //Atencao
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametros do metodo GETSELLER³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObj:cUSERCODE		:= "MSALPHA"
oObj:cSELLERCODE	:= HttpSession->CODVENERP

//cUSERCODE,cSELLERCODE
If oObj:GETSELLER()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Retorno do metodo GETSELLER³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	HttpSession->PWSV141RESULT := { oObj:oWSGETSELLERRESULT }
Else
	Return PWSHtmlAlert( "", STR0006, "", "W_PWSV140.APW" )   //Atencao
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Telefones :         ³
//³Comercial   - Tipo 1³
//³FAX         - Tipo 2³
//³Celular     - Tipo 3³
//|Residencial - Tipo 4|
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 To Len( Httpsession->PWSV141TYPES[1][1] )
	If Empty( HttpSession->PWSV141RESULT[1]:oWSPHONES:oWSPHONEVIEW )
		nPosTel := 0
	Else
		nPosTel := aScan( HttpSession->PWSV141RESULT[1]:oWSPHONES:oWSPHONEVIEW, { |x| x:cTYPEOFPHONE == Str( nI, 1 ) } )
	EndIf

	If nPosTel == 0
		aAdd( HttpSession->PWSV141RESULT[1]:oWSPHONES:oWSPHONEVIEW, MTSELLER_PHONEVIEW():New() )
		aTail( HttpSession->PWSV141RESULT[1]:oWSPHONES:oWSPHONEVIEW ):cTYPEOFPHONE := Str( nI, 1 )
	EndIf
Next nI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Telefones ordenado pelo Tipo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
HttpSession->PWSV141RESULT[1]:oWSPHONES:oWSPHONEVIEW := aSort( HttpSession->PWSV141RESULT[1]:oWSPHONES:oWSPHONEVIEW,,, { |x, y| x:cTYPEOFPHONE < y:cTYPEOFPHONE } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada - Dados do Contato³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "PEV141" )
	aWebCols := ExecBlock( "PEV141", .F., .F., { 1 } )
Else
	aAdd( aWebCols, { "SELLERCODE", "D" } )
	aAdd( aWebCols, "NAME" )
	aAdd( aWebCols, "NICKNAME" )
	aAdd( aWebCols, "FEDERALID" )
	aAdd( aWebCols, "STATEID" )
	aAdd( aWebCols, "DISTRICTID" )
	aAdd( aWebCols, "HOMEPAGE" )
	aAdd( aWebCols, "EMAIL" )
	aAdd( aWebCols, "SALESSUPERVISORCODE" )
	aAdd( aWebCols, "SALESMANAGERCODE" )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Funcao de montagem da descricao dos campos da tela³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
GridLinesEx( { 	HttpSession->PWSV141INFO[1]		, HttpSession->PWSV141HEADER[1][1]	,;
				HttpSession->PWSV141RESULT[1]	, aWebCols							,;
				.T.								, "H",, 1 }, cNomeWs )

aWebCols := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada - Endereco do Contato³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "PEV141" )
	aWebCols := ExecBlock( "PEV141", .F., .F., { 2 } )
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Funcao de montagem da descricao dos campos da tela³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
GridLinesEx( { 	HttpSession->PWSV141INFO[2]					, HttpSession->PWSV141HEADER[2][1]	,;
				HttpSession->PWSV141RESULT[1]:oWSADDRESSES	, aWebCols							,;
				.T.											, "H",, 1 }, cNomeWs )

aWebCols := {}
     
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada - Telefone do Contato³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "PEV141" )
	aWebCols := ExecBlock( "PEV141", .F., .F., { 3 } )
Else
	aAdd( aWebCols, "PHONENUMBER" )
EndIf

aAdd( HttpSession->PWSV141INFO[3], {} )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Funcao de montagem da descricao dos campos da tela³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
GridLinesEx( { 	HttpSession->PWSV141INFO[3][1]							, HttpSession->PWSV141HEADER[3][1]	,;
				HttpSession->PWSV141RESULT[1]:oWSPHONES:oWSPHONEVIEW[1], aWebCols							,;
				.T.														, "H", "1", 2 }, cNomeWs )

aWebCols := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de Entrada - Telefone do Contato³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "PEV141" )
	aWebCols := ExecBlock( "PEV141", .F., .F., { 4 } )
Else
	aAdd( aWebCols, "PHONENUMBER" )
EndIf

For nI := 2 To Len( HttpSession->PWSV141RESULT[1]:oWSPHONES:oWSPHONEVIEW )
	aAdd( HttpSession->PWSV141INFO[3], {} )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Funcao de montagem da descricao dos campos da tela³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	GridLinesEx( { 	HttpSession->PWSV141INFO[3][nI]								, HttpSession->PWSV141HEADER[3][1]	,;
					HttpSession->PWSV141RESULT[1]:oWSPHONES:oWSPHONEVIEW[nI]	, aWebCols							,;
					.T.															, "H", Str( nI, 1 ), IIf( nI <> Len( HttpSession->PWSV141RESULT[1]:oWSPHONES:oWSPHONEVIEW ), 2, 3 ) }, cNomeWs )
Next nI

cHtml += ExecInPage( "PWSV141" )

WEB EXTENDED END

Return cHtml

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PWSV145   ºAutor  ³Luiz Felipe Couto    º Data ³  19/04/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Inclusao ou alteracao dos dados do vendedor.                º±±
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
Web Function PWSV142()

Local cHtml := ""						//Pagina WEB
Local nI	:= 0						//Variavel de apoio
Local oObjSeller						//Objeto WS - WSMTSELLER
Local oCFGVal							//Objeto WS - WSCFGVALIDATION
Local oObjClone							//Objeto WS - Clone

WEB EXTENDED INIT cHtml START "InSite"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa Objeto WS - WSCRMSELLERCUSTOMERCONTACT³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObjSeller := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTSELLER"), WSMTSELLER():New() )
WsChgUrl( @oObjSeller, "MTSELLER.APW" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa Objeto WS - WSCFGVALIDATION³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oCFGVal := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGVALIDATION"), WSCFGVALIDATION():New() )
WsChgUrl( @oCFGVal, "CFGVALIDATION.APW" )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica CNPJ / CGC³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty( HttpSession->PWSV141RESULT[1]:cFEDERALID )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Parametros do metodo CHECKFEDERALID³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oCFGVal:cUSERCODE	:= GetUsrCode()
	oCFGVal:cCOUNTRY	:= "BRA"
	oCFGVal:cFEDERALID	:= HttpSession->PWSV141RESULT[1]:cFEDERALID
	
	//cUSERCODE,cCOUNTRY,cFEDERALID
	If !oCFGVal:CHECKFEDERALID()
		Return PWSHtmlAlert( "", STR0006, "", "W_PWSV141.APW" ) //Atencao
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Armazena Informacoes do Contato - CONTACTVIEW³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PWSSetObjToPost( HttpSession->PWSV141RESULT[1], HttpSession->PWSV141HEADER[1][1], HttpPost->aPost )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Armazena Informacoes do Endereco do Contato - ADDRESSVIEW³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PWSSetObjToPost( 	HttpSession->PWSV141RESULT[1]:oWSADDRESSES	,;
					HttpSession->PWSV141HEADER[2][1]			,;
					HttpPost->aPost )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Armazena Informacoes do Telefone do Contato - PHONEVIEW³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nI := 1 To Len( HttpSession->PWSV141RESULT[1]:oWSPHONES:oWSPHONEVIEW )
	PWSSetObjToPost( 	HttpSession->PWSV141RESULT[1]:oWSPHONES:oWSPHONEVIEW[nI]	,;
						HttpSession->PWSV141HEADER[3][1]							,;
						HttpPost->aPost, Str( nI, 1 ) )
Next nI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Clone do Objeto WS                                           |
//³Utilizado para a armazenagem da Session no Objeto de Gravacao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObjClone := HttpSession->PWSV141RESULT[1]:CLONE()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Parametros do metodo PUTCONTACT³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObjSeller:cUSERCODE	:= GetUsrCode()
oObjSeller:cSELLERCODE	:= HttpSession->CODVENERP
oObjSeller:oWSSELLER 	:= oObjClone

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Endereco do Contato³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObjSeller:oWSSELLER:oWSADDRESSES := MTSELLER_ADDRESSVIEW():New()

oObjSeller:oWSSELLER:oWSADDRESSES:cADDRESS			:= HttpSession->PWSV141RESULT[1]:oWSADDRESSES:cADDRESS
oObjSeller:oWSSELLER:oWSADDRESSES:cADDRESSNUMBER	:= HttpSession->PWSV141RESULT[1]:oWSADDRESSES:cADDRESSNUMBER
oObjSeller:oWSSELLER:oWSADDRESSES:cDISTRICT			:= HttpSession->PWSV141RESULT[1]:oWSADDRESSES:cDISTRICT
oObjSeller:oWSSELLER:oWSADDRESSES:cSTATE			:= HttpSession->PWSV141RESULT[1]:oWSADDRESSES:cSTATE
oObjSeller:oWSSELLER:oWSADDRESSES:cTYPEOFADDRESS	:= HttpSession->PWSV141RESULT[1]:oWSADDRESSES:cTYPEOFADDRESS
oObjSeller:oWSSELLER:oWSADDRESSES:cZIPCODE			:= HttpSession->PWSV141RESULT[1]:oWSADDRESSES:cZIPCODE
oObjSeller:oWSSELLER:oWSADDRESSES:cZONE				:= HttpSession->PWSV141RESULT[1]:oWSADDRESSES:cZONE

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Telefone do Contato³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oObjSeller:oWSSELLER:oWSPHONES := MTSELLER_ARRAYOFPHONEVIEW():New()

For nI := 1 To Len( HttpSession->PWSV141RESULT[1]:oWSPHONES:oWSPHONEVIEW )
	aAdd( oObjSeller:oWSSELLER:oWSPHONES:oWSPHONEVIEW, MTSELLER_PHONEVIEW():New() )

	oObjSeller:oWSSELLER:oWSPHONES:oWSPHONEVIEW[nI]:cCOUNTRYAREACODE 	:= HttpSession->PWSV141RESULT[1]:oWSPHONES:oWSPHONEVIEW[nI]:cCOUNTRYAREACODE
	oObjSeller:oWSSELLER:oWSPHONES:oWSPHONEVIEW[nI]:cLOCALAREACODE 		:= HttpSession->PWSV141RESULT[1]:oWSPHONES:oWSPHONEVIEW[nI]:cLOCALAREACODE
	oObjSeller:oWSSELLER:oWSPHONES:oWSPHONEVIEW[nI]:cPHONENUMBER 		:= HttpSession->PWSV141RESULT[1]:oWSPHONES:oWSPHONEVIEW[nI]:cPHONENUMBER
	oObjSeller:oWSSELLER:oWSPHONES:oWSPHONEVIEW[nI]:cTYPEOFPHONE		:= HttpSession->PWSV141RESULT[1]:oWSPHONES:oWSPHONEVIEW[nI]:cTYPEOFPHONE
Next nI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Grava Informacoes do Contato³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//cUSERCODE,cSELLERCODE,oWSSELLER
If oObjSeller:PUTSELLER()
	HttpGet->cSELLERCODE := oObjSeller:cPUTSELLERRESULT

	Return PWSHtmlAlert( "",	STR0001,; 	//Dados Cadastrais
								STR0004,;	//Informacoes cadastradas com SUCESSO!
								"W_PWSV141.APW" )
Else
	Return PWSHtmlAlert( "", "Atencao", "", "W_PWSV141.APW" )
EndIf

WEB EXTENDED END

Return cHtml
