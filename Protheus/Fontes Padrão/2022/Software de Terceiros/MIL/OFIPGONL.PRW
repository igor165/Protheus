#include "Protheus.Ch"
#include "PanelOnLine.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � OFIPGONL � Autor � ANDRE                 � Data � 20/07/07 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � PAINEL DE GESTAO PARA O MODULO DE OFICINA                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function OFIPGONL(oPGOnline)

//������������������������������������������������������������������������Ŀ
//�Vendas Oficina                                                           �
//��������������������������������������������������������������������������
PANELONLINE oPGOnline ADDPANEL ;
	TITLE "Vendas Oficina" ;
	DESCR "Vendas Oficina" ;
	TYPE 1 ;
	ONLOAD "VEIP070" ;
	REFRESH 300 ;
	NAME "1"

//������������������������������������������������������������������������Ŀ
//�Vendas de Servicos                                                      �
//��������������������������������������������������������������������������
PANELONLINE oPGOnline ADDPANEL ;
	TITLE "Vendas de Servicos" ;
	DESCR "Vendas de Servicos" ;
	TYPE 1 ;
	ONLOAD "VEIP080" ;
	REFRESH 300 ;
	NAME "2"

//������������������������������������������������������������������������Ŀ
//�Vendas de Pecas Oficina                                                 �
//��������������������������������������������������������������������������
PANELONLINE oPGOnline ADDPANEL ;
	TITLE "Vendas de Pecas Oficina" ;
	DESCR "Vendas de Pecas Oficina" ;
	TYPE 1 ;
	ONLOAD "VEIP090" ;
	REFRESH 300 ;
	NAME "3"

Return