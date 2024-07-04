#INCLUDE "HSPAHR78.ch"
#Include "protheus.ch"
#include "TopConn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHR78 บ Autor ณ Cibele Peria       บ Data ณ  28/03/05   บฑฑ
ฑฑบ          ณ          บ Alter.| Daniel Peixoto     บ Data ณ  11/11/05   บฑฑ
ฑฑบ          ณ          บ Alter.| Daniel Peixoto     บ Data ณ  05/01/06   บฑฑ
ฑฑบ          ณ          บ Alter.| Daniel Peixoto     บ Data ณ  29/03/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio de Procedimento por Medicos                      บฑฑ 
ฑฑบ          ณ (Producao por Procedimento)                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHR78()

 Local cDesc1 := STR0001 //"Este programa tem como objetivo imprimir relatorio "
 Local cDesc2 := STR0002 //"de acordo com os parametros informados pelo usuario."
 Local cDesc3 := STR0003  //"Procedimentos por medico"
 Local aOrd   := {}
 Local cAlias := ""

 Private Titulo := cDesc3
                 /*                     1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21
                              0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789 */
 Private Cabec1 := STR0036
 Private Cabec2 := STR0004 //"Data      Hora  Aten.  Profissional                           Plano                            Ato Medico             Quantidade    Quant. Ch.     Procedim(R$)    Repasse(R$) "
 Private lEnd        := .F.
 Private lAbortPrint := .F.
 Private limite      := 80
 Private Tamanho     := "G"
 Private NomeProg    := "HSPAHR78" // Coloque aqui o nome do programa para impressao no cabecalho
 Private nTipo       := 18
 Private aReturn     := { STR0005, 1, STR0006, 2, 2, 1, "", 1} //"Zebrado"###"Administracao"
 Private nLastKey    := 0
 Private cbtxt       := Space(10)
 Private cbcont      := 00
 Private CONTFL      := 01
 Private m_pag       := 01
 Private wnrel       := NomeProg
 Private nTam        := 132 
 
 Private cCodLoc_De  := "", cCodLoc_Ate := ""
 Private cCodPro_De  := "", cCodPro_Ate := ""
 Private cCodCRM_De  := "", cCodCRM_Ate := ""
 Private cCodPre_De  := "", cCodPre_Ate := ""
 Private cCodCon_De  := "", cCodCon_Ate := ""
 Private dDatDes_De  := "", dDatDes_Ate := ""
 Private cFaturSN    := "", cLaudSN     := ""
 Private lRepDir     := .T.

 Private cCODIMP := ""
 Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao         
 
 DbSelectArea("SX1")
 DbSetOrder(1)
 If !DbSeek("HSPR78    15")
  HS_MsgInf(STR0044 + "HSPR78" + STR0045, STR0032, STR0046) //###"Pergunta do grupo "###" nใo encontrada. Solicite atualiza็ใo"###"Aten็ใo"###"Valida็ใo de dicionแrio"
  Return()
 EndIf

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ PARAMETROS                                                       ณ
 //ณ MV_PAR01	Do setor                                              ณ
 //ณ MV_PAR02	Ate o setor                                           ณ
 //ณ MV_PAR03	Do procedimento                                       ณ
 //ณ MV_PAR04	Ate o procedimento                                    ณ
 //ณ MV_PAR05	Do medico                                             ณ
 //ณ MV_PAR06	Ate o medico                                          ณ
 //ณ MV_PAR07	Do medico                                             ณ
 //ณ MV_PAR08	Ate o medico                                          ณ
 //ณ MV_PAR09	Do convenio                                           ณ
 //ณ MV_PAR10	Ate o convenio                                        ณ
 //ณ MV_PAR11	Da data                                               ณ
 //ณ MV_PAR12	Ate a data                                            ณ
 //ณ MV_PAR13	Faturado - Sim/Nao                                    ณ
 //ณ MV_PAR14	Emite Rep. Direto - Sim/Nใo                           ณ    
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 If !Pergunte("HSPR78",.T.)
  Return()
 EndIf

 nMaxLin := HS_MaxLin(cCODIMP)

 cCodLoc_De  := mv_par01
 cCodLoc_Ate := mv_par02
 cCodPro_De  := mv_par03
 cCodPro_Ate := mv_par04
 cCodPre_De  := mv_par05
 cCodPre_Ate := mv_par06
 cCodCRM_De  := mv_par07
 cCodCRM_Ate := mv_par08
 cCodCon_De  := mv_par09
 cCodCon_Ate := mv_par10
 dDatDes_De  := mv_par11
 dDatDes_Ate := mv_par12
 cFaturSN    := mv_par13
 lRepDir     := mv_par14 == 1
 cLaudSN     := mv_par15 - 1
 
 Titulo      += STR0007
 If Empty(dDatDes_de)
  Titulo += STR0030 + DTOC(dDatDes_Ate)
 Else
  Titulo += DTOC(dDatDes_De) + STR0008 + DTOC(dDatDes_Ate)
 Endif
 Titulo  += STR0009 + IIF(cFaturSN==1, STR0010, IIF(cFaturSN==2, STR0011, STR0034)) + STR0012 //("###"Faturados"###"Nao faturados"###"Faturados/Nao Faturados"###")" 
 
 If cFaturSN == 1 
  cAlias := "GE7"
 ElseIf cFaturSN == 2
  cAlias := "GD7"
 Endif  

 wnrel := SetPrint(cAlias, NomeProg, "", @Titulo, cDesc1, cDesc2, cDesc3, .T., aOrd, .T., Tamanho, , .T.)
 If nLastKey == 27
  Return()
 Endif

 SetDefault(aReturn, cAlias)
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
ฑฑบFuno    ณRUNREPORT บ Autor ณ Cibele Peria       บ Data ณ  28/03/05   บฑฑ
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
 Local cNomLoc := "", cNomPac := "", cDesPro := "", nTotPro := 0, nTotPac := 0, nTotLoc := 0, nTotGer := 0
 Local nTotValDes := 0, nTotValRep := 0
 Local nTotRepLoc := 0, nTotValLoc := 0
 Local nTotValGer := 0, nTotRepGer := 0
 Local nTotValPac := 0, nTotRepPac := 0
 Local cOpcPrLaud := IIf (cLaudSN == 4, "'0','1','2','3'", ("'" + ALLTRIM(STR(cLaudSN)) + "'" ))
 Local cStatusPro := "", cStatFatur := ""
 
 If cFaturSN == 1 .Or. cFaturSN == 3//Faturados
  cSQL := "SELECT  "
  cSQL += " 'GE' AS QRY_ALIAS, GE7.GE7_CODLOC QRY_CODLOC, GE7.GE7_CODDES QRY_CODDES, GE7.GE7_CODCRM QRY_CODCRM, "
  cSQL += "GE7.GE7_DATDES QRY_DATDES, GE7.GE7_HORDES QRY_HORDES, GE7.GE7_QTDDES QRY_QTDDES, GE7.GE7_SEQDES QRY_SEQDES, "
  cSQL += "GCS.GCS_NOMLOC QRY_NOMLOC, GBY.GBY_STATUS QRY_STATUS, GCZ.GCZ_CODCON QRY_CODCON, GCZ.GCZ_CODPLA QRY_CODPLA, GCZ.GCZ_REGGER QRY_REGGER, "
  cSQL += "GCZ.GCZ_REGATE QRY_REGATE, GA7.GA7_DESC QRY_DESPRO, SRA.RA_NOME QRY_NOMMED, GCM.GCM_DESPLA QRY_DESPLA, GBH.GBH_NOME QRY_NOMPAC, "
  cSQL += HS_FVALDES("GE7")+ " AS QRY_VALDES, GE7.GE7_VALREP QRY_VALREP, GE7.GE7_QTDCHP QRY_QTDCHP, GMC.GMC_DESATO QRY_DESATO"
  cSQL += " FROM " + RetSQLName("GE7") + " GE7 "
  cSQL += " JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_NRSEQG = GE7.GE7_NRSEQG AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
  cSQL += " JOIN " + RetSQLName("GCM") + " GCM ON GCM.GCM_CODCON = GCZ.GCZ_CODCON AND GCM.GCM_CODPLA = GCZ.GCZ_CODPLA AND GCM.GCM_FILIAL = '" + xFilial("GCM") + "' AND GCM.D_E_L_E_T_ <> '*' "
  cSQL += " JOIN " + RetSQLName("GBH") + " GBH ON GBH.GBH_CODPAC = GCZ.GCZ_REGGER AND GBH.GBH_FILIAL = '" + xFilial("GBH") + "' AND GBH.D_E_L_E_T_ <> '*' "
  cSQL += " JOIN " + RetSQLName("GCS") + " GCS ON GCS.GCS_CODLOC = GE7.GE7_CODLOC AND GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' " 
  cSQL += " JOIN " + RetSQLName("GA7") + " GA7 ON GA7.GA7_CODPRO = GE7.GE7_CODDES AND GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' "
  cSQL += " JOIN " + RetSQLName("SRA") + " SRA ON SRA.RA_CODIGO  = GE7.GE7_CODCRM AND SRA.RA_FILIAL =  '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' "
  cSQL += " LEFT JOIN " + RetSqlName("GMC") + " GMC ON GMC.GMC_FILIAL = '"+xFilial("GMC")+"' AND GMC.D_E_L_E_T_ <> '*' AND GMC.GMC_CODATO = GE7.GE7_CODATO "
  cSQL += " LEFT JOIN " + RetSQLName("GBY") + " GBY ON GBY.GBY_SEQDES = GE7.GE7_SEQDES AND GBY.GBY_STATUS IN (" + cOpcPRLaud + ") AND GBY.GBY_FILIAL = '" + xFilial("GBY") + "' AND GBY.D_E_L_E_T_ <> '*' "
  cSQL += " WHERE "
  cSQL += "GE7.GE7_FILIAL = '" + xFilial("GE7") + "' AND GE7.D_E_L_E_T_ <> '*' AND "
  cSQL += "GE7.GE7_CODLOC BETWEEN '" + cCodLoc_De + "' AND '" + cCodLoc_Ate + "' AND "
  cSQL += "GE7.GE7_CODDES BETWEEN '" + cCodPro_De + "' AND '" + cCodPro_Ate + "' AND " 
  cSQL += "GE7.GE7_CODCRM BETWEEN '" + cCodCRM_De + "' AND '" + cCodCRM_Ate + "' AND " 
  cSQL += "GE7.GE7_DATDES BETWEEN '" + DTOS(dDatDes_De) + "' AND '" + DTOS(dDatDes_Ate) + "' AND "
  cSQL += "GCZ.GCZ_CODCON BETWEEN '" + cCodCon_De + "' AND '" + cCodCon_Ate + "' AND "
  cSQL += "GE7.GE7_CODPRE BETWEEN '" + cCodPre_De + "' AND '" + cCodPre_Ate + "' "
  
  If !lRepDir 
   cSQL += " AND GE7.GE7_PGTMED <> '0' "
  EndIf
 EndIf
  
 If cFaturSN == 2 .Or. cFaturSN == 3 //Nao faturados ou Todos
  If cFaturSN == 3 //Todos
   cSQL += "UNION ALL "
  EndIf
  cSQL += "SELECT  "
  cSQL += " 'GD' AS QRY_ALIAS, GD7.GD7_CODLOC QRY_CODLOC, GD7.GD7_CODDES QRY_CODDES, GD7.GD7_CODCRM QRY_CODCRM, "
  cSQL += "GD7.GD7_DATDES QRY_DATDES, GD7.GD7_HORDES QRY_HORDES, GD7.GD7_QTDDES QRY_QTDDES, GD7.GD7_SEQDES QRY_SEQDES, "
  cSQL += "GCS.GCS_NOMLOC QRY_NOMLOC, GBY.GBY_STATUS QRY_STATUS, GCZ.GCZ_CODCON QRY_CODCON, GCZ.GCZ_CODPLA QRY_CODPLA, GCZ.GCZ_REGGER QRY_REGGER, "
  cSQL += "GCZ.GCZ_REGATE QRY_REGATE, GA7.GA7_DESC QRY_DESPRO, SRA.RA_NOME QRY_NOMMED, GCM.GCM_DESPLA QRY_DESPLA, GBH.GBH_NOME QRY_NOMPAC, "
  cSQL += HS_FVALDES("GD7")+ " AS QRY_VALDES, GD7.GD7_VALREP QRY_VALREP, GD7.GD7_QTDCHP QRY_QTDCHP, GMC.GMC_DESATO QRY_DESATO"
  cSQL += " FROM " + RetSQLName("GD7") + " GD7 "
  cSQL += " JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_NRSEQG = GD7.GD7_NRSEQG AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
  cSql += " JOIN " + RetSQLName("GCU") + " GCU ON GCU.D_E_L_E_T_ <> '*' AND GCU.GCU_FILIAL = '" + xFilial("GCU") + "' "
  cSql += " AND GCU.GCU_CODTPG = GCZ.GCZ_CODTPG AND GCU.GCU_TPGUIA <> '7' "  //Nใo Apresenta Guias Tipo Retorno   
  cSQL += " JOIN " + RetSQLName("GCM") + " GCM ON GCM.GCM_CODCON = GCZ.GCZ_CODCON AND GCM.GCM_CODPLA = GCZ.GCZ_CODPLA AND GCM.GCM_FILIAL = '" + xFilial("GCM") + "' AND GCM.D_E_L_E_T_ <> '*' "
  cSQL += " JOIN " + RetSQLName("GBH") + " GBH ON GBH.GBH_CODPAC = GCZ.GCZ_REGGER AND GBH.GBH_FILIAL = '" + xFilial("GBH") + "' AND GBH.D_E_L_E_T_ <> '*' "
  cSQL += " JOIN " + RetSQLName("GCS") + " GCS ON GCS.GCS_CODLOC = GD7.GD7_CODLOC AND GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' " 
  cSQL += " JOIN " + RetSQLName("GA7") + " GA7 ON GA7.GA7_CODPRO = GD7.GD7_CODDES AND GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' "
  cSQL += " JOIN " + RetSQLName("SRA") + " SRA ON SRA.RA_CODIGO  = GD7.GD7_CODCRM AND SRA.RA_FILIAL =  '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' "
  cSQL += " LEFT JOIN " + RetSqlName("GMC") + " GMC ON GMC.GMC_FILIAL = '"+xFilial("GMC")+"' AND GMC.D_E_L_E_T_ <> '*' AND GMC.GMC_CODATO = GD7.GD7_CODATO "
  cSQL += " LEFT JOIN " + RetSQLName("GBY") + " GBY ON GBY.GBY_SEQDES = GD7.GD7_SEQDES AND GBY.GBY_STATUS IN (" + cOpcPRLaud + ") AND GBY.GBY_FILIAL = '" + xFilial("GBY") + "' AND GBY.D_E_L_E_T_ <> '*' "
  cSQL += " WHERE "
  cSQL += "GD7.GD7_FILIAL = '" + xFilial("GD7") + "' AND GD7.D_E_L_E_T_ <> '*' AND "
  cSQL += "GCZ.GCZ_STATUS < '2' AND "
  cSQL += "GD7.GD7_CODLOC BETWEEN '" + cCodLoc_De + "' AND '" + cCodLoc_Ate + "' AND "
  cSQL += "GD7.GD7_CODDES BETWEEN '" + cCodPro_De + "' AND '" + cCodPro_Ate + "' AND " 
  cSQL += "GD7.GD7_CODCRM BETWEEN '" + cCodCRM_De + "' AND '" + cCodCRM_Ate + "' AND "
  cSQL += "GD7.GD7_DATDES BETWEEN '" + DTOS(dDatDes_De) + "' AND '" + DTOS(dDatDes_Ate) + "' AND "
  cSQL += "GCZ.GCZ_CODCON BETWEEN '" + cCodCon_De + "' AND '" + cCodCon_Ate + "' AND "
  cSQL += "GD7.GD7_CODPRE BETWEEN '" + cCodPre_De + "' AND '" + cCodPre_Ate + "' "

  If !lRepDir 
   cSQL += " AND GD7.GD7_PGTMED <> '0' "
  EndIf
 EndIf
 
 cSQL += "ORDER BY QRY_NOMLOC, QRY_ALIAS, QRY_NOMPAC, QRY_STATUS, QRY_DESPRO, QRY_NOMMED, 	QRY_DESPLA "
 
 cSQL := ChangeQuery(cSQL)
 
 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")
 DbGoTop()

 If Eof()
  HS_MsgInf(STR0031, STR0032, STR0033) //"Nenhum dado foi encontrado para a selecao efetuada."###"Aten็ใo"###"Verifique a sele็ใo"
  DbCloseArea()
  Return()
 Endif 
  
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 SetRegua(200)

 While !EOF()                                                                                

  IncRegua()
  If QRY->QRY_NOMLOC <> cNomLoc .or. QRY->QRY_NOMPAC <> cNomPac .Or. QRY->QRY_DESPRO <> cDesPro .Or. QRY->QRY_ALIAS <> cStatFatur
   If nTotPro > 0
    nLin := FS_Total("P", nTotPro, nTotValDes, nTotValRep, nLin)
    nTotPac    += nTotPro
    nTotValPac += nTotValDes
    nTotRepPac += nTotValRep
    nTotPro    := 0
    nTotValDes := 0
    nTotValRep := 0
   Endif
   
   If QRY->QRY_NOMLOC <> cNomLoc .or. QRY->QRY_NOMPAC <> cNomPac .Or. QRY->QRY_ALIAS <> cStatFatur
    If nTotPac > 0
     nLin := FS_Total("R", nTotPac, nTotValPac, nTotRepPac, nLin)
     nTotLoc    += nTotPac
     nTotValLoc += nTotValPac
     nTotRepLoc += nTotRepPac
     nTotPac    := 0
     nTotValPac := 0
     nTotRepPac := 0
    Endif
   Endif
   If QRY->QRY_NOMLOC <> cNomLoc .Or. QRY->QRY_ALIAS <> cStatFatur
    If nTotLoc > 0
     nLin := FS_Total("L", nTotLoc, nTotValLoc, nTotRepLoc, nLin)
     nTotGer += nTotLoc
     nTotValGer += nTotValLoc
     nTotRepGer += nTotRepLoc
     nTotLoc    := 0
     nTotValLoc := 0
     nTotRepLoc := 0
    Endif
   
				cStatusPro  := "5"
				cStatFatur  := ""
   
    nLin := FS_Cabec()    
    nLin += 1
    @nLin, 000 PSAY STR0013 + QRY->QRY_CODLOC + " - " + ALLTRIM(QRY->QRY_NOMLOC) //"Setor "
    
   If QRY->QRY_ALIAS <> cStatFatur .And. QRY->QRY_ALIAS == 'GD'
    nLin += 2
    @nLin, 000 PSAY STR0011 + ":" //"Nใo Faturados:"      
   ElseIf QRY->QRY_ALIAS <> cStatFatur .And. QRY->QRY_ALIAS == 'GE'
    nLin += 2
    @nLin, 000 PSAY STR0010 + ":"//Faturados:"          
   EndIf
   
    nLin += 2
    @nLin, 000 PSAY STR0035 + QRY->QRY_REGGER + " - " + ALLTRIM(QRY->QRY_NOMPAC) //"Paciente: "
    
   Else
                                        
    If QRY->QRY_NOMPAC <> cNomPac
     nLin += 2
     @nLin, 000 PSAY STR0035 + QRY->QRY_REGGER + " - " + ALLTRIM(QRY->QRY_NOMPAC) //"Paciente: "
     cStatusPro  := "5"
    Endif 
   Endif
   
   If QRY->QRY_STATUS <> cStatusPro
    nLin += 2
    If QRY->QRY_STATUS == '0'
     @nLin, 000 PSAY STR0039 + STR0040 //"Procediento com Laudo - "###"Nใo Gerado:"
    ElseIf QRY->QRY_STATUS == '1'
     @nLin, 000 PSAY STR0039 + STR0041 //"Procediento com Laudo - "###"Gerado:"
    ElseIf QRY->QRY_STATUS == '2'
     @nLin, 000 PSAY STR0039 + STR0042 //"Procediento com Laudo - "###"Liberado:"
    ElseIf QRY->QRY_STATUS == '3'
     @nLin, 000 PSAY STR0039 + STR0043 //"Procediento com Laudo - "###"Entregue:"
    Else
     @nLin, 000 PSAY STR0038 //"Procediento sem Laudo: "   
    EndIf
    cStatusPro := QRY->QRY_STATUS
   EndIf
   
   nLin += 2
   @nLin,000 PSAY ALLTRIM(QRY->QRY_CODDES) + " - " + ALLTRIM(QRY->QRY_DESPRO)//"Procedimento: "
   cNomLoc   := QRY->QRY_NOMLOC
   cNomPac   := QRY->QRY_NOMPAC 
   cDesPro   := QRY->QRY_DESPRO
   cStatFatur:= QRY->QRY_ALIAS
  Endif 
    
  If nLin > nMaxLin
   nLin := FS_Cabec()
  Endif
  nLin += 1
  @nLin, 000 PSAY DTOC(STOD(QRY->QRY_DATDES)) 
  @nLin, 010 PSAY QRY->QRY_HORDES
  @nLin, 016 PSAY QRY->QRY_REGATE
  @nLin, 023 PSAY QRY->QRY_CODCRM + " " 
  @nLin, 030 PSAY SUBSTR(QRY->QRY_NOMMED,1,30)
  @nLin, 062 PSAY QRY->QRY_DESPLA
  @nLin, 095 PSAY SUBSTR(QRY->QRY_DESATO,1,20)
  @nLin, 119 PSAY TRANSFORM(QRY->QRY_QTDDES, "@E 99,999.99") //Qtd.
  @nLin, 133 PSAY TRANSFORM(QRY->QRY_QTDCHP, "@E 99,999.99") //Qtd. CH
  @nLin, 146 PSAY TRANSFORM(QRY->QRY_VALDES, "@E 99,999,999.99")
  @nLin, 160 PSAY TRANSFORM(IIF(QRY->QRY_ALIAS == "GE", QRY->QRY_VALREP, 0), "@E 99,999,999.99")
  nTotPro += QRY->QRY_QTDDES
  nTotValDes += QRY->QRY_VALDES
  nTotValRep += IIF(QRY->QRY_ALIAS == "GE", QRY->QRY_VALREP, 0)
  
  DbSkip()

 EndDo
  
 nLin := FS_Total("P", nTotPro, nTotValDes, nTotValRep, nLin)
 nTotPac    += nTotPro
 nTotValPac += nTotValDes
 nTotRepPac += nTotValRep  
 
 nLin := FS_Total("R", nTotPac, nTotValPac, nTotRepPac, nLin)
 nTotLoc    += nTotPac
 nTotValLoc += nTotValPac
 nTotRepLoc += nTotRepPac  
 
 nLin := FS_Total("L", nTotLoc, nTotValLoc, nTotRepLoc, nLin)
 nTotGer    += nTotLoc 
 nTotValGer += nTotValLoc
 nTotRepGer += nTotRepLoc  
 FS_Total("G", nTotGer, nTotValGer, nTotRepGer, nLin)


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
ฑฑบFuno    ณFS_Cabec  บ Autor ณ Cibele Peria       บ Data ณ  29/03/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Cabecalho do relatorio                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_Cabec()
 Local nLin := 9
 Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo, ,.T.) 
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
Static Function FS_Total(cTipo, nQtdTot, nTotVal, nTotRep,  nLin)
 Local cTotal := ""

 If nLin > nMaxLin
  nLin := FS_Cabec()
 Endif
 If cTipo == "P"    //Procedimento
  nLin += 1  
  cTotal := STR0014 //"Total do Procedimento"
  nLin += 1  
 ElseIf cTipo == "L"
  cTotal := STR0015 //"Total do Setor"
  nLin += 2    
 ElseIf cTipo == "R" //Paciente
  cTotal := STR0037  //"Total do Paciente"       
  nLin += 2    
 Else
  cTotal := STR0016 //"Total Geral"
  nLin += 2  
 Endif

 If cTipo == "G"
  @nLin,005 PSAY REPLICATE("_",220)
  nLin ++
 Endif
 
 @nLin, 005 PSAY cTotal 
 @nLin, 030 PSAY TRANSFORM(nQtdTot, "999,999,999")
 @nLin, 146 PSAY TRANSFORM(nTotVal, "@E 99,999,999.99")
 @nLin, 160 PSAY TRANSFORM(nTotRep, "@E 99,999,999.99")

Return(nLin)