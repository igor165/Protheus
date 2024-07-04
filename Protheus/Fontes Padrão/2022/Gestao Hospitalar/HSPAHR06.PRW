#INCLUDE "HSPAHR06.ch"
#Include "protheus.ch"
#include "TopConn.ch"     
#define TRACE  repl("_",132)
#include "Report.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHR06  บ Autor ณ ANTONIO CARLOS     บ Data ณ  31/08/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Nao conformidades                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบObs:      ณ Convertido para relatorios personalizaveis                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HSPAHR06()
 Local oReport
 Private nTotQry := 0          
 
 If FindFunction("TRepInUse") .And. TRepInUse() 
 	pergunte("HSPR06",.F.)
  oReport := ReportDef() 
  oReport:PrintDialog()  
 ELSE  
  HSPAHR06R3()  
 EndIF
Return( Nil )     


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณREPORTDEF ณ Autor ณ MARCELO JOSE          ณ Data ณ 10/09/06 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function ReportDef()
 Local oReport 
 Local oSection1, oSection2, oSection3
 Local oCell
 Local oTotaliz1, oTotaliz2, oTotaliz3, oTotaliz4, oTotaliz5

 
 oReport := TReport():New("HSPAHR06",STR0003,"HSPR06",{|oReport| R06IMP(oReport)}, STR0001 + " " + STR0002 + " " + STR0003)
 //###"Este programa tem como objetivo imprimir relatorio"###"de acordo com os parametros informados pelo usuario."
 //###"Nao Conformidades "

 oReport:SetPortrait()          // Imprimir relatorio em formato retrato

 oSection1 := TRSection():New(oReport,STR0018,{"GSE","GSF"})   //"Nใo Conformidades"
 oSection1:SetHeaderBreak(.F.)
 oSection1:SetPageBreak(.T.)
 oSection1:SetReadOnly(.F.)
 oCell := TRCell():New(oSection1," "," "," ",,10)     
 oCell := TRCell():New(oSection1,"GSE_CODDET","GSE",STR0018) //"Nใo Conformidades"    
 oCell := TRCell():New(oSection1,"GSF_DESCRI","GSF"," ")     
 
 oSection2 := TRSection():New(oSection1,STR0027+"/"+STR0018,{"GSE","GBH","GSD","GSB"})     //"Nใo Conformidade..:"
 oSection2:SetHeaderBreak(.F.)
 oSection2:SetHeaderPage(.T.)
 oSection2:SetTotalInLine(.T.)
 oSection2:SetReadOnly(.F.)
 oCell := TRCell():New(oSection2,"GSE_REGGER","GSE",)
 oCell := TRCell():New(oSection2,"GBH_NOME"  ,"GBH",)             
 oCell := TRCell():New(oSection2,"GSD_TIPEND","GSD",STR0027)      //"Tipo Endere็o"
 oCell := TRCell():New(oSection2,"GSB_DESEND","GSB",STR0028)      //"Endere็o"

 oReport:SetTotalText(STR0022) //"Indicativo de Nใo Conformidade por Tipo de Endere็amento"

 oTotaliz1 := TRFunction():new(oSection2:Cell("GSE_REGGER"),,"COUNT",,"==>","@E 999",,.T.,.F.,.F.,,)

 oTotaliz2 := TRFunction():new(oSection2:Cell("GSD_TIPEND"),,"COUNT",,STR0011+"==>","@E 999",,.F.,.T.,.F.,,)   //"Ambulatorial"
 oTotaliz2:SetCondition( { || ("QRYR06")->GSD_TIPEND == "1" } ) 
                     
 oTotalizP2 := TRFunction():new(oSection2:Cell("GSD_TIPEND"),,"SUM",,STR0011+"==>","999.999",{|| STR( ( 1 / nTotQry ) * 100) },.F.,.T.,.F.,oSection1)   //"Ambulatorial"
 oTotalizP2:SetCondition( { || ("QRYR06")->GSD_TIPEND == "1" } ) 

 oTotaliz3 := TRFunction():new(oSection2:Cell("GSD_TIPEND"),,"COUNT",,STR0012+"==>","@E 999",,.F.,.T.,.F.,,)   //"Pronto Atendimento"
 oTotaliz3:SetCondition( { || ("QRYR06")->GSD_TIPEND == "2" } ) 

 oTotalizP3 := TRFunction():new(oSection2:Cell("GSD_TIPEND"),,"SUM",,STR0012+"==>","999.999",{|| STR( ( 1 / nTotQry ) * 100) },.F.,.T.,.F.,oSection1)   //"Pronto Atendimento"
 oTotalizP3:SetCondition( { || ("QRYR06")->GSD_TIPEND == "2" } ) 

 oTotaliz4 := TRFunction():new(oSection2:Cell("GSD_TIPEND"),,"COUNT",,STR0013+"==>","@E 999",,.F.,.T.,.F.,,)   //"Hospitalar"
 oTotaliz4:SetCondition( { || ("QRYR06")->GSD_TIPEND == "3" } ) 

 oTotaliz4 := TRFunction():new(oSection2:Cell("GSD_TIPEND"),,"COUNT",,STR0013+"==>","999.999",{|| STR( ( 1 / nTotQry ) * 100) },.F.,.T.,.F.,,)   //"Hospitalar"
 oTotaliz4:SetCondition( { || ("QRYR06")->GSD_TIPEND == "3" } ) 
 
 oTotaliz5 := TRFunction():new(oSection2:Cell("GSD_TIPEND"),,"COUNT",,STR0014,"@E 999",,.F.,.T.,.F.,,) //"Total Geral==>"

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ TRFunction:  Classe que instancia totalizadores de quebra, secoes ou relatorios.                                                                        ณ
 //ณ Parametros para o construtor inicializar as variaveis de instancia :                                                                                    ณ
 //ณ (oSec:Cell("campo"),/*cVarTemp*/,/*FUNCAO*/,/*oBreak*/,/*cTit*/,/*cPict*/,/*uForm*/,.F./*lEndSect*/,.F./*lEndRep*/,.F./*lEndPage*/,oSection,condition)  ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Return( oReport )


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ R06Imp   ณ Autor ณ Antonio Carlos        ณ Data ณ 31/08/06 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function R06IMP(oReport)

Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(1):Section(1)

