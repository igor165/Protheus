#INCLUDE "HSPAHR47.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ HRPAHR47 บ Autor ณ Daniel Peixoto     บ Data ณ  16/06/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio Pacientes Dias no Periodo                        บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GESTAO HOSPITALAR.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ 
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHR47()

 Local   cDesc1      := STR0001 //"Este programa tem como objetivo imprimir relat๓rio "
 Local   cDesc2      := STR0002 //"de acordo com os parโmetros informados pelo usuแrio."
 Local   cDesc3      := STR0003 //"Pacientes Dias no Perํodo"
 Local   aOrd        := {}
 
 Private Cabec1      := ""
 Private Cabec2      := "" 
 Private cTitulo     := ""
 Private lEnd        := .F.
 Private lAbortPrint := .F.
 Private limite      := 132
 Private Tamanho     := "G"
 Private NomeProg    := "HSPAHR47"
 Private nTipo       := 18
 Private aReturn     := {STR0004, 1, STR0005, 2, 2, 1, "", 1}  //"Zebrado"###"Administra็ใo"
 Private nLastKey    := 0
 Private m_Pag       := 01
 Private wnRel       := NomeProg
 Private nTam        := 132
 Private nLin        := 80
 
 Private cAnoMes     := ""
 Private cCodLoc_De  := ""
 Private cCodLoc_Ate := ""
 Private cCodCli_De  := ""
 Private cCodCli_Ate := ""
 Private cCodCon_De  := ""
 Private cCodCon_Ate := ""
 Private nGrafico    := 0 
 Private nUti        := 0
 Private cCodImp     := ""
 Private nMaxLin     := 0
 
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ PARAMETROS                                                       ณ
 //ณ MV_PAR01	Tipo (1=Setor 2=Clinica)                                ณ
 //ณ MV_PAR02	Ano/Mes                                                 ณ
 //ณ MV_PAR03	Do setor                                                ณ
 //ณ MV_PAR04	Ate o setor                                             ณ
 //ณ MV_PAR05	Da Clinica                                              ณ
 //ณ MV_PAR06	Ate Clinica                                             ณ
 //ณ MV_PAR07	Considera Data Saida (1=Nao 2=Sim)                      ณ
 //ณ MV_PAR08	Emite grafico (1=Nao 2=SIm)                             ณ  
 //ณ MV_PAR09	Uti(1=Nao 2=Sim)                                        ณ
 //| MV_PAR10 Impressora                                              |
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 If !Pergunte("HSPR47", .T.)
  Return()
 EndIf
 
 nTipRel     := MV_PAR01
 cAnoMes     := Substr(DTOS(CTOD("01/" + Substr(MV_PAR02, 1, 2) + "/" + Substr(MV_PAR02, 4, 4))) ,1, 6)
 cCodLoc_De  := MV_PAR03
 cCodLoc_Ate := MV_PAR04
 cCodCli_De  := MV_PAR05
 cCodCli_Ate := MV_PAR06
 nConsDataS  := MV_PAR07
 nGrafico    := MV_PAR08
 nUti        := MV_PAR09


 cCodImp := MV_PAR10
 nMaxLin := HS_MaxLin(cCodImp)
 nLin    := nMaxLin * 2

 cTitulo := STR0006 + MesExtenso(STOD(cAnoMes + "01")) + " " + AllTrim(STR(YEAR(STOD(cAnoMes + "01")))) //"Pacientes Dia: Compet๊ncia "
 
 wnrel := SetPrint("GCY", NomeProg, "", @cTitulo, cDesc1, cDesc2, cDesc3, .T., aOrd, .T., Tamanho, , .T.)
 
 If nLastKey == 27
  Return()
 EndIf
 
 SetDefault(aReturn, "GCY")
 
 If nLastKey == 27
  Return()
 EndIf

 nTipo := If(aReturn[4] == 1, 15, 18)
 RptStatus({|| RunReport()}, cTitulo)
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ Daniel Peixoto     บ Data ณ  20/06/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Rotina de execucao do relatorio                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function RunReport()

 Local cSql        := ""
 Local nMes        := 0
 Local nCont       := 0
 Local nCont1      := 0
 Local cQuebra     := ""
 
 Private aVetDias  := {}
 Private aVetDados := {}
 Private aVetGraf  := {}
 Private nDiasMes  := Day(LastDay(STOD(cAnoMes + "01")))
 Private cLimDataE := ""
 Private nTotGer   := 0, nTotGPac := 0, nTotPac := 0


 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Montagem do cabecalho do relatorio                               ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 Cabec1 := Padr(IIF(nTipRel == 1, STR0007, STR0008), 30) //"Setor"###"Clํnica"
 For nMes := 1 To Day(LastDay(STOD(cAnoMes + "01")))
  Cabec1 += IIF(nMes < 10, Space(04), Space(03)) + ALLTRIM(STR(nMes))
 Next nMes
 Cabec1 += "  " + STR0019 //"Total"
 Cabec1 += "  " + STR0020 //"Pacientes"
 Cabec1 += "  " + STR0009

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Selecao dos dados                                                ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

 cSQL := "SELECT GCS.GCS_NOMLOC, GB1.GB1_CODLOC, GCW.GCW_DESCLI, GCW.GCW_CODCLI, GCY.GCY_REGATE, GB1.GB1_QUARTO, "
 cSQL += "GB1.GB1_LEITO, GB1.GB1_DATAE, GB1.GB1_DATAS, GB1.GB1_HORAS "
 cSQL += " FROM " + RetSQLName("GCY") + " GCY "             
 cSQL += " JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GB1") + " GB1 ON GB1.GB1_FILIAL = '" + xFilial("GB1") + "' AND GB1.D_E_L_E_T_ <> '*' AND GB1.GB1_REGATE = GCY.GCY_REGATE " 
 cLimDataE := IIF(cAnoMes < Substr(DTOS(DDATABASE), 1, 6), DTOS(LastDay(STOD(cAnoMes+"01"))),  DTOS(DDATABASE))
 cSQL += "                                      AND GB1.GB1_DATAE <= '" + cLimDataE + "' "
 cSQL += "                                      AND (GB1.GB1_DATAS >= '" + cAnoMes + "01"  + "' OR GB1.GB1_DATAS = '" + SPACE(8) + "') "
 cSQL += " 																																					AND GB1.GB1_CODLOC BETWEEN '" + cCodLoc_De + "' AND '" + cCodLoc_Ate + "' "  
 cSQL += " JOIN " + RetSQLName("GAV") + " GAV ON GAV.GAV_FILIAL = '" + xFilial("GAV") + "' AND GAV.D_E_L_E_T_ <> '*' AND GAV.GAV_CODLOC = GB1.GB1_CODLOC AND GAV.GAV_QUARTO = GB1.GB1_QUARTO "
 cSQL += " 																																							AND GAV.GAV_LEITO = GB1.GB1_LEITO AND GAV.GAV_ESTATI = '1' "   
 If nUTI == 1 //Nao
  cSQL += " 																																						AND GAV.GAV_TIPO <> '4' "     
 EndIf
 cSQL += " JOIN " + RetSQLName("GCS") + " GCS ON GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' AND GCS.GCS_CODLOC = GB1.GB1_CODLOC "
 cSQL +=	" JOIN " + RetSQLName("GCW") + " GCW ON GCW.GCW_FILIAL = '" + xFilial("GCW") + "' AND GCW.D_E_L_E_T_ <> '*' AND GCW.GCW_CODCLI = GCY.GCY_CODCLI "
 cSQL += "																																								AND GCW.GCW_CODCLI BETWEEN '" + cCodCli_De + "' AND '" + cCodCli_Ate + "' "
 cSQL += "WHERE GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "
 cSQL += "AND GCY.GCY_TPALTA <> '99' "                   	
 cSQL += "AND GCZ.GCZ_NRSEQG = (SELECT MIN(GCZ_NRSEQG) FROM " + RetSQLName("GCZ") + " GCZ WHERE GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
 cSQL += "                      AND GCZ_REGATE = GCY.GCY_REGATE) "
 cSQL += "AND GB1.R_E_C_N_O_ = (SELECT MIN(GB1.R_E_C_N_O_) FROM " + RetSQLName("GB1") + " GB1 WHERE GB1.GB1_FILIAL = '" + xFilial("GB1") + "' AND GB1.D_E_L_E_T_ <> '*' AND GB1.GB1_REGATE = GCY.GCY_REGATE  ) " 
 cSQL += "ORDER BY " + IIF(nTipRel == 1, "GB1.GB1_CODLOC", "GCW.GCW_CODCLI") 

 cSQL := ChangeQuery(cSQL)
 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")

 DbGoTop()
 If Eof()
  Hs_MsgInf(STR0010, STR0011, STR0012) //"Nenhum dado foi encontrado para a sele็ใo efetuada."###"Aten็ใo"###"Execu็ใo do Relatorio"
  DbCloseArea()
  Return()
 EndIf
  
 While !Eof()                                                                                
  AADD(aVetDados, {IIF(nTipRel == 1, QRY->GB1_CODLOC, QRY->GCW_CODCLI), ;
  																	SUBSTR(IIF(nTipRel == 1, QRY->GCS_NOMLOC, QRY->GCW_DESCLI), 1, 30), ;
  																	QRY->GCY_REGATE, ;
  																	QRY->GB1_QUARTO, ;
  																	QRY->GB1_LEITO, ;
  																	QRY->GB1_DATAE, ;
  																	QRY->GB1_DATAS,;
  																	QRY->GB1_HORAS})
  DbSkip()
 EndDo
 
 FS_MontaM()
 
 SetRegua(Len(aVetDias))

 aSort(aVetDias,,, {|x,y| x[33] < y[33]}) //NOMLOC ou DESCLI

 For nCont := 1 To Len(aVetDias)
  IncRegua()

	 If nLin > nMaxLin
	 	FS_Cabec(cTitulo)
  EndIf
  
  @nLin, 000 PSAY aVetDias[nCont, 33] //NOMLOC/DESCLI
  For nCont1 := 1 To nDiasMes
   @nLin, 032 + (nCont1 - 1)*5 PSAY TRANSFORM(aVetDias[nCont, nCont1], "@E 999")
  Next
  nTotGer += aVetDias[nCont, 34]
  @nLin, 031 + nDiasMes*5 PSAY TRANSFORM(aVetDias[nCont, 34], "@E 99,999") //Total Setor/Clinica
  nTotPac := FS_TotPac(aVetDias[nCont, 32])
  nTotGPac += nTotPac
  @nLin, 042 + nDiasMes*5 PSAY TRANSFORM(nTotPac, "@E 99,999") //Total Pacientes
  @nLin, 049 + nDiasMes*5 PSAY TRANSFORM(aVetDias[nCont, 34] / nTotPac, "@E 99,999") //Media Setor/Clinica
  nLin ++
  
 Next
 
 FS_ImpTot()
 
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Emissao do grafico                                               ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 If nGrafico == 2 //SIM
  cQuebra := IIF(nTipRel == 1, STR0007, STR0008) //"Setor"###"Clํnica"
  oGraf   := HsGRAF():NEW(STR0003, STR0013 + cQuebra , "", STR0014, cQuebra, "", aVetGRaf, 1, 1, 0, 0, 2, 17, 6, 6, 25, 20)   //"Pacientes Dias no Perํodo"###"Por "###"Qtd Atendimento"
 EndIf  
 
 SET DEVICE TO SCREEN
 If aReturn[5] == 1
  dbCommitAll()
  SET PRINTER TO
  OurSpool(wnrel)
 EndIf

 MS_FLUSH()
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
ฑฑบFuno    ณFS_MontaM บ Autor ณ Daniel Peixoto     บ Data ณ  20/06/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Impressao do total                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_MontaM()
Local cCodQuebra := ""
Local nCont      := 0, nDias := 0
Local nPermLei   := GETMV("MV_PERMLEI")
Local dDataS     := CTOD(""), dDataE := CTOD("")
Local nPos:=0

