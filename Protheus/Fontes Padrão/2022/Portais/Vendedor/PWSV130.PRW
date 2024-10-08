#INCLUDE "PWSV130.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSV13*   �Autor  �Luiz Felipe Couto    � Data �  18/03/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Este fonte possui as funcionalidades relacionado aos        ���
���          � prospects.                                                  ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSV130   �Autor  �Luiz Felipe Couto    � Data �  04/04/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Mostra os vendedores disponiveis para o usuario logado.     ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Web Function PWSV130()

Local cHtml := ""					//Pagina WEB
Local aVend	:= {}					//Array de vendedores cadastrados para o usuario logado

WEB EXTENDED INIT cHtml START "InSite"

//��������������������������������������������Ŀ
//�Vendedores cadastrados para o usuario logado�
//����������������������������������������������
aVend := GetUserVen()

//���������������������������������������Ŀ
//�Informacoes a serem utilizadas pelo APH�
//�����������������������������������������
HttpSession->PWSV020APH	:= { 	STR0001,; 						//"Prospects"
								"W_PWSV131.APW",;				//Pagina para onde sera enviado o POST
								"" }							//Mensagem a ser mostrada na tela
	
Do Case
	//�����������������������������������������������������
	//�Nao ha vendedores cadastrados para o usuario logado�
	//�����������������������������������������������������
	Case Empty( aVend )
		HttpSession->PWSV020APH[3] := STR0002 					//"N�o h� vendedores a consultar."
		
	//����������������������������Ŀ
	//�Apenas 1 vendedor cadastrado�
	//������������������������������
	Case Len( aVend ) == 2
		HttpSession->CODVENERP := aVend[2][2]

		Return W_PWSV131()

	//��������������������
	//�Mais de 1 vendedor�
	//��������������������
	Otherwise
		cHtml += ExecInPage( "PWSV020" )

EndCase

cHtml += ExecInPage( "PWSV020" )

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSV131   �Autor  �Luiz Felipe Couto    � Data �  18/03/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Tela de apresentacao da busca do prospect.                  ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Web Function PWSV131()

Local cHtml 	:= ""					//Pagina WEB
Local aWebCols 	:= {}					//Array de campos a serem mostrados na tela
Local oObjCRM							//Objeto WS - WSCRMPROSPECT
Local oObjIndex							//Objeto WS - WSCFGDICTIONARY

WEB EXTENDED INIT cHtml START "InSite"

//���������������������������������������Ŀ
//�Informacoes a serem utilizadas pelo APH�
//�����������������������������������������
HttpSession->PWSV131APH := { 	STR0001 + STR0002,; 		//Prospects - Busca 
								"W_PWSV132.APW",;			//Pagina para onde sera enviado o POST para Alteracao
								"W_PWSV133.APW" }			//Pagina para onde sera enviado o POST para Inclusao



//��������������������������������������Ŀ
//�Inicializa o objeto WS - WSCRMPROSPECT�
//����������������������������������������
oObjCRM := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSCRMPROSPECT' ), WSCRMPROSPECT():New() )
WsChgUrl( @oObjCRM, "CRMPROSPECT.apw" )

//����������������������������������������Ŀ
//�Inicializa o objeto WS - WSCFGDICTIONARY�
//������������������������������������������
oObjIndex := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSCFGDICTIONARY' ), WSCFGDICTIONARY():New() )
WsChgUrl( @oObjIndex, "CFGDICTIONARY.APW" )

