#INCLUDE "HSPAHR69.ch"
#Include "protheus.ch"
#include "TopConn.ch"
#include "Report.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHR69  บ Autor ณ ANTONIO CARLOS     บ Data ณ  01/09/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio da tabela de taxas e diarias                     บฑฑ 
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบObs:      ณ Convertido para relatorios personalizaveis                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HSPAHR69()
 Local oReport
 If FindFunction("TRepInUse") .And. TRepInUse() 
 	pergunte("HSPR69",.F.)
  oReport := ReportDef() 
  oReport:PrintDialog()  
 ELSE  
  HSPAHR69R3()  
 EndIF
Return( Nil )     


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒ
ฒฒฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฒฒ
ฒฒณFuno    ณREPORTDEF ณ Autor ณ Antonio Carlos        ณ Data ณ 01/09/06 ณฒฒ
ฒฒภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฒฒ
ฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function ReportDef()
 Local oReport 
 Local oSection1, oSection2, oSection3, oSection4
 Local oCell
 Local oTotaliz1, oTotaliz2

 oReport := TReport():New("HSPAHR69",STR0003,"HSPR69",{|oReport| R69IMP(oReport)}, STR0001 + " " + STR0002 + " " + STR0003)
 //###"Relatorio de Diarias e Taxas"
 //###"Este programa tem como objetivo imprimir relatorio"###"de acordo com os parametros informados pelo usuario."###"Relatorio de Diarias e Taxas"

//oReport:SetLandscape()         // Imprimir relatorio em formato paisagem
 oReport:SetPortrait()          // Imprimir relatorio em formato retrato

 oSection1 := TRSection():New(oReport,STR0025,{"GD2"}) //"Tabela"
 oSection1:SetHeaderBreak(.F.)
 oSection1:SetPageBreak(.T.)
 oCell := TRCell():New(oSection1,"GD2_CODTAB","GD2",STR0009)   //"Tabela"     
 oCell := TRCell():New(oSection1,"GD2_DESCRI","GD2",)     
 
 oSection2 := TRSection():New(oSection1,"Descri็ใo",{"SX5"})
 oSection2:SetHeaderBreak(.F.)
 oSection2:SetPageBreak(.F.)
 oSection2:SetHeaderPage(.T.)
 oSection2:SetNoFilter({"SX5"})
 oCell := TRCell():New(oSection2,"X5_DESCRI","SX5",STR0004,,50)    //"Categoria"

 oSection3 := TRSection():New(oSection2,STR0004,{"GD3","GAA"})    //"Categoria"
 oSection3:SetHeaderBreak(.T.)    //Define se cabecalho das celulas sera impresso apos quebra TRBreak.
 oSection3:SetPageBreak(.F.)
 oSection3:SetHeaderSection(.T.)  //Define se cabecalho da celula sera impresso na quebra da secao.
 oSection3:SetHeaderPage(.T.)
 oCell := TRCell():New(oSection3,"GD3_CODTXD","GD3",STR0026)      //"Item"
 oCell := TRCell():New(oSection3,"GAA_DESC","GAA",)     
 oCell := TRCell():New(oSection3,"GD3_CODTXC","GD3",STR0027)      //"Conv๋nio"
 oCell := TRCell():New(oSection3,"GD3_VALVTX","GD3",STR0028)      //"Vl. Venda"
 oCell := TRCell():New(oSection3,"GD3_VALCTX","GD3",)     
 oCell := TRCell():New(oSection3,"GD3_DATVIG","GD3",)     

 oSection1:SetTotalInLine(.F.)
 oSection2:SetTotalInLine(.F.)
 oSection3:SetTotalInLine(.F.)

 DEFINE FUNCTION FROM oSection3:Cell("GD3_CODTXD") OF oSection1 FUNCTION COUNT TITLE STR0011 NO END REPORT   //"Total de Itens da Tabela"
 oTotaliz1 := TRFunction():new(oSection3:Cell("GD3_CODTXD"),,"COUNT",,STR0010,,,.T.,.F.,.F.)    //"Total de Itens da Categoria"
 oTotaliz2 := TRFunction():new(oSection3:Cell("GD3_CODTXD"),,"COUNT",,STR0022,,,.F.,.T.,.F.)   //"Total Geral de itens"

