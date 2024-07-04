#INCLUDE "HSPAHRDA.ch"
#Include "protheus.ch"
#include "TopConn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHRDA  บ Autor ณ Daniel Peixoto     บ Data ณ  12/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio Glosas por Titulo                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑบAltera็๕esณ L.Gustavo Caloi 28/03/06 -> Padroniza็ใo da HS_MsgInf()    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HSPAHRDA()


/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 ณ Declaracao de Variaveis                                             ณ
 ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3         := ""
Local cPict          := ""
Local titulo         := STR0003 //"Glosas por Titulo - Convenio: "
Local nLin           := 80
/*                       					 1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16       17
               					 0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.12 */
Local Cabec1         := STR0004 //"Titulo      Data Vencto                          Nao Enviado       Enviado    Recuperado     Rejeitado   N/Informado         Saldo"
Local Cabec2         := ""
Local imprime        := .T.
Local aOrd 				   := {}    

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 80
Private tamanho      := "M"
Private nomeprog     := "HSPAHRDA" /* Coloque aqui o nome do programa para impressao no cabecalho */
Private nTipo        := 18
Private aReturn      := { STR0005, 1, STR0006, 2, 2, 1, "", 1}   //"Zebrado"###"Administracao"
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "HSPAHRDA" /* Coloque aqui o nome do arquivo usado para impressao em disco */
Private cPerg        := "HSPRDA"
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
 ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

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
ฑฑบFuno    ณRUNREPORT บ Autor ณ Daniel Peixoto     บ Data ณ  12/05/05   บฑฑ
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
Private nNEnv := 0, nEnv:= 0, nRec:= 0, nPer := 0, nNinf:= 0 , nSal:= 0 
Private nTotNEnv := 0, nTotEnv := 0, nTotRec := 0, nTotPer := 0, nTotNinf:= 0, nTotSal:= 0  //total do	 titulo
Private nTotGNEnv := 0, nTotGEnv := 0, nTotGRec := 0, nTotGPer := 0, nTotGNinf:= 0, nTotGSal:= 0  //total do convenio

 cSQL := "SELECT GCZ.GCZ_NRFATU QRY_NRFATU, SE1.E1_VENCTO QRY_VENCTO, GCZ.GCZ_NRSEQG QRY_NRSEQG, GCZ.GCZ_REGGER QRY_REGGER, GBH.GBH_NOME QRY_NOME,"
 cSQL += " GCY.GCY_DATATE QRY_DATATE, GCY.GCY_HORATE QRY_HORATE, GD4.GD4_MATRIC QRY_MATRIC, GCZ.GCZ_NRGUIA QRY_NRGUIA,"
 cSQL += " GF5.GF5_CODDES QRY_CODDES, SB1.B1_DESC QRY_DESC, GF5.GF5_VALGLO QRY_VALGLO, GF5.GF5_VALREC QRY_VALREC," 
 cSQL += " GF5.GF5_VALPER QRY_VALPER, GF5.GF5_STATUS QRY_STATUS, GF5.GF5_NRRECO QRY_NRRECO, 'MAT' QRY_TIPO "
 cSQL += " FROM " + RetSQLName("GF5") + " GF5" 
 cSQL += " JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_NRSEQG = GF5.GF5_NRSEQG AND GCZ.GCZ_CODCON = '" + cCodCon + "' AND GCZ.GCZ_NRFATU BETWEEN '" + cCoDTit_De + "' AND '" + cCodTit_Ate + "' AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GBH") + " GBH ON GBH.GBH_CODPAC = GCZ.GCZ_REGGER AND GBH.GBH_FILIAL = '" + xFilial("GBH") + "' AND GBH.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GCY") + " GCY ON GCY.GCY_REGATE = GCZ.GCZ_REGATE AND GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GD4") + " GD4 ON GD4.GD4_REGGER = GCZ.GCZ_REGGER AND GD4.GD4_CODPLA = GCZ.GCZ_CODPLA AND GD4.GD4_FILIAL = '" + xFilial("GD4") + "' AND GD4.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("SE1") + " SE1 ON SE1.E1_NUM = GCZ.GCZ_NRFATU AND SE1.E1_PREFIXO = GCZ.GCZ_SERIE AND SE1.E1_STATUS = 'A' AND SE1.E1_OCORREN IN ('  ', '01') AND SE1.E1_EMISSAO BETWEEN '" + DTOS(dDatFat_De) + "' AND '" + DTOS(dDatFat_Ate) + "' AND SE1.E1_FILIAL = '" + xFilial("SE1") + "' AND SE1.D_E_L_E_T_ <> '*' " 
 cSQL += " JOIN " + RetSQLName("SB1") + " SB1 ON SB1.B1_COD = GF5.GF5_CODDES AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GDM") + " GDM ON GDM.GDM_CODIGO = GF5.GF5_CDMGLO AND GDM.GDM_TIPO = '1' AND GDM.GDM_FILIAL = '" + xFilial("GDM") + "' AND GDM.D_E_L_E_T_ <> '*' "
 cSQL += " WHERE GF5.GF5_FILIAL = '" + xFilial("GF5") + "' AND GF5.D_E_L_E_T_ <> '*' "
 cSQL += " AND GF5.GF5_STATUS IN ('2','3') "
 
 cSQL += " UNION ALL"  
 cSQL += " SELECT GCZ.GCZ_NRFATU QRY_NRFATU, SE1.E1_VENCTO QRY_VENCTO, GCZ.GCZ_NRSEQG QRY_NRSEQG, GCZ.GCZ_REGGER QRY_REGGER, GBH.GBH_NOME QRY_NOME, "
 cSQL += " GCY.GCY_DATATE QRY_DATATE, GCY.GCY_HORATE QRY_HORATE, GD4.GD4_MATRIC QRY_MATRIC, GCZ.GCZ_NRGUIA QRY_NRGUIA, "
 cSQL += " GF6.GF6_CODDES QRY_CODDES, GAA.GAA_DESC QRY_DESC, GF6.GF6_VALGLO QRY_VALGLO, GF6.GF6_VALREC QRY_VALREC, "
 cSQL += " GF6.GF6_VALPER QRY_VALPER, GF6.GF6_STATUS QRY_STATUS, GF6.GF6_NRRECO QRY_NRRECO, 'TAX' QRY_TIPO "
 cSQL += " FROM " + RetSQLName("GF6") + " GF6" 
 cSQL += " JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_NRSEQG = GF6.GF6_NRSEQG AND GCZ.GCZ_CODCON = '" + cCodCon + "' AND GCZ.GCZ_NRFATU BETWEEN '" + cCoDTit_De + "' AND '" + cCodTit_Ate + "' AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GBH") + " GBH ON GBH.GBH_CODPAC = GCZ.GCZ_REGGER AND GBH.GBH_FILIAL = '" + xFilial("GBH") + "' AND GBH.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GCY") + " GCY ON GCY.GCY_REGATE = GCZ.GCZ_REGATE AND GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GD4") + " GD4 ON GD4.GD4_REGGER = GCZ.GCZ_REGGER AND GD4.GD4_CODPLA = GCZ.GCZ_CODPLA AND GD4.GD4_FILIAL = '" + xFilial("GD4") + "' AND GD4.D_E_L_E_T_ <> '*'"
 cSQL += " JOIN " + RetSQLName("SE1") + " SE1 ON SE1.E1_NUM = GCZ.GCZ_NRFATU AND SE1.E1_PREFIXO = GCZ.GCZ_SERIE AND SE1.E1_STATUS = 'A' AND SE1.E1_OCORREN IN ('  ', '01') AND SE1.E1_EMISSAO BETWEEN '" + DTOS(dDatFat_De) + "' AND '" + DTOS(dDatFat_Ate) + "' AND SE1.E1_FILIAL = '" + xFilial("SE1") + "' AND SE1.D_E_L_E_T_ <> '*'  "
 cSQL += " JOIN " + RetSQLName("GAA") + " GAA ON GAA.GAA_CODTXD = GF6.GF6_CODDES AND GAA.GAA_FILIAL = '" + xFilial("GAA") + "' AND GAA.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GDM") + " GDM ON GDM.GDM_CODIGO = GF6.GF6_CDMGLO  AND GDM.GDM_TIPO = '1' AND GDM.GDM_FILIAL = '" + xFilial("GDM") + "' AND GDM.D_E_L_E_T_ <> '*' "
 cSQL += " WHERE GF6.GF6_FILIAL = '" + xFilial("GF6") + "' AND GF6.D_E_L_E_T_ <> '*' "
 cSQL += " AND GF6.GF6_STATUS IN ('2','3') "
 
 cSQL += " UNION ALL" 
 cSQL += " SELECT GCZ.GCZ_NRFATU QRY_NRFATU, SE1.E1_VENCTO QRY_VENCTO, GCZ.GCZ_NRSEQG QRY_NRSEQG, GCZ.GCZ_REGGER QRY_REGGER, GBH.GBH_NOME QRY_NOME, "
 cSQL += " GCY.GCY_DATATE QRY_DATATE, GCY.GCY_HORATE QRY_HORATE, GD4.GD4_MATRIC QRY_MATRIC, GCZ.GCZ_NRGUIA QRY_NRGUIA, "
 cSQL += " GF7.GF7_CODDES QRY_CODDES, GA7.GA7_DESC QRY_DESC, GF7.GF7_VALGLO QRY_VALGLO, GF7.GF7_VALREC QRY_VALREC, "
 cSQL += " GF7.GF7_VALPER QRY_VALPER, GF7.GF7_STATUS QRY_STATUS, GF7.GF7_NRRECO QRY_NRRECO, 'PRO' QRY_TIPO "
 cSQL += " FROM " + RetSQLName("GF7") + " GF7" 
 cSQL += " JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_NRSEQG = GF7.GF7_NRSEQG AND GCZ.GCZ_CODCON = '" + cCodCon + "' AND GCZ.GCZ_NRFATU BETWEEN '" + cCoDTit_De + "' AND '" + cCodTit_Ate + "' AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GBH") + " GBH ON GBH.GBH_CODPAC = GCZ.GCZ_REGGER AND GBH.GBH_FILIAL = '" + xFilial("GBH") + "' AND GBH.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GCY") + " GCY ON GCY.GCY_REGATE = GCZ.GCZ_REGATE AND GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GD4") + " GD4 ON GD4.GD4_REGGER = GCZ.GCZ_REGGER AND GD4.GD4_CODPLA = GCZ.GCZ_CODPLA AND GD4.GD4_FILIAL = '" + xFilial("GD4") + "' AND GD4.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("SE1") + " SE1 ON SE1.E1_NUM = GCZ.GCZ_NRFATU AND SE1.E1_PREFIXO = GCZ.GCZ_SERIE AND SE1.E1_STATUS = 'A' AND SE1.E1_OCORREN IN ('  ', '01') AND SE1.E1_EMISSAO BETWEEN '" + DTOS(dDatFat_De) + "' AND '" + DTOS(dDatFat_Ate) + "' AND SE1.E1_FILIAL = '" + xFilial("SE1") + "' AND SE1.D_E_L_E_T_ <> '*'  "
 cSQL += " JOIN " + RetSQLName("GA7") + " GA7 ON GA7.GA7_CODPRO = GF7.GF7_CODDES AND GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GDM") + " GDM ON GDM.GDM_CODIGO = GF7.GF7_CDMGLO AND GDM.GDM_TIPO = '1' AND GDM.GDM_FILIAL = '" + xFilial("GDM") + "' AND GDM.D_E_L_E_T_ <> '*' "
 cSQL += " WHERE GF7.GF7_FILIAL = '" + xFilial("GF7") + "' AND GF7.D_E_L_E_T_ <> '*' "
 cSQL += " AND GF7.GF7_STATUS IN ('2','3') "
 cSQL += " ORDER BY QRY_NRFATU, QRY_NRSEQG, QRY_TIPO"

 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")
 DbGoTop()
                                
 If Eof()
  HS_MsgInf(STR0007, STR0032, STR0031) //"Nenhum dado foi encontrado para a selecao efetuada!"###"Aten็ใo"###"Funcao aux. chamada pela RPTSTATUS"
 Endif

