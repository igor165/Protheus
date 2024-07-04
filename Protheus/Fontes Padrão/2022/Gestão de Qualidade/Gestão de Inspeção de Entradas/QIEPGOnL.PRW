#Include "PanelOnLine.ch" 
#Include "QIEPGONL.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ QIEPGOnl ³ Autor ³ Cicero Cruz           ³ Data ³ 28/02/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Painel de Gestao On-line - Ambiente Inpeção de Entradas    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QIEPGOnl(ExpO1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = obj do proces.                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAQIE                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function QIEPGOnl(oPGOnline)

PANELONLINE oPGOnline ADDPANEL;
	TITLE STR0002; 					//"Indice de Qualidade Fornecedor X Produto"  	
	DESCR STR0002+" - "+STR0001; 	// "Indice de Qualidade Fornecedor X Produto"###"Inspeção de Entradas"
	TYPE 2; 				
	PARAMETERS "QEP010";
	ONLOAD "QIEP010"; 		
	REFRESH 600; 			
	DEFAULT 1; 			
	TITLECOMBO STR0003; 			//"Analisar : "
	NAME "1" 				

PANELONLINE oPGOnline ADDPANEL;
	TITLE STR0004; 					// "Resultados por Fornecedor X Produto "  	
	DESCR STR0004+" - "+STR0001; 	// "Resultados por Fornecedor X Produto "###"Inspeção de Entradas"
	TYPE 2;
	PARAMETERS "QEP020";
	ONLOAD "QIEP020"; 		
	REFRESH 600; 			
	DEFAULT 1; 			
	TITLECOMBO STR0003; 			//"Analisar : "
	NAME "2"

PANELONLINE oPGOnline ADDPANEL;
	TITLE STR0005; 					// "Entradas Inspecionadas/à Inspecionar"  	
	DESCR STR0005; 					// "Entradas Inspecionadas/à Inspecionar"
	TYPE 5; 				
	PARAMETERS "QEP030";
	ONLOAD "QIEP030"; 		
	REFRESH 3600; 			
	DEFAULT 5; 			
	TITLECOMBO STR0003; 			//"Analisar : "
	NAME "3"

PANELONLINE oPGOnline ADDPANEL;
	TITLE STR0006; 					// "Não-Conformidades X Fornecedor"  	
	DESCR STR0006+" - "+STR0001; 	// "Não-Conformidades X Fornecedor"###"Inspeção de Entradas"
	TYPE 2;
	PARAMETERS "QEP040";
	ONLOAD "QIEP040"; 		
	REFRESH 600; 			
	DEFAULT 1; 			
	TITLECOMBO STR0003; 			//"Analisar : "
	NAME "4"
			
Return	
