#INCLUDE "HSPAHRDX.ch"
#INCLUDE "protheus.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHRDX  บ Autor ณ Cibele Ap. L. Periaบ Data ณ  11/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Protocolo de envio de remessa                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑฬออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบAltera็๕esณ L.Gustavo Caloi 28/03/06 -> Padroniza็ใo da HS_MsgInf()    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHRDX(cNrFatu, cPrefixo)
 Local aArea := GetArea()

 Private cDesc1      := STR0001 //"Este programa tem como objetivo imprimir relatorio "
 Private cDesc2      := STR0002 //"de acordo com os parametros informados pelo usuario."
 Private cDesc3      := STR0003 //"Contas nao faturadas no periodo"
 Private titulo      := STR0004 //"Protocolo de envio de remessa"
 Private Cabec1      := STR0005 //"Lote   Descricao complementar                  Processo        MM/AA  Valor Lote"
 //                                0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.
 Private Cabec2      := ""
 Private imprime     := .T.
 Private aOrd        := {}
 Private lEnd        := .F.
 Private lAbortPrint := .F.
 Private Limite      := 80
 Private Tamanho     := "P"
 Private NomeProg    := "HSPAHRDX"
 Private nTipo       := 15
 Private aReturn     := { STR0006, 1, STR0007, 1, 2, 1, "", 1} //"Zebrado"###"Administracao"
 Private nLastKey    := 0
 Private CBtxt       := Space(10)
 Private CBcont      := 00
 Private CONTFL      := 01
 Private m_pag       := 01
 Private wnRel       := "HSPAHRDX"

 wnrel := SetPrint("GAT", NomeProg, "", @titulo, cDesc1, cDesc2, cDesc3, .F., aOrd, .F., Tamanho,, .F.)
 If nLastKey == 27
  Return()
 Endif

 SetDefault(aReturn, "GAT")
 If nLastKey == 27
  Return()
 Endif

 nTipo := If(aReturn[4]==1,15,18)
 RptStatus({|| RunReport(cNrFatu, cPrefixo) },Titulo)

 SET DEVICE TO SCREEN
 If aReturn[5]==1
  DbCommitAll()
  SET PRINTER TO
  OurSpool(wnrel)
 Endif
 MS_FLUSH()

 RestArea(aArea)
 
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRunReport บ Autor ณ Cibele Peria       บ Data ณ  04/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Execucao do relatorio                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function RunReport(cNrFatu, cPrefixo)
 Local      cQry := ""
 Local   nValTot := 0
 Local aParcelas := {}
 Local   nForPar := 0
 Local  dEmissao := ""
 Local cLote     := ""
 Local nGuiasGer := 0, nGuiasLote := 0
 
 Private nLin    := 99
 Private nMax    := 60
 
 Default cNrFatu  := SE1->E1_NUM
 Default cPrefixo := SE1->E1_PREFIXO

 DbSelectArea("SE1")
 DbSetOrder(1)
 If !DbSeek(xFilial("SE1") + cPrefixo + cNrFatu)
  HS_MsgInf(STR0008, STR0018, STR0019) //"Fatura nao encontrada no contas a pagar"###"Aten็ao"###"Execucao do relatorio"
  Return()
 Endif
 dEmissao := SE1->E1_EMISSAO 
 While !Eof() .and. SE1->E1_FILIAL == xFilial("SE1") .and. SE1->E1_NUM == cNrFatu .and. SE1->E1_PREFIXO == cPrefixo
  aAdd(aParcelas, {SE1->E1_PARCELA, SE1->E1_VALOR, SE1->E1_VENCTO,(SE1->E1_IRRF+SE1->E1_ISS), SE1->E1_TIPO})
  DbSkip()
 End 

 cQry := "SELECT GAT.GAT_NUMLOT NUMLOT, GAT.GAT_DESCOM DESCOM, GAT.GAT_NUMPRO NUMPRO, GAT.GAT_MESREF MESREF, "
 cQry += "SUM(GCZ.GCZ_VLGUIA) VALLOT , COUNT(*) QTDGUI"
 cQry += "FROM " + RetSqlName("GCZ") + " GCZ "
 cQry += "JOIN " + RetSqlName("GAT") + " GAT ON GAT.GAT_NUMLOT = GCZ.GCZ_NRLOTE AND GAT.GAT_FILIAL = '" + xFilial("GAT") + "' AND GAT.D_E_L_E_T_ <> '*' "
 cQry += "WHERE GCZ.GCZ_FILFAT = '" + xFilial("GAT") + "' AND GCZ.D_E_L_E_T_ <> '*' "
 cQry += "AND GCZ.GCZ_NRFATU = '" + cNrFatu + "' "
 cQry += "AND GCZ.GCZ_SERIE = '" + cPrefixo + "' "
 cQry += "GROUP BY GAT.GAT_NUMLOT, GAT.GAT_DESCOM, GAT.GAT_NUMPRO, GAT.GAT_MESREF "
 cQry += "ORDER BY GAT.GAT_NUMLOT"
 cQry := ChangeQuery(cQry)
 dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"QRY",.F.,.T.)
 
 FS_Cabec()
 
 nLin += 1
 @nLin, 054 PSAY STR0009 + SPACE(02) + cNrFatu //"Remessa       : "
 nLin += 1
 @nLin, 054 PSAY STR0010 + DTOC(dEmissao)      //"Data da Fatura: "
 
 nLin += 2
 DbSelectArea("SM0")
 @nLin, 000 PSAY AllTrim(SM0->M0_NOMECOM)
 nLin += 1
 @nLin, 000 PSAY AllTrim(SM0->M0_ENDCOB) + " - " + AllTrim(SM0->M0_BAIRCOB) + " - " + AllTrim(SM0->M0_CIDCOB) + " - " + SM0->M0_ESTCOB
 nLin += 1
 @nLin, 000 PSAY STR0011 + Substr(SM0->M0_CEPCOB,1,5) + "-" +	 Substr(SM0->M0_CEPCOB,6,3) //"CEP: "

 nLin += 1

 DbSelectArea("QRY")
 DbGoTop()
 While !Eof()

  If lAbortPrint
   @nLin, 000 PSAY STR0012 //"*** CANCELADO PELO OPERADOR ***"
   Exit
  Endif
  
  If nLin+1 > nMax
   FS_Cabec()
  Endif
  
  If cLote <> QRY->NUMLOT
   If !EMPTY(cLote)
    nLin ++
    @nLin, 000 PSAY STR0022 + TRANSFORM(nGuiasLote, "999,999")  //"Total Guias: "
    nLin ++
    nGuiasLote := 0
   EndIf 
   nGuiasLote += QRY->QTDGUI       
   nGuiasGer  += QRY->QTDGUI       
   cLote := QRY->NUMLOT
  EndIf
  nLin ++
  @nLin, 000 PSAY QRY->NUMLOT
  @nLin, 007 PSAY SUBSTR(QRY->DESCOM, 1, 39)
  @nLin, 047 PSAY QRY->NUMPRO
  @nLin, 063 PSAY QRY->MESREF
  @nLin, 069 PSAY TRANSFORM(QRY->VALLOT, "@E 9999,999.99") 
  nValTot += QRY->VALLOT

  DbSkip()
 End
 
 If nLin+3 > nMax
  FS_Cabec()
 Endif
 nLin ++
 @nLin, 000 PSAY STR0022 + TRANSFORM(nGuiasLote, "999,999")  //"Total Guias: "
 nLin += 3
 @nLin, 045 PSAY STR0013 //"VALOR TOTAL"
 @nLin, 069 PSAY TRANSFORM(nValTot, "@E 9999,999.99") 
 nLin ++
 @nLin, 045 PSAY STR0023 //"TOTAL GUIAS"
 @nLin, 073 PSAY TRANSFORM(nGuiasGer, "@E 999,999") 
 
 nLin += 2
 
 If nLin+len(aParcelas)+2 > nMax
  FS_Cabec()
 Endif 
 
 nLin += 1
 @nLin, 000 PSAY STR0014 + cNrFatu + " / " + cPrefixo //"Titulo: "
 nLin += 1
 
 For nForPar := 1 to len(aParcelas)
  If nLin+1 > nMax
   FS_Cabec()
  Endif
  nLin += 1
  @nLin, 000 PSAY STR0015 + aParcelas[nForPar, 1]                              //"Prc: "
  @nLin, 010 PSAY STR0024 + aParcelas[nForPar, 5]                               //"Tipo: "
  @nLin, 020 PSAY STR0016 + TRANSFORM(aParcelas[nForPar, 2], "@E 999,999.99")  //"Val: "
  @nLin, 036 PSAY STR0017 + DTOC(aParcelas[nForPar, 3])                        //"Vcto: "
  @nLin, 051 PSAY STR0020 + TRANSFORM(aParcelas[nForPar, 4], "@E 9,999.99")    //"Imp:"
  @nLin, 064 PSAY STR0021 + TRANSFORM((aParcelas[nForPar, 2]-aParcelas[nForPar, 4]), "@E 999,999.99") //"Liqdo:"
 Next nForPar  
 
 DbSelectArea("QRY")
 DbCloseArea() 
Return()
                                                
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_Cabec  บ Autor ณ Cibele Peria       บ Data ณ  04/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Cabecalho                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_Cabec()
 Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
 nLin := 7
Return()
