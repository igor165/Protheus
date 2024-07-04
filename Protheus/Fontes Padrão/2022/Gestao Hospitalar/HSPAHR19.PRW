#INCLUDE "HSPAHR19.ch"     
#Include "protheus.ch"
#include "TopConn.ch"
#include "report.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHR19  บ Autor ณ ANTONIO CARLOS     บ Data ณ  10/08/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio de Atendimentos por periodo                      บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบObs:      ณ Convertido para relatorios personalizaveis                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHR19()

Local oReport

 If FindFunction("TRepInUse") .And. TRepInUse() 
 	pergunte("HSPR19",.F.)
  oReport := ReportDef() 
  oReport:PrintDialog()  
 ELSE  
  HSPAHR19R3()  
 EndIf    
Return(Nil)     


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณREPORTDEF ณ Autor ณ Antonio Carlos        ณ Data ณ 10/08/06 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function ReportDef()
 Local oReport 
 Local oSection1, oSection2, oSection3, oSection4, oSection5
 Local oCell
 Local oTotaliz1,oTotaliz2,oTotaliz3,oTotaliz4

 oReport := TReport():New("HSPAHR19",STR0003,"HSPR19",{|oReport| R19IMP(oReport)}, STR0001 + STR0002 + STR0003) 
 //###"Atendimentos por Perํodo"### "Este programa tem como objetivo imprimir relatorio" ### "de acordo com os parametros informados pelo usuario."
 
 oReport:SetPortrait() // Imprimir relatorio em formato retrato

 oSection1 := TRSection():New(oReport, STR0016, {"GCS"}) //"Setor"
 oSection1:SetHeaderBreak(.F.)
 oSection1:SetPageBreak(.T.)
 oCell := TRCell():New(oSection1, "GCS_NOMLOC", "GCS", STR0015) //"Setor:"

 oSection2 := TRSection():New(oSection1, STR0022, {"GCY"}) //"Tipo de Atendimento"
 oSection2:SetHeaderPage(.F.)
 oSection2:SetHeaderBreak(.F.)
 //oCell := TRCell():New(oSection2, "GCY_ATENDI", "GCY", STR0022) //"Tipo de Atendimento"  
 oCell := TRCell():New(oSection2, "cDesTipAtd", " ", STR0022,,30,,{|| IIF(("QRYR19")->GCY_ATENDI == "0",STR0007,IIF(("QRYR19")->GCY_ATENDI == "1", STR0008, STR0009))}) //"Tipo de Atendimento"
                                                                                                                 
 oSection3 := TRSection():New(oSection2, STR0023, {"GA9"}) //"Conv๊nio"
 oSection3:SetHeaderPage(.T.)
 oSection3:SetHeaderBreak(.F.)
 oCell := TRCell():New(oSection3,"GA9_NREDUZ","GA9","",,20)
 
 oSection4 := TRSection():New(oSection3, STR0024, {"GCY","SRA"}) //"Data"
 oSection4:SetHeaderBreak(.T.)    //Define se cabecalho das celulas sera impresso apos quebra TRBreak.
 oSection4:SetPageBreak(.F.)
 oSection4:SetHeaderSection(.T.)  //Define se cabecalho da celula sera impresso na quebra da secao.
 oSection4:SetReadOnly(.F.)
 oSection4:SetHeaderPage(.T.)
 oSection4:Hide()                 // esconde a celula no relat๓rio s๓ para fazer a quebra.
 oCell := TRCell():New(oSection4,"GCY_DATATE","GCY"," ")       
                                                                                                                 
 oSection5 := TRSection():New(oSection4,STR0025,{"GCY","GBH"}) //"Atendimentos"
 oSection5:SetHeaderPage(.T.)
 oSection5:SetHeaderBreak(.F.)
 oCell := TRCell():New(oSection5,"GCY_DATATE","GCY",STR0024)   //"Data"
 oCell := TRCell():New(oSection5,"GCY_HORATE","GCY",STR0026)   //"Hora"
 oCell := TRCell():New(oSection5,"GBH_NOME"  ,"GBH",STR0027)   //"Nome"
 oCell := TRCell():New(oSection5,"GCY_REGATE","GCY","",,6) 
 oCell := TRCell():New(oSection5,"GCY_ATENDE","GCY",STR0028)   //"Usuแrio"

 DEFINE FUNCTION FROM oSection5:Cell("GCY_DATATE") OF oSection1 FUNCTION COUNT TITLE STR0020 NO END REPORT //" Total do Setor    ===> "
 DEFINE FUNCTION FROM oSection5:Cell("GCY_DATATE") OF oSection2 FUNCTION COUNT TITLE STR0021 NO END REPORT //" Total Atendimento ===> "
 DEFINE FUNCTION FROM oSection5:Cell("GCY_DATATE") OF oSection3 FUNCTION COUNT TITLE STR0019 NO END REPORT //" Total do Conv๊nio ===> "
 DEFINE FUNCTION FROM oSection5:Cell("GCY_DATATE") OF oSection4 FUNCTION COUNT TITLE STR0029 NO END REPORT //" Total do Dia ===>      "
 
 oTot :=  TRFunction():new(oSection5:Cell("GCY_DATATE"),,"COUNT",,STR0015,,,.F.,.T.,.F.) //""Total Geral"

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ TRFunction:  Classe que instancia totalizadores de quebra, secoes ou relatorios.                                                                        ณ
 //ณ Parametros para o construtor inicializar as variaveis de instancia :                                                                                    ณ
 //ณ (oSec:Cell("campo"),/*cVarTemp*/,/*FUNCAO*/,/*oBreak*/,/*cTit*/,/*cPict*/,/*uForm*/,.F./*lEndSect*/,.F./*lEndRep*/,.F./*lEndPage*/,oSection,condition)  ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