For nCont := 1 To Len(aVetDados) 
	If cCodQuebra <> aVetDados[nCont, 1] 
		If !Empty(cCodQuebra)
			aAdd(aVetGRaf, {aVetDias[Len(aVetDias), 34], ALLTRIM(aVetDias[Len(aVetDias), 32]) + "-" + aVetDias[Len(aVetDias), 33]}) 
		EndIf 
		cCodQuebra := aVetDados[nCont, 1]
		AADD(aVetDias, {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, aVetDados[nCont, 1], aVetDados[nCont, 2], 0})
	Endif
  
dDataE := IIF(STOD(aVetDados[nCont, 6]) < STOD(cAnoMes + "01"), STOD(cAnoMes + "01"), STOD(aVetDados[nCont, 6]))
    
	If !EMPTY(aVetDados[nCont, 7])
		dDataS := IIF(aVetDados[nCont, 7] > cLimDataE, STOD(cLimDataE), STOD(aVetDados[nCont, 7]))
	Else 
		If cAnoMes < SUBSTR(DTOS(dDataBase), 1, 6)
			dDataS := LastDay(STOD(cAnoMes+"01"))
		Else
		dDataS := dDataBase
		EndIf   
	EndIf 
 
	If dDataE == dDataS //Se entrou e saiu mesmo dia sempre contar 1, independente do perํodo dura็ใo
		FS_SomaDia(dDataE)
	Else
		dDataAtu := dDataE 
		For nDias := 1 To (dDataS - dDataE)
			FS_SomaDia(dDataAtu)
			dDataAtu ++
		Next                           
		If Empty(aVetDados[nCont, 8]) .Or. (nConsDataS == 2 .And. SubHoras(aVetDados[nCont, 8], 0) >= nPermLei) //Considera Dt Saida
			FS_SomaDia(dDataS)
		EndIf
	EndIf 