//-- Transforma parametros Range em expressao SQL
MakeSqlExpr(oReport:uParam)                      
 
oSection1:BeginQuery()

BeginSql alias "QRYR06"
 SELECT GSE_REGGER, GSE_DATNCF, GSE_CODDET, GBH_NOME, GSD_TIPEND, GSD_DESEND, GSB_DESEND, GSF_DESCRI 
 FROM %table:GSE% GSE 
 JOIN %table:GBH% GBH ON GBH.GBH_CODPAC = GSE.GSE_REGGER AND GBH.GBH_FILIAL = %xFilial:GBH% AND GBH.%NotDel%  
 JOIN %table:GSD% GSD ON GSD.GSD_CODEND = GSE.GSE_CODEND AND GSD.GSD_FILIAL = %xFilial:GSD% AND GSD.%NotDel%  
 JOIN %table:GSB% GSB ON GSB.GSB_REGGER = GSE.GSE_REGGER 
                     AND GSB.GSB_CODEND = GSE.GSE_CODEND AND GSB.GSB_FILIAL = %xFilial:GSB% AND GSB.%NotDel%  
 JOIN %table:GSF% GSF ON GSF.GSF_CODIGO = GSE.GSE_CODDET AND GSF.GSF_FILIAL = %xFilial:GSF% AND GSF.%NotDel%  
 WHERE GSE.GSE_FILIAL = %xFilial:GSE% AND GSE.%NotDel%  
   AND GSE.GSE_DATNCF BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%  
   AND GSE.GSE_CODDET BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%  
 ORDER BY GSF_DESCRI 
