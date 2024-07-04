#INCLUDE "HSPAHRDD.ch"
#Include "protheus.ch"
#include "TopConn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHRDD บ Autor ณ Cibele Peria       บ Data ณ  16/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio de Extrato de atendimento                        บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HSPAHRDD()

Local oReport

If FindFunction("TRepInUse") .And. TRepInUse() 
	pergunte("HSPRDD",.F.)
    oReport := ReportDef() 
    oReport:PrintDialog()  
Else  
	HSPAHRDDR3()  
EndIf 

Return Nil 
 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒ
ฒฒฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฒฒ
ฒฒณFuno    ณREPORTDEF ณ Autor ณ Antonio Carlos        ณ Data ณ 25/07/06 ณฒฒ
ฒฒภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฒฒ
ฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function ReportDef()

Local oReport 
Local oSection1, oSection2, oSection3, oSection4
Local oCell
Local oTotaliz1

oReport := TReport():New("HSPAHRDD",STR0003,"HSPRDD",{|oReport| RDDIMP(oReport)}, STR0001 + " " + STR0002 + " " + STR0003)

oSection1 := TRSection():New(oReport,STR0013,{"QRYRDD"})
oSection1:SetHeaderPage(.T.)
oSection1:SetHeaderBreak(.F.) 
oSection1:SetNoFilter({"QRYRDD"})
oCell := TRCell():New(oSection1,"PACIENTE","QRYRDD"," ",,Len(STR0014)+TamSx3("GCY_NOME")[1],,{|| STR0014 + QRYRDD->GCY_NOME }) //"Nome    : "    
 
oSection2 := TRSection():New(oSection1,STR0015,{"QRYRDD","SRA","GCY"})
oSection2:SetHeaderPage(.T.)
oSection2:SetHeaderBreak(.F.)
oSection2:SetNoFilter({"QRYRDD"})
oCell := TRCell():New(oSection2,"cGCY_DATATE","",STR0016,,8,,{ || cGCY_DATATE:=HS_DTOC(QRYRDD->GCY_DATATE,1)})
oCell := TRCell():New(oSection2,"GCY_HORATE","QRYRDD",STR0017)
oCell := TRCell():New(oSection2,"GCY_REGATE","QRYRDD",STR0018)
oCell := TRCell():New(oSection2,"GCY_CODLOC","QRYRDD",STR0019)
oCell := TRCell():New(oSection2,"GCS_NOMLOC","QRYRDD","",,30)
oCell := TRCell():New(oSection2,"cNOMMED","SRA",STR0020,,TamSX3("RA_NOME")[1],,{||HS_INIPADR("SRA",11, QRYRDD->GD7_CODCRM, "RA_NOME",,.F.)}) 
oCell := TRCell():New(oSection2,"GCM_DESPLA","QRYRDD",STR0021)

oSection3 := TRSection():New(oSection2,STR0025,{"QRYRDD"})
oSection3:SetHeaderPage(.T.)
oSection3:SetHeaderBreak(.F.)
oSection3:SetNoFilter({"QRYRDD"})
oCell := TRCell():New(oSection3," "," "," ",,72,,)
oCell := TRCell():New(oSection3,"GA7_DESC","QRYRDD",STR0022,)

oTotaliz1 := TRFunction():new(oSection1:Cell(1),,"COUNT",,STR0023,,,.F.,.F.,.T.)

Return oReport   


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒ
ฒฒฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฒฒ
ฒฒณFuno    ณREPORTDEF ณ Autor ณ Andr้ Cruz            ณ Data ณ 25/07/06 ณฒฒ
ฒฒภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤูฒฒ
ฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒฒ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function RDDIMP(oReport)  

Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(1):Section(1)
Local oSection3 := oReport:Section(1):Section(1):Section(1)

