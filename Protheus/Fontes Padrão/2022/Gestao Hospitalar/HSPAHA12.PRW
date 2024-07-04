#INCLUDE "HSPAHA12.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHA12  บ Autor ณ Cibele Peria       บ Data ณ  12/11/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Cadastro de Setor                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static __cRetFic := ""

Function HSPAHA12()

 Private aRotina := MenuDef()
						
						 

Private cGCSClasse := "2"
Private cGsDCtrl   := ""

Private lGFR := HS_LocTab("GFR", .F.)

If !HS_ExisDic({{"T", "GNO"}, {"C", "GCS_HORPAD"}})
	Return(Nil)
EndIf
mBrowse(06, 01, 22, 75, "GCS")
 

Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_A12    บ Autor ณ Cibele Peria       บ Data ณ  12/11/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Tratamento das Funcoes                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar (Agenda Ambulatorial)             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_A12(cAlias, nReg, nOpc12)

 Local nOpcA := 0
 Local  nGDOpc := IIf(nOpc12 == 2 .Or. nOpc12 == 5, 0, GD_INSERT + GD_UPDATE + GD_DELETE)
 
 Local bKeyF4, aJoin := {}

 Private oEscolhe
 Private aCGM0	:= {}, aHGM0 := {}, nUGM0 := 0, nLGM0 := 0
 Private aCGM1	:= {}, aHGM1 := {}, nUGM1 := 0, nLGM1 := 0
 Private aCGM2	:= {}, aHGM2 := {}, nUGM2 := 0, nLGM2 := 0
 Private aCGMB	:= {}, aHGMB := {}, nUGMB := 0, nLGMB := 0
 Private aCGDN	:= {}, aHGDN := {}, nUGDN := 0, nLGDN := 0       
 Private aCGMN	:= {}, aHGMN := {}, nUGMN := 0, nLGMN := 0        
 Private aCGNO	:= {}, aHGNO := {}, nUGNO := 0, nLGNO := 0     
 Private aTela := {}, aGets := {} 
 Private nGM0_CODLOC := 0, nGM0_CODPLA := 0, nGM0_DESPLA := 0, nGM0_STAREG := 0
 Private nGM1_CODLOC := 0, nGM1_CODUSU := 0, nGM1_STAREG := 0
 Private nGM2_CODLOC := 0, nGM2_CODPRO := 0, nGM2_NOMPRO := 0, nGM2_STAREG := 0
 Private nGMB_CODLOC := 0, nGMB_CODTXD := 0, nGMB_DESTXD := 0, nGMB_STAREG := 0
 Private nGDN_CODLOC := 0, nGDN_CODFIC := 0, nGDN_NOMFIC := 0, nGDN_NVIAS  := 0,  nGDN_FUNCAO := 0, nGDN_STAREG := 0
 Private nGMN_DIASEM := 0, nGMN_STAREG := 0
 Private nGNO_CODPRO := 0, nGNO_DESPRO := 0, nGNO_STAREG := 0
  
 Private oGM0, oGM1, oGM2, oGMB, oGDN, oGMN, oGNO, oFolder, pForACols := 0
 Private cEndOld := ""
 Private cTabSix := "GM8"

 RegToMemory("GCS", IIf( nOpc12 == 3, .T., .F.))// Gera variavies de memoria para o GCS
 
 cGsDCtrl := M->GCS_ENDTIP
 cEndOld  := M->GCS_CODEND

 
 HS_BDados("GM0", @aHGM0, @aCGM0, @nUGM0, 1, M->GCS_CODLOC, IIF(nOpc12 # 3, " GM0_CODLOC = '"+ GCS->GCS_CODLOC+"'", Nil), .T.)
 nGM0_STAREG := aScan(aHGM0, {| aVet | aVet[2] == "HSP_STAREG"})
 nGM0_CODLOC := aScan(aHGM0, {| aVet | aVet[2] == "GM0_CODLOC"})
 nGM0_CODPLA := aScan(aHGM0, {| aVet | aVet[2] == "GM0_CODPLA"})
 nGM0_DESPLA := aScan(aHGM0, {| aVet | aVet[2] == "GM0_DESPLA"})
 nLGM0 := IIF(Len(aCGM0) == 1 .And. Empty(aCGM0[1, nGM0_CODPLA]), 0, Len(aCGM0))

 HS_BDados("GM1", @aHGM1, @aCGM1, @nUGM1, 1, M->GCS_CODLOC, IIF(nOpc12 # 3,  " GM1_CODLOC = '"+  GCS->GCS_CODLOC+"'", Nil), .T.)
 nGM1_STAREG := aScan(aHGM1, {| aVet | aVet[2] == "HSP_STAREG"})
 nGM1_CODLOC := aScan(aHGM1, {| aVet | aVet[2] == "GM1_CODLOC"})
 nGM1_CODUSU := aScan(aHGM1, {| aVet | aVet[2] == "GM1_CODUSU"})
 nLGM1 := IIF(Len(aCGM1) == 1 .And. Empty(aCGM1[1, nGM1_CODUSU]), 0, Len(aCGM1))
 
 aJoin := {{" LEFT JOIN " + RetSqlName("GA7") + " GA7", "GA7.GA7_DESC", "GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' AND GA7.GA7_CODPRO = GM2.GM2_CODPRO", "GM2_DESPRO"}}
         
 HS_BDados("GM2", @aHGM2, @aCGM2, @nUGM2, 1, M->GCS_CODLOC, IIF(nOpc12 # 3, "'" + M->GCS_CODLOC + "' == GM2->GM2_CODLOC", Nil), .T.,,,,,,,,,,,,,,, aJoin)
 nGM2_STAREG := aScan(aHGM2, {| aVet | aVet[2] == "HSP_STAREG"})
 nGM2_CODLOC := aScan(aHGM2, {| aVet | aVet[2] == "GM2_CODLOC"})
 nGM2_CODPRO := aScan(aHGM2, {| aVet | aVet[2] == "GM2_CODPRO"})
 nGM2_DESPRO := aScan(aHGM2, {| aVet | aVet[2] == "GM2_DESPRO"})
 nLGM2 := IIF(Len(aCGM2) == 1 .And. Empty(aCGM2[1, nGM2_CODPRO]), 0, Len(aCGM2))
      
 aJoin := {{" LEFT JOIN " + RetSqlName("GAA") + " GAA", "GAA.GAA_DESC", "GAA.GAA_FILIAL = '" + xFilial("GAA") + "' AND GAA.D_E_L_E_T_ <> '*' AND GAA.GAA_CODTXD = GMB.GMB_CODTXD", "GMB_DESTXD"}}

 HS_BDados("GMB", @aHGMB, @aCGMB, @nUGMB, 1, M->GCS_CODLOC, IIF(nOpc12 # 3, "'" + M->GCS_CODLOC + "' == GMB->GMB_CODLOC", Nil), .T.,,,,,,,,,,,,,,, aJoin)
 nGMB_STAREG := aScan(aHGMB, {| aVet | aVet[2] == "HSP_STAREG"})
 nGMB_CODLOC := aScan(aHGMB, {| aVet | aVet[2] == "GMB_CODLOC"})
 nGMB_CODTXD := aScan(aHGMB, {| aVet | aVet[2] == "GMB_CODTXD"})
 nGMB_DESTXD := aScan(aHGMB, {| aVet | aVet[2] == "GMB_DESTXD"})
 nLGMB := IIF(Len(aCGMB) == 1 .And. Empty(aCGMB[1, nGMB_CODTXD]), 0, Len(aCGMB))
 
 HS_BDados("GDN", @aHGDN, @aCGDN, @nUGDN, 1, M->GCS_CODLOC, IIF(nOpc12 # 3, "'" + M->GCS_CODLOC + "' == GDN->GDN_CODLOC", Nil), .T.)
 nGDN_STAREG := aScan(aHGDN, {| aVet | aVet[2] == "HSP_STAREG"})
 nGDN_CODFIC := aScan(aHGDN, {| aVet | aVet[2] == "GDN_CODFIC"})
 nGDN_NOMFIC := aScan(aHGDN, {| aVet | aVet[2] == "GDN_NOMFIC"})
 nGDN_NVIAS  := aScan(aHGDN, {| aVet | aVet[2] == "GDN_NVIAS "})
 nGDN_FUNCAO := aScan(aHGDN, {| aVet | aVet[2] == "GDN_FUNCAO"})
 nGDN_CODFIC := aScan(aHGDN, {|aVet| AllTrim(aVet[2]) == "GDN_CODFIC"})

 nLGDN := IIF(Len(aCGDN) == 1 .And. Empty(aCGDN[1, nGDN_CODFIC]), 0, Len(aCGDN))
 If nLGDN == 0 
  aCGDN[1, nGDN_CODFIC] := StrZero(1, Len(GDN->GDN_CODFIC))
 EndIf 
 
 HS_BDados("GMN", @aHGMN, @aCGMN, @nUGMN, 1, M->GCS_CODLOC, IIF(nOpc12 <> 3, "'" + M->GCS_CODLOC + "' == GMN->GMN_CODLOC", Nil), .T.)
 nGMN_STAREG := aScan(aHGMN, {| aVet | aVet[2] == "HSP_STAREG"})
 nGMN_DIASEM := aScan(aHGMN, {| aVet | aVet[2] == "GMN_DIASEM"})

  
 HS_BDados("GNO", @aHGNO, @aCGNO, @nUGNO, 1, M->GCS_CODLOC, IIF(nOpc12 <> 3, "'" + M->GCS_CODLOC + "' == GNO->GNO_CODLOC", Nil), .T.)
 nGNO_STAREG := aScan(aHGNO, {| aVet | aVet[2] == "HSP_STAREG"})
 nGNO_CODPRO := aScan(aHGNO, {| aVet | aVet[2] == "GNO_CODPRO"})
 nGNO_DESPRO := aScan(aHGNO, {| aVet | aVet[2] == "GNO_DESPRO"})   
 
 nLGNO := IIF(Len(aCGNO) == 1 .And. Empty(aCGNO[1, nGNO_CODPRO]), 0, Len(aCGNO))
 
 nOpcA := 0      
 
 aSize := MsAdvSize(.T.)
 aObjects := {}	
 AAdd( aObjects, { 100, 050, .T., .T. } )	
 AAdd( aObjects, { 100, 050, .T., .T.,.T. } )	
 
 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPObjs := MsObjSize( aInfo, aObjects, .T. )  
 
 aObjects := {}	
 AAdd( aObjects, { 100, 100, .T., .T. } )	
 
 aInfo := { aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], 0, 0 }
 aPGDs := MsObjSize( aInfo, aObjects, .T. )   

 DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0006) From aSize[7], 0 To aSize[6], aSize[5]	PIXEL Of oMainWnd //"Setor"

  oEncGcs := MsMGet():New("GCS", nReg, nOpc12,,,,, aPObjs[1],, 3,,,, oDlg,, .T.,,,,,, .T.)
   oEncGcs:aEntryCtrls[aScan(oEncGcs:aGets, {|x| "GCS_CODLOC" $ x}) ]:lReadOnly := (nOpc12 <> 3)
   oEncGcs :oBox:Align := CONTROL_ALIGN_ALLCLIENT
  // Monta o Folder 
  @ aPObjs[2, 1], aPObjs[2, 2] FOLDER oFolder SIZE aPObjs[2, 3], aPObjs[2, 4] Pixel Of oDlg Prompts STR0007, STR0008, STR0009, STR0010, STR0043, STR0046,STR0062 //"Mat/Med nใo permitidos"##"Planos nใo permitidos"###"Usuแrios permitidos"###"Procedimentos permitidos"###"Taxas Diแrias permitidas"###"Fichas"###"Cirurgias x Dia"
  oFolder:Align := CONTROL_ALIGN_BOTTOM    
  
  oGM0 := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], nGDOpc, "HS_DuplAC(oGM0:oBrowse:nAt, oGM0:aCols, {nGM0_CODPLA},, .T.)",,,,, 99999,,,, oFolder:aDialogs[1], aHGM0, aCGM0)
  oGM0:oBrowse:align := CONTROL_ALIGN_ALLCLIENT
  oGM0:cFieldOk := "HS_GDAtrib(oGM0, {{nGM0_STAREG, 'BR_AMARELO', 'BR_VERDE'}})"
  oGM0:oBrowse:bDelete := {|| HS_GDAtrib(oGM0, {{nGM0_STAREG, "BR_CINZA", "BR_VERDE"}}), oGM0:DelLine()}
  
  oGM1 := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], nGDOpc, "HS_DuplAC(oGM1:oBrowse:nAt, oGM1:aCols, {nGM1_CODUSU},, .T.)",,,,, 99999,,,, oFolder:aDialogs[2], aHGM1, aCGM1)  
  oGM1:oBrowse:align := CONTROL_ALIGN_ALLCLIENT  
  oGM1:cFieldOk := "HS_GDAtrib(oGM1, {{nGM1_STAREG, 'BR_AMARELO', 'BR_VERDE'}})"
  oGM1:oBrowse:bDelete := {|| HS_GDAtrib(oGM1, {{nGM1_STAREG, "BR_CINZA", "BR_VERDE"}}), oGM1:DelLine()}
  
  oGM2 := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], nGDOpc, "HS_DuplAC(oGM2:oBrowse:nAt, oGM2:aCols, {nGM2_CODPRO},, .T.)",,,,, 99999,,,, oFolder:aDialogs[3], aHGM2, aCGM2)
  oGM2:oBrowse:align := CONTROL_ALIGN_ALLCLIENT 
  oGM2:cFieldOk := "HS_GDAtrib(oGM2, {{nGM2_STAREG, 'BR_AMARELO', 'BR_VERDE'}})"
  oGM2:oBrowse:bDelete := {|| HS_GDAtrib(oGM2, {{nGM2_STAREG, "BR_CINZA", "BR_VERDE"}}), oGM2:DelLine()}
  oGM2:oBrowse:bDelOk := {|| FS_VlExGM2()}
 
  oGMB := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], nGDOpc, "HS_DuplAC(oGMB:oBrowse:nAt, oGMB:aCols, {nGMB_CODTXD},, .T.)",,,,,99999,,,, oFolder:aDialogs[4], aHGMB, aCGMB)
  oGMB:oBrowse:align := CONTROL_ALIGN_ALLCLIENT
  oGMB:cFieldOk := "HS_GDAtrib(oGMB, {{nGMB_STAREG, 'BR_AMARELO', 'BR_VERDE'}})"
  oGMB:oBrowse:bDelete := {|| HS_GDAtrib(oGMB, {{nGMB_STAREG, "BR_CINZA", "BR_VERDE"}}), oGMB:DelLine()}
  
  oGDN := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], nGDOpc,,, "+GDN_CODFIC",,, 99999,,,, oFolder:aDialogs[5], aHGDN, aCGDN)
  oGDN:oBrowse:align := CONTROL_ALIGN_ALLCLIENT
  oGDN:cFieldOk := "HS_GDAtrib(oGDN, {{nGDN_STAREG, 'BR_AMARELO', 'BR_VERDE'}})"
  oGDN:oBrowse:bDelete := {|| HS_GDAtrib(oGDN, {{nGDN_STAREG, "BR_CINZA", "BR_VERDE"}}), oGDN:DelLine()}
  
  oGMN := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], nGDOpc, "HS_DuplAC(oGMN:oBrowse:nAt, oGMN:aCols, {nGMN_DIASEM},, .T.)",,,,, 99999,,,, oFolder:aDialogs[6], aHGMN, aCGMN)
  oGMN:oBrowse:align := CONTROL_ALIGN_ALLCLIENT
  oGMN:cFieldOk := "HS_GDAtrib(oGMN, {{nGMN_STAREG, 'BR_AMARELO', 'BR_VERDE'}})"
  oGMN:oBrowse:bDelete := {|| HS_GDAtrib(oGMN, {{nGMN_STAREG, "BR_CINZA", "BR_VERDE"}}), oGMN:DelLine()}
  
  oGNO := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], nGDOpc, "HS_DuplAC(oGNO:oBrowse:nAt, oGNO:aCols, {nGNO_CODPRO},, .T.)",,,,, 99999,,,, oFolder:aDialogs[7], aHGNO, aCGNO)
  oGNO:oBrowse:align := CONTROL_ALIGN_ALLCLIENT
  oGNO:cFieldOk := "HS_GDAtrib(oGNO, {{nGNO_STAREG, 'BR_AMARELO', 'BR_VERDE'}})"
  oGNO:oBrowse:bDelete := {|| HS_GDAtrib(oGNO, {{nGNO_STAREG, "BR_CINZA", "BR_VERDE"}}), oGNO:DelLine()}
  oEscolhe :={{"parametros", {|| FS_Busca(oFolder:NOPTION) }, STR0011, STR0047}} //"Busca Dados"###"Dados"

  bKeyF4 := SetKey( VK_F4, { || FS_Busca(oFolder:NOPTION)} ) //"Busca Dados"

 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar (oDlg, {|| nOpcA := 1, ;
                                                                IIF(Obrigatorio(aGets, aTela) .And. ;
                                                                    HS_TudoOK("GM0", oGM0, nGM0_CODPLA) .And. ;
                                                                    HS_TudoOK("GM1", oGM1, nGM1_CODUSU) .And. ;
                                                                    HS_TudoOK("GM2", oGM2, nGM2_CODPRO) .And. ;
                                                                    HS_TudoOK("GMB", oGMB, nGMB_CODTXD) .And. ;
                                                                    HS_TudoOK("GDN", oGDN, nGDN_NOMFIC) .And. ;  
                                                                    HS_TudoOK("GMN", oGMN, nGMN_DIASEM) .And. ;  
                                                                    HS_TudoOK("GNO", oGNO, nGNO_CODPRO) .And. ;
                                                                    FS_VLDTIP() .And. FS_VLDESP() .And. ;
                                                                    FS_VldExcL(M->GCS_CODLOC, M->GCS_CODEND, nOpc12), ;
                                                                     oDlg:End(), nOpcA := 0)}, ;  
                                                            {|| nOpcA := 0, oDlg:End()},, oEscolhe)

 SetKey(VK_F4, bKeyF4)

