#INCLUDE "PROTHEUS.CH"
#INCLUDE "PWSV140.CH"
#INCLUDE "APWEBEX.CH"

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSV14*   �Autor  �Luiz Felipe Couto    � Data �  19/04/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Este fonte possui as funcionalidades relacionado aos        ���
���          � dados do vendedor.                                          ���
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
���Programa  �PWSV140   �Autor  �Luiz Felipe Couto    � Data �  19/04/05   ���
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
Web Function PWSV140()

Local cHtml := ""					//Pagina WEB

WEB EXTENDED INIT cHtml START "InSite"

//��������������������������������������������Ŀ
//�Vendedores cadastrados para o usuario logado�
//����������������������������������������������
HttpPost->PWSV020VEN := GetUserVen()

//���������������������������������������Ŀ
//�Informacoes a serem utilizadas pelo APH�
//�����������������������������������������
HttpSession->PWSV020APH	:= { 	STR0001		,;				//Dados Cadastrais
								"W_PWSV141.APW" ,;				//Pagina para onde sera enviado o POST
								"" }							//Mensagem a ser mostrada na tela
	
Do Case
	//�����������������������������������������������������
	//�Nao ha vendedores cadastrados para o usuario logado�
	//�����������������������������������������������������
	Case Empty( HttpPost->PWSV020VEN )
		HttpSession->PWSC020APH[3] := STR0002		//Nao ha vendedores a consultar
		
	//����������������������������Ŀ
	//�Apenas 1 vendedor cadastrado�
	//������������������������������
	Case Len( HttpPost->PWSV020VEN ) == 2
		HttpSession->CODVENERP := HttpPost->PWSV020VEN[2][2]

		Return W_PWSV141()

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
���Programa  �PWSV141   �Autor  �Luiz Felipe Couto    � Data �  19/04/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Tela de alteracao dos dados do vendedor                     ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
���Cleber M. �17/05/06�98641 �Passagem de parametro com o nome do WS na    ���
���          �        �      �funcao GridLineEx() para que seja possivel   ���
���          �        �      �iniciar o metodo que inclui os campos de     ���
���          �        �      �usuario no aheader.                      	   ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
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

//���������������������������������������Ŀ
//�Informacoes a serem utilizadas pelo APH�
//�����������������������������������������
HttpSession->PWSV141APH := { 	STR0001	,;							//Dados Cadastrais
								"W_PWSV142.APW" }						//Pagina para onde sera enviado o POST

//��������������������������������������������������Ŀ
//�Informacoes dos campos que seram mostrados na tela�
//����������������������������������������������������
HttpSession->PWSV141INFO := { {}, {}, {} }

//�����������������������������������Ŀ
//�Inicializa o objeto WS - WSMTSELLER�
//�������������������������������������
oObj := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTSELLER"), WSMTSELLER():New() )
WsChgUrl( @oObj, "MTSELLER.apw" )

//��������������������������������������������������������Ŀ
//�Array contendo os headers dos WS utilizados nesta pagina�
//����������������������������������������������������������
If Empty( HttpSession->PWSV141HEADER )
	HttpSession->PWSV141HEADER := { NIL, NIL, NIL, NIL, NIL, NIL }
	
	//��������������������������������������������Ŀ
	//�Header da estrutura SELLERVIEW - Vendedor   �
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
	//����������������������������������������������
	If Empty( HttpSession->PWSV141HEADER[1] )
		//������������������������������Ŀ
		//�Parametros do metodo GETHEADER�
		//��������������������������������
		oObj:cHEADERTYPE := "SELLERVIEW"

		//cHEADERTYPE
		If oObj:GETHEADER()
			//���������������������������Ŀ
			//�Retorno do Metodo GETHEADER�
			//�����������������������������
			HttpSession->PWSV141HEADER[1] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0006, "", "W_PWSV140.APW" )	//Atencao
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
	If Empty( HttpSession->PWSV141HEADER[2] )
		//������������������������������Ŀ
		//�Parametros do metodo GETHEADER�
		//��������������������������������
		oObj:cHEADERTYPE := "ADDRESSVIEW"

		//cHEADERTYPE
		If oObj:GETHEADER()
			//���������������������������Ŀ
			//�Retorno do Metodo GETHEADER�
			//�����������������������������
			HttpSession->PWSV141HEADER[2] := { oObj:oWSGETHEADERRESULT:OWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0006, "", "W_PWSV140.APW" )  //Atencao
		EndIf
	EndIf

	//����������������������������������������Ŀ
	//�Header da estrutura PHONEVIEW - Telefone�
	//|- COUNTRYAREACODE : DDI                 |
	//|- LOCALAREACODE   : DDD                 |
	//|- PHONENUMBER     : Numero              |
	//������������������������������������������
	If Empty( HttpSession->PWSV141HEADER[3] )
		//������������������������������Ŀ
		//�Parametros do metodo GETHEADER�
		//��������������������������������
		oObj:cHEADERTYPE := "PHONEVIEW"

		//cHEADERTYPE
		If oObj:GETHEADER()
			//���������������������������Ŀ
			//�Retorno do Metodo GETHEADER�
			//�����������������������������
			HttpSession->PWSV141HEADER[3] := { oObj:oWSGETHEADERRESULT:OWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0006, "", "W_PWSV140.APW" ) //Atencao
		EndIf
	EndIf
