#INCLUDE "HSPAHRDU.ch"
#INCLUDE "protheus.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHRDU  บ Autor ณ Cibele Ap. L. Periaบ Data ณ  04/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio de Contas nao enviadas/ Periodo                  บฑฑ
ฑฑบ          ณ (Este programa foi feito com base no HSPAHRAA)             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑบAltera็๕esณ L.Gustavo Caloi 28/03/06 -> Padroniza็ใo da HS_MsgInf()    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHRDU()
 Private cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
 Private cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
 Private cDesc3         := STR0003 //"Contas nao enviadas"
 Private titulo         := STR0003 //"Contas nao enviadas"
 Private Cabec1         := ""
 Private Cabec2         := ""  //"         Despesa          Descricao                                          Quantidade       Vlr.Unitario             Valor Total"
 //"Paciente                                             Matricula                 Guia   Atend. Dt/Hr.Atendim.                 Valor"
 // xxxxxx xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx xxxxxxxxxxxxxxxxxxxxxxxxx 999999 xxxxxx xx/xx/xx-xx:xx         99.999.999,99
 //"         Despesa          Descricao                                          Quantidade       Vlr.Unitario       Valor Total"
 //                                                                                                    99.999.999,99	
 // 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
 //           1         2         3         4         5         6         7         8         9         0         1         2         3
 Private imprime        := .T.
 Private aOrd           := {}
 Private lEnd         := .F.
 Private lAbortPrint  := .F.
 Private limite       := 132
 Private tamanho      := "M"
 Private nomeprog     := "HSPAHRDU"
 Private nTipo        := 15
 Private aReturn      := { STR0005, 1, STR0006, 1, 2, 1, "", 1} //"Zebrado"###"Administracao" 
 Private nLastKey     := 0
 Private cPerg        := "HSPRDU"
 Private cbtxt        := Space(10)
 Private cbcont       := 00
 Private CONTFL       := 01
 Private m_pag        := 01
 Private wnrel        := "HSPAHRDU"

 Private cCODIMP := ""
 Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao
 Private lTamProd := IIf((TamSx3("GD5_CODDES")[1])<=15, .T., .F.)
  Cabec2:= IIF(lTamProd,STR0004,STR0027)

 
 If !Pergunte(cPerg, .T.)
  Return()
 EndIf

 nMaxLin := HS_MaxLin(cCODIMP)
 nLin := nMaxLin * 2

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
 Local cQry      := "", cSel    := "", cFrom   := "", cWhere := "", cCond := ""
 Local nQtdGuias := 0      
 Local nQtdGuiCo := 0
 Private cCodCon_De  := ""
 Private cCodCon_Ate := ""
 Private cCodLoc_De  := ""
 Private cCodLoc_Ate := ""
 Private cCodPla_De  := ""
 Private cCodPla_Ate := ""
 Private dDatAte_De  := ""
 Private dDatAte_Ate := ""
 Private nTipRel     := 0
 Private nOrdem      := 0
 Private cNrSeqG     := ""
 Private nLin        := 0
 Private nTotGE5_Conv := 0, nTotGE6_Conv := 0, nTotGE7_Conv := 0, nTotal_Conv  := 0   //// variaveis  total do convenio
 Private nTotGE5_Guia := 0, nTotGE6_Guia := 0, nTotGE7_Guia := 0, nTotal_Guia  := 0
 Private nTotGE5_Geral := 0, nTotGE6_Geral := 0, nTotGE7_Geral := 0, nTotal_Geral  := 0
 Private cCODDES := ""

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Parametros das perguntas ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 cCodCon_De  := mv_par01
 cCodCon_Ate := mv_par02
 cCodLoc_De  := mv_par03
 cCodLoc_Ate := mv_par04
 cCodPla_De  := mv_par05
 cCodPla_Ate := mv_par06
 dDatAte_De  := mv_par07
 dDatAte_Ate := mv_par08
 nTipRel     := mv_par09
 nOrdem      := mv_par10

 If nTipRel == 1   //Sintetico 
