#INCLUDE "PROTHEUS.CH"
#INCLUDE "PanelOnLine.ch"
#INCLUDE "CTBXPGL.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออออหออออออัอออออออออออปฑฑ
ฑฑบPrograma  ณCTBXPGL   บAutor  ณEduardo Nunes Cirqueira บ Data ณ  21/12/06 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออออสออออออฯอออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo para declarar todos os Paineis de Gestao disponibili- บฑฑ
ฑฑบ          ณ zados no SIGACTB.                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 9                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function CTBPGOnl(oPGOnline)
Local aToolBar1 	:= {}
Local aToolBar2 	:= {}
Local aToolBar3 	:= {}
Local aToolBar4 	:= {}
Local aToolBar5 	:= {}
Local aToolBar6 	:= {}
Local aToolBar7 	:= {}
Local aToolBar8 	:= {}
Local aToolBar9 	:= {}
Local aToolBar10 	:= {}
Local aToolBar11 	:= {}
Local aToolBar12 	:= {}

//---------------------------------------------------------------------------------//
	Aadd( aToolBar1, { "S4WB016N","Help",{ || MsgInfo(CtbHelpPainel("CtCmpEntGer")) } } ) 

	PANELONLINE oPGOnline ADDPANEL	;
		TITLE STR0001  				/*	"Comparativo - Entidades Gerenciais"*/ ;
		DESCR STR0002				/*	"Comparativo m๊s a m๊s de Saldos de Entidades Gerenciais"*/ ;
		TYPE 2						;
		PARAMETERS "CTBPGL010"		;
		ONLOAD "CtCmpEntGer"		;
		REFRESH 300 				/* 300 segundos = 5 minutos */;
		DEFAULT 1					;
		TOOLBAR aToolBar1 			;
		NAME "1"					;
		TITLECOMBO STR0003 			/*"Entidades Gerenciais"*/ 

//---------------------------------------------------------------------------------//
	Aadd( aToolBar2, { "S4WB016N","Help",{ || MsgInfo(CtbHelpPainel("CtCmpAnoAnt")) } } ) 

	PANELONLINE oPGOnline ADDPANEL	;
		TITLE STR0008 				/*	"Comparativo Gerencial - Anos Anteriores"*/ ;
		DESCR STR0004 				/*	"Comparativo de Saldos de Ent. Gerenciais - Anos Anteriores"*/ ;
		TYPE 2						;
		PARAMETERS "CTBPGL020"		;
		ONLOAD "CtCmpAnoAnt"		;
		REFRESH 300 				/*	300 segundos = 5 minutos */;
		DEFAULT 1					;
		TOOLBAR aToolBar2 			;
		NAME "2"					;
		TITLECOMBO STR0003			/*	"Entidades Gerenciais"*/   

//---------------------------------------------------------------------------------//
	Aadd( aToolBar3, { "S4WB016N","Help",{ || MsgInfo(CtbHelpPainel("CtCmpSldEnt")) } } ) 

	PANELONLINE oPGOnline ADDPANEL	;
		TITLE STR0005				/*"Comparativo de Entidades"*/ ;
		DESCR STR0006 				/*"Comparativo de Saldos com Meses Anteriores"*/ ;
		TYPE 2						;
		PARAMETERS "CTBPGL030"		;
		ONLOAD "CtCmpSldEnt"		;
		REFRESH 300 				/* 300 segundos = 5 minutos */;
		DEFAULT 1					;
		TOOLBAR aToolBar3 			;
		NAME "3"					;
		TITLECOMBO STR0007			/*"Entidades Gerenciais"*/ ;
		PYME

//---------------------------------------------------------------------------------//
	Aadd( aToolBar4, { "S4WB016N","Help",{ || MsgInfo(CtbHelpPainel("CtEbitda")) } } )

	PANELONLINE oPGOnline ADDPANEL ;
		TITLE STR0009				/*	"Evolu็ใo Mensal EBITDA"*/ ;
		DESCR STR0009 				/*	"Evolu็ใo Mensal EBITDA"*/ ;
		TYPE 1 						;
		PARAMETERS "CTBPGL040"		;
		ONLOAD "CtEbitda"			;
		REFRESH 300 				/*	300 segundos = 5 minutos */;
		DEFAULT 1					;
		TOOLBAR aToolBar4 			;
		NAME "4"

//---------------------------------------------------------------------------------//
	Aadd( aToolBar5, { "S4WB016N","Help",{ || MsgInfo(CtbHelpPainel("CtPreLan")) } } ) 

	PANELONLINE oPGOnline ADDPANEL ;
		TITLE STR0010				/*	"Pr้-Lan็amentos por Moeda"*/ ;
		DESCR STR0011 				/*	"Quantidade e Valor de Pr้-Lan็amentos por Moeda"*/ ;
		TYPE 5 						;
		PARAMETERS "CTBPGL050"		;
		ONLOAD "CtPreLan"			;
		REFRESH 300 				/*	300 segundos = 5 minutos */;
		DEFAULT 1 					;
		TOOLBAR aToolBar5 			;
		NAME "5" 					;
		PYME

