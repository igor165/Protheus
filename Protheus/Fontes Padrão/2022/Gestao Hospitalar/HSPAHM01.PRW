#INCLUDE "HSPAHM01.ch"
#INCLUDE "Protheus.CH"
#INCLUDE "Colors.CH"
#INCLUDE "TopConn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM01  บ Autor ณ Patricia Queiroz   บ Data ณ  24/10/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Coleta                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHM01()

 Local bKeyF12 := SetKey(VK_F12, {|| FS_FilM01(.T.)})
 
 Local aCampos := {{"C", "GGP_UNICOL"}, ;
                   {"C", "GGP_REGGER"}, ;
                   {"C", "GGP_LOCATE"}, ;                   
                   {"C", "GGP_DLOATE"}, ;
                   {"C", "GGQ_UNICOL"},;
                   {"C", "GGQ_IDMARK"}}
                   
 Local aCor := {{"GGO->GGO_SITCOL == '0'", "BR_AMARELO" }, ;
                {"GGO->GGO_SITCOL == '5'", "BR_VERDE"   }, ;
                {"GGO->GGO_SITCOL == '1'", "BR_LARANJA" }, ;
                {"GGO->GGO_SITCOL == '2'", "BR_CINZA"   }, ;
                {"GGO->GGO_SITCOL == '3'", "BR_AZUL"    }, ;
                {"GGO->GGO_SITCOL == '4'", "BR_VERMELHO"}} 

 Local aRotLote := {{OemtoAnsi(STR0057), "HS_MntLote" , 0, 3}, ; //"Gerar Protocolo"
                    {OemtoAnsi(STR0058), "HS_MntLote" , 0, 4}, ; //"Atrib. Amostra"
                    {OemtoAnsi(STR0059), "HS_MntSai"  , 0, 4}, ; //"Saํda"
                    {OemtoAnsi(STR0060), "HS_EtqM02"  , 0, 4}, ; //"Etiqueta"
                    {OemtoAnsi(STR0061), "HSPAHR13()" , 0, 4}}   //"Impressใo"
                    
                    
 Private lGGOInclui  := .T.               
 Private cFilM01     := ""
 Private cPerg       := "HSPM01"
 Private cLctCodLoc  := "" 
 Private cLocCodCol  := ""
 Private cCodProt    := ""
 Private __aMarkBrow := {}
 Private cLote       := Space(Len(GGP->GGP_CDPROT)) 
 Private aRotina     := {{OemtoAnsi(STR0001), "axPesqui" , 0, 01}, ; //"Pesquisar"
                         {OemtoAnsi(STR0002), "HS_MntM01", 0, 02}, ; //"Visualizar"
                         {OemtoAnsi(STR0003), "HS_MntM01", 0, 04}, ; //"Confirmar"
                         {OemtoAnsi(STR0004), "HS_MntM01", 0, 04}, ; //"Alterar"
                         {OemtoAnsi(STR0005), "HS_MntM01", 0, 04}, ; //"Concluir"
                         {OemtoAnsi(STR0049), aRotLote   , 0, 03}, ; //"Amostra"
                         {OemtoAnsi(STR0023), "HS_RelM01", 0, 02}, ; //"Docs/Relat"                     
                         {OemtoAnsi(STR0007), "HS_LegM01", 0, 01}}   //"Legenda"
                     
                     
 If !HS_ExisDic(aCampos) 
  Return(.F.)
 EndIf
 
 DbSelectArea("GGV")
 DbSelectArea("GGO")
 
 If FS_FilM01(.F.)
  mBrowse(06, 01, 22, 75, "GGO",,,,,, aCor,,,,,,,, cFilM01)
 EndIf
 
 SetKey(VK_F12, bKeyF12)
 
Return(Nil)


Static Function FS_FilM01(lSetFilter)

 Local lRet     := .T.
 Local oObjMBrw := GetObjBrow()
 Local cLocAte  := "", cLocCol := ""
 Local dDatini, dDatFim
 
 If !Pergunte(cPerg)
  Return(.F.)
 EndIf
 
 cLocCol := MV_PAR01
 cLocAte := MV_PAR02 
 dDatini := MV_PAR03
 dDatFim := MV_PAR04 
  
 cFilM01 := "GGO_FILIAL = '" + xFilial("GGO") + "' "
 If !Empty(dDatIni)
  cFilM01 += "AND GGO_DATLIB >= '" + DTOS(dDatIni) + "' "
 EndIf
 If !Empty(dDatIni)
  cFilM01 += "AND GGO_DATLIB <= '" + DTOS(dDatFim) + "' "
 EndIf
 If !Empty(cLocAte)
 	cFilM01 += "AND GGO_LOCATE = '" + cLocAte + "' "
 EndIf
 
 If lSetFilter
  MsgRun(STR0045, ,{|| SetMBTopFilter("GGO", cFilM01), oObjMBrw:GoTop(), oObjMBrw:Refresh()}) //"Selecionando registros...", "Aguarde..." 
 EndIf
 
 cLocCodCol := cLocCol  //Setor selecionado 
 
 DbSelectArea("GGO")
 
Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_MntM01 บ Autor ณ Patricia Queiroz   บ Data ณ  24/10/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Tratamento das funcoes                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_MntM01(cAliasM01, nRegM01, nOpcM01)

 Local nOpcA    := 0
 Local nGDOpc   := 0
 Local aSize    := {}, aObjects := {}, aInfo := {}, aPObjs := {}, aPGDM := {}, oFolGDM 
 Local oGGO, oGGL, aCposAlt := {}
 Local aHGGL := {}, aCGGL   := {}
 Local aHMM  := {}, aCMM    := {}
 Local aHTD  := {}, aCTD    := {}
 Local aHPR  := {}, aCPR    := {}
 Local aButtons := {}
 
 Private oGDPR, oGDMM, oGDTD  
 Private aTela := {}
 Private aGets := {}  
 Private nGGLIDMARK := 0; nGGLCDTIPA := 0; nGGLQTDAMO := 0 
 Private cRegAte  := "" 
 Private aAmostra := {}
 cLctCodLoc  := GGO->GGO_LOCATE
  
 If ((nOpcM01 == 3 .Or. nOpcM01 == 4) .And. GGO->GGO_SITCOL <> "5")
  HS_MsgInf(STR0012, STR0014, STR0015) //"A coleta s๓ poderแ ser confirmada ou alterada se a situa็ใo for: Liberada."###"Aten็ใo"###"Valida็ใo da Coleta"    
  Return(Nil)
 EndIf
 
 If nOpcM01 == 5 
  If GGO->GGO_SITCOL <> "1"
  HS_MsgInf(STR0013, STR0014, STR0015) //"A coleta s๓ poderแ ser concluํda se a situa็ใo for: Em Realiza็ใo."###"Aten็ใo"###"Valida็ใo da Coleta"   
  Return(Nil)
  ElseIf !HS_VldPar(StrTran(aRotina[nOpcM01, 1], "&", ""))
   Return(Nil)
 EndIf   
 Endif 
 
 If nOpcM01 <> 5
  DbSelectArea("SX3")
  DbSetOrder(1) //GGO_FILIAL + GGO_CDCOLE + GGO_REGATE
  DbSeek("GGO")
  While !Eof() .And. SX3->X3_ARQUIVO == "GGO"
   If !(SX3->X3_CAMPO $ "GGO_DATFIN/GGO_HORFIN/GGO_INTERC/GGO_COLINT/GGO_CVDOAD/GGO_LOCSOL")
    aAdd(aCposAlt, SX3->X3_CAMPO)
   EndIf
   DbSkip()
  End
 Else
  aCposAlt := {"GGO_DATFIN", "GGO_HORFIN", "GGO_INTERC", "GGO_COLINT", "GGO_CDMOTI"}
 EndIf
           
 DbSelectArea("GGO")
 RegToMemory("GGO", aRotina[nOpcM01, 4] == 3) 
 
 aButtons := {{"AUTOM", {|| HS_M01INT(M->GGO_REGATE, M->GGO_CDCOLE) }, OemToAnsi(STR0070),OemToAnsi(STR0071)}} // "Intercorr๊ncias"###"Intercor."
 
 If StrZero(nOpcM01,2) $ "03/04/06" 
  If Empty(M->GGO_CDUSUA)
   M->GGO_CDUSUA := cUserName
  EndIf
 EndIf

 If nOpcM01 == 3                 
 
  HS_BDados("GGL", @aHGGL, @aCGGL,, 1,, IIF(aRotina[nOpcM01, 4] # 3, "GGL->GGL_CDMODC == '" + GGO->GGO_CDMODC + "'" , Nil),,,,,,,"GGL_IDMARK", "'LBTIK'")
  nGGLIDMARK := aScan(aHGGL, {| aVet | aVet[2] == "GGL_IDMARK"})
  nGGLCDTIPA := aScan(aHGGL, {| aVet | aVet[2] == "GGL_CDTIPA"}) 
  nGGLQTDAMO := aScan(aHGGL, {| aVet | aVet[2] == "GGL_QTDAMO"})
  
  HS_BDados("GD5", @aHMM, @aCMM,, 3,,, .T.)
      
  HS_BDados("GD6", @aHTD, @aCTD,, 3,,, .T.)
  
  HS_BDados("GD7", @aHPR, @aCPR,, 3,,, .T.)
  
  HS_PrvGD(aHMM, aHTD, aHPR, "P", FunName(), GGO->GGO_REGATE)

 EndIf

 aSize := MsAdvSize(.T.)
 aObjects := {}
 AAdd(aObjects, {100, 050, .T., .T.})
 AAdd(aObjects, {100, 050, .T., .T., .T. })

 aInfo  := {aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0}
 aPObjs := MsObjSize(aInfo, aObjects, .T.)
 
 aObjects := {}
 AAdd( aObjects, { 100, 100, .T., .T. } )

 aInfo := {aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], 0, 0 }
 aPGDM := MsObjSize( aInfo, aObjects, .T. )
 
 DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) From aSize[7], 0 To aSize[6], aSize[5]	PIXEL Of oMainWnd  //"Coleta"

  oGGO := MsMGet():New("GGO", nRegM01, nOpcM01,,,,, {aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]}, aCposAlt,,,,, oDlg)
  oGGO:oBox:align:= CONTROL_ALIGN_ALLCLIENT
  
  FS_VldDtHr(nOpcM01)  
 
  If nOpcM01 == 3 // Confirmar
   @ aPObjs[2, 1], aPObjs[2, 2] FOLDER oFolGDM SIZE aPObjs[2, 3], aPObjs[2, 4] Pixel OF oDlg Prompts STR0028, STR0029, STR0030, STR0031 //"&1-Amostras"###"&2-Procedimentos"###"&3-Materiais / Medicamentos"###"&4-Taxas / Diarias" 
   oFolGDM:Align := CONTROL_ALIGN_BOTTOM  
   
   oGGL := MsNewGetDados():New(aPGDM[1, 1], aPGDM[1, 2], aPGDM[1, 3], aPGDM[1, 4],,,,,,,,,,, oFolGDM:aDialogs[1], aHGGL, aCGGL)
   oGGL:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT                     
   oGGL:oBrowse:BlDblClick := {|| FS_DblClk(oGGL)}

   oGDPR := MsNewGetDados():New(aPGDM[1, 1], aPGDM[1, 2], aPGDM[1, 3], aPGDM[1, 4], nGDOpc,,,,,,,,,, oFolGDM:aDialogs[2], aHPR, aCPR)
   oGDPR:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT                       
   
   oGDMM := MsNewGetDados():New(aPGDM[1, 1], aPGDM[1, 2], aPGDM[1, 3], aPGDM[1, 4], nGDOpc,,,,,,,,,, oFolGDM:aDialogs[3], aHMM, aCMM)
   oGDMM:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT                       
   
   oGDTD := MsNewGetDados():New(aPGDM[1, 1], aPGDM[1, 2], aPGDM[1, 3], aPGDM[1, 4], nGDOpc,,,,,,,,,, oFolGDM:aDialogs[4], aHTD, aCTD)
   oGDTD:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT                          
   
   If !Empty(cCodigo := HS_IniPadr("GGJ", 1, M->GGO_CDMODC, "GGJ_CDKITC",, .F.))
    HS_AddMatM(cCodigo)
   EndIf 
   HS_AddProc(HS_IniPadr("GGE", 1, GCY->GCY_CDTIPD, "GGE_CODPRO",, .F.))   
  EndIf
  
 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {|| nOpcA := 1, IIF(FS_GrvM01(nOpcM01, oGGL), oDlg:End(), nOpcA := 0)}, ;
                                                   {|| nOpcA := 0, oDlg:End()},,aButtons)

 If nOpcA == 1 .And. aRotina[nOpcM01, 4] <> 2
  While __lSx8
   ConfirmSx8()
  EndDo   
  If nOpcM01 == 3 // Confirmar
   HS_EtqM01(cRegAte, aAmostra)
  EndIf 
 ElseIf aRotina[nOpcM01, 4] <> 2
  While __lSx8
   RollBackSx8()
  EndDo
 EndIf
