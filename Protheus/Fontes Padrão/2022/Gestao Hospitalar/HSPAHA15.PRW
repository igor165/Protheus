#INCLUDE "PROTHEUS.CH"
#INCLUDE "HSPAHA15.CH"
#INCLUDE "TopConn.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHA15  บ Autor ณ Jos้ Orfeu         บ Data ณ  23/06/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ CADASTRO DE TABELAS DE PROCEDIMENTOS                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HSPAHA15()

 Private cCadastro := STR0010 //"Cadastro de Tabelas de Procedimentos"
 Private cPerg   := "HSPA15" 
 
 Private aRotina := MenuDef()

 DbSelectArea("GDB")
 DbSetOrder(1) // GDB_FILIAL + GDB_CHAVE
                   
 mBrowse(06, 01, 22, 75, "GDB")
 
Return(Nil)
                                                        

Function HS_MntA15(cAliasA15, nRegA15, nOpcA15)

 Local nOpcA     := 0, nGDOpc := IIf(aRotina[nOpcA15, 4] == 2 .Or. aRotina[nOpcA15, 4] == 5, 0, GD_INSERT + GD_UPDATE + GD_DELETE)
 Local bKeyF4    := SetKey(VK_F4, {|| Processa({||FS_Monta()}) })
 Local nCntFor   := 1, aSize := {}              
 Local cGdbChave := ""
 Local aJoinGA8  := {} , aJoinGAU := {}
 Local cCondGa8  := ""
 Local lUltVig   := SuperGetMV("MV_ULTVIG",, .F.)
 
 Private aTela := {}, aGets := {}
 Private oEscolhe
 Private aCGCN	:= {}, aHGCN := {}, nUGCN := 0, nLGCN := 0, oGCN
 Private aCGA8	:= {}, aHGA8 := {}, nUGA8 := 0, nLGA8 := 0, OGA8
 Private aCGAU	:= {}, aHGAU := {}, nUGAU := 0, oGAU
 Private nGCN_DIASEM := 0, nGCN_HINURG := 0, nGCN_HFIURG := 0
 Private nGA8CODPRO  := 0, nGA8DATVIG := 0
 Private nGauSeqInc  := 0, nGauCodGpP := 0
 Private oFolder, pForACols := 0
  
 cCondGa8 := " AND GA8.GA8_DATVIG = ( SELECT MAX(GA81.GA8_DATVIG) FROM " + RetSqlName("GDB") + " GDB "   
 cCondGa8 += " JOIN " + RetSqlName("GA8") + " GA81 ON GA81.GA8_TABPRO = GDB.GDB_CHAVE  AND GA81.GA8_FILIAL = '" + xFilial("GA8") + "' AND GA81.D_E_L_E_T_ <> '*' "
 cCondGa8 += " WHERE GDB.GDB_FILIAL = '" + xFilial("GDB") + "' AND GDB.D_E_L_E_T_ <> '*' "
 cCondGa8 += " AND GA81.GA8_TABPRO = GA8.GA8_TABPRO  AND GA81.GA8_CODPRO = GA8.GA8_CODPRO ) "   
 
                                                    
 RegToMemory("GDB", nOpcA15 == 6 .Or. aRotina[nOpcA15, 4] == 3)

 cGdbChave := IIf(nOpcA15 == 6, GDB->GDB_CHAVE, M->GDB_CHAVE)

 HS_BDados("GCN", @aHGCN, @aCGCN, @nUGCN, 1, M->GDB_CHAVE, IIf(aRotina[nOpcA15, 4] # 3, "'" + cGdbChave + "' == GCN->GCN_TABPRO", Nil))
 nGcn_DiaSem := aScan(aHGCN, {| aVet | aVet[2] == "GCN_DIASEM"})
 nGcn_HInUrg := aScan(aHGCN, {| aVet | aVet[2] == "GCN_HINURG"})
 nGcn_HFiUrg := aScan(aHGCN, {| aVet | aVet[2] == "GCN_HFIURG"})
 
 aJoinGA8 := {{" JOIN " + RetSqlName("GA7") + " GA7", "GA7.GA7_DESC", "GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' AND GA7.GA7_CODPRO = GA8.GA8_CODPRO", "GA8_DESPRO"}}
 
 nLGA8 := HS_BDados("GA8", @aHGA8, @aCGA8, @nUGA8, 3, M->GDB_CHAVE, IIf(aRotina[nOpcA15, 4] # 3, "'" + cGdbChave + "' == GA8->GA8_TABPRO" + Iif(lUltVig,cCondGa8,""), Nil), , ,"GA8_CODPRO" , ,"GA8_TABPRO/GA8_DESTPR",,,,,,,,,,,aJoinGA8) 
 nGA8CODPRO := aScan(aHGA8, {| aVet | aVet[2] == "GA8_CODPRO"})  
 nGA8DESPRO := aScan(aHGA8, {| aVet | aVet[2] == "GA8_DESPRO"})  
 nGA8CODPRT := aScan(aHGA8, {| aVet | aVet[2] == "GA8_CODPRT"})  
 nGA8VLRPRO := aScan(aHGA8, {| aVet | aVet[2] == "GA8_VLRPRO"})  
 nGA8VLRCOS := aScan(aHGA8, {| aVet | aVet[2] == "GA8_VLRCOS"})  
 nGA8METFIL := aScan(aHGA8, {| aVet | aVet[2] == "GA8_METFIL"})  
 nGA8CODPAN := aScan(aHGA8, {| aVet | aVet[2] == "GA8_CODPAN"}) 
 nGA8DATVIG := aScan(aHGA8, {| aVet | aVet[2] == "GA8_DATVIG"})
                                                                                                                           
 aJoinGAU   := {{" JOIN " + RetSqlName("GAQ") + " GAQ", "GAQ.GAQ_DESC", "GAQ.GAQ_FILIAL = '" + xFilial("GAQ") + "' AND GAQ.D_E_L_E_T_ <> '*' AND GAQ.GAQ_GRUPRO = GAU.GAU_CODGPP", "GAU_DESGPP"}}
 AADD(aJoinGAU, {" JOIN " + RetSqlName("GA7") + " GA7", "GA7.GA7_DESC", "GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' AND GA7.GA7_CODPRO = GAU.GAU_CODPRO", "GAU_DESPRO"})
 
 HS_BDados("GAU", @aHGAU, @aCGAU, @nUGAU, 1, M->GDB_CHAVE, IIf(aRotina[nOpcA15, 4] # 3, "'" + cGdbChave + "' == GAU->GAU_TABPRO", Nil),,,,,,,,,,,,,,,,aJoinGAU)
 nGauSeqInc := aScan(aHGau, {| aVet | aVet[2] == "GAU_SEQINC"})
 nGauCodGpP := aScan(aHGau, {| aVet | aVet[2] == "GAU_CODGPP"})
 nGauCodPro := aScan(aHGau, {| aVet | aVet[2] == "GAU_CODPRO"})
 
 aSize := MsAdvSize(.T.)
 aObjects := {}	
 AAdd( aObjects, { 100, 040, .T., .T. } )	
 AAdd( aObjects, { 100, 048, .T., .T. } )	
 AAdd( aObjects, { 100, 012, .T., .T., .T. } )	
 
 aInfo  := {aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0}
 aPObjs := MsObjSize(aInfo, aObjects, .T.)

 DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 TO aSize[6]+25,aSize[5]	PIXEL of oMainWnd
  oEncGdb := MsMGet():New("GDB", nRegA15, nOpcA15,,,,, aPObjs[1],, 2,,,, oDlg) 
  oEncGdb:aEntryCtrls[aScan(oEncGdb:aGets, {|x| "GDB_CHAVE " $ x}) ]:lReadOnly := (aRotina[nOpcA15, 4] <> 3 .AND. nOpcA15 <> 6)
  oEncGdb:aEntryCtrls[aScan(oEncGdb:aGets, {|x| "GDB_CHAVE " $ x}) ]:bValid := {|| IIF(aRotina[nOpcA15, 4] <> 5, FS_VALDUP("GDB",M->GDB_CHAVE,1), .T.)}
  oEncGdb:oBox:Align := CONTROL_ALIGN_TOP
  
  @ 85, 000 FOLDER oFolder SIZE 400, 397	 OF oDlg PROMPTS STR0012, STR0013, STR0023 PIXEL //"Procedimentos"###"Hor. Acr้scimo"###"Incid๊ncias"
  oFolder:Align := CONTROL_ALIGN_ALLCLIENT

  oGA8 := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], nGDOpc,"HS_A15LOK(1)",,,,,99999,,,, oFolder:aDialogs[1], aHGA8, aCGA8)
  oGA8:oBrowse:align := CONTROL_ALIGN_ALLCLIENT                                                      
  
  oGCN := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], nGDOpc,,,,,,99999,,,, oFolder:aDialogs[2], aHGCN, aCGCN)
  oGCN :oBrowse:align := CONTROL_ALIGN_ALLCLIENT                                                      
  
  oGAU := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], nGDOpc,,,,,, 99999,,,, oFolder:aDialogs[3], aHGau, aCGau)
  oGAU :oBrowse:align := CONTROL_ALIGN_ALLCLIENT                                                      
  
  oEscolhe := {{"parametros", {|| Processa({||FS_Monta()}) }, STR0008, STR0024}} //"Busca Procedimentos"###"Dados"

  oPPesq	:=	tPanel():New(aPObjs[3, 1], aPObjs[3, 2],, oDlg,,,,,, aPObjs[3, 3], aPObjs[3, 4])
  oPPesq:Align := CONTROL_ALIGN_BOTTOM
  
 HS_GDPesqu( , , oGA8, oPPesq, 002)      
    

 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpcA := 1, IIf(oGCN:TudoOk() .And. HS_TudoOK("GAU", oGau, nGauCodGpP) .And. Obrigatorio(aGets, aTela) .And. IIf(aRotina[nOpcA15,4] == 5, FS_ExclGDB(), .T.), oDlg:End(), nOpcA := 0)}, ;
                                                           {|| nOpcA := 0, oDlg:End()},,oEscolhe)

 SetKey(VK_F4, bKeyF4)

 If nOpcA == 1
  Begin Transaction 
   FS_GrvA15(nOpcA15)
  End Transaction
 EndIf                                                    
 
