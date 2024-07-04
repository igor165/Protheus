#INCLUDE "HSPAHRDV.ch"
#INCLUDE "protheus.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHRDV  บ Autor ณ Cibele Ap. L. Periaบ Data ณ  04/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio de participacao faturamento por setor            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑบAltera็๕esณ L.Gustavo Caloi 28/03/06 -> Padroniza็ใo da HS_MsgInf()    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHRDV()
 Private cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
 Private cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
 Private cDesc3         := STR0003 //"Particip. faturamento"
 Private titulo         := STR0003 //"Particip. faturamento"
 Private Cabec1         := "          Despesa                           Valor  Percentual"
 //                         0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.
 Private Cabec2         := ""
 Private imprime        := .T.
 Private aOrd           := {}
 Private lEnd         := .F.
 Private lAbortPrint  := .F.
 Private limite       := 80
 Private tamanho      := "P"
 Private nomeprog     := "HSPAHRDV"
 Private nTipo        := 15
 Private aReturn      := { STR0004, 1, STR0005, 1, 2, 1, "", 1} //"Zebrado"###"Administracao"
 Private nLastKey     := 0
 Private cPerg        := "HSPRDV"
 Private cbtxt        := Space(10)
 Private cbcont       := 00
 Private CONTFL       := 01
 Private m_pag        := 01
 Private wnrel        := "HSPAHRDV"

 Private cCODIMP := ""
 Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao

 If !Pergunte(cPerg, .T.)
  Return()
 EndIf
                                    
 nMaxLin := HS_MaxLin(cCODIMP)
 
 Titulo := AllTrim(Titulo) + " - Ref. " + MV_PAR03

 wnrel := SetPrint("GCZ", NomeProg, cPerg, @titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .F., Tamanho,, .F.)
 If nLastKey == 27
  Return()
 Endif

 SetDefault(aReturn, "GCZ")
 If nLastKey == 27
  Return()
 Endif

 nTipo := If(aReturn[4]==1,15,18)
 RptStatus({|| RunReport(Cabec1, Cabec2, Titulo) },Titulo)
 
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRunReport บ Autor ณ Cibele Peria       บ Data ณ  04/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Execucao do relatorio                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function RunReport(Cabec1, Cabec2, Titulo)
 Local cQry        := ""
 
 Local cCodLoc     := ""
 Local aSetores    := {}
 Local aTipos      := {}
 Local aTotais     := {}
 Local nValTot_Set := 0
 Local nQtdTip_Set := 0
 Local nValTot_Ger := 0
 Local nPosS       := 0
 Local nForTipo    := 0
 Local nPercent    := 0
 Local aVetor      := {}
 
 Local cCodLoc_De  := ""
 Local cCodLoc_Ate := ""
 Local cMesRef     := ""
 Local nStatus     := ""
 Local nTipRel     := ""
 Local nGrafico    := ""                   
 Local nAgrPor     := 1

 Private aGE5CBox  := {}
 Private aGE7CBox  := {}
 Private nLin      := nMaxLin * 2

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Parametros das perguntas ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 cCodLoc_De  := mv_par01
 cCodLoc_Ate := mv_par02
 cMesRef     := mv_par03
 nStatus     := mv_par04
 nTipRel     := mv_par05
 nGrafico    := mv_par06
 nAgrPor     := mv_par07
  
 If nTipRel == 1   //Analitico
  Cabec1     := STR0006 //"          Despesa                           Valor  Percentual"
  Cabec2     := ""
 Else
  Cabec1     := STR0007 //"Atendimento                                             Matricula            Guia   Pront. Dt/Hr.Atendim."
 Endif

 cQry := "SELECT GE5.GE5_CODLOC CODLOC, 'GE5' ARQUIVO, " + IIf(nAgrPor == 1, "GBI.GBI_TIPO TIPO", "GBI.GBI_CODGDE TIPO, GAW.GAW_DESC DESGDE") + ", SUM(" + HS_FValDes("GE5") + ") VALOR "
 cQry += "FROM " + RetSqlName("GE5") + " GE5 "
 cQry += "JOIN " + RetSqlName("GBI") + " GBI ON GBI.GBI_PRODUT = GE5.GE5_CODDES AND GBI.GBI_FILIAL = '" + xFilial("GBI") + "' AND GBI.D_E_L_E_T_ <> '*' "
 cQry += "JOIN " + RetSqlName("GCZ") + " GCZ ON GCZ.GCZ_NRSEQG = GE5.GE5_NRSEQG AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "   
 cQry += "JOIN " + RetSQLName("GCU") + " GCU ON GCU.D_E_L_E_T_ <> '*' AND GCU.GCU_FILIAL = '" + xFilial("GCU") + "' "
 cQry += " AND GCU.GCU_CODTPG = GCZ.GCZ_CODTPG AND GCU.GCU_TPGUIA <> '7' "  //Nใo Apresenta Guias Tipo Retorno   
 IF(nAgrPor == 2)
  cQry += "JOIN " + RetSQLName("GAW") + " GAW ON GAW.D_E_L_E_T_ <> '*' AND GAW.GAW_FILIAL = '" + xFilial("GAW") + "' AND GBI.GBI_CODGDE = GAW.GAW_CODGDE "
 EndIf
 cQry += "JOIN " + RetSqlName("GAT") + " GAT ON GAT.GAT_NUMLOT = GCZ.GCZ_NRLOTE AND GAT.GAT_FILIAL = '" + xFilial("GAT") + "' AND GAT.D_E_L_E_T_ <> '*' "    
 cQry += "WHERE GE5.GE5_FILIAL = '" + xFilial("GE5") + "' AND GE5.D_E_L_E_T_ <> '*' "
 cQry += "AND GE5.GE5_CODLOC BETWEEN '" + cCodLoc_De + "' AND '" + cCodLoc_Ate + "' "
 If !Empty(cMesRef)
  cQry += "AND GAT.GAT_MESREF = '" + cMesRef + "' "
 EndIf 
 If nStatus == 1
  cQry += "AND GCZ.GCZ_STATUS = '3' "
 ElseIf nStatus = 2
  cQry += "AND GCZ.GCZ_STATUS >= '4' "
 Else
  cQry += "AND GCZ.GCZ_STATUS >= '3' "
 Endif 
 cQry += "GROUP BY GE5.GE5_CODLOC, " + IIf(nAgrPor == 1, "GBI.GBI_TIPO", "GBI.GBI_CODGDE, GAW.GAW_DESC")
 
 cQry += " UNION ALL "
 cQry += "SELECT GE6.GE6_CODLOC CODLOC, 'GE6' ARQUIVO, " + IIf(nAgrPor == 1, "'0' TIPO", "GAA.GAA_CODGDE TIPO, GAW.GAW_DESC DESGDE") + ", SUM(" + HS_FValDes("GE6") + ") VALOR "
 cQry += "FROM " + RetSqlName("GE6") + " GE6 "
 cQry += "JOIN " + RetSqlName("GAA") + " GAA ON GAA.GAA_CODTXD = GE6.GE6_CODDES AND GAA.GAA_FILIAL = '" + xFilial("GAA") + "' AND GAA.D_E_L_E_T_ <> '*' "
 cQry += "JOIN " + RetSqlName("GCZ") + " GCZ ON GCZ.GCZ_NRSEQG = GE6.GE6_NRSEQG AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "  
 cQry += "JOIN " + RetSQLName("GCU") + " GCU ON GCU.D_E_L_E_T_ <> '*' AND GCU.GCU_FILIAL = '" + xFilial("GCU") + "' "
 IF(nAgrPor == 2)
  cQry += "JOIN " + RetSQLName("GAW") + " GAW ON GAW.D_E_L_E_T_ <> '*' AND GAW.GAW_FILIAL = '" + xFilial("GAW") + "' AND GAA.GAA_CODGDE = GAW.GAW_CODGDE "
 EndIf
 cQry += " AND GCU.GCU_CODTPG = GCZ.GCZ_CODTPG AND GCU.GCU_TPGUIA <> '7' "  //Nใo Apresenta Guias Tipo Retorno    
 cQry += "JOIN " + RetSqlName("GAT") + " GAT ON GAT.GAT_NUMLOT = GCZ.GCZ_NRLOTE AND GAT.GAT_FILIAL = '" + xFilial("GAT") + "' AND GAT.D_E_L_E_T_ <> '*' "  
 cQry += "WHERE GE6.GE6_FILIAL = '" + xFilial("GE6") + "' AND GE6.D_E_L_E_T_ <> '*' "
 cQry += "AND GE6.GE6_CODLOC BETWEEN '" + cCodLoc_De + "' AND '" + cCodLoc_Ate + "' "
 If !Empty(cMesRef)
  cQry += "AND GAT.GAT_MESREF = '" + cMesRef + "' "
 EndIf
 If nStatus == 1
  cQry += "AND GCZ.GCZ_STATUS = '3' "
 ElseIf nStatus = 2
  cQry += "AND GCZ.GCZ_STATUS >= '4' "
 Else
  cQry += "AND GCZ.GCZ_STATUS >= '3' "
 Endif 
 cQry += "GROUP BY GE6.GE6_CODLOC" + IIf(nAgrPor == 1, "", ", GAA.GAA_CODGDE, GAW.GAW_DESC")
  
 cQry += " UNION ALL "
 cQry += "SELECT GE7.GE7_CODLOC CODLOC, 'GE7' ARQUIVO, " + IIf(nAgrPor == 1, "GA7.GA7_TIPPRO TIPO", "GA7.GA7_CODGDE TIPO, GAW.GAW_DESC DESGDE") + ", SUM(" + HS_FValDes("GE7") + ") VALOR "
 cQry += "FROM " + RetSqlName("GE7") + " GE7 "
 cQry += "JOIN " + RetSqlName("GA7") + " GA7 ON GA7.GA7_CODPRO = GE7.GE7_CODDES AND GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' "
 cQry += "JOIN " + RetSqlName("GCZ") + " GCZ ON GCZ.GCZ_NRSEQG = GE7.GE7_NRSEQG AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "  
 cQry += "JOIN " + RetSQLName("GCU") + " GCU ON GCU.D_E_L_E_T_ <> '*' AND GCU.GCU_FILIAL = '" + xFilial("GCU") + "' "
 IF(nAgrPor == 2)
  cQry += "JOIN " + RetSQLName("GAW") + " GAW ON GAW.D_E_L_E_T_ <> '*' AND GAW.GAW_FILIAL = '" + xFilial("GAW") + "' AND GA7.GA7_CODGDE = GAW.GAW_CODGDE "
 EndIf
 cQry += " AND GCU.GCU_CODTPG = GCZ.GCZ_CODTPG AND GCU.GCU_TPGUIA <> '7' "  //Nใo Apresenta Guias Tipo Retorno    
 cQry += "JOIN " + RetSqlName("GAT") + " GAT ON GAT.GAT_NUMLOT = GCZ.GCZ_NRLOTE AND GAT.GAT_FILIAL = '" + xFilial("GAT") + "' AND GAT.D_E_L_E_T_ <> '*' "   
 cQry += "WHERE GE7.GE7_FILIAL = '" + xFilial("GE7") + "' AND GE7.D_E_L_E_T_ <> '*' "
 cQry += "AND GE7.GE7_CODLOC BETWEEN '" + cCodLoc_De + "' AND '" + cCodLoc_Ate + "' " 
 cQry += "AND GE7.GE7_PGTMED <> '0' " 
 If !Empty(cMesRef)
  cQry += "AND GAT.GAT_MESREF = '" + cMesRef + "' "
 EndIf 
 If nStatus == 1
  cQry += "AND GCZ.GCZ_STATUS = '3' "
 ElseIf nStatus = 2
  cQry += "AND GCZ.GCZ_STATUS >= '4' "
 Else
  cQry += "AND GCZ.GCZ_STATUS >= '3' "
 Endif 
 cQry += "GROUP BY GE7.GE7_CODLOC, " + IIf(nAgrPor == 1, "GA7.GA7_TIPPRO", "GA7.GA7_CODGDE, GAW.GAW_DESC")

 cQry += " ORDER BY CODLOC, ARQUIVO, TIPO"
 
 cQry := ChangeQuery(cQry)
 dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"QRY",.F.,.T.)
 
 DbSelectArea("QRY")
 DbGoTop()
 If Eof()
  DbCloseArea()
  HS_MsgInf(STR0008, STR0019, STR0022) //"Nenhuma informacao foi encontrada para a selecao efetuada"###"Aten็ใo"###"Execucao do relatorio"
  Return()
 Endif

 HS_DCBox("GBI_TIPO", @aGE5CBox)
 HS_DCBox("GA7_TIPPRO", @aGE7CBox)

 While !Eof()

  If lAbortPrint
   @nLin,000 PSAY STR0009 //"*** CANCELADO PELO OPERADOR ***"
   Exit
  Endif
  
  cCodLoc     := QRY->CODLOC
  nValTot_Set := 0
  nQtdTip_Set := 0

  While !Eof() .and. QRY->CODLOC == cCodLoc
  
   nValTot_Set += QRY->VALOR
   nQtdTip_Set += 1

   If (nPosS := aScan(aTipos, {|x| x[1]+x[2] == QRY->ARQUIVO + QRY->TIPO}) ) == 0
    aAdd(aTipos, {QRY->ARQUIVO, IIf(nAgrPor == 1, QRY->TIPO, QRY->DESGDE), QRY->VALOR})
   Else
    aTipos[nPosS, 3] += QRY->VALOR
   Endif  

   DbSkip()
  
  End
  
  aAdd(aTotais, {cCodLoc, nValTot_Set, nQtdTip_Set})
  nValTot_Ger += nValTot_Set
 End 
 
 If nGrafico == 1
  For nForTipo := 1 to Len(aTipos)
   aAdd( aVetor, {FS_DescCBox(aTipos[nForTipo, 1], aTipos[nForTipo, 2]), aTipos[nForTipo, 3]})
  Next   
  oGraf := hsGRAF():NEW(Titulo, Titulo, STR0010,STR0011, STR0012, "", aVetor,1,2,0,0,1,11,6,6,25,20)    //"Setor...: "###"Quantidade"###"Usuarios" //"Valores por tipo de despesa"###"Valor"###"Tipo de Despesa"
 Endif

 If nTipRel == 1  //Analitico 
  DbGoTop()
  While !Eof() 
  
   If lAbortPrint
    @nLin,000 PSAY STR0009 //"*** CANCELADO PELO OPERADOR ***"
    Exit
   Endif
   
   DbSelectArea("GCS")
   DbSetOrder(1)
   DbSeek(xFilial("GCS") + QRY->CODLOC)
 
   nPosS       := aScan(aTotais, {|x| x[1] == QRY->CODLOC})
   nValTot_Set := aTotais[nPosS, 2]
   nQtdTip_Set := aTotais[nPosS, 3]
   nAcuPer     := 0
   nAcuTip     := 0
   cCodLoc := QRY->CODLOC  
   
   If nLin+3 > nMaxLin
    FS_Cabec()
    nLin -= 1
   Endif
   nLin += 2
   @nLin, 000 PSAY STR0013 + QRY->CODLOC + " - " + GCS->GCS_NOMLOC //"Setor: "
 
   DbSelectArea("QRY")
   While !Eof() .and. QRY->CODLOC == cCodLoc  
    
    nAcuTip += 1
    nPercent := Round(IIF(nAcuTip==nQtdTip_Set, 100 - nAcuPer, (QRY->VALOR / nValTot_Set) * 100) , 2)
    nAcuPer  += nPercent
    
    If nLin+1 > nMaxLin
     FS_Cabec()
    Endif
    nLin ++   
    @nLin, 010 PSAY IIF(nAgrPor == 1, FS_DescCBox(QRY->ARQUIVO, QRY->TIPO), QRY->DESGDE)
    @nLin, 036 PSAY TRANSFORM(QRY->VALOR, "@E 99,999,999.99")
    @nLin, 055 PSAY TRANSFORM(nPercent, "@E 999.99")    
    
    DbSkip()
   End
   
   FS_Total(STR0014, nValTot_Set, Round((nValTot_Set / nValTot_Ger) * 100, 2)) //"Total do Setor"
 
  End
  FS_Total(STR0015, nValTot_Ger) //"Total Geral"
 Endif 
      
 nLin := nMaxLin * 2
 Cabec1 := STR0016 //"Despesas                        Valor"
 Cabec2 := ""
 FS_Cabec() 
 
 nLin ++
 @nLin, 000 PSAY IIf(nAgrPor == 1, STR0017, STR0024) //"Totalizacao por tipo de despesa"
 For nForTipo := 1 to len(aTipos)
    If nLin+1 > nMaxLin
        FS_Cabec()
    Endif 
  nLin ++
  @nLin, 010 PSAY IIF(nAgrPor == 1, FS_DescCBox(aTipos[nForTipo, 1], aTipos[nForTipo, 2]), aTipos[nForTipo, 2])
  @nLin, 036 PSAY TRANSFORM(aTipos[nForTipo, 3], "@E 99,999,999.99")
  @nLin, 055 PSAY TRANSFORM(Round((aTipos[nForTipo, 3] / nValTot_Ger) * 100, 2), "@E 999.99")      
 Next nForTipo
 
 FS_Total(STR0015, nValTot_Ger)
 
 SET DEVICE TO SCREEN
 If aReturn[5]==1
  DbCommitAll()
  SET PRINTER TO
  OurSpool(wnrel)
 Endif
 MS_FLUSH()

 DbSelectArea("QRY")
 DbCloseArea()
