#INCLUDE "HSPAHR40.ch"
#include "TopConn.ch"

#define TRACE  repl("_",132)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHR40 บ Autor ณ Mario Arizono      บ Data ณ 07/02/06    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Previsao de leitos vagos                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHR40()


/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 ณ Declaracao de Variaveis                                             ณ
 ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3         := ""
Local cPict          := ""
Local nLin           := 80    
Local imprime        := .T.
Local aOrd 				      := {}    
/*              	    			                     1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21
                                   0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.1 */
Private Cabec1       := STR0003 //"Leito Nome                            Dt.Entr. Pre.Alta Convenio            Clinica                     Medico "
Private Cabec2       := ""
Private titulo       := STR0004 //"Previsao de leitos vagos"
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 132
Private tamanho      := "M"
Private nomeprog     := "HSPAHR40" /* Coloque aqui o nome do programa para impressao no cabecalho */
Private nTipo        := 18
Private aReturn      := { STR0005, 1, STR0006, 2, 2, 1, "", 1}    //"Zebrado"###"Administracao"
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "HSPAHR40" /* Coloque aqui o nome do arquivo usado para impressao em disco */
Private cPerg        := "HSPR40"
Private lErrPerg 	   := .T.  
Private lRetPerg     := .T.
Private cString  := ""

Private cCODIMP := ""
Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao

/*ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
  ณ PARAMETROS                                                         ณ
  ณ MV_PAR01	Filial                                                    ณ
  ณ MV_PAR02	Da previsao de alta                                       ณ
  ณ MV_PAR03	Ate a previsao de alta                                    ณ
  ณ MV_PAR04	Do Setor ?                                                ณ
  ณ MV_PAR05	Ate o Setor ?                                             ณ
  ณ MV_PAR06	Emite ?                                                   ณ 
  ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู */

If !Pergunte(cPerg,.T.)
	return
EndIf

nMaxLin := HS_MaxLin(cCODIMP)
nLin := nMaxLin * 2

Private cCodFil     := mv_par01  
Private dPreAlt_De  := mv_par02
Private dPreAlt_Ate := mv_par03  
Private cCodSet_De  := mv_par04
Private cCodSet_Ate := mv_par05  
Private nTipRel     := mv_par06

If nTipRel == 1
 Titulo += STR0007 //" - Analitico"
ElseIf nTipRel == 2
 Titulo += STR0008 //" - Sintetico"
