#INCLUDE "hspahr37.ch"
#Include "protheus.ch"
#include "TopConn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HRPAHR37 บ Autor ณ Daniel Peixoto     บ Data ณ  24/07/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio Estatistica Permanencia Interna็ใo               บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ 
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHR37()
 Local   cDesc1      := STR0001 //"Este programa tem como objetivo imprimir relatorio "
 Local   cDesc2      := STR0002 //"de acordo com os parametros informados pelo usuario."
 Local   cDesc3      := STR0003 //"Estatistica Permanencia Media Internacao"
 Local   aOrd        := {}
 
 Private Cabec1      := ""
 Private Cabec2      := "" 
 Private cTitulo     := STR0003 //"Estatistica Permanencia Media Internacao"
 Private lEnd        := .F.
 Private lAbortPrint := .F.
 Private limite      := 132
 Private Tamanho     := "M"
 Private NomeProg    := "HSPAHR37"
 Private nTipo       := 18
 Private aReturn     := {STR0004, 1, STR0005, 2, 2, 1, "", 1}  //"Zebrado"###"Administracao"
 Private nLastKey    := 0
 Private m_Pag       := 01
 Private wnRel       := NomeProg
 Private nTam        := 132
 
 Private cCodLoc_De  := ""
 Private cCodLoc_Ate := ""
 Private cCodCon_De  := ""
 Private cCodCon_Ate := ""
 Private cCodPla_De  := ""
 Private cCodPla_Ate := ""
 Private cAnoMes     := ""
 Private nAtendi     := 0
 Private nMesesRetr  := 0
 Private nTipEst     := 0
 Private nTipRel     := 0
 Private nConsDataS  := 0
 Private nOrdem      := 0 
 Private nGrafico    := 0 
 Private cCodImp     := ""
 Private nMaxLin     := 0
 
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ PARAMETROS                                                       ณ
 //ณ MV_PAR01	Do setor                                                ณ
 //ณ MV_PAR02	Ate o setor                                             ณ
 //ณ MV_PAR03	Da convenio                                             ณ
 //ณ MV_PAR04	Ate a convenio                                          ณ
 //ณ MV_PAR05	Do plano                                                ณ
 //ณ MV_PAR06	Ate o plano                                             ณ
 //ณ MV_PAR07	Ano/mes referencia                                      ณ
 //ณ MV_PAR08	Quebra Por(1=Setor/2=Setor+Clinica/3=Setor+CID)         ณ
 //ณ MV_PAR09	Numero retroativo de meses para calculo da media        ณ
 //ณ MV_PAR10	Tipo da Estatisitca(1=Mansal/ 2=Diaria/3=Por Paciente   ณ  
 //ณ MV_PAR11	Tipo do relatorio (1=Analitico/ 2=Resumo)               ณ  
 //ณ MV_PAR12	COnsidera Dt. Saida(1=Nao/2=Sim)                        ณ  
 //ณ MV_PAR13	Ordem de impressao (1=por descricao/2=por qtde total)   ณ  
 //ณ MV_PAR14	Emite grafico (1=Ultimo Mes 2=Total 3=Media 4=Nenhum    ณ  
 //| MV_PAR15 Impressora                                              |
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 If !Pergunte("HSPR37",.T.)
  Return()
 EndIf
 
 cCodLoc_De  := mv_par01
 cCodLoc_Ate := mv_par02
 cCodCon_De  := mv_par03
 cCodCon_Ate := mv_par04
 cCodPla_De  := mv_par05
 cCodPla_Ate := mv_par06 
 cAnoMes     := Substr(DtoS(cToD("01/" + Substr(mv_par07, 1, 2) + "/" + Substr(mv_par07, 4, 4))) ,1, 6)
 nQuebra     := mv_par08
 nMesesRetr  := mv_par09
 nTipEst     := mv_par10
 nTipRel     := mv_par11
 nConsDataS  := mv_par12
 nOrdem      := mv_par13
 nGrafico    := mv_par14
 cCodImp     := mv_par15
 nMaxLin     := HS_MaxLin(cCodImp)

 wnrel := SetPrint("GCY", NomeProg, "", @cTitulo, cDesc1, cDesc2, cDesc3, .T., aOrd, .T., Tamanho, , .T.)
 If nLastKey == 27
  Return()
 Endif
 SetDefault(aReturn, "GCY")
 If nLastKey == 27
  Return()
 Endif

 nTipo := If(aReturn[4]==1,15,18)
 RptStatus({|| RunReport() }, cTitulo)
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ Cibele Peria       บ Data ณ  30/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Rotina de execucao do relatorio                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function RunReport()
 Local   cSql     := ""
 Local   nMes     := 0
 Local   nPosPar  := 0
 Local   cParam   := "", cParRel := "" 
 Local   cCodLoc  := ""
 Local   nForJoin := 0
 Local   cAlias   := ""
 Local   cPref    := ""
 Local   aDescMes := {STR0006,STR0007,STR0008,STR0009,STR0010,STR0011,STR0012,STR0013,STR0014,STR0015,STR0016,STR0017} //" Jan"###" Fev"###" Mar"###" Abr"###" Mai"###" Jun"###" Jul"###" Ago"###" Set"###" Out"###" Nov"###" Dez"
 Local   aGrafico := {}
 Local   cTitGrf  := ""
 Local   nPar     := 0
 Local   nValGra  := 0
 Local   cTitGra  := ""
 Local  cSubTitulo:= ""
 Local __cParam   := "", __cJoin  := "", __cOrder := ""
 Local nDias      := 0
 Local dDataAtu   := CTOD(""), dDataS := CTOD(""), dDataE := CTOD("")
 Local nPermLei   := GETMV("MV_PERMLEI")
 Local cFilUsu    := HS_FilUsu("GCY")
 Local cCposGCY   := HS_RetCpos("GCY" ,.T., ".")  

 Private aParam   := {}
 Private aSetor   := {}
 Private aResumo  := {}
 Private aGeral   := {}
 Private aMesesR  := Array(12)
 Private nLin     := nMaxLin + 1
 Private nPosC1   := 15
 Private nPosC2   := 16
 Private nTotGer  := 0
 Private cLimDataE := ""
 Private nTotGeral := 0
 Private nLeitoAtv := 0

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Monta array com os meses retroativos ao Ano/Mes informado        ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 aMesesR     := Array(12)
 aMesesR[12] := cAnoMes
 For nMes := 11 to 1 Step -1
  aMesesR[nMes] := FS_MesRetr(aMesesR[nMes+1])
 Next nMes

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Montagem do cabecalho do relatorio                               ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 If nQuebra == 1 //Setor
  cSubTitulo  := STR0018 //"Setor"
 ElseIf nQuebra == 2 //Setor+CLinica
  cSubTitulo  := STR0019 //"Clinica"
 Else//Setor+CID
  cSubTitulo  := STR0020 //"CID"
 EndIf
 Cabec1      := Padr(cSubTitulo, 40) 
 Cabec2      := Space(Len(Cabec1))

 For nMes := 1 to 12
  Cabec1        += Space(02) + aDescMes[Val(Substr(aMesesR[nMes], 5, 2))]
  Cabec2        += Space(02) + Substr(aMesesR[nMes], 1, 4)
 Next nMes
 Cabec1 += " " + PADR(STR0021, 6) + " " + PADC("(%)", 6) + " " + PADR(STR0022, 5) //"Total"###"Media"
 Cabec2 += SPACE(15) + PADR("(" + AllTrim(Str(nMesesRetr)) + "M" + ")", 5)

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Selecao dos dados                                                ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 If nQuebra == 1 //Setor
  __cParam := "GCS.GCS_NOMLOC"
  __cOrder := " ORDER BY GCS.GCS_NOMLOC, GB1.GB1_DATAE"
 ElseIf nQuebra == 2 //Setor+Clinica
  __cParam := "GCW.GCW_DESCLI"
  __cJoin  := "JOIN " + RetSQLName("GCW") + " GCW ON GCW.GCW_FILIAL = '" + xFilial("GCW") + "' AND GCW.D_E_L_E_T_ <> '*' AND GCW.GCW_CODCLI = GCY.GCY_CODCLI "  
  __cOrder := " ORDER BY GCS.GCS_NOMLOC, GCW.GCW_DESCLI, GB1.GB1_DATAE"
 ElseIf nQuebra == 3 //Setor+CID
  __cParam := "GAS.GAS_PATOLO" 
  __cJoin  := "JOIN " + RetSQLName("GAS") + " GAS ON GAS.GAS_FILIAL = '" + xFilial("GAS") + "' AND GAS.D_E_L_E_T_ <> '*' AND GAS.GAS_CODIGO = GCY.GCY_CIDINT "   
  __cOrder := "ORDER BY GCS.GCS_NOMLOC, GAS.GAS_PATOLO, GB1.GB1_DATAE"
 EndIf

	cSQL := "SELECT " + cCposGCY + ", GB1.GB1_DATAE DATAE, GB1.GB1_HORAE HORAE, GB1.GB1_DATAS DATAS, GB1.GB1_HORAS HORAS, " + __cParam + " PARAMETRO, GCS.GCS_CODLOC CODLOC "
 If nQuebra <> 1 
  cSQL += ", GCS.GCS_NOMLOC NOMLOC "
 EndIf
 cSQL += "FROM " + RetSQLName("GCY") + " GCY "                
 cSQL += "JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
 cSQL += "JOIN " + RetSQLName("GB1") + " GB1 ON GB1.GB1_FILIAL = '" + xFilial("GB1") + "' AND GB1.D_E_L_E_T_ <> '*' AND GB1.GB1_REGATE = GCY.GCY_REGATE "
 cLimDataE := IIF(cAnoMes < Substr(DTOS(DDATABASE), 1, 6), DTOS(LastDay(STOD(cAnoMes+"01"))),  DTOS(DDATABASE))
 cSQL += "                                      AND GB1.GB1_DATAE <= '" + cLimDataE + "' "
 cSQL += "                                      AND (GB1.GB1_DATAS >= '" + aMesesR[1] + "01"  + "' OR GB1.GB1_DATAS = '" + SPACE(8) + "') "
 cSQL += "JOIN " + RetSQLName("GAV") + " GAV ON GAV.GAV_FILIAL = '" + xFilial("GAV") + "' AND GAV.D_E_L_E_T_ <> '*' AND GAV.GAV_CODLOC = GB1.GB1_CODLOC AND GAV.GAV_QUARTO = GB1.GB1_QUARTO "
 cSQL += "                                      AND GAV.GAV_LEITO = GB1.GB1_LEITO AND GAV.GAV_ESTATI = '1' "
 cSQL += "JOIN " + RetSQLName("GCS") + " GCS ON GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' AND GCS.GCS_CODLOC = GB1.GB1_CODLOC "  
 cSQL += __cJoin
 cSQL += "WHERE GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "
 cSQL += "AND GCY.GCY_TPALTA <> '99' "
 cSQL += "AND GCZ.GCZ_NRSEQG = (SELECT MIN(GCZ_NRSEQG) FROM " + RetSQLName("GCZ") + " GCZ WHERE GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
 cSQL += "AND GCZ_REGATE = GCY.GCY_REGATE) "

 If !Empty(cCodLoc_De)
  cSQL += "AND GB1.GB1_CODLOC >= '" + cCodLoc_De + "' "
 Endif 
 If !Empty(cCodLoc_Ate)
  cSQL += "AND GB1.GB1_CODLOC <= '" + cCodLoc_Ate + "' "
 Endif

 If !Empty(cCodCon_De)
  cSQL += "AND GCZ.GCZ_CODCON >= '" + cCodCon_De + "' "
 Endif
 If !Empty(cCodCon_Ate)
  cSQL += "AND GCZ.GCZ_CODCON <= '" + cCodCon_Ate + "' "
 Endif
 
 If !Empty(cCodPla_De)
  cSQL += "AND GCZ.GCZ_CODPLA >= '" + cCodPla_De + "' "
 Endif
 If !Empty(cCodPla_Ate)
  cSQL += "AND GCZ.GCZ_CODPLA <= '" + cCodPla_Ate + "' "
 Endif
 cSQL += "AND GCY.GCY_ATENDI = '0' "
 
 cSQL += __cOrder
 
 cSQL := ChangeQuery(cSQL)
 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")

 DbGoTop()
 If Eof()
  Hs_MsgInf(STR0023,STR0024,STR0025) //"Nenhum dado foi encontrado para a selecao efetuada."###"Aten็ใo"###"Execu็ใo do Relatorio"
  DbCloseArea()
  Return()
 Endif
  
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Emissao do relatorio                                             ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 cTitGrf := AllTrim(cTitulo)
 cTitulo := AllTrim(cTitulo) + " - " + IIF(nTipEst == 1, STR0035, IIF(nTipEst == 2, STR0036, STR0037)) //"Mensal"###"Diแria"###"Paciente"
 cTitulo := AllTrim(cTitulo) + " - " + IIF(nTipRel == 1, STR0026,STR0027) //"Analitico"###"Sintetico"
 cTitulo += " (" +  IIF(nOrdem==1, STR0028, ; //"Ultimo mes"
                    IIF(nOrdem==2, STR0021, ; //"Total"
                    IIF(nOrdem==3, STR0022, STR0029))) + ")" //"Media"###"Descricao"
 aGeral  := {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, STR0030, STR0038} //"R E S U M O" //"M้dia M๊s"
 If nQuebra == 1 //Setor
  aSetor := {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, "", STR0038}   //"M้dia M๊s"
 EndIf 
 
 SetRegua(1000)
 
 While !Eof()                                                                                

  If !&(cFilUsu)    // Filtro usando HS_FilUsu para imprimir o que foi selecionado pelo usuario.
   DbSkip()
   Loop
  Endif

  IncRegua()
  
  If nQuebra <> 1 .And. nTipRel == 1 .And. QRY->NOMLOC <> cCodLoc
   If !Empty(cCodLoc)
    FS_Total(cTitulo, aParam, aSetor)
   Endif 
   cCodLoc        := QRY->NOMLOC   
   aSetor         := {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, STR0032 + QRY->NOMLOC, STR0039}  //"Setor: " //"M้dia Mes"
   aParam         := {}
   cParam         := ""   
  Endif
  
  cParRel := QRY->PARAMETRO
  If cParam <> cParRel
   cParam   := cParRel
   If (nPosPar := aScan(aParam, {|x| x[15] == cParam})) == 0
    aAdd(aParam, {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, cParRel, cParRel, QRY->CODLOC})
    nPosPar  := len(aParam)
   Endif
   If (nPosRes := aScan(aResumo, {|x| x[15] == cParam})) == 0
    aAdd(aResumo, {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, cParRel, cParRel, QRY->CODLOC})
    nPosRes  := len(aResumo)
   Endif
  Endif

  //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
  //ณ Detalhe - acumular por linha (parametro) e no resumo ณ
  //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

 
  dDataE := IIF(STOD(QRY->DATAE) < STOD(aMesesR[1] + "01"), STOD(aMesesR[1] + "01"), STOD(QRY->DATAE))
    
  If !EMPTY(QRY->DATAS)
   dDataS := IIF(QRY->DATAS > cLimDataE, STOD(cLimDataE), STOD(QRY->DATAS))
  Else 
   If cAnoMes < SUBSTR(DTOS(dDataBase), 1, 6)
    dDataS := LastDay(STOD(cAnoMes+"01"))
   Else
    dDataS := dDataBase
   EndIf   
  EndIf 
  
  If dDataE == dDataS //Se entrou e saiu mesmo dia sempre contar 1, independente do perํodo dura็ใo
   FS_AtuVet(dDataE, nPosPar, nPosRes, QRY->GCY_REGGER)
  Else
   dDataAtu := dDataE 
   For nDias := 1 To (dDataS - dDataE)
    FS_AtuVet(dDataAtu, nPosPar, nPosRes, QRY->GCY_REGGER)   
    dDataAtu ++
   Next                           
   If Empty(QRY->HORAS) .Or. (nConsDataS == 2 .And. SubHoras(QRY->HORAS, 0) >= nPermLei) //Considera Dt Saida
    FS_AtuVet(dDataS, nPosPar, nPosRes, QRY->GCY_REGGER)
   EndIf
  EndIf 

  DbSkip()
 EndDo
 
 If Len(aParam) == 0
  Hs_MsgInf(STR0023,STR0024,STR0025) //"Nenhum dado foi encontrado para a selecao efetuada."###"Aten็ใo"###"Execu็ใo do Relatorio"
  DbCloseArea()
  Return()
 EndIf
 
 If nTipRel == 1 
  FS_Total(cTitulo, aParam, aSetor)
 Endif

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Impressao do resumo                                  ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 If nQuebra <> 1 .Or. (nQuebra == 1 .And. nTipRel == 2)
  FS_Total(cTitulo, aResumo, aGeral, , .T.) 
 ElseIf nQuebra == 1 .And. nTipRel == 1
  FS_Total(cTitulo, aResumo, aGeral, .F., .T.) 
 EndIf 
 
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Emissao do grafico                                               ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 If nGrafico < 4
  For nPar := 1 To Len(aResumo)
   If nGrafico == 1
    nValGra := aResumo[nPar, 12] //Ultimo mes
    cTitGra := STR0028 //"Ultimo mes"
   ElseIf nGrafico == 2
    nValGra := aResumo[nPar, 13]
    cTitGra := STR0021     //"Total"
   Else
    nValGra := aResumo[nPar, 14]
    cTitGra := STR0022 //"Media"
   Endif 
   aAdd(aGrafico, {nValGra, Padr(aResumo[nPar, 16], 40)}) 
  Next
  oGraf := HsGRAF():NEW(cTitGrf, cTitGrf, "", STR0034 + " (" + cTitGra + ")", cSubTitulo, "", aGrafico, 1, 1, 0, 0, 2, 17, 6, 6, 25, 20)      //"Quantidade"
 EndIf  
 
 SET DEVICE TO SCREEN
 If aReturn[5]==1
  dbCommitAll()
  SET PRINTER TO
  OurSpool(wnrel)
 Endif

 MS_FLUSH()
 DbSelectArea("QRY")
 DBCloseArea()

