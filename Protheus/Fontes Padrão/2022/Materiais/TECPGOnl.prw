#INCLUDE "PanelOnLine.ch"
#INCLUDE "TECPGONL.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ TECPGOnl   ³ Autor ³ Conrado Q. Gomes    ³ Data ³ 09.02.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Painéis de gestão on-line                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                 											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGATEC                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TECPGOnl(oPGOnline)

	Local aToolBar	:= {}

	aToolBar := {}
	Aadd( aToolBar, { "S4WB016N", STR0001, { || MsgInfo( STR0002 + Chr(13) + Chr(10) + STR0003 ) } } ) // "Este cálculo é baseado na somatória do valor bruto dos itens da nota-fiscal" + Chr(13) + Chr(10) + "das O.S. faturadas, separado pelo mês de emissão da fatura."

	PANELONLINE oPGOnline ADDPANEL ;
		TITLE STR0004 ; // "Faturamento médio por O.S."
		DESCR STR0005 ; // "Valor médio de faturamento por O.S."                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
		TYPE 1 ;
		ONLOAD "AT450PGOnL1" ;
		PARAMETERS "ATP450" ;		
		REFRESH 14400 ; // 4 hora
		TOOLBAR aToolBar ;	
		NAME "1"

	aToolBar := {}
	Aadd( aToolBar, { "S4WB016N", STR0001, { || MsgInfo( STR0006 + Chr(13) + Chr(10) + STR0007 ) } } ) // "Este cálculo é baseado na somatória do total de horas faturadas dos atendimentos" + Chr(13) + Chr(10) + "das O.S., separado pelo mês do término do atendimento."
		
	PANELONLINE oPGOnline ADDPANEL ;
		TITLE STR0008 ; // "Atendimento médio por O.S."
		DESCR STR0009 ; // "Tempo médio de atendimento por O.S."
		TYPE 1 ;
		ONLOAD "AT460PGOnL1" ;
		PARAMETERS "ATP460" ;		
		REFRESH 14400 ; // 4 hora
		TOOLBAR aToolBar ;	
		NAME "2"				
		
Return	