Next

	If  nPos :=   aScan(aVetGraf,{|x| x[2] $ cCodQuebra}) == 0    
		If !Empty(cCodQuebra)
			aAdd(aVetGRaf, {aVetDias[Len(aVetDias), 34], ALLTRIM(aVetDias[Len(aVetDias), 32]) + "-" + aVetDias[Len(aVetDias), 33]}) 
		Endif
	Endif				

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณFS_ImpTot บ Autor ณ Daniel Peixoto     บ Data ณ  30/06/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Impressao do total                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_ImpTot()

Local nContCol  := 0
Local nContLin  := 0
Local nTotDia   := 0 

 nLin ++
 @nLin, 000 PSAY STR0015 //"M้dia Pacientes Dia"
 For nContCol := 1 To nDiasMes 
  For nContLin := 1 To Len(aVetDias)
   nTotDia += aVetDias[nContLin, nContCol]
  Next
  @nLin, 032 + (nContCol - 1) * 5 PSAY TRANSFORM(nTotDia / Len(aVetDias), "@E 999")
  nTotDia := 0
 Next 
 @nLin, 031 + nDiasMes * 5 PSAY TRANSFORM(nTotGer / Len(aVetDias), "@E 99,999")
 @nLin, 042 + nDiasMes * 5 PSAY TRANSFORM(nTotGPac / Len(aVetDias), "@E 99,999")