//��������������������������������������������������������Ŀ
//�Array contendo os headers dos WS utilizados nesta pagina�
//����������������������������������������������������������
If Empty( HttpSession->PWSV131HEADER )
	HttpSession->PWSV131HEADER := { NIL, NIL, NIL, NIL }
	
	//�������������������������������������������Ŀ
	//�Header da estrutura PROSPECTVIEW - Prospect�
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
	//���������������������������������������������
	If Empty( HttpSession->PWSV131HEADER[1] )
		//������������������������������Ŀ
		//�Parametros do metodo GETHEADER�
		//��������������������������������
		oObjCRM:cHEADERTYPE := "PROSPECTVIEW"

		//cHEADERTYPE
		If oObjCRM:GETHEADER()
			//���������������������������Ŀ
			//�Retorno do Metodo GETHEADER�
			//�����������������������������
			HttpSession->PWSV131HEADER[1] := { oObjCRM:oWSGETHEADERRESULT:oWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0003,;		//Atencao
								 "", "W_PWSV130.APW" )
		EndIf
	EndIf
	
	//������������������������������������������Ŀ
	//�Header da estrutura ADDRESSVIEW - Endereco�
	//|- ADDRESS       : Endereco                |
	//|- ADDRESSNUMBER : Numero                  |
	//|- DISTRICT      : Cidade                  |
	//|- STATE         : Estado                  |
	//|- ZIPCODE       : CEP                     |
	//|- ZONE          : Bairro                  |
	//��������������������������������������������
	If Empty( HttpSession->PWSV131HEADER[2] )
		//������������������������������Ŀ
		//�Parametros do metodo GETHEADER�
		//��������������������������������
		oObjCRM:cHEADERTYPE := "ADDRESSVIEW"

		//cHEADERTYPE
		If oObjCRM:GETHEADER()
			//���������������������������Ŀ
			//�Retorno do Metodo GETHEADER�
			//�����������������������������
			HttpSession->PWSV131HEADER[2] := { oObjCRM:oWSGETHEADERRESULT:OWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0003,; 	//Atencao
								 "", "W_PWSV130.APW" )
		EndIf
	EndIf

	//����������������������������������������Ŀ
	//�Header da estrutura PHONEVIEW - Telefone�
	//|- COUNTRYAREACODE : DDI                 |
	//|- LOCALAREACODE   : DDD                 |
	//|- PHONENUMBER     : Numero              |
	//������������������������������������������
	If Empty( HttpSession->PWSV131HEADER[3] )
		//������������������������������Ŀ
		//�Parametros do metodo GETHEADER�
		//��������������������������������
		oObjCRM:cHEADERTYPE := "PHONEVIEW"

		//cHEADERTYPE
		If oObjCRM:GETHEADER()
			//���������������������������Ŀ
			//�Retorno do Metodo GETHEADER�
			//�����������������������������
			HttpSession->PWSV131HEADER[3] := { oObjCRM:oWSGETHEADERRESULT:OWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0003,;		//Atencao
								 "", "W_PWSV130.APW" )
		EndIf
	EndIf

	//���������������������������������������Ŀ
	//�Header da estrutura do WS CFGDICTIONARY�
	//|- CODE        : Ordem                  |
	//|- DESCRIPTION : Chave                  |
	//�����������������������������������������
	If Empty( HttpSession->PWSV131HEADER[4] )
		If oObjIndex:GETHEADER()
			//���������������������������Ŀ
			//�Retorno do Metodo GETHEADER�
			//�����������������������������
			HttpSession->PWSV131HEADER[4] := { oObjIndex:oWSGETHEADERRESULT:oWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0003,; 	//Atencao
								 "", "W_PWSV180.APW" )
		EndIf
	EndIf
EndIf

//���������������������Ŀ
//�Indices da Tabela SA1�
//�����������������������
If Empty( HttpSession->PWSV131INDEX )
	HttpSession->PWSV131INDEX := {}
	
	//�����������������������������Ŀ
	//�Parametros do metodo GETINDEX�
	//�������������������������������
	oObjIndex:cUSERCODE 	:= GetUsrCode()
	oObjIndex:cTABLE 		:= "SUS"
	
	//cUSERCODE,cTABLE
	If oObjIndex:GETINDEX()
		//����������������������������Ŀ
		//�Resultado do Metodo GETINDEX�
		//������������������������������
		HttpSession->PWSV131INDEX := { oObjIndex:oWSGETINDEXRESULT:oWSGENERICSTRUCT }
	Else
		Return PWSHtmlAlert( "", STR0003,;  //Atencao
							 "", "W_PWSV130.APW" )
	EndIf
