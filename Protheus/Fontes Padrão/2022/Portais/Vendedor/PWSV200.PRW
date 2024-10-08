#INCLUDE "PROTHEUS.CH"
#INCLUDE "PWSV200.CH"
#INCLUDE "APWEBEX.CH"

/*                                                          
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSV20*   �Autor  �Luiz Felipe Couto    � Data �  23/03/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Este fonte possui as funcionalidades relacionado aos        ���
���          � titulos baixados.                                           ���
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
���Programa  �PWSV200   �Autor  �Luiz Felipe Couto    � Data �  23/03/05   ���
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
Web Function PWSV200()

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
HttpSession->PWSV020APH	:= { 	STR0001			,; 			//Titulos Baixados
								"W_PWSV201.APW"		,;			//Pagina para onde sera enviado o POST
								"" }							//Mensagem a ser mostrada na tela
	
Do Case
	//�����������������������������������������������������
	//�Nao ha vendedores cadastrados para o usuario logado�
	//�����������������������������������������������������
	Case Empty( aVend )
		HttpSession->PWSV020APH[3] := STR0002					//Nao ha vendedores a consultar.
		
	//����������������������������Ŀ
	//�Apenas 1 vendedor cadastrado�
	//������������������������������
	Case Len( aVend ) == 2
		HttpSession->CODVENERP := aVend[2][2]

		Return W_PWSV201()

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
���Programa  �PWSV201   �Autor  �Luiz Felipe Couto    � Data �  23/03/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Tela de busca dos titulos baixados para o vendedor          ���
���          � selecionado.                                                ���
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
Web Function PWSV201()

Local cHtml 	:= ""					//Pagina WEB
Local aWebCols 	:= {}					//Array contendo os campos que serao mostrados na tela
Local oObjFin							//Objeto WS - WSFINANCESELLERBILL
Local oObjIndex							//Objeto WS - WSCFGDICTIONARY

WEB EXTENDED INIT cHtml START "InSite"

//���������������������������������������Ŀ
//�Informacoes a serem utilizadas pelo APH�
//�����������������������������������������
HttpSession->PWSV201APH := { STR0001		,; 	//Titulos baixados
							 "W_PWSV202.APW" }

//��������������������������������������������Ŀ
//�Inicializa o objeto WS - WSFINANCESELLERBILL�
//����������������������������������������������
oObjFin := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSFINANCESELLERBILL' ), WSFINANCESELLERBILL():New() )
WsChgUrl( @oObjFin, "FINANCESELLERBILL.APW" )

//����������������������������������������Ŀ
//�Inicializa o objeto WS - WSCFGDICTIONARY�
//������������������������������������������
oObjIndex := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSCFGDICTIONARY' ), WSCFGDICTIONARY():New() )
WsChgUrl( @oObjIndex, "CFGDICTIONARY.APW" )

//��������������������������������������������������������Ŀ
//�Array contendo os headers dos WS utilizados nesta pagina�
//����������������������������������������������������������
If Empty( HttpSession->PWSV201HEADER )
	HttpSession->PWSV201HEADER := { NIL, NIL, NIL }

	//���������������������������������������������Ŀ
	//�Header da estrutura BILLVIEW - Titulo        �
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
	//�����������������������������������������������
	If Empty( HttpSession->PWSV201HEADER[1] )
		//������������������������������Ŀ
		//�Parametros do metodo GETHEADER�
		//��������������������������������
		oObjFin:cHEADERTYPE := "BILLVIEW"
	
		//cHEADERTYPE
		If oObjFin:GETHEADER()
			//���������������������������Ŀ
			//�Retorno do Metodo GETHEADER�
			//�����������������������������
			HttpSession->PWSV201HEADER[1] := { oObjFin:oWSGETHEADERRESULT:oWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0003		,;		//Atencao
								 "", "W_PWSV200.APW" )
		EndIf
	EndIf

	//�������������������������������������������������������������Ŀ
	//�Header da estrutura PAIDBILLVIEW - Baixa                     �
	//|- REASONOFWRITEOFF  : Motivo                                 |
	//|- BANK              : Banco                                  |
	//|- BANKACCOUNT       : Conta                                  |
	//|- PAIDDATE          : Data do Pagamento                      |
	//|- CREDITDATE        : Data do Credito                        |
	//|- CURRENCY          : Moeda                                  |
	//|- CURRENCYSIMBOL    : Simbolo da Moeda                       |
	//|- VALUEPAID         : Valor Pago                             |
	//|- CURRENCYVALUEPAID : Valor Pago na Moeda Corrente           |
	//|- HISTORY           : Historico                              |
	//|- WRITEOFFTYPE      : 1-Principal;2-Descontos;3-Multa;4-Juros|
	//|- TYPEDESCRIPTION   : 1-Principal;2-Descontos;3-Multa;4-Juros|
	//���������������������������������������������������������������
	If Empty( HttpSession->PWSV201HEADER[2] )
		//������������������������������Ŀ
		//�Parametros do metodo GETHEADER�
		//��������������������������������
		oObjFin:cHEADERTYPE := "PAIDBILLVIEW"
	
		//cHEADERTYPE
		If oObjFin:GETHEADER()
			//���������������������������Ŀ
			//�Retorno do Metodo GETHEADER�
			//�����������������������������
			HttpSession->PWSV201HEADER[2] := { oObjFin:oWSGETHEADERRESULT:oWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0003		,;		//Atencao
								 "", "W_PWSV200.APW" )
		EndIf
	EndIf

	//���������������������������������������Ŀ
	//�Header da estrutura do WS CFGDICTIONARY�
	//|- CODE        : Ordem                  |
	//|- DESCRIPTION : Chave                  |
	//�����������������������������������������
	If Empty( HttpSession->PWSV201HEADER[3] )
		//������������������������������Ŀ
		//�Parametros do metodo GETHEADER�
		//��������������������������������
		If oObjIndex:GETHEADER()
			//���������������������������Ŀ
			//�Retorno do Metodo GETHEADER�
			//�����������������������������
			HttpSession->PWSV201HEADER[3] := { oObjIndex:oWSGETHEADERRESULT:oWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0003		,;		//Atencao 		
								 "", "W_PWSV200.APW" )
		EndIf
	EndIf
EndIf

//���������������������Ŀ
//�Indices da Tabela SE1�
//�����������������������
If Empty( HttpSession->PWSV201INDEX )
	HttpSession->PWSV201INDEX := {}
	
	//�����������������������������Ŀ
	//�Parametros do metodo GETINDEX�
	//�������������������������������
	oObjIndex:cUSERCODE 	:= GetUsrCode()
	oObjIndex:cTABLE 		:= "SE1"
	
	//cUSERCODE,cTABLE
	If oObjIndex:GETINDEX()
		//����������������������������Ŀ
		//�Resultado do Metodo GETINDEX�
		//������������������������������
		HttpSession->PWSV201INDEX := { oObjIndex:oWSGETINDEXRESULT:oWSGENERICSTRUCT }
	Else
		Return PWSHtmlAlert( "", STR0003		,;		//Atencao
							 "", "W_PWSV200.APW" )
	EndIf
EndIf

//�������������������������������������Ŀ
//�Dados para montagem do campo de Ordem�
//���������������������������������������
If Empty( HttpSession->PWSV201INFO )
	HttpSession->PWSV201INFO := {}

	//�����������������������������������������������Ŀ
	//�Ponto de Entrada - Campos do WS WSCFGDICTIONARY�
	//�������������������������������������������������
	If ExistBlock( "PEV201" )
		aWebCols := ExecBlock( "PEV201", .F., .F., {} )
	Else
		aAdd( aWebCols, "CODE" )
		aAdd( aWebCols, "DESCRIPTION" )
	EndIf
	
	//��������������������������������������������������Ŀ
	//�Funcao de montagem da descricao dos campos da tela�
	//����������������������������������������������������
   	GridHeader( HttpSession->PWSV201INFO, HttpSession->PWSV201HEADER[3][1], aWebCols )
	
	//�������������������������������������Ŀ
	//�Funcao de montagem dos campos da tela�
	//���������������������������������������
	GridLinesEx( { 	HttpSession->PWSV201INFO		, HttpSession->PWSV201HEADER[3][1]	,;
					HttpSession->PWSV201INDEX[1]	, aWebCols							,;
					.F., "A",, 0 } )
EndIf

cHtml += ExecInPage( "PWSV201" )

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSV202   �Autor  �Luiz Felipe Couto    � Data �  23/03/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Tela com os titulos em aberto para o vendedor selecionado.  ���
��������������������������������������������������������������������������͹��
���Parametros�                                                             ���
��������������������������������������������������������������������������͹��
���Uso       �Portal Protheus                                              ���
��������������������������������������������������������������������������͹��
���Analista  � Data/Bops/Ver �Manutencao Efetuada                      	   ���
��������������������������������������������������������������������������͹��
���Tatiana C.�118373 - Incluido o campo loja na busca de titulos baixados  ���
���Cleber M. �Bops 125482: Correcao da busca por cliente/loja e inclusao   ���
���          �de consulta F3 para cliente. 								   ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Web Function PWSV202()

Local cHtml 	:= ""					//Pagina WEB
Local aWebCols 	:= {}					//Array contendo os campos a serem mostrados na tela
Local oObj								//Objeto WS - WSFINANCESELLERBILL
Local nQtdeTitulos

WEB EXTENDED INIT cHtml START "InSite"

//�������������������������������������Ŀ
//�Informacoes a serem mostradas na tela�
//���������������������������������������                                                                               
HttpSession->PWSV202APH := { 	STR0004		, ;             //Titulos Baixados - Resultado da Busca TITULOS BAIXADOS
								"W_PWSV203.APW"	, ;			//Pagina para onde sera enviado o POST
								"W_PWSV201.APW" }			//Pagina de Volta

//���������������������������Ŀ
//�Array para montagem da tela�
//�����������������������������
HttpSession->PWSV202INFO := {}

//��������������������������������������������Ŀ
//�Inicializa o objeto WS - WSFINANCESELLERBILL�
//����������������������������������������������
oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSFINANCESELLERBILL' ), WSFINANCESELLERBILL():New() )
WsChgUrl( @oObj, "FINANCESELLERBILL.APW" )

If 	!Empty( HttpGet->dREGISTERDATEFROM ) .AND. !Empty( HttpGet->dREGISTERDATETO ) .AND.;
	!Empty( HttpGet->dREALDUEDATEFROM ) .AND. !Empty( HttpGet->dREALDUEDATETO ) .AND.;
	!Empty( HttpGet->dDATEFROM ) .AND. !Empty( HttpGet->dDATETO )
	
	HttpPost->dREGISTERDATEFROM 	:= HttpGet->dREGISTERDATEFROM
	HttpPost->dREGISTERDATETO 		:= HttpGet->dREGISTERDATETO
	HttpPost->dREALDUEDATEFROM 		:= HttpGet->dREALDUEDATEFROM
	HttpPost->dREALDUEDATETO 		:= HttpGet->dREALDUEDATETO
	HttpPost->dDATEFROM 			:= HttpGet->dDATEFROM
	HttpPost->dDATETO		 		:= HttpGet->dDATETO
Endif

If !Empty( HttpGet->cCUSTOMERFROM ) .OR. !Empty( HttpGet->cCUSTOMERTO )
	HttpPost->cCUSTOMERFROM 	:= HttpGet->cCUSTOMERFROM
	HttpPost->cCUSTOMERTO 		:= HttpGet->cCUSTOMERTO
Endif
If !Empty( HttpGet->cCUSTOMERUNITFROM ) .OR. !Empty( HttpGet->cCUSTOMERUNITTO )
	HttpPost->cCUSTOMERUNITFROM 	:= HttpGet->cCUSTOMERUNITFROM
	HttpPost->cCUSTOMERUNITTO 		:= HttpGet->cCUSTOMERUNITTO
Endif
//��������������������������������Ŀ
//�Parametros do metodo BRWPAIDBILL�
//����������������������������������
oObj:cUSERCODE			:= GetUsrCode()
oObj:cSELLERCODE		:= HttpSession->CODVENERP
oObj:dREGISTERDATEFROM	:= CToD( HttpPost->dREGISTERDATEFROM )
oObj:dREGISTERDATETO	:= CToD( HttpPost->dREGISTERDATETO )
oObj:dREALDUEDATEFROM	:= CToD( HttpPost->dREALDUEDATEFROM )
oObj:dREALDUEDATETO		:= CToD( HttpPost->dREALDUEDATETO )
oObj:dDATEFROM			:= CToD( HttpPost->dDATEFROM )
oObj:dDATETO			:= CToD( HttpPost->dDATETO )
oObj:nPAGELEN			:= 10 
If Empty( HttpGet->cPagina )
	HttpGet->cPagina := "0"
EndIf
oObj:nPAGEFIRST			:= ( Val( HttpGet->cPagina ) * 10 ) + 1

If ( !Empty( HttpPost->cCUSTOMERFROM ) .OR. !Empty( HttpPost->cCUSTOMERTO ) ) .AND.;
	( !Empty( HttpPost->cCUSTOMERUNITFROM ) .OR. !Empty( HttpPost->cCUSTOMERUNITTO ) )
	oObj:cQUERYADDWHERE		:= "A1_COD >= '" + HttpPost->cCUSTOMERFROM+"' AND A1_COD <= '" + HttpPost->cCUSTOMERTO + "' AND " + "A1_LOJA >= '" + HttpPost->cCUSTOMERUNITFROM+"' AND A1_LOJA <= '" + HttpPost->cCUSTOMERUNITTO + "'"
Endif                                                        

If(Empty(HttpSession->CINDEX))
	HttpSession->CINDEX := HttpPost->CINDEX
EndIf

oObj:cINDEXKEY			:= Iif(!Empty(HttpPost->CINDEX), HttpPost->CINDEX, HttpSession->CINDEX)  


//cUSERCODE,cSELLERCODE,dREGISTERDATEFROM,dREGISTERDATETO,dREALDUEDATETO,dREALDUEDATEFROM,dDATEFROM,dDATETO,cQUERYADDWHERE,cINDEXKEY
If oObj:BrwPaidBillQTDE()
	//���������������������������������Ŀ
	//�Retorno do metodo BrwPaidBillQTDE�
	//�����������������������������������
	nQtdeTitulos:= oObj:nBRWPAIDBILLQTDERESULT
	HttpSession->BrwPaidBillQTDE := nQtdeTitulos
Else
	Return PWSHTMLALERT( "", STR0003, "", "PWSV200.APW" )
EndIf

//cUSERCODE,cSELLERCODE,dREGISTERDATEFROM,dREGISTERDATETO,dREALDUEDATETO,dREALDUEDATEFROM,dDATEFROM,dDATETO,cQUERYADDWHERE,cINDEXKEY
If oObj:BRWPAIDBILL()
	//�����������������������������Ŀ
	//�Retorno do metodo BRWPAIDBILL�
	//�������������������������������
	HttpSession->PWSV202RESULT := { oObj:oWSBRWPAIDBILLRESULT:oWSBILLVIEW }
Else
	Return PWSHtmlAlert( "", STR0003		,; //Atencao
						 "", "W_PWSV200.APW" )
EndIf

//���������������������������Ŀ
//�Verifica Resultado da Busca�
//�����������������������������
If !Empty( HttpSession->PWSV202RESULT ) .AND. Len( HttpSession->PWSV202RESULT[1] ) > 0
	//�������������������������Ŀ
	//�Ponto de Entrada - Titulo�
	//���������������������������
	If ExistBlock( "PEV202" )
		aWebCols := ExecBlock( "PEV202", .F., .F., {} )
	Else
		aAdd( aWebCols, "PREFIX" )
		aAdd( aWebCols, "BILLNUMBER" )
		aAdd( aWebCols, "INSTALLMENT" )
		aAdd( aWebCols, "BILLTYPE" )
		aAdd( aWebCols, "CUSTOMERCODE" )		
		aAdd( aWebCols, "UNITCUSTOMERCODE" )		
		aAdd( aWebCols, "CUSTOMERNAME" )				
		aAdd( aWebCols, "CLASSCODE" )
		aAdd( aWebCols, "ISSUEDATE" )
		aAdd( aWebCols, "ORIGINALDUEDATE" )
		aAdd( aWebCols, "REALDUEDATE" )
		aAdd( aWebCols, "ORIGINALVALUE" )
	EndIf

	//��������������������������������������������������Ŀ
	//�Funcao de montagem da descricao dos campos da tela�
	//����������������������������������������������������
	GridHeader(	HttpSession->PWSV202INFO, HttpSession->PWSV201HEADER[1][1], aWebCols, ,"FINANCESELLERBILL", "SE1" )
             
	//�������������������������������������Ŀ
	//�Funcao de montagem dos campos da tela�
	//���������������������������������������
	GridLinesEx( { 	HttpSession->PWSV202INFO		, HttpSession->PWSV201HEADER[1][1]	,;
					HttpSession->PWSV202RESULT[1]	, aWebCols							,;
					.F., "A",, 0 },"FINANCESELLERBILL", "SE1" )
Else
	Return PWSHtmlAlert( "", STR0003	,;	//Atencao
							 STR0005	,;  //A busca n�o retornou nenhum titulo baixado cadastrado para este vendedor no periodo solicitado.
						 "W_PWSV201.APW" )
EndIf

cHtml += ExecInPage( "PWSV202" )

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSV203   �Autor  �Luiz Felipe Couto    � Data �  23/03/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Tela com o titulo selecionado.                              ���
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
Web Function PWSV203()

Local cHtml 	:= ""					//Pagina WEB
Local nPosTit 	:= 0					//Posicao do Titulo dentro do array de retorno do metodo BRWPAIDBILL
Local aWebCols 	:= {}					//Array contendo os campos que serao mostrados na tela
Local oObj								//Objeto WS - WSFINANCESELLERBILL

WEB EXTENDED INIT cHtml START "InSite"

nPosTit := Val( HttpGet->cTitulo )

//��������������������������������������������������Ŀ
//�Array com as informacoes a serem mostradas na tela�
//����������������������������������������������������
HttpSession->PWSV203APH := { 	STR0001  											+ ;			//Titulos baixados
								HttpSession->PWSV202RESULT[1][nPosTit]:cPREFIX 		+ ;
								HttpSession->PWSV202RESULT[1][nPosTit]:cBILLNUMBER 	+ ;
								HttpSession->PWSV202RESULT[1][nPosTit]:cINSTALLMENT	+ ;
								HttpSession->PWSV202RESULT[1][nPosTit]:cBILLTYPE	, ;
								STR0001											, ; 		//Titulos baixados
								"W_PWSV202.APW?dREGISTERDATEFROM=" + HttpGet->dREGISTERDATEFROM + "&dREGISTERDATETO=" + HttpGet->dREGISTERDATETO + "&dREALDUEDATEFROM=" + HttpGet->dREALDUEDATEFROM + "&dREALDUEDATETO=" + HttpGet->dREALDUEDATETO + "&dDATEFROM=" + HttpGet->dDATEFROM + "&dDATETO=" + HttpGet->dDATETO + "&cCUSTOMERFROM=" + HttpGet->cCUSTOMERFROM + "&cCUSTOMERTO=" + HttpGet->cCUSTOMERTO + "&cCUSTOMERUNITFROM=" + HttpGet->cCUSTOMERUNITFROM + "&cCUSTOMERUNITTO=" + HttpGet->cCUSTOMERUNITTO }		//Pagina de Volta

//��������������������������������������������������Ŀ
//�Informacoes dos campos que seram mostrados na tela�
//����������������������������������������������������
HttpSession->PWSV203INFO := { {}, {} }

//�������������������������������������������������Ŀ
//�Inicializa Objeto WS - WSCRMSELLERCUSTOMERCONTACT�
//���������������������������������������������������
oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSFINANCESELLERBILL' ), WSFINANCESELLERBILL():New() )
WsChgUrl( @oObj, "FINANCESELLERBILL.APW" )

oObj:cUSERCODE		:= GetUsrCode()
oObj:cCUSTOMERID	:= HttpSession->PWSV202RESULT[1][nPosTit]:cCUSTOMERCODE + HttpSession->PWSV202RESULT[1][nPosTit]:cUNITCUSTOMERCODE
oObj:cPREFIX		:= HttpSession->PWSV202RESULT[1][nPosTit]:cPREFIX
oObj:cBILLNUMBER	:= HttpSession->PWSV202RESULT[1][nPosTit]:cBILLNUMBER
oObj:cINSTALLMENT	:= HttpSession->PWSV202RESULT[1][nPosTit]:cINSTALLMENT
oObj:cBILLTYPE		:= HttpSession->PWSV202RESULT[1][nPosTit]:cBILLTYPE

//cUSERCODE,cCUSTOMERID,cPREFIX,cBILLNUMBER,cINSTALLMENT,cBILLTYPE
If oObj:GETPAIDBILL()
	HttpSession->PWSV203RESULT := { oObj:oWSGETPAIDBILLRESULT }

	//�������������������������Ŀ
	//�Ponto de Entrada - Titulo�
	//���������������������������
	If ExistBlock( "PEV203" )
	   	aWebCols := ExecBlock( "PEV203", .F., .F., { 1 } )		   	      	
	Else 	  
	  	aadd( aWebCols,   "PREFIX"  	  )
		aadd( aWebCols,   "BILLNUMBER"  	  )
		aadd( aWebCols,   "INSTALLMENT"  	  )
		aadd( aWebCols,   "BILLTYPE"  	  )
		aadd( aWebCols,   "CUSTOMERCODE"  	  )
		aadd( aWebCols,   "UNITCUSTOMERCODE"  	  )
		aadd( aWebCols,   "CUSTOMERNAME"  	  )
  		aadd( aWebCols,   "CLASSCODE"  	  )
		aadd( aWebCols,   "ISSUEDATE"  	  )
		aadd( aWebCols,   "ORIGINALDUEDATE"  	  )
		aadd( aWebCols,   "REALDUEDATE"  	  )
		aadd( aWebCols,   "CURRENCY"  	  )
		aadd( aWebCols,   "CURRENCYSIMBOL"  	  )
		aadd( aWebCols,   "ORIGINALVALUE"  	  )
		aadd( aWebCols,   "ORIGINALCURRENCYVALUE"  	  )		
		aadd( aWebCols,   "DEDUCTIONSVALUE"  	  )
		aadd( aWebCols,   "DEDUCTIONSVALUE"  	  )
		aadd( aWebCols,   "INCREASEVALUE"  	  )
		aadd( aWebCols,   "DECREASEVALUE"  	  )
		aadd( aWebCols,   "BALANCEVALUE"  	  )
	  	aadd( aWebCols,   "BALANCECURRENCYVALUE"  	  )
		aadd( aWebCols,   "BANK"  	  )
		aadd( aWebCols,   "HISTORY"  	  )
		aadd( aWebCols,   "DELAYINDAYS"  	  )
		aadd( aWebCols,   "DAYLYINTERESTRATE"  	  ) 
	   	aadd( aWebCols,   "DAYLYINTERESTRATEVALUE"  	  )
	  	aadd( aWebCols,   "FINANCIALDISCOUNT"  	  )
    	aadd( aWebCols,   "DAYSFORDISCOUNT"  	  )
        aadd( aWebCols,   "DAYLYINTERESTVALUE"  	) 
	EndIf
	   	
	//��������������������������������������������������Ŀ
	//�Funcao de montagem da descricao dos campos da tela�
	//����������������������������������������������������	
	GridLinesEx( { 	HttpSession->PWSV203INFO[1]				, HttpSession->PWSV201HEADER[1][1]	,;
					HttpSession->PWSV202RESULT[1][nPosTit]	, aWebCols							,;
					.F., "H",, 0 } )					
 		  
							
	aWebCols := {}
	//������������������������Ŀ
	//�Ponto de Entrada - Baixa�
	//��������������������������
	If ExistBlock( "PEV203" )
	   	aWebCols := ExecBlock( "PEV203", .F., .F., { 2 } )
	EndIf
	
	//��������������������������������������������������Ŀ
	//�Funcao de montagem da descricao dos campos da tela�
	//����������������������������������������������������
	GridHeader(	HttpSession->PWSV203INFO[2], HttpSession->PWSV201HEADER[2][1], aWebCols )
	
	//��������������������������������������������������Ŀ
	//�Funcao de montagem da descricao dos campos da tela�
	//����������������������������������������������������
	GridLinesEx( { 	HttpSession->PWSV203INFO[2]	, HttpSession->PWSV201HEADER[2][1]	,;
   					HttpSession->PWSV203RESULT[1]:oWSPAYMENT:oWSPAIDBILLVIEW	, aWebCols							,;
   					.F., "A",, 0 } )
Else
	Return PWSHtmlAlert( "", STR0003	,; //Atencao
					 "", "W_PWSV202.APW" )
EndIf

cHtml += ExecInPage( "PWSV203" )

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSV203A  �Autor  �Luiz Felipe Couto    � Data �  23/03/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Tela com as baixas do titulos selecionado.                  ���
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
Web Function PWSV203A()

Local cHtml 	:= ""

WEB EXTENDED INIT cHtml START "InSite"

cHtml += ExecInPage( "PWSV203A" )

WEB EXTENDED END

Return cHtml