Return()

Static Function FS_SomaDia(dData)

 aVetDias[Len(aVetDias), DAY(dData)] ++
 aVetDias[Len(aVetDias), 34] ++

Return(Nil)

Function HS_VldR47()
 Local lRet := .T.
 
 If ReadVar() == "MV_PAR02"
  If !(lRet := Substr(MV_PAR02, 1, 2) $ "01/02/03/04/05/06/07/08/09/10/11/12")
   HS_MsgInf(STR0016, STR0011, STR0017) //"Mes/Ano referencia invalido"###"Aten็ใo"###"Mes/Ano Refer๊ncia"
  ElseIf !(lRet := Substr(MV_PAR02, 4, 4) + Substr(MV_PAR02, 1, 2) <= Substr(DTOS(DDATABASE), 1, 6) )
   HS_MsgInf(STR0018, STR0011, STR0017) //"Mes/Ano referencia nใo pode ser maior que o m๊s da database."###"Aten็ใo"###"Mes/Ano Refer๊ncia"
  Endif
 EndIf
 
Return(lRet)

Static Function FS_TotPac(cCodQuebra)
 Local nQtdPac := 0
 Local cSQL    := ""
 
 cSQL := "SELECT COUNT(DISTINCT(GCY.GCY_REGGER)) TOTREGGER "
 cSQL += " FROM " + RetSQLName("GCY") + " GCY "             
 cSQL += " JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GB1") + " GB1 ON GB1.GB1_FILIAL = '" + xFilial("GB1") + "' AND GB1.D_E_L_E_T_ <> '*' AND GB1.GB1_REGATE = GCY.GCY_REGATE " 
 cLimDataE := IIF(cAnoMes < Substr(DTOS(DDATABASE), 1, 6), DTOS(LastDay(STOD(cAnoMes+"01"))),  DTOS(DDATABASE))
 cSQL += "                                      AND GB1.GB1_DATAE <= '" + cLimDataE + "' "
 cSQL += "                                      AND (GB1.GB1_DATAS >= '" + cAnoMes + "01"  + "' OR GB1.GB1_DATAS = '" + SPACE(8) + "') "
 If nTipRel == 1 //Setor
  cSQL += " 																																				AND GB1.GB1_CODLOC = '" + cCodQuebra + "' "  
 EndIf
 cSQL += " JOIN " + RetSQLName("GAV") + " GAV ON GAV.GAV_FILIAL = '" + xFilial("GAV") + "' AND GAV.D_E_L_E_T_ <> '*' AND GAV.GAV_CODLOC = GB1.GB1_CODLOC AND GAV.GAV_QUARTO = GB1.GB1_QUARTO "
 cSQL += " 																																							AND GAV.GAV_LEITO = GB1.GB1_LEITO AND GAV.GAV_ESTATI = '1' "   
 If nUTI == 1 //Nao
  cSQL += " 																																						AND GAV.GAV_TIPO <> '4' "     
 EndIf
 If nTipRel == 2 //Clinica
  cSQL +=	" JOIN " + RetSQLName("GCW") + " GCW ON GCW.GCW_FILIAL = '" + xFilial("GCW") + "' AND GCW.D_E_L_E_T_ <> '*' AND GCW.GCW_CODCLI = GCY.GCY_CODCLI "
  cSQL += "																																								AND GCW.GCW_CODCLI = '" + cCodQuebra + "' "
 EndIf
 cSQL += "WHERE GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' "
 cSQL += "AND GCY.GCY_TPALTA <> '99' "
 cSQL += "AND GCZ.GCZ_NRSEQG = (SELECT MIN(GCZ_NRSEQG) FROM " + RetSQLName("GCZ") + " GCZ WHERE GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
 cSQL += "                      AND GCZ_REGATE = GCY.GCY_REGATE) "
 cSQL += "AND GB1.R_E_C_N_O_ = (SELECT MIN(GB1.R_E_C_N_O_) FROM " + RetSQLName("GB1") + " GB1 WHERE GB1.GB1_FILIAL = '" + xFilial("GB1") + "' AND GB1.D_E_L_E_T_ <> '*' AND GB1.GB1_REGATE = GCY.GCY_REGATE  ) " 
 
 cSQL := ChangeQuery(cSQL)
 TCQUERY cSQL NEW ALIAS "QRYPAC"
 DbSelectArea("QRYPAC")

 nQtdPac := QRYPAC->TOTREGGER
  
 DbCloseArea()

Return(nQtdPac)
