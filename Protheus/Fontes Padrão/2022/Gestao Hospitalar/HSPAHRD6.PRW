#INCLUDE "HSPAHRD6.ch"
#Include "protheus.ch"
#include "TopConn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHRD6 บ Autor ณ Cibele Peria       บ Data ณ  30/04/05   บฑฑ  
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio de Recurso de Glosas                             บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHRD6()

 Local cDesc1 := STR0001 //"Este programa tem como objetivo imprimir relatorio "
 Local cDesc2 := STR0002 //"de acordo com os parametros informados pelo usuario."
 Local cDesc3 := STR0003 //"Recurso de Glosa"
 Local aOrd   := {}
 Local lErrPerg := .T., lRetPerg := .T.
 
 Private Titulo := cDesc3
 Private Cabec1 := SPACE(86) + SUBSTR(STR0005,11,100)//"Procedimento"###"Vl Faturado       Vl Pago      Vl Glosa"
//                  0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789
 Private Cabec2 := STR0006 //"        Motivo de Glosa                                    Justificativa de Glosa"
 Private lEnd        := .F.
 Private lAbortPrint := .F.
 Private limite      := 80
 Private Tamanho     := "M"
 Private NomeProg    := "HSPAHRD6" // Coloque aqui o nome do programa para impressao no cabecalho
 Private nTipo       := 18
 Private aReturn     := { STR0007, 1, STR0008, 2, 2, 1, "", 2} //"Zebrado"###"Administracao"
 Private nLastKey    := 0
 Private cbtxt       := Space(10)
 Private cbcont      := 00
 Private CONTFL      := 01
 Private m_pag       := 01
 Private wnrel       := NomeProg
 Private nTam        := 132 
 Private cNumRec_De := "", cNumRec_Ate := ""
 Private dDatRec_De := "", dDatRec_Ate := ""
 Private cCodCon_De := "", cCodCon_Ate := ""
 Private cMotGlo_De := "", cMotGlo_Ate := ""
 Private cJusGlo_De := "", cJusGlo_Ate := ""
 Private cPerg :=PADR("HSPRD6", Len(SX1->X1_GRUPO))

 Private cCODIMP := ""
 Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ PARAMETROS                                                    ณ
 //ณ MV_PAR01	 - Do convenio                                       ณ
 //ณ MV_PAR02	 - Ate o convenio                                    ณ
 //ณ MV_PAR03	 - Do recurso                                        ณ
 //ณ MV_PAR04	 - Ate o recurso                                     ณ
 //ณ MV_PAR05	 - Da data do recurso                                ณ
 //ณ MV_PAR06	 - Ate a data do recurso                             ณ
 //ณ MV_PAR07	 - Do Motivo de Glosa ?                              ณ 
 //ณ MV_PAR08	 - Ate Motivo de Glosa ?                             ณ
 //ณ MV_PAR09	 - Da Just. de Glosa?                               ณ
 //ณ MV_PAR010	 - Ate Just. de Glosa?                             ณ 
 //ณ MV_PAR011	 - Impressora ?                                     ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

lRetPerg := Pergunte(cPerg, .T.)
If lRetPerg
   cCodCon_De  := mv_par01
   cCodCon_Ate := mv_par02
   cNumRec_De  := mv_par03
   cNumRec_Ate := mv_par04
   dDatRec_De  := mv_par05 
   dDatRec_Ate := mv_par06
   cMotGlo_De  := mv_par07
   cMotGlo_Ate := mv_par08
   cJusGlo_De  := mv_par09
   cJusGlo_Ate := mv_par10
   
   lErrPerg := FS_VldUserChoose({{cCodCon_Ate,STR0009}, ; //"Informe o codigo final do convenio"
                                  {cNumRec_Ate,STR0010},; //"Informe o codigo final do recurso"
                                  {dDatRec_De,STR0011}, ; //"Informe o perido da data do recurso"
                                  {dDatRec_Ate,STR0011},; //"Informe o perido da data do recurso"
                                  {cMotGlo_Ate,STR0026},; //"Informe o codigo final do motivo da glosa"
                                  {cJusGlo_Ate,STR0027}}) //"Informe o codigo final da justificativa de glosa"
