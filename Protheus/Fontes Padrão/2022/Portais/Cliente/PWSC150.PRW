#INCLUDE "PWSC150.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSC15*   �Autor  �Luiz Felipe Couto    � Data �  19/04/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Este fonte possui as funcionalidades relacionado a ficha    ���
���          � de credito do cliente.                                      ���
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
���Programa  �PWSC150   �Autor  �Luiz Felipe Couto    � Data �  19/04/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Mostra os clientes disponiveis para o usuario logado.       ���
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
Web Function PWSC150()

Local cHtml := ""					//Pagina WEB

WEB EXTENDED INIT cHtml START "InSite"

cHtml += W_PWSC151()

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSC151   �Autor  �Luiz Felipe Couto    � Data �  19/04/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Tela para consulta por CGC.                                 ���
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
Web Function PWSC151()

Local cHtml := ""					//Pagina WEB
Local oObj							//Objeto WS - WSFINANCEREGFORM

WEB EXTENDED INIT cHtml START "InSite"

//���������������������������������������Ŀ
//�Informacoes a serem utilizadas pelo APH�
//�����������������������������������������
HttpSession->PWSC151APH := { 	STR0004,;					//"Ficha de Cr�dito"
								"W_PWSC152.APW" }

//������������������������������������Ŀ
//�Inicializa o Objeto WSFINANCEREGFORM�
//��������������������������������������
oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSFINANCEREGFORM' ), WSFINANCEREGFORM():New() )
WsChgURL( @oObj, "FINANCEREGFORM.APW" )

//��������������������������������������������������������Ŀ
//�Array contendo os headers dos WS utilizados nesta pagina�
//����������������������������������������������������������
If Empty( HttpSession->PWSC151HEADER )
	HttpSession->PWSC151HEADER := {}
	
	//������������������������������������������������������������Ŀ
	//�Header da estrutura REGFORMSTRUCT - Ficha de Credito        �
	//|- MATURITYOFCREDITLIMIT   : Vencimento Limite de Credito    |
	//|- SELLER                  : Vendedor                        |
	//|- NUMBEROFCHECKSRETURNED  : Numero de Cheques devolvidos    |
	//|- DATELASTCHECKSRETURNED  : Data do ultimo cheque devolvido |
	//|- BILLSPROTESTED          : Titulos protestados             |
	//|- DATEOFLASTPROTESTEDBILL : Data do ultimo titulo protestado|
	//|- CREDITLIMIT             : Limite de Credito               |
	//|- FIRSTPURCHASE           : Primeira Compra                 |
	//|- BILLBALANCE             : Saldo do Titulo                 |
	//|- LASTPURCHASE            : Ultima Compra                   |
	//|- SECONDARYCREDITLIMIT    : Limite de Credito Sec.          |
	//|- MAJORDELAY              : Maior Atraso                    |
	//|- SECCREDITLIMITBALANCE   : Saldo do Limite de Credito Sec. |
	//|- AVERAGEDELAY            : Media Atraso                    |
	//|- BIGGESTPURCHASE         : Maior Compra                    |
	//|- RISKRATE                : Taxa de Risco                   |
	//|- BIGGESTBALANCE          : Maior Saldo                     |
	//��������������������������������������������������������������
	If Empty( HttpSession->PWSC151HEADER )
		If oObj:GETHEADER()
			//���������������������������Ŀ
			//�Retorno do Metodo GETHEADER�
			//�����������������������������
			HttpSession->PWSC151HEADER := { oObj:oWSGETHEADERRESULT:oWSBRWHEADER }
		Else
			Return PWSHtmlAlert( "", STR0005, "", "W_PWSC150.APW" )  //"Aten��o"
		EndIf
	EndIf
EndIf

cHtml += ExecInPage( "PWSC151" )

WEB EXTENDED END

Return cHtml

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �PWSC152   �Autor  �Luiz Felipe Couto    � Data �  19/04/05   ���
��������������������������������������������������������������������������͹��
���Desc.     � Tela com a ficha de credito do cliente.                     ���
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
Web Function PWSC152()

Local cHtml 	:= ""					//Pagina WEB
Local aWebCols 	:= {}					//Campos que serao mostrados na tela
Local oObj								//Objeto WS - WSFINANCEREGFORM

WEB EXTENDED INIT cHtml START "InSite"

//���������������������������������������Ŀ
//�Informacoes a serem utilizadas pelo APH�
//�����������������������������������������
HttpSession->PWSC152APH := { 	STR0004 + STR0006 + IIF( Len( HttpPost->cFEDERALID ) == 11, Transform( HttpPost->cFEDERALID, "@R 999.999.999-99" ), Transform( HttpPost->cFEDERALID, "@R 999.999.999/9999-99" ) ),;				//"Ficha de Cr�dito" /" - CPF/CGC: "
								"W_PWSC151.APW" }

//�����������������������������������������Ŀ
//�Inicializa o objeto WS - WSFINANCEREGFORM�
//�������������������������������������������
oObj := IIf( FindFunction( 'GetAuthWs' ), GetAuthWs( 'WSFINANCEREGFORM' ), WSFINANCEREGFORM():New() )
WsChgURL( @oObj, "FINANCEREGFORM.APW" )

//�������������������������������Ŀ
//�Parametros do metodo GETREGFORM�
//���������������������������������
oObj:cUSERCODE	:= GetUsrCode()
oObj:cFEDERALID	:= HttpPost->cFEDERALID

//cUSERCODE,cFEDERALID
If oObj:GETREGFORM()
	//���������������������������Ŀ
	//�Array para montagem da tela�
	//�����������������������������
	HttpSession->PWSC152INFO := {}

	//����������������������������Ŀ
	//�Retorno do metodo GETREGFORM�
	//������������������������������
	HttpSession->PWSC152RESULT := { oObj:oWSGETREGFORMRESULT }

	//��������������������������������Ŀ
	//�Ponto de Entrada - REGFORMSTRUCT�
	//����������������������������������
	If ExistBlock( "PEC152" )
		aWebCols := ExecBlock( "PEC152", .F., .F., {} )
	EndIf

	//�������������������������������������Ŀ
	//�Funcao de montagem dos campos da tela�
	//���������������������������������������
	GridLinesEx( { HttpSession->PWSC152INFO			, HttpSession->PWSC151HEADER[1],;
					HttpSession->PWSC152RESULT[1]	, aWebCols						,;
					.F.								, "H",, 0 } )
Else
	Return PWSHTMLALERT( "", STR0005, "", "W_PWSC150.APW" )          //"Aten��o"
EndIf

cHtml += ExecInPage( "PWSC152" )

WEB EXTENDED END

Return cHtml