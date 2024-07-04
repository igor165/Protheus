#include "protheus.ch"
#include "tdsBirt.ch"
#include "matr471.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MATR471  � Autor �Jesus Penaloza         � Data � 21/05/14 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Generacion de Nota de Credito en formato birt.  		    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MATR471()                                                  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MATR471()
	Local aAreaSM0:= SM0->(GetArea())
	//llamada a funcion para crear imagen IMG_FRANJA.BMP
	CreaImage()

		If cPaisLoc == 'MEX'
			DEFINE REPORT oRpt NAME MATR471 TITLE "Nota de abono" EXCLUSIVE
		Else
			DEFINE REPORT oRpt NAME MATR471A TITLE "Nota de credito" EXCLUSIVE
		EndIf

		ACTIVATE REPORT oRpt FORMAT PDF

	RestArea(aAreaSM0)
Return