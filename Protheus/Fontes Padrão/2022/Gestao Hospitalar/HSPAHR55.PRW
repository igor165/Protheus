#INCLUDE "HSPAHR55.ch"
#Include "protheus.ch"
#include "TopConn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHR55 บ Autor ณ Monica Y. Miyamoto บ Data ณ  13/09/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Dados Plantใo                                              บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHR55()

 Local cDesc1 := STR0001 //"Este programa tem como objetivo imprimir relatorio "
 Local cDesc2 := STR0002 //"de acordo com os parametros informados pelo usuario."
 Local cDesc3 := STR0003 //"Plantao - Dados Cadastrais"
 Local aOrd   := {}
 Private Titulo := cDesc3
 Private Cabec1 := STR0004 //"Sequencia  Profissional                            Periodo Inicial  Setor "
 //                 0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.
 Private Cabec2 := STR0005 //"           Profissional Substituido                Periodo Final"
 Private lEnd        := .F.
 Private lAbortPrint := .F.
 Private limite      := 132
 Private Tamanho     := "M"
 Private NomeProg    := "HSPAHR55" // Coloque aqui o nome do programa para impressao no cabecalho
 Private nTipo       := 18
 Private aReturn     := { STR0006, 1, STR0007, 2, 2, 1, "", 1} // //"Zebrado"###"Administracao"
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
 //ณ MV_PAR03	Do Profissional ?                                         ณ
 //ณ MV_PAR04	Ate Profissional ?                                        ณ                                              ณ
 //ณ MV_PAR05	Do Setor ?                                                ณ
 //ณ MV_PAR06	Ate Setor ?                                               ณ
 //ณ MV_PAR07	Tipo ?                                                    ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 cPerg := "HSPR55"
 If !Pergunte(cPerg,.T.)
  return
 EndIf

 nMaxLin := HS_MaxLin(cCODIMP)

 dDatIni  := mv_par01
 dDatFin  := mv_par02
 cProIni  := mv_par03
 cProFin  := mv_par04 
 cSetIni  := mv_par05
 cSetFin  := mv_par06 
 cTipo    := mv_par07
 
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
 Local   cSql    := ""  
 Local   nForR55 := 0 
 Local   cObs    := ""
 Private nLin    := nMaxLin * 2
 Private cCodLoc := "" 
 Private cStatus := "" , cDscSta := ""

 If cTipo == 1
  cDscSta := STR0008 //"INCLUSAO"
 ElseIf cTipo == 2
  cDscSta := STR0009 //"TROCA"
 ElseIf cTipo == 3
  cDscSta := STR0010 //"FALTA"
 ElseIf cTipo == 4
  cDscSta := STR0011 //"CANCELAMENTO"
 ElseIf cTipo == 5
  cDscSta := STR0012 //"GERAL"
 Endif                 


 cSQL := "SELECT GN4.GN4_STATUS, GN4.GN4_NRSEQP, GN4.GN4_NRSEQE, GN4.GN4_CODCRM, GN3.GN3_CODLOC, GCS.GCS_NOMLOC, GN4.GN4_DATINI, GN4.GN4_HORINI, "
 cSQL += " GN4.GN4_DATFIN, GN4.GN4_HORFIN, SRA.RA_NOME, GN4.GN4_PROSUB, GN4.GN4_OBSGER "
 cSQL += " FROM " + RetSQLName("GN4") + " GN4 "
 cSQL += " JOIN " + RetSQLName("GN3") + " GN3 ON GN4.GN4_NRSEQP = GN3.GN3_NRSEQP AND GN3.GN3_FILIAL = '" + xFilial("GN3") + "' AND GN3.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GBJ") + " GBJ ON GN4.GN4_CODCRM    = GBJ.GBJ_CRM    AND GBJ.GBJ_FILIAL = '" + xFilial("GBJ") + "' AND GBJ.D_E_L_E_T_ <> '*'"
 cSQL += " JOIN " + RetSQLName("GCS") + " GCS ON GCS.GCS_CODLOC = GN3.GN3_CODLOC AND GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*'"
 cSQL += " JOIN " + RetSQLName("SRA") + " SRA ON GN4.GN4_CODCRM    = SRA.RA_CODIGO  AND SRA.RA_FILIAL  = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*'"
 cSQL += " WHERE GN4.GN4_FILIAL = '" + xFilial("GN4") + "' AND GN4.D_E_L_E_T_ <> '*' " 
 If !Empty(dDatFin)
  cSQL += " AND GN4.GN4_DATINI BETWEEN '" + DTOS(dDatIni) + "' AND '" + DTOS(dDatFin) + "' "
 Endif                                                 
 If !Empty(cProIni) .and. !Empty(cProFin)
  cSQL += " AND GN4.GN4_CODCRM    BETWEEN '" + cProIni + "' AND '" + cProFin + "' "
 Endif                                                 
 If !Empty(cSetIni) .and. !Empty(cSetFin)
  cSQL += " AND GN3.GN3_CODLOC BETWEEN '" + cSetIni + "' AND '" + cSetFin + "' "
 Endif                                                 
 If cTipo < 5
  cSQL += " AND GN4.GN4_STATUS = '" + AllTrim(str(cTipo-1)) + "'"
 EndIf
 cSQL += " ORDER BY GN4.GN4_STATUS, GN4.GN4_DATINI, GN4.GN4_DATFIN, GN3.GN3_CODLOC, GN4.GN4_CODCRM"

 cSQL := ChangeQuery(cSQL)

 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")
 If Eof()
  HS_MsgInf(STR0013, STR0014, STR0015) //"Nenhum dado foi encontrado para a selecao efetuada."###"Aten็ใo"###"Rotina de execucao do relatorio"
  DbCloseArea()
  Return()
 Endif
 
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

 cStatus:=""
 SetRegua(1000)
 DbGoTop()
 While !EOF()                                                                                
  IncRegua()

  If nLin+1 > nMaxLin
   FS_Cabec()
  Endif

  If QRY->GN4_STATUS <> cStatus
     nLin++
     nLin++
     If QRY->GN4_STATUS == "0" 
      @nLin, 000 PSAY STR0016 //"INCLUIDO"
     ElseIf QRY->GN4_STATUS == "1"
      @nLin, 000 PSAY STR0009 //"TROCA"
     ElseIf QRY->GN4_STATUS == "2"      
      @nLin, 000 PSAY STR0010 //"FALTA"
     ElseIf QRY->GN4_STATUS == "3"      
      @nLin, 000 PSAY STR0017 //"CANCELADO"
     EndIf  
     nLin++
     @nLin, 000 PSAY REPLICATE("-", 132)
  Endif

  nLin += 1
  @nLin, 000 PSAY QRY->GN4_NRSEQP       
  @nLin, 011 PSAY QRY->GN4_CODCRM          
  @nLin, 019 PSAY QRY->RA_NOME          
  @nLin, 051 PSAY STOD(QRY->GN4_DATINI) 
  @nLin, 060 PSAY QRY->GN4_HORINI       
  @nLin, 068 PSAY QRY->GN3_CODLOC       
  @nLin, 071 PSAY QRY->GCS_NOMLOC       
  nLin += 1
  @nLin, 011 PSAY QRY->GN4_PROSUB       
  @nLin, 019 PSAY IIf(!Empty(QRY->GN4_PROSUB),HS_IniPadr("SRA",11,	QRY->GN4_PROSUB,"RA_NOME")," ")       
  @nLin, 051 PSAY STOD(QRY->GN4_DATFIN) 
  @nLin, 060 PSAY QRY->GN4_HORFIN       

  nLin += 1       
  cObs := HS_IniPadr("GN4",1,	QRY->GN4_NRSEQP+QRY->GN4_NRSEQE,"GN4_OBSGER")
  If !Empty(cObs)
   @ nLin,000 PSAY STR0018  //"Observacao: "
    If (nLin + MLCount(cObs, 115)) > nMaxLin
     FS_Cabec()
    EndIf
    For nForR55 := 1 to MLCount(cObs, 115)
     @ nLin,013 PSAY MemoLine(cObs,115, nForR55)
     nLin++
    Next
  EndIf    


  If nImpDes == 1
   FS_ImpDes(QRY->GN4_NRSEQP)
   @nLin, 000 PSAY REPLICATE("_", 132)
   cCodLoc := ""  
  Endif
  
  DbSelectArea("QRY")
  cStatus   := QRY->GN4_STATUS
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
 nLin := 7
Return()