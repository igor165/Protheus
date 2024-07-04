#include "pmsxpgl.ch"
#include "PanelOnLine.ch"
#include "Protheus.Ch"
#include "pmsicons.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³PMSPGOnl  ³ Autor ³ Ana Paula N. Silva    ³ Data ³ 15/02/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Definição dos paineis de gestão PMS                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ PMSPgOnl                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAPMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSPGOnl(oPGOnline)

PANELONLINE oPgOnLine ADDPANEL;
	TITLE STR0001; //"Recursos maior aloc. mes"
	DESCR STR0001; //"Recursos maior aloc. mes"
	TYPE 1;    
	PARAMETERS 'PMSOL1';
 	ONLOAD "PMSLOnl01";
	REFRESH 300;
	TOOLBAR {{BMP_INTERROGACAO,"Help","{ || MsgInfo('"+STR0008+"') }"}}; //"Lista a qtde. de apontamentos dos recursos(código e descrição) por ordem decrescente de apontamento."
	NAME "PmsLOnl01"

PANELONLINE oPgOnLine ADDPANEL;
	TITLE STR0002; //"Projetos com data de entrega proxima"
	DESCR STR0002; //"Projetos com data de entrega proxima"
	TYPE 1;    
	PARAMETERS 'PMSOL2';
 	ONLOAD "PMSLOnl02";
	REFRESH 300;
	TOOLBAR {{BMP_INTERROGACAO,"Help","{ || MsgInfo('"+STR0009+"') }"}}; //"Lista os projetos em aberto com a data prevista de término próxima."
	NAME "PMSLOnl02"
               
PANELONLINE oPgOnLine ADDPANEL;
	TITLE STR0003; //"Projetos com data de inicio proxima"
	DESCR STR0003; //"Projetos com data de inicio proxima"
	TYPE 1;    
	PARAMETERS 'PMSOL03';
 	ONLOAD "PMSLOnl03";
	REFRESH 300;
	TOOLBAR {{BMP_INTERROGACAO,"Help","{ || MsgInfo('"+STR0010+"') }"}}; //"Lista os projetos em aberto com a data prevista de início próxima."
	NAME "PMSLOnl03"

PANELONLINE oPgOnLine ADDPANEL;
	TITLE STR0004; //"Maiores Consumos por Produto"
	DESCR STR0004; //"Maiores Consumos por Produto"
	TYPE 2;
	PARAMETERS "PMSOL04";
 	ONLOAD "PMSLOnl04";
	REFRESH 300;
	DEFAULT 1;
	TOOLBAR {{BMP_INTERROGACAO,"Help","{ || MsgInfo('"+STR0011+"') }"}}; //"Lista os projetos e as maiores quantidades consumidas por produto."
	NAME "PMSLOnl04";
	TITLECOMBO STR0005 //"Produto"

PANELONLINE oPgOnLine ADDPANEL;
	TITLE STR0006; //"Recursos com mais Horas Previstas no Período"
	DESCR STR0006; //"Recursos com mais Horas Previstas no Período"
	TYPE 1;    
	PARAMETERS "PMSOL05";
 	ONLOAD "PMSLOnl05";
	REFRESH 300;
	TOOLBAR {{BMP_INTERROGACAO,"Help","{ || MsgInfo('"+STR0012+"') }"}}; //"Lista os recursos e a quantidade de horas que estão alocados dentro do período em ordem decrescente."
	NAME "PMSLOnl05"

PANELONLINE oPgOnLine ADDPANEL;
	TITLE STR0007; //"Equipes com mais Horas Alocadas no Período"
	DESCR STR0007; //"Equipes com mais Horas Alocadas no Período"
	TYPE 1;
	PARAMETERS "PMSOL06";
 	ONLOAD "PMSLOnl06";
	REFRESH 300;
	TOOLBAR {{BMP_INTERROGACAO,"Help","{ || MsgInfo('"+STR0013+"') }"}}; //"Lista as equipes e a quantidade de horas que estão alocadas dentro do período em ordem decrescente."
	NAME "PMSLOnl06"

Return