Return(Nil)





/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_MntLote บ Autor ณ Patricia Queiroz   บ Data ณ  05/01/07  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Monta a tela de protocolo para lan็ar as amostras.         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
                                                                            */
Function HS_MntLote(cAliasML, nRegML, nOpcML)

 Local nOpcA    := 0
 Local aSize    := {}, aObjects := {}, aInfo := {}, aPObjs := {}, aPGGs := {}
 Local nGGOpc	  := GD_DELETE
 Local aCGGP    := {}, aHGGP := {}
 Local oLote, oDlgLote  
 Local nOpcLote := 0  
 Local lAtrib   := .F.

 Private aTela 		 := {}
 Private aGets    := {}
 Private aHeader  := {}
 Private aCols    := {}
 Private oGGP, oDlgS
 Private nUGGP    := 0
 Private nGGPCODBAR := 0, nGGPCDTIPA := 0, nGGPDSTIPA := 0
 Private cCamposN := "", cCampos := ""
 Private cCodBar  := Space(8)
 Private aProt    := {}
 
 nOpcA := 0 
 
 If nOpcML == 1
  If (nOpcA := FS_MntProt(nOpcML)) == 1
   lAtrib := .T.
   nOpcML := 2
  EndIf
 EndIf
 If nOpcML == 2
  lGGOInclui := .F.
 EndIf         
 If nOpcML == 2 .And. !lAtrib
  DEFINE MSDIALOG oDlgLote TITLE STR0049 + " - " + STR0050 FROM 000, 000 TO 070, 400  OF oMainWnd PIXEL  //"Amostras"###"Protocolo"
 
   @ 018, 003 Say OemToAnsi(STR0051) Size 075, 009 OF oDlgLote PIXEL COLOR CLR_BLACK  //"Informe o Protocolo :"
   @ 016, 051 MSGet oLote Var cLote F3 "GGQ001" Valid HS_VldLot(cLote, nOpcML,) Size 020, 009 OF oDlgLote PIXEL COLOR CLR_BLACK 

  ACTIVATE MSDIALOG oDlgLote CENTERED ON INIT EnchoiceBar(oDlgLote, {|| nOpcLote := 1, oDlgLote:End()}, {|| nOpcLote := 0, oDlgLote:End()})
 EndIf 
 
 If nOpcLote == 1 .Or. nOpcML == 1 .Or. (nOpcML == 2 .And. lAtrib)
  cCamposN := "GGP_CDCOLE/GGP_DATEMI/GGP_USUEMI/GGP_CDSITA/GGP_CDPROT/GGP_CDAMOT/GGP_REGATE/GGP_CDMOTI/GGP_DSMOTI/GGP_NOME  /GGP_DATATE/GGP_CDITEM"
  cCamposN += "GGP_REGGER/GGP_UNICOL/GGP_DSUNIC/GGP_LOCATE/GGP_DLOATE" 
  cCampos  := "GGP_CODBAR/GGP_CDTIPA/GGP_DSTIPA" 
 
  HS_BDados("GGP", @aHGGP, @aCGGP, @nUGGP, 1,, IIF(nOpcML == 2, "GGP->GGP_CDPROT == '" + cLote + "'", Nil),,, cCampos,, cCamposN, .F.)
  nGGPCODBAR := aScan(aHGGP, {| aVet | aVet[2] == "GGP_CODBAR"})
  nGGPCDTIPA := aScan(aHGGP, {| aVet | aVet[2] == "GGP_CDTIPA"})
  nGGPDSTIPA := aScan(aHGGP, {| aVet | aVet[2] == "GGP_DSTIPA"})

  aSize := MsAdvSize(.T.)
  aObjects := {}
  AAdd(aObjects, {100, 050, .T., .T.})
  AAdd(aObjects, {100, 050, .T., .T.})

  aInfo  := {aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0}
  aPObjs := MsObjSize(aInfo, aObjects, .T.) 

  DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0049) From aSize[7], 0 To aSize[6], aSize[5]	PIXEL Of oMainWnd //"Amostras"
   
   @ 15, 005 SAY OemToAnsi(STR0052) OF oDlgS PIXEL COLOR CLR_BLUE //"Cod. Barra" 
   @ 15, 035 MSGET oCodBar VAR cCodBar Valid HS_VldML(nOpcML) SIZE 060, 4 OF oDlgS PIXEL COLOR CLR_BLACK
  
   oGGP := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2],aPObjs[2, 3], aPObjs[2, 4], nGGOpc,,,,,,,,,,, aHGGP, aCGGP)
   oGGP:oBrowse:Align := CONTROL_ALIGN_BOTTOM
   
   HS_AdiItem(oGGP)

  ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {|| nOpcA := 1, IIF(FS_GrvProt(, nOpcML, oGGP), oDlg:End(), nOpcA == 0)}, ;
                                                    {|| nOpcA := 0, oDlg:End()})
 EndIf                                                     
 lGGOInclui := .T.
                                                    
 MBrChgLoop(.F.)

 If nOpcA == 1 
  While __lSx8
   ConfirmSx8()
  EndDo  
 Else
  While __lSx8
   RollBackSx8()
  EndDo
 EndIf    
                                                                       
Return(Nil)                                                                            



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_MntSAI บ Autor ณ Patricia Queiroz   บ Data ณ  22/02/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Tratamento das saํdas das amostras.                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
                                                                            */