EndIf

//������������������������������������Ŀ
//�Dados para montagem da Tela de Busca�
//��������������������������������������
If Empty( HttpSession->PWSV131BUSCA )
	HttpSession->PWSV131BUSCA := { {}, {} }
                          
	//���������������������������������������������Ŀ
	//�Ponto de Entrada - Campos do WS WSCRMPROSPECT�
	//�����������������������������������������������
	If ExistBlock( "PEV131" )
		aWebCols := ExecBlock( "PEV131", .F., .F., { 1 } )
	Else
		aAdd( aWebCols, "NAME" )
		aAdd( aWebCols, "NICKNAME" )
	EndIf
	
	//��������������������������������������������������Ŀ
	//�Funcao de montagem da descricao dos campos da tela�
	//����������������������������������������������������
	GridHeader( HttpSession->PWSV131BUSCA[1], HttpSession->PWSV131HEADER[1][1], aWebCols )
	
	//�������������������������������������Ŀ
	//�Funcao de montagem dos campos da tela�
	//���������������������������������������
	GridLinesEx( { 	HttpSession->PWSV131BUSCA[1]			, HttpSession->PWSV131HEADER[1][1]	,;
					CRMPROSPECT_PROSPECTVIEW():New()		, aWebCols							,;
					.T.										, "A",, 0 },"CRMPROSPECT")
	
	aWebCols := {}
                                 
	//�����������������������������������������������Ŀ
	//�Ponto de Entrada - Campos do WS WSCFGDICTIONARY�
	//�������������������������������������������������
	If ExistBlock( "PEV131" )
		aWebCols := ExecBlock( "PEV131", .F., .F., { 2 } )
	Else
		aAdd( aWebCols, "CODE" )
		aAdd( aWebCols, "DESCRIPTION" )
	EndIf
	
	//��������������������������������������������������Ŀ
	//�Funcao de montagem da descricao dos campos da tela�
	//����������������������������������������������������
   	GridHeader( HttpSession->PWSV131BUSCA[2], HttpSession->PWSV131HEADER[4][1], aWebCols )

	//�������������������������������������Ŀ
	//�Funcao de montagem dos campos da tela�
	//���������������������������������������
	GridLinesEx( { HttpSession->PWSV131BUSCA[2]		, HttpSession->PWSV131HEADER[4][1]	,;
					HttpSession->PWSV131INDEX[1]	, aWebCols							,;
					.F.								, "A",, 0 } )
EndIf

cHtml += ExecInPage( "PWSV131" )

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSV132   �Autor  �Luiz Felipe Couto    � Data �  04/04/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Tela com o retorno da busca do prospect.                    ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Web Function PWSV132()

Local cHtml 	:= ""					//Pagina WEB
Local aWebCols 	:= {}					//Array com os campos a serem mostrados na tela
Local oObj								//Objeto WS - WSCRMPROSPECT

Private cMsg := ""

WEB EXTENDED INIT cHtml START "InSite"

//�������������������������������������Ŀ
//�Informacoes a serem mostradas na tela�
//���������������������������������������
HttpSession->PWSV132APH := {	STR0001 + STR0004 ,;	//Prospects - Resultado da Busca 
								"W_PWSV133.APW"	,;
								"W_PWSV131.APW" }

//���������������������������Ŀ
//�Array para montagem da tela�
//�����������������������������
HttpSession->PWSV132INFO := {}


//��������������������������������������Ŀ
//�Inicializa o objeto WS - WSCRMPROSPECT�
//����������������������������������������
oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSCRMPROSPECT' ), WSCRMPROSPECT():New() )
WsChgUrl( @oObj, "CRMPROSPECT.APW" )