If nOpcA == 1
	FS_GrvA12(nOpc12)
EndIf
 
Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GrvA12 บ Autor ณ Cibele Peria       บ Data ณ  12/11/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina de Atualizacao das tabelas                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar (Agenda Ambulatorial)             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_GrvA12(nOpc12)

 Local wProcura := .F.
 Local lRet := .T.
 
 aCGM0 := aClone(oGM0:aCols)
 aCGM1 := aClone(oGM1:aCols)
 aCGM2 := aClone(oGM2:aCols)
 aCGMB := aClone(oGMB:aCols)
 aCGDN := aClone(oGDN:aCols)
 aCGMN	:= aClone(oGMN:aCols)
 aCGNO	:= aClone(oGNO:aCols)
 
 If nOpc12 # 2 // nao for consulta
  DbSelectArea("GCS")
  DbSetOrder(1)  // GCS_FILIAL + GCS_CODLOC
  wProcura := DbSeek(xFilial("GCS") + M->GCS_CODLOC)
  If Inclui .Or. Altera 
   RecLock("GCS", If(Altera, .F., .T.))
    HS_GRVCPO("GCS")
   MsUnlock()
   ConfirmSx8()
   
   FS_GrvGM("GM0", 1, "M->GCS_CODLOC + aCGM0[pForACols, nGM0_CODPLA]", aHGM0, aCGM0, nUGM0, nGM0_CODPLA, nGM0_STAREG)
   FS_GrvGM("GM1", 1, "M->GCS_CODLOC + aCGM1[pForACols, nGM1_CODUSU]", aHGM1, aCGM1, nUGM1, nGM1_CODUSU, nGM1_STAREG)
   FS_GrvGM("GM2", 1, "M->GCS_CODLOC + aCGM2[pForACols, nGM2_CODPRO]", aHGM2, aCGM2, nUGM2, nGM2_CODPRO, nGM2_STAREG)
   FS_GrvGM("GMB", 1, "M->GCS_CODLOC + aCGMB[pForACols, nGMB_CODTXD]", aHGMB, aCGMB, nUGMB, nGMB_CODTXD, nGMB_STAREG)
   FS_GrvGM("GDN", 1, "M->GCS_CODLOC + aCGDN[pForACols, nGDN_CODFIC]", aHGDN, aCGDN, nUGDN, nGDN_FUNCAO, nGDN_STAREG)
   FS_GrvGM("GMN", 1, "M->GCS_CODLOC + aCGMN[pForACols, nGMN_DIASEM]", aHGMN, aCGMN, nUGMN, nGMN_DIASEM, nGMN_STAREG)
   FS_GrvGM("GNO", 1, "M->GCS_CODLOC + aCGNO[pForACols, nGNO_CODPRO]", aHGNO, aCGNO, nUGNO, nGNO_CODPRO, nGNO_STAREG)
  Else  // exclusao
   If wProcura
    FS_DelGM("GM0", 1, "M->GCS_CODLOC + aCGM0[pForACols, nGM0_CODPLA]", aCGM0, nGM0_CODPLA) // Excluir relacionamento GM0
    FS_DelGM("GM1", 1, "M->GCS_CODLOC + aCGM1[pForACols, nGM1_CODUSU]", aCGM1, nGM1_CODUSU) // Excluir relacionamento GM1
    FS_DelGM("GM2", 1, "M->GCS_CODLOC + aCGM2[pForACols, nGM2_CODPRO]", aCGM2, nGM2_CODPRO) // Excluir relacionamento GM2
    FS_DelGM("GMB", 1, "M->GCS_CODLOC + aCGMB[pForACols, nGMB_CODTXD]", aCGMB, nGMB_CODTXD) // Excluir relacionamento GMB
    FS_DelGM("GDN", 1, "M->GCS_CODLOC + aCGDN[pForACols, nGDN_CODFIC]", aCGDN, nGDN_CODFIC) // Excluir relacionamento GDN
    FS_DelGM("GMN", 1, "M->GCS_CODLOC + aCGMN[pForACols, nGMN_DIASEM]", aCGMN, nGMN_DIASEM) // Excluir relacionamento GMN
    FS_DelGM("GNO", 1, "M->GCS_CODLOC + aCGNO[pForACols, nGNO_CODPRO]", aCGNO, nGNO_CODPRO) // Excluir relacionamento GNO

    DbSelectArea("GCS")
    RecLock("GCS", .F., .T.)
    	DBDelete()
     MsUnlock()
   EndIf
  EndIf
 EndIf 
              
Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_VldA12 บ Autor ณ Cibele Peria       บ Data ณ  12/11/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Validacao dos campos chave dos relacionamentos             บฑฑ
ฑฑบ          ณ para inclusao                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar (Agenda Ambulatorial)             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_VldA12(cAlias)
            
 //Local aArea := GetArea()
 Local lRet := .T., cAliasOld := Alias()
 Local _daduser :=_grupo:={}
 Local cTipEnd  := ""
                                                                                          
