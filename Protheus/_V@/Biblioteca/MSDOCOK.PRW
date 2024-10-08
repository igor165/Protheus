#include "topconn.ch"
#include "protheus.ch" 
#include "rwmake.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MT241LOK Autor � Henrique Magalhaes   � Data � 23.11.2015� ��
�������������������������������������������������������������������������Ĵ��
��� Descri��o �  Validacao na inclusao de movimento interno               ���  
��� ** Utilizado para tratar obrigatoriedade de campos					  ���
�������������������������������������������������������������������������Ĵ��
���Uso       � validar campos de digitacao no item do movimento interno    ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

/*   
Descri��o:
MsDocOk - Trata informa��es complementares
Ponto de entrada para tratamento de informa��es complementares ao gravar um registro no banco de conhecimento.
O ponto de entrada receber� como par�metro (PARAMIXB) um vetor com a tabela de onde o banco de conhecimento � chamado e o ID do registro.
*/  

User Function MSDOCOK()
Local aArea		:= GetArea()
Local cDocTab	:= PARAMIXB[1]	// Tabela a qual foi gravado o documento 
Local nDocRecno	:= PARAMIXB[2]  // recno do registro

    // Tratamento para Gravar os mesmos anexos do pedido, no cadastro do fornecedor
	If Alltrim(cDocTab)$"SC7"
        
		DbselectArea("SC7")
		SC7->(DBGOTO(nDocRecno))
		u_GrvAC9C7(SC7->C7_FILIAL, SC7->C7_NUM,     "", SC7->C7_FORNECE, SC7->C7_LOJA)
//		u_GrvAC9C7(xC7Fil, xC7Num, xA2Fil, xA2Cod, xA2Loja)
	Endif
	
RestArea(aArea)
Return Nil      