If !Empty( HttpPost->CNAME ) .OR. !Empty( HttpPost->CNICKNAME )
	//��������������������������������Ŀ
	//�Parametros do metodo BRWPROSPECT�
	//����������������������������������
	oObj:cUSERCODE		:= "MSALPHA"
	oObj:cSELLERCODE	:= HttpSession->CODVENERP
	oObj:cQUERYADDWHERE	:= ""
	oObj:cINDEXKEY		:= "US_COD"
	
	//cUSERCODE,cSELLERCODE,cQUERYADDWHERE,cINDEXKEY
	If oObj:BRWPROSPECT()
		//������������������������������
		//�Retorno do metodo BRWCONTACT�
		//������������������������������
		HttpSession->PWSV132RESULT := { oObj:oWSBRWPROSPECTRESULT:oWSPROSPECTVIEW }
	
		//���������������������������Ŀ
		//�Ponto de Entrada - Prospect�
		//�����������������������������
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
		
		//��������������������������������������������������Ŀ
		//�Funcao de montagem da descricao dos campos da tela�
		//����������������������������������������������������
		GridHeader( HttpSession->PWSV132INFO, HttpSession->PWSV131HEADER[1][1], aWebCols )
		
		//�������������������������������������Ŀ
		//�Funcao de montagem dos campos da tela�
		//���������������������������������������
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
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSV133   �Autor  �Luiz Felipe Couto    � Data �  04/04/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Tela com os dados do Prospect selecionado.                  ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
���Cleber M. �22/03/06� 90349�- Desabilitados os campos Codigo/Loja na in- ���
���          �        �  8.11�clusao do Prospect. A MsExecAuto determinara ���
���          �        �      �o proximo codigo automaticamente.            ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Web Function PWSV133()

Local cHtml 		:= ""						//Pagina WEB
Local nI 			:= 0						//Variavel de apoio
Local nPosEnd		:= 0						//Posicao do tipo do endereco dentro do array de Enderecos do Contato
Local nPosTel		:= 0						//Posicao do tipo do telefone dentro do array de Telefones do Contato
Local aWebCols 		:= {}						//Array contendo os campos que serao utilizados na tela
Local oObj										//Objeto WS - WSCRMPROSPECT


WEB EXTENDED INIT cHtml START "InSite"

//��������������������������������������������������Ŀ
//�Array com as informacoes a serem mostradas na tela�
//����������������������������������������������������
HttpSession->PWSV133APH := { 	""				,;			//Titulo da pagina
								"W_PWSV134.APW"	,;			//Pagina para onde sera enviado o POST
								"W_PWSV131.APW" }			//Pagina de Volta

//��������������������������������������������������Ŀ
//�Informacoes dos campos que seram mostrados na tela�
//����������������������������������������������������
HttpSession->PWSV133INFO := { {}, {}, {} }

//�����������������������������������Ŀ
//�Session de armazenagem do objeto WS�
//�������������������������������������
HttpSession->PWSV133RESULT := {}


//�������������������������������������������������Ŀ
//�Inicializa Objeto WS - WSCRMSELLERCUSTOMERCONTACT�
//���������������������������������������������������
oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSCRMPROSPECT' ), WSCRMPROSPECT():New() )
WsChgUrl( @oObj, "CRMPROSPECT.APW" )

