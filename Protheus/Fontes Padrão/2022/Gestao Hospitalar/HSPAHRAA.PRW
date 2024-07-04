#INCLUDE "HSPAHRAA.ch"
#INCLUDE "protheus.ch"
#INCLUDE "TOPCONN.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHRAA  º Autor ³ Alessandro Freire  º Data ³  17/04/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de Faturas por Lote / Remessa                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
                            
Function HSPAHRAA()

 Private cDesc1      := STR0001 //"Este programa tem como objetivo imprimir relatorio "
 Private cDesc2      := STR0002 //"de acordo com os parametros informados pelo usuario."
 Private cDesc3      := STR0003 //"Faturas por Lote / Remessa"
 Private titulo      := STR0003 //"Faturas por Lote / Remessa"
 Private Cabec1      := ""
 Private Cabec2      := "" //"         Despesa          Descricao                                          Quantidade       Vlr.Unitario       Valor Total"
 Private imprime     := .T.
 Private m_pag       := 01
 Private aOrd        := {}
 
 Private lEnd        := .F.
 Private lAbortPrint := .F.
 Private limite      := 132
 Private tamanho     := "M"
 Private nomeprog    := "HSPAHRAA"
 Private nTipo       := 15
 Private aReturn     := { STR0004, 1, STR0005, 1, 2, 1, "", 1} //"Zebrado"###"Administracao"
 Private nLastKey    := 0
 Private cPerg       := PADR("HSPRAA", Len(SX1->X1_GRUPO)) 
 Private cbtxt       := Space(10)
 Private cbcont      := 00
 Private CONTFL      := 01
 Private wnrel       := "HSPAHRAA"
 Private cString     := "GCZ"
 Private cE1Prefixo  := ALLTRIM(GetMV("MV_HSPSERIE")) + "/" + ALLTRIM(GetMV("MV_PREFCRH"))
 Private lAtrbAuto	  := .t. // nao retire esta variavel - utilizada na hs_fillote() na consulta padrao GAT
 Private cCODIMP     := ""
 Private nMaxLin     := 0 // quantidade maxima de linhas p/ impressao
 Private oFont1      := TFont():New( "Courier New", , 09, , .T., , , , , .F. ) //Conteudo dos Campos
 Private oFont2      := TFont():New( "Courier New", , 09, , .F., , , , , .F. ) //Conteudo dos Campos em Negrito
 Private lCabec      := .T.
 Private nLinI       := 0
 Private nLinF       := 260
 Private cCodCon     := ""
 Private cCodPla_De  := ""
 Private cCodPla_Ate := ""
 Private cCodLoc_De  := ""
 Private cCodLoc_Ate := ""
 Private cNrLote     := ""
 Private cNumPro     := ""
 Private cNrFatu     := ""
 Private dDatAte_De  := ""
 Private dDatAte_Ate := ""
 Private nTipRel     := 0
 Private lTamProd := IIf((TamSx3("GD5_CODDES")[1])<=15, .T., .F.) 
 
 
 
 If !Pergunte(cPerg,.T.)
  Return()
 EndIf
 Cabec2:= IIF(lTamProd,STR0011,STR0025)
 
 cCodImp := MV_PAR14
 nMaxLin := HS_MaxLin(cCODIMP)
 nLin := nMaxLin * 2

 If EMPTY(AllTrim(MV_PAR01))
  HS_MsgInf(STR0006, STR0007, STR0020) //"Preencha o parametro Convenio"###"Atencao"###"Parametro Vazio"
  Return()
 EndIf

 lIpmGraf := MV_PAR13 == 1
  
 If lIpmGraf
	 nTipRel := mv_par11
  Cabec2  := STR0021 //"Despesa         Descricao                                          Quantidade   Vlr.Unitario   Valor Total"
	 If nTipRel == 1   //Sintetico
	  Cabec1     := STR0022 //"Atendimento                                Matricula                 Guia Pront. Dt/Hr.Atendim. Titulo          Total"
	  Cabec2     := ""
	 Else
	  Cabec1     := STR0023 //"Atendimento                                Matricula                 Guia Pront. Dt/Hr.Atendim. Titulo" 
	 EndIf
	 
	 RptStatus({|| RotImp(Cabec1,Cabec2,Titulo,nMaxLin) },Titulo)
 Else
	 wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.F.)
	 	 
	 If nLastKey == 27
	  Return()
	 EndIf
	
	 SetDefault(aReturn,cString) 
	 
	 If nLastKey == 27
	  Return()
	 EndIf
	
	 nTipo := If(aReturn[4]==1,15,18)
	 RptStatus({|| RunReport(Cabec1,Cabec2,Titulo) },Titulo)
