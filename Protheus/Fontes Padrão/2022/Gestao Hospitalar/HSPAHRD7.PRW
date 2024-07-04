#INCLUDE "HSPAHRD7.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHRD7 บ Autor ณ Daniel Peixoto     บ Data ณ  26/07/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Previsao de Repasse - Prestador                            บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHRD7()

 Local cDesc1 := STR0001 //"Este programa tem como objetivo imprimir relatorio "
 Local cDesc2 := STR0002 //"de acordo com os parametros informados pelo usuario."
 Local cDesc3 := STR0003 //"Previsao de Repasse - Prestador"
 Local aOrd   := {}
 
 Private Titulo := cDesc3     
          //                            1         2         3         4         5         6         7         8         9        10        11        12        13        14
          //                  0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.
 Private Cabec1 := STR0004 //"Prestador"
 Private Cabec2      := STR0005 //"   Profissional                                       Qtde Procedmto     Qtde Taxas    Qtde Mat/Med   Repasse($)    Perc(%)"
 Private lEnd        := .F.
 Private lAbortPrint := .F.
 Private limite      := 120
 Private Tamanho     := "M"
 Private NomeProg    := "HSPAHRD7" // Coloque aqui o nome do programa para impressao no cabecalho
 Private nTipo       := 18
 Private aReturn     := {STR0006, 1, STR0007, 2, 2, 1, "", 2}  //"Zebrado"###"Administracao"
 Private nLastKey    := 0
 Private cbtxt       := Space(10)
 Private cbcont      := 00
 Private CONTFL      := 01
 Private m_pag       := 01
 Private wnrel       := NomeProg
 Private nTam        := 120
 Private cString  := ""
 
 Private cCODIMP := ""
 Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ PARAMETROS                                                         ณ
 //ณ MV_PAR01	Da Data Servico?                                          ณ
 //ณ MV_PAR02	Ate Data Servico?                                         ณ
 //ณ MV_PAR03	Do Prestador?                                             ณ
 //ณ MV_PAR04	Ate Prestador?                                            ณ
 //ณ MV_PAR05	Do Profissional?                                          ณ
 //ณ MV_PAR06	Ate Profissional?                                         ณ
 //ณ MV_PAR07 Faturados  1=Sim;2=Nao;3=Todos                            ณ
 //ณ MV_PAR08 Grafico  1=Sim;2=Nao                                      ณ
 //ณ MV_PAR09 Impressora ?                                              ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

 cPerg := "HSPRD7"

 If !Pergunte(cPerg, .T.)
  Return()
 EndIf

 nMaxLin := HS_MaxLin(cCODIMP)

 wnrel := SetPrint(cString, NomeProg, "", @Titulo, cDesc1, cDesc2, cDesc3, .T., aOrd, .T., Tamanho, , .T.)

 If nLastKey == 27
  Return()
 EndIf

 SetDefault(aReturn, cString)

 If nLastKey == 27
  Return()
 EndIf

 nTipo := If(aReturn[4] == 1, 15, 18)

 RptStatus({|| RunReport() }, Titulo)

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ Daniel Peixoto     บ Data ณ  26/07/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Rotina de execucao do relatorio                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function RunReport()

 Local cSql        := ""
 Local nLin        := nMaxLin * 2
 Local nContFor  := 0
 
 Private cCodPRe  := ""
 Private cCodCRM  := "" 
 Private nQtdPre  := 0
 Private nQtdPrePR := 0
 Private nQtdPreDT := 0
 Private nQtdPreMM := 0
 Private nQtdMedPR := 0
 Private nQtdMedDT := 0
 Private nQtdMedMM := 0
 Private nQtdTot   := 0
 Private nQtdTotPR := 0
 Private nQtdTotDT := 0
 Private nQtdTotMM := 0
 Private nRepPre  := 0
 Private nRepMed  := 0
 Private nPerPre  := 0
 Private nRepTot  := 0
 Private nValDes  := 0   
 Private aVetGraf := {} 
 Private cTipo    := IIF(MV_PAR07 == 1, "F", IIF(MV_PAR07 == 2, "P", "FP"))

 cSQL := "SELECT 
 cSQL += " QRY_CODPRE, QRY_FANPRE, QRY_CODCRM, QRY_NOME, 
 cSQL += " SUM(QRY_QTDPR) QRY_QTDPR, SUM(QRY_QTDDT) QRY_QTDDT, SUM(QRY_QTDMM) QRY_QTDMM, SUM(QRY_VALREP) QRY_VALREP,  QRY_STATUS "
 cSQL += "FROM "
 cSQL += "( "

 cSQL += "   SELECT "
 cSQL += "     GD7.GD7_CODPRE QRY_CODPRE,      GD7.GD7_CODCRM QRY_CODCRM,    'PR' TIPODES ,     'P' QRY_STATUS ,  "
 cSQL += "     MAX(SRA.RA_NOME) QRY_NOME,      SUM(GD7.GD7_QTDDES) QRY_QTDPR, SUM(0) QRY_QTDDT, SUM(0) QRY_QTDMM, " 
 cSQL += "     SUM(GD7.GD7_VALREP) QRY_VALREP, MAX(GAZ.GAZ_FANPRE) QRY_FANPRE "
 cSQL += "   FROM   " + RetSQLName("GD7") + " GD7 "
 cSQL += "     JOIN " + RetSQLName("GAZ") + " GAZ ON GAZ.GAZ_FILIAL = '" + xFilial("GAZ") + "' AND GAZ.D_E_L_E_T_ <> '*' AND GAZ.GAZ_CODPRE = GD7.GD7_CODPRE "
 cSQL += "     JOIN " + RetSQLName("SRA") + " SRA ON SRA.RA_FILIAL  = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' AND SRA.RA_CODIGO  = GD7.GD7_CODCRM "
 cSQL += "     JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' AND GCZ.GCZ_NRSEQG = GD7.GD7_NRSEQG AND GCZ.GCZ_STATUS < '2' "
 cSQL += "     JOIN " + RetSQLName("GCU") + " GCU ON GCU.D_E_L_E_T_ <> '*' AND GCU.GCU_FILIAL = '" + xFilial("GCU") + "' "
 cSQL += "      AND GCU.GCU_CODTPG = GCZ.GCZ_CODTPG AND GCU.GCU_TPGUIA <> '7' "  //Nใo Apresenta Guias Tipo Retorno 
 cSQL += "   WHERE "                                                                     
 cSQL += "     GD7.GD7_FILIAL = '" + xFilial("GD7") + "' AND GD7.D_E_L_E_T_ <> '*' AND "
 cSQL += "     GD7.GD7_PGTMED <> '0' AND "
 cSQL += "     GD7.GD7_DATDES BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' AND "
 cSQL += "     GD7.GD7_CODPRE BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' AND "
 cSQL += "     GD7.GD7_CODCRM BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "   
 IF "ORACLE" $ Upper(TCGETDB())
  cSql += "  HAVING SUM(GD7.GD7_VALREP) > 0 "
  cSql += "  GROUP BY GD7.GD7_CODPRE, GD7.GD7_CODCRM "  
 ELSE  
  cSql += "  GROUP BY GD7.GD7_CODPRE, GD7.GD7_CODCRM " 
  cSql += "  HAVING SUM(GD7.GD7_VALREP) > 0 "  
 ENDIF 
 cSQL += "			UNION ALL "
 cSQL += "   SELECT "
 cSQL += "     GE7.GE7_CODPRE QRY_CODPRE,      GE7.GE7_CODCRM QRY_CODCRM,    'PR' TIPODES ,     'F' QRY_STATUS ,  "
 cSQL += "     MAX(SRA.RA_NOME) QRY_NOME,      SUM(GE7.GE7_QTDDES) QRY_QTDPR, SUM(0) QRY_QTDDT, SUM(0) QRY_QTDMM, "
 cSQL += "     SUM(GE7.GE7_VALREP) QRY_VALREP, MAX(GAZ.GAZ_FANPRE) QRY_FANPRE "
 cSQL += "			FROM   " + RetSQLName("GE7") + " GE7 "
 cSQL += "					JOIN " + RetSQLName("GAZ") + " GAZ ON GAZ.GAZ_FILIAL = '" + xFilial("GAZ") + "' AND GAZ.D_E_L_E_T_ <> '*' AND GAZ.GAZ_CODPRE = GE7.GE7_CODPRE "
 cSQL += "					JOIN " + RetSQLName("SRA") + " SRA ON SRA.RA_FILIAL  = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' AND SRA.RA_CODIGO  = GE7.GE7_CODCRM "
 cSQL += "			WHERE "                                                                     
 cSQL += "					GE7.GE7_FILIAL = '" + xFilial("GE7") + "' AND GE7.D_E_L_E_T_ <> '*' AND "
 cSQL += "					GE7.GE7_PGTMED <> '0' AND "
 cSQL += "					GE7.GE7_DATDES BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' AND "
 cSQL += "					GE7.GE7_CODPRE BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' AND "
 cSQL += "					GE7.GE7_CODCRM BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "   
 IF "ORACLE" $ Upper(TCGETDB())
  cSql += "		HAVING SUM(GE7.GE7_VALREP) > 0 "  
  cSql += "		GROUP BY GE7.GE7_CODPRE, GE7.GE7_CODCRM " 
 ELSE  
  cSql += "		GROUP BY GE7.GE7_CODPRE, GE7.GE7_CODCRM " 
  cSql += "		HAVING SUM(GE7.GE7_VALREP) > 0 "  
 ENDIF
 cSQL += "			UNION ALL "
 cSQL += "			SELECT "
 cSQL += "     GD6.GD6_CODPRE QRY_CODPRE,      GD6.GD6_CODCRM QRY_CODCRM,  'PR' TIPODES ,                  'P' QRY_STATUS,   "
 cSQL += "     MAX(SRA.RA_NOME) QRY_NOME,      SUM(0) QRY_QTDPR,           SUM(GD6.GD6_QTDDES) QRY_QTDDT,  SUM(0) QRY_QTDMM, " 
 cSQL += "     SUM(GD6.GD6_VALREP) QRY_VALREP, MAX(GAZ.GAZ_FANPRE) QRY_FANPRE "
 cSQL += "			FROM   " + RetSQLName("GD6") + " GD6 "
 cSQL += "				 JOIN " + RetSQLName("GAZ") + " GAZ ON GAZ.GAZ_FILIAL = '" + xFilial("GAZ") + "' AND GAZ.D_E_L_E_T_ <> '*' AND GAZ.GAZ_CODPRE = GD6.GD6_CODPRE "
 cSQL += "				 JOIN " + RetSQLName("SRA") + " SRA ON SRA.RA_FILIAL  = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' AND SRA.RA_CODIGO  = GD6.GD6_CODCRM "
 cSQL += "				 JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' AND GCZ.GCZ_NRSEQG = GD6.GD6_NRSEQG AND GCZ.GCZ_STATUS < '2' "
 cSQL += "     JOIN " + RetSQLName("GCU") + " GCU ON GCU.D_E_L_E_T_ <> '*' AND GCU.GCU_FILIAL = '" + xFilial("GCU") + "' "
 cSQL += "      AND GCU.GCU_CODTPG = GCZ.GCZ_CODTPG AND GCU.GCU_TPGUIA <> '7' "  //Nใo Apresenta Guias Tipo Retorno 
 cSQL += "			WHERE "                                                                     
 cSQL += "					GD6.GD6_FILIAL = '" + xFilial("GD6") + "' AND GD6.D_E_L_E_T_ <> '*' AND "
 cSQL += "					GD6.GD6_PGTMED <> '0' AND "
 cSQL += "					GD6.GD6_DATDES BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' AND "
 cSQL += "					GD6.GD6_CODPRE BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' AND "
 cSQL += "					GD6.GD6_CODCRM BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "   
 IF "ORACLE" $ Upper(TCGETDB())
  cSql += "   HAVING SUM(GD6.GD6_VALREP) > 0 "
  cSql += "   GROUP BY GD6.GD6_CODPRE, GD6.GD6_CODCRM "  
 ELSE  
  cSql += "   GROUP BY GD6.GD6_CODPRE, GD6.GD6_CODCRM " 
  cSql += "   HAVING SUM(GD6.GD6_VALREP) > 0 "  
 ENDIF 
 cSQL += "   UNION ALL "
 cSQL += "   SELECT "
 cSQL += "     GE6.GE6_CODPRE QRY_CODPRE,      GE6.GE6_CODCRM QRY_CODCRM,  'PR' TIPODES ,                 'F' QRY_STATUS,   "
 cSQL += "     MAX(SRA.RA_NOME) QRY_NOME,      SUM(0) QRY_QTDPR,           SUM(GE6.GE6_QTDDES) QRY_QTDDT, SUM(0) QRY_QTDMM, "
 cSQL += "     SUM(GE6.GE6_VALREP) QRY_VALREP, MAX(GAZ.GAZ_FANPRE) QRY_FANPRE "
 cSQL += "			FROM   " + RetSQLName("GE6") + " GE6 "
 cSQL += "					JOIN " + RetSQLName("GAZ") + " GAZ ON GAZ.GAZ_FILIAL = '" + xFilial("GAZ") + "' AND GAZ.D_E_L_E_T_ <> '*' AND GAZ.GAZ_CODPRE = GE6.GE6_CODPRE "
 cSQL += "					JOIN " + RetSQLName("SRA") + " SRA ON SRA.RA_FILIAL  = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' AND SRA.RA_CODIGO  = GE6.GE6_CODCRM "
 cSQL += "			WHERE "                                                                     
 cSQL += "					GE6.GE6_FILIAL = '" + xFilial("GE6") + "' AND GE6.D_E_L_E_T_ <> '*' AND "
 cSQL += "					GE6.GE6_PGTMED <> '0' AND "
 cSQL += "					GE6.GE6_DATDES BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' AND "
 cSQL += "					GE6.GE6_CODPRE BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' AND "
 cSQL += "					GE6.GE6_CODCRM BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "   
 IF "ORACLE" $ Upper(TCGETDB())
  cSql += "		  	HAVING SUM(GE6.GE6_VALREP) > 0 "  
  cSql += "			  GROUP BY GE6.GE6_CODPRE, GE6.GE6_CODCRM " 
 ELSE
  cSql += "			  GROUP BY GE6.GE6_CODPRE, GE6.GE6_CODCRM " 
  cSql += "			  HAVING SUM(GE6.GE6_VALREP) > 0 "  
 ENDIF

 cSQL += "			UNION ALL "
 cSQL += "			SELECT "
 cSQL += "     GD5.GD5_CODPRE QRY_CODPRE,      GD5.GD5_CODCRM QRY_CODCRM,  'PR' TIPODES ,     'P' QRY_STATUS, "
 cSQL += "     MAX(SRA.RA_NOME) QRY_NOME,      SUM(0) QRY_QTDPR,           SUM(0) QRY_QTDDT,  SUM(GD5.GD5_QTDDES) QRY_QTDMM, " 
 cSQL += "     SUM(GD5.GD5_VALREP) QRY_VALREP, MAX(GAZ.GAZ_FANPRE) QRY_FANPRE "
 cSQL += "			FROM   " + RetSQLName("GD5") + " GD5 "
 cSQL += "					JOIN " + RetSQLName("GAZ") + " GAZ ON GAZ.GAZ_FILIAL = '" + xFilial("GAZ") + "' AND GAZ.D_E_L_E_T_ <> '*' AND GAZ.GAZ_CODPRE = GD5.GD5_CODPRE "
 cSQL += "					JOIN " + RetSQLName("SRA") + " SRA ON SRA.RA_FILIAL  = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' AND SRA.RA_CODIGO  = GD5.GD5_CODCRM "
 cSQL += "					JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' AND GCZ.GCZ_NRSEQG = GD5.GD5_NRSEQG AND GCZ.GCZ_STATUS < '2' "
 cSQL += "     JOIN " + RetSQLName("GCU") + " GCU ON GCU.D_E_L_E_T_ <> '*' AND GCU.GCU_FILIAL = '" + xFilial("GCU") + "' "
 cSQL += "      AND GCU.GCU_CODTPG = GCZ.GCZ_CODTPG AND GCU.GCU_TPGUIA <> '7' "  //Nใo Apresenta Guias Tipo Retorno 
 cSQL += "			WHERE "                                                                     
 cSQL += "					GD5.GD5_FILIAL = '" + xFilial("GD5") + "' AND GD5.D_E_L_E_T_ <> '*' AND "
 cSQL += "					GD5.GD5_PGTMED <> '0' AND "
 cSQL += "					GD5.GD5_DATDES BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' AND "
 cSQL += "					GD5.GD5_CODPRE BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' AND "
 cSQL += "					GD5.GD5_CODCRM BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "   
 IF "ORACLE" $ Upper(TCGETDB())
  cSql += "			  HAVING SUM(GD5.GD5_VALREP) > 0 "
  cSql += "			  GROUP BY GD5.GD5_CODPRE, GD5.GD5_CODCRM "  
 ELSE  
  cSql += "			  GROUP BY GD5.GD5_CODPRE, GD5.GD5_CODCRM " 
  cSql += "			  HAVING SUM(GD5.GD5_VALREP) > 0 "  
 ENDIF 

 cSQL += "		 UNION ALL "
 cSQL += "		 SELECT "
 cSQL += "     GE5.GE5_CODPRE QRY_CODPRE,      GE5.GE5_CODCRM QRY_CODCRM,  'PR' TIPODES ,     'F' QRY_STATUS, "
 cSQL += "     MAX(SRA.RA_NOME) QRY_NOME,      SUM(0) QRY_QTDPR,           SUM(0) QRY_QTDDT,  SUM(GE5.GE5_QTDDES) QRY_QTDMM, "
 cSQL += "     SUM(GE5.GE5_VALREP) QRY_VALREP, MAX(GAZ.GAZ_FANPRE) QRY_FANPRE "
 cSQL += "			FROM   " + RetSQLName("GE5") + " GE5 "
 cSQL += "					JOIN " + RetSQLName("GAZ") + " GAZ ON GAZ.GAZ_FILIAL = '" + xFilial("GAZ") + "' AND GAZ.D_E_L_E_T_ <> '*' AND GAZ.GAZ_CODPRE = GE5.GE5_CODPRE "
 cSQL += "					JOIN " + RetSQLName("SRA") + " SRA ON SRA.RA_FILIAL  = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' AND SRA.RA_CODIGO  = GE5.GE5_CODCRM "
 cSQL += "			WHERE "                                                                     
 cSQL += "					GE5.GE5_FILIAL = '" + xFilial("GE5") + "' AND GE5.D_E_L_E_T_ <> '*' AND "
 cSQL += "					GE5.GE5_PGTMED <> '0' AND "
 cSQL += "					GE5.GE5_DATDES BETWEEN '" + DTOS(MV_PAR01) + "' AND '" + DTOS(MV_PAR02) + "' AND "
 cSQL += "					GE5.GE5_CODPRE BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "' AND "
 cSQL += "					GE5.GE5_CODCRM BETWEEN '" + MV_PAR05 + "' AND '" + MV_PAR06 + "' "   
 IF "ORACLE" $ Upper(TCGETDB())
  cSql += "					HAVING SUM(GE5.GE5_VALREP) > 0 "  
  cSql += "					GROUP BY GE5.GE5_CODPRE, GE5.GE5_CODCRM " 
 ELSE
  cSql += "					GROUP BY GE5.GE5_CODPRE, GE5.GE5_CODCRM " 
  cSql += "					HAVING SUM(GE5.GE5_VALREP) > 0 "  
 ENDIF
 cSQL += "			) TMP "    
 
 IF "ORACLE" $ Upper(TCGETDB())
  cSql += "					HAVING SUM(QRY_VALREP) > 0 "  
  cSql += "					GROUP BY TIPODES, QRY_STATUS, QRY_CODPRE, QRY_FANPRE, QRY_CODCRM, QRY_NOME " 
 ELSE
  cSql += "					GROUP BY TIPODES, QRY_STATUS, QRY_CODPRE, QRY_FANPRE, QRY_CODCRM, QRY_NOME " 
  cSql += "					HAVING SUM(QRY_VALREP) > 0 "  
 ENDIF

 cSQL += "						ORDER BY QRY_FANPRE, QRY_NOME, QRY_STATUS"
 
 TCQUERY cSQL NEW ALIAS "QRY"
 
 DbSelectArea("QRY")
 DbGoTop()
                                
 If Eof()
  HS_MsgInf(STR0008, STR0016, STR0015) //"Nenhum dado foi encontado para a selecao efetuada!"###"Aten็ใo"###"Rotina de execucao do relatorio"
  DbCloseArea()
  Return()
 EndIf
  
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 While !EOF()
  If QRY->QRY_STATUS $ cTipo      
   nRepTot += QRY->QRY_VALREP
   nQtdTotPR += QRY->QRY_QTDPR
   nQtdTotDT += QRY->QRY_QTDDT
   nQtdTotMM += QRY->QRY_QTDMM
  EndIf 
  DBSKIP()
 EndDo     
 DbGoTop()

 SetRegua(200)

 While !EOF()                                                                                

  IncRegua()
   
  If lAbortPrint
   @nLin, 000 PSAY STR0009 //"*** CANCELADO PELO OPERADOR ***"
   Exit
  EndIf
  
  nLin := FS_Cabec(nLin)
  
	 If cCodPre <> QRY->QRY_CODPRE .And. QRY->QRY_STATUS $ cTipo
 		If !EMPTY(cCodPre)
 			cCodCRM := ""
 			nLin := FS_ImpTotPre(nLin)
 		EndIf
 		nLin := FS_Cabec(nLin)
			cCodPre := QRY->QRY_CODPRE
 		@nLin, 000 PSAY QRY->QRY_CODPRE + " - " + QRY->QRY_FANPRE
 		nLin += 2 		
 	EndIf
 
  If cCodCRM <> QRY->QRY_CODCRM .And. IIF(cTipo = "FP", .T., QRY->QRY_STATUS $ cTipo)
	 	If !EMPTY(cCOdCRM)
  		nLin := FS_ImpTotCRM(nLin)
 			nQtdMedPR := 0
 			nQtdMedDT := 0
 			nQtdMedMM := 0
  		nRepMed := 0
  	EndIf
   nLin := FS_Cabec(nLin)
   @nLin, 004 PSAY PADL(ALLTRIM(QRY->QRY_CODCRM), LEN(QRY->QRY_CODCRM)) + " - " + SUBSTR(QRY->QRY_NOME, 1, 27)  //medico
 		cCodCRM := QRY->QRY_CODCRM
 	EndIf

 	If IIF (cTipo = "FP", .T., QRY->QRY_STATUS $ cTipo)

 	 nQtdMedPR += QRY->QRY_QTDPR
 	 nQtdMedDT += QRY->QRY_QTDDT
 	 nQtdMedMM += QRY->QRY_QTDMM
 	 nRepMed += QRY->QRY_VALREP

 	EndIf 
 	
  DbSkip()

  If EOF()
  	nLin := FS_ImpTotPre(nLin)
   @ nLin, 000 PSAY STR0010 //"Total Geral...: "
   @ nLin, 053 PSAY TRANSFORM (nQtdTotPR, "@E 9,999,999")
   @ nLin, 071 PSAY TRANSFORM (nQtdTotDT, "@E 9,999,999")
   @ nLin, 084 PSAY TRANSFORM (nQtdTotMM, "@E 9,999,999")
   @ nLin, 096 PSAY TRANSFORM (nRepTot,   "@E 9,999,999.99")
   @ nLin, 110 PSAY "100,00%"  
  EndIf 

 EndDo   
 
 If MV_PAR08 == 1    
  aSort(aVetGraf,,, {| x, y | x[1] < y[1]})
  oGraf := hsGRAF():NEW(STR0003, STR0011, STR0012, STR0013, STR0004 , "", aVetGraf, 1, 1, 0, 0, 2, 17, 6, 6, 25, 20)     //"PREVISAO DE REPASSE - PRESTADOR"###"REPASSE POR PRESTADOR "###"Percentual do Repasse"###"Percentual %"###"Prestador"
 EndIf  
  
 SET DEVICE TO SCREEN
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Se impressao em disco, chama o gerenciador de impressao...          ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 If aReturn[5] == 1
  dbCommitAll()
  SET PRINTER TO
  OurSpool(wnrel)
 EndIf

 MS_FLUSH()
 DBCloseArea()

