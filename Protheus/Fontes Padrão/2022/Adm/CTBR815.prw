#include "protheus.ch"
#include "tdsBirt.ch"
#include "ctbr815.ch"

/*/
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������Ŀ��
���Fun��o    �CTBR815     �Autor  �Jesus Pe�aloza          �Data  �10.12.14    ���
������������������������������������������������������������������������������Ĵ��
���Descri��o �Balance Patrimonial BIRT                                         ���
������������������������������������������������������������������������������Ĵ��
��|Uso       �Generico                                                         ���
������������������������������������������������������������������������������Ĵ��
��|           ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.                ���
������������������������������������������������������������������������������Ĵ��
���Programador   �Data    �BOPS/FNC �Motivo da Alteracao                       ���
������������������������������������������������������������������������������Ĵ��
���jonathan glez �08/09/15�TTHAMD   �Se cambia la forma de imprimir el archivo ���
���              �        �         �Termino Auxiliares para que no permita la ���
���              �        �         �impresion de archivos mayores a 2 mil     ���
���              �        �         �caracteres.                               ���
���              �        �         �                                          ���
�������������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
/*/
Function CTBR815()

	Help(" ",1,STR0021,,STR0020,1,0) //Mensagem de descontinua��o e bloqueio a partir de 01/10/2022.
				 
	If Date() >= CTOD("01/10/2022")
		Return
	Endif

	DEFINE REPORT oRpt NAME CTBR815 TITLE STR0001 EXCLUSIVE //"Balance Patrimonial"
	ACTIVATE REPORT oRpt

Return