End
  
 If !lRetPerg .or. lErrPerg
  Return()
 Endif

 nMaxLin := HS_MaxLin(cCODIMP)
  
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
ฑฑบFuno    ณRUNREPORT บ Autor ณ Cibele Peria       บ Data ณ  30/04/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Rotina de execucao do relatorio                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function RunReport()
 Local cSql    := ""
 Local cTpTab  := ""
 Private aTotPac := {}
 Private cCodcon  := "", cNrFatu := "", cSerie := "", cRegAte := "", cNrGuia := "" ,cNumRec:=""
 Private nFatGuia  := 0,  nRecGuia  := 0, nPerGuia  := 0, nRcuGuia    := 0
 Private nFatFat   := 0,  nRecFat   := 0, nPerFat   := 0, nRcuFat     := 0
 Private nFatCon   := 0,  nRecCon   := 0, nPerCon   := 0, nRcuCon     := 0
 Private nFatGer   := 0,  nRecGer   := 0, nPerGer   := 0, nRcuGer     := 0   
 Private nLin := nMaxLin * 2

 cSQL := " SELECT 'GF5'  TABELA, GF0.GF0_CODCON CODCON,GF0.GF0_NRFATU NRFATU, GF0.GF0_SERIE SERIE, GF0.GF0_NUMREC NUMREC,GF0.GF0_OBSERV OBSERV,GA9.GA9_NREDUZ NREDUZ, "    
 cSQL += "        GF5.GF5_CODDES CODDES, GF0.GF0_VLRECU VLRECU, GF5.GF5_VALGLO VALGLO, GF5.GF5_VALREC VALREC, GF5.GF5_VALPER VALPER,SB1.B1_DESC DESCRI,"
 cSQL += "        GCZ.GCZ_REGATE REGATE, GCZ.GCZ_REGGER REGGER, GCZ.GCZ_NRGUIA NRGUIA, GBH.GBH_NOME NOME, GCY.GCY_DATATE DATATE, GCY.GCY_HORATE HORATE, "
 cSQL += "        GDM.GDM_DESC GDMDESC, GG9.GG9_DSJGLO DSJGLO, GCZ.GCZ_NRLOTE NRLOTE "
 cSQL += " FROM " + RetSQLName("GF0") + " GF0 "  
 cSQL += " JOIN " + RetSQLName("GA9") + " GA9 ON GA9.GA9_CODCON = GF0.GF0_CODCON  "
 cSQL += "                                    AND GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*' " 
 cSQL += " JOIN " + RetSQLName("GF5") + " GF5 ON GF5.GF5_NUMREC = GF0.GF0_NUMREC "  
 cSQL += "                                    AND GF5.GF5_FILIAL = '" + xFilial("GF5") + "' AND GF5.D_E_L_E_T_ <> '*' "
 cSQL += " LEFT JOIN " + RetSQLName("GG9") + " GG9 ON GG9.GG9_CDJGLO = GF5.GF5_CDJGLO "
 cSQL += "                                         AND GG9.GG9_FILIAL = '" + xFilial("GG9") + "' AND GG9.D_E_L_E_T_ <> '*' " 
 cSQL += " LEFT JOIN " + RetSQLName("GDM") + " GDM ON GDM.GDM_CODIGO = GF5.GF5_CDMGLO "
 cSQL += "                                         AND   GDM.GDM_FILIAL = '" + xFilial("GDM") + "' AND GDM.D_E_L_E_T_ <> '*' " 
 cSQL += " JOIN " + RetSQLName("SB1") + " SB1 ON SB1.B1_COD = GF5.GF5_CODDES "  
 cSQL += "                                    AND   SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_NRSEQG = GF5.GF5_NRSEQG "    
 cSQL += "                                    AND   GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GBH") + " GBH ON GBH.GBH_CODPAC = GCZ.GCZ_REGGER "
 cSQL += "                                    AND   GBH.GBH_FILIAL = '" + xFilial("GBH") + "' AND GBH.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GCY") + " GCY ON GCY.GCY_REGATE = GCZ.GCZ_REGATE "
 cSQL += "                                    AND   GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "
 cSQL += " WHERE GF0.GF0_FILIAL = '" + xFilial("GF0") + "' AND GF0.D_E_L_E_T_ <> '*' "
 cSQL += " AND   GF0.GF0_STATUS IN( '1','2') "
 cSQL += " AND   GF0.GF0_NUMREC BETWEEN '" + cNumRec_De + "' AND '" + cNumRec_Ate + "' " 
 cSQL += " AND   GF0.GF0_DATREC BETWEEN '" + DTOS(dDatRec_De) + "' AND '" + DTOS(dDatRec_Ate) + "'"
 cSQL += " AND   GF0.GF0_CODCON BETWEEN '" + cCodCon_De + "' AND '" + cCodCon_Ate + "'"
 cSQL += " AND   GF5.GF5_CDJGLO BETWEEN '" + cJusGlo_De + "' AND '" + cJusGlo_Ate + "'"
 cSQL += " AND   GF5.GF5_CDMGLO BETWEEN '" + cMotGlo_De + "' AND '" + cMotGlo_Ate + "'"
 cSQL += " UNION ALL " 

 cSQL += " SELECT 'GF6'  TABELA, GF0.GF0_CODCON CODCON, GF0.GF0_NRFATU NRFATU, GF0.GF0_SERIE SERIE, GF0.GF0_NUMREC NUMREC, GF0.GF0_OBSERV OBSERV, GA9.GA9_NREDUZ NREDUZ, "    
 cSQL += "        GF6.GF6_CODDES CODDES, GF0.GF0_VLRECU VLRECU, GF6.GF6_VALGLO VALGLO, GF6.GF6_VALREC VALREC, GF6.GF6_VALPER VALPER, GAA.GAA_DESC DESCRI,"
 cSQL += "        GCZ.GCZ_REGATE REGATE, GCZ.GCZ_REGGER REGGER, GCZ.GCZ_NRGUIA NRGUIA, GBH.GBH_NOME NOME, GCY.GCY_DATATE DATATE, GCY.GCY_HORATE HORATE, "
 cSQL += "        GDM.GDM_DESC GDMDESC, GG9.GG9_DSJGLO DSJGLO, GCZ.GCZ_NRLOTE NRLOTE " 
 cSQL += " FROM " + RetSQLName("GF0") + " GF0 "  
 cSQL += " JOIN " + RetSQLName("GA9") + " GA9 ON GA9.GA9_CODCON = GF0.GF0_CODCON  "
 cSQL += "                                    AND GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*' " 
 cSQL += " JOIN " + RetSQLName("GF6") + " GF6 ON GF6.GF6_NUMREC = GF0.GF0_NUMREC "  
 cSQL += "                                    AND GF6.GF6_FILIAL = '" + xFilial("GF6") + "' AND GF6.D_E_L_E_T_ <> '*' "
 cSQL += " LEFT JOIN " + RetSQLName("GG9") + " GG9 ON GG9.GG9_CDJGLO = GF6.GF6_CDJGLO "
 cSQL += "                                         AND GG9.GG9_FILIAL = '" + xFilial("GG9") + "' AND GG9.D_E_L_E_T_ <> '*' " 
 cSQL += " LEFT JOIN " + RetSQLName("GDM") + " GDM ON GDM.GDM_CODIGO = GF6.GF6_CDMGLO "
 cSQL += "                                         AND   GDM.GDM_FILIAL = '" + xFilial("GDM") + "' AND GDM.D_E_L_E_T_ <> '*' " 
 cSQL += " JOIN " + RetSQLName("GAA") + " GAA ON GAA.GAA_CODTXD = GF6.GF6_CODDES "  
 cSQL += "                                    AND   GAA.GAA_FILIAL = '" + xFilial("GAA") + "' AND GAA.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_NRSEQG = GF6.GF6_NRSEQG "    
 cSQL += "                                    AND   GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GBH") + " GBH ON GBH.GBH_CODPAC = GCZ.GCZ_REGGER "
 cSQL += "                                    AND   GBH.GBH_FILIAL = '" + xFilial("GBH") + "' AND GBH.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GCY") + " GCY ON GCY.GCY_REGATE = GCZ.GCZ_REGATE "
 cSQL += "                                    AND   GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "
 cSQL += " WHERE GF0.GF0_FILIAL = '" + xFilial("GF0") + "' AND GF0.D_E_L_E_T_ <> '*' "
 cSQL += " AND   GF0.GF0_STATUS IN( '1','2') "
 cSQL += " AND   GF0.GF0_NUMREC BETWEEN '" + cNumRec_De + "' AND '" + cNumRec_Ate + "' " 
 cSQL += " AND   GF0.GF0_DATREC BETWEEN '" + DTOS(dDatRec_De) + "' AND '" + DTOS(dDatRec_Ate) + "'"
 cSQL += " AND   GF0.GF0_CODCON BETWEEN '" + cCodCon_De + "' AND '" + cCodCon_Ate + "'"
 cSQL += " AND   GF6.GF6_CDJGLO BETWEEN '" + cJusGlo_De + "' AND '" + cJusGlo_Ate + "'"
 cSQL += " AND   GF6.GF6_CDMGLO BETWEEN '" + cMotGlo_De + "' AND '" + cMotGlo_Ate + "'" 
 cSQL += " UNION ALL "

 cSQL += " SELECT 'GF7'  TABELA, GF0.GF0_CODCON CODCON, GF0.GF0_NRFATU NRFATU, GF0.GF0_SERIE SERIE, GF0.GF0_NUMREC NUMREC, GF0.GF0_OBSERV OBSERV, GA9.GA9_NREDUZ NREDUZ, "    
 cSQL += "        GF7.GF7_CODDES CODDES, GF0.GF0_VLRECU VLRECU, GF7.GF7_VALGLO VALGLO, GF7.GF7_VALREC VALREC, GF7.GF7_VALPER VALPER, GA7.GA7_DESC DESCRI,"
 cSQL += "        GCZ.GCZ_REGATE REGATE, GCZ.GCZ_REGGER REGGER, GCZ.GCZ_NRGUIA NRGUIA, GBH.GBH_NOME NOME, GCY.GCY_DATATE DATATE, GCY.GCY_HORATE HORATE, "
 cSQL += "        GDM.GDM_DESC GDMDESC, GG9.GG9_DSJGLO DSJGLO, GCZ.GCZ_NRLOTE NRLOTE "
 cSQL += " FROM " + RetSQLName("GF0") + " GF0 "  
 cSQL += " JOIN " + RetSQLName("GA9") + " GA9 ON GA9.GA9_CODCON = GF0.GF0_CODCON  "
 cSQL += "                                    AND GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*' " 
 cSQL += " JOIN " + RetSQLName("GF7") + " GF7 ON GF7.GF7_NUMREC = GF0.GF0_NUMREC "  
 cSQL += "                                    AND GF7.GF7_FILIAL = '" + xFilial("GF7") + "' AND GF7.D_E_L_E_T_ <> '*' "
 cSQL += " LEFT JOIN " + RetSQLName("GG9") + " GG9 ON GG9.GG9_CDJGLO = GF7.GF7_CDJGLO "
 cSQL += "                                         AND GG9.GG9_FILIAL = '" + xFilial("GG9") + "' AND GG9.D_E_L_E_T_ <> '*' " 
 cSQL += " LEFT JOIN " + RetSQLName("GDM") + " GDM ON GDM.GDM_CODIGO = GF7.GF7_CDMGLO "
 cSQL += "                                         AND   GDM.GDM_FILIAL = '" + xFilial("GDM") + "' AND GDM.D_E_L_E_T_ <> '*' " 
 cSQL += " JOIN " + RetSQLName("GA7") + " GA7 ON GA7.GA7_CODPRO = GF7.GF7_CODDES "  
 cSQL += "                                    AND   GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_NRSEQG = GF7.GF7_NRSEQG "    
 cSQL += "                                    AND   GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GBH") + " GBH ON GBH.GBH_CODPAC = GCZ.GCZ_REGGER "
 cSQL += "                                    AND   GBH.GBH_FILIAL = '" + xFilial("GBH") + "' AND GBH.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GCY") + " GCY ON GCY.GCY_REGATE = GCZ.GCZ_REGATE "
 cSQL += "                                    AND   GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "
 cSQL += " WHERE GF0.GF0_FILIAL = '" + xFilial("GF0") + "' AND GF0.D_E_L_E_T_ <> '*' "
 cSQL += " AND   GF0.GF0_STATUS IN( '1','2') "
 cSQL += " AND   GF0.GF0_NUMREC BETWEEN '" + cNumRec_De + "' AND '" + cNumRec_Ate + "' " 
 cSQL += " AND   GF0.GF0_DATREC BETWEEN '" + DTOS(dDatRec_De) + "' AND '" + DTOS(dDatRec_Ate) + "'"
 cSQL += " AND   GF0.GF0_CODCON BETWEEN '" + cCodCon_De + "' AND '" + cCodCon_Ate + "'"
 cSQL += " AND   GF7.GF7_CDJGLO BETWEEN '" + cJusGlo_De + "' AND '" + cJusGlo_Ate + "'"
 cSQL += " AND   GF7.GF7_CDMGLO BETWEEN '" + cMotGlo_De + "' AND '" + cMotGlo_Ate + "'" 
 cSQL += " ORDER BY NREDUZ, TABELA, NRFATU, SERIE,NUMREC, DATATE, HORATE, NOME"

 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")
 DbGoTop()
 If Eof()
  HS_MsgInf(STR0012, STR0024, STR0025) //"Nenhum dado foi encontrado para a selecao efetuada. Verifique!###"Aten็ใo"###"Rotina de execucao do relatorio "
  DbCloseArea()
  Return()
 Endif

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ RELATORIO                                                           ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 DbGoTop()
 While !Eof()
  If(QRY->CODCON <> cCodCon) .or. (QRY->NRFATU <> cNrFatu) .or. ;
    (QRY->SERIE <> cSerie)   .or. (QRY->REGATE <> cRegAte) .or. ;
    (QRY->NRGUIA <> cNrGuia) .or. (QRY->NUMREC <>cNumRec)
   FS_Totalizar() 
   FS_Quebra()
  Endif
  
  If nLin+2 > nMaxLin
   FS_Cabec()
  Endif
  nLin += 1
  
  IF (cTpTab <> QRY->TABELA)
   IF (QRY->TABELA == 'GF5')
    @nLin, 001 PSAY STR0033 //Material/Medicamento
    @nLin++               
    cTpTab := QRY->TABELA
   ElseIf (QRY->TABELA == 'GF6')
    @nLin, 001 PSAY STR0034 //Taxa/Diแria
    @nLin++          
    cTpTab := QRY->TABELA
   Else
    @nLin, 001 PSAY STR0004 //Procedimento
    @nLin++
    cTpTab := QRY->TABELA
   EndIf
  EndIF
  
  @nLin++
  @nLin, 005 PSAY QRY->CODDES
  @nLin, 022 PSAY SUBSTR(QRY->DESCRI, 1, 50)
  @nlin, 085 PSAY TRANSFORM(QRY->VALGLO, "@E 9999,999.99")
  @nlin, 100 PSAY TRANSFORM(QRY->VALREC, "@E 9999,999.99")
  @nlin, 113 PSAY TRANSFORM(QRY->VALPER, "@E 9999,999.99")  
  nLin += 1
  @nLin, 015 PSAY QRY->GDMDESC
  @nLin, 060 PSAY QRY->DSJGLO
  
  cRegAte   := QRY->REGATE     
  cNrGuia   := QRY->NRGUIA 
 
  nFatGuia  += QRY->VALGLO 
  nRecGuia  += QRY->VALREC
  nPerGuia  += QRY->VALPER
  
 
  nFatFat   += QRY->VALGLO
  nRecFat   += QRY->VALREC
  nPerFat   += QRY->VALPER
 
 
  nFatCon   += QRY->VALGLO
  nRecCon   += QRY->VALREC
  nPerCon   += QRY->VALPER
 
 
  nFatGer   += QRY->VALGLO
  nRecGer   += QRY->VALREC
  nPerGer   += QRY->VALPER   
 
 
  nLin += 1  
  DbSkip()
 End
 cCodCon := ""
 cNrFatu := ""
 cSerie  := ""
 cNumRec := "" 
 FS_Totalizar()
 FS_Quebra()

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
ฑฑบFuno    ณFS_Quebra บ Autor ณ Cibele Peria       บ Data ณ  30/04/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Tratamento das quebras de convenio/fatura(titulo)/paciente บฑฑ
ฑฑบ          ณ Imprime o total de cada quebra e o novo cabecalho          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_Quebra()
 Local aArea  := GetArea()
 Local  cObservacao := "" //cNumRec := "",
 Local nMemoLin, nCont
    
 //Tratamento dos cabecalhos da nova quebra
 If !Eof()   
  If(QRY->CODCON <> cCodCon)
   FS_Cabec()
   nLin += 1                          
   @nLin, 000 PSAY QRY->NREDUZ
   nLin += 1
   cCodCon := QRY->CODCON
   cNrFatu := ""
   cTpTab  := ""
  Endif

  If (QRY->NRFATU <> cNrFatu) .or. 	(QRY->SERIE <> cSerie)  .or. (QRY->NUMREC <>cNumRec)
   If nLin+2 > nMaxLin
    FS_Cabec()
   Endif  
   
   nLin += 1
   @nLin, 000 PSAY STR0016 + QRY->NRFATU + "/" + QRY->SERIE + STR0017 + QRY->NUMREC //"Titulo: "###" - Recurso: "
   @nlin, 054 PSAY SUBSTR(STR0005,1,10)+ "==>"+TRANSFORM(QRY->VLRECU, "@E 9999,999.99")
   nLin += 1

   
   aArea := GetArea()
   DbSelectArea("GF0")
   DbSetOrder(1) 
   If DbSeek(xFilial("GF0")+cNumRec+cCodCon)
    cObservacao := GF0->GF0_OBSERV
   EndIf
   RestArea(aArea)
   @nLin, 000 PSAY STR0028
   nMemoLin := MlCount(cObservacao,110)
   
   For nCont := 1 To nMemoLin
	  	@ nLin, 013 PSAY MemoLine(cObservacao,110, nCont)
		  nLin++
		  If nLin >= nMaxLin
		  	FS_Cabec()
		  EndIf
	  Next nCont

   cNrFatu := QRY->NRFATU
   cSerie  := QRY->SERIE
   cNumRec := QRY->NUMREC
  Endif
  
  If nLin+3 > nMaxLin
   FS_Cabec()
  Endif
  nLin += 1
  @nLin, 000 PSAY STR0029+QRY->REGATE+" - "+DTOC(STOD(QRY->DATATE))+" "+QRY->HORATE //Atendimento 
  @nLin, 038 PSAY STR0030+QRY->REGGER+" - "+SUBSTR(QRY->NOME, 1, 18)
  @nLin, 080 PSAY STR0031+QRY->NRGUIA+"   "+STR0035+QRY->NRLOTE
  
  nLin +=1
 Else                  
  FS_Total(STR0015, nRcuGer, nFatGer, nRecGer, nPerGer) //"Total Geral" 
 Endif
  