Return()         

/***************************************************************************************************/
Static Function FS_Cabec(nLin)
                                                                                                     
 If nLin > nMaxLin
  Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
  nLin := 9
 EndIf 
 
Return(nLin)
/***************************************************************************************************/
Static Function FS_ImpTotPre(nLin)

 nLin := FS_ImpTotCRM(nLin)
 nQtdMedPR := 0
 nQtdMedDT := 0
 nQtdMedMM := 0
	nRepMed := 0
 nLin ++
 @ nLin, 000 PSAY STR0014 //"Total do Prestador...: "
 @ nLin, 053 PSAY TRANSFORM (nQtdPrePR, "@E 9,999,999")
 @ nLin, 071 PSAY TRANSFORM (nQtdPreDT, "@E 9,999,999")
 @ nLin, 084 PSAY TRANSFORM (nQtdPreMM, "@E 9,999,999")
 @ nLin, 096 PSAY TRANSFORM (nRepPre,   "@E 9,999,999.99")
 nPerPre := (nRepPre / nRepTot) * 100
 @ nLin, 110 PSAY TRANSFORM (nPerPre,  "@E 999.99") + "%"
 
 If MV_PAR08 == 1 //grafico
 	aAdd(aVetGraf, {nPerPre, ALLTRIM(cCodPre) + " - " + AllTrim(Str(nPerPre, 6, 2)) + "%"})
 EndIf
 
 nLin += 2
 @ nLin, 000 PSAY REPLI("-", 120)
 nLin += 2
 nQtdPrePR := 0
 nQtdPreDT := 0
 nQtdPreMM := 0
 nRepPre := 0

