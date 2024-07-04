#INCLUDE "HSPAHR49.ch"
#Include "protheus.ch"
#include "TopConn.ch"
#include "Report.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHR49  บ Autor ณ ANTONIO CARLOS     บ Data ณ  25/07/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio de atendimentos por usuario                      บฑฑ 
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบObs:      ณ Convertido para relatorios personalizaveis                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HSPAHR49()
 Local oReport
 Private aVetor  := {} 
 Private nTotQry := 0
 
 If FindFunction("TRepInUse") .And. TRepInUse() 
 	pergunte("HSPR49",.F.)
  oReport := ReportDef() 
  oReport:PrintDialog()  
 ELSE  
  HSPAHR49R3()  
 EndIF
Return( Nil )     


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒ
ฒฒฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฒฒ
ฒฒณFuno    ณREPORTDEF ณ Autor ณ Antonio Carlos        ณ Data ณ 25/07/06 ณฒฒ
ฒฒภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฒฒ
ฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function ReportDef()
 Local oReport 
 Local oSection1, oSection2
 Local oCell
 Local oTotaliz1
  
 oReport := TReport():New("HSPAHR49",STR0003,"HSPR49",{|oReport| R49IMP(oReport)}, STR0001 + " " + STR0002 + " " + STR0003)
 //"Atendimentos por usuario"
 //"Este programa tem como objetivo imprimir relatorio"###"de acordo com os parametros informados pelo usuario." ###"Atendimentos por usuario"
 
 oSection1 := TRSection():New(oReport,STR0009,{"GCS"})    //"Setor"
 oSection1:SetHeaderBreak(.F.)
 oSection1:SetPageBreak(.T.)
 oSection1:SetHeaderPage(.T.)
 oSection1:SetHeaderSection(.T.)  //Define se cabecalho da celula sera impresso na quebra da secao.

 oCell := TRCell():New(oSection1,"GCS_NOMLOC","GCS",STR0009)  //"Setor"     
 
 oSection2 := TRSection():New(oSection1,STR0011,{"GCY"})       //"Usuแrios"
 oSection2:SetTotalInLine(.F.)
 oSection2:SetHeaderPage(.T.)
 oCell := TRCell():New(oSection2,"GCY_ATENDE","GCY",STR0011,,50) //"Usuแrios"
 oCell := TRCell():New(oSection2,"QTDATE","QRYR49",STR0010)      //"Quantidade"
 oCell := TRCell():New(oSection2,"nPERUSU"," ","    (%)   ","9999.99",6,,{||(QRYR49->QTDATE / FS_DevTot(QRYR49->GCY_LOCATE))*100})
 
 oSection2:SetTotalText(STR0008)   //"Total de atendimentos do setor "
 oTotaliz1 := TRFunction():new(oSection2:Cell("QTDATE"),,"SUM",,,"99999.99",,.T.,.F.,.F.)

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ TRFunction:  Classe que instancia totalizadores de quebra, secoes ou relatorios.                                                                        ณ
 //ณ Parametros para o construtor inicializar as variaveis de instancia :                                                                                    ณ
 //ณ (oSec:Cell("campo"),/*cVarTemp*/,/*FUNCAO*/,/*oBreak*/,/*cTit*/,/*cPict*/,/*uForm*/,.F./*lEndSect*/,.F./*lEndRep*/,.F./*lEndPage*/,oSection,condition)  ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Return( oReport )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ R63Imp   ณ Autor ณ MARCELO JOSE          ณ Data ณ 10/09/06 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function R49IMP(oReport)

 Local oSection1 := oReport:Section(1)
 Local oSection2 := oReport:Section(1):Section(1)
 Local cGroupBy  := "%GCY_FILIAL, GCS_NOMLOC, GCY_ATENDE, GCY_LOCATE%"
 Local cLocAte   := ""

 //-- Transforma parametros Range em expressao SQL
MakeSqlExpr(oReport:uParam)                      
 
If MV_PAR05 == 1
 cCond:= "%GCS_NOMLOC, QTDATE DESC%"
Else
 cCond:= "%GCS_NOMLOC, GCY.GCY_ATENDE%"