Endif  
Titulo  += STR0009 + DTOC(dPreAlt_De) + STR0010 + DTOC(dPreAlt_Ate)   //" - Periodo: "###" a "

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
ฑฑบFuno    ณRUNREPORT บ Autor ณ Mario Arizono      บ Data ณ  07/02/06   บฑฑ
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
 Private nTotCir  := 0, nTotLei := 0
 
 cSQL := "SELECT COUNT(*) NQTDCIR " 
 cSQL += "FROM " + RetSqlName("GMJ") + " GMJ"
 cSQL += " WHERE"
 cSQL += "     GMJ_FILIAL = '" + xFilial("GMJ") + "' AND D_E_L_E_T_ <> '*'"
 cSQL += " AND GMJ_STATUS = '1'" 
 cSQL += " AND GMJ_CODAGE = GMJ_SEQAGE"
 cSQL += " AND GMJ.GMJ_DATAGE BETWEEN '" + DTOS(dPreAlt_De) + "' AND '" + DTOS(dPreAlt_Ate) + "'"
 
 cSQL :=  ChangeQuery(cSQL)   

 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")   
 
 nTotCir := QRY->NQTDCIR
 
 DbCloseArea()  
 
 cSQL := "SELECT COUNT(*) NQTDLEI " 
 cSQL += "FROM " + RetSqlName("GAV") + " GAV"
 cSQL += " WHERE"
 cSQL += "     GAV_FILIAL = '" + xFilial("GAV") + "' AND D_E_L_E_T_ <> '*'"
 cSQL += " AND GAV_STATUS = '0'" 
 cSQL += " AND GAV_TIPO IN ('1','4')"

 cSQL :=  ChangeQuery(cSQL)   

 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")   
 
 nTotLei := QRY->NQTDLEI
 
 DbCloseArea()

 cSQL := " SELECT GCY.GCY_CODLOC QRY_CODLOC, GCS.GCS_NOMLOC QRY_NOMLOC, GCY.GCY_LEIINT QRY_LEIINT, GCY.GCY_DATATE QRY_DATATE,"
 cSQL += " GCY.GCY_NOME QRY_NOME, GCW.GCW_DESCLI QRY_DESCLI, SRA.RA_NOME QRY_MEDICO, GA9.GA9_NREDUZ QRY_NOMCON, "
 cSQL += " GE8.GE8_DATVEN QRY_DATVEN "
 cSQL += " FROM " + RetSQLName("GCY") + " GCY"  
 cSQL += " JOIN " + RetSQLName("GCS") + " GCS ON GCS.GCS_CODLOC = GCY.GCY_CODLOC AND GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*'" 
 cSQL += " JOIN " + RetSQLName("GAV") + " GAV ON GAV.GAV_REGATE = GCY.GCY_REGATE AND GAV.GAV_FILIAL = '" + xFilial("GAV") + "' AND GAV.D_E_L_E_T_ <> '*'" 
 cSQL += " JOIN " + RetSQLName("SRA") + " SRA ON SRA.RA_CODIGO  = GCY.GCY_CODCRM AND SRA.RA_FILIAL  = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*'" 
 cSQL += " JOIN " + RetSQLName("GCW") + " GCW ON GCW.GCW_CODCLI = GCY.GCY_CODCLI AND GCW.GCW_FILIAL  = '"+ xFilial("GCW") + "' AND GCW.D_E_L_E_T_ <> '*'"  
 cSQL += " JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_REGATE = GCY.GCY_REGATE AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*'"
 cSQL += " JOIN " + RetSQLName("GA9") + " GA9 ON GA9.GA9_CODCON = GCZ.GCZ_CODCON AND GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*'"
 cSQL += " JOIN " + RetSQLName("GE8") + " GE8 ON GE8.GE8_NRSEQG = GCZ.GCZ_NRSEQG AND GE8.GE8_FILIAL = '" + xFilial("GE8") + "' AND GE8.D_E_L_E_T_ <> '*'"
 cSQL += " WHERE"
 cSQL += "     GCY.GCY_FILIAL = '" + cCodFil + "' AND GCY.D_E_L_E_T_ <> '*'"
 cSQL += " AND GCY.GCY_ATENDI = '0'"
 cSQL += " AND GE8.GE8_DATVEN BETWEEN '" + DTOS(dPreAlt_De) + "' AND '" + DTOS(dPreAlt_Ate) + "'"
 cSQL += " AND GCY.GCY_CODLOC BETWEEN '" + cCodSet_De + "' AND '" + cCodSet_Ate + "'"   
 cSQL += " AND GAV.GAV_TIPO IN ('1','4')"
 cSQL += " AND GCY.GCY_TPALTA = ' '"
 cSQL += " AND GE8.GE8_SEQDES = ( SELECT MAX(GE81.GE8_SEQDES) "
 cSQL += " FROM " + RetSQLName("GE8") + " GE81"  
 cSQL += " WHERE"
 cSQL += " GE81.GE8_FILIAL = '" + xFilial("GE8") + "' AND GE81.D_E_L_E_T_ <> '*'" 
 cSQL += " AND GE81.GE8_NRSEQG = GE8.GE8_NRSEQG )" 
 cSQL += " ORDER BY QRY_CODLOC"
 
 cSQL :=  ChangeQuery(cSQL)   

 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")                                                   
 DbGoTop()
                                
 If Eof()
  HS_MsgInf(STR0011,STR0018, STR0019) //"Nenhum dado foi encontrado para a selecao efetuada!" //"Aten็ใo"###"Previsใo de leitos vagos"
 Else
  nTipo := If(aReturn[4]==1,15,18)
  If nTipRel == 1
   RptStatus({|| FS_Analit() }, Titulo)
  ElseIf nTipRel == 2
   RptStatus({|| FS_Sintet() }, Titulo)
  Endif
 Endif 
 


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

