#INCLUDE "HSPAHR65.ch"
#Include "protheus.ch"
#include "TopConn.ch"
#include "Report.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHR65  บ Autor ณ ANTONIO CARLOS     บ Data ณ  05/09/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio da Tabela de Procedimentos                       บฑฑ 
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบObs:      ณ Convertido para relatorios personalizaveis                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HSPAHR65()
 Local oReport
 If FindFunction("TRepInUse") .And. TRepInUse() 
 	pergunte("HSPR65",.F.)
  oReport := ReportDef() 
  oReport:PrintDialog()  
 ELSE  
  HSPAHR65R3()  
 EndIF
Return( Nil )     


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒ
ฒฒฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฒฒ
ฒฒณFuno    ณREPORTDEF ณ Autor ณ Antonio Carlos        ณ Data ณ 05/09/06 ณฒฒ
ฒฒภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฒฒ
ฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function ReportDef()
 Local oReport 
 Local oSection1, oSection2, oSection3, oSection4
 Local oCell
 Local oTotaliz1, oTotaliz2

 oReport := TReport():New("HSPAHR65",STR0003,"HSPR65",{|oReport| R65IMP(oReport)}, STR0001 + " " + STR0002 + " " + STR0003)
 //"Tabela de Procedimentos"
 //###"Este programa tem como objetivo imprimir relatorio"###"de acordo com os parametros informados pelo usuario."###"Tabela de Procedimentos"

//oReport:SetLandscape()         // Imprimir relatorio em formato paisagem
 oReport:SetPortrait()          // Imprimir relatorio em formato retrato

 oSection1 := TRSection():New(oReport,STR0016,{"GDB"}) //"Tabela"
 oSection1:SetHeaderBreak(.F.)
 oSection1:SetPageBreak(.T.)
 oCell := TRCell():New(oSection1,"GDB_CHAVE","GDB",STR0013)  //"Tabela...:"     
 oCell := TRCell():New(oSection1,"GDB_DESCRI","GD2",)     
 
 oSection2 := TRSection():New(oSection1,STR0008,{"GAW"}) //"Grupo de Procedimento"
 oSection2:SetHeaderBreak(.F.)
 oSection2:SetPageBreak(.F.)
 oSection2:SetHeaderPage(.T.)
 oCell := TRCell():New(oSection2,"GAW_CODGDE","GAW",STR0008,)   //"Grupo de Procedimento"
 oCell := TRCell():New(oSection2,"GAW_DESC"  ,"GAW","")

 oSection3 := TRSection():New(oSection2,STR0017,{"GD3","GAA"}) //"Procedimento"
 oSection3:SetHeaderBreak(.T.)    //Define se cabecalho das celulas sera impresso apos quebra TRBreak.
 oSection3:SetPageBreak(.F.)
 oSection3:SetHeaderSection(.T.)  //Define se cabecalho da celula sera impresso na quebra da secao.
 oSection3:SetHeaderPage(.T.)
 oCell := TRCell():New(oSection3,"GA8_CODPRO","GA8",)     
 oCell := TRCell():New(oSection3,"GA7_DESC","GA7","")     
 oCell := TRCell():New(oSection3,"GA8_CODPRT","GA8",STR0018)      //"C๓d. Conv๋nio"
 oCell := TRCell():New(oSection3,"GA8_DATVIG","GA8",)     
 oCell := TRCell():New(oSection3,"GA8_VLRPRO","GA8",)     
 oCell := TRCell():New(oSection3,"GA8_VLRCOS","GA8",)     
 oCell := TRCell():New(oSection3,"GA8_METFIL","GA8",)     
 oCell := TRCell():New(oSection3,"GA8_CODPAN","GA8",)     
 oCell := TRCell():New(oSection3,"GA8_QTDAUX","GA8",)     

 oSection1:SetTotalInLine(.F.)
 oSection2:SetTotalInLine(.F.)
 oSection3:SetTotalInLine(.F.)

 DEFINE FUNCTION FROM oSection3:Cell("GA8_QTDAUX") OF oSection1 FUNCTION COUNT TITLE STR0011 NO END REPORT   //"Total de Itens da Tabela"
 oTotaliz1 := TRFunction():new(oSection3:Cell("GA8_QTDAUX"),,"COUNT",,STR0010,,,.T.,.F.,.F.)  //"Total de Itens do Grupo"
 oTotaliz2 := TRFunction():new(oSection3:Cell("GA8_QTDAUX"),,"COUNT",,STR0019,,,.F.,.T.,.F.) //"Total Geral de itens"

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ TRFunction:  Classe que instancia totalizadores de quebra, secoes ou relatorios.                                                                        ณ
 //ณ Parametros para o construtor inicializar as variaveis de instancia :                                                                                    ณ
 //ณ (oSec:Cell("campo"),/*cVarTemp*/,/*FUNCAO*/,/*oBreak*/,/*cTit*/,/*cPict*/,/*uForm*/,.F./*lEndSect*/,.F./*lEndRep*/,.F./*lEndPage*/,oSection,condition)  ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

