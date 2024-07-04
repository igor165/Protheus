#INCLUDE "HSPAHRA8.ch"
#include "Protheus.ch"       
#INCLUDE "TopConn.ch"
#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHRA8  บ Autor ณ Saude              บ Data ณ  24/03/05   บฑฑ 
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Descritivo Or็amento                                       บฑฑ
ฑฑบAlteracao ณ Reconstrucao do Comando SQL.                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HSPAHRA8(cNumOrc)

Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
Local cDesc3         := STR0003 //"Emissao Descritiva do Orcamento"
Local cPict          := ""
Local titulo         := STR0003 //"Emissao Descritiva do Orcamento"
Local nLin           := 80

Local Cabec1         := ""
Local Cabec2         := ""
Local imprime        := .T.
Local aOrd           := {}

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 132
Private tamanho      := "M"
Private nomeprog     := "HSPAHRA8"
Private nTipo        := 15
Private aReturn      := { STR0004, 1, STR0005, 1, 2, 1, "", 1}   //"Zebrado"###"Administracao"
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "HSPAHRA8"
Private cPerg        := "HSPRA8"

Private cNumOrc_De   := ""
Private cNumOrc_Ate  := ""
Private dDatOrc_De   := ""
Private dDatOrc_Ate  := ""
Private nStatus      := 0
Private nTipOrc			   := 0 
Private cCodCon_De   := ""
Private cCodCon_Ate  := ""
Private cCodPla_De   := ""
Private cCodPla_Ate  := ""

Private lChamado     := !Empty(cNumOrc)

Private cString := ""

Private cCODIMP := ""
Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao

Private lTamProd := IIf((TamSx3("GO5_CODDES")[1])<=15, .T., .F.)
/*
mv_par01 - Do Or็amento
mv_mar02 - Ate Orcamento
mv_par03 - Da Data
mv_par04 - Ate Data
mv_par05 - Status       0=Aberto, 1=Confirmado, 2=Rejeitado
mv_par06 - Tipo         0=Interna็ใo 1=Ambulatorio 2=Pronto Atend.
MV_PAR07	- Do Convenio                                             
MV_PAR08	- Ate COnvenio                                            
MV_PAR09	- Do Plano                                                
MV_PAR10	- Ate Plano                                                
mv_par11 - Impressora ?
*/

 If !lChamado
 	HS_MsgInf(STR0006, STR0042, STR0007)   //"Os Parametros utilizados serใo os mesmos do Relatorio Capa do Or็amento"###"Aten็ใo"###"Aviso"
 	Pergunte(cPerg,.F.)
 	cNumOrc_De  := mv_par01
  cNumOrc_Ate := mv_par02
  dDatOrc_De  := mv_par03
  dDatOrc_Ate := mv_par04
  nStatus     := mv_par05
  nTipOrc		   := mv_par06
  cCodCon_De  := mv_par07
  cCodCon_Ate := mv_par08
  cCodPla_De  := mv_par09
  cCodPla_Ate := mv_par10
 Else
  cNumOrc_De  := cNumOrc
  cNumOrc_Ate := cNumOrc
  dDatOrc_De  := GO0->GO0_DATORC
  dDatOrc_Ate := GO0->GO0_DATORC
  nStatus     := Val(GO0->GO0_STATUS) + 1
  nTipOrc	  	 := Val(GO0->GO0_ATENDI) + 1
  cCodCon_De  := HS_IniPadR("GCM", 2, GO0->GO0_CODPLA, "GCM_CODCON",, .F.) 
  cCodCon_Ate := HS_IniPadR("GCM", 2, GO0->GO0_CODPLA, "GCM_CODCON",, .F.)
  cCodPla_De  := GO0->GO0_CODPLA
  cCodPla_Ate := GO0->GO0_CODPLA
 EndIf

 nMaxLin := HS_MaxLin(cCODIMP)
 nLin := nMaxLin * 2

 wnrel := SetPrint(cString,NomeProg,IIf(lChamado,"","HSPRA8"),@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho) 

 If nLastKey == 27
 	Return
 Endif

 SetDefault(aReturn,cString)

 If nLastKey == 27
 	Return
 Endif

 nTipo := If(aReturn[4]==1,15,18)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Processamento. RPTSTATUS monta janela com a regua de processamento. ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

 RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ AP6 IDE            บ Data ณ  16/03/05   บฑฑ
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

