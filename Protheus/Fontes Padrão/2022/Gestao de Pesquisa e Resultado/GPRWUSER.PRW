#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ValidaPesq�Autor  �WILKER VALLADARES   � Data �  24/11/03   ���
�������������������������������������������������������������������������͹��
���Desc.     �  Validacao exemplo para ser utilizada no SIGAGPR           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/


USER FUNCTION VALIDAPESQ()
Local aRet    := {}
Local cQuery  := ""

//�����������������������������������������������������������������������������Ŀ
//�A vari�vel HttpSession->cRespond � carregada no site, no momento da valida��o�
//�da chave definida em KC_TEXTO e KC_REGRA                                     �
//�������������������������������������������������������������������������������

if ! Empty( HttpSession->cRespond )
	
	cQuery := " SELECT COUNT(*) AS CONTA FROM "+RetSqlName("SKJ")
	cQuery += " WHERE KJ_FILIAL = "+ valtosql( xFilial("SKJ")  )
	cQuery += " AND KJ_RESPID = "+ valtosql( HttpSession->cRespond )
	cquery += " AND D_E_L_E_T_ <> '*' "
	
	OPEN QUERY cQuery ALIAS "VALPESQ"
	
	// posso fazer referencia tb a query montada no campo KC_CODLST ( valida��o de p�blico alvo )                          
	
	if VALPESQ->CONTA > 0
		AADD(aRet,{.F.,"Exemplo Resposta: Este usu�rio j� respondeu � pesquisa"}) // caso a primeira posi��o = .F., entao mostrar msg erro site
	else // caso contrario, eh .T. habilitar a pesquisa para o usuario.
		AADD(aRet,{.T.,""})
	endif
else
	AADD(aRet,{.F.,"N�o foi habilitado o campo chave na pesquisa"}) // caso a primeira posi��o = .F., entao mostrar msg erro site
endif      
CLOSE QUERY "VALPESQ"
Return aRet
              

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �G000INT   �Autor  �WILKER VALLADARES   � Data �  10/12/03   ���
�������������������������������������������������������������������������͹��
���Desc.     �  CUSTOMIZACAO DA MENSAGEM CASO A PESQUISA ESTEJE COM       ���
���          �  O STATUS INATIVO/WEB                                      ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
USER FUNCTION GP000INT()
Local cRet  := ""

// a tabela SKC est� posicionada !!   
if ! Empty(SKC->KC_DATINAT)
   cRet := "Esta pesquisa est� desativada desde "+ALLTRIM(SKC->KC_DATINAT)+"<br>" // <br> - pula linha no html
endif   
                                     
cRet += "Por favor, entre em contato com o Sr(a). "+ALLTRIM(SKC->KC_RESP)
Return cRet