Return(Nil)

Function HS_A15LOK(nFolder)

 Local lRet := .T.
 
 If nFolder == 1
      
  If !(Len(oGA8:aCols) == len(aCGA8) .And. ; 
   oGA8:aCols[oGA8:oBrowse:nAt, nGA8CODPRO] == aCGA8[oGA8:oBrowse:nAt, nGA8CODPRO] .And. ;
   oGA8:aCols[oGA8:oBrowse:nAt, nGA8DATVIG] == aCGA8[oGA8:oBrowse:nAt, nGA8DATVIG])
   lRet := HS_DuplAC(oGA8:oBrowse:nAt, oGA8:aCols, {nGA8CODPRO, nGA8DATVIG})
   If lRet
    aCGA8 := aClone(oGA8:aCols)
   EndIf
  EndIf 
 
 EndIf

Return(lRet)


Static Function FS_GrvA15(nOpcA15)

 Local lAchou := .F.
 
 Private pForaCols := 0

 If aRotina[nOpcA15, 4] # 2 // nao for consulta
  DbSelectArea("GDB")  
  DbsetOrder(1) // GDB_FILIAL + GDB_CHAVE
  lAchou := DbSeek(xFilial("GDB") + M->GDB_CHAVE)
  If Inclui .Or. Altera
   RecLock("GDB", If(lAchou, .F., .T.))
    HS_GRVCPO("GDB")
    GDB->GDB_FILIAL := xFilial("GDB")
		 MsUnLock() 
  Else  // exclusao
   RecLock("GDB", .F., .T.)
   DbDelete()
   MsUnlock()
   WriteSx2("GDB")
  EndIf
                                     
  FS_GrvRel("GCN", 1, "M->GDB_CHAVE + oGCN:aCols[pForaCols, nGcn_DiaSem]+ oGCN:aCols[pForaCols, nGcn_HInUrg] + oGCN:aCols[pForaCols, nGcn_HFiUrg]", oGCN, nGCN_DIASEM)
  FS_GrvRel("GA8", 3, "M->GDB_CHAVE + oGA8:aCols[pForaCols, nGA8CODPRO] + DtoS(oGA8:aCols[pForaCols, nGA8DATVIG])", oGA8 ,nGA8CODPRO)                                  
  FS_GrvRel("GAU", 2, "M->GDB_CHAVE + oGAU:aCols[pForaCols, nGauCodGpP] + oGAU:aCols[pForaCols, nGauCodPro]", oGau, nGauCodGpp)
 EndIf
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GrvRel บ Autor ณ Cibele Peria       บ Data ณ  14/12/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Grava arquivos de relacionamento                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_GrvRel(cAlias, nOrd, cChave, oGrv,nPos)

 Local nItem 				:= 0, cPref := cAlias + "->" + PrefixoCpo(cAlias)
 Local cAliasOld := Alias() 
 Local lAchou    := .F.

 For nItem := 1 To Len(oGrv:aCols)
  pForaCols := nItem
  DbSelectArea(cAlias)
  DbSetOrder(nOrd)
  lAchou := DbSeek(xFilial(cAlias) + &(cChave) )
  If ((!Inclui .And. !Altera) .Or. oGrv:aCols[nItem, Len(oGrv:aCols[nItem])]) .And. lAchou // exclusao
   RecLock(cAlias, .F., .T.)
   DbDelete()
   MsUnlock()
   WriteSx2(cAlias)
  Else                             
   If Inclui .Or. Altera
    If !oGrv:aCols[nItem, Len(oGrv:aCols[nItem])]
     RecLock(cAlias, !lAchou) 
     HS_GRVCPO(cAlias, oGrv:aCols, oGrv:aHeader, nItem)
     &(cPref + "_FILIAL") := xFilial(cAlias)
     &(cPref + "_TABPRO") := M->GDB_CHAVE
     &(cPref + "_LOGARQ") := HS_LogArq()
     MsUnlock()
    EndIf 
   EndIf
  EndIf 
 Next
 
 DbSelectArea(cAliasOld)
