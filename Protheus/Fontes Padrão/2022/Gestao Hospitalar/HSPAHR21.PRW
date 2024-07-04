#INCLUDE "HSPAHR21.ch"
#Include "protheus.ch"
#include "TopConn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHR21 บ Autor ณ Daniel Peixoto     บ Data ณ  13/03/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio de Pacotes e suas excecoes                      บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHR21()

 Local cDesc1 := STR0001 //"Este programa tem como objetivo imprimir relatorio "
 Local cDesc2 := STR0002 //"de acordo com os parametros informados pelo usuario."
 Local cDesc3 := STR0003 //"Pacotes"
 Local aOrd   := {}
 
 Private Titulo      := cDesc3
 Private Cabec1      := ""
 Private Cabec2      := ""
 Private lEnd        := .F.
 Private lAbortPrint := .F.
 Private limite      := 132
 Private Tamanho     := "M"
 Private NomeProg    := "HSPAHR21" // Coloque aqui o nome do programa para impressao no cabecalho
 Private nTipo       := 18
 Private aReturn     := {STR0004 , 1, STR0005, 2, 2, 1, "", 1}     //"Zebrado"###"Administracao"
 Private nLastKey    := 0
 Private cbtxt       := Space(10)
 Private cbcont      := 00
 Private CONTFL      := 01
 Private m_pag       := 01
 Private wnrel       := NomeProg
 Private nTam        := 132 
 Private cPerg       := "HSPR21"

 Private cDoCodCon  := "", cAteCodCon := ""
 Private cDoCodPct  := "", cAteCodPct := ""
 
 Private cCODIMP := ""
 Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao
 Private lTamProd := IIf((TamSx3("GD5_CODDES")[1])<=15, .T., .F.) 

 If !Pergunte(cPerg,.T.)
  return
 EndIf

 cDoCodCon  := MV_PAR01
 cAteCodCon := MV_PAR02
 cDoCodPct  := MV_PAR03
 cAteCodPct := MV_PAR04

 
 nMaxLin := HS_MaxLin(cCODIMP)