Local cQry           := ""
Local cArqTrab       := ""
Local cCODUNC        := ""
Local cCODGRU        := ""
Local nTotGer        := 0
Local	nGrpDesp       := 0
Local nUniCons       := 0
Local cNumOrc        := "" 

cQry := "SELECT GO0.GO0_NUMORC TRB_NUMORC, GO0.GO0_REGATE TRB_REGATE, GO0.GO0_NOMPAC TRB_NOMPAC, GO0.GO0_CODPLA TRB_CODPLA, "
cQry += "GO0.GO0_REGGER TRB_REGGER, GO0.GO0_DATORC TRB_DATORC, GO0.GO0_HORORC TRB_HORORC, GCM.GCM_CODCON TRB_CODCON, GO5.GO5_CODDES TRB_CODDES, " 
cQry += "GO5.GO5_QTDDES TRB_QTDDES, GO5.GO5_VALDES TRB_VALDES," + HS_FVALDES("GO5")+ " AS TRB_TOT, SB1.B1_DESC TRB_DESC, "
cQry += "GAW.GAW_CODGDE TRB_CODGDE , GAW.GAW_DESC TRB_DESCGR, GCT.GCT_CODUNC TRB_CODUNC, GCT.GCT_DESUNC TRB_DESUNC "
cQry += "FROM " + RetSqlName("GO0") + " GO0 "
cQry += "JOIN " + RetSQLName("GCM") + " GCM ON GCM.GCM_CODPLA = GO0.GO0_CODPLA AND GCM.GCM_FILIAL = '" + xFilial("GCM") + "' AND GCM.D_E_L_E_T_ <> '*' AND GCM.GCM_CODCON BETWEEN '" + cCodCon_De + "' AND '" + cCodCon_Ate + "' "   
cQry += "JOIN " + RetSqlName("GO5") + " GO5 ON GO5.GO5_NUMORC = GO0.GO0_NUMORC AND GO5.GO5_FILIAL = '" + xFilial("GO5") + "' AND GO5.D_E_L_E_T_ <> '*' "  
cQry += "JOIN " + RetSqlName("GBI") + " GBI ON GBI.GBI_PRODUT = GO5.GO5_CODDES AND GBI.GBI_FILIAL = '" + xFilial("GBI") + "' AND GBI.D_E_L_E_T_ <> '*' "  
cQry += "JOIN " + RetSqlName("GAW") + " GAW ON GAW.GAW_CODGDE = GBI.GBI_CODGDE AND GAW.GAW_FILIAL = '" + xFilial("GAW") + "' AND GAW.D_E_L_E_T_ <> '*' " 
cQry += "JOIN " + RetSqlName("SB1") + " SB1 ON  SB1.B1_COD    = GBI.GBI_PRODUT AND  SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.D_E_L_E_T_ <> '*' "
cQry += "JOIN " + RetSqlName("GCS") + " GCS ON GCS.GCS_CODLOC = GO0.GO0_CODLOC AND GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' "
cQry += "JOIN " + RetSqlName("GCT") + " GCT ON GCT.GCT_CODUNC = GCS.GCS_CODUNC AND GCT.GCT_FILIAL = '" + xFilial("GCT") + "' AND GCT.D_E_L_E_T_ <> '*' "   
cQry += "WHERE "
cQry += "GO0.GO0_FILIAL = '" + xFilial("GO0") + "' AND GO0.D_E_L_E_T_ <> '*' "
cQry += "AND GO0.GO0_NUMORC BETWEEN '" + cNumOrc_De + "' AND '" + cNumOrc_Ate + "' "
cQry += "AND GO0.GO0_DATORC BETWEEN '" + DTOS(dDatOrc_De) + "' AND '" + DTOS(dDatOrc_Ate) + "' "
cQry += "AND GO0.GO0_CODPLA BETWEEN '" + cCodPla_De + "' AND '" + cCodPla_Ate + "' " 
If nStatus == 1
 cQry += "AND GO0.GO0_STATUS = '0' "
ElseIf nStatus == 2
 cQry += "AND GO0.GO0_STATUS = '1' "
ElseIf nStatus == 3
	cQry += "AND GO0.GO0_STATUS = '2' "
EndIf  	  
        
If nTipOrc == 1
 cQry += "AND GO0.GO0_ATENDI = '0' "
ElseIf nTipOrc == 2
 cQry += "AND GO0.GO0_ATENDI = '1' "
ElseIf nTipOrc == 3
 cQry += "AND GO0.GO0_ATENDI = '2' "
