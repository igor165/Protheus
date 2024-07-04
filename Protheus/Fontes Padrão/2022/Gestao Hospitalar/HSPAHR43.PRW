#INCLUDE "HSPAHR43.ch"
#Include "protheus.ch"
#include "TopConn.ch"
#define TRACE  repl("_",80)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHR43  บ Autor ณ Mario Arizono      บ Data ณ  16/09/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio Glosas em Aberto                                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HSPAHR43()


/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 ณ Declaracao de Variaveis                                             ณ
 ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3         := ""
Local cPict          := ""
Local titulo         := STR0003 //"Glosas em Aberto"
Local nLin           := 80    
Local Cabec1         := ""
Local Cabec2         := ""
Local imprime        := .T.
Local aOrd 				   := {}    

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 80
Private tamanho      := "P"
Private nomeprog     := "HSPAHR43" /* Coloque aqui o nome do programa para impressao no cabecalho */
Private nTipo        := 18
Private aReturn      := { STR0004, 1, STR0005, 2, 2, 1, "", 1}  //"Zebrado"###"Administracao"
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "HSPAHR43" /* Coloque aqui o nome do arquivo usado para impressao em disco */
Private cPerg        := "HSPR43"
Private lErrPerg 	   := .T.  
Private lRetPerg     := .T.
Private cString  := ""

Private cCODIMP := ""
Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao

/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 ณ PARAMETROS                                                         ณ
 ณ MV_PAR01	Do Convenio                                               ณ
 ณ MV_PAR02	Ate o Convenio                                            ณ
 ณ MV_PAR03	Do Atendimento                                            ณ
 ณ MV_PAR04	Ate o Atendimento                                         ณ
 ณ MV_PAR05	Da Data do Atendiment                                     ณ   
 ณ MV_PAR06	Ate a Data do Atendimento                                 ณ
 ณ MV_PAR07	Do Paciente                                               ณ
 ณ MV_PAR08	Ate o Paciente                                            ณ 
 ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

If !Pergunte(cPerg,.T.)
	return
EndIf

nMaxLin := HS_MaxLin(cCODIMP)
nLin := nMaxLin * 2

Private cCodCon_Do  := mv_par01  
Private cCodCon_Ate := mv_par02
Private cCodAte_Do  := mv_par03  
Private cCodAte_Ate := mv_par04  
Private dDatAte_Da  := mv_par05
Private dDatAte_Ate := mv_par06                            
Private cCodPac_Do  := mv_par07
Private cCodPac_Ate := mv_par08


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
ฑฑบFuno    ณRUNREPORT บ Autor ณ Mario Arizono      บ Data ณ  16/09/05   บฑฑ
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

