#INCLUDE "Protheus.ch"
#INCLUDE "PanelOnLine.ch"
#INCLUDE "LojaPgOnL.ch"

/*                
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³LOJAPGONL    ³ Autor ³Vendas Clientes      ³ Data ³ 26/02/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Exibe os paineis de gestão para o modulo SIGALOJA			   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Automação Comercial                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function LOJAPGONL(oPgOnline) 

PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0001 ;        // "Média de vendas por PDV por mês"
	DESCR STR0002 ;        // "Exibe a média de vendas efetuadas por mês por PDV"
	TYPE 5 ; 
	ONLOAD "LOJP010" ; 
	PARAMETERS "LOJP010" ; 
	REFRESH 3600 ;         // 1 Hora
	DEFAULT 5 ; 
	NAME "1" ; 
	PYME 

PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0003 ;        // "Ranking de venda das lojas"
	DESCR STR0004 ;        // "Exibe o ranking das lojas que mais vendem"
	TYPE 1 ; 
	ONLOAD "LOJP701" ; 
	PARAMETERS "LJP701" ; 
	REFRESH 14400 ;        // 4 Horas
	DEFAULT 1 ; 
	NAME "2" ; 
	PYME 

Return Nil