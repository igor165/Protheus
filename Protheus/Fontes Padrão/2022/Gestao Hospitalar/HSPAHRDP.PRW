#INCLUDE "HSPAHRDP.ch"
#Include "protheus.ch"
#Include "TopConn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHRDP บ Autor ณ Cibele Peria       บ Data ณ  28/06/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio de Recurso de Glosa                              บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑบAltera็๕esณ L.Gustavo Caloi 28/03/06 -> Padroniza็ใo da HS_MsgInf()    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHRDP()

 Local cDesc1 := STR0001 //"Este programa tem como objetivo imprimir relatorio "
 Local cDesc2 := STR0002 //"de acordo com os parametros informados pelo usuario."
 Local cDesc3 := STR0003 //"Procedimentos por medico"
 Local aOrd   := {}
 Private Titulo := cDesc3
 Private Cabec1 := ""
 Private Cabec2 := STR0004 //"Recurso Data      Status                              Valor    Recup.    Perdido"
//                  0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789 
 Private lEnd        := .F.
 Private lAbortPrint := .F.
 Private limite      := 80
 Private Tamanho     := "P"
 Private NomeProg    := "HSPAHRDP" // Coloque aqui o nome do programa para impressao no cabecalho
 Private nTipo       := 18
 Private aReturn     := { STR0005, 1, STR0006, 2, 2, 1, "", 1} //"Zebrado"###"Administracao"
 Private nLastKey    := 0
 Private cbtxt       := Space(10)
 Private cbcont      := 00
 Private CONTFL      := 01
 Private m_pag       := 01
 Private wnrel       := NomeProg
 Private nTam        := 132 
 
 Private cCodCon_De  := "", cCodCon_Ate := ""
 Private cNumRec_De  := "", cNumRec_Ate := ""
 Private dDatRec_De  := "", dDatRec_Ate := ""
 Private nStatus     := 0
 Private nTipRel     := 0

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ PARAMETROS                                                       ณ
 //ณ MV_PAR01	Do convenio                                             ณ
 //ณ MV_PAR02	Ate o convenio                                          ณ
 //ณ MV_PAR03	Do recurso                                              ณ
 //ณ MV_PAR04	Ate o recurso                                           ณ
 //ณ MV_PAR05	Da data do recurso                                      ณ
 //ณ MV_PAR06	Ate a data do recurso                                   ณ
 //ณ MV_PAR07	Status do recurso                                       ณ
 //ณ MV_PAR08	Tipo (Analitico/ Sintetico)                             ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 If !Pergunte("HSPRDP", .T.)
  return
 EndIf

 cCodCon_De  := mv_par01
 cCodCon_Ate := mv_par02
 cNumRec_De  := mv_par03
 cNumRec_Ate := mv_par04
 dDatRec_De  := mv_par05
 dDatRec_Ate := mv_par06
 nStatus     := mv_par07
 nTipRel     := mv_par08
 
 wnrel := SetPrint("GF0", NomeProg, "", @Titulo, cDesc1, cDesc2, cDesc3, .T., aOrd, .T., Tamanho, , .T.)
 If nLastKey == 27
  Return()
 Endif

 SetDefault(aReturn, "GF0")
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
ฑฑบFuno    ณRUNREPORT บ Autor ณ Cibele Peria       บ Data ณ  28/06/05   บฑฑ
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
 Private nLin    := 99
 Private nMax    := 55
 Private cCodCon := ""
 
 cSQL := "SELECT GA9.GA9_NOME, GF0.GF0_CODCON, GF0.GF0_NUMREC, GF0.GF0_DATREC, GF0.GF0_STATUS, "
 cSQL += "GF0.GF0_VLRECU, GF0.GF0_VALREC, GF0.GF0_VALPER "
 cSQL += "FROM " + RetSQLName("GF0") + " GF0 "
 cSQL += "JOIN " + RetSQLName("GA9") + " GA9 ON GA9.GA9_CODCON = GF0.GF0_CODCON "
 cSQL += "WHERE "
 cSQL += "GF0.GF0_FILIAL = '" + xFilial("GF0") + "' AND GF0.D_E_L_E_T_ <> '*' "
 cSQL += "AND GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*' "
 cSQL += "AND GF0.GF0_CODCON BETWEEN '" + cCodCon_De + "' AND '" + cCodCon_Ate + "' "
 cSQL += "AND GF0.GF0_NUMREC BETWEEN '" + cNumRec_De + "' AND '" + cNumRec_Ate + "' "
 cSQL += "AND GF0.GF0_DATREC BETWEEN '" + DTOS(dDatRec_De) + "' AND '" + DTOS(dDatRec_Ate) + "' "
 If nStatus <> 5
  cSQL += "AND GF0.GF0_STATUS = '" + STR(nStatus, 1) + "' "
 Endif 
 cSQL += "ORDER BY GA9.GA9_NOME, GF0.GF0_NUMREC"
 TCQUERY cSQL NEW ALIAS "QRY"

 DbSelectArea("QRY")
 DbGoTop()
 If Eof()
  HS_MsgInf(STR0007, STR0019, STR0020) //"Nenhum recurso foi encontrado para a selecao efetuada."###"Aten็ใo"###"Rotina de execucao do relatorio"
  DbCloseArea()
  Return()
 Endif 
  
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 SetRegua(1000)
 While !Eof()                                                                                
  IncRegua()
         
  If nLin+1 > nMax .or. QRY->GF0_CODCON <> cCodCon .or. nTipRel == 1
   cCodCon := QRY->GF0_CODCON
   nLin := FS_Cabec()
  Endif

  nLin += 1 
  @nLin, 000 PSAY QRY->GF0_NUMREC
  @nLin, 007 PSAY DTOC(STOD(QRY->GF0_DATREC))
  @nLin, 017 PSAY IIF(QRY->GF0_STATUS=="1", STR0008, ; //"Aberto"
                   IIF(QRY->GF0_STATUS=="2", STR0009, ; //"Associado"
                   IIF(QRY->GF0_STATUS=="3", STR0010, STR0011))) //"Liquidado"###"Quitado"
  @nLin, 049 PSAY TRANSFORM(QRY->GF0_VLRECU, "99,999.99")
  @nLin, 060 PSAY TRANSFORM(QRY->GF0_VALREC, "99,999.99")
  @nLin, 071 PSAY TRANSFORM(QRY->GF0_VALPER, "99,999.99")
  
  If nTipRel == 1 //Analitico
   FS_Dspesas()
  Endif
  
  DbSelectArea("QRY")
  DbSkip()
  
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
ฑฑบFuno    ณFS_Cabec  บ Autor ณ Cibele Peria       บ Data ณ  28/06/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Cabecalho do relatorio                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_Cabec()
 Cabec(Titulo, QRY->GA9_NOME, Cabec2, NomeProg, Tamanho, nTipo, ,.T.) 
