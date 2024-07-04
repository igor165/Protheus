#INCLUDE "HSPAHRDM.ch"
#Include "protheus.ch"
#include "TopConn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHRDM บ Autor ณ Cibele Peria       บ Data ณ  19/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio de Orcamentos por periodo                        บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑบAltera็๕esณ L.Gustavo Caloi 28/03/06 -> Padroniza็ใo da HS_MsgInf()    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHRDM()

 Local cDesc1 := STR0001 //"Este programa tem como objetivo imprimir relatorio "
 Local cDesc2 := STR0002 //"de acordo com os parametros informados pelo usuario."
 Local cDesc3 := STR0003 //"Relatorio de orcamentos por periodo"
 Local aOrd   := {}
 Private Titulo := cDesc3
 Private Cabec1 := STR0004 //"Numero Data    Paciente                               Plano               Atd  Materiais Medicamtos  Taxas/Dia   Procedim.      Total"
 //                  0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.
 Private Cabec2 := ""
 Private lEnd        := .F.
 Private lAbortPrint := .F.
 Private limite      := 132
 Private Tamanho     := "M"
 Private NomeProg    := "HSPAHRDM" // Coloque aqui o nome do programa para impressao no cabecalho
 Private nTipo       := 18
 Private aReturn     := { "Zebrado", 1, STR0005, 2, 2, 1, "", 1} //"Administracao"
 Private nLastKey    := 0
 Private cbtxt       := Space(10)
 Private cbcont      := 00
 Private CONTFL      := 01
 Private m_pag       := 01
 Private wnrel       := NomeProg
 Private nTam        := 132

 Private dDatOrc_De  := ""
 Private dDatOrc_Ate := ""
 Private nStatus     := 0
 Private nImpDes     := 0
 Private nclassif    := 0

 Private cCODIMP := ""
 Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ PARAMETROS                                                         ณ
 //ณ MV_PAR01	Data de orcamento - inicial                               ณ
 //ณ MV_PAR02	Data de orcamento - final                                 ณ
 //ณ MV_PAR03	Status do orcamento                                       ณ
 //ณ MV_PAR04	Imprime Despesas - S/N                                    ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 cPerg := "HSPRDM"
 If !Pergunte(cPerg,.T.)
  return
 EndIf

 nMaxLin := HS_MaxLin(cCODIMP)

 dDatOrc_De  := mv_par01
 dDatOrc_Ate := mv_par02
 nStatus     := mv_par03
 nImpDes     := mv_par04 
 nClassif    := mv_par05
 
 wnrel := SetPrint("GO0", NomeProg, "", @Titulo, cDesc1, cDesc2, cDesc3, .T., aOrd, .T., Tamanho, , .T.)
 If nLastKey == 27
  Return()
 Endif

 SetDefault(aReturn, "GO0")
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
ฑฑบFuno    ณRUNREPORT บ Autor ณ Cibele Peria       บ Data ณ  19/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Rotina de execucao do relatorio                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function RunReport()
 Local   cSql    := ""
 Private nLin    := nMaxLin * 2
 Private cCodLoc := ""

 cSQL := "SELECT GO0.GO0_NUMORC, GO0.GO0_ATENDI, GO0.GO0_DATPRE, GO0.GO0_HORPRE, GO0.GO0_DATORC, "
 cSQL += "GO0.GO0_REGGER, GO0.GO0_CODPLA, GO0.GO0_VALMAT, GO0.GO0_VALMED, GO0.GO0_VALTXD, GO0.GO0_VALPRO, GO0.GO0_VALTOT, "
 cSQL += "GBH.GBH_NOME, GCM_DESPLA "
 cSQL += "FROM " + RetSQLName("GO0") + " GO0 "
 cSQL += "JOIN " + RetSQLName("GBH") + " GBH ON GBH.GBH_CODPAC = GO0.GO0_REGGER "
 cSQL += "JOIN " + RetSQLName("GCM") + " GCM ON GCM.GCM_CODPLA = GO0.GO0_CODPLA "
 cSQL += "WHERE GO0.GO0_FILIAL = '" + xFilial("GO0") + "' AND GO0.D_E_L_E_T_ <> '*' " 
 cSQL += " AND GBH.GBH_FILIAL = '" + xFilial("GBH") + "' AND GBH.D_E_L_E_T_ <> '*' "
 cSQL += " AND GCM.GCM_FILIAL = '" + xFilial("GCM") + "' AND GCM.D_E_L_E_T_ <> '*' "
 cSQL += " AND GO0_DATORC BETWEEN '" + DTOS(dDatOrc_De) + "' AND '" + DTOS(dDatOrc_Ate) + "' "
 If nStatus == 1
  cSQL += " AND GO0_STATUS = '0' "
 ElseIf nStatus == 2 
  cSQL += " AND GO0_STATUS = '1' "
 ElseIf nStatus == 3
  cSQL += " AND GO0_STATUS = '2' "  
 Endif
  
 If nClassif == 1
  cSQL += "ORDER BY GO0.GO0_NUMORC"
 ElseIf nClassif == 2
  cSQL += "ORDER BY GO0.GO0_DATORC, GO0.GO0_NUMORC"
 ElseIf nClassif == 3
  cSQL += "ORDER BY GBH.GBH_NOME, GO0.GO0_NUMORC"
 ElseIf nClassif == 4
  cSQL += "ORDER BY GO0.GO0_STATUS, GO0.GO0_NUMORC"
 Else 
  cSQL += "ORDER BY GCS.GO0_ATENDI, GO0.GO0_NUMORC" 
 Endif  

 cSQL := ChangeQuery(cSQL)
 
 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")
 If Eof()
  HS_MsgInf(STR0006, STR0028, STR0029) //"Nenhum dado foi encontrado para a selecao efetuada.###"Aten็ใo"###"Rotina de execucao do relatorio"
  DbCloseArea()
  Return()
 Endif
 
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 SetRegua(1000)
 DbGoTop()
 While !EOF()                                                                                
  IncRegua()

  If nLin+1 > nMaxLin
   FS_Cabec()
  Endif
  nLin += 1
  @nLin, 000 PSAY QRY->GO0_NUMORC
  @nLin, 007 PSAY STOD(QRY->GO0_DATORC)
  @nLin, 016 PSAY QRY->GO0_REGGER + "-"
  @nLin, 023 PSAY SUBSTR(QRY->GBH_NOME, 1, 30)
  @nLin, 054 PSAY SUBSTR(QRY->GCM_DESPLA,1, 19)
  @nLin, 074 PSAY IIF(QRY->GO0_ATENDI=="0", STR0007, IIF(QRY->GO0_ATENDI=="1", STR0008, STR0009)) //"INT"###"AMB"###"PAT"
  @nLin, 078 PSAY TRANSFORM(QRY->GO0_VALMAT, "@E 999,999.99")
  @nLin, 089 PSAY TRANSFORM(QRY->GO0_VALMED, "@E 999,999.99")
  @nLin, 100 PSAY TRANSFORM(QRY->GO0_VALTXD, "@E 999,999.99")
  @nLin, 111 PSAY TRANSFORM(QRY->GO0_VALPRO, "@E 999,999.99")
  @nLin, 122 PSAY TRANSFORM(QRY->GO0_VALTOT, "@E 999,999.99")
  
  If nImpDes == 1
   FS_ImpDes(QRY->GO0_NUMORC)
   @nLin, 000 PSAY REPLICATE("-", 132)
   cCodLoc := ""  
  Endif
  
  DbSelectArea("QRY")
  DbSkip()
 End  
 DbCloseArea()
  
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
ฑฑบFuno    ณFS_Cabec  บ Autor ณ Cibele Peria       บ Data ณ  19/05/05   บฑฑ
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
 nLin := 7
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_ImpDes บ Autor ณ Cibele Peria       บ Data ณ  19/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Impressao das despesas do orcamento                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_ImpDes(cNumOrc)
 Local cSQL := ""
 Local cAliasOld := Alias()
 
 cSQL := "SELECT "
 cSQL += "'GO5' AS TIPO, GO5.GO5_ITEM AS ITEM, GO5.GO5_CODDES AS CODDES, GO5.GO5_CODLOC AS CODLOC, GO5.GO5_VALDES AS VALDES, "
 cSQL += "SB1.B1_DESC AS DESCRICAO, GCS.GCS_NOMLOC AS NOMLOC "
 cSQL += "FROM " + RetSQLName("GO5") + " GO5 "
 cSQL += "JOIN " + RetSQLName("SB1") + " SB1 ON SB1.B1_COD = GO5.GO5_CODDES "
 cSQL += "JOIN " + RetSQLName("GCS") + " GCS ON GCS.GCS_CODLOC = GO5.GO5_CODLOC "
 cSQL += "WHERE GO5.GO5_FILIAL = '" + xFilial("GO5") + "' AND GO5.D_E_L_E_T_ <> '*' "
 cSQL += " AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.D_E_L_E_T_ <> '*' "  
 cSQL += " AND GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' "
 cSQL += " AND GO5.GO5_NUMORC = '" + cNumOrc + "' "
 cSQL += "UNION "
 cSQL += "SELECT "
 cSQL += "'GO6' AS TIPO, GO6.GO6_ITEM AS ITEM, GO6.GO6_CODDES AS CODDES, GO6.GO6_CODLOC AS CODLOC, GO6.GO6_VALDES AS VALDES, "
 cSQL += "GAA.GAA_DESC AS DESCRICAO, GCS.GCS_NOMLOC AS NOMLOC "
 cSQL += "FROM " + RetSQLName("GO6") + " GO6 "
 cSQL += "JOIN " + RetSQLName("GAA") + " GAA ON GAA.GAA_CODTXD = GO6.GO6_CODDES "
 cSQL += "JOIN " + RetSQLName("GCS") + " GCS ON GCS.GCS_CODLOC = GO6.GO6_CODLOC "
 cSQL += "WHERE GO6.GO6_FILIAL = '" + xFilial("GO6") + "' AND GO6.D_E_L_E_T_ <> '*' "
 cSQL += " AND GAA.GAA_FILIAL = '" + xFilial("GAA") + "' AND GAA.D_E_L_E_T_ <> '*' "
 cSQL += " AND GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' "
 cSQL += " AND GO6.GO6_NUMORC = '" + cNumOrc + "' "
 cSQL += "UNION "
 cSQL += "SELECT "
 cSQL += "'GO7' AS TIPO, GO7.GO7_ITEM AS ITEM, GO7.GO7_CODDES AS CODDES, GO7.GO7_CODLOC AS CODLOC, GO7.GO7_VALDES AS VALDES, "
 cSQL += "GA7.GA7_DESC AS DESCRICAO, GCS.GCS_NOMLOC AS NOMLOC "
 cSQL += "FROM " + RetSQLName("GO7") + " GO7 "
 cSQL += "JOIN " + RetSQLName("GA7") + " GA7 ON GA7.GA7_CODPRO = GO7.GO7_CODDES "
 cSQL += "JOIN " + RetSQLName("GCS") + " GCS ON GCS.GCS_CODLOC = GO7.GO7_CODLOC "
 cSQL += "WHERE GO7.GO7_FILIAL = '" + xFilial("GO7") + "' AND GO7.D_E_L_E_T_ <> '*' "
 cSQL += " AND GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' "  
 cSQL += " AND GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' "
 cSQL += " AND GO7.GO7_NUMORC = '" + cNumOrc + "' " 
 cSQL += "ORDER BY CODLOC, DESCRICAO"
 
 cSQL := ChangeQuery(cSQL) 
 
 TCQUERY cSQL NEW ALIAS "DES"
 
 DbSelectArea("DES")
                      
 If Eof()
  If nLin+1 > nMaxLin
   FS_Cabec()
  Endif
  nLin += 1
  @nLin, 007 PSAY STR0010 //"Orcamento sem despesas cadastradas"
 Else
  If nLin+3 > nMaxLin
   FS_Cabec()
  Endif
  nLin += 1
  @nLin, 002 PSAY STR0011   //"Itm"
  @nLin, 006 PSAY STR0013 //"Setor"
  @nLIn, 047 PSAY STR0012 //"Despesa"
  nLin += 1
  @nLin, 002 PSAY "==="
  @nLin, 006 PSAY REPLICATE("=", 40)
  @nLIn, 047 PSAY REPLICATE("=", 31)
 Endif
 
 DbGoTop()
 While !Eof()
  If nLin+1 > nMaxLin
   FS_Cabec()
  Endif
  nLin += 1
  
  @nLin, 002 PSAY DES->ITEM
  If DES->CODLOC <> cCodLoc
   @nLin, 006 PSAY DES->CODLOC
   @nLin, 009 PSAY SUBSTR(DES->NOMLOC, 1, 37)
   cCodLoc := DES->CODLOC
  EndIf 
  @nLIn, 047 PSAY SUBSTR(DES->DESCRICAO, 1, 31)
  
  If DES->TIPO == "GO5"
   If Posicione("GBI", 1, xFilial("GBI")+DES->CODDES,"GBI_TIPO") == "0"
    @nLin, 078 PSAY TRANSFORM(DES->VALDES, "@E 999,999.99")
   Else 
    @nLin, 089 PSAY TRANSFORM(DES->VALDES, "@E 999,999.99")
   Endif
  ElseIf DES->TIPO == "GO6"  
   @nLin, 100 PSAY TRANSFORM(DES->VALDES, "@E 999,999.99")
  Else 
   @nLin, 111 PSAY TRANSFORM(DES->VALDES, "@E 999,999.99")
  Endif 

  DbSkip()
 End

 If nLin+1 <= nMaxLin
  nLin += 1
 Endif
 
 DbCloseArea()
 DbSelectArea(cAliasOld)

Return()