EndIf

//����������������������������������������������������������������Ŀ
//�Array com os tipos de informacoes que serao apresentados na tela�
//�Ex: Tipo de Telefone, Tipos de Endereco, etc.                   �
//������������������������������������������������������������������
If Empty( Httpsession->PWSV141TYPES )
	Httpsession->PWSV141TYPES := { NIL }
	
	//�������������������
	//�Tipos de Telefone�
	//�������������������
	If Empty( Httpsession->PWSV141TYPES[1] )
		If oObj:GETTYPEOFPHONE()
			//��������������������������������Ŀ
			//�Retorno do metodo GETTYPEOFPHONE�
			//����������������������������������
			Httpsession->PWSV141TYPES[1] := { oObj:oWSGETTYPEOFPHONERESULT:oWSGENERICSTRUCT }
		Else
			Return PWSHtmlAlert( "", STR0006, "", "W_PWSV140.APW" )   //Atencao
		EndIf
	EndIf
EndIf

//������������������������������Ŀ
//�Parametros do metodo GETSELLER�
//��������������������������������
oObj:cUSERCODE		:= "MSALPHA"
oObj:cSELLERCODE	:= HttpSession->CODVENERP

//cUSERCODE,cSELLERCODE
If oObj:GETSELLER()
	//���������������������������Ŀ
	//�Retorno do metodo GETSELLER�
	//�����������������������������
	HttpSession->PWSV141RESULT := { oObj:oWSGETSELLERRESULT }
Else
	Return PWSHtmlAlert( "", STR0006, "", "W_PWSV140.APW" )   //Atencao
EndIf

//��������������������Ŀ
//�Telefones :         �
//�Comercial   - Tipo 1�
//�FAX         - Tipo 2�
//�Celular     - Tipo 3�
//|Residencial - Tipo 4|
//����������������������
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

//����������������������������Ŀ
//�Telefones ordenado pelo Tipo�
//������������������������������
HttpSession->PWSV141RESULT[1]:oWSPHONES:oWSPHONEVIEW := aSort( HttpSession->PWSV141RESULT[1]:oWSPHONES:oWSPHONEVIEW,,, { |x, y| x:cTYPEOFPHONE < y:cTYPEOFPHONE } )

//�����������������������������������Ŀ
//�Ponto de Entrada - Dados do Contato�
//�������������������������������������
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

//��������������������������������������������������Ŀ
//�Funcao de montagem da descricao dos campos da tela�
//����������������������������������������������������
GridLinesEx( { 	HttpSession->PWSV141INFO[1]		, HttpSession->PWSV141HEADER[1][1]	,;
				HttpSession->PWSV141RESULT[1]	, aWebCols							,;
				.T.								, "H",, 1 }, cNomeWs )

aWebCols := {}

//��������������������������������������Ŀ
//�Ponto de Entrada - Endereco do Contato�
//����������������������������������������
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

//��������������������������������������������������Ŀ
//�Funcao de montagem da descricao dos campos da tela�
//����������������������������������������������������
GridLinesEx( { 	HttpSession->PWSV141INFO[2]					, HttpSession->PWSV141HEADER[2][1]	,;
				HttpSession->PWSV141RESULT[1]:oWSADDRESSES	, aWebCols							,;
				.T.											, "H",, 1 }, cNomeWs )

aWebCols := {}
     
//��������������������������������������Ŀ
//�Ponto de Entrada - Telefone do Contato�
//����������������������������������������
If ExistBlock( "PEV141" )
	aWebCols := ExecBlock( "PEV141", .F., .F., { 3 } )
