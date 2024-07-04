#INCLUDE "PanelOnLine.ch"
#INCLUDE "TECPGONL.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TECPGOnl   � Autor � Conrado Q. Gomes    � Data � 09.02.07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Pain�is de gest�o on-line                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                 											  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �SIGATEC                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TECPGOnl(oPGOnline)

	Local aToolBar	:= {}

	aToolBar := {}
	Aadd( aToolBar, { "S4WB016N", STR0001, { || MsgInfo( STR0002 + Chr(13) + Chr(10) + STR0003 ) } } ) // "Este c�lculo � baseado na somat�ria do valor bruto dos itens da nota-fiscal" + Chr(13) + Chr(10) + "das O.S. faturadas, separado pelo m�s de emiss�o da fatura."

	PANELONLINE oPGOnline ADDPANEL ;
		TITLE STR0004 ; // "Faturamento m�dio por O.S."
		DESCR STR0005 ; // "Valor m�dio de faturamento por O.S."                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
		TYPE 1 ;
		ONLOAD "AT450PGOnL1" ;
		PARAMETERS "ATP450" ;		
		REFRESH 14400 ; // 4 hora
		TOOLBAR aToolBar ;	
		NAME "1"

	aToolBar := {}
	Aadd( aToolBar, { "S4WB016N", STR0001, { || MsgInfo( STR0006 + Chr(13) + Chr(10) + STR0007 ) } } ) // "Este c�lculo � baseado na somat�ria do total de horas faturadas dos atendimentos" + Chr(13) + Chr(10) + "das O.S., separado pelo m�s do t�rmino do atendimento."
		
	PANELONLINE oPGOnline ADDPANEL ;
		TITLE STR0008 ; // "Atendimento m�dio por O.S."
		DESCR STR0009 ; // "Tempo m�dio de atendimento por O.S."
		TYPE 1 ;
		ONLOAD "AT460PGOnL1" ;
		PARAMETERS "ATP460" ;		
		REFRESH 14400 ; // 4 hora
		TOOLBAR aToolBar ;	
		NAME "2"				
		
Return	