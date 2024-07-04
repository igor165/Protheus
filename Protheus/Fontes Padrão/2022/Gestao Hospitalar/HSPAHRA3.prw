#INCLUDE "HSPAHRA3.ch"
#include "TopConn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HSPAHRA3 บ       ณ Saude              บ Data ณ 25/05/2005  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Capa do orcamento                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHRA3(cNumOrc)
 Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
 Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
 Local cDesc3         := ""
 Local cPict          := ""
 Local cTitulo        := STR0003 //"Capa do Orcamento"
 Local nLin           := 80 
 Local cCabec1        := ""
 Local cCabec2        := ""
 Local imprime        := .T.
 Local aOrd           := {}
 Local nLinTotal      := 60

 Private lEnd         := .F.
 Private lAbortPrint  := .F.
 Private Tamanho      := "M"
 Private limite       := 132
 Private m_pag        := 01
 Private nomeprog     := "HSPAHRA3"
 Private nTipo        := 18
 Private aReturn      := {STR0004, 1, STR0005, 2, 2, 1, "", 1} //"Zebrado"###"Administracao"
 Private nLastKey     := 0
 Private wnrel        := "HSPAHRA3"
 Private cString      := "GCY"
 Private aVetor       := {}
 Private cPerg        := "HSPRA8"
 Private bRepli       := {|| REPLI("_",132) }
 
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

 Private cCODIMP := ""
 Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao
 
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ PARAMETROS                                                       ณ
 //ณ MV_PAR01	Numero do orcamento inicial                             ณ
 //ณ MV_PAR02	Numero do orcamento final                               ณ
 //ณ MV_PAR03	Data do orcamento inicial                               ณ
 //ณ MV_PAR04	Data do orcamento final                                 ณ
 //ณ MV_PAR05	Status do orcamento                                     ณ
 //ณ MV_PAR06	Tipo do orcamento                                       ณ 
 //ณ MV_PAR07	Do Convenio                                             ณ
 //ณ MV_PAR08	Ate COnvenio                                            ณ
 //ณ MV_PAR09	Do Plano                                                ณ
 //ณ MV_PAR10	Ate Plano                                               ณ 
 //| MV_PAR11 Impressora ?                                            |
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 
 If !lChamado
 	If !Pergunte(cPerg,.T.)
   Return
  EndIf
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
  
 wnrel := SetPrint(cString,NomeProg,IIf(lChamado,"","HSPRA8"),@cTitulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.F.)
 
 If nLastKey == 27
  Return
 Endif
 
 SetDefault(aReturn,cString)
 
 If nLastKey == 27
  Return
 Endif
 
 RptStatus({|| RunRel(cCabec1, cCabec2, cTitulo, nLin, nLinTotal)}, cTitulo)
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ Cibele Peria       บ Data ณ  25/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Rotina de execucao do relatorio                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function RunRel(cCabec1, cCabec2, cTitulo, nLin, nLinTotal)
 Local   cSQL    := ""
 Local   cNumOrc := ""
 Local   nPosVet := 0
 
 Private aVetor  := {}
 
 cSQL := "SELECT " 
 cSQL += "GO0.GO0_NUMORC, GO0.GO0_REGGER, GO0.GO0_REGATE, GO0.GO0_NOMPAC, GO0.GO0_SEXO, GO0.GO0_FONE, GO0.GO0_DTNASC, GO0.GO0_CODPLA, "
 cSQL += "GAW.GAW_CODGDE, GAW.GAW_DESC, GCM.GCM_CODCON," + HS_FVALDES("GO5")+ " AS VALDES "
 cSQL += "FROM " + RetSQLName("GO0") + " GO0 "
 cSQL += "JOIN " + RetSQLName("GO5") + " GO5 ON GO5.GO5_NUMORC = GO0.GO0_NUMORC AND GO5.GO5_FILIAL = '" + xFilial("GO5") + "' AND GO5.D_E_L_E_T_ <> '*' "  
 cSQL += "JOIN " + RetSQLName("GBI") + " GBI ON GBI.GBI_PRODUT = GO5.GO5_CODDES AND GBI.GBI_FILIAL = '" + xFilial("GBI") + "' AND GBI.D_E_L_E_T_ <> '*' "  
 cSQL += "JOIN " + RetSQLName("GAW") + " GAW ON GAW.GAW_CODGDE = GBI.GBI_CODGDE AND GAW.GAW_FILIAL = '" + xFilial("GAW") + "' AND GAW.D_E_L_E_T_ <> '*' "  
 cSQL += "JOIN " + RetSQLName("GCM") + " GCM ON GCM.GCM_CODPLA = GO0.GO0_CODPLA AND GCM.GCM_FILIAL = '" + xFilial("GCM") + "' AND GCM.D_E_L_E_T_ <> '*' AND GCM.GCM_CODCON BETWEEN '" + cCodCon_De + "' AND '" + cCodCon_Ate + "' "   
 cSQL += "WHERE GO0.GO0_FILIAL = '" + xFilial("GO0") + "' AND GO0.D_E_L_E_T_ <> '*' " 
 cSQL += "AND GO0.GO0_NUMORC BETWEEN '" + cNumOrc_De + "' AND '" + cNumOrc_Ate + "' " 
 cSQL += "AND GO0.GO0_DATORC BETWEEN '" + DTOS(dDatOrc_De) + "' AND '" + DTOS(dDatOrc_Ate) + "' " 
 cSQL += "AND GO0.GO0_CODPLA BETWEEN '" + cCodPla_De + "' AND '" + cCodPla_Ate + "' " 
 If nStatus == 1
  cSQL += "AND GO0.GO0_STATUS = '0' " 
 ElseIf nStatus == 2
  cSQL += "AND GO0.GO0_STATUS = '1' " 
 ElseIf nStatus == 3
  cSQL += "AND GO0.GO0_STATUS = '2' " 
 Endif  
 If nTipOrc == 1
  cSQL += "AND GO0.GO0_ATENDI = '0' " 
 ElseIf nTipOrc == 2
  cSQL += "AND GO0.GO0_ATENDI = '1' " 
 ElseIf nTipOrc == 3
  cSQL += "AND GO0.GO0_ATENDI = '2' " 
 Endif  
 
 cSQL += "UNION ALL "
 cSQL += "SELECT " 
 cSQL += "GO0.GO0_NUMORC, GO0.GO0_REGGER, GO0.GO0_REGATE, GO0.GO0_NOMPAC, GO0.GO0_SEXO, GO0.GO0_FONE, GO0.GO0_DTNASC, GO0.GO0_CODPLA, " 
 cSQL += "GAW.GAW_CODGDE, GAW.GAW_DESC, GCM.GCM_CODCON," + HS_FVALDES("GO6")+ " AS VALDES " 
 cSQL += "FROM " + RetSQLName("GO0") + " GO0 " 
 cSQL += "JOIN " + RetSQLName("GO6") + " GO6 ON GO6.GO6_NUMORC = GO0.GO0_NUMORC AND GO6.GO6_FILIAL = '" + xFilial("GO6") + "' AND GO6.D_E_L_E_T_ <> '*' " 
 cSQL += "JOIN " + RetSQLName("GAA") + " GAA ON GAA.GAA_CODTXD = GO6.GO6_CODDES AND GAA.GAA_FILIAL = '" + xFilial("GAA") + "' AND GAA.D_E_L_E_T_ <> '*' " 
 cSQL += "JOIN " + RetSQLName("GAW") + " GAW ON GAW.GAW_CODGDE = GAA.GAA_CODGDE AND GAW.GAW_FILIAL = '" + xFilial("GAW") + "' AND GAW.D_E_L_E_T_ <> '*' " 
 cSQL += "JOIN " + RetSQLName("GCM") + " GCM ON GCM.GCM_CODPLA = GO0.GO0_CODPLA AND GCM.GCM_FILIAL = '" + xFilial("GCM") + "' AND GCM.D_E_L_E_T_ <> '*' AND GCM.GCM_CODCON BETWEEN '" + cCodCon_De + "' AND '" + cCodCon_Ate + "' "   
 cSQL += "WHERE GO0.GO0_FILIAL = '" + xFilial("GO0") + "' AND GO0.D_E_L_E_T_ <> '*' " 
 cSQL += "AND GO0.GO0_NUMORC BETWEEN '" + cNumOrc_De + "' AND '" + cNumOrc_Ate + "' " 
 cSQL += "AND GO0.GO0_DATORC BETWEEN '" + DTOS(dDatOrc_De) + "' AND '" + DTOS(dDatOrc_Ate) + "' " 
 cSQL += "AND GO0.GO0_CODPLA BETWEEN '" + cCodPla_De + "' AND '" + cCodPla_Ate + "' " 
 If nStatus == 1
  cSQL += "AND GO0.GO0_STATUS = '0' " 
 ElseIf nStatus == 2
  cSQL += "AND GO0.GO0_STATUS = '1' " 
 ElseIf nStatus == 3
  cSQL += "AND GO0.GO0_STATUS = '2' " 
 Endif  
  If nTipOrc == 1
  cSQL += "AND GO0.GO0_ATENDI = '0' " 
 ElseIf nTipOrc == 2
  cSQL += "AND GO0.GO0_ATENDI = '1' " 
 ElseIf nTipOrc == 3
  cSQL += "AND GO0.GO0_ATENDI = '2' " 
 Endif  

 cSQL += "UNION ALL " 
 cSQL += "SELECT " 
 cSQL += "GO0.GO0_NUMORC, GO0.GO0_REGGER, GO0.GO0_REGATE, GO0.GO0_NOMPAC, GO0.GO0_SEXO, GO0.GO0_FONE, GO0.GO0_DTNASC, GO0.GO0_CODPLA, " 
 cSQL += "GAW.GAW_CODGDE, GAW.GAW_DESC, GCM.GCM_CODCON," + HS_FVALDES("GO7")+ " AS VALDES " 
 cSQL += "FROM " + RetSQLName("GO0") + " GO0 " 
 cSQL += "JOIN " + RetSQLName("GO7") + " GO7 ON GO7.GO7_NUMORC = GO0.GO0_NUMORC AND GO7.GO7_FILIAL = '" + xFilial("GO7") + "' AND GO7.D_E_L_E_T_ <> '*' " 
 cSQL += "JOIN " + RetSQLName("GA7") + " GA7 ON GA7.GA7_CODPRO = GO7.GO7_CODDES AND GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' " 
 cSQL += "JOIN " + RetSQLName("GAW") + " GAW ON GAW.GAW_CODGDE = GA7.GA7_CODGDE AND GAW.GAW_FILIAL = '" + xFilial("GAW") + "' AND GAW.D_E_L_E_T_ <> '*' " 
 cSQL += "JOIN " + RetSQLName("GCM") + " GCM ON GCM.GCM_CODPLA = GO0.GO0_CODPLA AND GCM.GCM_FILIAL = '" + xFilial("GCM") + "' AND GCM.D_E_L_E_T_ <> '*' AND GCM.GCM_CODCON BETWEEN '" + cCodCon_De + "' AND '" + cCodCon_Ate + "' "   
 cSQL += "WHERE GO0.GO0_FILIAL = '" + xFilial("GO0") + "' AND GO0.D_E_L_E_T_ <> '*' " 
 cSQL += "AND GO0.GO0_NUMORC BETWEEN '" + cNumOrc_De + "' AND '" + cNumOrc_Ate + "' " 
 cSQL += "AND GO0.GO0_DATORC BETWEEN '" + DTOS(dDatOrc_De) + "' AND '" + DTOS(dDatOrc_Ate) + "' " 
 cSQL += "AND GO0.GO0_CODPLA BETWEEN '" + cCodPla_De + "' AND '" + cCodPla_Ate + "' " 
 If nStatus == 1
  cSQL += "AND GO0.GO0_STATUS = '0' " 
 ElseIf nStatus == 2
  cSQL += "AND GO0.GO0_STATUS = '1' " 
 ElseIf nStatus == 3
  cSQL += "AND GO0.GO0_STATUS = '2' " 
 Endif
  If nTipOrc == 1
  cSQL += "AND GO0.GO0_ATENDI = '0' " 
 ElseIf nTipOrc == 2
  cSQL += "AND GO0.GO0_ATENDI = '1' " 
 ElseIf nTipOrc == 3
  cSQL += "AND GO0.GO0_ATENDI = '2' " 
 Endif  
 cSQL += "ORDER BY GO0_NUMORC, GAW_CODGDE"

 cSQL := ChangeQuery(cSQL)
 
 TCQUERY cSQL NEW ALIAS "QRY"
 
 DbSelectArea("QRY")
 DbGoTop()
 
 If Eof()
  HS_MsgInf(STR0006, STR0032, STR0033) //"Nenhum orcamento foi encontrado para a selecao efetuada."###"Aten็ใo"###"Verifique a sele็ใo"
  DbCloseArea()
  MS_FLUSH()
  Return()
 Endif 
  
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ SETREGUA -> Indica quantos registros serao processados para a regua ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 SetRegua(150)
 While !Eof()                                                                                
  IncRegua()

  If QRY->GO0_NUMORC <> cNumOrc
   If !EMPTY(cNumOrc)
    FS_Impr(nLin, cTitulo, cCabec1, cCabec2, NomeProg, Tamanho, nTipo)
    aVetor := {}
   EndIf

   FS_CabEmp(cTitulo, cCabec1, cCabec2, NomeProg, Tamanho, nTipo)
   nLin := 12
   nLin := FS_Capa(nLin)
 
   cNumOrc := QRY->GO0_NUMORC
  EndIf

  If (nPosVet := aScan(aVetor, {| aVetTmp | aVetTmp[1] == QRY->GAW_CODGDE })) == 0
   AADD(aVetor,{QRY->GAW_CODGDE, QRY->GAW_DESC, QRY->VALDES})
  Else
   aVetor[nPosVet,3] += QRY->VALDES
  Endif     
  
  dbSelectArea("QRY")  
  DbSkip() 
      
 EndDo 
 If EOF()
  FS_Impr(nLin, cTitulo, cCabec1, cCabec2, NomeProg, Tamanho, nTipo)
 EndIf
 
 dbSelectArea("QRY")
 dbCloseArea()
 
 Set Printer to
 Set Device  to Screen
 
 If aReturn[5]==1
  dbCommitAll()
  SET PRINTER TO
  OurSpool(wnrel)
 Endif

 MS_FLUSH()
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_CAPA   บ Autor ณ Cibele Peria       บ Data ณ  25/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Impressao da capa                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_Capa(nLin)
 Local cAliasOld := Alias()
 
 DbSelectArea("GBH")
 DbSetOrder(1)
 DbSeek(xFilial("GBH") + QRY->GO0_REGGER)

 @ nLin,40 Psay STR0007  + QRY->GO0_NUMORC //"O R C A M E N T O     H O S P I T A L A R   "
 nLin++
 @ nLin,00 Psay Eval(bRepli)
 nLin++
 @ nLin,00 Psay STR0008 + QRY->GO0_NOMPAC //"Nome..............: "
 @ nLin,62 Psay STR0009 + IIF(Empty(QRY->GO0_REGATE), DTOC(STOD(QRY->GO0_DTNASC)), DTOC(GBH->GBH_DTNASC)) //"Data de Nascimento: "
 @ nLin,94 Psay STR0010  //"Sexo .....: "
 IF !EMPTY(QRY->GO0_SEXO) 
  If QRY->GO0_SEXO == "0"
    @ nLin,106 Psay STR0011 //"Masculino"
  Else  
    @ nLin,106 Psay STR0012 //"Feminino"
  EndIf
 EndIf   
 nLin++
 @ nLin,00 Psay STR0013 + IIF(Empty(QRY->GO0_REGATE), "", GBH->GBH_END) //"Endereco .........: "
 @ nLin,62 Psay STR0014 + IIF(Empty(QRY->GO0_REGATE), "", GBH->GBH_NUM) //"Numero ...........: "
 @ nLin,94 Psay STR0015 + IIF(Empty(QRY->GO0_REGATE), "", GBH->GBH_BAIRRO) //"Bairro ...: "
 nLin++
 @ nLin,00 Psay STR0016 + IIF(Empty(QRY->GO0_REGATE), "", GBH->GBH_CEP + " " + ALLTRIM(GBH->GBH_MUN) + " - " + GBH->GBH_EST) //"Municipio ........: "
 nLin++
 @ nLin,00 Psay STR0017 + IIF(Empty(QRY->GO0_REGATE), QRY->GO0_FONE, GBH->GBH_TEL) //"Telefone .........: "
 @ nLin,62 Psay STR0034 + IIF(Empty(QRY->GO0_REGATE), "", GBH->GBH_CPF)//"C.P.F. ...........: "
 @ nLin,94 Psay STR0018 + IIF(Empty(QRY->GO0_REGATE), "", GBH->GBH_RG) //"Identidade: "
 nLin++
 @ nLin,00 Psay STR0019 + IIF(Empty(QRY->GO0_REGGER), "", Posicione("GFD",1,xFilial("GFD")+GCY->GCY_CODRES, "GFD_NOME") ) //"Responsavel ......: "
 nLin++
 @ nLin,00 Psay STR0020 + QRY->GO0_REGGER //"PRONTUARIO .......: "
 nLin++
 @ nLin,00 Psay Eval(bRepli)
 nLin++

 @ nLin,00 Psay STR0021 + Posicione("GA9",1,xFilial("GA9")+QRY->GCM_CODCON,"GA9_NREDUZ") //"Convenio .........: "
 @ nLin,62 Psay STR0022 + Posicione("GCM",2,xFilial("GCM")+QRY->GO0_CODPLA,"GCM_DESPLA") //"Plano ............: "
 nLin++

 @ nLin,00 Psay STR0023 + QRY->GO0_REGATE //"Atendimento ......: "
 If EMPTY(QRY->GO0_REGATE)
   @ nLin,62 Psay STR0035
   nLin++
   @ nLin,00 Psay STR0024  //"LEITO ............: "
   nLin++
   @ nLin,00 Psay STR0025  //"Data da Entrada ..: "
   @ nLin,62 Psay STR0026  //"Hora da Entrada ..: "
   nLin++
   @ nLin,00 Psay STR0027  //"Data da Saida ....: "
   @ nLin,62 Psay STR0028 //"Hora da Saida ....: "
   nLin++
   @ nLin,00 Psay Eval(bRepli)
 Else
   dbSelectArea("GCY")
   dbSetOrder(2)        
   If dbSeek(xFilial("GCY") + QRY->GO0_REGATE )
     @ nLin,62 Psay STR0035 + Posicione("GAS",1,xFilial("GAS")+GCY->GCY_CIDINT,"GAS_PATOLO")//"CID ..............: "
     nLin++
     @ nLin,00 Psay STR0024 + Posicione("GAV",1,xFilial("GAV")+GCY->GCY_REGATE,"GAV_LEITO")  //"LEITO ............: "
     nLin++
     @ nLin,00 Psay STR0025 + DTOC(GCY->GCY_DATATE) //"Data da Entrada ..: "
     @ nLin,62 Psay STR0026 + GCY->GCY_HORATE //"Hora da Entrada ..: "
     nLin++
     @ nLin,00 Psay STR0027 + DTOC(GCY->GCY_DATALT)  //"Data da Saida ....: "
     @ nLin,62 Psay STR0028 + GCY->GCY_HORALT //"Hora da Saida ....: "
     nLin++
     @ nLin,00 Psay Eval(bRepli)
     DbselectArea(cAliasOld)
   EndIf  
 EndIf  
 
 nLin++
  
