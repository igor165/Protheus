#Include "PanelOnLine.ch"
#include "QADPGOnl.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ QADPGOnl ³ Autor ³ Rafael S. Bernardi    ³ Data ³19/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Painel de Gestao On-line - Modulo SIGAQAD                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QADPGOnl(ExpO1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = obj do proces.                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAQAD                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QADPGOnl(oPGOnline)

Local aToolBar  := {} 
Local aToolBar2  := {} 
Local aToolBar3  := {} 
Local aToolBar4  := {} 
Local cHelp     := ""
Local cHelp2     := ""
Local cHelp3     := ""
Local cHelp4     := ""

cHelp := STR0006//"O sistema ira apresentar uma lista das auditorias que estao sendo executadas."

aToolBar:= {}
Aadd( aToolBar, { "S4WB016N","Help",&('{ || MsgInfo(Lower("'+cHelp+'")) }') } )

//--Painel 1 - Auditorias em andamento
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0001 ; //"Auditorias em andamento" - Esta descricao aparece na lista de paineis disponiveis, superior esquerdo
	DESCR STR0001 ; //"Auditorias em andamento" - Descricao na Barra Superior
	TYPE 5 ; //-- Tipo do Painel
	ONLOAD "QADP010" ; //--Funcao para montagem do Painel
	REFRESH 600 ; //--Tempo para Refresh do Painel em segundos
	TOOLBAR aToolBar ;//--Help que sera apresentado ao usuário sobre o resultado do painel
	DEFAULT 1	 ; //-- Default do Combo
	NAME "1" //--Ordem de Exibicao
	
cHelp2 := STR0007//"O sistema ira apresentar uma das auditorias que foram realizadas no periodo escolhido pelo usuario."

Aadd( aToolBar2, { "S4WB016N","Help",&('{ || MsgInfo(Lower("'+cHelp2+'")) }') } )

//--Painel 2 - "Auditorias realizadas"
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0002 ; //"Auditorias realizadas" - Esta descricao aparece na lista de paineis disponiveis, superior esquerdo
	DESCR STR0002 ; //"Auditorias realizadas" - Descricao na Barra Superior
	TYPE 5 ; //-- Tipo do Painel
	PARAMETERS "QADP20";
	ONLOAD "QADP020" ; //--Funcao para montagem do Painel
	REFRESH 600 ; //--Tempo para Refresh do Painel em segundos
	TOOLBAR aToolBar2 ;//--Help que sera apresentado ao usuário sobre o resultado do painel
	DEFAULT 1	 ; //-- Default do Combo
	NAME "2" //--Ordem de Exibicao

cHelp3 := STR0008//"O sistema ira apresentar uma lista das auditorias que estao prevista para serem realizadas no periodo escolhido pelo usuario."

Aadd( aToolBar3, { "S4WB016N","Help",&('{ || MsgInfo(Lower("'+cHelp3+'")) }') } )

//--Painel 2 - Auditorias previstas
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0003; //"Auditorias previstas" - Esta descricao aparece na lista de paineis disponiveis, superior esquerdo
	DESCR STR0003; //"Auditorias previstas" - Descricao na Barra Superior
	TYPE 5 ; //-- Tipo do Painel
	PARAMETERS "QADP30";
	ONLOAD "QADP030" ; //--Funcao para montagem do Painel
	REFRESH 600 ; //--Tempo para Refresh do Painel em segundos
	TOOLBAR aToolBar3 ;//--Help que sera apresentado ao usuário sobre o resultado do painel
	DEFAULT 1	 ; //-- Default do Combo
	NAME "3" //--Ordem de Exibicao 
	
cHelp4 := STR0009//"O sistema ira apresentar os numeros de nao conformidades por auditorias. "
cHelp4 += STR0010//"Os resultados serao apresentados em tres dimensoes: 1 - por auditorias, "
cHelp4 += STR0011//" 2 - por categorias  e 3 - por geracao de acao corretiva (Sim / Nao)."

Aadd( aToolBar4, { "S4WB016N","Help",&('{ || MsgInfo(Lower("'+cHelp4+'")) }') } )

//--Painel 4 - "Nao-Conformidades por auditoria"
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0004; //"Nao-Conformidades por auditoria" - Esta descricao aparece na lista de paineis disponiveis, superior esquerdo
	DESCR STR0004; //"Nao-Conformidades por auditoria" - Descricao na Barra Superior
	TYPE 2 ; //-- Tipo do Painel
	PARAMETERS "QADP40";	
	ONLOAD "QADP040" ; //--Funcao para montagem do Painel
	DEFAULT 1;
	REFRESH 600 ; //--Tempo para Refresh do Painel em segundos
	TOOLBAR aToolBar4 ;//--Help que sera apresentado ao usuário sobre o resultado do painel
	NAME "4" //--Ordem de Exibicao	
	
Return