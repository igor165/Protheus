#INCLUDE "pmsupdat.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PMSUPDAT  �Autor  �Edson Maricate      � Data �  09/03/02   ���
�������������������������������������������������������������������������͹��
���Desc.     �Funcao de atualizacao dos arquivos do SIGAPMS da versao     ���
���          �6.09 para a versao 7.10                                     ���
�������������������������������������������������������������������������͹��
���Uso       � AP7                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PmsUpDat()
Local cText:= STR0001 //"Compatibilizando o arquivo"
Local aArea:= GetArea()

dbSelectArea("AE1")
dbGotop()
UpdSet01(LastRec())

While !Eof()
	UpdInc01(cText+" AE1",.T.)
	//������������������������������������������������������������Ŀ
	//� Grava os campos                                            �
	//��������������������������������������������������������������
	Reclock("AE1",.F.)
	Replace AE1_PRIORI With 500
	MsUnlock()
	dbSkip()
EndDo

dbSelectArea("AF2")
dbGotop()
UpdSet01(LastRec())

While !Eof()
	UpdInc01(cText+" AF2",.T.)
	//������������������������������������������������������������Ŀ
	//� Grava os campos                                            �
	//��������������������������������������������������������������
	Reclock("AF2",.F.)
	Replace AF2_PRIORI With 500
	MsUnlock()
	dbSkip()
EndDo

dbSelectArea("AF9")
dbGotop()
UpdSet01(LastRec())

While !Eof()
	UpdInc01(cText+" AF9",.T.)
	//������������������������������������������������������������Ŀ
	//� Grava os campos                                            �
	//��������������������������������������������������������������
	Reclock("AF9",.F.)
	Replace AF9_PRIORI With 500
	MsUnlock()
	dbSkip()
EndDo


RestArea(aArea)
Return