/*    			                            1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21
        		               	 0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789 */
  Cabec1     := STR0007 //"Atendimento                                   Setor  Matricula                 Guia   Pront. Dt/Hr.Atendim. Status         Total"
  Cabec2     := ""
 Else
  Cabec1     := STR0008 //"Atendimento                                      Setor  Matricula                 Guia   Pront. Dt/Hr.Atendim. Status"
 Endif
    
 cSel  := "SELECT GCZ_LOCATE SETOR, GCZ_CODCON CODCON, GCZ_NRSEQG NRSEQG, GCZ_REGATE REGATE, "
 cSel  += "GCZ_REGGER REGGER, GCZ_STATUS STATU, GCY_NOME NOME, GD4_MATRIC MATRIC, GCZ_DATATE DATATE, GCY_HORATE HORATE, "
 
 cFrom := "FROM " + RetSqlName("GCZ") + " GCZ "
 cFrom += "JOIN " + RetSQLName("GCU") + " GCU ON GCU.D_E_L_E_T_ <> '*' AND GCU.GCU_FILIAL = '" + xFilial("GCU") + "' "
 cFrom += " AND GCU.GCU_CODTPG = GCZ.GCZ_CODTPG AND GCU.GCU_TPGUIA <> '7' "  //Nใo Apresenta Guias Tipo Retorno  
 cFrom += "JOIN " + RetSqlName("GD4") + " GD4 ON GD4_REGGER = GCZ_REGGER AND GD4_CODCON = GCZ_CODCON AND GD4_CODPLA = GCZ_CODPLA AND GD4_FILIAL = '" + xFilial("GD4") + "' AND GD4.D_E_L_E_T_ <> '*' "
 cFrom += "JOIN " + RetSqlName("GCY") + " GCY ON GCY_REGATE = GCZ_REGATE AND GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "
 
 cWhere  += "WHERE GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
 
 cCond += " AND GCY_TPALTA <> '99' "  // Atendimento nใo cancelados
 cCond += "AND GCZ_CODCON BETWEEN '" + cCodCon_De + "' AND '" + cCodCon_Ate + "' "
 cCond += "AND GCZ_DATATE BETWEEN '" + DTOS(dDatAte_De) + "' AND '" + DTOS(dDatAte_Ate) + "' "
 cCond += "AND GCZ_CODPLA BETWEEN '" + cCodPla_De + "' AND '" + cCodPla_Ate + "' "  
 cCond += "AND GCZ_CANCEL <> '1'"

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Query SQL                                          ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 cQry := cSel + "'1' TIPO, GD5_CODDES CODDES, B1_DESC DESCR, GD5_VALDES VALDES, GD5_QTDDES QTDDES, "
 cQry += HS_FVALDES("GD5") + " VALTOT "
 cQry += cFrom                                        
 
 cQry += "JOIN " + RetSqlName("GD5") + " GD5 ON GD5_NRSEQG = GCZ_NRSEQG "
 cQry += "JOIN " + RetSqlName("SB1") + " SB1 ON GD5_CODDES = B1_COD "
 cQry += cWhere
 cQry += "AND GD5_FILIAL = '" + xFilial("GD5") + "' AND GD5.D_E_L_E_T_ <> '*' "
 cQry += "AND GD5_CODLOC BETWEEN '" + cCodLoC_De + "' AND '" + cCodLoC_Ate + "' " 
 cQry += "AND B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.D_E_L_E_T_ <> '*' "
 cQry += "AND GCZ_STATUS = '0' "
 cQry += cCond
 
 cQry += " UNION ALL "
 cQry += cSel + "'1' TIPO, GE5_CODDES CODDES, B1_DESC DESCR, GE5_VALDES VALDES, GE5_QTDDES QTDDES, "
 cQry += HS_FVALDES("GE5") + " VALTOT "
 cQry += cFrom 
 cQry += "JOIN " + RetSqlName("GE5") + " GE5 ON GE5_NRSEQG = GCZ_NRSEQG "
 cQry += "AND GE5_CODLOC BETWEEN '" + cCodLoC_De + "' AND '" + cCodLoC_Ate + "' " 
 cQry += "JOIN " + RetSqlName("SB1") + " SB1 ON GE5_CODDES = B1_COD "
 cQry += cWhere
 cQry += "AND GE5_FILIAL = '" + xFilial("GE5") + "' AND GE5.D_E_L_E_T_ <> '*' "
 cQry += "AND B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.D_E_L_E_T_ <> '*' "
 cQry += "AND GCZ_STATUS IN ('1', '2', '3') "
 cQry += cCond

 cQry += " UNION ALL "
 cQry += cSel + "'2' TIPO, GD6_CODDES CODDES, GAA_DESC DESCR, GD6_VALDES VALDES, GD6_QTDDES QTDDES, "
 cQry += HS_FVALDES("GD6") + " VALTOT "
 cQry += cFrom 
 cQry += "JOIN " + RetSqlName("GD6") + " GD6 ON GD6_NRSEQG = GCZ_NRSEQG "
 cQry += "JOIN " + RetSqlName("GAA") + " GAA ON GD6_CODDES = GAA_CODTXD "
 cQry += cWhere
 cQry += "AND GD6_FILIAL = '" + xFilial("GD6") + "' AND GD6.D_E_L_E_T_ <> '*' "
 cQry += "AND GD6_CODLOC BETWEEN '" + cCodLoC_De + "' AND '" + cCodLoC_Ate + "' " 
 cQry += "AND GAA_FILIAL = '" + xFilial("GAA") + "' AND GAA.D_E_L_E_T_ <> '*' " 
 cQry += "AND GCZ_STATUS = '0' " 
 cQry += cCond
 
 cQry += " UNION ALL "
 cQry += cSel + "'2' TIPO, GE6_CODDES CODDES, GAA_DESC DESCR, GE6_VALDES VALDES, GE6_QTDDES QTDDES, "
 cQry += HS_FVALDES("GE6") + " VALTOT "
 cQry += cFrom 
 cQry += "JOIN " + RetSqlName("GE6") + " GE6 ON GE6_NRSEQG = GCZ_NRSEQG "
 cQry += "AND GE6_CODLOC BETWEEN '" + cCodLoC_De + "' AND '" + cCodLoC_Ate + "' "  
 cQry += "JOIN " + RetSqlName("GAA") + " GAA ON GE6_CODDES = GAA_CODTXD "
 cQry += cWhere
 cQry += "AND GE6_FILIAL = '" + xFilial("GE6") + "' AND GE6.D_E_L_E_T_ <> '*' "
 cQry += "AND GAA_FILIAL = '" + xFilial("GAA") + "' AND GAA.D_E_L_E_T_ <> '*' " 
 cQry += "AND GCZ_STATUS IN ('1', '2', '3') "
 cQry += cCond

 cQry += "UNION ALL "
 cQry += cSel + "'3' TIPO, GD7_CODDES CODDES, GA7_DESC DESCR, GD7_VALDES VALDES, GD7_QTDDES QTDDES, "
 cQry += HS_FVALDES("GD7") + " VALTOT "
 cQry += cFrom 
 cQry += "JOIN " + RetSqlName("GD7") + " GD7 ON GD7_NRSEQG = GCZ_NRSEQG "
 cQry += "JOIN " + RetSqlName("GA7") + " GA7 ON GD7_CODDES = GA7_CODPRO "
 cQry += cWhere
 cQry += "AND GD7_FILIAL = '" + xFilial("GD7") + "' AND GD7.D_E_L_E_T_ <> '*' "
  cQry += "AND GD7_CODLOC BETWEEN '" + cCodLoC_De + "' AND '" + cCodLoC_Ate + "' " 
 cQry += "AND GD7_PGTMED <> '0' " 
 cQry += "AND GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' " 
 cQry += "AND GCZ_STATUS = '0' "  
 cQry += cCond
 
 cQry += "UNION ALL "
 cQry += cSel + "'3' TIPO, GE7_CODDES CODDES, GA7_DESC DESCR, GE7_VALDES VALDES, GE7_QTDDES QTDDES, "
 cQry += HS_FVALDES("GE7") + " VALTOT "
 cQry += cFrom 
 cQry += "JOIN " + RetSqlName("GE7") + " GE7 ON GE7_NRSEQG = GCZ_NRSEQG "
 cQry += "JOIN " + RetSqlName("GA7") + " GA7 ON GE7_CODDES = GA7_CODPRO "
 cQry += cWhere
 cQry += "AND GE7_FILIAL = '" + xFilial("GE7") + "' AND GE7.D_E_L_E_T_ <> '*' "
 cQry += "AND GE7_CODLOC BETWEEN '" + cCodLoC_De + "' AND '" + cCodLoC_Ate + "' " 
 cQry += "AND GE7_PGTMED <> '0' " 
 cQry += "AND GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' " 
 cQry += "AND GCZ_STATUS IN ('1', '2', '3') "
 cQry += cCond

 If nOrdem == 1 //nome Pac
  cQry += "ORDER BY CODCON, NOME, REGGER, NRSEQG, TIPO, CODDES  "
 ElseIf nOrdem == 2 //data Ate. + Hora
  cQry += "ORDER BY CODCON, DATATE, HORATE, REGGER, NRSEQG, TIPO, CODDES "
 Else //Nr Atend.
  cQry += "ORDER BY CODCON, REGATE, REGGER, NRSEQG, TIPO, CODDES "
 EndIf

 cQry := ChangeQuery(cQry)
 dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TRB",.F.,.T.)
 
 DbSelectArea("TRB")
 SetRegua(RecCount())
 DbGoTop()

 cCodCon := ""
 cNrSeqG := ""

 While !Eof()      ///Query

  If lAbortPrint
   @nLin,000 PSAY STR0009 //"*** CANCELADO PELO OPERADOR ***"
   Exit
  Endif
  
  DbSelectArea("GA9")
  DbSetOrder(1)
  DbSeek(xFilial("GA9") + TRB->CODCON)
  cCodCon := TRB->CODCON    
  FS_Cabec(Cabec1, Cabec2, .T.)
  
 While !Eof() .and. TRB->CODCON == cCodCon //convenio
 If nLin+1 > nMaxLin
    FS_Cabec(Cabec1, Cabec2)
       
   Endif  
   

   cNrSeqG   := TRB->NRSEQG
   If nLin+1 > nMaxLin
    FS_Cabec(Cabec1, Cabec2)
   Endif
   
   nLin ++   
	  @nLin,000 PSAY TRB->REGATE
   @nLin,007 PSAY SubStr(TRB->NOME,1,33)
   @nLin,041 PSAY TRB->SETOR
   @nLin,044 PSAY TRB->MATRIC
   @nLin,070 PSAY TRB->NRSEQG
   @nLin,077 PSAY TRB->REGGER
   @nLin,084 PSAY DTOC( STOD(TRB->DATATE) ) + "-" + TRB->HORATE + " " + SubStr(HS_RDescrB("GCZ_STATUS", TRB->STATU),1,20)
 
   While !Eof() .and. TRB->CODCON == cCodCon .and. TRB->NRSEQG == cNrSeqG   //guiasdo convenio

    If nTipRel == 2 //analitico
     If nLin+1 > nMaxLin
      FS_Cabec(Cabec1, Cabec2)
     Endif 
     nLin++
     @nLin,009 PSAY TRB->CODDES
     @nLin,IIF(lTamProd,026,042) PSAY TRB->DESCR
     @nLin,077 PSAY TRANSFORM(TRB->QTDDES, "@E 999,999.99")
     @nLin,093 PSAY TRANSFORM(TRB->VALDES, "@E 9999,999.9999") 
     @nLin,119 PSAY TRANSFORM(TRB->VALTOT, "@E 99,999,999.99")
