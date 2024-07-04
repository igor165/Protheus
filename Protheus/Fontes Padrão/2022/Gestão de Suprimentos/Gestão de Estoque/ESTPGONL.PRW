#INCLUDE "ESTPGONL.ch"
#include "protheus.ch"
#Include "PanelOnLine.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ESTPGOnl ³ Autor ³ Nereu Humberto Junior ³ Data ³ 24/01/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Painel de Gestao On-line (EST)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ESTPGOnl(ExpO1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = obj do proces.                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                              		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEST                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ESTPGOnl(oPGOnline)
Local cDias

ESTPG05Init()
cDias:= Alltrim(cvaltochar(mv_par03))

PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0002 ; //'Valor em Estoque'
	DESCR STR0002 ; //'Valor em Estoque'
	TYPE 2 ;
	PARAMETERS 'ESTPGONL02' ;
	ONLOAD 'ESTPgOn02' ;
	REFRESH 1200 ;
	DEFAULT 1 ;	
	NAME '2' ;
	TITLECOMBO STR0003	;	 //"Moeda"
	PYME 

PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0004 ; //'Quantidade em Estoque'
	DESCR STR0004 ; //'Quantidade em Estoque'
	TYPE 2 ;
	PARAMETERS 'ESTPGONL03' ;
	ONLOAD 'ESTPgOn03' ;
	REFRESH 1200 ;
	DEFAULT 1 ;	
	NAME '3' ;
	TITLECOMBO STR0005	;	 //"Saldos"
	PYME 
	
PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0006 ; //'Lotes Vencidos'
	DESCR STR0006 ; //'Lotes Vencidos'
	TYPE 5 ;
	PARAMETERS 'ESTPGONL04' ;
	ONLOAD 'ESTPgOn04' ;
	REFRESH 100 ;
	NAME '4' ;


PANELONLINE oPGOnline ADDPANEL ;
	TITLE STR0007 ; //'Lotes a Vencer em ... dias'
	DESCR STR0008+cDias+STR0009 ; //'Lotes a Vencer em ... dias'
	TYPE 5 ;
	PARAMETERS 'ESTPGONL05' ;
	ONLOAD 'ESTPgOn05' ;
	REFRESH 100 ;
	NAME '5' ;

Return


/*/{Protheus.doc} ESTPG05Init
Inicializa mv_par03 do pergunte ESTPGONL05 da rotina ESTPGOnl
@type function
@version P12 
@author thiago.fonseca
@since 20/04/2022
/*/
Static Function ESTPG05Init() 
Local nCont
Local nTamPerg
Local oSX1 

oSX1 := FwSx1Util():New()
oSX1:AddGroup("ESTPGONL05")
oSX1:SearchGroup()

nTamPerg := Len(oSX1:aGrupo[1, 2])
Pergunte("ESTPGONL05",.F.)

For nCont := 1 TO nTamPerg
	If UPPER(ALLTRIM(oSX1:aGrupo[1, 2, nCont]:CX1_VAR01)) == UPPER("mv_par03")
		mv_par03 := IIf(Empty(mv_par03), 30, mv_par03)
	EndIf
Next nCont

Return