Return(oReport)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณR19Imp    ณ Autor ณ Antonio Carlos        ณ Data ณ 08/08/06 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function R19IMP(oReport)

 Local oSection1 := oReport:Section(1)
 Local oSection2 := oReport:Section(1):Section(1)
 Local oSection3 := oReport:Section(1):Section(1):Section(1)
 Local oSection4 := oReport:Section(1):Section(1):Section(1):Section(1)
 Local oSection5 := oReport:Section(1):Section(1):Section(1):Section(1):Section(1)

 Local cCond1:= "%%"
 Local cCond2:= "%%"
 Local cCond3 := "%%"

 //-- Transforma parametros Range em expressao SQL
 MakeSqlExpr(oReport:uParam)                      
 
 oSection1:BeginQuery()

If MV_PAR09 == 1
 cCond1 := "%GCY.GCY_ATENDI = '0'%"
ElseIf MV_PAR09 == 2
 cCond1 := "%GCY.GCY_ATENDI = '1'%"
ElseIf MV_PAR09 == 3
 cCond1 := "%GCY.GCY_ATENDI = '2'%"
Else
 cCond1 := "%GCY.GCY_ATENDI IN ('0', '1', '2')%"
EndIf

If MV_PAR10 == 1
 cCond2 := "%GCS_NOMLOC, GCY_ATENDI, GA9_NREDUZ, GCY_DATATE, GBH_NOME%"
Else
 cCond2 := "%GCS_NOMLOC, GCY_ATENDI, GA9_NREDUZ, GCY_DATATE, GCY_HORATE%"
EndIf

cCond3 := "% GCZ.GCZ_NRSEQG = ( SELECT MIN( GCZ_NRSEQG ) "  
cCond3 += "                       FROM " + RetSqlName("GCZ") + " GUIA "
cCond3 += "                      WHERE GUIA.GCZ_FILIAL = GCZ.GCZ_FILIAL 
cCond3 += "                        AND GUIA.D_E_L_E_T_ <> '*' "   
cCond3 += "                        AND GUIA.GCZ_REGATE = GCZ.GCZ_REGATE) %"