Local   cSQL 	   := ""
Private cNrConv  := ""
Private cNrAten  := "" 
Private cTipExt  := ""
Private nTotCon  := 0
Private nTotAte  := 0
Private nTotGer  := 0     
Private nValGlo  := 0

 cSQL := " SELECT GCZ.GCZ_NRFATU QRY_NRFATU, GCZ.GCZ_NRSEQG QRY_NRSEQG, GCZ.GCZ_REGGER QRY_REGGER,"
 cSQL += " GCZ.GCZ_NRGUIA QRY_NRGUIA, GCZ.GCZ_CODCON QRY_CODCON, GBH.GBH_NOME QRY_NOME, GCY.GCY_REGATE QRY_REGATE, "
 cSQL += " GCY.GCY_DATATE QRY_DATATE, GF5.GF5_CODDES QRY_CODDES, GF5.GF5_VALGLO QRY_VALGLO, GF5.GF5_STATUS QRY_STATUS, "  
 cSQL += " GF5.GF5_VALPER QRY_VALPER, GF5.GF5_NRRECO QRY_NRRECO, SB1.B1_DESC QRY_DESC, 'MAT' QRY_TIPO"
 cSQL += " FROM " + RetSQLName("GCZ") + " GCZ" 
 cSQL += " JOIN " + RetSQLName("GBH") + " GBH ON GBH.GBH_CODPAC = GCZ.GCZ_REGGER"
 cSQL += " JOIN " + RetSQLName("GCY") + " GCY ON GCY.GCY_REGATE = GCZ.GCZ_REGATE"
 cSQL += " JOIN " + RetSQLName("GF5") + " GF5 ON GF5.GF5_NRSEQG = GCZ.GCZ_NRSEQG"
 cSQL += " JOIN " + RetSQLName("SB1") + " SB1 ON SB1.B1_COD     = GF5.GF5_CODDES"
 cSQL += " WHERE"
 cSQL += "     GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
 cSQL += " AND GBH.GBH_FILIAL = '" + xFilial("GBH") + "' AND GBH.D_E_L_E_T_ <> '*' "
 cSQL += " AND GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "
 cSQL += " AND GF5.GF5_FILIAL = '" + xFilial("GF5") + "' AND GF5.D_E_L_E_T_ <> '*' "
 cSQL += " AND SB1.B1_FILIAL = '"  + xFilial("SB1") + "' AND SB1.D_E_L_E_T_ <> '*' "
 cSQL += " AND GF5.GF5_STATUS = '2'"
 cSQL += " AND GCZ.GCZ_CODCON BETWEEN '" + cCodCon_Do + "' AND '" +cCodCon_Ate+"'"   
 cSQL += " AND GCY.GCY_REGATE BETWEEN '" + cCodAte_Do + "' AND '" +cCodAte_Ate+"'"  
 cSQL += " AND GCY.GCY_DATATE BETWEEN '" + DTOS(dDatAte_Da) + "' AND '" + DTOS(dDatAte_Ate) + "' "
 cSQL += " AND GCZ.GCZ_REGGER BETWEEN '" + cCodPac_Do + "' AND '" + cCodPac_Ate + "' "  
 
 cSQL += " UNION ALL"   
 cSQL += " SELECT GCZ.GCZ_NRFATU QRY_NRFATU, GCZ.GCZ_NRSEQG QRY_NRSEQG, GCZ.GCZ_REGGER QRY_REGGER,"
 cSQL += " GCZ.GCZ_NRGUIA QRY_NRGUIA, GCZ.GCZ_CODCON QRY_CODCON, GBH.GBH_NOME QRY_NOME, GCY.GCY_REGATE QRY_REGATE,"
 cSQL += " GCY.GCY_DATATE QRY_DATATE, GF6.GF6_CODDES QRY_CODDES, GF6.GF6_VALGLO QRY_VALGLO, GF6.GF6_STATUS QRY_STATUS," 
 cSQL += " GF6.GF6_VALPER QRY_VALPER, GF6.GF6_NRRECO QRY_NRRECO, GAA.GAA_DESC QRY_DESC, 'TAX' QRY_TIPO "
 cSQL += " FROM " + RetSQLName("GCZ") + " GCZ" 
 cSQL += " JOIN " + RetSQLName("GBH") + " GBH ON GBH.GBH_CODPAC = GCZ.GCZ_REGGER"
 cSQL += " JOIN " + RetSQLName("GCY") + " GCY ON GCY.GCY_REGATE = GCZ.GCZ_REGATE"
 cSQL += " JOIN " + RetSQLName("GF6") + " GF6 ON GF6.GF6_NRSEQG = GCZ.GCZ_NRSEQG"
 cSQL += " JOIN " + RetSQLName("GAA") + " GAA ON GAA.GAA_CODTXD = GF6.GF6_CODDES"
 cSQL += " WHERE"
 cSQL += "     GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
 cSQL += " AND GBH.GBH_FILIAL = '" + xFilial("GBH") + "' AND GBH.D_E_L_E_T_ <> '*' "
 cSQL += " AND GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "
 cSQL += " AND GF6.GF6_FILIAL = '" + xFilial("GF6") + "' AND GF6.D_E_L_E_T_ <> '*' "
 cSQL += " AND GAA.GAA_FILIAL = '" + xFilial("GAA") + "' AND GAA.D_E_L_E_T_ <> '*' "
 cSQL += " AND GF6.GF6_STATUS = '2'"
 cSQL += " AND GCZ.GCZ_CODCON BETWEEN '" + cCodCon_Do + "' AND '" +cCodCon_Ate+"'"   
 cSQL += " AND GCY.GCY_REGATE BETWEEN '" + cCodAte_Do + "' AND '" +cCodAte_Ate+"'"  
 cSQL += " AND GCY.GCY_DATATE BETWEEN '" + DTOS(dDatAte_Da) + "' AND '" + DTOS(dDatAte_Ate) + "' "
 cSQL += " AND GCZ.GCZ_REGGER BETWEEN '" + cCodPac_Do + "' AND '" + cCodPac_Ate + "' " 
 
 cSQL += " UNION ALL" 
 cSQL += " SELECT GCZ.GCZ_NRFATU QRY_NRFATU, GCZ.GCZ_NRSEQG QRY_NRSEQG, GCZ.GCZ_REGGER QRY_REGGER,"
 cSQL += " GCZ.GCZ_NRGUIA QRY_NRGUIA, GCZ.GCZ_CODCON QRY_CODCON, GBH.GBH_NOME QRY_NOME, GCY.GCY_REGATE QRY_REGATE, "
 cSQL += " GCY.GCY_DATATE QRY_DATATE, GF7.GF7_CODDES QRY_CODDES, GF7.GF7_VALGLO QRY_VALGLO, GF7.GF7_STATUS QRY_STATUS," 
 cSQL += " GF7.GF7_VALPER QRY_VALPER, GF7.GF7_NRRECO QRY_NRRECO, GA7.GA7_DESC QRY_DESC, 'PRO' QRY_TIPO "
 cSQL += " FROM " + RetSQLName("GCZ") + " GCZ" 
 cSQL += " JOIN " + RetSQLName("GBH") + " GBH ON GBH.GBH_CODPAC = GCZ.GCZ_REGGER"
 cSQL += " JOIN " + RetSQLName("GCY") + " GCY ON GCY.GCY_REGATE = GCZ.GCZ_REGATE"
 cSQL += " JOIN " + RetSQLName("GF7") + " GF7 ON GF7.GF7_NRSEQG = GCZ.GCZ_NRSEQG"
 cSQL += " JOIN " + RetSQLName("GA7") + " GA7 ON GA7.GA7_CODPRO = GF7.GF7_CODDES"
 cSQL += " WHERE"
 cSQL += "     GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
 cSQL += " AND GBH.GBH_FILIAL = '" + xFilial("GBH") + "' AND GBH.D_E_L_E_T_ <> '*' "
 cSQL += " AND GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "
 cSQL += " AND GF7.GF7_FILIAL = '" + xFilial("GF7") + "' AND GF7.D_E_L_E_T_ <> '*' "
 cSQL += " AND GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' "
 cSQL += " AND GF7.GF7_STATUS = '2'"
 cSQL += " AND GCZ.GCZ_CODCON BETWEEN '" + cCodCon_Do + "' AND '" +cCodCon_Ate+"'"   
 cSQL += " AND GCY.GCY_REGATE BETWEEN '" + cCodAte_Do + "' AND '" +cCodAte_Ate+"'"  
 cSQL += " AND GCY.GCY_DATATE BETWEEN '" + DTOS(dDatAte_Da) + "' AND '" + DTOS(dDatAte_Ate) + "' "
 cSQL += " AND GCZ.GCZ_REGGER BETWEEN '" + cCodPac_Do + "' AND '" + cCodPac_Ate + "' " 

 cSQL += " ORDER BY QRY_CODCON, QRY_REGATE, QRY_REGGER, QRY_TIPO"
 
 cSQL :=  ChangeQuery(cSQL)   

 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")                                                   
 DbGoTop()
                                
 If Eof()
  HS_MsgInf(STR0006, STR0016, STR0017) //"Nenhum dado foi encontrado para a selecao efetuada!"###"Aten็ใo"###"Verifique a sele็ใo"
 Endif