Return(nLin)

/******************************************************************************************************************/

Static Function FS_Impr(nLin, cTitulo, cCabec1, cCabec2, NomeProg, Tamanho, nTipo)
 Local nCtaFor   := 1
 Local cGrupoD   := ""
 Local nSubTotal := 0
 Local nTotal    := 0
 nLin++
 @ nLin,00 Psay STR0029 //"Descricao                                                                                               -Total R$-"
 nLin++
 For nCtaFor := 1 to Len(aVetor)
  If nLin > nMaxLin
   FS_CabEmp(cTitulo,cCabec1,cCabec2,NomeProg,Tamanho,nTipo)
   nLin := 12
  	@ nLin,40 Psay STR0007 //"O R C A M E N T O     H O S P I T A L A R   "
  	nLin++
  	@ nLin,00 Psay STR0008 + IIF(Empty(QRY->GO0_REGATE), "", GCY->GCY_NOME) //"Nome..............: "
	  nLin++
  EndIf 
 
  If cGrupoD # aVetor[nCtaFor,1]
   cGrupoD := aVetor[nCtaFor,1]
   If nCtaFor > 1
     @ nLin,104 Psay nSubTotal Picture "999,999.99"
     nSubTotal := 0
     nLin++
   EndIf
  EndIf
  @ nLin,00 Psay aVetor[nCtaFor,1]
  @ nLin,18 Psay aVetor[nctaFor,2]
  @ nLin,91 Psay aVetor[nCtaFor,3] Picture "999,999.99"
  nSubTotal := nSubTotal + aVetor[nCtaFor,3]
  nTotal    := nTotal + aVetor[nCtaFor,3] 
  nLin++
 Next 
 @ nLin,104 Psay nSubTotal Picture "999,999.99"
 nLin+=2
 @ nLin,104 Psay "----------"
 nLin++
 @ nLin,060 Psay STR0030 //"T o t a l   d o   O r c a m e n t o ===> "
 @ nLin,104 Psay nTotal Picture "999,999.99"
 nLin++
 @ nLin,060 Psay "("+Extenso(nTotal,.F.,1 )+" )"
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_CABEMP บ Autor ณ Cibele Peria       บ Data ณ  25/05/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Impressao do cabecalho da empresa                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_CabEmp(cTitulo, cCabec1, cCabec2, NomeProg, Tamanho, nTipo)
 Cabec(cTitulo, cCabec1, cCabec2, NomeProg, Tamanho, nTipo, , .F.)  
 @ 06,00 PSAY SM0->M0_NOMECOM
 @ 07,00 PSAY SM0->M0_ENDENT+" "+SM0->M0_BAIRENT
 @ 08,00 PSAY SM0->M0_CIDENT+" - "+SM0->M0_ESTENT+ STR0036 +SM0->M0_CEPENT //" CEP: "
 @ 09,00 PSAY SM0->M0_CGC
 @ 10,00 PSAY STR0031+SM0->M0_TEL+ STR0037 +SM0->M0_FAX //"Fone: "###"  Fax: "
 @ 11,00 PSAY Eval(bRepli)
Return(Nil)