/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
 ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

 SetRegua(100)

 While !EOF()

	 IncRegua()
   
   If lAbortPrint
    @nLin,00 PSAY STR0008  //"*** CANCELADO PELO OPERADOR ***"
    Exit
   Endif
   
   If nLin > nMaxLin
    Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
    nLin := 9
   Endif

  If QRY->QRY_NRFATU <> cNrFat /*mudou o titulo*/
 		nLin := FS_ImpTot(nLin) 
 		cNrFat := QRY->QRY_NRFATU
   @nLin,000 PSAY cNrFat
   @nLin,015 PSAY DTOC(STOD(QRY->QRY_VENCTO))
  EndIf
     
  FS_CalcVal(nLin)
    
  dbSkip() /* Avanca o ponteiro do registro no arquivo */
  
  If EOF()
   nLin := FS_ImpTot(nLin)
   nLin ++
   FS_ImpTotGer(nLin)
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

Return   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHRDA  บAutor  ณDaniel Peixoto     บ Data ณ  12/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina de Calculo dos Valores                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_CalcVal(nLin)
 
 If Empty(QRY_NRRECO)  				/*N FOI GERADO NENHUM RECURSO ANTES*/
  If  QRY->QRY_STATUS == '2' /*DISPONIVEL P RECURSO*/
			nNEnv := QRY->QRY_VALGLO
			nTotNEnv += nNEnv			
		Else 											/* EM RECURSO*/
   nEnv := QRY->QRY_VALGLO
   nTotEnv += nEnv
  EndIF  
 Else 												/*JA GEROU ALGUM RECURSO ANTES*/
 	If  QRY->QRY_STATUS = '2' /*DISPONIVEL P RECURSO NOVAMENTE*/
   nEnv := QRY->QRY_VALGLO
 		nRec := QRY->QRY_VALREC
   nPer := QRY->QRY_VALPER
   nTotEnv += nEnv
   nTotRec += nRec
   nTotPer += nPer
  Else 											/*EM RECURSO DE NOVO*/
   nEnv := QRY->QRY_VALPER
   nTotEnv += nEnv
	 EndIf  
 EndIf
 nNInf := nEnv - (nRec + nPer)
 nTotNinf += nNInf
 nSal  := nNEnv + nNInf  
 nTotSal += nSal
 
 nNEnv := 0 
 nEnv  := 0
 nRec  := 0
 nPer  := 0
 nNinf := 0
 nSal  := 0     
 