Return() 

/*************************************************************************************************/
Function FS_AchaNumSeq()

Local cNumSeq := "" 
Local lFound  := .F.

 If oGAU <> Nil
  lFound := IIf(!Empty(oGAU:aCols[oGAU:nAt, nGauSeqInc]) .And. !Inclui, DbSeek(xFilial("GAU") + oGAU:aCols[oGAU:nAt, nGauSeqInc]), .F.)
  If !oGAU:aCols[oGAU:nAt, nUGAU + 1] //n esta deletado
   If !lFound
    cNumSeq := Soma1(oGAU:aCols[oGAU:nAt, nGauSeqInc], Len(oGAU:aCols[oGAU:nAt, nGauSeqInc])) 
   Else
    cNumSeq := oGAU:aCols[oGAU:nAt, nGauSeqInc]
   EndIf 
  Else
   cNumSeq := Soma1(oGAU:aCols[oGAU:nAt, nGauSeqInc], Len(oGAU:aCols[oGAU:nAt, nGauSeqInc])) 
  EndIf  
 Else
  cNumSeq := "001"
 EndIf 

Return(cNumSeq)

/*************************************************************************************************/
Function HS_VldA15()

 Local lRet := .T., cAliasOld := Alias()
 Local nPos := 0
 Local cCampo := ReadVar()
 Local cFVCDPR := ""

 If cCampo == "M->GA8_CODPRO" 
  DbSelectArea("GA7")
  DbSetOrder(1) // GA7_FILIAL + GA7_CODPRO
  lRet := DbSeek(xFilial("GA7") + M->GA8_CODPRO)
  GDFieldPut("GA8_DESPRO", GA7->GA7_DESC)
  If lRet
   nPos := aScan(oGA8:aCols, {| aVet | aVet[nGA8CODPRO] == M->GA8_CODPRO})
   If nPos > 0 .And. nPos # oGA8:oBrowse:nAt
    HS_MsgInf(STR0007, STR0016, STR0010) //"Procedimento jแ cadastrado para a tabela"###"Aten็ใo"###"Cadastro de Tabelas de Procedimentos"
    lRet := .F.
   EndIf 
  Else
   HS_MsgInf(STR0006, STR0016, STR0010) //"Procedimento invแlido"###"Aten็ใo"###"Cadastro de Tabelas de Procedimentos"
  EndIf 
 
 ElseIf cCampo == "M->GDB_TBTISS" 
  If !EMPTY(M->GDB_TBTISS) .And. !(lRet := HS_SeekRet("G24", "M->GDB_TBTISS", 1, .F., "GDB_DTBTIS", "G24_DESCRI",,, .T.))
   HS_MsgInf(STR0027, STR0016, STR0028)  //"Tabela do TISS nใo encontrada."###"Aten็ใo"###"Valida็ใo dos campos"
  EndIf
 ElseIf cCampo == "M->GA8_CODPRT"
  If HS_ExisDic({{"C", "GDB_FVCDPR"}}, .F.)
   If Type("M->GDB_FVCDPR") # "U"
    cFVCDPR := M->GDB_FVCDPR                                                                                                                   
   Else 
    DbSelectArea("GDB")
    DbSetOrder(1)//GDB_FILIAL+GDB_CHAVE
    If DbSeek(xFilial("GDB")+oGA8:aCols[oGA8:oBrowse:nAt , nGa8TABPRO])
     cFVCDPR := GDB->GDB_FVCDPR
    EndIf
   EndIf  
   lRet:= IIf(!Empty(cFVCDPR), &(cFVCDPR), .T.)
  EndIf
  
 EndIf
 
 DbSelectArea(cAliasOld)
Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_Monta  บ Autor ณ Marcelo Jose       บ Data ณ  21/12/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina para montar os facilitadores                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar (Agenda Ambulatorial)             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_Monta()

 If !Pergunte(cPerg, .T.)
 	Return
 EndIf

 DbSelectArea("GA7")
 DbSetOrder(1) // GA7_FILIAL + GA7_CODPRO
 ProcRegua(reccount())
 DbSeek(xFilial("GA7") + MV_PAR01, .T. )
 While GA7->GA7_FILIAL == xFilial("GA7") .And. GA7->GA7_CODPRO <= MV_PAR02 .And. !Eof()
  IncProc(STR0009 + GA7->GA7_CODPRO) // "Aguarde, processando dados: "
  If !Empty(GA7->GA7_CODESP) 
   If GA7->GA7_CODESP < MV_PAR03 .Or. GA7->GA7_CODESP > MV_PAR04
    DbSkip()
    Loop
   EndIf
  EndIf 
  IF !Empty(aCGA8[ Len(aCGA8), nGA8CODPRO	] )
   aAdd(aCGA8, oGA8:aCols[1] )
  EndIf
  aCGA8[ Len(aCGA8), nGA8CODPRO	] := GA7->GA7_CODPRO
  aCGA8[ Len(aCGA8), nGA8DESPRO	] := GA7->GA7_DESC
  aCGA8[ Len(aCGA8), nGA8CODPRT	] := GA7->GA7_CODPRO
  aCGA8[ Len(aCGA8), nGA8METFIL	] := GA7->GA7_METFIL
  aCGA8[ Len(aCGA8), nGA8CODPAN	] := GA7->GA7_CODPAN
  aCGA8[ Len(aCGA8), nGA8DATVIG	] := MV_PAR05
  oGA8:SetArray(aCGA8)
  DbSkip()
 EndDo
 If Len(aCGA8) > 0
  oGA8:oBrowse:Refresh()
 EndIf 
 