MakeSqlExpr(oReport:uParam)                      
oSection1:BeginQuery()
BeginSql alias "QRYRDD"
   SELECT GCM_DESPLA, GCS_NOMLOC, GCY_CODLOC, GCY_DATATE, GCY_HORATE, GCY_NOME, GCY_REGATE, GCY_REGGER, 
          GCZ_CODPLA, GA7_DESC, GD7_CODCRM, GD7_CODDES 
   FROM %table:GCY% GCY JOIN %table:GCZ% GCZ ON (GCZ.GCZ_REGATE = GCY.GCY_REGATE AND GCY.GCY_FILIAL = %xFilial:GCY% AND GCY.%NotDel% AND GCZ.GCZ_FILIAL = %xFilial:GCZ% AND GCZ.%NotDel%)
                        JOIN %table:GD7% GD7 ON (GD7.GD7_NRSEQG = GCZ.GCZ_NRSEQG AND GD7.GD7_FILIAL = %xFilial:GD7% AND GD7.%NotDel%)
                        JOIN %table:GCS% GCS ON (GCS.GCS_CODLOC = GCY.GCY_CODLOC AND GCS.GCS_FILIAL = %xFilial:GCS% AND GCS.%NotDel%)
                        JOIN %table:GCM% GCM ON (GCM.GCM_CODPLA = GCZ.GCZ_CODPLA AND GCM.GCM_FILIAL = %xFilial:GCM% AND GCM.%NotDel%)
                        JOIN %table:GA7% GA7 ON (GA7.GA7_CODPRO = GD7.GD7_CODDES AND GA7.GA7_FILIAL = %xFilial:GA7% AND GA7.%NotDel%)
   WHERE GCY.GCY_REGGER BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
   AND GCY.GCY_TPALTA <> %Exp:'99'%
   ORDER BY GCY_NOME, GCY_REGATE, GCM_DESPLA, GA7_DESC
EndSql

oSection1:EndQuery()
oSection2:SetParentQuery()
oSection2:SetParentFilter( {|G| ("QRYRDD")->GCY_NOME == G }, {|| ("QRYRDD")->GCY_NOME } )     // Quebra por Paciente
oSection3:SetParentQuery()
oSection3:SetParentFilter( {|G| ("QRYRDD")->GCY_REGATE + ("QRYRDD")->GCY_NOME == G }, {|| ("QRYRDD")->GCY_REGATE + ("QRYRDD")->GCY_NOME } )     // Quebra por Atendimento

oSection1:Print() // processa as informacoes da tabela principal
oReport:SetMeter(QRYRDD->(LastRec())) // Define o total da regua da tela de processamento do relat๓rio.

Return Nil     


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHRDD บ Autor ณ Cibele Peria       บ Data ณ  16/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio de Extrato de atendimento                        บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHRDDR3()

