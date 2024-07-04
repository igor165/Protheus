#INCLUDE "HSPAHA81.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

Static __RetGH3 := ""  // Var para retorno da SXB

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHA81  º Autor ³ José Orfeu         º Data ³  15/10/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ CADASTRO DE TABELA DE PRECOS MAT/MED                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHA81()

Private cCadastro := STR0009 //"Tabela de Preços MAT/MED"
Private aRotina   := MenuDef()

DbSelectArea("GCA")
DbSetOrder(1)  // GCA_FILIAL + GCA_CODTAB                                            

mBrowse(06, 01, 22, 75, "GCA")
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³HS_A81Roti³ Autor ³  José Orfeu           ³ Data ³ 15/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Funcao de Tratamento do Cadastro de Tabela De Preços MAT/MED±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Gestao Hospitalar                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_A81Roti(cAliasA81, nRegA81, nOpcA81)

 Local aHGcb  := {}, aCGcb := {}, nUGcb := 0, oEnGca, lBMatMed := .F., nDlgA81 := 0
 Local nGDOpc := IIF(StrZero(aRotina[nOpcA81, 4], 2) $ "03/04", GD_INSERT + GD_UPDATE + GD_DELETE, 0)
 Local cGcaCodTab := "", aSize := {}, aObjects := {}, aInfo := {}, aPObjs := {}
 Local aJoinGA8   := {}
 Local i		:= 0
 
 Private aTela := {}, aGets := {}, nLGcb := 0, oGetDados
 Private nGCBCODTAB := 0, nGCBPRODUT    := 0, nGCBDESCRI := 0, nGCBPRCVEN := 0, nGCBStaReg := 0
 Private nGCBPRCVUC := 0, nGCBFATOR     := 0, nGCBATIVO  := 0, nGCBDATVIG	:= 0
 Private cG1RTipo   := "01", cGbiTipKit := ""
                                                                    
 If nOpcA81 == 6 
  If !Pergunte("HSPA81", .T.)
   Return(.F.)
  EndIf
 EndIf

 RegToMemory("GCA", nOpcA81 == 7 .Or. aRotina[nOpcA81, 4] == 3)                                                          
 
 If nOpcA81 == 7
  M->GCA_TIPO := GCA->GCA_TIPO
 EndIf
  
 cGcaCodTab := IIF(nOpcA81 == 7, GCA->GCA_CODTAB, M->GCA_CODTAB)
 
 aJoinGA7 := {{" JOIN " + RetSqlName("SB1") + " SB1", "SB1.B1_DESC", "SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.D_E_L_E_T_ <> '*' AND SB1.B1_COD = GCB.GCB_PRODUT", "GCB_DESCRI"}}
 
 nLGcb := HS_BDados("GCB", @aHGcb, @aCGcb, @nUGcb, 1,, IIF(aRotina[nOpcA81, 4] == 3 .And. nOpcA81 <> 7, Nil, "GCB->GCB_CODTAB == '" + cGcaCodTab + "'"), .T.,,,,,IIF(nOpcA81 == 7 .Or. aRotina[nOpcA81, 4] == 3 , "BR_VERMELHO", Nil),,,,,,,,,, aJoinGA7)
 
 nGCBStaReg := aScan(aHGcb, {|aVet| aVet[2]          == "HSP_STAREG"})
 nGCBCODTAB := aScan(aHGcb, {|aVet| AllTrim(aVet[2]) == "GCB_CODTAB"})
 nGCBPRODUT := aScan(aHGcb, {|aVet| AllTrim(aVet[2]) == "GCB_PRODUT"})
 nGCBDESCRI := aScan(aHGcb, {|aVet| AllTrim(aVet[2]) == "GCB_DESCRI"})
 nGCBPRCVEN := aScan(aHGcb, {|aVet| AllTrim(aVet[2]) == "GCB_PRCVEN"})          
 nGCBPRCVUC := aScan(aHGcb, {|aVet| AllTrim(aVet[2]) == "GCB_PRCVUC"}) 
 nGCBFATOR  := aScan(aHGcb, {|aVet| AllTrim(aVet[2]) == "GCB_FATOR" })
 nGCBATIVO  := aScan(aHGcb, {|aVet| AllTrim(aVet[2]) == "GCB_ATIVO" })
 nGCBDATVIG := aScan(aHGcb, {|aVet| AllTrim(aVet[2]) == "GCB_DATVIG"})
 nGCBCODPRO := aScan(aHGcb, {|aVet| AllTrim(aVet[2]) == "GCB_CODPRO"})
 nGCBCODCON := aScan(aHGcb, {|aVet| AllTrim(aVet[2]) == "GCB_CODCON"})
 nGCBVALUC	:= aScan(aHGcb, {|aVet| AllTrim(aVet[2]) == "GCB_VALUC" })

 If nGCBVALUC > 0
 	For i := 1 To Len(aCGcb)
		aCGcb[i][nGCBVALUC] := IIF(Empty(aCGcb[i][nGCBVALUC]), '0', aCGcb[i][nGCBVALUC])
	Next i
 EndIf
 
 If nOpcA81 == 6
  Processa({|| lBMatMed := FS_BMatMed(aCGcb, @nLGcb, nUGcb)})
  If !lBMatMed 
   HS_MsgInf(STR0010, STR0011, STR0009) //"Nenhum produto encontrado no período"###"Atenção"###"Tabela de Preços MAT/MED"
   Return(.F.)
  EndIf 
 EndIf
                         
 DbSelectArea("GCA") 

 If nOpcA81 == 6 
  IF MV_PAR09 == 1
   M->GCA_TIPO := "0"
  ElseIf MV_PAR09 == 2
   M->GCA_TIPO := "1"
  EndIf   
 EndIf
 
 DbSelectArea("GCA")
 
 cG1RTipo   := M->GCA_TIPO + "4"
 cGbiTipKit := M->GCA_TIPO
 
 aSize := MsAdvSize(.T.)
 aObjects := {}	
 AAdd(aObjects, {100, 030, .T., .T.})	
 AAdd(aObjects, {100, 058, .T., .T.})	
 AAdd(aObjects, {100, 012, .T., .T., .T.})	
 
 aInfo  := { aSize[1], aSize[2], aSize[3], aSize[4], 0, 0}
 aPObjs := MsObjSize(aInfo, aObjects, .T.)
  
 DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7], 000 To aSize[6], aSize[5] Of oMainWnd Pixel
  oEnGca := MsMGet():New("GCA", nRegA81, nOpcA81,,,,, aPObjs[1],, 3)                          
  oEnGca:oBox:align := CONTROL_ALIGN_TOP
                                                                            
  oGetDados := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], nGDOpc,,,,,, 99999,,,,, aHGcb, aCGcb)
  oGetDados:oBrowse:align   := CONTROL_ALIGN_ALLCLIENT                                                      
  oGetDados:bLinhaOk        := {|| FS_A81LOk(nLGcb, aCGcb)}
  oGetDados:cFieldOk        := "HS_GDAtrib(oGetDados, {{nGCBStaReg, 'BR_AMARELO', 'BR_VERDE'}})"
  oGetDados:oBrowse:bDelete := {|| HS_GDAtrib(oGetDados, {{nGCBStaReg, "BR_CINZA", "BR_VERDE"}}), oGetDados:DelLine()}
  
  oPPesq	:=	tPanel():New(aPObjs[3, 1], aPObjs[3, 2],, oDlg,,,,,, aPObjs[3, 3], aPObjs[3, 4])
  oPPesq:Align := CONTROL_ALIGN_BOTTOM
  
 HS_GDPesqu( , , oGetDados, oPPesq, 002)        

 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nDlgA81 := 1, IIF(oGetDados:TudoOk() .And. Obrigatorio(aGets, aTela) .And. IIf(aRotina[nOpcA81,4] == 5, FS_ExclGCA(), .T.), oDlg:End(), nDlgA81 := 0)}, ;
                                                  {|| oDlg:End(), nDlgA81 := 0})

 If nDlgA81 == 1
  FS_GrvA81(nOpcA81)
  
  While __lSx8
   ConfirmSx8()
  End  
 Else
  While __lSx8
   RollBackSxe()
  End            
 EndIf