EndIf	  
  
cQry += "UNION ALL " 
cQry += "SELECT GO0.GO0_NUMORC TRB_NUMORC, GO0.GO0_REGATE TRB_REGATE, GO0.GO0_NOMPAC TRB_NOMPAC, GO0.GO0_CODPLA TRB_CODPLA, "
cQry += "GO0.GO0_REGGER TRB_REGGER, GO0.GO0_DATORC TRB_DATORC, GO0.GO0_HORORC TRB_HORORC,  GCM.GCM_CODCON TRB_CODCON, "
cQry += "GO6.GO6_CODDES TRB_CODDES, GO6.GO6_QTDDES TRB_QTDDES, GO6.GO6_VALDES TRB_VALDES," + HS_FVALDES("GO6")+ " AS TRB_TOT, "
cQry += "GAA.GAA_DESC TRB_DESC, GAW.GAW_CODGDE TRB_CODGDE , GAW.GAW_DESC TRB_DESCGR, GCT.GCT_CODUNC TRB_CODUNC , GCT.GCT_DESUNC TRB_DESUNC "
cQry += "FROM " + RetSqlName("GO0") + " GO0 " 
cQry += "JOIN " + RetSQLName("GCM") + " GCM ON GCM.GCM_CODPLA = GO0.GO0_CODPLA AND GCM.GCM_FILIAL = '" + xFilial("GCM") + "' AND GCM.D_E_L_E_T_ <> '*' AND GCM.GCM_CODCON BETWEEN '" + cCodCon_De + "' AND '" + cCodCon_Ate + "' "   
cQry += "JOIN " + RetSqlName("GO6") + " GO6 ON GO6.GO6_NUMORC = GO0.GO0_NUMORC AND GO6.GO6_FILIAL = '" + xFilial("GO6") + "' AND GO6.D_E_L_E_T_ <> '*' "  
cQry += "JOIN " + RetSqlName("GAA") + " GAA ON GAA.GAA_CODTXD = GO6.GO6_CODDES AND GAA.GAA_FILIAL = '" + xFilial("GAA") + "' AND GAA.D_E_L_E_T_ <> '*' "
cQry += "JOIN " + RetSqlName("GAW") + " GAW ON GAW.GAW_CODGDE = GAA.GAA_CODGDE AND GAW.GAW_FILIAL = '" + xFilial("GAW") + "' AND GAW.D_E_L_E_T_ <> '*' " 
cQry += "JOIN " + RetSqlName("GCS") + " GCS ON GCS.GCS_CODLOC = GO0.GO0_CODLOC AND GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' "
cQry += "JOIN " + RetSqlName("GCT") + " GCT ON GCT.GCT_CODUNC = GCS.GCS_CODUNC AND GCT.GCT_FILIAL = '" + xFilial("GCT") + "' AND GCT.D_E_L_E_T_ <> '*' "    
cQry += "WHERE "
cQry += "    GO0.GO0_FILIAL = '" + xFilial("GO0") + "' AND GO0.D_E_L_E_T_ <> '*' "   
cQry += "AND GO0.GO0_NUMORC BETWEEN '" + cNumOrc_De + "' AND '" + cNumOrc_Ate + "' "
cQry += "AND GO0.GO0_DATORC BETWEEN '" + DTOS(dDatOrc_De) + "' AND '" + DTOS(dDatOrc_Ate) + "' "
cQry += "AND GO0.GO0_CODPLA BETWEEN '" + cCodPla_De + "' AND '" + cCodPla_Ate + "' " 
If nStatus == 1
 cQry += "AND GO0.GO0_STATUS = '0' "
ElseIf nStatus == 2
 cQry += "AND GO0.GO0_STATUS = '1' "
ElseIf nStatus == 3
	cQry += "AND GO0.GO0_STATUS = '2' "
EndIf  	  
        
If nTipOrc == 1
 cQry += "AND GO0.GO0_ATENDI = '0' "
ElseIf nTipOrc == 2
 cQry += "AND GO0.GO0_ATENDI = '1' "
ElseIf nTipOrc == 3
 cQry += "AND GO0.GO0_ATENDI = '2' "
EndIf	  