Return()

Static Function FS_Totalizar()
 If (QRY->NRGUIA <> cNrGuia).And.(nFatGuia > 0 .or. nRecGuia > 0 .Or. nPerGuia > 0) 
  FS_Total(STR0032, nRcuGuia, nFatGuia, nRecGuia, nPerGuia) //"Total da Guia"
  nRcuGuia  := 0
  nFatGuia  := 0
  nRecGuia  := 0
  nPerGuia  := 0
 EndIf
 If ((QRY->NRFATU <> cNrFatu) .or. (QRY->SERIE <> cSerie) .or. (QRY->NUMREC <>cNumRec) ) .And.;
    (nFatFat > 0 .or. nRecFat > 0 .Or. nPerFat > 0)   
  FS_Total(STR0013, nRcuFat, nFatFat, nRecFat, nPerFat) //"Total do Titulo"
  nRcuFat   := 0
  nFatFat   := 0
  nRecFat   := 0
  nPerFat   := 0
 EndIf         
 If (QRY->CODCON <> cCodCon).And.(nFatCon > 0 .or. nRecCon > 0 .Or. nPerCon > 0) 
  FS_Total(STR0014, nRcuCon, nFatCon, nRecCon, nPerCon) //"Total do Convenio"
  nRcuCon   := 0
  nFatCon   := 0
  nRecCon   := 0
  nPerCon   := 0
 EndIf
 
