#include "PanelOnLine.Ch"
#include "Protheus.Ch"
#include "Atfxpgl.Ch"

// 17/08/2009 - Ajuste para filiais com mais de 2 caracteres.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ATFPGOnl  ³ Autor ³ Claudio Donizete Souza³ Data ³ 27/12/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Definicao dos paineis on-line para modulo Ativo Fixo 		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ AtfPgOnl  										   	  			     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGAATF  			   												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ATFPGOnl(oPGOnline)
Local cMoeda  := AllTrim(GetMv("MV_ATFMOED"))
Local cDescMoeda := AllTrim(GETMV("MV_SIMB" + cMoeda))
Local aToolBar := {}

aToolBar := {}

Aadd( aToolBar, { { "S4WB016N","Help","{ || MsgInfo('"+STR0010+"') }" } } ) // "Este painel mostra o valor e a quantidade de bens que foram incluidos pela integração Compras x Ativo e ainda não foram classificados e portanto ainda não estão gerando depreciação. Bens não classificados são aqueles que estão com a conta contábil do bem (N3_CCONTAB) em branco."
Aadd( aToolBar, { { "S4WB016N","Help","{ || MsgInfo('"+STR0011+"') }" } } ) // "Este painel mostra o valor e a quantidade de bens que estão próximos do final da depreciação. Apenas o bens em o quociente da depreciação acumulada pelo valor original do bem seja maior que o percentual definido pelo usuário"
Aadd( aToolBar, { { "S4WB016N","Help","{ || MsgInfo('"+STR0012+"') }" } } ) // "Este painel mostra a data em que foi efetuado o últomo cálculo de depreciação no sistema"
Aadd( aToolBar, { { "S4WB016N","Help","{ || MsgInfo('"+STR0013+"') }" } } ) // "Este painel mostra o prazo médio ponderado (em dias) em que o bem leva para ser classificado. A ponderação é efetuada sobre o valor do bem, ou seja, (Soma((data de classificação - Data de aquisição) * valor original))/Soma(valor original)"
Aadd( aToolBar, { { "S4WB016N","Help","{ || MsgInfo('"+STR0014+"') }" } } ) // "Este painel mostra todos os bens que possuam grupo (N1_GRUPO) preenchido e exibe em ordem decrescente de valor "
Aadd( aToolBar, { { "S4WB016N","Help",'{ || MsgInfo("'+STR0015+'") }' } } ) // "Este painel mostra a soma dos bens adquiridos nos últimos N meses, ou seja, todos os movimentos de aquisição (N4_OCORR='05'), agrupados por mês, conforme a quantidade de meses definida pelo usuário"
Aadd( aToolBar, { { "S4WB016N","Help",'{ || MsgInfo("'+STR0016+'") }' } } ) // "Este painel mostra a soma dos bens adquiridos nos últimos N meses, ou seja, todos os movimentos de aquisição (N4_OCORR='05'), agrupados por grupo de bem, conforme a quantidade de meses definida pelo usuário"

PANELONLINE oPgOnLine ;
	ADDPANEL TITLE STR0001; // "Bens não classificados"
	DESCR STR0002 ; // "Bens não classificados por filial"
	TYPE 2;
 	ONLOAD "AtfLOnl01";
	REFRESH 5;
	DEFAULT 1;
	NAME	"AtfLOnl01";
	TOOLBAR aToolBar[1];
	TITLECOMBO STR0003 ;
	PYME
	 
PANELONLINE oPgOnLine ;
	ADDPANEL TITLE STR0004; // "Bens próximos do final da depreciação - por filial"
	DESCR STR0004; // "Bens próximos do final da depreciação - por filial"
	TYPE 1;
 	ONLOAD "AtfLOnl02";
	REFRESH 5;
	NAME	"AtfLOnl02";
	PARAMETERS "ATFPGL01";
	TOOLBAR aToolBar[2];
	PYME

PANELONLINE oPgOnLine ;
	ADDPANEL TITLE STR0005; // "Data da última depreciação"
	DESCR STR0005; // "Data da última depreciação"
	TYPE 1;
 	ONLOAD "AtfLOnl03";
	REFRESH 5;
	NAME	"AtfLOnl03";
	TOOLBAR aToolBar[3];	 	 

PANELONLINE oPgOnLine ;
	ADDPANEL TITLE STR0006; //"Tempo médio de classificação - por filial";
	DESCR STR0006; //  "Tempo médio de classificação - por filial"
	TYPE 2;
 	ONLOAD "AtfLOnl04";
	REFRESH 5;
	DEFAULT 1;
	NAME	"AtfLOnl04";
	TOOLBAR aToolBar[4];	 	 
	TITLECOMBO STR0003;  // "Filial " 
 	PYME
 
PANELONLINE oPgOnLine ;
	ADDPANEL TITLE STR0007; // "Bens por grupo de maior valor - por filial"
	DESCR STR0007; // "Bens por grupo de maior valor - por filial"
	TYPE 2;
 	ONLOAD "AtfLOnl05";
	REFRESH 5;
	DEFAULT 1;
	NAME	"AtfLOnl05";
 	PARAMETERS "ATFPGL02";
	TOOLBAR aToolBar[5];
	TITLECOMBO STR0003; // "Filial " 
	PYME
 
PANELONLINE oPgOnLine ;
	ADDPANEL TITLE STR0008; // "Valor dos bens adquiridos nos ultimos meses"
	DESCR STR0009 +  cDescMoeda; // "Valor dos bens adquiridos nos ultimos meses - em "
	TYPE 1;
 	ONLOAD "AtfLOnl06";
	REFRESH 5;
	DEFAULT 1;
	NAME	"AtfLOnl06";
	TOOLBAR aToolBar[6];
	PARAMETERS "ATFPGL03"   ;
	PYME

PANELONLINE oPgOnLine ;
	ADDPANEL TITLE STR0017; // "Aquisições por grupo, nos ultimos meses"
	DESCR STR0017;  // "Aquisições por grupo, nos ultimos meses"
	TYPE 2;
 	ONLOAD "AtfLOnl07";
	REFRESH 5;
	DEFAULT 1;
	NAME	"AtfLOnl07";
	PARAMETERS "ATFPGL04"; 
	TOOLBAR aToolBar[7]; 
	TITLECOMBO STR0018 ;
	PYME
	 
Return
