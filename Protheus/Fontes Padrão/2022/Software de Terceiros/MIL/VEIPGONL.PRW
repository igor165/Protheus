#include "Protheus.Ch"
#include "PanelOnLine.ch" 
#Include "veipgonl.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � VEIPGONL � Autor � ANDRE                 � Data � 20/07/07 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � PAINEL DE GESTAO PARA O MODULO DE VEICULOS                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function VEIPGONL(oPGOnline)
     
//������������������������������������������������������������������������Ŀ
//�Venda de Veiculos por Modelo                                            �
//��������������������������������������������������������������������������
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0001 ;			//Venda de Veiculos por Modelo
	DESCR STR0001 ;			//Venda de Veiculos por Modelo
	TYPE 2 ;
	ONLOAD "VEIP030" ;
	REFRESH 300 ;
	DEFAULT 2;
	NAME "1"

//������������������������������������������������������������������������Ŀ
//�Qtdade de Veiculos por Modelo                                           �
//��������������������������������������������������������������������������
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0002 ;			//Qtdade de Veiculos por Modelo
	DESCR STR0002 ;			//Qtdade de Veiculos por Modelo
	TYPE 2 ;
	ONLOAD "VEIP040" ;
	REFRESH 300 ;
	DEFAULT 2;
	NAME "2"

//������������������������������������������������������������������������Ŀ
//�Qtdade de Veiculos por Vendedor                                         �
//��������������������������������������������������������������������������
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0003 ;			//Qtdade de Veiculos por Vendedor
	DESCR STR0003 ;			//Qtdade de Veiculos por Vendedor
	TYPE 1 ;
	ONLOAD "VEIP060" ;
	REFRESH 300 ;
	NAME "3"

Return        