//����������������������������������������������������������������Ŀ
//�Array com os tipos de informacoes que serao apresentados na tela�
//�Ex: Tipo de Telefone, Tipos de Endereco, etc.                   �
//������������������������������������������������������������������
If Empty( Httpsession->PWSV133TYPES )
	Httpsession->PWSV133TYPES := { NIL, NIL }
	
	//�������������������
	//�Tipos de Endereco�
	//�������������������
	If Empty( Httpsession->PWSV133TYPES[1] )
		If oObj:GETTYPEOFADDRESS()
			//����������������������������������Ŀ
			//�Retorno do metodo GETTYPEOFADDRESS�
			//������������������������������������
			Httpsession->PWSV133TYPES[1] := { oObj:oWSGETTYPEOFADDRESSRESULT:oWSGENERICSTRUCT }
		Else
			Return PWSHtmlAlert( "", STR0003,;	//Atencao
								 "", "W_PWSV132.APW" )
		EndIf
	EndIf
	
	//�������������������
	//�Tipos de Telefone�
	//�������������������
	If Empty( Httpsession->PWSV133TYPES[2] )
		If oObj:GETTYPEOFPHONE()
			//��������������������������������Ŀ
			//�Retorno do metodo GETTYPEOFPHONE�
			//����������������������������������
			Httpsession->PWSV133TYPES[2] := { oObj:oWSGETTYPEOFPHONERESULT:oWSGENERICSTRUCT }
		Else
			Return PWSHtmlAlert( "", STR0003,;  //Atencao
								 "", "W_PWSV132.APW" )
		EndIf
	EndIf
EndIf

//���������������������Ŀ
//�Alteracao de Prospect�
//�����������������������
If HttpGet->cAcao == "A"
	HttpSession->PWSV133APH[1] := 	STR0001+;	//Prospects
									STR0006+;  	//Alteracao - Dados Cadastrais
									HttpSession->PWSV132RESULT[1][Val( HttpGet->cProspect )]:cNAME 
	HttpSession->cProspect	:= HttpGet->cProspect 
	//��������������������������������Ŀ
	//�Parametros do metodo GETPROSPECT�
	//����������������������������������
	oObj:cUSERCODE		:= GetUsrCode() 
	oObj:cSELLERCODE	:= HttpSession->CODVENERP 
	oObj:cPROSPECTID	:= HttpSession->PWSV132RESULT[1][Val( HttpGet->cProspect )]:cPROSPECTCODE
	
	//cUSERCODE,cSELLERCODE,cPROSPECTID
	If oObj:GETPROSPECT()
		//�����������������������������Ŀ
		//�Retorno do metodo GETPROSPECT�
		//�������������������������������
		HttpSession->PWSV133RESULT := { oObj:oWSGETPROSPECTRESULT }
	Else
		Return PWSHtmlAlert( "", STR0003,;	//Atencao
							 "", "W_PWSV131.APW" )
	EndIf
Else
	//�������������������������������
	//� Inclusao de novo prospect   �
	//�������������������������������
	HttpSession->PWSV133APH[1] := STR0001 + STR0005		// Inclusao - Dados Cadastrais

	aAdd( HttpSession->PWSV133RESULT, CRMPROSPECT_PROSPECTVIEW():New() )

	HttpSession->PWSV133RESULT[1]:oWSADDRESSES 		:= CRMPROSPECT_ARRAYOFADDRESSVIEW():New()
	HttpSession->PWSV133RESULT[1]:oWSPHONES 		:= CRMPROSPECT_ARRAYOFPHONEVIEW():New()
	//�����������������������������������������������������Ŀ
	//� Inicializador Padrao: Loja do Prospect = 01   		�
	//�������������������������������������������������������
	HttpSession->PWSV133RESULT[1]:cUNITPROSPECTCODE	:= "01"	
EndIf
	
//��������������������Ŀ
//�Endereco do Prospect�
//����������������������
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

//��������������������Ŀ
//�Telefones :         �
//�Comercial   - Tipo 1�
//�FAX         - Tipo 2�
//����������������������
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

//����������������������������Ŀ
//�Enderecos ordenado pelo Tipo�
//������������������������������
HttpSession->PWSV133RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW := aSort( HttpSession->PWSV133RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW,,, { |x, y| x:cTYPEOFADDRESS < y:cTYPEOFADDRESS } )

//����������������������������Ŀ
//�Telefones ordenado pelo Tipo�
//������������������������������
HttpSession->PWSV133RESULT[1]:oWSPHONES:oWSPHONEVIEW := aSort( HttpSession->PWSV133RESULT[1]:oWSPHONES:oWSPHONEVIEW,,, { |x, y| x:cTYPEOFPHONE < y:cTYPEOFPHONE } )

