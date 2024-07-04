#include "PanelOnLine.Ch"
#include "Protheus.Ch"
#include "Finxpgl.Ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �FINPGOnl  � Autor � Marcel Borges Ferreira� Data � 31/01/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Definicao dos paineis on-line para modulo Financeiro 	     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � FinPgOnl  								   	  	           ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � NIL                                                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGAFIN  			   									           ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function FINPGOnl(oPGOnline)

	PANELONLINE oPgOnLine ADDPANEL;
		TITLE STR0001; //"Cota��es"
		DESCR STR0002; //"Cotacoes de Moedas"
		TYPE 5;
	 	ONLOAD "FinLOnl01";                          
		TOOLBAR {{"S4WB016N","Help","{ || MsgInfo('"+STR0019+"') }"}}; //"Exibe a cota��o das moedas na data base cadastrada na tabela SM2"
		NAME "FinLOnl01" ;
		PYME
//		NOTIMER;
	
	PANELONLINE oPgOnLine ADDPANEL;
		TITLE STR0003;//Titulos a receber em atraso
		DESCR STR0003;//Titulos a receber em atraso
		TYPE 1;
	 	ONLOAD "FinLOnl02";
		REFRESH 600;
		TOOLBAR {{"S4WB016N","Help","{ || MsgInfo('"+STR0020+"') }"}};//"Exibe os t�tulos a receber em atraso com base na data de vencimento real (E2_VENCREA)"		
		NAME "FinLOnl02" ;
		PYME
	
	PANELONLINE oPgOnLine ADDPANEL;
		TITLE STR0004;//Maiores devedores
		DESCR STR0004;//Maiores devedores
		TYPE 2;
		PARAMETERS "FINPGL05";	
	 	ONLOAD "FinLOnl03"; 	
		REFRESH 1200;
		TOOLBAR {{"S4WB016N","Help","{ || MsgInfo('"+STR0021+"') }"}};//"Exibe os maiores devedores at� a data, com o saldo dos t�tulos atrasados"
		DEFAULT 3;
		NAME "FinLOnl03" ;
		PYME
	
	PANELONLINE oPgOnLine ADDPANEL;
		TITLE STR0005;//Maiores credores
		DESCR STR0005;//Maiores credores
		TYPE 2;
		PARAMETERS "FINPGL06";	
	 	ONLOAD "FinLOnl04"; 	
		REFRESH 1200;
		TOOLBAR {{"S4WB016N","Help","{ || MsgInfo('"+STR0022+"') }"}};//"Exibe os maiores credores at� a data, com o saldo dos t�tulos atrasados"
		DEFAULT 3;		
		NAME "FinLOnl04" ;
		PYME
	
	PANELONLINE oPgOnLine ADDPANEL;
		TITLE STR0006;//"Titulos a receber a vencer"
		DESCR STR0006;//"Titulos a receber a vencer"
		TYPE 2;
		PARAMETERS "FINPGL07";
	 	ONLOAD "FinLOnl05"; 	
		REFRESH 600;
		TOOLBAR {{"S4WB016N","Help","{ || MsgInfo('"+STR0023+"') }"}};//"Exibe uma lista com os t�tulos a receber pr�ximos do vencimento real (E1_VENCREA) nos pr�ximos dias."
		DEFAULT 3;
		NAME "FinLOnl05";
		TITLECOMBO STR0007 ; //"Nos pr�ximos"
		PYME

	PANELONLINE oPgOnLine ADDPANEL;
		TITLE STR0008;//"Titulos a pagar a vencer"
		DESCR STR0008;//"Titulos a pagar a vencer"
		TYPE 2;
		PARAMETERS "FINPGL08";		
	 	ONLOAD "FinLOnl06"; 	
		REFRESH 600;
		TOOLBAR {{"S4WB016N","Help","{ || MsgInfo('"+STR0024+"') }"}};//"Exibe uma lista com os t�tulos a pagar pr�ximos do vencimento real (E2_VENCREA) nos pr�ximos dias."
		DEFAULT 3;
		NAME "FinLOnl06";
		TITLECOMBO STR0007;  //"Nos pr�ximos"	
		PYME
	
	PANELONLINE oPgOnLine ADDPANEL;
		TITLE STR0009; //"Maiores Fornecedores"
		DESCR STR0009+" - "+STR0011; //"Maiores Fornecedores - por data"
		TYPE 2;
		PARAMETERS "FINPGL01";	
	 	ONLOAD "FinLOnl07";
		REFRESH 1200;
		TOOLBAR {{"S4WB016N","Help","{ || MsgInfo('"+STR0025+"') }"}};//"Exibe os fornecedores que mais geraram t�tulos a pagar a partir de uma data at� a data atual"		
		DEFAULT 3;
		NAME "FinLOnl07" ;
		PYME

	PANELONLINE oPgOnLine ADDPANEL;
		TITLE STR0010; //"Maiores Clientes"
		DESCR STR0010+" - "+STR0011; //"Maiores Clientes - por data"
		TYPE 2;
		PARAMETERS "FINPGL02";
	 	ONLOAD "FinLOnl08";
		TOOLBAR {{"S4WB016N","Help","{ || MsgInfo('"+STR0026+"') }"}};	//"Exibe os clientes que mais geraram t�tulos a receber a partir de uma data at� a data atual"
		DEFAULT 3;
		NAME "FinLOnl08";
		REFRESH 1200 ;
		PYME


	PANELONLINE oPgOnLine ADDPANEL;
		TITLE STR0012; //"Saldos Banc�rios"
		DESCR STR0012; //"Saldos Banc�rios"
		TYPE 2;
	 	ONLOAD "FinLOnl09";
		REFRESH 1200;
		TOOLBAR {{"S4WB016N","Help","{ || MsgInfo('"+STR0027+"') }"}};//"Exibe os saldos banc�rios dos bancos cadastrados na tabela SA6"
		NAME "FinLOnl09" ;
		DEFAULT 2;		
		NAME "FinLOnl09";
		TITLECOMBO "Bancos"
		
	
	PANELONLINE oPgOnLine ADDPANEL;
		TITLE STR0013; //"Aging a Pagar"
		DESCR STR0014; //"Titulos a Pagar:"
		TYPE 5;
		PARAMETERS "FINPGL03";	
	 	ONLOAD "FinLOnl10";
		REFRESH 1200;
		TOOLBAR {{"S4WB016N","Help","{ || MsgInfo('"+STR0028+"') }"}};		
		NAME "FinLOnl10" 
			
	PANELONLINE oPgOnLine ADDPANEL;
		TITLE STR0015; //"Aging a Receber"
		DESCR STR0016; //"Titulos a Receber:"
		TYPE 5;
		PARAMETERS "FINPGL04";	
	 	ONLOAD "FinLOnl11";
		REFRESH 1200;
		TOOLBAR {{"S4WB016N","Help","{ || MsgInfo('"+STR0029+"') }"}};		
		NAME "FinLOnl11"  
		
	PANELONLINE oPgOnLine ADDPANEL;
		TITLE STR0017; //"Aplica��es e empr�stimos"
		DESCR STR0017+" - "+STR0018+" "+GetMV("MV_SIMB1"); //"Aplica��es e empr�stimos" "Valores em"
		TYPE 2;
	 	ONLOAD "FinLOnl12";
		REFRESH 1200;
		TOOLBAR {{"S4WB016N","Help","{ || MsgInfo('"+STR0030+"') }"}};		
		DEFAULT 1;		
		NAME "FinLOnl12"				

	PANELONLINE oPgOnLine ADDPANEL;
		TITLE STR0032;//Valores a receber - por risco
		DESCR STR0033;// Valores a receber classificados por risco
		TYPE 2;
	 	ONLOAD "FinLOnl13";
		REFRESH 1200;
		TOOLBAR {{"S4WB016N","Help","{ || MsgInfo('"+STR0031+"') }"}};		
		DEFAULT 2;		
		NAME "FinLOnl13";				
		TITLECOMBO STR0034
			
Return
