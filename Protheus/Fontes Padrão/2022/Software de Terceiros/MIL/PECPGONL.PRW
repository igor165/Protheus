#include "Protheus.Ch"
#include "PanelOnLine.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PECPGONL � Autor � ANDRE                 � Data � 20/07/07 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � PAINEL DE GESTAO PARA O MODULO DE PECAS                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PECPGONL(oPGOnline)

//������������������������������������������������������������������������Ŀ
//�Venda de Pecas por condicao de Pagamento                                �
//��������������������������������������������������������������������������
PANELONLINE oPGOnline ADDPANEL ;
	TITLE "Venda de Pecas por condicao de Pagamento" ;
	DESCR "Venda de Pecas por condicao de Pagamento" ;
	TYPE 1 ;
	ONLOAD "VEIP010" ;
	REFRESH 300 ;
	NAME "1"


//������������������������������������������������������������������������Ŀ
//�Lucro de Pecas por condicao de Pagamento                                �
//��������������������������������������������������������������������������
PANELONLINE oPGOnline ADDPANEL ;
	TITLE "Lucro por condicao de Pagamento" ;
	DESCR "Lucro por condicao de Pagamento" ;
	TYPE 1 ;
	ONLOAD "VEIP020" ;
	REFRESH 300 ;
	NAME "2"


//������������������������������������������������������������������������Ŀ
//�Lucro de Pecas por condicao de Pagamento                                �
//��������������������������������������������������������������������������
PANELONLINE oPGOnline ADDPANEL ;
	TITLE "Vendas por vendedor" ;
	DESCR "Vendas por vendedor" ;
	TYPE 1 ;
	ONLOAD "VEIP050" ;
	REFRESH 300 ;
	NAME "3"

Return