EndSql

oSection1:EndQuery()
oSection2:SetParentQuery()
oSection2:SetParentFilter( {|G| ("QRYR06")->GSE_CODDET == G }, {|| ("QRYR06")->GSE_CODDET }) // Quebra P/Nao Conformidade
                
While ("QRYR06")->(!Eof())
 nTotQry++  
 DbSkip()
End

oSection1:Print() // processa as informacoes da tabela principal
oReport:SetMeter(QRYR06->(LastRec()))
                  
Return( NIL )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHR06R3บ Autor ณ Mario Arizono      บ Data ณ  08/08/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Nao conformidades                                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HSPAHR06R3()


/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 ณ Declaracao de Variaveis                                             ณ
 ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3         := ""
Local cPict          := ""
Local titulo         := STR0003 //"Nao Conformidades "
Local nLin           := 80 
Local Cabec1         := ""
Local Cabec2         := ""
Local imprime        := .T.
Local aOrd 				   := {}    

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 80
Private tamanho      := "M"
Private nomeprog     := "HSPAHR06" /* Coloque aqui o nome do programa para impressao no cabecalho */
Private nTipo        := 18
Private aReturn      := {STR0004 , 1, STR0005, 2, 2, 1, "", 1}      //"Administracao"###"Zebrado"
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "HSPAHR06" /* Coloque aqui o nome do arquivo usado para impressao em disco */
Private cPerg        := "HSPR06"
Private cString      := ""  
Private aVetGraf     := {}

Private cCODIMP := ""
Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao

/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
  ณ PARAMETROS                                                         ณ
  ณ MV_PAR01	Do Periodo                                                ณ
  ณ MV_PAR02	Ate Periodo                                               ณ
  ณ MV_PAR03	Da Nao Conformidade                                       ณ
  ณ MV_PAR04	Ate a Nao Conformidade                                    ณ
  ณ MV_PAR05	Grafico                                                   ณ     
  ณ MV_PAR06	Tipo de Endereco                                          ณ
  ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/

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
ฑฑบFuno    ณRUNREPORT บ Autor ณ Mario Arizono     บ Data ณ  08/08/05    บฑฑ
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
Private cCodDet  := ""      
Private nTotCon  := 0
Private nTotGer  := 0   
Private nTotAmb  := 0      
Private nTotPro  := 0
Private nTotHos  := 0  
Private nPerAm   := 0 
Private nPerPa   := 0 
Private nPerHs   := 0 
   
 cSQL := "SELECT GSE.GSE_REGGER, GSE.GSE_DATNCF, GSE.GSE_CODDET, GBH.GBH_NOME, GSD.GSD_TIPEND, GSD.GSD_DESEND,"
 cSQL += "GSB.GSB_DESEND, GSF.GSF_DESCRI"
 cSQL += " FROM " + RetSQLName("GSE") + " GSE"                                   
 cSQL += " JOIN " + RetSQLName("GBH") + " GBH ON GBH.GBH_CODPAC = GSE.GSE_REGGER"
 cSQL += " JOIN " + RetSQLName("GSD") + " GSD ON GSD.GSD_CODEND = GSE.GSE_CODEND" 
 cSQL += " JOIN " + RetSQLName("GSB") + " GSB ON GSB.GSB_REGGER = GSE.GSE_REGGER AND GSB.GSB_CODEND=GSE.GSE_CODEND"
 cSQL += " JOIN " + RetSQLName("GSF") + " GSF ON GSF.GSF_CODIGO = GSE.GSE_CODDET"
 cSQL += " WHERE"
 cSQL += "     GSE.GSE_FILIAL = '" + xFilial("GSE") + "' AND GSE.D_E_L_E_T_ <> '*' "
 cSQL += " AND GBH.GBH_FILIAL = '" + xFilial("GBH") + "' AND GBH.D_E_L_E_T_ <> '*' "
 cSQL += " AND GSD.GSD_FILIAL = '" + xFilial("GSD") + "' AND GSD.D_E_L_E_T_ <> '*' "
 cSQL += " AND GSB.GSB_FILIAL = '" + xFilial("GSB") + "' AND GSB.D_E_L_E_T_ <> '*' "
 cSQL += " AND GSF.GSF_FILIAL = '" + xFilial("GSF") + "' AND GSF.D_E_L_E_T_ <> '*' "    
 cSQL += " AND GSE.GSE_DATNCF BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' "
 cSQL += " AND GSE.GSE_CODDET BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' "    
 If MV_PAR06=1
  cSQL+="AND GSD.GSD_TIPEND='1'"
 ElseIf MV_PAR06=2
  cSQL+="AND GSD.GSD_TIPEND='2'"
 ElseIf MV_PAR06=3
  cSQL+="AND GSD.GSD_TIPEND='3'"
 Endif      
 cSQL += " ORDER BY GSF_DESCRI "
 
 cSQL :=  ChangeQuery(cSQL)

 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")
 DbGoTop()
                                
 If Eof()
  HS_MsgInf(STR0006,STR0026,STR0003) //"Nenhum dado foi encontrado para a selecao efetuada!",//"Nao Conformidades " //"Atencao"
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
/*              				                 1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21
        			                0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789 */
      Cabec1 := STR0008 //"Prontuario   Nome                                        Tipo Endereco           Endereco  "
      Cabec2 := "" 
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nLin := 9
   Endif

  If cCodDet <> QRY->GSE_CODDET
    If !EMPTY(cCodDet)
      nLin++
      @nLin,000 PSAY STR0009 + TRANSFORM(nTotCon, "@E 999999")       //"Total de Nao Conformidades.......: "
       nLin +=2
    EndIf 
    @nLin,000 PSAY STR0010 + QRY->GSE_CODDET + "-" + QRY->GSF_DESCRI  //"Nao Conformidade.......:"
    cCodDet := QRY->GSE_CODDET
    nTotCon := 0
    nLin +=2
  EndIf                                        
                    
  @nLin,000 PSAY QRY->GSE_REGGER
  @nLin,013 PSAY alltrim(QRY->GBH_NOME)
  If MV_PAR06==4
    If QRY->GSD_TIPEND == "1"  
     @nLin,057 PSAY STR0011  //"Ambulatorial"
    ElseIf QRY->GSD_TIPEND == "2" 
     @nLin,057 PSAY STR0012 //"Pronto Atendimento"
    ElseIf QRY->GSD_TIPEND == "3" 
     @nLin,057 PSAY STR0013 //"Hospitalar" 
    Endif     
  Else  
    If QRY->GSD_TIPEND == "1"  
     @nLin,057 PSAY STR0011  //"Ambulatorial"
    ElseIf QRY->GSD_TIPEND == "2" 
     @nLin,057 PSAY STR0012 //"Pronto Atendimento"
    ElseIf QRY->GSD_TIPEND == "3" 
     @nLin,057 PSAY STR0013 //"Hospitalar"    
    EndIf  
  Endif
  @nLin,081 PSAY QRY->GSB_DESEND
  nTotCon++
  nTotGer++  
  If QRY->GSD_TIPEND=="1"
    nTotAmb++  
  ElseIf QRY->GSD_TIPEND=="2"
    nTotPro++            
  ElseIf QRY->GSD_TIPEND=="3"
    nTotHos++   
  Endif  
  nPerAm  := (nTotAmb/nTotGer)*100
  nPerPa  := (nTotPro/nTotGer)*100
  nPerHs  := (nTotHos/nTotGer)*100     
 
  dbSkip() /* Avanca o ponteiro do registro no arquivo */  
  
  nLin ++
  If EOF() 
    nLin++
    @nLin,000 PSAY STR0009 + TRANSFORM(nTotCon, "@E 999999") //"Total de Nao Conformidades.......: "
    nLin ++   
    @nLin,000 PSAY TRACE
    nLin++                                                                                   
    @nLin,015 PSAY STR0014 + TRANSFORM(nTotGer, "@E 999999") //"Total Geral.......: "
  EndIf
  