//������������������������������������Ŀ
//�Ponto de Entrada - Dados do Prospect�
//��������������������������������������
If ExistBlock( "PEV133" )
	aWebCols := ExecBlock( "PEV133", .F., .F., { 1 } )
Else
	If HttpGet->cAcao == "A"
		//�����������������������Ŀ
		//� Alteracao do prospect �
		//�������������������������
		aAdd( aWebCols, { "PROSPECTCODE", "D" } )
		aAdd( aWebCols, { "UNITPROSPECTCODE", "D" } )
	Else
		//����������������������Ŀ
		//� Inclusao do Prospect �
		//������������������������
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

//��������������������������������������������������Ŀ
//�Funcao de montagem da descricao dos campos da tela�
//����������������������������������������������������
GridLinesEx( { 	HttpSession->PWSV133INFO[1]		, HttpSession->PWSV131HEADER[1][1]	,;
				HttpSession->PWSV133RESULT[1]	, aWebCols							,;
				.T.								, "H",, 1 }, "CRMPROSPECT", "SUS" )

aWebCols := {}

//���������������������������������������Ŀ
//�Ponto de Entrada - Endereco do Prospect�
//�����������������������������������������
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
	
	//��������������������������������������������������Ŀ
	//�Funcao de montagem da descricao dos campos da tela�
	//����������������������������������������������������
	GridLinesEx( { 	HttpSession->PWSV133INFO[2][nI]									, HttpSession->PWSV131HEADER[2][1]	,;
					HttpSession->PWSV133RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW[nI]	, aWebCols							,;
					.T.																, "H", Str( nI, 1 ), 2 } )
Next nI
     
aWebCols := {}

//���������������������������������������Ŀ
//�Ponto de Entrada - Telefone do Prospect�
//�����������������������������������������
If ExistBlock( "PEV133" )
	aWebCols := ExecBlock( "PEV133", .F., .F., { 3 } )
Else
	aAdd( aWebCols, "COUNTRYAREACODE" )
	aAdd( aWebCols, "LOCALAREACODE" )
	aAdd( aWebCols, "PHONENUMBER" )
EndIf

aAdd( HttpSession->PWSV133INFO[3], {} )

//��������������������������������������������������Ŀ
//�Funcao de montagem da descricao dos campos da tela�
//����������������������������������������������������
GridLinesEx( { 	HttpSession->PWSV133INFO[3][1]							, HttpSession->PWSV131HEADER[3][1]	,;
				HttpSession->PWSV133RESULT[1]:oWSPHONES:oWSPHONEVIEW[1], aWebCols							,;
				.T.														, "H", "1", 2 } )

aWebCols := {}

//���������������������������������������Ŀ
//�Ponto de Entrada - Telefone do Prospect�
//�����������������������������������������
If ExistBlock( "PEV133" )
	aWebCols := ExecBlock( "PEV133", .F., .F., { 4 } )
Else
	aAdd( aWebCols, "PHONENUMBER" )
EndIf

For nI := 2 To Len( HttpSession->PWSV133RESULT[1]:oWSPHONES:oWSPHONEVIEW )
	aAdd( HttpSession->PWSV133INFO[3], {} )
	
	//��������������������������������������������������Ŀ
	//�Funcao de montagem da descricao dos campos da tela�
	//����������������������������������������������������
	GridLinesEx( { 	HttpSession->PWSV133INFO[3][nI]								, HttpSession->PWSV131HEADER[3][1]	,;
					HttpSession->PWSV133RESULT[1]:oWSPHONES:oWSPHONEVIEW[nI]	, aWebCols							,;
					.T.															, "H", Str( nI, 1 ), IIf( nI <> Len( HttpSession->PWSV133RESULT[1]:oWSPHONES:oWSPHONEVIEW ), 2, 3 ) } )
