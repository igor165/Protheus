#INCLUDE "PanelOnLine.ch"
#INCLUDE "TMKPGONL.CH"

/*                
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMKPGONL     ³ Autor ³Michel W. Mosca      ³ Data ³ 07/02/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Exibe os paineis de gestao para o modulo SIGATMK.			   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CALL CENTER                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³ Data/Bops/Ver ³Manutencao Efetuada                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Conrado Q.³22/02/07³115977³- Adicionado painel número 2.                ³±±
±±³Michel M. ³26/02/07³115978³- Adicionado painel numero 3.                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMKPGONL(oPgOnline) 

PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0001;  // "Status dos atendimentos em cobrança"
	DESCR STR0001;  // STR0002 // "Exibe a quantidade de atendimentos em cobrança por campanha"
	TYPE 2 ;	         
	PARAMETERS "TMKH04";
	ONLOAD "TK274PGOn1"; 
	REFRESH 100 ;
	DEFAULT 2 ;
	NAME "1"
	                
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0003; // "Status dos atendimentos em telemarketing"
	DESCR STR0003; // STR0004 // "Exibe a quantidade de atendimentos em telemarketing por campanha"
	TYPE 2 ;	         
	PARAMETERS "TMKH05";
	ONLOAD "TK272PGOn1"; 
	REFRESH 30 ;
	DEFAULT 2 ;
	NAME "2"  
	
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0005;  //"Status dos Atendimentos de Televendas" ;
	DESCR STR0005;  //STR0006 //"Exibe a quantidade de atendimentos realizados pelo Televendas por campanha"; 
	TYPE 2 ;	         
	PARAMETERS "TMKH06";
	ONLOAD "TK273PGON3"; 
	REFRESH 100 ;
	DEFAULT 2 ;
	NAME "3" 		

Return       

