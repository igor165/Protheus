#INCLUDE "HSPAHR09.ch"
#Include "protheus.ch"
#include "TopConn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHR09 บ Autor ณ Cibele Peria       บ Data ณ  17/10/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio da analise do Teto Orcamentario                  บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHR09()
 Local   cDesc1      := STR0001 //"Este programa tem como objetivo imprimir relatorio "
 Local   cDesc2      := STR0002 //"de acordo com os parametros informados pelo usuario."
 Local   cDesc3      := STR0003 //"Atendimentos por periodo"
 Local   aOrd        := {}
 
 Private Cabec1      := ""
 Private Cabec2      := ""
 Private cTitulo     := STR0004 //"Analise do Teto Orcamentario"
 Private lEnd        := .F.
 Private lAbortPrint := .F.
 Private limite      := 132
 Private Tamanho     := "M"
 Private NomeProg    := "HSPAHR09"
 Private nTipo       := 18
 Private aReturn     := {STR0005, 1, STR0006, 2, 2, 1, "", 1} //"Zebrado"###"Administracao"
 Private nLastKey    := 0
 Private m_Pag       := 01
 Private wnRel       := NomeProg
 Private nTam        := 132
 
 Private nTipSel     := 0
 Private cCodPla_De  := ""
 Private cCodPla_Ate := ""
 Private dDatAte_De  := ""
 Private dDatAte_Ate := ""
 Private nFatur      := 0
 Private cNrLote_De  := ""
 Private cNrLote_Ate := ""
 Private cTpItem     := ""
 Private cCdItem_De  := ""
 Private cCdItem_Ate := ""
 Private nRel        := 0 
 
 If !Pergunte("HSPR09",.T.)
  Return()
 EndIf

 nTipSel     := MV_PAR01
 cCodPla_De  := MV_PAR02
 cCodPla_Ate := MV_PAR03
 dDatAte_De  := MV_PAR04
 dDatAte_Ate := MV_PAR05
 nFatur      := MV_PAR06
 cNrLote_De  := MV_PAR07
 cNrLote_Ate := MV_PAR08
 cTpItem     := Str(MV_PAR09, 1)
 cCdItem_De  := IIF(cTpItem == "1", MV_PAR10, IIF(cTpItem == "2", MV_PAR12, MV_PAR15)) 
 cCdItem_Ate := IIF(cTpItem == "1", MV_PAR11, IIF(cTpItem == "2", MV_PAR13, MV_PAR16))
 nTipRel     := MV_PAR14
 
 cTitulo     += " - " + IIf(nTipRel = 1, STR0007, STR0008) //"Analitico"###"Sintetico"
 If nTipRel == 1 //Analitico
  Cabec1 := PadR(STR0009, 80) //"Dt.Atend Paciente"
  Cabec1 += PadL(STR0010, 12) + " " //"Quantidade"
  Cabec1 += PadL(STR0011, 12) + " " //"Valor Unit"
  Cabec1 += PadL(STR0012, 12) + " " //"Valor Total"
  Cabec1 += PadR(STR0013, 12) + " " //"Lote"

  Cabec2 := Space(10) + STR0014 //"Atend   Profissional"

