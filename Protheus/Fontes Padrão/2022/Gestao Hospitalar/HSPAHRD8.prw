#INCLUDE "HSPAHRD8.ch"
#Include "protheus.ch"
#include "TopConn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHRD8  บ Autor ณ Daniel Peixoto     บ Data ณ  06/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio Glosas por guia                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑบAltera็๕esณ L.Gustavo Caloi 28/03/06 -> Padroniza็ใo da HS_MsgInf()    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HSPAHRD8()


/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 ณ Declaracao de Variaveis                                             ณ
 ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3         := ""
Local cPict          := ""
Local titulo         := STR0003 //"Glosas por Guia - Convenio: "
Local nLin           := 80
                                //"          1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16       17
                                //"0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.12346789.123456789.12345
Local Cabec1         := STR0004	//"Paciente                                                                                                     Nao Enviado      Enviado   Recuperado    Rejeitado  N/Informado       Saldo"
Local Cabec2         := STR0005	//"Data         Hora                                               Matricula                  Guia"

Local imprime        := .T.
Local aOrd 				   := {}    

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 80
Private tamanho      := "G"
Private nomeprog     := "HSPAHRD8" /* Coloque aqui o nome do programa para impressao no cabecalho */
Private nTipo        := 18
Private aReturn      := { STR0006, 1, STR0007, 2, 2, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "HSPAHRD8" /* Coloque aqui o nome do arquivo usado para impressao em disco */
Private cPerg        := "HSPRD8"
Private lErrPerg 	   := .T.  
Private lRetPerg     := .T.
Private cString  := ""

Private cCODIMP := ""
Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao

/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 ณ PARAMETROS                                                         ณ
 ณ MV_PAR01	Convenio                                                ณ
 ณ MV_PAR02	Da Data                                                 ณ
 ณ MV_PAR03	Ate Data                                                ณ
 ณ MV_PAR04	Do Titulo                                               ณ
 ณ MV_PAR05	Ate Titulo                                              ณ
 ณ MV_PAR06	Impressora ?                                              ณ
  ณ MV_PAR07	Tipo Glosa                                              ณ
  ณ MV_PAR08	Do Motivo Glosa                                         ณ
  ณ MV_PAR09	Ate Motivo Glosa                                        ณ
  ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

If !Pergunte(cPerg,.T.)
	return
EndIf

nMaxLin := HS_MaxLin(cCODIMP)
nLin := nMaxLin * 2

Private cCodCon     := mv_par01
Private dDatFat_De  := mv_par02
Private dDatFat_Ate := mv_par03                            
Private cCodTit_De  := mv_par04
Private cCodTit_Ate := mv_par05
Private cNomCon     := ""          
Private cTipoGlosa  := IIf(mv_par06 = 2, "'1','2'", "'1'")
Private cMotGlo_De  := mv_par07
Private cMotGlo_Ate := mv_par08

titulo += MV_PAR01 + "  " + POSICIONE("GA9",1,xFilial("GA9")+MV_PAR01,"GA9_NREDUZ")

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
ฑฑบFuno    ณRUNREPORT บ Autor ณ Daniel Peixoto     บ Data ณ  06/05/05   บฑฑ
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
Private cNrFat   := ""
Private cNrSeqG  := ""
Private cTitDesp := ""
Private nNEnvi   := 0, nEnvi:= 0, nRecu:= 0, nPerd := 0, nNinf:= 0 , nSaldo:= 0, nGloFec := 0, nTotGlo := 0  //total da guia
Private nTotNEnvi:= 0, nTotEnvi := 0, nTotRecu := 0, nTotPerd := 0, nTotNinf:= 0, nTotSaldo:= 0, nTotGloF := 0, nTTotGlo := 0   //total do titulo
Private nTGerGlo := 0, nTGerGloF := 0, nTGerNEnv := 0, nTGerEnv := 0,nTGerRec := 0, nTGerRej := 0, nTGerNI := 0, nTGerSal := 0   // Totais Gerais

 cSQL := "SELECT GCZ.GCZ_NRFATU QRY_NRFATU, GCZ.GCZ_NRSEQG QRY_NRSEQG, GCZ.GCZ_REGGER QRY_REGGER, GBH.GBH_NOME QRY_NOME,"
 cSQL += " GCY.GCY_DATATE QRY_DATATE, GCY.GCY_HORATE QRY_HORATE, GD4.GD4_MATRIC QRY_MATRIC, GCZ.GCZ_NRGUIA QRY_NRGUIA,"
 cSQL += " GF5.GF5_CODDES QRY_CODDES, SB1.B1_DESC QRY_DESC, GF5.GF5_VALGLO QRY_VALGLO, GF5.GF5_VALREC QRY_VALREC," 
 cSQL += " GF5.GF5_VALPER QRY_VALPER, GF5.GF5_STATUS QRY_STATUS, GF5.GF5_NRRECO QRY_NRRECO, GDM.GDM_TIPO QRY_TPGLO, GCZ.GCZ_NRLOTE QRY_NRLOTE, 'MAT' QRY_TIPO "
 cSQL += " FROM " + RetSQLName("GCZ") + " GCZ" 
 cSQL += " JOIN " + RetSQLName("GBH") + " GBH ON GBH.GBH_CODPAC = GCZ.GCZ_REGGER"
 cSQL += " JOIN " + RetSQLName("GCY") + " GCY ON GCY.GCY_REGATE = GCZ.GCZ_REGATE"
 cSQL += " JOIN " + RetSQLName("GD4") + " GD4 ON GD4.GD4_REGGER = GCZ.GCZ_REGGER AND GD4.GD4_CODPLA = GCZ.GCZ_CODPLA"
 cSQL += " JOIN " + RetSQLName("GF5") + " GF5 ON GF5.GF5_NRSEQG = GCZ.GCZ_NRSEQG"
 cSQL += " JOIN " + RetSQLName("SE1") + " SE1 ON SE1.E1_NUM = GCZ.GCZ_NRFATU AND SE1.E1_PREFIXO = GCZ.GCZ_SERIE" 
 cSQL += " JOIN " + RetSQLName("GA9") + " GA9 ON GA9.GA9_CODCON = GCZ.GCZ_CODCON AND GA9.GA9_CODCLI = SE1.E1_CLIENTE"
 cSQL += " JOIN " + RetSQLName("SB1") + " SB1 ON SB1.B1_COD = GF5.GF5_CODDES"
 cSQL += " JOIN " + RetSQLName("GDM") + " GDM ON GDM.GDM_CODIGO = GF5.GF5_CDMGLO"
 cSQL += " WHERE"
 cSQL += " GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
 cSQL += " AND GBH.GBH_FILIAL = '" + xFilial("GBH") + "' AND GBH.D_E_L_E_T_ <> '*' "
 cSQL += " AND GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "
 cSQL += " AND GD4.GD4_FILIAL = '" + xFilial("GD4") + "' AND GD4.D_E_L_E_T_ <> '*'"
 cSQL += " AND GF5.GF5_FILIAL = '" + xFilial("GF5") + "' AND GF5.D_E_L_E_T_ <> '*' "
 cSQL += " AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.D_E_L_E_T_ <> '*' "
 cSQL += " AND SE1.E1_FILIAL = '" + xFilial("SE1") + "' AND SE1.D_E_L_E_T_ <> '*' "
 cSQL += " AND GDM.GDM_FILIAL = '" + xFilial("GDM") + "' AND GDM.D_E_L_E_T_ <> '*' "
 cSQL += " AND GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*' "
 cSQL += " AND GF5.GF5_STATUS IN ('2','3') "
 cSQL += " AND GDM.GDM_TIPO = '1' "
 cSQL += " AND GCZ.GCZ_CODCON = '" + cCodCon + "' "
 cSQL += " AND SE1.E1_EMISSAO BETWEEN '" + DTOS(dDatFat_De) + "' AND '" + DTOS(dDatFat_Ate) + "' "
 cSQL += " AND SE1.E1_TIPO IN('NF ','DP ') "
 cSQL += " AND SE1.E1_PARCELA <= '1' "
 cSQL += " AND GCZ.GCZ_NRFATU BETWEEN '" + cCoDTit_De + "' AND '" + cCodTit_Ate + "' " 
 cSQL += " AND GDM.GDM_CODIGO BETWEEN '" + cMotGlo_De + "' AND '" + cMotGlo_Ate + "' "
 cSQL += " AND GDM.GDM_TIPO IN (" + cTipoGlosa + ") "
 
 cSQL += " UNION ALL"  
 cSQL += " SELECT GCZ.GCZ_NRFATU QRY_NRFATU, GCZ.GCZ_NRSEQG QRY_NRSEQG, GCZ.GCZ_REGGER QRY_REGGER, GBH.GBH_NOME QRY_NOME, "
 cSQL += " GCY.GCY_DATATE QRY_DATATE, GCY.GCY_HORATE QRY_HORATE, GD4.GD4_MATRIC QRY_MATRIC, GCZ.GCZ_NRGUIA QRY_NRGUIA, "
 cSQL += " GF6.GF6_CODDES QRY_CODDES, GAA.GAA_DESC QRY_DESC, GF6.GF6_VALGLO QRY_VALGLO, GF6.GF6_VALREC QRY_VALREC, "
 cSQL += " GF6.GF6_VALPER QRY_VALPER, GF6.GF6_STATUS QRY_STATUS, GF6.GF6_NRRECO QRY_NRRECO, GDM.GDM_TIPO QRY_TPGLO, GCZ.GCZ_NRLOTE QRY_NRLOTE, 'TAX' QRY_TIPO "
 cSQL += " FROM " + RetSQLName("GCZ") + " GCZ" 
 cSQL += " JOIN " + RetSQLName("GBH") + " GBH ON GBH.GBH_CODPAC = GCZ.GCZ_REGGER"
 cSQL += " JOIN " + RetSQLName("GCY") + " GCY ON GCY.GCY_REGATE = GCZ.GCZ_REGATE"
 cSQL += " JOIN " + RetSQLName("GD4") + " GD4 ON GD4.GD4_REGGER = GCZ.GCZ_REGGER AND GD4.GD4_CODPLA = GCZ.GCZ_CODPLA"
 cSQL += " JOIN " + RetSQLName("GF6") + " GF6 ON GF6.GF6_NRSEQG = GCZ.GCZ_NRSEQG"
 cSQL += " JOIN " + RetSQLName("SE1") + " SE1 ON SE1.E1_NUM = GCZ.GCZ_NRFATU AND SE1.E1_PREFIXO = GCZ.GCZ_SERIE"
 cSQL += " JOIN " + RetSQLName("GAA") + " GAA ON GAA.GAA_CODTXD = GF6.GF6_CODDES"
 cSQL += " JOIN " + RetSQLName("GDM") + " GDM ON GDM.GDM_CODIGO = GF6.GF6_CDMGLO"
 cSQL += " WHERE"
 cSQL += " GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
 cSQL += " AND GBH.GBH_FILIAL = '" + xFilial("GBH") + "' AND GBH.D_E_L_E_T_ <> '*' "
 cSQL += " AND GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "
 cSQL += " AND GD4.GD4_FILIAL = '" + xFilial("GD4") + "' AND GD4.D_E_L_E_T_ <> '*'"
 cSQL += " AND GF6.GF6_FILIAL = '" + xFilial("GF6") + "' AND GF6.D_E_L_E_T_ <> '*' "
 cSQL += " AND GAA.GAA_FILIAL = '" + xFilial("GAA") + "' AND GAA.D_E_L_E_T_ <> '*' "
 cSQL += " AND SE1.E1_FILIAL = '" + xFilial("SE1") + "' AND SE1.D_E_L_E_T_ <> '*' "
 cSQL += " AND GDM.GDM_FILIAL = '" + xFilial("GDM") + "' AND GDM.D_E_L_E_T_ <> '*' "
 cSQL += " AND GF6.GF6_STATUS IN ('2','3') "
 cSQL += " AND GDM.GDM_TIPO = '1' "
 cSQL += " AND GCZ.GCZ_CODCON = '" + cCodCon + "' "
 cSQL += " AND SE1.E1_TIPO IN('NF ','DP ') "
 cSQL += " AND SE1.E1_PARCELA <= '1' "
 cSQL += " AND SE1.E1_EMISSAO BETWEEN '" + DTOS(dDatFat_De) + "' AND '" + DTOS(dDatFat_Ate) + "' "
 cSQL += " AND GCZ.GCZ_NRFATU BETWEEN '" + cCoDTit_De + "' AND '" + cCodTit_Ate + "' " 
 cSQL += " AND GDM.GDM_CODIGO BETWEEN '" + cMotGlo_De + "' AND '" + cMotGlo_Ate + "' "
 cSQL += " AND GDM.GDM_TIPO IN (" + cTipoGlosa + ") "
 
 cSQL += " UNION ALL" 
 cSQL += " SELECT GCZ.GCZ_NRFATU QRY_NRFATU, GCZ.GCZ_NRSEQG QRY_NRSEQG, GCZ.GCZ_REGGER QRY_REGGER, GBH.GBH_NOME QRY_NOME, "
 cSQL += " GCY.GCY_DATATE QRY_DATATE, GCY.GCY_HORATE QRY_HORATE, GD4.GD4_MATRIC QRY_MATRIC, GCZ.GCZ_NRGUIA QRY_NRGUIA, "
 cSQL += " GF7.GF7_CODDES QRY_CODDES, GA7.GA7_DESC QRY_DESC, GF7.GF7_VALGLO QRY_VALGLO, GF7.GF7_VALREC QRY_VALREC, "
 cSQL += " GF7.GF7_VALPER QRY_VALPER, GF7.GF7_STATUS QRY_STATUS, GF7.GF7_NRRECO QRY_NRRECO, GDM.GDM_TIPO QRY_TPGLO, GCZ.GCZ_NRLOTE QRY_NRLOTE, 'PRO' QRY_TIPO "
 cSQL += " FROM " + RetSQLName("GCZ") + " GCZ" 
 cSQL += " JOIN " + RetSQLName("GBH") + " GBH ON GBH.GBH_CODPAC = GCZ.GCZ_REGGER"
 cSQL += " JOIN " + RetSQLName("GCY") + " GCY ON GCY.GCY_REGATE = GCZ.GCZ_REGATE"
 cSQL += " JOIN " + RetSQLName("GD4") + " GD4 ON GD4.GD4_REGGER = GCZ.GCZ_REGGER AND GD4.GD4_CODPLA = GCZ.GCZ_CODPLA"
 cSQL += " JOIN " + RetSQLName("GF7") + " GF7 ON GF7.GF7_NRSEQG = GCZ.GCZ_NRSEQG"
 cSQL += " JOIN " + RetSQLName("SE1") + " SE1 ON SE1.E1_NUM = GCZ.GCZ_NRFATU AND SE1.E1_PREFIXO = GCZ.GCZ_SERIE"
 cSQL += " JOIN " + RetSQLName("GA7") + " GA7 ON GA7.GA7_CODPRO = GF7.GF7_CODDES"
 cSQL += " JOIN " + RetSQLName("GDM") + " GDM ON GDM.GDM_CODIGO = GF7.GF7_CDMGLO"
 cSQL += " WHERE"
 cSQL += " GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
 cSQL += " AND GBH.GBH_FILIAL = '" + xFilial("GBH") + "' AND GBH.D_E_L_E_T_ <> '*' "
 cSQL += " AND GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "
 cSQL += " AND GD4.GD4_FILIAL = '" + xFilial("GD4") + "' AND GD4.D_E_L_E_T_ <> '*' "
 cSQL += " AND GF7.GF7_FILIAL = '" + xFilial("GF7") + "' AND GF7.D_E_L_E_T_ <> '*' "
 cSQL += " AND GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' "
 cSQL += " AND SE1.E1_FILIAL = '" + xFilial("SE1") + "' AND SE1.D_E_L_E_T_ <> '*' "
 cSQL += " AND GDM.GDM_FILIAL = '" + xFilial("GDM") + "' AND GDM.D_E_L_E_T_ <> '*' "
 cSQL += " AND GF7.GF7_STATUS IN ('2','3') "
 cSQL += " AND GDM.GDM_TIPO = '1' "
 cSQL += " AND GCZ.GCZ_CODCON = '" + cCodCon + "' "
 cSQL += " AND SE1.E1_EMISSAO BETWEEN '" + DTOS(dDatFat_De) + "' AND '" + DTOS(dDatFat_Ate) + "' "
 cSQL += " AND SE1.E1_TIPO IN('NF ','DP ') "
 cSQL += " AND SE1.E1_PARCELA <= '1' "
 cSQL += " AND GCZ.GCZ_NRFATU BETWEEN '" + cCoDTit_De + "' AND '" + cCodTit_Ate + "' " 
 cSQL += " AND GDM.GDM_CODIGO BETWEEN '" + cMotGlo_De + "' AND '" + cMotGlo_Ate + "' "
 cSQL += " AND GDM.GDM_TIPO IN (" + cTipoGlosa + ") " 
 cSQL += " ORDER BY QRY_NRFATU, QRY_NRSEQG, QRY_TIPO"
 
 cSQL :=  ChangeQuery(cSQL)

 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")
 DbGoTop()
                                
 If Eof()
  HS_MsgInf(STR0008, STR0036, STR0037)  //"Nenhum dado foi encontado para a selecao efetuada!"###"Aten็ใo"###"Funcao aux. RPTSTATUS"
 Endif

/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
 ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

 SetRegua(100)

/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 ณ Posicionamento do primeiro registro e loop principal. Pode-se criar ณ
 ณ a logica da seguinte maneira: Posiciona-se na filial corrente e pro ณ
 ณ cessa enquanto a filial do registro for a filial corrente. Por exem ณ
 ณ plo, substitua o dbGoTop() e o While !EOF() abaixo pela sintaxe:    ณ
 ณ                                                                     ณ
 ณ dbSeek(xFilial())                                                   ณ
 ณ While !EOF() .And. xFilial() == A1_FILIAL                           ณ
 ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

 While !EOF()

   //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
   //ณ Verifica o cancelamento pelo usuario...                             ณ
   //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	 IncRegua()
   
   If lAbortPrint
      @nLin,00 PSAY STR0009 //"*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif
   
   If nLin > nMaxLin
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nLin := 9
   Endif

  If QRY->QRY_NRFATU <> cNrFat /*mudou o titulo*/
		FS_ImpTot(nLin)
		If !Empty(cNrFat)
		  nLin += 2
		  @nLin, 000 PSAY REPLICATE("-",184)
		EndIf  
		nLin++
		cNrFat := QRY->QRY_NRFATU
		@nLin, 000 PSAY STR0011 + cNrFat //"Titulo:"
		cNrSeqG := ""
  EndIf

  If QRY->QRY_NRSEQG <> cNrSeqG /*mudou a guia*/
    FS_ImpTot(nLin)
    nLin += 2
  	@nLin, 000 PSAY QRY->QRY_REGGER
  	@nLin, 008 PSAY QRY->QRY_NOME
  	nLin++
  	@nLin, 000 PSAY DTOC(STOD(QRY->QRY_DATATE))
  	@nLin, 013 PSAY QRY->QRY_HORATE
  	@nLin, 060 PSAY QRY->QRY_MATRIC
  	@nLin, 087 PSAY QRY->QRY_NRGUIA+ "      "+STR0038+QRY->QRY_NRLOTE
  	cNrSeqG := QRY->QRY_NRSEQG
  	nLin += 2
  EndIf

  @nLin, 003 PSAY QRY->QRY_CODDES
  @nLin, 020 PSAY QRY->QRY_DESC
 
  FS_ImpVal(nLin)
  
  nLin += 2
  dbSkip() /* Avanca o ponteiro do registro no arquivo */
EndDo

FS_ImpTot(nLin)  
FS_TotGeral(nLin + 2)

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

Return   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHRD8  บAutor  ณDaniel Peixoto     บ Data ณ  06/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de Calculo e Impressใo dos Valores                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_ImpVal(nLin)
 
 If Empty(QRY_NRRECO)  				/*N FOI GERADO NENHUM RECURSO ANTES*/
  If  QRY->QRY_STATUS == "2" /*DISPONIVEL P RECURSO*/
			nNEnvi:= QRY->QRY_VALGLO
			nTotNEnvi += nNEnvi
 	Else 											/* EM RECURSO*/
 	 nEnvi:= QRY->QRY_VALGLO
 	 nTotEnvi += nEnvi
 	EndIF  
 Else 												/*JA GEROU ALGUM RECURSO ANTES*/
  If  QRY->QRY_STATUS = "2" /*DISPONIVEL P RECURSO NOVAMENTE*/
 	 nEnvi:= QRY->QRY_VALGLO
		 nRecu:= QRY->QRY_VALREC
 	 nPerd:= QRY->QRY_VALPER
 	 nTotEnvi += nEnvi
 	 nTotRecu += nRecu
 	 nTotPerd += nPerd 	    
 	Else 											/*EM RECURSO DE NOVO*/
 	 nEnvi:= QRY->QRY_VALPER
 	 nTotEnvi += nEnvi 	    
 	EndIf  
 EndIf
 If QRY->QRY_TPGLO = '2' //se o tipo de glosa ้ fechada, imprime no valor de glosa de fechada
  nGloFec = QRY->QRY_VALGLO
 EndIf
 nNInf:= nEnvi - (nRecu + nPerd)
 nTotNInf += nNInf
 nSaldo:= nNEnvi + nNInf   
 nTotSaldo += nSaldo
 nTotGlo := nGloFec + (nEnvi + nNEnvi)
 nTotGloF += nGloFec
 nTTotGlo += nTotGlo                         
                          
 @nLin, 095 PSAY TRANSFORM(nTotGlo, "@E 9999,999.99")  /*TOTAL GLOSA*/
 @nLin, 108 PSAY TRANSFORM(nGloFec, "@E 9999,999.99")  /*GLOSA FECHADA*/ 
 @nLin, 123 PSAY TRANSFORM(nNEnvi, "@E 9999,999.99")  /*N ENVIADO*/
 @nLin, 137 PSAY TRANSFORM(nEnvi, "@E 9999,999.99")  /*ENVIADO*/
 @nLin, 151 PSAY TRANSFORM(nREcu, "@E 9999,999.99")  /*RECUPERADO*/
 @nLin, 164 PSAY TRANSFORM(nPerd, "@E 9999,999.99")  /*Rejeitado*/
 @nLin, 180 PSAY TRANSFORM(nNInf, "@E 9999,999.99")  /*N informado*/
 @nLin, 192 PSAY TRANSFORM(nSaldo, "@E 9999,999.99")  /*Saldo*/
 nNEnvi  := 0
 nEnvi   := 0
 nRecu   := 0
 nPerd   := 0
 nNinf   := 0
 nSaldo  := 0             
 nTotGlo := 0
 nGloFec := 0            
 
Return

Static Function FS_ImpTot(nLin)

If !Empty(cNrfat) .and. !Empty(cNrSeqG)
	@nLin, 000 PSAY STR0028 //"Total: ----->"
	@nLin, 095 PSAY TRANSFORM(nTTotGlo, "@E 9999,999.99")  /*TOTAL DO TOTAL GLOSA*/
	nTGerGlo += nTTotGlo //Geral
	@nLin, 108 PSAY TRANSFORM(nTotGloF, "@E 9999,999.99")  /*TOTAL GLOSA FECHADA*/     
	nTGerGloF += nTotGloF
	@nLin, 123 PSAY TRANSFORM(nTotNEnvi, "@E 9999,999.99")  /* TOTAL N ENVIADO*/
	nTGerNEnv += nTotNEnvi
	@nLin, 137 PSAY TRANSFORM(nTotEnvi, "@E 9999,999.99")  /* TOTAL ENVIADO*/
	nTGerEnv += nTotEnvi
	@nLin, 151 PSAY TRANSFORM(nTotRecu, "@E 9999,999.99")  /* TOTAL RECUPERADO*/
	nTGerRec += nTotRecu
	@nLin, 164 PSAY TRANSFORM(nTotPerd, "@E 9999,999.99")  /* TOTAL Rejeitado*/
	nTGerRej += nTotPerd
	@nLin, 180 PSAY TRANSFORM(nTotNInf, "@E 9999,999.99")  /* TOTAL N informado*/
	nTGerNI += nTotNInf
	@nLin, 192 PSAY TRANSFORM(nTotSaldo, "@E 9999,999.99")  /*TOTAL  Saldo*/
	nTGerSal += nTotSaldo
EndIF
  nTotNEnvi := 0
  nTotEnvi := 0
  nTotRecu := 0
  nTotPerd := 0
  nTotNinf:= 0 
  nTotSaldo:= 0
  nTTotGlo  := 0
  nTotGloF  := 0

Return


Static Function FS_TotGeral(nLin)

If !Empty(cNrfat) .and. !Empty(cNrSeqG)
	@nLin, 000 PSAY STR0039 + ": ----->" //"Total Geral" 
	@nLin, 095 PSAY TRANSFORM(nTGerGlo, "@E 9999,999.99")  /*TOTAL DO TOTAL GLOSA*/
	@nLin, 108 PSAY TRANSFORM(nTGerGloF, "@E 9999,999.99")  /*TOTAL GLOSA FECHADA*/
	@nLin, 123 PSAY TRANSFORM(nTGerNEnv, "@E 9999,999.99")  /* TOTAL N ENVIADO*/
	@nLin, 137 PSAY TRANSFORM(nTGerEnv, "@E 9999,999.99")  /* TOTAL ENVIADO*/
	@nLin, 151 PSAY TRANSFORM(nTGerRec, "@E 9999,999.99")  /* TOTAL RECUPERADO*/
	@nLin, 164 PSAY TRANSFORM(nTGerRej, "@E 9999,999.99")  /* TOTAL Rejeitado*/
	@nLin, 180 PSAY TRANSFORM(nTGerNI, "@E 9999,999.99")  /* TOTAL N informado*/
	@nLin, 192 PSAY TRANSFORM(nTGerSal, "@E 9999,999.99")  /*TOTAL  Saldo*/
EndIF
  nTotNEnvi := 0
  nTotEnvi := 0
  nTotRecu := 0
  nTotPerd := 0
  nTotNinf:= 0 
  nTotSaldo:= 0
  nTTotGlo  := 0
  nTotGloF  := 0

Return