Return

Static Function FS_ImpTot(nLin)
	 
	If !Empty(cNrfat)
	 @nLin,049 PSAY TRANSFORM(nTotNEnv, "@E 9999,999.99")  /*N ENVIADO*/
		@nLin,063 PSAY TRANSFORM(nTotEnv, "@E 9999,999.99")  /*ENVIADO*/
  @nLin,077 PSAY TRANSFORM(nTotREc, "@E 9999,999.99")  /*RECUPERADO*/
  @nLin,091 PSAY TRANSFORM(nTotPer, "@E 9999,999.99")  /*Rejeitado*/
 	@nLin,105 PSAY TRANSFORM(nTotNInf, "@E 9999,999.99")  /*N informado*/                       
 	@nLin,119 PSAY TRANSFORM(nTotSal, "@E 9999,999.99")  /*Saldo*/
 	nTotGNEnv += nTotNEnv
	 nTotGEnv  += nTotEnv
  nTotGRec  += nTotRec
		nTotGPer  += nTotPer  
 	nTotGNInf += nTotNInf        
 	nTotGSal  += nTotSal
 	nTotNEnv  := 0
		nTotEnv   := 0
 	nTotRec   := 0
	 nTotPer   := 0
 	nTotNInf  := 0   
 	nTotSal   := 0
 	nLin++
	EndIf	
Return(nLin)

Static Function FS_ImpTotGer(nLin)

 @nLin, 000 PSAY STR0009 //"Total: ----->"
 @nLin, 049 PSAY TRANSFORM(nTotGNEnv, "@E 9999,999.99")  /* TOTAL N ENVIADO*/
 @nLin, 063 PSAY TRANSFORM(nTotGEnv, "@E 9999,999.99")  /* TOTAL ENVIADO*/
 @nLin, 077 PSAY TRANSFORM(nTotGRec, "@E 9999,999.99")  /* TOTAL RECUPERADO*/
 @nLin, 091 PSAY TRANSFORM(nTotGPer, "@E 9999,999.99")  /* TOTAL Rejeitado*/
 @nLin, 105 PSAY TRANSFORM(nTotGNInf, "@E 9999,999.99")  /* TOTAL N informado*/
 @nLin, 119 PSAY TRANSFORM(nTotGSal, "@E 9999,999.99")  /*TOTAL  Saldo*/

Return