Return()
        
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_Cabec  บ Autor ณ Cibele Peria       บ Data ณ  30/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Cabecalho do relatorio                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_Cabec(cTitulo)
 Cabec(cTitulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo, ,.T.)
 nLin := 8
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_Total  บ Autor ณ Cibele Peria       บ Data ณ  30/11/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Impressao das linhas totalizadoras                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_Total(cTitulo, aDados, aTotal, lImp, lImpRes)
 Local   nFor := 0   
 Local nLinha := 0, nColuna := 0
 Local nLin1  := 0, nCol1   := 0
 Local nFatDiv    := 0                                     

 Default lImp    := .T.
 Default lImpRes := .F.
 
 If nTipEst == 1 //Mensal
  nTotGeral := IIF(!lImpRes, aSetor[13], aGeral[13])
  For nColuna := 1 To 13
   aSetor[nColuna] := aSetor[nColuna] / Len(aParam)
   If lImpRes
    aGeral[nColuna] := aGeral[nColuna] / Len(aResumo)
   EndIf 
  Next 
 
 ElseIf nTipEst == 2 .Or. nTipEst == 3 //Diaria ou Paciente
  For nLinha := 1 To Len(aParam)
   If nTipEst == 2
    nLeitoAtv := FS_LeiAtv(aParam[nLinha, 17])
   EndIf 
   For nColuna := 1 To 12                         
    If nTipRel == 1 //Analitico
     nFatDiv := FS_FatDiv(nTipEst, nColuna, aParam[nLinha, 17])
     aParam[nLinha, nColuna]  := aParam[nLinha, nColuna] / IIF(nFatDiv > 0, nFatDiv, 1)
    EndIf
    If nLinha == 1 
     If nTipRel == 1 //Analitico
      aSetor[nColuna] := IIf(nQuebra == 1, FS_MedTot(nTipEst, aParam, nColuna, .F.), aSetor[nColuna] / IIF(nFatDiv > 0, nFatDiv, 1) / Len(aParam))
     EndIf
     If lImpRes
      If nColuna == 1
       FS_CalcRes(nTipEst)
      EndIf 
      aTotal[nColuna] := IIf(nQuebra == 1, FS_MedTot(nTipEst, aDados, nColuna, .T.), aTotal[nColuna] / IIF(nFatDiv > 0, nFatDiv, 1) / Len(aDados))
     EndIf
    EndIf 
   Next
  Next
 
 EndIf


 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Calculo da media de cada ocorrencia sobre o total                ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 For nFor := 1 to len(aDados)
  If aDados[nFor, 13] > 0
   aDados[nFor, 14] := FS_Media(aDados[nFor])
  Endif 
 Next nFor

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Classificacao dos dados conforme opcao do usuario nas perguntas  ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 If len(aDados) > 1
  If nOrdem == 1          //ultimo mes
   aSort(aDados,,,{|x, y| x[12] > y[12]})
  ElseIf nOrdem == 2     //quantidade total
   aSort(aDados,,,{|x, y| x[13] > y[13]})
  ElseIf nOrdem == 3     //media
   aSort(aDados,,,{|x, y| x[14] > y[14]})
  Else                   //descricao
   aSort(aDados,,,{|x, y| x[16] < y[16]})
  Endif 
 Endif 
 
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Impressao dos totais de detalhe                                  ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 If aTotal[13] > 0
  aTotal[14] := FS_Media(aTotal)
 Endif  

 If lImp
  FS_Cabec(cTitulo)
  nLin += 1
  @nLin, 000 PSAY aTotal[15]
  nLin += 1
  For nFor := 1 to len(aDados)
   If nLin+1 > nMaxLin
    FS_Cabec(cTitulo)
   Endif
   nLin += 1
   
   FS_ImpTot(aDados[nFor], .T.)   
  Next nFor
  
  //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
  //ณ Impressao dos totais dos detalhes                                ณ
  //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
  If nLin+2 > nMaxLin
   FS_Cabec(cTitulo)
  Endif
  nLin += 2        
  
  FS_ImpTot(aTotal)
 EndIf
 
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_ImpTot บ Autor ณ Cibele Peria       บ Data ณ  13/12/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Impressao do total                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_ImpTot(aLinha, lTotMedia)
 Local nCont   := 0, nCol := 0                
 
 Default lTotMedia := .F.
 
 @nLin, 000 PSAY Padr(aLinha[16], 40)         
 nCol := 041
 For nCont := 1 To 12
  @nLin, nCol PSAY TRANSFORM(aLinha[nCont], "@E 99999")
  nCol += 6
 Next
 
 If nTipEst == 1 //mensal
  @nLin, 113 PSAY TRANSFORM(aLinha[13], "@E 999999") //Total
 EndIf
 
 If lTotMedia
  If nTipEst == 1 
   @nLin, 120 PSAY TRANSFORM((aLinha[13] / nTotGeral) * 100, "@E 999.99") //(%)
  ElseIf nTipEst == 2
   @nLin, 120 PSAY TRANSFORM((aLinha[14] / nLeitoAtv) * 100, "@E 999.99") //(%)
  EndIF
 Endif
 
 @nLin, 127 PSAY TRANSFORM(aLinha[14], "@E 99999") //Media(x Meses)

