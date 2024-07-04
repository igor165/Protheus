#INCLUDE "PCOR002.CH"
#INCLUDE "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � PCOR002  � Autor � Paulo Carnelossi      � Data � 24/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Relatorio do cadastro do plano de classses orcamentarios    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PCOR002()                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function PCOR002()

Local cReport	:= "PCOR002"				// Nome do Programa
Local cAlias	:= "AK6"					// Alias da tabela
Local cTitulo	:= STR0001					// Titulo do relat�rio apresentado no cabe�alho
Local cDesc		:= STR0002+" "+STR0003 		// Descri��o do relat�rio
Local aOrd		:= { STR0006, STR0007 }    	// Ordens do relatorio
Local lInd		:= .T.						// Retorna Indice SIX

MPReport(cReport,cAlias,cTitulo,cDesc,aOrd,lInd)

Return