EndIf
 
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ AP6 IDE            º Data ³  17/04/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RunReport(Cabec1,Cabec2,Titulo)
 Local cQry       := ""
 Local cSel       := ""
 Local cFrom      := ""
 Local cCond      := ""
 Local nGatItens  := 0
 Local nQtdGuiasR := 0 
 
 Private cCodCon     := ""
 Private cCodPla_De  := ""
 Private cCodPla_Ate := ""
 Private cCodLoc_De  := ""
 Private cCodLoc_Ate := ""
 Private cNrLote     := ""
 Private cNumPro     := ""
 Private cNrFatu     := ""
 Private dDatAte_De  := ""
 Private dDatAte_Ate := ""
 Private nTipRel     := 0
 Private nOrdem      := 0
 Private cNrSeqG     := ""

 Private nTotGE5_Guia := 0, nTotGE6_Guia := 0, nTotGE7_Guia := 0, nTotal_Guia  := 0
 Private nTotGE5_Lote := 0, nTotGE6_Lote := 0, nTotGE7_Lote := 0, nTotal_Lote  := 0
 Private cCODDES := ""

 cCodCon     := mv_par01
 cCodLoc_De  := mv_par02
 cCodLoc_Ate := mv_par03
 cCodPla_De  := mv_par04
 cCodPla_Ate := mv_par05
 cNrLote     := mv_par06
 cNumPro     := mv_par07
 cNrFatu     := mv_par08
 dDatAte_De  := mv_par09
 dDatAte_Ate := mv_par10
 nTipRel     := mv_par11
 nOrdem      := mv_par12
 
 If nTipRel == 1   //Sintetico
 																							//"          1         2         3         4         5         6         7         8         9         10        11        12        13
 																							//"0123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789.123456789
  Cabec1     := STR0016	//"Atendimento                                           Matricula                 Guia   Pront. Dt/Hr.Atendim. Titulo          Total"
  Cabec2     := ""
 Else
  Cabec1     := STR0017 //"Atendimento                                           Matricula                 Guia   Pront. Dt/Hr.Atendim. Titulo"
 EndIf
    
 cSel := "GCZ.GCZ_REGGER REGGER, GCZ.GCZ_REGATE REGATE, GCZ.GCZ_DATATE DATATE, GCZ.GCZ_CODCON CODCON, GCZ.GCZ_NRLOTE NRLOTE, GCZ.GCZ_NRFATU NRFATU, GCZ.GCZ_NRSEN1 NRSEN1, GCZ.GCZ_NRSEQG NRSEQG, "
 cSel += "GAT.GAT_NUMPRO NUMPRO, GCY.GCY_HORATE HORATE, GCY.GCY_NOME NOME, GD4.GD4_MATRIC MATRIC, GCZ.GCZ_NRGUIA NRGUIA, "

 cFrom := "FROM " + RetSqlName("GCZ") + " GCZ "
 cFrom += "JOIN " + RetSqlName("GD4") + " GD4 ON GD4.GD4_FILIAL = " + HS_xFilFat("GD4") + " AND GD4.D_E_L_E_T_ <> '*' AND GD4.GD4_REGGER = GCZ.GCZ_REGGER AND GD4.GD4_CODCON = GCZ.GCZ_CODCON AND GD4.GD4_CODPLA = GCZ.GCZ_CODPLA "
 cFrom += "JOIN " + RetSqlName("GAT") + " GAT ON GAT.GAT_FILIAL = GCZ.GCZ_FILFAT AND GAT.D_E_L_E_T_ <> '*' AND GAT.GAT_NUMLOT = GCZ.GCZ_NRLOTE "
 cFrom += "JOIN " + RetSqlName("GCY") + " GCY ON GCY.GCY_FILIAL = " + HS_xFilFat("GCY") + " AND GCY.D_E_L_E_T_ <> '*' AND GCY.GCY_REGATE = GCZ.GCZ_REGATE "
 
 cCond := "WHERE GCZ.GCZ_FILFAT = '" + cFilAnt + "' AND GCZ.D_E_L_E_T_ <> '*' "
 
 If !Empty(cCodCon)
  cCond += "AND GCZ.GCZ_CODCON = '" + cCodCon + "' "
 EndIf

 If !Empty(cNrFatu)
  cCond += "AND GCZ.GCZ_NRFATU = '" + cNrFatu + "' " 
 EndIf
 
 If !Empty(cNrLote)
  cCond += "AND GCZ.GCZ_NRLOTE = '" + cNrLote + "' "
 Else
  cCond += "AND GCZ.GCZ_NRLOTE <> '" + SPACE(LEN(GCZ->GCZ_NRLOTE)) + "' "
 EndIf

 If !Empty(dDatAte_De)
  cCond += "AND GCZ.GCZ_DATATE >= '" + DTOS(dDatAte_De) + "' "
 EndIf 
 If !Empty(dDatAte_Ate)
  cCond += "AND GCZ.GCZ_DATATE <= '" + DTOS(dDatAte_Ate) + "' "
 EndIf 

 If !Empty(cCodPla_De)
  cCond += "AND GCZ.GCZ_CODPLA >= '" + cCodPla_De + "' "
 EndIf
 If !Empty(cCodPla_Ate)
  cCond += "AND GCZ.GCZ_CODPLA <= '" + cCodPla_Ate + "' "  
 EndIf
 
 IF !Empty(cNumPro)
  cCond += "AND GAT.GAT_NUMPRO = '" + cNumPro + "' "
 EndIf

 cQry := "SELECT '1' TIPO, " + cSel    // -- Mat/Med 
 cQry += HS_FValDes("GE5") + " VALTOT, GE5.GE5_CODDES CODDES, GE5.GE5_VALDES VALDES, GE5.GE5_QTDDES QTDDES, SB1.B1_DESC DESCR "
 cQry += cFROM
 cQry += "JOIN " + RetSqlName("GE5") + " GE5 ON GE5.GE5_FILIAL = " + HS_xFilFat("GE5") + " AND GE5.D_E_L_E_T_ <> '*' "
 cQry += "AND GE5.GE5_NRSEQG = GCZ.GCZ_NRSEQG AND GE5.GE5_GLODES = '0' "
 If !Empty(cCodLoc_De)                   	
  cQry += "AND GE5.GE5_CODLOC >= '" + cCodLoC_De + "' " 
 EndIf 
 If !Empty(cCodLoc_Ate)
  cQry += "AND GE5.GE5_CODLOC <= '" + cCodLoC_Ate + "' " 
 EndIf 
	cQry += "JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_FILIAL  = " + HS_xFilFat("SB1") + " AND SB1.D_E_L_E_T_ <> '*' AND GE5.GE5_CODDES = B1_COD "
	cQry += cCond
	   
 cQry += "UNION ALL "
 cQry += "SELECT '2' TIPO, " + cSel    // -- Tax/Dia
	cQry += HS_FValDes("GE6") + " VALTOT, GE6.GE6_CODDES CODDES, GE6.GE6_VALDES VALDES, GE6.GE6_QTDDES QTDDES, GAA.GAA_DESC DESCR "
 cQry += cFrom
 cQry += "JOIN " + RetSqlName("GE6") + " GE6 ON GE6.GE6_FILIAL = " + HS_xFilFat("GE6") + " AND GE6.D_E_L_E_T_ <> '*' "
 cQry += "AND GE6.GE6_NRSEQG = GCZ.GCZ_NRSEQG AND GE6.GE6_GLODES = '0' "
 If !Empty(cCodLoc_De)
  cQry += "AND GE6.GE6_CODLOC >= '" + cCodLoC_De + "' " 
 EndIf 
 If !Empty(cCodLoc_Ate)
  cQry += "AND GE6.GE6_CODLOC <= '" + cCodLoC_Ate + "' " 
 EndIf 
	cQry += "JOIN " + RetSqlName("GAA") + " GAA ON GAA.GAA_FILIAL = " + HS_xFilFat("GAA") + " AND GAA.D_E_L_E_T_ <> '*' AND GAA.GAA_CODTXD = GE6.GE6_CODDES "  
 cQry += cCond

 cQry += "UNION ALL "
 cQry += "SELECT '3' TIPO, " + cSel    // -- Procedimento 
 cQry += HS_FValDes("GE7") + " VALTOT, GE7.GE7_CODDES CODDES, GE7.GE7_VALDES VALDES, GE7.GE7_QTDDES QTDDES, GA7.GA7_DESC DESCR "
 cQry += cFrom
	cQry += "JOIN " + RetSqlName("GE7") + " GE7 ON GE7.GE7_FILIAL = " + HS_xFilFat("GE7") + " AND GE7.D_E_L_E_T_ <> '*' "
	cQry += "AND GE7.GE7_NRSEQG = GCZ.GCZ_NRSEQG AND GE7.GE7_GLODES = '0' AND GE7.GE7_PGTMED <> '0' "
 If !Empty(cCodLoc_De)
  cQry += "AND GE7.GE7_CODLOC >= '" + cCodLoC_De + "' " 
 EndIf 
 If !Empty(cCodLoc_Ate)
  cQry += "AND GE7.GE7_CODLOC <= '" + cCodLoC_Ate + "' " 
 EndIf 
	cQry += "JOIN " + RetSqlName("GA7") + " GA7 ON GA7.GA7_FILIAL = " + HS_xFilFat("GA7") + " AND GA7.D_E_L_E_T_ <> '*' AND GA7.GA7_CODPRO = GE7.GE7_CODDES " 
 cQry += cCond
 
 If nOrdem == 1 //nome Pac
  cQry += "ORDER BY CODCON, NRLOTE, NOME, REGGER, NRSEQG, TIPO, CODDES"
 ElseIf nOrdem == 2 //data Ate. + Hora
  cQry += "ORDER BY CODCON, NRLOTE, DATATE, HORATE, REGGER, NRSEQG, TIPO, CODDES"
 Else //Nr Atend.
  cQry += "ORDER BY CODCON, NRLOTE, REGATE, REGGER, NRSEQG, TIPO, CODDES"
 EndIf

 cQry := ChangeQuery(cQry)
 
 
 DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TRB",.F.,.T.)
 
 DbSelectArea("TRB")
 SetRegua(RecCount())
 DbGoTop()

 cCodCon := ""
 cNrLote := ""
 cNrSeqG := ""

 While !Eof()

  If lAbortPrint
   @nLin,000 PSAY STR0008 //"*** CANCELADO PELO OPERADOR ***"
   Exit
  EndIf
  
  If TRB->CODCON <> cCodCon .or. TRB->NRLOTE <> cNrLote
   If TRB->CODCON <> cCodCon
    DbSelectArea("GA9")
    DbSetOrder(1)
    DbSeek(xFilial("GA9") + TRB->CODCON)
    cCodCon := TRB->CODCON    
   EndIf 
   FS_Cabec(Cabec1, Cabec2, .T.)
   cNrLote := TRB->NRLOTE
  EndIf
  
  nGatItens := HS_IniPadr("GAT", 1, TRB->NRLOTE, "GAT_ITENS",, .F.)
   
  While !Eof() .and. TRB->CODCON == cCodCon .and. TRB->NRLOTE == cNrLote
      
   If EMPTY(TRB->CODDES)
    DbSelectArea("TRB")
    DbSkip()
    Loop
   EndIf
  
   If nLin+1 > nMaxLin
    FS_Cabec(Cabec1, Cabec2)
   EndIf 
   cNrSeqG   := TRB->NRSEQG
   
   nLin ++   
   @nLin,000 PSAY TRB->REGATE
   @nLin,007 PSAY SubStr(TRB->NOME,1,25)
   @nLin,033 PSAY TRB->MATRIC