BeginSql alias "QRYR19"
 SELECT GCY_CODLOC, GCS_NOMLOC, GCY_ATENDI, GA9_NREDUZ, GCY_DATATE, GCY_HORATE, GBH_NOME, GCY_REGATE, GCY_ATENDE
   FROM %table:GCY% GCY
        JOIN %table:GCZ% GCZ ON GCZ.GCZ_REGATE = GCY.GCY_REGATE AND GCZ.GCZ_FILIAL = %xFilial:GCZ% AND GCZ.%NotDel%
        JOIN %table:GCS% GCS ON GCS.GCS_CODLOC = GCY.GCY_CODLOC AND GCS.GCS_FILIAL = %xFilial:GCS% AND GCS.%NotDel%
        JOIN %table:GA9% GA9 ON GA9.GA9_CODCON = GCZ.GCZ_CODCON AND GA9.GA9_FILIAL = %xFilial:GA9% AND GA9.%NotDel%
        JOIN %table:GBH% GBH ON GBH.GBH_CODPAC = GCY.GCY_REGGER AND GBH.GBH_FILIAL = %xFilial:GBH% AND GBH.%NotDel%
   WHERE GCY.GCY_FILIAL = %xFilial:GCY% AND GCY.%NotDel%
        AND %Exp:cCond1% 
        AND GCY.GCY_TPALTA <> '99' 
        AND GCY.GCY_CODLOC BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02% 
        AND GCY.GCY_DATATE BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
        AND GCZ.GCZ_CODCON BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06% 
        AND GCY.GCY_ATENDE BETWEEN %Exp:MV_PAR07% AND %Exp:MV_PAR08%
        AND %Exp:cCond3%
   ORDER BY %Exp:cCond2%
EndSql

	oSection1:EndQuery()
	oSection2:SetParentQuery()
	oSection2:SetParentFilter( {|G| ("QRYR19")->GCS_NOMLOC == G }, {|| ("QRYR19")->GCS_NOMLOC}) // Quebra P/Setor
	oSection3:SetParentQuery()                                                              // Quebra P/Tipo Atendimento
	oSection3:SetParentFilter( {|G| ("QRYR19")->GCY_ATENDI + ("QRYR19")->GCS_NOMLOC == G }, {|| ("QRYR19")->GCY_ATENDI + ("QRYR19")->GCS_NOMLOC})
 oSection4:SetParentQuery()
	oSection4:SetParentFilter( {|G| ("QRYR19")->GA9_NREDUZ + ("QRYR19")->GCY_ATENDI + ("QRYR19")->GCS_NOMLOC == G }, {||("QRYR19")->GA9_NREDUZ + ("QRYR19")->GCY_ATENDI + ("QRYR19")->GCS_NOMLOC})
 oSection5:SetParentQuery()
	oSection5:SetParentFilter( {|G| DTOC(("QRYR19")->GCY_DATATE) + ("QRYR19")->GA9_NREDUZ + ("QRYR19")->GCY_ATENDI + ("QRYR19")->GCS_NOMLOC == G }, {|| DTOC(("QRYR19")->GCY_DATATE) + ("QRYR19")->GA9_NREDUZ + ("QRYR19")->GCY_ATENDI + ("QRYR19")->GCS_NOMLOC})

 oSection1:Print() // processa as informacoes da tabela principal
 oReport:SetMeter(QRYR19->(LastRec()))
 
Return( NIL )