Return(Nil)

Function HS_VALHA15(nVem)

 Local lRet := .T., cCpoEsc := "GCN_"

 IF nVem == 1
  cCpoEsc := cCpoEsc+"HINURG"
 Else
  cCpoEsc := cCpoEsc+"HFIURG"
 EndIf
 
 If Empty(M->&cCpoEsc)
  HS_MsgInf(STR0015, STR0016, STR0010)  //"Horแrio invแlido"###"Aten็ใo"###"Cadastro de Tabelas de Procedimentos"
  lRet := .F.
 ElseIf Val(SUBSTR(M->&cCpoEsc,1,2)) < 0 .Or. Val(SUBSTR(M->&cCpoEsc, 1, 2)) > 23
  HS_MsgInf(STR0017, STR0016, STR0010)  //"Hora invแlida"###"Aten็ใo"###"Cadastro de Tabelas de Procedimentos"
  lRet := .F.
 ElseIf Empty(SUBSTR(M->&cCpoEsc, 4, 2)) .Or. (Val(SUBSTR(M->&cCpoEsc, 4, 2)) < 0 .Or. Val(SUBSTR(M->&cCpoEsc, 4, 2)) > 59)
  HS_MsgInf(STR0018, STR0016, STR0010)  //"Minutos invแlidos"###"Aten็ใo"###"Cadastro de Tabelas de Procedimentos"
  lRet := .F.
 EndIf