//-- Secao para Planos que utilizam a tabela em questao
oSection4:= TRSection():New(oReport,STR0012,{"GC6","GCM"},,,)   //"PLANOS QUE UTILIZAM A TABELA"
oSection4:SetHeaderSection()
oCell := TRCell():New(oSection4,"GDB_CHAVE","GDB",STR0013)   //"Tabela....: "     
oCell := TRCell():New(oSection4,"GC6_TABPRO","GC6",)     
oCell := TRCell():New(oSection4,"GCM_DESPLA","GCM",)

Return( oReport )


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒ
ฒฒฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฒฒ
ฒฒณFuno    ณ R65Imp   ณ Autor ณ Antonio Carlos        ณ Data ณ 05/09/06 ณฒฒ
ฒฒภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฒฒ
ฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function R65IMP(oReport)

 Local oSection1 := oReport:Section(1)
 Local oSection2 := oReport:Section(1):Section(1)
 Local oSection3 := oReport:Section(1):Section(1):Section(1)
 Local oSection4 := oReport:Section(2)
 Local cCond := ""

 //-- Transforma parametros Range em expressao SQL
MakeSqlExpr(oReport:uParam)                      
 
/*If MV_PAR05 == 1
 cCond := "%GD2.GD2_TABATV = '1'%"
ElseIf MV_PAR05 == 2
 cCond := "%GD2.GD2_TABATV = '0'%"
Else
 //cCond := "%GD2.GD2_TABATV <> '" + STR(Len(MV_PAR05)) + "'%" 
 cCond := "%GD2.GD2_TABATV <> '" + ALLTRIM(STR(MV_PAR05)) + "'%"
Endif */

If MV_PAR06 == 1
 cCond := "%GDB_DESCRI, GAW_DESC, GA7_DESC%"
Else
 cCond := "%GDB_DESCRI, GAW_DESC, GA8_CODPRO%"
EndIf 

oSection1:BeginQuery()
BeginSql alias "QRYR65"
 SELECT DISTINCT GDB_CHAVE, GDB_DESCRI, GAW_CODGDE, GAW_DESC, GA8_CODPRO, GA7_DESC, GA8_CODPRT, GA8_DATVIG,
                 GA8_VLRPRO,GA8_VLRCOS, GA8_METFIL, GA8_CODPAN, GA8_QTDAUX 
 FROM %table:GDB% GDB 
 JOIN %table:GA8% GA8 ON GA8.GA8_TABPRO = GDB.GDB_CHAVE  AND GA8.GA8_FILIAL = %xFilial:GA8% AND GA8.%NotDel%
 JOIN %table:GA7% GA7 ON GA7.GA7_CODPRO = GA8.GA8_CODPRO AND GA7.GA7_FILIAL = %xFilial:GA7% AND GA7.%NotDel%
 JOIN %table:GAW% GAW ON GAW.GAW_CODGDE = GA7.GA7_CODGDE AND GAW.GAW_FILIAL = %xFilial:GAW% AND GAW.%NotDel%
 WHERE GDB.GDB_FILIAL = %xFilial:GDB% AND GDB.%NotDel%
   AND GAW.GAW_FILIAL = %xFilial:GAW% AND GAW.%NotDel%
   AND GDB.GDB_CHAVE  BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
   AND GA7.GA7_CODGDE BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
   AND GA8.GA8_DATVIG = ( SELECT MAX(GA81.GA8_DATVIG)
 FROM %table:GDB% GDB   
 JOIN %table:GA8% GA81 ON GA81.GA8_TABPRO = GDB.GDB_CHAVE  AND GA81.GA8_FILIAL = %xFilial:GA8% AND GA81.%NotDel%
 WHERE GDB.GDB_FILIAL = %xFilial:GDB% AND GDB.%NotDel%
 AND GA81.GA8_TABPRO = GA8.GA8_TABPRO  
 AND GA81.GA8_CODPRO = GA8.GA8_CODPRO ) 
 ORDER by %Exp:cCond%
