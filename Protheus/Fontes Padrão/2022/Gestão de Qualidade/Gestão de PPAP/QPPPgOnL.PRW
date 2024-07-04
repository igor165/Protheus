#Include "PanelOnLine.ch"
#include "PPAPPGOnl.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ QPPPGOnl ³ Autor ³ Rafael S. Bernardi    ³ Data ³22/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Painel de Gestao On-line - Modulo SIGAPPAP                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QPPPGOnl(ExpO1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = obj do proces.                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAPPAP                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PPAPPGOnl(oPGOnline)
Local aToolBar := {}
Local cHelp    := ""
         
cHelp := STR0001//"O sistema ira listar as pecas de acordo com o intervalo definido pelo usuario. "
cHelp += STR0002//"Ira considerar um PPAP completo, se existerem todos os documentos selecionados "
cHelp += STR0003//"no primeiro parametro pelo usuario para aquela peca. Caso contrario, ira considerar "
cHelp += STR0004//"o PPAP da peca como incompleto."

Aadd( aToolBar, { "S4WB016N","Help",&('{ || MsgInfo(Lower("'+cHelp+'")) }') } )

//--Painel 1 - PPAPs Completos / Incompletos
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0005 ; //"PPAPs Completos / Incompletos" - Esta descricao aparece na lista de paineis disponiveis, superior esquerdo
	DESCR STR0005 ; //"PPAPs Completos / Incompletos" - Descricao na Barra Superior
	TYPE 5 ; //-- Tipo do Painel
	PARAMETERS "QPPP10" ; //--Grupo de Perguntas
	ONLOAD "QPPP010" ; //--Funcao para montagem do Painel
	REFRESH 600 ; //--Tempo para Refresh do Painel em segundos
	TOOLBAR aToolBar ;//--Help que sera apresentado ao usuário sobre o resultado do painel
	DEFAULT 5	 ; //-- Default do Combo
	NAME "1"; //--Ordem de Exibicao
	
Return