cQry += "UNION ALL "                     
cQry += "SELECT GO0.GO0_NUMORC TRB_NUMORC, GO0.GO0_REGATE TRB_REGATE, GO0.GO0_NOMPAC TRB_NOMPAC, GO0.GO0_CODPLA TRB_CODPLA, "  
cQry += "GO0.GO0_REGGER TRB_REGGER, GO0.GO0_DATORC TRB_DATORC, GO0.GO0_HORORC TRB_HORORC,  GCM.GCM_CODCON TRB_CODCON, " 
cQry += "GO7.GO7_CODDES TRB_CODDES,  GO7.GO7_QTDDES TRB_QTDDES, GO7.GO7_VALDES TRB_VALDES," + HS_FVALDES("GO7")+ " AS TRB_TOT, "
cQry += "GA7.GA7_DESC TRB_DESC, GAW.GAW_CODGDE TRB_CODGDE , GAW.GAW_DESC TRB_DESCGR, GCT.GCT_CODUNC TRB_CODUNC, GCT.GCT_DESUNC TRB_DESUNC "
cQry += "FROM " + RetSqlName("GO0") + " GO0 " 
cQry += "JOIN " + RetSQLName("GCM") + " GCM ON GCM.GCM_CODPLA = GO0.GO0_CODPLA AND GCM.GCM_FILIAL = '" + xFilial("GCM") + "' AND GCM.D_E_L_E_T_ <> '*' AND GCM.GCM_CODCON BETWEEN '" + cCodCon_De + "' AND '" + cCodCon_Ate + "' "   
cQry += "JOIN " + RetSqlName("GO7") + " GO7 ON GO7.GO7_NUMORC = GO0.GO0_NUMORC AND GO7.GO7_FILIAL = '" + xFilial("GO7") + "' AND GO7.D_E_L_E_T_ <> '*' "   
cQry += "JOIN " + RetSqlName("GA7") + " GA7 ON GA7.GA7_CODPRO = GO7.GO7_CODDES AND GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' "
cQry += "JOIN " + RetSqlName("GAW") + " GAW ON GAW.GAW_CODGDE = GA7.GA7_CODGDE AND GAW.GAW_FILIAL = '" + xFilial("GAW") + "' AND GAW.D_E_L_E_T_ <> '*' " 
cQry += "JOIN " + RetSqlName("GCS") + " GCS ON GCS.GCS_CODLOC = GO0.GO0_CODLOC AND GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' "
cQry += "JOIN " + RetSqlName("GCT") + " GCT ON GCT.GCT_CODUNC = GCS.GCS_CODUNC AND GCT.GCT_FILIAL = '" + xFilial("GCT") + "' AND GCT.D_E_L_E_T_ <> '*' "  
cQry += "WHERE "
cQry += "    GO0.GO0_FILIAL = '" + xFilial("GO0") + "' AND GO0.D_E_L_E_T_ <> '*' "   
cQry += "AND GO0.GO0_NUMORC BETWEEN '" + cNumOrc_De + "' AND '" + cNumOrc_Ate + "' "
cQry += "AND GO0.GO0_DATORC BETWEEN '" + DTOS(dDatOrc_De) + "' AND '" + DTOS(dDatOrc_Ate) + "' "
cQry += "AND GO0.GO0_CODPLA BETWEEN '" + cCodPla_De + "' AND '" + cCodPla_Ate + "' " 
If nStatus == 1
 cQry += "AND GO0.GO0_STATUS = '0' "
ElseIf nStatus == 2
 cQry += "AND GO0.GO0_STATUS = '1' "
ElseIf nStatus == 3
	cQry += "AND GO0.GO0_STATUS = '2' "
EndIf  	  
        
If nTipOrc == 1
 cQry += "AND GO0.GO0_ATENDI = '0' "
ElseIf nTipOrc == 2
 cQry += "AND GO0.GO0_ATENDI = '1' "
ElseIf nTipOrc == 3
 cQry += "AND GO0.GO0_ATENDI = '2' "
EndIf	 

cQry += "ORDER BY TRB_NUMORC, TRB_CODUNC, TRB_CODGDE"
  
// Executa a Query
cQry				:= ChangeQuery(cQry)
cArqTrab		:= CriaTrab(,.F.)

dbUseArea(.T.,"TOPCONN", TcGenQry(,,cQry), "TRB", .F., .F.)

DbSelectArea("TRB")

dbGoTop()

If Eof()
 HS_MsgInf(STR0006, STR0032, STR0033) //"Nenhum orcamento foi encontrado para a selecao efetuada."###"Aten็ใo"###"Verifique a sele็ใo"
 DbCloseArea()
 MS_FLUSH()
 Return()
Endif 

