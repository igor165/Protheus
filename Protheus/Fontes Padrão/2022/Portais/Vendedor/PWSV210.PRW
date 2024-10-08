#INCLUDE "PROTHEUS.CH"
#INCLUDE "PWSV210.CH"
#INCLUDE "APWEBEX.CH"

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSV21*   �Autor  �Luiz Felipe Couto    � Data �  23/03/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Este fonte possui as funcionalidades relacionado as         ���
���          � notas de credito.                                           ���
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
���Programa  �PWSV210   �Autor  �Luiz Felipe Couto    � Data �  23/03/05   ���
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
Web Function PWSV210()

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
HttpSession->PWSV020APH	:= { 	STR0001			,;			//Notas de Credito
								"W_PWSV211.APW"		,;			//Pagina para onde sera enviado o POST
								"" }							//Mensagem a ser mostrada na tela
	
Do Case
	//�����������������������������������������������������
	//�Nao ha vendedores cadastrados para o usuario logado�
	//�����������������������������������������������������
	Case Empty( aVend )
		HttpSession->PWSV020APH[3] := STR0002					//Nao ha vendedores a consultar
		
	//����������������������������Ŀ
	//�Apenas 1 vendedor cadastrado�
	//������������������������������
	Case Len( aVend ) == 2
		HttpSession->CODVENERP := aVend[2][2]

		Return W_PWSV211()

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
���Programa  �PWSV211   �Autor  �Luiz Felipe Couto    � Data �  23/03/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Tela de busca das notas de credito para o vendedor          ���
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
Web Function PWSV211()

Local cHtml 	:= ""					//Pagina WEB
Local aWebCols 	:= {}					//Array contendo os campos que serao mostrados na tela
Local oObjFin							//Objeto WS - WSFINANCESELLERBILL
Local oObjIndex							//Objeto WS - WSCFGDICTIONARY

WEB EXTENDED INIT cHtml START "InSite"

//���������������������������������������Ŀ
//�Informacoes a serem utilizadas pelo APH�
//�����������������������������������������
HttpSession->PWSV211APH := {	STR0001		,; // Notas de credito
							 	"W_PWSV212.APW" }

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
If Empty( HttpSession->PWSV211HEADER )
	HttpSession->PWSV211HEADER := { NIL, NIL }

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
	If Empty( HttpSession->PWSV211HEADER[1] )
		//������������������������������Ŀ
		//�Parametros do metodo GETHEADER�
		//��������������������������������
		oObjFin:cHEADERTYPE := "BILLVIEW"
	
		//cHEADERTYPE
		If oObjFin:GETHEADER()
			//���������������������������Ŀ
			//�Retorno do Metodo GETHEADER�
			//�����������������������������
			HttpSession->PWSV211HEADER[1] := { oObjFin:oWSGETHEADERRESULT:oWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0003		,; 	//Erro
								 "", "W_PWSV210.APW" )
		EndIf
	EndIf

	//���������������������������������������Ŀ
	//�Header da estrutura do WS CFGDICTIONARY�
	//|- CODE        : Ordem                  |
	//|- DESCRIPTION : Chave                  |
	//�����������������������������������������
	If Empty( HttpSession->PWSV211HEADER[2] )
		//������������������������������Ŀ
		//�Parametros do metodo GETHEADER�
		//��������������������������������
		If oObjIndex:GETHEADER()
			//���������������������������Ŀ
			//�Retorno do Metodo GETHEADER�
			//�����������������������������
			HttpSession->PWSV211HEADER[2] := { oObjIndex:oWSGETHEADERRESULT:oWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0003		,;  //Erro
								 "", "W_PWSV210.APW" )
		EndIf
	EndIf
EndIf

//���������������������Ŀ
//�Indices da Tabela SE1�
//�����������������������
If Empty( HttpSession->PWSV211INDEX )
	HttpSession->PWSV211INDEX := {}
	
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
		HttpSession->PWSV211INDEX := { oObjIndex:oWSGETINDEXRESULT:oWSGENERICSTRUCT }
	Else
		Return PWSHtmlAlert( "", STR0003		,; //Erro
							 "", "W_PWSV210.APW" )
	EndIf
EndIf

