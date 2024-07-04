#INCLUDE "HSPAHR63.ch"
#Include "protheus.ch"
#include "TopConn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHR63  บ Autor ณ Daniel Peixoto     บ Data ณ  24/06/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Guias com Advertencia - Faturamento                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HSPAHR63()


/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 ณ Declaracao de Variaveis                                             ณ
 ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3         := ""
Local cPict          := ""
Local titulo         := STR0003 //"Guias com Advertencia"
Local nLin           := 80 
/*                                 1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16       17
                         0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.12346789.123456789.12345 */
Local Cabec1         := ""
Local Cabec2         := ""
Local imprime        := .T.
Local aOrd 				   := {}    

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 80
Private tamanho      := "M"
Private nomeprog     := "HSPAHR63" /* Coloque aqui o nome do programa para impressao no cabecalho */
Private nTipo        := 18
Private aReturn      := { STR0004, 1, STR0005, 2, 2, 1, "", 1}    //"Zebrado"###"Administracao"
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "HSPAHR63" /* Coloque aqui o nome do arquivo usado para impressao em disco */
Private cPerg        := "HSPR63"
Private cString  := ""

/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 ณ PARAMETROS                                                       ณ
 ณ MV_PAR01	 Do Setor                                               ณ
 ณ MV_PAR02	 Ate Setor                                              ณ
 ณ MV_PAR03	 Da dt Atend                                            ณ
 ณ MV_PAR04	 Ate Dt Atend                                           ณ
 ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */
Private cCodLoc_De := "", cCodLoc_Ate := "", dDatAte_De  := "", dDatAte_Ate := "", nAlta := 0
Private cCODIMP := ""
Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao

Private lTamProd := IIf((TamSx3("GBI_PRODUT")[1])<=15, .T., .F.)
 If !Pergunte(cPerg,.T.)
 	return
 EndIf

 cCodLoc_De  := MV_PAR01
 cCodLoc_Ate := MV_PAR02
 dDatAte_De  := MV_PAR03
 dDatAte_Ate := MV_PAR04
 nAlta							:= MV_PAR05

 nMaxLin := HS_MaxLin(cCODIMP)
 nLin := nMaxLin * 2

 wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

 If nLastKey == 27
 	Return
 Endif

 SetDefault(aReturn,cString)

 If nLastKey == 27
  Return
 Endif

 nTipo := If(aReturn[4]==1,15,18)

 RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ Daniel Peixoto     บ Data ณ  24/06/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

 Local cSQL 	     := "" 
 Private cCodLoc  := ""      
 Private cRegAte  := "" 
 Private cNrSeqG  := "" 
 Private nTotGuia := 0

 cSQL := "SELECT '0' TIPO, GCY.GCY_CODLOC QRY_CODLOC, GCS.GCS_NOMLOC QRY_NOMLOC, GCY.GCY_REGATE QRY_REGATE, GCY.GCY_NOME QRY_NOMPAC,"
 cSQL += " GCY.GCY_DATALT QRY_DATALT, GCY.GCY_DATATE QRY_DATATE, GCZ.GCZ_NRSEQG QRY_NRSEQG, GCZ.GCZ_NRGUIA QRY_NRGUIA, "
 cSQL += " GCM.GCM_DESPLA QRY_DESPLA, '' QRY_CODDES, '' QRY_DDESPE, 0 TVALDES, 0 TVALGAR, "
 cSQL += " 0 QRY_VALMAT, 0 QRY_VALMED, 0 QRY_VALPRO "
 cSQL += " FROM " + RetSQLName("GCZ") + " GCZ"                                   
 cSql += " JOIN " + RetSQLName("GCU") + " GCU ON GCU.D_E_L_E_T_ <> '*' AND GCU.GCU_FILIAL = '" + xFilial("GCU") + "' "
 cSql += " AND GCU.GCU_CODTPG = GCZ.GCZ_CODTPG AND GCU.GCU_TPGUIA <> '7' "  //Nใo Apresenta Guias Tipo Retorno 
 cSQL += " JOIN " + RetSQLName("GCY") + " GCY ON GCY.GCY_REGATE = GCZ.GCZ_REGATE  AND GCY.GCY_ATENDI = '0' AND GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GE8") + " GE8 ON GE8.GE8_NRSEQG = GCZ.GCZ_NRSEQG AND GE8.GE8_DATVEN < '" + DTOS(DDATABASE) + "' AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GCS") + " GCS ON GCS.GCS_CODLOC = GCY.GCY_CODLOC AND GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GCM") + " GCM ON GCM.GCM_CODPLA = GCZ.GCZ_CODPLA AND GCM.GCM_FILIAL = '" + xFilial("GCM") + "' AND GCM.D_E_L_E_T_ <> '*' "
 cSQL += " WHERE GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
 cSQL += " AND GCZ.GCZ_STATUS IN ('0', '1') "
 cSQL += " AND GCY.GCY_CODLOC BETWEEN '" + cCodLoc_De + "' AND '" + cCodLoc_Ate + "' "
 cSQL += " AND GCY.GCY_DATATE BETWEEN '" + DTOS(dDatAte_De) + "' AND '" + DTOS(dDatAte_Ate) + "'  "
 If nAlta == 1 //SEM ALTA
  cSQL += " AND GCY.GCY_DATALT =  '"+SPACE(8)+"' "
 ElseIf  nAlta == 2 //COM ALTA
  cSQL += " AND GCY.GCY_DATALT <> '"+SPACE(8)+"' "
 EndIf 
 
 cSQL += " UNION ALL "
 cSQL += " SELECT '1' TIPO, GCY.GCY_CODLOC QRY_CODLOC, GCS.GCS_NOMLOC QRY_NOMLOC, GCY.GCY_REGATE QRY_REGATE, GCY.GCY_NOME QRY_NOMPAC,"
 cSQL += " GCY.GCY_DATALT QRY_DATALT, GCY.GCY_DATATE QRY_DATATE, GD5.GD5_NRSEQG QRY_NRSEQG, GCZ.GCZ_NRGUIA QRY_NRGUIA, "
 cSQL += " GCM.GCM_DESPLA QRY_DESPLA, GD5.GD5_CODDES QRY_CODDES, SB1.B1_DESC QRY_DDESPE, 0 TVALDES, 0 TVALGAR, "
 cSQL += " GC1.GC1_VALMAT QRY_VALMAT, GC1.GC1_VALMED QRY_VALMED, GC1.GC1_VALPRO QRY_VALPRO "
 cSQL += " FROM " + RetSQLName("GD5") + " GD5"                                   
 cSQL += " JOIN " + RetSQLName("GCY") + " GCY ON GCY.GCY_REGATE = GD5.GD5_REGATE  AND GCY.GCY_ATENDI = '0' AND GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_NRSEQG = GD5.GD5_NRSEQG AND GCZ.GCZ_STATUS IN ('0', '1') AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
 cSql += " JOIN " + RetSQLName("GCU") + " GCU ON GCU.D_E_L_E_T_ <> '*' AND GCU.GCU_FILIAL = '" + xFilial("GCU") + "' "
 cSql += " AND GCU.GCU_CODTPG = GCZ.GCZ_CODTPG AND GCU.GCU_TPGUIA <> '7' "  //Nใo Apresenta Guias Tipo Retorno  
 cSQL += " JOIN " + RetSQLName("GCS") + " GCS ON GCS.GCS_CODLOC = GCY.GCY_CODLOC AND GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GCM") + " GCM ON GCM.GCM_CODPLA = GCZ.GCZ_CODPLA AND GCM.GCM_FILIAL = '" + xFilial("GCM") + "' AND GCM.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GBI") + " GBI ON GBI.GBI_PRODUT = GD5.GD5_CODDES AND GBI.GBI_FILIAL = '" + xFilial("GBI") + "' AND GBI.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("SB1") + " SB1 ON SB1.B1_COD     = GBI.GBI_PRODUT AND SB1.B1_FILIAL  = '" + xFilial("SB1") + "' AND SB1.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GC1") + " GC1 ON GC1.GC1_CODPLA = GCZ.GCZ_CODPLA AND GC1.GC1_FILIAL = '" + xFilial("GC1") + "' AND GC1.D_E_L_E_T_ <> '*' "
 cSQL += " WHERE GD5.GD5_FILIAL = '" + xFilial("GD5") + "' AND GD5.D_E_L_E_T_ <> '*' "
 cSQL += " AND GCY.GCY_CODLOC BETWEEN '" + cCodLoc_De + "' AND '" + cCodLoc_Ate + "' "
 cSQL += " AND GCY.GCY_DATATE BETWEEN '" + DTOS(dDatAte_De) + "' AND '" + DTOS(dDatAte_Ate) + "'  "
 If nAlta == 1 //SEM ALTA
  cSQL += " AND GCY.GCY_DATALT =  '"+SPACE(8)+"' "
 ElseIf  nAlta == 2 //COM ALTA
  cSQL += " AND GCY.GCY_DATALT <> '"+SPACE(8)+"' "
 EndIf  
 cSQL += " AND GC1.GC1_DATVIG = (SELECT MAX(GC1.GC1_DATVIG) FROM " + RetSQLName("GC1") + " GC1 WHERE GC1.GC1_FILIAL = '" + xFilial("GC1") + "' AND GC1.D_E_L_E_T_ <> '*' AND GC1.GC1_CODPLA = GCZ.GCZ_CODPLA AND GC1.GC1_DATVIG <= '" + DTOS(DDATABASE) + "') "
 cSQL += " AND ((CASE WHEN GBI.GBI_TIPO = '0' THEN GC1.GC1_VALMAT ELSE GC1.GC1_VALMED END > 0 AND " + HS_FValDes("GD5") + " > CASE WHEN GBI.GBI_TIPO = '0' THEN GC1.GC1_VALMAT ELSE GC1.GC1_VALMED END)
 cSQL += "      OR EXISTS (SELECT GA4.GA4_DATVIG FROM " + RetSQLName("GA4") + " GA4 "
	cSQL += "                 WHERE GA4.GA4_FILIAL = '" + xFilial("GA4") + "' AND GA4.D_E_L_E_T_ <> '*' AND GA4.GA4_CODPLA = GCZ.GCZ_CODPLA AND GA4.GA4_ORIDES = '3' "
	cSQL += "                 AND GA4.GA4_CODDES = GD5.GD5_CODDES AND GA4.GA4_DATVIG <= GD5.GD5_DATDES)) "
	cSQL += "	AND( EXISTS (SELECT GE2.GE2_NRSEQG, GE2.GE2_CODDES FROM " + RetSQLName("GE2") + " GE2 "
	cSQL += "   											WHERE GE2.GE2_FILIAL = '" + xFilial("GE2") + "' AND GE2.D_E_L_E_T_ <> '*' AND GE2.GE2_NRSEQG = GD5.GD5_NRSEQG "
	cSQL += "   											AND GE2.GE2_CODDES = GD5.GD5_CODDES AND GE2.GE2_DATAUT = '"+SPACE(8)+"' ) "
	cSQL += "	 				OR NOT EXISTS (SELECT GE2.GE2_NRSEQG, GE2.GE2_CODDES FROM " + RetSQLName("GE2") + " GE2 "
	cSQL += "											          WHERE GE2.GE2_FILIAL = '" + xFilial("GE2") + "' AND GE2.D_E_L_E_T_ <> '*' AND GE2.GE2_NRSEQG = GD5.GD5_NRSEQG "
	cSQL += "											          AND GE2.GE2_CODDES = GD5.GD5_CODDES) ) "
  
 cSQL += " UNION ALL "
 cSQL += " SELECT '2' TIPO, GCY.GCY_CODLOC QRY_CODLOC, GCS.GCS_NOMLOC QRY_NOMLOC, GCY.GCY_REGATE QRY_REGATE, GCY.GCY_NOME QRY_NOMPAC,"
 cSQL += " GCY.GCY_DATALT QRY_DATALT, GCY.GCY_DATATE QRY_DATATE, GD7.GD7_NRSEQG QRY_NRSEQG, GCZ.GCZ_NRGUIA QRY_NRGUIA, "
 cSQL += " GCM.GCM_DESPLA QRY_DESPLA, GD7.GD7_CODDES QRY_CODDES, GA7.GA7_DESC QRY_DDESPE, 0 TVALDES, 0 TVALGAR, "
 cSQL += " GC1.GC1_VALMAT QRY_VALMAT, GC1.GC1_VALMED QRY_VALMED, GC1.GC1_VALPRO QRY_VALPRO "
 cSQL += " FROM " + RetSQLName("GD7") + " GD7"                                   
 cSQL += " JOIN " + RetSQLName("GCY") + " GCY ON GCY.GCY_REGATE = GD7.GD7_REGATE  AND GCY.GCY_ATENDI = '0' AND GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_NRSEQG = GD7.GD7_NRSEQG AND GCZ.GCZ_STATUS IN ('0', '1') AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
 cSql += " JOIN " + RetSQLName("GCU") + " GCU ON GCU.D_E_L_E_T_ <> '*' AND GCU.GCU_FILIAL = '" + xFilial("GCU") + "' "
 cSql += " AND GCU.GCU_CODTPG = GCZ.GCZ_CODTPG AND GCU.GCU_TPGUIA <> '7' "  //Nใo Apresenta Guias Tipo Retorno  
 cSQL += " JOIN " + RetSQLName("GCS") + " GCS ON GCS.GCS_CODLOC = GCY.GCY_CODLOC AND GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' " 
 cSQL += " JOIN " + RetSQLName("GCM") + " GCM ON GCM.GCM_CODPLA = GCZ.GCZ_CODPLA AND GCM.GCM_FILIAL = '" + xFilial("GCM") + "' AND GCM.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GA7") + " GA7 ON GA7.GA7_CODPRO = GD7.GD7_CODDES AND GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GC1") + " GC1 ON GC1.GC1_CODPLA = GCZ.GCZ_CODPLA AND GC1.GC1_FILIAL = '" + xFilial("GC1") + "' AND GC1.D_E_L_E_T_ <> '*' "
 cSQL += " WHERE GD7.GD7_FILIAL = '" + xFilial("GD7") + "' AND GD7.D_E_L_E_T_ <> '*' "
 cSQL += " AND GCY.GCY_CODLOC BETWEEN '" + cCodLoc_De + "' AND '" + cCodLoc_Ate + "' "
 cSQL += " AND GCY.GCY_DATATE BETWEEN '" + DTOS(dDatAte_De) + "' AND '" + DTOS(dDatAte_Ate) + "'  "
 If nAlta == 1 //SEM ALTA
  cSQL += " AND GCY.GCY_DATALT =  '"+SPACE(8)+"' "
 ElseIf  nAlta == 2 //COM ALTA
  cSQL += " AND GCY.GCY_DATALT <> '"+SPACE(8)+"' "
 EndIf
 cSQL += " AND GC1.GC1_DATVIG = (SELECT MAX(GC1.GC1_DATVIG) FROM " + RetSQLName("GC1") + " GC1 WHERE GC1.GC1_FILIAL = '" + xFilial("GC1") + "' AND GC1.D_E_L_E_T_ <> '*' AND GC1.GC1_CODPLA = GCZ.GCZ_CODPLA AND GC1.GC1_DATVIG <= '" + DTOS(DDATABASE) + "' ) "
 cSQL += " AND ((GC1.GC1_VALPRO > 0 AND " + HS_FValDes("GD7") + " > GC1.GC1_VALPRO) " 
 cSQL += "      OR EXISTS (SELECT GA4.GA4_DATVIG FROM " + RetSQLName("GA4") + " GA4 " 
	cSQL += "                 WHERE GA4.GA4_FILIAL = '" + xFilial("GA4") + "' AND GA4.D_E_L_E_T_ <> '*' AND GA4.GA4_CODPLA = GCZ.GCZ_CODPLA AND GA4.GA4_ORIDES IN('4','9') "
	cSQL += "                 AND GA4.GA4_CODDES = GD7.GD7_CODDES AND GA4.GA4_DATVIG <= GD7.GD7_DATDES)) "
	cSQL += "	AND( EXISTS (SELECT GE3.GE3_NRSEQG, GE3.GE3_CODDES FROM " + RetSQLName("GE3") + " GE3 "
	cSQL += "   											WHERE GE3.GE3_FILIAL = '" + xFilial("GE3") + "' AND GE3.D_E_L_E_T_ <> '*' AND GE3.GE3_NRSEQG = GD7.GD7_NRSEQG "
	cSQL += "   											AND GE3.GE3_CODDES = GD7.GD7_CODDES AND GE3.GE3_DATAUT = '"+SPACE(8)+"' ) "
	cSQL += "	 				OR NOT EXISTS (SELECT GE3.GE3_NRSEQG, GE3.GE3_CODDES FROM " + RetSQLName("GE3") + " GE3 "
	cSQL += "											          WHERE GE3.GE3_FILIAL = '" + xFilial("GE3") + "' AND GE3.D_E_L_E_T_ <> '*' AND GE3.GE3_NRSEQG = GD7.GD7_NRSEQG "
	cSQL += "											          AND GE3.GE3_CODDES = GD7.GD7_CODDES) ) "

 cSQL += " UNION ALL "
 cSQL += " SELECT '3' TIPO, GCY.GCY_CODLOC QRY_CODLOC, GCS.GCS_NOMLOC QRY_NOMLOC, GCY.GCY_REGATE QRY_REGATE, GCY.GCY_NOME QRY_NOMPAC,"
 cSQL += " GCY.GCY_DATALT QRY_DATALT, GCY.GCY_DATATE QRY_DATATE, '' QRY_NRSEQG, '' QRY_NRGUIA, "
 cSQL += " GCM.GCM_DESPLA QRY_DESPLA, '' QRY_CODDES, '' QRY_DDESPE, "
 cSQL += " SUM(CASE WHEN "+HS_FVALDES("GD5")+" IS NULL THEN 0 ELSE "+HS_FVALDES("GD5")+" END) + "   
	cSQL += " SUM(CASE WHEN "+HS_FVALDES("GD6")+" IS NULL THEN 0 ELSE "+HS_FVALDES("GD6")+" END) + " 	
	cSQL += " SUM(CASE WHEN "+HS_FVALDES("GD7")+"           IS NULL THEN 0 ELSE "+HS_FVALDES("GD7")+"          END) TVALDES, "
	cSQL += " SUM(CASE WHEN GDQ.GDQ_VALGAR                  IS NULL THEN 0 ELSE GDQ.GDQ_VALGAR                  END) TVALGAR, "          
 cSQL += " 0 QRY_VALMAT, 0 QRY_VALMED, 0 QRY_VALPRO "
 cSQL += " FROM " + RetSQLName("GCY") + " GCY"                                   
 cSQL += "      JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_REGATE = GCY.GCY_REGATE AND GCZ.GCZ_STATUS IN ('0', '1') AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
 cSql += "      JOIN " + RetSQLName("GCU") + " GCU ON GCU.D_E_L_E_T_ <> '*' AND GCU.GCU_FILIAL = '" + xFilial("GCU") + "' "
 cSql += "       AND GCU.GCU_CODTPG = GCZ.GCZ_CODTPG AND GCU.GCU_TPGUIA <> '7' "  //Nใo Apresenta Guias Tipo Retorno  
 cSQL += "      JOIN " + RetSQLName("GA9") + " GA9 ON GA9.GA9_CODCON = GCZ.GCZ_CODCON  AND GA9.GA9_TIPCON = '1' AND GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*' "
 cSQL += "      JOIN " + RetSQLName("GCS") + " GCS ON GCS.GCS_CODLOC = GCY.GCY_CODLOC AND GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' "
 cSQL += "      JOIN " + RetSQLName("GCM") + " GCM ON GCM.GCM_CODPLA = GCZ.GCZ_CODPLA AND GCM.GCM_FILIAL = '" + xFilial("GCM") + "' AND GCM.D_E_L_E_T_ <> '*' "
 cSQL += " LEFT JOIN " + RetSQLName("GD5") + " GD5 ON GD5.GD5_FILIAL = '" + xFilial("GD5") + "' AND GD5.D_E_L_E_T_ <> '*' AND GD5.GD5_REGATE = GCY.GCY_REGATE "
 cSQL += " LEFT JOIN " + RetSQLName("GD6") + " GD6 ON GD6.GD6_FILIAL = '" + xFilial("GD6") + "' AND GD6.D_E_L_E_T_ <> '*' AND GD6.GD6_REGATE = GCY.GCY_REGATE "
 cSQL += " LEFT JOIN " + RetSQLName("GD7") + " GD7 ON GD7.GD7_FILIAL = '" + xFilial("GD7") + "' AND GD7.D_E_L_E_T_ <> '*' AND GD7.GD7_REGATE = GCY.GCY_REGATE "
	cSQL += " LEFT JOIN " + RetSQLName("GDQ") + " GDQ ON GDQ.GDQ_FILIAL = '" + xFilial("GDQ") + "' AND GDQ.D_E_L_E_T_ <> '*' AND GDQ.GDQ_REGATE = GCY.GCY_REGATE AND GDQ.GDQ_STATUS <> '1' "
 cSQL += " WHERE GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "
 cSQL += " AND GCY.GCY_CODLOC BETWEEN '" + cCodLoc_De + "' AND '" + cCodLoc_Ate + "' "
 cSQL += " AND GCY.GCY_DATATE BETWEEN '" + DTOS(dDatAte_De) + "' AND '" + DTOS(dDatAte_Ate) + "'  "
 If nAlta == 1 //SEM ALTA
  cSQL += " AND GCY.GCY_DATALT =  '"+SPACE(8)+"' "
 ElseIf  nAlta == 2 //COM ALTA
  cSQL += " AND GCY.GCY_DATALT <> '"+SPACE(8)+"' "
 EndIf 

 cSQL += " GROUP BY GCY.GCY_CODLOC, GCS.GCS_NOMLOC, GCY.GCY_REGATE, GCY.GCY_NOME, GCY.GCY_DATALT, GCY.GCY_DATATE, GCM.GCM_DESPLA "
 cSQL += " HAVING SUM(CASE WHEN "+HS_FVALDES("GD5")+" IS NULL THEN 0 ELSE "+HS_FVALDES("GD5")+" END) + "   
 cSQL += "        SUM(CASE WHEN "+HS_FVALDES("GD6")+" IS NULL THEN 0 ELSE "+HS_FVALDES("GD6")+" END) + "
 cSQL += "        SUM(CASE WHEN "+HS_FVALDES("GD7")+"          IS NULL THEN 0 ELSE "+HS_FVALDES("GD7")+"           END) > "
 cSQL += "        SUM(CASE WHEN GDQ.GDQ_VALGAR                  IS NULL THEN 0 ELSE GDQ.GDQ_VALGAR                  END)   "
 
 cSQL += " ORDER BY QRY_CODLOC, QRY_REGATE, QRY_NRSEQG"
  
 cSQL :=  ChangeQuery(cSQL)

 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")
 DbGoTop()
                                
 If Eof()
  HS_MsgInf(STR0006, STR0016, STR0017) //"Nenhum dado foi encontado para a selecao efetuada!"###"Aten็ใo"###"Verifique a sele็ใo"
 Endif