//                    1         2         3         4         5         6         7         8         9        10        11        12        13
//          0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.
 Cabec1 := STR0006 //"Convenio"
 Cabec2 := STR0007 //"  Pacote"
 
  
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
ฑฑบFuno    ณRUNREPORT บ Autor ณ Daniel Peixoto     บ Data ณ  13/03/06   บฑฑ
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
 Local cCodCon   := ""
 Local cCodPct   := ""
 Local cTipo     := ""
 
 Private nLin    := nMaxLin * 2

 
 cSQL := "SELECT '1' QRY_TIPO, GP0.GP0_CODCON QRY_CODCON, GA9.GA9_NOME QRY_DESCON, GP0.GP0_CODPRO QRY_CODPCT, GA7.GA7_DESC QRY_DESEXC, "
 cSQL += " GP1.GP1_PROSEC QRY_CODEXC, GP1.GP1_QTDPRO QRY_QTDADE, GP0.GP0_VALMED QRY_VALMED, GP0.GP0_VALMAT QRY_VALMAT"
 cSQL += " FROM " + RetSQLName("GP0") + " GP0"
 cSQL += " JOIN " + RetSQLName("GA9") + " GA9 ON GA9.GA9_CODCON = GP0.GP0_CODCON AND GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GP1") + " GP1 ON GP1.GP1_CODPRO = GP0.GP0_CODPRO AND GP1.GP1_CODCON = GP0.GP0_CODCON AND GP1.GP1_FILIAL = '" + xFilial("GP1") + "' AND GP1.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GA7") + " GA7 ON GA7.GA7_CODPRO = GP1.GP1_PROSEC AND GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' " 
 cSQL += " WHERE "
 cSQL += " GP0.GP0_FILIAL = '" + xFilial("GP0") + "' AND GP0.D_E_L_E_T_ <> '*' "
 cSQL += " AND GP0.GP0_CODPRO BETWEEN '" + cDoCodPct + "' AND '" + cAteCodPct + "' "
 cSQL += " AND GP0.GP0_CODCON BETWEEN '" + cDoCodCon + "' AND '" + cAteCodCon + "' "

 cSQL += "UNION ALL"
 cSQL += " SELECT '2' QRY_TIPO, GP0.GP0_CODCON QRY_CODCON, GA9.GA9_NOME QRY_DESCON, GP0.GP0_CODPRO QRY_CODPCT, GAQ.GAQ_DESC QRY_DESEXC,"
 cSQL += " GP2.GP2_CODGPP QRY_CODEXC, 0 QRY_QTDADE, GP0.GP0_VALMED QRY_VALMED, GP0.GP0_VALMAT QRY_VALMAT"
 cSQL += " FROM " + RetSQLName("GP0") + " GP0"
 cSQL += " JOIN " + RetSQLName("GA9") + " GA9 ON GA9.GA9_CODCON = GP0.GP0_CODCON AND GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GP2") + " GP2 ON GP2.GP2_CODPRO = GP0.GP0_CODPRO AND GP2.GP2_CODCON = GP0.GP0_CODCON AND GP2.GP2_FILIAL = '" + xFilial("GP2") + "' AND GP2.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GAQ") + " GAQ ON GAQ.GAQ_GRUPRO = GP2.GP2_CODGPP AND GAQ.GAQ_FILIAL = '" + xFilial("GAQ") + "' AND GAQ.D_E_L_E_T_ <> '*' " 
 cSQL += " WHERE "
 cSQL += " GP0.GP0_FILIAL = '" + xFilial("GP0") + "' AND GP0.D_E_L_E_T_ <> '*' "
 cSQL += " AND GP0.GP0_CODPRO BETWEEN '" + cDoCodPct + "' AND '" + cAteCodPct + "' "
 cSQL += " AND GP0.GP0_CODCON BETWEEN '" + cDoCodCon + "' AND '" + cAteCodCon + "' "

 cSQL += "UNION ALL"
 cSQL += " SELECT '3' QRY_TIPO, GP0.GP0_CODCON QRY_CODCON, GA9.GA9_NOME QRY_DESCON, GP0.GP0_CODPRO QRY_CODPCT, GAA.GAA_DESC QRY_DESEXC,"
 cSQL += " GP3.GP3_CODTXD QRY_CODEXC, GP3.GP3_QTDTXD QRY_QTDADE, GP0.GP0_VALMED QRY_VALMED, GP0.GP0_VALMAT QRY_VALMAT"
 cSQL += " FROM " + RetSQLName("GP0") + " GP0"
 cSQL += " JOIN " + RetSQLName("GA9") + " GA9 ON GA9.GA9_CODCON = GP0.GP0_CODCON AND GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GP3") + " GP3 ON GP3.GP3_CODPRO = GP0.GP0_CODPRO AND GP3.GP3_CODCON = GP0.GP0_CODCON AND GP3.GP3_FILIAL = '" + xFilial("GP3") + "' AND GP3.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GAA") + " GAA ON GAA.GAA_CODTXD = GP3.GP3_CODTXD AND GAA.GAA_FILIAL = '" + xFilial("GAA") + "' AND GAA.D_E_L_E_T_ <> '*' " 
 cSQL += " WHERE "
 cSQL += " GP0.GP0_FILIAL = '" + xFilial("GP0") + "' AND GP0.D_E_L_E_T_ <> '*' "
 cSQL += " AND GP0.GP0_CODPRO BETWEEN '" + cDoCodPct + "' AND '" + cAteCodPct + "' "
 cSQL += " AND GP0.GP0_CODCON BETWEEN '" + cDoCodCon + "' AND '" + cAteCodCon + "' "
 
 cSQL += "UNION ALL"
 cSQL += " SELECT '4' QRY_TIPO, GP0.GP0_CODCON QRY_CODCON, GA9.GA9_NOME QRY_DESCON, GP0.GP0_CODPRO QRY_CODPCT, SX5.X5_DESCRI QRY_DESEXC,"
 cSQL += " GP4.GP4_CODCTD QRY_CODEXC, 0 QRY_QTDADE, GP0.GP0_VALMED QRY_VALMED, GP0.GP0_VALMAT QRY_VALMAT"
 cSQL += " FROM " + RetSQLName("GP0") + " GP0"
 cSQL += " JOIN " + RetSQLName("GA9") + " GA9 ON GA9.GA9_CODCON = GP0.GP0_CODCON AND GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GP4") + " GP4 ON GP4.GP4_CODPRO = GP0.GP0_CODPRO AND GP4.GP4_CODCON = GP0.GP0_CODCON AND GP4.GP4_FILIAL = '" + xFilial("GP4") + "' AND GP4.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("SX5")+ " SX5 ON SX5.X5_TABELA = 'CT' AND SX5.X5_CHAVE = GP4.GP4_CODCTD  AND SX5.X5_FILIAL = '" + xFilial("SX5") + "' AND SX5.D_E_L_E_T_ <> '*' " 
 cSQL += " WHERE "
 cSQL += " GP0.GP0_FILIAL = '" + xFilial("GP0") + "' AND GP0.D_E_L_E_T_ <> '*' "
 cSQL += " AND GP0.GP0_CODPRO BETWEEN '" + cDoCodPct + "' AND '" + cAteCodPct + "' "
 cSQL += " AND GP0.GP0_CODCON BETWEEN '" + cDoCodCon + "' AND '" + cAteCodCon + "' "  
 
 cSQL += "UNION ALL"
 cSQL += " SELECT '5' QRY_TIPO, GP0.GP0_CODCON QRY_CODCON, GA9.GA9_NOME QRY_DESCON, GP0.GP0_CODPRO QRY_CODPCT, SB1.B1_DESC QRY_DESEXC,"
 cSQL += " GP5.GP5_CODMED QRY_CODEXC, GP5.GP5_QTDMED QRY_QTDADE, GP0.GP0_VALMED QRY_VALMED, GP0.GP0_VALMAT QRY_VALMAT"
 cSQL += " FROM " + RetSQLName("GP0") + " GP0"
 cSQL += " JOIN " + RetSQLName("GA9") + " GA9 ON GA9.GA9_CODCON = GP0.GP0_CODCON AND GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GP5") + " GP5 ON GP5.GP5_CODPRO = GP0.GP0_CODPRO AND GP5.GP5_CODCON = GP0.GP0_CODCON AND GP5.GP5_FILIAL = '" + xFilial("GP5") + "' AND GP5.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("SB1") + " SB1 ON SB1.B1_COD     = GP5.GP5_CODMED AND SB1.B1_FILIAL  = '" + xFilial("SB1") + "' AND SB1.D_E_L_E_T_ <> '*' "
 cSQL += " WHERE "
 cSQL += " GP0.GP0_FILIAL = '" + xFilial("GP0") + "' AND GP0.D_E_L_E_T_ <> '*' "
 cSQL += " AND GP0.GP0_CODPRO BETWEEN '" + cDoCodPct + "' AND '" + cAteCodPct + "' "
 cSQL += " AND GP0.GP0_CODCON BETWEEN '" + cDoCodCon + "' AND '" + cAteCodCon + "' "  
 
 cSQL += "UNION ALL"
 cSQL += " SELECT '6' QRY_TIPO, GP0.GP0_CODCON QRY_CODCON, GA9.GA9_NOME QRY_DESCON, GP0.GP0_CODPRO QRY_CODPCT, SBM.BM_DESC QRY_DESEXC,"
 cSQL += " GP6.GP6_CODGRP QRY_CODEXC, 0 QRY_QTDADE, GP0.GP0_VALMED QRY_VALMED, GP0.GP0_VALMAT QRY_VALMAT"
 cSQL += " FROM " + RetSQLName("GP0") + " GP0"
 cSQL += " JOIN " + RetSQLName("GA9") + " GA9 ON GA9.GA9_CODCON = GP0.GP0_CODCON AND GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GP6") + " GP6 ON GP6.GP6_CODPRO = GP0.GP0_CODPRO AND GP6.GP6_CODCON = GP0.GP0_CODCON AND GP6.GP6_FILIAL = '" + xFilial("GP6") + "' AND GP6.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("SBM") + " SBM ON SBM.BM_GRUPO   = GP6.GP6_CODGRP AND SBM.BM_FILIAL  = '" + xFilial("SBM") + "' AND SBM.D_E_L_E_T_ <> '*' "
 cSQL += " WHERE "
 cSQL += " GP0.GP0_FILIAL = '" + xFilial("GP0") + "' AND GP0.D_E_L_E_T_ <> '*' "
 cSQL += " AND GP0.GP0_CODPRO BETWEEN '" + cDoCodPct + "' AND '" + cAteCodPct + "' "
 cSQL += " AND GP0.GP0_CODCON BETWEEN '" + cDoCodCon + "' AND '" + cAteCodCon + "' "  
 
 cSQL += "UNION ALL"
 cSQL += " SELECT '7' QRY_TIPO, GP0.GP0_CODCON QRY_CODCON, GA9.GA9_NOME QRY_DESCON, GP0.GP0_CODPRO QRY_CODPCT, SB1.B1_DESC QRY_DESEXC,"
 cSQL += " GP7.GP7_CODMAT QRY_CODEXC, GP7.GP7_QTDMAT QRY_QTDADE, GP0.GP0_VALMED QRY_VALMED, GP0.GP0_VALMAT QRY_VALMAT"
 cSQL += " FROM " + RetSQLName("GP0") + " GP0"
 cSQL += " JOIN " + RetSQLName("GA9") + " GA9 ON GA9.GA9_CODCON = GP0.GP0_CODCON AND GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GP7") + " GP7 ON GP7.GP7_CODPRO = GP0.GP0_CODPRO AND GP7.GP7_CODCON = GP0.GP0_CODCON AND GP7.GP7_FILIAL = '" + xFilial("GP7") + "' AND GP7.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("SB1") + " SB1 ON SB1.B1_COD     = GP7.GP7_CODMAT AND SB1.B1_FILIAL  = '" + xFilial("SB1") + "' AND SB1.D_E_L_E_T_ <> '*' "
 cSQL += " WHERE "
 cSQL += " GP0.GP0_FILIAL = '" + xFilial("GP0") + "' AND GP0.D_E_L_E_T_ <> '*' "
 cSQL += " AND GP0.GP0_CODPRO BETWEEN '" + cDoCodPct + "' AND '" + cAteCodPct + "' "
 cSQL += " AND GP0.GP0_CODCON BETWEEN '" + cDoCodCon + "' AND '" + cAteCodCon + "' "  
 
 cSQL += "UNION ALL"
 cSQL += " SELECT '8' QRY_TIPO, GP0.GP0_CODCON QRY_CODCON, GA9.GA9_NOME QRY_DESCON, GP0.GP0_CODPRO QRY_CODPCT, SBM.BM_DESC QRY_DESEXC,"
 cSQL += " GP8.GP8_CODGRP QRY_CODEXC, 0 QRY_QTDADE, GP0.GP0_VALMED QRY_VALMED, GP0.GP0_VALMAT QRY_VALMAT"
 cSQL += " FROM " + RetSQLName("GP0") + " GP0"
 cSQL += " JOIN " + RetSQLName("GA9") + " GA9 ON GA9.GA9_CODCON = GP0.GP0_CODCON AND GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GP8") + " GP8 ON GP8.GP8_CODPRO = GP0.GP0_CODPRO AND GP8.GP8_CODCON = GP0.GP0_CODCON AND GP8.GP8_FILIAL = '" + xFilial("GP8") + "' AND GP8.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("SBM") + " SBM ON SBM.BM_GRUPO   = GP8.GP8_CODGRP AND SBM.BM_FILIAL  = '" + xFilial("SBM") + "' AND SBM.D_E_L_E_T_ <> '*' "
 cSQL += " WHERE "
 cSQL += " GP0.GP0_FILIAL = '" + xFilial("GP0") + "' AND GP0.D_E_L_E_T_ <> '*' "
 cSQL += " AND GP0.GP0_CODPRO BETWEEN '" + cDoCodPct + "' AND '" + cAteCodPct + "' "
 cSQL += " AND GP0.GP0_CODCON BETWEEN '" + cDoCodCon + "' AND '" + cAteCodCon + "' "  
 cSQL += " ORDER BY QRY_CODCON, QRY_CODPCT, QRY_TIPO"

 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")
 
 DbGoTop()
 If Eof()
  HS_MsgInf(STR0018,STR0019,STR0020) //"Nenhum dado foi encontrado para a selecao efetuada."###"Aten็ใo"###"Eexecu็ใo do relat๓rio"
  DbCloseArea()
  Return()
 Endif 
  
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 SetRegua(200)
 While !EOF()                                                                                
  IncRegua()
                      
  If nLin+2 > nMaxLin
   FS_Cabec()
   nLin ++ 
  Endif

  If cCodCon <> QRY->QRY_CODCON
   If !EMPTY(cCodCon)
    nLin ++ 
   EndIf 
   @nLin, 000 PSAY QRY->QRY_CODCON + " - " + QRY->QRY_DESCON
   cCodCon := QRY->QRY_CODCON
   cCodPct := ""
   nLin++
  EndIf
  
  If cCodPct <> QRY->QRY_CODPCT
   If !EMPTY(cCodPct)
    nLin ++ 
   EndIf 
   @nLin, 002 PSAY QRY->QRY_CODPCT + " - " + HS_IniPadr("GA7", 1, QRY->QRY_CODPCT , "GA7_DESC",, .F.) 
   cCodPct := QRY->QRY_CODPCT
   nLin++
  EndIf

  If cTipo <> QRY->QRY_TIPO
   FS_ImpTipo(QRY->QRY_TIPO)
   cTipo := QRY->QRY_TIPO
  EndIf 

  @nLin, 008 PSAY PADL(ALLTRIM(QRY->QRY_CODEXC), Iif(lTamProd,15,30)) + " - " + SUBSTR(QRY->QRY_DESEXC,1,30)
  If QRY->QRY_TIPO $ "1/3/5/7"
   @nLin, Iif(lTamProd,070,075) PSAY QRY->QRY_QTDADE 
  EndIf 
  nLin += 1
  
  If nLin+1 > nMaxLin
   FS_Cabec()
  Endif
  
  DbSkip()
 End    

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
ฑฑบFuno    ณFS_Cabec  บ Autor ณ Daniel Peixoto     บ Data ณ  13/03/06   บฑฑ
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