Function HS_MntSai(cAliasMSa, nRegMSa, nOpcMSa)   

 Local nOpcA    := 0
 Local aSize    := {}, aObjects := {}, aInfo := {}, aPObjs := {}, aPGGs := {}
 Local nGGOpc	  := 0
 Local aCGGP    := {}, aHGGP := {}                
 Local nOpcLote := 0 
 Local aCpos    := {}
                     
 Private aTela 		:= {}
 Private aGets   := {}
 Private aHeader := {}
 Private aCols   := {}
 Private oGGQ, oGGP
 Private nUGGP := 0
 Private nGGPCODBAR := 0, nGGPCDTIPA := 0, nGGPDSTIPA := 0
 Private cCamposN := "", cCampos := ""
 Private nOpcCol  := nOpcMsa
 
 
 If nOpcMSa == 3
  DbSelectArea("SX3")
  DbSetOrder(1) // GGQ_FILIAL + GGQ_CDPROT
  DbSeek("GGQ")
  While !Eof() .And. SX3->X3_ARQUIVO == "GGQ"
   If !(SX3->X3_CAMPO $ "GGQ_FILIAL/GGQ_RESREC/GGQ_TEMPCH/GGQ_DATREC/GGQ_HORCHE/GGQ_VALREC/GGQ_CODBAR/GGQ_SITLOT/GGQ_IDMARK/GGQ_UNICOL")
    aAdd(aCpos, SX3->X3_CAMPO)
   EndIf  
   DbSkip()
  End
 EndIf          
 
 
 DEFINE MSDIALOG oDlgLote TITLE STR0049 + " - " + STR0050 FROM 000, 000 TO 070, 400  OF oMainWnd PIXEL //"Amostras"###"Protocolo"
 
  @ 018, 003 Say OemToAnsi(STR0051) Size 075, 009 OF oDlgLote PIXEL COLOR CLR_BLACK  //"Informe o Protocolo :" 
  @ 016, 051 MSGet oLote Var cLote F3 "GGQ001" Valid HS_VldLot(cLote,, nOpcMSa) Size 020, 009 OF oDlgLote PIXEL COLOR CLR_BLACK 
  
 ACTIVATE MSDIALOG oDlgLote CENTERED ON INIT EnchoiceBar(oDlgLote, {|| nOpcLote := 1, oDlgLote:End()}, {|| nOpcLote := 0, oDlgLote:End()})
 
 RegToMemory("GGQ", nOpcMSa == 3) 
 nOpcA := 0
 
 M->GGQ_CDPROT := cLote
 
 If nOpcLote == 1
  cCamposN := "GGP_CDCOLE/GGP_DATEMI/GGP_USUEMI/GGP_CDSITA/GGP_CDPROT/GGP_CDAMOT/GGP_REGATE/GGP_CDMOTI/GGP_DSMOTI/GGP_NOME  /GGP_DATATE/GGP_CDITEM"
  cCamposN += "GGP_REGGER/GGP_UNICOL/GGP_DSUNIC/GGP_LOCATE/GGP_DLOATE" 
  cCampos  := "GGP_CODBAR/GGP_CDTIPA/GGP_DSTIPA" 
 
  HS_BDados("GGP", @aHGGP, @aCGGP, @nUGGP, 1,, "GGP->GGP_CDPROT == '" + cLote + "'",,, cCampos,, cCamposN, .F.)
  nGGPCODBAR := aScan(aHGGP, {| aVet | aVet[2] == "GGP_CODBAR"})
  nGGPCDTIPA := aScan(aHGGP, {| aVet | aVet[2] == "GGP_CDTIPA"})
  nGGPDSTIPA := aScan(aHGGP, {| aVet | aVet[2] == "GGP_DSTIPA"})    
  
  aSize := MsAdvSize(.T.)
  aObjects := {}
  AAdd(aObjects, {100, 050, .T., .T.})
  AAdd(aObjects, {100, 050, .T., .T.})

  aInfo  := {aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0}
  aPObjs := MsObjSize(aInfo, aObjects, .T.) 
  
  DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0049) From aSize[7], 0 To aSize[6], aSize[5]	PIXEL Of oMainWnd //"Amostras" 
                                
   oGGQ := MsMGet():New("GGQ", nRegMSa, nOpcMSa,,,, aCpos, {aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]},,,,,, oDlg)
   oGGQ:oBox:align := CONTROL_ALIGN_ALLCLIENT
  
   oGGP := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2],aPObjs[2, 3], aPObjs[2, 4], nGGOpc,,,,,,,,,,, aHGGP, aCGGP)
   oGGP:oBrowse:Align := CONTROL_ALIGN_BOTTOM
   
   HS_AdiItem(oGGP)
   
   If nOpcMSa == 3  
    M->GGQ_RESLIB := cUserName
   EndIf   
     
  ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {|| nOpcA := 1, IIF(FS_GrvProt(nOpcMSA, , oGGP), oDlg:End(), nOpcA == 0)}, ;
                                                    {|| nOpcA := 0, oDlg:End()}) 
 EndIf                                                    
  
 If nOpcA == 1 .And. nOpcMSa == 3
  HSPAHR13(cCODPROT)     
 EndIf
 
Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GrvM01 บAutor  ณPatricia Queiroz    บ Data ณ  24/10/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณTrava tabela para Inclusao e Alteracao.                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_GrvM01(nOpcM01, oGGL)

 Local nFor      := 0, nForI := 0, nQTD  := 0
 Local lRet      := .T.
 Local cSql      := "" 
 Local aArea     := GetArea()
 Local nItemGGV  := 0
 Local lBloqueia := .T.
 
 Private cMotBlq := GetMV("MV_MTBLQLT")
 
 If (lRet := Obrigatorio(aGets, aTela) .And. FS_VerGrv(nOpcM01, oGGL))
 
  cRegAte := M->GGO_REGATE
  
  Begin Transaction
   If aRotina[nOpcM01, 4] == 4 .Or. aRotina[nOpcM01, 4] == 3 
    RecLock("GGO", aRotina[nOpcM01, 4] == 3)
     HS_GrvCpo("GGO")
     GGO->GGO_UNICOL := cLocCodCol 
     If nOpcM01 <> 4
      GGO->GGO_SITCOL := IIF(aRotina[nOpcM01, 4] == 3, "0", IIF(nOpcM01 == 3, "1", IIF(nOpcM01 == 5 .And. (M->GGO_COLINT == "0" .Or. M->GGO_COLINT == " "), "2", "3")))  
     EndIf 
    MsUnlock()	
   EndIf 	

   If nOpcM01 == 3 // Confirmar
    nItem := FS_ItemM01(cRegAte)
    For nFor := 1 To Len(oGGL:aCols)
     nQTD := oGGL:aCols[nFor, nGGLQTDAMO] 
     If oGGL:aCols[nFor, nGGLIDMARK] == "LBTIK"
      For nForI := 1 To nQTD
       nItem++
       RecLock("GGP", .T.)
        GGP->GGP_CDAMOT := HS_VSxeNum("GGP", "GGP_CDAMOT", 1)
        GGP->GGP_CDITEM := StrZero(nItem, Len(GGP->GGP_CDITEM))
        GGP->GGP_CODBAR := GGP->GGP_CDAMOT 
        GGP->GGP_CDTIPA := oGGL:aCols[nFor, nGGLCDTIPA]
        GGP->GGP_CDCOLE := M->GGO_CDCOLE     
        GGP->GGP_CDSITA := IIF(M->GGO_COLINT == "0" .Or. M->GGO_COLINT == " ", "0", "3")
        GGP->GGP_REGATE := M->GGO_REGATE
        GGP->GGP_NOME   := HS_IniPadr("GCY", 1, M->GGO_REGATE, "GCY_NOME",, .F.)
        GGP->GGP_DATATE := M->GGO_DATATE     
        GGP->GGP_CDMOTI := M->GGO_CDMOTI
        GGP->GGP_DATEMI := dDataBase  
        GGP->GGP_USUEMI := cUserName
        GGP->GGP_UNICOL := cLocCodCol    
        GGP->GGP_DSUNIC := HS_IniPadr("GCS", 1, cLocCodCol, "GCS_NOMLOC",, .F.) 
        GGP->GGP_LOCATE := cLctCodLoc 
        GGP->GGP_DLOATE := HS_IniPadr("GCS", 1, cLctCodLoc, "GCS_NOMLOC",, .F.) 
        GGP->GGP_REGGER := HS_IniPadr("GCY", 1, M->GCY_REGATE, "GCY_REGGER",, .F.) 
        GGP->GGP_FILIAL := xFilial("GGP")
       MsUnLock()  
       
      	aAdd(aAmostra, {GGP->GGP_CDAMOT})  
            
       ConfirmSx8()
      Next(nForI)
     EndIf 
    Next(nFor)
    
    FS_M01Guia() 
    
   ElseIf nOpcM01 == 5 // Concluir
    // Se for conclusใo deverแ dar entrada no estoque dos produtos cadastrados na modalidade(BOLSAS)
        
    DbSelectArea("GCS")
    DbSetorder(1) //GCS_FILIAL + GCS_CODLOC
	   DbSeek(xFilial("GCS") + cLocCodCol)
   
    cSql := "SELECT GGM.GGM_CDITEM, GGM.GGM_CDPROD,GGM.GGM_QTDEST, GBI.GBI_DIASVL "
    cSql += "FROM " + RetSqlName("GGM") + " GGM "
    cSql +=       " JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_COD = GGM.GGM_CDPROD "
    cSql +=  " LEFT JOIN " + RetSqlName("GBI") + " GBI ON GBI.GBI_PRODUT = GGM.GGM_CDPROD "
    cSql += "WHERE GGM.GGM_FILIAL = '" + xFilial("GGM") + "' AND GGM.D_E_L_E_T_ <> '*' AND "
    cSql +=       "GGM.GGM_CDMODC = '" + M->GGO_CDMODC + "' "                                           

    cSql += "ORDER BY GGM.GGM_CDITEM, GGM.GGM_CDPROD"

    cSql := ChangeQuery(cSql)

    DbUseArea(.T., "TOPCONN", TcGenQry(,,cSql), "TMPGGM",.T.,.T.)

    DbSelectArea("TMPGGM")
    DbGotop()

    nItemGGV := 0

    While !(TMPGGM->(Eof()))
     aMovest := HS_MovEst("E", TMPGGM->GGM_CDPROD, TMPGGM->GGM_QTDEST, GCS->GCS_PREEST, cUserName, GCS->GCS_CODCCU,, Space(Len(SD3->D3_NUMLOTE)),GGO->GGO_REGATE, dDataBase + TMPGGM->GBI_DIASVL,,,,GGO->GGO_REGATE)

     If !(aMovEst[1])
      DisarmTransaction()
      Exit
     EndIf

     DbSelectArea("SD5")
     DbSetOrder(3)//D5_FILIAL+D5_NUMSEQ+D5_PRODUTO+D5_LOCAL+D5_LOTECTL+D5_NUMLOTE
     If !DbSeek(xFilial("SD5") + aMovest[2])
      HS_MsgInf(STR0067 + TMPGGM->GGM_CDPROD + STR0068, STR0014, STR0069)//"Nใo foi encontrado lote para o produto ["###"]. Verificar rastro."###"Aten็ใo"###"Valida็ใo de Lote"
      DisarmTransaction()
      Exit
     EndIf

     DbSelectArea("SD3")
     DbSetOrder(4) //D3_FILIAL+D3_NUMSEQ+D3_CHAVE+D3_COD
     DbSeek(xFilial("SD3") + aMovest[2])

     If !HS_BlqLote(lBloqueia, ,TMPGGM->GGM_CDPROD, SD3->D3_LOCAL, SD5->D5_LOTECTL, SD5->D5_NUMLOTE, TMPGGM->GGM_QTDEST, cMotBlq)
      DisarmTransaction()
      Exit
     EndIf

     nItemGGV++
     
     // PELO SEQUENCIAL 'NUMSEQ' (SD3) ษ POSSIVEL CHEGAR AO LOTE/SUB-LOTE SD5
     DbSelectArea("GGV")
     DbSetOrder(1) //GGV_FILIAL + GGV_REGATE + GGV_CDCOLE + GGV_CDITEM
     Reclock("GGV", .T.)
      GGV->GGV_FILIAL := xFilial("GGV") 
      GGV->GGV_REGATE := GGO->GGO_REGATE
      GGV->GGV_CDCOLE := GGO->GGO_CDCOLE
      GGV->GGV_CDITEM := StrZero(nItemGGV, Len(GGV->GGV_CDITEM))
      GGV->GGV_CDPROD := TMPGGM->GGM_CDPROD
      GGV->GGV_QTDEST := TMPGGM->GGM_QTDEST
      GGV->GGV_NUMSEQ := aMovest[2]
     MsUnlock()
     TMPGGM->(DbSkip())
    End
    DbSelectArea("TMPGGM")     
    DbCloseArea()
   EndIf 
   
  End Transaction 
 EndIf 

 RestArea(aArea)
 
Return(lRet)