Next nI

cHtml += ExecInPage( "PWSV133" )

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSV134   �Autor  �Luiz Felipe Couto    � Data �  21/03/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Inclusao ou alteracao do prospect.                          ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
���Cleber M. �27/03/06�95776 �- Corrigido o conteudo da variavel           ���
���			 �		  �		 �	HttpPost->cProspect						   ���
���Cleber M. �26/12/06�116041�- Tratamento do conteudo a ser enviado no    ���
���			 �		  �		 �	botao Voltar.							   ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Web Function PWSV134()

Local cHtml := ""						//Pagina WEB
Local nI	:= 0						//Variavel de apoio
Local oObjCRM							//Objeto WS - WSCRMPROSPECT
Local oCFGVal							//Objeto WS - WSCFGVALIDATION
Local oObjClone							//Objeto WS - Clone


WEB EXTENDED INIT cHtml START "InSite"


//�������������������������������������������������Ŀ
//�Inicializa Objeto WS - WSCRMSELLERCUSTOMERCONTACT�
//���������������������������������������������������
oObjCRM := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSCRMPROSPECT' ), WSCRMPROSPECT():New() )
WsChgUrl( @oObjCRM, "CRMPROSPECT.APW" )

//��������������������������������������Ŀ
//�Inicializa Objeto WS - WSCFGVALIDATION�
//����������������������������������������
oCFGVal := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSCFGVALIDATION' ), WSCFGVALIDATION():NEW() )
WsChgUrl( @oCFGVal, "CFGVALIDATION.APW" )

//For�ar a instancia de campo de usuario no HttpSession
aProp := PWVPutUsrFld( HttpSession->PWSV133RESULT[1], "SUS", "CRMPROSPECT" )
nPos 	:= aScan( aProp, { |x| x[1] == "OWSUSERFIELDS" } )
HttpSession->PWSV133RESULT[1]:oWSuserfields := aProp[nPos][2]

PWSSetObjToPost( HttpSession->PWSV133RESULT[1], HttpSession->PWSV131HEADER[1][1], HttpPost->aPost )
//�������������������Ŀ
//�Verifica CNPJ / CGC�
//���������������������
If !Empty( HttpSession->PWSV133RESULT[1]:cFEDERALID )
	//�����������������������������������Ŀ
	//�Parametros do metodo CHECKFEDERALID�
	//�������������������������������������
	oCFGVal:cUSERCODE	:= GetUsrCode()
	oCFGVal:cCOUNTRY	:= "BRA"
	oCFGVal:cFEDERALID	:= HttpSession->PWSV133RESULT[1]:cFEDERALID
	
	//cUSERCODE,cCOUNTRY,cFEDERALID
	If !oCFGVal:CHECKFEDERALID()
		//������������������������������������������������Ŀ
		//� Trata o conteudo a ser enviado no botao Voltar �
		//��������������������������������������������������
		If HttpPost->cAcao == "A"
			HttpPost->cProspect := HttpSession->cProspect
		Else
			HttpPost->cProspect := oObjCRM:oWSPROSPECT:cORIGINCODE
		EndIf
		Return PWSHtmlAlert( "", STR0003,;	//Atencao
							 "", "W_PWSV133.APW?cProspect=" + HttpPost->cProspect + "&cAcao=" + HttpPost->cAcao )
	EndIf
EndIf

//����������������������������������������������Ŀ
//�Armazena Informacoes do Contato - PROSPECTVIEW�
//������������������������������������������������
PWSSetObjToPost( HttpSession->PWSV133RESULT[1], HttpSession->PWSV131HEADER[1][1], HttpPost->aPost )

//����������������������������������������������������������Ŀ
//�Armazena Informacoes do Endereco do Prospect - ADDRESSVIEW�
//������������������������������������������������������������
For nI := 1 To Len( HttpSession->PWSV133RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW )
	PWSSetObjToPost( 	HttpSession->PWSV133RESULT[1]:oWSADDRESSES:oWSADDRESSVIEW[nI]	,;
						HttpSession->PWSV131HEADER[2][1]								,;
						HttpPost->aPost, Str( nI, 1 ) )