/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
 ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

 SetRegua(150)

 While !EOF()

	 IncRegua()
   
   If lAbortPrint
    @nLin,00 PSAY STR0007 //"*** CANCELADO PELO OPERADOR ***"
    Exit
   Endif
   
   If nLin > nMaxLin
  /*              				   1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21
         			   0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789 */
    Cabec1 := STR0008 //"Atendimento                                                  Dt. Entrada  Dt. Alta   Plano"
    Cabec2 := STR0009 //"  Guia                  Advertencia"
    Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
    nLin := 9
   Endif

  If cCodLoc <> QRY->QRY_CODLOC
    If !EMPTY(cCodLoc)
     nLin ++
     @nLin,000 PSAY REPLICATE("-",132)
     nLin ++
    EndIf  
    @nLin,000 PSAY STR0010 + QRY->QRY_CODLOC + " - " + QRY->QRY_NOMLOC  //"Setor: "
    cCodLoc := QRY->QRY_CODLOC
    nTotGuia := 0
  EndIf
  
  If cRegAte <> QRY->QRY_REGATE
   nLin += 2
   @nLin,000 PSAY QRY->QRY_REGATE + " - " + SUBSTR(QRY->QRY_NOMPAC, 1, 31)
   @nLin,061 PSAY DTOC(STOD(QRY->QRY_DATATE))
   @nLin,074 PSAY DTOC(STOD(QRY->QRY_DATALT))
   @nLin,085 PSAY QRY->QRY_DESPLA  
   nLin ++
   If QRY->TIPO == "3"
    @nLin,003 PSAY STR0011 //"Valor total das despesas do atendimento maior que o valor das garantias"
   EndIf 
   cRegAte := QRY->QRY_RegAte
  EndIf
   
  If cNrSeqG <> QRY->QRY_NRSEQG
    @nLin,002 PSAY PADL(ALLTRIM(QRY->QRY_NRGUIA),20) 
    If QRY->TIPO == "0"
     @nLin,024 PSAY STR0012 //"Guia com autorizacao vencida"
    EndIf 
    nLin ++
    If QRY->TIPO <> "3"
     @nLin,013 PSAY STR0013 //"DESPESAS: "
    EndIf 
    cNrSeqG := QRY->QRY_NRSEQG
  EndIf 
  
  If !EMPTY(QRY->QRY_CODDES)
   @nLin,023 PSAY PADL(ALLTRIM(QRY->QRY_CODDES),Iif(lTamProd,15,30)) + " - " + SUBSTR(QRY->QRY_DDESPE,1,35) +;
                  IIF(QRY->TIPO == "1",STR0014, STR0015 )  //"  Mat/Med nao autorizado"###"  Procedimento nao autorizado"
   nLin ++
  EndIf
  
  DbSkip() /* Avanca o ponteiro do registro no arquivo */  
  
  If EOF()
    
  EndIf
 
 EndDo
                                                                                        


/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 ณ Finaliza a execucao do relatorio...                                 ณ
 ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

 SET DEVICE TO SCREEN

/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 ณ Se impressao em disco, chama o gerenciador de impressao...          ณ                                           	
 ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

 If aReturn[5]==1
  dbCommitAll()
  SET PRINTER TO
  OurSpool(wnrel)
 Endif

 MS_FLUSH()
 DBCloseArea()

Return()