Return () 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_Analit บ Autor ณ MARIO ARIZONO      บ Data ณ  07/02/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Rotina de execucao do relatorio ANALITICO                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_Analit()
 Local   cCodLoc  := ""
 Local   nLin     := nMaxLin * 2
 Local   nTotAlt  := 0 



 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Processamento da impressao                                          ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

 DbSelectArea("QRY")
 DbGoTop()
 SetRegua(100)
 
 While !EOF()   
 
  IncRegua()
   
  If lAbortPrint
   @nLin,00 PSAY STR0012 //"*** CANCELADO PELO OPERADOR ***"
   Exit
  Endif
   
  If nLin > nMaxLin
   nLin:= FS_Cabec(nLin)
  Endif
    
  If cCodLoc <> QRY->QRY_CODLOC  
   nLin++
   @nLin, 000 PSAY QRY->QRY_CODLOC +" - "+ QRY->QRY_NOMLOC 
   nLin+=2
  Endif
  
  @nLin, 000 PSAY QRY->QRY_LEIINT
  @nLin, 006 PSAY SUBSTR(QRY->QRY_NOME,1,28)  
  @nLin, 038 PSAY DTOC(STOD(QRY->QRY_DATATE))
  @nLin, 047 PSAY DTOC(STOD(QRY->QRY_DATVEN))
  @nLin, 056 PSAY SUBSTR(QRY->QRY_NOMCON,1,18)  
  @nLin, 076 PSAY SUBSTR(QRY->QRY_DESCLI,1,26) 
  @nLin, 104 PSAY SUBSTR(QRY->QRY_MEDICO,1,28)
  cCodLoc := QRY->QRY_CODLOC
  nTotAlt++
  nLin ++ 
     
  DBSKIP()
 EndDo     
 
 If EOF() 
  If nLin > nMaxLin
   nLin:= FS_Cabec(nLin)
  Endif
  nLin++
  @nLin, 000 PSAY TRACE
  nLin++
  @nLin, 007 PSAY STR0013 + TRANSFORM(nTotAlt, "@E 999,999")  //"Tt. de Altas Previstas = "
  nLin++
  @nLin, 007 PSAY STR0014 + TRANSFORM(nTotCir, "@E 999,999")  //"Tt. de Cirurgias       = "
  nLin++
  @nLin, 007 PSAY STR0015 + TRANSFORM(nTotLei, "@E 999,999")  //"Tt. Leitos Vagos       = "
  nLin++
  @nLin, 007 PSAY STR0016 + TRANSFORM((nTotAlt-nTotCir+nTotLei), "@E 999,999")  //"Tt. de Leitos Dispon.  = "
 Endif
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_Sintet บ Autor ณ MARIO ARIZONO      บ Data ณ  07/02/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Rotina de execucao do relatorio SINTETICO                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_Sintet()
 Local   cCodLoc  := ""
 Local   nLin     := nMaxLin * 2
 Local   nTotAlt  := 0
 Local   nTGerAlt := 0

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Processamento da impressao                                          ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

 DbSelectArea("QRY")
 DbGoTop()
 SetRegua(100)
 
 While !EOF()   
 
  IncRegua()
   
  If lAbortPrint
   @nLin,00 PSAY STR0012 //"*** CANCELADO PELO OPERADOR ***"
   Exit
  Endif
   
  If nLin > nMaxLin
   Cabec(Titulo,"" ,"" , NomeProg, Tamanho, nTipo, ,.T.)
   nLin := 6
  Endif
    
  If cCodLoc <> QRY->QRY_CODLOC  
   If Empty(cCodLoc)
    @nLin, 000 PSAY QRY->QRY_CODLOC +" - "+ QRY->QRY_NOMLOC 
    nLin++
   Else   
    nLin++
    @nLin, 000 PSAY STR0017 + TRANSFORM(nTotAlt, "@E 999,999")  //"Total de Altas Previstas = "
    nTotAlt := 0
    nLin+=2
    @nLin, 000 PSAY QRY->QRY_CODLOC +" - "+ QRY->QRY_NOMLOC 
    nLin++  
   Endif 
  Endif
  
  nTotAlt++   
  nTGerAlt++
  cCodLoc := QRY->QRY_CODLOC   
  DBSKIP()
 EndDo     
 
 If EOF() 
  If nLin > nMaxLin
   nLin:= FS_Cabec(nLin)
  Endif   
  nLin++
  @nLin, 000 PSAY STR0017 + TRANSFORM(nTotAlt, "@E 999,999")  //"Total de Altas Previstas = "
  nLin++
  @nLin, 000 PSAY TRACE
  nLin++
  @nLin, 002 PSAY STR0013 + TRANSFORM(nTGerAlt, "@E 999,999")  //"Tt. de Altas Previstas = "
  nLin++
  @nLin, 002 PSAY STR0014 + TRANSFORM(nTotCir, "@E 999,999")  //"Tt. de Cirurgias       = "
  nLin++
  @nLin, 002 PSAY STR0015 + TRANSFORM(nTotLei, "@E 999,999")  //"Tt. Leitos Vagos       = "
  nLin++
  @nLin, 002 PSAY STR0016 + TRANSFORM((nTGerAlt-nTotCir+nTotLei), "@E 999,999") //"Tt. de Leitos Dispon.  = "
 Endif
Return()


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_Cabec  บ Autor ณ Mario Arizono      บ Data ณ  07/02/06   บฑฑ
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
 nLin := 7 
 
Return(nLin)