Return(lRet)

/*
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณ HS_A15ATU ณ Autor ณ Robson Ramiro A. Oliveณ Data ณ 06.04.05 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Atualizacao da tabela de procedimentos                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ HS_A15ATU                                                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ Void                                                        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ HSP                                                         ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_A15ATU

Local aArea := GetArea()

If !Pergunte("HSA15A", .T.)
 Return .F.
EndIf     

If MsgYesNo(STR0019 + GDB->GDB_CHAVE) //"Confirma atualiza็ใo da Tabela de Procedimentos "
 Processa({|| FS_GerAtu()}, STR0020 + GDB->GDB_CHAVE) //"Processando tabela "
EndIf

RestArea(aArea)

Return(.T.)

/*
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณ FS_GerAtu ณ Autor ณ Robson Ramiro A. Oliveณ Data ณ 06.04.05 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Processa a atualizacao da tabela de procedimentos           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ FS_GerAtu                                                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ Void                                                        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ HSP                                                         ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_GerAtu

Local nTamLin := GDB->(GDB_TAMCOD + GDB_TAMVLR + GDB_TAMCHC + GDB_TAMM2F + GDB_TAMPOR)
Local cArq    := Trim(GDB->GDB_NOMARQ)
Local nHdl    := Nil
Local cBuffer := Space(nTamLin + 2)
Local nBytes  := 0
Local cCOD				:= ""
Local nVLR				:= 0
Local	nCHC				:= 0
Local nM2F				:= 0
Local	cPOR				:= ""
Local nCont			:= 0
Local bCampo		:=	{|nCpo| Field(nCpo)}

nHdl := fOpen(cArq, 2) // Abre o arquivo

If nHdl == -1
	HS_MsgInf(STR0021, STR0016, STR0010) //"Arquivo nใo pode ser aberto!"###"Aten็ใo"###"Cadastro de Tabelas de Procedimentos"
	Return
EndIf

Begin Transaction 

DbSelectArea("GDB")
RecLock("GDB", .F.)
GDB->GDB_LOG := HS_LOGARQ()
MsUnLock()

nBytes := fRead(nHdl, @cBuffer, nTamLin+2)

ProcRegua(nBytes)

Do While nBytes == nTamLin + 2

	cCOD	:= SUBSTR(cBuffer, GDB->GDB_COLINI, GDB->GDB_TAMCOD)
	nVLR := SuperVal(SUBSTR(cBuffer, GDB->GDB_COLINV, GDB->GDB_TAMVLR))  // Funcao que pega os valores com decimais
	nCHC := SuperVal(SUBSTR(cBuffer, GDB->GDB_COLCHC, GDB->GDB_TAMCHC))
	nM2F := SuperVal(SUBSTR(cBuffer, GDB->GDB_COLM2F, GDB->GDB_TAMM2F))
	cPOR	:= SUBSTR(cBuffer, GDB->GDB_COLPOR, GDB->GDB_TAMPOR)

	DbSelectArea("GA8")
	DbSetOrder(2) // GA8_FILIAL + GA8_TABPRO + GA8_CODPRT + GA8_DATVIG
	If DbSeek(xFilial("GA8") + GDB->GDB_CHAVE + cCOD) .And. !Empty(cCOD)
		
		IncProc(STR0022 + GA8->GA8_CODPRT) //"Atualizando "

 	DbSelectArea("GA8")
		RegToMemory("GA8", .F.)

 	RecLock("GA8", .T.)
 			 
		For nCont := 1 To FCount()  // Copia dados do registro original
			If "FILIAL"$Field(nCont)
				FieldPut(nCont, xFilial("GA8"))
			Else
				FieldPut(nCont, M->&(Eval(bCampo, nCont)))
			EndIf
		Next nCont

		GA8->GA8_VLRPRO := nVLR  // Atribui valores novos
		GA8->GA8_VLRCOS := nCHC
		GA8->GA8_METFIL := nM2F
		GA8->GA8_CODPAN := cPOR
		GA8->GA8_DATVIG := MV_PAR01
		GA8->GA8_LOGARQ := HS_LOGARQ()
 	MsUnLock()

	EndIf

 nBytes := fRead(nHdl, @cBuffer, nTamLin + 2)

EndDo

End Transaction

fClose(nHdl)
          
Return(.T.)  

/*
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_DescA15บ Autor ณ Daniel Peixoto     บ Data ณ  02/09/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina de validacao dos campos de descricao.               บฑฑ
ฑฑบ          ณ Chamada do X3_RELACAO do campo de Acordo com o Parametro   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_DescA15(cAlias, nCpo)

 Local cCodChave := ""
 Local cDescri   := ""  
 
 If cAlias == "GA8"
  cCodChave := IIf(Inclui, "", IIf(Alias() == "TMPGA8", (Alias())->GA8_CODPRO, ""))
  If !Empty(cCodChave)
   cDescri := HS_IniPadr("GA7", 1, cCodChave, "GA7_DESC",,.F.)
  EndIf 
  
 ElseIf cAlias == "GAU"     
  If nCpo == 1
   cCodChave := IIf(Inclui, "", IIf(Alias() == "TMPGAU", (Alias())->GAU_CODGPP, ""))
   If !Empty(cCodChave)
    cDescri := HS_IniPadr("GAQ", 1, cCodChave, "GAQ_DESC",,.F.)
   EndIf 
  ElseIf  nCpo == 2
   cCodChave := IIf(Inclui, "", IIf(Alias() == "TMPGAU", (Alias())->GAU_CODPRO, ""))
   If !Empty(cCodChave)
    cDescri := HS_IniPadr("GA7", 1, cCodChave, "GA7_DESC",,.F.) 
   EndIf 
  EndIf
 
 EndIf
 
Return(cDescri)    

/*
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VALDUP บ Autor ณ Mario Arizono      บ Data ณ  20/04/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Valida duplicidade na digitacao do codigo.                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_ValDup(cAlias, cCpo,nOrd)

 Local lRet := .T.
  
 DbSelectArea(cAlias)
 DbSetOrder(nOrd)
 If DbSeek(xFilial(cAlias) + cCpo)
  Hs_MsgInf(STR0026, STR0016, STR0010) //"Chave jแ existe"###"Aten็ใo"###"Cadastro de Tabelas de Procedimentos" 
  lRet := .F.
 EndIf 
  
Return(lRet)


Static Function FS_ExclGDB()

 Local aArea := GetArea()
 Local lRet	 := .T.

 If (HS_CountTB("GC6", "GC6_TABPRO = '" + M->GDB_CHAVE + "'")  > 0) 
  HS_MsgInf(STR0029, STR0016, STR0030) //"Tabela Procedimento possui relacionamento com Planos X Tabela Procedimento."###"Aten็ใo"###"Valida็ใo de exclusใo"
 	lRet := .F.
 Endif
                                                                                                                      
 RestArea(aArea)
Return(lRet) 

Function HS_A15SUS()
 Local aArea := GetArea()


 If MsgYesNo(STR0032 + GDB->GDB_CHAVE) //"Confirma atualiza็ใo de tabelas de procedimento - SUS "
  Processa({|| FS_AtuSUS()}, STR0020 + GDB->GDB_CHAVE) //"Processando tabela "
 EndIf

 RestArea(aArea)
Return()

Static Function FS_AtuSUS()
 Local aArea     := GetArea(), aAreaSX3 := SX3->(GetArea())
 Local cSql  := ""
 Local nFor      := 0
 Local aTab      := {}
 Local lGA7Found := .F.
 
 If !Pergunte("HSA15S", .T.)
  Return()
 EndIf
 
 aTab := {{"GL1", "GJ1", STR0043},; //Habilitacao 
          {"GL3", "GJ3", STR0044},; //Especialidade do Leito
          {"GL5", "GJ5", STR0045},; //Modalidade de Atendimento
          {"GL7", "GJ7", STR0046},; //Servico (Cabecalho)
          {"GL8", "GJ8", STR0047},; //Servico/Classificacao
          {"GLA", "GJA", STR0048},; //Instrumento de Registro
          {"GLC", "GJC", STR0049},; //Subgrupo de Procedimentos
          {"GLD", "GJD", STR0050},; //Forma de Organizacao
          {"GMS", "GJS", STR0051},; //Grupo de Procedimento
          {"GLS", "GAS", STR0052},; //CID
          {"GH2", "GH1", STR0053},;  //CBO
          {"GLU", "GLV", STR0058};   //Detalhe
         }
 
 For nFor := 1 To Len(aTab) // Repete para cada tabela
  ProcRegua(3)
  IncProc(STR0054 + aTab[nFor, 3]) //"Aguarde excluindo registros..."
  IncProc()

  HS_ZAPCOND(aTab[nFor, 2])
 
  FS_DePara(aTab[nFor, 1], aTab[nFor, 2], aTab[nFor, 3])
 Next
 
 aTab := {{"GL0", "GHH", STR0034},; //"Procedimento X CID"
           {"GLG", "GHD", STR0035},; //"Procedimento X CBO"
           {"GLF", "GK0", STR0036},; //"Procedimento X OPM"
           {"GL9", "GK1", STR0037},; //"Procedimento X Servi็o X Classifica็ใo"
           {"GL2", "GK2", STR0038},; //"Procedimento X Habilita็ใo"
           {"GL4", "GK3", STR0039},; //"Procedimento X Especialidade do Leito"
           {"GLE", "GK4", STR0040},; //"Procedimento X Incremento"
           {"GL6", "GK5", STR0041},; //"Procedimento X Modalidade"
           {"GLB", "GK6", STR0042},; //"Procedimento X Instrumento de Registro"
           {"GLX", "GLZ", STR0059};  //"Procedimento X Detalhe"
            }
 
 For nFor := 1 To Len(aTab)
  ProcRegua(3)
  IncProc(STR0054 + aTab[nFor, 3]) //"Aguarde excluindo registros..."
  IncProc()

  HS_ZAPCOND(aTab[nFor, 2])
  
 Next
  
 //Atualiza Cadastro de Procedimentos
 
 cSql := "SELECT * "
 cSql += "FROM " + RetSqlName("GMV") + " GMV "
 cSql += "WHERE GMV.D_E_L_E_T_ <> '*' AND GMV.GMV_FILIAL = '" + xFilial("GMV") + "' "
 cSql += "ORDER BY GMV.GMV_FILIAL, GMV.GMV_CODPRO "
 
 cSql := ChangeQuery(cSql)
 
 TcQuery cSql New Alias "TMPGMV"
 DbSelectArea("TMPGMV")
 DbGotop()
 
 While !(TMPGMV->(Eof()))
  IncProc(STR0056 + " " + TMPGMV->GMV_CODPRO + ". " + STR0055) // "Atualizando "###". Aguarde..."
  
  DbSelectArea("GA7")
  DbSetOrder(1)
  lGA7Found := DbSeek(xFilial("GA7") + TMPGMV->GMV_CODPRO)
  
  FS_GrvProc(lGA7Found)//Irแ gravar GA7 e GA8  
  
  TMPGMV->(DbSkip())
 End
 
 //Grava os relacionamentos
 For nFor := 1 To Len(aTab)
  FS_DePara(aTab[nFor, 1], aTab[nFor, 2], aTab[nFor, 3])
 Next
 
 //Criar uma fun็ใo que possa ser utilizada na c๓pia.
 //Correr a GMV, procurando na GA7 os procedimentos com o mesmo c๓digo SUS
 //Fazer um Select nas propriedades e duplicar os caras.
 DbSelectArea("TMPGMV")
 DbGotop()
 
 While !(TMPGMV->(Eof()))
  
  DbSelectArea("GA7")
  DbSetOrder(10)
  DbSeek(xFilial("GA7") + TMPGMV->GMV_CODPRO)
  While !GA7->(Eof()) .And. xFilial("GA7") == GA7->GA7_FILIAL .And. GA7->GA7_CODSUS == TMPGMV->GMV_CODPRO

   If GA7->GA7_CODPRO <> GA7->GA7_CODSUS
   
   	FS_GrvProc(.T.)
   
   	For nFor := 1 To Len(aTab)
   	 HS_ZAPCOND(aTab[nFor, 2], aTab[nFor, 2] + "_CODPRO = '" + GA7->GA7_CODPRO + "'")
   	 FS_DePara(aTab[nFor, 1], aTab[nFor, 2], aTab[nFor, 3], GA7->GA7_CODSUS, GA7->GA7_CODPRO)
   	Next
   	
   EndIf
   
   GA7->(DbSkip())  
  End
  
  TMPGMV->(DbSkip())
  
 End 
  
 HS_MsgInf(STR0057, STR0016, STR0031)//"Atualiza็ใo finalizada com sucesso."###"Aten็ใo"###"Atualiza็ใo SUS"
 RestArea(aAreaSX3)
 RestArea(aArea)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHA15  บAutor  ณMicrosiga           บ Data ณ  10/13/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function FS_GrvProc(lGA7Found)
 Local lGA8Found := .F.
 
 RecLock("GA7", !lGA7Found)
  GA7->GA7_FILIAL := xFilial("GA7")
  If !lGA7Found
   GA7->GA7_CODPRO := TMPGMV->GMV_CODPRO
   GA7->GA7_DESC   := TMPGMV->GMV_DESCRI
  EndIf
  GA7->GA7_RUBRIC := TMPGMV->GMV_RUBRIC
  GA7->GA7_IDAMIN := TMPGMV->GMV_IDMIN
  GA7->GA7_IDAMAX := TMPGMV->GMV_IDMAX
  If TMPGMV->GMV_SEXO == 'M'
   GA7->GA7_CDSEXO := '0'
  ElseIf TMPGMV->GMV_SEXO == 'F'
   GA7->GA7_CDSEXO := '1'
  ElseIf TMPGMV->GMV_SEXO == 'I'
   GA7->GA7_CDSEXO := '2'
  Else
   GA7->GA7_CDSEXO := '3'
  EndIf
  GA7->GA7_QTDMAX := TMPGMV->GMV_QTDMAX
  GA7->GA7_PERMAN := TMPGMV->GMV_PERMAN
  GA7->GA7_COMPLE := TMPGMV->GMV_COMPLE
  GA7->GA7_COMPET := TMPGMV->GMV_COMPET
  GA7->GA7_FINANC := TMPGMV->GMV_FINANC
  GA7->GA7_ANESTE := TMPGMV->GMV_ANESTE
  GA7->GA7_PERMAI := TMPGMV->GMV_PERMAI
  GA7->GA7_QTDPTS := TMPGMV->GMV_QTDPTS
  GA7->GA7_AUTORI := TMPGMV->GMV_AUTORI
//  GA7->GA7_CODSUS := TMPGMV->GMV_CODPRO
 MsUnlock()
  
 DbSelectArea("GA8")
 DbSetOrder(1) //GA8_FILIAL+GA8_CODPRO+GA8_TABPRO+DTOS(GA8_DATVIG)
 lGA8Found := DbSeek(xFilial("GA8") + GA7->GA7_CODPRO + GDB->GDB_CHAVE + DTOS(MV_PAR01))
 RecLock("GA8", !lGA8Found)
  GA8->GA8_FILIAL := xFilial("GA8")
  GA8->GA8_CODPRO := GA7->GA7_CODPRO
  GA8->GA8_CODPRT := IIf(!Empty(GA7->GA7_CODSUS), GA7->GA7_CODSUS, GA7->GA7_CODPRO)
  GA8->GA8_DESPRT := IIf(!Empty(GA7->GA7_CODSUS), TMPGMV->GMV_DESCRI, GA7->GA7_DESC)
  GA8->GA8_TABPRO := GDB->GDB_CHAVE
  GA8->GA8_DATVIG := MV_PAR01
  GA8->GA8_VLSRVH := TMPGMV->GMV_VLSRVH
  GA8->GA8_VLSRVP := TMPGMV->GMV_VLSRVP
  GA8->GA8_VLSRVA := TMPGMV->GMV_VLSRVA
 MsUnlock()
  
 IncProc()
  
Return()

Function FS_DePara(cAlias1, cAlias2, cMensagem, cCodSUS, cCodPro)
                       
  Local aArea := GetArea()
  
  Default cCodPro := ""
  Default cCodSUS := ""
 
  
  cAliasTrab := Alias()
  
  //Query utilizada para contar o numero de registros
  cSql := "SELECT COUNT(*) CONT FROM " + RetSqlName(cAlias1) + " WHERE D_E_L_E_T_ <> '*' AND " 
  cSql += cAlias1 + "_FILIAL ='" + xFIlial(cAlias1) + "' "
  If !Empty(cCodSUS)
   cSql += " AND " + cAlias1 + "_CODPRO = '" + cCodSUS + "' "
  EndIf
  
  cSql := ChangeQuery(cSql)
  
  TcQuery cSql New Alias "TMP"
 
  ProcRegua(TMP->CONT)
  
  TMP->(DbCloseArea())
  
  IncProc(STR0033 + cMensagem + ". " + STR0055) // "Atualizando "###". Aguarde..."
  //IncProc()
  
  cSql := "SELECT * FROM " + RetSqlName(cAlias1) + " WHERE D_E_L_E_T_ <> '*' AND " 
  cSql += cAlias1 + "_FILIAL ='" + xFilial(cAlias1) + "' "
  If !Empty(cCodSUS)
   cSql += " AND " + cAlias1 + "_CODPRO = '" + cCodSUS + "' "
  EndIf
  
  cSql := ChangeQuery(cSql)
  
  TcQuery cSql New Alias "TMP"
  
  DbSelectArea("TMP")
  While TMP->(!Eof()) // Repete para cada registro da tabela "Temporaria"
     
   DbSelectArea(cAlias2)
   IncProc()
   
   Begin Transaction
    RecLock(cAlias2, .T.)
     
     DbSelectArea("SX3")
     DBSetOrder(1)
     DbSeek(cAlias1)
     While !SX3->(Eof()) .And. SX3->X3_ARQUIVO == cAlias1 //Repete para cada campo da tabela teporaria
      
      If SX3->X3_TIPO <> "M" .And. SX3->X3_CONTEXT <> "V"
       cCampo := PrefixoCpo(cAlias2) + AllTrim(SubStr(SX3->X3_CAMPO, At("_", SX3->X3_CAMPO), Len(SX3->X3_CAMPO)))
    
       If "_FILIAL" $ cCampo
        &(cAlias2 + "->" + cCampo) := xFilial(cAlias2)
       ElseIf !Empty(cCodPro) .And. "_CODPRO" $ cCampo
        &(cAlias2 + "->" + cCampo) := cCodPro
       Else
        &(cAlias2 + "->" + cCampo) := &("TMP->" + SX3->X3_CAMPO)
       EndIf
       
      EndIf
      SX3->(DbSkip())
     End
    
    DbSelectArea(cAlias2) 
    MsUnlock()   
    
   End Transaction
   
   TMP->(DbSkip())
  End
  
  TMP->(DbCloseArea())
  
  aArea := GetArea()
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ MenuDef  ณ Autor ณ Tiago Bandeira        ณ Data ณ 06/06/07 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Defini็ใo do aRotina (Menu funcional)                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ MenuDef()                                                  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define Array contendo as Rotinas a executar do programa      ณ
//ณ ----------- Elementos contidos por dimensao ------------     ณ
//ณ 1. Nome a aparecer no cabecalho                              ณ
//ณ 2. Nome da Rotina associada                                  ณ
//ณ 3. Usado pela rotina                                         ณ
//ณ 4. Tipo de Transao a ser efetuada                          ณ
//ณ    1 - Pesquisa e Posiciona em um Banco de Dados             ณ
//ณ    2 - Simplesmente Mostra os Campos                         ณ
//ณ    3 - Gera arquivo TXT para exportacao                      ณ
//ณ    4 - Recebe arquivo TXT                                    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local aRotina :=	{	{OemToAnsi(STR0001),	"axPesqui" , 0, 1, 0, nil},;  //"Pesquisar"
          						{OemToAnsi(STR0002),	"HS_MntA15", 0, 2, 0, Nil},;  //"Visualizar"
		             	{OemToAnsi(STR0003),	'HS_MntA15', 0, 3, 0, Nil},;  //"Incluir"
		             	{OemToAnsi(STR0004),	'HS_MntA15', 0, 4, 0, Nil},;  //"Alterar"
		             	{OemToAnsi(STR0005),	'HS_MntA15', 0, 5, 0, Nil},;  //"Excluir" 
		             	{OemToAnsi(STR0025),	'HS_MntA15', 0, 4, 0, Nil},;  //"Copiar"
		             	{OemToAnsi(STR0011),	"HS_A15ATU", 0, 6, 0, Nil},;  //"Atualiza็ใo"
		             	{OemToAnsi(STR0031),	"HS_A15SUS", 0, 4, 0, Nil}} 		//"Atualiza็ใo SUS"
Return(aRotina)
