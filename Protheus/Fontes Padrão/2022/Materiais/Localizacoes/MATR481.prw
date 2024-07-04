#include "tdsBirt.ch"
#include "protheus.ch"
#include "MATR481.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funci�n   � MATR481  � Autor � alfredo.medrano     � Data �  09/05/2014���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime el pedido de compra en formato realizado en BIRT   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MATR481()                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Permitir que el usu�rio pueda imprimir el pedido de        ���
���          � compra en formato realizado en BIRT                        ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador   � Data   � BOPS/FNC  �  Motivo da Alteracao              ���
�������������������������������������������������������������������������Ĵ��
���              �        �           �            		                  ���
���              �        �           �            		                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MATR481()
//llamada a funcion para crear imagen IMG_FRANJA.BMP
CreaImage()

	// Definici�n del reporte oRPT y se asocia al dise�o(MATR481.rptdesign)
 	DEFINE REPORT oRPT NAME MATR481 title STR0024 EXCLUSIVE // "Pedido de Compra"

	ACTIVATE REPORT oRPT

Return