//�������������������������������������Ŀ
//�Dados para montagem do campo de Ordem�
//���������������������������������������
If Empty( HttpSession->PWSV211INFO )
	HttpSession->PWSV211INFO := {}

	//�����������������������������������������������Ŀ
	//�Ponto de Entrada - Campos do WS WSCFGDICTIONARY�
	//�������������������������������������������������
	If ExistBlock( "PEV211" )
		aWebCols := ExecBlock( "PEV211", .F., .F., {} )
	Else
		aAdd( aWebCols, "CODE" )
		aAdd( aWebCols, "DESCRIPTION" )
	EndIf
	
	//��������������������������������������������������Ŀ
	//�Funcao de montagem da descricao dos campos da tela�
	//����������������������������������������������������
   	GridHeader( HttpSession->PWSV211INFO, HttpSession->PWSV211HEADER[2][1], aWebCols )
	
	//�������������������������������������Ŀ
	//�Funcao de montagem dos campos da tela�
	//���������������������������������������
	GridLinesEx( { 	HttpSession->PWSV211INFO		, HttpSession->PWSV211HEADER[2][1]	,;
					HttpSession->PWSV211INDEX[1]	, aWebCols							,;
					.F., "A",, 0 } )
EndIf

cHtml += ExecInPage( "PWSV211" )

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSV212   �Autor  �Luiz Felipe Couto    � Data �  23/03/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Tela com as notas de credito para o vendedor selecionado.   ���
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
Web Function PWSV212()

Local cHtml 	:= ""					//Pagina WEB
Local aWebCols 	:= {}					//Array contendo os campos a serem mostrados na tela
Local oObj								//Objeto WS - WSFINANCESELLERBILL

WEB EXTENDED INIT cHtml START "InSite"

//�������������������������������������Ŀ
//�Informacoes a serem mostradas na tela�
//���������������������������������������
HttpSession->PWSV212APH := { 	STR0004		, ;				//Notas de Credito - Resultado da Busca NOTAS DE CREDITO
								"W_PWSV213.APW"	, ;				//Pagina para onde sera enviado o POST
								"W_PWSV211.APW" }				//Pagina de Volta

//���������������������������Ŀ
//�Array para montagem da tela�
//�����������������������������
HttpSession->PWSV212INFO := {}

//��������������������������������������������Ŀ
//�Inicializa o objeto WS - WSFINANCESELLERBILL�
//����������������������������������������������
oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSFINANCESELLERBILL' ), WSFINANCESELLERBILL():New() )
WsChgUrl( @oObj, "FINANCESELLERBILL.APW" )

If 	!Empty( HttpGet->dREGISTERDATEFROM ) .AND. !Empty( HttpGet->dREGISTERDATETO ) .AND.;
	!Empty( HttpGet->dREALDUEDATEFROM ) .AND. !Empty( HttpGet->dREALDUEDATETO )
	
	HttpPost->dREGISTERDATEFROM 	:= HttpGet->dREGISTERDATEFROM
	HttpPost->dREGISTERDATETO 		:= HttpGet->dREGISTERDATETO
	HttpPost->dREALDUEDATEFROM 		:= HttpGet->dREALDUEDATEFROM
	HttpPost->dREALDUEDATETO 		:= HttpGet->dREALDUEDATETO
Endif

//��������������������������������Ŀ
//�Parametros do metodo BRWCUSTOMER�
//����������������������������������
oObj:cUSERCODE			:= GetUsrCode()
oObj:cSELLERCODE		:= HttpSession->CODVENERP
oObj:dREGISTERDATEFROM	:= CToD( HttpPost->dREGISTERDATEFROM )
oObj:dREGISTERDATETO	:= CToD( HttpPost->dREGISTERDATETO )
oObj:dREALDUEDATEFROM	:= CToD( HttpPost->dREALDUEDATEFROM )
oObj:dREALDUEDATETO		:= CToD( HttpPost->dREALDUEDATETO )
oObj:cQUERYADDWHERE		:= ""
oObj:cINDEXKEY			:= HttpPost->CINDEX

//cUSERCODE,cSELLERCODE,dREGISTERDATEFROM,dREGISTERDATETO,dREALDUEDATETO,dREALDUEDATEFROM,cQUERYADDWHERE,cINDEXKEY
If oObj:BRWCREDITNOTE()
	//�����������������������������Ŀ
	//�Retorno do metodo BRWCUSTOMER�
	//�������������������������������
	HttpSession->PWSV212RESULT := { oObj:oWSBRWCREDITNOTERESULT:oWSBILLVIEW }
Else
	Return PWSHtmlAlert( "", STR0003		,; 	//Erro
						 "", "W_PWSV210.APW" )
EndIf