If cAlias == "GCS"
	If ReadVar() == "M->GCS_CODUNC"
		If !HS_SeekRet("GCT", "M->GCS_CODUNC", 1, .F., "GCS_DESUNC", "GCT_DESUNC",,, .T.)
			HS_MsgInf(STR0012, STR0013, STR0048) //"Unidade de Consumo invแlida"###"Aten็ใo"###"Cadastro de Setores"
			lRet := .F.
		EndIf
	ElseIf ReadVar() == "M->GCS_CODCCU"
		lRet := HS_VldCCU(M->GCS_CODCCU, "M->GCS_DESCCU", .T.)
	ElseIf ReadVar() == "M->GCS_ESTSUP"
		If !Empty(M->GCS_ESTSUP) .And. !HS_SeekRet("GCS", "M->GCS_ESTSUP", 1, .F., "GCS_DESESP", "GCS_NOMLOC",,, .T.)
			HS_MsgInf(STR0097, STR0013, STR0048) //"Setor invalido"###"Aten็ใo"###"Cadastro de Setores"
			lRet := .F.
		EndIf	
	ElseIf ReadVar() == "M->GCS_ARMSET"
		If !Empty(M->GCS_ARMSET) .And. !HS_SeekRet("SX5", "'AL'+M->GCS_ARMSET", 1, .F., "GCS_DESASE", "X5_DESCRI",,, .T.)
			HS_MsgInf(STR0041, STR0013, STR0048) //"Armaz้m invแlido."###"Aten็ใo"###"Cadastro de Setores"
			lRet := .F.
		EndIf
	ElseIf ReadVar() == "M->GCS_ARMFAR"
		If !Empty(M->GCS_ARMFAR) .And. !HS_SeekRet("SX5", "'AL'+M->GCS_ARMFAR", 1, .F., "GCS_DESAFA", "X5_DESCRI",,, .T.)
			HS_MsgInf(STR0041, STR0013, STR0048) //"Armaz้m invแlido."###"Aten็ใo"###"Cadastro de Setores"
			lRet := .F.
		EndIf
	ElseIf ReadVar() == "M->GCS_ARMFA2"
		If !Empty(M->GCS_ARMFA2) .And. !HS_SeekRet("SX5", "'AL'+M->GCS_ARMFA2", 1, .F., "GCS_DESAF2", "X5_DESCRI",,, .T.)
			HS_MsgInf(STR0041, STR0013, STR0048) //"Armaz้m invแlido."###"Aten็ใo"###"Cadastro de Setores"
			lRet := .F.
		EndIf
	ElseIf ReadVar() == "M->GCS_ARMDES"
		If !Empty(M->GCS_ARMDES) .And. !HS_SeekRet("SX5", "'AL'+M->GCS_ARMDES", 1, .F., "GCS_DARMDE", "X5_DESCRI",,, .T.)
			HS_MsgInf(STR0041, STR0013, STR0048) //"Armaz้m invแlido."###"Aten็ใo"###"Cadastro de Setores"
			lRet := .F.
		EndIf
	ElseIf ReadVar() == "M->GCS_PREEST"
		If !Empty(M->GCS_PREEST) .And. !HS_SeekRet("SX5", "'AL'+M->GCS_PREEST", 1, .F., "GCS_DPREST", "X5_DESCRI",,, .T.)
			HS_MsgInf(STR0041, STR0013, STR0048) //"Armaz้m invแlido."###"Aten็ใo"###"Cadastro de Setores"
			lRet := .F.
		EndIf
	ElseIf ReadVar() == "M->GCS_ENDTIP"
		cGsDCtrl := M->GCS_ENDTIP
		If M->GCS_ENDTIP <> "0" //Multi
			M->GCS_CODEND := Space(Len(GCS->GCS_CODEND))
			M->GCS_NOMEND := Space(Len(GSD->GSD_DESEND))
		EndIf
	ElseIf ReadVar() == "M->GCS_CODEND"
		If !HS_SeekRet("GSD", "M->GCS_CODEND", 1, .F., "M->GCS_NOMEND", "GSD_DESEND")
			HS_MsgInf(STR0052, STR0013, STR0048) //"C๓digo do endere็o padrใo invแlido."##"Aten็ใo"##"Cadastro de Setores"
			lRet := .F.
		Else
			If GSD->GSD_ENDTIP <> "0"
				HS_MsgInf(STR0053, STR0013, STR0048) //"Endere็o nใo ้ do tipo multi-prontuแrio."##"Aten็ใo"##"Cadastro de Setores"
				lRet := .F.
			Else
				cTipEnd := IIF(M->GCS_TIPLOC == "0", "3", IIF(M->GCS_TIPLOC == "2", "1/2", M->GCS_TIPLOC))
				If !GSD->GSD_TIPEND $ cTipEnd
					HS_MsgInf(STR0054 + ALLTRIM(HS_RDescrB("GSD_TIPEND", GSD->GSD_TIPEND)) + STR0055 + ALLTRIM(HS_RDescrB("GCS_TIPLOC", M->GCS_TIPLOC)) + "]", STR0013, STR0048) //"Tipo do endere็o ["###"] diferente do tipo do setor ["###"Aten็ใo"###"Cadastro de Setores"
					lRet := .F.
				EndIf
			EndIf
		EndIf
		If !lRet
			M->GCS_NOMEND := Space(Len(GSD->GSD_DESEND))
		EndIf
	ElseIf ReadVar() == "M->GCS_INDGM8"
		If !Empty(M->GCS_INDGM8)
			DbSelectArea("SIX")
			DbSetOrder(1) // INDICE + ORDEM
			lRet := DbSeek("GM8"+ M->GCS_INDGM8)
			If !lRet
				HS_MsgInf(STR0060, STR0013, STR0048) //"Ordem de ํndice selecionado nใo existe na tabela de agendamento ambulatorial(GM8)."###"Aten็ใo"###"Cadastro de Setores"
			Endif
		Endif
	ElseIf ReadVar() == "M->GCS_CEP"
		M->GCS_NUM := Space(Len(GCS->GCS_NUM))
		
	ElseIf ReadVar() == "M->GCS_EST"
		If !(lRet := HS_SeekRet("SX5", "'12' + M->GCS_EST", 1, .F.))
			HS_MsgInf(STR0063, STR0013, STR0064) //"Unidade Federativa nใo encontrada."###"Aten็ใo"###"Valida็ใo da digita็ใo"
		EndIf
	EndIf