EndIf

oSection1:BeginQuery()
BeginSql alias "QRYR49"
SELECT GCY_LOCATE, GCS_NOMLOC, GCY_ATENDE, COUNT(*) QTDATE
FROM %table:GCY% GCY 
JOIN %table:GCS% GCS ON GCS_CODLOC = GCY_LOCATE  AND GCS.GCS_FILIAL = %xFilial:GCS% AND GCS.%NotDel%
WHERE GCY_FILIAL = %xFilial:GCY% AND GCY.%NotDel%
AND GCY_TPALTA <> %Exp:'99'% 
AND GCY_LOCATE BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
AND GCY_DATATE BETWEEN %Exp:DTOS(MV_PAR03)% AND %Exp:DTOS(MV_PAR04)%
GROUP BY %Exp:cGroupBy%
ORDER BY %Exp:cCond%
EndSql

oSection1:EndQuery()
cLocAte := QRYR49->GCY_LOCATE
 
While ("QRYR49")->(!Eof())
 nLocate := AScan(aVetor,{|x| alltrim(x[1]) == ("QRYR49")->GCY_LOCATE })
 If nLocate > 0
  aVetor[nLocate,2] += ("QRYR49")->QTDATE
 Else 
  AADD(aVetor,{ ("QRYR49")->GCY_LOCATE,("QRYR49")->QTDATE} )
 EndIf
 nTotQry = ("QRYR49")->QTDATE
 DbSkip()
End

oSection2:SetParentQuery()
oSection2:SetParentFilter({|G|("QRYR49")->GCS_NOMLOC == G }, {||("QRYR49")->GCS_NOMLOC}) // Quebra por Setor
oSection1:Print() // processa as informacoes da tabela principal
oReport:SetMeter(QRYR49->(LastRec()))
                   
Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ R63Imp   ณ Autor ณ MARCELO JOSE          ณ Data ณ 10/09/06 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function FS_DevTot(cSetor)
 Local nLocate := AScan(aVetor,{|x| alltrim(x[1]) == cSetor })
 nRet := 0
 If nLocate > 0
  nRet := aVetor[nLocate,2]
 EndIf
Return(nRet)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHR49R3บ Autor ณ Cibele Peria       บ Data ณ  26/09/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio de atendimentos por usuario                      บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHR49R3()
 Local cDesc1        := STR0001 //"Este programa tem como objetivo imprimir relatorio "
 Local cDesc2        := STR0002 //"de acordo com os parametros informados pelo usuario."
 Local cDesc3        := STR0003 //"Atendimentos por usuario"
 Local aOrd          := {}

 Private Titulo      := ""
 Private cCabec      := STR0004 //"     Usuario                               Quantidade            (%)"