//���������������������������Ŀ
//�Verifica Resultado da Busca�
//�����������������������������
If !Empty( HttpSession->PWSV212RESULT ) .AND. Len( HttpSession->PWSV212RESULT[1] ) > 0
	//�������������������������Ŀ
	//�Ponto de Entrada - Titulo�
	//���������������������������
	If ExistBlock( "PEV212" )
		aWebCols := ExecBlock( "PEV212", .F., .F., {} )
	Else
		aAdd( aWebCols, "PREFIX" )
		aAdd( aWebCols, "BILLNUMBER" )
		aAdd( aWebCols, "INSTALLMENT" )
		aAdd( aWebCols, "BILLTYPE" )
		aAdd( aWebCols, "CLASSCODE" )
		aAdd( aWebCols, "ISSUEDATE" )
		aAdd( aWebCols, "ORIGINALDUEDATE" )
		aAdd( aWebCols, "REALDUEDATE" )
		aAdd( aWebCols, "ORIGINALVALUE" )
	EndIf

	//��������������������������������������������������Ŀ
	//�Funcao de montagem da descricao dos campos da tela�
	//����������������������������������������������������
	GridHeader(	HttpSession->PWSV212INFO, HttpSession->PWSV211HEADER[1][1], aWebCols )
             
	//�������������������������������������Ŀ
	//�Funcao de montagem dos campos da tela�
	//���������������������������������������
	GridLinesEx( { 	HttpSession->PWSV212INFO		, HttpSession->PWSV211HEADER[1][1]	,;
					HttpSession->PWSV212RESULT[1]	, aWebCols							,;
					.F., "A",, 0 } )
Else
	Return PWSHtmlAlert( "",	STR0005,;		// Atencao
								STR0006,;     //A busca n�o retornou nenhuma nota de credito para este vendedor no periodo solicitado.
						 "W_PWSV211.APW" )
EndIf

cHtml += ExecInPage( "PWSV212" )

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSV213   �Autor  �Luiz Felipe Couto    � Data �  23/03/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Tela com a nota de credito selecionado.                     ���
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
Web Function PWSV213()

Local cHtml 	:= ""					//Pagina WEB
Local nPosTit 	:= 0					//Posicao do Titulo dentro do array de retorno do metodo BRWCREDITNOTE
Local aWebCols 	:= {}					//Array contendo os campos que serao mostrados na tela
Local oObj								//Objeto WS - WSFINANCESELLERBILL

WEB EXTENDED INIT cHtml START "InSite"

nPosTit := Val( HttpGet->cTitulo )

//��������������������������������������������������Ŀ
//�Array com as informacoes a serem mostradas na tela�
//����������������������������������������������������
HttpSession->PWSV213APH := { 	STR0007+ ;		//Notas de Credito - Titulo 
								HttpSession->PWSV212RESULT[1][nPosTit]:cPREFIX + ;
								HttpSession->PWSV212RESULT[1][nPosTit]:cBILLNUMBER + ;
								HttpSession->PWSV212RESULT[1][nPosTit]:cINSTALLMENT + ;
								HttpSession->PWSV212RESULT[1][nPosTit]:cBILLTYPE, ;
								"W_PWSV212.APW?dREGISTERDATEFROM=" + HttpGet->dREGISTERDATEFROM + "&dREGISTERDATETO=" + HttpGet->dREGISTERDATETO + "&dREALDUEDATEFROM=" + HttpGet->dREALDUEDATEFROM + "&dREALDUEDATETO=" + HttpGet->dREALDUEDATETO }			//Pagina de Volta
                                   
//��������������������������������������������������Ŀ
//�Informacoes dos campos que seram mostrados na tela�
//����������������������������������������������������
HttpSession->PWSV213INFO := {}

//�������������������������������������������������Ŀ
//�Inicializa Objeto WS - WSCRMSELLERCUSTOMERCONTACT�
//���������������������������������������������������
oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSFINANCESELLERBILL' ), WSFINANCESELLERBILL():New() )
WsChgUrl( @oObj, "FINANCESELLERBILL.APW" )

//�������������������������Ŀ
//�Ponto de Entrada - Titulo�
//���������������������������
If ExistBlock( "PEV213" )
	aWebCols := ExecBlock( "PEV213", .F., .F., {} )
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

GridLinesEx( { 	HttpSession->PWSV213INFO				, HttpSession->PWSV211HEADER[1][1]	,;
				HttpSession->PWSV212RESULT[1][nPosTit]	, aWebCols							,;
				.F., "H",, 0 }, "FINANCESELLERBILL", "SE1" )
				
cHtml += ExecInPage( "PWSV213" )

WEB EXTENDED END

Return cHtml