EndSql

oSection1:EndQuery()
oSection2:SetParentQuery()
oSection2:SetParentFilter( {|G|("QRYR65")->GDB_CHAVE == G}, {||("QRYR65")->GDB_CHAVE}) // Quebra por Tabela
oSection3:SetParentQuery()
oSection3:SetParentFilter( {|G|("QRYR65")->GAW_CODGDE + ("QRYR65")->GDB_CHAVE == G }, {|| ("QRYR65")->GAW_CODGDE + ("QRYR65")->GDB_CHAVE } ) // Quebra por Grupo de Procedimento
oSection1:Print() // processa as informacoes da tabela principal
                
oSection4:BeginQuery()
BeginSql alias "QRYR65A"
 SELECT  /*DISTINCT*/ GC6.GC6_TABPRO, GCM.GCM_DESPLA
 FROM %table:GC6% GC6 
 JOIN %table:GCM% GCM ON GCM.GCM_CODPLA = GC6.GC6_CODPLA
 WHERE GC6.GC6_FILIAL = %xFilial:GC6% AND GC6.%NotDel%
 AND GCM.GCM_FILIAL = %xFilial:GCM% AND GCM.%NotDel%
 AND GC6.GC6_TABPRO BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
 Order By GC6_TABPRO
EndSql

oSection4:EndQuery()
oSection4:SetParentFilter({|G|("QRYR65A")->GCM_DESPLA == G}, {||("QRYR65A")->GCM_DESPLA}) //Quebra por Tabela
oReport:SkipLine(2)
oReport:PrintText(STR0012,,10)  //"PLANOS QUE UTILIZAM A TABELA"
oSection4:Print()
oReport:SetMeter(QRYR65->(LastRec()))
	
Return( NIL )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHR65R3บ Autor ณ Daniel Peixoto     บ Data ณ  16/06/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Tabelas de Procedimentos                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HSPAHR65R3()


/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 ณ Declaracao de Variaveis                                             ณ
 ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3         := ""
Local cPict          := ""
Local titulo         := STR0003 //"Tabela de Procedimentos"
Local nLin           := 80 

Local Cabec1         := ""
Local Cabec2         := ""
Local imprime        := .T.
Local aOrd 				   := {}    

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 80
Private tamanho      := "M"
Private nomeprog     := "HSPAHR65" /* Coloque aqui o nome do programa para impressao no cabecalho */
Private nTipo        := 18
Private aReturn      := { STR0004, 1, STR0005, 2, 2, 1, "", 1}    //"Zebrado"###"Administracao"
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "HSPAHR65" /* Coloque aqui o nome do arquivo usado para impressao em disco */
Private cPerg        := "HSPR65"
Private cString  := ""

 Private cCODIMP := ""
 Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao

/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 ณ PARAMETROS                                                                 ณ
 ณ MV_PAR01	- Da Tabela                                                       ณ
 ณ MV_PAR02	- Ate Tabela                                                      ณ
 ณ MV_PAR03	- Do Grp proced.                                                  ณ
 ณ MV_PAR04	- Ate Grp proced.                                                 ณ
 ณ MV_PAR05	- Ativa      0=Sim 1=nao  2=Ambas                                 ณ
 ณ MV_PAR06 - Ordem de Impressao  1=Descri. Procedimento 2=C๓digo procedimentoณ
 ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */


If !Pergunte(cPerg,.T.)
	return
EndIf

 nMaxLin := HS_MaxLin(cCODIMP)
 nLin := nMaxLin * 2

wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,15,18)


RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ Daniel Peixoto     บ Data ณ  16/06/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

