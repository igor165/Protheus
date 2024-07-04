#include "rwmake.ch"    

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
��� Funcao   � CBA140EXC  � Autor � Anderson Rodrigues � Data �Wed  10/07/02���
���������������������������������������������������������������������������͹��
���Descri��o � Atualiza CB0 na Exclus�o da Pre-nota.  - Somente Protheus  	���
���������������������������������������������������������������������������͹��
���Uso       � SIGAACD                                                   	���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function CBA140EXC()

If !SuperGetMV("MV_CBPE002",.F.,.F.)
	Return .t.
EndIf

If Type("l140AUTO") =="L" .and. l140AUTO
	Return .t.
EndIf

CB0->(DbSetOrder(6)) 
While CB0->(DbSeek(xFilial("CB0")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))	
	CB0->(CbLog("05",{CB0_CODPRO,CB0_QTDE,CB0_LOTE,CB0_NFENT,CB0_SERIEE,CB0_FORNEC,CB0_LOJAFO,CB0_LOCAL,CB0_CODETI,"Estorno"}))	
	CB0->(Reclock("CB0",.F.))
	CB0->CB0_NFENT  := " "
	CB0->CB0_SERIEE := " "	
	CB0->CB0_LOTE   := " "		
	CB0->CB0_LOCAL  := " "	                	
	CB0->CB0_ITNFE  := " "	
	CB0->(MsUnlock())	
Enddo
Return .t.