Return(.T.)


/*********************************************************************************************************/
Static Function FS_A81LOk(nLGcb, aCGcb)

 Local lRet := .T.
 
 If oGetDados:oBrowse:nAt > nLGcb .Or. ;
    oGetDados:aCols[oGetDados:oBrowse:nAt, nGCBPRODUT] <> aCGcb[oGetDados:oBrowse:nAt, nGCBPRODUT] .Or. ;
    oGetDados:aCols[oGetDados:oBrowse:nAt, nGCBDATVIG] <> aCGcb[oGetDados:oBrowse:nAt, nGCBDATVIG]
  lRet := HS_DuplAC(oGetDados:oBrowse:nAt, oGetDados:aCols, {nGCBPRODUT, nGCBDATVIG})
 EndIf 
Return(lRet)


/*********************************************************************************************************/
Static Function FS_GrvA81(nOpcA81)

 Local lAchou := .F., nCntFor := 1
 
 Begin Transaction
  If aRotina[nOpcA81, 4] # 2 // nao for consulta
   If Inclui .Or. Altera
    RecLock("GCA", Inclui .Or. nOpcA81 == 7)
     HS_GrvCpo("GCA")
     GCA->GCA_DATATU := dDataBase
     GCA->GCA_LOGARQ := HS_LogArq()
    MsUnLock()
   Else  // exclusao
    RecLock("GCA", .F., .T.)
     DbDelete()
    MsUnlock()
    WriteSx2("GCA")
   EndIf
                   
   For nCntFor := 1 To Len(oGetDados:aCols)
    If oGetDados:aCols[nCntFor, nGCBStaReg] <> "BR_VERDE"
     DbSelectArea("GCB")
     DbSetOrder(1)// GCB_FILIAL + GCB_CODTAB + GCB_PRODUT + GCB_DATVIG
     lAchou := DbSeek(xFilial("GCB") + M->GCA_CODTAB + oGetDados:aCols[nCntFor, nGCBPRODUT] + DtoS(oGetDados:aCols[nCntFor, nGCBDATVIG]))
     If Inclui .Or. Altera
      If oGetDados:aCols[nCntFor, Len(oGetDados:aCols[nCntFor])] .And. lAchou // exclusao
       RecLock("GCB", .F., .T.)
        DbDelete()
       MsUnlock()
       WriteSx2("GCB")
      ElseIf HS_VlbA81(oGetDados:aCols[nCntFor, nGCBPRODUT])
       If !oGetDados:aCols[nCntFor, Len(oGetDados:aCols[nCntFor])]
  	     RecLock("GCB", !lAchou)
  	      HS_GrvCpo("GCB", oGetDados:aCols, oGetDados:aHeader, nCntFor)
  	      GCB->GCB_FILIAL := xFilial("GCB")
  	      GCB->GCB_CODTAB := M->GCA_CODTAB
  	      GCB->GCB_LOGARQ := HS_LOGARQ()
  	     MsUnlock()
  	    EndIf 
  	   EndIf
     Else  	
      If lAchou  // opcao exclusao do menu
       RecLock("GCB", .F., .T.)
        DbDelete()
       MsUnlock()
       WriteSx2("GCB")
      EndIf   
     EndIf
    EndIf 
   Next
  EndIf
 End Transaction 
Return(.T.)



