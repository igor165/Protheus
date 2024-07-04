#INCLUDE "Protheus.ch"  

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
��� Programa � CBSF1100E  � Autor � Anderson Rodrigues � Data �Wed  10/07/02���
���������������������������������������������������������������������������͹��
���Descri��o � Faz ajuste do CB0 apos a exclusao da Nota - Somente Protheus	���
���������������������������������������������������������������������������͹��
���Uso       � SIGAACD                                                  	���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function CBSF1100E()

If !SuperGetMV("MV_CBPE019",.F.,.F.)
	Return
EndIf

If Type("l103AUTO") =="L" .and. l103AUTO
	Return
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
Return 
