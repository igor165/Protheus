#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOBJECT.CH"

#DEFINE TABELA "MDO"

Function LOJA1417()
Return NIL
/* 
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Classe� LJCEntProcInt    �Autor  �Vendas Clientes     �Data�  26/05/09   ���
���������������������������������������������������������������������������͹��
���Desc. � Classe utilizada para instanciar a tabela MDO atraves da Classe  ���
���      � LJAEntidade.                                                     ���
���������������������������������������������������������������������������͹��
���Uso   � SIGALOJA                                                         ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Class LJCEntProcInt From LJAEntidade
	Method New()
EndClass

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    � New      �Autor  �Vendas Clientes     � Data �  26/05/09   ���
�������������������������������������������������������������������������͹��
���Desc.     � Instancia o objeto com os dados da Tabela de processos da  ���
���          � integracao.                                                ���
�������������������������������������������������������������������������͹��
���Uso       � SIGALOJA                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Method New() Class LJCEntProcInt
	_Super:New(TABELA)
Return Self