/*********************************************************************************************************/
Static Function FS_BMatMed(aCGcb, nLGcb, nUGcb)

 Local cAliasOld := Alias()
 Local nOrdSb1   := SB1->(IndexOrd()), nOrdSbm := SBM->(IndexOrd())
 
 aCGcb := {}
 DbSelectArea("SBM")
 DbSetOrder(1)// BM_FILIAL + BM_GRUPO
 DbSeek(xFilial("SBM") + MV_PAR01, .T.)
 
 ProcRegua(SB1->(RecCount()))
 
 While SBM->BM_FILIAL == xFilial("SBM") .And. SBM->BM_GRUPO <= MV_PAR02 .And. !Eof()       
                           
  DbSelectArea("SB1")
  DbSetOrder(4)// B1_FILIAL + B1_GRUPO + B1_COD
  DbSeek(xFilial("SB1") + SBM->BM_GRUPO + MV_PAR03, .T.)
  While SB1->B1_FILIAL == xFilial("SB1") .And. SB1->B1_GRUPO == SBM->BM_GRUPO .And. SB1->B1_COD <= MV_PAR04 .And. !Eof()
   DbSelectArea("GBI")
   DbSetOrder(1)// GBI_FILIAL + GBI_PRODUT
   DbSeek(xFilial("GBI") + SB1->B1_COD)
   DbSelectArea("SB1")
   
   If (MV_PAR07 == 2 .And. SB1->B1_PRV1 <= 0.00) .Or. ;
      (MV_PAR08 == 2 .And. GBI->GBI_PRODES == "0") .Or. ;
      (Str(MV_PAR09 - 1, 1) <> GBI->GBI_TIPO)
    IncProc(STR0013 + SBM->BM_GRUPO + STR0014 + SB1->B1_COD) //"Grupo - "###" Mat/Med - "
    DbSkip()
    Loop
   EndIf
    
   aAdd(aCGcb, Array(nUGcb + 1))
    
   If nGCBCODTAB > 0
    aCGcb[Len(aCGcb)][nGCBCODTAB] := M->GCA_CODTAB
   EndIf             
    
   If nGCBPRODUT > 0 
    aCGcb[Len(aCGcb)][nGCBPRODUT] := SB1->B1_COD
   EndIf
    
   If nGCBDESCRI > 0
    aCGcb[Len(aCGcb)][nGCBDESCRI] := SB1->B1_DESC
   EndIf
    
   If nGCBPRCVEN > 0
    aCGcb[Len(aCGcb)][nGCBPRCVEN] := SB1->B1_PRV1 * IIF(MV_PAR05 > 0.00, MV_PAR05, 1)
   EndIf
   
   If nGCBPRCVUC > 0
    aCGcb[Len(aCGcb)][nGCBPRCVUC] := SB1->B1_UPRC * IIF(MV_PAR05 > 0.00, MV_PAR05, 1)
   EndIf
    
   If nGCBFATOR > 0
    aCGcb[Len(aCGcb)][nGCBFATOR ] := MV_PAR06
   EndIf
    
   If nGCBATIVO > 0
    aCGcb[Len(aCGcb)][nGCBATIVO ] := IIF(GBI->GBI_PRODES == "0", "0", "1")
   EndIf
   If nGCBDATVIG > 0
    aCGcb[Len(aCGcb)][nGCBDATVIG ] := MV_PAR10
   EndIf
   
   If nGCBCODPRO > 0
    aCGcb[Len(aCGcb)][nGCBCODPRO ] := Space(20)
   EndIf
   
   If nGCBCODCON > 0
    aCGcb[Len(aCGcb)][nGCBCODCON ] := Space(20)
   EndIf
   
   If nGCBVALUC > 0
	aCGcb[Len(aCGcb)][nGCBVALUC] := IIF(Empty(aCGcb[Len(aCGcb)][nGCBVALUC]), "0", aCGcb[Len(aCGcb)][nGCBVALUC])
   EndIf
	
   aCGcb[Len(aCGcb), nUGcb + 1 ] := .F.
   
   IncProc(STR0013 + SBM->BM_GRUPO + STR0014 + SB1->B1_COD) //"Grupo - "###" Mat/Med - "
   
   nLGcb++
   
   DbSkip()
  EndDo                
   
  DbSelectArea("SBM")
  DbSkip()
 EndDo
 
 DbSetOrder(nOrdSbm)
 
 DbSelectArea("SB1")
 DbSetOrder(nOrdSb1)
 
 DbSelectArea(cAliasOld)
Return(Len(aCGcb) > 0)


