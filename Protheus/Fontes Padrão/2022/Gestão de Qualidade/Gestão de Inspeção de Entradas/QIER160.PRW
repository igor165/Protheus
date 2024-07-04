#INCLUDE "QIER160.CH"
#INCLUDE "PROTHEUS.CH" 
#INCLUDE "REPORT.CH"


#DEFINE TAMANHO_ATUAL 1
#DEFINE TAMANHO_MIN   3
#DEFINE TAMANHO_MAX   4


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³QIER160   ºAutor  ³Telso Carneiro      º Data ³  08/06/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Relatorio Listagem dos Indices Mensais                     º±±
±±º          ³ (Versao Relatorio Personalizavel)                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function QIER160()
Local oReport	

Pergunte("QER160",.F.)
oReport := ReportDef()
oReport:PrintDialog()

Return

Static Function ReportDef()
Local wnrel 	:= "QIER160"
Local cDesc1	:= OemToAnsi(STR0001)	//"Serao relacionados os Indices Mensais"
Local cTitulo	:= OemToAnsi(STR0002) 	//"Indices Mensais"
Local cPerg	  	:= "QER160"
Local oReport
Local oSection1 
Local oSection2 
Local nLargInd	:= TamSX3("QE0_INDICE")[1]+TamSX3("QF1_DESCRI")[1]+1
Local nLargFor	:= TamSX3("QE0_FORNEC")[1]+TamSX3("A2_NOME")[1]+1
Local nLargPro	:= TamSX3("QE0_PRODUT")[1]+TamSX3("QE6_DESCPO")[1]+1

DEFINE REPORT oReport NAME wnrel TITLE cTitulo PARAMETER cPerg ACTION {|oReport| PrintReport(oReport)} DESCRIPTION (cDesc1)

DEFINE SECTION oSection1 OF oReport TITLE STR0007 TABLES "QE0","QF1" //"Indices"
DEFINE CELL NAME "QE0_INDICE" OF oSection1 ALIAS "QE0" SIZE nLargInd BLOCK {|| QE0_INDICE+"-"+POSICIONE("QF1",1,xFilial("QF1")+QE0_INDICE,"QF1_DESCRI") }

DEFINE SECTION oSection2 OF oSection1 TITLE STR0008 TABLES "QE0","SA2","QE6" //"Valores"
DEFINE CELL NAME "QE0_ANO"    OF oSection2 ALIAS "QE0"
DEFINE CELL NAME "QE0_MES"    OF oSection2 ALIAS "QE0"
DEFINE CELL NAME "QE0_FORNEC" OF oSection2 ALIAS "QE0" SIZE nLargFor BLOCK {|| QE0_FORNEC+"-"+POSICIONE("SA2",1,xFilial("SA2")+QE0_FORNEC,"A2_NOME") }
DEFINE CELL NAME "QE0_PRODUT" OF oSection2 ALIAS "QE0" SIZE nLargPro BLOCK {|| QE0_PRODUT+"-"+POSICIONE("QE6",1,xFilial("QE6")+QE0_PRODUT,"QE6_DESCPO") }
DEFINE CELL NAME "QE0_VALOR"  OF oSection2 ALIAS "QE0"
 
Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PrintReporºAutor  ³Telso Carneiro      º Data ³  08/06/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Relatorio Personalizavel                                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³QIER160()                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
                  
Static Function PrintRepor(oReport) 
Local cFiltro   := ""
Local cAliasQE0	:= "QE0"
Local oSection2 := oReport:Section(1):Section(1)  

MakeSqlExpr(oReport:uParam)
oReport:Section(1):BeginQuery()
cAliasQE0 := GetNextAlias()
	
BeginSql Alias cAliasQE0
	SELECT * FROM %table:QE0% QE0
	WHERE QE0_FILIAL = %xFilial:QE0% AND
	QE0_ANO BETWEEN %Exp:Str(mv_par01,4)% AND %Exp:Str(mv_par02,4)% AND
	QE0_MES BETWEEN %Exp:StrZero(mv_par03,2)% AND %Exp:StrZero(mv_par04,2)% AND
	QE0_FORNEC BETWEEN %Exp:mv_par05% AND %Exp:mv_par06% AND
	QE0_PRODUT BETWEEN %Exp:mv_par07% AND %Exp:mv_par08% AND
	QE0.%notDel%

	ORDER BY QE0_FILIAL,QE0_INDICE,QE0_ANO,QE0_MES
			
EndSql
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Metodo EndQuery ( Classe TRSection )                                    ³
//³Prepara o relatório para executar o Embedded SQL.                       ³
//³ExpA1 : Array com os parametros do tipo Range                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)
  
TRPosition():New(oReport:Section(1),"QF1",1,{|| xFilial("QF1")+(cAliasQE0)->QE0_INDICE })
TRPosition():New(oReport:Section(1):Section(1),"SA2",1,{|| xFilial("SA2")+(cAliasQE0)->QE0_FORNEC})
TRPosition():New(oReport:Section(1):Section(1),"QE6",1,{|| xFilial("QE6")+(cAliasQE0)->QE0_PRODUT})

oSection2:SetParentQuery()
oSection2:SetParentFilter( { |cParam| (cAliasQE0)->QE0_INDICE == cParam },{ || (cAliasQE0)->QE0_INDICE })

oReport:Section(1):Print()

Return NIL

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ R160CkMes  ³ Autor ³ Marcelo Pimentel      ³ Data ³ 27/05/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica o mes                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ X1_VALID                        	 						    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function R160CkMes(nParam)
Local lRet := .F.,cCpo :=""

If naovazio()
	cCpo := "mv_par"+StrZero(nParam,2)
	cCpo := &cCpo
	If cCpo > 0 .And. cCpo <=12
		lRet := .T.
	EndIf
EndIf

Return(lRet)