Else
	aAdd( aWebCols, "PHONENUMBER" )
EndIf

aAdd( HttpSession->PWSV141INFO[3], {} )

//��������������������������������������������������Ŀ
//�Funcao de montagem da descricao dos campos da tela�
//����������������������������������������������������
GridLinesEx( { 	HttpSession->PWSV141INFO[3][1]							, HttpSession->PWSV141HEADER[3][1]	,;
				HttpSession->PWSV141RESULT[1]:oWSPHONES:oWSPHONEVIEW[1], aWebCols							,;
				.T.														, "H", "1", 2 }, cNomeWs )

aWebCols := {}

//��������������������������������������Ŀ
//�Ponto de Entrada - Telefone do Contato�
//����������������������������������������
If ExistBlock( "PEV141" )
	aWebCols := ExecBlock( "PEV141", .F., .F., { 4 } )
Else
	aAdd( aWebCols, "PHONENUMBER" )
EndIf

For nI := 2 To Len( HttpSession->PWSV141RESULT[1]:oWSPHONES:oWSPHONEVIEW )
	aAdd( HttpSession->PWSV141INFO[3], {} )
	
	//��������������������������������������������������Ŀ
	//�Funcao de montagem da descricao dos campos da tela�
	//����������������������������������������������������
	GridLinesEx( { 	HttpSession->PWSV141INFO[3][nI]								, HttpSession->PWSV141HEADER[3][1]	,;
					HttpSession->PWSV141RESULT[1]:oWSPHONES:oWSPHONEVIEW[nI]	, aWebCols							,;
					.T.															, "H", Str( nI, 1 ), IIf( nI <> Len( HttpSession->PWSV141RESULT[1]:oWSPHONES:oWSPHONEVIEW ), 2, 3 ) }, cNomeWs )
Next nI

cHtml += ExecInPage( "PWSV141" )

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSV145   �Autor  �Luiz Felipe Couto    � Data �  19/04/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Inclusao ou alteracao dos dados do vendedor.                ���
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
Web Function PWSV142()

Local cHtml := ""						//Pagina WEB
Local nI	:= 0						//Variavel de apoio
Local oObjSeller						//Objeto WS - WSMTSELLER
Local oCFGVal							//Objeto WS - WSCFGVALIDATION
Local oObjClone							//Objeto WS - Clone

WEB EXTENDED INIT cHtml START "InSite"

//�������������������������������������������������Ŀ
//�Inicializa Objeto WS - WSCRMSELLERCUSTOMERCONTACT�
//���������������������������������������������������
oObjSeller := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSMTSELLER"), WSMTSELLER():New() )
WsChgUrl( @oObjSeller, "MTSELLER.APW" )

//��������������������������������������Ŀ
//�Inicializa Objeto WS - WSCFGVALIDATION�
//����������������������������������������
oCFGVal := Iif(FindFunction("GetAuthWs"), GetAuthWs("WSCFGVALIDATION"), WSCFGVALIDATION():New() )
WsChgUrl( @oCFGVal, "CFGVALIDATION.APW" )

//�������������������Ŀ
//�Verifica CNPJ / CGC�
//���������������������
If !Empty( HttpSession->PWSV141RESULT[1]:cFEDERALID )
	//�����������������������������������Ŀ
	//�Parametros do metodo CHECKFEDERALID�
	//�������������������������������������
	oCFGVal:cUSERCODE	:= GetUsrCode()
	oCFGVal:cCOUNTRY	:= "BRA"
	oCFGVal:cFEDERALID	:= HttpSession->PWSV141RESULT[1]:cFEDERALID
	
	//cUSERCODE,cCOUNTRY,cFEDERALID
	If !oCFGVal:CHECKFEDERALID()
		Return PWSHtmlAlert( "", STR0006, "", "W_PWSV141.APW" ) //Atencao
	EndIf
EndIf

//���������������������������������������������Ŀ
//�Armazena Informacoes do Contato - CONTACTVIEW�
//�����������������������������������������������
PWSSetObjToPost( HttpSession->PWSV141RESULT[1], HttpSession->PWSV141HEADER[1][1], HttpPost->aPost )

//���������������������������������������������������������Ŀ
//�Armazena Informacoes do Endereco do Contato - ADDRESSVIEW�
//�����������������������������������������������������������
PWSSetObjToPost( 	HttpSession->PWSV141RESULT[1]:oWSADDRESSES	,;
					HttpSession->PWSV141HEADER[2][1]			,;
					HttpPost->aPost )