Static Function FS_ImpTipo(cTipo)

 nLin++
 If cTipo = "1"
  @nLin, 004 PSAY STR0008 //"Procedimentos "
  @nLin, Iif(lTamProd,070,075) PSAY STR0009 //"Qtde "
 ElseIf cTipo = "2"
  @nLin, 004 PSAY STR0010 //"Grupo Procedimentos"
 ElseIf cTipo = "3"
  @nLin, 004 PSAY STR0011 //"Taxas"
  @nLin, Iif(lTamProd,070,075) PSAY STR0012  //"Qtde"
 ElseIf cTipo = "4"
  @nLin, 004 PSAY STR0013 //"Grupo Taxas"
 ElseIf cTipo = "5"
  @nLin, 004 PSAY STR0014     //"Medicamentos"
  @nLin, Iif(lTamProd,070,075) PSAY STR0012   //"Qtde"
 ElseIf cTipo = "6"
  @nLin, 004 PSAY STR0015   //"Grupo Medicamentos"
 ElseIf cTipo = "7"
  @nLin, 004 PSAY STR0016 //"Materiais"
  @nLin, Iif(lTamProd,070,075) PSAY STR0012  //"Qtde"
 ElseIf cTipo = "8"
  @nLin, 004 PSAY STR0017 //"Grupo Materiais"
 EndIf
 nLin ++
 
Return() 
  
