#INCLUDE "PWSP020.ch"
#INCLUDE "APWEBEX.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "SIGAWIN.CH"   

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PWSP001   �Autor  �Cristiano Denardi   � Data �  08/11/05   ���
�������������������������������������������������������������������������͹��
���Desc.     � Gerencia erros. 													     ���
�������������������������������������������������������������������������͹��
���Uso       � Portal PMS                                                 ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Web Function PWSP001()

Local cHtml := ""

HttpSession->cTitErro   := Alltrim( HttpGet->cTitErro		)
HttpSession->cErro      := Alltrim( HttpGet->cErro			)
HttpSession->cLinkErro  := Alltrim( HttpGet->cLinkErro	)
HttpSession->cBotaoErro := Alltrim( HttpGet->cBotaoErro	)

WEB EXTENDED INIT cHtml

cHtml += ExecInPage( "PWSP001" )

WEB EXTENDED END

Return cHtml