//     cCODDES := TRB->CODDES
    EndIf 
    nTotGE5_Guia += IIF(TRB->TIPO == '1', TRB->VALTOT, 0)
    nTotGE6_Guia += IIF(TRB->TIPO == '2', TRB->VALTOT, 0)
    nTotGE7_Guia += IIF(TRB->TIPO == '3', TRB->VALTOT, 0)
                  	
    DbSelectArea("TRB")
    DbSkip()
   End //guias do convenios	

   nTotal_Guia := nTotGE5_Guia +  nTotGE6_Guia + nTotGE7_Guia
   If nTipRel == 1  //Sintetico
    @nLin,119 PSAY TRANSFORM(nTotal_Guia, "@E 99,999,999.99")
   Else  //analitico
    If nLin+2 > nMaxLin
     FS_Cabec(Cabec1, Cabec2)
    Endif
    nLin += 1 
    
    
    @nLin,004 PSAY "==>"
    @nLin,009 PSAY STR0010 //"Mat/Med:"
    @nLin,018 PSAY TRANSFORM(nTotGE5_Guia,  "@E 99,999,999.99")
    @nLin,035 PSAY STR0011 //"Taxas/Diarias:"
    @nLin,050 PSAY TRANSFORM(nTotGE6_Guia,  "@E 99,999,999.99")    
    @nLin,070 PSAY STR0012 //"Procedimentos:"
    @nLin,086 PSAY TRANSFORM(nTotGE7_Guia,  "@E 99,999,999.99")    
	   @nLin,104 PSAY STR0013 //"Total:"
    @nLin,119 PSAY TRANSFORM(nTotal_Guia, "@E 99,999,999.99")
    
    nLin += 1
   Endif  

   nTotGE5_Conv += nTotGE5_Guia
   nTotGE6_Convl += nTotGE6_Guia
   nTotGE7_Conv += nTotGE7_Guia
   nQtdGuiCo   += 1
   nTotGE5_Guia := 0
   nTotGE6_Guia := 0
   nTotGE7_Guia := 0

   
  End ///fim eof convenio       


