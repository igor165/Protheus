#include "protheus.ch"
#include "tdsBirt.ch"
#include "CTBR816.ch"

/*/
��������������������������������������������������������������������������
��������������������������������������������������������������������������
����������������������������������������������������������������������Ŀ��
���Funci�n   � CTBR816  � Autor � alfredo.medrano  � Data �  03/12/2014���
����������������������������������������������������������������������Ĵ��
���Descri��o � Imprime el an�lisis vertical                            ���
����������������������������������������������������������������������Ĵ��
���Sintaxe   � CTBR816()                                               ���
����������������������������������������������������������������������Ĵ��
��� Uso      � Permitir que el usu�rio pueda imprimir el               ���
���          � an�lisis vertical en formato realizado en BIRT          ���
����������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.          ���
����������������������������������������������������������������������Ĵ��
���Programador   � Data   �BOPS/FNC�  Motivo da Alteracao              ���
����������������������������������������������������������������������Ĵ��
���jonathan glez �08/09/15�TTHAMD  �Se cambia la forma de imprimir el  ���
���              �        �        �archivo Termino Auxiliares para que���
���              �        �        �no permita imprimir archivo mayores���
���              �        �        �a 2 mil caracteres.                ���
���              �        �        �                                   ���
�����������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������
��������������������������������������������������������������������������
/*/
Function CTBR816()
	Local aArea := GetArea()

	Help(" ",1,STR0035,,STR0034,1,0)  //Mensagem de descontinua�?o e bloqueio a partir de 01/10/2022.
	
	If Date() >= CTOD("01/10/2022")
		Return
	Endif

	Private NomeProg := FunName()

		If ( !AMIIn(34) )	// Acesso somente pelo SIGACTB
			Return
		EndIf

		// Definici�n del reporte oRPT y se asocia al dise�o(MATR481.rptdesign)
	 	DEFINE REPORT oRPT NAME CTBR816 title STR0031 EXCLUSIVE // "Informe an�lisis vertical"
		ACTIVATE REPORT oRPT FORMAT PDF //Ejecuta la presentaci�n del Reporte (PDF)

	RestArea( aArea )

Return

