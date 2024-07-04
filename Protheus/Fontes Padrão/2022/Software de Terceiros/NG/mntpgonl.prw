#INCLUDE "MNTPGONL.ch"
#Include "PanelOnLine.ch"

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �MNTPGONL  � Autor � Elisangela Costa      � Data � 02/03/2007 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Painel de Gestao.                                             ���
���          �Chama Painel de Gestao na entrada do sistema (SIGAMDI).    	���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   �MNTPGONL(oPGOnline)                                           ���
���������������������������������������������������������������������������Ĵ��
���Uso       �Generico                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function MNTPGONL(oPGOnline)

//������������������������������������������������������������������������Ŀ
//�MTBF e MTTR/TMPR                                                        �
//��������������������������������������������������������������������������
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0001;	 //"MTBF e MTTR/TMPR"
	DESCR STR0001;	 //"MTBF e MTTR/TMPR"
	TYPE 1 ; 
	PARAMETERS "MNTP010" ;
	ONLOAD "MNTP010" ;
	REFRESH 300 ;
	NAME "1"    
          
//������������������������������������������������������������������������Ŀ
//�Soliciatacoes de Servico Pententes                                      �
//��������������������������������������������������������������������������
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0002;	 //"SS Pendentes" 
	DESCR STR0002;	 //"SS Pendentes"
	TYPE 1 ; 
	PARAMETERS "MNTP020" ;
	ONLOAD "MNTP020" ;
	REFRESH 300 ;
	NAME "2"    

//������������������������������������������������������������������������Ŀ
//�Distribuicao de Solicitacoes de Servico                                 �
//��������������������������������������������������������������������������
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0003;	 //"Distribui��o SS" 
	DESCR STR0003;	 //"Distribui��o SS"
	TYPE 5 ; 
	PARAMETERS "MNTP030" ;
	ONLOAD "MNTP030" ;
	REFRESH 300 ;
	NAME "3"    

//������������������������������������������������������������������������Ŀ
//�Situacao das Ordens de Servico em Aberto                                �
//��������������������������������������������������������������������������
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0004;	 //"Situa��o OS em Aberto"
	DESCR STR0004;	 //"Situa��o OS em Aberto"
	TYPE 1 ; 
	PARAMETERS "MNTP040" ;
	ONLOAD "MNTP040" ;
	REFRESH 300 ;
	NAME "4" 

//������������������������������������������������������������������������Ŀ
//�Posicao de Ordens de Servico                                            �
//��������������������������������������������������������������������������  
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0005;	 //"Posi��o OS "
	DESCR STR0005;	 //"Posi��o OS "
	TYPE 2 ; 
	PARAMETERS "MNTP050" ;
	ONLOAD "MNTP050" ;
	REFRESH 300 ;  
    DEFAULT 2 ;
	NAME "5" ;
	TITLECOMBO STR0006    //"Status"

//������������������������������������������������������������������������Ŀ
//�% de Atendimento de Ordem de Servico                                    �
//��������������������������������������������������������������������������
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0007;	 //"% Atendimento OS"
	DESCR STR0007;	 //"% Atendimento OS"
	TYPE 4 ; 
	ONLOAD "MNTP060" ;
	REFRESH 300 ;
	NAME "6"            		                          

Return .T.