/* If nTipRel == 1	//Sintetico
//   		@nLin,059 PSAY TRB->NRGUIA
   		@nLin,060 PSAY TRB->NRSEQG
		@nLin,074 PSAY TRB->REGGER
		@nLin,081 PSAY DTOC( STOD(TRB->DATATE) ) + "-" + TRB->HORATE
		@nLin,097 PSAY TRB->NRSEN1
   Else */
   		@nLin,059 PSAY TRB->NRGUIA
   		@nLin,080 PSAY TRB->NRSEQG
   		@nLin,087 PSAY TRB->REGGER
   		@nLin,094 PSAY DTOC( STOD(TRB->DATATE) ) + "-" + TRB->HORATE
		@nLin,109 PSAY SubStr(ALLTRIM(TRB->NRSEN1),1,9)
 //  EndIf
//   @nLin,087 PSAY TRB->REGGER
//   @nLin,094 PSAY DTOC( STOD(TRB->DATATE) ) + "-" + TRB->HORATE
//   @nLin,109 PSAY TRB->NRSEN1  
//   @nLin,124 PSAY TRB->NRFATU  
   
   nQtdGuiasR += 1
   
   While !Eof() .and. TRB->CODCON == cCodCon .and. TRB->NRLOTE == cNrLote .and. TRB->NRSEQG == cNrSeqG

    If EMPTY(TRB->CODDES)                    
     DbSelectArea("TRB")
     DbSkip()
     Loop
    EndIf  
    
    If nTipRel == 2 //analitico
     If nLin+1 > nMaxLin
      FS_Cabec(Cabec1, Cabec2)
     EndIf 
      nLin++
      @nLin,009 PSAY TRB->CODDES
      @nLin,IIF(lTamProd,026,042) PSAY TRB->DESCR
      @nLin,077 PSAY TRANSFORM(TRB->QTDDES, "@E 999,999.99")
      @nLin,093 PSAY TRANSFORM(TRB->VALDES, "@E 9999,999.9999") 
      @nLin,111 PSAY TRANSFORM(TRB->VALTOT, "@E 99,999,999.99")
      cCODDES := TRB->CODDES
    EndIf 
    nTotGE5_Guia += IIF(TRB->TIPO == '1', TRB->VALTOT, 0)
    nTotGE6_Guia += IIF(TRB->TIPO == '2', TRB->VALTOT, 0)
    nTotGE7_Guia += IIF(TRB->TIPO == '3', TRB->VALTOT, 0)
    
    DbSelectArea("TRB")
    DbSkip()
   End	
   nTotal_Guia := nTotGE5_Guia +  nTotGE6_Guia + nTotGE7_Guia
    
   If nTipRel == 1  //Sintetico
    @nLin,117 PSAY TRANSFORM(nTotal_Guia, "@E 99,999,999.99")
   Else  //analitico
    If nLin+2 > nMaxLin
     FS_Cabec(Cabec1, Cabec2)
    EndIf
    nLin += 1
    @nLin,004 PSAY "==>"
    @nLin,009 PSAY STR0013 //"Mat/Med:"
    @nLin,018 PSAY TRANSFORM(nTotGE5_Guia,  "@E 99,999,999.99")
    @nLin,035 PSAY STR0014  //"Taxas/Diarias:"
    @nLin,050 PSAY TRANSFORM(nTotGE6_Guia,  "@E 99,999,999.99")    
    @nLin,070 PSAY STR0015 //"Procedimentos:"
    @nLin,086 PSAY TRANSFORM(nTotGE7_Guia,  "@E 99,999,999.99")    
    @nLin,104 PSAY STR0012  //"Total:"
    @nLin,111 PSAY TRANSFORM(nTotal_Guia, "@E 99,999,999.99")
    nLin += 1
   EndIf  
    nTotGE5_Lote += nTotGE5_Guia
    nTotGE6_Lote += nTotGE6_Guia
    nTotGE7_Lote += nTotGE7_Guia
    nTotGE5_Guia := 0
    nTotGE6_Guia := 0
    nTotGE7_Guia := 0
  End
  
  If nLin+7 > nMaxLin
   FS_Cabec(Cabec1, Cabec2)
  EndIf
  nLin += 2
  nTotal_Lote := nTotGE5_Lote +  nTotGE6_Lote + nTotGE7_Lote
  @nLin,088 PSAY STR0013 //"Mat/Med:"
  @nLin,114 PSAY TRANSFORM(nTotGE5_Lote, "@E 99,999,999.99")  
  nLin += 1
  @nLin,088 PSAY STR0014  //"Taxas/Diarias:"
  @nLin,114 PSAY TRANSFORM(nTotGE6_Lote, "@E 99,999,999.99")    
  nLin += 1
  @nLin,088 PSAY STR0015 //"Procedimentos:"
  @nLin,114 PSAY TRANSFORM(nTotGE7_Lote, "@E 99,999,999.99")    
  nLin += 1
  @nLin,088 PSAY STR0012 //"Total:"
  @nLin,114 PSAY TRANSFORM(nTotal_Lote, "@E 99,999,999.99")
  nLin += 1
  @nLin,088 PSAY STR0018 //"	Total de guias:"
  @nLin,120 PSAY TRANSFORM(nGatItens, "@E 999,999")
  nLin += 1
  @nLin,088 PSAY STR0019 //"Total de guias consideradas: "
  @nLin,120 PSAY TRANSFORM(nQtdGuiasR, "@E 999,999")
  nTotGE5_Lote := 0
  nTotGE6_Lote := 0
  nTotGE7_Lote := 0
  nQtdGuiasR   := 0
  cCODDES := ""
  
 End 
  
 SET DEVICE TO SCREEN
 If aReturn[5] == 1
  DbCommitAll()
  SET PRINTER TO
  OurSpool(wnrel)
 EndIf
 MS_FLUSH()

 DbSelectArea("TRB")
 DbCloseArea()