/*/             
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHR19 บ Autor ณ Cibele Peria       บ Data ณ  30/03/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio de Atendimentos por periodo                      บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHR19R3()

 Local cDesc1 := STR0001 //"Este programa tem como objetivo imprimir relatorio "
 Local cDesc2 := STR0002 //"de acordo com os parametros informados pelo usuario."
 Local cDesc3 := STR0003 //"Atendimentos por Perํodo"
 Local aOrd   := {}
 
 Private Titulo      := cDesc3
 Private Cabec1      := STR0004 //"Data       Hora   Nome                                           Usuario"
 Private Cabec2      := ""
 Private lEnd        := .F.
 Private lAbortPrint := .F.
 Private limite      := 80
 Private Tamanho     := "P"
 Private NomeProg    := "HSPAHR19" // Coloque aqui o nome do programa para impressao no cabecalho
 Private nTipo       := 18
 Private aReturn     := {STR0005, 1, STR0006, 2, 2, 1, "", 1} //"Zebrado"###"Administra็ใo"
 Private nLastKey    := 0
 Private cbtxt       := Space(10)
 Private cbcont      := 00
 Private CONTFL      := 01
 Private m_pag       := 01
 Private wnrel       := NomeProg
 Private nTam        := 80 
 Private cCodLoc_De  := "", cCodLoc_Ate := "", dDatAte_De  := "", dDatAte_Ate := ""
 Private cCodCon_De  := "", cCodCon_Ate := "", cAtende_De  := "", cAtende_Ate := ""
 Private nTipAte     := 0 , nClassf     := 0
 Private cCODIMP     := ""
 Private nMaxLin     := 0 // quantidade maxima de linhas p/ impressao
 Private nLin
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ PARAMETROS                                                         ณ
 //ณ MV_PAR01	Do setor                                                ณ
 //ณ MV_PAR02	Ate o setor                                             ณ
 //ณ MV_PAR03	Da data                                                 ณ
 //ณ MV_PAR04	Ate a data                                              ณ
 //ณ MV_PAR05	Do convenio                                             ณ
 //ณ MV_PAR06	Ate o convenio                                          ณ
 //ณ MV_PAR07	Do usuario                                              ณ
 //ณ MV_PAR08	Ate o usuario                                           ณ
 //ณ MV_PAR09	Tipo de atendimento                                     ณ
 //ณ MV_PAR10	Classificacao do relatorio                              ณ 
 //| MV_PAR11 Impressora ?                                              |
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 cPerg := "HSPR19"
 If !Pergunte(cPerg, .T.)
  Return
 EndIf
 
 nMaxLin := HS_MaxLin(cCODIMP)

 cCodLoc_De  := mv_par01
 cCodLoc_Ate := mv_par02
 dDatAte_De  := mv_par03
 dDatAte_Ate := mv_par04
 cCodCon_De  := mv_par05
 cCodCon_Ate := mv_par06 
 cAtende_De  := mv_par07
 cAtende_Ate := mv_par08
 nTipAte     := mv_par09
 nClassf     := mv_par10

 wnrel := SetPrint("GCY", NomeProg, "", @Titulo, cDesc1, cDesc2, cDesc3, .T., aOrd, .T., Tamanho, , .T.)
 If nLastKey == 27
  Return()
 Endif
 SetDefault(aReturn, "GCY")
 If nLastKey == 27
  Return()
 Endif

 nTipo := If(aReturn[4] == 1, 15, 18)
 RptStatus({|| RunReport(Cabec1, Cabec2, Titulo, nLin)}, Titulo)
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ Cibele Peria       บ Data ณ  30/03/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Rotina de execucao do relatorio                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function RunReport()

 Local cSql := "", nLin := nMaxLin * 2
 
 Private dDatAte := "", cAtendi := "", cNomCon:= "", cNomLoc := ""
 Private nTotDia := 0, nTotCon := 0, nTotAte := 0, nTotLoc := 0, nToTGer := 0

 cSQL := "SELECT GCS.GCS_NOMLOC, GCY.GCY_ATENDI, GA9.GA9_NREDUZ, GCY.GCY_DATATE, GCY.GCY_HORATE, GBH.GBH_NOME, GCY.GCY_REGATE, GCY.GCY_ATENDE"
 cSQL += " FROM " + RetSQLName("GCY") + " GCY"
 cSQL += " JOIN " + RetSQLName("GCZ") + " GCZ "
 cSQL += "   ON GCZ.GCZ_REGATE = GCY.GCY_REGATE AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GCS") + " GCS "
 cSQL += "   ON GCS.GCS_CODLOC = GCY.GCY_CODLOC AND GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' " 
 cSQL += " JOIN " + RetSQLName("GA9") + " GA9 "
 cSQL += "   ON GA9.GA9_CODCON = GCZ.GCZ_CODCON AND GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GBH") + " GBH "
 cSQL += "   ON GBH.GBH_CODPAC = GCY.GCY_REGGER AND GBH.GBH_FILIAL = '" + xFilial("GBH") + "' AND GBH.D_E_L_E_T_ <> '*' "
 cSQL += " WHERE GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "
 
 If !Empty(nTipAte)
  If nTipAte == 1
   cSQL += " AND GCY.GCY_ATENDI = '0' "
  ElseIf nTipAte == 2
   cSQL += " AND GCY.GCY_ATENDI = '1' "
  ElseIf nTipAte == 3
   cSQL += " AND GCY.GCY_ATENDI = '2' "   
  ElseIf nTipAte == 4
   cSQL += " AND GCY.GCY_ATENDI IN ('0', '1', '2') "      
  EndIf
 EndIf  
 cSQL += " AND GCY.GCY_TPALTA <> '99' "
 cSQL += " AND GCY.GCY_CODLOC BETWEEN '" + cCodLoc_De + "' AND '" + cCodLoc_Ate + "'"
 cSQL += " AND GCY.GCY_DATATE BETWEEN '" + DTOS(dDatAte_De) + "' AND '" + DTOS(dDatAte_Ate) + "'"
 cSQL += " AND GCZ.GCZ_CODCON BETWEEN '" + cCodCon_De + "' AND '" + cCodCon_Ate + "'"
 cSQL += " AND GCY.GCY_ATENDE BETWEEN '" + cAtende_De + "' AND '" + cAtende_Ate + "'"
 
 cSQL += " AND GCZ.GCZ_NRSEQG = ( SELECT MIN( GCZ_NRSEQG ) "  
 cSQL += "                          FROM " + RetSqlName("GCZ") + " GUIA "
 cSQL += "                        WHERE GUIA.GCZ_FILIAL = GCZ.GCZ_FILIAL 
 cSQL += "                          AND GUIA.D_E_L_E_T_ <> '*' "   
 cSQL += "                          AND GUIA.GCZ_REGATE = GCZ.GCZ_REGATE) "
 
 If nClassf == 1
  cSQL += "ORDER BY GCS.GCS_NOMLOC, GCY.GCY_ATENDI, GA9.GA9_NREDUZ, GCY.GCY_DATATE, GBH.GBH_NOME"
 Else
  cSQL += "ORDER BY GCS.GCS_NOMLOC, GCY.GCY_ATENDI, GA9.GA9_NREDUZ, GCY.GCY_DATATE, GCY.GCY_HORATE"
 Endif  

 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")
 DbGoTop()
                                
 If Eof()
  HS_MsgInf(STR0010, STR0018, STR0003) //"Nenhum dado foi encontrado para a sele็ใo efetuada."###"Aten็ใo"###"Atendimentos por Perํodo"
 Endif
  
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 SetRegua(RecCount())
 While !EOF()                                                                                
  IncRegua()
  //Totais
  If QRY->GCS_NOMLOC <> cNomLoc
   nLin := FS_Quebra(4, nLin)
  ElseIf QRY->GCY_ATENDI <> cAtendi
   nLin := FS_Quebra(3, nLin)
  ElseIf QRY->GA9_NREDUZ <> cNomCon
   nLin := FS_Quebra(2, nLin)
  ElseIf QRY->GCY_DATATE <> dDatAte
   nLin := FS_Quebra(1, nLin)
  Endif

  // Linha detalhe
  If nLin+1 > nMaxLin
   nLin := FS_Cabec(0, nLin+1)
  Endif   
  nLin += 1
  @nLin, 000 PSAY DTOC(STOD(QRY->GCY_DATATE))
  @nLin, 011 PSAY QRY->GCY_HORATE
  @nLin, 017 PSAY QRY->GBH_NOME
  @nLin, 058 PSAY QRY->GCY_REGATE
  @nLin, 065 PSAY QRY->GCY_ATENDE
  dDatAte := QRY->GCY_DATATE
  nTotDia += 1
  DbSkip()
 End 
 FS_Quebra(5, nLin)
 
 SET DEVICE TO SCREEN
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Se impressao em disco, chama o gerenciador de impressao...          ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 If aReturn[5] == 1
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
ฑฑบFuno    ณFS_Quebra บ Autor ณ Cibele Peria       บ Data ณ  29/03/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Rotina de Totais                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_Quebra(nQual, nLin)
 Local nForCab := 0
 
 // Impressao dos totais da quebra anterior
  If nQual >= 1 .and. nTotDia > 0
  nLin := FS_Total(nQual, STR0011, nTotDia, nLin) //"Total do Dia"
  nTotCon += nTotDia
  ntotDia := 0
 Endif
 If nQual >= 2 .and. nTotCon > 0
  nLin := FS_Total(nQual, STR0012, nTotCon, nLin) //"Total do Conv๊nio"
  nTotAte += nTotCon
  nTotCon := 0
  cNomCon := QRY->GA9_NREDUZ
 Endif
 If nQual >= 3 .and. nTotAte > 0
  nLin := FS_Total(nQual, STR0013, nTotAte, nLin) //"Total do Atendimento"
  nTotLoc += nTotAte
  nTotAte := 0
  cAtendi := QRY->GCY_ATENDI
 Endif 
 If nQual >= 4 .and. nTotLoc > 0
  nLin := FS_Total(nQual, STR0014, nTotLoc, nLin) //"Total do Setor"
  nTotGer += nTotLoc
  nTotLoc := 0
  cNomLoc := QRY->GCS_NOMLOC
 Endif
 If nQual == 5 .and. nTotGer > 0
  nLin := FS_Total(nQual, STR0015, nTotGer, nLin) //"Total Geral"
 Endif
 
 If nQual > 1 .and. nQual < 5 // nQual == 2, 3 ou 4 (quebras que tem cabecalho)
  For nForCab := nQual to 2 Step -1
   nLin := FS_Cabec(nForCab, nLin)
  Next nForCab
 Endif
 
Return(nLin)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_Cabec  บ Autor ณ Cibele Peria       บ Data ณ  29/03/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Cabecalho do relatorio                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_Cabec(nQual, nLin)
 
 If nQual == 4 .or. nLin > nMaxLin
  Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo, ,.T.)
  nLin := 7
 Endif
 
 If nQual == 4    //Quebra de setor
  nLin += 1
  @nLin, 0000 PSAY STR0016 + QRY->GCS_NOMLOC //"Setor: "
  cNomLoc := QRY->GCS_NOMLOC
 ElseIf nQual == 3  // Quebra de Atendimento
  nLin += 2
  @nLin, 000 PSAY STR0017	+ IF(QRY->GCY_ATENDI == "0", STR0007, IIF(QRY->GCY_ATENDI == "1", STR0008, STR0009)) //"Tipo de Atendimento: "###"Interna็ใo"###"Ambulat๓rio"###"Pronto Atendimento"
  cAtendi := QRY->GCY_ATENDI
 ElseIf nQual == 2  //Quebra de convenio
  nLin += 2 
  @nLin, 000 PSAY QRY->GA9_NREDUZ
  cNomCon := QRY->GA9_NREDUZ
 Endif 
  
Return(nLin)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_Total  บ Autor ณ Cibele Peria       บ Data ณ  29/03/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Rotina de Totais                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_Total(nQual, cTotal, nTotal, nLin)

 If nLin + 1 > nMaxLin
  nLin := FS_Cabec(nQual, nLin)
 Endif
 nLin += 1

 @nLin, 000 PSAY cTotal
 @nLin, 030 PSAY TRANSFORM(nTotal, "9999,999")
 nLin += 1

Return(nLin)