//�������������������������������������������������������Ŀ
//�Armazena Informacoes do Telefone do Contato - PHONEVIEW�
//���������������������������������������������������������
For nI := 1 To Len( HttpSession->PWSV141RESULT[1]:oWSPHONES:oWSPHONEVIEW )
	PWSSetObjToPost( 	HttpSession->PWSV141RESULT[1]:oWSPHONES:oWSPHONEVIEW[nI]	,;
						HttpSession->PWSV141HEADER[3][1]							,;
						HttpPost->aPost, Str( nI, 1 ) )
Next nI

//���������������������������������������������������������������
//�Clone do Objeto WS                                           |
//�Utilizado para a armazenagem da Session no Objeto de Gravacao�
//���������������������������������������������������������������
oObjClone := HttpSession->PWSV141RESULT[1]:CLONE()

//�������������������������������Ŀ
//�Parametros do metodo PUTCONTACT�
//���������������������������������
oObjSeller:cUSERCODE	:= GetUsrCode()
oObjSeller:cSELLERCODE	:= HttpSession->CODVENERP
oObjSeller:oWSSELLER 	:= oObjClone

//�������������������Ŀ
//�Endereco do Contato�
//���������������������
oObjSeller:oWSSELLER:oWSADDRESSES := MTSELLER_ADDRESSVIEW():New()

oObjSeller:oWSSELLER:oWSADDRESSES:cADDRESS			:= HttpSession->PWSV141RESULT[1]:oWSADDRESSES:cADDRESS
oObjSeller:oWSSELLER:oWSADDRESSES:cADDRESSNUMBER	:= HttpSession->PWSV141RESULT[1]:oWSADDRESSES:cADDRESSNUMBER
oObjSeller:oWSSELLER:oWSADDRESSES:cDISTRICT			:= HttpSession->PWSV141RESULT[1]:oWSADDRESSES:cDISTRICT
oObjSeller:oWSSELLER:oWSADDRESSES:cSTATE			:= HttpSession->PWSV141RESULT[1]:oWSADDRESSES:cSTATE
oObjSeller:oWSSELLER:oWSADDRESSES:cTYPEOFADDRESS	:= HttpSession->PWSV141RESULT[1]:oWSADDRESSES:cTYPEOFADDRESS
oObjSeller:oWSSELLER:oWSADDRESSES:cZIPCODE			:= HttpSession->PWSV141RESULT[1]:oWSADDRESSES:cZIPCODE
oObjSeller:oWSSELLER:oWSADDRESSES:cZONE				:= HttpSession->PWSV141RESULT[1]:oWSADDRESSES:cZONE

//�������������������Ŀ
//�Telefone do Contato�
//���������������������
oObjSeller:oWSSELLER:oWSPHONES := MTSELLER_ARRAYOFPHONEVIEW():New()

For nI := 1 To Len( HttpSession->PWSV141RESULT[1]:oWSPHONES:oWSPHONEVIEW )
	aAdd( oObjSeller:oWSSELLER:oWSPHONES:oWSPHONEVIEW, MTSELLER_PHONEVIEW():New() )

	oObjSeller:oWSSELLER:oWSPHONES:oWSPHONEVIEW[nI]:cCOUNTRYAREACODE 	:= HttpSession->PWSV141RESULT[1]:oWSPHONES:oWSPHONEVIEW[nI]:cCOUNTRYAREACODE
	oObjSeller:oWSSELLER:oWSPHONES:oWSPHONEVIEW[nI]:cLOCALAREACODE 		:= HttpSession->PWSV141RESULT[1]:oWSPHONES:oWSPHONEVIEW[nI]:cLOCALAREACODE
	oObjSeller:oWSSELLER:oWSPHONES:oWSPHONEVIEW[nI]:cPHONENUMBER 		:= HttpSession->PWSV141RESULT[1]:oWSPHONES:oWSPHONEVIEW[nI]:cPHONENUMBER
	oObjSeller:oWSSELLER:oWSPHONES:oWSPHONEVIEW[nI]:cTYPEOFPHONE		:= HttpSession->PWSV141RESULT[1]:oWSPHONES:oWSPHONEVIEW[nI]:cTYPEOFPHONE
Next nI

//����������������������������Ŀ
//�Grava Informacoes do Contato�
//������������������������������
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