Return()
                                                
Function FS_VldCon()
 Local lRet := .T.

 If Empty(MV_PAR01)
  HS_MsgInf(STR0006, STR0007, STR0020) //"Preencha o parametro Convenio"###"Atencao"###"Parametro Vazio"
  lRet := .F.
 EndIf   

Return(lRet)

Static Function FS_Cabec(Cabec1, Cabec2, lQuebra)
 Default lQuebra := .F.

 Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
 nLin := IIF(nTipRel == 1, 7, 8)
 If lQuebra
  nLin += 1
  @nLin,000 PSAY STR0009 + TRB->CODCON + "-" + GA9->GA9_NREDUZ                //"Convenio: "
  @nLin,040 PSAY STR0010 + ALLTRIM(TRB->NRLOTE) + "/" + ALLTRIM(TRB->NUMPRO)  //"Lote/Processo: "
  @nLin,080 PSAY STR0024 + TRB->NRFATU  //"Numero do Titulo: "
  nLin += 1
 EndIf
Return()

Static Function RotImp(Cabec1,Cabec2,Titulo,nMaxLin)

 /*
 Definicao de fontes
 nome/larg/alt/fromuser/bold/italic/underline/
 oFont1 	  	:= TFont():New("Arial"      	    ,10,09,,.F.,,,,,.F.) //
 oFont2   		:= TFont():New("Arial"      	    ,09,10,,.F.,,,,,.F.) //Conteudo dos Campos
 oFont3Bold	:= TFont():New("Arial Black"	    ,09,15,,.T.,,,,,.F.) //Nome do Banco
 oFont4 	  	:= TFont():New("Arial"      	    ,09,12,,.T.,,,,,.F.) //Dados do Recibo de Entrega
 oFont5 		  := TFont():New("Arial"      	    ,09,18,,.T.,,,,,.F.) //Codigo de Compensação do Banco
 oFont6 		  := TFont():New("Arial"      	    ,09,14,,.T.,,,,,.F.) //Codigo de Compensação do Banco
 oFont7 		  := TFont():New("Arial"           ,09,10,,.T.,,,,,.F.) //Conteudo dos Campos em Negrito
 oFont8 		  := TFont():New("Arial"           ,09,09,,.F.,,,,,.F.) //Dados do Cliente
 oFont9 		  := TFont():New("Times New Roman" ,09,14,,.T.,,,,,.F.) //Linha Digitavel
 oFont10		  := TFont():New("Times New Roman" ,09,12,,.T.,,,,,.F.) //Linha Digitavel
 */
 
 Local cQry       := ""
 Local cSel       := ""
 Local cFrom      := ""
 Local cCond      := ""
 Local nGatItens  := 0
 Local nQtdGuiasR := 0 
  
 Private oFont1 := TFont():New( "Courier New", , 09, , .T., , , , , .F. ) //Conteudo dos Campos
 Private oFont2 := TFont():New( "Courier New", , 09, , .T., , , , , .F. ) //Conteudo dos Campos em Negrito
 Private lCabec := .T.
 Private nLinI  := 0
 Private nLinF  := 260
 Private cCodCon     := ""
 Private cCodPla_De  := ""
 Private cCodPla_Ate := ""
 Private cCodLoc_De  := ""
 Private cCodLoc_Ate := ""
 Private cNrLote     := ""
 Private cNumPro     := ""
 Private cNrFatu     := ""
 Private dDatAte_De  := ""
 Private dDatAte_Ate := ""
 Private nOrdem      := 0
 Private cNrSeqG     := ""
 
 Private nTotGE5_Guia := 0, nTotGE6_Guia := 0, nTotGE7_Guia := 0, nTotal_Guia  := 0
 Private nTotGE5_Lote := 0, nTotGE6_Lote := 0, nTotGE7_Lote := 0, nTotal_Lote  := 0
 Private cCODDES := ""
 Private cConteudo := ""
 
 cCodCon     := mv_par01
 cCodLoc_De  := mv_par02
 cCodLoc_Ate := mv_par03
 cCodPla_De  := mv_par04
 cCodPla_Ate := mv_par05
 cNrLote     := mv_par06
 cNumPro     := mv_par07
 cNrFatu     := mv_par08
 dDatAte_De  := mv_par09
 dDatAte_Ate := mv_par10
 nOrdem      := mv_par12
  
     
 cSel := "GCZ.GCZ_REGGER REGGER, GCZ.GCZ_REGATE REGATE, GCZ.GCZ_DATATE DATATE, GCZ.GCZ_CODCON CODCON, GCZ.GCZ_NRLOTE NRLOTE, GCZ.GCZ_NRFATU NRFATU, GCZ.GCZ_NRSEN1 NRSEN1, GCZ.GCZ_NRSEQG NRSEQG, "
 cSel += "GAT.GAT_NUMPRO NUMPRO, GCY.GCY_HORATE HORATE, GCY.GCY_NOME NOME, GD4.GD4_MATRIC MATRIC, GCZ.GCZ_NRGUIA NRGUIA, "

 cFrom := "FROM " + RetSqlName("GCZ") + " GCZ "
 cFrom += "JOIN " + RetSqlName("GD4") + " GD4 ON GD4.GD4_FILIAL = " + HS_xFilFat("GD4") + " AND GD4.D_E_L_E_T_ <> '*' AND GD4.GD4_REGGER = GCZ.GCZ_REGGER AND GD4.GD4_CODCON = GCZ.GCZ_CODCON AND GD4.GD4_CODPLA = GCZ.GCZ_CODPLA "
 cFrom += "JOIN " + RetSqlName("GAT") + " GAT ON GAT.GAT_FILIAL = GCZ.GCZ_FILFAT AND GAT.D_E_L_E_T_ <> '*' AND GAT.GAT_NUMLOT = GCZ.GCZ_NRLOTE "
 cFrom += "JOIN " + RetSqlName("GCY") + " GCY ON GCY.GCY_FILIAL = " + HS_xFilFat("GCY") + " AND GCY.D_E_L_E_T_ <> '*' AND GCY.GCY_REGATE = GCZ.GCZ_REGATE "
  
 cCond := "WHERE GCZ.GCZ_FILFAT = '" + cFilAnt + "' AND GCZ.D_E_L_E_T_ <> '*' "
 
 If !Empty(cCodCon)
  cCond += "AND GCZ.GCZ_CODCON = '" + cCodCon + "' "
 EndIf
 
 If !Empty(cNrFatu)
  cCond += "AND GCZ.GCZ_NRFATU = '" + cNrFatu + "' " 
 EndIf
 
 If !Empty(cNrLote)
  cCond += "AND GCZ.GCZ_NRLOTE = '" + cNrLote + "' "
 Else
  cCond += "AND GCZ.GCZ_NRLOTE <> '" + SPACE(LEN(GCZ->GCZ_NRLOTE)) + "' "
 EndIf
 
 If !Empty(dDatAte_De)
  cCond += "AND GCZ.GCZ_DATATE >= '" + DTOS(dDatAte_De) + "' "
 EndIf 
 If !Empty(dDatAte_Ate)
  cCond += "AND GCZ.GCZ_DATATE <= '" + DTOS(dDatAte_Ate) + "' "
 EndIf 

 If !Empty(cCodPla_De)
  cCond += "AND GCZ.GCZ_CODPLA >= '" + cCodPla_De + "' "
 EndIf
 If !Empty(cCodPla_Ate)
  cCond += "AND GCZ.GCZ_CODPLA <= '" + cCodPla_Ate + "' "  
 EndIf
  
 If !Empty(cNumPro)
  cCond += "AND GAT.GAT_NUMPRO = '" + cNumPro + "' "
 EndIf

 cQry := "SELECT '1' TIPO, " + cSel    // -- Mat/Med 
 cQry += HS_FValDes("GE5") + " VALTOT, GE5.GE5_CODDES CODDES, GE5.GE5_VALDES VALDES, GE5.GE5_QTDDES QTDDES, SB1.B1_DESC DESCR "
 cQry += cFROM
 cQry += "JOIN " + RetSqlName("GE5") + " GE5 ON GE5.GE5_FILIAL = " + HS_xFilFat("GE5") + " AND GE5.D_E_L_E_T_ <> '*' "
 cQry += "AND GE5.GE5_NRSEQG = GCZ.GCZ_NRSEQG AND GE5.GE5_GLODES = '0' "
 If !Empty(cCodLoc_De)                   	
  cQry += "AND GE5.GE5_CODLOC >= '" + cCodLoC_De + "' " 
 EndIf 
 If !Empty(cCodLoc_Ate)
  cQry += "AND GE5.GE5_CODLOC <= '" + cCodLoC_Ate + "' " 
 EndIf 
 cQry += "JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_FILIAL  = " + HS_xFilFat("SB1") + " AND SB1.D_E_L_E_T_ <> '*' AND GE5.GE5_CODDES = B1_COD "
 cQry += cCond
 	   
 cQry += "UNION ALL "
 cQry += "SELECT '2' TIPO, " + cSel    // -- Tax/Dia
 cQry += HS_FValDes("GE6") + " VALTOT, GE6.GE6_CODDES CODDES, GE6.GE6_VALDES VALDES, GE6.GE6_QTDDES QTDDES, GAA.GAA_DESC DESCR "
 cQry += cFrom
 cQry += "JOIN " + RetSqlName("GE6") + " GE6 ON GE6.GE6_FILIAL = " + HS_xFilFat("GE6") + " AND GE6.D_E_L_E_T_ <> '*' "
 cQry += "AND GE6.GE6_NRSEQG = GCZ.GCZ_NRSEQG AND GE6.GE6_GLODES = '0' "
 If !Empty(cCodLoc_De)
  cQry += "AND GE6.GE6_CODLOC >= '" + cCodLoC_De + "' " 
 EndIf 
 If !Empty(cCodLoc_Ate)
  cQry += "AND GE6.GE6_CODLOC <= '" + cCodLoC_Ate + "' " 
 EndIf 
 cQry += "JOIN " + RetSqlName("GAA") + " GAA ON GAA.GAA_FILIAL = " + HS_xFilFat("GAA") + " AND GAA.D_E_L_E_T_ <> '*' AND GAA.GAA_CODTXD = GE6.GE6_CODDES "  
 cQry += cCond
 
 cQry += "UNION ALL "
 cQry += "SELECT '3' TIPO, " + cSel    // -- Procedimento 
 cQry += HS_FValDes("GE7") + " VALTOT, GE7.GE7_CODDES CODDES, GE7.GE7_VALDES VALDES, GE7.GE7_QTDDES QTDDES, GA7.GA7_DESC DESCR "
 cQry += cFrom
 cQry += "JOIN " + RetSqlName("GE7") + " GE7 ON GE7.GE7_FILIAL = " + HS_xFilFat("GE7") + " AND GE7.D_E_L_E_T_ <> '*' "
 cQry += "AND GE7.GE7_NRSEQG = GCZ.GCZ_NRSEQG AND GE7.GE7_GLODES = '0' AND GE7.GE7_PGTMED <> '0' "
 If !Empty(cCodLoc_De)
  cQry += "AND GE7.GE7_CODLOC >= '" + cCodLoC_De + "' " 
 EndIf 
 If !Empty(cCodLoc_Ate)
  cQry += "AND GE7.GE7_CODLOC <= '" + cCodLoC_Ate + "' " 
 EndIf 
 cQry += "JOIN " + RetSqlName("GA7") + " GA7 ON GA7.GA7_FILIAL = " + HS_xFilFat("GA7") + " AND GA7.D_E_L_E_T_ <> '*' AND GA7.GA7_CODPRO = GE7.GE7_CODDES " 
 cQry += cCond
 
 If nOrdem == 1 //nome Pac
    cQry += "ORDER BY CODCON, NRLOTE, NOME, REGGER, NRSEQG, TIPO, CODDES"
 ElseIf nOrdem == 2 //data Ate. + Hora
    cQry += "ORDER BY CODCON, NRLOTE, DATATE, HORATE, REGGER, NRSEQG, TIPO, CODDES"
 Else //Nr Atend.
    cQry += "ORDER BY CODCON, NRLOTE, REGATE, REGGER, NRSEQG, TIPO, CODDES"
 EndIf
 
  
 DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TRB",.F.,.T.)
 
 DbSelectArea("TRB")
 SetRegua(RecCount())
 DbGoTop()

 cCodCon := ""
 cNrLote := ""
 cNrSeqG := ""

 oPrn:=TMSPrinter():New() 
 oPrn:Setup() 

 oPrn:StartPage()                            // Inicio Impressao Grafica
 lCabec := .F.
 lPrimPag := .T.
 While !Eof()
 	
	 If lAbortPrint
 		@ nLinI,010 PSAY STR0008 //"*** CANCELADO PELO OPERADOR ***"
 		Exit
 	EndIf
 
  If TRB->CODCON <> cCodCon .or. TRB->NRLOTE <> cNrLote
   If TRB->CODCON <> cCodCon
    DbSelectArea("GA9")
  		DbSetOrder(1)
  		DbSeek(xFilial("GA9") + TRB->CODCON)
  		cCodCon := TRB->CODCON    
  		
 			If lPrimPag
 				EmiCab()
 				lPrimPag := .F.
 				nLinI+=050
 				nLinF+=050
 			Else
 	  	lCabec := .T.
 	  	EmiCab()
 			EndIf
    	
   EndIf 
 
   cNrLote := TRB->NRLOTE
    	
  EndIf
   
  nGatItens := HS_IniPadr("GAT", 1, TRB->NRLOTE, "GAT_ITENS",, .F.)
    
  While !Eof() .and. TRB->CODCON == cCodCon .and. TRB->NRLOTE == cNrLote
       
  	If EMPTY(TRB->CODDES)
 	  DbSelectArea("TRB")
 	  DbSkip()
 	  Loop
 	 EndIf
 	  
  	If nLinI >= 2945
  		lCabec := .T.
  		EmiCab()     
   EndIf
 
 	 cNrSeqG   := TRB->NRSEQG
 	   
 	 cConteudo := TRB->REGATE + " " + SubStr(TRB->NOME,1,25) + " " + TRB->MATRIC + " " + TRB->NRGUIA + ;
 	   				 " " + TRB->NRSEQG + " " + TRB->REGGER + " " + DTOC( STOD(TRB->DATATE) ) + ;
 	   				 "-" + TRB->HORATE + " " + TRB->NRSEN1
 		oFont2 := TFont():New( "Courier New", , 09, , .F., , , , , .F. )
 		oPrn:Say( nLinI, 0050, cConteudo, oFont2, 100 )                 
 		oFont2 := TFont():New( "Courier New", , 9, , .F., , , , , .F. )
 		If nTipRel == 2
 			nLinI+=050
 			nLinF+=050
 		EndIf	
 	   
 	 nQtdGuiasR += 1
 	   
 	 While !Eof() .and. TRB->CODCON == cCodCon .and. TRB->NRLOTE == cNrLote .and. TRB->NRSEQG == cNrSeqG
 	
 	  If Empty(TRB->CODDES)                    
 		  DbSelectArea("TRB")
 		  DbSkip()
 		  Loop
 		 EndIf  
 		    
 		 If nTipRel == 2 //analitico
 		  If nLinI >= 2945
 		  	lCabec := .T.
 		  	EmiCab()
 		  EndIf
 				cConteudo := ""
 			 cConteudo := TRB->CODDES + " " + TRB->DESCR + " " + TRANSFORM(TRB->QTDDES, "@E 999,999.99") + ;
 			   				 " " + TRANSFORM(TRB->VALDES, "@E 9999,999.9999") + " " + TRANSFORM(TRB->VALTOT, "@E 99,999,999.99")
 				oPrn:Say( nLinI, 0050, cConteudo, oFont2, 100 )
 				nLinI+=050
 				nLinF+=050
 			 cCODDES := TRB->CODDES
 		 EndIf 
 		 nTotGE5_Guia += IIF(TRB->TIPO == '1', TRB->VALTOT, 0)
 		 nTotGE6_Guia += IIF(TRB->TIPO == '2', TRB->VALTOT, 0)
 		 nTotGE7_Guia += IIF(TRB->TIPO == '3', TRB->VALTOT, 0)
 		   
 		 DbSelectArea("TRB")
 		 DbSkip()
 	 End	
 	 nTotal_Guia := nTotGE5_Guia +  nTotGE6_Guia + nTotGE7_Guia
 	    
 	 If nTipRel == 1  //Sintetico
 			oPrn:Say( nLinI, 1900, TRANSFORM(nTotal_Guia, "@E 99,999,999.99"), oFont2, 100 )  //2100
 			nLinI+=050
 			nLinF+=050
 	 	If nLinI >= 2945
 	 		lCabec := .T.
 	 		EmiCab()
 	  EndIf
   Else  //analitico
   	If nLinI >= 2945
   		lCabec := .T.
   		EmiCab()
   	EndIf
 			
 			cConteudo := ""
 		 cConteudo := "==>" + " " + STR0013 + " " + TRANSFORM(nTotGE5_Guia,  "@E 99,999,999.99") + ;
 		   				 " " + STR0014 + " " + TRANSFORM(nTotGE6_Guia,  "@E 99,999,999.99") + ;
 		   				 " " + STR0015 + " " + TRANSFORM(nTotGE7_Guia,  "@E 99,999,999.99") + ;
 		   				 " " + STR0012 + " " + TRANSFORM(nTotal_Guia, "@E 99,999,999.99")
 			oPrn:Say( nLinI, 0050, cConteudo, oFont2, 100 )
 			nLinI+=100
 			nLinF+=050
 	 EndIf  
 	 nTotGE5_Lote += nTotGE5_Guia
 	 nTotGE6_Lote += nTotGE6_Guia
 	 nTotGE7_Lote += nTotGE7_Guia
 	 nTotGE5_Guia := 0
 	 nTotGE6_Guia := 0
 	 nTotGE7_Guia := 0
  End
   
  If nLinI >= 2945
  	lCabec := .T.
  	EmiCab()
  EndIf
  nTotal_Lote := nTotGE5_Lote +  nTotGE6_Lote + nTotGE7_Lote
 
 	oPrn:Say( nLinI, 0900, STR0013, oFont2, 100 )
 	oPrn:Say( nLinI, 1900, TRANSFORM(nTotGE5_Lote, "@E 99,999,999.99"), oFont2, 100 )
 	nLinI+=050
 	nLinF+=050
 
 	oPrn:Say( nLinI, 0900, STR0014, oFont2, 100 )
 	oPrn:Say( nLinI, 1900, TRANSFORM(nTotGE6_Lote, "@E 99,999,999.99"), oFont2, 100 )
 	nLinI+=050
 	nLinF+=050
 
 	oPrn:Say( nLinI, 0900, STR0015, oFont2, 100 )
 	oPrn:Say( nLinI, 1900, TRANSFORM(nTotGE7_Lote, "@E 99,999,999.99"), oFont2, 100 )
 	nLinI+=050
 	nLinF+=050
 
 	oPrn:Say( nLinI, 0900, STR0012, oFont2, 100 )
 	oPrn:Say( nLinI, 1900, TRANSFORM(nTotal_Lote, "@E 99,999,999.99"), oFont2, 100 )
 	nLinI+=050
 	nLinF+=050
 
 	oPrn:Say( nLinI, 0900, STR0018, oFont2, 100 )
 	oPrn:Say( nLinI, 2000, TRANSFORM(nGatItens, "@E 999,999"), oFont2, 100 )
 	nLinI+=050
 	nLinF+=050
 
 	oPrn:Say( nLinI, 0900, STR0019, oFont2, 100 )
 	oPrn:Say( nLinI, 2000, TRANSFORM(nQtdGuiasR, "@E 999,999"), oFont2, 100 )
 	If !eof()
 		lCabec := .T.
 		EmiCab()
 	EndIf	
 	
 	nLinI+=050
 	nLinF+=050
 	
  If nLinI >= 2945 .and. !eof()
  	lCabec := .T.
  	EmiCab()     
  EndIf
 
  nTotGE5_Lote := 0
  nTotGE6_Lote := 0
  nTotGE7_Lote := 0
  nQtdGuiasR   := 0
  cCODDES := ""
   
 End 
 
 oPrn:EndPage()                               //Fim da impressao grafica
