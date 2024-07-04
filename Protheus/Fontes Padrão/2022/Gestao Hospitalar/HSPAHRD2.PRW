#INCLUDE "HSPAHRD2.ch"
#Include "protheus.ch"
#include "TopConn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHRD2 บ Autor ณ Cibele Peria       บ Data ณ  01/04/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Pagamento medico - Producao e Glosa                        บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHRD2()

 Local cDesc1 := STR0001 //"Este programa tem como objetivo imprimir relatorio "
 Local cDesc2 := STR0002 //"de acordo com os parametros informados pelo usuario."
 Local cDesc3 := STR0003 //"Pagamento Producao e Glosa"
 Local aOrd   := {}
 
 Private Titulo := cDesc3
 Private Cabec1 := ""
 Private Cabec2 := ""

 Private lEnd        := .F.
 Private lAbortPrint := .F.
 Private limite      := 80
 Private Tamanho     := "M"
 Private NomeProg    := "HSPAHRD2" // Coloque aqui o nome do programa para impressao no cabecalho
 Private nTipo       := 18
 Private aReturn     := { STR0005, 1, STR0006, 2, 2, 1, "", 2} //"Zebrado"###"Administracao"
 Private nLastKey    := 0
 Private cbtxt       := Space(10)
 Private cbcont      := 00
 Private CONTFL      := 01
 Private m_pag       := 01
 Private wnrel       := NomeProg
 Private nTam        := 80

 Private cCodPre_De := "", cCodPre_Ate := ""
 Private cCodCRM_De := "", cCodCRM_Ate := ""
 Private cCodCon_De := "", cCodCon_Ate := ""
 Private dDatLan_De := "", dDatLan_Ate := ""
 Private cCPagar := 0, nTipRel := 0
 
 Private lVldDic := HS_ExisDic({{"C", "GE5_VALREP"}}, .F.)
 Private cCODIMP := ""
 Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ PARAMETROS                                                       ณ
 //ณ MV_PAR01	Do prestador                                          ณ
 //ณ MV_PAR02	Ate o prestador                                       ณ
 //ณ MV_PAR03	Do profissional                                       ณ
 //ณ MV_PAR04	Ate o profissional                                    ณ
 //ณ MV_PAR05	Do convenio                                           ณ
 //ณ MV_PAR06	Ate o convenio                                        ณ
 //ณ MV_PAR07	Da data                                               ณ
 //ณ MV_PAR08	Ate a data                                            ณ
 //ณ MV_PAR09 Contas a pagar                                          ณ
 //ณ MV_PAR10 Tipo do Relatorio (Analitico/Sintetico)                 ณ
 //ณ MV_PAR11 Impressora ?                                            ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 If !Pergunte("HSPRD2", .T.)
  return
 EndIf

 nMaxLin := HS_MaxLin(cCODIMP)

 cCodPre_De  := mv_par01
 cCodPre_Ate := mv_par02
 cCodCRM_De  := mv_par03
 cCodCRM_Ate := mv_par04
 cCodCon_De  := mv_par05
 cCodCon_Ate := mv_par06
 dDatLan_De  := mv_par07
 dDatLan_Ate := mv_par08
 nCPagar     := mv_par09
 nTipRel     := mv_par10
 
 If nTipRel == 1
  Titulo += STR0030
 Else
  Titulo += STR0031
 Endif                           
 Titulo      += STR0007 //"- Periodo: "
 If Empty(dDatLan_De)
  Titulo += STR0008 + DTOC(dDatLan_Ate) //"Ate "
 Else
  Titulo += DTOC(dDatLan_De) + STR0009 + DTOC(dDatLan_Ate) //" a "
 Endif
 If nCPagar == 1
  Titulo += STR0010 //" (Contas a Pagar gerada)"
 ElseIf nCPagar == 2
  Titulo += STR0011 //" (Contas a Pagar nao gerada)"
 Endif  

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Preparacao da impressao                                          ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 wnrel := SetPrint("GDX", NomeProg, "", @Titulo, cDesc1, cDesc2, cDesc3, .T., aOrd, .T., Tamanho, , .T.)
 If nLastKey == 27
  Return()
 Endif
 SetDefault(aReturn, "GDX")
 If nLastKey == 27
  Return()
 Endif

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Preparacao diferenciada para tipo ANALITICO e SINTETICO          ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 
 If nTipRel == 1   
  Cabec1 := "  " + STR0014 //Procedimento 
          /*                     1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21
                       0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789 */
  Cabec2 := STR0004 //"     Nome                                  Guia                   Data Atd.   Cd Atd.      Repasse        Glosa      Recurso" 
 Else
          /*                     1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21
                       0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789 */
  Cabec1 := STR0029 //"  Convenio                                                                  Qtde           Repasse        Glosa      Recurso      (%)"
 Endif
	
 If Eof()
  HS_MsgInf(STR0012, STR0032, STR0033) //"Nenhum dado foi encontado para a selecao efetuada!"###"Aten็ใo"###"Diferenciada para tipo ANALITICO e SINTETICO"
 Else
  nTipo := If(aReturn[4]==1,15,18)
  If nTipRel == 1
   RptStatus({|| FS_Analit() }, Titulo)
  Else
   RptStatus({|| FS_Sintet() }, Titulo)
  Endif
 Endif 
 
 DBCloseArea()
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
ฑฑบFuno    ณFS_Analit บ Autor ณ Cibele Peria       บ Data ณ  01/04/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Rotina de execucao do relatorio ANALITICO                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_Analit()
 Local nLin := nMaxLin * 2
 Local cSQL := ""
 Private nRepPro := 0, nRepTipo := 0, nRepCon := 0, nRepCRM := 0, nRepTot := 0
 Private nGloPro := 0, nGloTipo := 0, nGloCon := 0, nGloCRM := 0, nGloTot := 0
 Private nProPro := 0, nProTipo := 0, nProCon := 0, nProCRM := 0, nProTot := 0   
 Private nRecPro := 0, nRecTipo := 0, nRecCon := 0, nRecCRM := 0, nRecTot := 0 
 Private cCodCRM := "", cCodCon := "", cCodPro := "", cTipoDes := ""
 
 cSQL := " SELECT "
 
 If lVldDic
  cSQL += " GDX.GDX_CODCRM CODCRM, GCZ.GCZ_CODCON CODCON, GA9.GA9_NREDUZ NREDUZ, GE5.GE5_CODDES CODDES, SB1.B1_DESC DESCR,  GCY.GCY_REGGER REGGER, "
  cSQL += " GCY.GCY_NOME   NOME,   GCZ.GCZ_NRGUIA NRGUIA, GCY.GCY_DATATE DATATE, GCY.GCY_REGATE REGATE, GE5.GE5_VALREP VALREP, GE5.GE5_VLRGLO VLRGLO, "
  cSQL += " GE5.GE5_VLRREC VLRREC, CASE GBI.GBI_TIPO WHEN '0' THEN '1-Material' WHEN '1' THEN '2-Medicamento' END TIPODES "
  cSQL += " FROM " + RetSQLName("GDX") + " GDX " 
  cSQL += " JOIN " + RetSQLName("GE5") + " GE5 ON GE5.GE5_NREXTM = GDX.GDX_NREXTM AND GE5.GE5_FILIAL = '" + xFilial("GE5") + "' AND GE5.D_E_L_E_T_ <> '*' "
  cSQL += " JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_NRSEQG = GE5.GE5_NRSEQG AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
  cSQL += " JOIN " + RetSQLName("GCY") + " GCY ON GCY.GCY_REGATE = GCZ.GCZ_REGATE AND GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "
  cSQL += " JOIN " + RetSQLName("GA9") + " GA9 ON GA9.GA9_CODCON = GCZ.GCZ_CODCON AND GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*' "
  cSQL += " JOIN " + RetSQLName("SB1") + " SB1 ON SB1.B1_COD     = GE5.GE5_CODDES AND SB1.B1_FILIAL  = '" + xFilial("SB1")+ "' AND SB1.D_E_L_E_T_ <> '*' "
  cSQL += " JOIN " + RetSQLName("GBI") + " GBI ON GBI.GBI_PRODUT = GE5.GE5_CODDES AND GBI.GBI_FILIAL = '" + xFilial("GBI") + "' AND GBI.D_E_L_E_T_ <> '*' "
  cSQL += " WHERE "
  cSQL += " GDX.GDX_FILIAL = '" + xFilial("GDX") + "' AND GDX.D_E_L_E_T_ <> '*' AND GBI.GBI_TIPO IN ('0','1') "
  cSQL += " AND GDX.GDX_CODPRE BETWEEN '" + cCodPre_De + "' AND '" + cCodPre_Ate + "' "
  cSQL += " AND GDX.GDX_CODCRM BETWEEN '" + cCodCRM_De + "' AND '" + cCodCRM_Ate + "' " 
  cSQL += " AND GCZ.GCZ_CODCON BETWEEN '" + cCodCon_De + "' AND '" + cCodCon_Ate + "' "
  cSQL += " AND GDX.GDX_DATLAN BETWEEN '" + DTOS(dDatLan_De) + "' AND '" + DTOS(dDatLan_Ate) + "' "
  If nCPagar == 1
  	cSQL += " AND GDX.GDX_CODCPG <> '" + Space(Len(GDX->GDX_CODCPG)) + "' "
  ElseIf nCPagar == 2
   cSQL += " AND GDX.GDX_CODCPG = '" + Space(Len(GDX->GDX_CODCPG)) + "' "
  Endif 
  cSQL += " UNION ALL "
  cSQL += " SELECT GDX.GDX_CODCRM CODCRM, GCZ.GCZ_CODCON CODCON, GA9.GA9_NREDUZ NREDUZ, GE6.GE6_CODTXC CODDES, GAA.GAA_DESC   DESCR,  GCY.GCY_REGGER REGGER, "
  cSQL += " GCY.GCY_NOME   NOME,   GCZ.GCZ_NRGUIA NRGUIA, GCY.GCY_DATATE DATATE, GCY.GCY_REGATE REGATE, GE6.GE6_VALREP VALREP, GE6.GE6_VLRGLO VLRGLO, "
  cSQL += " GE6.GE6_VLRREC VLRREC, CASE GAA.GAA_TIPDES WHEN '2' THEN '3-Taxa' WHEN '7' THEN '4-Diaria' END TIPODES "
  cSQL += " FROM " + RetSQLName("GDX") + " GDX "
  cSQL += " JOIN " + RetSQLName("GE6") + " GE6 ON GE6.GE6_NREXTM = GDX.GDX_NREXTM AND GE6.GE6_FILIAL = '" + xFilial("GE6") + "' AND GE6.D_E_L_E_T_ <> '*' "
  cSQL += " JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_NRSEQG = GE6.GE6_NRSEQG AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
  cSQL += " JOIN " + RetSQLName("GCY") + " GCY ON GCY.GCY_REGATE = GCZ.GCZ_REGATE AND GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "
  cSQL += " JOIN " + RetSQLName("GA9") + " GA9 ON GA9.GA9_CODCON = GCZ.GCZ_CODCON AND GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*' "
  cSQL += " JOIN " + RetSQLName("GAA") + " GAA ON GAA.GAA_CODTXD = GE6.GE6_CODTXC AND GAA.GAA_FILIAL = '" + xFilial("GAA") + "' AND GAA.D_E_L_E_T_ <> '*' "
  cSQL += " WHERE "
  cSQL += " GDX.GDX_FILIAL = '" + xFilial("GDX") + "' AND GDX.D_E_L_E_T_ <> '*' AND GAA.GAA_TIPDES IN ('2','7') "
  cSQL += " AND GDX.GDX_CODPRE BETWEEN '" + cCodPre_De + "' AND '" + cCodPre_Ate + "' "
  cSQL += " AND GDX.GDX_CODCRM BETWEEN '" + cCodCRM_De + "' AND '" + cCodCRM_Ate + "' " 
  cSQL += " AND GCZ.GCZ_CODCON BETWEEN '" + cCodCon_De + "' AND '" + cCodCon_Ate + "' "
  cSQL += " AND GDX.GDX_DATLAN BETWEEN '" + DTOS(dDatLan_De) + "' AND '" + DTOS(dDatLan_Ate) + "' "
  If nCPagar == 1
  	cSQL += " AND GDX.GDX_CODCPG <> '" + Space(Len(GDX->GDX_CODCPG)) + "' "
  ElseIf nCPagar == 2
   cSQL += " AND GDX.GDX_CODCPG = '" + Space(Len(GDX->GDX_CODCPG)) + "' "
  Endif
  cSQL += " UNION ALL "
  cSQL += " SELECT GDX.GDX_CODCRM CODCRM, GCZ.GCZ_CODCON CODCON, GA9.GA9_NREDUZ NREDUZ, GG5.GG5_CODDES CODDES, SB1.B1_DESC DESCR,  GCY.GCY_REGGER REGGER, "
  cSQL += " GCY.GCY_NOME   NOME,   GCZ.GCZ_NRGUIA NRGUIA, GCY.GCY_DATATE DATATE, GCY.GCY_REGATE REGATE, GG5.GG5_VALREP VALREP, GG5.GG5_VLRGLO VLRGLO, "
  cSQL += " GG5.GG5_VLRREC VLRREC, CASE GBI.GBI_TIPO WHEN '0' THEN '1-Material' WHEN '1' THEN '2-Medicamento' END TIPODES "
  cSQL += " FROM " + RetSQLName("GDX") + " GDX "  
  cSQL += " JOIN " + RetSQLName("GG5") + " GG5 ON GG5.GG5_NREXTM = GDX.GDX_NREXTM AND GG5.GG5_FILIAL = '" + xFilial("GG5") + "' AND GG5.D_E_L_E_T_ <> '*' "
  cSQL += " JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_NRSEQG = GG5.GG5_NRSEQG AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
  cSQL += " JOIN " + RetSQLName("GCY") + " GCY ON GCY.GCY_REGATE = GCZ.GCZ_REGATE AND GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "
  cSQL += " JOIN " + RetSQLName("GA9") + " GA9 ON GA9.GA9_CODCON = GCZ.GCZ_CODCON AND GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*' "
  cSQL += " JOIN " + RetSQLName("SB1") + " SB1 ON SB1.B1_COD     = GG5.GG5_CODDES AND SB1.B1_FILIAL  = '" + xFilial("SB1") + "' AND SB1.D_E_L_E_T_ <> '*' "
  cSQL += " JOIN " + RetSQLName("GBI") + " GBI ON GBI.GBI_PRODUT = GG5.GG5_CODDES AND GBI.GBI_FILIAL = '" + xFilial("GBI") + "' AND GBI.D_E_L_E_T_ <> '*' "
  cSQL += " JOIN " + RetSQLName("GE7") + " GE7 ON GE7.GE7_SEQDES = GG5.GG5_SEQGE7 AND GE7.GE7_FILIAL = '" + xFilial("GE7") + "' AND GE7.D_E_L_E_T_ <> '*' "
  cSQL += " WHERE "
  cSQL += " GDX.GDX_FILIAL = '" + xFilial("GDX") + "' AND GDX.D_E_L_E_T_ <> '*' AND GBI.GBI_TIPO IN ('0','1') "
  cSQL += " AND GDX.GDX_CODPRE BETWEEN '" + cCodPre_De + "' AND '" + cCodPre_Ate + "' "
  cSQL += " AND GDX.GDX_CODCRM BETWEEN '" + cCodCRM_De + "' AND '" + cCodCRM_Ate + "' " 
  cSQL += " AND GCZ.GCZ_CODCON BETWEEN '" + cCodCon_De + "' AND '" + cCodCon_Ate + "' "
  cSQL += " AND GDX.GDX_DATLAN BETWEEN '" + DTOS(dDatLan_De) + "' AND '" + DTOS(dDatLan_Ate) + "' "
  If nCPagar == 1
  	cSQL += " AND GDX.GDX_CODCPG <> '" + Space(Len(GDX->GDX_CODCPG)) + "' "
  ElseIf nCPagar == 2
   cSQL += " AND GDX.GDX_CODCPG = '" + Space(Len(GDX->GDX_CODCPG)) + "' "
  Endif
  cSQL += " UNION ALL "
  cSQL += " SELECT GDX.GDX_CODCRM CODCRM, GCZ.GCZ_CODCON CODCON, GA9.GA9_NREDUZ NREDUZ, GG6.GG6_CODDES CODDES, GAA.GAA_DESC DESCR, GCY.GCY_REGGER REGGER, "
  cSQL += " GCY.GCY_NOME NOME, GCZ.GCZ_NRGUIA NRGUIA, GCY.GCY_DATATE DATATE, GCY.GCY_REGATE REGATE, GG6.GG6_VALREP VALREP, GG6.GG6_VLRGLO VLRGLO, "
  cSQL += " GG6.GG6_VLRREC VLRREC, CASE GAA.GAA_TIPDES WHEN '2' THEN '3-Taxa' WHEN '7' THEN '4-Diaria' END AS TIPODES "
  cSQL += " FROM " + RetSQLName("GDX") + " GDX "      
  cSQL += " JOIN " + RetSQLName("GG6") + " GG6 ON GG6.GG6_NREXTM = GDX.GDX_NREXTM AND GG6.GG6_FILIAL = '" + xFilial("GG6") + "' AND GG6.D_E_L_E_T_ <> '*' "
  cSQL += " JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_NRSEQG = GG6.GG6_NRSEQG AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
  cSQL += " JOIN " + RetSQLName("GCY") + " GCY ON GCY.GCY_REGATE = GCZ.GCZ_REGATE AND GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "
  cSQL += " JOIN " + RetSQLName("GA9") + " GA9 ON GA9.GA9_CODCON = GCZ.GCZ_CODCON AND GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*' "
  cSQL += " JOIN " + RetSQLName("GAA") + " GAA ON GAA.GAA_CODTXD = GG6.GG6_CODDES AND GAA.GAA_FILIAL = '" + xFilial("GAA") + "' AND GAA.D_E_L_E_T_ <> '*' "
  cSQL += " JOIN " + RetSQLName("GE7") + " GE7 ON GE7.GE7_SEQDES = GG6.GG6_SEQGE7 AND GE7.GE7_FILIAL = '" + xFilial("GG6") + "' AND GE7.D_E_L_E_T_ <> '*' "
  cSQL += " WHERE "
  cSQL += " GDX.GDX_FILIAL = '" + xFilial("GDX") + "' AND GDX.D_E_L_E_T_ <> '*' AND GAA.GAA_TIPDES IN ('2','7') "
  cSQL += " AND GDX.GDX_CODPRE BETWEEN '" + cCodPre_De + "' AND '" + cCodPre_Ate + "' "
  cSQL += " AND GDX.GDX_CODCRM BETWEEN '" + cCodCRM_De + "' AND '" + cCodCRM_Ate + "' " 
  cSQL += " AND GCZ.GCZ_CODCON BETWEEN '" + cCodCon_De + "' AND '" + cCodCon_Ate + "' "
  cSQL += " AND GDX.GDX_DATLAN BETWEEN '" + DTOS(dDatLan_De) + "' AND '" + DTOS(dDatLan_Ate) + "' "
  If nCPagar == 1
  	cSQL += " AND GDX.GDX_CODCPG <> '" + Space(Len(GDX->GDX_CODCPG)) + "' "
  ElseIf nCPagar == 2
   cSQL += " AND GDX.GDX_CODCPG = '" + Space(Len(GDX->GDX_CODCPG)) + "' "
  Endif
  cSQL += " UNION ALL "
  cSQL += " SELECT "
 Endif
 cSQL += " GDX.GDX_CODCRM CODCRM, GCZ.GCZ_CODCON CODCON, GA9.GA9_NREDUZ NREDUZ, GE7.GE7_CODDES CODDES, GA7.GA7_DESC DESCR,  GCY.GCY_REGGER REGGER, "
 cSQL += " GCY.GCY_NOME   NOME,   GCZ.GCZ_NRGUIA NRGUIA, GCY.GCY_DATATE DATATE, GCY.GCY_REGATE REGATE, GE7.GE7_VALREP VALREP, GE7.GE7_VLRGLO VLRGLO, "
 cSQL += " GE7.GE7_VLRREC VLRREC, '5-Procedimento' TIPODES "
 cSQL += " FROM " + RetSQLName("GDX") + " GDX "
 cSQL += " JOIN " + RetSQLName("GE7") + " GE7 ON GE7.GE7_NREXTM = GDX.GDX_NREXTM AND GE7.GE7_FILIAL = '" + xFilial("GE7") + "' AND GE7.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_NRSEQG = GE7.GE7_NRSEQG AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GCY") + " GCY ON GCY.GCY_REGATE = GCZ.GCZ_REGATE AND GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GA9") + " GA9 ON GA9.GA9_CODCON = GCZ.GCZ_CODCON AND GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GA7") + " GA7 ON GA7.GA7_CODPRO = GE7.GE7_CODDES AND GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' "
 cSQL += " WHERE "
 cSQL += " GDX.GDX_FILIAL = '" + xFilial("GDX") + "' AND GDX.D_E_L_E_T_ <> '*' AND GA7.GA7_TIPPRO <> '9' "
 cSQL += " AND GDX.GDX_CODPRE BETWEEN '" + cCodPre_De + "' AND '" + cCodPre_Ate + "' "
 cSQL += " AND GDX.GDX_CODCRM BETWEEN '" + cCodCRM_De + "' AND '" + cCodCRM_Ate + "' " 
 cSQL += " AND GCZ.GCZ_CODCON BETWEEN '" + cCodCon_De + "' AND '" + cCodCon_Ate + "' "
 cSQL += " AND GDX.GDX_DATLAN BETWEEN '" + DTOS(dDatLan_De) + "' AND '" + DTOS(dDatLan_Ate) + "' "
 If nCPagar == 1
 	cSQL += " AND GDX.GDX_CODCPG <> '" + Space(Len(GDX->GDX_CODCPG)) + "' "
 ElseIf nCPagar == 2
  cSQL += " AND GDX.GDX_CODCPG = '" + Space(Len(GDX->GDX_CODCPG)) + "' "
 Endif
 cSQL += " UNION ALL "
 cSQL += " SELECT GDX.GDX_CODCRM CODCRM, GCZ.GCZ_CODCON CODCON, GA9.GA9_NREDUZ NREDUZ, GG7.GG7_CODDES CODDES, GA7.GA7_DESC DESCR, GCY.GCY_REGGER REGGER, "
 cSQL += " GCY.GCY_NOME   NOME,   GCZ.GCZ_NRGUIA NRGUIA, GCY.GCY_DATATE DATATE, GCY.GCY_REGATE REGATE, GG7.GG7_VALREP VALREP, GG7.GG7_VLRGLO VLRGLO, "
 cSQL += " GG7.GG7_VLRREC VLRREC, '5-Procedimento' TIPODES "
 cSQL += " FROM " + RetSQLName("GDX") + " GDX "
 cSQL += " JOIN " + RetSQLName("GG7") + " GG7 ON GG7.GG7_NREXTM = GDX.GDX_NREXTM AND GG7.GG7_FILIAL = '" + xFilial("GG7") + "' AND GG7.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_NRSEQG = GG7.GG7_NRSEQG AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GCY") + " GCY ON GCY.GCY_REGATE = GCZ.GCZ_REGATE AND GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GA9") + " GA9 ON GA9.GA9_CODCON = GCZ.GCZ_CODCON AND GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GA7") + " GA7 ON GA7.GA7_CODPRO = GG7.GG7_CODDES AND GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GE7") + " GE7 ON GE7.GE7_SEQDES = GG7.GG7_SEQGE7 AND GE7.GE7_FILIAL = '" + xFilial("GE7") + "' AND GE7.D_E_L_E_T_ <> '*' "
 cSQL += " WHERE "
 cSQL += " GDX.GDX_FILIAL = '" + xFilial("GDX") + "' AND GDX.D_E_L_E_T_ <> '*' "
 cSQL += " AND GDX.GDX_CODPRE BETWEEN '" + cCodPre_De + "' AND '" + cCodPre_Ate + "' "
 cSQL += " AND GDX.GDX_CODCRM BETWEEN '" + cCodCRM_De + "' AND '" + cCodCRM_Ate + "' " 
 cSQL += " AND GCZ.GCZ_CODCON BETWEEN '" + cCodCon_De + "' AND '" + cCodCon_Ate + "' "
 cSQL += " AND GDX.GDX_DATLAN BETWEEN '" + DTOS(dDatLan_De) + "' AND '" + DTOS(dDatLan_Ate) + "' "
 If nCPagar == 1
 	cSQL += " AND GDX.GDX_CODCPG <> '" + Space(Len(GDX->GDX_CODCPG)) + "' "
 ElseIf nCPagar == 2
  cSQL += " AND GDX.GDX_CODCPG = '" + Space(Len(GDX->GDX_CODCPG)) + "' "
 Endif

 cSQL += " ORDER BY CODCRM, NREDUZ, TIPODES, NOME "
 
 TCQuery cSQL NEW ALIAS "QRY"
 TCSetField("QRY","DATATE","D")
 DbSelectArea("QRY")
 DbGoTop()

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Processamento da impressao                                          ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
  SetRegua(1000)
 
 While !EOF()                                                                                
  IncRegua()
  
  If QRY->CODCRM <> cCodCRM .or. QRY->CODCON <> cCodCon .or. QRY->TIPODES <> cTipoDes .or. QRY->CODDES <> cCodPro
   nLin := FS_Quebra(nLin)
  Endif 
  
  If nLin+1 > nMaxLin
   nLin := FS_Cabec(nLin)
  Endif 
  nLin += 1
  @nLin, 005 PSAY SUBSTR(QRY->NOME,1,35)
  @nLin, 043 PSAY QRY->NRGUIA
  @nLin, 066 PSAY QRY->DATATE
  @nLin, 079 PSAY QRY->REGATE
  @nLin, 087 PSAY TRANSFORM(QRY->VALREP, "@E 9999,999.99")
  @nLin, 100 PSAY TRANSFORM(QRY->VLRGLO, "@E 9999,999.99")
  @nLin, 113 PSAY TRANSFORM(QRY->VLRREC, "@E 9999,999.99")
  
  nRepPro += QRY->VALREP
  nGloPro += QRY->VLRGLO
  nRecPro += QRY->VLRREC
  nProPro += 1
  
  DbSelectArea("QRY")
  DbSkip()
 End
 
 FS_Final(nLin)

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_Sintet บ Autor ณ Cibele Peria       บ Data ณ  21/07/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Rotina de execucao do relatorio SINTETICO                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_Sintet()
 Local   nLin := nMaxLin * 2
 Local   aTotCRM := {}, nPos := 0
 Local   nTotCRM := 0 
 Local      cSQL := ""
 Private nRepCRM := 0, nRepTot := 0
 Private nGloCRM := 0, nGloTot := 0
 Private nProCRM := 0, nProTot := 0
 Private nRecCRM := 0, nRecTot := 0
 Private cCodCon := ""
 Private cCodCRM := ""
 
 cSQL := " SELECT "
 
 If lVldDic
  cSQL += " GDX.GDX_CODCRM CODCRM, GCZ.GCZ_CODCON CODCON, GA9.GA9_NREDUZ NREDUZ, COUNT(*) QTDPRO, SUM(GE5.GE5_VALREP) VALREP, SUM(GE5_VLRGLO) VLRGLO, "
  cSQL += " SUM(GE5_VLRREC) VLRREC "
  cSQL += " FROM " + RetSQLName("GDX") + " GDX "        
  cSQL += " JOIN " + RetSQLName("GE5") + " GE5 ON GE5.GE5_NREXTM = GDX.GDX_NREXTM AND GE5.GE5_FILIAL = '" + xFilial("GE5") + "' AND GE5.D_E_L_E_T_ <> '*' "
  cSQL += " JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_NRSEQG = GE5.GE5_NRSEQG AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
  cSQL += " JOIN " + RetSQLName("GA9") + " GA9 ON GA9.GA9_CODCON = GCZ.GCZ_CODCON AND GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*' "
  cSQL += " JOIN " + RetSQLName("SB1") + " SB1 ON SB1.B1_COD     = GE5.GE5_CODDES AND SB1.B1_FILIAL  = '" + xFilial("SB1") + "' AND SB1.D_E_L_E_T_ <> '*' "
  cSQL += " JOIN " + RetSQLName("GBI") + " GBI ON GBI.GBI_PRODUT = GE5.GE5_CODDES AND GBI.GBI_FILIAL = '" + xFilial("GBI") + "' AND GBI.D_E_L_E_T_ <> '*' "
  cSQL += " WHERE " 
  cSQL += " GDX.GDX_FILIAL = '" + xFilial("GDX") + "' AND GDX.D_E_L_E_T_ <> '*' AND GBI.GBI_TIPO IN ('0','1') "
  cSQL += " AND GDX.GDX_CODPRE BETWEEN '" + cCodPre_De + "' AND '" + cCodPre_Ate + "' "
  cSQL += " AND GDX.GDX_CODCRM BETWEEN '" + cCodCRM_De + "' AND '" + cCodCRM_Ate + "' " 
  cSQL += " AND GCZ.GCZ_CODCON BETWEEN '" + cCodCon_De + "' AND '" + cCodCon_Ate + "' "
  cSQL += " AND GDX.GDX_DATLAN BETWEEN '" + DTOS(dDatLan_De) + "' AND '" + DTOS(dDatLan_Ate) + "' "
  If nCPagar == 1
  	cSQL += " AND GDX.GDX_CODCPG <> '" + Space(Len(GDX->GDX_CODCPG)) + "' "
  ElseIf nCPagar == 2
   cSQL += " AND GDX.GDX_CODCPG = '" + Space(Len(GDX->GDX_CODCPG)) + "' "
  Endif 
  cSQL += " GROUP BY GDX.GDX_CODCRM, GCZ.GCZ_CODCON, GA9.GA9_NREDUZ "
  cSQL += " UNION ALL "
  cSQL += " SELECT GDX.GDX_CODCRM CODCRM, GCZ.GCZ_CODCON CODCON, GA9.GA9_NREDUZ NREDUZ, COUNT(*) QTDPRO, SUM(GE6.GE6_VALREP) VALREP, SUM(GE6_VLRGLO) VLRGLO, "
  cSQL += " SUM(GE6_VLRREC) VLRREC "
  cSQL += " FROM " + RetSQLName("GDX") + " GDX "      
  cSQL += " JOIN " + RetSQLName("GE6") + " GE6 ON GE6.GE6_NREXTM = GDX.GDX_NREXTM AND GE6.GE6_FILIAL = '" + xFilial("GE6") + "' AND GE6.D_E_L_E_T_ <> '*' "
  cSQL += " JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_NRSEQG = GE6.GE6_NRSEQG AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
  cSQL += " JOIN " + RetSQLName("GA9") + " GA9 ON GA9.GA9_CODCON = GCZ.GCZ_CODCON AND GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*' "
  cSQL += " JOIN " + RetSQLName("GAA") + " GAA ON GAA.GAA_CODTXD = GE6.GE6_CODTXC AND GAA.GAA_FILIAL = '" + xFilial("GAA") + "' AND GAA.D_E_L_E_T_ <> '*' "
  cSQL += " WHERE "
  cSQL += " GDX.GDX_FILIAL = '" + xFilial("GDX") + "' AND GDX.D_E_L_E_T_ <> '*' AND GAA.GAA_TIPDES IN ('2','7') "
  cSQL += " AND GDX.GDX_CODPRE BETWEEN '" + cCodPre_De + "' AND '" + cCodPre_Ate + "' "
  cSQL += " AND GDX.GDX_CODCRM BETWEEN '" + cCodCRM_De + "' AND '" + cCodCRM_Ate + "' " 
  cSQL += " AND GCZ.GCZ_CODCON BETWEEN '" + cCodCon_De + "' AND '" + cCodCon_Ate + "' "
  cSQL += " AND GDX.GDX_DATLAN BETWEEN '" + DTOS(dDatLan_De) + "' AND '" + DTOS(dDatLan_Ate) + "' "
  If nCPagar == 1
  	cSQL += " AND GDX.GDX_CODCPG <> '" + Space(Len(GDX->GDX_CODCPG)) + "' "
  ElseIf nCPagar == 2
   cSQL += " AND GDX.GDX_CODCPG = '" + Space(Len(GDX->GDX_CODCPG)) + "' "
  Endif 
  cSQL += " GROUP BY GDX.GDX_CODCRM, GCZ.GCZ_CODCON, GA9.GA9_NREDUZ "
  cSQL += " UNION ALL "
  cSQL += " SELECT GDX.GDX_CODCRM CODCRM, GCZ.GCZ_CODCON CODCON, GA9.GA9_NREDUZ NREDUZ, COUNT(*) QTDPRO, SUM(GG5.GG5_VALREP) VALREP, SUM(GG5_VLRGLO) VLRGLO, "
  cSQL += " SUM(GG5_VLRREC) VLRREC "
  cSQL += " FROM " + RetSQLName("GDX") + " GDX "
  cSQL += " JOIN " + RetSQLName("GG5") + " GG5 ON GG5.GG5_NREXTM = GDX.GDX_NREXTM AND GG5.GG5_FILIAL = '" + xFilial("GG5") + "' AND GG5.D_E_L_E_T_ <> '*' "
  cSQL += " JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_NRSEQG = GG5.GG5_NRSEQG AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
  cSQL += " JOIN " + RetSQLName("GA9") + " GA9 ON GA9.GA9_CODCON = GCZ.GCZ_CODCON AND GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*' "
  cSQL += " JOIN " + RetSQLName("SB1") + " SB1 ON SB1.B1_COD     = GG5.GG5_CODDES AND SB1.B1_FILIAL  = '" + xFilial("SB1") + "' AND SB1.D_E_L_E_T_ <> '*' "
  cSQL += " JOIN " + RetSQLName("GBI") + " GBI ON GBI.GBI_PRODUT = GG5.GG5_CODDES AND GBI.GBI_FILIAL = '" + xFilial("GBI") + "' AND GBI.D_E_L_E_T_ <> '*' "
  cSQL += " JOIN " + RetSQLName("GE7") + " GE7 ON GE7.GE7_SEQDES = GG5.GG5_SEQGE7 AND GE7.GE7_FILIAL = '" + xFilial("GE7") + "' AND GE7.D_E_L_E_T_ <> '*' "
  cSQL += " WHERE "
  cSQL += " GDX.GDX_FILIAL = '" + xFilial("GDX") + "' AND GDX.D_E_L_E_T_ <> '*' AND GBI.GBI_TIPO IN ('0','1') "
  cSQL += " AND GDX.GDX_CODPRE BETWEEN '" + cCodPre_De + "' AND '" + cCodPre_Ate + "' "
  cSQL += " AND GDX.GDX_CODCRM BETWEEN '" + cCodCRM_De + "' AND '" + cCodCRM_Ate + "' " 
  cSQL += " AND GCZ.GCZ_CODCON BETWEEN '" + cCodCon_De + "' AND '" + cCodCon_Ate + "' "
  cSQL += " AND GDX.GDX_DATLAN BETWEEN '" + DTOS(dDatLan_De) + "' AND '" + DTOS(dDatLan_Ate) + "' "
  If nCPagar == 1
  	cSQL += " AND GDX.GDX_CODCPG <> '" + Space(Len(GDX->GDX_CODCPG)) + "' "
  ElseIf nCPagar == 2
   cSQL += " AND GDX.GDX_CODCPG = '" + Space(Len(GDX->GDX_CODCPG)) + "' "
  Endif
  cSQL += " GROUP BY GDX.GDX_CODCRM, GCZ.GCZ_CODCON, GA9.GA9_NREDUZ "
  cSQL += " UNION ALL "
  cSQL += " SELECT GDX.GDX_CODCRM CODCRM, GCZ.GCZ_CODCON CODCON, GA9.GA9_NREDUZ NREDUZ, COUNT(*) QTDPRO, SUM(GG6.GG6_VALREP) VALREP, SUM(GG6_VLRGLO) VLRGLO, "
  cSQL += " SUM(GG6_VLRREC) VLRREC "
  cSQL += " FROM " + RetSQLName("GDX") + " GDX "      
  cSQL += " JOIN " + RetSQLName("GG6") + " GG6 ON GG6.GG6_NREXTM = GDX.GDX_NREXTM AND GG6.GG6_FILIAL = '" + xFilial("GG6") + "' AND GG6.D_E_L_E_T_ <> '*' "
  cSQL += " JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_NRSEQG = GG6.GG6_NRSEQG AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
  cSQL += " JOIN " + RetSQLName("GCY") + " GCY ON GCY.GCY_REGATE = GCZ.GCZ_REGATE AND GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "
  cSQL += " JOIN " + RetSQLName("GA9") + " GA9 ON GA9.GA9_CODCON = GCZ.GCZ_CODCON AND GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*' "
  cSQL += " JOIN " + RetSQLName("GAA") + " GAA ON GAA.GAA_CODTXD = GG6.GG6_CODDES AND GAA.GAA_FILIAL = '" + xFilial("GAA") + "' AND GAA.D_E_L_E_T_ <> '*' "
  cSQL += " JOIN " + RetSQLName("GE7") + " GE7 ON GE7.GE7_SEQDES = GG6.GG6_SEQGE7 AND GE7.GE7_FILIAL = '" + xFilial("GG6") + "' AND GE7.D_E_L_E_T_ <> '*' "
  cSQL += " WHERE "
  cSQL += " GDX.GDX_FILIAL = '" + xFilial("GDX") + "' AND GDX.D_E_L_E_T_ <> '*' AND GAA.GAA_TIPDES IN ('2','7') "
  cSQL += " AND GDX.GDX_CODPRE BETWEEN '" + cCodPre_De + "' AND '" + cCodPre_Ate + "' "
  cSQL += " AND GDX.GDX_CODCRM BETWEEN '" + cCodCRM_De + "' AND '" + cCodCRM_Ate + "' " 
  cSQL += " AND GCZ.GCZ_CODCON BETWEEN '" + cCodCon_De + "' AND '" + cCodCon_Ate + "' "
  cSQL += " AND GDX.GDX_DATLAN BETWEEN '" + DTOS(dDatLan_De) + "' AND '" + DTOS(dDatLan_Ate) + "' "
  If nCPagar == 1
  	cSQL += " AND GDX.GDX_CODCPG <> '" + Space(Len(GDX->GDX_CODCPG)) + "' "
  ElseIf nCPagar == 2
   cSQL += " AND GDX.GDX_CODCPG = '" + Space(Len(GDX->GDX_CODCPG)) + "' "
  Endif
  cSQL += " GROUP BY GDX.GDX_CODCRM, GCZ.GCZ_CODCON, GA9.GA9_NREDUZ "
 
  cSQL += " UNION ALL "
  cSQL += " SELECT "
 Endif
 
 cSQL += " GDX.GDX_CODCRM CODCRM, GCZ.GCZ_CODCON CODCON, GA9.GA9_NREDUZ NREDUZ, COUNT(*) QTDPRO, SUM(GE7.GE7_VALREP) VALREP, SUM(GE7_VLRGLO) VLRGLO, "
 cSQL += " SUM(GE7_VLRREC) VLRREC "
 cSQL += " FROM " + RetSQLName("GDX") + " GDX "       
 cSQL += " JOIN " + RetSQLName("GE7") + " GE7 ON GE7.GE7_NREXTM = GDX.GDX_NREXTM AND GE7.GE7_FILIAL = '" + xFilial("GE7") + "' AND GE7.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_NRSEQG = GE7.GE7_NRSEQG AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GA9") + " GA9 ON GA9.GA9_CODCON = GCZ.GCZ_CODCON AND GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GA7") + " GA7 ON GA7.GA7_CODPRO = GE7.GE7_CODDES AND GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' "
 cSQL += " WHERE "
 cSQL += " GDX.GDX_FILIAL = '" + xFilial("GDX") + "' AND GDX.D_E_L_E_T_ <> '*' AND GA7.GA7_TIPPRO <> '9' "
 cSQL += " AND GDX.GDX_CODPRE BETWEEN '" + cCodPre_De + "' AND '" + cCodPre_Ate + "' "
 cSQL += " AND GDX.GDX_CODCRM BETWEEN '" + cCodCRM_De + "' AND '" + cCodCRM_Ate + "' " 
 cSQL += " AND GCZ.GCZ_CODCON BETWEEN '" + cCodCon_De + "' AND '" + cCodCon_Ate + "' "
 cSQL += " AND GDX.GDX_DATLAN BETWEEN '" + DTOS(dDatLan_De) + "' AND '" + DTOS(dDatLan_Ate) + "' "
 If nCPagar == 1
 	cSQL += " AND GDX.GDX_CODCPG <> '" + Space(Len(GDX->GDX_CODCPG)) + "' "
 ElseIf nCPagar == 2
  cSQL += " AND GDX.GDX_CODCPG = '" + Space(Len(GDX->GDX_CODCPG)) + "' "
 Endif
 cSQL += " GROUP BY GDX.GDX_CODCRM, GCZ.GCZ_CODCON, GA9.GA9_NREDUZ "
 cSQL += " UNION ALL "
 cSQL += " SELECT GDX.GDX_CODCRM CODCRM, GCZ.GCZ_CODCON CODCON, GA9.GA9_NREDUZ NREDUZ, COUNT(*) QTDPRO, SUM(GG7.GG7_VALREP) VALREP, SUM(GG7_VLRGLO) VLRGLO, "
 cSQL += " SUM(GG7_VLRREC) VLRREC "
 cSQL += " FROM " + RetSQLName("GDX") + " GDX "      
 cSQL += " JOIN " + RetSQLName("GG7") + " GG7 ON GG7.GG7_NREXTM = GDX.GDX_NREXTM AND GG7.GG7_FILIAL = '" + xFilial("GG7") + "' AND GG7.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_NRSEQG = GG7.GG7_NRSEQG AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GA9") + " GA9 ON GA9.GA9_CODCON = GCZ.GCZ_CODCON AND GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GA7") + " GA7 ON GA7.GA7_CODPRO = GG7.GG7_CODDES AND GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GE7") + " GE7 ON GE7.GE7_SEQDES = GG7.GG7_SEQGE7 AND GE7.GE7_FILIAL = '" + xFilial("GE7") + "' AND GE7.D_E_L_E_T_ <> '*' "
 cSQL += " WHERE "
 cSQL += " GDX.GDX_FILIAL = '" + xFilial("GDX") + "' AND GDX.D_E_L_E_T_ <> '*' "
 cSQL += " AND GDX.GDX_CODPRE BETWEEN '" + cCodPre_De + "' AND '" + cCodPre_Ate + "' "
 cSQL += " AND GDX.GDX_CODCRM BETWEEN '" + cCodCRM_De + "' AND '" + cCodCRM_Ate + "' " 
 cSQL += " AND GCZ.GCZ_CODCON BETWEEN '" + cCodCon_De + "' AND '" + cCodCon_Ate + "' "
 cSQL += " AND GDX.GDX_DATLAN BETWEEN '" + DTOS(dDatLan_De) + "' AND '" + DTOS(dDatLan_Ate) + "' "
 If nCPagar == 1
 	cSQL += " AND GDX.GDX_CODCPG <> '" + Space(Len(GDX->GDX_CODCPG)) + "' "
 ElseIf nCPagar == 2
  cSQL += " AND GDX.GDX_CODCPG = '" + Space(Len(GDX->GDX_CODCPG)) + "' "
 Endif
 cSQL += " GROUP BY GDX.GDX_CODCRM, GCZ.GCZ_CODCON, GA9.GA9_NREDUZ "
 cSQL += " ORDER BY CODCRM, NREDUZ "

 TCQuery cSQL NEW ALIAS "QRY"
 TCSetField("QRY","DATATE","D")
 
 DbSelectArea("QRY")
 DbGotop()
 
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Sumariza os valores de repasse por mediCo, para calculo do percent. ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
  
 While !EOF()
  
  If (nPos := aScan(aTotCrm, {|aTotCrm| aTotCrm[1] == QRY->CODCRM })) == 0
   AADD(aTotCrm,{;
   QRY->CODCRM, ;      //[1]  Codigo CRM
   QRY->VALREP})       //[2]  Valor Repasse         
  Else
   aTotCrm[nPos,2]  += QRY->VALREP    
  EndIf 
  
  DbSkip()
 End

 cCodCRM := ""
 cCodCon := ""
 nRepCRM := 0
 
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Processamento da impressao                                          ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 DbGoTop()
 SetRegua(1000)
 While !EOF()                                                                                
  IncRegua()
  
  If QRY->CODCRM <> cCodCRM .Or. QRY->CODCON <> cCodCon
   nLin := FS_Quebra(nLin)
   nPos := aScan(aTotCRM, {| aVet | aVet[1] == QRY->CODCRM})
   nTotCRM := aTotCRM[nPos, 2]
  Endif 
  
  nLin := FS_Total(QRY->NREDUZ, 		QRY->VALREP, QRY->VLRGLO, QRY->VLRREC, QRY->QTDPRO, nLin, ((QRY->VALREP / nTotCRM) * 100) ) //"Geral"  
  
  nRepCRM += QRY->VALREP
  nGloCRM += QRY->VLRGLO
  nRecCRM += QRY->VLRREC
  nProCRM += QRY->QTDPRO
  
  DbSelectArea("QRY")
  DbSkip()
 End

 FS_Final(nLin)

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_Quebra บ Autor ณ Cibele Peria       บ Data ณ  04/04/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Tratamento das quebras                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_Quebra(nLin)
 Local cAliasOld := Alias()

 If nTipRel == 1 //Analitico
  If nRepPro > 0
   nLin := FS_Total(STR0018+" Despesa", nRepPro, nGloPro, nRecPro, nProPro, nLin) //"Total"###"Procedimento"
  Endif 
  nRepTipo += nRepPro
  nGloTipo += nGloPro
  nProTipo += nProPro
  nRecTipo += nRecPro
  nRepPro  := 0
  nGloPro  := 0
  nProPro  := 0
  nRecPro  := 0

  If QRY->CODCRM <> cCodCRM .or. QRY->CODCON <> cCodCon .or. QRY->TIPODES <> cTipoDes .or. Eof()
   If nRepTipo > 0
	    nLin := FS_Total(STR0018+AllTrim(SubStr(QRY->TIPODES,3)), nRepTipo, nGloTipo, nRecTipo, nProTipo, nLin) //"Total"
   Endif
   nRepCon  += nRepTipo
   nGloCon  += nGloTipo
   nProCon  += nProTipo
   nRecCon  += nRecTipo
   nRepTipo := 0
   nGloTipo := 0
   nProTipo := 0
   nRecTipo := 0
  Endif
       
  If QRY->CODCRM <> cCodCRM .or. QRY->CODCON <> cCodCon .or. Eof()
   If nRepCon > 0
	    nLin := FS_Total(STR0018+STR0015, nRepCon, nGloCon, nRecCon, nProCon, nLin) //"Total"###"Convenio"
   Endif
   nRepCRM += nRepCon
   nGloCRM += nGloCon
   nProCRM += nProCon
   nRecCRM += nRecCon
   nRepCon := 0
   nGloCon := 0
   nProCon := 0 
   nRecCon := 0
  Endif
  
 Endif
 
 If QRY->CODCRM <> cCodCRM .or. Eof()
  If nRepCRM > 0
   nLin := FS_Total(STR0018+STR0016, nRepCRM, nGloCRM, nRecCRM, nProCRM, nLin) //"Total"###"Profissional"
   nRepTot += nRepCRM
   nGloTot += nGloCRM
   nProTot += nProCRM
   nRecTot += nRecCRM
   nRepCRM := 0
   nGloCRM := 0
   nProCRM := 0  
   nRecCRM := 0  
  Endif
 Endif
 
 If !Eof()
  If QRY->CODCRM <> cCodCRM
   nLin := FS_Cabec()
   DbSelectArea("SRA")
   DbSetOrder(11)
   DbSeek(xFilial("SRA")+QRY->CODCRM)
   nLin += 1
   @nLin, 000 PSAY STR0017 + QRY->CODCRM + " " + SRA->RA_NOME //"Profissional: "
   nLin += 1  
   cCodCRM := QRY->CODCRM
   cCodCon := ""
   cCodPro := ""
  Endif
 
  If nTipRel == 1
   If QRY->CODCON <> cCodCon
    If nLin+1 > nMaxLin
     nLin := FS_Cabec()
    Endif
    nLin += 1
    @ nLin, 000 PSAY QRY->NREDUZ
    cCodCon := QRY->CODCON
    cCodPro := ""   
   Endif
   If QRY->TIPODES <> cTipoDes
    If nLin+1 > nMaxLin
     nLin := FS_Cabec()
    Endif
    nLin += 1
    @ nLin, 002 PSAY AllTrim(SubStr(QRY->TIPODES,3))
    cTipoDes := QRY->TIPODES
    cCodPro  := ""   
   Endif
   If QRY->CODDES <> cCodPro
    If nLin+1 > nMaxLin
     nLin := FS_Cabec()
    Endif
    nLin += 1
    @ nLin, 004 PSAY QRY->DESCR
    cCodPro := QRY->CODDES
   Endif 
  Endif
   
 Endif
 
 DbSelectArea(cAliasOld)
