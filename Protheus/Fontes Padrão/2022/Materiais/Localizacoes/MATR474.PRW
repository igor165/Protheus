#include "tdsBirt.ch"
#include "protheus.ch"
#Include "matr474.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MATR474  � Autor �Mayra Camargo          � Data � 23/05/14 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Generaci�n de Nota de Cargo en formato birt.  	           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � matr474()                                                  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MATR474()
//llamada a funcion para crear imagen IMG_FRANJA.BMP
CreaImage()

	IF cPaisLoc == "MEX"
		DEFINE REPORT oRPT NAME MATR474M TITLE STR0025 EXCLUSIVE //"Nota de Cargo"
	ElseIf cPaisLoc == "ARG"
		DEFINE REPORT oRPT NAME MATR474A TITLE STR0025 EXCLUSIVE //"Nota de Cargo"
	EndIF

	ACTIVATE REPORT oRPT
Return