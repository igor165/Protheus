#INCLUDE "PCOXPGL.ch"
#Include "PanelOnLine.ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOPGOnl  บAutor  ณPaulo Carnelossi    บ Data ณ  13/02/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPaineis de Gestao Modulo SIGAPCO                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PCOPGOnl(oPGOnline)
Local aToolBar10 := {}
Local aToolBar20 := {}
Local aToolBar30 := {}
Local aToolBar40 := {}
Local aToolBar50 := {}
Local aToolBar60 := {}

Local lPerg010 := ( GetMv("MV_PCOP010") == "1" )
Local lPerg020 := ( GetMv("MV_PCOP020") == "1" )
Local lPerg050 := ( GetMv("MV_PCOP050") == "1" )
Local lPerg060 := ( GetMv("MV_PCOP060") == "1" )

//--------------------------------------------------------------------------------------------//
//  nao tirar linha comentada ------ esta ainda em implementacao a barra de tarefas
//	Aadd( aToolBar10, { "GRAF2D",STR0001,{ || PCOC330() } } ) //"Cubos - Saldo na Data"
	Aadd( aToolBar10, { "S4WB016N","Help",{ || MsgInfo(PcoHelpPainel("PCOPG010")) } } )

	PANELONLINE oPGOnline ADDPANEL ;
		TITLE STR0002 ; //"Saldo de Cubos"
		DESCR STR0003 ; //"Saldos de Cubos - 1a. Dimensao"
		TYPE 1 ;
		PARAMETERS If(lPerg010,"PCR900",Nil) ;
		ONLOAD "PCOPG010" ;
		REFRESH 900 ;
		TOOLBAR aToolBar10 ;
		NAME "010"

//--------------------------------------------------------------------------------------------//
//  nao tirar linha comentada ------ esta ainda em implementacao a barra de tarefas
//	Aadd( aToolBar20, { "GRAF2D","Cubos - Saldo na Data",{ || PCOC330() } } )
	Aadd( aToolBar20, { "S4WB016N","Help",{ || MsgInfo(PcoHelpPainel("PCOPG020")) } } ) 

	PANELONLINE oPGOnline ADDPANEL ;
		TITLE STR0004 ; //"Saldo de Cubos - 2 Configuracoes" 
		DESCR STR0005 ; //"Saldos de Cubos (2 Configuracoes) - 1a. Dimensao"
		TYPE 2 ;
		PARAMETERS If(lPerg020,"PCR910",Nil) ;
		ONLOAD "PCOPG020" ;
		REFRESH 960;
		DEFAULT 1 ;
		TOOLBAR aToolBar20 ;
		NAME "020" ;
		TITLECOMBO STR0006 //"Selecione"

//--------------------------------------------------------------------------------------------//
//  nao tirar linha comentada ------ esta ainda em implementacao a barra de tarefas
//	Aadd( aToolBar30, { "PCO_CONOR","Revisar Planilha",{ || PCOA120() } } )
	Aadd( aToolBar30, { "S4WB016N","Help",{ || MsgInfo(PcoHelpPainel("PCOPG030")) } } ) 

	PANELONLINE oPGOnline ADDPANEL ;
		TITLE STR0007 ; //"Planilhas em Revisao"
		DESCR STR0008 ; //"Planilhas Or็amentแrias em Revisao"
		TYPE 1 ;
		PARAMETERS NIL ;
		ONLOAD "PCOPG030" ;
		REFRESH 360 ;
		TOOLBAR aToolBar30 ;
		NAME "030"

//--------------------------------------------------------------------------------------------//
//  nao tirar linha comentada ------ esta ainda em implementacao a barra de tarefas
//	Aadd( aToolBar40, { "CADEADO","Tipos de Bloqueio",{ || PCOA090() } } )
	Aadd( aToolBar40, { "S4WB016N","Help",{ || MsgInfo(PcoHelpPainel("PCOPG040")) } } ) 

	PANELONLINE oPGOnline ADDPANEL ;
		TITLE STR0009 ;// "Bloqueios por Tipo"
		DESCR STR0010 ;// "Quantidade de Bloqueios por Tipo"
		TYPE 1 ;
		PARAMETERS NIL ;
		ONLOAD "PCOPG040" ;
		REFRESH 90 ;
		TOOLBAR aToolBar40 ;
		NAME "040"

//--------------------------------------------------------------------------------------------//
//  nao tirar linha comentada ------ esta ainda em implementacao a barra de tarefas
//	Aadd( aToolBar50, { "GRAF2D","Cubos - Saldo na Data",{ || PCOC330() } } )
	Aadd( aToolBar50, { "S4WB016N","Help",{ || MsgInfo(PcoHelpPainel("PCOPG050")) } } ) 

	PANELONLINE oPGOnline ADDPANEL ;
		TITLE STR0011 ; //"Saldos/Projecoes por Periodo"
		DESCR STR0011 ;  //"Saldos/Projecoes por Periodo"
		TYPE 2 ;
		PARAMETERS If(lPerg050,"PCR920",Nil) ;
		ONLOAD "PCOPG050" ;
		REFRESH 420 ;
		DEFAULT 2 ;
		TOOLBAR aToolBar50 ;
		NAME "050";
		TITLECOMBO STR0006 //"Selecione"

//--------------------------------------------------------------------------------------------//
//  nao tirar linha comentada ------ esta ainda em implementacao a barra de tarefas
//	Aadd( aToolBar60, { "GRAF2D","Cubos - Saldo na Data",{ || PCOC330() } } )
	Aadd( aToolBar60, { "S4WB016N","Help",{ || MsgInfo(PcoHelpPainel("PCOPG060")) } } ) 

	PANELONLINE oPGOnline ADDPANEL ;
		TITLE STR0012 ; //"Saldo de Cubos - Mes Atual x Mes Ano Anterior"
		DESCR  STR0013 ; //"Saldo de Cubos - Mes Atual x Mes Ano Anterior - 1a. Dimensao"
		TYPE 2 ;
		PARAMETERS If(lPerg060,"PCR930",Nil) ;
		ONLOAD "PCOPG060" ;
		REFRESH 960;
		DEFAULT 1 ;
		TOOLBAR aToolBar60 ;
		NAME "060" ;
		TITLECOMBO STR0006 //"Selecione"

Return	
