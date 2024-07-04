#INCLUDE "HSPAHRD9.ch"
#Include "protheus.ch"
#include "TopConn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHRD9 บ Autor ณ Cibele Peria       บ Data ณ  06/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio de Titulos a receber (por convenio/guia)         บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ 
ฑฑบAltera็๕esณ L.Gustavo Caloi 28/03/06 -> Padroniza็ใo da HS_MsgInf()    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHRD9()

 Local cDesc1 := STR0001 //"Este programa tem como objetivo imprimir relatorio "
 Local cDesc2 := STR0002 //"de acordo com os parametros informados pelo usuario."
 Local cDesc3 := STR0003 //"Titulos a receber por convenio"
 Local aOrd   := {}
 Private Titulo := cDesc3
 Private Cabec1 := STR0004 //" Titulo        Vencto"
 Private Cabec2 := STR0005 //"  Paciente                                 Dt Atend Guia                 Vl.Fatura   Vl.Pago  Pg.Maior  Gl.Disc.  Gl.Fech.     Saldo"
//                  0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.
 Private lEnd        := .F.
 Private lAbortPrint := .F.
 Private limite      := 132
 Private Tamanho     := "M"
 Private NomeProg    := "HSPAHRD9" // Coloque aqui o nome do programa para impressao no cabecalho
 Private nTipo       := 18
 Private aReturn     := { STR0006, 1, STR0007, 2, 2, 1, "", 1} //"Zebrado"###"Administracao"
 Private nLastKey    := 0
 Private cbtxt       := Space(10)
 Private cbcont      := 00
 Private CONTFL      := 01
 Private m_pag       := 01
 Private wnrel       := NomeProg
 Private nTam        := 132 

 Private cHSPSeri   := IIF(LEN(ALLTRIM(GetMV("MV_HSPSERI"))) == 0, "   ", ALLTRIM(GetMV("MV_HSPSERI")))
 Private cPrefCRH   := IIF(LEN(ALLTRIM(GetMV("MV_PREFCRH"))) == 0, "   ", ALLTRIM(GetMV("MV_PREFCRH")))
 Private cPrfRecu   := IIF(LEN(ALLTRIM(GetMv("MV_PRFRECU"))) == 0, "   ", ALLTRIM(GetMv("MV_PRFRECU")))
 Private cE1Prefixo := cHSPSeri + "/" + cPrefCRH
 Private dE1Ven_D   := ""
 Private dE1Ven_A   := ""
  
 Private cCodCon_De  := "", cCodCon_Ate := ""
 Private dDatVen_De  := "", dDatVen_Ate := ""
 Private cNumTit_De  := "", cNumTit_Ate := ""
 
 Private cCODIMP := ""
 Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ PARAMETROS                                                         ณ
 //ณ MV_PAR01	Do convenio                                               ณ
 //ณ MV_PAR02	Ate o convenio                                            ณ
 //ณ MV_PAR03	Do data de vencimento do titulo                           ณ
 //ณ MV_PAR04	Ate data de vencimento do titulo                          ณ
 //ณ MV_PAR05	Do titulo                                                 ณ
 //ณ MV_PAR06	Ate o titulo                                              ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 Pergunte("HSPRD9",.F.)
 HS_HSPRD9(1)
 HS_HSPRD9(2) 
 If !Pergunte("HSPRD9",.T.)
  return
 EndIf

 nMaxLin := HS_MaxLin(cCODIMP)
 
 cCodCon_De  := mv_par01
 cCodCon_Ate := mv_par02
 dVencto_De  := mv_par03
 dVencto_Ate := mv_par04
 cNumTit_De  := mv_par05
 cNumTit_Ate := mv_par06
 
 wnrel := SetPrint("", NomeProg, "", @Titulo, cDesc1, cDesc2, cDesc3, .T., aOrd, .T., Tamanho, , .T.)
 If nLastKey == 27
  Return()
 Endif

 SetDefault(aReturn, "")
 If nLastKey == 27
  Return()
 Endif

 nTipo := If(aReturn[4]==1,15,18)
 RptStatus({|| RunReport("") }, Titulo)
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ Cibele Peria       บ Data ณ  09/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Rotina de execucao do relatorio                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function RunReport()
 Local   cSql    := ""
 Local   cTab    := ""
 Private nLin := nMaxLin * 2
 Private cCodCon := ""
 Private cTitulo := ""
 Private cSerie  := ""
 Private cNrSeqG := ""
 Private cRegGer := ""
 Private cNome   := ""
 Private dDatAte := ""
 Private cNrGuia := ""
 
 Private nVlFat_Gui := 0, nVlPag_Gui := 0, nVlMai_Gui := 0, nVlGlD_Gui := 0, nVlGlF_Gui := 0
 Private nVlFat_Tit := 0, nVlPag_Tit := 0, nVlMai_Tit := 0, nVlGlD_Tit := 0, nVlGlF_Tit := 0
 Private nVlFat_Con := 0, nVlPag_Con := 0, nVlMai_Con := 0, nVlGlD_Con := 0, nVlGlF_Con := 0
 Private nVlFat_Ger := 0, nVlPag_Ger := 0, nVlMai_Ger := 0, nVlGlD_Ger := 0, nVlGlF_Ger := 0
 
 cSQL := "SELECT "
 cSQL += "GCZ_CODCON, GCZ.GCZ_NRFATU, GCZ.GCZ_SERIE, GCZ.GCZ_NRSEQG, SE1.E1_VENCTO, GCZ.GCZ_NRGUIA, "
 cSQL += "GA9.GA9_NREDUZ, GCZ.GCZ_REGGER, GBH.GBH_NOME, GCZ.GCZ_VLGUIA, GCY.GCY_DATATE, "
 cSQL += "'GF5' AS TAB, GF5.GF5_SEQDES AS SEQDES, GF5.GF5_STATUS AS STATUS, GF5.GF5_NRRECO AS NRRECO, "
 cSQL += "GF5.GF5_VALAPR AS VALAPR, GF5.GF5_VALPAG AS VALPAG, GF5.GF5_VALGLO AS VALGLO, GF5.GF5_VALREC AS VALREC, GF5.GF5_VALPER AS VALPER"
 cSQL += " FROM " + RetSQLName("GCZ") + " GCZ"
 cSQL += " JOIN " + RetSQLName("SE1") + " SE1 ON SE1.E1_NUM = GCZ.GCZ_NRFATU AND SE1.E1_PREFIXO = GCZ.GCZ_SERIE"
 cSQL += " JOIN " + RetSQLName("GCY") + " GCY ON GCY.GCY_REGATE = GCZ.GCZ_REGATE" 
 cSQL += " JOIN " + RetSQLName("GA9") + " GA9 ON GA9.GA9_CODCON = GCZ.GCZ_CODCON"
 cSQL += " JOIN " + RetSQLName("GBH") + " GBH ON GBH.GBH_CODPAC = GCZ.GCZ_REGGER"
 cSQL += " JOIN " + RetSQLName("GF5") + " GF5 ON GF5.GF5_NRSEQG = GCZ.GCZ_NRSEQG"
 cSQL += " WHERE "
 cSQL += "GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' AND " 
 cSQL += "GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*' AND "
 cSQL += "SE1.E1_FILIAL = '" + xFilial("SE1") + "' AND SE1.D_E_L_E_T_ <> '*' AND "
 cSQL += "GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' AND "     
 cSQL += "GBH.GBH_FILIAL = '" + xFilial("GBH") + "' AND GBH.D_E_L_E_T_ <> '*' AND "
 cSQL += "GF5.GF5_FILIAL = '" + xFilial("GF5") + "' AND GF5.D_E_L_E_T_ <> '*' AND "
 cSQL += "GCZ.GCZ_CODCON BETWEEN '" + cCodCon_De + "' AND '" + cCodCon_Ate + "' AND "
 cSQL += "GCZ.GCZ_NRFATU BETWEEN '" + cNumTit_De + "' AND '" + cNumTit_Ate + "' AND "
 cSQL += "SE1.E1_VENCTO BETWEEN '" + DTOS(dVencto_De) + "' AND '" + DTOS(dVencto_Ate) + "' AND "
 cSQL += "GF5.GF5_STATUS IN ('1', '2', '3', '4', '5', '6')"
 cSQL += " UNION " + STRTRAN(cSQL, "GF5", "GF6") + " UNION " + STRTRAN(cSQL, "GF5", "GF7")
 
 cSQL += " ORDER BY 1, 2, 3, 4"
 
 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")
 
 DbGoTop()
 If Eof()
  HS_MsgInf(STR0008, STR0018, STR0019) //"Nenhum dado foi encontrado para a selecao efetuada."###"Aten็ใo"###"Rotina de execucao do relatorio"
  DbCloseArea()
  Return()
 Endif 
  
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 SetRegua(RecCount())
 While !EOF()                                                                                
  IncRegua()
                      
  If (QRY->GCZ_CODCON <> cCodCon .or. QRY->GCZ_NRFATU <> cTitulo .or. QRY->GCZ_SERIE <> cSerie .or. QRY->GCZ_NRSEQG <> cNrSeqG)
   If nVlFat_Gui > 0

    FS_Total()  //Total da guia
    
    If (QRY->GCZ_CODCON <> cCodCon .or. QRY->GCZ_NRFATU <> cTitulo .or. QRY->GCZ_SERIE <> cSerie) .and. nVlFat_Tit > 0
     FS_Total("T") //Total do titulo (fatura)
    Endif
 
    If QRY->GCZ_CODCON <> cCodCon .and. nVlFat_Con > 0
     FS_Total("C")  //Total do convenio
    Endif
   
   Endif 
   cNrSeqG    := QRY->GCZ_NRSEQG   
   cRegGer    := QRY->GCZ_REGGER
   cNome      := QRY->GBH_NOME
   dDatAte    := QRY->GCY_DATATE
   cNrGuia    := QRY->GCZ_NRGUIA
   nVlFat_Gui := QRY->GCZ_VLGUIA   
   FS_Quebra()  //Trata a impressao dos cabecalhos do convenio ou do titulo
  Endif  
   
  If QRY->STATUS <> "6"
   If QRY->STATUS == "1"  //Despesa Associada
    If QRY->VALPAG > 0 .or. QRY->VALGLO > 0
     nVlPag_Gui += QRY->VALPAG
     nVlGlD_Gui += QRY->VALGLO
    Endif 
   ElseIf QRY->STATUS $ "2/3"  //Despesa disponivel para recurso
    If Empty(QRY->NRRECO)
     nVlPag_Gui += QRY->VALPAG
     nVlGlD_Gui += QRY->VALGLO
    Else 
     nVlPag_Gui += QRY->VALPAG + QRY->VALREC
     nVlGlD_Gui += QRY->VALPER
    Endif
   ElseIf QRY->STATUS == "4"  //Despesa Liquidada
    If Empty(QRY->NRRECO)
     nVlPag_Gui += QRY->VALPAG
     nVlGlF_Gui += QRY->VALGLO
    Else 
     nVlPag_Gui += QRY->VALPAG + QRY->VALREC
     nVlGlF_Gui += QRY->VALPER
    Endif
   ElseIf QRY->STATUS == "5"  //Despesa Quitada  
    nVlPag_Gui += QRY->VALAPR
   Endif
   DbSkip()
  
  Else
   If QRY->TAB == "GF5" // Mat/Med
    nVlPag_Gui += QRY->GCZ_VLPAGM
    nVlGlD_Gui += QRY->GCZ_VLGLOM
   ElseIf QRY->TAB == "GF6" //Tax/Dia
    nVlPag_Gui += QRY->GCZ_VLPAGT
    nVlGlD_Gui += QRY->GCZ_VLGLOT
   ElseIf QRY->TAB == "GF7" //Pro/Hon    
    nVlPag_Gui += QRY->GCZ_VLPAGP
    nVlGlD_Gui += QRY->GCZ_VLGLOP
   Endif
   cTab := QRY->TAB
   While !Eof() .and. QRY->GCZ_CODCON == cCodCon .and. QRY->GCZ_NRFATU == cTitulo .and. QRY->GCZ_NRSEQG == cNrSeqG .and. 	QRY->TAB == cTab
    DbSelectArea("QRY")   
    DbSkip()
   End 
  
  Endif 
   
 End 
 FS_Total()

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
 Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo, ,.T.) 
 nLin := 8
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_Total  บ Autor ณ Cibele Peria       บ Data ณ  09/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Impressao das linhas de totalizacao                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_Total(cTotal) //, nVlFat, nVlPag, nVlMai, nVlGlD, nVlGlF)
 
 If Empty(cTotal) .or. Eof()
  If nLin+1 > nMaxLin
   FS_Cabec()
  Endif
  nLin += 1
  @ nLin, 003 PSAY cRegGer + "-"
  @ nLin, 011 PSAY SUBSTR(cNome,1,25)
  @ nLin, 037 PSAY STOD(dDatAte)
  @ nLin, 046 PSAY SUBSTR(cNrGuia,1,15)
  FS_ImpTot(nVlFat_Gui, nVlPag_Gui, nVlMai_Gui, nVlGlD_Gui, nVlGlF_Gui)
  nVlFat_Tit += nVlFat_Gui
  nVlPag_Tit += nVlPag_Gui
  nVlMai_Tit += nVlMai_Gui
  nVlGlD_Tit += nVlGld_Gui
  nVlGlF_Tit += nVlGlF_Gui
 Endif

 If cTotal == "T" .or. Eof()
  If nLin+1 > nMaxLin
   FS_Cabec()
  Endif
  nLin += 1
  @ nLin, 040 PSAY STR0009 //"Total do Titulo"
  FS_ImpTot(nVlFat_Tit, nVlPag_Tit, nVlMai_Tit, nVlGlD_Tit, nVlGlF_Tit)
  nVlFat_Con += nVlFat_Tit
  nVlPag_Con += nVlPag_Tit
  nVlMai_Con += nVlMai_Tit
  nVlGlD_Con += nVlGld_Tit
  nVlGlF_Con += nVlGlF_Tit
 Endif

 If cTotal == "C" .or. Eof()
  If nLin+2 > nMaxLin
   FS_Cabec()
  Endif
  nLin += 2
  @ nLin, 040 PSAY STR0010 //"Total do Convenio"
  FS_ImpTot(nVlFat_Con, nVlPag_Con, nVlMai_Con, nVlGlD_Con, nVlGlF_Con)
  nVlFat_Ger += nVlFat_Con
  nVlPag_Ger += nVlPag_Con
  nVlMai_Ger += nVlMai_Con
  nVlGlD_Ger += nVlGld_Con
  nVlGlF_Ger += nVlGlF_Con
 Endif
 
 If Eof()
  If nLin+2 > nMaxLin
   FS_Cabec()
  Endif
  nLin += 2
  @ nlin, 040 PSAY STR0011 //"Total do Geral"
  FS_ImpTot(nVlFat_Ger, nVlPag_Ger, nVlMai_Ger, nVlGlD_Ger, nVlGlF_Ger)
 Endif
 
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_ImpTot บ Autor ณ Cibele Peria       บ Data ณ  12/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Impressao dos totais                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_ImpTot(nVlFat, nVlPag, nVlMai, nVlGlD, nVlGlF)
 
 @ nLin, 067 PSAY TRANSFORM(nVlFat, "@E 999,999.99")
 @ nLin, 078 PSAY TRANSFORM(nVlPag, "@E 999,999.99")
 @ nLin, 089 PSAY TRANSFORM(nVlMai, "@E 999,999.99")
 @ nLin, 100 PSAY TRANSFORM(nVlGlD, "@E 999,999.99")
 @ nLin, 110 PSAY TRANSFORM(nVlGlF, "@E 999,999.99")
 @ nLin, 122 PSAY TRANSFORM((nVlFat - nVlPag - nVlGlF), "@E 9999,999.99")

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_Quebra บ Autor ณ Cibele Peria       บ Data ณ  29/03/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Rotina de Totais                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_Quebra()

  If QRY->GCZ_CODCON <> cCodCon
   FS_Cabec()
   nLin += 1
   @ nLin, 000 PSAY QRY->GA9_NREDUZ
   cCodCon := QRY->GCZ_CODCON
   cTitulo := ""
  Endif 

  If QRY->GCZ_NRFATU <> cTitulo .or. QRY->GCZ_SERIE <> cSerie
   If nLin+2 > nMaxLin
    FS_Cabec()
   Endif
   nLin += 2
   @nLin, 001 PSAY QRY->GCZ_NRFATU + "/" + QRY->GCZ_SERIE
   @nLin, 015 PSAY STOD(QRY->E1_VENCTO)
   cTitulo := QRY->GCZ_NRFATU
   cSerie  := QRY->GCZ_SERIE
  Endif
   
Return()

Function HS_HSPRD9(nPar)
 If nPar == 1
  dE1Ven_D := mv_par03
 ElseIf nPar == 2
  dE1Ven_A := mv_par04
 Endif   
Return()