Return(nLin)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_Cabec  บ Autor ณ Cibele Peria       บ Data ณ  01/04/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Cabecalho do relatorio                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_Cabec(nLin)

 Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo, ,.T.)
 If nTipRel == 1
  nLin := 8
 Else
  nLin := 7
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
Static Function FS_Total(cDescr, nRepasse, nGlosa, nRecurso, nQtProced, nLin, nPercent)
       
 If nLin+IIF(Empty(nPercent), 2, 1) > nMaxLin
  nLin := FS_Cabec()
 Endif

 nLin += 1

 @nLin, IIf(Empty(nPercent), 054, 002) PSAY cDescr
 @nLin, 075       PSAY TRANSFORM(nQtProced, "@E 99999")
 @nLin, 087       PSAY TRANSFORM(nRepasse, "@E 9999,999.99")
 @nLin, 100	      PSAY TRANSFORM(nGlosa, "@E 9999,999.99")
 @nLin, 113	      PSAY TRANSFORM(nRecurso, "@E 9999,999.99")
 @nLin, 127       PSAY IIf(Empty(nPercent), IIF(nTipRel == 1, "", IIF(nPercent == Nil, "100,00", "")), TRANSFORM(nPercent, "@E 999.99"))
 
 If Empty(nPercent) //Se for o relatorio analitico, pula uma linha apos o total.
  nLin += 1
 Endif 

Return(nLin)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_Final  บ Autor ณ Cibele Peria       บ Data ณ  21/07/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Rotina de Finalizacao                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_Final(nLin)

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Total Geral                                                         ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 nLin := FS_Quebra(nLin)
 If nRepTot > 0
  nLin := FS_Total(STR0018+STR0013, nRepTot, nGloTot, nRecTot, nProTot, nLin) //"Total"###"Geral"
 Endif
Return()