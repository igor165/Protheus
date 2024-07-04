#INCLUDE "ctbr517.ch"
#Include "Protheus.ch"

// 17/08/2009 -- Filial com mais de 2 caracteres
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CTBR517      ³Autor ³  Paulo Augusto       ³Data³ 22/01/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Este relatorio imprime a declaracao DEMONSTRATIVO DE       ³±±
±±³          ³DETERMINACAO DO IMPOSTO AO ATIVO                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³Data    ³ BOPS     ³ Motivo da Alteracao                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jonathan Glz³26/06/15³PCREQ-4256³Se elimina la funcion fCriaSx1() la   ³±±
±±³            ³        ³          ³cual realiza modificacion a SX1 por   ³±±
±±³            ³        ³          ³motivo de adecuacion a fuentes a nueva³±±
±±³            ³        ³          ³estructura de SX para Version 12.     ³±±
±±³Jonathan Glz³09/10/15³PCREQ-4261³Merge v12.1.8                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTBR517()
Local  nomeprog:="CTBR517"
Local cPerg:= "CTR517"
Local ApERG:={}
Local aArea:={}
Local dDataFim:=dDatabase

Pergunte( CPERG, .T. )
AaDD(aPerg,MV_PAR01)
AaDD(aPerg,MV_PAR02)
AaDD(aPerg,MV_PAR03)
AaDD(aPerg,MV_PAR04)
AaDD(aPerg,MV_PAR05)
AaDD(aPerg,MV_PAR06)
cTitulo:=OemToAnsi(STR0001) //"DEMONSTRATIVO DE DETERMINACAO DO IMPOSTO AO ATIVO"
cDesc:=	OemToAnsi(STR0002) +; //"Este programa irá imprimir o Demonstrativo"
			 	OemToAnsi(STR0003) //"de determinacao do Imposto ao Ativo"

aArea:=GetArea()
dbSelectArea("CTG")
dbSetOrder(1)
CTG->(DbSeek(xFilial() + mv_par01))
While CTG->CTG_FILIAL = xFilial("CTG") .And. CTG->CTG_CALEND = mv_par01
	dDataFim	:= CTG->CTG_DTFIM
	CTG->(DbSkip())
EndDo
RestArea(aArea)

aDescCab:={} 
Aadd(aDescCab,".          " + STR0004 + "       ." ) //"DETERMINACAO DO IMPOSTO AO ATIVO"
Aadd(aDescCab,	".          " + STR0005 + Alltrim(Str(year(dDataFim))) + "       ." ) //"EXERCICIO "

CtbR511(.T.,aPerg,"CTBR517",cTitulo,cDesc,nomeprog,cPerg,aDescCab)  
Return()                         