//-- Secao para Planos que utilizam a tabela em questao
oSection4:= TRSection():New(oReport,STR0013,{"GCM","GD2"},,,)    //"PLANOS QUE UTILIZAM A TABELA"
oSection4:SetHeaderSection()
//oSection4:SetPageBreak() 

oCell := TRCell():New(oSection4,"GD2_CODTAB","GD2",STR0025)      //"Tabela"
oCell := TRCell():New(oSection4,"GD2_DESCRI","GD2",)     
oCell := TRCell():New(oSection4,"GCM_DESPLA","GCM",)

Return( oReport )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ R69Imp   ณ Autor ณ MARCELO JOSE          ณ Data ณ 01/09/06 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function R69IMP(oReport)

 Local oSection1 := oReport:Section(1)
 Local oSection2 := oReport:Section(1):Section(1)
 Local oSection3 := oReport:Section(1):Section(1):Section(1)
 Local oSection4 := oReport:Section(2)
 Local cCond     := ""
 Local cCond1    := ""
 Local cSubs     := ""

 //-- Transforma parametros Range em expressao SQL
MakeSqlExpr(oReport:uParam)                      
 
If MV_PAR05 == 1
 cCond := "%GD2.GD2_TABATV = '1'%"
ElseIf MV_PAR05 == 2
 cCond := "%GD2.GD2_TABATV = '0'%"
Else
 //cCond := "%GD2.GD2_TABATV <> '" + STR(Len(MV_PAR05)) + "'%" 
 cCond := "%GD2.GD2_TABATV <> '" + ALLTRIM(STR(MV_PAR05)) + "'%"
Endif   

IF "MSSQL" $ Upper(TCGetDB())
 cSubs := "%SUBSTRING(SX5.X5_CHAVE,1,2)%"
ELSEIF "ORACLE" $ Upper(TCGetDB())
 cSubs := "%SUBSTR(SX5.X5_CHAVE,1,2)%"
ELSE
 cSubs := "%SUBSTR(SX5.X5_CHAVE,1,2)%"
ENDIF

oSection1:BeginQuery()
BeginSql alias "QRYR69"
 SELECT GD2.GD2_CODTAB, GD2.GD2_DESCRI, GD2.GD2_TABATV, SX5.X5_CHAVE,   SX5.X5_DESCRI, GD3.GD3_CODTXD,;
        GAA.GAA_DESC,   GD3.GD3_CODTXC, GD3.GD3_VALVTX, GD3.GD3_VALCTX, GD3.GD3_DATVIG 
 FROM %table:GD2% GD2 
 JOIN %table:GD3% GD3 ON GD3.GD3_CODTAB = GD2.GD2_CODTAB AND GD3.GD3_FILIAL = %xFilial:GD3% AND GD3.%NotDel%
 JOIN %table:GAA% GAA ON GAA.GAA_CODTXD = GD3.GD3_CODTXD AND GAA.GAA_FILIAL = %xFilial:GAA% AND GAA.%NotDel%
 JOIN %table:SX5% SX5 ON SX5.X5_TABELA  = %Exp:'CT'% AND %Exp:cSubs% = GAA.GAA_CODCTD AND SX5.X5_FILIAL = %xFilial:SX5% AND SX5.%NotDel%
 WHERE GD2.GD2_FILIAL = %xFilial:GD2% AND GD2.%NotDel%
   AND GD2.GD2_CODTAB BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
   AND SX5.X5_CHAVE   BETWEEN %Exp:PADR(MV_PAR03,6)% AND %Exp:PADR(MV_PAR04,6)%
   AND %Exp:cCond%
 ORDER BY GD2.GD2_DESCRI, SX5.X5_DESCRI, GAA.GAA_DESC
EndSql