Return()
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_MesRetrบ Autor ณ Cibele Peria       บ Data ณ  29/03/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Subtrai nMeses de uma data no formato AAAAMM               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_MesRetr(cAnoMes)
 Local cAno := Substr(cAnoMes, 1, 4)
 Local cMes := Substr(cAnoMes, 5, 2)
 
 If cMes == "01"
  cAno := Str(Val(cAno)-1, 4)
  cMes := "12"
 Else
  cMes :=  StrZero(Val(cMes)-1, 2)
 Endif 
Return(cAno+cMes)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_Media  บ Autor ณ Cibele Peria       บ Data ณ  29/03/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Calcula a media dos ultimos n meses (meses retroativos)    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_Media(aQtd)
 Local nMedia  := 0
 Local nMes    := 0

 For nMes := 12 to (12-nMesesRetr+1) Step -1
  nMedia += aQtd[nMes]
 Next nMes
 nMedia := Int((nMedia / nMesesRetr))

Return(nMedia)

Static Function FS_AtuVet(dData, nPosPar, nPosRes, cRegGer)
 Local nMes := 0

 nMes := aScan(aMesesR, SUBSTR(DTOS(dData), 1, 6))  
  
 If nTipRel == 1   //Analitico
  aParam[nPosPar, nMes] ++ 
  aParam[nPosPar, 13]   ++ 
  aSetor[nMes]          ++ 
  aSetor[13]            ++ 
 EndIf
 
 aResumo[nPosRes, nMes] ++
 aResumo[nPosRes, 13]   ++
 aGeral[nMes]           ++
 aGeral[13]             ++

