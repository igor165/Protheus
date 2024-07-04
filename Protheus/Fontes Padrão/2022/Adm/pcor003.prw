#INCLUDE "PCOR003.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � PCOR003  �Autor  � Gustavo Henrique   � Data �  24/05/06   ���
�������������������������������������������������������������������������͹��
���Descricao � Relatorio de cadastro de operacoes utilizando rotinas de   ���
���          � relatorios personalizaveis - Release 4.                    ���
�������������������������������������������������������������������������͹��
���Uso       � PCO                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PCOR003()

Local cReport	:= "PCOR003"			// Nome do Programa
Local cAlias	:= "AKF"				// Alias da tabela
Local cTitulo	:= STR0001				// Titulo do relat�rio apresentado no cabe�alho ### "Relacao do Cadastro de Operacoes Orcamentarias"
Local cDesc		:= STR0002+" "+STR0003 	// Descri��o do relat�rio ### "Ira imprimir o cadastro de operacoes orcamentarias" ### "de acordo com a configuracao do usuario."
Local aOrd		:= { STR0006, STR0007 }	// Ordens do relatorio
Local lInd		:= .T.					// Retorna Indice SIX

MPReport(cReport,cAlias,cTitulo,cDesc,aOrd,lInd)

Return