oSection1:EndQuery()
oSection2:SetParentQuery()
oSection2:SetParentFilter( {|G| ("QRYR69")->GD2_CODTAB == G }, {|| ("QRYR69")->GD2_CODTAB } ) // Quebra por Tabela
oSection3:SetParentQuery()
oSection3:SetParentFilter( {|G| ("QRYR69")->X5_DESCRI + ("QRYR69")->GD2_CODTAB == G }, {|| ("QRYR69")->X5_DESCRI + ("QRYR69")->GD2_CODTAB } ) // Quebra por Categoria
oSection1:Print() // processa as informacoes da tabela principal
                     
oSection4:BeginQuery()
BeginSql alias "QRYR69A"
 SELECT GCM_DESPLA, GD8_CODTXD
   FROM %table:GCM% GCM
   JOIN %table:GD8% GD8 ON GD8_FILIAL = %xFilial:GD8% AND GD8_CODPLA = GCM_CODPLA AND GD8.%NotDel%
 WHERE GCM_FILIAL = %xFilial:GCM% AND GCM.%NotDel%
   AND GD8.GD8_CODTXD BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
  ORDER BY GCM_DESPLA
EndSql

oSection4:EndQuery()
oSection4:SetParentFilter({|G|("QRYR69A")->GCM_DESPLA == G}, {||("QRYR69A")->GCM_DESPLA}) //Quebra por Plano
oReport:SkipLine(2)
oReport:PrintText(STR0013,,10)  //"PLANOS QUE UTILIZAM A TABELA"
oSection4:Print()
oReport:SetMeter(QRYR69->(LastRec()))
	
Return( NIL )



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHR69R3บ Autor ณ Cibele Peria       บ Data ณ  16/06/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio da tabela de taxas e diarias                     บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHR69R3()

 Local cDesc1 := STR0001 //"Este programa tem como objetivo imprimir relatorio "
 Local cDesc2 := STR0002 //"de acordo com os parametros informados pelo usuario."
 Local cDesc3 := STR0003 //"Relatorio de Diarias e Taxas"
 Local aOrd   := {}
 Private Titulo := cDesc3
 Private Cabec1 := STR0004 //"Categoria"
 Private Cabec2 := STR0005 //"Item                                  Convenio     Vl.Venda    Vl.Custo Vigencia"