/////imprimir total do convenio
    nLin += 2    
   //@nLin,093 PSAY "==>"
  nTotal_Conv := nTotGE5_Conv +  nTotGE6_Conv + nTotGE7_Conv
  @nLin,094 PSAY STR0010 //"Mat/Med:"
  @nLin,119 PSAY TRANSFORM(nTotGE5_Conv, "@E 99,999,999.99")  
  nLin += 1
  @nLin,094 PSAY STR0011 //"Taxas/Diarias:"
  @nLin,119 PSAY TRANSFORM(nTotGE6_Conv, "@E 99,999,999.99")    
  nLin += 1
  @nLin,094 PSAY STR0012 //"Procedimentos:"
  @nLin,119 PSAY TRANSFORM(nTotGE7_Conv, "@E 99,999,999.99")    
  nLin += 1
  @nLin,094 PSAY STR0013 //"Total:"
  @nLin,119 PSAY TRANSFORM(nTotal_Conv, "@E 99,999,999.99")
  nLin += 1
  @nLin,094 PSAY STR0017 //"Total de guias: "
  @nLin,123 PSAY TRANSFORM(nQtdGuiCo, "@E 999,999")
 //nTotal_Geral:=0    
 
  nTotGE5_Geral += nTotGE5_Conv
  nTotGE6_Geral += nTotGE6_Conv
  nTotGE7_Geral += nTotGE7_Conv  
  nTotal_Geral+=nTotal_Conv  
  nQtdGuias     += nQtdGuiCo  
 nTotGE5_Conv:=0
 nTotGE6_Conv:=0             
 nTotGE7_Conv:=0
 nTotal_Conv:=0
 nQtdGuiCo:=0  
 

  
  
  If nLin+6 > nMaxLin
   FS_Cabec(Cabec1, Cabec2)
  Endif
  nLin += 2
  
 End   //fim query 
 
    nLin += 3 