Function HS_BlqLote(lBloqueia, cDoc,cCodProd, cLocal, cLoteCTL, cNumLote, nQuant, cMotBlq)

 Local aSDD := {}, aArea := GetArea()
 Local lRet := .T.
 
 Private lMsErroAuto := .F.
 Private lMsHelpAuto := .T.
 
 Default cDoc     := HS_VSxeNum("SDD", "M->DD_DOC", 1)
 Default cNumLote := Space(Len(SDD->DD_NUMLOTE))

 DbSelectArea("SDD")

 aSDD := {}  
 aAdd(aSDD, {"DD_DOC"    , cDoc    , NIL})
 aAdd(aSDD, {"DD_PRODUTO", cCodProd, NIL})
 aAdd(aSDD, {"DD_LOCAL"  , cLocal  , NIL})
 aAdd(aSDD, {"DD_LOTECTL", cLoteCTL, NIL})
 aAdd(aSDD, {"DD_NUMLOTE", cNumLote, NIL})
 aAdd(aSDD, {"DD_QUANT"  , nQuant  , NIL})
 aAdd(aSDD, {"DD_MOTIVO" , cMotBlq , NIL})
   
 MSExecAuto({|x,y| Mata275(x,y)}, aSDD, Iif(lBloqueia,3,4) )
 
 If lMsErroAuto
  MostraErro()
  lRet := .F. 
 EndIf
 
 RestArea(aArea)   
Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GrvProt บAutor  ณPatricia Queiroz    บ Data ณ  22/02/07  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณTrava tabela para Inclusao, Alteracao e Exclusao.           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_GrvProt(nOpcMSa, nOpcML, oGGP)

 Local nFor := 0
 Local lRet := .T.
 
 Default nOpcMSA := 0
 Default nOpcML  := 0 

	If (lRet := Obrigatorio(aGets, aTela) .And. FS_VldGrav())

  Begin Transaction  
 
   cCODPROT := IIF(nOpcML == 1, GetSXENum("GGQ", "GGQ_CDPROT",, 1), cLote)
   
   For nFor := 1 To Len(oGGP:aCols)
    DbSelectArea("GGP")
    DbSetOrder(1) // GGP_FILIAL + GGP_CDAMOT + GGP_CDSITA
    lAchou := DbSeek(xFilial("GGP") + SubStr(oGGP:aCols[nFor, nGGPCODBAR], 1, 6))
    If lAchou .And. !oGGP:aCols[nFor, Len(oGGP:aHeader)+1]
     RecLock("GGP", .F.)
     GGP->GGP_CDPROT := cCODPROT
      If nOpcMSa == 3
       GGP->GGP_CDSITA := "1"
      ElseIf nOpcML == 1 .Or. nOpcML == 2
       GGP->GGP_CDSITA := "5"
      EndIf
     MsUnLock() 
    EndIf
   Next() 
   
   RecLock("GGQ", nOpcML == 1)
    HS_GrvCpo("GGQ")
    GGQ->GGQ_UNICOL := cLocCodCol
    GGQ->GGQ_CDPROT := cCODPROT
    If nOpcML == 1 .Or. nOpcMSa == 3
     GGQ->GGQ_SITLOT := IIF(nOpcML == 1, "0", IIF(nOpcMSa == 3, "1", "2"))
    EndIf
   MsUnlock()	   
  
   If nOpcML == 1
    HS_MsgInf(STR0053 + cCODPROT, STR0014, STR0054) //"O n๚mero do protocolo gerado ้ "###"Aten็ใo"###"Gera็ใo de Protocolo"
   EndIf
  
  End Transaction  
 EndIf 

Return(lRet)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_DblClk บAutor  ณPatricia Queiroz    บ Data ณ  24/10/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณFuncao para marcar e desmarcar o item.                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_DblClk(oGGL)

 If oGGL:aHeader[oGGL:oBrowse:nColPos, 2] == "GGL_IDMARK"
  oGGL:aCols[oGGL:oBrowse:nAt, nGGLIDMARK] := IIf(oGGL:aCols[oGGL:oBrowse:nAt, nGGLIDMARK] == "LBTIK", "LBNO", "LBTIK")
 Else
  oGGL:EDITCELL(oGGL:oBrowse, oGGL:oBrowse:nAt, oGGL:oBrowse:nColPos)
 EndIf
 
Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VerGrv บAutor  ณPatricia Queiroz    บ Data ณ  29/10/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณValidacao os dados para gravacao                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_VerGrv(nOpcM01, oGGL)
 Local lRet  := .T.  

 If nOpcM01 == 3 .And. !(lRet := (aScan(oGGL:aCols, {| aVet | aVet[nGGLIDMARK] == "LBTIK"}) > 0))
  HS_MsgInf(STR0016, STR0014, STR0017) //"Nใo hแ amostras selecionadas."###"Aten็ใo"###"Valida็ใo de Amostras"
 ElseIf nOpcM01 == 5 .And. !(lRet := (M->GGO_DATFIN >= GGO->GGO_DATINI))
  HS_MsgInf(STR0024, STR0014, STR0025) //"A data de t้rmino nใo pode ser menor que a data de inํcio."###"Aten็ใo"###"Valida็ใo de Data"
 ElseIf nOpcM01 == 5 .And. !(lRet := ((M->GGO_HORFIN >= GGO->GGO_HORINI .And. M->GGO_DATFIN = GGO->GGO_DATINI) .Or. (M->GGO_DATFIN > GGO->GGO_DATINI) ))
  HS_MsgInf(STR0026, STR0014, STR0027) //"A hora de t้rmino nใo pode ser menor que a hora de inํcio."###"Aten็ใo"###"Valida็ใo de Horas"  
 EndIf
Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_VldM01 บAutor  ณPatricia Queiroz    บ Data ณ  16/11/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณValidacao de campos.                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_VldM01(cCampo)

Local lRet  := .T.
Local aArea := GetArea()

Default cCampo := ReadVar()

 If cCampo == "M->GGO_REGATE"
  If !(lRet := HS_SeekRet("GCY", "M->GGO_REGATE", 1, .F., "GGO_NOME", "GCY_NOME"))
   HS_MsgInf(STR0021, STR0014, STR0022) //"Este atendimento nใo existe."###"Aten็ใo"###"Valida็ใo de Atendimento" 
  EndIf
  DbSelectArea("GCY")
  DbSetOrder(1) //GCY_FILIAL + GCY_REGATE
  DbSeek(xFilial("GCY") + M->GGO_REGATE)
  M->GGO_DATATE := GCY->GCY_DATATE
  M->GGO_CDMODC := HS_IniPadr("GGE", 1, GCY->GCY_CDTIPD, "GGE_CDMODC",, .F.)
  M->GGO_DSMODC := HS_IniPadr("GGJ", 1, M->GGO_CDMODC  , "GGJ_DSMODC",, .F.)
  M->GGO_LOCATE := HS_IniPadr("GCY", 1, M->GGO_REGATE, "GCY_LOCATE",, .F.)
 
 ElseIf cCampo == "M->GGO_LOCSOL"
  
  If !(lRet := HS_SeekRet("GCS", "M->GGO_LOCSOL", 1, .F., "GGO_DSLOCS", "GCS_NOMLOC"))
   HS_MsgInf(STR0062, STR0014, STR0077) //"Setor Invแlido"###"Aten็ใo"###"Valida็ใo de Setor Solicitante da Coleta"
  EndIf
  
 ElseIf cCampo == "M->GHK_CDINTE"
  
  If !(lRet := HS_SeekRet("GHM", "M->GHK_CDINTE", 1, .F., "GHK_DSINTE", "GHM_DSINTE"))
   HS_MsgInf(STR0078, STR0014, STR0079) //"Tipo de Intercorr๊ncia invแlida"###"Aten็ใo"###"Valida็ใo do tipo de intercorr๊ncia"
  EndIf
  
 ElseIf cCampo == "MV_PAR01"
  DbSelectArea("GCS")
  DbSetorder(1)
  If !DbSeek(xFilial("GCS") + MV_PAR01)
   HS_MsgInf(STR0062,STR0014, STR0063)//"Setor invแlido"###"Aten็ใo"###"Valida็ใo do Filtro de Coleta"
   lRet := .F.
  Else
   If GCS->GCS_TIPLOC <> "E"
    HS_MsgInf(STR0064,STR0014, STR0063) //"O Setor nใo ้ do tipo Coleta"###"Aten็ใo"###"Valida็ใo do Filtro de Coleta"
    lRet := .F.
   Else
    DbSelectArea("GM1")
    DbSetOrder(1)
    If !Empty(MV_PAR01) .And. !DbSeek(xFilial("GM1") + MV_PAR01 + cUserName)
     HS_MsgInf(STR0065,STR0014, STR0063) //"Usuแrio sem permissใo de acesso ao Setor de Coleta"###"Aten็ใo"###"Valida็ใo do Filtro de Coleta"
     lRet := .F.
    EndIf
   EndIf
  EndIf

 ElseIf cCampo == "MV_PAR02"
  DbSelectArea("GCS")
  DbSetorder(1)
  If !Empty(MV_PAR02) .And. !DbSeek(xFilial("GCS") + MV_PAR02)
   HS_MsgInf(STR0062,STR0014, STR0063) ////"Setor invแlido"###"Aten็ใo"###"Valida็ใo do Filtro de Coleta"
   lRet := .F.
  ElseIf !Empty(MV_PAR02) .And. !(GCS->GCS_TIPLOC $ "0#1#C")
   HS_MsgInf(STR0066,STR0014, STR0063)////"Setor nใo ้ do tipo Atendimento Interna็ใo/Ambulatorial/Doa็ใo"###"Aten็ใo"###"Valida็ใo do Filtro de Coleta"
   lRet := .F.
  EndIf
  
 EndIf
 RestArea(aArea)

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_LegM01 บAutor  ณPatricia Queiroz    บ Data ณ  25/10/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณMonta Legenda                                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_LegM01()