Return(8)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_Dspesasบ Autor ณ Cibele Peria       บ Data ณ  28/06/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Impressao das despesas do recurso                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_Dspesas()
 Local cSQL := ""
 
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Selecao das despesas da GF5 - Mat/Med                               ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 cSQL := "SELECT GF5.GF5_CODDES AS CODDES, SB1.B1_DESC AS DESCRI, "
 cSQL += "GF5.GF5_VALAPR AS VALAPR, GF5.GF5_VALREC AS VALREC, GF5.GF5_VALPER AS VALPER "
 cSQL += "FROM " + RetSQLName("GF5") + " GF5 "
 cSQL += "JOIN " + RetSQLName("SB1") + " SB1 ON SB1.B1_COD = GF5.GF5_CODDES "
 cSQL += "WHERE "
 cSQL += "GF5.GF5_FILIAL = '" + xFilial("GF5") + "' AND GF5.D_E_L_E_T_ <> '*' AND "
 cSQL += "SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.D_E_L_E_T_ <> '*' AND " 
 cSQL += "GF5.GF5_NRRECO = '" + QRY->GF0_NUMREC + "' "
 cSQL += "ORDER BY GF5.GF5_CODDES"
 TCQUERY cSQL NEW ALIAS "DES"
 FS_ImpDes(STR0012) //"Mat/Med"
 
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Selecao das despesas da GF5 - Tax/Dia                               ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 cSQL := "SELECT GF6.GF6_CODDES AS CODDES, GAA.GAA_DESC AS DESCRI, "
 cSQL += "GF6.GF6_VALAPR AS VALAPR, GF6.GF6_VALREC AS VALREC, GF6.GF6_VALPER AS VALPER "
 cSQL += "FROM " + RetSQLName("GF6") + " GF6 "
 cSQL += "JOIN " + RetSQLName("GAA") + " GAA ON GAA.GAA_CODTXD = GF6.GF6_CODDES "
 cSQL += "WHERE "
 cSQL += "GF6.GF6_FILIAL = '" + xFilial("GF6") + "' AND GF6.D_E_L_E_T_ <> '*' AND "
 cSQL += "GAA.GAA_FILIAL = '" + xFilial("GAA") + "' AND GAA.D_E_L_E_T_ <> '*' AND " 
 cSQL += "GF6.GF6_NRRECO = '" + QRY->GF0_NUMREC + "' "
 cSQL += "ORDER BY GF6.GF6_CODDES"
 TCQUERY cSQL NEW ALIAS "DES"
 FS_ImpDes(STR0013) //"Tax/Dia"

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Selecao das despesas da GF5 - Pro/Hon                               ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 cSQL := "SELECT GF7.GF7_CODDES AS CODDES, GA7.GA7_DESC AS DESCRI, "
 cSQL += "GF7.GF7_VALAPR AS VALAPR, GF7.GF7_VALREC AS VALREC, GF7.GF7_VALPER AS VALPER "
 cSQL += "FROM " + RetSQLName("GF7") + " GF7 "
 cSQL += "JOIN " + RetSQLName("GA7") + " GA7 ON GA7.GA7_CODPRO = GF7.GF7_CODDES "
 cSQL += "WHERE "
 cSQL += "GF7.GF7_FILIAL = '" + xFilial("GF7") + "' AND GF7.D_E_L_E_T_ <> '*' AND "
 cSQL += "GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' AND " 
 cSQL += "GF7.GF7_NRRECO = '" + QRY->GF0_NUMREC + "' "
 cSQL += "ORDER BY GF7.GF7_CODDES"
 TCQUERY cSQL NEW ALIAS "DES"
 FS_ImpDes(STR0014) //"Pro/Hon"

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_ImpDes บ Autor ณ Cibele Peria       บ Data ณ  28/06/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Impressao das despesas do grupo                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_ImpDes(cDescri)
 Local nDes := 0
 
 DbSelectArea("DES")
 While !Eof()
  nDes += 1
  If nDes == 1
   nLin += 2       
   @nLin, 000 PSAY REPLICATE("=", limite)
   nLin += 1   
   @nLin, 000 PSAY cDescri
   @nLin, 049 PSAY STR0015 //"    Valor"
   @nLin, 060 PSAY STR0016 //"   Recup."
   @nLin, 071 PSAY STR0017 //"  Perdido"
   nLin += 1   
   @nLin, 000 PSAY REPLICATE("=", limite)
  Endif

  If nLin+1 > nMax
   FS_Cabec()
  Endif
  
  nLin += 1 
  @nLin, 000 PSAY SUBSTR(DES->CODDES + " " + DES->DESCRI, 1, 48)
  @nLin, 049 PSAY TRANSFORM(DES->VALAPR, "99,999.99")
  @nLin, 060 PSAY TRANSFORM(DES->VALPER, "99,999.99")
  @nLin, 071 PSAY TRANSFORM(DES->VALAPR, "99,999.99")

  DbSkip()
 End
 If nLin+2 > nMax
  FS_Cabec()
 Endif
 If nDes > 0
  If nLin+2 > nMax
   nLin := FS_Cabec()
  Endif 
  nLin += 2
  @nLin, 010 PSAY STR(nDes) + STR0018 //" despesa(s) impressa(s)"
 Endif 
              
 DbSelectArea("DES")
 DbCloseArea()
 
Return()