ElseIf cAlias = "GM0"
	DbSelectArea("GCM")
	DbSetOrder(2)	//GCM_FILIAL + GCM_CODPLA
	lRet := DbSeek(xFilial("GCM") + M->GM0_CODPLA)
	GDFieldPut("GM0_DESPLA", GCM->GCM_DESPLA)
	If !lRet
		HS_MsgInf(STR0014, STR0013, STR0048) //"Plano invแlido"###"Aten็ใo"###"Cadastro de Setores"
	Else
		//DbSelectArea("GM4") //Verifica se existe pelo menos uma disponibilidade ambulatorial ativa com este Plano
		//DbSetOrder(2)  // GM4_CODLOC + GM4_CODPLA + GM4_IDEATI
		//If DbSeek(xFilial("GM4") + GCS->GCS_CODLOC + M->GM0_CODPLA + "1")
		//	HS_MsgInf(STR0016 + GM4->GM4_CODDIS + ")", STR0017, STR0048) //"Plano existente em disponibilidade ambulatorial ativa ("###"Identifica็ใo nใo permitida."###"Cadastro de Setores"
		//	lRet := .F.
		//Else
			DbSelectArea("GMH") //Verifica se existe pelo menos uma disponibilidade ambulatorial ativa com este Plano
			DbSetOrder(2) // GM4_CODLOC + GM4_CODPLA + GM4_IDEATI
			If DbSeek(xFilial("GMH") + GCS->GCS_CODLOC + M->GM0_CODPLA + "1")
				HS_MsgInf(STR0018 + GMH->GMH_CODDIS + ")", STR0017, STR0048) //"Plano existente em disponibilidade cir๚rgica ativa ("###"Identifica็ใo nใo permitida."###"Cadastro de Setores"
				lRet := .F.
			EndIf
		//EndIf
	EndIf
	
ElseIf cAlias == "GM1"
	PswOrder(2)  // Nome do usuario (tam=15)
	If !PswSeek(M->GM1_CODUSU, .T.)
		HS_MsgInf(STR0019, STR0013, STR0048) //"Usuแrio invแlido."###"Aten็ใo"###"Cadastro de Setores"
		lRet := .F.
	EndIf
	
ElseIF cAlias == "GM2"
	If Empty(M->GM2_CODPRO)
		lRet := .F.
	Else
		DbSelectArea("GA7")     //Cadastro de Procedimento
		DbSetOrder(1) // GA7_FILIAL + GA7_CODPRO
		lRet := DbSeek(xFilial("GA7") + M->GM2_CODPRO)
		GDFieldPut("GM2_DESPRO", GA7->GA7_DESC)
	EndIf
	If !lRet
		HS_MsgInf(STR0020, STR0013, STR0048) //"Procedimento invแlido."###"Aten็ใo"###"Cadastro de Setores"
	EndIf
	
ElseIF cAlias == "GMB"
	DbSelectArea("GAA")       // Cadastro de Taxas Diarias
	DbSetOrder(1) // GAA_FILIAL + GAA_CODTXD
	lRet := DbSeek(xFilial("GAA") + M->GMB_CODTXD)
	GDFieldPut("GMB_DESTXD", GAA->GAA_DESC)
	If !lRet
		HS_MsgInf(STR0021, STR0013, STR0048) //"Taxa diแria invแlida."###"Aten็ใo"###"Cadastro de Setores"
	EndIf
	
ElseIF cAlias == "GNO"
	DbSelectArea("SB1")       // Cadastro de Taxas Diarias
	DbSetOrder(1) // GNO_FILIAL + GNO_CODPRO
	lRet := DbSeek(xFilial("SB1") + M->GNO_CODPRO)
	GDFieldPut("GNO_DESPRO", SB1->B1_DESC)
	If !lRet
		HS_MsgInf(STR0065, STR0013, STR0048) //"Mat/Med invแlido."##"Mat/Med invแlido."###"Aten็ใo"###"Cadastro de Setores"
	EndIf
	