Return()                                                      

Function HS_VldR37()
 Local lRet := .T.
 
 If ReadVar() == "MV_PAR07"
  If !(lRet := Substr(MV_PAR07, 1, 2) $ "01/02/03/04/05/06/07/08/09/10/11/12")
   HS_MsgInf(STR0040, STR0024, STR0041) //"Mes/Ano referencia invalido"###"Aten็ใo"###"Subtrai Mes(es) de uma data"
  ElseIf !(lRet := Substr(MV_PAR07, 4, 4) + Substr(MV_PAR07, 1, 2) <= Substr(DTOS(DDATABASE), 1, 6) )
   HS_MsgInf(STR0042, STR0024, STR0043) //"Mes/Ano referencia nใo pode ser maior que o m๊s da database."###"Aten็ใo"###"Mes/Ano Refer๊ncia"
  Endif
 EndIf
 
Return(lRet)

Static Function FS_FatDiv(nTipEst, nMes, cCodLoc)
 Local nVal := 1
 Local cSQL := ""
 
 Default cCodLoc := ""
 
 If nTipEst == 2
  If nMes == 12
   nVal := VAL(SUBSTR(cLimDataE, 7, 2))
  Else
   nVal := VAL(SUBSTR(DTOS(LastDay(STOD(aMesesR[nMes] + "01"))), 7, 2))
  EndIf

 Else
  cSQL := "SELECT COUNT(DISTINCT(GCY.GCY_REGGER)) TOTREGGER "
  cSQL += "FROM " + RetSQLName("GCY") + " GCY "                
  cSQL += "JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
  cSQL += "JOIN " + RetSQLName("GB1") + " GB1 ON GB1.GB1_FILIAL = '" + xFilial("GB1") + "' AND GB1.D_E_L_E_T_ <> '*' AND GB1.GB1_REGATE = GCY.GCY_REGATE "
  cSQL += "                                      AND GB1.GB1_DATAE <= '" + DTOS(LastDay(STOD(aMesesR[nMes] + "01"))) + "' "
  cSQL += "                                      AND (GB1.GB1_DATAS >= '" + aMesesR[nMes] + "01"  + "' OR GB1.GB1_DATAS = '" + SPACE(8) + "') "
  cSQL += "JOIN " + RetSQLName("GAV") + " GAV ON GAV.GAV_FILIAL = '" + xFilial("GAV") + "' AND GAV.D_E_L_E_T_ <> '*' AND GAV.GAV_CODLOC = GB1.GB1_CODLOC AND GAV.GAV_QUARTO = GB1.GB1_QUARTO "
  cSQL += "                                      AND GAV.GAV_LEITO = GB1.GB1_LEITO AND GAV.GAV_ESTATI = '1' "
  cSQL += "WHERE GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "
  cSQL += "AND GCY.GCY_TPALTA <> '99' "
  cSQL += "AND GCZ.GCZ_NRSEQG = (SELECT MIN(GCZ_NRSEQG) FROM " + RetSQLName("GCZ") + " GCZ WHERE GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
  cSQL += "AND GCZ_REGATE = GCY.GCY_REGATE) "
  If !Empty(cCodLoc)
   cSQL += "AND GB1.GB1_CODLOC = '" + cCodLoc + "' "
  EndIf
  If !Empty(cCodCon_De)
   cSQL += "AND GCZ.GCZ_CODCON >= '" + cCodCon_De + "' "
  Endif
  If !Empty(cCodCon_Ate)
   cSQL += "AND GCZ.GCZ_CODCON <= '" + cCodCon_Ate + "' "
  Endif
 
  If !Empty(cCodPla_De)
   cSQL += "AND GCZ.GCZ_CODPLA >= '" + cCodPla_De + "' "
  Endif
  If !Empty(cCodPla_Ate)
   cSQL += "AND GCZ.GCZ_CODPLA <= '" + cCodPla_Ate + "' "
  Endif
  cSQL += "AND GCY.GCY_ATENDI = '0' "
 
  cSQL := ChangeQuery(cSQL)
  TCQUERY cSQL NEW ALIAS "QRYPAC"
  DbSelectArea("QRYPAC")

  nVal := QRYPAC->TOTREGGER
  
  DbCloseArea()
 
 EndIf 