Return()
                                                
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณHS_VPerRDVบ Autor ณ Cibele Peria       บ Data ณ  04/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Validacao das perguntas                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_VPerRDV()
 Local lRet := .T.

 If Empty(mv_par03)
  HS_MsgInf(STR0018, STR0019, STR0023) //"Por favor, informe o mes de referencia"###"Atencao"###"Validacao das perguntas"
  lRet := .F.
 EndIf   

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_Cabec  บ Autor ณ Cibele Peria       บ Data ณ  04/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Cabecalho                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_Cabec()
 Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
 nLin := 7
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_Total  บ Autor ณ Cibele Peria       บ Data ณ  04/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Impressao do total                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_Total(cTitulo, nValor, nPercent)
 If nLin+1 > nMaxLin
  FS_Cabec()
 Endif

 nLin ++
 @nLin, 015 PSAY cTitulo
 @nLin, 035 PSAY TRANSFORM(nValor, "@E 999,999,999.99")
 @nLin, 055 PSAY TRANSFORM(nPercent, "@E 999.99")    
 nLin ++ 

Return()

Static Function FS_DescCBox(cAlias, cTipo)
 Local cDescr   := ""
 Local nPosTp   := 0                                                                               
 Local aDescr   := IIF(cAlias=="GE6", {},aClone(&("a"+cAlias+"CBox")))
 
 If cAlias == "GE6"
  cDescr := STR0020 //"Taxas/Diarias"
 Else
  If (nPosTP := aScan(aDescr, {|x| x[1] == cTipo})) == 0
   cDescr := STR0021 //"Outros"
  Else 
   cDescr := aDescr[nPosTp, 2]
  Endif
 Endif  

Return(cDescr)

Function HS_DCBox(cCampo,aArray)
 Local aArea   := GetArea()
 Local cOcorr  := {}
 Local nPosSep := 0
 
 aArray := {}
 SX3->(DbSetOrder(2))
 If SX3->(DbSeek(cCampo)) .And. !Empty(X3Cbox())
 	cCBOX := AllTrim(X3Cbox())
 	While Len(cCBox) > 0
 	 nPosSep := AT(";", cCBox)
 	 cOcorr := IIF(nPosSep==0, cCBox, Substr(cCBox, 1, nPosSep-1))
 	 nPosSep := AT("=", cOcorr)
 	 aAdd(aArray, {Substr(cOcorr, 1, nPosSep-1), Substr(cOcorr, nPosSep+1)} )
			cCBOX := SubStr(cCBox, len(cOcorr)+2)
		End
	Endif

 RestArea(aArea)
Return()