//                            0123456789,123456789,123456789,123456789,123456789,123456789,123456789,123456789.
 Private lEnd        := .F.
 Private lAbortPrint := .F.
 Private limite      := 80
 Private Tamanho     := "P"
 Private NomeProg    := "HSPAHR69" // Coloque aqui o nome do programa para impressao no cabecalho
 Private nTipo       := 18
 Private aReturn     := { STR0006, 1, STR0007, 2, 2, 1, "", 1} //"Zebrado"###"Administracao"
 Private nLastKey    := 0
 Private cbtxt       := Space(10)
 Private cbcont      := 00
 Private CONTFL      := 01
 Private m_pag       := 01
 Private wnrel       := NomeProg
 Private nTam        := 132 

 Private cCodTab_De  := "", cCodTab_Ate := "" 
 Private cCodCTD_De  := "", cCodCTD_Ate := ""
 Private nIdAtiv     := 0

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ PARAMETROS                                                         ณ
 //ณ MV_PAR01	- Da tabela                                               ณ
 //ณ MV_PAR02	- Ate a tabela                                            ณ
 //ณ MV_PAR03	- Da categoria                                            ณ
 //ณ MV_PAR04	- Ate a categoria                                         ณ
 //ณ MV_PAR05	- Ativa                                                   ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

 Private cCODIMP := ""
 Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao

 If !Pergunte("HSPR69", .T.)
  Return()
 EndIf

 nMaxLin := HS_MaxLin(cCODIMP)

 cCodTab_De  := mv_par01
 cCodTab_Ate := mv_par02
 cCodCTD_De  := mv_par03
 cCodCTD_Ate := mv_par04
 nIdAtiv     := mv_par05

 wnrel := SetPrint("", NomeProg, "", @Titulo, cDesc1, cDesc2, cDesc3, .T., aOrd, .T., Tamanho, , .T.)
 If nLastKey == 27
  Return()
 Endif

 SetDefault(aReturn, "")
 If nLastKey == 27
  Return()
 Endif

 nTipo := If(aReturn[4]==1,15,18)
 RptStatus({|| RunReport() }, Titulo)
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ Cibele Peria       บ Data ณ  16/06/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Rotina de execucao do relatorio                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function RunReport()
 Local   cSQL    := ""
 Local   cCodCTD := "" 
 Local   cCodTab := ""
 Local   nTotCTD := 0
 Local   nTotTab := 0
 Local   nTotGer := 0

 Private nLin    := nMaxLin * 2
 
 cSQL := "SELECT "
 cSQL += "GD2.GD2_CODTAB, GD2.GD2_DESCRI, GD2.GD2_TABATV, SX5.X5_CHAVE CHAVE, SX5.X5_DESCRI DESCRI, "
 cSQL += "GD3.GD3_CODTXD, GAA.GAA_DESC, GD3.GD3_CODTXC, GD3.GD3_VALVTX, GD3.GD3_VALCTX, GD3.GD3_DATVIG "
 cSQL += "FROM " + RetSQLName("GD2")+ " GD2 "
 cSQL += "JOIN " + RetSQLName("GD3")+ " GD3 ON GD3.GD3_CODTAB = GD2.GD2_CODTAB " 
 cSQL += "JOIN " + RetSQLName("GAA")+ " GAA ON GAA.GAA_CODTXD = GD3.GD3_CODTXD "
 cSQL += "JOIN " + RetSQLName("SX5")+ " SX5 ON SX5.X5_TABELA = 'CT' AND SX5.X5_CHAVE = GAA.GAA_CODCTD " 
 cSQL += " WHERE "
 cSQL += "GD2.GD2_FILIAL = '" + xFilial("GD2") + "' AND GD2.D_E_L_E_T_ <> '*' AND "
 cSQL += "GD3.GD3_FILIAL = '" + xFilial("GD3") + "' AND GD3.D_E_L_E_T_ <> '*' AND " 
 cSQL += "GAA.GAA_FILIAL = '" + xFilial("GAA") + "' AND GAA.D_E_L_E_T_ <> '*' AND "
 cSQL += "SX5.X5_FILIAL = '" + xFilial("SX5") + "' AND SX5.D_E_L_E_T_ <> '*' AND "
 cSQL += "GD2.GD2_CODTAB BETWEEN '" + cCodTab_De + "' AND '" + cCodTab_Ate + "' AND "
 cSQL += "SX5.X5_CHAVE BETWEEN '" + cCodCTD_De + "' AND '" + cCodCTD_Ate + "' "
 If nIdAtiv == 1
  cSQL += "AND GD2.GD2_TABATV = '1'"
 ElseIf nIdAtiv == 2
  cSQL += "AND GD2.GD2_TABATV = '0'"
 Endif 
 cSQL += "ORDER BY GD2.GD2_DESCRI, SX5.X5_DESCRI, GAA.GAA_DESC"
 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")
 DbGoTop()
 If Eof()
  HS_MsgInf(STR0008, STR0023, STR0024) //"Nenhum dado foi encontrado para a selecao efetuada."###"Aten็ใo"###"Verifique a sele็ใo"
  DbCloseArea()
  Return()
 Endif 
  
 SetRegua(1000)
 While !EOF()                                                                                
  IncRegua()

  If QRY->GD2_CODTAB <> cCodTab
   nLin := FS_Cabec()
   nLin += 1
   @nLin, 00 PSAY STR0009 + QRY->GD2_CODTAB + "-" + QRY->GD2_DESCRI //"Tabela: "
   nLin += 1
   cCodTab := QRY->GD2_CODTAB
  Endif
  
  If nLin+2 > nMaxLin
   nLin := FS_Cabec()
  Endif
  nLin += 1
  @nLin, 000 PSAY QRY->DESCRI
  nLin += 1
  cCodCTD := QRY->CHAVE

  DbSelectArea("QRY")  
  While !Eof() .and. QRY->GD2_CODTAB == cCodTab .and. QRY->CHAVE == cCodCTD
   
   If nLin+1 > nMaxLin
    nLin := FS_Cabec()
   Endif
   nLin += 1
   @nLin, 00 PSAY QRY->GD3_CODTXD
   @nLin, 11 PSAY SUBSTR(QRY->GAA_DESC, 1, 26)
   @nLin, 38 PSAY QRY->GD3_CODTXC
   @nLin, 48 PSAY TRANSFORM(QRY->GD3_VALVTX, "9999,999.99")
   @nLin, 60 PSAY TRANSFORM(QRY->GD3_VALCTX, "9999,999.99")
   @nLin, 72 PSAY DTOC(STOD(QRY->GD3_DATVIG))
   
   nTotCTD += 1
     
   DbSkip()
  End
  
  nLin    := FS_Total(STR0010, nTotCTD) //"Total de itens da categoria"
  nTotTab += nTotCTD
  nTotCTD := 0
  If Eof() .or. QRY->GD2_CODTAB <> cCodTab
   nLin    := FS_Total(STR0011, nTotTab) //"Total de itens da tabela"
   nTotGer += nTotTab
   nTotTab := 0
   If Eof()
    FS_Total(STR0022, nTotGer)
   Endif 
   nLin    := FS_Planos(cCodTab)
  Endif
  nLin += 1                             
  
 End 
             
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
 DBCloseArea()

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_Cabec  บ Autor ณ Cibele Peria       บ Data ณ  16/06/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Cabecalho do relatorio                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_Cabec()
 Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo, ,.T.) 