EndIf

 
DbSelectArea(cAliasOld)  
//RestArea(aArea) 
Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VldExcLบ Autor ณ Cibele Peria       บ Data ณ  12/11/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina de Validacao do DELETE de um Setor                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar (Agenda Ambulatorial)             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_VldExcL(cCodLoc, cCodend, nOpc12)

 Local lRet := .T., cAliasOld := Alias()

 If nOpc12 # 2 .And. !Inclui .And. !Altera     //Nao consulta nao inclusao nao alteracao
  DbSelectArea("GM6")
  DbSetOrder(2) // GM6_FILIAL + GM6_CODLOC + GM6_CODCRM
  If DbSeek(xFilial("GM6") + cCodLoc) //GM6_FILIAL + GM6_CODLOC + GM6_CODCRM
   HS_MsgInf(STR0022 + GM6->GM6_CODDIS + ")", STR0023, STR0048) //"Setor existente em disponibilidade ambulatorial ativa ("###")"###"Exclusใo nใo permitida."###"Cadastro de Setores"
   lRet := .F.
  Else
   DbSelectArea("GMD")
   DbSetOrder(2) // GMD_FILIAL + GMD_QUARTO + GMD_LEITO
   If DbSeek(xFilial("GMD") + cCodLoc) //GMD_FILIAL + GMD_CODLOC + GMD_QUARTO + GMD_LEITO
    HS_MsgInf(STR0024 + GMD->GMD_CODDIS + ")", STR0023, STR0048) //"Setor existente em Disponibilidade Cir๚rgica ativa ("###"Exclusใo nใo permitida."###"Cadastro de Setores"
    lRet := .F.
   Else
    DbSelectArea("GCY")
    DbSetOrder(8) // GCY_FILIAL + GCY_CODLOC + GCY_QUAINT + GCY_LEIINT
    If DbSeek(xFilial("GCY") + cCodLoc)
     HS_MsgInf(STR0025 + GCY->GCY_REGATE + ")", STR0023, STR0048) //"Setor existente em atendimento ("###")"###"Exclusใo nใo permitida."###"Cadastro de Setores"
     lRet := .F.
    Else
     DbSelectArea("GSB")
     DbSetOrder(2) // GSB_FILIAL + GSB_CODEND 
     If DbSeek(xFilial("GSB") + cCodEnd)//filial+codend
      HS_MsgInf(STR0056, STR0023, STR0048) //"Endere็o possui relacionamento"###"Exclusใo nใo permitida."###"Cadastro de Setores"
      lRet := .F.  
     EndIf 
    EndIf 
   EndIf
  EndIf 
  
  // Verifica se o setor esta relacionado ao Profissional //
  If lRet
  	If !(lRet := !(HS_CountTB("GBJ", "GBJ_CODLOC  = '" + cCodLoc + "'")  > 0))
  		HS_MsgInf(STR0058, STR0023, STR0048) //"Setor possui relacionamento. Existe(m) profissional(is) que utiliza(m) este setor para realizar agendamento(s) atrav้s da Anamnese"###"Exclusใo nใo permitida."###"Cadastro de Setores"	
  	EndIf
  EndIf
  
 EndIf
 
 DbSelectArea(cAliasOld)
 
Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VlExGM บ Autor ณ Cibele Peria       บ Data ณ  12/11/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Validacao a exclusao de um relacionamento do Local (um pro-บฑฑ
ฑฑบ          ณ cedimento ou um convenio                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar (Agenda Ambulatorial) 
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_VlExGM2()

 Local lRet := .T., cAliasOld := Alias()

 DbSelectArea("GM3")
 DbSetOrder(2) // GM3_FILIAL + GM3_CODLOC + GM3_CODPRO + GM3_IDEATI
 If !Empty(oGm2:aCols[oGm2:oBrowse:nAt, nGm2_CodPro]) .And. ;
  DbSeek(xFilial("GM3") + GCS->GCS_CODLOC + oGm2:aCols[oGm2:oBrowse:nAt, nGm2_CodPro] + "1")
  
  HS_MsgInf(STR0026 + GM3->GM3_CODDIS + ")", STR0023, STR0048) //"Procedimento existente em Disponibilidade Ambulatorial ativa ("###")"###"Exclusใo nใo permitida."###"Cadastro de Setores"
  lRet := .F.
  oGm2:aCols[oGm2:oBrowse:nAt, nUGm2 + 1] := .F.
  oGm2:oBrowse:Refresh()
 Else
  DbSelectArea("GMI")
  DbSetOrder(2) // GMI_FILIAL + GMI_CODLOC + GMI_CODPRO + GMI_IDEATI
  If !Empty(oGm2:aCols[oGm2:oBrowse:nAt, nGm2_CodPro]) .And. ;
   DbSeek(xFilial("GMI") + GCS->GCS_CODLOC + oGm2:aCols[oGm2:oBrowse:nAt, nGm2_CodPro] + "1")
   HS_MsgInf(STR0027 + GMI->GMI_CODDIS + ")", STR0023, STR0048) //"Procedimento existente em Cir๚rgica ativa ("###")"###"Exclusใo nใo permitida."###"Cadastro de Setores"
   lRet := .F.
   oGm2:aCols[oGm2:oBrowse:nAt, nUGm2 + 1] := .F.
   oGm2:oBrowse:Refresh()
  EndIf 
    
 EndIf
 
 DbSelectArea(cAliasOld)
 
Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GrvGM  บ Autor ณ Cibele Peria       บ Data ณ  12/11/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Grava arquivos de relacionamento - GM0, GM1 e GM2          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar (Agenda Ambulatorial)             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_GrvGM(cAlias, nOrd, cChave, aHGrv, aCGrv, nUGrv, nPos, nStaReg)

 Local nForACols := 0, cAliasOld := Alias(), lAchou := .F.
 Local cPref := cAlias + "->" + PrefixoCpo(cAlias)

 If !(Len(aCGrv) == 1 .And. Empty(aCGrv[1, nPos]))
  While (nForACols := aScan(aCGrv, {| aVet | aVet[nStaReg] <> "BR_VERDE"}, nForACols + 1)) > 0
   pForACols := nForACols
  
   DbSelectArea(cAlias)
   DbSetOrder(nOrd)
   lAchou := DbSeek(xFilial(cAlias) + &(cChave))
   If aCGrv[nForACols, nUGrv + 1] .And. lAchou // exclusao
    RecLock(cAlias, .F., .T.)
     DbDelete()
    MsUnlock()
   Else
    If !aCGrv[nForACols, nUGrv + 1]
     RecLock(cAlias, !lAchou)
      HS_GRVCPO(cAlias, aCGrv, aHGrv, nForACols)
      &(cPref + "_FILIAL") := xFilial(cAlias)
      &(cPref + "_CODLOC") := M->GCS_CODLOC
      If cAlias <> "GNO"
       &(cPref + "_LOGARQ") := HS_LogArq()  
      Endif
     MsUnlock()                  
    EndIf 
   EndIf
  End
 EndIf 
 
 DbSelectArea(cAliasOld)
 
Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_DelGM  บ Autor ณ Cibele Peria       บ Data ณ  12/11/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina de DELETE dos relacionamentos do Local              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar (Agenda Ambulatorial)             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_DelGM(cAlias, nOrd, cChave, aCGrv, nPos)

 Local nForDel := 0, cAliasOld := Alias()
 
 If !(Len(aCGrv) == 1 .And. Empty(aCGrv[1, nPos])) 
  For nForDel := 1 To Len(aCGrv)
   pForACols := nForDel
  
   DbSelectArea(cAlias)
   DbSetOrder(nOrd)
   If DbSeek(xFilial(cAlias) + &(cChave))
    RecLock(cAlias, .F., .T.)
     DbDelete()
    MsUnlock()
   EndIf
  Next
 EndIf
 
 DbSelectArea(cAliasOld)
 
Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_TudoOK บ Autor ณ Cibele Peria       บ Data ณ  01/04/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Verificacao de validade da confirmacao de atualizacao      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar (Agenda Ambulatorial)             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_TudoOK(cAlias, oOK, nPos)

Return(IIF(Len(oOk:aCols) <> 1 .Or. !Empty(oOK:aCols[1, nPos]), oOk:TudoOk(), .T.))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_Busca  บ Autor ณ Marcelo Jose       บ Data ณ  21/12/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina para selecionar dados ( facilitadores )             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar (Agenda Ambulatorial)             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_Busca(nVem)

 Local oSay1, oSay2,oSay3,oSay4, oSay5,oSay6, oGet1, oGet2, oGet3, oGet4, oGet5, oGet6
 Local cFraseOp1 := "", cFraseOp2 := "", cFraseOp3 := "", cFraseOp4 := "", cFraseOp5 := "", cFraseOp6 := ""
 Local nRespoOp1 := "", nRespoOp2 := "", nRespoOp3 := "", nRespoOp4 := "", nRespoOp5 := "", nRespoOp6 := ""
 
	If StrZero(nVem , 2) $ "05/06"
		MsgStop(STR0061+IIF(nVem == 5, STR0043, STR0046) + "'") //"Op็ใo nใo disponํvel para '"###"Fichas"###"Cirurgias x Dia"
		return(nil)
	EndIf
 
 If nVem == 1
  cFraseOp1 := STR0028 //"Do Plano    "
  cFraseOp2 := STR0029 //"At้ o Plano "
  nRespoOp1 := Space(6); nRespoOp2 := Space(6)
 ElseIf nVem == 2
  cFraseOp1 := STR0030 //"Do Usuแrio   "
  cFraseOp2 := STR0031 //"At้ o Usuแrio"
  nRespoOp1 := Space(15); nRespoOp2 := Space(15)
 ElseIf nVem == 3
  cFraseOp1 := STR0032 //"Do Procedimento    "
  cFraseOp2 := STR0033 //"At้ o Procedimento "
  cFraseOp3 := STR0034 //"Da Especialidade   "
  cFraseOp4 := STR0035 //"At้ a Especialidade"
  cFraseOp5 := STR0049 //"Do Grp Procedimento"
  cFraseOp6 := STR0050 //"At้ Grp Procedimento"
  nRespoOp1 := Space(9); nRespoOp2 := Space(9)
  nRespoOp3 := Space(2); nRespoOp4 := Space(2)
  nRespoOp5 := Space(9); nRespoOp6 := Space(9)
 ElseIf nVem == 4
  cFraseOp1 := STR0036 //"Da Taxa   "
  cFraseOp2 := STR0037 //"At้ a Taxa"
  cFraseOp3 := STR0038 //"Da Categoria"
  cFraseOp4 := STR0039 //"At้ a Categoria"
  nRespoOp1 := Space(10); nRespoOp2 := Space(10)
  nRespoOp3 := Space(2); nRespoOp4 := Space(2)
 ElseIf nVem == 7
  cFraseOp1 := STR0066 //"Do Mat/Med"
  cFraseOp2 := STR0067 //"At้ o Mat/Med"
  nRespoOp1 := Space(len(SB1->B1_COD)); nRespoOp2 := Space(len(SB1->B1_COD))
 EndIf
 
 DEFINE MSDIALOG oDlgBus TITLE STR0040 + cFraseOp1 From 01, 01 To 250, 500	Of oMainWnd PIXEL  //"Sele็ใo "
  oSay1 := tSay():New(22, 10, {||cFraseOp1}, oDlgBus,,,,,, .T.,,, 130, 10) 
  oSay2 := tSay():New(37, 10, {||cFraseOp2}, oDlgBus,,,,,, .T.,,, 130, 10) 
  If nVem == 1
   oGet1 := tGet():New(20, 70, {|u| If(PCount() > 0, nRespoOp1 := u , nRespoOp1)}, oDlgBus, 50, 10, "@!",,,,,,,.T.,,,,,,,,, "GCM", "nRespoOp1")    
   oGet2 := tGet():New(35, 70, {|u| If(PCount() > 0, nRespoOp2 := u , nRespoOp2)}, oDlgBus, 50, 10, "@!",,,,,,,.T.,,,,,,,,, "GCM", "nRespoOp2")   
  ElseIf nVem == 2
   oGet1 := tGet():New(20, 70, {|u| If(PCount() > 0, nRespoOp1 := u , nRespoOp1)}, oDlgBus, 100, 10, "@!",,,,,,,.T.,,,,,,,,, "US3", "nRespoOp1")    
   oGet2 := tGet():New(35, 70, {|u| If(PCount() > 0, nRespoOp2 := u , nRespoOp2)}, oDlgBus, 100, 10, "@!",,,,,,,.T.,,,,,,,,, "US3", "nRespoOp2")     
  ElseIf nVem == 3
   oSay3 := tSay():New(82, 10, {||cFraseOp3}, oDlgBus,,,,,, .T.,,, 130, 10) 
   oSay4 := tSay():New(97, 10, {||cFraseOp4}, oDlgBus,,,,,, .T.,,, 130, 10) 
   oSay5 := tSay():New(52, 10, {||cFraseOp5}, oDlgBus,,,,,, .T.,,, 130, 10) 
   oSay6 := tSay():New(67, 10, {||cFraseOp6}, oDlgBus,,,,,, .T.,,, 130, 10) 
   oGet1 := tGet():New(20, 70, {|u| If(PCount() > 0, nRespoOp1 := u , nRespoOp1)}, oDlgBus, 50, 10, "@!",,,,,,, .T.,,,,,,,,, "GA7", "nRespoOp1")    
   oGet2 := tGet():New(35, 70, {|u| If(PCount() > 0, nRespoOp2 := u , nRespoOp2)}, oDlgBus, 50, 10, "@!",,,,,,, .T.,,,,,,,,, "GA7", "nRespoOp2") 
   oGet5 := tGet():New(50, 70, {|u| If(PCount() > 0, nRespoOp5 := u , nRespoOp5)}, oDlgBus, 50, 10, "@!",,,,,,, .T.,,,,,,,,, "GAQ", "nRespoOp5")    
   oGet6 := tGet():New(65, 70, {|u| If(PCount() > 0, nRespoOp6 := u , nRespoOp6)}, oDlgBus, 50, 10, "@!",,,,,,, .T.,,,,,,,,, "GAQ", "nRespoOp6") 
   
   If lGFR
   	oGet3 := tGet():New(80, 70, {|u| If(PCount() > 0, nRespoOp3 := u , nRespoOp3)}, oDlgBus, 30, 10, "@!",,,,,,, .T.,,,,,,,,, "GFR001", "nRespoOp3")    
   	oGet4 := tGet():New(95, 70, {|u| If(PCount() > 0, nRespoOp4 := u , nRespoOp4 )}, oDlgBus, 30, 10, "@!",,,,,,, .T.,,,,,,,,, "GFR001", "nRespoOp4")
   Else
   	oGet3 := tGet():New(80, 70, {|u| If(PCount() > 0, nRespoOp3 := u , nRespoOp3)}, oDlgBus, 30, 10, "@!",,,,,,, .T.,,,,,,,,, "EM" , "nRespoOp3")    
   	oGet4 := tGet():New(95, 70, {|u| If(PCount() > 0, nRespoOp4 := u , nRespoOp4)}, oDlgBus, 30, 10, "@!",,,,,,, .T.,,,,,,,,, "EM" , "nRespoOp4")
   EndIf
   
  ElseIf nVem == 4
   oSay3 := tSay():New(52, 10, {||cFraseOp3}, oDlgBus,,,,,, .T.,,, 130, 10) 
   oSay4 := tSay():New(67, 10, {||cFraseOp4}, oDlgBus,,,,,, .T.,,, 130, 10) 
   oGet1 := tGet():New(20, 70, {|u| If(PCount() > 0, nRespoOp1 := u, nRespoOp1)}, oDlgBus, 30, 10, "@!",,,,,,, .T.,,,,,,,,, "GAA","nRespoOp1")    
   oGet2 := tGet():New(35, 70, {|u| If(PCount() > 0, nRespoOp2 := u, nRespoOp2)}, oDlgBus, 30, 10, "@!",,,,,,, .T.,,,,,,,,, "GAA","nRespoOp2")     
   oGet3 := tGet():New(50, 70, {|u| If(PCount() > 0, nRespoOp3 := u, nRespoOp3)}, oDlgBus, 30, 10, "@!",,,,,,, .T.,,,,,,,,, "CT" , "nRespoOp3")    
   oGet4 := tGet():New(65, 70, {|u| If(PCount() > 0, nRespoOp4 := u, nRespoOp4)}, oDlgBus, 30, 10, "@!",,,,,,, .T.,,,,,,,,, "CT" , "nRespoOp4")   
  ElseIf nVem == 7
  
   oGet1 := tGet():New(20, 70, {|u| If(PCount() > 0, nRespoOp1 := u , nRespoOp1)}, oDlgBus, 60, 10, "@!",,,,,,,.T.,,,,,,,,, "G1R", "nRespoOp1")    
   oGet2 := tGet():New(35, 70, {|u| If(PCount() > 0, nRespoOp2 := u , nRespoOp2)}, oDlgBus, 60, 10, "@!",,,,,,,.T.,,,,,,,,, "G1R", "nRespoOp2")   
  EndIf

 ACTIVATE MSDIALOG oDlgBus CENTERED ON INIT EnchoiceBar (oDlgBus, {|| Processa({||FS_Monta(nVem, nRespoOp1, nRespoOp2, nRespoOp3, nRespoOp4, nRespoOp5, nRespoOp6)}), oDlgBus:End()}, {|| oDlgBus:End()})
Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_Monta  บ Autor ณ Marcelo Jose       บ Data ณ  21/12/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina para Gerar dados (facilitadores)                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar (Agenda Ambulatorial)             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_Monta(nVem, cParvem1, cParvem2, cParvem3, cParvem4, cParvem5, cParvem6)

 Local aVetUsr := {}, nCtaFor := 0, lValida := .T.
 Local cCodUser := "", cCodUser2 := ""

 If nVem == 1 /*PLANOS*/
  DbSelectArea("GCM")
  DbSetOrder(2) // GCM_FILIAL + GCM_CODPLA
  ProcRegua(reccount())
  DbSeek(xFilial("GCM") + cParvem1, .T. )
  While GCM->GCM_FILIAL == xFilial("GCM") .And. GCM->GCM_CODPLA <= cParvem2 .And. !Eof()
                                                             
   If ASCAN(aCGM0,{ | aVet | aVet[nGM0_CODPLA] == GCM->GCM_CODPLA}) == 0//Verificando a Existencia do codigo no vetor
                                                                          //Evitando a duplicidade
	   IncProc(STR0042 + GCM->GCM_CODPLA) //"Aguarde, processando dados "
	   IF !Empty(aCGM0[Len(aCGM0), nGM0_CODPLA	])
	    aAdd(aCGM0, oGM0:aCols[1])
	   EndIf      
	   aCGM0[Len(aCGM0), nGM0_STAREG	] := "BR_VERMELHO"
	   aCGM0[Len(aCGM0), nGM0_CODPLA	] := GCM->GCM_CODPLA
	   aCGM0[Len(aCGM0), nGM0_DESPLA	] := GCM->GCM_DESPLA 
	   oGM0:SetArray(aCGM0)
	  EndIf 
   DbSkip()
  EndDo
  If Len(aCGM0) > 0
   oGM0:oBrowse:Refresh()
  EndIf 
  
 ElseIf nVem == 2 /*USUARIOS*/
  aVetUsr := AllUsers()
  If Len(aVetUsr) > 0
   For nCtaFor := 1 To Len(aVetUsr)
   
    If Empty(cParvem1) .And. Empty(cParvem2)
     exit
    Else 
     If !Empty(cParvem1) 
      If aVetUsr[nCtafor, 1, 2] == cParvem1 
       cCodUser := aVetUsr[nCtafor, 1, 1]
      Endif
     Endif 
     
     If aVetUsr[nCtafor, 1, 2] == cParvem2 .And. !Empty(cParvem2)
      cCodUser2 := aVetUsr[nCtafor, 1, 1]
     Endif 
    
    Endif
     
    If ((Empty(cCodUser) .And. !Empty(cParvem1)) .Or. (aVetUsr[nCtafor, 1, 1] < cCodUser) .Or. (!Empty(cCodUser2) .And. aVetUsr[nCtafor, 1, 1] > cCodUser2))
     Loop
    Else
   
     If ASCAN(aCGM1,{| aVet | aVet[nGM1_CODUSU] == aVetUsr[nCtafor, 1, 2]}) == 0
	
	     IF Empty(aCGM1[Len(aCGM1), nGM1_CODUSU	])
	      aCGM1[Len(aCGM1), nGM1_CODUSU] := aVetUsr[nCtafor, 1, 2]
	     Else
	      aAdd(aCGM1, {"BR_VERMELHO", aVetUsr[nCtafor, 1, 2], "0", .F.})
	     EndIf   
	    EndIf 
    EndIf
   Next
  EndIf
  
  If Len(aCGM1) > 0
   oGM1:SetArray(aCGM1)
   oGM1:oBrowse:Refresh()
  EndIf    
  
 ElseIf nVem == 3 /*PROCEDIMENTOS*/
  DbSelectArea("GA7")
  DbSetOrder(1) // GA7_FILIAL + GA7_CODPRO
  ProcRegua(RecCount())
  DbSeek(xFilial("GA7") + cParvem1, .T. )
  While GA7->GA7_FILIAL == xFilial("GA7") .And. GA7->GA7_CODPRO <= cParvem2 .And. !Eof()
   IncProc(STR0042 + GA7->GA7_CODPRO) //"Aguarde, processando dados "
   
   //Checando se os parametros foram digitados 
   if (!Empty(cParvem3)    .And. (GA7->GA7_CODESP < cParvem3)) .or. (!Empty(cParvem4) .And. (GA7->GA7_CODESP > cParvem4)) ;                                                      
    .or. (!Empty(cParvem5) .And. (GA7->GA7_CODGPP < cParvem5)) .or. (!Empty(cParvem6) .And. (GA7->GA7_CODGPP > cParvem6)) 
     DbSkip()
     Loop
   EndIf
   
   If ASCAN(aCGM2,{| aVet | aVet[nGM2_CODPRO] == GA7->GA7_CODPRO}) == 0
	   If !Empty(aCGM2[Len(aCGM2), nGM2_CODPRO	])
	    aAdd(aCGM2, oGM2:aCols[1])
	   EndIf
	   aCGM2[Len(aCGM2), nGM2_STAREG	] := "BR_VERMELHO"
	   aCGM2[Len(aCGM2), nGM2_CODPRO	] := GA7->GA7_CODPRO
	   aCGM2[Len(aCGM2), nGM2_DESPRO	] := GA7->GA7_DESC
	   oGM2:SetArray(aCGM2)
   EndIf
   DbSkip()
  EndDo
  
  If Len(aCGM2) > 0
   oGM2:SetArray(aCGM2)
   oGM2:oBrowse:Refresh()
  EndIf 
 
 ElseIf nVem == 4 /*TAXAS*/

  DbSelectArea("GAA")
  DbSetOrder(1) // GAA_FILIAL + GAA_CODTXD
  ProcRegua(reccount())
  DbSeek(xFilial("GAA") + cParvem1, .T. )
  While GAA->GAA_FILIAL == xFilial("GAA") .And. GAA->GAA_CODTXD <= cParvem2 .And. !Eof()

   IncProc(STR0042 + GAA->GAA_CODTXD) //"Aguarde, processando dados "

   if (!Empty(cParvem3) .And. (GAA->GAA_CODCTD < cParvem3)) .Or. (!Empty(cParvem4) .And. (GAA->GAA_CODCTD > cParvem4))
    DbSkip()
    Loop
   EndIf

   If ASCAN(aCGMB,{|aVet| aVet[nGMB_CODTXD] == GAA->GAA_CODTXD}) == 0
	   IF !Empty(aCGMB[Len(aCGMB), nGMB_CODTXD	])
	    aAdd(aCGMB, oGMB:aCols[1])
	   EndIf
	   aCGMB[Len(aCGMB), nGMB_STAREG] := "BR_VERMELHO"
	   aCGMB[Len(aCGMB), nGMB_CODTXD] := GAA->GAA_CODTXD
	   aCGMB[Len(aCGMB), nGMB_DESTXD] := GAA->GAA_DESC  
	   oGMB:SetArray(aCGMB)
	  EndIf 
	  
   DbSkip()
  EndDo
  If Len(aCGMB) > 0
   oGMB:SetArray(aCGMB)
   oGMB:oBrowse:Refresh()
  EndIf 
 
 ElseIf nVem = 7
 
  DbSelectArea("SB1")
  DbSetOrder(1) // GCM_FILIAL + GCM_CODPLA
  ProcRegua(reccount())
  DbSeek(xFilial("SB1") + cParvem1, .T. )
  While SB1->B1_FILIAL == xFilial("SB1") .And. SB1->B1_COD <= cParvem2 .And. !Eof()
                                                             
   If ASCAN(aCGNO,{ | aVet | aVet[nGNO_CODPRO] == SB1->B1_COD}) == 0//Verificando a Existencia do codigo no vetor
                                                                          //Evitando a duplicidade
	   IncProc(STR0042 + SB1->B1_COD) //"Aguarde, processando dados "
	   IF !Empty(aCGNO[Len(aCGNO), nGNO_CODPRO	])
	    aAdd(aCGNO, oGNO:aCols[1])
	   EndIf
	   aCGNO[Len(aCGNO), nGNO_STAREG	] := "BR_VERMELHO"
	   aCGNO[Len(aCGNO), nGNO_CODPRO	] := SB1->B1_COD
	   aCGNO[Len(aCGNO), nGNO_DESPRO	] := SB1->B1_DESC 
	   oGNO:SetArray(aCGNO)
	  EndIf 
   DbSkip()
  EndDo
  If Len(aCGNO) > 0
   oGNO:oBrowse:Refresh()
  EndIf 
 EndIf
 
Return(Nil)                         


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_A12FUNCบ Autor ณ Gilson da Silva    บ Data ณ  08/04/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Validacao do campo GDN_FUNCAO, verifica se a funcao        บฑฑ
ฑฑบ          ณ digitada existe no sistema.                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar (Agenda Ambulatorial)             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_A12FUNC(cNomFunc)

 Local lRet := .T.
 Local aFichas := HS_RetFichas()
 Local nPFicha := 0
 
 If !(lRet := ((nPFicha := aScan(aFichas, {| aVet | PadR(AllTrim(aVet[1]), Len(GDN->GDN_FUNCAO)) == cNomFunc})) > 0))
  HS_MsgInf(STR0068, STR0013, STR0059) //"Informa็ใo invalida, somente fichas, termos e etiquetas podem ser utilizadas"##"Aten็ใo"###"Valida็ใo de fun็ใo"

 Else
  //"Nome", "Qtd.Vias", "Modo", "Qtd.Linhas", "Tp.Fonte", "Tam.Linha"
  oGdn:aCols[oGdn:nAt, aScan(oGdn:aHeader, {| aVet | aVet[2] == "GDN_NOMFIC"})] := aFichas[nPFicha][2]
  oGdn:aCols[oGdn:nAt, aScan(oGdn:aHeader, {| aVet | aVet[2] == "GDN_NVIAS "})] := aFichas[nPFicha][3]
  oGdn:aCols[oGdn:nAt, aScan(oGdn:aHeader, {| aVet | aVet[2] == "GDN_MODIMP"})] := aFichas[nPFicha][4]
  oGdn:aCols[oGdn:nAt, aScan(oGdn:aHeader, {| aVet | aVet[2] == "GDN_QTLIN "})] := aFichas[nPFicha][5]
  oGdn:aCols[oGdn:nAt, aScan(oGdn:aHeader, {| aVet | aVet[2] == "GDN_TPFONT"})] := aFichas[nPFicha][6]
  oGdn:aCols[oGdn:nAt, aScan(oGdn:aHeader, {| aVet | aVet[2] == "GDN_TAMLIN"})] := aFichas[nPFicha][7]
  oGdn:oBrowse:Refresh()

 EndIf
 
Return(lRet)


/*
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_DescA12บ Autor ณ Daniel Peixoto     บ Data ณ  17/10/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina de validacao dos campos de descricao.               บฑฑ
ฑฑบ          ณ Chamada do X3_RELACAO do campo de Acordo com o Parametro   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_DescA12(cAlias, nCpo)

 Local cCodChave := ""
 Local cDescri     := ""  
 
 If cAlias == "GM0"
  cCodChave := IIF(Inclui, "", IIF(Alias() == "TMPGM0", (Alias())->GM0_CODPLA, ""))
  If !Empty(cCodChave)
   cDescri := HS_IniPadr("GCM", 2, cCodChave, "GCM_DESPLA",, .F.)
  EndIf 
  
 ElseIf cAlias == "GM2"     
   cCodChave := IIF(Inclui, "", IIF(Alias() == "TMPGM2", (Alias())->GM2_CODPRO, ""))
   If !Empty(cCodChave)
    cDescri := HS_IniPadr("GA7", 1, cCodChave, "GA7_DESC",, .F.)
   EndIf 
   
 ElseIf cAlias == "GMB"     
   cCodChave := IIF(Inclui, "", IIF(Alias() == "TMPGMB", (Alias())->GMB_CODTXD, ""))
   If !Empty(cCodChave)
    cDescri := HS_IniPadr("GAA", 1, cCodChave, "GAA_DESC",, .F.)
   EndIf 
   
 ElseIf cAlias == "GNO"
  cCodChave := IIF(Inclui, "", IIF(Alias() == "TMPGNO", (Alias())->GNO_CODPRO, ""))
  If !Empty(cCodChave)
   cDescri := HS_IniPadr("SB1", 1, cCodChave, "B1_DESC",, .F.)
  EndIf  
 EndIf
 
Return(cDescri)    

     
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VLDTIP บ Autor ณ Mario Arizono      บ Data ณ  20/06/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Valida se o campo enderco padrao esta preenchido caso      บฑฑ
ฑฑบ          ณ tenha sido escolhido multi-prontuario no campo controle.   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar 																					             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_VLDTIP()

 Local lRet := .T.

 If M->GCS_ENDTIP == "0" .And. (Inclui .Or. Altera)
  If Empty(M->GCS_CODEND)
   HS_MsgInf(STR0057, STR0013, STR0048) //"Para Controle de Endere็o Multi-Prontuario ้ obrigat๓rio preencher o campo endere็o padrใo."##"Aten็ใo"##"Cadastro de Setores"
   lRet := .F.
  EndIf
 EndIf
  
Return(lRet)          


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VLDESP บ Autor ณ Rogerio Tabosa     บ Data ณ  17/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Valida se o campo GCS_ESTSUP (Estrutura superior) esta     บฑฑ
ฑฑบ          ณ preenchido caso o tipo de setor escolhido seja             บฑฑ
ฑฑบ          ณ (H-SubEstrutura).                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar 																					             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_VLDESP()

 Local lRet := .T.

 If M->GCS_TIPLOC == "H" 
  If Empty(M->GCS_ESTSUP)
   HS_MsgInf(STR0098, STR0013, STR0048) //"Necessแrio informar o c๓digo da estrutura superior para setores do tipo (H = Sub-estrutura)!"##"Aten็ใo"##"Cadastro de Setores"
   lRet := .F.
  EndIf
 EndIf
  
Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_TipLoc บ Autor ณ Patricia Queiroz   บ Data ณ  05/10/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao utilizada para tratar a descricao do campo combo.   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar 																					             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_TipLoc()

Local cDescri := ""

cDescri := "0=Intern; 1=Ambulat; 2=P. Atendto; 3=Enferm; 4=C. Cirug; 5=Marcacao; 6=Reserva C. C.; 7=Administ; "
cDescri += "8=Bercario; 9=Laudo; A=Farmac; B=Espera; C=Doacao; D=Consult๓rio; E=Coleta; F=Recurso Glosa; G=Laboratorio; H=Sub-estrutura; "
cDescri += "I=Marcac Clinica; J=Atend Clinica"
 
Return(cDescri) 




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_RtCamp บ Autor ณ Patricia Queiroz   บ Data ณ  29/03/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Fun็ใo para descarregar os campos de endere็o.             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_RtCamp()

 Local lRet  := .F.
 Local aArea := GetArea()
 
 If ReadVar() == "M->GCS_CEP"
  lRet := HS_SeekRet("GAM", "M->GCS_CEP", 3, .F., {"GCS_MUN", "GCS_EST", "GCS_RUA", "GCS_BAIRRO"}, {"GAM_MUNICI","GAM_EST","GAM_END","GAM_BAIRRO"})  
 EndIf 

 RestArea(aArea)       
            
Return(lRet)

Function HS_FilFic()
 Local aFichas := {}
 Local cFichas := ""
 Local oFichas
 Local oDlgFic
 Local lRet := .F.
 
 aFichas := HS_RetFichas()
 
 If Empty(aFichas)
 	Return(lRet)
 EndIf
 
 Define MsDialog oDlgFic Title OemToAnsi(STR0089) From 000, 000 To 500, 850 Of oMainWnd PIXEL //"Lista de fichas"
  @ 005, 005 LISTBOX oFichas VAR cFichas FIELDS HEADER STR0090, STR0091, STR0092, STR0093, STR0094, STR0095, STR0096 /*COLSIZES 190, 190, 30*/ SIZE 400, 250 OF oDlgFic PIXEL ;  //"Fichas"##"Nome"##"Qtd.Vias"##"Modo"##"Qtd.Linhas"##"Tp.Fonte"##"Tam.Linha"
             ON DBLCLICK (__cRetFic := aFichas[oFichas:nAt, 01], lRet := .T., oDlgFic:End())
  oFichas:Align := CONTROL_ALIGN_ALLCLIENT

  oFichas:SetArray(aFichas)

  oFichas:bLine := {|| {aFichas[oFichas:nAt, 01], ;
                        aFichas[oFichas:nAt, 02], ;
                        aFichas[oFichas:nAt, 03], ;
                        PadR(AllTrim(HS_RDescrB("GDN_MODIMP", aFichas[oFichas:nAt, 04])), 11), ;
                        aFichas[oFichas:nAt, 05], ;
                        PadR(AllTrim(HS_RDescrB("GDN_TPFONT", aFichas[oFichas:nAt, 06])), 10), ;
                        PadR(AllTrim(HS_RDescrB("GDN_TAMLIN", aFichas[oFichas:nAt, 07])), 07)}}
 Activate MsDialog oDlgFic Centered
 
Return(lRet)

Function HS_DetFic(cDirTxt, cNomFic)
 Local cModImp  := "0"
 Local cLinha   := ""
 Local lRetFic  := .F.
 Local nQtdLin  := 55
 Local nQtdVias := 1
 Local cTPFont  := "2"
 Local cTamLin  := "1"
 Local nPosMI   := 0
 Local nPosQL   := 0
 Local nPosQV   := 0
 Local nPosTF   := 0
 Local nPosTL   := 0
                            
 If lRetFic := !(Empty(cLinha := MemoRead(cDirTxt + cNomFic)))
              
  If (nPosMI := AT("#MI", cLinha)) > 0 // 0=Nใo ou 1=Sim, sinaliza utiliza็ใo da fun็ใo Cabec no relat๓rio
   cModImp := SubStr(cLinha, nPosMI + 3, 1)
  EndIf
    
  If (nPosQL := AT("#QL", cLinha)) > 0 // sinaliza a quantidade de linhas por pagina
   nQtdLin := Val(AllTrim(SubStr(cLinha, nPosQL + 3, 3)))
  EndIf
    
  If (nPosQV := AT("#QV", cLinha)) > 0 // sinaliza a quantidade de vias por ficha
   nQtdVias := Val(AllTrim(SubStr(cLinha, nPosQV + 3, 3)))
  EndIf
    
  If (nPosTF := AT("#TF", cLinha)) > 0 // 1=Comprimido ou 2=Normal, sinaliza o tipo de fonte (Compactado ou Normal)
   cTPFont := SubStr(cLinha, nPosTF + 3, 1)
  EndIf
    
  If (nPosTL := AT("#TL", cLinha)) > 0 // 1=P ou 2=M ou 3=G, sinaliza o tamanho da pagina P, M ou G
   cTamLin := SubStr(cLinha, nPosTL + 3, 1)
  EndIf
 
 EndIf 
Return({lRetFic, nQtdVias, cModImp, nQtdLin, cTPFont, cTamLin})

Function HS_RetFichas()
 Local aSvArea := GetArea()
 Local cDirTxt := AllTrim(GetMV("MV_DIRTXT"))
 Local aDirTxt := {}
 Local aFichas := {}
 Local aDetFic := {}
 Local cParEtq := ""
 Local cParArq := ""
 
 cDirTxt += IIf(SubStr(cDirTxt, Len(cDirTxt), 1) <> "\", "\", "")
 
 If     Empty(cDirTxt)
  HS_MsgInf(STR0071, STR0013, STR0072) //"Defina o parโmetro [MV_DIRTXT] com o diret๓rio onde estใo localizados o arquivos das fichas."##"Aten็ใo"##"Fichas"
  Return({})
 ElseIf !lIsDir(cDirTxt)                                                                                                             
  HS_MsgInf(STR0073 + cDirTxt + STR0074, STR0013, STR0072) //"Diret๓rio ["##"] definido no parโmetro [MV_DIRTXT] nใo existe."##"Aten็ใo"##"Fichas"
  Return({})
 EndIf
 
 // 0=Txt C/Cabec;1=Txt S/Cabec;4=Imagem;
 // Pega arquivo para uso do HSPFITXT
 aDirTxt := Directory(cDirTxt + "*.TXT")
 aEVal( aDirTxt, {| aFile | {aDetFic := HS_DetFic(cDirTxt, aFile[1]), IIf(aDetFic[1], aAdd(aFichas, {PadR(aFile[1], Len(GDN->GDN_FUNCAO)), PadR(aFile[1], Len(GDN->GDN_FUNCAO)), aDetFic[2], aDetFic[3], aDetFic[4], aDetFic[5], aDetFic[6]}), .F.)}})
                               
 // 2=Fic.Pad.Txt;3=Fic.Pad.Img
 // Pega fichas padr๕es
 aAdd(aFichas, {PadR("01", Len(GDN->GDN_FUNCAO)), PadR(STR0075          , Len(GDN->GDN_FUNCAO)), 1, "2", 55, "2", "1"})  //"Prontuแrio do Paciente"
 
 // Pega todos os termos de reponsabilidade existentes no cadastro.
 DbSelectArea("GDW")
 DbGoTop()
 While !Eof() .And. GDW->GDW_FILIAL == xFilial("GDW")
  aAdd(aFichas, {PadR("02('" + GDW->GDW_CODTER + "')", Len(GDN->GDN_FUNCAO)), PadR(AllTrim(GDW->GDW_DESCRI), Len(GDN->GDN_FUNCAO)), 1, "2", 55, "2", "1"})
  
  DbSkip()
 End 
 
 aAdd(aFichas, {PadR("03", Len(GDN->GDN_FUNCAO)), PadR(STR0076     , Len(GDN->GDN_FUNCAO)), 1, "2", 55, "2", "1"}) //"Solicitacao de Procedimento"
 aAdd(aFichas, {PadR("04", Len(GDN->GDN_FUNCAO)), PadR(STR0077     , Len(GDN->GDN_FUNCAO)), 1, "2", 55, "2", "1"}) //"Ficha de CCIH"
 aAdd(aFichas, {PadR("05", Len(GDN->GDN_FUNCAO)), PadR(STR0078     , Len(GDN->GDN_FUNCAO)), 1, "2", 55, "2", "1"}) //"Laudo M้dico"
 aAdd(aFichas, {PadR("06", Len(GDN->GDN_FUNCAO)), PadR(STR0079     , Len(GDN->GDN_FUNCAO)), 1, "2", 55, "2", "1"}) //"Laudo Obstetrico"
 aAdd(aFichas, {PadR("07", Len(GDN->GDN_FUNCAO)), PadR(STR0080     , Len(GDN->GDN_FUNCAO)), 1, "2", 55, "2", "1"}) //"Formulario de Prescriscao Medica"
 aAdd(aFichas, {PadR("08", Len(GDN->GDN_FUNCAO)), PadR(STR0081     , Len(GDN->GDN_FUNCAO)), 1, "2", 55, "2", "1"}) //"Evolucao do Paciente"
 aAdd(aFichas, {PadR("09", Len(GDN->GDN_FUNCAO)), PadR(STR0082     , Len(GDN->GDN_FUNCAO)), 1, "2", 55, "2", "1"}) //"Anota็๕es de Enfermagem"
 aAdd(aFichas, {PadR("10", Len(GDN->GDN_FUNCAO)), PadR(STR0083     , Len(GDN->GDN_FUNCAO)), 1, "2", 55, "2", "1"}) //"Controle de e Balanco Hidricoe"
 aAdd(aFichas, {PadR("11", Len(GDN->GDN_FUNCAO)), PadR(STR0084     , Len(GDN->GDN_FUNCAO)), 1, "2", 55, "2", "1"}) //"Autoriza็ใo de Doctos"
 aAdd(aFichas, {PadR("12", Len(GDN->GDN_FUNCAO)), PadR(STR0085     , Len(GDN->GDN_FUNCAO)), 1, "2", 55, "2", "1"}) //"Atendimento Ambulatorial SUS"
 aAdd(aFichas, {PadR("13", Len(GDN->GDN_FUNCAO)), PadR(STR0086     , Len(GDN->GDN_FUNCAO)), 1, "2", 55, "2", "1"}) //"Atendimento ambulatorial"
 aAdd(aFichas, {PadR("14", Len(GDN->GDN_FUNCAO)), PadR(STR0087     , Len(GDN->GDN_FUNCAO)), 1, "3", 55, "2", "1"}) //"Admissใo e Alta"
 aAdd(aFichas, {PadR("15", Len(GDN->GDN_FUNCAO)), PadR(STR0088     , Len(GDN->GDN_FUNCAO)), 1, "3", 55, "2", "1"}) //"Prescri็ใo M้dica"
 
 //5=Etiqueta
 // Pega etiquetas
 DbSelectArea("GC7")
 DbGoTop()
 While !Eof() .And. GC7->GC7_FILIAL == xFilial("GC7")
  cParEtq := "{__QTDEIMP"
  
  DbSelectArea("GC8")
  DbSetOrder(1)
  DbSeek(xFilial("GC8") + GC7->GC7_CODETI)
  While !Eof() .And. GC8->GC8_FILIAL == xFilial("GC8") .And. GC8->GC8_CODETI == GC7->GC7_CODETI
  
   If GC8->GC8_PARAM == "1"
    cParArq := HS_CfgSx3(GC8->GC8_CAMPO)[SX3->(FieldPos("X3_ARQUIVO"))]
    If GC8->GC8_TPARAM == "0" // Nใo Gera Intervalo
     cParEtq += ", " + cParArq + "->" + AllTrim(GC8->GC8_CAMPO)
     
    ElseIf GC8->GC8_TPARAM == "1" // Gera Intervalo
     cParEtq += ", " + cParArq + "->" + AllTrim(GC8->GC8_CAMPO) + ", " + cParArq + "->" + AllTrim(GC8->GC8_CAMPO)

    EndIf
   EndIf 
   
   DbSkip()
  End                
  
  cParEtq += "}"
 
  aAdd(aFichas, {PadR("'" + GC7->GC7_CODETI + "', " + cParEtq, Len(GDN->GDN_FUNCAO)), PadR(AllTrim(GC7->GC7_DESCR), Len(GDN->GDN_FUNCAO)), 1, "5", 55, "2", "1"})
  
  DbSelectArea("GC7")
  DbSkip()
 End 
 
 RestArea(aSvArea)
Return(aFichas) 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ MenuDef  ณ Autor ณ 				        ณ Data ณ 15/07/15 ณฑฑ
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
//ณ    3 - Incluir							                     ณ
//ณ    4 - Alterar			                                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aRotina :=	{{OemToAnsi(STR0001) 	, "axPesqui" 	, 0, 1, 0, nil}, ; //"Pesquisar" 
                     {OemToAnsi(STR0002)	, "HS_A12"		, 0, 2, 0, nil}, ; //"Visualizar" 
                     {OemToAnsi(STR0003)   , "HS_A12"		, 0, 3, 0, nil}, ; //"Incluir" 
                     {OemToAnsi(STR0004)   , "HS_A12"		, 0, 4, 0, nil}, ; //"Alterar" 
                     {OemToAnsi(STR0005)   , "HS_A12"		, 0, 5, 0, nil}}   //"Excluir"
Return(aRotina)

