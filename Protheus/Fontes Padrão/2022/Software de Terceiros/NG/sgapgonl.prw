#include "Protheus.Ch"
#Include "PanelOnLine.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � SGAPGONL � Autor � Rafael Diogo Richter  � Data �05/03/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Definicao dos Paineis de Gestao On-Line do modulo de Gestao ���
���          �Ambiental.                                                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � SGAPGONL  										   	  			     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SigaSGA                                                    ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � F.O  �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function SGAPGONL(oPGOnline)

//������������������������������������������������������������������������Ŀ
//�Ocorrencias por Plano Emergencial                                       �
//��������������������������������������������������������������������������
PANELONLINE oPGOnline ADDPANEL ;
	TITLE "Ocorr�ncias por Plano Emergencial" ;
	DESCR "Ocorr�ncias por Plano Emergencial" ;
	TYPE 5 ;
	ONLOAD "SGAP010" ;
	REFRESH 300 ;
	NAME "1"

//������������������������������������������������������������������������Ŀ
//�Metas Alcancadas por Objetivos                                          �
//��������������������������������������������������������������������������
PANELONLINE oPGOnline ADDPANEL ;
	TITLE "Metas alcan�adas por Objetivos" ;
	DESCR "Metas alcan�adas por Objetivos" ;
	TYPE 5 ;
	ONLOAD "SGAP020" ;
	REFRESH 300 ;
	NAME "2"

//������������������������������������������������������������������������Ŀ
//�Percentual de Metas Alcancadas                                          �
//��������������������������������������������������������������������������
PANELONLINE oPGOnline ADDPANEL ;
	TITLE "Percentual de Metas Alcan�adas" ;
	DESCR "Percentual de Metas Alcan�adas" ;
	TYPE 3 ;
	ONLOAD "SGAP030" ;
	REFRESH 300 ;
	NAME "3"

//������������������������������������������������������������������������Ŀ
//�Situacao Demandas                                                       �
//��������������������������������������������������������������������������
PANELONLINE oPGOnline ADDPANEL ;
	TITLE "Situa��o Demandas" ;
	DESCR "Situa��o Demandas" ;
	TYPE 1 ;
	ONLOAD "SGAP040" ;
	REFRESH 300 ;
	NAME "4"
	
//������������������������������������������������������������������������Ŀ
//�Documentos a serem revisados                                            �
//��������������������������������������������������������������������������
PANELONLINE oPGOnline ADDPANEL ;
	TITLE "Qtde de Documentos � serem lidos" ;
	DESCR "Qtde de Documentos � serem lidos" ;
	TYPE 5 ;
	ONLOAD "SGAP050" ;
	REFRESH 300 ;
	NAME "5"

//������������������������������������������������������������������������Ŀ
//�Dias sem ocorrencias do P.E.                                            �
//��������������������������������������������������������������������������
PANELONLINE oPGOnline ADDPANEL ;
	TITLE "Dias sem ocorr�ncias do P.E." ;
	DESCR "Dias sem ocorr�ncias do P.E." ;
	TYPE 1 ;
	ONLOAD "SGAP060" ;
	REFRESH 300 ;
	NAME "6"

//������������������������������������������������������������������������Ŀ
//�Planos de Acao Pendentes                                                �
//��������������������������������������������������������������������������
PANELONLINE oPGOnline ADDPANEL ;
	TITLE "Planos de A��o Pendentes" ;
	DESCR "Planos de A��o Pendentes" ;
	TYPE 2 ;
	ONLOAD "SGAP070" ;
	REFRESH 300 ;
	DEFAULT 2;
	NAME "7"


Return