Return(8)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_Total  บ Autor ณ Cibele Peria       บ Data ณ  16/06/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Rotina de Totais                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_Total(cTotal, nValor)

 If nLin+2 > nMaxLin
  nLin := FS_Cabec()
 Endif
 nLin += 2
 @nLin, 12 PSAY cTotal
 @nLin, 40 PSAY TRANSFORM(nValor, "99,999")

Return(nLin)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_Total  บ Autor ณ Cibele Peria       บ Data ณ  16/06/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Rotina de Totais                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_Planos(cCodTab)
 Local cAliasOld := Alias()
 Local cSQL      := ""
 Local aLinha    := {}
 
 cSQL := "SELECT GCM.GCM_DESPLA "
 cSQL += "FROM " + RetSQLName("GD8")+ " GD8 "
 cSQL += "JOIN " + RetSQLName("GCM")+ " GCM ON GCM.GCM_CODPLA = GD8.GD8_CODPLA "
 cSQL += " WHERE "
 cSQL += "GD8.GD8_FILIAL = '" + xFilial("GD8") + "' AND GD8.D_E_L_E_T_ <> '*' AND "
 cSQL += "GCM.GCM_FILIAL = '" + xFilial("GCM") + "' AND GCM.D_E_L_E_T_ <> '*' AND "
 cSQL += "GD8.GD8_CODTXD = '" + cCodTab + "' "
 cSQL += "ORDER BY GCM.GCM_DESPLA" 
 TCQUERY cSQL NEW ALIAS "PLA"
 DbSelectArea("PLA")
 DbGoTop()
 
 If nLin+2 > nMaxLin
  nLin := FS_Cabec()
 Endif
 nLin += 1
 If Eof()
  If nLin+1 > nMaxLin
   nLin := FS_Cabec()
  Endif
  nLin += 1
  @nLin, 03 PSAY STR0012 + cCodTab //"NAO HA PLANOS CADASTRADOS PARA A TABELA "
 Else 
  If nLin+2 > nMaxLin
   nLin := FS_Cabec()
  Endif
  nLin += 1
  @nLin, 22 PSAY STR0013 + cCodTab //"PLANOS QUE UTILIZAM A TABELA "
  nLin += 1  
  @nLin, 22 PSAY REPLICATE("=", 35)  
 Endif 
 
 While !Eof()
 
  aLinha := {}
  While !Eof() .and. Len(aLinha) < 2
   aAdd(aLinha, PLA->GCM_DESPLA)
   DbSkip()
  End

  If nLin+1 > nMaxLin
   nLin := FS_Cabec()
  Endif
  nLin += 1
  
  @nLin, 06 PSAY aLinha[1]
  If len(aLinha) == 2
   @nLin, 44 PSAY aLinha[2]
  Endif
 
 End 

 DbSelectArea("PLA")
 DbCloseArea()
 DbSelectArea(cAliasOld)

Return(nLin)
