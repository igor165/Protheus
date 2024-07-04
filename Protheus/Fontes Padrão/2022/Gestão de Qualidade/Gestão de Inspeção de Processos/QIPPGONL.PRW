#Include "PanelOnLine.ch"
#include "QIPPGOnl.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ QIPPGOnl ³ Autor ³ Rafael S. Bernardi    ³ Data ³17/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Painel de Gestao On-line - Modulo SIGAQIP                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ QIPPGOnl(ExpO1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = obj do proces.                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAQIP                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function QIPPGOnl(oPGOnline)
Local aToolBar  := {} 
Local aToolBar2 := {}
Local cHelp     := ""
Local cHelp2    := ""

         
cHelp := STR0005//"O sistema ira listar a(s) ordem(s) de producao e seu status em relacao "
cHelp += STR0006//"ao resultado (Inspecionada / A Inspecionar)."

aToolBar:= {}
Aadd( aToolBar, { "S4WB016N","Help",&('{ || MsgInfo(Lower("'+cHelp+'")) }') } )

//--Painel 1 - Ordens de produção inspecionadas / a inspecionar
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0001 ; //"Ordens de produção inspecionadas / a inspecionar" - Esta descricao aparece na lista de paineis disponiveis, superior esquerdo
	DESCR STR0001 ; //"Ordens de produção inspecionadas / a inspecionar" - Descricao na Barra Superior
	TYPE 5 ; //-- Tipo do Painel
	PARAMETERS "QIPP10" ; //--Grupo de Perguntas
	ONLOAD "QIPP010" ; //--Funcao para montagem do Painel
	REFRESH 600 ; //--Tempo para Refresh do Painel em segundos
	TOOLBAR aToolBar ;//--Help que sera apresentado ao usuário sobre o resultado do painel
	DEFAULT 5	 ; //-- Default do Combo
	NAME "1" //--Ordem de Exibicao
	
cHelp2 := STR0007//"O sistema ira apresentar uma lista no estilo de ranking com duas dimesoes: "
cHelp2 += STR0008//"1ª = quantidade de nao-conformidades por classe / "
cHelp2 += STR0009//"2ª = quantidade de nao-conformidades por produto"

aToolBar2:= {}
Aadd( aToolBar2, { "S4WB016N","Help",&('{ || MsgInfo(Lower("'+cHelp2+'")) }') } )
	
PANELONLINE oPGOnline ADDPANEL;
	TITLE STR0002; // "Não-Conformidades X Produtos"  	
	DESCR STR0002+" - "+STR0003; 	// "Não-Conformidades X Produtos"###"Inspeção de Processos"
	TYPE 2;  
	PARAMETERS "QIP020";
	ONLOAD "QIPP020"; 		
	REFRESH 600;
	TOOLBAR aToolBar2 ;//--Help que sera apresentado ao usuário sobre o resultado do painel
	DEFAULT 1; 			
	TITLECOMBO STR0004; 			//"Analisar : "
	NAME "2"
	
Return