//////////Total geral  
  nTotal_Geral := nTotGE5_Geral +  nTotGE6_Geral + nTotGE7_Geral
  @nLin,094 PSAY STR0022 //"Total Mat/Med:"   
  @nLin,119 PSAY TRANSFORM(nTotGE5_Geral, "@E 99,999,999.99")  
  nLin += 1
  @nLin,094 PSAY STR0023 //"Total Taxas/Diแrias:"   
  @nLin,119 PSAY TRANSFORM(nTotGE6_Geral, "@E 99,999,999.99")    
  nLin += 1
  @nLin,094 PSAY STR0024 //"Total Procedimentos:"   
  @nLin,119 PSAY TRANSFORM(nTotGE7_Geral, "@E 99,999,999.99")    
  nLin += 1
  @nLin,094 PSAY STR0025 //"Total Geral" 
  @nLin,119 PSAY TRANSFORM(nTotal_Geral, "@E 99,999,999.99")
  nLin += 1
  @nLin,094 PSAY STR0026 //Total Geral de Guias "  
  @nLin,123 PSAY TRANSFORM(nQtdGuias, "@E 999,999")
  

 
 
  
 SET DEVICE TO SCREEN
 If aReturn[5]==1
  DbCommitAll()
  SET PRINTER TO
  OurSpool(wnrel)
 Endif
 MS_FLUSH()

 DbSelectArea("TRB")
 DbCloseArea()
Return()
                                                
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRunReport บ Autor ณ Cibele Peria       บ Data ณ  04/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Validacao das perguntas                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_VPerRDU()
 Local lRet := .T.

// If Empty(mv_par01)
//  HS_MsgInf(STR0014, STR0015, STR0018) //"Por favor, informe o codigo do Convenio"###"Atencao"###"Valida็ใo das Perg."
//  lRet := .F.
// EndIf   

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRunReport บ Autor ณ Cibele Peria       บ Data ณ  04/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Cabecalho                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_Cabec(Cabec1, Cabec2, lQuebra)
 Default lQuebra := .F.

 Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
 nLin := IIF(nTipRel == 1, 7, 8)
 If lQuebra
  nLin += 1
  @nLin,000 PSAY STR0016 + TRB->CODCON + "-" + GA9->GA9_NREDUZ //"Convenio: "
  nLin += 1
 Endif
Return()                                                                                               
