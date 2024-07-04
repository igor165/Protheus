#INCLUDE "HSPAHRD0.ch"
#Include "protheus.ch"
#include "TopConn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHRD0 บ Autor ณ Cibele Peria       บ Data ณ  01/04/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Movimentacoes Avulsas do extrato medico                    บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑบAltera็๕esณ L.Gustavo Caloi 28/03/06 -> Padroniza็ใo da HS_MsgInf()    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHRD0()

 Local cDesc1 := STR0001 //"Este programa tem como objetivo imprimir relatorio "
 Local cDesc2 := STR0002 //"de acordo com os parametros informados pelo usuario."
 Local cDesc3 := STR0003 //"Extrato medico - Movimentacao Avulsa"
 Local aOrd   := {}
 Private Titulo := cDesc3
 Private Cabec1 := STR0004 //"Profissional"
 Private Cabec2 := STR0005  //"Data       Descricao                                      Credito         Debito"
 Private lEnd        := .F.
 Private lAbortPrint := .F.
 Private limite      := 80
 Private Tamanho     := "P"
 Private NomeProg    := "HSPAHRD0" // Coloque aqui o nome do programa para impressao no cabecalho
 Private nTipo       := 18
 Private aReturn     := { STR0006, 1, STR0007, 2, 2, 1, "", 1} //"Zebrado"###"Administracao"
 Private nLastKey    := 0
 Private cbtxt       := Space(10)
 Private cbcont      := 00
 Private CONTFL      := 01
 Private m_pag       := 01
 Private wnrel       := NomeProg
 Private nTam        := 80
 
 Private cCodPre_De  := "", cCodPre_Ate := ""
 Private cCodCRM_De  := "", cCodCRM_Ate := ""
 Private dDatLan_De  := "", dDatLan_Ate := ""
 Private nCPagar := 0

 Private cCODIMP := ""
 Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ PARAMETROS                                                       ณ
 //ณ MV_PAR01	Do prestador                                            ณ
 //ณ MV_PAR02	Ate o prestador                                         ณ
 //ณ MV_PAR03	Do profissional                                         ณ
 //ณ MV_PAR04	Ate o profissional                                      ณ
 //ณ MV_PAR05	Da data                                                 ณ
 //ณ MV_PAR06	Ate a data                                              ณ
 //ณ MV_PAR07	Contas a Pagar (Gerada/Nao Gerada/Ambas)                ณ 
 //ณ MV_PAR08	Impressora ?                                            ณ 
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 If !Pergunte("HSPRD0", .T.)
  return
 EndIf

 nMaxLin := HS_MaxLin(cCODIMP)

 cCodPre_De  := mv_par01
 cCodPre_Ate := mv_par02
 cCodCRM_De  := mv_par03
 cCodCRM_Ate := mv_par04
 dDatLan_De  := mv_par05
 dDatLan_Ate := mv_par06
 nCPagar     := mv_par07

 wnrel := SetPrint("GDX", NomeProg, "", @Titulo, cDesc1, cDesc2, cDesc3, .T., aOrd, .T., Tamanho, , .T.)
 If nLastKey == 27
  Return()
 Endif
 SetDefault(aReturn, "GDX")
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
ฑฑบFuno    ณRUNREPORT บ Autor ณ Cibele Peria       บ Data ณ  01/04/05   บฑฑ
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
 Local cCodPre := "" 
 Local cCodCRM := ""
 Local nValCre := 0, nValDeb := 0
 Local nCrePre := 0, nDebPre := 0, nLanPre := 0
 Local nCreCRM := 0, nDebCRM := 0, nLanCRM := 0 
 Local nCreTot := 0, nDebTot := 0, nLanTot := 0

 cSQL := "SELECT GDX.GDX_CODPRE, GDX.GDX_CODCRM, GDX.GDX_DATLAN, GDX.GDX_TIPLAN, GDX.GDX_HISLAN, GDX.GDX_VALLAN, GDX.GDX_CODCPG, "
 cSQL += " GAZ.GAZ_FANPRE, SRA.RA_NOME "
 cSQL += " FROM " + RetSQLName("GDX") + " GDX"
 cSQL += " JOIN " + RetSQLName("GAZ") + " GAZ ON GAZ.GAZ_CODPRE = GDX.GDX_CODPRE AND GAZ.GAZ_FILIAL = '" + xFilial("GAZ") + "' AND GAZ.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("SRA") + " SRA ON SRA.RA_CODIGO  = GDX.GDX_CODCRM AND SRA.RA_FILIAL  = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' "
 cSQL += " WHERE GDX.GDX_FILIAL = '" + xFilial("GDX") + "' AND GDX.D_E_L_E_T_ <> '*'"
 cSQL += " AND GDX.GDX_TIPMOV = '1'"
 cSQL += " AND GDX.GDX_CODPRE BETWEEN '" + cCodPre_De + "' AND '" + cCodPre_Ate + "'"
 cSQL += " AND GDX.GDX_CODCRM BETWEEN '" + cCodCRM_De + "' AND '" + cCodCRM_Ate + "'" 
 cSQL += " AND GDX.GDX_DATLAN BETWEEN '" + DTOS(dDatLan_De) + "' AND '" + DTOS(dDatLan_Ate) + "'"
 If nCPagar == 1
  cSQL += " AND GDX.GDX_CODCPG <> '" + Space(Len(GDX->GDX_CODCPG)) + "'"
 ElseIf nCPagar == 2
  cSQL += " AND GDX.GDX_CODCPG = '" + Space(Len(GDX->GDX_CODCPG)) + "'"
 Endif 
 cSQL += " ORDER BY GDX.GDX_CODPRE, GDX.GDX_CODCRM, GDX.GDX_DATLAN, GDX.GDX_TIPLAN"
 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")
 DbGoTop()
                                
 If Eof()
  HS_MsgInf(STR0008, STR0014, STR0015) //"Nenhum lancamento foi encontrado para a selecao efetuada!"###"Aten็ใo"###"Rotina de execu็ใo de relatorio"
  DbCloseArea()
  Return()
 Endif
  
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 SetRegua(1000)
 While !EOF()                                                                                
  IncRegua()
  
  If QRY->GDX_CODPRE <> cCodPre
   nLin := FS_Cabec()   
   nLin += 1
   @nLin, 000 PSAY "Prestador: " + QRY->GAZ_FANPRE
   cCodPre := QRY->GDX_CODPRE
   cCodCrm := ""   
  Endif 
   
  If nLin+2 > nMaxLin
   nLin := FS_Cabec()
  Endif

  If cCodCRM <> QRY->GDX_CODCRM
   nLin += 2 
   @nLin, 000 PSAY QRY->GDX_CODCRM + " - " + QRY->RA_NOME
   cCodCRM := QRY->GDX_CODCRM
   
   While !Eof() .and. QRY->GDX_CODCRM == cCodCRM .And. cCodPre == QRY->GDX_CODPRE
    If QRY->GDX_TIPLAN == "0"
     nValCre := 0
     nValDeb := QRY->GDX_VALLAN
    Else
     nValCre := QRY->GDX_VALLAN
     nValDeb := 0
    Endif
    
    If nLin+1 > nMaxLin
     nLin := FS_Cabec(nLin)
    Endif
    nLin += 1
    @nLin, 000 PSAY DTOC(STOD(QRY->GDX_DATLAN))
    @nLin, 011 PSAY SUBSTR(QRY->GDX_HISLAN, 1,39)
    @nLin, 051 PSAY TRANSFORM(nValCre, "@E 999,999,999.99")
    @nLin, 066 PSAY TRANSFORM(nValDeb, "@E 999,999,999.99")
   
    nCreCRM += nValCre
    nDebCRM += nValDeb
    nLanCRM += 1
   
    DbSelectArea("QRY")
    DbSkip()
   EndDo 

  EndIf 
  
  nLin := FS_Total(STR0004, nCreCRM, nDebCRM, nLanCRM, nLin) //"Profissional"
  nCrePre += nCreCRM
  nDebPre += nDebCRM
  nLanPre += nLanCRM
  nCreCRM := 0
  nDebCRM := 0
  nLanCRM := 0
   
  If QRY->GDX_CODPRE <> cCodPre
   nLin := FS_Total(STR0013, nCrePre, nDebPre, nLanPre, nLin) //"Prestador"
   nCreTot += nCrePre
   nDebTot += nDebPre
   nLanTot += nLanPre
   nCrePre := 0
   nDebPre := 0
   nLanPre := 0
  Endif    

 End

 If nLanTot > 0
  FS_Total(STR0009, nCreTot, nDebTot, nLanTot, nLin) //"Geral"
 Endif 
 
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
 nLin := 8
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
Static Function FS_Total(cDescr, nCredit, nDebito, nLancam, nLin)

 If nLin+2 > nMaxLin
  nLin := FS_Cabec()
 Endif
 nLin += 2

 @nLin, 000 PSAY STR0010 + cDescr //"Total "
 @nLin, 022 PSAY STR0011 + TRANSFORM(nLancam, "@E 99999") + STR0012 //" - "###" lancamento(s)"
 @nLin, 050 PSAY TRANSFORM(nCredit, "@E 9999,999,999.99")
 @nLin, 065 PSAY TRANSFORM(nDebito, "@E 9999,999,999.99")

Return(nLin)