//---------------------------------------------------------------------------------//
	Aadd( aToolBar6, { "S4WB016N","Help",{ || MsgInfo(CtbHelpPainel("CtCmpEntAnt")) } } )

	PANELONLINE oPGOnline ADDPANEL	;
		TITLE STR0012				/*	"Comparativo de Entidades - Anos Anteriores" */	;
		DESCR STR0013				/*	"Comparativo de Saldos de Entidades - Anos Anteriores" */	;
		TYPE 2						;
		PARAMETERS "CTBPGL060"		;
		ONLOAD "CtCmpEntAnt"		;
		REFRESH 300					/*	300 segundos = 5 minutos	*/	;
		DEFAULT 1					;
		TOOLBAR aToolBar6 			;
		NAME "6"					;
		TITLECOMBO STR0003			/*	"Entidades Gerenciais" */ ;
		PYME

//---------------------------------------------------------------------------------//
	Aadd( aToolBar7, { "S4WB016N","Help",{ || MsgInfo(CtbHelpPainel("CtIndPat")) } } ) 

	PANELONLINE oPGOnline ADDPANEL	;
		TITLE STR0016				/*	"Estrutura Patrimonial" */	;
		DESCR STR0017				/*	"Indice de Estrutura Patrimonial" */ ;
		TYPE 1						;
		PARAMETERS "CTBPGL070"		;
		ONLOAD "CtIndPat"			;
		REFRESH 300					/*	300 segundos = 5 minutos */	;
		DEFAULT 1					;
		TOOLBAR aToolBar7 			;
		NAME "7" 

//---------------------------------------------------------------------------------//
	Aadd( aToolBar8, { "S4WB016N","Help",{ || MsgInfo(CtbHelpPainel("CtbPrzMed")) } } ) 

	PANELONLINE oPGOnline ADDPANEL	;
		TITLE STR0014 				/*  "Prazos Medios" */	;
		DESCR STR0015 				/*  "Indices de Prazos Medios" */ ;
		TYPE 1 						;
		PARAMETERS "CTBPGL080"		;
		ONLOAD "CtbPrzMed" 			;
		REFRESH 300					/*	300 segundos = 5 minutos */	;
		DEFAULT 1					;
		TOOLBAR aToolBar8 			;
		NAME "8"

//---------------------------------------------------------------------------------//
	Aadd( aToolBar9, { "S4WB016N","Help",{ || MsgInfo(CtbHelpPainel("CtbGiros")) } } ) 

	PANELONLINE oPGOnline ADDPANEL	;
		TITLE STR0018 				; //"Giro dos Recursos" 	
		DESCR STR0019 				; //"Indices de Rotacao dos Recursos"
		TYPE 1 						;
		PARAMETERS "CTBPGL090"		;
		ONLOAD "CtbGiros" 			;
		REFRESH 300					/*	300 segundos = 5 minutos */	;
		DEFAULT 1					;
		TOOLBAR aToolBar9 			;
		NAME "9"

//---------------------------------------------------------------------------------//
	Aadd( aToolBar10, { "S4WB016N","Help",{ || MsgInfo(CtbHelpPainel("CtRentab")) } } ) 

	PANELONLINE oPGOnline ADDPANEL	;
		TITLE STR0020				/*  "Rentabilidade" */	;
		DESCR STR0021				/*  "Margens de Rentabilidade" */	;
		TYPE 1 						;
		PARAMETERS "CTBPGL100"		;
		ONLOAD "CtRentab" 			;
		REFRESH 300					/*	300 segundos = 5 minutos */	;
		DEFAULT 1					;
		TOOLBAR aToolBar10 ;
		NAME "10"

//---------------------------------------------------------------------------------//
	Aadd( aToolBar12, { "S4WB016N","Help",{ || MsgInfo(CtbHelpPainel("CtSolv")) } } ) 

	PANELONLINE oPGOnline ADDPANEL	;
		TITLE STR0022				/*  "Indices de Solv๊ncia" */	;
		DESCR STR0022				/*  "Indices de Solv๊ncia" */	;
		TYPE 1 						;
		PARAMETERS "CTBPGL120"		;
		ONLOAD "CtSolv" 			;
		REFRESH 300					/*	300 segundos = 5 minutos */	;
		DEFAULT 1					;
		TOOLBAR aToolBar12 ;
		NAME "12"
//---------------------------------------------------------------------------------//
	Aadd( aToolBar11, { "S4WB016N","Help",{ || MsgInfo(CtbHelpPainel("CtbTxRetorno")) } } ) 

	PANELONLINE oPGOnline ADDPANEL	;
		TITLE STR0023	; //"Taxas de Retorno"
		DESCR STR0023	; //"Taxas de Retorno"
		TYPE 1 						;
		PARAMETERS "CTBPGL110"		;
		ONLOAD "CtbTxRetorno" 			;
		REFRESH 300					/*	300 segundos = 5 minutos */	;
		DEFAULT 1					;
		TOOLBAR aToolBar11 ;
		NAME "11"
//---------------------------------------------------------------------------------//

Return