SetRegua(100)
While !EOF()
 IncRegua()
	
	If lAbortPrint
		@nLin,00 PSAY STR0008 //"*** CANCELADO PELO OPERADOR ***"
		Exit
	Endif
	
	If nLin > nMaxLin .Or. cNumOrc <> TRB->TRB_NUMORC
		Cabec1  := STR0009 + TRB->TRB_REGATE + "         "   //"Atendimento: "
		Cabec1  += STR0010 + TRB->TRB_NOMPAC   //"Nome    : "
		Cabec1  += STR0041 + DTOC(STOD(TRB->TRB_DATORC)) + "  " + TRB->TRB_HORORC    //"Data Orcamento: "
		
		Cabec2  := STR0012 + Posicione("GA9",1,xFilial("GA9")+TRB->TRB_CODCON,"GA9_NREDUZ")    //"Convenio...: "
		Cabec2  += STR0013 + Posicione("GCM",2,xFilial("GCM")+TRB->TRB_CODPLA,"GCM_DESPLA") + "     "     //"Plano...: "
		Cabec2  += STR0011 + TRB->TRB_NUMORC //"Orcamento: "
		
		Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo, , .F.) 
		nLin := 8
		
		nLin ++
		@ nLin,64 PSAY IIf(lTamProd,STR0014,STR0043)  //"Quantidade   Vlr.Unit.   Vlr.Total"
		nLin++
		@ nLin,00 PSAY STR0015 + TRB->TRB_DESUNC   //"Unidade de Consumo: "
		nLin += 2
 	@ nLin,03 PSAY STR0016 + TRB->TRB_DESCGR   //"Grupo de Despesa: "
		cCODGRU := TRB->TRB_CODGDE
		cNumOrc := TRB->TRB_NUMORC
		nLin ++ 
	Endif
	
	If cCODGRU != TRB->TRB_CODGDE
		@ nLin,03 PSAY STR0016 + TRB->TRB_DESCGR   //"Grupo de Despesa: "
		cCODGRU := TRB->TRB_CODGDE
		nLin ++ 
	EndIf
	
	/*
	Quantidade   Vlr.Unit.   Vlr.Total
	99,999.99  999,999.99  999,999.99
	567890123456789012345678901234567890
	6    7         8         9  */
	
	@ nLin,06 PSAY TRB->TRB_CODDES
	@ nLin,IIf(lTamProd,23,38)  PSAY SUBSTR( TRB->TRB_DESC,1,40 )
	@ nLin,IIf(lTamProd,65,80) PSAY TRB->TRB_QTDDES PICTURE "@E 99,999.99"   
    @ nLin,IIf(lTamProd,76,91) PSAY TRB->TRB_VALDES PICTURE "@E 999,999.99"
    @ nLin,IIf(lTamProd,88,103) PSAY TRB->TRB_TOT    PICTURE "@E 999,999.99"

 nGrpDesp  += TRB->TRB_TOT

 nLin  ++
	cCODUNC  := TRB_CODUNC
	cCODGRU  := TRB->TRB_CODGDE
	
	dbSkip()
	
  // Imprime o total do grupo de despesas
	If TRB->TRB_CODGDE != cCODGRU .Or. TRB->TRB_CODUNC != cCODUNC
		@ nLin,23 PSAY STR0017 + Posicione("GAW",1,xFilial("GAW")+cCodGru,"GAW_DESC")    //"Total do Grupo "
		@ nLin,88 PSAY nGrpDesp PICTURE "@E 999,999.99"
		nUniCons  += nGrpDesp
		nGrpDesp  := 0
		nLin      += 2
	EndIf
	
	// Imprime o total	da unidade de consumo
	If TRB->TRB_CODUNC != cCODUNC  .OR. Eof()
		@ nLin,23 PSAY STR0018 + Posicione("GCT",1,xFilial("GCT")+cCodUNC,"GCT_DESUNC")   //"Total da Unid. Cons."
		@ nLin,88 PSAY nUniCons PICTURE "@E 999,999.99"
		nTotGer   += nUniCons
		If Eof()
			nLin += 2
			@ nLin, 23 PSAY STR0019 //"TOTAL GERAL"
			@ nLin, 88 PSAY nTotGer	PICTURE "@E 999,999.99"
		EndIf
		
		nUniCons := 0
		nLin     := nMaxLin * 2 // Forca um salto de pagina
	EndIf
	
EndDo

dbSelectArea("TRB")
dbCloseArea()

SET DEVICE TO SCREEN

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return(NIL)         