Else
  Cabec1 := PadR(IIf(cTpItem == "1", STR0015, STR0016), 55) //"Procedimento"###"Especialidade"
  Cabec1 += PadL(STR0017, 12) + " " //"Qtde Teto "
  Cabec1 += PadL(STR0018, 12) + " " //"Qtde Calc "
  Cabec1 += PadL(STR0019, 12) + " " //"Qtde Difer"
  Cabec1 += PadL(STR0020, 12) + " " //"Valor Teto"
  Cabec1 += PadL(STR0021, 12) + " " //"Valor Calc"
  Cabec1 += PadL(STR0022, 12)       //"Valor Difer"
  
 Endif

 wnrel := SetPrint("GGK", NomeProg, "", @cTitulo, cDesc1, cDesc2, cDesc3, .T., aOrd, .T., Tamanho, , .T.)
 If nLastKey == 27
  Return()
 Endif
 SetDefault(aReturn, "GGK")
 If nLastKey == 27
  Return()
 Endif

 nTipo := If(aReturn[4]==1,15,18)
 RptStatus({|| RunReport() }, cTitulo)
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ RunReportบ Autor ณ Cibele Peria       บ Data ณ  17/10/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Execucao do relatorio                                      บฑฑ 
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function RunReport()
 Local   cSql       := ""
 Local   cCodPla_W  := ""
 
 Private nLin       := 99
 Private nMax       := 55
 Private nTI_QtdDes := 0  //Total Itens
 Private nTI_ValTot := 0
 Private nTT_QtdDes := 0 //Total Teto
 Private nTT_ValTot := 0
 Private nTG_QtdDes := 0 //Total Geral dos Itens
 Private nTG_ValTot := 0
 
 cSQL := "SELECT GGK_CODPLA CODPLA, GGK_CDITEM CDITEM, GGK_TPITEM TPITEM, GGK_QTTETO QTTETO, GGK_VLTETO VLTETO "
 cSQL += "FROM " + RetSQLName("GGK") + " "
 cSQL += "WHERE GGK_FILIAL = '" + xFilial("GGK") + "' AND D_E_L_E_T_ <> '*' "
 cSQL += "AND GGK_CODPLA BETWEEN '" + cCodPla_De + "' AND '" + cCodPla_Ate + "' "
 cSQL += "AND GGK_TPITEM = '" + cTpItem + "' "
 cSQL += "AND GGK_CDITEM BETWEEN '" + Padr(cCdItem_De, Len(GGK->GGK_CDITEM)) + "' AND '"+ Padr(cCdItem_Ate, Len(GGK->GGK_CDITEM)) + "' "
 cSQL += "ORDER BY CODPLA, CDITEM"

 cSQL := ChangeQuery(cSQL)
 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")

 DbGoTop()
 If Eof()
  HS_MsgInf(STR0023, STR0024, STR0025) //"Nenhum 'Teto Or็amentแrio' foi encontrado para a sele็ใo efetuada"###"Verifique"###"Anแlise do Teto Or็amentแrio"
  DbCloseArea()
  Return()
 Endif
  
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Emissao do relatorio                                             ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 While !Eof()
  nTI_QtdDes := 0
  nTI_ValTot := 0
  
  If QRY->CODPLA <> cCodPla_W
   nLin := nMax + 1
   nLin := FS_Cabec() + 1
   @nLin, 000 PSAY STR0028 + ": " + QRY->CODPLA + "/" + HS_IniPadr("GCM", 2, QRY->CODPLA, "GCM_DESPLA",, .F.) //"Plano"
   cCodPla_W := QRY->CODPLA
  Endif
  
  nLin := FS_Cabec() + 1  
  @nLin, 000 PSAY IIF(nTipRel == 1, "==> ", "") + PadR(	QRY->CDITEM, IIf(cTpItem == "1", 9, IIF(cTpItem == "2", 2, 4))) + " " + IIF(cTpItem == "1", HS_IniPadr("GA7", 1, QRY->CDITEM, "GA7_DESC",, .F.), IIF(cTpItem == "2", HS_IniPadr("GFR", 1, QRY->CDITEM, "GFR_DSESPE",, .F.), HS_IniPadr("GAQ", 1, QRY->CDITEM, "GAQ_DESC",, .F.)))

  FS_CalcVTO(QRY->CODPLA, QRY->TPITEM, QRY->CDITEM)
  
  If nTipRel == 1 //Analitico
   
   If nTI_QtdDes > 0
    nLin := FS_Cabec() + 1
   Endif
   @nLin, 074 PSAY STR0026 //"Total"
   @nLin, 081 PSAY Transform(nTI_QtdDes, "@E 999,999.9999")
   @nLin, 107 PSAY Transform(nTI_ValTot, "@E 99999,999.99")

   nLin := FS_Cabec() + 1
   @nLin, 075 PSAY STR0027 //"Teto"
   @nLin, 081 PSAY Transform(QRY->QTTETO, "@E 999,999.9999")
   @nLin, 094 PSAY Transform((QRY->QTTETO - nTI_QtdDes), "@E 999,999.9999")
   @nLin, 107 PSAY Transform(QRY->VLTETO, "@E 99999,999.99")
   @nLin, 120 PSAY Transform((QRY->VLTETO - nTI_ValTot), "@E 99999,999.99")
   nLin := FS_Cabec() + 1   
   
  Else
   @nLin, 055 PSAY Transform(QRY->QTTETO, "@E 999,999.9999")   
   @nLin, 068 PSAY Transform(nTI_QtdDes, "@E 999,999.9999")
   @nLin, 081 PSAY Transform((QRY->QTTETO - nTI_QtdDes), "@E 999,999.9999")   
   @nLin, 094 PSAY Transform(QRY->VLTETO, "@E 99999,999.99")
   @nLin, 107 PSAY Transform(nTI_ValTot, "@E 99999,999.99")
   @nLin, 120 PSAY Transform((QRY->VLTETO - nTI_ValTot), "@E 99999,999.99")   
   
  Endif
  
  nTT_QtdDes += QRY->QTTETO
  nTT_ValTot += QRY->VLTETO

  If nTipRel == 2
   nTG_QtdDes += nTI_QtdDes
   nTG_ValTot += nTI_ValTot
  Endif
  
  DbSelectArea("QRY")
  DbSkip()
 End

 If nTipRel == 2
  nLin := FS_Cabec() + 2
  @nLin, 055 PSAY Transform(nTT_QtdDes, "@E 999,999.9999")   
  @nLin, 068 PSAY Transform(nTG_QtdDes, "@E 999,999.9999")
  @nLin, 081 PSAY Transform((nTT_QtdDes - nTG_QtdDes), "@E 999,999.9999")   
  @nLin, 094 PSAY Transform(nTT_ValTot, "@E 99999,999.99")
  @nLin, 107 PSAY Transform(nTG_ValTot, "@E 99999,999.99")
  @nLin, 120 PSAY Transform((nTT_ValTot - nTG_ValTot), "@E 99999,999.99")   
 Endif

 DbSelectArea("QRY") 
 DbCloseArea()
 
 SET DEVICE TO SCREEN
 If aReturn[5]==1
  DbCommitAll()
  SET PRINTER TO
  OurSpool(wnrel)
 Endif
 MS_FLUSH()
 
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_CalcVTOบ Autor ณ Cibele Peria       บ Data ณ  17/10/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Calcula os valores para a analise do teto                  บฑฑ 
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_CalcVTO(cCodPla, cTpItem, cCdItem)
 Local aArea  := GetArea()
 Local cAlias := IIf(nTipSel = 1, "GD7", "GE7")
 Local cPref  := cAlias + "." + PrefixoCpo(cAlias)
 Local cSQL := ""
 
 cSQL := "SELECT GBH.GBH_NOME NOME, " 
 If cTpItem == "3"
  cSQL += "GA7.GA7_CODGPP, "
 EndIf 
 cSQL += "GCZ.GCZ_DATATE DATATE, GCZ.GCZ_REGGER REGGER, "
 cSQL += "GCZ.GCZ_NRLOTE NRLOTE, " + cPref + "_REGATE REGATE, "
 cSQL += cPref + "_CODCRM CODCRM, SRA.RA_NOME NOMCRM, "
 cSQL += cPref + "_QTDDES QTDDES,  " + cPref + "_VALDES VALDES, "
 cSQL += HS_FValDes(cAlias) + " VALTOT "
 cSQL += "FROM " + RetSQLName(cPref) + " " + cAlias + " "
 cSQL += "JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' AND GCZ.GCZ_NRSEQG = " + cPref + "_NRSEQG "+;
         "                                   AND GCZ.GCZ_DATATE BETWEEN '" + DToS(dDatAte_De) + "' AND '" + DToS(dDatAte_Ate) + "' "
 cSql += "JOIN " + RetSQLName("GCU") + " GCU ON GCU.D_E_L_E_T_ <> '*' AND GCU.GCU_FILIAL = '" + xFilial("GCU") + "' "
 cSql += " AND GCU.GCU_CODTPG = GCZ.GCZ_CODTPG AND GCU.GCU_TPGUIA <> '7' "  //Nใo Apresenta Guias Tipo Retorno 
 
 If nTipSel == 1 //Atendimento
  If nFatur == 1 //Faturados   
   cSQL += "AND GCZ.GCZ_STATUS = '2' "
  Else
   cSQL += "AND GCZ.GCZ_STATUS IN ('0', '1') "
  EndIf
 ElseIf nTipSel = 2 //Por lote
  cSQL += "AND GCZ.GCZ_NRLOTE BETWEEN '" + cNrLote_De + "' AND '" + cNrLote_Ate + "' "
  If nFatur == 1 //Faturados
   cSQL += "AND GCZ.GCZ_STATUS >= '4' "
  Else
   cSQL += "AND GCZ.GCZ_STATUS = '3' "
  EndIf
 EndIf 
 
 If cTpItem == "3" 
  cSQL += "JOIN " + RetSQLName("GA7") + " GA7 ON GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' AND GA7.GA7_CODPRO = " + cPref + "_CODDES "
 Else
  cSQL += "AND " + cPref + IIf(cTpItem == "1", "_CODDES", "_CODESP") + " =  '" + cCdItem + "' " 
 EndIf
  
 cSQL += "JOIN " + RetSQLName("GBH") + " GBH ON GBH.GBH_FILIAL = '" + xFilial("GBH") + "' AND GBH.D_E_L_E_T_ <> '*' AND GBH.GBH_CODPAC = GCZ.GCZ_REGGER "
 cSQL += "JOIN " + RetSQLName("SRA") + " SRA ON SRA.RA_FILIAL = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' AND SRA.RA_CODIGO = " + cPref + "_CODCRM "
 cSQL += "WHERE " + cPref + "_FILIAL = '" + xFilial(cAlias) + "' AND " + cAlias + ".D_E_L_E_T_ <> '*' AND " + cPref + "_PGTMED <> '0' "
 cSQL += "AND GCZ.GCZ_CODPLA = '" + cCodPla + "' "        

 cSQL += "ORDER BY DATATE, REGATE"   

 cSQL := ChangeQuery(cSQL)
 TCQUERY cSQL NEW ALIAS "ITM"
 DbSelectArea("ITM")

 DbGoTop()
 While !Eof()

  If nTipRel == 1 //Analitico
   nLin := FS_Cabec() + 1
   @nLin, 000 PSAY HS_DToC(SToD(ITM->DATATE))
   @nLin, 009 PSAY ITM->REGGER + " " + ITM->NOME
   @nLin, 081 PSAY Transform(ITM->QTDDES, "@E 999,999.9999")
   @nLin, 094 PSAY Transform(ITM->VALDES, "@E 999,999.9999")
   @nLin, 107 PSAY Transform(ITM->VALTOT, "@E 99999,999.99")
   @nLin, 120 PSAY ITM->NRLOTE

   nLin := FS_Cabec() + 1
   @nLin, 009 PSAY ITM->REGATE   
   @nLin, 018 PSAY ITM->CODCRM + "-" + ITM->NOMCRM   
  Endif
  nTI_QtdDes += ITM->QTDDES
  nTI_ValTot += ITM->VALTOT
  
  DbSelectArea("ITM")
  DbSkip()
 End

 DbCloseArea()
 RestArea(aArea)
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_Cabec  บ Autor ณ Cibele             บ Data ณ  14/10/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Impressao do Cabecalho                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_Cabec()
 If nLin > nMax
  Cabec(cTitulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo, ,.T.)
  nLin := IIf(cTpItem == "1", 9, 8)
 Endif 
Return(nLin)
