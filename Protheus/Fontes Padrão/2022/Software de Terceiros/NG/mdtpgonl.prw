#INCLUDE "MDTPGONL.ch"
#Include "PanelOnLine.ch"

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �MDTPGONL  � Autor � Ricardo Dal Ponte     � Data � 26/03/2007 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Painel de Gestao.                                             ���
���          �Chama Painel de Gestao na entrada do sistema (SIGAMDI).    	���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �MDTPGONL(oPGOnline)                                           ���
���������������������������������������������������������������������������Ĵ��
���Uso       �Generico                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function MDTPGONL(oPGOnline)
//������������������������������������������������������������������������Ŀ
//�Acidentes por Centro de Custo                                           �
//��������������������������������������������������������������������������
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0001; //"Acidentes por Centro de Custo"
	DESCR STR0001; //"Acidentes por Centro de Custo"
	TYPE 5 ; 
	PARAMETERS "MDTP010" ;
	ONLOAD "MDTP010" ;
	REFRESH 300 ;
	NAME "1"    

//������������������������������������������������������������������������Ŀ
//�Acidentes por Parte Atingida                                            �
//��������������������������������������������������������������������������
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0002; //"Acidentes por Parte Atingida"
	DESCR STR0002; //"Acidentes por Parte Atingida"
	TYPE 5 ; 
	PARAMETERS "MDTP020" ;
	ONLOAD "MDTP020" ;
	REFRESH 300 ;
	NAME "2"    

//������������������������������������������������������������������������Ŀ
//�Dias sem Acidentes                                                      �
//��������������������������������������������������������������������������
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0003; //"Dias sem Acidentes"
	DESCR STR0003; //"Dias sem Acidentes"
	TYPE 1 ; 
	PARAMETERS "MDTP030" ;
	ONLOAD "MDTP030" ;
	REFRESH 300 ;
	NAME "3"    
//������������������������������������������������������������������������Ŀ
//�Indice de Anormalidade no Resultado dos Exames                          �
//��������������������������������������������������������������������������
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0004; //"�ndice de Anormalidade no Resultado dos Exames"
	DESCR STR0004; //"�ndice de Anormalidade no Resultado dos Exames"
	TYPE 3 ; 
	PARAMETERS "MDTP040" ;
	ONLOAD "MDTP040" ;
	REFRESH 300 ;
	NAME "4"    
//������������������������������������������������������������������������Ŀ
//�Ocorrencias de Doencas Ocupacionais                                     �
//��������������������������������������������������������������������������
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0005; //"Ocorr�ncias de Doen�as Ocupacionais"
	DESCR STR0005; //"Ocorr�ncias de Doen�as Ocupacionais"
	TYPE 5 ; 
	PARAMETERS "MDTP050" ;
	ONLOAD "MDTP050" ;
	REFRESH 300 ;
	NAME "5"    
//������������������������������������������������������������������������Ŀ
//�Asos's Emitidos (Aptos/Inaptos)                                         �
//��������������������������������������������������������������������������
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0006; //"Asos's Emitidos"
	DESCR STR0006; //"Asos's Emitidos"
	TYPE 1 ; 
	PARAMETERS "MDTP060" ;
	ONLOAD "MDTP060" ;
	REFRESH 300 ;
	NAME "6"    
//������������������������������������������������������������������������Ŀ
//�Planos de Acao da CIPA (Abertas/Fechadas)                               �
//��������������������������������������������������������������������������
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0007; //"Planos de A��o da CIPA"
	DESCR STR0007; //"Planos de A��o da CIPA"
	TYPE 1 ; 
	PARAMETERS "MDTP070" ;
	ONLOAD "MDTP070" ;
	REFRESH 300 ;
	NAME "7"    
//������������������������������������������������������������������������Ŀ
//�Dias Perdidos em Acidentes de Trabalho                                  �
//��������������������������������������������������������������������������
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0008; //"Dias Perdidos em Acidentes de Trabalho"
	DESCR STR0008; //"Dias Perdidos em Acidentes de Trabalho"
	TYPE 1 ; 
	PARAMETERS "MDTP080" ;
	ONLOAD "MDTP080" ;
	REFRESH 300 ;
	NAME "8"    

//������������������������������������������������������������������������Ŀ
//�Despesas com Acidentes de Trabalho                                      �
//��������������������������������������������������������������������������
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0009; //"Despesas com Acidentes de Trabalho"
	DESCR STR0009; //"Despesas com Acidentes de Trabalho"
	TYPE 1 ; 
	PARAMETERS "MDTP090" ;
	ONLOAD "MDTP090" ;
	REFRESH 300 ;
	NAME "9"    
Return .T.