BrwLegenda(STR0006, STR0007, {{'BR_AMARELO' , STR0008},;  //"Coleta"###"Legenda"###"Espera"
                              {'BR_VERDE'   , STR0019	},; //"Liberada"
                              {'BR_LARANJA' , STR0009	},; //"Em Realiza็ใo"
                              {'BR_CINZA'   ,	STR0010},;  //"Concluํda"
                              {'BR_AZUL'    ,	STR0011},;	 //"Interrompida"	
                              {'BR_VERMELHO', STR0018}})	 //"Cancelada"	
Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_M01GuiaบAutor  ณPatricia Queiroz    บ Data ณ  30/11/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณGrava os Mat/Med - Tax/Dia - Proc.                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_M01Guia()
 Local aArea := GetArea()
 Local aDespExcec := {{"GD5", {}}, {"GD6", {}}, {"GD7", {}}} 
 Local aCtrlVias  := {}, aIncide := {}
 Local cGa9TipCon := ""
 
 DbSelectArea("GCZ")
 DbSetOrder(2) //GCZ_FILIAL + GCZ_REGATE + GCZ_STAUS + GCZ_NRSEQG
 DbSeek(xFilial("GCZ") + GGO->GGO_REGATE + "0")    
 
 cGa9TipCon := HS_RCfgCP(GCZ->GCZ_CODCON, GCZ->GCZ_CODPLA, "_TIPCON")
 
 DbSelectArea("GCY")
 DbSetOrder(1)//GCY_FILIAL + GCY_REGATE
 DbSeek(xFilial("GCY") + GGO->GGO_REGATE)
 
 HS_GrvMM("GD5",, .T.,, @aDespExcec, cGa9TipCon, oGDMM:aCols, .F.) 
 HS_GrvGD("GD6", 1,,3, oGDTD:aHeader, "M->GD6_SEQDES", .T., nTDSeqDes, nTDCodDes, nTDCodLoc,, @aDespExcec, cGa9TipCon, nTDStaReg, oGDTD:aCols)
 HS_GrvGD("GD7", 1,,4, oGDPR:aHeader, "M->GD7_SEQDES", .T., nPRSeqDes, nPRCodDes, nPRCodLoc, @aCtrlVias, @aDespExcec, cGa9TipCon, nPRStaReg, oGDPR:aCols, @aIncide) 
 
 cGuiaRet := HS_RGuia("1", "0", GGO->GGO_REGATE)
 
 If Len(aDespExcec[1][2]) > 0 .Or. Len(aDespExcec[2][2]) > 0 .Or. Len(aDespExcec[3][2]) > 0
  If !Empty(cGuiaRet) .Or. HS_IGuiaP(GGO->GGO_REGATE, GCY->GCY_REGGER, "0", "3", GCY->GCY_DATATE, GCY->GCY_LOCATE)
   HS_GrvMM("GD5",, .T.,, @aDespExcec, cGa9TipCon, aDespExcec, .F.)  
   HS_GrvGD("GD6", 1,,, @aDespExcec, "M->GD6_SEQDES", .T., nTDSeqDes, nTDCodDes, nTDCodLoc)
   HS_GrvGD("GD7", 1,,, @aDespExcec, "M->GD7_SEQDES", .T., nPRSeqDes, nPRCodDes, nPRCodLoc, @aCtrlVias,,,,, @aIncide)
  EndIf
 EndIf 
 
 HS_CalcVias(aCtrlVias, "GD7", {1, 5}, , .T., aIncide) // Efetua calculo de vias 
                    
 RestArea(aArea)
Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_RGuia  บAutor  ณPatricia Queiroz    บ Data ณ  30/11/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณRetorna uma guia com o status, regate e tipo de convenio    บฑฑ
ฑฑบ          ณinformado.                                                  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_RGuia(cTpCon, cStatus, cRegAte)
 Local aArea := GetArea()
 Local cGuia := ""
 Local cSql  := ""
 
 cSql := "SELECT GCZ.GCZ_NRSEQG, GCZ.GCZ_STATUS, GA9.GA9_TIPCON "
 cSql += "FROM " + RetSqlName("GCZ") + " GCZ "                                                                           
 cSql += "JOIN " + RetSqlName("GA9") + " GA9 ON GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*' AND GA9.GA9_CODCON = GCZ.GCZ_CODCON AND GA9.GA9_TIPCON = '" + cTpCon + "' " 
 cSql += "WHERE GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' "
 cSql += " AND GCZ.GCZ_STATUS =  '" + cStatus + "' "                      
 cSql += " AND GCZ.GCZ_REGATE =  '" + cRegAte + "' "                      

 cSQL:=ChangeQuery(cSQL)
 TCQUERY cSQL NEW ALIAS "QRY"
        
 DbSelectArea("QRY")
 DbGoTop()

 cGuia := QRY->GCZ_NRSEQG 

 DbCloseArea()

 RestArea(aArea)
Return(cGuia)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma ณHS_AddMatM บAutor  ณPatricia Queiroz    บ Data ณ  30/11/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณAdiciona Mat/Med.                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_AddMatM(cCodDes)

 Local cOldReadV := __ReadVar, lRet := .F., cCodBar := HS_IniPadr("SB1", 1, cCodDes, "B1_CODBAR",, .F.)
  
 If (oGDMM:nAt := aScan(oGDMM:aCols, {| aVet | Empty(aVet[nMMCODDES])})) == 0
  oGDMM:AddLine(.F., .F.)                    
  oGDMM:lNewLine := .F.    
  oGDMM:nAt := Len(oGDMM:aCols)
 EndIf                     
   
 __ReadVar := "M->GD5_CODBAR"
 &("M->GD5_CODBAR") := cCodBar

 If (lRet := HS_VCodBar(M->GD5_CODBAR, "GD5_CODDES",,, cLctCodLoc, .F.))
  oGDMM:oBrowse:Refresh()
 EndIf
                       
 __ReadVar := cOldReadV
