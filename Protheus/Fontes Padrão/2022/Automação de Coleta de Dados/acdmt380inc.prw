#INCLUDE "RWMAKE.CH"
#INCLUDE "ACDMT380INC.CH"

/*/
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������ͻ��
��� Funcao   � CBMT380INC � Autor � Flavio Luiz Vicco     � Data � 10/03/2008 ���
�����������������������������������������������������������������������������͹��
���Descri��o � Faz validacao do Ajuste de Empenho - Mata380       			  ���
�����������������������������������������������������������������������������͹��
���Uso       � SIGAACD                                                        ���
�����������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
/*/     
Function CBMT380INC()
Local aArea    := GetArea()
Local aAreaSC2 := SC2->(GetArea())
Local lRet     := .T.
If	SuperGetMV("MV_CBPE024",.F.,.F.)
	If	__cInternet == "AUTOMATICO" .OR. IsTelnet()
		Return lRet
	EndIf
	dbSelectArea("SC2")
	SC2->(dbSetOrder(1))
	If	dbSeek(xFilial("SC2")+Left(M->D4_OP,11))
		If	!Empty(SC2->C2_ORDSEP)
			MsgBox(STR0001,STR0002,STR0003) //"O empenho desta OP nao pode ser alterado pois o mesmo encontra-se amarrado a Ordem de Separacao ","Atencao","Parar"
			lRet := .F.
		EndIf
	EndIf
EndIf
RestArea(aAreaSC2)
RestArea(aArea)
Return lRet