return(nil)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_Total  บ Autor ณ Cibele Peria       บ Data ณ  30/04/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Cabecalho do relatorio                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_Total(cTotal, nVlRecu, nValFat, nValRec, nValPer)
 If nLin+2 > nMaxLin
  FS_Cabec()
 Endif
 nLin += 1                                                     
 @nLin, 000 PSAY cTotal
 @nlin, 085 PSAY TRANSFORM(nValFat, "@E 9999,999.99")
 @nlin, 100 PSAY TRANSFORM(nValRec, "@E 9999,999.99")
 @nlin, 113 PSAY TRANSFORM(nValPer, "@E 9999,999.99")  
 nLin += 1
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_Cabec  บ Autor ณ Cibele Peria       บ Data ณ  30/04/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Cabecalho do relatorio                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_Cabec(cTotal)
 Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo, ,.T.) 
 nLin := 8
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออหอออออออัออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_VldUserChooseบ Autor ณ Bruno Santos บ Data ณ  23/04/07   บฑฑ
ฑฑฬออออออออออุออออออออออออออออสอออออออฯออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Valida็ใo da escolha do usuแrio                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_VldUserChoose(aArgs)
 Local lRet := .F.
 Local cValidField
 Local cMsgError
 Local nCont
 
 For nCont := 1 to Len(aArgs) 
  cValidField := aArgs[nCont][1]
  cMsgError   := aArgs[nCont][2]

  If (Empty(cValidField)) .And. (!lRet) 
   lRet := .T.
   HS_MsgInf(cMsgError, STR0024, STR0003)          
  EndIf
   
 Next nCont
Return(lRet)