Local cSQL 	     := "" 
Local nTottab    := 0
Local nTotItens  := 0
Local lMudouTab  := .F.
Private cCodTab  := ""
Private cCodGrp  := ""
Private aTabPla  := {}

 cSQL := "SELECT  DISTINCT GC6.GC6_TABPRO, GCM.GCM_DESPLA "
 cSQL += " FROM " + RetSQLName("GC6") + " GC6" 
 cSQL += " JOIN " + RetSQLName("GCM") + " GCM ON GCM.GCM_CODPLA = GC6.GC6_CODPLA "
 cSQL += " WHERE"
 cSQL += "     GC6.GC6_FILIAL = '" + xFilial("GC6") + "' AND GC6.D_E_L_E_T_ <> '*' "
 cSQL += " AND GCM.GCM_FILIAL = '" + xFilial("GCM") + "' AND GCM.D_E_L_E_T_ <> '*' "
 cSQL += "Order By GC6_TABPRO"
                      
 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")
 DbGoTop()
 FS_MontaVet()               
 DBCloseArea()
 
 cSQL := "SELECT  DISTINCT GDB.GDB_CHAVE, GDB.GDB_DESCRI, GAW.GAW_CODGDE, GAW.GAW_DESC, GA8.GA8_CODPRO, GA7.GA7_DESC,  "
 cSQL += " GA8.GA8_CODPRT, GA8.GA8_DATVIG, GA8.GA8_VLRPRO,GA8.GA8_VLRCOS, GA8.GA8_METFIL, GA8.GA8_CODPAN, GA8.GA8_QTDAUX "
 cSQL += " FROM " + RetSQLName("GDB") + " GDB "  
 cSQL += " JOIN " + RetSQLName("GA8") + " GA8 ON GA8.GA8_TABPRO = GDB.GDB_CHAVE "
 cSQL += " JOIN " + RetSQLName("GA7") + " GA7 ON GA7.GA7_CODPRO = GA8.GA8_CODPRO "
 cSQL += " JOIN " + RetSQLName("GAW") + " GAW ON GAW.GAW_CODGDE = GA7.GA7_CODGDE "
 cSQL += " WHERE"
 cSQL += "     GDB.GDB_FILIAL = '" + xFilial("GDB") + "' AND GDB.D_E_L_E_T_ <> '*' "
 cSQL += " AND GA8.GA8_FILIAL = '" + xFilial("GA8") + "' AND GA8.D_E_L_E_T_ <> '*' "
 cSQL += " AND GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' "
 cSQL += " AND GAW.GAW_FILIAL = '" + xFilial("GAW") + "' AND GAW.D_E_L_E_T_ <> '*' "
 cSQL += " AND GDB.GDB_CHAVE  BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
 cSQL += " AND GA7.GA7_CODGDE BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "
/* If MV_PAR05 == 1   nao tem esse campo 
   cSQL += " AND G.G_TABATV = '0' "
 Else
   cSQL += " AND G.G_TABATV = '1' "
 EndIf           */
 cSQL += " AND GA8.GA8_DATVIG = ( SELECT MAX(GA81.GA8_DATVIG) "
 cSQL += " FROM " + RetSQLName("GDB") + " GDB "  
 cSQL += " JOIN " + RetSQLName("GA8") + " GA81 ON GA81.GA8_TABPRO = GDB.GDB_CHAVE "
 cSQL += " WHERE"
 cSQL += "     GDB.GDB_FILIAL = '" + xFilial("GDB") + "' AND GDB.D_E_L_E_T_ <> '*' "
 cSQL += " AND GA81.GA8_FILIAL = '" + xFilial("GA8") + "' AND GA81.D_E_L_E_T_ <> '*' "
 cSQL += " AND GA81.GA8_TABPRO = GA8.GA8_TABPRO  "
 cSQL += " AND GA81.GA8_CODPRO = GA8.GA8_CODPRO ) "
 If MV_PAR06 == 1
  cSQL += " Order By GDB_DESCRI, GAW_DESC, GA7_DESC"
 Else
  cSQL += " Order By GDB_DESCRI, GAW_DESC, GA8_CODPRO"
 EndIf 

 cSQL :=  ChangeQuery(cSQL)

 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")
 DbGoTop()
                                
 If Eof()
  MsgStop(STR0006) //"Nenhum dado foi encontado para a selecao efetuada!"
 Endif

