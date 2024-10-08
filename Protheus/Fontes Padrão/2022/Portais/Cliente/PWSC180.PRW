#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
#INCLUDE "PWSC180.CH"
/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSC18*   �Autor  �Luiz Felipe Couto    � Data �  22/03/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Este fonte possui as funcionalidades relacionado a ficha    ���
���          � cadastral do cliente.                                       ���
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
���Programa  �PWSC180   �Autor  �Luiz Felipe Couto    � Data �  22/03/05   ���
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
Web Function PWSC180()

Local cHtml 	:= ""					//Pagina WEB

WEB EXTENDED INIT cHtml START "InSite"

//������������������������������������������Ŀ
//�Clientes cadastrados para o usuario logado�
//��������������������������������������������
HttpPost->PWSC020CLI := GetUserCli()
HttpSession->PWSC020CLI := GetUserCli()

//���������������������������������������Ŀ
//�Informacoes a serem utilizadas pelo APH�
//�����������������������������������������
HttpSession->PWSC020APH	:= { 	STR0001	,;                      //"Ficha Cadastral"
								"W_PWSC181.APW"		,;			//Pagina para onde sera enviado o POST
								"" }							//Mensagem a ser mostrada na tela
	
Do Case
	//���������������������������������������������������
	//�Nao ha clientes cadastrados para o usuario logado�
	//���������������������������������������������������
	Case Empty( HttpPost->PWSC020CLI )
		HttpSession->PWSC020APH[3] := STR0002                   //"N�o h� clientes a consultar."
		
	//���������������������������Ŀ
	//�Apenas 1 cliente cadastrado�
	//�����������������������������
	Case Len( HttpPost->PWSC020CLI ) == 2
		HttpSession->CODCLIERP := HttpPost->PWSC020CLI[2][2]

		Return W_PWSC181()

	//�������������������
	//�Mais de 1 cliente�
	//�������������������
	//Otherwise
		//cHtml += ExecInPage( "PWSC020" )

EndCase

cHtml += ExecInPage( "PWSC020" )

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSC181   �Autor  �Luiz Felipe Couto    � Data �  22/03/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Tela de apresentacao da busca do cliente.                   ���
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
Web Function PWSC181()

Local cHtml 	:= ""					//Pagina WEB
Local nPos		:= 0					//Posicao do Cliente no array de Clientes
Local aWebCols 	:= {}					//Array de campos a serem mostrados na tela
Local oObj								//Objeto WS - WSFINANCECUSTOMERREGFORM

WEB EXTENDED INIT cHtml START "InSite"

If !Empty( HttpPost->CODCLIERP )
	HttpSession->CODCLIERP := HttpPost->CODCLIERP
Endif

nPos := aScan( HttpSession->PWSC020CLI, { |x| x[2] == HttpSession->CODCLIERP } )

If nPos > 0
	//�������������������������������������Ŀ
	//�Informacoes a serem mostradas na tela�
	//���������������������������������������
	HttpSession->PWSC181APH := { 	STR0003 + HttpSession->CODCLIERP + " - " + HttpSession->PWSC020CLI[nPos][4],;	//"Ficha Cadastral - Cliente : "
									"W_PWSC180.APW" }			//Pagina de volta do Resultado da Busca
	
	//���������������������������Ŀ
	//�Array para montagem da tela�
	//�����������������������������
	HttpSession->PWSC181INFO := {}
	
	//�������������������������������������������������Ŀ
	//�Inicializa o objeto WS - WSFINANCECUSTOMERREGFORM�
	//���������������������������������������������������

	oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSFINANCECUSTOMERREGFORM' ), WSFINANCECUSTOMERREGFORM():New() )
	WsChgUrl( @oObj, "FINANCECUSTOMERREGFORM.APW" )

	//��������������������������������������������������������Ŀ
	//�Array contendo os headers dos WS utilizados nesta pagina�
	//����������������������������������������������������������
	If Empty( HttpSession->PWSC181HEADER )
		HttpSession->PWSC181HEADER := { NIL }
		
		//���������������������������������Ŀ
		//�Header da estrutura REGFORMSTRUCT�
		//|- CODE        : Codigo do Cliente|
		//|- UNIT        : Loja do Cliente  |
		//|- DESCRIPTION : Nome do Cliente  |
		//�����������������������������������
		If Empty( HttpSession->PWSC181HEADER[1] )
			If oObj:GETHEADER()
				//���������������������������Ŀ
				//�Retorno do Metodo GETHEADER�
				//�����������������������������
				HttpSession->PWSC181HEADER[1] := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
			Else
				Return PWSHtmlAlert( "", STR0004, "", "W_PWSC180.APW" )        //"Aten��o"
			EndIf
		EndIf
	EndIf
	
	oObj:cUSERCODE		:= GetUsrCode()
	oObj:cCUSTOMERID	:= HttpSession->CODCLIERP
	
	//cUSERCODE,cCUSTOMERID
	If oObj:GETREGFORM()
		//����������������������������������Ŀ
		//�Ponto de Entrada - Ficha Cadastral�
		//������������������������������������
		If ExistBlock( "PEC181" )
			aWebCols := ExecBlock( "PEC181", .F., .F., {} )
		EndIf
	
		//�������������������������������������Ŀ
		//�Funcao de montagem dos campos da tela�
		//���������������������������������������
		GridLinesEX( { 	HttpSession->PWSC181INFO	, HttpSession->PWSC181HEADER[1][1]	,;
						oObj:oWSGETREGFORMRESULT	, aWebCols							,;
						.F., "H",, 0 } )
	Else
		Return PWSHtmlAlert( "", STR0004, "", "W_PWSC180.APW" )      //"Aten��o"
	EndIf
Else
	Return PWSHtmlAlert( "", STR0004, STR0005, "W_PWSC180.APW" )   //"Aten��o"   /"Cliente n�o encontrado."
EndIf

cHtml += ExecInPage( "PWSC181" )

WEB EXTENDED END

Return cHtml