Return(nVal)

Static Function FS_LeiAtv(cCodLoc)
 Local nQtdLei := 0
 Local cSQL    := ""
 
 cSQL := "SELECT COUNT(*) TOTLEI "
 cSQL += "FROM " + RetSQLName("GAV") + " GAV "                
 cSQL += "WHERE GAV.GAV_FILIAL = '" + xFilial("GAV") + "' AND GAV.D_E_L_E_T_ <> '*' "
 cSQL += "AND GAV.GAV_CODLOC = '" + cCodLoc + "' AND GAV_STATUS <> '4' "
 
 cSQL := ChangeQuery(cSQL)
 TCQUERY cSQL NEW ALIAS "QRYLEI"
 DbSelectArea("QRYLEI")

 nQtdLei := QRYLEI->TOTLEI
 
 DbCloseArea()

Return(nQtdLei)

Static Function FS_MedTot(nTipEst, aVet, nMes, lResumo)
 Local nMedia := 0, nCont := 0, nFatDiv := 0
 
 For nCont := 1 To Len(aVet)
  nFatDiv := FS_FatDiv(nTipEst, nMes, aVet[nCont, 17])
  nMedia += aVet[nCont, nMes] / IIF(nFatDiv > 0 .And. !lResumo, nFatDiv, 1)
 Next

 nMedia := nMedia / Len(aVet)
 
Return(nMedia)

Static Function FS_CalcRes(nTipEst)
 Local nLin1 := 0, nCol1 := 0

 For nLin1 := 1 To Len(aResumo)
  For nCol1 := 1 To 12              
   nFatDiv := FS_FatDiv(nTipEst, nCol1, aResumo[nLin1, 17])
   aResumo[nLin1, nCol1] := aResumo[nLin1, nCol1] / IIF(nFatDiv > 0, nFatDiv, 1)
  Next 
 Next 

Return(Nil)