#include "tdsBirt.ch"
#include "protheus.ch"
#include "MATR552.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MATR552  � Autor �Mayra Camargo          � Data � 23/05/14 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Generaci�n de factura de venta en formato birt.	           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � matr552()                                                  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

Function MATR552()
//llamada a funcion para crear imagen IMG_FRANJA.BMP
CreaImage()

	// LLamado a Reporte	dependiendo del pa�s
	IF cPaisLoc == "MEX"
		DEFINE REPORT oRPT NAME MATR552M TITLE STR0025 EXCLUSIVE
	ElseIf cPaisLoc == "ARG"
		DEFINE REPORT oRPT NAME MATR552A TITLE STR0025 EXCLUSIVE
	EndIF

	ACTIVATE REPORT oRPT

Return
