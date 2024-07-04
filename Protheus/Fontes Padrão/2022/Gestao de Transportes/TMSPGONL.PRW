#Include "PanelOnLine.ch"
#Include "tmspgonl.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ TMSPGOnl ³ Autor ³ Rodolfo K. Rosseto    ³ Data ³ 06/02/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Painel de Gestao On-line - Modulo SIGATMS                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSPGOnl(ExpO1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = obj do proces.                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSPGOnl(oPGOnline)
                         
//--Painel 1 - Analise de Clientes
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0004 ; //"Analise de Clientes" - Esta descricao aparece na lista de paineis disponiveis, superior esquerdo
	DESCR STR0004 ; //"Análise de Clientes" - Descricao na Barra Superior
	TYPE 2 ; //-- Tipo do Painel
	PARAMETERS "TMSP010" ; //--Grupo de Perguntas
	ONLOAD "TMSP010" ; //--Funcao para montagem do Painel
	REFRESH 300 ; //--Tempo para Refresh do Painel em segundos
	DEFAULT 1	 ; //-- Default do Combo
	TITLECOMBO STR0006 ; //"Análise por: " - Configura o Label do ComboBox
	NAME "1" //--Ordem de Exibicao

//--Painel 2 - Ocupacao de Frota - Peso das Mercadorias
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0005 ; //"Ocupacao por Peso"
	DESCR STR0003 ; //"Peso das Mercadorias X Capacidade dos Veículos"
	TYPE 3 ; //--Modelo do Painel
	PARAMETERS "TMSP020" ; //--Grupo de Perguntas
	ONLOAD "TMSP020" ; //--Funcao para montagem do Painel
	REFRESH 300 ; //--Tempo para Refresh do Painel em segundos
	NAME "2" //--Ordem de Exibicao

//--Painel 3 - Ocupacao de Frota - Horas utilizadas da Frota 
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0001 ; //--"Ocupacao por Hora"
	DESCR STR0002 ; //--"Hora de Utilizacao X Horas Disponiveis"
	TYPE 3 ; //--Modelo do Painel
	PARAMETERS "TMSP030" ; //--Grupo de Perguntas
	ONLOAD "TMSP030" ; //--Funcao para montagem do Painel
	REFRESH 300 ; //--Tempo para Refresh do Painel em segundos
	NAME "3" //--Ordem de Exibicao  */
	                                      
	//--Painel 4 - Status das Coletas 
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0007 ; //--"Coletas"
	DESCR STR0008 ; //--"Status dos Documentos de Coleta"
	TYPE 1 ; //--Modelo do Painel
	PARAMETERS "TMSP040" ; //--Grupo de Perguntas
	ONLOAD "TMSP040" ; //--Funcao para montagem do Painel
	REFRESH 300 ; //--Tempo para Refresh do Painel em segundos
	NAME "4" //--Ordem de Exibicao   */
                                   
	//--Painel 5 - Status das Entregas
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0009 ; //--"Entregas"
	DESCR STR0010 ; //--"Status dos documentos de Entrega"
	TYPE 1 ; //--Modelo do Painel
	PARAMETERS "TMSP050" ; //--Grupo de Perguntas
	ONLOAD "TMSP050" ; //--Funcao para montagem do Painel
	REFRESH 300 ; //--Tempo para Refresh do Painel em segundos
	NAME "5" //--Ordem de Exibicao    */      
	
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0011; //"Faturamento X Regiao"
	DESCR STR0012 ; //"Valor de Faturamento X Regiao"
	TYPE 2 ; //-- Tipo do Painel
	PARAMETERS "TMSP060" ; //--Grupo de Perguntas
	ONLOAD "TMSP060" ; //--Funcao para montagem do Painel
	REFRESH 300 ; //--Tempo para Refresh do Painel em segundos
	DEFAULT 1	 ; //-- Default do Combo
	TITLECOMBO STR0006 ; //"Análise por: " - Configura o Label do ComboBox
	NAME "6" //--Ordem de Exibicao
	
Return