Function HS_VldA81()

 Local lRet := .F. 
 Local cCampo := ReadVar()
 Local aCposGCB := {{"GCA_TAMCOD","GCB_CODPRO"},{"GCA_TAMTIS","GCB_CDTISS"},{"GCA_TAMVLR","GCB_PRCVEN"},{"GCA_QTDDEC"}} 
 Local nPos     := 0                
 Local aStruct  := {}
 Local cMsg     := ""
 Local nQtdDec  := 0
                  
 If cCampo == "M->GCA_TIPO"
  If !(lRet := !(Len(oGetDados:aCols) > 1 .Or. (Len(oGetDados:aCols) == 1 .And. !Empty(oGetDados:aCols[1, nGCBPRODUT]))))
   HS_MsgInf(STR0021, STR0011, STR0028)//"Alteração não permitida, exclua primeiro os itens da tabela"###"Atenção"###"Validação dos Campos"
  Else
   If lRet := Pertence("012")
    cG1RTipo := M->GCA_TIPO
   EndIf 
  EndIf 

 ElseIf cCampo == "M->GCB_PRODUT"
  If !(lRet := HS_SeekRet("SB1", "M->GCB_PRODUT", 1, .F., {"GCB_DESCRI", "GCB_PRCVEN"}, {"B1_DESC", "B1_PRV1"}))
   HS_MsgInf(STR0022, STR0011, STR0028) //"Produto não cadastrado (SB1)"###"Atenção"###"Validação dos Campos"
  ElseIf !(lRet := HS_SeekRet("GBI", "M->GCB_PRODUT", 1, .F.))
   HS_MsgInf(STR0023, STR0011, STR0028) //"Produto não cadastrado (GBI)"###"Atenção"###"Validação dos Campos"
  ElseIf IIf(GBI->GBI_TIPO == "4", !(lRet := GBI->GBI_TIPKIT == M->GCA_TIPO) , !(lRet := GBI->GBI_TIPO == M->GCA_TIPO))
   HS_MsgInf(STR0024 + AllTrim(GBI->GBI_PRODUT) + STR0025, STR0011, STR0028) //"Tipo do produto ["###"] não permitido na tabela de preço"###"Atenção"###"Validação dos Campos"
  Else
   oGetDados:aCols[n, nGCBPrcVUC] := SB1->B1_UPRC
  EndIf 
 ElseIf cCampo == "M->GCA_TBTISS" 
  If !EMPTY(M->GCA_TBTISS) .And. !(lRet := HS_SeekRet("G24", "M->GCA_TBTISS", 1, .F., "GCA_DTBTIS", "G24_DESCRI",,, .T.))
   HS_MsgInf(STR0032, STR0011, STR0033) //"Tabela do TISS não encontrada"###"Atenção"###"Validação dos campos"
  EndIf
 ElseIf cCampo == "M->GCB_CODPRO"
  If HS_ExisDic({{"C", "GCA_FVCDPR"}}, .F.)
   lRet:= IIf(!Empty(M->GCA_FVCDPR), &(M->GCA_FVCDPR), .T.)
  EndIf
 ElseIf (nPos := aScan(aCposGCB,{|aVet| aVet[1] == SubStr(cCampo,4)})) > 0
  nQtdDec := IIF(HS_ExisDic({{"C","GCA_QTDDEC"}},.F.),IIF(M->GCA_QTDDEC > 0,M->GCA_QTDDEC,-1),-1)     
  If (cCampo # "M->GCA_QTDDEC") .And. !(lRet := &(cCampo) <= TamSx3(aCposGCB[nPos,2])[1])
   aStruct :=  HS_CfgSx3(aCposGCB[nPos,1])
   cMsg    := STR0044+chr(10)+chr(13)+STR0045 //"Tamanho defindo inválido."###"O conteúdo do campo "
   cMsg    += aStruct[Sx3->(FieldPos("X3_TITULO"))]+"("+aCposGCB[nPos,1]+") "
   aStruct :=  HS_CfgSx3(aCposGCB[nPos,2])
   cMsg    += STR0046 //"não pode ser maior do que o tamanho do campo "
   cMsg    += aStruct[Sx3->(FieldPos("X3_TITULO"))]+"("+aCposGCB[nPos,2]+") "  
  ElseIf (cCampo $ "M->GCA_QTDDEC/M->GCA_TAMVLR") 
   If !(lRet := M->GCA_TAMVLR >= nQtdDec)
    cMsg := STR0044+chr(10)+chr(13)//"Tamanho defindo inválido."
    cMsg := STR0047 //"Número de casas decimais deve ser menor do  que o tamanho do valor"
   ElseIf !(lRet := M->GCA_TAMVLR - (nQtdDec + 1) <= TamSx3("GCB_PRCVEN")[1] - (TamSx3("GCB_PRCVEN")[2]+1))
	aStruct :=  HS_CfgSx3("GCA_TAMVLR")
    cMsg := STR0044 + chr(10) + chr(13)+STR0045 //"Tamanho defindo inválido."###"O conteúdo do campo "
    cMsg += aStruct[Sx3->(FieldPos("X3_TITULO"))] + "(GCA_TAMVLR) " //"Configuração permite que o valor exceda o tamanho suportado pelo Protheus."
	aStruct :=  HS_CfgSx3("GCB_PRCVEN")
    cMsg += STR0046 //"não pode ser maior do que o tamanho do campo "
    cMsg += aStruct[Sx3->(FieldPos("X3_TITULO"))]+"(GCB_PRCVEN) " 
   EndIf
  EndIf 
 
  If !Empty(cMsg)
   HS_MsgInf(cMsg, STR0011, STR0033) //"Atenção"###"Validação dos campos"
  EndIf 
 EndIf
 
Return(lRet)  


Static Function HS_VlbA81(cVemProd)
 Local aAreaOld := GetArea()
 Local lRet := .F., cTipProd := ""

 /* se o Tipo do Produto for KIT, entao pega o Tipo do Produto Kit, no campo GBI_TIPKIT */
 DbSelectArea("GBI")
 DbSetorder(1)// GBI_FILIAL + GBI_PRODUT
 If DbSeek(xFilial("GBI") + cVemProd)
  cTipProd := IIF(GBI->GBI_TIPO == "4", GBI->GBI_TIPKIT, GBI->GBI_TIPO )
  If !(lRet := (cTipProd == M->GCA_TIPO) )
   HS_MsgInf(STR0026 + AllTrim(GBI->GBI_PRODUT) + STR0027, STR0011, STR0028) //"Tipo do produto ["###"] não permitido na tabela de preço"###"Atenção"###"Validação dos Campos"
  EndIf      
 Else
  HS_MsgInf(STR0034 + AllTrim(cVemProd) + STR0035, STR0011, STR0033)  //"Produto ["###"] não encontrado"###"Atenção"###"Validação dos Campos"
 EndIf 

 RestArea(aAreaOld)
 
Return(lRet)  


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_A81REAJ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 31.03.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualizacao da tabela de precos                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Gestao Hospitalar                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/
Function HS_A81REAJ

Local aArea := GetArea()

If !Pergunte("HSA81R", .T.)
 Return(.F.)
EndIf     

If MsgYesNo(STR0015 + GCA->GCA_CODTAB, STR0011) //"Confirma atualização de Preços da Tabela "###"Atenção"
 Processa({|| FS_GerRea()}, STR0016 + GCA->GCA_CODTAB) //"Processando Tabela "
EndIf

RestArea(aArea)

Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_GerRea ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 31.03.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Processa a reajuste da tabela de precos                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Funcao HS_A81REAJ                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/
Static Function FS_GerRea
 Local nValAntV := 0
 Local nValAntC := 0
 Local nValNovo	:= 0
 Local nValNoUC	:= 0 
 Local nPorRea  := MV_PAR01
 Local nAtuOri  := MV_PAR02
 Local dDatVig  := MV_PAR03
 Local nAtuMenor:= MV_PAR04
 Local lAtuVig  := MV_PAR05 == 1
 Local lCriaNovo:= .T.
 Local cQuery			:= ""

 cQuery := "SELECT GCB.GCB_PRODUT, MAX(GCB.GCB_DATVIG) GCB_DATVIG "
 cQuery += "FROM " + RetSQLName("GCB") + " GCB "
 cQuery += "WHERE GCB.GCB_FILIAL = '" + xFilial("GCB") + "' "	
 cQuery += "AND GCB.GCB_CODTAB = '" + GCA->GCA_CODTAB + "' "	
 cQuery += "AND GCB.D_E_L_E_T_ <> '*' "
 cQuery += "GROUP BY GCB.GCB_PRODUT"

 cQuery := ChangeQuery(cQuery)

 DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), "TRB", .F., .F.)

 DbSelectArea("TRB")
 ProcRegua(100)

 Do While !Eof()
	IncProc(OemToAnsi(STR0004) + "  " + TRB->GCB_PRODUT) // Alterar

	nValAntV := 0
	nValAntC := 0
	nValNovo	:= 0
	nValNoUC	:= 0
  lCriaNovo := .T.

 DbSelectArea("GCB")
  DbSetOrder(1) //FILIAL + CODTAB + PRODUT + DATVIG
  DbSeek(xFilial("GCB") + GCA->GCA_CODTAB + TRB->GCB_PRODUT + TRB->GCB_DATVIG)

 DbSelectArea("SB1")
  DbSetOrder(1) // B1_FILIAL + B1_COD
 DbSeek(xFilial("SB1") + GCB->GCB_PRODUT)

 nValAntV := GCB->GCB_PRCVEN
 nValAntC := GCB->GCB_PRCVUC
 
	 nValNovo := IIf(nAtuOri == 1, nValAntV * (1 + nPorRea/100), SB1->B1_PRV1 * (1 + nPorRea/100))
	
	 If nValNovo <> nValAntV .And. dDatVig >= STOD(TRB->GCB_DATVIG)
 
 	 If nAtuMenor == 2 .And. nValNovo < nValAntV    
    DbSelectArea("TRB")
    DbSkip()
   	Loop
	 EndIf
	 
 	 If dDatVig == STOD(TRB->GCB_DATVIG) 
    If lAtuVig
     lCriaNovo := .F.
	Else
     DbSelectArea("TRB")
     DbSkip()
     Loop
  EndIf	
	EndIf

 	 Begin Transaction 

    nValNoUC	:= SB1->B1_UPRC * (1 + nPorRea/100)
   
    DbSelectArea("GCA")
    RecLock("GCA", .F.)
     GCA->GCA_DATATU := dDataBase
     GCA->GCA_LOGARQ := HS_LOGARQ()
    MsUnLock()
 
  DbSelectArea("GCB")
  RegToMemory("GCB", .F.)

    RecLock("GCB", lCriaNovo)
   HS_GrvCpo("GCB")
 	 GCB->GCB_FILIAL := xFilial("GCB")
     GCB->GCB_PRCVEN := nValNovo 
   GCB->GCB_PRCVUC := nValNoUC
   GCB->GCB_DATVIG := dDatVig
  MsUnLock()
    
  DbSelectArea("GCC")
  RecLock("GCC", .T.)
   GCC->GCC_FILIAL := xFilial("GCC") 
   GCC->GCC_ROTINA := "HSPAHA81"
   GCC->GCC_PRODUT := SB1->B1_COD
   GCC->GCC_DESCRI := SB1->B1_DESC
   GCC->GCC_DATATU := dDataBase	
	  GCC->GCC_VANTUV := nValAntV 								//Prc. de Venda Anterior UV
	  GCC->GCC_VATUUV := nValNovo 								//Prc. de Venda Atual UV
	  GCC->GCC_VANTUC := nValAntC 								//Prc. de Venda Anterior UC
	  GCC->GCC_VATUUC := nValNoUC									//Prc. de Venda Atual UC
  MsUnlock()  
 
   End Transaction

 EndIf 

 DbSelectArea("TRB")
 DbSkip()

 EndDo
 
 DbSelectArea("TRB")
 DbCloseArea()

Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ HS_A81Atu ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 04.04.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atualizacao da tabela de precos a partir de um TXT          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSP                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/
Function HS_A81Atu

