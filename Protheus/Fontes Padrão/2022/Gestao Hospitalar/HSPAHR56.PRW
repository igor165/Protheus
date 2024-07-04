#INCLUDE "HSPAHR56.ch"
#Include "protheus.ch"
#include "TopConn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHR56 บ Autor ณ Monica Y. Miyamoto บ Data ณ  13/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Quadro - Plantใo                                           บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHR56()

 Local cDesc1 := STR0001 //"Este programa tem como objetivo imprimir relatorio "
 Local cDesc2 := STR0002 //"de acordo com os parametros informados pelo usuario."
 Local cDesc3 := STR0003 //"Plantao - Quadro"
 Local aOrd   := {}
 Private Titulo := cDesc3
 Private Cabec1 := STR0004 //"Horario                   Plantonista                     Especialidade"
 //                 0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.
 Private Cabec2 := ""
 Private lEnd        := .F.
 Private lAbortPrint := .F.
 Private limite      := 132
 Private Tamanho     := "M"
 Private NomeProg    := "HSPAHR56" // Coloque aqui o nome do programa para impressao no cabecalho
 Private nTipo       := 18
 Private aReturn     := { STR0005, 1, STR0006, 2, 2, 1, "", 1} // //"Zebrado"###"Administracao"
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
 //ณ MV_PAR01	Da Data ?                                                 ณ
 //ณ MV_PAR02	Ate a Data ?                                              ณ
 //ณ MV_PAR03	Do Setor ?                                                ณ
 //ณ MV_PAR04	Ate Setor ?                                               ณ
 //ณ MV_PAR05	Pula pagina ?                                             ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 cPerg := "HSPR56"
 If !Pergunte(cPerg,.T.)
  return
 EndIf

 nMaxLin := HS_MaxLin(cCODIMP)

 dDatIni  := mv_par01
 dDatFin  := mv_par02
 cSetIni  := mv_par03
 cSetFin  := mv_par04 
 cPulPag  := mv_par05
 
 wnrel := SetPrint("GN4", NomeProg, "", @Titulo, cDesc1, cDesc2, cDesc3, .T., aOrd, .T., Tamanho, , .T.)
 If nLastKey == 27
  Return()
 Endif

 SetDefault(aReturn, "GN4")
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
ฑฑบFuno    ณRUNREPORT บ Autor ณ Monica Y. Miyamoto บ Data ณ  13/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Rotina de execucao do relatorio                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function RunReport()
 Local   cSql    := "", dDataExt :="" , cSetor :=""
 Private nLin    := nMaxLin * 2
 Private cCodLoc := ""

 cSQL := "SELECT GN3.GN3_CODLOC, GCS.GCS_NOMLOC, GN4.GN4_DATINI, GN4.GN4_HORINI, "
 cSQL += " GN4.GN4_DATFIN, GN4.GN4_HORFIN, SRA.RA_NOME, GFR.GFR_DSESPE "
 cSQL += " FROM " + RetSQLName("GN4") + " GN4 "
 cSQL += " JOIN " + RetSQLName("GN3") + " GN3 ON GN4.GN4_NRSEQP = GN3.GN3_NRSEQP AND GN3.GN3_FILIAL = '" + xFilial("GN3") + "' AND GN3.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GBJ") + " GBJ ON GN4.GN4_CODCRM    = GBJ.GBJ_CRM    AND GBJ.GBJ_FILIAL = '" + xFilial("GBJ") + "' AND GBJ.D_E_L_E_T_ <> '*'"
 cSQL += " JOIN " + RetSQLName("GFR") + " GFR ON GBJ.GBJ_ESPEC1 = GFR.GFR_CDESPE AND GFR.GFR_FILIAL = '" + xFilial("GFR") + "' AND GFR.D_E_L_E_T_ <> '*'"
 cSQL += " JOIN " + RetSQLName("GCS") + " GCS ON GCS.GCS_CODLOC = GN3.GN3_CODLOC AND GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*'"
 cSQL += " JOIN " + RetSQLName("SRA") + " SRA ON GN4.GN4_CODCRM    = SRA.RA_CODIGO  AND SRA.RA_FILIAL  = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*'"
 cSQL += " WHERE GN4.GN4_FILIAL = '" + xFilial("GN4") + "' AND GN4.D_E_L_E_T_ <> '*' " 
 If Len(Alltrim(dDatIni)) > 0 .and. Len(Alltrim(dDatFin)) > 0
  cSQL += " AND GN4_DATINI BETWEEN '" + DTOS(dDatIni) + "' AND '" + DTOS(dDatFin) + "' "
 Endif                                                 
 If Len(Alltrim(cSetIni)) > 0 .and. Len(Alltrim(cSetFin)) > 0
  cSQL += " AND GN3.GN3_CODLOC BETWEEN '" + cSetIni + "' AND '" + cSetFin + "' "
 Endif                                                 
 cSQL += " AND GN4_STATUS <> '3' "
 cSQL += " ORDER BY GN3.GN3_CODLOC, GN4.GN4_DATINI, GN4.GN4_DATFIN"

 cSQL := ChangeQuery(cSQL)
 
 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")
 If Eof()
  HS_MsgInf(STR0007, STR0008, STR0009) //"Nenhum dado foi encontrado para a selecao efetuada."###"Aten็ใo"###"Rotina de execucao do relatorio"
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

  If QRY->GN3_CODLOC <> cSetor
     If cPulPag == 1 .and. nLin > 7// SALTA PAGINA POR SETOR
      FS_Cabec()
     Endif
     nLin++
     nLin++
     @nLin, 000 PSAY STR0010  //"SETOR: "
     @nLin, 007 PSAY QRY->GN3_CODLOC
     @nLin, 010 PSAY "-"
     @nLin, 012 PSAY QRY->GCS_NOMLOC
  Endif

  If QRY->GN4_DATINI <> dDATAEXT
     nLin++
     nLin++
     @nLin, 000 PSAY STOD(QRY->GN4_DATINI)
     @nLin, 010 PSAY "(" + HS_SEMANA(DOW(STOD(QRY->GN4_DATINI))) + ")" 
  Endif

  nLin += 1
  @nLin, 000 PSAY QRY->GN4_HORINI + " - "
  @nLin, 009 PSAY STOD(QRY->GN4_DATFIN)
  @nLin, 020 PSAY QRY->GN4_HORFIN 
  @nLin, 026 PSAY QRY->RA_NOME
  @nLin, 058 PSAY QRY->GFR_DSESPE
  
  If nImpDes == 1
   FS_ImpDes(QRY->GO0_NUMORC)
   @nLin, 000 PSAY REPLICATE("-", 132)
   cCodLoc := ""  
  Endif
  
  DbSelectArea("QRY")
  dDATAEXT := QRY->GN4_DATINI
  cSetor   := QRY->GN3_CODLOC
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
ฑฑบFuno    ณFS_Cabec  บ Autor ณ Monica Y. Miyamoto บ Data ณ  13/09/07   บฑฑ
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
 nLin := 6
Return()