Return(lRet)   


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma ณHS_AddProc บAutor  ณPatricia Queiroz    บ Data ณ  30/11/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณAdiciona Procedimento.                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_AddProc(cCodProc)                           

 Local nPosDes := 0, cOldReadV := __ReadVar, lRet := .F.
 
 If (oGDPr:nAt := aScan(oGDPr:aCols, {| aVet | Empty(aVet[nPRCodDes])})) == 0
  oGDPr:AddLine(.F., .F.)                    
  oGDPr:lNewLine := .F.    
  oGDPr:nAt := Len(oGDPr:aCols)
 EndIf                     
    
 __ReadVar := "M->GD7_CODDES"  
 &("M->GD7_CODDES") := cCodProc
           
 If (lRet := HS_VProced(cGczCodpla, cLctCodLoc, cCodProc))
  oGDPr:oBrowse:Refresh()
 EndIf 
 
 __ReadVar := cOldReadV
 
Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma ณHS_PrvGD บAutor  ณJose Orfeu            บ Data ณ  01/12/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณDeclaracao das variaveis do M24.                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_PrvGD(aHMM, aHTD, aHPR, cExecM24, cFunName, cRegAte)
 Local aVParam := {}, cAlias := Alias()
 
 Default aHMM := {} // Material e Medicamentos
 Default aHTD := {} // Taxas e Diarias
 Default aHPR := {} // Procedimentos                            
           
 DbSelectArea("GCY")
 DbSetOrder(1) //GCY_FILIAL + GCY_REGATE
 DbSeek(xFilial("GCY") + cRegAte)
  
 DbSelectArea("SX3")
 DbSetOrder(1) //X3_ARQUIVO + X3_ORDEM
 DbSeek("GCY")
 
 While !Eof() .And. SX3->X3_ARQUIVO == "GCY"
  If SX3->X3_CONTEXT == "V"                                               
   _SetOwnerPrvt(AllTrim(SX3->X3_CAMPO), CriaVar(SX3->X3_CAMPO))
  Else
   _SetOwnerPrvt(AllTrim(SX3->X3_CAMPO), GCY->(FieldGet(FieldPos(SX3->X3_CAMPO))))
  EndIf 
 
  DbSkip()
 End
 
 _SetOwnerPrvt("cGcyAtendi", GCY->GCY_ATENDI                                        )
 _SetOwnerPrvt("cGcsCodLoc", GCY->GCY_CODLOC                                        )
 _SetOwnerPrvt("cGcsArmSet", HS_IniPadr("GCS", 1, cLctCodLoc   , "GCS_ARMSET",, .F.))
 _SetOwnerPrvt("cGcsCodCCu", GCS->GCS_CODCCU)
 _SetOwnerPrvt("cGcsArmFar", GCS->GCS_ARMFAR)
 _SetOwnerPrvt("cGczCodPla", HS_IniPadr("GCZ", 2, cRegAte + "0", "GCZ_CODPLA",, .F.))
 _SetOwnerPrvt("cGcuCodTpG", GCZ->GCZ_CODTPG)

 If Len(aHMM) > 0                                              
  _SetOwnerPrvt("__cFCdBKit", "HS_M24Kit()")
  _SetOwnerPrvt("__cCtrEst" , "cLctCodLoc")
  _SetOwnerPrvt("cPrefiMM"  , IIf(cExecM24 == "P", "GD5->GD5", "GE5->GE5"))
  _SetOwnerPrvt("cAliasMM"  , IIf(cExecM24 == "P", "GD5", "GE5"))
  
  _SetOwnerPrvt("__aRMatMed", {{"oGDMM:aCols[oGDMM:nAt, nMMDDESPE]", "06"}, ; // Sera utilizado dentro da fun็ใo de valida็ใo
                               {"oGDMM:aCols[oGDMM:nAt, nMMCODPRO]", "09"}, ; // do material e medicamento. HS_VMatMed()
                               {"oGDMM:aCols[oGDMM:nAt, nMMDESPRO]", "10"}})
                 
  _SetOwnerPrvt("__aRLote"  , {{"oGDMM:aCols[oGDMM:nAt, nMMNumLot]", "SB8->B8_NUMLOTE"}, ;
                               {"oGDMM:aCols[oGDMM:nAt, nMMLoteFo]", "SB8->B8_LOTEFOR"}, ;
                               {"oGDMM:aCols[oGDMM:nAt, nMMLoteCt]", "SB8->B8_LOTECTL"}, ;
                               {"oGDMM:aCols[oGDMM:nAt, nMMDtVali]", "SB8->B8_DTVALID"}})

  _SetOwnerPrvt("__aRProSel", {{"oGDMM:aCols[oGDMM:nAt, nMMNumLot]", "Space(Len(SB8->B8_NUMLOTE))"}, ;
                               {"oGDMM:aCols[oGDMM:nAt, nMMLoteFo]", "Space(Len(SB8->B8_LOTEFOR))"}, ;
                               {"oGDMM:aCols[oGDMM:nAt, nMMLoteCt]", "Space(Len(SB8->B8_LOTECTL))"}, ;
                               {"oGDMM:aCols[oGDMM:nAt, nMMDtVali]", "CToD('')"                   }, ;
                               {"oGDMM:aCols[oGDMM:nAt, nMMProAlt]", "GBI->GBI_PRODUT"            }, ;
                               {"oGDMM:aCols[oGDMM:nAt, nMMDPrAlt]", "HS_IniPadr('SB1', 1, GBI->GBI_PRODUT, 'B1_DESC',,.F.)"}})
  
  _SetOwnerPrvt("nMMStaReg", aScan(aHMM, {|aVet| aVet[2] ==                     "HSP_STAREG"}))
  _SetOwnerPrvt("nMMQDevol", aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_QDEVOL"}))
  _SetOwnerPrvt("nMMCodLoc", aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_CODLOC"}))
  _SetOwnerPrvt("nMMNomLoc", aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_NOMLOC"}))
  _SetOwnerPrvt("nMMDatDes", aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_DATDES"}))
  _SetOwnerPrvt("nMMHorDes", aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_HORDES"}))
  _SetOwnerPrvt("nMMSeqDes", aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_SEQDES"}))
  _SetOwnerPrvt("nMMQtdDes", aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_QTDDES"}))
  _SetOwnerPrvt("nMMCODDES", aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_CODDES"}))
  _SetOwnerPrvt("nMMCODBAR", aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_CODBAR"})) 
  _SetOwnerPrvt("nMMDDESPE", aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_DDESPE"}))
  _SetOwnerPrvt("nMMNumLot", aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_NUMLOT"}))
  _SetOwnerPrvt("nMMLoteFo", aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_LOTEFO"}))
  _SetOwnerPrvt("nMMLoteCt", aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_LOTECT"}))
  _SetOwnerPrvt("nMMDtVali", aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_DTVALI"}))              
  _SetOwnerPrvt("nMMProAlt", aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_PROALT"}))
  _SetOwnerPrvt("nMMDPrAlt", aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_DPRALT"}))
  _SetOwnerPrvt("nMMCodPct", aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_CODPCT"}))
  _SetOwnerPrvt("nMMDesPct", aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_DESPCT"}))
  _SetOwnerPrvt("nMMCodKit", aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_CODKIT"}))
  _SetOwnerPrvt("nMMDesKit", aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_DESKIT"}))
  _SetOwnerPrvt("nMMValDes", aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_VALDES"}))
  _SetOwnerPrvt("nMMPCuDes", aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_PCUDES"}))
  _SetOwnerPrvt("nMMCodPro", aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_CODPRO"}))
  _SetOwnerPrvt("nMMDesPro", aScan(aHMM, {|aVet| aVet[2] == PrefixoCpo(cAliasMM) + "_DESPRO"}))
 EndIf
 
 If Len(aHTD) > 0                                              
  _SetOwnerPrvt("cPrefiTD", IIf(cExecM24 == "P", "GD6->GD6", "GE6->GE6"))
  _SetOwnerPrvt("cAliasTD", IIf(cExecM24 == "P", "GD6", "GE6"))
  _SetOwnerPrvt("__aRTaxDia", {{"oGDTD:aCols[oGDTD:nAt, nTDDDESPE]", "06"}, ; // Sera utilizado dentro da fun็ใo de valida็ใo da
                               {"oGDTD:aCols[oGDTD:nAt, nTDCODTXC]", "07"}, ; // taxa e diaria. HS_VTaxDia()
                               {"oGDTD:aCols[oGDTD:nAt, nTDDESTXC]", "08"}})
  
  _SetOwnerPrvt("nTDStaReg", aScan(aHTD, {|aVet| aVet[2] ==                     "HSP_STAREG"}))
  _SetOwnerPrvt("nTDCodLoc", aScan(aHTD, {|aVet| aVet[2] == PrefixoCpo(cAliasTD) + "_CODLOC"}))
  _SetOwnerPrvt("nTDNomLoc", aScan(aHTD, {|aVet| aVet[2] == PrefixoCpo(cAliasTD) + "_NOMLOC"}))
  _SetOwnerPrvt("nTDSeqDes", aScan(aHTD, {|aVet| aVet[2] == PrefixoCpo(cAliasTD) + "_SEQDES"}))
  _SetOwnerPrvt("nTDDatDes", aScan(aHTD, {|aVet| aVet[2] == PrefixoCpo(cAliasTD) + "_DATDES"}))
  _SetOwnerPrvt("nTDHorDes", aScan(aHTD, {|aVet| aVet[2] == PrefixoCpo(cAliasTD) + "_HORDES"}))
  _SetOwnerPrvt("nTDQTDDES", aScan(aHTD, {|aVet| aVet[2] == PrefixoCpo(cAliasTD) + "_QTDDES"}))
  _SetOwnerPrvt("nTDCODDES", aScan(aHTD, {|aVet| aVet[2] == PrefixoCpo(cAliasTD) + "_CODDES"}))
  _SetOwnerPrvt("nTDDDESPE", aScan(aHTD, {|aVet| aVet[2] == PrefixoCpo(cAliasTD) + "_DDESPE"}))
  _SetOwnerPrvt("nTDCodPct", aScan(aHTD, {|aVet| aVet[2] == PrefixoCpo(cAliasTD) + "_CODPCT"}))
  _SetOwnerPrvt("nTDDesPct", aScan(aHTD, {|aVet| aVet[2] == PrefixoCpo(cAliasTD) + "_DESPCT"}))
  _SetOwnerPrvt("nTDCodKit", aScan(aHTD, {|aVet| aVet[2] == PrefixoCpo(cAliasTD) + "_CODKIT"}))
  _SetOwnerPrvt("nTDDesKit", aScan(aHTD, {|aVet| aVet[2] == PrefixoCpo(cAliasTD) + "_DESKIT"}))
  _SetOwnerPrvt("nTDValDes", aScan(aHTD, {|aVet| aVet[2] == PrefixoCpo(cAliasTD) + "_VALDES"}))
  _SetOwnerPrvt("nTDPCuDes", aScan(aHTD, {|aVet| aVet[2] == PrefixoCpo(cAliasTD) + "_PCUDES"}))
  _SetOwnerPrvt("nTDCodTxc", aScan(aHTD, {|aVet| aVet[2] == PrefixoCpo(cAliasTD) + "_CODTXC"}))
  _SetOwnerPrvt("nTDDesTxc", aScan(aHTD, {|aVet| aVet[2] == PrefixoCpo(cAliasTD) + "_DESTXC"})) 
 EndIf 
 
 If Len(aHPR) > 0
  _SetOwnerPrvt("__cFVPrPct", "HS_M24Pct()")
  _SetOwnerPrvt("cPrefiPR"  , IIf(cExecM24 == "P", "GD7->GD7", "GE7->GE7"))
  _SetOwnerPrvt("cAliasPR"  , IIf(cExecM24 == "P", "GD7", "GE7"))
  _SetOwnerPrvt("__aRProced", {{"oGDPR:aCols[oGDPR:nAt, nPRDDESPE]",     "06"}, ; // Sera utilizado dentro da fun็ใo de valida็ใo do
                               {"oGDPR:aCols[oGDPR:nAt, nPRCODESP]",     "07"}, ; // procedimento. HS_VProced()
                               {"oGDPR:aCols[oGDPR:nAt, nPRNOMESP]",     "08"}, ; // 
                               {"oGDPR:aCols[oGDPR:nAt, nPRINCIDE]", "02, 16"}, ;
                               {"oGDPR:aCols[oGDPR:nAt, nPRCODPRT]", "02, 15"}, ;
                               {"oGDPR:aCols[oGDPR:nAt, nPRDESPRT]", "02, 18"}})
  
  // Verifica se o parametro MV_ATESUS esta setado para SIM, ou seja, o Hospital atende o Plano SUS
  _SetOwnerPrvt("cMV_AteSus", GetMv("MV_ATESUS"))
  If cMV_AteSus == "S" 
   aVParam := {{"MV_PCONSUS", ""}, {"MV_PSUSBPA", ""}, {"MV_PSUSPAC", ""}, {"MV_PSUSAIH", ""}}
   If HS_VMVSUS(@aVParam)
	   _SetOwnerPrvt("__cCodCon" , aVparam[1][2])
    _SetOwnerPrvt("__cCodBPA" , aVparam[2][2])
    _SetOwnerPrvt("__cCodPAC" , aVparam[3][2])
    _SetOwnerPrvt("__cCodAIH" , aVparam[4][2])
   Else
    Return(Nil) 
   EndIf
	 EndIf
  
  _SetOwnerPrvt("nPRStaReg", aScan(aHPR, {|aVet| aVet[2] ==                     "HSP_STAREG"}))
  _SetOwnerPrvt("nPRCodLoc", aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_CODLOC"}))
  _SetOwnerPrvt("nPRNomLoc", aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_NOMLOC"}))
  _SetOwnerPrvt("nPRSeqDes", aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_SEQDES"}))
  _SetOwnerPrvt("nPRDatDes", aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_DATDES"}))
  _SetOwnerPrvt("nPRHorDes", aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_HORDES"}))
  _SetOwnerPrvt("nPRQTDDES", aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_QTDDES"}))
  _SetOwnerPrvt("nPRCODDES", aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_CODDES"}))                              
  _SetOwnerPrvt("nPRDDESPE", aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_DDESPE"}))
  _SetOwnerPrvt("nPRCODESP", aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_CODESP"}))
  _SetOwnerPrvt("nPRNOMESP", aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_NOMESP"}))
  _SetOwnerPrvt("nPRCODCRM", aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_CODCRM"}))
  _SetOwnerPrvt("nPRNOMMED", aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_NOMMED"}))
  _SetOwnerPrvt("nPRCODATO", aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_CODATO"}))
  _SetOwnerPrvt("nPRDESATO", aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_DESATO"}))
  _SetOwnerPrvt("nPRCodVia", aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_CODVIA"}))
  _SetOwnerPrvt("nPRCodPct", aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_CODPCT"}))
  _SetOwnerPrvt("nPRDesPct", aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_DESPCT"}))
  _SetOwnerPrvt("nPRCodKit", aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_CODKIT"}))
  _SetOwnerPrvt("nPRDesKit", aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_DESKIT"}))
  _SetOwnerPrvt("nPRSPrinc", aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_SPRINC"}))
  _SetOwnerPrvt("nPRCOEFAM", aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_COEFAM"})) 
  _SetOwnerPrvt("nPRVALDES", aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_VALDES"})) 
  _SetOwnerPrvt("nPRVFILME", aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_VFILME"}))
  _SetOwnerPrvt("nPRVCUSOP", aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_VCUSOP"}))
  _SetOwnerPrvt("nPRPCUDES", aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_PCUDES"}))
  _SetOwnerPrvt("nPRURGDES", aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_URGDES"}))
  _SetOwnerPrvt("nPRCOECHP", aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_COECHP"}))
  _SetOwnerPrvt("nPRQTDCHP", aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_QTDCHP"}))
  _SetOwnerPrvt("nPRPGTMED", aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_PGTMED"}))
  _SetOwnerPrvt("nPRCOECHM", aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_COECHM"}))
  _SetOwnerPrvt("nPRREPAMB", aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_REPAMB"}))
  _SetOwnerPrvt("nPRVALREP", aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_VALREP"}))
  _SetOwnerPrvt("nPRSLaudo", aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_SLAUDO"}))
  _SetOwnerPrvt("nPRCrmLau", aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_CRMLAU"}))
  _SetOwnerPrvt("nPRNMeLau", aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_NMELAU"}))
  _SetOwnerPrvt("nPRINCIDE", aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_INCIDE"}))
  _SetOwnerPrvt("nPRCoeDes", aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_COEDES"}))
  _SetOwnerPrvt("nPROriDes", aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_ORIDES"})) 
  _SetOwnerPrvt("nPRCodPrt", aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_CODPRT"})) 
  _SetOwnerPrvt("nPRDesPrt", aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_DESPRT"})) 
  _SetOwnerPrvt("nPRVlrCos", aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_VLRCOS"})) 
  If cMV_AteSus == "S"
   _SetOwnerPrvt("nPRCdAPro", aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_CDAPRO"}))
   _SetOwnerPrvt("nPRDsAPro", aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_DSAPRO"}))
   _SetOwnerPrvt("nPRCdGAte", aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_CDGATE"}))
   _SetOwnerPrvt("nPRDsGAte", aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_DSGATE"}))
   _SetOwnerPrvt("nPRCdTAte", aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_CDTATE"}))  
   _SetOwnerPrvt("nPRDsTAte", aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_DSTATE"}))
   _SetOwnerPrvt("nPRCodCid", aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_CODCID"}))
   _SetOwnerPrvt("nPRDesCid", aScan(aHPR, {|aVet| aVet[2] == PrefixoCpo(cAliasPR) + "_DESCID"}))
  EndIf
 EndIf 
 
 If cExecM24 == "F"
  If Len(aHMM) > 0
   aAdd(__aRMatMed, {"oGDMM:aCols[oGDMM:nAt, nMMVALDES]", "02"})
   aAdd(__aRMatMed, {"oGDMM:aCols[oGDMM:nAt, nMMPCUDES]", "03"})
  EndIf 
  
  If Len(aHTD) > 0
   aAdd(__aRTaxDia, {"oGDTD:aCols[oGDTD:nAt, nTDVALDES]", "02"})
   aAdd(__aRTaxDia, {"oGDTD:aCols[oGDTD:nAt, nTDPCUDES]", "03"})
  EndIf
  
  If Len(aHPR) > 0                                                    
   aAdd(__aRProced, {"oGDPR:aCols[oGDPR:nAt, nPRCOEFAM]", "02, 01, 02"})
   aAdd(__aRProced, {"oGDPR:aCols[oGDPR:nAt, nPRVALDES]", "02, 01, 01"})
   aAdd(__aRProced, {"oGDPR:aCols[oGDPR:nAt, nPRVFILME]", "02, 03"})
   aAdd(__aRProced, {"oGDPR:aCols[oGDPR:nAt, nPRVCUSOP]", "02, 02"})
   aAdd(__aRProced, {"oGDPR:aCols[oGDPR:nAt, nPRPCUDES]", "03"})
   aAdd(__aRProced, {"oGDPR:aCols[oGDPR:nAt, nPRURGDES]", "02, 14"})
   aAdd(__aRProced, {"oGDPR:aCols[oGDPR:nAt, nPRCOECHP]", "02, 10"})
   aAdd(__aRProced, {"oGDPR:aCols[oGDPR:nAt, nPRQTDCHP]", "02, 11"})
   aAdd(__aRProced, {"oGDPR:aCols[oGDPR:nAt, nPRPGTMED]", "09, 01"})
   aAdd(__aRProced, {"oGDPR:aCols[oGDPR:nAt, nPRCOECHM]", "02, 13"})
   aAdd(__aRProced, {"oGDPR:aCols[oGDPR:nAt, nPRREPAMB]", "02, 12"})
   aAdd(__aRProced, {"oGDPR:aCols[oGDPR:nAt, nPRQTDDES]", "16, 01"})   
   Iif( cAliasPR <> "GD7", aAdd(__aRProced, {"oGDPR:aCols[oGDPR:nAt, nPRCOEDES]", "16, 02"}), Nil)
   aAdd(__aRProced, {"oGDPR:aCols[oGDPR:nAt, nPRVLRCOS]", "02, 24"})
  EndIf 
   
 ElseIf cFunName == "HSPAHP12"
  If Len(aHPR) > 0
   aAdd(__aRProced, {"oGDPR:aCols[oGDPR:nAt, nPRVALDES]", "02, 01, 01"})
   aAdd(__aRProced, {"oGDPR:aCols[oGDPR:nAt, nPRVFILME]", "02, 03"})
   aAdd(__aRProced, {"oGDPR:aCols[oGDPR:nAt, nPRPGTMED]", "09, 01"})
   aAdd(__aRProced, {"oGDPR:aCols[oGDPR:nAt, nPRQTDDES]", "16, 01"})  
   Iif( cAliasPR <> "GD7", aAdd(__aRProced, {"oGDPR:aCols[oGDPR:nAt, nPRCOEDES]", "16, 02"}), Nil)
   
   If cMV_AteSus == "S"
    If cGczCodPla == __cCodBPA
     aAdd(__aRProced, {"oGDPR:aCols[oGDPR:nAt, nPRCDGATE]", "15, 02, 01"})
     aAdd(__aRProced, {"oGDPR:aCols[oGDPR:nAt, nPRDSGATE]", "15, 02, 02"})
     aAdd(__aRProced, {"oGDPR:aCols[oGDPR:nAt, nPRCDTATE]", "15, 03, 01"})
     aAdd(__aRProced, {"oGDPR:aCols[oGDPR:nAt, nPRDSTATE]", "15, 03, 02"})
    EndIf
    If cGczCodPla == __cCodBPA .Or. cGczCodPla $ __cCodPAC
     aAdd(__aRProced, {"oGDPR:aCols[oGDPR:nAt, nPRCDAPRO]", "15, 01, 01"})
     aAdd(__aRProced, {"oGDPR:aCols[oGDPR:nAt, nPRDSAPRO]", "15, 01, 02"})
     aAdd(__aRProced, {"oGDPR:aCols[oGDPR:nAt, nPRCODCID]", "15, 04, 01"})
     aAdd(__aRProced, {"oGDPR:aCols[oGDPR:nAt, nPRDESCID]", "15, 04, 02"})
    EndIf
   EndIf
  EndIf 
 EndIf
Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma ณHS_RelM01 บAutor  ณPatricia Queiroz    บ Data ณ  30/11/06    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณExecuta a rotina que permite a impressใo das fichas.        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_RelM01()  

 GDN->(dbSetOrder(1)) //GDN_FILIAL + GDN_CODLOC + GDN_CODFIC
 If GDN->(DbSeek(xFilial("GDN") + cLocCodCol))
		HSPAHP44(.T., cLocCodCol)
 EndIf     
 
Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma ณFS_VldDtHr บAutor  ณPatricia Queiroz    บ Data ณ  09/01/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณPreenche os campos Data Final e Hora Final.                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_VldDtHr(nOpc)

 Local aArea := GetArea()
 
 If nOpc == 5
  M->GGO_DATFIN := dDataBase
  M->GGO_HORFIN := Time()
 EndIf 
 
 RestArea(aArea) 

Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_EtqM01  บAutor  ณPatricia Queiroz    บ Data ณ  12/01/07  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณImprimi as etiquetas de acordo com o tipo de doacao.        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                                     
Function HS_EtqM01(cRegAte, aAmostra)

 Local aArea    := GetArea()
 Local cCodTipD := ""
 Local aCpos    := {}
 Local nFor     := 0
 
 cCodTipD := HS_IniPadr("GCY", 1, cRegAte, "GCY_CDTIPD",, .F.)
 
 DbSelectArea("GGX")
 DbSetOrder(2) //GGX_FILIAL + GGX_CDTIPD + GGX_CDITEM
 DbSeek(xFilial("GGX") + cCodTipD)
 While !Eof() .And. GGX->GGX_CDTIPD == cCodTipD
 	aAdd(aCpos, {GGX->GGX_CDETIQ, GGX->GGX_QTDETI})  
 	DbSkip() 	 	
 EndDo    
 
 If Len(aCpos) == 0
  HS_MsgInf(STR0048, STR0014, STR0017) //"Nใo hแ etiquetas para as amostras."###"Aten็ใo"###"Valida็ใo de Amostras"
  Return(.F.)
 Else
  For nFor := 1 To Len(aCpos)
   HSPAHR71(AllTrim(aCpos[nFor, 1]), {aCpos[nFor, 2], aAmostra[1, 1], aAmostra[Len(aAmostra), 1]})
  Next 
 EndIf 
 
 RestArea(aArea)

Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_ItemM01 บAutor  ณPatricia Queiroz    บ Data ณ  12/01/07  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricaoณVerifica se jแ existem amostras para o atendimento, se houverบฑฑ
ฑฑบ          comeca a incrementar o campo GGP_CDITEM a partir do ultimo.  บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                                     
Function FS_ItemM01(cRegAte)

 Local aArea := GetArea()
 Local nItem := 0
 Local cSQL  := ""
 
 cSQL := "SELECT GGP_REGATE, GGP_CDAMOT, GGP_CDITEM "
 cSQL += "FROM " + RetSqlName("GGP") + " GGP "
 cSQL += "WHERE GGP_FILIAL = '" + xFilial("GGP") + "' AND GGP.D_E_L_E_T_ <> '*' "
 cSQL += "AND GGP_REGATE = '" + cRegAte + "' "
 
 cSQL := ChangeQuery(cSQL)
 TCQUERY cSQL NEW ALIAS "QRY"
 
 DbSelectArea("QRY")
 DbGoTop()
 
 While !Eof()
  nItem := Val(QRY->GGP_CDITEM)
  DbSkip()
 EndDo
 
 DbCloseArea()
 RestArea(aArea) 
                
Return(nItem)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VldGrav บAutor  ณPatricia Queiroz    บ Data ณ  22/02/07  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณValidacao os dados para gravacao                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_VldGrav()

 Local aArea := GetArea()
 Local lRet  := .F.
 Local nFor  := 0


 If Len(oGGP:aCols) == 1 .And. Empty(oGGp:aCols[1, nGGPCODBAR])
  HS_MsgInf(STR0055, STR0014, STR0056) //"Nใo hแ amostras para saํda. Cancele a saํda ou inclua novas amostras."###"Aten็ใo"###"Valida็ใo de Saํda de Amostras"
 Else
  For nFor := 1 To Len(oGGP:aCols)
   If lRet := !oGGP:aCols[nFor, nUGGP + 1]
    Exit
   Else
    Loop
   EndIf
  Next() 
 EndIf    
 
 RestArea(aArea)

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_M01INT บAutor  ณLuiz Pereira       บ Data ณ  04/03/07    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Montagem da tela de intercorrencia.                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HS_M01Int(cRegAte, cCdCole, cCdAnam, lPermite)
 Local aSize := {}, aObjects := {}, aInfo := {}, aPObjs := {}
 Local nOpcA := 0
 Local oBtnVis
 Local aHGHK := {}, aCGHK := {}
 Local nRegistros := 0
 Local cCond := "GHK->GHK_REGATE == '" + cRegAte + "'" + IIf(ValType(cCdCole) <> "U", " .AND. GHK->GHK_CDCOLE == '" + cCdCole + "'", "") +;
                IIf(ValType(cCdAnam) <> "U", " .AND. GHK->GHK_CDANAM == '" + cCdAnam + "'", "")
 
 Private oDlg := Nil
 Private nGHKCODINT := 0
 
 Default lPermite := .T.

 aSize := MsAdvSize(.T.)
 aObjects := {}
 AAdd(aObjects, {100, 010, .T., .T.})
 AAdd(aObjects, {100, 080, .T., .T.})
 AAdd(aObjects, {100, 010, .T., .T.})
 
 aInfo  := {aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0}
 aPObjs := MsObjSize(aInfo, aObjects, .T.)
 
 nRegistros := HS_BDados("GHK", @aHGHK, @aCGHK,, 1,, cCond,,,,,,,, )
 nGHKCODINT := aScan(aHGHK, {| aVet | aVet[2] == "GHK_CODINT"})
 
 DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0070) From aSize[7], 0 To aSize[6], aSize[5]	PIXEL Of oMainWnd  //"Intercorr๊ncias"

  oScrollBox := TScrollBox():New(oDlg, aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4], .T., .T., .T.)
 
  oBtnVis := tButton():New(010,010, STR0073,  oScrollBox, {|| FS_Interc(2, @oGHK, @nRegistros, cCond, cRegAte, cCdCole, cCdAnam) }    ,050,012,,,, .T.)    //"Visualizar"
  oBtnInc := tButton():New(010,070, STR0074,  oScrollBox, {|| FS_Interc(3, @oGHK, @nRegistros, cCond, cRegAte, cCdCole, cCdAnam) }    ,050,012,,,, lPermite)    //"Incluir"
  oBtnAlt := tButton():New(010,130, STR0075,  oScrollBox, {|| FS_Interc(4, @oGHK, @nRegistros, cCond, cRegAte, cCdCole, cCdAnam) }    ,050,012,,,, lPermite)    //"Alterar"
  oBtnExc := tButton():New(010,190, STR0076,  oScrollBox, {|| FS_Interc(5, @oGHK, @nRegistros, cCond, cRegAte, cCdCole, cCdAnam) }    ,050,012,,,, lPermite)    //"Excluir"
  
  oGHK := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4],,,,,,,,,,, oDlg, aHGHK, aCGHK)
  
  oScrollBox3 := TScrollBox():New(oDlg, aPObjs[3, 1], aPObjs[3, 2], aPObjs[3, 3], aPObjs[3, 4], .T., .T., .T.)
  
  HS_GDPesqu(aHGHK, aCGHK, oGHK, oScrollBox3, 002)
 
 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {|| nOpcA := 1, oDlg:End() }, ;
                                                   {|| nOpcA := 0, oDlg:End() })
                                                   
 If nRegistros == 0
  While __lSx8
   RollBackSx8() 
  End 
 EndIf
 
Return(.T.)


Static Function FS_Interc(nOpc, oGDGHK, nRegistros, cCond, cRegAte, cCdCole, cCdAnam)

 Local aSizeInt := {}, aObjInt := {}, aInfoInt := {}, aPObjsInt := {}
 Local oDlgInt := Nil
 Local nOpcA := 0
 
 Private aTela := {}
 Private aGets := {} 
 Private aRotina     := {{"", "", 0, 01}, ;
                         {"", "", 0, 02}, ; 
                         {"", "", 0, 03}, ; 
                         {"", "", 0, 04}, ; 
                         {"", "", 0, 05}}
                         
 If nRegistros == 0 .And. nOpc<> 3
  HS_MsgInf(STR0072, STR0014,STR0070)//"Somente a opera็ใo de inclusใo ้ permitida quando o arquivo estแ vazio."###"Aten็ใo"###"Intercorr๊ncias"
  Return(.F.)
 EndIf
 
 DbSelectArea("GHK")
 DbSetOrder(1) //GHK_FILIAL + GHK_CODINT
 DbSeek(xFilial("GHK") + oGDGHK:aCols[oGDGHK:nAt, nGHKCODINT] )
 
 RegToMemory("GHK", nOpc == 3)
 
 If nOpc == 3
  M->GHK_REGATE := cRegAte
  If ValType(cCdCole) <> "U"
   M->GHK_CDCOLE := cCdCole
  EndIf
  If ValType(cCdAnam) <> "U"
   M->GHK_CDANAM := cCdAnam
  EndIf
 EndIf

 aSizeInt := MsAdvSize(.T.)
 aObjInt := {}
 AAdd(aObjInt, {100, 100, .T.,.T.})
 
 aInfoInt  := {aSizeInt[ 1 ], aSizeInt[ 2 ], aSizeInt[ 3 ], aSizeInt[ 4 ], 0, 0}
 aPObjsInt := MsObjSize(aInfoInt, aObjInt, .T.)
 
 DEFINE MSDIALOG oDlgInt TITLE OemToAnsi(STR0070) From aSizeInt[7], 0 To aSizeInt[6], aSizeInt[5]	PIXEL Of oMainWnd  //"Intercorr๊ncias"

  oEncGHK := MsMGet():New("GHK", GHK->(Recno()), nOpc,,,,, aPObjsInt[1],,,,,, oDlgInt)
 
 ACTIVATE MSDIALOG oDlgInt ON INIT EnchoiceBar (oDlgInt, {|| nOpcA := 1, IIf(Obrigatorio(aGets, aTela), oDlgInt:End(), nOpcA:=0) }, ;
                                                         {|| nOpcA := 0, oDlgInt:End() })
 
 If nOpcA == 1 .And. nOpc <> 2
  Begin Transaction
   FS_GrvInt(nOpc)
  End Transaction
  
  oGDGHK:aCols   := {}
  oGDGHK:aHeader := {}
 
  nRegistros := HS_BDados("GHK", @oGDGHK:aHeader, @oGDGHK:aCols,, 1,, cCond,,,,,,,, )
  ConfirmSx8()
 Else
  While __lSx8
   RollBackSx8() 
  End
 EndIf

Return()

Static Function FS_GrvInt(nOpc)

 DbSelectArea("GHK")
 RecLock("GHK", nOpc == 3)
  If nOpc <> 5
   If nOpc == 3
    M->GHK_CODINT := HS_VSxeNum("GHK", "M->GHK_CODINT", 1)
   EndIf
   HS_GrvCpo("GHK")
  Else
   DbDelete()
  EndIf
 MsUnlock()

Return()
             


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_MntProt บAutor  ณPatricia Queiroz    บ Data ณ  20/04/07  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณFuncao para apresnetar a tela de selecao.                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_MntProt(nOpcML)

 Local aArea := GetArea()
 Local aHGGQ := {}, aCGGQ := {}, nUGGQ := 0
 Local nOpcA := 0
 Local aCpos := {}
  
 Private nGGQIDMARK := 0, nGGQCDPROT := 0 
 Private oGGQ        
 
 aCpos    := "GGQ_CDPROT"
 aCposNao := "GGQ_MOTRES/GGQ_RESLIB/GGQ_TEMPSA/GGQ_TIPTRA/GGQ_HORSAI/GGQ_DATSAI/GGQ_CODBAR/GGQ_RESREC/GGQ_TEMPCH/GGQ_DATREC/GGQ_HORCHE/GGQ_VALREC/GGQ_SITLOT/GGQ_UNICOL"


 nUGGQ := HS_BDados("GGQ", @aHGGQ, @aCGGQ,, 1,, "GGQ->GGQ_UNICOL == '" + cLocCodCol + "' AND GGQ->GGQ_SITLOT == '0'",,, aCpos,, aCposNao,, "GGQ_IDMARK") 
 nGGQIDMARK := aScan(aHGGQ, {| aVet | aVet[2] == "GGQ_IDMARK"})
 nGGQCDPROT := aScan(aHGGQ, {| aVet | aVet[2] == "GGQ_CDPROT"})
 
 If nUGGQ > 0                
 
  DEFINE MSDIALOG oDlgProt TITLE OemToAnsi(STR0083) From 500, 300 TO 800, 670 PIXEL Of oMainWnd //"Protocolos em Aberto"
    
   oGGQ := MsNewGetDados():New(200, 300, 200, 300,,,,,,,,,,,, aHGGQ, aCGGQ)
   oGGQ:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT                     
   oGGQ:oBrowse:BlDblClick := {|| FS_DblClik(oGGQ)}  
                                                                              //[1] retorno .T. ou .F. da fun็ใo
  ACTIVATE MSDIALOG oDlgProt CENTERED ON INIT EnchoiceBar(oDlgProt, {|| nOpcA := 1, IIF(FS_SelProt(oGGQ, @aProt)[1], oDlgProt:End(), nOpcA := 0)}, ;
                                                            {|| nOpcA := 0, oDlgProt:End()})
                                                           
  If nOpcA == 1
   cLote  := aProt[1]
  EndIf
 EndIf                                                            
 
 RestArea(aArea) 
 
Return(nOpcA)
 
   
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_DblClik บAutor  ณPatricia Queiroz    บ Data ณ  20/04/07  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณFuncao para marcar e desmarcar o item.                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_DblClik(oGGQ)

 If oGGQ:aHeader[oGGQ:oBrowse:nColPos, 2] == "GGQ_IDMARK"
  oGGQ:aCols[oGGQ:oBrowse:nAt, nGGQIDMARK] := IIf(oGGQ:aCols[oGGQ:oBrowse:nAt, nGGQIDMARK] == "LBTIK", "LBNO", "LBTIK")
 Else
  oGGQ:EDITCELL(oGGQ:oBrowse, oGGQ:oBrowse:nAt, oGGQ:oBrowse:nColPos)
 EndIf
 
Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_SelProt บAutor  ณPatricia Queiroz    บ Data ณ  20/04/07  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ. Selecao do protocolo em aberto.                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_SelProt(oGGQ, aProt)

 Local aArea  := GetArea()
 Local nFProt := 0
 Local lRet   := .T. 
 
 For nFProt := 1 To Len(oGGQ:aCols)
  If oGGQ:aCols[nFProt, nGGQIDMARK] == "LBTIK"
   aAdd(aProt, oGGQ:aCols[nFProt, nGGQCDPROT])
  EndIf   
 Next
 
 If Len(aProt) > 1
  HS_MsgInf(STR0080, STR0014, STR0081) //"Selecione apenas um protocolo."###"Aten็ใo"###"Valida็ใo de protocolo"
  lRet := .F.
 ElseIf Len(aProt) == 0 
  HS_MsgInf(STR0082, STR0014, STR0081) //"Selecione um protocolo."###"Aten็ใo"###"Valida็ใo de protocolo"
  lRet := .F.
 EndIf

 RestArea(aArea)

Return({lRet, aProt})