If oPrn:GetOrientation () == 1
  oPrn:SetPortrait ( ) 
else
 oPrn:SetLandscape()    //** Para Imprimir em Formato Paisagem
Endif  
 oPrn:PREVIEW()
 oPrn:End()
 
 MS_FLUSH()
 
 dbCloseArea()
Return(Nil)

Static Function EmiCab()

 nLinI  := 0
 nLinF  := 260
        
 If lCabec
 	oPrn:EndPage()
 	lCabec := .F.
	 oPrn:StartPage()
 EndIf

 nLinI := HS_CabGraf(oPrn, 2300, NomeProg, 0800, Titulo)   //2450
 oPrn:Say( nLinI, 0050, Cabec1, oFont1, 100 )
 nLinI+=050 
 nLinF+=050
 oPrn:Say( nLinI, 0050, Cabec2, oFont1, 100 )
 nLinI+=050
 nLinF+=050
 oPrn:Line(nLinI, 0050, nLinI,  2750) //2400
 nLinI+=050
 nLinF+=050
 
 cConteudo := ""
 cConteudo := STR0009 + TRB->CODCON + "-" + GA9->GA9_NREDUZ + STR0010 + ALLTRIM(TRB->NRLOTE) + "/" + ALLTRIM(TRB->NUMPRO) + "     " + STR0024 + TRB->NRFATU
 nLinI+=050
 oPrn:Say( nLinI, 0050, cConteudo, oFont1, 100 )
 nLinI+=050
 nLinF+=050
 lCabec := .F.
Return()