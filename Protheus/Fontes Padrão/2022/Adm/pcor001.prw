#INCLUDE "PCOR001.CH"
#INCLUDE "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PCOR001   �Autor  �Gustavo Henrique    � Data �  24/05/06   ���
�������������������������������������������������������������������������͹��
���Descricao � Relatorio do cadastro do plano de contas orcamentarios     ���                                              
���          � Release 4                                                  ���
�������������������������������������������������������������������������͹��
���Uso       � PCOR001                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PCOR001()
                    
Local cReport	:= "PCOR001"				// Nome do Programa
Local cAlias	:= "AK5"					// Alias da tabela
Local cTitulo	:= STR0001					// Titulo do relat�rio apresentado no cabe�alho
Local cDesc		:= STR0002+" "+STR0003 		// Descri��o do relat�rio
Local aOrd		:= { STR0006, STR0007 }    	// Ordens do relatorio
Local lInd		:= .T.						// Retorna Indice SIX

MPReport(cReport,cAlias,cTitulo,cDesc,aOrd,lInd)

Return