Local aArea 		:= GetArea()

If !Pergunte("HSA81A", .T.)
 Return(.F.)
EndIf     

If MsgYesNo(STR0015 + GCA->GCA_CODTAB, STR0011) //"Confirma atualização de Preços da Tabela "###"Atenção"
 Processa({|| FS_GerAtu()}, STR0016 + GCA->GCA_CODTAB) //"Processando Tabela "
EndIf

RestArea(aArea)

Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_GerAtu ³ Autor ³ Robson Ramiro A. Olive³ Data ³ 04.04.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Processa a atualizacao da tabela de precos                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ HSP                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
*/
Static Function FS_GerAtu
	Local nTamLin  := IIF(GCA->(FieldPos("GCA_TAMLIN")) > 0,GCA->GCA_TAMLIN, Val(HS_PreCpo(STR0029, STR0030, 10,))) //"Atualização da Tabela de Preço"###"Informe o tamanho máximo de linhas"
	Local cArq     := Trim(GCA->GCA_NOMARQ)
	Local nHdl     := Nil
	Local cBuffer  := Space(nTamLin + 2)
	Local nBytes   := 0
	Local cCodigo 	:= ""
	Local cValor   := ""
	Local cCAntTis := "", cCAtuTis := ""
	Local nValor	 	:= 0
	Local nFatorD 	:= 0
	Local nValAntV := 0
	Local nValAntC := 0
	Local nValNovo	:= 0
	Local nValNoUC	:= 0
	Local nRetGcb  := 0
	Local aArea    := GetArea()

	Local aCampos  := {}
	Local cTabRec   := ""
	Local cAliasRec := "TMPLST"
	Local cInd1     := ""
	Local cSql      := ""
	Local nQtdDec   := IIF(HS_EXISDIC({{"C", "GCA_QTDDEC"}}, .F.),GCA->GCA_QTDDEC,2)
	Local lCAtuTis  := HS_EXISDIC({{"C", "GCA_COLTIS"}, {"C", "GCA_TAMTIS"}}, .F.)
 
	Local oTempTable
 
	nHdl := fOpen(cArq, 2) // Abre o arquivo

	If nHdl == -1
		HS_MsgInf(STR0017, STR0011, STR0029) //"Arquivo não pode ser aberto!"###"Atenção"###"Atualização da Tabela de Preço"
		Return()
	EndIf

	If nTamLin == 0
		Hs_MsgInf(STR0031, STR0011,STR0029)//"Tamanho de linhas especificado inválido"###"Atenção"###"Atualização da Tabela de Preço"
		Return()
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria a estrutura do arquivo temporario          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//              Nome       Tipo                     Tamanho                   Decimal
	aAdd(aCampos, {"CODIGO" , TamSX3("GCB_CODPRO")[3], TamSX3("GCB_CODPRO")[1], TamSX3("GCB_CODPRO")[2]})
	aAdd(aCampos, {"VALOR"  , TamSX3("GCB_PRCVEN")[3], TamSX3("GCB_PRCVEN")[1], TamSX3("GCB_PRCVEN")[2]})
	aAdd(aCampos, {"CATUTIS", TamSX3("GCB_CDTISS")[3], TamSX3("GCB_CDTISS")[1], TamSX3("GCB_CDTISS")[2]})
	aAdd(aCampos, {"FATORD" , TamSX3("GCB_FATOR" )[3], TamSX3("GCB_FATOR" )[1], TamSX3("GCB_FATOR" )[2]})

	//--< Criação do objeto FWTemporaryTable >---
	oTempTable := FWTemporaryTable():New( cAliasRec )
	oTempTable:SetFields( aCampos )
	oTempTable:AddIndex( "INDREC",{ "CODIGO" } )

	if( select( cAliasRec ) > 0 )
		( cAliasRec )->( dbCloseArea() )
	endIf

	oTempTable:Create()

	nBytes := fRead(nHdl, @cBuffer, nTamLin + 2)

	ProcRegua(nBytes)

	DbSelectArea(cAliasRec)
	DbSetOrder(1)
	Do While nBytes == nTamLin + 2

		cCodigo := Substr(cBuffer, GCA->GCA_COLINI, GCA->GCA_TAMCOD)
		cValor  := Substr(cBuffer, GCA->GCA_COLINV, GCA->GCA_TAMVLR)
 
		If lCAtuTis
			cCAtuTis := Substr(cBuffer, GCA->GCA_COLTIS, GCA->GCA_TAMTIS)
		Endif
 
		If At(".", cValor) > 0 .Or. At(",", cValor) > 0
			nValor	:= SuperVal(cValor)
		Else
			nValor := Superval(cValor) * (10 ^ (-nQtdDec))
		EndIf
	 
		If GCA->GCA_COLFAT <> 0 .And. GCA->GCA_TAMFAT <> 0
			nFatorD	:= SuperVal(Substr(cBuffer, GCA->GCA_COLFAT, GCA->GCA_TAMFAT))
		EndIf
 
		lAchou := Dbseek(cCodigo)

		RecLock(cAliasRec,!lAchou)
		&(cAliasRec+"->CODIGO")  := cCodigo
		&(cAliasRec+"->VALOR")   := nValor
		&(cAliasRec+"->CATUTIS") := cCAtuTis
		&(cAliasRec+"->FATORD")  := nFatorD
		MsUnlock()
	  
		nBytes := fRead(nHdl, @cBuffer, nTamLin + 2)

	EndDo
	
	fClose(nHdl)
	  
	cSql := " SELECT GCB.GCB_PRODUT, GCB.GCB_CODPRO, GCB.GCB_DESPRO, GCB.GCB_DATVIG, GCB_PRCVEN, GCB_PRCVUC, "
	cSql += "        GCB_FATOR, GCB_ATIVO "
	cSql += IIF(HS_EXISDIC({{"C", "GCB_CDTISS"}}, .F.),",  GCB_CDTISS ","")
	cSql += "   FROM "+RetSqlName("GCB")+" GCB "
	cSql += "  WHERE GCB.GCB_FILIAL = '"+xFilial("GCB")+"' AND GCB.D_E_L_E_T_ <> '*' AND GCB.GCB_CODTAB = '"+GCA->GCA_CODTAB+"' "
	cSql += "    AND GCB_CODPRO <> '" + Space(TamSX3("GCB_CODPRO")[1]) + "' "
	cSql += "    AND GCB_DATVIG = (SELECT MAX(GCB_DATVIG) "
	cSql += "                        FROM "+RetSqlName("GCB")+" GCB2 "
	cSql += "                       WHERE GCB2.GCB_FILIAL = GCB.GCB_FILIAL "
	cSql += "                         AND	GCB2.GCB_CODTAB = GCB.GCB_CODTAB "
	cSql += "                         AND GCB2.GCB_PRODUT = GCB.GCB_PRODUT "
	cSql += "                         AND GCB2.D_E_L_E_T_ <> '*')	"
		   
	cSql := ChangeQuery(cSql)
	TcQuery cSql NEW ALIAS "TMPPRO"
 
	Begin Transaction

		DbSelectArea("GCA")
		RecLock("GCA", .F.)
		GCA->GCA_DATATU := dDataBase
		GCA->GCA_LOGARQ := HS_LOGARQ()
		MsUnLock()

		DbSelectArea("TMPPRO")
		DbGotop()
		
		While TMPPRO->(!EOF())
  
			DbSelectArea(cAliasRec)
			DbSetOrder(1)
 
			If !DbSeek(TMPPRO->GCB_CODPRO) .Or. TMPPRO->GCB_DATVIG ==  DTOS(MV_PAR02)
				DbSelectArea("TMPPRO")
				DbSkip()
				Loop
			EndIf
		
			IncProc(OemToAnsi(STR0004) + "  " + TMPPRO->GCB_PRODUT) // Alterar

			cCodigo	 := &(cAliasRec+"->CODIGO")
			nValor	  := &(cAliasRec+"->VALOR")
			cCAtuTis := &(cAliasRec+"->CATUTIS")
			nFatorD	 := &(cAliasRec+"->FATORD")
			nValAntV := 0
			nValAntC := 0
			nValNovo	:= 0
			nValNoUC	:= 0
  
			DbSelectArea("SB1")
			DbSetOrder(1)// B1_FILIAL + B1_COD
			If DbSeek(xFilial("SB1") + TMPPRO->GCB_PRODUT)
				If HS_EXISDIC({{"C", "GCB_CDTISS"}}, .F.)
					cCAntTis := TMPPRO->GCB_CDTISS
				Endif
				nValAntV := TMPPRO->GCB_PRCVEN
				nValAntC := TMPPRO->GCB_PRCVUC
 	 
				DbSelectArea("GBI")
				DbSetOrder(1)// GBI_FILIAL + GBI_PRODUT
				DbSeek(xFilial("GBI") + SB1->B1_COD)
 	 
				If nFatorD > 0 // Fator de divisão do brasindice
					nValor := (nValor / nFatorD)
				EndIf
		 
				If GBI->GBI_FDVBRA > 0 // Fator de divisão do hospital
					nValor	:= (nValor / GBI->GBI_FDVBRA)
				EndIf
		 
				If GBI->GBI_FMTHSP > 0 // Fator de multiplicação do hospital
					nValor	:= (nValor * GBI->GBI_FMTHSP)
				EndIf

				nValNovo := nValor * MV_PAR01
				nValNoUC	:= SB1->B1_UPRC * MV_PAR01

				RecLock("SB1", .F.)
				SB1->B1_PRV1 := nValNovo
				MsUnLock()
 	 
				RecLock("GCB", .T.)
				GCB->GCB_FILIAL := xFilial("GCB")
				GCB->GCB_CODTAB := GCA->GCA_CODTAB
				GCB->GCB_PRODUT := TMPPRO->GCB_PRODUT
				GCB->GCB_PRCVEN := nValNovo  // atribui novas informacoes
				GCB->GCB_PRCVUC := nValNoUC
				GCB->GCB_ATIVO  := "1"
				GCB->GCB_CODPRO := TMPPRO->GCB_CODPRO
				GCB->GCB_DESPRO := TMPPRO->GCB_DESPRO
				GCB->GCB_FATOR  := TMPPRO->GCB_FATOR

				GCB->GCB_DATVIG := MV_PAR02
				GCB->GCB_LOGARQ := HS_LOGARQ()
				If HS_EXISDIC({{"C", "GCB_ORIGEM"}, {"C", "GCB_CDTISS"}}, .F.)
					GCB->GCB_ORIGEM := '0'
					GCB->GCB_CDTISS := cCAtuTis
				Endif
				MsUnLock()

				DbSelectArea("GCC")
				RecLock("GCC", .T.)
				GCC->GCC_FILIAL := xFilial("GCC")
				GCC->GCC_ROTINA := "HSPAHA81"
				GCC->GCC_PRODUT := SB1->B1_COD
				GCC->GCC_DESCRI := SB1->B1_DESC
				GCC->GCC_DATATU := dDataBase
				GCC->GCC_VANTUV := nValAntV 								//Prc. de Venda Anterior UV
				GCC->GCC_VATUUV := nValNovo 								//Prc. de Venda Atual UV
				GCC->GCC_VANTUC := nValAntC 								//Prc. de Venda Anterior UC
				GCC->GCC_VATUUC := nValNoUC									//Prc. de Venda Atual UC
				If HS_EXISDIC({{"C", "GCC_CANTTI"}, {"C", "GCC_CATUTI"}}, .F.)
					GCC->GCC_CANTTI := cCAntTis        // Codigo TISS Anterior
					GCC->GCC_CATUTI := cCAtuTis        // Codigo TISS Atual
				Endif
				MsUnlock()
 
				DbSelectArea("TMPPRO")
				DbSkip()
			EndIF
		End
  
	End Transaction

	if( select( cAliasRec ) > 0 )
		oTempTable:delete()
	endIf

	DbSelectArea("TMPPRO")
	DbCloseArea()

	RestArea(aArea)

	HS_PosSX1({{"HSPR23", "01", GCA->GCA_CODTAB}, {"HSPR23", "02", "'"+DTOC(MV_PAR02)+"'"}})
	HSPAHR23()
Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	   ³HS_A81DIR ³ Autor ³ Robson Ramiro Oliveira³ Data ³ 05.04.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria uma consulta padrao "GH3" com cGetFile                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		    ³ Gestao Hospitalar                          													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function HS_A81DIR()