/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
 ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

 SetRegua(100)

 While !EOF()

   //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
   //ณ Verifica o cancelamento pelo usuario...                             ณ
   //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	 IncRegua()
   
   If lAbortPrint
      @nLin,00 PSAY STR0007 //"*** CANCELADO PELO OPERADOR ***"
      Exit
   Endif
   
     If nLin > nMaxLin
/*              	  			    1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21
        	 		    0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789 */
      Cabec1 :=STR0008 //"Convenio "
      Cabec2 :=STR0009    //"Atend.  Paciente                                         Data Atend.     "
      Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
      nLin := 9                                                                 
      
   Endif
     
     If EMPTY(cNrConv) 
     @nLin,000 PSAY QRY->QRY_CODCON +" - "+ Posicione("GA9",1,xFilial("GA9")+QRY->QRY_CODCON,"GA9_NREDUZ") 
    EndIf 
   If cNrAten <> QRY->QRY_REGATE
    If !EMPTY(cNrAten) 
      nLin +=2
      @nLin,008 PSAY STR0010 + ALLTRIM(TRANSFORM(nTotAte, "@E 999,999.99"))    //"Total do Atendimento......: "
      nLin ++
      nTotAte:=0 
      If cNrConv == QRY->QRY_CODCON    
       nLin ++
       @nLin,000 PSAY QRY->QRY_REGATE
       @nLin,008 PSAY QRY->QRY_REGGER +" - "+ QRY->QRY_NOME   
       @nLin,058 PSAY DTOC(STOD(QRY->QRY_DATATE))
      Endif 
    Else  
      nLin +=2
      @nLin,000 PSAY QRY->QRY_REGATE
      @nLin,008 PSAY QRY->QRY_REGGER +" - "+ QRY->QRY_NOME   
      @nLin,058 PSAY DTOC(STOD(QRY->QRY_DATATE))
    EndIf    
   EndIf           
   If cNrConv <> QRY->QRY_CODCON
    If !EMPTY(cNrConv) 
     @nLin,008 PSAY STR0011 + ALLTRIM(TRANSFORM(nTotCon, "@E 999,999.99"))    //"Total do Convenio.........: "
     nLin +=2      
     nTotCon:=0  
     @nLin,000 PSAY QRY->QRY_CODCON +" - "+ Posicione("GA9",1,xFilial("GA9")+QRY->QRY_CODCON,"GA9_NREDUZ")   
     nLin +=2
     @nLin,000 PSAY QRY->QRY_REGATE
     @nLin,008 PSAY QRY->QRY_REGGER +" - "+ QRY->QRY_NOME 
     @nLin,058 PSAY DTOC(STOD(QRY->QRY_DATATE))
    EndIf    
   EndIf        
   If QRY->QRY_TIPO ="MAT"    
    If cTipExt<>"MAT"  .OR. cNrAten <> QRY->QRY_REGATE
      nLin +=2
      @nLin, 000 PSAY STR0012     //"MATERIAIS E MEDICAMENTOS"
      nLin +=2
      @nLin, 008 PSAY QRY->QRY_CODDES
      @nLin, 025 PSAY SUBSTR(QRY->QRY_DESC,1,30)
      @nLin, 057 PSAY QRY->QRY_NRSEQG
      If QRY->QRY_NRRECO = "      "
       @nLin, 065 PSAY ALLTRIM(TRANSFORM(QRY->QRY_VALGLO,"@E 999,999.99"))
      Else
       @nLin, 065 PSAY ALLTRIM(TRANSFORM(QRY->QRY_VALPER,"@E 999,999.99"))
      Endif   
    Else  
     nLin ++
     @nLin, 008 PSAY QRY->QRY_CODDES
     @nLin, 025 PSAY SUBSTR(QRY->QRY_DESC,1,30)
     @nLin, 057 PSAY QRY->QRY_NRSEQG  
     If QRY->QRY_NRRECO = "      "
      @nLin, 065 PSAY ALLTRIM(TRANSFORM(QRY->QRY_VALGLO,"@E 999,999.99"))
     Else
      @nLin, 065 PSAY ALLTRIM(TRANSFORM(QRY->QRY_VALPER,"@E 999,999.99"))
     Endif  
    Endif 
   ElseIf QRY->QRY_TIPO ="TAX" 
    If cTipExt<>"TAX" .OR. cNrAten <> QRY->QRY_REGATE
     nLin +=2
     @nLin, 000 PSAY STR0013 //"TAXAS E DIARIAS"
     nLin +=2
     @nLin, 008 PSAY QRY->QRY_CODDES
     @nLin, 025 PSAY SUBSTR(QRY->QRY_DESC,1,30)
     @nLin, 057 PSAY QRY->QRY_NRSEQG
     If QRY->QRY_NRRECO = "      "
      @nLin, 065 PSAY ALLTRIM(TRANSFORM(QRY->QRY_VALGLO,"@E 999,999.99"))
     Else
      @nLin, 065 PSAY ALLTRIM(TRANSFORM(QRY->QRY_VALPER,"@E 999,999.99"))
     Endif   
    Else      
     nLin ++
     @nLin, 008 PSAY QRY->QRY_CODDES
     @nLin, 025 PSAY SUBSTR(QRY->QRY_DESC,1,30)
     @nLin, 057 PSAY QRY->QRY_NRSEQG
     If QRY->QRY_NRRECO = "      "
      @nLin, 065 PSAY ALLTRIM(TRANSFORM(QRY->QRY_VALGLO,"@E 999,999.99"))
     Else
      @nLin, 065 PSAY ALLTRIM(TRANSFORM(QRY->QRY_VALPER,"@E 999,999.99"))
     Endif   
    Endif 
   ElseIf QRY->QRY_TIPO ="PRO"
    If cTipExt<>"PRO" .OR. cNrAten <> QRY->QRY_REGATE
     nLin +=2
     @nLin, 000 PSAY STR0014     //"PROCEDIMENTOS E HONORARIOS"
     nLin +=2
     @nLin, 008 PSAY QRY->QRY_CODDES
     @nLin, 025 PSAY SUBSTR(QRY->QRY_DESC,1,30)
     @nLin, 057 PSAY QRY->QRY_NRSEQG
     If QRY->QRY_NRRECO = "      "
      @nLin, 065 PSAY ALLTRIM(TRANSFORM(QRY->QRY_VALGLO,"@E 999,999.99"))
     Else
      @nLin, 065 PSAY ALLTRIM(TRANSFORM(QRY->QRY_VALPER,"@E 999,999.99"))
     Endif   
    Else 
     nLin ++
     @nLin, 008 PSAY QRY->QRY_CODDES
     @nLin, 025 PSAY SUBSTR(QRY->QRY_DESC,1,30)
     @nLin, 057 PSAY QRY->QRY_NRSEQG
     If QRY->QRY_NRRECO = "      "
      @nLin, 065 PSAY ALLTRIM(TRANSFORM(QRY->QRY_VALGLO,"@E 999,999.99"))
     Else
      @nLin, 065 PSAY ALLTRIM(TRANSFORM(QRY->QRY_VALPER,"@E 999,999.99"))
     Endif  
    Endif 
   Endif                     
   
   cNrAten := QRY->QRY_REGATE
   cNrConv := QRY->QRY_CODCON  
   cTipExt := QRY->QRY_TIPO 
   nTotAte += QRY->QRY_VALGLO
   nTotCon += QRY->QRY_VALGLO
   nValGlo += QRY->QRY_VALGLO   
   dbSkip() /* Avanca o ponteiro do registro no arquivo */  
  
  
  If EOF() 
   nLin +=2
   @nLin,008 PSAY STR0010 + ALLTRIM(TRANSFORM(nTotAte, "@E 999,999.99"))    //"Total do Atendimento......: "
   nLin ++    
   @nLin,008 PSAY STR0011 + ALLTRIM(TRANSFORM(nTotCon, "@E 999,999.99"))    //"Total do Convenio.........: "
   nLin ++
   @nLin,000 PSAY TRACE
   nLin ++
   @nLin,008 PSAY STR0015 + ALLTRIM(TRANSFORM(nValGlo, "@E 999,999.99"))    //"Total Geral..............: "
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