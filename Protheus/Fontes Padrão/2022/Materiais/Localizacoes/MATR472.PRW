#include "protheus.ch"
#include "tdsBirt.ch"
#include "matr472.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MATR472  � Autor �Jesus Penaloza         � Data � 08/05/14 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Generacion de Remision de venta en formato birt.		    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MATR472()                                                  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Jonathan Glz�09/09/15�TTH559�Se complementa el informe con la impresion���
���            �        �      �de los valores de gastos, fletes, seguro y���
���            �        �      �descuentos de los remitos de entrada o de ���
���            �        �      �salida.                                   ���
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MATR472()
	Local aAreaSM0 := SM0->(GetArea())
	//llamada a funcion para crear imagen IMG_FRANJA.BMP
	CreaImage()

		DEFINE REPORT oRpt NAME MATR472 TITLE GetDescRem() EXCLUSIVE

		ACTIVATE REPORT oRpt

	RestArea(aAreaSM0)
Return