Local cMask := ""

If Type("cMaskTISS") <> "U" .And. !Empty(cMaskTISS)  // mascara utilizada no Cadastro de Convenio no campo GA9_LOGOTP - Logo Tipo, para o TISS
 cMask := cMaskTISS
Else
 cMask := PadR(STR0018, 27) + "|*.txt|" + PadR(STR0019, 27)+ "|*.*|" //"Texto (*.txt)"###"Todos (*.*)"
EndIf

__RetGH3 := cFile := Trim(cGetFile(OemToAnsi(cMask), OemToAnsi(STR0020), 0,, .F., GETF_ONLYSERVER+GETF_NETWORKDRIVE)) //"Selecione o Arquivo"

Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	   ³HS_A81RET ³ Autor ³ Robson Ramiro Oliveira³ Data ³ 05.04.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Somente retorno da consulta padrao "GH3"                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		    ³ Gestao Hospitalar                           													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function HS_A81RET

Return __RetGH3

/*
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_DescA81º Autor ³ Daniel Peixoto     º Data ³  23/09/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina de validacao dos campos de descricao.               º±±
±±º          ³ Chamada do X3_RELACAO do campo de Acordo com o Parametro   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_DescA81(cAlias, nCpo)

 Local cCodChave := ""
 Local cDescri   := ""  
 
 If cAlias == "GCB"
  cCodChave := IIF(Inclui, "", IIF(Alias() == "TMPGCB", (Alias())->GCB_PRODUT, ""))
  If !Empty(cCodChave)
   cDescri := HS_IniPadr("SB1", 1, cCodChave, "B1_DESC" ,, .F.)
  EndIf 
 EndIf
 
Return(cDescri)         

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Funcao   ³ HS_PreCpo³ Autor ³ Mario Arizono         ³ Data ³ 25/04/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descricao³  Mostra tela para digitacao do campo.                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³ Uso      ³ FS_GerAtu                                                  ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_PreCpo(cTitulo, cMsg, nTamanho, cValid)

Local oDlgMsg, oEdiCpo, oBtnOk
Local cEditCpo := Space(nTamanho)

DEFINE MSDIALOG oDlgMsg FROM	62, 100 To 320, 510 TITLE OemToAnsi(cTitulo) PIXEL

@ 003, 008 TO 027, 196 LABEL OF oDlgMsg PIXEL 

@ 010, 010 MSGET oEdiCpo VAR cEditCpo VALID IIF(Empty(cValid), .T., FS_VALCPO(cValid, cEditCpo)) SIZE 100, 010 OF oDlgMsg PIXEL

@ 036, 008 GET oTexto VAR OemToAnsi(cMsg) MEMO READONLY SIZE 188, 070 OF oDlgMsg PIXEL

oBtnOk := tButton():New(115, 170, "Ok", oDlgMsg, {|| oDlgMsg:End()},,,,,, .T.)
oBtnOk:SetFocus()

ACTIVATE MSDIALOG oDlgMsg CENTERED

Return(cEditCpo)
                                                   
Static Function FS_ValCpo(cValid, cEditCpo)

 If Substr(cValid, Len(cValid) - 1) == "()"
  cValid := Substr(cValid, 1, Len(cValid) - 1) + "'" + cEditCpo + "')"  
 Else
  cValid := cValid + "(" + "'" + cEditCpo + "')" 
 EndIf
 
 &cValid    
 
Return() 

Static Function FS_ExclGCA()
 Local aArea := GetArea()
 Local lRet	 := .T.

 If (HS_CountTB("GD9", "GD9_CODMAT = '" + M->GCA_CODTAB + "'")  > 0) 
  HS_MsgInf(STR0036, STR0011, STR0037) //"Tabela de preços Mat/Met possui relacionamento com Planos X Tabela Preço Materias"###"Atenção"###"Validação de exclusão" 
 	lRet := .F.
 ElseIf (HS_CountTB("GDA", "GDA_CODMED = '" + M->GCA_CODTAB + "'")  > 0) 
  HS_MsgInf(STR0038, STR0011, STR0037) //"Tabela de preços Mat/Met possui relacionamento com Planos X Tabela Preço Medicamentos"###"Atenção"###"Validação de exclusão"
 	lRet := .F.
 Endif
                                                                                                                      
 RestArea(aArea)
Return(lRet) 

Function HS_A81SUS()
 Local aArea := GetArea()

 If !Pergunte("HSA81S", .T.)
  Return(.F.)
 EndIf     

 If MsgYesNo(STR0042 + GCA->GCA_CODTAB) //"Confirma atualização de tabelas de Mat/Med - SUS "
  Processa({|| FS_AtuSUS()}, STR0016 + GCA->GCA_CODTAB) //"Processando tabela "
 EndIf
 RestArea(aArea)
Return()

Static Function FS_AtuSUS()
 Local aArea := GetArea()
 Local cSql  := ""
 Local dVigencia := MV_PAR01
 
 ProcRegua(0)
 
 //Seleciona todos os procedimentos cujo próprio estaja na tabela (GMV) do SUS
 cSql := "SELECT DISTINCT GCB.GCB_PRODUT,GCB.GCB_CODPRO,GMV.GMV_DESCRI,GMV.GMV_VLRAS,GMV.GMV_VLSRVH,GMV.GMV_VLSRVP, GMV.GMV_VLSADT "
 cSql += "FROM " + RetSqlName("GCB") + " GCB "
 cSql +=   "JOIN " + RetSqlName("GMV") + " GMV ON GMV.GMV_FILIAL = '" + xFilial("GMV") + "' AND GMV.D_E_L_E_T_ <> '*' AND "
 cSql +=                                        " GMV.GMV_CODSUS = SUBSTRING(GCB.GCB_CODPRO,1," + AllTrim(Str(Len(GMV->GMV_CODSUS))) + ") "
 cSql += "WHERE GCB.GCB_FILIAL = '" + xFilial("GCB") + "' AND GCB.D_E_L_E_T_ <> '*' AND GCB.GCB_CODTAB = '" + GCA->GCA_CODTAB + "' AND GCB.GCB_ATIVO = '1' "
 
 cSql := ChangeQuery(cSql)
 TcQuery cSql NEW ALIAS "TMPPRO"
 
 DbSelectArea("TMPPRO")
 DbGotop()
 
 While !TMPPRO->(Eof())
  IncProc(STR0043 + TMPPRO->GCB_PRODUT)//"Atualizando "
  DbSelectArea("GCB")
  DbSetOrder(3) //GCB_FILIAL+GCB_CODTAB+GCB_PRODUT+GCB_CODPRO+DTOS(GCB_DATVIG)
  lAchou :=  DbSeek(xFilial("GCB") + GCA->GCA_CODTAB + TMPPRO->GCB_PRODUT + TMPPRO->GCB_CODPRO + DTOS(dVigencia))
  RecLock("GCB", !lAchou)
  	GCB->GCB_FILIAL := xFilial("GCB")
   GCB->GCB_PRODUT := TMPPRO->GCB_PRODUT
   GCB->GCB_CODTAB := GCA->GCA_CODTAB
   GCB->GCB_CODPRO := Iif(lAchou, GCB->GCB_CODPRO, TMPPRO->GCB_CODPRO)
   GCB->GCB_DESPRO := Iif(lAchou, GCB->GCB_DESPRO, TMPPRO->GMV_DESCRI)
   GCB->GCB_DATVIG := dVigencia
   GCB->GCB_PRCVEN := IIf(!Empty(TMPPRO->GMV_VLRAS), TMPPRO->GMV_VLRAS, TMPPRO->GMV_VLSRVH + TMPPRO->GMV_VLSRVP + TMPPRO->GMV_VLSADT)
   GCB->GCB_PRCVUC := IIf(!Empty(TMPPRO->GMV_VLRAS), TMPPRO->GMV_VLRAS, TMPPRO->GMV_VLSRVH + TMPPRO->GMV_VLSRVP + TMPPRO->GMV_VLSADT)
   GCB->GCB_FATOR  := Iif(lAchou, GCB->GCB_FATOR, 1.0)
   GCB->GCB_ATIVO  := "1"
  MsUnlock()
  
  TMPPRO->(DbSkip())
 End
 
 TMPPRO->(DbCloseArea())
 
 RestArea(aArea)
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ MenuDef  ³ Autor ³ Tiago Bandeira        ³ Data ³ 06/06/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Definição do aRotina (Menu funcional)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MenuDef()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Gera arquivo TXT para exportacao                      ³
//³    4 - Recebe arquivo TXT                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aRotina :=	{{OemToAnsi(STR0001), "axPesqui"   , 0, 1, 0, Nil},; //01-"Pesquisar" 
                  {OemToAnsi(STR0002) , 'HS_A81Roti', 0, 2, 0, Nil},; //02-"Visualizar"
                  {OemToAnsi(STR0003) , 'HS_A81Roti', 0, 3, 0, Nil},; //03-"Incluir" 
                  {OemToAnsi(STR0004) , 'HS_A81Roti', 0, 4, 0, Nil},; //04-"Alterar" 
                  {OemToAnsi(STR0005) , 'HS_A81Roti', 0, 5, 0, Nil},; //05-"Excluir" 
                  {OemToAnsi(STR0006) , 'HS_A81Roti', 0, 3, 0, Nil},; //06-"Gerar"
                  {OemToAnsi(STR0007) , 'HS_A81Roti', 0, 4, 0, Nil},; //07-"Copiar"
                  {OemToAnsi(STR0012) , 'HS_A81Atu' , 0, 2, 0, Nil},; //08-"Atualizar"
                  {OemToAnsi(STR0008) , 'HS_A81REAJ', 0, 2, 0, Nil}} //09-"Reajuste"
                 // {OemToAnsi(STR0041) , 'HS_A81SUS' , 0, 4, 0, Nil}}
Return(aRotina)