Local cDesc1        := STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2        := STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3        := STR0003 //"Extrato de Atendimento"
Local aOrd          := {}
Local nPacient      := 0
Private Titulo      := cDesc3
Private Cabec1      := STR0004 //"   Data     Hora  Atend. Setor                                       Medico                         Plano"
//                  0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.
Private Cabec2      := "                                                                        Procedimentos Realizados"        
Private lEnd        := .F.
Private lAbortPrint := .F.
Private limite      := 132
Private Tamanho     := "M"
Private NomeProg    := "HSPAHRDD" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo       := 18
Private aReturn     := { STR0005, 1, STR0006, 2, 2, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey    := 0
Private cbtxt       := Space(10)
Private cbcont      := 00
Private CONTFL      := 01
Private m_pag       := 01
Private wnrel       := NomeProg
Private nTam        := 132 
Private cRegGer_De  := "", cRegGer_Ate := ""
Private cCODIMP     := ""
Private nMaxLin     := 0 // quantidade maxima de linhas p/ impressao

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ PARAMETROS                                                         ณ
 //ณ MV_PAR01	Do Paciente                                               ณ
 //ณ MV_PAR02	Ate o Ppaciente                                           ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cPerg := "HSPRDD"
If !Pergunte(cPerg,.T.)
	Return
EndIf

nMaxLin := HS_MaxLin(cCODIMP)

cRegGer_De  := mv_par01
cRegGer_Ate := mv_par02
 
wnrel := SetPrint("", NomeProg, "", @Titulo, cDesc1, cDesc2, cDesc3, .T., aOrd, .T., Tamanho, , .T.)
If nLastKey == 27
	Return()
EndIf

SetDefault(aReturn, "")
If nLastKey == 27
	Return()
EndIf

nTipo := If(aReturn[4]==1,15,18)
RptStatus({|| RunReport("") }, Titulo)

Return(Nil)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ Cibele Peria       บ Data ณ  09/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Rotina de execucao do relatorio                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function RunReport()  

Local cSql      := ""
Local nPacient  := 0
Private nLin    := nMaxLin * 2
Private cRegGer := ""
Private cRegAte := ""
Private cCodCRM := ""
Private cCodPla := ""
 
cSQL := "SELECT "
cSQL += " GCM.GCM_DESPLA, "
cSQL += " GCS.GCS_NOMLOC, "
cSQL += " GCY.GCY_CODLOC, "
cSQL += " GCY.GCY_DATATE, "
cSQL += " GCY.GCY_HORATE, "
cSQL += " GCY.GCY_NOME, "
cSQL += " GCY.GCY_REGATE, "
cSQL += " GCY.GCY_REGGER, "
cSQL += " GCZ.GCZ_CODPLA, "
cSQL += " GA7.GA7_DESC, "
cSQL += " GD7.GD7_CODCRM, "
cSQL += " GD7.GD7_CODDES "
cSQL += "FROM " + RetSQLName("GCY") + " GCY JOIN " + RetSQLName("GCZ") + " GCZ ON (GCZ.GCZ_REGATE = GCY.GCY_REGATE AND GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*')"
cSQL +=                                   " JOIN " + RetSQLName("GD7") + " GD7 ON (GD7.GD7_NRSEQG = GCZ.GCZ_NRSEQG AND GD7.GD7_FILIAL = '" + xFilial("GD7") + "' AND GD7.D_E_L_E_T_ <> '*')"       
cSQL +=                                   " JOIN " + RetSQLName("GCS") + " GCS ON (GCS.GCS_CODLOC = GCY.GCY_CODLOC AND GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*')"
cSQL +=                                   " JOIN " + RetSQLName("GCM") + " GCM ON (GCM.GCM_CODPLA = GCZ.GCZ_CODPLA AND GCM.GCM_FILIAL = '" + xFilial("GCM") + "' AND GCM.D_E_L_E_T_ <> '*')" 
cSQL +=                                   " JOIN " + RetSQLName("GA7") + " GA7 ON (GA7.GA7_CODPRO = GD7.GD7_CODDES AND GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*')"
cSQL += "WHERE "
cSQL += "     GCY.GCY_REGGER BETWEEN '" + cRegGer_De + "' AND '" + cRegGer_Ate + "'"
cSQL += " AND GCY.GCY_TPALTA <> '99' "
cSQL += "ORDER BY GCY.GCY_NOME, GCY.GCY_REGATE, GCM.GCM_DESPLA, GA7.GA7_DESC"
 
cSQL := ChangeQuery(cSQL)
 
TCQUERY cSQL NEW ALIAS "QRY"
DbSelectArea("QRY")
 
DbGoTop()
If Eof()
	HS_MsgInf(STR0007, STR0011, STR0012) //"Nenhum dado foi encontrado para a selecao efetuada."###"Aten็ใo"###"Rotina de execucao do relatorio"
    DbCloseArea()
    Return()
EndIf 
  
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
SetRegua(RecCount())
While !EOF()                                                                                
	IncRegua()
                      
    If QRY->GCY_REGGER <> cRegGer
    	If nLin+2 > nMaxLin
        	FS_Cabec()
            nLin += -1
        EndIf
   		nLin += 2
        @nlin, 000 PSAY STR0008 + QRY->GCY_NOME //"Nome    : "
        cRegGer := QRY->GCY_REGGER
        cRegAte := ""  //forcar a quebra do atendimento
        nPacient++
    EndIf  

	If QRY->GCY_REGATE <> cRegAte .or. QRY->GD7_CODCRM <> cCodCRM .or. QRY->GCZ_CODPLA <> cCodPla
    	If nLin+1 > nMaxLin
        	FS_Cabec()
        EndIf
        nLin += 1
        If QRY->GCY_REGATE <> cRegAte
        	@nLin, 003 PSAY HS_DTOC(STOD(QRY->GCY_DATATE))
            @nLin, 012 PSAY QRY->GCY_HORATE
            @nLin, 018 PSAY QRY->GCY_REGATE
            @nLin, 025 PSAY QRY->GCY_CODLOC
            @nLin, 028 PSAY QRY->GCS_NOMLOC
            cRegAte := QRY->GCY_REGATE     
        EndIf
        @nLin, 069 PSAY HS_IniPadr("SRA",11,QRY->GD7_CODCRM,"RA_NOME",,.F.)
        @nLin, 100 PSAY QRY->GCM_DESPLA
        cCodCRM := QRY->GD7_CODCRM
        cCodPla := QRY->GCZ_CODPLA
    EndIf
 
    If nLin+1 > nMaxLin
    	FS_Cabec()
    EndIf
    nLin += 1
    @nLin, 072 PSAY QRY->GA7_DESC
 
    DbSkip()
End    

 
If nLin+1 > nMaxLin
	FS_Cabec()
EndIf
nLin += 1
@nLin, 000 PSAY STR0023 + Str(nPacient)

SET DEVICE TO SCREEN
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Se impressao em disco, chama o gerenciador de impressao...          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If aReturn[5]==1
	dbCommitAll()
    SET PRINTER TO
    OurSpool(wnrel)
EndIf

MS_FLUSH()
DBCloseArea()

Return()


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_Cabec  บ Autor ณ Cibele Peria       บ Data ณ  16/05/05   บฑฑ
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
nLin := 8

Return()