Next nI

//��������������������������������������������������������Ŀ
//�Armazena Informacoes do Telefone do Prospect - PHONEVIEW�
//����������������������������������������������������������
For nI := 1 To Len( HttpSession->PWSV133RESULT[1]:oWSPHONES:oWSPHONEVIEW )
	PWSSetObjToPost( 	HttpSession->PWSV133RESULT[1]:oWSPHONES:oWSPHONEVIEW[nI]	,;
						HttpSession->PWSV131HEADER[3][1]							,;
						HttpPost->aPost, Str( nI, 1 ) )
Next nI

//���������������������������������������������������������������
//�Clone do Objeto WS                                           |
//�Utilizado para a armazenagem da Session no Objeto de Gravacao�
//���������������������������������������������������������������
oObjClone := HttpSession->PWSV133RESULT[1]:CLONE()

If HttpPost->cAcao == "A" .OR. HttpPost->cAcao == "I"
	//��������������������������������Ŀ
	//�Parametros do metodo PUTPROSPECT�
	//����������������������������������
	oObjCRM:cUSERCODE		:= GetUsrCode()
	oObjCRM:cSELLERCODE		:= HttpSession->CODVENERP
	oObjCRM:oWSPROSPECT 	:= oObjClone
	
	//��������������������Ŀ
	//�Endereco do Prospect�
	//����������������������
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
	
	//��������������������Ŀ
	//�Telefone do Prospect�
	//����������������������
	oObjCRM:oWSPROSPECT:oWSPHONES := CRMPROSPECT_ARRAYOFPHONEVIEW():New()
	
	For nI := 1 To Len( HttpSession->PWSV133RESULT[1]:oWSPHONES:oWSPHONEVIEW )
		aAdd( oObjCRM:oWSPROSPECT:oWSPHONES:oWSPHONEVIEW, CRMPROSPECT_PHONEVIEW():New() )

		oObjCRM:oWSPROSPECT:oWSPHONES:oWSPHONEVIEW[nI]:cCOUNTRYAREACODE 	:= HttpSession->PWSV133RESULT[1]:oWSPHONES:oWSPHONEVIEW[nI]:cCOUNTRYAREACODE
		oObjCRM:oWSPROSPECT:oWSPHONES:oWSPHONEVIEW[nI]:cLOCALAREACODE 		:= HttpSession->PWSV133RESULT[1]:oWSPHONES:oWSPHONEVIEW[nI]:cLOCALAREACODE
		oObjCRM:oWSPROSPECT:oWSPHONES:oWSPHONEVIEW[nI]:cPHONENUMBER 		:= HttpSession->PWSV133RESULT[1]:oWSPHONES:oWSPHONEVIEW[nI]:cPHONENUMBER
		oObjCRM:oWSPROSPECT:oWSPHONES:oWSPHONEVIEW[nI]:cTYPEOFPHONE			:= HttpSession->PWSV133RESULT[1]:oWSPHONES:oWSPHONEVIEW[nI]:cTYPEOFPHONE
	Next nI

	//�����������������������������Ŀ
	//�Grava Informacoes do Prospect�
	//�������������������������������
	//cUSERCODE,cSELLERCODE,oWSPROSPECT
	If oObjCRM:PUTPROSPECT()
		HttpGet->cProspect := oObjCRM:cPUTPROSPECTRESULT

		Return PWSHtmlAlert( "",STR0003,;		//Atencao
							 	STR0008,;		//Informacoes cadastradas com SUCESSO!
							  	"W_PWSV130.APW" )
	Else
		//������������������������������������������������Ŀ
		//� Trata o conteudo a ser enviado no botao Voltar �
		//��������������������������������������������������
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