Return(nLin)

/***************************************************************************************************/
Static Function FS_ImpTotCRM(nLin)

			@nLin, 053 PSAY TRANSFORM (nQtdMedPR , "@E 9,999,999")
			@nLin, 071 PSAY TRANSFORM (nQtdMedDT , "@E 9,999,999")
			@nLin, 084 PSAY TRANSFORM (nQtdMedMM , "@E 9,999,999")
			@nLin, 096 PSAY TRANSFORM (nRepMed   , "@E 9,999,999.99")
			nLin ++
			nQtdPrePR += nQtdMedPR 
			nQtdPreDT += nQtdMedDT 
			nQtdPreMM += nQtdMedMM
			nRepPre += nRepMed

Return(nLin)

/***************************************************************************************************/                     
Function HS_GrvCPre(cCodCrm)
 If IIf(cCodCrm == Nil, MsgYesNo("Confirma processamento"), .T.)
  Processa({|| FS_GrvCPre(cCodCrm)})
 EndIf 
Return(Nil)


Function FS_GrvCPre(cCodCrm)
 Local nForPR := 1, cAlias := "", cPrefi := ""
 
 Default cCodCrm := ""
 
 CursorWait()
                    
 For nForPR := 1 To 2
  cAlias := IIf(nForPR == 1, "GD7", "GE7")
  cPrefi := IIf(nForPR == 1, "GD7->GD7_", "GE7->GE7_")
 
  DbSelectArea(cAlias)
  DbSetOrder(IIf(nForPR == 1, 10, 11))
  DbSeek(xFilial(cAlias) + cCodCrm)
 
  ProcRegua((cAlias)->(RecCount()))
    
  While !Eof() .And. &(cPrefi + "FILIAL") == xFilial(cAlias) .And. IIf(!Empty(cCodCrm), &(cPrefi + "CODCRM") == cCodCrm, .T.)
                             
   IncProc("Grv. Prestador do CRM [" + &(cPrefi + "CODCRM") + "] - " + IIf(nForPR == 1, "Posto", "Faturamento"))
  
   RecLock(cAlias, .F.)
    &(cPrefi + "CODPRE") := HS_RPreMed(&(cPrefi + "CODCRM"), &(cPrefi + "CODLOC"))
   MsUnLock()
   
   DbSkip()
  End
 Next 
 
 CursorArrow()
Return(Nil)