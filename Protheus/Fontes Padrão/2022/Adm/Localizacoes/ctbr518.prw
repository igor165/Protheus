#INCLUDE "ctbr518.ch"
#Include "Protheus.ch"


// 17/08/2009 -- Filial com mais de 2 caracteres
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CTBR518      ³Autor ³  Paulo Augusto       ³Data³ 22/01/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Este relatorio imprime a declaracao de pagtos provisorios  ³±±
±±³          ³ do IMPAC                                                   ³±±
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

Function CTBR518()
Local  nomeprog:="CTBR518"
Local cPerg:= "CTR518"
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

cTitulo:=OemToAnsi(STR0001) //"DEMONSTRATIVO DE CALCULO PROVISORIO  DE IMPAC"
cDesc:=	OemToAnsi(STR0002) +; //"Este programa irá imprimir o Demonstrativo"
			 	OemToAnsi(STR0003) //"de Calculo de Pagamentos Provisorios do IMPAC"

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
Aadd(aDescCab,".          " + STR0004 ) //"CALCULO DE PAGAMENTOS PROVISORIOS DO IMPAC      ."
Aadd(aDescCab,	".          " + STR0005 + Alltrim(Str(year(dDataFim))) +" / "+ "FATOR DE ACTUALIZACION: " +Alltrim(STR(MV_PAR06))+ "       ." ) //"EXERCICIO "

                                    
CtbR511(.T.,aPerg,"CTBR518",cTitulo,cDesc,nomeprog,cPerg,aDescCab)  
Return()                         

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CTR518V      ³Autor ³  Paulo Augusto       ³Data³ 22/01/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualizacao da pergunta 06 ref. a taxa do periodo contabil ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function CTR518V()
Local nTaxaCor:=0 
Local nTaxaAtu:=0
Local nTaxaAnt:=0
Local cMesAtu:= ""
Local cAnoAtu:= ""
Local cMesIn:= ""
Local cAnoIn:= ""
Local aArea:=Getarea() 
Local dDataFim:=dDataBase 


dbSelectArea("CTG")
dbSetOrder(1)
CTG->(DbSeek(xFilial() + mv_par01))
dIni:=CTG->CTG_DTINI
While CTG->CTG_FILIAL = xFilial("CTG") .And. CTG->CTG_CALEND = mv_par01
	dDataFim	:= CTG->CTG_DTFIM
	CTG->(DbSkip())
EndDo
If Month(dIni) ==1               
	cMesIn:= StrZero(12,2,0)
	cAnoIn:= Str(Year(dIni)-1,4,0) 
Else
	cMesIn:= StrZero(Month(dIni)-1,2,0)
	cAnoIn:= Str(Year(dIni),4,0) 
EndIf	
cMesAtu:= StrZero(Month(dDataFim),2,0) 
cAnoAtu:= Str(Year(dDataFim),4,0) 

DbSelectArea("SIE")   

If DbSeek( xFilial("SIE")+cAnoAtu +cMesAtu) 
	nTaxaAtu:=SIE->IE_INDICE
EndIf
If DbSeek( xFilial("SIE")+cAnoIn +cMesIn)
	nTaxaAnt:=SIE->IE_INDICE
EndIf
nTaxaCor:= NoRound(nTaxaAtu /  nTaxaAnt,4)

MV_PAR06:=nTaxaCor
      
RestArea(aArea)
