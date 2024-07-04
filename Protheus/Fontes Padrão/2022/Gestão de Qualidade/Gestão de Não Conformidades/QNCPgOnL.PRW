#Include "PanelOnLine.ch"
#include "QNCPGOnl.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ QNCPGOnl ³ Autor ³ Rafael S. Bernardi    ³ Data ³27/02/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Painel de Gestao On-line - Modulo SIGAQNC                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QNCPGOnl(ExpO1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = obj do proces.                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAQNC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QNCPGOnl(oPGOnline)

Local aToolBar  := {}
Local aToolBar2 := {}
Local aToolBar3 := {}
Local aToolBar4 := {}
Local cHelp     := ""
Local cHelp2    := ""
Local cHelp3    := ""
Local cHelp4    := ""
         
cHelp := STR0009//"O sistema ira apresentar as FNC´s de produtos, geradas a partir do modulo QNC. "
cHelp += STR0010//"Os resultados sao apresentados em duas dimensoes: analise pelo numero das FNC´s "
cHelp += STR0011//"e analise pelo percentual que cada produto representa no universo do estudo."

Aadd( aToolBar, { "S4WB016N","Help",&('{ || MsgInfo(Lower("'+cHelp+'")) }') } )

//--Painel 1 - Nao-Conformidades por Produto
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0001 ; //"Nao-Conformidades por Produto" - Esta descricao aparece na lista de paineis disponiveis, superior esquerdo
	DESCR STR0001 ; //"Nao-Conformidades por Produto" - Descricao na Barra Superior
	TYPE 2 ; //-- Tipo do Painel
	PARAMETERS "QNCP10" ; //--Grupo de Perguntas
	ONLOAD "QNCP010" ; //--Funcao para montagem do Painel
	REFRESH 600 ; //--Tempo para Refresh do Painel em segundos
	TOOLBAR aToolBar ;//--Help que sera apresentado ao usuário sobre o resultado do painel
	DEFAULT 1	 ; //-- Default do Combo
	TITLECOMBO STR0002 ; //"Analise por: " - Configura o Label do ComboBox
	NAME "1" //--Ordem de Exibicao
	
cHelp2 := STR0012//"O sistema ira apresentar as FNC´s de acordo com o status e desenvolvimento dos planos de acao. "
cHelp2 += STR0013//"Os resultados sao apresentados em quatro dimensoes: por tipo de FNC, por prioridade da FNC, "
cHelp2 += STR0014//"por status da FNC e por plano de acao."

Aadd( aToolBar2, { "S4WB016N","Help",&('{ || MsgInfo(Lower("'+cHelp2+'")) }') } )

//--Painel 2 - Status das FNC´s / Planos de Ação
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0003 ; //"Status das FNC´s / Planos de Ação" - Esta descricao aparece na lista de paineis disponiveis, superior esquerdo
	DESCR STR0003 ; //"Status das FNC´s / Planos de Ação" - Descricao na Barra Superior
	TYPE 2 ; //-- Tipo do Painel
	PARAMETERS "QNCP20" ; //--Grupo de Perguntas
	ONLOAD "QNCP020" ; //--Funcao para montagem do Painel
	REFRESH 600 ; //--Tempo para Refresh do Painel em segundos
	TOOLBAR aToolBar2 ;//--Help que sera apresentado ao usuário sobre o resultado do painel
	DEFAULT 1	 ; //-- Default do Combo
	TITLECOMBO STR0002 ; //"Análise por: " - Configura o Label do ComboBox
	NAME "2" //--Ordem de Exibicao

cHelp3 := STR0015//"O sistema ira apresentar as FNC´s de fornecedores, geradas a partir do modulo QNC. "
cHelp3 += STR0016//"Os resultados sao apresentados em quatro dimensoes: analise pelo numero de FNC´s "
cHelp3 += STR0017//"para o fornecedor, analise pela categoria das FNC´s, analise pelo efeito das FNC´s "
cHelp3 += STR0018//"e anlise pela disposicao das FNC´s."

Aadd( aToolBar3, { "S4WB016N","Help",&('{ || MsgInfo(Lower("'+cHelp3+'")) }') } )
	
//--Painel 3 - Nao-Conformidades por Fornecedor
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0004 ; //"Nao-Conformidades por Fornecedor" - Esta descricao aparece na lista de paineis disponiveis, superior esquerdo
	DESCR STR0004 ; //"Nao-Conformidades por Fornecedor" - Descricao na Barra Superior
	TYPE 2 ; //-- Tipo do Painel
	PARAMETERS "QNCP30" ; //--Grupo de Perguntas
	ONLOAD "QNCP030" ; //--Funcao para montagem do Painel
	REFRESH 600 ; //--Tempo para Refresh do Painel em segundos
	TOOLBAR aToolBar3 ;//--Help que sera apresentado ao usuário sobre o resultado do painel
	DEFAULT 1	 ; //-- Default do Combo
	TITLECOMBO STR0002 ; //"Análise por: " - Configura o Label do ComboBox
	NAME "3" //--Ordem de Exibicao
	
cHelp4 := STR0019//"O sistema ira apresentar as FNC´s de instumentos gerados no ambiente Metrologia "
cHelp4 += STR0020//"e no ambiente Nao-Conformidades. Os resultados sao apresentados em tres dimensoes "
cHelp4 += STR0021//"geradas no ambiente nao conformidades, gerados no ambiente metrologia ou ambas."

Aadd( aToolBar4, { "S4WB016N","Help",&('{ || MsgInfo(Lower("'+cHelp4+'")) }') } )

//--Painel 3 - Não-Conformidades por Instrumento
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0006 ; //"Não-Conformidades por Instrumento" - Esta descricao aparece na lista de paineis disponiveis, superior esquerdo
	DESCR STR0007 ; //"Não-Conformidades por Instrumento (TOP 5)" - Descricao na Barra Superior
	TYPE 2 ; //-- Tipo do Painel
	PARAMETERS "QNCP40" ; //--Grupo de Perguntas
	ONLOAD "QNCP040" ; //--Funcao para montagem do Painel
	REFRESH 600 ; //--Tempo para Refresh do Painel em segundos
	TOOLBAR aToolBar4 ;//--Help que sera apresentado ao usuário sobre o resultado do painel
	DEFAULT 1	 ; //-- Default do Combo
	TITLECOMBO STR0008 ; //"Módulo:" - Configura o Label do ComboBox
	NAME "4" //--Ordem de Exibicao
	
Return