EndDo

 If MV_PAR05 == 1     
  /* Monta vetor para o grafico carteziano */ 
  AADD(aVetGraf,{nPerAm,STR0015+Str(nPerAm,6,2)+"%"} ) //"Amb."
  AADD(aVetGraf,{nPerPa,STR0016+Str(nPerPa,6,2)+"%"} ) //"Pr.Atend."
  AADD(aVetGraf,{nPerHs,STR0017+Str(nPerHs,6,2)+"%"} ) //"Hosp."
  /* CRIA O OBJETO PARA CONSTRUCAO DO GRAFICO CARTEZIANO  */
  oGraf := hsGRAF():NEW("%", STR0018, STR0019+Str(nTotGer,8,2), STR0020, STR0021, "", aVetGraf,1,1,0,0,2,20,6,6,25,20)  //"Nao Conformidades"###"Total de Nao Conformidades.......:"###"Percentual %"###"Tipos de Enderecamento"
 EndIf    
 If nLin < (nMaxLin - 10)
   nLin +=3
   @nLin,025 PSAY STR0022 //"Indicativo de Nao Conformidade por Tipo de Enderecamento"
   nLin +=2
   @nLin,020 PSAY STR0023 //"Tipo de End."
   @nLin,050 PSAY STR0024 //"Qtd. Nao Conformidades"
   @nLin,075 PSAY STR0025 //"Percentual"
   nLin +=2
   @nLin,020 PSAY STR0011 //"Ambulatorial"
   @nLin,060 PSAY nTotAmb
   @nLin,075 PSAY TRANSFORM(nPerAm,"@E 999.999") + "%"   
   nLin++
   @nLin,020 PSAY STR0012 //"Pronto Atendimento"
   @nLin,060 PSAY NTotPro
   @nLin,075 PSAY TRANSFORM(nPerPa,"@E 999.999") + "%"
   nLin++
   @nLin,020 PSAY STR0013 //"Hospitalar"
   @nLin,060 PSAY NTotHos
   @nLin,075 PSAY TRANSFORM(nPerHs,"@E 999.999") + "%"
   nLin +=2
   @nLin,020 PSAY STR0014 //"Total Geral.......: "
   @nLin,055 PSAY TRANSFORM(nTotGer, "@E 999999")    
 Else 
   nLin:=3    
   @nLin,025 PSAY STR0022 //"Indicativo de Nao Conformidade por Tipo de Enderecamento"
   nLin +=2
   @nLin,020 PSAY STR0023 //"Tipo de End."
   @nLin,050 PSAY STR0024 //"Qtd. Nao Conformidades"
   @nLin,075 PSAY STR0025 //"Percentual"
   nLin +=2
   @nLin,020 PSAY STR0011 //"Ambulatorial"
   @nLin,060 PSAY nTotAmb
   @nLin,075 PSAY TRANSFORM(nPerAm,"@E 999.999") + "%"   
   nLin++
   @nLin,020 PSAY STR0012 //"Pronto Atendimento"
   @nLin,060 PSAY NTotPro
   @nLin,075 PSAY TRANSFORM(nPerPa,"@E 999.999") + "%"
   nLin++
   @nLin,020 PSAY STR0013 //"Hospitalar"
   @nLin,060 PSAY NTotHos
   @nLin,075 PSAY TRANSFORM(nPerHs,"@E 999.999") + "%"
   nLin +=2
   @nLin,020 PSAY STR0014 //"Total Geral.......: "
   @nLin,055 PSAY TRANSFORM(nTotGer, "@E 999999")
 Endif 
 
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