//                                 0123456789.0123456789.0123456789.0123456789.0123456789.0123456789.123456789
 Private lEnd        := .F.
 Private lAbortPrint := .F.
 Private limite      := 80
 Private Tamanho     := "P"
 Private NomeProg    := "HSPAHR49"
 Private nTipo       := 18
 Private aReturn     := {STR0005, 1, STR0006, 1, 2, 1, "", 1} //"Zebrado"###"Administracao"
 Private nLastKey    := 0
 Private m_pag       := 01
 Private wnrel       := NomeProg
 Private nTam        := 80
 
 Private cLocAte_De  := "", cLocAte_Ate := ""
 Private dDatAte_De  := "", dDatAte_Ate := ""
 Private nOrdem      := 0
 Private nGrafico    := 0     
 Private aVetGraf    := {}

 Private cCODIMP := ""
 Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ PARAMETROS                                                       ณ
 //ณ MV_PAR01	Do setor                                              ณ
 //ณ MV_PAR02	Ate o setor                                           ณ
 //ณ MV_PAR03	Da data atendimento                                   ณ
 //ณ MV_PAR04	Ate o data de atendimento                             ณ
 //ณ MV_PAR05	nOrdem - 1=Quantidade (decrescente); 2=Usuario        ณ
 //ณ MV_PAR06	nGrafico - 1=Sim; 2=Nao                               ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 If !Pergunte("HSPR49",.T.)
  Return()
 EndIf

 nMaxLin := HS_MaxLin(cCODIMP)
 
 cLocAte_De  := mv_par01
 cLocAte_Ate := mv_par02
 dDatAte_De  := mv_par03
 dDatAte_Ate := mv_par04
 nOrdem      := mv_par05
 nGrafico    := mv_par06 
 
 Titulo := "Atd. p/ Usr " + DTOC(MV_PAR03) + "-" + DTOC(MV_PAR04)
 
 wnrel := SetPrint("GCY", NomeProg, "", @Titulo, cDesc1, cDesc2, cDesc3, .T., aOrd, .T., Tamanho, , .T.)
 If nLastKey == 27
  Return()
 Endif
 
 SetDefault(aReturn, "GCY")
 If nLastKey == 27
  Return()
 Endif

 nTipo := If(aReturn[4]==1,15,18)
 RptStatus({|| RunReport() }, Titulo)
 
 SET DEVICE TO SCREEN
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Se impressao em disco, chama o gerenciador de impressao...          ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 If aReturn[5]==1
  dbCommitAll()
  SET PRINTER TO
  OurSpool(wnrel)
 Endif

 MS_FLUSH()
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHR49 บ Autor ณ Cibele Peria       บ Data ณ  26/09/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Execucao do relatorio                                      บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function RunReport()
 Local cSql    := ""
 Local nLin    := nMaxLin * 2
 Local cLocAte := ""
 Local aTotLoc := {}
 Local nTotAte := 0 //Total de Atendimentos por setor
 Local nTotUsu := 0 //Total de usuarios (linhas) por setor
 Local nAcuPer := 0 //Valor acumulado do percentual por setor
 Local nAcuUsu := 0 //Quantidade acumulada de usuarios (linhas) por setor
 Local nValPer := 0
 Local cValPer := ""
 Local nTotReg := 0 //Total de registro da query

 cSQL := "SELECT GCY.GCY_LOCATE, GCS.GCS_NOMLOC, GCY.GCY_ATENDE, COUNT(*) AS QTDATE "
 cSQL += "FROM " + RetSQLName("GCY") + " GCY "
 cSQL += "JOIN " + RetSQLName("GCS") + " GCS ON GCS.GCS_CODLOC = GCY.GCY_LOCATE "
 cSQL += "WHERE GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND  GCY.D_E_L_E_T_ <> '*' "
 cSQL += "AND GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND  GCS.D_E_L_E_T_ <> '*' " 
 cSQL += "AND GCY.GCY_TPALTA <> '99' "
 cSQL += "AND GCY.GCY_LOCATE BETWEEN '" + cLocAte_De + "' AND '" + cLocAte_Ate + "' "
 cSQL += "AND GCY.GCY_DATATE BETWEEN '" + DTOS(dDatAte_De) + "' AND '" + DTOS(dDatAte_Ate) + "' "
 cSQL += "GROUP BY GCY.GCY_LOCATE, GCS.GCS_NOMLOC, GCY.GCY_ATENDE "
 If nOrdem == 1
  cSQL += "ORDER BY GCS.GCS_NOMLOC, QTDATE DESC"
 Else
  cSQL += "ORDER BY GCS.GCS_NOMLOC, GCY.GCY_ATENDE"
 Endif  
 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")
 DbGoTop()
 If Eof()
  HS_MsgInf(STR0007, STR0012, STR0013) //"Nenhum dado foi encontrado para a selecao efetuada."###"Aten็ใo"###"Verifique a sele็ใo"
  DbCloseArea()
  Return()
 Endif 
             
 While !Eof()
  If QRY->GCY_LOCATE <> cLocAte
   aAdd(aTotLoc, {QRY->GCY_LOCATE, 0, 0})
   cLocAte := QRY->GCY_LOCATE
  Endif 
  
  aTotLoc[len(aTotLoc), 2] += QRY->QTDATE
  aTotLoc[len(aTotLoc), 3] += 1
  nTotReg += 1
  DbSkip()
 End 
  
 DbGotop()
 cLocAte := ""
 SetRegua(nTotReg)
 While !Eof()                                                                                
  IncRegua()

  If QRY->GCY_LOCATE <> cLocAte    
   If !Empty(cLocAte) .AND. nGrafico==1
  // CRIA O OBJETO PARA CONSTRUCAO DO GRAFICO CARTEZIANO  
    oGraf := hsGRAF():NEW(STR0003,STR0009+ cLocAte+" - "+ POSICIONE("GCS",1,xFilial("GCS")+cLocAte,"GCS_NOMLOC"), STR0008+"...: "+ ALLTRIM(STR(nTotAte)),STR0010, STR0011, "", aVetGraf,1,1,0,0,2,17,6,6,25,20)    //"Setor...: "###"Quantidade"###"Usuarios"
   Endif
   If nTotAte > 0
    nLin := FS_Total(nTotAte, nLin)
   Endif
   nLin    := FS_Cabec(.T.)
   cLocAte := QRY->GCY_LOCATE
   nTotAte := aTotLoc[aScan(aTotLoc, {|x| x[1] == QRY->GCY_LOCATE}), 2]                                 
   nTotUsu := aTotLoc[aScan(aTotLoc, {|x| x[1] == QRY->GCY_LOCATE}), 3]
   aVetGraf:= {}
   nAcuPer := 0
   nAcuUsu := 0
  Endif 

  nAcuUsu += 1
  If nAcuUsu == nTotUsu
   cValPer := TRANSFORM(100 - nAcuPer, "999.99")
  Else 
   cValPer := TRANSFORM((QRY->QTDATE / nTotAte) * 100, "999.99")  
  Endif 
  nValPer := Val(cValPer)
  nAcuPer += nValPer
           
  If nLin+1 > nMaxLin
   FS_Cabec()
  Endif   
  
  nLin += 1
  @nLin, 005 PSAY QRY->GCY_ATENDE
  @nLin, 042 PSAY TRANSFORM(QRY->QTDATE, "999,999,999")
  @nLin, 062 PSAY cValPer   
  AADD(aVetGraf,{QRY->QTDATE,PADR(QRY->GCY_ATENDE,8)+" "+ STR(nValPer,6,2)+"%"})
  DbSelectArea("QRY")
  DbSkip()
 End 
 If EOF() .AND. nGrafico==1
  // CRIA O OBJETO PARA CONSTRUCAO DO GRAFICO CARTEZIANO  
  oGraf := hsGRAF():NEW(STR0003,STR0009+ cLocAte+" - "+ POSICIONE("GCS",1,xFilial("GCS")+cLocAte,"GCS_NOMLOC"), STR0008+"...: "+ALLTRIM(STR(nTotAte)),STR0010, STR0011, "", aVetGraf,1,1,0,0,2,17,6,6,25,20)   //"Setor...: "###"Quantidade"###"Usuarios"
 Endif   
 FS_Total(nTotAte, nLin)
 
 DbCloseArea()

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHR49 บ Autor ณ Cibele Peria       บ Data ณ  26/09/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Cabecalho                                                  บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_Cabec(lCabec)
 Local   nLin   := 8
 Local   aArea  := GetArea()
 Local   Cabec1 := ""
 Local   Cabec2 := ""
 Default lCabec := .F.
                          
 If lCabec
  DbSelectArea("GCS")
  DbSetOrder(1)
  DbSeek(xFilial("GCS") + QRY->GCY_LOCATE)
  Cabec1 := GCS->GCS_NOMLOC
  Cabec2 := cCabec
 Else
  Cabec1 := cCabec
  Cabec2 := "" 
 Endif
  
 Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo, ,.T.) 
 
 RestArea(aArea)

Return(nLin)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHR49 บ Autor ณ Cibele Peria       บ Data ณ  26/09/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Impressao do total do setor                                บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_Total(nTotAte, nLin)
 If nLin+2 > nMaxLin
  nLin := FS_Cabec()
 Endif
 
 nLin += 2
 @nLin, 005 PSAY STR0008 + "..:" //"Total de atendimentos do setor" 
 @nLin, 042 PSAY TRANSFORM(nTotAte, "999,999,999")
 
Return(nLin)