/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
 ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

 SetRegua(100)
 
 While !EOF()

	 IncRegua()
   
   If lAbortPrint
      @nLin,00 PSAY STR0007 //"*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif
   
   If nLin > nMaxLin
              /*              				   1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21
        	             		   0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789 */
      Cabec1 := STR0008 //"Grupo de Procedimento"
      Cabec2 := STR0009 //"Procedimento                              Cod. Convenio   Vigencia      Vl. R$\CH   Vl. CH Oper.     M2 Filme  Porte Anest  Qtd Aux"
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nLin := 9
   Endif
   lMudouTab := .F.
   If cCodTab <> QRY->GDB_CHAVE
     If !EMPTY(cCodTab)   
       nLin++  
       @nLin,008 PSAY STR0010 //"Total de Itens do Grupo.: "
       @nLin,050 PSAY nTotItens
       nTotTab += nTotItens
       nTotItens := 0
       nLin +=2
       @nLin,008 PSAY STR0011 //"Total de Itens da Tabela: "
       @nLin,050 PSAY nTotTab
       nTotTab := 0
       nLin +=2    
       @nLin,050 PSAY STR0012 //"Planos que usam esta Tabela"
       nLin ++
       nLin:= FS_ImpVet(nLin)
       @nLin,000 PSAY REPLICATE("-",133)
       nLin += 2
     EndIf     
     @nLin,000 PSAY STR0013 +QRY->GDB_CHAVE +' - '+ QRY->GDB_DESCRI //"Tabela......: "
     nLin +=2
     lMudouTab := .T.
     cCodTab := QRY->GDB_CHAVE
     cCodGrp := ""
   EndIf

   If cCodGrp <> QRY->GAW_CODGDE 
     If !EMPTY(cCodGrp) .AND. !lMudouTab
       nLin++
       @nLin,008 PSAY STR0010 //"Total de Itens do Grupo.: "
       @nLin,050 PSAY nTotItens
       nTotTab += nTotItens
       nTotItens := 0
       nLin +=2    
     EndIf       
     @nLin,000 PSAY QRY->GAW_CODGDE +' - '+ QRY->GAW_DESC
     nLin +=2
     cCodGrp := QRY->GAW_CODGDE
   EndIf 

   @nLin,000 PSAY QRY->GA8_CODPRO +" - " + SUBSTR( QRY->GA7_DESC, 1 , 28 ) 
   @nLin,046 PSAY PADL(ALLTRIM(QRY->GA8_CODPRT), 10)  
   @nLin,058 PSAY DTOC( STOD(QRY->GA8_DATVIG) )      
   @nLin,069 PSAY TRANSFORM(QRY->GA8_VLRPRO,"@E 9,999,999.99") 
   @nLin,084 PSAY TRANSFORM(QRY->GA8_VLRCOS,"@E 9,999,999.999") 
   @nLin,099 PSAY TRANSFORM(QRY->GA8_METFIL,"@E 9,999.9999") 
   @nLin,116 PSAY PADL(ALLTRIM(QRY->GA8_CODPAN),6) 
   @nLin,130 PSAY QRY->GA8_QTDAUX 
   nTotItens += 1
   nLin ++        
   dbSkip() /* Avanca o ponteiro do registro no arquivo */
  
  If EOF()   
    nLin++
    @nLin,008 PSAY STR0010 //"Total de Itens do Grupo.: "
    @nLin,050 PSAY nTotItens
    nLin +=2
    nTotTab += nTotItens
    @nLin,008 PSAY STR0011 //"Total de Itens da Tabela: "
    @nLin,050 PSAY nTotTab
    nLin +=2    
    @nLin,050 PSAY STR0012 //"Planos que usam esta Tabela"
    nLin ++
    nLin:= FS_ImpVet(nLin)
  EndIf       
  
EndDo


/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 ณ Finaliza a execucao do relatorio...                                 ณ
 ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

SET DEVICE TO SCREEN

/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 ณ Se impressao em disco, chama o gerenciador de impressao...          ณ                                           	
 ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif

MS_FLUSH()
DBCloseArea()

Return   

Static Function FS_MontaVet()
  While !EOF()
    AADD(aTabPla,{QRY->GC6_TABPRO,QRY->GCM_DESPLA})
    DBSkip()
  EndDo  
Return()

Static Function FS_ImpVet(nLin)
Local nContFor := 0
Local nNroCol  := 1                    
Local nCol     := 0

  If Ascan(aTabPla,{|x| x[1] == cCodTab }) == 0
    @nLin,000 PSAY STR0020 //"Nenhum Plano Encontrado"
  Else
    For nCOntFor:= 1 to Len(aTabPla)
      If nNroCol <= 3
        If aTabPla[nCOntFor,1] == cCodTab  
          @nLin,nCol PSAY aTabPla[nCOntFor,2]
          nCol := nCol + 40
          nNroCol ++
        EndIf
      Else        
        nLin++         
        nCol    := 0
        nNroCol := 1   
      EndIf 
    Next  
  EndIF  
  nLin += 2
 
Return(nLin)
